#include "protheus.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "PLSMGER.CH"

/*/{Protheus.doc} PLSLOTENF
Rotina geracao lote de fechamento NF
@type function
@version 12.1.2310
@author claudiol
@since 7/10/2024
/*/
function PLSLOTENF

	local oBrwB0J
	local lContinua:= .T.

	iif((BCI->(FieldPos("BCI_LOTENF"))==0 .or. !ExisteSX2("B0J")), {||ApMsgStop("Não localizado o campo BCI_LOTENF ou a tabela B0J. Verifique e aplique o pacote de atualização do processo!","Atenção"), lContinua:=.F.}, nil )

	if lContinua
		oBrwB0J := FWmBrowse():New()
		oBrwB0J:SetAlias( 'B0J' )
		oBrwB0J:SetDescription( 'Lote Fechamento Nota Fiscal' )
		oBrwB0J:SetMenuDef( "PLSLOTENF" )

		oBrwB0J:AddLegend( "B0J->B0J_STATUS == 'A'",	'BR_VERDE'   ,	 "Aberto"  )
		oBrwB0J:AddLegend( "B0J->B0J_STATUS == 'F'",	'BR_VERMELHO',	 "Fechado"  )

		oBrwB0J:Activate()
	endif

return


/*/{Protheus.doc} menuDef
menudef
@type function
@version 12.1.2310
@author claudiol
@since 7/10/2024
@return array, aRotina
/*/
static function menuDef()

	private aRotina := {}

	Add Option aRotina Title 'Processar'		    Action 'PLSLOTPRO()' 		Operation 3 Access 0 // Incluir
	Add Option aRotina Title 'Reprocessar'		    Action 'PLSLOTREP()' 		Operation 3 Access 0 // Incluir
	Add Option aRotina Title 'Visualizar'  			Action 'VIEWDEF.PLSLOTENF' 	Operation 2 Access 0 // Visualizar
	Add Option aRotina Title 'Excluir'				Action 'PLSLOTEXC()'		Operation 5 Access 0 // Excluir
	Add Option aRotina Title 'Banco de Conhecimento' Action 'MsDocument( "B0J", B0J->( recno() ), 2 )' Operation 7 Access 0 

return aRotina


