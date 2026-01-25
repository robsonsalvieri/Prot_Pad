#Include "TOTVS.ch"
#Include "GFER002.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFER002()
Relatório de Visão Geral de Fretes
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFER002()
	Private _aFields   := {}
	Private _cMvPar01  := Nil
	Private _cMvPar02  := Nil
	Private _cMvPar03  := Nil
	Private _cMvPar04  := Nil
	Private _cMvPar05  := Nil
	Private _cMvPar06  := Nil
	Private _cMvPar07  := Nil
	Private _IntGFE    := SuperGetMV('MV_ERPGFE',,'1') == '1'
	Private nHandle    := Nil
	Private oReport    := Nil
	Private oSection   := Nil
	// Variáveis Impressão
	Private cGW1FILIAL := Nil
	Private cGW1NMFIL  := Nil
	Private cGW1CDTPDC := Nil
	Private cGW1EMISDC := Nil
	Private cCNPJEMIS  := Nil
	Private cNMEMIS    := Nil
	Private cGW1SERDC  := Nil
	Private cGW1NRDC   := Nil
	Private cGW1DANFE  := Nil
	Private cGW1DTEMIS := Nil
	Private cGW1DTIMPL := Nil
	Private cGW1DTSAI  := Nil
	Private cGW1USO    := Nil
	Private cGW1REGCOM := Nil
	Private cGW8ITEM   := Nil
	Private cGW8DSITEM := Nil
	Private cGW8QTDE   := Nil
	Private cGW8VALOR  := Nil
	Private cGW8VOLUME := Nil
	Private cGW8PESOC  := Nil
	Private cGW8PESOR  := Nil
	Private cGW8QTDALT := Nil
	Private cGUBDSCLFR := Nil
	Private cGW8CFOP   := Nil
	Private cGW8INFO1  := Nil
	Private cGW8INFO2  := Nil
	Private cGW8INFO3  := Nil
	Private cGW8INFO4  := Nil
	Private cGW8INFO5  := Nil
	Private cGW1CDREM  := Nil
	Private cCNPJREM   := Nil
	Private cNMREM     := Nil
	Private cGW1CDDEST := Nil
	Private cCNPJDEST  := Nil
	Private cNMDEST    := Nil
	Private cGW1SIT    := Nil
	Private cGW0MSG    := Nil
	Private cGW1CALCAT := Nil
	Private cGW1ROMTV  := Nil
	Private cGW1ROMCF  := Nil
	Private cGW1ROMTO  := Nil
	Private cGU3NRCID  := Nil
	Private cGWUNRCIDO := Nil
	Private cNMCIDO    := Nil
	Private cUFO       := Nil
	Private cGWUNRCIDD := Nil
	Private cNMCIDD    := Nil
	Private cUFD       := Nil
	Private cNMREGP    := Nil
	Private cNMREGD    := Nil
	Private cGWUSEQ    := Nil
	Private cGWUPAGAR  := Nil
	Private cGWUCDTRP  := Nil
	Private cCNPJTRP   := Nil
	Private cNMTRP     := Nil
	Private cAUTON     := Nil
	Private cMODAL     := Nil
	Private cTPTRIB    := Nil
	Private cGWNNRROM  := Nil
	Private cGWNSIT    := Nil
	Private cGWNCDTPVC := Nil
	Private cGWNCDCLFR := Nil
	Private cGWNCDTPOP := Nil
	Private cGWNCALC   := Nil
	Private cGWNMTCALC := Nil
	Private cGWNVPVAL  := Nil
	Private cGWUDTPENT := Nil
	Private cGWUHRPENT := Nil
	Private cGWUDTENT  := Nil
	Private cGWUHRENT  := Nil
	Private cGWFNRCALC := Nil
	Private cGWFTPFRET := Nil
	Private cVLFRET    := Nil
	Private cVLICMS    := Nil
	Private cVLPIS     := Nil
	Private cVLCOFI    := Nil
	Private cGWFTPTRIB := Nil
	Private cGWFCRDICM := Nil
	Private cGWFCRDPC  := Nil
	Private cGWGNRTAB  := Nil
	Private cGWGNRNEG  := Nil
	Private cGWGCDFXTV := Nil
	Private cGWGCDTPOP := Nil
	Private cGWGCDTPVC := Nil
	Private cGWGCDCLFR := Nil
	Private cGV9UNIFAI := Nil
	Private cGWGNRROTA := Nil
	Private cDESCROTA  := Nil
	Private cGWJNRPF   := Nil
	Private cGWJDTIMPL := Nil
	Private cGWJSIT    := Nil
	Private cGWJSITFIN := Nil
	Private cCODLOTE   := Nil
	Private cGXFVALOR  := Nil
	Private cPERLOTE   := Nil
	Private cSITLOTE   := Nil
	Private cGXTNRCT   := Nil
	Private cGW3CDESP  := Nil
	Private cGW3NRDF   := Nil
	Private cGW3SERDF  := Nil
	Private cGW3TPDF   := Nil
	Private cGW3DTENT  := Nil
	Private cGW3DTEMIS := Nil
	Private cVLFRETDF  := Nil
	Private cVLICMSDF  := Nil
	Private cVLPISDF   := Nil
	Private cVLCOFIDF  := Nil
	Private cGW3SIT    := Nil
	Private cGXGEDISIT := Nil
	Private cGW3MOTBLQ := Nil
	Private cGW3SITFIS := Nil
	Private cGW3DTFIS  := Nil
	Private cGW3SITREC := Nil
	Private cGW3DTREC  := Nil
	Private cGW3SITCUS := Nil
	Private cGW3DTCUS  := Nil
	Private cGW3SITMLA := Nil
	Private cGW6NRFAT  := Nil
	Private cGW6DTEMIS := Nil
	Private cGW6VLFATU := Nil
	Private cGW6SITAPR := Nil
	Private cGW6DTFIN  := Nil
	Private cGW6SITFIN := Nil

	If Pergunte('GFER002')
		_cMvPar01 := DToS(MV_PAR01)
		_cMvPar02 := DToS(MV_PAR02)
		_cMvPar03 := DToS(MV_PAR03)
		_cMvPar04 := DToS(MV_PAR04)
		_cMvPar05 := MV_PAR05
		_cMvPar06 := IIf(!Empty(MV_PAR06),MV_PAR06,1)
		_cMvPar07 := IIf(!Empty(MV_PAR07),AllTrim(MV_PAR07),'')

		If _cMvPar06 == 1
			GFER002Rep()
		Else
			GFER002Txt()
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} GFER002GerRep
	Geração do relatório padrão
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Rep()
	//Teste padrão
	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Definição do obejto TReport
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
	Local aGW1FILIAL := {}
	Local aGW1NMFIL  := {}
	Local aGW1CDTPDC := {}
	Local aGW1EMISDC := {}
	Local aCNPJEMIS  := {}
	Local aNMEMIS    := {}
	Local aGW1SERDC  := {}
	Local aGW1NRDC   := {}
	Local aGW1DANFE  := {}
	Local aGW1DTEMIS := {}
	Local aGW1DTIMPL := {}
	Local aGW1DTSAI  := {}
	Local aGW1USO    := {}
	Local aGW1REGCOM := {}
	Local aGW8ITEM   := {}
	Local aGW8DSITEM := {}
	Local aGW8QTDE   := {}
	Local aGW8VALOR  := {}
	Local aGW8VOLUME := {}
	Local aGW8PESOC  := {}
	Local aGW8PESOR  := {}
	Local aGW8QTDALT := {}
	Local aGUBDSCLFR := {}
	Local aGW8CFOP   := {}
	Local aGW8INFO1  := {}
	Local aGW8INFO2  := {}
	Local aGW8INFO3  := {}
	Local aGW8INFO4  := {}
	Local aGW8INFO5  := {}
	Local aGW1CDREM  := {}
	Local aCNPJREM   := {}
	Local aNMREM     := {}
	Local aGW1CDDEST := {}
	Local aCNPJDEST  := {}
	Local aNMDEST    := {}
	Local aGW1SIT    := {}
	Local aGW0MSG    := {}
	Local aGW1CALCAT := {}
	Local aGW1ROMTV  := {}
	Local aGW1ROMCF  := {}
	Local aGW1ROMTO  := {}
	Local aGU3NRCID  := {}
	Local aGWUNRCIDO := {}
	Local aNMCIDO    := {}
	Local aUFO       := {}
	Local aGWUNRCIDD := {}
	Local aNMCIDD    := {}
	Local aUFD       := {}
	Local aNMREGP    := {}
	Local aNMREGD    := {}
	Local aGWUSEQ    := {}
	Local aGWUPAGAR  := {}
	Local aGWUCDTRP  := {}
	Local aCNPJTRP   := {}
	Local aNMTRP     := {}
	Local aAUTON     := {}
	Local aMODAL     := {}
	Local aTPTRIB    := {}
	Local aGWNNRROM  := {}
	Local aGWNSIT    := {}
	Local aGWNCDTPVC := {}
	Local aGWNCDCLFR := {}
	Local aGWNCDTPOP := {}
	Local aGWNCALC   := {}
	Local aGWNMTCALC := {}
	Local aGWNVPVAL  := {}
	Local aGWUDTPENT := {}
	Local aGWUHRPENT := {}
	Local aGWUDTENT  := {}
	Local aGWUHRENT  := {}
	Local aGWFNRCALC := {}
	Local aGWFTPFRET := {}
	Local aVLFRET    := {}
	Local aVLICMS    := {}
	Local aVLPIS     := {}
	Local aVLCOFI    := {}
	Local aGWFTPTRIB := {}
	Local aGWFCRDICM := {}
	Local aGWFCRDPC  := {}
	Local aGWGNRTAB  := {}
	Local aGWGNRNEG  := {}
	Local aGWGCDFXTV := {}
	Local aGWGCDTPOP := {}
	Local aGWGCDTPVC := {}
	Local aGWGCDCLFR := {}
	Local aGV9UNIFAI := {}
	Local aGWGNRROTA := {}
	Local aDESCROTA  := {}
	Local aGWJNRPF   := {}
	Local aGWJDTIMPL := {}
	Local aGWJSIT    := {}
	Local aGWJSITFIN := {}
	Local aCODLOTE   := {}
	Local aGXFVALOR  := {}
	Local aPERLOTE   := {}
	Local aSITLOTE   := {}
	Local aGXTNRCT   := {}
	Local aGW3CDESP  := {}
	Local aGW3NRDF   := {}
	Local aGW3SERDF  := {}
	Local aGW3TPDF   := {}
	Local aGW3DTENT  := {}
	Local aGW3DTEMIS := {}
	Local aVLFRETDF  := {}
	Local aVLICMSDF  := {}
	Local aVLPISDF   := {}
	Local aVLCOFIDF  := {}
	Local aGW3SIT    := {}
	Local aGXGEDISIT := {}
	Local aGW3MOTBLQ := {}
	Local aGW3SITFIS := {}
	Local aGW3DTFIS  := {}
	Local aGW3SITREC := {}
	Local aGW3DTREC  := {}
	Local aGW3SITCUS := {}
	Local aGW3DTCUS  := {}
	Local aGW3SITMLA := {}
	Local aGW6NRFAT  := {}
	Local aGW6DTEMIS := {}
	Local aGW6VLFATU := {}
	Local aGW6SITAPR := {}
	Local aGW6DTFIN  := {}
	Local aGW6SITFIN := {}
	
	Local aVLIBS     := {}
	Local aVLIBM     := {}
	Local aVLCBS     := {}
	Local aVLIBSDF   := {}
	Local aVLIBMDF   := {}
	Local aVLCBSDF   := {}

	Local oSection1  := Nil
	Local oFieldHide := Nil
	Local cData      := __FWLibVersion()


	GFEFindSx3("GW1_FILIAL",aGW1FILIAL,,,,,"@!")
	GFEFindSx3(,aGW1NMFIL,,30,0,"C","@!")
	GFEFindSx3("GW1_CDTPDC",aGW1CDTPDC)
	GFEFindSx3("GW1_EMISDC",aGW1EMISDC)
	GFEFindSx3("GU3_IDFED",aCNPJEMIS)
	GFEFindSx3("GU3_NMEMIT",aNMEMIS)
	GFEFindSx3("GW1_SERDC",aGW1SERDC)
	GFEFindSx3("GW1_NRDC",aGW1NRDC)
	GFEFindSx3("GW1_DANFE",aGW1DANFE)
	GFEFindSx3("GW1_DTEMIS",aGW1DTEMIS)
	GFEFindSx3("GW1_DTIMPL",aGW1DTIMPL)
	GFEFindSx3("GW1_DTSAI",aGW1DTSAI)
	GFEFindSx3("GW1_USO",aGW1USO,,25)
	GFEFindSx3("GW1_REGCOM",aGW1REGCOM)
	GFEFindSx3("GW8_ITEM",aGW8ITEM)
	GFEFindSx3("GW8_DSITEM",aGW8DSITEM)
	GFEFindSx3("GW8_QTDE",aGW8QTDE)
	GFEFindSx3("GW8_VALOR",aGW8VALOR)
	GFEFindSx3("GW8_VOLUME",aGW8VOLUME)
	GFEFindSx3("GW8_PESOC",aGW8PESOC)
	GFEFindSx3("GW8_PESOR",aGW8PESOR)
	GFEFindSx3("GW8_QTDALT",aGW8QTDALT)
	GFEFindSx3("GUB_DSCLFR",aGUBDSCLFR)
	GFEFindSx3("GW8_CFOP",aGW8CFOP)
	GFEFindSx3("GW8_INFO1",aGW8INFO1)
	GFEFindSx3("GW8_INFO2",aGW8INFO2)
	GFEFindSx3("GW8_INFO3",aGW8INFO3)
	GFEFindSx3("GW8_INFO4",aGW8INFO4)
	GFEFindSx3("GW8_INFO5",aGW8INFO5)
	GFEFindSx3("GW1_CDREM",aGW1CDREM)
	aCNPJREM   := aCNPJEMIS
	aNMREM     := aNMEMIS
	GFEFindSx3("GW1_CDREM",aGW1CDDEST)
	aCNPJDEST  := aCNPJEMIS
	aNMDEST    := aNMEMIS
	GFEFindSx3("GW1_SIT",aGW1SIT,,25)
	GFEFindSx3("GW0_CHAR01",aGW0MSG)
	GFEFindSx3("GW1_CALCAT",aGW1CALCAT,,25)
	GFEFindSx3("GW1_ROMTV",aGW1ROMTV)
	GFEFindSx3("GW1_ROMCF",aGW1ROMCF)
	GFEFindSx3("GW1_ROMTO",aGW1ROMTO)
	GFEFindSx3("GU3_NRCID",aGU3NRCID)
	GFEFindSx3("GWU_NRCIDO",aGWUNRCIDO)
	aNMCIDO    := aGU3NRCID
	GFEFindSx3("GU7_NMCID",aNMCIDO)
	GFEFindSx3("GU7_CDUF",aUFO)
	aGWUNRCIDD := aGWUNRCIDO
	GFEFindSx3("GU7_NMCID",aNMCIDD)
	GFEFindSx3("GU7_CDUF",aUFD)
	GFEFindSx3("GU9_NMREG",aNMREGP)
	aNMREGD    := aNMREGP
	GFEFindSx3("GWU_SEQ",aGWUSEQ)
	GFEFindSx3("GWU_PAGAR",aGWUPAGAR,,3)
	GFEFindSx3("GWU_CDTRP",aGWUCDTRP)
	aCNPJTRP   := aGWUCDTRP
	GFEFindSx3("GU3_NMEMIT",aNMTRP)
	GFEFindSx3("GU3_AUTON",aAUTON,,15)
	GFEFindSx3("GU3_MODAL",aMODAL,,25)
	GFEFindSx3("GU3_TPTRIB",aTPTRIB,,25)
	GFEFindSx3("GWN_NRROM",aGWNNRROM)
	GFEFindSx3("GWN_SIT",aGWNSIT,,25)
	GFEFindSx3("GWN_CDTPVC",aGWNCDTPVC)
	GFEFindSx3("GWN_CDCLFR",aGWNCDCLFR)
	GFEFindSx3("GWN_CDTPOP",aGWNCDTPOP)
	GFEFindSx3("GWN_CALC",aGWNCALC,,25)
	GFEFindSx3("GWN_MTCALC",aGWNMTCALC)
	GFEFindSx3("GWN_VPVAL",aGWNVPVAL)
	GFEFindSx3("GWU_DTPENT",aGWUDTPENT)
	GFEFindSx3("GWU_HRPENT",aGWUHRPENT)
	GFEFindSx3("GWU_DTENT",aGWUDTENT)
	GFEFindSx3("GWU_HRENT",aGWUHRENT)
	GFEFindSx3("GWF_NRCALC",aGWFNRCALC)
	GFEFindSx3("GWF_TPFRET",aGWFTPFRET,,25)
	GFEFindSx3("GWM_VLFRET",aVLFRET)
	GFEFindSx3("GWM_VLICMS",aVLICMS)
	GFEFindSx3("GWM_VLPIS",aVLPIS)
	GFEFindSx3("GWM_VLCOFI",aVLCOFI)
	GFEFindSx3("GWF_TPTRIB",aGWFTPTRIB,,25)
	GFEFindSx3("GWF_CRDICM",aGWFCRDICM,,3)
	GFEFindSx3("GWF_CRDPC",aGWFCRDPC,,3)
	GFEFindSx3("GWG_NRTAB",aGWGNRTAB)
	GFEFindSx3("GWG_NRNEG",aGWGNRNEG)
	GFEFindSx3("GWG_CDFXTV",aGWGCDFXTV)
	GFEFindSx3("GWG_CDTPOP",aGWGCDTPOP)
	GFEFindSx3("GWG_CDTPVC",aGWGCDTPVC)
	GFEFindSx3("GWG_CDCLFR",aGWGCDCLFR)
	GFEFindSx3("GV9_UNIFAI",aGV9UNIFAI)
	GFEFindSx3("GWG_NRROTA",aGWGNRROTA)
	GFEFindSx3("GV6_INFROT",aDESCROTA)
	GFEFindSx3("GWJ_NRPF",aGWJNRPF)
	GFEFindSx3("GWJ_DTIMPL",aGWJDTIMPL)
	GFEFindSx3("GWJ_SIT",aGWJSIT)
	GFEFindSx3("GWJ_SITFIN",aGWJSITFIN)
	GFEFindSx3("GXE_CODLOT",aCODLOTE)
	GFEFindSx3("GXF_VALOR",aGXFVALOR)
	GFEFindSx3("GXE_PERIOD",aPERLOTE)
	GFEFindSx3("GXE_SIT",aSITLOTE)
	GFEFindSx3("GXT_NRCT",aGXTNRCT)
	GFEFindSx3("GW3_CDESP",aGW3CDESP)
	GFEFindSx3("GW3_NRDF",aGW3NRDF)
	GFEFindSx3("GW3_SERDF",aGW3SERDF)
	GFEFindSx3("GW3_TPDF",aGW3TPDF,,25)
	GFEFindSx3("GW3_DTENT",aGW3DTENT)
	GFEFindSx3("GW3_DTEMIS",aGW3DTEMIS)
	GFEFindSx3("GWM_VLFRET",aVLFRETDF)
	GFEFindSx3("GWM_VLICMS",aVLICMSDF)
	GFEFindSx3("GWM_VLPIS",aVLPISDF)
	GFEFindSx3("GWM_VLCOFI",aVLCOFIDF)
	GFEFindSx3(,aGW3SIT,,25,0,"C","@!")
	GFEFindSx3(,aGXGEDISIT,,25,0,"C","@!")
	GFEFindSx3("GW3_MOTBLQ",aGW3MOTBLQ)
	GFEFindSx3("GW3_SITFIS",aGW3SITFIS,,25)
	GFEFindSx3("GW3_DTFIS",aGW3DTFIS)
	GFEFindSx3("GW3_SITREC",aGW3SITREC,,25)
	GFEFindSx3("GW3_DTREC",aGW3DTREC)
	GFEFindSx3("GW3_SITCUS",aGW3SITCUS,,25)
	GFEFindSx3("GW3_DTCUS",aGW3DTCUS)
	GFEFindSx3("GW3_SITMLA",aGW3SITMLA,,25)
	GFEFindSx3("GW6_NRFAT",aGW6NRFAT)
	GFEFindSx3("GW6_DTEMIS",aGW6DTEMIS)
	GFEFindSx3("GW6_VLFATU",aGW6VLFATU)
	GFEFindSx3(,aGW6SITAPR,,25,0,"C","@!")
	GFEFindSx3("GW6_DTFIN",aGW6DTFIN)
	GFEFindSx3("GW6_SITFIN",aGW6SITFIN,,25)
	
	If GFXCP2510('GWM_VLIBS')
		GFEFindSx3("GWM_VLIBS",aVLIBS)
		GFEFindSx3("GWM_VLIBS",aVLIBSDF)
	EndIf
	If GFXCP2510('GWM_VLIBM')
		GFEFindSx3("GWM_VLIBM",aVLIBM)
		GFEFindSx3("GWM_VLIBM",aVLIBMDF)
	EndIf
	If GFXCP2510('GWM_VLCBS')
		GFEFindSx3("GWM_VLCBS",aVLCBS)
		GFEFindSx3("GWM_VLCBS",aVLCBSDF)
	EndIf

	oReport := TReport():New("GFER002","Relatório Visão Geral de Fretes","GFER002", {|oReport| ReportPrint(oReport)},)
	oReport:SetLandscape()
	oReport:HideParamPage()
	oReport:NDEVICE := 4    //DEFINE COMO EXCEL A SAÍDA

	If (cData >= "20180413") // Somente a partir desta versão existe a propriedade lExcelWrXml no TReport
		oReport:lExcelWrXml := .T.
	EndIf

	oSection1 := TRSection():New(oReport,STR0001,) // Relatório Visão Geral de Fretes
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "(cTabTemp)->GW1FILIAL", aGW1FILIAL[5], STR0002 , aGW1FILIAL[4] ,aGW1FILIAL[2] ,.T.,{||(cTabTemp)->GW1FILIAL}) // Código Filial
	TRCell():New(oSection1, "(cTabTemp)->GW1NMFIL" , aGW1NMFIL[5] , STR0003 , aGW1NMFIL[4]  ,aGW1NMFIL[2]  ,.T.,{||(cTabTemp)->GW1NMFIL})  // Nome Filial
	TRCell():New(oSection1, "(cTabTemp)->GW1CDTPDC", aGW1CDTPDC[5], STR0004 , aGW1CDTPDC[4] ,aGW1CDTPDC[2] ,.T.,{||(cTabTemp)->GW1CDTPDC}) // Tipo DC
	TRCell():New(oSection1, "(cTabTemp)->GW1EMISDC", aGW1EMISDC[5], STR0005 , aGW1EMISDC[4] ,aGW1EMISDC[2] ,.T.,{||(cTabTemp)->GW1EMISDC}) // Cód. Emissor
	TRCell():New(oSection1, "(cTabTemp)->CNPJEMIS" , aCNPJEMIS[5] , STR0006 , aCNPJEMIS[4]  ,aCNPJEMIS[2]  ,.T.,{||(cTabTemp)->CNPJEMIS})  // CNPJ/CPF Emis.
	TRCell():New(oSection1, "(cTabTemp)->NMEMIS"   , aNMEMIS[5]   , STR0007 , aNMEMIS[4]    ,aNMEMIS[2]    ,.T.,{||(cTabTemp)->NMEMIS})    // Nome Emissor
	TRCell():New(oSection1, "(cTabTemp)->GW1SERDC" , aGW1SERDC[5] , STR0008 , aGW1SERDC[4]  ,aGW1SERDC[2]  ,.T.,{||(cTabTemp)->GW1SERDC})  // Série DC
	TRCell():New(oSection1, "(cTabTemp)->GW1NRDC"  , aGW1NRDC[5]  , STR0009 , aGW1NRDC[4]   ,aGW1NRDC[2]   ,.T.,{||(cTabTemp)->GW1NRDC})   // Número DC

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW1DANFE" , aGW1DANFE[5], STR0010 , aGW1DANFE[4] ,aGW1DANFE[2] ,.T.,{||(cTabTemp)->GW1DANFE}) // Chave Acesso
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->GW1DTEMIS", aGW1DTEMIS[5], STR0011 , aGW1DTEMIS[4] ,aGW1DTEMIS[2] ,.T.,{||(cTabTemp)->GW1DTEMIS}) // Dt. Emissão
	TRCell():New(oSection1, "(cTabTemp)->GW1DTIMPL", aGW1DTIMPL[5], STR0012 , aGW1DTIMPL[4] ,aGW1DTIMPL[2] ,.T.,{||(cTabTemp)->GW1DTIMPL}) // Dt. Implantação
	TRCell():New(oSection1, "(cTabTemp)->GW1DTSAI" , aGW1DTSAI[5] , STR0013 , aGW1DTSAI[4]  ,aGW1DTSAI[2]  ,.T.,{||(cTabTemp)->GW1DTSAI})  // Dt. Saída
	TRCell():New(oSection1, "(cTabTemp)->GW1USO"   , aGW1USO[5]   , STR0014 , aGW1USO[4]    ,aGW1USO[2]    ,.T.,{||(cTabTemp)->GW1USO})    // Finalidade

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW1REGCOM", aGW1REGCOM[5], STR0015 , aGW1REGCOM[4] ,aGW1REGCOM[2] ,.T.,{||(cTabTemp)->GW1REGCOM}) // Região Comercial
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->GW8ITEM"  , aGW8ITEM[5]  , STR0016 , aGW8ITEM[4]   ,aGW8ITEM[2]   ,.T.,{||(cTabTemp)->GW8ITEM})   // Item
	TRCell():New(oSection1, "(cTabTemp)->GW8DSITEM", aGW8DSITEM[5], STR0017 , aGW8DSITEM[4] ,aGW8DSITEM[2] ,.T.,{||(cTabTemp)->GW8DSITEM}) // Descrição Item
	TRCell():New(oSection1, "(cTabTemp)->GW8QTDE"  , aGW8QTDE[5]  , STR0018 , aGW8QTDE[4]   ,aGW8QTDE[2]   ,.T.,{||(cTabTemp)->GW8QTDE})   // Quantidade Item
	TRCell():New(oSection1, "(cTabTemp)->GW8VALOR" , aGW8VALOR[5] , STR0019 , aGW8VALOR[4]  ,aGW8VALOR[2]  ,.T.,{||(cTabTemp)->GW8VALOR})  // Valor Item
	TRCell():New(oSection1, "(cTabTemp)->GW8VOLUME", aGW8VOLUME[5], STR0020 , aGW8VOLUME[4] ,aGW8VOLUME[2] ,.T.,{||(cTabTemp)->GW8VOLUME}) // Volume Item
	TRCell():New(oSection1, "(cTabTemp)->GW8PESOC" , aGW8PESOC[5] , STR0021 , aGW8PESOC[4]  ,aGW8PESOC[2]  ,.T.,{||(cTabTemp)->GW8PESOC})  // Peso Cubado Item
	TRCell():New(oSection1, "(cTabTemp)->GW8PESOR" , aGW8PESOR[5] , STR0022 , aGW8PESOR[4]  ,aGW8PESOR[2]  ,.T.,{||(cTabTemp)->GW8PESOR})  // Peso Real Item
	TRCell():New(oSection1, "(cTabTemp)->GW8QTDALT", aGW8QTDALT[5], STR0023 , aGW8QTDALT[4] ,aGW8QTDALT[2] ,.T.,{||(cTabTemp)->GW8QTDALT}) // Quantidade/Peso Alt.
	TRCell():New(oSection1, "(cTabTemp)->GUBDSCLFR", aGUBDSCLFR[5], STR0024 , aGUBDSCLFR[4] ,aGUBDSCLFR[2] ,.T.,{||(cTabTemp)->GUBDSCLFR}) // Classificação De Frete
	TRCell():New(oSection1, "(cTabTemp)->GW8CFOP"  , aGW8CFOP[5]  , STR0025 , aGW8CFOP[4]   ,aGW8CFOP[2]   ,.T.,{||(cTabTemp)->GW8CFOP})   // CFOP

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW8INFO1", aGW8INFO1[5], IIf(_IntGFE ,STR0026 ,STR0027) ,aGW8INFO1[4] ,aGW8INFO1[2] , .T.,{||(cTabTemp)->GW8INFO1}) // Natureza de Operação // Info Contábil 1
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW8INFO2", aGW8INFO2[5], IIf(_IntGFE ,STR0028 ,STR0029) ,aGW8INFO2[4] ,aGW8INFO2[2] , .T.,{||(cTabTemp)->GW8INFO2}) // Canal de Vendas      // Info Contábil 2
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW8INFO3", aGW8INFO3[5], IIf(_IntGFE ,STR0030 ,STR0031) ,aGW8INFO3[4] ,aGW8INFO3[2] , .T.,{||(cTabTemp)->GW8INFO3}) // Grupo de Estoque     // Info Contábil 3
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW8INFO4", aGW8INFO4[5], IIf(_IntGFE ,STR0032 ,STR0033) ,aGW8INFO4[4] ,aGW8INFO4[2] , .T.,{||(cTabTemp)->GW8INFO4}) // Família Comercial    // Info Contábil 4
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW8INFO5", aGW8INFO5[5], IIf(_IntGFE ,STR0034 ,STR0035) ,aGW8INFO5[4] ,aGW8INFO5[2] , .T.,{||(cTabTemp)->GW8INFO5}) // Família de Materiais // Info Contábil 5
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->GW1CDREM"  , aGW1CDREM[5], STR0036 , aGW1CDREM[4] ,aGW1CDREM[2] ,.T.,{||(cTabTemp)->GW1CDREM}) // Código Remetente

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->CNPJREM" , aCNPJREM[5], STR0037 , aCNPJREM[4]  ,aCNPJREM[2]  ,.T.,{||(cTabTemp)->CNPJREM}) // CNPJ/CPF Remetente
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->NMREM"     , aNMREM[5]    , STR0038 , aNMREM[4]    ,aNMREM[2]    ,.T.,{||(cTabTemp)->NMREM})     // Nome Remetente
	TRCell():New(oSection1, "(cTabTemp)->GW1CDDEST" , aGW1CDDEST[5], STR0039 , aGW1CDDEST[4],aGW1CDDEST[2],.T.,{||(cTabTemp)->GW1CDDEST}) // Código Destinatário

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->CNPJDEST" , aCNPJDEST[5], STR0040 , aCNPJDEST[4] ,aCNPJDEST[2] ,.T.,{||(cTabTemp)->CNPJDEST}) // CNPJ/CPF Destinatário
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->NMDEST"     , aNMDEST[5]   , STR0041 , aNMDEST[4]   ,aNMDEST[2]   ,.T.,{||(cTabTemp)->NMDEST})    // Nome Destinatário
	TRCell():New(oSection1, "(cTabTemp)->GW1SITDES"  , aGW1SIT[5]   , STR0042 , aGW1SIT[4]   ,aGW1SIT[2]   ,.T.,{||(cTabTemp)->GW1SITDES})    // Situação
	TRCell():New(oSection1, "(cTabTemp)->GW0MSG"     , aGW0MSG[5]   , STR0043 , aGW0MSG[4]   ,aGW0MSG[2]   ,.T.,{||(cTabTemp)->GW0MSG})    // Motivo Bloqueio
	TRCell():New(oSection1, "(cTabTemp)->GW1CALCAT"  , aGW1CALCAT[5], STR0044 , aGW1CALCAT[4],aGW1CALCAT[2],.T.,{||(cTabTemp)->GW1CALCAT}) // Sit. Cálc Automático

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW1ROMTV" , aGW1ROMTV[5] , STR0045 , aGW1ROMTV[4] ,aGW1ROMTV[2] ,.T.,{||(cTabTemp)->GW1ROMTV}) // Tipo Veículo Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW1ROMCF" , aGW1ROMCF[5] , STR0046 , aGW1ROMCF[4] ,aGW1ROMCF[2] ,.T.,{||(cTabTemp)->GW1ROMCF}) // Classificação de Frete Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GW1ROMTO" , aGW1ROMTO[5] , STR0047 , aGW1ROMTO[4] ,aGW1ROMTO[2] ,.T.,{||(cTabTemp)->GW1ROMTO}) // Tipo de Operação Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GU3NRCID" , aGU3NRCID[5] , STR0048 , aGU3NRCID[4] ,aGU3NRCID[2] ,.T.,{||(cTabTemp)->GU3NRCID}) // Cód. Cidade Emit
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWUNRCIDO", aGWUNRCIDO[5], STR0049 , aGWUNRCIDO[4],aGWUNRCIDO[2],.T.,{||(cTabTemp)->GWUNRCIDO}) // Cód. Cidade Origem
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->NMCIDO"     , aNMCIDO[5] , STR0050 , aNMCIDO[4] ,aNMCIDO[2] ,.T.,{||(cTabTemp)->NMCIDO}) // Nome Cidade Origem
	TRCell():New(oSection1, "(cTabTemp)->UFO"        , aUFO[5]    , STR0051 , aUFO[4]    ,aUFO[2]    ,.T.,{||(cTabTemp)->UFO})    // UF Cidade Origem

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWUNRCIDD" , aGWUNRCIDD[5], STR0052 , aGWUNRCIDD[4],aGWUNRCIDD[2],.T.,{||(cTabTemp)->GWUNRCIDD}) // Cód. Cidade Destino
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->NMCIDD"     , aNMCIDD[5], STR0053 , aNMCIDD[4]   ,aNMCIDD[2]   ,.T.,{||(cTabTemp)->NMCIDD}) // Nome Cidade Destino
	TRCell():New(oSection1, "(cTabTemp)->UFD"        , aUFD[5]   , STR0054 , aUFD[4]      ,aUFD[2]      ,.T.,{||(cTabTemp)->UFD})    // UF Cidade Destino

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->NMREGP" , aNMREGP[5], STR0055 , aNMREGP[4]   ,aNMREGP[2]   ,.T.,{||(cTabTemp)->NMREGP}) // Região Própria
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->NMREGD" , aNMREGD[5], STR0056 , aNMREGD[4]   ,aNMREGD[2]   ,.T.,{||(cTabTemp)->NMREGD}) // Região Negociação Frete
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->GWUSEQ"    , aGWUSEQ[5]  , STR0057 , aGWUSEQ[4]   ,aGWUSEQ[2]   ,.T.,{||(cTabTemp)->GWUSEQ})   // Sequência do Itinerário
	TRCell():New(oSection1, "(cTabTemp)->GWUPAGAR"  , aGWUPAGAR[5], STR0058 , aGWUPAGAR[4] ,aGWUPAGAR[2] ,.T.,{||(cTabTemp)->GWUPAGAR}) // Pagar
	TRCell():New(oSection1, "(cTabTemp)->GWUCDTRP"  , aGWUCDTRP[5], STR0059 , aGWUCDTRP[4] ,aGWUCDTRP[2] ,.T.,{||(cTabTemp)->GWUCDTRP}) // Código Transportador

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->CNPJTRP" , aCNPJTRP[5], STR0060 , aCNPJTRP[4]  ,aCNPJTRP[2]  ,.T.,{||(cTabTemp)->CNPJTRP}) // CNPJ/CPF Transportador
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->NMTRP"     , aNMTRP[5], STR0061 , aNMTRP[4]    ,aNMTRP[2]    ,.T.,{||(cTabTemp)->NMTRP}) // Nome Transportador

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->AUTON"   , aAUTON[5] , STR0062 , aAUTON[4]    ,aAUTON[2]    ,.T.,{||(cTabTemp)->AUTON}) // Tipo Transportador
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->MODAL"     , aMODAL[5], STR0063 , aMODAL[4]    ,aMODAL[2]    ,.T.,{||(cTabTemp)->MODAL}) // Modal Transportador

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->TPTRIB"  , aTPTRIB[5], STR0064 , aTPTRIB[4]   ,aTPTRIB[2]   ,.T.,{||(cTabTemp)->TPTRIB}) // Regime Tributário Transp.
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "(cTabTemp)->GWNNRROM"  , aGWNNRROM[5] , STR0065 , aGWNNRROM[4] ,aGWNNRROM[2] ,.T.,{||(cTabTemp)->GWNNRROM})  // Número Romaneio
	TRCell():New(oSection1, "(cTabTemp)->GWNSIT"    , aGWNSIT[5]   , STR0066 , aGWNSIT[4]   ,aGWNSIT[2]   ,.T.,{||(cTabTemp)->GWNSIT})    // Situação Romaneio
	TRCell():New(oSection1, "(cTabTemp)->GWNCDTPVC" , aGWNCDTPVC[5], STR0067 , aGWNCDTPVC[4],aGWNCDTPVC[2],.T.,{||(cTabTemp)->GWNCDTPVC}) // Tipo de Veículo
	TRCell():New(oSection1, "(cTabTemp)->GWNCDCLFR" , aGWNCDCLFR[5], STR0068 , aGWNCDCLFR[4],aGWNCDCLFR[2],.T.,{||(cTabTemp)->GWNCDCLFR}) // Classificação de Frete Romaneio
	TRCell():New(oSection1, "(cTabTemp)->GWNCDTPOP" , aGWNCDTPOP[5], STR0069 , aGWNCDTPOP[4],aGWNCDTPOP[2],.T.,{||(cTabTemp)->GWNCDTPOP}) // Tipo de Operação
	TRCell():New(oSection1, "(cTabTemp)->GWNCALC"   , aGWNCALC[5]  , STR0070 , aGWNCALC[4]  ,aGWNCALC[2]  ,.T.,{||(cTabTemp)->GWNCALC})   // Situação Cálculo
	TRCell():New(oSection1, "(cTabTemp)->GWNMTCALC" , aGWNMTCALC[5], STR0071 , aGWNMTCALC[4],aGWNMTCALC[2],.T.,{||(cTabTemp)->GWNMTCALC}) // Motivo Cálculo
	TRCell():New(oSection1, "(cTabTemp)->GWNVPVAL"  , aGWNVPVAL[5] , STR0072 , aGWNVPVAL[4] ,aGWNVPVAL[2] ,.T.,{||(cTabTemp)->GWNVPVAL})  // Valor Pedágio
	TRCell():New(oSection1, "(cTabTemp)->GWUDTPENT" , aGWUDTPENT[5], STR0073 , aGWUDTPENT[4],aGWUDTPENT[2],.T.,{||(cTabTemp)->GWUDTPENT}) // Data Prevista Entrega
	TRCell():New(oSection1, "(cTabTemp)->GWUHRPENT" , aGWUHRPENT[5], STR0074 , aGWUHRPENT[4],aGWUHRPENT[2],.T.,{||(cTabTemp)->GWUHRPENT}) // Hora Prevista Entrega
	TRCell():New(oSection1, "(cTabTemp)->GWUDTENT"  , aGWUDTENT[5] , STR0075 , aGWUDTENT[4] ,aGWUDTENT[2] ,.T.,{||(cTabTemp)->GWUDTENT})  // Data Entrega
	TRCell():New(oSection1, "(cTabTemp)->GWUHRENT"  , aGWUHRENT[5] , STR0076 , aGWUHRENT[4] ,aGWUHRENT[2] ,.T.,{||(cTabTemp)->GWUHRENT})  // Hora Entrega
	TRCell():New(oSection1, "(cTabTemp)->GWFNRCALC" , aGWFNRCALC[5], STR0077 , aGWFNRCALC[4],aGWFNRCALC[2],.T.,{||(cTabTemp)->GWFNRCALC}) // Número Cálculo
	TRCell():New(oSection1, "(cTabTemp)->GWFTPFRET" , aGWFTPFRET[5], STR0078 , aGWFTPFRET[4],aGWFTPFRET[2],.T.,{||(cTabTemp)->GWFTPFRET}) // Tipo de Frete do Cálculo
	TRCell():New(oSection1, "(cTabTemp)->VLFRET"    , aVLFRET[5]   , STR0079 , aVLFRET[4]   ,aVLFRET[2]   ,.T.,{||(cTabTemp)->VLFRET})    // Valor Frete
	TRCell():New(oSection1, "(cTabTemp)->VLICMS"    , aVLICMS[5]   , STR0080 , aVLICMS[4]   ,aVLICMS[2]   ,.T.,{||(cTabTemp)->VLICMS})    // Valor ICMS
	TRCell():New(oSection1, "(cTabTemp)->VLPIS"     , aVLPIS[5]    , STR0081 , aVLPIS[4]    ,aVLPIS[2]    ,.T.,{||(cTabTemp)->VLPIS})     // Valor PIS
	TRCell():New(oSection1, "(cTabTemp)->VLCOFI"    , aVLCOFI[5]   , STR0082 , aVLCOFI[4]   ,aVLCOFI[2]   ,.T.,{||(cTabTemp)->VLCOFI})    // Valor COFINS

	If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
		TRCell():New(oSection1, "(cTabTemp)->VLIBS", aVLIBS[5]  , "Valor IBS Est", aVLIBS[4], aVLIBS[2], .T., {||(cTabTemp)->VLIBS})
		TRCell():New(oSection1, "(cTabTemp)->VLIBM", aVLIBM[5]  , "Valor IBS Mun", aVLIBM[4], aVLIBM[2], .T., {||(cTabTemp)->VLIBM})
		TRCell():New(oSection1, "(cTabTemp)->VLCBS", aVLCBS[5]  , "Valor CBS", aVLCBS[4], aVLCBS[2], .T., {||(cTabTemp)->VLCBS})
	EndIf

	TRCell():New(oSection1, "(cTabTemp)->GWFTPTRIB" , aGWFTPTRIB[5], STR0083 , aGWFTPTRIB[4],aGWFTPTRIB[2],.T.,{||(cTabTemp)->GWFTPTRIB}) // Tipo de Tributação
	TRCell():New(oSection1, "(cTabTemp)->GWFCRDICM" , aGWFCRDICM[5], STR0084 , aGWFCRDICM[4],aGWFCRDICM[2],.T.,{||(cTabTemp)->GWFCRDICM}) // Gera Crédito ICMS
	TRCell():New(oSection1, "(cTabTemp)->GWFCRDPC"  , aGWFCRDPC[5] , STR0085 , aGWFCRDPC[4] ,aGWFCRDPC[2] ,.T.,{||(cTabTemp)->GWFCRDPC})  // Gera Crédito PIS/COFINS
	TRCell():New(oSection1, "(cTabTemp)->GWGNRTAB"  , aGWGNRTAB[5] , STR0086 , aGWGNRTAB[4] ,aGWGNRTAB[2] ,.T.,{||(cTabTemp)->GWGNRTAB})  // Número Tabela de Frete
	TRCell():New(oSection1, "(cTabTemp)->GWGNRNEG"  , aGWGNRNEG[5] , STR0087 , aGWGNRNEG[4] ,aGWGNRNEG[2] ,.T.,{||(cTabTemp)->GWGNRNEG})  // Negociação
	TRCell():New(oSection1, "(cTabTemp)->GWGCDFXTV" , aGWGCDFXTV[5], STR0088 , aGWGCDFXTV[4],aGWGCDFXTV[2],.T.,{||(cTabTemp)->GWGCDFXTV}) // Faixa
	TRCell():New(oSection1, "(cTabTemp)->GWGCDTPOP" , aGWGCDTPOP[5], STR0089 , aGWGCDTPOP[4],aGWGCDTPOP[2],.T.,{||(cTabTemp)->GWGCDTPOP}) // Tipo de Operação
	TRCell():New(oSection1, "(cTabTemp)->GWGCDTPVC" , aGWGCDTPVC[5], STR0090 , aGWGCDTPVC[4],aGWGCDTPVC[2],.T.,{||(cTabTemp)->GWGCDTPVC}) // Tipo de Veículo
	TRCell():New(oSection1, "(cTabTemp)->GWGCDCLFR" , aGWGCDCLFR[5], STR0091 , aGWGCDCLFR[4],aGWGCDCLFR[2],.T.,{||(cTabTemp)->GWGCDCLFR}) // Class. Frete da Tab. de Frete
	TRCell():New(oSection1, "(cTabTemp)->GV9UNIFAI" , aGV9UNIFAI[5], STR0092 , aGV9UNIFAI[4],aGV9UNIFAI[2],.T.,{||(cTabTemp)->GV9UNIFAI}) // Unid. Faixa
	TRCell():New(oSection1, "(cTabTemp)->GWGNRROTA" , aGWGNRROTA[5], STR0093 , aGWGNRROTA[4],aGWGNRROTA[2],.T.,{||(cTabTemp)->GWGNRROTA}) // Rota
	TRCell():New(oSection1, "(cTabTemp)->DESCROTA"  , aDESCROTA[5] , STR0094 , aDESCROTA[4] ,aDESCROTA[2] ,.T.,{||(cTabTemp)->DESCROTA})  // Descrição da Rota

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWJNRPF"  , aGWJNRPF[5]  , STR0095 , aGWJNRPF[4]  ,aGWJNRPF[2]  ,.T.,{||(cTabTemp)->GWJNRPF})   // Número Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWJDTIMPL", aGWJDTIMPL[5], STR0096 , aGWJDTIMPL[4],aGWJDTIMPL[2],.T.,{||(cTabTemp)->GWJDTIMPL}) // Data de Implantação Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWJSIT"   , aGWJSIT[5]   , STR0097 , aGWJSIT[4]   ,aGWJSIT[2]   ,.T.,{||(cTabTemp)->GWJSIT})    // Situação Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GWJSITFIN", aGWJSITFIN[5], STR0098 , aGWJSITFIN[4],aGWJSITFIN[2],.T.,{||(cTabTemp)->GWJSITFIN}) // Situação Pré-Fatura Financeiro
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->CODLOTE"  , aCODLOTE[5]  , STR0099 , aCODLOTE[4]  ,aCODLOTE[2]  ,.T.,{||(cTabTemp)->CODLOTE})   // Código Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->GXFVALOR" , aGXFVALOR[5] , STR0100 , aGXFVALOR[4] ,aGXFVALOR[2] ,.T.,{||(cTabTemp)->GXFVALOR})  // Valor Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->PERLOTE"  , aPERLOTE[5]  , STR0101 , aPERLOTE[4]  ,aPERLOTE[2]  ,.T.,{||(cTabTemp)->PERLOTE})   // Período Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "(cTabTemp)->SITLOTE"  , aSITLOTE[5]  , STR0102 , aSITLOTE[4]  ,aSITLOTE[2]  ,.T.,{||(cTabTemp)->SITLOTE})   // Situação Lote
	oFieldHide:lUserEnabled := .F.

	If GFXTB12117("GXT")
		TRCell():New(oSection1, "(cTabTemp)->GXTNRCT" , aGXTNRCT[5], STR0103 , aGXTNRCT[4]  ,aGXTNRCT[2]  ,.T.,{||(cTabTemp)->GXTNRCT}) // Número Contrato Transp
	EndIf

	TRCell():New(oSection1, "(cTabTemp)->GW3CDESP"  , aGW3CDESP[5] , STR0104 , aGW3CDESP[4] ,aGW3CDESP[2] ,.T.,{||(cTabTemp)->GW3CDESP})  // Espécie Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3NRDF"   , aGW3NRDF[5]  , STR0105 , aGW3NRDF[4]  ,aGW3NRDF[2]  ,.T.,{||(cTabTemp)->GW3NRDF})   // Número Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3SERDF"  , aGW3SERDF[5] , STR0106 , aGW3SERDF[4] ,aGW3SERDF[2] ,.T.,{||(cTabTemp)->GW3SERDF})  // Série Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3TPDF"   , aGW3TPDF[5]  , STR0107 , aGW3TPDF[4]  ,aGW3TPDF[2]  ,.T.,{||(cTabTemp)->GW3TPDF})   // Tipo Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3DTENT"  , aGW3DTENT[5] , STR0108 , aGW3DTENT[4] ,aGW3DTENT[2] ,.T.,{||(cTabTemp)->GW3DTENT})  // Data de Entrada Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3DTEMIS" , aGW3DTEMIS[5], STR0109 , aGW3DTEMIS[4],aGW3DTEMIS[2],.T.,{||(cTabTemp)->GW3DTEMIS}) // Data de Emissão Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->VLFRETDF"  , aVLFRETDF[5] , STR0110 , aVLFRETDF[4] ,aVLFRETDF[2] ,.T.,{||(cTabTemp)->VLFRETDF})  // Valor Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->VLICMSDF"  , aVLICMSDF[5] , STR0111 , aVLICMSDF[4] ,aVLICMSDF[2] ,.T.,{||(cTabTemp)->VLICMSDF})  // Valor ICMS Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->VLPISDF"   , aVLPISDF[5]  , STR0112 , aVLPISDF[4]  ,aVLPISDF[2]  ,.T.,{||(cTabTemp)->VLPISDF})   // Valor PIS Doc. Frete
	TRCell():New(oSection1, "(cTabTemp)->VLCOFIDF"  , aVLCOFIDF[5] , STR0113 , aVLCOFIDF[4] ,aVLCOFIDF[2] ,.T.,{||(cTabTemp)->VLCOFIDF})  // Valor COFINS Doc. Frete

	If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
		TRCell():New(oSection1, "(cTabTemp)->VLIBSDF", aVLIBSDF[5] , "Valor IBS Est. Doc. Frete", aVLIBSDF[4], aVLIBSDF[2], .T., {||(cTabTemp)->VLIBSDF})
		TRCell():New(oSection1, "(cTabTemp)->VLIBMDF", aVLIBMDF[5] , "Valor IBS Mun. Doc. Frete", aVLIBMDF[4], aVLIBMDF[2], .T., {||(cTabTemp)->VLIBMDF})
		TRCell():New(oSection1, "(cTabTemp)->VLCBSDF", aVLCBSDF[5] , "Valor CBS Doc. Frete", aVLCBSDF[4], aVLCBSDF[2], .T., {||(cTabTemp)->VLCBSDF})
	EndIf

	TRCell():New(oSection1, "(cTabTemp)->GW3SIT"    , aGW3SIT[5]   , STR0114 , aGW3SIT[4]   ,aGW3SIT[2]   ,.T.,{||(cTabTemp)->GW3SIT})    // Situação Documento de Frete
	TRCell():New(oSection1, "(cTabTemp)->GXGEDISIT" , aGXGEDISIT[5], STR0115 , aGXGEDISIT[4],aGXGEDISIT[2],.T.,{||(cTabTemp)->GXGEDISIT}) // Situação EDI
	TRCell():New(oSection1, "(cTabTemp)->GW3MOTBLQ" , aGW3MOTBLQ[5], STR0116 , aGW3MOTBLQ[4],aGW3MOTBLQ[2],.T.,{||(cTabTemp)->GW3MOTBLQ}) // Motivo Divergência Conferência
	TRCell():New(oSection1, "(cTabTemp)->GW3SITFIS" , aGW3SITFIS[5], STR0117 , aGW3SITFIS[4],aGW3SITFIS[2],.T.,{||(cTabTemp)->GW3SITFIS}) // Situação Integração Fiscal
	TRCell():New(oSection1, "(cTabTemp)->GW3DTFIS"  , aGW3DTFIS[5] , STR0118 , aGW3DTFIS[4] ,aGW3DTFIS[2] ,.T.,{||(cTabTemp)->GW3DTFIS})  // Data Integração Fiscal
	TRCell():New(oSection1, "(cTabTemp)->GW3SITREC" , aGW3SITREC[5], STR0119 , aGW3SITREC[4],aGW3SITREC[2],.T.,{||(cTabTemp)->GW3SITREC}) // Situação Integração Recebedoria
	TRCell():New(oSection1, "(cTabTemp)->GW3DTREC"  , aGW3DTREC[5] , STR0120 , aGW3DTREC[4] ,aGW3DTREC[2] ,.T.,{||(cTabTemp)->GW3DTREC})  // Data Integração Recebedoria
	TRCell():New(oSection1, "(cTabTemp)->GW3SITCUS" , aGW3SITCUS[5], STR0121 , aGW3SITCUS[4],aGW3SITCUS[2],.T.,{||(cTabTemp)->GW3SITCUS}) // Situação Integ. Custo de Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3DTCUS"  , aGW3DTCUS[5] , STR0122 , aGW3DTCUS[4] ,aGW3DTCUS[2] ,.T.,{||(cTabTemp)->GW3DTCUS})  // Data Integ. Custo de Frete
	TRCell():New(oSection1, "(cTabTemp)->GW3SITMLA" , aGW3SITMLA[5], STR0123 , aGW3SITMLA[4],aGW3SITMLA[2],.T.,{||(cTabTemp)->GW3SITMLA}) // Situação Integração MLA
	TRCell():New(oSection1, "(cTabTemp)->GW6NRFAT"  , aGW6NRFAT[5] , STR0124 , aGW6NRFAT[4] ,aGW6NRFAT[2] ,.T.,{||(cTabTemp)->GW6NRFAT})  // Número Fatura
	TRCell():New(oSection1, "(cTabTemp)->GW6DTEMIS" , aGW6DTEMIS[5], STR0125 , aGW6DTEMIS[4],aGW6DTEMIS[2],.T.,{||(cTabTemp)->GW6DTEMIS}) // Data Emissão Fatura
	TRCell():New(oSection1, "(cTabTemp)->GW6VLFATU" , aGW6VLFATU[5], STR0126 , aGW6VLFATU[4],aGW6VLFATU[2],.T.,{||(cTabTemp)->GW6VLFATU}) // Valor Fatura
	TRCell():New(oSection1, "(cTabTemp)->GW6SITAPR" , aGW6SITAPR[5], STR0127 , aGW6SITAPR[4],aGW6SITAPR[2],.T.,{||(cTabTemp)->GW6SITAPR}) // Situação Fatura
	TRCell():New(oSection1, "(cTabTemp)->GW6DTFIN"  , aGW6DTFIN[5] , STR0128 , aGW6DTFIN[4] ,aGW6DTFIN[2] ,.T.,{||(cTabTemp)->GW6DTFIN})  // Data Integração Fatura
	TRCell():New(oSection1, "(cTabTemp)->GW6SITFIN" , aGW6SITFIN[5], STR0129 , aGW6SITFIN[4],aGW6SITFIN[2],.T.,{||(cTabTemp)->GW6SITFIN}) // Situação Integração Fatura
