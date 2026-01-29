#INCLUDE "Protheus.CH"
#include "TOTVS.ch"
#include "TBICONN.ch"
#include "FINITITG.ch"

#DEFINE ValidSM0		1
#DEFINE MessageError	2
#DEFINE CompanyId		3
#DEFINE BranchId		4
#DEFINE OperationType	5
#DEFINE OperationAction	6
#DEFINE CodeGesplan		7
#DEFINE IDGesplan		8
#DEFINE MessageContent	9

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe de Integração com Gesplan via smartlink

@author TOTVS
@since 07/2023
@type class
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Class TITreadXGspMessageReader from LongNameClass

	Data lSuccess		As Logical 
	Data aDados	 		As Array	
	Data aDataResponse 	As Array	
	Data cEmpMsg		As Character
	Data cFilMsg		As Character	
	Data cTenantId		As Character		
	Data nQtdSuccess	As Numeric
	Data nQtdError		As Numeric	

    Method New() Constructor
    Method Read()
	Method FormatData()
	Method FTitGLog()
	Method SendResponse()

End Class

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author TOTVS
@since 07/2023
@type method
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method New() Class TITreadXGspMessageReader

	::lSuccess		:= .T.
	::aDados		:= {}	
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
Geração de Títulos a Pagar / Receber

@author Fabio Zanchim
@since 07/2023
@type method
@version 1.0
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
//-----------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class TITreadXGspMessageReader
	
	Local nZ 				As Numeric	
	Local nX				As Numeric	
	Local nI				As Numeric
	Local nQtdRegs			As Numeric
	Local cFunBkp			As Character
	Local oResp 			As Object
	Local oContent 			As Object
	Local aListTit			As Array
	Local aAreaAnt     		As Array
	Local aReturn			As Array

	nZ 		 := 0  	
	nI 		 := 0
	nQtdRegs := 0
	cFunBkp  := FunName()
	aAreaAnt := FwGetArea()
	oResp 	 := JsonObject():New()
	oContent := JsonObject():New()

    oContent:FromJSON(oLinkMessage:RawMessage())
    aListTit 		:= oContent['data']
    ::cTenantId 	:= oContent['tenantId']	

	//-- Organiza os dados por Empresa/Filial/Operação
	::FormatData( aListTit )
	
	::FTitGLog(1)
	For	nZ := 1 To Len(::aDados)
		If ::aDados[nZ,ValidSM0]//--Empresa/Filial válidos
			If ::cEmpMsg <> ::aDados[nZ,CompanyId] 
				
				::cEmpMsg := ::aDados[nZ,CompanyId]
				::cFilMsg := ::aDados[nZ,BranchId]	

				//------------------------------------------------------------------
				//-- Processa todos os títulos desse Grupo de Empresas 
				::FTitGLog(2)
				aReturn := StartJob("FTitGProc", GetEnvServer(), .T., ::cEmpMsg, ::cFilMsg, aClone(::aDados), __cUserID )
				::FTitGLog(3)

				For nX:=1 to Len(aReturn)//aReturn possui somente os movimentos do CompanyId
					Aadd(::aDataResponse,JsonObject():new())
					::aDataResponse[Len(::aDataResponse)]["CompanyId"]	:= aReturn[nX,CompanyId]
					::aDataResponse[Len(::aDataResponse)]["BranchId"]	:= aReturn[nX,BranchId]
					::aDataResponse[Len(::aDataResponse)]["SYSCODE"]	:= aReturn[nX,CodeGesplan]
					::aDataResponse[Len(::aDataResponse)]["ID"]			:= aReturn[nX,IDGesplan]			
					::aDataResponse[Len(::aDataResponse)]["error"]		:= FWhttpEncode(aReturn[nX,MessageError])
				Next nX
			EndIf
		Else
			Aadd(::aDataResponse,JsonObject():new())
			::aDataResponse[Len(::aDataResponse)]["CompanyId"]	:= ::aDados[nZ,CompanyId]
			::aDataResponse[Len(::aDataResponse)]["BranchId"]	:= ::aDados[nZ,BranchId]
			::aDataResponse[Len(::aDataResponse)]["SYSCODE"]	:= ::aDados[nZ,CodeGesplan]
			::aDataResponse[Len(::aDataResponse)]["ID"]			:= ::aDados[nZ,IDGesplan]			
			::aDataResponse[Len(::aDataResponse)]["error"]		:= FWhttpEncode(::aDados[nZ,MessageError])
		EndIF
	Next nZ

	If !Empty(::aDataResponse) 
		If (nQtdRegs := Len(::aDataResponse)) > 0		
			For nI := 1 to nQtdRegs
				If Empty(::aDataResponse[nI]["error"])
					::nQtdSuccess++
				Else
					::nQtdError++
				EndIf
			Next nI
			
			::FTitGLog(4)

			oResp:set(::aDataResponse)
			::SendResponse(oResp:toJSON(), ::cTenantId )
			::FTitGLog(5)
		EndIf
	EndIf

	::FTitGLog(6)

	SetFunName(cFunBkp)
	FwRestArea(aAreaAnt)

	FwFreeArray(aAreaAnt)
	FwFreeArray(aListTit)
	FwFreeArray(::aDados)	
	FwFreeArray(::aDataResponse)	
	FwFreeArray(aReturn)

	FwFreeObj(oResp)
	FwFreeObj(oContent)

