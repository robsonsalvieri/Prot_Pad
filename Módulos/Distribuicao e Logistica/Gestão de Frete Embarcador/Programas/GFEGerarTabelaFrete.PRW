#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GFEGerarTabelaFrete()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEGerarTabelaFrete()

Método responsável por realizar a criação da tabela de frete com base nos dados setados pela rotina

@author João Leonardo Schmidt
@since 15/5/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEGerarTabelaFrete FROM LongNameClass 
	DATA lStatus
	DATA cComp
	DATA cMensagem
	DATA cSolucao
	
	DATA cCodTransp
	DATA cDtContrato
	DATA cNrTab
	DATA cDsTab
	
	DATA cCdClFr
	DATA cCdTpOp
	DATA cDtIniVal
	DATA cCompFreMin
	DATA cNrNeg
	DATA cCdFai
	DATA cUniFai
	DATA cNrRota
	DATA cTpTab
	DATA cTpLota
	DATA cSitNeg
	DATA cAdiImp
	DATA cEnvApr

	DATA aTrechos
	DATA aComponentes
	DATA aCpTre

	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy(oObject)
   
	METHOD VlFixBuscarComp()
	METHOD VlUniBuscarComp()
	METHOD VlPerBuscarComp()
	METHOD NrTabBuscarProx()
	METHOD NrNegBuscarProx()
	METHOD CdFaiBuscarProx()
	METHOD NrRotaBuscarProx()
	METHOD ContAprovNeg()
	
	METHOD TabCriaReg()
	METHOD NegCriaReg()
	METHOD TarifCriaReg()
   
	METHOD setStatus(lStatus)
	METHOD setComp(cComp)
	METHOD setMensagem(cMensagem)
	METHOD setSolucao(cSolucao)
	
	METHOD setCodTransp(cCodTransp)
    METHOD setDtContrato(cDtContrato)
    METHOD setNrTab(cNrTab)
    METHOD setDsTab(cDsTab)
    
    METHOD setCdClFr(cCdClFr)
    METHOD setCdTpOp(cCdTpOp)
    METHOD setDtIniVal(cDtIniVal)
    METHOD setCompFreMin(cCompFreMin)
    METHOD setNrNeg(cNrNeg)
    METHOD setCdFai(cCdFai)
    METHOD setUniFai(cUniFai)
    METHOD setNrRota(cNrRota)
    METHOD setTpTab(cTpTab)
    METHOD setTpLota(cTpLota)
    METHOD setSitNeg(cSitNeg)
    METHOD setAdiImp(cAdiImp)
    METHOD setEnvApr(cEnvApr)
        
    METHOD setAddTrechos(aTrechos)
    METHOD setAddComponentes(aComponentes)
    METHOD setAddCpTre(aCpTre)
       
	METHOD getStatus()
	METHOD getComp()
	METHOD getMensagem()
	METHOD getSolucao()
	
	METHOD getCodTransp()
	METHOD getDtContrato()
	METHOD getNrTab()
	METHOD getDsTab()
	
	METHOD getCdClFr()
	METHOD getCdTpOp()
	METHOD getDtIniVal()
	METHOD getCompFreMin()
	METHOD getNrNeg()
	METHOD getCdFai()
	METHOD getUniFai()
	METHOD getNrRota()
	METHOD getTpTab()
	METHOD getTpLota()
	METHOD getSitNeg()
	METHOD getAdiImp()
	METHOD getEnvApr()
				
	METHOD getTrechos()
	METHOD getComponentes()
	METHOD getCpTre()
ENDCLASS

// Método Construtor da classe
METHOD New() Class GFEGerarTabelaFrete
   Self:ClearData()
Return

// Método Destoy da classe
METHOD Destroy(oObject) CLASS GFEGerarTabelaFrete
   FreeObj(oObject)
Return

