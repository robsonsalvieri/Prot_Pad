#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'

/*/{Protheus.doc} MATA019EVBRA
Eventos do MVC para o BRASIL, qualquer regra que se aplique somente para BRASIL
deve ser criada aqui, se for uma regra geral deve estar em MATA019EVBRA.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Matheus Bispo
@since 13/11/2025
@version P12.1.2510
 
/*/

CLASS MATA019EVBRA From FWModelEvent 
	
	METHOD New() CONSTRUCTOR
	METHOD AfterTTS(oModel, cModelId)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA019EVBRA
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio do Fiscal depois da transação do modelo de dados.
@type 		Método
@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.
@author 	Matheus Bispo
@version	12.1.2510
@since		13/11/2025
/*/
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS MATA019EVBRA

	if findFunction("f166ProfOp")
		f166ProfOp(oModel:GetOperation(), oModel:GetValue("SB1MASTER","B1_COD")) // Otimizador do Perfil de Produtos
	endIf

Return Nil
