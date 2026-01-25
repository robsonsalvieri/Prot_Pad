#INCLUDE "Protheus.CH"
#include "TOTVS.ch"
#include "TBICONN.ch"
#include "FINI100G.ch"

#DEFINE ValidSM0		1
#DEFINE MessageError	2
#DEFINE CodeGesplan		3
#DEFINE IDGesplan		4
#DEFINE CompanyId		5
#DEFINE BranchId		6
#DEFINE EventType		7
#DEFINE MessageContent	8
#DEFINE CdExtnalHeader	9

Static __oObjSE5 as Object

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe de Integração com Gesplan via smartlink

@author TOTVS
@since 09/2022
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Class MOVreadXGspMessageReader from LongNameClass

	Data lSuccess		As Logical
	Data aDataBank  	As Array
	Data aDataResponse 	As Array	
	Data cEmpMsg		As Character
	Data cFilMsg		As Character	
	Data cTenantId		As Character	
	Data nQtdSuccess	As Numeric
	Data nQtdError		As Numeric
		
    Method New() Constructor
    Method Read()
	Method FormatData()
	Method F100GLog()
	Method SendResponse()
 
End Class
											

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author TOTVS
@since 09/2022
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method New() Class MOVreadXGspMessageReader
 
	::lSuccess		:= .T.
	::aDataBank 	:= {}
	::aDataResponse := {}
	::cEmpMsg		:= ""
	::cFilMsg		:= ""	
	::cTenantId		:= ""	
	::nQtdSuccess	:= 0
	::nQtdError		:= 0

Return Self
 

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Read()
Responsável pela leitura e processamento da mensagem.

@author TOTVS
@since 09/2022
@version 1.0
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
//-----------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class MOVreadXGspMessageReader

	Local nZ				As Numeric
	Local nX				As Numeric
	Local cFunBkp			As Character
	Local aAreaAnt			As Array
	Local oResp 			As Object
	Local oContent 			As Object
	Local aListContent		As Array
	Local aReturn			As Array
	Local nLenDtBnk         As Numeric
	Local nLenRet			As Numeric
    
	cFunBkp  := FunName()
	aAreaAnt := FwGetArea()
	aReturn  := {}

	oResp 	 := JsonObject():new()
	oContent := JsonObject():new()

    oContent:FromJSON(oLinkMessage:RawMessage())
	aListContent	:= oContent['data']
	::cTenantId 	:= oContent['tenantId']    

	//-- Organiza os dados recebidos por empresa/filial
	::FormatData(aListContent)

	::F100GLog(1)
	nLenDtBnk := Len(::aDataBank) 
	For	nZ := 1 To nLenDtBnk 

		If ::aDataBank[nZ,ValidSM0] //--Empresa/Filial válidos
			If ::cEmpMsg <> ::aDataBank[nZ,CompanyId] 
					
				::cEmpMsg := ::aDataBank[nZ,CompanyId]
				::cFilMsg := ::aDataBank[nZ,BranchId]	
						
				//-- Faz a inclusão de todos movimentos desse Grupo de Empresas 
				::F100GLog(2)			
				
				aReturn := StartJob("F100GPROC", GetEnvServer(), .T., ::cEmpMsg, ::cFilMsg, aClone(::aDataBank), __cUserID )				
				
				::F100GLog(8)

				If Len(aReturn) > 0
					::F100GLog(9) //Processamento do movimento bancario
					nLenRet := Len(aReturn) 
					For nX := 1 to nLenRet
						Aadd(::aDataResponse, JsonObject():new())
						::aDataResponse[Len(::aDataResponse)]["CompanyId"]	:= aReturn[nX,CompanyId]
						::aDataResponse[Len(::aDataResponse)]["BranchId"]	:= aReturn[nX,BranchId]
						::aDataResponse[Len(::aDataResponse)]["SYSCODE"]	:= aReturn[nX,CodeGesplan]
						::aDataResponse[Len(::aDataResponse)]["ID"]			:= aReturn[nX,IDGesplan]			
						::aDataResponse[Len(::aDataResponse)]["error"]		:= FWhttpEncode(aReturn[nX,MessageError])
						::aDataResponse[Len(::aDataResponse)]["CdExtHeader"]:= aReturn[nX,CdExtnalHeader]		
					Next nX
				EndIf

			EndIF
		Else
			Aadd(::aDataResponse,JsonObject():new())
			::aDataResponse[Len(::aDataResponse)]["CompanyId"]	:= ::aDataBank[nZ,CompanyId]
			::aDataResponse[Len(::aDataResponse)]["BranchId"]	:= ::aDataBank[nZ,BranchId]
			::aDataResponse[Len(::aDataResponse)]["SYSCODE"]	:= ::aDataBank[nZ,CodeGesplan]
			::aDataResponse[Len(::aDataResponse)]["ID"]			:= ::aDataBank[nZ,IDGesplan]			
			::aDataResponse[Len(::aDataResponse)]["error"]		:= FWhttpEncode(::aDataBank[nZ,MessageError])
			::aDataResponse[Len(::aDataResponse)]["CdExtHeader"]:= ::aDataBank[nZ,CdExtnalHeader]
		EndIF
		
	Next nZ

	//-- Envia mensagem de resposta para a fila MovRespXGsp
	If Len(::aDataResponse) > 0		
		
		aEval( ::aDataResponse, {|x| Iif( Empty(x:GetJsonText("error")), ::nQtdSuccess++, ::nQtdError++ ) })
		::F100GLog(10)

		oResp:set(::aDataResponse)
		::SendResponse(oResp:toJSON(), ::cTenantId )				
		::F100GLog(11)
	EndIF
	::F100GLog(12)

	SetFunName(cFunBkp)	
	FwRestArea(aAreaAnt)

	FwFreeArray(aAreaAnt)
	FwFreeArray(::aDataBank)	
	FwFreeArray(::aDataResponse)
	FwFreeArray(aListContent)
	FwFreeArray(aReturn)

	FwFreeObj(oResp)
	FwFreeObj(oContent)

