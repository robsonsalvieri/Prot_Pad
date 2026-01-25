#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include 'tbiconn.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'VEIA140.CH'

Static oModelVQE
Static oModelVJU
Static oModelVJQ
Static oModelVQ0
Static oModelVV1
Static oModelVJV
Static oModelVQC
Static lMVMIL0185
Static oFilHelper
Static oArrayHelper
Static cBaseCode := ""

//static aFilCodCli := {}

Static oModelVN0
/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VEIA140()

Local bProcess
Local cPerg := "VEIA140"
Local oTProces
Private lSchedule := FWGetRunSchedule()
Private cCodMar   := FMX_RETMAR(GetNewPar("MV_MIL0006",""))
Private cMarVeiF3 := "JD"

VV2->( DbSetOrder(1) )
VV2->( DbSeek( xFilial("VV2") + cCodMar ) )

bProcess := { |oSelf| VA1400051_Processa(oSelf) }
CriaSX1(cPerg)

If lSchedule
	VA1400051_Processa()
Else
	oTProces := tNewProcess():New(;
	/* 01 */				"VEIA140",;
	/* 02 */				"Dealer Data Exchange Complete Goods (CGPoll)",;
	/* 03 */				bProcess,;
	/* 04 */				STR0001,;
	/* 05 */				cPerg ,;
	/* 06 */				/*aInfoCustom*/ ,;
	/* 07 */				.t. /* lPanelAux */ ,;
	/* 08 */				5 /* nSizePanelAux */ ,;
	/* 09 */				/* cDescriAux */ ,;
	/* 10 */				.t. /* lViewExecute */ ,;
	/* 11 */				.t. /* lOneMeter */ )
EndIf

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function SchedDef()
	Local aParam := {"P","VEIA140","","",""}
Return aParam

Function VA1400051_Processa(oProcess)

Local cLocal   := Alltrim(MV_PAR01)
Local nX
Local aVetNome := {}
//Local aVetTam  := {}
//Local aVetData := {}
//Local aVetHora := {}
//Local aFiles   := {}
Local cArquivo  := ""
Local cMoveArq  := ""
Local aPedPro   := {}

Local cCompVQ0  := FwModeAccess("VQ0",1) + FwModeAccess("VQ0",2) + FwModeAccess("VQ0",3)
Local cCompVJR  := FwModeAccess("VJR",1) + FwModeAccess("VJR",2) + FwModeAccess("VJR",3)

Local nPosFil   := 0
Local oAuxFil   := DMS_FilialHelper():New()
Local aFiliais  := oAuxFil:GetAllFilEmpresa(.t.)
Local cCor      := ""

Private aRegrVl:= {}
Private aVetGrv:= {}
Private aVStat := {}
Private cStr   := ""
Private dDtaIni:= MV_PAR02

Private oFilJD := DMS_DPM():New()
Private aVQ0VQJ:= {}

Private aMapFilDealerCode := {}
oArrayHelper := DMS_ArrayHelper():New()
If !(cCompVQ0 == cCompVJR)
	MsgStop(STR0002,STR0003) // "Compartilhamento entre as tabelas VQ0 e VJR estão divergentes. É necessário ajustar para prosseguir com a importação!" / "Atenção"
	Return
EndIf

If Empty(dDtaIni)
	MsgStop(STR0004,STR0003) //"Informe a data inicial que o CGPoll foi implementado!" / "Atenção"
	Return
EndIf

if VA1400019_PergunteCOR() 
	cCor := MV_PAR03

	If Empty(cCor)
		MsgStop(STR0022,STR0003)  //"Informe a cor!" / "Atenção"
		Return
	EndIf

EndIf

For nPosFil := 1 to Len(aFiliais)
	AADD( aMapFilDealerCode , { aFiliais[nPosFil] , GetNewPar("MV_MIL0005","", aFiliais[nPosFil]) })
Next nPosFil

//Implicit Trailing Signs
aAdd(aRegrVl,{'{', "0"})
aAdd(aRegrVl,{'}', "-0"})
aAdd(aRegrVl,{'A', "1"})
aAdd(aRegrVl,{'B', "2"})
aAdd(aRegrVl,{'C', "3"})
aAdd(aRegrVl,{'D', "4"})
aAdd(aRegrVl,{'E', "5"})
aAdd(aRegrVl,{'F', "6"})
aAdd(aRegrVl,{'G', "7"})
aAdd(aRegrVl,{'H', "8"})
aAdd(aRegrVl,{'I', "9"})
aAdd(aRegrVl,{'J', "-1"})
aAdd(aRegrVl,{'K', "-2"})
aAdd(aRegrVl,{'L', "-3"})
aAdd(aRegrVl,{'M', "-4"})
aAdd(aRegrVl,{'N', "-5"})
aAdd(aRegrVl,{'O', "-6"}) 
aAdd(aRegrVl,{'P', "-7"})
aAdd(aRegrVl,{'Q', "-8"})
aAdd(aRegrVl,{'R', "-9"})

aAdd(aVStat,{"NDA","0"}) // Nenhum
aAdd(aVStat,{"CAN","1"}) // Cancelled
aAdd(aVStat,{"CON","2"}) // Confirmed
aAdd(aVStat,{"ERR","3"}) // Order in error
aAdd(aVStat,{"FRZ","4"}) // Frozen
aAdd(aVStat,{"ICS","5"}) // Invoice complete
aAdd(aVStat,{"IPS","6"}) // Partially invoiced
aAdd(aVStat,{"RLS","7"}) // Released (i.e. inventory applied)
aAdd(aVStat,{"SHP","8"}) // Shipped
aAdd(aVStat,{"SSD","9"}) // Scheduled Ship Date set
aAdd(aVStat,{"UNC","A"}) // Unconfirmed
aAdd(aVStat,{"UNS","B"}) // Unsourced
aAdd(aVStat,{"TRF","C"}) // Transfered

/* Matriz aVQ0VQJ
	1 - Campo a ser gravado
	2 - Campo com o conteudo
	3 - Model que será gravada
	4 - Indicador de gravação
		I - Inclusão
		T - Inclusão e Alteração
*/

aAdd(aVQ0VQJ,{"VJR_ORDNUM","VJQ_ORDNUM","VJRMASTER","I"})

aAdd(aVQ0VQJ,{"VQ0_DATPED","VJQ_ORDDAT","VQ0MASTER","I"})

aAdd(aVQ0VQJ,{"VQ0_NUMPED","VJQ_QUOTNR","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_MODVEI","VJQ_MODNUM","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_CHASSI","VJQ_PRODID","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_FILPED","VJQ_SOLDAC","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_FILENT","VJQ_SHIPAC","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_VALCUS","VJQ_ORDTOT","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_EVENTO","VJQ_EVNTID","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_STATUS","VJQ_QUOTST","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_FATDIR","VJQ_ORDTYP","VQ0MASTER","T"})
aAdd(aVQ0VQJ,{"VQ0_SEGMOD","VJQ_ORDTP" ,"VQ0MASTER","T"})

aAdd(aVQ0VQJ,{"VJR_EVENTO","VJQ_EVNTID","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_STAFAB","VJQ_ORDSTA","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_DATORS","VJQ_SHIPDT","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_DATFDD","VJQ_DATFDD","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_ORDCOD","VJQ_ORDCOD","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_RTLDAT","VJQ_RTLDAT","VJRMASTER","T"})
aAdd(aVQ0VQJ,{"VJR_CCGNAM","VJQ_CCGNAM","VJRMASTER","T"})

//if aDir(cLocal+"RECEIPTS_*.DAT" ,aVetNome,aVetTam,aVetData,aVetHora) == 0 .and.;
//	aDir(cLocal+"OUTBOUND_*.DAT" ,aVetNome,aVetTam,aVetData,aVetHora) == 0
//	Return
//EndIf

//if aDir(cLocal+"RECEIPTS_*.DAT" ,aVetNome,aVetTam,aVetData,aVetHora) == 0 .and.;
aVetNome := Directory(cLocal + "RECEIPTS_*.DAT")
aVetNome := oArrayHelper:Merge(aVetNome,Directory(cLocal + "OUTBOUND_*.DAT"))
if len(aVetNome) == 0
	Return
endif

aSort(aVetNome,,,{|x,y| dtos(x[3])+x[4] < dtos(y[3])+y[4] })

if ! lSchedule
	oProcess:SetRegua1(Len(aVetNome))
endif

