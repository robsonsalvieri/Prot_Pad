#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF93.CH"

/*{Protheus.doc} TMSAF93
Integração do Faturamento com Coleta/Entrega (notas avulsas)
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Function TMSAF93()

Local cCadastro := STR0001 //-- "INTEGRAÇÃO PORTAL COLETA ENTREGA NOTAS SEM VEÍCULOS"
	If TM92VldInt()
		Private aRotina := MenuDef()

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("DNG")
		oBrowse:SetDescription(cCadastro)

		oBrowse:AddLegend( "DNG->DNG_STATUS=='1'", "YELLOW", STR0002) //-- "Sem Histórico"
		oBrowse:AddLegend( "DNG->DNG_STATUS=='2'", "GREEN" , STR0003) //-- "Com Histórico"

		oBrowse:Activate()
	EndIf
Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0004 Action "AxPesqui"         OPERATION 1 ACCESS 0	//-- "Pesquisar"
	ADD OPTION aRotina Title STR0005 Action "VIEWDEF.TMSAF93"  OPERATION 2 ACCESS 0	//-- "Visualizar"
	ADD OPTION aRotina Title STR0006 Action "VIEWDEF.TMSAF93"  OPERATION 3 ACCESS 0	//-- "Incluir"
	ADD OPTION aRotina Title STR0008 Action "VIEWDEF.TMSAF93"  OPERATION 5 ACCESS 0	//-- "Excluir"
	ADD OPTION aRotina Title STR0012 Action 'TMSAF93Wiz()'     OPERATION 3 ACCESS 0	//-- 'Wiz.Grv.Hist'
	ADD OPTION aRotina Title STR0009 Action 'TMSAF93Sup(6,,)'  OPERATION 2 ACCESS 0	//-- 'Grava Hist'
	ADD OPTION aRotina Title STR0010 Action 'TMSAF93Sup(7,,)'  OPERATION 2 ACCESS 0	//-- 'Env. Portal'
	ADD OPTION aRotina Title STR0011 Action 'TMSAF93Sup(8,,)'  OPERATION 2 ACCESS 0	//-- 'Estorna'

Return aRotina

/*{Protheus.doc} ModelDef
Definição do Modelo
@author Carlos Alberto Gomes Junior
@since 11/01/2023
*/
Static Function ModelDef()
Local oStrucDNG  := FWFormStruct(1,"DNG")
Local oModel

	oModel := MpFormModel():New("TMSAF93",/*bPreValidacao*/,{|oModel| TMSAF93Pos(oModel)}/*bPosVld*/,/*bCommit*/,/*bCancel*/)

	oModel:SetDescription(STR0001)

	//-- Cabeçalho da Viagem
	oModel:AddFields("MdFieldDNG",,oStrucDNG,,,)
	oModel:SetPrimaryKey({"DNG_DOC","DNG_SERIE"})
	oModel:GetModel("MdFieldDNG"):SetDescription(STR0013)

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@author Carlos Alberto Gomes Junior
@since 11/01/2023
*/
Static Function ViewDef()
Local oStrucDNG := FWFormStruct(2,"DNG")
Local oModel    := FwLoadModel("TMSAF93")
Local oView

	oView := FwFormView():New()
	oView:SetModel(oModel)
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "TelaNotas", 100 )

	//-- Define o Field da Tela Principal
	oView:AddField("VwFieldDNG",oStrucDNG,"MdFieldDNG")
	oView:SetOwnerView("VwFieldDNG","TelaNotas")

Return oView

/*{Protheus.doc} TMSAF93Vld
Validação dos campos da tela
@author Carlos Alberto Gomes Junior
@since 16/01/2023
*/
Function TMSAF93Vld(cCampo)
Local aAreas    := {DNG->(GetArea()),SF2->(GetArea()),GetArea()}
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelDNG := oModel:GetModel("MdFieldDNG")

