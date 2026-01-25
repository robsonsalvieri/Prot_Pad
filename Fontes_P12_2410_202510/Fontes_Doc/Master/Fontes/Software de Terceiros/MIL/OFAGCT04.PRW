#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} OFAGCT04



	T E M P O R A R I O   N A O   D E V E   S U B I R   N A   T O T V S



	Criado para acelerar o envio dos dados para a AGCO, não utilizado pelo cliente diretamente
	Ele cria threads de execução que enviam massivamente dados a agco, usado normalmente na 
	geração da carga inicial

	@type  Function
	@author Vinicius Gati
	@since 30/01/2018
	@version 12
	/*/
Function OFAGCT04

Return .T.