Return .T. // .T. apaga a mensagem da fila do smartlink


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FormatData()
Organiza os dados recebidos pelo smartlink

@author Fabio Zanchim
@since 02/2024
@version 1.0
@param aListContent, object, atributo Data recebido na mensagem 
/*/
//-----------------------------------------------------------------------------------------
Method FormatData( aListContent ) Class MovreadXGspMessageReader

	Local nZ 	 	as Numeric
	Local nPos 	 	as Numeric
	Local nField 	as Numeric
	Local nLenList	as Numeric
	Local nLenField	as Numeric
	Local nLenBranch  as Numeric 
	Local cField 	as Character
	Local aSM0 		as Array
	Local aFields 	as Array
	Local aDataJson as Array

	aSM0 := FWLoadSM0()    	

	nLenList := Len(aListContent)
	For	nZ := 1 To nLenList
		
		aDataJson	:= {}
		aFields 	:= aListContent[nZ]:GetNames()//Chaves de cada movimento (chaves variáveis)
		nLenField	:= Len(aFields)

		For nField:=1 To nLenField
			cField:=Alltrim(aFields[nField])	        
			If !(cField $ "SYSCODE|ID|CompanyId|BranchId|E5_RECPAG")
				aAdd(aDataJson, {cField, aListContent[nZ]:GetJsonText(aFields[nField])})
			EndIF
	    Next
		
		Aadd(::aDataBank,{.T.,;										// 1 ValidSM0
						'',;										// 2 MessageError
						aListContent[nZ]:GetJsonText("SYSCODE"),;	// 3
						aListContent[nZ]:GetJsonText("ID"),;		// 4
						aListContent[nZ]:GetJsonText("CompanyId"),; // 5
						aListContent[nZ]:GetJsonText("BranchId"),;	// 6
						aListContent[nZ]:GetJsonText("E5_RECPAG"),;	// 7						
						aClone(aDataJson),; // Campos Variaveis		// 8
						''}) 										// 9 CdExtnalHeader
		
		nLenBranch := Len(::aDataBank)
		If (nPos:=aScan(aSM0,  { |x| Alltrim(x[1])+AllTrim(x[2]) == AllTrim(::aDataBank[nLenBranch,CompanyId]) + AllTrim(::aDataBank[nLenBranch,BranchId])  })) == 0
			::aDataBank[nLenBranch,ValidSM0]		:= .F.
			::aDataBank[nLenBranch,MessageError]	:= STR0002 //"Empresa e/ou Filial inválidos."
		Else
			::aDataBank[nLenBranch,BranchId] := PadR(::aDataBank[nLenBranch,BranchId],aSM0[nPos,8])// Ajusta tamanho da Filial
		EndIF
	Next nZ

	//-- Ordena por empresa+filial para evitar chamadas excessivas de RpcSetEnv
	If Len(::aDataBank) > 0
		aSort(::aDataBank,,,{|x,y| x[CompanyId]+x[BranchId] < y[CompanyId]+y[BranchId] })
	EndIF
	
	FwFreeArray(aSM0)
	FwFreeArray(aFields)
	FwFreeArray(aDataJson)

Return Nil



//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} SendResponse()
Resposta da mensagem

@author TOTVS
@since 09/2022
@version 1.0
@param oResp, object, mensagens de retorno do todos movimentos bancários 
@param cTenantId, Character, identificação do tenant
/*/
//-----------------------------------------------------------------------------------------
Method SendResponse( oResp, cTenantId ) Class MovreadXGspMessageReader

	Local oClient	 As Object    
	Local cMessage	 As Character
	Local cTimestamp As Character 

	cMessage	:= ""
	oClient		:= FwTotvsLinkClient():New()
	cTimestamp	:= FWTimeStamp(5, Date(), Time())	
	
	BeginContent Var cMessage
	{
		"specversion": "1.0",
		"time": "%Exp:cTimestamp%" ,
		"type": "MOVrespXGsp",
		"tenantId": "%Exp:cTenantId%" ,
		"data": %Exp:oResp%
	}
	EndContent

    ::lSuccess := oClient:SendAudience("MOVrespXGsp","LinkProxy", cMessage)
	FreeObj(oClient)

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintLog()
Log 

