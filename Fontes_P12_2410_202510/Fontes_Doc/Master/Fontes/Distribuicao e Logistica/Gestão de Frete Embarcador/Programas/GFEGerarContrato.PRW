#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFEGerarContrato()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEGerarContrato()

@author Leonardo Ribas Jimenez Hernandez
@since 18/05/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEGerarContrato FROM LongNameClass 
	
	DATA cIdReq
	DATA cUsuNegoc
	DATA cNrCt
	DATA cDtCt
	DATA cUsuar
	DATA cCdTrp
	DATA cCdClfr
	DATA cCdTpop
	DATA cDtIRet
	DATA cDtFret
	DATA cDtFent
	DATA cNrTab
	DATA cNrNeg
	DATA cPesot
	DATA cQtDet
	DATA cSeq
	DATA cNrCido
	DATA cNrCidd
	DATA cUnimed
	DATA cVlUni
	DATA cImpinc
	DATA cFilCt
	DATA lStatus
	DATA cMensagem
	DATA cErroMensagem
	DATA cObsCga
	DATA cObsDga
	DATA cUniQtd
	DATA cFrtQtd

	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy(oObject)
	
	METHOD ValidarRegistrarContrato()
	METHOD GravarContrato()
	   
	METHOD setIdReq(cIdReq)
	METHOD setUsuNegoc(cUsuNegoc)
	METHOD setNrCt(cNrCt)
	METHOD setDtCt(cDtCt)
	METHOD setUsuar(cUsuar)
	METHOD setCdTrp(cCdTrp)
	METHOD setCdClfr(cCdClfr)
	METHOD setCdTpop(cCdTpop)
	METHOD setDtIRet(cDtIRet)
	METHOD setDtFret(cDtFret)
	METHOD setDtFent(cDtFent)
	METHOD setNrTab(cNrTab)
	METHOD setNrNeg(cNrNeg)
	METHOD setPesot(cPesot)
	METHOD setQtDet(cQtDet)
	METHOD setSeq(cSeq)
	METHOD setNrCido(cNrCido)
	METHOD setNrCidd(cNrCidd)
	METHOD setUnimed(cUnimed)
	METHOD setVlUni(cVlUni)
	METHOD setImpinc(cImpinc)
	METHOD setFilCt(cFilCt)
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setErroMensagem(cMensagem)
	METHOD setObsCga(cObsCga)
	METHOD setObsDga(cObsDga)
	METHOD setUniQtd(cUniQtd)
	METHOD setFrtQtd(cFrtQtd)
	
	METHOD getIdReq()
	METHOD getUsuNegoc()
	METHOD getNrCt()
	METHOD getDtCt()
	METHOD getUsuar()
	METHOD getCdTrp()
	METHOD getCdClfr()
	METHOD getCdTpop()
	METHOD getDtIRet()
	METHOD getDtFret()
	METHOD getDtFent()
	METHOD getNrTab()
	METHOD getNrNeg()
	METHOD getPesot()
	METHOD getQtDet()
	METHOD getSeq()
	METHOD getNrCido()
	METHOD getNrCidd()
	METHOD getUnimed()
	METHOD getVlUni()
	METHOD getImpinc()
	METHOD getFilCt()
	METHOD getStatus()
	METHOD getMensagem()
	METHOD getErroMensagem()
	METHOD getObsCga()
	METHOD getObsDga()
	METHOD getUniQtd()
	METHOD getFrtQtd()
ENDCLASS

METHOD New() Class GFEGerarContrato
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEGerarContrato
   FreeObj(oObject)
Return

METHOD ClearData() Class GFEGerarContrato
	Self:setIdReq("")
	Self:setUsuNegoc("")
	Self:setNrCt("")  
	Self:setDtCt("")  
	Self:setUsuar("") 
	Self:setCdTrp("") 
	Self:setCdClfr("")
	Self:setCdTpop("")
	Self:setDtIRet("")
	Self:setDtFret("")
	Self:setDtFent("")
	Self:setNrTab("") 
	Self:setNrNeg("") 
	Self:setPesot("") 
	Self:setQtDet("") 
	Self:setSeq("")   
	Self:setNrCido("")
	Self:setNrCidd("")
	Self:setUnimed("")
	Self:setVlUni("") 
	Self:setImpinc("")
	Self:setFilCt("")
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:setErroMensagem("")
	Self:setObsCga("")
	Self:setObsDga("")
	Self:setUniQtd("")
	Self:setFrtQtd("")
Return

