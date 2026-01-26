#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmApi
Métodos Rest do FSM
@author flavio.martins
@since 13/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMCAD DESCRIPTION "WS de Integração Field Services Manager" 

	WSDATA page                 AS INTEGER
	WSDATA pageSize             AS INTEGER
	WSDATA codigoBase       	AS STRING 
	WSDATA idUnico		      	AS STRING 
	WSDATA codigoProduto      	AS STRING 
	WSDATA codigoTabela      	AS STRING 
	WSDATA filter		      	AS STRING 
	WSDATA codigoCliente		AS STRING
	WSDATA lojaCliente			AS STRING
	WSDATA quantidade			AS INTEGER
	WSDATA dataVigencia         AS STRING

	// Métodos GET
	WSMETHOD GET historicoTransferencia DESCRIPTION 'Historico de transferências da base de atendimento' PATH "historicoTransferencia" 	PRODUCES APPLICATION_JSON	
	WSMETHOD GET tabelaPreco  DESCRIPTION 'Tabelas de preço do produto'									 PATH "tabelaPreco"  			PRODUCES APPLICATION_JSON	
	WSMETHOD GET precoProduto  DESCRIPTION 'Retorna o preço do produto da tabela de preços'				 PATH "precoProduto"  			PRODUCES APPLICATION_JSON	

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 15/10/2024
@Retorna ordem servico da base de atendimento
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET historicoTransferencia WSRECEIVE codigoBase, idUnico WSREST FSMCAD

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nItems    := 0

Default Self:page     		:= 1
Default Self:pageSize 		:= 10
Default Self:codigoBase 	:= ''
Default Self:idUnico 		:= ''

cQuery := " SELECT "
cQuery += "   JO9_CODIGO," 
cQuery += "   JO9_CLIANT, "
cQuery += "   JO9_LOJANT, "
cQuery += "   JO9_DTTRAN, "
cQuery += "   JO9_HRTRAN, "
cQuery += "   SA1.A1_NOME, "
cQuery += "   SA1.A1_NREDUZ FROM " + RetSqlName('JO9') + " JO9 "
cQuery += "   LEFT JOIN " + RetSqlName('SA1') + " SA1 ON SA1.A1_FILIAL = ? " 
cQuery += "   AND SA1.A1_COD = JO9.JO9_CLIANT "
cQuery += "   AND SA1.A1_LOJA = JO9.JO9_LOJANT "
cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   JO9.JO9_FILIAL = ? "
cQuery += "   AND JO9.JO9_CODPRO = ? "
cQuery += "   AND JO9.JO9_NUMSER = ? "
cQuery += "   AND JO9.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY JO9.JO9_CODIGO "
cQuery += "  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("SA1"))
oQryTmp:SetString(2, xFilial("JO9"))
oQryTmp:SetString(3, Self:codigoBase)
oQryTmp:SetString(4, Self:idUnico)
oQryTmp:SetNumeric(5, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(6, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nItems]['codigoHistorico'] 	:= AllTrim((cAliasTmp)->JO9_CODIGO)
	oResponse['items'][nItems]['clienteAnterior'] 	:= AllTrim((cAliasTmp)->JO9_CLIANT)
	oResponse['items'][nItems]['lojaAnterior']  	:= AllTrim((cAliasTmp)->JO9_LOJANT)
	oResponse['items'][nItems]['nomeFantasia']  	:= AllTrim((cAliasTmp)->A1_NREDUZ)
	oResponse['items'][nItems]['razaoSocial'] 	    := AllTrim((cAliasTmp)->A1_NOME)
	oResponse['items'][nItems]['dataTransferencia'] := AllTrim((cAliasTmp)->JO9_DTTRAN)
	oResponse['items'][nItems]['horaTransferencia'] := AllTrim((cAliasTmp)->JO9_HRTRAN)
	
	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nItems >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 21/07/2025
@Retorna as tabelas de preços do produto
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET tabelaPreco WSRECEIVE codigoProduto, filter WSREST FSMCAD

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nItems    := 0

Default Self:page     		:= 1
Default Self:pageSize 		:= 10
Default Self:codigoProduto	:= ''
Default Self:codigoTabela	:= ''
Default Self:filter			:= ''

cQuery += " SELECT DISTINCT "
cQuery += "   DA0.DA0_CODTAB, "
cQuery += "   DA0.DA0_DESCRI, "
cQuery += "   DA0.DA0_DATDE, "
cQuery += "   DA0.DA0_DATATE, "
cQuery += "   DA0.DA0_ATIVO "
cQuery += " FROM " + RetSqlName('DA0') + " DA0 "
cQuery += "   INNER JOIN " + RetSqlName('DA1') + " DA1 ON DA1.DA1_FILIAL = ? "
cQuery += "   AND DA1.DA1_CODTAB = DA0.DA0_CODTAB "
cQuery += "   AND DA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   DA0.DA0_FILIAL = ? "
cQuery += "   AND DA0.D_E_L_E_T_ = ' ' "
cQuery += "   AND (DA0.DA0_CODTAB LIKE ? OR DA0.DA0_DESCRI LIKE ?) "

If !Empty(Self:codigoTabela) 
	cQuery += " AND DA0.DA0_CODTAB = ?
Else 
	cQuery += " AND DA1.DA1_CODPRO = ?
Endif 

cQuery += " ORDER BY DA0.DA0_CODTAB "
cQuery += "  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("DA1"))
oQryTmp:SetString(2, xFilial("DA0"))
oQryTmp:SetString(3, '%'+Self:filter+'%')
oQryTmp:SetString(4, '%'+Self:filter+'%')

If !Empty(Self:codigoTabela) 
	oQryTmp:SetString(5, Self:codigoTabela)
Else 
	oQryTmp:SetString(5, Self:codigoProduto)
Endif 

oQryTmp:SetNumeric(6, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(7, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nItems]['codigo'] 		:= AllTrim((cAliasTmp)->DA0_CODTAB)
	oResponse['items'][nItems]['descricao'] 	:= AllTrim((cAliasTmp)->DA0_DESCRI)
	oResponse['items'][nItems]['dataInicial']	:= AllTrim((cAliasTmp)->DA0_DATDE)
	oResponse['items'][nItems]['dataFinal']  	:= AllTrim((cAliasTmp)->DA0_DATATE)
	oResponse['items'][nItems]['status']  		:= AllTrim((cAliasTmp)->DA0_ATIVO)
	
	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nItems >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 23/07/2025
@Retorna as tabelas de preços do produto
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET precoProduto WSRECEIVE codigoProduto, filter WSREST FSMCAD

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local nValor    := 0

Default Self:codigoProduto		:= ''
Default Self:codigoTabela		:= ''
Default Self:codigoCliente		:= ''
Default Self:lojaCliente		:= ''
Default Self:quantidade			:= 1

If Self:dataVigencia == Nil 
	Self:dataVigencia := dDataBase
Else
	Self:dataVigencia := StoD(Self:dataVigencia)
Endif

nValor := MaTabPrVen(Padr(Self:codigoTabela,TAMSX3("DA0_CODTAB")[1]),;
					 Padr(Self:codigoProduto,TAMSX3("B1_COD")[1]),;
					 Self:quantidade, Self:codigoCliente,Self:lojaCliente,,;
					 Self:dataVigencia)

oResponse['codigoTabela']  := Self:codigoTabela
oResponse['codigoProduto'] := Self:codigoProduto
oResponse['precoProduto']  := nValor

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet 

