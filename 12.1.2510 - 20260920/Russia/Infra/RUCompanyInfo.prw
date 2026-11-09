#INCLUDE "PROTHEUS.CH"



/*/{Protheus.doc} RUCompanyInfo
    Class for returns information about a group of companies, a company or a business unit.

    @type Class
    @author vselyakov
    @since 2023/10/02
    @version 12.1.23
/*/
Class RUCompanyInfo From LongNameClass

    // Methods.
    Method New() Constructor

    Method GetInfoAboutCompany(nTypeAgent, cAgentGroupCode, cCompanyCode, cUnitCode)

EndClass

/*/{Protheus.doc} New
    Default constructor.

    @type Method
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return Object, RUCompanyInfo instance.
    @example RUCompanyInfo():New()
/*/
Method New() Class RUCompanyInfo

Return Self

/*/{Protheus.doc} GetInfoAboutCompany
    The function returns information about a group of companies, a company or a business unit.
    If you need information about the branch, you need to use the "GetCoBrRUS" function.

    nTypeAgent = 4 - Group company
    nTypeAgent = 3 - Company
    nTypeAgent = 2 - Buisness unit

    @type function
    @version 12.1.33
    @author vselyakov
    @since 2023/10/02
    @param nTypeAgent, Numeric, agent type from parameters.
           nTypeAgent = 4 - Group company
           nTypeAgent = 3 - Company
           nTypeAgent = 2 - Buisness unit
    @param cAgentGroupCode, Character, group company code.
    @param cCompanyCode, Character, company code.
    @param cUnitCode, Character, buiness unit code.
    @return array, array of information about unit.
            aCompanyInfo[1] - CO_INN // INN.
            aCompanyInfo[2] - CO_KPP // KPP.
            aCompanyInfo[3] - CO_FULLNAM // Full name.
            aCompanyInfo[4] - CO_LOCLTAX // IFNS code.
            aCompanyInfo[5] - CO_OKTMO // OKTMO.
            aCompanyInfo[6] - CO_PHONENU // Phone number.
            aCompanyInfo[7] - CO_OKVED // OKVED.
    @example aCompanyInfo := oCompanyInfo:GetInfoAboutCompany(self:aParameters[AGENT_TYPE_INDEX], self:aParameters[PARAM_GROUP_COMPANY_INDEX], self:aParameters[PARAM_COMPANY_INDEX], self:aParameters[PARAM_FILIAL_INDEX])
/*/
Method GetInfoAboutCompany(nTypeAgent, cAgentGroupCode, cCompanyCode, cUnitCode) Class RUCompanyInfo
    Local cQuery := ""  As Character
    Local oStatement := Nil As Object
    Local aArea := GetArea() As Array
    Local cCO_TIPO := "" As Character
    Local aCompanyInfo := {} As Array

    // Defenition type of object like "sys_company_l_rus" style.
    If nTypeAgent == 4 // Group company.
        cCO_TIPO := "0"
    ElseIf nTypeAgent == 3 // Company.
        cCO_TIPO := "1"
    ElseIf nTypeAgent == 2 // Buisness unit.
        cCO_TIPO := "2"
    EndIf

    // Make SQL query.
    cQuery := " SELECT CO_TIPO, CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_FULLNAM, CO_SHORTNM, CO_INN, CO_KPP, CO_PHONENU, CO_OKVED, CO_OKTMO, CO_LOCLTAX "
    cQuery += " FROM SYS_COMPANY_L_RUS " 
    cQuery += " WHERE "
    cQuery += "     CO_TIPO = ? "
    cQuery += "     AND CO_COMPGRP = ? " 
    cQuery += "     AND CO_COMPEMP = ? " 
    cQuery += "     AND CO_COMPUNI = ? " 
    cQuery += "     AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cCO_TIPO)
    oStatement:SetString(2, cAgentGroupCode)
    oStatement:SetString(3, cCompanyCode)
    oStatement:SetString(4, cUnitCode)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_INN)) // INN.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_KPP)) // KPP.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_FULLNAM)) // Full name.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_LOCLTAX)) // IFNS code.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_OKTMO)) // OKTMO.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_PHONENU)) // Phone number.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_OKVED)) // OKVED.

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aCompanyInfo
                   
//Merge Russia R14 
                   
