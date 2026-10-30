Function ConsEstOnLine(cCodProd)
/*
Local nCon    := 0
Local cFunc   := "U_HHESTON" 
Local cRetRpc := ""
If !Empty(cCodProd)
	// Faz a Conexao com o Servidor
	nCon := connectserver()

	If nCon != 0
		// Executa a funcao do Protheus
		cRetRpc := rpcprotheus( nCon , cFunc , cCodProd)
		// Diconecta do Servidor
		disconnectserver(nCon)
		MsgAlert("Estoque = " + cRetRpc, HB1->HB1_DESCR)
	Else 
		MsgAlert("Não foi possivel conectar ao servidor", "Conexão")
	EndIf
Else
	MsgAlert("Digite o código do produto", "Produto")
EndIf
*/
Return Nil