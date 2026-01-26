#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'OMSI010.CH'
#Include 'FWLIBVERSION.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMSI010O   ºAutor  ³Totvs Cascavel     º Data ³  14/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações das Tabelas de precos 		          º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OMSI010O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMSI010O( oEAIObEt, nTypeTrans, cTypeMessage, nPage, nPagesize )
	
	Local aArea			As Array	
	Local aAreaDA0		As Array	
	Local aAreaDA1		As Array
 	Local aHeader		As Array	
	Local aItens		As Array
	Local aJsonItens	As Array
	Local aMsgErro		As Array	
	Local aRet			As Array	
	Local aSaveLine		As Array	
	Local aRetItem      As Array	
	Local cCodTab		As Character
	Local cEvent		As Character
	Local cEvntItem		As Character	
	Local cDataAte		As Character
	Local cDataDe		As Character
	Local cDataVig		As Character
	Local cEntity		As Character	
	Local cFilDA0		As Character
	Local cFilDA1		As Character
	Local cJson			As Character
	Local cLogErro		As Character
	Local cMarca		As Character
	Local cMaxItem		As Character	
	Local cTabPrcItm	As Character
	Local lCargaIni		As Logical	
	Local lFound		As Logical	
	Local lNewItem		As Logical	
	Local lRet 			As Logical	
	Local lTippre		As Logical		
	Local lCrmInteg		As Logical
	Local nContReg		As Numeric
	Local nControl		As Numeric	
	Local nErrSize		As Numeric	
	Local nLen			As Numeric	
	Local nLength		As Numeric	
	Local nI			As Numeric	
 	Local nOpcx 		As Numeric
	Local nR 			As Numeric	
	Local nTamCodPro	As Numeric
	Local nTamCodTab	As Numeric
	Local nX			As Numeric	
	Local oFwEAIObj		As Object		
	Local nj			As Numeric	
	Local oHashJSON		As Object
	Local oModel 		As Object	
	Local oModelDA0		As Object	
	Local oModelDA1		As Object	
	Local oIteTbPri		As Object
	Local nStart		As Numeric
	Local nReg			As Numeric 
	Local nPages		As Numeric 
	Local aFieldStru	As Array
	Local cCpoTagDA0	As Character
	Local cCpoTagDA1	As Character
	Local cPrefCpo		As Character
	Local cEAIFLDS     	As Character
	Local lAddField		As Logical

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	
	Default oEAIObEt		:= Nil
	Default cTypeMessage 	:= ""
	Default nTypeTrans 		:= 0
	Default nPage			:= 1
	Default nPageSize		:= 100
	
	aArea		:= FWGetArea() 								//Salva contexto do alias atual
	aAreaDA0	:= DA0->(FWGetArea()) 						//Salva contexto do alias DA0
	aAreaDA1	:= DA1->(FWGetArea()) 						//Salva contexto do alias DA1
	aHeader		:= {}										//Dados da Master
	aItens		:= {}										//Dados da Detail
	aJsonItens	:= {}
	aMsgErro	:= {}										//Mensagem de erro na gravação do Model	
	aRet		:= {.T.,""}									//Array de retorno da execucao da versao
	aSaveLine	:= FWSaveRows() 							//Salva contexto do model ativo		
	aRetItem    := {.T.,""}  								//Array de retorno do ponto de entrada OMSIOAIT
	cCodTab		:= ""										//Codigo da tabela de preços
	cEvent		:= "upsert" 								//Operação realizada na master e na detail ( upsert ou delete )
	cEvntItem	:= "" 				
	cDataAte	:= "" 										//Data final da tabela de preços
	cDataDe		:= "" 										//Data inicial da tabela de preços	
	cDataVig	:= "" 										//Data de vigência do item na tabela de preços	
	cEntity		:= "PriceListHeaderItem"
	cFilDA0		:= FWxFilial('DA0') 						// Filial Header
	cFilDA1		:= FWxFilial('DA1')							// filial Itens
	cJson		:= ""
	cLogErro	:= ""										//Log de erro da execução da rotina
	cMarca		:= ""										//Indica a marca integrada	
	cMaxItem	:= StrZero( 0, FWTamSX3('DA1_ITEM')[1] )
	cTabPrcItm	:= "" 										//item da tabela de preço
	lCargaIni	:= .F. 										//Controla chamada de carga inicial
	lFound		:= .F. 										//Indica se encontrou o registro
	lNewItem	:= .T. 										//Indica se é a primeira linha de DA1 nova durante alteração
	lRet 		:= .T. 										//Indica o resultado da execução da função
	lTippre		:= DA1->(ColumnPos("DA1_TIPPRE") > 0) 
	lCrmInteg	:= .F.
	nContReg	:= 0 
	nControl	:= 0 										//Contador	
	nErrSize	:= 0 										//Len do array de erros
	nLen		:= 0 										//Quantidade de itens da Tabela de Preço
	nLength		:= 0 										//Grid de Itens
	nI			:= 0 										//Contador de uso geral
	nOpcx 		:= 3 										//Tipo de operação	
	nR 			:= 0 										//Contador erro
	nTamCodPro	:= DA1->(FWTamSX3("DA1_CODPRO")[1])
	nTamCodTab	:= DA0->(FWTamSX3("DA0_CODTAB")[1])
	nX			:= 0										//Contador de uso geral		
	oFwEAIObj	:= FwEAIObj():New()
	nj			:= 0										//Contador do laço itens de retorno do ponto de entrada OMSIOAIT
	oHashJSON	:= Nil  									//Hash com a carga dos itens usado durante a Alteração para determinar se o item é novo
	oModel 		:= Nil 										//Objeto com o model da tabela de preços
	oModelDA0	:= Nil 										//Objeto com o model da master apenas
	oModelDA1	:= Nil 										//Objeto com o model da detail apenas
	oIteTbPri	:= Nil 		
	nStart		:= 1
	nReg		:= 0
	nPages		:= 1
	aFieldStru	:= {}
	cCpoTagDA0	:= ""
	cCpoTagDA1	:= ""
	cPrefCpo	:= ""
	cEAIFLDS    := SuperGetMV( "MV_EAIFLDS ", , "0000" )
	lAddField	:= FindFunction("IntAddField")

	// Relação de campos que possuem tag para serem desconsiderados na seção AddFields
	If lAddField
		cCpoTagDA0 := "DA0_FILIAL|DA0_CODTAB|DA0_DESCRI|DA0_DATDE|DA0_DATATE|DA0_HORADE|DA0_HORATE|DA0_ATIVO|DA0_USERGI|DA0_USERGA"
		cCpoTagDA1 := "DA1_FILIAL|DA1_CODPRO|DA1_PRCVEN|DA1_VLRDES|DA1_PERDES|DA1_DATVIG|DA1_ATIVO|DA1_TIPPRE|DA1_USERGI|DA1_USERGA"

		If nTypeTrans == TRANS_SEND .And. MV_PAR01 == 2 // Mensagem de Envio e Demonstrar por: 2-PRODUTO
			cCpoTagDA1 += "|DA1_CODTAB|DA1_DESTAB"
		EndIf
	EndIf

	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If ( nTypeTrans == TRANS_RECEIVE ) .And. ValType( oEAIObEt ) == 'O' 
	
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		
			//Guarda o código da tabela recebido na mensagem.
			//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
			If oEAIObEt:getPropValue("Code") != nil 
				cCodTab := PadR( AllTRim(oEAIObEt:getPropValue("Code")), nTamCodTab)
			EndIf		
			
			//Posiciona tabela DA0
			DbSelectArea('DA0')
			DA0->( dbSetOrder(1) )	//Filial + Codigo da Tabela | DB0_FILIAL + DB0_CODTAB
			lFound := DA0->( MSSeek( cFilDA0 + cCodTab ) )
					
			//Verifica a operação realizada
			If ( Upper( AllTrim( oEAIObEt:getEvent() ) ) == 'UPSERT' ) .Or. ( Upper( AllTrim( oEAIObEt:getEvent() ) ) == 'REQUEST' ) 
				
				If ( lFound )
					nOpcx := 4
					
					//Em caso de alteração, grava os itens já gravados para uso posterior
					oModel 		:= FwLoadModel( 'OMSA010')
					oModelDA1 	:= oModel:GetModel('DA1DETAIL')
					oModel:Activate()
					nLength 	:= oModelDA1:Length()
					oModelDA1:SeekLine( {{'DA1_CODTAB', cCodTab}} )
					
					//Hash com a lista de itens da DA1 que já existem na base
					oHashJSON := THashMap():New() 
	
					For nI := 1 To nLength
						oModelDA1:GoLine(nI)
						oHashJSON:Set( Alltrim(oModelDA1:GetValue('DA1_CODPRO')) + DtoC(oModelDA1:GetValue('DA1_DATVIG') ), { oModelDA1:GetValue('DA1_ITEM') }  )
						If nI == nLength
							cMaxItem := oModelDA1:GetValue('DA1_ITEM')
						EndIf
						
					Next nI
				EndIf
				
			Else
				//Exclusão
				If ( !lFound )
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := EncodeUTF8(STR0001)	//'Registro não encontrado!'
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
				Else
					nOpcx := 5
				EndIf
			EndIf
			
			If lRet 
				//Monta array com dados da tabela Master
				aAdd( aHeader, {'DA0_CODTAB', cCodTab, Nil } )	
				If oEAIObEt:getPropValue("Name") != nil	.And. !Empty(oEAIObEt:getPropValue("Name"))
					aAdd( aHeader, {'DA0_DESCRI', oEAIObEt:getPropValue("Name"), Nil } )	
				Endif		
				
				If oEAIObEt:getPropValue("InitialDate") != nil .And. !Empty(oEAIObEt:getPropValue("InitialDate"))
					aAdd( aHeader, {'DA0_DATDE', CToD( oEAIObEt:getPropValue("InitialDate") ), Nil } )	
				Endif	
					
				If oEAIObEt:getPropValue("FinalDate") != nil .And. !Empty(oEAIObEt:getPropValue("FinalDate"))
					aAdd( aHeader, {'DA0_DATATE', CToD( oEAIObEt:getPropValue("FinalDate") ), Nil } )	
				Endif	
				
				If oEAIObEt:getPropValue("InitialHour") != nil .And. !Empty(oEAIObEt:getPropValue("InitialHour"))
					aAdd( aHeader, {'DA0_HORADE', SubStr( oEAIObEt:getPropValue("InitialHour"), 1, 5 ), Nil } )	
				Endif
				
				If oEAIObEt:getPropValue("FinalHour") != nil .And. !Empty(oEAIObEt:getPropValue("FinalHour"))
					aAdd( aHeader, {'DA0_HORATE', SubStr( oEAIObEt:getPropValue("FinalHour"), 1, 5 ), Nil } )
				Endif
				
				If oEAIObEt:getPropValue("ActiveTablePrice") != nil .And. !Empty(oEAIObEt:getPropValue("ActiveTablePrice"))
					aAdd( aHeader, {'DA0_ATIVO',  oEAIObEt:getPropValue("ActiveTablePrice"), Nil } )
				EndIf
				
				// Realiza a leitura da seção AddFields com os campos sem tag ou customizados para gravar na DA0
				If lAddField .And. oEAIObEt:getPropValue("AddFields") != nil .And. !Empty(oEAIObEt:getPropValue("AddFields"))
					cPrefCpo := "DA0"
					IntAddField(@oEAIObEt:getPropValue("AddFields"), nTypeTrans, @aHeader, cCpoTagDA0, cPrefCpo)
				EndIf

				If oEAIObEt:getPropValue("ItensTablePrice") != nil  .AND. oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item") <> NIL;
					.And. !Empty(oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item"))

					oIteTbPri := oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item")
					nLen := Len( oIteTbPri )
				Endif

				aItens 	:= {}
				
				//Monta array com dados da tabela detail
				For nI := 1 To nLen
					aAdd( aItens, {} )	
					
					aAdd( aItens[nI], { 'DA1_FILIAL', cFilDA1 , Nil } )
					
					If oIteTbPri[nI]:getPropValue("ItemCode") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("ItemCode"))
						aAdd( aItens[nI], { 'DA1_CODPRO', PadR(AllTRim(oIteTbPri[nI]:getPropValue("ItemCode")), nTamCodPro), Nil } )
					EndIf

					If oIteTbPri[nI]:getPropValue("MinimumSalesPrice") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("MinimumSalesPrice"))
						aAdd( aItens[nI], { 'DA1_PRCVEN', oIteTbPri[nI]:getPropValue("MinimumSalesPrice"), Nil  } )
					EndIf

					If oIteTbPri[nI]:getPropValue("DiscountValue") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("DiscountValue"))
						aAdd( aItens[nI], { 'DA1_VLRDES', oIteTbPri[nI]:getPropValue("DiscountValue"), Nil} )
					EndIf

					If oIteTbPri[nI]:getPropValue("DiscountFactor") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("DiscountFactor"))
						aAdd( aItens[nI], { 'DA1_PERDES', oIteTbPri[nI]:getPropValue("DiscountFactor"), Nil } )
					EndIf
					
					If oIteTbPri[nI]:getPropValue("ItemValidity") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("ItemValidity"))
						aAdd( aItens[nI], { 'DA1_DATVIG', CToD( oIteTbPri[nI]:getPropValue("ItemValidity") ), Nil } )
					EndIf

					If nOpcx == 4 .And. oHashJSON:Get( Alltrim(aItens[nI][2][2])  + DtoC(aItens[nI][6][2]), @aJsonItens )					
						aAdd( aItens[nI], { 'LINPOS','DA1_ITEM', aJsonItens[1] } )
					ElseIf nOpcx <> 5
						If lNewItem
							cTabPrcItm := Soma1( cMaxItem )
							lNewItem := .F.
						Else
							cTabPrcItm := Soma1(cTabPrcItm)
						EndIf
	
						aAdd( aItens[nI], { 'DA1_ITEM', cTabPrcItm, Nil } )
					EndIf
				
					If oIteTbPri[nI]:getPropValue("ActiveItemPrice") != nil .And. !Empty(oIteTbPri[nI]:getPropValue("ActiveItemPrice"))
						aAdd( aItens[nI], { 'DA1_ATIVO', oIteTbPri[nI]:getPropValue("ActiveItemPrice"), Nil } )  
					EndIf   
					
					If lTippre .And. oIteTbPri[nI]:getPropValue("TypePrice") != Nil .And. !Empty(oIteTbPri[nI]:getPropValue("TypePrice"))
						aAdd( aItens[nI], { 'DA1_TIPPRE', oIteTbPri[nI]:getPropValue("TypePrice"), Nil} )
					EndIf

					If nOpcx <> 5 .And. oIteTbPri[nI]:getPropValue("Event") != NIL .AND. Upper(AllTrim(oIteTbPri[nI]:getPropValue("Event"))) == 'DELETE'
						aAdd( aItens[nI], { 'AUTDELETA', 'S', Nil } )
					EndIf					

					// Realiza a leitura da seção AddFields com os campos sem tag ou customizados para gravar na DA1
					If lAddField .And. oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item")[nI]:getPropValue("AddFields") != nil;
						.And. !Empty(oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item")[nI]:getPropValue("AddFields"))
						
						cPrefCpo := "DA1"
						IntAddField(@oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item")[nI]:getPropValue("AddFields"), nTypeTrans, @aItens[nI], cCpoTagDA1, cPrefCpo)
					EndIf

				Next nI
	
				If nOpcx == 4
					oModel:DeActivate()
					oModel:Destroy()
					oHashJSON:Clean()
				EndIf
				
				//Atualiza model com dados recebidos 
				MSExecAuto({|x, y, z| OMSA010(x, y, z)}, aHeader, aItens, nOpcx)
				
				If lMsErroAuto
					aMsgErro := GetAutoGRLog()
					nErrSize := Len(aMsgErro)
					lRet := .F.
					
					cLogErro := ""
					For nR := 1 To nErrSize
						cLogErro += aMsgErro[nR]  
					Next nCount
	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
				  	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
					
					//Monta de Erro de execução da rotina automatica.
					DisarmTransaction()
					MsUnlockAll()
				
				Else
					Return {lRet, STR0008, cEntity} //'operação realizado com sucesso!'
				EndIf
			EndIf		
			
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------	
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )   
				cMarca := Upper(oEAIObEt:getHeaderValue("ProductName"))
			Endif
			
			// Identifica se o processamento pelo parceiro ocorreu com sucesso.
			If 	Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) != nil .And. ;
				Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"
				
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil 
					oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")
					If oObLisOfIt[1]:getPropValue('Origin') != nil .And. oObLisOfIt[1]:getPropValue('Destination') != nil .And. oObLisOfIt[1]:getPropValue('Name') != nil
						If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
							CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', oObLisOfIt[1]:getPropValue('Destination'), oObLisOfIt[1]:getPropValue('Origin'), .F. )	
						Elseif Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
							CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', oObLisOfIt[1]:getPropValue('Destination'), oObLisOfIt[1]:getPropValue('Origin'), .T. )
						Endif				
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0003 //"De-Para não pode ser gravado a integração poderá ter falhas"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
					Endif
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0003 //"De-Para não pode ser gravado a integração poderá ter falhas"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
															
				Endif
		
			Else
				lRet    := .F.
				If Empty( cLogErro )
					cLogErro := STR0004 + CRLF //"Processamento pela outra aplicação não teve sucesso"
					
					If oEAIObEt:getpropvalue('ProcessingInformation') != nil
						If ( oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("Details") ) != Nil
							For nX := 1 To Len( oMsgError )
								If oMsgError[nX]:getpropvalue('DetailedMessage') != Nil
									cLogErro += oMsgError[nX]:getpropvalue('DetailedMessage') + CRLF
								EndIf
							Next nX
						EndIf
					Endif
		
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		
				Endif		
			EndIf
		EndIf
	
	//--------------------------------------
	//envio mensagem
	//--------------------------------------          
	ElseIf ( nTypeTrans == TRANS_SEND )
	
		oModel 		:= FWModelActive()						//Instancia objeto com o model completo da tabela de preços
		oModelDA0	:= oModel:GetModel( 'DA0MASTER' )	//Instancia objeto com model da master apenas
		oModelDA1	:= oModel:GetModel( 'DA1DETAIL' )	//Instancia objeto com model da detail apenas
	
		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf
		
		//Carrega os campos data, deixando em branco se não tiverem sido preenchidos
		If MV_PAR01 == 1 .Or. oModel:nOperation == 3 //Demonstrar por: 1-Tabela ou operação de inclusão
			cDataDe	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATDE') ), cValToChar( oModelDA0:GetValue('DA0_DATDE') ), '' )
			cDataAte	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATATE') ), cValToChar( oModelDA0:GetValue('DA0_DATATE') ), '' )
		EndIf

		lCargaIni := ( FWIsInCallStack( 'OMSM010' ) .Or. FWIsInCallStack( 'IPCCFG020A' ) .Or. FWIsInCallStack( 'OMS010CPY' ) )
		
		//Montagem da mensagem
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)
		
		ofwEAIObj:SetProp("CompanyID"	,cEmpAnt)
		ofwEAIObj:SetProp("BranchId"         	,cFilAnt)
		ofwEAIObj:SetProp("CompanyInternalID"	,cEmpAnt + '|' + cFilAnt )
		If MV_PAR01 == 1 .Or. oModel:nOperation == 3 //Demonstrar por: 1-Tabela ou operação de inclusão
			ofwEAIObj:setprop("InternalId", cEmpAnt + "|" + RTrim(FWxFilial("DA0")) + "|" + oModelDA0:GetValue('DA0_CODTAB') )
			ofwEAIObj:setprop("Code", oModelDA0:GetValue('DA0_CODTAB') )
			ofwEAIObj:setprop("Name", oModelDA0:GetValue('DA0_DESCRI') )
			ofwEAIObj:setprop("InitialDate", cDataDe )
			ofwEAIObj:setprop("FinalDate", cDataAte )
			ofwEAIObj:setprop("InitialHour", oModelDA0:GetValue('DA0_HORADE') + ':00' )
			ofwEAIObj:setprop("FinalHour", oModelDA0:GetValue('DA0_HORATE') + ':00' )
			ofwEAIObj:setprop("ActiveTablePrice", oModelDA0:GetValue('DA0_ATIVO') )	
		EndIf

		If ExistBlock("OMSIOACT")
			cJson := ExecBlock("OMSIOACT",.F.,.F., {cEvent, oModelDA0})
			If ValType( cJson ) == "C" .And. !( Empty( cJson ) )
				ofwEAIObj:loadJson(cJson)
			Endif
		EndIf	

		/*Efetua a Paginacao*/
		nReg := oModelDA1:Length()
		If Len(FwAdapterInfo( "OMSA010", "PRICELISTHEADERITEM"))>=10
			lCrmInteg := .T.	
			ofwEAIObj:setprop("Page", nPage)
			If Upper(SuperGetMV("MV_TPCPAG",.F.,"ALL")) <> "ALL"
				nPageSize := Val(SuperGetMV("MV_TPCPAG",.F.,"100"))//Se o Default do parametro não for ALL e não tiver valor assume 100
				nPages := Round(oModelDA1:Length() / nPageSize,0)
				If  nPages < oModelDA1:Length() / nPageSize
					nPages++
				EndIf
			Else
				nPageSize := oModelDA1:Length()
				nPages := 1
			EndIf
			ofwEAIObj:setprop("TotalPages", nPages)
			ofwEAIObj:setprop("PageSize", nPageSize)
			ofwEAIObj:setprop("TotalRecords", oModelDA1:Length())

			nStart := ((nPage-1) * nPageSize) + 1
			
			If nPage == nPages
				nReg := oModelDA1:Length()
				ofwEAIObj:setprop("NextPage", .F.)
			Else
				nReg := nPage * nPageSize
				ofwEAIObj:setprop("NextPage", .T.)
			EndIf
		EndIf

		//Se Demonstrar por: 2-PRODUTO e for operação de alteração não gera seção AddFields referente a DA0
		If MV_PAR01 == 1 .Or. !(MV_PAR01 == 2 .And. oModel:nOperation == 4)
			// Verifica os campos sem tag que estão preenchidos para gerar a seção AddFields referente a DA0
			If Substr(cEAIFLDS, 4, 1) == "1".And. lAddField
				aFieldStru  := FWSX3Util():GetAllFields("DA0", .F.)
				IntAddField(@ofwEAIObj, nTypeTrans, aFieldStru, cCpoTagDA0, "DA0")
			EndIf
		EndIf
		
		ofwEAIObj:setprop("ItensTablePrice")
		
		//Monta os itens da tabela de preços (DA1)
		For nI := nStart To nReg

			nControl += 1
			oModelDA1:GoLine(nI)
			
			//Carrega o campo data, deixando em branco se não tiver sido preenchido
			cDataVig := IIf( !Empty( oModelDA1:GetValue('DA1_DATVIG') ), cValToChar( oModelDA1:GetValue('DA1_DATVIG') ), '' )
			
			//Somente adiciona o item na mensagem se ele sofreu alguma modificação
			//Se o item foi inserido e deletado não envia
			//No caso de exclusão da tabela de preços, os itens não serão enviados, pois não sofreram alterações
			//Se a rotina foi acionada pela carga inicial envia tudo
			//Se Integra via rotina Gerar (lCrmInteg := .T.) Continua montando agora.
			If 	(lCrmInteg .And. (oModelDA1:IsInserted() .Or. oModelDA1:IsUpdated())) .OR. (( oModelDA1:IsDeleted() .And. !oModelDA1:IsInserted()) .Or.;
				(oModelDA1:IsUpdated() .And. !oModelDA1:IsDeleted()) .Or. lCargaIni)
				
				ofwEAIObj:getPropValue("ItensTablePrice"):setProp("Item",{})
				nContReg := Len( ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item") )
				If MV_PAR01 == 2 .And. oModel:nOperation == 4 //Demonstrar por: 2-PRODUTO e operação de alteração
					ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("InternalId", cEmpAnt + "|" + RTrim(FWxFilial("DA0")) + "|" + oModelDA1:GetValue('DA1_CODTAB')	)
					ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("Code", oModelDA1:GetValue('DA1_CODTAB')	)
					ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("Name", oModelDA1:GetValue('DA1_DESTAB')	)
				EndIf
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemCode", oModelDA1:GetValue('DA1_CODPRO')	)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemInternalId", cEmpAnt + "|" + RTrim(FWxFilial("SB1")) + "|" + oModelDA1:GetValue('DA1_CODPRO')	)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("MinimumSalesPrice", oModelDA1:GetValue('DA1_PRCVEN') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("DiscountValue", oModelDA1:GetValue('DA1_VLRDES') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("DiscountFactor", oModelDA1:GetValue('DA1_PERDES') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemValidity", cDataVig )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ActiveItemPrice", oModelDA1:GetValue('DA1_ATIVO ') )
				If ExistBlock("OMSIOAIT")
					aRetItem := ExecBlock("OMSIOAIT",.F.,.F., {cEvent, oModelDA1, ni})
					If ValType( aRetItem ) == "A" .And. !( Empty( aRetItem ) ) 
						For nj := 1 To Len(aRetItem)
							If (Len( aRetItem[nJ] ) == 2) 
								ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp(aRetItem[nJ,1], aRetItem[nJ,2] )
							Endif	
						Next nJ
					Endif
				EndIf
				If lTippre
					ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("TypePrice", cValToChar( oModelDA1:GetValue('DA1_TIPPRE') ) )
				EndIf
	
				//Define a operação no item
				If ( oModelDA1:IsDeleted() )
					cEvntItem := 'delete' 	
				Else
					cEvntItem := 'upsert'
				EndIf	
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("Event", cEvntItem )		
				
			EndIf
			
			// Verifica os campos sem tag que estão preenchidos para gerar a seção AddFields referente a DA1
			If Substr(cEAIFLDS, 4, 1) == "1".And. lAddField
				If ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg] <> Nil

					// Este posicionamento se faz necessario devido a tabela DA1 estar posicionada no último item da tabela preço
					DA1->(dbSetOrder(2))	//DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
					If DA1->(dbSeek(cFilDA1+oModelDA1:GetValue('DA1_CODPRO')+oModelDA0:GetValue('DA0_CODTAB')+oModelDA1:GetValue('DA1_ITEM')))
                       
						aFieldStru  := FWSX3Util():GetAllFields("DA1", .F.)
						IntAddField(@ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg], nTypeTrans, aFieldStru, cCpoTagDA1, "DA1")
					EndIf
				EndIf
			EndIf
		Next nI
		
		IIF( ( nControl > oModelDA1:Length() ), nControl := -1, )

		
	EndIf
	
	//Restaura ambiente
	FWRestRows( aSaveLine )     
	FWRestArea(aAreaDA1)
	FWRestArea(aAreaDA0)
	FWRestArea(aArea)

	aSize(aArea,0)
	aArea	:= {}
	
	aSize(aAreaDA0,0)
	aAreaDA0	:= {}
	
	aSize(aAreaDA1,0)
	aAreaDA1	:= {}

	aSize(aSaveLine,0)
	aSaveLine := {}
	
	aSize(aHeader,0)
	aHeader	:= {}
	
	aSize(aItens,0)
	aItens	:= {}
	
	aSize(aMsgErro,0)
	aMsgErro	:= {}	
	
	aSize(aRet,0)
	aMsgErro	:= {}	

Return {lRet, ofwEAIObj, cEntity}