Default cCampo := ReadVar()

	If "DNG_DOC" $ cCampo
		If !Empty(oModelDNG:GetValue("DNG_SERIE"))
			SF2->(DbSetOrder(1))
			DNG->(DbSetOrder(1))
			If !( lRet := SF2->(DbSeek(xFilial("SF2") + M->DNG_DOC + oModelDNG:GetValue("DNG_SERIE"))) )
				Help("",1,"TMSAF9305") //-- "Nota Fiscal não encontrada."
			ElseIf !( lRet := !DNG->(DbSeek(xFilial("DNG") + M->DNG_DOC + oModelDNG:GetValue("DNG_SERIE"))) )
				Help("",1,"TMSAF9307") //-- "Nota Fiscal já cadastrada para integração."
			Else
				lRet := ( !TM92SeekNF(cFilAnt, M->DNG_DOC, oModelDNG:GetValue("DNG_SERIE")) )
			EndIf
		EndIf
	ElseIf "DNG_SERIE" $ cCampo
		If !Empty(oModelDNG:GetValue("DNG_DOC"))
			SF2->(DbSetOrder(1))
			If !( lRet := SF2->(DbSeek(xFilial("SF2") + oModelDNG:GetValue("DNG_DOC") + M->DNG_SERIE)) )
				Help("",1,"TMSAF9305") //-- "Nota Fiscal não encontrada."
			ElseIf !( lRet := !DNG->(DbSeek(xFilial("DNG") + oModelDNG:GetValue("DNG_DOC") + M->DNG_SERIE)) )
				Help("",1,"TMSAF9307") //-- "Nota Fiscal já cadastrada para integração."
			Else
				lRet := ( !TM92SeekNF(cFilAnt, oModelDNG:GetValue("DNG_DOC"), M->DNG_SERIE) )
			EndIf
		EndIf
	EndIf

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF93Pos
Função de pós validação do modelo
@author Carlos Alberto Gomes Junior
@Since	12/01/2023
*/
Function TMSAF93Pos(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

	If oModel:GetValue( 'MdFieldDNG', 'DNG_STATUS' ) != "1"
		If nOperation == MODEL_OPERATION_DELETE
			Help("",1,"TMSAF9302") //-- Notas com histórico não podem ser excluidas.
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} TMSAF93Sup
Rotina de suporte que chama as funções da integração com coleta/entrega.
@author Carlos Alberto Gomes Junior
@since 12/01/2023
*/
Function TMSAF93Sup(nAcao,cProces,nEnvRet)

Default nAcao   := 0
DEFAULT cProces := DNG->(DNG_FILIAL+DNG_DOC+DNG_SERIE)
Default nEnvRet := 0

	If nAcao == 6	//-- Gravação da DN5
		FWMsgrun(,{|| TMSAF93His(cProces)}, STR0014, STR0015 ) //-- "Aguarde" //-- "Gerando Histórico de Integração"
	ElseIf nAcao == 7	//-- Envio ao Portal
		FWMsgrun(,{|| TMSAF93His(cProces,,.F.)}, STR0014, STR0015 ) //-- "Aguarde" //-- "Gerando Histórico de Integração"
		FWMsgrun(,{|| TMSAI86AUX(cProces,DN1->DN1_URLAPP)}, STR0016, STR0017 ) //-- "Job de Envio de Integração" //-- "Aguarde enquanto o Job é executado."
	ElseIf nAcao == 8	//-- Estorno
		FWMsgrun(,{|| TMSAF93His(cProces,2)}, STR0014, STR0018 ) //-- "Aguarde" //-- "Estornando Integração com Coleta/Entrega"
	EndIf

Return

/*{Protheus.doc} TMSAF93His
Grava Histórico por Nota
@author Carlos Alberto Gomes Junior
@since 12/01/2023
*/
Function TMSAF93His(cProces,nOpc,lHelp)
Local aAreas   := { DNG->(GetArea()), SF2->(GetArea()), GetArea() }

DEFAULT cProces := DNG->(DNG_FILIAL+DNG_DOC+DNG_SERIE)
DEFAULT nOpc    := 1
DEFAULT lHelp   := .T.

	DNG->(DbSetOrder(1))
	SF2->(DbSetOrder(1))
	If DNG->(MsSeek(cProces)) .And. SF2->(MsSeek(cProces))
		If nOpc == 1
			If DNG->DNG_STATUS == "1"
				Begin Transaction
				If TMC30GHist(cProces)
					RecLock("DNG",.F.)
					DNG->DNG_STATUS := "2"
					MsUnlock()
				EndIf
				End Transaction
			Elseif lHelp
				Help("",1,"TMSAF9303") //-- Histórico de Nota Fiscal ja gravado. Para enviar novamente estorne esta nota.
			EndIf
		ElseIf nOpc == 2
			TM93EstHis(cProces)
		EndIf
	EndIf
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aAreas)'

