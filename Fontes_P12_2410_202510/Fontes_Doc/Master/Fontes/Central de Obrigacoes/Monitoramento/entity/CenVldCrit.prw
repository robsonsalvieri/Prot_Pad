#Include "TOTVS.CH"

#DEFINE VALIDO "2"
#DEFINE INVALIDO "3"
#DEFINE ARQUIVO_LOG	"logs_gerais_monitoramento"
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldCrit
Descricao: 	Classe responsável por realizar as validações das Criticas
				das Obrigações da Central de Obrigações

				Obrigações atendidas até o momento:
				-> MONITORAMENTO TISS - Hermiro Jr 01/10/2019

@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------		
Class CenVldCrit

	Data aCritInd
	Data aCritGrp
	Data cOper
	Data cObrig
	Data cAno
	Data cComp
	Data oEntity
	Data oCenLogger

	Method New() Constructor
	Method destroy()
	Method setOper(cOper)
	Method setObrig(cObrig)
	Method setAno(cAno)
	Method setComp(cComp)
	Method getOper()
	Method getObrig()
	Method getAno()
	Method getComp()
	Method getCritInd()
	Method getCritGrp()
	Method validar()
	Method AlterCrit()
	Method AddCrit(oCritica)
	Method vldGrupo(oCollection)
	Method vldIndiv(oCollection)
	Method setEntity(oEntity)
	Method initCritInd()
	Method initCritGrp()

EndClass

Method New() Class CenVldCrit
	
	self:initCritInd()
	self:initCritGrp()
	self:oCenLogger := CenLogger():New()
	self:oCenLogger:setFileName(ARQUIVO_LOG)

Return self

Method Destroy() Class CenVldCrit
Return

Method initCritInd() Class CenVldCrit
Return

Method initCritGrp() Class CenVldCrit
Return

Method setOper(cOper) Class CenVldCrit
	self:cOper := cOper
Return

Method setObrig(cObrig) Class CenVldCrit
	self:cObrig := cObrig
Return

Method setAno(cAno) Class CenVldCrit
	self:cAno := cAno
Return

Method setComp(cComp) Class CenVldCrit
	self:cComp := cComp
Return

Method getOper() Class CenVldCrit
Return self:cOper

Method getObrig() Class CenVldCrit
Return self:cObrig

Method getAno() Class CenVldCrit
Return self:cAno

Method getComp() Class CenVldCrit
Return self:cComp

Method getCritInd() Class CenVldCrit
Return self:aCritInd

Method getCritGrp() Class CenVldCrit
Return self:aCritGrp

Method validar() Class CenVldCrit
	Local lValido := .T.	
	
	lValido := self:vldGrupo()
	//lValido := lValido .AND. self:vldIndiv()
	
Return lValido

Method vldGrupo(oCollection) Class CenVldCrit
	Local lValido		:= .T.	
	Local aCriticas 	:= self:getCritGrp()
	Local nLen 			:= len(aCriticas)
	Local oCltCrit		:= CenCltCrit():New()
	Local nCritica		:= 0  
	
	For nCritica := 1 to nLen

		oCltCrit:setValue("operatorRecord",self:getOper())
		oCltCrit:setValue("requirementCode",self:getObrig())
		oCltCrit:setValue("commitReferenceYear",self:getAno())
		oCltCrit:setValue("commitmentCode",self:getComp())
		oCltCrit:setValue("reviewOrigin",aCriticas[nCritica]:getAlias())
		oCltCrit:setValue("reviewCode",aCriticas[nCritica]:getCodCrit())
		oCltCrit:lmpCriticas()

		aCriticas[nCritica]:setOper(self:getOper())
		aCriticas[nCritica]:setObrig(self:getObrig())
		aCriticas[nCritica]:setAno(self:getAno())
		aCriticas[nCritica]:setComp(self:getComp())
		lValido := oCltCrit:insCritGrp(aCriticas[nCritica]:getQryCrit())
		If oCollection <> nil
			oCollection:atuStatGrp(INVALIDO,aCriticas[nCritica]:getAlias(),aCriticas[nCritica]:getWhereCrit())
		EndIf
	Next nCritica

Return lValido

