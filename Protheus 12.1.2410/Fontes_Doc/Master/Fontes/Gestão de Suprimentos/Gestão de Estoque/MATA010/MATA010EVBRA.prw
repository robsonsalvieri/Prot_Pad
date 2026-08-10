#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'

/*/{Protheus.doc} MATA010EVBRA
Eventos do MVC para o BRASIL, qualquer regra que se aplique somente para BRASIL
deve ser criada aqui, se for uma regra geral deve estar em MATA010EVDEF.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author joao.pellegrini
@since 19/09/2018
@version P12.1.17
 
/*/

CLASS MATA010EVBRA From FWModelEvent 
	
	DATA lFacFis
	DATA nOpc
	Data cCodProd
	
	METHOD New() CONSTRUCTOR
	Method ModelPosVld(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010EVBRA
	::lFacFis := IIf(FindFunction("FSA172VLD"), FSA172VLD(), .F.)
	::cCodProd := ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do Fiscal antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	joao.pellegrini
@version	12.1.17 / Superior
@since		19/09/2018 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId)  CLASS MATA010EVBRA

Local lValid := .T.

::nOpc := oModel:GetOperation()
::cCodProd := oModel:GetValue("SB1MASTER","B1_COD")

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio do Fiscal depois da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	joao.pellegrini
@version	12.1.17 / Superior
@since		19/08/2018
/*/
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS MATA010EVBRA

// Não acionar o facilitador de dentro do FISA170 pois se o produto estiver sendo cadastrado pela
// consulta padrão ele já será vinculado ao perfil.
If ::lFacFis .And. ::nOpc == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
	FSA172FAC({"PRODUTO", ::cCodProd})
EndIf

Return Nil