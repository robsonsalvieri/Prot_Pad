#include 'TOTVS.CH'
#include 'FWLIBVERSION.CH'
#include 'RESTFUL.CH'
#include 'FWADAPTEREAI.CH'
#include 'APWEBSRV.CH'
#include 'TBICONN.CH'
#include 'FILEIO.CH'
#include 'CONSIG006.CH'
#include 'FWMVCDEF.CH'

/*/{Protheus.doc} function CONSIG006
Sincronização de Contratos Totvs Consignado
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.0
/*/
main function CONSIG006() as logical
	local oContracts := JsonObject():New()
	Local nIndex
	Local cFilIC

	// Verifica a chave de ativação da integração TOTVS Consignado
	if !GetMv("MV_CONSIG", .F., .F.)
		Help( " ", 1, STR0004,, STR0005, 1 )  // STR0004: "Aviso Integração", STR0005: "Ative a chave do TOTVS Consignado."
		Return .F.
	endIf

	if fValidSincContracts()
		oContracts := fGetContractEmployeeLast60Days()

		if VALTYPE(oContracts) == "U"
			MsgStop(oEmToAnsi(STR0001)) // STR0001: "Erro: Falha na comunicação com o Totvs Consignado. Verifique a integração ou tente novamente mais tarde.
			Return .F.
		EndIf

		fClearRUF()

		if LEN(oContracts["items"]) != 0
			for nIndex := 1 to Len(oContracts["items"])
				oContract := oContracts["items"][nIndex]
				cFilIC := fBranchByCnpj(oContract["companyCNPJ"])
				fSetTmpContract(oContract, cFilIC)
			next nIndex
		else
			MsgInfo(oEmToAnsi(STR0002))// STR0002: "Não há novos contratos encontrado para sincronização."
		EndIf

		MsgInfo(oEmToAnsi(STR0003))// STR0003: "Sincronização de contratos concluída com sucesso"
	EndIf
return .T.


/*/{Protheus.doc} function CONSIG006
Consulta dos Contratos do Totvs Consignado
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.0
/*/
Static Function fGetContractEmployeeLast60Days()
	Local oInteg
	Local cRacToken := ""
	Local aHeader   := {}
	Local oContracts  := JsonObject():New()
	Local cEndPoint := fGetURLCsg()

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/employee-contracts")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oInteg:setPath("?")

	If oInteg:Get(aHeader)
		If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
			oContracts:FromJson(oInteg:GetResult())
		EndIf
	EndIf
Return oContracts


/*/{Protheus.doc} function CONSIG006
Limpa os registros na tabela RUF
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.0
/*/
static function fClearRUF() as array
	Local aArea:= GetArea()

	dbSelectArea("RUF")
	RUF->(dbSetOrder(1))

	While (!RUF->(EOF()))
		RecLock("RUF", .F.)
		RUF->(dbDelete())
		RUF->(MsUnlock())
		RUF->(dbSkip())
	EndDo

	RestArea(aArea)
return


/*/{Protheus.doc} function fSetTmpFields(oContracts)
Preenche as colunas da tabela temporária de contratos
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.0
/*/
Static Function fSetTmpContract(oContracts , cFilIC ) as array
	local aArea  := getArea() 		as array
	local cAlias := 'RUF' 			as character
	local aRet   := { .F. , '' } 	as array

	dbSelectArea( cAlias )

	recLock( cAlias , .T. )
	(cAlias)->RUF_CPF	:= oContracts['employeeCPF']
	(cAlias)->RUF_CNPJ	:= oContracts['companyCNPJ']
	(cAlias)->RUF_MAT	:= oContracts['employeeRegistration']
	(cAlias)->RUF_CCODE  := oContracts['contractCode']
	(cAlias)->RUF_IREM   := oContracts['installmentRemaining']
	(cAlias)->RUF_IDEBIT  := oContracts['totalDebit']
	(cAlias)->RUF_PCODE  := oContracts['partnerCode']
	(cAlias)->RUF_DTCOM := oContracts['contractDate']
	(cAlias)->RUF_INSTVL := oContracts['installmentValue']
	(cAlias)->RUF_FILIAL := cFilIC
	(cAlias)->( msUnLock() )
	(cAlias)->( dbCloseArea() )

	restArea( aArea )

	aRet := { .T. , STR0007 }
return aRet


/*/{Protheus.doc} function CONSIG006
Validação se deseja realizar a Sincronização dos Contratos.
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.0
/*/
static function fValidSincContracts() as logical
	if !msgYesNo(oEmToAnsi(STR0006)) //STR0006: 'Deseja realizar a sincronização de contratos do Totvs Consignado?'
		return .F.
	endIf
return .T.


/*/{Protheus.doc} function CONSIG006
Retorna a Filial por CNPJ
@author  Franklin Felipe de Castro
@since   18/10/2024
@version 1.1
/*/
static function fBranchByCnpj(cCnpj as character) as character
	local cCodFil := ''
	local aSm0 := FWLoadSM0()
	local nPos := Ascan(aSM0, {|x| Alltrim(x[18]) == Alltrim(cCnpj)})

	if nPos > 0
		cCodFil := aSm0[nPos][02]
	endif
return cCodFil
