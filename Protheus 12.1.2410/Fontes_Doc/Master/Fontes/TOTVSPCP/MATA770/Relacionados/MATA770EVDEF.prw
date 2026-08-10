#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA770.CH"

/*/{Protheus.doc} MATA770EVDEF
Eventos padrão do cadastro de centro de trabalho.
@author    lucas.franca
@since     18/06/2018
@version   1
/*/
CLASS MATA770EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS()
EndClass

/*/{Protheus.doc} New
Método construtor
@author    lucas.franca
@since     18/06/2018
@version   1
/*/
METHOD New() CLASS MATA770EVDEF
Return

/*/{Protheus.doc} ModelPosVld
Método de Pós-validação do modelo de dados.
@author lucas.franca
@since 18/06/2018

@param oModel	- Modelo de dados a ser validado
@param cModelId	- ID do modelo de dados que será validado.

@return lRet	- Indicador se o modelo é válido.
/*/
METHOD ModelPosVld(oModel,cModelId) CLASS MATA770EVDEF
	Local lRet    := .T.
	Local nOpc    := oModel:GetOperation()
	
	If nOpc == MODEL_OPERATION_DELETE
		dbSelectArea("SG2")
		SG2->(dbSetOrder(5))
		If SG2->(dbSeek(xFilial()+oModel:GetValue("SHBMASTER","HB_COD")))
			Help(" ",1,"A770DELCT")
			lRet := .F.		
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} InTTS
Método executado após as gravações do modelo, e antes do commit.

@author lucas.franca
@since 19/06/2018
@version 1.0
@param oModel	- Modelo de dados que está sendo gravado
@param cModelId	- ID do modelo de dados que está sendo gravado

@return lRet	- Indicador se a gravação ocorreu corretamente.
/*/
METHOD InTTS(oModel, cModelId) CLASS MATA770EVDEF
	Local lRet    := .T.
	Local lIntSFC := ExisteSFC("SHB") .And. !IsInCallStack("AUTO770")// Determina se existe integracao com o SFC
	Local lIntDPR := IntegraDPR() .And. !IsInCallStack("AUTO770")// Determina se existe integracao com o DPR
	
	//Chama rotina para integracao com SFC(Chao de Fabrica)
	If lIntSFC .Or. lIntDPR
		lRet := A770IntSFC(oModel:GetOperation(),,,,oModel)	
	EndIf
Return lRet

/*/{Protheus.doc} A770IntSFC
Realiza integração com o módulo chão de fábriga (SIGASFC)
@author lucas.franca
@since 18/06/2018
@version 1.0

@param nOpc		- Operação que está sendo realizada (3-Inclusão;4-Alteração;5-Exclusão)
@param cError	- Variável passada por referência, para retornar mensagens de erro caso existam.
@param cNome	- Nome para geração de log de erro caso ocorra.
@param oModel	- Modelo de dados utilizado na integração.

@return lRet	- Indica se a integração foi realizada com sucesso.
/*/
Function A770IntSFC(nOpc,cError,cNome,oModel,oModelSHB)
	Local aArea   := GetArea()	// Salva area atual para posterior restauracao
	Local lRet    := .T.		// Conteudo de retorno
	Local aCampos := {}			// Array dos campos a serem atualizados pelo modelo
	Local nX      := 0			// Indexadora de laco For/Next
	Local aAux    := {}			// Array auxiliar com o conteudo dos campos
	
	Default oModel := FWLoadModel("SFCA001")
	
	If oModelSHB == NIL
		oModelSHB := FWLoadModel("MATA770")
		oModelSHB:SetOperation(MODEL_OPERATION_VIEW)
		oModelSHB:Activate()
	EndIf
	
	If nOpc < 5
		//Monta array com dados do Centro de Trabalho para atualizacao no SFC
		If nOpc == 3
			aAdd(aCampos,{"CYI_CDCETR", oModelSHB:GetValue("SHBMASTER","HB_COD")})
		EndIf
		aAdd(aCampos,{"CYI_DSCETR"	,oModelSHB:GetValue("SHBMASTER","HB_NOME")})
		aAdd(aCampos,{"CYI_CDCECS"	,oModelSHB:GetValue("SHBMASTER","HB_CC")})
		aAdd(aCampos,{"CYI_HRUTDY"	,oModelSHB:GetValue("SHBMASTER","HB_HRUT")})
	EndIf
	
	oModel:SetOperation(nOpc)
	
	If nOpc # 3
		//Quando se tratar de alteracao ou exclusao primeiramente o registro devera ser posicionado
		CYI->(dbSetOrder(1))
		CYI->(dbSeek(xFilial("CYI")+oModelSHB:GetValue("SHBMASTER","HB_COD")))
	EndIf
			
	//Ativa o modelo de dados
	If (lRet := oModel:Activate())
		//Obtem a estrutura de dados do Model
		aAux := oModel:GetModel("CYIMASTER"):GetStruct():GetFields()
		
		//Loop para validacao e atribuicao de dados dos campos do Model
		For nX := 1 To Len(aCampos)
			//Valida os campos existentes na estrutura do Model
			If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCampos[nX,1])}) > 0
				//Atribui os valores aos campos do Model caso passem pela validacao do formulario 
				//referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.   
				If !(oModel:SetValue("CYIMASTER",aCampos[nX,1],aCampos[nX,2]))
					lRet := .F.
					Exit       
				EndIf
			EndIf
		Next nX
	EndIf
	
	If lRet
		//Valida os dados e integridade conforme dicionario do Model
		If (lRet := oModel:VldData())
			//Efetiva gravacao dos dados na tabela
			lRet := oModel:CommitData()
		EndIf
	EndIf

	//Gera log de erro caso nao tenha passado pela validacao
	If !lRet
		A010SFCErr(oModel,@cError,NIL,cNome,oModelSHB:GetValue("SHBMASTER","HB_COD"))
	EndIf
	
	//Desativa o Model
	oModel:DeActivate()
	
	RestArea(aArea)
Return(lRet)
