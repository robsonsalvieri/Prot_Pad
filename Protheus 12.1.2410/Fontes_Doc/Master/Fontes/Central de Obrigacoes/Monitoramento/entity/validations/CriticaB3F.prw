#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CriticaB3F
Descricao: Classe abstrata das Criticas do Projeto de Monitoramento.	
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CriticaB3F 

	Data cCodCrit
	Data cMsgCrit
	Data cSolCrit
	Data cCpoCrit
	Data cAlias
	Data cOper
	Data cObrig
	Data cAno
	Data cComp
	Data nRecno
	Data cTpVld
	Data cCodANS
	Data cChaveOri
	Data cDesOri
	Data cStatus
	Data oEntity

	Method New() Constructor
	Method destroy()
	Method setCodCrit(cCodCrit)
	Method setMsgCrit(cMsgCrit)
	Method setSolCrit(cSolCrit)
	Method setCpoCrit(cCpoCrit)
	Method setAlias(cAlias)
	Method setOper(cOper)
	Method setObrig(cObrig)
	Method setAno(cAno)
	Method setComp(cComp)
	Method setRecno(nRecno)
	Method setTpVld(cTpVld)
	Method setCodANS(cCodANS)
	Method setChaveOri(cChaveOri)
	Method setDesOri(cDesOri)
	Method setStatus(cStatus)
	Method setEntity(oEntity)
	Method getCodCrit()
	Method getMsgCrit()
	Method getSolCrit()
	Method getCpoCrit()
	Method getAlias()
	Method getOper()
	Method getObrig()
	Method getAno()
	Method getComp()
	Method getRecno()
	Method getTpVld()
	Method getCodANS()
	Method getChaveOri()
	Method getDesOri()
	Method getStatus()
	Method getObj()
	Method validar()

EndClass

Method New() Class CriticaB3F
	self:setTpVld('1')
	self:setStatus('1' )
Return Self

Method destroy() Class CriticaB3F
Return

Method setCodCrit(cCodCrit) Class CriticaB3F
	self:cCodCrit := cCodCrit
Return

Method setMsgCrit(cMsgCrit) Class CriticaB3F
	self:cMsgCrit := cMsgCrit
Return

Method setSolCrit(cSolCrit) Class CriticaB3F
	self:cSolCrit := cSolCrit
Return

Method setCpoCrit(cCpoCrit) Class CriticaB3F
	self:cCpoCrit := cCpoCrit
Return

Method setAlias(cAlias) Class CriticaB3F
	self:cAlias := cAlias
Return

Method setOper(cOper) Class CriticaB3F
	self:cOper := cOper
Return

Method setObrig(cObrig) Class CriticaB3F
	self:cObrig := cObrig
Return

Method setAno(cAno) Class CriticaB3F
	self:cAno := cAno
Return

Method setComp(cComp) Class CriticaB3F
	self:cComp := cComp
Return

Method setRecno(nRecno) Class CriticaB3F
	self:nRecno := nRecno
Return

Method setTpVld(cTpVld) Class CriticaB3F
	self:cTpVld := cTpVld
Return

Method setCodANS(cCodANS) Class CriticaB3F
	self:cCodANS := cCodANS
Return

Method setChaveOri(cChaveOri) Class CriticaB3F
	self:cChaveOri := cChaveOri
Return

Method setDesOri(cDesOri) Class CriticaB3F
	self:cDesOri := cDesOri
Return

Method setStatus(cStatus) Class CriticaB3F
	self:cStatus := cStatus
Return

Method setEntity(oEntity) Class CriticaB3F
	self:oEntity := oEntity
Return

Method getCodCrit() Class CriticaB3F
Return self:cCodCrit

Method getMsgCrit() Class CriticaB3F
Return self:cMsgCrit

Method getSolCrit() Class CriticaB3F
Return self:cSolCrit

Method getCpoCrit() Class CriticaB3F
Return self:cCpoCrit

Method getAlias() Class CriticaB3F
Return self:cAlias

Method getOper() Class CriticaB3F
Return self:cOper

Method getObrig() Class CriticaB3F
Return self:cObrig

Method getAno() Class CriticaB3F
Return self:cAno

Method getComp() Class CriticaB3F
Return self:cComp

Method getRecno() Class CriticaB3F
Return self:nRecno

Method getTpVld() Class CriticaB3F
Return self:cTpVld

Method getCodANS() Class CriticaB3F
Return self:cCodANS

Method getChaveOri() Class CriticaB3F
Return self:cChaveOri

Method getDesOri() Class CriticaB3F
Return self:cDesOri

Method getStatus() Class CriticaB3F
Return self:cStatus

Method getObj() Class CriticaB3F
Return self:oEntity

Method Validar() Class CriticaB3F
Return .F.
