#Include 'Protheus.ch'
#INCLUDE "PLSMCCR.CH" 

STATIC cCodRDA		:= ""
static lSempMsgErro	:= .t.
static nValorCrit	:= 0
static lVarCarregG	:= .f.
static oObjCompC	:= JsonObject():New()
static cCodOpe		:= ""
static cFilBAUG		:= ""
static cFilBA0G		:= ""
static cFilBA1G		:= ""
static cFilBR8G		:= ""
static cFilBB8G		:= ""
static aTabDupG		:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlCabConsulta
LOTEGUIAS de Consulta: Valida o cabeçalho.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
Function PlsVlCabConsulta(oLote)	
	
	Local aAreaBAU	:= BAU->(GetArea())
	Local aAreaBA0	:= BA0->(GetArea())
	local aResult	:= {}
	Local cSoap		:= ""
	local dDataH	:= Date()
	local lCalend	:= iif(GetNewPar("MV_PLCALPG","1") == "2", .t., .f.)

	//Carrega variáveis estáticas
	PlVarCarreg()
	
	//Verifica se Codigo da RDA ou CPF/CNPJ existe:
	If !Empty(oLote:cCodRDA)
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		If ! BAU->(MsSeek(cFilBAUG + alltrim(oLote:cCodRDA)))
	   		cSoap := PLSTISSNWL( oLote, {},  {{1, 0, "", "1203" ,"CÓDIGO PRESTADOR INVÁLIDO"}} )
	   	Endif
		
	Elseif !Empty(oLote:cCgcOri)
		If CGC(oLote:cCgcOri)
			BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
			If ! BAU->(MsSeek(cFilBAUG + alltrim(oLote:cCgcOri)))
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
		If !BA0->( MsSeek( cFilBA0G + alltrim(oLote:cRegAns) ) )
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO"}} ) //função do michel
		EndIf
	EndIf 
	
	//Validar Calendário de Pagamento
	if lCalend .and. empty(cSoap)
		aResult := PLSXVLDCAL(dDataH, cCodOpe,.f.,'','',.t.,cCodRda,.f.,.f.)
		if aResult[1]
			if ( !(dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9])) ) //busca janela 1
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
    
	RestArea(aAreaBAU)
	RestArea(aAreaBA0)
	
