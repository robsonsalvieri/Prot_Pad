#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC lMedExt := .F.
STATIC nLenSX8    := 0
STATIC lat930autG := .F.
STATIC aCloneCab  := {}
STATIC aCompProc  := {}
STATIC IsBlindRb  := .F.
STATIC cMV_PAR04  := ""
STATIC lMsgRpl 	  := .F.
Static lMedExce   := .F.
STATIC lApuraHE   := .F.
Static aHEsProc   := {}

Function TECA930D()
Local oMBrowse

oMBrowse:= FWmBrowse():New()
oMBrowse:SetAlias("TFV")
oMBrowse:SetMenudef("TECA930D")
oMBrowse:SetDescription("Apuração / Medição de Contratos")
oMBrowse:AddLegend("TFV->TFV_TIPO == '1'","BR_VERDE","Padrão")
oMBrowse:Activate()

Return

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"          OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TECA930D" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Medir/Apurar Contrato" ACTION "At930dGerMed" OPERATION 3 ACCESS 0

Return(aRotina)

Static Function ModelDef()

Local oModel  := Nil
Local oStrTFV := FWFormStruct(1, "TFV")
Local oStrTWB := FWFormStruct(1, "TWB")
Local oStrTFW := FWFormStruct(1, "TFW")
Local oStrTFX := FWFormStruct(1, "TFX")
Local oStrTFY := FWFormStruct(1, "TFY")
Local bCommit := {|oModel| At930DRun(oModel)}

oModel := MPFormModel():New("TECA930D",/*Pre-Validacao*/, /*Pos-Validacao*/, bCommit,/*Cancel*/)

oModel:AddFields("TFVMASTER",/*cOwner*/,oStrTFV)
oModel:addGrid("TWBDETAIL","TFVMASTER" , oStrTWB)
oModel:addGrid("TFWDETAIL","TWBDETAIL" , oStrTFW)
oModel:addGrid("TFXDETAIL","TFWDETAIL" , oStrTFX)
oModel:addGrid("TFYDETAIL","TFWDETAIL" , oStrTFY)

oModel:SetRelation("TWBDETAIL", { { "TWB_FILIAL", "xFilial('TWB')" }, { "TWB_CODTFV" ,"TFV_CODIGO" } }, TWB->(IndexKey(1)))
oModel:SetRelation("TFWDETAIL", { { "TFW_FILIAL", "xFilial('TFW')" }, { "TFW_APURAC" ,"TFV_CODIGO" }, { "TFW_CODTFL" ,"TWB_CODTFL" } }, TFW->(IndexKey(1)))
oModel:SetRelation("TFXDETAIL", { { "TFX_FILIAL", "xFilial('TFX')" }, { "TFX_APURAC" ,"TFW_APURAC" }, { "TFX_CODTFF" ,"TFW_CODTFF" } }, TFX->(IndexKey(1)))
oModel:SetRelation("TFYDETAIL", { { "TFY_FILIAL", "xFilial('TFY')" }, { "TFY_APURAC" ,"TFW_APURAC" }, { "TFY_CODTFF" ,"TFY_CODTFF" } }, TFY->(IndexKey(1)))

