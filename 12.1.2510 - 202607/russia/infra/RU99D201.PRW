#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU99D201.CH"

#DEFINE MVC_TYPE '1'
#DEFINE MILE_TYPE '2'
#DEFINE CUSTOM_TYPE '3'
#DEFINE RECEIVE_OPER '1'
#DEFINE SEND_OPER '2'
#DEFINE REST_TYPE '1'
#DEFINE AMQP_TYPE '2'

/*/{Protheus.doc} RU99D201()
    EAI Adapters Maintenance
    @type function
    @author @Bruno Sobieski
    @since 
    @version 1.0
    @return Logical, Flag of sucessfully opened routine
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Function RU99D201()

	Local lRet as Logical
	Local oBrowse as Object
	Private aRotina as Array

	lRet := .T.
	SX2->(DbSetOrder(1))
	SX2->(DbSeek('F6F'))

	aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F6F")
	oBrowse:SetDescription(X2Nome())
	oBrowse:SetAttach(.T.)
	oBrowse:Activate()

Return(lRet)

/*/{Protheus.doc} MenuDef
    Routine "Adapters" menu function
    @type function
    @author @Bruno Sobieski
    @since 
    @version 1.0
    @return Array, Menu items
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function MenuDef()

	Local aRet as Array

	aRet := {{STR0011, "VIEWDEF.RU99D201", 0, MODEL_OPERATION_VIEW, 0, Nil},; // View
		{STR0012, "VIEWDEF.RU99D201", 0, MODEL_OPERATION_INSERT, 0, Nil},; // Add
		{STR0013, "VIEWDEF.RU99D201", 0, MODEL_OPERATION_UPDATE, 0, Nil},; // Update
		{STR0014, "VIEWDEF.RU99D201", 0, MODEL_OPERATION_DELETE, 0, Nil}} // Delete

Return(aRet)

/*/{Protheus.doc} ModelDef
    Creates Model for "Adapters" routine
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version 1.0
    @return Object, Model for "Adapters" routine
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function ModelDef()

	Local oModel as Object
	Local oStrF6F as Object
	Local oStrF6G as Object
	Local aRelac := {}

	oStrF6F := FWFormStruct(1, "F6F")
	oStrF6G := FWFormStruct(1, "F6G")

	oModel := MPFormModel():New("RU99D201"/*cID*/, /*bPre*/,  {|oModel| ValidModel(oModel)}/*bPost*/, /*bCommit*/)

	oModel:AddFields("F6FMASTER", Nil, oStrF6F)
	oModel:SetPrimaryKey({"F6F_FILIAL", "F6F_CODE"})

	oModel:AddGrid('F6GDETAIL','F6FMASTER',oStrF6G)
	oModel:GetModel( 'F6GDETAIL' ):SetOptional( .T. )

	aAdd(aRelac,{'F6G_FILIAL'	,'xFilial("F6G")'})
	aAdd(aRelac,{'F6G_ADAPTE' 	,'F6F_CODE'})

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'F6GDETAIL', aRelac , "F6G_FILIAL+F6G_ADAPTE+F6G_ITEM")

Return(oModel)

