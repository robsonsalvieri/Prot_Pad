#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldItMGui
Descricao:  Classe Responsavel por Validar as Criticas da Obriga��o
				.-> MONITORAMENTO TISS

@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldItMGui From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldItMGui
	_Super:new()
Return Self

Method initCritInd() Class CenVldItMGui
	Self:aCritInd := {}
	aAdd(Self:aCritInd,CritCODGRU():New())
	aAdd(Self:aCritInd,CritCDFACE():New())
	aAdd(Self:aCritInd,CritCODPRO():New())
	aAdd(Self:aCritInd,CritCNPJFR():New())
	aAdd(Self:aCritInd,CritTABPAC():New())
	aAdd(Self:aCritInd,CritCDFAC1():New())	
Return

Method initCritGrp() Class CenVldItMGui
	Self:aCritGrp := {}
	
	aAdd(Self:aCritGrp,CritCdDent():New())
	aAdd(Self:aCritGrp,CritCdRegi():New())
	aAdd(Self:aCritGrp,CritCodTab():New())
	aAdd(Self:aCritGrp,CritPgPr2():New())
	aAdd(Self:aCritGrp,CritQtdInf():New())
	aAdd(Self:aCritGrp,CritQtPag2():New())
	aAdd(Self:aCritGrp,CritVlrCop():New())
	aAdd(Self:aCritGrp,CritVlrIn2():New())
	aAdd(Self:aCritGrp,CritVlrPgf():New())
	aAdd(Self:aCritGrp,CritQtPag3():New())	

Return