oModel:GetModel("TWBDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TWBDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("TFWDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TFWDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("TFXDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TFXDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("TFYDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TFYDETAIL"):SetNoDeleteLine(.T.)

oStrTWB:AddField(TecTituDes("TWB_CODABS",.T.),TecTituDes("TWB_CODABS",.F.),"TWB_CODABS","C",FwTamSX3("TWB_CODABS")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dLocal("ABS_LOCAL" )} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("ABS_DESCRI",.T.),TecTituDes("ABS_DESCRI",.F.),"ABS_DESCRI","C",FwTamSX3("ABS_DESCRI")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dLocal("ABS_DESCRI")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("ABS_CODIGO",.T.),TecTituDes("ABS_CODIGO",.F.),"ABS_CODIGO","C",FwTamSX3("ABS_CODIGO")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dLocal("ABS_CODIGO")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("ABS_LOJA"  ,.T.),TecTituDes("ABS_LOJA"  ,.F.),"ABS_LOJA"  ,"C",FwTamSX3("ABS_LOJA"  )[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dLocal("ABS_LOJA"  )} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("ABS_DESENT",.T.),TecTituDes("ABS_DESENT",.F.),"ABS_DESENT","C",FwTamSX3("ABS_DESENT")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dCliLoc("A1_NOME"  )} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("TFL_TOTRH" ,.T.),TecTituDes("TFL_TOTRH" ,.F.),"TFL_TOTRH" ,"N",FwTamSX3("TFL_TOTRH" )[1],2,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dTotais("TFL_TOTRH")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("TFL_TOTMI" ,.T.),TecTituDes("TFL_TOTMI" ,.F.),"TFL_TOTMI" ,"N",FwTamSX3("TFL_TOTMI" )[1],2,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dTotais("TFL_TOTMI")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("TFL_TOTMC" ,.T.),TecTituDes("TFL_TOTMC" ,.F.),"TFL_TOTMC" ,"N",FwTamSX3("TFL_TOTMC" )[1],2,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dTotais("TFL_TOTMC")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTWB:AddField(TecTituDes("TFL_TOTLE" ,.T.),TecTituDes("TFL_TOTLE" ,.F.),"TFL_TOTLE" ,"N",FwTamSX3("TFL_TOTLE" )[1],2,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dTotais("TFL_TOTLE")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)

oStrTFW:AddField(TecTituDes("TFF_PRODUT",.T.),TecTituDes("TFF_PRODUT",.F.),"TFF_PRODUT","C",FwTamSX3("TFF_PRODUT")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dRecHm("TFF_PRODUT")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTFW:AddField(TecTituDes("TFF_DESCRI",.T.),TecTituDes("TFF_DESCRI",.F.),"TFF_DESCRI","C",FwTamSX3("TFF_DESCRI")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dProdRh("B1_DESC"  )} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTFW:AddField(TecTituDes("TDW_DESC"  ,.T.),TecTituDes("TDW_DESC"  ,.F.),"TDW_DESC"  ,"C",FwTamSX3("TDW_DESC"  )[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dEscRh("TDW_DESC"  )} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oStrTFW:AddField(TecTituDes("TFF_VLRCOB",.T.),TecTituDes("TFF_VLRCOB",.F.),"TFF_VLRCOB","N",FwTamSX3("TFF_VLRCOB")[1],2,/* */,/*bValid*/, /*bWhen*/, .F., {||At930dRecHm("TFF_VLRCOB")} ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)

oModel:GetModel("TFXDETAIL"):SetOptional(.T.)
oModel:GetModel("TFYDETAIL"):SetOptional(.T.)

oModel:SetActivate({|oModel|InitDados(oModel)})

Return(oModel)

Static Function ViewDef()

Local oView   := Nil
Local oModel  := FWLoadModel("TECA930D")
Local oStrTFV := FWFormStruct(2, "TFV")
Local oStrTWB := FWFormStruct(2, "TWB", {|cCpo| AllTrim(cCpo)$"TWB_COD|TWB_CODTFV|TWB_CODTFL"})
Local oStrTFW := FWFormStruct(2, "TFW", {|cCpo| AllTrim(cCpo)$"TFW_APURAC|TFW_NUMMED|TFW_ITMED|TFW_CODIGO|TFW_CODTFF|TFW_VLRMED"})
Local oStrTFX := FWFormStruct(2, "TFX")
Local oStrTFY := FWFormStruct(2, "TFY")

oView := FWFormView():New()

oStrTFV:SetProperty("TFV_REVISA" ,MVC_VIEW_TITULO,TecTituDes("TFJ_CONREV",.T.))
//oStrTWB:SetProperty("TWB_CODTFL" ,MVC_VIEW_TITULO,TecTituDes("TWB_CODTFL",.T.))

oStrTWB:SetProperty("TWB_COD"    ,MVC_VIEW_ORDEM,"01")
oStrTWB:SetProperty("TWB_CODTFV" ,MVC_VIEW_ORDEM,"02")
oStrTWB:SetProperty("TWB_CODTFL" ,MVC_VIEW_ORDEM,"03")
oStrTWB:AddField("TWB_CODABS","04",TecTituDes("TWB_CODABS",.F.),TecTituDes("TWB_CODABS",.F.),{},"C",AllTrim(X3Picture("TWB_CODABS")),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("ABS_DESCRI","05",TecTituDes("ABS_DESCRI",.T.),TecTituDes("ABS_DESCRI",.F.),{},"C",AllTrim(X3Picture("ABS_DESCRI")),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("ABS_CODIGO","06",TecTituDes("ABS_CODIGO",.T.),TecTituDes("ABS_CODIGO",.F.),{},"C",AllTrim(X3Picture("ABS_CODIGO")),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("ABS_LOJA"  ,"07",TecTituDes("ABS_LOJA"  ,.T.),TecTituDes("ABS_LOJA"  ,.F.),{},"C",AllTrim(X3Picture("ABS_LOJA"  )),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("ABS_DESENT","08",TecTituDes("ABS_DESENT",.T.),TecTituDes("ABS_DESENT",.F.),{},"C",AllTrim(X3Picture("ABS_DESENT")),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("TFL_TOTRH" ,"09",TecTituDes("TFL_TOTRH" ,.T.),TecTituDes("TFL_TOTRH" ,.F.),{},"N",AllTrim(X3Picture("TFL_TOTRH" )),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("TFL_TOTMI" ,"10",TecTituDes("TFL_TOTMI" ,.T.),TecTituDes("TFL_TOTMI" ,.F.),{},"N",AllTrim(X3Picture("TFL_TOTMI" )),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("TFL_TOTMC" ,"11",TecTituDes("TFL_TOTMC" ,.T.),TecTituDes("TFL_TOTMC" ,.F.),{},"N",AllTrim(X3Picture("TFL_TOTMC" )),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)
oStrTWB:AddField("TFL_TOTLE" ,"12",TecTituDes("TFL_TOTLE" ,.T.),TecTituDes("TFL_TOTLE" ,.F.),{},"N",AllTrim(X3Picture("TFL_TOTLE" )),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/)

oStrTFW:SetProperty("TFW_APURAC" ,MVC_VIEW_ORDEM,"01")
oStrTFW:SetProperty("TFW_NUMMED" ,MVC_VIEW_ORDEM,"02")
oStrTFW:SetProperty("TFW_ITMED"  ,MVC_VIEW_ORDEM,"03")
oStrTFW:SetProperty("TFW_CODIGO" ,MVC_VIEW_ORDEM,"04")
oStrTFW:SetProperty("TFW_CODTFF" ,MVC_VIEW_ORDEM,"05")
oStrTFW:SetProperty("TFW_VLRMED" ,MVC_VIEW_ORDEM,"10")
oStrTFW:AddField("TFF_PRODUT","06",TecTituDes("TFF_PRODUT",.T.),TecTituDes("TFF_PRODUT",.F.),{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/ )
oStrTFW:AddField("TFF_DESCRI","07",TecTituDes("TFF_DESCRI",.T.),TecTituDes("TFF_DESCRI",.F.),{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/ )
oStrTFW:AddField("TDW_DESC"  ,"08",TecTituDes("TDW_DESC"  ,.T.),TecTituDes("TDW_DESC"  ,.F.),{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/ )
oStrTFW:AddField("TFF_VLRCOB","09",TecTituDes("TFF_VLRCOB",.T.),TecTituDes("TFF_VLRCOB",.F.),{},"N",AllTrim(X3Picture("TFF_VLRCOB")),/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,.T.,/*cPictVar*/,/*lInsertLine*/ )

oView:SetModel(oModel)

oView:AddField("VIEW_MASTER", oStrTFV, "TFVMASTER")
oView:AddGrid("VIEW_LOCAL",   oStrTWB, "TWBDETAIL")
oView:AddGrid("VIEW_RECHM",   oStrTFW, "TFWDETAIL")
oView:AddGrid("VIEW_MI"   ,   oStrTFX, "TFXDETAIL")
oView:AddGrid("VIEW_MC"   ,   oStrTFY, "TFYDETAIL")

oView:SetDescription("Apuração / Medição de Contratos")

oView:CreateHorizontalBox("TOP",   30)
oView:CreateHorizontalBox("MIDDLE",70)

oView:CreateFolder("ABAS","MIDDLE")
oView:AddSheet("ABAS","ABA01","Locais de Atendimento")
oView:AddSheet("ABAS","ABA02","Recursos Humanos")

oView:CreateHorizontalBox("ID_ABA01" ,100,,,"ABAS","ABA01") // Define a área de Locais
oView:CreateHorizontalBox("ID_ABA02" ,060,,,"ABAS","ABA02") // Define a área de RH
oView:CreateHorizontalBox("ID_ABA02A",040,,,"ABAS","ABA02") // área dos acionais relacionados com RH

oView:CreateFolder("RH_ABAS","ID_ABA02A")
oView:AddSheet("RH_ABAS","RH_ABA02","Materiais de Implantação")
oView:AddSheet("RH_ABAS","RH_ABA03","Materiais de Consumo")

oView:CreateHorizontalBox("ID_RH_02",100,,,"RH_ABAS","RH_ABA02") // Define a área de Materiais de Implantação
oView:CreateHorizontalBox("ID_RH_03",100,,,"RH_ABAS","RH_ABA03") // Define a área de Materiais de Consumo

oView:SetOwnerView("VIEW_MASTER", "TOP") // Cabeçalho
oView:SetOwnerView("VIEW_LOCAL" , "ID_ABA01") // Grid Locais
oView:SetOwnerView("VIEW_RECHM" , "ID_ABA02") // Grid RH
oView:SetOwnerView("VIEW_MI"    , "ID_RH_02") // Grid Materiais de Implantação
oView:SetOwnerView("VIEW_MC"    , "ID_RH_03") // Grid Materiais de Consumo

Return(oView)

//----------------------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oMdlGer)
Local oMdlTFV := Nil //CABEÇALHO
Local oMdlTWB := Nil //LOCAL DE ATENDIMENTO
Local oMdlTFW := Nil //RECURSOS HUMANOS
Local oMdlTFX := Nil //MATERIAL IMPLANTAÇÃO
Local oMdlTFY := Nil //MATERIAL CONSUMO
Local aArea := GetArea()
Local aAreaTFL := TFL->( GetArea() )
Local aArTFL	:= {}
Local lOk := .T.
Local lValImp := .F.
Local lCliFat	:= .F.
Local cAbsCliFat:= ""
Local cAbsLojfat:= ""

If oMdlGer:GetOperation() == 3
	//Seta os modelos nas variáveis:
	oMdlTFV := oMdlGer:GetModel("TFVMASTER")
	oMdlTWB := oMdlGer:GetModel("TWBDETAIL")
	oMdlTFW := oMdlGer:GetModel("TFWDETAIL")
	oMdlTFX := oMdlGer:GetModel("TFXDETAIL")
	oMdlTFY := oMdlGer:GetModel("TFYDETAIL")

	//Permite edição das linhas:
	oMdlTWB:SetNoInsertLine(.F.)
	oMdlTFW:SetNoInsertLine(.F.)
	oMdlTFX:SetNoInsertLine(.F.)
	oMdlTFY:SetNoInsertLine(.F.)

	//Carrega dados do Cabeçalho:
	cRevCtr := Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")
	DbSelectArea("TFJ")
	TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL + TFJ_CONTRT + TFJ_CONREV
	TFJ->( DbSeek( xFilial("TFJ") + MV_PAR01 + cRevCtr ) )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_CONTRT", MV_PAR01  )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_REVISA", cRevCtr   )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_DTINI" , MV_PAR02  )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_DTFIM" , MV_PAR03  )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_DTAPUR", dDataBase )
	lOk := lOk .And. oMdlTFV:SetValue( "TFV_ANTECI", If( TFJ->TFJ_ANTECI=="1", "1", "2" ) )

	//Carrega Locais de Atendimento:
	DbSelectArea("TFL")
	TFL->(DbSetOrder(4)) //TFL_FILIAL+TFL_CONTRT+TFL_CONREV
	If TFL->(DbSeek(xFilial("TFL")+MV_PAR01+cRevCtr))
		DbSelectArea("CNA")
		CNA->(DbSetOrder( 1 )) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

		TFJ->( DbSetOrder(1) ) // TFJ_FILIAL+TFJ_CODIGO
		lValImp := TFJ->(DbSeek(xFilial("TFJ")+TFL->TFL_CODPAI)) .And. ; // posiciona no cabeçalho do orçamento de serviços
						!Empty(TFJ->TFJ_TABXML) .OR. !Empty(TFJ->TFJ_CODTAB)  // verifica se é orçamento com precificação

		While TFL->(!EOF()) .And. TFL->TFL_FILIAL == xFilial("TFL") .And. TFL->TFL_CONTRT == MV_PAR01 .And. TFL->TFL_CONREV == cRevCtr .And. lOk
			aArTFL := TFL->(GetArea())
			lCliFat := .F.
			If !Empty( oMdlTWB:GetValue("TWB_CODTFL") )
				// verifica se foi possível adicionar nova linha, caso não consiga
				// aborta o preenchimento do grid
				If oMdlTWB:Length()+1 <> oMdlTWB:AddLine()
					// lOk := .F.
					// Exit
				EndIf
			EndIf
			RestArea(aArTFL)
			//lOk := lOk .And. oMdlTWB:SetValue("TWB_COD"   , at930DCod("TWB","TWB_COD"))
			If Empty( oMdlTWB:GetValue("TWB_COD") )
				lOk := lOk .And. oMdlTWB:SetValue("TWB_COD", CriaVar("TWB_COD"))
			EndIf
			lOk := lOk .And. oMdlTWB:LoadValue("TWB_CODTFV", oMdlTFV:GetValue("TFV_CODIGO")) // LoadValue para não exec. X3_VALID
			lOk := lOk .And. oMdlTWB:SetValue("TWB_CODTFL", TFL->TFL_CODIGO)
			lOk := lOk .And. oMdlTWB:SetValue("TWB_CODABS", TFL->TFL_LOCAL)
			lOk := lOk .And. oMdlTWB:SetValue("ABS_DESCRI", ALLTRIM(Posicione("ABS", 1, xFilial("ABS")+TFL->TFL_LOCAL, "ABS_DESCRI")))

			cAbsCliFat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_CLIFAT")
			cAbsLojfat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_LJFAT")

			If !Empty(Alltrim(cAbsCliFat)) .AND. !Empty(Alltrim(cAbsLojfat))
				cQuery := " SELECT 1 R_E_C_N_O_ "
				cQuery += " FROM   "+RetSqlName("CNC")+" CNC "
				cQuery += " WHERE  CNC.CNC_FILIAL = '"+xFilial("CNC")+"' "
				cQuery += " AND    CNC.CNC_NUMERO = '"+MV_PAR01+"' "
				cQuery += " AND    CNC.CNC_REVISA = '"+cRevCtr+"' "
				cQuery += " AND    CNC.CNC_CLIENT = '"+cAbsCliFat+"' "
				cQuery += " AND    CNC.CNC_LOJACL = '"+cAbsLojfat+"' "
				cQuery += " AND    CNC.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				cAliasCNC := GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNC,.T.,.T.)
				If (cAliasCNC)->(!EOF())
					lCliFat:= .T.
				EndIf
				(cAliasCNC)->(DbCloseArea())
			EndIf

			If lCliFat
				lOk := lOk .And. oMdlTWB:SetValue("ABS_CODIGO", cAbsCliFat)
				lOk := lOk .And. oMdlTWB:SetValue("ABS_LOJA"  , cAbsLojfat)
				lOk := lOk .And. oMdlTWB:SetValue("ABS_DESENT", ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+cAbsCliFat+cAbsLojfat,"A1_NOME")))
			Else
				If CNA->(DbSeek(xFilial("CNA")+MV_PAR01+cRevCtr+TFL->TFL_PLAN))
					lOk := lOk .And. oMdlTWB:SetValue("ABS_CODIGO", CNA->CNA_CLIENT)
					lOk := lOk .And. oMdlTWB:SetValue("ABS_LOJA"  , CNA->CNA_LOJACL)
					lOk := lOk .And. oMdlTWB:SetValue("ABS_DESENT", ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+CNA->CNA_CLIENT+CNA->CNA_LOJACL,"A1_NOME")))
				EndIf
			EndIf

			lOk := lOk .And. oMdlTWB:SetValue("TFL_TOTRH", TFL->TFL_TOTRH)
			lOk := lOk .And. oMdlTWB:SetValue("TFL_TOTMI", TFL->TFL_TOTMI)
			lOk := lOk .And. oMdlTWB:SetValue("TFL_TOTMC", TFL->TFL_TOTMC)

			If lOk 
				lOk := At930DCaRH(oMdlGer, TFL->TFL_CODIGO)
			EndIf

			RestArea(aArTFL)
			TFL->(DbSkip())
		EndDo
	EndIf

	If !lOk //Apresenta mensagem de erro:
		// AtErroMvc(oMdlGer)
		// MostraErro()
	EndIf

	//Permite edição das linhas:
	oMdlTWB:SetNoInsertLine(.T.)
	oMdlTFW:SetNoInsertLine(.T.)
	oMdlTFX:SetNoInsertLine(.T.)
	oMdlTFY:SetNoInsertLine(.T.)	

EndIf
RestArea(aAreaTFL)
RestArea(aArea)
Return

// Static Function At930DResLoc( oMdl, cNumCtr, cRevCtr )

// Local oMdlTFL := oMdl:GetModel("TWBDETAIL")
// Local aArea := GetArea()
// Local aAreaTFL := TFL->( GetArea() )
// Local aArTFL	:= {}
// Local lOk := .T.
// Local nValImp := 0
// Local lValImp := .F.
// Local lCliFat	:= .F.
// Local cAbsCliFat:= ""
// Local cAbsLojfat:= ""

// DbSelectArea("TFL")
// TFL->(DbSetOrder(4)) //TFL_FILIAL+TFL_CONTRT+TFL_CONREV
// If TFL->(DbSeek(xFilial("TFL")+cNumCtr+cRevCtr))

// 	DbSelectArea("CNA")
// 	CNA->(DbSetOrder( 1 )) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

// 	TFJ->( DbSetOrder(1) ) // TFJ_FILIAL+TFJ_CODIGO
// 	lValImp := TFJ->(DbSeek(xFilial("TFJ")+TFL->TFL_CODPAI)) .And. ; // posiciona no cabeçalho do orçamento de serviços
// 					!Empty(TFJ->TFJ_TABXML) .OR. !Empty(TFJ->TFJ_CODTAB)  // verifica se é orçamento com precificação

// 	While TFL->(!EOF()) .And. TFL->TFL_FILIAL == xFilial("TFL") .And. TFL->TFL_CONTRT == cNumCtr .And. TFL->TFL_CONREV == cRevCtr
// 		aArTFL := TFL->(GetArea())
// 		lCliFat := .F.
// 		If !Empty( oMdlTFL:GetValue("TWB_CODTFL") )
// 			// verifica se foi possível adicionar nova linha, caso não consiga aborta o preenchimento do grid
// 			If oMdlTFL:Length()+1 <> oMdlTFL:AddLine()
// 				lOk := .F.
// 				Exit
// 			EndIf
// 		EndIf

// 		lOk := lOk .And. oMdlTFL:SetValue("TWB_CODTFL", TFL->TFL_CODIGO)
// 		lOk := lOk .And. oMdlTFL:SetValue("TWB_CODABS", TFL->TFL_LOCAL)
// 		lOk := lOk .And. oMdlTFL:SetValue("ABS_DESCRI", ALLTRIM(Posicione("ABS", 1, xFilial("ABS")+TFL->TFL_LOCAL, "ABS_DESCRI")))

// 		If lOk
// 			cAbsCliFat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_CLIFAT")
// 			cAbsLojfat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_LJFAT")

// 			If !Empty(Alltrim(cAbsCliFat)) .AND. !Empty(Alltrim(cAbsLojfat))
// 				cQuery := " SELECT 1 R_E_C_N_O_ "
// 				cQuery += " FROM   "+RetSqlName("CNC")+" CNC "
// 				cQuery += " WHERE  CNC.CNC_FILIAL = '"+xFilial("CNC")+"' "
// 				cQuery += " AND    CNC.CNC_NUMERO = '"+cNumCtr+"' "
// 				cQuery += " AND    CNC.CNC_REVISA = '"+cRevCtr+"' "
// 				cQuery += " AND    CNC.CNC_CLIENT = '"+cAbsCliFat+"' "
// 				cQuery += " AND    CNC.CNC_LOJACL = '"+cAbsLojfat+"' "
// 				cQuery += " AND    CNC.D_E_L_E_T_ = '' "
// 				cQuery := ChangeQuery(cQuery)
// 				cAliasCNC := GetNextAlias()
// 				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNC,.T.,.T.)
// 				If (cAliasCNC)->(!EOF())
// 					lCliFat:= .T.
// 				EndIf
// 				(cAliasCNC)->(DbCloseArea())
// 			EndIf

// 			If lCliFat
// 				lOk := lOk .And. oMdlTFL:SetValue("ABS_CODIGO", cAbsCliFat)
// 				lOk := lOk .And. oMdlTFL:SetValue("ABS_LOJA"  , cAbsLojfat)
// 				lOk := lOk .And. oMdlTFL:SetValue("ABS_DESENT", ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+cAbsCliFat+cAbsLojfat,"A1_NOME")))
// 			Else
// 				If CNA->(DbSeek(xFilial("CNA")+cNumCtr+cRevCtr+TFL->TFL_PLAN))
// 					lOk := lOk .And. oMdlTFL:SetValue("ABS_CODIGO", CNA->CNA_CLIENT)
// 					lOk := lOk .And. oMdlTFL:SetValue("ABS_LOJA"  , CNA->CNA_LOJACL)
// 					lOk := lOk .And. oMdlTFL:SetValue("ABS_DESENT", ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+CNA->CNA_CLIENT+CNA->CNA_LOJACL,"A1_NOME")))
// 				EndIf
// 			EndIf
// 		EndIf

// 		lOk := lOk .And. oMdlTFL:SetValue("TFL_TOTRH", TFL->TFL_TOTRH)
// 		lOk := lOk .And. oMdlTFL:SetValue("TFL_TOTMI", TFL->TFL_TOTMI)
// 		lOk := lOk .And. oMdlTFL:SetValue("TFL_TOTMC", TFL->TFL_TOTMC)

// 		If lOk
// 			lOk := At930DCaRH(oMdl, TFL->TFL_CODIGO)
// 		Else // aborta o preenchimento na identificação de qlq erro
// 			AtErroMvc(oMdl)
// 			MostraErro()
// 			Exit
// 		EndIf
// 		RestArea(aArTFL)
//         TFL->(DbSkip())
//     EndDo
// EndIf

// RestArea(aAreaTFL)
// RestArea(aArea)

// Return(Nil)


//------------------------------------------------------------------------------------------------------------------------------------
Static Function At930DCaRH(oMdl, cCodTFL)
Local oMdlTFV := oMdl:GetModel("TFVMASTER")
Local oMdlTFF := oMdl:GetModel("TFWDETAIL")
Local aArTFF  := {}
Local lOk     := .T.
Local descProd:= ""
Local escala  := ""

cApurac	 := oMdlTFV:GetValue("TFV_CODIGO")

DbSelectArea("TFF")
TFF->(DbSetOrder(3)) //TFF_FILIAL+TFF_CODPAI+TFF_ITEM                                                                                                                                  
If TFF->(DbSeek(xFilial("TFF")+cCodTFL))

	While TFF->(!EOF()) .And. TFF->TFF_FILIAL == xFilial("TFF") .And. TFF->TFF_CODPAI == cCodTFL .And. lOk
		aArTFF := TFF->(GetArea())
		If !Empty( oMdlTFF:GetValue("TFW_CODTFL") )
			// verifica se foi possível adicionar nova linha, caso não consiga aborta o preenchimento do grid
			If oMdlTFF:Length()+1 <> oMdlTFF:AddLine()
				// lOk :.F.
				// Exit
			EndIf
		EndIf
		descProd:= AllTrim(Posicione("SB1", 1, xFilial("SB1")+TFF->TFF_PRODUT, "B1_DESC"))
		escala  := AllTrim(Posicione("TDW", 1, xFilial("TDW")+TFF->TFF_ESCALA, "TDW_DESC"))
		RestArea(aArTFF)
		lOk := lOk .And. oMdlTFF:SetValue("TFW_CODIGO", at930DCod())
		lOk := lOk .And. oMdlTFF:SetValue("TFW_APURAC", oMdlTFV:GetValue("TFV_CODIGO"))
		lOk := lOk .And. oMdlTFF:SetValue("TFW_CODTFL", cCodTFL)
		lOk := lOk .And. oMdlTFF:SetValue("TFW_CODTFF", TFF->TFF_COD)
		lOk := lOk .And. oMdlTFF:SetValue("TFF_PRODUT", TFF->TFF_PRODUT)
		lOk := lOk .And. oMdlTFF:SetValue("TFF_DESCRI", descProd)
		lOk := lOk .And. oMdlTFF:SetValue("TDW_DESC" , escala)
		lOk := lOk .And. oMdlTFF:SetValue("TFF_VLRCOB", TFF->TFF_VLRCOB)
		lOk := lOk .And. oMdlTFF:SetValue("TFW_VLRMED", TFF->TFF_VLRCOB)
		lOk := lOk .And. oMdlTFF:SetValue("TFW_VLRCON", TFF->TFF_VLRCOB)
		If lOk
			lOk := At930DLoadMat(oMdl, TFF->TFF_COD, cCodTFL)
		EndIf

		RestArea(aArTFF)
		TFF->(DbSkip())
	EndDo
EndIf

Return(lOk)

Static Function At930DLoadMat(oMdl, cCodTFF, cCodTFL)
Local oMdlTFV	:= oMdl:GetModel("TFVMASTER")
Local oMdlTFX	:= oMdl:GetModel("TFXDETAIL")
Local oMdlTFY	:= oMdl:GetModel("TFYDETAIL")
//Local oMdlTWB	:= oMdl:GetModel("TWBDETAIL")
Local cAliasMI	:= GetNextAlias()
Local cAliasMC	:= GetNextAlias()
Local cContrato := ""
Local cRevisao	:= ""
Local lOk		:= .T.
//Local nTotMI	:= 0
//Local nTotMC	:= 0

cApurac	 := oMdlTFV:GetValue("TFV_CODIGO")
cContrato:= oMdlTFV:GetValue("TFV_CONTRT")
cRevisao := oMdlTFV:GetValue("TFV_REVISA")
cDataIni := DtoS(MV_PAR03)
cDataFim := DtoS(MV_PAR02)

//Materiais de Implantação:
BeginSql Alias cAliasMI
	SELECT TFG.TFG_COD, TFG.TFG_ITEM, TFG.TFG_PRODUT, TFG.TFG_VLPRPA
		FROM %table:TFG% TFG
		WHERE TFG.TFG_FILIAL = %xFilial:TFG%
			AND TFG.TFG_CONTRT = %Exp:cContrato%
			AND TFG.TFG_CONREV = %Exp:cRevisao%
			AND TFG.TFG_CODPAI = %Exp:cCodTFF%
			AND TFG.TFG_COBCTR <> '2'
			AND TFG.TFG_PERINI <= %Exp:cDataIni%
			AND TFG.TFG_PERFIM >= %Exp:cDataFim%
			AND TFG.%NotDel%
EndSql
While (cAliasMI)->(!EOF()) .And. lOk
	If !Empty( oMdlTFX:GetValue("TFX_CODTFG") )
		// verifica se foi possível adicionar nova linha, caso não consiga aborta o preenchimento do grid
		If oMdlTFX:Length()+1 <> oMdlTFX:AddLine()
			// lOk := .F.
			// Exit
		EndIf
	EndIf
	lOk := lOk .And. oMdlTFX:SetValue("TFX_CODIGO", GetSXENum( "TFX","TFX_CODIGO"))
	lOk := lOk .And. oMdlTFX:SetValue("TFX_APURAC", cApurac) //Apuração GS
	lOk := lOk .And. oMdlTFX:SetValue("TFX_NUMMED", cApurac) //Medição CNTA121
	lOk := lOk .And. oMdlTFX:SetValue("TFX_ITMED" , TFG->TFG_ITEM)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_CODTFL", cCodTFL)
	// lOk := lOk .And. oMdlTFX:SetValue("TFX_TOTMUL", 0)
	// lOk := lOk .And. oMdlTFX:SetValue("TFX_TOTDES", 0)
	// lOk := lOk .And. oMdlTFX:SetValue("TFX_TOTBON", 0)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_VLRAPU", TFG->TFG_VLPRPA)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_VLRCON", TFG->TFG_VLPRPA)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_CODTFG", TFG->TFG_COD)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_VLRMED", TFG->TFG_VLPRPA)
	lOk := lOk .And. oMdlTFX:SetValue("TFX_CODTFF", cCodTFF)
	//nTotMI += TFG->TFG_VLPRPA

	(cAliasMI)->(DbSkip())
EndDo
(cAliasMI)->(DbCloseArea())

//Materiais de Consumo:
BeginSql Alias cAliasMC
	SELECT TFH.TFH_COD, TFH.TFH_ITEM, TFH.TFH_PRODUT, TFH.TFH_VLPRPA
		FROM %table:TFH% TFH
		WHERE TFH.TFH_FILIAL = %xFilial:TFH%
			AND TFH.TFH_CONTRT = %Exp:cContrato%
			AND TFH.TFH_CONREV = %Exp:cRevisao%
			AND TFH.TFH_CODPAI = %Exp:cCodTFF%
			AND TFH.TFH_COBCTR <> '2'
			AND TFH.TFH_PERINI <= %Exp:cDataIni%
			AND TFH.TFH_PERFIM >= %Exp:cDataFim%
			AND TFH.%NotDel%
EndSql
While (cAliasMC)->(!EOF()) .And. lOk
	If !Empty( oMdlTFY:GetValue("TFY_CODTFH") )
		// verifica se foi possível adicionar nova linha, caso não consiga aborta o preenchimento do grid
		If oMdlTFY:Length()+1 <> oMdlTFY:AddLine()
			// lOk := .F.
			// Exit
		EndIf
	EndIf
	lOk := lOk .And. oMdlTFY:SetValue("TFY_CODIGO", GetSXENum( "TFY","TFY_CODIGO"))
	lOk := lOk .And. oMdlTFY:SetValue("TFY_APURAC", cApurac) //Apuração GS
	lOk := lOk .And. oMdlTFY:SetValue("TFY_NUMMED", cApurac) //Medição CNTA121
	lOk := lOk .And. oMdlTFY:SetValue("TFY_ITMED" , TFH->TFH_ITEM)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_CODTFL", cCodTFL)
	// lOk := lOk .And. oMdlTFY:SetValue("TFY_TOTMUL", 0)
	// lOk := lOk .And. oMdlTFY:SetValue("TFY_TOTDES", 0)
	// lOk := lOk .And. oMdlTFY:SetValue("TFY_TOTBON", 0)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_VLRAPU", TFH->TFH_VLPRPA)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_VLRCON", TFH->TFH_VLPRPA)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_CODTFH", TFH->TFH_COD)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_VLRMED", TFH->TFH_VLPRPA)
	lOk := lOk .And. oMdlTFY:SetValue("TFY_CODTFF", cCodTFF)
	//nTotMC += TFH->TFH_VLPRPA

	(cAliasMC)->(DbSkip())
EndDo
(cAliasMC)->(DbCloseArea())

//lOk := lOk .And. oMdlTWB:SetValue("TFL_TOTMC", nTotMC)
//lOk := lOk .And. oMdlTWB:SetValue("TFL_TOTMI", nTotMI)

Return lOk


// Static Function At930TotHr(cCodABB,lHrExtr)
// Local cAliasABB := ""
// Local nTotRet	:= 0
// Local cQuery	:= ""

// cQuery := " SELECT ABB.ABB_HRTOT, COALESCE(ABR.ABR_TEMPO,'') ABR_TEMPO "
// cQuery += " FROM " + RetSQLName("ABB") + " ABB "
// cQuery += " LEFT JOIN " + RetSQLName("ABR") + " ABR ON "
// cQuery += " ABR.ABR_FILIAL = '" + xFilial("ABR") + "' "
// cQuery += " AND ABR.ABR_AGENDA = ABB.ABB_CODIGO "
// cQuery += " AND ABR.D_E_L_E_T_ = ' ' "
// cQuery += " WHERE ABB.ABB_CODIGO = '"+cCodABB+"' "
// cQuery += " AND ABB.ABB_FILIAL = '" + xFilial("ABB")+"' "
// cQuery += " AND ABB.ABB_CHEGOU = 'S' "
// cQuery += " AND ABB.ABB_ATENDE = '1' "
// cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

// cQuery := ChangeQuery(cQuery)

// cAliasABB := GetNextAlias()

// DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasABB, .T., .T.)

// While (cAliasABB)->(!Eof())
// 	If lHrExtr
// 		If !Empty((cAliasABB)->ABR_TEMPO)
// 			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
// 		Endif
// 	Else
// 		If Empty((cAliasABB)->ABR_TEMPO)
// 			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
// 		Else
// 			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
// 		Endif
// 	Endif
// 	(cAliasABB)->(dbSkip())
// EndDo

// (cAliasABB)->(DbCloseArea())

// Return nTotRet

Static Function At930dTotais(cField)
Local nRet := Posicione("TFL", 1, xFilial("TFL")+TWB->TWB_CODTFL, cField)
Return nRet

Static Function At930dCliLoc(cField)
Local cCodigo := ""
Local cCodLoc := ""
Local cDescri := ""

cCodigo := TWB->TWB_CODTFL
cCodLoc := Posicione("TFL", 1, xFilial("TFL")+cCodigo, "TFL_LOCAL")
ABS->(dbSelectArea("ABS"))
If ABS->(dbSeek(xFilial("SA1")+cCodLoc))
    cDescri := ALLTRIM( POSICIONE('SA1',1,XFILIAL('SA1')+ABS->ABS_CODIGO+ABS->ABS_LOJA,'A1_NOME') )
EndIf

Return cDescri

Static Function At930dLocal(cField)
Local cCodigo := ""
Local cCodLoc := ""
Local cDescri := ""

cCodigo := TWB->TWB_CODTFL
cCodLoc := Posicione("TFL", 1, xFilial("TFL")+cCodigo, "TFL_LOCAL")
cDescri := Posicione("ABS", 1, xFilial("ABS")+cCodLoc, cField)
Return cDescri

Static Function At930dRecHm(cField)
Local xRet := Posicione("TFF", 1, xFilial("TFF")+TFW->TFW_CODTFF, cField)
Return xRet

Static Function At930dProdRh(cField)
Local cCodigo := ""
Local cCodRec := ""
Local cDescri := ""

cCodigo := TFW->TFW_CODTFF
cCodRec := Posicione("TFF", 1, xFilial("TFF")+cCodigo, "TFF_PRODUT")
cDescri := Posicione("SB1", 1, xFilial("SB1")+cCodRec, cField)
Return cDescri

Static Function At930dEscRh(cField)
Local cCodigo := ""
Local cCodRec := ""
Local cDescri := ""

cCodigo := TFW->TFW_CODTFF
cCodRec := Posicione("TFF", 1, xFilial("TFF")+cCodigo, "TFF_ESCALA")
cDescri := Posicione("TDW", 1, xFilial("TDW")+cCodRec, cField)

Return cDescri

/*

Parâmetro MV_ORCPRC = Não
Novo parâmentro para ativar nova Medição
Validação do Contrato: Fixo=Não
Novo Pergunte para selecionar Contrato e Periodo

Agrup Med = 1-Sim

*/
Function At930dGerMed(cAlias, nReg, nOpc)
Local nOperacao := If(nOpc == 3, MODEL_OPERATION_INSERT, MODEL_OPERATION_DELETE)

If Pergunte("TEC930",.T.)
    MsgRun( "Processando Apuração", "Aguarde...", {|| FWExecView("Geração","VIEWDEF.TECA930D",nOperacao,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) } )
EndIf

Return

Function At930DRun(oMdl930D, oSay)
Local lRet := .T.
FwMsgRun(Nil,{|oSay| lRet := At930DCmt(oMdl930D,oSay)}, "Processando", "Gerando apuração do Contrato...") //"Processando", "Gerando apuração do Contrato..."
	//MsgRun( "Processando Apuração", "Aguarde...", {|| lRet := At930DCmt(oMdl930D) } )
Return lRet

Function At930DCmt(oMdl930D, oSay)
Local cCodCTR	:= ""
Local cCodRev	:= ""
Local aMsgDeErro:= {}
Local lRet      := .T. 
Local nX        := 0
Local oModel    := Nil
Local oMdlTFV	:= oMdl930D:GetModel("TFVMASTER")

cCodCTR	:= oMdlTFV:GetValue("TFV_CONTRT")
cCodRev	:= oMdlTFV:GetValue("TFV_REVISA")

CN9->(DbSetOrder(1))
        
If CN9->(DbSeek(xFilial("CN9") + cCodCTR + cCodRev))//Posicionar na CN9 para realizar a inclusão

	Begin Transaction

		oModel := FWLoadModel("CNTA121")
		
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If(oModel:CanActivate())           
			oModel:Activate()
			oModel:SetValue("CNDMASTER", "CND_CONTRA", cCodCTR)
			oModel:SetValue("CNDMASTER", "CND_COMPET", MV_PAR04)//Selecionar competência
				
			For nX := 1 To oModel:GetModel("CXNDETAIL"):Length()
			oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)//Marcar a planilha(nesse caso apenas uma)           
			Next nX 
				
			If (oModel:VldData()) /*Valida o modelo como um todo*/
				oModel:CommitData()
			EndIf
		EndIf
			
		If(oModel:HasErrorMessage())
			aMsgDeErro := oModel:GetErrorMessage()
			If Len(aMsgDeErro) > 5
				oMdl930D:SetErrorMessage(aMsgDeErro[1],aMsgDeErro[2],aMsgDeErro[3], aMsgDeErro[4],aMsgDeErro[5],aMsgDeErro[6])
			EndIf
			lRet := .F.
		Else
			oModel:DeActivate()        
			lRet := CN121Encerr(.T.) //Realiza o encerramento da medição                   
		EndIf

	End Transaction
	
	If lRet
		FWFormCommit(oMdl930D)
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} at930DCod

/*/
//--------------------------------------------------------------------------------
Function at930DCod()
Local aArea		:= GetArea()
Local aAreaTFW	:= TFW->(GetArea())
Local cCodTFW	:= ""

dbSelectArea("TFW")
dbSetOrder(1)
dbGoTop()

cCodTFW:= GetSXENum("TFW","TFW_CODIGO",,1)

While TFW->( DbSeek(xFilial("TFW")+cCodTFW) )
	If ( __lSx8 )
		ConfirmSX8()
	EndIf
	cCodTFW:= GetSXENum("TFW","TFW_CODIGO",,1)
EndDo

RestArea(aAreaTFW)
RestArea(aArea)

Return cCodTFW
