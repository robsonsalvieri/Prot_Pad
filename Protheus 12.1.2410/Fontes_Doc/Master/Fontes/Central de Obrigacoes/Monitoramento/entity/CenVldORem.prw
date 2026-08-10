#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldORem
Validador das críticas de guias de outras formas de remuneração

@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldORem From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldORem
	_Super:new()
Return Self

Method initCritInd() Class CenVldORem
	Self:aCritInd := {}
	
	aAdd(Self:aCritInd,CritCPFCNPJ2():New())
	aAdd(Self:aCritInd,CritIDEREC():New())
	
Return

Method initCritGrp() Class CenVldORem
	Self:aCritGrp := {}
	//BVZ
	aAdd(Self:aCritGrp,CritDatProc():New())
	aAdd(Self:aCritGrp,CritTpRgMn2():New())
	aAdd(Self:aCritGrp,CritVltGlo2():New())
	aAdd(Self:aCritGrp,CritVltInf():New())
	aAdd(Self:aCritGrp,CritVltPag():New())
	
Return




