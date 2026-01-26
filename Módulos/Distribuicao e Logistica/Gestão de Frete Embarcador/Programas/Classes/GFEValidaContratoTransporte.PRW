#INCLUDE "PROTHEUS.CH" 

Function GFEValidaContratoTransporte()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEValidaContratoTransporte
Classe de Funções Relacionadas as tabelas de Rotas do Contrato de Transporte (GXU) e Contrato de Transporte (GXT)
Generica

@author Leandro Conradi Zmovirzynski
@since 09/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

CLASS GFEValidaContratoTransporte FROM LongNameClass
	DATA cVlrFixo
	DATA cVlrUnit
	DATA cVlrCarga
	DATA cCdtrp
	DATA cNrtab
	DATA cNrneg
	DATA cGXTFilial
	DATA cGXTNrCt
	DATA cGXTSit
	DATA cDtIRet
	DATA cDtFRet
	DATA cDtIEnt
	DATA cDtFEnt
	DATA lStatus
	DATA cMensage
	DATA cUMPeso
	DATA aUMPeso
	DATA cFrtPes
	DATA cUniMed
	DATA dDataEnvio
	DATA dDataConfirmacao
	DATA dDataEncerramento
	DATA cMotivoCancelamento


	METHOD New() CONSTRUCTOR
	METHOD Validar()
	METHOD ValidarRotas()
	METHOD Destroy(oObject)
	METHOD ClearData()
	METHOD saveGXT()
	METHOD ValidaUMPeso()	

	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensage)
	METHOD setVlrFixo(cVlrFixo)
	METHOD setVlrUnit(cVlrUnit)
	METHOD setVlrCarga(cVlrCarga)
	METHOD setCdtrp(cCdtrp)
	METHOD setNrtab(cNrtab)
	METHOD setNrneg(cNrneg)
	METHOD setGXTFilial(cGXTFilial)
	METHOD setGXTNrCt(cGXTNrCt)
	METHOD setGXTSit(cGXTSit)
	METHOD setDtIRet(cDtIRet)
	METHOD setDtFRet(cDtFRet)
	METHOD setDtIEnt(cDtIEnt)
	METHOD setDtFEnt(cDtFEnt)
	METHOD setUMPeso(cUMPeso)
	METHOD setFrtPes(cFrtPes)
	METHOD setUniMed(cUnimed)
	METHOD setDataEnvio(dDataEnvio)
	METHOD setDataConfirmacao(dDataConfirmacao)
	METHOD setDataEncerramento(dDataEncerramento)
	METHOD setMotivoCancelamento(cMotivoCancelamento)		

	METHOD getStatus()
	METHOD getMensagem()
	METHOD getVlrFixo()
	METHOD getVlrUnit()
	METHOD getVlrCarga()
	METHOD getCdtrp()
	METHOD getNrtab()
	METHOD getNrneg()
	METHOD getGXTFilial()
	METHOD getGXTNrCt()
	METHOD getGXTSit()
	METHOD getDtIRet()
	METHOD getDtFRet()
	METHOD getDtIEnt()
	METHOD getDtFEnt()
	METHOD getUMPeso()
	METHOD getFrtPes()
	METHOD getUniMed()
	METHOD getDataEnvio()
	METHOD getDataConfirmacao()
	METHOD getDataEncerramento()
	METHOD getMotivoCancelamento()	
ENDCLASS

METHOD New() Class GFEValidaContratoTransporte
	Self:ClearData()
	
	Self:aUMPeso	:= {}
	Self:cUMPeso	:= ""
Return

METHOD ClearData() Class GFEValidaContratoTransporte
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:setVlrFixo("")
	Self:setVlrUnit("")
	Self:setVlrCarga("")
	Self:setCdtrp("")
	Self:setNrtab("")
	Self:setNrneg("")
	Self:setDtIRet("")
	Self:setDtFRet("")
	Self:setDtIEnt("")
	Self:setDtFEnt("")
	Self:setFrtPes("")
	Self:setUniMed("")
	Self:setDataEnvio(CtoD(""))
	Self:setDataConfirmacao(CtoD(""))
	Self:setDataEncerramento(CtoD(""))
	Self:setMotivoCancelamento("")
	
	// O método setUMPeso não deve ser chamado nesta função, pois o mesmo adiciona valor a um array	
Return

METHOD Destroy(oObject) CLASS GFEValidaContratoTransporte
	FreeObj(oObject)
Return

