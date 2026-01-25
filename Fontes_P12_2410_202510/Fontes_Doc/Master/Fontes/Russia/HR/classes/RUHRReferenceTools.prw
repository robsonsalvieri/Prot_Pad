#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE RUSS20301_LENGTH 8
#DEFINE RUSS20302_LENGTH 200

#DEFINE REFERENCES_ROUTINE "RU07T11"
#DEFINE F6H_MODEL_ID "F6HMASTER"

/*/
{Protheus.doc} RUHRReferenceTools
    Class for working with reference sets

    @type Class
    @author dtereshenko
    @since 10/07/2019
    @version 12.1.23
/*/
Class RUHRReferenceTools From LongNameClass
    Data oReferences As Object


    Method New() Constructor

    Method GetMap()
    Method GetAllMandatoryByMat(cMat)
    Method GetExpByTypes(cMat, cRefTypes)
    Method GetExp(cMat, cRefType)
    Method GetTotalDays()

EndClass

/*/
{Protheus.doc} New()
    Default RUHRReferenceTools constructor

    @type Method
    @params
    @author dtereshenko
    @since 10/08/2019
    @version 12.1.23
    @return RUHRReferenceTools,    Object,    RUHRReferenceTools instance
/*/
Method New() Class RUHRReferenceTools
    ::oReferences := RUMap():New()
Return Self

/*/
{Protheus.doc} GetMap()
    Returns References

    @type Method
    @params
    @author dtereshenko
    @since 10/08/2019
    @version 12.1.23
    @return oReferences,    Object,    RUMap - set of References
/*/
Method GetMap() Class RUHRReferenceTools
Return ::oReferences

/*/
{Protheus.doc} GetAllMandatoryByMat(cMat As Char)
    Fill and return ::oReferences with all mandatory References by employee's reg. number

    @type Method
    @params cMat,          Char,     Employee's reg. number
    @return oReferences,   Object,   RUMap - set of References
    @author dtereshenko
    @since 10/08/2019
    @version 12.1.23
/*/
Method GetAllMandatoryByMat(cMat) Class RUHRReferenceTools
    Local cCic As Char
    Local cQuery As Char
    Local cRefTypes As Char
    Local cRccConteo As Char
    Local cRefTypeCode As Char
    Local lUnique As Logical
    Local lMandatory As Logical
    Local lSystem As Logical
    Local oRefModel As Object
    Local oReference As Object
    Local aSavedArea := GetArea()
    Local aMandatoryTypes := {}

    Default cMat := SRA->RA_MAT

    ::oReferences:Clean()

    cCic := fRUGetCIC(cMat)

    // Get mandatory reference types
    cQuery := "SELECT RCC_CONTEU FROM " + RetSQLName("RCC") + " WHERE RCC_CODIGO = 'S203' AND D_E_L_E_T_ = ' '"
    cRefTypes := MPSysOpenQuery(cQuery, GetNextAlias())

    dbSelectArea(cRefTypes)
    While !EoF()
        cRccConteo := (cRefTypes)->RCC_CONTEU

        cRefTypeCode := Substr(cRccConteo, 1, RUSS20301_LENGTH)
        lUnique := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 1, 1) == "1" )
        lMandatory := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 2, 1) == "1" )
        lSystem := ( Substr(cRccConteo, RUSS20301_LENGTH + RUSS20302_LENGTH + 3, 1) == "1" )

        If lUnique .And. lMandatory .And. lSystem
            aAdd(aMandatoryTypes, cRefTypeCode)
        EndIf

        dbSkip()
    EndDo
    dbCloseArea()

    // Get employee's mandatory references
    dbSelectArea("F6H")
    dbSetOrder(1) // F6H_FILIAL + F6H_CIC
    If F6H->(dbSeek(FWxFilial("F6H") + cCic))
        While !EoF() .And. F6H->F6H_FILIAL+F6H_CIC == FWxFilial("F6H") + cCic
            If Ascan(aMandatoryTypes, { |x| x == F6H->F6H_REFTYPE }) != 0 .And. ;
               ( F6H->F6H_END > dDatabase .Or. F6H->F6H_END == SToD("//") )

                oRefModel := FWLoadModel(REFERENCES_ROUTINE)
                oReference := RUHRReference():New(F6H->F6H_REFTYPE, oRefModel)
                oReference:Activate(MODEL_OPERATION_VIEW)
                ::oReferences:Set(oReference:GetIndex(), oReference)
            EndIf
            dBSkip()
        EndDo
    EndIf
    dbCloseArea()

    RestArea(aSavedArea)

Return ::oReferences

/*/
{Protheus.doc} GetExpByTypes(cMat As Char, cRefTypes As Char)
    Fill and return ::oReferences with all References of given types by employee's reg. number

    @type Method
    @params cMat,          Char,     Employee's reg. number
            cRefTypes,     Char,     Reference types (by separator)
    @return oReferences,   Object,   RUMap - set of References
    @author dtereshenko
    @since 2020/07/22
    @version 12.1.23
/*/
Method GetExpByTypes(cMat, cRefTypes) Class RUHRReferenceTools
    Local oRefModel As Object
    Local oReference As Object
    Local aSavedArea := GetArea()

    ::oReferences:Clean()

    DBSelectArea("F6H")
    DBSetOrder(2) // F6H_FILIAL + F6H_MAT
    If F6H->(DBSeek(FWxFilial("F6H") + cMat))
        While !EoF() .And. F6H->F6H_FILIAL+F6H_MAT == FWxFilial("F6H") + cMat
            If AllTrim(F6H->F6H_REFTYP) $ cRefTypes
                oRefModel := FWLoadModel(REFERENCES_ROUTINE)
                oReference := RUHRReference():New(F6H->F6H_REFTYP, oRefModel)
                oReference:Activate(MODEL_OPERATION_VIEW)
                ::oReferences:Set(oReference:GetField("F6H_START"), oReference)
            EndIf
            dBSkip()
        EndDo
    EndIf

    RestArea(aSavedArea)

Return ::oReferences

/*/
{Protheus.doc} GetExp(cMat As Char, cRefType As Char)
    Fill and return ::oReferences with all References of given type by employee's reg. number

    @type Method
    @params cMat,          Char,     Employee's reg. number
            cRefType,      Char,     Reference type
    @return oReferences,   Object,   RUMap - set of References
    @author dtereshenko
    @since 2020/07/22
    @version 12.1.23
/*/
Method GetExp(cMat, cRefType) Class RUHRReferenceTools

    ::oReferences := ::GetExpByTypes(cMat, cRefType)

Return ::oReferences

/*/
{Protheus.doc} GetTotalDays()
    Returns number of days of all contained references

    @type Method
    @params
    @return nDays,   Numeric,   Number of days
    @author dtereshenko
    @since 2020/07/23
    @version 12.1.23
/*/
Method GetTotalDays() Class RUHRReferenceTools
    Local dStartDate As Date
    Local dEndDate As Date
    Local nI As Numeric
    Local lIsUntilNow As Logical
    Local nDays := 0
    Local aReferences := {}

    ::oReferences:List(aReferences)

    For nI := 1 To Len(aReferences)
        dStartDate := aReferences[nI][2]:GetField("F6H_START")
        dEndDate := aReferences[nI][2]:GetField("F6H_END")
        lIsUntilNow := aReferences[nI][2]:GetField("F6H_TILNOW")

        If Empty(dEndDate) .AND. lIsUntilNow
            dEndDate := dDataBase
        EndIf

        nDays += (dEndDate - dStartDate)
    Next nI

Return nDays
