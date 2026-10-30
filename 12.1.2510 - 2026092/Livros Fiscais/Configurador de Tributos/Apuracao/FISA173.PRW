#Include "FISA173.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA173 SOURCE FISA173

STATIC cLpApur		:= "767"
STATIC cLpExApur	:= "768"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA173()

Função de apuração dos tributos genéricos

@author Erick G Dias
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA173()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2H")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2H")
    oBrowse:SetDescription(STR0001) //"Apuração dos Tributos Genéricos"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal. //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'FSA173PROC()'   OPERATION 3 ACCESS 0 //"Processar"
ADD OPTION aRotina TITLE STR0004 ACTION 'FSA173VIS()'    OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION 'FSA173EDIT()'   OPERATION 4 ACCESS 0 //"Editar"
ADD OPTION aRotina TITLE STR0006 ACTION 'FSA173EXCL()'   OPERATION 5 ACCESS 0 //"Excluir"

// Se a função de geração de títulos do financeiro não existir não adiciono os botões.
If FindFunction("FGrvImpFi")
	ADD OPTION aRotina TITLE STR0007 ACTION 'FSA173TIT("1")' OPERATION 4 ACCESS 0 //"Gerar Título Financeiro e Guia de Recolhimento"
	ADD OPTION aRotina TITLE STR0008 ACTION 'FSA173TIT("2")' OPERATION 4 ACCESS 0 //"Gerar Título Financeiro/Contabilização e Guia de Recolhimento"
	ADD OPTION aRotina TITLE STR0037 ACTION 'FSA173TIT("3")' OPERATION 4 ACCESS 0 //"Contabilizar Título Gerado"	
	ADD OPTION aRotina TITLE STR0009 ACTION 'FSA173VTIT()'   OPERATION 4 ACCESS 0 //"Visualizar Título Gerado"
EndIf

If FindFunction("FISR161")
	ADD OPTION aRotina TITLE STR0041 ACTION 'FISR161()' OPERATION 4 ACCESS 0 //"Relatório de Conferência de Apuração"