for nX := 1 to Len(aVetNome)

	cArquivo := Alltrim(cLocal+aVetNome[nX,1])
	cMoveArq := cLocal + ALLTRIM(STR0005 + "\ ") + aVetNome[nX,1] //importados

	oFile := FWFileReader():New(cArquivo)

	if ! lSchedule
		oProcess:IncRegua1(cArquivo)
	endif

	if (oFile:Open())

		While (oFile:hasLine())
			
			cStr := oFile:GetLine()
			
			cTpRegtr := Subs(cStr, 1,3) //Network Code

			If Left(cTpRegtr,1) == "Z"
				cTpMovto := Subs(cStr, 4,1) //Poll Record Type
				cGpOrder := Subs(cStr, 5,2) //Order Group code
				cOrderNr := Subs(cStr, 7,6) //Order Number code


				Do Case
					Case cTpMovto == "1" // 1-Header Record
						VA1400052_HeaderRecord(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
					Case cTpMovto == "2" // 2-Detail
						VA1400053_Detail(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
					Case cTpMovto == "3" // 3-Header Extension Record
						VA1400054_HeaderExtensionRecord(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
					Case cTpMovto == "4" // 4-Extension Part 1
						VA1400055_ExtensionPart1(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
					Case cTpMovto == "5" // 5-Detail Extension Part 2
						VA1400056_DetailExtensionPart2(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
					Case cTpMovto == "6" // 6-Detail Extension Part 3
						VA1400057_DetailExtensionPart3(cStr,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)
				EndCase
			End
		End

		oFile:Close()

		aPedPro := {}

		VA140005O_GravacaoImportacao(@aPedPro)
		VA140005N_GravacaoPedidoVQ0(aPedPro, cCor)

		Copy File &(cArquivo) to &(cMoveArq)
		Dele File &(cArquivo)

		VA1400059_LimpaVetor(aVetGrv)
		aVetGrv := {}

	End

Next

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400052_HeaderRecord(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Local cNrOrder := ""
Local cTpLinha := ""
Local cNrLinha := ""
Local cShipAcc := ""
Local cDtCriac := ""
Local cDtInvoi := ""
Local cNumbAcc := ""
Local cCodFato := ""
Local cCodIden := ""
Local cChkLeit := ""
Local cOrigEnt := ""
Local cVlMaqDl := ""
Local cVlMaqLt := ""
Local cCodProd := ""
Local cNrSerie := ""
Local cSerTran := ""
Local cSerCab  := ""
Local cDataFDD := ""
Local cFiller  := ""
Local cQtdaOri := ""
Local cIndShip := ""
Local cStatOrd := ""
Local cIndCons := ""
Local cCdManut := ""
Local cFiller2 := ""

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cNrOrder := Subs(cLinha, 13, 2) //Sequence Number
cTpLinha := Subs(cLinha, 15, 1) //Poll Activity Type
cNrLinha := Subs(cLinha, 16, 2) //Poll Record Sequence
cShipAcc := Subs(cLinha, 18, 6) //Ship To Account
cDtCriac := Subs(cLinha, 24, 8) //Order Date
cDtInvoi := Subs(cLinha, 32, 8) //Invoice Date
cNumbAcc := Subs(cLinha, 40, 6) //Sold to Account
cCodFato := Subs(cLinha, 46, 2) //Source of Supply Unit
cCodIden := Subs(cLinha, 48, 2) //Source of Supply Location
cChkLeit := Subs(cLinha, 50, 3) //Check Letter
cOrigEnt := Subs(cLinha, 53, 1) //Method of Order Entry
cVlMaqDl := Subs(cLinha, 54, 9) //Dealer Order Cost
cVlMaqLt := Subs(cLinha, 63, 9) //Dealer Order List

If cTpLinha $ "IT" //Dealer Invoice - Dealer Transfer
	cCodProd := Subs(cLinha, 72,13) //Product ID Number
	cNrSerie := Subs(cLinha, 85,13) //Engine Serial Number
	cSerTran := Subs(cLinha, 98,13) //Transmission Serial Number
	cSerCab  := Subs(cLinha,111,13) //Cab Serial Number
Else
	cDataFDD := Subs(cLinha, 72, 8) //Date FDD
	cFiller  := Subs(cLinha, 80,44) //Filler
End

cQtdaOri := Subs(cLinha,124, 2) //Original Order Quantity
cIndShip := Subs(cLinha,126, 1) //Early Ship Indicator
cStatOrd := Subs(cLinha,127, 3) //Order Status

If cTpLinha $ "IT"
	cIndCons := Subs(cLinha,130, 1) //Consigned Indicator
	cCdManut := Subs(cLinha,131, 3) //WMC
Else
	cFiller2 := Subs(cLinha,130, 3) //Filler
EndIf

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_SEQNUM",cNrOrder},;
				{"VJQ_ACTVTP",cTpLinha},;
				{"VJQ_RCRDSQ",Val(cNrLinha)},;
				{"VJQ_SHIPAC",cShipAcc},;
				{"VJQ_ORDDAT",StoD(cDtCriac)},;
				{"VJQ_INVDAT",StoD(cDtInvoi)},;
				{"VJQ_SOLDAC",cNumbAcc},;
				{"VJQ_SUPUNT",cCodFato},;
				{"VJQ_SUPLOC",cCodIden},;
				{"VJQ_CHKLET",cChkLeit},;
				{"VJQ_ORDENT",cOrigEnt},;
				{"VJQ_ORDCOS",VA1400058_ImplicitTrailingSigns(cVlMaqDl,"VJQ_ORDCOS")},;
				{"VJQ_ORDLIS",VA1400058_ImplicitTrailingSigns(cVlMaqLt,"VJQ_ORDLIS")},;
				{"VJQ_PRODID",cCodProd},;
				{"VJQ_ENGSER",cNrSerie},;
				{"VJQ_TRMSER",cSerTran},;
				{"VJQ_CABSER",cSerCab},;
				{"VJQ_DATFDD",StoD(cDataFDD)},;
				{"VJQ_ORDQNT",Val(cQtdaOri)},;
				{"VJQ_SHIPIN",cIndShip},;
				{"VJQ_ORDSTA",cStatOrd},;
				{"VJQ_CNSGIN",cIndCons},;
				{"VJQ_WMC"   ,cCdManut};
			})

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400053_Detail(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Local cNrOrder := ""
Local cTpLinha := ""
Local cNrLinha := ""
Local cShipAcc := ""
Local cCodMaq  := ""
Local cTpGrMaq := ""
Local cCdModel := ""
Local cSufxMod := ""
Local cDtlhMaq := ""
Local cVlMaqDl := ""
Local cVlMaqLt := ""
Local cQtdaOri := ""
Local cLngDtlh := ""
Local cTpCdPCI := ""
Local cDtaEftv := ""
Local cFiller  := ""
Local cCGDeal  := ""
Local cFiller2 := ""

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cNrOrder := Subs(cLinha, 13, 2) //Sequence Number
cTpLinha := Subs(cLinha, 15, 1) //Poll Activity Type
cNrLinha := Subs(cLinha, 16, 2) //Poll Record Sequence
cShipAcc := Subs(cLinha, 18, 6) //Ship To Account
cCodMaq  := Subs(cLinha, 24,12) //Order Code
cTpGrMaq := Subs(cLinha, 36, 1) //Order Code Type
cCdModel := Subs(cLinha, 37, 4) //Model Number
cSufxMod := Subs(cLinha, 41, 1) //Model Suffix
cDtlhMaq := Subs(cLinha, 42,12) //Alternate Attachment Code or Detail Machine Code
cVlMaqDl := Subs(cLinha, 54, 9) //Dealer Order Cost
cVlMaqLt := Subs(cLinha, 63, 9) //Dealer Order List
cQtdaOri := Subs(cLinha, 72, 3) //Attachment Quantity
cLngDtlh := Subs(cLinha, 75,29) //Order Code Description
cTpCdPCI := Subs(cLinha,104,10) //PCI Type Code
cDtaEftv := Subs(cLinha,114, 8) //Price Effective date
cFiller  := Subs(cLinha,122, 2) //Filler
cCGDeal  := Subs(cLinha,124, 3) //CG Dealer Code
cFiller2 := Subs(cLinha,127, 7) //Filler

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_SEQNUM",cNrOrder},;
				{"VJQ_ACTVTP",cTpLinha},;
				{"VJQ_RCRDSQ",Val(cNrLinha)},;
				{"VJQ_SHIPAC",cShipAcc},;
				{"VJQ_ORDCOD",cCodMaq },;
				{"VJQ_ORDTP" ,cTpGrMaq},;
				{"VJQ_MODNUM",cCdModel},;
				{"VJQ_MODSUF",cSufxMod},;
				{"VJQ_PCITPE",cDtlhMaq},;
				{"VJQ_ORDCOS",VA1400058_ImplicitTrailingSigns(cVlMaqDl,"VJQ_ORDCOS")},;
				{"VJQ_ORDLIS",VA1400058_ImplicitTrailingSigns(cVlMaqLt,"VJQ_ORDLIS")},;
				{"VJQ_ATTQNT",VA1400058_ImplicitTrailingSigns(cQtdaOri,"VJQ_ATTQNT")},;
				{"VJQ_ORDDES",cLngDtlh},;
				{"VJQ_PCITPE",cTpCdPCI},;
				{"VJQ_EFFDAT",StoD(cDtaEftv)},;
				{"VJQ_CGCODE",cCGDeal};
			})

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400054_HeaderExtensionRecord(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cNrOrder := Subs(cLinha, 13, 2) //Sequence Number
cTpLinha := Subs(cLinha, 15, 1) //Poll Activity Type
cNrLinha := Subs(cLinha, 16, 2) //Poll Record Sequence
cShipAcc := Subs(cLinha, 18, 6) //Ship To Account
cCodMaq  := Subs(cLinha, 24, 1) //Type Order
cTpGrMaq := Subs(cLinha, 25,15) //Customer Order Number
cNumbAcc := Subs(cLinha, 40, 6) //Sold to Account
cModAprt := Subs(cLinha, 46,40) //Decal Model
cChDecal := Subs(cLinha, 86,10) //Decal Unique Identifier
cMakeMaq := Subs(cLinha, 96,25) //Make
cChvMake := Subs(cLinha,121,10) //Make Unique Identifier
cFiller  := Subs(cLinha,131, 3) //Filler

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_SEQNUM",cNrOrder},;
				{"VJQ_ACTVTP",cTpLinha},;
				{"VJQ_RCRDSQ",Val(cNrLinha)},;
				{"VJQ_SHIPAC",cShipAcc},;
				{"VJQ_ORDCOD",cCodMaq},;
				{"VJQ_ORDTP" ,cTpGrMaq},;
				{"VJQ_SOLDAC",cNumbAcc},;
				{"VJQ_DECMOD",cModAprt},;
				{"VJQ_DECUID",Val(cChDecal)},;
				{"VJQ_MAKE"  ,cMakeMaq},;
				{"VJQ_MAKEID",Val(cChvMake)};
			})
Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400055_ExtensionPart1(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cNrOuote := Subs(cLinha, 13,10) //Quote Number
cStOuote := Subs(cLinha, 23,50) //Quoting Status Code
cEventID := Subs(cLinha, 73,20) //Special Event ID
cDataCCG := Subs(cLinha, 93, 7) //CCG Order Warehouse date
cDtFator := Subs(cLinha,100, 7) //Orig Factory Del date
cDataReq := Subs(cLinha,107, 7) //Req Del Date
cDReqShp := Subs(cLinha,114, 8) //ORIG REQ SHIP DATE
cDOrgEnt := Subs(cLinha,122, 8) //ORIGINAL ORDER ENTRY DATE

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_QUOTNR",cNrOuote},;
				{"VJQ_QUOTST",cStOuote},;
				{"VJQ_EVNTID",cEventID},;
				{"VJQ_CCGDAT",VA140005A_LevantaData(cDataCCG)},;
				{"VJQ_FACTDT",VA140005A_LevantaData(cDtFator)},;
				{"VJQ_RQDLDT",VA140005A_LevantaData(cDataReq)},;
				{"VJQ_SHIPDT",StoD(cDReqShp)},;
				{"VJQ_ENTDAT",StoD(cDOrgEnt)};
			})
Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400056_DetailExtensionPart2(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cDescPrt := Subs(cLinha,13,121) //Product

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_PRODUC",cDescPrt};
			})

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400057_DetailExtensionPart3(cLinha,cTpRegtr,cTpMovto,cGpOrder,cOrderNr)

Default cLinha   := ""
Default cTpRegtr := ""
Default cTpMovto := ""
Default cGpOrder := ""
Default cOrderNr := ""

cNomeCCG := Subs(cLinha, 13,28) //CCG_ship_to_name
cDtDeliv := Subs(cLinha, 41, 8) //Delivery Date
cDtRepar := Subs(cLinha, 49, 8) //Retail sold Date
cOrdType := Subs(cLinha, 57,40) //ORD_TYP
cVlTotOr := Subs(cLinha, 98, 9) //Order_Tot_Prc
cVlFrete := Subs(cLinha,107, 9) //Order_FRT
cVlComis := Subs(cLinha,116, 9) //Order_Comsn
cVlTotTx := Subs(cLinha,125, 9) //Order_tot_tax

aAdd(aVetGrv,{;
				{"VJQ_NTWCOD",cTpRegtr},;
				{"VJQ_RCRDTP",cTpMovto},;
				{"VJQ_ORDGRP",cGpOrder},;
				{"VJQ_ORDNUM",Val(cOrderNr)},;
				{"VJQ_CCGNAM",cNomeCCG},;
				{"VJQ_DLVDAT",VA140005A_LevantaData(cDtDeliv)},;
				{"VJQ_RTLDAT",sTod(cDtRepar)},;
				{"VJQ_ORDTYP",cOrdType},;
				{"VJQ_ORDTOT",VA1400058_ImplicitTrailingSigns(cVlTotOr,"VJQ_ORDTOT")},;
				{"VJQ_ORDFRT",VA1400058_ImplicitTrailingSigns(cVlFrete,"VJQ_ORDFRT")},;
				{"VJQ_ORDCOM",VA1400058_ImplicitTrailingSigns(cVlComis,"VJQ_ORDCOM")},;
				{"VJQ_ORDTAX",VA1400058_ImplicitTrailingSigns(cVlTotTx,"VJQ_ORDTAX")};
	})

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400058_ImplicitTrailingSigns(cValor,cCpo)

Local cVlrRet := cValor

nPosRegra := aScan(aRegrVl,{|x| x[1] == Right(cValor,1)})
If nPosRegra > 0
	cVlrRet := Val(StrTran(cValor,Right(cValor,1),aRegrVl[nPosRegra,2]))
	If GeTSX3Cache(cCpo,"X3_DECIMAL") > 0
		cVlrRet := cVlrRet/100
	EndIf
EndIf

Return cVlrRet

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1400059_LimpaVetor(aArray)
	aArray := aSize(aArray,0)
Return

Static Function VA140005A_LevantaData(uAuxValor)

If !Empty(uAuxValor)
	cMes := UPPER(SubStr(uAuxValor,3,3))
	Do Case
		Case cMes == "JAN" ; cMes := "01"
		Case cMes == "FEB" ; cMes := "02"
		Case cMes == "MAR" ; cMes := "03"
		Case cMes == "APR" ; cMes := "04"
		Case cMes == "MAY" ; cMes := "05"
		Case cMes == "JUN" ; cMes := "06"
		Case cMes == "JUL" ; cMes := "07"
		Case cMes == "AUG" ; cMes := "08"
		Case cMes == "SEP" ; cMes := "09"
		Case cMes == "OCT" ; cMes := "10"
		Case cMes == "NOV" ; cMes := "11"
		Otherwise ; cMes := "12"
	End Case
	uAuxValor := CtoD(SubStr(uAuxValor,1,2) + "/" + cMes + "/" + SubStr(uAuxValor,6,2))
EndIf

Return uAuxValor

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA140005B_GravacaoVQ0(cNumPed,cComCod,cImport)

Local aRetorno := {,,}
Default cNumPed := ""
Default cComCod := ""

If oModelVQ0 == NIL
	oModelVQ0 := FWLoadModel( 'VEIA142' )
