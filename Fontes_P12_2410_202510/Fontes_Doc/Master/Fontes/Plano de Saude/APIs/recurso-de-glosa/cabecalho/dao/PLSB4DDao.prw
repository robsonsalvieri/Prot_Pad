#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSB4DDao from CenDao

    Method New(aFields) Constructor
    Method bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc)
    Method hasNext(nRecno)
    Method loadOrder()
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
Method New(aFields) Class PLSB4DDao
	_Super:New(aFields)
    self:cfieldOrder := "B4D_PROTOC DESC"
    self:cAlias      := "B4DQRY"  
    self:loadOrder()    
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} bscUtiliz
Query que retorna todos os customers

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
Method bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc) Class PLSB4DDao

local cQuery  := ""

cQuery += self:getRowControl()
cQuery += " B4D_PROTOC, B4D_CODPEG, B4D_NUMAUT, B4D_DATSOL, B4D_SEQB4D, B4D_DCDPEG, "
cQuery += "   (CASE WHEN B4D_OBJREC = '1' THEN 'Protocolo' WHEN B4D_OBJREC = '2' THEN 'Guia' ELSE 'Itens' END) OBJREC, "
cQuery += "   B4D_STATUS STATUS, R_E_C_N_O_ RecnoB4D,"
cQuery += "   (CASE WHEN B4D_ORIENT = '2' THEN 'Via Portal' WHEN B4D_ORIENT = '4' THEN 'Via XML' "
cQuery += "         WHEN B4D_ORIENT = '3'  THEN 'Via Webservice' ELSE 'Via Operadora' END) ORIGEM, "
IIF("ORACLE" $ upper(TCGetDb()),;
    cQuery += " B4D_OPEMOV || B4D_CODLDP || B4D_CODPEG || B4D_NUMAUT || LPAD(LTRIM(TO_CHAR(B4D_QTDIRP)), 15, ' ') AS CHAVE ", ;
    cQuery += " B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT+right(rtrim(replicate(' ',15)+cast(B4D_QTDIRP as varchar)),15) CHAVE " ;
)
cQuery += " FROM " + RetSqlName('B4D') 
cQuery += " WHERE B4D_FILIAL = '" + xFilial('B4D') + "' "
cQuery += " AND B4D_OPEMOV = '" + plsintpad() + "' "
cQuery += " AND B4D_CODRDA = '" + cCodRda + "' "

if !empty(cPeriodDe)
    cQuery += " AND B4D_DATSOL >= '" + cPeriodDe + "' "
endif

if !empty(cPeriodAte)
    cQuery += " AND B4D_DATSOL <= '" + cPeriodAte + "' "	
endif

if !empty(cStatus)	
    cQuery += " AND B4D_STATUS IN (" + strtran("'"+cStatus+"'",",","','") + ") "	
endif

if !empty(cCodPeg)
    cQuery += " AND B4D_CODPEG = '" + strzero(val(cCodPeg),8) + "' "
endif

if !empty(cProtoc)
    cQuery += " AND B4D_PROTOC = '" + strzero(val(cProtoc),12) + "' "
endif

cQuery += " AND D_E_L_E_T_ = ' ' "

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
Method hasNext(nRecno) Class PLSB4DDao
    Local lTemProx := .F.
    If self:aliasSelected()
        lTemProx := !(self:getAliasTemp())->(Eof())
    EndIf
return lTemProx


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadOrder
    Adicona campos para ordenacao

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method loadOrder() Class PLSB4DDao

    self:oHashOrder:set("REQUESTDATE",          "B4D_DATSOL")

Return
