#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Maybe will be better to get these values from RCB
#DEFINE RUSS20301_LENGTH 8
#DEFINE RUSS20302_LENGTH 200

#DEFINE REFERENCES_ROUTINE "RU07T11"
#DEFINE F6H_MODEL_ID "F6HMASTER"
#DEFINE CLASS_NAME "RUHRREFERENCE"

/*/
{Protheus.doc} RUHRReference
    A wrapper class to facilitate further reference work

    @type Class
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
/*/
Class RUHRReference From LongNameClass
    Data oModel As Object
    Data cRefTypeCode As Char
    Data cRefTypeName As Char
    Data lUnique As Logical
    Data lMandatory As Logical
    Data lSystem As Logical
    Data lTilNow As Logical
    Data oQuestionMap As Object

    Method New(cRefTypeCode, oReferenceModel) Constructor

    Method IsActual(dDate)
    Method GetModel()
    Method SetModel(oReferenceModel)
    Method Activate()
    Method IsSimultaneously(oReference)
    Method ToString()
    Method GetIndex()
    Method GetContent()
    Method LoadLastUnique(cMat)
    Method Clone(dDateStart)
    Method ModelIsFine(oModel)
    Method ClassName()
    Method SetField(cFieldName, xFieldValue)
    Method GetField(cFieldName)
    Method SetIsTilNow(lIsUntilNow)
    Method Ask(cQuestion)

EndClass

/*/
{Protheus.doc} New(cRefTypeCode As Char, oModelF6H As Object)
    Default RUHRReference constructor

    @type Method
    @params cRefTypeCode,      Char,      Reference code according to RCC\S203
            oReferenceModel,   Object,    RU07T11 reference model (FWFormModel)
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
    @return RUHRReference,    Object,    RUHRReference instance
/*/
Method New(cRefTypeCode, oReferenceModel) Class RUHRReference
    Local cRccConteo As Char

    Default oReferenceModel := FWLoadModel(REFERENCES_ROUTINE)

    cRccConteo := fRUGetRccConteo("S203", cRefTypeCode)

    ::cRefTypeCode := cRefTypeCode
    ::cRefTypeName := Substr(cRccConteo, RUSS20301_LENGTH + 1, RUSS20302_LENGTH)
    ::lUnique := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 1, 1) == "1" )
    ::lMandatory := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 2, 1) == "1" )
    ::lSystem := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 3, 1) == "1" )
    ::lTilNow := .F.
    ::oQuestionMap := NIL

    If ::ModelIsFine(oReferenceModel)
        ::oModel := oReferenceModel
    EndIf

Return Self

/*/
{Protheus.doc} Activate(nOperationCode As Numeric)
    Activate self:Model

    @type Method
    @params nOperationCode,    Numeric,    MVC Model Operation Code: 
                                             1 - View
                                             3 - Insert (default value)
                                             4 - Update
                                             5 - Delete
                                             9 - Copy
    @return lResult,           Logical,    Operation result
    @author dtereshenko
    @since 10/03/2019
    @version 12.1.23
/*/
Method Activate(nOperationCode) Class RUHRReference
    Local lResult := .F.
    Local lUntilNow As Logical

    Default nOperationCode := MODEL_OPERATION_INSERT

    If ::ModelIsFine()
        If ::oModel:IsActive()
            ::oModel:DeActivate()
        EndIf

        ::oModel:SetOperation(nOperationCode)
        lResult := ::oModel:Activate()

        lUntilNow := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_TILNOW")
        ::SetIsTilNow(lUntilNow)

        If !::lTilNow .And. nOperationCode != MODEL_OPERATION_VIEW
            ::SetField("F6H_END", dDataBase)
        EndIf
        
    EndIf

Return lResult

/*/
{Protheus.doc} IsActual(dDate As Date)
    Check if transfered date is after beginning of the period and before its end.

    @type Method
    @params dDate,    Date,    Date to verify
    @author dtereshenko
    @since 10/01/2019
    @version 12.1.23
    @return RUHRReference,    Logical,    Verification result
/*/
Method IsActual(dDate) Class RUHRReference
    Local lIsActual As Logical
    Local dThisStart As Date
    Local dThisEnd As Date

    Default dDate := dDataBase

    If ::ModelIsFine() .And. ::oModel:IsActive()
        dThisStart := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_START")
        dThisEnd := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_END")
    EndIf

    If dThisStart != CToD("//")
        If dThisEnd != CToD("//")
            lIsActual := ( dDate >= dThisStart .And. dDate <= dThisEnd )
        Else
            lIsActual := ( dDate >= dThisStart )
        EndIf
    EndIf

Return lIsActual

