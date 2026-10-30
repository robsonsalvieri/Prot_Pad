#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMMAP
Métodos Rest do FSM
@author flavio.martins
@since 03/08/2026
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMMAP DESCRIPTION "WS de Integração Field Services Manager" 

	WSDATA codigoLocal	AS STRING 

	// Métodos GET
	WSMETHOD GET mapaLocal  DESCRIPTION 'Mapa dos locais de atendimento' PATH "mapaLocal" PRODUCES APPLICATION_JSON	

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 03/08/2026
@Retorna o mapa dos locais de atendimento
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET mapaLocal WSRECEIVE WSREST FSMMAP

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nItems    := 0
Local cCodLocal := Padr(Self:codigoLocal, TamSx3("JOL_CODIGO")[1])
Local cBanco    := AllTrim(TcGetDB()) 

If Empty(cCodLocal)
	SetRestFault(404, EncodeUtf8("Código do local não informado"))
	Return .F.
Endif

cQuery := " WITH "

If cBanco $ 'POSTGRES'
	cQuery += " RECURSIVE "
Endif

cQuery += " MAPA (JOL_FILIAL,JOL_CODIGO, JOL_CODSUP, JOL_DESCRI, NIVEL) AS ( "
cQuery += "    SELECT "
cQuery += "        JOL_FILIAL, "
cQuery += "        JOL_CODIGO, "
cQuery += "        JOL_CODSUP, "
cQuery += "		JOL_DESCRI, "
cQuery += "        1 AS NIVEL "
cQuery += "    FROM " + RetSqlName('JOL') + " "
cQuery += "    WHERE JOL_FILIAL = ? "
cQuery += "    AND JOL_CODIGO = ? "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery += "    UNION ALL "
cQuery += "    SELECT "
cQuery += "        sublocal.JOL_FILIAL, "
cQuery += "        sublocal.JOL_CODIGO, "
cQuery += "        sublocal.JOL_CODSUP, "
cQuery += "		   sublocal.JOL_DESCRI, "
cQuery += "        principal.NIVEL + 1 AS NIVEL "
cQuery += "    FROM " + RetSqlName('JOL') + " sublocal "
cQuery += "    INNER JOIN MAPA principal "
cQuery += "        ON sublocal.JOL_FILIAL = principal.JOL_FILIAL "
cQuery += "        AND sublocal.JOL_CODSUP = principal.JOL_CODIGO "
cQuery += "        AND sublocal.D_E_L_E_T_ = ' ') "
cQuery += " SELECT * FROM MAPA "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JOL"))
oQryTmp:SetString(2, Self:codigoLocal)

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nItems]['codigoLocal'] 	    := AllTrim((cAliasTmp)->JOL_CODIGO)
	oResponse['items'][nItems]['codigoSuperior']    := AllTrim((cAliasTmp)->JOL_CODSUP)
	oResponse['items'][nItems]['descricao']  	    := AllTrim((cAliasTmp)->JOL_DESCRI)
	oResponse['items'][nItems]['nivel']  	        := AllTrim(Str((cAliasTmp)->NIVEL))
	oResponse['items'][nItems]['pk']                := Encode64((cAliasTmp)->JOL_FILIAL + (cAliasTmp)->JOL_CODIGO)
	
	(cAliasTmp)->(dbSkip())

EndDo

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 