@author Fabio Zanchim
@since 04/2024
@version 1.0
@param nId, Numeric, identificador da mensagem a ser impressa
/*/
//-----------------------------------------------------------------------------------------
Method F100GLog( nId ) Class MovreadXGspMessageReader

	Local cMsgRet As Character
	Local cMsgSty As Character

	Do Case
	Case nId == 1		
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( STR0005, {::cTenantId,Str(Len(::aDataBank),3)} ) )//"Iniciando processamento para tenant #1 - Quantidade de registros: #2"
	Case nId == 2
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( STR0006, {::cEmpMsg, ::cFilMsg} ) )//"Início da tarefa para Empresa/Filial: #1/#2"
	Case nId == 8
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( STR0007, {::cEmpMsg, ::cFilMsg} ) )//"Fim da tarefa para Empresa/Filial: #1/#2"
	Case nId == 9
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+"Processamento do movimento bancario" ) // "Processamento do movimento bancario"
	Case nId == 10
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( STR0011, {Str(::nQtdSuccess,3), Str(::nQtdError,3)} ) )//"Finalizados com sucesso: #1 - Finalizados com falha: #2
	Case nId == 11
		cMsgRet := STR0009 //"Falha no envio da resposta para fila MOVrespXGsp."
		cMsgSty := 'WARN' 
		If ::lSuccess
			cMsgRet := STR0008 //"Sucesso no envio da resposta para fila MOVrespXGsp."
			cMsgSty := 'INFO'
		EndIf
		FWLogMsg(cMsgSty,, 'FINI100G',,,, 'F100GLog - '+cMsgRet )
	Case nId == 12
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( STR0010, { ::cTenantId } ) )//"Fim do processamento para tenant #1"
	EndCase

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} F100GProc()
Thread para processamento dos Movimentos Bancários

@author Fabio Zanchim
@since 04/2024
@version 1.0

@param cCompany, character, código do grupo de empresa 
@param cBranch, character, código da filial 
@param aData, array, dados recebidos via smartlink
@param cCodUser, character, código do usuário que startou a thread principal
/*/
//-----------------------------------------------------------------------------------------
Function F100GProc(cCompany as Character, cBranch as Character, aData as Array, cCodUser as Character)

	Local nPos 				as Numeric
	Local aProcessed 		as Array
	Local cMessage			as Character
	Local cBranchAtu		as Character
	Local nLenData          as Numeric
	Local cFkIdMov			as Character
	Local aRetMssge			as Array

	Private oHashFields 	as Object
	Private lMsErroAuto     as Logical
	Private lMsHelpAuto		as Logical
	Private lAutoErrNoFile	as Logical

	Default cCompany := ""
	Default cBranch  := ""
	Default aData    := {}
	Default cCodUser := ""

	lMsErroAuto		:= .F.
	lMsHelpAuto		:= .T.
	lAutoErrNoFile	:= .T.	
	
	cMessage 	:= ''
	cBranchAtu	:= ''
	aProcessed 	:= {}
	cFkIdMov	:= ''
	aRetMssge	:= {}

	RPCSetType(3) 
	RPCSetEnv(cCompany, cBranch,,, 'FIN', 'FINI100G') 
	cBranchAtu := cFilAnt

	//-- Atualiza usuário da thread inicial para respeitar parametrização do ambiente 
	If GetRPORelease() < "12.1.2510"
		__cUserID := cCodUser
	EndIf

	//-- Lista a estrutura do dicionário SE5 
	SetHashFields()

	nLenData := Len(aData) 
	For	nPos := 1 To nLenData
		
		//::F100GLog(3) //Inicio processamento dos dados
		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( "Inicio processamento dos dados para Empresa/Filial: #1/#2", {cCompany, cBranch} ) )//"Inicio processamento dos dados para Empresa/Filial: #1/#2"

		cMessage := ''		
		If AllTrim(cEmpAnt) == AllTrim(aData[nPos,CompanyId]) .And. aData[nPos,ValidSM0] 

			//::F100GLog(4) //Inicio de verificação das informações básicas obrigatórias
			FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+I18N( "Inicio de verificação das informações básicas obrigatórias", {cCompany, cBranch} ) )//"Inicio de verificação das informações básicas obrigatórias"

			// Verifica informações básicas obrigatórias
			cMessage := CheckData( aData[nPos] ) 
			cFkIdMov := ""
			If Empty(cMessage)

				//- ajusta os padrões
				cBranch := Padr(aData[nPos,BranchId],Len(cFilAnt))
				If cBranchAtu <> cBranch
					cBranchAtu := cBranch
					cFilAnt := cBranch
				EndIf
			
				//-- Execução do Movimento Bancário (execauto FINA100)					
				aRetMssge := ProcessData( aData[nPos] )
				cMessage := aRetMssge[1]
				cFkIdMov := aRetMssge[2]
			EndIf
			
			//-- Atualiza ocorrências do execauto
			aData[nPos, MessageError ] := cMessage
			aData[nPos, CdExtnalHeader] := cFkIdMov
			aAdd(aProcessed, aClone(aData[nPos]))
		EndIf
	Next nPos

	If __oObjSE5 <> Nil
		FwFreeObj(__oObjSE5)
	EndIf

	RpcClearEnv() 

