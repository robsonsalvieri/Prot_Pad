#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldVPre
Validador das críticas de guias de valor pré-estabelecido

@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldVPre From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldVPre
	_Super:new()
Return Self

Method initCritInd() Class CenVldVPre
	Self:aCritInd := {}

	aAdd(Self:aCritInd,CritIDVLRP2():New())
	aAdd(Self:aCritInd,CritCPFCNPJ():New())

Return

Method initCritGrp() Class CenVldVPre
	Self:aCritGrp := {}
	//B9T
	aAdd(Self:aCritGrp,CritCDMUNPR():New())
	aAdd(Self:aCritGrp,CritIDEPRE():New())
	aAdd(Self:aCritGrp,CritINDTPRG():New())
	aAdd(Self:aCritGrp,CritVLRPRE():New())
	aAdd(Self:aCritGrp,CritRGOPIN2():New())
	aAdd(Self:aCritGrp,CritCNES9T():New())
	aAdd(Self:aCritGrp,CritIDPR():New())
	aAdd(Self:aCritGrp,CritCNE9T1():New())

Return




