#include 'PROTHEUS.CH'
#include 'FINI473.CH'

#DEFINE ValidSM0		1
#DEFINE MessageError	2
#DEFINE CompanyId		3
#DEFINE BranchId		4
#DEFINE Carteira		5
#DEFINE DataConcil		6
#DEFINE EventType		7
#DEFINE IDMOV			8
#DEFINE CodeGesplan		9
#DEFINE IDGesplan		10

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe de Integração com Gesplan via smartlink, para alterar os status de conciliação bancaria 
para as tabelas FK5 e SE5
@type Class
@author Luiz Gustavo R. Jesus
@since 18/06/2025
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Class CONXreadXGspMessageReader from LongNameClass

	Data lSuccess		As Logical
	Data aDataConc  	As Array
	Data aDataResponse 	As Array	
	Data cEmpMsg		As Character
	Data cFilMsg		As Character	
	Data cTenantId		As Character	
	Data nQtdSuccess	As Numeric
	Data nQtdError		As Numeric
		
    Method New() Constructor
    Method Read()
	Method FormatData()
	Method FIN473Log()
	Method SendResponse()
 
End Class

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe
@type Method
@author Luiz Gustavo R. Jesus
@since 18/06/2025
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method New() Class CONXreadXGspMessageReader
 
	::lSuccess		:= .T.
	::aDataConc 	:= {}
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
@type Method
@author Luiz Gustavo R. Jesus
@since 18/06/2025
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
//-----------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class CONXreadXGspMessageReader
	
	Local nX				As Numeric
	Local nY				As Numeric
	Local cFunBkp			As Character
	Local aAreaAnt			As Array
	Local oResp 			As Object
	Local oContent 			As Object
	Local aListContent		As Array
	Local aReturn			As Array
	Local nLenDtCon         As Numeric
	Local nLenRet			As Numeric
	Local aAux				As Array
	Local cEmpAtu

	cFunBkp  := FunName()
	aAreaAnt := FwGetArea()
	aAux	 := {}
	aReturn  := {}
	cEmpAtu  := ""

	oResp 	 := JsonObject():new()
	oContent := JsonObject():new()

    oContent:FromJSON(oLinkMessage:RawMessage())
	aListContent	:= oContent['data']
	::cTenantId 	:= oContent['tenantId']    

	//-------------------------------------------------------
	//-- Organiza os dados recebidos por empresa/filial
	::FormatData(aListContent)
	
	nLenDtCon := Len(::aDataConc) 

	::FIN473Log(2)

	For nX:= 1 to nLenDtCon
		//Efetua a execução por empresa
		If cEmpAtu <> ::aDataConc[nX,CompanyId]
			cEmpAtu := ::aDataConc[nX,CompanyId]
			For nY:=1 to nLenDtCon
				If cEmpAtu == ::aDataConc[nY,CompanyId]
					Aadd(aAux,::aDataConc[nY])
				EndIf 
			Next nY
			Aadd(aReturn, StartJob("FIN473Conc", GetEnvServer(), .T., aClone(aAux)))
			aAux := {}
		EndIf
	Next nX

	If nLenDtCon > 0		
		nLenRet := Len(aReturn)

		For nX:=1 to nLenRet
			nLenDtCon := Len(aReturn[nX])
			For nY:=1 to nLenDtCon
				::cEmpMsg := aReturn[nX,nY,CompanyId]
				::cFilMsg := aReturn[nX,nY,BranchId]			
				
				Aadd(::aDataResponse,JsonObject():new())					
				::aDataResponse[Len(::aDataResponse)]["CompanyId"]	:= aReturn[nX,nY,CompanyId]
				::aDataResponse[Len(::aDataResponse)]["BranchId"]	:= aReturn[nX,nY,BranchId]	
				::aDataResponse[Len(::aDataResponse)]["IDMOV"]		:= aReturn[nX,nY,IDMOV]
				::aDataResponse[Len(::aDataResponse)]["error"]		:= FWhttpEncode(aReturn[nX,nY,MessageError])
				::aDataResponse[Len(::aDataResponse)]["SYSCODE"]	:= aReturn[nX,nY,CodeGesplan]
				::aDataResponse[Len(::aDataResponse)]["ID"]			:= aReturn[nX,nY,IDGesplan]
			Next nY
		Next nX
	
	EndIf	

	//-------------------------------------------------------
	//-- Envia mensagem de resposta para a fila CONXrespXGsp
	If Len(::aDataResponse) > 0				
		aEval( ::aDataResponse, {|x| Iif( Empty(x:GetJsonText("error")), ::nQtdSuccess++, ::nQtdError++ ) })
		::FIN473Log(6) // "Finalizados com sucesso: #1 - Finalizados com falha: #2"

		oResp:set(::aDataResponse)
		::SendResponse(oResp:toJSON(), ::cTenantId )				
		::FIN473Log(7)
	EndIF
	::FIN473Log(9) //"Fim do processamento para tenant #1"

	SetFunName(cFunBkp)	
	FwRestArea(aAreaAnt)

	FwFreeArray(aAreaAnt)
	FwFreeArray(::aDataConc)	
	FwFreeArray(::aDataResponse)
	FwFreeArray(aListContent)
	FwFreeArray(aReturn)
	FwFreeArray(aAux)
	FwFreeObj(oResp)
	FwFreeObj(oContent)