/*/
{Protheus.doc} GetModel()
    Return model

    @type Method
    @params
    @author dtereshenko
    @since 10/03/2019
    @version 12.1.23
    @return oModel,    Object,    Model F6HMaster
/*/
Method GetModel() Class RUHRReference
Return ::oModel

/*/
{Protheus.doc} SetModel(oReferenceModel As Object)
    Set Model

    @type Method
    @params oReferenceModel,    Object,     RU07T11 reference model (FWFormModel)
    @return lResult,            Logical,    Operation result
    @author dtereshenko
    @since 10/03/2019
    @version 12.1.23
/*/
Method SetModel(oReferenceModel) Class RUHRReference
    Local lResult As Logical

    If lResult := ::ModelIsFine(oReferenceModel)
        ::oModel := oReferenceModel
    EndIf

Return lResult

/*/
{Protheus.doc} IsSimultaneously(oReference As Object)
    Check if transfered reference's simultaneous to this one

    @type Method
    @params oReference,    Object,    Reference to verify
    @author dtereshenko
    @since 10/01/2019
    @version 12.1.23
    @return nResult,    Numeric,    Verification result: 0 if references're completely simultaneous,
                                                         1 if tranfered ref. starts after this one,
                                                        -1 by default
/*/
Method IsSimultaneously(oReference) Class RUHRReference
    Local nResult As Numeric
    Local oRefModel As Object
    Local dRefStart As Date
    Local dRefEnd As Date
    Local dThisStart As Date
    Local dThisEnd As Date

    nResult := -1

    If ValType(oReference) == "O" .And. oReference:ClassName() == CLASS_NAME
        oRefModel := oReference:GetModel()

        If ::ModelIsFine() .And. ::ModelIsFine(oRefModel) .And. ::oModel:IsActive() .And. oRefModel:IsActive()

            dRefStart := oRefModel:GetModel(F6H_MODEL_ID):GetValue("F6H_START")
            dRefEnd := oRefModel:GetModel(F6H_MODEL_ID):GetValue("F6H_END")

            dThisStart := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_START")
            dThisEnd := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_END")

            If dRefStart >= dThisStart .And. dRefEnd <= dThisEnd
                nResult := 0
            ElseIf dRefStart >= dThisStart
                nResult := 1
            EndIf

        EndIf
    EndIf

Return nResult

/*/
{Protheus.doc} ToString()
    Returns document name + number + start date

    @type Method
    @params
    @author dtereshenko
    @since 10/01/2019
    @version 12.1.23
    @return cString,    Char,    Document name + number + start date
/*/
Method ToString() Class RUHRReference
    Local cNumber As Char
    Local dStart As Date
    Local cString := ""

    If ::ModelIsFine() .And. ::oModel:IsActive()
        cNumber := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_NUMBER")
        dStart := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_START")

        cString := ::cRefTypeName + cNumber + DToS(dStart)
    EndIf

Return cString

/*/
{Protheus.doc} GetIndex()
    Returns F6H_FILIAL + F6H_CIC + F6H_REFTYP + F6H_NUMBER

    @type Method
    @params
    @author dtereshenko
    @since 10/03/2019
    @version 12.1.23
    @return cIndex,    Char,    F6H_FILIAL + F6H_CIC + F6H_REFTYP + F6H_NUMBER
/*/
Method GetIndex() Class RUHRReference
    Local cFiial As Char
    Local cCic As Char
    Local cRefType As Char
    Local cNumber As Char
    Local cIndex := ""

    If ::ModelIsFine() .And. ::oModel:IsActive()
        cFiial := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_FILIAL")
        cCic := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_CIC")
        cRefType := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_REFTYP")
        cNumber := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_NUMBER")

        cIndex := cFiial + cCic + cRefType + cNumber
    EndIf

Return cIndex

/*/
{Protheus.doc} GetContent()
    Returns F6H_CONTEN or if F6H_CONTEN starts with "#" - result of expression evaluation

    @type Method
    @params
    @author dtereshenko
    @since 10/03/2019
    @version 12.1.23
    @return cContent,    Char,    F6H_CONTEN or if F6H_CONTEN starts with "#" - result of expression evaluation
/*/
Method GetContent() Class RUHRReference
    Local cContent := ""

    If ::ModelIsFine() .And. ::oModel:IsActive()
        cContent := ::oModel:GetModel(F6H_MODEL_ID):GetValue("F6H_CONTEN")

        If Substr(cContent, 1, 1) == "#"
            cContent = &(Substr(cContent, 2, Len(cContent) - 1))
        EndIf
    EndIf

Return cContent

