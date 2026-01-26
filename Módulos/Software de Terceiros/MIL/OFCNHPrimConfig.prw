#include 'totvs.ch'

/*/{Protheus.doc} OFCNHPrimConfig
Classe de Configuracao do ERP Prim CNH
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Class OFCNHPrimConfig from LongNameClass
	Data cCodigo
	Data oConfig
	Data cUser
	Data cPass
	Data cDealerCode
	Data cMarket
	Data aFiliais
	Data cCodCliRecomp
	Data cLojCliRecomp

	Method New() CONSTRUCTOR
    Method getConfig()
    Method saveConfig()
	Method toString()
	Method CorpToFil()
	Method NextNum()
	Method SaveCheckpoint()
	Method getNumSeq()
EndClass


/*/{Protheus.doc} New
Construtor Simples
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Method New( lConfig ) Class OFCNHPrimConfig
default lConfig := .F.
	::cCodigo       := "OFCNHA06"
	::cUser         := ""
	::cPass         := ""
	::cDealerCode   := ""
	::cMarket       := ""
	::aFiliais      := {}
	::cCodCliRecomp := ""
	::cLojCliRecomp := ""
	::oConfig       := nil

	if lConfig
		::getConfig()
	endif
Return SELF


/*/{Protheus.doc} getConfig
Pega a configuracao em formato de data container
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Method getConfig( cFilCurr ) Class OFCNHPrimConfig
local   oConfig   := JsonObject():New()
local   lVRN      := FWAliasInDic("VRN")
local   lExistCfg := .f.
local   nI
default cFilCurr  := cFilAnt

	aSize( ::aFiliais, 0 )

	If lVRN
		VRN->(dbSetOrder(1))
		lExistCfg := VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
		if lExistCfg
			oConfig:FromJson(VRN->VRN_CONFIG)
		endif
	endif

	if ! lVRN .or. ! lExistCfg
		oConfig["MOEDA"]          := "040"
		oConfig["DIR_IN"]         := Space(80)
		oConfig["DIR_OUT"]        := Space(80)
		oConfig["DIR_LIDOS"]      := Space(80)
		oConfig["EMAIL_SERVER"]   := Space(80)
		oConfig["EMAIL_USER"]     := Space(80)
		oConfig["EMAIL_PASS"]     := Space(80)
		oConfig["EMAIL_SENDER"]   := Space(80)
		oConfig["EMAIL_OCORREN"]  := Space(80)
		oConfig["EMAIL_AUTH"]     := "1"
		oConfig["EMAIL_SECURE"]   := "3"
		oConfig["AMBIENTE"]       := "TEST"
		oConfig["LOCAIS"]         := {}
		oConfig["SENHAS"]         := {}
		oConfig["LOGS"]           := "0"		// 0=Não/1=Sim
		oConfig["GRUPO"]          := FWTamSX3('BM_GRUPO')[1]
		oConfig["CONDPAGTO"]      := FWTamSX3('E4_CODIGO')[1]
		oConfig["CODCLIRECOMP"]   := ""
		oConfig["LOJCLIRECOMP"]   := ""

		if lVRN
			reclock("VRN", .T.)
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := self:cCodigo
			VRN->VRN_CONFIG := oConfig:toJson()
			VRN->(MsUnlock())
		endif
	endif

	for nI := 1 to len( oConfig["SENHAS"] )
		aAdd( ::aFiliais, { ;
			oConfig["SENHAS"][nI]["FILIAL"]  ,;
			cValToChar( oConfig["SENHAS"][nI]["D1NUMSEQ"] ),;
			cValToChar( oConfig["SENHAS"][nI]["D2NUMSEQ"] ),;
			cValToChar( oConfig["SENHAS"][nI]["D3NUMSEQ"] ),;
			iif( oConfig["SENHAS"][nI]["NROTRANSMISSAO"] == nil, 0, oConfig["SENHAS"][nI]["NROTRANSMISSAO"] ) ;
		})

		if alltrim(oConfig["SENHAS"][nI]["FILIAL"]) == alltrim( cFilCurr )
			::cUser       := alltrim( oConfig["SENHAS"][nI]["USUARIO"] )
			::cPass       := alltrim( oConfig["SENHAS"][nI]["SENHA"] )
			::cDealerCode := alltrim( oConfig["SENHAS"][nI]["DEALERCODE"] )
			::cMarket     := alltrim( oConfig["SENHAS"][nI]["MERCADO"] )
		endif
	next

	::cCodCliRecomp := oConfig["CODCLIRECOMP"]
	::cLojCliRecomp := oConfig["LOJCLIRECOMP"]

	self:oConfig := oConfig
Return oConfig


/*/{Protheus.doc} saveConfig
Salva a configuracao no lugar da atual
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Method saveConfig(oConfig) Class OFCNHPrimConfig
local cJson := oConfig:toJson()

	VRN->(dbSetOrder(1))
	if VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := FGX_JSONform( cJson, .T., nil, .F. )
		VRN->(MsUnlock())
	endif
