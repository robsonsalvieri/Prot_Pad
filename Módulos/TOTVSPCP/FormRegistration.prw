#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "formregistration.ch"

STATIC lDicValido := Nil

WSRESTFUL FormRegistration DESCRIPTION "Serviço REST para manipulação do Cadastro de Formulários do apontamento"

WSDATA userCode	  AS String  
WSDATA code       AS String  Optional
WSDATA count      AS INTEGER Optional
WSDATA startIndex AS INTEGER Optional
WSDATA page    	  AS INTEGER Optional
WSDATA onlyHeader AS INTEGER Optional
WSDATA codeForm   AS String
WSDATA productionOrder AS INTEGER Optional
 
WSMETHOD GET Form 				DESCRIPTION "Recupera os formulários de apontamento"				WSSYNTAX "/Form/{code}/{startIndex}/{count}/{page}" PATH "/Form"
WSMETHOD GET FormUsers 			DESCRIPTION "Recupera os formulários de apontamento do usuário"		WSSYNTAX "/FormUsers/{userCode}/{startIndex}/{count}/{page}/{onlyHeader}" PATH "FormUsers"
WSMETHOD GET FormFields			DESCRIPTION "Recupera os campos do formulário"						WSSYNTAX "/FormFields/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormFields"
WSMETHOD GET FormConfig			DESCRIPTION "Recupera a configuração de um formulário"				WSSYNTAX "/FormConfig/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormConfig"
WSMETHOD GET FormMachines		DESCRIPTION "Recupera as máquinas do formulário"					WSSYNTAX "/FormMachines/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormMachines"
WSMETHOD GET FormCustomField	DESCRIPTION "Recupera os campos customizados do formulário"		    WSSYNTAX "/FormCustomField/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormCustomField"

WSMETHOD GET profile;
	DESCRIPTION "Recupera as permissões de acesso";
	WSSYNTAX "/profile";
	PATH "/profile"

//Ação leitura qrcode
WSMETHOD POST BarcodeAction;
	DESCRIPTION "Executa uma ação no formulário de apontamento";
	WSSYNTAX "/v1/barcodeaction/";
	PATH "/v1/barcodeaction/"

END WSRESTFUL

WSMETHOD GET profile WSSERVICE FormRegistration
    Local oJson := JsonObject():New()

    oJson["apiVersion"] := 5

    ::SetResponse(EncodeUTF8(oJson:toJson()))
Return .T.

WSMETHOD GET Form WSRECEIVE code, startIndex, count, page WSSERVICE FormRegistration
	Local aSOX  := {}
	Local lGet  := .T.
	Local lSMJ  := AliasInDic("SMJ")
	Local nI    := 0
	Local oJson := Nil
	Local oSMJ  := Nil

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.	
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		If !Empty(::code)

			// insira aqui o código para pesquisa do parametro recebido
			aSOX := PCPA121Con(::code)
			If Len(aSOX) > 0
				oJson['code']            := EncodeUTF8(aSOX[1,1])
				oJson['appointmentType'] := aSOX[1,2]
				oJson['iconName']        := aSOX[1,3]
				oJson['description']     := trim(EncodeUTF8(aSOX[1,4]))
				oJson['stopReport']      := aSOX[1,5]
				oJson['useTimer']        := aSOX[1,6]
				oJson['typeProgress']    := aSOX[1,7]

				If lSMJ 
					oSMJ := PCPA121Emp(aSOX[1,1], .F.)
					oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
					oJson["insertAllocations"] := oSMJ["insertAllocations"]
					oJson["updateAllocations"] := oSMJ["updateAllocations"]
					oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
				EndIf
			Else
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			EndIf

			// exemplo de retorno de um objeto JSON
			::SetResponse(oJson:toJson())

			If oSMJ != Nil
				FreeObj(oSMJ)
				oSMJ := Nil
			EndIf
		Else
			// as propriedades da classe receberão os valores enviados por querystring
			// exemplo: http://localhost:8080/sample?startIndex=1&count=10
			DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

			// exemplo de retorno de uma lista de objetos JSON
			aSOX:= PCPA121con(::code, ::startIndex, ::count, ::page)
			
			If Len(aSOX) < 1
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			Else	
				::SetResponse('[')
				For nI := 1 To len(aSOX)
					If nI > ::startIndex
						::SetResponse(',')
					EndIf
					oJson['code']            := EncodeUTF8(aSOX[nI,1])
					oJson['appointmentType'] := aSOX[nI,2]
					oJson['iconName']        := aSOX[nI,3]
					oJson['description']     := trim(EncodeUTF8(aSOX[nI,4]))
					oJson['stopReport']      := aSOX[nI,5]
					oJson['useTimer']        := aSOX[nI,6]
					oJson['typeProgress']    := aSOX[nI,7]

					If lSMJ 
						oSMJ := PCPA121Emp(aSOX[nI,1], .F.)
						oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
						oJson["insertAllocations"] := oSMJ["insertAllocations"]
						oJson["updateAllocations"] := oSMJ["updateAllocations"]
						oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
					EndIf

					::SetResponse(oJson:toJson())

					If oSMJ != Nil
						FreeObj(oSMJ)
						oSMJ := Nil
					EndIf
				Next nI
				::SetResponse(']') 
			EndIf
			
		EndIf
	EndIf

	aSize(aSOX, 0)

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf

