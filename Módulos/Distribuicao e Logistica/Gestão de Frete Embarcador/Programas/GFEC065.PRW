#INCLUDE "GFEC065.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC065
Consulta de Documentos de Frete                                                                                              
Uso Genérico.

@sample
GFEC065()

@author Fabiane Schulze
@since 21/05/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC065()
	Local oBrowse
	Private cTTRELAT
	Private aRotina := MenuDef()
	Public lFlagMov   := .F.
	Public cCdEspGw3  := ""
	Public cEmisDfGW3 := ""
	Public cSerDfGw3  := "" 
	Public nNrDfGw3   := 0
	Public dDtEmisGw3
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW3")										// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC065")								// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse    //"Consulta de Documentos de Frete"
	
	oBrowse:AddLegend("GW3_SIT=='1'", "WHITE", STR0002) //"Recebido"
	oBrowse:AddLegend("GW3_SIT=='2'", "RED",   STR0003) //"Bloqueado"
	oBrowse:AddLegend("GW3_SIT=='3'", "BLUE",  STR0004) //"Aprovado pelo Sistema"
	oBrowse:AddLegend("GW3_SIT=='4'", "GREEN", STR0005)	//"Aprovado pelo Usuário"
	oBrowse:AddLegend("GW3_SIT=='5'", "YELLOW", STR0048) //"Bloqueado por Entrega"
	
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}   
	
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar" //"Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC065" OPERATION 2 ACCESS 0 //"Visualizar" //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA066AP(.F.)"  OPERATION 4 ACCESS 0 //"Conferencia" //"Conferencia"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEC065" OPERATION 8 ACCESS 0 //"Imprimir" //"Imprimir"
	ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "MsDocument('GW3',GW3->(RecNo()), 2)" OPERATION 2  ACCESS 0 
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStructGW3 := FWFormStruct(1, "GW3")
Local oStructGW4 := FWFormStruct(1, "GW4")
Local oStructGWA := FWFormStruct(1, "GWA")
Local oStructGW6 := FWFormStruct(1, "GW6")
Local oStructGWC

If GFXTB12117("GWC")
	oStructGWC := FWFormStruct(1, "GWC")
EndIf

oModel := MPFormModel():New("GFEC065",,,, /*bCancel*/)