EndIf

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F2H" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA173')

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA173",,oCabecalho)

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //"Apuração dos Tributos Genéricos"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA173" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2H")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA173' )
oView:CreateHorizontalBox( "CABEC" , 100 )
oView:SetOwnerView( "VIEW_CABECALHO" , "CABEC" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173PROC
Função que iniciará o processamento da apuração

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173PROC()

Local aParam    := FISA175WIZ()
Local aFil      := {}
Local aReproc	:= {}
Local aAreaSM0 	:= SM0->(GetArea())
Local nCont		:= 0
Local nRecnoTit	:= 0
Local cTitOk	:= ""
Local cTitNotOk	:= ""
Local cNumTit	:= ""
Local cAlsTit	:= ""
Local lProc		:= .T.
Local oSay	 	:= nil

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

If Len(aParam) > 0   

	aReproc	:= ChkApur(aParam) 

	IF aReproc[1]
		
		//Já existem apurações processadas neste período, questionará o usuário se deseja prosseguir com apuração.
		lProc	:= .F.
		lProc	:= ApMsgYesNo(aReproc[2] + CHR(13)+CHR(10)  + STR0010) //'Deseja prosseguir com o reprocessamento?'

		IF lProc

			//Laço para verificar a questão dos títulos  tributo a tributo 
			For nCont:=1  to len(aReproc[3])

				If !Empty(aReproc[3][nCont][1]) .And. F2L->(MsSeek(xFilial("F2L") + aReproc[3][nCont][1]))
					//Se entrou aqui possui título, precisa verificar então se tem baixas
					//Verifica se os títulos podem ser excluídos
					IF !Empty(F2L->F2L_CHVFK7)						
						//Guarda a chave FK7
						aReproc[3][nCont][2]	:= F2L->F2L_CHVFK7
						//Verifica se pode excluir o título
						IF DelTit(F2L->F2L_CHVFK7, "1", "FISA173", @cNumTit)
							//Montar lista de títulos por tributo que podem ser excluídos
							cTitOk += cNumTit + CHR(13) + CHR(10)							
						Else
							//Montar lista de títulos por tributo que NÂO podem ser excluídos							
							cTitNotOk += cNumTit + CHR(13) + CHR(10)							
						EndIF
					EndIF
				EndIF
			
			Next nCont

			//Se existem títulos na lista cTitNotOk, significa que estes títulos possuem baixa e o reprocessamento não poderá prosseguir
			If !Empty(cTitNotOk)
				MsgAlert(STR0011 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cTitNotOk ) //"Foram identificados títulos que possuem baixa, por este motivo o reprocessamento será interrompido."
				lProc	:= .F.
			ElseIF !EMpty(cTitOk)
				lProc	:= ApMsgYesNo(STR0012 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cTitOk  ) //"Confirma a exclusão dos títulos abaixo?"
			EndIF

			IF lProc
				dbSelectArea("F2H")
				F2H->(dbSetOrder(3)) //F2H_FILIAL+F2H_ID
				
				For nCont:=1  to len(aReproc[3])
					//Deleta os títulos
					IF !Empty(aReproc[3][nCont][2])
						
						//Reverte a x173Contabação, caso tenha sido x173Contabado previamente.//Preciso posicionar a F2H também
						IF aReproc[3][nCont][3] == "5" .AND. x173PosTit(aReproc[3][nCont][2], @cAlsTit, @nRecnoTit) .AND. F2H->(MsSeek(xFilial("F2H") + aReproc[3][nCont][1]))
							x173Contab(cLpExApur, cAlsTit, nRecnoTit)
						EndIF
						
						//Deleta o título
						DelTit(aReproc[3][nCont][2], "2", "FISA173")

					EndIF				
					
					//Deleta a apuração
					DelApur(aReproc[3][nCont][1])
				Next nCont
			EndIF
			dbSelectArea("F2H")
			F2H->(dbSetOrder(1))

		EndIF

	EndIF
	
	IF lProc
		aFil    := x173GetFil( aParam[3] == '1' )

		IF Len(aFil) > 0

			FwMsgRun(,{|oSay| x175Processa(aFil, aParam) },STR0013,"") //"Processando Apuração dos Tributos Genéricos"

			RestArea (aAreaSM0)
			cFilAnt := FWGETCODFILIAL

			
			//Exibe mensagem de sucesso
			MsgInfo(STR0014) //"Apuração Concluída com Sucesso !"

			//Se o usuário selecionou somente 1 tributo, abriremos a tela
			If Len( StrToKArr(aParam[4], "|") ) == 1
				FSA173EDIT()
			EndIF

		EndIF

	EndIF

EndIF

//Desabilita o loop de inclusão
MbrChgLoop(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173VIS
Função que faz a visualização da apuração.

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173VIS()

If !Empty(F2H->F2H_ID)
	FISA174('1', STR0017 + F2H->F2H_TRIB + STR0018 + DTOC(F2H->F2H_DTINI) + STR0016 +  DTOC(F2H->F2H_DTFIN) + STR0015, F2H->F2H_ID) //' (Visualizando)' //' - Período Final: ' //'Tributo: ' //' - Período Inicial: '
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173EDIT
FUnção responsável por fazer edição na apuração

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173EDIT()

BEGIN TRANSACTION

If !Empty(F2H->F2H_ID)
	
	IF F2H->F2H_STATUS $ "5/2"
		MSGALERT(STR0019) //"Não é permitida edição de apuração que já possui título gerado!"
		
	ElseIF FISA174('2', STR0017 + F2H->F2H_TRIB + STR0018 + DTOC(F2H->F2H_DTINI) + STR0016 +  DTOC(F2H->F2H_DTFIN) + STR0020, F2H->F2H_ID) == 1 //' (Editando)' //' - Período Final: ' //'Tributo: ' //' - Período Inicial: '
		//Clicou no OK, pode confirmar as alterações...caso contrário deverá fazer rollback
		DisarmTransaction()
	Else
		//Chama função para atualizar o Status da Apuração
		x175AtuSts(F2H->F2H_ID)
	EndIF

EndIF

END TRANSACTION

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173EXCL
Função responsável por fazer a exclusão da apuração

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173EXCL()

Local cNumTit	:= ""
Local cChaveFk7	:= ""
Local cAlsTit	:= ""
Local lProc		:= .T.
Local nRecnoTit	:= 0

BEGIN TRANSACTION	

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

If  ApMsgYesNo( STR0021 ) //"Deseja realmente excluir apuração?"

	If !Empty(F2H->F2H_ID) .And. F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID))
		//Se entrou aqui possui título, precisa verificar então se tem baixas
		//Verifica se os títulos podem ser excluídos		
		IF !Empty(F2L->F2L_CHVFK7)
			cChaveFk7	:= F2L->F2L_CHVFK7

			//Verifica se pode excluir o título
			IF DelTit(cChaveFk7, "1", "FISA173", @cNumTit)
				//Aqui significa que o título pode ser excluído, perguntar se o cliente confirmar exclusão do título
				If ApMsgYesNo( STR0022 + cNumTit + STR0024 + CHR(13)+CHR(10) + CHR(13)+CHR(10) + STR0023) //"Existe o título financeiro " //"Deseja prosseguir excluíndo este título?" //" gravado para esta apuração. "
					//Aqui pode excluir o título
					lProc	:= .T.
				Else
					lProc	:= .F.
				EndIF
			Else
				//Título não pode ser cancelado, pois possui baixa, exibir mensagerm de que título não pode ser deletado.
				MsgAlert(STR0026 + cNumTit + STR0025) //" já possui baixa e não poderá ser excluído!" //"Título "
				lProc	:= .F.
			EndIF
		EndIF
	EndIF

	IF lProc						
		//Reverte a x173Contabação caso tenha sido x173Contabado anteriormente.
		If F2H->F2H_STATUS == "5" .AND. x173PosTit(cChaveFk7, @cAlsTit, @nRecnoTit)
			x173Contab(cLpExApur, cAlsTit, nRecnoTit)
		EndIF

		//Chama função para excluir o título
		If !(Empty(cChaveFk7))
			DelTit(cChaveFk7, "2", "FISA173")
		EndIf
		DelApur(F2H->F2H_ID)
		MsgInfo( STR0027) //"Apuração excluída com sucesso!"
	EndIF

