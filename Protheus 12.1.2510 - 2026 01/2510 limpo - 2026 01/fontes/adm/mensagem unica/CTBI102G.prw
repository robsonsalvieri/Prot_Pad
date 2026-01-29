#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "CTBI102G.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"

/*/{Protheus.doc} CT2readXGspMessageReader
INTEGRAÇÃO PROTHEUS GESPLAN LANÇAMENTO CONTÁBIL CTBA102
@type Class
@since 22/08/2022
@author Thiago Bussolin
/*/
Class CT2readXGspMessageReader from LongNameClass

	method New()
	method Read()

EndClass

/*/{Protheus.doc} CT2readXGspMessageReader::New
construtor
@type method
@since 22/08/2022
@author Thiago Bussolin
/*/
method New() Class CT2readXGspMessageReader

return self

/*/{Protheus.doc} CT2readXGspMessageReader::Read
Responsável pela leitura e processamento da mensagem.
@type method
@since 22/08/2022
@author Thiago Bussolin
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
method Read( oLinkMessage ) Class CT2readXGspMessageReader

	Local oContent 		:= JsonObject():new()
	Local aItensJson 	:= {}
	Local aValid 		:= {}
	Local oResp 		:= JsonObject():new()
	Local nZ 			:= 0
	Local aJson 		:= {}
	Local cTenantId 	:= ""
	Local cEmpJson 		:= ""
	Local cFilJson 		:= ""
	Local cCt2key 		:= ""
	Local nModOld 		:= nModulo
	Local cModOld 		:= cModulo 
	Local oReturn 		:= Nil
	
	oContent:FromJSON(oLinkMessage:RawMessage())
	cTenantId := oContent['tenantId']
	oContent := oContent['data']

	FWLogMsg('INFO',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0010 + cTenantId + STR0011 ) //"Início do processamento CTBI102G. Tenant: "  " Validando campos obrigatórios e tipo de dado"

	// ConOut( oLinkMessage:RawMessage())
	// ConOut( oLinkMessage:Header():toJson())
	// ConOut( oLinkMessage:Content():toJson())
	// ConOut( oLinkMessage:Type())
	// ConOut( oLinkMessage:tenantId())
	// ConOut( oLinkMessage:requestID())

	If len(oContent) > 0
		For	nZ := 1 To len(oContent)
			
			cEmpJson 	:= oContent[nZ]:GetJsonText("COD_EMP")
			cFilJson 	:= oContent[nZ]["CT2_FILIAL"] 
			aItensJson 	:= oContent[nZ]['ITENS']

			aValid := ValidData(oContent[nZ], @cEmpJson, @cFilJson, aItensJson, @cCt2key)

			If aValid[1]
				oReturn := StartJob("CTBIPrcCT2", GetEnvServer(), .T., @cEmpJson, @cFilJson, oContent, aItensJson, @cCt2key, nZ)
				aAdd(aJson,oReturn)
			Else
				FWLogMsg('WARN',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0012 + cTenantId ) //"Campos obrigatórios inválidos ou não preenchidos. Tenant: " 
				IncResp({},@aJson,aValid[2]/*cError*/ ,oContent,nZ ,cEmpJson,cFilJson ,cCt2key, ""/*cDOC*/)
			EndIF

		Next nZ
	Else
		FWLogMsg('WARN',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0013 + cTenantId ) //"Mensagem recebida sem conteúdo para processamento. Tenant: "
	EndIf

	//- restaura o módulo de processamento 
	If !Empty(cModOld) .and. !cModulo == cModOld 
		cModulo := cModOld
		nModulo := nModOld
	EndIf
	
	oResp:set(aJson)
	RespGesplan(oResp:toJSON(),cTenantId)

	FWLogMsg('INFO',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0014 + cTenantId )//"Fim do processamento. Tenant: "
	
	FreeObj(oResp)
	FreeObj(oReturn)
	aSize(aJson,0)
	aJson := nil
	aSize(aValid,0)
	aValid := nil

Return .T.