Return lGet

WSMETHOD GET FormUsers WSRECEIVE userCode, startIndex, count, page, onlyHeader, productionOrder WSSERVICE FormRegistration
	Local aHWS    := {}
	Local aSMC    := {}
	Local aSOY    := {}
	Local aSOZ    := {}
	Local lGet    := .T.
	Local lHWS    := AliasInDic("HWS")
	Local lSMC    := AliasInDic("SMC")
	Local lSMJ    := AliasInDic("SMJ")
	Local nIndSOZ := 0
	Local nIndSOY := 0
	Local nIndHWS := 0
	Local oJson   := Nil
	Local oSMJ    := Nil

	// as propriedades da classe receberão os valores enviados por querystring
	// exemplo: http://localhost:8080/sample?startIndex=1&count=10
	DEFAULT ::startIndex := 1, ::count := 20, ::page := 0, ::onlyHeader := 0, ::productionOrder := 0

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		// verifica se recebeu parametro pela URL
		// exemplo: http://localhost:8080/sample/1
		If !Empty(::userCode)
			// exemplo de retorno de uma lista de objetos JSON
			aSOZ:= PCPA121usf(::userCode, ::startIndex, ::count, ::page, ::productionOrder)

			If Len(aSOZ) < 1
				lGet := .F.
				If ::productionOrder == 1
					SetRestFault(400, EncodeUTF8(STR0028)) //Não há formulários de ordem de produção cadastrados para o usuário.
				Else					
					SetRestFault(400, EncodeUTF8(STR0020)) //Não há formulários de apontamento cadastrados para o usuário.
				EndIf
			Else	
				::SetResponse('[')
				For nIndSOZ := 1 To len(aSOZ)
					If nIndSOZ > ::startIndex
						::SetResponse(',')
					EndIf 

					oJson['code'           ] := EncodeUTF8(aSOZ[nIndSOZ,1])
					oJson['description'    ] := trim(EncodeUTF8(aSOZ[nIndSOZ,2]))
					oJson['appointmentType'] := aSOZ[nIndSOZ,3]
					oJson['iconName'       ] := LOWER(trim(aSOZ[nIndSOZ,4]))
					oJson['stopReport'     ] := aSOZ[nIndSOZ,5]
					oJson['useTimer'       ] := aSOZ[nIndSOZ,6]
					oJson['typeProgress'   ] := aSOZ[nIndSOZ,7]

                    If ::onlyHeader == 0
						aSOY:={}
						aSOY:= PCPA121fld(aSOZ[nIndSOZ,1], ::userCode, ::startIndex, ::count, ::page)

						If Len(aSOY) < 1
							lGet := .F.
							If ::productionOrder == 1
								SetRestFault(400, EncodeUTF8(STR0028)) //Não há formulários de ordem de produção cadastrados para o usuário.
							Else					
								SetRestFault(400, EncodeUTF8(STR0020)) //Não há formulários de apontamento cadastrados para o usuário.
							EndIf
						Else	
							oJson['FormFields'] := {}
							For nIndSOY := 1 To Len(aSOY)
								Aadd(oJson['FormFields'], JsonObject():New())
								oJson['FormFields'][nIndSOY]['code'       ] := EncodeUTF8(aSOY[nIndSOY,1])
								oJson['FormFields'][nIndSOY]['field'      ] := trim(aSOY[nIndSOY,2])
								oJson['FormFields'][nIndSOY]['description'] := trim(EncodeUTF8(aSOY[nIndSOY,3]))
								oJson['FormFields'][nIndSOY]['codebar'    ] := aSOY[nIndSOY,4]
								oJson['FormFields'][nIndSOY]['visible'    ] := aSOY[nIndSOY,5]
								oJson['FormFields'][nIndSOY]['editable'   ] := aSOY[nIndSOY,6]
								oJson['FormFields'][nIndSOY]['default'    ] := execPad(trim(aSOY[nIndSOY,7]))
								oJson['FormFields'][nIndSOY]['position'   ] := aSOY[nIndSOY,8]
							Next nIndSOY
						EndIf		
						If lHWS
							aHWS:={}
							aHWS:= PCPA121maq(aSOZ[nIndSOZ,1], ::userCode, ::startIndex, ::count, ::page)
							oJson['FormMachines'] := {}
							If Len(aHWS) >= 1
								For nIndHWS := 1 To len(aHWS)
									Aadd(oJson['FormMachines'], JsonObject():New())
									oJson['FormMachines'][nIndHWS]['code'       ] := EncodeUTF8(aHWS[nIndHWS,1])
									oJson['FormMachines'][nIndHWS]['machine'    ] := trim(aHWS[nIndHWS,2])
									oJson['FormMachines'][nIndHWS]['description'] := trim(EncodeUTF8(aHWS[nIndHWS,3]))
								Next nIndHWS
							EndIf		
						EndIf
						If lSMC
							aSMC := {}
							aSMC := PCPA121cus(aSOZ[nIndSOZ,1], ::userCode, ::startIndex, ::count, ::page, getAlsForm(aSOZ[nIndSOZ,3]))
							oJson['FormCustomField'] := {}
							putCtmFdls(oJson['FormCustomField'], aSMC)

							aSMC := {}
							aSMC := PCPA121cus(aSOZ[nIndSOZ,1], ::userCode, ::startIndex, ::count, ::page, getAlsForm())
							oJson['AllocationCustomField'] := {}
							putCtmFdls(oJson['AllocationCustomField'], aSMC)
						EndIf
						If lSMJ
							oSMJ := PCPA121Emp(aSOZ[nIndSOZ,1], .T.)
							oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
							oJson["insertAllocations"] := oSMJ["insertAllocations"]
							oJson["updateAllocations"] := oSMJ["updateAllocations"]
							oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
							oJson["allocationFields" ] := oSMJ["allocationFields" ]
							If oSMJ != Nil
								FreeObj(oSMJ)
								oSMJ := Nil
							EndIf
						EndIf
					EndIf
					::SetResponse(oJson:toJson())
				Next nIndSOZ
				::SetResponse(']')
			EndIf
		Else
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf
	FwFreeArray(aHWS)
	FwFreeArray(aSMC)
	FwFreeArray(aSOY)
	FwFreeArray(aSOZ)
