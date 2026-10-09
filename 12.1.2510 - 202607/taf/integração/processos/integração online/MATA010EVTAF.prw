#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'
#include 'MATA010EVTAF.ch'

/*/{Protheus.doc} MATA010EVTAF
Eventos padrão do Produto, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Rotina :Criada para executar Inclusão, Alteração e Exclusão de produtos dentro do TAF, 
         através da integração entre os módulos. Lembrando que para que a mesma funcione 
         o parâmetro MV_INTTAF deve estar preenchido com "S" 
Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Graziella Souza
@since 12/03/2018
@version P12.1.17
 
/*/
CLASS MATA010EVTAF FROM FWModelEvent

	DATA lIntTAF
	DATA nOpc
	DATA cCodProduto
	DATA cCodGrupo
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS()
	
ENDCLASS


//-----------------------------------------------------------------
METHOD New() CLASS MATA010EVTAF

::lIntTAF		:= TAFExstInt()

Return

METHOD InTTS(oModel, cID) CLASS MATA010EVTAF

Local lRet 	:= .T.
Local cError 	:= ""
::nOpc 		:= oModel:getOperation()
::cCodProduto := oModel:GetValue("SB1MASTER", "B1_COD")
::nOpc 		:= oModel:getOperation()
	
If ::lIntTAF	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		MsgRun( STR0002, STR0001, {|| TAFIntOnLn("T007",::nOpc,cFilAnt) } ) // "Aguarde enquanto a Atualização e/ou Inclusão esta sendo realizada."
	Endif
	
	If ::nOpc == MODEL_OPERATION_DELETE
		MsgRun( STR0002, STR0001, {|| TAFExcPrd("T007",::nOpc,cFilAnt,::cCodProduto) } ) // "Aguarde enquanto a Exclusão esta sendo realizada."
	Endif
Endif 

Return lRet



METHOD ModelPosVld(oModel) CLASS MATA010EVTAF
Local lRet := .T.

	::nOpc := oModel:getOperation()
	
	/*If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE	
		If ::l010TOkT
			lRet:= ExecTemplate("A010TOK",.F.,.F.)
			If ValType(lRet) # "L"
				lRet :=.T.
			EndIf
		EndIf
	EndIf*/
		
Return lRet