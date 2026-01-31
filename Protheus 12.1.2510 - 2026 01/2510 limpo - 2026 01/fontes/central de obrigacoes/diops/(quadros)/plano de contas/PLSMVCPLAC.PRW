#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

#DEFINE COD_CONTA  	1
#DEFINE DES_CONTA  	2
#DEFINE VIG_INI  		3
#DEFINE VIG_FIN  		4

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCPLAC
//PLPLACON
Manutencao de balancete

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCPLAC()

	Local oBrowse	:= Nil
	Local cCodOpe := B3D->B3D_CODOPE
	Local cFiltro := "B8B_CODOPE = '" + cCodOpe + "'"

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8B')
	oBrowse:SetDescription("Plano de Contas da ANS") //Plano de Contas
	oBrowse:SetMenuDef( 'PLSMVCPLAC' )
	oBrowse:SetFilterDefault(cFiltro)

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Plano de Contas", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !Isblind()
		oBrowse:Activate()
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}
	// Definido que não haverá inclusão/alteração/exclusão nesse cadastro, uma vez que trata-se da importação de uma tabela de domínio da ANS
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCPLAC'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCPLAC'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCPLAC'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCPLAC'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Importar"				, 'PLCARPLCO()'			, 0 , 3 , 0 , NIL } ) //Importar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8B

@return oModel	objeto model criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB8B 	:= FWFormStruct( 1, 'B8B', , )
	Local oModel		:= MPFormModel():New( "Plano de Contas ANS", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8BMASTER', NIL, oStruB8B )
	oModel:GetModel( 'B8BMASTER' ):SetDescription( "Plano de Contas ANS" )
	oModel:SetDescription( "Plano de Contas ANS" )
	oModel:SetPrimaryKey({})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8B

@return oView	objeto view criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'PLSMVCPLAC' )
	Local oStruB8B := FWFormStruct( 2, 'B8B' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8B' , oStruB8B, 'B8BMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8B', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8B', "Plano de Contas ANS" )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCARPLCO

Rotina para leitura e importação do arquivo de plano de contas da ANS.

@author TOTVS PLS Team
@since 08/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCARPLCO(cArquivo,dDataVig,cCodOpe,oHelper,lManual)

	Local nOpc		:= 0
	Local cDesc1	:= 'Processamento do arquivo de Contas Contábeis da ANS '
	Local lOk		:= .T.
	Local aErro 	:= {}
	Local aPergs	:= {}
	Local aRet		:= {}
	Local nExistReg	:= 0
	Default cArquivo:= ''
	Default dDataVig:= CtoD('')
	Default cCodOpe	:= '417505'
	Default oHelper	:= ''
	Default lManual	:= .T.

	Private cCadastro	:= cDesc1

	aadd(aPergs,{ 6,"Arquivo a Importar","",,'.T.','.T.',85,.T.,"Arquivos .CSV |*.CSV" } )
	aadd(aPergs,{ 1,"Data Início Vigência",dDataBase,"99/99/9999",'.T.',,,60,.T. } )

	If !Empty(cArquivo) .and. File(cArquivo)
		lManual	:= .F.
		aAdd(aRet, cArquivo)
		aAdd(aRet, dDataVig)

	ElseIf (lManual .AND.  !ParamBox( aPergs, "Parâmetros", aRet ) ) .or. Empty(aRet[1]) .or. !File(aRet[1])
		If lManual
			MsgInfo("Para confirmar o processamento selecione um arquivo.","TOTVS")
		EndIf
		Return .F.
	EndIf

	If lManual

		// Valida se a data de vigência parametrizada pode ser processada
		cQuery	:= "SELECT SUM(1) AS EXISTREG "
		cQuery	+= "FROM "+RetSqlName('B8B')+" "
		cQuery	+= "WHERE B8B_FILIAL = '"+xFilial('B8B')+"' "
		cQuery	+= "AND B8B_CODOPE = '"+B3D->B3D_CODOPE+"' "
		cQuery	+= "AND B8B_VIGINI >= '"+DtoS(aRet[2])+"' "
		cQuery	+= "AND ( B8B_VIGFIN <= '"+DtoS(aRet[2]-1)+"' "
		cQuery	+= "OR B8B_VIGFIN = ' ' ) "
		cQuery	+= "AND D_E_L_E_T_ = ' ' "

		If Select('TRBPLA') > 0
			TRBPLA->(dbCloseArea())
		EndIf
		MPSysOpenQuery( changeQuery(cQuery), 'TRBPLA' )
		tcSetField('TRBPLA' ,'EXISTREG','N',16,0)
		nExistReg	:= TRBPLA->EXISTREG
		TRBPLA->(dbCloseArea())

	EndIf

	If nExistReg > 0
		If lManual
			MsgInfo("Já existe registro dentro da vigência parametrizada.","Verifique")
		Else
			Return(.F.)
		EndIf
	Else
		If lManual
			Processa( { || lOk := PLImPlaCsv(lManual, aRet[1], aRet[2], aErro) },'Aguarde','Processando...',.F.)
		Else
			lOk := PLImPlaCsv(lManual, aRet[1], aRet[2], aErro, cCodOpe)
		EndIf
		DelClassIntf()
	EndIf

