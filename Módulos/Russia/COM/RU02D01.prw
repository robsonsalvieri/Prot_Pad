#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU02D01.CH"

#define CALLER_INFLOW_INVOICE	 		 3
#define CALLER_UPCD					 	 4

#define NOTA_CREDIT_SUPPLIER	"NCP"
#define NOTA_DEBIT_SUPPLIER		"NDP"

#define SHEET_AFTER 1
#define SHEET_INCREASE 2
#define SHEET_DECREASE 3

/*/{Protheus.doc} RU02D01
Browse for Unified Purchases Correction Document

@type function
@author E.Prokhorenko
@since 07/04/2024
@version 12.1.2310
/*/
Function RU02D01(nCaller As Numeric)

Local oBrowse		As Object
Private aRotina		As Array
Default nCaller		:= CALLER_UPCD

//Initalization of tables, if they do not exist.
DBSelectArea("F5Y")
F5Y->(DbSetOrder(4))
DBSelectArea("F5Z")
F5Z->(DbSetOrder(1))

aRotina := MenuDef(nCaller)
oBRowse := BrowseDef()
If (nCaller == CALLER_INFLOW_INVOICE)
	oBrowse:SetFilterDefault(RU02D01028_FilterUPCDBrowseByInflowlInvoice())
EndIf

oBrowse:Activate()

Return

/*/{Protheus.doc} BrowseDef
Browser Definition

@type function
@author 
@since 07/04/2024
@version 12.1.2310
@return oBrowse, object, Browser's Object
/*/
Static Function BrowseDef()
Local oBrowse	As Object

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"Unified Purchases Correction Document"
oBrowse:SetAlias("F5Y")
F5Y->(DbSetOrder(4))
RU09XFN026_HideFldBrw(oBrowse,'F5Y_CLIENT|F5Y_BRANCH|F5Y_CLINAM')//Example to remove field
oBrowse:SetDoubleClick({||FwExecView(STR0001,"RU02D01",MODEL_OPERATION_VIEW)})
oBrowse:SetFilterDefault("F5Y_ORIGIN  $ '3|4' " )
oBrowse:SetWalkThru(.F.)
oBrowse:DisableDetails(.T.)

Return oBrowse

/*/{Protheus.doc} MenuDef
Menu Definition

@type function
@author E.Prokhorenko
@since 07/04/2024
@version 12.1.2310
@return aMenu, array, Options for Menu
/*/
Static Function MenuDef(nCaller As Numeric)
	Local aMenu	As Array
	Default nCaller		:= CALLER_UPCD

	aMenu := {}
		aAdd(aMenu,;
			{STR0013, {;
				  {STR0048, 'RU02D01017_ShowInflowInvoices()', 0, MODEL_OPERATION_INSERT};
				, {STR0049, RU99XFUN06_ToCallback('RU02D01012_CreateUPCD', CALLER_UPCD, MODEL_OPERATION_INSERT), 0, MODEL_OPERATION_INSERT};
			}, 0, MODEL_OPERATION_VIEW};
		)
		aAdd(aMenu,{STR0012, "VIEWDEF.RU02D01", 0, MODEL_OPERATION_VIEW}) // View
		aAdd(aMenu,{STR0015, "VIEWDEF.RU02D01", 0, MODEL_OPERATION_DELETE, 0, Nil}) // Delete
		aAdd(aMenu,{STR0016, "VIEWDEF.RU02D01", 0, 8, 0, Nil}) // Print

Return aMenu


/*/{Protheus.doc} ModelDef
Model Definition

@type function
@author E.Prokhorenko
@since 07/04/2024
@version 12.1.2310
@return oModel, object, Model's Object
/*/
Static Function ModelDef()

Local oModel		        As Object
Local oStruF5Y	            As Object
Local oStruF5Z_After        As Object
Local oStruSD1_Before   	As Object
Local oStruSD1_Increase 	As Object
Local oStruSD1_Decrease 	As Object
Local bCommit   := {|oMdl| RU02D01002_MdlCommit(oMdl)} //Code-Block for Commit
Local bPosVald  := {|oMdl| RU02D01001_MdlPosVld(oMdl)} //Code-Block for Pos-Validation
Local bPrVldF5Y := {|oMdl, cAction, cIDField, xValue, xCurrentValue| RU02D01007_PrVldF5Y(oMdl, cAction, cIDField, xValue, xCurrentValue)}
Local bLoadBef  := {|oMdl| RU02D01006_LoadBefore(oMdl)} //Code-Block for Load Informations
Local bLoadDecrease := {|oMdl| RU02D01014_LoadDecrease(oMdl)} // code-block loads data from the SD1 table into the Decrease tab

oModel	:= MPFormModel():New("RU02D01", /*Pre-Validation*/, bPosVald /*Pos-Validation*/, bCommit, /*Cancel*/)
oModel:SetDescription(STR0001) //"Incoming Invoice Correction"

oStruF5Y			:= FWFormStruct(1, "F5Y")
oStruF5Z_After   	:= FWFormStruct(1, "F5Z")
oStruSD1_Before  	:= FWFormStruct(1, "SD1")
oStruSD1_Increase  	:= FWFormStruct(1, "SD1")
oStruSD1_Decrease  	:= FWFormStruct(1, "SD1")

	//SetProperties
oStruF5Y:SetProperty( 'F5Y_DOC' , MODEL_FIELD_OBRIGAT, .T.)

oStruSD1_Before:SetProperty('*', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, 'AllwaysFalse()'))
oStruSD1_Decrease:SetProperty('*', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, 'AllwaysFalse()'))
oStruSD1_Increase:SetProperty('*', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, 'AllwaysFalse()'))

oStruSD1_Decrease:SetProperty('*', MODEL_FIELD_VALID, {|| .T. })
oStruSD1_Increase:SetProperty('*', MODEL_FIELD_VALID, {|| .T. })

oStruSD1_Before:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.) //Temporary, because need more implementations
oStruSD1_Decrease:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.) //Temporary, because need more implementations
oStruSD1_Increase:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.) //Temporary, because need more implementations

oStruF5Z_After:SetProperty('F5Z_ITEM', MODEL_FIELD_INIT , {||RU02D01029(oModel)}) //Add treatment for standard entrey (item sequence)
	
oStruF5Z_After:AddTrigger("F5Z_TOTAL" , "F5Z_TOTAL" ,,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_TOTAL")})
oStruF5Z_After:AddTrigger("F5Z_BASE"  , "F5Z_BASE"  ,,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_BASE")})
oStruF5Z_After:AddTrigger("F5Z_VATVL" , "F5Z_VATVL" ,,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_VATVL")})
oStruF5Z_After:AddTrigger("F5Z_GROSS" , "F5Z_GROSS" ,,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_GROSS")})
oStruF5Z_After:AddTrigger("F5Z_TOTAL1", "F5Z_TOTAL1",,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_TOTAL1")})
oStruF5Z_After:AddTrigger("F5Z_BASE1" , "F5Z_BASE1" ,,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_BASE1")})
oStruF5Z_After:AddTrigger("F5Z_VATVL1", "F5Z_VATVL1",,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_VATVL1")})
oStruF5Z_After:AddTrigger("F5Z_GROSS1", "F5Z_GROSS1",,  {|oModel| RU02D01013_RUTrigger(oModel, "F5Z_GROSS1")})
	
oModel:AddFields("F5YMASTER", , oStruF5Y, bPrVldF5Y)
oModel:AddGrid("F5ZDETAIL_AFTER", "F5YMASTER", oStruF5Z_After)

oModel:SetRelation("F5ZDETAIL_AFTER", {{"F5Z_FILIAL", "FWxFilial('F5Z')" }, {"F5Z_UIDF5Y", "F5Y_UID" }}, F5Z->(IndexKey(1)))

oModel:AddGrid("SD1DETAIL_BEFORE", "F5YMASTER", oStruSD1_Before, /**/, /**/, /*Line pre-valid*/,, bLoadBef)
oModel:AddGrid("SD1DETAIL_INCREASE", "F5YMASTER", oStruSD1_Increase)

oModel:SetRelation("SD1DETAIL_INCREASE", {{"D1_FILIAL", "FWxFilial('SD1')" }, {"D1_DOC", "F5Y_DOCDEB" }, {"D1_SERIE", "F5Y_SERDEB"}, {"D1_FORNECE", "F5Y_SUPPL"}, {"D1_LOJA", "F5Y_SUPBR"}}, SD1->(IndexKey(1)))

oModel:AddGrid("SD1DETAIL_DECREASE", "F5YMASTER", oStruSD1_Decrease, /**/, /**/, /*bPreVld*/,, bLoadDecrease)

	//Set Optional
oModel:SetOptional("SD1DETAIL_INCREASE", .T.)
oModel:SetOptional("SD1DETAIL_DECREASE", .T.)

Return oModel

/*/{Protheus.doc} ViewDef
View Definition

@type function
@author E.Prokhorenko
@since 07/04/2024
@version 12.1.2310
@return oView, object, View's Object
/*/
Static Function ViewDef()

Local oView					As Object
Local oModel				As Object
Local oStruF5Y_UPCD 		As Object
Local oStruF5Y_Origin 		As Object
Local oStruF5Y_Payment 		As Object
Local oStruF5Y_Total 		As Object
Local oStruSD1_Before 		As Object
Local oStruF5Z_After 		As Object
Local oStruSD1_Increase		As Object
Local oStruSD1_Decrease		As Object
Local cCmpF5Y_UPCD			As Character
Local cCmpF5Y_Origin		As Character
Local cCmpF5Y_Payment		As Character
Local cCmpF5Y_Total			As Character

	//Strings for the fields filtration
cCmpF5Y_UPCD	:= "F5Y_FILIAL;F5Y_SERIE;F5Y_DOC;F5Y_DATE;F5Y_SUPPL;F5Y_SUPBR;F5Y_SUPNAM;F5Y_CONUNI;F5Y_CURREN;F5Y_CURNAM;F5Y_EXGRAT;F5Y_SERDEB;F5Y_DOCDEB;F5Y_SERCRD;F5Y_DOCCRD;"
cCmpF5Y_Origin	:= "F5Y_ORIGIN;F5Y_SERORI;F5Y_DOCORI;F5Y_DTORI;F5Y_CNRVEN;F5Y_CNRCOD;F5Y_CNRBR;F5Y_CNRNAM;F5Y_CNECLI;F5Y_CNECOD;F5Y_CNEBR;F5Y_CNENAM;F5Y_CNTCOD;F5Y_CNTNAM;"
cCmpF5Y_Payment	:= "F5Y_COND;F5Y_CNDNAM;F5Y_CLASS;"
cCmpF5Y_Total	:= "F5Y_TOTAL;F5Y_BASE;F5Y_VATVL;F5Y_GROSS;F5Y_TOTAL1;F5Y_BASE1;F5Y_VATVL1;F5Y_GROSS1;"

oStruF5Y_UPCD		:= FWFormStruct(2, "F5Y", {|x| (AllTrim(x) + ";" $ cCmpF5Y_UPCD)})
oStruF5Y_Origin		:= FWFormStruct(2, "F5Y", {|x| (AllTrim(x) + ";" $ cCmpF5Y_Origin)})
oStruF5Y_Payment	:= FWFormStruct(2, "F5Y", {|x| (AllTrim(x) + ";" $ cCmpF5Y_Payment)})
oStruF5Y_Total		:= FWFormStruct(2, "F5Y", {|x| (AllTrim(x) + ";" $ cCmpF5Y_Total)})
oStruSD1_Before 	:= FWFormStruct(2, "SD1")
oStruF5Z_After 		:= FWFormStruct(2, "F5Z")
oStruSD1_Increase 	:= FWFormStruct(2, "SD1")
oStruSD1_Decrease 	:= FWFormStruct(2, "SD1")

	//Remove Fields
oStruF5Z_After:RemoveField("F5Z_UIDF5Y")
oStruF5Z_After:RemoveField("F5Z_UIDORI")
oStruF5Z_After:RemoveField("F5Y_F5QUID")

oModel 	:= FWLoadModel("RU02D01")

oView 	:= FWFormView():New()

oView:SetModel(oModel)
oView:SetDescription(STR0001)

oView:AddField("F5Y_UPCD"	, oStruF5Y_UPCD		, "F5YMASTER")
oView:AddField("F5Y_Origin"	, oStruF5Y_Origin	, "F5YMASTER")
oView:AddField("F5Y_Payment", oStruF5Y_Payment	, "F5YMASTER")
oView:AddField("F5Y_Total"	, oStruF5Y_Total	, "F5YMASTER")

oView:AddGrid("SD1_Before"	, oStruSD1_Before	, "SD1DETAIL_BEFORE")
oView:AddGrid("F5Z_After"	, oStruF5Z_After	, "F5ZDETAIL_AFTER")

oView:AddGrid("SD1_Increase", oStruSD1_Increase	, "SD1DETAIL_INCREASE")
oView:AddGrid("SD1_Decrease", oStruSD1_Decrease	, "SD1DETAIL_DECREASE")

oView:CreateHorizontalBox("bHeader"	, 35)
oView:CreateHorizontalBox("bMiddle"	, 20)
oView:CreateHorizontalBox("bLow"	, 30)
oView:CreateHorizontalBox("bTotal"	, 15)

oView:CreateFolder("fUPCD"	,"bHeader")
oView:CreateFolder("fBefore","bMiddle")
oView:CreateFolder("fAfter"	, "bLow")

oView:AddSheet("fUPCD"	, "sULPD"		, STR0001) //"UPCD"
oView:AddSheet("fUPCD"	, "sOrigin"		, STR0002) //"Origin"
oView:AddSheet("fUPCD"	, "sPayment"	, STR0009) //"Payment"
oView:AddSheet("fBefore", "sBefore"		, STR0004) //"Before"
oView:AddSheet("fAfter"	, "sAfter"		, STR0005) //"After"
oView:AddSheet("fAfter"	, "sIncrease"	, STR0006) //"Increase"
oView:AddSheet("fAfter"	, "sDecrease"	, STR0007) //"Decrease"

oView:CreateHorizontalBox("bUPCD"		, 100, , , "fUPCD"		, "sULPD")
oView:CreateHorizontalBox("bOrigin"		, 100, , , "fUPCD"		, "sOrigin")
oView:CreateHorizontalBox("bPayment"	, 100, , , "fUPCD"		, "sPayment")
oView:CreateHorizontalBox("bBefore"		, 100, , , "fBefore"	, "sBefore")
oView:CreateHorizontalBox("bAfter"		, 100, , , "fAfter"		, "sAfter")
oView:CreateHorizontalBox("bIncrease"	, 100, , , "fAfter"		, "sIncrease")
oView:CreateHorizontalBox("bDecrease"	, 100, , , "fAfter"		, "sDecrease")

oView:SetOwnerView("F5Y_UPCD"		, "bUPCD")
oView:SetOwnerView("F5Y_Origin"		, "bOrigin")
oView:SetOwnerView("F5Y_Payment"	, "bPayment")
oView:SetOwnerView("SD1_Before"		, "bBefore")
oView:SetOwnerView("F5Z_After"		, "bAfter")
oView:SetOwnerView("SD1_Increase"	, "bIncrease")
oView:SetOwnerView("SD1_Decrease"	, "bDecrease")
oView:SetOwnerView("F5Y_Total"		, "bTotal")

oView:SetViewCanActivate({|oView| RU02D01018_SettingsActivation(oView)})
oView:SetAfterViewActivate({|oView| RU02D01016_SettingsBeforeActivation(oView)})

Return oView

/*/{Protheus.doc} RU02D01001_MdlPosVld
Model Pós Validation
@type function
@author Rafael Gonçalves
@since May|2020
@version 12.1.2310
@param oModel, object, Model Object
@return lReturn, Process Control
/*/

Static Function RU02D01001_MdlPosVld(oModel As Object)
Local lAllowQnt as Logical  // Allow D1_QUANT changing
Local lReturn  	as Logical 	//Process Control
Local nOper    	as Numeric 	//Operation
Local oMdlInc  	as Object 	//Increase Model
Local oMdlDec  	as Object 	//Decrease Model
Local nI       	as Numeric 	//For control 
Local cQuery 	as Character
Local aArea   	as Array	//Save position 
Local cHelpMsg 	as Character//Aditional information at help message

//Initialize Variables
aArea := GetArea()
lReturn  := .T. //Process Control
nOper    := oModel:GetOperation() //Operation
oMdlInc  := oModel:GetModel("SD1DETAIL_INCREASE")
oMdlDec  := oModel:GetModel("SD1DETAIL_DECREASE")

//Verify Operation
If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE

	RU02D01020_RecalcFolder(oModel, 2, "SD1DETAIL_INCREASE") //recalculate increase folder
	If .Not. oMdlInc:IsEmpty() //Increase --> Debit
		For nI := 01 To oMdlInc:Length()//Loop Itens and check TES is Filled
			oMdlInc:GoLine(nI)
			SF4->(DbSetOrder(1))

			If SF4->(DbSeek(xFilial('SF4') + oMdlInc:GetValue("D1_TES"))) 
				lAllowQnt := SF4->F4_QTDZERO <> "1"

				If oMdlInc:GetValue("D1_QUANT") <= 0 .And. lAllowQnt //correctio price (qtd zero, TIO must allow Zero qtd)
					Help(" ", 01, "MdlPreVld01", " ", STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044+" "+oMdlInc:GetValue("D1_ITEM")}) // "One or more itens at Increase Folder has invalid TIO."  "Selected a correct TIO that accept zero quantities at folder After"
					lReturn  := .F. //Process Control
					Exit
				ElseIf oMdlInc:GetValue("D1_QUANT") > 0 .And. .Not. lAllowQnt //check if TIO are not mark with allow zero quantity
					Help(" ", 01, "MdlPreVld02", " ", STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0041+" "+oMdlInc:GetValue("D1_ITEM")}) // "One or more itens at Increase Folder has invalid TIO."  "Selected a correct TIO that not accept zero quantities at folder After"
					lReturn  := .F. //Process Control
					Exit
				EndIf	
			Endif
		Next nI	
	EndIf

	If (lReturn)
		RU02D01020_RecalcFolder(oModel, 3, "SD1DETAIL_DECREASE")
		If .Not. oMdlDec:IsEmpty() //Decrease --> Credit

			For nI := 01 To oMdlDec:Length()//Loop Itens and check TES is Filled
				oMdlDec:GoLine(nI)
				SF4->(DbSetOrder(1))

				If SF4->(DbSeek(xFilial('SF4')+oMdlDec:GetValue("D1_TES"))) 
					lAllowQnt := SF4->F4_QTDZERO <> "1" 

					If oMdlDec:GetValue("D1_QUANT") <= 0 .And. lAllowQnt //correctio price (qtd zero, TIO must allow Zero qtd)
						Help(" ", 01, "MdlPreVld01", " ", STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044+" "+oMdlDec:GetValue("D1_ITEM")}) // "One or more itens at Decrease Folder has invalid TIO."  "Select one TIO that accept zero quantities at folder After"
						lReturn  := .F. //Process Control
						Exit
					ElseIf oMdlDec:GetValue("D1_QUANT") > 0 .And. .Not. lAllowQnt //check if TIO are not mark with allow zero quantity
						Help(" ", 01, "MdlPreVld02", " ", STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0041+" "+oMdlDec:GetValue("D1_ITEM")}) // "One or more itens at Increase Folder has invalid TIO."  "Selected a correct TIO that not accept zero quantities at folder After"
						lReturn  := .F. //Process Control
						Exit
					EndIf	
				Endif
			Next nI
		EndIf
	EndIf
ElseIf nOper == MODEL_OPERATION_DELETE

	//Check if UPCD is base for another UPCD
	cQuery := " SELECT F5Y_DOC FROM " + RetSQLName("F5Y") + " WHERE"
	cQuery += " 	F5Y_FILIAL = '" + FwxFilial("F5Y") +"' AND F5Y_SUPPL = '" + F5Y->F5Y_SUPPL + "'"
	cQuery += " 	AND F5Y_SUPBR = '" + F5Y->F5Y_SUPBR + "' AND F5Y_SERORI = '" + F5Y->F5Y_SERORI + "'"
	cQuery += " 	AND F5Y_DOCORI = '" + F5Y->F5Y_DOC + "' AND D_E_L_E_T_ = ' '  and F5Y_ORIGIN ='4' "
	// F5Y_ORIGIN - 1=Commercial Invoice; 2=ULCD; 3-Inflow Invoice; 4-UPCD
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))
	(cTab)->(dbGoTop())
	If (!(cTab)->(Eof()))
		cHelpMsg := ''
		While (!(cTab)->(Eof()))
			If !Empty(cHelpMsg)
				cHelpMsg += ", "
			Endif
			cHelpMsg += " " + alltrim((cTab)->F5Y_DOC) 
			(cTab)->(DbSkip())
		EndDo

		Help(" ", 01, "MdlDelVld01", " ", STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0018 + ":  "+cHelpMsg+"."}) //This UPCD cannot be deleted === This UPCD is used as base for UPCD
		lReturn  := .F. //Process Control				
	Endif