Return .T. // .T. apaga a mensagem da fila do smartlink

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FormatData()
Organiza os dados recebidos pelo smartlink
@type method
@author Luiz Gustavo R. Jesus
@since 18/06/2025
@version 1.0
@param aListContent, object, atributo Data recebido na mensagem 
/*/
//-----------------------------------------------------------------------------------------
Method FormatData( aListContent ) Class CONXreadXGspMessageReader

	Local nZ 	 		As Numeric
	Local nPos 	 		As Numeric	
	Local nLenList		As Numeric	
	Local nLenBranch  	As Numeric 	
	Local aSM0 			As Array
	
	aSM0 := FWLoadSM0()    	

	nLenList := Len(aListContent)
	For	nZ := 1 To nLenList	
		Aadd(::aDataConc,{.T.,;										// 1 ValidSM0
						'',;										// 2 MessageError						
						aListContent[nZ]:GetJsonText("CompanyId"),; // 3 Empresa
						aListContent[nZ]:GetJsonText("BranchId"),;	// 4 Filial
						aListContent[nZ]:GetJsonText("Carteira"),;	// 5 Carteira
                        aListContent[nZ]:GetJsonText("DataConc"),;	// 6 Data
                        aListContent[nZ]:GetJsonText("EventType"),;	// 7 Estono ou conciliado "X"
						aListContent[nZ]:GetJsonText("IDMOV"),;	    // 8 Valores da chave FK5_IDMOV
						aListContent[nZ]:GetJsonText("SYSCODE"),;	// 9 CodeGesplan
						aListContent[nZ]:GetJsonText("ID")})		// 10 IDGesplan
						
		
		nLenBranch := Len(::aDataConc)
		If (nPos:=aScan(aSM0,  { |x| Alltrim(x[1])+AllTrim(x[2]) == AllTrim(::aDataConc[nLenBranch,CompanyId]) + AllTrim(::aDataConc[nLenBranch,BranchId])  })) == 0
			::aDataConc[nLenBranch,ValidSM0]		:= .F.
			::aDataConc[nLenBranch,MessageError]	:= STR0001 //"Empresa e/ou Filial inválidos."
		Else
			::aDataConc[nLenBranch,BranchId] := PadR(::aDataConc[nLenBranch,BranchId],aSM0[nPos,8])// Ajusta tamanho da Filial
		EndIF
	Next nZ

	//-- Ordena por empresa+filial para evitar chamadas excessivas de RpcSetEnv
	If Len(::aDataConc) > 0
		aSort(::aDataConc,,,{|x,y| x[CompanyId]+x[BranchId] < y[CompanyId]+y[BranchId] })
	EndIF
	
	FwFreeArray(aSM0)
Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} SendResponse()
Resposta da mensagem
@type Method
@author Luiz Gustavo R. Jesus
@since 18/06/2025
@version 1.0
@param oResp, object, mensagens de retorno do todos movimentos bancários 
@param cTenantId, Character, identificação do tenant
/*/
//-----------------------------------------------------------------------------------------
Method SendResponse( oResp, cTenantId ) Class CONXreadXGspMessageReader

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
		"type": "CONXrespXGsp",
		"tenantId": "%Exp:cTenantId%" ,
		"data": %Exp:oResp%
	}
	EndContent

    ::lSuccess := oClient:SendAudience("CONXrespXGsp","LinkProxy", cMessage)
	FreeObj(oClient)

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintLog()
Log 
@type Method
@author Luiz Gustavo R. Jesus
@since 27/06/2025
@version 1.0
@param nId, Numeric, identificador da mensagem a ser impressa
/*/
//-----------------------------------------------------------------------------------------
Method FIN473Log( nId ) Class CONXreadXGspMessageReader

	Local cMsgRet As Character
	Local cMsgSty As Character

	Do Case	
	
	Case nId == 2	
		FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0002, {::cTenantId,Str(Len(::aDataConc),3)} ) ) )//"Iniciando processamento para tenant #1 - Quantidade de registros: #2"	
	
	Case nId == 6
		FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0006, {Str(::nQtdSuccess,3), Str(::nQtdError,3)} ) ) )//"Finalizados com sucesso: #1 - Finalizados com falha: #2
	
	Case nId == 7
		cMsgRet := STR0008 //"Falha no envio da resposta para fila CONXrespXGsp."
		cMsgSty := 'WARN' 
		If ::lSuccess
			cMsgRet := STR0007 //"Sucesso no envio da resposta para fila CONXrespXGsp."
			cMsgSty := 'INFO'
		EndIf
		FWLogMsg(cMsgSty,, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( cMsgRet ) )
	
	Case nId == 9
		FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0009, { ::cTenantId } ) ) )//"Fim do processamento para tenant #1"		
	
	EndCase    

Return Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN473Conc
Função responsavel pelo processamento dos registros de conciliação das tabelas FK5 e SE5
@type  Function
@author Luiz Gustavo R. Jesus
@since 02/07/2025    
@param aData, Array, Registros enviados pela mensagem do Smartlink
@return Array, Registros processados para serem enviados   
/*/
//-----------------------------------------------------------------------------------------	
Function FIN473Conc( aData as Array )

	Local lEstorno 		As Logical
	Local nTotal 		As Numeric
	Local nX 			As Numeric
	Local cFk5_idmov 	As Character
	Local cCarteira 	As Character
	Local cFilAnte	 	As Character
	Local cEmpAnte	 	As Character
	Local cMessage		As Character
	Local cTipoDoc		As Character

	Default aData := {}

	lEstorno := .F.
	nTotal	 := Len(aData)
	cFilAnte := ""
	cMessage := ""
	cTipoDoc := ""
	
	If nTotal > 0		
		
		For nX := 1 to nTotal

			cMessage := ""
			
			//Verifica se a empresa é valida
			If aData[nX,ValidSM0]

				// Verifica informações básicas obrigatórias
				cMessage := CheckData( aData[nX] )
				If Empty(cMessage)

					//Define as variaveis
					cFk5_idmov := aData[nX,IDMOV]
					cCarteira  := aData[nX,Carteira]				

					//Prepara o ambiente pela empresa
					If cEmpAnte <> aData[nX,CompanyId]
						cEmpAnte := aData[nX,CompanyId]
						cFilAnte := aData[nX,BranchId]	
						RPCSetType(3) 
						RPCSetEnv(cEmpAnte, cFilAnte,,, 'FIN', 'FINI473')					
					EndIf
					
					cFilAnt 	:= aData[nX,BranchId]
					dDataBase   := CToD(aData[nX,DataConcil])
					
					FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0003, {cEmpAnt, cFilAnt} ) ) )//"Início da tarefa para Empresa/Filial: #1/#2"					
					FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( STR0005 ) ) // "Processamento da Conciliacao Bancaria"

					//Valida se é o estorno.
					If ( Upper(aData[nX,EventType]) == "X" )
						lEstorno := .F.
					Else
						lEstorno := .T.
					EndIf

					//Valida a existencia da movimentação na tabela FK5
					If ( CheckFk5(cFk5_idmov) )						
						//Executa os processos de Conciliação para FK5 e SE5
						ConcilFK5(cFk5_idmov,@cTipoDoc,lEstorno)
						ConcilSE5(cFk5_idmov,cTipoDoc,cCarteira,lEstorno)
					Else				
						cMessage := FwNoAccent( I18N( STR0010, {cFk5_idmov,cEmpAnt, cFilAnt} ) ) //"IDMOV: #1 não encontrado para Empresa/Filial: #2/#3"					
						FWLogMsg('WARN',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0010, {cFk5_idmov,cEmpAnt, cFilAnt} ) ) )//"IDMOV: #1 não encontrado para Empresa/Filial: #2/#3"
					EndIf

				EndIf

				aData[nX,MessageError] := cMessage
								
				FWLogMsg('INFO',, 'FINI473',,,, 'FINI473Log - '+ FwNoAccent( I18N( STR0004, {cEmpAnt, cFilAnt} ) ) )//"Fim da tarefa para Empresa/Filial: #1/#2"	
			
			EndIf

		Next nX

	EndIf