EndIF

END TRANSACTION

Return

//------------------------------------------------------------
/*/{Protheus.doc} FSA173TIT

Função que fará a geração do título financeiro 

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function FSA173TIT(cOpcao, lAutomato)

Local cRegraFin		:= ""
Local cAlsTit		:= ""
Local cRegraGNRE	:= ""
Local cNumTitulo	:= ""
Local nValTit		:= 0
Local nRecnoTit		:= 0
Local aTitulo		:= {}
Local lContabOK		:= .F.

DEFAULT lAutomato := .F.

dbSelectArea("F2N")
F2N->(dbSetOrder(1)) //F2N_FILIAL+F2N_TRIB
dbSelectArea("F2K")
F2K->(dbSetOrder(1)) //F2K_FILIAL + F2K_IDAPUR
dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

IF F2H->F2H_STATUS == "5" .AND. cOpcao $ "1/2" //Título Já foi gerado e contabilizado	
	MsgAlert(STR0038) //"Título já foi gerado e Contabilizado"

ElseIF F2H->F2H_STATUS == "3" .AND. cOpcao $ "1/2" //Saldo Credor
	//Exibe mensagem de sucesso
	MsgAlert(STR0030) //"Título não será gerado pois apuração não possui saldo devedor!"

ElseIF F2H->F2H_STATUS == "4" .AND. cOpcao $ "1/2" //Sem saldos
	//Exibe mensagem de sucesso
	MsgAlert(STR0030) //"Título não será gerado pois apuração não possui saldo devedor!"

ElseIF F2H->F2H_STATUS == "2" .AND. cOpcao $ "1/2" //Título já gerado
	//Título já foi gerado
	MsgAlert(STR0029)		 //"Título desta apuração já foi gerado!"
	
ElseIF F2H->F2H_STATUS == "1" .AND. cOpcao $ "1/2"  //Aqui o título será gerado	
	//Posicionar tabela F2G para buscar regra financeira 	
	If !Empty(F2H->F2H_TRIB) .And. F2N->(MsSeek(xFilial("F2N") + F2H->F2H_TRIB))
		cRegraFin	:= F2N->F2N_RTIT
	EndIf

	//Pega regra de GNRE
	If F2N->(FieldPos("F2N_RGGUIA"))>0
		cRegraGNRE	:= F2N->F2N_RGGUIA
	EndIF
	
	//Posiciona na F2K para obter o valor do saldo devedor, que será considerado para gravação do título
	If !Empty(F2H->F2H_TRIB) .And. F2K->(MsSeek(xFilial("F2K") + F2H->F2H_ID))
		nValTit	:= 	F2K->F2K_SLDDEV
	EndIF

	IF Empty(cRegraFin) 
		//NãoTributo não possui regra de Título x Apuração
		MsgAlert(STR0028) //"Este título não possui uma Regra de Título da Apuração Cadastrada!"	
	
	ElseIf FindFunction("FinFKKVig") .AND. !FinFKKVig(cRegraFin, dDataBase)
		MsgAlert(STR0042 + cRegraFin + STR0043 )//"Verifique a regra financeira " + cRegraFin + ", ela não está vigente ou ativa. Por este motivo o título não será gerado "" 
		cRegraFin	:= ""
	EndIF

ElseIf cOpcao == "3" .AND. F2H->F2H_STATUS <> "2"	
	MsgAlert(STR0035) //"Esta apuração ainda não gerou título!"

//Para as opções 1 e 2 é necessário ter a regra financeira prenchida 
ElseIF cOpcao $ "1/2" .AND. Empty(cRegraFin) 
	//NãoTributo não possui regra de Título x Apuração
	MsgAlert(STR0031) //"Este título não possui uma Regra de Título da Apuração Cadastrada"

EndIF

BEGIN TRANSACTION 

//Se a regra financeira estiver preenchida, então gerarei o título
If !Empty(cRegraFin) .AND. nValTit > 0	
	cNumTitulo	:= xFisTitTG()
	aAdd(aTitulo, {cRegraFin,; // Código da Regra FKK
	               nValTit,; // Valor do tributo
				   cNumTitulo,; // Número do título a ser gerado
				   '',; // ID FK7 do título gerado
				   '',;
				   AllTrim(F2H->F2H_TRIB) + " - DE " + DtoC(F2H->F2H_DTINI)  + " A " + DtoC(F2H->F2H_DTFIN)}) 
	
	//Chama função do Financeiro para geração do título
	FGrvImpFi(@aTitulo, "FISA173", dDatabase)

	//Aqui deverá verificar se possí regra de GNRE para gerar via apuração.
	IF !Empty(cRegraGNRE) .And. CJ4->(MsSeek(xFilial("CJ4") + cRegraGNRE )) .AND. CJ4->CJ4_MODO == "2"
		
		//Gerar a GNRE aqui		
		GravaGNRE(cNumTitulo, nValTit, F2H->F2H_TRIB, F2H->F2H_ID)

	EndIF

	IF !Empty(aTitulo[1][4])

		//Gravação da tabela F2L, que tem o vínculo da apuração com a F2L.	
		x173PrcF2L("1", F2H->F2H_ID, aTitulo[1][4], cRegraFin)		

		//Faz x173Contabação. Posiciona o título através da x173PosTit
		If cOpcao == "2" .AND. x173PosTit(aTitulo[1][4], @cAlsTit, @nRecnoTit)
			//Chama função para contabilizar
			lContabOK	:= x173Contab(cLpApur, cAlsTit, nRecnoTit)
		EndIF

		//Chama função para atualizar o Status da Apuração
		x175AtuSts(F2H->F2H_ID, lContabOK)
		
	EndIF		
		
	// Exibe um browse com o título gerado pela apuração.
	// Não chamar visualização quando executado pelo ADVPR.
	If !lAutomato .And. Len(aTitulo) > 0 .And. !Empty(aTitulo[1][4])	
		
		//Função que faz visualização do título gerado pela apuração
		x173VisTit(aTitulo[1][4])

		//Exibe mensagem de sucesso
		MsgInfo(STR0032)	 //"Título Gerado com Sucesso!"

	EndIf

ElseIf cOpcao == "3" .AND. F2H->F2H_STATUS == "2" .AND. !Empty(F2H->F2H_ID) .AND. F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID)) .AND. x173PosTit(F2L->F2L_CHVFK7, @cAlsTit, @nRecnoTit)	
	//Função responsável por realizar contabilização de título já gerado 	
	//Chama função para contabilizar
	lContabOK	:= x173Contab(cLpApur, cAlsTit, nRecnoTit)
		
	//Chama função para atualizar o Status da Apuração
	x175AtuSts(F2H->F2H_ID, lContabOK)
	
	//Exibe mensagem de sucesso
	If lContabOK		
		MsgInfo(STR0040) //"Contabilização realizada com Sucesso!"
	EndIF
	
EndIf

END TRANSACTION

Return

//------------------------------------------------------------
/*/{Protheus.doc} x173GetFil

