#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class loteGuias 
method New() Constructor

data cTpTran
data cSeqTran
data cDataTran
data cHoraTran
data cNumLote
data cCgcOri
data cCodRDA
data cRegAns
data cCgcDes
data cRegDes
data cVerTiss
data cTipoGuia
data nValTotal //silvia
data nQtdGuias //silvia
data nQtdProcs
data cCodPegGr
data cNumB1R

endclass

method New() class loteGuias
::cTpTran   := ""
::cSeqTran  := ""
::cDataTran := ""
::cHoraTran := ""
::cNumLote  := ""
::cCgcOri   := ""
::cCodRDA   := ""
::cRegAns   := ""
::cCgcDes   := ""
::cRegDes	:= ""
::cVerTiss  := ""
::cTipoGuia := ""
::nValTotal := 0 //silvia
::nQtdGuias	:= 0 //silvia
::nQtdProcs	:= 0
::cCodPegGr := ""
::cNumB1R   := ""

Return Self
//================================================================
class GConsulta 
method New() Constructor

data cNumGuiPre
data cNumGuiOpe
data cRegAnsCab
data cIndAcid
data cObs
data cDataAtend
data cTpConsult
data oBenef 
data oRda
data oProfExec
data oProced
data oRDASolicitante
data oDadosSolicitacao
data oRDAExecutante
data oDadosAtendimento
data oProcedSADT
data oProfExecSadt
data oProfSolicitante
data cDatAutori
data cSenha
data cDatVldSen
data cNumGuiPri
data oXMLTotais
data oProcedOutDesp
data aProcImp
data cGuiaSolInt
data oLocContratado
data oDadInternacao
data cDtEmiGuia
data cNGuiSoInt
data oSaidaInte
endclass

method New() class GConsulta
::cNumGuiPre    := ""
::cNumGuiOpe    := ""
::cRegAnsCab	 := ""
::cIndAcid      := ""
::cObs          := ""
::cDataAtend    := ""
::cTpConsult    := ""
::oBenef        := oBenef():new()
::oRda          := RDA():new()
::oProfExec     := ProfExec():new()
::oProced       := Procedimento():new()
::oProcedOutDesp:= ProcedOutDesp():new()
::cDatAutori 	:= ""
::cSenha		:= ""
::cDatVldSen	:= ""
::cNumGuiPri	:= ""
::aProcImp		:= {}

// SADT
::oRDASolicitante	:= RDASolicitante():new()
::oDadosSolicitacao	:= DadosSolicitacao():new()
::oRDAExecutante	:= RDAExecutante():new()
::oDadosAtendimento	:= DadosAtendimento():new()
::oProfExecSadt		:= ProfExecSadt():new()
::oProfSolicitante	:= ProfSolicitante():new()
::oXMLTotais		:= XMLTotais():new()

// HONORARIOS
::cGuiaSolInt	    := ""
::oLocContratado	:= LocalContratado():new()
::oDadInternacao	:= DadosInternacao():new()
::cDtEmiGuia        :=""

// RESUMO DE INTERNAÇÃO 

::cNGuiSoInt        := ""
::oSaidaInte        := oSaidaInte():new()

Return Self

//================================================================

class oSaidaInte 
method New() Constructor

data cIndAciden
data cMotEnce 

endclass

method New() class oSaidaInte
::cIndAciden  := ""
::cMotEnce    := ""

Return Self


//================================================================
class oBenef 
method New() Constructor

data cCarteirinha
data cAtendRN
data cNome
data cCNS
data cIndBenef

endclass

method New() class oBenef
::cCarteirinha  := ""
::cAtendRN      := ""
::cNome         := ""
::cCNS          := ""
::cIndBenef     := ""

Return Self

//================================================================
class RDA 
method New() Constructor

data cCodRda
data cCgc
data cNome
data cCnes

endclass

method New() class RDA
::cCodRda  := ""
::cCgc     := ""
::cNome    := ""
::cCnes    := ""

Return Self

//================================================================
class ProfExec 
method New() Constructor

data cNome
data cConselho
data cNumCons
data cUF
data cCBOS

endclass

method New() class ProfExec
::cNome     := ""
::cConselho := ""
::cNumCons  := ""
::cUF       := ""
::cCBOS     := ""
Return Self

//================================================================
class Procedimento 
method New() Constructor

data cCodTab
data cCodPro
data nVlrPro
data cDatExec
data cHoraIni
data cHoraFim
data cDescPro
data nQtdExe
data nViaAce
data cTecUti
data nRedAcr
data nVlrTot
data cSeqItem

data cRegiao
data cDente
data cFace

endclass

