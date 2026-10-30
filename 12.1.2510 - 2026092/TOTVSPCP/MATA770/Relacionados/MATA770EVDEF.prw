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

	// A integração com o Chão de Fábrica foi protegida e migrada para a classe PCPA770 - Smart X

Return totvs.manufatura.centrodetrabalho.events.PCPA770():integracaoComChaoDeFabrica(nOpc,cError,cNome,oModel,oModelSHB)