Função que fará tratamento das filiais selecionadas pelo usuário, e que 
serão consideradas na apuração

@author Erick G. Dias
@since 19/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function x173GetFil( lPergunta )

Local aFil	    := {}
Local aSM0	    := {}
Local aAreaSM0	:= {}
Local nFil	    := 0

Default lPergunta	:= .F.

//lpergunrta indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se lPergunta estiver .F., a função retornará a filial logada.
If lPergunta	
    //chama função para usuário escolher filial
    aFil:= MatFilCalc( .T. )
    If len(aFil) ==0
        MsgAlert(STR0033) //'Nenhuma filial foi selecionada, o processamento não será realizado.'
    EndiF

Else	
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0

//------------------------------------------------------------
/*/{Protheus.doc} DelTAb

Função genérico para deletar as tabelas da apuração

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function DelTAb(cTab, cIdApur, lMainTab)

Local cQuery	:= ""
Local cCampoId	:= Iif(lMainTab, "_ID" ,"_IDAPUR")

cCampoId	:= IIf(cTab == "F2M", "_IDRAPU", cCampoId )

cQuery := "DELETE FROM " +  RetSqlName(cTab)  + " "
cQuery += "WHERE " + cTab + cCampoId + " = " + ValToSQL( cIdApur ) + " "

IF !EmpTy(Alltrim(cQuery))
	TcSqlExec(cQuery)
EndIF

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelApur

Função que reune a exclusão de todas as tabelas, seja acionada pela
opção de exclusão ou pela opção de reprocessamento.

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function DelApur(cId)

//Exclui as guias que possuierem o ID da apuração e tipo de imposto igual a "E"(GNRE de apuração)
IF AliasInDic("CJ4")
	DelGuia(cId)
EndIF

DelTAb("F2I", cId, .F.)
DelTAb("F2J", cId, .F.)

If F2K->(MsSeek(xFilial("F2K") + cId))
	DelTAb("F2M", F2K->F2K_ID, .F.)
	DelTAb("F2K", cId, .F.)
EndIF

DelTAb("F2L", cId, .F.)
DelTAb("F2H", cId, .T.)

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelGuia

Função que fará a exclusão das guias geradas pela apuração dos tributos genéricos.
Esta função receberá ID e excluirá todas as guias que tiverem o ID da apuração.

@author Erick G. Dias
@since 28/09/2020
@version 12.1.31
/*/
//------------------------------------------------------------------
Function DelGuia(cId)