// Método para limpeza das variáveis da classe
METHOD ClearData() Class GFEGerarTabelaFrete
	Self:setStatus(.T.)
	Self:setComp("")
	Self:setMensagem("")
	Self:setSolucao("")
	
	Self:setCodTransp("")
	Self:setDtContrato("")
	Self:setNrTab("")
	Self:setDsTab("")
	
	Self:setCdClFr("")
	Self:setCdTpOp("")
	Self:setDtIniVal("")
	Self:setCompFreMin("")
	Self:setNrNeg("")
	Self:setCdFai("")
	Self:setUniFai("")
	Self:setNrRota("")
	Self:setTpTab("")
	Self:setTpLota("")
	Self:setSitNeg("")
	
	Self:aTrechos := {}
	Self:aComponentes := {}
	Self:aCpTre := {}
Return

//-----------------------------------
//Métodos de Negócio
//-----------------------------------
// Método responsável por buscar o componente relativo ao Valor Fixo
METHOD VlFixBuscarComp() Class GFEGerarTabelaFrete
	GV2->(dbSetOrder(1))
	GV2->(dbSeek(xFilial("GV2")))
	While GV2->(!EoF())
		If AllTrim(GV2->GV2_ATRCAL) == "8"
			Self:setComp(GV2->GV2_CDCOMP)
			Return
		EndIf
		
		GV2->(dbSkip())
	EndDo
	
	Self:setStatus(.F.)
	Self:setMensagem("Não foi encontrado nenhum componente que calcula sobre Valor Fixo!")
	Self:setSolucao("Para continuar o processe realize o cadastro de um componente que calcule sobre Valor Fixo.")	
Return

// Método responsável por buscar o componente relativo ao Frete Peso
METHOD VlUniBuscarComp() Class GFEGerarTabelaFrete
	GV2->(dbSetOrder(1))
	GV2->(dbSeek(xFilial("GV2")))
	While GV2->(!EoF())
		If AllTrim(GV2->GV2_ATRCAL) == "1"
			Self:setComp(GV2->GV2_CDCOMP)
			Return
		EndIf
		
		GV2->(dbSkip())
	EndDo
	
	Self:setStatus(.F.)
	Self:setMensagem("Não foi encontrado nenhum componente que calcula sobre Peso!")
	Self:setSolucao("Para continuar o processe realize o cadastro de um componente que calcule sobre Peso.")
Return

// Método responsável por buscar o componente relativo ao Valor Carga
METHOD VlPerBuscarComp() Class GFEGerarTabelaFrete
	GV2->(dbSetOrder(1))
	GV2->(dbSeek(xFilial("GV2")))
	While GV2->(!EoF())
		If AllTrim(GV2->GV2_ATRCAL) == "2"
			Self:setComp(GV2->GV2_CDCOMP)
			Return
		EndIf
		
		GV2->(dbSkip())
	EndDo
	
	Self:setStatus(.F.)
	Self:setMensagem("Não foi encontrado nenhum componente que calcula sobre Valor Carga!")
	Self:setSolucao("Para continuar o processe realize o cadastro de um componente que calcule sobre Valor Carga.")
Return

// Método responsável por buscar o próximo número de tabela
METHOD NrTabBuscarProx() Class GFEGerarTabelaFrete
	Local nI   := 1
	Local nTam := TamSX3("GVA_NRTAB")[1]
	Local nLim := ""
	Local nNum := ""
	
	nLim := Val(PADL(nLim,nTam,"9"))
	
	While nI < nLim
		nNum := PADL(nI,nTam,"0")
	
		GVA->(dbSetOrder(1))
		If !(GVA->(dbSeek(xFilial("GVA")+Self:getCodTransp()+nNum)))
			Self:setNrTab(nNum)
			Return
		EndIf
		
		nI++
	EndDo
Return