METHOD Validar() CLASS GFEValidaContratoTransporte
    
	// Validação do Transportador
	If !ExistCpo("GU3",Self:getCdtrp())
		Self:setStatus(.F.)
		Self:setMensagem("É necessário informar um Transportador válido.")
		Return
	Endif
    
	// Validação da Tabela de Frete
	If Alltrim(Self:getNrtab()) != ""
		If !GFEExistC("GVA",1,Self:getCdtrp()+Self:getNrtab(),"GVA_CDEMIT == GXT_CDTRP") 
			Self:setStatus(.F.)
			Self:setMensagem("É necessário informar uma Tabela de Frete válida.")
			Return
		Endif
	EndIf    

	// Validação da Negociação
	If Alltrim(Self:getNrtab()) != "" .And. Alltrim(Self:getNrneg())!= ""
		If !GFEExistC("GV9", 1, Self:getCdtrp()+Self:getNrtab()+Self:getNrneg(), "GV9->GV9_SIT=='2'") 
			Self:setStatus(.F.)
			Self:setMensagem("É necessário informar uma negociação válida.")
			Return
		Endif
	EndIf
	
	// Validação Data de Retirada
	If !Empty(Self:getDtIRet()) .And. !Empty(Self:getDtFRet())
		If Self:getDtIRet() > Self:getDtFRet()
			Self:setStatus(.F.)
			Self:setMensagem("A Data Inicial de Retirada deve ser menor ou igual a Data Final de Retirada.")
			Return
		EndIf
	EndIf
	
	// Validação Data de Entrega
	If !Empty(Self:getDtIEnt()) .And. !Empty(Self:getDtFEnt())
		If Self:getDtIEnt() > Self:getDtFEnt()
			Self:setStatus(.F.)
			Self:setMensagem("A Data Inicial de Entrega deve ser menor ou igual a Data Final de Entrega.")
			Return
		EndIf
	EndIf
	
	// Validação Data de Entrega
	If !Empty(Self:getDtIEnt()) .And. !Empty(Self:getDtIRet())
		If Self:getDtIEnt() < Self:getDtIRet()
			Self:setStatus(.F.)
			Self:setMensagem("A Data Inicial de Entrega deve ser maior ou igual a Data Inicial de Retirada.")
			Return
		EndIf
	EndIf
	
	// Validação Data de Entrega
	If !Empty(Self:getDtFEnt()) .And. !Empty(Self:getDtFRet())
		If Self:getDtFEnt() < Self:getDtFRet()
			Self:setStatus(.F.)
			Self:setMensagem("A Data Final de Entrega deve ser maior ou igual a Data Final de Retirada.")
			Return
		EndIf
	EndIf	
Return

METHOD ValidarRotas() CLASS GFEValidaContratoTransporte
	// Validação do Valor
    Local nCount
    
	nCount := 0
	nCount := If(!Empty(Self:getVlrCarga()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getVlrFixo()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getVlrUnit()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getFrtPes()), nCount + 1, nCount)
	
	If nCount == 0
		Self:setStatus(.F.)
    	Self:setMensagem("É necessário informar um Valor.")
    	Return
	EndIf
	
	If nCount > 1
		Self:setStatus(.F.)
    	Self:setMensagem("Só é permitido informar um tipo de Valor: Fixo, Unitário ou Carga.")
    	Return
	EndIf
	
	If (Empty(Self:getUMPeso()) .And. Empty(Self:getUniMed()))
		Self:setStatus(.F.)
		Self:setMensagem("É necessário informar ao menos uma unidade de medida.")
		Return
	EndIf
	
Return

METHOD saveGXT() CLASS GFEValidaContratoTransporte
	GXT->(dbSetOrder(1))
	
	If GXT->( dbSeek(self:getGXTFilial() + self:getGXTNrCt()) )
		RecLock("GXT",.F.)
		GXT->GXT_SIT 	:= Self:getGXTSIT()
		GXT->GXT_DATENV := Self:getDataEnvio()
		GXT->GXT_DATCFG := Self:getDataConfirmacao()
		GXT->GXT_DATENC := Self:getDataEncerramento()
		GXT->GXT_MOTCAN := Self:getMotivoCancelamento()
		GXT->(MsUnLock())		
		Self:setStatus(.T.)
    	Self:setMensagem("")
	Else
		Self:setStatus(.F.)
   		Self:setMensagem("Contrato de Tranporte não encontrado.")
	EndIf
Return

METHOD ValidaUMPeso() CLASS GFEValidaContratoTransporte
	Local nX		:= 0
	Local cUmPeso	:= ""
	
	For nX := 1 To Len(Self:aUMPeso)
		If Empty(cUmPeso)
			cUmPeso	:= Self:aUMPeso[nX]
		Else
			If cUmPeso != Self:aUMPeso[nX]
				Self:setStatus(.F.)
				Self:setMensagem("A unidade de Peso das rotas deve ser a mesma em todas as rotas.")
			EndIf
		EndIf
	Next nX
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFEValidaContratoTransporte
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensage) CLASS GFEValidaContratoTransporte
   Self:cMensage := cMensage
Return

METHOD setVlrFixo(cVlrFixo) CLASS GFEValidaContratoTransporte
   Self:cVlrFixo := cVlrFixo
Return

METHOD setVlrUnit(cVlrUnit) CLASS GFEValidaContratoTransporte
   Self:cVlrUnit := cVlrUnit
Return

METHOD setVlrCarga(cVlrCarga) CLASS GFEValidaContratoTransporte
   Self:cVlrCarga := cVlrCarga