return .t. 


/*/{Protheus.doc} toString()
retorna JSON dos parâmetros configurados PRIM
@type function
@author Cristiam Rossi
@since 07/02/2025
/*/
Method toString(oConfig) class OFCNHPrimConfig
return FGX_JSONform( oConfig:toJson(), .T., nil, .F. )


/*/{Protheus.doc} New
Retorna a Filial do Dealercode informado
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Method CorpToFil( cDealer ) Class OFCNHPrimConfig
local   cFilDealer := ""
local   oConfig    := ::getConfig()
local   nI
default cDealer    := ""

	if ! empty( cDealer )
		for nI := 1 to len( oConfig["SENHAS"] )
			if alltrim(oConfig["SENHAS"][nI]["DEALERCODE"]) == alltrim(cDealer)
				cFilDealer := alltrim( oConfig["SENHAS"][nI]["FILIAL"] )
				exit
			endif
		next
	endif

return cFilDealer


/*/{Protheus.doc} toString()
retorna JSON dos parâmetros configurados PRIM
@type function
@author Cristiam Rossi
@since 07/02/2025
/*/
Method NextNum( cFilAtu ) class OFCNHPrimConfig
local   nI
local   nNroTrans := 1
default cFilAtu   := cFilAnt

	for nI := 1 to Len(::aFiliais)
		if ::aFiliais[nI][1] == alltrim( cFilAtu )
			nNroTrans := ++::aFiliais[nI][5]
			::oConfig["SENHAS"][nI]["NROTRANSMISSAO"] := nNroTrans
			exit
		endif
	next

	::saveConfig(::oConfig)
return cValToChar( nNroTrans )


/*/{Protheus.doc} SaveCheckpoint
	salva numeracao de sequencia das movimentacoes ja enviadas a cnh

	@type function
	@author Vinicius Gati
	@since 08/03/2018
/*/
Method SaveCheckpoint(cD1NumSeq, cD2NumSeq, cD3NumSeq, cFilAtu) Class OFCNHPrimConfig
local   nI
Default cD1NumSeq := FM_SQL(" SELECT MAX(D1_NUMSEQ) FROM "+RetSqlName('SD1')+" WHERE D1_FILIAL = '"+xFilial('SD1')+"' AND D_E_L_E_T_ = ' ' ")
Default cD2NumSeq := FM_SQL(" SELECT MAX(D2_NUMSEQ) FROM "+RetSqlName('SD2')+" WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D_E_L_E_T_ = ' ' ")
Default cD3NumSeq := FM_SQL(" SELECT MAX(D3_NUMSEQ) FROM "+RetSqlName('SD3')+" WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D_E_L_E_T_ = ' ' ")
Default cFilAtu   := cFilAnt

	for nI := 1 to Len(::aFiliais)
		if ::aFiliais[nI][1] == alltrim(cFilAtu)
			::aFiliais[nI][2] := cD1NumSeq
			::aFiliais[nI][3] := cD2NumSeq
			::aFiliais[nI][4] := cD3NumSeq

			::oConfig["SENHAS"][nI]["D1NUMSEQ"] := cD1NumSeq
			::oConfig["SENHAS"][nI]["D2NUMSEQ"] := cD2NumSeq
			::oConfig["SENHAS"][nI]["D3NUMSEQ"] := cD3NumSeq
		endif
	next
	::saveConfig(::oConfig)
return nil


/*/{Protheus.doc} getNumSeq
Retorna a numeracao de sequencia das movimentacoes ja enviadas a cnh
@type function
@author Cristiam Rossi
@since 07/03/2025
/*/
Method getNumSeq( cFilAtu ) Class OFCNHPrimConfig
local   aRetorno := {}
local   nI
default cFilAtu := cFilAnt

	::getConfig()

	for nI := 1 to len( ::aFiliais )
		if ::aFiliais[nI][1] == alltrim(cFilAtu)
			aAdd( aRetorno, {;
				::aFiliais[nI][2],;
				::aFiliais[nI][3],;
				::aFiliais[nI][4],;
				::aFiliais[nI][5];
			})
		endif
	next

return aRetorno