/*/{Protheus.doc} IncResp
INCREMENTA ITENS DE RESPOSTA PARA GESPLAN APÓS EXECAUTO	
@type StaticFunction
@since 10/07/2023
@author Thiago Bussolin
/*/
Static Function IncResp(aLog,aJson,cError,oContent,nZ ,cEmpJson,cFilJson ,cCt2key, cDoc)

	Local nX := 0
	Local nPos := 0
	If Len(aLog) > 0
		For nX := 1 To Len(aLog)
			cError += alltrim(aLog[nX]) + CRLF
		Next nX
	EndIf
	Aadd(aJson,JsonObject():new())
	nPos := Len(aJson)
	IiF(Empty(oContent[nZ]["ID"]),aJson[nPos]["ID"]:= 'Empty',aJson[nPos]["ID"]:= oContent[nZ]:GetJsonText("ID"))
	IiF(Empty(oContent[nZ]["EST"]),aJson[nPos]["EST"]:= 'Empty',aJson[nPos]["EST"]:= oContent[nZ]:GetJsonText("EST"))
	aJson[nPos]["COD_EMP"] := cEmpJson 
	aJson[nPos]["CT2_FILIAL"] := cFilJson
	aJson[nPos]["CT2_DOC"] := cDoc
	aJson[nPos]["CT2_KEY"] := cCt2key
	aJson[nPos]["error"] := cError

Return

/*/{Protheus.doc} RespGesplan
ENVIO DE RESPOSTA PARA GESPLAN APÓS EXECAUTO	
@type StaticFunction
@since 22/08/2022
@author Thiago Bussolin
/*/
Static Function RespGesplan(oResp,cTenantId)
	Local oClient as object
	Local cMessage as character
	local cTimestamp := FWTimeStamp(5, DATE(), TIME())
	oClient := FwTotvsLinkClient():New()

	BeginContent Var cMessage
	{
	"specversion": "1.0",
	"time": "%Exp:cTimestamp%" ,
	"type": "CT2respXGsp",
	"tenantId": "%Exp:cTenantId%" ,
	"data": %Exp:oResp%
	}
	EndContent
	cMessage := FWhttpEncode(cMessage)
	If oClient:SendAudience("CT2respXGsp","LinkProxy", cMessage)
		FWLogMsg('INFO',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0015 + cTenantId ) // "Resposta enviada para o smartlink da Gesplan. tenant: "
	EndIf

Return