/*/
{Protheus.doc} LoadLastUnique(cMat As Char)
    According to the reference type load the last one for the given employee

    @type Method
    @params cMat,       Char,       Employee's ID (RA_MAT)
    @return lResult,    Logical,    Operation result
    @author dtereshenko
    @since 10/01/2019
    @version 12.1.23
/*/
Method LoadLastUnique(cMat) Class RUHRReference
    Local cQuery As Char
    Local cEmployeeLatestDoc As Char
    Local oStatement As Object
    Local lResult := .F.

    cQuery := "SELECT R_E_C_N_O_ FROM " + RetSQLName("F6H") + " WHERE F6H_MAT = ? AND F6H_REFTYP = ? AND D_E_L_E_T_ = ' ' ORDER BY F6H_START DESC"

    oStatement := FWPreparedStatement():New()

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cMat)
    oStatement:SetString(2, ::cRefTypeCode)

    cEmployeeLatestDoc := MPSysOpenQuery(oStatement:GetFixQuery(), GetNextAlias())

    dbSelectArea(cEmployeeLatestDoc)
    (cEmployeeLatestDoc)->(DbGoTop())
    cEmployeeLatestDoc := (cEmployeeLatestDoc)->R_E_C_N_O_
    dbCloseArea()

    dbSelectArea("F6H")
    dbSetOrder(2) // F6H_FILIAL + F6H_MAT
    If F6H->(dbSeek(xFilial("F6H") + cMat))
        While !EoF() .And. F6H->F6H_FILIAL+F6H_MAT == xFilial("F6H") + cMat
            If Recno() == cEmployeeLatestDoc
                 lResult := ::Activate(::oModel:GetOperation())
                Exit
            EndIf
            dBSkip()
        EndDo
    EndIf
    dbCloseArea()

Return lResult

/*/
{Protheus.doc} Clone(dDateStart As Date)
    Clone reference with transfered start date and cleared document link and end date

    @type Method
    @params dDateStart,    Date,      Start date of the reference
    @author dtereshenko
    @since 10/01/2019
    @version 12.1.23
    @return oReference,    Object,    Clone of the reference
/*/
Method Clone(dDateStart) Class RUHRReference
    Local oNewReference As Object
    Local oNewRefModel As Object
    Local oNewRefStruct As Object
    Local aCopyFields As Array
    Local aEraseFields As Array
    Local nI As Numeric

    Default dDateStart := dDataBase

    aCopyFields := {"F6H_FILIAL", "F6H_CIC", "F6H_REFTYP", "F6H_MAT", "F6H_CARGO", "F6H_FUNC", "F6H_POST", "F6H_PD", "F6H_ISHAZ", "F6H_ISDANG"}
    aEraseFields := {"F6H_DOCTYP", "F6H_DOCID", "F6H_CONTEN", "F6H_NUMBER", "F6H_DESCR"}

    If ::ModelIsFine() .And. ::oModel:IsActive()
        oNewReference := RUHRReference():New(::cRefTypeCode)

        oNewRefStruct := FWFormStruct(1, "F6H")
        oNewRefModel := MPFormModel():New("RU07T11")
        oNewRefModel:AddFields("F6HMASTER",, oNewRefStruct)

        If oNewRefModel:IsActive()
            oNewRefModel:DeActivate()
        EndIf

        oNewRefModel:SetOperation(MODEL_OPERATION_INSERT)
        oNewRefModel:Activate()

        For nI := 1 To Len(aCopyFields)
            oNewRefModel:GetModel(F6H_MODEL_ID):SetValue(aCopyFields[nI], ::oModel:GetModel(F6H_MODEL_ID):GetValue(aCopyFields[nI]))
        Next nI

        For nI := 1 To Len(aEraseFields)
            oNewRefModel:GetModel(F6H_MODEL_ID):SetValue(aEraseFields[nI], "")
        Next nI

        oNewRefModel:GetModel(F6H_MODEL_ID):SetValue("F6H_START", dDateStart)
        oNewRefModel:GetModel(F6H_MODEL_ID):SetValue("F6H_END", CToD("//"))

        oNewReference:SetModel(oNewRefModel)
        oNewRefModel:CommitData()

    EndIf

Return oNewReference

/*/
{Protheus.doc} ModelIsFine(oModel As Object)
    Checks wether transfered Model can be used in the class

    @type Method
    @params oModel,    Object,    FWFormModel instance
    @return lResult,   Logical,   Check result
    @author dtereshenko
    @since 2020/07/16
    @version 12.1.23
/*/
Method ModelIsFine(oModel) Class RUHRReference
    Local lResult := .F.
    Default oModel := ::oModel

    lResult := ValType(oModel) == "O" .And. ;
               oModel:ClassName() == "FWFORMMODEL" .And. ;
               oModel:GetId() == REFERENCES_ROUTINE

Return lResult