Return( aProcessed )

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} setHashFields()
Lista a estrutura do dicionário SE5 para a empresa corrente

@author Fabio Zanchim
@since 02/2024
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Static Function SetHashFields() 

	Local nX 		as Numeric
	Local nQtd		as Numeric
	Local aFields	as Array
	
	oHashFields := tHashMap():new()

	aFields := FWSx3Util():GetListFieldsStruct('SE5',.F.)
	nQtd	:= Len(aFields)	
	For nX := 1 To nQtd

		oHashFields:Set(aFields[nX,1], aFields[nX,2]) //Chave:x3_campo, Valor:x3_tipo
	Next nX
	
	FwFreeArray(aFields)

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckData()
Verifica informações básicas obrigatórias

@author Fabio Zanchim
@since 02/2024
@version 1.0
@param nPos, Numeric, movimento que esta sendo processado
@return character, indica problema com algum campo obrigatório
/*/
//-----------------------------------------------------------------------------------------
Static Function CheckData( aData )

	Local cMessage As Character 

	cMessage := ''		
	If Empty(aData[MessageContent]) .Or.;
			"null" $ aData[CodeGesplan]+;
				 	 aData[IDGesplan]+;
				 	 aData[EventType]
				 
		cMessage += STR0003 //"Campos obrigatórios não informados ou vazio."		
	EndIF	

Return( cMessage )


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessData()
Converte data types e inclui movimento bancário
@type StaticFunction
@author Fabio Zanchim
@since 02/2024
@version 1.0
@param aData, array, movimento que esta sendo processado dos dados recebidos via smartlink 
@return character, indica problemas na inclusão do movimento bancário
/*/
//-----------------------------------------------------------------------------------------
Static Function ProcessData( aData )
	
	Local nX			as Numeric
	Local nOpc			as Numeric
	Local aMov			as Array
	Local aCab			as Array
	Local aLog			as Array
	Local cField 		as Character
	Local cType 		as Character
	Local xContent  	as Character
	Local cMsgAux		as Character
	Local cMessageFail 	as Character
	Local cRetIdMov		as Character
	Local cEventType 	as Character
	Local lFieldFail 	as Logical
	Local lAchouSE5 	as Logical
	Local nLenMov       as Numeric
	Local nLenLog		as Numeric
	Local nRecnoSE5		as Numeric
	Local aChvMov		as Array
	
	aCab 		 := {}
	aChvMov 	 := {}
	lFieldFail 	 := .F.
	lAchouSE5 	 := .F.
	cMessageFail := ''
	cRetIdMov	 := ''
	cEventType   := ""
	aMov 		 := aClone(aData[MessageContent])
	nLenMov 	 := Len(aMov)
	nRecnoSE5	 := 0
	nPosIdOrig   := AScan(aMov, {|x| x[1] == "IDMOV"})

	For nX := 1 To nLenMov

		cEventType := AllTrim(aData[EventType])
	
		If cEventType == "Z" .And. (nPosIdOrig == 0 .Or. Empty(aMov[nPosIdOrig, 2]))
			lFieldFail	 := .T.	
			cMessageFail := STR0014 //IDMOV não informado
			Exit
		EndIf

		If aMov[nX, 1] == "IDMOV"
			cField 	    := "E5_IDORIG"
		Else
			cField 	   := AllTrim(aMov[nX,1])
		EndIf

		If cEventType $ "S|E|Z" //Movimento Bancário (Entrada, Saída e Estorno)
			If oHashFields:Get(cField, @cType)
				If cType=='D'
					xContent:=CtoD(aMov[nX,2])
				ElseIf cType=='N'
					xContent:=Val(aMov[nX,2])
				Else
					If cField $ "E5_HISTOR|E5_BENEF"
						xContent := DecodeUtf8(aMov[nX,2])
					Else
						xContent:=aMov[nX,2]
					EndIf
				EndIf
			Else
				lFieldFail	:= .T.	
				cMessageFail:= I18N( STR0001, {cField} ) //"Campo nao existe no dicionário"
				Exit
			EndIF
		ElseIf cEventType == 'T' //Transferência Bancária

			If cField == "DDATACRED"
				xContent:=CtoD(aMov[nX,2])
				dDatabase := xContent
				cType := "D"
			ElseIf cField $ "NVALORTRAN|NCTBONLINE"
				xContent:=Val(aMov[nX,2])
				cType := "N"
			Else
				If cField $ "CHIST100|CBENEF100"
					xContent := DecodeUtf8(aMov[nX,2])
				Else
					xContent := aMov[nX,2]
				EndIf
				cType := "C"
			EndIf

		ElseIf cEventType == 'X' //Estorno da Transferência

			If cField == "AUTDTMOV"
				xContent:=CtoD(aMov[nX,2])
				dDatabase := xContent 
				cType := "D"
			Else
				xContent:=aMov[nX,2]
				cType := "C"
			EndIf	

		EndIf	

		If cType == 'D' .And. Empty(xContent) 
			lFieldFail	:= .T.					
			cMessageFail:= I18N( STR0004, { cField, cType } ) //"Valor inválido para tipo do campo" //"Valor esperado"
			Exit			
		ElseIf cType =='N' .And. !IsNumeric(StrTran(aMov[nX,2],'.',''))
			lFieldFail	:= .T.					
			cMessageFail:= I18N( STR0004, { cField, cType } ) //"Valor inválido para tipo do campo" //"Valor esperado"
			Exit
		Else				
			aAdd(aCab, {cField, xContent, Nil} )
		EndIf
	Next nX

	If !lFieldFail	
		If cEventType == 'S' //Saída - Pagar
			nOpc := 3
		ElseIf cEventType == 'E' //Entrada - Receber
			nOpc := 4
		ElseIf cEventType == 'Z' //Estorno Movimento bancário (Entrada/Saída)
			nOpc := 6
		ElseIf cEventType == 'T' //Transferência de Contas
			nOpc := 7
		ElseIf cEventType == 'X' //Estorno Transferência
			nOpc := 8
		EndIf

		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+"Início do processamento da execauto FINA100" ) 

		If nOpc == 7 .Or. nOpc == 8
			aChvMov := GetChavMov(aCab,nOpc)
		ElseIf nOpc == 6
			nPosIdOrig  := AScan(aCab, {|x| x[1] == "E5_IDORIG"})
			nRecnoSE5	:= FindSE5(aCab[nPosIdOrig, 2])
			If lAchouSE5 := (nRecnoSE5 == 0)
				cMessageFail :=  STR0015 +  aCab[nPosIdOrig, 2] + STR0016
			EndIf
		EndIf

		If !lAchouSE5
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0 ,aCab, nOpc ) 
		EndIf

		FWLogMsg('INFO',, 'FINI100G',,,, 'F100GLog - '+"Fim do processamento da execauto FINA100" )//"Fim do processamento da execauto FINA100"
		
		If lMsErroAuto
			cMsgAux := ('[Log inicio]' + CRLF)//Conteúdo fixo para replace na automação com UTVldSmtLink
			cMsgAux += ('[Empresa/Filial: ' + cEmpAnt + '/' + cFilAnt + ']' + CRLF)
			
			cMessageFail := cMsgAux
			aLog := GetAutoGRLog()
			nLenLog := Len(aLog)				
			For nX := 1 To nLenLog
				cMessageFail += Alltrim(aLog[nX]) + CRLF
			Next nX
			cMessageFail += '[Log fim]'//Conteúdo fixo para replace na automação com UTVldSmtLink

			//::F100GLog(7) // "Processamento da execauto retornou erro na movimentação."
			FWLogMsg('WARN',, 'FINI100G',,,, 'F100GLog - '+"Processamento da execauto retornou erro na movimentação" )//"Processamento da execauto retornou erro na movimentação"
		Else
			If nOpc == 7 .Or. nOpc == 8
				cRetIdMov := GFK5IdMov(aChvMov,nOpc)			
			ElseIf !lAchouSE5
				cRetIdMov := FK5->FK5_IDMOV
			EndIf
		EndIf
	EndIF

	FwFreeArray(aMov)
	FwFreeArray(aCab)
	FwFreeArray(aLog)