/*/{Protheus.doc} RU99D20103_TrigAdapt(cField as Character)
    Trigger function for Adapters table fields. Returns new value for updated field. 
    @type function
    @param cField, Character, Name of field to be updated
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Character, New value of updated field
    @example M->F6F_ADMVC := RU99D20103_TrigAdapt('F6F_ADMVC')
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Function RU99D20103_TrigAdapt(cField as Character) // Not Static Function because is used in the trigger, produces error otherwise

    Local oModelAct := FWModelActive() 
    Local cVal := oModelAct:GetValue('F6FMASTER',cField)
    Local cOper := oModelAct:GetValue('F6FMASTER','F6F_OPER')
    Local cType := oModelAct:GetValue('F6FMASTER','F6F_TYPE') 
    Local cMileAdapter := oModelAct:GetValue('F6FMASTER','F6F_ADMILE')
    
    Do Case
        Case cField == 'F6F_ADMVC'
            If cOper == SEND_OPER
                If cType == MILE_TYPE
                    cVal := AllTrim(Posicione("XXJ",1,cMileAdapter,"XXJ_ADAPT")) // xxj_code
                ElseIf cType == CUSTOM_TYPE
                    cVal := ''
                EndIf
            ElseIf cOper == RECEIVE_OPER 
                If cType == CUSTOM_TYPE
                    cVal := ''
                EndIf
            EndIf
        Case cField == 'F6F_ADMILE'
            If cOper == SEND_OPER .Or. cOper == RECEIVE_OPER
                If cType == CUSTOM_TYPE
                    cVal := ''
                EndIf
            EndIf
        Case cField == 'F6F_CUSTOM'
            If cOper == SEND_OPER
                cVal := ''
            EndIf
        Case cField == 'F6F_QUEUE'
            If cOper == SEND_OPER
                cVal := '0' // Does not apply
            ElseIf cOper == RECEIVE_OPER
                cVal := '1' // Passive
            EndIf
    End Do

Return cVal

/*/{Protheus.doc} RU99D20104_TrigAdaptEndpoint(cField as Character)
    Trigger function for Adapters X EndPoints table fields. Returns new value for updated field. 
    @type function
    @param cField, Character, Name of field to be updated
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Character, New value of updated field
    @example M->F6G_QUEUE := RU99D20104_TrigAdaptEndpoint("F6G_QUEUE")
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Function RU99D20104_TrigAdaptEndpoint(cField as Character) // Not Static Function because is used in the trigger, produces error otherwise

    Local oModelAct := FWModelActive() 
    Local cVal := AllTrim(oModelAct:GetValue('F6GDETAIL',cField))
    Local cEndPointCode := oModelAct:GetValue('F6GDETAIL','F6G_ENDPOI')
    Local cOper := oModelAct:GetValue('F6FMASTER','F6F_OPER')
    Local cF6EType := Posicione("F6E", 1, xFilial("F6E") + cEndPointCode, "F6E->F6E_TYPE") // F6E_filial + F6E_code 

    Do Case
    Case cField == 'F6G_PATH'
        If cOper == SEND_OPER .Or. cOper == RECEIVE_OPER
            If !(cF6EType == REST_TYPE)
                cVal := ''  
            EndIf
        EndIf
    Case cField == 'F6G_QUEUE'
        If cOper == SEND_OPER .Or. cOper == RECEIVE_OPER
            If cF6EType == AMQP_TYPE
                cVal := IIF(EMPTY(cEndPointCode),"",Posicione("F6E",1,xFilial('F6E')+cEndPointCode,"F6E->F6E_A_QUEU"))
            Else
                cVal := ''  
            EndIf
        EndIf
    Case cField == 'F6G_AUTHAD'    
        If cOper == SEND_OPER .Or. cOper == RECEIVE_OPER
            If cF6EType == REST_TYPE
                cVal := IIF(EMPTY(cEndPointCode),"",Posicione("F6E",1,xFilial('F6E')+cEndPointCode,"F6E->F6E_R_AUTH"))
            Else
                cVal := ''  
            EndIf
        EndIf  
    End Case

Return cVal

/*/{Protheus.doc} RU99D20105_F6GWhen(cField as Character)
    Defines conditions for field in grid part of 
    the form to be editable. The field belongs to F6G table.
    Result depends on other fields values.
    @type function
    @param cField, Character, Name of field with regulated access
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Logical, Flag of field access permisson
    @example lCanEdit := F6GWhen('F6G_PATH')
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Function RU99D20105_F6GWhen(cField as Character)

    Local oModelAct := FWModelActive() 
    Local cEndPointCode := oModelAct:GetValue('F6GDETAIL','F6G_ENDPOI')
    Local cF6EType := Posicione("F6E", 1, xFilial("F6E") + cEndPointCode, "F6E_TYPE") // F6E_filial + F6E_code 
    Local lRet := .F.

    Do Case 
        Case cField == 'F6G_QUEUE'
            lRet := (cF6EType == AMQP_TYPE)
        Case cField == 'F6G_PATH'
            lRet := (cF6EType == REST_TYPE)
    End Do

Return lRet

/*/{Protheus.doc} RU99D20101_F6FValid(cField as Character)
    Validates value of passed field by its name.
    Field assumed to be in main part of the form, from F6F table.
    @type function
    @param cField, Character, Name of field to be validated
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Logical, Flag of successful field value validation
    @example lIsValid := F6FValid('F6F_CUSTOM')
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Function RU99D20101_F6FValid(cField as Character)

    Local oModelAct := FWModelActive() 
    Local cOper := oModelAct:GetValue('F6FMASTER','F6F_OPER')
    Local cVal := oModelAct:GetValue('F6FMASTER',cField)
    Local aArea := FwGetArea()
    Local lRet := .T.
    Do Case 
        Case cField == 'F6F_CODE'
            DbSelectArea("F6F")
            F6F->(DbSetOrder(1)) // F6F_filial + F6F_code + F6F_oper
            If F6F->(DbSeek(xFilial("F6F")+cVal))
                lRet := .F.
            EndIf
            If !lRet
                Help("", 1, "Ma3"/*cTitle*/, , STR0006/*cError*/, 1, 0, , , , , ) // Code already exists
            EndIf
        Case cField == 'F6F_CUSTOM' .or. cField == 'F6F_TRANS' .or. cField == 'F6F_SWAGG'
            lRet:= ValidateMacrosString(cVal) .Or. (Alltrim(cVal) == "") 
            If !lRet 
                lRet := FuncExist(cVal,.F.) 
            EndIf 
            IF !lRet
                Help("", 1, "Ma3"/*cTitle*/, , F6EI18N(STR0005,{RetTitle(cField)})/*cError*/, 1, 0, , , , , ) // Invalid value. Inform a text of #1 field to be macro executed between (") or a function
            EndIf
        Case cField == 'F6F_ADMVC'
            lRet := ValidateAdapterMVC(cVal,cOper) // Help message is inside the function
        Case cField == 'F6F_ADMILE'
            lRet := ExistCPO("XXJ",cVal)
    End Do

    FwRestArea(aArea)

