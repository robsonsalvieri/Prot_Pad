#include 'protheus.ch'

function VEAtendimentoApi()
return .t.

/*/{Protheus.doc} VEAtendimentoApi
	Classe de abstração da tabela VO3
	
	@type function
	@author Vinicius Gati
	@since 10/09/2019
/*/
Class VEAtendimentoApi from VERegistroSql
	Data lAlcadaPermitida

	Method New() CONSTRUCTOR
	Method Aprovar()
	Method Reprovar()
	Method Alcada()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 10/09/2019
/*/
Method New() Class VEAtendimentoApi
	Local oSqlHelper := Dms_SqlHelper():New()
	_Super:New('VV9')
	::AddFields({;
		"R_E_C_N_O_","VV9_FILIAL","VV9_NUMATE","VV9_STATUS","VV9_CODCLI", "VV9_LOJA",;
		"D_E_L_E_T_ as deleted", "VV9_TELVIS","VV9_NOMVIS","VV9_MODVEI","SA1.A1_NOME",;
		oSQLHelper:Concat( { "VV9_FILIAL","VV9_NUMATE" })+" as VV9_UIDV";
	})

	if VV9->(FieldPos("VV9_INTUID")) > 0
		::AddField("VV9_INTUID")
	endif

	::HasOne("VEClienteApi", {{{||xFilial('SA1')}, 'A1_FILIAL' }, {'VV9_CODCLI', 'A1_COD'}, {'VV9_LOJA', 'A1_LOJA'}})
Return SELF

/*/{Protheus.doc} Aprovar
	Aprova o atendimento

	@type method
	@author Vinicius Gati
	@since 11/01/2023
/*/
Method Aprovar(oTecnico) Class VEAtendimentoApi
	if !empty(self:lAlcadaPermitida) .AND. !self:lAlcadaPermitida
		self:AddError("ALÇADA", "user without permissions")
		return .f.
	endif

	if oTecnico:Get("VAI_APROVA") == "1"
		VX0130064_Aprova(self:Get("VV9_NUMATE"), 1) // pre aprova
		VXI001ATU(self:Get("VV9_NUMATE"), "O")
	elseif oTecnico:Get("VAI_APROVA") == "2"
		VX0130064_Aprova(self:Get("VV9_NUMATE"), 2) // aprova
		VXI001ATU(self:Get("VV9_NUMATE"), "L")
	elseif oTecnico:Get("VAI_APROVA") == "3"
		VX0130064_Aprova(self:Get("VV9_NUMATE"), 3) // aprova previo
	else
		self:AddError("VAI_APROVA", "user without permissions")
		return .f.
	endif
Return .t.

/*/{Protheus.doc} Reprovar
	Reprova o atendimento

	@type method
	@author Vinicius Gati
	@since 11/01/2023
/*/
Method Reprovar(oTecnico) Class VEAtendimentoApi
	local lRet := .f.

	if oTecnico:Get("VAI_APROVA") <> "1" .and. oTecnico:Get("VAI_APROVA") <> "2" .and. oTecnico:Get("VAI_APROVA") <> "3"
		self:AddError("VAI_APROVA", "user without permissions")
		return .f.
	endif

	VXI010021_FaseAutomaticaInteresse(self:Get("VV9_FILIAL") , self:Get("VV9_NUMATE") , self:Get("VV9_STATUS"))
	VXI001ATU(self:Get("VV9_NUMATE"), "R")
	dbSelectarea("VV0")
	dbSetOrder(1)
	CONOUT(self:Get("VV9_NUMATE"))
	if dbSeek(xFilial("VV0") + self:Get("VV9_NUMATE"))
		VX0130054_Reprova() // grava um memo simples, nada demais
		lRet := .t.
	endif
Return lRet

/*/{Protheus.doc} Alcada
	Executa a verificação de alçada

	@type Method
	@author Bruno Forcato
	@since 12/05/2025
/*/
Method Alcada(cChaint, cId) Class VEAtendimentoApi
	local aVV1 := {}
	local aMap
	local nx := 0
	
	aMap := FM_MAPAVAPI(xFilial("VV9"), cId)
	for nx := 1 to len(aMap)
		aadd(aVV1, {cChaInt, '', '', '', '', '', '', '', aMap[nx][5][2], ''})	
	next

	self:lAlcadaPermitida := VEIXX007( 2 , aVV1 , , , , aMap[1, len(aMap[1]), 2] )
Return