#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"

/*/{Protheus.doc} GTPR801

@type function
@author Fernando Radu Muscalu
@since 31/01/2023
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR801()
	
	Local lRet := .T.
	
	FWMsgRun( ,{|| lRet := DocResponsa() },"Realizando a impressão do documento", "Impressão da declaração de responsabilidade") 
	
Return(lRet)

/*/{Protheus.doc} DocResponsa
Funçao para integrar ms word e gerar o documento
de declaração de responsabilidade
@type function
@author Fernando Radu Muscalu
@since 31/01/2023
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DocResponsa()
		
	Local cArqDot		:= GTPGetRules("DECLARADOT",,,"doc_declaracao_conteudo_responsabilidade.dot" )  
	Local cDirArq		:= GTPGetRules("DIRDECLARA",,,"c:\temp\" )  
    Local cFileDot		:= ""
	Local cDataExtenso 	:= ""
	Local cFileTarget	:= ""
	Local cHandle		:= ""

	Local lRet			:= .T.
	Local lSetup
	
	Local oMdlEncom		:= FwLoadModel("GTPA801")	

	Local aFieldSM0 := {"M0_NOMECOM"}
	
	Local aSigamat	:=  FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,aFieldSM0)

	lSetup := Setup(@cFileDot,cDirArq,cArqDot)
	
	If ( lSetup )
	
		oMdlEncom:SetOperation(MODEL_OPERATION_VIEW)
		oMdlEncom:Activate()
			
		BeginMsOle()
		
		cHandle := GTPMSWord()
		
		If ( cHandle == "-1" )
				
			lRet := .f.				
			
		Else
			CpyS2T( cFileDot, cDirArq, .T. )
			
			OLE_SetProperty( cHandle, oleWdVisible, .T. )
			OLE_NewFile(cHandle, cDirArq + cArqDot) //Param cArquivo (2º) deve conter o endereço que o dot está na máquina, por exemplo, C:\arquivos_dot\teste.dotx
			
			OLE_SetDocumentVar(cHandle,    "docVarIdEncomenda",   oMdlEncom:GetModel("MASTERG99"):GetValue("G99_CODIGO") )
			OLE_SetDocumentVar(cHandle,    "docVarEmpresa",   aSigamat[1,2] )
						
			cDataExtenso := Capital(GTPDataExtenso())

			OLE_SetDocumentVar(cHandle, "docVarDataExenso", 		cDataExtenso)

			//Atualizando campos
			OLE_UpdateFields(cHandle)

			Sleep(2000)

			cFileTarget := AllTrim(cDirArq)	
			cFileTarget += Alltrim(oMdlEncom:GetModel("MASTERG99"):GetValue("G99_CODIGO")) + "_"
			cFileTarget	+= Alltrim(FWTimeStamp())
			cFileTarget	+= STRTRAN(Lower(cArqDot),".dot",".doc")
			
			OLE_SaveAsFile( cHandle,cFileTarget ) 
			
			lRet := .t.
			EndMsOle()
	
		EndIf

		oMdlEncom:DeActivate()
			
	Else
		lRet := .F.
	EndIf	
	
	If ( lRet )
		R801MsgSucces(cDirArq)		
	EndIf

Return(lRet) 

/*/{Protheus.doc} Setup
Ajusta os diretórios: 
	diretório do modelo .dot
	diretório para guardar no host
	nome do arquivo do modelo .dot
de declaração de responsabilidade
@type function
@author Fernando Radu Muscalu
@since 31/01/2023
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
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
		MsgStop("O modelo .dot do documento de declaração de responsabilidade não foi localizado no servidor","Modelo não encontrado")
		lRet  := .F.
	Endif

	If !(ExistDir(cDirArq))
		MontaDir(cDirArq)
	EndIf
	
Return(lRet)

/*/{Protheus.doc} R801MsgSucces
função para mostrar a Mensagem 
de declaração de responsabilidade
@type function
@author Fernando Radu Muscalu
@since 31/01/2023
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function R801MsgSucces(cDirArq)
	
	Local cMsg := "Uma cópia do documento Declaração de Responsabilidade "
	
	Default cDirArq := GTPGetRules("DIREXTRET",,,"c:\temp\" )

	cMsg += "foi gerada no diretório (pasta) "
	cMsg += "computador " + Alltrim(Lower(cDirArq)) + ". "
	cMsg += "Verifique!"

	FwAlertSuccess(cMsg,"Documento Impresso")

Return()
