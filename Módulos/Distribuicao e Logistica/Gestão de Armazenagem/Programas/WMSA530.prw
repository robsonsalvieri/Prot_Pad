#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'WMSA530.CH'
#INCLUDE "FWEDITPANEL.CH"

#DEFINE WMSA53001 "WMSA53001"
#DEFINE WMSA53002 "WMSA53002"
#DEFINE WMSA53003 "WMSA53003"
#DEFINE WMSA53004 "WMSA53004"
#DEFINE WMSA53005 "WMSA53005"
#DEFINE WMSA53006 "WMSA53006"
#DEFINE WMSA53007 "WMSA53007"
#DEFINE WMSA53008 "WMSA53008"
#DEFINE WMSA53009 "WMSA53009"
#DEFINE WMSA53010 "WMSA53010"

Static lExistUnit := WmsX312118('D14','D14_IDUNIT')
//--------------------------------------------------
/*/{Protheus.doc} WMSA530
(long_description)
@author felipe.m
@since 26/03/2015
@version 1.0
/*/
//--------------------------------------------------
Function WMSA530()
Local oBrw

Private lOperInsert := .F.
Private lOperDelete := .F.
Private lD14SemSB8  := .F.

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("D0A")
	oBrw:SetDescription(STR0001) // Troca de Lotes
	oBrw:SetFilterDefault("@ D0A_PROCES = '3'")
	oBrw:Activate()
Return Nil

//--------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "WMSA530MEN(2)" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "WMSA530MEN(3)" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "WMSA530MEN(4)" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
Return aRotina
//---------------------------------------------------------
Function WMSA530MEN(nPos)
Local lRet       := .T.
Local aRotina    := MenuDef()
Local nOperation := 0
	nOperation  := aRotina[nPos][4]
	lOperInsert := .F.
	lOperDelete := .F.

	If nOperation == MODEL_OPERATION_INSERT
		lRet := Pergunte("WMSA530",.T.)		
		If lRet
			lRet := A530VldPrd() .And. A510VldPrd(.F.) .And. A530VldArm()
		EndIf
		lOperInsert := .T.
		If !D14SemSB8(MV_PAR01, MV_PAR02)			
			lRet := .F.
		EndIf
		
	ElseIf nOperation == MODEL_OPERATION_DELETE
		lRet := A510VldOS()
		lOperDelete := .T.
		If lRet
			If SB8SemLote(D0A->D0A_LOCAL, D0A->D0A_PRODUT)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return Iif(lRet,FWExecView(aRotina[nPos][1],"WMSA530",nOperation,,{ || .T. },{ || .T. },0,,{ || .T. },,, ),.F.)