// Método responsável por buscar o próximo número de negociação
METHOD NrNegBuscarProx() Class GFEGerarTabelaFrete
	Local nI   := 1
	Local nTam := TamSX3("GV9_NRNEG")[1]
	Local nLim := ""
	Local nNum := ""
	
	nLim := Val(PADL(nLim,nTam,"9"))
	
	While nI < nLim
		nNum := PADL(nI,nTam,"0")
	
		GV9->(dbSetOrder(1))
		If !(GV9->(dbSeek(xFilial("GV9")+Self:getCodTransp()+Self:getNrTab()+nNum)))
			Self:setNrNeg(nNum)
			Return
		EndIf
		
		nI++
	EndDo
Return

// Método responsável por buscar o próximo código da faixa
METHOD CdFaiBuscarProx() Class GFEGerarTabelaFrete
	Local nI   := 1
	Local nTam := TamSX3("GV7_CDFXTV")[1]
	Local nLim := ""
	Local nNum := ""
	
	nLim := Val(PADL(nLim,nTam,"9"))
	
	While nI < nLim
		nNum := PADL(nI,nTam,"0")
	
		GV7->(dbSetOrder(1))
		If !(GV7->(dbSeek(xFilial("GV7")+Self:getCodTransp()+Self:getNrTab()+Self:getNrNeg()+nNum)))
			Self:setCdFai(nNum)
			Return
		EndIf
		
		nI++
	EndDo
Return

// Método responsável por buscar o próximo número de rota
METHOD NrRotaBuscarProx() Class GFEGerarTabelaFrete
	Local nI   := 1
	Local nTam := TamSX3("GV8_NRROTA")[1]
	Local nLim := ""
	Local nNum := ""
	
	nLim := Val(PADL(nLim,nTam,"9"))
	
	While nI < nLim
		nNum := PADL(nI,nTam,"0")
	
		GV8->(dbSetOrder(1))
		If !(GV8->(dbSeek(xFilial("GV8")+Self:getCodTransp()+Self:getNrTab()+Self:getNrNeg()+nNum)))
			Self:setNrRota(nNum)
			Return
		EndIf
		
		nI++
	EndDo
Return

// Método responsável por definir se o sistema está configurado para realizar a Aprovação da Tabela
METHOD ContAprovNeg() Class GFEGerarTabelaFrete
	Local cMV_APRTAB := SuperGetMV("MV_APRTAB",.F.,"2")
	
	If cMV_APRTAB == "2"
		Self:setSitNeg("2")
		Self:setEnvApr("2")
	Else
		Self:setEnvApr("1")
	EndIf
Return

