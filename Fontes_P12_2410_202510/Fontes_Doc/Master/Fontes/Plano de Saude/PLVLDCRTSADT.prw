#Include 'Protheus.ch'
#INCLUDE "PLSMCCR.CH" 

STATIC cCodRDA		:= ""
static lSempMsgErro	:= .t.
static nValorCrit	:= 0
static oObjComp		:= JsonObject():New()
static lVarCarreg	:= .f.
static cFilBAU		:= ""
static cFilBA0		:= ""
static cFilBA1		:= ""
static cFilBR8		:= ""
static cFilBB0		:= ""
static aTabDup		:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PlVlTCabSADT
LOTEGUIAS de Consulta: Valida o cabeçalho.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
Function PlVlTCabSADT(oLote)	
	
	local aResult	:= {}	
	Local cSoap		:= ""
	local dDataH	:= Date()
	local lCalend	:= iif(GetNewPar("MV_PLCALPG","1") == "2", .t., .f.)

	PlVarCarreg() //Carrega variaveis estáticas, se vazias
	
	//Verifica se Codigo da RDA ou CPF/CNPJ existe:
	If !Empty(oLote:cCodRDA)
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		If ! BAU->(MsSeek(cFilBAU + strZero(val(oLote:cCodRDA),TamSx3("BAU_CODIGO")[1])))
	   		cSoap := PLSTISSNWL( oLote, {},  {{1, 0, "", "1203" ,"CÓDIGO PRESTADOR INVÁLIDO"}} )
	   	Endif
		
	Elseif !Empty(oLote:cCgcOri)
		If CGC(oLote:cCgcOri)
			BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
			If ! BAU->(MsSeek(cFilBAU + alltrim(oLote:cCgcOri)))
				cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "1203" ,"CODIGO PRESTADOR INVÁLIDO"}} )
		   	Endif	
		Else
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "1206" ,"CPF / CNPJ INVÁLIDO"}} )
	   	Endif
	Endif
	
	cCodRDA := BAU->BAU_CODIGO
	oLote:cCodRDA := cCodRDA
	
	If !Empty(oLote:cRegAns)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If !BA0->( MsSeek( cFilBA0 + alltrim(oLote:cRegAns) ) )
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO"}} ) //função do michel
		EndIf
	EndIf 

	//Validar Calendário de Pagamento
	if lCalend .and. empty(cSoap)
		aResult := PLSXVLDCAL(dDataH,PlsIntPad(),.f.,'','',.t.,cCodRda,.f.,.f.)
		if aResult[1]
			if ( !(dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9])) )
				if !(Len(aResult) >= 10 .AND. aResult[10] .AND. dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9]) ) //busca janela 2, caso exista
					cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "3091", "COBRANÇA FORA DO PRAZO ESTIPULADO NO CONTRATO - PERIODO DE " + strtran(aResult[8], "/", "-") + " ATÉ " + strtran(aResult[9], "/", "-") }} ) //função do michel
				endif
			endif
		else
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "3091", "COBRANÇA FORA DO PRAZO ESTIPULADO NO CONTRATO - ENTRE EM CONTATO COM A OPERADORA - CALENDARIO NAO CADASTRADO" }} ) //função do michel
		endif		
	endif	

	If Empty(cSoap)
		cSoap := PLTisOnBXX( oLote, cCodRDA )
    	if ! Empty(cSoap)
    	  	return cSoap
    	Endif
    EndIf
	
