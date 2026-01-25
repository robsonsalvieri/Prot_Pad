#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------
/* Romaneio x Docto de Carga
@author  	Katia
@version 	12.1.33
@since 		12/07/21
@return 	*/
//-----------------------------------------
Function GFEX300()
    Local oMBrowse 	:= Nil

    Private aRotina := MenuDef()

    oMBrowse:= FWMBrowse():New()	
    oMBrowse:SetAlias( "GWN" )
    oMBrowse:SetDescription( 'Romaneio x Docto Carga' ) 
    oMBrowse:AddLegend("GWN_SIT=='1'", "WHITE" , "Digitado") //"Digitado"
    oMBrowse:AddLegend("GWN_SIT=='2'", "BLUE"  , "Emitido")  //"Emitido"
    oMBrowse:AddLegend("GWN_SIT=='3'", "GREEN" , "Liberado")  //"Liberado"
    oMBrowse:AddLegend("GWN_SIT=='4'", "RED"   , "Encerrado") //"Encerrado"
    oMBrowse:Activate()
Return NIL

//------------------------------------------
/* ModelDef 
@author  	Katia
@version 	12.1.33
@since 		12/07/21
@return 	*/
//-------------------------------------------
Static Function ModelDef()
    Local oModel 	:= NIL
    Local oStruFGWN := FwFormStruct( 1, "GWN" )
    Local oStruGGW1	:= FwFormStruct( 1, "GW1" )
    Local oStruGGW8	:= FwFormStruct( 1, "GW8" )
    Local oStruGGWU	:= FwFormStruct( 1, "GWU" )
    Local oStruGGWE	:= FwFormStruct( 1, "GWE" )
    Local oStruGGXP	:= FwFormStruct( 1, "GXP" )

    oModel := MPFormModel():New( "GFEX300",/*bPreValid*/, {|oMod| GFX300POS(oMod)}, /*bCommit*/, /*bCancel*/ )

    oModel:SetDescription('Romaneio x Docto Carga')  

    oModel:AddFields( 'MdFieldGWN', Nil	, oStruFGWN, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	
    oModel:GetModel("MdFieldGWN"):SetPrimaryKey( { "GWN_FILIAL", "GWN_NRROM" } )

    oModel:AddGrid( "MdGridGW1", "MdFieldGWN", oStruGGW1 )
    If GFXCP1212210('GW1_FILROM')
        oModel:SetRelation( "MdGridGW1", {	{"GW1_FILROM","GWN_FILIAL"}, {"GW1_NRROM","GWN_NRROM"}}, GW1->( IndexKey( 9 ) ) )
    Else
        oModel:SetRelation( "MdGridGW1", {	{"GW1_FILIAL","xFilial('GW1')"}, {"GW1_NRROM","GWN_NRROM"}}, GW1->( IndexKey( 9 ) ) )
    EndIf
    oModel:GetModel("MdGridGW1"):SetUniqueLine({"GW1_EMISDC","GW1_CDTPDC","GW1_SERDC","GW1_NRDC"})
    oModel:GetModel("MdGridGW1"):SetOptional(.T.)

    oModel:AddGrid( "MdGridGW8", "MdGridGW1", oStruGGW8 )
    oModel:SetRelation( "MdGridGW8", {	{"GW8_FILIAL","xFilial('GW8')"}, {"GW8_CDTPDC","GW1_CDTPDC"}, {"GW8_EMISDC","GW1_EMISDC"},;
                                        {"GW8_SERDC","GW1_SERDC"}, {"GW8_NRDC","GW1_NRDC"}    }, GW8->( IndexKey( 1 ) ) )                                                                          
    oModel:GetModel("MdGridGW8"):SetOptional(.T.)

    oModel:AddGrid( "MdGridGWU", "MdGridGW1", oStruGGWU )
    oModel:SetRelation( "MdGridGWU", {	{"GWU_FILIAL","xFilial('GWU')"}, {"GWU_CDTPDC","GW1_CDTPDC"}, {"GWU_EMISDC","GW1_EMISDC"},;
                                        {"GWU_SERDC","GW1_SERDC"}, {"GWU_NRDC","GW1_NRDC"}    }, GWU->( IndexKey( 1 ) ) )
    oModel:GetModel("MdGridGWU"):SetUniqueLine({"GWU_CDTPDC","GWU_EMISDC","GWU_SERDC","GWU_NRDC","GWU_SEQ"})
    oModel:GetModel("MdGridGWU"):SetOptional(.T.)

    oModel:AddGrid( "MdGridGWE", "MdGridGW1", oStruGGWE )
    oModel:SetRelation( "MdGridGWE", {	{"GWE_FILIAL","xFilial('GWE')"}, {"GWE_CDTPDC","GW1_CDTPDC"}, {"GWE_EMISDC","GW1_EMISDC"},;
                                        {"GWE_SERDC","GW1_SERDC"}, {"GWE_NRDC","GW1_NRDC"}    }, GWE->( IndexKey( 1 ) ) )
    oModel:GetModel("MdGridGWE"):SetOptional(.T.)

    oModel:AddGrid( "MdGridGXP", "MdGridGW1", oStruGGXP )
    oModel:SetRelation( "MdGridGXP", {	{"GXP_FILIAL","xFilial('GXP')"}, {"GXP_CDTPDC","GW1_CDTPDC"}, {"GXP_EMISDC","GW1_EMISDC"},;
                                        {"GXP_SERDC","GW1_SERDC"}, {"GXP_NRDC","GW1_NRDC"}    }, GXP->( IndexKey( 1 ) ) )

    oModel:GetModel("MdGridGXP"):SetUniqueLine({"GXP_FILORI","GXP_EMIORI","GXP_SERORI","GXP_DOCORI"})
    oModel:GetModel("MdGridGXP"):SetOptional(.T.)

Return( oModel )

//------------------------------------------
/* ViewDef 
@author  	Katia
@version 	12.1.33
@since 		12/07/21
@return 	*/
//------------------------------------------
Static Function ViewDef()
Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruFGWN := FwFormStruct( 2, "GWN" )
Local oStruGGW1 := FwFormStruct( 2, "GW1" )
Local oStruGGW8 := FwFormStruct( 2, "GW8" )
Local oStruGGWU := FwFormStruct( 2, "GWU" )
Local oStruGGWE := FwFormStruct( 2, "GWE" )
Local oStruGGXP := FwFormStruct( 2, "GXP" )

oModel   := FwLoadModel( "GFEX300" )

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:SetContinuousForm()   

oView:CreateHorizontalBox( "Sup", 020 )
oView:CreateHorizontalBox( "Inf", 080  )

oView:CreateFolder( "Folder",  "Inf" )

oView:AddSheet( "Folder", "Sht1_Fld", 'SIGAGFE' )
oView:AddSheet( "Folder", "Sht2_Fld", 'SIGATMS' )

oView:CreateHorizontalBox( "Box1FldSht1", 200,,.T., "Folder", "Sht1_Fld" )  
oView:CreateHorizontalBox( "Box2FldSht1", 200,,.T., "Folder", "Sht1_Fld" )
oView:CreateHorizontalBox( "Box3FldSht1", 200,,.T., "Folder", "Sht1_Fld" )

oView:CreateHorizontalBox( "Box1FldSht2", 200,,.T., "Folder", "Sht2_Fld" )
oView:CreateHorizontalBox( "Box2FldSht2", 200,,.T., "Folder", "Sht2_Fld" )

oView:AddField('VwFieldGWN', oStruFGWN, 'MdFieldGWN')

oView:AddGrid( "VwGridGW1", oStruGGW1, "MdGridGW1" )
oView:AddGrid( "VwGridGW8", oStruGGW8, "MdGridGW8" )
oView:AddGrid( "VwGridGWU", oStruGGWU, "MdGridGWU" )
oView:AddGrid( "VwGridGWE", oStruGGWE, "MdGridGWE" )
oView:AddGrid( "VwGridGXP", oStruGGXP, "MdGridGXP" )

oView:AddIncrementField("VwGridGW8", "GW8_SEQ" )     
oView:AddIncrementField("VwGridGWU", "GWU_SEQ" )     

oView:EnableTitleView('VwFieldGWN', "Romaneio" )
oView:EnableTitleView('VwGridGW1' , "Documento Carga" ) 
oView:EnableTitleView('VwGridGW8' , "Item Documento Carga" ) 
oView:EnableTitleView('VwGridGWU' , "Trechos" ) 
oView:EnableTitleView('VwGridGWE' , "Doc.Carga x Doc.Transporte" ) 
oView:EnableTitleView('VwGridGXP' , "Documentos de Origem" ) 

oView:SetOwnerView( "VwFieldGWN", "Sup")
oView:SetOwnerView( "VwGridGW1" , "Box1FldSht1" )
oView:SetOwnerView( "VwGridGW8" , "Box2FldSht1" )
oView:SetOwnerView( "VwGridGWU" , "Box3FldSht1" )

oView:SetOwnerView( "VwGridGWE" , "Box1FldSht2" )
oView:SetOwnerView( "VwGridGXP" , "Box2FldSht2" )

oView:SetViewProperty("VwGridGW1", "EnableNewGrid")
oView:SetViewProperty("VwGridGW8", "EnableNewGrid")
oView:SetViewProperty("VwGridGWU", "EnableNewGrid")
oView:SetViewProperty("VwGridGWE", "EnableNewGrid")
oView:SetViewProperty("VwGridGXP", "EnableNewGrid")

oView:SelectFolder("Folder_01",1,2)

Return( oView )

//------------------------------------------
/* MenuDef 
@author  	Katia
@version 	12.1.33
@since 		12/07/21
@return 	aRotina - Array com as opçoes de Menu */   
//------------------------------------------
Static Function MenuDef()
Local aRotina:= {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION "VIEWDEF.GFEX300" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION "VIEWDEF.GFEX300" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION "VIEWDEF.GFEX300" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION "VIEWDEF.GFEX300" OPERATION 5 ACCESS 0						 

Return(aRotina)

Static Function GFX300POS(oModel)
    Local oModelGW1     := oModel:GetModel("MdGridGW1")
    Local nOperation    := oModel:GetOperation()
    Local lRet          := .T.
    Local nLineAux      := 0
    Local nLenGrid      := 0
    Local nI            := 0

    // Ajusta o campo hora para o formato do campo do GFE
	If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT)
        nLineAux := oModelGW1:GetLine()
        nLenGrid := oModelGW1:GetQtdLine()

        For nI := 1 To nLenGrid
            oModelGW1:GoLine(nI)

            If !Empty(oModelGW1:GetValue("GW1_HRIMPL")) .And. SubStr(oModelGW1:GetValue("GW1_HRIMPL"),3,1) != ":" 
                oModelGW1:SetValue("GW1_HRIMPL", SubStr(oModelGW1:GetValue('GW1_HRIMPL'),1,2) + ":" + SubStr(oModelGW1:GetValue("GW1_HRIMPL"),3,2) )
            EndIf
        Next nI

        oModelGW1:GoLine(nLineAux)
	EndIf
Return lRet
