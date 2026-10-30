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
    B4D->(dbsetorder(1))
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} bscUtiliz
Query que retorna todos os recursos de glosa

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
Method bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc) Class PLSB4DDao
    local cQuery      := ""
    local lB4D_DATANA := B4D->(fieldpos("B4D_DATANA")) > 0
    local cDB         := upper(TCGetDb()) 
    local lFound      := .F.

    self:cfieldOrder := "B4D_DATSOL DESC"

    cQuery += self:getRowControl()
    
    cQuery += " B4D_PROTOC, B4D_CODPEG, B4D_NUMAUT, B4D_DATSOL, B4D_SEQB4D, B4D_DCDPEG, "
    cQuery += "   (CASE WHEN B4D_OBJREC = '1' THEN 'Protocolo' WHEN B4D_OBJREC = '2' THEN 'Guia' WHEN B4D_OBJREC = '3' THEN 'Itens' ELSE '' END) OBJREC, "
    cQuery += "   B4D_STATUS STATUS, R_E_C_N_O_ RecnoB4D,"
    cQuery += "   (CASE WHEN B4D_ORIENT = '2' THEN 'Via Portal' WHEN B4D_ORIENT = '4' THEN 'Via XML' "
    cQuery += "         WHEN B4D_ORIENT = '3'  THEN 'Via Webservice' ELSE 'Via Operadora' END) ORIGEM, "
    
    If "ORACLE" $ cDB
        cQuery += " B4D_OPEMOV || B4D_CODLDP || B4D_CODPEG || B4D_NUMAUT || LPAD(LTRIM(TO_CHAR(B4D_QTDIRP)), 15, ' ') AS CHAVE, "
    ElseIf "POSTGRES" $ cDB
        cQuery += " B4D_OPEMOV || B4D_CODLDP || B4D_CODPEG || B4D_NUMAUT || LPAD(TRIM(CAST(B4D_QTDIRP AS VARCHAR)), 15, ' ') AS CHAVE, "
    Else 
        cQuery += " B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT+right(rtrim(replicate(' ',15)+cast(B4D_QTDIRP as varchar)),15) CHAVE, "
    EndIf
    
    cQuery += iif(lB4D_DATANA," B4D_DATANA "," '' AS B4D_DATANA ")
    
    cQuery += " , BXX_PLSHAT, BXX_CODREG "

    cQuery += " FROM ( "

    cQuery += "   SELECT B4D_PROTOC, "
    cQuery += "          B4D_CODPEG, "
    cQuery += "          B4D_DATSOL, "
    cQuery += "          B4D_NUMAUT, "
    cQuery += "          B4D_SEQB4D, "
    cQuery += "          B4D_OBJREC, "
    cQuery += "          B4D_DCDPEG, "
    cQuery += "          CASE WHEN (BXX_STATUS = '6') THEN 'C' ELSE B4D_STATUS END AS B4D_STATUS, "
    cQuery += "          B4D.R_E_C_N_O_ AS R_E_C_N_O_, B4D_ORIENT, B4D_OPEMOV, B4D_CODLDP, B4D_QTDIRP, "
    cQuery +=            iif(lB4D_DATANA, " B4D_DATANA, ", " '' AS B4D_DATANA, ")
    cQuery += "          BXX_PLSHAT, BXX.BXX_CODREG, B4D.D_E_L_E_T_ AS D_E_L_E_T_ "
    cQuery += "   FROM " + RetSqlName('B4D') + " B4D "
    cQuery += "   LEFT JOIN " + RetSqlName('BXX') + " BXX ON BXX_FILIAL = '" + xFilial('BXX') + "' "
    cQuery += "     AND BXX_CODINT = B4D_OPEMOV "
    cQuery += "     AND BXX_PROGLO = B4D_CODPEG "
    cQuery += "     AND BXX.D_E_L_E_T_ = ' ' "
    cQuery += "   WHERE B4D_FILIAL = '" + xFilial('B4D') + "' "
    cQuery += "     AND B4D_OPEMOV = '" + plsintpad() + "' "
    cQuery += "     AND B4D_CODRDA = '" + cCodRda + "' "
    cQuery += "     AND B4D.D_E_L_E_T_ = ' ' " 

    cQuery += " UNION ALL "

    cQuery += "   SELECT BXX_PROGLO AS B4D_PROTOC, "
    cQuery += "          BXX_CODPEG AS B4D_CODPEG, "
    cQuery += "          BXX_DATMOV AS B4D_DATSOL, "
    cQuery += "          '' AS B4D_NUMAUT, "
    cQuery += "          '' AS B4D_SEQB4D, "
    cQuery += "          '' AS B4D_OBJREC, " 
    cQuery += "          '' AS B4D_DCDPEG, " 
    cQuery += "          CASE WHEN (BXX_STATUS = '6') THEN 'C' ELSE BXX_STATUS END AS B4D_STATUS, "
    cQuery += "          0 AS R_E_C_N_O_, '4' AS B4D_ORIENT, BXX_CODINT AS B4D_OPEMOV, '    ' AS B4D_CODLDP, 0 AS B4D_QTDIRP, " 
    cQuery += "          '' AS B4D_DATANA, BXX_PLSHAT, BXX_CODREG, BXX.D_E_L_E_T_ AS D_E_L_E_T_ "
    cQuery += "   FROM " + RetSqlName('BXX') + " BXX "
    cQuery += "   WHERE BXX_FILIAL = '" + xFilial('BXX') + "' "
    cQuery += "     AND (BXX_PROGLO IS NULL OR RTRIM(BXX_PROGLO) = '') " 
    cQuery += "     AND BXX_CODINT = '" + plsintpad() + "' "
    cQuery += "     AND BXX_CODRDA = '" + cCodRda + "' "
    cQuery += "     AND BXX_TIPGUI = '10' "
    cQuery += "     AND BXX.D_E_L_E_T_ = ' ' "    

    cQuery += " ) BASE_UNIFICADA "
    cQuery += " WHERE 1=1 "

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