Return .T. // .T. apaga a mensagem da fila do smartlink

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} setHashFields()
Lista a estrutura do dicionário 

@author Fabio Zanchim
@since 02/2024
@type function
@version 1.0
@param cCart, Character, carteira (pagar/receber) que será processada
/*/
//-----------------------------------------------------------------------------------------
Static Function SetHashFields( cCart ) 

	Local nX 		as Numeric
	Local nQtd		as Numeric
	Local cAls		as Character
	Local aFields	as Array

	If oHashFields <> Nil
		oHashFields:Clean()		
	EndIf
	oHashFields := tHashMap():New()

	If cCart == 'P'
		cAls:='SE2'
	Else
		cAls:='SE1'
	EndIf

	aFields := FWSx3Util():GetListFieldsStruct(cAls,.F.)
	nQtd	:= Len(aFields)	
	For nX:=1 To nQtd		
		oHashFields:Set( aFields[nX,1] , aClone({aFields[nX,2],aFields[nX,3]}) ) //Chave: x3_campo, Valor: {x3_tipo, X3_tamanho}
	Next nX

	FwFreeArray(aFields)

Return Nil


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FormatData()
Organiza os dados recebidos pelo smartlink

@author Fabio Zanchim
@since 07/2023
@type method
@version 1.0
@param aListTit, array, atributo Data recebido na mensagem 
/*/
//-----------------------------------------------------------------------------------------
Method FormatData( aListTit ) Class TITreadXGspMessageReader

	Local nZ 		as Numeric
	Local nPos 		as Numeric    	
	Local nField 	as Numeric
	Local nLenList	as Numeric
	Local nLenField	as Numeric	
	Local aSM0 		as Array
	Local aFields 	as Array
	Local aDataJson as Array
	Local cTable 	as Character

	nZ   	:= 0
	aSM0 	:= FWLoadSM0()    
	cTable 	:= 'SE2'	

	nLenList := len(aListTit)
	For	nZ := 1 To nLenList

		aDataJson	:= {}
		aFields 	:= aListTit[nZ]:GetNames()//Chaves de cada titulo (campos variáveis)
		nLenField	:= Len(aFields) 

		For nField:=1 To nLenField
			cField:=Alltrim(aFields[nField])	        
			If !(cField $ "SYSCODE|ID|CompanyId|BranchId|OperationType|OperationAction")
				aAdd(aDataJson, {cField, aListTit[nZ]:GetJsonText(aFields[nField])})
			EndIF
		Next

		If aListTit[nZ]:GetJsonText("OperationType") == 'R'
			cTable := 'SE1'
		EndIf

		aDataJson := FWVetByDic(aDataJson, cTable)

		Aadd(::aDados,{	.T.,;											// 1 ValidSM0
						'',;											// 2 MessageError
						aListTit[nZ]:GetJsonText("CompanyId"),; 	    // 3
						aListTit[nZ]:GetJsonText("BranchId"),;	        // 4
						aListTit[nZ]:GetJsonText("OperationType"),;	    // 5						
						aListTit[nZ]:GetJsonText("OperationAction"),;	// 6
						aListTit[nZ]:GetJsonText("SYSCODE"),;	        // 7
						aListTit[nZ]:GetJsonText("ID"),;	            // 8
						aClone(aDataJson)})								// 9	Campos Variáveis										

		If (nPos:=aScan(aSM0,  { |x| Alltrim(x[1])+x[2] == AllTrim(::aDados[Len(::aDados),CompanyId]) + PadR(::aDados[Len(::aDados),BranchId],x[8])  })) == 0
			::aDados[Len(::aDados), ValidSM0 ]   := .F.
			::aDados[Len(::aDados),MessageError] := STR0002 //"Empresa e/ou Filial inválidos."
		Else
			::aDados[Len(::aDados), BranchId ] := PadR(::aDados[Len(::aDados),BranchId],aSM0[nPos,8])// Ajusta tamanho da Filial
		EndIF
	Next nZ

	//-- Ordem 1 - empresa+filial para evitar chamadas excessivas de StartJob
	//-- Ordem 2 - exclusão -> inclusão (pois pode vir o mesmo título) -> Carteira P/R (para nao ficar listando dicionario no sethashFields)
	If Len(::aDados) > 0
		aSort(::aDados,,,{|x,y| x[CompanyId]+x[BranchId]+x[OperationAction]+x[OperationType] < y[CompanyId]+y[BranchId]+y[OperationAction]+y[OperationType] })		
	EndIF

	FwFreeArray(aFields)
	FwFreeArray(aDataJson)
	FwFreeArray(aSM0)

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckData()
Verifica informações básicas obrigatórias

