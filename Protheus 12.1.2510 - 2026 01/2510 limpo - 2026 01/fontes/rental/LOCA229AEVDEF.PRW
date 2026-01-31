#INCLUDE 'TOTVS.CH'


//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA229AEVDEF
Eventos padrão do cadastro da capa do romaneio, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type Class
 
@author Alexandre Circenis
@since 26/05/2025
@version 25.10
 
/*/
//---------------------------------------------------------------------------------------------------------------------
CLASS LOCA229AEVDEF From FWModelEvent

	METHOD New() CONSTRUCTOR

	METHOD AFTERTTS()	//Após o Commit do Model

ENDCLASS
//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe LOCA229AEVDEF

@type Method

@author Alexandre Circenis
@since 26/05/2025
@version 25.10
 
/*/
//---------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS LOCA229AEVDEF

Return Self

//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC após o termino da transação do commit do model
@author Alexandre Circenis
@type method
@since 09/06/2025
@version 25.10
/*/
//---------------------------------------------------------------------------------------------------------------------
Method AfterTTS(oModel, cModelId) Class LOCA229AEVDEF

	Loca229AEV(oModel) // Processar as mensagem de eventos na gravação

Return 