Return( {cMessageFail,cRetIdMov} )

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} GetChavMov()
Busca as chaves do movimento 
@type StaticFunction
@author Bruno Rosa
@since 07/2025
@version 1.0
@param aCab, array, dados para serem processados para compor a chave
@param nOpc, numeric, opção de processamento 
@return array, retorno da chave
/*/
//-----------------------------------------------------------------------------------------
Static Function GetChavMov(aCab as Array, nOpc as Numeric)
	
	Local aRet	as Array
	Local nW	as Numeric
	Local cFilMov as Character
	Local cBncMov as Character
	Local cAgcMov as Character
	Local cCntMov as Character
	Local cDatMov as Character
	Local cNtzMov as Character
	Local cRpgMov as Character
	Local cBncDst as Character
	Local cAgcDst as Character
	Local cCntDst as Character
	Local cNtzDst as Character
	Local cRpgDst as Character
	Local aRetrn1 as Array
	Local cNroMov as Character
	Local nTamBnc as Numeric
	Local nTamAgc as Numeric
	Local nTamCnt as Numeric
	Local nTamNtz as Numeric

	Default aCab := {}
	Default nOpc := 0

	aRet    := {}
	nW		:= 0
	cBncMov := ""
	cAgcMov := ""
	cCntMov := ""
	cDatMov := ""
	cNtzMov := ""
	cRpgMov := ""
	cBncDst := ""
	cAgcDst := ""
	cCntDst := ""
	cNtzDst := ""
	cRpgDst := ""
	aRetrn1 := {}
	cNroMov := ""
	cFilMov := cFilAnt
	nTamBnc := TamSx3("FK5_BANCO")[1]
	nTamAgc := TamSx3("FK5_AGENCI")[1]
	nTamCnt := TamSx3("FK5_CONTA")[1]
	nTamNtz := TamSx3("FK5_NATURE")[1]

	If nOpc == 7 //Transferência de Contas

		For nW := 1 to Len(aCab)

			If AllTrim(aCab[nW,1]) == "CBCOORIG"
				cBncMov := PADR(aCab[nW,2],nTamBnc)
			ElseIf AllTrim(aCab[nW,1]) == "CAGENORIG"
				cAgcMov := PADR(aCab[nW,2],nTamAgc)
			ElseIf AllTrim(aCab[nW,1]) == "CCTAORIG"
				cCntMov := PADR(aCab[nW,2],nTamCnt)
			ElseIf AllTrim(aCab[nW,1]) == "DDATACRED"
				cDatMov := DTOS(aCab[nW,2])
			ElseIf AllTrim(aCab[nW,1]) == "CNATURORI"
				cNtzMov := PADR(aCab[nW,2],nTamNtz)
			ElseIf AllTrim(aCab[nW,1]) == "CBCODEST"
				cBncDst := PADR(aCab[nW,2],nTamBnc)
			ElseIf AllTrim(aCab[nW,1]) == "CAGENDEST"
				cAgcDst := PADR(aCab[nW,2],nTamAgc)
			ElseIf AllTrim(aCab[nW,1]) == "CCTADEST"
				cCntDst := PADR(aCab[nW,2],nTamCnt)
			ElseIf AllTrim(aCab[nW,1]) == "CNATURDES"
				cNtzDst := PADR(aCab[nW,2],nTamNtz)
			ElseIf AllTrim(aCab[nW,1]) =="CDOCTRAN"
				cNroMov := aCab[nW,2]	
			EndIf
		
		Next nw

		aAdd(aRetrn1,{cFilMov,cBncMov,cAgcMov,cCntMov,cDatMov,cNtzMov,cNroMov})
		aAdd(aRetrn1,{cFilMov,cBncDst,cAgcDst,cCntDst,cDatMov,cNtzDst,cNroMov})	

	ElseIf nOpc == 8 //Estorno Transferência

		For nW := 1 to Len(aCab)

			If AllTrim(aCab[nW,1]) == "AUTBANCO"
				cBncMov := PADR(aCab[nW,2],nTamBnc)
			ElseIf AllTrim(aCab[nW,1]) == "AUTAGENCIA"
				cAgcMov := PADR(aCab[nW,2],nTamAgc)
			ElseIf AllTrim(aCab[nW,1]) == "AUTCONTA"
				cCntMov := PADR(aCab[nW,2],nTamCnt)
			ElseIf AllTrim(aCab[nW,1]) == "AUTDTMOV"
				cDatMov := DTOS(aCab[nW,2])
			ElseIf AllTrim(aCab[nW,1]) == "AUTNRODOC"
				cNroMov := aCab[nW,2]
			EndIf
		
		Next nw

		aAdd(aRetrn1,{cFilMov,cBncMov,cAgcMov,cCntMov,cDatMov,cNtzMov,cNroMov})
	EndIf
	
Return aRetrn1

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} GFK5IdMov()
Busca o IdMov da tabela FK5
@type StaticFunction
@author Bruno Rosa
@since 07/2025
@version 1.0
@param aCab, array, dados para serem processados para compor a chave
@param nOpc, numeric, opção de processamento 
@return character, retorno do idmov
/*/
//-----------------------------------------------------------------------------------------
Static Function GFK5IdMov(aChvMov as Array, nOpc as Numeric)

	Local aAreaFk5	as Array
	Local aArea		as Array
	Local cRetFk5ID	as Character
	Local cTpRet	as Character
	Local cQry		as Character
    Local cTmp		as Character    
    Local oQuery	as Object 

	Default aChvMov := {}
	Default nOpc := ""

	aAreaFk5	:= FK5->(GetArea())
	aArea		:= GetArea()  
	cTpRet		:= ""
	cRetFk5ID	:= ""
	cQry		:= ""
	cTmp		:= ""
	oQuery		:= Nil
    
    cQry := " SELECT "
    cQry += "   FK5_FILIAL,FK5_IDMOV,FK5_NUMCH,FK5_DOC,FK5_DATA,FK5_PROTRA "
    cQry += " FROM "
    cQry += "   "+ RetSqlName("FK5") +" FK5 "
    cQry += " WHERE "
    cQry += "   FK5.FK5_FILIAL = ? "
    cQry += "   AND FK5.FK5_BANCO = ? "
    cQry += "   AND FK5.FK5_AGENCI = ? "
	cQry += "   AND FK5.FK5_CONTA = ? "
	cQry += "   AND FK5.FK5_DATA = ? "
	If nOpc == 7
		cQry += "   AND FK5.FK5_NATURE = ? "
		cQry += "   AND FK5.D_E_L_E_T_ = ? "
		cQry += "   AND FK5.FK5_NUMCH = ? "	
		cQry += "   AND FK5.FK5_RECPAG = ? "
	ElseIf nOpc == 8
		cQry += "   AND FK5.D_E_L_E_T_ = ? "
		cQry += "   AND FK5.Fk5_TPDOC = ? "	
		cQry += "   AND (FK5.FK5_NUMCH = ? "
		cQry += "   OR FK5.FK5_DOC = ? )"
	EndIf	

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)

    oQuery:SetString(1,aChvMov[1][1])
    oQuery:SetString(2,aChvMov[1][2])
    oQuery:SetString(3,aChvMov[1][3])
	oQuery:SetString(4,aChvMov[1][4])
	oQuery:SetString(5,aChvMov[1][5])

	If nOpc == 7
		oQuery:SetString(6,aChvMov[1][6])
		oQuery:SetString(7,' ')
		oQuery:SetString(8,aChvMov[1][7])		
		oQuery:SetString(9,'P')			
	Else
		oQuery:SetString(6,' ')
		oQuery:SetString(7,'TR')
		oQuery:SetString(8,aChvMov[1][7])
		oQuery:SetString(9,aChvMov[1][7])
	EndIf

	//Abertura da Area da consulta
    cTmp := oQuery:OpenAlias()

    If !(cTmp)->(Eof())
		If nOpc == 7
			cRetFk5ID += STR0012 //"Origem: "
		ElseIf nOpc == 8
			If !Empty((cTmp)->FK5_NUMCH)
				cTpRet := "P"
				cRetFk5ID += STR0012 //"Origem: "				
			ElseIf !Empty((cTmp)->FK5_DOC)
				cTpRet := "R"
				cRetFk5ID += STR0013 //"Destino: "
			EndIf
		EndIf
        cRetFk5ID += (cTmp)->FK5_IDMOV
    EndIf
	
	If nOpc == 7 //Transferencia de Contas

		cRetFk5ID += "|" + STR0013 //"Destino: "
		cRetFk5ID += BscTrsfP2(aChvMov[2])
	
	ElseIf nOpc == 8 //Estorno

		cRetFk5ID += BscEstP2((cTmp)->FK5_FILIAL,(cTmp)->FK5_DATA,(cTmp)->FK5_PROTRA,cTpRet)

	EndIf

	(cTmp)->(DbCloseArea())

	RestArea(aAreaFk5)
	FwFreeArray(aAreaFk5)
	RestArea(aArea)
	FwFreeArray(aArea)