Return lGet

WSMETHOD GET FormFields WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aSOY  := {}
Local lGet  := .T.
Local nI    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else

	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aSOY:= PCPA121fld(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aSOY) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aSOY)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf
				oJson['code']			:= EncodeUTF8(aSOY[nI,1])
				oJson['field']			:= trim(aSOY[nI,2])
				oJson['description']	:= trim(EncodeUTF8(aSOY[nI,3]))
				oJson['codebar']		:= aSOY[nI,4]
				oJson['visible']		:= aSOY[nI,5]
				oJson['editable']		:= aSOY[nI,6]
				oJson['default']		:= execPad(trim(aSOY[nI,7]))
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

WSMETHOD GET FormConfig WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration
	Local aHWS    := {}
	Local aSMC    := {}
	Local aSOX    := {}
	Local aSOY    := {}
	Local lGet    := .T.
	Local lHWS    := AliasInDic("HWS")
	Local lSMC    := AliasInDic("SMC")
	Local lSMJ    := AliasInDic("SMJ")
	Local nIndSOY := 0
	Local nIndHWS := 0
	Local oJson
	Local oSMJ    := Nil

	// as propriedades da classe receberão os valores enviados por querystring
	// exemplo: http://localhost:8080/sample?startIndex=1&count=10
	DEFAULT ::startIndex := 1, ::count := 40, ::page := 0

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		If !Empty(::codeForm) .And. !Empty(::userCode)
			aSOX := PCPA121Con(::codeForm)

			If Len(aSOX) > 0
				aSOY:= PCPA121fld(::codeForm, ::userCode, ::startIndex, ::count, ::page)

				If Len(aSOY) < 1
					lGet := .F.
					SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
				Else
					oJson['code']            := EncodeUTF8(aSOX[1,1])
					oJson['appointmentType'] := aSOX[1,2]
					oJson['iconName']        := LOWER(trim(aSOX[1,3]))
					oJson['description']     := trim(EncodeUTF8(aSOX[1,4]))
					oJson['stopReport']      := aSOX[1,5]
					oJson['useTimer']        := aSOX[1,6]
					oJson['typeProgress']    := aSOX[1,7]
					oJson['lossFormCode']    := aSOX[1,8]
					oJson['CRPForm']         := aSOX[1,9]
					oJson['RequiresCRPSeq']  := aSOX[1,10]

					oJson['FormFields'] := {}
					
					For nIndSOY := 1 To len(aSOY)
						Aadd(oJson['FormFields'], JsonObject():New())

						oJson['FormFields'][nIndSOY]['code']        := EncodeUTF8(aSOY[nIndSOY,1])
						oJson['FormFields'][nIndSOY]['field']       := trim(aSOY[nIndSOY,2])
						oJson['FormFields'][nIndSOY]['description'] := trim(EncodeUTF8(aSOY[nIndSOY,3]))
						oJson['FormFields'][nIndSOY]['codebar']     := aSOY[nIndSOY,4]
						oJson['FormFields'][nIndSOY]['visible']     := aSOY[nIndSOY,5]
						oJson['FormFields'][nIndSOY]['editable']    := aSOY[nIndSOY,6]
						oJson['FormFields'][nIndSOY]['default']	    := execPad(trim(aSOY[nIndSOY,7]))
						oJson['FormFields'][nIndSOY]['position']    := aSOY[nIndSOY,8]
					Next nIndSOY
					If lHWS
						aHWS:={}
						aHWS:= PCPA121maq(::codeForm, ::userCode, ::startIndex, ::count, ::page, aSOX[1,2])
						oJson['FormMachines'] := {}
						If Len(aHWS) >= 1
							For nIndHWS := 1 To len(aHWS)
								Aadd(oJson['FormMachines'], JsonObject():New())

								oJson['FormMachines'][nIndHWS]['code']        := EncodeUTF8(aHWS[nIndHWS,1])
								oJson['FormMachines'][nIndHWS]['machine']     := trim(aHWS[nIndHWS,2])
								oJson['FormMachines'][nIndHWS]['description'] := trim(EncodeUTF8(aHWS[nIndHWS,3]))
							Next nIndHWS
						EndIf		
					EndIf	
					If lSMC
						aSMC := {}
						aSMC := PCPA121cus(::codeForm, ::userCode, ::startIndex, ::count, ::page, getAlsForm(aSOX[1,2]))
						oJson['FormCustomField'] := {}
						putCtmFdls(oJson['FormCustomField'], aSMC)
						aSMC := {}
						aSMC := PCPA121cus(::codeForm, ::userCode, ::startIndex, ::count, ::page, getAlsForm())
						oJson['AllocationCustomField'] := {}
						putCtmFdls(oJson['AllocationCustomField'], aSMC)
					EndIf
					If lSMJ 
						oSMJ := PCPA121Emp(::codeForm, .T.)
						oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
						oJson["insertAllocations"] := oSMJ["insertAllocations"]
						oJson["updateAllocations"] := oSMJ["updateAllocations"]
						oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
						oJson["allocationFields" ] := oSMJ["allocationFields" ]
					EndIf
					If !Empty(aSOX[1,8])
						aSOXPer := PCPA121Con(aSOX[1,8])
						oJson["lossForm"] := JsonObject():New()
						oJson["lossForm"]["code"]            := EncodeUTF8(aSOXPer[1,1])
						oJson["lossForm"]["description"]     := TRIM(EncodeUTF8(aSOXPer[1,4]))
						oJson["lossForm"]['iconName']        := LOWER(TRIM(aSOXPer[1,3]))

						oJson["lossForm"]["FormFields"]      := {}
						aSOYPer:= PCPA121fld(aSOX[1,8], ::userCode,::startIndex, ::count, ::page)
						For nIndSOY := 1 To len(aSOYPer)
							Aadd(oJson["lossForm"]["FormFields"], JsonObject():New())
							oJson["lossForm"]["FormFields"][nIndSOY]["code"]        := EncodeUTF8(aSOYPer[nIndSOY,1])
							oJson["lossForm"]["FormFields"][nIndSOY]["field"]       := TRIM(aSOYPer[nIndSOY,2])
							oJson["lossForm"]["FormFields"][nIndSOY]["description"] := TRIM(EncodeUTF8(aSOYPer[nIndSOY,3]))
							oJson["lossForm"]["FormFields"][nIndSOY]["codebar"]     := aSOYPer[nIndSOY,4]
							oJson["lossForm"]["FormFields"][nIndSOY]["visible"]     := aSOYPer[nIndSOY,5]
							oJson["lossForm"]["FormFields"][nIndSOY]["editable"]    := aSOYPer[nIndSOY,6]
							oJson["lossForm"]["FormFields"][nIndSOY]["default"]	    := execPad(TRIM(aSOYPer[nIndSOY,7]))
							oJson["lossForm"]["FormFields"][nIndSOY]["position"]    := aSOYPer[nIndSOY,8]
						Next nIndSOY
						aSMCPer := PCPA121cus(aSOX[1,8], ::userCode,::startIndex, ::count, ::page, getAlsForm(aSOXPer[1,2]))
						oJson["lossForm"]['FormCustomField'] := {}
						putCtmFdls(oJson["lossForm"]['FormCustomField'], aSMCPer)
					EndIf					
					::SetResponse(oJson:toJson())
					If oSMJ != Nil
						FreeObj(oSMJ)
						oSMJ := Nil
					EndIf
				EndIf
			Else
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			EndIf
		Else
			If Empty(::codeForm)
				SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
				lGet := .F.
			ElseIf Empty(::userCode)
				SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
				lGet := .F.
			EndIf
		EndIf
	EndIf

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf

	aSize(aHWS, 0)
	aSize(aSMC, 0)
	aSize(aSOY, 0)
	aSize(aSOX, 0)