Method vldIndiv(oCollection) Class CenVldCrit
	Local lValido 		:= .T.	
	Local aCriticas 	:= self:getCritInd()
	Local nLen 			:= len(aCriticas)
	Local oCltCrit		:= CenCltCrit():New()
	Local nCritica		:= 0  
	Local lCriticado	:= .F.

	For nCritica := 1 to nLen
		oCltCrit:setValue("operatorRecord",self:getOper())
		oCltCrit:setValue("requirementCode",self:getObrig())
		oCltCrit:setValue("commitReferenceYear",self:getAno())
		oCltCrit:setValue("commitmentCode",self:getComp())
		oCltCrit:setValue("reviewOrigin",aCriticas[nCritica]:getAlias())
		oCltCrit:setValue("reviewCode",aCriticas[nCritica]:getCodCrit())	
		
		oCltCrit:setValue("originIdentKey",self:oEntity:getIdeOri())	
		oCltCrit:setValue("originDescription",self:oEntity:getDesOri())	
		
		aCriticas[nCritica]:setEntity(self:oEntity)
		aCriticas[nCritica]:setChaveOri(self:oEntity:getIdeOri())
		aCriticas[nCritica]:setDesOri(self:oEntity:getDesOri())
		
		lValido := aCriticas[nCritica]:validar()
		If lValido
			self:AlterCrit(aCriticas[nCritica])
		Else
			lCriticado := .T.
			self:AddCrit(aCriticas[nCritica])
		EndIf

	Next nCritica

	If oCollection <> nil .AND. self:oEntity:getValue("status") <> INVALIDO
		oCollection:atuStatusByRecno(IIf(lCriticado,INVALIDO, VALIDO), oCollection:getDbRecno())
	EndIf

	If oCollection <> nil .AND. oCollection:oDao:CALIAS $ "BKS/BKR/BVQ/BVT"  .And. (lCriticado .Or. self:oEntity:getValue("status") == INVALIDO)

		If oCollection:oDao:CALIAS $ "BKS/BKR"
			nRec:=oCollection:VerCritBKR(self:cOper,self:COBRIG,self:CANO,self:cComp,self:oEntity:getValue("operatorFormNumber"))
		Else	
			nRec:=oCollection:VerCritBVT(self:cOper,self:COBRIG,self:CANO,self:cComp,self:oEntity:getValue("providerFormNumber"))
		EndIf

		If  nRec > 0 
			oCollection:atuStatGrp(INVALIDO,  IIF(oCollection:oDao:CALIAS $ "BKR/BKS","BKR","BVQ")," AND R_E_C_N_O_ = "+cValToChar(nRec)+" "  )
		EndIf

	EndIf

Return lValido

Method AlterCrit(oCritica) Class CenVldCrit
	Local lRet			:= .T.
	Default oCritica	:= Nil

	If !Empty(oCritica)
		lRet	:= PlObCorCri(	self:GetOper(),;
									self:getObrig(),;
									self:getAno(),;
									self:getComp(),;
									oCritica:cAlias,;
									STR((oCritica:cAlias)->(Recno()), 10, 0),;
									oCritica:cCodCrit,;
									oCritica:cTpVld )
	EndIf

	If !lRet
		self:oCenLogger:SetFileName(ARQUIVO_LOG)
		self:oCenLogger:addLine("observacao", 'Critica não corrigida.')
		self:oCenLogger:addLog()
		self:oCenLogger:flush()
	EndIf

Return lRet

Method AddCrit(oCritica) Class CenVldCrit
	Local lRet			:= .T.
	Local oCenLogger	:= CenLogger():New()	
	Default oCritica	:= Nil
	
	//-> Chama Rotina de Geração das Criticas NA B3F
	If !Empty(oCritica)
		// Chama Rotina Centralizadora Criadora de Criticas
		dbSelectArea('B3F')
		B3F->(DbSetOrder(7))
		lRet	:= PlObInCrit(	self:GetOper(),;
									self:getObrig(),;
									self:getAno(),;
									self:getComp(),;
									oCritica:cAlias,;
									STR((oCritica:cAlias)->(Recno()), 10, 0),;
									oCritica:cCodCrit,;
									oCritica:cMsgCrit,;
									oCritica:cSolCrit,;
									oCritica:cCpoCrit,;
									oCritica:cTpVld,;
									oCritica:cCodANS,;
									oCritica:cChaveOri,;
									oCritica:cDesOri,;
									oCritica:cStatus )
	EndIf

	If !lRet
		oCenLogger:SetFileName(ARQUIVO_LOG)
		oCenLogger:addLine("observacao", 'Critica não gerada.')
		oCenLogger:addLog()
		self:oCenLogger:flush()
	EndIf

	oCenLogger:destroy()
	FreeObj(oCenLogger)
	oCenLogger := nil	

Return lRet

Method setEntity(oEntity) Class CenVldCrit
	self:oEntity := oEntity
Return