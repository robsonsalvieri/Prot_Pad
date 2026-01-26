#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1127.CH"

Function LOJA1127()
Return NIL
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros para Consulta de Saldos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct ConsProd
	WSData NConsProd as Array of Produto
EndWSStruct

WSStruct Produto
	WSData EmpCons		as String
	WSData FilCons		as String
	WSData Codigo		as String
	WSData Descri		as String
	WSData Armazem		as String
	WSData Item			as Float
EndWSStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno da Consulta de Saldos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct RetSaldos
	WSData NRetSaldos as Array of Saldo
EndWSStruct

WSStruct Saldo
	WSData EmpCons		as String
	WSData FilCons		as String
	WSData Armazem		as String
	WSData Codigo		as String
	WSData Unidade		as String
	WSData Grupo		as String
	WSData Descri		as String
	WSData Inicial		as Float
	WSData Atual		as Float
	WSData Preco1		as Float
	WSData Preco2		as Float
	WSData Preco3		as Float
	WSData Preco4		as Float
	WSData Preco5		as Float
	WSData Preco6		as Float
	WSData Preco7		as Float
	WSData Preco8		as Float
	WSData Preco9		as Float
	WSData Item			as Float
EndWSStruct
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros para Reserva de Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct ResProd
	WSData NResProd as Array Of ItResProd
EndWSStruct

WSStruct ItResProd
	WSData EmpRes		as String
	WSData FilRes		as String
	WSData CodProd		as String
	WSData Armazem		as String
	WSData Lote			as String
	WSData Sublote		as String
	WSData Endereco		as String
	WSData NumSerie		as String
	WSData DtValid		as String
	WSData CodCli		as String
	WSData LojCli		as String
	WSData KeyCli		as String
	WSData ItVenda		as String
	WSData TpVenda		as String
	WSData QtdeRes		as Float
	WSData Quebra		as String
EndWSStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno da Reserva de Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct RetRes
	WSData NRetRes as Array Of ItRetRes
EndWSStruct

WSStruct ItRetRes
	WSData Item		as String
	WSData FilRes	as String
	WSData Reserva	as String
	WSData Orcam	as String
	WSData Pedido	as String	OPTIONAL
EndWSStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros para Consulta de Reservas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct ConsRes
	WSData NConsRes as Array of ItConsRes
EndWSStruct

WSStruct ItConsRes
	WSData FilCons as String
EndWSStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno da Consulta de Reservas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct RetCRes
		WSData NRetCRes as Array Of ItRetCRes
EndWSStruct

WSStruct ItRetCRes
	WSData FilCons	as String
	WSData Produto	as String
	WSData QuantRes	as Float
	WSData CodRes	as String
	WSData DataRes	as String
	WSData DataVal	as String
	WSData Armazem	as String
	WSData Observ	as String
EndWSStruct	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros para o Cancelamento das Reservas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct CancRes
	WSData NCancRes as Array Of ItCancRes
EndWSStruct

WSStruct ItCancRes
	WSData Reserva	as String
	WSData LojaRes	as String
	WSData Produto	as String
	WSData Armazem	as String
	WSData FilCanc	as String
	WSData SubLote	as String
	WSData NumLote	as String
	WSData Endereco	as String
	WSData NumSerie as String
EndWSStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno do Cancelamento das Reservas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSStruct RetCanc
	WSData NRetCanc as Array Of ItRetCanc
EndWSStruct

WSStruct ItRetCanc
	WSData Cancela as Boolean
	WSData Reserva as String
EndWSStruct

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWSService ³LJWEstoqueºAutor  ³ Vendas Clientes    º Data ³  20/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Web Service de Consulta de Estoques e Manutencao de        º±±
±±º          ³ Reservas.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSService LJWEstoque				DESCRIPTION	STR0001	//"Consultas de Estoque e Reservas"
	WSData		aConsProd	as ConsProd					//Array com os parametros para Consulta de Saldos
	WSData		aRetSaldos	as RetSaldos				//Array com os resultados da Consulta de Saldos
	WSData		aResProd	as ResProd					//Array com os parametros para Reserva de Saldos
	WSData		aRetRes		as RetRes					//Array com os resultados da Reserva de Saldos
	WSData		aConsRes	as ConsRes					//Array com os parametros para Consulta de Reservas
	WSData		aRetCRes	as RetCRes					//Array com os resultados da Consulta de Reservas
	WSData		KeyCli		as String					//CNPJ ou CPF do Cliente para Consulta de Reservas
	WSData		aCancRes	as CancRes					//Array com os parametros para o Cancelamento de Reservas
	WSData		aRetCanc	as RetCanc					//Array com os resultados do Cancelamento de Reservas

	WSMethod	ConsEst				DESCRIPTION 		STR0002			//"Consulta Saldos de Produtos"
	WSMethod	ResProd				DESCRIPTION 		STR0003			//"Reserva de Produtos"
	WSMethod	ConsRes				DESCRIPTION 		STR0004			//"Consulta Reservas de Produtos"
	WSMethod	CancRes				DESCRIPTION 		STR0005			//"Cancelamento de Reserva de Produtos"
