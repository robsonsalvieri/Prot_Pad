#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"

Static oR753Tab 		:= Nil

Static cR753HandWord	:= ""

/*/{Protheus.doc} GTPR113A

@type function
@author henrique.toyada 
@since 13/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR753(cProcExtravio,cMoveProc,lFinished)
	
	Local lRet := .T.
	
	Default lFinished := .F.

	FWMsgRun( ,{|| lRet := GerDocExtravio(cProcExtravio,cMoveProc,lFinished) },"Realizando a impressão do documento", OemToAnsi("Gerando Documento de Retirada " + AllTrim(cProcExtravio+"/"+cMoveProc)) ) 
	
Return(lRet)

/*/{Protheus.doc} GerDocAutor

@type function
@author henrique.toyada 
@since 13/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GerDocExtravio(cProcExtravio,cMoveProc,lFinished)
	
	Local cArqDot		:= GTPGetRules("EXTRETDOT",,,"doc_retirada_bagaem.dot" )  
	Local cDirArq		:= GTPGetRules("DIREXTRET",,,"c:\temp\" ) 
	Local cFileDot		:= ""
	Local cTextRG		:= ""
	Local cNumRG		:= ""
	Local cDataExtenso 	:= ""
	Local cDocVarValue	:= "R$ 0,00"
	Local cDocVarExtVl	:= "(zero real)"
	Local cFileTarget	:= ""
	
	Local nValor		:= 0
	
	Local lRet			:= .T.
	Local lSetup        := .T.
	Local lReOpen		:= .F.

	Local aArea	    	:= GetArea()
	Local oModelProc	:= FwLoadModel("GTPA752")
	Local aFieldSM0 := { ;
							"M0_CODIGO",;    //Posição [1]
							"M0_CODFIL",;    //Posição [2]
							"M0_NOMECOM",;   //Posição [3]
							"M0_CGC",;       //Posição [4]
							"M0_INSCM",;     //Posição [5]
							"M0_CIDENT",;    //Posição [6]
							"M0_ESTENT",;    //Posição [7]
							"M0_ENDENT",;    //Posição [8]
							"M0_BAIRENT",;   //Posição [9]
							"M0_CEPENT",;    //Posição [10]
							"M0_COMPENT",;   //Posição [11]
							"M0_TEL";        //Posição [12]
						}
	
	Local aSM0			:=  FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,aFieldSM0)

	lSetup := Setup(@cFileDot,cDirArq,cArqDot)

	If ( lSetup )

		oModelProc:SetOperation(MODEL_OPERATION_UPDATE)

		H6F->(DbSetOrder(1))
		
		If H6F->(DbSeek(xfilial("H6F") + cProcExtravio))
			
			oModelProc:Activate()
			
			BeginMsOle()
			
			If ( !FwIsInCallStack("GTP753RETIRA") )
				
				OLE_CloseFile( cR753HandWord )
				OLE_CloseLink( cR753HandWord )
				
				cR753HandWord := ""
			
			EndIf

			//Cria um ponteiro e já chama o arquivo
			If (  Empty(cR753HandWord) .Or. Val(cR753HandWord) < 0 )
				cR753HandWord := OLE_CreateLink()			
			Else
				lReOpen := .t.
			EndIf	
			
			If ( cR753HandWord != "-1" )
			
				CpyS2T( cFileDot, cDirArq, .T. )
				
				OLE_SetProperty( cR753HandWord, oleWdVisible, .T. )

				If ( lReOpen )
					OLE_OpenFile(cR753HandWord,cDirArq + cArqDot,.t.)	//,"SENHAXXX","SENHAWWW")
				Else
					OLE_NewFile(cR753HandWord, cDirArq + cArqDot) //Param cArquivo (2º) deve conter o endereço que o dot está na máquina, por exemplo, C:\arquivos_dot\teste.dotx
				EndIf
				//Setando o conteúdo das DocVariables
				
				OLE_SetDocumentVar(cR753HandWord, "docvarProcesso", cProcExtravio)
				OLE_SetDocumentVar(cR753HandWord, "docvarMove", 	cMoveProc)
				OLE_SetDocumentVar(cR753HandWord, "docvarNomeEmp", 	Alltrim(aSM0[3,2]))
				OLE_SetDocumentVar(cR753HandWord, "docvarEndEmp", 	Alltrim(aSM0[8,2]))
				OLE_SetDocumentVar(cR753HandWord, "docvarMunEmp", 	Alltrim(aSM0[6,2]))
				OLE_SetDocumentVar(cR753HandWord, "docvarEstEmp", 	Alltrim(aSM0[7,2]))
				OLE_SetDocumentVar(cR753HandWord, "docvarCepEmp", 	Alltrim(aSM0[10,2]))
				OLE_SetDocumentVar(cR753HandWord, "docvarTelEmp", 	Alltrim(aSM0[12,2]))//1=Pendente;2=Baixado
				
				OLE_SetDocumentVar(cR753HandWord, "docvarNomePassageiro",	H6F->H6F_NOMEPS)
				
				cNumRG := GTPPictRG(H6F->H6F_RGPASS)

				If ( !Empty(cNumRG) )
					cTextRG := "portador do RG " + cNumRG
				Else
					cNumRG := "não informado."
					cTextRG := ""
				EndIf

				OLE_SetDocumentVar(cR753HandWord, "docvarRGPassageiro", 	cNumRG)
				OLE_SetDocumentVar(cR753HandWord, "docvarRGText", 			cTextRG)			
				OLE_SetDocumentVar(cR753HandWord, "docvarEndereco", 		H6F->H6F_ENDPAS)
				OLE_SetDocumentVar(cR753HandWord, "docvarComplEnd", 		H6F->H6F_CPENPS)
				OLE_SetDocumentVar(cR753HandWord, "docvarCEP", 				H6F->H6F_CEPPAS)
				OLE_SetDocumentVar(cR753HandWord, "docvarEmailPassageiro", 	Lower(H6F->H6F_EMAIL))
				OLE_SetDocumentVar(cR753HandWord, "docvarTelPassageiro", 	H6F->H6F_TELEFO)			
				
				nValor := GetTotal(oModelProc:GetModel("H6FMASTER"))

				If ( nValor > 0 )
					cDocVarValue := "R$ " + Alltrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))
					cDocVarExtVl := "("+ Alltrim(Extenso(nValor)) +")"
				EndIf

				OLE_SetDocumentVar(cR753HandWord, "docvarValor", 			cDocVarValue)
				OLE_SetDocumentVar(cR753HandWord, "docvarValorExtenso", 	cDocVarExtVl)
				
				cDataExtenso := Capital(GTPDataExtenso())

				OLE_SetDocumentVar(cR753HandWord, "docvarDataExtenso", 		cDataExtenso)

				//Atualizando campos
				OLE_UpdateFields(cR753HandWord)

				Sleep(2000)

				cFileTarget := AllTrim(cDirArq)	
				cFileTarget += Alltrim(cProcExtravio)
				cFileTarget += Alltrim(cMoveProc)
				cFileTarget	+= Alltrim(FWTimeStamp())
				cFileTarget	+= STRTRAN(Lower(cArqDot),".dot",".doc")
				
				OLE_SaveAsFile(cR753HandWord,cFileTarget) 

				lRet := .t.
				EndMsOle()

			EndIf

		EndIf
	Else

		lRet := .F.

	EndIf
	RestArea(aArea)

	If ( lRet .And. lFinished )
		R753MsgSucces(cDirArq)		
	EndIf