// Método responsável por realizar a criação da Tabela (GVA)
METHOD TabCriaReg() Class GFEGerarTabelaFrete
	Local oModel    := FwLoadModel("GFEA061")
	Local oModelGVA := oModel:GetModel("GFEA061_GVA")
		
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	Self:NrTabBuscarProx()
	
	If !oModelGVA:SetValue("GVA_CDEMIT",AllTrim(Self:getCodTransp()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGVA:SetValue("GVA_NRTAB",AllTrim(Self:getNrTab()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGVA:SetValue("GVA_DSTAB",AllTrim(Self:getDsTab()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGVA:SetValue("GVA_TPTAB",AllTrim(Self:getTpTab()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGVA:SetValue("GVA_DTNEG",SToD(Self:getDtContrato()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	If Self:getStatus()
		If oModel:VldData()
			oModel:CommitData()
		Else
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
	EndIf
	
	oModel:DeActivate()
Return

// Método responsável por realizar a criação da Negociação (GV9, GV8, GV7 e GUY)
METHOD NegCriaReg() Class GFEGerarTabelaFrete
	Local oModel    := FwLoadModel("GFEA061A")
	Local oModelGV9 := oModel:GetModel("GFEA061A_GV9")
	Local oModelGV8 := oModel:GetModel("DETAIL_GV8")
	Local oModelGV7 := oModel:GetModel("DETAIL_GV7")
	Local oModelGUY := oModel:GetModel("DETAIL_GUY")
	Local nI		:= 1
	Local aCompsGUY := Self:getComponentes()
	Local aTreGV8	:= Self:getTrechos()
	Local cNrRota   := ""
	Local nTam 		:= TamSX3("GV8_NRROTA")[1]
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	// Preenchendo a Negociação (GV9)
	Self:NrNegBuscarProx()
	
	If !oModelGV9:SetValue("GV9_NRNEG",AllTrim(Self:getNrNeg()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	Self:ContAprovNeg()
	
	If Self:getStatus() .And. !Empty(Self:getSitNeg()) .And. !oModelGV9:SetValue("GV9_SIT",AllTrim(Self:getSitNeg()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_CDCLFR",AllTrim(Self:getCdClFr()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_CDTPOP",AllTrim(Self:getCdTpOp()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_DTVALI",SToD(Self:getDtIniVal()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_TPLOTA",AllTrim(Self:getTpLota()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_UNIFAI",AllTrim(Self:getUniFai()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_COMMIN",AllTrim(Self:getCompFreMin()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_ADISS",AllTrim(Self:getAdiImp()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV9:SetValue("GV9_ADICMS",AllTrim(Self:getAdiImp()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	
	// Preenchendo os componentes (GUY)
	If Self:getStatus()
		For nI := 1 To Len(aCompsGUY)
			If nI > 1			
				oModelGUY:AddLine()
			EndIf
			
			If !oModelGUY:SetValue("GUY_CDCOMP",AllTrim(aCompsGUY[nI]))
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
		Next
	EndIf
	
	// Preenchendo a Faixa/Tipo de Veículo (GV7)
	Self:CdFaiBuscarProx()
	
	If Self:getStatus() .And. !oModelGV7:SetValue("GV7_CDFXTV",AllTrim(Self:getCdFai()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV7:SetValue("GV7_UNICAL",AllTrim(Self:getUniFai()))
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf
	If Self:getStatus() .And. !oModelGV7:SetValue("GV7_QTFXFI",999999999.99999)
		Self:setStatus(.F.)
		Self:setMensagem(oModel:getErrorMessage()[6])
	EndIf	
	
	// Preenchendo as rotas (GV8)
	If Self:getStatus()
		For nI := 1 To Len(aTreGV8)
			If nI == 1	
				Self:NrRotaBuscarProx()
			Else			
				oModelGV8:AddLine()
				cNrRota := PADL(nI,nTam,"0")
				Self:setNrRota(cNrRota)
			EndIf
			
			If Self:getStatus() .And. !oModelGV8:SetValue("GV8_NRROTA",AllTrim(Self:getNrRota()))
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV8:SetValue("GV8_TPORIG","1")
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV8:SetValue("GV8_NRCIOR",AllTrim(aTreGV8[nI][1]))
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV8:SetValue("GV8_TPDEST","1")
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV8:SetValue("GV8_NRCIDS",AllTrim(aTreGV8[nI][2]))
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
		Next
	EndIf
	
	If Self:getStatus()
		If oModel:VldData()
			oModel:CommitData()
		Else
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
	EndIf
	
	oModel:DeActivate()
Return

// Método responsável por realizar a criação da Tarifa (GV6 e GV1)
METHOD TarifCriaReg() Class GFEGerarTabelaFrete
	Local oModel    := FwLoadModel("GFEA061F")
	Local oModelGV6 := oModel:GetModel("GFEA061F_GV6")
	Local oModelGV1 := oModel:GetModel("DETAIL_GV1")
	Local aCpTreGV1	:= Self:getCpTre()
	Local nI 		:= 1
	
	For nI := 1 To Len(aCpTreGV1)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
			
		GV6->(dbSetOrder(1))
		If !(GV6->(dbSeek(xFilial("GV8")+Self:getCodTransp()+Self:getNrTab()+Self:getNrNeg()+aCpTreGV1[nI][1])))
			If !oModelGV6:SetValue("GV6_CDFXTV",AllTrim(Self:getCdFai()))
				Self:setStatus(.F.)
				Self:setMensagem("GV6" + oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV6:SetValue("GV6_NRROTA",PADL(AllTrim(aCpTreGV1[nI][1]),TamSX3("GV8_NRROTA")[1],"0"))
				Self:setStatus(.F.)
				Self:setMensagem("GV6" + oModel:getErrorMessage()[6])
			EndIf
			If Self:getStatus() .And. !oModelGV6:SetValue("GV6_CONSPZ","0")
				Self:setStatus(.F.)
				Self:setMensagem("GV6" + oModel:getErrorMessage()[6])
			EndIf
		EndIf						
			
		If Self:getStatus() .And. !oModelGV1:SetValue("GV1_CDCOMP",AllTrim(aCpTreGV1[nI][2]))
			Self:setStatus(.F.)
			Self:setMensagem("GV1" + oModel:getErrorMessage()[6])
		EndIf
		If Self:getStatus() .And. !Empty(aCpTreGV1[nI][3])
			If !oModelGV1:SetValue("GV1_VLFIXN",aCpTreGV1[nI][3])
				Self:setStatus(.F.)
				Self:setMensagem("GV1" + oModel:getErrorMessage()[6])
			EndIf
		EndIf
		If Self:getStatus() .And. !Empty(aCpTreGV1[nI][4])
			If !oModelGV1:SetValue("GV1_VLUNIN",aCpTreGV1[nI][4])
				Self:setStatus(.F.)
				Self:setMensagem("GV1" + oModel:getErrorMessage()[6])
			EndIf
		EndIf
		If Self:getStatus() .And. !Empty(aCpTreGV1[nI][5])
			If !oModelGV1:SetValue("GV1_PCNORM",aCpTreGV1[nI][5])
				Self:setStatus(.F.)
				Self:setMensagem("GV1" + oModel:getErrorMessage()[6])
			EndIf
		EndIf
			
		If Self:getStatus()
			If oModel:VldData()
				oModel:CommitData()
			Else
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
		EndIf
			
		oModel:DeActivate()
	Next
		
	If Self:getStatus() .And. Self:getEnvApr() == "1"
		GFEA61ENV()
	EndIf
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFEGerarTabelaFrete
   Self:lStatus := lStatus
Return

METHOD setComp(cComp) CLASS GFEGerarTabelaFrete
   Self:cComp := cComp
Return

METHOD setMensagem(cMensagem) CLASS GFEGerarTabelaFrete
   Self:cMensagem := cMensagem
Return

METHOD setSolucao(cSolucao) CLASS GFEGerarTabelaFrete
   Self:cSolucao := cSolucao
Return

METHOD setCodTransp(cCodTransp) CLASS GFEGerarTabelaFrete
   Self:cCodTransp := cCodTransp
Return

METHOD setDtContrato(cDtContrato) CLASS GFEGerarTabelaFrete
   Self:cDtContrato := cDtContrato
Return

METHOD setNrTab(cNrTab) CLASS GFEGerarTabelaFrete
   Self:cNrTab := cNrTab
Return

METHOD setDsTab(cDsTab) CLASS GFEGerarTabelaFrete
   Self:cDsTab := cDsTab
Return

METHOD setCdClFr(cCdClFr) CLASS GFEGerarTabelaFrete
   Self:cCdClFr := cCdClFr
Return

METHOD setCdTpOp(cCdTpOp) CLASS GFEGerarTabelaFrete
   Self:cCdTpOp := cCdTpOp
Return

METHOD setDtIniVal(cDtIniVal) CLASS GFEGerarTabelaFrete
   Self:cDtIniVal := cDtIniVal
Return

METHOD setCompFreMin(cCompFreMin) CLASS GFEGerarTabelaFrete
   Self:cCompFreMin := cCompFreMin
Return

METHOD setAddTrechos(aTrechos) CLASS GFEGerarTabelaFrete
   Aadd(Self:aTrechos,aTrechos)
Return

METHOD setAddComponentes(aComponentes) CLASS GFEGerarTabelaFrete
   Aadd(Self:aComponentes,aComponentes)
Return

METHOD setUniFai(cUniFai) CLASS GFEGerarTabelaFrete
   Self:cUniFai := cUniFai
Return

METHOD setNrNeg(cNrNeg) CLASS GFEGerarTabelaFrete
   Self:cNrNeg := cNrNeg
Return

METHOD setCdFai(cCdFai) CLASS GFEGerarTabelaFrete
   Self:cCdFai := cCdFai
Return

METHOD setAddCpTre(aCpTre) CLASS GFEGerarTabelaFrete
   Aadd(Self:aCpTre,aCpTre)
Return

METHOD setNrRota(cNrRota) CLASS GFEGerarTabelaFrete
   Self:cNrRota := cNrRota
Return

METHOD setTpTab(cTpTab) CLASS GFEGerarTabelaFrete
   Self:cTpTab := cTpTab
Return

METHOD setTpLota(cTpLota) CLASS GFEGerarTabelaFrete
   Self:cTpLota := cTpLota
Return

METHOD setSitNeg(cSitNeg) CLASS GFEGerarTabelaFrete
   Self:cSitNeg := cSitNeg
Return

METHOD setAdiImp(cAdiImp) CLASS GFEGerarTabelaFrete
   Self:cAdiImp := cAdiImp
Return

METHOD setEnvApr(cEnvApr) CLASS GFEGerarTabelaFrete
   Self:cEnvApr := cEnvApr
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFEGerarTabelaFrete
Return Self:lStatus

METHOD getComp() CLASS GFEGerarTabelaFrete
Return Self:cComp

METHOD getMensagem() CLASS GFEGerarTabelaFrete
Return Self:cMensagem

METHOD getSolucao() CLASS GFEGerarTabelaFrete
Return Self:cSolucao

METHOD getCodTransp() CLASS GFEGerarTabelaFrete
Return Self:cCodTransp

METHOD getDtContrato() CLASS GFEGerarTabelaFrete
Return Self:cDtContrato

METHOD getNrTab() CLASS GFEGerarTabelaFrete
Return Self:cNrTab

METHOD getDsTab() CLASS GFEGerarTabelaFrete
Return Self:cDsTab

METHOD getCdClFr() CLASS GFEGerarTabelaFrete
Return Self:cCdClFr

METHOD getCdTpOp() CLASS GFEGerarTabelaFrete
Return Self:cCdTpOp

METHOD getDtIniVal() CLASS GFEGerarTabelaFrete
Return Self:cDtIniVal

METHOD getCompFreMin() CLASS GFEGerarTabelaFrete
Return Self:cCompFreMin

METHOD getTrechos() CLASS GFEGerarTabelaFrete
Return Self:aTrechos

METHOD getComponentes() CLASS GFEGerarTabelaFrete
Return Self:aComponentes

METHOD getUniFai() CLASS GFEGerarTabelaFrete
Return Self:cUniFai

METHOD getNrNeg() CLASS GFEGerarTabelaFrete
Return Self:cNrNeg

METHOD getCdFai() CLASS GFEGerarTabelaFrete
Return Self:cCdFai

METHOD getCpTre() CLASS GFEGerarTabelaFrete
Return Self:aCpTre

METHOD getNrRota() CLASS GFEGerarTabelaFrete
Return Self:cNrRota

METHOD getTpTab() CLASS GFEGerarTabelaFrete
Return Self:cTpTab

METHOD getTpLota() CLASS GFEGerarTabelaFrete
Return Self:cTpLota

METHOD getSitNeg() CLASS GFEGerarTabelaFrete
Return Self:cSitNeg

METHOD getAdiImp() CLASS GFEGerarTabelaFrete
Return Self:cAdiImp

METHOD getEnvApr() CLASS GFEGerarTabelaFrete
Return Self:cEnvApr