/*/
{Protheus.doc} ClassName()
    Returns class name (RUHRREFERENCE)

    @type Method
    @params
    @return cClassName,   Char,   Class name (RUHRREFERENCE)
    @author dtereshenko
    @since 2020/07/16
    @version 12.1.23
/*/
Method ClassName() Class RUHRReference
Return CLASS_NAME

/*/
{Protheus.doc} SetField(cFieldName, xFieldValue)
    Set value of the field to internal FWFormFieldsModel

    @type Method
    @params cFieldName,    Char,      Field name
            xFieldValue,   Any,       Field value
    @return lResult,       Logical,   Operation result
    @author dtereshenko
    @since 2020/07/16
    @version 12.1.23
/*/
Method SetField(cFieldName, xFieldValue) Class RUHRReference
    Local lResult As Logical

    If ::ModelIsFine() .And. ::oModel:IsActive()
        lResult := ( ::oModel:GetModel(F6H_MODEL_ID):SetValue(cFieldName, xFieldValue) )
    EndIf

Return lResult

/*/
{Protheus.doc} GetField(cFieldName)
    Returns value of the transfered field from internal FWFormFieldsModel

    @type Method
    @params cFieldName,    Char,    Field name
    @return xFieldValue,   Any,     Field value
    @author dtereshenko
    @since 2020/07/16
    @version 12.1.23
/*/
Method GetField(cFieldName) Class RUHRReference
    Local xFieldValue

    If ::ModelIsFine() .And. ::oModel:IsActive()
        xFieldValue := ::oModel:GetModel(F6H_MODEL_ID):GetValue(cFieldName)
    EndIf

Return xFieldValue

/*
{Protheus.doc} SetIsTilNow(lIsUntilNow)
    Set field lTilNow from F6H_TILNOW of loaded reference.
    Shows that the reference is still valid now.

    @type Method
    @params lIsUntilNow,    Logical,    Shows that the reference is still valid now
    @return NIL
    @author vselyakov
    @since 2020/09/03
    @version 12.1.23
*/
Method SetIsTilNow(lIsUntilNow) Class RUHRReference
    ::lTilNow := lIsUntilNow
Return NIL

/*
{Protheus.doc} Ask(cQuestion)
    Initializes ::oQuestionMap. Collects data from the called pergunta.

    @type Method
    @params cQuestion,    Character,    Pergunte name.
    @return NIL
    @author vselyakov
    @since 2020/09/10
    @version 12.1.23
    @example ::Ask("TRMM080")
*/
Method Ask(cQuestion) Class RUHRReference
    Local aCurArea   As Array
    Local oStatement As Object
    Local cPerParNm  As Character // Parameter name of pergunte.
    Local cPerParTp  As Character // Parameter type of pergunte.
    Local cPerParVL  As Character // Parameter value of pergunte.
    Local cContent   As Character
    Local lPergOk    As Logical

    aCurArea := GetArea()
    ::oQuestionMap := RUMap():New()

    // If the name of the pergunta is not indicated, then exit.
    If Empty(cQuestion)
        ApMsgInfo("Please indicate the name of the existing pergunte.")
        Return NIL
    EndIf    

    // Pergunte(/*PergunteName*/, /*Show dialog or not (.T. default) */, /*Title*/, /*lOnlyView (if .T.-chages do not save)*/)
    lPergOk := Pergunte(cQuestion, .T., cQuestion, .T.)

    // If user press 'Cancel' - exit from method.
    If !lPergOk
        Return NIL
    EndIf

    // Let's execute an SQL query to get the names of the pergunta variables.
    oStatement := FWPreparedStatement():New()       
    cQuery := " SELECT X1_TIPO AS X1_TYPE, X1_VAR01 AS X1_PAR FROM " + MPSysSQLName("SX1") + " WHERE "
    cQuery += " X1_GRUPO=? "
    cQuery += " AND D_E_L_E_T_=' ' "
    
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cQuestion)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery(), "cAlias")

    DBSelectArea(cAlias)
    DBGoTop()

    WHILE !EOF()
        cPerParNm := AllTrim((cAlias)->X1_PAR) // Parameter name.
        cPerParTp := AllTrim((cAlias)->X1_TYPE) // Parameter type.

        If cPerParTp == "C"
            cPerParVL := AllTrim(&(cPerParNm)) // Parameter value.
        Else
            cPerParVL := &(cPerParNm) // Parameter value.
        EndIf

        ::oQuestionMap:Set(cPerParNm, cPerParVL)
 
        DBSkip()
    ENDDO

    DbCloseArea()   

    cContent := ::oQuestionMap:Implode("|")

    If ::ModelIsFine() .And. ::oModel:IsActive()
        ::SetField("F6H_CONTEN", cContent)
    EndIf

    If (M->F6H_CONTEM <> NIL)
        M->F6H_CONTEM := cContent
    EndIf

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aCurArea)
Return NIL