/*/{Protheus.doc} ValidData
Pré valida campos obrigatórios e tipos para a chamada do execauto 
@type Static Function
@since 22/08/2022
@author Thiago Bussolin
@return Array, sucesso ou falha. mensagem de falha.
/*/
Static Function ValidData(oContent,cEmpJson,cFilJson,aItensJson,cCt2key,nZ)
	
	Local lRet As logical
	Local cMsg As Character
	Local aSM0 As Array
	Local nY As Numeric
	
	lRet := .T.
	cMsg := ""
	aSM0 := {}
	nY   := 0

	//Validação de campos obrigatórios
	//Capa do Lote
	IIf( Empty(cEmpJson),cMsg := STR0001 +"COD_EMP"+ STR0002,) 		//"| Campo " + " obrigatório |"
	IIf( Empty(cFilJson),cMsg += STR0001 +"CT2_FILIAL"+ STR0002,) //"| Campo " + " obrigatório |"
	IIf( Empty(oContent["CT2_DATA"]),cMsg   += STR0001 +"CT2_DATA"+ STR0002,)	//"| Campo " + " obrigatório |"
	
	//Itens
	If VALTYPE(aItensJson) == 'A'
		For nY := 1 to len(aItensJson)
			IIf( Empty(aItensJson[nY]["CT2_DC"]),cMsg += STR0001 +"CT2_DC"+ STR0002,IIF(aItensJson[nY]["CT2_DC"]=='1' .and. Empty(aItensJson[nY]["CT2_DEBITO"]),cMsg += STR0001 +"CT2_DEBITO"+ STR0002,; //"| Campo " + " obrigatório |"
			IIf(aItensJson[nY]["CT2_DC"]=='2' .and. Empty(aItensJson[nY]["CT2_CREDIT"]),cMsg += STR0001 +"CT2_CREDIT"+ STR0002,IIF(aItensJson[nY]["CT2_DC"]=='3' .and.(Empty(aItensJson[nY]["CT2_DEBITO"]).or. Empty(aItensJson[nY]["CT2_CREDIT"])),; //"| Campo " + " obrigatório |"
			cMsg += STR0001 +"CT2_CREDIT"+ STR0007 +"CT2_DEBITO" + STR0003,)))) //"| Campo " +  " e " +" obrigatório para Partida Dobrada|"

			IIf( Empty(aItensJson[nY]["CT2_VALOR"]),cMsg += STR0001 +"CT2_VALOR"+ STR0002,)   //"| Campo " + " obrigatório |"
			IIf( Empty(aItensJson[nY]["CT2_HIST"]),cMsg += STR0001 +"CT2_HIST"+ STR0002,)	    //"| Campo " + " obrigatório |"
			IIf( Empty(aItensJson[nY]["CT2_EMPORI"]),cMsg += STR0001 +"CT2_EMPORI"+ STR0002,) //"| Campo " + " obrigatório |"
			IIf( Empty(aItensJson[nY]["CT2_FILORI"]),cMsg += STR0001 +"CT2_FILORI"+ STR0002,) //"| Campo " + " obrigatório |"
			IIf( Empty(aItensJson[nY]["CT2_KEY"]),cMsg += STR0001 +"CT2_KEY"+ STR0002,)		//"| Campo " + " obrigatório |"
			IIf( Empty(aItensJson[nY]["CT2_ROTINA"]),cMsg += STR0001 +"CT2_ROTINA"+ STR0004,) //"| Campo " + " obrigatório. Enviar: WFNFIN ou WFNCASH ou WFNLEAS |"
			IIf( VALTYPE(aItensJson[nY]["CT2_LP"])=="C" .and. VALTYPE(oContent['CPADRAO']) =="C" .AND. ;
				! Empty(aItensJson[nY]["CT2_LP"]) .AND. ! Empty(oContent['CPADRAO']) ;
				,cMsg += STR0001 +"CT2_LP"+STR0007+"cPadrao "+ STR0019,)	//"| Campo " + " e  "+ " não podem ser preenchidos simultaneamente. Por gentileza, revise os dados de origem da Geplan. O registro foi ignorado. |"
		NEXT ny
		cCt2key := aItensJson[1]:GetJsonText("CT2_KEY")
	Else
		cMsg += STR0001 + "ITENS" + STR0002 //"| Campo " + " obrigatório. 
	EndIf

	If Empty(cMsg)
		//Validação de tipos
		//Capa do Lote
		IIf( VALTYPE(oContent["COD_EMP"])=="C",,cMsg += STR0001 +"COD_EMP"+ STR0005) 	   //"| Campo " + " tipo inválido|"
		IIf( VALTYPE(oContent["CT2_FILIAL"])=="C",,cMsg += STR0001 +"CT2_FILIAL"+ STR0005) //"| Campo " + " tipo inválido|"
		IIf( VALTYPE(oContent["CT2_DATA"])=="C",,cMsg   += STR0001 +"CT2_DATA"+ STR0005)   //"| Campo " + " tipo inválido|"
	
	//Itens
		For nY := 1 to len(aItensJson)
			IIf(!VALTYPE(aItensJson[nY]["CT2_DC"])=="C",cMsg += STR0001 +"CT2_DC"+ STR0005,IIF(aItensJson[nY]["CT2_DC"]=='1' .and. !VALTYPE(aItensJson[nY]["CT2_DEBITO"])=="C",cMsg += STR0001 +"CT2_DEBITO"+ STR0005,; //"| Campo " + " tipo inválido|"
			IIf(aItensJson[nY]["CT2_DC"]=='2' .and. !VALTYPE(aItensJson[nY]["CT2_CREDIT"])=="C",cMsg += STR0001 +"CT2_CREDIT"+ STR0005,IIF(aItensJson[nY]["CT2_DC"]=='3' .and.(!VALTYPE(aItensJson[nY]["CT2_DEBITO"]) == "C".or. !VALTYPE(aItensJson[nY]["CT2_CREDIT"])=="C"),; //"| Campo " + " tipo inválido|"
			cMsg += STR0001 +"CT2_CREDIT"+ STR0006 +"CT2_DEBITO"+ STR0005,)))) //"| Campo " + " ou " + " tipo inválido|"

			IIf( VALTYPE(aItensJson[nY]["CT2_VALOR"])=="N",,cMsg += STR0001 +"CT2_VALOR"+ STR0005)	//"| Campo " + " tipo inválido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_HIST"])=="C",,cMsg += STR0001 +"CT2_HIST"+ STR0005)		//"| Campo " + " tipo inválido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_EMPORI"])=="C",,cMsg += STR0001 +"CT2_EMPORI"+ STR0005)  //"| Campo " + " tipo inválido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_FILORI"])=="C",,cMsg += STR0001 +"CT2_FILORI"+ STR0005)  //"| Campo " + " tipo inválido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_KEY"])=="C",,cMsg += STR0001 +"CT2_KEY"+ STR0005)		//"| Campo " + " tipo inválido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_ROTINA"])=="C",,cMsg += STR0001 +"CT2_ROTINA"+ STR0005)	//"| Campo " + " tipo inválido|"

		NEXT ny
		
	EndIf

	If Empty(cMsg)
		If !validSM0(@cEmpJson,@cFilJson)
			lRet := .F.
			cMsg := STR0008+' '+cEmpJson+' | '+cFilJson +' |'//"| Empresa ou Filial não foram encontradas |"
		EndIf
	Else
		lRet := .F.
	EndIf

	aSize(aSM0,0)
	aSM0 := nil

