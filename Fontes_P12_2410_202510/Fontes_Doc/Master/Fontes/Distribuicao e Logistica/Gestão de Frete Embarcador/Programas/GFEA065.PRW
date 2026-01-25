#INCLUDE "GFEA065.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

// TOTVS Colaboracao 2.0
#DEFINE TOTVS_COLAB_ONDEMAND 3100

// Códigos de mensagens padronizadas
#DEFINE GFEA065001 'GFEA065001'
#DEFINE GFEA065002 'GFEA065002'
#DEFINE GFEA065003 'GFEA065003'
#DEFINE GFEA065004 'GFEA065004'
#DEFINE GFEA065005 'GFEA065005'
#DEFINE GFEA065006 'GFEA065006'
#DEFINE GFEA065007 'GFEA065007'
#DEFINE GFEA065008 'GFEA065008'
#DEFINE GFEA065009 'GFEA065009'
#DEFINE GFEA065010 'GFEA065010'
#DEFINE GFEA065011 'GFEA065011'
#DEFINE GFEA065012 'GFEA065012'
#DEFINE GFEA065013 'GFEA065013'
#DEFINE GFEA065014 'GFEA065014'
#DEFINE GFEA065015 'GFEA065015'
#DEFINE GFEA065016 'GFEA065016'
#DEFINE GFEA065017 'GFEA065017'
#DEFINE GFEA065018 'GFEA065018'
#DEFINE GFEA065019 'GFEA065019'
#DEFINE GFEA065020 'GFEA065020'
#DEFINE GFEA065021 'GFEA065021'
#DEFINE GFEA065022 'GFEA065022'
#DEFINE GFEA065023 'GFEA065023'
#DEFINE GFEA065024 'GFEA065024'
#DEFINE GFEA065025 'GFEA065025'
#DEFINE GFEA065026 'GFEA065026'
#DEFINE GFEA065027 'GFEA065027'
#DEFINE GFEA065028 'GFEA065028'
#DEFINE GFEA065029 'GFEA065029'
#DEFINE GFEA065030 'GFEA065030'
#DEFINE GFEA065031 'GFEA065031'

Static lGfeAtu    := .F.
Static lDlg       := .F.
Static dDataDf    := NIL
Static aCalcRel   := {}
Static lConferiu  := .F.
Static cSitAnt    := ""
Static cSitCusAnt := ""
Static __lCpoSDoc := Nil
// Parâmetro que indica quando o calendário para seleção da
// data de vencimento da fatura deve ser apresentado
// 1 - Conforme cadastro do emitente (transportador)
// 2 - Nunca apresentar
// 3 - Sempre apresentar
Static __cGFECVFA := SuperGetMV("MV_GFECVFA",.T.,'1')
Static __lGFEROTR := (SuperGetMV("MV_GFEROTR",.F.,'1') == '1')

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065
Digitação de Documentos de Frete
Uso Generico.

@sample
GFEA065()

@author Israel A Possoli
@since 13/11/09
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function GFEA065()
	Local oBrowse   := Nil
	Local aLegenda  := {}
	Local nI        := 0
	Local nF        := 0
	Local s_GFE011  := ""
	Private lCopy   := .F.
	Private aRotina := MenuDef()

	If GFXPR12118("MV_GFE011")
		s_GFE011 := SuperGetMV("MV_GFE011", .F., "1")
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW3")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA065")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Digitação de Documentos de Frete"

	aAdd(aLegenda, {"GW3_SIT=='1'", "BLACK", STR0002}) //"Digitado"
	aAdd(aLegenda, {"GW3_SIT=='2'", "RED"  , STR0003}) //"Bloqueado"
	aAdd(aLegenda, {"GW3_SIT=='3'", "GREEN", STR0004}) //"Aprovado pelo Sistema"
	aAdd(aLegenda, {"GW3_SIT=='4'", "BLUE" , STR0005}) //"Aprovado pelo Usuário"
	aAdd(aLegenda, {"GW3_SIT=='5'", "YELLOW" , "Bloqueado por Entrega"}) //"Bloqueado por Entrega"

	// Ponto de entrada para customizar as legendas do Browse
	If ExistBlock("GFE065LG")
		aLegenda := ExecBlock("GFE065LG",.f.,.f.,{aLegenda})
	EndIf

	// Define para o contábil que a rotina chamadora é MVC. Ação necessária para acertar as validações realizadas pelo Módulo
	// Existe um chamado no Materiais para implementar esta chamada. Futuramente pode ser retirada do fonte
	CTB105MVC(.T.)
	nF := Len(aLegenda)
	For nI := 1 To nF
		oBrowse:AddLegend(aLegenda[nI][1], aLegenda[nI][2], aLegenda[nI][3])
	Next nI

	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina  := {}
	Local aRotina2 := {} //Submenu
	Local aRetPE   := {}
	Local cERPGFE  := ""
	Local aArea    := GetArea()

	If GFEA065INP()
		cERPGFE := SuperGetMv("MV_ERPGFE", .F., "2")
	EndIf

	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEA065" OPERATION 4 ACCESS  0 // "Alterar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA065" OPERATION 3 ACCESS  0 // "Incluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC065" OPERATION 2 ACCESS  0 // "Visualizar"

	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS  0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GFEA065" OPERATION 5 ACCESS  0 // "Excluir"
	ADD OPTION aRotina TITLE STR0012 ACTION "GFEA65COPY()"    OPERATION 6 ACCESS  0 // "Copiar"
	ADD OPTION aRotina TITLE STR0013 ACTION "VIEWDEF.GFEA065" OPERATION 8 ACCESS  0 // "Imprimir"
	ADD OPTION aRotina TITLE "Exclusão em Lote"	    ACTION "GFEA065LOT()"	  		   OPERATION 10 ACCESS 0 // "Exclusão em lote"
	ADD OPTION aRotina TITLE "Dados da Conferência" ACTION "GFEA066AP(.F.)"  		   OPERATION 4  ACCESS 0 // "Dados da Conferência"
	ADD OPTION aRotina TITLE "Atualizar Fiscal ERP"	ACTION "GFEA065XF(.F., '1', .T. )" OPERATION 10 ACCESS 0 // "Fiscal"

	If cERPGFE == "2"
		ADD OPTION aRotina TITLE "Atualizar Pré Nota" ACTION "GFEA065XF(.F., '4' )" OPERATION 10 ACCESS 0 // "Fiscal"
	EndIf

	ADD OPTION aRotina TITLE "Desatualiz Fiscal ERP" ACTION "GFEA065XD('1')"  OPERATION 10 ACCESS 0 // "Desatualizar Fiscal"
	ADD OPTION aRotina TITLE "Atualizar Aprop Desp ERP"	ACTION "GFEA065XC(.F., '2', .T.)" OPERATION 11 ACCESS 0 // "Apropriação Despesa"

	If cERPGFE == "2"
		ADD OPTION aRotina TITLE "Atualizar Pré CT" ACTION "GFEA065XC(.F., '5')" OPERATION 11 ACCESS 0 // "Apropriação Despesa"
	EndIf

	ADD OPTION aRotina TITLE "Desatualiz Aprop Desp ERP" ACTION "GFEA065XD('2')"  OPERATION 11 ACCESS 0 // "Desatualizar Aprop Despesa"
	ADD OPTION aRotina TITLE "Gerar Fatura Avulsa" ACTION "GFEA65GFAT(.T.)" OPERATION 4  ACCESS 0 // "Gera Fatura Avulsa"
	ADD OPTION aRotina TITLE "Gerar Doc Complementar" ACTION "GFEA065CC()"     OPERATION 12 ACCESS 0 // "Gerar Doc Complementar"

	If cERPGFE == "2"
		ADD OPTION aRotina TITLE "Dados Integração ERP" ACTION "GFEA065IPR()" OPERATION 13 ACCESS 0
	EndIf

	If FindFunction('GFEA065B')
		ADD OPTION aRotina TITLE "Inclusão Rápida" ACTION "GFEA065B('1')" OPERATION 3 ACCESS 0
	EndIf

	If FindFunction('GFEA065B')
		ADD OPTION aRotina TITLE "Inclusão Rápida Chave CTe" ACTION "GFEA065B('2')" OPERATION 3 ACCESS 0
	EndIf

	If FindFunction('GFEA065CDF')
		ADD OPTION aRotina TITLE "Doc. Carga" ACTION "GFEA065CDF()" OPERATION 4 ACCESS 0
	EndIf

	If FindFunction('GFEA065D') .AND. GFXCP12117("GW3_MOTFIN")
		ADD OPTION aRotina TITLE "Situação no Financeiro" 		ACTION aRotina2 			OPERATION 14 ACCESS 0
		ADD OPTION aRotina2 TITLE "1 - Não Enviada" 	  		ACTION "GFEA065D('1')"		OPERATION 1  ACCESS  0
		ADD OPTION aRotina2 TITLE "2 - Pendente" 				ACTION "GFEA065D('2')"		OPERATION 2  ACCESS  0
		ADD OPTION aRotina2 TITLE "3 - Rejeitada" 				ACTION "GFEA065D('3')"		OPERATION 2  ACCESS  0
		ADD OPTION aRotina2 TITLE "4 - Atualizada" 				ACTION "GFEA065D('4')"		OPERATION 2  ACCESS  0
		ADD OPTION aRotina2 TITLE "5 - Pendente Desatualização" ACTION "GFEA065D('5')"		OPERATION 2  ACCESS  0
	EndIf

	If GFXCP12118("GW3_SITMLA")
		If SuperGetMv("MV_DFMLA",.F.,"1") $ "2|3"
			ADD OPTION aRotina TITLE "Desatualizar MLA" ACTION "GFEA065DMA" OPERATION 10 ACCESS 0
		EndIf
	EndIf

	If GFXTB12117("GWC")
		ADD OPTION aRotina TITLE "Atualizar Custo Frete TMS" ACTION "GFEA065CTP('ID', .T.)" OPERATION 15 ACCESS 0
		ADD OPTION aRotina TITLE "Desatualizar Custo Frete TMS" ACTION "GFEA065CTP('E', .T.)" OPERATION 15 ACCESS 0
	EndIf

	ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GW3',GW3->(RecNo()), 2)"  OPERATION 4 ACCESS 0  // "Anexo"
	// Função indisponível para ajuste de usabilidade
	ADD OPTION aRotina TITLE "Gerar Fatura por Faixa" ACTION "GFEA065GFF(.T.)" OPERATION 8 ACCESS 0 // "Gerar Fatura por Faixa"
	AAdd(aRotina, {"Reauditar", "GFEA065REA()", 0, 4, 0, .F.} )

	// Ponto de entrada que permite incluir opções adicionais
	// no menu padrão da rotina documentos de frete
	If ExistBlock("GFEA0657")
		aRetPE := ExecBlock("GFEA0657 ",.F.,.F.)
		If ValType(aRetPE) == "A"
			AEval(aRetPE, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf
	RestArea(aArea)
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel     := Nil
	Local oView      := Nil
	Local oStructGW3 := FWFormStruct(1, "GW3")
	Local oStructGW4 := FWFormStruct(1, "GW4")
	Local oStructGW8 := FWFormStruct(1, "GW8", {|cCampo| BscStrGW8(cCampo)})

	//----------------------------------------------

	oStructGW3:AddField (STR0100, STR0100, "GW3_PCPIS" , "N", 12, 4/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("PIS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/) //"Aliquota PIS"
	oStructGW3:AddField (STR0101, STR0101, "GW3_PCCOFI", "N", 12, 4/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("COFINS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/) //"Aliquota COFINS"

	// UF do Destinatário - Usado na integração com Protheus para gravar a UF Origem no Documento de Entrada
	oStructGW3:AddField ("UF Destinatario", "UF Destinatario", "GW3_UFDEST", "C", TamSX3("GU7_CDUF")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	oStructGW3:AddField ("UF Emissor", "UF Emissor", "GW3_UFEMIS", "C", TamSX3("GU7_CDUF")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)

	If GFXXB12117("GWJPRE")
		oStructGW4:AddField("OK", "OK", "_VALID", 'BT', 1, 0/*nDECIMAL*/, , /*bWHEN*/, /*@aVALUES*/, .F., {|| CORVALID(.T.)}, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	EndIf

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição

	oView := FWViewActive()
	oModel := MPFormModel():New("GFEA065", , , {|oModel| GFEA065CMT(oModel)}, /*bCancel*/)
	oModel:bPost := {|oModel| GFEA065VP(oModel, oView)}
	oModel:SetVldActivate ( { |oMod| GFEA065VL( oMod ) } )

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA065_GW3", Nil, oStructGW3, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"GW3_FILIAL", "GW3_CDESP", "GW3_EMISDF", "GW3_SERDF", "GW3_NRDF", "GW3_DTEMIS"})

	oModel:AddGrid("GFEA065_GW4","GFEA065_GW3", oStructGW4, {|oMod| G065GW4VPR(oMod)}, {|oMod| GFE065PreT(oMod), G065GW4VP(oMod)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid("GFEA065_GW8","GFEA065_GW4", oStructGW8, , , /*bPreVal*/, /*bPosVal*/,  {|oMod| GFEA065GW8(oMod)} )
	oModel:GetModel('GFEA065_GW8'):SetOptional(.T.)
	oModel:GetModel('GFEA065_GW8'):SetOnlyQuery(.T.)
	If !IsBlind()
		oModel:GetModel("GFEA065_GW4"):SetMaxLine(9999)
	EndIf
	oModel:GetModel("GFEA065_GW4"):SetUniqueLine({"GW4_EMISDC","GW4_SERDC","GW4_NRDC","GW4_TPDC"})
	oModel:GetModel("GFEA065_GW4"):SetDelAllLine( .T. )

	oModel:GetModel("GFEA065_GW8"):SetDescription(STR0102) //"Itens"
	oModel:GetModel("GFEA065_GW8"):SetUniqueLine({"GW8_CDTPDC","GW8_EMISDC","GW8_SERDC","GW8_NRDC","GW8_SEQ"})
	oModel:SetOptional("GFEA065_GW4", .T. )

	oModel:SetRelation("GFEA065_GW4",{{"GW4_FILIAL","xFilial('GW4')"},{"GW4_CDESP","GW3_CDESP"},{"GW4_EMISDF","GW3_EMISDF"},{"GW4_SERDF","GW3_SERDF"},{"GW4_NRDF","GW3_NRDF"},{"GW4_DTEMIS","GW3_DTEMIS"}},"GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+GW4_DTEMIS")
	oModel:SetRelation("GFEA065_GW8",{{"GW8_FILIAL","xFilial('GW8')"},{"GW8_CDTPDC","GW4_TPDC"},{"GW8_EMISDC","GW4_EMISDC"},{"GW8_SERDC","GW4_SERDC"},{"GW8_NRDC","GW4_NRDC"}},"GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC")

	oModel:SetActivate({|oMod| GFEA65ACT(oMod)})

Return oModel

//--------------------------------------------------------------

Static Function ViewDef()

	Local oModel     := FWLoadModel("GFEA065")
	Local oView      := Nil
	Local oStructGW3 := FWFormStruct(2, "GW3")
	Local oStructGW4 := FWFormStruct(2, "GW4")
	Local lCpoTES    := GFEA065INP()

 	oStructGW3:AddField("GW3_PCPIS" , AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASPIS"})][2]) + 1)), STR0100, "", {STR0100}, "N", "@E 999,999,999.9999", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) // "Aliquota PIS"
	oStructGW3:AddField("GW3_PCCOFI", AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASCOF"})][2]) + 1)), STR0101, "", {STR0101}, "N", "@E 999,999,999.9999", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) // "Aliquota COFINS"

 	oStructGW3:AddGroup("GrpId" , STR0091, "1", 2) // "Identificação"
	oStructGW3:AddGroup("GrpOri", STR0092, "1", 2) // "Origem/Destino"
	oStructGW3:AddGroup("GrpVal", STR0093, "1", 2) // "Valores"
	oStructGW3:AddGroup("GrpDtC", STR0094, "1", 2) // "Dados da Carga"
	oStructGW3:AddGroup("GrpImp", STR0095, "1", 2) // "Impostos"
	oStructGW3:AddGroup("GrpCom", STR0096, "1", 2) // "Complementos"

	If lCpoTES
		oStructGW3:AddGroup("GrpInt",	"Geral"	  , "2", 2) // "Geral"
		oStructGW3:AddGroup("GrpDS"	, 	"Datasul" , "2", 2) // "Datasul"
		oStructGW3:AddGroup("GrpProt",	"Protheus"	, "2", 2) // "Protheus"
		oStructGW3:AddGroup("GrpMLA",   "MLA"     , "2", 2)
		oStructGW3:AddGroup("GrpAudit", "Auditoria", "3", 2) // "Auditoria"
		If GFXCP12127("GW3_VLDIV")
			oStructGW3:AddGroup("GrpDiv", "Divergência", "3", 2) // "Divergência"
		Endif
		oStructGW3:AddGroup("GrpDFt", STR0103, "4", 2) // "Dados da Fatura"
		oStructGW3:AddGroup("GrpFtA", STR0104, "4", 2) // "Faturamento Avulso"
		oStructGW3:AddGroup("GrpCsg", STR0097, "5", 2) // "Consignatário"
		oStructGW3:AddGroup("GrpDFO", STR0098, "5", 2) // "Documento de Frete de Origem"
	Else
		oStructGW3:AddGroup("GrpAudit", "Auditoria", "2", 2) // "Auditoria"
		If GFXCP12127("GW3_VLDIV")
			oStructGW3:AddGroup("GrpDiv", "Divergência", "2", 2) // "Divergência"
		Endif
		oStructGW3:AddGroup("GrpDFt", STR0103, "3", 2) // "Dados da Fatura"
		oStructGW3:AddGroup("GrpFtA", STR0104, "3", 2) // "Faturamento Avulso"
		oStructGW3:AddGroup("GrpCsg", STR0097, "4", 2) // "Consignatário"
		oStructGW3:AddGroup("GrpDFO", STR0098, "4", 2) // "Documento de Frete de Origem"
		oStructGW3:AddGroup("GrpInt", STR0099, "4", 2) // "Integrações"
	EndIf
	oStructGW3:SetProperty("GW3_CDESP" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_EMISDF", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_NMEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_SERDF" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_NRDF"  , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_TPDF"  , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_DTENT" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_CFOP"  , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW3:SetProperty("GW3_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpId")
	If GFXCP12117("GW3_CDTPSE")
		oStructGW3:SetProperty("GW3_CDTPSE", MVC_VIEW_GROUP_NUMBER, "GrpId")
		oStructGW3:SetProperty("GW3_DSTPSE", MVC_VIEW_GROUP_NUMBER, "GrpId")
	EndIf
	//Ponto de entrada Britania
	If ExistBlock("XGFEINC")
		ExecBlock("XGFEINC",.f.,.f.,{oStructGW3, "GrpId"})
	EndIf
	//Fim ponto de entrada Britania
	oStructGW3:SetProperty("GW3_CDREM" , MVC_VIEW_GROUP_NUMBER, "GrpOri")
	oStructGW3:SetProperty("GW3_NMREM" , MVC_VIEW_GROUP_NUMBER, "GrpOri")
	oStructGW3:SetProperty("GW3_CDDEST", MVC_VIEW_GROUP_NUMBER, "GrpOri")
	oStructGW3:SetProperty("GW3_NMDEST", MVC_VIEW_GROUP_NUMBER, "GrpOri")
	If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM")
		oStructGW3:SetProperty("GW3_MUNINI", MVC_VIEW_GROUP_NUMBER, "GrpOri")
		oStructGW3:SetProperty("GW3_UFINI" , MVC_VIEW_GROUP_NUMBER, "GrpOri")
		oStructGW3:SetProperty("GW3_MUNFIM", MVC_VIEW_GROUP_NUMBER, "GrpOri")
		oStructGW3:SetProperty("GW3_UFFIM" , MVC_VIEW_GROUP_NUMBER, "GrpOri")
	EndIf
	oStructGW3:SetProperty("GW3_VLDF"  , MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_TAXAS" , MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_FRPESO", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_FRVAL" , MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_PEDAG" , MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_PDGFRT", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_ICMPDG", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_PDGPIS", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW3:SetProperty("GW3_QTDCS" , MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_QTVOL" , MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_VOLUM" , MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_PESOR" , MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_PESOC" , MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_VLCARG", MVC_VIEW_GROUP_NUMBER, "GrpDtC")
	oStructGW3:SetProperty("GW3_TRBIMP", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_TPIMP" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_BASIMP", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_PCIMP" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_VLIMP" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_IMPRET", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_PCRET" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_CRDICM", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_BASCOF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_VLCOF" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_BASPIS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_VLPIS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_NATFRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_CRDPC" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_OBS"   , MVC_VIEW_GROUP_NUMBER, "GrpCom")
	oStructGW3:SetProperty("GW3_CTE"   , MVC_VIEW_GROUP_NUMBER, "GrpCom")
	oStructGW3:SetProperty("GW3_TPCTE" , MVC_VIEW_GROUP_NUMBER, "GrpCom")
	If GFXCP12137('GW3_FILTOM')
		oStructGW3:SetProperty("GW3_FILTOM", MVC_VIEW_GROUP_NUMBER, "GrpCom")
	EndIf
	If GFXCP2510('GW3_CTESUB')
		oStructGW3:SetProperty("GW3_CTESUB" , MVC_VIEW_GROUP_NUMBER, "GrpCom")
	EndIf 
	oStructGW3:SetProperty("GW3_FILFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_EMIFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_SERFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_NRFAT" , MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_DTEMFA", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	If GFXCP12116("GW3","GW3_DTVCFT")
		oStructGW3:SetProperty("GW3_DTVCFT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	EndIf
	If GFXCP12117("GW3_MOTFIN")
		oStructGW3:SetProperty("GW3_SITFIN", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
		oStructGW3:SetProperty("GW3_DTFIN" , MVC_VIEW_GROUP_NUMBER, "GrpDFt")
		oStructGW3:SetProperty("GW3_MOTFIN", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	EndIf
	oStructGW3:SetProperty("GW3_MOTBLQ", MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	oStructGW3:SetProperty("GW3_DTBLQ" , MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	oStructGW3:SetProperty("GW3_USUBLQ", MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	oStructGW3:SetProperty("GW3_MOTAPR", MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	oStructGW3:SetProperty("GW3_DTAPR" , MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	oStructGW3:SetProperty("GW3_USUAPR", MVC_VIEW_GROUP_NUMBER, "GrpAudit")
	If GFXCP12127("GW3_VLDIV")
		oStructGW3:SetProperty("GW3_VLDIV", MVC_VIEW_GROUP_NUMBER, "GrpDiv")
		oStructGW3:SetProperty("GW3_SITDIV", MVC_VIEW_GROUP_NUMBER, "GrpDiv")
	Endif
	oStructGW3:SetProperty("GW3_DTVNFT", MVC_VIEW_GROUP_NUMBER, "GrpFtA")
	oStructGW3:SetProperty("GW3_CDCONS", MVC_VIEW_GROUP_NUMBER, "GrpCsg")
	oStructGW3:SetProperty("GW3_NMCONS", MVC_VIEW_GROUP_NUMBER, "GrpCsg")
	oStructGW3:SetProperty("GW3_ORINR" , MVC_VIEW_GROUP_NUMBER, "GrpDFO")
	oStructGW3:SetProperty("GW3_ORISER", MVC_VIEW_GROUP_NUMBER, "GrpDFO")
	oStructGW3:SetProperty("GW3_ORIDTE", MVC_VIEW_GROUP_NUMBER, "GrpDFO")
	oStructGW3:SetProperty("GW3_TPCTB" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_ACINT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_DSOFDT", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_DTFIS" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_SITFIS", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_MOTFIS", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_DTREC" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_SITREC", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW3:SetProperty("GW3_MOTREC", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	If lCpoTES
		oStructGW3:SetProperty("GW3_DSOFIT", MVC_VIEW_GROUP_NUMBER, "GrpDS")
		oStructGW3:SetProperty("GW3_DSOFDT", MVC_VIEW_GROUP_NUMBER, "GrpDS")
		oStructGW3:SetProperty("GW3_PRITDF", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_CPDGFE", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_TES",    MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_CONTA",  MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_ITEMCT", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_CC",	  MVC_VIEW_GROUP_NUMBER, "GrpProt")
	Else
		oStructGW3:SetProperty("GW3_DSOFIT", MVC_VIEW_GROUP_NUMBER, "GrpInt")
		oStructGW3:SetProperty("GW3_PRITDF", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf
	If GFXTB12117("GWC")
		oStructGW3:SetProperty("GW3_SITCUS", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_DESCUS", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_DTCUS",  MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_USUCUS", MVC_VIEW_GROUP_NUMBER, "GrpProt")
		oStructGW3:SetProperty("GW3_MOTCUS", MVC_VIEW_GROUP_NUMBER, "GrpProt")
   EndIf
	If oStructGW3:HasField('GW3_SITMLA') .And. lCpoTes
		oStructGW3:SetProperty("GW3_SITMLA", MVC_VIEW_GROUP_NUMBER, "GrpMLA")
		oStructGW3:SetProperty("GW3_MOTMLA", MVC_VIEW_GROUP_NUMBER, "GrpMLA")
		oStructGW3:SetProperty("GW3_HRAPR" , MVC_VIEW_GROUP_NUMBER, "GrpMLA")
	EndIf
	If GFXCP12123("GW3_USO")
		oStructGW3:SetProperty("GW3_USO", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf
	If GFXCP12123("GW3_TPOPER")
		oStructGW3:SetProperty("GW3_TPOPER", MVC_VIEW_GROUP_NUMBER, "GrpProt")
	EndIf
	oStructGW3:SetProperty("GW3_ACINT", MVC_VIEW_GROUP_NUMBER, "GrpDS")


	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("GFEA065_GW3", oStructGW3)

	if SuperGetMv("MV_ERPGFE", .F., "2") == "1" .and. lCpoTES
		oStructGW3:RemoveField("GW3_PRITDF")
		oStructGW3:RemoveField("GW3_TES")
		oStructGW3:RemoveField("GW3_CONTA")
		oStructGW3:RemoveField("GW3_ITEMCT")
		oStructGW3:RemoveField("GW3_CC")
		oStructGW3:RemoveField("GW3_CPDGFE")
	endif

	oStructGW3:RemoveField("GW3_DSOFUM")
	oStructGW3:RemoveField("GW3_DSOFCF")
	oStructGW3:RemoveField("GW3_DSOFCT")
	oStructGW3:RemoveField("GW3_DSOFCS")

	If GFXCP2510('GW3_XMLTRB')
		oStructGW3:RemoveField("GW3_XMLTRB")
	EndIf

	If GFXXB12117("GWJPRE")
		oStructGW4:AddField( "_VALID"  ,'00' , "OK"          , "OK"      , {} , 'BT' ,'@BMP', NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T. )
	EndIf

	oStructGW4:RemoveField("GW4_FILIAL")
	oStructGW4:RemoveField("GW4_CDESP")
	oStructGW4:RemoveField("GW4_EMISDF")
	oStructGW4:RemoveField("GW4_SERDF")
	oStructGW4:RemoveField("GW4_NRDF")
	oStructGW4:RemoveField("GW4_DTEMIS")
	oView:AddGrid("GFEA065_GW4", oStructGW4)

	oView:CreateHorizontalBox("MASTER", 55)
	oView:CreateHorizontalBox("DETAIL", 45)

	oView:CreateFolder("IDFOLDER", "DETAIL")
	oView:AddSheet("IDFOLDER", "IDSHEET01", STR0057) //"Documentos de Carga"

	oView:CreateVerticalBox("EMBAIXOESQ", 90,,, "IDFOLDER", "IDSHEET01")
	oView:CreateVerticalBox("EMBAIXODIR", 10,,, "IDFOLDER", "IDSHEET01")

	oView:SetOwnerView( "GFEA065_GW3" , "MASTER"     )
	oView:SetOwnerView( "GFEA065_GW4" , "EMBAIXOESQ" )

	oView:AddOtherObject("OTHER_PANEL", {|oPanel,oModel| GFEA065ADD(oPanel,oModel)})
	oView:SetOwnerView("OTHER_PANEL","EMBAIXODIR")
	If GFXXB12117("GWJPRE")
		oView:AddUserButton('Legenda','',{|| LEGVALID() })
	EndIf
Return oView

/*------------------------------------------------------------
Função para permitir a geração automática de Fatura de Frete
------------------------------------------------------------*/
Function GFEA065GFF(lInterface)
	Local aErro      := {}
	Local aErros     := {}
	Local aTransp    := {}
	Local aFatura    := {}
	Local aReg       := {}
	Local aGW3       := {}
	Local aDocto     := {}
	Local nI         := 0
	Local nX         := 0
	Local nY         := 0
	Local nF         := 0
	Local nTotal     := 0
	Local oModelGW6  as Object
	Local cQuery     := ""
	Local cTpImp     := ""
	Local cLogOption := "3"
	Local s_GFE06501 := ExistBlock("GFE06501")
	Local lEnc       := .F.
	Local nVlICMS    := 0
	Local nVlISS     := 0
	Local dDtVenc    := NIL
	Local cLstFil    := ""
	Local cLstTran   := ""
	Local aFil01     := {}
	Local aFil02     := {}
	Local aFil03     := {}
	Local aFilPerm   := {}
	Local dData      as Date
	Local NVLISRE    := 0
	Local nVlIcre    := 0
	Local cFaturas 	 := ""
	Local lDataOk 	 := .F.
	Local aDocsVal   := {0,0,0,0,0}
	Local cBcoDados	 := TcGetDb()

	Private cAliasQry := GetNextAlias()

	If IsBlind()
		dData := DATE()
		lInterface := .F.
	Else
		dData := DDATABASE
	EndIf

	If !IsBlind()
		// Tratamento para que permita a geração automática de Fatura de Frete sem o pergunte atualizado
		Pergunte("GFEA065GFF",.F.)
		If !Empty(MV_PAR05)
			If !( Pergunte("GFEA065GFF",.T.) )
				GFEMessage(0, GFEA065030, STR0549) // "Operação Cancelada pelo Usuário"
				Return
			EndIf
		Else
			MV_PAR05 := 1
		Endif
	EndIf

	cQuery := "SELECT GW3_FILIAL, GW3_NRDF, GW3_EMISDF, GW3_SERDF, GW3_CDESP, GW3_VLDF, GW3_VLIMP, GW3_IMPRET, GW3_DTEMIS "
	cQuery += " FROM " + RetSQLName("GW3") + " GW3 "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "

	//Filiais
	If !Empty(MV_PAR01)
		aFil01   := Str2Arr(Upper(MV_PAR01), ";") //Filiais informadas em tela
		aFilPerm := FWUsrEmp(__cUserID) // Lista as filiais que o usuário tem permissão.
		For nX:= 1 To Len(aFilPerm)
			AADD(aFil02,SubStr(aFilPerm[nX], Len(cEmpAnt)+1))
		Next
		aFil03 := {}
		// Como o usuário pode ter informado filiais que não tem permissão, é preciso verificar quais tem permissão.
		nF := Len(aFil01)
		For nX:= 1 To nF
			nPos := ASCAN(aFil02,{|X| Alltrim(X) == Alltrim(aFil01[nX])})
			If nPos > 0 .OR. AScan(aFilPerm,"@@@@") > 0
				AADD(aFil03,aFil01[nX])
			EndIf
		Next
	EndIf

	nF := Len(aFil03)
	For nI := 1 To nF
		If cLstFil == ""
			If cBcoDados == "ORACLE"
				cLstFil := aFil03[nI]
			Else
				cLstFil := "'" + aFil03[nI] + "'"
			EndIf
		Else
			If cBcoDados == "ORACLE"
				cLstFil += "," + aFil03[nI]
			Else
				cLstFil += ",'" + aFil03[nI] + "'"
			EndIf
		EndIf
	Next nI

	If !Empty( cLstFil )
		cQuery += " AND GW3_FILIAL IN (" + cLstFil + " )"
	EndIf

	//Transportadoras
	aTransp := Iif(!Empty(MV_PAR04),Str2Arr(Upper(MV_PAR04), ";"),{})

	nF := Len(aTransp)
	For nI := 1 To nF
		If cLstTran == ""
			If cBcoDados == "ORACLE"
				cLstTran := aTransp[nI]
			Else
				cLstTran := "'" + aTransp[nI] + "'"
			EndIf
		Else
			If cBcoDados == "ORACLE"
				cLstTran += ","  + aTransp[nI]
			Else
				cLstTran += ",'"  + aTransp[nI] + "'"
			EndIf
		EndIf
	Next nI

	If !Empty( cLstTran )
		cQuery += " AND GW3_EMISDF IN ("+ cLstTran + ")"
	EndIf

	If !Empty(MV_PAR02)
		cQuery += " AND GW3_DTEMIS >= '" + DtoS(MV_PAR02) + "' "
	EndIf

	If !Empty(MV_PAR03)
		cQuery += " AND GW3_DTEMIS <= '" + DtoS(MV_PAR03) + "' "
	EndIf

	If MV_PAR05 == 1 // Status do Doc Frete (1=Apenas aprovados;2=Apenas integrados no módulo fiscal)
		cQuery += " AND (GW3_SIT = '3' OR GW3_SIT = '4')" // Aprovado sistema ou Aprovado usuário
	Else
		cQuery += " AND GW3_SITFIS = '4' " // Atualizado fiscal ERP
	EndIf
	cQuery += " AND GW3_NRFAT = '' " // Considera apenas documentos de frete não associados à faturas
	cQuery += " ORDER BY GW3_EMISDF "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	(cAliasQry)->( dbGoTop() )
	Do While !(cAliasQry)->( Eof() )
		nVlICMS := 0
		nVlISS  := 0
		cTpImp  := Posicione("GVT",1,xFilial("GVT")+(cAliasQry)->GW3_CDESP,"GVT_TPIMP")
		If AllTrim(cTpImp) == "1" // 1=ICMS
			nVlICMS := GFETratDec( (cAliasQry)->GW3_VLIMP, 0, .T. )
			nVlIcre := (cAliasQry)->GW3_IMPRET
		ElseIf AllTrim(cTpImp) == "2" // 2=ISS
			nVlISS  := GFETratDec( (cAliasQry)->GW3_VLIMP, 0, .T. )
			nVLISRE := (cAliasQry)->GW3_IMPRET
		EndIf

		If !Empty(aReg)
			nF := Len(aReg)
			For nI := 1 To nF
				If AllTrim(aReg[nI][1]) == AllTrim((cAliasQry)->GW3_FILIAL) .and. AllTrim(aReg[nI][2]) == AllTrim((cAliasQry)->GW3_EMISDF)

					aReg[nI][5] += (cAliasQry)->GW3_VLDF // Valor Fatura
					aReg[nI][6] += nVlICMS
					aReg[nI][7] += nVlISS

					aDocto := {(cAliasQry)->GW3_FILIAL,(cAliasQry)->GW3_CDESP,(cAliasQry)->GW3_EMISDF,(cAliasQry)->GW3_SERDF,(cAliasQry)->GW3_NRDF,(cAliasQry)->GW3_DTEMIS}
					Aadd(aGW3,aDocto)
					lEnc := .T.
					Exit
				EndIf
			Next nI
		EndIf

		If !lEnc
			aDocto := {(cAliasQry)->GW3_FILIAL,(cAliasQry)->GW3_CDESP,(cAliasQry)->GW3_EMISDF,(cAliasQry)->GW3_SERDF,(cAliasQry)->GW3_NRDF,(cAliasQry)->GW3_DTEMIS}
			Aadd(aGW3,aDocto)

			aFatura := { (cAliasQry)->GW3_FILIAL,;
				 		 (cAliasQry)->GW3_EMISDF,;
				 		 (cAliasQry)->GW3_SERDF,;
						 (cAliasQry)->GW3_NRDF,;
						 (cAliasQry)->GW3_VLDF,;
						  nVlICMS,;
						  nVlIcre,;
						  nVlISS,;
						  nVLISRE}
			Aadd(aReg,aFatura)
		EndIf
		lEnc := .F.
		(cAliasQry)->( dbSkip() )
	EndDo

	GFEResult := GFEViewProc():New()

	If !Empty(aReg)
		GFELog065 := GFELog():New("Gerar_Fatura", "Fatura - Criação automática de Faturas de Frete", cLogOption )
		nF := Len(aReg)
		For nX := 1 To nF
			oModelGW6 := FWLoadModel( "GFEA070" )
			nTotal++

			oModelGW6:SetOperation( 3 )
			oModelGW6:Activate()

			GFELog065:Add("[" + cValToChar(nTotal) + "] Criando Fatura de Frete: " + aReg[nX][4] )
			GFELog065:Add("> Filial: " + aReg[nX][1], 1)
			GFELog065:Add("> Transportador: " + aReg[nX][2], 1)
			GFELog065:Add("> Número: " + aReg[nX][4], 1)
			GFELog065:Add("> Dt.Emis: " + DToC(dData), 1)
			GFELog065:Save()

			oModelGW6:SetValue("GFEA070_GW6",'GW6_FILIAL' , aReg[nX][1] ) // Filial
			oModelGW6:SetValue("GFEA070_GW6",'GW6_EMIFAT' , aReg[nX][2] ) // Emissor Fatura
			oModelGW6:SetValue("GFEA070_GW6",'GW6_SERFAT' , aReg[nX][3] ) // Série
			oModelGW6:SetValue("GFEA070_GW6",'GW6_NRFAT'  , aReg[nX][4] ) // Número Fatura (primeiro DF encontrado)
			oModelGW6:SetValue("GFEA070_GW6",'GW6_DTEMIS' , dData )       // Data de Emissão
			oModelGW6:SetValue("GFEA070_GW6",'GW6_DTCRIA' , dData )       // Data de Criação

			dDtVenc := GFECalcVc(dData, aReg[nX][2])

			If lInterface
				////DLOGGFE-11382 - apresentar data somente um vez
				If __cGFECVFA == '3' .Or.;
				  (__cGFECVFA == '1' .And. Posicione("GU3", 1, xFilial("GU3") + aReg[nX][2], "GU3_CALCVC") == '2') .and. !lDataOk

					DEFINE DIALOG oDlg TITLE "Selecione a Data de Vencimento" FROM 180,180 TO 350,460 PIXEL
					oMsCalend := MsCalend():New(01,01,oDlg,.F.)
					oMsCalend:dDiaAtu := dDtVenc
					oMsCalend:bChange := {|| dDtVenc := oMsCalend:dDiaAtu}
					oTButton1 := TButton():New( 070, 30, "Ok" ,oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Ok"
					lOK := .T.
					lDataOk := .T.
					ACTIVATE DIALOG oDlg CENTERED

				EndIf
			EndIf

			If Empty(dDtVenc)
				dDtVenc := dData
			EndIf

			If s_GFE06501
				dDtVenc := ExecBlock("GFE06501",.F.,.F.,{dDtVenc})
			EndIf

			GFELog065:Add("> Dt.Venc: " + DToC(dDtVenc), 1)

			oModelGW6:SetValue("GFEA070_GW6",'GW6_DTVENC' , dDtVenc )    // Data de Vencimento
			oModelGW6:SetValue("GFEA070_GW6",'GW6_ORIGEM' , '3' )        // 3=Sistema

			oModelGW6:SetValue("GFEA070_GW6",'GW6_VLFATU', aReg[nX][5] ) // Valor Fatura
			oModelGW6:SetValue("GFEA070_GW6",'GW6_VLICMS', aReg[nX][6] ) // Valor ICMS
			oModelGW6:SetValue("GFEA070_GW6",'GW6_VLICRE', aReg[nX][7] )
			oModelGW6:SetValue("GFEA070_GW6",'GW6_VLISS' , aReg[nX][8] ) // Valor ISS
			oModelGW6:SetValue("GFEA070_GW6",'GW6_VLISRE', aReg[nX][9] )
			oModelGW6:SetValue("GFEA070_GW6",'GW6_SITAPR' , '1' )        // 3=Aprovada sistema

			If oModelGW6:VldData() // Indica se o modelo foi carregado com sucesso
				lRet := oModelGW6:CommitData() // Grava a folha de dados do obj
				If lRet
					GFELog065:NewLine()
					GFELog065:Add("** " + "Documentos de Frete da Fatura: " , 1)

					aDocsVal := {0,0,0,0,0}

					// Relacionada todos os documentos de frete com a Fatura
					nF := Len(aGW3)
					For nY := 1 To nF
						// GW3_FILIAL + GW3_EMISDF
						If aReg[nX][1] == aGW3[nY][1] .and. aReg[nX][2] == aGW3[nY][3]
							GW3->(dbsetOrder(1))
							GW3->(dbSeek(aGW3[nY][1] + aGW3[nY][2] + aGW3[nY][3] + aGW3[nY][4] + aGW3[nY][5] + aGW3[nY][6]))
							Do While !GW3->(Eof()) .And. (aGW3[nY][1] + aGW3[nY][2] + aGW3[nY][3] + aGW3[nY][4] + aGW3[nY][5] + aGW3[nY][6]) == GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS))
								GFELog065:Add("** " + "Emissor: " + AllTrim(aGW3[nY][3]) + " Série: " + AllTrim(aGW3[nY][4]) + " Número Documento : " + AllTrim(aGW3[nY][5]), 1)
								//Relaciona o Documento de Frete à pré-fatura.
								RecLock("GW3", .F.)
									GW3->GW3_FILFAT := aReg[nX][1]
									GW3->GW3_EMIFAT := aReg[nX][2]
									GW3->GW3_SERFAT := aReg[nX][3]
									GW3->GW3_NRFAT  := aReg[nX][4]
									GW3->GW3_DTEMFA := dData
								GW3->(MSUnlock())

								aDocsVal[1] += GW3->GW3_VLDF

								If GW3->GW3_TPIMP == "1"
									aDocsVal[2] += GW3->GW3_VLIMP
									aDocsVal[3] += GW3->GW3_IMPRET
								Else
									aDocsVal[4] += GW3->GW3_VLIMP
									aDocsVal[5] += GW3->GW3_IMPRET
								EndIf

								GW3->(dbSkip())
							EndDo
						EndIf
					Next nY

					GFELog065:NewLine()
					GFELog065:Add("** " + "Fatura de Frete " + AllTrim(aReg[nX][4]) + " gerada com sucesso." + CRLF, 1)
					cFaturas += "** " + "Fatura de Frete " + AllTrim(aReg[nX][4]) + " gerada com sucesso." + CRLF
					GFEResult:Add(cFaturas + "Arquivo de log gerado em: '" + GFELog065:cFullFile)

					GW6->( dbSetOrder(1) )
					If GW6->( dbSeek(aReg[nX][1] + aReg[nX][2] + aReg[nX][3] + aReg[nX][4] + DToS(dData)) )
						RecLock("GW6", .F.)
							GW6->GW6_VLFATU := aDocsVal[1]
							GW6->GW6_VLICMS := aDocsVal[2]
							GW6->GW6_VLICRE := aDocsVal[3]
							GW6->GW6_VLISS  := aDocsVal[4]
							GW6->GW6_VLISRE := aDocsVal[5]
						GW6->(MSUnlock())

						GFEA070CO() //Conferência da Fatura
					EndIf
				EndIf
			Else
				// Recupera as mensagens de erro
				If !Empty(aErro)
					aAdd(aErro, oModelGW6:GetErrorMessage())
				Else
					aErro := oModelGW6:GetErrorMessage()
				EndIf

				aAdd(aErros, aErro)

				GFELog065:NewLine()
				GFELog065:Add("** " + "Erro na inclusão da fatura de frete: '" + AllTrim(aReg[nX][2]) + "'. Motivo: " + aErro[6] + CRLF, 1)
				GFEResult:AddErro("Erro na inclusão da fatura de frete: '" + AllTrim(aReg[nX][2]) + "'. Motivo: " + aErro[6] + CRLF)
			EndIf

			oModelGW6:DeActivate()

			GFELog065:NewLine()
			GFELog065:Add(Replicate(".", 120))
			GFELog065:NewLine()
			GFELog065:Save()
		Next nX

		If !IsBlind()
			If !Empty(aErros)
				GFEResult:Show("Criação automática de Faturas de Frete", "Faturas", "Erros",;
				"Ocorreram erros na geração de um ou mais documentos. Clique no botão 'Erros' para mais detalhes."+ CRLF +;
				"Arquivo de log gerado em: '" + GFELog065:cFullFile)
			Else
				GFEResult:Add("Faturas(s) de Frete gerada(s) com sucesso." )
				GFEResult:Add("" )
				GFEResult:Show("Criação automática de Faturas de Frete", "Faturas", "Erros",;
				"Arquivo de log gerado em: '" + GFELog065:cFullFile)
			EndIf
		Endif
		GFELog065:EndLog()
	Else
		If !IsBlind()
			GFEResult:AddErro("Não foram encontrados documentos de frete para permitir a geração da fatura" )

			GFEResult:Show("Criação automática de Faturas de Frete","Faturas", "Erros",;
			"Não foram encontrados documentos de frete para permitir a geração da fatura")
		Endif
	EndIf

	aSize(aDocsVal,0)
	aDocsVal := nil
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGW8
Criação do objeto Struct
Uso restrito

@sample
BscStrGW8( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function BscStrGW8( cCampo )
	Local aCampos := {}
	Local lRet    := .F.

	aAdd( aCampos, 'GW8_FILIAL')
	aAdd( aCampos, 'GW8_CDTPDC')
	aAdd( aCampos, 'GW8_EMISDC')
	aAdd( aCampos, 'GW8_SERDC ')
	aAdd( aCampos, 'GW8_NRDC  ')
	aAdd( aCampos, 'GW8_ITEM  ')
	aAdd( aCampos, 'GW8_SEQ   ')
	aAdd( aCampos, 'GW8_INFO1 ')
	aAdd( aCampos, 'GW8_CFOP  ')

	lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )
Return lRet

/*------------------------------------------------------------------------------------------------*/

Function GFEA065VP(oModel, oViewImp)
	Local aArea         := GetArea()
	Local aAreaGW3      := GW3->( GetArea() )
	Local aAreaGW4      := GW4->( GetArea() )
	Local nOpc          := (oModel:GetOperation())
	Local lAprovar      := .F.
	Local nCont         := 0
	Local nQtdPISCOF    := 0
	Local nQtdTotal     := 0 //Acumulador dos atributos dos itens para rateio
	Local oModelGW4     := oModel:GetModel("GFEA065_GW4")
	Local oModelGW3     := oModel:GetModel("GFEA065_GW3")
	Local nVlPIS        := 0
	Local nVlCO         := 0
	Local nVlBasePIS    := 0
	Local nVlBaseCO     := 0
	Local nVlDoc        := 0
	Local nLine         := 0
	Local lTemDC        := .F.
	Local nI            := 0
	Local cChaveDF      := ""
	Local cUniDF        := SuperGetMV("MV_GFEVLDT",.F.,"3")
	Local cCredIcms     := SuperGetMV("MV_GFECRIC",.F.,"1")
	Local cIcmsSt       := SuperGetMV("MV_ICMSST" ,.F.,"1")
	Local aFil          := GFEGETFIL(cEmpAnt)
	Local lDCUsoCons    := .F.
	Local cCredPC       := ""
	Local cChvCte       := FwFldGet("GW3_CTE")
	Local cTpCte        := FwFldGet("GW3_TPCTE")
	Local cEmissor      := FwFldGet("GW3_EMISDF")
	Local cSerie        := FwFldGet("GW3_SERDF")
	Local cNumero       := FwFldGet("GW3_NRDF")
	Local dDataEmis     := FwFldGet("GW3_DTEMIS")
	Local aRetVldCte    := {}
	Local aRet          := {.T.,"",""}
	Local cCdEsp        := FwFldGet("GW3_CDESP" )
	Local lNfEnt        := .F. //Variavel que indica se existem notas fiscais de entrada associadas ao documento de frete
	Local lChvCte       := .F. //Campo Chave Ct-e existe na GVT
	Local cCredPCTF     := ""
	Local aGVTStruct    := {}
	Local lTribPC       := .F.
	Local lTrechoPC     := .F.
	Local lEspCTe       := .T.
	Local lEmiCTe       := .F.
	Local lCusto        := .F.
	Local cNrDF         := ""
	Local nQtAlg        := 0
	Local lRetPE        := .F.
	Local cCidRem       := ""
	Local cCidDes       := ""
	Local cCidTrp       := ""
	Local cCidFil       := ""
	Local cCFOFR1       := SuperGetMV("MV_CFOFR1",.T.,"")
	Local cCFOFR2       := SuperGetMV("MV_CFOFR2",.T.,"")
	Local cCFOFR3       := SuperGetMV("MV_CFOFR3",.T.,"")
	Local cCFOFR4       := SuperGetMV("MV_CFOFR4",.T.,"")
	Local nERP          := SuperGetMV("MV_ERPGFE",.T.,"2")
	Local cTpImp        := ""
	Local aForLoj       := ""
	Local cTes          := ""
	Local cTesAuto      := SuperGetMV("MV_TESGFE",.T.,"1")
	Local lCpoTES       := GFEA065INP()
	Local lAspaInic     := .F.
	Local lAspaFim      := .F.
	Local cFormCredICMS := SuperGetMV("MV_CRDPAR",.F.,"1")
	Local lCrdSim       := .F.
	Local nLinha        := 0
	Local aArrFil       := {}
	Local lAprovMLA     := SuperGetMv("MV_ERPGFE",.F.,"1") == "1" .And. SuperGetMv("MV_DFMLA",.F.,"1") $ "2|3"
	Local aGFEA659      := {}
	Local cFGER         := ""
	Local lConsumo      := .F.
	Local lAtivo        := .F.
	Local nLenGW4       := 0
	Local nLenAfil      := 0
	Local cMsg          := ""
	Local cSolucao      := ""
	Local cCodUsr       := RetCodUsr()
	Local cAliasGWU     := Nil
	Local cAliasGU3     := Nil
	Local aMsgTES       := {}

	Private cMotBloq    := ""
	Private nVlDiver    := 0
	Private cSitTab     := ""

	Private lBloqEntrega := .F.
	Private lBloqSeFaz   := .F.

	aGVTStruct := GVT->( dbStruct() )

	IIf (nOpc == MODEL_OPERATION_UPDATE, cSitAnt := GW3->GW3_SIT, cSitAnt := "")
	If GFXCP12117("GW3_SITCUS")
		IIf (nOpc == MODEL_OPERATION_UPDATE, cSitCusAnt := GW3->GW3_SITCUS, cSitCusAnt := "")
	EndIf

	If nOpc != MODEL_OPERATION_DELETE
		lChvCte := AScan(aGVTStruct, {|x| x[1] == "GVT_CHVCTE"}) != 0
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		If GFXCP12123("GW3_USO")
			//Verifica se existem notas de entrada associadas ao documento de frete.
			If !oModelGW4:IsEmpty()
				nLenGW4 := oModelGW4:Length()
				GW1->( dbSetOrder(1) )
				For nI := 1 To nLenGW4
					oModelGW4:GoLine(nI)
					If !oModelGW4:IsDeleted()
						If !oModelGW4:IsDeleted()
							GW1->( dbSetOrder(1) )
							If GW1->( dbSeek(xFilial("GW1") + oModelGW4:GetValue("GW4_TPDC") + oModelGW4:GetValue("GW4_EMISDC") + ;
									 oModelGW4:GetValue("GW4_SERDC") + oModelGW4:GetValue("GW4_NRDC")) )
								If GW1->GW1_USO == "2"
									lConsumo := .T.
								ElseIf GW1->GW1_USO == "3"
									lAtivo := .T.
								EndIf
							EndIf
						EndIf
					EndIf
				Next nI
				oModelGW4:GoLine(nLine)
			EndIf

			If lAtivo
				oModelGW3:SetValue("GW3_USO", "3")
			ElseIf lConsumo
				oModelGW3:SetValue("GW3_USO", "2")
			Else
				oModelGW3:SetValue("GW3_USO", "1")
			EndIf
		EndIf

		//Validação para atribuir o CFOP, caso ainda não tenha sido preenchido.
		//Chamado TPPVFL.
		If Empty(oModelGW3:GetValue("GW3_CFOP"))

			If !Empty(oModelGW3:GetValue("GW3_MUNINI")) .And. !Empty(oModelGW3:GetValue("GW3_UFINI")) 
				cCidRem := oModelGW3:GetValue("GW3_MUNINI")
			EndIF

			If !Empty(oModelGW3:GetValue("GW3_MUNFIM")) .And. !Empty(oModelGW3:GetValue("GW3_UFFIM"))
				cCidDes := oModelGW3:GetValue("GW3_MUNFIM")
			EndIf 

			If Empty(cCidRem)
				GW1->( dbSetOrder(1) )
				GW1->( dbSeek(If(Empty(FwFldGet("GW4_FILIAL")),xFilial("GW4"),FwFldGet("GW4_FILIAL"))+FwFldGet("GW4_TPDC")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC")) )
				GWH->( dbSetOrder(2) )
				If GWH->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) )
					// Procura em todos os Cálculos de Documento de Carga, um que o Tipo de Cálculo, seja igual ao Tipo de Cálcudo do Documento de Frete
					Do While !GWH->(Eof()) .And. GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC
						GWF->( dbSetOrder(1) )
						If GWF->( dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC) )

							//Procura por todos os trechos, pois pode haver mais de um trecho com o mesmo transportador (por exemplo, importação,
							//onde há um trecho internacional e outro estadual/interestadual.
							cAliasGWU := GetNextAlias()
							BeginSql Alias cAliasGWU
								SELECT GWU.R_E_C_N_O_ RECNOGWU
								FROM %Table:GWU% GWU
								WHERE GWU.GWU_FILIAL = %xFilial:GWU%
								AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(GWF->GWF_TRANSP)%)
								AND GWU.GWU_CDTPDC = %Exp:oModelGW4:GetValue("GW4_TPDC")%
								AND GWU.GWU_EMISDC = %Exp:oModelGW4:GetValue("GW4_EMISDC")%
								AND GWU.GWU_SERDC = %Exp:oModelGW4:GetValue("GW4_SERDC")%
								AND GWU.GWU_NRDC = %Exp:oModelGW4:GetValue("GW4_NRDC")%
								AND GWU.GWU_SEQ = %Exp:GWF->GWF_SEQTRE%
								AND GWU.%NotDel%
							EndSql
							If (cAliasGWU)->(!Eof())
								// Compara o cálculo do Documento de Carga com o de Documento de Frete
								If FwFldGet("GW3_TPDF") == GWF->GWF_TPCALC .AND. (!GFXCP12117("GW3_CDTPSE") .Or. FwFldGet("GW3_CDTPSE") == GWF->GWF_CDTPSE)
									cCidRem := GWF->GWF_CIDORI
									cCidDes := GWF->GWF_CIDDES
								EndIf
							EndIf
							(cAliasGWU)->(dbCloseArea())
						EndIf
						GWH->( dbSkip() )
					EndDo
				EndIf
			EndIf

			If Empty(cCidRem)
				cAliasGWU := GetNextAlias()
				BeginSql Alias cAliasGWU
					SELECT GWU.GWU_NRCIDO,
							GWU.GWU_NRCIDD
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_CDTRP = %Exp:oModelGW3:GetValue("GW3_EMISDF")%
					AND GWU.GWU_FILIAL = %xFilial:GWU%
					AND GWU.GWU_CDTPDC = %Exp:oModelGW4:GetValue("GW4_TPDC") %
					AND GWU.GWU_EMISDC = %Exp:oModelGW4:GetValue("GW4_EMISDC")%
					AND GWU.GWU_SERDC = %Exp:oModelGW4:GetValue("GW4_SERDC")%
					AND GWU.GWU_NRDC = %Exp:oModelGW4:GetValue("GW4_NRDC")%
					AND GWU.%NotDel%
				EndSql
				If (cAliasGWU)->(!Eof())
					cCidRem := (cAliasGWU)->GWU_NRCIDO
					cCidDes := (cAliasGWU)->GWU_NRCIDD
				EndIf
				(cAliasGWU)->(dbCloseArea())

				// Carrega cidade origem
				If Empty(cCidRem)
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3.GU3_NRCID
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_CDEMIT = %Exp:oModelGW3:GetValue("GW3_CDREM")%
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cCidRem := (cAliasGU3)->GU3_NRCID
					EndIf
					(cAliasGU3)->(dbCloseArea())
				EndIf
				// Carrega cidade destino
				If Empty(cCidDes)
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3 
						SELECT GU3.GU3_NRCID
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_CDEMIT = %Exp:oModelGW3:GetValue("GW3_CDDEST")%
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cCidDes := (cAliasGU3)->GU3_NRCID
					EndIf
					(cAliasGU3)->(dbCloseArea())
				EndIf
			EndIf

			If FwFldGet("GW3_TPIMP") == '2'
				aArrFil := FWArrFilAtu()

				cCidTrp := Posicione("GU3",1,XFILIAL("GU3")+oModelGW3:GetValue("GW3_EMISDF"),"GU3_NRCID")
				cCidFil := Posicione("GU3",11,XFILIAL("GU3")+aArrFil[18],"GU3_NRCID")

				If Empty(FwFldGet("GW3_CFOP")) .And. Posicione("GU7",1, xfilial("GU7")+cCidFil, "GU7_NRCID") == Posicione("GU7",1, xfilial("GU7")+cCidTrp, "GU7_NRCID")
					oModelGW3:LoadValue("GW3_CFOP", cCFOFR3)
				ElseIf Empty(FwFldGet("GW3_CFOP"))
					oModelGW3:LoadValue("GW3_CFOP", cCFOFR4)
				EndIf
			Else
				If Posicione("GU7",1, xfilial("GU7")+cCidRem, "GU7_CDUF") == Posicione("GU7",1, xfilial("GU7")+cCidDes, "GU7_CDUF")
					oModelGW3:LoadValue("GW3_CFOP", cCFOFR1)
				Else
					oModelGW3:LoadValue("GW3_CFOP", cCFOFR2)
				EndIf
			EndIf

			aSize(aArrFil,0)
		EndIf

		/* Alteração referente a validação Tipo CT-e - Chamado TQDIGM */
		GVT->( dbSetOrder(1) )
		If GVT->( dbSeek(xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP")))
			If GVT->(FieldPos("GVT_CHVCTE")) > 0 .And. GVT->GVT_CHVCTE == "3"
				lEspCTe := .F.
			EndIf
		EndIf

		GU3->( dbSetOrder(1) )
		If GU3->( dbSeek(xFilial("GU3") + oModelGW3:GetValue("GW3_EMISDF")))
			If GU3->GU3_CTE == "1"
				lEmiCTe := .T.
			EndIf
		EndIf

		If !Empty(cChvCte) .And. lEspCTe .And. lEmiCTe
			If GFE065VLDV(cChvCte) .and. Empty(cTpCte) .and. !IsInCallStack("GFEA115PRO")
				cMsg     := "Tipo do CT-e em branco."
				cSolucao := "É necessário preencher o tipo do CT-e."
				oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
				Return .F.
			EndIf
		EndIf

		If oModelGW3:GetValue("GW3_TPDF") != "3" .And. oModelGW3:GetValue("GW3_VLDF") == 0
			cMsg     := "Não é permitido criar um documento de frete deste tipo com valor zerado."
			cSolucao := ""
			oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
			Return .F.
		EndIf

		If GFXTB12117("GWC") .And. GFEA065CTA()
			If AllTrim(FwFldGet("GW3_DESCUS")) == ""
				cMsg     := "Necessário preencher o código da despesa de custo de frete."
				cSolucao := ""
				oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
				Return .F.
			EndIf

			If AllTrim(Posicione("DT7",1,xFilial("DT7")+FwFldGet("GW3_DESCUS"), "DT7_CODDES")) == ""
				cMsg     := "Despesa de custo de frete não cadastrado no Protheus."
				cSolucao := ""
				oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
				Return .F.
			EndIf
		EndIf

		If !oModelGW4:IsEmpty()
			nLenGW4 := oModelGW4:Length()
			For nI := 1 To nLenGW4
				oModelGW4:GoLine(nI)
				If !oModelGW4:IsDeleted()
					If !GFEA065GW1( IIf(Empty(oModelGW4:GetValue("GW4_FILIAL")),xFilial("GW4"),oModelGW4:GetValue("GW4_FILIAL")),;
									oModelGW4:GetValue("GW4_TPDC"),;
									oModelGW4:GetValue("GW4_EMISDC"),;
									oModelGW4:GetValue("GW4_SERDC"),;
									oModelGW4:GetValue("GW4_NRDC"))
						Return .F.
					EndIf
					// Verifica se há trechos no documento de entrada
					If !GFEA065VTR( oModelGW3:GetValue("GW3_TPDF"),;
									oModelGW3:GetValue("GW3_EMISDF"),;
									oModelGW3:GetValue("GW3_NRDF"),;
									oModelGW4:GetValue("GW4_FILIAL"),;
									oModelGW4:GetValue("GW4_TPDC"),;
									oModelGW4:GetValue("GW4_EMISDC"),;
									oModelGW4:GetValue("GW4_SERDC"),;
									oModelGW4:GetValue("GW4_NRDC"))
						Return .F.
					EndIf
				EndIf
			Next nI
			oModelGW4:GoLine(nLine)
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_INSERT
		// Tipo do CT-e
		If Empty(oModelGW3:GetValue("GW3_CTE")) .and. IsInCallStack("GFEA065")
			oModelGW3:LoadValue("GW3_TPCTE", "")
		EndIf

		//Número do Documento de Frete
		If AScan(aGVTStruct, {|x| x[1] == "GVT_FORMNM"}) != 0
			GVT->( dbSetOrder(1) )
			If GVT->( dbSeek(xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP")) )

				cNrDF  := AllTrim(oModelGW3:GetValue("GW3_NRDF"))
				nQtAlg := Iif(GVT->GVT_QTALG > 0, GVT->GVT_QTALG, TamSX3("GW3_NRDF")[1])

				// Zeros à esquerda = 2 - Retirar ou 3 - Preencher
				If GVT->GVT_ZEROS $ "2|3"
					cNrDF := GFEZapZero(cNrDF)
					If GVT->GVT_ZEROS == "3" .And. Len(cNrDF) < nQtAlg
						cNrDF := PadL(cNrDF, nQtAlg, "0")
					EndIf
				EndIf

				If Len(cNrDF) > nQtAlg
					oModel:SetErrorMessage(,,,,,"A quantidade de caracteres no Número do Documento de Frete ultrapassa o delimitado no cadastro da Espécie.","Informe um número com quantidade menor de caracteres.")
					Return .F.
				EndIf

				// Preenche o campo número do documento com o valor da variável formatada
				oModelGW3:LoadValue("GW3_NRDF", cNrDF)

				/* - Validação de aspa simples " ' " no começo da string ou no final da string
					feita para evitar mensagem de erro em tela
				*/
lAspaInic := SUBSTR(AllTrim(oModelGW3:GetValue("GW3_NRDF")),1,1) == "'"
lAspaFim  := SUBSTR(AllTrim(oModelGW3:GetValue("GW3_NRDF")),Len(AllTrim(oModelGW3:GetValue("GW3_NRDF"))),1) == "'"

If  lAspaInic .Or. lAspaFim
	If GVT->GVT_FORMNM == "1"
		oModel:SetErrorMessage(,,,,,"Número do Documento de Frete com algarismos em formato diferente do parametrizado no cadastro de Espécie.","Informe um número com algarismos em formato compatível com o parametrizado no cadastro de Espécie do Documento de Frete.")
		Return .F.
	ElseIf GVT->GVT_FORMNM == "2"
		oModel:SetErrorMessage(,,,,,"Número do Documento de Frete com algarismos ou letras em formato diferente do parametrizado no cadastro de Espécie.","Informe um número com algarismos ou letras em formato compatível com o parametrizado no cadastro de Espécie do Documento de Frete.")
		Return .F.
		//Substituição de aspas simples por aspas duplas, no inicio e no final da string
	ElseIf GVT->GVT_FORMNM == "3"
		If lAspaInic .AND.  !lAspaFim
			oModelGW3:LoadValue("GW3_NRDF",'"'+SUBSTR(AllTrim(oModelGW3:GetValue("GW3_NRDF")),2,LEN(AllTrim(oModelGW3:GetValue("GW3_NRDF")))))
		ElseIf !lAspaInic .AND. lAspaFim
			oModelGW3:LoadValue("GW3_NRDF",SUBSTR(AllTrim(oModelGW3:GetValue("GW3_NRDF")),1,LEN(AllTrim(oModelGW3:GetValue("GW3_NRDF")))-1)+'"')
		ElseIf lAspaInic .AND. lAspaFim
			oModelGW3:LoadValue("GW3_NRDF",'"'+SUBSTR(AllTrim(oModelGW3:GetValue("GW3_NRDF")),2,LEN(AllTrim(oModelGW3:GetValue("GW3_NRDF")))-1)+'"')
		EndIf
	EndIf
EndIf

If GVT->GVT_FORMNM == "1" .And. !GFEVldForm(AllTrim(oModelGW3:GetValue("GW3_NRDF")), "IsDigit")
	oModel:SetErrorMessage(,,,,,"Número do Documento de Frete com algarismos em formato diferente do parametrizado no cadastro de Espécie.","Informe um número com algarismos em formato compatível com o parametrizado no cadastro de Espécie do Documento de Frete.")
Return .F.
ElseIf GVT->GVT_FORMNM == "2" .And. !GFEVldForm(AllTrim(oModelGW3:GetValue("GW3_NRDF")), "LetterOrNum")
	oModel:SetErrorMessage(,,,,,"Número do Documento de Frete com algarismos ou letras em formato diferente do parametrizado no cadastro de Espécie.","Informe um número com algarismos ou letras em formato compatível com o parametrizado no cadastro de Espécie do Documento de Frete.")
Return .F.
EndIf
EndIf
EndIf

If Empty(cUniDF)
	cUniDF := "3"
EndIf

If cUniDF == "1"
	cChaveDF := (oModelGW3:GetValue("GW3_NRDF"))
ElseIf cUniDF == "2"
	cChaveDF := (oModelGW3:GetValue("GW3_NRDF")) + (oModelGW3:GetValue("GW3_SERDF"))
ElseIf cUniDF == "3"
	cChaveDF := (oModelGW3:GetValue("GW3_NRDF")) + (oModelGW3:GetValue("GW3_SERDF")) + DToS(oModelGW3:GetValue("GW3_DTEMIS"))
EndIf

GW3->( dbSetOrder(11) )
nLenAfil := Len(aFil)
For nI := 1 To nLenAfil
	If GW3->( dbSeek(aFil[nI][1] + oModelGW3:GetValue("GW3_CDESP") + oModelGW3:GetValue("GW3_EMISDF") + cChaveDF) )
		oModel:SetErrorMessage(,,,,,"Já existe Documento de Frete cadastrado com a chave informada na Filial " + Iif(aFil[nI][1] == cFilAnt, "corrente", aFil[nI][1] + " - " + aFil[nI][2]),"Verifique se os dados informados estão corretos.")
		RestArea(aAreaGW3)
		RestArea(aAreaGW4)
		Return .F.
	EndIf
Next

If oModelGW3:GetValue("GW3_TPDF") <> "7" .And.  Posicione("GU3", 1, xFilial("GU3")+oModelGW3:GetValue("GW3_EMISDF"), "GU3_TRANSP")  <> "1"
	oModel:SetErrorMessage(,,,,,"[" + GFEA065017 + "] " + STR0531,STR0532) //"Emitente ou Tipo incorreto" // "Emitente diferente de transportador, somente é possível utilizar para o tipo igual a Serviço."
Return .F.
EndIf

cValDF := AllTrim(oModelGW3:GetValue("GW3_NRDF"))
oModelGW3:SetValue("GW3_NRDF",cValDF)

cValSerDF := AllTrim(oModelGW3:GetValue("GW3_SERDF"))
oModelGW3:SetValue("GW3_SERDF",cValSerDF)

RestArea(aAreaGW3)
RestArea(aAreaGW4)
EndIf

lConferiu := .F.

If !IsInCallStack("GFEA065In") //Se não houver chamada da função de integração
	oModelGW4 := oModel:GetModel("GFEA065_GW4")
	nLine     := oModelGW4:GetLine()
	If nOpc == MODEL_OPERATION_INSERT
		//Crédito PC
		cCredPC   := SuperGetMV("MV_GFEPC" ,.F.,"1",cFilAnt)
		cCredPCTF := SuperGetMV("MV_PICOTR",.F.,"2",cFilAnt)

		If Empty(cCredPC)
			cCredPC := "1"
		EndIf

		If Empty(cCredPCTF)
			cCredPCTF := "2"
		EndIf

		If cCredPC == "1"
			If (Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDREM"), "GU3->GU3_EMFIL") == "1" .And. ;
					Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDDEST"), "GU3->GU3_EMFIL") == "1")
				If SubStr(Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDREM"), "GU3->GU3_IDFED"), 1, 8) == ;
						SubStr(Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDDEST"), "GU3->GU3_IDFED"), 1, 8) .And. ;
						cCredPCTF == "2"

					oModelGW3:LoadValue("GW3_CRDPC", "2")
				Else
					oModelGW3:LoadValue("GW3_CRDPC", "1")
				EndIf
			Else
				oModelGW3:LoadValue("GW3_CRDPC", "1")
			EndIf
		EndIf

		//Verifica se existem notas de entrada associadas ao documento de frete.
		If !oModelGW4:IsEmpty()
			GV5->(dbSetOrder(1))
			nLenGW4 := oModelGW4:Length()
			For nI := 1 To nLenGW4
				oModelGW4:GoLine(nI)
				If !oModelGW4:IsDeleted()
					If GV5->(dbSeek(xFilial("GV5")+oModelGW4:GetValue("GW4_TPDC")))
						If GV5->GV5_SENTID == "1"
							lNfEnt := .T.
						EndIf
						If GV5->GV5_FRCTB == "2"
							lCusto := .T.
						EndIf
						If GV5->GV5_FRCTB == "4"
							If GFXCP12123("GW3_USO") .And. oModelGW3:GetValue("GW3_USO") == "1"
								lCusto := .T.
							EndIf
						EndIf
						If lNfEnt .And. lCusto
							Exit
						EndIf
					EndIf
				EndIf
			Next nI
			oModelGW4:GoLine(nLine)
		EndIf

		GVT->( dbSetOrder(1) )
		If GVT->( dbSeek(xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP")) ) .And. GVT->GVT_TPIMP == "3"
			// Quando a espécie não possui nenhum imposto, o documento de frete não é integrado ao ERP
			oModelGW3:LoadValue("GW3_SITFIS", "6")
			oModelGW3:LoadValue("GW3_SITREC", "6")
		Else
			// Atribui o valor aos campos GW3_SITFIS e GW3_SITREC de acordo com o ERP integrado
			// e o parâmetro MV_ATUCTRC(1=Atualiza pelo GFE","2=Atualiza pelo Recebimento")
			If (nERP == "1" .And. (!lCusto .Or. (oModelGW3:GetValue("GW3_TPDF") == "3" .And. oModelGW3:GetValue("GW3_VLDF") == 0)));
					.Or. (nERP == "2" .And. !lCusto)
				oModelGW3:SetValue("GW3_SITFIS", "1") // Não enviado
				oModelGW3:SetValue("GW3_SITREC", "6") // Não se Aplica
			ElseIf (nERP == "1" .Or. nERP == "2") .And. lCusto
				oModelGW3:SetValue("GW3_SITFIS", "6") // Não se Aplica
				oModelGW3:SetValue("GW3_SITREC", "1") // Não enviado
			Else
				oModelGW3:SetValue("GW3_SITREC", "1") // Não Enviado
				oModelGW3:SetValue("GW3_SITFIS", "1") // Não Enviado
			EndIf
		EndIf

		//Atualiza o campo tipo de contabilização
		oModelGW3:SetValue('GW3_TPCTB', Iif(lCusto,'2','1'))
	EndIf

	// Alteração referente a Edição de um documento de frete que seja vinculado a uma nota
	// de Uso e Consumo, sendo necessário que essa informação seja gravada também na alteração
	// do documento de frete. Trecho abaixo foi retirado do If que contempla apenas a inserção
	// de um novo documento, isto foi feito para minimizar qualquer risco de alterar um outro
	// campo, como o Credita PIS/COFINS.
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		If !oModelGW4:IsEmpty()
			oModelGW4:GoLine(1)
			If !oModelGW4:IsDeleted()
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek(xFilial("GW1") + oModelGW4:GetValue("GW4_TPDC") + oModelGW4:GetValue("GW4_EMISDC") + ;
						oModelGW4:GetValue("GW4_SERDC") + oModelGW4:GetValue("GW4_NRDC")) ) .And. GW1->GW1_USO == "2"
					lDCUsoCons := .T.
				EndIf
			EndIf
			oModelGW4:GoLine(nLine)
		EndIf
	EndIf

	If nOpc != MODEL_OPERATION_DELETE
		// Ponto de entrada que permite substituir a validação padrão que identifica
		// se o documento de frete possui documentos de carga relacionados
		If ExistBlock("GFEA0656")
			lRetPE := ExecBlock("GFEA0656",.F.,.F.)
			If ValType(lRetPE) == "L" .And. !lRetPE
				Return .F.
			EndIf
		Else
			If !oModelGW4:IsEmpty()
				nLenGW4 := oModelGW4:Length()
				For nI := 1 To nLenGW4
					oModelGW4:GoLine(nI)
					If !oModelGW4:IsDeleted() .And. !Empty(oModelGW4:GetValue("GW4_NRDC"))
						lTemDC := .T.
						Exit
					EndIf
				Next nI

				oModelGW4:GoLine(nLine)

				If !lTemDC
					oModel:SetErrorMessage(,,,,,"["+GFEA065002+"] "+STR0502,STR0503) //"Não existem Documentos de Carga relacionados ao Documento de Frete." , "Relacione um Documento de Carga para concluir a inclusão/alteração do Documento de Frete."
					Return .F.
				EndIf
			Else
				oModel:SetErrorMessage(,,,,,"["+GFEA065002+"] "+STR0502,STR0503) //"Não existem Documentos de Carga relacionados ao Documento de Frete." , "Relacione um Documento de Carga para concluir a inclusão/alteração do Documento de Frete."
				Return .F.
			EndIf
		EndIf

		//Ponto de Entrada Britania
		If ExistBlock("XGFEMODE")
			cRet := ExecBlock("XGFEMODE",.f.,.f.,{oModelGW3, oModelGW4})
			If cRet == .F.
				Return .F.
			EndIf
		EndIf
		//Fim Ponto de Entrada Britania

		// Tributação - Não Tributado ou Isento
		If FwFldGet("GW3_TRBIMP") == "2"/*.OR.FwFldGet("GW3_TRBIMP") == "5"*/
			If FwFldGet("GW3_VLIMP") != 0.OR.FwFldGet("GW3_BASIMP") != 0
				oModel:SetErrorMessage(,,,,,"["+GFEA065003+"] "+STR0504,STR0505) //"Valor e Base de Imposto maiores que zero para Documento de Frete com a tributação igual a 'Isento/Não-tributado'." , "Informe zero no Valor e na Base de Imposto para Documento de Frete com a tributação igual a 'Isento/Não-tributado' ou verifique o tipo de tributação."
				Return .F.
			EndIf
		ElseIf FwFldGet("GW3_TRBIMP") == "6" //Se a tributação for "Outros"
			If FwFldGet("GW3_BASIMP") == 0
				oModel:SetErrorMessage(,,,,,"["+GFEA065004+"] " +STR0506,STR0507) //"Base de Imposto não informada para Documento de Frete com a tributação igual a 'Outros'." , "Informe uma base de imposto maior que zero para o Documento de Frete com a tributação igual a 'Outros' ou verifique o tipo de tributação."
				Return .F.
			EndIf
		Else
			If (FwFldGet("GW3_VLIMP") == 0 .Or. FwFldGet("GW3_BASIMP") == 0 .Or. FwFldGet("GW3_PCIMP") == 0) .And. (FwFldGet("GW3_TRBIMP") != "4" .And. FwFldGet("GW3_TRBIMP") != "3")
				oModel:SetErrorMessage(,,,,,"["+GFEA065001+"] "+STR0500,STR0501) //"Valor, Base e Alíquota de Imposto não informados.", "Informe o Valor, a Base e a Alíquota do Imposto para o Documento de Frete com tributação igual a 'Tributado', 'Substituição Tributária' ou 'Presumido' ou verifique o tipo de tributação."
				Return .F.
			EndIf
		EndIf

			/* Definição Credito ICMS */
		// Definindo o campo CRDICM para os tipos de tributação
		If oModelGW3:GetValue("GW3_TRBIMP") $ "3;4;7"
			// Quando o tipo de tributação for "Substituição Tributária", "Diferida" ou "Presumida"
			// é verificado o parâmetro "ICMS ST", sendo 1 igual a tributado e 2 igual a não
			If (FwFldGet("GW3_VLIMP") == 0 .Or. FwFldGet("GW3_BASIMP") == 0 .Or. FwFldGet("GW3_PCIMP") == 0)
				oModelGW3:LoadValue("GW3_CRDICM", "2")
			Else
				If cIcmsSt == "1"
					oModelGW3:LoadValue("GW3_CRDICM", "1")
				Else
					oModelGW3:LoadValue("GW3_CRDICM", "2")
				EndIf
			EndIf
		ElseIf oModelGW3:GetValue("GW3_TRBIMP") $ "2;6"
			// Quando o tipo for "Isento" ou "Outros", o documento não será tributado
			oModelGW3:LoadValue("GW3_CRDICM", "2")
		Else
			// O else é referente aos valores "Tributado" ou "Reduzido", nesse caso o documento será tributado
			oModelGW3:LoadValue("GW3_CRDICM", "1")
		EndIf
		// Finalizada a definição do crédito de ICMS conforme tipo de tributação

		// Após definir o Crédito de ICMS pelo tipo de tributação, caso esse seja Sim é validado o parâmetro da Forma de Crédito de ICMS
		If oModelGW3:GetValue("GW3_CRDICM") == "1"
			If cCredIcms == "1" //Tributado
				// Este parâmetro indica se o Crédito ICMS é pela Regra Sistema(Crédito Total)
				// ou se é Conforme Itens Nota(Crédito Parcial), respectivamente igual a 1 e 2
				If cFormCredICMS == "2"
					// Opção referente ao Crédito de ICMS Conforme Itens Nota(Crédito Parcial)
					nLinha := 1
					nLenGW4 := 	oModelGW4:GetQtdLine()
					For nLinha := 1 To nLenGW4
						oModelGW4:GoLine( nLinha )
						If !oModelGW4:IsDeleted()
							GW8->( dbSetOrder(2) )
							If GW8->( dbSeek(xFilial("GW8")+FwFldGet("GW4_TPDC", nLinha)+FwFldGet("GW4_EMISDC", nLinha)+FwFldGet("GW4_SERDC", nLinha)+FwFldGet("GW4_NRDC", nLinha)))
								// Percorre todos os itens do documento de carga relacionado ao documento de frete
								Do While !GW8->(Eof()) .And. GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC == ;
										xFilial("GW8")+FwFldGet("GW4_TPDC", nLinha)+FwFldGet("GW4_EMISDC", nLinha)+FwFldGet("GW4_SERDC", nLinha)+FwFldGet("GW4_NRDC", nLinha)
									// Verifica se o item possui a informação de credita ICMS como Sim
									// Caso possua atribui verdadeiro a variável que indica se existe algum item que credita ICMS
									// Senão passa ao próximo item deste documento de carga e depois ao próximo documento de carga do docto frete
									If GW8->GW8_CRDICM == "1"
										// Atribui verdadeiro a variável que indica se existe algum item que credita ICMS
										lCrdSim := .T.
										Exit // Encerra o While dos itens do documento de carga, pois já existe um que credita ICMS
									EndIf
									GW8->(dbSkip())
								EndDo
							EndIf
						EndIf
					Next nLinha

					// Verifica a variável que indica se existe algum item que possua o Crédito de ICMS como Sim
					// Caso não exista o documento de frete não credita ICMS, senão o documento mantém o crédito de ICMS
					If lCrdSim == .F.
						//Credita como Não
						oModelGW3:LoadValue("GW3_CRDICM", "2")
					EndIf
				Else
					// Opção referente ao Crédito de ICMS Regra Sistema(Crédito Total)
					// Verifica se o docto frete possui documentos relacionados que sejam Uso e Consumo
					If lDCUsoCons
						GW1->( dbSetOrder(1) )
						GW1->( dbSeek(xFilial("GW1")+oModelGW3:GetValue("GW3_EMISDF")+oModelGW3:GetValue("GW3_CDESP")+oModelGW3:GetValue("GW3_SERDF")+oModelGW3:GetValue("GW3_NRDF")+DTOS(oModelGW3:GetValue("GW3_DTEMIS"))))
						// Verificação do sentido da nota fiscal, sendo 1 igual a Entrada
						If(Posicione("GV5", 1, xFilial("GV5") + FwFldGet("GW4_TPDC"), "GV5_SENTID") == "1")
							//Credita como Não
							oModelGW3:LoadValue("GW3_CRDICM","2")
						EndIf
					EndIf
				EndIf
			Else
				//Credita como Não
				oModelGW3:LoadValue("GW3_CRDICM","2")
			EndIf
		EndIf
			/* Fim Definição Credito ICMS */
			/* Conferência de Frete */
		// Início Ponto de Entrada
		If ExistBlock("GFEA0659")
			aGFEA659 := ExecBlock("GFEA0659",.f.,.f.,{alltrim(oModelGW3:GetValue("GW3_EMISDF"))})
		EndIF

		If !Empty(aGFEA659)
			oModel:SetValue("GFEA065_GW3","GW3_SIT", aGFEA659[1])
			oModel:SetValue("GFEA065_GW3","GW3_DTAPR",DDATABASE)

			oModel:LoadValue("GFEA065_GW3" ,"GW3_USUBLQ","")
			oModel:SetValue("GFEA065_GW3","GW3_MOTBLQ","")
			oModel:SetValue("GFEA065_GW3","GW3_MOTREC","")
			oModel:SetValue("GFEA065_GW3","GW3_MOTFIS","")

			oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTAPR",aGFEA659[2])
			oModel:LoadValue("GFEA065_GW3" ,"GW3_USUAPR",aGFEA659[3])

		Else // Fim Ponto de Entrada
			lAprovar := GFEA065CO(oModel)
			If !lAprovar
				If lBloqEntrega
					cCodSit := "5"
				Else
					cCodSit := "2"
				EndIf
				oModel:LoadValue("GFEA065_GW3" ,"GW3_SIT"   , cCodSit)
				If lBloqEntrega
					If oModel:GetValue("GFEA065_GW3", "GW3_SIT") == "1"
						oModel:LoadValue("GFEA065_GW3" ,"GW3_SIT"   , "2")
					EndIf
				EndIf
				oModel:LoadValue("GFEA065_GW3" ,"GW3_USUBLQ", cUserName)
				oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTBLQ", cMotBloq)
				oModel:LoadValue("GFEA065_GW3" ,"GW3_DTBLQ" , DDATABASE)

				oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTAPR",'')
				oModel:LoadValue("GFEA065_GW3" ,"GW3_DTAPR" ,CtoD('  /  /  '))
				oModel:LoadValue("GFEA065_GW3" ,"GW3_USUAPR",'')
			Else
				oModel:SetValue("GFEA065_GW3","GW3_SIT", '3')
				oModel:LoadValue("GFEA065_GW3" ,"GW3_USUBLQ","")
				oModel:SetValue("GFEA065_GW3","GW3_MOTBLQ","")
				oModel:SetValue("GFEA065_GW3","GW3_MOTREC","")
				oModel:SetValue("GFEA065_GW3","GW3_MOTFIS","")
				oModel:SetValue("GFEA065_GW3","GW3_DTAPR",DDATABASE)
				oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTAPR",'Aprovado Sistema.')
				oModel:LoadValue("GFEA065_GW3" ,"GW3_USUAPR",UsrFullName(cCodUsr))
			EndIf

			If GFXCP12127("GW3_VLDIV")
				oModel:SetValue("GFEA065_GW3","GW3_VLDIV",nVlDiver)
				oModel:SetValue("GFEA065_GW3","GW3_SITDIV",cSitTab)
			Endif
		EndIf

		If GfeVerCmpo({"GW3_SITMLA","GW3_MOTMLA"})
			// PCREQ-9324 alterar para model
			If lAprovMLA
				If oModel:GetValue("GFEA065_GW3","GW3_SITMLA") == "7"
					oModel:LoadValue("GFEA065_GW3","GW3_SITMLA","8") /* Atualizar registro no mla */
				Else
					oModel:LoadValue("GFEA065_GW3","GW3_SITMLA","2") /*Pendente Atualização */
					oModel:LoadValue("GFEA065_GW3","GW3_MOTMLA","")
				EndIf
			Else
				oModel:LoadValue("GFEA065_GW3","GW3_SITMLA","6") /* Não se aplica. */
				oModel:LoadValue("GFEA065_GW3","GW3_MOTMLA","")
			EndIf
		EndIf
	EndIf

	//Calcula o PIS/COFINS do Documento de Frete
	If (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
			/*Verifica tipo de imposto da especie do documento*/
		GVT->( dbSetOrder(1))
		If GVT->(dbSeek(xFilial("GVT")+cCdEsp))
			If GVT->GVT_TPIMP == "1"
				If Empty(oModelGW3:GetValue("GW3_CTE"))
					If lChvCte .And. ( Posicione("GU3", 1, xFilial("GU3")+oModelGW3:GetValue("GW3_EMISDF"), "GU3_CTE")) == "1" .And. GVT->GVT_CHVCTE == "1"
						oModel:SetErrorMessage(,,,,,"A Chave do CT-e não foi informada.","A Espécie do Documento de Frete obriga a digitação do campo Chave CT-e.")
						Return .F.
					ElseIf Posicione("GU3", 1, xFilial("GU3")+oModelGW3:GetValue("GW3_EMISDF"), "GU3_CTE") == "1" .And. GVT->GVT_CHVCTE == "1"
						oModel:SetErrorMessage(,,,,,"A Chave do CT-e não foi informada.","O Emissor do Documento de Frete está parametrizado para emitir CT-e. O campo Chave CT-e deve ser preenchido.")
						Return.F.
					EndIf
				EndIf

				aRetVldCte := GFE065VCTE(cChvCte, cEmissor, cSerie, cNumero, dDataEmis)
				If !aRetVldCte[1]
					If !(Empty(oModelGW3:GetValue("GW3_CTE"))) .and. (GVT->GVT_CHVCTE == "2") .And. Posicione("GU3", 1, xFilial("GU3")+oModelGW3:GetValue("GW3_EMISDF"), "GU3_CTE") == "1"
						oModel:SetErrorMessage(,,,,,"Chave Ct-e inválida:" + CRLF + aRetVldCte[2],"Informe uma Chave de CT-e válida.")
						Return .F.
					ElseIf ((!lChvCte) .Or. (GVT->GVT_CHVCTE == "1")) .And. Posicione("GU3", 1, xFilial("GU3")+oModelGW3:GetValue("GW3_EMISDF"), "GU3_CTE") == "1"
						oModel:SetErrorMessage(,,,,,"Chave Ct-e inválida:" + CRLF + aRetVldCte[2],"Informe uma Chave de CT-e válida.")
						Return .F.
					EndIf
				Else
					If GFEA065CTE(.T.)
						If lBloqSeFaz
							oModel:LoadValue("GFEA065_GW3" ,"GW3_SIT"   , '2')
							oModel:LoadValue("GFEA065_GW3" ,"GW3_USUBLQ", cUserName)
							oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTBLQ", cMotBloq)
							oModel:LoadValue("GFEA065_GW3" ,"GW3_DTBLQ" , DDATABASE)

							oModel:LoadValue("GFEA065_GW3" ,"GW3_MOTAPR",'')
							oModel:LoadValue("GFEA065_GW3" ,"GW3_DTAPR" ,CtoD('  /  /  '))
							oModel:LoadValue("GFEA065_GW3" ,"GW3_USUAPR",'')
						EndIf
					Else
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If  FwFldGet("GW3_TPDF") == "1"
			nLenGW4 := oModelGW4:GetQtdLine()
			For nCont := 1 To nLenGW4
				oModelGW4:GoLine( nCont )
				If !oModelGW4:isDeleted()
					If !GFEA065GW4( oModelGW3:getValue("GW3_TPDF"),;
							oModelGW3:getValue("GW3_EMISDF"),;
							oModelGW3:getValue("GW3_SERDF"),;
							oModelGW3:getValue("GW3_NRDF"),;
							DtoS(oModelGW3:getValue("GW3_DTEMIS")),;
							oModelGW4:getValue("GW4_EMISDC"),;
							oModelGW4:getValue("GW4_SERDC"),;
							oModelGW4:getValue("GW4_NRDC"),;
							oModelGW4:getValue("GW4_TPDC"),;
							oModelGW3:getValue("GW3_CDESP"))
						Return .F.
					EndIf
				EndIf
			Next nCont
		EndIf
		//Natureza SPED
		cCredPCTF := SuperGetMV("MV_PICOTR",.F.,"2",cFilAnt)
		If Empty(cCredPCTF)
			cCredPCTF := "2"
		EndIf

		If (Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDREM") , "GU3_EMFIL") == "1" .And. ;
				Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDDEST"), "GU3_EMFIL") == "1") .And. ;
				(SubStr(Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDREM"), "GU3->GU3_IDFED"), 1, 8) == ;
				SubStr(Posicione("GU3", 1, xFilial("GU3") + oModelGW3:GetValue("GW3_CDDEST"), "GU3->GU3_IDFED"), 1, 8));

			If cCredPCTF == "2"
				oModelGW3:LoadValue("GW3_NATFRE", "4")
			Else
				oModelGW3:LoadValue("GW3_NATFRE", "0")
				//Trata o campo GW8_TRIBP.
				//For uma transferencia, o parametro está como "Com direito a credito"
				//E a finalidade de uso da nota for "Industrialização".
				GW1->( dbSetOrder(1) )
				GW1->( dbSeek(xFilial("GW1")+oModel:getValue("GFEA065_GW4","GW4_TPDC")+oModel:getValue("GFEA065_GW4","GW4_EMISDC")+oModel:getValue("GFEA065_GW4","GW4_SERDC")+oModel:getValue("GFEA065_GW4","GW4_NRDC")) )
				If GW1->GW1_USO == "1"
					lTribPC := .T.
				EndIf
			EndIf
		ElseIf Posicione("GV5", 1, xFilial("GV5") + oModelGW4:GetValue("GW4_TPDC", 1), "GV5_SENTID") != "1"
			//Chamado TTRDJT.
			If oModelGW3:GetValue("GW3_CRDPC") == "1"
				oModelGW3:LoadValue("GW3_NATFRE", "0")
			Else
				oModelGW3:LoadValue("GW3_NATFRE", "1")
			EndIf
		Else
			If oModelGW3:GetValue("GW3_CRDPC") == "1"
				oModelGW3:LoadValue("GW3_NATFRE", "2")
			Else
				oModelGW3:LoadValue("GW3_NATFRE", "3")
			EndIf
		EndIf

		cParamRat := SuperGetMV('MV_CRIRAT',.F.,'5')
		If cParamRat == '5'
			GFEMsgErro(STR0086) //"Parâmetro MV_CRIRAT (Critério de Rateio) não está cadastrado"
		EndIf

		If cParamRat $ '1;4'
			nLenGW4 := oModelGW4:GetQtdLine()
			For nCont := 1 To nLenGW4
				oModelGW4:GoLine( nCont )
				If !(oModelGW4:IsDeleted(nCont))
					//Verificação para que caso o Parametro de Rateio seja por peso ou volume e os mesmos
					//venham zerados, seja atribuido a quantidade.
					GW8->( dbSetOrder(1))
					GW8->( dbSeek(xFilial("GW8")+oModel:getValue("GFEA065_GW4","GW4_TPDC")+oModel:getValue("GFEA065_GW4","GW4_EMISDC")+oModel:getValue("GFEA065_GW4","GW4_SERDC")+oModel:getValue("GFEA065_GW4","GW4_NRDC")))
					Do While GW8->(!Eof()) .And. xFilial("GW8")+oModel:getValue("GFEA065_GW4","GW4_TPDC")+oModel:getValue("GFEA065_GW4","GW4_EMISDC")+oModel:getValue("GFEA065_GW4","GW4_SERDC")+oModel:getValue("GFEA065_GW4","GW4_NRDC") == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
						If cParamRat == '1' //Peso
							If GW8->GW8_TRIBP == '1'
								If GW8->GW8_PESOR > GW8->GW8_PESOC
									nQtdPISCOF += GW8->GW8_PESOR
								Else
									nQtdPISCOF += GW8->GW8_PESOC
								EndIf
							EndIf
						ElseIf cParamRat == '3' //Volume
							If GW8->GW8_TRIBP == '1'
								nQtdPISCOF += GW8->GW8_VOLUME
							EndIf
						EndIf
						GW8->( dbSkip() )
					EndDo
				EndIf
			Next nCont

			If nQtdPISCOF == 0
				cParamRat := '4'
			Else
				//Zera a variavel para não influenciar no cálculo de PIS e Cofins
				nQtdPISCOF := 0
			EndIf
		EndIf

		//------------------------------------------------//
			/*Alteração referente ao chamado TPREH6 - Britania*/
		If GFEVerCmpo({"GVT_CRDPC"})
			If GVT->GVT_CRDPC == "2"
				oModelGW3:LoadValue("GW3_CRDPC", "1")
			ElseIf GVT->GVT_CRDPC == "3"
				oModelGW3:LoadValue("GW3_CRDPC", "2")
			EndIf
		EndIf
		//-------------------------------------------------//
		nLenGW4 := oModelGW4:GetQtdLine()
		For nCont := 1 To nLenGW4
			oModelGW4:GoLine( nCont )
			If !(oModelGW4:IsDeleted(nCont))
				If IsBlind()
					If !GFEA65CAL(oModelGW4)
						Return .F.
					EndIf
				EndIf

				GW8->( dbSetOrder(1))
				GW8->( dbSeek(xFilial("GW8")+oModel:getValue("GFEA065_GW4","GW4_TPDC")+oModel:getValue("GFEA065_GW4","GW4_EMISDC")+oModel:getValue("GFEA065_GW4","GW4_SERDC")+oModel:getValue("GFEA065_GW4","GW4_NRDC")))
				Do While GW8->(!Eof()) .And. xFilial("GW8")+oModel:getValue("GFEA065_GW4","GW4_TPDC")+oModel:getValue("GFEA065_GW4","GW4_EMISDC")+oModel:getValue("GFEA065_GW4","GW4_SERDC")+oModel:getValue("GFEA065_GW4","GW4_NRDC") == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
					If GW8->GW8_TRIBP == '1'
						lTrechoPC := .T.
					EndIf
					If cParamRat == '1' //Peso
						If GW8->GW8_TRIBP == '1' .Or. lTribPC
							If GW8->GW8_PESOR > GW8->GW8_PESOC
								nQtdPISCOF += GW8->GW8_PESOR
							Else
								nQtdPISCOF += GW8->GW8_PESOC
							EndIf
						EndIf

						If GW8->GW8_PESOR > GW8->GW8_PESOC
							nQtdTotal += GW8->GW8_PESOR
						Else
							nQtdTotal += GW8->GW8_PESOC
						EndIf
					ElseIf cParamRat == '2' //Valor
						If GW8->GW8_TRIBP== '1' .Or. lTribPC
							nQtdPISCOF += GW8->GW8_VALOR
						EndIf

						nQtdTotal += GW8->GW8_VALOR
					ElseIf cParamRat == '4' //Quantidade
						If GW8->GW8_TRIBP== '1' .Or. lTribPC
							nQtdPISCOF += GW8->GW8_QTDE
						EndIf
						nQtdTotal += GW8->GW8_QTDE
					ElseIf cParamRat == '3' //Volume
						If GW8->GW8_TRIBP== '1' .Or. lTribPC
							nQtdPISCOF += GW8->GW8_VOLUME
						EndIf
						nQtdTotal += GW8->GW8_VOLUME
					EndIf
					GW8->( dbSkip() )
				EndDo
			EndIf
		Next nCont

		nVlDoc := oModelGW3:getValue("GW3_VLDF")

		If nVlDoc != 0 .And. M->GW3_PEDAG != 0 .And. Posicione("GVT", 1, xFilial('GVT') + M->GW3_CDESP, "GVT_TPIMP") != '2'
			If M->GW3_PDGFRT == "1" .And. M->GW3_PDGPIS == "2"
				nVlDoc -= M->GW3_PEDAG
			ElseIf M->GW3_PDGFRT == "2" .And. M->GW3_PDGPIS == "1"
				nVlDoc += M->GW3_PEDAG
			EndIf
		EndIf

		If Posicione("GVT", 1, xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP"), "GVT_TPIMP") == "2" .And. SuperGetMV('MV_ISSBAPI',,'2') $ "2N"
			nVlDoc -= oModelGW3:GetValue("GW3_VLIMP")
			If nVlDoc < 0
				nVlDoc := 0
			EndIf
		EndIf

		If Posicione("GVT", 1, xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP"), "GVT_TPIMP") == "1" .And. SuperGetMV('MV_ICMBAPI',,'2') $ "2N"
			nVlDoc -= oModelGW3:GetValue("GW3_IMPRET")
			If nVlDoc < 0
				nVlDoc := 0
			EndIf
		EndIf

		If Posicione("GVT", 1, xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP"), "GVT_TPIMP") == "1" .And.  SuperGetMV('MV_ICMBAPI',,'2') == "3"
			nVlDoc -= oModelGW3:GetValue("GW3_VLIMP")
			If nVlDoc < 0
				nVlDoc := 0
			EndIf
		EndIf

		nVlBasePIS := nVlDoc * nQtdPISCOF / nQtdTotal
		nVlBaseCO  := nVlDoc * nQtdPISCOF / nQtdTotal

		nVlPIS  := GFETratDec((nVlBasePIS * GFEA065PCD("PIS") / 100),0,.T.)
		nVLCO   := GFETratDec((nVlBaseCO  * GFEA065PCD("COFINS") / 100),0,.T.)

		If !lTrechoPC .And. nVlBasePIS == 0 .And. nVlBaseCO == 0
			oModelGW3:LoadValue("GW3_CRDPC", "2")
		Else
			// Não deve gravar valores negativos nos casos em que o documento de frete
			// está sendo integrado com valor do pedágio maior que o total do documento.
			If nVlBasePIS < 0 .And. nVlBaseCO < 0
				nVlBasePIS := 0
				nVlBaseCO  := 0
				nVlPIS     := 0
				nVLCO      := 0
			EndIf
			oModelGW3:SetValue("GW3_BASCOF", nVlBaseCO)
			oModelGW3:SetValue("GW3_VLCOF" , nVlCO)
			oModelGW3:SetValue("GW3_BASPIS", nVlBasePIS)
			oModelGW3:SetValue("GW3_VLPIS" , nVLPIS)
		EndIf

		If oModel:GetValue( 'GFEA065_GW3', 'GW3_NATFRE')== "2" .and. oModel:GetValue( 'GFEA065_GW3', 'GW3_CRDPC') == "2"
			oModelGW3:LoadValue("GW3_NATFRE", "3")
		EndIf
		If oModel:GetValue( 'GFEA065_GW3', 'GW3_NATFRE')== "0" .and. oModel:GetValue( 'GFEA065_GW3', 'GW3_CRDPC') == "2"
			oModelGW3:LoadValue("GW3_NATFRE", "1")
		EndIf

		//Se estiver parametrizado para TES automático, então calcula
		If lCpoTES .And. nERP == "2" .And. (cTesAuto == "1" .Or. cTesAuto == "3")
			aAdd(aMsgTES,STR0105) //-- "Possui campo GW3_TES e parâmetro MV_TESGFE (TES Doc.Frete) está como 1-Atribuído sistema"
			cTes 	 := oModelGW3:GetValue("GW3_TES")
			cTpImp	 := Posicione("GVT", 1, xFilial("GVT") + oModelGW3:GetValue("GW3_CDESP"), "GVT_TPIMP")
			aForLoj  := GFEA055GFL(oModelGW3:GetValue("GW3_EMISDF"))

			If GFXCP12123("GW3_USO")
				cFGer := GFEA065FGER(oModelGW3:GetValue("GW3_NATFRE"),oModelGW3:GetValue("GW3_USO"))
			EndIf

			cItemTes := oModelGW3:GetValue("GW3_PRITDF")
			cTes 	:= GFE065TES(cTes,;
				cTpImp,;
				oModelGW3:GetValue("GW3_TRBIMP"),;
				oModelGW3:GetValue("GW3_CRDICM"),;
				oModelGW3:GetValue("GW3_CRDPC"),;
				aForLoj, ;
				cFGer, ;
				oModelGW3:GetValue("GW3_TPCTB"), ;
				cItemTes, ;
				oModelGW3:GetValue("GW3_CFOP"),;
				aMsgTES)
			oModel:LoadValue("GFEA065_GW3", "GW3_TES", cTes)
		EndIf
	EndIf
	RestArea( aAreaGW4 )
	RestArea( aAreaGW3 )
	RestArea( aArea )
Else
	If nOpc == MODEL_OPERATION_UPDATE
		If oModel:GetValue( 'GFEA065_GW3', 'GW3_SITFIS') $ "25" //"Atualizar Fiscal ERP"
			GFEA065IPG("1",oModel:GetValue( 'GFEA065_GW3', 'GW3_SITFIS'),oModel,@aRet)
			If !Empty(aRet[2])
				If !aRet[1] //Retorno Falso
					oModel:SetValue( 'GFEA065_GW3', 'GW3_SITFIS', "3") //Situação Rejeitado
					oModel:SetValue( 'GFEA065_GW3', 'GW3_MOTFIS', AllTrim(aRet[3]) + CRLF + "Ultima tentativa de integração: " + DtoC(Date()) + " " + Time() )
					oModel:LoadValue( 'GFEA065_GW3', 'GW3_DTFIS' , CtoD("  /  /  "))
				Else //Retorno Verdadeiro
					oModel:SetValue( 'GFEA065_GW3', 'GW3_SITFIS', "4") //Situação Atualizado
					oModel:SetValue( 'GFEA065_GW3', 'GW3_MOTFIS', " ")
					lGfeAtu := .T.
				EndIf
			EndIf
		EndIf

		If oModel:GetValue( 'GFEA065_GW3', 'GW3_SITREC') $ "25" //"Atualizar Aprop Desp ERP"
			GFEA065IPG("2",oModel:GetValue( 'GFEA065_GW3', 'GW3_SITREC'),oModel,@aRet)
			If !Empty(aRet[2])
				If !aRet[1] //Retorno Falso
					oModel:SetValue( 'GFEA065_GW3', 'GW3_SITREC', "3") //Situação Rejeitado
					oModel:SetValue( 'GFEA065_GW3', 'GW3_MOTREC', AllTrim(aRet[3]) + CRLF + "Ultima tentativa de integração: " + DtoC(Date()) + " " + Time() )
					oModel:SetValue( 'GFEA065_GW3', 'GW3_DTREC' , SToD(Space(8)) )
				Else //Retorno Verdadeiro
					oModel:SetValue( 'GFEA065_GW3', 'GW3_SITREC', "4") //Situação Atualizado
					oModel:SetValue( 'GFEA065_GW3', 'GW3_MOTREC', " ")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If nOpc == MODEL_OPERATION_DELETE
	If GFXCP12127("GXZ_NRCT")
		GXZ->( dbSetOrder(2) )
		If GXZ->(dbSeek(GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF))
			GXT->( dbSetOrder(1) )
			If GXT->(dbSeek(GXZ->GXZ_FILIAL + GXZ->GXZ_NRCT))
				RecLock("GXT", .F.)
				GXT->GXT_VLREAL := GXT->GXT_VLREAL - GW3->GW3_VLDF
				GXT->(MsUnLock())
			ElseIf GXT->(dbSeek(xFilial("GXT") + GXZ->GXZ_NRCT))
				RecLock("GXT", .F.)
				GXT->GXT_VLREAL := GXT->GXT_VLREAL - GW3->GW3_VLDF
				GXT->(MsUnLock())
			EndIf
			GW4->(dbSetOrder(1))
			GW4->(dbSeek(xFilial("GW4") + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF))
			Do While GW4->(!Eof()) .And. GW4->(GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF) == GW3->GW3_FILIAL + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek(xFilial("GW4") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )
					GWH->( dbSetOrder(2) )
					If GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
						GWF->( dbSetOrder(1) )
						If GWF->(dbSeek(xFilial("GWF")+GWH->GWH_NRCALC))
							If GWF->GWF_TPCALC == GW3->GW3_TPDF
								GXY->( dbSetOrder(2) )
								If GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
									// Somente se o cálculo estiver no mesmo contrato
									If GXY->GXY_NRCT == GXZ->GXZ_NRCT
										If GXY->GXY_VLPREV > 0
											GXT->( dbSetOrder(1) )
											If GXT->(dbSeek(GXY->GXY_FILIAL+GXY->GXY_NRCT))
												RecLock("GXT", .F.)
												GXT->GXT_VLPREV := GXT->GXT_VLPREV + GXY->GXY_VLPREV
												GXT->(MsUnLock())
											ElseIf GXT->(dbSeek(xFilial("GXT") + GXY->GXY_NRCT))
												RecLock("GXT", .F.)
												GXT->GXT_VLPREV := GXT->GXT_VLPREV + GXY->GXY_VLPREV
												GXT->(MsUnLock())
											EndIf
										EndIf
									EndIf
								Endif
							Endif
						Endif
					EndIf
				EndIf
				GW4->(dbSkip())
			EndDo
			RecLock("GXZ",.F.)
			GXZ->(dbDelete())
			GXZ->(MsUnLocK())
		EndIf
	EndIf

	if GFXCP12131("GZZ_NRDF")
		dbSelectArea("GZZ")
		GZZ->(dbSetOrder(1))
		GZZ->(dbSeek(GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DTOS(GW3->GW3_DTEMIS)))

		While !GZZ->( Eof() ) .And. GZZ->GZZ_FILIAL == GW3->GW3_FILIAL .And. GZZ->GZZ_CDESP == GW3->GW3_CDESP ;
				.AND. GZZ->GZZ_EMISDF == GW3->GW3_EMISDF .And. GZZ->GZZ_SERDF == GW3->GW3_SERDF ;
				.AND. GZZ->GZZ_NRDF == GW3->GW3_NRDF .And. DTOS(GZZ->GZZ_DTEMIS) == DTOS(GW3->GW3_DTEMIS)

			RecLock("GZZ",.F.)
			dbDelete()
			GZZ->(MsUnLock("GZZ"))

			GZZ->( dbSkip() )
		EndDo
	EndIF

EndIf

If !Empty(aMsgTES)
	Private _oGFEXFBFL := GFEXFBFLog():New()
	Private _lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

	_oGFEXFBFL:setSaveLog(_lLogIntP)
	_oGFEXFBFL:setAgrFrt(oModelGW3:GetValue("GW3_NRDF"))
	_oGFEXFBFL:NovoLogInP("GFEA065") //Log de integração com ERP Protheus
	AddToLog(CRLF + STR0129 + CRLF + CRLF) //"Busca da TES e Tipo de Operação:"
	For nI := 1 To Len(aMsgTES)
		AddToLog(aMsgTes[nI]+ CRLF)
	Next nI
	_oGFEXFBFL:SaveLog()
	aMsgTES := {}
EndIf
FwFreeArray(aMsgTES)
Return .T.
//-------------------------------------------------------------------
Static Function GFEVldForm(cStr, cFun)
	Local nI

	For nI := 1 To Len(cStr)
		If &("!" + cFun + "('" + SubStr(cStr, nI) + "')")
			Return .F.
		EndIf
	Next nI
Return .T.

//-------------------------------------------------------------------

Function GFEZapZero(cStr)
	Local nI
	Local nPos := 2

	If SubStr(cStr, 1, 1) != "0"
		Return cStr
	EndIf

	For nI := 2 To Len(cStr)
		If SubStr(cStr, nI, 1) == "0"
			nPos++
		Else
			Exit
		EndIf
	Next nI
Return SubStr(cStr, nPos)

/*-------------------------------------------------------------------
Realiza a gravação do documento de frete na base e chama a rotina de
contabilização
-------------------------------------------------------------------*/
Static Function GFEA065CMT(oModel)
	Local lRet        := .T.
	Local lExistCamp  := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local aRetRateio  := {}
	Local nQtLinhas   := 0
	Local nI          := 1
	Local nF          := 0
	Local oModelGW4   := oModel:getModel("GFEA065_GW4")
	Local oModelGW3   := oModel:getModel("GFEA065_GW3")
	Local aCalcProv   := {} // Receberá os cálculos dos documentos de frete do documento de carga
	Local cCidDest    := ""
	Local cCidEmis    := ""
	Local dDataMod    := oModel:getValue("GFEA065_GW3","GW3_DTENT")
	Local aDadosAgro  := {}
	Local s_CRIRAT    := SuperGetMv("MV_CRIRAT",,"0")
	Local nValorFrt   := 0
	local cCGCCliente := ""
	Local lMV_AGRORI  := SuperGetMv("MV_AGRORI",.F.,.T.)
	Local lMV_SIGAAGR := SuperGetMv("MV_SIGAAGR",.F.,.T.)

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	// Caso seja informada uma data diferente da atual para o
	// documento, deve assumir o que foi informado pelo usuário
	If oModel:getOperation() != MODEL_OPERATION_DELETE .And. dDataDf != dDataMod
		oModel:GetModel('GFEA065_GW3'):SetValue('GW3_DTENT',dDataMod)
	ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:GetModel('GFEA065_GW3'):SetValue('GW3_DTENT',dDataBase)
	EndIf

	If IsInCallStack("GFEA065In")
		If oModel:getOperation() == MODEL_OPERATION_INSERT .OR. oModel:getOperation() == MODEL_OPERATION_UPDATE
			cCidDest := POSICIONE("GU3", 1, xFilial("GU3") + oModel:getValue("GFEA065_GW3","GW3_CDDEST"), "GU3_NRCID")
			oModel:LoadValue("GFEA065_GW3", "GW3_UFDEST", POSICIONE("GU7", 1, xFilial("GU7") + cCidDest, "GU7_CDUF"))
			//Para enviar para o mapa a UF do transportador.
			cCidEmis := Posicione("GU3", 1, oModel:getValue("GFEA065_GW3","GW3_EMISDF"),"GU3_NRCID")
			oModel:LoadValue("GFEA065_GW3", "GW3_UFEMIS", POSICIONE("GU7", 1, xFilial("GU7") + cCidEmis, "GU7_CDUF"))
		EndIf
	EndIf

	If !IsInCallStack("GFEA065In") //Se não houver chamada da função de integração

		// Verifica se há documentos de carga relacionados ao documento de frete
		nF := oModelGW4:getQtdLine()
		For nI := 1 to nF
			// Conta as linhas válidas, ou seja, que não foram deletadas
			if !oModelGW4:isDeleted(nI)
				nQtLinhas++
			EndIf

			If oModelGW4:isDeleted(nI) .OR. oModel:getOperation() == MODEL_OPERATION_DELETE
				// Obtem o número do cálculo normal ao qual o documento de carga está vinculado
				// Como está sendo eliminado do documento de frete, deve reverter a eliminação da provisão
				// ocorrida quando o documento de carga foi vinculado ao documento de frete
				GWH->(dbSetOrder(2))
				If GWH->(dbSeek(xFilial("GWH")+oModelGW4:getValue("GW4_TPDC")+oModelGW4:getValue("GW4_EMISDC")+oModelGW4:getValue("GW4_SERDC")+oModelGW4:getValue("GW4_NRDC")))
					Do While GWH->(!Eof()) .And.;
						xFilial("GWH")                   == GWH->GWH_FILIAL .And.;
						oModelGW4:getValue("GW4_TPDC")   == GWH->GWH_CDTPDC .And.;
						oModelGW4:getValue("GW4_EMISDC") == GWH->GWH_EMISDC .And.;
						oModelGW4:getValue("GW4_SERDC")  == GWH->GWH_SERDC  .And.;
						oModelGW4:getValue("GW4_NRDC")   == GWH->GWH_NRDC

						GWF->(dbSetOrder(1))
						if GWF->(dbSeek(xFilial("GWF")+GWH->GWH_NRCALC))
							If GWF->GWF_TPCALC $ "16" // 1-Normal, 6-Redespacho
								nPos := aScan(aCalcProv,{|x| x == GWF->GWF_NRCALC})
								if nPos == 0
									aAdd(aCalcProv,GWF->GWF_NRCALC)
								EndIf
							EndIf
						EndIf
						GWH->(dbSkip())
					EndDo
				EndIf
			EndIf
		Next nI

		// Documento de frete está sendo eliminado ou todos os documentos de carga foram desvinculados
		If oModel:getOperation() == MODEL_OPERATION_DELETE .OR. nQtLinhas == 0

			// Elimina Rateio Contábeis do Documento de Frete
			GWM->(dbSetOrder(1))
			GWM->(dbSeek(xFilial("GWM")+"2"+oModel:getValue("GFEA065_GW3","GW3_CDESP")+oModel:getValue("GFEA065_GW3","GW3_EMISDF")+oModel:getValue("GFEA065_GW3","GW3_SERDF")+oModel:getValue("GFEA065_GW3","GW3_NRDF")+DTOS(oModel:getValue("GFEA065_GW3","GW3_DTEMIS"))))
			Do While GWM->(!Eof()) .And.;
				GWM->GWM_FILIAL == xFilial("GWM") .And.;
				GWM->GWM_TPDOC  == "2" .And.;
				GWM->GWM_CDESP  == oModel:getValue("GFEA065_GW3","GW3_CDESP" ) .And.;
				GWM->GWM_CDTRP  == oModel:getValue("GFEA065_GW3","GW3_EMISDF") .And.;
				GWM->GWM_SERDOC == oModel:getValue("GFEA065_GW3","GW3_SERDF" ) .And.;
				GWM->GWM_NRDOC  == oModel:getValue("GFEA065_GW3","GW3_NRDF"  ) .And.;
				GWM->GWM_DTEMIS == oModel:getValue("GFEA065_GW3","GW3_DTEMIS")

				If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
					If FindFunction("AGRGFE003")
						aCriaRAt := GFEGetRatVal(s_CRIRAT)

						nVlICMS := aCriaRAt[1]
						nVlPis := aCriaRAt[2]
						nVlCofi := aCriaRAt[3]
						nValorFrt := aCriaRAt[4]

						GW1->( dbSetOrder(1) )
						If GW1->( dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC))
							cCGCCliente := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_IDFED")
						EndIf

						aAdd(aDadosAgro,{GWM->GWM_FILIAL,;
											GWM->GWM_TPDOC,;
											GWM->GWM_EMISDC,;
											GWM->GWM_SERDC,;
											GWM->GWM_NRDC,;
											cCGCCliente,;
											nVlICMS,;
											nVlPis,;
											nVlCofi,;
											nValorFrt,;
											"D" /*DELETE*/ })
					EndIf
				EndIf

				RecLock("GWM",.F.)
					GWM->(dbDelete())
				GWM->(MsUnlock())
				GWM->(dbSkip())
			EndDo

			If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
				If FindFunction("AGRGFE003") .And. !Empty(aDadosAgro)
					AGRGFE003(aDadosAgro)
				EndIf
			EndIf

			// Elimina os Movimentos Contábeis do Documento de Frete
			GWA->(dbSetOrder(3))
			GWA->(dbSeek(xFilial("GWA")+"2"+oModel:getValue("GFEA065_GW3","GW3_NRDF")))
			Do While GWA->(!Eof()) .And.;
				GWA->GWA_FILIAL == xFilial("GWA") .And.;
				GWA->GWA_TPDOC  == "2" .And.;
				GWA->GWA_NRDOC  == oModel:getValue("GFEA065_GW3","GW3_NRDF")

				RecLock("GWA",.F.)
					GWA->(dbDelete())
				GWA->(MsUnlock())
				GWA->(dbSkip())
			EndDo
		EndIf
	EndIf

	If oModel:getOperation() == MODEL_OPERATION_DELETE
		aCalcRel := {}

		If GFXTB12117("GWC")
			GFEA065CTP("E")
		EndIf
	EndIf
	//Trata relacionamento das tabelas GW3 X GWF
	If lExistCamp .And. (lConferiu .Or. oModel:getOperation() == MODEL_OPERATION_DELETE)
		//Apaga as informações do documento de frete que encontram-se no cálculo
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GWF.R_E_C_N_O_ RECNOGWF
			FROM %Table:GWF% GWF
			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
			AND GWF.GWF_CDESP = %Exp:oModelGW3:getValue("GW3_CDESP")%
			AND GWF.GWF_EMISDF = %Exp:oModelGW3:getValue("GW3_EMISDF")%
			AND GWF.GWF_SERDF = %Exp:oModelGW3:getValue("GW3_SERDF")%
			AND GWF.GWF_NRDF = %Exp:oModelGW3:getValue("GW3_NRDF")%
			AND GWF.GWF_DTEMDF = %Exp:DtoS(oModelGW3:getValue("GW3_DTEMIS"))%
			AND GWF.%NotDel%
		EndSql
		Do While (cAliasQry)->(!EoF())
			GWF->(dbGoTo((cAliasQry)->RECNOGWF))
			RecLock("GWF",.F.)
				GWF->GWF_CDESP := ""
				GWF->GWF_EMISDF:= ""
				GWF->GWF_SERDF := ""
				GWF->GWF_NRDF  := ""
				GWF->GWF_DTEMDF:= StoD("  \  \  ")
			GWF->(MsUnlock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

		//Refaz a associação do cálculo com o documento de frete, confome o array de cálculos relacionados ao documento de frete
		nF := Len(aCalcRel)
		For nI := 1 to nF
			GWF->(DBGOTOP())
			GWF->(DBSETORDER(1))
			IF GWF->(dbSeek(xFilial('GWF')+aCalcRel[nI]))
				RecLock("GWF",.F.)
					GWF->GWF_CDESP := oModelGW3:getValue("GW3_CDESP")
					GWF->GWF_EMISDF:= oModelGW3:getValue("GW3_EMISDF")
					GWF->GWF_SERDF := oModelGW3:getValue("GW3_SERDF")
					GWF->GWF_NRDF  := oModelGW3:getValue("GW3_NRDF")
					GWF->GWF_DTEMDF:= oModelGW3:getValue("GW3_DTEMIS")
				GWF->(MsUnlock())
			eNDIF
		Next nI
	EndIf

	aCalcRel := {}
	lConferiu := .F.
	lRet := FWFormCommit(oModel)

	If oModel:getOperation() != MODEL_OPERATION_DELETE .And. GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM")

		GW3->( dbSetOrder(1) )
		If GW3->( dbSeek(xFilial("GW3") + oModel:getValue("GFEA065_GW3", "GW3_CDESP") + oModel:getValue("GFEA065_GW3", "GW3_EMISDF") + oModel:getValue("GFEA065_GW3", "GW3_SERDF") + oModel:getValue("GFEA065_GW3", "GW3_NRDF") + DTos(oModel:getValue("GFEA065_GW3", "GW3_DTEMIS"))) ) ;
		   .And. (Empty(GW3->GW3_MUNINI) .Or. Empty(GW3->GW3_UFINI) .Or. Empty(GW3->GW3_MUNFIM) .Or. Empty(GW3->GW3_UFFIM))

			aAuxCid := GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF)
			If Len(aAuxCid) > 0
				If GW3->GW3_TPDF == "5"
					// Para os documentos de frete que são de devolução, as informações são gravadas invertidas do registrado no documento de carga
					RecLock("GW3", .F.)
						GW3->GW3_MUNINI := Alltrim(aAuxCid[1][2]) 											// Município Início Transporte
						GW3->GW3_UFINI  := Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][2], "GU7_CDUF") 	// UF Início do Transporte
						GW3->GW3_MUNFIM := Alltrim(aAuxCid[1][1]) 											// Município Término do Transporte
						GW3->GW3_UFFIM  := Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][1], "GU7_CDUF") 	// UF Término do Transporte
					GW3->(MsUnlock())
				Else
					RecLock("GW3", .F.)
						GW3->GW3_MUNINI := Alltrim(aAuxCid[1][1]) 											// Município Início Transporte
						GW3->GW3_UFINI  := Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][1], "GU7_CDUF") 	// UF Início do Transporte
						GW3->GW3_MUNFIM := Alltrim(aAuxCid[1][2]) 											// Município Término do Transporte
						GW3->GW3_UFFIM  := Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][2], "GU7_CDUF") 	// UF Término do Transporte
					GW3->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	//Se não houver chamada da função de integração
	If !IsInCallStack("GFEA065In")
		GW3->( dbSetOrder(1) )
		If GW3->( dbSeek(xFilial("GW3") + oModel:getValue("GFEA065_GW3", "GW3_CDESP") + oModel:getValue("GFEA065_GW3", "GW3_EMISDF") +;
				oModel:getValue("GFEA065_GW3", "GW3_SERDF") + oModel:getValue("GFEA065_GW3", "GW3_NRDF") + ;
				 DTos(oModel:getValue("GFEA065_GW3", "GW3_DTEMIS"))) )

			If oModel:getOperation() != MODEL_OPERATION_DELETE .AND.;
				(oModel:getValue("GFEA065_GW3","GW3_SIT") == "3" .OR. oModel:getValue("GFEA065_GW3","GW3_SIT") == "4")

				If SuperGetMV("MV_TPGERA",.F.,"1") == "1" // OnLine
					aRetRateio := GFERatDF( .F.,;
											oModel:getValue("GFEA065_GW3","GW3_CDESP" ),;
											oModel:getValue("GFEA065_GW3","GW3_EMISDF"),;
											oModel:getValue("GFEA065_GW3","GW3_SERDF" ),;
											oModel:getValue("GFEA065_GW3","GW3_NRDF"  ),;
											oModel:getValue("GFEA065_GW3","GW3_DTEMIS"))
					If aRetRateio[1] == .F.
						GFEMsgErro(aRetRateio[2])
					EndIf
				Else
					// Geração do Rateio simplificado (sem contas contábeis)
					GFERatDFSimp({GW3->GW3_FILIAL, GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS})
				EndIf
			EndIf

			// Refaz o rateio e grade contábil dos cálculos relacionados aos documentos de carga do documento de frete
			If (oModel:getOperation() == MODEL_OPERATION_DELETE .OR. nQtLinhas == 0) .And. !Empty(aCalcProv)
				nF := Len(aCalcProv)
				For nI := 1 to nF
					GFERatCal(.F.,aCalcProv[nI])
				Next nI
			EndIf

			If GFXTB12117("GWC")
				//Após gerar o rateio contábil deve-se verificar a integração com TMS, pois os valores enviados são baseados no rateio.
				//Se for inclusão e o DF foi aprovado, verificar necessidade de gerar integração automática de custo de frete com TMS;
				//Se for alteração, por demanda, já foi enviado, estava aprovado e foi bloqueado, deve ser feita alteração para pendente;
				//Se for alteração, automático, se ficar pendente deve ser excluído. Se for aprovado, deve ser excluído e regerada a integração de custo de frete com TMS.
				If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModelGW3:GetValue("GW3_SIT") == "3"
					GFEA065CTP("IA")
				ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
					If oModelGW3:GetValue("GW3_SIT") $ "2;3"
						If SuperGetMv("MV_GFEI21",.F.,"3") == "1" .And. cSitAnt $ "3;4" .And. cSitCusAnt == "2"
							GFEA065CTP("P")
						ElseIf SuperGetMv("MV_GFEI21",.F.,"3") == "2"
							GFEA065CTP("E")
							If SuperGetMv("MV_GFEI21",.F.,"3") == "2"
								GFEA065CTP("IA")
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		//Integração automatica
		If oModel:getOperation() != MODEL_OPERATION_DELETE
			If oModel:GetValue("GFEA065_GW3", "GW3_SIT") $ "3/4"  //Verifica se o documento está aprovado
				//Teste integração Automatica
				If SuperGetMV('MV_GFEI13',,'1') == "2" .And. oModel:GetValue("GFEA065_GW3", "GW3_SITFIS") $ "1;3" //Fiscal
					GFEA065XF(.T.)
				EndIf
				If SuperGetMV('MV_GFEI14',,'1') == "2" //Recebimento
					GFEA065XC(.T.)
				EndIf
			EndIf
		EndIf
		//Gerar Pendencia de Atualizar Valores de Frete no ERP
		If GFXCP12117("GW1_SITFRE") .And. SuperGetMV('MV_INTFRE',.F.,'1') == '2' .And. oModel:GetValue("GFEA065_GW3", "GW3_SIT") $ "3/4"
			GFEA065VF(oModel)
		EndIf
	EndIf

	If oModel:GetOperation() != MODEL_OPERATION_DELETE .And. ;
		(oModel:GetValue("GFEA065_GW3", "GW3_SIT") == "3" .Or. oModel:GetValue("GFEA065_GW3", "GW3_SIT") == "4")

		GW3->( dbSetOrder(1) )
		If GW3->( dbSeek(xFilial("GW3") + oModel:GetValue("GFEA065_GW3", "GW3_CDESP") + oModel:GetValue("GFEA065_GW3", "GW3_EMISDF") +;
					oModel:GetValue("GFEA065_GW3", "GW3_SERDF") + oModel:GetValue("GFEA065_GW3", "GW3_NRDF") + ;
					DToS(oModel:GetValue("GFEA065_GW3", "GW3_DTEMIS"))) )
			If !IsInCallStack("GFEA065XF") .And. !IsInCallStack("GFEA065XD") .And. !IsInCallStack("GFEA065XC")
				GFEA65GFAT(.F.)
			EndIf
		EndIf
	EndIf

	cFil    := Nil
	nPreFat := Nil
Return lRet

/*-------------------------------------------------------------------
Realiza a validação do formulário do documento de frete na ativação
-------------------------------------------------------------------*/
Function GFEA065VL(oModel)
	Local nOpc      := oModel:GetOperation()
	Local lAprovMLA := SuperGetMv("MV_ERPGFE",.F.,"1") == "1" .And. SuperGetMv("MV_DFMLA",.F.,"1") $ "2|3"
	Local lCteSubs  := "#infctesub#" $ GW3->GW3_OBS //Ct-e será substituído

	// Validação da situação Fiscal e Recebedoria no ERP
	// Se não houver chamada da função de integração
	If (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_DELETE ) .And. !ISINCALLSTACK("GFEA065In")
		If GW3->GW3_SITFIS == "2" .And. !lCteSubs
			GFEMessage(5,GFEA065005,STR0508,STR0509) //"O Documento de Frete está Pendente no Fiscal, portanto, não poderá ser alterado ou excluído." , "Aguarde o processo de integração do Doc Frete. Retornando como Atualizado, poderá ser executada a desatualização. Caso retorne como Rejeitado o documento poderá ser alterado/excluído."
			Return .F.
		EndIf

		If GW3->GW3_SITFIS == "4" .AND. !lGfeAtu .And. !lCteSubs
			GFEMessage(5,GFEA065006,STR0510,STR0511) //"O Documento de Frete está Atualizado no Fiscal, portanto, não poderá ser alterado ou excluído." , "Execute a desatualização do Documento de Frete no Fiscal, para posteriormente realizar a alteração ou exclusão."
			Return .F.
		EndIf

		If GW3->GW3_SITFIS == "5"
			GFEMessage(5,GFEA065007,STR0512,STR0513) //"O Documento de Frete está Pendente de Desatualização no Fiscal, portanto, não poderá ser alterado ou excluído." , "Aguarde o processo de integração do Doc Frete, retornando Não Enviado, poderá alterar/excluir o documento. Retornando Atualizado, verifique o documento e execute nova desatualização."
			Return .F.
		EndIf

		If GW3->GW3_SITREC == "2"
			GFEMessage(5,GFEA065008,STR0514,STR0509) //"O Documento de Frete está Pendente no Recebimento/Compras, portanto, não poderá ser alterado ou excluído." , "Aguarde o processo de integração do Doc Frete. Retornando como Atualizado, poderá ser executada a desatualização. Caso retorne como Rejeitado o documento poderá ser alterado/excluído."
			Return .F.
		EndIf

		If GW3->GW3_SITREC == "4"
			GFEMessage(5,GFEA065009,STR0516,STR0517) //"O Documento de Frete está Atualizado no Recebimento/Compras, portanto, não poderá ser alterado ou excluído." , "Execute a desatualização do Documento de Frete no Recebimento/Compras, para posteriormente realizar a alteração ou exclusão."
			Return .F.
		EndIf

		If GW3->GW3_SITREC == "5"
			GFEMessage(5,GFEA065010,STR0518,STR0513) //"O Documento de Frete está Pendente de Desatualização no Recebimento/Compras, portanto, não poderá ser alterado ou excluído." , "Aguarde o processo de integração do Doc Frete, retornando Não Enviado, poderá alterar/excluir o documento. Retornando Atualizado, verifique o documento e execute nova desatualização."
			Return .F.
		EndIf

		If nOpc == MODEL_OPERATION_UPDATE .And. !FWIsInCallStack("GFEA032")
			GW6->( dbSetOrder(1) )
			If GW6->( dbSeek(GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)) )
				If GW6->GW6_SITAPR $ "3;4"
					Help( ,, 'HELP',, "O Documento de Frete não pode ser alterado, pois está vinculado a uma Fatura aprovada." + ;
							"É necessário que o Documento de Frete seja desvinculado da Fatura para que possa ser efetuada a alteração.", 1, 0)
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_DELETE
		// Relacionado a Fatura
		If !Empty(GW3->GW3_NRFAT)
			Help( ,, 'HELP',, STR0024, 1, 0) //"Não é possível excluir quando o documento de frete estiver vinculado em uma fatura"
			Return .F.
		EndIf
		// Não permitir excluir registros que estejam com a Situação Recebimento e Fiscal como Pendente
		If GW3->GW3_SITREC == '2' .OR. GW3->GW3_SITREC == '4' .OR. GW3->GW3_SITREC == '5'
			Help( ,, 'HELP',, "Não é possível excluir quando a situação do Recebimento estiver 'Pendente' ou 'Atualizado' ", 1, 0)
			Return .F.
		ElseIf ( GW3->GW3_SITFIS == '2' .OR. GW3->GW3_SITFIS == '4' .OR. GW3->GW3_SITFIS == '5' ) .And. !lCteSubs
			Help( ,, 'HELP',, "Não é possível excluir quando a situação do Fiscal estiver 'Pendente' ou 'Atualizado'", 1, 0)
			Return .F.
		EndIf

		If GfeVerCmpo({"GW3_SITMLA"})
			// Impede que a exclusão ocorra antes de desatualizar o documento de frete ao MLA
			If lAprovMLA .And. !(GW3->GW3_SITMLA $ "1|6" .Or. Empty(GW3->GW3_SITMLA))
				Help(,,'HELP',,"Documento de Frete está integrado ao MLA ou pendente de integração, realize a desatualização para esta operação.",1,0)
				Return .F.
			EndIf
		EndIf
	EndIf

	If lGfeAtu
		lGfeAtu := .F.
	EndIf
Return .T.

// Procura pelo mesmo Documento de Carga (GW4) vinculado em outro Documento de Frete (GW3)
Function GFEA065GW4(cTpDf,cEmisDf,cSerDf,cNrDf,dDtEmis,cEmisDc,cSerDc,cNrDc,cTpDc,cCdEsp)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cAliasGW4 := Nil
	Local cMsg      := ""
	Local cSolucao  := ""
	Local oModel    := FWModelActive()

	cAliasGW4 := GetNextAlias()
	BeginSql Alias cAliasGW4
		SELECT GW4.GW4_NRDC,
				GW4.GW4_EMISDC,
				GW3.GW3_NRDF
		FROM %Table:GW4% GW4
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
		AND GW3.GW3_CDESP = GW4.GW4_CDESP
		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
		AND GW3.GW3_SERDF = GW4.GW4_SERDF
		AND GW3.GW3_NRDF = GW4.GW4_NRDF
		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		AND GW3.GW3_TPDF = %Exp:cTpDf%
		AND GW3.%NotDel%
		WHERE GW4.GW4_FILIAL = %xFilial:GW4%
		AND GW4.GW4_EMISDC = %Exp:cEmisDc%
		AND GW4.GW4_SERDC = %Exp:cSerDC%
		AND GW4.GW4_NRDC = %Exp:cNrDc%
		AND GW4.GW4_TPDC = %Exp:cTpDc%
		AND (GW4.GW4_CDESP <> %Exp:cCdEsp%
			OR GW4.GW4_EMISDF <> %Exp:cEmisDf%
			OR GW4.GW4_SERDF <> %Exp:cSerDf%
			OR GW4.GW4_NRDF <> %Exp:cNrDf%
			OR GW4.GW4_DTEMIS <> %Exp:dDtEmis%)
		AND GW4.%NotDel%
	EndSql
	If (cAliasGW4)->(!Eof())
		cMsg     := "O documento de carga número: "+AllTrim(cNrDc)+" série: "+AllTrim(cSerDC)+" já está relacionado a um documento de frete (número :"+AllTrim((cAliasGW4)->GW3_NRDF)+") de despacho (1-Normal), é permitido relacionar cada documento de carga a apenas um documento de frete de despacho (1-Normal)"
		cSolucao := "Vefirique se o documento de frete número: "+AllTrim(cNrDf)+" deve ser de outro tipo (por exemplo: 6-Redespacho) ou se o documento de carga é o correto"
		oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
		lRet := .F.
	EndIf
	(cAliasGW4)->(dbCloseArea())
	RestArea( aArea )
Return lRet

Function G065GW4VPR(oModel)
	Local lRet  := .T.
	Local aArea := GetArea()

	// Impedir quando estiver vinculado em uma fatura
	If !Empty(FwFldGet("GW3_EMIFAT")) .Or. !Empty(FwFldGet("GW3_SERFAT")) .Or. !Empty(FwFldGet("GW3_NRFAT")) .Or. !Empty(FwFldGet("GW3_DTEMFA")) .Or. !Empty(FwFldGet("GW3_FILFAT"))
		Help( ,, 'HELP',, STR0027, 1, 0) //"Não é possível vincular/desvincular Documentos de Carga, quando o documento de Fatura estiver vinculado em uma fatura"
		lRet := .F.
	EndIf
	RestArea( aArea )
Return lRet


Function G065GW4VP(oModel)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaGW1   := GW1->( GetArea() )
	Local aAreaGW3   := GW3->( GetArea() )
	Local aAreaGW4   := GW4->( GetArea() )
	Local aAreaGWF   := GWF->( GetArea() )
	Local aAreaGWH   := GWH->( GetArea() )
	Local cAliasGW1  := Nil

	Private lCalc    := .T.  // Verifica se o Doc carga tem Calc

	// Verifica se o Documento de Carga existe e se o romaneio vinculado está Liberado
	If lRet
		If !GFEA065GW1( IIf(Empty(FwFldGet("GW4_FILIAL")),xFilial("GW4"),FwFldGet("GW4_FILIAL")),;
						FwFldGet("GW4_TPDC"),;
						FwFldGet("GW4_EMISDC"),;
						FwFldGet("GW4_SERDC"),;
						FwFldGet("GW4_NRDC"))
			lRet := .F.
		EndIf
	EndIf

	// Verifica se o transportador do trecho e o emissor do documento de frete são iguais, considerar o parâmetro da raiz do CNPJ
	If lRet
		// Verifica se há trechos no documento de entrada
		If !GFEA065VTR( FwFldGet("GW3_TPDF"),;
						FwFldGet("GW3_EMISDF"),;
						FwFldGet("GW3_NRDF"),;
						FwFldGet("GW4_FILIAL"),;
						FwFldGet("GW4_TPDC"),;
						FwFldGet("GW4_EMISDC"),;
						FwFldGet("GW4_SERDC"),;
						FwFldGet("GW4_NRDC"))
			lRet := .F.
		EndIf
	EndIf

	// Procura pelo mesmo Documento de Carga (GW4) vinculado em outro Documento de Frete (GW3)
	If lRet .And. FwFldGet("GW3_TPDF") == "1"
		nLine:= oModel:getLine()
		If !GFEA065GW4( FwFldGet("GW3_TPDF"),;
						FwFldGet("GW3_EMISDF"),;
						FwFldGet("GW3_SERDF"),;
						FwFldGet("GW3_NRDF"),;
						DtoS(FwFldGet("GW3_DTEMIS")),;
						FwFldGet("GW4_EMISDC", nLine),;
						FwFldGet("GW4_SERDC", nLine),;
						FwFldGet("GW4_NRDC", nLine),;
						FwFldGet("GW4_TPDC", nLine),;
						FwFldGet("GW3_CDESP"))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If FwFldGet("GW3_TPDF") == "6" .And. (IsInCallStack("GFEA115") .Or. IsInCallStack("GFEA118"))//Se o documento de frete for de redespacho
			cAliasGW4 := GetNextAlias()
			BeginSql Alias cAliasGW4
				SELECT 1
				FROM %Table:GW4% GW4
				INNER JOIN %Table:GW3% GW3
				ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
				AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
				AND GW3.GW3_SERDF = GW4.GW4_SERDF
				AND GW3.GW3_NRDF = GW4.GW4_NRDF
				AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
				AND GW3.GW3_TPDF = '6'
				AND GW3.%NotDel%
				WHERE GW4.GW4_FILIAL = %Exp:IIf(Empty(FwFldGet("GW4_FILIAL")),xFilial("GW4"),FwFldGet("GW4_FILIAL"))%
				AND GW4.GW4_EMISDC = %Exp:FwFldGet("GW4_EMISDC")%
				AND GW4.GW4_SERDC = %Exp:FwFldGet("GW4_SERDC")%
				AND GW4.GW4_NRDC = %Exp:FwFldGet("GW4_NRDC")%
				AND GW4.GW4_TPDC = %Exp:FwFldGet("GW4_TPDC")%
				AND GW4.GW4_DTEMIS = %Exp:FwFldGet("GW4_DTEMIS")%
				AND GW4.%NotDel%
			EndSql
			If (cAliasGW4)->(!Eof())
				GFEA115Red(.T.)
			EndIf
			(cAliasGW4)->(dbCloseArea())
		EndIf
	EndIf

	// Se encontrou um trecho que o Transportador é o Emissor do Documento de Frete
	// Verifica se o Tipo de Cálculo do Documento de Frete é obrigatório ser igual ao TIpo de Cálculo do Documento de Carga
	If lRet
		//Função verifica a existencia de calculo de frete caso o parametro exija, a função já tem as mensagens de erro dentro da função
		If !GFEA65CAL(oModel)
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. oModel:getLine() == 1  .And. oModel:IsInserted() .And. ;
		Empty(FwFldGet("GW3_CDREM")) .And. Empty(FwFldGet("GW3_CDDEST"))

		cAliasGW1 := GetNextAlias()

		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_CDREM,
					GW1.GW1_CDDEST
			FROM %Table:GW1% GW1
			WHERE GW1.GW1_FILIAL = %Exp:IIf(Empty(FwFldGet("GW4_FILIAL")),xFilial("GW4"),FwFldGet("GW4_FILIAL"))%
			AND GW1.GW1_CDTPDC = %Exp:FwFldGet("GW4_TPDC")%
			AND GW1.GW1_EMISDC = %Exp:FwFldGet("GW4_EMISDC")%
			AND GW1.GW1_SERDC = %Exp:FwFldGet("GW4_SERDC")%
			AND GW1.GW1_NRDC = %Exp:FwFldGet("GW4_NRDC")%
			AND GW1.%NotDel%
		EndSql

		If (cAliasGW1)->(!Eof())
			FwFldPut("GW3_CDREM", (cAliasGW1)->GW1_CDREM)
			FwFldPut("GW3_CDDEST", (cAliasGW1)->GW1_CDDEST)
		EndIf

		(cAliasGW1)->(dbCloseArea())
	EndIf

	If !IsBlind() .And. GFXXB12117("GWJPRE")
		oModel:SetValue("_VALID",CORVALID(lRet))
	EndIf

	RestArea(aAreaGW1)
	RestArea(aAreaGW3)
	RestArea(aAreaGW4)
	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	RestArea(aArea)
Return lRet
/*/--------------------------------------------------------------------------------------------------
// Conferência do Documento de frete
// Executado após inclusão/alteração
--------------------------------------------------------------------------------------------------/*/
Function GFEA065CO(oModel)
	Local lRet   := .T.

	// Dados dos Documentos (MV_DCOUT)
	Local iQT_VOL    := 0	// Quantidade de Volumes
	Local iPESO_REAL := 0   // Peso Real
	Local iPESO_CUBA := 0   // Peso Cubado
	Local iVOLUME    := 0   // Volume
	Local iVALOR 	 := 0   // Valor dos Itens

	// Valores Detalhados (MV_DCABE)
	Local iFRET_UNID := 0	// Frete Unidade
	Local iFRET_VAL  := 0	// Frete Valor
	Local iTAXAS	 := 0	// Taxas
	Local iVAL_PEDA	 := 0	// Valor do Pedágio
	// Valor Total (MV_DCTOT)
	Local iVAL_FRETE := 0   // Valor do Frete
	Local iALIQUOTA	 := 0	// Alíquota
	Local iVAL_IMPO	 := 0	// Valor do Imposto (ICMS ou ISS)
	Local lUnitiz	 := .F. // Possui Unitizador (GWB)
	Local aArea      := GetArea()
	Local aAreaGW1   := GW1->( GetArea() )
	Local aAreaGW4   := GW4->( GetArea() )
	Local aAreaGWB   := GWB->( GetArea() )
	Local aAreaGW8   := GW8->( GetArea() )
	Local aAreaGUG   := GUG->( GetArea() )
	Local aAreaGWH   := GWH->( GetArea() )
	Local aAreaGWI   := GWI->( GetArea() )
	Local aAreaGWF   := GWF->( GetArea() )
	Local aAreaGV2   := GV2->( GetArea() )
	Local aDocRel    := {}
	Local oModelGW4  := oModel:GetModel("GFEA065_GW4") //Recebe o model da GW4
	Local nLine      := oModelGW4:GetLine()
	Local nI         := 0
	Local nF         := 0
	Local lMsgOco    := .F.
	Local lReturnPE  := .T.
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1")  .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local cAliasGWI  := ""
	Local s_VLCNPJ_1 := SuperGetMV('MV_VLCNPJ',.F.,'1')
	Local s_VLCNPJ_2 := SuperGetMV('MV_VLCNPJ',,'1')
	Local s_AUDINF   := SuperGetMV('MV_AUDINF',.F.,'1')
	Local s_GFE011   := ""
	Local cMsg   := ""
	Private cmsgoco  := " "

	If GFXPR12118("MV_GFE011")
		s_GFE011	:= SuperGetMV("MV_GFE011", .F., "1")
	EndIf
	lConferiu := .T.

	//Incializa array de cálculos
	aCalcRel := {}

	// For nI := 1 - executa uma for para verificar todos os registros do grid
	// oModelGW4:GetQtdLine() - Verifica quantas linhas existem no grid
	// oModelGW4:GoLine( nI ) - Verifica se o model esta posicionado no campo certo
	// !oModelGW4:IsDeleted() - Verifica se a linha na esta deletada
	nF := oModelGW4:GetQtdLine()
	For nI := 1 To nF

		oModelGW4:GoLine( nI )
		If !oModelGW4:IsDeleted()

			AAdd(aDocRel, FwFldGet("GW4_TPDC")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC"))

			GW1->(dbSetOrder(1))
			GW1->(dbSeek(xFilial("GW4")+FwFldGet("GW4_TPDC")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC")))

			GWL->(dbSetOrder(5))
			GWL->(dbSeek(xFilial("GWL")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_TPDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC")))

			Do While GWL->(!Eof()) .And. GWL->(GWL_FILDC+GWL_EMITDC+GWL_TPDC+GWL_SERDC+GWL_NRDC) == xFilial("GWL")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_TPDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC")
				GWD->(dbSetOrder(1))
				If GWD->(dbSeek(GWL->GWL_FILIAL+GWL->GWL_NROCO))
					If GWD->GWD_SIT == "2"
						GU5->(dbSetOrder(1))
						If GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
							GU3->(dbSetOrder(1))
							If GU3->(dbSeek(xFilial("GU3") + GWD->GWD_CDTRP)) //Posiciona no emitente com o codigo do transportador para saber qual a ação deve ser tomada para a ocorrencia
								If GU3->GU3_ACOCO == "1" .and. GWD->GWD_CDTRP == FwFldGet("GW3_EMISDF")
									If GU5->GU5_ACAODF == "3"
										lRet := .F.
										cMotBloq := "Há Registro de Ocorrência para o(s) Documento(s) de Carga do Documento de Frete com ação de bloqueio."
										lMsgOco := .T.
										GFEA115Msg(lMsgOco)
										Exit
									ElseIf GU5->GU5_ACAODF == "2"
										If !IsInCallStack("GFEA115") .And. !IsInCallStack("GFEA118")
											Alert("Atenção: Documento de Carga " + AllTrim(GW1->GW1_NRDC) + " possui ocorrência!")
											Exit
										Else
											lMsgOco := .T.
											GFEA115Msg(lMsgOco)
											Exit
										EndIf
									EndIf
								ElseIf GU3->GU3_ACOCO == "3"
									If GU5->GU5_ACAODF == "2" .Or. GU5->GU5_ACAODF == "3"
										Alert("Atenção: Documento de Carga " + AllTrim(GW1->GW1_NRDC) + " possui ocorrência!")
										Exit
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				GWL->(dbSkip())
			EndDo

			// GWB
			GWB->(dbSetOrder(2))
			GWB->(dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
			Do While GWB->(!Eof()) .And. xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == GWB->GWB_FILIAL+GWB->GWB_CDTPDC+GWB->GWB_EMISDC+GWB->GWB_SERDC+GWB->GWB_NRDC
				lUnitiz := .T.
				iQT_VOL := iQT_VOL + GWB->GWB_QTDE

				GUG->(dbSetOrder(1))
				If GUG->(dbSeek(xFilial("GUG")+GWB->GWB_CDUNIT))
					iVOLUME    := iVOLUME    + GUG->GUG_VOLUME*GWB->GWB_QTDE
				EndIf
				GWB->(dbSkip())
			EndDo

			// GW8
			GW8->(dbSetOrder(1))
			GW8->(dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
			Do While GW8->(!Eof()) .And. xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
				If !lUnitiz
					iQT_VOL    := iQT_VOL    + GW8->GW8_QTDE
					iVOLUME    := iVOLUME 	 + GW8->GW8_VOLUME
				EndIf
				iPESO_REAL := iPESO_REAL + GW8->GW8_PESOR
				iPESO_CUBA := iPESO_CUBA + GW8->GW8_PESOC
				iVALOR     := iVALOR     + GW8->GW8_VALOR

				GW8->(dbSkip())
			EndDo
			//Busca os cálculos que serão vinculados ao documento de frete
		 	cQuery := " SELECT GWF.GWF_NRCALC,"
			cQuery +=        " GWF.GWF_FILIAL,"
			cQuery +=        " GWF.GWF_VLAJUS,"
			cQuery +=        " GWF.GWF_IMPOST,"
			cQuery +=        " GWF.GWF_PCISS,"
			cQuery +=        " GWF.GWF_PCICMS,"
			cQuery +=        " GWF.GWF_VLICMS,"
			cQuery +=        " GWF.GWF_VLISS,"
			cQuery +=        " GWF.GWF_TRANSP,"
			cQuery +=        " GWH.GWH_NRCALC,"
			cQuery +=        " GWF.GWF_ORIGEM,"
			cQuery +=        " GWF_TPCALC"
			cQuery += "   FROM "+RetSqlName('GWH')+" GWH"
			cQuery += "  INNER JOIN "+RetSqlName('GWF')+" GWF"
			cQuery += "     ON GWF.GWF_FILIAL = GWH.GWH_FILIAL"
			cQuery += "    AND GWF.GWF_NRCALC = GWH.GWH_NRCALC"
			cQuery += "    AND GWF.GWF_TPCALC = '"+FwFldGet("GW3_TPDF")+"'"
			If GFXCP12117("GW3_CDTPSE") .And. !Empty(FwFldGet("GW3_CDTPSE"))
				cQuery += "    AND GWF.GWF_CDTPSE = '"+FwFldGet("GW3_CDTPSE")+"'"
			EndIf
			cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
			If lExistCamp
				cQuery += "    AND (GWF.GWF_CDESP  = '"+Space(TamSX3("GWF_CDESP")[1]) +"' OR GWF_CDESP  = '"+FwFldGet("GW3_CDESP ")+"')"
				cQuery += "    AND (GWF.GWF_EMISDF = '"+Space(TamSX3("GWF_EMISDF")[1])+"' OR GWF_EMISDF = '"+FwFldGet("GW3_EMISDF")+"')"
				cQuery += "    AND (GWF.GWF_SERDF  = '"+Space(TamSX3("GWF_SERDF")[1]) +"' OR GWF_SERDF  = '"+FwFldGet("GW3_SERDF ")+"')"
				cQuery += "    AND (GWF.GWF_NRDF   = '"+Space(TamSX3("GWF_NRDF")[1])  +"' OR GWF_NRDF   = '"+FwFldGet("GW3_NRDF  ")+"')"
				cQuery += "    AND (GWF.GWF_DTEMDF = '"+Space(TamSX3("GWF_DTEMDF")[1])+"' OR GWF_DTEMDF = '"+DtoS(FwFldGet("GW3_DTEMIS"))+"')"
			EndIf
			If s_VLCNPJ_1 == "1"
				cQuery += "    AND GWF.GWF_TRANSP = '"+FwFldGet("GW3_EMISDF")+"'"
			EndIf
			cQuery += "  WHERE GWH.GWH_FILIAL = '"+GW1->GW1_FILIAL+"'"
			cQuery += "    AND GWH.GWH_CDTPDC = '"+GW1->GW1_CDTPDC+"'"
			cQuery += "    AND GWH.GWH_EMISDC = '"+GW1->GW1_EMISDC+"'"
			cQuery += "    AND GWH.GWH_SERDC  = '"+GW1->GW1_SERDC +"'"
			cQuery += "    AND GWH.GWH_NRDC   = '"+GW1->GW1_NRDC  +"'"
			cQuery += "    AND GWH.D_E_L_E_T_ = ' '"
			If GFXCP12117("GW3_CDTPSE")
				cQuery += " ORDER BY GWF.GWF_CDTPSE"
			EndIf
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

			Do While (cAliasQry)->(!EoF())
				If s_VLCNPJ_2 == "1" .Or. SubStr(Posicione("GU3", 1, xFilial("GU3") +FwFldGet("GW3_EMISDF"), "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + (cAliasQry)->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8)
					If AScan(aCalcRel, {|x| x == (cAliasQry)->GWH_NRCALC}) > 0
						Exit
					EndIf

					AAdd(aCalcRel, (cAliasQry)->GWF_NRCALC)

					iVAL_FRETE += (cAliasQry)->GWF_VLAJUS

					//Verifica se é ISS ou ICMS
					If (cAliasQry)->GWF_IMPOST == "2"
						/*ISS*/
						iAliquota := (cAliasQry)->GWF_PCISS
						iVal_IMPO += GFETratDec((cAliasQry)->GWF_VLISS,0,.T.)
					Else
						/*ICMS*/
						iAliquota := (cAliasQry)->GWF_PCICMS
						iVal_IMPO += GFETratDec((cAliasQry)->GWF_VLICMS,0,.T.)
					EndIf

					//Auditoria de Frete Combinado
					//Se o parâmetro estiver ativo e a Origem Valor Cálculo igual a 'Informado'
					If s_AUDINF $ "2" .And. (cAliasQry)->GWF_ORIGEM == "2" .and. (cAliasQry)->GWF_TPCALC != "2" .and. (cAliasQry)->GWF_TPCALC != "3"
						lRet := .F.
						cMotBloq := cMotBloq + " Há Frete Combinado" //" Há Frete Combinado"
					EndIf

					//Auditoria de Frete Complementar
					//Se o parâmetro estiver ativo e for Documentos de Frete do tipo Complementar (de valor e de imposto)

					If s_GFE011 $ "2" .and. FwFldGet("GW3_TPDF") $ "23"
						lRet := .F.
						cMotBloq := cMotBloq + " Documento de Frete Complementar"
					EndIf
					cAliasGWI := GetNextAlias()
					BeginSql Alias cAliasGWI
						SELECT SUM(GWI.GWI_VLFRET) GWI_VLFRET,
									GV2.GV2_CATVAL
						FROM %Table:GWI% GWI
						INNER JOIN %Table:GV2% GV2
						ON GV2.GV2_FILIAL = %xFilial:GV2%
						AND GV2.GV2_CDCOMP = GWI.GWI_CDCOMP
						AND GV2.%NotDel%
						WHERE GWI.GWI_FILIAL = %Exp:(cAliasQry)->GWF_FILIAL%
						AND GWI.GWI_NRCALC = %Exp:(cAliasQry)->GWF_NRCALC%
						AND GWI.GWI_TOTFRE = '1'
						AND GWI.%NotDel%
						GROUP BY GV2.GV2_CATVAL
					EndSql
					Do While (cAliasGWI)->(!Eof())

						// Valor Total do Frete
						iVAL_FRETE := iVAL_FRETE + (cAliasGWI)->GWI_VLFRET

						//1=Frete Unidade;2=Frete Valor;3=Taxas;4=Valor do Pedagio
						Do Case
							Case (cAliasGWI)->GV2_CATVAL == "1"  // Frete Unidade
							iFRET_UNID += (cAliasGWI)->GWI_VLFRET

							Case (cAliasGWI)->GV2_CATVAL == "2"  // Frete Valor
							iFRET_VAL  += (cAliasGWI)->GWI_VLFRET

							Case (cAliasGWI)->GV2_CATVAL == "3"  // Taxas
							iTAXAS     += (cAliasGWI)->GWI_VLFRET

							Case (cAliasGWI)->GV2_CATVAL == "4"  // Valor do Pedagio
							iVAL_PEDA  += (cAliasGWI)->GWI_VLFRET
						EndCase

						(cAliasGWI)->(dbSkip())
					EndDo
					(cAliasGWI)->(dbCloseArea())
					Exit //Sai do while da GWH, porque o documento de frete deve ser vinculado ao primeiro cálculo encontrado para o tipo informado.
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			// Verifica se a entrega é obrigatoria
			cMsg := GFEA065VET( FwFldGet("GW3_TPDF"),;
								FwFldGet("GW3_EMISDF"),;
								FwFldGet("GW3_NRDF"),;
								FwFldGet("GW4_FILIAL"),;
								FwFldGet("GW4_TPDC"),;
								FwFldGet("GW4_EMISDC"),;
								FwFldGet("GW4_SERDC"),;
								FwFldGet("GW4_NRDC"))
			If !Empty(cMsg)
				cMotBloq := cMotBloq + cMsg
				lRet := .F.
			EndIf
		EndIf
	Next nI

	//Ponto de Entrada que permite validar se o Documento de Carga foi relacionado ao Documento de Frete
	if ExistBlock("GFEA6510")
		lReturnPE := ExecBlock("GFEA6510",.F.,.F.,{FwFldGet("GW3_EMISDF"), FwFldGet("GW3_NRDF"), FwFldGet("GW3_SERDF"), FwFldGet("GW3_TPDF"),FwFldGet("GW4_EMISDC"),FwFldGet("GW4_NRDC"),FwFldGet("GW4_SERDC"),FwFldGet("GW4_TPDC")})
	Endif

	if lReturnPE

		oModelGW4:GoLine(nLine)
		nF := Len(aCalcRel)
		For nI := 1 To nF
			GWH->( dbSetOrder(1) )
			GWH->(dbSeek(xFilial("GWH") + aCalcRel[nI]))
			Do While GWH->(!Eof()) .And. GWH->GWH_FILIAL == xFilial("GWH") .And. GWH->GWH_NRCALC == aCalcRel[nI]
				If AScan(aDocRel, {|x| x == GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC}) == 0
					lRet := .F.
					cMotBloq += " Nem todos os Documentos de Carga do Cálculo " + GWH->GWH_NRCALC + " foram relacionados ao Documento de Frete."
					Exit
				EndIf
				GWH->(dbSkip())
			EndDo

			If !lRet
				Exit
			EndIf
		Next nI

	Endif

	// *** Dados dos Documentos	*******************************
	If SuperGetMV('MV_DCOUT',.F.,"N") $ "1S"
		// Quantidade de Volumes
		If FwFldGet("GW3_QTVOL") != iQT_VOL
			lRet := .F.
			cMotBloq := cMotBloq + STR0035  //"Há diferença na Quantidade de Volume"
		EndIf

		// Peso Real
		If FwFldGet("GW3_PESOR") != iPESO_REAL
			lRet := .F.
			cMotBloq := cMotBloq + STR0036  //" Há diferença no Peso Real"
		EndIf

		// Peso Cubado  /
		If FwFldGet("GW3_PESOC") != iPESO_CUBA
			lRet := .F.
			cMotBloq := cMotBloq + STR0037  //" Há diferença no Peso Cubado"
		EndIf

		// Volume /
		If FwFldGet("GW3_VOLUM") != iVOLUME
			lRet := .F.
			cMotBloq := cMotBloq + STR0038  //" Há diferença no Volume"
		EndIf

		// Valor dos Itens /
		If FwFldGet("GW3_VLCARG") != iVALOR
			lRet := .F.
			cMotBloq := cMotBloq + STR0039  //" Há diferença no Valor dos Itens"
		EndIf
	EndIf

	// *** Valores Detalhados	*******************************
	If SuperGetMV('MV_DCABE',.F.,"N") $ "1S"
		// Frete Unidade /
		If AbaixoTol(FwFldGet("GW3_FRPESO"), iFRET_UNID)
			lRet := .F.
			cMotBloq := cMotBloq + STR0040  //" Há diferença no Frete Unidade"
		EndIf

		// Frete Valor /
		If AbaixoTol(FwFldGet("GW3_FRVAL"), iFRET_VAL)
			lRet := .F.
			cMotBloq := cMotBloq + STR0041  //" Há diferença no Frete Valor"
		EndIf

		// Taxas /
		If AbaixoTol(FwFldGet("GW3_TAXAS"), iTAXAS)
			lRet := .F.
			cMotBloq := cMotBloq + " Há diferença nas Taxas" //Constante STR0042 alterada para " Há diferença nas Taxas"
		EndIf

		// Valor do Pedágio /
		If AbaixoTol(FwFldGet("GW3_PEDAG"), iVAL_PEDA)
			lRet := .F.
			cMotBloq := cMotBloq + STR0043  //" Há diferença no Valor do Pedágio"
		EndIf
	EndIf

	If GFXCP12127("GW3_VLDIV")
		If FwFldGet("GW3_VLDF") <> iVAL_FRETE
			nVlDiver := FwFldGet("GW3_VLDF") - iVAL_FRETE
			cSitTab  := SuperGetMV("MV_GFEDCFA", .F., "2")
		Endif
	Endif

	// *** Valores Total 		*******************************
	If SuperGetMV('MV_DCTOT',.F.,"N") $ "1S"
		// Valor Total do Frete /
		If AbaixoTol(FwFldGet("GW3_VLDF"), iVAL_FRETE)
			lRet := .F.
			cMotBloq := cMotBloq + STR0044  //" Há diferença no Valor Total do Frete"
		EndIf
	EndIf

	If SuperGetMV('MV_DMIMP',.F.,"N") $ "1S"
		// Alíquota /
		If FwFldGet("GW3_PCIMP") != iALIQUOTA
			lRet := .F.
			cMotBloq := cMotBloq + " Há diferença na Alíquota" + CRLF //Constante STR0045 alterada para " Há diferença na Alíquota"
		EndIf

		// Valor do Imposto /
		If AbaixoTol(Round(FwFldGet("GW3_VLIMP"), 2), iVAL_IMPO)
			lRet := .F.
			cMotBloq := cMotBloq + STR0046 + CRLF //" Há diferença no Valor do Imposto"
		EndIf
	EndIf
	RestArea(aAreaGW1)
	RestArea(aAreaGW4)
	RestArea(aAreaGWB)
	RestArea(aAreaGW8)
	RestArea(aAreaGUG)
	RestArea(aAreaGWH)
	RestArea(aAreaGWI)
	RestArea(aAreaGWF)
	RestArea(aAreaGV2)
	RestArea(aArea)
Return lRet

Static Function DiffValor(nInfo, nCalc)
	Local nDif := nInfo - nCalc
Return nDif


// Verifica se a diferença entre os valores está dentro da tolerância permitida
Static Function AbaixoTol(nInfo, nCalc)
	Local lRet  := .T.
	Local nDif  := 0
	Local nPorc := 0
	Local n_DMVAL  := SuperGetMv('MV_DMVAL',,0)
	Local n_DMPERC := SuperGetMv('MV_DMPERC',,0)

	nDif := DiffValor(nInfo, nCalc)

	If nDif == 0
		Return .F.
	EndIf

	/*Faz uma verificação de que se o paramtro MV_DCNEG esta setado como "Sim" e o valor da Variavel nInfo for menor que o valor do calculo
	então Indica que os valores dos documentos de frete menores que os valores calculados
	pelo sistema não serão considerados como divergência na conferência se estiver como "Não" cai na condição Else*/
	If SuperGetMV('MV_DCNEG',.F.,"N") $ "1S" .And. nInfo < nCalc
		lRet := .F.
	Else
		If nInfo >= nCalc	// Verifica se valor do DF é maior que o calculo
			If !Empty(SuperGetMV('MV_DCVAL',.F.,"")) .And. !Empty(SuperGetMV('MV_DCPERC',.F.,""))
				nPorc := (SuperGetMV('MV_DCPERC',.F.,"") / 100) * nCalc
				If (abs(nDif) <= nPorc ) .And. abs(nDif) <= SuperGetMV('MV_DCVAL',.F.,"")
					lRet := .F.
				EndIf
			EndIf
		Else				// Verifica se valor do DF é menor que o calculo
			If n_DMPERC > 0 .And. n_DMVAL > 0
				nPorc := (n_DMPERC / 100) * nCalc
				If Abs(nDif) < nPorc .And. Abs(nDif) < n_DMVAL
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA65CAL
Validação de existencia de calculo de frete caso o parametro exija
Uso GFEA065.

@sample
GFEA65CAL()

@author Felipe M.
@since 14/05/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA65CAL(oModelGW4)
	Local lRet       := .T.
	Local cOBNENT    := SuperGetMV('MV_OBNENT',.F.,'1',cFilAnt) //Calculos de Fretes Normais (de Entrada) sao Obrigatorios
	Local cOBCOMP    := SuperGetMV('MV_OBCOMP',.F.,'1',cFilAnt) //Calculos de Fretes Complementares       sao Obrigatorios
	Local cOBREEN    := SuperGetMV('MV_OBREEN',.F.,'1',cFilAnt) //Calculos de Fretes de Reentrega         sao Obrigatorios
	Local cOBDEV     := SuperGetMV('MV_OBDEV' ,.F.,'1',cFilAnt) //Calculos de Fretes de Devolucao         sao Obrigatorios
	Local cOBSERV    := SuperGetMV('MV_OBSERV',.F.,'1',cFilAnt) //Calculos de Fretes de Servico           sao Obrigatorios
	Local cOBREDE    := SuperGetMV('MV_OBREDE',.F.,cOBNENT,cFilAnt) // Calculos de Frete Redespacho sao Obrigatorios
	Local ChkObrigat := .F.
	Local lVldCalc   := .F.
	Local lVldSrv    := .F.
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. SuperGetMV("MV_DPSERV", .F., "1") == "1"  .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local cCpnjDF    := ""
	Local cCpnjDC    := ""
	Local nRecPriClc := 0
	Local s_VLCNPJ_2 := SuperGetMV('MV_VLCNPJ',,'1')

	// Verifica se o Tipo de Documento está parametrizado como obrigatório nos parâmtros
	Do Case
		Case FwFldGet("GW3_TPDF") == "1" // Normal
			// Quando for Normal de Saída, sempre será obrigatório

			//Se especie do documento de frete(GVT), estiver com o parâmetro "Calc Normal" igual a "sempre obrigatório"
			//ou "Conforme Param Módulo"
			GVT->(dbSetOrder(1))
			If GVT->(dbSeek(xFilial("GVT") + FwFldGet("GW3_CDESP")))
				cCalcn := IIf(!Empty(GVT->GVT_CALCN),GVT->GVT_CALCN,"3")
				If cCalcn == "1" .Or. (cCalcn == "3" .And. cOBNENT == "1")
					ChkObrigat := .T.
				EndIf
			EndIf
		Case FwFldGet("GW3_TPDF") == "2" .OR. FwFldGet("GW3_TPDF") == "3" //Complementares
			If cOBCOMP $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "4" // Reentrega
			If cOBREEN $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "5" // Devolução
			If cOBDEV $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "6" // Redespacho
			If cOBREDE $ "1S"
				ChkObrigat := .T.
			EndIf
		Case FwFldGet("GW3_TPDF") == "7" // Serviço
			If cOBSERV $ "1S"
				ChkObrigat := .T.
			EndIf
	EndCase

	// Ponto de entrada
	If ExistBlock("GFEA6511")
		ChkObrigat := ExecBlock("GFEA6511",.f.,.f.,{ChkObrigat,FwFldGet("GW3_FILIAL"),FwFldGet("GW3_CDESP"),FwFldGet("GW3_EMISDF"),FwFldGet("GW3_SERDF"),FwFldGet("GW3_NRDF"),FwFldGet("GW3_DTEMIS"),oModelGW4 })
	EndIf

	// O Tipo de Cálculo do Documento de Frete deve ser igual ao Tipo de Cálculo do Cálculo do Documento de Carga
	If ChkObrigat

		If !oModelGW4:IsDeleted()
			GW1->(dbSetOrder(1))
			GW1->(dbSeek(If(Empty(FwFldGet("GW4_FILIAL")),xFilial("GW4"),FwFldGet("GW4_FILIAL"))+FwFldGet("GW4_TPDC")+FwFldGet("GW4_EMISDC")+FwFldGet("GW4_SERDC")+FwFldGet("GW4_NRDC")))

			GWH->(dbSetOrder(2))
			If GWH->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
				// Procura em todos os Cálculos de Documento de Carga, um que o Tipo de Cálculo, seja igual ao Tipo de Cálcudo do Documento de Frete
			Do While GWH->(!Eof()) .And. GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC;
					.And. !lVldCalc //O documento de frete deve possuir apenas um cálculo válido para o documento de carga

					GWF->(dbSetOrder(1))
					GWF->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC))
					// Compara o cálculo do Documento de Carga com o de Documento de Frete
					// GW3->GW3_TPDF X GWF->GWF_TPCALC -> 1=Normal;2=Redespacho;3=Reentrega;4=Devolucao;5=Servico;6=Compl. Valor;7=Compl. ICMS;8=Provisao
					If lVldCalc <> .T. .And. FwFldGet("GW3_TPDF") == GWF->GWF_TPCALC
						lVldCalc := .T.

						//Verifica se transportador do cálculo é igual ao emissor do documento de frete.
						If FwFldGet("GW3_EMISDF") != GWF->GWF_TRANSP
							If s_VLCNPJ_2 == "2"
								cCpnjDC     := Posicione("GU3", 1,xFilial("GU3") + FwFldGet("GW3_EMISDF"), "GU3_IDFED" )
								cCpnjDCNun  := SUBSTR(cCpnjDC,1,8)
								cCpnjDF  	 := Posicione("GU3", 1,xFilial("GU3") + GWF->GWF_TRANSP, "GU3_IDFED" )
								cCpnjDFNun  := SUBSTR(cCpnjDF,1,8)
								If cCpnjDCNun != cCpnjDFNun
									lVldCalc := .F.
									lVldSrv := .T.
								EndIf
							Else
								lVldCalc := .F.
								lVldSrv := .T.
							EndIf
						EndIf
					EndIf

					// Valida se o calculo não está vinculado a outro documento de frete
					If lVldCalc .And. FwFldGet("GW3_TPDF") == GWF->GWF_TPCALC .And. lExistCamp .And. !Empty(GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF))) .And.;
						GWF->(GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF)) <>  FwFldGet("GW3_FILIAL")+FwFldGet("GW3_CDESP")+FwFldGet("GW3_EMISDF")+FwFldGet("GW3_SERDF")+FwFldGet("GW3_NRDF")+DToS(FwFldGet("GW3_DTEMIS"))
						lVldCalc := .F.
						lVldSrv := .T.
					EndIf

					If GFXCP12117("GW3_CDTPSE")
						If lVldCalc .And. FwFldGet("GW3_TPDF") == '7'
							If Empty(nRecPriClc)
								nRecPriClc := GWF->(Recno())
							EndIf
							If FwFldGet("GW3_CDTPSE") != GWF->GWF_CDTPSE
								lVldCalc := .F.
								lVldSrv := .F.
							Else
								lVldSrv := .T.
							EndIf
						EndIf
					EndIf

					// Valida se o calculo não está vinculado a outro documento de frete
					If lVldCalc .And. FwFldGet("GW3_TPDF") == GWF->GWF_TPCALC .And. lExistCamp .And. !Empty(GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF))) .And.;
						GWF->(GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF)) <>  FwFldGet("GW3_FILIAL")+FwFldGet("GW3_CDESP")+FwFldGet("GW3_EMISDF")+FwFldGet("GW3_SERDF")+FwFldGet("GW3_NRDF")+DToS(FwFldGet("GW3_DTEMIS"))
						lVldCalc := .F.
					EndIf
					GWH->(dbSkip())
				EndDo

				If GFXCP12117("GW3_CDTPSE") .And. lVldCalc == .F. .And. lVldSrv == .F. .And. !Empty(nRecPriClc)
					lVldCalc := .T.
					GWF->(dbGoTo(nRecPriClc))
				EndIf
			Else
				lVldCalc := .F.
			EndIf

			If !lVldCalc .and. !(IsInCallStack("GFEA115") .or. IsInCallStack("GFEA118"))
				Help( ,, 'HELP',, "É necessário que haja um Cálculo de Frete para o Documento de Carga que possua o mesmo Tipo do Documento de Frete e Transportador do Cálculo igual ao Emissor do Documento de Frete.", 1, 0) //Antiga STR0073 e STR0072 "É necessário que haja um Cálculo de Frete dos Documentos de Carga que possua o mesmo Tipo do Documento de Frete, e Transportador do Cálculo igual ao Emissor do Documento de Frete."
				lRet := .F.
			ElseIf !lVldCalc .and. (IsInCallStack("GFEA115") .or. IsInCallStack("GFEA118"))
				Help( ,, 'HELP',, "É necessário que haja um Cálculo de Frete para o Documento de Carga (Emissor: "+ GW1->GW1_EMISDC + "Tipo: "+ GW1->GW1_CDTPDC +  "Serie: "+ GW1->GW1_SERDC +" e Número: " + GW1->GW1_NRDC + ", Romaneio: " + GW1->GW1_NRROM + ") que possua o mesmo Tipo do Documento de Frete e Transportador do Cálculo igual ao Emissor do Documento de Frete." , 1, 0)
				lRet := .F.
				Return .F.
			EndIf
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065XF()
Integração com EMS - Fiscal
Generico

@sample
GFEA065XF()

@author Israel Possoli
@since 30/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA065XF(lAutom, nOpc, lExec)
	Local lRet       := .F.
	Local aRet       := {}
	Local dData      := nil
	Local lIntGFE    := SuperGetMv("MV_INTGFE" ,.F.,.F.)
	Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cSiGFE     := SuperGetMv("MV_SIGFE"  ,.F.,"2")
	Local cERPGFE    := SuperGetMv("MV_ERPGFE" ,.F.,"2")
	Local lIntDocF   := SuperGetMv('MV_DSCTB',, '1') == "2"
	Local lCpoTES    := GFEA065INP()
	Local lcall115   := IsInCallStack("GFEA115")
	Local lcall117   := IsInCallStack("GFEA117")
	Local lcall118   := IsInCallStack("GFEA118")
	Local cDTInt     := SuperGetMv("MV_DSOFDT",.F.,"1")
	Local lMsg       := .F.
	Local nVlMov     := 0
	Local dDtUlFe    := SuperGetMv("MV_DTULFE",.F.,"01/01/1900")
	Local cAliasGWA  := Nil
	Local cIntGFEI13 := SuperGetMV('MV_GFEI13',,'1')
	Local cIntERP    := SuperGetMv("MV_ERPGFE",.F.,.F.)
	Local cIntFis 	 := ""

	Default lAutom  := .F. // parametro referente a integração automatica
	Default nOpc    := '1' 
	Default lExec   := .F.
	Default lFirstMsg := .F.

	If cIntERP == "2" .AND. cIntGFEI13 == "2" .AND. nOpc == "1"
		cIntFis  := SuperGetMV('MV_INTFIS',,'1')
		If cIntFis == "2" .OR. cIntFis == "4"
			nOpc := "4"
		EndIf
	EndIf

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	If cIntGFEI13 == "3"
		Help( ,, 'Help',, "Sistema parametrizado como Não Integrar Doc Frete com o Fiscal.", 1, 0 ) // "Sistema parametrizado como Não Integrar Doc Frete com o Fiscal."
		Return .F.
	EndIf

	If !lcall115 .Or. !lcall118
		dData := dDatabase
	EndIf

	If lCpoTES
		cSiGFE := SuperGetMv("MV_SIGFE", .F., "2")
	EndIf

	If !lAutom

		If dData <= dDtUlFe .and. cERPGFE == "2"
			GFEMessage(5, GFEA065018, GFEMsgFmt(STR0075 + "[VAR01]" + STR0076, {{"[VAR01]", DToC(dDtUlFe)}}), STR0533) //"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf

		// Deve ser Não-Enviado ou Rejeitado
		If GW3->GW3_SITFIS != "1".And.GW3->GW3_SITFIS != "3"
			GFEMessage(5, GFEA065019, STR0074, STR0534) //"Somente Documentos de Frete Não-Enviado ou Rejeitado podem ser integrados" , "Não é permitido realizar integrações de documentos com status diferente de Não-Enviado ou Rejeitado, realize a desatualização do documento ou selecione um documento com status de acordo para integração."
			Return .F.
		EndIf

		// Deve ser Aprov.Sistema ou Aprov.Usuario
		If GW3->GW3_SIT != "3".And.GW3->GW3_SIT != "4"
			GFEMessage(5, GFEA065020, STR0090, STR0535) //"Somente Documentos de Frete Aprov.Sistema ou Aprov.Usuario podem ser integrados" , "Não é permitido realizar integrações de Documentos de Frete que não estão aprovados, realize a aprovação do documento antes de realizar a integração."
			Return .F.
		EndIf

	EndIf

	If cERPGFE == "1"
		If lIntDocF
			cAliasGWA := GetNextAlias()
			BeginSql Alias cAliasGWA
				SELECT SUM(GWA.GWA_VLMOV) GWA_VLMOV
				FROM %Table:GWA% GWA
				WHERE GWA.GWA_FILIAL = %Exp:GW3->GW3_FILIAL%
				AND GWA.GWA_TPDOC = '2' // Docto Frete
				AND GWA.GWA_CDESP = %Exp:GW3->GW3_CDESP%
				AND GWA.GWA_CDEMIT = %Exp:GW3->GW3_EMISDF%
				AND GWA.GWA_SERIE = %Exp:GW3->GW3_SERDF%
				AND GWA.GWA_NRDOC = %Exp:GW3->GW3_NRDF%
				AND GWA.GWA_DTEMIS = %Exp:GW3->GW3_DTEMIS%
				AND GWA.%NotDel%
			EndSql
			If (cAliasGWA)->(!Eof())
				nVlMov := (cAliasGWA)->GWA_VLMOV
			EndIf
			(cAliasGWA)->(dbCloseArea())
			If	nVlMov != GW3->GW3_VLDF
				GFEMessage(5, GFEA065021, GFEMsgFmt(STR0536, {{"[VAR01]", cValToChar(GW3->GW3_VLDF)}, {"[VAR02]", cValToChar(nVlMov)}}), STR0537) //"No modo de integração fiscal pelo Recebimento, o valor do documento: " + #### + " deve ser igual ao total dos rateios contábeis: " + ####
				Return .F.
			EndIf
		EndIf

		If (cDTInt == "2" .or. cDTInt == "3") .and. (lcall115 .or. lcall118)
			lMsg := .T.
			PosVal115(lMsg)
			Return .F.
		EndIf
		
		// Data Corrente (4)
		If cDtInt == "4"
			dData := Date()

			If dData <= dDtUlFe .AND. !lAutom
				GFEMessage(5, GFEA065022, GFEMsgFmt(STR0075 + "[VAR01]" + STR0076, {{"[VAR01]", DToC(dDtUlFe)}}), STR0533)	//"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
				Return .F.
			EndIf
		EndIf	

		// Data Informada (3)
		// - Data Informada = "".OR.Data Informada <= MV_DTULFE Mensagem não processa;
		// - GW3_DTFIS = Data Informada
		If cDTInt == "3"
			dData := GFEA065DT()
			If Empty(dData)
				Return .F.
			EndIf

			If dData <= dDtUlFe .AND. !lAutom
				GFEMessage(5, GFEA065022, GFEMsgFmt(STR0075 + "[VAR01]" + STR0076, {{"[VAR01]", DToC(dDtUlFe)}}), STR0533)	//"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
				Return .F.
			EndIf
		EndIf

		// Data Financeira (2)
		// - Se GW6_DTFIN = "".OR.GW6_DTFIN <= MV_DTULFE  continue;
		// - GW3_DTFIS = GW6_DTFIN
		If cDTInt == "2"
			GW6->(dbSetOrder(1))
			If GW6->(dbSeek(GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)))
				If GW6->GW6_SITFIN != "4"
					If lcall117 //Não apresenta Mensagem em tela quando chamado via GFEA117
						Return .F.
					Else 
						GFEMessage(5, GFEA065023, STR0538, STR0539) // "A Fatura de Frete não foi atualizada no financeiro."
						Return .F.
					EndIF
				EndIf

				If GW6->GW6_DTFIN <= dDtUlFe .AND. !lAutom
					GFEMessage(5, GFEA065024, GFEMsgFmt(STR0078 + "[VAR01]" + STR0076, {{"[VAR01]", DToC(dDtUlFe)}}), STR0540) //"Data de envio da Fatura de Frete deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
					Return .F.
				EndIf
			Else
				//DLOGGFE2-2099
				If GW3->GW3_TPDF != "3" .And. !(FWIsInCallStack("GFEA032") .Or. FWIsInCallStack("GFEA117"))
					If FWIsInCallStack("") .And. !lFirstMsg
						lFirstMsg := .T.
					ElseIf FWIsInCallStack("GFE050CALC")
						If !lFirstMsg
							lFirstMsg := .T.
							GFEMessage(5, GFEA065025, STR0541, STR0542)	// "Integração com o fiscal não executada, pois não há Fatura de Frete relacionado a este Documento de Frete para definir a data de transação. Verificar o parâmetro 'Data de Transação do Documento Fiscal' na aba 'Integrações Datasul'."
						EndIf
					Else
						GFEMessage(5, GFEA065025, STR0541, STR0542)	// "Integração com o fiscal não executada, pois não há Fatura de Frete relacionado a este Documento de Frete para definir a data de transação. Verificar o parâmetro 'Data de Transação do Documento Fiscal' na aba 'Integrações Datasul'."
					EndIf

					Return .F.
				EndIf
			EndIf

			If GW3->GW3_TPDF == "3"
				dData := GFEA065DT()
				If Empty(dData)
					Return .F.
				EndIf
			Else
				dData := GW6->GW6_DTFIN
			EndIf
		EndIf

		// Data de Entrada (1)
		//		- MV_DSOFDT = 1
		//		- Se GW3_DTENT = "".OR.GW3_DTENT <= MV_DTULFE  continue;
		//		- GW3_DTFIS = GW3_DTENT
		If cDTInt == "1"
			If Empty(GW3->GW3_DTENT)
				GFEMessage(5, GFEA065026, STR0077, STR0543) //"A Fatura de Frete não foi enviada"
				Return .F.
			EndIf

			If GW3->GW3_DTENT <= dDtUlFe .AND. !lAutom
				GFEMessage(5, GFEA065027, GFEMsgFmt(STR0544 + "[VAR01]" + STR0076, {{"[VAR01]", DToC(dDtUlFe)}}), STR0545) // "Data de envio do Documento de Frete deve ser posterior a data do último fechamento: " ####
				Return .F.
			ElseIf GW3->GW3_DTENT <= dDtUlFe .AND. lAutom
				Return .F.
			EndIf
			dData := GW3->GW3_DTENT
		EndIf
	EndIf

	// Início Ponto de Entrada Britania
	If ExistBlock("XGFEENOF")
		aRotAdic := ExecBlock("XGFEENOF",.f.,.f.,{GW3->GW3_FILIAL, GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS)})
		If aRotAdic == .F.
			Return .F.
		EndIf
	EndIf
	// Fim Ponto de Entrada Britania

	// A tela para informar os campos de integração deve ser aberta somente quando a integração
	// for com ERP Protheus e quando a execução da função for através da tela do GFEA065
	// e somente para a integração como Documento Fiscal
	If lCpoTES .And. cERPGFE == "2"
		If lExec
			If cSiGFE == "1" .And. nOpc == "1"
				lRet := GFEA065IPR(.T., "", nOpc )
				If !lRet
					GFEMessage(0, GFEA065028, STR0546) // "Operação Cancelada pelo Usuário - Produto não informado"
					Return .F.
				EndIf
			EndIf
			If !GFE065VCPO(nOpc, .T.)  // Valida se os campos de Integracao protheus estão preenchidos
				Return .F.
			EndIf
		ElseIf lAutom
			GFE065VCPO(nOpc, .T.)  // Preenche os campos de integração Protheus caso estejam vazios
		EndIf
	EndIf

	aRet := GFEA065In("2", dData, nOpc) // Pendente, Data, Fiscal -> nOpc = 1 ou 4

	If GFXCP1212410("GW3_DSOFDT") .And. GFXRL1212410("GW3","GW3_DSOFDT")
		If cIntERP == "1" .And. aRet[1] .And. Alltrim(nOpc) == "1" .And. Empty(GW3->GW3_DSOFDT)
			RecLock("GW3", .F.)
				GW3->GW3_DSOFDT := cDTInt
			GW3->( MsUnlock() )
		EndIf
	EndIf

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. !lAutom .And. !aRet[1]
		GFEMessage(0, GFEA065029, GFEMsgFmt(STR0548, {{"[VAR01]", aRet[2][6]}}))	// "Documento de Frete não foi enviada para atualização no Fiscal por causa do seguinte erro: " + ###
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065VF()
Integração com EMS - Valor de Frete
Generico

@sample
GFEA065XVF()

@author Estela Baratto
@since 18/05/2017
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA065VF( oModel, lAcao )
	Local lRet      := .T.
	Local nI        := 0
	Local nF        := 0
	Local oModelGW4 := oModel:getModel("GFEA065_GW4")

	GW1->(dbSetOrder(1))
	nF := oModelGW4:Length()
	For nI := 1 To nF
		oModelGW4:GoLine(nI)
		If !oModelGW4:IsDeleted() .And. !Empty(oModelGW4:GetValue("GW4_NRDC"))
			GW1->(dbSeek(xFilial("GW1") + oModelGW4:GetValue("GW4_TPDC") + oModelGW4:GetValue("GW4_EMISDC") + oModelGW4:GetValue("GW4_SERDC") + oModelGW4:GetValue("GW4_NRDC")))
			If GW1->GW1_SITFRE != '6' .And. GW1->GW1_ORIGEM == '2'
				RecLock("GW1", .F.)
					GW1->GW1_SITFRE := "2"
					GW1->GW1_MOTFRE := "GFEA065 - Documento de Frete"
					GW1->GW1_DTFRE := Date()
				GW1->(Msunlock())
			EndIf
		EndIf
	Next nI
Return lRet
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065XC()
Integração com EMS - Apropriação de Custos por Lote
Generico

@sample
GFEA065XC()

@author Israel Possoli
@since 30/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA065XC(lAutom, nOpc, lExec)
	Local lRet       := .F.
	Local aRet       := {}
	Local dData      := CtoD("  /  /  ")
	Local dDataint   := Date()
	Local cParData   := SuperGetMV('MV_DSDTRE',,'1') // Parametro Int Origem Data de Integração
	Local lIntGFE    := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cSitFinFat := "" // Situação financeira fatura
	Local cSiGFE     := SuperGetMv("MV_SIGFE", .F., "2")
	Local cERPGFE    := SuperGetMv("MV_ERPGFE", .F., "2")
	Local lcall115   := IsInCallStack("GFEA115")
	Local lcall118   := IsInCallStack("GFEA118")
	Local lCpoTES    := GFEA065INP()
	Local dDtUlFe    := SuperGetMv("MV_DTULFE",.F.,"01/01/1900")
	Local cIntGFEI14 := SuperGetMV('MV_GFEI14',,'1') 
	Local cIntERP    := SuperGetMv("MV_ERPGFE",.F.,.F.)
	Local cIntFis	 := ""
	
	Default lAutom   := .F. // parametro referente a integração automatica
	Default nOpc     := "2" // Tipo de integração
	Default lExec    := .F.
	
	If cIntERP == "2" .AND. cIntGFEI14 == "2" .AND. nOpc == "2"
		cIntFis  := SuperGetMV('MV_INTFIS',,'1')
		If cIntFis == "3" .OR. cIntFis == "4"
			nOpc := "5"
		EndIf
	EndIf

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	If lCpoTES
		cSiGFE := SuperGetMv("MV_SIGFE", .F., "2")
	EndIf

	If !lcall115 .and. !lcall118
		dDataint := dDatabase
	EndIf

	If dDataint <= dDtUlFe .and. cERPGFE == "2"
		If !lAutom
			Help( ,, 'Help',, STR0075 + DToC(dDtUlFe) + STR0076, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
		EndIf
		Return .F.
	EndIf


	If GW3->GW3_SITREC != "1".AND.GW3->GW3_SITREC != "3" // Não-Enviado ou Rejeitado
		If !lAutom
			Help( ,, 'Help',, STR0074, 1, 0 ) //"Somente Documentos de Frete Não-Enviado ou Rejeitado podem ser integrados"
		EndIf
		Return .F.
	EndIf

	// Deve ser Aprov.Sistema ou Aprov.Usuario
	If GW3->GW3_SIT != "3".AND.GW3->GW3_SIT != "4"
		If !lAutom
			Help( ,, 'Help',, STR0090, 1, 0 ) //"Somente Documentos de Frete Aprov.Sistema ou Aprov.Usuario podem ser integrados"
		EndIf
		Return .F.
	EndIf

	If Empty(cParData)
		cParData := "1"
	EndIf

	//Integração com Datasul
	If SUPERGETMV("MV_ERPGFE",.F.,"2") == "1"
		If cParData == "3"       //Informada Usuário
			dData := GFEA065DT()
		ElseIf cParData == "1"   //Data Corrente
		 	dData := DDATABASE
		ElseIf cParData == "2"   //Data Entrada
			dData := GW3->GW3_DTENT
		ElseIf cParData == "4"   //1=Nao Enviada;2=Pendente;3=Rejeitada;4=Atualizada;5=Pendente Desatualizacao
			GW6->(dbSetOrder(1))
			If GW6->(dbSeek(xFilial("GW6")+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA)))
				cSitFinFat := GW6->GW6_SITFIN
				dData := GW6->GW6_DTFIN
				If cSitFinFat != "4"
					Help( ,, 'Help',, "A Fatura de Frete não foi atualizada no financeiro.", 1, 0 )
					Return .F.
				EndIf
			else
				Help( ,, 'Help',, "O parâmetro Data Integração Recebimento esta configurado para assumir a data do Financeiro, porém não existe Fatura de Frete atualizada com o Financeiro para este Documento de Frete.", 1, 0 )
			EndIf
		EndIf

		If Empty(dData)
			Return .F.
		EndIf

		If dData <= dDtUlFe
			Help( ,, 'Help',, STR0075 + DTOC(dDtUlFe) + STR0076, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
	EndIf

	// A tela para informar os campos de integração deve ser aberta somente quando a integração
	// for com ERP Protheus e quando a execução da função for através da tela do GFEA065
	If lCpoTES .And. cERPGFE == "2"
		If lExec
			If cSiGFE == "1"
				lRet := GFEA065IPR(.T., "", nOpc )
				If !lRet
					MsgAlert( "Operação Cancelada pelo Usuário - Produto não informado" )
					Return .F.
				EndIf
			EndIf
		ElseIf lAutom
			GFE065VCPO(nOpc, .T.)  // Preenche os campos de integração Protheus caso estejam vazios
		EndIf
	EndIf

	If empty(dData)
		dData := dDataint
	Endif
	aRet := GFEA065In("2", dData, nOpc) // Pendente, Data, Custos

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. !lAutom
		If aRet[1]
			lRet := .T.
		Else
			Alert("Documento de Frete não foi enviado para atualização no Recebimento. Motivo: " + aRet[2][6])
		EndIf
	EndIf
Return lRet

/*--------------------------------------------------
Função para desatualização no Fiscal ou Recebimento
--------------------------------------------------*/
Function GFEA065XD(cOp)
	Local aRet     := {}
	Local lIntGFE  := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local dDtUlFe  := SuperGetMv("MV_DTULFE",.F.,"01/01/1900")
	Local cIntFisc := SuperGetMv("MV_GFEI23",.F.,"2")
	Local cIntERP  := SuperGetMv("MV_ERPGFE",.F.,.F.)
	local aHelp    := {}

	If cOp == "1" .And. GW3->GW3_SITFIS != "4"
		Help( ,, 'Help',, "O Documento de Frete deve estar atualizado no Fiscal", 1, 0 ) //"O Documento de Frete deve estar atualizado no Financeiro"
		Return
	ElseIf cOp == "2" .And. GW3->GW3_SITREC != "4"
		Help( ,, 'Help',, "O Documento de Frete deve estar atualizado no Recebimento", 1, 0 ) //"O Documento de Frete deve estar atualizado no Recebimento"
		Return
	EndIf

	If (!Empty(GW3->GW3_DTFIS) .And. GW3->GW3_DTFIS <= dDtUlFe) .Or.(!Empty(GW3->GW3_DTREC) .And. GW3->GW3_DTREC <= dDtUlFe)
		Help( ,, 'Help',, STR0075 + DToC(dDtUlFe) + STR0076, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
		Return
	EndIf

	If cIntFisc == "1"
		GW6->(dbSetOrder(1))
		If GW6->(dbSeek( GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT +  DToS(GW3->GW3_DTEMFA)))
			If GW6->GW6_SITFIN == "2" .OR. GW6->GW6_SITFIN == "4"
				AADD(aHelp,"Quando o Parâmetro 'Fiscal Pré-requisito para Atualizar Fatura com Financ.' está ativado, não é possível desatualizar o documento do Fiscal/Recebimento se ele estiver em uma fatura atualizada no financeiro.")
				Help( ,, 'Help',, "Documento de Frete vinculado à uma Fatura atualizada ou pendente de atualização no Financeiro.",1,0,,,,,,aHelp)
				Return
			EndIf
		EndIf
	EndIf

	If Existblock( "GFEA65XD" )
		If ! Execblock( "GFEA65XD" , .F. , .F. , {cOp} )
			Return
		EndIf
	EndIf

	If !MsgNoYes("Deseja desatualizar o Documento de Frete no " + IIf(cOp == "1", "Fiscal", "Recebimento") + "?", "Aviso")
		Return
	EndIf

	aRet := GFEA065In("5", , cOp)

	If GFXCP1212410("GW3_DSOFDT") .And. GFXRL1212410("GW3","GW3_DSOFDT")
		If cIntERP == "1" .And. aRet[1] .And. Alltrim(cOp) == "1" .And. !Empty(GW3->GW3_DSOFDT)
			RecLock("GW3", .F.)
				GW3->GW3_DSOFDT := " "
			GW3->( MsUnlock() )
		EndIf
	EndIf

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. !aRet[1]
		Alert("Documento de Frete não foi enviada para desatualização no " + IIf(cOp == "1", "Fiscal", "Recebimento") + " por causa do seguinte erro: " + aRet[2][6])
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} -()
Função utilizada em Integração.
Generico

@parametros
cSituacao: Situação a ser atribuida
	1=Nao Enviado
	2=Pendente
	3=Rejeitado
	4=Atualizado
	5=Pendente Desatualizacao
	6=Nao se Aplica
dData: Data a ser atribuida
tpAcaoInt: Tipo de integração, influencia em quais campos a situação e data serão atribuidos. 1 = Fiscal, 2 = Despesas, 3 = Ambos

@sample
GFEA100In()

@author Israel Possoli
@since 14/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA065In(cSituacao, dData, tpAcaoInt,cFatu)
	Local oModelPai := Nil
	Local oModel    := Nil
	Local aRet      := {.T., {}}
	Local aRetAux   := {.T.,"",""}
	Local cProg     := "1"
	Local cERPGFE   := SuperGetMv("MV_ERPGFE", .F., "2")
	Local lCpoTES	:= GFEA065INP()

	Private aMsgInfo := {}
	//*******************************************************************************************************************
	// Quando esta função (GFEA065In) for alterada é imprescindível olhar a função (GFEAIntGW3), pois elas são espelho
	// uma da outra, verificar se há necessidade de alterar as duas.
	//*******************************************************************************************************************
	If lCpoTES
		cSiGFE := SuperGetMv("MV_SIGFE", .F., "2")
	EndIf

	If cFatu == "1" .and. cERPGFE == "2"
		aRet := GFEAIntGW3(cSituacao, dData, tpAcaoInt,cFatu)
	Else
		oModelPai := FWLoadModel("GFEA065")
		oModel    := oModelPai:GetModel("GFEA065_GW3")
		If cSituacao == "5"
			//Desatualização do Documento de Frete no Protheus. Nova integração.
			//Uso do RecLock pelo confronto do retorno de erro do MsExecAuto com o model
			GFEA065IPG(tpAcaoInt, "5",, @aRetAux)
			If !Empty(aRetAux[2])
				If aRetAux[1]
					RecLock("GW3", .F.)
					If tpAcaoInt == "1" // Fiscal
						GW3->GW3_SITFIS := "1"
						GW3->GW3_DTFIS  := CtoD("  /  /  ")
						GW3->GW3_MOTFIS := ""
					ElseIf tpAcaoInt == "2" .And. !(GW3->GW3_TPDF == "3" .And. GW3->GW3_VLDF == 0) // Recebimento
						GW3->GW3_SITREC := "1"
						GW3->GW3_DTREC  := CtoD("  /  /  ")
						GW3->GW3_MOTREC := ""
					EndIf
					GW3->( MsUnlock() )

					Return {.T., {}}
				Else
					RecLock("GW3", .F.)
						If tpAcaoInt == "1" // Fiscal
							GW3->GW3_SITFIS := "4"
							GW3->GW3_MOTFIS := aRetAux[3]
						ElseIf tpAcaoInt == "2" // Recebimento
							GW3->GW3_SITREC := "4"
							GW3->GW3_MOTREC := aRetAux[3]
						EndIf
					GW3->( MsUnlock())

					Return {.F., {,,,,,aRetAux[3]}}
				EndIf
			EndIf
		EndIf
		oModelPai:SetOperation( 4 )
		oModelPai:Activate()

		If cERPGFE == "2" // Campo GW3_ACINT receberá quatro opções somente na integração Protheus
			If AllTRIM(tpAcaoInt) $ "1;3"
				oModel:SetValue( 'GW3_ACINT', "1" )
			ElseIf AllTRIM(tpAcaoInt) == "2"
				oModel:SetValue( 'GW3_ACINT', "2" )
			ElseIf AllTRIM(tpAcaoInt) == "4"
				oModel:SetValue( 'GW3_ACINT', "3" )
			ElseIf AllTRIM(tpAcaoInt) == "5"
				oModel:SetValue( 'GW3_ACINT', "4" )
			Else
				oModel:SetValue( 'GW3_ACINT', AllTRIM(tpAcaoInt) )
			EndIf
		EndIf

		If IsInCallStack("GFEA115AIN")
			cProg = "2"
		EndIf
		// Fiscal
		If tpAcaoInt $ "1;3" .And. oModel:getValue('GW3_SITFIS') != '6'

			oModel:SetValue('GW3_SITFIS', AllTrim(cSituacao))

			dbSelectArea('GW3')
			GW3->(dbSetOrder(1))
			If cSituacao != "5"
				RecLock('GW3', .F.)
					GW3->GW3_DTFIS := dData
				GW3->( MsUnlock() )
			EndIf

			If cSituacao == "2"
				oModel:ClearField('GW3_MOTFIS')
			EndIf

		EndIf

		// Recebimento
		If tpAcaoInt $ "2;3" .And. oModel:getValue('GW3_SITREC') != '6'

			oModel:SetValue('GW3_SITREC', AllTrim(cSituacao))

			If cSituacao != "5"
				oModel:SetValue('GW3_DTREC',  dData)
			EndIf

			If cSituacao == "2"
				oModel:ClearField('GW3_MOTREC')
			EndIf

		EndIf

		If cSituacao == "3" .Or. cSituacao == "4"
			// Geração da grade contábil
			GFERatDF(.F.,oModel:getValue("GW3_CDESP"),oModel:getValue("GW3_EMISDF"),oModel:getValue("GW3_SERDF"),oModel:getValue("GW3_NRDF"),oModel:getValue("GW3_DTEMIS"))
			If GFXTB12117("GWC")
				//Se for inclusão e o DF foi aprovado, verificar necessidade de gerar integração de custo de frete com TMS;
				//Se for alteração, por demanda, e for bloqueado, deve ser feita alteração para pendente;
				//Se for alteração, automático, e for aprovado, verificar necessidade de gerar integração de custo de frete com TMS.
				If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModelGW3:GetValue("GW3_SIT") == "3"
					GFEA065CTP("IA")
				ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
					If SuperGetMv("MV_GFEI21",.F.,"3") == "1" .And. oModelGW3:GetValue("GW3_SIT") == "2"
						GFEA065CTP("P")
					ElseIf SuperGetMv("MV_GFEI21",.F.,"3") == "2" .And. oModelGW3:GetValue("GW3_SIT") == "3"
						GFEA065CTP("E")
						GFEA065CTP("IA")
					EndIf
				EndIf
			EndIf
		EndIf

		If tpAcaoInt == "4"  // Pre-Nota

			oModel:SetValue('GW3_SITFIS', AllTrim(cSituacao))

			If cSituacao != "5"
				oModel:SetValue('GW3_DTFIS', dData)
			EndIf

			If cSituacao == "2"
				oModel:ClearField('GW3_MOTFIS')
			EndIf

		End If

		If tpAcaoInt == "5"  // Pre-CTE

			oModel:SetValue('GW3_SITREC', AllTrim(cSituacao))

			If cSituacao != "5"
				oModel:SetValue('GW3_DTREC', dData)
			EndIf

			If cSituacao == "2"
				oModel:ClearField('GW3_MOTREC')
			EndIf

		End If

		If oModelPai:VldData()
			oModelPai:CommitData()
			If !IsInCallStack("GFEA065")
				//Quando a integração não ocorreu, é necessário retornar falso e a mensagem de erro
				If tpAcaoInt $ "1;3;4"
					If oModel:GetValue('GW3_SITFIS') == "3" //Situação Rejeitado
						aRet := {.F., {,,,,,oModel:GetValue('GW3_MOTFIS'),,,}}
					EndIf
				EndIf
				If tpAcaoInt $ "2;3;5"
					If oModel:GetValue('GW3_SITREC') == "3" //Situação Rejeitado
						aRet := {.F., {,,,,,oModel:GetValue('GW3_MOTREC'),,,}}
					EndIf
				EndIf
			EndIf
		Else
			aRet := {.F., oModelPai:GetErrorMessage()}
		EndIf

		oModelPai:Deactivate()
		oModelPai:Destroy()
		oModelPai := nil

		If IsInCallStack("GFEA065") .And. !Empty(aMsgInfo)
			MsgInfo(aMsgInfo[1])
		EndIf 
	EndIf
Return aRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065DT()
Função utilizada em Integração para buscar a data que será utilizada.
Generico

@sample
GFEA065DT()

@author Israel Possoli
@since 29/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA065DT()
	Local dData := Date()
	Local lOk := .F.

	If !IsBlind()
		DEFINE DIALOG oDlg TITLE "Seleciona a data de transação no fiscal" FROM 180,180 TO 350,460 PIXEL //"Seleciona a Data"
			// Cria objeto
			oMsCalend := MsCalend():New(01,01,oDlg,.F.)

			// Define o dia a ser exibido no calendário
			oMsCalend:dDiaAtu := dData

			// Code-Block para mudança de Dia
			oMsCalend:bChange := {|| dData := oMsCalend:dDiaAtu}

			oTButton1 := TButton():New( 070, 30, STR0082,oDlg,{||lOk := .T.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Ok"
			oTButton1 := TButton():New( 070, 75, STR0083,oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

		ACTIVATE DIALOG oDlg CENTERED

		If !lOk
			dData := nil
		EndIf
	EndIf

Return dData

//-----------------------------------------------------------
Function GFEA065CC()
	Local lRet       := .T.
	Local aColsComp  := {}
	Local nSeqComp   := 000
	Local cNrCalcPri := ""
	Local S_VLCNPJ_2 := SuperGetMV('MV_VLCNPJ',,'1')

	If !(Alltrim(GW3->GW3_TPDF) $ "2;3") 	// 1=Normal;2=Complementar Valor;3=Complementar Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico

		GW4->(dbSetOrder(1))
		If GW4->(dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)))

			GWH->(dbSetOrder(2))
			GWH->(dbSeek(xFilial("GWH")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC))
			Do While GWH->(!Eof()) .and. xFilial("GWH")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC == xFilial("GW4")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC

				GWF->(dbSetOrder(1))
				GWF->(dbseek(xFilial("GWF")+GWH->GWH_NRCALC))

				IF GWF->GWF_TPCALC == GW3->GW3_TPDF .And. (GWF->GWF_TRANSP == GW3->GW3_EMISDF .Or. ;
				(s_VLCNPJ_2 == "2" .And. SubStr(Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_EMISDF, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8) ) )

					GWI->(dbSetOrder(1))
					GWI->(dbSeek(xFilial("GWI")+GWH->GWH_NRCALC))

					Do While GWI->(!Eof()) .and. GWI->GWI_NRCALC == GWH->GWH_NRCALC
						nSeqComp += 1
						aAdd(aColsComp,{nSeqComp ,; //Emitente do Documento
										GWI->GWI_CDCOMP,;  //Serie do Documento
										GWI->GWI_VLFRET,;
										GW3->GW3_EMISDF})

						cNrCalcPri := GWH->GWH_NRCALC

						GWI->(dbSkip())
					EndDo
				EndIf
				GWH->(dbSkip())
			EndDo

			If Empty(cNrCalcPri)
				nSeqComp += 1
				aAdd(aColsComp,{nSeqComp ,       ; //Emitente do Documento
								GWI->GWI_CDCOMP, ;  //Serie do Documento
								GWI->GWI_VLFRET, ;
								GW3->GW3_EMISDF})
			EndIf
		EndIf

		// Ponto de entrada
		If ExistBlock("GFEA6512")
			aColsComp := ExecBlock("GFEA6512", .F., .F., { aColsComp, cNrCalcPri })
		EndIf

		GFEA065A(aColsComp,cNrCalcPri)

	Else
		GFEMessage(5, GFEA065031, STR0550, STR0551)	// "Não é permitido gerar Documento de Frete Complementar associado a esse documento selecionado.", "Selecione um Documento de Frete com tipo diferente de Complementar para continuar."
		lRet := .F.
	EndIf
Return lRet

//---------------------------------------------------------------------------
Function GFEA065ADD(oPanel,oView)

	@ 10, 10 Button STR0087 Size 36, 13 Message STR0088 Pixel Action GFEADOCRE(FwFldGet("GW4_TPDC"),FwFldGet("GW4_EMISDC"),FwFldGet("GW4_SERDC"),FwFldGet("GW4_NRDC")) of oPanel //"Doc.Relac." ### "Documentos Relacionados"
	If GFXXB12117("GWJPRE")
		@ 30, 10 Button "Doc.Pré-Fat" Size 36, 13 Message STR0088 Pixel Action GFEADOCPF() of oPanel //"Doc.Pré-Fat." ### "Documentos Relacionados"
	EndIf
Return .T.

//---------------------------------------------------------------------------

Static Function GFEADOCRE(cTpDc, cEmisDc, cSerDc, cNrDc)
	Local oView       := FWViewActive()
	Local oModel      := oView:GetModel()
	Local oModelGW4   := oModel:GetModel("GFEA065_GW4")
	Local aAreaGWH    := GWH->(GetArea())
	Local aAreaGWF    := GWF->(GetArea())
	Local aPosGWH     := {}
	Local nLineaUX    := 0
	Local nTotLen     := 0
	Local nCalc       := 0
	Local nDC         := 0
	Local nChange     := 0
	Local aErroGW4    := {}
	Local cGW3_TPDF   := ""
	Local cGW3_EMISDF := ""

	If __lCpoSDoc == Nil
		__lCpoSDoc := Len(TamSX3("GW4_SDOCDC")) > 0
	EndIf

	nLineaUX := oModelGW4:GetLine()

	If oModelGW4:IsEmpty()
		Help(,,'HELP',, "Informe pelo menos um Documento de Carga para buscar os relacionados a ele.", 1, 0)
		Return .F.
	EndIf

	If oModelGW4:IsDeleted()
		Help(,,'HELP',, "O registro selecionado está deletado.", 1, 0)
		Return .F.
	EndIf

	If !oModelGW4:VldLineData()
		aErroGW4 := oModel:GetErrorMessage()
		Help(,,'HELP',, aErroGW4[6], 1, 0)
		Return .F.
	EndIf
	cGW3_TPDF 	:= FwFldGet("GW3_TPDF")
	cGW3_EMISDF	:= FwFldGet("GW3_EMISDF")

	GWH->(dbSetOrder(2))
	GWH->(dbSeek(xFilial("GWH") + cTpDc + cEmisDc + cSerDc + cNrDc))
	Do While GWH->(!Eof()) .And. ;
				GWH->GWH_FILIAL == xFilial("GWH") .And. ;
				GWH->GWH_CDTPDC == cTpDc .And. ;
				GWH->GWH_EMISDC == cEmisDc .And. ;
				GWH->GWH_SERDC  == cSerDc .And. ;
				GWH->GWH_NRDC   == cNrDc

		aPosGWH := GWH->( GetArea() )

		GWF->(dbSetOrder(1))
		If GWF->(dbSeek(xFilial("GWF") + GWH->GWH_NRCALC))
			If GWF->GWF_TPCALC == cGW3_TPDF .And. (!GFXCP12117("GW3_CDTPSE") .OR. FwFldGet("GW3_CDTPSE") == GWF->GWF_CDTPSE) .And. GWF->GWF_TRANSP == cGW3_EMISDF
				nCalc++

				GWH->(dbSetOrder(1))
				GWH->(dbSeek(xFilial("GWH") + GWF->GWF_NRCALC))
				Do While GWH->(!Eof()) .And. ;
							GWH->GWH_FILIAL == xFilial("GWH") .And. ;
							GWF->GWF_NRCALC == GWH->GWH_NRCALC

					GW1->(dbSetOrder(1))
					If GW1->(dbSeek(xFilial("GW1") + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC))

						If oModelGW4:SeekLine({{"GW4_TPDC", GW1->GW1_CDTPDC}, {"GW4_EMISDC", GW1->GW1_EMISDC}, ;
												{"GW4_SERDC", GW1->GW1_SERDC}, {"GW4_NRDC", GW1->GW1_NRDC}})

							If oModelGW4:IsDeleted()
								oModelGW4:UndeleteLine()
								nDc++
							ElseIf GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC != ;
								   cTpDc + cEmisDc + cSerDc + cNrDc
								nDc++
								nChange++
							EndIf

							oModelGW4:GoLine( nLineaUX )
							GWH->(dbSkip())
							Loop
						EndIf

						nTotLen := oModelGW4:Length() + 1

						If oModelGW4:AddLine() != nTotLen
							Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0)
						Else
							nDc++
							oModelGW4:LoadValue('GW4_TPDC'  , GW1->GW1_CDTPDC)
							oModelGW4:LoadValue('GW4_EMISDC', GW1->GW1_EMISDC)
							oModelGW4:LoadValue('GW4_NMEMIS', POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_EMISDC, "GU3_NMEMIT"))
							oModelGW4:LoadValue('GW4_SERDC' , GW1->GW1_SERDC )
							oModelGW4:LoadValue('GW4_NRDC'  , GW1->GW1_NRDC  )
							If __lCpoSDoc
								oModelGW4:LoadValue('GW4_SDOCDC', GW1->GW1_SDOC)
							EndIf
						EndIf

					EndIf
					GWH->(dbSkip())
				EndDo
			EndIf
		EndIf
		RestArea(aPosGWH)
		GWH->(dbSkip())
	EndDo
	RestArea(aAreaGWF)
	RestArea(aAreaGWH)

	oModelGW4:SetLine(nLineaUX)
	oView:Refresh()

	If nCalc == 0
		Help(,,'HELP',, "Não foram encontrados Cálculos do tipo " + GFEFldInfo("GW3_TPDF", FwFldGet("GW3_TPDF"), 2) + " para o Documento de Carga.", 1, 0)
	ElseIf nDC == 0
		Help(,,'HELP',, "Não foram encontrados outros Documentos de Carga para vincular ao Documento de Frete.", 1, 0)
	ElseIf nDC == nChange
		Help(,,'HELP',, "Todos os Documentos de Carga relacionados a este já foram vinculados.", 1, 0)
	EndIf
Return

/*Tipo de Tributação do Documento*/
Function GFEA065TTD()
	Local cEmisDf 	  := FwFldGet("GW3_EMISDF")
	Local cCdEsp 	  := FwFldGet("GW3_CDESP" )
	Local lRet    	  := "1"
	Local cTpImp  	  := ""

	/*Verifica tipo de imposto da especie do documento*/
	GVT->(dbSetOrder(1))
	If GVT->(dbSeek(xFilial("GVT")+cCdEsp))
		If GVT->GVT_TPIMP == "1"
			cTpImp := "1"  //ICMS
		Else
			cTpImp := "2"  //ISS
		EndIf
	EndIf

	GU3->(dbSetOrder(1))
	If GU3->(dbSeek(xfilial("GU3")+cEmisDf))
		If (cTpImp == "1" .And. GU3->GU3_CONICM == "2") .Or. (cTpImp == "2" .And. GU3->GU3_CONISS == "2")
			lRet := "2"
		Else
			If cTpImp == "1"
				If GU3->GU3_APUICM == "1"
					lRet := "1"
				ElseIf GU3->GU3_APUICM == "2"
					lRet := "3"
				ElseIf GU3->GU3_APUICM == "3"
					lRet := "4"
				ElseIf GU3->GU3_APUICM == "4"
					lRet := "7"
				EndIf
			ElseIf cTpImp == "2"
			If GU3->GU3_APUISS == "1"
				lRet := "1"
			Else
				lRet := "2"
			EndIf				
		EndIf
		EndIf
	EndIf
Return lRet

Function GFEA065BIM()
	Local cCdEsp  := FwFldGet("GW3_CDESP"  )
	Local nVlPeda := FwFldGet("GW3_PEDAG"  )
	Local cPdgFrt := FwFldGet("GW3_PDGFRT" )
	Local cIcmPdg := FwFldGet("GW3_ICMPDG" )
	Local nVlDf   := FwFldGet("GW3_VLDF"   )
	Local nVlBase := 0

	GVT->(dbSetOrder(1))
	If GVT->(dbSeek(xFilial("GVT")+cCdEsp))
		If GVT->GVT_TPIMP == "1" //ICMS
			If cPdgFrt == "1" .And. cIcmPdg == "2"
				If nVlDf > 0
					nVlBase := nVlDf - nVlPeda
				EndIf
			Else
				nVlBase := nVlDf
			EndIf
		EndIf
	EndIf
Return nVlBase

Function GFEA065VIM()
	Local nPcImp  := FwFldGet("GW3_PCIMP"  )
	Local nBasImp := FwFldGet("GW3_BASIMP" )
	Local cTpTrib := FwFldGet("GW3_TRBIMP" )
	Local nVlImp  := 0

	If cTpTrib == "2" .And. nPcImp > 0
		Return .F.
	EndIf
	nVlImp := nBasImp * ( nPcImp / 100 )
	nVlImp := VerifRoundABNT(nVlImp)

Return nVlImp

Function GFEA065ISE()
	Local cTpTrib := FwFldGet("GW3_TRBIMP" )
	Local nZeraVl := FwFldGet("GW3_PCIMP"  )

	If cTpTrib == "2"
		nZeraVl := 0
	EndIf

Return nZeraVl

//-----------------------------

Function GFEA065PRE()

	Local cTpTrib := FwFldGet("GW3_TRBIMP")
	Local cEmisDf := FwFldGet("GW3_EMISDF")
	Local cNrCid  := ""
	Local cCdUf   := ""
	Local cIcmPre := 0

	If cTpTrib == "7"
		cNrCid  := Posicione("GU3", 1,xFilial("GU3") + cEmisDf, "GU3_NRCID" )
		cCdUf   := Posicione("GU7", 1,xFilial("GU7") + cNrCid , "GU7_CDUF"  )
		cIcmPre := Posicione("GUT", 1,xFilial("GUT") + cCdUf  , "GUT_ICMPRE")
	EndIf

Return cIcmPre

//-----------------------------

Function GFEA065IMP()

	Local cTpTrib  := FwFldGet("GW3_TRBIMP")
	Local nBasImp  := FwFldGet("GW3_BASIMP")
	Local nPcImp   := FwFldGet("GW3_PCIMP")
	Local nPcRet   := FwFldGet("GW3_PCRET")
	Local nVlImpre := 0

	If cTpTrib == "7"
		nVlImpre := nBasImp * nPcImp / 100 * (1 - (nPcRet / 100))
		nVlImpre := VerifRoundABNT(nVlImpre)
	ElseIf cTpTrib == "3"
		nVlImpre := nBasImp * nPcImp / 100
		nVlImpre := VerifRoundABNT(nVlImpre)
	EndIf

Return nVlImpre

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA65GTRB
Gatilho dos campos CDESP e EMISDF
Sugere a tributação do documento de frete ao informar a Espécie e o Emissor

@sample
GFEA65GTRB()

@author Israel A Possoli
@since 13/11/09
@version 1.0
---------------------------------------------------------------------------------------------------*/
Function GFEA65GTRB()
	Local cCdEsp      := FwFldGet("GW3_CDESP")
	Local cCdEmis     := FwFldGet("GW3_EMISDF")
	Local cApuIcms    := ""
	Local cApuIss     := ""
	Local cTipoImpEsp := Posicione("GVT", 1, xFilial("GVT")+cCdEsp, "GVT_TPIMP")
	Local cCidTransp  := ""
	Local cCidOri     := ""
	Local cCidDest    := ""

	If !Empty(cCdEmis) .And. !Empty(cCdEsp)
		// ICMS ----------------------
		If cTipoImpEsp == "1"
			If Posicione("GU3", 1, xFilial("GU3")+cCdEmis, "GU3_CONICM") == "2" // Não contribuinte ICMS
				Return "2" // Isento/Não Tributado
			Else
				cApuIcms := GU3->GU3_APUICM
				If cApuIcms == "1" // Normal
					Return "1" // Tributado
				ElseIf cApuIcms == "2" // Subs. Tributária
					Return "3"
				ElseIf cApuIcms == "3" // Diferido
					Return "4"
				ElseIf cApuIcms == "4" // Presumido
					Return "7"
				EndIf
			EndIf
		EndIf

		// ISS ----------------------
		If cTipoImpEsp == "2"
			If Posicione("GU3", 1, xFilial("GU3")+cCdEmis, "GU3_CONISS") == "2" // Não contribuinte ISS
				Return "2" // Isento/Não Tributado
			Else
				cCidTransp  := GU3->GU3_NRCID
				cCidOri     := GWU->GWU_NRCIDO
				cCidDest    := GWU->GWU_NRCIDD

				IF  GFXCP1212410("GU3_APISSO") .AND. cCidTransp != cCidOri .AND. cCidTransp != cCidDest 
					cApuIss := GU3->GU3_APISSO
				ELSE
					cApuIss := GU3->GU3_APUISS
				ENDIF
				
				If cApuIss == "1" // Normal
					Return "1" // Tributado
				ElseIf cApuIss == "2" // Subs. Tributária
					Return "3"
				ElseIf cApuIss == "3" // Diferido
					Return "4"
				ElseIf cApuIss == "4" // Presumido
					Return "7"
				EndIf			
			EndIf
		EndIf
	EndIf
Return FwFldGet("GW3_TRBIMP")

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA44COPY
Função chamada após a ativação do Model

@sample
GFEA65ACT(oModel)

@author Octávio Augusto Felippe de Macedo
@since 24/02/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFEA65ACT(oModel)
	Local oModelGW3 := oModel:GetModel("GFEA065_GW3")
	Local aFieldGW3 := oModelGW3:GetStruct():aFields
	Local nI        := 0
	Local nF        := 0
	Local aCmpGW3   := {""}


	If GFEA065INP()
		aCmpGW3 := {"GW3_CDESP", "GW3_EMISDF", "GW3_SERDF", "GW3_DTEMIS", "GW3_CDREM", "GW3_CDDEST", "GW3_TPDF", "GW3_DTENT", "GW3_CFOP", ;
					"GW3_PDGFRT", "GW3_ICMPDG", "GW3_PDGPIS", "GW3_TRBIMP", "GW3_PCIMP", "GW3_CDCONS", "GW3_OBS", "GW3_DSOFIT", "GW3_DSOFDT", ;
					"GW3_PCRET", "GW3_TPIMP", "GW3_PRITDF", "GW3_CPDGFE", "GW3_CONTA", "GW3_ITEMCT", "GW3_CC", "GW3_TES" }
	Else
		aCmpGW3 := {"GW3_CDESP", "GW3_EMISDF", "GW3_SERDF", "GW3_DTEMIS", "GW3_CDREM", "GW3_CDDEST", "GW3_TPDF", "GW3_DTENT", "GW3_CFOP", ;
					"GW3_PDGFRT", "GW3_ICMPDG", "GW3_PDGPIS", "GW3_TRBIMP", "GW3_PCIMP", "GW3_CDCONS", "GW3_OBS", "GW3_DSOFIT", "GW3_DSOFDT", ;
					"GW3_PCRET", "GW3_TPIMP", "GW3_PRITDF" }
	EndIf

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	dDataDf := oModel:getValue("GFEA065_GW3","GW3_DTENT")

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:GetModel('GFEA065_GW3'):SetValue('GW3_DTENT',dDataBase)
	EndIf

	If IsInCallStack("GFEA065") .And. lCopy
		nF := Len(aFieldGW3)
		For nI := 1 To nF

			If aFieldGW3[nI][3] == "GW3_SIT"
				oModelGW3:SetValue(aFieldGW3[nI][3], "1")
			ElseIf aFieldGW3[nI][3] == "GW3_SITFIS"
				oModelGW3:SetValue(aFieldGW3[nI][3], "1")
			ElseIf aFieldGW3[nI][3] == "GW3_SITREC"
				oModelGW3:SetValue(aFieldGW3[nI][3], "1")
			ElseIf aFieldGW3[nI][3] == "GW3_USUIMP"
				oModelGW3:SetValue(aFieldGW3[nI][3], cUserName)
			ElseIf aFieldGW3[nI][3] == "GW3_DTENT"
				Loop
			ElseIf aFieldGW3[nI][3] == "GW3_DESCUS"
				If GFXTB12117("GWC")
					oModelGW3:SetValue(aFieldGW3[nI][3], GFEA065GTP(oModelGW3:GetValue("GW3_TPDF")))
				EndIf
			ElseIf aFieldGW3[nI][3] == "GW3_SITCUS"
				If GFXTB12117("GWC")
					oModelGW3:SetValue(aFieldGW3[nI][3], IIf (GFEA065CTA(), "1", "0")) //mesma lógica do X3_RELACAO do campo GW3_SITCUS
				EndIf
			ElseIf aFieldGW3[nI][14]
				Loop
			ElseIf aScan( aCmpGW3, {|x| x == aFieldGW3[nI][3] } ) > 0
				oModelGW3:SetValue(aFieldGW3[nI][3], &("GW3->"+aFieldGW3[nI][3]))
			Else
				oModel:ClearField("GFEA065_GW3", aFieldGW3[nI][3])
			EndIf
		Next nI
		lCopy := .F.
	EndIf
Return Nil

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA65COPY
Rotina que executa a view quando for cópia do Documentos de Frete

@sample
GFEA65COPY()

@author Octávio Augusto Felippe de Macedo
@since 24/02/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFEA65COPY()
	lCopy := .T.
	FWExecView(STR0089,"GFEA065",3,,{|| .T.}) //"Cópia"
Return Nil

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065GW8
Rotina para preencher o model com a chave dos itens utilizada na integração

@sample
GFEA065GW8()

@author Octávio Augusto Felippe de Macedo
@since 24/02/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA065GW8(oModel)
	Local nCont     := 0
	Local nFCont    := 0
	Local aStruc    := {}//Array para armazenar o struct da tabela
	Local aRet      := {}//Array de retorno com os regitros. Formato ##array{ #linha{#recno 1, #campos{,,,}}, #linha{#recno 2, #campos{,,,}} }
	Local aCmp      := {}
	Local nRec      := 1 //Número de registros
	Local aInfo01   := {}
	Local oModelGW4 := oModel:GetModel():GetModel("GFEA065_GW4")

	aStruc := oModel:GetStruct() //Struct da tabela

	GW8->(dbSetOrder(1))
	GW8->(dbSeek(xFilial("GW8") + oModelGW4:GetValue("GW4_TPDC") + oModelGW4:GetValue("GW4_EMISDC") + oModelGW4:GetValue("GW4_SERDC") + oModelGW4:GetValue("GW4_NRDC")))
	Do While GW8->(!Eof()) .And. xFilial("GW8") == GW8->GW8_FILIAL .And. oModelGW4:GetValue("GW4_TPDC") == GW8->GW8_CDTPDC .And. ;
				oModelGW4:GetValue("GW4_EMISDC") == GW8->GW8_EMISDC .And. oModelGW4:GetValue("GW4_SERDC") == GW8->GW8_SERDC .And. ;
				oModelGW4:GetValue("GW4_NRDC") == GW8->GW8_NRDC

		If aScan(aInfo01, {|x| x == GW8->GW8_INFO1}) == 0
			nFCont := Len(aStruc:aFields)
			For nCont := 1 To nFCont
				AAdd(aCmp, &("GW8->" + aStruc:aFields[nCont][3]))
			Next nCont
			//Monta o array de acordo com a sequência de campos do struct, para ser mostrado no grid.
			AAdd(aRet, {nRec, aCmp})

			aCmp := {}
			nRec++

			AAdd(aInfo01, GW8->GW8_INFO1)
		EndIf
		GW8->(dbSkip())
	EndDo
	//Caso não encontre registros, permanece o array em branco Obs: Permanecer todas as 'vírgulas' para não ocorrer erros
	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:aFields)-1) + "}")}}
	EndIf
Return aRet

/*----------------------------------------------------------------------
Função para a geração automática da fatura para o documento de frete
----------------------------------------------------------------------*/

Function GFEA65GFAT(lInterface)
	Local aValues    :={}
	Local aAreaGW3   := GW3->( GetArea() )
	Local cAliasQry  := Nil
	Local dDtVenc    := Nil
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1")  .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local s_GFEPF1   := SuperGetMv("MV_GFEPF1",,'1')

	If lInterface .And. !(GW3->GW3_SIT $ "3;4")
		Help( ,, 'Help',, "O Documento de Frete deve estar aprovado para a geração da Fatura.", 1, 0 ) //"O Documento de Frete deve estar aprovado para a geração da Fatura."
		Return
	EndIf

	If !lInterface .And. Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_EMISDF, "GU3_FATAUT") != "1"
		Return
	EndIf

	If lInterface
		GW6->( dbSetOrder(1) )
		If GW6->(dbSeek(xFilial("GW6") + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF ))
			Help( ,, 'Help',, "Fatura já cadastrada no sistema. A fatura já existe no sistema portanto este documento de frete deverá ser vinculado a uma fatura manualmente.", 1, 0 )
			Return
		EndIf
	elseIf IsInCallStack("GFEA066OK")
		GW6->(dbSetOrder(1))
		If GW6->(dbSeek(xFilial("GW6") + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF ))
			If (GW6->GW6_SITFIN == '1')
				Help( ,, 'Help',, "Fatura já cadastrada no sistema. A fatura já existe no sistema portanto este documento de frete deverá ser vinculado a uma fatura manualmente.", 1, 0 )
				Return
			EndIf
		EndIf
	ElseIf (IsInCallStack("GFEA065") .Or. IsInCallStack("GFEA115")) .And. (GW3->GW3_SIT == "3" .Or. GW3->GW3_SIT == "4")
		GW6->(dbSetOrder(1))
		If GW6->(dbSeek(xFilial("GW6") + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF ))
			If (GW6->GW6_SITFIN == '1')
				Help( ,, 'Help',, "Fatura já cadastrada no sistema. A fatura já existe no sistema portanto este documento de frete deverá ser vinculado a uma fatura manualmente.", 1, 0 )
				Return
			EndIf
		EndIf
	ElseIf (IsInCallStack("GFEA065") .Or. IsInCallStack("GFEA115")) .And. (GW3->GW3_SIT == "1".or.GW3->GW3_SIT == "2")
		GW6->(dbSetOrder(1))
		If GW6->(dbSeek(xFilial("GW6") + FwFldGet("GW3_EMISDF") + FwFldGet("GW3_SERDF") + (FwFldGet("GW3_NRDF") )))
			Help( ,, 'Help',, "Fatura já cadastrada no sistema. A fatura já existe no sistema portanto este documento de frete deverá ser vinculado a uma fatura manualmente.", 1, 0 )
			Return
		EndIf
	ElseIF IsInCallStack("GFEA065XF")
		GW6->(dbSetOrder(1))
		If GW6->(dbSeek(xFilial("GW6") + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF ))
			Return
		EndIf
	EndIf

	If !Empty(GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA))
		If lInterface
			Help( ,, 'Help',, "O Documento de Frete já está vinculado a uma Fatura.", 1, 0 ) //"O Documento de Frete já está vinculado a uma Fatura."
		EndIf
		Return
	EndIf

	If GW3->GW3_TPDF == "3" .And. GW3->GW3_VLDF == 0
		If lInterface
			Help( ,, 'HELP',, "Não é permitido gerar uma fatura para o documento de frete deste tipo com valor zerado.", 1, 0)
		EndIf
		Return
	EndIf

	If !Empty(GW3->GW3_DTVNFT)
		dDtVenc := GW3->GW3_DTVNFT
	Else
		dDtVenc := GFECalcVc(GW3->GW3_DTEMIS, GW3->GW3_EMISDF)
		If lInterface
			If __cGFECVFA == '3' .Or. (__cGFECVFA == '1' .And. Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_EMISDF, "GU3_CALCVC") == '2')
				DEFINE DIALOG oDlg TITLE "Selecione a Data de Vencimento" FROM 180,180 TO 350,460 PIXEL
					oMsCalend := MsCalend():New(01,01,oDlg,.F.)
					oMsCalend:dDiaAtu := dDtVenc
					oMsCalend:bChange := {|| dDtVenc := oMsCalend:dDiaAtu}
					oTButton1 := TButton():New( 070, 30, "Ok" ,oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Ok"
					lOK := .T.
				ACTIVATE DIALOG oDlg CENTERED
			EndIf
		EndIf
	EndIf

	If Empty(dDtVenc)
		dDtVenc := GW3->GW3_DTENT
	EndIf

	aValues := {;
				{{"GW6_FILIAL", xFilial("GW6") },;
				{"GW6_EMIFAT" , GW3->GW3_EMISDF},;
				{"GW6_NRFAT"  , GW3->GW3_NRDF  },;
				{"GW6_SERFAT" , GW3->GW3_SERDF },;
				{"GW6_DTEMIS" , GW3->GW3_DTEMIS},;
				{"GW6_DTCRIA" , GW3->GW3_DTENT },;
				{"GW6_DTVENC" , dDtVenc        },;
				{"GW6_VLFATU" , GW3->GW3_VLDF  },;
				{"GW6_ORIGEM" , "3"},;
				{"GW6_SITAPR" , "1"},;
				{"GW6_SITFIN" , "1"}};
				}

	If GFXCP12130("GW6_NATURE")
		aAdd(aValues[1],{"GW6_NATURE" ,SuperGetMv("MV_NTFGFE",,"")})
	EndIf

	If GFXCP12117("GW6_USUIMP")
		aAdd(aValues[1],{"GW6_USUIMP" ,CUSERNAME})
	EndIf

	If GFEINSFAT(aValues) //Insere fatura através do model

		//Relaciona o Documento de Frete à pré-fatura.
		RecLock("GW3", .F.)
			GW3->GW3_FILFAT := xFilial("GW6")
			GW3->GW3_EMIFAT := GW3->GW3_EMISDF
			GW3->GW3_SERFAT := GW3->GW3_SERDF
			GW3->GW3_NRFAT  := GW3->GW3_NRDF
			GW3->GW3_DTEMFA := GW3->GW3_DTEMIS
		GW3->(MSUnlock())

		GW6->( dbSetOrder(1) )
		If GW6->( dbSeek( xFilial("GW6") + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF +  DToS(GW3->GW3_DTEMFA)) )
			//Soma valor dos impostos
			If Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '1'
				RecLock("GW6", .F.)
					GW6->GW6_VLICMS := GFETratDec((GW3->GW3_VLIMP),0,.T.)
					GW6->GW6_VLICRE := GW3->GW3_IMPRET
				GW6->(MsUnLock())
			Else
				RecLock("GW6", .F.)
					GW6->GW6_VLISS := GFETratDec((GW3->GW3_VLIMP),0,.T.)
					GW6->GW6_VLISRE := GW3->GW3_IMPRET
				GW6->(MsUnLock())
			EndIf

			//Relaciona as Pré-faturas


			If lExistCamp //Utiliza novo indice para buscar pré-faturas
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT DISTINCT GWJ.R_E_C_N_O_ RECNOGWJ
					FROM %Table:GWF% GWF
					INNER JOIN %Table:GWJ% GWJ
					ON GWJ.GWJ_FILIAL = GWF.GWF_FILIAL
					AND GWJ.GWJ_NRPF = GWF.GWF_NRPREF
					AND GWJ.GWJ_SIT = '3'
					AND GWJ.GWJ_SITFIN = '4'
					AND GWJ.GWJ_CDTRP = %Exp:GW6->GW6_EMIFAT%
					AND GWJ.GWJ_FILFAT = '  '
					AND GWJ.GWJ_EMIFAT = '  '
					AND GWJ.GWJ_SERFAT = '  '
					AND GWJ.GWJ_NRFAT  = '  '
					AND GWJ.GWJ_DTEMFA = '  '
					AND GWJ.%NotDel%
					WHERE GWF.GWF_FILIAL = %Exp:GW3->GW3_FILIAL%
					AND GWF.GWF_CDESP  = %Exp:GW3->GW3_CDESP%
					AND GWF.GWF_EMISDF = %Exp:GW3->GW3_EMISDF%
					AND GWF.GWF_SERDF = %Exp:GW3->GW3_SERDF%
					AND GWF.GWF_NRDF = %Exp:GW3->GW3_NRDF%
					AND GWF.GWF_DTEMDF = %Exp:DToS(GW3->GW3_DTEMIS)%
					AND GWF.%NotDel%
				EndSql
				Do While (cAliasQry)->(!EoF())
					GWJ->(dbGoTo((cAliasQry)->RECNOGWJ))
					RecLock("GWJ", .F.)
						GWJ->GWJ_FILFAT := xFilial("GW6")
						GWJ->GWJ_EMIFAT := GW3->GW3_EMISDF
						GWJ->GWJ_SERFAT := GW3->GW3_SERDF
						GWJ->GWJ_NRFAT  := GW3->GW3_NRDF
						GWJ->GWJ_DTEMFA := GW3->GW3_DTEMIS
					GWJ->(MsUnLock())
					(cAliasQry)->(dbSkip())
				EndDo
			Else
				GW4->(dbSetOrder(1))
				GW4->(dbSeek(xFilial('GW4') + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)))
				Do While GW4->(!Eof()) .And. GW4->GW4_FILIAL == xFilial('GW4') .And. GW4->GW4_CDESP == GW3->GW3_CDESP .And. ;
							GW4->GW4_EMISDF == GW3->GW3_EMISDF .And. GW4->GW4_SERDF == GW3->GW3_SERDF .And. GW4->GW4_NRDF == GW3->GW3_NRDF .And.;
							DtoS(GW4->GW4_DTEMIS) == DToS(GW3->GW3_DTEMIS)

					GWH->(dbSetOrder(2))
					GWH->(dbSeek(xFilial('GWH') + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC))
					Do While GWH->(!Eof()) .And. GWH->GWH_FILIAL == xFilial('GWH') .And. GWH->GWH_CDTPDC == GW4->GW4_TPDC .And. ;
								GWH->GWH_EMISDC == GW4->GW4_EMISDC .And. GWH->GWH_SERDC == GW4->GW4_SERDC .And. GWH->GWH_NRDC == GW4->GW4_NRDC

						GWF->(dbSetOrder(1))
						If GWF->(dbSeek(xFilial('GWF') + GWH->GWH_NRCALC)) .And. GWF->GWF_TPCALC == GW3->GW3_TPDF .And. (!GFXCP12117("GW3_CDTPSE") .OR. GW3->GW3_CDTPSE == GWF->GWF_CDTPSE)
							GWJ->(dbSetOrder(1))
							If GWJ->(dbSeek(GWF->GWF_FILPRE + GWF->GWF_NRPREF)) .And.;
								((s_GFEPF1 == '1' .AND. GWJ->GWJ_SIT == "3") .OR.;
								(s_GFEPF1 == '2' .AND. (GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "3") )) .AND.;
								(GWJ->GWJ_CDTRP  == GW6->GW6_EMIFAT) .And.;
						 	 	Empty(GWJ->GWJ_FILFAT + GWJ->GWJ_EMIFAT + GWJ->GWJ_SERFAT + GWJ->GWJ_NRFAT + DToS(GWJ->GWJ_DTEMFA)) .And.;
						 	 	GWJ->GWJ_SITFIN == "4"

								RecLock("GWJ", .F.)
									GWJ->GWJ_FILFAT := xFilial("GW6")
									GWJ->GWJ_EMIFAT := GW3->GW3_EMISDF
									GWJ->GWJ_SERFAT := GW3->GW3_SERDF
									GWJ->GWJ_NRFAT  := GW3->GW3_NRDF
									GWJ->GWJ_DTEMFA := GW3->GW3_DTEMIS
								GWJ->(MsUnLock())
								Exit
							EndIf
						EndIf
						GWH->(dbSkip())
					EndDo
					GW4->( dbSkip() )
				EndDo
			EndIf
			If lInterface
				MsgInfo("Fatura gerada com sucesso.") //"Fatura gerada com sucesso."
			EndIf

			GFEA070CO() //Conferência da Fatura
		EndIf
	EndIf
	RestArea(aAreaGW3)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE065CFOP
Função que retorna o CFOP de acordo com a UF do emitente x destinatario
Uso Restrito do Dicionario.

@author Cristiane Horr
@since 28/06/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE065CFOP()
	Local cCidRem  := ""
	Local cCidDes  := ""
	Local cCFOP    := ""
	Local cCFOPAtu := M->GW3_CFOP
	Local cCFOFR1  := SuperGetMV("MV_CFOFR1",.T.,"")
	Local cCFOFR2  := SuperGetMV("MV_CFOFR2",.T.,"")

	If Empty(M->GW3_CDREM) .OR. Empty(M->GW3_CDDEST)
		Return cCFOPAtu
	EndIf

	cCidRem := Posicione("GU3",1,XFILIAL("GU3")+M->GW3_CDREM,"GU3_NRCID")
	cCidDes := Posicione("GU3",1,XFILIAL("GU3")+M->GW3_CDDEST,"GU3_NRCID")

	If Posicione("GU7",1, xfilial("GU7")+cCidRem, "GU7_CDUF") == Posicione("GU7",1, xfilial("GU7")+cCidDes, "GU7_CDUF")
		cCFOP := cCFOFR1
	Else
		cCFOP := cCFOFR2
	EndIf

	If !Empty(M->GW3_CFOP) .And. M->GW3_CFOP != cCFOFR1 .And. M->GW3_CFOP != cCFOFR2
		Return cCFOPAtu
	EndIf

Return cCFOP

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para retornar o valor da Base de Imposto de acordo  ³
//³com os campos de Valor do Documento e a parametrização     ³
//³do pedágio                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

Function GFEA065BAS()
	Local nBaseImp := M->GW3_VLDF

	If nBaseImp != 0 .And. M->GW3_PEDAG != 0 .And. Posicione("GVT", 1, xFilial('GVT') + M->GW3_CDESP, "GVT_TPIMP") != '2'
		If M->GW3_PDGFRT == "1" .And. M->GW3_ICMPDG == "2"
			nBaseImp -= FwFldGet("GW3_PEDAG")
		ElseIf FwFldGet("GW3_PDGFRT") == "2" .And. FwFldGet("GW3_ICMPDG") == "1"
			nBaseImp += FwFldGet("GW3_PEDAG")
		EndIf
	EndIf
Return nBaseImp

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE065VCTE
Função que valida a chave do Ct-e

@retorno Array duas posições
	[1] Sucesso true/false
	[2] Mensagem de erro

@author Lidiomar Fernando dos Santos Machado
@since 11/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE065VCTE(cChvCte, cEmissor, cSerie, cNumero, dDataEmis)
	Local cUF         := Substr(cChvCte,1,2)  //Código da UF do emitente do Documento Fiscal
	Local cAAMM       := Substr(cChvCte,3,4)  //Ano e Mês de emissão do CT-e
	Local cCNPJ       := Substr(cChvCte,7,14) //CNPJ do emitente
	Local cMod        := Substr(cChvCte,21,2) //Modelo do Documento Fiscal
	Local cSerieChave := Substr(cChvCte,23,3) //Série do Documento Fiscal
	Local cNct        := Substr(cChvCte,26,9) //Número do Documento Fiscal
	Local cTpEmis     := Substr(cChvCte,35,1) //Forma de emissão do CT-e
	Local cCdEsp      := FwFldGet("GW3_CDESP" )
	Local cNrCid      := ""
	Local cUfBrw      := ""
	Local cAAMMBrw    := ""
	Local cCNPJBrw    := ""
	Local cTpEmisStr  := ""
	Local aRet        := Array(2)
	Local cAliasTmp   := ""

	aRet[1] := .F.
	aRet[2] := ""

	/*Verifica tipo de imposto da especie do documento*/
	GVT->(dbSetOrder(1))
	If GVT->(dbSeek(xFilial("GVT")+cCdEsp))
		If GVT->(FieldPos("GVT_CHVCTE")) > 0 .And. GVT->GVT_CHVCTE == "3"
			aRet[1] := .T.
			Return(aRet)
		EndIf
		If GVT->GVT_TPIMP == "1"
			If Len(cChvCte) != 44
				aRet[2] := "Número de caracteres informado no campo Chave Ct-e inválido."
				Return (aRet)
			EndIf

			cNrCid := Posicione("GU3",1,xFilial("GU3")+cEmissor,"GU3_NRCID")
			cUfBrw := Posicione("GU7",1,xFilial("GU7")+cNrCid,"GU7_CDUF")

			cAAMMBrw := Substr(strtran(DtoS(dDataEmis),"/"),3,2) + Substr(strtran(DtoS(dDataEmis),"/"),5,2)

			cCNPJBrw := AllTrim(Posicione("GU3",1,xFilial("GU3")+cEmissor,"GU3_IDFED"))

			// Valida se a UF do conhecimento é a mesma da chave
			If (GFE065RUF(cUF, 2) == "0") .Or. (GFE065RUF(cUF, 2) != "0" .And. GFE065RUF(cUF, 2) != cUfBrw)
				aRet[2] := "UF da chave difere da chave do documento de frete."
				Return (aRet)
			EndIf

			// Validação do Ano e o mês
			If cAAMM != cAAMMBrw
				aRet[2] := "Ano e mês da chave difere do documento de frete."
				Return (aRet)
			EndIf

			// Validação do CNPJ
			If cCNPJ != cCNPJBrw
				aRet[2] := "CNPJ da chave difere do documento de frete."
				Return (aRet)
			EndIf

			If cMod != "57" //Utilizar o código 57 para identificação do CT-e, emitido em substituição aos modelos de conhecimentos em papel.
				aRet[2] := "Modalidade de transporte inválido."
				Return (aRet)
			EndIf

			// Validação da série
			If (Empty(cSerie) .And. cSerieChave != "000") .Or. ( !Empty(cSerie) .And. PADL(AllTrim(cSerie), 3, "0") != cSerieChave)
				aRet[2] := "Série da chave difere do documento de frete."
				Return (aRet)
			EndIf

			// Validação do número do conhecimento

			If Val(cNct) != Val(cNumero)
				aRet[2] := "Número do conhecimento da chave difere do documento de frete."
				Return (aRet)
			EndIf


			If !cTpEmis $ "1;4;5;7;8" //1 - Normal; 4 - EPEC pela SVC, 5 - Contingência FSDA;
				cTpEmisStr := "Código inválido."

				aRet[2] := "Tipo emissão inválida. [" + cTpEmis + "] " + cTpEmisStr

				Return (aRet)
			EndIf

			If !GFE065VLDV(cChvCte)
				aRet[2] := "Digito verificador inválido."
				Return (aRet)
			EndIf

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT GW3_NRDF
				FROM %Table:GW3% GW3
				WHERE GW3_CTE = %Exp:cChvCte%
				AND (GW3_FILIAL <> %xFilial:GW3%
					OR GW3_CDESP <> %Exp:cCdEsp%
					OR GW3_EMISDF <> %Exp:cEmissor%
					OR GW3_SERDF <> %Exp:cSerie%
					OR GW3_NRDF <> %Exp:cNumero%
					OR GW3_DTEMIS <> %Exp:Dtos(dDataEmis)%)
				AND GW3.%NotDel%
			EndSql
			If (cAliasTmp)->(!Eof())
				aRet[2] := "Já existe uma chave ct-e igual cadastrada."
				(cAliasTmp)->(dbCloseArea())
				Return aRet
			EndIf
			(cAliasTmp)->(dbCloseArea())
			aRet[1] := .T.
		EndIf
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE065RUF
Função que retorna o código da UF de acordo com a
codificação da UF definida pelo IBGE

@author Lidiomar Fernando dos Santos Machado
@since 11/02/2013
@version 1.0
/*/
/*
Tipo 1: recebe cUF como Sigla  e retorna código
Tipo 2: recebe cUF como código e retorna Sigla
*/
//-------------------------------------------------------------------

Function GFE065RUF(cUF, nTipo)

	Local aUf       := {{"RO","11"},;
		{"AC","12"},;
		{"AM","13"},;
		{"RR","14"},;
		{"PA","15"},;
		{"AP","16"},;
		{"TO","17"},;
		{"MA","21"},;
		{"PI","22"},;
		{"CE","23"},;
		{"RN","24"},;
		{"PB","25"},;
		{"PE","26"},;
		{"AL","27"},;
		{"SE","28"},;
		{"BA","29"},;
		{"MG","31"},;
		{"ES","32"},;
		{"RJ","33"},;
		{"SP","35"},;
		{"PR","41"},;
		{"SC","42"},;
		{"RS","43"},;
		{"MS","50"},;
		{"MT","51"},;
		{"GO","52"},;
		{"DF","53"}}

	Local bSeek     := Nil
	Local cUfArray  := ""
	Local cPosArray := ""

	bSeek := {|cUfArray|,cUfArray[nTipo] == cUF}
	cPosArray := aScan(aUf,bSeek)

	If cPosArray != 0
		If nTipo == 1
			Return aUf[cPosArray][2]
		Else
			Return aUf[cPosArray][1]
		EndIf
	EndIf
Return "0"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE065VLDV
Função que valida o digito verificador
da chave de acesso do CT-e

@author Lidiomar Fernando dos Santos Machado
@since 11/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE065VLDV(cChvAcesso)
	Local cDigChave := Substr(cChvAcesso,44,1)
	Local cDigCalc	:= GFEA065DVC(cChvAcesso)
Return cDigChave == cDigCalc

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065DVC
Função que calcula o digito verificador
da chave de acesso do CT-e

@author Siegklenes.Beulke
@since 06/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA065DVC(cChvAcesso)
	Local cDigCalc   := ""
	Local aChvAcesso := {}
	Local nResto     := 0
	Local nSomaChvAc := 0
	Local nI         := 0
	Local nCont      := 2

	For	nI := 1 To 43
		AADD(aChvAcesso,AllTrim(substr(cChvAcesso,nI,1)))
	Next nI

	For	nI := 43 To 1 STEP -1
		nSomaChvAc := nSomaChvAc + Val(aChvAcesso[nI]) * nCont
		If nCont == 9
			nCont := 2
		Else
			nCont++
		EndIf
	Next nI

	nResto := nSomaChvAc % 11

	If nResto == 0 .OR. nResto == 1
		cDigCalc := "0"
	Else
		cDigCalc  := ALLTRIM(STR(11 - (nResto)))
	EndIf
Return cDigCalc

/*-------------------------------------------------------------------
{Protheus.doc} IsNumeric
Verifica se uma string contem somente numeros

@author Lucas Manolli de Oliveira Cristo
@since 20/06/2014
@version 1.0
-------------------------------------------------------------------*/
Function IsNumeric(cSerire)
	Local nPos := 0
	Local nLen := 0

	cSerire := AllTrim(cSerire)
	nLen    := Len(cSerire)
	For nPos := 1 to nLen
		If !IsDigit( Substr( cSerire, nPos, 1 ) )
			Return .F.
		EndIf
	Next nPos
Return .T.

/*-------------------------------------------------------------------
{Protheus.doc} GFE065PCTE
Função de sugestão de preenchimento do campo CT-e

@author Lidiomar Fernando dos Santos Machado
@since 11/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE065PCTE()
	Local cNrCid    := ""
	Local cUf       := ""
	Local cCdUf     := ""
	Local cAAMM     := ""
	Local cCNPJ     := ""
	Local cCteParte := "" //Parte do Código
	Local cCdEsp    := FwFldGet("GW3_CDESP" )
	Local lCmpCte   := .F.
	//dados para fazer integridade da serie quando o emissor estiver parametrizado para gerar a chave ct-e
	Local cSerie    := FwFldGet("GW3_SERDF")
	Local cEmissor  := FwFldGet("GW3_EMISDF")

	/*Verifica tipo de imposto da especie do documento*/

	GVT->(dbSetOrder(1))
	lCmpCte := GVT->(FieldPos("GVT_CHVCTE")) > 0
	If GVT->(dbSeek(xFilial("GVT")+cCdEsp))
		If GU3->(dbSeek(xFilial("GU3")+cEmissor))
			If (GU3->GU3_CTE == "1") .And. !(IsNumeric(cSerie)) .And. (GVT->GVT_TPIMP != "2")
				If !lCmpCte .Or. (lCmpCte .And. GVT->GVT_CHVCTE != "3") //Se a espécie do documento de frete estiver configurada para não informar a Chave do CT-e, não deve forçar a digitação da mesma.
					MsgInfo("Transportador cadastrado para gerar chave ct-e, série do documento tem que ser númerica.")
					Return .F.
				EndIf
			EndIf
		EndIf
		If GVT->GVT_TPIMP == "1"
			If lCmpCte .And. GVT->GVT_CHVCTE == "3"
				Return cCteParte
			EndIf
			If Empty(M->GW3_EMISDF) .Or. Empty(M->GW3_DTEMIS) .Or. Empty(M->GW3_NRDF) .Or. !Empty(M->GW3_CTE) ;
				.Or. Posicione("GU3", 1, xFilial("GU3")+ M->GW3_EMISDF, "GU3_CTE") == "2"

				Return M->GW3_CTE
			EndIf

			cNrCid := Posicione("GU3" ,1, xFilial("GU3")+ M->GW3_EMISDF,"GU3_NRCID")
			cUf    := Posicione("GU7",1,xFilial("GU7")+cNrCid,"GU7_CDUF") //Uf no formato sigla
			cCdUf  := GFE065RUF(cUF, 1) // UF no formato código

			cAAMM   := Substr(strtran(DtoS(M->GW3_DTEMIS),"/"),3,2)  + Substr(strtran(DtoS(M->GW3_DTEMIS),"/"),5,2)
			cCNPJ   := Padr(Posicione("GU3",1,xFilial("GU3")+M->GW3_EMISDF,"GU3_IDFED"),14)
			cMod    := "57" //Utilizar o código 57 para identificação do CT-e, emitido em substituição aos modelos de conhecimentos em papel.
			cSerie  := PadL(AllTrim(Substr(M->GW3_SERDF,1,3)),3,"0")
			cNct    := PadL(AllTrim(Substr(M->GW3_NRDF,1,9)),9,"0")
			cTpEmis := "1" //1 - Normal; 5 - Contingência FSDA; 7 - Autorização pela SVC-RS; 8 - Autorização pela SVC-SP
			cCteParte := Padr(cCdUf+cAAMM+cCNPJ+cMod+cSerie+cNct+cTpEmis,TamSx3("GW3_CTE")[1])
		Else
			cCteParte := " "
		EndIf
	EndIf
Return cCteParte

//-------------------------------------------------------
Function GFE065CAMP()
	GVT->(dbSetOrder(1))
	If GVT->(dbSeek(xFilial("GVT")+ M->GW3_CDESP))
		//Se na espécie está parametrizado para não informar
		If (GVT->(FieldPos("GVT_CHVCTE")) > 0 .And. GVT->GVT_CHVCTE == "3") .or. ( Posicione("GU3", 1, xFilial("GU3")+M->GW3_EMISDF, "GU3_CTE")) == "2"
			Return .F.
		EndIf
		If M->GW3_ORIGEM == "2"
			// Se não for icms, deixa desabilitado
			If (GVT->GVT_TPIMP != "1")
				Return .F.
			EndIf
		EndIf
	EndIf
Return .T.
//-----------------------------------------------------
/*/ Integração de Documentos de Frete como Documento de Entrada
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
*/
//------------------------------------------------------

Function GFEA065IPG(nInt, cSituacao, oModel, aRet)
	Local cMsg     := ""
	Local lIntGFE  := SuperGetMv("MV_INTGFE" ,.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE  := SuperGetMv("MV_ERPGFE" ,.F.,"2")

	Private _oGFEXFBFL := GFEXFBFLog():New()
	Private _lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"

		_oGFEXFBFL:setSaveLog(_lLogIntP)
		_oGFEXFBFL:setAgrFrt(GW3->GW3_NRDF)

		Do Case
		Case cSituacao == "2"
			If !AtuDocFret(nInt,oModel,@cMsg) //Atualização Doc. Frete Fiscal/Recebimento
				aRet := {.F.,"2",cMsg}
			Else
				aRet := {.T.,"2",""}
			EndIf

		Case cSituacao == "5"
			If !DesAtuDocFret(nInt,oModel,@cMsg) //Desatualização Doc. Frete Fiscal/Recebimento
				aRet := {.F.,"5",cMsg}
			Else
				aRet := {.T.,"5",""}
			EndIf

		Otherwise
			Return
		EndCase
		_oGFEXFBFL:SaveLog()
	EndIf
Return

//-----------------------------------------------------
/*/	Atualização do documento de frete no Protheus
	@author Felipe Machado de Oliveira
	@param nInt = "1"(Integração de Documentos de Frete como Documento de Entrada)
	= "2"(Integração de Documentos de Frete como Nota de Conhecimento)
	oModel
	cMsg
	@version P11
	@since 30/05/2013
*/
//------------------------------------------------------

Static Function AtuDocFret(nInt, oModel, cMsg, nOpc)
	Local aDocFrete   := {}
	Local aItensDoc   := {}
	Local aNotasFis   := {}
	Local lErro       := .F.
	Local aForLoj     := GFEA055GFL(GW3->GW3_EMISDF)
	Local aCliLoj     := GFEA055DEV(GW3->GW3_CDDEST,"C") // "C" -> Solicita o codigo do cadastro de clientes (SA1)
	Local cF1_DOC     := GW3->GW3_NRDF
	Local aErro       := {}
	Local nX          := 0
	Local nF          := 0
	Local nA		  := 0
	Local nZ		  := 0
	Local cCpdGFE     := ""
	Local cNtfGfe     := SuperGetMv("MV_NTFGFE",,"")
	Local cFilAtu     := ""
	Local aCustFis 	  := {}
	Local aCustRec    := {}
	Local cTpCte      := ""
	Local cOpcInteg   := ""
	Local aCidades    := {}
	Local aCidadesUF  := {}
	Local lCpoTES     := GFEA065INP()
	Local lInteg      := .F.
	Local cAliasQry   := Nil
	Local cCNPJCli    := AllTrim(Posicione("GU3",1,XFILIAL("GU3")+GW3->GW3_CDDEST,"GU3_IDFED"))
	Local cAliasGW1   := Nil
	Local cTpImp      := Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")
	Local aMsgTES     := {}
	Local cTpDf       := oModel:getValue("GFEA065_GW3","GW3_TPDF")
	Default cMsg      := ""

	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private lTemF1GFE      := .F.
	Private aHeader        := {}
	Private cOperPE        := ""
	Private ctpNfMat       := ""
	Private aParamValue	   := {}
	Private lISSxMun	   := SuperGetMV("MV_ISSXMUN",.F.,.F.)
	Private aCFOPItensDC   := {}

	ParInt65()

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	cOpcInteg := oModel:getValue("GFEA065_GW3","GW3_ACINT") //GW3->GW3_ACINT

	If !lErro
		If Empty(aForLoj[2])
			aForLoj[2] := "01"
		EndIf

		cF1_DOC := SubStr(cF1_DOC,1,TamSx3("F1_DOC")[1])

		/* Array com dados da Cidade e UF da Origem e Destino dos TRECHOS - Ato Cotepe 48
		   aCidadesUF[1][1] - Cidade Origem do Transporte
		   aCidadesUF[1][2] - UF Origem do Transporte
		   aCidadesUF[1][3] - Cidade Destino do Transporte
		   aCidadesUF[1][4] - UF Destino do Transporte   */
		If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   !(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))

			aAdd(aCidadesUF, { Substr(GW3->GW3_MUNINI, 3,7), GW3->GW3_UFINI, Substr(GW3->GW3_MUNFIM, 3,7), GW3->GW3_UFFIM })
		Else
			aCidades := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
			aAdd(aCidadesUF, { Substr(aCidades[1][1], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"), Substr(aCidades[1][2], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF") })
		EndIf

		If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2;4") .And. cTpDf != "3" //Recebimento/Pré-CT
			//Notas Fiscais do Conhecimento de Frete
			GetNotasFis(@aNotasFis,oModel,aForLoj,cF1_DOC)

			//Parametros para geração do Conhecimento no MATA116
			ParamMt116 ( 2,@aDocFrete,aForLoj,cF1_DOC,aCidadesUF, cOpcInteg, @aMsgTES )

			//Geração do Conhecimento no MATA116
			If !Empty(aNotasFis)

				/*Ponto de Entrada Nestle - TQASX7 */
				If  ExistBlock("GFEA0654")
					aCustRec := ExecBlock("GFEA0654",.F.,.F., {aDocFrete, aNotasFis, cOperPE})
					aDocFrete := aCustRec[1][1]
					aNotasFis := aCustRec[1][2]
				EndIf

				_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus

				AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
				AddToLog('Atualização' + CRLF)
				AddToLog("Rotina Da Integração: GFEA065" + CRLF)
				AddToLog("Documento de Frete - Atualizar Aprop Desp ERP" + CRLF + CRLF)
				AddToLog("-----------------------------------------------------" + CRLF)
				AddToLog("Parâmetros da Integração:" + CRLF)
				For nX := 1 To Len(aParamValue[1])
					AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
				Next nX
				AddToLog("-----------------------------------------------------" + CRLF)

				AddToLog('Documento de Frete' + CRLF)				
				nF := Len(aDocFrete)
				For nX := 1 To nF
					If Len(aDocFrete[nX]) == 3
						AddToLog(aDocFrete[nx,1] + " - "+ cValToChar(aDocFrete[nx,2]) + CRLF)
					Else
						AddToLog(aDocFrete[nx,1] + ": "+ aDocFrete[nx,4] + " - "+ cValToChar(aDocFrete[nx,2])  + CRLF)
					EndIf
				Next nX

				If !Empty(aMsgTES)
					AddToLog(CRLF + STR0129 + CRLF + CRLF) //"Busca da TES e Tipo de Operação:"
					nF := Len(aMsgTES)
					For nX := 1 To nF
						AddToLog(aMsgTES[nx] + CRLF)
					Next nX
					FwFreeArray(aMsgTES)
					aMsgTES := {}
				EndIf

				If !Empty(aNotasFis)
					AddToLog(CRLF + 'Itens' + CRLF)
					nF := Len(aNotasFis[1])
					For nX := 1 To nF
						AddToLog(aNotasFis[1,nX,1] + " - " + cValToChar(aNotasFis[1,nX,2]) + CRLF)
					next nX
				EndIf

				If cOpcInteg != "4"
					MSExecAuto( { |x,y| MATA116(x,y) }, aDocFrete, aNotasFis )
				Else
					MSExecAuto( { |x,y| MATA116(x,y,,.T.) }, aDocFrete, aNotasFis )
				EndIf
				lInteg := .T.
			Else
				lErro := .T.
				cMsg := "Notas Fiscais não selecionadas."
			EndIf
		Else
			//Cabeçalho do Documento de Entrada
			Aadd(aDocFrete, {"F1_DOC"     , cF1_DOC        , Nil } )
			Aadd(aDocFrete, {"F1_SERIE"   , GW3->GW3_SERDF , Nil } )
			Aadd(aDocFrete, {"F1_FORNECE" , aForLoj[1]     , Nil } )
			Aadd(aDocFrete, {"F1_LOJA"    , aForLoj[2]     , Nil } )
			Aadd(aDocFrete, {"F1_EMISSAO" , GW3->GW3_DTEMIS, Nil } )

			//Ponto de entrada da CROWN EMBALAGENS
			If  ExistBlock("GFEA0653")
				cCpdGFE :=  ExecBlock("GFEA0653",.F.,.F.,{3}) // Ponto de entrada para alterar a cond. de pagamento
			EndIf

			If Empty(cCpdGFE)
				If lCpoTES
					cCpdGFE := GW3->GW3_CPDGFE
				else
					cCpdGFE := SuperGetMv("MV_CPDGFE",,"1")
					If Empty(cCpdGFE)
						cCpdGFE := Space(TamSX3("GW3_CPDGFE")[1])
					EndIf
				EndIf
			EndIf
			//Fim do Ponto de entrada da CROWN EMBALAGENS

			Aadd(aDocFrete, {"F1_COND"    , cCpdGFE       , Nil})
			Aadd(aDocFrete, {"F1_RECBMTO" , GW3->GW3_DTFIS, Nil})
			Aadd(aDocFrete, {"F1_CHVNFE"  , GW3->GW3_CTE  , Nil})
			If cTpDf == "3"
				Aadd(aDocFrete, {"F1_TIPO" , "I"          , Nil})
			Else
				If cOpcInteg == "4" // Pré Ct-e
					Aadd(aDocFrete, {"F1_TIPO" , "C"          , Nil})
				Else // Fiscal ou Pré Nota
					Aadd(aDocFrete, {"F1_TIPO" , "N"          , Nil})
				EndIf
			EndIf
			Aadd(aDocFrete, {"F1_FORMUL"  , "N"           , Nil})
			Aadd(aDocFrete, {"F1_ESPECIE" , GW3->GW3_CDESP, Nil})
			Aadd(aDocFrete, {"F1_ORIGEM"  , "GFEA065"     , Nil})
			Aadd(aDocFrete, {"F1_VALPEDG" , GW3->GW3_PEDAG, Nil})

			If !(cOpcInteg $ "3") .And. !Empty(GW3->GW3_CTE)
				If GW3->GW3_TPCTE == "0"
					cTpCte = "N"
				ElseIF GW3->GW3_TPCTE == "1"
					cTpCte = "C"
				ElseIF GW3->GW3_TPCTE == "2"
					cTpCte = "A"
				ElseIF GW3->GW3_TPCTE == "3"
					cTpCte = "S"
				EndIf
				aAdd(aDocFrete,{"F1_TPCTE" ,cTpCte         ,Nil}) //Tipo CTE
			EndIf
			AAdd(aDocFrete, {"F1_TPFRETE" , "C"            ,Nil}) //Tipo Frete integração realizada pelo MATA103/MATA140, enviar a informação como CIF

			// Validação abaixo apenas quando o Doc. Carga relacionado seja do Tipo Saída pois pode existir o cadastro de um fornecer como cliente.
			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW4.R_E_C_N_O_ RECNOGW3
				FROM %Table:GW4% GW4
				INNER JOIN %Table:GW1% GW1
					ON GW1_FILIAL = GW4_FILIAL
					AND GW1_EMISDC = GW4_EMISDC
					AND GW1_SERDC = GW4_SERDC
					AND GW1_NRDC = GW4_NRDC
					AND GW1_CDTPDC = GW4_TPDC
					AND GW1.%NotDel%
				INNER JOIN %Table:GV5% GV5
					ON GV5_FILIAL = %xFilial:GV5%
					AND GV5_CDTPDC = GW1_CDTPDC
					AND GV5_SENTID IN ('2')
					AND GV5.%NotDel%
				WHERE GW4.GW4_FILIAL = %Exp:GW3->GW3_FILIAL%
				AND GW4_EMISDF = %Exp:GW3->GW3_EMISDF%
				AND GW4_CDESP = %Exp:GW3->GW3_CDESP%
				AND GW4_SERDF = %Exp:GW3->GW3_SERDF%
				AND GW4_NRDF = %Exp:GW3->GW3_NRDF%
				AND GW4_DTEMIS = %Exp:GW3->GW3_DTEMIS%
				AND GW4.%NotDel%
			EndSql
			If (cAliasGW1)->(!Eof()) .And. Len(aCliLoj) > 0
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
							SELECT SA1.R_E_C_N_O_ RECNOSA1
							FROM %Table:SA1% SA1
							WHERE SA1.A1_FILIAL = %xFilial:SA1%
							AND SA1.A1_COD = %Exp:aCliLoj[1][1]%
							AND SA1.A1_LOJA = %Exp:aCliLoj[1][2]%
							AND SA1.A1_CGC = %Exp:cCNPJCli%
							AND SA1.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					If GW3->GW3_TPDF <> "5"
						AAdd(aDocFrete, {"F1_CLIDEST" , PADR(aCliLoj[1][1], TamSX3("F1_CLIDEST") [1]), Nil } )
						AAdd(aDocFrete, {"F1_LOJDEST" , PADR(aCliLoj[1][2], TamSX3("F1_LOJDEST") [1]), Nil } )
					EndIf
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
			(cAliasGW1)->(dbCloseArea())

			/* Origem x Destino do transporte - Ato Cotepe 48 */
			Aadd(aDocFrete, {"F1_EST"     , aCidadesUF[1][2]    , Nil } )
			Aadd(aDocFrete, {"F1_ESTDES"  , aCidadesUF[1][4]    , Nil } )
			Aadd(aDocFrete, {"F1_MUORITR" , aCidadesUF[1][1]    , Nil } )
			Aadd(aDocFrete, {"F1_UFORITR" , aCidadesUF[1][2]    , Nil } )
			Aadd(aDocFrete, {"F1_MUDESTR" , aCidadesUF[1][3]    , Nil } )
			Aadd(aDocFrete, {"F1_UFDESTR" , aCidadesUF[1][4]    , Nil } )
			Aadd(aDocFrete, {"E2_NATUREZ" , cNtfGfe    			, Nil } )

			If lISSxMun .And. cTpImp == "2" //"2=ISS"
				Aadd(aDocFrete, {"F1_INCISS" , aCidadesUF[1][1] , Nil } )
			EndIf
			//Itens do Documento de Entrada
			GetItensDoc(@aItensDoc,aForLoj,cF1_DOC,3, cOpcInteg, aMsgTES, cTpDf)

			//Utilizado para que não seja atribuida a filial do usuário logado
			// dentro do módulo de compras
			cFilAtu := cFilAnt
			cFilAnt := GW3->GW3_FILIAL
			If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
				cFilAnt := GW3->GW3_FILTOM
			Endif

					/*Ponto de Entrada Nestle - TQASX7 */
			If  ExistBlock("GFEA0655")
				aCustFis 	:= ExecBlock("GFEA0655",.F.,.F.,{aDocFrete, aItensDoc, cOperPE})
				aDocFrete 	:= aCustFis[1][1]
				aItensDoc 	:= aCustFis[1][2]
			EndIf

			If cOpcInteg $ "3"
				_oGFEXFBFL:NovoLogInP("MATA140") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA140 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA140 - Iniciado em "###", as "
			Else
				_oGFEXFBFL:NovoLogInP("MATA103") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA103 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA103 - Iniciado em "###", as "
			EndIf

			AddToLog('Atualização' + CRLF)
			AddToLog("Rotina Da Integração: GFEA065" + CRLF)
			AddToLog("Documento de Frete - Atualizar Fiscal ERP" + CRLF + CRLF)
			AddToLog("-----------------------------------------------------" + CRLF)
			AddToLog("Parâmetros da Integração:" + CRLF)
			nF := Len(aParamValue[1])
			For nX := 1 To nF
				AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
			Next nX
			AddToLog("-----------------------------------------------------" + CRLF)

			AddToLog('Documento de Frete' + CRLF)
			nF := Len(aDocFrete)
			For nX := 1 To nF
				AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)
			Next nX
			
			AddToLog("-----------------------------------------------------" + CRLF)
			
			If !Empty(aItensDoc)
				AddToLog(CRLF + 'Itens' + CRLF)
				nZ := Len(aItensDoc) 
				For nA := 1 To nZ 
					nF := Len(aItensDoc[nA]) 	
					nX := 1
					While nX <= nF
						AddToLog(aItensDoc[nA][nX][1] + " - " + cValToChar(aItensDoc[nA][nX][2]) + CRLF)
					nX++
					EndDo
					AddToLog("-----------------------------" + CRLF)
				Next nA
			EndIf

			If !Empty(aMsgTES)
				AddToLog(CRLF + STR0129 + CRLF + CRLF) //"Busca da TES e Tipo de Operação:"
				nF := Len(aMsgTES)
				For nX := 1 To nF
					AddToLog(aMsgTES[nx] + CRLF)
				Next nX
				FwFreeArray(aMsgTES)
				aMsgTES := {}
			EndIf

			If cOpcInteg $ "3"
				//Se for Pré Nota executar o MATA140
				MSExecAuto( { |x,y,z| MATA140(x,y,z) }, aDocFrete,aItensDoc,3 )
			Else
				//Inclusão do Documento de Entrada no MATA103
				MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aDocFrete,aItensDoc,3 )
			EndIf
			lInteg := .T.
			cFilAnt := cFilAtu
		EndIf
		If lInteg
			If lMsErroAuto
				If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2;4")
					aErro := GetAutoGrLog()
					cMsg  := ""
					nF := Len(aErro)
					For nX := 1 To nF
						cMsg += aErro[nX] + CRLF
					Next nX

					lErro := .T.
					AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
					AddToLog(cMsg + CRLF)
				Else
					If !lTemF1GFE
						aErro := GetAutoGrLog()
						cMsg  := ""
						nF := Len(aErro)
						For nX := 1 To nF
							cMsg += aErro[nX] + CRLF
						Next nX

						lErro := .T.
						AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
						AddToLog(cMsg + CRLF)
					EndIf
				EndIf
			Else
				AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
			EndIf

			AddToLog("LOG DE INTEGRAÇÃO - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO - Finalizado em "###", as "
		EndIf
	EndIf

	If nInt == "1"
		cTipInt := "Fiscal"
	Else
		cTipInt := "Recebimento"
	EndIf

	If IsInCallStack("GFEA065")
		If lErro
			aMsgInfo := {"Documento de Frete não enviada para atualização. Verificar motivo no campo 'Mot Rej "+SubStr(cTipInt,1,3)+"'."}
		Else
			aMsgInfo := {"Documento de Frete atualizado no "+cTipInt+"."}
		EndIf
	EndIf
Return !lErro

//-----------------------------------------------------
/*/	Desatualização do documento de frete no Protheus
@author Felipe Machado de Oliveira
@param nInt = "1"(Integração de Documentos de Frete como Documento de Entrada)
= "2"(Integração de Documentos de Frete como Nota de Conhecimento)
oModel
cMsg
@version P11
@since 30/05/2013
*/
//------------------------------------------------------

Static Function DesAtuDocFret(nInt, oModel, cMsg)
	Local aDocFrete	 := {}
	Local aItensDoc  := {}
	Local aNotasFis  := {}
	Local lErro      := .F.
	Local lErroDc    := .F.
	Local aForLoj    := GFEA055GFL(GW3->GW3_EMISDF)
	Local cF1_DOC    := SubStr(GW3->GW3_NRDF,1,TamSx3("F1_DOC")[1])
	Local cTipInt    := ""
	Local aErro      := {}
	Local nX         := 0
	Local nF         := 0
	Local nA         := 0
	Local nZ         := 0
	Local cCpdGFE    := ""
	Local cOpcInteg  := ""
	Local lCpoTES    := GFEA065INP()
	Local aAreaSF1   := {}
	Local cTipo      := ""
	Local aCidadesUF := {}
	Local lInteg     := .F.
	Local cFilAtu 	 := ""
	Local aMsgTES    := {}

	Default cMsg     := ""

	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private aHeader        := {}
	Private ctpNfMat       := ""
	Private lTemF1GFE      := .F.

	Private aParamValue	   := {}

	ParInt65()

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If !lErro
		If Empty(aForLoj[2])
			aForLoj[2] := "01"
		EndIf

		//Utilizado para que não seja atribuida a filial do usuário logado
		// dentro do módulo de compras
		cFilAtu := cFilAnt
		cFilAnt := GW3->GW3_FILIAL
		If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
			cFilAnt := GW3->GW3_FILTOM
		Endif

		aAreaSF1 := SF1->(GetArea())
		SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If SF1->(dbSeek(xFilial("SF1") + cF1_DOC + PadR(GW3->GW3_SERDF, TamSX3("F1_SERIE")[1]) + aForLoj[1] + aForLoj[2]))
			If GW3->(FieldPos("GW3_ACINT")) > 0 .And. !Empty(GW3->GW3_ACINT)
				cOpcInteg := GW3->GW3_ACINT
				If cOpcInteg $ '3'
					If !Empty(SF1->F1_STATUS)
						cOpcInteg := '1' //Documento já classificado, enviar pelo MATA103
						cTipo := SF1->F1_TIPO
					EndIf
				EndIf
			EndIf
		Else
			//Documento não localizado para exclusão
			lErro   := .T.
			lErroDc := .T.
			cMsg    := "O documento de Frete não foi localizado no ERP para desatualização."
		EndIf
		RestArea(aAreaSF1)
		aSize(aAreaSF1,0)
		cFilAnt := cFilAtu
	EndIf

	If !lErro
		If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
				!(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))

			aAdd(aCidadesUF, { Substr(GW3->GW3_MUNINI, 3,7), GW3->GW3_UFINI, Substr(GW3->GW3_MUNFIM, 3,7), GW3->GW3_UFFIM })
		Else
			/* Array com dados da Cidade e UF da Origem e Destino dos TRECHOS - Ato Cotepe 48
				aCidadesUF[1][1] - Cidade Origem do Transporte
				aCidadesUF[1][2] - UF Origem do Transporte
				aCidadesUF[1][3] - Cidade Destino do Transporte
				aCidadesUF[1][4] - UF Destino do Transporte   */
			aCidades   := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
			aAdd(aCidadesUF,{Substr(aCidades[1][1], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"), Substr(aCidades[1][2], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF") })
		EndIf

		If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2;4") //Recebimento/Pré-ct
			//Notas Fiscais do Conhecimento de Frete
			GetNotasFis(@aNotasFis,oModel,aForLoj,cF1_DOC)

			//Parametros para exclusão do Conhecimento no MATA116
			ParamMt116 ( 1,@aDocFrete,aForLoj,cF1_DOC,aCidadesUF,, @aMsgTES )

			//Exclusão do Conhecimento no MATA116
			If !Empty(aNotasFis)

				_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus

				AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
				AddToLog('Desatualização' + CRLF)
				AddToLog("Rotina Da Integração: GFEA065" + CRLF)
				AddToLog("Documento de Frete - Desatualizar Aprop Despesa ERP" + CRLF + CRLF)
				AddToLog("-----------------------------------------------------" + CRLF)
				AddToLog("Parâmetros da Integração:" + CRLF)
				
				For nX := 1 To Len(aParamValue[1])
					AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
				Next nX

				AddToLog("-----------------------------------------------------" + CRLF)

				AddToLog('Documento de Frete' + CRLF)
				nF := Len(aDocFrete)
				For nX := 1 To nF
					If Len(aDocFrete[nX]) == 3
						AddToLog(aDocFrete[nx,1] + " - "+ cValToChar(aDocFrete[nx,2]) + CRLF)
					Else
						AddToLog(aDocFrete[nx,1] + ": "+ aDocFrete[nx,4] + " - "+ cValToChar(aDocFrete[nx,2])  + CRLF)
					EndIf
				Next nX

				If !Empty(aMsgTES)
					AddToLog(CRLF + STR0129 + CRLF + CRLF) //"Busca da TES e Tipo de Operação:"
					nF := Len(aMsgTES)
					For nX := 1 To nF
						AddToLog(aMsgTES[nx] + CRLF)
					Next nX
					FwFreeArray(aMsgTES)
					aMsgTES := {}
				EndIf
				AddToLog("-----------------------------------------------------" + CRLF)
				If !Empty(aNotasFis)
					AddToLog(CRLF + 'Itens' + CRLF)					
					nF := Len(aNotasFis[1])
					For nX := 1 To nF
						AddToLog(aNotasFis[1,nX,1] + " - " + cValToChar(aNotasFis[1,nX,2]) + CRLF)
					next nX
				EndIf

				If cOpcInteg != "4"
					MSExecAuto( { |x,y| MATA116(x,y) }, aDocFrete,aNotasFis )
				Else
					MSExecAuto( { |x,y| MATA116(x,y,,.T.) }, aDocFrete,aNotasFis )
				EndIf

				lInteg := .T.
			Else
				lErro := .T.
				cMsg := "Notas Fiscais não selecionadas."
			EndIf
		Else //Fiscal
			//Cabeçalho do Documento de Entrada
			Aadd(aDocFrete, {"F1_DOC"     , cF1_DOC                  , Nil } )
			Aadd(aDocFrete, {"F1_SERIE"  , PadR(GW3->GW3_SERDF, TamSX3("F1_SERIE")[1]), Nil } )
			Aadd(aDocFrete, {"F1_FORNECE" , aForLoj[1]               , Nil } )
			Aadd(aDocFrete, {"F1_LOJA"    , aForLoj[2]               , Nil } )
			Aadd(aDocFrete, {"F1_EMISSAO" , GW3->GW3_DTEMIS          , Nil } )

			//Ponto de entrada CROWN EMBALAGENS
			If  ExistBlock("GFEA0653")
				cCpdGFE :=  ExecBlock("GFEA0653",.F.,.F.,{5}) // Ponto de entrada para alterar a cond. de pagamento
			EndIf

			If Empty(cCpdGFE)
				If lCpoTES
					cCpdGFE := GW3->GW3_CPDGFE
				else
					cCpdGFE := SuperGetMv("MV_CPDGFE",,"1")
					If Empty(cCpdGFE)
						cCpdGFE := Space(TamSX3("GW3_CPDGFE")[1])
					EndIf
				EndIf
			EndIf
			//Fim do Ponto de entrada da CROWN EMBALAGENS

			Aadd(aDocFrete, {"F1_COND"    , cCpdGFE                  , Nil } )
			Aadd(aDocFrete, {"F1_EST"     , Posicione("GU7",1,XFILIAL("GU7")+Posicione("GU3",1,xFilial("GU3")+GW3->GW3_CDREM,"GU3_NRCID") ,"GU7_CDUF") } )
			Aadd(aDocFrete, {"F1_RECBMTO" , GW3->GW3_DTFIS           , Nil } )
			Aadd(aDocFrete, {"F1_CHVNFE"  , GW3->GW3_CTE             , Nil } )
			If !Empty(cTipo)
				Aadd(aDocFrete, {"F1_TIPO"    , cTipo                , Nil } )
			Else
				Aadd(aDocFrete, {"F1_TIPO"    , "N"                  , Nil } )
			EndIf
			Aadd(aDocFrete, {"F1_FORMUL"  , "N"                      , Nil } )
			Aadd(aDocFrete, {"F1_ESPECIE" , GW3->GW3_CDESP           , Nil } )
			Aadd(aDocFrete, {"F1_ORIGEM"  , "GFEA065"                , Nil } )
			AAdd(aDocFrete, {"F1_TPFRETE" , "C"                      , Nil } ) //Tipo Frete integração realizada pelo MATA103/MATA140, enviar a informação como CIF

			//Itens do Documento de Entrada
			GetItensDoc(@aItensDoc,aForLoj,cF1_DOC,5, cOpcInteg, aMsgTES)

			//Utilizado para que não seja atribuida a filial do usuário logado
			// dentro do módulo de compras
			cFilAtu := cFilAnt
			cFilAnt := GW3->GW3_FILIAL
			If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
				cFilAnt := GW3->GW3_FILTOM
			Endif

			If cOpcInteg $ "3"	// Pré Nota
				_oGFEXFBFL:NovoLogInP("MATA140") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA140 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA140 - Iniciado em "###", as "
			Else
				_oGFEXFBFL:NovoLogInP("MATA103") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA103 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA103 - Iniciado em "###", as "
			EndIf

			AddToLog('Desatualização' + CRLF)
			AddToLog("Rotina Da Integração: GFEA065" + CRLF)
			AddToLog("Documento de Frete - Desatualizar Fiscal ERP" + CRLF + CRLF)
			AddToLog("-----------------------------------------------------" + CRLF)
			AddToLog("Parâmetros da Integração:" + CRLF)
			For nX := 1 To Len(aParamValue[1])
				AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
			Next nX
			AddToLog("-----------------------------------------------------" + CRLF)

			nF := Len(aDocFrete)
			For nX := 1 To nF
				AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)
			Next nX

			If !Empty(aMsgTES)
				AddToLog(CRLF + STR0129 + CRLF+ CRLF) //"Busca da TES e Tipo de Operação:"
				nF := Len(aMsgTES)
				For nX := 1 To nF
					AddToLog(aMsgTES[nx] + CRLF)
				Next nX
				FwFreeArray(aMsgTES)
				aMsgTES := {}
			EndIf
			AddToLog("-----------------------------------------------------" + CRLF)
			If !Empty(aItensDoc)
				AddToLog(CRLF + 'Itens' + CRLF)
				nZ := Len(aItensDoc)
				For nA := 1 To nZ 
					nF := Len(aItensDoc[nA]) 	
					nX := 1
					While nX <= nF
						AddToLog(aItensDoc[nA][nX][1] + " - " + cValToChar(aItensDoc[nA][nX][2]) + CRLF)
					nX++
					EndDo
					AddToLog("-----------------------------" + CRLF)
				Next nA
			EndIf

			If cOpcInteg $ "3"	// Pré Nota
				//Exclusão do Documento de Entrada no MATA140
				MSExecAuto( { |x,y,z| MATA140(x,y,z) }, aDocFrete,aItensDoc,5 )
			Else // Documento Fiscal
				//Exclusão do Documento de Entrada no MATA103
				MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aDocFrete,aItensDoc,5 )
			EndIf
			lInteg := .T.
			cFilAnt := cFilAtu
		EndIf

		If lInteg
			If lMsErroAuto
				If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2;4")
					aErro := GetAutoGrLog()
					cMsg  := ""

					nf := Len(aErro)
					For nX := 1 To nF
						cMsg += aErro[nX] + CRLF
					Next nX

					lErro := .T.

					AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
					AddToLog(cMsg + CRLF)
				Else
					If lTemF1GFE
						aErro := GetAutoGrLog()
						cMsg  := ""

						nf := Len(aErro)
						For nX := 1 To nF
							cMsg += aErro[nX] + CRLF
						Next nX

						lErro := .T.

						AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
						AddToLog(cMsg + CRLF)
					EndIf
				EndIf
			Else
				If lTemF1GFE
					cMsg := "Integração não realizada." + CRLF
					cMsg += " Verifique o uso da Nota Fiscal pós módulo de compras."

					lErro := .T.
					AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
					AddToLog(cMsg + CRLF)
				Else
					AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
				EndIf
			EndIf

			AddToLog("LOG DE INTEGRAÇÃO - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO - Finalizado em "###", as "
		EndIf
	EndIf

	If nInt == "1"
		cTipInt := "Fiscal"
	Else
		cTipInt := "Recebimento"
	EndIf

	If IsInCallStack("GFEA065")
		If lErro
			If lErroDc
				MsgInfo(cMsg)
			Else
				MsgInfo("Documento de Frete não enviado para desatualização. Verificar motivo no campo 'Mot Rej "+SubStr(cTipInt,1,3)+"'.")
			EndIf
		Else
			MsgInfo("Documento de Frete desatualizado no "+cTipInt+".")
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Retorna os Itens do Documento de Entrada
@author Felipe Machado de Oliveira
@version P11
@since 07/06/2013
/*/
//------------------------------------------------------

Function GetItensDoc(aItensDoc,aForLoj,cF1_DOC,nOp,cOpcInt,aMsgTES,cTpDf)
	Local cTes     	:= ""
	Local cTesSis  	:= ""
	Local cCenCus  	:= GW3->GW3_CC
	Local cRetPE   	:= ""
	Local cTpImp   	:= Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")
	Local cPrdFrete	:= ""
	Local cD1_Quant	:= 1
	Local lCpoTES  	:= GFEA065INP()
	Local lEscPed  	:= .F.
	Local nVlDoc   	:= GW3->GW3_VLDF
	Local s_ESCPED	:= SuperGetMV("MV_ESCPED", .F., "2")
	Local cFGER 	:= ""
	Local cTESGFE	:= SuperGetMv("MV_TESGFE", .F., "1")
	Local nCFOPDC	:= 0
	Local nI		:= 0
	Local cSeqItem	:= ""

	Local aItemDoc 		:= {}
	Local aCFOPDC		:= {}
	Local aSmTot		:= {}
	
	Local cSelect 	:= " "
	Local cGroupBy  := " "
	Local lGFEA0651 := ExistBlock("GFEA0651")
	Local lGFEA0652 := ExistBlock("GFEA0652")
	Local lGFEA0658 := ExistBlock("GFEA0658")
	Local cMVPRITDF := SuperGetMv("MV_PRITDF",.F.,"")

	Default cOpcInt	:= "0"
	Default aMsgTES	:= {}
	Default cTpDf	:= "1"
	
	aCFOPItensDC    := {}

	If cOpcInt == "4" .Or. cTpDf == "3" 
		cD1_Quant := 0
	EndIf

	/*** Escrituração Pedágio: o parametro deve estar Ativo, o imposto ser ICMS, com o Pedágio incluso
	     no valor total do documento e não estar incluso na base de ICMS e o Valor do Pedágio destacado ***/
	If s_ESCPED == "1"   .And. cTpImp == "1"  .And. GW3->GW3_PDGFRT == "1" .And. GW3->GW3_ICMPDG == "2" .And. GW3->GW3_PEDAG > 0
		lEscPed := .T.
		nVlDoc  := GW3->GW3_VLDF - GW3->GW3_PEDAG  /* descontar o valor do Pedágio do total do Documento quando este for escriturado separadamente */
	EndIf

	// Opção de separação por CFOP
	If cTESGFE == "3"
		cSelect 	  := "GW8.GW8_CFOP CFOP, "
		cGroupBy	  := "GW8.GW8_CFOP"

		If GFXCP1212410("GVS_TES") .And. !Empty("GW8_INFO3")
				cSelect 	  += "GW8.GW8_INFO3 TES, "
				cGroupBy 	  += ", GW8.GW8_INFO3"
		EndIf
		
		cSelect := "%" + cSelect + "%"
		cGroupBy := "%" + cGroupBy + "%"

		cAliasGW8 := GetNextAlias()

		BeginSQL Alias cAliasGW8
			SELECT DISTINCT GW8.GW8_SEQ,
							%Exp:cSelect%
	   						SUM(GWM.GWM_PCRAT) PCRAT,
							GW8.GW8_NRDC NRDC,
							GW8.GW8_ITEM ITEM
			FROM %Table:GWM% GWM
			INNER JOIN %Table:GW8% GW8
			ON GW8.GW8_FILIAL = GWM.GWM_FILIAL
			AND GW8.GW8_CDTPDC = GWM.GWM_CDTPDC
			AND GW8.GW8_EMISDC = GWM.GWM_EMISDC
			AND GW8.GW8_SERDC = GWM.GWM_SERDC
			AND GW8.GW8_NRDC = GWM.GWM_NRDC
			AND GW8.GW8_SEQ = GWM.GWM_SEQGW8
			AND GW8.D_E_L_E_T_ = ''
			WHERE GWM.GWM_FILIAL = %Exp:GW3->GW3_FILIAL%
			AND GWM.GWM_TPDOC = '2'
			AND GWM.GWM_CDESP = %Exp:GW3->GW3_CDESP%
			AND GWM.GWM_CDTRP = %Exp:GW3->GW3_EMISDF%			
			AND GWM.GWM_SERDOC = %Exp:GW3->GW3_SERDF%
			AND GWM.GWM_NRDOC = %Exp:GW3->GW3_NRDF%
			AND GWM.GWM_DTEMIS = %Exp:GW3->GW3_DTEMIS%			
			AND GWM.D_E_L_E_T_ = ''
			GROUP BY GW8.GW8_SEQ, %Exp:cGroupBy% , GW8.GW8_NRDC, GW8.GW8_ITEM
		EndSQL

		Do While !((cAliasGW8)->(EoF()))
			If GFXCP1212410("GVS_TES")
				nI := aScan(aCFOPDC, {|x| Alltrim(x[1]) == Alltrim((cAliasGW8)->CFOP) })
				If nI > 0
					aCFOPDC[nI][2] += (cAliasGW8)->PCRAT / 100
				Else
					Aadd(aCFOPDC, {(cAliasGW8)->CFOP, ((cAliasGW8)->PCRAT / 100), (cAliasGW8)->TES})
				EndIf
			Else
				Aadd(aCFOPDC, {(cAliasGW8)->CFOP, ((cAliasGW8)->PCRAT / 100)})
			EndIf

			Aadd(aCFOPItensDC, {(cAliasGW8)->NRDC,(cAliasGW8)->ITEM,(cAliasGW8)->CFOP })

			(cAliasGW8)->(dbSkip())
		EndDo

		(cAliasGW8)->(dbCloseArea())
	Else
		Aadd(aCFOPDC, {GW3->GW3_CFOP, 1,""})
	EndIf

	nCFOPDC := Len(aCFOPDC)
	aSmTot := {0,0,0,0}

	For nI := 1 To nCFOPDC
		aItemDoc := {}

		cSeqItem := PADL(cValToChar(nI), TamSX3("D1_ITEM")[1],"0")

		//Itens do Documento de Entrada
		Aadd(aItemDoc, {"D1_ITEM"   , cSeqItem			, Nil} )
		Aadd(aItemDoc, {"D1_DOC"    , cF1_DOC           , Nil} )
		Aadd(aItemDoc, {"D1_SERIE"  , GW3->GW3_SERDF    , Nil} )
		Aadd(aItemDoc, {"D1_FORNECE", aForLoj[1]        , Nil} )
		Aadd(aItemDoc, {"D1_LOJA"   , aForLoj[2]        , Nil} )
		Aadd(aItemDoc, {"D1_EMISSAO", GW3->GW3_DTEMIS   , Nil} )

		//Ponto de entrada CROWN EMBALAGENS
		If lGFEA0651
			cPrdFrete := ExecBlock("GFEA0651",.F.,.F.,{nOp})// Ponto de entrada para mudar o produto frete
		EndIf

		If Empty(cPrdFrete)
			If lCpoTES .And. !Empty(GW3->GW3_PRITDF)
				cPrdFrete := GW3->GW3_PRITDF
			Else
				cPrdFrete := cMVPRITDF
			EndIf
		EndIf

		//Fim do Ponto de entrada da CROWN EMBALAGENS
		Aadd(aItemDoc, {"D1_COD"    , cPrdFrete     			, Nil} )
		Aadd(aItemDoc, {"D1_UM"     , "UN"          			, Nil} )
		If cTpDf != "3" 
			Aadd(aItemDoc, {"D1_QUANT"  , cD1_Quant     			, Nil} ) // se opcint = 4 entao envia 0 senao mantem 1
		
			If nI == nCFOPDC .And. aSmTot[1] > 0
				Aadd(aItemDoc, {"D1_VUNIT"  , nVlDoc - aSmTot[1], Nil} )
				Aadd(aItemDoc, {"D1_TOTAL"  , nVlDoc - aSmTot[1], Nil} )
			Else
				Aadd(aItemDoc, {"D1_VUNIT"  , Round(nVlDoc * aCFOPDC[nI][2], 2)  , Nil} )
				Aadd(aItemDoc, {"D1_TOTAL"  , Round(nVlDoc * aCFOPDC[nI][2], 2) , Nil} )
				aSmTot[1] += Round(nVlDoc * aCFOPDC[nI][2], 2)
			EndIf
		EndIf

		//Ponto de entrada POLENGHI
		If lGFEA0658
			cRetPE := ExecBlock( "GFEA0658",.F.,.F.,{cCenCus} ) // Ponto de entrada para alterar a TES a utilizar no CTe
			If ValType(cRetPE) == "C"
				cCenCus := cRetPE
			EndIf
		EndIf
		//Fim do Ponto de entrada da POLENGHI

		//-- Inicio log Frete
		aAdd(aMsgTES,STR0107) //--  "Inicializando tipo de operação"
		aAdd(aMsgTES,"Critério de Rateio - "+ STR0066 ) // "Frete valor"

		If lCpoTES
			// Verifica se os novos campos estão preenchidos, e
			// caso não estejam, preenche com os valores padrão
			// antes de adicionar no array
			If GFE065VCPO("1",.T.,,.F.)
				cTes := GW3->GW3_TES
				If !Empty(cTes)
					aAdd(aMsgTES, STR0121 + " - " + cTes) //-- "TES atribuida GW3"
				EndIf

				Aadd(aItemDoc, {"D1_CONTA"  , GW3->GW3_CONTA  , Nil})
				Aadd(aItemDoc, {"D1_ITEMCTA", GW3->GW3_ITEMCT, Nil})
				Aadd(aItemDoc, {"D1_CC"     , cCenCus         , Nil})
			EndIf
		EndIf

		If cTESGFE == "1" .Or. cTESGFE == "3" // Atribuído sistema
			If GFXCP12123("GW3_USO")
				cFGer := GFEA065FGER(GW3->GW3_NATFRE, GW3->GW3_USO)
			EndIf

			If GFXCP1212410("GVS_TES")
				cTes := GFE065TES(cTes, cTpImp, GW3->GW3_TRBIMP, GW3->GW3_CRDICM, GW3->GW3_CRDPC, aForLoj, cFGer, GW3->GW3_TPCTB, cPrdFrete, aCFOPDC[nI][1], aMsgTES, aCFOPDC[nI][3])
			Else
				cTes := GFE065TES(cTes, cTpImp, GW3->GW3_TRBIMP, GW3->GW3_CRDICM, GW3->GW3_CRDPC, aForLoj, cFGer, GW3->GW3_TPCTB, cPrdFrete, aCFOPDC[nI][1], aMsgTES)
			EndIf
		EndIf

		//Ponto de entrada CROWN EMBALAGENS
		If lGFEA0652
			cTesSis := cTes
			cTes := ExecBlock( "GFEA0652",.F.,.F.,{nOp} ) // Ponto de entrada para alterar a TES a utilizar no CTe
			aAdd( aMsgTES,STR0122 + " " + cTes) //-- "TES atribuida Ponto de Entrada"
			If Empty(cTes)
				cTes := cTesSis
				aAdd( aMsgTES,STR0123 + " " + cTes) //-- "TES do sistema retomada - Ponto de entrada retornou vazio"
			EndIf
		EndIf
		//Fim do Ponto de entrada da CROWN EMBALAGENS

		If cOpcInt $ "3"
			Aadd( aItemDoc,{ "D1_TESACLA", cTes, Nil })
		Else
			Aadd( aItemDoc,{ "D1_TES", cTes, Nil })
		EndIf

		If nI == nCFOPDC .And. aSmTot[2] > 0
			If cTpImp == "1" /*"1=ICMS"*/ .AND. GW3->GW3_CRDICM == "1"
				If cTpDf != "3" 
					Aadd(aItemDoc, {"D1_VALICM"  , GW3->GW3_VLIMP - aSmTot[2]  , Nil } )
				EndIf
				Aadd(aItemDoc, {"D1_PICM"    , GW3->GW3_PCIMP, Nil } )
				Aadd(aItemDoc, {"D1_BASEICM" , Round(GW3->GW3_BASIMP - aSmTot[3], 2)  , Nil } )
				Aadd(aItemDoc, {"D1_ICMSRET" , GW3->GW3_IMPRET - aSmTot[4] , Nil } )
			EndIf

			If cTpImp == "2" //"2=ISS"
				Aadd(aItemDoc, {"D1_VALISS"  , GW3->GW3_VLIMP - aSmTot[2]  , Nil } )
				Aadd(aItemDoc, {"D1_ALIQISS" , GW3->GW3_PCIMP, Nil } )
				Aadd(aItemDoc, {"D1_BASEISS" , Round(GW3->GW3_BASIMP - aSmTot[3], 2) , Nil } )
			EndIf
		Else
			If cTpImp == "1" /*"1=ICMS"*/ .AND. GW3->GW3_CRDICM == "1"
				If cTpDf != "3" 
					Aadd(aItemDoc, {"D1_VALICM"  , Round(GW3->GW3_VLIMP * aCFOPDC[nI][2], 2)  , Nil } )
				EndIf
				Aadd(aItemDoc, {"D1_PICM"    , GW3->GW3_PCIMP, Nil } )
				Aadd(aItemDoc, {"D1_BASEICM" , Round(GW3->GW3_BASIMP * aCFOPDC[nI][2], 2) , Nil } )
				Aadd(aItemDoc, {"D1_ICMSRET" , GW3->GW3_IMPRET * aCFOPDC[nI][2] , Nil } )

				aSmTot[2] := aSmTot[2] + Round(GW3->GW3_VLIMP * aCFOPDC[nI][2], 2)
				aSmTot[3] := aSmTot[3] + Round(GW3->GW3_BASIMP * aCFOPDC[nI][2], 2)
				aSmTot[4] := aSmTot[4] + (GW3->GW3_IMPRET * aCFOPDC[nI][2])
			EndIf

			If cTpImp == "2" //"2=ISS"
				Aadd(aItemDoc, {"D1_VALISS"  , GW3->GW3_VLIMP * aCFOPDC[nI][2]  , Nil } )
				Aadd(aItemDoc, {"D1_ALIQISS" , GW3->GW3_PCIMP, Nil } )
				Aadd(aItemDoc, {"D1_BASEISS" , Round(GW3->GW3_BASIMP * aCFOPDC[nI][2], 2) , Nil } )

				aSmTot[2] := aSmTot[2] + (GW3->GW3_VLIMP * aCFOPDC[nI][2])
				aSmTot[3] := aSmTot[3] + Round(GW3->GW3_BASIMP * aCFOPDC[nI][2], 2)
			EndIf
		EndIf

		If cTpDf == "3"
			Aadd(aItemDoc, {"D1_NFORI"     , GW3->GW3_ORINR         , Nil} )
			Aadd(aItemDoc, {"D1_SERIORI"   , GW3->GW3_ORISER        , Nil} )
			Aadd(aItemDoc, {"D1_ITEMORI"   , "0001"     			, Nil} )
		EndIf

		Aadd(aItensDoc, aItemDoc)
	Next nI

	/*** Pedágio - cria item de pedágio ***/
	If lEscPed

		aItemDoc := {}
		cTes     := ""

		If GFXCP12123("GW3_USO")
			cFGer	 := GFEA065FGER(GW3->GW3_NATFRE, GW3->GW3_USO)
		EndIf
		//-- Inicio log Pedagio
		aAdd(aMsgTES,STR0107 +"-"+ STR0068 ) //--  "Inicializando tipo de operação" ## "Valor do Pedágio"

		cTes     := GFE065TES(cTes, "3", "P", GW3->GW3_CRDICM, GW3->GW3_CRDPC, aForLoj, cFGer, GW3->GW3_TPCTB, cPrdFrete, GW3->GW3_CFOP, aMsgTES)

		cSeqItem := PADL(cValToChar(nI), TamSX3("D1_ITEM")[1],"0")

		Aadd(aItemDoc, {"D1_ITEM"    , cSeqItem			, Nil} )
		Aadd(aItemDoc, {"D1_DOC"     , cF1_DOC          , Nil} )
		Aadd(aItemDoc, {"D1_SERIE"   , GW3->GW3_SERDF   , Nil} )
		Aadd(aItemDoc, {"D1_FORNECE" , aForLoj[1]       , Nil} )
		Aadd(aItemDoc, {"D1_LOJA"    , aForLoj[2]       , Nil} )
		Aadd(aItemDoc, {"D1_EMISSAO" , GW3->GW3_DTEMIS  , Nil} )
		Aadd(aItemDoc, {"D1_COD"     , cPrdFrete        , Nil} )
		Aadd(aItemDoc, {"D1_UM"      , "UN"             , Nil} )
		Aadd(aItemDoc, {"D1_QUANT"   , cD1_Quant	    , Nil} ) // se opcint = 4 entao envia 0 senao mantem 1
		Aadd(aItemDoc, {"D1_VUNIT"   , GW3->GW3_PEDAG   , Nil} )
		Aadd(aItemDoc, {"D1_TOTAL"   , GW3->GW3_PEDAG   , Nil} )
		Aadd(aItemDoc, {"D1_TES"     , cTes             , Nil})
		Aadd(aItemDoc, {"D1_VALICM"  , 0                , Nil} )
		Aadd(aItemDoc, {"D1_PICM"    , 0                , Nil} )
		Aadd(aItemDoc, {"D1_BASEICM" , 0                , Nil} )
		Aadd(aItemDoc, {"D1_ICMSRET" , 0                , Nil} )
		Aadd(aItensDoc, aItemDoc)
	EndIf

	aSize(aCFOPDC,0)
	aCFOPDC := Nil
	aSize(aSmTot,0)
	aSmTot := Nil
Return

//-----------------------------------------------------
/*/	Notas Fiscais do Conhecimento de Frete
@author Felipe Machado de Oliveira
@version P11
@since 07/06/2013
/*/
//------------------------------------------------------

Function GetNotasFis(aNotasFis,oModel,aForLoj,cF1_DOC)
	//Obs: Na desatualização não faz uso do model devido a problema do msexecauto dentro de rotina mvc
	Local aEmis  := ""
	Local cNrDc  := ""
	Local cSerDc := ""
	Local nX     := 0
	Local nF     := 0

	If Empty(aForLoj[2])
		aForLoj[2] := "01"
	EndIf

	GW4->(dbSetOrder(1))
	GW4->(dbSeek(xFilial("GW4") + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)))
	Do While GW4->(!Eof()) .And. GW4->GW4_FILIAL == xFilial("GW4") .And. GW4->GW4_EMISDF == GW3->GW3_EMISDF .And. ;
				GW4->GW4_CDESP == GW3->GW3_CDESP .And. GW4->GW4_SERDF == GW3->GW3_SERDF .And. GW4->GW4_NRDF == GW3->GW3_NRDF .And. ;
				DToS(GW4->GW4_DTEMIS) == DToS(GW3->GW3_DTEMIS)

		GW1->(dbSetOrder(1))
		GW1->(dbSeek(GW4->GW4_FILIAL+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC ))

		SF1->(dbSetOrder(8))
		SF1->(dbSeek(xFilial("SF1")+GW1->GW1_DANFE ))


		If !Empty( GW1->GW1_DANFE )
			If SF1->(!Eof()) .And. SF1->F1_FILIAL == xFilial("SF1") .And. AllTrim(SF1->F1_CHVNFE) == AllTrim(GW1->GW1_DANFE)
				//Armazena o tipo de nota fiscal para usar no ParamMT116.
				ctpNfMat := SF1->F1_TIPO
				Aadd(aNotasFis,{ {"PRIMARYKEY",SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+ctpNfMat,Nil} })
				Aadd(aNotasFis,{ {"D1_ORIGLAN","F",Nil}} ) // Valor fixo devido ser utilizado dentro do materiais
			EndIf
		Else
			aEmis  := GFEA055DEV(GW4->GW4_EMISDC)
			cNrDc  := PadR(GW4->GW4_NRDC, TamSX3("F1_DOC")[1])
			cSerDc := PadR(GW4->GW4_SERDC, TamSX3("F1_SERIE")[1])

			SF1->(dbSetOrder(1))
			nF := Len(aEmis)
			For nX:= 1 To nF
				SF1->(dbSeek(xFilial("SF1")+cNrDc+cSerDc+aEmis[nX][1]+aEmis[nX][2]))
				If SF1->(!Eof()) .And. SF1->F1_FILIAL == xFilial("SF1") ;
									.And. SF1->F1_EMISSAO == GW1->GW1_DTEMIS;
									.And. AllTrim(SF1->F1_DOC) == AllTrim(cNrDc) ;
									.And. AllTrim(SF1->F1_SERIE) == AllTrim(cSerDc) ;
									.And. AllTrim(SF1->F1_FORNECE) == AllTrim(aEmis[nX][1]) ;
									.And. Alltrim(SF1->F1_LOJA) == AllTrim(aEmis[nX][2])

					//Armazena o tipo de nota fiscal para usar no ParamMT116.
					ctpNfMat := SF1->F1_TIPO
					Aadd(aNotasFis,{ {"PRIMARYKEY",cNrDc+cSerDc+aEmis[nX][1]+aEmis[nX][2]+ctpNfMat,Nil} })
					Aadd(aNotasFis,{ {"D1_ORIGLAN","F",Nil}} ) // Valor fixo devido ser utilizado dentro do materiais
				EndIf
			Next
		Endif
		GW4->(dbSkip())
	EndDo
Return

//-----------------------------------------------------
/*/	Montagem do array de envio como parametro de execução do MATA116
@author Felipe Machado de Oliveira
@version P11
@since 26/06/2013
/*/
//------------------------------------------------------

Function ParamMt116(nOpc, aDocFrete, aForLoj, cF1_DOC, aCidadesUF, cOpcInteg, aMsgTES)
	Local cTes    	 := ""
	Local cOper   	 := ""
	Local cFGer   	 := ""
	Local cTpCte  	 := ""
	Local cCFOPTES	 := ""
	Local cAliasCFOP := Nil
	Local cTpImp  	 := Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")
	Local lCpoTES 	 := GFEA065INP()
	Local cCidOri 	 := Posicione("GU7",1,XFILIAL("GU7")+Posicione("GU3",1,xFilial("GU3")+GW3->GW3_CDREM,"GU3_NRCID") ,"GU7_CDUF")
	Local cNtfGfe 	 := SuperGetMv("MV_NTFGFE",,"")
	Local cTESGFE 	 := SuperGetMv("MV_TESGFE", .F., "1")
	Local lOracle    := (TcGetDB() == 'ORACLE')
	Local lPostgre   := (TcGetDb() == 'POSTGRES')
	
	Default cOpcInteg := GW3->GW3_ACINT
	Default aMsgTES := {}

	aAdd(aDocFrete,{"MV_PAR11", dDataBase-99999               , Nil, "Data inicial para filtro das nota"})
	aAdd(aDocFrete,{"MV_PAR12", dDataBase                     , Nil, "Data final para filtro das notas"})
	aAdd(aDocFrete,{"MV_PAR13", nOpc                          , Nil, "2-Inclusao ; 1=Exclusao"})
	aAdd(aDocFrete,{"MV_PAR14", Space(TamSx3("F1_FORNECE")[1]), Nil, "Rementente das notas contidas no conhecimento"})
	aAdd(aDocFrete,{"MV_PAR15", Space(TamSx3("F1_LOJA")[1])   , Nil, "Loja do remetente das notas contidas no conhecimento"})
	aAdd(aDocFrete,{"MV_PAR16", Iif(ctpNfMat $ "BD", 2, 1)    , Nil, "Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef"})
	aAdd(aDocFrete,{"MV_PAR17", 2                             , Nil, "Aglutina itens ; 2=Nao aglutina itens"})
	aAdd(aDocFrete,{"MV_PAR18", cCidOri    					  , Nil, "UF das notas contidas no conhecimento"})
	aAdd(aDocFrete,{"MV_PAR21", GW3->GW3_VLDF                 , Nil, "Valor do conhecimento"})
	aAdd(aDocFrete,{"MV_PAR22", 1                             , Nil, "Formulario Proprio 2=Sim 1=Nao"})
	aAdd(aDocFrete,{"MV_PAR23", cF1_DOC                       , Nil, "Numero da nota de conhecimento"})
	aAdd(aDocFrete,{"MV_PAR24", PadR(GW3->GW3_SERDF, TamSX3("F1_SERIE")[1]) , Nil, "Serie da nota de conhecimento"}) 
	aAdd(aDocFrete,{"MV_PAR25", aForLoj[1]                    , Nil, "Fornecedor da nota de conhecimento"}) 
	aAdd(aDocFrete,{"MV_PAR26", aForLoj[2]                    , Nil, "Loja do fornecedor da nota de conhecimento"}) 

	If lCpoTes
		cTes := GW3->GW3_TES
		If !Empty(cTes)
			aAdd(aMsgTES,STR0121 +" "+ cTes) //-- "TES atribuida GW3"
		EndIf
	EndIf

	If GFXCP12123("GW3_USO")
		cFGer	 := GFEA065FGER(GW3->GW3_NATFRE, GW3->GW3_USO)
	EndIf

	cAliasCFOP := GetNextAlias()

	cQuery := "SELECT "
	If lPostgre .Or. lOracle
		cQuery += " "
	Else
		cQuery += "TOP 1 "
	EndIf
	cQuery += "GW8_CFOP CFOPITEM"
	cQuery += " FROM " + RetSqlName("GW3") + " GW3"
	cQuery += " INNER JOIN " + RetSqlName("GW4") + " GW4"
	cQuery += " ON GW4.GW4_FILIAL  = GW3.GW3_FILIAL"
	cQuery += " AND GW4.GW4_EMISDF = GW3.GW3_EMISDF"
	cQuery += " AND GW4.GW4_CDESP  = GW3.GW3_CDESP"
	cQuery += " AND GW4.GW4_SERDF  = GW3.GW3_SERDF"
	cQuery += " AND GW4.GW4_NRDF   = GW3.GW3_NRDF"
	cQuery += " AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS"
	cQuery += " AND GW4.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("GW8") + " GW8"
	cQuery += " ON GW8.GW8_FILIAL  = GW4.GW4_FILIAL"
	cQuery += " AND GW8.GW8_CDTPDC = GW4.GW4_TPDC"
	cQuery += " AND GW8.GW8_EMISDC = GW4.GW4_EMISDC"
	cQuery += " AND GW8.GW8_SERDC  = GW4.GW4_SERDC"
	cQuery += " AND GW8.GW8_NRDC   = GW4.GW4_NRDC"
	cQuery += " AND GW8.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GW3.GW3_FILIAL = '" + xFilial("GW3") + "'"
	cQuery += " AND GW3.GW3_CDESP  = ?"
	cQuery += " AND GW3.GW3_EMISDF = ?"
	cQuery += " AND GW3.GW3_SERDF  = ?"
	cQuery += " AND GW3.GW3_NRDF   = ?"
	cQuery += " AND GW3.GW3_DTEMIS = ?"
	cQuery += " AND GW3.D_E_L_E_T_ = ' '"
	If lOracle
		cQuery += " FETCH FIRST 1 ROWS ONLY"
	ElseIf lPostgre
		cQuery += " LIMIT 1"
	EndIf

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)
	oQry:SetString(1, GW3->GW3_CDESP)
	oQry:SetString(2, GW3->GW3_EMISDF)
	oQry:SetString(3, GW3->GW3_SERDF)
	oQry:SetString(4, GW3->GW3_NRDF)
	oQry:SetString(5, DTOS(GW3->GW3_DTEMIS))

	cAliasCFOP := oQry:OpenAlias()
	If (cAliasCFOP)->(!Eof())
		If cTESGFE == '3'
			cCFOPTES := (cAliasCFOP)->CFOPITEM
		Else
			cCFOPTES := GW3->GW3_CFOP
		EndIf
	EndIf
	(cAliasCFOP)->(dbCloseArea())
	
	If FindFunction("GFEX021BOPER")
		aRet := GFEX021BOPER(AllTrim(cCFOPTES), cTpImp, GW3->GW3_TRBIMP, GW3->GW3_CRDICM, GW3->GW3_CRDPC, cFGer, GW3->GW3_TPCTB, @aMsgTES)
	Else
		aRet := {.F.,"01"}
		aAdd(aMsgTES,STR0108 +" 01") //--  "Retornado tipo de operação "
	EndIf

	If aRet[1] == .T.
		cOper := aRet[2]
		aAdd(aMsgTES,STR0108 + " - " + cOper) //--  "Retornado tipo de operação "

		If cTESGFE == "1" .Or. cTESGFE == "3" // TES atribuída pelo sistema
			cTes := MaTESInt(1,cOper,aForLoj[1],aForLoj[2],"F",) // Não envia o item pois é custo. Na apropriação de custo o GFE não cria produto.
			aAdd(aMsgTES,STR0120 + " - " + cTes) //--"Interpretada TES inteligente"
		EndIf
	Else
		If aRet[2] == "01" .Or. aRet[2] == "02"
			Do Case
				Case cTpImp == "1" //"1=ICMS"
					Do Case
						Case GW3->GW3_TRBIMP == "2" //"2=ISENTO"
							cOper := "T8"
							aAdd(aMsgTES,STR0109 + " " +;         //-- "Selecionando tipo de operação para ICMS"
										STR0124  + " - " + cOper) //-- "Isento/Não-tributado"
						Case GW3->GW3_TRBIMP == "3" //"3=SUBS. TRIB."
							cOper := "T9"
							aAdd(aMsgTES,STR0109 + " " +;         //-- "Selecionando tipo de operação para ICMS"
										STR0125  + " - " + cOper) //-- "Subst.Tributária"
					EndCase
			EndCase

			If Empty(cOper)
				cOper := "T7"
				aAdd(aMsgTES,STR0109 + " " +;         //-- "Selecionando tipo de operação para ICMS"
							STR0119  + " - " + cOper) //--  "Sem regra exclusiva, utilizado tipo de operação padrão"
			EndIf

			If Empty(cTes) .And. (cTESGFE == "1" .Or. cTESGFE == "3") // TES atribuída pelo sistema
				SFM->(dbSetOrder(1))
				SFM->(dbSeek(xFilial("SFM")+cOper))
				Do While SFM->(!Eof()) .AND. SFM->FM_TIPO == cOper
					If aForLoj[1] == SFM->FM_FORNECE .AND. aForLoj[2] == SFM->FM_LOJAFOR
						cTes := SFM->FM_TE
						aAdd(aMsgTES,STR0126 + " - " + cTes+ ", "+; //-- "TES atribuída SFM "
									 STR0127 + ": " + aForLoj[1]+"/"+aForLoj[2]) //-- "Fornecedor/Loja "
						Exit
					EndIf
					/*Se não encontrar uma TES específica para o transportador, utiliza uma que esteja com os campos em branco
					"FM_FORNECE" e "FM_LOJAFOR"*/
					If Empty(SFM->FM_FORNECE) .AND. Empty(SFM->FM_LOJAFOR)
						cTes := SFM->FM_TE
						aAdd(aMsgTES,STR0126 + " - " + cTes+ ", "+; //-- "TES atribuída SFM "
									 STR0127 + ": " + STR0128) //-- "Fornecedor/Loja " ## "em branco "
					EndIf
					SFM->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	If Empty(cTes)
		aAdd(aMsgTES, STR0130) //"TES em branco. Cadastro não encontrado para o tipo de operação!"
	EndIf

	aAdd(aDocFrete,{"MV_PAR27"  ,cTes , Nil, "TES a ser utilizada nos itens do conhecimento"})

	aAdd(aDocFrete,{"MV_PAR28"  ,0    , Nil, "Valor da base de calculo do ICMS retido"})
	aAdd(aDocFrete,{"MV_PAR29"  ,0    , Nil, "Valor do ICMS retido"}) 
	If lCpoTES
		aAdd(aDocFrete,{"MV_PAR31",GW3->GW3_CPDGFE, Nil, "Condicao de pagamento"})
	Else
		aAdd(aDocFrete,{"MV_PAR31",SuperGetMv("MV_CPDGFE", .F., Space(TamSX3("GW3_CPDGFE")[1])), Nil, "Condicao de pagamento"})
	EndIf
	aAdd(aDocFrete,{"Emissao"   ,GW3->GW3_DTEMIS , Nil}) // Data de emissao do conhecimento
	aAdd(aDocFrete,{"F1_ESPECIE",GW3->GW3_CDESP  , Nil}) // Especie do documento
	aAdd(aDocFrete,{"F1_CHVNFE" ,GW3->GW3_CTE    , Nil}) //Chave CTE

	//-- Validação retirada para tratamento de aliquota respeitando a modalidade de transporte.
	// SE O VALOR DA BASE DO ICMS + PEDAGIO FOR IGUAL AO VALOR DO DOCUMENTO, O PEDÁGIO FOI DESCONTADO E DEVE SER ENVIADA A BASE DIFERENCIADA
	// FOI COLOCADO ESTE TRATAMENTO POIS O PARAMETRO NF_BASEICM FOI UTILIZADO EXATAMENTE PARA ESTE PROPOSITO.
	// SE TIVER OUTRO SITUAÇÃO QUE A BASE DEVA SER ENVIADA DIFERENTE, DEVERÁ SER ANALISADA PARA NÃO IMPACTAR EM OUTRAS SITUAÇÕES.

	If Empty(AllTrim(cTes)) .AND. !Empty(AllTrim(cOper))
		aAdd(aDocFrete,{"D1_OPER", cOper, Nil}) //Tipo de operação
	EndIf

	AAdd(aDocFrete,{"F1_TPFRETE", "F", Nil}) //Tipo Frete integração realizada pelo MATA116, enviar a informação como FOB.
	AAdd(aDocFrete,{"F1_VALPEDG", GW3->GW3_PEDAG, Nil})

	If (cOpcInteg $ "2") .And. !Empty(GW3->GW3_CTE)
		If GW3->GW3_TPCTE == "0"
			cTpCte = "N"
		ElseIF GW3->GW3_TPCTE == "1"
			cTpCte = "C"
		ElseIF GW3->GW3_TPCTE == "2"
			cTpCte = "A"
		ElseIF GW3->GW3_TPCTE == "3"
			cTpCte = "S"
		EndIf
		aAdd(aDocFrete, {"F1_TPCTE", cTpCte, Nil}) //Tipo CTE
	EndIf

	//-- Validação incluida para tratamento de aliquota respeitando a modalidade de transporte.
	If cTpImp == "1" //"1=ICMS"
		AAdd(aDocFrete,{"NF_BASEICM", GW3->GW3_BASIMP, Nil}) //Base do ICMS
		AAdd(aDocFrete,{"IT_ALIQICM", GW3->GW3_PCIMP , Nil}) //Alqiuota do ICMS
		AAdd(aDocFrete,{"NF_VALICM" , GW3->GW3_VLIMP , Nil}) //Alqiuota do ICMS
	EndIf
	/* Origem x Destino do transporte - Ato Cotepe 48 */
	Aadd(aDocFrete, {"F1_EST"     , aCidadesUF[1][2], Nil } )
	Aadd(aDocFrete, {"F1_ESTDES"  , aCidadesUF[1][4], Nil } )
	Aadd(aDocFrete, {"F1_MUORITR" , aCidadesUF[1][1], Nil } )
	Aadd(aDocFrete, {"F1_UFORITR" , aCidadesUF[1][2], Nil } )
	Aadd(aDocFrete, {"F1_MUDESTR" , aCidadesUF[1][3], Nil } )
	Aadd(aDocFrete, {"F1_UFDESTR" , aCidadesUF[1][4], Nil } )
	Aadd(aDocFrete, {"E2_NATUREZ" , cNtfGfe    		, Nil } )
Return

/*/{Protheus.doc} GFEA065CTE

@author siegklenes.beulke
@since 29/04/2013
@version 1.0

@param lValCte, Informa se já executou a função de validação local da chave do CT-e

@description

Faz a consulta no SEFAZ da chave do cte, se estiver parametrizado
Uso dicionário/Model

/*/
Function GFEA065CTE(lValCte)
	Local lRet        := .T.
	Local aRet        := {}
	Local aRetVldCte  := {.T.,""}
	Local cChvCte     := FwFldGet("GW3_CTE")
	Local cEmissor    := FwFldGet("GW3_EMISDF")
	Local cSerie      := FwFldGet("GW3_SERDF")
	Local cNumero     := FwFldGet("GW3_NRDF")
	Local dDataEmis   := FwFldGet("GW3_DTEMIS")
	Local cTextoProc  := ""

	Private oProcess  := Nil

	Default lValCte := .F.

	If SuperGetMv("MV_CHVNFE",.F.,.F.)
		If !lValCte
			aRetVldCte := GFE065VCTE(cChvCte, cEmissor, cSerie, cNumero, dDataEmis)
		EndIf
		If !lValCte .And. !aRetVldCte[1] .And. Len(AllTrim(SubStr(cChvCte,1,Len(cChvCte)-1))) == Len(cChvCte)-1
			Help(,, 'HELP',, "Chave Ct-e inválida:"+CRLF+aRetVldCte[2], 1, 0)
			Return .F.
		EndIf
		// Nesse ponto a chave do CT-e deve estar válida, seja do Valid do Campo ou Post do Model, realizando a consulta no SEFAZ
		If !Empty(cChvCte) .And. Len(AllTrim(SubStr(cChvCte,1,Len(cChvCte)-1))) == Len(cChvCte)-1
			If IsBlind()
				aRet := GFEA065PROC(cChvCte)
			Else
				If GA065TC20()
					cTextoProc := "Gerando arquivo de envio para Neogrid..."
				Else
					cTextoProc := "Conectando ao TSS..."
				EndIf

				oProcess := MsNewProcess():New({|| (aRet := GFEA065PROC(cChvCte)),aRet[1]}, "Consulta ao SEFAZ", cTextoProc)
				oProcess:Activate()
			EndIf
			If !aRet[1]
				Help(,,'HELP',,aRet[2],1,0)
				Return .F.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} GFEA065PROC

@author siegklenes.beulke
@since 29/04/2013
@version 1.0

@description

Faz a consulta no TSS
baseado no TMA050SEF
/*/
Function GFEA065PROC(cChvCte)
	//Variáveis comuns
	Local aRet             := {.F.,""}
	Local lTela            := !IsBlind()
	Local cCodRet          := "Codigo de retorno: "
	Local cMensRet         := "Mensagem de retorno: "
	Local cProt	           := "Protocolo: "
	//Variáveis específicas para Colaboração
	Local aDir             := {"",""}
	Local cXML             := ""
	Local cNmArqSExt       := ""
	Local cNmArqOut        := ""
	Local cNmArqIn         := ""
	Local cDirArqIn        := ""
	Local nCount           := 0
	Local lEncerraConsulta := .F.
	Local cError           := ""
	Local cWarning         := ""
	Local nHandle          := 0
	Local cBuffer          := ''
	Local nSize            := 0
	Local oXML             := NIL
	Local cRetProt         := ""
	Local cRetCodRet       := ""
	Local cRetMensRet      := ""
	Local nTentativa       := 1
	Local cURL             := PadR(SuperGetMV("MV_SPEDURL",.F.,"http://"),250)
	Local nTimeOut         := SuperGetMV("MV_GFETOTC", .F., 25)
	Local cVerCte          := SuperGetMv("MV_VERCTE", .F., "2.00")
	//Variáveis específicas para TSS
	Local cIdEnt           := ""

	Private oWS            := Nil

	Default cChvCte        := ""

	lBloqSeFaz := .F.
	If GA065TC20()
		//Verifica se a empresa tem licença pro TC 2.0
		If ((!FindFunction("FWLSEnable") .Or. !FWLSEnable(TOTVS_COLAB_ONDEMAND)) .and. !FwEmpTeste())
			aRet[2] := "Ambiente não licenciado para o modelo TOTVS Colaboração 2.0."
			Return aRet
		EndIf

		If nTimeOut = 0
			aRet[2] := "Parâmetro Tempo de espera para processar retorno da consulta via TOTVS Colaboração 2.0 não informado (aba Integrações ERP)."
			Return aRet
		EndIf

		If Empty(cVerCte) .Or. cVerCte = " "
			aRet[2] := "Parâmetro Versão do CTe para TOTVS Colaboração 2.0 não informado (aba Integrações ERP)."
			Return aRet
		EndIf

		//Determina diretórios e arquivos entrada/saída
		cNmArqSExt := "208_" + GFENOW(.T., .T., "") + "_0001"

		aDir := GA065DPar("MV_NGOUT")
		If Empty(aDir[1])
			aRet[2] := aDir[2]
			Return aRet
		Else
			cNmArqOut := aDir[1] + cNmArqSExt + ".xml"
		EndIf

		aDir := GA065DPar("MV_NGINN")
		If Empty(aDir[1])
			aRet[2] := aDir[2]
			Return aRet
		Else
			cDirArqIn := aDir[1]
			cNmArqIn := cDirArqIn + cNmArqSExt + "*.xml"
		EndIf

		If lTela
			oProcess:setRegua1(nTimeOut + 1)
			oProcess:incRegua1("Gerando arquivo de envio para Neogrid...")
			oProcess:setRegua2(nTimeOut + 1)
			oProcess:incRegua2("Gerando arquivo de envio para Neogrid...")
		EndIf

		//Grava o arquivo de saída
		If !File(cNmArqOut)
			nHandle := FCreate(cNmArqOut,FC_NORMAL)
			If nHandle <= 0
				aRet[2] :=  "Não foi possível gerar o arquivo de consulta " + cNmArqOut + "."
				Return aRet
			EndIf
			FSeek(nHandle, 0)
		Else
			nHandle := FOpen(cNmArqOut,FO_READWRITE)
			If nHandle = 0
				aRet[2] := "Não foi possível gerar o arquivo de consulta " + cNmArqOut + "."
				Return aRet
			EndIf
			FSeek(nHandle, 0, FS_END)
		EndIf

		//Monta o XML
		cXML := '<consSitCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCTe + '">' + ;
				'<tpAmb>' + cValToChar(SuperGetMV("MV_AMBCTEC", .F., "1")) + '</tpAmb>' + ;
				'<xServ>CONSULTAR</xServ>' + ;
				'<chCTe>' + cChvCte + '</chCTe>' + ;
				'</consSitCTe>'

		FWrite(nHandle,cXML,len(cXML))
		FClose(nHandle)

		//Aguarda o retorno da Neogrid
		Do While !lEncerraConsulta
			oProcess:setRegua1(nTimeOut + 1)
			oProcess:setRegua2(nTimeOut + 1)

			For nCount = 1 to nTimeOut
				If lTela
					oProcess:incRegua1("Aguardando retorno da consulta - " + cValToChar(nTentativa) + "ª tentativa...")
					oProcess:incRegua2("Tempo restante: " + cValToChar(nTimeOut - nCount + 1) + " segundos...")
				End If

				Sleep(1000)

				//Faz a verificação a cada 5 segundos ou no fim do laço
				If nCount % 5 = 0 .Or. nCount = nTimeOut
					aDirImpor := DIRECTORY(Alltrim(cNmArqIn))

					//Só pode encontrar 1 arquivo, que terá o mesmo nome do arquivo de envio e mais um número aleatório de 4 dígitos
					If Len(aDirImpor) = 1
 						cNmArqIn := cDirArqIn + aDirImpor[1][1]

						If File(cNmArqIn)
							nHandle := FOpen(cNmArqIn,FO_READ+FO_SHARED)
 							If nHandle < 0
 								aRet[2] := "Não foi possível efetuar leitura do arquivo de retorno de consulta via Neogrid " + cNmArqIn + "."
								Return aRet
 							EndIf

							nSize := FSeek(nHandle,FS_SET,FS_END)
							FSeek(nHandle,0)
							FRead(nHandle,@cBuffer,nSize)

							oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)
							FClose(nHandle)
							nHandle   := -1
							FErase(cNmArqIn)

							If XmlChildEx(oXML, "_RETCONSSITCTE") = NIL
								aRet[2] := "Arquivo de retorno com estrutura inválida."
							Else
								If XmlChildEx(oXML:_RETCONSSITCTE, "_PROTCTE") != NIL
									cRetProt := oXML:_RETCONSSITCTE:_PROTCTE:_INFPROT:_NPROT:TEXT
								EndIf

								cRetCodRet  := oXML:_RETCONSSITCTE:_CSTAT:TEXT
								cRetMensRet := oXML:_RETCONSSITCTE:_XMOTIVO:TEXT
								If AllTrim(cRetCodRet) == "731"
									lBloqSeFaz := .T.
									cMotBloq   := "CT-e necessita de aprovação." + CRLF +;
													cCodRet+cRetCodRet+"."+CRLF+;
													cMensRet+cRetMensRet+"."+CRLF+;
													cProt+cRetProt+"."
									aRet[1] := .T.
								ElseIf Empty (cRetProt)
									aRet[2] := "A chave digitada não foi encontrada na SEFAZ."
								ElseIf AllTrim(cRetCodRet) != "100"
									aRet[2] := "Uso do CT-e não autorizado." + CRLF +;
										cCodRet+cRetCodRet+"."+CRLF+;
										cMensRet+cRetMensRet+"."+CRLF+;
										cProt+cRetProt+"."
								Else
									aRet[1] := .T.
								EndIf
							EndIf

							lEncerraConsulta := .T.
							Exit
						EndIf
					ElseIf Len(aDirImpor) > 1
						aRet[2] := "Foi encontrado mais de um arquivo usando o filtro " + cNmArqIn + ". Repita a consulta."
						lEncerraConsulta := .T.
						Exit
					EndIf
				EndIf
			Next nCount

			//Caso não encontre retorno da consulta:
			//Se não houver interação de tela, não permitirá aguardar e retornará false.
			//Senão, irá solicitar para aguardar mais tempo.
			If !lEncerraConsulta
				If !lTela
					aRet[2] := "A consulta da chave de acesso não retornou nenhum resultado."
					lEncerraConsulta := .T.
				Else
					If MsgYesNo("A consulta da chave de acesso não retornou nenhum resultado. Repetir a busca?")
						nTentativa += 1
					Else
						aRet[2] := 'A chave digitada não foi validada na SEFAZ.'
						lEncerraConsulta :=  .T.
					EndIf
				EndIf
			EndIf
		EndDo
	Else
		If lTela
			oProcess:setRegua1(3)
			oProcess:incRegua1("Conectando ao TSS...")
			oProcess:setRegua2(3)
			oProcess:incRegua2("Conectando ao TSS...")
		EndIf

		If TMSIsReady(,,.F.)  //(cURL),ntipo,lhelp
				 //Obtem o codigo da entidade
			If lTela
				oProcess:incRegua1("Obtendo identidade de conexão...")
				oProcess:incRegua2("Obtendo identidade de conexão...")
			EndIf
			oWS := WsSPEDAdm():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
			oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
			oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
			oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
			oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
			oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
			oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
			oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
			oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
			oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
			oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
			oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
			oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
			oWS:oWSEMPRESA:cCEP_CP     := Nil
			oWS:oWSEMPRESA:cCP         := Nil
			oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
			oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
			oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
			oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
			oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
			oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
			oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cINDSITESP  := ""
			oWS:oWSEMPRESA:cID_MATRIZ  := ""
			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
			oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

			If oWs:ADMEMPRESAS()
				cIdEnt  := oWs:cADMEMPRESASRESULT
			Else
				aRet[2] := "Não foi possível obter o código da identidade. Motivo:" + CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				Return aRet
			EndIf

			If lTela
				oProcess:incRegua1("Consultando Chave CT-e...")
				oProcess:incRegua2("Consultando Chave CT-e...")
			EndIf

			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT      := cIdEnt
			ows:cCHVNFE      := cChvCte
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

			If oWs:ConsultaChaveNFE()
				If AllTrim(AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE)) == "731"
					lBloqSeFaz := .T.
					cMotBloq   := "CT-e necessita de aprovação." + CRLF +;
									cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+"."+CRLF+;
									cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+"."+CRLF+;
									cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+"."
					aRet[1] := .T.
				ElseIf Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
						aRet[2] := 'A chave digitada não foi encontrada na SEFAZ.'
				ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) != "100"
					aRet[2] := "Uso do CT-e não autorizado. " + CRLF +;
								cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+"."+CRLF+;
								cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+"."+CRLF+;
								cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+"."
				Else
					aRet[1] := .T.
				EndIf
			 Else
				aRet[2] := "Não foi possível consultar a Chave CT-e no SEFAZ. Motivo:" + CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			 EndIf
		Else
			If Empty(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
				aRet[2] := "Não foi possível conectar ao TSS. Verifique as configurações de conexão. "
			Else
				aRet[2] := "Não foi possível conectar ao TSS. Motivo: " + CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf
		EndIf
	EndIf
Return aRet

Static Function GA065DPar(cParam)
	Local aRet   := {nil, nil}
	Local cBarra := If(isSrvUnix(),"/","\")

	aRet[1] := AllTrim(SuperGetMv(cParam, .F., ""))
	If Empty(aRet[1])
		aRet[2] := "Não foi especificado um diretório para comunicação com Neogrid no parâmetro " + cParam + "."
	Else
		If !ExistDir(aRet[1])
			If MakeDir(aRet[1]) <> 0
				aRet[2] := "Não foi possível criar pasta " + cValToChar(FError())
			EndIf
		EndIf

		If SubStr(aRet[1], Len(aRet[1]), 1) != '/' .And. SubStr(aRet[1], Len(aRet[1]), 1) != '\'
			aRet[1] += cBarra
		EndIf
	EndIf
Return aRet

//Indica se a forma de transmissão da consulta da chave do CTe será por TOTVS Colaboração 2.0
Function GA065TC20()
	Local cTotvsColab	:= SuperGetMV("MV_SPEDCOL", .F., "N")
	Local cTotvsCol20	:= Alltrim( SuperGetMv("MV_TCNEW", .F. ,"" ) )

	//Validação de utilização do Totvs Colaboração 2.0
	//A mesma regra existe nos GFEA065/GFEA118/GFEX000.
	//Lógica copiada da função ColabGeneric.prw
	If cTotvsColab == "S" .And. ( ("0" $ cTotvsCol20) .Or. ("6" $ cTotvsCol20)) //0-Todos / 6-Recebimento
		Return .T.
	EndIf
Return .F.

//Preenche o campo GW3_ICMPDG, de acordo com o informado no cadastro de tributações por UF
//Chamada no gatilho do campo GW3_CDREM
Function GFEA065ICM()
	local cCidRem:= Posicione("GU3",1,xFilial("GU3")+M->GW3_CDREM,"GU3_NRCID")
	local cUFRem := Posicione("GU7",1,xFilial("GU7")+cCidRem,"GU7_CDUF")

	If GUT->(dbSeek(xFilial("GUT")+cUFRem))
		Return GUT->GUT_ICMPDG
	EndIf
Return "2" //Retorna "Não"


Static Function RetTipoCTE(cCTE)
	Local aCombo1   :={}
	Local aComboCte :={}
	Local cTPCTE    := ""
	Local nCT       := 0

	If SF1->(FieldPos("F1_TPCTE"))>0
		aCombo1:=x3CboxToArray("F1_TPCTE")[1]
		aSize(aComboCte,Len(aCombo1)+1)
		For nCT:=1 to Len(aComboCte)
			aComboCte[nCT]:=IIf(nCT==1," ",aCombo1[nCT-1])
		Next nCT
		nCT:=Ascan(aComboCTE, {|x| Substr(x,1,1) == cCTE})
		If nCT>0
			cTPCTE:=aComboCte[nCT]
		EndIf
	EndIf
Return cTPCTE

/*/{Protheus.doc} GFEA065TPDF()

@author joao.schmidt
@since 23/09/2014
@version 1.0

@description

Realiza a validação do tipo do cálculo dos documentos de carga ao realizar a alteração do
tipo do documento de frete.

/*/
Function GFEA065TPDF()
	Local cOBNENT     := SuperGetMV("MV_OBNENT",.F.,"1") // Calculos de Fretes Normais (de Entrada) sao Obrigatorios
	Local cOBCOMP     := SuperGetMV("MV_OBCOMP",.F.,"1") // Calculos de Fretes Complementares       sao Obrigatorios
	Local cOBREEN     := SuperGetMV("MV_OBREEN",.F.,"1") // Calculos de Fretes de Reentrega         sao Obrigatorios
	Local cOBDEV      := SuperGetMV("MV_OBDEV" ,.F.,"1") // Calculos de Fretes de Devolucao         sao Obrigatorios
	Local cOBSERV     := SuperGetMV("MV_OBSERV",.F.,"1") // Calculos de Fretes de Servico           sao Obrigatorios
	Local cOBREDE     := SuperGetMV('MV_OBREDE',.F.,cOBNENT,cFilAnt) // Calculos de Frete Redespacho            sao Obrigatorios
	Local ChkObrigat  := .F.
	Local lVldCalc    := .F.
	Local lVldSrv     := .F.
	Local lVerificado := .F.
	Local lExistCamp  := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1")  .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local cCalcn      := ""
	Local nRecPriClc  := 0

	// Verifica se o Tipo de Documento está parametrizado como obrigatório nos parâmtros
	Do Case
		Case FwFldGet("GW3_TPDF") == "1" //Normal
			// Quando for Normal de Saída, sempre será obrigatório

			//Se especie do documento de frete(GVT), estiver com o parâmetro "Calc Normal" igual a "sempre obrigatório" ou "Conforme Param Módulo"
			GVT->(dbSetOrder(1))
			If GVT->(dbSeek(xFilial("GVT") + GW3->GW3_CDESP))
				cCalcn := IIF(!Empty(GVT->GVT_CALCN),GVT->GVT_CALCN,"3")
				If cCalcn == "1" .Or. (cCalcn == "3" .And. cOBNENT == "1")
					ChkObrigat := .T.
				EndIf
			EndIf
		Case FwFldGet("GW3_TPDF") == "2" .OR. FwFldGet("GW3_TPDF") == "3" //Complementares
			If cOBCOMP $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "4" // Reentrega
			If cOBREEN $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "5" // Devolução
			If cOBDEV $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "6" // Redespacho
			If cOBREDE $ "1S"
				ChkObrigat := .T.
			EndIf

		Case FwFldGet("GW3_TPDF") == "7" // Serviço
			If cOBSERV $ "1S"
				ChkObrigat := .T.
			EndIf
	EndCase

	// Ponto de entrada
	If ExistBlock("GFEA6511")
		ChkObrigat := ExecBlock("GFEA6511",.f.,.f.,{ChkObrigat,FwFldGet("GW3_FILIAL"),FwFldGet("GW3_CDESP"),FwFldGet("GW3_EMISDF"),FwFldGet("GW3_SERDF"),FwFldGet("GW3_NRDF"),FwFldGet("GW3_DTEMIS") })
	EndIf

	If ChkObrigat
		GW4->(dbSetOrder(1))
		If GW4->(dbSeek(xFilial("GW4")+FwFldGet("GW3_EMISDF")+FwFldGet("GW3_CDESP")+FwFldGet("GW3_SERDF")+FwFldGet("GW3_NRDF")+DTOS(FwFldGet("GW3_DTEMIS"))))

			Do While GW4->(!Eof()) .And. xFilial("GW4")+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS) == FwFldGet("GW3_FILIAL")+FwFldGet("GW3_EMISDF")+FwFldGet("GW3_CDESP")+FwFldGet("GW3_SERDF")+FwFldGet("GW3_NRDF")+DTOS(FwFldGet("GW3_DTEMIS"))
				GW1->(dbSetOrder(1))
				GW1->(dbSeek(xFilial("GW1")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC))

				GWH->(dbSetOrder(2))
				If GWH->(dbSeek(xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
					// Procura em todos os Cálculos de Documento de Carga, um que o Tipo de Cálculo, seja igual ao Tipo de Cálcudo do Documento de Frete
					Do While GWH->(!Eof()) .And. xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC

						GWF->(dbSetOrder(1))
						GWF->(dbSeek(xFilial("GWF")+GWH->GWH_NRCALC))
						// Compara o cálculo do Documento de Carga com o de Documento de Frete
						// GW3->GW3_TPDF X GWF->GWF_TPCALC -> 1=Normal;2=Redespacho;3=Reentrega;4=Devolucao;5=Servico;6=Compl. Valor;7=Compl. ICMS;8=Provisao
						If lVldCalc <> .T. .And. FwFldGet("GW3_TPDF") == GWF->GWF_TPCALC
							lVldCalc := .T.
						EndIf

						If !lVerificado
							lVerificado := .T.
						EndIf

						// Valida se o calculo não está vinculado a outro documento de frete
						If lVldCalc .And. lExistCamp .And. !Empty(GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF))) .And.;
							GWF->(GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DToS(GWF_DTEMDF)) <>  FwFldGet("GW4_FILIAL")+FwFldGet("GW4_CDESP")+FwFldGet("GW4_EMISDF")+FwFldGet("GW4_SERDF")+FwFldGet("GW4_NRDF")+DToS(FwFldGet("GW4_DTEMIS"))

							lVldCalc := .F.
							lVldSrv := .T.
						EndIf

						If GFXCP12117("GW3_CDTPSE") .And. lVldCalc .And. FwFldGet("GW3_TPDF") == '7'
							If Empty(nRecPriClc)
								nRecPriClc := GWF->(Recno())
							EndIf
							If FwFldGet("GW3_CDTPSE") != GWF->GWF_CDTPSE
								lVldCalc := .F.
								lVldSrv := .F.
							Else
								lVldSrv := .T.
							EndIf
						EndIf
						GWH->(dbSkip())
					EndDo

					If GFXCP12117("GW3_CDTPSE") .And. lVldCalc == .F. .And. lVldSrv == .F. .And. !Empty(nRecPriClc)
						lVldCalc := .T.
						GWF->(dbGoTo(nRecPriClc))
					EndIf
				Else
					lVldCalc := .F.
				EndIf

				If !lVldCalc .And. lVerificado
					GFEMessage(5,GFEA065016,STR0529,STR0530) //"É necessário que haja um Cálculo de Frete dos Documentos de Carga que possua o mesmo Tipo do Documento de Frete, e Transportador do Cálculo igual ao Emissor do Documento de Frete." , "Verifique o Tipo e Transportador do cálculo para criar/alterar o tipo do Doc. Frete."
					Return .F.
				EndIf
				GW4->(dbSkip())
			EndDo
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065IPR

@author Marcelo R. Ferrari
@since 21/10/14
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA065IPR( lInt, cOp, nOpc )
	Local oDlg      := Nil
	Local nAlt      := 350
	Local nLrg      := 520
	Local lRet 	    := .F.
	Local cValores  := ""
	Local aVlrs     := {}
	Local cPritDF   := GW3->GW3_PRITDF
	Local ccpdGFE   := GW3->GW3_CPDGFE
	Local cTes      := GW3->GW3_TES
	Local cConta    := GW3->GW3_CONTA
	Local cItemCta  := GW3->GW3_ITEMCT
	Local cCC       := GW3->GW3_CC
	Local lCpoTES   := GFEA065INP()
	Local lHabilita := .T.

	Default lInt    := .F.
	Default cOp     := "0"
	Default nOpc    := ""

	Private cCadastro := "Integração Protheus"

	//Se o documento já estiver integrado sai da rotina sem exibir a tela.
	If (GW3->GW3_SITFIS == "4") .OR. (GW3->GW3_SITREC == "4")
		If cOp == "1"
			MsgAlert("Documento está com a situação de Integrado. Dados não podem ser alterados")
			Return .T.
		EndIf
	EndIf

	If !lCpoTES  //Não Executa o Dialog Se os campos não estiverem criados.
		MsgAlert("Os campos de integração Protheus não encontrados na tabela")
		Return .T.
	EndIf

	If lInt .or. empty(cConta) .or. empty(cItemCta) .or. empty(cCC)
		//intgração Documento Fiscal ou Apropriação de despesa
		//Se estiver executando a integrando então verifica se os campos já contém valores.
		//No caso de não estiverem informados deverá apresentar a mensagem se deseja utilizar
		//informações do produto do respectivo parâmetro do GFE : MV_PRITDF
		If GFE065VCPO("2", .F., @aVlrs)
			If Len(aVlrs) > 0 .and. !empty(aVlrs[2])
				ccpdGFE  := aVlrs[1] // GW3->GW3_CPDGFE
				cPritDF  := aVlrs[2] // GW3->GW3_PRITDF
				cConta   := aVlrs[3] // GW3->GW3_CONTA
				cItemCta := aVlrs[4] // GW3->GW3_ITEMCT
				cCC      := aVlrs[5] // GW3->GW3_CC
				cTes     := aVlrs[6] // GW3->GW3_TES
			EndIf
		EndIf
	EndIf

	If Empty(cCpdGFE)
		cCpdGFE := Space(TamSX3("GW3_CPDGFE")[1])
	EndIf

	if nOpc == '2'
		lHabilita := .F.
	EndIf
	CursorWait()
	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
		oDlg:lEscClose := .F.

		oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,135,.F.,.F.)
		oPnlA:Align := CONTROL_ALIGN_ALLCLIENT

		@ 07,15  Say "Cod.Produto"		Of oPnlA COLOR CLR_BLACK Pixel
		@ 05,60  MSGET cPritDF  SIZE 100,11 Picture "@!" Of oPnlA F3 "SB1" Valid GFEA065VAL(@cConta, @cItemCta, @cCC, @cTes, cPritDF) /*ValidDic()*/ When lHabilita   Pixel hasbutton

		@ 22,15 Say "Cond.Pagto"			Of oPnlA COLOR CLR_BLACK Pixel
		@ 20,60 MSGET ccpdGFE   SIZE 100,11 Picture "@!" Of oPnlA F3 "SE4" Valid GFEA065PGTO(ccpdGFE) When lHabilita   Pixel hasbutton

		@ 37,15 Say "TES"					Of oPnlA COLOR CLR_BLACK Pixel
		@ 35,60 MSGET cTes   SIZE 100,11 Picture "@!" Of oPnlA F3 "SF4"  When .T.   Pixel hasbutton

		@ 52,15 Say "Conta Contabil"	Of oPnlA COLOR CLR_BLACK Pixel
		@ 50,60 MSGET cConta  SIZE 100,11 Picture "@!" Of oPnlA F3 "CT1"  When lHabilita   Pixel hasbutton

		@ 67,15 Say "Item Contabil"	Of oPnlA COLOR CLR_BLACK Pixel
		@ 65,60 MSGET cItemCta   SIZE 100,11 Picture "@!" Of oPnlA F3 "CTD" When lHabilita   Pixel hasbutton

		@ 82,15 Say "Centro de Custo"		Of oPnlA COLOR CLR_BLACK Pixel
		@ 80,60 MSGET cCC SIZE 100,11 Picture "@!" Of oPnlA F3 "CTT" When lHabilita   Pixel hasbutton

		CursorArrow()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||lRet := .T. ,ODlg:End()},{||lRet := .F.  ,ODlg:End(),},,) CENTERED

	//Se for integração e não informar o produto, não deixa integrar
	cValores := AllTrim(cPritDF) + AllTrim(cTes) + AllTrim(ccpdGFE)

	If lInt .AND. cValores == ""
		lRet := .F.
	EndIf

	If lRet
		lDlg := .T.
		RecLock( "GW3", .f. )
			GW3->GW3_PRITDF := cPritDF
			GW3->GW3_CPDGFE := ccpdGFE
			GW3->GW3_TES    := cTes
			GW3->GW3_CONTA  := cConta
			GW3->GW3_ITEMCT := cItemCta
			GW3->GW3_CC     := cCC
		GW3->(MsUnlock())
		lDlg := .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065VAL

@author Marcelo R. Ferrari
@since 23/10/14
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA065VAL( cConta, cItemCta, cCC, cTes, cPritDF )
	Local cPr := GW3->GW3_PRITDF

	If AllTrim(cPritDF) == AllTrim( cPr )
		Return .T.
	EndIf

	If !lDlg  //Quando o campo GW3_PRITDF é atualizado atravé do DIALOG então não deve passar pelo gatilho
		cConta   := GFE065GAT( "1", "2", cPritDF )
		cItemCta := GFE065GAT( "2", "2", cPritDF )
		cCC      := GFE065GAT( "3", "2", cPritDF )
		cTes     := GFE065GAT( "4", "2", cPritDF )
	EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065PGTO
Valida condição de pagamento informada em campo de tela.

@since 03/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA065PGTO(cCondPgto)
	Local lRet      := .T.
	Local cAliasSE4 := Nil

	If !Empty(AllTrim(cCondPgto))
		cAliasSE4 := GetNextAlias()
		BeginSql Alias cAliasSE4
		  SELECT 1
		    FROM %Table:SE4% SE4
		   WHERE SE4.E4_FILIAL = %xFilial:SE4%
		     AND SE4.E4_CODIGO = %Exp:cCondPgto%
		     AND SE4.E4_MSBLQL <> '1'
			 AND SE4.%NotDel%
		EndSql
		If (cAliasSE4)->(Eof())
			lRet := .F.
			GFEHelp("Condição de pagamento informada invalida ou bloqueada para uso. Verifique!")
		EndIf
		(cAliasSE4)->(dbCloseArea())
	EndIf
Return lRet

//Função do Gatilho do campo Produto Protheus (GW3_PRITDF)
Function GFE065GAT(cCampo, cTipo, cPritDF)
	Local cConta    := ""
	Local cItemcta  := ""
	Local cCC       := ""
	Local cTes      := ""
	Local cRet      := ""
	Local cPrtDf    := ""
	Local cAliasSB1 := Nil
	Default cTipo   := "1"
	Default cPritDF := ""

	If cTipo == "1"
		cPrtDf := M->GW3_PRITDF
	ElseIf cTipo == "2"
		cPrtDf := cPritDF
	EndIf

	cAliasSB1 := GetNextAlias()
	BeginSql Alias cAliasSB1
		SELECT SB1.B1_CONTA,
		SB1.B1_ITEMCC,
		SB1.B1_CC,
		SB1.B1_TE
		FROM %Table:SB1% SB1
		WHERE SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = %Exp:cPrtDf%
		AND SB1.%NotDel%
	EndSql

 	If (cAliasSB1)->(!Eof())
  		cConta  := (cAliasSB1)->B1_CONTA
		cItemCta := (cAliasSB1)->B1_ITEMCC
		cCC      := (cAliasSB1)->B1_CC
		cTes    := (cAliasSB1)->B1_TE
 	EndIf

 	(cAliasSB1)->(dbCloseArea())

	If cCampo = "1"
		cRet := cConta
	ElseIf cCampo = "2"
		cRet := cItemCta
	ElseIf cCampo == "3"
		cRet := cCC
	ElseIf cCampo =="4"
		//Verifica os parametros de buscar a TES automático
		If ctes != ""
			cRet := cTes
		else
			//a TES fica em branco pois irá gerar o valor na INTEGRAÇÃO.
			cTes := ""
		EndIf
	Else
		cRet := ""
	EndIf
Return cRet

//Verifica se os campos estão informados
Static Function GFE065VCPO(nOpc, lGrava, aVlrs, lPerg)
	Local lRet     := .F.
	Local cPritDF  := Iif(!Empty(GW3->GW3_PRITDF),GW3->GW3_PRITDF,SuperGetMV("MV_PRITDF", .F.,TamSX3("GW3_PRITDF")[1]))
	Local lIntProt := SuperGetMV("MV_ERPGFE", .F.)
	Local cCpdGFE  := Iif(!Empty(GW3->GW3_CPDGFE),GW3->GW3_CPDGFE,SuperGetMV("MV_CPDGFE", .F.,Space(TamSX3("GW3_CPDGFE")[1])))
	Local bBlock   := {|| .T.}

	Default aVlrs := {}
	Default lPerg := .T.

	// Só deve fazer a pergunta caso o parâmetro MV_TESGFE
	// for igual a 2 = Informado usuário
	If lPerg .And. (SuperGetMV("MV_TESGFE", .F., "1") == '2')
		If !IsBlind()
			bBlock := {|| MsgYesNo( "Deseja utilizar os dados do produto informados no parâmetro do GFE?", "Confirmação Dados do Produto" )}
		EndIf
	EndIf

	If ( lIntProt == "2" ) .And. ( (nOpc == "1") .Or. (nOpc == "2") )
		 If ( Empty(GW3->GW3_TES) .Or. Empty(GW3->GW3_CPDGFE) .Or. Empty(GW3->GW3_PRITDF) .Or.;
				Empty(GW3->GW3_CONTA) .Or. Empty(GW3->GW3_ITEMCT) .Or. Empty(GW3->GW3_CC) )

			If Eval(bBlock)

				If lGrava
					RecLock("GW3",.F.)
					GW3->GW3_CPDGFE  := cCpdGFE
					GW3->GW3_PRITDF  := cPritDF
					GW3->GW3_CONTA   := Iif(!Empty(GW3->GW3_CONTA)  ,GW3->GW3_CONTA  ,GFE065GAT( "1", "2", cPritDF ))
					GW3->GW3_ITEMCT  := Iif(!Empty(GW3->GW3_ITEMCT),GW3->GW3_ITEMCT,GFE065GAT( "2", "2", cPritDF ))
					GW3->GW3_CC      := Iif(!Empty(GW3->GW3_CC)     ,GW3->GW3_CC     ,GFE065GAT( "3", "2", cPritDF ))
					GW3->GW3_TES     := Iif(!Empty(GW3->GW3_TES)    ,GW3->GW3_TES    ,GFE065GAT( "4", "2", cPritDF ))
					GW3->(MsUnlock())
				Else
					aAdd( aVlrs, cCpdGFE )
					aAdd( aVlrs, cPritDF )
					aAdd( aVlrs, Iif(!Empty(GW3->GW3_CONTA)  ,GW3->GW3_CONTA  ,GFE065GAT( "1", "2", cPritDF )) )
					aAdd( aVlrs, Iif(!Empty(GW3->GW3_ITEMCT),GW3->GW3_ITEMCT,GFE065GAT( "2", "2", cPritDF )) )
					aAdd( aVlrs, Iif(!Empty(GW3->GW3_CC)     ,GW3->GW3_CC     ,GFE065GAT( "3", "2", cPritDF )) )
					aAdd( aVlrs, Iif(!Empty(GW3->GW3_TES)    ,GW3->GW3_TES    ,GFE065GAT( "4", "2", cPritDF )) )
				EndIf
				lRet := .T.
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE065TES()

@author Marcelo R. Ferrari
@since 23/10/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE065TES(cTes, cTpImp, cTrbImp, cCrdIcm, cCrdPc, aForLoj, cFGer, cTPOnus, cItemTes, cCFOP, aMsgTES, cTESDC)
	Local cOper := ""
	Local aRet  := {}
	Local nX	:= 0
	Local cTESGFE := SuperGetMV("MV_TESGFE",.T.,"1")

	Default aMsgTES := {}
	Default cTesDC	:= ""
	Default aCFOPItensDC := {}

	If FindFunction("GFEX021BOPER")
		aAdd(aMsgTES,STR0107) //--"Inicializando tipo de operação"
		aRet := GFEX021BOPER(AllTrim(cCFOP), cTpImp, cTrbImp, cCrdIcm, cCrdPc, cFGer, cTPOnus, , cTesDC)
	Else
		aAdd(aMsgTES,STR0106) //--"Inicializado com tipo de operação default 01"
		aRet := {.F.,"01"}
	EndIf
	If aRet[1] == .T.
		cOper	:= aRet[2]
		aAdd(aMsgTES,STR0108 + cOper) //--"Retornado tipo de operação "
	Else
		If aRet[2] == "01" .Or. aRet[2] == "02"
			Do Case
				Case cTpImp == "1" //"1=ICMS"
					aAdd(aMsgTES,STR0109) //--"Selecionando tipo de operação para ICMS"
					Do Case
						Case cTrbImp == "2" .And. cCrdPc == "1" //"2=ISENTO" .And. "1=Sim"
							cOper := "T2"
							aAdd(aMsgTES,STR0112 + " - " + cOper ) //--"Isento/Não-tributado, crédito PIS/COFINS = Sim"

						Case cTrbImp == "2" .And. cCrdPc == "2" //"2=ISENTO" .And. "2=Não"
							cOper := "T6"
							aAdd(aMsgTES,STR0113 + " - " + cOper ) //--"Isento/Não-tributado, crédito PIS/COFINS = Não"

						Case cTrbImp == "3" .And. cCrdIcm == "1"//"3=SUBS. TRIB. Credito ICMS = Sim"
							cOper := "T3"
							aAdd(aMsgTES,STR0114 + " - " + cOper ) //--"Subst.Tributária, crédito ICMS = Sim"

						Case cTrbImp == "3" .And. cCrdIcm == "2"//"3=SUBS. TRIB. Credito ICMS = Não"
							cOper := "T5"
							aAdd(aMsgTES,STR0115 + " - " + cOper ) //--"Subst.Tributária, crédito ICMS = N~so"

						Case cTrbImp == "1" .And. cCrdPc == "2"  //"1=TRIBUTADO" .And. "2=NAO"
							cOper := "T7"
							aAdd(aMsgTES,STR0116 + " - " + cOper ) //--"Tributado, crédito PIS/COFINS = Não"

						Case cTrbImp == "1" .And. cCrdIcm == "2"  //"1=TRIBUTADO" .And. "2=NAO"
							cOper := "T8"
							aAdd(aMsgTES,STR0117 + " - " + cOper ) //--"Tributado, crédito ICMS = Não"

						Case cTrbImp == "6" //"6=OUTROS"
							cOper := "T8"
							aAdd(aMsgTES,STR0118 + " - " + cOper ) //--"Outros"
					EndCase

				Case cTpImp == "2" //"2=ISS"
					cOper := "T4"
					aAdd(aMsgTES,STR0110 + " - " + cOper) //--"Selecionando tipo de operação para ISS"

				Case cTpImp == "3" //"3=PEDÁGIO"
					cOper := "TA"
					aAdd(aMsgTES,STR0111 + " - " + cOper) //--"Selecionando tipo de operação para Pedágio"

			EndCase

			If Empty(cOper)
				cOper := "T1"
				aAdd(aMsgTES,STR0119 + " - " + cOper) //--"Sem regra exclusiva, utilizado padrão"
			EndIf
		EndIf
	EndIf
	cTes    := MaTESInt(1,cOper,aForLoj[1],aForLoj[2],"F",cItemTes)
	aAdd(aMsgTES,STR0120 + " - " + cTes) //--"Interpretada TES inteligente"	
	cOperPE := cOper
	
	If cTESGFE == '3'
		For nX := 1 To Len(aCFOPItensDC)
			If AllTrim(aRet[4]) == Alltrim(aCFOPItensDC[nX][3])
				aAdd(aMsgTES, "Documento de Carga: "+aCFOPItensDC[nX][1] ) 
				aAdd(aMsgTES, "Item de Carga: "+aCFOPItensDC[nX][2] ) 
				aAdd(aMsgTES, "CFOP do Item de Carga: "+cCFOP + CRLF) 
			EndIf
		Next nX
	EndIF
Return cTes

Function GFEA065NPR( cTipo )
	Local cRet := SuperGetMV("MV_PRITDF",.F.,TamSX3("B1_COD")[1])
	Local cPritDFa := ""

	If cTipo = 1
		cPritDFa := M->GW3_PRITDF
	Else
		cPritDFa := GW3->GW3_PRITDF
	EndIf

	If !Empty(cPritDFa)
		cRet := cPritDFa
	EndIf
Return cRet

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065VFIX
Valida se o compatibilizador de base RUP_GFE foi executado.
A execução do compatibilizador garante que os cálculos e documentos de frete estão devidamente associados.

@sample
GFEA065VFIX()

@author Amanda Rosa Vieira
@since 13/07/2016
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function GFEA065VFIX()
	Private s_DPSERV   	:= SuperGetMV("MV_DPSERV", .F., "1")

	cFilGW0 := Space(Len(xFilial("GW0")))
	cTabela := PadR("GWF", TamSX3("GW0_TABELA")[1])
	cFun    := PadR("MV_DPSERV", TamSX3("GW0_CHAVE")[1])

	GW0->( dbSetOrder(1) )
	If !GW0->(dbSeek(cFilGW0+cTabela+cFun))
		If s_DPSERV == "1"
			GFEConout("INFO","Necessário Execução de acerto de base GFEUPDCalc() ")
		EndIf
	EndIf
Return .T.

// Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
Function GFE065PreT(oModelGW4)
	Local cTpDc   := FwFldGet("GW4_TPDC")
	Local cEmiDc  := FwFldGet("GW4_EMISDC")
	Local cSerDc  := FwFldGet("GW4_SERDC")
	Local cNrDc   := FwFldGet("GW4_NRDC")
	Local oView   := FWViewActive()
	Local nLine   := oModelGW4:GetLine()
	Local aRet    := {}

	If __lCpoSDoc == Nil
		__lCpoSDoc := Len(TamSX3("GW4_SDOCDC")) > 0
	EndIf

	If TamSx3("GW4_SERDC")[1] == 14
		aRet := GFE517TLDC( cNrDc , cTpDc , cEmiDc , cSerDc )

		If Len(aRet) > 0
			If !oModelGW4:IsDeleted()
				oModelGW4:GoLine( nLine )

				oModelGW4:LoadValue('GW4_TPDC'  , aRet[6])
				oModelGW4:LoadValue('GW4_EMISDC', aRet[2])
				oModelGW4:LoadValue('GW4_NMEMIS', POSICIONE("GU3", 1, xFilial("GU3") + aRet[2], "GU3_NMEMIT"))
				oModelGW4:LoadValue('GW4_SERDC' , aRet[4])
				oModelGW4:LoadValue('GW4_NRDC'  , aRet[5])
				If __lCpoSDoc
					oModelGW4:LoadValue('GW4_SDOCDC', Transform(aRet[4], "!!!") )
				EndIf
			EndIf

			If oView != Nil .And. oView:lActivate
				oView:Refresh()
			EndIf
		EndIf
	EndIf
Return Nil


//-----------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065DMA
Dasatualização do documento de frete ao MLA
@author felipe.m
@since 11/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------
Function GFEA065DMA()
Local lRet := .T.
Local nRecnoGW3 := GW3->(Recno())

	If !(GW3->GW3_SITMLA $ "3|4|7") // 3=Rejeitado ou 4=Atualizado ou 7-Enviado/aguardando.
		Help(,,'HELP',,"Documento de Frete ainda não foi integrado ao MLA.",1,0)
		lRet := .F.
	EndIf

	If lRet .And. MsgNoYes("Deseja desatualizar o Documento de Frete no MLA?","Aviso")
		GW3->(dbGoto(nRecnoGW3))
		RecLock("GW3",.F.)
			GW3->GW3_SITMLA := "5"
		GW3->(MsUnlock())

		MsgInfo("Documento de Frete enviado para desatualização no MLA.")
	EndIf
Return lRet


/** {Protheus.doc} GFEA065INP
Valida se campos disponibilizados no IRMVAR301 estão criados
*/
Function GFEA065INP()
	Local lRet       := .F.
	Local aArea      := GetArea()
	Local lGW3_ACINT := .F.
	Local lGW3_TES   := .F.

	lGW3_ACINT	:= GFXCP12118("GW3_ACINT")
	lGW3_TES	:= GFXCP12118("GW3_TES")
	// ColumnPos( - Eliminar esta função após base estabilizada com atualizações
	/* PCREQ-99 - Globo Aves - Campos e Parâmetros não atualizados
	--CAMPOS--
	GW3_CPDGFE
	GW3_TES
	GW3_CONTA
	GW3_ITEMCT
	GW3_CC

	--PARAMETROS--
	MV_TESGFE	"TES Doc. Frete" 				1=Atribuído.Sistema;2=Informado.Usuário
	MV_SIGFE	"Solicita Info Integração"	1=Sim;2=Não
	*/
	If lGW3_ACINT .and. lGW3_TES
		lRet := .T.
	EndIf
	RestArea(aArea)
Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GFE065DTVF
Retorna a data de vencimento da fatura à qual o documento de frete está vinculado.

@author  Guilherme A. Metzger
@since   07/11/2016
@version 1.0
@return  dDataVenc   Data de vencimento da fatura a qual o documento está vinculado
@obs     Utilizado no inicializador padrão do campo GW3_DTVCFT
/*/
//-----------------------------------------------------------------------------
Function GFE065DTVF()
	Local dDataVenc := CtoD("  /  /    ")

	GW6->(DbSetOrder(1)) // GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+GW6_DTEMIS
	If !Inclui .And. GW6->(DbSeek(GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT))
		dDataVenc := GW6->GW6_DTVENC
	EndIf
Return dDataVenc

/*/	{Protheus.doc} SitFinGW6

	Init Browse - Init Tabela

	@sample	SitFinGW6()
	@param		Nenhum
	@return	GW3_SITFIN (Descrição da Situação).
	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function SitFinGW6()
	Local aOldArea := GetArea()
	Local cPos     := ""

	cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_SITFIN")
	RestArea(aOldArea)
Return NGRETSX3BOX("GW6_SITFIN",cPos)


/*/	{Protheus.doc} SitFinGW6c

	Init Padrão - Init Campo

	@sample	SitFinGW6c()
	@param		Nenhum
	@return	GW3_SITFIN.
	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function SitFinGW6c()
	local oModel   := FwModelActive()
	Local aOldArea := GetArea()
	Local cPos     := ""

	If oModel == Nil
		Return ""
	Else
		Inclui := ( oModel:GetOperation() == 3 )
	EndIf
	If !Inclui
		cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_SITFIN")
	EndIf
	If cPos == ""
		cPos := "1"
	EndIf
	RestArea(aOldArea)
Return cPos

/*/	{Protheus.doc} DtFinGW6

	Init Browse - Init Tabela

	@sample	DtFinGW6()
	@param		Nenhum
	@return	GW3_DTFIN (Descrição da Situação).

	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function DtFinGW6()
	Local aOldArea := GetArea()
	Local cPos     := ""

	cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_DTFIN")
	RestArea(aOldArea)
Return cPos


/*/	{Protheus.doc} DtFinGW6c

	Init Padrão - Init Campo

	@sample	DtFinGW6c()
	@param		Nenhum
	@return	GW3_DTFIN.
	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function DtFinGW6c()
	local oModel   := FwModelActive()
	Local aOldArea := GetArea()
	Local cPos     := ""

	If oModel == Nil
		Return ""
	Else
		Inclui := ( oModel:GetOperation() == 3 )
	EndIf
	If !Inclui
		cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_DTFIN")
	EndIf
	RestArea(aOldArea)
Return cPos

/*/	{Protheus.doc} MotFinGW6

	Init Browse - Init Tabela

	@sample	MotFinGW6()
	@param	Nenhum
	@return	GW3_MOTFIN (Descrição da Situação).
	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function MotFinGW6()
	Local cPos     := ""
	Local aOldArea := GetArea()

	cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_MOTFIN")
	RestArea(aOldArea)
Return cPos

/*/	{Protheus.doc} DtFinGW6c

	Init Padrão - Init Campo

	@sample	DtFinGW6c()
	@param		Nenhum
	@return	GW3_DTFIN.
	@author	Carlos Augusto Pereira
	@since		23/09/2016
	@version	12
/*/
Function MotFinGW6c()
	local oModel   := FwModelActive()
	Local aOldArea := GetArea()
	Local cPos     := ""

	If oModel == Nil
		Return ""
	Else
		Inclui := ( oModel:GetOperation() == 3 )
	EndIf
	If !Inclui
		cPos := Posicione("GW6",1,GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA),"GW6_MOTFIN")
	EndIf
	RestArea(aOldArea)
Return cPos


/*/	{Protheus.doc} GFEADOCPF

	MSDIALOG para pesquisar pré-faturas

	@sample	GFEADOCPF()

	@param		Nenhum

	@return

	@author	Carlos Augusto Pereira
	@since		05/10/2016
	@version	12
/*/
Static Function GFEADOCPF()
	Local oDlg   := Nil
	Local lRet   := .F.
	Static cFil    := ""
	Static nPreFat := 0

	If Empty(cFil)
		cFil    := space(Len(GWJ->GWJ_FILIAL))
		nPreFat := space(Len(GWJ->GWJ_NRPF))
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Pesquisar Documentos de carga" From 4,0 To 100,250 OF oMainWnd PIXEL
	@  4, 020  SAY "Filial:" SIZE 70,7 PIXEL OF oDlg
	@ 19, 005  SAY "Nr. Pré-Fatura:" SIZE 70,7 PIXEL OF oDlg

	@  3, 040  MSGET cFil When .T. SIZE 45,7 PIXEL OF oDlg hasbutton F3 "SM0"
	@ 18, 040  MSGET nPreFat  When .T. SIZE 45,7 PIXEL OF oDlg hasbutton F3 "GWJPRE"

	oButtonOK   := tButton():New(35,002,'OK',oDlg,{||IIf (!Empty(cFil) .And. !Empty(nPreFat), (GFEA065PF(cFil,nPreFat),	oDlg:End()), ;
		Help(,,'HELP',, "Favor preencher os campos de Filial e Pré-Fatura.", 1, 0))  },25,10,,,,.T.)
	oButtonCanc := tButton():New(35,030,"Cancelar",oDlg,{||lRet:={},oDlg:End()},25,10,,,,.T.)
	ACTIVATE MSDIALOG oDlg
Return

/*/	{Protheus.doc} GFEA065PF

	Pesquisa de documentos de carga relacionados à fatura

	@sample	GFEA065PF()

	@param		Nenhum

	@return

	@author	Carlos Augusto Pereira
	@since		05/10/2016
	@version	12
/*/
Static Function GFEA065PF(cFilp, cNrpf)
	Local oView       := FWViewActive()
	Local oModel      := oView:GetModel()
	Local oModelGW4   := oModel:GetModel("GFEA065_GW4")
	Local aAreaGWH    := GWH->(GetArea())
	Local aAreaGWF    := GWF->(GetArea())
	Local nLineaUX    := 0
	Local nTotLen     := 0
	Local nDC         := 0
	Local aErroGW4    := {}
	Local aArea       := GetArea()
	Local cGW3_TPDF   := ""
	Local cGW3_EMISDF := ""
	Local nCalc       := 0

	cGW3_TPDF 	:= FwFldGet("GW3_TPDF")
	cGW3_EMISDF	:= FwFldGet("GW3_EMISDF")

	If __lCpoSDoc == Nil
		__lCpoSDoc := Len(TamSX3("GW4_SDOCDC")) > 0
	EndIf

	lPrimeiro  := .F.

	GWJ->(dbSetOrder(1))
	If !GWJ->(dbSeek(cFilp+cNrpf))
		Help(,,'HELP',, "Não foi encontrada pré-fatura com o número informado.", 1, 0)
		RestArea(aArea)
		Return .F.
	EndIf
	RestArea(aArea)

	nLineaUX := oModelGW4:GetLine()

	GWF->(dbSetOrder(3))
	GWF->(dbSeek(cFilp+cNrpf) )
	Do While GWF->(!Eof()) .And. cFilp+cNrpf == GWF->GWF_FILPRE+GWF->GWF_NRPREF
		If GWF->GWF_TPCALC == cGW3_TPDF .And. GWF->GWF_TRANSP == cGW3_EMISDF
			nCalc++
			GWH->(dbSetOrder(1))
			GWH->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
			Do While GWH->(!Eof()) .And. GWF->GWF_FILIAL+GWF->GWF_NRCALC == GWH->GWH_FILIAL+GWH->GWH_NRCALC
				GW1->(dbSetOrder(1))
				If GW1->(dbSeek(xFilial("GW1") + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC))

					If oModelGW4:SeekLine({{"GW4_TPDC", GW1->GW1_CDTPDC}, {"GW4_EMISDC", GW1->GW1_EMISDC}, ;
							{"GW4_SERDC", GW1->GW1_SERDC}, {"GW4_NRDC", GW1->GW1_NRDC}})

						GWH->(dbSkip())
						Loop
					EndIf

					nTotLen := oModelGW4:Length() + 1
					If !Empty(  oModelGW4:GetValue('GW4_TPDC'  ,1)+;
							oModelGW4:GetValue('GW4_EMISDC',1)+;
							oModelGW4:GetValue('GW4_NMEMIS',1)+;
							oModelGW4:GetValue('GW4_SERDC' ,1)+;
							oModelGW4:GetValue('GW4_NRDC'  ,1))
						If oModelGW4:AddLine() != nTotLen
							Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0)
							Return .F.
						EndIf
					EndIf
					oModelGW4:LoadValue('GW4_TPDC'  , GW1->GW1_CDTPDC)
					oModelGW4:LoadValue('GW4_EMISDC', GW1->GW1_EMISDC)
					oModelGW4:LoadValue('GW4_NMEMIS', POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_EMISDC, "GU3_NMEMIT"))
					oModelGW4:LoadValue('GW4_SERDC' , GW1->GW1_SERDC )
					oModelGW4:LoadValue('GW4_NRDC'  , GW1->GW1_NRDC  )
					If __lCpoSDoc
						oModelGW4:LoadValue('GW4_SDOCDC', GW1->GW1_SDOC)
					EndIf
					If !oModelGW4:VldLineData()
						aErroGW4 := oModel:GetErrorMessage()
						oModelGW4:DeleteLine()
					EndIf
					nDc++
				EndIf
				GWH->(dbSkip())
			EndDo
		EndIf
		GWF->(dbSkip())
	EndDo

	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	oModelGW4:GoLine(nLineaUX)
	oView:Refresh()

	If nCalc == 0
		Help(,,'HELP',, "Não foram encontrados Cálculos do tipo " + GFEFldInfo("GW3_TPDF", FwFldGet("GW3_TPDF"), 2) + " para o emissor do conhecimento relacionados à pré-fatura.", 1, 0)
	ElseIf nDC == 0
		Help(,,'HELP',, "Não foram encontrados outros Documentos de Carga para vincular ao Documento de Frete.", 1, 0)
	EndIf
Return

Static Function CORVALID(lCor)
	If lCor
		Return "BR_VERDE"
	Else
		Return "BR_VERMELHO"
	EndIf
Return

Static Function LEGVALID()
	Local aLegenda := {}
	Local cTitulo  := ""

	cTitulo  := "Status do registro"
	Aadd(aLegenda,{"BR_VERMELHO", "Inválido"})
	Aadd(aLegenda,{"BR_VERDE" , "Válido"})
	BrwLegenda(cTitulo, "Legenda", aLegenda)
Return .T.

/*/	{Protheus.doc} GFEA065CTA
	Indica se a integração de (C)usto de frete com o (T)MS Protheus está (A)tiva.
	Retornará verdadeiro se integrar com TMS, ERP de integração for Protheus e se a integração de custo de frete for automática ou sob demanda.
	Usado para atribuição do campo GW3_SITCUS (no dicionário) na inclusão de documentos de frete.

	@sample	GFEA065CTA()
	@param		Nenhum
	@return

	@author	Wander Horongoso
	@since		27/01/2017
	@version	12
/*/

Function GFEA065CTA()
Return SuperGetMv("MV_INTTMS", .F., .F.) == .T. .And. SuperGetMv("MV_GFEI21", .F.,"3") $ "1;2"

/*/	{Protheus.doc} GFEA065CTP
	Indica se a integração do (C)usto de frete com o (T)MS Protheus será (P)rocessada.
	*Utiliza dados do registro corrente na GW3.
	Retornará verdadeiro se integrar o custo de frete com TMS.

	@sample	GFEA065CTP()
	@return	Indicativo lógico de sucesso da execução;
		Valor gravado no campo Motivo da rejeição da integração do custo de frete.
	Valor gravado no campo Situação do custo de frete;
		Valor gravado no campo Data de integração do custo de frete;
		Valor gravado no campo Usuário de integração do custo de frete;

	@param		Ação ((IA) Integração Automática;
		(ID) Integração sob Demanda;
		(IL) Integração por lote;
		(P)  Pendente (quando mudança do DF e sob demanda))
	(E)  Exclusão da integração (quando exclusão do DF, ou mudança do DF e automático);
		(EI) Exclusão na Inclusão (quando houver erro na inclusão, eliminar os registros).
	lExibeMsg: indica se será exibido em tela mensagem com o resultado da integração.
	@author	Wander Horongoso
	@since		27/01/2017
	@version	12
/*/

Function GFEA065CTP(cAcao, lExibeMsg)
	//Local aCotacao   := {1,RecMoeda(Date(),2),RecMoeda(Date(),3),RecMoeda(Date(),4),RecMoeda(Date(),5)}
	Local aCmpVal    := {{"%GWM_VLFRET%","%GWM_VLICMS%","%GWM_VLPIS%","%GWM_VLCOFI%"},;
		{"%GWM_VLFRE1%","%GWM_VLICM1%","%GWM_VLPIS1%","%GWM_VLCOF1%"},;
		{"%GWM_VLFRE2%","%GWM_VLICM2%","%GWM_VLPIS2%","%GWM_VLCOF2%"},;
		{"%GWM_VLFRE3%","%GWM_VLICM3%","%GWM_VLPIS3%","%GWM_VLCOF3%"}}
	Local nCriRat    := Val(SuperGetMV('MV_CRIRAT',,'1'))
	Local aRet       :=  {.F.,'','',NIL,'',''}
	Local lAtualiza  := .F.
	Local lExec      := .F.
	Local aAreaGW3   := GW3->(GetArea())
	Local oModel     := Nil
	Local lMsgAviso  := .F. //quando for apenas um aviso, não irá gravar na GW3_MOTCUS
	Local nValor     := 0
	Local aForn      := {}

	Default lExibeMsg := .F.

	If !SuperGetMv("MV_INTTMS", .F., .F.)
		aRet[2] := "Integração de valores de custo de transporte disponível apenas para ambientes com SIGATMS implantado."
	ElseIf SuperGetMV("MV_GFEI21", .F., "3") == "3"
		aRet[2] := "Parâmetro Custos de Transporte configurado para não integrar custo de transporte com SIGATMS."
	ElseIf !(GW3->GW3_SIT $ "34") .And. !(SubStr(cAcao,1,1) $ "P;E") //Para pendência não haverá integração, apenas alteração do DF. Para exclusão pode estar não aprovado
		aRet[2] := "Para integração de valores de custo de transporte com SIGATMS o documento de frete deve estar aprovado."
	Else
		Do Case
		Case Substr(cAcao,1,1) == "E" //Pode ser E ou EI
			GWC->(dbSetOrder(1))
			GWC->(dbSeek(GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+dToS(GW3_DTEMIS))))
			Do While GWC->(!Eof()) .And. GWC->(GWC_FILIAL+GWC_CDESP+GWC_EMISDF+GWC_SERDF+GWC_NRDF+DTOS(GWC_DTEMIS)) ==;
					GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+dToS(GW3_DTEMIS))

				lExec := .T.

				SDG->(dbSetOrder(1))
				SDG->(dbSeek(GWC->(GWC_FILIAL+GWC_DOC+GWC_CODDES+GWC_ITEM)))
				Do While SDG->(!Eof()) .And. GWC->(GWC_FILIAL+GWC_DOC+GWC_CODDES+GWC_ITEM) == SDG->(DG_FILIAL+DG_DOC+DG_CODDES+DG_ITEM)
					TMSA070Bx("2", SDG->DG_NUMSEQ)

					RecLock("SDG",.F.)
					SDG->(dbDelete())
					SDG->(MsUnlock())
					SDG->(dbSkip())
				EndDo

				RecLock("GWC",.F.)
				GWC->(dbDelete())
				GWC->(MsUnlock())
				GWC->(dbSkip())
			EndDo

			//Para EI não alterar os dados da integração com custo, pois isso será feito após a chamada desta rotina de exclusão
			If cAcao == "E"
				aRet[1] := .T.
				aRet[3] := "1"
				aRet[4] := SToD("")

				lMsgAviso := .T.
				If lExec
					aRet[2] := "Exclusão dos valores de custo de transporte com SIGATMS efetuada com sucesso."
				Else
					aRet[2] := "Não foram encontrados valores de custo de transporte com SIGATMS para exclusão."
				EndIf
			EndIf

		Case cAcao == "P"
			lMsgAviso := .T.
			aRet[1] := .T.
			aRet[2] := "Situação de integração de valores de custo de frete com SIGATMS alterado para Pendente Atualização."
			aRet[3] := "4"

		Case Substr(cAcao,1,1) == "I" //Pode ser IA, ID ou IL.
			lAtualiza := .F.
			If GW3->GW3_SITCUS == "2"
				aRet[2] := "Integração de valores de custo de transporte com SIGATMS já efetuada para este documento de frete."
			Else
				Do Case
				Case cAcao == "ID" //Sob (D)emanda - Menu integração Custo do GFEA065
					If SuperGetMv("MV_GFEI21", .F., "3") $ "1,2" //1=Sob demanda.
						lAtualiza := .T.
					EndIf
				Case cAcao == "IA" //(A)utomático - Nas aprovações do GFEA065 e GFEA066
					If SuperGetMv("MV_GFEI21", .F., "3") == "2" //2=Automático
						lAtualiza := .T.
					Else
						aRet[2] := "Custo de transporte do documento de frete não pendente para integração automática com SIGATMS."
					EndIf
				Case cAcao = "IL" //Por (L)ote GFEA067 / GFEX100
					lAtualiza := .T.
				EndCase
			EndIf

			If lAtualiza
				If AllTrim(GW3->GW3_DESCUS) == ""
					aRet[1] := .T.
					aRet[2] := "Código da Despesa de Frete não informado no documento de frete."
					aRet[3] := "3"
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
							SELECT SUM(GWM.%Exp:aCmpVal[nCriRat][1]%) VLFRET,
									SUM(GWM.%Exp:aCmpVal[nCriRat][2]%) VLICMS,
									SUM(GWM.%Exp:aCmpVal[nCriRat][3]%) VLPIS,
									SUM(GWM.%Exp:aCmpVal[nCriRat][4]%) VLCOFINS,
									GWE.GWE_FILDT,
									GWE.GWE_NRDT,
									GWE.GWE_SERDT
							FROM %Table:GWM% GWM
							INNER JOIN %Table:GWE% GWE
							ON GWE.GWE_FILIAL = GWM.GWM_FILIAL
							AND GWE.GWE_CDTPDC = GWM.GWM_CDTPDC
							AND GWE.GWE_EMISDC = GWM.GWM_EMISDC
							AND GWE.GWE_SERDC = GWM.GWM_SERDC
							AND GWE.GWE_NRDC = GWM.GWM_NRDC
							AND GWE.%NotDel%
							WHERE GWM.GWM_FILIAL = %Exp:GW3->GW3_FILIAL%
							AND GWM.GWM_TPDOC = '2' //Fixo Doc Frete
							AND GWM.GWM_CDESP = %Exp:GW3->GW3_CDESP%
							AND GWM.GWM_CDTRP = %Exp:GW3->GW3_EMISDF%
							AND GWM.GWM_SERDOC = %Exp:GW3->GW3_SERDF%
							AND GWM.GWM_NRDOC = %Exp:GW3->GW3_NRDF%
							AND GWM.GWM_DTEMIS = %Exp:DToS(GW3->GW3_DTEMIS)%
							AND GWM.%NotDel%
							GROUP BY GWE.GWE_FILDT,
										GWE.GWE_NRDT,
										GWE.GWE_SERDT
					EndSql
					If (cAliasQry)->(EoF())
						aRet[1] := .T.
						aRet[2] := "Não foram encontrados rateio contábil do documento de frete ou documentos de frete do TMS vinculados aos documentos de carga."
						aRet[3] := "3"
					Else
						nItem := 0

						//Se tiver pendência, antes elimina os registros já existentes
						If GW3->GW3_SITCUS == "4"
							GFEA065CTP("EI")
						EndIf

						DT7->(dbSetOrder(1))
						DT7->(dbSeek(xFilial('DT7')+GW3->GW3_DESCUS))
						aForn := GFEA055GFL(GW3->GW3_EMISDF)

						Do While (cAliasQry)->(!Eof())
							nItem += 1
							nValor := (cAliasQry)->VLFRET - IIF(GW3->GW3_CRDICM == "1", (cAliasQry)->VLICMS, 0) - IIF(GW3->GW3_CRDPC == "1", (cAliasQry)->VLPIS + (cAliasQry)->VLCOFINS, 0)

							oModel := FWLoadModel("TMSA070")
							oModel:SetOperation( MODEL_OPERATION_INSERT )
							oModel:Activate()
							oModel:GetModel("MdFieldSDG"):SetValue("DG_DOC",    NextNumero("SDG",1,"DG_DOC",.T.))
							oModel:GetModel("MdGridSDG"):SetValue("DG_ITEM",    StrZero(nItem, Len(SDG->DG_ITEM)))
							oModel:GetModel("MdGridSDG"):SetValue("DG_CODDES",  GW3->GW3_DESCUS)
							oModel:GetModel("MdGridSDG"):SetValue("DG_FILFRT",  (cAliasQry)->GWE_FILDT)
							oModel:GetModel("MdGridSDG"):SetValue("DG_DOCFRT",  (cAliasQry)->GWE_NRDT)
							oModel:GetModel("MdGridSDG"):SetValue("DG_SERFRT",  (cAliasQry)->GWE_SERDT)
							oModel:GetModel("MdGridSDG"):SetValue("DG_CODFOR",  aForn[1])
							oModel:GetModel("MdGridSDG"):SetValue("DG_LOJFOR",  aForn[2])

							oModel:GetModel("MdGridSDG"):SetValue("DG_TOTAL",   nValor)
							oModel:GetModel("MdGridSDG"):SetValue("DG_CUSTO1",  nValor)
							oModel:GetModel("MdGridSDG"):SetValue("DG_NUMPARC",  1)
							oModel:GetModel("MdGridSDG"):SetValue("DG_ORIGEM",  "GW3")
							oModel:GetModel("MdGridSDG"):SetValue("DG_HISTOR",  Substr(GW3->GW3_NRDF + " - " + GW3->GW3_SERDF + " - " + DToC(GW3->GW3_DTEMIS), 1, 40))
							oModel:GetModel("MdGridSDG"):SetValue("DG_VALCOB",  nValor)
							oModel:GetModel("MdGridSDG"):SetValue("DG_CLVL",    DT7->DT7_CLVL)
							oModel:GetModel("MdGridSDG"):SetValue("DG_ITEMCTA", DT7->DT7_ITEMCT)
							oModel:GetModel("MdGridSDG"):SetValue("DG_CONTA",   DT7->DT7_CONTA)
							oModel:GetModel("MdGridSDG"):SetValue("DG_CC",      DT7->DT7_CC)

							If oModel:VldData()
								oModel:CommitData()

								lMsgAviso := .T.
								aRet[1] := .T.
								aRet[2] := "Integração dos valores de custo de transporte com SIGATMS efetuada com sucesso."
								aRet[3] := "2"
								aRet[4] := dDatabase
								aRet[5] := cUserName
							Else
								//Caso ocorra erro, eliminar os possíveis registros que foram criados.
								GFEA065CTP("EI")

								aRet[1] := .T.
								aRet[2] := oModel:GetErrorMessage(.F.)[6]
								aRet[3] := "3"
								aRet[4] := dDatabase
								aRet[5] := cUserName

								Exit
							EndIf

							RecLock("GWC",.T.)
							GWC->GWC_FILIAL := GW3->GW3_FILIAL
							GWC->GWC_CDESP  := GW3->GW3_CDESP
							GWC->GWC_EMISDF := GW3->GW3_EMISDF
							GWC->GWC_SERDF  := GW3->GW3_SERDF
							GWC->GWC_NRDF   := GW3->GW3_NRDF
							GWC->GWC_DTEMIS := GW3->GW3_DTEMIS
							GWC->GWC_DOC    := oModel:GetModel("MdFieldSDG"):GetValue("DG_DOC")
							GWC->GWC_CODDES := oModel:GetModel("MdGridSDG"):GetValue("DG_CODDES")
							GWC->GWC_ITEM   := oModel:GetModel("MdGridSDG"):GetValue("DG_ITEM")
							GWC->(MsUnlock())

							oModel:Deactivate()

							(cAliasQry)->(dbSkip())
						EndDo
					EndIf
					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf
		EndCase
	EndIf

	If aRet[1]
		RecLock("GW3", .F.)
		GW3->GW3_SITCUS := aRet[3]
		//Quando alterar para pendente, deve manter as informações.
		If !(cAcao == "P")
			GW3->GW3_DTCUS  := aRet[4]
			GW3->GW3_USUCUS := aRet[5]

			If lMsgAviso
				GW3->GW3_MOTCUS := ""
			Else
				GW3->GW3_MOTCUS := aRet[2]
			EndIf
		EndIf
		GW3->(MsUnlock())
	EndIf

	If lExibeMsg
		If lMsgAviso
			MsgInfo(aRet[2])
		Else
			Help( ,, 'HELP',, aRet[2], 1, 0)
		EndIf
	EndIf
	RestArea(aAreaGW3)
Return aRet

/*/	{Protheus.doc} GFEA065GTP
	Gatilho para alimentar o campo GW3_DESCUS a partir do tipo de documento de frete.

	@sample	GFEA065GTP()
	@param
	@return	Código da despesa de frete
	@author	Wander Horongoso
	@since		27/01/2017
	@version	12
/*/

Function GFEA065GTP(cTpDF)
Return IIf (GFEA065CTA(), SuperGetMv("MV_DESGFE" + AllTrim(cTpDF), .F., ""), "")

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica
@author Hercilio Henning Neto
@since 18/07/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message
@type function
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
	Local  aResult := {}

	aResult := GFEI065(cXml,nType,cTypeMsg)
Return aResult


/*/	{Protheus.doc} GFEA065PCD
	Retorna o percentual de tributação do PIS/COFINS	conforme cadastro do transportador

	@sample	GFEA065PCD()
	@param    cTpImp - PIS ou COFINS
	@return	Percentual de imposto PIS/COFINS
	@author	Pedro E. Scandolara
	@since		27/10/2017
	@version	1
/*/
Function GFEA065PCD(cTpImp)
	Local cRet := ""

	GU3->(dbSetOrder(1) )
	GU3->(dBSeek(xFilial("GU3") + FwFldGet('GW3_EMISDF')))

	If cTpImp == "PIS"
		If GU3->GU3_TPTRIB == "2" .AND. SuperGetMv("MV_PISDIF",.F.,0) <> 0
			cRet := SuperGetMv("MV_PISDIF",.F.,0)
		Else
			cRet := SuperGetMv("MV_PCPIS",.F.,1.65)
		EndIf
	Else //COFINS
		If GU3->GU3_TPTRIB == "2" .AND. SuperGetMv("MV_COFIDIF",.F.,0) <> 0
			cRet := SuperGetMv("MV_COFIDIF",.F.,0)
		Else
			cRet := SuperGetMv("MV_PCCOFI",.F.,7.6)
		EndIf
	EndIf
Return cRet

Function GFEUPDCalc()
	Local cAliasQry := Nil
	Local cWhere    := ""
	Local cVLCNPJ   :=  SuperGetMV('MV_VLCNPJ',,'1')

	GW0->(dbSetOrder(1))//GW0_FILIAL+GW0_TABELA+GW0_CHAVE

	If SuperGetMV("MV_DPSERV", .F., "1") == "1"
		If cVLCNPJ == "1"
			cWhere := " AND GWF.GWF_TRANSP = GW3.GW3_EMISDF "
		EndIf
		cWhere := "%"+cWhere+"%"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DISTINCT GWF.R_E_C_N_O_ RECNOGWF,
					GWF.GWF_NRCALC,
					GWF.GWF_TRANSP,
					GWF.GWF_TPCALC,
					GW4.GW4_TPDC,
					GW4.GW4_EMISDC,
					GW4.GW4_SERDC,
					GW4.GW4_NRDC,
					GU3A.GU3_IDFED AS GU3A_IDFED,
					GU3B.GU3_IDFED AS GU3B_IDFED,
					GW3.GW3_FILIAL,
					GW3.GW3_CDESP,
					GW3.GW3_EMISDF,
					GW3.GW3_SERDF,
					GW3.GW3_NRDF,
					GW3.GW3_DTEMIS,
					GW3.GW3_CDTPSE
			FROM %Table:GW4% GW4
			INNER JOIN %Table:GW3% GW3
			ON GW4.GW4_FILIAL = GW3.GW3_FILIAL
			AND GW4.GW4_EMISDF = GW3.GW3_EMISDF
			AND GW4.GW4_CDESP = GW3.GW3_CDESP
			AND GW4.GW4_SERDF = GW3.GW3_SERDF
			AND GW4.GW4_NRDF = GW3.GW3_NRDF
			AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS
			AND GW4.%NotDel%
			INNER JOIN %Table:GU3% GU3A
			ON GU3A.GU3_FILIAL = %xFilial:GU3%
			AND GU3A.GU3_CDEMIT = GW3.GW3_EMISDF
			AND GU3A.%NotDel%
			INNER JOIN %Table:GWH% GWH
			ON GWH.GWH_FILIAL = GW4.GW4_FILIAL
			AND GWH.GWH_CDTPDC = GW4.GW4_TPDC
			AND GWH.GWH_EMISDC = GW4.GW4_EMISDC
			AND GWH.GWH_SERDC = GW4.GW4_SERDC
			AND GWH.GWH_NRDC = GW4.GW4_NRDC
			AND GWH.%NotDel%
			INNER JOIN %Table:GWF% GWF
			ON GWF.GWF_FILIAL = GWH_FILIAL
			AND GWF.GWF_NRCALC = GWH_NRCALC
			AND GWF.GWF_TPCALC = GW3.GW3_TPDF
			AND GWF.GWF_CDTPSE = GW3.GW3_CDTPSE
			AND GWF.GWF_CDESP = ' '
			AND GWF.GWF_EMISDF = ' '
			AND GWF.GWF_SERDF = ' '
			AND GWF.GWF_NRDF = ' '
			AND GWF.GWF_DTEMDF = ' '
			%Exp:cWhere%
			AND GWF.%NotDel%
			INNER JOIN %Table:GU3% GU3B
			ON GU3B.GU3_FILIAL = %xFilial:GU3%
			AND GU3B.GU3_CDEMIT = GWF.GWF_TRANSP
			AND GU3B.%NotDel%
			WHERE GW3.GW3_SIT IN ('2','3','4')
			AND GW3.%NotDel%
			ORDER BY GW4_TPDC,
						GW4.GW4_EMISDC,
						GW4.GW4_SERDC,
						GW4.GW4_NRDC,
						GWF.GWF_NRCALC
		EndSql
		GFEConout("INFO",getLastQuery()[2])
		Do While (cAliasQRY)->(!Eof())
			If cVLCNPJ == "1" .Or. SubStr((cAliasQRY)->GU3A_IDFED, 1, 8) == SubStr((cAliasQRY)->GU3B_IDFED, 1, 8)
				GWF->(dbsetorder(6))
				If (cAliasQRY)->GWF_TPCALC == "1" .Or. !GWF->(msseek((cAliasQRY)->GW3_FILIAL + (cAliasQRY)->GW3_CDESP + (cAliasQRY)->GW3_EMISDF + (cAliasQRY)->GW3_SERDF + (cAliasQRY)->GW3_NRDF + (cAliasQRY)->GW3_DTEMIS))
					GWF->(dbGoTo((cAliasQRY)->RECNOGWF))

					RecLock("GWF",.F.)
					GWF->GWF_CDESP := (cAliasQRY)->GW3_CDESP
					GWF->GWF_EMISDF:= (cAliasQRY)->GW3_EMISDF
					GWF->GWF_SERDF := (cAliasQRY)->GW3_SERDF
					GWF->GWF_NRDF  := (cAliasQRY)->GW3_NRDF
					GWF->GWF_DTEMDF:= SToD((cAliasQRY)->GW3_DTEMIS)
					GWF->(MsUnlock())
					GFEConout("INFO",'[RUP_GFE] - Doc. Frete ' + (cAliasQRY)->GW3_CDESP + (cAliasQRY)->GW3_EMISDF + (cAliasQRY)->GW3_SERDF + (cAliasQRY)->GW3_NRDF + (cAliasQRY)->GW3_DTEMIS + ' relacionado ao calculo ' + GWF->GWF_NRCALC)
				EndIf
			EndIf
			(cAliasQRY)->(dbSkip())
		EndDo
		(cAliasQRY)->(dbCloseArea())
	ElseIf SuperGetMV("MV_DPSERV", .F., "1") == "2"
		GWF->(dbGoTop())
		Do While GWF->(!EoF())
			RecLock("GWF",.F.)
			GWF->GWF_CDESP  := ""
			GWF->GWF_EMISDF := ""
			GWF->GWF_SERDF  := ""
			GWF->GWF_NRDF   := ""
			GWF->GWF_DTEMDF := STOD("")
			GWF->(MsUnlock())
			GWF->(dbSkip())
		EndDo
	EndIf

	If !GW0->( dbSeek(Space(Len(xFilial("GW0"))) + PadR("GWF", TamSX3("GW0_TABELA")[1]) + PadR("MV_DPSERV", TamSX3("GW0_CHAVE")[1])) )
		RecLock("GW0", .T.)
		GW0->GW0_TABELA := "GWF"
		GW0->GW0_CHAVE  := "MV_DPSERV"
		GW0->GW0_CHAR01 := GetComputerName()
		GW0->GW0_DATA01 := Date()
		GW0->( MSUnlock())
	EndIf
Return .T.

Function GFEA065FGER(cNATFRE, cUso)
	Do Case
	Case cNATFRE == "0" .Or. cNATFRE == "1"
		Return "4" // Venda
	Case cNATFRE == "2" .Or. cNATFRE == "3"
		If cUso == "2"
			Return "2"
		ElseIf cUso == "3"
			Return "3"
		Else
			Return "1" // Compra
		EndIf
	Case cNATFRE == "4" .Or. cNATFRE == "5"
		Return "5" // Transferência
	End Case
Return ""

/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime    := .T.
	Default nPosicao := _LOG_END

	If !_lLogIntP
		Return
	EndIf

	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(_lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL

/*/{Protheus.doc} GFEA065VET
Valida se trecho possue entrega trecho
@type  Function
@author Squad GFE
@since 08/01/2020
@version 1.0
@param cTpDf, caracter, Tipo do documento de frete
@param cEmisDf, caracter, Emissor do documento de frete
@param cNrDf, caracter, Número do documento de frete
@param cFilDc, caracter, Filial do documento de carga
@param cTpDc, caracter, Tipod do documento de carga
@param cEmisDc, caracter, Emissor do documento de carga
@param cSerDc, caracter, Série do documento de carga
@param cNrDc, caracter, Número do documento de carga
@return lRet, lógico, .T. Trecho válido, .F. Trecho inválido
/*/
Function GFEA065VET(cTpDf,cEmisDf,cNrDf,cFilDc,cTpDc,cEmisDc,cSerDc,cNrDc)
	Local cMsg      := ""
	Local cWhere    := ""
	Local cAliasGWU := Nil
	Local cAliasGU3 := Nil
	Local lContinua := .T.
	Local lEvidObr  := .F.

	cAliasGU3 := GetNextAlias()
	BeginSql Alias cAliasGU3
		SELECT GU3.GU3_ENTOBR
		FROM %Table:GU3% GU3
		WHERE  GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_CDEMIT = %Exp:cEmisDf%
		AND GU3.GU3_ENTOBR <> '2'
		AND GU3.%NotDel%
	EndSql
	If (cAliasGU3)->(!Eof())
		If ((cAliasGU3)->GU3_ENTOBR == "2") 	//2=Nenhum
			lContinua := .F.
		ElseIf ((cAliasGU3)->GU3_ENTOBR == "0") //0=Prova de Entrega, exige data e evidencia de entrega
			lEvidObr := .T.
		EndIf
	Else
		lContinua := .F.
	EndIf
	(cAliasGU3)->(dbCloseArea())

	If lContinua .And. cTpDf $ '1|6'
		If lEvidObr .And. GFXCP12130("GWU_EVENTR")
			cWhere := " AND GWU_EVENTR <> '' "
		EndIf

		If cTpDf == '1'
			cWhere += " AND GWU.GWU_SEQ = '01'"
		Else
			cWhere += " AND GWU.GWU_SEQ > '01'"
		EndIf

		cWhere := "%"+cWhere+"%"

		cAliasGWU := GetNextAlias()
		BeginSql Alias cAliasGWU
			SELECT GW1.GW1_SERDC,
					GW1.GW1_NRDC
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(cEmisDf)%)
			AND GWU.GWU_DTENT <> ' '
			%Exp:cWhere%
			AND GWU.%NotDel%
			INNER JOIN %Table:GV5% GV5
			ON GV5.GV5_FILIAL = %xFilial:GV5%
			AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC
			//AND GV5.GV5_SENTID IN ('1','2','3')
			AND GV5.%NotDel%
			WHERE GW1.GW1_FILIAL = %Exp:IIf(Empty(cFilDc),xFilial("GW4"),cFilDc)%
			AND GW1.GW1_CDTPDC = %Exp:cTpDc%
			AND GW1.GW1_EMISDC = %Exp:cEmisDc%
			AND GW1.GW1_SERDC = %Exp:cSerDc%
			AND GW1.GW1_NRDC = %Exp:cNrDc%
			AND GW1.%NotDel%
		EndSql
		If (cAliasGWU)->(Eof())
			If lEvidObr
				cMsg := "Trecho do documento de carga número: "+AllTrim(cNrDc)+" série: "+AllTrim(cSerDc)+" correspondente ao documento de frete número: "+Alltrim(cNrDf)+" não possui data de entrega e/ou evidência de entrega informadas;"
				cMsg += "emitente: "+AllTrim(cEmisDf)+" exige registro da data de entrega e da evidência de entrega."
			Else
				cMsg := "Trecho do documento de carga número: "+AllTrim(cNrDc)+" série: "+AllTrim(cSerDc)+" correspondente ao documento de frete número: "+Alltrim(cNrDf)+" não possui data de entrega informada;"
				cMsg += "emitente: "+AllTrim(cEmisDf)+" exige registro da data de entrega."
			EndIf
			lBloqEntrega := .T.
		EndIf
		(cAliasGWU)->(dbCloseArea())
	EndIf
Return cMsg

/*/{Protheus.doc} GFEA065VTR
Verifica se há trecho informado
@type  Function
@author Squad GFE
@since 08/01/2020
@version 1.0
@param cTpDf, caracter, Tipo do documento de frete
@param cEmisDf, caracter, Emissor do documento de frete
@param cNrDf, caracter, Número do documento de frete
@param cFilDc, caracter, Filial do documento de carga
@param cTpDc, caracter, Tipod do documento de carga
@param cEmisDc, caracter, Emissor do documento de carga
@param cSerDc, caracter, Série do documento de carga
@param cNrDc, caracter, Número do documento de carga
@return lRet, lógico, .T. Trecho válido, .F. Trecho inválido
/*/
Function GFEA065VTR(cTpDf,cEmisDf,cNrDf,cFilDc,cTpDc,cEmisDc,cSerDc,cNrDc)
	Local cMsg      := ""
	Local cSolucao  := ""
	Local lRet      := .T.
	Local cAliasGWU := GetNextAlias()
	Local oModel    := FWModelActive()
	Local cAliasGWD := ""

	// De acordo com o parâmetro MV_GFEROTR irá validar se o transportador está atribuído em algum trecho do documento de carga
	If __lGFEROTR
		If cTpDf $ '1|6'
			If cTpDf == '1'
				cWhere := " AND GWU.GWU_SEQ = '01'"
			Else
				cWhere := " AND GWU.GWU_SEQ > '01'"
			EndIf
			cWhere := "%"+cWhere+"%"

			BeginSql Alias cAliasGWU
				SELECT 1
				FROM %Table:GW1% GW1
				INNER JOIN %Table:GWU% GWU
				ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
				AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
				AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
				AND GWU.GWU_SERDC = GW1.GW1_SERDC
				AND GWU.GWU_NRDC = GW1.GW1_NRDC
				AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(cEmisDf)%)
				AND GWU.%NotDel%
				%Exp:cWhere%
				WHERE GW1.GW1_FILIAL = %Exp:IIf(Empty(cFilDc),xFilial("GW4"),cFilDc)%
				AND GW1.GW1_CDTPDC = %Exp:cTpDc%
				AND GW1.GW1_EMISDC = %Exp:cEmisDc%
				AND GW1.GW1_SERDC = %Exp:cSerDc%
				AND GW1.GW1_NRDC = %Exp:cNrDc%
				AND GW1.%NotDel%
			EndSql

			If (cAliasGWU)->(Eof())
				cAliasGWD := GetNextAlias()
				BeginSQL Alias cAliasGWD
					SELECT  GWD.R_E_C_N_O_ RECNOGWD
					FROM %Table:GWL% GWL
					LEFT JOIN %Table:GWD% GWD
					ON GWD.GWD_FILIAL = GWL.GWL_FILIAL
					AND GWD.GWD_NROCO = GWL.GWL_NROCO
					AND GWD.%NotDel%
					WHERE GWL.GWL_FILIAL = %Exp:IIf(Empty(cFilDc),xFilial("GWL"),cFilDc)%
					AND GWL.GWL_TPDC = %Exp:cTpDc%
					AND GWL.GWL_EMITDC = %Exp:cEmisDc%
					AND GWL.GWL_SERDC = %Exp:cSerDc%
					AND GWL.GWL_NRDC = %Exp:cNrDc%
					AND GWD.GWD_PRESTS IN (%Exp:GFEGetEmRz(cEmisDf)%)
					AND GWL.%NotDel%
				EndSql

				If  (cAliasGWD)->(Eof())
					cMsg     := "Nenhum trecho do documento de carga ou ocorrência vinculada ao documento de carga número: "+AllTrim(cNrDc)+" série: "+AllTrim(cSerDc)+" possui o transportador igual ao emissor: "+AllTrim(cEmisDf)+" do documento de frete número: "+Alltrim(cNrDf)
					cSolucao := "É previsto que o emissor do documento de frete seja o transportador da sequencia do trecho corresponde ao tipo do documento de frete (1-Normal para o primeiro trecho e 6-Redespacho para os demais trechos) ou possua uma ocorrência com este emissor como prestador de serviço."
					oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
					lRet := .F.
				EndIf
				(cAliasGWD)->(dbCloseArea())
			EndIf
			(cAliasGWU)->(dbCloseArea())
		EndIf
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065GW1
	Verifica se documento de carga valido
	@type  Function
	@author Squad GFE
	@since 08/01/2020
	@version 1.0
	@param cFilDf, caracter, Filial do documento de frete
	@param cCdTpDc, caracter, Tipo do documento de carga
	@param cEmissDc, caracter, Emissor do documento de carga
	@param cSerDc, caracter, Série do documento de carga
	@param cNrDc, caracter, Número do documento de carga
	@return lRet, lógico, .T. Documento válido, .F. Documento inválido
/*/
//---------------------------------------------------------------------------------------------------------
Function GFEA065GW1(cFilDf,cCdTpDc,cEmissDc,cSerDc,cNrDc)
	Local lRet      := .T.
	Local cAliasGW1 := GetNextAlias()
	Local cMsg      := ""
	Local cSolucao  := ""
	Local oModel    := FWModelActive()

	BeginSql Alias cAliasGW1
		SELECT GW1.GW1_NRROM,
				GW1.GW1_DTSAI,
				GW1.GW1_SIT
		FROM %Table:GW1% GW1
		WHERE GW1.GW1_FILIAL = %Exp:cFilDf%
		AND GW1.GW1_CDTPDC = %Exp:cCdTpDc%
		AND GW1.GW1_EMISDC = %Exp:cEmissDc%
		AND GW1.GW1_SERDC = %Exp:cSerDc%
		AND GW1.GW1_NRDC = %Exp:cNrDc%
		AND GW1.%NotDel%
	EndSql
	If (cAliasGW1)->(!Eof())
		// De acordo com o parâmetro MV_GFEROTR irá validar se o romaneio de carga existe e se está liberado
		If __lGFEROTR
			If Empty((cAliasGW1)->GW1_NRROM)
				cMsg     := "["+GFEA065015+"] "+ GFEMsgFmt(STR0527,{{"[VAR01]",AllTrim(cNrDc)},{"[VAR02]",AllTrim(cSerDc)},{"[VAR03]",AllTrim(GW1->GW1_EMISDC)}}) //"Documento de Carga número: [VAR01] série: [VAR02] Emissor: [VAR03] não possui Romaneio de Carga gerado!"
				cSolucao := STR0528 //"Incluir Documento de Carga em um Romaneio de Carga!"
				lRet := .F.
			EndIf
			If lRet .And. Empty((cAliasGW1)->GW1_DTSAI)
				cMsg     := "["+GFEA065011+"] "+ GFEMsgFmt(STR0519,{{"[VAR01]",AllTrim(cNrDc)},{"[VAR02]",AllTrim(cSerDc)},{"[VAR03]",AllTrim(GW1->GW1_EMISDC)}}) //"Documento de Carga número: [VAR01] série: [VAR02] Emissor: [VAR03] está com a data de saída em branco."
				cSolucao := GFEMsgFmt(STR0520,{{"[VAR01]",AllTrim((cAliasGW1)->GW1_NRROM)}}) //"Para atribuir a data de saída do Documento de Carga, Libere o Romaneio de Carga: [VAR01]!"
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. (cAliasGW1)->GW1_SIT == '2'
			cMsg     := "["+GFEA065012+"] "+GFEMsgFmt(STR0521,{{"[VAR01]",AllTrim(cNrDc)},{"[VAR02]",AllTrim(cSerDc)},{"[VAR03]",AllTrim(GW1->GW1_EMISDC)}}) //"Documento de Carga número: [VAR01] série: [VAR02] Emissor: [VAR03] está bloqueado, não é permitido relacionar ao documento de frete um documento de carga em situação bloqueado."
			cSolucao := STR0522 //"Efetue a liberação do Documento de Carga para permitir relacionar ao Documento de Frete!"
			lRet := .F.
		EndIf
		If lRet .And. (cAliasGW1)->GW1_SIT == '7'
			cMsg     := "["+GFEA065013+"] "+GFEMsgFmt(STR0523,{{"[VAR01]",AllTrim(cNrDc)},{"[VAR02]",AllTrim(cSerDc)},{"[VAR03]",AllTrim(GW1->GW1_EMISDC)}}) //"Documento de Carga número: [VAR01] série: [VAR02] Emissor: [VAR03] está cancelado, não é permitido relacionar ao documento de frete um documento de carga em situação cancelado."
			cSolucao := STR0524 //"Verifique se o Documento de Carga a ser relacionado está correto!"
			lRet := .F.
		EndIf
	Else
		cMsg     := "["+GFEA065014+"] "+GFEMsgFmt(STR0525,{{"[VAR01]",AllTrim(FwFldGet("GW4_NRDC"))},{"[VAR02]",AllTrim(FwFldGet("GW4_SERDC"))},{"[VAR03]",AllTrim(GW1->GW1_EMISDC)}}) //"Documento de Carga número: [VAR01] série: [VAR02] Emissor: [VAR03] não encontrado."
		cSolucao := STR0526 //"Verifique se o Documento de Carga está registrado na mesma filial do Documento de Frete!"
		lRet := .F.
	EndIf
	If !lRet
		oModel:SetErrorMessage(,,,,,cMsg,cSolucao)
	EndIf
	(cAliasGW1)->(dbCloseArea())
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065REA
Reauditar Documento de Frete
@type function
@version 12.1.30
@author andre.alvarez
@since 28/02/2020
/*/
//---------------------------------------------------------------------------------------------------------
Function GFEA065REA()
	Local nRecGW3 := 0

	nRecGW3 := GW3->(Recno())
	GW3->(dbGoTo(nRecGW3))

	If GW3->GW3_SIT != '2' .And. GW3->GW3_SIT != '5'
		Help( ,, 'HELP',, "Somente é possível reauditar documentos com situação bloqueada.", 1, 0)
		Return
	EndIf

	GFE50DFCONF()

	MsgInfo("Reauditoria realizada com sucesso! Verifique a situação do documento de frete, caso o documento tenha atendido os critérios de auditoria a situação será alterada para 'Aprovado Sistema', caso continue não atendo, a situação será mantida como 'Bloqueado'")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065LOT

Função para excluir ocorrencias em lote conforme filtro informado e dados marcados

@author Jefferson Hita
@since 08/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA065LOT()
	Local oDlg
	Local oPnlA
	Local oPnlB
	Local aCores    := {}
	Local aGW3      := Nil
	Local aCpGW3    := Nil
	Local cCadastro := "Exclusão de Doc Frete em Lote"
	Local nAlt      := GetScreenRes()[2]
	Local nLrg      := GetScreenRes()[1]
	Local aNewButton:= {}

	Private oMark
	Private cAliGW3   := Nil
	Private cOperacao := "Excluir"
	Private cMarca    := GetMark()
	Private cSitFis   := ""
	Private cWhereSit := ""

	nAlt -= (nAlt - 1100) * 80 / 100

	//Pergunte Exclusão Doc de Frete em Lote
	IF Pergunte("GFEA065LOT",.T.)
		VerifParam()
	Else
		MsgAlert("Realize o cadastro do Pergunte (GFEA065LOT) antes de seguir com a exclusão em lote!")
		Return
	EndIf

	Aadd(aNewButton, {"Parâmetros" ,{||RepPerg065()},"Parâmetros","Parâmetros"})

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aGW3 := {{"OK"    , "C" , 02                     , 0},;
		{"FILIAL" , "C", TamSX3("GW3_FILIAL")[1], 0},;
		{"CDESP"  , "C", TamSX3("GW3_CDESP" )[1], 0},;
		{"EMISDF" , "C", TamSX3("GW3_EMISDF")[1], 0},;
		{"SERDF"  , "C", TamSX3("GW3_SERDF" )[1], 0},;
		{"NRDF"   , "C", TamSX3("GW3_NRDF"  )[1], 0},;
		{"DTEMIS" , "D", TamSX3("GW3_DTEMIS")[1], 0},;
		{"NMTRP"  , "C", TamSX3("GU3_NMEMIT")[1], 0},;
		{"TPDF"   , "C", 20  					 , 0},;
		{"DTENT"  , "D", TamSX3("GW3_DTENT" )[1], 0},;
		{"SIT"    , "C", 22   					 , 0},;
		{"SITFIS" , "C", 22   				     , 0},;
		{"RECNUM" , "N", 10					 , 0}}

	aCpGW3 := {{"OK"     , Nil, " "					   ,""  },;
		{"CDESP"  , Nil, "Espécie"			   ,"@!"},;
		{"EMISDF" , Nil, "Emissor"			   ,"@!"},;
		{"NMTRP"  , Nil, "Nome"				   ,"@!"},;
		{"SERDF"  , Nil, "Série"			 	   ,"@!"},;
		{"NRDF"   , Nil, "Nr. Doc. Frete"       ,"@!"},;
		{"DTEMIS" , Nil, "Data Emissão"		   ,"@!"},;
		{"TPDF"   , Nil, "Tipo DF"     		   ,"@!"},;
		{"DTENT"  , Nil, "Data Entrada"		   ,""  },;
		{"SIT"    , Nil, "Situação"   		   ,"@!"},;
		{"SITFIS" , Nil, "Situação Fiscal"      ,"@!"}}

	cAliGW3 := GFECriaTab({aGW3, {"FILIAL+CDESP+EMISDF+SERDF+NRDF+DTEMIS"}})

	CursorWait()

	Processa({|lEnd| GFE065Load()}, "Filtrando Documentos de Frete...", "Aguarde")

	dbSelectArea(cAliGW3)
	dbSetOrder(1)
	dbGoTop()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Color CLR_BLACK,RGB(225,225,225) Pixel Of oMainWnd
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	@ 07,10  Say "Transportador de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,65  MsGet MV_PAR01 Picture "@!" SIZE 50,7 When .F. Pixel Of oPnlA
	@ 07,120 Say "Transportador até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,175 MsGet MV_PAR02 Picture "@!" SIZE 50,7 When .F. Pixel Of oPnlA
	@ 07,230 Say "Dt de Entrada de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,280 MsGet MV_PAR03 Picture "99/99/9999" SIZE 65,7 When .F. Hasbutton Pixel Of oPnlA
	@ 07,350 Say "Dt de Entrada até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,400 MsGet MV_PAR04 Picture "99/99/9999" SIZE 65,7 When .F. Hasbutton Pixel Of oPnlA
	@ 07,470 Say "Sit. Fiscal: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,500 MsGet cSitFis Picture "@!" SIZE 65,7 When .F. Hasbutton Pixel Of oPnlA

	@ 23,10  Say "Nr. Doc. de Frete de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,65  MsGet MV_PAR05 Picture "@!" SIZE 50,7 When .F. Hasbutton Pixel Of oPnlA
	@ 23,120 Say "Nr. Doc. de Frete até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,175 MsGet MV_PAR06 Picture "@!" SIZE 50,7 When .F. Hasbutton Pixel Of oPnlA
	@ 23,230 Say "Dt de Emissão de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,280 MsGet MV_PAR07 Picture "99/99/9999" SIZE 65,7 When .F. Hasbutton Pixel Of oPnlA
	@ 23,350 Say "Dt de Emissão até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,400 MsGet MV_PAR08 Picture "99/99/9999" SIZE 65,7 When .F. Hasbutton Pixel Of oPnlA

	oMark := MsSelect():New(cAliGW3, "OK", , aCpGW3, , @cMarca, {0,0,0,0}, , , oPnlB,,aCores)
	oMark:oBrowse:bLDblClick := {|| GFE065CHK(.F.) }
	oMark:oBrowse:cToolTip := "Excluir"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:bAllMark :=  {|| GFE065CHK(.T.)}

	CursorArrow()

	Activate MsDialog oDlg ON Init EnchoiceBar(ODlg, {|| If(GFE065LOTE(), ODlg:End(), NIL)},;
		{|| If(ApMsgYesNo("Deseja cancelar esse processo?"), ODlg:End(),)},,aNewButton) Centered

	GFEDelTab(cAliGW3)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifParam

Função para verificar os parâmetros .T. de Situação Fiscal

@author Philippe Rocca Bretas
@since 18/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerifParam()
	Local cSitValue    := 0
	Local aSitFis      := {}
	Local nX           := 1
	Local aParams 	   := {{MV_PAR09, "1 - Não enviado", "1"}, ;
		{MV_PAR10, "2 - Pendente", "2"}, ;
		{MV_PAR11, "3 - Rejeitado", "3"}, ;
		{MV_PAR12, "4 - Atualizado", "4"}, ;
		{MV_PAR13, "5 - Pendente desatualização", "5"}, ;
		{MV_PAR14, "6 - Não se aplica", "6"}}

	cWhereSit    := ''

	For nX := 1 To Len(aParams)
		If aParams[nX][1] == 1
			cSitFis := aParams[nX][2]
			cSitValue := aParams[nX][3]
			AADD(aSitFis, cSitValue)
		EndIf
	Next nX

	For nX := 1 To Len(aSitFis)
		If nX != Len(aSitFis)
			cWhereSit += aSitFis[nX] + ','
		Else
			cWhereSit += aSitFis[nX]
		EndIf
	Next nX

	cWhereSit := "%" + cWhereSit + "%"

	If len(aSitFis) > 1
		cSitFis := "Multiplas Situações"
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RepPerg065

Função para realizar o Pergunte e o reprocessamento através do botão em Outras Ações.

@author Philippe Rocca Bretas
@since 16/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RepPerg065()
	//Pergunte Exclusão Doc de Frete em Lote
	Pergunte("GFEA065LOT",.T.)

	VerifParam()

	Processa({|lEnd| GFE065Load()}, "Filtrando Documentos de Frete...", "Aguarde")

	dbSelectArea(cAliGW3)
	dbSetOrder(1)
	dbGoTop()
Return

Static Function GFE065CHK(lMarkAll)
	Default lMarkAll := .F.

	If lMarkAll
		(cAliGW3)->(dbGoTop())
		Do While (cAliGW3)->(!Eof())
			RecLock(cAliGW3, .F.)
			If ((cAliGW3)->OK <> cMarca)
				(cAliGW3)->OK := cMarca
			Else
				(cAliGW3)->OK := " "
			EndIf
			(cAliGW3)->(MsUnlock())
			(cAliGW3)->(dbSkip())
		EndDo
		(cAliGW3)->(DbGoTop())
	Else
		RecLock((cAliGW3), .F.)
		(cAliGW3)->OK := If(IsMark('OK', cMarca), "  ", cMarca)
		(cAliGW3)->(MsUnLock())
	EndIf
	(cAliGW3)->(DbGoTop())
	oMark:oBrowse:Refresh(.T.)
Return

Static Function GFE065Load()
	Local cAliasQry := GetNextAlias()
	Local aTpDF     := {{"1", "Normal"},;
		{"2", "Complementar Valor"},;
		{"3", "Complementar Imposto"},;
		{"4", "Reentrega"},;
		{"5", "Devolucao"},;
		{"6", "Redespacho"},;
		{"7", "Servico"}}
	Local aSit      := {{"1", "Digitado"},;
		{"2", "Bloqueado"},;
		{"3", "Aprovado pelo Sistema"},;
		{"4", "Aprovado pelo Usuário"},;
		{"5", "Bloqueado por Entrega"}}
	Local aSitFis      := {{"1", "Não enviado"},;
		{"2", "Pendente"},;
		{"3", "Rejeitado"},;
		{"4", "Atualizado"},;
		{"5", "Pendente desatualização"},;
		{"6", "Não se aplica"}}

	DbSelectArea(cAliGW3)
	ZAP

	BeginSql Alias cAliasQry
		SELECT GW3_FILIAL
		     , GW3_CDESP
			 , GW3_EMISDF
			 , GW3_SERDF
			 , GW3_NRDF
			 , GW3_DTEMIS
			 , GW3_TPDF
			 , GW3_DTENT
			 , GW3_SIT
			 , GW3_SITFIS
			 , GW3.R_E_C_N_O_ AS RECNUM
		FROM %Table:GW3% GW3
		WHERE GW3.GW3_FILIAL = %xFilial:GW3%
		AND GW3.GW3_EMISDF BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND GW3.GW3_DTENT  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND GW3.GW3_NRDF   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
		AND GW3.GW3_DTEMIS BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
		AND GW3.GW3_SITFIS IN (%Exp:cWhereSit%)
		AND GW3.%NotDel%
		ORDER BY GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF, GW3_DTEMIS
	EndSql
	While (cAliasQry)->(!Eof())
		RecLock((cAliGW3),.T.)
		(cAliGW3)->OK     := cMarca
		(cAliGW3)->FILIAL := (cAliasQry)->GW3_FILIAL
		(cAliGW3)->CDESP  := (cAliasQry)->GW3_CDESP
		(cAliGW3)->EMISDF := (cAliasQry)->GW3_EMISDF
		(cAliGW3)->NMTRP  := Alltrim(Posicione("GU3", 1, xFilial("GU3") + (cAliasQry)->GW3_EMISDF, "GU3_NMEMIT"))
		(cAliGW3)->SERDF  := (cAliasQry)->GW3_SERDF
		(cAliGW3)->NRDF   := (cAliasQry)->GW3_NRDF
		(cAliGW3)->DTEMIS := SToD((cAliasQry)->GW3_DTEMIS)
		(cAliGW3)->DTENT  := SToD((cAliasQry)->GW3_DTENT)
		(cAliGW3)->TPDF   := aTpDF[aScan(aTpDF, {|x| x[1] == Alltrim((cAliasQry)->GW3_TPDF)})][2]
		(cAliGW3)->SIT    := aSit[aScan(aSit, {|x| x[1] == Alltrim((cAliasQry)->GW3_SIT)})][2]
		(cAliGW3)->SITFIS := aSitFis[aScan(aSitFis, {|x| x[1] == Alltrim((cAliasQry)->GW3_SITFIS)})][2]
		(cAliGW3)->RECNUM := (cAliasQry)->RECNUM
		(cAliGW3)->(MsUnlock())

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return .T.

Static Function GFE065LOTE()
	Local nX         := 0
	Local nY         := 0
	Local lRet       := .T.
	Local aErro  	 := {}
	Local oModel 	 := Nil

	Private nCount   := 0
	Private aMsgProc := {}
	Private oVwProc  := GFEViewProc():New()

	(cAliGW3)->(dbGoToP())
	If !(cAliGW3)->(Eof())
		While (cAliGW3)->(!Eof())
			If (cAliGW3)->OK == cMarca
				nCount++
				GW3->(dbGoto((cAliGW3)->RECNUM))

				oModel := FwLoadModel("GFEA065")
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				If !oModel:Activate() .Or. !oModel:VldData()
					aErro := oModel:GetErrorMessage()
					aAdd(aMsgProc, { nCount,;
						CRLF + "Falha na exclusão do(s) Documento(s) de Frete: Filial: " + Alltrim(GW3->GW3_FILIAL) + " / Emissor: "+ Alltrim(GW3->GW3_EMISDF) + " / Série: "+ Alltrim(GW3->GW3_SERDF) + " / Nr.DF: "+ Alltrim(GW3->GW3_NRDF) + CRLF +;
						"Mensagem: " + AllToChar(aErro[6]) + CRLF +;
						"Solução: " + AllToChar(strtran(Alltrim(aErro[7]), CRLF, " ")) + CRLF +;
						IIF(!Empty(aErro[2]),"Campo: " + AllToChar(aErro[2]) + CRLF + "Valor: " + AllToChar(aErro[9])," ")})
				Else
					oModel:CommitData()
				EndIf
				oModel:DeActivate()
				FreeObj(oModel)

				aSize(aErro, 0)
			EndIf

			(cAliGW3)->(DbSkip())
		EndDo

		// Processamento da mensagens da rotina
		CursorArrow()
		For nX := 1 To Len(aMsgProc)
			If nY != aMsgProc[nX,1]
				nY := aMsgProc[nX,1]
				oVwProc:AddErro( "Erro(s) no registro " + cValToChar(nY) + ": " + aMsgProc[nX,2] )
			EndIf
		Next nX

		If Len(aMsgProc) == 0
			oVwProc:Add("")
			oVwProc:Add("Documentos de Frete selecionado excluídos com sucesso!")
		EndIf
		oVwProc:Show("Excluir em Lote", "Documentos de Frete", "Erros", "Um ou mais registros não foram excluídos. Clique em 'Erros' para mais detalhes.")
	EndIf
	FreeObj(oVwProc)
Return lRet

Function ParInt65()
	Local lIntGFE	 := SuperGetMv("MV_INTGFE" ,.F.,.F.)
	Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE    := SuperGetMv("MV_ERPGFE" ,.F.,"2")
	Local cIntGFEI13 := SuperGetMV('MV_GFEI13' ,   ,'1')
	Local cIntGFEI14 := SuperGetMV('MV_GFEI14' ,   ,'1')
	Local cIntFisc   := SuperGetMv("MV_GFEI23" ,.F.,"2")
	Local dDtUlFe    := SuperGetMv("MV_DTULFE" ,.F.,"01/01/1900")
	Local cParTES    := SuperGetMV('MV_TESGFE' ,   ,"3")
	Local cSiGFE     := SuperGetMv("MV_SIGFE"  ,.F.,"2")
	Local cDTInt     := SuperGetMv("MV_DSOFDT" ,.F.,"1")
	Local lIntDocF   := SuperGetMv('MV_DSCTB'  ,   ,'1') == "2"
	Local cParData   := SuperGetMV('MV_DSDTRE' ,   ,'1')

	lISSxMun         := SuperGetMV("MV_ISSXMUN",.F.,.F.)
	aParamValue      := {}

	If Empty(cParData)
		cParData := "1"
	EndIf

	aadd(aParamValue, {;
		{"MV_INTGFE:  GFE Ativo: - "                        ,cValToChar(lIntGFE)},;
		{"MV_INTGFE2: Modo de Integração - PROTHEUS/ GFE - ",cIntGFE2},;
		{"MV_ERPGFE:  ERP Integrado - " 					,cERPGFE},;
		{"MV_GFEI13:  Doc. Frete Fiscal - "  				,cIntGFEI13},;
		{"MV_GFEI14:  Doc. Frete Custo - " 					,cIntGFEI14},;
		{"MV_GFEI23:  Fiscal Pré-requisito para Atualizar Fatura com Financ.-", cIntFisc},;
		{"MV_DTULFE:  Data do último fechamento - " 		,cValToChar(dDtUlFe)},;
		{"MV_ISSXMUN: Tratamento de ISS por Municipio - " 	,cvaltoChar(lISSxMun)},;
		{"MV_TESGFE:  TES Doc. Frete - " 					,cParTES},;
		{"MV_DSOFDT:  Data Transação Documento Fiscal - " 	,cDTInt},;
		{"MV_SIGFE:   Solicita Info Integração - "  		,cSiGFE},;
		{"MV_DSCTB:   Contabilização Frete de Vendas - " 	,cValToChar(lIntDocF)},;
		{"MV_DSDTRE:  Data de Integração Recebimento - " 	,cParData};
		})

Return aParamValue