Return aData

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFk5
Função para validar a existencia do movimento na tabela FK5
@type  StaticFunction
@author Luiz Gustavo R. Jesus
@since 17/06/2025    
@param cFk5_idmov, Character, Valor do campo FK5_IDMOV para validação da existencia do movimento
@return Logical, Caso encontre o registro FK5_IDMOV na base retorna verdadeiro.    
/*/
//-----------------------------------------------------------------------------------------
Static Function CheckFk5(cFk5_idmov as Character)

    Local lRet as Logical
    Local cQry as Character
    Local cTmp as Character    
    Local oQuery as Object 
	Local aArea as Array

	Default cFk5_idmov := ""

    lRet := .F.
    cQry := "" 
	aArea := GetArea()   
    
    cQry := " SELECT "
    cQry += "   FK5_IDMOV "
    cQry += " FROM "
    cQry += "   "+ RetSqlName("FK5") +" FK5 "
    cQry += " WHERE "
    cQry += "   FK5.FK5_FILIAL = ? "
    cQry += "   AND FK5.FK5_IDMOV = ? "
    cQry += "   AND FK5.D_E_L_E_T_ = ? "

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)
    //Substituição dos parametros da Qry    
    oQuery:SetString(1,xFilial("FK5"))
    oQuery:SetString(2,cFk5_idmov)
    oQuery:SetString(3,' ')
    //Abertura da Area da consulta
    cTmp := oQuery:OpenAlias()

    If !(cTmp)->(Eof())
        lRet := .T.
    EndIf

    (cTmp)->(DbCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeObj(oQuery)

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ConcilFK5
Função utilizada para efetuar o update do campo FK5_DTCONC para os registros identificados pelo campo FK5_IDMOV
@type  StaticFunction
@author Luiz Gustavo R. Jesus
@since 17/06/2025    
@param cFk5_idmov, Character, Valor do campo FK5_IDMOV utilizado como parametro da alteração do registro
@param cTipoDoc,   Character, Valor do campo FK5_TPDOC utilizado como parametro da alteração do registro
@param lEstorno,   Logical, Define se deve realizar o estorno do movimento.
@return Logical, Caso tenha sucesso na alteração do registro para o campo FK5_DTCONC na base retorna verdadeiro.    
/*/
//-----------------------------------------------------------------------------------------
Static Function ConcilFK5(cFk5_idmov as Character, cTipoDoc as Character, lEstorno as Logical)

    Local lRet  as Logical
	Local aArea as Array
    
	Default cFk5_idmov	:= ""
	Default cTipoDoc	:= ""
	Default lEstorno	:= .F.

	lRet := .F.
	aArea := GetArea()

    dbSelectArea('FK5')
    FK5->(DbSetOrder(1))
    If FK5->(dbSeek(xFilial('FK5')+cFk5_idmov))
		cTipoDoc := FK5->FK5_TPDOC
        RecLock("FK5", .F.)
        If lEstorno
            FK5->FK5_DTCONC := CToD("")
        Else
            FK5->FK5_DTCONC := dDataBase
        EndIf
        lRet := .T.
        FK5->(MsUnLock())
    End
    FK5->(DBCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ConcilSE5
Função utilizada para efetuar o update do campo E5_RECONC para os registros identificados pelo campo FK5_IDMOV
@type  StaticFunction
@author Luiz Gustavo R. Jesus
@since 17/06/2025    
@param cFk5_idmov, Character, Valor do campo FK5_IDMOV utilizado como parametro da alteração do registro
@param cTipoDoc,   Character, Valor do campo FK5_TPDOC utilizado como parametro da alteração do registro
@param cCarteira,  Character, Define o tipo de carteira se 'P' = Pagar ou 'R' = Receber
@param lEstorno,   Logical, Define se deve realizar o estorno do movimento.
@return Logical, Caso tenha sucesso na alteração do registro para o campo E5_RECONC na base retorna verdadeiro.
/*/
//-----------------------------------------------------------------------------------------
Static Function ConcilSE5(cFk5_idmov as Character, cTipoDoc as Character, cCarteira as Character, lEstorno as Logical )

    Local lRet      as Logical
    Local cQry      as Character
    Local cTmp      as Character
    Local cIdOrig   as Character
    Local cTabFk    as Character
    Local oQuery    as Object 
	Local aArea 	as Array
	Local lCheckSe5 as Logical

	Default cFk5_idmov	:= ""
	Default cTipoDoc	:= ""
	Default cCarteira	:= ""
	Default lEstorno	:= .F.

    lRet := .F.
	lCheckSe5 := .F.
    cQry := ""
    cIdOrig := ""
	aArea := GetArea()
    
	dbSelectArea('SE5')
    SE5->(DbSetOrder(21))//E5_FILIAL+E5_IDORIG+E5_TIPODOC
    If SE5->(dbSeek(xFilial('SE5')+cFk5_idmov+cTipoDoc))
		lCheckSe5 := .T.
	EndIf		

	If !lCheckSe5 .And. cFk5_idmov <> ""

		If cCarteira == 'P'
			cTabFk := 'FK2'
		else
			cTabFk := 'FK1'
		EndIf
		
		cQry := " SELECT "
		cQry += "   FKA_B.FKA_IDORIG "
		cQry += " FROM "
		cQry += "   "+ RetSqlName("FKA") +" FKA_A "
		cQry += "   INNER JOIN "+ RetSqlName("FKA") +" FKA_B ON FKA_A.FKA_FILIAL = FKA_B.FKA_FILIAL AND FKA_A.FKA_IDPROC = FKA_B.FKA_IDPROC AND FKA_B.D_E_L_E_T_ = ? "
		cQry += " WHERE "
		cQry += "   FKA_A.FKA_FILIAL = ? "
		cQry += "   AND FKA_A.FKA_IDORIG = ? "
		cQry += "   AND FKA_B.FKA_TABORI = ? "
		cQry += "   AND FKA_A.D_E_L_E_T_ = ? "

		cQry := ChangeQuery(cQry)
		oQuery := FwExecStatement():New(cQry)
		//Substituição dos parametros da Qry    
		oQuery:SetString(1,' ')
		oQuery:SetString(2,xFilial("FKA"))
		oQuery:SetString(3,cFk5_idmov)
		oQuery:SetString(4,cTabFk)
		oQuery:SetString(5,' ')
		//Abertura da Area da consulta
		cTmp := oQuery:OpenAlias()

		If !(cTmp)->(Eof())
			cIdOrig := (cTmp)->(FKA_IDORIG)
		EndIf
		
		If SE5->(dbSeek(xFilial('SE5')+cIdOrig))
			lCheckSe5 := .T.	
		EndIf
		
		(cTmp)->(DbCloseArea())		
	EndIf 

	If lCheckSe5
		RecLock("SE5", .F.)
		If lEstorno
			SE5->E5_RECONC := ""
		Else
			SE5->E5_RECONC := "x"
		EndIf            
		SE5->(MsUnlock())
		lRet := .T.
	EndIf
    
	SE5->(DBCloseArea())
    
	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeObj(oQuery)

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckData()
Verifica informações básicas obrigatórias
@type StaticFunction
@author Bruno Rosa
@since 08/2025
@version 1.0
@param nPos, Numeric, movimento que esta sendo processado
@return character, indica problema com algum campo obrigatório
/*/
//-----------------------------------------------------------------------------------------
Static Function CheckData( aData )

	Local cMessage As Character

	Default aData := {} 

	cMessage := ''		
	If Empty(aData[Carteira]) .Or. Empty(aData[DataConcil]) .Or. Empty(aData[IDMOV]) .Or.;
			"null" $ aData[CodeGesplan]+aData[IDGesplan]
				 
		cMessage += STR0011 //"Campos obrigatórios não informados ou vazio."		
	EndIF	

Return( cMessage )
