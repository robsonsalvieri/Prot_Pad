#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA1050.CH"


/*/
{Protheus.doc} RUGPEA050Event
    Class of events for GPEA050.

    @type Class
    @author vselyakov
    @since 17.11.2021
    @version 12.1.33
/*/
Class RUGPEA050Event From FWModelEvent
    Method New() Constructor
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Method RUGPEA5001_IsCanChangePlannedVacation(dDateVacation, nDaysVacation)
Endclass

/*{Protheus.doc} New()
    Constructor of events class RU07T12Event().

    @type Method
    @author vselyakov
    @since 17.11.2021
    @version 12.1.33
*/
Method New() Class RUGPEA050Event
Return Self

/*/
{Protheus.doc} GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Method that is called by MVC when Grid row pre-validation actions occur.
    Here you can do the validation for the fields in the grid in the model.

    @type Method
    @params oSubModel, Object, Object of submodel.
            cModelID, Character, Model ID.
            nLine, Numeric, Line number into the grid.
            cAction, Character, The action to be taken on the table (It can take the following values: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE).
            cId, Character, Name of the field to be modified.
            xValue, Indefined, New value of field.
            xCurrentValue, Indefined, Current value of field.
    @author vselyakov
    @since 17.11.2021
    @version 12.1.33
    @return lIsValid, Logical, 
    @example 
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RUGPEA050Event
    Local lIsValid As Logical

    lIsValid := .T.

    If cAction == "SETVALUE" .And. cId $ "RF_DATAINI|RF_DFEPRO1|RF_DATINI2|RF_DFEPRO2|RF_DATINI3|RF_DFEPRO3|RF_DATINI4|RF_DFEPRO4|RF_DATINI5|RF_DFEPRO5|RF_DATINI6|RF_DFEPRO6"
        Do Case
            Case cId $ "RF_DATAINI|RF_DFEPRO1"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATAINI"), oSubModel:GetValue("RF_DFEPRO1"))
            Case cId $ "RF_DATINI2|RF_DFEPRO2"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATINI2"), oSubModel:GetValue("RF_DFEPRO2"))
            Case cId $ "RF_DATINI3|RF_DFEPRO3"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATINI3"), oSubModel:GetValue("RF_DFEPRO3"))
            Case cId $ "RF_DATINI4|RF_DFEPRO4"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATINI4"), oSubModel:GetValue("RF_DFEPRO4"))
            Case cId $ "RF_DATINI5|RF_DFEPRO5"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATINI5"), oSubModel:GetValue("RF_DFEPRO5"))
            Case cId $ "RF_DATINI6|RF_DFEPRO6"
                lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATINI6"), oSubModel:GetValue("RF_DFEPRO6"))
        EndCase

        If !lIsValid
            Help(,, STR0016,, STR0085, 1, 0)
        EndIf
    EndIf

Return lIsValid

/* 
{Protheus.doc} RUGPEA5001_IsCanChangePlannedVacation(dDateVacation, nDaysVacation)
    The method checks for the existence of the calculation of the specified planned vacation in the SRR table.
    If the SRR has a record of this vacation, then this planned vacation cannot be changed in GPEA050.

    @type Method
    @params dDateVacation, Date, Scheduled vacation start date.
            nDaysVacation, Numeric, Number of days of planned vacation.
    @return lResult, Logical, .T. - if planned vacation can be changed, .F. - in other case.
    @author vselyakov
    @since 17.11.2021
    @version 12.1.33
    @example lIsValid := ::RUGPEA5001_IsCanChangePlannedVacation(oSubModel:GetValue("RF_DATAINI"), oSubModel:GetValue("RF_DFEPRO1"))
*/
Method RUGPEA5001_IsCanChangePlannedVacation(dDateVacation, nDaysVacation) Class RUGPEA050Event
    Local lResult       As Logical
    Local aPaymentTypes As Array
    Local aArea         As Array
    Local oStatement    As Object
    Local cQuery        As Character
    Local cTab          As Character

    aArea := GetArea()
    lResult := .F.
    
    /* Payment types of vacation:
        * 121 - vacation current month.
        * 121 - vacation next month.
        * 125 - vacation monetary compensation.
    */
    aPaymentTypes := {"121", "122", "125"}

    // Select lines from SRR table for the presence of records about the specified vacation.
    cQuery := " SELECT "
    cQuery += " COUNT(*) AS VACATIONLENGTH "
    cQuery += " FROM " + RetSqlName("SRR") + " WHERE "
    cQuery += " RR_FILIAL = ? "
    cQuery += " AND RR_MAT = ? " 
    cQuery += " AND RR_PD IN (?) "
    cQuery += " AND RR_DATA = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRR"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetDate(4, dDateVacation)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    /*
        If the SQL request returns a value greater than 0, then the SRR contains a record about the specified vacation.
        This means that you cannot change the data on it in the vacation schedule. Therefore, .F returns.
    */
    lResult := !((cTab)->VACATIONLENGTH > 0)

    DBCloseArea()

    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return lResult