#INCLUDE "GFEC040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Documentos de Carga
Uso Generico.

@sample
GFEC040()

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEC040()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW1")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC040")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Consulta de Documentos de Carga") // Descrição do browse Documentos de Carga

	oBrowse:AddLegend("GW1_SIT=='1'", "WHITE" , STR0002) //"Digitado "
	oBrowse:AddLegend("GW1_SIT=='2'", "YELLOW", STR0003) //"Bloqueado"
	oBrowse:AddLegend("GW1_SIT=='3'", "GRAY"  , STR0004) //"Liberado "
	oBrowse:AddLegend("GW1_SIT=='4'", "BLUE"  , STR0005) //"Embarcado"
	oBrowse:AddLegend("GW1_SIT=='5'", "GREEN" , STR0006) //"Entregue "
	oBrowse:AddLegend("GW1_SIT=='6'", "ORANGE", STR0007) //"Retornado"
	oBrowse:AddLegend("GW1_SIT=='7'", "RED"   , STR0008) //"Cancelado"

	oBrowse:Activate() 

Return(Nil)
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0009    ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0010    ACTION "VIEWDEF.GFEC040" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0012    ACTION "VIEWDEF.GFEC040" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructGW1 := FWFormStruct(1, "GW1")
	Local oStructGW8 := FWFormStruct(1, "GW8")
	Local oStructGWB := FWFormStruct(1, "GWB")
	Local oStructGWU := FWFormStruct(1, "GWU")
	Local oStructGXP := Nil
	Local oStructGWM := FWFormStruct(1, "GWM")
	Local oStructGWE := Nil
	Local oStructGWF := FWFormStruct(1, "GWF")
	Local oStructGWJ := FWFormStruct(1, "GWJ")
	Local oStructGWD := FWFormStruct(1, "GWD")
	Local oStructGW3 := FWFormStruct(1, "GW3")

	If GFXTB12117("GXP")
		oStructGXP := FWFormStruct(1, "GXP")
	EndIf

	If ChkFile("GWE")
		oStructGWE := FWFormStruct(1, "GWE")
	EndIf

	oStructGWF:AddField(STR0020, STR0021, "GWF_VALFRT", "C", 20, /*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, , /*lOBRIGAT*/, /*bINIT*/, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)

	oModel := MPFormModel():New("GFEC040", /*bPre*/,/*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields("GFEC040_GW1", Nil, oStructGW1, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"GW1_FILIAL", "GW1_CDTPDC", "GW1_EMISDC", "GW1_SERDC", "GW1_NRDC", "GW1_DTEMIS", "GW1_CDREM", "GW1_CDREM", "GW1_CDDEST", "GW1_DTIMPL", "GW1_CDREM", "GW1_TPFRET"})

	/*Itens*/
	oModel:AddGrid("GFEC040_GW8","GFEC040_GW1", oStructGW8,/*bLinePre*/,/*{|oMod| GF40_GW8PS(oMod)}*/,,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEC040_GW8",{{"GW8_FILIAL","GW1_FILIAL"},{"GW8_CDTPDC","GW1_CDTPDC"},{"GW8_EMISDC","GW1_EMISDC"},{"GW8_SERDC","GW1_SERDC"},{"GW8_NRDC","GW1_NRDC"}},"GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ")
	oModelGW8 = oModel:GetModel("GFEC040_GW8")
	oModelGW8:SetUniqueLine({"GW8_SEQ"})
	oModelGW8:SetDescription("GW8")

	/*Unitizadores*/                                                                	
	oModel:AddGrid("GFEC040_GWB","GFEC040_GW1", oStructGWB, /*bLinePre*/, , /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEC040_GWB",{{"GWB_FILIAL","GW1_FILIAL"},{"GWB_CDTPDC","GW1_CDTPDC"},{"GWB_EMISDC","GW1_EMISDC"},{"GWB_SERDC","GW1_SERDC"},{"GWB_NRDC","GW1_NRDC"}},"GWB_FILIAL+GWB_CDTPDC+GWB_EMISDC+GWB_SERDC+GWB_NRDC")
	oModelGWB = oModel:GetModel("GFEC040_GWB")
	oModelGWB:SetUniqueLine({"GWB_CDUNIT"})
	oModelGWB:SetDescription("GWB")
	oModelGWB:SetDelAllLine(.T.)

	oModel:SetOptional("GFEC040_GWB", .T. )

	/*Trechos*/
	oModel:AddGrid("GFEC040_GWU","GFEC040_GW1", oStructGWU, , , /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEC040_GWU",{{"GWU_FILIAL","GW1_FILIAL"},{"GWU_CDTPDC","GW1_CDTPDC"},{"GWU_EMISDC","GW1_EMISDC"},{"GWU_SERDC","GW1_SERDC"},{"GWU_NRDC","GW1_NRDC"}},"GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC")
	oModelGWU = oModel:GetModel("GFEC040_GWU")
	oModelGWU:SetUniqueLine({"GWU_SEQ"})
	oModelGWU:SetDescription("GWU")
	oModelGWU:cOrderBy := "GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ"

	If GFXTB12117("GXP")
		/*Documentos de origem*/
		oModel:AddGrid("GFEC040_GXP","GFEC040_GW1", oStructGXP,/*bLinePre*/,/*{|oMod| GFE44PSGWB(oMod)}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
		oModel:SetRelation("GFEC040_GXP",{{"GXP_FILIAL","xFilial('GXP')"},{"GXP_CDTPDC","GW1_CDTPDC"},{"GXP_EMISDC","GW1_EMISDC"},{"GXP_SERDC","GW1_SERDC"},{"GXP_NRDC","GW1_NRDC"}},GXP->(IndexKey(1)))
		oModelGXP = oModel:GetModel("GFEC040_GXP")
		oModelGXP:SetUniqueLine({"GXP_FILORI","GXP_EMIORI","GXP_SERORI","GXP_DOCORI"})
		oModelGXP:SetDescription("GXP")
		oModelGXP:SetDelAllLine(.T.)
		oModel:SetOptional("GFEC040_GXP", .T. )
	EndIf

	/*Calculos*/
	oModel:AddGrid("GFEC040_GWF","GFEC040_GW1", oStructGWF, , , /*bPre*/, /*bPost*/, {|oModelGWF| GFEC040LCL(oModelGWF)}/*bLoad*/)
	oModel:SetRelation("GFEC040_GWF",{{"GWF_FILIAL","GW1_FILIAL"}},"GWF_FILIAL+GWF_NRCALC")
	oModelGWF = oModel:GetModel("GFEC040_GWF")
	oModelGWF:SetDescription("GWF")

	/*Pre-faturas*/
	oModel:AddGrid("GFEC040_GWJ","GFEC040_GW1", oStructGWJ, , , /*bPre*/, /*bPost*/, {|oModelGWJ| GFEC040LPF(oModelGWJ)}/*bLoad*/)
	oModel:SetRelation("GFEC040_GWJ",{{"GWH_FILIAL",'GW1_FILIAL'}},"GWJ_FILIAL+GWJ_NRPF")
	oModelGWJ = oModel:GetModel("GFEC040_GWJ")
	oModelGWJ:SetDescription("GWJ")

	/*Ocorrencias*/
	oModel:AddGrid("GFEC040_GWD","GFEC040_GW1", oStructGWD, , , /*bPre*/, /*bPost*/, {|oModelGWD| GFEC040LOC(oModelGWD)}/*bLoad*/)
	oModel:SetRelation("GFEC040_GWD",{{"GWD_FILIAL","GW1_FILIAL"}},"GWD_FILIAL+GWD_NROCO")
	oModelGWD = oModel:GetModel("GFEC040_GWD")
	oModelGWD:SetDescription("GWD")

	/*Documentos de Frete*/
	oModel:AddGrid("GFEC040_GW3","GFEC040_GW1", oStructGW3, , , /*bPre*/, /*bPost*/, {|oModelGW3| GFEC040LDF(oModelGW3)}/*bLoad*/)
	oModel:SetRelation("GFEC040_GW3",{{"GW3_FILIAL","GW1_FILIAL"}},"GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)")
	oModelGW3 = oModel:GetModel("GFEC040_GW3")
	oModelGW3:SetDescription("GW3")

	/*Rateio Contabil de Frete*/
	oModel:AddGrid("GFEC040_GWM","GFEC040_GW1", oStructGWM, , , /*bPre*/, /*bPost*/, /*bLoad*/) 
	oModel:SetRelation("GFEC040_GWM",{{"GWM_FILIAL","GW1_FILIAL"},{"GWM_CDTPDC","GW1_CDTPDC"},{"GWM_EMISDC","GW1_EMISDC"},{"GWM_SERDC","GW1_SERDC"},{"GWM_NRDC","GW1_NRDC"}},"GWM_FILIAL+GWM_TPDOC+GWM_CDTRP")
	oModel:GetModel("GFEC040_GWM"):SetDescription("GWM")


	/*Relac Doc Carga GFE e Doc Transp TMS*/
	If ChkFile("GWE")
		oModel:AddGrid("GFEC040_GWE","GFEC040_GW1", oStructGWE, , , /*bPre*/, /*bPost*/, /*bLoad*/)
		oModel:SetRelation("GFEC040_GWE",{{"GWE_FILIAL","GW1_FILIAL"},{"GWE_CDTPDC","GW1_CDTPDC"},{"GWE_EMISDC","GW1_EMISDC"},{"GWE_SERDC","GW1_SERDC"},{"GWE_NRDC","GW1_NRDC"}},"GWE_FILIAL+GWE_EMISDC+GWE_SERDC")
		oModel:GetModel("GFEC040_GWE"):SetDescription("GWE")
	EndIf 

	/* Totalizadores dos campos da tabela GW8 */
	//Quantidade, Valor, Volume(m3), Peso Real, Peso Cubado e Qtd/Peso Alt ;
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_QTDE', 'TOTQTDE', 'SUM',,,'Tot Qtde' )
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_VALOR', 'TOTVALOR', 'SUM',,,'Tot Valor' )
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_VOLUME', 'TOTVOLUME', 'SUM',,,'Tot Volume' )
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_PESOR', 'TOTPESOR', 'SUM',,,'Tot Peso Real' )
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_PESOC', 'TOTPESOC', 'SUM',,,'Tot Peso Cubado' )
	oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_QTDALT', 'TOTQTDALT', 'SUM',,,'Tot Qtd/Peso Alt' )
	If GFXCP12118("GW8_VALLIQ")
		oModel:AddCalc('CALCGW8_QTDE', 'GFEC040_GW1', 'GFEC040_GW8', 'GW8_VALLIQ', 'TOTVALLIQ', 'SUM',,,'Tot Valor Líq' )
	EndIf

Return oModel

//---------------------------------------------------
Static Function ViewDef()
	Local nI,nX
	Local cCampos
	Local nUltOrd
	Local nPosBase
	Local cPosBase
	Local oModel     := FWLoadModel("GFEC040")
	Local oView      := Nil
	Local oStructGW1 := FWFormStruct(2,"GW1")
	Local oStructGW8 := FWFormStruct(2,"GW8")
	Local oStructGWB := FWFormStruct(2,"GWB")
	Local oStructGWU := FWFormStruct(2,"GWU")
	Local oStructGXP := Nil
	Local oStructGWF := FWFormStruct(2,"GWF")
	Local oStructGWJ := FWFormStruct(2,"GWJ")
	Local oStructGWD := FWFormStruct(2,"GWD")
	Local oStructGW3 := FWFormStruct(2,"GW3")
	Local oStructGWM := FWFormStruct(2,"GWM")
	Local oCalcGW8   := FWCalcStruct( oModel:GetModel( 'CALCGW8_QTDE') )
	Local oStructGWE := Nil
	Local aCampGWF   := {"GWF_NRCALC","GWF_TRANSP","GWF_NMTRP","GWF_EMIREM","GWF_NMREM","GWF_EMIDES","GWF_NMDEST","GWF_EMIRED","GWF_NMRED","GWF_EMIPAG",;
							"GWF_NMPAG","GWF_TPCALC","GWF_VALFRT","GWF_ORIGEM","GWF_TPFRET","GWF_FINCAL","GWF_CIDORI","GWF_NMCIOR","GWF_CIDDES","GWF_NMCIDE",;
							"GWF_ENDENT","GWF_BAIENT","GWF_CIDENT","GWF_DTCRIA","GWF_HRCRIA","GWF_USUCRI","GWF_DTPREN","GWF_HRPREN","GWF_CARREG","GWF_NRROM",;
							"GWF_VLAJUS","GWF_TPTRIB","GWF_BASISS","GWF_PCISS","GWF_VLISS","GWF_BASICM","GWF_PCICMS","GWF_PCREIC","GWF_VLICMS","GWF_ICMRET",;
							"GWF_BAPICO","GWF_VLPIS","GWF_VLCOFI","GWF_FILPRE","GWF_NRPREF","GWF_NRCONT","GWF_IDFRVI","GWF_AGRUP","GWF_SEQTRE","GWF_OBS",;
							"GWF_IMPOST"}

	If GFXTB12117("GXP")
		oStructGXP := FWFormStruct(2,"GXP")
	EndIf

	If ChkFile("GWE")
		oStructGWE := FWFormStruct(2,"GWE")
	EndIf

	oStructGWD:AddField("GWD_FILIAL","03","Filial","Filial do documento",,"C","@!",,"",.F.,,,,,,.F.,,,)

	oStructGW1:AddGroup("GrpId" , "Identificação", "1", 2) // "Identificação"
	oStructGW1:AddGroup("GrpMov", "Movimentação" , "1", 2) // "Movimentação"
	oStructGW1:AddGroup("GrpCtl", "Controle"     , "1", 2) // "Controle"

	oStructGW1:AddGroup("GrpCar", "Carga"             , "2", 2)
	oStructGW1:AddGroup("GrpEnd", "Endereço Entrega"  , "2", 2)
	oStructGW1:AddGroup("GrpCtr", "Controle"          , "2", 2)
	oStructGW1:AddGroup("GrpCal", "Cálculo Automático", "2", 2)
	oStructGW1:AddGroup("GrpInt", "Integrações"       , "2", 2)

	oStructGW1:SetProperty("GW1_CDTPDC", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_EMISDC", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_NMEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_SERDC" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_NRDC"  , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_AUTSEF", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_DANFE" , MVC_VIEW_GROUP_NUMBER, "GrpId")

	//Ponto de entrada Harley Davidson
	If ExistBlock("XINCGW1")
		ExecBlock("XINCGW1",.f.,.f.,{oStructGW1, "GrpId", oStructGW1:GetProperty("GW1_ORIGEM" , MVC_VIEW_ORDEM) , oStructGW1:GetProperty("GW1_SIT" , MVC_VIEW_ORDEM) })
	EndIf 	
	//Fim ponto de entrada Harley Davidson

	oStructGW1:SetProperty("GW1_CDREM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NMREM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NRROM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_CDDEST", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NMDEST", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_TPFRET", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_HRIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_ENVEDI", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_USO"   , MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	If GFXCP1212210('GW1_FILROM') .And. AScan(oStructGW1:aFields,{|x| x[1] == "GW1_FILROM"}) != 0
		oStructGW1:SetProperty("GW1_FILROM", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	EndIf

	oStructGW1:SetProperty("GW1_DSESP" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_QTVOL" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_CARREG", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_REGCOM", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_REPRES", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ICMSDC", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ORINR" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ORISER", MVC_VIEW_GROUP_NUMBER, "GrpCar")

	oStructGW1:SetProperty("GW1_ENTEND", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTBAI", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTCEP", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTNRC", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTCID", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTUF" , MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_NRREG"}) != 0 
		oStructGW1:SetProperty('GW1_NRREG', MVC_VIEW_FOLDER_NUMBER, '2')
		oStructGW1:SetProperty("GW1_NRREG" , MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	EndIf

	oStructGW1:SetProperty("GW1_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTLIB" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRLIB" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTPSAI", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRPSAI", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTPENT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTALT" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRALT" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_USUALT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTCAN" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRCAN" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_USUCAN", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRPENT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_SITFT"}) != 0
		oStructGW1:SetProperty("GW1_SITFT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		oStructGW1:SetProperty("GW1_MOTFT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_CALCAT"}) != 0
		oStructGW1:SetProperty("GW1_CALCAT" , MVC_VIEW_GROUP_NUMBER,  "GrpCtr")
	EndIf

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_ROMTV"}) != 0
		oStructGW1:SetProperty("GW1_ROMTV", MVC_VIEW_GROUP_NUMBER, "GrpCal")
		oStructGW1:SetProperty("GW1_ROMCF", MVC_VIEW_GROUP_NUMBER, "GrpCal")
		oStructGW1:SetProperty("GW1_ROMTO", MVC_VIEW_GROUP_NUMBER, "GrpCal")
	EndIf

	oStructGWF:AddField("GWF_VALFRT", "", STR0020, "", {STR0021}, "GET", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, .F., /*"1"*/, /*cGRUP*/, /*aListaCombo*/, /*nMAXLENCOMBO*/, /*"1"*/, /*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/)

	For nI := 1 To Len(aCampGWF)
		If nI < 10
			oStructGWF:SetProperty( aCampGWF[nI], MVC_VIEW_ORDEM, '0' + Alltrim(STR(nI)))
		Else
			oStructGWF:SetProperty( aCampGWF[nI], MVC_VIEW_ORDEM, Alltrim(STR(nI)))
		EndIf
	Next

	nUltOrd := nI

	For nI := 1 To Len(oStructGWF:aFields)
		If ASCAN(aCampGWF, oStructGWF:aFields[nI][1]) == 0 .And. Alltrim(oStructGWF:aFields[nI][1]) != "GWF_FILIAL"
			If nUltOrd < 10
				oStructGWF:SetProperty( oStructGWF:aFields[nI][1], MVC_VIEW_ORDEM, '0' + Alltrim(STR(nUltOrd)))
			Else
				oStructGWF:SetProperty( oStructGWF:aFields[nI][1], MVC_VIEW_ORDEM, Alltrim(STR(nUltOrd)))
			EndIf
			nUltOrd := nUltOrd + 1
		EndIf
	Next

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEC040_GW1" , oStructGW1 )

	oView:AddGrid( "GFEC040_GW8" , oStructGW8)
	oStructGW8:RemoveField("GW8_FILIAL")
	oStructGW8:RemoveField("GW8_CDTPDC")
	oStructGW8:RemoveField("GW8_EMISDC")
	oStructGW8:RemoveField("GW8_SERDC")
	oStructGW8:RemoveField("GW8_NRDC")
	/* Integração - Protheus 
	Verifica se o sistema está integrado com ERP e se a origem é o Protheus, 
	de outra forma remove o campo GW6_ATUATF */
	If GetNewPar("MV_CADERP", "2") == "2" .OR. GetNewPar("MV_ERPGFE", "0") != "2"
		oStructGW8:RemoveField("GW8_ATUATF")
	EndIf

	oView:AddIncrementField("GFEC040_GW8","GW8_SEQ")

	oView:AddGrid( "GFEC040_GWB" , oStructGWB)
	oStructGWB:RemoveField("GWB_FILIAL")
	oStructGWB:RemoveField("GWB_CDTPDC")
	oStructGWB:RemoveField("GWB_EMISDC")
	oStructGWB:RemoveField("GWB_SERDC")
	oStructGWB:RemoveField("GWB_NRDC")

	oView:AddGrid( "GFEC040_GWU" , oStructGWU)
	oStructGWU:RemoveField("GWU_FILIAL")
	oStructGWU:RemoveField("GWU_CDTPDC")
	oStructGWU:RemoveField("GWU_EMISDC")
	oStructGWU:RemoveField("GWU_SERDC")
	oStructGWU:RemoveField("GWU_NRDC")

	If GFXTB12117("GXP")
		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_NRCIDD"})
		cPosBase := oStructGWU:aFields[nPosBase,2]
		cCampos  := "GWU_NRCIDOGWU_NMCIDOGWU_UFOGWU_CEPOGWU_CEPDGWU_CDCLFRGWU_DSCLFRGWU_CDTPOPGWU_DSTPOP"

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_NRCIDO", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)  ,36,2))
		oStructGWU:SetProperty("GWU_NMCIDO", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+1,36,2))
		oStructGWU:SetProperty("GWU_UFO"   , MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+2,36,2))
		oStructGWU:SetProperty("GWU_CEPO"  , MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+3,36,2))

		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_CDTPVC"})
		cPosBase := oStructGWU:aFields[nPosBase,2]

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_CEPD", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36) ,36,2))

		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_PAGAR"})
		cPosBase := oStructGWU:aFields[nPosBase,2]

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_CDCLFR", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)  ,36,2))
		oStructGWU:SetProperty("GWU_DSCLFR", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+1,36,2))
		oStructGWU:SetProperty("GWU_CDTPOP", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+2,36,2))
		oStructGWU:SetProperty("GWU_DSTPOP", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+3,36,2))

		oStructGXP:RemoveField("GXP_CDTPDC")
		oStructGXP:RemoveField("GXP_EMISDC")
		oStructGXP:RemoveField("GXP_SERDC" )
		oStructGXP:RemoveField("GXP_NRDC"  )

		oView:AddGrid( "GFEC040_GXP" , oStructGXP)
	EndIF

	oView:AddGrid("GFEC040_GWF", oStructGWF)
	oView:AddGrid("GFEC040_GWJ", oStructGWJ)
	oView:AddGrid("GFEC040_GWD", oStructGWD)
	oView:AddGrid("GFEC040_GW3", oStructGW3)
	oView:AddGrid("GFEC040_GWM", oStructGWM)
	/* Adiciona totalizadores */           
	oView:AddField( 'VIEWCALC_GW8', oCalcGW8, 'CALCGW8_QTDE' )

	If ChkFile("GWE")
		oView:AddGrid( "GFEC040_GWE" , oStructGWE)
		oStructGWE:RemoveField("GWE_FILIAL")
		oStructGWE:RemoveField("GWE_CDTPDC")
		oStructGWE:RemoveField("GWE_EMISDC")
		oStructGWE:RemoveField("GWE_SERDC")
		oStructGWE:RemoveField("GWE_NRDC")
	EndIf
	oView:CreateHorizontalBox("MASTER" , 55)
	oView:CreateHorizontalBox("DETAIL" , 45)

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0013) //"Itens"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0014) //"Unitizadores"
	oView:AddSheet("IDFOLDER","IDSHEET03",STR0015) //"Trechos"
	If GFXTB12117("GXP")
		oView:AddSheet("IDFOLDER","IDSHEET10","Documentos de Origem")
	EndIf
	oView:AddSheet("IDFOLDER","IDSHEET04",STR0016) //"Cálculos"
	oView:AddSheet("IDFOLDER","IDSHEET05",STR0017) //"Pré-Faturas"
	oView:AddSheet("IDFOLDER","IDSHEET06",STR0018) //"Ocorrências"
	oView:AddSheet("IDFOLDER","IDSHEET07",STR0019) //"Documentos de Frete"
	oView:AddSheet("IDFOLDER","IDSHEET08","Rateio Frete")
	If ChkFile("GWE")
		oView:AddSheet("IDFOLDER","IDSHEET09","Documentos SIGATMS")
	Endif
	oView:CreateHorizontalBox( "DETAIL_GW8" , 70,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_GW8CALC" , 30,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_GWB" , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAIL_GWU" , 100,,,"IDFOLDER","IDSHEET03" )
	If GFXTB12117("GXP")
		oView:CreateHorizontalBox( "DETAIL_GXP" , 100,,,"IDFOLDER","IDSHEET10" )
	EndIf

	oView:CreateHorizontalBox( "DETAIL_GWF" , 100,,,"IDFOLDER","IDSHEET04" )
	oView:CreateHorizontalBox( "DETAIL_GWJ" , 100,,,"IDFOLDER","IDSHEET05" )
	oView:CreateHorizontalBox( "DETAIL_GWD" , 100,,,"IDFOLDER","IDSHEET06" )
	oView:CreateHorizontalBox( "DETAIL_GW3" , 100,,,"IDFOLDER","IDSHEET07" )
	oView:CreateHorizontalBox( "DETAIL_GWM" , 100,,,"IDFOLDER","IDSHEET08" )
	oView:CreateHorizontalBox( "DETAIL_GWE" , 100,,,"IDFOLDER","IDSHEET09" )

	oView:SetOwnerView( "GFEC040_GW1" , "MASTER" )
	oView:SetOwnerView( "GFEC040_GW8" , "DETAIL_GW8" )
	oView:SetOwnerView( "VIEWCALC_GW8" , "DETAIL_GW8CALC" )
	oView:SetOwnerView( "GFEC040_GWB" , "DETAIL_GWB" )
	oView:SetOwnerView( "GFEC040_GWU" , "DETAIL_GWU" )
	If GFXTB12117("GXP")
		oView:SetOwnerView( "GFEC040_GXP" , "DETAIL_GXP" )
	EndIf

	oView:SetOwnerView( "GFEC040_GWF" , "DETAIL_GWF" )
	oView:SetOwnerView( "GFEC040_GWJ" , "DETAIL_GWJ" )
	oView:SetOwnerView( "GFEC040_GWD" , "DETAIL_GWD" )
	oView:SetOwnerView( "GFEC040_GW3" , "DETAIL_GW3" )
	oView:SetOwnerView( "GFEC040_GWM" , "DETAIL_GWM" )

	If ChkFile("GWE")
		oView:SetOwnerView( "GFEC040_GWE" , "DETAIL_GWE" )
	Endif
	//oView:AddIncrementField("GFEC040_GW8","GW8_SEQ")
	oView:AddIncrementField("GFEC040_GWU","GWU_SEQ")


	oView:AddUserButton("Cons. Cálculo"   , "MAGIC_BMP", {|oView| GFEC040CCL(oView)}, )
	oView:AddUserButton("Cons. Pré-fatura", "MAGIC_BMP", {|oView| GFEC040CPF(oView)}, )
	oView:AddUserButton("Cons. Ocorrência", "MAGIC_BMP", {|oView| GFEC040COC(oView)}, )
	oView:AddUserButton("Cons. Documento de Frete", "MAGIC_BMP", {|oView| GFEC040CDF(oView)}, )
	oView:AddUserButton("Totais por classificação", "MAGIC_BMP", {||GFEC040A() }            , )

Return oView

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Insere cálculos relacionados ao documento de carga no grid.
Restrito

@sample
GFEC040LCL(oModelGWF)

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/
Static Function GFEC040LCL(oModelGWF)
	Local aStruc    := oModelGWF:GetStruct() // Array para armazenar o struct da tabela
	Local aRet      := {} // Array de retorno com os regitros. Formato ##array{ #linha{#recno 1, #campos{,,,}}, #linha{#recno 2, #campos{,,,}} }
	Local aCmp      := {}
	Local cAliasGWF := GetNextAlias()
	Local nRec      := 1 // Número de registros
	Local nCont     := 1

	BeginSql Alias cAliasGWF
		SELECT GWF.R_E_C_N_O_ RECNOGWF
		FROM %Table:GWH% GWH
		INNER JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
		AND GWF.%NotDel%
		WHERE GWH.GWH_FILIAL = %Exp:GW1->GW1_FILIAL%
		AND GWH.GWH_CDTPDC = %Exp:GW1->GW1_CDTPDC%
		AND GWH.GWH_EMISDC = %Exp:GW1->GW1_EMISDC%
		AND GWH.GWH_SERDC = %Exp:GW1->GW1_SERDC%
		AND GWH.GWH_NRDC = %Exp:GW1->GW1_NRDC%
		AND GWH.%NotDel%
	EndSql
	Do While (cAliasGWF)->(!Eof())
		GWF->(dbGoTo((cAliasGWF)->(RECNOGWF)))

		Do While nCont <= Len(aStruc:AFIELDS)
			If !aStruc:AFIELDS[nCont][14]
				If aStruc:AFIELDS[nCont][3] == "GWF_VALFRT"
					AAdd(aCmp, VLTOTFRET())
				Else
					AAdd(aCmp, &("GWF->"+aStruc:AFIELDS[nCont][3]))
				EndIf
			Else
				AAdd(aCmp, &(GetSx3Cache(aStruc:AFIELDS[nCont][3],"X3_RELACAO")))
			EndIf
			nCont++
		EndDo
		
		//Monta o array de acordo com a sequência de campos do struct, para ser mostrado no grid.
		AAdd(aRet,{nRec, aCmp})
	
		aCmp  := {}
		nCont := 1
		nRec++
		
		(cAliasGWF)->(dbSkip())
	EndDo
	(cAliasGWF)->(dbCloseArea())

	//Caso não encontre registros, permanece o array em branco Obs: Permanecer todas as 'vírgulas' para não ocorrer erros
	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:AFIELDS)-1) + "}")}}
	EndIf
Return aRet

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Insere pré-faturas relacionadas ao documento de carga no grid.
Restrito

@sample
GFEC040LPF(oModelGWJ)

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/
Static Function GFEC040LPF(oModelGWJ)
	Local aNrPf     := {}
	Local aStruc    := oModelGWJ:GetStruct()
	Local aRet      := {}
	Local aCmp      := {}
	Local cAliasGWJ := GetNextAlias()
	Local nRec      := 1
	Local nCont     := 1

	BeginSql Alias cAliasGWJ
		SELECT GWJ.R_E_C_N_O_ RECNOGWJ,
				GWJ.GWJ_NRPF
		FROM %Table:GWH% GWH
		INNER JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
		AND GWF.%NotDel%
		INNER JOIN %Table:GWJ% GWJ
		ON GWJ.GWJ_FILIAL = GWF.GWF_FILPRE
		AND GWJ.GWJ_NRPF = GWF.GWF_NRPREF
		AND GWJ.%NotDel%
		WHERE GWH.GWH_FILIAL = %Exp:GW1->GW1_FILIAL%
		AND GWH.GWH_CDTPDC = %Exp:GW1->GW1_CDTPDC%
		AND GWH.GWH_EMISDC = %Exp:GW1->GW1_EMISDC%
		AND GWH.GWH_SERDC = %Exp:GW1->GW1_SERDC%
		AND GWH.GWH_NRDC = %Exp:GW1->GW1_NRDC%
		AND GWH.%NotDel%
	EndSql
	Do While (cAliasGWJ)->(!Eof())
		If AScan(aNrPf,{|x| x == (cAliasGWJ)->GWJ_NRPF}) == 0
			GWJ->(dbGoTo((cAliasGWJ)->RECNOGWJ))
	
			AAdd(aNrPf,GWJ->GWJ_NRPF)
	
			Do While nCont <= Len(aStruc:AFIELDS)
				If !aStruc:AFIELDS[nCont][14]
					AAdd(aCmp, &("GWJ->"+aStruc:AFIELDS[nCont][3]))
				Else
					AAdd(aCmp, &(GetSx3Cache(aStruc:AFIELDS[nCont][3],"X3_RELACAO")))
				EndIf
				nCont++
			EndDo
	
			AAdd(aRet,{nRec, aCmp})
	
			aCmp  := {}
			nCont := 1
			nRec++
		EndIf
		
		(cAliasGWJ)->(dbSkip())
	EndDo
	(cAliasGWJ)->(dbCloseArea())

	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:AFIELDS)-1) + "}")}}
	EndIf