Return cRetFk5ID

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} BscTrsfP2()
Busca IDMOV da outra conta da transferencia
@type StaticFunction
@author Bruno Rosa
@since 08/2025
@version 1.0
@param aDadosMov, arrays, Dados do movimento bancario
@return character, retorno do idmov
/*/
//-----------------------------------------------------------------------------------------
Static Function BscTrsfP2(aDadosMov as Array)

    Local cRet	as Character
    Local cQry	as Character
    Local cTmp	as Character    
    Local oQuery	as Object 
	Local aArea	as Array

	Default aDadosMov := {}

    cRet	:= ""
    cQry	:= "" 
	cTmp	:= ""
	oQuery	:= Nil 
	aArea	:= GetArea()   
    
    cQry := " SELECT "
    cQry += "   FK5_IDMOV "
    cQry += " FROM "
    cQry += "   "+ RetSqlName("FK5") +" FK5 "
    cQry += " WHERE "
    cQry += "   FK5.FK5_FILIAL = ? "
    cQry += "   AND FK5.FK5_BANCO = ? "
    cQry += "   AND FK5.FK5_AGENCI = ? "
	cQry += "   AND FK5.FK5_CONTA = ? "
	cQry += "   AND FK5.FK5_DATA = ? "
	cQry += "   AND FK5.FK5_NATURE = ? "
	cQry += "   AND FK5.FK5_DOC = ? "
	cQry += "   AND FK5.FK5_RECPAG = ? "
    cQry += "   AND FK5.D_E_L_E_T_ = ? "

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)
  
    oQuery:SetString(1,aDadosMov[1])
    oQuery:SetString(2,aDadosMov[2])
    oQuery:SetString(3,aDadosMov[3])
	oQuery:SetString(4,aDadosMov[4])
	oQuery:SetString(5,aDadosMov[5])
	oQuery:SetString(6,aDadosMov[6])
	oQuery:SetString(7,aDadosMov[7])
	oQuery:SetString(8,'R')
	oQuery:SetString(9,' ')

    //Abertura da Area da consulta
    cTmp := oQuery:OpenAlias()

    If !(cTmp)->(Eof())
        cRet += (cTmp)->FK5_IDMOV
    EndIf

    (cTmp)->(DbCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)

Return cRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} BscEstP2()
Busca IDMOV da outra conta de estorno
@type StaticFunction
@author Bruno Rosa
@since 07/2025
@version 1.0
@param cFilFk5, character, Filial do movimento
@param cData, character, Data do movimento 
@param cProtra, character, Processo da transferencia
@param cTpRet, character, Tipo do retorno 
@return character, retorno do idmov
/*/
//-----------------------------------------------------------------------------------------
Static Function BscEstP2(cFilFk5 as Character, cData as Character, cProtra as Character, cTpRet as Character)
	
    Local cRet as Character
    Local cQry as Character
    Local cTmp as Character    
    Local oQuery as Object 
	Local aArea as Array

	Default cFilFk5	:= ""
	Default cData	:= ""
	Default cProtra	:= ""
	Default cTpRet	:= ""
	
    cRet := ""
    cQry := "" 
	aArea := GetArea()   
    
    cQry := " SELECT "
    cQry += "   FK5_IDMOV "
    cQry += " FROM "
    cQry += "   "+ RetSqlName("FK5") +" FK5 "
    cQry += " WHERE "
    cQry += "   FK5.FK5_FILIAL = ? "
	cQry += "   AND FK5.FK5_DATA = ? "
	cQry += "   AND FK5.FK5_PROTRA = ? "
    cQry += "   AND FK5.FK5_RECPAG = ? "
    cQry += "   AND FK5.FK5_TPDOC = ? "
    cQry += "   AND FK5.D_E_L_E_T_ = ? "

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)
  
    oQuery:SetString(1,cFilFk5)
    oQuery:SetString(2,cData)
    oQuery:SetString(3,cProtra)

	If cTpRet == "P"
		oQuery:SetString(4,"R")
		cRet := "|" + STR0013 //"Destino: "
	ElseIf cTpRet == "R"
		oQuery:SetString(4,"P")
		cRet := "|" + STR0012 //"Origem: "
	EndIf

	oQuery:SetString(5,"TR")
	oQuery:SetString(6,' ')

    //Abertura da Area da consulta
    cTmp := oQuery:OpenAlias()

    If !(cTmp)->(Eof())
        cRet += (cTmp)->FK5_IDMOV
    EndIf

    (cTmp)->(DbCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)