/*/{Protheus.doc} ModelDef
definicao do modelo de dados

@type function
@version 12.1.23
@author claudiol
@since 7/10/2024
@return object, omodel
/*/
static function ModelDef()

	local oModel
	local oStrB0J:= FWFormStruct(1, 'B0J', )// cria as estruturas a serem usadas no modelo de dados
	local oStrBCI:= FWFormStruct(1, 'BCI', { |cCampo| ALLTRIM(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_TIPGUI,BCI_FASE,BCI_VLRGUI,BCI_VLRGLO,BCI_VLRAPR,BCI_QTDEVE,BCI_VALORI' })

	oModel := MPFormModel():New( 'PLSLOTENF' , , {||} , , {||} ) // cria o objeto do modelo de dados

	oModel:addFields('MasterB0J',/*cOwner*/, oStrB0J)  // adiciona ao modelo um componente de formulário
	oModel:AddGrid('BCIDetail', 'MasterB0J', oStrBCI) // adiciona ao modelo uma componente de grid

	oModel:SetRelation( 'BCIDetail', { ;
		{ 'BCI_FILIAL'	, 'xFilial("BCI")' },;
		{ 'BCI_LOTENF'	, 'B0J_LOTENF' 		};
		}, 	BCI->( IndexKey(18) ) )

	oModel:GetModel('MasterB0J'):SetDescription("Lote Fechamento de Nota Fiscal") // adiciona a descrição do modelo de dados

	oModel:SetPrimaryKey( {"B0J_FILIAL", "B0J_LOTENF"} )

return oModel // Retorna o modelo de dados


/*/{Protheus.doc} ViewDef
definição da interface
@type function
@version 12.1.2310
@author claudiol
@since 7/11/2024
@return object, oView
/*/
static function ViewDef()

	local oView  // interface de visualização construída
	local oModel := FWLoadModel( 'PLSLOTENF' ) // cria as estruturas a serem usadas na View
	local oStrB0J:= FWFormStruct(2, 'B0J', )
	local oStrBCI:= FWFormStruct(2, 'BCI', { |cCampo| ALLTRIM(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_TIPGUI,BCI_FASE,BCI_VLRGUI,BCI_VLRGLO,BCI_VLRAPR,BCI_QTDEVE,BCI_VALORI' })

	oView := FWFormView():New() // cria o objeto de View

	oView:SetModel(oModel)		// define qual Modelo de dados será utilizado

	oView:AddField('ViewB0J' , oStrB0J,'MasterB0J' ) // adiciona no nosso View um controle do tipo formulário
	oView:AddGrid( 'ViewBCI' , oStrBCI,'BCIDetail' ) // adiciona no nosso view um controle do tipo grid

	oStrB0J:SetNoGroups()

	oView:CreateHorizontalBox( 'CABECALHO', 30 ) // cria um "box" horizontal para receber os campos do cabeçalho
	oView:CreateHorizontalBox( 'INFERIOR' , 70 ) // cria um "box" horizontal para receber o grid de pegs

	oView:EnableTitleView( 'ViewB0J', 'Lote Fechamento de Nota Fiscal')

	oView:CreateFolder( 'PASTA','INFERIOR' )
	oView:AddSheet( 'PASTA', 'ABA01', 'Protocolos' )

	oView:CreateVerticalBox( 'BOXBCI', 100,,, 'PASTA', 'ABA01' )

	oView:SetViewProperty("ViewBCI","GRIDFILTER",{.T.}) // ativa o filtro no grid de procedimentos
	oView:SetViewProperty("ViewBCI","GRIDSEEK",{.T.})

	oView:SetOwnerView('ViewB0J','CABECALHO') // relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView('ViewBCI','BOXBCI') // relaciona o identificador (ID) da View com o "box" para exibição

return oView


/*/{Protheus.doc} PLSLOTPRO
processa protocolos faturados e liberados para pagamento
@type function
@version 12.1.2310
@author claudiol
@since 7/10/2024
/*/
function PLSLOTPRO()

	local nOpca		:= 0		// Flag de confirmacao para OK ou CANCELA
	local aSays	 	:= {} 		// Array com as mensagens explicativas da rotina
	local aButtons 	:= {}		// Array com as perguntas (parametros) da rotina
	local cCadastro	:= "Apura Protocolos Faturados e Lib. para Pagamento"
	local cMensLog 	:= ""
	local lPergOK	:= .F.

	Private oProcess

	//Tela de confirmação
	AADD(aSays, "Este programa tem como objetivo efetuar processo de apuração")
	AADD(aSays, "dos protocolos faturados e/ou liberados para  pagamento  que")
	AADD(aSays, "ainda não foi finalizado o lote de fechamento de nota fiscal.")

	aAdd( aButtons, { 5, .T., { || lPergOK := TelaPerg("PLSLOTPRO") } } )
	aAdd( aButtons, { 1, .T., { || IIf(!lPergOK , ;
									ApMsgAlert("Obrigatório Informar Parâmetros!"),;
									(nOpca:=1, FechaBatch()) )      } } )
	aAdd( aButtons, { 2, .T., { || FechaBatch()        } } )

	FormBatch( cCadastro, aSays, aButtons )

	If (nOpcA == 1)
		oProcess := MsNewProcess():New({|lEnd| ProcLote(@cMensLog,1) },OemToAnsi("Processando"),OemToAnsi("Processando dados. Aguarde..."),.F.)
		oProcess:Activate()
	endif

	If !Empty(cMensLog)
		ApMsgInfo(cMensLog,cCadastro)
	endif

return


/*/{Protheus.doc} PLSLOTREP
reprocessa o lote posicionado
@type function
@version 12.1.2310
@author claudiol
@since 7/10/2024
/*/
function PLSLOTREP()

	local nOpca		:= 0		// Flag de confirmacao para OK ou CANCELA
	local aSays	 	:= {} 		// Array com as mensagens explicativas da rotina
	local aButtons 	:= {}		// Array com as perguntas (parametros) da rotina
	local cCadastro	:= "Apura Protocolos Faturados e Lib. para Pagamento"
	local cMensLog 	:= ""

	Private oProcess

	if B0J->B0J_STATUS=='F'
		ApMsgStop("Não é possível reprocessar lote com anexo já recebido. Verifique!","Atenção")
		return
	endif

	AADD(aSays, "Este programa tem como objetivo efetuar reprocessamento do lote")
	AADD(aSays, "posicionado, efetuando a apuração dos protocolos faturados e/ou")
	AADD(aSays, "liberados para pagamento que ainda não foi finalizado,  isto  é ")
	AADD(aSays, "recebido o anexo da nota fiscal.")

	aAdd( aButtons, { 1, .T., { || (nOpca:=1, FechaBatch()) } } )
	aAdd( aButtons, { 2, .T., { || FechaBatch()        } } )

	FormBatch( cCadastro, aSays, aButtons )

	If (nOpcA == 1)
		MV_PAR01:= B0J->B0J_ANO
		MV_PAR02:= B0J->B0J_MES
		MV_PAR03:= B0J->B0J_CODRDA
		MV_PAR04:= B0J->B0J_CODRDA

		oProcess := MsNewProcess():New({|lEnd| ProcLote(@cMensLog,2) },OemToAnsi("Processando"),OemToAnsi("Processando dados. Aguarde..."),.F.)
		oProcess:Activate()
	endif

	If !Empty(cMensLog)
		ApMsgInfo(cMensLog,cCadastro)
	endif

return


/*/{Protheus.doc} PLSLOTEXC
exclui o lote posicionado
@type function
@version 12.1.2310
@author claudiol
@since 7/10/2024
/*/
function PLSLOTEXC()

	local nOpca		:= 0		// Flag de confirmacao para OK ou CANCELA
	local aSays	 	:= {} 		// Array com as mensagens explicativas da rotina
	local aButtons 	:= {}		// Array com as perguntas (parametros) da rotina
	local cCadastro	:= "Exclui Lote de Fechamento"
	local cMensLog 	:= ""
	local lContinua := .T.

	Private oProcess

	if B0J->B0J_STATUS=='F' .and. !ApMsgNoYes("Anexo já recebido. Confirma Exclusão mesmo assim?")
		lContinua:= .F.
	endif

	if lContinua
		//Tela de confirmação
		AADD(aSays, "Este programa tem como objetivo efetuar a exclusão do lote")
		AADD(aSays, "de fechamento de nota fiscal.")
		AADD(aSays, "Será excluído tambem todos os anexos recebidos.")

		aAdd( aButtons, { 1, .T., { || (nOpca:=1, FechaBatch()) } } )
		aAdd( aButtons, { 2, .T., { || FechaBatch()        } } )

		FormBatch( cCadastro, aSays, aButtons )

		If (nOpcA == 1)
			oProcess := MsNewProcess():New({|lEnd| ProcExc(@cMensLog) },OemToAnsi("Processando"),OemToAnsi("Processando dados. Aguarde..."),.F.)
			oProcess:Activate()
		endif

		If !Empty(cMensLog)
			ApMsgInfo(cMensLog,cCadastro)
		endif
	endif

return


/*/{Protheus.doc} ProcLote
processa dados
@type function
@version 12.1.23
@author claudiol
@since 7/12/2024
@param cMensLog, character, param_description
@param nProces, numeric, param_description
/*/
static Function ProcLote(cMensLog,nProces)

	local nTotReg   := 0
	local nCtdReg   := 0
	local nVlrApr   := 0
	local nVlrPag   := 0
	local nVlrGlo   := 0
	local cAliTmp   := ""
	local cCodRda	:= ""
	local cLoteNF 	:= ""
	local lRet      := .T.

	BeginTran()

		if nProces==2 //reprocessa
			oProcess:SetRegua1(3)
			oProcess:IncRegua1("Desmarca registros para atualizar...")

			LimpLote(B0J->B0J_LOTENF,B0J->B0J_ANO,B0J->B0J_MES,B0J->B0J_CODRDA)
		else
			oProcess:SetRegua1(2)
		endif

		oProcess:IncRegua1("Buscando Dados a Atualizar...")
		BuscDados(@cAliTmp)

		oProcess:IncRegua1("Atualizando dados...")

		(cAliTMP)->(DBEval({|| nTotReg++ } ) )
		oProcess:SetRegua2(nTotReg)

		If (nTotReg <> 0)

			(cAliTMP)->(dbGotop())
			While (cAliTMP)->(!Eof())

				nCtdReg++
				oProcess:IncRegua2("Processando: " + StrZero(nCtdReg,6) + " de "+StrZero(nTotReg,6))

				If (cAliTMP)->CODRDA <> cCodRda
					if nProces==1 //processa
						if (!empty((cAliTMP)->LOTENF))
							//posiciona no lote
							cLoteNF := (cAliTMP)->LOTENF
							if B0J->(msseek(xFilial("B0J")+cLoteNF))
								LimpLote(B0J->B0J_LOTENF,B0J->B0J_ANO,B0J->B0J_MES,B0J->B0J_CODRDA)
								Reclock("B0J",.F.)
								B0J->B0J_DATPRO := dDatabase
								B0J->B0J_STATUS := "A" //Aberto
								B0J->( MsUnlock() )
							endif
						else
							while .t.
								cLoteNF := B0J->(GetSXENum("B0J","B0J_LOTENF"))
								B0J->(ConfirmSX8())
								if !(B0J->(msseek(xFilial("B0J")+cLoteNF)))
									exit
								endif
							enddo

							Reclock("B0J",.T.)
							B0J->B0J_FILIAL := xFilial("B0J")
							B0J->B0J_LOTENF := cLoteNF
							B0J->B0J_CODRDA := (cAliTMP)->CODRDA
							B0J->B0J_ANO    := MV_PAR01
							B0J->B0J_MES    := MV_PAR02	
							B0J->B0J_DATPRO := dDatabase
							B0J->B0J_STATUS := "A" //Aberto
							B0J->( MsUnlock() )
						endif
					elseif nProces==2 //reprocessa
						cLoteNF := B0J->B0J_LOTENF
					endif

					cCodRda := (cAliTMP)->CODRDA
					nVlrApr := 0
					nVlrPag := 0
					nVlrGlo := 0
				endif

				nVlrApr += (cAliTMP)->VALORI //(cAliTMP)->VLRAPR + (cAliTMP)->VLTXAP
				nVlrGlo += (cAliTMP)->VLRGLO + (cAliTMP)->VLRGTX
				nVlrPag += (cAliTMP)->VLRPAG

				//atualiza PEG's (BuscDados)
				BCI->(dbgoto((cAliTMP)->BCIRECNO))
				reclock("BCI",.F.)
				BCI->BCI_LOTENF:= cLoteNF
				BCI->( MsUnlock() )

				(cAliTMP)->(dbSkip())

				if (cAliTMP)->CODRDA <> cCodRda
					Reclock("B0J",.F.)
					B0J->B0J_VLRAPR := nVlrApr
					B0J->B0J_VLRPAG := nVlrPag
					B0J->B0J_VLRGLO := nVlrGlo
					B0J->( MsUnlock() )
				endif

			EndDo

			cMensLog+= "Processamento Finalizado!"
		Else
			cMensLog+= "Não existe registros a processar!"
		endif

		(cAliTMP)->(dbCloseArea())

		iif(lRet, EndTran(), DisarmTransaction ())

	MsUnlockAll()

return


/*/{Protheus.doc} BuscDados
busca dados a processar
@type function
@version 12.1.23
@author claudiol
@since 7/12/2024
@param cAliTmp, character, alias dos dados
/*/
static Function BuscDados(cAliTmp)

	cAliTmp := GetNextAlias()

	beginSQL Alias cAliTmp

		SELECT BD6_FILIAL FILIAL, BD6_CODRDA CODRDA, BCI_LOTENF LOTENF, BD6_CODPEG CODPEG, BCI_FASE FASE, BCI.R_E_C_N_O_ BCIRECNO, 
			ROUND(SUM(BD6_VLRAPR),2) VLRAPR, 
			ROUND(SUM(BD6_VLTXAP),2) VLTXAP, 
			ROUND(SUM(BD6_VLRGLO),2) VLRGLO, 
			ROUND(SUM(BD6_VLRGTX),2) VLRGTX, 
			ROUND(SUM(BD6_VLRPAG),2) VLRPAG, 
			ROUND(SUM(BD6_VALORI),2) VALORI
		FROM %Table:BD6% BD6
		INNER JOIN %Table:BCI% BCI
			ON  BCI_FILIAL=BD6_FILIAL
			AND BCI_CODOPE=BD6_CODOPE
			AND BCI_CODLDP=BD6_CODLDP
			AND BCI_CODPEG=BD6_CODPEG
		INNER JOIN %Table:B0J% B0J
			ON  B0J_LOTENF = BCI_LOTENF
			AND B0J_CODRDA = BCI_CODRDA
			AND B0J_ANO    = BD6_ANOPAG
			AND B0J_MES    = BD6_MESPAG
			AND B0J_FILIAL = %XFILIAL:B0J%
			AND B0J.%NotDel%
		WHERE   BD6.%NotDel%
			AND BCI.%NotDel%
			AND BD6_FILIAL =  %XFILIAL:BD6%
			AND ISNULL(B0J_STATUS,' ') <> 'F'
			AND BD6_ANOPAG =  %Exp:MV_PAR01%
			AND BD6_MESPAG =  %Exp:MV_PAR02%
			AND BCI_CODRDA >= %Exp:MV_PAR03%
			AND BCI_CODRDA <= %Exp:MV_PAR04%
			AND (BCI_FASE = '4' OR BCI_STTISS = '3')
		GROUP BY BD6_FILIAL, BD6_CODRDA, BCI_LOTENF, BD6_CODPEG, BCI_FASE, BCI.R_E_C_N_O_

		UNION 

		SELECT BD6_FILIAL FILIAL, BD6_CODRDA CODRDA, BCI_LOTENF LOTENF, BD6_CODPEG CODPEG, BCI_FASE FASE, BCI.R_E_C_N_O_ BCIRECNO, 
			ROUND(SUM(BD6_VLRAPR),2) VLRAPR, 
			ROUND(SUM(BD6_VLTXAP),2) VLTXAP, 
			ROUND(SUM(BD6_VLRGLO),2) VLRGLO, 
			ROUND(SUM(BD6_VLRGTX),2) VLRGTX, 
			ROUND(SUM(BD6_VLRPAG),2) VLRPAG, 
			ROUND(SUM(BD6_VALORI),2) VALORI
		FROM %Table:BD6% BD6
		INNER JOIN %Table:BCI% BCI
			ON  BCI_FILIAL=BD6_FILIAL
			AND BCI_CODOPE=BD6_CODOPE
			AND BCI_CODLDP=BD6_CODLDP
			AND BCI_CODPEG=BD6_CODPEG
		WHERE   BD6.%NotDel%
			AND BCI.%NotDel%
			AND BD6_FILIAL =  %XFILIAL:BD6%
			AND BD6_ANOPAG =  %Exp:MV_PAR01%
			AND BD6_MESPAG =  %Exp:MV_PAR02%
			AND BCI_CODRDA >= %Exp:MV_PAR03%
			AND BCI_CODRDA <= %Exp:MV_PAR04%
			AND (BCI_FASE = '4' OR BCI_STTISS = '3')
			AND BCI_LOTENF = ' '
		GROUP BY BD6_FILIAL, BD6_CODRDA, BCI_LOTENF, BD6_CODPEG, BCI_FASE, BCI.R_E_C_N_O_

		ORDER BY FILIAL, CODRDA, LOTENF desc, CODPEG, FASE, BCIRECNO
	endSQL

return


/*/{Protheus.doc} ProcExc
efetua exclusao do lote, anexo e desmarca protocolos
@type function
@version 12.1.23
@author claudiol
@since 7/12/2024
@param cMensLog, character, param_description
/*/
static Function ProcExc(cMensLog)

	local cLoteNF	:= B0J->B0J_LOTENF
	local cAnoLote	:= B0J->B0J_ANO
	local cMesLote	:= B0J->B0J_MES
	local cSeek		:= ""
	local lRet		:= .T.

	oProcess:SetRegua1(1)
	oProcess:IncRegua1("Excluindo lote " + cLoteNF)

	oProcess:SetRegua2(1)
	oProcess:IncRegua2("Processando ... ")

	BeginTran()

		//atualiza PEG
		cSql := " UPDATE " + RetSqlName("BCI") + " SET "
		cSql += " BCI_LOTENF=' ' "
		cSql += " WHERE "
		cSql += " BCI_FILIAL = '" + xFilial("BCI") + "' AND "
		cSql += " BCI_LOTENF = '" + cLoteNF + "' AND "
		cSql += " BCI_ANO = '" + cAnoLote + "' AND "
		cSql += " BCI_MES = '" + cMesLote + "' AND "
		cSql += " D_E_L_E_T_ = ' '  "

		iif(TCSQLExec(cSql) < 0,FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {}),"")

		iif(allTrim( TCGetDB() ) == "ORACLE",TCSQLExec("COMMIT"),"")

		//exclui anexos
		AC9->(dbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
		while AC9->(msseek(cSeek:= xFilial("AC9")+"B0J"+xFilial("B0J")+xFilial("B0J")+cLoteNF))
			if alltrim(cSeek)==alltrim(AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT))
				ACB->(dbSetOrder(1)) //ACB_FILIAL+ACB_CODOBJ
				ACB->(msseek(xFilial("ACB")+AC9->AC9_CODOBJ))
				if ACB->(!Eof())
					ACB->(RecLock( "ACB", .F. ))
					ACB->(DbDelete())
					ACB->( MsUnlock() )
				endif

				AC9->(RecLock( "AC9", .F. ))
				AC9->(DbDelete())
				AC9->( MsUnlock() )
			endif
		enddo

		//exclui lote
		Reclock("B0J",.F.)
		B0J->(dbDelete())
		B0J->( MsUnlock() )

		iif(lRet, EndTran(), DisarmTransaction ())

	MsUnlockAll()

	If lRet
		cMensLog+= "Processamento Finalizado!"
	endif

return


/*/{Protheus.doc} TelaPerg
Perguntas da rotina
@type function
@author claudiol
@since 7/10/2024
@version 12.1.2310
@param cNomRot, characters, descricao
@return logical, lret
/*/
static Function TelaPerg(cNomRot)

	local aParambox	:= {}
	local aRet 		:= {}
	local lRet		:= .T.
	local nX		:= 0

	Private lWhen	:= .T.

	aAdd( aParambox ,{1,"Ano de Competência: "   	, Space(04),"9999",".T.",,"lWhen",20,.T.})	  //01
	aAdd( aParambox ,{1,"Mês de Competência: : "	, Space(02),"99",".T.",,"lWhen",20,.T.})      //02
	aAdd( aParambox ,{1,"RDA De: "		            , Space(06),"@!",".T.",,"lWhen",100,.F.})	  //03
	aAdd( aParambox ,{1,"RDA Até: "		            , "ZZZZZZ","@!",".T.",,"lWhen",100,.T.})	  //04

	//Carrega o array com os valores utilizados na última tela ou valores default de cada campo.
	For nX := 1 To Len(aParamBox)
		aParamBox[nX][3] := ParamLoad(cNomRot,aParamBox,nX,aParamBox[nX][3])
	Next nX

	lRet := ParamBox(aParamBox,"Parâmetros",aRet,{|| .T.},{},.T.,Nil,Nil,Nil,cNomRot,.F.,.F.)

	If lRet
		//Carrega perguntas em variaveis usadas no programa
		If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
			For nX := 1 to Len(aParamBox)
				&("Mv_Par"+StrZero(nX,2)) := aRet[nX]
			Next nX
		endif

		//Salva parametros
		ParamSave(cNomRot,aParamBox,"1")
	endif

return(lRet)


/*/{Protheus.doc} LimpLote
Limpa dados do lote gerado
@type function
@version 12.1.23
@author claudiol
@since 7/15/2024
@param cLote, character, Lote
@param cAno, character, Ano
@param cMes, character, Mes
@param cCodRda, character, codrda
/*/
static Function LimpLote(cLote,cAno,cMes,cCodRda)

	local cSql:= ""

	//desmarca protocolos
	cSql := " UPDATE " + RetSqlName("BCI") + " SET "
	cSql += " BCI_LOTENF=' ' "
	cSql += " WHERE "
	cSql += " BCI_FILIAL = '" + xFilial("BCI") + "' AND "
	cSql += " BCI_LOTENF = '" + cLote + "' AND "
	cSql += " BCI_ANO = '" + cAno + "' AND "
	cSql += " BCI_MES = '" + cMes + "' AND "
	cSql += " BCI_CODRDA = '" + cCodRda + "' AND "
	cSql += " D_E_L_E_T_ = ' '  "

	iif(TCSQLExec(cSql) < 0,FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {}),"")

	iif(allTrim( TCGetDB() ) == "ORACLE",TCSQLExec("COMMIT"),"")

	//zera totalizadores
	Reclock("B0J",.F.)
	B0J->B0J_VLRAPR := 0
	B0J->B0J_VLRPAG := 0
	B0J->B0J_VLRGLO := 0
	B0J->( MsUnlock() )

return