Return aRet
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Insere ocorrências relacionadas ao documento de carga no grid.
Restrito

@sample
GFEC040LOC(oModelGWD)

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/ 
Static Function GFEC040LOC(oModelGWD)
	Local aStruc    := oModelGWD:GetStruct()
	Local aRet      := {}
	Local aCmp      := {}
	Local cAliasGWD := GetNextAlias()
	Local nRec      := 1
	Local nCont     := 1

	BeginSql Alias cAliasGWD
		SELECT GWD.R_E_C_N_O_ RECNOGWD
		FROM %Table:GWL% GWL
		INNER JOIN %Table:GWD% GWD
		ON GWD.GWD_FILIAL = GWL.GWL_FILIAL
		AND GWD.GWD_NROCO = GWL.GWL_NROCO
		AND GWD.%NotDel%
		WHERE GWL.GWL_FILDC = %Exp:GW1->GW1_FILIAL%
		AND GWL.GWL_EMITDC = %Exp:GW1->GW1_EMISDC%
		AND GWL.GWL_TPDC = %Exp:GW1->GW1_CDTPDC%
		AND GWL.GWL_SERDC = %Exp:GW1->GW1_SERDC%
		AND GWL.GWL_NRDC = %Exp:GW1->GW1_NRDC%
		AND GWL.%NotDel%
	EndSql
	Do While (cAliasGWD)->(!Eof())
		GWD->(dbGoTo((cAliasGWD)->RECNOGWD))
		
		Do While nCont <= Len(aStruc:AFIELDS)
			If !aStruc:AFIELDS[nCont][14]
				AAdd(aCmp, &("GWD->"+aStruc:AFIELDS[nCont][3]))
			Else
				AAdd(aCmp, &(GetSx3Cache(aStruc:AFIELDS[nCont][3],"X3_RELACAO")))
			EndIf
			nCont++
		EndDo
		
		AAdd(aRet,{nRec, aCmp})

		aCmp  := {}
		nCont := 1
		nRec++
		
		(cAliasGWD)->(dbSkip())
	EndDo
	(cAliasGWD)->(dbCloseArea())

	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:AFIELDS)-1) + "}")}}
	EndIf