Return oReport
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint(oReport as object)
Função de impressão do relatório. Dentro dela que é chamada a função de carga do alias da Query.
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport as object)
	oSection := oReport:Section(1)
	oSection:Init()
	LoadTable()
	oSection:Finish()
Return Nil

Static Function GFER002Line()
	Local cLinha := ""
	If _cMvPar06 == 1
		oReport:SetMeter((cTabTemp)->(LastRec()))
		oSection:PrintLine()
		oReport:IncMeter()
	Else
		cLinha := (cTabTemp)->GW1FILIAL+";"
		cLinha += (cTabTemp)->GW1NMFIL+";"
		cLinha += (cTabTemp)->GW1CDTPDC+";"
		cLinha += (cTabTemp)->GW1EMISDC+";"
		cLinha += (cTabTemp)->CNPJEMIS+";"
		cLinha += (cTabTemp)->NMEMIS+";"
		cLinha += (cTabTemp)->GW1SERDC+";"
		cLinha += (cTabTemp)->GW1NRDC+";"
		cLinha += (cTabTemp)->GW1DANFE+";"
		cLinha += DtoC((cTabTemp)->GW1DTEMIS)+";"
		cLinha += DtoC((cTabTemp)->GW1DTIMPL)+";"
		cLinha += DtoC((cTabTemp)->GW1DTSAI)+";"
		cLinha += (cTabTemp)->GW1USO+";"
		cLinha += (cTabTemp)->GW1REGCOM+";"
		cLinha += (cTabTemp)->GW8ITEM+";"
		cLinha += (cTabTemp)->GW8DSITEM+";"
		cLinha += cValToChar((cTabTemp)->GW8QTDE)+";"
		cLinha += cValToChar((cTabTemp)->GW8VALOR)+";"
		cLinha += cValToChar((cTabTemp)->GW8VOLUME)+";"
		cLinha += cValToChar((cTabTemp)->GW8PESOC)+";"
		cLinha += cValToChar((cTabTemp)->GW8PESOR)+";"
		cLinha += cValToChar((cTabTemp)->GW8QTDALT)+";"
		cLinha += (cTabTemp)->GUBDSCLFR+";"
		cLinha += (cTabTemp)->GW8CFOP+";"
		cLinha += (cTabTemp)->GW8INFO1+";"
		cLinha += (cTabTemp)->GW8INFO2+";"
		cLinha += (cTabTemp)->GW8INFO3+";"
		cLinha += (cTabTemp)->GW8INFO4+";"
		cLinha += (cTabTemp)->GW8INFO5+";"
		cLinha += (cTabTemp)->GW1CDREM+";"
		cLinha += (cTabTemp)->CNPJREM+";"
		cLinha += (cTabTemp)->NMREM+";"
		cLinha += (cTabTemp)->GW1CDDEST+";"
		cLinha += (cTabTemp)->CNPJDEST+";"
		cLinha += (cTabTemp)->NMDEST+";"
		cLinha += (cTabTemp)->GW1SITDES+";"
		cLinha += (cTabTemp)->GW0MSG+";"
		cLinha += (cTabTemp)->GW1CALCAT+";"
		cLinha += (cTabTemp)->GW1ROMTV+";"
		cLinha += (cTabTemp)->GW1ROMCF+";"
		cLinha += (cTabTemp)->GW1ROMTO+";"
		cLinha += (cTabTemp)->GU3NRCID+";"
		cLinha += (cTabTemp)->GWUNRCIDO+";"
		cLinha += (cTabTemp)->NMCIDO+";"
		cLinha += (cTabTemp)->UFO+";"
		cLinha += (cTabTemp)->GWUNRCIDD+";"
		cLinha += (cTabTemp)->NMCIDD+";"
		cLinha += (cTabTemp)->UFD+";"
		cLinha += (cTabTemp)->NMREGP+";"
		cLinha += (cTabTemp)->NMREGD+";"
		cLinha += (cTabTemp)->GWUSEQ+";"
		cLinha += (cTabTemp)->GWUPAGAR+";"
		cLinha += (cTabTemp)->GWUCDTRP+";"
		cLinha += (cTabTemp)->CNPJTRP+";"
		cLinha += (cTabTemp)->NMTRP+";"
		cLinha += (cTabTemp)->AUTON+";"
		cLinha += (cTabTemp)->MODAL+";"
		cLinha += (cTabTemp)->TPTRIB+";"
		cLinha += (cTabTemp)->GWNNRROM+";"
		cLinha += (cTabTemp)->GWNSIT+";"
		cLinha += (cTabTemp)->GWNCDTPVC+";"
		cLinha += (cTabTemp)->GWNCDCLFR+";"
		cLinha += (cTabTemp)->GWNCDTPOP+";"
		cLinha += (cTabTemp)->GWNCALC+";"
		cLinha += (cTabTemp)->GWNMTCALC+";"
		cLinha += cValToChar((cTabTemp)->GWNVPVAL)+";"
		cLinha += DtoC((cTabTemp)->GWUDTPENT)+";"
		cLinha += (cTabTemp)->GWUHRPENT+";"
		cLinha += DtoC((cTabTemp)->GWUDTENT)+";"
		cLinha += (cTabTemp)->GWUHRENT+";"
		cLinha += (cTabTemp)->GWFNRCALC+";"
		cLinha += (cTabTemp)->GWFTPFRET+";"
		cLinha += cValToChar((cTabTemp)->VLFRET)+";"
		cLinha += cValToChar((cTabTemp)->VLICMS)+";"
		cLinha += cValToChar((cTabTemp)->VLPIS)+";"
		cLinha += cValToChar((cTabTemp)->VLCOFI)+";"
		If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
			cLinha += cValToChar((cTabTemp)->VLIBS) + ";"
			cLinha += cValToChar((cTabTemp)->VLIBM) + ";"
			cLinha += cValToChar((cTabTemp)->VLCBS) + ";"
		EndIf
		cLinha += (cTabTemp)->GWFTPTRIB+";"
		cLinha += (cTabTemp)->GWFCRDICM+";"
		cLinha += (cTabTemp)->GWFCRDPC+";"
		cLinha += (cTabTemp)->GWGNRTAB+";"
		cLinha += (cTabTemp)->GWGNRNEG+";"
		cLinha += (cTabTemp)->GWGCDFXTV+";"
		cLinha += (cTabTemp)->GWGCDTPOP+";"
		cLinha += (cTabTemp)->GWGCDTPVC+";"
		cLinha += (cTabTemp)->GWGCDCLFR+";"
		cLinha += (cTabTemp)->GV9UNIFAI+";"
		cLinha += (cTabTemp)->GWGNRROTA+";"
		cLinha += (cTabTemp)->DESCROTA+";"
		cLinha += (cTabTemp)->GWJNRPF+";"
		cLinha += DtoC((cTabTemp)->GWJDTIMPL)+";"
		cLinha += (cTabTemp)->GWJSIT+";"
		cLinha += (cTabTemp)->GWJSITFIN+";"
		cLinha += (cTabTemp)->CODLOTE+";"
		cLinha += cValToChar((cTabTemp)->GXFVALOR)+";"
		cLinha += (cTabTemp)->PERLOTE+";"
		cLinha += (cTabTemp)->SITLOTE+";"
		cLinha += (cTabTemp)->GXTNRCT+";"
		cLinha += (cTabTemp)->GW3CDESP+";"
		cLinha += (cTabTemp)->GW3NRDF+";"
		cLinha += (cTabTemp)->GW3SERDF+";"
		cLinha += (cTabTemp)->GW3TPDF+";"
		cLinha += DtoC((cTabTemp)->GW3DTENT)+";"
		cLinha += DtoC((cTabTemp)->GW3DTEMIS)+";"
		cLinha += cValToChar((cTabTemp)->VLFRETDF)+";"
		cLinha += cValToChar((cTabTemp)->VLICMSDF)+";"
		cLinha += cValToChar((cTabTemp)->VLPISDF)+";"
		cLinha += cValToChar((cTabTemp)->VLCOFIDF)+";"
		If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
			cLinha += cValToChar((cTabTemp)->VLIBSDF) + ";"
			cLinha += cValToChar((cTabTemp)->VLIBMDF) + ";"
			cLinha += cValToChar((cTabTemp)->VLCBSDF) + ";"
		EndIf
		cLinha += (cTabTemp)->GW3SIT+";"
		cLinha += (cTabTemp)->GXGEDISIT+";"
		cLinha += (cTabTemp)->GW3MOTBLQ+";"
		cLinha += (cTabTemp)->GW3SITFIS+";"
		cLinha += DtoC((cTabTemp)->GW3DTFIS)+";"
		cLinha += (cTabTemp)->GW3SITREC+";"
		cLinha += DtoC((cTabTemp)->GW3DTREC)+";"
		cLinha += (cTabTemp)->GW3SITCUS+";"
		cLinha += DtoC((cTabTemp)->GW3DTCUS)+";"
		cLinha += (cTabTemp)->GW3SITMLA+";"
		cLinha += (cTabTemp)->GW6NRFAT+";"
		cLinha += DtoC((cTabTemp)->GW6DTEMIS)+";"
		cLinha += cValToChar((cTabTemp)->GW6VLFATU)+";"
		cLinha += (cTabTemp)->GW6SITAPR+";"
		cLinha += DtoC((cTabTemp)->GW6DTFIN)+";"
		cLinha += (cTabTemp)->GW6SITFIN


		FWrite(nHandle, cLinha + CRLF)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTable()