Return lGet

WSMETHOD GET FormMachines WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aHWS  := {}
Local lGet  := .T.
Local nI    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else

	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aHWS:= PCPA121maq(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aHWS) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aHWS)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf
				oJson['code']  	     := EncodeUTF8(aHWS[nI,1])
				oJson['machine']     := trim(aHWS[nI,2])
				oJson['description'] := trim(EncodeUTF8(aHWS[nI,3]))
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

WSMETHOD GET FormCustomField WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aSMC    := {}
Local cValPad := ""
Local lGet    := .T.
Local nI      := 0
Local nPos    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else
	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aSMC:= PCPA121cus(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aSMC) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aSMC)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf

				oJson['code']  	      := EncodeUTF8(aSMC[nI,1])
				oJson['type']         := trim(aSMC[nI,2])
				oJson['field']		  := trim(aSMC[nI,3])
				oJson['description']  := trim(EncodeUTF8(aSMC[nI,4]))
				oJson['codebar']	  := aSMC[nI,5]
				oJson['visible']	  := aSMC[nI,6]
				oJson['editable']	  := aSMC[nI,7]

				nPos := 0
				If "CustomFieldList" $ trim(aSMC[nI,2])
					oJson['options'] := getOptions(RTrim(aSmc[nI,9]))

					cValPad := execPad(trim(aSMC[nI,8]))
					nPos    := AScan(oJson['options'], {|x| RTrim(x["code"]) == cValPad})
					If(nPos > 0 )
						oJson['default'] := cValPad
					Else
						oJson['default'] := ' '	
					EndIf
				Else
					oJson['default'] := execPad(trim(aSMC[nI,8]))
				EndIf
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