Return aRet
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Insere documentos de frete relacionadas ao documento de carga no grid.
Restrito

@sample
GFEC040LDF(oModelGW3)

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/ 
Static Function GFEC040LDF(oModelGW3)
	Local aStruc    := oModelGW3:GetStruct()
	Local aRet      := {}
	Local aCmp      := {}
	Local cAliasGW3 := GetNextAlias()
	Local nRec      := 1
	Local nCont     := 1
	
	BeginSql Alias cAliasGW3
		SELECT GW3.R_E_C_N_O_ RECNOGW3 
		FROM %Table:GW4% GW4
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
		AND GW3.GW3_CDESP = GW4.GW4_CDESP
		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
		AND GW3.GW3_SERDF = GW4.GW4_SERDF
		AND GW3.GW3_NRDF = GW4.GW4_NRDF
		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		AND GW3.%NotDel%
		WHERE GW4.GW4_FILIAL = %Exp:GW1->GW1_FILIAL%
		AND GW4.GW4_EMISDC = %Exp:GW1->GW1_EMISDC%
		AND GW4.GW4_SERDC = %Exp:GW1->GW1_SERDC%
		AND GW4.GW4_NRDC = %Exp:GW1->GW1_NRDC%
		AND GW4.GW4_TPDC = %Exp:GW1->GW1_CDTPDC%
		AND GW4.%NotDel%
	EndSql
	Do While (cAliasGW3)->(!Eof())
		GW3->(dbGoTo((cAliasGW3)->RECNOGW3))
		
		Do While nCont <= Len(aStruc:AFIELDS)
			If !aStruc:AFIELDS[nCont][14]
				AAdd(aCmp, &("GW3->"+aStruc:AFIELDS[nCont][3]))
			Else
				AAdd(aCmp, &(GetSx3Cache(aStruc:AFIELDS[nCont][3],"X3_RELACAO")))
			EndIf
			nCont++
		EndDo
		
		AAdd(aRet,{nRec, aCmp})
		
		aCmp  := {}
		nCont := 1
		nRec++
		
		(cAliasGW3)->(dbSkip())
	EndDo
	(cAliasGW3)->(dbCloseArea())

	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:AFIELDS)-1) + "}")}}
	EndIf