oStructGW3:AddField (STR0044, STR0044, "GW3_PCPIS" , "N", 12, 4/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("PIS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/) //"Aliquota PIS"
oStructGW3:AddField (STR0045, STR0045, "GW3_PCCOFI", "N", 12, 4/*nDECIMAL*/, /*bVALID*/, {||.F.}/*bWHEN*/, /*@aVALUES*/, .F., {||GFEA065PCD("COFINS")}/*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/) //"Aliquota COFINS"

oModel:AddFields("GFEC065_GW3", Nil, oStructGW3, /*bPre*/ ,/**/,/*bLoad*/)
oModel:SetPrimaryKey({"GW3_FILIAL", "GW3_CDESP", "GW3_EMISDF", "GW3_SERDF", "GW3_NRDF", "GW3_DTEMIS"})

oModel:AddGrid("GFEC065_GW4","GFEC065_GW3", oStructGW4,,, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GFEC065_GW4",{{"GW4_FILIAL","xFilial('GW4')"},{"GW4_CDESP","GW3_CDESP"},{"GW4_EMISDF","GW3_EMISDF"},{"GW4_SERDF","GW3_SERDF"},{"GW4_NRDF","GW3_NRDF"},{"GW4_DTEMIS","GW3_DTEMIS"}},"GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+GW4_DTEMIS")

oModel:AddGrid("GFEC065_GWA","GFEC065_GW3", oStructGWA,,, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GFEC065_GWA",{{"GWA_FILIAL","xFilial('GWA')"},{"GWA_TPDOC","'2'"},{"GWA_CDESP","GW3_CDESP"},{"GWA_CDEMIT","GW3_EMISDF"},{"GWA_SERIE","GW3_SERDF"},{"GWA_NRDOC","GW3_NRDF"},{"GWA_DTEMIS","GW3_DTEMIS"}},"GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+GWA_DTEMIS")

oModel:AddGrid('GFEC065_GW6','GFEC065_GW3',oStructGW6,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('GFEC065_GW6',{{'GW6_FILIAL','GW3_FILIAL'},{'GW6_EMIFAT' ,'GW3_EMIFAT' },{'GW6_SERFAT' ,'GW3_SERFAT' },{'GW6_NRFAT' ,'GW3_NRFAT' },{'GW6_DTEMIS' ,'GW3_DTEMFA' }},'GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT')

If GFXTB12117("GWC")
	oModel:AddGrid('GFEC065_GWC','GFEC065_GW3',oStructGWC,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation('GFEC065_GWC',{{'GWC_FILIAL','GW3_FILIAL'},{'GWC_CDESP' ,'GW3_CDESP' },{'GWC_EMISDF' ,'GW3_EMISDF' },{'GWC_SERDF' ,'GW3_SERDF'},{'GWC_NRDF' ,'GW3_NRDF'},{'GWC_DTEMIS' ,'GW3_DTEMIS'}},"GWC_FILIAL+GWC_CDESP+GWC_EMISDF+GWC_SERDF+GWC_NRDF+GWC_DTEMIS")
EndIf

oModel:SetActivate({|oMod| GFEC065ACT(oMod)} )

Return oModel 
                            
Static Function ViewDef()
Local oModel := FWLoadModel("GFEC065")
Local oView := Nil
Local oStructGW3 := FWFormStruct(2,"GW3")
Local oStructGW4 := FWFormStruct(2,"GW4")
Local oStructGWA := FWFormStruct(2,"GWA")
Local oStructGWC
Local lCpoTES		:= GFEA065INP()

If GFXTB12117("GWC")
	oStructGWC := FWFormStruct(2, "GWC")
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)

oStructGW3:AddField("GW3_PCPIS" , AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASPIS"})][2]) + 1)), STR0044, "", {STR0044}, "N", "@E 999,999,999.9999", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) // "Aliquota PIS"
oStructGW3:AddField("GW3_PCCOFI", AllTrim(Str(Val(oStructGW3:GetFields()[AScan(oStructGW3:GetFields(), {|x| x[1] == "GW3_BASCOF"})][2]) + 1)), STR0045, "", {STR0045}, "N", "@E 999,999,999.9999", /*bPICTVAR*/, /*cLOOKUP*/, /*lCANCHANGE*/, "1"/*cFOLDER*/, "GrpImp"/*cGRUP*/, /*@aCOMBOVALUES*/, /*nMAXLENCOMBO*/, " ", .T./*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) // "Aliquota COFINS"

oStructGW3:AddGroup("GrpId" , STR0035, "1", 2) // "Identificação"
oStructGW3:AddGroup("GrpOri", STR0036, "1", 2) // "Origem/Destino"
oStructGW3:AddGroup("GrpVal", STR0037, "1", 2) // "Valores"
oStructGW3:AddGroup("GrpDtC", STR0038, "1", 2) // "Dados da Carga"
oStructGW3:AddGroup("GrpImp", STR0039, "1", 2) // "Impostos"
oStructGW3:AddGroup("GrpCom", STR0040, "1", 2) // "Complementos"

If lCpoTES
	oStructGW3:AddGroup("GrpInt",	"Geral"	  , "2", 2) // "Geral"
	oStructGW3:AddGroup("GrpDS"	, 	"Datasul" , "2", 2) // "Datasul"

	If SuperGetMv("MV_ERPGFE", .F., "2") == "2"
		oStructGW3:AddGroup("GrpProt",	"Protheus"	, "2", 2) // "Protheus"
	EndIf
	
	oStructGW3:AddGroup("GrpMLA",   "MLA"     , "2", 2)
	
	oStructGW3:AddGroup("GrpAudit", "Auditoria", "3", 2) // "Auditoria"
	
	If GFXCP12127("GW3_VLDIV")
		oStructGW3:AddGroup("GrpDiv", "Divergência", "3", 2) // "Divergência"
	Endif
	
	oStructGW3:AddGroup("GrpDFt", STR0046, "4", 2) // "Dados da Fatura"
	oStructGW3:AddGroup("GrpFtA", STR0047, "4", 2) // "Faturamento Avulso"

	oStructGW3:AddGroup("GrpCsg", STR0041, "5", 2) // "Consignatário"
	oStructGW3:AddGroup("GrpDFO", STR0042, "5", 2) // "Documento de Frete de Origem"
	
Else
	oStructGW3:AddGroup("GrpAudit", "Auditoria", "2", 2) // "Auditoria"
	
	If GFXCP12127("GW3_VLDIV")
		oStructGW3:AddGroup("GrpDiv", "Divergência", "2", 2) // "Divergência"
	Endif

	oStructGW3:AddGroup("GrpDFt", STR0046, "3", 2) // "Dados da Fatura"
	oStructGW3:AddGroup("GrpFtA", STR0047, "3", 2) // "Faturamento Avulso"

	oStructGW3:AddGroup("GrpCsg", STR0041, "4", 2) // "Consignatário"
	oStructGW3:AddGroup("GrpDFO", STR0042, "4", 2) // "Documento de Frete de Origem"
	oStructGW3:AddGroup("GrpInt", STR0043, "4", 2) // "Integrações"
EndIf

oStructGW3:RemoveField("GW3_DSOFUM")
oStructGW3:RemoveField("GW3_DSOFCF")
oStructGW3:RemoveField("GW3_DSOFCT")
oStructGW3:RemoveField("GW3_DSOFCS")

oView:AddField( "GFEC065_GW3" , oStructGW3 )

oStructGW4:RemoveField("GW4_FILIAL")
oStructGW4:RemoveField("GW4_CDESP")
oStructGW4:RemoveField("GW4_EMISDF")
oStructGW4:RemoveField("GW4_SERDF")
oStructGW4:RemoveField("GW4_NRDF")
oStructGW4:RemoveField("GW4_DTEMIS")

oView:AddGrid( "GFEC065_GW4" , oStructGW4) 

oStructGWA:RemoveField("GWA_TPDOC")
oStructGWA:RemoveField("GWA_CDESP")
oStructGWA:RemoveField("GWA_CDEMIT")
oStructGWA:RemoveField("GWA_NMEMIT")
oStructGWA:RemoveField("GWA_SERIE")
oStructGWA:RemoveField("GWA_NRDOC")
oStructGWA:RemoveField("GWA_DTEMIS")
oStructGWA:RemoveField("GWA_CODEST")
oView:AddGrid( "GFEC065_GWA" , oStructGWA) 

If GFXTB12117("GWC")
	oStructGWC:RemoveField("GWC_FILIAL")
	oStructGWC:RemoveField("GWC_CDESP")
	oStructGWC:RemoveField("GWC_EMISDF")
	oStructGWC:RemoveField("GWC_SERDF")
	oStructGWC:RemoveField("GWC_NRDF")
	oStructGWC:RemoveField("GWC_DTEMIS")
	oView:AddGrid( "GFEC065_GWC" , oStructGWC) 
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
if GFXCP12117("GW3_CDTPSE")
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

If GFXCP2510('GW3_BASIBS') .And. GFXCP2510('GW3_PCIBS') .And. GFXCP2510('GW3_VLIBS')
	oStructGW3:SetProperty("GW3_BASIBS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_PCIBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_VLIBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
EndIf

If GFXCP2510('GW3_BASCBS') .And. GFXCP2510('GW3_VLCBS')
	oStructGW3:SetProperty("GW3_BASCBS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_PCCBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW3:SetProperty("GW3_VLCBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
EndIf

oStructGW3:SetProperty("GW3_OBS"   , MVC_VIEW_GROUP_NUMBER, "GrpCom")
oStructGW3:SetProperty("GW3_CTE"   , MVC_VIEW_GROUP_NUMBER, "GrpCom")
oStructGW3:SetProperty("GW3_TPCTE" , MVC_VIEW_GROUP_NUMBER, "GrpCom")
If GFXCP12137('GW3_FILTOM')
	oStructGW3:SetProperty("GW3_FILTOM" , MVC_VIEW_GROUP_NUMBER, "GrpCom")
EndIf
If GFXCP2510('GW3_XMLTRB')
	oStructGW3:SetProperty("GW3_XMLTRB" , MVC_VIEW_GROUP_NUMBER, "GrpCom")
EndIf

oStructGW3:SetProperty("GW3_FILFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
oStructGW3:SetProperty("GW3_EMIFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
oStructGW3:SetProperty("GW3_SERFAT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
oStructGW3:SetProperty("GW3_NRFAT" , MVC_VIEW_GROUP_NUMBER, "GrpDFt")
oStructGW3:SetProperty("GW3_DTEMFA", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
if GFXCP12117("GW3_DTVCFT")
	oStructGW3:SetProperty("GW3_DTVCFT", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
EndIf
If GFXCP12117("GW3_MOTFIN")
	oStructGW3:SetProperty("GW3_SITFIN", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_DTFIN" , MVC_VIEW_GROUP_NUMBER, "GrpDFt")
	oStructGW3:SetProperty("GW3_MOTFIN", MVC_VIEW_GROUP_NUMBER, "GrpDFt")
EndIf

oStructGW3:SetProperty("GW3_DTVNFT", MVC_VIEW_GROUP_NUMBER, "GrpFtA")

oStructGW3:SetProperty("GW3_CDCONS", MVC_VIEW_GROUP_NUMBER, "GrpCsg")	
oStructGW3:SetProperty("GW3_NMCONS", MVC_VIEW_GROUP_NUMBER, "GrpCsg")

oStructGW3:SetProperty("GW3_ORINR" , MVC_VIEW_GROUP_NUMBER, "GrpDFO")
oStructGW3:SetProperty("GW3_ORISER", MVC_VIEW_GROUP_NUMBER, "GrpDFO")
oStructGW3:SetProperty("GW3_ORIDTE", MVC_VIEW_GROUP_NUMBER, "GrpDFO")

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

if SuperGetMv("MV_ERPGFE", .F., "2") == "1" .and. lCpoTES
	oStructGW3:RemoveField("GW3_PRITDF")
	oStructGW3:RemoveField("GW3_TES")
	oStructGW3:RemoveField("GW3_CONTA")
	oStructGW3:RemoveField("GW3_ITEMCT")
	oStructGW3:RemoveField("GW3_CC")
	oStructGW3:RemoveField("GW3_CPDGFE")
endif

If GFXCP2510('GW3_XMLTRB')
	oStructGW3:RemoveField("GW3_XMLTRB")
EndIf

oView:CreateHorizontalBox( "MASTER" , 55)
oView:CreateHorizontalBox( "DETAIL" , 45 )  

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0019) //"Documentos de Carga"
oView:AddSheet("IDFOLDER","IDSHEET02","Lançamentos Contábeis"/*STR0034*/) //"Movimentos Contábeis"
If GFXTB12117("GWC")
	oView:AddSheet("IDFOLDER","IDSHEET03","Custo de Frete") //"Custo de Frete"
EndIf
oView:CreateHorizontalBox("EMBAIXOESQ", 100,,,"IDFOLDER","IDSHEET01")
oView:CreateHorizontalBox("EMBAIXOMEI", 100,,,"IDFOLDER","IDSHEET02")
If GFXTB12117("GWC")
	oView:CreateHorizontalBox("EMBAIXODIR", 100,,,"IDFOLDER","IDSHEET03")
EndIf

oView:SetOwnerView("GFEC065_GW3", "MASTER"    )
oView:SetOwnerView("GFEC065_GW4", "EMBAIXOESQ")
oView:SetOwnerView("GFEC065_GWA", "EMBAIXOMEI") 
If GFXTB12117("GWC")
	oView:SetOwnerView("GFEC065_GWC", "EMBAIXODIR")
EndIf
    
oView:AddUserButton("Cons. Doc. Carga", "MAGIC_BMP", {|oView| GFEC065CDC(oView)}, ) 
oView:AddUserButton("Cons. Fatura", "MAGIC_BMP", {|oView| GFEC065FR(oView)}, ) 
If GFXCP2510('GW3_XMLTRB')
    oView:AddUserButton("Impostos XML", "MAGIC_BMP", {|oView| GFEC65IMP(oView)}, ) 
    oView:AddUserButton("Visualizar XML", "MAGIC_BMP", {|oView| GFEC65XML(oView)}, ) 
EndIf
Return oView
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC065CDC
Consulta de Doc. Carga
Generico

@author Ana Claudia da Silva	
@since 07/03/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEC065CDC(oView)
	
	Local oModel		:= oView:GetModel()
	Local oModelGW4 	:= oModel:GetModel("GFEC065_GW4")
	Local nLine		:= oModelGW4:GetLine()

	dbSelectArea("GW4")
	GW4->( dbSetOrder(2) )
	If GW4->( dbSeek(xFilial("GW4") + FWFldGet("GW4_EMISDC", nLine) + FWFldGet("GW4_SERDC", nLine) + FWFldGet("GW4_NRDC", nLine) + FWFldGet("GW4_TPDC", nLine)) )

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		IF GW1->( dbSeek(xFilial("GW1") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )	
			FWExecView("Visualiza", "GFEC040", 1,,{|| .T.})
		Else 
			MsgInfo("Não existe Documento de Carga relacionado ao Documento de Frete.")		
		EndIf
		
	Endif 
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC065FR
Consulta de Fatura de Frete
Generico

@author Carlos Augusto Pereira	
@since 26/09/2016
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEC065FR(oView)
	Local oModel	:= oView:GetModel()
	Local oModelGW6 := oModel:GetModel("GFEC065_GW6")
	Local nLine		:= oModelGW6:GetLine()

	dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	If GW6->( dbSeek(xFilial("GW6") + FwFldGet("GW6_EMIFAT", nLine) + FwFldGet("GW6_SERFAT", nLine) + FwFldGet("GW6_NRFAT", nLine) + ;
				DToS(FwFldGet("GW6_DTEMIS", nLine))))
		FWExecView("Frete Embarcador",'GFEC070', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 
	Else
		MsgInfo("Não existe Fatura de Frete relacionada ao Documento de Frete.")	
	Endif 
return 

//---------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC065ACT
Pre Validação da visualização do Documento de Frete
@type function
@version 12.1.31
@author 
@since 12/01/2021
/*/
//---------------------------------------------------------------------------------------------------------
Function GFEC065ACT(oModel)
	Local lRet        := .T.
	Local lExistCamp  := GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM")

	Local nOperation  := oModel:GetOperation()

	If nOperation == 1 .And. lExistCamp

		GW3->( dbSetOrder(1) )
		If GW3->( dbSeek(xFilial("GW3") + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DTos(GW3->GW3_DTEMIS)) ) .And. ;
		        (Empty(GW3->GW3_MUNINI) .Or. Empty(GW3->GW3_UFINI) .Or. Empty(GW3->GW3_MUNFIM) .Or. Empty(GW3->GW3_UFFIM))

			aAuxCid := GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF)
			If Len(aAuxCid) > 0
				oModel:LoadValue("GFEC065_GW3",'GW3_MUNINI', Alltrim(aAuxCid[1][1]) )												// Município Início Transporte
				oModel:LoadValue("GFEC065_GW3",'GW3_UFINI' , Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][1], "GU7_CDUF") )	// UF Início do Transporte
				oModel:LoadValue("GFEC065_GW3",'GW3_MUNFIM', Alltrim(aAuxCid[1][2]) )												// Município Término do Transporte
				oModel:LoadValue("GFEC065_GW3",'GW3_UFFIM' , Posicione("GU7", 1, xFilial("GU7") + aAuxCid[1][2], "GU7_CDUF") )	// UF Término do Transporte
			EndIf
		EndIf
	EndIf

Return lRet


Function GFEC65XML(oView)
    Local oXml
	Local oDlgXml
    Local nJanAltu  := 720
    Local nJanLarg  := 1080
    Local cFile     := Nil
	Local oFileXML  := Nil
    Local cBARRAS   := If(isSRVunix(),"/","\")
	Local cContent  := Alltrim(GW3->GW3_XMLTRB)
    Local cRootPath := Alltrim(GetSrvProfString("RootPath",cBARRAS))

    If !GFXCP2510('GW3_XMLTRB')
        MsgInfo("Atualize o dicionario de dados do ambiente para visualizar os dados de impostos do XML.")
        Return
    EndIf

    If Right(AllTrim(cRootPath),1) != cBARRAS
		cRootPath := AllTrim(cRootPath) + cBARRAS
    EndIf
    If !ExistDir(cRootPath+"temp")
        MakeDir(cRootPath+"temp")
    EndIf

    cFile := cRootPath + "temp" + cBARRAS + "GFEA065_" + Alltrim(GW3->GW3_NRDF) + "_" + strtran(time(),":") + ".xml"
    If !File(cFile)
		oFileXML := FCREATE(cFile)
		If oFileXML > 0
			FWrite(oFileXML, cContent)
			FClose(oFileXML)
		EndIf
    EndIf

    Define Dialog oDlgXml Title "Visualizador de XML CT-e" From 180,180 To nJanAltu,nJanLarg Pixel

    oXml := TXMLViewer():New(0, 0, oDlgXml , cFile, 455, 262, .T. )
    oXml:setXML(cFile)
    
    Activate Dialog oDlgXml Centered

    If File(cFile)
		FErase(cFile)
	EndIf

	oFileXML := Nil
	oXml     := Nil
Return

Function GFEC65IMP(oView)
	Local oDlgXml, oBrw
    Local aImp      := Nil
    Local nJanAltu  := 600
    Local nJanLarg  := 1280
	Local cContent  := Alltrim(GW3->GW3_XMLTRB)
    Local oTFont    := TFont():New('Courier new',,16,.T.)

    If !GFXCP2510('GW3_XMLTRB')
        MsgInfo("Atualize o dicionario de dados do ambiente para visualizar os dados de impostos do XML.")
        Return
    EndIf
    
    If Empty(cContent)
        MsgInfo("Documento de Frete não possui XML importado para consulta.")
        Return
    EndIf

    aImp := GFEImpXML(Alltrim(cContent))

    Define Dialog oDlgXml Title "Impostos XML CTe" From 180,180 To nJanAltu,nJanLarg Pixel

    oBrw := TWBrowse():New( 0, 0, (oDlgXml:nWidth-555), (oDlgXml:nHeight-237),,{'Tipo', 'CST', 'Base', 'Alíquota', 'Valor'}, {200, 20, 50, 30, 50}, oDlgXml,,,,{||},{||},{||},oTFont,,,,,,,.F.)
    oBrw:SetArray(aImp)
    oBrw:bLine := {||{	Alltrim(aImp[oBrw:nAt,01]), ;
                        Alltrim(aImp[oBrw:nAt,02]), ;
                        Transform(aImp[oBrw:nAt,03], "@E 9,999,999.99"), ;
                        Transform(aImp[oBrw:nAt,04], "@E 999.99"), ;
                        Transform(aImp[oBrw:nAt,05], "@E 9,999,999.99")}}  

    Activate Dialog oDlgXml Centered
    
Return
