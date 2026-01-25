#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


//-------------------------------------
/*	IntegDef
@author    	Caio Murakami
@return 		Valor lógico e XML*/
//-------------------------------------

Function OMSI060( cXML, nTypeTrans, cTypeMessage )

Local lRet     	:= .T.
Local lExecAuto	:= .T.
Local lRastre		:= AliasInDic("DAW")
Local cXMLRet  	:= ""
Local cError		:= ""
Local cWarning 	:= ""
Local cLogErro 	:= ""
Local cEvent      := "upsert"
Local cDatAtu     := ""
Local cCodFor     := ""
Local cLojFor		:= ""
Local cMarca 		:= ""
Local cValInt		:= ""
Local cValExt		:= ""
Local cCodRas		:= ""
Local cLojRas		:= ""
Local cCGCRas		:= ""
Local cCodVei		:= ""
Local cQuery		:= ""
Local cAliasQry
Local nCount      := 0
Local nOpcx			:= 0
Local aCab			:= {}
Local aItens		:= {}
Local aErroAuto	:= {}
Local aArea			:= GetArea()

Private oXmlA060		  := Nil
Private nCountA060	  := 0
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

If Type("Inclui") == "U"
	Private Inclui := .T.
EndIf

If Type("Altera") == "U"
	Private Altera := .F.
