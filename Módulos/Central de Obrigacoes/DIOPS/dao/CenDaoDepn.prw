#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoDepn from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoDepn
	_Super:New(aFields)
    self:cAlias := "B8Z"
    self:cfieldOrder := "B8Z_CODOPE,B8Z_CNPJ"
Return self

Method buscar() Class CenDaoDepn
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8Z->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoDepn
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoDepn

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8Z') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8Z_FILIAL = '" + xFilial("B8Z") + "' "

    cQuery += " AND B8Z_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8Z_CNPJ = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("legalEntityNatRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoDepn
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoDepn

    Default lInclui := .F.

	If B8Z->(RecLock("B8Z",lInclui))
		
        B8Z->B8Z_FILIAL := xFilial("B8Z")
        If lInclui
        
            B8Z->B8Z_CODOPE := _Super:normalizeType(B8Z->B8Z_CODOPE,self:getValue("providerRegister")) /* Column B8Z_CODOPE */
            B8Z->B8Z_CNPJ := _Super:normalizeType(B8Z->B8Z_CNPJ,self:getValue("legalEntityNatRegister")) /* Column B8Z_CNPJ */

        EndIf

        B8Z->B8Z_CODCEP := _Super:normalizeType(B8Z->B8Z_CODCEP,self:getValue("postAddrCode")) /* Column B8Z_CODCEP */
        B8Z->B8Z_CODDDD := _Super:normalizeType(B8Z->B8Z_CODDDD,self:getValue("longDistanceCode")) /* Column B8Z_CODDDD */
        B8Z->B8Z_CODDDI := _Super:normalizeType(B8Z->B8Z_CODDDI,self:getValue("internationalCallinfCd")) /* Column B8Z_CODDDI */
        B8Z->B8Z_BAIRRO := _Super:normalizeType(B8Z->B8Z_BAIRRO,self:getValue("district")) /* Column B8Z_BAIRRO */
        B8Z->B8Z_CDIBGE := _Super:normalizeType(B8Z->B8Z_CDIBGE,self:getValue("ibgeCityCode")) /* Column B8Z_CDIBGE */
        B8Z->B8Z_COMDEP := _Super:normalizeType(B8Z->B8Z_COMDEP,self:getValue("addressComplement")) /* Column B8Z_COMDEP */
        B8Z->B8Z_EMAIL := _Super:normalizeType(B8Z->B8Z_EMAIL,self:getValue("eMail")) /* Column B8Z_EMAIL */
        B8Z->B8Z_NMLOGR := _Super:normalizeType(B8Z->B8Z_NMLOGR,self:getValue("addressName")) /* Column B8Z_NMLOGR */
        B8Z->B8Z_NOMRAZ := _Super:normalizeType(B8Z->B8Z_NOMRAZ,self:getValue("corporateName")) /* Column B8Z_NOMRAZ */
        B8Z->B8Z_NUMLOG := _Super:normalizeType(B8Z->B8Z_NUMLOG,self:getValue("addressNumber")) /* Column B8Z_NUMLOG */
        B8Z->B8Z_RAMAL := _Super:normalizeType(B8Z->B8Z_RAMAL,self:getValue("extensionLine")) /* Column B8Z_RAMAL */
        B8Z->B8Z_SIGLUF := _Super:normalizeType(B8Z->B8Z_SIGLUF,self:getValue("stateAcronym")) /* Column B8Z_SIGLUF */
        B8Z->B8Z_TELEFO := _Super:normalizeType(B8Z->B8Z_TELEFO,self:getValue("telephoneNumber")) /* Column B8Z_TELEFO */
        B8Z->B8Z_TIPODE := _Super:normalizeType(B8Z->B8Z_TIPODE,self:getValue("dependenceType")) /* Column B8Z_TIPODE */

        B8Z->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