Return

/*{Protheus.doc} TM93EstHis
Estorna os registros da tabela intermediária de histórico que ainda não foram enviados à gestão de entregas
@author Carlos Alberto Gomes Junior
@Since	13/01/2023
*/
Static Function TM93EstHis(cProces)
Local aAreas     := {DNG->(GetArea()),DN4->(GetArea()),DN5->(GetArea()),DN1->(GetArea()),GetArea()}
Local aStruct    := {}
Local aSituac    := {}
Local nRegPrinc  := 0
Local nRegistro  := 0
Local lOk        := .T.
Local lPrimeiro  := .T.
Local cAliasDN5  := ""
Local cQuery     := ""
Local lExcluida	 := .F. 
Local oColEnt AS Object

Default cProces := DNG->(DNG_FILIAL+DNG_DOC+DNG_SERIE)

	DNG->(DbSetOrder(1))
	If DNG->(MsSeek(cProces))
		If DNG->DNG_STATUS == "1"
			Help("",1,"TMSAF9304") //-- Somente Documentos com Histórico podem ter o Histórico estornado.

		ElseIf ( lOk := MsgYesNo( STR0019 + cProces ) ) //-- "Confirma Estorno do Envio da Nota Fiscal: "
			SF2->(DbSetOrder(1))
			SF2->(MsSeek(cProces))
			oColEnt := TMSBCACOLENT():New("DN1")
			If oColEnt:DbGetToken()
				DN1->(DbGoTo(oColEnt:config_recno))
				//-- Inicializa a estrutura
				aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
				//-- Localiza primeiro registro da estrutura
				nRegPrinc := TMFirstReg(aStruct)
			
				If ExisteDN5(aStruct[nRegPrinc,1],aStruct[nRegPrinc,2],PadR(cProces,Len(DN5->DN5_PROCES)),{"1","2"},@nRegistro)
					DN5->(DbGoTo(nRegistro))
					If DN5->DN5_STATUS == "1" .Or. DN5->DN5_STATUS == "2"
						If DN5->DN5_STATUS == "1"
							If (aSituac := TMSAC30GDD(oColEnt,DN5->DN5_IDEXT))[1]
								If aSituac[2][1] != "AGUARDANDO_VIAGEM"
									Help(" ", , STR0020, , STR0021 + aSituac[2][1], 2, 1) //-- "Não é possível estonar a integração." //-- "Nota Fiscal já manipulada no portal. Status atual: "
									lOk := .F.
								EndIf
								If aSituac[2][1] == "EXCLUIDA"//--Caso a NF Avulsa tenha sido excluída no Coleta entrega, deve permitir a exclusão no FAT.
									lExcluida := .T. 
								EndIf 
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If (lOk .And. (Empty(DN5->DN5_IDEXT) .Or. TMSAC30ExN(AllTrim(DN5->DN5_IDEXT)))) .Or. lExcluida 
			cAliasDN5 := GetNextAlias()
			cQuery := "SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
			cQuery += "  FROM " + RetSqlName("DN5") + " DN5 "
			cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
			cQuery += "   AND DN5.DN5_CODFON = '" + DN1->DN1_CODFON + "' "
			cQuery += "   AND DN5.DN5_PROCES = '" + cProces + "' "
			cQuery += "   AND DN5.DN5_STATUS IN('1','2') "
			cQuery += "   AND DN5.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

			DN4->(DbSetOrder(1))

			While (cAliasDN5)->(!Eof())
				//-- Estorna registro na DN5
				DN5->(DbGoTo((cAliasDN5)->REGISTRO))
				RecLock("DN5",.F.)
				DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
				DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
				DN5->(MsUnLock())

				//-- Estorna registro na DN4
				DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
				RecLock("DN4",.F.)
				DN4->DN4_IDEXT  := ""
				DN4->DN4_STATUS := '2'
				DN4->(MsUnLock())

				If lPrimeiro
					DNC->(DbSetOrder(1))
					If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
						Reclock("DNC",.F.)
						DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
						DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
						DNC->DNC_DATULT := dDataBase
						DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
						DNC->(MsUnlock())
					EndIf
					lPrimeiro := .F.
				EndIf

				(cAliasDN5)->(DbSkip())
			EndDo

			(cAliasDN5)->(DbCloseArea())
			
			RecLock("DNG",.F.)
			DNG->DNG_STATUS := "1"
			MsUnlock()

		EndIf

		FWFreeObj( oColEnt )

		AEval( aAreas, {|x,y| RestArea(x), FwFreeArray(x) } )
		FWFreeArray( aAreas )
		FWFreeArray( aStruct )

	EndIf