EndIf

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlA060 := XmlParser(cXml, "_", @cError, @cWarning)

		If oXmlA060 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			DA3->( dbSetOrder( 1 ) )
			If Upper(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
			   If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> "U"
					If DA3->( MsSeek( xFilial('DA3')+oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text))
						nOpcx:= 4
					Else
						nOpcx:= 3
					EndIf
					cCodVei := oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
					Aadd( aCab, { "DA3_COD", cCodVei , Nil })
				EndIf
			ElseIf Upper(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
				nOpcx := 5
				If !DA3->( MsSeek( xFilial('DA3')+oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text))
            	lExecAuto := .F.
				Else
					cCodVei := oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
					Aadd( aCab, { "DA3_COD", cCodVei, Nil })
				EndIf
			EndIf

			//If nOpcx <> 5
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Model:Text") <> "U"
					Aadd( aCab, { "DA3_DESC", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Model:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_ID:Text") <> "U"
					Aadd( aCab, { "DA3_PLACA ", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_ID:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_State:_Code:Text") <> "U"
					Aadd( aCab, { "DA3_ESTPLA", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_State:_Code:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_City:_Description:Text") <> "U"
					Aadd( aCab, { "DA3_MUNPLA ", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plate:_City:_Description:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalLenght:Text") <> "U"
					Aadd( aCab, { "DA3_COMEXT" , Val(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalLenght:Text), Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalHeight:Text") <> "U"
					Aadd( aCab, { "DA3_ALTEXT" , Val(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalHeight:Text), Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalWidth:Text") <> "U"
					Aadd( aCab, { "DA3_LAREXT" , Val(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ExternalWidth:Text), Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeFleet:Text") <> "U"
					Aadd( aCab, { "DA3_FROVEI" , oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeFleet:Text, Nil })
				EndIf
				//-- Codigo do fornecedor
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Owner:_Id:Text") <> "U"
				  	cValExt := oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Owner:_Id:Text

					//--------------------------------------------------------------------------------------
					//-- Tratamento utilizando a tabela XXF com um De/Para de codigos
					//--------------------------------------------------------------------------------------
					If FindFunction("CFGA070INT")
						cMarca  := oXmlA060:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						cValInt := AllTrim(CFGA070INT( cMarca , "SA2", "A2_COD" , cValExt ))
					EndIf

					If Empty(cValInt)
						cValInt := cValExt
					EndIf

					cCodFor := SubStr(cValInt,1,TamSX3('DA3_CODFOR')[1])
					cLojFor := SubStr(cValInt,TamSx3('DA3_CODFOR')[1]+1,TamSx3('DA3_LOJFOR')[1])
					Aadd( aCab , { "DA3_CODFOR",cCodFor, 		NIL })
			  		Aadd( aCab , { "DA3_LOJFOR",cLojFor,      NIL })
				EndIf

				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BrandCode:Text") <> "U"
					Aadd( aCab, { "DA3_MARVEI", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BrandCode:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ColorCode:Text") <> "U"
					Aadd( aCab, { "DA3_CORVEI", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ColorCode:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ModelYear:Text") <> "U"
					Aadd( aCab, { "DA3_ANOMOD" , oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ModelYear:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ManufactureYear:Text") <> "U"
					Aadd( aCab, { "DA3_ANOFAB" , oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ManufactureYear:Text, Nil })
				EndIf
					If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Chassis:Text") <> "U"
					Aadd( aCab, { "DA3_CHASSI" , oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Chassis:Text, Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeCode:Text") <> "U"
					Aadd( aCab, { "DA3_TIPVEI", oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeCode:Text, Nil })
				EndIf
		  		If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Axles:Text") <> "U"
					Aadd( aCab, { "DA3_QTDEIX" , Val(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Axles:Text), Nil })
				EndIf
				If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RenavamCode:Text") <> "U"
					Aadd( aCab, { "DA3_RENAVA" , oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RenavamCode:Text, Nil })
				EndIf
			//EndIf

			If Type("oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker") <> "U"

				If ValType(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker) <> "A"
					XmlNode2Arr(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker,"_Tracker")
				EndIf

			   If lRastre
			   	If nOpcx <> 5
						For nCount:= 1 To Len(oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker)

							cIDRas :=  oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker[nCount]:_Code:Text
							cCGCRas := oXmlA060:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfTrackers:_Tracker[nCount]:_ManufacturerID:Text

							//-- A2_FILIAL + A2_CGC
							SA2->( dbSetOrder(3) )
							If SA2->( dbSeek( xFilial("SA2") +  cCGCRas ) )
								cCodRas := SA2->A2_COD
								cLojRas := SA2->A2_LOJA
							EndIf

							Aadd( aItens , {} )
							Aadd( aItens[nCount] , {"DAW_ITEM"  , StrZero( nCount, TamSX3("DAW_ITEM")[1] ), Nil })
							Aadd( aItens[nCount] , {"DAW_IDRAS" , cIDRas 											, Nil })
						 	Aadd( aItens[nCount] , {"DAW_CODRAS", cCodRas 											, NIL })
						 	Aadd( aItens[nCount] , {"DAW_LOJRAS", cLojRas											, NIL })

						Next nCount
					EndIf
				EndIf

			EndIf

			If lExecAuto
				MSExecAuto({|x,y,z| OMSA060(x,y,z)},aCab,nOpcx, aItens)
			EndIf

			If lMsErroAuto
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(StrTran(aErroAuto[nCount],"<",""),"-",""),"   "," ") + (" ")
				Next nCount
				// Monta XML de Erro de execução da rotina automatica.
				lRet := .F.
				cXMLRet := SubSTR(cLogErro,1,750)
			Else
				// Monta xml com status do processamento da rotina autmotica OK.
				cXMLRet := "<OriginInternalID>"+  AllTrim(DA3->DA3_COD) +"</OriginInternalID>"
			EndIf

		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf

ElseIf nTypeTrans == TRANS_SEND

	If !Inclui .And. !Altera
		cEvent := 'delete'
	EndIf

  	cDatAtu := Transform(dToS(dDataBase),"@R 9999-99-99")

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>Vehicles</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' +AllTrim(DA3->DA3_COD)+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet += '<BusinessContent>'
	cXMLRet += 		'<Code>'     			+AllTrim(DA3->DA3_COD)+	 			'</Code>'
	cXMLRet += 		'<Model>'				+AllTrim(DA3->DA3_DESC)+			'</Model>'

	cXMLRet += 		'<Plate>'
	cXMLRet += 			'<ID>'				+AllTrim(DA3->DA3_PLACA)+			'</ID>'

	If !Empty(DA3->DA3_ESTPLA)
  		cXMLRet += 			'<State>'
  		cXMLRet += 				'<Code>'			+AllTrim(DA3->DA3_ESTPLA)+			'</Code>'
  		cXMLRet += 				'<Description>'+ AllTrim(Posicione("SX5",1, xFilial("SX5") + "12" + DA3->DA3_ESTPLA, "X5DESCRI()" )) +'</Description>'
		cXMLRet += 			'</State>'
	EndIf

	cXMLRet += 			'<City>'
	cXMLRet += 				'<Description>'+AllTrim(DA3->DA3_MUNPLA)+			'</Description>'
	cXMLRet += 			'</City>'

	cXMLRet += 		'</Plate>'

	If !Empty(DA3->DA3_MARVEI)
		cXMLRet += 		'<BrandCode>'			+AllTrim(DA3->DA3_MARVEI)+			'</BrandCode>'
		cXMLRet +=  	'<BrandDescription>'	+AllTrim(Posicione("SX5",1, xFilial("SX5") + "M6" + DA3->DA3_MARVEI, "X5DESCRI()" ))+		'</BrandDescription>'
   EndIf

	If !Empty(DA3->DA3_CORVEI)
		cXMLRet += 		'<ColorCode>'			+AllTrim(DA3->DA3_CORVEI)+	 		'</ColorCode>'
		cXMLRet += 		'<ColorDescription>'	+AllTrim(Posicione("SX5",1, xFilial("SX5") + "M7" + DA3->DA3_CORVEI, "X5DESCRI()" ))+	  		'</ColorDescription>'
	EndIf

	cXMLRet += 		'<TypeCode>'			+AllTrim(DA3->DA3_TIPVEI)+			'</TypeCode>'
	cXMLRet += 		'<TypeDescription>'	+ AllTrim(M->DA3_DESTIP)+  		'</TypeDescription>'

	cXMLRet += 		'<Chassis>'				+AllTrim(DA3->DA3_CHASSI)+			'</Chassis>'
	cXMLRet += 		'<RenavamCode>'		+AllTrim(DA3->DA3_RENAVA)+			'</RenavamCode>'
	cXMLRet += 		'<TypeFleet>'			+AllTrim(DA3->DA3_FROVEI)+			'</TypeFleet>'
	cXMLRet +=		'<Axles>'				+cValToChar(DA3->DA3_QTDEIX)+		'</Axles>'
	cXMLRet += 		'<ExternalLenght>'	+cValToChar(DA3->DA3_COMEXT)+		'</ExternalLenght>'
	cXMLRet += 		'<ExternalHeight>'	+cValToChar(DA3->DA3_ALTEXT)+		'</ExternalHeight>'
	cXMLRet += 		'<ExternalWidth>' 	+cValToChar(DA3->DA3_LAREXT)+		'</ExternalWidth>'
	cXMLRet += 		'<ModelYear>'			+AllTrim(DA3->DA3_ANOMOD)+			'</ModelYear>'
	cXMLRet += 		'<ManufactureYear>'	+AllTrim(DA3->DA3_ANOFAB)+			'</ManufactureYear>'

	cXMLRet +=		'<Owner>'
	cXMLRet +=			'<Id>'     			+AllTrim(DA3->(DA3_CODFOR + DA3_LOJFOR))+ 			'</Id>'
	cXMLRet += 		'</Owner>'
	If lRastre
		If !('delete' $ cEvent)

			DAW->( dbSetOrder(1) )
			If DAW->( dbSeek(xFilial("DAW") + DA3->DA3_COD ) )
				cXMLRet += 		'<ListOfTrackers>'
				While !DAW->( Eof() ) .And. DAW->DAW_CODVEI == DA3->DA3_COD .And.  DAW->DAW_MSBLQL == '2'

					cCGCRas := Posicione("SA2",1,xFilial("SA2") + DAW->(DAW_CODRAS + DAW_LOJRAS) ,"A2_CGC")

					cXMLRet += 			'<Tracker>'
					cXMLRet += 				'<Code>'+AllTrim(DAW->DAW_IDRAS)+'</Code>'
					cXMLRet += 				'<ManufacturerID>'+AllTrim(cCGCRas)+'</ManufacturerID>'
					cXMLRet += 			'</Tracker>'

					DAW->( dbSkip() )
				EndDo
				cXMLRet += 		'</ListOfTrackers>'
			EndIf

		Else
			#IFDEF TOP

				cAliasQry := GetNextAlias()

				cQuery := " SELECT DAW_IDRAS, DAW_CODRAS, DAW_LOJRAS "
				cQuery += " FROM " + RetSQLName("DAW") + " DAW "
				cQuery += " WHERE DAW_FILIAL  = '" + xFilial("DAW")  + " '
				cQuery += " 	AND DAW_CODVEI = '" + DA3->DA3_COD    + " '

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

				cXMLRet += 		'<ListOfTrackers>'
				While !(cAliasQry)->(EOF())
				 	cXMLRet += 			'<Tracker>'
						cXMLRet += 				'<Code>'+AllTrim((cAliasQry)->DAW_IDRAS)+'</Code>'
						cCGCRas := Posicione("SA2",1,xFilial("SA2") + (cAliasQry)->(DAW_CODRAS + DAW_LOJRAS) ,"A2_CGC")
						cXMLRet += 				'<ManufacturerID>'+AllTrim(cCGCRas)+'</ManufacturerID>'
					cXMLRet += 			'</Tracker>'
					(cAliasQry)->( dbSkip() )
				EndDo
				cXMLRet += 		'</ListOfTrackers>'
				(cAliasQry)->(dbCloseArea())

			#ENDIF
		EndIf
	EndIf
	cXMLRet += '</BusinessContent>'

EndIf

RestArea( aArea )
Return { lRet, cXMLRet }