Return {lRet,cMsg}

/*/{Protheus.doc} validSM0
Função auxiliar para validação do grupo de empresa + filial
@type  Function
@author Nilton Rodrigues
@since 08/05/2023
@version 1.0
@param cEmpJson, Character, Código da empresa/grupo
@param cFilJson, Character, Código da filial
@return Logical, retorna true na sua existência e falso não existindo
/*/
static function validSM0(cEmpJson,cFilJson)
	local aAreaSM0 as array
	local cWorkarea as char
	local lOk as logical

	if !FWDbConnectionManagement():HasConnection()
		FWDbConnectionManagement():Connect()
	endif

	cWorkarea := Alias()

	OpenSM0()

	aAreaSM0 := SM0->(FWGetArea())

	SM0->(DBSetOrder(1))
	cEmpJson := Padr(cEmpJson,Len(SM0->M0_CODIGO))
	cFilJson := Padr(cFilJson,Len(SM0->M0_CODFIL))
	
	lOk      := SM0->(DBSeek(cEmpJson+cFilJson))

	FWRestArea(aAreaSM0)
	FWRestAlias(cWorkarea)

return lOk

/*/{Protheus.doc} CTBIPrcCT2
Valida se a empresa está correta e aberta
@type  Function
@author Nilton Rodrigues
@since 08/05/2023
@version 1.0
/*/ 
Function CTBIPrcCT2(cEmpInt As Character, cFilInt as character,oContent,aItensJson,cCt2key,nZ)

	Local aJson := {}
	Local oReturn := Nil

	If Select( "SX3" ) == 0 .Or. !( cEmpAnt == cEmpInt )
        RpcClearEnv( )
        RpcSetType( 3 )

        OpenSM0( cEmpInt )

        RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
    EndIf

	//- Ajusta a filial de processamento 
	If !cFilAnt == cFilInt
		If !Empty(cFilInt)
			cFilAnt := cFilInt
		EndIf 
	EndIf

	//- ajusta o módulo de uso do processamento 
	cModulo   := 'CTB'
	nModulo   := 34

	ProcessCT2(oContent,cEmpInt,cFilInt,aItensJson,cCt2key,nZ,@aJson)

	oReturn := aJson[1]

Return oReturn

