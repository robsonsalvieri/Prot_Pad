#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOCI076.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCI076
Funcao de integracao com o adapter EAI para tratamento da mensagem CANCELINVOICENOTIFY

Onde se recebe o Numero do Documento de saída (InvoiceNumber) e o Documento é cancelado

@param		cXml			Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans		Tipo de transação. (Envio/Recebimento)
@param		cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)

@author	Jose Eulalio
@version	P12
@since	17/06/2022
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function LOCI076(cXML, nTypeTrans, cTypeMessage, cVersion)

Local cVersao	:= ""
Local lRet		:= .T.
Local cXmlRet	:= ""
Local cNameMsg	:= "CANCELINVOICENOTIFY"
Local aRet		:= {}

Private oXml    := Nil

//Valida versão de envio e/ou recebimento
cVersao := StrTokArr(cVersion, ".")[1]
	
//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		If cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage)
			lRet    := aRet[1]
			cXMLRet := aRet[2]
		Else
			lRet    := .F.
			cXmlRet := STR0001 //"A versão da mensagem informada não foi implementada!"
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v1000(cXml, nTypeTrans, cTypeMessage)
		lRet    := aRet[1]
		cXMLRet := aRet[2]
	Endif
	
// Mensagem de Saida	
ElseIf nTypeTrans == TRANS_SEND
	cXmlRet :=  STR0002 //"Esta mensagem apenas recebe requisições!"
EndIf

Return {lRet, cXmlRet, cNameMsg}

/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para cancelamento de Documento de Saida
@author José Eulalio
@since	17/06/2022
@version 1.0
@param 	cXML - Variavel com conteudo xml para recebimento.     
@param nTypeTrans - Tipo de transacao. (Recebimento)          
@param cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) 
@return 
	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.                                       
		aRet[1] - (boolean) Indica o resultado da execução da função 
		aRet[2] - (caracter) Mensagem Xml para envio                 