EndIf

cQuery := "SELECT VQ0.R_E_C_N_O_ VQ0RECNO, VJR.R_E_C_N_O_ VJRRECNO "
cQuery += "FROM " + RetSqlName("VQ0") + " VQ0 "
cQuery += "JOIN " + RetSqlName("VJR") + " VJR "
cQuery +=   " ON VJR.VJR_FILIAL = VQ0.VQ0_FILIAL "
cQuery +=  " AND VJR.VJR_CODVQ0 = VQ0.VQ0_CODIGO "
cQuery +=  " AND VJR.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VQ0.VQ0_FILIAL = '" + xFilial("VQ0") + "' "
cQuery +=  " AND ((VQ0.VQ0_NUMPED = '" + cNumPed + "' AND VQ0.VQ0_CODVJQ = ' ') " 
cQuery +=  " OR VJR.VJR_ORDNUM = '" + cComCod + "') "
cQuery +=  " AND VQ0.D_E_L_E_T_ = ' ' "

TcQuery cQuery New Alias "TMPPED"

If !Empty(TMPPED->VQ0RECNO)
	
	DbSelectArea("VQ0")
	DbGoTo(TMPPED->VQ0RECNO)
	
	oModelVQ0:SetOperation( MODEL_OPERATION_UPDATE )

	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoDeleteLine( .F. )
	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoUpdateLine( .F. )
	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoInsertLine( .F. )
	
	DbSelectArea("VJR")
	DbGoTo(TMPPED->VJRRECNO)

	aRetorno[1] := VQ0->VQ0_CODIGO
	aRetorno[2] := "1"
	aRetorno[3] := VQ0->VQ0_CHAINT
Else
	
	oModelVQ0:SetOperation( MODEL_OPERATION_INSERT )

	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoDeleteLine( .F. )
	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoUpdateLine( .F. )
	oModelVQ0:GetModel( 'VJNMASTER' ):SetNoInsertLine( .F. )

	aRetorno[1] := ""
	aRetorno[2] := "0"
	aRetorno[3] := ""
EndIf

TMPPED->(DbCloseArea())

Return aRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA14000C5_StatusPedido(cStatPed)

Local cRetorno := "0"

nPosSt := aScan(aVStat,{|x| x[1] == cStatPed})
If nPosSt > 0
	cRetorno := aVStat[nPosSt,2]
EndIf

Return cRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005D_ComboStatusFabrica()

Local cRetorno := ""

cRetorno := STR0006 //"1=Cancelado;"
cRetorno += STR0007 //"2=Confirmado;"
cRetorno += STR0008 //"3=Pedido com erro;"
cRetorno += STR0009 //"4=Congelado;"
cRetorno += STR0010 //"5=Faturado;"
cRetorno += STR0011 //"6=Parcialmente faturado;"
cRetorno += STR0012 //"7=Liberado;"
cRetorno += STR0013 //"8=Enviado;"
cRetorno += STR0014 //"9=Programada data de envio;"
cRetorno += STR0015 //"A=Não confirmado;"
cRetorno += STR0016 //"B=Sem valor;"
cRetorno += STR0017 //"C=Transferido;"

Return cRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005E_MontaChassi(cProdId)

Local cRetorno := ""
Default cProdId := ""

If oModelVJQ == NIL
	oModelVJQ := FWLoadModel( 'VEIA141' )
EndIf

If !Empty(cProdId)

	If Empty(oModelVJQ:GetValue( "VJQMASTER", "VJQ_WMC")) .and.;
		Empty(oModelVJQ:GetValue( "VJQMASTER", "VJQ_CHKLET"))
		cRetorno := Alltrim(cProdId)
	Else
		//Exemplo: 1BM6150JTJD001017
		cRetorno := oModelVJQ:GetValue( "VJQMASTER", "VJQ_WMC") //1BM
		cRetorno += Subs(cProdId,3,5) //6150J
		cRetorno += oModelVJQ:GetValue( "VJQMASTER", "VJQ_CHKLET") //TJD
		cRetorno += Subs(cProdId,8,6) //001017
	Endif

EndIf

Return cRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005F_MontaModelo(cModNum)

Local cRetorno := Space(GeTSX3Cache("VQ0_MODVEI","X3_TAMANHO"))
Local cBaseCd  := Space(GeTSX3Cache("VJQ_ORDCOD","X3_TAMANHO"))
Default cModNum := ""

If oModelVJQ == NIL
	oModelVJQ := FWLoadModel( 'VEIA141' )
EndIf