Return

METHOD setCdtrp(cCdtrp) CLASS GFEValidaContratoTransporte
   Self:cCdtrp := cCdtrp
Return

METHOD setNrtab(cNrtab) CLASS GFEValidaContratoTransporte
   Self:cNrtab := cNrtab
Return

METHOD setNrneg(cNrneg) CLASS GFEValidaContratoTransporte
   Self:cNrneg := cNrneg
Return

METHOD setGXTFilial(cGXTFilial) CLASS GFEValidaContratoTransporte
	Self:cGXTFilial := cGXTFilial
Return

METHOD setGXTNrCt(cGXTNrCt) CLASS GFEValidaContratoTransporte
	Self:cGXTNrCt := cGXTNrCt
Return

METHOD setGXTSit(cGXTSit) CLASS GFEValidaContratoTransporte
	Self:cGXTSit := cGXTSit
Return

METHOD setDtIRet(cDtIRet) CLASS GFEValidaContratoTransporte
	Self:cDtIRet := cDtIRet
Return

METHOD setDtFRet(cDtFRet) CLASS GFEValidaContratoTransporte
	Self:cDtFRet := cDtFRet
Return

METHOD setDtIEnt(cDtIEnt) CLASS GFEValidaContratoTransporte
	Self:cDtIEnt := cDtIEnt
Return

METHOD setDtFEnt(cDtFEnt) CLASS GFEValidaContratoTransporte
	Self:cDtFEnt := cDtFEnt
Return

METHOD setUMPeso(cUMPeso) CLASS GFEValidaContratoTransporte
	Self:cUMPeso := cUMPeso
	
	Aadd(Self:aUMPeso,cUMPeso)
Return

METHOD setFrtPes(cFrtPes) CLASS GFEValidaContratoTransporte
	Self:cFrtPes := cFrtPes
Return

METHOD setUniMed(cUniMed) CLASS GFEValidaContratoTransporte
	Self:cUniMed := cUniMed
Return

METHOD setDataEnvio(dDataEnvio) CLASS GFEValidaContratoTransporte
	Self:dDataEnvio := dDataEnvio
Return

METHOD setDataConfirmacao(dDataConfirmacao) CLASS GFEValidaContratoTransporte
	Self:dDataConfirmacao := dDataConfirmacao
Return

METHOD setDataEncerramento(dDataEncerramento) CLASS GFEValidaContratoTransporte
	Self:dDataEncerramento := dDataEncerramento
Return

METHOD setMotivoCancelamento(cMotivoCancelamento) CLASS GFEValidaContratoTransporte	
	Self:cMotivoCancelamento := cMotivoCancelamento
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFEValidaContratoTransporte
Return Self:lStatus

METHOD getMensagem() CLASS GFEValidaContratoTransporte
Return Self:cMensage

METHOD getVlrFixo() CLASS GFEValidaContratoTransporte
Return Self:cVlrFixo

METHOD getVlrUnit() CLASS GFEValidaContratoTransporte
Return Self:cVlrUnit

METHOD getVlrCarga() CLASS GFEValidaContratoTransporte
Return Self:cVlrCarga

METHOD getCdtrp() CLASS GFEValidaContratoTransporte
Return Self:cCdtrp

METHOD getNrtab() CLASS GFEValidaContratoTransporte
Return Self:cNrtab

METHOD getNrneg() CLASS GFEValidaContratoTransporte
Return Self:cNrneg

METHOD getGXTFilial() CLASS GFEValidaContratoTransporte
Return Self:cGXTFilial

METHOD getGXTNrCt() CLASS GFEValidaContratoTransporte
Return Self:cGXTNrCt

METHOD getGXTSit() CLASS GFEValidaContratoTransporte
Return Self:cGXTSit

METHOD getDtIRet() CLASS GFEValidaContratoTransporte
Return Self:cDtIRet

METHOD getDtFRet() CLASS GFEValidaContratoTransporte
Return Self:cDtFRet

METHOD getDtIEnt() CLASS GFEValidaContratoTransporte
Return Self:cDtIEnt

METHOD getDtFEnt() CLASS GFEValidaContratoTransporte
Return Self:cDtFEnt

METHOD getUMPeso() CLASS GFEValidaContratoTransporte
Return Self:cUMPeso

METHOD getFrtPes() CLASS GFEValidaContratoTransporte
Return Self:cFrtPes

METHOD getUniMed() CLASS GFEValidaContratoTransporte
Return Self:cUniMed

METHOD getDataEnvio() CLASS GFEValidaContratoTransporte	
Return Self:dDataEnvio

METHOD getDataConfirmacao() CLASS GFEValidaContratoTransporte	
Return Self:dDataConfirmacao

METHOD getDataEncerramento() CLASS GFEValidaContratoTransporte
Return Self:dDataEncerramento

METHOD getMotivoCancelamento() CLASS GFEValidaContratoTransporte
Return Self:cMotivoCancelamento