EndIf

RestArea(aArea)
Return lReturn

/*/{Protheus.doc} RU02D01002_MdlCommit
Model Commit

@type function
@author 
@since 2024/02/08
@version 12.1.2310
@param oModel, object, Model Object
@return lReturn, Process Control
/*/
Static Function RU02D01002_MdlCommit(oModel As Object)

Local lReturn  		As Logical	//Process Control
Local nOper    		As Numeric	//Operation
Local oMdlF5Y  		As Object 	//F5Y Model
Local oMdlF5Z  		As Object 	//F5Z Model
Local oMdlBef  		As Object 	//Before Model
Local oMdlInc  		As Object 	//Increase Model
Local oMdlDec  		As Object 	//Decrease Model
Local oView	   		As Object 	//oView

	//Initialize Variables
lReturn  := .T. //Process Control
nOper    := oModel:GetOperation() //Operation
oMdlF5Y  := oModel:GetModel("F5YMASTER")
oMdlF5Z  := oModel:GetModel("F5ZDETAIL_AFTER")
oMdlBef  := oModel:GetModel("SD1DETAIL_BEFORE")
oMdlInc  := oModel:GetModel("SD1DETAIL_INCREASE")
oMdlDec  := oModel:GetModel("SD1DETAIL_DECREASE")

lReturn := RU05XFN010_CheckModel(oModel, "RU02D01")

