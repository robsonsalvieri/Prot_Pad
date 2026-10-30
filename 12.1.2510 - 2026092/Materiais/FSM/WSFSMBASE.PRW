#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmBase
Métodos Rest do FSM
@author flavio.martins
@since 08/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL FSMBASE DESCRIPTION "WS de Integração Field Services Manager - Base de Atendimento" 

	WSDATA page                 AS INTEGER
	WSDATA pageSize             AS INTEGER
	WSDATA codigoCliente		AS STRING
	WSDATA lojaCliente			AS STRING
	WSDATA codigoBase       	AS STRING 
	WSDATA idUnico		      	AS STRING 
	
	// Métodos GET
    WSMETHOD GET historicoLocal DESCRIPTION 'Historico de locais da base de atendimento' PATH "historicoLocal" 	PRODUCES APPLICATION_JSON
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 08/05/2026
@Retorna historico de locais da base de atendimento
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET historicoLocal WSRECEIVE codigoCliente, lojaCliente, codigoBase, idUnico WSREST FSMBASE

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nItems    := 0

Default Self:page     		:= 1
Default Self:pageSize 		:= 10
Default Self:codigoCliente 	:= ''
Default Self:lojaCliente 	:= ''
Default Self:codigoBase 	:= ''
Default Self:idUnico 		:= ''

cQuery += " SELECT "
cQuery += "   JOL.JOL_CODIGO, "
cQuery += "   JOL.JOL_DESCRI, "
cQuery += "   JOP.JOP_DTINST, "
cQuery += "   JOP.JOP_DTDINS, "
cQuery += "   JOP.JOP_STATUS "
cQuery += " FROM " + RetSqlName('JOP') + " JOP "
cQuery += "   INNER JOIN " + RetSqlName('JOL') + " JOL ON JOL.JOL_FILIAL = ? "
cQuery += "   AND JOL.JOL_CODIGO = JOP.JOP_CODJOL "
cQuery += "   AND JOL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   JOP_FILIAL = ? "
cQuery += "   AND JOP_CLIENT = ? "
cQuery += "   AND JOP_LOJA = ? "
cQuery += "   AND JOP_CODPRO = ? "
cQuery += "   AND JOP_NUMSER = ? "
cQuery += "   AND JOP.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY JOP.JOP_CODIGO "
cQuery += "  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JOL"))
oQryTmp:SetString(2, xFilial("JOP"))
oQryTmp:SetString(3, Self:codigoCliente)
oQryTmp:SetString(4, Self:lojaCliente)
oQryTmp:SetString(5, Self:codigoBase)
oQryTmp:SetString(6, Self:idUnico)
oQryTmp:SetNumeric(7, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(8, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nItems]['codigoLocal'] 	        := AllTrim((cAliasTmp)->JOL_CODIGO)
	oResponse['items'][nItems]['descricaoLocal'] 	    := AllTrim((cAliasTmp)->JOL_DESCRI)
	oResponse['items'][nItems]['dataInstalacao']  	    := AllTrim((cAliasTmp)->JOP_DTINST)
	oResponse['items'][nItems]['dataDesinstalacao']  	:= AllTrim((cAliasTmp)->JOP_DTDINS)
	oResponse['items'][nItems]['status']  	            := AllTrim((cAliasTmp)->JOP_STATUS)
	
	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nItems >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 