If !Empty(cModNum)

	//Exemplo: 6190J
	cModFab := cModNum //6190
	cModFab += oModelVJQ:GetValue( "VJQMASTER", "VJQ_MODSUF") //J
	cBaseCd := left(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDCOD"),6) //J

	cRetorno := VA140005K_BuscaModelo( cCodMar, cModFab, cBaseCd , "1" ) // Retorna o Modelo

EndIf

Return cRetorno

/*/
{Protheus.doc} VA140005G_GravaMaquina

@author Renato Vinicius
@since 15/04/2019
@version 1.0

@param cChaInt, characters   , 01
@param cModVei, characters   , 02
@param cChassi, characters   , 03
@param cFilEnt, characters   , 04
@param oModelVei, characters , 05
@param cCor, characters      , 06
@param cSegMod, characters   , 07
@param cCodMar, characters   , 08
@param cCodImp, characters   , 09
@param cComarCod, characters , 10
@param cNroPed , characters  , 11
@param cStatusPed, characters, 12
@param dPedido, date         , 13
@return ${return}, ${return_description}
@type function
/*/
Function VA140005G_GravaMaquina(cChaInt, cModVei, cChassi, cFilEnt, oModelVei, cCor, cSegMod, cCodMar, cLocPad, lVEIImp, cCodImp, cComarCod, cNroPed , cStatusPed, dPedido, cTpVend )

	Local lRet := .t.
	Local lNTemChaInt := .f.
	local lIntegrar := .f.
	Local cGrpOrd   := ""
	Local cOrdNum   := ""
	Local cCategory := ""
	Local lVV1CGCODE := VV1->(FieldPos("VV1_CGCODE")) > 0

	local aFldUpdate := {}
	local dDelivery  := CtoD("  /  /  ")
	local cSerCab    := ""
	local cSerTran   := ""
	local cNrSerie   := ""
	local cAlias

	Default cChaInt   := ""
	Default cModVei   := ""
	Default cChassi   := ""
	Default cFilEnt   := cFilAnt
	Default cCor      := ""
	Default cSegMod   := ""
	Default cCodMar   := ""
	Default cLocPad   := ""
	Default lVEIImp   := .f.
	Default cCodImp   := ""
	Default cComarCod := ""
	Default cNroPed   := ""
	Default cStatusPed := ""
	Default dPedido    := CtoD("  /  /  ")
	Default cTpVend    := ""

	If Empty(cModVei)
		Return cChaInt
	EndIf

	if lMVMIL0185 == NIL
		lMVMIL0185 := GetNewPar("MV_MIL0185",.F.)
	endif

	if oFilHelper == NIL
		oFilHelper := DMS_FilialHelper():New()
	endif

	lNTemChaInt := Empty(cChaInt)

	If lNTemChaInt
		oModelVei:SetOperation( MODEL_OPERATION_INSERT )
	Else
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+cChaInt))

		// se o pedido foi cancelado, excluimos o chassi do Blackbird1
		if cStatusPed == "3"

			if VV1->(FieldPos("VV1_BBINTG")) <> 0 .and. VV1->VV1_BBINTG <> "1"
				return cChaint
			endif

			Conout(" Excluindo registro no BLACKBIRD -> VA0700053_ExcluirBlackbird " + VV1->VV1_CHASSI)

			AADD( aFldUpdate , { "VV1_CHASSI" , VV1->VV1_CHASSI }) // Esta linha é so para "enganar" o fonte e gerar uma linha de LOG
			AADD( aFldUpdate , { "VV1_ROTINA" , "VA140005G_GravaMaquina - Pedido Cancelado" })
			AADD( aFldUpdate , { "VV1_BBDEL"  , "1" })

			oModelVei:SetOperation( MODEL_OPERATION_UPDATE )
			if ! oModelVei:Activate()
				return cChaInt
			endif

			if VA0700093_AtualizaVV1(@oModelVei, aFldUpdate)
				FMX_COMMITDATA(@oModelVei)
			endif

			oModelVei:DeActivate()
			//VA0700053_ExcluirBlackbird("VV1",VV1->(Recno()),4,.f.)

			//VA0700173_LogVW0("VA140005G_GravaMaquina - Pedido Cancelado")

			return cChaint

		endif

		oModelVei:SetOperation( MODEL_OPERATION_UPDATE )
	EndIf

	If lVV1CGCODE .and. !Empty(cCodImp)

		cGrpOrd := Left( Alltrim(cComarCod),GetSX3Cache("VJQ_ORDGRP","X3_TAMANHO"))
		cOrdNum := Right(Alltrim(cComarCod),GetSX3Cache("VJQ_ORDNUM","X3_TAMANHO"))

		cQuery := "SELECT VJQ.VJQ_CGCODE "
		cQuery += " FROM " + RetSQLName("VJQ") + " VJQ "
		cQuery += " WHERE VJQ.VJQ_FILIAL = '" + xFilial("VJQ") + "' "
		cQuery += 	" AND VJQ.VJQ_CODIGO = '" + cCodImp + "' "
		cQuery += 	" AND VJQ.VJQ_ORDGRP = '" + cGrpOrd + "' "
		cQuery += 	" AND VJQ.VJQ_ORDNUM = '" + cOrdNum + "' "
		cQuery += 	" AND VJQ.VJQ_RCRDTP = '2' "
		cQuery += 	" AND VJQ.VJQ_ORDTP  = 'B' "
		cQuery += 	" AND VJQ.D_E_L_E_T_ = ' ' "

		cCategory := FM_SQL(cQuery)

	EndIf

	lRet := oModelVei:Activate()

	If lRet
		
		VV2->( DbSetOrder(1) )
		VVC->( DbSetOrder(1) )
		VV2->( DbSeek( xFilial("VV2") + cCodMar + cModVei + cSegMod ) )
		VVC->( DbSeek( xFilial("VVC") + VV2->VV2_CODMAR + cCor ) )

		If ! empty(cCodImp)

			cGrpOrd := Left( Alltrim(cComarCod),GetSX3Cache("VJQ_ORDGRP","X3_TAMANHO"))
			cOrdNum := Right(Alltrim(cComarCod),GetSX3Cache("VJQ_ORDNUM","X3_TAMANHO"))

			cQuery := "SELECT DISTINCT VJQ_DATFDD, VJQ_CABSER, VJQ_TRMSER, VJQ_ENGSER "
			cQuery += " from " + RetSQLName("VJQ") + " VJQ "
			cQuery += " where VJQ_FILIAL = '" + xFilial("VJQ") + "' "
			cQuery += 	" and VJQ_CODIGO = '" + cCodImp + "' "
			cQuery += 	" and VJQ_ORDGRP = '" + cGrpOrd + "' "
			cQuery += 	" and VJQ_ORDNUM = '" + cOrdNum + "' "
			cQuery += 	" and VJQ.D_E_L_E_T_ = ' ' "
			cAlias := MPSysOpenQuery(cQuery)

			while ! (cAlias)->( eof() ) .and. empty(dDelivery) .and. empty(cSerCab)
				if ! empty( (cAlias)->VJQ_DATFDD )
					dDelivery := StoD( (cAlias)->VJQ_DATFDD )
				endif
				if ! empty( (cAlias)->VJQ_CABSER )
					cSerCab := alltrim( (cAlias)->VJQ_CABSER )
				endif
				if ! empty( (cAlias)->VJQ_TRMSER )
					cSerTran := alltrim( (cAlias)->VJQ_TRMSER )
				endif
				if ! empty( (cAlias)->VJQ_ENGSER )
					cNrSerie := alltrim( (cAlias)->VJQ_ENGSER )
				endif
				(cAlias)->( dbSkip() )
			endDo
			(cAlias)->( dbCloseArea() )
		EndIf

		// Inclusao de Veiculo
		if lNTemChaInt

			if ! empty(cChassi)
				oModelVei:SetValue( "MODEL_VV1", "VV1_CHASSI", cChassi )
			endif
			oModelVei:SetValue( "MODEL_VV1", "VV1_CODMAR", VV2->VV2_CODMAR )
			oModelVei:SetValue( "MODEL_VV1", "VV1_MODVEI", cModVei )
			if ! empty(cSegMod)
				oModelVei:SetValue( "MODEL_VV1", "VV1_SEGMOD", cSegMod )
			endif
			oModelVei:SetValue( "MODEL_VV1", "VV1_FABMOD", Year2Str(dDataBase) + Year2Str(dDataBase) )

			if ! VVC->(Eof()) 
				oModelVei:SetValue( "MODEL_VV1", "VV1_CORVEI", VVC->VVC_CORVEI )
			endif

			If !Empty(cCategory)
				oModelVei:SetValue( "MODEL_VV1", "VV1_CGCODE", cCategory )
			EndIf

			//cAuxFilEnt := IIF( ! empty( cFilEnt ) , cFilEnt , cFilAnt )
			if ! empty(cFilEnt)
				oModelVei:SetValue( "MODEL_VV1", "VV1_FILENT", cFilEnt )

				If !Empty(cLocPad)
					oModelVei:SetValue( "MODEL_VV1", "VV1_LOCPAD", cLocPad )
				EndIf

				aSA1Filial := oFilHelper:GetCodCli(cFilEnt)
				if ! empty(aSA1Filial[1])
					oModelVei:SetValue( "MODEL_VV1", "VV1_PROATU", aSA1Filial[1] )
					oModelVei:SetValue( "MODEL_VV1", "VV1_LJPATU", aSA1Filial[2] )
				endif
				
			endif

			oModelVei:SetValue( "MODEL_VV1", "VV1_SITVEI", "8" )
			oModelVei:SetValue( "MODEL_VV1", "VV1_ESTVEI", "0" )

			if lMVMIL0185
			// Qualquer alteracao neste ponto requer verifica  o na FGX_ATUBBPEDIDO
				if cTpVend == "0"
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBEQTY" , "1" ) // CustomerEquip
				Else
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBEQTY" , "2" ) // StockUnit
				Endif
				oModelVei:SetValue( "MODEL_VV1" , "VV1_BBSTTY" , "1" ) // Novo
				oModelVei:SetValue( "MODEL_VV1" , "VV1_BBINST" , "2" ) // Stock 
				oModelVei:SetValue( "MODEL_VV1" , "VV1_BBSTST" , "1" ) // Pending
				oModelVei:SetValue( "MODEL_VV1" , "VV1_BBYARD" , "0" ) // Nao
				oModelVei:SetValue( "MODEL_VV1" , "VV1_LOCRID" , cFilEnt ) // Location Ref
				//
			endif

			oModelVei:SetValue( "MODEL_VV1", "VV1_PEDFAB", cNroPed )
			if ! empty( dPedido )
				oModelVei:SetValue( "MODEL_VV1", "VV1_DATPED", dPedido )
			endif

			if ! empty( dDelivery )
				oModelVei:SetValue( "MODEL_VV1", "VV1_DTEFAB", dDelivery )
			endif

			oModelVei:SetValue( "MODEL_VV1", "VV1_NUMCMO", cSerCab )
			oModelVei:SetValue( "MODEL_VV1", "VV1_CAMBIO", cSerTran )
			oModelVei:SetValue( "MODEL_VV1", "VV1_SERMOT", cNrSerie )

			lIntegrar := .t.

		else

			if ! VV1->VV1_CHASSI == cChassi
				oModelVei:SetValue( "MODEL_VV1", "VV1_CHASSI", cChassi )
				lIntegrar := .t.
			endif

			if ! VV1->VV1_CODMAR == VV2->VV2_CODMAR
				oModelVei:SetValue( "MODEL_VV1", "VV1_CODMAR", VV2->VV2_CODMAR )
				lIntegrar := .t.
			endif

			if ! VV1->VV1_MODVEI == cModVei
				oModelVei:SetValue( "MODEL_VV1", "VV1_MODVEI", cModVei )
				lIntegrar := .t.
			endif

			if ! VV1->VV1_SEGMOD == cSegMod
				oModelVei:SetValue( "MODEL_VV1", "VV1_SEGMOD", cSegMod )
				lIntegrar := .t.
			endif

			if empty(VV1->VV1_FABMOD) 
				oModelVei:SetValue( "MODEL_VV1", "VV1_FABMOD", Year2Str(dDataBase) + Year2Str(dDataBase) )
				lIntegrar := .t.
			endif

			if ! VV1->VV1_CORVEI == VVC->VVC_CORVEI
				oModelVei:SetValue( "MODEL_VV1", "VV1_CORVEI", VVC->VVC_CORVEI )
				lIntegrar := .t.
			endif

			if ! VV1->VV1_FILENT == cFilEnt
				oModelVei:SetValue( "MODEL_VV1", "VV1_FILENT", cFilEnt )
				lIntegrar := .t.

				if ! empty(cFilEnt)

					aSA1Filial := oFilHelper:GetCodCli(cFilEnt)

					if ! empty(aSA1Filial[1])
						oModelVei:SetValue( "MODEL_VV1", "VV1_PROATU", aSA1Filial[1] )
						oModelVei:SetValue( "MODEL_VV1", "VV1_LJPATU", aSA1Filial[2] )
					endif

				endif
				
			endif

			if ! VV1->VV1_PEDFAB == cNroPed
				oModelVei:SetValue( "MODEL_VV1", "VV1_PEDFAB", cNroPed )
				lIntegrar := .t.
			endif

			if lMVMIL0185
				// Qualquer alteracao neste ponto requer verifica  o na FGX_ATUBBPEDIDO
				if cTpVend == "0"
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBEQTY" , "1" ) // CustomerEquip
					lIntegrar := .t.
				Else
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBEQTY" , "2" ) // StockUnit
					lIntegrar := .t.
				Endif
				if VV1->VV1_BBSTTY <> "1" // Novo
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBSTTY" , "1" ) // Novo
					lIntegrar := .t.
				endif
				if VV1->VV1_BBINST <> "2" // Stock 
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBINST" , "2" ) // Stock 
					lIntegrar := .t.
				endif
				if VV1->VV1_BBSTST <> "1" // Pending
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBSTST" , "1" ) // Pending
					lIntegrar := .t.
				endif
				if VV1->VV1_BBYARD <> "0" // Nao
					oModelVei:SetValue( "MODEL_VV1" , "VV1_BBYARD" , "0" ) // Nao
					lIntegrar := .t.
				endif
				if ! alltrim(VV1->VV1_LOCRID) == alltrim(cFilEnt)
					oModelVei:SetValue( "MODEL_VV1" , "VV1_LOCRID" , cFilEnt ) // Location Ref
					lIntegrar := .t.
				endif
				//
			endif

			if ! empty(dPedido) .and. ! VV1->VV1_DATPED == dPedido
				oModelVei:SetValue( "MODEL_VV1", "VV1_DATPED", dPedido )
				lIntegrar := .t.
			endif

			if ! empty( dDelivery ) .and. ! VV1->VV1_DTEFAB == dDelivery
				oModelVei:SetValue( "MODEL_VV1", "VV1_DTEFAB", dDelivery )
				lIntegrar := .t.
			endif

			if ! empty( cSerCab ) .and. ! VV1->VV1_NUMCMO == padR( cSerCab, len(VV1->VV1_NUMCMO) )
				oModelVei:SetValue( "MODEL_VV1", "VV1_NUMCMO", cSerCab )
				lIntegrar := .t.
			endif

			if ! empty( cSerTran ) .and. ! VV1->VV1_CAMBIO == padR( cSerTran, len(VV1->VV1_CAMBIO) )
				oModelVei:SetValue( "MODEL_VV1", "VV1_CAMBIO", cSerTran )
				lIntegrar := .t.
			endif

			if ! empty( cSerTran ) .and. ! VV1->VV1_SERMOT == padR( cNrSerie, len(VV1->VV1_SERMOT) )
				oModelVei:SetValue( "MODEL_VV1", "VV1_SERMOT", cNrSerie )
				lIntegrar := .t.
			endif

			if ! empty( cSerTran ) .and. ! VV1->VV1_CAMBIO == padR( cSerTran, len(VV1->VV1_CAMBIO) )
				oModelVei:SetValue( "MODEL_VV1", "VV1_CAMBIO", cSerTran )
				lIntegrar := .t.
			endif

		endif

		if lIntegrar
		If lVEIImp
			oModelVei:SetValue( "MODEL_VV1", "VV1_INDCAL", "2" )
		EndIf

			If ( lRet := oModelVei:VldData() )

				if ( lRet := oModelVei:CommitData())
					If !Empty(oModelVei:GetValue("MODEL_VV1","VV1_CHASSI"))
						VM190ALTVVA(oModelVei:GetValue("MODEL_VV1","VV1_CHAINT"),oModelVei:GetValue("MODEL_VV1","VV1_CHASSI")) // ALTERA TODOS VVA_CHASSI DO VEICULO
					EndIf	


				EndIf
			Else

aErro := oModelVei:GetErrorMessage()
conout("-------------")
conout("VA140VALIDVV1")
conout("-------------")
	conout( "Id do formulário de origem:" + ' [' + AllToChar(aErro[1]) + ']') // "Id do formulário de origem:"
	conout( "Id do campo de origem: "     + ' [' + AllToChar(aErro[2]) + ']') // "Id do campo de origem: "    
	conout( "Id do formulário de erro: "  + ' [' + AllToChar(aErro[3]) + ']') // "Id do formulário de erro: " 
	conout( "Id do campo de erro: "       + ' [' + AllToChar(aErro[4]) + ']') // "Id do campo de erro: "      
	conout( "Id do erro: "                + ' [' + AllToChar(aErro[5]) + ']') // "Id do erro: "               
	conout( "Mensagem do erro: "          + ' [' + AllToChar(aErro[6]) + ']') // "Mensagem do erro: "         
	conout( "Mensagem da soluçao: "       + ' [' + AllToChar(aErro[7]) + ']') // "Mensagem da soluçao: "      
conout(" ")
				
				Help("",1,"VA140VALIDVV1",,STR0019,1,0) //"Problema na validação dos campos e não foi possivel concluir o relacionamento"

			EndIf
		endif
		
		cChaInt := oModelVei:GetValue("MODEL_VV1","VV1_CHAINT")

		oModelVei:DeActivate()
	Else
		Help("",1,"ACTIVEVV1",,STR0020,1,0) //"Não foi possivel ativar o modelo de inclusão da tabela"
	EndIf

Return cChaInt

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA14000H5_NumeroPedido(cNumPed)

Local cRetorno := Space(GeTSX3Cache("VJR_ORDNUM","X3_TAMANHO"))
Default cNumPed := cRetorno

If oModelVJQ == NIL
	oModelVJQ := FWLoadModel( 'VEIA141' )
EndIf