Query que carrega a tabela temporária
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTable()
	Local cDtDe      := ""
	Local cDtAte     := ""
	Local cDtEmisDe  := ""
	Local cDtEmisAte := ""
	Local cCampos    := ""
	Local cSelGWM 	 := ""
	Local cSelGWMDF  := ""
	Local cWhere     := ""
	Local cJoinGWN   := ""
	Local cAliasQry  := Nil
	Local cAliasGW0  := Nil
	Local cAliasGXZ  := Nil
	Local cAliasGXY  := Nil
	Local cChave     := ""
	//Tipo de Rateio configurado no sistema
	Local cTpRat     := SuperGetMV('MV_CRIRAT', .F., '1')
	Local cTpReg     := SuperGetMV('MV_TIPREG', .F., '1')
	Local cEmit		 := ""
	Local cTrp       := ""
	Local aAuxEmit	 := {}
	Local nX		 := 0
	Local cAliasGWU  := Nil
	Local cGWMOrd    := ""
	Local cGWMDFOrd  := ""
	Local cAliasGWF  := Nil 
	Local cAliasGW3  := Nil 
	Local cAliasGWH  := Nil

	Private cTabTemp	:= ""

	cDtDe       := _cMvPar01
	cDtAte      := _cMvPar02
	cDtEmisDe   := _cMvPar03
	cDtEmisAte  := _cMvPar04
	
	cTabTemp := CriaTab()
	dbSelectArea(cTabTemp)

	If _cMvPar05 == 1 .Or. _cMvPar05 == 2
		cCampos := ""
		Do Case
		Case cTpRat == "1"
			cSelGWM := "GWM.GWM_VLFRET AS VLFRET,"
			cSelGWM += "GWM.GWM_VLICMS AS VLICMS,"
			cSelGWM += "GWM.GWM_VLPIS AS VLPIS,"
			cSelGWM += "GWM.GWM_VLCOFI AS VLCOFI"
			cSelGWM += Iif(GFXCP2510("GWM_VLIBS"), ",GWM.GWM_VLIBS AS VLIBS", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLIBM"), ",GWM.GWM_VLIBM AS VLIBM", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLCBS"), ",GWM.GWM_VLCBS AS VLCBS", "")
			
			cGWMOrd := "GWM.GWM_VLFRET,"
			cGWMOrd += "GWM.GWM_VLICMS,"
			cGWMOrd += "GWM.GWM_VLPIS,"
			cGWMOrd += "GWM.GWM_VLCOFI"
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBS"), ",GWM.GWM_VLIBS", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBM"), ",GWM.GWM_VLIBM", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLCBS"), ",GWM.GWM_VLCBS", "")
			
			cSelGWMDF := "GWMDF.GWM_VLFRET AS VLFRETDF,"
			cSelGWMDF += "GWMDF.GWM_VLICMS AS VLICMSDF,"
			cSelGWMDF += "GWMDF.GWM_VLPIS AS VLPISDF,"
			cSelGWMDF += "GWMDF.GWM_VLCOFI AS VLCOFIDF"
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBS"), ",GWMDF.GWM_VLIBS AS VLIBSDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBM"), ",GWMDF.GWM_VLIBM AS VLIBMDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLCBS"), ",GWMDF.GWM_VLCBS AS VLCBSDF", "")
			
			cGWMDFOrd := "GWMDF.GWM_VLFRET,"
			cGWMDFOrd += "GWMDF.GWM_VLICMS,"
			cGWMDFOrd += "GWMDF.GWM_VLPIS,"
			cGWMDFOrd += "GWMDF.GWM_VLCOFI"
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBS"), ",GWMDF.GWM_VLIBS", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBM"), ",GWMDF.GWM_VLIBM", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLCBS"), ",GWMDF.GWM_VLCBS", "")
		Case cTpRat == "2"
			cSelGWM := "GWM.GWM_VLFRE1 AS VLFRET,"
			cSelGWM += "GWM.GWM_VLICM1 AS VLICMS,"
			cSelGWM += "GWM.GWM_VLPIS1 AS VLPIS,"
			cSelGWM += "GWM.GWM_VLCOF1 AS VLCOFI"
			cSelGWM += Iif(GFXCP2510("GWM_VLIBS1"), ",GWM.GWM_VLIBS1 AS VLIBS", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLIBM1"), ",GWM.GWM_VLIBM1 AS VLIBM", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLCBS1"), ",GWM.GWM_VLCBS1 AS VLCBS", "")

			cGWMOrd := "GWM.GWM_VLFRE1,"
			cGWMOrd += "GWM.GWM_VLICM1,"
			cGWMOrd += "GWM.GWM_VLPIS1,"
			cGWMOrd += "GWM.GWM_VLCOF1"
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBS1"), ",GWM.GWM_VLIBS1", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBM1"), ",GWM.GWM_VLIBM1", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLCBS1"), ",GWM.GWM_VLCBS1", "")

			cSelGWMDF := "GWMDF.GWM_VLFRE1 AS VLFRETDF,"
			cSelGWMDF += "GWMDF.GWM_VLICM1 AS VLICMSDF,"
			cSelGWMDF += "GWMDF.GWM_VLPIS1 AS VLPISDF,"
			cSelGWMDF += "GWMDF.GWM_VLCOF1 AS VLCOFIDF"
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBS1"), ",GWMDF.GWM_VLIBS1 AS VLIBSDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBM1"), ",GWMDF.GWM_VLIBM1 AS VLIBMDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLCBS1"), ",GWMDF.GWM_VLCBS1 AS VLCBSDF", "")

			cGWMDFOrd := "GWMDF.GWM_VLFRE1,"
			cGWMDFOrd += "GWMDF.GWM_VLICM1,"
			cGWMDFOrd += "GWMDF.GWM_VLPIS1,"
			cGWMDFOrd += "GWMDF.GWM_VLCOF1"
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBS1"), ",GWMDF.GWM_VLIBS1", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBM1"), ",GWMDF.GWM_VLIBM1", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLCBS1"), ",GWMDF.GWM_VLCBS1", "")
		Case cTpRat == "3"
			cSelGWM := "GWM.GWM_VLFRE3 AS VLFRET,"
			cSelGWM += "GWM.GWM_VLICM3 AS VLICMS,"
			cSelGWM += "GWM.GWM_VLPIS3 AS VLPIS,"
			cSelGWM += "GWM.GWM_VLCOF3 AS VLCOFI"
			cSelGWM += Iif(GFXCP2510("GWM_VLIBS3"), ",GWM.GWM_VLIBS3 AS VLIBS", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLIBM3"), ",GWM.GWM_VLIBM3 AS VLIBM", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLCBS3"), ",GWM.GWM_VLCBS3 AS VLCBS", "")

			cGWMOrd := "GWM.GWM_VLFRE3,"
			cGWMOrd += "GWM.GWM_VLICM3,"
			cGWMOrd += "GWM.GWM_VLPIS3,"
			cGWMOrd += "GWM.GWM_VLCOF3"
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBS3"), ",GWM.GWM_VLIBS3", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBM3"), ",GWM.GWM_VLIBM3", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLCBS3"), ",GWM.GWM_VLCBS3", "")

			cSelGWMDF := "GWMDF.GWM_VLFRE3 AS VLFRETDF,"
			cSelGWMDF += "GWMDF.GWM_VLICM3 AS VLICMSDF,"
			cSelGWMDF += "GWMDF.GWM_VLPIS3 AS VLPISDF,"
			cSelGWMDF += "GWMDF.GWM_VLCOF3 AS VLCOFIDF"
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBS3"), ",GWMDF.GWM_VLIBS3 AS VLIBSDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBM3"), ",GWMDF.GWM_VLIBM3 AS VLIBMDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLCBS3"), ",GWMDF.GWM_VLCBS3 AS VLCBSDF", "")

			cGWMDFOrd := "GWMDF.GWM_VLFRE3,"
			cGWMDFOrd += "GWMDF.GWM_VLICM3,"
			cGWMDFOrd += "GWMDF.GWM_VLPIS3,"
			cGWMDFOrd += "GWMDF.GWM_VLCOF3"
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBS3"), ",GWMDF.GWM_VLIBS3", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBM3"), ",GWMDF.GWM_VLIBM3", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLCBS3"), ",GWMDF.GWM_VLCBS3", "")
		Case cTpRat == "4"
			cSelGWM := "GWM.GWM_VLFRE2 AS VLFRET,"
			cSelGWM += "GWM.GWM_VLICM2 AS VLICMS,"
			cSelGWM += "GWM.GWM_VLPIS2 AS VLPIS,"
			cSelGWM += "GWM.GWM_VLCOF2 AS VLCOFI"
			cSelGWM += Iif(GFXCP2510("GWM_VLIBS2"), ",GWM.GWM_VLIBS2 AS VLIBS", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLIBM2"), ",GWM.GWM_VLIBM2 AS VLIBM", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLCBS2"), ",GWM.GWM_VLCBS2 AS VLCBS", "")

			cGWMOrd := "GWM.GWM_VLFRE2,"
			cGWMOrd += "GWM.GWM_VLICM2,"
			cGWMOrd += "GWM.GWM_VLPIS2,"
			cGWMOrd += "GWM.GWM_VLCOF2"
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBS2"), ",GWM.GWM_VLIBS2", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBM2"), ",GWM.GWM_VLIBM2", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLCBS2"), ",GWM.GWM_VLCBS2", "")

			cSelGWMDF := "GWMDF.GWM_VLFRE2 AS VLFRETDF,"
			cSelGWMDF += "GWMDF.GWM_VLICM2 AS VLICMSDF,"
			cSelGWMDF += "GWMDF.GWM_VLPIS2 AS VLPISDF,"
			cSelGWMDF += "GWMDF.GWM_VLCOF2 AS VLCOFIDF"
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBS2"), ",GWMDF.GWM_VLIBS2 AS VLIBSDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBM2"), ",GWMDF.GWM_VLIBM2 AS VLIBMDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLCBS2"), ",GWMDF.GWM_VLCBS2 AS VLCBSDF", "")

			cGWMDFOrd := "GWMDF.GWM_VLFRE2,"
			cGWMDFOrd += "GWMDF.GWM_VLICM2,"
			cGWMDFOrd += "GWMDF.GWM_VLPIS2,"
			cGWMDFOrd += "GWMDF.GWM_VLCOF2"
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBS2"), ",GWMDF.GWM_VLIBS2", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBM2"), ",GWMDF.GWM_VLIBM2", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLCBS2"), ",GWMDF.GWM_VLCBS2", "")
		Otherwise
			cSelGWM := "GWM.GWM_VLFRET AS VLFRET,"
			cSelGWM += "GWM.GWM_VLICMS AS VLICMS,"
			cSelGWM += "GWM.GWM_VLPIS  AS VLPIS,"
			cSelGWM += "GWM.GWM_VLCOFI AS VLCOFI"
			cSelGWM += Iif(GFXCP2510("GWM_VLIBS"), ",GWM.GWM_VLIBS AS VLIBS", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLIBM"), ",GWM.GWM_VLIBM AS VLIBM", "")
			cSelGWM += Iif(GFXCP2510("GWM_VLCBS"), ",GWM.GWM_VLCBS AS VLCBS", "")

			cGWMOrd := "GWM.GWM_VLFRET,"
			cGWMOrd += "GWM.GWM_VLICMS,"
			cGWMOrd += "GWM.GWM_VLPIS,"
			cGWMOrd += "GWM.GWM_VLCOFI"
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBS"), ",GWM.GWM_VLIBS", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLIBM"), ",GWM.GWM_VLIBM", "")
			cGWMOrd += Iif(GFXCP2510("GWM_VLCBS"), ",GWM.GWM_VLCBS", "")

			cSelGWMDF := "GWMDF.GWM_VLFRET AS VLFRETDF,"
			cSelGWMDF += "GWMDF.GWM_VLICMS AS VLICMSDF,"
			cSelGWMDF += "GWMDF.GWM_VLPIS AS VLPISDF,"
			cSelGWMDF += "GWMDF.GWM_VLCOFI AS VLCOFIDF"
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBS"), ",GWMDF.GWM_VLIBS AS VLIBSDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLIBM"), ",GWMDF.GWM_VLIBM AS VLIBMDF", "")
			cSelGWMDF += Iif(GFXCP2510("GWM_VLCBS"), ",GWMDF.GWM_VLCBS AS VLCBSDF", "")

			cGWMDFOrd := "GWMDF.GWM_VLFRET,"
			cGWMDFOrd += "GWMDF.GWM_VLICMS,"
			cGWMDFOrd += "GWMDF.GWM_VLPIS,"
			cGWMDFOrd += "GWMDF.GWM_VLCOFI"
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBS"), ",GWMDF.GWM_VLIBS", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLIBM"), ",GWMDF.GWM_VLIBM", "")
			cGWMDFOrd += Iif(GFXCP2510("GWM_VLCBS"), ",GWMDF.GWM_VLCBS", "")
		EndCase

		cWhere 	  := ""
		cSelGWM   := "%" + cSelGWM + "%"
		cSelGWMDF := "%" + cSelGWMDF + "%"
		cGWMOrd   := "%" + cGWMOrd + "%"
		cGWMDFOrd := "%" + cGWMDFOrd + "%"

		If !Empty(cDtAte) .And. cDtAte >= cDtDe
			cWhere += " AND GW1.GW1_DTIMPL >= '"+cDtDe+"' AND GW1.GW1_DTIMPL <= '"+cDtAte+"'"
		EndIf
		If !Empty(cDtEmisAte) .And. cDtEmisAte >= cDtEmisDe
			cWhere += " AND GW1.GW1_DTEMIS >= '"+cDtEmisDe+"' AND GW1.GW1_DTEMIS <= '"+cDtEmisAte+"'"
		EndIf
		cWhere := "%" + cWhere + "%"

		If GFXCP1212210('GW1_FILROM')
			cJoinGWN := "GW1.GW1_FILROM"
		Else
			cJoinGWN := "GW1.GW1_FILIAL"
		EndIf
		cJoinGWN := "%" + cJoinGWN + "%"

		// Busca emitentes com a mesma raiz de CNPJ
		cAliasGWU := GetNextAlias()
		BeginSQL Alias cAliasGWU
			SELECT DISTINCT GWU.GWU_CDTRP
				FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL  = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC  = GW1.GW1_SERDC
			AND GWU.GWU_NRDC   = GW1.GW1_NRDC
			AND GWU.%NotDel%
			WHERE GW1.%NotDel%
			%Exp:cWhere%
		EndSql

		(cAliasGWU)->(dbGoTop())
		Do While (cAliasGWU)->(!Eof())
			If !Empty((cAliasGWU)->GWU_CDTRP)
				cTrp := (cAliasGWU)->GWU_CDTRP
				cEmit +=  "'" + GFEGetEmRz(cTrp) + "',"
				aAuxEmit := Strtokarr(cEmit,",")
			EndIf
			(cAliasGWU)->(dbSkip())
		EndDo

		cEmit := ""
		For nX := 1 to Len(aAuxEmit)
			If nX == Len(aAuxEmit)
				cEmit += aAuxEmit[nX]
			Else
				cEmit += aAuxEmit[nX] + ","
			EndIf
		Next

		If Empty(cEmit)
			cEmit := "%''%"
		Else 
			cEmit := "%" + cEmit + "%"
		EndIf
		
		cAliasGWF := GetNextAlias()
		BeginSQL Alias cAliasGWF
			SELECT GW1.GW1_FILIAL,
					GW1.GW1_CDTPDC,
					GW1.GW1_EMISDC,
					GW1.GW1_SERDC,
					GW1.GW1_NRDC,
					GW1.GW1_TPFRET,
					GU3EMIS.GU3_NMEMIT AS NMEMIS,
					GU3EMIS.GU3_IDFED AS CNPJEMIS,
					GU3EMIS.GU3_NRCID AS GU3NRCID,
					GW1.GW1_DANFE, 
					GW1.GW1_DTEMIS, 
					GW1.GW1_DTIMPL,
					GW1.GW1_DTSAI,
					GW1.GW1_USO,
					GW1.GW1_REPRES,
					GW1.GW1_REGCOM,
					GW8.GW8_CDCLFR,
					GW8.GW8_SEQ,
					GW8.GW8_ITEM,
					GW8.GW8_DSITEM,
					GW8.GW8_QTDE,
					GW8.GW8_VALOR,
					GW8.GW8_VOLUME,
					GW8.GW8_PESOC,
					GW8.GW8_PESOR,
					GW8.GW8_QTDALT,
					GUB.GUB_DSCLFR,
					GW8.GW8_CFOP,
					GW8.GW8_INFO1,
					GW8.GW8_INFO2,
					GW8.GW8_INFO3,
					GW8.GW8_INFO4,
					GW8.GW8_INFO5,
					GW1.GW1_CDREM,
					GU3REM.GU3_NMEMIT AS NMREM,
					GU3REM.GU3_IDFED AS CNPJREM,
					GW1.GW1_CDDEST,
					GU3DES.GU3_NMEMIT AS NMDEST,
					GU3DES.GU3_IDFED AS CNPJDEST,
					GW1.GW1_SIT,
					GW1.GW1_CALCAT,
					GW1.GW1_ROMTV,
					GW1.GW1_ROMCF,
					GW1.GW1_ROMTO,
					GWU.GWU_NRCIDO,
					GU7ORI.GU7_NMCID AS NMCIDO,
					GU7ORI.GU7_CDUF AS UFO,
					GWU.GWU_NRCIDD,
					GU7DST.GU7_NMCID AS NMCIDD,
					GU7DST.GU7_CDUF AS UFD,
					GWU.GWU_SEQ,
					GWU.GWU_PAGAR,
					GWU.GWU_CDTRP,
					GU3TRP.GU3_IDFED AS CNPJTRP,
					GU3TRP.GU3_NMEMIT AS NMTRP,
					GU3TRP.GU3_AUTON AS AUTON,
					GU3TRP.GU3_MODAL AS MODAL,
					GU3TRP.GU3_TPTRIB AS TPTRIB,
					GWN.GWN_NRROM,
					GWN.GWN_SIT,
					GWN.GWN_CDTPVC,
					GWN.GWN_CDCLFR,
					GWN.GWN_CDTPOP,
					GWN.GWN_CALC,
					GWN.GWN_VPVAL,
					GWU.GWU_DTPENT,
					GWU.GWU_HRPENT,
					GWU.GWU_DTENT,
					GWU.GWU_HRENT,
					GWG.GWG_NRTAB,
					GWG.GWG_NRNEG,
					GWG.GWG_CDFXTV,
					GWG.GWG_NRROTA,
					GWG.GWG_CDTPOP,
					GWG.GWG_CDTPVC,
					GWG.GWG_CDCLFR,
					GWJ.GWJ_NRPF,
					GWJ.GWJ_DTIMPL,
					GWJ.GWJ_SIT,
					GWJ.GWJ_SITFIN,
					GXE.GXE_CODLOT AS CODLOTE,
    				GXF.GXF_VALOR,
					GXE.GXE_PERIOD AS PERLOTE,
					GXE.GXE_SIT AS SITLOTE,
					GWF.GWF_NRCALC,
					GWF.GWF_TPFRET,
					GWF.GWF_TPCALC,
					GWF.GWF_TPTRIB,
					GWF.GWF_CRDICM,
					GWF.GWF_CRDPC,
					GWF.GWF_NRDF,
					GWF.GWF_CDESP,
					GWF.GWF_EMISDF,
					GWF.GWF_SERDF,
					GWF.GWF_DTEMDF,
					GV8.GV8_NRREDS,
					GW1.GW1_NRREG,
					GU9A.GU9_NMREG AS NMNRREDS,
					GU9B.GU9_NMREG AS NMNRREG,
					GWM.GWM_NRDOC,
					GWM.GWM_TPDOC,
					GWM.GWM_CDESP,
					GV9.GV9_UNIFAI,
					%Exp:cSelGWM%
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.%NotDel%

			INNER JOIN %Table:GW8% GW8
			ON GW8.GW8_FILIAL = GW1.GW1_FILIAL
			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
			AND GW8.GW8_SERDC = GW1.GW1_SERDC
			AND GW8.GW8_NRDC = GW1.GW1_NRDC
			AND GW8.%NotDel%

			INNER JOIN %Table:GWH% GWH
			ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
			AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
			AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
			AND GWH.GWH_SERDC = GW1.GW1_SERDC
			AND GWH.GWH_NRDC = GW1.GW1_NRDC
			AND GWH.GWH_TRECHO = GWU.GWU_SEQ
			AND GWH.%NotDel%

			LEFT JOIN %Table:GWN% GWN
			ON GWN.GWN_FILIAL = %Exp:cJoinGWN%
			AND GWN.GWN_NRROM = GW1.GW1_NRROM
			AND GWN.%NotDel%

			INNER JOIN %Table:GWF% GWF
			ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
			AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
			AND GWF.%NotDel%

			LEFT JOIN %Table:GWG% GWG
			ON GWG.GWG_FILIAL = GWH.GWH_FILIAL
			AND GWG.GWG_NRCALC = GWH.GWH_NRCALC
			AND GWG.GWG_CDCLFR = GW8.GW8_CDCLFR
			AND GWG.%NotDel%
			
			LEFT JOIN %Table:GV8% GV8
			ON GV8.GV8_FILIAL = %xFilial:GV8%
			AND GV8.GV8_CDEMIT = GWG.GWG_CDEMIT
			AND GV8.GV8_NRTAB = GWG.GWG_NRTAB
			AND GV8.GV8_NRNEG = GWG.GWG_NRNEG
			AND GV8.GV8_NRROTA = GWG.GWG_NRROTA
			AND GV8.GV8_TPDEST = '2'
			AND GV8.%NotDel%

			LEFT JOIN %Table:GV9% GV9
			ON GV9.GV9_FILIAL  = %xFilial:GV9%
			AND GV9.GV9_CDEMIT = GWU.GWU_CDTRP
			AND GV9.GV9_NRTAB  = GWG.GWG_NRTAB
			AND GV9.GV9_NRNEG  = GWG.GWG_NRNEG
			AND GV9.%NotDel%

			LEFT JOIN %Table:GWM% GWM 
			ON GWM.GWM_FILIAL = GW1.GW1_FILIAL
			AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC
			AND GWM.GWM_EMISDC = GW1.GW1_EMISDC
			AND GWM.GWM_SERDC = GW1.GW1_SERDC
			AND GWM.GWM_NRDC = GW1.GW1_NRDC
			AND GWM.GWM_SEQGW8 = GW8.GW8_SEQ 
			AND GWM.GWM_TPDOC = '1'
			AND GWM.GWM_NRDOC = GWF.GWF_NRCALC 
			AND GWM.%NotDel%

			LEFT JOIN %Table:GWJ% GWJ
			ON GWJ.GWJ_FILIAL = GWF.GWF_FILPRE
			AND GWJ.GWJ_NRPF = GWF.GWF_NRPREF
			AND GWJ.%NotDel%

			LEFT JOIN %Table:GXD% GXD
			ON GXD.GXD_FILCAL = GWF.GWF_FILIAL
			AND GXD.GXD_NRCALC = GWF.GWF_NRCALC
			AND GXD.%NotDel%

			LEFT JOIN %Table:GXE% GXE 
			ON GXE.GXE_FILIAL = GXD.GXD_FILIAL
			AND GXE.GXE_CODLOT = GXD.GXD_CODLOT
			AND GXE.%NotDel%

			LEFT JOIN %Table:GXF% GXF  
			ON GXF.GXF_FILIAL = GXE.GXE_FILIAL
			AND GXF.GXF_CODLOT = GXE.GXE_CODLOT
			AND GXF.%NotDel%

			INNER JOIN %Table:GUB% GUB
			ON GUB.GUB_FILIAL = %xFilial:GUB%
			AND GUB.GUB_CDCLFR = GW8.GW8_CDCLFR
			AND GUB.%NotDel%

			INNER JOIN %Table:GU3% GU3EMIS
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3%
			AND GU3EMIS.GU3_CDEMIT = GW1.GW1_EMISDC
			AND GU3EMIS.%NotDel%

			INNER JOIN %Table:GU3% GU3REM
			ON GU3REM.GU3_FILIAL = %xFilial:GU3%
			AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM
			AND GU3REM.%NotDel%

			INNER JOIN %Table:GU3% GU3DES
			ON GU3DES.GU3_FILIAL = %xFilial:GU3%
			AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST
			AND GU3DES.%NotDel%

			LEFT JOIN %Table:GU3% GU3TRP
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP
			AND GU3TRP.%NotDel%

			LEFT JOIN %Table:GU7% GU7ORI
			ON GU7ORI.GU7_FILIAL = %xFilial:GU7%
			AND GU7ORI.GU7_NRCID = GWU.GWU_NRCIDO
			AND GU7ORI.%NotDel%

			LEFT JOIN %Table:GU7% GU7DST
			ON GU7DST.GU7_FILIAL = %xFilial:GU7%
			AND GU7DST.GU7_NRCID = GWU.GWU_NRCIDD
			AND GU7DST.%NotDel%

			LEFT JOIN %Table:GUB% GUBROM
			ON GUBROM.GUB_FILIAL = %xFilial:GUB%
			AND GUBROM.GUB_CDCLFR = GWN.GWN_CDCLFR
			AND GUBROM.%NotDel%

			LEFT JOIN %Table:GU9% GU9A
			ON GU9A.GU9_FILIAL = %xFilial:GU9%
			AND GU9A.GU9_NRREG = GV8.GV8_NRREDS
			AND GU9A.%NotDel%

			LEFT JOIN %Table:GU9% GU9B
			ON GU9B.GU9_FILIAL = %xFilial:GU9%
			AND GU9B.GU9_NRREG = GW1.GW1_NRREG
			AND GU9B.%NotDel%

			WHERE GW1.%NotDel%
			%Exp:cWhere%

			GROUP BY GW1.GW1_FILIAL,
					GW1.GW1_TPFRET,
					GW1.GW1_CDTPDC,
					GW1.GW1_EMISDC,
					GU3EMIS.GU3_NMEMIT,
					GU3EMIS.GU3_IDFED,
					GU3EMIS.GU3_NRCID,
					GW1.GW1_SERDC,
					GW1.GW1_NRDC,
					GW1.GW1_DANFE,
					GW1.GW1_DTEMIS,
					GW1.GW1_DTIMPL,
					GW1.GW1_DTSAI,
					GW1.GW1_USO,
					GW1.GW1_REPRES,
					GW1.GW1_REGCOM,
					GW8.GW8_CDCLFR,
					GW8.GW8_SEQ,
					GW8.GW8_ITEM,
					GW8.GW8_DSITEM,
					GW8.GW8_QTDE,
					GW8.GW8_VALOR,
					GW8.GW8_VOLUME,
					GW8.GW8_PESOC,
					GW8.GW8_PESOR,
					GW8.GW8_QTDALT,
					GUB.GUB_DSCLFR,
					GW8.GW8_CFOP,
					GW8.GW8_INFO1,
					GW8.GW8_INFO2,
					GW8.GW8_INFO3,
					GW8.GW8_INFO4,
					GW8.GW8_INFO5,
					GW1.GW1_CDREM,
					GU3REM.GU3_NMEMIT,
					GU3REM.GU3_IDFED,
					GW1.GW1_CDDEST,
					GU3DES.GU3_NMEMIT,
					GU3DES.GU3_IDFED,
					GW1.GW1_SIT,
					GW1.GW1_CALCAT,
					GW1.GW1_ROMTV,
					GW1.GW1_ROMCF,
					GW1.GW1_ROMTO,
					GUBROM.GUB_DSCLFR,
					GWU.GWU_NRCIDO,
					GU7ORI.GU7_NMCID,
					GU7ORI.GU7_CDUF,
					GWU.GWU_NRCIDD,
					GU7DST.GU7_NMCID,
					GU7DST.GU7_CDUF,
					GWU.GWU_SEQ,
					GWU.GWU_PAGAR,
					GWU.GWU_CDTRP,
					GU3TRP.GU3_IDFED,
					GU3TRP.GU3_NMEMIT,
					GU3TRP.GU3_AUTON,
					GU3TRP.GU3_MODAL,
					GU3TRP.GU3_TPTRIB,
					GWN.GWN_NRROM,
					GWN.GWN_SIT,
					GWN.GWN_CDTPVC,
					GWN.GWN_CDCLFR,
					GWN.GWN_CDTPOP,
					GWN.GWN_CALC,
					GWN.GWN_VPVAL,
					GWU.GWU_DTPENT,
					GWU.GWU_HRPENT,
					GWU.GWU_DTENT,
					GWU.GWU_HRENT,
					GWF.GWF_NRCALC,
					GWF.GWF_TPFRET,
					GWF.GWF_TPCALC,
					GWF.GWF_TPTRIB,
					GWF.GWF_CRDICM,
					GWF.GWF_CRDPC,
					GWF.GWF_NRDF,
					GWF.GWF_CDESP,
					GWF.GWF_EMISDF,
					GWF.GWF_SERDF,
					GWF.GWF_DTEMDF,
					GWG.GWG_NRTAB,
					GWG.GWG_NRNEG,
					GWG.GWG_CDFXTV,
					GWG.GWG_NRROTA,
					GWG.GWG_CDTPOP,
					GWG.GWG_CDTPVC,
					GWG.GWG_CDCLFR,
					GWJ.GWJ_NRPF,
					GWJ.GWJ_DTIMPL,
					GWJ.GWJ_SIT,
					GWJ.GWJ_SITFIN,
					GXE.GXE_CODLOT,
    				GXF.GXF_VALOR,
					GXE.GXE_PERIOD,
					GXE.GXE_SIT,
					GWF.GWF_NRDF,
					GWF.GWF_CDESP,
					GWF.GWF_EMISDF,
					GWF.GWF_SERDF,
					GV8.GV8_NRREDS,
					GW1.GW1_NRREG,
					GV9.GV9_UNIFAI,
					GWM.GWM_NRDOC,
					GWM.GWM_TPDOC,
					GWM.GWM_CDESP,
					GU9A.GU9_NMREG,
					GU9B.GU9_NMREG,
					%Exp:cGWMOrd%
			ORDER BY GWN.GWN_NRROM,
					GW1.GW1_DTIMPL,
					GW1.GW1_NRDC,
					GWU.GWU_SEQ,
					GWF.GWF_NRCALC
		EndSQL
		
		(cAliasGWF)->(dbGoTop())
		Do While (cAliasGWF)->(!Eof())
			RecLock(cTabTemp,.T.)
				(cTabTemp)->GW1FILIAL := (cAliasGWF)->GW1_FILIAL
				(cTabTemp)->GW1NMFIL  := FwFilName(cEmpAnt,(cTabTemp)->GW1FILIAL)
				(cTabTemp)->GW1CDTPDC := (cAliasGWF)->GW1_CDTPDC
				(cTabTemp)->GW1EMISDC := (cAliasGWF)->GW1_EMISDC
				(cTabTemp)->CNPJEMIS  := (cAliasGWF)->CNPJEMIS
				(cTabTemp)->NMEMIS    := (cAliasGWF)->NMEMIS
				(cTabTemp)->GW1SERDC  := (cAliasGWF)->GW1_SERDC
				(cTabTemp)->GW1NRDC   := (cAliasGWF)->GW1_NRDC
				(cTabTemp)->GW1DANFE  := (cAliasGWF)->GW1_DANFE
				(cTabTemp)->GW1DTEMIS := SToD((cAliasGWF)->GW1_DTEMIS)
				(cTabTemp)->GW1DTIMPL := SToD((cAliasGWF)->GW1_DTIMPL)
				(cTabTemp)->GW1DTSAI  := SToD((cAliasGWF)->GW1_DTSAI)
				(cTabTemp)->GW1USO    := RetUso((cAliasGWF)->GW1_USO)
				(cTabTemp)->GW1REGCOM := (cAliasGWF)->GW1_REGCOM
				(cTabTemp)->GW8ITEM   := (cAliasGWF)->GW8_ITEM
				(cTabTemp)->GW8DSITEM := FWNoAccent((cAliasGWF)->GW8_DSITEM)
				(cTabTemp)->GW8SEQ    := (cAliasGWF)->GW8_SEQ
				(cTabTemp)->GW8QTDE   := (cAliasGWF)->GW8_QTDE
				(cTabTemp)->GW8VALOR  := (cAliasGWF)->GW8_VALOR
				(cTabTemp)->GW8VOLUME := (cAliasGWF)->GW8_VOLUME
				(cTabTemp)->GW8PESOC  := (cAliasGWF)->GW8_PESOC
				(cTabTemp)->GW8PESOR  := (cAliasGWF)->GW8_PESOR
				(cTabTemp)->GW8QTDALT := (cAliasGWF)->GW8_QTDALT
				(cTabTemp)->GUBDSCLFR := (cAliasGWF)->GUB_DSCLFR
				(cTabTemp)->GW8CFOP   := (cAliasGWF)->GW8_CFOP
				(cTabTemp)->GW8INFO1  := (cAliasGWF)->GW8_INFO1
				(cTabTemp)->GW8INFO2  := (cAliasGWF)->GW8_INFO2
				(cTabTemp)->GW8INFO3  := (cAliasGWF)->GW8_INFO3
				(cTabTemp)->GW8INFO4  := (cAliasGWF)->GW8_INFO4
				(cTabTemp)->GW8INFO5  := (cAliasGWF)->GW8_INFO5
				(cTabTemp)->GW1CDREM  := (cAliasGWF)->GW1_CDREM
				(cTabTemp)->CNPJREM   := (cAliasGWF)->CNPJREM
				(cTabTemp)->NMREM     := (cAliasGWF)->NMREM
				(cTabTemp)->GW1CDDEST := (cAliasGWF)->GW1_CDDEST
				(cTabTemp)->CNPJDEST  := (cAliasGWF)->CNPJDEST
				(cTabTemp)->NMDEST    := (cAliasGWF)->NMDEST
				(cTabTemp)->GW1SIT	  := (cAliasGWF)->GW1_SIT
				(cTabTemp)->GW1SITDES := RetSitGW1((cAliasGWF)->GW1_SIT)
				(cTabTemp)->GW0MSG    := ""	
				(cTabTemp)->GW1CALCAT := RetCalcGW1((cAliasGWF)->GW1_CALCAT)
				(cTabTemp)->GW1ROMTV  := (cAliasGWF)->GW1_ROMTV
				(cTabTemp)->GW1ROMCF  := (cAliasGWF)->GW1_ROMCF
				(cTabTemp)->GW1ROMTO  := (cAliasGWF)->GW1_ROMTO
				(cTabTemp)->GU3NRCID  := (cAliasGWF)->GU3NRCID
				(cTabTemp)->GWUNRCIDO := (cAliasGWF)->GWU_NRCIDO
				(cTabTemp)->NMCIDO    := (cAliasGWF)->NMCIDO
				(cTabTemp)->UFO       := (cAliasGWF)->UFO
				(cTabTemp)->GWUNRCIDD := (cAliasGWF)->GWU_NRCIDD
				(cTabTemp)->NMCIDD    := (cAliasGWF)->NMCIDD
				(cTabTemp)->UFD       := (cAliasGWF)->UFD
				(cTabTemp)->NMREGP    := IIf(cTpReg == '2',(cAliasGWF)->NMNRREG,"")
				(cTabTemp)->NMREGD    := (cAliasGWF)->NMNRREDS
				(cTabTemp)->GWUSEQ    := (cAliasGWF)->GWU_SEQ
				(cTabTemp)->GWUPAGAR  := IIf((cAliasGWF)->GWU_PAGAR == "1","Sim","Não")
				(cTabTemp)->GWUCDTRP  := (cAliasGWF)->GWU_CDTRP
				(cTabTemp)->CNPJTRP   := (cAliasGWF)->CNPJTRP
				(cTabTemp)->NMTRP     := (cAliasGWF)->NMTRP
				(cTabTemp)->AUTON     := IIf((cAliasGWF)->AUTON == "1", "Autônomo","Transportador")
				(cTabTemp)->MODAL     := RetTpMod((cAliasGWF)->MODAL)
				(cTabTemp)->TPTRIB    := RetTpTrb((cAliasGWF)->TPTRIB)
				(cTabTemp)->GWNNRROM  := (cAliasGWF)->GWN_NRROM
				(cTabTemp)->GWNSIT    := RetSitRom((cAliasGWF)->GWN_SIT)
				(cTabTemp)->GWNCDTPVC := (cAliasGWF)->GWN_CDTPVC
				(cTabTemp)->GWNCDCLFR := (cAliasGWF)->GWN_CDCLFR
				(cTabTemp)->GWNCDTPOP := (cAliasGWF)->GWN_CDTPOP
				(cTabTemp)->GWNCALC   := RetCalcGWN((cAliasGWF)->GWN_CALC)
				(cTabTemp)->GWNMTCALC := rTrim(MemoLine(FWNoAccent(Posicione("GWN", 1, (cAliasGWF)->GW1_FILIAL+(cAliasGWF)->GWN_NRROM, "GWN_MTCALC")),128,1))
				(cTabTemp)->GWNVPVAL  := (cAliasGWF)->GWN_VPVAL
				(cTabTemp)->GWUDTPENT := SToD((cAliasGWF)->GWU_DTPENT)
				(cTabTemp)->GWUHRPENT := (cAliasGWF)->GWU_HRPENT
				(cTabTemp)->GWUDTENT  := SToD((cAliasGWF)->GWU_DTENT)
				(cTabTemp)->GWUHRENT  := (cAliasGWF)->GWU_HRENT
				(cTabTemp)->GWFNRCALC := (cAliasGWF)->GWF_NRCALC
				(cTabTemp)->GWFTPFRET := RetTpFrtCalc((cAliasGWF)->GW1_TPFRET)
				(cTabTemp)->VLFRET    := (cAliasGWF)->VLFRET
				(cTabTemp)->VLICMS    := (cAliasGWF)->VLICMS
				(cTabTemp)->VLPIS     := (cAliasGWF)->VLPIS
				(cTabTemp)->VLCOFI    := (cAliasGWF)->VLCOFI
				(cTabTemp)->VLIBS    := (cAliasGWF)->VLIBS
				(cTabTemp)->VLIBM    := (cAliasGWF)->VLIBM
				(cTabTemp)->VLCBS    := (cAliasGWF)->VLCBS
				(cTabTemp)->GWFTPTRIB := RetTpTrbGWF((cAliasGWF)->GWF_TPTRIB)
				(cTabTemp)->GWFCRDICM := IIf((cAliasGWF)->GWF_CRDICM == "1", "Sim", "Não")
				(cTabTemp)->GWFCRDPC  := IIf((cAliasGWF)->GWF_CRDPC == "1", "Sim", "Não")
				(cTabTemp)->GWFNRDF   := (cAliasGWF)->GWF_NRDF
				(cTabTemp)->GWFCDESP  := (cAliasGWF)->GWF_CDESP
				(cTabTemp)->GWFEMISDF := (cAliasGWF)->GWF_EMISDF
				(cTabTemp)->GWFSERDF  := (cAliasGWF)->GWF_SERDF
				(cTabTemp)->GWFDTMDF  := SToD((cAliasGWF)->GWF_DTEMDF)	
				(cTabTemp)->GWGNRTAB  := (cAliasGWF)->GWG_NRTAB
				(cTabTemp)->GWGNRNEG  := (cAliasGWF)->GWG_NRNEG
				(cTabTemp)->GWGCDFXTV := (cAliasGWF)->GWG_CDFXTV
				(cTabTemp)->GWGCDTPOP := (cAliasGWF)->GWG_CDTPOP
				(cTabTemp)->GWGCDTPVC := (cAliasGWF)->GWG_CDTPVC
				(cTabTemp)->GWGCDCLFR := (cAliasGWF)->GWG_CDCLFR
				(cTabTemp)->GV9UNIFAI := (cAliasGWF)->GV9_UNIFAI
				(cTabTemp)->GWGNRROTA := (cAliasGWF)->GWG_NRROTA
				(cTabTemp)->GWJNRPF   := (cAliasGWF)->GWJ_NRPF
				(cTabTemp)->GWJDTIMPL := SToD((cAliasGWF)->GWJ_DTIMPL)
				(cTabTemp)->GWJSIT    := (cAliasGWF)->GWJ_SIT
				(cTabTemp)->GWJSITFIN := (cAliasGWF)->GWJ_SITFIN
				(cTabTemp)->CODLOTE   := (cAliasGWF)->CODLOTE
				(cTabTemp)->GXFVALOR  := (cAliasGWF)->GXF_VALOR
				(cTabTemp)->PERLOTE   := (cAliasGWF)->PERLOTE
				(cTabTemp)->SITLOTE   := (cAliasGWF)->SITLOTE
			(cTabTemp)->(MsUnlock())
			(cAliasGWF)->(dbSkip())
		EndDo
		(cAliasGWF)->(dbCloseArea())

		cAliasGW3 := GetNextAlias()
		BeginSQL Alias cAliasGW3
			SELECT GW1.GW1_FILIAL,
				GW1.GW1_CDTPDC,
				GW1.GW1_EMISDC,
				GW1.GW1_SERDC,
				GW1.GW1_NRDC,
				GW1.GW1_TPFRET,
				GU3EMIS.GU3_NMEMIT AS NMEMIS,
				GU3EMIS.GU3_IDFED AS CNPJEMIS,
				GU3EMIS.GU3_NRCID AS GU3NRCID,
				GW1.GW1_DANFE, 
				GW1.GW1_DTEMIS, 
				GW1.GW1_DTIMPL,
				GW1.GW1_DTSAI,
				GW1.GW1_USO,
				GW1.GW1_REPRES,
				GW1.GW1_REGCOM,
				GW8.GW8_CDCLFR,
				GW8.GW8_SEQ,
				GW8.GW8_ITEM,
				GW8.GW8_DSITEM,
				GW8.GW8_QTDE,
				GW8.GW8_VALOR,
				GW8.GW8_VOLUME,
				GW8.GW8_PESOC,
				GW8.GW8_PESOR,
				GW8.GW8_QTDALT,
				GUB.GUB_DSCLFR,
				GW8.GW8_CFOP,
				GW8.GW8_INFO1,
				GW8.GW8_INFO2,
				GW8.GW8_INFO3,
				GW8.GW8_INFO4,
				GW8.GW8_INFO5,
				GW1.GW1_CDREM,
				GU3REM.GU3_NMEMIT AS NMREM,
				GU3REM.GU3_IDFED AS CNPJREM,
				GW1.GW1_CDDEST,
				GU3DES.GU3_NMEMIT AS NMDEST,
				GU3DES.GU3_IDFED AS CNPJDEST,
				GW1.GW1_SIT,
				GW1.GW1_CALCAT,
				GW1.GW1_ROMTV,
				GW1.GW1_ROMCF,
				GW1.GW1_ROMTO,
				GWU.GWU_NRCIDO,
				GU7ORI.GU7_NMCID AS NMCIDO,
				GU7ORI.GU7_CDUF AS UFO,
				GWU.GWU_NRCIDD,
				GU7DST.GU7_NMCID AS NMCIDD,
				GU7DST.GU7_CDUF AS UFD,
				GWU.GWU_SEQ,
				GWU.GWU_PAGAR,
				GWU.GWU_CDTRP,
				GU3TRP.GU3_IDFED AS CNPJTRP,
				GU3TRP.GU3_NMEMIT AS NMTRP,
				GU3TRP.GU3_AUTON AS AUTON,
				GU3TRP.GU3_MODAL AS MODAL,
				GU3TRP.GU3_TPTRIB AS TPTRIB,
				GWN.GWN_NRROM,
				GWN.GWN_SIT,
				GWN.GWN_CDTPVC,
				GWN.GWN_CDCLFR,
				GWN.GWN_CDTPOP,
				GWN.GWN_CALC,
				GWN.GWN_VPVAL,
				GWU.GWU_DTPENT,
				GWU.GWU_HRPENT,
				GWU.GWU_DTENT,
				GWU.GWU_HRENT,
				GW3.GW3_FILIAL,
				GW3.GW3_CDESP,
				GW3.GW3_NRDF,
				GW3.GW3_SERDF,
				GW3.GW3_EMISDF,
				GW3.GW3_TPDF,
				GW3.GW3_DTENT,
				GW3.GW3_DTEMIS,
				GW3.GW3_SIT,
				GW3.GW3_SITFIS,
				GW3.GW3_DTFIS,
				GW3.GW3_SITREC,
				GW3.GW3_DTREC,
				GW3.GW3_SITCUS,
				GW3.GW3_DTCUS,
				GW3.GW3_SITMLA,
			    GW3.GW3_MUNINI,
				GW3.GW3_UFINI,
				GW3.GW3_MUNFIM,
				GW3.GW3_UFFIM,
				GW6.GW6_NRFAT,
				GW6.GW6_DTEMIS,
				GW6.GW6_VLFATU,
				GW6.GW6_SITAPR,
				GW6.GW6_DTFIN,
				GW6.GW6_SITFIN,
				%Exp:cSelGWMDF%
			FROM %Table:GW1% GW1

			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.%NotDel%

			INNER JOIN %Table:GW8% GW8
			ON GW8.GW8_FILIAL = GW1.GW1_FILIAL
			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
			AND GW8.GW8_SERDC = GW1.GW1_SERDC
			AND GW8.GW8_NRDC = GW1.GW1_NRDC
			AND GW8.%NotDel%

			INNER JOIN %Table:GUB% GUB
			ON GUB.GUB_FILIAL = %xFilial:GUB%
			AND GUB.GUB_CDCLFR = GW8.GW8_CDCLFR
			AND GUB.%NotDel%

			INNER JOIN %Table:GU3% GU3EMIS
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3%
			AND GU3EMIS.GU3_CDEMIT = GW1.GW1_EMISDC
			AND GU3EMIS.%NotDel%

			INNER JOIN %Table:GU3% GU3REM
			ON GU3REM.GU3_FILIAL = %xFilial:GU3%
			AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM
			AND GU3REM.%NotDel%

			INNER JOIN %Table:GU3% GU3DES
			ON GU3DES.GU3_FILIAL = %xFilial:GU3%
			AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST
			AND GU3DES.%NotDel%

			LEFT JOIN %Table:GU3% GU3TRP
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP
			AND GU3TRP.%NotDel%

			LEFT JOIN %Table:GWN% GWN
			ON GWN.GWN_FILIAL = %Exp:cJoinGWN%
			AND GWN.GWN_NRROM = GW1.GW1_NRROM
			AND GWN.%NotDel%

			LEFT JOIN %Table:GU7% GU7ORI
			ON GU7ORI.GU7_FILIAL = %xFilial:GU7%
			AND GU7ORI.GU7_NRCID = GWU.GWU_NRCIDO
			AND GU7ORI.%NotDel%

			LEFT JOIN %Table:GU7% GU7DST
			ON GU7DST.GU7_FILIAL = %xFilial:GU7%
			AND GU7DST.GU7_NRCID = GWU.GWU_NRCIDD
			AND GU7DST.%NotDel%

			LEFT JOIN %Table:GUB% GUBROM
			ON GUBROM.GUB_FILIAL = %xFilial:GUB%
			AND GUBROM.GUB_CDCLFR = GWN.GWN_CDCLFR
			AND GUBROM.%NotDel%

			INNER JOIN %Table:GW4% GW4
			ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
			AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
			AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
			AND GW4.GW4_SERDC = GW1.GW1_SERDC
			AND GW4.GW4_NRDC = GW1.GW1_NRDC
			AND GW4.GW4_EMISDF IN (%Exp:cEmit%)
			AND GW4.%NotDel%

			INNER JOIN %Table:GW3% GW3
			ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
			AND GW3.GW3_CDESP  = GW4.GW4_CDESP
			AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
			AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		    AND GW3.GW3_NRDF   = GW4.GW4_NRDF
			AND GW3.GW3_SERDF  = GW4.GW4_SERDF
			AND GW3.%NotDel%

			INNER JOIN %Table:GWM% GWMDF 
			ON GWMDF.GWM_FILIAL = GW1.GW1_FILIAL
			AND GWMDF.GWM_CDTPDC = GW1.GW1_CDTPDC
			AND GWMDF.GWM_EMISDC = GW1.GW1_EMISDC
			AND GWMDF.GWM_SERDC = GW1.GW1_SERDC
			AND GWMDF.GWM_NRDC = GW1.GW1_NRDC
			AND GWMDF.GWM_SEQGW8 = GW8.GW8_SEQ 
			AND GWMDF.GWM_TPDOC = '2'
			AND GWMDF.GWM_NRDOC = GW3.GW3_NRDF
			AND GWMDF.D_E_L_E_T_= ' '

			LEFT JOIN %Table:GW6% GW6
			ON GW6.GW6_FILIAL  = GW3.GW3_FILFAT
			AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT
			AND GW6.GW6_SERFAT = GW3.GW3_SERFAT
			AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT
			AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA
			AND GW6.%NotDel%
			
			WHERE GW1.%NotDel%
			AND GW3.GW3_MUNINI = GWU.GWU_NRCIDO
  			AND GW3.GW3_MUNFIM = GWU.GWU_NRCIDD
			%Exp:cWhere%

			GROUP BY GW1.GW1_FILIAL,
					GW1.GW1_TPFRET,
					GW1.GW1_CDTPDC,
					GW1.GW1_EMISDC,
					GU3EMIS.GU3_NMEMIT,
					GU3EMIS.GU3_IDFED,
					GU3EMIS.GU3_NRCID,
					GW1.GW1_SERDC,
					GW1.GW1_NRDC,
					GW1.GW1_DANFE,
					GW1.GW1_DTEMIS,
					GW1.GW1_DTIMPL,
					GW1.GW1_DTSAI,
					GW1.GW1_USO,
					GW1.GW1_REPRES,
					GW1.GW1_REGCOM,
					GW8.GW8_CDCLFR,
					GW8.GW8_SEQ,
					GW8.GW8_ITEM,
					GW8.GW8_DSITEM,
					GW8.GW8_QTDE,
					GW8.GW8_VALOR,
					GW8.GW8_VOLUME,
					GW8.GW8_PESOC,
					GW8.GW8_PESOR,
					GW8.GW8_QTDALT,
					GUB.GUB_DSCLFR,
					GW8.GW8_CFOP,
					GW8.GW8_INFO1,
					GW8.GW8_INFO2,
					GW8.GW8_INFO3,
					GW8.GW8_INFO4,
					GW8.GW8_INFO5,
					GW1.GW1_CDREM,
					GU3REM.GU3_NMEMIT,
					GU3REM.GU3_IDFED,
					GW1.GW1_CDDEST,
					GU3DES.GU3_NMEMIT,
					GU3DES.GU3_IDFED,
					GW1.GW1_SIT,
					GW1.GW1_CALCAT,
					GW1.GW1_ROMTV,
					GW1.GW1_ROMCF,
					GW1.GW1_ROMTO,
					GUBROM.GUB_DSCLFR,
					GWU.GWU_NRCIDO,
					GU7ORI.GU7_NMCID,
					GU7ORI.GU7_CDUF,
					GWU.GWU_NRCIDD,
					GU7DST.GU7_NMCID,
					GU7DST.GU7_CDUF,
					GWU.GWU_SEQ,
					GWU.GWU_PAGAR,
					GWU.GWU_CDTRP,
					GU3TRP.GU3_IDFED,
					GU3TRP.GU3_NMEMIT,
					GU3TRP.GU3_AUTON,
					GU3TRP.GU3_MODAL,
					GU3TRP.GU3_TPTRIB,
					GWN.GWN_NRROM,
					GWN.GWN_SIT,
					GWN.GWN_CDTPVC,
					GWN.GWN_CDCLFR,
					GWN.GWN_CDTPOP,
					GWN.GWN_CALC,
					GWN.GWN_VPVAL,
					GWU.GWU_DTPENT,
					GWU.GWU_HRPENT,
					GWU.GWU_DTENT,
					GWU.GWU_HRENT,
					GW3.GW3_FILIAL,
					GW3.GW3_CDESP,
					GW3.GW3_NRDF,
					GW3.GW3_SERDF,
					GW3.GW3_EMISDF,
					GW3.GW3_TPDF,
					GW3.GW3_DTENT,
					GW3.GW3_DTEMIS,
					GW3.GW3_SIT,
					GW3.GW3_SITFIS,
					GW3.GW3_DTFIS,
					GW3.GW3_SITREC,
					GW3.GW3_DTREC,
					GW3.GW3_SITCUS,
					GW3.GW3_DTCUS,
					GW3.GW3_SITMLA,
					GW3.GW3_MUNINI,
					GW3.GW3_UFINI,
					GW3.GW3_MUNFIM,
					GW3.GW3_UFFIM,
					GW6.GW6_NRFAT,
					GW6.GW6_DTEMIS,
					GW6.GW6_VLFATU,
					GW6.GW6_SITAPR,
					GW6.GW6_DTFIN,
					GW6.GW6_SITFIN,
					%Exp:cGWMDfOrd%
			ORDER BY GWN.GWN_NRROM,
					GW1.GW1_DTIMPL,
					GW1.GW1_NRDC,
					GWU.GWU_SEQ
		EndSQL
		TcSetField(cAliasGW3,"GW1_DTEMIS","D",8,0)
		TcSetField(cAliasGW3,"GW1_DTIMPL","D",8,0)
		TcSetField(cAliasGW3,"GW1_DTSAI" ,"D",8,0)
		TcSetField(cAliasGW3,"GWU_DTPENT","D",8,0)
		TcSetField(cAliasGW3,"GWU_DTENT" ,"D",8,0)
		TcSetField(cAliasGW3,"GWJ_DTIMPL","D",8,0)
		TcSetField(cAliasGW3,"GW3_DTENT" ,"D",8,0)
		TcSetField(cAliasGW3,"GW3_DTEMIS","D",8,0)
		TcSetField(cAliasGW3,"GW3_DTFIS" ,"D",8,0)
		TcSetField(cAliasGW3,"GW3_DTREC" ,"D",8,0)
		TcSetField(cAliasGW3,"GW3_DTCUS" ,"D",8,0)
		TcSetField(cAliasGW3,"GW6_DTEMIS","D",8,0)
		TcSetField(cAliasGW3,"GW6_DTFIN" ,"D",8,0)

		(cAliasGW3)->(dbGoTop())
		(cTabTemp)->(dbGoTop())
		While (cAliasGW3)->(!EoF())
			(cTabTemp)->(dbSetOrder(1))
			If (cTabTemp)->(dbSeek((cAliasGW3)->GW1_FILIAL+(cAliasGW3)->GW1_CDTPDC+(cAliasGW3)->GW1_EMISDC+;
							   	(cAliasGW3)->GW1_SERDC+(cAliasGW3)->GW1_NRDC+(cAliasGW3)->GW8_SEQ+(cAliasGW3)->CNPJEMIS+;
							   	(cAliasGW3)->GW3_NRDF+(cAliasGW3)->GW3_CDESP+(cAliasGW3)->GW3_EMISDF+(cAliasGW3)->GW3_SERDF))
				// Grava na tabela temporaria os registros da GW3 e GW6 relacionados ao calculo encontrado. 
				RecLock(cTabTemp,.F.)
					(cTabTemp)->GXTNRCT   := ""
					(cTabTemp)->GXGEDISIT := ""
					(cTabTemp)->GW3FILIAL := (cAliasGW3)->GW3_FILIAL
					(cTabTemp)->GW3CDESP  := (cAliasGW3)->GW3_CDESP
					(cTabTemp)->GW3NRDF   := (cAliasGW3)->GW3_NRDF
					(cTabTemp)->GW3SERDF  := (cAliasGW3)->GW3_SERDF
					(cTabTemp)->GW3TPDF   := RetTipGW3((cAliasGW3)->GW3_TPDF)
					(cTabTemp)->GW3DTENT  := (cAliasGW3)->GW3_DTENT
					(cTabTemp)->GW3DTEMIS := (cAliasGW3)->GW3_DTEMIS
					(cTabTemp)->VLFRETDF  := (cAliasGW3)->VLFRETDF
					(cTabTemp)->VLICMSDF  := (cAliasGW3)->VLICMSDF
					(cTabTemp)->VLPISDF   := (cAliasGW3)->VLPISDF
					(cTabTemp)->VLCOFIDF  := (cAliasGW3)->VLCOFIDF
					(cTabTemp)->VLIBSDF   := (cAliasGW3)->VLIBSDF
					(cTabTemp)->VLIBMDF   := (cAliasGW3)->VLIBMDF
					(cTabTemp)->VLCBSDF   := (cAliasGW3)->VLCBSDF
					(cTabTemp)->GW3MOTBLQ := rTrim(MemoLine(FWNoAccent(Posicione("GW3", 1, (cAliasGW3)->GW3_FILIAL+(cAliasGW3)->GW3_CDESP+(cAliasGW3)->GW3_EMISDF+(cAliasGW3)->GW3_SERDF+(cAliasGW3)->GW3_NRDF, "GW3_MOTBLQ")),128,1))
					(cTabTemp)->GW3SITFIS := RetFisGW3((cAliasGW3)->GW3_SITFIS)
					(cTabTemp)->GW3DTFIS  := (cAliasGW3)->GW3_DTFIS
					(cTabTemp)->GW3SITREC := RetFisGW3((cAliasGW3)->GW3_SITREC)
					(cTabTemp)->GW3DTREC  := (cAliasGW3)->GW3_DTREC
					(cTabTemp)->GW3SITCUS := RetSitCusGW3((cAliasGW3)->GW3_SITCUS)
					(cTabTemp)->GW3DTCUS  := (cAliasGW3)->GW3_DTCUS
					(cTabTemp)->GW3SITMLA := RetSitMLA((cAliasGW3)->GW3_SITMLA)
					(cTabTemp)->GW6NRFAT  := (cAliasGW3)->GW6_NRFAT
					(cTabTemp)->GW6DTEMIS := (cAliasGW3)->GW6_DTEMIS
					(cTabTemp)->GW6VLFATU := (cAliasGW3)->GW6_VLFATU
					(cTabTemp)->GW6SITAPR := RetSit((cAliasGW3)->GW6_SITAPR)
					(cTabTemp)->GW6DTFIN  := (cAliasGW3)->GW6_DTFIN
					(cTabTemp)->GW6SITFIN := RetFinGW6((cAliasGW3)->GW6_SITFIN)
				(cTabTemp)->(MsUnlock())
			Else
				RecLock(cTabTemp,.T.)
					(cTabTemp)->GW1FILIAL := (cAliasGW3)->GW1_FILIAL
					(cTabTemp)->GW1NMFIL  := FwFilName(cEmpAnt,(cTabTemp)->GW1FILIAL)
					(cTabTemp)->GW1CDTPDC := (cAliasGW3)->GW1_CDTPDC
					(cTabTemp)->GW1EMISDC := (cAliasGW3)->GW1_EMISDC
					(cTabTemp)->CNPJEMIS  := (cAliasGW3)->CNPJEMIS
					(cTabTemp)->NMEMIS    := (cAliasGW3)->NMEMIS
					(cTabTemp)->GW1SERDC  := (cAliasGW3)->GW1_SERDC
					(cTabTemp)->GW1NRDC   := (cAliasGW3)->GW1_NRDC
					(cTabTemp)->GW1DANFE  := (cAliasGW3)->GW1_DANFE
					(cTabTemp)->GW1DTEMIS := (cAliasGW3)->GW1_DTEMIS
					(cTabTemp)->GW1DTIMPL := (cAliasGW3)->GW1_DTIMPL
					(cTabTemp)->GW1DTSAI  := (cAliasGW3)->GW1_DTSAI
					(cTabTemp)->GW1USO    := RetUso((cAliasGW3)->GW1_USO)
					(cTabTemp)->GW1REGCOM := (cAliasGW3)->GW1_REGCOM
					(cTabTemp)->GW8CDCLFR := (cAliasGW3)->GW8_CDCLFR
					(cTabTemp)->GW8ITEM   := (cAliasGW3)->GW8_ITEM
					(cTabTemp)->GW8DSITEM := FWNoAccent((cAliasGW3)->GW8_DSITEM)
					(cTabTemp)->GW8SEQ	  := (cAliasGW3)->GW8_SEQ
					(cTabTemp)->GW8QTDE   := (cAliasGW3)->GW8_QTDE
					(cTabTemp)->GW8VALOR  := (cAliasGW3)->GW8_VALOR
					(cTabTemp)->GW8VOLUME := (cAliasGW3)->GW8_VOLUME
					(cTabTemp)->GW8PESOC  := (cAliasGW3)->GW8_PESOC
					(cTabTemp)->GW8PESOR  := (cAliasGW3)->GW8_PESOR
					(cTabTemp)->GW8QTDALT := (cAliasGW3)->GW8_QTDALT
					(cTabTemp)->GUBDSCLFR := (cAliasGW3)->GUB_DSCLFR
					(cTabTemp)->GW8CFOP   := (cAliasGW3)->GW8_CFOP
					(cTabTemp)->GW8INFO1  := (cAliasGW3)->GW8_INFO1
					(cTabTemp)->GW8INFO2  := (cAliasGW3)->GW8_INFO2
					(cTabTemp)->GW8INFO3  := (cAliasGW3)->GW8_INFO3
					(cTabTemp)->GW8INFO4  := (cAliasGW3)->GW8_INFO4
					(cTabTemp)->GW8INFO5  := (cAliasGW3)->GW8_INFO5
					(cTabTemp)->GW1CDREM  := (cAliasGW3)->GW1_CDREM
					(cTabTemp)->CNPJREM   := (cAliasGW3)->CNPJREM
					(cTabTemp)->NMREM     := (cAliasGW3)->NMREM
					(cTabTemp)->GW1CDDEST := (cAliasGW3)->GW1_CDDEST
					(cTabTemp)->CNPJDEST  := (cAliasGW3)->CNPJDEST
					(cTabTemp)->NMDEST    := (cAliasGW3)->NMDEST
					(cTabTemp)->GW1SIT	  := (cAliasGW3)->GW1_SIT
					(cTabTemp)->GW1SITDES := RetSitGW1((cAliasGW3)->GW1_SIT)
					(cTabTemp)->GW0MSG    := ""	
					(cTabTemp)->GW1CALCAT := RetCalcGW1((cAliasGW3)->GW1_CALCAT)
					(cTabTemp)->GW1ROMTV  := (cAliasGW3)->GW1_ROMTV
					(cTabTemp)->GW1ROMCF  := (cAliasGW3)->GW1_ROMCF
					(cTabTemp)->GW1ROMTO  := (cAliasGW3)->GW1_ROMTO
					(cTabTemp)->GU3NRCID  := (cAliasGW3)->GU3NRCID
					(cTabTemp)->GWUNRCIDO := (cAliasGW3)->GWU_NRCIDO
					(cTabTemp)->NMCIDO    := (cAliasGW3)->NMCIDO
					(cTabTemp)->UFO       := (cAliasGW3)->UFO
					(cTabTemp)->GWUNRCIDD := (cAliasGW3)->GWU_NRCIDD
					(cTabTemp)->NMCIDD    := (cAliasGW3)->NMCIDD
					(cTabTemp)->UFD       := (cAliasGW3)->UFD
					(cTabTemp)->GWUSEQ    := (cAliasGW3)->GWU_SEQ
					(cTabTemp)->GWUPAGAR  := IIf((cAliasGW3)->GWU_PAGAR == "1","Sim","Não")
					(cTabTemp)->GWUCDTRP  := (cAliasGW3)->GWU_CDTRP
					(cTabTemp)->CNPJTRP   := (cAliasGW3)->CNPJTRP
					(cTabTemp)->NMTRP     := (cAliasGW3)->NMTRP
					(cTabTemp)->AUTON     := IIf((cAliasGW3)->AUTON == "1", "Autônomo","Transportador")
					(cTabTemp)->MODAL     := RetTpMod((cAliasGW3)->MODAL)
					(cTabTemp)->TPTRIB    := RetTpTrb((cAliasGW3)->TPTRIB)
					(cTabTemp)->GWNNRROM  := (cAliasGW3)->GWN_NRROM
					(cTabTemp)->GWNSIT    := RetSitRom((cAliasGW3)->GWN_SIT)
					(cTabTemp)->GWNCDTPVC := (cAliasGW3)->GWN_CDTPVC
					(cTabTemp)->GWNCDCLFR := (cAliasGW3)->GWN_CDCLFR
					(cTabTemp)->GWNCDTPOP := (cAliasGW3)->GWN_CDTPOP
					(cTabTemp)->GWNCALC   := RetCalcGWN((cAliasGW3)->GWN_CALC)
					(cTabTemp)->GWNMTCALC := rTrim(MemoLine(FWNoAccent(Posicione("GWN", 1, (cAliasGW3)->GW1_FILIAL+(cAliasGW3)->GWN_NRROM, "GWN_MTCALC")),128,1))
					(cTabTemp)->GWNVPVAL  := (cAliasGW3)->GWN_VPVAL
					(cTabTemp)->GWUDTPENT := (cAliasGW3)->GWU_DTPENT
					(cTabTemp)->GWUHRPENT := (cAliasGW3)->GWU_HRPENT
					(cTabTemp)->GWUDTENT  := (cAliasGW3)->GWU_DTENT
					(cTabTemp)->GWUHRENT  := (cAliasGW3)->GWU_HRENT
					(cTabTemp)->GWFTPFRET := RetTpFrtCalc((cAliasGW3)->GW1_TPFRET)
					(cTabTemp)->GXTNRCT   := ""
					(cTabTemp)->GXGEDISIT := ""
					(cTabTemp)->GW3FILIAL := (cAliasGW3)->GW3_FILIAL
					(cTabTemp)->GW3CDESP  := (cAliasGW3)->GW3_CDESP
					(cTabTemp)->GW3EMISDF := (cAliasGW3)->GW3_EMISDF
					(cTabTemp)->GW3NRDF   := (cAliasGW3)->GW3_NRDF
					(cTabTemp)->GW3SERDF  := (cAliasGW3)->GW3_SERDF
					(cTabTemp)->GW3TPDF   := RetTipGW3((cAliasGW3)->GW3_TPDF)
					(cTabTemp)->GW3DTENT  := (cAliasGW3)->GW3_DTENT
					(cTabTemp)->GW3DTEMIS := (cAliasGW3)->GW3_DTEMIS
					(cTabTemp)->VLFRETDF  := (cAliasGW3)->VLFRETDF
					(cTabTemp)->VLICMSDF  := (cAliasGW3)->VLICMSDF
					(cTabTemp)->VLPISDF   := (cAliasGW3)->VLPISDF
					(cTabTemp)->VLCOFIDF  := (cAliasGW3)->VLCOFIDF
					(cTabTemp)->VLIBSDF   := (cAliasGW3)->VLIBSDF
					(cTabTemp)->VLIBMDF   := (cAliasGW3)->VLIBMDF
					(cTabTemp)->VLCBSDF   := (cAliasGW3)->VLCBSDF
					(cTabTemp)->GW3MOTBLQ := rTrim(MemoLine(FWNoAccent(Posicione("GW3", 1, (cAliasGW3)->GW3_FILIAL+(cAliasGW3)->GW3_CDESP+(cAliasGW3)->GW3_EMISDF+(cAliasGW3)->GW3_SERDF+(cAliasGW3)->GW3_NRDF, "GW3_MOTBLQ")),128,1))
					(cTabTemp)->GW3SITFIS := RetFisGW3((cAliasGW3)->GW3_SITFIS)
					(cTabTemp)->GW3DTFIS  := (cAliasGW3)->GW3_DTFIS
					(cTabTemp)->GW3SITREC := RetFisGW3((cAliasGW3)->GW3_SITREC)
					(cTabTemp)->GW3DTREC  := (cAliasGW3)->GW3_DTREC
					(cTabTemp)->GW3SITCUS := RetSitCusGW3((cAliasGW3)->GW3_SITCUS)
					(cTabTemp)->GW3DTCUS  := (cAliasGW3)->GW3_DTCUS
					(cTabTemp)->GW3SITMLA := RetSitMLA((cAliasGW3)->GW3_SITMLA)
					(cTabTemp)->GW6NRFAT  := (cAliasGW3)->GW6_NRFAT
					(cTabTemp)->GW6DTEMIS := (cAliasGW3)->GW6_DTEMIS
					(cTabTemp)->GW6VLFATU := (cAliasGW3)->GW6_VLFATU
					(cTabTemp)->GW6SITAPR := RetSit((cAliasGW3)->GW6_SITAPR)
					(cTabTemp)->GW6DTFIN  := (cAliasGW3)->GW6_DTFIN
					(cTabTemp)->GW6SITFIN := RetFinGW6((cAliasGW3)->GW6_SITFIN)
				(cTabTemp)->(MsUnlock())
			EndIf
			(cAliasGW3)->(dbSkip())
		EndDo
		(cAliasGW3)->(dbCloseArea())

		// Busca os registros que não possuem calculo
		cAliasGWH := GetNextAlias()
		BeginSQL Alias cAliasGWH
			SELECT GW1.GW1_FILIAL,
				GW1.GW1_CDTPDC,
				GW1.GW1_EMISDC,
				GW1.GW1_SERDC,
				GW1.GW1_NRDC,
				GW1.GW1_TPFRET,
				GU3EMIS.GU3_NMEMIT AS NMEMIS,
				GU3EMIS.GU3_IDFED AS CNPJEMIS,
				GU3EMIS.GU3_NRCID AS GU3NRCID,
				GW1.GW1_DANFE,
				GW1.GW1_DTEMIS,
				GW1.GW1_DTIMPL,
				GW1.GW1_DTSAI,
				GW1.GW1_USO,
				GW1.GW1_REPRES,
				GW1.GW1_REGCOM,
				GW8.GW8_CDCLFR,
				GW8.GW8_SEQ,
				GW8.GW8_ITEM,
				GW8.GW8_DSITEM,
				GW8.GW8_QTDE,
				GW8.GW8_VALOR,
				GW8.GW8_VOLUME,
				GW8.GW8_PESOC,
				GW8.GW8_PESOR,
				GW8.GW8_QTDALT,
				GW8.GW8_CFOP,
				GW8.GW8_INFO1,
				GW8.GW8_INFO2,
				GW8.GW8_INFO3,
				GW8.GW8_INFO4,
				GW8.GW8_INFO5,
				GW1.GW1_CDREM,
				GU3REM.GU3_NMEMIT AS NMREM,
				GU3REM.GU3_IDFED AS CNPJREM,
				GW1.GW1_CDDEST,
				GU3DES.GU3_NMEMIT AS NMDEST,
				GU3DES.GU3_IDFED AS CNPJDEST,
				GW1.GW1_SIT,
				GW1.GW1_CALCAT,
				GW1.GW1_ROMTV,
				GW1.GW1_ROMCF,
				GW1.GW1_ROMTO,
				GWU.GWU_NRCIDO,
				GW1.GW1_NRREG,
				GU7ORI.GU7_NMCID AS NMCIDO,
				GU7ORI.GU7_CDUF AS UFO,
				GWU.GWU_NRCIDD,
				GU7DST.GU7_NMCID AS NMCIDD,
				GU7DST.GU7_CDUF AS UFD,
				GWU.GWU_SEQ,
				GWU.GWU_PAGAR,
				GWU.GWU_CDTRP,
				GU3TRP.GU3_IDFED AS CNPJTRP,
				GU3TRP.GU3_NMEMIT AS NMTRP,
				GU3TRP.GU3_AUTON AS AUTON,
				GU3TRP.GU3_MODAL AS MODAL,
				GU3TRP.GU3_TPTRIB AS TPTRIB,
				GUBROM.GUB_DSCLFR,
				GWN.GWN_NRROM,
				GWN.GWN_SIT,
				GWN.GWN_CDTPVC,
				GWN.GWN_CDCLFR,
				GWN.GWN_CDTPOP,
				GWN.GWN_CALC,
				GWN.GWN_VPVAL,
				GWU.GWU_DTPENT,
				GWU.GWU_HRPENT,
				GWU.GWU_DTENT,
				GWU.GWU_HRENT
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.%NotDel%
			INNER JOIN %Table:GW8% GW8 
			ON GW8.GW8_FILIAL = GW1.GW1_FILIAL
			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
			AND GW8.GW8_SERDC = GW1.GW1_SERDC
			AND GW8.GW8_NRDC = GW1.GW1_NRDC
			AND GW8.%NotDel%
			LEFT JOIN %Table:GWN% GWN 
			ON GWN.GWN_FILIAL = GW1.GW1_FILROM
			AND GWN.GWN_NRROM = GW1.GW1_NRROM
			AND GWN.%NotDel%
			LEFT JOIN %Table:GWH% GWH 
			ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
			AND GWH.GWH_NRDC = GW1.GW1_NRDC 
			AND GWH.GWH_TRECHO = GWU.GWU_SEQ
			AND GWH.%NotDel%
			LEFT JOIN %Table:GW4% GW4 
			ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
			AND GW4.GW4_NRDC = GW1.GW1_NRDC
			AND GW4.%NotDel%
			INNER JOIN %Table:GU3% GU3EMIS 
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3%
			AND GU3EMIS.GU3_CDEMIT = GW1.GW1_EMISDC
			AND GU3EMIS.%NotDel%
			INNER JOIN %Table:GU3% GU3REM 
			ON GU3REM.GU3_FILIAL = %xFilial:GU3%
			AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM
			AND GU3REM.%NotDel%
			INNER JOIN %Table:GU3% GU3DES 
			ON GU3DES.GU3_FILIAL = %xFilial:GU3%
			AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST
			AND GU3DES.%NotDel%
			LEFT JOIN %Table:GU3% GU3TRP 
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP
			AND GU3TRP.%NotDel%
			LEFT JOIN %Table:GU7% GU7ORI 
			ON GU7ORI.GU7_FILIAL = %xFilial:GU7%
			AND GU7ORI.GU7_NRCID = GWU.GWU_NRCIDO
			AND GU7ORI.%NotDel%
			LEFT JOIN %Table:GU7% GU7DST 
			ON GU7DST.GU7_FILIAL = %xFilial:GU7%
			AND GU7DST.GU7_NRCID = GWU.GWU_NRCIDD
			AND GU7DST.%NotDel%
			LEFT JOIN %Table:GUB% GUBROM 
			ON GUBROM.GUB_FILIAL = %xFilial:GUB%
			AND GUBROM.GUB_CDCLFR = GWN.GWN_CDCLFR
			AND GUBROM.%NotDel%
			WHERE GW1.%NotDel%
			AND GWH.GWH_NRCALC IS NULL
			%Exp:cWhere%
		EndSql

		Do While (cAliasGWH)->(!Eof())
			(cTabTemp)->(dbSetOrder(2))
			If !(cTabTemp)->(dbSeek((cAliasGWH)->GW1_FILIAL+(cAliasGWH)->GW1_CDTPDC+(cAliasGWH)->GW1_EMISDC+;
							   	   (cAliasGWH)->GW1_SERDC+(cAliasGWH)->GW1_NRDC+(cAliasGWH)->GW8_SEQ+(cAliasGWH)->GWU_CDTRP+(cAliasGWH)->GW8_CDCLFR))
				RecLock(cTabTemp,.T.)
					(cTabTemp)->GW1FILIAL := (cAliasGWH)->GW1_FILIAL
					(cTabTemp)->GW1NMFIL  := FwFilName(cEmpAnt,(cTabTemp)->GW1FILIAL)
					(cTabTemp)->GW1CDTPDC := (cAliasGWH)->GW1_CDTPDC
					(cTabTemp)->GW1EMISDC := (cAliasGWH)->GW1_EMISDC
					(cTabTemp)->CNPJEMIS  := (cAliasGWH)->CNPJEMIS
					(cTabTemp)->NMEMIS    := (cAliasGWH)->NMEMIS
					(cTabTemp)->GW1SERDC  := (cAliasGWH)->GW1_SERDC
					(cTabTemp)->GW1NRDC   := (cAliasGWH)->GW1_NRDC
					(cTabTemp)->GW1DANFE  := (cAliasGWH)->GW1_DANFE
					(cTabTemp)->GW1DTEMIS := SToD((cAliasGWH)->GW1_DTEMIS)
					(cTabTemp)->GW1DTIMPL := SToD((cAliasGWH)->GW1_DTIMPL)
					(cTabTemp)->GW1DTSAI  := SToD((cAliasGWH)->GW1_DTSAI)
					(cTabTemp)->GW1USO    := RetUso((cAliasGWH)->GW1_USO)
					(cTabTemp)->GW1REGCOM := (cAliasGWH)->GW1_REGCOM
					(cTabTemp)->GW8CDCLFR := (cAliasGWH)->GW8_CDCLFR
					(cTabTemp)->GW8ITEM   := (cAliasGWH)->GW8_ITEM
					(cTabTemp)->GW8DSITEM := FWNoAccent((cAliasGWH)->GW8_DSITEM)
					(cTabTemp)->GW8SEQ	  := (cAliasGWH)->GW8_SEQ
					(cTabTemp)->GW8QTDE   := (cAliasGWH)->GW8_QTDE
					(cTabTemp)->GW8VALOR  := (cAliasGWH)->GW8_VALOR
					(cTabTemp)->GW8VOLUME := (cAliasGWH)->GW8_VOLUME
					(cTabTemp)->GW8PESOC  := (cAliasGWH)->GW8_PESOC
					(cTabTemp)->GW8PESOR  := (cAliasGWH)->GW8_PESOR
					(cTabTemp)->GW8QTDALT := (cAliasGWH)->GW8_QTDALT
					(cTabTemp)->GUBDSCLFR := (cAliasGWH)->GUB_DSCLFR
					(cTabTemp)->GW8CFOP   := (cAliasGWH)->GW8_CFOP
					(cTabTemp)->GW8INFO1  := (cAliasGWH)->GW8_INFO1
					(cTabTemp)->GW8INFO2  := (cAliasGWH)->GW8_INFO2
					(cTabTemp)->GW8INFO3  := (cAliasGWH)->GW8_INFO3
					(cTabTemp)->GW8INFO4  := (cAliasGWH)->GW8_INFO4
					(cTabTemp)->GW8INFO5  := (cAliasGWH)->GW8_INFO5
					(cTabTemp)->GW1CDREM  := (cAliasGWH)->GW1_CDREM
					(cTabTemp)->CNPJREM   := (cAliasGWH)->CNPJREM
					(cTabTemp)->NMREM     := (cAliasGWH)->NMREM
					(cTabTemp)->GW1CDDEST := (cAliasGWH)->GW1_CDDEST
					(cTabTemp)->CNPJDEST  := (cAliasGWH)->CNPJDEST
					(cTabTemp)->NMDEST    := (cAliasGWH)->NMDEST
					(cTabTemp)->GW1SIT	  := (cAliasGWH)->GW1_SIT
					(cTabTemp)->GW1SITDES := RetSitGW1((cAliasGWH)->GW1_SIT)
					(cTabTemp)->GW0MSG    := ""	
					(cTabTemp)->GW1CALCAT := RetCalcGW1((cAliasGWH)->GW1_CALCAT)
					(cTabTemp)->GW1ROMTV  := (cAliasGWH)->GW1_ROMTV
					(cTabTemp)->GW1ROMCF  := (cAliasGWH)->GW1_ROMCF
					(cTabTemp)->GW1ROMTO  := (cAliasGWH)->GW1_ROMTO
					(cTabTemp)->GU3NRCID  := (cAliasGWH)->GU3NRCID
					(cTabTemp)->GWUNRCIDO := (cAliasGWH)->GWU_NRCIDO
					(cTabTemp)->NMCIDO    := (cAliasGWH)->NMCIDO
					(cTabTemp)->UFO       := (cAliasGWH)->UFO
					(cTabTemp)->GWUNRCIDD := (cAliasGWH)->GWU_NRCIDD
					(cTabTemp)->NMCIDD    := (cAliasGWH)->NMCIDD
					(cTabTemp)->UFD       := (cAliasGWH)->UFD
					(cTabTemp)->GWUSEQ    := (cAliasGWH)->GWU_SEQ
					(cTabTemp)->GWUPAGAR  := IIf((cAliasGWH)->GWU_PAGAR == "1","Sim","Não")
					(cTabTemp)->GWUCDTRP  := (cAliasGWH)->GWU_CDTRP
					(cTabTemp)->CNPJTRP   := (cAliasGWH)->CNPJTRP
					(cTabTemp)->NMTRP     := (cAliasGWH)->NMTRP
					(cTabTemp)->AUTON     := IIf((cAliasGWH)->AUTON == "1", "Autônomo","Transportador")
					(cTabTemp)->MODAL     := RetTpMod((cAliasGWH)->MODAL)
					(cTabTemp)->TPTRIB    := RetTpTrb((cAliasGWH)->TPTRIB)
					(cTabTemp)->GWNNRROM  := (cAliasGWH)->GWN_NRROM
					(cTabTemp)->GWNSIT    := RetSitRom((cAliasGWH)->GWN_SIT)
					(cTabTemp)->GWNCDTPVC := (cAliasGWH)->GWN_CDTPVC
					(cTabTemp)->GWNCDCLFR := (cAliasGWH)->GWN_CDCLFR
					(cTabTemp)->GWNCDTPOP := (cAliasGWH)->GWN_CDTPOP
					(cTabTemp)->GWNCALC   := RetCalcGWN((cAliasGWH)->GWN_CALC)
					(cTabTemp)->GWNMTCALC := rTrim(MemoLine(FWNoAccent(Posicione("GWN", 1, (cAliasGWH)->GW1_FILIAL+(cAliasGWH)->GWN_NRROM, "GWN_MTCALC")),128,1))
					(cTabTemp)->GWNVPVAL  := (cAliasGWH)->GWN_VPVAL
					(cTabTemp)->GWUDTPENT := SToD((cAliasGWH)->GWU_DTPENT)
					(cTabTemp)->GWUHRPENT := (cAliasGWH)->GWU_HRPENT
					(cTabTemp)->GWUDTENT  := SToD((cAliasGWH)->GWU_DTENT)
					(cTabTemp)->GWUHRENT  := (cAliasGWH)->GWU_HRENT
					(cTabTemp)->GWFTPFRET := RetTpFrtCalc((cAliasGWH)->GW1_TPFRET)
					(cTabTemp)->GXTNRCT   := ""
					(cTabTemp)->GXGEDISIT := ""
				(cTabTemp)->(MsUnlock())
			EndIf
			(cAliasGWH)->(dbSkip())
		EndDo
		(cAliasGWH)->(dbCloseArea())				

		(cTabTemp)->(dbGoTop())
		Do While (cTabTemp)->(!Eof())
			If (cTabTemp)->GW1SIT == "2" .and. _IntGFE
				cAliasGW0 := GetNextAlias()
				cChave := (cTabTemp)->GW1FILIAL + (cTabTemp)->GW1CDTPDC + (cTabTemp)->GW1EMISDC + (cTabTemp)->GW1SERDC  + (cTabTemp)->GW1NRDC
				BeginSql Alias cAliasGW0
					SELECT GW0.GW0_CHAR01,
							GW0.GW0_CHAR02,
							GW0.GW0_CHAR03
					FROM %Table:GW0% GW0
					WHERE
					GW0.GW0_FILIAL = %Exp:(cTabTemp)->GW1FILIAL%
					AND GW0.GW0_TABELA = 'GW1'
					AND GW0.GW0_CHAVE = %Exp:cChave%
					AND GW0.%NotDel%
				EndSql
				If (cAliasGW0)->(!Eof())
					(cTabTemp)->GW0MSG := FWNoAccent((cAliasGW0)->GW0_CHAR01 + (cAliasGW0)->GW0_CHAR02 + (cAliasGW0)->GW0_CHAR03)
				EndIf
				(cAliasGW0)->(dbCloseArea())
			EndIf

			cAliasGXZ := GetNextAlias()
			BeginSql Alias cAliasGXZ
				SELECT GXZ.GXZ_NRCT
				FROM %Table:GXZ% GXZ
				WHERE GXZ.GXZ_FILDF = %Exp:(cTabTemp)->GW3FILIAL%
				AND GXZ.GXZ_CDESP = %Exp:(cTabTemp)->GW3CDESP%
				AND GXZ.GXZ_EMISDF = %Exp:(cTabTemp)->GW3EMISDF%
				AND GXZ.GXZ_SERDF = %Exp:(cTabTemp)->GW3SERDF%
				AND GXZ.GXZ_NRDF = %Exp:(cTabTemp)->GW3NRDF%
				AND GXZ.GXZ_DTEMIS = %Exp:(cTabTemp)->GW3DTEMIS%
				AND GXZ.%NotDel%
			EndSql
			If (cAliasGXZ)->(!Eof())
				(cTabTemp)->GXTNRCT := (cAliasGXZ)->GXZ_NRCT
			EndIf
				
			(cAliasGXZ)->(dbCloseArea())
			If Empty((cTabTemp)->GXTNRCT)
				cAliasGXY := GetNextAlias()
				BeginSql Alias cAliasGXY
					SELECT GXY.GXY_NRCT
					FROM %Table:GXY% GXY
					WHERE GXY.GXY_FILCA = %Exp:(cTabTemp)->GW1FILIAL%
					AND GXY.GXY_NRCALC = %Exp:(cTabTemp)->GWFNRCALC%
					AND GXY.%NotDel%
				EndSql
				If (cAliasGXY)->(!Eof())
					(cTabTemp)->GXTNRCT := (cAliasGXY)->GXY_NRCT
				EndIf
				(cAliasGXY)->(dbCloseArea())
			EndIf
			GFER002Line()
			(cTabTemp)->(dbSkip())
		EndDo
	EndIf

	If _cMvPar05 == 1 .Or. _cMvPar05 == 3
		cWhere := ""
		If !Empty(cDtAte) .And. cDtAte >= cDtDe
			cWhere += " AND GXG.GXG_DTIMP >= '"+cDtDe+"' AND GXG.GXG_DTIMP <= '"+cDtAte+"'"
		EndIf
		If !Empty(cDtEmisAte) .And. cDtEmisAte >= cDtEmisDe
			cWhere += " AND GXG.GXG_DTEMIS >= '"+cDtEmisDe+"' AND GXG.GXG_DTEMIS <= '"+cDtEmisAte+"'"
		EndIf
		cWhere := "%" + cWhere + "%"
		// Select para buscar apenas os documentos de frete que estão com situação rejeitado na importação Conemb
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GXH.GXH_FILDC,
					GXH.GXH_TPDC,
					GXH.GXH_EMISDC,
					GXH.GXH_SERDC,
					GXH.GXH_NRDC,
					GXH.GXH_DANFE,
					GXG.GXG_CDESP,
					GXG.GXG_SERDF,
					GXG.GXG_NRDF,
					GXG.GXG_TPDF,
					GXG.GXG_EMISDF,
					GXG.GXG_DTENT,
					GXG.GXG_DTEMIS,
					GXG.GXG_VLDF,
					GXG.GXG_NRIMP,
					GXG.GXG_VLIMP,
					GXG.GXG_TPIMP,
					GXG.GXG_EDISIT,
					GU3EMIS.GU3_NMEMIT AS NMEMIS,
					GU3TRP.GU3_IDFED AS CNPJTRP,
					GU3TRP.GU3_NMEMIT AS NMTRP,
					GU3TRP.GU3_AUTON AS AUTON,
					GU3TRP.GU3_MODAL AS MODAL,
					GU3TRP.GU3_TPTRIB AS TPTRIB
			FROM %Table:GXG% GXG
			INNER JOIN %Table:GXH% GXH 
			ON GXG.GXG_FILIAL = GXH.GXH_FILIAL 
			AND GXG.GXG_NRIMP = GXH.GXH_NRIMP 
			AND GXH.%NotDel% 
			LEFT JOIN %Table:GU3% GU3EMIS
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3% 
			AND GXH.GXH_EMISDC = GU3EMIS.GU3_CDEMIT
			AND GU3EMIS.%NotDel%
			LEFT JOIN %Table:GU3% GU3TRP
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GXG.GXG_EMISDF = GU3TRP.GU3_CDEMIT
			AND GU3TRP.%NotDel%
			WHERE GXG.GXG_EDISIT = '3'
			AND GXG.%NotDel%
		EndSql
		TcSetField(cAliasQry,"GXG_DTENT","D",8,0)
		TcSetField(cAliasQry,"GXG_DTEMIS","D",8,0)
		Do While (cAliasQry)->(!Eof())
			// Inicializa as variáveis
			RecLock(cTabTemp,.T.)
				(cTabTemp)->GW1FILIAL  := (cAliasQry)->GXH_FILDC
				(cTabTemp)->GW1NMFIL   := FwFilName(cEmpAnt,(cTabTemp)->GW1FILIAL)
				(cTabTemp)->GW1CDTPDC  := (cAliasQry)->GXH_TPDC
				(cTabTemp)->GW1EMISDC  := (cAliasQry)->GXH_EMISDC
				(cTabTemp)->GW1SERDC   := (cAliasQry)->GXH_SERDC
				(cTabTemp)->GW1NRDC    := (cAliasQry)->GXH_NRDC
				(cTabTemp)->GWFTPFRET  := ""
				(cTabTemp)->CNPJEMIS   := ""
				(cTabTemp)->NMEMIS     := (cAliasQry)->NMEMIS
				(cTabTemp)->GU3NRCID   := ""
				(cTabTemp)->GW1DANFE   := (cAliasQry)->GXH_DANFE
				(cTabTemp)->GW1DTEMIS  := SToD("  /  /    ")
				(cTabTemp)->GW1DTIMPL  := SToD("  /  /    ")
				(cTabTemp)->GW1DTSAI   := SToD("  /  /    ")
				(cTabTemp)->GW1USO     := ""
				(cTabTemp)->GW1REGCOM  := ""
				(cTabTemp)->GW8ITEM    := ""
				(cTabTemp)->GW8DSITEM  := ""
				(cTabTemp)->GW8QTDE    := 0
				(cTabTemp)->GW8VALOR   := 0
				(cTabTemp)->GW8VOLUME  := 0
				(cTabTemp)->GW8PESOC   := 0
				(cTabTemp)->GW8PESOR   := 0
				(cTabTemp)->GW8QTDALT  := 0
				(cTabTemp)->GUBDSCLFR  := ""
				(cTabTemp)->GW8CFOP    := ""
				(cTabTemp)->GW8INFO1   := ""
				(cTabTemp)->GW8INFO2   := ""
				(cTabTemp)->GW8INFO3   := ""
				(cTabTemp)->GW8INFO4   := ""
				(cTabTemp)->GW8INFO5   := ""
				(cTabTemp)->GW1CDREM   := ""
				(cTabTemp)->NMREM      := ""
				(cTabTemp)->CNPJREM    := ""
				(cTabTemp)->GW1CDDEST  := ""
				(cTabTemp)->NMDEST     := ""
				(cTabTemp)->CNPJDEST   := ""
				(cTabTemp)->GW1SITDES  := ""
				(cTabTemp)->GW1CALCAT  := ""
				(cTabTemp)->GW1ROMTV   := ""
				(cTabTemp)->GW1ROMCF   := ""
				(cTabTemp)->GW1ROMTO   := ""
				(cTabTemp)->GWUNRCIDO  := ""
				(cTabTemp)->NMCIDO     := ""
				(cTabTemp)->UFO        := ""
				(cTabTemp)->GWUNRCIDD  := ""
				(cTabTemp)->NMCIDD     := ""
				(cTabTemp)->UFD        := ""
				(cTabTemp)->NMREGD     := ""
				(cTabTemp)->GWUSEQ     := ""
				(cTabTemp)->GWUPAGAR   := ""
				(cTabTemp)->GWUCDTRP   := (cAliasQry)->GXG_EMISDF
				(cTabTemp)->CNPJTRP    := (cAliasQry)->CNPJTRP
				(cTabTemp)->NMTRP      := (cAliasQry)->NMTRP
				(cTabTemp)->AUTON      := (cAliasQry)->AUTON
				(cTabTemp)->MODAL      := (cAliasQry)->MODAL
				(cTabTemp)->TPTRIB     := (cAliasQry)->TPTRIB
				(cTabTemp)->GWNNRROM   := ""
				(cTabTemp)->GWNSIT     := ""
				(cTabTemp)->GWNCDTPVC  := ""
				(cTabTemp)->GWNCDCLFR  := ""
				(cTabTemp)->GWNCDTPOP  := ""
				(cTabTemp)->GWNCALC    := ""
				(cTabTemp)->GWUDTPENT  := SToD("  /  /    ")
				(cTabTemp)->GWUHRPENT  := ""
				(cTabTemp)->GWUDTENT   := SToD("  /  /    ")
				(cTabTemp)->GWUHRENT   := ""
				(cTabTemp)->GWNMTCALC  := ""
				(cTabTemp)->NMREGP     := ""
				(cTabTemp)->GWFNRCALC  := ""
				(cTabTemp)->GWFTPFRET  := ""
				(cTabTemp)->VLFRET     := 0
				(cTabTemp)->VLICMS     := 0
				(cTabTemp)->VLPIS      := 0
				(cTabTemp)->VLCOFI     := 0
				(cTabTemp)->VLIBS      := 0
				(cTabTemp)->VLIBM      := 0
				(cTabTemp)->VLCBS      := 0
				(cTabTemp)->GWFTPTRIB  := ""
				(cTabTemp)->GWFCRDICM  := ""
				(cTabTemp)->GWFCRDPC   := ""
				(cTabTemp)->GWGNRTAB   := ""
				(cTabTemp)->GWGNRNEG   := ""
				(cTabTemp)->GWGCDFXTV  := ""
				(cTabTemp)->GWGNRROTA  := ""
				(cTabTemp)->DESCROTA   := ""
				(cTabTemp)->GV9UNIFAI  := ""
				(cTabTemp)->GWGCDTPOP  := ""
				(cTabTemp)->GWGCDTPVC  := ""
				(cTabTemp)->GWGCDCLFR  := ""
				(cTabTemp)->GXTNRCT    := ""
				(cTabTemp)->GWJNRPF    := ""
				(cTabTemp)->GWJDTIMPL  := SToD("  /  /    ")
				(cTabTemp)->GWJSIT     := ""
				(cTabTemp)->GWJSITFIN  := ""
				(cTabTemp)->CODLOTE    := ""
				(cTabTemp)->GXFVALOR   := 0
				(cTabTemp)->PERLOTE    := ""
				(cTabTemp)->SITLOTE    := ""
				(cTabTemp)->GW3CDESP   := (cAliasQry)->GXG_CDESP
				(cTabTemp)->GW3NRDF    := (cAliasQry)->GXG_NRDF
				(cTabTemp)->GW3SERDF   := (cAliasQry)->GXG_SERDF
				(cTabTemp)->GW3TPDF    := (cAliasQry)->GXG_TPDF
				(cTabTemp)->GW3DTENT   := (cAliasQry)->GXG_DTENT
				(cTabTemp)->GW3DTEMIS  := (cAliasQry)->GXG_DTEMIS
				(cTabTemp)->VLFRETDF   := (cAliasQry)->GXG_VLDF
				(cTabTemp)->VLICMSDF   := (cAliasQry)->GXG_VLIMP
				(cTabTemp)->VLIBSDF    := 0
				(cTabTemp)->VLIBMDF    := 0
				(cTabTemp)->VLCBSDF    := 0
				(cTabTemp)->VLPISDF    := 0
				(cTabTemp)->VLCOFIDF   := 0
				(cTabTemp)->GW3SIT     := ""
				(cTabTemp)->GW3MOTBLQ  := rTrim(MemoLine(FWNoAccent(Posicione('GXG', 1, FWxFilial('GXG')+(cAliasQry)->GXG_NRIMP, 'GXG_EDIMSG')),128,1))
				(cTabTemp)->GW3SITFIS  := ""
				(cTabTemp)->GW3DTFIS   := SToD("  /  /    ")
				(cTabTemp)->GW3SITREC  := ""
				(cTabTemp)->GW3DTREC   := SToD("  /  /    ")
				(cTabTemp)->GW3SITCUS  := ""
				(cTabTemp)->GW3DTCUS   := SToD("  /  /    ")
				(cTabTemp)->GW3SITMLA  := ""
				(cTabTemp)->GW6NRFAT   := ""
				(cTabTemp)->GW6DTEMIS  := SToD("  /  /    ")
				(cTabTemp)->GW6VLFATU  := 0
				(cTabTemp)->GW6SITAPR  := ""
				(cTabTemp)->GW6DTFIN   := SToD("  /  /    ")
				(cTabTemp)->GW6SITFIN  := ""
				(cTabTemp)->GXGEDISIT  := RetSitEdi((cAliasQry)->GXG_EDISIT)
				(cTabTemp)->GW0MSG     := ""
				(cTabTemp)->GWNVPVAL   := 0
			(cTabTemp)->(MsUnlock())
			
			GFER002Line()
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		(cTabTemp)->(dbCloseArea())
	Endif
	GFEDelTab(cTabTemp)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} RetUso(cCodUso)