Return lRet

/*/{Protheus.doc} RU99D20102_F6GValid(cField as Character)
    Vlidates value of passed field by its name.
    Field assumed to be in grid part of the form, from F6G table.
    @type function
    @param cField, Character, Name of field to be validated
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Logical, Flag of successful field value validation
    @example lIsValid := F6GValid('F6G_TRANS')
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Function RU99D20102_F6GValid(cField as Character)

    Local oModelAct := FWModelActive() 
    Local cVal := AllTrim(oModelAct:GetValue('F6GDETAIL',cField))
    Local lRet := .T.

    Do Case 
        Case cField == 'F6G_TRANS'
            lRet := ValidateMacrosString(cVal) .Or. (Alltrim(cVal) == "") 
            If !lRet 
                lRet := FuncExist(cVal,.F.)
            EndIf
            If !lRet
                Help("", 1, "Ma3"/*cTitle*/, , F6EI18N(STR0005,{RetTitle(cField)})/*cError*/, 1, 0, NIL, NIL, NIL, NIL, NIL) // Invalid value. Inform a text of #1 field to be macro executed between (") or a function
            Endif
        Case cField == 'F6G_VALID'
            lRet := ValidateMacrosString(cVal) .Or. (Alltrim(cVal) == "") 
            If !lRet 
                If !(cVal == "") // Empty value is accepted
                    lRet := FuncExist(cVal,.F.)
                EndIf
            Endif
            If !lRet
                Help("", 1, "Ma3"/*cTitle*/, , F6EI18N(STR0005,{RetTitle(cField)})/*cError*/, 1, 0, NIL, NIL, NIL, NIL, NIL) // Invalid value. Inform a text of #1 field to be macro executed between (") or a function
            Endif
        Case cField == 'F6G_PATH'
            lRet:= ValidateMacrosString(cVal) .Or. (Alltrim(cVal) == "") 
            If !lRet 
                lRet := FuncExist(cVal,.F.)
            EndIf
            If !lRet
                Help("", 1, "Ma3"/*cTitle*/, , F6EI18N(STR0005,{RetTitle(cField)})/*cError*/, 1, 0, NIL, NIL, NIL, NIL, NIL) // Invalid value. Inform a text of #1 field to be macro executed between (") or a function
            Endif
        Case cField == 'F6G_ENDPOI'
            lRet := ExistCpo('F6E',cVal) // It has its own HELP Message
    End Do

Return lRet