if !Empty(cNumPed)

	//Exemplo: 20617311
	cRetorno := cValtoChar(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDGRP")) //20
	cRetorno += StrZero(cNumPed, TamSX3("VJQ_ORDNUM")[1], TamSX3("VJQ_ORDNUM")[2]) //617311

EndIf

Return cRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA14000I5_ReferenciaFilial(cCodFil)

	Local cRetorno := ""

	Default cCodFil := ""

	if !Empty(cCodFil)
		cRetorno := oFilJD:GetFilial(cCodFil)
	EndIf

Return IIF( Empty(cRetorno) , Space(GeTSX3Cache("VQ0_FILIAL","X3_TAMANHO")) , cRetorno )

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA14000J5_Filial(cCodFil)

	Local cRetorno := Space(GeTSX3Cache("VQ0_FILIAL","X3_TAMANHO"))
	Local nPosFil  := 0

	Default cCodFil := cRetorno

	nPosFil := aScan(aMapFilDealerCode, { |x| x[2] == cCodFil })
	If nPosFil <> 0
		cRetorno := aMapFilDealerCode[nPosFil,1]
	EndIf

Return cRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005K_BuscaModelo( cCodMar, cModFab, cBaseCd , cTp )

	Local cRet    := ""
	Local aModVei := Array(5)

	Default cCodMar := ""
	Default cModFab := ""
	Default cBaseCd := ""
	Default cTp     := "1" // 1 - Retorna o Modelo / 2 - Retorna o Codigo da Tabela VJU / 3 - Retorna o SEGMENTO

	VJU->(DbSetOrder(3))
	If !(VJU->(DbSeek(xFilial("VJU")+cModFab+cBaseCd)))

		aModVei[1] := Space(GetSX3Cache("VJU_CODMAR","X3_TAMANHO"))
		aModVei[2] := Space(GetSX3Cache("VJU_GRUMOD","X3_TAMANHO"))
		aModVei[3] := Space(GetSX3Cache("VJU_MODVEI","X3_TAMANHO"))
		aModVei[4] := Space(GetSX3Cache("VJU_SEGMOD","X3_TAMANHO"))
		aModVei[5] := .t.

		If VJU->(DbSeek(xFilial("VJU")+cModFab))
			aModVei[1] := VJU->VJU_CODMAR
			aModVei[2] := VJU->VJU_GRUMOD
			aModVei[3] := VJU->VJU_MODVEI
			aModVei[4] := VJU->VJU_SEGMOD
			aModVei[5] := .t.
		Else
			VJU->(DbSetOrder(2))
			If VJU->(DbSeek(xFilial("VJU")+cBaseCd))
				aModVei[1] := VJU->VJU_CODMAR
				aModVei[2] := VJU->VJU_GRUMOD
				aModVei[3] := VJU->VJU_MODVEI
				aModVei[4] := VJU->VJU_SEGMOD
				aModVei[5] := .f.
			EndIf
		EndIf

		VA140005L_GravaModeloFabrica(cModFab , cBaseCd, aModVei)
		VJU->(DbSetOrder(3))
		VJU->(DbSeek(xFilial("VJU")+cModFab+cBaseCd))

	EndIf

	If cTp == "1" // Retorna o Modelo
		cRet := Alltrim(VJU->VJU_MODVEI)
	ElseIf cTp == "2" // Retorna o Codigo da Tabela VJU
		cRet := VJU->VJU_CODIGO
	Elseif cTp == "3" // Retorna o Segmento 
		cRet := VJU->VJU_SEGMOD
	EndIf

Return cRet

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005L_GravaModeloFabrica(cModFab , cBaseCd, aModVei)

	

	Default cModFab := ""
	Default cBaseCd := ""
	Default aModVei := {}

	if oModelVJU == NIL
		oModelVJU := FWLoadModel( 'VEIA145' )
	endif

	If len(aModVei) > 0 .and. aModVei[5]
		oModelVJU:SetOperation( MODEL_OPERATION_INSERT )
	Else
		oModelVJU:SetOperation( MODEL_OPERATION_UPDATE )
	EndIf

	lRet := oModelVJU:Activate()

	If lRet

		oModelVJU:SetValue( "VJUMASTER", "VJU_MODEID", cModFab )
		oModelVJU:SetValue( "VJUMASTER", "VJU_BASECD", cBaseCd )

		If len(aModVei) > 0 .and. !Empty(aModVei[3])
			oModelVJU:SetValue( "VJUMASTER", "VJU_CODMAR", aModVei[1] )
			oModelVJU:SetValue( "VJUMASTER", "VJU_GRUMOD", aModVei[2] )
			oModelVJU:SetValue( "VJUMASTER", "VJU_MODVEI", aModVei[3] )
			oModelVJU:SetValue( "VJUMASTER", "VJU_SEGMOD", aModVei[4] )
		EndIf
	
		If ( lRet := oModelVJU:VldData() )
			if ( lRet := oModelVJU:CommitData())
				VA14000SC_SetBBSync( cBaseCD )	// flag p/ integrar VV1 - Blackbird


			EndIf

		Else
			Help("",1,"VALIDVJU",,STR0019,1,0)
		EndIf

		oModelVJU:DeActivate()
	Else
		Help("",1,"ACTIVEVJU",,STR0020,1,0)
	EndIf

	FreeObj(oModelVJU)

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005M_ImportaModelo(cBaseCode)

	Local lRetorno := .f.
	Local cQuery   := ""

	cQuery := "SELECT VJU.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("VJU") + " VJU "
	cQuery += " WHERE VJU.VJU_FILIAL = '" + xFilial("VJU") + "' "
	cQuery += 	" AND VJU.VJU_BASECD = '" + cBaseCode + "' "
	cQuery += 	" AND VJU.VJU_CONIMP <> '0' "
	cQuery += 	" AND VJU.D_E_L_E_T_ = ' '"

	lRetorno := FM_SQL(cQuery) > 0

Return lRetorno

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005N_GravacaoPedidoVQ0(aPedidos, cCor)

	Local nI, nJ
	Local cBkpFil   := ""
	Local cChaInt  := "" // VV1_CHAINT
	//Local oModel
	Default aPedidos:= {}

	If oModelVQ0 == NIL
		oModelVQ0 := FWLoadModel( 'VEIA142' )
	EndIf
	If oModelVV1 == NIL
		oModelVV1 := FWLoadModel( 'VEIA070' )
	EndIf

	For ni := 1 to Len(aPedidos)

		If aPedidos[ni,3]

			cBkpFil := cFilAnt

			nPosFil := aScan(aPedidos[ni,4],{ |x| x[2] == "VQ0_FILPED"})
			If nPosFil > 0
				If !Empty(aPedidos[ni,4,nPosFil,3])
					cFilAnt := aPedidos[ni,4,nPosFil,3]
				EndIf
			EndIf

			nPosBc:= aScan(aPedidos[ni,4],{ |x| x[2] == "VJR_ORDCOD"})
			If nPosBc > 0
				cBaseCode := aPedidos[ni,4,nPosBc,3]
			EndIf

			lImpPed := .t.
			If !Empty(cBaseCode)
				lImpPed := VA140005M_ImportaModelo(cBaseCode)
			EndIf
			
			If lImpPed

				cChaInt := ""
				cComCod := aPedidos[ni,1]
				cCodImp := aPedidos[ni,2]

				nPosNrPd:= aScan(aPedidos[ni,4],{ |x| x[2] == "VQ0_NUMPED"})
				cNroPed := iif( nPosNrPd > 0, aPedidos[ni,4,nPosNrPd,3], "" )

				aVetReg := VA140005B_GravacaoVQ0(cNroPed,cComCod,cCodImp)

				If oModelVQ0:Activate()

					nPosSta := aScan(aPedidos[ni,4],{ |x| x[2] == "VJR_STAIMP"})
					If nPosSta > 0
						aPedidos[ni,4,nPosSta,3] := aVetReg[2]
					EndIf

					For nJ := 1 to Len(aPedidos[ni,4])
						oModelVQ0:SetValue( aPedidos[ni,4,nJ,1], aPedidos[ni,4,nJ,2], aPedidos[ni,4,nJ,3] )

						If aPedidos[ni,4,nJ,2] == "VJR_ORDCOD" .and.;
							Len(aPedidos[ni,4,nJ,4]) > 0

							VA14000R5_RelacionaOpcionalPedido( oModelVQ0, aPedidos[ni,4,nJ,4])

						EndIf

					Next

					cChaInt := VA140005G_GravaMaquina(aVetReg[3],;                              // 01 - cChaInt
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_MODVEI"),; // 02 - cModVei
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_CHASSI"),; // 03 - cChassi
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_FILENT"),; // 04 - cFilEnt
											oModelVV1,;                                      // 05 - oModelVei
											cCor,;                                           // 06 - cCor
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_SEGMOD"),; // 07 - cSegMod
											cCodMar,;                                        // 08 - cCodMar
											,;                                               // 09 - cLocPad
											,;                                               // 10 - lVEIImp
											cCodImp,;                                        // 11 - cCodImp
											oModelVQ0:GetValue( "VJRMASTER", "VJR_ORDNUM"),; // 12 - cComarCod
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_NUMPED"),; // 13 - cNroPed 
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_STATUS"),; // 14 - cStatusPed
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_DATPED"),; // 15 - dPedido
											oModelVQ0:GetValue( "VQ0MASTER", "VQ0_FATDIR");  // 16 - cTpVend
											 ) 

					If !Empty(cChaInt)
						oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CHAINT", cChaInt )
						
						If MV_PAR04 == 1 // Gravar Configuração ( VQC e VQD )
							cCodPac := VA1400105_GravaPacoteConfiguracao( oModelVQ0 , cChaInt , cBaseCode )
							VA1400115_GravaConfiguracaoNoVeiculo( oModelVQ0 , cChaInt , cCodPac )
						Endif
					EndIf
					VVC->( DbSetOrder(1) )
					VVC->( DbSeek( xFilial("VVC") + cCodMar + cCor ) )
					oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CORVEI", cCor )
					oModelVQ0:SetValue( "VQ0MASTER", "VQ0_DESCOR", alltrim(VVC->VVC_DESCRI) )

					If ( lRetVQ0 := oModelVQ0:VldData() )
						ConfirmSX8()
						if ( lRetVQ0 := oModelVQ0:CommitData())
							if oModelVQ0:GetValue( "VQ0MASTER", "VQ0_FATDIR" ) == "0" .and. lMVMIL0185
								VA140013C_FatDireto( oModelVQ0 )
							endif
							VA14001213_BBSyncRestVV1(oModelVQ0, cChaInt)


						EndIf
					Else
						Help("",1,"VALIDVQ0",,oModelVQ0:GetErrorMessage()[6] + STR0021 + oModelVQ0:GetErrorMessage()[2],1,0) //" Campo: "
					EndIf

					oModelVQ0:DeActivate()
				
				Else
					Help("",1,"ACTIVEVQ0",,STR0020,1,0)
				EndIf

			EndIf

			cFilAnt := cBkpFil

		EndIf

	Next

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA140005O_GravacaoImportacao(aPedPro)

	Local nG, nJ, nZ
	Local cUltPed   := ""
	Local cNroPed   := ""
	Local cConteudo := ""
	Local cTpCpoVQ0 := ""
	Local cTpCpoVJQ := ""
	Local cCodVJV   := ""
	Local cOpcional := ""
	Local aRetAux   := ""
	Local cIndice   := ""
	Local cNrModelo := ""

	If oModelVJQ == NIL
		oModelVJQ := FWLoadModel( 'VEIA141' )
	EndIf

	cCodImp := GetSXENum("VJQ","VJQ_CODIGO",,1)

	oModelVJQ:DeActivate()
	oModelVJQ:SetOperation( MODEL_OPERATION_INSERT )
	
	cUltPed := ""
	nPosPed := 0

	For nG := 1 to Len(aVetGrv)

		lRetVQJ := oModelVJQ:Activate()

		if lRetVQJ

			oModelVJQ:SetValue( "VJQMASTER", "VJQ_CODIGO", cCodImp )
			oModelVJQ:SetValue( "VJQMASTER", "VJQ_SEQUEN", StrZero(nG,TamSX3("VJQ_SEQUEN")[1]) )
			oModelVJQ:SetValue( "VJQMASTER", "VJQ_DATIMP", dDataBase )

			For nJ := 1 to Len(aVetGrv[nG])

				If !Empty(aVetGrv[nG,nJ,2])
					oModelVJQ:SetValue( "VJQMASTER", aVetGrv[nG,nJ,1], aVetGrv[nG,nJ,2] )
				EndIf

			Next

			cNroPed := oModelVJQ:GetValue( "VJQMASTER", "VJQ_QUOTNR")
			cComCod := oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDGRP")
			cComCod += StrZero(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDNUM"), TamSX3("VJQ_ORDNUM")[1], TamSX3("VJQ_ORDNUM")[2])

			dDtaPed := oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDDAT")

			If cUltPed <> cComCod

				cUltPed := cComCod
                cIndice := cComCod+cValToChar(nG)+oModelVJQ:GetValue( "VJQMASTER", "VJQ_NTWCOD")+oModelVJQ:GetValue( "VJQMASTER","VJQ_RCRDTP" )
//				nPosPed := aScan(aPedPro,{ |x| x[1] == cComCod })

//				If nPosPed == 0
					aAdd(aPedPro,{;
									cComCod,;
									cCodImp,;
									dDtaPed >= dDtaIni,;
									{	{ "VQ0MASTER", "VQ0_CODVJQ", cCodImp },;
										{ "VQ0MASTER", "VQ0_CODMAR", cCodMar },;
										{ "VJRMASTER", "VJR_STAIMP", "0" },;
										{ "VJRMASTER", "VJR_DATATU", dDataBase };
									},;
									cIndice;
								})
//				EndIf

				nPosPed := aScan(aPedPro,{ |x| x[5] == cIndice })

			EndIf

			If aPedPro[nPosPed,3]

				For nZ := 1 to Len(aVQ0VQJ)

					cCodVJV   := ""
					cOpcional := ""
					cConteudo := oModelVJQ:GetValue( "VJQMASTER", aVQ0VQJ[nZ,2])

					If Empty(cConteudo)
						Loop
					EndIf

					If aVQ0VQJ[nZ,1] == "VJR_ORDNUM"
						cConteudo := VA14000H5_NumeroPedido(cConteudo)
					ElseIf aVQ0VQJ[nZ,1] == "VJR_STAFAB"
						cConteudo := VA14000C5_StatusPedido(cConteudo)
					ElseIf aVQ0VQJ[nZ,1] == "VQ0_MODVEI"
						If oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDTP") == "B"
							cConteudo := VA140005F_MontaModelo(cConteudo)
							// GRAVAR VX5 dos BASE CODE CODIGO e DESCRICAO -> GetValue("XYZ")
							cBaseCd := left(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDCOD"),6)
							cDescri := oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDDES")
							VA1400081_GravarBaseCode( cBaseCd , cDescri )
						Else
							Loop
						EndIf
					ElseIf aVQ0VQJ[nZ,1] == "VQ0_SEGMOD"
						cConteudo := ""
						If oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDTP") == "B"
							cBaseCd := left(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDCOD"),6)
							cModFab := oModelVJQ:GetValue( "VJQMASTER", "VJQ_MODNUM") + oModelVJQ:GetValue( "VJQMASTER", "VJQ_MODSUF")
							cConteudo := VA140005K_BuscaModelo(cCodMar, cModFab, cBaseCd,"3") // Busca Segmento 
						EndIf
					ElseIf aVQ0VQJ[nZ,1] == "VJR_ORDCOD" .and.;
						oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDTP") <> "B"
						If oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDTP") == "O"
							cNrModelo := oModelVJQ:GetValue( "VJQMASTER", "VJQ_MODNUM")
							cCodVJU   := VA1400061_Buscar_CODVJU( cNrModelo )
							aRetAux   := VA14000Q5_GravaOpcional( Right(cConteudo,6) , oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDDES") , cCodVJU )
							cCodVJV   := aRetAux[1]
							cOpcional := aRetAux[2]
							If MV_PAR04 == 1 // Gravar Configuração ( VQC e VQD )
								VA1400071_GravarConfiguracao( cCodVJV , cCodVJU , MV_PAR05 )
							EndIf
						Else
							Loop
						EndIf
					ElseIf aVQ0VQJ[nZ,1] == "VQ0_CHASSI"
						cConteudo := VA140005E_MontaChassi(cConteudo)
					ElseIf aVQ0VQJ[nZ,1] == "VQ0_FILPED" .or.;
							aVQ0VQJ[nZ,1] == "VQ0_FILENT"
						cConteudo := VA14000I5_ReferenciaFilial(cConteudo)
					ElseIf aVQ0VQJ[nZ,1] == "VQ0_EVENTO"
						cConteudo := VA14000P5_GravaEvento(cConteudo)
					Elseif aVQ0VQJ[nZ,1] == "VQ0_FATDIR"
						cConteudo := VA1400025_IndicaFaturamento(cConteudo)
					Else
						cTpCpoVQ0 := GeTSX3Cache(aVQ0VQJ[nZ,1],"X3_TIPO")
						cTpCpoVJQ := GeTSX3Cache(aVQ0VQJ[nZ,2],"X3_TIPO")
					EndIf

					if !Empty(cConteudo)
						nPosCp := aScan( aPedPro[nPosPed,4], { |x| x[2] == aVQ0VQJ[nZ,1] } )
						If nPosCp == 0
							aAdd(aPedPro[nPosPed,4],{ aVQ0VQJ[nZ,3], aVQ0VQJ[nZ,1], cConteudo, If(!Empty(cCodVJV), { { cCodVJV , cOpcional } } , {} ) } )
						Else
							If Empty(cOpcional)
								aPedPro[nPosPed,4,nPosCp,3] := cConteudo
							Else
								aAdd( aPedPro[nPosPed,4,nPosCp,4] , { cCodVJV , cOpcional } )
							EndIf
						EndIf
					EndIf

				Next

			EndIf

			If ( lRetVQJ := oModelVJQ:VldData() )
				ConfirmSX8()
				lRetVQJ := oModelVJQ:CommitData()



			Else
aErro := oModelVJQ:GetErrorMessage()
conout("-------------")
conout("VALIDVJQ     ")
conout("-------------")
	conout( "Id do formulário de origem:" + ' [' + AllToChar(aErro[1]) + ']') // "Id do formulário de origem:"
	conout( "Id do campo de origem: "     + ' [' + AllToChar(aErro[2]) + ']') // "Id do campo de origem: "    
	conout( "Id do formulário de erro: "  + ' [' + AllToChar(aErro[3]) + ']') // "Id do formulário de erro: " 
	conout( "Id do campo de erro: "       + ' [' + AllToChar(aErro[4]) + ']') // "Id do campo de erro: "      
	conout( "Id do erro: "                + ' [' + AllToChar(aErro[5]) + ']') // "Id do erro: "               
	conout( "Mensagem do erro: "          + ' [' + AllToChar(aErro[6]) + ']') // "Mensagem do erro: "         
	conout( "Mensagem da soluçao: "       + ' [' + AllToChar(aErro[7]) + ']') // "Mensagem da soluçao: "      
conout(" ")

				Help("",1,"VALIDVJQ",,STR0019,1,0)
			EndIf
		Else
			Help("",1,"ACTIVEVJQ",,STR0020,1,0)
		EndIf

		oModelVJQ:DeActivate()

	Next

Return


/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA14000P5_GravaEvento(cDescEvent)

	Local cCodEvento := ""
	
	Local cQuery     := ""

	cQuery := "SELECT VX5.VX5_CODIGO "
	cQuery += " FROM " + RetSqlName("VX5") + " VX5 "
	cQuery += " WHERE VX5.VX5_FILIAL = '" + xFilial("VX5") + "' "
	cQuery += 	" AND VX5.VX5_CHAVE  = '051' "
	cQuery += 	" AND VX5.VX5_DESCRI = '" + Alltrim( cDescEvent ) + "' "
	cQuery += 	" AND VX5.D_E_L_E_T_ = ' '"

	cCodEvento := FM_SQL(cQuery)
	
	If Empty(cCodEvento)

		cQuery := "SELECT MAX(VX5.VX5_CODIGO) "
		cQuery += " FROM " + RetSqlName("VX5") + " VX5 "
		cQuery += " WHERE VX5.VX5_FILIAL = '" + xFilial("VX5") + "' "
		cQuery += 	" AND VX5.VX5_CHAVE  = '051' "

		cSeqEvento := Alltrim(FM_SQL(cQuery))

		If Empty(cSeqEvento)
			cSeqEvento := cValToChar(StrZero(0,GeTSX3Cache("VJR_EVENTO","X3_TAMANHO")))
		EndIf

		cSeqEvento := Soma1(cSeqEvento,Len(cSeqEvento))

		OFIOA560ADD("051", cSeqEvento, cDescEvent)
		If OFIOA560VL("051", cSeqEvento,,.f.)
			cCodEvento := cSeqEvento
		EndIf
	EndIf

Return cCodEvento


/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA14000Q5_GravaOpcional( cOpcional , cDescOpcional , cCodVJU )

	Local cCodVJV := ""
	Local cCodOpc := ""
	Local cQuery  := ""
	Local nRecVJV := 0

	if oModelVJV == NIL
		oModelVJV := FWLoadModel( 'VEIA146' )
	endif

	DbSelectArea("VJV")
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM " + RetSqlName("VJV")
	cQuery += " WHERE VJV_FILIAL='"+xFilial("VJV")+"'"
	cQuery += "   AND VJV_CODOPC = '"+cOpcional+"'"
	cQuery += " AND VJV_CODVJU = '"+cCodVJU+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	nRecVJV := FM_SQL(cQuery)
	If nRecVJV > 0
		VJV->(DbGoto(nRecVJV))
		Return { VJV->VJV_CODIGO , VJV->VJV_CODOPC }
	EndIf

	oModelVJV:SetOperation( MODEL_OPERATION_INSERT )

	lRet := oModelVJV:Activate()

	If lRet

		oModelVJV:SetValue( "VJVMASTER", "VJV_CODOPC", Left(cOpcional,GetSX3Cache("VJV_CODOPC","X3_TAMANHO")) )
		oModelVJV:SetValue( "VJVMASTER", "VJV_DESOPC", cDescOpcional )
		oModelVJV:SetValue( "VJVMASTER", "VJV_CODVJU", cCodVJU )
		oModelVJV:SetValue( "VJVMASTER", "VJV_TIPGER", '0' )

		If ( lRet := oModelVJV:VldData() )

			lRet := oModelVJV:CommitData()




		Else
			Help("",1,"VALIDVJV",,STR0019,1,0)
		EndIf

		cCodVJV := oModelVJV:GetValue("VJVMASTER","VJV_CODIGO")
		cCodOpc := oModelVJV:GetValue("VJVMASTER","VJV_CODOPC")

		oModelVJV:DeActivate()
	Else
		Help("",1,"ACTIVEVJV",,STR0020,1,0)
	EndIf

	//FreeObj(oModelVJV)
	
Return { cCodVJV , cCodOpc }

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA14000R5_RelacionaOpcionalPedido( oModelPed, aOpcionais )

	Local nK := 0

	Local cCodVQ0 := ""

	oModelDet := oModelPed:GetModel("VJNMASTER")
	cCodVQ0   := oModelPed:GetValue( "VQ0MASTER", "VQ0_CODIGO")
	For nK := 1 to Len(aOpcionais)

			lSeek := oModelDet:SeekLine({;
										{ "VJN_FILIAL" , xFilial("VJN") },;
										{ "VJN_CODVQ0" , cCodVQ0 },;
										{ "VJN_CODVJV" , aOpcionais[nK,2] },;
										{ "VJN_CODOPC" , space(GetSX3Cache("VJN_CODOPC","X3_TAMANHO")) };
									})




				lSeek := oModelDet:SeekLine({;
										{ "VJN_FILIAL" , xFilial("VJN") },;
										{ "VJN_CODVQ0" , cCodVQ0 },;
										{ "VJN_CODVJV" , aOpcionais[nK,1] };
									})
				If	!lSeek
					If oModelDet:Length() == 1 .and. Empty(oModelDet:GetValue("VJN_CODVQ0"))
					Else
						oModelDet:AddLine()
					EndIf
					oModelDet:SetValue( "VJN_CODVQ0", cCodVQ0 )
					oModelDet:SetValue( "VJN_CODVJV", aOpcionais[nK,1] )
					oModelDet:SetValue( "VJN_CODOPC", aOpcionais[nK,2] )
				EndIf

















	Next

Return

/*/
{Protheus.doc} VEIA140

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function CriaSX1(cPerg)

	//Local aRegs := {}
	//Local nOpcGetFil := GETF_RETDIRECTORY

	//aAdd(aRegs,{"Local do Arquivo"      ,"Local do Arquivo"      ,"Local do Arquivo"      ,"MV_CH1","C",99,0,0,"G","!Vazio().or.(MV_PAR01:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+"))","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{"Informe o local do arquivo"},{},{}}) // Diretório
	//aAdd(aRegs,{"Data Inicio CGPoll"    ,"Data Inicio CGPoll"    ,"Data Inicio CGPoll"    ,"MV_CH2","D", 8,0,0,"G",""                                                                                ,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{"Informe a data inicial que o CGPoll será implementado. Assim, todos os pedidos anteriores a esta data não serão criados/atualizados ao importar o arquivo."},{},{}})
	//aAdd(aRegs,{"Cor"                   ,"Cor"                   ,"Cor"                   ,"MV_CH3","C", 6,0,0,"G","ExistCPO("VVC", cCodMar + MV_PAR03)"                                             ,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","VVC","","","","",{"Informe a cor padrão"},{},{}})
	//aAdd(aRegs,{"Importa Configurações?","Importa Configurações?","Importa Configurações?","MV_CH4","N", 1,0,0,"C",""                                                                                ,"MV_PAR04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","","","",{"Informe se importa as Configurações."},{},{}})
	//aAdd(aRegs,{"Nome Agrupador"        ,"Nome Agrupador"        ,"Nome Agrupador"        ,"MV_CH5","C",99,0,0,"G",""                                                                                ,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{"Informe o nome do Agrupador dos Opcionais."},{},{}})

	//FMX_AJSX1(cPerg,aRegs)

Return

Static Function  VA1400019_PergunteCOR()
    Local oObjSX1 := FWSX1Util():New()

    oObjSX1:AddGroup("VEIA140")
    oObjSX1:SearchGroup()
    If Len(  oObjSX1:GetGroup("VEIA140") [2] ) >= 3
        Return .t.
    EndIf 
	
Return .f.

/*/
{Protheus.doc} VA1400061_Buscar_CODVJU
Retorna o VJU_CODIGO referente ao Nro.Modelo Fabrica + BaseCod

@author Andre Luis Almeida
@since 22/06/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VA1400061_Buscar_CODVJU( cModNum )

	Local cRet      := ""
	Local cModFab   := ""
	Local cBaseCd   := ""
	Default cModNum := ""

	If oModelVJQ == NIL
		oModelVJQ := FWLoadModel( 'VEIA141' )
	EndIf

	If !Empty(cModNum)

		//Exemplo: 6190J
		cModFab := cModNum //6190
		cModFab += oModelVJQ:GetValue( "VJQMASTER", "VJQ_MODSUF") //J
		cBaseCd := left(oModelVJQ:GetValue( "VJQMASTER", "VJQ_ORDCOD"),6) //J

		cRet := VA140005K_BuscaModelo( cCodMar, cModFab, cBaseCd , "2" ) // Retorna o Codigo da Tabela VJU

	EndIf

Return cRet

/*/
{Protheus.doc} VA1400071_GravarConfiguracao
Gravar Configuração - VQC e VQD 

@author Andre Luis Almeida
@since 29/06/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VA1400071_GravarConfiguracao( cCodVJV , cCodVJU , cTitVQC )
Local nTamDesc := GeTSX3Cache("VQD_DESCRI","X3_TAMANHO")
Local nRecVQC  := 0
Local cQuery   := ""
Local cTitGrv  := ""


Local lRet := .f.
Local lGrava := .f.



if oModelVQC == nil
	oModelVQC := FWLoadModel( 'VEIA243' )
endif

VJV->(DbSetOrder(1))

VJU->(DbSetOrder(1))
VJU->(DbSeek(xFilial("VJU")+cCodVJU))

If !Empty(VJU->VJU_CODMAR+VJU->VJU_MODVEI+VJU->VJU_SEGMOD)

	cTitGrv := Alltrim(cTitVQC)+" - "+Alltrim(VJU->VJU_CODMAR)+" "+Alltrim(VJU->VJU_MODVEI)+" "+Alltrim(VJU->VJU_SEGMOD)

	cQuery := "SELECT R_E_C_N_O_ AS RECVQC "
	cQuery += "  FROM " + RetSqlName("VQC")
	cQuery += " WHERE VQC_FILIAL = '"+xFilial("VQC")+"'"
	cQuery += "   AND VQC_CODMAR = '"+VJU->VJU_CODMAR+"'"
	cQuery += "   AND VQC_GRUMOD = '"+VJU->VJU_GRUMOD+"'"
	cQuery += "   AND VQC_MODVEI = '"+VJU->VJU_MODVEI+"'"
	cQuery += "   AND VQC_SEGMOD = '"+VJU->VJU_SEGMOD+"'"
	cQuery += "   AND VQC_DESCRI = '"+cTitGrv+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"

	nRecVQC := FM_SQL(cQuery) 

	If nRecVQC == 0
		oModelVQC:SetOperation( MODEL_OPERATION_INSERT )
	Else
		VQC->(DbGoTo(nRecVQC))
		oModelVQC:SetOperation( MODEL_OPERATION_UPDATE )
	EndIf

	lRet := oModelVQC:Activate()

	if lRet
		
		If oModelVQC:GetOperation() == MODEL_OPERATION_INSERT
			oModelVQC:SetValue( "VQCMASTER", "VQC_FILIAL", xFilial("VQC") )
			oModelVQC:SetValue( "VQCMASTER", "VQC_CODIGO", GetSXENum("VQC","VQC_CODIGO") )
			oModelVQC:SetValue( "VQCMASTER", "VQC_CODMAR", VJU->VJU_CODMAR )
			oModelVQC:SetValue( "VQCMASTER", "VQC_GRUMOD", VJU->VJU_GRUMOD )
			oModelVQC:SetValue( "VQCMASTER", "VQC_MODVEI", VJU->VJU_MODVEI )
			oModelVQC:SetValue( "VQCMASTER", "VQC_SEGMOD", VJU->VJU_SEGMOD )
			oModelVQC:SetValue( "VQCMASTER", "VQC_DESCRI", cTitGrv )
		EndIf

		oModelVQD := oModelVQC:GetModel("VQDDETAIL")

		If !( oModelVQD:SeekLine( { {"VQD_FILIAL",xFilial("VQD")},;
									{"VQD_CODVJV",cCodVJV},;
									{"VQD_BASCOD",Left(VJU->VJU_BASECD,GeTSX3Cache("VQD_BASCOD","X3_TAMANHO"))},;
									{"VQD_DIGIMP","1"}},.f.,.t.))

			oModelVQD:AddLine()

			VJV->(DbSeek(xFilial("VJV")+cCodVJV))

			oModelVQD:SetValue( "VQD_FILIAL", xFilial("VQD") )
			oModelVQD:SetValue( "VQD_CODIGO", GetSXENum("VQD","VQD_CODIGO") )
			oModelVQD:LoadValue( "VQD_CODVQC", oModelVQC:GetValue( "VQCMASTER" , "VQC_CODIGO" ))
			oModelVQD:LoadValue( "VQD_CODVJV", cCodVJV )
			oModelVQD:SetValue( "VQD_BASCOD", Alltrim(VJU->VJU_BASECD) )
			oModelVQD:SetValue( "VQD_DESCRI", IIF ( ! empty(VJV->VJV_DESOPC) , left(VJV->VJV_DESOPC,nTamDesc) , "." ))
			oModelVQD:SetValue( "VQD_DIGIMP", "1" ) // Importado CGPoll


				oModelVQD:SetValue( "VQD_CODOPC", VJV->VJV_CODOPC )


			lGrava := .t.












		Endif

		If lGrava
			If ( lRet := oModelVQC:VldData() )
				lRet := oModelVQC:CommitData()
					ConfirmSX8()



			Else
				Help("",1,"VALIDVQC",,oModelVQC:GetErrorMessage()[6] + STR0021 + oModelVQC:GetErrorMessage()[2],1,0)
			EndIf
		EndIf

		oModelVQC:DeActivate()

	Else
		Help("",1,"ACTIVEVQC",,oModelVQC:GetErrorMessage()[6] + STR0021 + oModelVQC:GetErrorMessage()[2],1,0)
	EndIf

EndIf
// Chamar funções para gravar os pacotes automaticamente

Return

/*/
{Protheus.doc} VA1400081_GravarBaseCode
Gravar Configuração - VQC e VQD 

@author Andre Luis Almeida
@since 29/06/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VA1400081_GravarBaseCode( cBaseCd , cDescri )
DbSelectArea("VX5")
DbSetOrder(1)
If !DbSeek( xFilial("VX5") + '082' + left(cBaseCd+space(10),10) )
	OFIOA560ADD("082", cBaseCd, cDescri, "S") // Criação de registros no VX5
EndIf
Return

Static Function VA1400105_GravaPacoteConfiguracao( oModelPed , cChaInt , cBaseCode )

	
	Local cTitGrv   := ""
	Local cQuery    := ""
	Local oModVJN   := oModelPed:GetModel("VJNMASTER")
	Local nCntFor   := 0
	Local aOpcs     := {}
	Local cOpcs     := ""
	Local cCodPac   := ""
	Local oSqlHlp   := DMS_SqlHelper():New()
	Local aVQCVQD   := {}

	if oModelVN0 == NIL
		oModelVN0 := FWLoadModel( 'VEIA241' )
	endif

	VV1->( DbSetOrder(1) )
	VV1->( DbSeek( xFilial("VV1") + cChaInt ) )
	VV2->( DbSetOrder(1) )
	VV2->( DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ) )

	cTitGrv := Alltrim(MV_PAR05)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV1->VV1_MODVEI)+" "+Alltrim(VV1->VV1_SEGMOD)

	For nCntFor := 1 to oModVJN:Length()
		oModVJN:GoLine(nCntFor)
		aAdd(aOpcs,Alltrim(oModVJN:GetValue("VJN_CODOPC")))
	Next
	aSort(aOpcs)
	For nCntFor := 1 to len(aOpcs)
		cOpcs += aOpcs[nCntFor]
	Next

	cQuery := "SELECT VN0_CODIGO "
	cQuery += "  FROM " + RetSqlName("VN0")
	cQuery += " WHERE VN0_FILIAL = '"+xFilial("VN0")+"'"
	cQuery += "   AND VN0_CODMAR = '"+VV1->VV1_CODMAR+"'"
	cQuery += "   AND VN0_GRUMOD = '"+VV2->VV2_GRUMOD+"'"
	cQuery += "   AND VN0_MODVEI = '"+VV1->VV1_MODVEI+"'"
	cQuery += "   AND VN0_SEGMOD = '"+VV1->VV1_SEGMOD+"'"
	cQuery += "   AND VN0_BASCOD = '"+Alltrim(cBaseCode)+"'"
	cQuery += "   AND VN0_CHVOPC = '"+cOpcs+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cCodPac := FM_SQL(cQuery)

	If !Empty(cCodPac)
		Return cCodPac
	EndIf

	oModelVN0:SetOperation( MODEL_OPERATION_INSERT )
	lRet := oModelVN0:Activate()

	if lRet

		oModelVN0:SetValue( "VN0MASTER", "VN0_STATUS", "0" )
		oModelVN0:SetValue( "VN0MASTER", "VN0_CODMAR", VV1->VV1_CODMAR )
		oModelVN0:SetValue( "VN0MASTER", "VN0_GRUMOD", VV2->VV2_GRUMOD )
		oModelVN0:SetValue( "VN0MASTER", "VN0_MODVEI", VV1->VV1_MODVEI )
		oModelVN0:SetValue( "VN0MASTER", "VN0_SEGMOD", VV1->VV1_SEGMOD )
		oModelVN0:SetValue( "VN0MASTER", "VN0_BASCOD", Alltrim(cBaseCode) )
		oModelVN0:SetValue( "VN0MASTER", "VN0_DESPAC", cTitGrv )
		oModelVN0:SetValue( "VN0MASTER", "VN0_CHVOPC", cOpcs )

		oModDtVN2 := oModelVN0:GetModel("VN2DETAIL")

		cCodPac := oModelVN0:GetValue( "VN0MASTER", "VN0_CODIGO")

		oModDtVN2:AddLine()

		oModDtVN2:SetValue( "VN2_CODVN0", cCodPac )
		oModDtVN2:SetValue( "VN2_STATUS", "1" )
		oModDtVN2:SetValue( "VN2_DATINI", dDataBase )
		oModDtVN2:SetValue( "VN2_VALPAC", 0 )
		oModDtVN2:SetValue( "VN2_FREPAC", 0 )
		oModDtVN2:SetValue( "VN2_USRCAD", __cUserID )

		oModelVN1 := oModelVN0:GetModel("VN1DETAIL")

		For nCntFor := 1 to oModVJN:Length()
			oModVJN:GoLine(nCntFor)

			cQuery := "SELECT VQD_CODVQC, VQD_CODIGO "
			cQuery += "  FROM " + RetSqlName("VQD")
			cQuery += " WHERE VQD_FILIAL = '" + xFilial("VQD") + "' "
			cQuery += "   AND VQD_CODVJV = '" + oModVJN:GetValue("VJN_CODVJV") + "' "
			cQuery += "   AND D_E_L_E_T_ = ' '"
			aVQCVQD := oSqlHlp:GetSelectArray(cQuery, 2)
			If len(aVQCVQD) > 0
				cQuery := "SELECT R_E_C_N_O_ "
				cQuery += "  FROM " + RetSqlName("VN1")
				cQuery += " WHERE VN1_FILIAL = '" + xFilial("VN1") + "' "
				cQuery += "   AND VN1_CODVN0 = '" + cCodPac + "' "
				cQuery += "   AND VN1_CODVQC = '" + aVQCVQD[1,1] + "' "
				cQuery += "   AND VN1_CODVQD = '" + aVQCVQD[1,2] + "' "
				cQuery += "   AND D_E_L_E_T_ = ' '"
				If FM_SQL(cQuery) == 0 // veirifica se não existe para nao duplicar os registros
					oModelVN1:AddLine()
					oModelVN1:SetValue( "VN1_CODVN0", cCodPac )
					oModelVN1:SetValue( "VN1_CODVQC", aVQCVQD[1,1] )
					oModelVN1:SetValue( "VN1_CODVQD", aVQCVQD[1,2] )
				EndIf
			EndIf

		Next

		If ( lRet := oModelVN0:VldData() )
			lRet := oModelVN0:CommitData()
				ConfirmSX8()



		Else
			Help("",1,"VALIDVN0",,oModelVN0:GetErrorMessage()[6] + STR0021 + oModelVN0:GetErrorMessage()[2],1,0)
		EndIf

		oModelVN0:DeActivate()

	Else
		Help("",1,"ACTIVEVN0",,oModelVN0:GetErrorMessage()[6] + STR0021 + oModelVN0:GetErrorMessage()[2],1,0)
	EndIf

Return cCodPac

Static Function VA1400115_GravaConfiguracaoNoVeiculo( oModelPed , cChaInt , cCodPac )

	Local oModVJN := oModelPed:GetModel("VJNMASTER")
	Local cQuery  := ""
	LocaL cCodVQD := ""
	Local nCntFor := 0
	Local lRetMVCAuto
	
	Local aFldVQE := {}
	Local aCfgAtual
	Local nPosOpc

	If !Empty(cCodPac)

		If Type("aRotina") == "U"
			aRotina := {}
		endif

		Begin Transaction

		if oModelVQE == NIL
			oModelVQE := FwLoadModel("VEIA246")
		endif
		aCfgAtual := VA38005B_RetornaConfiguracaoVeiculo(cChaInt)

		For nCntFor := 1 to oModVJN:Length()
			oModVJN:GoLine(nCntFor)

			nPosOpc := aScan(aCfgAtual, { |x| x[5] == oModVJN:GetValue("VJN_CODVJV") })
			If nPosOpc > 0

				aCfgAtual[nPosOpc][4] := .T.

				VQE->(dbGoTo( aCfgAtual[nPosOpc,3]))

				aFldVQE := { {'VQE_CODPAC', cCodPac} }

				lRetMvcAuto := FwMvcRotAuto(oModelVQE, "VQE", MODEL_OPERATION_UPDATE, {{'MODEL_VQE', aFldVQE}}, .F., .F.)
				oModelVQE:DeActivate()
				If ! lRetMVCAuto
					
				Endif

			Else

				cQuery := " SELECT "
				cQuery += " 	VQD.VQD_CODIGO "
				cQuery += " FROM "
				cQuery += " 	" + RetSqlName("VQD") + " VQD "
				cQuery += " WHERE "
				cQuery += " 	VQD.VQD_FILIAL = '" + xFilial("VQD") + "' "
				cQuery += " 	AND VQD.VQD_CODVJV = '" + oModVJN:GetValue("VJN_CODVJV") + "' "
				cQuery += " 	AND VQD.D_E_L_E_T_ = ' ' "

				cCodVQD := FM_SQL(cQuery)

				If !Empty(cCodVQD)

					// Deve gravar VQE assim como os campos referentes no VV1_
					aFldVQE := {;
						{'VQE_CHAINT', cChaInt} ,;
						{'VQE_CODVQD', cCodVQD}  ,;
						{'VQE_CODPAC', cCodPac}  ;
					}

					lRetMvcAuto := FwMvcRotAuto(oModelVQE, "VQE", MODEL_OPERATION_INSERT, {{'MODEL_VQE', aFldVQE}}, .F., .F.)
					oModelVQE:DeActivate()
					If ! lRetMVCAuto
						
					Endif

				endif

			EndIf

		Next

		// Exclui registros nao utilizados ...
		For nCntFor := 1 To Len(aCfgAtual)

			// verifica se o registro foi alterado durante o processamento do vetor de configuracao 
			if aCfgAtual[nCntFor, 4]
				loop
			endif
			//

			VQE->(dbGoTo( aCfgAtual[nCntFor,3]))

			lRetMvcAuto := FwMvcRotAuto(oModelVQE, "VQE", MODEL_OPERATION_DELETE , {}, .F., .F.)
			oModelVQE:DeActivate()
			If ! lRetMVCAuto
				MostraErro()
			Endif
			
		Next
		//	

		// Chama a rotina de transmissão do veiculo para justamente enviar os registros de Options
		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1") + cChaInt ))
		VA0700033_TransmitirBlackBird("VV1",VV1->(Recno()),4,.f.)
		//

		End Transaction
	EndIf
Return


/*/{Protheus.doc} VA14000SC_SetBBSync
Restaura VV1 no Blackbird ou marca para sincronismo
@type function
@version 1.0
@author rubens takahashi
@since 29/04/2024
@param cChaInt, character, Chassi Interno
/*/
static function VA14001213_BBSyncRestVV1(oModelVQ0, cChaInt)
	if ! empty( cChaInt ) .and. lMVMIL0185 .and. ;
		(! empty( oModelVQ0:GetValue( "VJRMASTER", "VJR_RTLDAT" ) ) .or. ! empty( oModelVQ0:GetValue( "VJRMASTER", "VJR_CCGNAM" ) ) )
		
		VV1->( DbSetOrder(1) )
		if VV1->( DbSeek( xFilial("VV1") + cChaInt ) )
			
			oModelVV1:setOperation( MODEL_OPERATION_UPDATE )
			if oModelVV1:Activate()
				oModelVV1:SetValue( "MODEL_VV1", "VV1_BBSYNC", "0" )
				if oModelVV1:getValue( "MODEL_VV1", "VV1_BBDEL") == "1"
					oModelVV1:SetValue( "MODEL_VV1", "VV1_BBDEL","0")
				EndIf
				if oModelVV1:VldData()
					oModelVV1:CommitData()
				endif
			endif
			oModelVV1:DeActivate()
		endif
	endif
return

/*/{Protheus.doc} VA14000SC_SetBBSync
Marca o Veículo para ser integrado com o SMO - Blackbird
@type function
@version 1.0
@author cristiamRossi
@since 12/18/2023
@param cBaseCD, character, Código base do equipamento
/*/
static function VA14000SC_SetBBSync( cBaseCD )
local cAliasAtu := alias()
local oModelVV1
local cAlias    := getNextAlias()

	if empty( cBaseCD )
		return nil
	endif

	beginSql alias cAlias
		select distinct VV1.R_E_C_N_O_ RECVV1
		from %table:VJR% VJR
		join %table:VQ0% VQ0
			on  VQ0_FILIAL = %xFilial:VQ0%
			and VQ0_CODIGO = VJR_CODVQ0
			and VQ0.%notdel%
		join %table:VV1% VV1
			on  VV1_FILIAL = %xFilial:VV1%
			and VV1_CHAINT = VQ0_CHAINT
			and VV1.%notdel%
		where VJR_FILIAL = %xFilial:VJR%
		and   VJR_ORDCOD = %exp:cBaseCD%
		and   VJR.%notdel%
	endSql

	if ! (cAlias)->( eof() )
		oModelVV1 := FWLoadModel( 'VEIA070' )
		oModelVV1:SetOperation( MODEL_OPERATION_UPDATE )

		while ! (cAlias)->( eof() )
			dbSelectArea("VV1")
			VV1->( dbGoto( (cAlias)->RECVV1 ) )
			if oModelVV1:Activate()
				//oModelVV1:SetValue("MODEL_VV1", "VV1_BBINTG" , "0" ) // Marca como nao integrado para enviar a JD
				oModelVV1:SetValue("MODEL_VV1", "VV1_BBSYNC" , "0" ) // Marca como nao sincronizado para enviar a JD
				if VV1->VV1_BBDEL == "1"
					oModelVV1:SetValue("MODEL_VV1", "VV1_BBDEL"  , "0" ) // Desmarca como deletado
				endif
				if oModelVV1:VldData()
					oModelVV1:CommitData()
				endif
			endif
			oModelVV1:DeActivate()

			(cAlias)->( dbSkip() )
		endDo
		freeObj(oModelVV1)
	endif
	(cAlias)->( dbCloseArea() )

	if ! empty(cAliasAtu)
		dbSelectArea( cAliasAtu )
	endif
return nil


/*/{Protheus.doc} VA140013C_FatDireto
rotina que gera Faturamento Direto em caso de Venda
@type function
@version 1.0
@author cristiamRossi
@since 7/25/2024
@param oModelVQ0, object, modelo MVC tabela VQ0
@return logical, sucesso ou não na geração do faturamento direto
/*/
static function VA140013C_FatDireto( oModelVQ0 )
local   nOpc        := 3
local   aAutoCab    := {}
local   aAutoItens  := {}
local   aAutoIt     := {}
local   cQuery
local   nRecVVA
local   _filAtu     := cFilAnt
local   cAuxFil     := oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_FILENT' )
private lMSHelpAuto := .T.
private lMsErroAuto := .F.

	if ! empty( cAuxFil )
		cFilAnt := cAuxFil
	endif

	cQuery := "select R_E_C_N_O_ RECVVA from " + retSqlName("VVA")
	cQuery += " where VVA_FILIAL='" + xFilial("VVA") + "'"
	cQuery += " and VVA_NUMPED='" + oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_NUMPED' ) + "'"
	cQuery += " and D_E_L_E_T_ = ' '"
	nRecVVA := FM_SQL( cQuery )
	if nRecVVA > 0
		nOpc := 4
		VVA->( dbGoto( nRecVVA ) )
		VV0->( dbSetOrder(1) )
		VV0->( dbSeek( VVA->( VVA_FILIAL + VVA_NUMTRA ) ) )
		VV9->( dbSetOrder(1) )
		VV9->( dbSeek( VVA->( VVA_FILIAL + VVA_NUMTRA ) ) )
	endif

	aAdd( aAutoCab, { "VV0_MODVDA" ,"0"           , nil })     // 0=NOVO;1=USADO

    aAdd( aAutoIt , { 'VVA_CODPED' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_CODIGO' ) , nil } )
    aAdd( aAutoIt , { 'VVA_NUMPED' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_NUMPED' ) , nil } )
    aAdd( aAutoIt , { 'VVA_CODMAR' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_CODMAR' ) , nil } )
    aAdd( aAutoIt , { 'VVA_MODVEI' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_MODVEI' ) , nil } )
    aAdd( aAutoIt , { 'VVA_SEGMOD' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_SEGMOD' ) , nil } )
    aAdd( aAutoIt , { 'VVA_CHAINT' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_CHAINT' ) , nil } )
    aAdd( aAutoIt , { 'VVA_CHASSI' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_CHASSI' ) , nil } )
    aAdd( aAutoIt , { 'VVA_CORVEI' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_CORVEI' ) , nil } )
    aAdd( aAutoIt , { 'VVA_VALTAB' , oModelVQ0:getValue( 'VQ0MASTER', 'VQ0_VALCUS' ) , nil } )
	if nRecVVA > 0
		aAdd( aAutoIt , { 'RECVVA' , nRecVVA                                         , nil } )
	endif
    aAdd(aAutoItens,aAutoIt)

    msExecAuto({|x,y,z,w| VEIXX030(x,y,,z)}, aAutoCab, aAutoItens, nOpc)
    if lMsErroAuto
        MostraErro()
    endif

	cFilAnt := _filAtu
return ! lMsErroAuto


/*/{Protheus.doc} VA1400025_IndicaFaturamento

@type function
@version 1.0
@author Renato Vinicius
@since 22/05/2025
@param 
@return logical, sucesso ou não na geração do faturamento direto
/*/

Static Function VA1400025_IndicaFaturamento(cStaVend)

	Local cRetorno := " "

	If alltrim( cStaVend ) $ "VENDA"
		cRetorno := "0"
	EndIf

Return cRetorno
