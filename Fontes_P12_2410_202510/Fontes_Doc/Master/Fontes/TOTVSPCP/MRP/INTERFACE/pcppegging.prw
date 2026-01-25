#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPPEGGING.CH"
#INCLUDE "restful.ch"
#INCLUDE "fwcommand.ch"

Static _oCacheFil := JsonObject():New()

/*/{Protheus.doc} PCPPegging
Chamada da tela de Rastreabilidade de Demandas (dash-rastreabilidade PO-UI).

@type  Function
@author parffit.silva
@since 03/05/2021
@version P12.1.33
@param  Nil
@return Nil
/*/
Function PCPPegging()

	If !AliasInDic("SMH")
		Help( ,, 'PCPPegging',, STR0001, 1, 0 ) //"Tabela SMH não foi encontrada no dicionário de dados! "
		Return
	EndIf

	If PCPVldApp() .And. VldMultEmp()
		FwCallApp('pcppegging')
	EndIf
Return

/*/{Protheus.doc} pcppegging
API para montagem das colunas da table list da rastrebalidade.

@type  WSCLASS
@author mauricio.joao
@since 02/02/2023
@version 12.1.2210
/*/

WSRESTFUL pcppegging DESCRIPTION STR0002 FORMAT APPLICATION_JSON
	WSDATA parentCode AS string

	WSMETHOD GET ColumnsOrder;
		DESCRIPTION STR0002;
		WSSYNTAX "api/pcp/v1/pcppegging/columns/orders" ;
		PATH "api/pcp/v1/pcppegging/columns/orders" ;
		TTALK "v1"

END WSRESTFUL

WSMETHOD GET ColumnsOrder WSRECEIVE parentCode WSSERVICE pcppegging
	Local cJson     := ""
	Local lMrpMulti := isMRPMulti(self:parentCode)
	Local oJsonRet  := JsonObject():New()

	// define o tipo de retorno do método
	::SetContentType("application/json")

	oJsonRet["mrpMulti"] := lMrpMulti
	oJsonRet["usaOpc"] := OPComOpc()

	cJson := EncodeUTF8(oJsonRet:toJson())
	::SetResponse(cJson)

Return .T.

/*/{Protheus.doc} isMRPMulti
Verifica se a empresa é processada por mrp multi empresa.

@type  Static Function
@author mauricio.joao
@since 16/01/2023
@version 1.0
@param parentCode, string, código da empresa
@return lMrpMulti, logical, Retorna se a empresa é processada por mrp multi empresa.
/*/
Static Function isMRPMulti(parentCode)
	Local aArrFil   := FWArrFilAtu(cEmpAnt, parentCode)
	Local cAliasQry := GetNextAlias()
	Local cBranch   := ''
	Local cCompany  := ''
	Local cGroup    := ''
	Local cQuery    := ''
	Local cUnit     := ''
	Local lMrpMulti := .F.

	If Len(aArrFil) > 0
		cBranch  := aArrFil[SM0_FILIAL]
		cCompany := aArrFil[SM0_EMPRESA]
		cGroup   := aArrFil[SM0_GRPEMP]
		cUnit    := aArrFil[SM0_UNIDNEG]

		cQuery := "SELECT COUNT(1) ISMRPMULTI"
		cQuery += " FROM "+RetSqlName("SOP")+" SOP "
		cQuery += " WHERE SOP.D_E_L_E_T_ = ' ' "
		cQuery += " AND ((SOP.OP_CDEPCZ = '"+cGroup+"' AND SOP.OP_EMPRCZ = '"+cCompany+"' AND SOP.OP_UNIDCZ  = '"+cUnit+"' AND SOP.OP_CDESCZ  = '"+cBranch+"')"
		cQuery += " OR (SOP.OP_CDEPGR = '"+cGroup+"' AND SOP.OP_EMPRGR = '"+cCompany+"' AND SOP.OP_UNIDGR  = '"+cUnit+"' AND SOP.OP_CDESGR  = '"+cBranch+"'))"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

		If (cAliasQry)->(ISMRPMULTI) > 0
			lMrpMulti := .T.
		EndIf

		(cAliasQry)->(DbCloseArea())
		aSize(aArrFil,0)
	EndIf

Return lMrpMulti