/*/{Protheus.doc} ValidModel(oModel)
    Validates main model of "Adapter" routine.
    @type function
    @param oModel, Object, Current active model of "Adapters" routine
    @author idashkov
    @since 21/12/2023
    @version 1.0
    @return Logical, Flag of successful Model validation
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Static Function ValidModel(oModel)

    Local lRet := .T.
    Local oModelAct := FWModelActive() 
    Local cOper := oModelAct:GetValue('F6FMASTER','F6F_OPER')
    Local cType := oModelAct:GetValue('F6FMASTER','F6F_TYPE')
    Local cMVCRoutine := oModelAct:GetValue('F6FMASTER','F6F_ADMVC')
    Local cMILERoutine := oModelAct:GetValue('F6FMASTER','F6F_ADMILE') 
    Local cEndPointCode := oModelAct:GetValue('F6GDETAIL','F6G_ENDPOI')
    Local nColGrid := oModel:GetModel('F6GDETAIL'):Length(.T.)
    Local lUpdate := oModelAct:GetValue('F6FMASTER','F6F_UPDATE')
    Local lDelete := oModelAct:GetValue('F6FMASTER','F6F_DELETE') 
    Local aArea := FwGetArea()
    Local cError := ""
    Local cWarning := ""
    Local oXml
    If cType == MILE_TYPE
        If Empty(oModelAct:GetValue('F6FMASTER','F6F_ALIAS'))
            Help("", 1, "Ma3"/*cTitle*/, , I18N(STR0008,{RetTitle('F6F_ALIAS')})/*cError*/, 1, 0, , , , , ) // Value of #1 is mandatory for MILE adapter
            lRet := .F.
        EndIf
    EndIf

    If lRet
        If cOper == RECEIVE_OPER 
            If cType == MILE_TYPE 
                If !Empty(cMILERoutine)
                    If lUpdate .Or. lDelete // Adapter to be used in UPDATE or DELETE operations 
                        oXml := XmlParser(Posicione("XXJ",1,cMILERoutine,"XXJ_LAYOUT"),"_",@cError,@cWarning) // Perhaps instead of parsing XXJ_LAYOUT MILE object (FWMile()) with the layout can be used
                        If ValType(oXml) == 'O'
                            oDetXZ1Info := oXml:_CFGA600:_XZ1MASTER
                            If AllTrim(oDetXZ1Info:_XZ1_TYPE:_VALUE:TEXT) == '1' // MSExecAuto 
                                Help("", 1, "Ma3"/*cTitle*/, , STR0001/*cError*/, 1, 0, , , , , ) // Mile adapter with 'MSExecAuto' type cannot be used for update or delete operation
                                lRet := .F.
                            EndIf
                        Else
                            Help("", 1, "Ma3"/*cTitle*/, , I18N(STR0009,{AllTrim(cMILERoutine)})/*cError*/, 1, 0, , , , , ) // Could not get Mile adapter [#1] layout
                            lRet := .F.
                        EndIf
                    EndIf
                Else
                    Help("", 1, "Ma3"/*cTitle*/, , I18N(STR0010,{RetTitle('F6F_ADMILE')})/*cError*/, 1, 0, , , , , ) // The {} value cannot be empty
                    lRet := .F.
                EndIf
            ElseIf cType == CUSTOM_TYPE
                If AllTrim(oModelAct:GetValue('F6FMASTER','F6F_CUSTOM')) == ""
                    Help("", 1, "Ma3"/*cTitle*/, , STR0002/*cError*/, 1, 0, , , , , ) // Custom adapter is mandatory for 'Custom' type
                    lRet := .F.
                EndIf
            EndIf
        ElseIf cOper == SEND_OPER 
            // Check head in the form
            If cType == MVC_TYPE .Or. cType == MILE_TYPE 
                If !Empty(cMVCRoutine)
                    lRet := ValidateAdapterMVC(cMVCRoutine,cOper) // Help message is inside the function
                EndIf
            EndIf
            If lRet // Check grid in the form if head was OK
                If nColGrid == 1 .AND. AllTrim(cEndPointCode) == ""
                    Help("", 1, "Ma3"/*cTitle*/, , STR0004/*cError*/, 1, 0, , , , , ) // The list of endpoints could not be empty
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    FwRestArea(aArea)

Return lRet