/*/{Protheus.doc} VldDiciona
	Valida se as tabelas SOX, SOY e SOZ estão no dicionário.
	@typVldDiciona

	@author Michelle Ramos
	@since 14/12/2018
	@param Sem parâmetro
	@return True or False

/*/
 Static Function VldDiciona()
	Local lRet := .T.

	if lDicValido == Nil
		If !AliasInDic("SOX") .Or. !AliasInDic("SOY") .Or. !AliasInDic("SOZ")
			lRet := .F.
			lDicValido := .F.
		Else
			lDicValido := .T.
		EndIf
	Else
		lRet := lDicValido
	EndIf

Return lRet

/*/{Protheus.doc} execPad
Avalia código do campo Valor padrão e executa funções que sejam passadas 
no campo ( obrigatório uso de "_" para definir que o valor é função)

@type  Function
@author douglas.Heydt
@since 16/08/2021
@version P12.1.30
@param cValPad  , Caracter, Valor padrão para o campo informado na rotina de formulários
@return cReturn , Caracter, Retorna o valor padrão atualizado.
/*/
Function execPad(cValPad)
	Local cReturn := ""

	IF SUBSTR(cValPad, 0, 1) == "_"
		cFunc := SUBSTR(cValPad, 2, Len(cValPad) )
		IF FindFunction(cFunc)
			cReturn := &cFunc
		ENDIF
	ELSE
		cReturn := cValPad
	ENDIF

