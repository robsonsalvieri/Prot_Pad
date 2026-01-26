#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSB4EDao from CenDao

    Method New(aFields) Constructor
    Method bscUtiliz(cCodRda,cProtoc)
    Method hasNext(nRecno)
    Method getFiltCus()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method New(aFields) Class PLSB4EDao
	_Super:New(aFields)
    self:cfieldOrder := "B4E_SEQUEN"
    self:cAlias      := "B4EQRY"    
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUtiliz
    Query que retorna todos os customers

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method bscUtiliz(cCodRda,cProtoc,cStatus) Class PLSB4EDao

local cQuery  := ""

cQuery += self:getRowControl()
cQuery += " B4E_SEQUEN, B4E_DATPRO, B4E_CODPAD, B4E_CODPRO, B4E_DESPRO, B4E_VLRREC, B4E_VLRACA, B4E.R_E_C_N_O_ RecnoB4E, "
cQuery += " B4E_STATUS STATUS, B4E_OPEMOV, B4E_CODLDP, B4E_CODPEG, B4E_NUMAUT, B4E_ORIMOV "
cQuery += " FROM " + RetSqlName('B4D') + " B4D " 
cQuery += " INNER JOIN " + RetSqlName('B4E') + " B4E " 
cQuery += " ON  B4E_FILIAL = '" + xFilial('B4E') + "' "
cQuery += " AND B4E_SEQB4D = B4D_SEQB4D "
cQuery += " AND B4E.D_E_L_E_T_ = ' ' "
cQuery += " WHERE B4D_FILIAL = '" + xFilial('B4D') + "' "
cQuery += " AND B4D_PROTOC = '" + cProtoc + "' "
cQuery += " AND B4D_CODRDA = '" + cCodRda + "' "
cQuery += " AND B4D.D_E_L_E_T_ = ' ' "

if !empty(cStatus)	
    cQuery += " AND B4E_STATUS IN (" + strtran("'"+cStatus+"'",",","','") + ") "	
endif

cQuery += self:getWhereRow()

self:setQuery(self:queryBuilder(cQuery))
lFound := self:executaQuery()

return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasNext
    hasNext especifico

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method hasNext(nRecno) Class PLSB4EDao
    Local lTemProx := .F.
    If self:aliasSelected()
        lTemProx := !(self:getAliasTemp())->(Eof())
    EndIf
return lTemProx

