#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"

Static oR756DTab := Nil

Static cR756DHandWord   := ""

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
Function GTPR756D(cProcConserto,lFinished)
	
	Local lRet := .T.
	
	Default lShowAlert := .T.
	Default lFinished := .F.
	
	FWMsgRun( ,{|| lRet := GerDocExtravio(cProcConserto,lFinished) },"Realizando a impressão do documento", OemToAnsi("Gerando Documento de Retirada " + AllTrim(cProcConserto)) ) 
	
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
Static Function GerDocExtravio(cProcConserto,lFinished)
		
	Local cArqDot	:= GTPGetRules("CONRETDOT",,,"doc_retirada_conserto.dot" )  
	Local cDirArq	:= GTPGetRules("DIRCONRET",,,"c:\temp\" )  
    Local cFileDot		:= ""
	Local cTextRG		:= ""
	Local cNumRG		:= ""
	Local cDataExtenso 	:= ""
	Local cDocVarValue	:= "R$ 0,00"
	Local cDocVarExtVl	:= "(zero real)"
	Local cFileTarget	:= ""
	
	Local nValor		:= 0
	
	Local lRet			:= .T.
	Local lSetup
	Local lReOpen		:= .F.

	Local aArea	    	:= GetArea()
	Local oMdlConserto	:= FwLoadModel("GTPA756")
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
	
		oMdlConserto:SetOperation(MODEL_OPERATION_UPDATE)
		
		H6K->(DbSetOrder(1))
		
		If H6K->(DbSeek(xfilial("H6K") + cProcConserto))
			
			oMdlConserto:Activate()
			
	        BeginMsOle()
		
	        If (  Empty(cR756DHandWord) .Or. Val(cR756DHandWord) < 0 )
	            cR756DHandWord := OLE_CreateLink()			
	        Else
	            lReOpen := .t.
	        EndIf
			
			If ( cR756DHandWord == "-1" )
					
				lRet := .f.				
				
			Else
				CpyS2T( cFileDot, cDirArq, .T. )
				
				OLE_SetProperty( cR756DHandWord, oleWdVisible, .T. )
				
				If ( lReOpen )
	                OLE_OpenFile(cR756DHandWord,cDirArq + cArqDot,.t.)	//,"SENHAXXX","SENHAWWW")
	            Else
	                OLE_NewFile(cR756DHandWord, cDirArq + cArqDot) //Param cArquivo (2º) deve conter o endereço que o dot está na máquina, por exemplo, C:\arquivos_dot\teste.dotx
	            EndIf
				
				//Setando o conteúdo das DocVariables
				
				OLE_SetDocumentVar(cR756DHandWord,    "docvarProcesso",   cProcConserto)
				OLE_SetDocumentVar(cR756DHandWord,   "docvarNomeEmp", 	Alltrim(aSM0[3,2]))
	            OLE_SetDocumentVar(cR756DHandWord,   "docvarEndEmp", 	Alltrim(aSM0[8,2]))
	            OLE_SetDocumentVar(cR756DHandWord,   "docvarMunEmp", 	Alltrim(aSM0[6,2]))
	            OLE_SetDocumentVar(cR756DHandWord,   "docvarEstEmp", 	Alltrim(aSM0[7,2]))
	            OLE_SetDocumentVar(cR756DHandWord,   "docvarCepEmp", 	Alltrim(aSM0[10,2]))
	            OLE_SetDocumentVar(cR756DHandWord,   "docvarTelEmp", 	Alltrim(aSM0[12,2]))
				
				OLE_SetDocumentVar(cR756DHandWord, "docvarNomePassageiro",H6K->H6K_NOMEPS)
				
				cNumRG := GTPPictRG(H6K->H6K_RGPASS)
	
				If ( !Empty(cNumRG) )
					cTextRG := "portador do RG " + cNumRG
				Else
					cNumRG := "não informado."
					cTextRG := ""
				EndIf
	
				OLE_SetDocumentVar(cR756DHandWord, "docvarRGPassageiro", 	cNumRG)
				OLE_SetDocumentVar(cR756DHandWord, "docvarRGText", 			cTextRG)			
				OLE_SetDocumentVar(cR756DHandWord, "docvarEndereco", 		H6K->H6K_ENDPAS)
				OLE_SetDocumentVar(cR756DHandWord, "docvarComplEnd", 		H6K->H6K_CPENPS)
				OLE_SetDocumentVar(cR756DHandWord, "docvarCEP", 			H6K->H6K_CEPPAS)
				OLE_SetDocumentVar(cR756DHandWord, "docvarEmailPassageiro", Lower(H6K->H6K_EMAIL))
				OLE_SetDocumentVar(cR756DHandWord, "docvarTelPassageiro", 	H6K->H6K_TELEFO)			
				
				nValor := H6K->H6K_VLRDOC
	
				If ( nValor > 0 )
					cDocVarValue := "R$ " + Alltrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))
					cDocVarExtVl := "("+ Alltrim(Extenso(nValor)) +")"
				EndIf
	
				OLE_SetDocumentVar(cR756DHandWord, "docvarValor", 			cDocVarValue)
				OLE_SetDocumentVar(cR756DHandWord, "docvarValorExtenso", 	cDocVarExtVl)
				
				cDataExtenso := Capital(GTPDataExtenso())
	
				OLE_SetDocumentVar(cR756DHandWord, "docvarDataExtenso", 		cDataExtenso)
	
				//Atualizando campos
				OLE_UpdateFields(cR756DHandWord)
	
				Sleep(2000)
	
				cFileTarget := AllTrim(cDirArq)	
				cFileTarget += Alltrim(cProcConserto) + "_"
				cFileTarget	+= Alltrim(FWTimeStamp())
				cFileTarget	+= STRTRAN(Lower(cArqDot),".dot",".doc")
				
				OLE_SaveAsFile( cR756DHandWord,cFileTarget ) 
				
				lRet := .t.
	            EndMsOle()
		
			EndIf
	
			oMdlConserto:DeActivate()
	
		Else
			
			lRet := .F.
	
		EndIf
	Else
		lRet := .F.
	EndIf	
	RestArea(aArea)

	If ( lRet .And. lFinished )
		R756DMsgSucces(cDirArq)		
	EndIf

Return(lRet) 


Static Function Setup(cFileDot,cDirArq,cArqDot)

	Local lRet	:= .T.
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
	
Return(lRet)


Function R756DMsgSucces(cDirArq)
	
	Local cMsg := "O(s) documento(s) de conserto de mala(s) "
	
	Default cDirArq := GTPGetRules("DIREXTRET",,,"c:\temp\" )

	cMsg += "foi(ram) gerado(s) no diretório (pasta) "
	cMsg += "computador " + Alltrim(Lower(cDirArq)) + ". "
	cMsg += "Verifique!"

	FwAlertSuccess(cMsg,"Documento de Retirada Impresso")

Return()


Function R756DCloseWord()
	
	If ( FwIsInCallStack("A756RDOCPRT") )

	    If ( !Empty(cR756DHandWord)  )
	
	        OLE_CloseFile( cR756DHandWord )
	        OLE_CloseLink( cR756DHandWord )		
	        
	        cR756DHandWord := ""
	
	    EndIf
	
	EndIf	
	

Return()