/*/{Protheus.doc} ViewDef()
    View form of Adapters routine
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version 1.0
    @return Object, View form of Adapter routine
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function ViewDef()

	Local oView as Object
	Local oModel as Object
	Local oStrF6F as Object

	oModel := ModelDef()
	oStrF6F := FWFormStruct(2, "F6F")
	oStrF6G := FWFormStruct(2, "F6G")
    oStrF6G:RemoveField('F6G_ADAPTE')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("F6F", oStrF6F, "F6FMASTER")
	oView:AddGrid( 'F6G', oStrF6G, 'F6GDETAIL' )

	oView:AddIncrementField( "F6GDETAIL", 'F6G_ITEM' )
	oView:CreateHorizontalBox( 'TOP' 	, 60 )
	oView:CreateHorizontalBox( 'BOTTOM' , 40 )

	oView:SetOwnerView( 'F6F', 'TOP'   )
	oView:SetOwnerView( 'F6G', 'BOTTOM'   )

Return(oView)

/*/{Protheus.doc} RU99D20106_SXB()
    Function for special query (lookup) - XXJRUS
    @type function
    @author @Bruno Sobieski
    @since 
    @version 
    @return Character, XXJ_CODE value selected from the shown list 
/*/
FUNCTION RU99D20106_SXB()

RETURN FWMILEXXJF3( "XXJ->XXJ_TYPE== '"+M->F6F_OPER +"' " )

/*FUNCTION RU99D201A_SX7()

RETURN FWMILEXXJF3( "XXJ->XXJ_TYPE== '"+M->F6F_OPER +"' " ) 
*/

/*/{Protheus.doc} FuncExist(cFuncName,lCanBeOnlyUser)
    Checks if passed function exists in appserver.
    @type function
    @param cFuncName, Character, Name of function to be checked
    @param lCanBeOnlyUser, Character, Should be the passed function only User type or any type
    @author idashkov
    @since 09/01/2023
    @version 1.0
    @return Logical, Flag of function indeed exists 
    @example lExists := FuncExist("U_MyFunc()",.T.)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Static Function FuncExist(cFuncName,lCanBeOnlyUser)

    Local lRet := .F.
    Local cVal := UPPER(StrTran(cFuncName, " ", ""))
    Local nAt  := At("(",cFuncName)
    Default lCanBeOnlyUser := .F.
    If nAt > 0
        cFuncName := SubStr(cFuncName,1,nAt-1)
    Endif
    If lCanBeOnlyUser // Assumed it can be only User Function here
        If SubStr(cVal,1,2) == 'U_' .And. !(UPPER(cVal)== 'U_')
            lRet := FindFunction(cVal) 
        EndIf
    Else
        lRet := FindFunction(cVal) 
    EndIf

Return lRet

/*/{Protheus.doc} ValidateMacrosString(cStr as Character)
    Validates string to be called as macros by '&' operator
    @type function
    @param cStr, Character, String to be checked
    @author idashkov
    @since 16/01/2023
    @version 1.0
    @return Logical, Flag of sucessfull validation
    @example lRet := ValidateMacrosString('"/fwmodel/MATA010"')
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5829
*/
Static Function ValidateMacrosString(cStr as Character)

    Local lRet := .F.
    Local cFirstSym := ""
    Local cLastSym := ""

    cStr := StrTran(cStr, " ", "")
    cFirstSym := SubStr(cStr,1,1)
    cLastSym := SubStr(cStr,Len(cStr),1)

    If (cFirstSym == cLastSym)
        If cFirstSym == '"' .Or. cFirstSym == "'"
            lRet := .T.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} ValidateAdapterMVC
    Validates if MVC model set in the adapter 
    exists and has NPEAI event installed
    @type function
    @author bsobieski
    @since 28/02/2024
    @param cMVCRoutine, character, MVC Adapter Code
    @return Logical, TRUE if adapter is OK
/*/
Static Function ValidateAdapterMVC(cMVCRoutine,cOper)
    
    Local lRet := .T.
    Local oAdapterModel as Object // Instantate adapter model
    
    If !Empty(AllTrim(cMVCRoutine))
        oAdapterModel := FWLoadModel(cMVCRoutine)
        If oAdapterModel == Nil
            Help("", 1, "Ma3"/*cTitle*/, , STR0007/*cError*/, 1, 0, , , , , ) // MVC Model does not exist
            lRet := .F.
        ElseIf cOper == SEND_OPER .And. (oAdapterModel:oEventHandler == NIL .OR. ASCAN(oAdapterModel:oEventHandler:aEvents, {|x| x:cIdEVENT == "NPEAI"}) == 0) 
            Help("", 1, "Ma3"/*cTitle*/, , STR0003/*cError*/, 1, 0, , , , , ) // There are no Events in EAI defined for MILE
            lRet := .F.
        EndIf
    EndIf

Return lRet
                   
//Merge Russia R14 
                   
