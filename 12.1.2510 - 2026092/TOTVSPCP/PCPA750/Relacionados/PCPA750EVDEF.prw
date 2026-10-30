#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA750.CH"

STATIC lPrincipal := .T.

/*/{Protheus.doc} PCPA750EVDEF
Eventos padrão da Manutenção do Plano Mestre de Produção
@author Carlos Alexandre da Silveira
@since 23/07/2018
@version 1
/*/
CLASS PCPA750EVDEF FROM FWModelEvent

	DATA aModelLote

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS()
	
EndClass

/*/{Protheus.doc} New
Método construtor
@author Carlos Alexandre da Silveira
@since 23/07/2018
@version 1
/*/
METHOD New() CLASS PCPA750EVDEF
	::aModelLote := {}
Return

/*/{Protheus.doc} ModelPosVld
Método de Pós-validação do modelo de dados.
@author Carlos Alexandre da Silveira
@since 23/07/2018

@param oModel	- Modelo de dados a ser validado
@param cModelId	- ID do modelo de dados que será validado.
@return lRet	- Indicador se o modelo é válido.
/*/
METHOD ModelPosVld(oModel,cModelId) CLASS PCPA750EVDEF
	Local lRet   	 	:= .T.
	Local lRetPE        := .T.
	Local nOpc   	 	:= oModel:GetOperation()
	Local cProduto 	 	:= oModel:GetModel("SHCMASTER"):GetValue("HC_PRODUTO")
	Local nQuant     	:= oModel:GetModel("SHCMASTER"):GetValue("HC_QUANT")
	Local cOpc       	:= oModel:GetModel("SHCMASTER"):GetValue("HC_OPC")
	Local dData      	:= oModel:GetModel("SHCMASTER"):GetValue("HC_DATA")
	Local cMopc			:= oModel:GetModel("SHCMASTER"):GetValue("HC_MOPC")
	Local cOp 			:= oModel:GetModel("SHCMASTER"):GetValue("HC_OP")
	Local nX			:= 0
	Local nY			:= 0
	Local nPosMdl       := 0
	Local aNec 			:= {}
	Local aAux			:= {}
	
	If lRet .And. nOpc <> 5
		lRet := SeleOpc(1,"PCPA750",cProduto,,,Iif(Empty(cMopc),cOpc,cMopc),"M->HC_OPC",,nQuant,dData)
	EndIf

	If lRet .And. nOpc <> 5
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		If SB1->B1_MSBLQL == '1'
			HELP(" ",1,"REGBLOQ")
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !Empty(cOp) .And. nOpc == 5
		Help(,,'Help',,STR0021,1,0)	//STR0021 - PMP já executado. Exclusão não permitida.
		lRet := .F.
	EndIf

	// Executa Ponto de Entrada antes da alteração
	If lRet .And. nOpc == 4
		If ExistBlock('A750ALT')
			lRet := Execblock('A750ALT',.F.,.F.)
			If ValType(lRet) <> "L"
				lRet := .F.
			Endif
		EndIf
	Endif

	// Executa Ponto de Entrada antes da exclusão
	IF lRet .And. nOpc == MODEL_OPERATION_DELETE
		If ExistBlock('A750EXCL')
			lRetPE := Execblock('A750EXCL',.F.,.F.)
			If ValType(lRetPE) <> "L"
			   lRetPE := .F.
			Endif
			lRet := lRetPE
		EndIf
	EndIf	
	
	If lRet .And. nOpc == MODEL_OPERATION_INSERT .And. MV_PAR01 == 2 .And. lPrincipal
		lPrincipal := .F.
		aNec := CalcLote(cProduto,nQuant,If(SG1->(DbSeek(xFilial("SG1")+cProduto)),"F","C"))
		If !Empty(aNec)
			oModel:LoadValue("SHCMASTER","HC_QUANT",aNec[1])
			
			aAux := oModel:GetModel("SHCMASTER"):GetStruct():GetFields()			
			
			For nX:= 2 to Len(aNec)
				aAdd(::aModelLote,FwLoadModel("PCPA750"))
				
				nPosMdl := Len(::aModelLote)
				
				::aModelLote[nPosMdl]:SetOperation(MODEL_OPERATION_INSERT)
				::aModelLote[nPosMdl]:Activate()
				
				::aModelLote[nPosMdl]:LoadValue("SHCMASTER","HC_QUANT",aNec[nX])
				For nY := 1 To Len(aAux)
					If (aAux[nY,3] <> "HC_QUANT")
						If !(::aModelLote[nPosMdl]:LoadValue("SHCMASTER",aAux[nY,3],oModel:GetValue("SHCMASTER",aAux[nY,3])))
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nY
				If !lRet
					Exit
				EndIf
				lRet := ::aModelLote[nPosMdl]:VldData()
				If !lRet
					Exit
				EndIf
			Next nX
			lPrincipal := .T.
		EndIf
		
		If lRet == .F.
			For nX := 1 To Len(::aModelLote)
				If ::aModelLote[nX] <> Nil 
					If ::aModelLote[nX]:IsActive()
						::aModelLote[nX]:DeActivate()
					EndIf
					::aModelLote[nX]:Destroy()
				EndIf
			Next nX
			aSize(::aModelLote,0)
			FWModelActive(oModel)
		EndIf
		
	EndIf
Return lRet

/*/{Protheus.doc} InTTS
Método para commit dos dados (após gravação do modelo, antes do fim da transação)
@author lucas.franca
@since 26/07/2018

@param oModel	- Modelo de dados a ser validado
@param cModelId	- ID do modelo de dados que será validado.
@return lRet	- Indicador se o modelo é válido.
/*/
METHOD InTTS(oModel,cModelId) CLASS PCPA750EVDEF
	Local nX := 0
	
	For nX := 1 To Len(::aModelLote)
		::aModelLote[nX]:CommitData()
		::aModelLote[nX]:DeActivate()
		::aModelLote[nX]:Destroy()
	Next nX
	aSize(::aModelLote,0)
	FWModelActive(oModel)

Return