//-----------------------------------
// Métodos de Negócio
//-----------------------------------
METHOD ValidarRegistrarContrato() Class GFEGerarContrato
	Local nCount := 0
	
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			If !Empty(GXR->GXR_USUNEG) .And. (AllTrim(GXR->(GXR_USUNEG)) <> Self:getUsuNegoc())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição não está vinculada ao seu usuário.")
				Return
			EndIf
			If (GXR->(GXR_SIT) != "3" .Or. GXR->(GXR_SIT) != "4") .And. GXR->(GXR_FDADE) != "2"  
				Self:setStatus(.F.)
				Self:setMensagem("A requisição deve estar em estado Em negociação ou Atendida e sua finalidade deve ser Contratação. Apenas nessas situações podem ser registrado os contratos.")
				Return
			EndIf
		EndIf
		
		GXS->(dbSetOrder())
		If GXS->(dbSeek(xFilial("GXS") + Self:getIdReq()))
			While !GXS->(Eof()) .And. GXS->GXS_IDREQ == Self:getIdReq()  
				If GXS->GXS_MRKBR
					nCount += 1
				EndIf 
				GXS->(dbSkip())
			EndDo
		Else
			Self:setStatus(.F.)				
			Self:setMensagem("Não existe nenhuma cotação para esta requisição. É necessário selecionar uma cotação para poder registrar o contrato.")
			Return
		EndIf
		If nCount == 0
			Self:setStatus(.F.)				
			Self:setMensagem("É necessário selecionar uma cotação para poder gerar o contrato.")
			Return
		EndIf
		
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD GravarContrato() Class GFEGerarContrato
	Local oModel := FwLoadModel("GFEA079")	
	Local oModelGXT := oModel:GetModel("GFEA079_GXT")
	Local oModelGXU := oModel:GetModel("GFEA079_GXU")
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	// CONTRATO
	Self:setNrCt(oModelGXT:GetValue("GXT_NRCT"))
	
	If !oModelGXT:SetValue("GXT_DTCT",StoD(Self:getDtCt()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_USUAR",AllTrim(Self:getUsuar()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_CDTRP",AllTrim(Self:getCdTrp()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_CDCLFR",AllTrim(Self:getCdClfr()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_CDTPOP",AllTrim(Self:getCdTpop()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_DTIRET",Self:getDtIRet())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_DTFRET",Self:getDtFret())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_DTFENT",Self:getDtFent())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_NRTAB",AllTrim(Self:getNrTab()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_NRNEG",AllTrim(Self:getNrNeg()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_OBSCGA",AllTrim(Self:getObsCga()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXT:SetValue("GXT_OBSDGA",AllTrim(Self:getObsDga()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	// ROTAS
	If !oModelGXU:SetValue("GXU_NRCT",AllTrim(Self:getNrCt()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_PESOT",Self:getPesot())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_QTDET",Self:getQtDet())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_SEQ",PADL(AllTrim(Self:getSeq()),TamSX3("GXU_SEQ")[1],"0"))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_NRCIDO",AllTrim(Self:getNrCido()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_NRCIDD",AllTrim(Self:getNrCidd()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_UNIMED",AllTrim(Self:getUniQtd()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !Empty(Self:getFrtQtd()) .And. !oModelGXU:SetValue("GXU_VLUNI",Self:getFrtQtd())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_IMPINC",AllTrim(Self:getImpinc()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !oModelGXU:SetValue("GXU_UMPESO",AllTrim(Self:getUniMed()))
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus() .And. !Empty(Self:getVlUni()) .And. !oModelGXU:SetValue("GXU_FRTPES",Self:getVlUni())
		Self:setStatus(.F.)
		Self:setErroMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	Self:setMensagem("Contrato " + AllTrim(Self:getNrCt()) + " ")
	If Self:getStatus()
		If oModelGXU:VldLineData()
			If oModel:VldData()
				oModel:CommitData()
			Else
				Self:setStatus(.F.)
				Self:setErroMensagem(oModel:getErrorMessage()[6])
			EndIf
		Else 
			Self:setStatus(.F.)
			Self:setErroMensagem(oModel:getErrorMessage()[6])
		EndIf
	EndIf
	
	oModel:DeActivate()

Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setIdReq(cIdReq) CLASS GFEGerarContrato
   Self:cIdReq := cIdReq
Return

METHOD setUsuNegoc(cUsuNegoc) CLASS GFEGerarContrato
   Self:cUsuNegoc := cUsuNegoc
Return

METHOD setNrCt(cNrCt) CLASS GFEGerarContrato
   Self:cNrCt := cNrCt
Return

METHOD setDtCt(cDtCt) CLASS GFEGerarContrato
   Self:cDtCt := cDtCt
Return

METHOD setUsuar(cUsuar) CLASS GFEGerarContrato
   Self:cUsuar := cUsuar
Return

METHOD setCdTrp(cCdTrp) CLASS GFEGerarContrato
   Self:cCdTrp := cCdTrp
Return

METHOD setCdClfr(cCdClfr) CLASS GFEGerarContrato
   Self:cCdClfr := cCdClfr
Return

METHOD setCdTpop(cCdTpop) CLASS GFEGerarContrato
   Self:cCdTpop := cCdTpop
Return

METHOD setDtIRet(cDtIRet) CLASS GFEGerarContrato
   Self:cDtIRet := cDtIRet
Return

METHOD setDtFret(cDtFret) CLASS GFEGerarContrato
   Self:cDtFret := cDtFret
Return

METHOD setDtFent(cDtFent) CLASS GFEGerarContrato
   Self:cDtFent := cDtFent
Return

METHOD setNrTab(cNrTab) CLASS GFEGerarContrato
   Self:cNrTab := cNrTab
Return

METHOD setNrNeg(cNrNeg) CLASS GFEGerarContrato
   Self:cNrNeg := cNrNeg
Return

METHOD setPesot(cPesot) CLASS GFEGerarContrato
   Self:cPesot := cPesot
Return

METHOD setQtDet(cQtDet) CLASS GFEGerarContrato
   Self:cQtDet := cQtDet
Return

METHOD setSeq(cSeq) CLASS GFEGerarContrato
   Self:cSeq := cSeq
Return

METHOD setNrCido(cNrCido) CLASS GFEGerarContrato
   Self:cNrCido := cNrCido
Return

METHOD setNrCidd(cNrCidd) CLASS GFEGerarContrato
   Self:cNrCidd := cNrCidd
Return

METHOD setUnimed(cUnimed) CLASS GFEGerarContrato
   Self:cUnimed := cUnimed
Return

METHOD setVlUni(cVlUni) CLASS GFEGerarContrato
   Self:cVlUni := cVlUni
Return

METHOD setImpinc(cImpinc) CLASS GFEGerarContrato
   Self:cImpinc := cImpinc
Return

METHOD setFilCt(cFilCt) CLASS GFEGerarContrato
   Self:cFilCt := cFilCt
Return

METHOD setStatus(lStatus) CLASS GFEGerarContrato
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFEGerarContrato
   Self:cMensagem := cMensagem
Return

METHOD setErroMensagem(cErroMensagem) CLASS GFEGerarContrato
   Self:cErroMensagem := cErroMensagem
Return

METHOD setObsCga(cObsCga) CLASS GFEGerarContrato
   Self:cObsCga := cObsCga
Return

METHOD setObsDga(cObsDga) CLASS GFEGerarContrato
   Self:cObsDga := cObsDga
Return

METHOD setUniQtd(cUniQtd) CLASS GFEGerarContrato
   Self:cUniQtd := cUniQtd
Return

METHOD setFrtQtd(cFrtQtd) CLASS GFEGerarContrato
   Self:cFrtQtd := cFrtQtd
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getIdReq() CLASS GFEGerarContrato
Return Self:cIdReq

METHOD getUsuNegoc() CLASS GFEGerarContrato
Return Self:cUsuNegoc

METHOD getNrCt() CLASS GFEGerarContrato
Return Self:cNrCt

METHOD getDtCt() CLASS GFEGerarContrato
Return Self:cDtCt

METHOD getUsuar() CLASS GFEGerarContrato
Return Self:cUsuar

METHOD getCdTrp() CLASS GFEGerarContrato
Return Self:cCdTrp

METHOD getCdClfr() CLASS GFEGerarContrato
Return Self:cCdClfr

METHOD getCdTpop() CLASS GFEGerarContrato
Return Self:cCdTpop

METHOD getDtIRet() CLASS GFEGerarContrato
Return Self:cDtIRet

METHOD getDtFret() CLASS GFEGerarContrato
Return Self:cDtFret

METHOD getDtFent() CLASS GFEGerarContrato
Return Self:cDtFent

METHOD getNrTab() CLASS GFEGerarContrato
Return Self:cNrTab

METHOD getNrNeg() CLASS GFEGerarContrato
Return Self:cNrNeg

METHOD getPesot() CLASS GFEGerarContrato
Return Self:cPesot

METHOD getQtDet() CLASS GFEGerarContrato
Return Self:cQtDet

METHOD getSeq() CLASS GFEGerarContrato
Return Self:cSeq

METHOD getNrCido() CLASS GFEGerarContrato
Return Self:cNrCido

METHOD getNrCidd() CLASS GFEGerarContrato
Return Self:cNrCidd

METHOD getUnimed() CLASS GFEGerarContrato
Return Self:cUnimed

METHOD getVlUni() CLASS GFEGerarContrato
Return Self:cVlUni

METHOD getImpinc() CLASS GFEGerarContrato
Return Self:cImpinc

METHOD getFilCt() CLASS GFEGerarContrato
Return Self:cFilCt

METHOD getStatus() CLASS GFEGerarContrato
Return Self:lStatus

METHOD getMensagem() CLASS GFEGerarContrato
Return Self:cMensagem

METHOD getErroMensagem() CLASS GFEGerarContrato
Return Self:cErroMensagem

METHOD getObsCga() CLASS GFEGerarContrato
Return Self:cObsCga

METHOD getObsDga() CLASS GFEGerarContrato
Return Self:cObsDga

METHOD getUniQtd() CLASS GFEGerarContrato
Return Self:cUniQtd

METHOD getFrtQtd() CLASS GFEGerarContrato
Return Self:cFrtQtd