Return cRet

/*/
    Função para posicionar na SE5 a partir de um ID de movimento
	
	@author victor.azevedo@totvs.com.br
	@since 08/2025
	@version 1.0
    @param cIdOrigSE5, Character, string contendo o E5_IDORIG para busca.
    @return Numeric, Recno da SE5 encontrado
	@type StaticFunction
/*/
Static Function FindSE5(cIdOrigSE5 as Character)
	
	Local cQuery	 as Character
	Local nRecnoSE5  as Numeric
	Local nParam	 as Numeric
	
	Default cIdOrigSE5 := ""

	cQuery	  := ""
	nRecnoSE5 := 0
	nParam 	  := 1 

    If !Empty(cIdOrigSE5)		
		If __oObjSE5 == Nil
			cQuery := " "
			cQuery += " SELECT SE5.R_E_C_N_O_ RECNO"
			cQuery += " FROM " + RetSQLName("SE5") + " SE5 "
			cQuery += " WHERE E5_FILIAL = ? " //1
			cQuery += " AND E5_IDORIG = ? "   //2
			cQuery += " AND D_E_L_E_T_ = ? "  //3
			cQuery := ChangeQuery(cQuery)
			__oObjSE5	:= FwExecStatement():New(cQuery)
		EndIf

		__oObjSE5:SetString(nParam++, FWxFilial("SE5", cFilAnt))
		__oObjSE5:SetString(nParam++, cIdOrigSE5)
		__oObjSE5:SetString(nParam++, Space(1)) // D_E_L_E_T_
		nRecnoSE5 := __oObjSE5:ExecScalar("RECNO")

		If !Empty(nRecnoSE5)
			SE5->(DbGoTo(nRecnoSE5))
		EndIf
	EndIf

Return nRecnoSE5