method New() class Procedimento
::cCodTab       := ""
::cCodPro       := ""
::nVlrPro       := 0
::cDatExec 	    := ""
::cHoraIni		:= ""
::cHoraFim 	    := ""
::cCodTab		:= ""	
::cCodPro		:= ""
::cDescPro		:= ""
::nQtdExe		:= 0
::nViaAce		:= 0
::cTecUti		:= ""
::nRedAcr		:= 0
::nVlrTot		:= 0
::cSeqItem		:= ""
::cRegiao       := ""
::cDente        := ""
::cFace         := ""

Return Self




//SADT Exclusivos
//================================================================
class RDASolicitante
method New() Constructor

data cCodRda
data cCgc
data cNome

endclass

method New() class RDASolicitante
::cCodRda  := ""
::cCgc     := ""
::cNome    := ""
Return Self



//================================================================
class ProfSolicitante 
method New() Constructor

data cNome
data cConselho
data cNumCons
data cUF
data cCBOS

endclass

method New() class ProfSolicitante
::cNome     := ""
::cConselho := ""
::cNumCons  := ""
::cUF       := ""
::cCBOS     := ""
Return Self

//================================================================



class DadosSolicitacao
method New() Constructor

data cDataSol
data cCartAtend
data cIndClinica
data cUF
data cCBOS

endclass

method New() class DadosSolicitacao
::cDataSol     	:= ""
::cCartAtend 		:= ""
::cIndClinica  	:= ""
Return Self



//================================================================
class RDAExecutante
method New() Constructor

data cCodRda
data cCgc
data cNome
data cCnes

endclass

method New() class RDAExecutante
::cCodRda  := ""
::cCgc     := ""
::cNome    := ""
::cCnes    := ""
Return Self



//================================================================
class DadosAtendimento
method New() Constructor

data cTipoAtend
data cIndicAcid
data cTipoConsl
data cMotEncerr

endclass

method New() class DadosAtendimento
::cTipoAtend	:= ""
::cIndicAcid	:= ""
::cTipoConsl	:= ""
::cMotEncerr	:= ""
Return Self



//================================================================
class ProfExecSadt
method New() Constructor

data cGrauPart
data cCodProf
data cNome
data cConselho
data cNumCons
data cUF
data cCBOS

endclass

method New() class ProfExecSadt
::cGrauPart	    := ""
::cCodProf		:= ""
::cNome		    := ""
::cConselho	    := ""
::cNumCons		:= ""
::cUF			:= ""
::cCBOS		    := ""

Return Self



//================================================================
class XMLTotais
method New() Constructor

data nVlrProcedimento
data nVlrDiarias
data nVlrTaxAlug
data nVlrMateriais
data nVlrMedicamentos
data nVlrOPME
data nVlrGasesMed
data nVlrTotalGeral

endclass

method New() class XMLTotais
::nVlrProcedimento	:= 0
::nVlrDiarias		:= 0
::nVlrTaxAlug		:= 0
::nVlrMateriais		:= 0
::nVlrMedicamentos	:= 0
::nVlrOPME			:= 0
::nVlrGasesMed		:= 0
::nVlrTotalGeral	:= 0

Return Self



//================================================================
class ProcedOutDesp 
method New() Constructor

data cSeqItem
data cCodDesp
data cDatExec
data cHoraIni
data cHoraFim
data cCodTab
data cCodPro
data nQtdExe
data cUnMedida
data nRedAcr
data nVlrPro
data nVlrTot
data cDescPro
data cRegAnvisa
data cCodFabric
data cAutoriFunc

endclass

method New() class ProcedOutDesp
::cSeqItem      := ""
::cCodDesp		:= ""
::cDatExec		:= ""
::cHoraIni		:= ""
::cHoraFim		:= ""
::cCodTab		:= ""
::cCodPro		:= ""
::nQtdExe		:= 0
::cUnMedida 	:= ""
::nRedAcr		:= 0
::nVlrPro		:= 0
::nVlrTot		:= 0
::cDescPro		:= ""
::cRegAnvisa	:= ""
::cCodFabric	:= ""
::cAutoriFunc	:= ""
Return Self

//================================================================
//Honorarios
//================================================================
class LocalContratado
method New() Constructor

data cCodRda
data cCgc
data cNome
data cCnes

endclass

method New() class LocalContratado
::cCodRda  := ""
::cCgc     := ""
::cNome    := ""
::cCnes    := ""
Return Self

//================================================================
class DadosInternacao
method New() Constructor

data cCaracAten 
data cTipFat
data cDatIniFat
data cDatFimFat
data cHorIniFat
data cHorFimFat
data cTipIntern
data cRegIntern

endclass

method New() class DadosInternacao
::cCaracAten  := ""
::cTipFat     := ""
::cDatIniFat  := ""
::cDatFimFat  := ""
::cHorIniFat  := ""
::cHorFimFat  := ""
::cTipIntern  := ""
::cRegIntern  := ""

Return Self