Return(lOk)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLImPlaCsv

Funcao criada para importar o arquivo CSV do Plano de Contas ANS

@author everton.mateus
@since 30/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLImPlaCsv(lManual, cArq, dVigIni, aErro, cCodOpe)

	Local cLinha	:= ""
	Local cConta    := ""
	Local nI		:= 0
	Local aDados	:= {}
	Local oModel 	:= FWLoadModel('PLSMVCPLAC')
	Local cQuery	:= ''
	DEFAULT lManual	:= .T.
	DEFAULT cArq	:= ""
	DEFAULT aErro	:= {}
	DEFAULT dVigIni	:= dDataBase
	DEFAULT cCodOpe	:= B3D->B3D_CODOPE


	FT_FUSE(cArq)
	If lManual
		ProcRegua(FT_FLASTREC())
	EndIf

	FT_FGOTOP()
	While !FT_FEOF()
		If lManual
			IncProc("Lendo arquivo texto...")
		EndIf

		cLinha := FT_FREADLN()

		AADD(aDados,Separa(cLinha,";",.T.))

		FT_FSKIP()
	EndDo

	Begin Transaction
		cQuery := "UPDATE " + RetSqlname('B8B') + " SET B8B_VIGFIN = '"+DtoS(dVigIni-1)+"' WHERE B8B_FILIAL ='"+xFilial('B8B')+"' AND B8B_CODOPE = '"+cCodOpe
		cQuery += "' AND B8B_VIGFIN = '' AND D_E_L_E_T_ = ' '  "
		TCSQLEXEC(cQuery)

		If lManual
			ProcRegua(Len(aDados))
		EndIf

		B8B->(DbSetOrder(1))	//B8B_FILIAL+B8B_CODOPER+B8B_CONTA+DTOS(B8B_VIGINI)+DTOS(B8B_VIGFIN)

		nLen := Len(aDados)
		If nLen > 0

			For nI :=1 to Len(aDados)

				If lManual
					IncProc("Importando Plano de Contas ANS...")
				EndIf
				If Len(aDados[nI]) > 0 .AND. !Empty(aDados[nI,COD_CONTA])
					cConta  	:= Alltrim(aDados[nI,COD_CONTA])
					cDescri		:= Alltrim(aDados[nI,DES_CONTA])
					dVigFin 	:= CtoD('')
					lExist := B8B->(MsSeek(xFilial("B8B")+PadR( cConta, tamSX3("B8B_CONTA")[1])+DtoS(dVigIni)))

					If lExist
						nOpc := MODEL_OPERATION_UPDATE
					Else
						nOpc := MODEL_OPERATION_INSERT
					EndIf

					oModel:SetOperation( nOpc )

					oModel:Activate()

					oModel:SetValue( 'B8BMASTER',	'B8B_FILIAL',	xFilial("B8B"))
					oModel:SetValue( 'B8BMASTER',	'B8B_CODOPE',	cCodOpe)
					oModel:SetValue( 'B8BMASTER',	'B8B_CONTA' ,	cConta)
					oModel:SetValue( 'B8BMASTER',	'B8B_DESCRI',	cDescri)
					oModel:SetValue( 'B8BMASTER',	'B8B_VIGINI',	dVigIni)
					oModel:SetValue( 'B8BMASTER',	'B8B_VIGFIN',	dVigFin)

					If oModel:VldData()
						oModel:CommitData()
					Else
						aErro := oModel:GetErrorMessage()
						DisarmTransaction()
						Exit
					EndIf

					oModel:DeActivate()
				EndIf

			Next nI

		EndIf
	End Transaction

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

	FT_FUSE()
	If lManual
		ApMsgInfo("Importação do Plano de Contas ANS foi concluída com sucesso!","SUCESSO")
	Else
		ConOut("Importação do Plano de Contas ANS foi concluída com sucesso!")
	EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8BDescri