/*/
Static Function v1000( cXML, nTypeTrans, cTypeMessage )
Local aArea		:= GetArea()
Local aCabSF1	:= {}
Local aDadSD1	:= {}
Local aLinha	:= {}
Local aLogAuto 	:= {}
Local cInvNumber:= ""
Local cInvSerie	:= ""
Local cInvType	:= ""
Local cXMLRet 	:= ""
Local cError	:= ""
Local cWarning	:= ""
Local nX		:= 0
Local lRet		:= .T.
Local cRomaneio := ""

Private oXmlM076

//Trata o recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )
	
	//Trata o recebimento de dados (BusinessContent)
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		
		oXmlM076 := XmlParser( cXml, "_", @cError, @cWarning )
		
		//Verifica se houve erro na criacao do objeto XML
		If ( oXmlM076 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
			
			// Caso seja Fornecedor
			If ( AllTrim( Upper( oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Entity:Text ) ) == "CANCELINVOICENOTIFY")
				//--------------------------------------------------------------------------------------
				//-- Tratamento utilizando a tabela XXF com um De/Para de codigos
				//--------------------------------------------------------------------------------------
				// Documento e Serie
				If 		( Type( "oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceNumber:Text" ) <> "U" ) .And. ;
						( Type( "oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceSerie:Text" ) <> "U" )
					cInvNumber	:= AllTrim(oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceNumber:Text)
					cInvSerie	:= AllTrim(oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceSerie:Text)

					if len(cInvNumber) < tamsx3("F1_DOC")[1]
                    	cInvNumber := cInvNumber + space( tamsx3("F1_DOC")[1] - len(cInvNumber) )
                	EndIf
                	if len(cInvSerie) < tamsx3("F1_SERIE")[1]
	                    cInvSerie := cInvSerie + space( tamsx3("F1_SERIE")[1] - len(cInvSerie) )
                	EndIf

				EndIf
				// Tipo de Documento
				If 	( Type( "oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeOfInvoice:Text" ) <> "U" )
					cInvType	:= AllTrim(oXmlM076:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeOfInvoice:Text)
				EndIf
				//Tratamento em caso não mande documento
				If Empty(cInvNumber)  
					lRet		:= .F.
					cXMLRet		:= STR0003 //"Não foi informado número do documento na mensagem!"
				Else
					//Começa o controle de transação
					//Begin Transaction

						//tipo de documento 1 = Documento de Entrada / 2 = Documento de Saída
						If cInvType == "1"
							SF1->(dbSetOrder(1))
							If SF1->(dbSeek(xFilial("SF1") + cInvNumber + cInvSerie))
								aAdd(aCabSF1, {"F1_DOC",     SF1->F1_DOC,     Nil})
								aAdd(aCabSF1, {"F1_SERIE",   SF1->F1_SERIE,   Nil})
								aAdd(aCabSF1, {"F1_FORNECE", SF1->F1_FORNECE, Nil})
								aAdd(aCabSF1, {"F1_LOJA",    SF1->F1_LOJA,    Nil})
								aAdd(aCabSF1, {"F1_TIPO",    SF1->F1_TIPO,    Nil})
								aAdd(aCabSF1, {"F1_ESPECIE", SF1->F1_ESPECIE, Nil})
								//Posiciona na SD1
								SD1->(DbSetOrder(1))
								If SD1->(DbSeek(xFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
									//Percorre os itens e monta o array de itens
									While 	! SD1->(EoF())               		.And.;
											SD1->D1_DOC     == SF1->F1_DOC     .And.;
											SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
											SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
											SD1->D1_LOJA    == SF1->F1_LOJA 
										
										aLinha := {}
										aAdd(aLinha,  {"D1_DOC",     SD1->D1_DOC,     Nil})
										aAdd(aLinha,  {"D1_SERIE",   SD1->D1_SERIE,   Nil})
										aAdd(aLinha,  {"D1_FORNECE", SD1->D1_FORNECE, Nil})
										aAdd(aLinha,  {"D1_LOJA",    SD1->D1_LOJA,    Nil})
										aAdd(aLinha,  {"D1_TIPO",    SD1->D1_TIPO,    Nil})
										aAdd(aLinha,  {"D1_ITEM",    SD1->D1_ITEM,    Nil})
										aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,     Nil})
										aAdd(aDadSD1, aClone(aLinha))
										
										SD1->(DbSkip())
									EndDo
									
									//Ordena pelo número do item
									aSort(aDadSD1, , , { |x, y| x[6] < y[6] })
								EndIf
								//executa rotina automatica
                                lMsErroAuto := .F.
								cRomaneio := SF1->F1_IT_ROMA
								MSExecAuto({|a,b,c| MATA103(a,b,c)},aCabSF1,aDadSD1,5)
								//Se houve erro, mostra o erro, disarma a transação e atualiza a variável
                                If lMsErroAuto
                                    //MostraErro()
									//Pegando log do ExecAuto
									aLogAuto := GetAutoGRLog()
									
									//Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
									For nX := 1 To Len(aLogAuto)
										cError += aLogAuto[nX] + CRLF
									Next nX
                                    //DisarmTransaction()
									cXMLRet := cError + CRLF + STR0004 //"Não foi possível excluir Documento de Entrada!"
									lRet    := .F.
								Else
									cXMLRet := "OK"
									//If ExistBlock("MT103FIM") 	
									//	ExecBlock("MT103FIM",.T.,.T.,{5,1})
									//ENDIF
                                EndIf
							Else
								cXMLRet := STR0005  //"Documento não localizado"
								lRet    := .F.
							EndIF	
						ElseIf cInvType == "2"
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2") + cInvNumber + cInvSerie))
								cAlias 		:= "SF2"
								nReg        := 1
								nOpcX       := 1
								lAutomato	:= .T.
								lAglCtb		:= .F.
								lContab		:= .F.
								lCarteira 	:= .F.
								//realiza exclusão do documento de saída (específico do RENTAL é feito por PE)
								If Ma521Mbrow(cAlias,nReg,nOpcX,lAutomato,lAglCtb,lContab,lCarteira)
									cXMLRet := "OK"
									If ExistBlock("SF2520E") 	
										ExecBlock("SF2520E",.T.,.T.,{})
									ENDIF
								Else
									cXMLRet := STR0006 //"Ocorreu um erro no processo de exclusão. Entre em contato com o Administrador Protheus."
									lRet    := .F.
								EndIf
							Else
								cXMLRet := STR0005 //"Documento não localizado"
								lRet    := .F.
							EndIF
						Else
							cXMLRet := STR0007 //"Tipo de Documento invalido"
							lRet    := .F.
						EndIf

					//End Transaction
										
				EndIf
			EndIf
		Else
			//Tratamento em caso de falha ao gerar o objeto XML
			lRet    := .F.
			cXMLRet := STR0008 + cWarning + ' | ' + cError //"Xml mal formatado. "
		EndIf		
	
	//Tratamento de solicitacao de versao
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := "1.000"
	EndIf
	
//Tratamento de envio de mensagens
ElseIf ( nTypeTrans == TRANS_SEND )
	
	cXMLRet += STR0009 //"Mensagem não implementada"
	
EndIf

RestArea(aArea)
Return { lRet, cXMLRet }

