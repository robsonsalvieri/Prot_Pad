#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldMGui
Descricao:  Classe Responsavel por Validar as Criticas da Obrigação
				.-> MONITORAMENTO TISS

@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldMGui From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldMGui
	_Super:new()
Return Self

Method initCritInd() Class CenVldMGui
	Self:aCritInd := {}
	aAdd(Self:aCritInd,CritCNS():New())
	aAdd(Self:aCritInd,CritCodMun():New())
	aAdd(Self:aCritInd,CritDtNas():New())
	aAdd(Self:aCritInd,CritIdPlan():New())
	aAdd(Self:aCritInd,CritMunBen():New())
	aAdd(Self:aCritInd,CritCNPJ():New())
	aAdd(Self:aCritInd,CritCodCBOS():New())
	aAdd(Self:aCritInd,CritDECNUM():New())
	aAdd(Self:aCritInd,CritDECOBI():New())
	aAdd(Self:aCritInd,CritIDVLRP():New())
	aAdd(Self:aCritInd,CritSexo():New())
	aAdd(Self:aCritInd,CritVLTCOP():New())
	aAdd(Self:aCritInd,CritVlrInf():New())
	aAdd(Self:aCritInd,CritVltFOR():New())
	aAdd(Self:aCritInd,CritVltProc():New())
	aAdd(Self:aCritInd,CritProd():New())
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DTPROT"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DTINFT"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DTFIFT"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DATREA"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DATAUT"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DTPAGT"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DATSOL"))
	aAdd(Self:aCritInd,CritDtMoni():New("BKR_DTPRGU"))

Return

Method initCritGrp() Class CenVldMGui
	Self:aCritGrp := {}

	aAdd(Self:aCritGrp,CritBenRN():New())
	aAdd(Self:aCritGrp,CritCID1():New())
	aAdd(Self:aCritGrp,CritCID2():New())
	aAdd(Self:aCritGrp,CritCID3():New())
	aAdd(Self:aCritGrp,CritCID4():New())
	aAdd(Self:aCritGrp,CritCNES():New())
	aAdd(Self:aCritGrp,CritDiaAco():New())
	aAdd(Self:aCritGrp,CritDiaUTI():New())
	// aAdd(Self:aCritGrp,CritDtAut():New())
	// aAdd(Self:aCritGrp,CritDtFinFat():New())
	// aAdd(Self:aCritGrp,CritDtInFat():New())
	// aAdd(Self:aCritGrp,CritDtPag():New())
	// aAdd(Self:aCritGrp,CritDtProc():New())
	// aAdd(Self:aCritGrp,CritDtRea():New())
	// aAdd(Self:aCritGrp,CritDtProt():New())
	// aAdd(Self:aCritGrp,CritDtSol():New())
	aAdd(Self:aCritGrp,CritIdPrest():New())
	aAdd(Self:aCritGrp,CritIdReOp():New())
	aAdd(Self:aCritGrp,CritIndAcid():New())
	aAdd(Self:aCritGrp,CritNumGuia():New())
	aAdd(Self:aCritGrp,CritOrigEven():New())
	aAdd(Self:aCritGrp,CritRegInt():New())
	aAdd(Self:aCritGrp,CritRgOpIn():New())
	aAdd(Self:aCritGrp,CritTipAdm():New())
	aAdd(Self:aCritGrp,CritTipAte():New())
	aAdd(Self:aCritGrp,CritTipFat():New())
	aAdd(Self:aCritGrp,CritTpCons():New())
	aAdd(Self:aCritGrp,CritTpEvent():New())
	aAdd(Self:aCritGrp,CritTpInt():New())
	aAdd(Self:aCritGrp,CritTpReg():New())
	aAdd(Self:aCritGrp,CritVltDia():New())
	aAdd(Self:aCritGrp,CritVltGlo():New())
	aAdd(Self:aCritGrp,CritVltMat():New())
	aAdd(Self:aCritGrp,CritVltOPE():New())
//	aAdd(Self:aCritGrp,CritVltPgp():New())
	aAdd(Self:aCritGrp,CritVltTax():New())
	//aAdd(Self:aCritGrp,CritVltTBP():New())
	aAdd(Self:aCritGrp,CritNMGPri():New())
	aAdd(Self:aCritGrp,CritNrGuiaOp():New())
	aAdd(Self:aCritGrp,CritNrSolIn():New())
	aAdd(Self:aCritGrp,CritVltGUI():New())
	aAdd(Self:aCritGrp,CritMotSai():New())	
	aAdd(Self:aCritGrp,CriTpAtTd():New())	
	aAdd(Self:aCritGrp,CritCdCboTd():New())
	aAdd(Self:aCritGrp,CriTPADMTd():New())
	aAdd(Self:aCritGrp,CritVerTd():New())
	aAdd(Self:aCritGrp,CritTpInt1():New())
	aAdd(Self:aCritGrp,CritDNVGri():New())
	aAdd(Self:aCritGrp,CritDNVObs():New())
	aAdd(Self:aCritGrp,CritDecObt():New())
	aAdd(Self:aCritGrp,CritCNES1():New())

Return