Return (cSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlGuiConsulta
LOTEGUIAS Consulta: Valida as Guias.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlsVlGuiConsulta (oLote, oGuia, aCritSoap, nX)
	
	local aVgDatBlo		:= {}
	local lCritica		:= .f.
	local dDataAtend	:= PlVerDataX(oGuia:cDataAtend)
	local cNumGuiPre	:= oGuia:cNUMGUIPRE
	local cMatNova		:= ""
	local l360Blo		:= .t.
	local lPlChHiBlo	:= .f.
	local lRegAns		:= .t.

	//verifico o tipo de crítica - no futuro pode ser parametrizado:
	PlVarCarreg()

	If cCodRDA <> BAU->BAU_CODIGO
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		BAU->(MsSeek(cFilBAUG +cCodRDA))
	EndIf
	
	If !Empty(oGuia:cRegAnsCab)
		if oObjCompC["ANS"+oGuia:cRegAnsCab] == Nil
			BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
			If !BA0->( MsSeek( cFilBA0G + alltrim(oGuia:cRegAnsCab ) ))
				aAdd(aCritSoap,{nValorCrit, nX, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO - N Guia: " + AllTrim(cNumGuiPre)})
				lRegAns := .f.
			EndIf
			oObjCompC["ANS"+oGuia:cRegAnsCab] := lRegAns
		elseif !oObjCompC["ANS"+oGuia:cRegAnsCab]
			aAdd(aCritSoap,{nValorCrit, nX, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO - N Guia: " + AllTrim(cNumGuiPre)})
		endif
	EndIf 

	//valida CNES
	if !empty(oGuia:oRDA:cCnes)
		PlsVlLtdCnes(oGuia:oRDA:cCnes, dDataAtend, @aCritSoap, nX, cCodRda, AllTrim(cNumGuiPre))
	endif	

	//Verifica se a data do atendimento é menor que a data de inclusão no plano :
	if (dDataAtend < BAU->BAU_DTINCL)	
		aAdd(aCritSoap,{nValorCrit, nX, "", "1201", "ATENDIMENTO FORA DA VIGENCIA DO CONTRATO COM O CREDENCIADO - N Guia: " + AllTrim(cNumGuiPre)})
	endif
	
	//Verifica se a RDA estava bloqueada na data :
	if oObjCompC["BLO" + cCodRda + oGuia:cDataAtend] == Nil
		if ! Empty(cCodRDA) .AND. ! A360CHEBLO(cCodRda, dDataAtend, .t., time())
			l360Blo := .f.
		endIf
		oObjCompC["BLO" + cCodRda + oGuia:cDataAtend] := l360Blo
	endif
	if !oObjCompC["BLO" + cCodRda + oGuia:cDataAtend] .or. !l360Blo
		aAdd(aCritSoap,{nValorCrit, nX, "", "1212" ,"ATENDIMENTO / REFERÊNCIA FORA DA VIGÊNCIA DO CONTRATO DO PRESTADOR - N Guia: " + AllTrim(cNumGuiPre)})
	endif

	if !empty(oGuia:oBenef:cCarteirinha)
		if oObjCompC["BNF" + oGuia:oBenef:cCarteirinha] == Nil                                                                                                                                      
			BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
			if !BA1->(dbseek(cFilBA1G + alltrim(oGuia:oBenef:cCarteirinha)))
				BA1->(dbsetorder(5))
				if !BA1->(DbSeek(cFilBA1G +alltrim(oGuia:oBenef:cCarteirinha))) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
					lCritica := .t.
				endif
			endif
			oObjCompC["BNF" + oGuia:oBenef:cCarteirinha] := lCritica
		endif
		if oObjCompC["BNF" + oGuia:oBenef:cCarteirinha] .or. lCritica
			aAdd(aCritSoap,{nValorCrit, nX, "", "1001", "NUMERO DA CARTEIRA INVALIDO - N Guia: " + AllTrim(cNumGuiPre)})
		endif	
		
		if !lCritica  //Significa que achou o beneficiário.
			oObjCompC["BNF" + oGuia:oBenef:cCarteirinha] := lCritica

			//Verificar se o beneficiário estava bloqueado no dia do atendimento :
			if oObjCompC["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:cDataAtend] == Nil
				if (PlChHiBlo('BCA',dDataAtend,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,nil,nil,nil,nil,@aVgDatBlo,.F.))
					// Verifica se a matricula informada e anterior a alguma transferencia
					if !empty(BA1->(BA1_TRADES)) .and. PlXmlCkDes(BA1->(BA1_TRADES), dDataAtend, @cMatNova)
						oGuia:oBenef:cCarteirinha := cMatNova
						BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
						BA1->(dbseek(cFilBA1G + alltrim(cMatNova)))
					else
						lPlChHiBlo := .t.
					endif
				endif
				oObjCompC["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:cDataAtend] := lPlChHiBlo
			endif
			if oObjCompC["BNFBCA" + oGuia:oBenef:cCarteirinha + oGuia:cDataAtend] .or. lPlChHiBlo
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
	    
	PlsVlProcConsulta(oLote,oGuia,@aCritSoap,nX)
	
return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlProcConsulta
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlsVlProcConsulta (oLote, oGuia, aCritSoap, nX)
	local cCodPad	:= ""
	local cCodPro	:= ""
	local cCodPadBK	:= ""
	local cCodProBK	:= ""
	local aBkpCriti	:= {}
	
	cCodPadBK := oGuia:oProced:cCodTab
	cCodProBK := oGuia:oProced:cCodPro

	if oObjCompC["CDPAD" + cCodPadBK] == Nil					
		cCodPad	:= AllTrim(PLSVARVINC('87','BR4',oGuia:oProced:cCodTab))
		oObjCompC["CDPAD" + cCodPadBK] := cCodPad
	else
		cCodPad := oObjCompC["CDPAD" + cCodPadBK]	
	endif

	if oObjCompC["CDPRO" + cCodPadBK + cCodProBK] == Nil	
		cCodPro	:= AllTrim(PLSVARVINC(oGuia:oProced:cCodTab,'BR8', oGuia:oProced:cCodPro, cCodPad+oGuia:oProced:cCodPro,,aTabDupG,@CCODPAD))
		oObjCompC["CDPRO" + cCodPadBK + cCodProBK] := cCodPro
	else
		cCodPro := oObjCompC["CDPRO" + cCodPadBK + cCodProBK]
	endif

	if oObjCompC["PROC" + alltrim(cCodPad + cCodPro)] == Nil
		BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
		If BR8->(msSeek(cFilBR8G + alltrim(cCodPad + cCodPro) ))	

			if ! PLSISCON(cCodPad, cCodPro)
				aBkpCriti := {nValorCrit, nX, cCodPro,  "5058", "PROCEDIMENTO INCOMPATÍVEL COM O TIPO DE GUIA. - N Guia: " + alltrim(oGuia:cNUMGUIPRE) }
				aAdd(aCritSoap, aBkpCriti)
			Endif
		Else
			aBkpCriti := {nValorCrit, nX, cCodPro,  "1801", "PROCEDIMENTO INVÁLIDO. - N Guia: " + alltrim(oGuia:cNUMGUIPRE) }
			aAdd(aCritSoap, aBkpCriti)
		EndIf
		oObjCompC["PROC" + alltrim(cCodPad + cCodPro)] := aBkpCriti
	elseif !empty(oObjCompC["PROC" + alltrim(cCodPad + cCodPro)])
		aAdd(aCritSoap, oObjCompC["PROC" + alltrim(cCodPad + cCodPro)])	
	endif
return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlLtdCnes
LOTEGUIAS Consulta: Valida CNES dos locais de atendimento

@author  Pls Team
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlsVlLtdCnes(cCnes, dDataAtend, aCritSoap, nX, cCodRda, cNumGuiaAv)
local lRet 			:= .t.
local cOpeMov		:= ""
local lFound		:= .f.
local lNoCnes		:= .f.
local cLocXML		:= ""
local dDatBlo		:= nil
local cCompCrit		:= ""
local cCompjson		:= dtos(dDataAtend)
default cNumGuiaAv	:= ""

//verifico o tipo de crítica - no futuro pode ser parametrizado:
PlVarCarreg()
cOpeMov	:= cCodOpe

if oObjCompC["CNES" + cCodRda + cCnes + cCompjson] == Nil
	//Verifica se o CNES existe em algum local de atendimento do Prestador
	BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
	if BB8->(MsSeek(cFilBB8G + cCodRda + cOpeMov))
		While !BB8->(Eof()) .And. AllTrim(BB8->(BB8_CODIGO + BB8_CODINT)) == cCodRda + cOpeMov  	
			lFound	:= AllTrim(BB8->BB8_CNES) == AllTrim(cCnes) 
			lNoCnes	:= empty(BB8->BB8_CNES)
			cLocXML	:= AllTrim(BB8->BB8_CODLOC)
			dDatBlo	:= BB8->BB8_DATBLO
			
			BB8->(DbSkip())
				
			if lFound .Or. lNoCnes
				exit
			endif
		EndDo
		
		if (!lFound .And. !lNoCnes)
			lRet := .F.
		endif
	endif
	oObjCompC["CNES" + cCodRda + cCnes + cCompjson] := lRet
endif
if !oObjCompC["CNES" + cCodRda + cCnes + cCompjson] .or. !lRet
	cCompCrit	:= "CNES não encontrado nos Locais de atendimento."
	lRet := .f.
endif

	
if lRet
	if oObjCompC["CNES2" + cCodRda + cCnes + cCompjson] == Nil
		if !empty(dDatBlo) .And. !lNoCnes .and. dDataAtend >= dDatBlo
			lRet := .F.
		endif
		oObjCompC["CNES2" + cCodRda + cCnes + cCompjson] := lRet
	endif
	if !oObjCompC["CNES2" + cCodRda + cCnes + cCompjson] .or. !lRet
		cCompCrit	:= "Local de atendimento bloqueado na data do atendimento."
		lRet := .f.
	endif
endif

if !lRet
	aAdd(aCritSoap,{nValorCrit, nX, "", "1202", "NÚMERO DO CNES INVÁLIDO - " + cCompCrit + " - N Guia: " + alltrim(cNumGuiaAv)})
endif

return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} function
Verfica se existe matricula vigente para matriculas que estão bloqueadas (wsloteguias)
@author  victor.silva
@since   20201005
/*/
//-------------------------------------------------------------------
function PlXmlCkDes(cMatDes, dDataAtend, cMatNova)
	local aAreaBA1		:= BA1->(GetArea())
	local lHasMatVig	:= .F.
	local lIntHat    	:= GetNewPar("MV_PLSHAT","0") == "1"
	default dDataAtend	:= Date()

	// Caso a integracao com o HAT esteja desabilitada nao roda a validacao
	if lIntHat
		BA1->(dbsetorder(2)) // BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
		if BA1->(dbseek(xFilial("BA1") + alltrim(cMatDes)))
			if !(PlChHiBlo('BCA',dDataAtend,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC),BA1->BA1_TIPREG,nil,nil,nil,nil,{},.F.))
				cMatNova := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
				lHasMatVig := .T.
			// Caso tenha outra matricula de transferencia, faz a chamada recursiva
			elseif !empty(BA1->(BA1_TRADES))
				lHasMatVig := PlXmlCkDes(BA1->(BA1_TRADES), dDataAtend, @cMatNova)
			endif
		endif
	endif

	RestArea(aAreaBA1)

return lHasMatVig


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVarCarreg
Função para carregar valores nas variáveis estáticas, otimizando processamento

@version P12
@since   01/2023
/*/
//-------------------------------------------------------------------
static function PlVarCarreg()
if !lVarCarregG
	lVarCarregG		:= .t.
	cFilBAUG		:= xFilial("BAU")
	cFilBA0G		:= xFilial("BA0")
	cFilBA1G		:= xFilial("BA1")
	cFilBR8G		:= xFilial("BR8")
	cFilBB8G		:= xFilial("BB8")
	nValorCrit		:= iif(lSempMsgErro, 1, 2)
	aTabDupG 		:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
	cCodOpe			:= PlsIntPad()
endif
return nil