Retorna a finalidade do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetUso(cCodUso)

	Local cDesc := ""

	Do Case
	Case cCodUso == '1'
		cDesc := 'Industrialização/Venda'
	Case cCodUso == '2'
		cDesc := 'Uso/Consumo'
	Case cCodUso == '3'
		cDesc := 'Ativo Imobilizado'
	Otherwise
		cDesc := 'Finalidade Não Encontrada'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpMod(cTp)
Retorna o tipo de modal
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpMod(cTp )
	Local cDesc := ""

	Do Case
	Case cTp == "1"
		cDesc := "Nao-Informado"
	Case cTp == "2"
		cDesc := "Rodoviario"
	Case cTp == "3"
		cDesc := "Ferroviario"
	Case cTp == '4'
		cDesc := 'Aereo'
	Case cTp == '5'
		cDesc := 'Aquaviario'
	Case cTp == '6'
		cDesc := 'Dutoviario'
	Case cTp == '7'
		cDesc := 'Multimodal'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitGW1(cSit)
Retorna a situação do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitGW1(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Digitado"
	Case cSit == "2"
		cDesc := "Bloqueado"
	Case cSit == "3"
		cDesc := "Liberado"
	Case cSit == '4'
		cDesc := 'Embarcado'
	Case cSit == '5'
		cDesc := 'Entregue'
	Case cSit == '6'
		cDesc := 'Retornado'
	Case cSit == '7'
		cDesc := 'Cancelado'
	Case cSit == '8'
		cDesc := 'Sinistrado'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCalcGW1(cCalc)
Retorna a situação de cálculo do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCalcGW1(cCalc)
	Local cDesc := ""

	Do Case
	Case cCalc == "0"
		cDesc := "Não se Aplica"
	Case cCalc == "1"
		cDesc := "Cálculo Aut. Pendente"
	Case cCalc == "2"
		cDesc := "Cálculo Automático"
	Case cCalc == "3"
		cDesc := "Cálculo Sem Sucesso"
	Case cCalc == '4'
		cDesc := 'Romaneio Sem Sucesso'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc}  RetTpTrb(cTp)
