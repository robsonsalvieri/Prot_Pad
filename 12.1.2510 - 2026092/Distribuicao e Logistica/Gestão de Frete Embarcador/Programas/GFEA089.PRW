#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA089.CH"
//-------------------------------------------------------------------
/*
{Protheus.doc} GFEA089
Cadastro de Centro de Custo

GFEA089()
@sample

@author Octávio Augusto Felippe de Macedo
@since 12/07/2011
@version 1.0
*/
//-------------------------------------------------------------------
Function GFEA089()
 
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUH")
oBrowse:SetMenuDef("GFEA089")
oBrowse:SetDescription(STR0001) //"Cadastro de Centro de Custo"
oBrowse:Activate()

Return Nil

//-----------------------------

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA089" OPERATION 2 ACCESS 0 //"Visualizar"
If SuperGetMV('MV_CADERP',,'1') $ "2N"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA089" OPERATION 3 ACCESS 0 //"Incluir"
EndIf
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA089" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA089" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA089" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA089" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina  

//-----------------------------

Static Function ModelDef()
Local oModel
Local oStructGUH := FWFormStruct(1,"GUH")
Local oStructGUM := FWFormStruct(1,"GUM")

oModel := MPFormModel():New("GFEA089",, {|oMod| GFEA89POS(oMod)},,)

oModel:AddFields("GFEA089_GUH", Nil, oStructGUH,,,)
oModel:SetPrimaryKey({"GUH_FILIAL", "GUH_CCUSTO"}) 

oModel:GetModel("GFEA089_GUH"):setDescription(STR0009) //"Centro de Custo"

oModel:AddGrid("GFEA089_GUM","GFEA089_GUH", oStructGUM,,{|oMod| GFEA89GUMP(oMod)},,,,)
oModel:SetRelation("GFEA089_GUM",{{"GUM_FILIAL","xFilial('GUM')"},{"GUM_CCUSTO","GUH_CCUSTO"}},"GUM_FILIAL+GUM_CCUSTO+GUM_CTACTB")
oModel:GetModel("GFEA089_GUM"):SetOptional(.T.)	

oModel:GetModel("GFEA089_GUM"):setDescription(STR0010) //"Contas Contábeis"

Return oModel       

//-----------------------------

Static Function ViewDef()
Local oModel := FWLoadModel("GFEA089")
Local oView
Local oStructGUH := FWFormStruct(2,"GUH")
Local oStructGUM := FWFormStruct(2,"GUM")

oStructGUM:RemoveField("GUM_CCUSTO")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("GFEA089_GUH", oStructGUH)

oView:AddGrid("GFEA089_GUM" , oStructGUM)

oView:CreateHorizontalBox("MASTER", 55, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
oView:CreateHorizontalBox("DETAIL", 45, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0010) //"Contas Contábeis"

oView:CreateHorizontalBox("DETAIL_GUH", 100,,,"IDFOLDER","IDSHEET01")

oView:SetOwnerView("GFEA089_GUH" , "MASTER")
oView:SetOwnerView("GFEA089_GUM" , "DETAIL_GUH")
	
Return oView

//-----------------------------

Static Function GFEA89GUMP(oModel)
Local nLine := oModel:GetLine()
Local nCount

For nCount := 1 To oModel:Length()
	oModel:GoLine(nCount)
	If nCount != nLine .And. !oModel:IsDeleted() .And. oModel:GetValue("GUM_CTACTB") == FwFldGet("GUM_CTACTB",nLine)
		Help( ,, 'HELP',, (STR0013 + AllTrim(Str(nCount)) + " ."), 1, 0,) //"A Conta Contábil já existe na linha "
		oModel:GoLine(nLine)
		Return .F.
	EndIf
Next nCount

oModel:GoLine(nLine)

Return .T.

//-----------------------------------------------
                                                 
Static Function GFEA89IMPD(oModel)
	Local aGUSFields := FWFormStruct(1, "GUS"):GetFields()
	Local aGUFFields := FWFormStruct(1, "GUF"):GetFields()
	Local cCentroC   := oModel:GetModel("GFEA089_GUH"):GetValue("GUH_CCUSTO")
	Local nI
	Local cFiltro    := ""
	Local lImped     := .F.
	
	For nI := 1 To Len(aGUSFields)
			
		If "GUS_CC" $ aGUSFields[nI][3] .And. GFEUSADO(aGUSFields[nI][3])
			
			If !Empty(cFiltro)
				cFiltro += " .Or. "
			EndIf
			
			cFiltro += "GUS->" + aGUSFields[nI][3] + " == '" + cCentroC + "'"
			
		EndIf
		
	Next nI
	
	dbSelectArea("GUS")
	GUS->( dbSetOrder(1) )
	GUS->( dbSetFilter({|| &(cFiltro)}, "") )
	GUS->( dbGoTop() )
	If !GUS->( Eof() )
		lImped := .T.
	EndIf
	
	GUS->( dbClearFilter() )
	
	If !lImped
		
		cFiltro := ""
		
		For nI := 1 To Len(aGUFFields)
			
			If "GUF_CC" $ aGUFFields[nI][3] .And. GFEUSADO(aGUFFields[nI][3])
				
				If !Empty(cFiltro)
					cFiltro += " .Or. "
				EndIf
				
				cFiltro += "GUF->" + aGUFFields[nI][3] + " == '" + cCentroC + "'"
				
			EndIf
			
		Next nI
		
		dbSelectArea("GUF")
		GUF->( dbSetOrder(1) )
		GUF->( dbSetFilter({|| &(cFiltro)}, "") )
		GUF->( dbGoTop() )
		If !GUF->( Eof() )
			lImped := .T.
		EndIf
		
		GUF->( dbClearFilter() )
		
	EndIf
	
Return lImped

//-----------------------------------------------

Function GFEA89POS(oModel)
	Local nOp       := oModel:GetOperation()
	Local oModelGUM := oModel:GetModel("GFEA089_GUM")
	Local nLine     := oModelGUM:GetLine()
	Local nI
	
	If GFEWSFUNLG() .And. FunName() != "GFEA089" 
	   Help( ,, 'HELP', '', 'Não é possível receber cadastro do Protheus quando ERP for Datasul.', 1, 0)
	   Return .F.
	EndIf
	
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
		
		For nI := 0 To oModelGUM:Length()
			oModelGUM:GoLine(nI)
			If !oModelGUM:IsDeleted()
				
				dbSelectArea("GUE")
				GUE->( dbSetOrder(1) )
				If GUE->( dbSeek(xFilial("GUE") + oModelGUM:GetValue("GUM_CTACTB")) )
					If GUE->GUE_SIT == "2"
						Help( ,, 'HELP',, "A Conta Contábil " + AllTrim(oModelGUM:GetValue("GUM_CTACTB")) + " está inativa, portanto, não poderá ser utilizada.", 1, 0,)
						oModelGUM:GoLine(nLine)
						Return .F.
					EndIf
				EndIf				
			EndIf
		Next nI
		
		oModelGUM:GoLine(nLine)
		
	EndIf
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
				
		If !IsBlind() .And. GFEA89IMPD(oModel)
		
			Help( ,, 'HELP',, "O Centro de Custo está informado em outros cadastros, portanto não poderá ser excluído. " + ;
							  "Retire os relacionamentos ou altere o Centro de Custo para Inativo.", 1, 0,) //"O Centro de Custo está informado em outros cadastros, portanto não poderá ser excluído. Retire os relacionamentos ou altere o Centro de Custo para Inativo."
			Return .F.
			
		EndIf
		
	EndIf

Return .T.