Retorna a descricao da conta para campo virtual

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function B8BDescri()
	Local cDescri	:= ""
	cDescri := POSICIONE('B8B',1,XFILIAL('B8B')+B8A->(B8A_CODOPE+B8A_CONTA),'B8B_DESCRI')

Return cDescri


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVALVIGPL
Verifica se a data informada está de acordo com as vigências.

@author Jose Paulo
@since 14/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVALVIGPL(dData,cConta,cOpe)
	local lRet		:= .t.
	local aArea 		:= B8B->(getArea())
	local nRecB8B		:= iif(inclui,0,B8B->(recno()))
	local cQuery        := ""

	default dData   	:= ""
	default cConta	:= ""
	default cOpe    := ""

	if empty(cConta)
		lRet := .f.
		Help( ,, 'HELP',,"Conta não informada", 1, 0,NIL,NIL,NIL,NIL,NIL,{"Informe o número da conta"})
	endIf

	if lRet .and. cOpe == "I" .and. !empty(dData) .and. !empty(M->B8B_VIGFIN) .and. dData > M->B8B_VIGFIN
		lRet := .f.
		Help( ,, 'HELP',,"A data da Vigência Início informada é superior a data da Vigência Fim.", 1,0,NIL,NIL,NIL,NIL,NIL,{"A Data de Vigência Inicial deve ser inferior a Data Final"})

	elseIf lRet .and. cOpe == "F" .and. !empty(M->B8B_VIGINI) .and. !empty(dData) .and. dData < M->B8B_VIGINI
		lRet := .f.
		Help( ,, 'HELP',,"A data da Vigência Fim informada é inferior a data da Vigência Início.", 1, 0,NIL,NIL,NIL,NIL,NIL,{"A Data de Vigência Final deve ser Maior que a Data Início"})
	elseIf lRet .and. cOpe == "F" .and. empty(M->B8B_VIGINI) .and. !empty(dData)
		lRet := .f.
		Help( ,, 'HELP',,"Informe a data de Vigência Inicial.", 1, 0,NIL,NIL,NIL,NIL,NIL,{"O campo Data Inicial deve ser informado primeiro."})
	endIf
	If lRet

		cQuery	:= "SELECT B8B_VIGINI AS VIGINI, B8B_VIGFIN AS VIGFIN, R_E_C_N_O_  AS RECNO"
		cQuery	+= "FROM "+RetSqlName('B8B')+" "
		cQuery	+= "WHERE B8B_FILIAL = '"+xFilial('B8B')+"' "
		cQuery	+= "AND B8B_CODOPE = '"+B3D->B3D_CODOPE+"' "
		cQuery	+= "AND B8B_CONTA = '"+ cConta +"' "
		If cOpe == "I"
			cQuery	+= "AND (B8B_VIGINI <= '"+DtoS(dData)+"' AND  (B8B_VIGFIN >='"+DtoS(dData)+"'  OR B8B_VIGFIN = ' ' )) "
		Else
			cQuery	+= "AND (B8B_VIGFIN >= '"+DtoS(dData)+"' OR B8B_VIGFIN = ' ')"

		EndIf
		cQuery	+= "AND D_E_L_E_T_ = ' ' "

		MPSysOpenQuery( changeQuery(cQuery), 'TRBVPL' )

		WHILE !TRBVPL->(Eof())

			If Empty(TRBVPL->VIGFIN) .And. nRecB8B == 0
				lRet := .f.
				Help( ,, 'HELP',,"Conta já cadastrada com a Vigência não finalizada.", 1, 0,NIL,NIL,NIL,NIL,NIL,{"Finalizar a Vigência da conta já cadastrada."})

			Else
				If TRBVPL->VIGINI <= DtoS(dData) .And. TRBVPL->VIGFIN >= DtoS(dData)  .And. nRecB8B == 0
					lRet := .f.
					Help( ,, 'HELP',,"Conta já cadastrada dentro desta vigência.", 1, 0,NIL,NIL,NIL,NIL,NIL,{"Ajustar a Vigência."})

				EndIf

				If cOpe == "F" .And. TRBVPL->VIGFIN >= DtoS(dData) .And. nRecB8B <> TRBVPL->RECNO
					lRet := .f.
					Help( ,, 'HELP',,"Conta já cadastrada dentro desta vigência.", 1, 0,NIL,NIL,NIL,NIL,NIL,{"Ajustar a Vigência."})

				EndIf
			EndIf
			TRBVPL->(DbSkip())
		EndDo
		if( select( "TRBVPL" ) > 0 )
			TRBVPL->( dbCloseArea() )
		endIf

	EndIf

Return (lRet)
