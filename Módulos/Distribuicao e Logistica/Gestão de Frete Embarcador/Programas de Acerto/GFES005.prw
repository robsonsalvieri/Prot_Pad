#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
Garação de arquivo .txt de Conemb (Documento de Frete) para testes importação EDI

@author Ana Claudia da Silva
@since 07/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GFES005()
	
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
	oBrowse:SetDescription("Digitação de Documentos de Frete")	// Descrição do browse

	aAdd(aLegenda, {"GW3_SIT=='1'", "BLACK", "Digitado"})
	aAdd(aLegenda, {"GW3_SIT=='2'", "RED"  , "Bloqueado"})
	aAdd(aLegenda, {"GW3_SIT=='3'", "GREEN", "Aprovado pelo Sistema"})
	aAdd(aLegenda, {"GW3_SIT=='4'", "BLUE" , "Aprovado pelo Usuário"})
	aAdd(aLegenda, {"GW3_SIT=='5'", "YELLOW" , "Bloqueado por Entrega"})

	// Ponto de entrada para customizar as legendas do Browse
	If ExistBlock("GFE065LG")
		aLegenda := ExecBlock("GFE065LG",.f.,.f.,{aLegenda})
	EndIf

	nF := Len(aLegenda)
	For nI := 1 To nF
		oBrowse:AddLegend(aLegenda[nI][1], aLegenda[nI][2], aLegenda[nI][3])
	Next nI

	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Gerar .TXT" ACTION "GFES05TXT()"   OPERATION 11  ACCESS 0

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

	Local oModel     := Nil
	Local oView      := Nil
	Local oStructGW3 := FWFormStruct(1, "GW3")
	Local oStructGW4 := FWFormStruct(1, "GW4")
	Local oStructGW8 := FWFormStruct(1, "GW8", {|cCampo| BscStrGW8(cCampo)})

	//----------------------------------------------

	oStructGW3:AddField ("Aliquota PIS", "Aliquota PIS", "GW3_PCPIS" , "N", 12, 2/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("PIS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	oStructGW3:AddField ("Aliquota COFINS", "Aliquota COFINS", "GW3_PCCOFI", "N", 12, 2/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("COFINS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)

	// UF do Destinatário - Usado na integração com Protheus para gravar a UF Origem no Documento de Entrada
	oStructGW3:AddField ("UF Destinatario", "UF Destinatario", "GW3_UFDEST", "C", TamSX3("GU7_CDUF")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	oStructGW3:AddField ("UF Emissor", "UF Emissor", "GW3_UFEMIS", "C", TamSX3("GU7_CDUF")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	
	If GFXXB12117("GWJPRE")
		oStructGW4:AddField("OK", "OK", "_VALID", 'BT', 1, 0/*nDECIMAL*/, , /*bWHEN*/, /*@aVALUES*/, .F., /*{|| CORVALID(.T.)}*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	EndIf

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição

	oView := FWViewActive()
	oModel := MPFormModel():New("GFES005", , , ,) 
	// oModel:bPost := {|oModel| GFEA065VP(oModel, oView)} 
	// oModel:SetVldActivate ( { |oMod| GFEA065VL( oMod ) } )

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFES005_GW3", Nil, oStructGW3, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"GW3_FILIAL", "GW3_CDESP", "GW3_EMISDF", "GW3_SERDF", "GW3_NRDF", "GW3_DTEMIS"})

	oModel:AddGrid("GFES005_GW4","GFES005_GW3", oStructGW4, {|oMod| G065GW4VPR(oMod)}, {|oMod| GFE065PreT(oMod), G065GW4VP(oMod)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid("GFES005_GW8","GFES005_GW4", oStructGW8, , , /*bPreVal*/, /*bPosVal*/,  {|oMod| GFEA065GW8(oMod)} )
	oModel:GetModel('GFES005_GW8'):SetOptional(.T.)
	oModel:GetModel('GFES005_GW8'):SetOnlyQuery(.T.)
	If !IsBlind()
		oModel:GetModel("GFES005_GW4"):SetMaxLine(9999)
	EndIf
	oModel:GetModel("GFES005_GW4"):SetUniqueLine({"GW4_EMISDC","GW4_SERDC","GW4_NRDC","GW4_TPDC"})
	oModel:GetModel("GFES005_GW4"):SetDelAllLine( .T. )

	oModel:GetModel("GFES005_GW8"):SetDescription("Itens")
	oModel:GetModel("GFES005_GW8"):SetUniqueLine({"GW8_CDTPDC","GW8_EMISDC","GW8_SERDC","GW8_NRDC","GW8_SEQ"})
	oModel:SetOptional("GFES005_GW4", .T. )

	oModel:SetRelation("GFES005_GW4",{{"GW4_FILIAL","xFilial('GW4')"},{"GW4_CDESP","GW3_CDESP"},{"GW4_EMISDF","GW3_EMISDF"},{"GW4_SERDF","GW3_SERDF"},{"GW4_NRDF","GW3_NRDF"},{"GW4_DTEMIS","GW3_DTEMIS"}},"GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+GW4_DTEMIS")
	oModel:SetRelation("GFES005_GW8",{{"GW8_FILIAL","xFilial('GW8')"},{"GW8_CDTPDC","GW4_TPDC"},{"GW8_EMISDC","GW4_EMISDC"},{"GW8_SERDC","GW4_SERDC"},{"GW8_NRDC","GW4_NRDC"}},"GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC")

	oModel:SetActivate({|oMod| GFEA65ACT(oMod)})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

	Local oModel     := FWLoadModel("GFES005")
	Local oView      := Nil
	Local oStructGW3 := FWFormStruct(2, "GW3")
	Local oStructGW4 := FWFormStruct(2, "GW4")
	Local lCpoTES    := GFEA065INP()

 	oStructGW3:AddField("GW3_PCPIS" , AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASPIS"})][2]) + 1)), "Aliquota PIS", "", {"Aliquota PIS"}, "N", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/)
	oStructGW3:AddField("GW3_PCCOFI", AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASCOF"})][2]) + 1)), "Aliquota COFINS", "", {"Aliquota COFINS"}, "N", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) 

 	oStructGW3:AddGroup("GrpId" , "Identificação", "1", 2)
	oStructGW3:AddGroup("GrpOri", "Origem/Destino", "1", 2)
	oStructGW3:AddGroup("GrpVal", "Valores", "1", 2)
	oStructGW3:AddGroup("GrpDtC", "Dados da Carga", "1", 2)
	oStructGW3:AddGroup("GrpImp", "Impostos", "1", 2)
	oStructGW3:AddGroup("GrpCom", "Complementos", "1", 2)

	If lCpoTES
		oStructGW3:AddGroup("GrpInt",	"Geral"	  , "2", 2) 
		oStructGW3:AddGroup("GrpDS"	, 	"Datasul" , "2", 2) 
		oStructGW3:AddGroup("GrpProt",	"Protheus"	, "2", 2) 
		oStructGW3:AddGroup("GrpMLA",   "MLA"     , "2", 2)
		oStructGW3:AddGroup("GrpAudit", "Auditoria", "3", 2) 
		If GFXCP12127("GW3_VLDIV")
			oStructGW3:AddGroup("GrpDiv", "Divergência", "3", 2) 
		Endif
		oStructGW3:AddGroup("GrpDFt", "Dados da Fatura", "4", 2)
		oStructGW3:AddGroup("GrpFtA", "Faturamento Avulso", "4", 2)
		oStructGW3:AddGroup("GrpCsg", "Consignatário", "5", 2)
		oStructGW3:AddGroup("GrpDFO", "Documento de Frete de Origem", "5", 2)
	Else
		oStructGW3:AddGroup("GrpAudit", "Auditoria", "2", 2)
		If GFXCP12127("GW3_VLDIV")
			oStructGW3:AddGroup("GrpDiv", "Divergência", "2", 2)
		Endif
		oStructGW3:AddGroup("GrpDFt", "Dados da Fatura", "3", 2)
		oStructGW3:AddGroup("GrpFtA", "Faturamento Avulso", "3", 2)
		oStructGW3:AddGroup("GrpCsg", "Consignatário", "4", 2)
		oStructGW3:AddGroup("GrpDFO", "Documento de Frete de Origem", "4", 2)
		oStructGW3:AddGroup("GrpInt", "Integrações", "4", 2)
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
	oView:AddField("GFES005_GW3", oStructGW3)

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
	
	If GFXXB12117("GWJPRE")
		oStructGW4:AddField( "_VALID"  ,'00' , "OK"          , "OK"      , {} , 'BT' ,'@BMP', NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T. )
	EndIf

	oStructGW4:RemoveField("GW4_FILIAL")
	oStructGW4:RemoveField("GW4_CDESP")
	oStructGW4:RemoveField("GW4_EMISDF")
	oStructGW4:RemoveField("GW4_SERDF")
	oStructGW4:RemoveField("GW4_NRDF")
	oStructGW4:RemoveField("GW4_DTEMIS")
	oView:AddGrid("GFES005_GW4", oStructGW4)

	oView:CreateHorizontalBox("MASTER", 55)
	oView:CreateHorizontalBox("DETAIL", 45)

	oView:CreateFolder("IDFOLDER", "DETAIL")
	oView:AddSheet("IDFOLDER", "IDSHEET01", "Documentos de Carga")

	oView:CreateVerticalBox("EMBAIXOESQ", 90,,, "IDFOLDER", "IDSHEET01")
	oView:CreateVerticalBox("EMBAIXODIR", 10,,, "IDFOLDER", "IDSHEET01")

	oView:SetOwnerView( "GFES005_GW3" , "MASTER"     )
	oView:SetOwnerView( "GFES005_GW4" , "EMBAIXOESQ" )

	oView:AddOtherObject("OTHER_PANEL", {|oPanel,oModel| GFEA065ADD(oPanel,oModel)})
	oView:SetOwnerView("OTHER_PANEL","EMBAIXODIR")
	If GFXXB12117("GWJPRE")
		oView:AddUserButton('Legenda','',{|| LEGVALID() })
	EndIf

Return oView

Static Function LEGVALID()
	Local aLegenda := {}		
	Local cTitulo  := ""
	
	cTitulo  := "Status do registro"
	Aadd(aLegenda,{"BR_VERMELHO", "Inválido"})
	Aadd(aLegenda,{"BR_VERDE" , "Válido"})
	BrwLegenda(cTitulo, "Legenda", aLegenda)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES05TXT
Montagem de arquivo .txt com base nos parametros do fonte GFEA065

@author Ana Claudia da Silva
@since 03/10/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFES05TXT()

	Local nHandle
	Local cFile
	Local oModelGW4
	Local nCont := 1 
	Local cCdRem    
	Local cNmRem    
	Local cNmDest   
	Local cNrDoc1   
	Local cNrDoc    
	Local cSrDoc    
	Local cCfop     
	Local nPeso     
	Local cCdTrp    
	Local cNmTrp    
	Local chrmn     
	Local cHora     
	Local cMin      
	Local cData     
	Local cDataD    
	Local cDataM    
	Local cDataA    
	Local cDataA1   
	Local cSrDC     
	Local cValor    
	Local cVlICMS   
	Local cFrValor  
	Local nPesoFr   
	Local cAlIMP    
	Local nCte      
	Local cTpFret   
	Local cTpTrib   
	Local cZeros1   
	Local cZeros    
	Local cZeroNF1  
	Local cZeroNF   
	Local cZeroSr   
	Local cNumCid   
	Local cFil322   
	Local cNrDc  
	Private aSrDC	:= Array(40)
	Private aNrDc1	:= Array(40)
	Private aNrDc	:= Array(40)

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	oModel    := FWLoadModel( "GFES005" )
	oModelGW4 := oModel:getModel("GFES005_GW4")

	If Pergunte("GFEA115",.T.)
		dbSelectArea("GW4")
		dbSetOrder(1)
			If dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
				
				dbSelectArea("GW1")
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek(xFilial("GW1") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )
					
				
				dbSelectArea("GW3")
				dbSetOrder(10)
				If dbSeek(GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_SERDF+GW4->GW4_NRDF)
											
					//Doc Frete
					cCdTrp   := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_IDFED")
					cNmTrp   := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_NMEMIT")
					cCdRem    := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_CDREM ,"GU3_IDFED")
					cNmRem    := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_CDREM ,"GU3_NMEMIT")
					cNmDest   := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_CDDEST,"GU3_NMEMIT")
					cNrDoc1   := PADL(Alltrim(Transform((GW3->GW3_NRDF), '@R 9999999999999999')),16,"0")
					cNrDoc    := SUBSTR(cNrDoc1,5,16)
					cSrDoc    := GW3->GW3_SERDF
					cCfop     := GW3->GW3_CFOP
					nPeso     := PADL(Alltrim(Transform((GW3->GW3_PESOR*100), '@R 9999999')),7,"0")
	
					//Transportador
					dbSelectArea("GWU")
					GWU->( dbSetOrder(1) )
					GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC +GW1->GW1_NRDC ) )

	
					//Hora Importação
					chrmn     := Time()
					cHora     := SUBSTR(chrmn,1,2)
					cMin      := SUBSTR(chrmn,4,2)
	
					//Data Emissão
					cData     := DTOC(GW4->GW4_DTEMIS)
					cDataD    := SUBSTR(cdata,1,2)
					cDataM    := SUBSTR(cdata,4,2)
					cDataA    := SUBSTR(cdata,9,2)
					cDataA1   := SUBSTR(cdata,7,4)
					cSrDC     := GW4->GW4_SERDC
					//Valores
					cValor    := PADL(Alltrim(Transform((GW3->GW3_VLDF*100), '@R 999999999999999')),15,"0")
	
					cVlICMS   := PADL(Alltrim(Transform((GW3->GW3_VLIMP*100), '@R 999999999999999')),15,"0")
	
					cFrValor  := PADL(Alltrim(Transform((GW3->GW3_FRVAL*100), '@R 999999999999999')),15,"0")
	
					nPesoFr   := PADL(Alltrim(Transform((GW3->GW3_FRPESO*100), '@R 999999999999999')),15,"0")
	
					//Alicota
					cAlIMP    := PADL(Alltrim(Transform((GW3->GW3_PCIMP*100), '@R 9999')),4,"0")
	
					// Chave CTe
					If !Empty(GW3->GW3_CTE)
						nCte  := AllTrim(GW3->GW3_CTE)
					Else
						nCte  := ''
					EndIf
	
					If GW1->GW1_TPFRET == '3' .OR. GW1->GW1_TPFRET == '4'
						cTpFret   := "F"//FOB
					Else
						cTpFret   := "C"//CIF
					EndIf
	
					If GW3->GW3_TRBIMP == '3'
						cTpTrib   := "1"//3=Subs Tributaria
					Else
						cTpTrib   := "2"//1=Tributado;2=Isento/Nao-tributado;4=Diferido;5=Reduzido;6=Outros;7=Presumido
					EndIf
	
					cZeros1   := 0
					cZeros    := STRZERO(cZeros1, 105, 0)
	
					cZeroNF1  := 0
					cZeroNF   := STRZERO(cZeroNF1, 8, 0)
	
					cZeroSr   := ''
	
					cNumCid   := POSICIONE("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3_NRCID")
					cFil322   := POSICIONE("GU7",1,xFilial("GU7")+cNumCid,"GU7_CDUF")
				EndIf
			EndIf 
		EndIf 
	
		//Seleciona um ou mais documentos de carga relacionados
		dbSelectArea("GW3")
		dbSetOrder(10)
		If dbSeek(GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_SERDF+GW4->GW4_NRDF)
			dbSelectArea("GW4")
			dbSetOrder(1)		
	 		If dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))		 	
				dbSelectArea("GW1")
				dbSetOrder(1)    			
				while dbSeek(xFilial("GW1") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC)
					For nCont:= 1 to 40
						If((GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) == xFilial("GW1") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC)												                                                                                                													
							cNrDc   := PADL(Alltrim(Transform((GW4->GW4_NRDC), '@R 9999999999999999')),16,"0")
							aNrDc[nCont] := SUBSTR(cNrDc,9,16)
							aSrDC[nCont] := GW4->GW4_SERDC	
							GW1->( dbSkip() )
							GW4->( dbSkip() )
						Else
							aNrDc[nCont] :="00000000"	
						EndIf
						If nCont == 40						
							Exit							
						EndIf	
					Next nCont	+1	
					Exit	
					GW1->( dbSkip() )	
				Enddo
			EndIf
		EndIf 	
		
		cDiretorio  := AllTrim(MV_PAR03)
		cFile := cDiretorio + "\"+ "Conemb"+AllTrim(cNrDoc)+".TXT"
	
		nHandle := fCreate(cFile)
		If nHandle == -1
			MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
			Return
		EndIf
	
		fWrite(nHandle,"000" + PADR( cNmRem, 35 )+ PADR( cNmDest, 35 )+ PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cDataA, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "CON" + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "0"  + PADR( " ", 585 )+ CRLF)
		fWrite(nHandle,"320" + "CONHE" + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "0" + PADR( " ", 663 )+ CRLF )
		fWrite(nHandle,"321" + PADR( cCdTrp, 14 )+ PADR( cNmTrp, 40 )+ PADR( " ", 623 )+ CRLF )
		fWrite(nHandle,"322" + PADR( cFil322, 10 )+ PADR( cSrDoc, 5 )+ PADr( cNrDoc, 12 ) + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cDataA1, 4 ) + PADR( cTpFret, 1 ) + PADR( nPeso, 7 ) +  PADL( cValor, 15 )+  PADL( cValor, 15 )+ PADR( cAlIMP, 4 )+  PADL( cVlICMS, 15 )+ PADL( nPesoFr, 15 ) + PADL( cFrValor, 15 ) + PADR( cZeros, 75 ) +  PADR( cTpTrib, 1 ) +PADL( cSrDC, 3 ) + PADR( cCdTrp, 14 )+ PADR( cCdRem, 14 )+ PADR( aSrDC[1], 3 )+ PADR( aNrDc[1], 8 )+ PADL(aSrDC[2], 3 )+ PADR(aNrDc[2], 8 )+ PADL( aSrDC[3], 3 )+ PADR( aNrDc[3], 8 )+ PADL( aSrDC[4], 3 )+ PADR( aNrDc[4], 8 )+ PADL( aSrDC[5], 3 )+ PADR( aNrDc[5], 8 )+ PADL( aSrDC[6], 3 )+ PADR( aNrDc[6], 8 )+ PADL( aSrDC[7], 3 )+ PADR( aNrDc[7], 8 )+ PADL( aSrDC[8], 3 )+ PADR( aNrDc[8], 8 )+ PADL( aSrDC[9], 3 )+ PADR( aNrDc[9], 8 )+ PADL( aSrDC[10], 3 )+ PADR( aNrDc[10], 8 )+ PADL( aSrDC[11], 3 )+ PADR( aNrDc[11], 8 )+ PADL( aSrDC[12], 3 )+ PADR( aNrDc[12], 8 )+ PADL( aSrDC[13], 3 )+ PADR( aNrDc[13], 8 )+ PADL( aSrDC[14], 3 )+ PADR( aNrDc[14], 8 )+ PADR( aSrDC[15], 3 )+ PADR( aNrDc[15], 8 )+ PADR( aSrDC[16], 3 )+ PADR( aNrDc[16], 8 )+ PADR( aSrDC[17], 3 )+ PADR( aNrDc[17], 8 )+ PADR( aSrDC[18], 3 )+ PADR( aNrDc[18], 8 )+ PADR( aSrDC[19], 3 )+ PADR( aNrDc[19], 8 )+ PADR( aSrDC[20], 3 )+ PADR( aNrDc[20], 8 )+ PADR( aSrDC[21], 3 )+ PADR( aNrDc[21], 8 )+ PADR( aSrDC[22], 3 )+ PADR( aNrDc[22], 8 )+ PADR( aSrDC[23], 3 )+ PADR( aNrDc[23], 8 )+ PADR( aSrDC[24], 3 )+ PADR( aNrDc[24], 8 )+ PADR( aSrDC[25], 3 )+ PADR( aNrDc[25], 8 )+ PADR( aSrDC[26], 3 )+ PADR( aNrDc[26], 8 )+ PADR( aSrDC[27], 3 )+ PADR( aNrDc[27], 8 )+ PADR( aSrDC[28], 3 )+ PADR( aNrDc[28], 8 )+ PADR( aSrDC[29], 3 )+ PADR( aNrDc[29], 8 )+ PADR( aSrDC[30], 3 )+ PADR( aNrDc[30], 8 )+ PADR( aSrDC[31], 3 )+ PADR( aNrDc[31], 8 )+ PADR( aSrDC[32], 3 )+ PADR( aNrDc[32], 8 )+ PADR( aSrDC[33], 3 )+ PADR( aNrDc[33], 8 )+ PADR( aSrDC[34], 3 )+ PADR( aNrDc[34], 8 )+ PADR( aSrDC[35], 3 )+ PADR( aNrDc[35], 8 )+ PADR( aSrDC[36], 3 )+ PADR( aNrDc[36], 8 )+ PADR( aSrDC[37], 3 )+ PADR( aNrDc[37], 8 )+ PADR( aSrDC[38], 3 )+ PADR( aNrDc[38], 8 )+ PADR( aSrDC[39], 3 )+ PADR( aNrDc[39], 8 )+ PADR( aSrDC[40], 3 )+ PADR( aNrDc[40], 8 )+"IN" + PADR( cCfop, 4 )+PADR( nCte, 45 ) + CRLF)
		Msginfo("Arquivo criado :" + cFile)
	
		IF !FCLOSE(nHandle)
			MsgAlert("Erro ao fechar arquivo. Erro número: " + STR(FERROR()))
		EndIf
	Else
		Return .F.
	EndIf
Return