return cReturn

/*/{Protheus.doc} getOptions
Retorna as informações da SX5 para determinada tabela

@type  Static Function
@author lucas.franca
@since 14/12/2021
@version P12
@param cTabela, Charactrer, Código da tabela da SX5
@return aOptions, Array, Array com as opções disponíveis
/*/
Static Function getOptions(cTabela)
	Local aOptions  := {}
	Local aDadosSX5 := FWGetSX5(cTabela) 
	Local nIndex    := 0
	Local nTotal    := Len(aDadosSX5)
	
	aOptions := Array(nTotal)

	For nIndex := 1 To nTotal 
		aOptions[nIndex] := JsonObject():New()
		aOptions[nIndex]["code"       ] := EncodeUTF8(RTrim(aDadosSX5[nIndex][3]))
		aOptions[nIndex]["description"] := EncodeUTF8(aOptions[nIndex]["code"] + " - " + RTrim(aDadosSX5[nIndex][4]))
	Next nIndex

	aSize(aDadosSX5, 0)

Return aOptions

/*/{Protheus.doc} putCtmFdls
Adiciona informações dos campos customizados ao objeto json

@type  Static Function
@author renan.roeder
@since 11/11/2022
@version P12.1.2310
@param 01 oJson, Json Object, Objeto json que deverá ser preenchido
@param 02 aSMC , Array      , Array com as informações dos campos customizados para preencher o objeto json
@return Nil
/*/
Static Function putCtmFdls(oJson, aSMC)
	Local cValPad := ""
	Local nPos    := 0
	Local nX      := 0

	If Len(aSMC) >= 1
		For nX := 1 To len(aSMC)
			Aadd(oJson, JsonObject():New())
			oJson[nX]['code'        ] := EncodeUTF8(aSMC[nX,1])
			oJson[nX]['type'        ] := trim(aSMC[nX,2])
			oJson[nX]['field'       ] := trim(aSMC[nX,3])
			oJson[nX]['description' ] := trim(EncodeUTF8(aSMC[nX,4]))
			oJson[nX]['codebar'     ] := aSMC[nX,5]
			oJson[nX]['visible'     ] := aSMC[nX,6]
			oJson[nX]['editable'    ] := aSMC[nX,7]
			oJson[nX]['recordable'  ] := !Empty(GetSX3Cache(trim(aSMC[nX,3]),"X3_CAMPO"))

			nPos := 0
			If "CustomFieldList" $ trim(aSMC[nX,2])
				oJson[nX]['options'] := getOptions(RTrim(aSmc[nX,9]))
				
				cValPad := execPad(trim(aSMC[nX,8]))
				nPos    := AScan(oJson[nX]['options'], {|x| RTrim(x["code"]) == cValPad})
				If(nPos > 0 )
					oJson[nX]['default'] := cValPad
				Else
					oJson[nX]['default'] := ' '	
				EndIf
			Else
				oJson[nX]['default'] := execPad(trim(aSMC[nX,8]))
			EndIf
			oJson[nX]['position'] := aSMC[nX,11]
		Next nX
	EndIf