//--------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------
Static Function ModelDef()
Local oModel
Local oStrD0A  := FWFormStruct(1,"D0A")
Local oStrD0B  := FWFormStruct(1,"D0B")
Local oStrD14  := FWFormModelStruct():New()
Local oStrLote := FWFormModelStruct():New()
Local bValid   := { |a,cField,xVal,nLine,xValAnt| ValidField(oModel,cField,xVal,nLine,xValAnt) }
Local aColsSx3 := {}
Local cDocto := ""

	oStrD0A:SetProperty("D0A_DOC"   ,MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("DCF","DCF_DOCTO"),IIf(__lSX8,ConfirmSX8(),),cDocto })
	oStrD0A:SetProperty('D0A_DTMOV' ,MODEL_FIELD_INIT,{|| dDataBase })
	oStrD0A:SetProperty('D0A_ENDER' ,MODEL_FIELD_VALID,bValid)
	oStrD0A:SetProperty('D0A_MOVAUT',MODEL_FIELD_INIT ,FWBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))
	oStrD0A:SetProperty('D0A_MOVAUT',MODEL_FIELD_WHEN ,FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
	oStrD0A:SetProperty('D0A_ENDER' ,MODEL_FIELD_WHEN ,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))

	oModel := MPFormModel():New("WMSA530",,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	oModel:AddFields("A530D0A",,oStrD0A)
	oModel:SetDescription(STR0001) // Troca de Lotes
	oModel:GetModel("A530D0A"):SetDescription(STR0001) // Troca de Lotes
	oModel:AddGrid("A530D0B","A530D0A",oStrD0B)
	oModel:SetRelation("A530D0B", {{"D0B_FILIAL","xFilial('D0B')"},{"D0B_DOC","D0A_DOC"}} )
	oModel:GetModel("A530D0B"):SetOptional(.T.)
	// cTitulo,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid
	buscarSX3("D14_LOTECT",,aColsSX3)
	oStrLote:AddField(aColsSX3[1],"","LOTECT","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStrLote:AddField(aColsSX3[1],"","LOTVIS","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_NUMLOT",,aColsSX3)
	oStrLote:AddField(aColsSX3[1],"","NUMLOT","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_DTVALD",,aColsSX3)
	oStrLote:AddField(aColsSX3[1],"","DTVALD","D",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_DTFABR",,aColsSX3)
	oStrLote:AddField(aColsSX3[1],"","DTFABR","D",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_NUMSER",,aColsSX3)
	oStrLote:AddField(aColsSX3[1],"","NUMSER","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrLote:AddField(STR0010,"","QTDEST","N",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.) //Qtd. Saldo.
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrLote:AddField(STR0011,"","QTDMOV","N",aColsSX3[3],aColsSX3[4],bValid,{||.T.},Nil,.F.,,.F.,.F.,.F.) //Qtd. Movimento
	oStrLote:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddGrid("A530LOTE","A530D0A",oStrLote)
	oModel:GetModel("A530LOTE"):SetOptional(.T.)
	oModel:GetModel("A530LOTE"):SetDescription(STR0025) // Lotes

	buscarSX3("D14_LOCAL",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_LOCAL","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_ENDER",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_ENDER","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	If lExistUnit
		oStrD14:AddField(buscarSX3("D14_IDUNIT",,aColsSX3),aColsSX3[1],"D14_IDUNIT","C",aColsSX3[3],aColsSX3[4],Nil   ,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	EndIf
	buscarSX3("D14_PRODUT",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_PRODUT","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_LOTECT",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_LOTECT","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStrD14:AddField(aColsSX3[1],"","D14_LOTVIS","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_NUMLOT",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_NUMLOT","C",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrD14:AddField(aColsSX3[1],"","D14_QTDEST","N",aColsSX3[3],aColsSX3[4],,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrD14:AddField(STR0011,"","D14_QTDMOV","N",aColsSX3[3],aColsSX3[4],bValid,{||.T.},Nil,.F.,,.F.,.F.,.F.)//Qtd. Mov.
	buscarSX3("D14_LOTECT",,aColsSX3)
	oStrD14:AddField(STR0013,"","D14_NEWLOT","C",aColsSX3[3],aColsSX3[4],bValid,{||.T.},Nil,.F.,,.F.,.F.,.F.)//Novo Lote
	oStrD14:SetProperty('*' ,MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddGrid("A530D14","A530LOTE",oStrD14,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/,{|| LoadGrdTmp(oModel)})
	oModel:SetRelation("A530D14", {{"D14_FILIAL","xFilial('D14')"},{"D14_LOTECT","LOTECT"},{"D14_NUMLOT","NUMLOT"},{"D14_DTVALD","DTVALD"},{"D14_DTFABR","DTFABR"},{"D14_NUMSER","NUMSER"}})
	oModel:GetModel("A530D14"):SetDescription(STR0008) // Produtos Selecionados
	oModel:GetModel("A530D14"):SetOptional(.T.)
	oModel:GetModel('A530D14'):SetNoInsertLine(.T.)
	oModel:GetModel('A530D14'):SetNoDeleteLine(.T.)

	oModel:SetActivate({|oModel| Active(oModel) })
Return oModel

//--------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------
Static Function ViewDef()
Local oModel  :=  ModelDef()
Local oStrD0A := FWFormStruct(2,"D0A")
Local oStrD14 := FWFormViewStruct():New()
Local oStrLote:= FWFormViewStruct():New()
Local oView   := Nil
Local aColsSX3:= {}
Local nI      := 0

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oStrD0A:RemoveField('D0A_PROCES')
	oStrD0A:RemoveField('D0A_OPERAC')
	oStrD0A:SetProperty('D0A_DOC'   ,MVC_VIEW_ORDEM,'01')
	oStrD0A:SetProperty('D0A_LOCAL' ,MVC_VIEW_ORDEM,'02')
	oStrD0A:SetProperty('D0A_PRODUT',MVC_VIEW_ORDEM,'03')
	oStrD0A:SetProperty('D0A_DESC'  ,MVC_VIEW_ORDEM,'04')
	oStrD0A:SetProperty('D0A_LOTECT',MVC_VIEW_ORDEM,'05')
	oStrD0A:SetProperty('D0A_NUMLOT',MVC_VIEW_ORDEM,'06')
	oStrD0A:SetProperty('D0A_QTDMOV',MVC_VIEW_ORDEM,'08')
	oStrD0A:SetProperty('D0A_MOVAUT',MVC_VIEW_ORDEM,'09')
	oStrD0A:SetProperty('D0A_ENDER' ,MVC_VIEW_ORDEM,'10')
	oStrD0A:SetProperty('*'         ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0A:SetProperty('D0A_ENDER' ,MVC_VIEW_CANCHANGE,.T.)
	oStrD0A:SetProperty('D0A_MOVAUT',MVC_VIEW_CANCHANGE,.F.)
	oView:AddField("VA530D0A",oStrD0A,"A530D0A")

	If lOperInsert
		// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
		buscarSX3("D14_LOTECT",,aColsSX3)
		oStrLote:AddField("LOTECT","01",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		oStrLote:AddField("LOTVIS","02",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		buscarSX3("D14_NUMLOT",,aColsSX3)
		oStrLote:AddField("NUMLOT","03",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		buscarSX3("D14_DTVALD",,aColsSX3)
		oStrLote:AddField("DTVALD","04",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		buscarSX3("D14_DTFABR",,aColsSX3)
		oStrLote:AddField("DTFABR","05",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		buscarSX3("D14_NUMSER",,aColsSX3)
		oStrLote:AddField("NUMSER","06",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		buscarSX3("D14_QTDEST",,aColsSX3)
		oStrLote:AddField("QTDEST","07",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
		oStrLote:AddField("QTDMOV","08",STR0011,STR0011,Nil,"GET",aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.F.) //Qtd. Mov.
		oStrLote:RemoveField("LOTECT")
	EndIf	

	oView:SetViewProperty('VA530D0A','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP,5})

	// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
	buscarSX3("D14_LOCAL",,aColsSX3)
	oStrD14:AddField("D14_LOCAL","01",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	buscarSX3("D14_ENDER",,aColsSX3)
	oStrD14:AddField("D14_ENDER","02",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	If lExistUnit
		oStrD14:AddField("D14_IDUNIT","03",buscarSX3("D14_IDUNIT",,aColsSX3)       ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	EndIf
	buscarSX3("D14_PRODUT",,aColsSX3)
	oStrD14:AddField("D14_PRODUT","04",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	buscarSX3("D14_LOTECT",,aColsSX3)
	oStrD14:AddField("D14_LOTECT","05",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	oStrD14:AddField("D14_LOTVIS","06",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	buscarSX3("D14_NUMLOT",,aColsSX3)
	oStrD14:AddField("D14_NUMLOT","07",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrD14:AddField("D14_QTDEST","08",aColsSX3[1],aColsSX3[1],Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.)
	buscarSX3("D14_QTDEST",,aColsSX3)
	oStrD14:AddField("D14_QTDMOV","09",STR0011,STR0011,Nil,"GET",aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.F.)//Qtd. Mov.
	buscarSX3("D14_LOTECT",,aColsSX3)
	oStrD14:AddField("D14_NEWLOT","10",STR0013,STR0013,Nil,"GET",aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.F.)//Novo Lote
	oStrD14:RemoveField("D14_LOTECT")
	
	If lOperInsert
		oView:AddGrid("VA530LOTE",oStrLote,"A530LOTE")
		oView:EnableTitleView("VA530LOTE", STR0025) //Lotes
	EndIf

	oView:AddGrid("VA530D14",oStrD14,"A530D14")
	oView:EnableTitleView("VA530D14", STR0008) // Produtos Selecionados

	oView:CreateHorizontalBox('D0A',20)
	If lOperInsert
		oView:CreateHorizontalBox('LOTE',40)
	EndIf
	oView:CreateHorizontalBox('D14',Iif(lOperInsert,40,80))

	oView:SetOwnerView("VA530D0A","D0A")
	If lOperInsert
		oView:SetOwnerView("VA530LOTE","LOTE")
	EndIf
	oView:SetOwnerView("VA530D14","D14")

	oView:SetCloseOnOk({|| .T. })
Return oView

Static Function Active(oModel)
Local oModelD0A := oModel:GetModel("A530D0A")
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		//Carrega grid de lotes
		LoadLotes()
		oModelD0A:SetValue("D0A_LOCAL" , MV_PAR01)
		oModelD0A:SetValue("D0A_PRODUT", MV_PAR02)
		oModelD0A:SetValue("D0A_LOTECT", MV_PAR03) 
		oModelD0A:SetValue("D0A_NUMLOT", MV_PAR04)
		oModelD0A:SetValue("D0A_PROCES", "3")
		oModelD0A:SetValue("D0A_OPERAC", "2")
	EndIf
Return .T.

Static Function LoadLotes()
Local oModel    := FWModelActive()
Local cQuery    := ""
Local cAliasD14 := ""
Local cAliasEnd := ""
Local cLoteCT   := ""
Local nQtdDisp  := 0

	oModel:GetModel('A530D14'):SetNoInsertLine(.F.)
	oModel:GetModel('A530D14'):SetNoDeleteLine(.F.)

	oModel:GetModel("A530LOTE"):SetNoInsertLine(.F.)
	oModel:GetModel("A530LOTE"):SetNoDeleteLine(.F.)

	cQuery := " SELECT D14_LOCAL,"
	cQuery +=        " D14_PRODUT,"
	cQuery +=        " D14_LOTECT,"
	cQuery +=        " D14_NUMLOT,"
	cQuery +=        " D14_DTVALD,"
	cQuery +=        " D14_DTFABR,"
	cQuery +=        " D14_NUMSER"
	cQuery +=   " FROM "+RetSqlName('D14')+" D14"
	cQuery +=  " WHERE D14_FILIAL = '"+xFilial('D14')+"'"
	cQuery +=    " AND D14_LOCAL  = '"+MV_PAR01+"'"
	cQuery +=    " AND D14_ENDER >= '"+MV_PAR05+"' AND D14_ENDER <= '"+MV_PAR06+"'"
	cQuery +=    " AND D14_PRODUT = '"+MV_PAR02+"'"
	If !Empty(MV_PAR03)
		cQuery += " AND D14_LOTECT = '"+MV_PAR03+"'"
		If !Empty(MV_PAR04)
			cQuery += " AND D14_NUMLOT = '"+MV_PAR04+"'"
		EndIf
	EndIf
	cQuery +=    " AND D14_PRODUT = D14_PRDORI "
	cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) > 0"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D14_LOCAL,"
	cQuery +=           " D14_PRODUT,"
	cQuery +=           " D14_LOTECT,"
	cQuery +=           " D14_NUMLOT,"
	cQuery +=           " D14_DTVALD,"
	cQuery +=           " D14_DTFABR,"
	cQuery +=           " D14_NUMSER"
	cAliasD14 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasD14, .T., .T. )
	TcSetField(cAliasD14,'D14_DTVALD','D')
	TcSetField(cAliasD14,'D14_DTFABR','D')
	While (cAliasD14)->(!EoF())
		nQtdDisp := WMSA510SLD((cAliasD14)->D14_LOCAL,(cAliasD14)->D14_PRODUT,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_NUMLOT,(cAliasD14)->D14_DTVALD,.T.)
		If QtdComp(nQtdDisp) > QtdComp(0)
			
			cLoteCT := IIf(AllTrim((cAliasD14)->D14_LOTECT) == AllTrim(''), STR0031, (cAliasD14)->D14_LOTECT) //SEM LOTE
						
			If oModel:GetModel("A530LOTE"):SeekLine( { {"LOTECT",cLoteCT},{"NUMLOT",(cAliasD14)->D14_NUMLOT},{"DTVALD",(cAliasD14)->D14_DTVALD},{"DTFABR",(cAliasD14)->D14_DTFABR},{"NUMSER",(cAliasD14)->D14_NUMSER}} )
				oModel:GetModel("A530LOTE"):LoadValue("QTDEST",nQtdDisp)
			Else
				If !Empty(oModel:GetModel("A530LOTE"):GetValue("LOTECT", oModel:GetModel("A530LOTE"):Length()) )
					oModel:GetModel("A530LOTE"):AddLine()
					oModel:GetModel("A530LOTE"):GoLine(oModel:GetModel("A530LOTE"):Length())
				EndIf

				oModel:GetModel("A530LOTE"):LoadValue("LOTECT",(cAliasD14)->D14_LOTECT)
				oModel:GetModel("A530LOTE"):LoadValue("LOTVIS",cLoteCT)
				oModel:GetModel("A530LOTE"):LoadValue("NUMLOT",(cAliasD14)->D14_NUMLOT)
				oModel:GetModel("A530LOTE"):LoadValue("DTVALD",(cAliasD14)->D14_DTVALD)
				oModel:GetModel("A530LOTE"):LoadValue("DTFABR",(cAliasD14)->D14_DTFABR)
				oModel:GetModel("A530LOTE"):LoadValue("NUMSER",(cAliasD14)->D14_NUMSER)
				oModel:GetModel("A530LOTE"):LoadValue("QTDEST",nQtdDisp)
				 
				//Se o lote estiver em branco, foi alterado o parâmetro é obrigatório alterar todo o estoque existente.
				//Assim, não permite alterar as quantidades e já define todas com o valor total
				If lD14SemSB8 
					oModel:GetModel("A530LOTE"):LoadValue("QTDMOV",nQtdDisp)
					oModel:GetModel("A530LOTE"):GetStruct():SetProperty("QTDMOV", MODEL_FIELD_WHEN,{||.F.})
					oModel:GetModel("A530D0A"):LoadValue("D0A_QTDMOV", oModel:GetModel("A530D0A"):GetValue("D0A_QTDMOV") + nQtdDisp)
				Else
					oModel:GetModel("A530LOTE"):LoadValue("QTDMOV",0)
					oModel:GetModel("A530LOTE"):GetStruct():SetProperty("QTDMOV", MODEL_FIELD_WHEN,{||.T.})
				EndIf
			EndIf

			cQuery := " SELECT D14_LOCAL,"
			cQuery +=        " D14_ENDER,"
			If lExistUnit
				cQuery += " D14_IDUNIT,"
			EndIf 
			cQuery +=        " D14_PRODUT,"
			cQuery +=        " D14_LOTECT,"
			cQuery +=        " D14_NUMLOT,"
			cQuery +=        " D14_DTVALD,"
			cQuery +=        " D14_DTFABR,"
			cQuery +=        " D14_NUMSER,"
			cQuery +=        " (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) D14_QTDEST"
			cQuery +=   " FROM "+RetSqlName('D14')+" D14"
			cQuery +=  " WHERE D14_FILIAL = '"+xFilial('D14')+"'"
			cQuery +=    " AND D14_LOCAL  = '"+(cAliasD14)->D14_LOCAL+"'"
			cQuery +=    " AND D14_PRODUT = '"+(cAliasD14)->D14_PRODUT+"'"
			cQuery +=    " AND D14_LOTECT = '"+(cAliasD14)->D14_LOTECT+"'"
			cQuery +=    " AND D14_NUMLOT = '"+(cAliasD14)->D14_NUMLOT+"'"
			cQuery +=    " AND D14_NUMSER = '"+(cAliasD14)->D14_NUMSER+"'"
			cQuery +=    " AND D14_ENDER >= '"+MV_PAR05+"' AND D14_ENDER <= '"+MV_PAR06+"'"
			cQuery +=    " AND D14_DTVALD = '"+ DtoS((cAliasD14)->D14_DTVALD)+"'"
			cQuery +=    " AND D14_DTFABR = '"+ DtoS((cAliasD14)->D14_DTFABR)+"'"
			cQuery +=    " AND D14_PRODUT = D14_PRDORI "
			cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) > 0"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cAliasEnd := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasEnd, .T., .T. )
			While (cAliasEnd)->(!EoF())
				cLoteCT := IIf(AllTrim((cAliasEnd)->D14_LOTECT) == AllTrim(''), STR0031, (cAliasEnd)->D14_LOTECT) //SEM LOTE				
				
				If oModel:GetModel("A530D14"):SeekLine( { {"D14_LOCAL",(cAliasEnd)->D14_LOCAL},{"D14_ENDER",(cAliasEnd)->D14_ENDER},{"D14_PRODUT",(cAliasEnd)->D14_PRODUT},{"D14_LOTECT",cLoteCT},{"D14_NUMLOT",(cAliasEnd)->D14_NUMLOT},{"D14_IDUNIT",(cAliasEnd)->D14_IDUNIT}} )
					oModel:GetModel("A530D14"):LoadValue("D14_QTDEST",(cAliasEnd)->D14_QTDEST)
				Else
					If !Empty(oModel:GetModel("A530D14"):GetValue("D14_LOCAL", oModel:GetModel("A530D14"):Length()) )
						oModel:GetModel("A530D14"):AddLine()
						oModel:GetModel("A530D14"):GoLine(oModel:GetModel("A530D14"):Length())
					EndIf
					If lExistUnit
						oModel:GetModel("A530D14"):LoadValue("D14_IDUNIT", (cAliasEnd)->D14_IDUNIT)
					EndIf
					oModel:GetModel("A530D14"):LoadValue("D14_LOCAL", (cAliasEnd)->D14_LOCAL)
					oModel:GetModel("A530D14"):LoadValue("D14_ENDER", (cAliasEnd)->D14_ENDER)
					oModel:GetModel("A530D14"):LoadValue("D14_PRODUT",(cAliasEnd)->D14_PRODUT)
					oModel:GetModel("A530D14"):LoadValue("D14_LOTECT",(cAliasEnd)->D14_LOTECT)
					oModel:GetModel("A530D14"):LoadValue("D14_LOTVIS",cLoteCT)
					oModel:GetModel("A530D14"):LoadValue("D14_NUMLOT",(cAliasEnd)->D14_NUMLOT)
					oModel:GetModel("A530D14"):LoadValue("D14_QTDEST",(cAliasEnd)->D14_QTDEST)
					 
					If lD14SemSB8 
						oModel:GetModel("A530D14"):LoadValue("D14_QTDMOV",(cAliasEnd)->D14_QTDEST)
						oModel:GetModel("A530D14"):GetStruct():SetProperty("D14_QTDMOV", MODEL_FIELD_WHEN,{||.F.})
					Else				
						oModel:GetModel("A530D14"):LoadValue("D14_QTDMOV",0)
						oModel:GetModel("A530D14"):GetStruct():SetProperty("D14_QTDMOV", MODEL_FIELD_WHEN,{||.T.})
					EndIf
					
					oModel:GetModel("A530D14"):LoadValue("D14_NEWLOT","")
				EndIf
				(cAliasEnd)->(DbSkip())
			EndDo
			(cAliasEnd)->(DbCloseArea())
		EndIf
		(cAliasD14)->(DbSkip())
	EndDo
	(cAliasD14)->(DbCloseArea())

	oModel:GetModel('A530D14'):SetNoInsertLine(.T.)
	oModel:GetModel('A530D14'):SetNoDeleteLine(.T.)

	oModel:GetModel("A530LOTE"):SetNoInsertLine(.T.)
	oModel:GetModel("A530LOTE"):SetNoDeleteLine(.T.)
	oModel:GetModel("A530LOTE"):GoLine(1)
Return Nil

Static Function ValidModel(oModel)
Local oModelD14 := oModel:GetModel("A530D14")
Local oModelLote:= oModel:GetModel("A530LOTE")
Local oModelD0A := oModel:GetModel("A530D0A")
Local oEndereco := WMSDTCEndereco():New()
Local oSeqAbast := WMSDTCSequenciaAbastecimento():New()
Local cLote     := ""
Local aLotes    := {}
Local lRet      := .T.
Local nPos      := 0
Local nI        := 0
Local nJ        := 0
Local nQtdMov   := 0

	If !lOperDelete
		//Verifica quantidade disponível novamente
		For nI := 1 To oModelLote:Length()
			oModelLote:GoLine(nI)
			nQtdDisp := WMSA510SLD(oModelD0A:GetValue("D0A_LOCAL"),oModelD0A:GetValue("D0A_PRODUT"),oModelLote:GetValue("LOTECT"),oModelLote:GetValue("NUMLOT"),oModelLote:GetValue("DTVALD"),.T.)
			If QtdComp(nQtdDisp) < QtdComp(oModelLote:GetValue("QTDMOV"))
				//Recarrega todo o model
				LoadLotes()
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA53007,WmsFmtMsg(STR0028,{{"[VAR01]",oModelLote:GetValue("LOTECT",nI)},{"[VAR02]",oModelLote:GetValue("NUMLOT",nI)}}),WmsFmtMsg(STR0029,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //"Quantidade informada indisponível para o lote/sub-lote [VAR01]/[VAR02]." //"Informe uma quantidade compatível com a disponível ([VAR01])."
				If FunName() == 'WMSA530'
					oView := FWViewActive()
					oView:Refresh()
				EndIf
				Return .F.
			EndIf
		Next nI
		//Valida quantidade informada do lote com as quantidades informadas por endereço
		For nI := 1 to oModelLote:Length()
			oModelLote:GoLine(nI)
			nQtdMov := 0
			For nJ := 1 to oModelD14:Length()
				oModelD14:GoLine(nJ)
				nQtdMov += oModelD14:GetValue("D14_QTDMOV")
			Next nJ
			If !(QtdComp(nQtdMov) == QtdComp(oModelLote:GetValue("QTDMOV")))
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA53006,WmsFmtMsg(STR0026,{{"[VAR01]",oModelD14:GetValue('D14_LOTECT')},{"[VAR02]",oModelD14:GetValue('D14_NUMLOT')}}),STR0027, '', '')//Quantidade informada para o lote/sub-lote [VAR01]/[VAR02] incompatível com a soma da quantidade informada para os endereços. //Ajuste a quantidade movimentada do lote.
				lRet := .F.
				Exit
			EndIf
			If !lRet
				Exit
			EndIf
		Next nI
		If lRet
			For nI := 1 to oModelLote:Length()
				oModelLote:GoLine(nI)
				For nJ := 1 to oModelD14:Length()
					oModelD14:GoLine(nJ)
					If oModelD14:GetValue("D14_QTDMOV") == 0
						Loop
					EndIf
					If Empty(oModelD14:GetValue("D14_NEWLOT"))
						nPos := aScan(aLotes, {|x| x[1] == oModelD14:GetValue("D14_PRODUT")+oModelD14:GetValue("D14_LOTECT")+oModelD14:GetValue("D14_NUMLOT") })
						If nPos == 0
							cLote := NextLote( oModelD14:GetValue("D14_PRODUT"),"L" )
							aAdd(aLotes, {oModelD14:GetValue("D14_PRODUT")+oModelD14:GetValue("D14_LOTECT")+oModelD14:GetValue("D14_NUMLOT"), cLote} )
						Else
							cLote := aLotes[nPos][2]
						EndIf
						oModelD14:LoadValue("D14_NEWLOT", cLote )
					EndIf
				Next nJ
			Next nI
		EndIf
	EndIf
	oEndereco:Destroy()
	oSeqAbast:Destroy()
Return lRet

Static Function CommitMdl(oModel)
Local lRet       := .T.
Local oModelD0A  := oModel:GetModel("A530D0A")
Local oModelD0B  := oModel:GetModel("A530D0B")
Local oModelD14  := oModel:GetModel("A530D14")
Local oModelLote := oModel:GetModel("A530LOTE")
Local cAliasQry  := Nil
Local cCtrl      := "01"
Local nI         := 0
Local nJ         := 0
Local nQtdDisp   := 0
Local nRecSB2    := 0

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SB2.R_E_C_N_O_ RECNOSB2
			FROM %Table:SB2% SB2
			WHERE SB2.B2_FILIAL = %xFilial:SB2% 
			AND SB2.B2_COD = %Exp:oModelD0A:GetValue("D0A_PRODUT")%
			AND SB2.B2_LOCAL = %Exp:oModelD0A:GetValue("D0A_LOCAL")%
			AND SB2.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SB2->(dbGoTo((cAliasQry)->RECNOSB2))
			If SB2->(SimpleLock())
				nRecSB2 := SB2->(Recno())
				For nI := 1 To oModelLote:Length()
					oModelLote:GoLine(nI)
					//Verifica quantidade disponível novamente
					nQtdDisp := WMSA510SLD(oModelD0A:GetValue("D0A_LOCAL"),oModelD0A:GetValue("D0A_PRODUT"),oModelLote:GetValue("LOTECT"),oModelLote:GetValue("NUMLOT"),oModelLote:GetValue("DTVALD"),.T.)
					If QtdComp(nQtdDisp) < QtdComp(oModelLote:GetValue("QTDMOV"))
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA53008,WmsFmtMsg(STR0028,{{"[VAR01]",oModelLote:GetValue("LOTECT",nI)},{"[VAR02]",oModelLote:GetValue("NUMLOT",nI)}}),WmsFmtMsg(STR0029,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //"Quantidade informada indisponível para o lote/sub-lote [VAR01]/[VAR02]." //"Informe uma quantidade compatível com a disponível ([VAR01])."
						Return .F.
					EndIf
				Next nI
			Else
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA53009,STR0030,, '', '') //"Produto comprometido em outro processo de troca de lotes."
				Return .F.
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		Begin Transaction
			If oModel:GetOperation() == MODEL_OPERATION_DELETE
				//Estorna movimentações automáticas de estoque.
				lRet := WMSA510EST(oModel,oModelD0A:GetValue('D0A_DOC'))
			EndIf
			If lRet
				If oModel:GetOperation() == MODEL_OPERATION_INSERT
					// Limpa a grid de Saldos, para considerar os endereços com quantidade preenchida maior que 0 (zero).
					oModelD14:SetNoDeleteLine(.F.)
					For nI := 1 To oModelLote:Length()
						oModelLote:GoLine(nI)
						For nJ := 1 To oModelD14:Length()
							oModelD14:GoLine(nJ)
							If oModelD14:GetValue("D14_QTDMOV") == 0
								oModelD14:DeleteLine()
								Loop
							EndIf
						Next nJ
					Next nI
					oModelD14:SetNoDeleteLine(.T.)
					For nI := 1 to oModelLote:Length()
						oModelLote:GoLine(nI)
						For nJ := 1 to oModelD14:Length()
							oModelD14:GoLine(nJ)
							If oModelD14:GetValue("D14_QTDMOV") == 0
								Loop
							EndIf
							// Construção da tabela D0B (Transferência)
							If !Empty(oModelD0B:GetValue("D0B_DOC", oModelD0B:Length()) )
								oModelD0B:AddLine()
								oModelD0B:GoLine(oModelD0B:Length())
							EndIf
							oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC"))
							oModelD0B:SetValue("D0B_ENDDES", oModelD14:GetValue("D14_ENDER"))
							oModelD0B:SetValue("D0B_LOCAL",  oModelD0A:GetValue("D0A_LOCAL"))
							oModelD0B:SetValue("D0B_PRODUT", oModelD14:GetValue("D14_PRODUT"))
							oModelD0B:SetValue("D0B_PRDORI", oModelD14:GetValue("D14_PRODUT"))
							oModelD0B:SetValue("D0B_LOTECT", oModelD14:GetValue("D14_LOTECT"))
							oModelD0B:SetValue("D0B_NUMLOT", oModelD14:GetValue("D14_NUMLOT"))
							oModelD0B:SetValue("D0B_QUANT",  oModelD14:GetValue("D14_QTDMOV"))
							oModelD0B:SetValue("D0B_ENDORI", oModelD14:GetValue("D14_ENDER"))
							If lExistUnit
								oModelD0B:SetValue("D0B_IDUNIT", oModelD14:GetValue("D14_IDUNIT"))
							EndIf
							oModelD0B:SetValue("D0B_TIPMOV", "1")
							oModelD0B:SetValue("D0B_CTRL"  , cCtrl)
							// Construção da tabela D0B (Endereçamento)
							oModelD0B:AddLine()
							oModelD0B:GoLine(oModelD0B:Length())
							oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC"))
							oModelD0B:SetValue("D0B_LOCAL",  oModelD0A:GetValue("D0A_LOCAL"))
							oModelD0B:SetValue("D0B_PRODUT", oModelD14:GetValue("D14_PRODUT"))
							oModelD0B:SetValue("D0B_PRDORI", oModelD14:GetValue("D14_PRODUT"))
							oModelD0B:SetValue("D0B_LOTECT", oModelD14:GetValue("D14_NEWLOT"))
							oModelD0B:SetValue("D0B_NUMLOT", oModelD14:GetValue("D14_NUMLOT"))
							oModelD0B:SetValue("D0B_QUANT",  oModelD14:GetValue("D14_QTDMOV"))
							oModelD0B:SetValue("D0B_ENDORI", oModelD14:GetValue("D14_ENDER"))
							oModelD0B:SetValue("D0B_ENDDES", oModelD14:GetValue("D14_ENDER"))
							If lExistUnit
								oModelD0B:SetValue("D0B_IDUNIT", oModelD14:GetValue("D14_IDUNIT"))
							EndIf
							oModelD0B:SetValue("D0B_TIPMOV", "2")
							oModelD0B:SetValue("D0B_CTRL"  , cCtrl)
							cCtrl := Soma1(cCtrl)
						Next nJ
					Next nI
				EndIf
				// Realiza o Commit dos dados D0A e D0B para serem utilizadas em metodos posteriores.
				FwFormCommit(oModel)
				If oModel:GetOperation() == MODEL_OPERATION_INSERT
					//cria o lote em branco
					If lD14SemSB8
						dbSelectArea("SB8")
						RecLock("SB8",.T.)
						Replace	B8_FILIAL  with xFilial("SB8"),;
							B8_NUMLOTE with '',;
							B8_PRODUTO with oModelD14:GetValue("D14_PRODUT"),;
							B8_LOCAL   with oModelD14:GetValue("D14_LOCAL"),;
							B8_DATA    with dDataBase,;
							B8_SALDO   with nQtdDisp,;
							B8_SALDO2  with ConvUm(oModelD14:GetValue("D14_PRODUT"),nQtdDisp,0,2),;
							B8_QTDORI  with nQtdDisp,;
							B8_QTDORI2 with ConvUm(oModelD14:GetValue("D14_PRODUT"),nQtdDisp,0,2),;
							B8_ORIGLAN with 'MI',;
							B8_LOTEFOR with '',;
							B8_LOTECTL with ''
							//B8_DTVALID with dDataBase,;
							//B8_DFABRIC with	dDataBase,;
						MsUnlock()						
					EndIf
					
					lRet := WMSA510AUTO(oModel,oModelD0A:GetValue('D0A_DOC'))
				EndIf
			EndIf
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction
		If (nRecSB2 > 0)
			If SB2->(Recno()) != nRecSB2
				SB2->(dbGoTo(nRecSB2))
			EndIf
			SB2->(MsUnlock())
		EndIf
	EndIf
Return lRet

Static Function SetQtdMov(oModel)
Local lRet      := .T.
Local oModelLote:= oModel:GetModel("A530LOTE")
Local oModelD14 := oModel:GetModel("A530D14")
Local nI        := 0
Local nQuant    := 0
Local nQtdMov   := 0

	If QtdComp(oModelLote:GetValue("QTDMOV")) > QtdComp(oModelLote:GetValue("QTDEST"))
		Return .F.
	EndIf

	//Zera quantidades já informadas para o lote
	For nI := 1 To oModelD14:Length()
		oModelD14:GoLine(nI)
		oModelD14:LoadValue("D14_QTDMOV",0)
	Next nI

	//Distribui quantidade informada para o lote entre os endereços disponíveis
	nQuant := oModelLote:GetValue("QTDMOV")
	For nI := 1 To oModelD14:Length()
		oModelD14:GoLine(nI)
		If QtdComp(nQuant) > QtdComp(oModelD14:GetValue("D14_QTDEST"))
			nQtdMov := oModelD14:GetValue("D14_QTDEST")
		Else
			nQtdMov := nQuant
		EndIf
		nQuant -= nQtdMov
		oModelD14:LoadValue("D14_QTDMOV",nQtdMov)
		If QtdComp(nQtdMov) <= QtdComp(0)
			Exit
		EndIf
	Next nI
	oModelD14:GoLine(1)
Return lRet

Static Function ValidField(oModel,cField,xVal,nLine,xValAnt)
Local oView := Nil 
Local lRet := .T.
Local cLocal

	If cField == "QTDMOV"
		If lRet := SetQtdMov(oModel)
			lRet := SetQtd(xVal,nLine,xValAnt)
		EndIf
	ElseIf cField == "D14_QTDMOV"
		lRet := VldQtdMov(oModel:GetModel("A530D14"))
	ElseIf cField == "D14_NEWLOT"
		lRet := LoteAssist(oModel:GetModel("A530D14"),xValAnt)
	ElseIf cField == "D0A_ENDER"
		cLocal := oModel:GetModel("A530D0A"):GetValue("D0A_LOCAL")
		Return Empty(oModel:GetModel("A530D0A"):GetValue(cField)) .Or. !Empty(Posicione("SBE",1,xFilial("SBE")+cLocal+oModel:GetModel("A530D0A"):GetValue(cField),"BE_LOCALIZ"))
	EndIf

	If FunName() == "WMSA530"
		oView := FWViewActive()
		oView:Refresh()
	EndIf
Return lRet

Static Function VldQtdMov(oModelD14)
Local lRet := .T.
	If QtdComp(oModelD14:GetValue("D14_QTDMOV")) > QtdComp(oModelD14:GetValue("D14_QTDEST"))
		lRet := .F.
	EndIf
Return lRet

Static Function LoteAssist(oModelD14,xValAnt)
Local nLine   := oModelD14:GetLine()
Local nCount  := 0
Local nI      := 0
Local lAssist := .T.
Local lRet    := .T.
	If oModelD14:GetValue("D14_LOTECT") == oModelD14:GetValue("D14_NEWLOT")
		Return .F.
	EndIf
	For nI := 1 To oModelD14:Length()
		oModelD14:GoLine(nI)

		If oModelD14:GetValue("D14_PRODUT",nI)+oModelD14:GetValue("D14_LOTECT",nI)+oModelD14:GetValue("D14_NUMLOT",nI) == oModelD14:GetValue("D14_PRODUT",nLine)+oModelD14:GetValue("D14_LOTECT",nLine)+oModelD14:GetValue("D14_NUMLOT",nLine)
			nCount++

			If nI == nLine
				Loop
			EndIf

			If oModelD14:GetValue("D14_NEWLOT",nI) != xValAnt .And. !Empty(oModelD14:GetValue("D14_NEWLOT"))
				lAssist := .F.
				Exit
			EndIf
		EndIf
	Next nI

	If lAssist .And. nCount > 1
		If WmsQuestion(STR0015,WMSA53001) // Atribuir este Lote a semelhantes?
			For nI := 1 To oModelD14:Length()
				oModelD14:GoLine(nI)

				If nI == nLine
					Loop
				EndIf

				oModelD14:LoadValue("D14_NEWLOT", oModelD14:GetValue("D14_NEWLOT",nLine) )

			Next nI
		EndIf
	EndIf

	oModelD14:GoLine(nLine)
Return lRet

Static Function SetQtd(xVal,nLine,xValAnt)
Local oModel := FWModelActive()
Local lRet := .T.
	If lRet
		If xValAnt < xVal
			oModel:GetModel("A530D0A"):LoadValue( 'D0A_QTDMOV', oModel:GetModel("A530D0A"):GetValue('D0A_QTDMOV') + (xVal - xValAnt) )
		ElseIf xValAnt > xVal
			oModel:GetModel("A530D0A"):LoadValue( 'D0A_QTDMOV', oModel:GetModel("A530D0A"):GetValue('D0A_QTDMOV') - (xValAnt - xVal) )
		EndIf
	EndIf
Return lRet

Static Function LoadGrdTmp(oModel)
Local aLoad     := {}
Local cQuery    := ""
Local cAliasTmp := ""
Local aAreaAnt  := GetArea()

	cQuery := " SELECT D0B.D0B_LOCAL,"
	cQuery +=        " D0B.D0B_ENDORI,"
	cQuery +=        " D0B.D0B_PRODUT,"
	cQuery +=        " D0B.D0B_LOTECT D0B1_LOTE,"
	cQuery +=        " D0B.D0B_NUMLOT,"
	cQuery +=        " D0B.D0B_QUANT,"
	If lExistUnit
		cQuery +=        " D0B.D0B_IDUNIT,"
	EndIf
	cQuery +=        " D0B2.D0B_LOTECT D0B2_LOTE"
	cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
	cQuery +=  " INNER JOIN (SELECT D0B_CTRL, D0B_LOTECT"
	cQuery +=                " FROM "+RetSqlName("D0B")+" D0B"
	cQuery +=               " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=                 " AND D0B.D_E_L_E_T_ = ' '"
	cQuery +=                 " AND D0B.D0B_TIPMOV = '2'"
	cQuery +=                 " AND D0B.D0B_PRODUT = '"+oModel:GetModel("A530D0A"):GetValue("D0A_PRODUT")+"'"
	cQuery +=                 " AND D0B.D0B_DOC = '"+oModel:GetModel("A530D0A"):GetValue("D0A_DOC")+"' ) D0B2"
	cQuery +=     " ON D0B2.D0B_CTRL = D0B.D0B_CTRL"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery +=    " AND D0B.D0B_TIPMOV = '1'"
	cQuery +=    " AND D0B.D0B_PRODUT = '"+oModel:GetModel("A530D0A"):GetValue("D0A_PRODUT")+"'"
	cQuery +=    " AND D0B.D0B_DOC = '"+oModel:GetModel("A530D0A"):GetValue("D0A_DOC")+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasTmp := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
	While (cAliasTmp)->(!Eof())
		If lExistUnit
			aAdd(aLoad,{0, {(cAliasTmp)->D0B_LOCAL,;
							(cAliasTmp)->D0B_ENDORI,;
							(cAliasTmp)->D0B_IDUNIT,;
							(cAliasTmp)->D0B_PRODUT,;
							(cAliasTmp)->D0B1_LOTE,;
							(cAliasTmp)->D0B1_LOTE,;
							(cAliasTmp)->D0B_NUMLOT,;
							0,;
							(cAliasTmp)->D0B_QUANT,;
							(cAliasTmp)->D0B2_LOTE}})
		Else
			aAdd(aLoad,{0, {(cAliasTmp)->D0B_LOCAL,;
							(cAliasTmp)->D0B_ENDORI,;
							(cAliasTmp)->D0B_PRODUT,;
							(cAliasTmp)->D0B1_LOTE,;
							(cAliasTmp)->D0B1_LOTE,;
							(cAliasTmp)->D0B_NUMLOT,;
							0,;
							(cAliasTmp)->D0B_QUANT,;
							(cAliasTmp)->D0B2_LOTE}})
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())
	RestArea(aAreaAnt)
Return aLoad

Static Function A530VldPrd()
Local lRet := .T.

	If !Rastro(MV_PAR02)
		WmsMessage(STR0018,WMSA53003,5/*MSG_HELP*/) //"Produto não controla Rastro (B1_RASTRO)."
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} D14SemSB8
Verifica se o produto possui D14 (estoque x endereço) mas não possui SB8 (lote).
@author Wander Horongoso
@since 31/10/2019
@version 1.0
@param cArmazem,cProduto
@return Se encontrar D14 sem SB8 verifica se D14 possui alguma quantidade pendente para ser movimentada. Se encontrar, não permite incluir lote. 
/*/
Static Function D14SemSB8(cArmazem, cProd)
Local cAliasSB2 := ''
Local cAliasD14 := ''
Local lRet := .T.

	lD14SemSB8 := WmsD14SSB8(cArmazem, cProd)
	
	If lD14SemSB8
	
		//Basicamente utilizada a mesma lógica da função ChkQtdRes da WMSDTCOrdemServico
		cAliasSB2 := GetNextAlias()
		BeginSql Alias cAliasSB2
			SELECT ((SB2.B2_QACLASS - CASE WHEN D0G.D0G_QTDORI IS NULL THEN 0 ELSE D0G.D0G_QTDORI END) + SB2.B2_RESERVA + SB2.B2_QEMP + SB2.B2_QEMPSA + SB2.B2_QEMPN) QTTOTAL
			FROM %Table:SB2% SB2
			LEFT JOIN %Table:D0G% D0G
			ON D0G.D0G_FILIAL = %xFilial:D0G%
			AND D0G.D0G_PRODUT = SB2.B2_COD
			AND D0G.D0G_LOCAL = SB2.B2_LOCAL
			AND D0G.%NotDel%
			WHERE SB2.B2_FILIAL = %xFilial:SB2%
			AND SB2.B2_COD = %Exp:cProd%
			AND SB2.B2_LOCAL = %Exp:cArmazem%
			AND SB2.%NotDel%
		EndSql
		If (cAliasSB2)->QTTOTAL > 0
			WmsMessage(STR0035,,2/*MSG_ERROR*/)  //Não é possível efetuar troca de lotes para produtos com quantidade a classificar, reserva, entrada prevista, saída prevista ou quantidade empenhada.			
			lRet := .F.
		Else
			cAliasD14 := GetNextAlias()
			BeginSql Alias cAliasD14
				SELECT SUM(D14_QTDEPR + D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ) QTTOTAL
				FROM %Table:D14%
				WHERE D14_FILIAL = %xFilial:D14%
				AND D14_LOCAL = %Exp:cArmazem%
				AND D14_PRODUT = %Exp:cProd%
				AND %NotDel%
			EndSql
			If (cAliasD14)->QTTOTAL > 0
				WmsMessage(STR0033,,2/*MSG_ERROR*/)  //Não é possível efetuar troca de lotes para produtos com entrada prevista, saída prevista, quantidade empenhada ou bloqueada.			
				lRet := .F.
			Else
				lRet := WmsQuestion(STR0034) //ATENÇAO: este produto foi alterado para controlar rastro por lote. Por este motivo, uma futura exclusão desta troca de lote não será possível. Continuar com a inclusão?
			EndIf
			dbCloseArea(cAliasD14)
		EndIf
		
		dbCloseArea(cAliasSB2)		
	EndIf	
Return lRet

//----------------------------------------
/*/{Protheus.doc} SB8SemLote
Verifica se o produto controla lote e em algum momento antes não controlava.
Nesse caso, não será possível excluir a troca de lote.
@author Wander Horongoso
@since 31/10/2019
@version 1.0
@param cArmazem,cProduto
@return Se encontrar SB8 com lote vazio retorna verdadeiro. 
/*/
Static Function SB8SemLote(cArmazem, cProd)
Local cAliasSB8 := ''
Local lRet := .F.

	cAliasSB8 := GetNextAlias()		
	BeginSql Alias cAliasSB8
		SELECT COUNT(B8_PRODUTO) QTTOTAL
		FROM %Table:SB8%
		WHERE B8_FILIAL = %xFilial:SB8% 
		AND B8_LOCAL = %Exp:cArmazem%
		AND B8_PRODUTO = %Exp:cProd%
		AND B8_LOTECTL = ' '
		AND %NotDel%
	EndSql
	If (cAliasSB8)->QTTOTAL > 0
		WmsMessage(STR0032,,2/*MSG_ERROR*/) //Não é possível excluir lotes de produtos que antes não possuíam controle de rastro.
		lRet := .T. 
	EndIf	
	dbCloseArea(cAliasSB8)		
Return lRet
/*/{Protheus.doc} A530VldArm
Verifica se o armazém informado é o armazém de qualidade e impede a operação.
@author amanda.vieira
@since 14/04/2020
@version 1.0
/*/
Static Function A530VldArm()
Local lRet := .T.
Local cLocalCQ := SuperGetMV("MV_CQ",.F.,"")
	If !Empty(cLocalCQ) .And. AllTrim(cLocalCQ) == AllTrim(MV_PAR01)
		WmsMessage(STR0036,WMSA53010,5/*MSG_HELP*/) //"Não permitida a troca de lotes no armazém de qualidade."
		lRet := .F.
	EndIf
Return lRet