Return

/*{Protheus.doc} TMSAF93Wiz
Função Wizard de Entrada
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Function TMSAF93Wiz( lNFAvulsa, aNfsOk )

Local cText     := ""
Local aPergs    := {}
Local cDocDe    := Space(Len(DNG->DNG_DOC))
Local cSerieDe  := Space(Len(DNG->DNG_SERIE))
Local cDocAt    := Replicate('Z',Len(DNG->DNG_DOC))
Local cSerieAt  := Replicate('Z',Len(DNG->DNG_SERIE))
Local cEmiDe    := StoD(StrZero(Year(dDataBase),4)+"0101")
Local cEmiAt    := dDataBase
Local cCliDe    := Space(Len(SA1->A1_COD))
Local cLojaDe   := Space(Len(SA1->A1_LOJA))
Local cCliAt    := Replicate('Z',Len(SA1->A1_COD))
Local cLojaAt   := Replicate('Z',Len(SA1->A1_LOJA))
Local aRetPar   := {cDocDe,cSerieDe,cDocAt,cSerieAt,cEmiDe,cEmiAt,cCliDe,cLojaDe,cCliAt,cLojaAt}
Local aLisNfs   := {{.F.,"","",StoD(""),"","",""}}
Local lAllOkNo  := .F.
Local lProcessa := .F.
Local oWizard As Object
Local oList   As Object

Private oBmpOk   := LoadBitmap(GetResources(), "LBOK")
Private oBmpNo   := LoadBitmap(GetResources(), "LBNO")

DEFAULT lNFAvulsa := .T.
DEFAULT aNfsOk    := {}

	cText += STR0022 //-- "Esta funcionalidade tem como objetivo gerar o histórico "
	cText += STR0023 //-- "de envio de Notas Fiscais sem veículo informado seguindo "
	cText += STR0024 + CRLF + CRLF //-- "os filtros informados nos parâmetros a seguir."
	cText += STR0025 //-- "Para prosseguir clique en avançar."

	//Inicialização objeto Wizard
	DEFINE WIZARD oWizard TITLE STR0026 ; //-- "Integração Coleta Entrega."
		HEADER STR0027 ; //-- "Wizard de Integração de notas sem veículos."
		MESSAGE STR0028 TEXT cText ; //-- "Gravação de histórico"
		NEXT {|| .T. } FINISH {|| .T. } PANEL

	//Segundo painel do Wizard (após o primeiro avançar)
	CREATE PANEL oWizard HEADER STR0027 ; //-- "Wizard de Integração de notas sem veículos."
		MESSAGE STR0029 ; //-- "Informe os Parâmetros para aplicação do filtro:"
		BACK {|| .T. } NEXT {|| TMSAF93Qry(aRetPar,aLisNfs,oList) } FINISH {|| .T. } PANEL

	//Criação dos dados dentro do painel por Parambox
	
	aAdd(aPergs, {1, STR0030, cDocDe  ,  "@!", ".T.", "F2COEN", ".T.", 80,  .F.}) //-- "N.Fiscal De"
	aAdd(aPergs, {1, STR0031, cSerieDe,  "@!", ".T.", ""      , ".T.", 30,  .F.}) //-- "Serie De"
	aAdd(aPergs, {1, STR0032, cDocAt  ,  "@!", ".T.", "F2COEN", ".T.", 80,  .T.}) //-- "N.Fiscal Até"
	aAdd(aPergs, {1, STR0033, cSerieAt,  "@!", ".T.", ""      , ".T.", 30,  .T.}) //-- "Serie Até"
	aAdd(aPergs, {1, STR0034, cEmiDe  ,  ""  , ".T.", ""      , ".T.", 60,  .F.}) //-- "Emissão De"
	aAdd(aPergs, {1, STR0035, cEmiAt  ,  ""  , ".T.", ""      , ".T.", 60,  .T.}) //-- "Emissão Até"
	aAdd(aPergs, {1, STR0036, cCliDe  ,  "@!", ".T.", "SA1"   , ".T.", 80,  .F.}) //-- "Cliente De"
	aAdd(aPergs, {1, STR0037, cLojaDe ,  "@!", ".T.", ""      , ".T.", 30,  .F.}) //-- "Loja De"
	aAdd(aPergs, {1, STR0038, cCliAt  ,  "@!", ".T.", "SA1"   , ".T.", 80,  .T.}) //-- "Cliente Até"
	aAdd(aPergs, {1, STR0039, cLojaAt ,  "@!", ".T.", ""      , ".T.", 30,  .T.}) //-- "Loja Até"
	
	ParamBox(aPergs,STR0040,@aRetPar,,,,,,oWizard:GetPanel(2))

	//Segundo painel do Wizard (após o segundo avançar)
	CREATE PANEL oWizard HEADER STR0027 ; //-- "Wizard de Integração de notas sem veículos."
		MESSAGE STR0041 ; //-- "Selecione as notas que serão processadas:"
		BACK {|| .T. } NEXT {|| .T. } FINISH {|| lProcessa := .T. } PANEL

	oList := TWBrowse():New(002,002,299,125,,{" ",STR0042,STR0043,STR0044,STR0045,STR0046,STR0047},,oWizard:GetPanel(3),,,,,,,,,,,,.F.,,.T.,,.F.,,,) //-- "Documento","Serie","Emissão","Cliente","Loja","Nome"
	oList:SetArray(aLisNfs)
	oList:bLine := {|| { Iif( aLisNfs[oList:nAt][1], oBmpOk, oBmpNo ), aLisNfs[oList:nAt][2],aLisNfs[oList:nAt][3],aLisNfs[oList:nAt][4],aLisNfs[oList:nAt][5],aLisNfs[oList:nAt][6],aLisNfs[oList:nAt][7] } }
	oList:blDblClick := {|| MudaMarca(oList,1,aLisNfs)  }
	TCheckBox():New( 130, 002, STR0048, {|| lAllOkNo  }, oWizard:GetPanel(3), 55, 10,,{|| MudaMarca(oList,2,aLisNfs,@lAllOkNo) },,,,,,.T.,,,) //-- 'Marcar/Desmarcar Todos:'
	ACTIVATE WIZARD oWizard CENTER

	FWFreeObj(oList)
	FWFreeObj(oWizard)

	If lProcessa
		If lNFAvulsa
			FWMsgrun(,{|| TMSAF93Pre(aLisNfs) }, STR0014, STR0015 ) //-- "Aguarde" //-- "Gerando Histórico de Integração"
		Else
			AEval( aLisNfs, { |aNF| If(aNF[1], AAdd( aNfsOk, { aNF[2], aNF[3] } ), ) })
		EndIf
	EndIf

Return .T.

/*{Protheus.doc} TMSAF93Qry
Função Wizard de Entrada
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Function TMSAF93Qry(aRetPar,aLisNfs,oList)
Local cQuery    := ""
Local aArea     := GetArea()
Local cAliasQRY := GetNextAlias()
Local cTpNF     := SuperGetMV("MV_COLETNF", .F., "'N','B','D'")

DEFAULT aRetPar := {}

	aLisNfs := {}
	If !Empty(aRetPar)
		cQuery += "SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_CLIENTE,SF2.F2_LOJA,F2_TIPO,SA1.A1_NOME,SA2.A2_NOME FROM " + RetSQLName("SF2") + " SF2 "
		cQuery += "LEFT OUTER JOIN " + RetSQLName("SA1") + " SA1 ON "
		cQuery += "  SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQuery += "  SA1.A1_COD    = SF2.F2_CLIENTE AND "
		cQuery += "  SA1.A1_LOJA   = SF2.F2_LOJA AND "
		cQuery += "  SA1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT OUTER JOIN " + RetSQLName("SA2") + " SA2 ON "
		cQuery += "  SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
		cQuery += "  SA2.A2_COD    = SF2.F2_CLIENTE AND "
		cQuery += "  SA2.A2_LOJA   = SF2.F2_LOJA AND "
		cQuery += "  SA2.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
		cQuery += "SF2.F2_DOC BETWEEN '" + aRetPar[1] + "' AND '" + aRetPar[3] + "' AND "
		cQuery += "SF2.F2_SERIE BETWEEN '" + aRetPar[2] + "' AND '" + aRetPar[4] + "' AND "
		cQuery += "SF2.F2_EMISSAO BETWEEN '" + DtoS(aRetPar[5]) + "' AND '" + DtoS(aRetPar[6]) + "' AND "
		cQuery += "SF2.F2_CLIENTE BETWEEN '" + aRetPar[7] + "' AND '" + aRetPar[9] +  "' AND "
        cQuery += "SF2.F2_LOJA BETWEEN '" + aRetPar[8] + "' AND '" + aRetPar[10] +  "' AND "
		If !Empty(cTpNF)
			cQuery += "SF2.F2_TIPO IN (" + cTpNF + ") AND "			
		Endif
		cQuery += "SF2.D_E_L_E_T_ = ' ' AND "
		cQuery += "NOT EXISTS ( SELECT 1 FROM " + RetSQLName("DNG") + " DNG WHERE "
		cQuery += "				DNG.DNG_FILIAL = '" + xFilial("DNG") + "' AND "
		cQuery += "				DNG.DNG_DOC = SF2.F2_DOC AND "
		cQuery += "				DNG.DNG_SERIE = SF2.F2_SERIE AND "
		cQuery += "				DNG.D_E_L_E_T_ = ' ') "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)

		If (cAliasQRY)->(!Eof())
			Do While (cAliasQRY)->(!Eof())
				(cAliasQRY)->(AAdd(aLisNfs,{ .T., F2_DOC, F2_SERIE, StoD(F2_EMISSAO), F2_CLIENTE, F2_LOJA, Iif(F2_TIPO $ "B|D",A2_NOME,A1_NOME) }))
				(cAliasQRY)->(DbSkip())
			EndDo
		Else
			Help("",1,"TMSAF9306") // Não foram encontrado registros para gerar Histórico.
		EndIf
		(cAliasQRY)->(DbCloseArea())

	Else
		Help("",1,"TMSAF9306") // Não foram encontrado registros para gerar Histórico.
	EndIf

	RestArea(aArea)
	FWFreeArray(aArea)
	oList:SetArray(aLisNfs)
	oList:bLine := {|| { Iif( aLisNfs[oList:nAt][1], oBmpOk, oBmpNo ), aLisNfs[oList:nAt][2],aLisNfs[oList:nAt][3],aLisNfs[oList:nAt][4],aLisNfs[oList:nAt][5],aLisNfs[oList:nAt][6],aLisNfs[oList:nAt][7] } }
	oList:Refresh()

Return .T.

/*{Protheus.doc} MudaMarca
Atualiza marca do TWBrowse
@author Carlos Alberto Gomes Junior
@since 17/01/2023
*/
Static Function MudaMarca(oList,nTipo,aLisNfs,lAllOkNo)
	If nTipo == 1
		aLisNfs[oList:nAt][1] := !aLisNfs[oList:nAt][1]
	ElseIf nTipo == 2
		lAllOkNo := !lAllOkNo
		AEval(aLisNfs,{|x,y| aLisNfs[y][1] := lAllOkNo })
	EndIf
	oList:Refresh()

Return .T.

/*{Protheus.doc} TMSAF93Pre
Função Wizard de Entrada
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Function TMSAF93Pre(aLisNfs)

Local nNF := 0
Local oModel As Object
	
	For nNF := 1 To Len(aLisNfs)
		If aLisNfs[nNf][1]
			oModel := FWLoadModel( "TMSAF93" )
			oModel:SetOperation( 3 )
			oModel:Activate()
			oModel:SetValue( "MdFieldDNG", "DNG_DOC"   , aLisNfs[nNf][2] )
			oModel:SetValue( "MdFieldDNG", "DNG_SERIE" , aLisNfs[nNf][3] )
			oModel:SetValue( "MdFieldDNG", "DNG_STATUS", "1" )
			If oModel:VldData()
				oModel:CommitData()
				TMSAF93His(xFilial("DNG")+aLisNfs[nNf][2]+aLisNfs[nNf][3])
			EndIf
			FWFreeObj(oModel)
		EndIf
	Next

Return .T.