@author Fabio Zanchim
@since 02/2024
@type function
@version 1.0
@param aData, array, título que esta sendo processado
@return character, indica problema com algum campo obrigatório
/*/
//-----------------------------------------------------------------------------------------
Static Function CheckData( aData ) 

	Local cMessage As Character 

	cMessage := ''		
	If Empty(aData[MessageContent]) .Or.;
		"null"  $	aData[CodeGesplan]+;
					aData[IDGesplan]+;
					aData[OperationType]+;
					aData[OperationAction]

		cMessage += STR0003 //"Campos obrigatórios não informados ou vazio."
	EndIF		

Return( cMessage )


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessData()
Inclusão do título

@author Fabio Zanchim
@since 07/2023
@type function
@version 1.0
@param aData, Array, título que será processado
@return character, indica problemas na inclusão/exclusão do título
/*/
//-----------------------------------------------------------------------------------------
Static Function ProcessData( aData ) 

	Local nX 		 As Numeric
	Local nOpc040 	 As Numeric
	Local nOpcInc050 As Numeric
	Local nOpcExc050 As Numeric
	Local nTam 		 As Numeric
    Local aCab	     As Array
	Local aLog	     As Array
	Local nSizeNum	 As Numeric
	Local cType  	 As Character
	Local cMsgAux	 As Character
	Local aProperty  As Array 
	Local aTitulo	 As Array
	Local cMessageFail 	as Character
	Local lFieldFail 	as Logical	

	aCab 	 	:= {}
	aLog 	 	:= {}	
	aProperty	:= {}	
	lFieldFail	:= .F.
	cMessageFail:= ''	
	aTitulo  	:= aClone(aData[MessageContent])

	If aData[OperationType]=='P'
		nSizeNum := TamSX3("E2_NUM")[1]
	Else
		nSizeNum := TamSX3("E1_NUM")[1]
	EndIF

	//-- Conversão de valores conforme dicionário e montagem do array do execauto
	For nX:=1 to Len(aTitulo)
		
		cField := aTitulo[nX,1]		
		If oHashFields:Get( cField , @aProperty)
			
			cType := aProperty[1] //x3_tipo
			nTam  := aProperty[2] //x3_tamanho
			If cType=='D'
				xContent:=CtoD(aTitulo[nX,2])
			ElseIf cType=='N'
				xContent:=Val(aTitulo[nX,2])
			Else
				xContent:=aTitulo[nX,2]
			EndIF

			iF cType=='D' .And. Empty(xContent)//Falha na conversão 
				lFieldFail	:= .T.					
				cMessageFail	:= I18N( STR0004, { cField, cType, Str(nTam,3) } )//"Valor inválido para tipo do campo cField - Valor esperado: cType - Tamanho: nTam"
				Exit
			ElseIf cType=='N' .And. (!IsNumeric(StrTran(aTitulo[nX,2],'.','')) .Or. Len( cValToChar(aTitulo[nX,2]) ) > nTam)
				lFieldFail	:= .T.					
				cMessageFail	:= I18N( STR0004, { cField, cType, Str(nTam,3) } )//"Valor inválido para tipo do campo cField - Valor esperado: cType - Tamanho: nTam"
				Exit
			Else
				//Regra para E1/E2_NUM
				IF cField $ ('E1_NUM|E2_NUM')
					xContent := Repl('0', nSizeNum-Len(xContent)) + xContent
				EndIF
				If Len(RTrim(cValToChar(xContent))) > nTam
					lFieldFail	:= .T.					
					cMessageFail	:= I18N( STR0004, { cField, cType, Str(nTam,3) } )//"Valor inválido para tipo do campo cField - Valor esperado: cType - Tamanho: nTam"
					Exit									
				EndIF
				//Padroniza conforme tamanho do dicionário
				If cType == 'C'
					xContent := Padr(xContent, nTam)
				EndIf
			EndIF

			If !lFieldFail
				aAdd(aCab, {cField, xContent, Nil})//Array do ExecAuto
			EndIF
		Else		
			lFieldFail	:= .T.	
			cMessageFail:= I18N( STR0001, { cField } )//"Campo nao existe no dicionário"
			Exit
		EndIF
	Next nX

	If !lFieldFail

		//-- P.E para adicionar conteúdo especifico
		If lFiTitGSP
			aCab := ExecBlock("FiTitGSP",.F.,.F.,{ aData[OperationType], aData[OperationAction], aCab })
		EndIF

		//-- Processa gravação do título
		If ValType(aCab) = "A" .And. Len(aCab) > 0

			//-- Ação a ser executada - Inclusão/Exclusão
			If aData[OperationAction]=='I'
				nOpc040	   := 3
				nOpcInc050 := 3 
				nOpcExc050 := Nil
			Else
				nOpc040	   := 5
				nOpcInc050 := Nil
				nOpcExc050 := 5 
			EndIf

			//-- Operação a ser executada - Pagar/Receber		
			lMsErroAuto := .F.	
			If aData[OperationType]=='P'     					
				MSExecAuto({|x,y,z| FINA050(x,y,z)},aCab, nOpcInc050, nOpcExc050)
			Else				
				MSExecAuto({|x,y| FINA040(x,y)}, aCab, nOpc040)
			EndIF

			If lMsErroAuto
				//-- Complemento de log em caso de falha do execauto
				cMsgAux := ('[Log inicio]' + CRLF)//Conteúdo fixo para replace na automação com UTVldSmtLink
				cMsgAux += ('[OperationType: '  + aData[OperationType] 	 + ']' + CRLF)
				cMsgAux += ('[OperationAction: '+ aData[OperationAction] + ']' + CRLF)
				cMsgAux += ('[Empresa/Filial: ' + cEmpAnt + '/' + cFilAnt+ ']' + CRLF)

				cMessageFail := cMsgAux
				aLog := GetAutoGRLog()				
				For nX := 1 To Len(aLog)
					cMessageFail += Alltrim(aLog[nX]) + CRLF
				Next nX		
				cMessageFail += '[Log fim]'//Conteúdo fixo para replace na automação com UTVldSmtLink
			EndIf
		Else	
			cMessageFail := 'Empty data for msExecAuto.'
		EndIF
	EndIF

    FwFreeArray(aCab)
    FwFreeArray(aLog)	
	FwFreeArray(aTitulo)

