#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldItFDir
Validador das críticas de itens das guias de fornecimento direto

@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldItFDir From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldItFDir
	_Super:new()
Return Self

Method initCritInd() Class CenVldItFDir
	Self:aCritInd := {}
	
	aAdd(Self:aCritInd,CritCODGRU2():New())
	aAdd(Self:aCritInd,CritCodPro2():New())
	aAdd(Self:aCritInd,CritCodTab2():New())

Return

Method initCritGrp() Class CenVldItFDir
	Self:aCritGrp := {}

	aAdd(Self:aCritGrp,CritDtPrGu2():New())
	aAdd(Self:aCritGrp,CritQtdInf2():New())
	aAdd(Self:aCritGrp,CritVlPgPr2():New())
	aAdd(Self:aCritGrp,CritVlrCop2():New())
Return