Local cChvSF6	:= xFilial("SF6") + cId
Local oModel	:= nil 

//Verifico se o ID está devidamente preenchido
If !Empty(cId)

	dbSelectArea("SF6")
	SF6->(dbSetOrder(8)) //F6_FILIAL + F6_IDNF

	//Laço nas guias que tiverem este ID, serão deletadas!
	If SF6->(MsSeek( cChvSF6 ))
		While !SF6->(EoF()) .And. SF6->(F6_FILIAL + F6_IDNF) == cChvSF6			

			//Prossigo com a deleção da SF6.
			oModel := FWLoadModel("MATA960")
            oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate() 			
        
        	If oModel:VldData()
            	lRet := FWFormCommit( oModel )
	        EndIf
        
			oModel:Deactivate()
			SF6->(dbSkip())			
		EndDo
	EndIf

EndIf

Return

//------------------------------------------------------------
/*/{Protheus.doc} ChkApur

Função que fará verificação da existência de apurações já processadas
no período, se existir a rotina retornará a lista dos tributos já processados
no período.

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ChkApur(aParam)

Local cAliasF2H	:= x175Query('F2H', {aParam[1], aParam[2], aParam[4]  })
Local cMsg		:= STR0034 + CHR(13)+CHR(10) + CHR(13)+CHR(10)  //"Já existe apuração processada para este período dos seguinte(s) tributos(s):"
Local lExist 	:= .F.
Local aIdsApur	:= {}

While (cAliasF2H)->(!Eof())		
	
	//Adiciona na mensagem os tributos que já possuem apurações para o período processado
	cMsg += (cAliasF2H)->F2H_TRIB + CHR(13)+CHR(10)
	aAdd(aIdsApur,{(cAliasF2H)->F2H_ID,"", (cAliasF2H)->F2H_STATUS})
	lExist	:= .T.

	(cAliasF2H)->(dbSkip())
EndDo

//Fecha o alias da query
(cAliasF2H)->(dbCloseArea())

Return {lExist, cMsg, aIdsApur}

//------------------------------------------------------------
/*/{Protheus.doc} x173PrcF2L

