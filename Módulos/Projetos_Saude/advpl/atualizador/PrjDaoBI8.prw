#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PrjDaoBI8 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method getAtuAuto()
    Method commit(lInclui)
    
EndClass

Method New(aFields) Class PrjDaoBI8
	_Super:New(aFields)
    self:cAlias := "BI8"
    self:cfieldOrder := "BI8_CODIGO,BI8_NOME,BI8_STATUS,BI8_ULTVER,BI8_VERLOC,BI8_ATUAUT"
Return self

Method buscar() Class PrjDaoBI8
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BI8->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PrjDaoBI8
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PrjDaoBI8

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI8') + " "
	cQuery += " WHERE BI8_FILIAL = '" + xFilial("BI8") + "' "


    cQuery += " AND BI8_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI8_CODIGO")))
    
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method getAtuAuto() Class PrjDaoBI8

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI8') + " "
	cQuery += " WHERE BI8_FILIAL = '" + xFilial("BI8") + "' "
    cQuery += " AND BI8_ATUAUT = ? "
    aAdd(self:aMapBuilder, '1')
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class PrjDaoBI8

    Default lInclui := .F.

	If BI8->(RecLock("BI8",lInclui))
		
        BI8->BI8_FILIAL := xFilial("BI8")
        If lInclui
            BI8->BI8_CODIGO := _Super:normalizeType(BI8->BI8_CODIGO,self:getValue("BI8_CODIGO"))
            BI8->BI8_NOME   := _Super:normalizeType(BI8->BI8_NOME,self:getValue("BI8_NOME"))
            BI8->BI8_STATUS := _Super:normalizeType(BI8->BI8_STATUS,self:getValue("BI8_STATUS"))
            BI8->BI8_ULTVER := _Super:normalizeType(BI8->BI8_ULTVER,self:getValue("BI8_ULTVER"))
            BI8->BI8_ATUAUT := _Super:normalizeType(BI8->BI8_ATUAUT,self:getValue("BI8_ATUAUT"))
            BI8->BI8_STATAU := _Super:normalizeType(BI8->BI8_STATAU,self:getValue("BI8_STATAU"))         
        Else
            BI8->BI8_NOME := _Super:normalizeType(BI8->BI8_NOME,self:getValue("BI8_NOME"))
            BI8->BI8_STATUS := _Super:normalizeType(BI8->BI8_STATUS,self:getValue("BI8_STATUS"))
            BI8->BI8_ULTVER := _Super:normalizeType(BI8->BI8_ULTVER,self:getValue("BI8_ULTVER"))
            BI8->BI8_VERLOC := _Super:normalizeType(BI8->BI8_VERLOC,self:getValue("BI8_VERLOC"))
            BI8->BI8_ATUAUT := _Super:normalizeType(BI8->BI8_ATUAUT,self:getValue("BI8_ATUAUT"))
            BI8->BI8_DESERR := _Super:normalizeType(BI8->BI8_DESERR,self:getValue("BI8_DESERR"))
            BI8->BI8_STATAU := _Super:normalizeType(BI8->BI8_STATAU,self:getValue("BI8_STATAU"))       
            BI8->BI8_DATA   := _Super:normalizeType(BI8->BI8_DATA,self:getValue("BI8_DATA"))
            BI8->BI8_HORA   := _Super:normalizeType(BI8->BI8_HORA,self:getValue("BI8_HORA"))
        EndIf

        BI8->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound