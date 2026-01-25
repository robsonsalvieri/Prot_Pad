#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldFDir
Validador das críticas de guias de fornecimento direto

@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldFDir From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldFDir
	_Super:new()
Return Self

Method initCritInd() Class CenVldFDir
	Self:aCritInd := {}
	
	aAdd(Self:aCritInd,CritCNS2():New())
	aAdd(Self:aCritInd,CritCODMUN2():New())
	aAdd(Self:aCritInd,CritDtNas2():New())
	aAdd(Self:aCritInd,CritIDFORN():New())
	aAdd(Self:aCritInd,CritIDPLAN2():New())
	aAdd(Self:aCritInd,CritSexo2():New())
	aAdd(Self:aCritInd,CritVLTCOP2():New())
	aAdd(Self:aCritInd,CritVLTGUI2():New())
	aAdd(Self:aCritInd,CritProd2():New())

Return

Method initCritGrp() Class CenVldFDir
	Self:aCritGrp := {}
	
	aAdd(Self:aCritGrp,CritInDtPrg2():New())
	aAdd(Self:aCritGrp,CritVltbOpe():New())
	
Return