Função responsável por gravar e excluir as informações da tabela F2L

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function x173PrcF2L(cOpcao, cIdApur, cChvFk7, cRFin)

IF cOpcao == '1' //Inclusão

	Reclock("F2L", .T.)
	F2L->F2L_FILIAL 	:= xFilial("F2L")
	F2L->F2L_ID 		:= FWUUID("F2L")
	F2L->F2L_IDAPUR 	:= cIdApur
	F2L->F2L_CHVFK7 	:= cChvFk7
	F2L->F2L_RFIN 		:= cRFin
	F2L->(MsUnlock())

EndIF

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelTit

Função responsável por gravar e excluir as informações da tabela F2L

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function DelTit(cChvFk7, cOpcao, cOrigem, cNumTit)

Local cAlsSE		:= ""
Local lRet 			:= .T.
Local aArea 		:= GetArea()
Default cOrigem		:= "FISA173|FISA181"

//Posiciona no título através da chave FK7
If x173PosTit(cChvFk7, @cAlsSE)
	// Verifica se há algum título vinculado que não possa ser excluido pois sofreu algum tipo de baixa ou movimentação no financeiro.
	// Se houver paro o laço e já retorno .F. pois o documento em questão não pode ser excluído.		
	If cOpcao == "1" //Verificação se pode deletar
		If cAlsSE == "SE1"
			lRet := FaCanDelCR("SE1", cOrigem, .F.)				
			cNumTit := SE1->E1_NUM + "/" + SE1->E1_PREFIXO
		ElseIf cAlsSE == "SE2"
			lRet := FaCanDelCP("SE2", cOrigem, .F.)				
			cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO
		EndIf
	
	ElseIf cOpcao == "2" //Exclusão
		
		If cAlsSE == "SE1
			SE1->(dbGoTo((cAlsSE)->(RecNo())))
			If FindFunction("FinGrvEx")
				FinGrvEx("R") // Gravar o histórico.
			EndIf
			RecLock("SE1",.F.)				
			SE1->(dbDelete())
			FaAvalSE1(2, cOrigem)
			FaAvalSE1(3, cOrigem)
			MsUnLock()
			
		ElseIf cAlsSE == "SE2
			SE2->(dbGoTo((cAlsSE)->(RecNo())))
			If FindFunction("FinGrvEx")
				FinGrvEx("P") // Gravar o histórico.
			EndIf
			RecLock("SE2",.F.)				
			SE2->(dbDelete())
			FaAvalSE2(2, cOrigem)
			FaAvalSE2(3, cOrigem)
			MsUnLock()

		EndIf	
	EndIF	
EndIF

RestArea(aArea)

Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} x173Contab

Função que realiza a x173Contabação do valor do título da ápuração

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function x173Contab(cCodLP,cAlsTit, nRecnoTit)
  
Local cLoteCtb		:= ''
Local cArqCtb		:= ''
Local cAuxCod		:= ''
Local nHdlPrv		:= 0
Local nTotalCtb		:= 0
local lCtbOnLine	:= .F.
Local aCT5			:= {}

// Verifica o numero do lote contabil.³
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09FIS")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "FIS "
EndIf		

// Executa um execblock
If At(UPPER("EXEC"),X5Descri()) > 0
	cLoteCtb := &(X5Descri())
EndIf				

//Inicializa o arquivo de x173Contabacao
nHdlPrv := HeadProva(cLoteCtb,"FISA173",Subs(cUsuario,7,6),@cArqCtb)
IF nHdlPrv <= 0
	HELP(" ",1,"SEM_LANC")
	lCtbOnLine := .F.
EndIf

Begin Transaction
	
	//x173Contabacao dos Lancamentos de PIS/COFINS	
	nTotalCtb += DetProva(nHdlPrv,cCodLP,"FISA173",cLoteCtb,,,,,@cAuxCod,@aCT5,,,{cAlsTit,nRecnoTit})

	RodaProva(nHdlPrv,nTotalCtb)
	If nTotalCtb > 0
		cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,.T.,.F.)
	EndIf
	