/*/{Protheus.doc} ProcessCT2
Chamada da execauto
@type  StaticFunction
@since 22/08/2022
@author Thiago Bussolin
@version 1.0
/*/ 
Static Function ProcessCT2(oContent,cEmpJson,cFilJson,aItensJson,cCt2key,nZ,aJson)

	Local aCab := {}
	Local aItens := {}
	Local nY := 0
	Local nW := 0
	Local nQtdCoHist := 0
	Local nTamHist := 0
	Local cHist := ""
	Local cLinha := ""
	Local _nQuantas := 0
	Local cLote     := ""
	Local cSubLote  := ""
	Local dDatLan   := StoD("")
	Local bBlock  := { || NIL }
	Local cTpsald := ""
	Local cCritConv := ""

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.

	aCab := {}
	aItens := {}

	_nQuantas := CtbMoedas()

	SetFunName("PROJETOGESPLAN") // Necessário para gravação dos campos CT2_ROTINA e CT2_KEY
							
	nTamHist := TamSx3("CT2_HIST")[1]
	cLote 	 := "008950" //Lote padrão Gesplan
	cSubLote := StrZero( 1,TamSx3("CT2_SBLOTE")[1] )
	dDatLan  := IIf(Empty(oContent[nZ]["CT2_DATA"]),dDataBase,CtoD(oContent[nZ]:GetJsonText("CT2_DATA")))

	aAdd(aCab, {'DDATALANC' , dDatLan  	,NIL} )	//CAMPO OBRIGATÓRIO
	aAdd(aCab, {'CLOTE' 	, cLote    	,NIL} )	//CAMPO OBRIGATÓRIO
	aAdd(aCab, {'CSUBLOTE' 	, cSubLote 	,NIL} )	//CAMPO OBRIGATÓRIO				
	aAdd(aCab, {'CPADRAO' 	, If(VALTYPE(oContent[nZ]['CPADRAO']) =="C",oContent[nZ]['CPADRAO'], '') 		,NIL} )	//CAMPO DEFAULT
	aAdd(aCab, {'NTOTINF' 	, 0 		,NIL} )	//CAMPO DEFAULT
	aAdd(aCab, {'NTOTINFLOT', 0 		,NIL} )	//CAMPO DEFAULT
				
	For nW := 1 to len(aItensJson)
					
		If nW == 1
			cLinha := StrZero( 1,TamSx3("CT2_LINHA")[1] )
		Else
			cLinha := Soma1(cLinha)
		EndIf

		cHist := IIf(Empty(aItensJson[nW]["CT2_HIST"]), '', DecodeUtf8(aItensJson[nW]:GetJsonText("CT2_HIST")))
		cTpsald := IiF(Empty(aItensJson[nW]["CT2_TPSALD"]),"1" , aItensJson[nW]:GetJsonText("CT2_TPSALD") )//CAMPO OPCIONAL

		cCritConv := IiF(Empty(aItensJson[nW]["CT2_CONVER"]), '1', IIf(len(aItensJson[nW]:GetJsonText("CT2_CONVER")) > _nQuantas, SubStr(aItensJson[nW]:GetJsonText("CT2_CONVER"),1,_nQuantas), SubStr(aItensJson[nW]:GetJsonText("CT2_CONVER"),1,len(aItensJson[nW]:GetJsonText("CT2_CONVER")))))

		aAdd(aItens,;
				  { {'CT2_FILIAL', 		cFilJson, 																										NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_LINHA', 		cLinha, 																										NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_MOEDLC', 		"01", 																											NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_DC', 			aItensJson[nW]["CT2_DC"], 																						NIL},; //CAMPO OBRIGATÓRIO
					IiF(Empty(aItensJson[nW]["CT2_DEBITO"]), {'CT2_DEBITO', '', NIL}, {'CT2_DEBITO', aItensJson[nW]:GetJsonText("CT2_DEBITO"), 			NIL}),; //CAMPO OPCIONAL/OBRIGATÓRIO DE ACORDO COM O TIPO DE LANÇAMENTO
					IiF(Empty(aItensJson[nW]["CT2_CREDIT"]), {'CT2_CREDIT', '', NIL}, {'CT2_CREDIT', aItensJson[nW]:GetJsonText("CT2_CREDIT"), 			NIL}),; //CAMPO OPCIONAL/OBRIGATÓRIO DE ACORDO COM O TIPO DE LANÇAMENTO
					{'CT2_VALOR', 		aItensJson[nW]["CT2_VALOR"], 																					NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_HP', 			'', 																											NIL},; //CAMPO DEFAULT
					{'CT2_HIST', 		SubStr(cHist, 1,  nTamHist),																					NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_CONVER', 		cCritConv, 																										NIL},; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_CCD"]), {'CT2_CCD', '', NIL}, {'CT2_CCD' , aItensJson[nW]:GetJsonText("CT2_CCD"),						NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_CCC"]), {'CT2_CCC', '', NIL}, {'CT2_CCC' , aItensJson[nW]:GetJsonText("CT2_CCC"), 					NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_ITEMD"]), {'CT2_ITEMD', '', NIL}, {'CT2_ITEMD', aItensJson[nW]:GetJsonText("CT2_ITEMD"), 		 		NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_ITEMC"]), {'CT2_ITEMC', '', NIL}, {'CT2_ITEMC', aItensJson[nW]:GetJsonText("CT2_ITEMC"), 				NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_CLVLDB"]), {'CT2_CLVLDB', '', NIL}, {'CT2_CLVLDB', aItensJson[nW]:GetJsonText("CT2_CLVLDB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_CLVLCR"]), {'CT2_CLVLCR', '', NIL}, {'CT2_CLVLCR', aItensJson[nW]:GetJsonText("CT2_CLVLCR"), 			NIL}),; //CAMPO OPCIONAL
					{'CT2_EMPORI', 		aItensJson[nW]:GetJsonText("CT2_EMPORI"), 																		NIL} ,; //CAMPO OBRIGATÓRIO
					{'CT2_FILORI', 		aItensJson[nW]:GetJsonText("CT2_FILORI"), 																		NIL} ,; //CAMPO OBRIGATÓRIO
					{'CT2_TPSALD',  	cTpsald, 																										NIL},;
					{'CT2_ORIGEM',		'GESPLAN', 																										NIL},;	 //CAMPO DEFAULT
					{'CT2_ROTINA', 		aItensJson[nW]["CT2_ROTINA"], 																					NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_AGLUT', 		aItensJson[nW]["CT2_AGLUT"], 																					NIL},; //CAMPO OBRIGATÓRIO
					{'CT2_LP',			IIf(VALTYPE(aItensJson[nW]["CT2_LP"])=="C", aItensJson[nW]["CT2_LP"], ''), 										NIL},; //CAMPO OPCIONAL
					{'CT2_KEY', 		aItensJson[nW]:GetJsonText("CT2_KEY"), 																			NIL} ,; //CAMPO OBRIGATÓRIO
					IiF(Empty(aItensJson[nW]["CT2_EC05DB"]), {'CT2_EC05DB', '', NIL}, {'CT2_EC05DB', aItensJson[nW]:GetJsonText("CT2_EC05DB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC05CR"]), {'CT2_EC05CR', '', NIL}, {'CT2_EC05CR', aItensJson[nW]:GetJsonText("CT2_EC05CR"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC06DB"]), {'CT2_EC06DB', '', NIL}, {'CT2_EC06DB', aItensJson[nW]:GetJsonText("CT2_EC06DB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC06CR"]), {'CT2_EC06CR', '', NIL}, {'CT2_EC06CR', aItensJson[nW]:GetJsonText("CT2_EC06CR"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC07DB"]), {'CT2_EC07DB', '', NIL}, {'CT2_EC07DB', aItensJson[nW]:GetJsonText("CT2_EC07DB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC07CR"]), {'CT2_EC07CR', '', NIL}, {'CT2_EC07CR', aItensJson[nW]:GetJsonText("CT2_EC07CR"), 			NIL}),;	//CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC08DB"]), {'CT2_EC08DB', '', NIL}, {'CT2_EC08DB', aItensJson[nW]:GetJsonText("CT2_EC08DB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC08CR"]), {'CT2_EC08CR', '', NIL}, {'CT2_EC08CR', aItensJson[nW]:GetJsonText("CT2_EC08CR"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC09DB"]), {'CT2_EC09DB', '', NIL}, {'CT2_EC09DB', aItensJson[nW]:GetJsonText("CT2_EC09DB"), 			NIL}),; //CAMPO OPCIONAL
					IiF(Empty(aItensJson[nW]["CT2_EC09CR"]), {'CT2_EC09CR', '', NIL}, {'CT2_EC09CR', aItensJson[nW]:GetJsonText("CT2_EC09CR"), 			NIL}) }) //CAMPO OPCIONAL

		If Len(cHist) > nTamHist // Tratamento para continuação de histórico
			//inteiro primeiro hist é gravado restando resultado da divisão menos 1
			//decimal primeiro hist é gravado restando para gravação resultado da divisão
			IIf (((Len(cHist) / nTamHist) % 1 == 0), nQtdCoHist := (Len(cHist) / nTamHist) - 1 , nQtdCoHist := Len(cHist) / nTamHist)

			For nY := 1 to nQtdCoHist //adiciono no array a quantidade de linhas necessária para gravação da continuação de histórico
			
				cLinha := Soma1(cLinha)
				aAdd(aItens,  { {'CT2_FILIAL', 			oContent[nZ]:GetJsonText("CT2_FILIAL"), 										NIL},;
								{'CT2_LINHA', 			cLinha, 																		NIL},; 
								{'CT2_MOEDLC', 			"01", 																			NIL},;
								{'CT2_DC',				"4", 																			NIL},;
								{'CT2_HIST',			SubStr(cHist, (nY * nTamHist) + 1, nTamHist),									NIL},;
								{'CT2_EMPORI', 			aItensJson[nW]:GetJsonText("CT2_EMPORI"), 										NIL},;
								{'CT2_FILORI', 			aItensJson[nW]:GetJsonText("CT2_FILORI"), 										NIL},; 
								{'CT2_TPSALD', 			cTpsald, 																		NIL},;
								{'CT2_ORIGEM', 			"GESPLAN", 																		NIL},;	
								{'CT2_ROTINA', 			aItensJson[nW]["CT2_ROTINA"], 													NIL},;	
								{'CT2_KEY', 			aItensJson[nW]:GetJsonText("CT2_KEY") , 										NIL} })
			Next nY
		EndIf
	Next nW

	lMsErroAuto := .F.

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	
	BEGIN SEQUENCE
		FWLogMsg('INFO',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0016 + cCt2key)// "Início do processamento da execauto. KEY: "
		MSExecAuto({|x, y, z| CTBA102(x, y, z)}, aCab, aItens, 3)

		If lMsErroAuto
			FWLogMsg('WARN',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0017 + cCt2key )// "Processamento da execauto retornou erro na inclusão. KEY: "
			IncResp( GETAUTOGRLOG(),@aJson, ""/*cError*/ ,oContent,nZ ,cEmpJson,cFilJson ,cCt2key,""/*cDOC*/)
		Else
			FWLogMsg('INFO',, 'CTBI102G',,,, 'CTBI102GLog - '+ STR0018 + cCt2key )// "Processamento da execauto retornou sucesso na inclusão. KEY: "
			IncResp( GETAUTOGRLOG(),@aJson, ""/*cError*/ ,oContent,nZ ,cEmpJson ,cFilJson ,cCt2key,CT2->CT2_DOC)
		EndIf

		RECOVER
				
		IncResp( GETAUTOGRLOG(),@aJson, STR0009 /*cError*/ ,oContent,nZ ,cEmpJson ,cFilJson,cCt2key,""/*cDOC*/) //"Protheus error: Erro interno. "

	END SEQUENCE
	
	ErrorBlock(bBlock)
	aSize(aCab,0)
	aCab := nil
	aSize(aItens,0)
	aItens := nil

Return