Return

/*/{Protheus.doc} getAlsForm
Adiciona informações dos campos customizados ao objeto json

@type  Static Function
@author renan.roeder
@since 11/11/2022
@version P12.1.2310
@param 01 oJson, Json Object, Objeto json que deverá ser preenchido
@param 02 aSMC , Array      , Array com as informações dos campos customizados para preencher o objeto json
@return Nil
/*/
Static Function getAlsForm(cApType)
	Local cRet := "D4_"

	Default cApType := "0"

	If cApType == "1" .Or. cApType == "5"
		cRet := "D3_"
	ElseIf cApType == "2" .Or. cApType == "3"
		cRet := "H6_"
	ElseIf cApType == "4"
		cRet := "CYV_"
	ElseIf cApType == "6"
		cRet := "C2_"
	ElseIf cApType == "7"
		cRet := "BC_"
	EndIf	
Return cRet

WSMETHOD POST BarcodeAction WSSERVICE FormRegistration
	Local cBody      := Self:GetContent()
	Local lPEBCodeAc := ExistBlock("PEBCodeAct")
	Local lRet       := .T.
	Local oBody      := JsonObject():New()
	Local oJsonRet   := JsonObject():New()

	Self:SetContentType("application/json")

	If oBody:FromJson(cBody) <> Nil
		SetRestFault(400, EncodeUTF8(STR0029)) //"Requisição com parâmetros inválidos."
		lRet := .F.
	EndIf
	If lRet
		If lPEBCodeAc
			cBody := ExecBlock("PEBCodeAct", .F., .F., cBody)
		EndIf
		If oJsonRet:FromJson(cBody) <> Nil
			SetRestFault(400, EncodeUTF8(STR0030)) //"Retorno da requisição com formato inválido"
			lRet := .F.
		EndIf
		If lRet
			If !lPEBCodeAc
				If oJsonRet:HasProperty("formSource") .And.;
				   oJsonRet["formSource"]:HasProperty("fieldCode") .And.;
				   oJsonRet["formSource"]:HasProperty("barcodeData")
					oJsonRet[oJsonRet["formSource"]["fieldCode"]] := oJsonRet["formSource"]["barcodeData"]
				EndIf
			EndIf
			Self:SetResponse(oJsonRet:ToJson())
		EndIf
	EndIf
	FreeObj(oBody)
	FreeObj(oJsonRet)
Return lRet