Return aRet
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040

Restrito
Exibe os dados do cálculo selecionado na aba "Cálculos"
@sample
GFEC040CCL(oView)

@author Lidiomar Fernando dos Santos Machado
@since 17/01/2013
@version 1.0
---------------------------------------------------------------------------------------------------*/
Function GFEC040CCL(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWF := oModel:GetModel("GFEC040_GWF")
	Local nLine     := oModelGWF:GetLine()
	Local cNrCalc   := FWFldGet("GWF_NRCALC", nLine)
	Local cAliasGWF := Nil
	
	If cNrCalc != Nil
		cAliasGWF := GetNextAlias()
		BeginSql Alias cAliasGWF
			SELECT GWF.R_E_C_N_O_ RECNOGWF
			FROM %Table:GWF% GWF
			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
			AND GWF.GWF_NRCALC = %Exp:cNrCalc%
			AND GWF.%NotDel%
		EndSql
		If (cAliasGWF)->(!Eof())
			GWF->(dbGoTo((cAliasGWF)->RECNOGWF))
			FWExecView("Visualizar", "GFEC080", 1,,{|| .T.})
		EndIf
		(cAliasGWF)->(dbCloseArea())
	EndIf
Return Nil
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Restrito
Exibe os dados da Pré fatura selecionada na aba "Pré faturas"
@sample
GFEC040CPF(oView)

@author Lidiomar Fernando dos Santos Machado
@since 17/01/2013
@version 1.0
---------------------------------------------------------------------------------------------------*/ 
Function GFEC040CPF(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWJ := oModel:GetModel("GFEC040_GWJ")
	Local nLine     := oModelGWJ:GetLine()
	Local cNrPf     := FWFldGet("GWJ_NRPF", nLine)
	Local cAliasGWJ := Nil

	If cNrPf != Nil
		cAliasGWJ := GetNextAlias()
		BeginSql Alias cAliasGWJ
			SELECT GWJ.R_E_C_N_O_ RECNOGWJ
			FROM %Table:GWJ% GWJ
			WHERE GWJ.GWJ_FILIAL = %xFilial:GWJ%
			AND GWJ.GWJ_NRPF = %Exp:cNrPf%
			AND GWJ.%NotDel%
		EndSql
		If (cAliasGWJ)->(!Eof())
			GWJ->(dbGoTo((cAliasGWJ)->RECNOGWJ))
			FWExecView("Visualizar", "GFEC055", 1,,{|| .T.})
		EndIf
		(cAliasGWJ)->(dbCloseArea())
	EndIf
Return Nil
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Exibe os dados da Ocorrência selecionada na aba "Ocorrências"
Restrito

@sample
GFEC040COC(oView)

@author Lidiomar Fernando dos Santos Machado
@since 17/01/2013
@version 1.0
---------------------------------------------------------------------------------------------------*/
Function GFEC040COC(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWD := oModel:GetModel("GFEC040_GWD")
	Local nLine     := oModelGWD:GetLine()
	Local cNrOco    := FWFldGet("GWD_NROCO", nLine)
	Local cFilOco   := FWFldGet("GWD_FILIAL", nLine)
	Local cAliasGWD := Nil

	If cNrOco != Nil
		cAliasGWD := GetNextAlias()
		BeginSql Alias cAliasGWD
			SELECT GWD.R_E_C_N_O_ RECNOGWD
			FROM %Table:GWD% GWD
			WHERE GWD.GWD_FILIAL = %Exp:cFilOco%
			AND GWD.GWD_NROCO = %Exp:cNrOco%
			AND GWD.%NotDel%
		EndSql
		If (cAliasGWD)->(!Eof())
			GWD->( dbGoTo((cAliasGWD)->RECNOGWD))
			FWExecView("Visualizar", "GFEC032", 1,,{|| .T.})
		EndIf
		(cAliasGWD)->(dbCloseArea())
	EndIf
Return Nil
/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Exibe os dados do documento de frete selecionada na aba "Documentos de Frete"
Restrito

@sample
GFEC040CDF(oView)

@author Lidiomar Fernando dos Santos Machado
@since 17/01/2013
@version 1.0
---------------------------------------------------------------------------------------------------*/
Function GFEC040CDF(oView)
	Local oModel    := oView:GetModel()
	Local oModelGW3 := oModel:GetModel("GFEC040_GW3")
	Local nLine     := oModelGW3:GetLine()
	Local cNrDf     := FWFldGet("GW3_NRDF", nLine)
	Local cAliasGW3 := Nil
	
	If cNrDf != Nil
		cAliasGW3 := GetNextAlias()
		BeginSql Alias cAliasGW3
			SELECT GW3.R_E_C_N_O_ RECNOGW3
			FROM %Table:GW3% GW3
			WHERE GW3.GW3_FILIAL = %xFilial:GW3%
			AND GW3.GW3_CDESP = %Exp:FWFldGet("GW3_CDESP", nLine)%
			AND GW3.GW3_EMISDF = %Exp:FWFldGet("GW3_EMISDF", nLine)%
			AND GW3.GW3_SERDF = %Exp:FWFldGet("GW3_SERDF", nLine)%
			AND GW3.GW3_NRDF = %Exp:FWFldGet("GW3_NRDF", nLine)%
			AND GW3.GW3_DTEMIS = %Exp:DTOS(FWFldGet("GW3_DTEMIS", nLine))%
		EndSql
		If (cAliasGW3)->(!Eof())
			GW3->(dbGoTo((cAliasGW3)->RECNOGW3))
			FWExecView("Visualizar", "GFEC065", 1,,{|| .T.})
		EndIf
		(cAliasGW3)->(dbCloseArea())
	EndIf
Return Nil
/*--------------------------------------------------------------------------------------
{Protheus.doc} FiltGW1RID

Query usada para melhorar a performance do filtro consulta padrão GW1RID

@since 08/02/2017
---------------------------------------------------------------------------------------*/
Function FiltGW1RID()
	Local cFiltro := " "

	cFiltro := "@EXISTS(SELECT GWN_SIT FROM " + RetSqlName('GWN')+ " GWN "
	cFiltro += " WHERE GWN.GWN_FILIAL = GW1_FILIAL " 
	cFiltro += " AND GWN.GWN_NRROM = GW1_NRROM "
	cFiltro += " AND GWN.GWN_SIT IN ('3','4') "
	cFiltro += " AND D_E_L_E_T_ = ' ')"  
Return cFiltro
