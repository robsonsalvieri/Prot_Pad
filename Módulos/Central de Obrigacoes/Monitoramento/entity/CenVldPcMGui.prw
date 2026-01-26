#Include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldPcMGui
Descricao:  Classe Responsavel por Validar as Criticas dos pacotes dos itens das guias do monitoramento TISS

@author Everton Mateus Fernandes
@since 05/12/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldPcMGui From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldPcMGui
	_Super:new()
Return Self

Method initCritInd() Class CenVldPcMGui
	Self:aCritInd := {}
	
	aAdd(Self:aCritInd,CritCDPRIT():New())
Return

Method initCritGrp() Class CenVldPcMGui
	Self:aCritGrp := {}
	
	aAdd(Self:aCritGrp,CritQTPRPC():New())
Return