Retorna o tipo de tributação
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpTrb(cTp )
	Local cDescTp := ""

	Do Case
	Case cTp == "1"
		cDescTp := "Normal"
	Case cTp == "2"
		cDescTp := "Simplificado"
	Case cTp == "3"
		cDescTp := "Especial"
	Case cTp == '4'
		cDescTp := 'Imune'
	EndCase
Return cDescTp
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitRom(cSit)
Retorna a situação do romaneio
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitRom(cSit )
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Digitado"
	Case cSit == "2"
		cDesc := "Emitido"
	Case cSit == "3"
		cDesc := "Liberado"
	Case cSit == '4'
		cDesc := 'Encerrado'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCalcGWN(cCalc)
Retorna a situação de cálculo do romaneio
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCalcGWN(cCalc)
	Local cDesc := ""

	Do Case
	Case cCalc == "1"
		cDesc := "Cálculo com Sucesso"
	Case cCalc == "2"
		cDesc := "Não Calculado"
	Case cCalc == "3"
		cDesc := "Tentativa Sem Sucesso"
	Case cCalc == "4"
		cDesc := "Necessita Recálculo"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpFrtCalc(cTpFrt)
Retorna o tipo de frete do cálculo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpFrtCalc(cTpFrt)
	Local cDesc := ""

	Do Case
	Case cTpFrt == "1"
		cDesc := "CIF"
	Case cTpFrt == "2"
		cDesc := "CIF Redesp"
	Case cTpFrt == "3"
		cDesc := "FOB"
	Case cTpFrt == "4"
		cDesc := "FOB Redesp."
	Case cTpFrt == "5"
		cDesc := "Consignado"
	Case cTpFrt == "6"
		cDesc := "Consig. Redesp."
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpTrbGWF(cTpTrib)
Retorna o tipo de tributo do cálculo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpTrbGWF(cTpTrib)
	Local cDesc := ""

	Do Case
	Case cTpTrib == "1"
		cDesc := "Tributado"
	Case cTpTrib == "2"
		cDesc := "Isento/Não-Tributado"
	Case cTpTrib == "3"
		cDesc := "Subs. Tributária"
	Case cTpTrib == "4"
		cDesc := "Diferido"
	Case cTpTrib == "5"
		cDesc := "Reduzido"
	Case cTpTrib == "6"
		cDesc := "Outros"
	Case cTpTrib == "Presumido"
		cDesc := "Outros"
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTipGW3(cTip)
Retorna o tipo de documento de frete
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTipGW3(cTip)
	Local cDesc := ""

	Do Case
	Case cTip == "1"
		cDesc := "Normal"
	Case cTip == "2"
		cDesc := "Complementar Valor"
	Case cTip == "3"
		cDesc := "Complementar Imposto"
	Case cTip == '4'
		cDesc := 'Reentrega'
	Case cTip == '5'
		cDesc := 'Devolução'
	Case cTip == '6'
		cDesc := 'Redespacho'
	Case cTip == '7'
		cDesc := 'Serviço'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetFisGW3(cSit)