End Transaction

Return (nTotalCtb > 0)

//------------------------------------------------
/*/{Protheus.doc} x173PosTit

Função que posiciona o título através da chave FK7

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Static Function x173PosTit(cChvFk7, cAlsSE, nRecnoTit)

Local cChvSE	:= ""
Local lAchou	:= .F.
Default cAlsSE	:= ""
Default nRecnoTit	:= 0

cAlsSE		:= ""
nRecnoTit	:= 0

dbSelectarea("FK7")
FK7->(dbSetOrder(1))

dbSelectarea("SE2")
SE2->(dbSetOrder(1))

dbSelectarea("SE1")
SE1->(dbSetOrder(1))

//Posiciona na Fk7 através da chave Fk7, e na sequência posiciona o título
If FK7->(MsSeek(xFilial("FK7") + cChvFk7))
	cAlsSE	:= FK7->FK7_ALIAS	
	// Converte o conteúdo do campo FK7_CHAVE para poder localizar a SE1/SE2.
	cChvSE := FK7ToE1E2(FK7->FK7_CHAVE, cAlsSE)
	
	//Posiciona no título em questão
	lAchou	:=  (cAlsSE)->(MsSeek(cChvSE))
	nRecnoTit	:= (cAlsSE)->(RECNO())
EndIF

Return lAchou

//------------------------------------------------
/*/{Protheus.doc} FSA173VTIT

Função que fará a visualização do título gerado através 
da apuração.

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Function FSA173VTIT()

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

IF !F2H->F2H_STATUS $ "5/2"
	MsgAlert(STR0035) //"Esta apuração ainda não gerou título!"
ElseIF F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID )) .AND. !Empty( F2L->F2L_CHVFK7 )
	//Função que exibe o título gerado através da apuração
	x173VisTit(F2L->F2L_CHVFK7)
EndIF

Return

//------------------------------------------------
/*/{Protheus.doc} x173VisTit

Função que recebe chave FK7 e exibe o título gerado pela apuração

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Static Function x173VisTit(cChaveFk7)

Local cFiltroBrw	:= ""
Local cAlsSE		:= ""
Local aChvSE		:= {}

If !Empty(cChaveFk7)

	dbSelectArea("FK7")
	FK7->(dbSetOrder(1))

	If FK7->(MsSeek(xFilial("FK7") + cChaveFk7))

		cAlsSE := FK7->FK7_ALIAS
		aChvSE := StrToKArr(FK7->FK7_CHAVE, "|")

		If cAlsSE == "SE1"
			cFiltroBrw := "E1_FILIAL == " + ValToSQL(aChvSE[1]) + " .And. "
			cFiltroBrw += "E1_PREFIXO == " + ValToSQL(aChvSE[2]) + " .And. "
			cFiltroBrw += "E1_NUM == " + ValToSQL(aChvSE[3]) + " .And. "
			cFiltroBrw += "E1_PARCELA == " + ValToSQL(aChvSE[4]) + " .And. "
			cFiltroBrw += "E1_TIPO == " + ValToSQL(aChvSE[5]) + " .And. "
			cFiltroBrw += "E1_CLIENTE == " + ValToSQL(aChvSE[6]) + " .And. "
			cFiltroBrw += "E1_LOJA == " + ValToSQL(aChvSE[7]) + " .And. "
			cFiltroBrw += "E1_ORIGEM == 'FISA173'"
		ElseIf cAlsSE == "SE2"
			cFiltroBrw := "E2_FILIAL == " + ValToSQL(aChvSE[1]) + " .And. "
			cFiltroBrw += "E2_PREFIXO == " + ValToSQL(aChvSE[2]) + " .And. "
			cFiltroBrw += "E2_NUM == " + ValToSQL(aChvSE[3]) + " .And. "
			cFiltroBrw += "E2_PARCELA == " + ValToSQL(aChvSE[4]) + " .And. "
			cFiltroBrw += "E2_TIPO == " + ValToSQL(aChvSE[5]) + " .And. "
			cFiltroBrw += "E2_FORNECE == " + ValToSQL(aChvSE[6]) + " .And. "
			cFiltroBrw += "E2_LOJA == " + ValToSQL(aChvSE[7]) + " .And. "
			cFiltroBrw += "E2_ORIGEM == 'FISA173'"
		EndIf

		FISA174DET(cAlsSE, STR0036, cFiltroBrw) //"Títulos Gerados Pela Apuração"

	EndIf

EndIf

Return

//------------------------------------------------
/*/{Protheus.doc} GravaGNRE