Return (cSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVlTGuiSADT
LOTEGUIAS Consulta: Valida as Guias.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlVlTGuiSADT (oLote, oGuia, aCritSoap, nX)
	local aVgDatBlo		:= {}
	local aRetF			:= {}
	local lCritica		:= .f.
	local dDataAtend	:= PlVerDataX(oGuia:oProced:cDatExec)
	local cMatNova		:= ""
	local cNumGuiPre	:= oGuia:cNUMGUIPRE
	local lRegAns		:= .t.
	local l360Blo		:= .t.
	local lPlChHiBlo 	:= .f.

	//verifico o tipo de crítica - no futuro pode ser parametrizado:
	PlVarCarreg()

	If cCodRDA <> BAU->BAU_CODIGO
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		BAU->(MsSeek(cFilBAU + cCodRDA))
	EndIf
	
	If !Empty(oGuia:cRegAnsCab)
		if oObjComp["ANS"+oGuia:cRegAnsCab] == Nil
			BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
			If !BA0->( MsSeek( cFilBA0 + alltrim(oGuia:cRegAnsCab ) ))
				lRegAns := .f.
			EndIf
			oObjComp["ANS"+oGuia:cRegAnsCab] := lRegAns
		endif
		if !oObjComp["ANS"+oGuia:cRegAnsCab] .or. !lRegAns
			aAdd(aCritSoap,{nValorCrit, nX, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO - N Guia: " + AllTrim(cNumGuiPre)})
		endif
	EndIf 
	
	//valida CNES
	if !empty(oGuia:oRDAExecutante:cCnes )
		PlsVlLtdCnes(oGuia:oRDAExecutante:cCnes, dDataAtend, @aCritSoap, nX, cCodRda, cNumGuiPre)
	endif	

	//Verifica se a data do atendimento é menor que a data de inclusão no plano :
	if (dDataAtend < BAU->BAU_DTINCL)	
		aAdd(aCritSoap,{nValorCrit, nX, "", "1201", "ATENDIMENTO FORA DA VIGENCIA DO CONTRATO COM O CREDENCIADO - N Guia: " + AllTrim(cNumGuiPre)})
	endif
		
	//Verifica se a RDA estava bloqueada na data :
	if oObjComp["BLO" + cCodRda + oGuia:oProced:cDatExec] == Nil
		if ! Empty(cCodRDA) .AND. ! A360CHEBLO(cCodRda, dDataAtend, .t., time())
			l360Blo := .f.
		endIf
		oObjComp["BLO" + cCodRda + oGuia:oProced:cDatExec] := l360Blo
	endif
	if !oObjComp["BLO" + cCodRda + oGuia:oProced:cDatExec] .or. !l360Blo
		aAdd(aCritSoap,{nValorCrit, nX, "", "1212" ,"ATENDIMENTO / REFERÊNCIA FORA DA VIGÊNCIA DO CONTRATO DO PRESTADOR - N Guia: " + AllTrim(cNumGuiPre)})
	endif
	
	if !empty(oGuia:oBenef:cCarteirinha)
		if oObjComp["BNF" + oGuia:oBenef:cCarteirinha] == Nil
			BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
			if !BA1->(dbseek(cFilBA1 + alltrim(oGuia:oBenef:cCarteirinha)))
				BA1->(dbsetorder(5))
				if !BA1->(DbSeek(cFilBA1 + alltrim(oGuia:oBenef:cCarteirinha))) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
					lCritica := .t.
				endif
			endif
			oObjComp["BNF" + oGuia:oBenef:cCarteirinha] := lCritica
		endif
		if oObjComp["BNF" + oGuia:oBenef:cCarteirinha] .or. lCritica
			aAdd(aCritSoap,{nValorCrit, nX, "", "1001", "NUMERO DA CARTEIRA INVALIDO - N Guia: " + AllTrim(cNumGuiPre)})
		endif
		
		if !lCritica  //Significa que achou o beneficiário.
			oObjComp["BNF" + oGuia:oBenef:cCarteirinha] := lCritica
			if oObjComp["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:oProced:cDatExec] == Nil
				//Verificar se o beneficiário estava bloqueado no dia do atendimento :
				if (PlChHiBlo('BCA',dDataAtend,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,nil,nil,nil,nil,@aVgDatBlo,.F.))
					// Verifica se a matricula informada e anterior a alguma transferencia
					if !empty(BA1->(BA1_TRADES)) .and. PlXmlCkDes(BA1->(BA1_TRADES), dDataAtend, @cMatNova)
						oGuia:oBenef:cCarteirinha := cMatNova
						BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
						BA1->(dbseek(cFilBA1 + alltrim(cMatNova)))
					else
						lPlChHiBlo := .t.
					endif
				endif
				oObjComp["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:oProced:cDatExec] := lPlChHiBlo
			endif
			if oObjComp["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:oProced:cDatExec] .or. lPlChHiBlo 
				aAdd(aCritSoap,{nValorCrit, nX, "", "1016", "BENEFICIÁRIO COM ATENDIMENTO SUSPENSO - N Guia: " + AllTrim(cNumGuiPre)})
			endif

			//Verifica se a data do atendimento é menor que a data de inclusão no plano :
			if (dDataAtend < BA1->BA1_DATINC)	
				aAdd(aCritSoap,{nValorCrit, nX, "", "1005", "ATENDIMENTO ANTERIOR À INCLUSÃO DO BENEFICIÁRIO - N Guia: " + AllTrim(cNumGuiPre)})
			endif
			
			//Verifica data da carteira	:
			if (!empty(BA1->BA1_DTVLCR) .and. dDataAtend > BA1->BA1_DTVLCR)	
				aAdd(aCritSoap,{nValorCrit, nX, "", "1017", "DATA VALIDADE DA CARTEIRA VENCIDA - N Guia: " + AllTrim(cNumGuiPre) })
			endif
			
		endif		
			
	endif
	
	//RDA Executante
	aRetF := PlVrCodBAU(oGuia)
	if !aRetF[1]
		aAdd(aCritSoap,{nValorCrit, nX, "", aRetF[2], aRetF[3] + " DO CONTRATADO EXECUTANTE - N Guia: " + AllTrim(cNumGuiPre)})		
	endif    

return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlProcConsulta
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlVlExTSADT(oLote,oGuia,aCritSoap,nX)
local aAreaBB0	:= BB0->(getarea())
local aAreaBAU	:= BAU->(getarea())
local cCodigo 	:= oGuia:oProfExecSadt:cCodProf
local cCodPro		:= oGuia:oProced:cCodPro

//verifico o tipo de crítica - no futuro pode ser parametrizado:
nValorCrit := iif(lSempMsgErro, 1, 3)

BAU->( DbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO

if !BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
	BAU->( DbSetOrder(4) ) //BAU_FILIAL + BAU_CPFCGC
	
	if !BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
		BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
		
		if !BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
			BB0->( DbSetOrder(3) ) //BB0_FILIAL + BB0_CPF
			
			if !BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
				aAdd(aCritSoap,{nValorCrit, nX, cCodPro, "1206", "CPF / CNPJ INVÁLIDO DO EXECUTANTE. - N Guia: " + alltrim(oGuia:cNUMGUIPRE)})
			endif
		
		endif
	
	endif

endif
		
RestArea(aAreaBB0)
RestArea(aAreaBAU)

Return (aCritSoap)



//-------------------------------------------------------------------
/*/{Protheus.doc} PlVrCodBAU
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
static function PlVrCodBAU(oGuia)
local aRetorno	:= {.t.}	
local lRetBAU	:= .t.

PlVarCarreg() //Carrega variaveis estáticas, se vazias

//Verifica se Codigo da RDA ou CPF/CNPJ existe:
If !Empty(oGuia:oRDAExecutante:cCodRda)
	if oObjComp["RDAEX" + oGuia:oRDAExecutante:cCodRda] == Nil
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		If ! BAU->(MsSeek(cFilBAU + alltrim(oGuia:oRDAExecutante:cCodRda)))
			lRetBAU := .f.
		Endif
		oObjComp["RDAEX" + oGuia:oRDAExecutante:cCodRda] := lRetBAU
	endif
	if !oObjComp["RDAEX" + oGuia:oRDAExecutante:cCodRda] .or. !lRetBAU
		aRetorno := {.f.,"1203", "CODIGO PRESTADOR INVÁLIDO" }
	endif

Elseif !Empty(oGuia:oRDAExecutante:cCgc)
	if oObjComp["RDAEX" + oGuia:oRDAExecutante:cCgc] == Nil
		If CGC(oGuia:oRDAExecutante:cCgc)
			BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
			If ! BAU->(MsSeek(cFilBAU + alltrim(oGuia:oRDAExecutante:cCgc)))
				aRetorno := {.f.,"1203", "CODIGO PRESTADOR INVÁLIDO" }
				lRetBAU := .f.
			Endif	
		Else
			aRetorno := {.f.,"1206", "CPF / CNPJ INVÁLIDO" }
			lRetBAU := .f.
		Endif
		oObjComp["RDAEX" + oGuia:oRDAExecutante:cCgc] 	:= lRetBAU
		if len(aRetorno) > 1
			oObjComp["RDAEXC" + oGuia:oRDAExecutante:cCgc] 	:= aRetorno[2]
			oObjComp["RDAEXC2" + oGuia:oRDAExecutante:cCgc] := aRetorno[3]
		endif
	elseif !oObjComp["RDAEX" + oGuia:oRDAExecutante:cCgc]
		aRetorno := {.f., oObjComp["RDAEXC" + oGuia:oRDAExecutante:cCgc], oObjComp["RDAEXC2" + oGuia:oRDAExecutante:cCgc] }
	endif		
Endif

return aRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVarCarreg
Função para carregar valores nas variáveis estáticas, otimizando processamento
@version P12
@since   01/2023
/*/
//-------------------------------------------------------------------
static function PlVarCarreg()
if !lVarCarreg
	lVarCarreg	:= .t.
	cFilBAU		:= xFilial("BAU")
	cFilBA0		:= xFilial("BA0")
	cFilBA1		:= xFilial("BA1")
	cFilBR8		:= xFilial("BR8")
	cFilBB0		:= xFilial("BB0")
	nValorCrit	:= iif(lSempMsgErro, 1, 2)
	aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
endif
return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVerDataX
Função para otimizar resultados, verificando se uma data já não foi convertida anteriormente, para não chamar
diversas vezes a função PLSAJUDAT
@version P12
@since   01/2023
/*/
//-------------------------------------------------------------------
function PlVerDataX(cData)
local dDataRet	:= nil

if oObjComp["DTCNV" + cData] == Nil
	dDataRet := PLSAJUDAT(cData)
	oObjComp["DTCNV" + cData] := dDataRet
else
	dDataRet := oObjComp["DTCNV" + cData]
endif
return dDataRet