EndWSService

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Metodo   ³ ConsEst  ºAutor  ³ Vendas Clientes    º Data ³  24/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a Consulta dos Saldos em Estoque.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod ConsEst WSReceive aConsProd WSSend aRetSaldos WSService LJWEstoque
	Local aConsulta	:= {}							//Array utilizado para a Consulta de Estoque
	Local nCons		:= Len(aConsProd:NConsProd)		//Quantidade de Produtos a Consultar
    Local nI		:= 0							//Contador
	Local nItem		:= 0							//Item da Consulta de Origem
	Local nQuant	:= 0							//Contador
	Local lRetorno	:= .T.							//Retorno do Metodo
	Local lLocal	:= .F.							//Determina se e consulta Local
	Local lReserva	:= .F.							//Determina se esta utilizando a tela de Reservas
    Local oEstoque	:= NIL							//Objeto para Consulta de Estoque

    For nI := 1 to nCons
		nItem := aConsProd:NConsProd[nI]:Item

		//Para a Consulta de Estoque a Quantidade sempre e igual a Zero
		//Nao recupera as informacoes de Lote
		aConsulta := {{	aConsProd:NConsProd[nI]:Codigo		,;	//Produto
						aConsProd:NConsProd[nI]:Armazem		,;	//Armazem
						0									,;	//Quantidade Reserva
						AllTrim(Str(nItem))					,;	//Item da Consulta
						aConsProd:NConsProd[nI]:Descri		,;	//Descricao do Produto
						""									,;	//Lote
						""									,;	//SubLote
						""									,;	//Endereco
						""									,;	//Numero Serie
						""									,;	//Tipo de Reserva
						""									}}	//Quebra

		//Instancia a Classe LJCEstoque
		oEstoque 	:= LJCEstoque():New(lLocal, lReserva)
		
		//Prepara a Filial da Consulta de Estoque
		If oEstoque:SetFilial(aConsProd:NConsProd[nI]:FilCons)

			//Inicializa o Array de Produtos
			oEstoque:SetProd(aConsulta)
			
			//Inicializa o Array de Lojas
			oEstoque:SetLoja()
			
			//Relaciona os Produtos x Lojas
			oEstoque:SetConsult()
			
			//Efetua a Consulta de Estoque
			oEstoque:ConsEst()
			
			//Restaura a Filial Original
			oEstoque:RestFil()
			
			//Trata o Retorno
			If !Empty(oEstoque:aSaldos)
	
				//Dimensiona o Array de Retorno
				Aadd(aRetSaldos:NRetSaldos, WSClassNew("Saldo"))
				
				nQuant++
	
				::aRetSaldos:NRetSaldos[nQuant]:EmpCons		:= oEstoque:aSaldos[1][01]
				::aRetSaldos:NRetSaldos[nQuant]:FilCons		:= oEstoque:aSaldos[1][02]
				::aRetSaldos:NRetSaldos[nQuant]:Codigo		:= oEstoque:aSaldos[1][03]
				::aRetSaldos:NRetSaldos[nQuant]:Unidade		:= oEstoque:aSaldos[1][04]
				::aRetSaldos:NRetSaldos[nQuant]:Grupo		:= oEstoque:aSaldos[1][05]
				::aRetSaldos:NRetSaldos[nQuant]:Descri		:= oEstoque:aSaldos[1][06]
				::aRetSaldos:NRetSaldos[nQuant]:Armazem		:= oEstoque:aSaldos[1][07]
				::aRetSaldos:NRetSaldos[nQuant]:Inicial		:= oEstoque:aSaldos[1][08]
				::aRetSaldos:NRetSaldos[nQuant]:Atual		:= oEstoque:aSaldos[1][09]
				::aRetSaldos:NRetSaldos[nQuant]:Preco1		:= oEstoque:aSaldos[1][10]
				::aRetSaldos:NRetSaldos[nQuant]:Preco2		:= oEstoque:aSaldos[1][11]
				::aRetSaldos:NRetSaldos[nQuant]:Preco3		:= oEstoque:aSaldos[1][12]
				::aRetSaldos:NRetSaldos[nQuant]:Preco4		:= oEstoque:aSaldos[1][13]
				::aRetSaldos:NRetSaldos[nQuant]:Preco5		:= oEstoque:aSaldos[1][14]
				::aRetSaldos:NRetSaldos[nQuant]:Preco6		:= oEstoque:aSaldos[1][15]
				::aRetSaldos:NRetSaldos[nQuant]:Preco7		:= oEstoque:aSaldos[1][16]
				::aRetSaldos:NRetSaldos[nQuant]:Preco8		:= oEstoque:aSaldos[1][17]
				::aRetSaldos:NRetSaldos[nQuant]:Preco9		:= oEstoque:aSaldos[1][18]
				::aRetSaldos:NRetSaldos[nQuant]:Item		:= nItem
			EndIf
		EndIf
	Next nI

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Metodo   ³ ResProd  ºAutor  ³ Vendas Clientes    º Data ³  02/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a Reserva dos produtos em Outras Filiais.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod ResProd WSReceive aResProd WSSend aRetRes WSService LJWEstoque
	Local aInfCli		:= {}			//Informacoes do Cliente
	Local aLote			:= {}			//Informacoes do Lote do Produto
	Local aReserva		:= {}			//Produtos para Reserva
	Local aResult		:= {}			//Resultado da Reserva
	Local cNumRes		:= ""			//Numero da Reserva
	Local cPedido		:= ""			//Numero do Pedido de Venda
	Local cOrcam		:= ""			//Numero do Orcamento
	Local nI			:= 0			//Contador
	Local nSldAtu		:= 0			//Saldo Atual
	Local nPosOrc		:= 0			//Verifica se o item ja tem um Orcamento ou Pedido de Venda Associado
	Local lLocal		:= .F.			//Determina que esta consultando via Web Service
	Local lPedido		:= .F.			//Determina se e Pedido de Venda
	Local lReserva		:= .T.			//Determina se esta fazendo Reserva
	Local lRetorno		:= .F.			//Retorno do Metodo
	Local oEstoque		:= NIL			//Objeto de Consultas / Reservas

	For nI := 1 to Len(aResProd:nResProd)
	
		//Instancia o Objeto
		oEstoque	:= LJCEstoque():New(lLocal, lReserva)
		
		aInfCli := {	aResProd:nResProd[nI]:CodCli,;
						aResProd:nResProd[nI]:LojCli,;
						aResProd:nResProd[nI]:KeyCli}

		//Passa os Dados do Cliente
		If oEstoque:SetCliente(aInfCli)
		
			//Prepara Filial
			If oEstoque:SetFilial(aResProd:nResProd[nI]:FilRes)

				//Recupera o Saldo atual do Produto
				nSldAtu		:= oEstoque:GetSldAtu(	aResProd:nResProd[nI]:CodProd,;
													aResProd:nResProd[nI]:Armazem)
				//Array com os Dados da Reserva
				aReserva	:= {}
				
				Aadd(aReserva,{	Val(aResProd:nResProd[nI]:ItVenda)	,;			//01 - Item do Produto no aCols
								aResProd:nResProd[nI]:CodProd		,;			//02 - Codigo do Produto
								aResProd:nResProd[nI]:QtdeRes		,;			//03 - Quantidade
								{	aResProd:nResProd[nI]:Armazem	,;			//04 - Local
									nSldAtu	}						,;			//05 - Quantidade em Estoque
								aResProd:nResProd[nI]:Armazem		})			//06 - Armazem

				//Dados do Lote do Produto
				aLote	:= {	aResProd:nResProd[nI]:Lote			,;			//01 - Lote
								aResProd:nResProd[nI]:SubLote		,;			//02 - SubLote
								aResProd:nResProd[nI]:Endereco		,;			//03 - Endereco
								aResProd:nResProd[nI]:NumSerie		}			//04 - Numero Serie

				//Faz a reserva
				cNumRes	:= oEstoque:GrvResProd(	aReserva								,;	//01 - Array para Rotina de Reserva
				 								CtoD(aResProd:nResProd[nI]:DtValid)		,;	//02 - Data da Validade da Reserva
				 								aResProd:nResProd[nI]:FilRes			,;	//03 - Filial para Reserva
				 								aLote									)	//04 - Variaveis de Controle de Lote

				If !Empty(cNumRes)                
					//Limpa o Numero do Pedido
					cPedido	:= ""

					//Verifica se este item ja tem um Orcamento ou Pedido de Venda Associado
					nPosOrc := Ascan(aResult, {|x| x[2] + x[3] + x[7] == aResProd:nResProd[nI]:FilRes + aResProd:nResProd[nI]:TpVenda + aResProd:nResProd[nI]:Quebra})

					lPedido := aResProd:nResProd[nI]:TpVenda == "3"

					If nPosOrc > 0
						cOrcam	:= aResult[nPosOrc][05]
						If lPedido
							cPedido := aResult[nPosOrc][06]
						EndIf
					Else
					    cOrcam := oEstoque:GetOrcam()
						If lPedido
							cPedido := oEstoque:GetPedido()
						EndIf
					EndIf

					//Adiciona aos resultados
					Aadd(aResult, {	aResProd:nResProd[nI]:ItVenda	,;		//01 - Item da Venda
									aResProd:nResProd[nI]:FilRes	,;		//02 - Filial da Reserva
									aResProd:nResProd[nI]:TpVenda	,;		//03 - Tipo da Venda
									cNumRes							,;		//04 - Numero da Reserva
									cOrcam							,;		//05 - Numero do Orcamento
									cPedido							,;		//06 - Numero do Pedido
									aResProd:nResProd[nI]:Quebra	})		//07 - Quebra para geracao de Orcamentos Filho / Pedidos
				EndIf
				oEstoque:RestFil()
			EndIf
		EndIf
	Next nI
	
	For nI := 1 to Len(aResult)
		Aadd(aRetRes:NRetRes, WSClassNew("ItRetRes"))

		aRetRes:nRetRes[nI]:Item		:= aResult[nI][01]		//Item da Venda
		aRetRes:nRetRes[nI]:FilRes		:= aResult[nI][02]		//Filial da Reserva
		aRetRes:nRetRes[nI]:Reserva		:= aResult[nI][04]		//Numero da Reserva
		aRetRes:nRetRes[nI]:Orcam		:= aResult[nI][05]		//Numero do Orcamento
		aRetRes:nRetRes[nI]:Pedido		:= aResult[nI][06]		//Numero do Pedido
	Next nI

	lRetorno := Len(aResult) > 0

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Metodo   ³ ConsRes  ºAutor  ³ Vendas Clientes    º Data ³  22/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a Consulta das Reservas de Produtos em Outras       º±±
±±º          ³ Filiais.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod ConsRes WSReceive aConsRes, KeyCli WSSend aRetCRes WSService LJWEstoque
	Local aInfCli	:= {}								//Informacoes do Cliente
	Local cKeyCli	:= ::KeyCli							//Chave de Pesquisa do Cliente
	Local lRetorno	:= .F.								//Retorno da Funcao
	Local nI 		:= 0								//Contador
	Local nJ		:= 0								//Contador
	Local oDCliente := NIL								//Dados da Entidade Cliente
 	Local oECliente	:= LJCEntCliente():New()			//Entidade Cliente
	Local oEstoque	:= NIL								//Instancia o Objeto
			
	oECliente:DadosSet("A1_CGC", cKeyCli)
	oDCliente := oECliente:Consultar(3)		//Filial + CNPJ ou CPF
	
	If oDCliente:Count() > 0

		aInfCli := {	oDCliente:Elements(1):DadosGet("A1_COD")	,;		//Codigo do Cliente
						oDCliente:Elements(1):DadosGet("A1_LOJA")	,;		//Loja do Cliente
						cKeyCli										}		//CPF ou CNPJ do Cliente
	
		For nI := 1 to Len(aConsRes:NConsRes)
			//Instancia o Objeto para Consulta de Estoque
			oEstoque := LJCEstoque():New(.F., .F.)
			If oEstoque:SetCliente(aInfCli)
				If oEstoque:SetLoja()
					If oEstoque:SetFilial(::aConsRes:NConsRes[nI]:FilCons)
						If oEstoque:ConsRes()
							lRetorno := .T.
							For nJ := 1 to Len(oEstoque:aConsRes)
								Aadd(::aRetCRes:NRetCRes, WSClassNew("ItRetCRes"))
	
								::aRetCRes:NRetCRes[nJ]:FilCons		:= oEstoque:aConsRes[nJ][02]
								::aRetCRes:NRetCRes[nJ]:Produto		:= oEstoque:aConsRes[nJ][03]
								::aRetCRes:NRetCRes[nJ]:QuantRes	:= oEstoque:aConsRes[nJ][04]
								::aRetCRes:NRetCRes[nJ]:CodRes		:= oEstoque:aConsRes[nJ][05]
								::aRetCRes:NRetCRes[nJ]:DataRes		:= DtoS(oEstoque:aConsRes[nJ][06])
								::aRetCRes:NRetCRes[nJ]:DataVal		:= DtoS(oEstoque:aConsRes[nJ][07])
								::aRetCRes:NRetCRes[nJ]:Armazem		:= oEstoque:aConsRes[nJ][08]
								::aRetCRes:NRetCRes[nJ]:Observ		:= oEstoque:aConsRes[nJ][09]
							Next nJ
						EndIf
						oEstoque:RestFil()
					EndIf
				EndIf
			EndIf
		Next nI
    EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Metodo   ³ CancRes  ºAutor  ³ Vendas Clientes    º Data ³  22/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o Cancelamento das Reservas de Produtos em Outras   º±±