Return(lRet) 


Static Function Setup(cFileDot,cDirArq,cArqDot)

	Local lRet  := .T.

	Local cPath	:= Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\WORD\" ) )

	If SubStr(cPath,-1) <> "\"
		cPath += "\" 
	Endif

	cFileDot := AllTrim(cPath + cArqDot) 

	If !(ExistDir( cPath ))
		nRet := MakeDir( cPath )
	EndIf

	// Verifica a existencia do DOT no ROOTPATH Protheus / Servidor
	If !File(cFileDot)
		MsgStop("O modelo .dot do documento de retirada não foi localizado no servidor","Modelo não encontrado")
		lRet  := .F.
	Endif

	If !(ExistDir(cDirArq))
		MontaDir(cDirArq)
	EndIf

Return lRet

Static Function GetTotal(oSubTotal)

	// Local oModel := oSubTotal:GetModel()

	Local nValor := oSubTotal:GetValue("H6F_VALOR")

	If ( nValor == 0 )
		nValor := FromQueryTotal(oSubTotal:GetValue("H6F_CODIGO"))
	EndIf

Return(nValor)

Static Function FromQueryTotal(cProcesso)

	Local nValor	:= 0
	
	Local cQuery	:= ""

	Local aFldConv	:= {{"TOTAL","N",16,2}}

	cQuery += "SELECT "
	cQuery += "	SUM(H6G_QUANTI*H6G_VALOR) TOTAL "
	cQuery += "FROM "
	cQuery += "	" + RetSQLName("H6G") + " H6G "
	cQuery += "WHERE "
	cQuery += "	H6G.H6G_FILIAL = '" + xFilial("H6G") + "' "
	cQuery += "	AND H6G.D_E_L_E_T_ = ' ' "
	cQuery += "	AND H6G_CODIGO = '" + cProcesso + "' "
	//Enquanto não atualizar o dicionário com o pacote
	//atualizado com o campo H6F_STATUS. Issue: DSERGTP-8024
	If ( H6G->(FieldPos("H6G_STATUS")) > 0  )
		cQuery += "	AND H6G_STATUS in (' ','1') " //('0=Em Analise', '1=Encontrado', '2=Reembolsado', '3=Recusado)
	EndIf

	GTPNewTempTable(cQuery,,,aFldConv,@oR753Tab)

	nValor := (oR753Tab:GetAlias())->(TOTAL)

Return(nValor)

Function R753MsgSucces(cDirArq)
	
	Local cMsg := "O(s) documento(s) de retirada de bagagem(ns) "
	
	Default cDirArq := GTPGetRules("DIREXTRET",,,"c:\temp\" )

	cMsg += "foi(ram) gerado(s) no diretório (pasta) "
	cMsg += "computador " + Alltrim(Lower(cDirArq)) + ". "
	cMsg += "Verifique!"

	FwAlertSuccess(cMsg,"Documento de Retirada Impresso")

Return()


Function R753CloseWord()
	
	If ( FwIsInCallStack("GTP753RETIRA") )

		If ( !Empty(cR753HandWord)  )

			OLE_CloseFile( cR753HandWord )
			OLE_CloseLink( cR753HandWord )		
			
			cR753HandWord := ""

		EndIf
		
	EndIf

Return()
