#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoRepr from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoRepr
	_Super:New(aFields)
    self:cAlias := "B8N"
    self:cfieldOrder := "B8N_CPFREP,B8N_CODOPE"
Return self

Method buscar() Class CenDaoRepr
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8N->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoRepr
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoRepr

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8N') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8N_FILIAL = '" + xFilial("B8N") + "' "

    cQuery += " AND B8N_CPFREP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("registrationOfIndividua")))
    cQuery += " AND B8N_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoRepr
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoRepr

    Default lInclui := .F.

	If B8N->(RecLock("B8N",lInclui))
		
        B8N->B8N_FILIAL := xFilial("B8N")
        If lInclui
        
            B8N->B8N_CPFREP := _Super:normalizeType(B8N->B8N_CPFREP,self:getValue("registrationOfIndividua")) /* Column B8N_CPFREP */
            B8N->B8N_CODOPE := _Super:normalizeType(B8N->B8N_CODOPE,self:getValue("providerRegister")) /* Column B8N_CODOPE */

        EndIf

        B8N->B8N_COMPEN := _Super:normalizeType(B8N->B8N_COMPEN,self:getValue("addressComplement")) /* Column B8N_COMPEN */
        B8N->B8N_BAIRRO := _Super:normalizeType(B8N->B8N_BAIRRO,self:getValue("district")) /* Column B8N_BAIRRO */
        B8N->B8N_CARGO := _Super:normalizeType(B8N->B8N_CARGO,self:getValue("representativeSPosition")) /* Column B8N_CARGO */
        B8N->B8N_CDIBGE := _Super:normalizeType(B8N->B8N_CDIBGE,self:getValue("ibgeCityCode")) /* Column B8N_CDIBGE */
        B8N->B8N_CODCEP := _Super:normalizeType(B8N->B8N_CODCEP,self:getValue("postAddrCode")) /* Column B8N_CODCEP */
        B8N->B8N_CODDDD := _Super:normalizeType(B8N->B8N_CODDDD,self:getValue("nationalCallingCd")) /* Column B8N_CODDDD */
        B8N->B8N_CODDDI := _Super:normalizeType(B8N->B8N_CODDDI,self:getValue("internationalCallinfCd")) /* Column B8N_CODDDI */
        B8N->B8N_DTEXRG := _Super:normalizeType(B8N->B8N_DTEXRG,self:getValue("idIssueDate")) /* Column B8N_DTEXRG */
        B8N->B8N_NMLOGR := _Super:normalizeType(B8N->B8N_NMLOGR,self:getValue("addressName")) /* Column B8N_NMLOGR */
        B8N->B8N_NOMEDE := _Super:normalizeType(B8N->B8N_NOMEDE,self:getValue("representativeSName")) /* Column B8N_NOMEDE */
        B8N->B8N_NUMERG := _Super:normalizeType(B8N->B8N_NUMERG,self:getValue("idNumber")) /* Column B8N_NUMERG */
        B8N->B8N_NUMLOG := _Super:normalizeType(B8N->B8N_NUMLOG,self:getValue("addressNumber")) /* Column B8N_NUMLOG */
        B8N->B8N_ORGEXP := _Super:normalizeType(B8N->B8N_ORGEXP,self:getValue("idIssuingBody")) /* Column B8N_ORGEXP */
        B8N->B8N_PAIS := _Super:normalizeType(B8N->B8N_PAIS,self:getValue("country")) /* Column B8N_PAIS */
        B8N->B8N_RAMAL := _Super:normalizeType(B8N->B8N_RAMAL,self:getValue("extension")) /* Column B8N_RAMAL */
        B8N->B8N_SIGLUF := _Super:normalizeType(B8N->B8N_SIGLUF,self:getValue("stateAcronym")) /* Column B8N_SIGLUF */
        B8N->B8N_TELEFO := _Super:normalizeType(B8N->B8N_TELEFO,self:getValue("telephoneNumber")) /* Column B8N_TELEFO */

        B8N->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