Retorna a situação de integração fiscal
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetFisGW3(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Não Enviado"
	Case cSit == "2"
		cDesc := "Pendente"
	Case cSit == "3"
		cDesc := "Rejeitado"
	Case cSit == "4"
		cDesc := "Atualizado"
	Case cSit == "5"
		cDesc := "Pendente Desatualização"
	Case cSit == "6"
		cDesc := "Não se Aplica"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitCusGW3(cSit)
Retorna a situação de integração de centro de custo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitCusGW3(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "0"
		cDesc := "Não se Aplica"
	Case cSit == "1"
		cDesc := "Não Enviado"
	Case cSit == "2"
		cDesc := "Atualizado"
	Case cSit == "3"
		cDesc := "Rejeitado"
	Case cSit == "4"
		cDesc := "Pendente Atualização"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetFinGW6(cSit)
Retorna o tipo de situação financeira
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetFinGW6(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Não enviada"
	Case cSit == "2"
		cDesc := "Pendente"
	Case cSit == "3"
		cDesc := "Rejeitada"
	Case cSit == "4"
		cDesc := "Atualizada"
	Case cSit == "5"
		cDesc := "Pendente Desatualização"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitMLA(cSit)
Retorna o tipo de situação MLA
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitMLA(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Não Enviado"
	Case cSit == "2"
		cDesc := "Pendente"
	Case cSit == "3"
		cDesc := "Rejeitado"
	Case cSit == '4'
		cDesc := 'Aprovado'
	Case cSit == '5'
		cDesc := 'Pend. Desatualização'
	Case cSit == '6'
		cDesc := 'Não se Aplica'
	Case cSit == '7'
		cDesc := 'Enviado/Aguardando'
	Case cSit == '8'
		cDesc := 'Pendente Atualização'
	EndCase
Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitMLA(cSit)
Retorna o tipo de situação MLA
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSit(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Recebido(a)"
	Case cSit == "2"
		cDesc := "Bloqueado(a)"
	Case cSit == "3"
		cDesc := "Aprovado(a) Sistema"
	Case cSit == '4'
		cDesc := 'Aprovado(a) Usuário'
	EndCase
Return cDesc

Static Function RetSitEdi(cSit)
	Local cDesc := ""

	Do Case
	Case cSit == "1"
		cDesc := "Importado"
	Case cSit == "2"
		cDesc := "Importado Com Erro"
	Case cSit == "3"
		cDesc := "Rejeitado"
	Case cSit == "4"
		cDesc := "Processado"
	Case cSit == "5"
		cDesc := "Erro Impeditivo"
	Otherwise
		cDesc := "  "
	EndCase
Return cDesc

Static Function SchedDef()

	Local aParam := {}
	Local aOrd   := {""}

	aParam := { "R",;       //Tipo R para relatorio P para processo
	"GFER002",; // Pergunte do relatorio, caso nao use passar ParamDef
	"GW1",;     // Alias
	aOrd,;      //Array de ordens
	"Schedule GFER002"}
Return aParam

/*/{Protheus.doc} GFER002Txt
	Geração do relatório em CSV
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@return lRet, Logical, .T. com sucesso, .F. sem sucesso
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Txt()
	Local lRet     := .T.
	Local cGFEDoc  := ""
	Local cIdArq   := GetNextAlias()
	Local cLogFile := "GFER002_" + cIdArq + ".txt"

	Private nHandle := Nil

	cGFEDoc  := _cMvPar07
	If !Empty(cGFEDoc)
		cGFEDoc := AllTrim(cGFEDoc)
		If Right(cGFEDoc,1) $ "/\"
			cGFEDoc := Left(cGFEDoc,Len(cGFEDoc)-1)
		EndIf
		cLogFile := cGFEDoc+"/"+cLogFile
	EndIf

	If !File(cLogFile)
		nHandle := MSFCreate(cLogFile,0)
		If nHandle <> -1
			lRet := .T.
		EndIf
	Else
		nHandle := FOpen(cLogFile,2)
		If nHandle <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf
	If lRet
		GFER002Def()
		LoadTable()

		FClose(nHandle)
	Else
		MsgAlert("Erro durante criação do arquivo.")
	EndIf
Return lRet

/*/{Protheus.doc} GFER002Def
	Definição leioute CSV
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Def()
	Local cLinha := ""

	// Define cabeçalho
	cLinha := STR0002+";" // Código Filial
	cLinha += STR0003+";" // Nome Filial
	cLinha += STR0004+";" // Tipo DC
	cLinha += STR0005+";" // Cód. Emissor
	cLinha += STR0006+";" // CNPJ/CPF Emis.
	cLinha += STR0007+";" // Nome Emissor
	cLinha += STR0008+";" // Série DC
	cLinha += STR0009+";" // Número DC
	cLinha += STR0010+";" // Chave Acesso
	cLinha += STR0011+";" // Dt. Emissão
	cLinha += STR0012+";" // Dt. Implantação
	cLinha += STR0013+";" // Dt. Saída
	cLinha += STR0014+";" // Finalidade
	cLinha += STR0015+";" // Região Comercial
	cLinha += STR0016+";" // Item
	cLinha += STR0017+";" // Descrição Item
	cLinha += STR0018+";" // Quantidade Item
	cLinha += STR0019+";" // Valor Item
	cLinha += STR0020+";" // Volume Item
	cLinha += STR0021+";" // Peso Cubado Item
	cLinha += STR0022+";" // Peso Real Item
	cLinha += STR0023+";" // Quantidade/Peso Alt.
	cLinha += STR0024+";" // Classificação De Frete
	cLinha += STR0025+";" // CFOP
	cLinha += IIf(_IntGFE,STR0026,STR0027)+";" // Natureza de Operação // Info Contábil 1
	cLinha += IIf(_IntGFE,STR0028,STR0029)+";" // Canal de Vendas      // Info Contábil 2
	cLinha += IIf(_IntGFE,STR0030,STR0031)+";" // Grupo de Estoque     // Info Contábil 3
	cLinha += IIf(_IntGFE,STR0032,STR0033)+";" // Família Comercial    // Info Contábil 4
	cLinha += IIf(_IntGFE,STR0034,STR0035)+";" // Família de Materiais // Info Contábil 5
	cLinha += STR0036+";" // Código Remetente
	cLinha += STR0037+";" // CNPJ/CPF Remetente
	cLinha += STR0038+";" // Nome Remetente
	cLinha += STR0039+";" // Código Destinatário
	cLinha += STR0040+";" // CNPJ/CPF Destinatário
	cLinha += STR0041+";" // Nome Destinatário
	cLinha += STR0042+";" // Situação
	cLinha += STR0043+";" // Motivo Bloqueio
	cLinha += STR0044+";" // Sit. Cálc Automático
	cLinha += STR0045+";" // Tipo Veículo Romaneio
	cLinha += STR0046+";" // Classificação de Frete Romaneio
	cLinha += STR0047+";" // Tipo de Operação Romaneio
	cLinha += STR0048+";" // Cód. Cidade Emit
	cLinha += STR0049+";" // Cód. Cidade Origem
	cLinha += STR0050+";" // Nome Cidade Origem
	cLinha += STR0051+";" // UF Cidade Origem
	cLinha += STR0052+";" // Cód. Cidade Destino
	cLinha += STR0053+";" // Nome Cidade Destino
	cLinha += STR0054+";" // UF Cidade Destino
	cLinha += STR0055+";" // Região Própria
	cLinha += STR0056+";" // Região Negociação Frete
	cLinha += STR0057+";" // Sequência do Itinerário
	cLinha += STR0058+";" // Pagar
	cLinha += STR0059+";" // Código Transportador
	cLinha += STR0060+";" // CNPJ/CPF Transportador
	cLinha += STR0061+";" // Nome Transportador
	cLinha += STR0062+";" // Tipo Transportador
	cLinha += STR0063+";" // Modal Transportador
	cLinha += STR0064+";" // Regime Tributário Transp.
	cLinha += STR0065+";" // Número Romaneio
	cLinha += STR0066+";" // Situação Romaneio
	cLinha += STR0067+";" // Tipo de Veículo
	cLinha += STR0068+";" // Classificação de Frete Romaneio
	cLinha += STR0069+";" // Tipo de Operação
	cLinha += STR0070+";" // Situação Cálculo
	cLinha += STR0071+";" // Motivo Cálculo
	cLinha += STR0072+";" // Valor Pedágio
	cLinha += STR0073+";" // Data Prevista Entrega
	cLinha += STR0074+";" // Hora Prevista Entrega
	cLinha += STR0075+";" // Data Entrega
	cLinha += STR0076+";" // Hora Entrega
	cLinha += STR0077+";" // Número Cálculo
	cLinha += STR0078+";" // Tipo de Frete do Cálculo
	cLinha += STR0079+";" // Valor Frete
	cLinha += STR0080+";" // Valor ICMS
	cLinha += STR0081+";" // Valor PIS
	cLinha += STR0082+";" // Valor COFINS
	If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
		cLinha += "Valor IBS Est.;"
		cLinha += "Valor IBS Mun.;"
		cLinha += "Valor CBS;"
	EndIf
	cLinha += STR0083+";" // Tipo de Tributação
	cLinha += STR0084+";" // Gera Crédito ICMS
	cLinha += STR0085+";" // Gera Crédito PIS/COFINS
	cLinha += STR0086+";" // Número Tabela de Frete
	cLinha += STR0087+";" // Negociação
	cLinha += STR0088+";" // Faixa
	cLinha += STR0089+";" // Tipo de Operação
	cLinha += STR0090+";" // Tipo de Veículo
	cLinha += STR0091+";" // Class. Frete da Tab. de Frete
	cLinha += STR0092+";" // Unid. Faixa
	cLinha += STR0093+";" // Rota
	cLinha += STR0094+";" // Descrição da Rota
	cLinha += STR0095+";" // Número Pré-Fatura
	cLinha += STR0096+";" // Data de Implantação Pré-Fatura
	cLinha += STR0097+";" // Situação Pré-Fatura
	cLinha += STR0098+";" // Situação Pré-Fatura Financeiro
	cLinha += STR0099+";" // Código Lote
	cLinha += STR0100+";" // Valor Lote
	cLinha += STR0101+";" // Período Lote
	cLinha += STR0102+";" // Situação Lote
	If GFXTB12117("GXT")
		cLinha += STR0103+";" // Número Contrato Transp
	EndIf
	cLinha += STR0104+";" // Espécie Doc. Frete
	cLinha += STR0105+";" // Número Doc. Frete
	cLinha += STR0106+";" // Série Doc. Frete
	cLinha += STR0107+";" // Tipo Doc. Frete
	cLinha += STR0108+";" // Data de Entrada Doc. Frete
	cLinha += STR0109+";" // Data de Emissão Doc. Frete
	cLinha += STR0110+";" // Valor Doc. Frete
	cLinha += STR0111+";" // Valor ICMS Doc. Frete
	cLinha += STR0112+";" // Valor PIS Doc. Frete
	cLinha += STR0113+";" // Valor COFINS Doc. Frete
	If GFXCP2510('GWM_VLIBS') .And. GFXCP2510('GWM_VLIBM') .And. GFXCP2510('GWM_VLCBS')
		cLinha += "Valor IBS Est. Doc. Frete;"
		cLinha += "Valor IBS Mun. Doc. Frete;"
		cLinha += "Valor CBS Doc. Frete;"
	EndIf
	cLinha += STR0114+";" // Situação Documento de Frete
	cLinha += STR0115+";" // Situação EDI
	cLinha += STR0116+";" // Motivo Divergência Conferência
	cLinha += STR0117+";" // Situação Integração Fiscal
	cLinha += STR0118+";" // Data Integração Fiscal
	cLinha += STR0119+";" // Situação Integração Recebedoria
	cLinha += STR0120+";" // Data Integração Recebedoria
	cLinha += STR0121+";" // Situação Integ. Custo de Frete
	cLinha += STR0122+";" // Data Integ. Custo de Frete
	cLinha += STR0123+";" // Situação Integração MLA
	cLinha += STR0124+";" // Número Fatura
	cLinha += STR0125+";" // Data Emissão Fatura
	cLinha += STR0126+";" // Valor Fatura
	cLinha += STR0127+";" // Situação Fatura
	cLinha += STR0128+";" // Data Integração Fatura
	cLinha += STR0129 // Situação Integração Fatura


	FWrite(nHandle, cLinha + CRLF)
Return Nil
Static Function CriaTab()
	Local aCampos 		:= {}
	
	aadd(aCampos, {"GW1FILIAL" ,"C", TamSX3("GW1_FILIAL")[1]	    , TamSX3("GW1_FILIAL")[2]})
	aadd(aCampos, {"GW1NMFIL"  ,"C", TamSX3("GU3_NMEMIT")[1]	    , TamSX3("GU3_NMEMIT")[1]})
	aadd(aCampos, {"GW1CDTPDC" ,"C", TamSX3("GW1_CDTPDC")[1]  		, TamSX3("GW1_CDTPDC")[2]})
	aadd(aCampos, {"GW1EMISDC" ,"C", TamSX3("GW1_EMISDC")[1]    	, TamSX3("GW1_EMISDC")[2]})
	aadd(aCampos, {"CNPJEMIS"  ,"C", TamSX3("GU3_IDFED")[1]		    , TamSX3("GU3_IDFED")[2]})
	aadd(aCampos, {"NMEMIS"    ,"C", TamSX3("GU3_NMEMIT")[1]		, TamSX3("GU3_NMEMIT")[2]})
	aadd(aCampos, {"GW1SERDC"  ,"C", TamSX3("GW1_SERDC")[1]			, TamSX3("GW1_SERDC")[2]})
	aadd(aCampos, {"GW1NRDC"   ,"C", TamSX3("GW1_NRDC")[1]			, TamSX3("GW1_NRDC")[2]})
	aadd(aCampos, {"GW1DANFE"  ,"C", TamSX3("GW1_DANFE")[1]			, TamSX3("GW1_DANFE")[2]})
	aadd(aCampos, {"GW1DTEMIS" ,"D", TamSX3("GW1_DTEMIS")[1]	    , TamSX3("GW1_DTEMIS")[2]})
	aadd(aCampos, {"GW1DTIMPL" ,"D", TamSX3("GW1_DTIMPL")[1]		, TamSX3("GW1_DTIMPL")[2]})
	aadd(aCampos, {"GW1DTSAI"  ,"D", TamSX3("GW1_DTSAI")[1]		    , TamSX3("GW1_DTSAI")[2]})
	aadd(aCampos, {"GW1USO"    ,"C", 50								, TamSX3("GW1_USO")[2]})
	aadd(aCampos, {"GW1REGCOM" ,"C", TamSX3("GW1_REGCOM")[1]		, TamSX3("GW1_REGCOM")[2]})
	aadd(aCampos, {"GW8CDCLFR" ,"C", TamSX3("GW8_CDCLFR")[1]		, TamSX3("GW8_CDCLFR")[2]})
	aadd(aCampos, {"GW8ITEM"   ,"C", TamSX3("GW8_ITEM")[1]			, TamSX3("GW8_ITEM")[2]})
	aadd(aCampos, {"GW8SEQ"    ,"C", TamSX3("GW8_SEQ")[1]			, TamSX3("GW8_SEQ")[2]})
	aadd(aCampos, {"GW8DSITEM" ,"C", 50								, TamSX3("GW8_DSITEM")[2]})
	aadd(aCampos, {"GW8QTDE"   ,"N", TamSX3("GW8_QTDE")[1]			, TamSX3("GW8_QTDE")[2]})
	aadd(aCampos, {"GW8VALOR"  ,"N", TamSX3("GW8_VALOR")[1]			, TamSX3("GW8_VALOR")[2]})
	aadd(aCampos, {"GW8VOLUME" ,"N", TamSX3("GW8_VOLUME")[1]		, TamSX3("GW8_VOLUME")[2]})
	aadd(aCampos, {"GW8PESOC"  ,"N", TamSX3("GW8_PESOC")[1]			, TamSX3("GW8_PESOC")[2]})
	aadd(aCampos, {"GW8PESOR"  ,"N", TamSX3("GW8_PESOR")[1]			, TamSX3("GW8_PESOR")[2]})
	aadd(aCampos, {"GW8QTDALT" ,"N", TamSX3("GW8_QTDALT")[1]		, TamSX3("GW8_QTDALT")[2]})
	aadd(aCampos, {"GUBDSCLFR" ,"C", TamSX3("GUB_DSCLFR")[1]		, TamSX3("GUB_DSCLFR")[2]})
	aadd(aCampos, {"GW8CFOP"   ,"C", TamSX3("GW8_CFOP")[1]			, TamSX3("GW8_CFOP")[2]})
	aadd(aCampos, {"GW8INFO1"  ,"C", TamSX3("GW8_INFO1")[1]			, TamSX3("GW8_INFO1")[2]})
	aadd(aCampos, {"GW8INFO2"  ,"C", TamSX3("GW8_INFO2")[1]			, TamSX3("GW8_INFO2")[2]})
	aadd(aCampos, {"GW8INFO3"  ,"C", TamSX3("GW8_INFO3")[1]			, TamSX3("GW8_INFO3")[2]})
	aadd(aCampos, {"GW8INFO4"  ,"C", TamSX3("GW8_INFO4")[1]			, TamSX3("GW8_INFO4")[2]})
	aadd(aCampos, {"GW8INFO5"  ,"C", TamSX3("GW8_INFO5")[1]			, TamSX3("GW8_INFO5")[2]})
	aadd(aCampos, {"GW1CDREM"  ,"C", TamSX3("GW1_CDREM")[1]			, TamSX3("GW1_CDREM")[2]})
	aadd(aCampos, {"CNPJREM"   ,"C", TamSX3("GU3_IDFED")[1]			, TamSX3("GU3_IDFED")[2]})
	aadd(aCampos, {"NMREM"     ,"C", TamSX3("GU3_NMEMIT")[1]		, TamSX3("GU3_NMEMIT")[2]})
	aadd(aCampos, {"GW1CDDEST" ,"C", TamSX3("GW1_CDDEST")[1]		, TamSX3("GW1_CDDEST")[2]})
	aadd(aCampos, {"CNPJDEST"  ,"C", TamSX3("GU3_IDFED")[1]			, TamSX3("GU3_IDFED")[2]})
	aadd(aCampos, {"NMDEST"    ,"C", TamSX3("GU3_NMEMIT")[1]		, TamSX3("GU3_NMEMIT")[2]})
	aadd(aCampos, {"GW1SIT"    ,"C", TamSX3("GW1_SIT")[1]			, TamSX3("GW1_SIT")[2]})
	aadd(aCampos, {"GW1SITDES" ,"C", 30								, TamSX3("GW1_SIT")[2]})
	aadd(aCampos, {"GW0MSG"    ,"C", 300							, TamSX3("GW0_CHAR01")[2]})
	aadd(aCampos, {"GW1CALCAT" ,"C", 30								, TamSX3("GW1_CALCAT")[2]})
	aadd(aCampos, {"GW1ROMTV"  ,"C", TamSX3("GW1_ROMTV")[1]			, TamSX3("GW1_ROMTV")[2]})
	aadd(aCampos, {"GW1ROMCF"  ,"C", TamSX3("GW1_ROMCF")[1]			, TamSX3("GW1_ROMCF")[2]})
	aadd(aCampos, {"GW1ROMTO"  ,"C", TamSX3("GW1_ROMTO")[1]			, TamSX3("GW1_ROMTO")[2]})
	aadd(aCampos, {"GU3NRCID"  ,"C", TamSX3("GU3_NRCID")[1]			, TamSX3("GU3_NRCID")[2]})
	aadd(aCampos, {"GWUNRCIDO" ,"C", TamSX3("GWU_NRCIDO")[1]		, TamSX3("GWU_NRCIDO")[2]})
	aadd(aCampos, {"NMCIDO"    ,"C", TamSX3("GU7_NMCID")[1]			, TamSX3("GU7_NMCID")[2]})
	aadd(aCampos, {"UFO"       ,"C", TamSX3("GU7_CDUF")[1]			, TamSX3("GU7_CDUF")[2]})
	aadd(aCampos, {"GWUNRCIDD" ,"C", TamSX3("GWU_NRCIDD")[1]		, TamSX3("GWU_NRCIDD")[2]})
	aadd(aCampos, {"NMCIDD"    ,"C", TamSX3("GU7_NMCID")[1]			, TamSX3("GU7_NMCID")[2]})
	aadd(aCampos, {"UFD"       ,"C", TamSX3("GU7_CDUF")[1]			, TamSX3("GU7_CDUF")[2]})
	aadd(aCampos, {"NMREGP"    ,"C", TamSX3("GU9_NMREG")[1]			, TamSX3("GU9_NMREG")[2]})
	aadd(aCampos, {"NMREGD"    ,"C", TamSX3("GU9_NMREG")[1]			, TamSX3("GU9_NMREG")[2]})
	aadd(aCampos, {"GWUSEQ"    ,"C", TamSX3("GWU_SEQ")[1]			, TamSX3("GWU_SEQ")[2]})
	aadd(aCampos, {"GWUPAGAR"  ,"C", 5								, TamSX3("GWU_PAGAR")[2]})
	aadd(aCampos, {"GWUCDTRP"  ,"C", TamSX3("GWU_CDTRP")[1]			, TamSX3("GWU_CDTRP")[2]})
	aadd(aCampos, {"CNPJTRP"   ,"C", TamSX3("GU3_IDFED")[1]			, TamSX3("GU3_IDFED")[2]})
	aadd(aCampos, {"NMTRP"     ,"C", TamSX3("GU3_NMEMIT")[1]		, TamSX3("GU3_NMEMIT")[2]})
	aadd(aCampos, {"AUTON"     ,"C", 15								, TamSX3("GU3_AUTON")[2]})
	aadd(aCampos, {"MODAL"     ,"C", 30								, TamSX3("GU3_MODAL")[2]})
	aadd(aCampos, {"TPTRIB"    ,"C", 30								, TamSX3("GWF_TPTRIB")[2]})
	aadd(aCampos, {"GWNNRROM"  ,"C", TamSX3("GWN_NRROM")[1]			, TamSX3("GWN_NRROM")[2]})
	aadd(aCampos, {"GWNSIT"    ,"C", 30								, TamSX3("GWN_SIT")[2]})
	aadd(aCampos, {"GWNCDTPVC" ,"C", TamSX3("GWN_CDTPVC")[1]		, TamSX3("GWN_CDTPVC")[2]})
	aadd(aCampos, {"GWNCDCLFR" ,"C", TamSX3("GWN_CDCLFR")[1]		, TamSX3("GWN_CDCLFR")[2]})
	aadd(aCampos, {"GWNCDTPOP" ,"C", TamSX3("GWN_CDTPOP")[1]		, TamSX3("GWN_CDTPOP")[2]})
	aadd(aCampos, {"GWNCALC"   ,"C", 30								, TamSX3("GWN_CALC")[2]})
	aadd(aCampos, {"GWNMTCALC" ,"C", TamSX3("GWN_MTCALC")[1]		, TamSX3("GWN_MTCALC")[2]})
	aadd(aCampos, {"GWNVPVAL"  ,"N", TamSX3("GWN_VPVAL")[1]			, TamSX3("GWN_VPVAL")[2]})
	aadd(aCampos, {"GWUDTPENT" ,"D", TamSX3("GWU_DTPENT")[1]		, TamSX3("GWU_DTPENT")[2]})
	aadd(aCampos, {"GWUHRPENT" ,"C", TamSX3("GWU_HRPENT")[1]		, TamSX3("GWU_HRPENT")[2]})
	aadd(aCampos, {"GWUDTENT"  ,"D", TamSX3("GWU_DTENT")[1]			, TamSX3("GWU_DTENT")[2]})
	aadd(aCampos, {"GWUHRENT"  ,"C", TamSX3("GWU_HRENT")[1]			, TamSX3("GWU_HRENT")[2]})
	aadd(aCampos, {"GWFNRCALC" ,"C", TamSX3("GWF_NRCALC")[1]		, TamSX3("GWF_NRCALC")[2]})
	aadd(aCampos, {"GWFTPFRET" ,"C", 30								, TamSX3("GWF_TPFRET")[2]})
	aadd(aCampos, {"VLFRET"    ,"N", TamSX3("GWM_VLFRET")[1]		, TamSX3("GWM_VLFRET")[2]})
	aadd(aCampos, {"VLICMS"    ,"N", TamSX3("GWM_VLICMS")[1]		, TamSX3("GWM_VLICMS")[2]})
	aadd(aCampos, {"VLPIS"     ,"N", TamSX3("GWM_VLPIS")[1]			, TamSX3("GWM_VLPIS")[2]})
	aadd(aCampos, {"VLCOFI"    ,"N", TamSX3("GWM_VLCOFI")[1]		, TamSX3("GWM_VLCOFI")[2]})
	aadd(aCampos, {"GWFTPTRIB" ,"C", 30								, TamSX3("GWF_TPTRIB")[2]})
	aadd(aCampos, {"GWFCRDICM" ,"C", 5								, TamSX3("GWF_CRDICM")[2]})
	aadd(aCampos, {"GWFCRDPC"  ,"C", 5								, TamSX3("GWF_CRDPC")[2]})
	aadd(aCampos, {"GWFNRDF"   ,"C", TamSX3("GWF_NRDF")[1]			, TamSX3("GWF_NRDF")[2]})
	aadd(aCampos, {"GWFCDESP"  ,"C", TamSX3("GWF_CDESP")[1]			, TamSX3("GWF_CDESP")[2]})
	aadd(aCampos, {"GWFEMISDF" ,"C", TamSX3("GWF_EMISDF")[1]		, TamSX3("GWF_EMISDF")[2]})
	aadd(aCampos, {"GWFSERDF"  ,"C", TamSX3("GWF_SERDF")[1]			, TamSX3("GWF_SERDF")[2]})
	aadd(aCampos, {"GWFDTMDF"  ,"D", TamSX3("GWF_DTEMDF")[1]		, TamSX3("GWF_DTEMDF")[2]})
	aadd(aCampos, {"GWGNRTAB"  ,"C", TamSX3("GWG_NRTAB")[1]			, TamSX3("GWG_NRTAB")[2]})
	aadd(aCampos, {"GWGNRNEG"  ,"C", TamSX3("GWG_NRNEG")[1]			, TamSX3("GWG_NRNEG")[2]})
	aadd(aCampos, {"GWGCDFXTV" ,"C", TamSX3("GWG_CDFXTV")[1]		, TamSX3("GWG_CDFXTV")[2]})
	aadd(aCampos, {"GWGCDTPOP" ,"C", TamSX3("GWG_CDTPOP")[1]		, TamSX3("GWG_CDTPOP")[2]})
	aadd(aCampos, {"GWGCDTPVC" ,"C", TamSX3("GWG_CDTPVC")[1]		, TamSX3("GWG_CDTPVC")[2]})
	aadd(aCampos, {"GWGCDCLFR" ,"C", TamSX3("GWG_CDCLFR")[1]		, TamSX3("GWG_CDCLFR")[2]})
	aadd(aCampos, {"GV9UNIFAI" ,"C", TamSX3("GV9_UNIFAI")[1]		, TamSX3("GV9_UNIFAI")[2]})
	aadd(aCampos, {"GWGNRROTA" ,"C", TamSX3("GWG_NRROTA")[1]		, TamSX3("GWG_NRROTA")[2]})
	aadd(aCampos, {"DESCROTA"  ,"C", TamSX3("GV6_INFROT")[1]		, TamSX3("GV6_INFROT")[2]})
	aadd(aCampos, {"GWJNRPF"   ,"C", TamSX3("GWJ_NRPF")[1]			, TamSX3("GWJ_NRPF")[2]})
	aadd(aCampos, {"GWJDTIMPL" ,"D", TamSX3("GWJ_DTIMPL")[1]		, TamSX3("GWJ_DTIMPL")[2]})
	aadd(aCampos, {"GWJSIT"    ,"C", 30								, TamSX3("GWJ_SIT")[2]})
	aadd(aCampos, {"GWJSITFIN" ,"C", 30								, TamSX3("GWJ_SITFIN")[2]})
	aadd(aCampos, {"CODLOTE"   ,"C", TamSX3("GXE_CODLOT")[1]		, TamSX3("GXE_CODLOT")[2]})
	aadd(aCampos, {"GXFVALOR"  ,"N", TamSX3("GXF_VALOR")[1]			, TamSX3("GXF_VALOR")[2]})
	aadd(aCampos, {"PERLOTE"   ,"C", TamSX3("GXE_PERIOD")[1]		, TamSX3("GXE_PERIOD")[2]})
	aadd(aCampos, {"SITLOTE"   ,"C", 30								, TamSX3("GXE_SIT")[2]})
	aadd(aCampos, {"GXTNRCT"   ,"C", TamSX3("GXT_NRCT")[1]			, TamSX3("GXT_NRCT")[2]})
	aadd(aCampos, {"VLFRETDF"  ,"N", TamSX3("GWM_VLFRET")[1]		, TamSX3("GWM_VLFRET")[2]})
	aadd(aCampos, {"VLICMSDF"  ,"N", TamSX3("GWM_VLICMS")[1]		, TamSX3("GWM_VLICMS")[2]})
	aadd(aCampos, {"VLPISDF"   ,"N", TamSX3("GWM_VLPIS")[1]			, TamSX3("GWM_VLPIS")[2]})
	aadd(aCampos, {"VLCOFIDF"  ,"N", TamSX3("GWM_VLCOFI")[1]		, TamSX3("GWM_VLCOFI")[2]})
	aadd(aCampos, {"GXGEDISIT" ,"C", 30								, TamSX3("GXG_EDISIT")[2]})
	aadd(aCampos, {"GW3FILIAL" ,"C", TamSX3("GW3_FILIAL")[1]		, TamSX3("GW3_FILIAL")[2]})
	aadd(aCampos, {"GW3CDESP"  ,"C", TamSX3("GW3_CDESP")[1]			, TamSX3("GW3_CDESP")[2]})
	aadd(aCampos, {"GW3EMISDF" ,"C", TamSX3("GW3_EMISDF")[1]		, TamSX3("GW3_EMISDF")[2]})
	aadd(aCampos, {"GW3NRDF"   ,"C", TamSX3("GW3_NRDF")[1]			, TamSX3("GW3_NRDF")[2]})
	aadd(aCampos, {"GW3SERDF"  ,"C", TamSX3("GW3_SERDF")[1]			, TamSX3("GW3_SERDF")[2]})
	aadd(aCampos, {"GW3SIT"    ,"C", 30								, TamSX3("GW3_SIT")[2]})
	aadd(aCampos, {"GW3TPDF"   ,"C", 30								, TamSX3("GW3_TPDF")[2]})
	aadd(aCampos, {"GW3DTENT"  ,"D", TamSX3("GW3_DTENT")[1]			, TamSX3("GW3_DTENT")[2]})
	aadd(aCampos, {"GW3DTEMIS" ,"D", TamSX3("GW3_DTEMIS")[1]		, TamSX3("GW3_DTEMIS")[2]})
	aadd(aCampos, {"GW3MOTBLQ" ,"C", TamSX3("GW3_MOTBLQ")[1]		, TamSX3("GW3_MOTBLQ")[2]})
	aadd(aCampos, {"GW3SITFIS" ,"C", 30								, TamSX3("GW3_SITFIS")[2]})
	aadd(aCampos, {"GW3DTFIS"  ,"D", TamSX3("GW3_DTFIS")[1]			, TamSX3("GW3_DTFIS")[2]})
	aadd(aCampos, {"GW3SITREC" ,"C", 30								, TamSX3("GW3_SITREC")[2]})
	aadd(aCampos, {"GW3DTREC"  ,"D", TamSX3("GW3_DTREC")[1]			, TamSX3("GW3_DTREC")[2]})
	aadd(aCampos, {"GW3SITCUS" ,"C", 30								, TamSX3("GW3_SITCUS")[2]})
	aadd(aCampos, {"GW3DTCUS"  ,"D", TamSX3("GW3_DTCUS")[1]			, TamSX3("GW3_DTCUS")[2]})
	aadd(aCampos, {"GW3SITMLA" ,"C", 30								, TamSX3("GW3_SITMLA")[2]})
	aadd(aCampos, {"GW6NRFAT"  ,"C", TamSX3("GW6_NRFAT")[1]			, TamSX3("GW6_NRFAT")[2]})
	aadd(aCampos, {"GW6DTEMIS" ,"D", TamSX3("GW6_DTEMIS")[1]		, TamSX3("GW6_DTEMIS")[2]})
	aadd(aCampos, {"GW6VLFATU" ,"N", TamSX3("GW6_VLFATU")[1]		, TamSX3("GW6_VLFATU")[2]})
	aadd(aCampos, {"GW6SITAPR" ,"C", 30								, TamSX3("GW6_SITAPR")[2]})
	aadd(aCampos, {"GW6DTFIN"  ,"D", TamSX3("GW6_DTFIN")[1]			, TamSX3("GW6_DTFIN")[2]})
	aadd(aCampos, {"GW6SITFIN" ,"C", 30								, TamSX3("GW6_SITFIN")[2]})

	If GFXCP2510('GWM_VLIBS')
		aadd(aCampos, {"VLIBS"  ,"N", TamSX3("GWM_VLIBS")[1]		, TamSX3("GWM_VLIBS")[2]})
		aadd(aCampos, {"VLIBSDF","N", TamSX3("GWM_VLIBS")[1]		, TamSX3("GWM_VLIBS")[2]})
	EndIf
	If GFXCP2510('GWM_VLIBM')
		aadd(aCampos, {"VLIBM"  ,"N", TamSX3("GWM_VLIBM")[1]		, TamSX3("GWM_VLIBM")[2]})
		aadd(aCampos, {"VLIBMDF","N", TamSX3("GWM_VLIBM")[1]		, TamSX3("GWM_VLIBM")[2]})
	EndIf
	If GFXCP2510('GWM_VLCBS')
		aadd(aCampos, {"VLCBS"  ,"N", TamSX3("GWM_VLCBS")[1]		, TamSX3("GWM_VLCBS")[2]})
		aadd(aCampos, {"VLCBSDF","N", TamSX3("GWM_VLCBS")[1]		, TamSX3("GWM_VLCBS")[2]})
	EndIf
	
	cTabTemp := GFECriaTab({aCampos,{"GW1FILIAL+GW1CDTPDC+GW1EMISDC+GW1SERDC+GW1NRDC+GW8SEQ+CNPJEMIS+GWFNRDF+GWFCDESP+GWFEMISDF+GWFSERDF",;
									 "GW1FILIAL+GW1CDTPDC+GW1EMISDC+GW1SERDC+GW1NRDC+GW8SEQ+GWUCDTRP+GW8CDCLFR"}})
Return cTabTemp