Return( cMessageFail )


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ReturnData()
Resposta da mensagem

@author Fabio Zanchim
@since 07/2023
@type method
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method SendResponse(oResp, cTenantId) Class TITreadXGspMessageReader

	Local oClient	 As Object    
	Local cMessage	 As Character
	local cTimestamp As Character 

	cMessage	:= ""
	oClient		:= FwTotvsLinkClient():New()
	cTimestamp	:= FWTimeStamp(5, Date(), Time())	

	BeginContent Var cMessage
	{
		"specversion": "1.0",
		"time": "%Exp:cTimestamp%" ,
		"type": "TITrespXGsp",
		"tenantId": "%Exp:cTenantId%" ,
		"data": %Exp:oResp%
	}
	EndContent

    ::lSuccess := oClient:SendAudience("TITrespXGsp","LinkProxy", cMessage)
	FreeObj(oClient)

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FTitGLog()
Log 

@author Fabio Zanchim
@since 04/2024
@type method
@version 1.0
@param nId, Numeric, identificador da mensagem a ser impressa
/*/
//-----------------------------------------------------------------------------------------
Method FTitGLog( nId ) Class TITreadXGspMessageReader

	Local cMsgRet As Character
	Local cMsgSty As Character

	Do Case
	Case nId == 1		
		FWLogMsg('INFO',, 'FINITITG',,,, 'FTitGLog - '+I18N( STR0005, {::cTenantId,Str(Len(::aDados),3)} ) )//"Iniciando processamento para tenant #1 - Quantidade de registros: #2"
	Case nId == 2
		FWLogMsg('INFO',, 'FINITITG',,,, 'FTitGLog - '+I18N( STR0006, {::cEmpMsg, ::cFilMsg} ) )//"Início da tarefa para Empresa/Filial: #1/#2"
	Case nId == 3
		FWLogMsg('INFO',, 'FINITITG',,,, 'FTitGLog - '+I18N( STR0007, {::cEmpMsg, ::cFilMsg} ) )//"Fim da tarefa para Empresa/Filial: #1/#2"
	Case nId == 4
		FWLogMsg('INFO',, 'FINITITG',,,, 'FTitGLog - '+I18N( STR0011, {Str(::nQtdSuccess,3), Str(::nQtdError,3)} ) )//"Finalizados com sucesso: #1 - Finalizados com falha: #2
	Case nId == 5
		cMsgRet := STR0009 //"Falha no envio da resposta para fila MOVrespXGsp."
		cMsgSty := 'WARN' 
		If ::lSuccess
			cMsgRet := STR0008 //"Sucesso no envio da resposta para fila MOVrespXGsp."
			cMsgSty := 'INFO'
		EndIf
		FWLogMsg(cMsgSty,, 'FINI100G',,,, 'F100GLog - '+cMsgRet )
	Case nId == 6
		FWLogMsg('INFO',, 'FINITITG',,,, 'FTitGLog - '+I18N( STR0010, { ::cTenantId } ) )//"Fim do processamento para tenant #1"
	EndCase

Return Nil


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FTitGProc()
Thread para inclusão/exclusão dos títulos

@author Fabio Zanchim
@since 04/2024
@type function
@version 1.0

@param cCompany, character, código do grupo de empresa 
@param cBranch, character, código da filial 
@param aData, array, dados recebidos via smartlink
@param cCodUser, character, código do usuário que startou a thread principal
/*/
//-----------------------------------------------------------------------------------------
Function FTitGProc(cCompany as Character, cBranch as Character, aData as Array, cCodUser as Character )

	Local nPos 				as Numeric
	Local aProcessed 		as Array
	Local cMessage			as Character
	Local cBranchAtu		as Character
	Local cCarteira			as Character
	
	Private oHashFields 	as Object
	Private lMsErroAuto     as Logical
	Private lMsHelpAuto		as Logical
	Private lAutoErrNoFile	as Logical	
	Private lFiTitGSP		as Logical

	Default cCompany := ""
	Default cBranch  := ""
	Default aData    := {}
	Default cCodUser := ""

	lMsErroAuto		:= .F.
	lMsHelpAuto		:= .T.
	lAutoErrNoFile	:= .T.	
	lFiTitGSP		:= ExistBlock("FiTitGSP")
	
	cMessage 	:= ''
	cBranchAtu	:= ''
	cCarteira	:= ''
	aProcessed 	:= {}

	RPCSetType(3) 
	RPCSetEnv(cCompany, cBranch,,, 'FIN', 'FINITITG') 
	cBranchAtu  := cBranch

	//-- Atualiza usuário da thread inicial para respeitar parametrização do ambiente 
	If GetRpoRelease() < "12.1.2510"
		__cUserID := cCodUser
	EndIf

	For	nPos := 1 To Len(aData) 
		
		cMessage := ''		
		If cCompany == aData[nPos,CompanyId] .And. aData[nPos,ValidSM0] 

			// Verifica informações básicas obrigatórias
			cMessage := CheckData( aData[nPos] ) 
			If Empty(cMessage)

				//-- Mudou carteira (pagar/receber)
				If cCarteira <> aData[nPos, OperationType]
					cCarteira := aData[nPos, OperationType]
					//-- Lista a estrutura do dicionário SE1 ou SE2 
					SetHashFields( cCarteira )
				EndIF			

				cBranch := aData[nPos,BranchId]
				If cBranchAtu <> cBranch
					cBranchAtu := cBranch
					cFilAnt	   := cBranch
				EndIF

				//-- Processa o título
				cMessage := ProcessData( aData[nPos] )
			EndIF
			
			//-- Atualiza ocorrências do execauto
			aData[nPos, MessageError ] := cMessage
			aAdd(aProcessed, aClone(aData[nPos]))
		EndIF
	Next nPos

	RpcClearEnv()

	FwFreeArray(aData)

Return( aProcessed )