±±º          ³ Filiais.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMethod CancRes WSReceive aCancRes, KeyCli WSSend aRetCanc WSService LJWEstoque
	Local aInfCli	:= {}								//Informacoes do Cliente
	Local aRetorno	:= {}								//Retorno do Cancelamento
	Local lRetorno	:= .F.								//Retorno do Web Service
	Local nI 		:= 0								//Contador
	Local nJ		:= 0								//Contador
	Local nWRetorno	:= 1								//Contador
	Local oDCliente := NIL								//Dados da Entidade Cliente
 	Local oECliente	:= LJCEntCliente():New()			//Entidade Cliente
	Local oEstoque	:= NIL								//Instancia o Objeto

	oECliente:DadosSet("A1_CGC", ::KeyCli)
	oDCliente := oECliente:Consultar(3)		//Filial + CNPJ ou CPF

	//Verifica se o Cliente esta cadastrado neste Ambiente
	If oDCliente:Count() > 0

		//Guarda os dados do Cliente
		aInfCli := {	oDCliente:Elements(1):DadosGet("A1_COD")	,;		//Codigo do Cliente
						oDCliente:Elements(1):DadosGet("A1_LOJA")	,;		//Loja do Cliente
						::KeyCli									}		//CPF ou CNPJ do Cliente

		//Percorre os Itens para Cancelamento
		For nI := 1 to Len(aCancRes:NCancRes)
		
			//Inicializa o Objeto para o Cancelamento da Reserva
			oEstoque := LJCEstoque():New(.F., .T., .T.)
			
			//Prepara a Filial de Trabalho
			If oEstoque:SetFilial(aCancRes:NCancRes[nI]:FilCanc)
				//Prepara as Lojas Cadastradas para Reserva
				If oEstoque:SetLoja()
					//Atribui os dados do Cliente
					If oEstoque:SetCliente(aInfCli)
						//Prepara o Array para o Cancelamento da Reserva
						aReservas := {}
						Aadd(aReservas, {	aCancRes:NCancRes[nI]:Produto		,;		// 01 - Codigo Produto
											aCancRes:NCancRes[nI]:Armazem		,;		// 02 - Armazem
											0									,;		// 03 - Qtde. (Nao Utilizado)
											""									,;		// 04 - Item da Venda
											""									,;		// 05 - Descr. (Nao Utilizado)
											aCancRes:NCancRes[nI]:NumLote		,;		// 06 - Lote
											aCancRes:NCancRes[nI]:SubLote		,;		// 07 - Sub Lote
											aCancRes:NCancRes[nI]:Endereco	,;		// 08 - Endereco
											aCancRes:NCancRes[nI]:NumSerie	,;		// 09 - Numero Serie
											.F.									,;		// 10 - Gera Pedido
											""									,;		// 11 - Chave para Quebra
											aCancRes:NCancRes[nI]:Reserva		,;		// 12 - Codigo da reserva
											aCancRes:NCancRes[nI]:LojaRes		})		// 13 - Codigo da loja

						//Atribui os dados do Produto para Reserva
						If oEstoque:SetProd(aReservas)
							//Faz o Cancelamento da Reserva
							aRetorno := oEstoque:CancRes()
							
							//Trata os dados do Retorno do Cancelamento
							For nJ := 1 to Len(aRetorno)
								Aadd(aRetCanc:NRetCanc, WSClassNew("ItRetCanc"))

								aRetCanc:NRetCanc[nWRetorno]:Reserva		:= aRetorno[nJ][01]
								aRetCanc:NRetCanc[nWRetorno]:Cancela		:= aRetorno[nJ][02]
								
								nWRetorno++
							Next nJ
						EndIf
					EndIf
				EndIf
				//Restaura a Filial
				oEstoque:RestFil()
		    EndIf
        Next nI
    EndIf
	//Verifica se foi feito algum Cancelamento
	If nWRetorno > 1
		lRetorno := .T.
	EndIf
Return lRetorno