dbSelectArea("SX5")
dbSetOrder(1)
If lReturn
	//Begin Transaction
	BeginTran()
		//Verify Operation
		Do Case
			Case nOper == MODEL_OPERATION_INSERT //Add
				If (lReturn)
					If (!oMdlInc:IsEmpty()) //Increase --> Debit 
						FWMsgRun( , {|| lReturn := lReturn .and. RU02D01003_Debt(oModel) } ,, STR0038)
					Else // oMdlInc:IsEmpty() == true
						lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_SERDEB", Space(TamSX3("F5Y_SERDEB")[01]))
					EndIf
				EndIf

				If (lReturn)
					If (!oMdlDec:IsEmpty()) //Decrease --> Credit
						FWMsgRun( , {|| lReturn := lReturn .and. RU02D01004_Crdt(oModel) } ,, STR0039)
					Else // oMdlDec:IsEmpty() == true
						lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_SERCRD", Space(TamSX3("F5Y_SERCRD")[01]))
					EndIf
				EndIf

					//Execute Compensation
				If (lReturn .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCDEB"))) .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCCRD"))))
					FWMsgRun( , {|| lReturn := lReturn .and. RU02D01005_Comp(oMdlF5Y, nOper) } ,, STR0040)
				EndIf

				If (lReturn)
					//Document and Serie
					cDocNum := (oMdlF5Y:GetValue("F5Y_DOC"))
					lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_DOC", cDocNum)
					cSerie  := (oMdlF5Y:GetValue("F5Y_SERIE"))
					lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_SERIE", cSerie)
				EndIf

				If (lReturn)
					oModel:GetModel("SD1DETAIL_BEFORE"):SetOnlyQuery(.T.)
					oModel:GetModel("SD1DETAIL_INCREASE"):SetOnlyQuery(.T.)
					oModel:GetModel("SD1DETAIL_DECREASE"):SetOnlyQuery(.T.)
					FWFormCommit(oModel)
				EndIf
			Case nOper == MODEL_OPERATION_UPDATE //Edit
				lReturn := .F.
				Help(" ", 01, "MdlCommit:02", , STR0035, 04, 15)
			Case nOper == MODEL_OPERATION_DELETE //Delete
				//Storno of Compensation
				If (lReturn .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCDEB"))) .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCCRD"))))
					FWMsgRun( , {|| lReturn := RU02D01005_Comp(oMdlF5Y, nOper) } ,, STR0034) //"Canceling Compensation..."
				EndIf

				//Delete Debit Note
				If (lReturn .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCDEB"))))
					FWMsgRun( , {|| lReturn := RU02D01003_Debt(oModel) } ,, STR0027) //"Deleting Debit Invoice..."
				EndIf

				//Delete Credit Note
				If (lReturn .AND. !(Empty(oMdlF5Y:GetValue("F5Y_DOCCRD"))))
					FWMsgRun( , {|| lReturn := RU02D01004_Crdt(oModel) } ,, STR0028) //"Deleting Credit Invoice..."
				EndIf

				If (lReturn)
					oModel:GetModel("SD1DETAIL_BEFORE"):SetOnlyQuery(.T.)
					oModel:GetModel("SD1DETAIL_INCREASE"):SetOnlyQuery(.T.)
					oModel:GetModel("SD1DETAIL_DECREASE"):SetOnlyQuery(.T.)
					FWFormCommit(oModel)
				EndIf
		EndCase
	//Check Transaction
	If !(lReturn)
		DisarmTransaction()
	EndIf
	//End Transaction
	EndTran()
	
	//Go To Line 01
	oMdlF5Z:GoLine(01)

	If (oModel:HasErrorMessage())
		RU05XFN008_Help(oModel)
	EndIf
	If !isBlind()
		oView	:= FWViewActive()
		oView:Refresh()
	EndIf
Else
	Help(" ", 01, "MdlCommit_02", ,STR0037, 04, 15) //"No corrections found"
EndIf

Return lReturn


/*/{Protheus.doc} RU02D01003_Debt
Create Debit Note

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param oModel       , object  , Root Model
@return lReturn     , Process Control
/*/
Static Function RU02D01003_Debt(oModel as Object)
Local lReturn 			As Logical 	//Process Control
Local aArea	  			As Array
Local aSF1    			As Array 	//Array for SF1 Fields
Local aSD1    			As Array 	//Array for SD1 Fields
Local aItem   			As Array 	//Item Array
Local aDocInf 			As Array 	//Document Informations
Local nI      			As Numeric 	//Loop Control
Local cNFOrig 			As Character//Origin Document
Local cSeriOr 			As Character//Origin Series
Local xValue 						// for any temporary value

Local oMdlF5Y			As Object	// Header model
Local oMdlF5Z			As Object	// Grid model with new values after changes
Local oMdlInc			As Object	// Grid model with increased quantity or price of products
Local nOper				As Numeric	// Numeric type of current operation
Local aLog		 		As Array
Local cMSAUTOLOG  		As Character

Private lMsErroAuto 	As Logical 	//MsExecAuto Error Control
Private lAutoErrNoFile  As Logical

//Initialize Variables
lReturn     := .T.
aArea		:= GetArea()
aSF1        := {}
aSD1        := {}
aItem       := {}
lMsErroAuto := .F.
lAutoErrNoFile  := .T.

If (lReturn	:= lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01"))
	oMdlF5Y	:= oModel:GetModel("F5YMASTER")
	oMdlF5Z	:= oModel:GetModel("F5ZDETAIL_AFTER")
	oMdlInc	:= oModel:GetModel("SD1DETAIL_INCREASE")
	nOper	:= oModel:GetOperation()
EndIf

If (lReturn := lReturn .and. RU02D01027_SeekOriginalInflowInvoice(oModel, @cNFOrig, @cSeriOr))
	//Fill SF1 Fields
	AAdd(aSF1, {"F1_FILIAL"	, FWxFilial("SF1")              , Nil})
	AAdd(aSF1, {"F1_FORNECE", oMdlF5Y:GetValue("F5Y_SUPPL") , Nil})
	AAdd(aSF1, {"F1_LOJA"   , oMdlF5Y:GetValue("F5Y_SUPBR") , Nil})
	If !(Empty(oMdlF5Y:GetValue("F5Y_DOCDEB")))
		AAdd(aSF1, {"F1_DOC"    , PadR(AllTrim(oMdlF5Y:GetValue("F5Y_DOCDEB")), TamSX3("F1_DOC")[01])  , Nil})
		AAdd(aSF1, {"F1_SERIE"	, PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERDEB")), TamSX3("F1_SERIE")[01]), Nil})
		AAdd(aSF1, {"F1_PREFIXO", PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERDEB")), TamSX3("F1_SERIE")[01]), Nil})
	Else
		//Get Document and Series
		aDocInf := {}	
		Aadd(aDocInf,oMdlF5Y:GetValue("F5Y_DOC"))
		Aadd(aDocInf,oMdlF5Y:GetValue("F5Y_SERIE"))

		If (Len(aDocInf) > 0)
			AAdd(aSF1, {"F1_SERIE"  , aDocInf[02]	            , Nil})
			AAdd(aSF1, {"F1_DOC"	, aDocInf[01]               , Nil})
			AAdd(aSF1, {"F1_PREFIXO", aDocInf[02]               , Nil})
			
			//Fil Debit Document and Series
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_DOCDEB", aDocInf[01])
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_SERDEB", aDocInf[02])
			//Fill Accounting Posting Date
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_DTLA", dDatabase)
		EndIf
	EndIf
EndIf

If (lReturn)
	AAdd(aSF1, {"F1_TIPODOC", "09"	 	                    , Nil}) //6 = NCI / 7=NCP / 8=NDI / 9=NDP
	AAdd(aSF1, {"F1_TIPO"	, "C"	 	                    , Nil}) 
	AAdd(aSF1, {"F1_COND"  	, oMdlF5Y:GetValue("F5Y_COND")	, Nil})
	AAdd(aSF1, {"F1_ESPECIE", NOTA_DEBIT_SUPPLIER			, Nil})
	AAdd(aSF1, {"F1_FORMUL" , "N" 		                    , Nil}) //Form proper
	AAdd(aSF1, {"F1_EMISSAO", oMdlF5Y:GetValue("F5Y_DATE")  , Nil})
	AAdd(aSF1, {"F1_DTDIGIT", oMdlF5Y:GetValue("F5Y_DATE")  , Nil}) 
	AAdd(aSF1, {"F1_EST"	, Posicione("SA2", 01, FWxFilial("SA2") + oMdlF5Y:GetValue("F5Y_SUPPL") + oMdlF5Y:GetValue("F5Y_SUPBR"), "A2_EST"), Nil})
	AAdd(aSF1, {"F1_MOEDA"	, Val(oMdlF5Y:GetValue("F5Y_CURREN")), Nil})



	AAdd(aSF1, {"F1_NATUREZ", oMdlF5Y:GetValue("F5Y_CLASS")	, Nil})
	AAdd(aSF1, {"F1_CNEEBUY", oMdlF5Y:GetValue("F5Y_CNECLI"), Nil})
	AAdd(aSF1, {"F1_CNORSUP", oMdlF5Y:GetValue("F5Y_CNRVEN"), Nil})

	AAdd(aSF1, {"F1_CNORCOD", oMdlF5Y:GetValue("F5Y_CNRCOD"), Nil})
	AAdd(aSF1, {"F1_CNORBR" , oMdlF5Y:GetValue("F5Y_CNRBR") , Nil})
	AAdd(aSF1, {"F1_CNEECOD", oMdlF5Y:GetValue("F5Y_CNECOD"), Nil})
	AAdd(aSF1, {"F1_CNEEBR" , oMdlF5Y:GetValue("F5Y_CNEBR") , Nil})
	AAdd(aSF1, {"F1_CONUNI" , oMdlF5Y:GetValue("F5Y_CONUNI"), Nil})
	
	AAdd(aSF1, {"F1_CNTID" 	, oMdlF5Y:GetValue("F5Y_CNTCOD"), Nil})
	AAdd(aSF1, {"F1_F5QUID" , oMdlF5Y:GetValue("F5Y_F5QUID"), Nil})

	//Fill Exchange Rate
	If (oMdlF5Y:GetValue("F5Y_EXGRAT") == 0)
		//Seek Rate
		SM2->(DbSetOrder(01)) //M2_DATA
		If (SM2->(DBSeek(DToS(oMdlF5Y:GetValue("F5Y_DATE")))))
			AAdd(aSF1, {"F1_TXMOEDA", RecMoeda(oMdlF5Y:GetValue("F5Y_DATE"),Val(oMdlF5Y:GetValue("F5Y_CURREN"))), Nil})
		EndIf
	Else
		AAdd(aSF1, {"F1_TXMOEDA", oMdlF5Y:GetValue("F5Y_EXGRAT"), Nil})
	EndIf
	
	AADD(aSF1, {"F1_NFORIG"	, cNFOrig						, Nil})
	AADD(aSF1, {"F1_SERORIG", cSeriOr						, Nil})
	//01/10/19:Calculate Total Values
	AAdd(aSF1, {"F1_VALMERC" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_TOTAL")	, Nil})
	AAdd(aSF1, {"F1_BASIMP1" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_BASIMP1"), Nil})
	AAdd(aSF1, {"F1_VALIMP1" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_VALIMP1"), Nil})
	AAdd(aSF1, {"F1_VALBRUT" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_VALBRUT"), Nil})
	AAdd(aSF1, {"F1_VLMERCM" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_TOTALM") , Nil})
	AAdd(aSF1, {"F1_BSIMP1M" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_BSIMP1M"), Nil})
	AAdd(aSF1, {"F1_VLIMP1M" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_VLIMP1M"), Nil})
	AAdd(aSF1, {"F1_VLBRUTM" , RU02D01015_CalculateTotalValue(oMdlInc, "D1_VLBRUTM"), Nil})
	//Order according SX3
	aSF1 := FWVetByDic(aSF1, "SF1")

	//Fill SD2 Fields
	If !(oMdlInc:IsEmpty())
		For nI := 01 To oMdlInc:Length()
			//Go Line
			oMdlInc:GoLine(nI)
			//Verify if Deleted
			If !(oMdlInc:IsDeleted(nI))
				//Verify fields Filled
				aItem := {}
				AAdd(aItem,{"D1_FILIAL" , FWxFilial("SD1")              , Nil})
				AAdd(aItem,{"D1_COD"	, oMdlInc:GetValue("D1_COD")    , NIL})
				AAdd(aItem,{"D1_UM"     , oMdlInc:GetValue("D1_UM")     , NIL})

				AAdd(aItem,{"D1_QUANT"	, oMdlInc:GetValue("D1_QUANT")	, NIL})
				AAdd(aItem,{"D1_VUNIT"  , oMdlInc:GetValue("D1_VUNIT") , NIL})
				AAdd(aItem,{"D1_TOTAL"	, oMdlInc:GetValue("D1_TOTAL")	, NIL})
				AAdd(aItem,{"D1_BASIMP1", oMdlInc:GetValue("D1_BASIMP1"), NIL})
				AAdd(aItem,{"D1_VALIMP1", oMdlInc:GetValue("D1_VALIMP1"), NIL})
				AAdd(aItem,{"D1_VALBRUT", oMdlInc:GetValue("D1_VALBRUT"), NIL})
				AAdd(aItem,{"D1_TOTALM"	, oMdlInc:GetValue("D1_TOTALM")	, NIL})
				AAdd(aItem,{"D1_BSIMP1M", oMdlInc:GetValue("D1_BSIMP1M"), NIL})
				AAdd(aItem,{"D1_VLIMP1M", oMdlInc:GetValue("D1_VLIMP1M"), NIL})
				AAdd(aItem,{"D1_VLBRUTM", oMdlInc:GetValue("D1_VLBRUTM"), NIL})
				AAdd(aItem,{"D1_ALQIMP1", oMdlInc:GetValue("D1_ALQIMP1"), NIL})

				AAdd(aItem,{"D1_TES"	, oMdlInc:GetValue("D1_TES")	, NIL})
				AAdd(aItem,{"D1_CF"     , oMdlInc:GetValue("D1_CF")	    , NIL})
				AAdd(aItem,{"D1_LOCAL"	, oMdlInc:GetValue("D1_LOCAL")	, NIL})
				AAdd(aItem,{"D1_CONTA"	, oMdlInc:GetValue("D1_CONTA")	, NIL})
				AAdd(aItem,{"D1_CC"		, oMdlInc:GetValue("D1_CC")	    , NIL})
				AAdd(aItem,{"D1_ITEMCTA", oMdlInc:GetValue("D1_ITEMCTA"), NIL})
				AAdd(aItem,{"D1_CLVL"	, oMdlInc:GetValue("D1_CLVL")	, NIL})
				AAdd(aItem,{"D1_ESPECIE", NOTA_DEBIT_SUPPLIER			, NIL})
				AAdd(aItem,{"D1_NFORI"	, cNFOrig                       , NIL})
				AAdd(aItem,{"D1_SERIORI", cSeriOr                       , NIL})
				AAdd(aItem,{"D1_ITEMORI",;
					 RU02D01030(oMdlF5Y:GetValue("F5Y_SUPPL"), oMdlF5Y:GetValue("F5Y_SUPBR"),cNFOrig, cSeriOr, oMdlInc:GetValue("D1_COD"),oMdlInc:GetValue("D1_ITEM") );
					 , NIL})

				If (!Empty(xValue := oMdlInc:GetValue("D1_LOTECTL")))
					AAdd(aItem,{"D1_LOTECTL", xValue, NIL})
				EndIf
				If (!Empty(xValue := oMdlInc:GetValue("D1_DTVALID")))
					AAdd(aItem,{"D1_DTVALID", xValue, NIL})
				EndIf
				//Order according SX3
				aItem := FWVetByDic(aItem, "SD1")
				//Add in Total array
				AAdd(aSD1, AClone(aItem))
			EndIf
		Next nI
	EndIf

	//Call ExecAuto
	If (Len(aSF1) > 0 .AND. Len(aSD1) > 0)
		MSExecAuto({|x, y, z| MATA466N(x, y, z)}, aSF1, aSD1, nOper)
		If lMsErroAuto 
			If IsBlind()
				aLog	:= GetAutoGRLog()
				cMSAUTOLOG := ""
				aEval( aLog, { |x| cMSAUTOLOG+= x+CRLF})
				oModel:SetErrorMessage(,,,,'MATA466N',cMSAUTOLOG)
				//Help(" ", 01, "MATA465N"  , , cMSAUTOLOG, 1, 1) 
			Else	
				MostraErro()
			Endif
			lReturn := .F.
		Endif
	EndIf
EndIf
RestArea(aArea)

Return lReturn

/*/{Protheus.doc} RU02D01004_Crdt
Create Credit Note

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param oModel       , object  , Root Model
@return lReturn     , Process Control
/*/
Static Function RU02D01004_Crdt(oModel as Object)

Local lReturn 		As Logical //Process Control
Local aArea   		As Array
Local aSF2    		As Array //Array for SF2 Fields
Local aSD2    		As Array //Array for SD2 Fields
Local aItem   		As Array //Item Array
Local aDocInf 		As Array //Document Informations
Local nI      		As Numeric //Loop Control
Local cNFOrig 		As Character //Origin Document
Local cSeriOr 		As Character //Origin Series
Local xValue // for any temporary value

Local oMdlF5Y		As Object	// Header model
Local oMdlF5Z		As Object	// Grid model with new values after changes
Local oMdlDec		As Object	// Grid model with decreased quantity or price of products
Local nOper			As Numeric	// Numeric type of current operation
Local aLog		 	As Array
Local cMSAUTOLOG 	As Character
Private lAutoErrNoFile  As Logical //MsexecAuto save error on file
Private lMsErroAuto As Logical //MsExecAuto Error Control

//Initialize Variables
lReturn     := .T.
aArea		:= GetArea()
aSF2        := {}
aSD2        := {}
aItem       := {}
lMsErroAuto := .F.
lAutoErrNoFile  := .T.

If (lReturn	:= lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01"))
	oMdlF5Y	:= oModel:GetModel("F5YMASTER")
	oMdlF5Z	:= oModel:GetModel("F5ZDETAIL_AFTER")
	oMdlDec	:= oModel:GetModel("SD1DETAIL_DECREASE")
	nOper	:= oModel:GetOperation()
EndIf

If (lReturn	:= lReturn .and. RU02D01027_SeekOriginalInflowInvoice(oModel, @cNFOrig, @cSeriOr))
	//Fill SF2 Fields
	AAdd(aSF2, {"F2_FILIAL"	, FWxFilial("SF2")              , Nil})
	AAdd(aSF2, {"F2_CLIENTE", oMdlF5Y:GetValue("F5Y_SUPPL") , Nil})
	AAdd(aSF2, {"F2_LOJA"   , oMdlF5Y:GetValue("F5Y_SUPBR") , Nil})

	If !(Empty(oMdlF5Y:GetValue("F5Y_DOCCRD")))
		AAdd(aSF2, {"F2_DOC"    , PadR(AllTrim(oMdlF5Y:GetValue("F5Y_DOCCRD")), TamSX3("F2_DOC")[01])  , Nil})
		AAdd(aSF2, {"F2_SERIE"	, PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERCRD")), TamSX3("F2_SERIE")[01]), Nil})
		AAdd(aSF2, {"F2_PREFIXO", PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERCRD")), TamSX3("F2_SERIE")[01]), Nil})
	Else
		//Get Document and Series
		aDocInf := {}	
		Aadd(aDocInf,oMdlF5Y:GetValue("F5Y_DOC"))
		Aadd(aDocInf,oMdlF5Y:GetValue("F5Y_SERIE"))

		If (Len(aDocInf) > 0)
			AAdd(aSF2, {"F2_SERIE"  , aDocInf[02]	                , Nil})
			AAdd(aSF2, {"F2_DOC"	, aDocInf[01]                   , Nil})
			AAdd(aSF2, {"F2_PREFIXO", aDocInf[02]               	, Nil})
			//Fil Credit Document and Series
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_DOCCRD", aDocInf[01])
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_SERCRD", aDocInf[02])
			//Fill Accounting Posting Date
			lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_DTLA", dDatabase)
		EndIf
	EndIf
EndIf

If (lReturn)
	AAdd(aSF2, {"F2_TIPODOC", "07"	 	                    , Nil}) //6 = NCI / 7=NCP / 8=NDI / 9=NDP
	AAdd(aSF2, {"F2_TIPO"	, "D"	 	                    , Nil})
	AAdd(aSF2, {"F2_COND"	, oMdlF5Y:GetValue("F5Y_COND")	, Nil})
	AAdd(aSF2, {"F2_ESPECIE", NOTA_CREDIT_SUPPLIER			, Nil})
	AAdd(aSF2, {"F2_FORMUL" , "N" 		                    , Nil}) //Form proper
	AAdd(aSF2, {"F2_EMISSAO", oMdlF5Y:GetValue("F5Y_DATE")  , Nil})
	AAdd(aSF2, {"F2_DTSAIDA", oMdlF5Y:GetValue("F5Y_DATE")  , Nil})
	AAdd(aSF2, {"F2_EST"	, Posicione("SA2", 01, FWxFilial("SA2") + oMdlF5Y:GetValue("F5Y_SUPPL") + oMdlF5Y:GetValue("F5Y_SUPBR"), "A2_EST"), Nil})
	AAdd(aSF2, {"F2_MOEDA"	, Val(oMdlF5Y:GetValue("F5Y_CURREN")), Nil})

	AAdd(aSF2, {"F2_NATUREZ", oMdlF5Y:GetValue("F5Y_CLASS")	, Nil})
	AAdd(aSF2, {"F2_CNEECLI", oMdlF5Y:GetValue("F5Y_CNECLI"), Nil})
	AAdd(aSF2, {"F2_CNORVEN", oMdlF5Y:GetValue("F5Y_CNRVEN"), Nil})

	AAdd(aSF2, {"F2_CNORCOD", oMdlF5Y:GetValue("F5Y_CNRCOD"), Nil})
	AAdd(aSF2, {"F2_CNORBR" , oMdlF5Y:GetValue("F5Y_CNRBR") , Nil})
	AAdd(aSF2, {"F2_CNEECOD", oMdlF5Y:GetValue("F5Y_CNECOD"), Nil})
	AAdd(aSF2, {"F2_CNEEBR" , oMdlF5Y:GetValue("F5Y_CNEBR") , Nil})
	AAdd(aSF2, {"F2_CONUNI" , oMdlF5Y:GetValue("F5Y_CONUNI"), Nil})

	AAdd(aSF2, {"F2_CNTID" 	, oMdlF5Y:GetValue("F5Y_CNTCOD"), Nil})
	AAdd(aSF2, {"F2_F5QUID" , oMdlF5Y:GetValue("F5Y_F5QUID"), Nil})

	//Fill Exchange Rate
	If (oMdlF5Y:GetValue("F5Y_EXGRAT") == 0)
		//Seek Rate
		SM2->(DbSetOrder(01)) //M2_DATA
		If (SM2->(DBSeek(DToS(oMdlF5Y:GetValue("F5Y_DATE")))))
			AAdd(aSF2, {"F2_TXMOEDA",  RecMoeda(oMdlF5Y:GetValue("F5Y_DATE"),Val(oMdlF5Y:GetValue("F5Y_CURREN"))), Nil})
		EndIf
	Else
		AAdd(aSF2, {"F2_TXMOEDA", oMdlF5Y:GetValue("F5Y_EXGRAT"), Nil})
	EndIf
	AADD(aSF2, {"F2_NFORIG"	, cNFOrig						, Nil})
	AADD(aSF2, {"F2_SERORIG", cSeriOr						, Nil})

	//01/10/19:Calculate Total Values
	AAdd(aSF2, {"F2_VALMERC" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_TOTAL")   , Nil})
	AAdd(aSF2, {"F2_BASIMP1" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_BASIMP1") , Nil})
	AAdd(aSF2, {"F2_VALIMP1" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_VALIMP1") , Nil})
	AAdd(aSF2, {"F2_VALBRUT" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_VALBRUT") , Nil})
	AAdd(aSF2, {"F2_VLMERCM" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_TOTALM")  , Nil})
	AAdd(aSF2, {"F2_BSIMP1M" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_BSIMP1M") , Nil})
	AAdd(aSF2, {"F2_VLIMP1M" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_VLIMP1M") , Nil})
	AAdd(aSF2, {"F2_VLBRUTM" , RU02D01015_CalculateTotalValue(oMdlDec, "D1_VLBRUTM") , Nil})
	//Order according SX3
	aSF2 := FWVetByDic(aSF2, "SF2")

	//Fill SD1 Fields
	If !(oMdlDec:IsEmpty())
		For nI := 01 To oMdlDec:Length()
			//Go Line
			oMdlDec:GoLine(nI)
			//Verify if Deleted
			If !(oMdlDec:IsDeleted(nI))
			//Verify fields Filled
				aItem := {}
				AAdd(aItem,{"D2_FILIAL" , FWxFilial("SD1")              , Nil})
				AAdd(aItem,{"D2_COD"	, oMdlDec:GetValue("D1_COD")    , NIL})
				AAdd(aItem,{"D2_UM"     , oMdlDec:GetValue("D1_UM")     , NIL})

				AAdd(aItem,{"D2_QUANT"	, oMdlDec:GetValue("D1_QUANT")	, NIL})
				AAdd(aItem,{"D2_PRCVEN" , oMdlDec:GetValue("D1_VUNIT")  , NIL})
				AAdd(aItem,{"D2_TOTAL"	, oMdlDec:GetValue("D1_TOTAL")	, NIL})
				AAdd(aItem,{"D2_BASIMP1", oMdlDec:GetValue("D1_BASIMP1"), NIL})
				AAdd(aItem,{"D2_VALIMP1", oMdlDec:GetValue("D1_VALIMP1"), NIL})
				AAdd(aItem,{"D2_VALBRUT", oMdlDec:GetValue("D1_VALBRUT"), NIL})
				AAdd(aItem,{"D2_TOTALM"	, oMdlDec:GetValue("D1_TOTALM")	, NIL})
				AAdd(aItem,{"D2_BSIMP1M", oMdlDec:GetValue("D1_BSIMP1M"), NIL})
				AAdd(aItem,{"D2_VLIMP1M", oMdlDec:GetValue("D1_VLIMP1M"), NIL})
				AAdd(aItem,{"D2_VLBRUTM", oMdlDec:GetValue("D1_VLBRUTM"), NIL})
				AAdd(aItem,{"D2_ALQIMP1", oMdlDec:GetValue("D1_ALQIMP1"), NIL})

				AAdd(aItem,{"D2_TES"	, oMdlDec:GetValue("D1_TES")	, NIL})
				AAdd(aItem,{"D2_CF"     , oMdlDec:GetValue("D1_CF")		, NIL})
				AAdd(aItem,{"D2_LOCAL"	, oMdlDec:GetValue("D1_LOCAL")	, NIL})
				AAdd(aItem,{"D2_CONTA"	, oMdlDec:GetValue("D1_CONTA")	, NIL})
				AAdd(aItem,{"D2_CC"		, oMdlDec:GetValue("D1_CC")		, NIL})
				AAdd(aItem,{"D2_ITEMCTA", oMdlDec:GetValue("D1_ITEMCTA"), NIL})
				AAdd(aItem,{"D2_CLVL"	, oMdlDec:GetValue("D1_CLVL")	, NIL})
				AAdd(aItem,{"D2_ESPECIE", NOTA_CREDIT_SUPPLIER			, NIL})
				AAdd(aItem,{"D2_NFORI"	, cNFOrig						, NIL})
				AAdd(aItem,{"D2_SERIORI", cSeriOr						, NIL})
				AAdd(aItem,{"D2_ITEMORI",;
					 RU02D01030(oMdlF5Y:GetValue("F5Y_SUPPL"), oMdlF5Y:GetValue("F5Y_SUPBR"),cNFOrig, cSeriOr, oMdlDec:GetValue("D1_COD"),oMdlDec:GetValue("D1_ITEM") );
					 , NIL})

				If (!Empty(xValue := oMdlDec:GetValue("D1_LOTECTL")))
					AAdd(aItem,{"D2_LOTECTL", xValue , NIL})
				EndIf
				If (!Empty(xValue := oMdlDec:GetValue("D1_DTVALID")))
					AAdd(aItem,{"D2_DTVALID", xValue, NIL})
				EndIf
				//Order according SX3
				aItem := FWVetByDic(aItem, "SD2")
				//Add in Total array
				AAdd(aSD2, AClone(aItem))
			EndIf
		Next nI
	EndIf
	//Call ExecAuto			
	If (Len(aSF2) > 0 .AND. Len(aSD2) > 0)
		MSExecAuto({|x, y, z| MATA466N(x, y, z)}, aSF2, aSD2, nOper)
		If lMsErroAuto
			If IsBlind()
				aLog	:= GetAutoGRLog()
				cMSAUTOLOG := ""
				aEval( aLog, { |x| cMSAUTOLOG+= x+CRLF})
				oModel:SetErrorMessage(,,,,'MATA466N',cMSAUTOLOG)
				//Help(" ", 01, "MATA465N"  , , cMSAUTOLOG, 1, 1) 
			Else	
				MostraErro()
				MsgInfo(STR0050) //Perhaps in the previous receipt adjustment you reversed the invoice item (the item was completely canceled on the Reduction tab), which you are trying to change again
			Endif
			lReturn := .F.
		Endif
	EndIf
EndIf
	RestArea(aArea)
Return lReturn

/*/{Protheus.doc} RU02D01005_Comp
Account Receivable Compensation

@type function
@author Alison Kaique
@since May|2019
@version 12.1.2310
@param oMdlF5Y      , object   , Model Object
@param nOper        , numeric  , Operation Code
@return lReturn     , Process Control
/*/
Static Function RU02D01005_Comp(oMdlF5Y As Object, nOper As Numeric)

Local lReturn 			As Logical 	//Process Control
Local cProcessName		As Character
Local aRecCredit 		As Array 	//Origin Recno
Local aRecDebit 		As Array 	//Destination Recno
Local aStorno 			As Array 	//Storno Informations
Local cGrpSX1 			As Character //Group of Questions
Local nI				As Numeric

Private lContabiliza 	As Logical //ExecAuto Variable
Private lAglutina    	As Logical //ExecAuto Variable
Private lDigita      	As Logical //ExecAuto Variable

//Initialize Variables
lReturn      	:= .T.
cProcessName	:= ProcName()
cGrpSX1      	:= "AFI340" //Compesation Group of Questions //FIN330
aRecCredit		:= {}
aRecDebit		:= {}
aStorno      	:= {}

Pergunte(cGrpSX1, .F.) //Without interface
lContabiliza := MV_PAR11 == 02
lAglutina    := MV_PAR08 == 02
lDigita      := MV_PAR09 == 02

//Seek Account Receivables
SE2->(DbSetOrder(06)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
//Origin
cSeekCredit := FWxFilial("SE2") +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SUPPL")) , TamSX3("E2_FORNECE")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SUPBR")) , TamSX3("E2_LOJA")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERCRD")), TamSX3("E2_PREFIXO")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_DOCCRD")), TamSX3("E2_NUM")[01]) 

If (SE2->(DBSeek(cSeekCredit)))
	While ((cSeekCredit) == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM))
		If((SE2->E2_TIPO) == NOTA_CREDIT_SUPPLIER)
			aAdd(aRecCredit, SE2->(Recno()))
		EndIf
		SE2->(dbSkip())
	EndDo
Else
	Help(" ", 01, cProcessName+":01", , STR0029, 1, 1) //"Credit Account Receivable not found"
EndIf

SE2->(DbSetOrder(06))
cSeekDebit := FWxFilial("SE2") +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SUPPL")) , TamSX3("E2_FORNECE")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SUPBR")) , TamSX3("E2_LOJA")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_SERDEB")), TamSX3("E2_PREFIXO")[01]) +;
	PadR(AllTrim(oMdlF5Y:GetValue("F5Y_DOCDEB")), TamSX3("E2_NUM")[01]) 

If (SE2->(DBSeek(cSeekDebit)))
	While ((cSeekDebit) == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM))
		If((SE2->E2_TIPO) == NOTA_DEBIT_SUPPLIER)
			aAdd(aRecDebit, SE2->(Recno()))
			//Check Operation Code
			If (nOper == MODEL_OPERATION_DELETE)
				//Compensation Write-Off
				SE5->(DBSetOrder(02)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
				If (SE5->(DBSeek(FWxFilial("SE5") +;
					PadR("CP", TamSX3("E5_TIPODOC")[01]) +;
					SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + DToS(E2_BAIXA) + E2_FORNECE + E2_LOJA) ;
					)))
					//Set Storno Array
					//AAdd(aStorno, {{SE5->E5_DOCUMEN},SE5->E5_SEQ})
					AAdd(aStorno, (SE5->E5_DOCUMEN))
					//TRBFR3->(FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO)+Alltrim(Str(TRBFR3->FR3_VALOR))+TRBFR3->(FR3_DOC+FR3_SERIE)})
				Else
					Help(" ", 01, cProcessName+":02", , STR0032, 1, 1) //"Compensation Write-off not found"
				EndIf
			EndIf
		EndIf
		SE2->(dbSkip())
	EndDo
Else
	Help(" ", 01, cProcessName+":03", , STR0030, 1, 1) //"Debit Account Receivable not found"
EndIf

//Execute Compensation
If (nOper == MODEL_OPERATION_INSERT) //Insert
	If (Len(aRecCredit) > 0 .AND. Len(aRecCredit) == Len(aRecDebit))
		//Go back to Order 01
		SE2->(DbSetOrder(01)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		For nI := 1 To Len(aRecCredit)
			If !MaIntBxCP(2,aRecDebit,,aRecCredit,,{.F.,.F.,.F.,.F.,.F.,.F.},,,,,,,/*nHdlPrv*/)
				Help(" ", 01, cProcessName+":04", , STR0031, 1, 1) //"Could not process compensation"
				lReturn := .F.
			EndIf
		Next nI
	EndIf
ElseIf (nOper == MODEL_OPERATION_DELETE) //Cancel
	If (Len(aRecCredit) > 0 .AND. Len(aStorno) > 0)
		//Go back to Order 01
		SE2->(DbSetOrder(01)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If !MaIntBxCP(2,aRecDebit,,aRecCredit,,{.F.,.F.,.F.,.F.,.F.,.F.},,aStorno,,,dDataBase,,/*nHdlPrv*/)
			Help(" ", 01, cProcessName+":05", , STR0033, 1, 1) //"Could not process storno of compensation"
			lReturn := .F.
		EndIf
	EndIf
EndIf

Return lReturn

/*/{Protheus.doc} RU02D01006_LoadBefore
Load Data of Model Before (SD1)

@type function
@author Alison Kaique
@since 2024/02/08
@version 12.1.2310
@param oSubModel    , object   , Model Object
@return aData       , Data Returned
/*/
Static Function RU02D01006_LoadBefore(oSubModel As Object)

Local oModel       As Object 	//Model Active
Local oMdlF5Y      As Object 	//F5Y Model
Local nOper        As Numeric 	//Operation
Local aData        As Array 	//Data Returned
Local aArea        As Array 	//Saved Area
Local aAreaF5Y     As Array 	//Saved Area

//Initialize Variables
oModel       := oSubModel:oFormModel
oMdlF5Y      := oModel:GetModel("F5YMASTER")
nOper        := oModel:GetOperation()
aData        := {}
aArea        := GetArea()
aAreaF5Y     := F5Y->(GetArea())

//Verify Operation
If !(nOper == MODEL_OPERATION_INSERT)
	//Verify Origin
	If (oMdlF5Y:GetValue("F5Y_ORIGIN") == "3") //Inflow Invoice
		//Seek in SF1
		SF1->(DbSetOrder(01)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If (SF1->(DbSeek(FWxFilial("SF1") + oMdlF5Y:GetValue("F5Y_DOCORI") + oMdlF5Y:GetValue("F5Y_SERORI") + oMdlF5Y:GetValue("F5Y_SUPPL") + oMdlF5Y:GetValue("F5Y_SUPBR"))))
			aData := RU02D01008_Before(@oSubModel, Val(oMdlF5Y:GetValue("F5Y_ORIGIN")), 01)
		EndIf
	ElseIf (oMdlF5Y:GetValue("F5Y_ORIGIN") == "4") //Other UPCD
		//Seek in F5Y
		F5Y->(DbSetOrder(06)) //F5Y_FILIAL+F5Y_SUPPL+F5Y_SUPBR+F5Y_DOC+F5Y_SERIE 
		If (F5Y->(DbSeek(FWxFilial("F5Y") + oMdlF5Y:GetValue("F5Y_SUPPL") + oMdlF5Y:GetValue("F5Y_SUPBR") + oMdlF5Y:GetValue("F5Y_DOCORI") + oMdlF5Y:GetValue("F5Y_SERORI"))))
			aData := RU02D01008_Before(@oSubModel, Val(oMdlF5Y:GetValue("F5Y_ORIGIN")), 1)
		EndIf
	EndIf
EndIf

RestArea(aAreaF5Y)
RestArea(aArea)

Return aData

/*/{Protheus.doc} RU02D01007_PrVldF5Y
Pre Validation of Header Model (F5Y)

@type function
@author Alison Kaique
@since May|2019
@version 12.1.2310
@param oSubModel    , object   , Model Object
@param cAction      , character, Current Action
@param cIDField     , character, Current Field
@param xValue       , unknow   , New Value
@param xCurrentValue, unknow   , Current Value
@return lReturn     , Process Control
/*/
Static Function RU02D01007_PrVldF5Y(oSubModel As Object, cAction As Character, cIDField As Character, xValue, xCurrentValue)

Local oModel       As Object //Model Active
Local lReturn      As Logical //Process Control

//Initialize variables
lReturn	:= .T.
oModel	:= oSubModel:oFormModel

lReturn := lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01")

//Verify Action
Do Case
	Case AllTrim(cAction) == "ISENABLE" //Enable Grid

	Case AllTrim(cAction) == "SETVALUE" //Set Value in Field
		//Verify Field
		Do Case
			Case AllTrim(cIDField) == "F5Y_SUPBR" //Supplier Unit
				//Seek in Supplier
				SA2->(DBSetOrder(01)) //A2_FILIAL+A2_COD+A2_LOJA
				If (SA2->(DBSeek(FWxFilial("SA2") + oSubModel:GetValue("F5Y_SUPPL") + xValue)))
					//Fill associated fields
					lReturn := lReturn .and. oSubModel:SetValue("F5Y_SUPNAM", Left(SA2->A2_NOME, TamSX3("F5Y_SUPNAM")[01])) //Supplier Name
				EndIf
		EndCase
	Case AllTrim(cAction) == "CANSETVALUE" //Can Set Value in Field
EndCase //Action

If (oModel:HasErrorMessage())
	RU05XFN008_Help(oModel)
EndIf

Return lReturn

/*/{Protheus.doc} RU02D01008_Before
Fill Before Model (SD1)

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param oMdlBef , object , Model Before Object
@param nDocType, numeric, Original Document Type
@param nRetType, numeric, Return Type
@return lReturn, Process Control or aReturn, Data Informations
/*/
Static Function RU02D01008_Before(oMdlBef As Object, nDocType As Numeric, nRetType As Numeric)

Local lReturn   	As Logical //Process Control
Local aFields   	As Array //Struct Fields
Local nI        	As Numeric //Loop Control
Local nX        	As Numeric //Loop Control
Local cQuery    	As Character //String Query
Local cAlias    	As Character //Alias
Local aReturn   	As Array //Data Array
Local aRelation 	As Array //Field Relation
Local nPosField 	As Numeric //Field Position

Local oModel     	As Object //Model Active
Local oMdlAfter  	As Object //After Model
	
Default nRetType := 0

//Initialize variables
lReturn := .T.
oModel       := oMdlBef:oFormModel

lReturn := lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01")
If (lReturn)
	oMdlAfter    := oModel:GetModel("F5ZDETAIL_AFTER")
	aReturn := {}
	aRelation := RU02D01011_GetSD1_F5Z()

	If (nDocType == 03) //Inflow Invoice
		aFields := oMdlBef:GetStruct():GetFields()
		//Create String SQL
		//Select
		cQuery := "SELECT" + CRLF
		//Fields
		For nI := 01 To Len(aFields)
			//Verify Virtual Field
			If !(aFields[nI, 14])
				cQuery += "SD1." + aFields[nI, 03] + ", "
			EndIf
		Next nI
		//Recno
		cQuery += "SD1.R_E_C_N_O_ RECNO" + CRLF
		//From
		cQuery += "FROM " + RetSQLName("SD1") + " SD1" + CRLF
		//Where
		cQuery += "WHERE" + CRLF
		cQuery += "SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' AND" + CRLF
		cQuery += "SD1.D1_DOC = '" + SF1->F1_DOC + "' AND" + CRLF
		cQuery += "SD1.D1_SERIE = '" + SF1->F1_SERIE + "' AND" + CRLF
		cQuery += "SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "' AND" + CRLF
		cQuery += "SD1.D1_LOJA = '" + SF1->F1_LOJA + "' AND" + CRLF
		cQuery += "SD1.D1_TIPODOC IN ('10') AND" + CRLF
		cQuery += "SD1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "order by" + CRLF
		cQuery += "SD1.D1_FILIAL" + CRLF
		cQuery += ", SD1.D1_FORNECE" + CRLF
		cQuery += ", SD1.D1_LOJA" + CRLF
		cQuery += ", SD1.D1_SERIE" + CRLF
		cQuery += ", SD1.D1_DOC" + CRLF
		cQuery += ", SD1.D1_ITEM" + CRLF
	Else //UPCD (Corrective or Adjustment)
		aFields := oMdlAfter:GetStruct():GetFields()
		//Create String SQL
		//Select
		cQuery := "SELECT" + CRLF
		//Fields
		For nI := 01 To Len(aRelation)
			//Verify if Real Field
			nPosField := AScan(aFields, {|x| AllTrim(x[03]) == AllTrim(aRelation[nI, 01])})
			If (nPosField > 0 .AND. !(aFields[nPosField, 14]))
				cQuery += "F5Z." + aRelation[nI, 01] + " " + aRelation[nI, 02] + ", "
			EndIf
		Next nI
		//Recno
		cQuery += "F5Z.R_E_C_N_O_ RECNO" + CRLF
		cQuery += " ,SB1.B1_DESC AS D1_DESCRI" + CRLF
		//From
		cQuery += "FROM " + RetSQLName("F5Z") + " F5Z" + CRLF
		cQuery += " JOIN " + RetSQLName("SB1") + " AS SB1 ON" + CRLF
		cQuery += " F5Z.F5Z_ITMCOD = SB1.B1_COD" + CRLF
		//Where
		cQuery += "WHERE" + CRLF
		cQuery += "F5Z.F5Z_FILIAL = '" + FWxFilial("F5Z") + "' AND" + CRLF
		cQuery += "F5Z.F5Z_UIDF5Y = '" + F5Y->F5Y_UID + "' AND" + CRLF
		cQuery += "F5Z.D_E_L_E_T_ = ' '" + CRLF
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF
		cQuery += " AND SB1.D_E_L_E_T_ = ' '" + CRLF
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	PlsQuery(cQuery, cAlias)
	aReturn := FWLoadByAlias(oMdlBef, cAlias, 'SD1')
	If (nRetType == 0)
		aFields := oMdlBef:GetStruct():GetFields()
		For nI := 01 To Len(aReturn)
			If (Len(aReturn[nI, 02]) == Len(aFields))
				//Add New Line
				If (nI != 01, oMdlBef:AddLine(), )
				//Load informations
				For nX := 01 To Len(aReturn[nI, 02])
					//Verify Type
					If (aFields[nX, 04] == "C") //04
						lReturn := lReturn .and. oMdlBef:LdValueByPos(nX, Left(aReturn[nI, 02][nX], TamSX3(aFields[nX, 03])[01]))
					Else
						lReturn := lReturn .and. oMdlBef:LdValueByPos(nX, aReturn[nI, 02][nX])
					EndIf
				Next nX
			EndIf
		Next nI
		oMdlBef:GoLine(01)
	EndIf
	CloseTempTable(cAlias)
EndIf

If (oModel:HasErrorMessage())
	RU05XFN008_Help(oModel)
EndIf
Return IIf(nRetType == 0, lReturn, aReturn)

/*/{Protheus.doc} RU02D01009_After
Fill After Model (F5Z)

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param oMdlAft , object , Model After Object
@param nDocType, numeric, Original Document Type
@return lReturn, Process Control
/*/
Static Function RU02D01009_After(oMdlAft As Object, nDocType As Numeric)

Local lReturn   		As Logical 	//Process Control
Local oStrAft   		As Object 	//Struct Object
Local aFields   		As Array 	//Struct Fields
Local aRelation 		As Array 	//Field Relation
Local nI        		As Numeric 	//Loop Control
Local nX        		As Numeric 	//Loop Control
Local nPosField 		As Numeric 	//Field Position
Local cQuery    		As Character //String Query
Local cAlias    		As Character //Alias
Local aReturn   		As Array 	//Data Array

//Get Fields
oStrAft   := oMdlAft:GetStruct()
aFields   := oStrAft:GetFields()
aRelation := RU02D01011_GetSD1_F5Z()

lReturn := .T.

If (lReturn .and. nDocType == 03) // request to create from Inflow Invoice
	//Create String SQL
	//Select
	cQuery := "SELECT" + CRLF
	//Fields
	For nI := 01 To Len(aRelation)
		//Verify Virtual Field
		nPosField := AScan(aFields, {|x| AllTrim(x[03]) == AllTrim(aRelation[nI, 01])})
		If (nPosField > 0)
			If !(aFields[nPosField, 14])
				cQuery += "SD1." + aRelation[nI, 02] + " " + aRelation[nI, 01] + ", "
			EndIf
		EndIf
	Next nI
	//Specific Fields
	cQuery += "CAST( SB1.B1_DESC as char(" + cValToChar(TamSX3("F5Z_ITMDES")[01]) + ")) F5Z_ITMDES, " + CRLF
	//Recno
	cQuery += "SD1.R_E_C_N_O_ RECNO" + CRLF
	//From
	cQuery += "FROM " + RetSQLName("SD1") + " SD1" + CRLF
	//Inner Join
	cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON" + CRLF
	cQuery += "SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' AND" + CRLF
	cQuery += "SB1.B1_COD = SD1.D1_COD AND" + CRLF
	cQuery += "SB1.D_E_L_E_T_ = ' '" + CRLF
	//Where
	cQuery += "WHERE" + CRLF
	cQuery += "SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' AND" + CRLF
	cQuery += "SD1.D1_DOC = '" + SF1->F1_DOC + "' AND" + CRLF
	cQuery += "SD1.D1_SERIE = '" + SF1->F1_SERIE + "' AND" + CRLF
	cQuery += "SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "' AND" + CRLF
	cQuery += "SD1.D1_LOJA = '" + SF1->F1_LOJA + "' AND" + CRLF
	cQuery += "SD1.D1_TIPODOC IN ('10') AND" + CRLF
	cQuery += "SD1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "order by" + CRLF
	cQuery += "SD1.D1_FILIAL" + CRLF
	cQuery += ", SD1.D1_FORNECE" + CRLF
	cQuery += ", SD1.D1_LOJA" + CRLF
	cQuery += ", SD1.D1_SERIE" + CRLF
	cQuery += ", SD1.D1_DOC" + CRLF
	cQuery += ", SD1.D1_ITEM" + CRLF
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()

	PlsQuery(cQuery, cAlias)

	(cAlias)->(dbGoTop())
	If ((cAlias)->(Eof()))
		lReturn = .F.
		Help(NIL, NIL, "RU02D01009_After_01", NIL, STR0036, 1, 0, NIL, NIL, NIL, NIL, NIL, /* solution */)
	EndIf

	If (lReturn)
		aReturn := FWLoadByAlias(oMdlAft, cAlias, 'F5Z')
		For nI := 01 To Len(aReturn)
			If (Len(aReturn[nI, 02]) == Len(aFields))
				// adds a new line
				If (nI != 01, oMdlAft:AddLine(), )
				// fulfills fields from the temporary table to the model After
				For nX := 01 To Len(aReturn[nI, 02])
					lReturn := lReturn .and. oMdlAft:LoadValue(aFields[nX, 03], aReturn[nI, 02][nX])
				Next nX
				// I put the content of F5Y_UID into F5Z_UIDF5Y here to mark all the lines from an original document.
				// New lines added by user will have F5Z_UIDF5Y empty,
				// so it becomes possible to differ lines from the original document and user's line.
				lReturn := lReturn .and. oMdlAft:LoadValue("F5Z_UIDF5Y", FwFldGet("F5Y_UID"))
				SD1->(dbGoTo(aReturn[nI,1])) //when we use FWLoadByAlias, the recno will be the first position.
				lReturn := lReturn .and. oMdlAft:LoadValue("F5Z_FDESC", Iif(!Empty(alltrim(SD1->D1_FDESC)), alltrim(SD1->D1_FDESC), oMdlAft:GetValue("F5Z_ITMDES")))
			EndIf
		Next nI
		// goes to the first line
		oMdlAft:GoLine(01)
	EndIf
	(cAlias)->(DBCloseArea())

ElseIf (lReturn .and. nDocType == 04) // request from to create from UPCD (Corrective or Adjustment)
	//Create String SQL
	//Select
	cQuery := "SELECT" + CRLF
	//Fields
	For nI := 01 To Len(aFields)
		//Verify if Real Field
		If !(aFields[nI, 14])
			cQuery += "F5Z." + aFields[nI, 03] + ", "
		EndIf
	Next nI
	//Description of products
	cQuery += "CAST( SB1.B1_DESC as char(" + cValToChar(TamSX3("F5Z_ITMDES")[01]) + ")) F5Z_ITMDES, " + CRLF
	
	//Recno
	cQuery += "F5Z.R_E_C_N_O_ RECNO" + CRLF
	//From
	cQuery += "FROM " + RetSQLName("F5Z") + " F5Z" + CRLF
	//Get Product Description
	cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON" + CRLF
	cQuery += "SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' AND" + CRLF
	cQuery += "SB1.B1_COD = F5Z.F5Z_ITMCOD AND" + CRLF
	cQuery += "SB1.D_E_L_E_T_ = ' '" + CRLF
	//Where
	cQuery += "WHERE" + CRLF
	cQuery += "F5Z.F5Z_FILIAL = '" + FWxFilial("F5Z") + "' AND" + CRLF
	cQuery += "F5Z.F5Z_UIDF5Y = '" + F5Y->F5Y_UID + "' AND" + CRLF
	cQuery += "F5Z.D_E_L_E_T_ = ' '" + CRLF
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()

	PlsQuery(cQuery, cAlias)

	(cAlias)->(dbGoTop())
	If ((cAlias)->(Eof()))
		lReturn = .F.
		Help(NIL, NIL, "RU02D01009_After_02", NIL, STR0036, 1, 0, NIL, NIL, NIL, NIL, NIL, /* solution */)
	EndIf

	If (lReturn)
		aReturn := FWLoadByAlias(oMdlAft, cAlias, 'F5Z')

		For nI := 01 To Len(aReturn)
			If (Len(aReturn[nI, 02]) == Len(aFields))
					// adds a new line
					If (nI != 01, oMdlAft:AddLine(), )
					// fulfills fields from the temporaryr table to the model After
				For nX := 01 To Len(aReturn[nI, 02])
					lReturn := lReturn .and. oMdlAft:LoadValue(aFields[nX, 03], aReturn[nI, 02][nX])
				Next nX
				// fulfills Origin ID
				lReturn := lReturn .and. oMdlAft:LoadValue("F5Z_UIDORI", F5Y->F5Y_UID)
				// I put the content of F5Y_UID into F5Z_UIDF5Y here to mark all the lines from an original document.
				// New lines added by user will have F5Z_UIDF5Y empty,
				// so it becomes possible to differ lines from the original document and user's line.
				lReturn := lReturn .and. oMdlAft:LoadValue("F5Z_UIDF5Y", FwFldGet("F5Y_UID"))
			EndIf
		Next nI
			// goes to the first line
		oMdlAft:GoLine(01)
	EndIf
		(cAlias)->(DBCloseArea())
EndIf
Return lReturn

/*/{Protheus.doc} RU02D01010_Total
Fill Total Model (F5Y)

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param oModel  , object  , Model Total Object
@param nLine   , numeric , Current Line
@return lReturn, Process Control
/*/
Static Function RU02D01010_Total(oModel As Object, nLine As Numeric)

Local lReturn   		As Logical //Process Control
Local nI        		As Numeric //Loop Control
Local nTotal    		As Numeric //Total Value
Local nBase     		As Numeric //VAT Base
Local nVATValue 		As Numeric //VAT Value
Local nGrossVl  		As Numeric //Gross Value
Local nTotalRUB 		As Numeric //Total in Rubles
Local nBaseRUB  		As Numeric //Base in Rubles
Local nValueRUB 		As Numeric //Value in Rubles
Local nGrossRUB 		As Numeric //Groos Value in Rubles

Default nLine := 01

//Initiliaze Variables
lReturn   := .T.
nTotal    := 0
nBase     := 0
nVATValue := 0
nGrossVl  := 0
nTotalRUB := 0
nBaseRUB  := 0
nValueRUB := 0
nGrossRUB := 0

//Check Header Model
lReturn := lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01")
oMdlF5Y	:= oModel:GetModel("F5YMASTER")
oMdlAft	:= oModel:GetModel("F5ZDETAIL_AFTER")

//Loop After Model and SUM values
For nI := 01 To oMdlAft:Length()
	oMdlAft:GoLine(nI)
	//SUM Values
	nTotal    += oMdlAft:GetValue("F5Z_TOTAL")
	nBase     += oMdlAft:GetValue("F5Z_BASE")
	nVATValue += oMdlAft:GetValue("F5Z_VATVL")
	nGrossVl  += oMdlAft:GetValue("F5Z_GROSS")
	nTotalRUB += oMdlAft:GetValue("F5Z_TOTAL1")
	nBaseRUB  += oMdlAft:GetValue("F5Z_BASE1")
	nValueRUB += oMdlAft:GetValue("F5Z_VATVL1")
	nGrossRUB += oMdlAft:GetValue("F5Z_GROSS1")
Next nI

//Set Values
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_TOTAL" , nTotal)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_BASE"  , nBase)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_VATVL" , nVATValue)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_GROSS" , nGrossVl)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_TOTAL1", nTotalRUB)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_BASE1" , nBaseRUB)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_VATVL1", nValueRUB)
lReturn := lReturn .and. oMdlF5Y:SetValue("F5Y_GROSS1", nGrossRUB)

//Go Line
oMdlAft:GoLine(nLine)
If (oModel:HasErrorMessage())
	RU05XFN008_Help(oModel)		
EndIf

Return lReturn

/*/{Protheus.doc} RU02D01011_GetSD1_F5Z
Get Relation of Tables SD1 and F5Z

@type function
@author Alison Kaique
@since Apr|2019
@version 12.1.2310
@param nType, numeric, Type of Relation
@return aRelation, Field Relation
/*/
Static Function RU02D01011_GetSD1_F5Z(nType As Numeric)

Local aRelation As Array
Default nType := 0

aRelation := {}

//Add in array
If nType == 0
	AAdd(aRelation, {"F5Z_FILIAL", "D1_FILIAL" })
	AAdd(aRelation, {"F5Z_ITEM"  , "D1_ITEM"   })
	AAdd(aRelation, {"F5Z_ITMCOD", "D1_COD"    })
	AAdd(aRelation, {"F5Z_WAREHO", "D1_LOCAL"  })
	AAdd(aRelation, {"F5Z_UM"    , "D1_UM"     })
	AAdd(aRelation, {"F5Z_TES"   , "D1_TES"    })
	AAdd(aRelation, {"F5Z_VATCOD", "D1_CF"     })
	AAdd(aRelation, {"F5Z_VATRT" , "D1_ALQIMP1"})
	AAdd(aRelation, {"F5Z_LOTCTL", "D1_LOTECTL"})
	AAdd(aRelation, {"F5Z_DTVALI", "D1_DTVALID"})
EndIf

AAdd(aRelation, {"F5Z_QUANT" , "D1_QUANT"  })
AAdd(aRelation, {"F5Z_VUNIT" , "D1_VUNIT" })
AAdd(aRelation, {"F5Z_TOTAL" , "D1_TOTAL"  })
AAdd(aRelation, {"F5Z_BASE"  , "D1_BASIMP1"})
AAdd(aRelation, {"F5Z_VATVL" , "D1_VALIMP1"})
AAdd(aRelation, {"F5Z_GROSS" , "D1_VALBRUT"})
AAdd(aRelation, {"F5Z_TOTAL1", "D1_TOTALM" })
AAdd(aRelation, {"F5Z_BASE1" , "D1_BSIMP1M"})
AAdd(aRelation, {"F5Z_VATVL1", "D1_VLIMP1M"})
AAdd(aRelation, {"F5Z_GROSS1", "D1_VLBRUTM"})
	
Return aRelation


/*/{Protheus.doc} RU02D01012_CreateUPCD
Other Actions button to input UPCD based in Inflow Invoice 

@type function
@author Artem Kostin
@since 13.02.2020
@version 12.1.2310
@return lReturn
/*/
Function RU02D01012_CreateUPCD(nCaller as Numeric, nOperation as Numeric)

Local lReturn				As Logical
Local cProcessName			As Character // The name of the process
Local oModel				As Object
Local oBrowseOri 			As Object

lReturn	:= .T.
cProcessName := ProcName()
	
// Clearing filter of invoice 
If nCaller == CALLER_INFLOW_INVOICE
	oBrowseOri := GetMBrowse()
	If oBrowseOri <> Nil .and. !Empty(oBrowseOri:cFilterDefault)
		(oBrowseOri:cAlias)->(DbClearFilter())
	EndIf
EndIf

If (nOperation == MODEL_OPERATION_INSERT)
	If (lReturn)
		oModel := FwLoadModel("RU02D01")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:SetDescription(STR0001)
		oModel:Activate()
		// checking date of original document 
		lReturn := lReturn .and. IIf(nCaller == CALLER_INFLOW_INVOICE,;
											SF1->F1_DTDIGIT <= dDatabase,; //SF2->F2_DTSAIDA
											F5Y->F5Y_DATE <= dDatabase)
		If !lReturn
			Help(" ", 1, cProcessName+":02", , STR0026, 1, 1)
		EndIf
	EndIf
		
	If (lReturn)
		oModel := RU02D01026_CopyDataFromOriginalDocument(oModel, nCaller)
		lReturn := lReturn .and. RU05XFN010_CheckModel(oModel, "RU02D01")
		If !IsBlind()
			FwExecView(STR0001,"RU02D01",nOperation,/* oDlg */,{|| .T.}, /* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
		EndIf
	EndIf
ElseIf (nOperation == MODEL_OPERATION_VIEW .or. nOperation == MODEL_OPERATION_DELETE)
	RU02D01(CALLER_INFLOW_INVOICE)
ElseIf (nOperation == MODEL_OPERATION_UPDATE)
	lReturn := .F.
	Help(" ", 1, cProcessName+":01", , STR0035, 1, 1)
EndIf
If nCaller == CALLER_INFLOW_INVOICE
	// restoring filter of invoice 
	If oBrowseOri <> Nil .and. !Empty(oBrowseOri:cFilterDefault)
		(oBrowseOri:cAlias)->(DbSetFilter({||&(oBrowseOri:cFilterDefault)},oBrowseOri:cFilterDefault))
	EndIf
EndIf

Return (lReturn)

/*/{Protheus.doc} RU02D01013_RUTrigger
Triggers

@type function
@author 
@since 
@version 12.1.2310
@return xRet, Return, multiple types
/*/
Static Function RU02D01013_RUTrigger(oSubModel As Object, cField As Character)
Local xRet 								//Return, multiple types
Local aChangeField 			As Array 	//Changed Fields
Local nPos         			As Numeric 	//Field Position

//Initiliaze variables
aChangeField := RU02D01011_GetSD1_F5Z(01)
oModel       := oSubModel:oFormModel
oView        := FWViewActive()
oMdlF5Y      := oModel:GetModel("F5YMASTER")
oMdlAft      := oModel:GetModel("F5ZDETAIL_AFTER")

//Verify Field
nPos := AScan(aChangeField, {|x| AllTrim(x[01]) == AllTrim(cField)})

//If Changed Field
If (nPos > 0)
	//Get default valor
	xRet := oMdlAft:GetValue(cField)
	//Update Totals
	RU02D01010_Total(oModel, oMdlAft:GetLine())
	//Refresh View
	If !isBlind()
		oView:Refresh("F5Y_Total")
	EndIf
EndIf

Return xRet


/*/{Protheus.doc} RU02D01014_LoadDecrease
Loads data from the SD1 table into the Decrease tab

@type function
@author 
@since 
@version 12.1.2310
@return aReturn, Array
/*/
Static Function RU02D01014_LoadDecrease(oMdlDec as Object)

Local oStrDec		As Object
Local aFldSD2		As Array
Local aReturn		As Array
Local cQuery		As Character
Local cTab			As Character
Local cTabFields	As Character

// Gets the model structure of the table SD2.
oStrDec := oMdlDec:GetStruct()
// Gets field names from the structure SD2.
aFldSD2 := oStrDec:GetFields()
aReturn := {}

// Change the prefix of every field from D1_ to D2_. Since both prefixes
// are very similar only the second symbol must be changed from '1' to '2'.
// Intersection between fields from the tables SD1 and SD2.
cTabFields := MPSysOpenQuery(														;
	ChangeQuery(																	;
		" SELECT SUBSTRING(T1.X3_CAMPO, 3, 10) AS FIELD_NAME"						;
		+ " FROM " + RetSQLName("SX3") + " AS T0"									;
		+ " INNER JOIN " + RetSQLName("SX3") + " AS T1 ON"							;
		+ " 	T1.X3_ARQUIVO IN ( 'SD1' )"											;
		+ " 	AND T1.X3_CONTEXT != 'V'"											;
		+ " 	AND SUBSTRING(T1.X3_CAMPO, 3, 10) = SUBSTRING(T0.X3_CAMPO, 3, 10)"	;
		+ " WHERE T0.X3_ARQUIVO IN ( 'SD2' )"										;
		+ " 	AND T0.X3_CONTEXT != 'V'"											;
	)																				;
)

// Create String SQL
cQuery := "SELECT " + CRLF
// Takes all fields from SD1 table which can be used in SD1 table.
While (!(cTabFields)->(EOF()))
	cQuery += " D2" + (cTabFields)->FIELD_NAME + " as D1" + (cTabFields)->FIELD_NAME + "," + CRLF
	(cTabFields)->(DbSkip())
EndDo
// Adds some exeptions when fields have different names but the same meaning.
cQuery += " D2_ITEMCC	as D1_ITEMCTA," + CRLF
cQuery += " D2_CCUSTO	as D1_CC," + CRLF
cQuery += " D2_CLIENTE	as D1_FORNECE," + CRLF
cQuery += " D2_PRCVEN	as D1_VUNIT," + CRLF
cQuery += " R_E_C_N_O_	as RECNO" + CRLF

// From
cQuery += "from " + RetSQLName("SD2") + CRLF
// Where
cQuery += "where" + CRLF
cQuery += "D2_FILIAL	= '" + FWxFilial("SD2") + "' and" + CRLF
cQuery += "D2_DOC		= '" + F5Y->F5Y_DOCCRD + "' and" + CRLF
cQuery += "D2_SERIE		= '" + F5Y->F5Y_SERCRD + "' and" + CRLF
cQuery += "D2_CLIENTE	= '" + F5Y->F5Y_SUPPL  + "' and" + CRLF
cQuery += "D2_LOJA		= '" + F5Y->F5Y_SUPBR  + "' and" + CRLF
cQuery += "D2_ESPECIE	= '" + NOTA_CREDIT_SUPPLIER + "' and" + CRLF
cQuery += "D_E_L_E_T_ = ' '" + CRLF
cQuery += "order by" + CRLF
cQuery += "D2_FILIAL" + CRLF
cQuery += ", D2_CLIENTE" + CRLF
cQuery += ", D2_LOJA" + CRLF
cQuery += ", D2_SERIE" + CRLF
cQuery += ", D2_DOC" + CRLF
cQuery += ", D2_ITEM" + CRLF
cQuery := ChangeQuery(cQuery)
cTab := MPSysOpenQuery(cQuery)

aReturn := FWLoadByAlias(oMdlDec, cTab, 'SD1')
(cTab)->(DBCloseArea())

Return(aReturn)

/*/{Protheus.doc} RU02D01015_CalculateTotalValue
Return table structure for auto generation invoice

@type function
@author Alexandra Velmozhnya
@since 27/09/2019
@version 12.1.2310
@param	oMdl 		Object		Model Decrese/Increse with value
		cFldGrid	Character	Field for sum
@return nRet 
/*/
Function RU02D01015_CalculateTotalValue(oMdl as Object, cFldGrid as Character)
Local nRet		As Numeric
Local nX		As Numeric

nRet := 0

// Checks if model is an object and activated.
lRet := RU05XFN010_CheckModel(oMdl, "SD1DETAIL_INCREASE|SD1DETAIL_DECREASE")

If (lRet)
	If oMdl:IsActive()
		For nX := 1 to oMdl:Length()
			oMdl:GoLine(nX)
			If !oMdl:IsDeleted()
				nRet += oMdl:GetValue(cFldGrid)
			EndIf
		Next nX
	EndIf
EndIf
Return nRet

/*/{Protheus.doc} RU02D01016_SettingsBeforeActivation
Settings before View activate

@type function
@author Alexandra Velmozhnya
@since 07/11/2019
@version 12.1.2310
@param	oView 		Object		View
@return 
/*/
Function RU02D01016_SettingsBeforeActivation(oView as Object)
Local nOper		As Numeric

nOper	:= oView:GetOperation()

If nOper ==  MODEL_OPERATION_INSERT
	oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| RU02D01019(cFolderID, nOldSheet, nSelSheet)})
EndIf

Return .T./*oView*/

/*/{Protheus.doc} RU02D01017_ShowInflowInvoices
Show Inflow Invoices

@type function
@author 
@since 
@version 12.1.2310
@return 
/*/
Function RU02D01017_ShowInflowInvoices()
Local oBrowse	as Object
Local bDblClick

DBSelectArea("SF1")
SF1->(DbSetOrder(1))
DBSelectArea("SD1")
SD1->(DbSetOrder(5))

aRotina	 := RU02D01025_MenuDefInvoiceBrowse() //Reset global aRotina
bDblClick := {|| CTBDOCENT()}//CtbDocSaida()
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SF1")
oBrowse:SetDescription(STR0020) // "Invoices"
oBrowse:DisableDetails(.T.)
oBrowse:SetWalkThru(.F.)
oBrowse:SetFilterDefault("F1_TIPODOC == '10'")
oBrowse:SetDoubleClick(bDblClick)
oBrowse:Activate()

aRotina	 := MenuDef()
Return

/*/{Protheus.doc} RU02D01018_SettingsActivation
Settings before View activate

@type function
@author Alexandra Velmozhnya
@since 07/04/2024
@version 12.1.2310
@param	oView 		Object		View
@return 
/*/
Function RU02D01018_SettingsActivation(oView As Object)
Local oStrF5Y		As Object
Local nOper			As Numeric

nOper	:= oView:GetOperation()
oStrF5Y := oView:GetViewStruct("F5Y_UPCD")

If nOper ==  MODEL_OPERATION_INSERT
	//oStrF5Y:RemoveField("F5Y_DOC")
	oStrF5Y:RemoveField("F5Y_DOCDEB")
	oStrF5Y:RemoveField("F5Y_DOCCRD")
EndIf
oView:SetViewProperty("SD1_Before"	, "GRIDDOUBLECLICK", {{|oView| RU09XFN025_OpenInflowinvoice(oView, "B"/*cFieldName,nLineGrid,nLineModel*/)}})
oView:SetViewProperty("SD1_Increase", "GRIDDOUBLECLICK", {{|oView| RU09XFN025_OpenInflowinvoice(oView, "I"/*cFieldName,nLineGrid,nLineModel*/)}})
oView:SetViewProperty("SD1_Decrease", "GRIDDOUBLECLICK", {{|oView| RU09XFN025_OpenInflowinvoice(oView, "D"/*cFieldName,nLineGrid,nLineModel*/)}})

oView:SetNoInsertLine("SD1_Before")
oView:SetNoDeleteLine("SD1_Before")
Return .T./*oView*/


/*/{Protheus.doc} RU02D01019
Validation of folder

@type function
@author Alexandra Velmozhnya
@since 16/12/2019
@version 12.1.2310
@param	cFolderID	Character	name of Folder contained tabs
		nOldSheet 	Numeric		Number of tabs from
		nSelSheet 	Numeric		Number of tabs to
/*/

Function RU02D01019(cFolderID as Character, nOldSheet as Numeric, nSelSheet as Numeric)
Local lRet 			As Logical
Local oModel    	As Object
Local oMdlBefore 	As Object
Local cNameUpd 		As Character

lRet := .T.

oView	:= FWViewActive()
oModel	:= oView:GetModel()
lRet := lRet .and. RU05XFN010_CheckModel(oModel, "RU02D01")
If (lRet)
	oMdlBefore	:= oModel:GetModel('SD1DETAIL_BEFORE')

//'fAfter'
	If !oMdlBefore:IsEmpty()
		If cFolderID == "fAfter"
			If nSelSheet == 1
				cNameUpd := "F5Z_After"
			ElseIf nSelSheet == 2	//Increase folder
				RU02D01020_RecalcFolder(oModel, nSelSheet, "SD1DETAIL_INCREASE")
				cNameUpd := "SD1_Increase"
			ElseIf nSelSheet == 3	//Decrease folder
				RU02D01020_RecalcFolder(oModel, nSelSheet, "SD1DETAIL_DECREASE")
				cNameUpd := "SD1_Decrease"
			EndIf

			If ValType(oView) == "O"
				oView:Refresh(cNameUpd)
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} RU02D01020_RecalcFolder
Run calculation of folder. it is clean submodel and recalculate when user is clicking on folder or saving model

@type function
@author Alexandra Velmozhnya
@since 16/12/2019
@version 12.1.2310
@param	nUpdSheet 	Numeric		Number of tabs
		cNameUpd	Character	name of submodel from tab
/*/
Function RU02D01020_RecalcFolder(oModel as Object, nUpdSheet as Numeric, cNameUpd as Character)

Local lRet 			As Logical
Local cProcessName	As Character
Local lNewLine 		As Logical
Local oMdlBef 		As Object
Local oMdlAft 		As Object
Local oMdlMove 		As Object
Local aFldBef 		As Array
Local aFldAft 		As Array
Local aFldMove 		As Array
Local aTriggers 	As Array
Local lIncrease		As Logical
Local xVal
Local nX 			As Numeric
Local nI 			As Numeric
Local nQntBef   	As Numeric // Quantity before correction
Local nQntAft    	As Numeric // Quantity after correction
Local nPriceBef   	As Numeric // Unit Price before correction
Local nPriceAft    	As Numeric // Unit Price after correction
Local nQntDif    	As Numeric // Quantity after correction
Local nPriceDif   	As Numeric // Unit Price before correction

Default nUpdSheet := SHEET_INCREASE
lRet := .T.

If (cNameUpd == "SD1DETAIL_INCREASE")
	lIncrease := .T.
ElseIf (cNameUpd == "SD1DETAIL_DECREASE")
	lIncrease := .F.
Else
	lRet := .F.
	Help(" ", 01, cProcessName + ":01", , STR0046 + cNameUpd + STR0047, 1, 1) // "Submodel " + cNameUpd + " is unknown."
EndIf

If (lRet)
	cProcessName := ProcName()
EndIf

lRet := lRet .and. RU05XFN010_CheckModel(oModel, "RU02D01")

If (lRet)
	oMdlBef   := oModel:GetModel("SD1DETAIL_BEFORE")
	aFldBef   := oMdlBef:GetStruct():GetFields()

	oMdlAft   := oModel:GetModel("F5ZDETAIL_AFTER")
	aFldAft   := oMdlAft:GetStruct():GetFields()

	oMdlMove := oModel:GetModel(cNameUpd)
	aFldMove := oMdlMove:GetStruct():GetFields()

	aChangeField := RU02D01011_GetSD1_F5Z()

	oMdlMove:ClearData(.F.,.T.)

	For nX := 1 to oMdlAft:Length()
		oMdlAft:GoLine(nX)
		lNewLine := .F.
		If (oMdlBef:SeekLine({{"D1_ITEM", Left(oMdlAft:GetValue("F5Z_ITEM"), TamSX3("D1_ITEM")[01])}}))

			nQntBef := oMdlBef:GetValue("D1_QUANT")
			nQntAft := oMdlAft:GetValue("F5Z_QUANT")
			nQntDif := nQntBef - nQntAft
			nPriceBef := oMdlBef:GetValue("D1_VUNIT")
			nPriceAft := oMdlAft:GetValue("F5Z_VUNIT")
			nPriceDif := nPriceBef - nPriceAft
			
			aTriggers:={}

			If nQntDif == 0 .And. nPriceDif == 0	//(Qa = Qb & Pa = Pb) 
				//try to find difference not in price/total or quantity
				For nI:= 1 to len(aChangeField)
					If !(aChangeField[nI, 1] $ "/F5Z_QUANT/F5Z_VUNIT/F5Z_TOTAL/")
						If oMdlAft:GetValue(aChangeField[nI, 1]) <> oMdlBef:GetValue(aChangeField[nI, 2])
							lNewLine := .T.
						EndIf
					EndIf
				Next nI
			Else
				For nI:= 1 to len(aChangeField)
					xVal := RU02D01024_TriggerValue(oModel, aChangeField[nI, 1])
					If !Empty(xVal) .And. xVal <> oMdlAft:GetValue(aChangeField[nI, 1])
						lNewLine := .T.
					EndIf
				Next nI
			EndIf

			If .Not. lNewLine .And. (nQntDif == 0 .And. ;
			((nUpdSheet == SHEET_DECREASE .And. nPriceDif > 0)  .Or. (nUpdSheet == SHEET_INCREASE .And. nPriceDif < 0)))	//(Qa = Qb & Pa <> Pb)

				oMdlMove := RU02D01021_InitMoveModel(oMdlMove/*oRet */, oMdlBef/*oMdlCpy*/, nX/*nLine*/)
				oMdlMove := RU02D01022_MoveModelF5Z(oMdlMove/*oRet */, oMdlAft/*oMdlCpy*/, nX/*nLine*/)

				oMdlMove:LoadValue("D1_QUANT", 0)
				oMdlMove:LoadValue("D1_VUNIT", abs(oMdlAft:GetValue("F5Z_TOTAL") - oMdlBef:GetValue("D1_TOTAL")))
				oMdlMove:LoadValue("D1_TOTAL", abs(oMdlAft:GetValue("F5Z_TOTAL") - oMdlBef:GetValue("D1_TOTAL")))

				If nUpdSheet == SHEET_DECREASE
					RU02D01031_UpdateTio(oMdlAft, oMdlMove)
				EndIf

				//reqursive run triggers from D1_TOTAL
				aTriggers :=  RU02D01023_TriggersChain("D1_TOTAL", lIncrease,"oMdlMove", aTriggers)
				nI := 1

				While nI <= Len(aTriggers)
					aTriggers :=  RU02D01023_TriggersChain(aTriggers[nI][1]/*"D2_TOTAL"*/, lIncrease,"oMdlMove", aTriggers)
					xVal := &(aTriggers[nI][2])
					lRet := lRet .and. oMdlMove:LoadValue(aTriggers[nI][1],xVal)
					nI++
				EndDo

			ElseIf .Not. lNewLine .And. (nPriceDif == 0 .And. ;
			((nUpdSheet == SHEET_DECREASE .And. nQntDif > 0)  .Or. (nUpdSheet == SHEET_INCREASE .And. nQntDif < 0)))// (Qa <> Qb & Pa == Pb)

				oMdlMove := RU02D01021_InitMoveModel(oMdlMove/*oRet */, oMdlBef/*oMdlCpy*/, nX/*nLine*/)
				oMdlMove := RU02D01022_MoveModelF5Z(oMdlMove/*oRet */, oMdlAft/*oMdlCpy*/, nX/*nLine*/)

				oMdlMove:LoadValue("D1_QUANT", abs(nQntDif))
				oMdlMove:LoadValue("D1_VUNIT", oMdlBef:GetValue("D1_VUNIT"))

				If nUpdSheet == SHEET_DECREASE
					RU02D01031_UpdateTio(oMdlAft, oMdlMove)
				EndIf

				//reqursive run triggers from D2_QUANT
				aTriggers :=  RU02D01023_TriggersChain("D1_QUANT", lIncrease,"oMdlMove", aTriggers)
				nI := 1

				While nI <= Len(aTriggers)
					aTriggers :=  RU02D01023_TriggersChain(aTriggers[nI][1]/*"D2_TOTAL"*/, lIncrease,"oMdlMove", aTriggers)
					xVal := &(aTriggers[nI][2])
					lRet := lRet .and. oMdlMove:LoadValue(aTriggers[nI][1],xVal)
					nI++
				EndDo

			ElseIf (nPriceDif <> 0 .And. nQntDif <> 0) .Or.	lNewLine//	(Qa <> Qb & Pa <> Pb)
				If nUpdSheet == SHEET_DECREASE
					oMdlMove := RU02D01021_InitMoveModel(oMdlMove/*oRet */, oMdlBef/*oMdlCpy*/, nX/*nLine*/)
					RU02D01031_UpdateTio(oMdlAft, oMdlMove)

				// Copy from model After
				ElseIf nUpdSheet == SHEET_INCREASE
					oMdlMove := RU02D01021_InitMoveModel(oMdlMove/*oRet */, oMdlBef/*oMdlCpy*/, nX/*nLine*/,.F.)
					oMdlMove := RU02D01022_MoveModelF5Z(oMdlMove/*oRet */, oMdlAft/*oMdlCpy*/, nX/*nLine*/)
				EndIf
			EndIf
		Else	// If it a new line (Qb = 0 & Pb = 0)
			If (nUpdSheet == SHEET_INCREASE) .And. .Not. oMdlAft:IsDeleted()
			// Copy from model After
				oMdlMove := RU02D01022_MoveModelF5Z(oMdlMove/*oRet */, oMdlAft/*oMdlCpy*/, nX/*nLine*/)
			EndIf
		EndIf
	Next nX

	//Return to begining
	oMdlAft:GoLine(1)
	oMdlBef:GoLine(1)
	oMdlMove:GoLine(1)
EndIf

Return lRet

/*/{Protheus.doc} RU02D01021_InitMoveModel
Initializing Movement Model by Value from Model Before

@type function
@author Alexandra Velmozhnya
@since 16/12/2019
@version 12.1.2310
@param	oRet 		Object		Model of Movement
		oMdlCpy		Object		Copied Model
		nLine 		Numeric		Copied line
		lCopyAll	Logical		flag copy all fields from Before model
@return 
/*/

Function RU02D01021_InitMoveModel(oRet as Object, oMdlCpy as Object, nLine As Numeric, lCopyAll as Logical)
Local nI 			As Numeric
Local aFldCpy 		As Array
Local aChangeField 	As Array

Default lCopyAll := .T.

//data for copy
aFldCpy := oMdlCpy:GetStruct():GetFields()
oMdlCpy:GoLine(nLine)

//data for change
If !lCopyAll
	aChangeField := RU02D01011_GetSD1_F5Z(1)
EndIf

//Check model Movements
If !oRet:IsEmpty()
	nI := oRet:addLine()
	oRet:GoLine(nI)
EndIf

// Initializing Value
For nI := 1 To Len(aFldCpy)
	//Fill informations
	If lCopyAll .Or. (!lCopyAll .And. aScan(aChangeField, {|x| AllTrim(x[2]) == AllTrim(aFldCpy[nI, 3])}) == 0)
		oRet:LdValueByPos(nI, oMdlCpy:GetValue(aFldCpy[nI, 3]))
	EndIf
Next nI
oRet:LoadValue("D1_QTDEDEV", 0)
oRet:LoadValue("D1_VALDEV ", 0)

Return oRet


/*/{Protheus.doc} RU02D01022_MoveModelF5Z
Initializing Movement Model by Value from Model After or calculate difference in numeric fields

@type function
@author Alexandra Velmozhnya
@since 16/12/2019
@version 12.1.2310
@param	oRet 		Object		Model of Movement
		oMdlCpy		Object		Copied Model
		nLine 		Numeric		Copied line
@return 
/*/

Function RU02D01022_MoveModelF5Z(oRet as Object, oMdlCpy as Object, nLine As Numeric)
Local nI 			As Numeric
Local aChangeField 	As Array
Local lRet 			As Logical
Local nDifVal 		As Numeric

//data for copy
aChangeField := RU02D01011_GetSD1_F5Z()
oMdlCpy:GoLine(nLine)
lRet := .T.

//Check model Movements
If !oRet:SeekLine({{"D1_ITEM", Left(oMdlCpy:GetValue("F5Z_ITEM"), TamSX3("D1_ITEM")[01])}})
	If !oRet:IsEmpty()
		nI := oRet:AddLine()
		oRet:GoLine(nI)
	EndIf
EndIf

For nI := 1 To Len(aChangeField)
	If (ValType(oRet:GetValue(aChangeField[nI, 2])) == "C")
		lRet := lRet .and. oRet:LoadValue(aChangeField[nI, 2], Left(oMdlCpy:GetValue(aChangeField[nI, 1]), TamSX3(aChangeField[nI, 2])[1]))

	ElseIf (ValType(oRet:GetValue(aChangeField[nI, 2])) == "D")
		lRet := lRet .and. oRet:LoadValue(aChangeField[nI, 2], oMdlCpy:GetValue(aChangeField[nI, 1]))

	Else
		nDifVal := Abs(oMdlCpy:GetValue(aChangeField[nI, 1]) - oRet:GetValue(aChangeField[nI, 2]))
		lRet := lRet .and. oRet:LoadValue(aChangeField[nI, 2], nDifVal)
	EndIf
Next nI
oRet:LoadValue("D1_ALQIMP1", oMdlCpy:GetValue("F5Z_VATRT"))

Return oRet


/*/{Protheus.doc} RU02D01023_TriggersChain
Return array of triggers which follow after changing cCampo

@type function
@author Alexandra Velmozhnya
@since 28/10/2019
@version 12.1.2310
@param	cCampo 		Character	Campo which runs trigger	
		lIncrease	Logical		Flag credit/debit
		cModMov		Character	Name of variable which contain submodel
		aRet		Array		Array parrent triggers
@return nRet 
/*/
Function RU02D01023_TriggersChain(cCampo as Character, lIncrease as Logical,cModMov as Character, aRet as Array)
//Local aRet As Array

Default aRet := {}
//Decrease triggers
	Do Case
		Case AllTrim(cCampo) == "D1_QUANT"
			aAdd(aRet, {"D1_TOTAL",'Round(' + cModMov + ':GetValue("D1_QUANT") * ' + cModMov + ':GetValue("D1_VUNIT"), 2)'})
		Case AllTrim(cCampo) == "D1_VUNIT"
			aAdd(aRet, {"D1_TOTAL", 'Round(' + cModMov + ':GetValue("D1_QUANT") * ' + cModMov + ':GetValue("D1_VUNIT"), 2)'})
		Case AllTrim(cCampo) == "D1_TOTAL"
			aAdd(aRet, {"D1_VALIMP1", 'RU09T01I("V",0, RU09T01_01(FWFldGet("F5Z_TES")), .F.,' + IIf(lIncrease,".T.",".F.")+')'})
			aAdd(aRet, {"D1_TOTALM" , 'Round(' + cModMov + ':GetValue("D1_TOTAL") * FWFldGet("F5Y_EXGRAT"), 2)'})
		Case AllTrim(cCampo) == "D1_VALIMP1"
			aAdd(aRet, {"D1_BASIMP1", 'RU09T01I("B",0, RU09T01_01(FWFldGet("F5Z_TES")), .F.,' + IIf(lIncrease,".T.",".F.")+')'})
			aAdd(aRet, {"D1_VLIMP1M", '' + cModMov + ':GetValue("D1_VALIMP1") * FWFldGet("F5Y_EXGRAT")'})
			aAdd(aRet, {"D1_VALBRUT", '' + cModMov + ':GetValue("D1_VALIMP1") + FWFldGet("D1_BASIMP1")'})
		Case AllTrim(cCampo) == "D1_BASIMP1"
			aAdd(aRet, {"D1_BSIMP1M", '' + cModMov + ':GetValue("D1_BASIMP1") * FWFldGet("F5Y_EXGRAT")'})
			aAdd(aRet, {"D1_VALBRUT", '' + cModMov + ':GetValue("D1_VALIMP1") + ' + cModMov + ':GetValue("D1_BASIMP1")'})
		Case AllTrim(cCampo) == "D1_VLIMP1M"
			aAdd(aRet, {"D1_VLBRUTM", '' + cModMov + ':GetValue("D1_VLIMP1M") + ' + cModMov + ':GetValue("D1_BSIMP1M")'})
		Case AllTrim(cCampo) == "D1_BSIMP1M"
			aAdd(aRet, {"D1_VLBRUTM", '' + cModMov + ':GetValue("D1_VLIMP1M") + ' + cModMov + ':GetValue("D1_BSIMP1M")'})
		Case AllTrim(cCampo) == "D1_VALBRUT"
			aAdd(aRet, {"D1_VLBRUTM", '' + cModMov + ':GetValue("D1_VALBRUT") * FWFldGet("F5Y_EXGRAT")'})
	EndCase
Return aRet

/*/{Protheus.doc} RU02D01024_TriggerValue
Return formula of field cCampo
@type function
@author Alexandra Velmozhnya
@since 24/12/2019
@version 12.1.2310
@param	oModel 		Object		Main model object
		cCampo 		Character	Campo which formula returns	
@return cRet 
/*/
Function RU02D01024_TriggerValue(oModel as Object, cCampo as Character)
Local nRet			as Numeric
Local oModelHeader	as Object
Local oModelAfter	as Object

nRet			:= 0
oModelHeader	:= oModel:GetModel("F5YMASTER")
oModelAfter		:= oModel:GetModel("F5ZDETAIL_AFTER")

Do Case
	Case AllTrim(cCampo) == "F5Z_TOTAL"
		nRet := Round(oModelAfter:GetValue("F5Z_QUANT") * oModelAfter:GetValue("F5Z_VUNIT"), 2)
	Case AllTrim(cCampo) == "F5Z_TOTAL1"
		nRet := Round(oModelAfter:GetValue("F5Z_TOTAL") * oModelHeader:GetValue("F5Y_EXGRAT"), 2)
	Case AllTrim(cCampo) == "F5Z_VATVL"
		nRet := RU09T01I("V",0, RU09T01_01(FWFldGet("F5Z_TES")), .F.,Nil)
	Case AllTrim(cCampo) == "F5Z_VATVL1"
		nRet := oModelAfter:GetValue("F5Z_VATVL") * oModelHeader:GetValue("F5Y_EXGRAT")
	Case AllTrim(cCampo) == "F5Z_BASE"
		nRet := RU09T01I("B",0, RU09T01_01(FWFldGet("F5Z_TES")), .F., Nil)
	Case AllTrim(cCampo) == "F5Z_BASE1"
		nRet := oModelAfter:GetValue("F5Z_BASE") * oModelHeader:GetValue("F5Y_EXGRAT")
	Case AllTrim(cCampo) == "F5Z_GROSS"
		nRet := oModelAfter:GetValue("F5Z_VATVL") + oModelAfter:GetValue("F5Z_BASE")
	Case AllTrim(cCampo) == "F5Z_GROSS1"
		nRet := oModelAfter:GetValue("F5Z_GROSS") * oModelHeader:GetValue("F5Y_EXGRAT")
EndCase
Return nRet

/*/{Protheus.doc} RU02D01025_MenuDefInvoiceBrowse
Routine menu for mark browse
1 - Inflow Invoice (SF1)
2 - Correction Inflow Invoice (F5Y)

@type function
@author Alexandra Velmozhnya
@since 09/01/2020
@version 12.1.2310
@return aRet , Array, array buttons
/*/
Function RU02D01025_MenuDefInvoiceBrowse()
Local aRet 		As Array
	aRet := {;
		{STR0045;
			, "RU02D01012_CreateUPCD(";
				+ str(CALLER_INFLOW_INVOICE);
				+ ", " + str(MODEL_OPERATION_INSERT);
				+ ")";
			, 0, MODEL_OPERATION_VIEW;
		};
		, {STR0012, "CTBDOCENT()", 0, MODEL_OPERATION_VIEW};//CtbDocSaida()
	}
Return aRet

/*/{Protheus.doc} RU02D01026_CopyDataFromOriginalDocument
Copy Data From Origina lDocument

@type function
@author 
@since 
@version 12.1.2310
@return oModel
/*/
Function RU02D01026_CopyDataFromOriginalDocument(oModel As Object, nDocType as Numeric)
Local lRet 		As Logical
Local oMdlF5Y   As Object //F5Y Model Object
Local oMdlBef   As Object //Before Model Object
Local oMdlAft   As Object //Before After Object

lRet := RU05XFN010_CheckModel(oModel, "RU02D01")

If (lRet)
	oMdlF5Y  := oModel:GetModel("F5YMASTER") //Get F5Y Model
	oMdlBef  := oModel:GetModel("SD1DETAIL_BEFORE") //Get Before Model
	oMdlAft  := oModel:GetModel("F5ZDETAIL_AFTER") //Get After Model

	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_FILIAL", xFilial("F5Y")) // Filial for the table 'F5Y' user works with
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_SUPPL" , IIf(nDocType == 03, SF1->F1_FORNECE, F5Y->F5Y_SUPPL)) // Supplier code
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_SUPBR" , IIf(nDocType == 03, SF1->F1_LOJA	 , F5Y->F5Y_SUPBR)) // Supplier's branch

	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_ORIGIN", cValToChar(nDocType)) //Original Type
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_SERORI", IIf(nDocType == 03, SF1->F1_SERIE  , F5Y->F5Y_SERIE )) //Original Series
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_DOCORI", IIf(nDocType == 03, SF1->F1_DOC    , F5Y->F5Y_DOC   )) //Original Document
	
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_DTORI" , IIf(nDocType == 03, SF1->F1_DTDIGIT, F5Y->F5Y_DATE)) //Issue Date

	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNRVEN", IIf(nDocType == 03, SF1->F1_CNORSUP, F5Y->F5Y_CNRVEN)) //Consignor
	If (oMdlF5Y:GetValue("F5Y_CNRVEN") == "2")
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNRCOD", IIf(nDocType == 03, SF1->F1_CNORCOD, F5Y->F5Y_CNRCOD)) //C-nor Code
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNRBR" , IIf(nDocType == 03, SF1->F1_CNORBR , F5Y->F5Y_CNRBR)) //C-nor Branch
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNRNAM", Left(Posicione("SA2", 01, FWxFilial("SA2") + oMdlF5Y:GetValue("F5Y_CNRCOD") + oMdlF5Y:GetValue("F5Y_CNRBR"), "A2_NOME"), TamSX3("F5Y_CNRNAM")[01])) //C-nor Name
	EndIf
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNECLI", IIf(nDocType == 03, SF1->F1_CNEEBUY, F5Y->F5Y_CNECLI)) //Consignee
	If (oMdlF5Y:GetValue("F5Y_CNECLI") == "2")
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNECOD", IIf(nDocType == 03, SF1->F1_CNEECOD, F5Y->F5Y_CNECOD)) //C-nee Code
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNEBR" , IIf(nDocType == 03, SF1->F1_CNEEBR , F5Y->F5Y_CNEBR)) //C-nee Branch
		lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNENAM", Left(Posicione("SA1", 01, FWxFilial("SA1") + oMdlF5Y:GetValue("F5Y_CNECOD") + oMdlF5Y:GetValue("F5Y_CNEBR"), "A1_NOME"), TamSX3("F5Y_CNENAM")[01])) //C-nee Name
	EndIf

	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CONUNI" , IIf(nDocType == 03, SF1->F1_CONUNI, F5Y->F5Y_CONUNI)) //Convential Unit
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CURREN" , IIf(nDocType == 03, StrZero(SF1->F1_MOEDA, TamSX3("F5Y_CURREN")[01]) , F5Y->F5Y_CURREN)) //Currency
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CURNAM" , Left(Posicione("CTO", 01, FWxFilial("CTO") + oMdlF5Y:GetValue("F5Y_CURREN"), "CTO_DESC"), TamSX3("F5Y_CURNAM")[01])) //Currency Name

	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_COND"   , IIf(nDocType == 03, SF1->F1_COND  , F5Y->F5Y_COND)) //Payment Term
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CNDNAM" , Left(Posicione("SE4", 01, FWxFilial("SE4") + oMdlF5Y:GetValue("F5Y_COND"), "E4_DESCRI"), TamSX3("F5Y_CNDNAM")[01])) //Payment Description
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_CLASS"  , IIf(nDocType == 03, SF1->F1_NATUREZ, F5Y->F5Y_CLASS)) //Payment Class
	lRet := lRet .and. oMdlF5Y:SetValue("F5Y_EXGRAT"  , IIf(nDocType == 03, SF1->F1_TXMOEDA, F5Y->F5Y_EXGRAT)) //Exchange Rate

	lRet := lRet .and. oMdlF5Y:setValue("F5Y_F5QUID" , IIf(nDocType == 03, SF1->F1_F5QUID, F5Y->F5Y_F5QUID))
	lRet := lRet .and. oMdlF5Y:setValue("F5Y_CNTCOD" , IIf(nDocType == 03, SF1->F1_CNTID, F5Y->F5Y_CNTCOD))
	lRet := lRet .and. oMdlF5Y:setValue("F5Y_CNTNAM" , IIf(nDocType == 03,Posicione("F5Q",1,xFilial("F5Q") + SF1->F1_F5QUID,"F5Q_DESCR"), Posicione("F5Q",1,xFilial("F5Q") + F5Y->F5Y_F5QUID,"F5Q_DESCR")))

	//Set Before Values
	FWMsgRun( , {|| lRet := lRet .and. RU02D01008_Before(@oMdlBef, nDocType) } ,, STR0023) //"Loading Before Informations..."
	//Set After Values
	FWMsgRun( , {|| lRet := lRet .and. RU02D01009_After(@oMdlAft, nDocType) } ,, STR0024) //"Loading After Informations..."
	//Set Total Values
	FWMsgRun( , {|| lRet := lRet .and. RU02D01010_Total(@oModel) } ,, STR0025) //"Loading Total Informations..."
	If (oModel:HasErrorMessage())
		RU05XFN008_Help(oModel)
	EndIf
EndIf
Return oModel

/*/{Protheus.doc} RU02D01027_SeekOriginalInflowInvoice
Seek Original Inflow Invoice

@type function
@author 
@since 
@version 12.1.2310
@return lRet
/*/
Function RU02D01027_SeekOriginalInflowInvoice(oModel as Object, cDocOri as Character, cSerOri as Character)
Local lRet				As Logical
Local cProcessName		As Character
Local oModelF5Y			As Object
Local oModelF5Z			As Object
Local oPrevModel		As Object

cProcessName	:= ProcName()

If (lRet := RU05XFN010_CheckModel(oModel, "RU02D01|RU02D02"))
	oModelF5Y := oModel:GetModel("F5YMASTER")
	oModelF5Z := oModel:GetModel("F5ZDETAIL_AFTER")
	If (oModelF5Y:GetValue("F5Y_ORIGIN") == "3")
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If (SF1->(dbSeek(xFilial("SF1") + oModelF5Y:GetValue("F5Y_DOCORI") + oModelF5Y:GetValue("F5Y_SERORI") + oModelF5Y:GetValue("F5Y_SUPPL") + oModelF5Y:GetValue("F5Y_SUPBR"))))
			cDocOri	:= SF1->F1_DOC
			cSerOri	:= SF1->F1_SERIE
		Else
			lRet	:= .F.
		EndIf
	ElseIf (oModelF5Y:GetValue("F5Y_ORIGIN") == "4")
		dbSelectArea("F5Y")
		F5Y->(dbSetOrder(1))
		dbSelectArea("F5Z")
		F5Z->(dbSetOrder(1))
		If (F5Z->(dbSeek(xFilial("F5Z") + oModelF5Z:GetValue("F5Z_UIDORI"))))
			If (F5Y->(dbSeek(xFilial("F5Y") + F5Z->F5Z_UIDF5Y)))
				oPrevModel := FWLoadModel("RU02D02")
				oPrevModel:SetOperation(MODEL_OPERATION_VIEW)
				oPrevModel:Activate()
				lRet := lRet .and. RU02D01027_SeekOriginalInflowInvoice(oPrevModel, @cDocOri, @cSerOri)
				oPrevModel:Destroy()
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
		F5Y->(dbSetOrder(4))
	Else
		lRet := .F.
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} RU02D01028_FilterUPCDBrowseByInflowlInvoice
Function responsable to filter the UPCD linked at the inflow invoice (used when we press view UPCD at inflow invoice routine)
@type function
@author Rafael Gonçalves
@since May|2020
/*/
Function RU02D01028_FilterUPCDBrowseByInflowlInvoice(cSupplier as Character, cUnit as Character, cSeries as Character, cDoc as Character)
Local cFilter		As Character
Local cQuery		As Character
Local cTab			As Character

Default cSupplier	:= SF1->F1_FORNECE
Default cUnit		:= SF1->F1_LOJA
Default cSeries		:= SF1->F1_SERIE
Default cDoc		:= SF1->F1_DOC

cFilter	:= ""
cTab	:= ""

cQuery := " SELECT F5Y_UID as UPCD_UID FROM " + RetSQLName("F5Y") + " WHERE"
cQuery += " 	F5Y_FILIAL = '" + xFilial("F5Y") +"' AND F5Y_SUPPL = '" + cSupplier + "'"
cQuery += " 	AND F5Y_SUPBR = '" + cUnit + "' AND F5Y_SERORI = '" + cSeries + "'"
cQuery += " 	AND F5Y_DOCORI = '" + cDoc + "' AND D_E_L_E_T_ = ' '"
cTab := MPSysOpenQuery(ChangeQuery(cQuery))
(cTab)->(dbGoTop())

cFilter := "F5Y_UID $ '"
While (!(cTab)->(Eof()))
	cFilter += (cTab)->UPCD_UID + "|"
	(cTab)->(DbSkip())
EndDo
cFilter += "'"

CloseTempTable(cTab)
Return cFilter

/*/{Protheus.doc} RU02D01029
Function responsable to add a item number when we add a new line at folder After, 
we need it becouse SetAutIncrement cant work here. It's used only at UPCD routine
@type function
@author Rafael Gonçalves
@since May|2020
/*/
Function  RU02D01029(oModel)
Local cValue	as Character
Local oMdlAft 	as Object

cValue := '    '

oMdlAft  := oModel:GetModel("F5ZDETAIL_AFTER")
If MODEL_OPERATION_INSERT== oModel:GetOperation() .or. MODEL_OPERATION_UPDATE== oModel:GetOperation()
	If oMdlAft:Length() > 0 
		cValue := PadR(soma1(alltrim(oMdlAft:GetValue("F5Z_ITEM"))),TamSX3("F5Z_ITEM")[01])
	Endif
Endif
Return cValue



/*/{Protheus.doc} RU02D01030
Function responsable to verified if we have this item number at original document (invoice) if we have add that do NDC or NCC, if not leave empty
@type function
@author Rafael Gonçalves
@since May|2020
/*/
Static Function RU02D01030(cSuppl, cSupBr,cInvoice, cSerie, cProduct,cItem )

Local aArea	  	As Array
aArea	:= GetArea()

SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
//if not found means that this items not exist at original document and cant be used at D?_ITEMORI
If !(SD1->(DbSeek(FWxFilial("SD1")+cInvoice+cSerie+cSuppl+cSupBr+cProduct+cItem)))
	cItem := Space(TamSX3("D1_ITEM")[01])
Endif

RestArea(aArea)
Return cItem

/*{Protheus.doc} RU02D01031_UpdateTio
@description 
@author alexander.ivanov
@since 02/04/2021
@version 12.1.2310
@project MA3 - Russia
*/
Static Function RU02D01031_UpdateTio(oMdlFrom, oMdlTo)
	DBSelectArea("SF4")
	SF4->(DbSetOrder(1)) // F4_FILIAL + F4_CODIGO

	If SF4->(DBSeek(FWxFilial("SF4") + oMdlFrom:GetValue("F5Z_TES")))
		oMdlTo:LoadValue("D1_TES", SF4->F4_TESDV)
	EndIf
Return 
//Merge Russia R14                   