Função que fará a gravação da Guia pela apuração, 
caso a regra de apuração tenha vinculada um regra de guia.

@author Erick G. Dias
@since 25/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Function GravaGNRE(cNumGNRE, nValor, cTributo, cIdApur)

Local dDtPadrao	:= DataValida( LastDay( dDataBase ) + 1, .T.) //Inicio com padrão do primeiro dia útil do próximo mês
Local dDtVenc	:= Iif( FindFunction("xFisDtGnre") , xFisDtGnre(dDtPadrao) , dDtPadrao )
Local cMvEstado := GetNewPar("MV_ESTADO","")
Local oModel    := FWLoadModel('MATA960')

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

//Para essa operação é preciso especificar qual o modelo que queremos inserir o valor
oModel:SetValue("MATA960MOD","F6_NUMERO"  , cNumGNRE)
oModel:SetValue("MATA960MOD","F6_TIPOIMP" , "E")
oModel:LoadValue("MATA960MOD","F6_VALOR"   , nValor)
oModel:SetValue("MATA960MOD","F6_DTARREC" , dDataBase)
oModel:SetValue("MATA960MOD","F6_MESREF"  , Month(dDataBase))		
oModel:SetValue("MATA960MOD","F6_ANOREF"  , Year(dDataBase))
oModel:SetValue("MATA960MOD","F6_TRIB"    , cTributo)
oModel:SetValue("MATA960MOD","F6_IDNF"    , cIdApur)
oModel:SetValue("MATA960MOD","F6_EST"     , cMvEstado)
oModel:SetValue("MATA960MOD","F6_DTVENC"  , Iif(Empty(dDtVenc), dDtPadrao,dDtVenc ) )

//Executo as validações do modelo e prossigo com gravação das informações.
If oModel:VldData()
	oModel:CommitData()	
Else		
	//Aqui exibo erro, pois ocorreu algum erro de validação do modelo
	VarInfo("",oModel:GetErrorMessage())			
EndIf

//Desativo e destruo o objeto aqui
oModel:DeActivate()
oModel:Destroy()

//Verifica se deseja visualizar/alterar a Guia gerada
//Aqui posso verifica a CJ4 pois a função EnqNFGNRE() já posicionou esta tabela
If !IsBlind() 
	IF CJ4->CJ4_VTELA == "1"
		FWExecView( cTributo ,"MATA960", MODEL_OPERATION_UPDATE, , { ||.T. } ,{ || .T.} )
	Else
		MsgInfo(STR0044) //"Guia de recolhimento gerada com sucesso!"
	EndIF
EndIf

Return

//------------------------------------------------
/*/{Protheus.doc} F173ChkGNRE

Verifica se há apuração para o tributo no período selecionado. 
Essa função foi criada por conta do SENAR que tinha a geração de guia e título duplicados ao realizar a apuração de ICMS (FISA153).
Porém, pode ser utilizada para qualquer tributo.

@author leandro.faggyas
@since 30/01/2023
@version 12.1.2210
@return lRet, Logical, Retorna se foi encontrada apuração na data inicial para o tributo pesquisado.
/*/
//------------------------------------------------
Function F173ChkGNRE( cIdTrib, dDtIni )
Local cTributo := ""
Local aAreaF2E := F2E->(GetArea())
Local aAreaF2H := F2H->(GetArea())
Local lRet     := .F.

DbSelectArea("F2E")
F2E->(DbSetOrder(3)) //F2E_FILIAL+F2E_IDTRIB
If F2E->(MsSeek(xFilial("F2E")+cIdTrib))
	cTributo := F2E->F2E_TRIB
EndIf

DbSelectArea("F2H")
F2H->(DbSetOrder(1)) //F2H_FILIAL+DTOS(F2H_DTINI)+F2H_TRIB+F2H_ID
If F2H->(MsSeek(xFilial("F2H")+Dtos(dDtIni)+cTributo))
	lRet := .T.
EndIf

RestArea(aAreaF2E)
RestArea(aAreaF2H)

Return lRet