/*/{Protheus.doc} OPComOpc
Verifica se existem ordens de produção com opcionais na tabela de rastreabilidade (SMH)

@type  Static Function
@author lucas.franca
@since 21/03/2023
@version P12
@return lRet, Logic, Retorna se existem OPs com opcionais na rastreabilidade
/*/
Static Function OPComOpc()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cBanco := TcGetDb()
	Local lRet   := .F.

	cQuery := " SELECT COUNT(*) TEMOPC"
	cQuery +=   " FROM " + RetSqlName("SMH") + " SMH"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=     " ON SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	If cBanco == "POSTGRES"
		cQuery += " AND TRIM(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) = SMH.MH_NMDCENT"
	Else
		cQuery += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMH.MH_NMDCENT"
	EndIf
	cQuery +=    " AND SC2.C2_OPC <> ' '"
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMH.MH_FILIAL = '" + xFilial("SMH") + "' "
	cQuery +=    " AND SMH.MH_TPDCENT = '1'"
	cQuery +=    " AND SMH.MH_NMDCENT <> ' '"
	cQuery +=    " AND SMH.D_E_L_E_T_ = ' '"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	If (cAlias)->(TEMOPC) > 0
		lRet := .T.
	EndIf
	(cAlias)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} VldMultEmp
Valida se é permitido executar a rotina na filial atual de acordo com as configurações de multi-empresas.

@type  Static Function
@author lucas.franca
@since 11/09/2023
@version P12
@return lPermite, Logic, Indica se permite iniciar a rotina
/*/
Static Function VldMultEmp()
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local cFilCent   := ""
	Local lPermite   := .T.
	Local nTamOPGE   := GetSx3Cache("OP_CDEPGR", "X3_TAMANHO")
	Local nTamOPEmp  := GetSx3Cache("OP_EMPRGR", "X3_TAMANHO")
	Local nTamOPUnid := GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")
	Local nTamOPFil  := GetSx3Cache("OP_CDESGR", "X3_TAMANHO")

	cGrupo := PadR(cGrupo, nTamOPGE)
	cEmp   := PadR(cEmp  , nTamOPEmp)
	cUnid  := PadR(cUnid , nTamOPUnid)
	cFil   := PadR(cFil  , nTamOPFil)

	SOP->(dbSetOrder(4))
	If SOP->(dbSeek(xFilial("SOP")+cGrupo+cEmp+cUnid+cFil))
		lPermite := .F.
		cFilCent := PadR(SOP->OP_EMPRCZ, Len(FWCompany())) + PadR(SOP->OP_UNIDCZ, Len(FWUnitBusiness())) + PadR(SOP->OP_CDESCZ, Len(FwFilial()))

		Help(,,'Help',, I18N(STR0126, {AllTrim(cFilAnt)}),; //"Filial '#1[FILIAL]#' está configurada como Filial Centralizada. Execução não permitida."
			1,0,,,,,,{I18N(STR0127, {AllTrim(cFilCent)})}) //"Para consultar as informações de rastreabilidade do MRP Multi-empresas, a execução deve ser realizada em uma filial centralizadora. Execute a rastreabilidade de demandas na filial '#1[FILIAL]#'."
	EndIf

Return lPermite

/*/{Protheus.doc} PCPRasFili
Monta o filtro de filiais considerando os dados de multi-empresas.

@type  Static Function
@author lucas.franca
@since 12/09/2023
@version P12
@param 01 cCampo , Caracter, Campo (com alias) para fazer a condição de filtro de filial
@param 02 cTabela, Caracter, Tabela utilizada para adicionar o filtro de filial
@param 03 cBranch, Caracter, Filial utilizada com filtro de dados.
@return cFilter, Caracter, Condição SQL para o filtro de filiais
/*/
Function PCPRasFili(cCampo, cTabela, cBranch)
	Local cFilter := " " + cCampo
	Local nIndex  := 0

	If _oCacheFil:hasProperty(cFilAnt) == .F.
		_oCacheFil[cFilAnt]               := JsonObject():New()
		_oCacheFil[cFilAnt]["filiais"]    := A712FilME(.T.)
		_oCacheFil[cFilAnt]["qtdFiliais"] := Len(_oCacheFil[cFilAnt]["filiais"])
	EndIf

	If !Empty(cBranch) .Or. _oCacheFil[cFilAnt]["qtdFiliais"] <= 1

		If Empty(cBranch)
			//Se não é multi-empresa cBranch estará vazio, então filtra pela filial corrente.
			cBranch := cFilAnt
		EndIf

		//Multi-empresa com filtro de filial ou sem multi-empresa, sempre filtra por uma filial específica.
		cFilter += " = '" + xFilial(cTabela, cBranch) + "' "
	Else
		//Utiliza multi-empresa e não possui filtro de filial,
		//adiciona todas as filiais do ME com a condição IN para filtro na query
		cFilter += " IN ("
		For nIndex := 1 To _oCacheFil[cFilAnt]["qtdFiliais"]
			If nIndex > 1
				cFilter += ","
			EndIf
			cFilter += "'" + xFilial(cTabela, _oCacheFil[cFilAnt]["filiais"][nIndex][1]) + "'"
		Next nIndex
		cFilter += ") "
	EndIf
Return cFilter

