#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1129.CH"

Function LOJA1129()
Return NIL
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณLJCEstoqueบAutor  ณVendas Clientes     บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Responsavel pelas consultas de Estoques e Reservas na      บฑฑ
ฑฑบ          ณ Venda Assistida.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCEstoque
	Data aAreaSM0		//Guarda a Posicao Inicial do Arquivo de Empresas
	Data aConsulta		//Filiais x Produtos para Consulta / Reserva
	Data aConsRes		//Resultado da Consulta de Reservas
	Data aLojas			//Filiais para Reserva / Consulta de Estoque
	Data aInfCli		//Dados do Cliente
	Data aProdutos		//Produtos para Consulta
	Data aSaldos		//Resultado da Consulta de Saldos
	Data aReserva		//Itens para Reserva
	Data cFilBkp		//Guarda a Filial Atual
    Data cLjAmbie		//Codigo do Ambiente Atual na Venda Off Line
	Data cURL			//URL para conexao
	Data lConsWeb		//Determina se deve realizar a Consulta em Outras Filias via Web Service
	Data lLocal			//Determina se e Consulta Local ou via Web Service
	Data lLjOffLn		//Determina se a Venda Off Line esta habilitada
    Data lLjMatOf		//Determina se o Ambiente Atual e Matriz na Venda Off Line
	Data lReserva		//Determina se a rotina foi chamada a partir da rotina de Reserva
	Data lCancela		//Determina se e Cancelamento de Reserva
	
	Method New(lLocal, lReserva)
	Method SetFilial(cFilTrb)
	Method SetCliente(aInfCli)
	Method GetURL()
	Method SetConsWeb()
	Method SetProd(aProdCons)
	Method GetProdInf(cProduto)		
	Method SetLoja()
	Method GetDescLj(cLoja) 
	Method SelProdLoj()
	Method SetConsult()
	Method ConsEst()
	Method GetSldAtu(cProduto, cLocal)
	Method GetSldIni(cProduto, cLocal)
	Method GetPrvs(cProduto)
	Method ShowEst()
	Method VldChkRes(nItSld)
	Method ResProd()
	Method GrvResProd(aReserva, dDataVal, cFilRes, aLote)
	Method RetReserva()
	Method GetCliente()
	Method ConsRes()
	Method ShowRes()
	Method CancRes()
	Method RestFil()
	Method GetOrcam()
	Method GetPedido()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ New      บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Instancia a Classe e executa os metodos de Consulta e      บฑฑ
ฑฑบ          ณ Reserva.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(lLocal, lReserva, lCancela) Class LJCEstoque
	Default lLocal		:= .T.						//Determina se e Consulta Local ou via Web Service
	Default lReserva	:= .F.						//Define se foi chamado da Rotina de Reserva
	Default lCancela	:= .F.						//Define se e Cancelamento de Reservas

	::cLjAmbie			:= SuperGetMV("MV_LJAMBIE", NIL, "")
	::lConsWeb			:= .F.
	::lLocal			:= lLocal
	::lLjOffLn			:= SuperGetMV("MV_LJOFFLN", NIL, .F.)
	::lLjMatOf			:= SuperGetMV("MV_LJMATOF", NIL, .F.)
	::lReserva			:= lReserva
	::lCancela			:= lCancela
	::aConsulta			:= {}
	::aLojas			:= {}
	::aProdutos			:= {}
	::aSaldos			:= {}

	::cURL				:= ::GetURL()

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณSetFilial บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara a Filial de Trabalho.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetFilial(cFilTrb) Class LJCEstoque
	Local lRetorno	:= .T.				//Retorno do Metodo

	::cFilBkp 	:= cFilAnt
	::aAreaSM0	:= SM0->(GetArea())

	//Posiciona na Filial de Trabalho
	DbSelectArea("SM0")
	DbSetOrder(1)
	If DbSeek(cEmpAnt + cFilTrb)
		cFilAnt		:= cFilTrb
	Else
		::RestFil()
		lRetorno	:= .F.
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณSetClienteบAutor  ณ Vendas Clientes    บ Data ณ  31/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Guarda o Cliente na variavel aInfCli.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetCliente(aInfCli) Class LJCEstoque
	Local lRetorno	:= .T.							//Retorno do Metodo
	Local oECliente	:= NIL							//Entidade Cliente
	Local oDCliente	:= NIL							//Dados da Entidade Cliente

	::aInfCli		:= AClone(aInfCli)				//Dados do Cliente
	
	If ::lReserva
		If Empty(::aInfCli)
			lRetorno := .F.
		Else
			If ::lLjOffLn
				If ::lLocal
					If Empty(::aInfCli[3])
						MsgAlert(STR0001)		//"Nใo sera possivel Efetuar ou Cancelar Reservas, pois o CPF ou CNPJ do cliente deve ser cadastrado."
						::RestFil()
						lRetorno := .F.
					EndIf
				Else
					oECliente	:= LJCEntCliente():New()
					oECliente:DadosSet("A1_CGC", aInfCli[3])
					oDCliente := oECliente:Consultar(3)		//A1_FILIAL + A1_CGC
					If !(oDCliente:Count() > 0)
						lRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndIf
    EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณGetClienteบAutor  ณ Vendas Clientes    บ Data ณ  28/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Array com os Dados do Cliente.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCliente() Class LJCEstoque
Return ::aInfCli

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ GetURL   บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Determina se e Consulta Web Service e retorna a URL de     บฑฑ
ฑฑบ          ณ Conexao quando for Venda Off Line.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetURL() Class LJCEstoque
	Local cURL			:= ""						//URL para Conexao
	Local cIP			:= ""						//IP para Conexao
	Local cPorta		:= ""						//Porta para Conexao
	Local oEWebServ		:= NIL						//Entidade Web Services
	Local oDWebServ		:= NIL						//Dados da Entidade Web Services

	If ::lLjOffLn
		If ::lLocal
			::SetConsWeb()
			If ::lConsWeb
				oEWebServ := LJCEntWebServices():New()
				oEWebServ:DadosSet("MD3_CODAMB"	, ::cLjAmbie)
				oEWebServ:DadosSEt("MD3_TIPO"	, "E")
				
				oDWebServ := oEWebServ:Consultar(1)		//MD3_FILIAL, MD3_CODAMB, MD3_TIPO
				
				//Verifica se tem Web Service Cadastrado para este Ambiente
				If oDWebServ:Count() > 0
					//So recupera o primeiro registro, pois apenas permite
					// o cadastramento de um Web Service de cada Tipo por Ambiente
					cIP		:= AllTrim(oDWebServ:Elements(1):DadosGet("MD3_IP"))
					cPorta	:= AllTrim(oDWebServ:Elements(1):DadosGet("MD3_PORTA"))
				Else
					ConOut(STR0002)		//"Nao existe um Web Service de Consulta configurado para este Ambiente."
				EndIf

				If !Empty(cIP) .AND. !Empty(cPorta)
					cURL	:= "http://" + cIP + ":"
					cURL	+= cPorta + "/LJWEstoque.APW"
				EndIf
			EndIf
		EndIf
	EndIf

Return cURL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณSetConsWebบAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se e consulta Web.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetConsWeb() Class LJCEstoque
	//Se for Cancelamento guarda a URL
	If ::lCancela
		::lConsWeb	:= .T.
	Else
		::lConsWeb	:= MsgYesNo(STR0003)		//"Deseja consultar em Outros Ambientes?"
	EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ SetProd  บAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atribui os Dados dos Produtos                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetProd(aProdCons) Class LJCEstoque
	Local aInfProd		:= {}		//Informacoes do Produto
	Local cUM			:= ""		//Unidade de Medida
	Local cGrupo		:= ""		//Grupo
	Local cReserva		:= ""		//Numero Reserva
	Local cFilRes		:= ""		//Filial Reserva
	Local nI			:= 0		//Contador
	Local lRetorno		:= .T.		//Retorno da Funcao

	Default aProdCons	:= {}		//Produtos a Consultar

	If !Empty(aProdCons)
		For nI := 1 to Len(aProdCons)

			aInfProd	:= ::GetProdInf(aProdCons[nI][1])

			If !Empty(aInfProd)
				cUM		:= aInfProd[1]
				cGrupo	:= aInfProd[2]
			EndIf

			If ::lCancela
				cReserva	:= aProdCons[nI][12]
				cFilRes		:= aProdCons[nI][13]
			Else
				cReserva	:= ""
				cFilRes		:= ""
			EndIf

			Aadd(::aProdutos, {	.T.						,;			//01 - Determina se realiza a Consulta / Reserva
								aProdCons[nI][01]		,;			//02 - Codigo do Produto
								aProdCons[nI][02]		,;			//03 - Armazem
								aProdCons[nI][03]		,;			//04 - Quantidade quando for Reserva
								cUM						,;			//05 - Unidade de Medida
								cGrupo					,;			//06 - Grupo
								aProdCons[nI][05]		,;			//07 - Descricao
								aProdCons[nI][04]		,;			//08 - Item da Venda
								aProdCons[nI][06]		,;			//09 - Lote
								aProdCons[nI][07]		,;			//10 - Sub Lote
								aProdCons[nI][08]		,;			//11 - Endereco
								aProdCons[nI][09]		,;			//12 - Numero de Serie
								cReserva				,;			//13 - Numero da Reserva
								cFilRes					,;			//14 - Filial da Reserva
								aProdCons[nI][10]		,;			//15 - Gera Pedido de Venda
								""                      ,;			//16 - Numero Orcam. Reserva
								""						,;			//17 - Numero Ped. Venda Reserva
								aProdCons[nI][11]		})			//18 - Chave para quebra na geracao do Orcamento Filho / Pedido de Venda
		Next nI
	Else
		lRetorno := .F.
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณGetProdInfบAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recupera as Informacoes genericas do Produto.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetProdInf(cProduto) Class LJCEstoque
	Local oEProd		:= NIL						//Objeto LJCEntProduto
	Local oDProd		:= NIL						//Dados da Entidade Produto
	Local aRetorno		:= {}						//Retorno do Metodo

	//Recupera as informacoes do Produto
	oEProd	:= LJCEntProduto():New()
	oEProd:DadosSet("B1_COD", cProduto)
	oDProd	:= oEProd:Consultar(1)	//B1_FILIAL, B1_COD
	If oDProd:Count() > 0
		Aadd(aRetorno, oDProd:Elements(1):DadosGet("B1_UM"))
		Aadd(aRetorno, oDProd:Elements(1):DadosGet("B1_GRUPO"))
		Aadd(aRetorno, oDProd:Elements(1):DadosGet("B1_DESC"))
	EndIf
Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ SetLoja  บAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona as Filiais para Consulta / Reserva.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetLoja() Class LJCEstoque
	Local nI			:= 0			//Contador
	Local nLojas		:= 0			//Resultado da Consulta
	Local lRetorno		:= .T.			//Retorno do Metodo
	Local oEIdentLj 	:= NIL			//Entidade Identificacao de Lojas
	Local oDIdentLj		:= NIL			//Dados da Entidade Identificacao de Lojas
	Local cCodLoj 		:= ""			//Codigo da Loja
	Local cNomLoj		:= ""			//Nome da Loja
	Local cRpcFil 		:= ""			//Codigo da Filial
	Local cLjRes		:= ""			//Determina se pode reservar nesta Loja
	Local dDataRes		:= dDataBase	//Data para Reserva
	
	If ::lLocal .OR. ::lCancela
		oEIdentLj 	:= LJCEntIdentLoja():New()

		oEIdentLj:DadosSet("LJ_RPCEMP", cEmpAnt)
		
		If !::lConsWeb
			oEIdentLj:DadosSet("LJ_RPCFIL", cFilAnt)
		EndIf

		oDIdentLj	:= oEIdentLj:Consultar(3)

		nLojas := oDIdentLj:Count()
	EndIf

	If nLojas > 0
		For nI := 1 to nLojas
			cCodLoj 	:= oDIdentLj:Elements(nI):DadosGet("LJ_CODIGO")
			cNomLoj		:= oDIdentLj:Elements(nI):DadosGet("LJ_NOME")
			cRpcFil 	:= oDIdentLj:Elements(nI):DadosGet("LJ_RPCFIL")
			cLjRes		:= oDIdentLj:Elements(nI):DadosGet("LJ_RESERVA")
			dDataRes	:= dDataBase + oDIdentLj:Elements(nI):DadosGet("LJ_DIASRES")

			If cRpcFil == cFilAnt
				lWebServ := .F.
			Else
				lWebServ := ::lConsWeb
			EndIf
			
			If cLjRes == "1"
				Aadd(::aLojas,{	.T.			,;		//01 - Selecionada
								cCodLoj		,;		//02 - Codigo Loja
								cNomLoj		,;		//03 - Nome Loja
								cEmpAnt		,;		//04 - Empresa
								cRpcFil		,;		//05 - Filial
								lWebServ	,;		//06 - Determina se a consulta e via Web Service
								dDataRes	})		//07 - Data da Validade da Reserva
			EndIf
		Next nI
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciona somente a Loja atual, se for Consulta Local ou chamada via Web Service.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(::aLojas)
		If (::lLocal .AND. !::lReserva) .OR. !::lLocal
			Aadd(::aLojas,{	.T.				,;		//01 - Selecionada
							"000000"		,;		//02 - Codigo Loja
							SM0->M0_FILIAL	,;		//03 - Nome Loja
							cEmpAnt			,;		//04 - Empresa
							cFilAnt			,;		//05 - Filial
							.F.				,;		//06 - Determina se a consulta e via Web Service
							dDataBase		})		//07 - Data para Reserva
		Else
			lRetorno := .F.
		EndIf
		If !lRetorno .AND. ::lLocal
			MsgAlert(	STR0004 + CRLF + ;			//"Nใo sera possivel efetuar reservas,"
						STR0005 + CRLF +;			//"pois nใo hแ nenhuma Loja Cadastrada"
						STR0006)					//"no Cadastro de Identifica็ใo de Lojas."
		EndIf
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ GetDescLjบAutor  ณ Vendas Clientes    บ Data ณ  22/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Nome da Filial de Consulta / Reserva             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDescLj(cLoja) Class LJCEstoque
	Local cDescri	:= ""											//Nome da Loja
	Local nPosLj	:= Ascan(::aLojas, {|x| x[05] == cLoja })		//Posicao da Loja
	
	If nPosLj > 0
		cDescri := ::aLojas[nPosLj][03]
	EndIf
Return cDescri

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณSelProdLojบAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra as Filiais cadastradas para Reserva de Produtos.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelProdLoj() Class LJCEstoque
	Local nPosLoja		:= 0										//Posicao da Loja
	Local nPosProd		:= 0										//Posicao do Produto
	Local lContinua		:= .F.										//Variavel de Controle
	Local lFecha		:= .F.										//Verifica se deve fechar a tela
	Local lTodasLojas	:= .F.										//Todas as Lojas selecionadas
	Local lTodosProds	:= .F.										//Todos os Produtos selecionados
	Local oDlgConsulta	:= NIL										//Tela de Consulta
	Local oLojas		:= NIL										//Objeto Listbox
	Local oTodasLojas	:= NIL										//Objeto Checkbox
	Local oProdutos		:= NIL										//Objeto Listbox
	Local oTodosProds	:= NIL										//Objeto Checkbox
	Local oOk 			:= LoadBitmap(GetResources(), "LBOK")		//Marcado
	Local oNo 			:= LoadBitmap(GetResources(), "LBNO")		//Desmarcado

	If ::lReserva

		//Desmarca todos as Lojas e Produtos
		aEval(::aLojas,		{|x| x[1]:= lTodasLojas})
		aEval(::aProdutos,	{|x| x[1]:= lTodosProds})

		While !lFecha

			DEFINE MSDIALOG oDlgConsulta TITLE ;
			STR0007;			//"Consulta de Estoques / Identifica็ใo de lojas"
			FROM 0,0 TO 300,490 PIXEL OF GetWndDefault()

			@ 08,08 LISTBOX oLojas FIELDS HEADER	"",;
													STR0008;		//"Loja"
			FIELDSIZES 14, 130 SIZE 230, 55 PIXEL OF oDlgConsulta

			oLojas:SetArray(::aLojas)

			oLojas:bLDblClick := {|| (::aLojas[oLojas:nAt,1] := !::aLojas[oLojas:nAt,1]) }

			oLojas:bLine := {|| {If(::aLojas[oLojas:nAt,1], oOk, oNo), ::aLojas[oLojas:nAt,3] }}

			@ 65,12 CHECKBOX oTodasLojas VAR lTodasLojas PROMPT STR0009 SIZE 53,8 PIXEL OF oDlgConsulta;		//"Selecionar Todas"
			ON CHANGE {|| aEval(::aLojas, {|x| x[1]:= lTodasLojas }), oLojas:Refresh()}

			@ 75,08 LISTBOX oProdutos FIELDS HEADER "",;
													STR0010,;		//"Codigo"
													STR0011,;		//"Descri็ใo"
													STR0012;		//"Quant."
			FIELDSIZES 14, 40, 123, 40 SIZE 230, 55 PIXEL OF oDlgConsulta

			oProdutos:SetArray(::aProdutos)

			oProdutos:bLDblClick := {|| (::aProdutos[oProdutos:nAt, 01] := !::aProdutos[oProdutos:nAt, 01])}

			oProdutos:bLine := {|| {	If(::aProdutos[oProdutos:nAt, 01], oOk, oNo),;
										::aProdutos[oProdutos:nAt, 02],;
										::aProdutos[oProdutos:nAt, 07],;
										Transform(::aProdutos[oProdutos:nAt, 04], PesqPict("SL2","L2_QUANT")) }}

			@ 133,12 CHECKBOX oTodosProds VAR lTodosProds PROMPT STR0013 SIZE 53,8 PIXEL OF oDlgConsulta;		//"Selecionar Todos"
			ON CHANGE {|| aEval(::aProdutos,{|x| x[1]:= lTodosProds}), oProdutos:Refresh()}

			DEFINE SBUTTON FROM 133, 180 TYPE 1 ACTION (lContinua:=.T., lFecha := .T., oDlgConsulta:End()) ENABLE PIXEL OF oDlgConsulta
			DEFINE SBUTTON FROM 133, 210 TYPE 2 ACTION (lFecha := .T., oDlgConsulta:End()) ENABLE PIXEL OF oDlgConsulta

			ACTIVATE MSDIALOG oDlgConsulta CENTERED

			If lContinua
				nPosLoja	:= aScan(::aLojas, {|x| x[1] == lContinua})
				nPosProd	:= aScan(::aProdutos, {|x| x[1] == lContinua})
				lFecha		:= nPosLoja > 0 .AND. nPosProd > 0
				If !lFecha
					MsgAlert(STR0014)		//"Para continuar, deve-se selecionar pelo menos uma Loja / Produto para consulta."
					lContinua := lFecha
				EndIf
			EndIf
		End
	Else
		lContinua := .T.
	EndIf

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณSetConsultบAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o array ::aConsulta que determinara a forma de       บฑฑ
ฑฑบ          ณ Consulta / Reserva dos Produtos.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetConsult() Class LJCEstoque
	Local nLoja		:= 0					//Contador Lojas
	Local nProd		:= 0					//Contador Produtos
	Local lRetorno	:= .T.					//Retorno do Metodo

	For nLoja := 1 to Len(::aLojas)
		If ::aLojas[nLoja][1]
			For nProd := 1 to Len(::aProdutos)
				If ::aProdutos[nProd][1]
					Aadd( ::aConsulta,{	nLoja					,;		//01 - Posicao no Array de Lojas
										nProd					,;		//02 - Posicao no Array de Produtos
										::aLojas[nLoja][04]		,;		//03 - Empresa
										::aLojas[nLoja][05]		,;		//04 - Filial
										::aProdutos[nProd][02]	,;		//05 - Produto
										::aProdutos[nProd][03]	,;		//06 - Armazem
										::aLojas[nLoja][06]		})		//07 - Determina se a Consulta e via Web Service
				EndIf
			Next nProd
		EndIf
	Next nLoja

	lRetorno := !Empty(::aConsulta)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ConsEst  บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os Saldos de um determinado produto.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConsEst() Class LJCEstoque
	Local aPrvs			:= {}											//Precos de Venda
	Local nCons			:= 0											//Contador
	Local nI			:= 0											//Contador
	Local nWEstoque		:= 1											//Contador Itens Consulta Web Service
	Local nPosVazio		:= 0											//Verifica se existem registros sem retorno
	Local nPosWeb		:= aScan(::aConsulta, {|x| x[07] == .T.})		//Verifica se existe alguma Consulta Web Service
	Local nSaldoAtu		:= 0											//Saldo Atual
	Local nSaldoIni		:= 0											//Saldo Inicial
	Local lAchouWeb		:= nPosWeb > 0									//Determina se deve instanciar a Consulta Web Service
	Local lRetorno		:= .T.											//Retorno da Funcao
	Local oLJWEstoque	:= NIL											//Objeto LJWEstoque

	If lAchouWeb
		//Instancia o Web Service
		oLJWEstoque	:= WSLJWEstoque():New()
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oLJWEstoque),Nil) //Monta o Header de Autentica็ใo do Web Service

		//Informa a URL para Conexao
		oLJWEstoque:_URL := ::cURL

		//Inicializa os parametros
		oLJWEstoque:oWSAConsProd:oWSNConsProd := LJWEstoque_ArrayOfProduto():New()
	EndIf

	For nCons := 1 to Len(::aConsulta)
		If ::aConsulta[nCons][07]
			//Passa os parametros para Consulta
			Aadd(oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto, LJWEstoque_Produto():New())

			nProd	:= ::aConsulta[nCons][02]

			cDescri := ::aProdutos[nProd][07]

			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:cEmpCons	:= ::aConsulta[nCons][03]
			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:cFilCons	:= ::aConsulta[nCons][04]
			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:cCodigo		:= ::aConsulta[nCons][05]
			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:cArmazem	:= ::aConsulta[nCons][06]
			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:cDescri		:= cDescri
			oLJWEstoque:oWSAConsProd:oWSNConsProd:oWSProduto[nWEstoque]:nItem		:= nCons
			
			nWEstoque++
		Else
			nSaldoAtu	:= ::GetSldAtu(::aConsulta[nCons][05], ::aConsulta[nCons][06])
			nSaldoIni	:= ::GetSldIni(::aConsulta[nCons][05], ::aConsulta[nCons][06])
			aPrvs		:= ::GetPrvs(::aConsulta[nCons][05])

			//Adiciona os Saldos ao resultado da Consulta
			Aadd(::aSaldos,{	::aConsulta[nCons][03],;							//01 - Empresa
								::aConsulta[nCons][04],;							//02 - Filial
								::aConsulta[nCons][05],;							//03 - Codigo
								::aProdutos[::aConsulta[nCons][02]][05],;			//04 - Unidade Medida
								::aProdutos[::aConsulta[nCons][02]][06],;			//05 - Grupo
								::aProdutos[::aConsulta[nCons][02]][07],;			//06 - Descricao
								::aConsulta[nCons][06]	,;							//07 - Armazem
								nSaldoIni,;											//08 - Quantidade Inicial
								nSaldoAtu,;											//09 - Saldo Atual
								aPrvs[1],;											//00 - Preco de Venda 1
								aPrvs[2],;											//11 - Preco de Venda 2
								aPrvs[3],;											//12 - Preco de Venda 3
								aPrvs[4],;											//13 - Preco de Venda 4
								aPrvs[5],;											//14 - Preco de Venda 5
								aPrvs[6],;											//15 - Preco de Venda 6
								aPrvs[7],;											//16 - Preco de Venda 7
								aPrvs[8],;											//17 - Preco de Venda 8
								aPrvs[9],;											//18 - Preco de Venda 9
								nCons,;												//19 - Item da Consulta
								.F.						})							//20 - Reserva?
		EndIf
	Next nCons
	
	//Verifica se deve efetuar a consulta via Web Service
	If lAchouWeb
		//Faz a Consulta de Saldos
		If oLJWEstoque:ConsEst()
			//Trata o Retorno
			nResult := Len(oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo)

			For nI := 1 to nResult
				//If !Empty(oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI])
					Aadd(::aSaldos,{	oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cEmpCons	,;	//01 - Empresa
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cFilCons	,;	//02 - Filial
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cCodigo		,;	//03 - Codigo
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cUnidade	,;	//04 - Unidade Medida
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cGrupo		,;	//05 - Grupo
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cDescri		,;	//06 - Descricao
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:cArmazem	,;	//07 - Armazem
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nInicial	,;	//08 - Quantidade Inicial
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nAtual		,;	//09 - Saldo Atual
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco1		,;	//10 - Preco de Venda 1
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco2		,;	//11 - Preco de Venda 2
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco3		,;	//12 - Preco de Venda 3
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco4		,;	//13 - Preco de Venda 4
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco5		,;	//14 - Preco de Venda 5
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco6		,;	//15 - Preco de Venda 6
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco7		,;	//16 - Preco de Venda 7
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco8		,;	//17 - Preco de Venda 8
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nPreco9		,;	//18 - Preco de Venda 9
										oLJWEstoque:oWSConsEstResult:oWSNRetSaldos:oWSSaldo[nI]:nItem		,;	//19 - Item da Consulta
										.F.																	})	//20 - Reserva?
				//EndIf
			Next nI
		Else
			//Em caso de Erro mostra no Server
			cSvcError := GetWSCError()
			If Left(cSvcError, 9) == "WSCERR048"
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				Conout("LOJA1129 - 01  - " + Time() + " - Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			Else
				MsgAlert("LOJA1129 - 02  - " + Time() + " - " + STR0015 + ::cURL)		//"Sem Comunicacao com o Web Service: "
			EndIf
		EndIf
	EndIf

	//Redimensiona para nao exibir itens inexistentes
	While ((nPosVazio := aScan(::aSaldos, {|x| AllTrim(x[06]) == "" .OR. x[06] == NIL })) > 0)
		aDel(::aSaldos, nPosVazio)
		aSize(::aSaldos, Len(::aSaldos) - 1)
	End

	//Classifica por Empresa + Filial + Produto
	aSort(::aSaldos,,, {|x,y| x[01] + x[02] + x[03] < y[01] + y[02] + y[03] })

	lRetorno := !Empty(::aSaldos)
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณGetSldAtu บAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recupera o Saldo Atual do Produto.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetSldAtu(cProduto, cLocal) Class LJCEstoque
	Local nSaldo := 0				//Saldo Atual

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Nao foi utilizada uma Entidade, pois a funcao   ณ
	//ณ SaldoSB2 precisa que o SB2 esteja posicionado   ณ
	//ณ para efetuar o calculo do Saldo Atual Disponivelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2") + cProduto + cLocal)
		nSaldo := SaldoSB2()
	EndIf
Return nSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณGetSldIni บAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recupera o Saldo Inicial do Produto                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetSldIni(cProduto, cLocal) Class LJCEstoque
	Local nSaldo		:= 0				//Saldo Inicial
	Local oESldIni		:= NIL				//Entidade Saldo Inicial
	Local oDSldIni		:= NIL				//Dados da Entidade Saldo Inicial

	//Recupera o Saldo Inicial
	oESldIni := LJCEntSaldoInicial():New()
	oESldIni:DadosSet("B9_FILIAL", cFilAnt)
	oESldIni:DadosSet("B9_COD", cProduto)
	oESldIni:DadosSet("B9_LOCAL", cLocal)
	oDSldIni := oESldIni:Consultar(1)
	If oDSldIni:Count() > 0
		nSaldo := oDSldIni:Elements(1):DadosGet("B9_QINI")
	EndIf
Return nSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ GetPrvs  บAutor  ณ Vendas Clientes    บ Data ณ  25/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recupera os Precos cadastrados na Tabela de Precos.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPrvs(cProduto) Class LJCEstoque
	Local aPrvs			:= {0, 0, 0, 0, 0, 0, 0, 0, 0}				//Retorno da Funcao
	Local oETabPreco 	:= LJCEntTabPreco():New()					//Entidade Tabela de Precos
	Local oDTabPreco	:= NIL										//Dados da Entidade Tabela de Precos

	//Recupera os Precos Cadastrados
	oETabPreco:DadosSet("B0_COD", cProduto)
	oDTabPreco := oETabPreco:Consultar(1)
	If oDTabPreco:Count() > 0
		aPrvs[01] := oDTabPreco:Elements(1):DadosGet("B0_PRV1")
		aPrvs[02] := oDTabPreco:Elements(1):DadosGet("B0_PRV2")
		aPrvs[03] := oDTabPreco:Elements(1):DadosGet("B0_PRV3")
		aPrvs[04] := oDTabPreco:Elements(1):DadosGet("B0_PRV4")
		aPrvs[05] := oDTabPreco:Elements(1):DadosGet("B0_PRV5")
		aPrvs[06] := oDTabPreco:Elements(1):DadosGet("B0_PRV6")
		aPrvs[07] := oDTabPreco:Elements(1):DadosGet("B0_PRV7")
		aPrvs[08] := oDTabPreco:Elements(1):DadosGet("B0_PRV8")
		aPrvs[09] := oDTabPreco:Elements(1):DadosGet("B0_PRV9")
	EndIf
Return aPrvs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ShowEst  บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra o resultado da Consulta de Saldos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ShowEst() Class LJCEstoque
	Local nI			:= 0											//Contador
	Local lFecha		:= .F.											//Verifica se deve Fechar a Tela
	Local lRetorno		:= .F.											//Retorno da Funcao
	Local oDlgEstoque	:= NIL											//Dialogo Saldos
	Local oEstoque		:= NIL											//Listbox
	Local oOk 			:= LoadBitmap(GetResources(), "LBOK")			//Imagem Selecionado
	Local oNo 			:= LoadBitmap(GetResources(), "LBNO")			//Imagem Nao Selecionado
	Local oWhite		:= LoadBitmap(GetResources(), "BR_BRANCO")		//Imagem para quando for apenas Consulta

	If ::lLocal
		If Empty(::aSaldos)
			MsgAlert(STR0016)		//"Nao existem dados para Consulta"
			lRetorno := .F.
		Else
			While !lFecha
				DEFINE MSDIALOG oDlgEstoque TITLE STR0017 FROM 0,0 TO 300,530 PIXEL OF GetWndDefault()		//"Consulta de Estoques"
			
				@ 08,08 LISTBOX oEstoque FIELDS HEADER ;
												"",;
												STR0018,;		//"Filial"
												STR0019,;		//"Codigo"
												STR0020,;		//"Unidade"
												STR0021,;		//"Grupo"
												STR0022,;		//"Descricao"
												STR0023,;		//"Armazem"
												STR0024,;		//"Saldo Inicial"
												STR0025,;		//"Saldo Atual"
												STR0026,;		//"Preco1"
												STR0027,;		//"Preco2"
												STR0028,;		//"Preco3"
												STR0029,;		//"Preco4"
												STR0030,;		//"Preco5"
												STR0031,;		//"Preco6"
												STR0032,;		//"Preco7"
												STR0033,;		//"Preco8"
												STR0034 ;		//"Preco9"
				SIZE 250,118 PIXEL OF oDlgEstoque
					
				oEstoque:SetArray(::aSaldos)
			
				oEstoque:bLine := {|| {	If(::lReserva, If(::aSaldos[oEstoque:nAt, 20], oOk, oNo), oWhite),;
										Posicione("SLJ", 3, xFilial("SLJ") + cEmpAnt + ::aSaldos[oEstoque:nAt, 02], "LJ_NOME"),;
										::aSaldos[oEstoque:nAt, 03],;
										::aSaldos[oEstoque:nAt, 04],;
										::aSaldos[oEstoque:nAt, 05],;
										::aSaldos[oEstoque:nAt, 06],;
										::aSaldos[oEstoque:nAt, 07],;
										Transform(::aSaldos[oEstoque:nAt, 08], PesqPict("SB9", "B9_QINI")),;
										Transform(::aSaldos[oEstoque:nAt, 09], PesqPict("SB2", "B2_QATU")),;
										Transform(::aSaldos[oEstoque:nAt, 10], PesqPict("SB0", "B0_PRV1")),;
										Transform(::aSaldos[oEstoque:nAt, 11], PesqPict("SB0", "B0_PRV2")),;
										Transform(::aSaldos[oEstoque:nAt, 12], PesqPict("SB0", "B0_PRV3")),;
										Transform(::aSaldos[oEstoque:nAt, 13], PesqPict("SB0", "B0_PRV4")),;
										Transform(::aSaldos[oEstoque:nAt, 14], PesqPict("SB0", "B0_PRV5")),;
										Transform(::aSaldos[oEstoque:nAt, 15], PesqPict("SB0", "B0_PRV6")),;
										Transform(::aSaldos[oEstoque:nAt, 16], PesqPict("SB0", "B0_PRV7")),;
										Transform(::aSaldos[oEstoque:nAt, 17], PesqPict("SB0", "B0_PRV8")),;
										Transform(::aSaldos[oEstoque:nAt, 18], PesqPict("SB0", "B0_PRV9"))}}
			
				If ::lReserva
					oEstoque:bLDblClick := {|| (::aSaldos[oEstoque:nAt, 20] := ::VldChkRes(oEstoque:nAt))}
					
					@ 133,165 BUTTON STR0035 PIXEL SIZE 32,14 ACTION (lRetorno := .T., lFecha := .T., oDlgEstoque:End()) OF oDlgEstoque		//"Reservar"
				EndIf
			
				@ 133,210 BUTTON STR0036 PIXEL SIZE 32,14 ACTION (lFecha := .T., oDlgEstoque:End()) OF oDlgEstoque		//"Fechar"
				
				ACTIVATE MSDIALOG oDlgEstoque CENTERED
			End
		EndIf
	Else
		lRetorno := .T.
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณVldChkRes บAutor  ณ Vendas Clientes    บ Data ณ  27/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a selecao do Item para Reserva                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VldChkRes(nItSld) Class LJCEstoque
	Local nI		:= 0							//Contador
	Local nItemCons	:= ::aSaldos[nItSld][19]		//Item da Consulta
	Local lConteudo	:= ::aSaldos[nItSld][20]		//Determina se deve realizar a Reserva
	Local lRetorno	:= .T.							//Retorno do Metodo
	
	If lConteudo
		lRetorno := !lConteudo
	Else
		nItemPrd := ::aConsulta[nItemCons][02]
		If ::aSaldos[nItSld][09] < ::aProdutos[nItemPrd][04]
			MsgAlert(	STR0037 + CRLF +;		//"Este Item nใo pode ser reservado,"
						STR0038 + CRLF +;		//"pois a quantidade solicitada ้"
						STR0039)				//"maior que o Saldo disponํvel."
			lRetorno := .F.
		Else
			For nI := 1 to Len(::aSaldos)
				If nI <> nItSld
					If ::aSaldos[nI][20]
						nConsNI := ::aSaldos[nI][19]
						nProdNI	:= ::aConsulta[nConsNI][02]
						
						If nProdNI == nItemPrd
							MsgAlert(STR0040)		//"Um item, nใo pode ser reservado em mais de uma Loja."
							lRetorno := .F.
							Exit
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ResProd  บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua as Reservas em outras filiais.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ResProd() Class LJCEstoque
	Local aReserva		:= {}						//Itens para Reserva
	Local cNumRes		:= ""						//Numero da Reserva
	Local nCons			:= 0						//Item do Array de Consultas
	Local nLoja			:= 0						//Item do Array de Lojas
	Local nProd			:= 0						//Item do Array de Produtos
	Local nI			:= 0						//Contador
	Local nItem			:= 0						//Item da Venda
	Local nSaldos		:= 0				   		//Contador
	Local nWEstoque		:= 1						//Quantidade de Itens para Reserva em outras Filiais
	Local lRetorno		:= .F.						//Retorno do Metodo
	Local oLJWEstoque	:= WSLJWEstoque():New()		//Web Service

	If ::lReserva

		//Informa a URL para Conexao
		oLJWEstoque:_URL := ::cURL
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oLJWEstoque),Nil) //Monta o Header de Autentica็ใo do Web Service
	
		//Prepara o Envio dos Dados
		oLJWEstoque:oWSAResProd:oWSNResProd := LJWEstoque_ArrayOfItResProd():New()
	
		For nSaldos := 1 to Len(::aSaldos)
			//Verifica se o Item foi Selecionado para Reserva
			If ::aSaldos[nSaldos][20]
	    		//Guarda a Posicao do Item nos Arrays de Consulta, Lojas e Produtos
				nCons	:= ::aSaldos[nSaldos][19]
				nLoja	:= ::aConsulta[nCons][01]
				nProd	:= ::aConsulta[nCons][02]
	
				//Verifica se a Reserva devera ser feita via Web Service
				If ::aConsulta[nCons][07]
					Aadd(oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd, LJWEstoque_ItResProd():New())
					
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cEmpRes		:= cEmpAnt
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cFilRes		:= ::aLojas[nLoja][05]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cCodProd	:= ::aProdutos[nProd][02]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cArmazem	:= ::aSaldos[nSaldos][07]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cLote		:= ::aProdutos[nProd][09]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cSublote	:= ::aProdutos[nProd][10]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cEndereco	:= ::aProdutos[nProd][11]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cNumSerie	:= ::aProdutos[nProd][12]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cDtValid	:= DtoC(::aLojas[nLoja][07])
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cItVenda	:= ::aProdutos[nProd][08]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:nQtdeRes	:= ::aProdutos[nProd][04]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cCodCli		:= ::GetCliente()[1]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cLojCli		:= ::GetCliente()[2]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cKeyCli		:= ::GetCliente()[3]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cTpVenda	:= ::aProdutos[nProd][15]
					oLJWEstoque:oWSAResProd:oWSNResProd:oWSItResProd[nWEstoque]:cQuebra		:= ::aProdutos[nProd][18]

					nWEstoque++
				Else
					aReserva := {}

					Aadd(aReserva,{	Val(::aProdutos[nProd][08])	,;		//Item do Produto no aCols
									::aProdutos[nProd][02]			,;		//Codigo do Produto
									::aProdutos[nProd][04]			,;		//Quantidade
									{	::aSaldos[nSaldos][07]		,;		//Local
										::aSaldos[nSaldos][09]}		,;		//Quantidade em Estoque
									::aProdutos[nSaldos][03]		})		//Armazem
					
					cNumRes	:= ::GrvResProd(	aReserva			,;	//Array para Rotina de Reserva
					 							::aLojas[nLoja][07]	,;	//Data da Validade da Reserva
					 							::aLojas[nLoja][05],;	//Filial para Reserva
					 							NIL					)	//Variaveis de Controle de Lote

					If !Empty(cNumRes)
						lRetorno				:= .T.
						::aProdutos[nProd][13]	:= cNumRes
						::aProdutos[nProd][14]	:= ::aLojas[nLoja][05]
					EndIf
				EndIf
			EndIf
		Next nSaldos
		If nWEstoque > 1
			//Efetua a Reserva dos Produtos
			If oLJWEstoque:ResProd()
				//Tratar o Retorno da Rotina de Reservas
				For nI := 1 to Len(oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes)
					//Guarda o numero do Item da Venda
					nItem := Val(oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes[nI]:cItem)
					
					//Procura o Item nos Produtos
					nProd := Ascan(::aProdutos, {|x| Val(x[8]) == nItem })

					//Guarda o numero da Reserva no Produto
					If nProd > 0
						lRetorno				:= .T.
						::aProdutos[nProd][14]	:= oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes[nI]:cFilRes
						::aProdutos[nProd][13]	:= oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes[nI]:cReserva
						::aProdutos[nProd][16]	:= oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes[nI]:cOrcam
						::aProdutos[nProd][17]	:= oLJWEstoque:oWSResProdResult:oWSNRetRes:oWSItRetRes[nI]:cPedido
					EndIf
				Next nI
			Else
				//Em caso de Erro mostra no Server
				cSvcError := GetWSCError()
				If Left(cSvcError, 9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("LOJA1129 - 01  - " + Time() + " - Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
				Else
					MsgAlert("LOJA1129 - 02  - " + Time() + " - " + STR0015 + ::cURL)		//"Sem Comunicacao com o Web Service: "
				EndIf
			EndIf
		EndIf
	EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณGrvResProdบAutor  ณ Vendas Clientes    บ Data ณ  28/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a Gravacao Local das Reservas                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GrvResProd(aReserva, dDataVal, cFilRes, aLote) Class LJCEstoque
	Local aCliente	:= {}							//Dados do Cliente
	Local cNumRes 	:= ""							//Numero da Reserva
	Local cCampo	:= ""							//Nome do Campo
	Local cValor	:= ""							//Valor do Campo
	Local nChave	:= 0							//Chave de Pesquisa no SA1
	Local nI		:= 0							//Contador
	Local oECliente	:= LJCEntCliente():New()		//Entidade Cliente
	Local oDCliente	:= NIL							//Dados da Entidade Cliente
	
	Default aLote	:= {}							//Informacoes de Lote do Produto

	If ::lLocal
		oECliente:DadosSet("A1_COD", ::GetCliente()[1])
		oECliente:DadosSet("A1_LOJA", ::GetCliente()[2])
		nChave	:= 1
	Else
		oECliente:DadosSet("A1_CGC", ::GetCliente()[3])
		nChave	:= 3
	EndIf

	oDCliente := oECliente:Consultar(nChave)
	
	If oDCliente:Count() > 0
		For nI := 1 to Len(oECliente:oCampos:aColecao)
			cCampo := oECliente:oCampos:aColecao[nI][1]
			cValor := oDCliente:Elements(1):DadosGet(cCampo)
			
			Aadd(aCliente, {cCampo, cValor})
        Next nI
		cNumRes := Lj7GeraSC0(aReserva, dDataVal, aCliente, cFilRes, aLote)
	EndIf
Return cNumRes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณRetReservaบAutor  ณ Vendas Clientes    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os Dados das Reservas Efetuadas                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetReserva() Class LJCEstoque
	Local aReservas := {}				//Array com as Informacoes das Reservas Efetuadas
	Local cLoja		:= ""				//Loja da Reserva
	Local nLoja		:= 0				//Posicao no Array de Lojas
	Local nI		:= 0				//Contador
	
	For nI := 1 to Len(::aProdutos)
		If !Empty(::aProdutos[nI][13]) .AND. !Empty(::aProdutos[nI][14])
			cLoja := ::aProdutos[nI][14]
			
			nLoja := Ascan(::aLojas, {|x| x[05] == cLoja})
			
			If nLoja > 0
				Aadd(aReservas, {	::aProdutos[nI][08],;	//01-Item da Venda
									::aProdutos[nI][02],;	//02-Codigo do Produto
									::aProdutos[nI][07],;	//03-Descricao do Produto
									::aProdutos[nI][03],;	//04-Armazem
									::aProdutos[nI][13],;	//05-Numero da Reserva
									::aLojas[nLoja][04],;	//06-Empresa da Reserva
									::aProdutos[nI][14],;	//07-Filial da Reserva
									::aLojas[nLoja][02],;	//08-Numero da Filial no Cadastro de Lojas
									::aProdutos[nI][16],;	//09-Numero do Orcamento Filho da Reserva
									::aProdutos[nI][17]})	//10-Numero do Pedido de Venda da Reserva
			EndIf
		EndIf
	Next nI
Return aReservas
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ConsRes  บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta Reservas.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConsRes() Class LJCEstoque
	Local lRetorno		:= .F.							//Retorno da Funcao

	Local cTipo			:= ""							//Tipo de Reserva
	Local cCliente		:= ""							//Codigo do Cliente

	Local nI			:= 0							//Contador
	Local nJ			:= 0							//Contador
	Local nWConsRes		:= 1							//Contador

	Local oEReserv		:= LJCEntReserva():New()		//Entidade Reservas
	Local oDReserv		:= NIL							//Dados da Entidade Reservas
	Local oLJWEstoque	:= NIL							//Objeto para Consulta via Web Service

	//Inicializa o Array com as Reservas
	::aConsRes	:= {}

	If ::lLocal .AND. ::lConsWeb
		//Instancia o Objeto
		oLJWEstoque	:= WSLJWEstoque():New()		//Web Service
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oLJWEstoque),Nil) //Monta o Header de Autentica็ใo do Web Service
		
		//Informa a URL para Conexao
		oLJWEstoque:_URL := ::cURL
		
		//Prepara os parametros para Consulta
		oLJWEstoque:oWSAConsRes:oWSNConsRes	:= LJWEstoque_ArrayOfItConsRes():New()
	EndIf

	For nI := 1 to Len(::aLojas)
		If ::aLojas[nI][06]
			//Prepara um novo item para Consulta
			Aadd(oLJWEstoque:oWSAConsRes:oWSNConsRes:oWSItConsRes, LJWEstoque_ItConsRes():New())
			//Instancia o Objeto para Consulta			
			oLJWEstoque:oWSAConsRes:oWSNConsRes:oWSItConsRes[nWConsRes]:cFilCons := ::aLojas[nI][05]
			
			nWConsRes++
		Else
			oEReserv:DadosSet("C0_FILIAL", ::aLojas[nI][05])
			oDReserv := oEReserv:Consultar(1)
			
			For nJ := 1 to oDReserv:Count()
				cTipo		:= oDReserv:Elements(nJ):DadosGet("C0_TIPO")
				cCliente	:= oDReserv:Elements(nJ):DadosGet("C0_DOCRES")

				If cTipo == "LJ" .AND. AllTrim(cCliente) == AllTrim(::GetCliente()[1])
					Aadd(::aConsRes, {	.F.												,;		//01 - Controle ListBox
										::aLojas[nI][05]								,;		//02 - Filial da Reserva
										oDReserv:Elements(nJ):DadosGet("C0_PRODUTO")	,;		//03 - Codigo Produto
										oDReserv:Elements(nJ):DadosGet("C0_QTDORIG")	,;		//04 - Quantidade Reserva
										oDReserv:Elements(nJ):DadosGet("C0_NUM")		,;		//05 - Numero Reserva
										oDReserv:Elements(nJ):DadosGet("C0_EMISSAO")	,;		//06 - Data Emissao
										oDReserv:Elements(nJ):DadosGet("C0_VALIDA")		,;		//07 - Data Validade
										oDReserv:Elements(nJ):DadosGet("C0_LOCAL")		,;		//08 - Armazem
										oDReserv:Elements(nJ):DadosGet("C0_OBS")		})		//09 - Observacoes
				EndIf
			Next nJ				
		EndIf
	Next nI

	If ::lLocal .AND. ::lConsWeb
		If nWConsRes > 1
			oLJWEstoque:cKeyCli := ::GetCliente()[3]
			
			If oLJWEstoque:ConsRes()
				For nI := 1 to Len(oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes)
					Aadd(::aConsRes, {	.F.																			,;		//01 - Controle ListBox
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cFilCons			,;		//02 - Filial Reserva
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cProduto			,;		//03 - Codigo Produto
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:nQuantRes			,;		//04 - Quantidade Reserva
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cCodRes			,;		//05 - Numero Reserva
										StoD(oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cDataRes)	,;		//06 - Data Emissao
										StoD(oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cDataVal)	,;		//07 - Data Validade
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cArmazem			,;		//08 - Armazem
										oLJWEstoque:oWSConsResResult:oWSNRetCRes:oWSItRetCRes[nI]:cObserv			})		//09 - Observacoes
				Next nI
			Else
				//Em caso de Erro mostra no Server
				cSvcError := GetWSCError()
				If Left(cSvcError, 9) == "WSCERR048"
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					Conout("LOJA1129 - 01  - " + Time() + " - Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
				Else
					MsgAlert("LOJA1129 - 02  - " + Time() + " - " + STR0015 + ::cURL)		//"Sem Comunicacao com o Web Service: "
				EndIf
			EndIf
		EndIf
	EndIf

	lRetorno := Len(::aConsRes) > 0

Return lRetorno                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ShowRes  บAutor  ณ Vendas Clientes    บ Data ณ  22/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a Tela com as Reservas do Cliente Atual              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ShowRes() Class LJCEstoque
	Local lRetorno	:= .T.										//Retorno do Metodo

	Local oECliente	:= LJCEntCliente():New()					//Entidade Cliente
	Local oDCliente := NIL										//Dados da Entidade Cliente
	
	Local cGetCliente	:= ""									//Descricao do Cliente

	Local oOk 			:= LoadBitmap(GetResources(), "LBOK")	//Marcado
	Local oNo 			:= LoadBitmap(GetResources(), "LBNO")	//Desmarcado
	Local oDlgConsulta											//Tela da Consulta
	Local oConsulta												//Objeto Listbox

	oECliente:DadosSet("A1_COD"		, ::GetCliente()[1])
	oECliente:DadosSet("A1_LOJA"	, ::GetCliente()[2])
	
	oDCliente := oECliente:Consultar(1)		//Filial + Codigo + Loja
                                                                     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta tela para informar ao usuario as reservas para o cliente           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(::aConsRes) .AND. oDCliente:Count() > 0

		cGetCliente := ::GetCliente()[1] + " - " + oDCliente:Elements(1):DadosGet("A1_NOME")

		DEFINE MSDIALOG oDlgConsulta TITLE STR0041 FROM 0, 0 TO 300, 490 PIXEL OF GetWndDefault()		//"Consulta Reservas"

		@ 10,8 SAY STR0042 PIXEL OF oDlgConsulta		//"Cliente: "

		@ 10,30 MSGET oCliente VAR cGetCliente WHEN .F. SIZE 130,08 PIXEL OF oDlgConsulta
	
 		@ 25,8 LISTBOX oConsulta FIELDS HEADER	"",;
												STR0043,;		//"Loja"
												STR0044,;		//"Produto"
												STR0045,;		//"Qtd"
												STR0046,;		//"Reserva"
												STR0047,;		//"Emissใo"
												STR0048,;		//"Validade"
												STR0049;		//"Observa็ใo"
		FIELDSIZES 14, 60, 90, 30, 40, 35, 40, 40, 120 SIZE 230, 100 PIXEL OF oDlgConsulta
		
		oConsulta:SetArray(::aConsRes)

		oConsulta:bLDblClick := {|| (::aConsRes[oConsulta:nAt, 01] := !::aConsRes[oConsulta:nAt, 01])}

		oConsulta:bLine := {|| {	Iif(::aConsRes[oConsulta:nAt, 01], oOk, oNo),;
									::GetDescLj(::aConsRes[oConsulta:nAt, 02]),;
									Alltrim(::aConsRes[oConsulta:nAt, 03]) + "-" + Alltrim(::GetProdInf(::aConsRes[oConsulta:nAt, 03])[03]),;
									::aConsRes[oConsulta:nAt, 04],;
									::aConsRes[oConsulta:nAt, 05],;
									::aConsRes[oConsulta:nAt, 06],;
									::aConsRes[oConsulta:nAt, 07],;
									::aConsRes[oConsulta:nAt, 09]}}
									
		@ 133,210 BUTTON STR0050 PIXEL SIZE 32,14 ACTION oDlgConsulta:End() OF oDlgConsulta		//"Sair"
	
		ACTIVATE MSDIALOG oDlgConsulta CENTERED
	Else
		Aviso( STR0051, STR0052, {STR0053} )		//"Aten็ใo"##"Nใo hแ reservas para este cliente."##"Ok"
	Endif	

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ CancRes  บAutor  ณ Vendas Clientes    บ Data ณ  24/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o cancelamento das Reservas Efetuadas.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancRes() Class LJCEstoque
	Local nCancWeb		:= 1				//Contador
	Local nI			:= 0				//Contador
	Local nJ			:= 0				//Contador
	Local nPosLoja		:= 0				//Posicao da Loja
	Local oLJWEstoque	:= NIL				//Objeto Web Service
	Local aLote			:= {}				//Array com os Lotes
	Local aRet			:= {}				//Retorno da Rotina de Cancelamentos
	Local aRetorno		:= {}				//Retorno da Funcao
	Local aReserva		:= {}				//Array de Reservas para Cancelamento

	If ::lLocal .AND. ::lConsWeb
		//Instancia o Objeto
		oLJWEstoque	:= WSLJWEstoque():New()		//Web Service
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oLJWEstoque),Nil) //Monta o Header de Autentica็ใo do Web Service
		
		//Informa a URL para Conexao
		oLJWEstoque:_URL := ::cURL
		
		//Prepara os parametros para Consulta
		oLJWEstoque:oWSACancRes:oWSNCancRes	:= LJWEstoque_ArrayOfItCancRes():New()
	EndIf

	For nI := 1 to Len(::aProdutos)
		nPosLoja := Ascan(::aLojas, {|x| AllTrim(x[02]) == AllTrim(::aProdutos[nI][14])})
		If nPosLoja > 0
			If ::aLojas[nPosLoja][06]
				//Adiciona ao Objeto para Cancelamento
				Aadd(oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes, LJWEstoque_ItCancRes():New())

				//Instancia o Objeto para Consulta
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cReserva		:= ::aProdutos[nI][13]		//Reserva
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cLojaRes		:= ::aProdutos[nI][14]		//Cod. Loja
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cProduto		:= ::aProdutos[nI][02]		//Produto
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cArmazem		:= ::aProdutos[nI][03]		//Local
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cFilCanc		:= ::aLojas[nPosLoja][05]	//Filial
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cSubLote		:= ::aProdutos[nI][10]		//Sub Lote
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cNumLote		:= ::aProdutos[nI][09]		//Lote
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cEndereco	:= ::aProdutos[nI][11]		//Endereco
				oLJWEstoque:oWSACancRes:oWSNCancRes:oWSItCancRes[nCancWeb]:cNumSerie	:= ::aProdutos[nI][12]		//Numero Serie

				nCancWeb++
			Else
				aReserva	:= {}
				aRet		:= {}

				//Cancelamento Local
				Aadd(aReserva,{	::aProdutos[nI][13]			,;		//Reserva
								::aProdutos[nI][14]			,;		//Cod. Loja
								::aProdutos[nI][02]			,;		//Produto
								::aProdutos[nI][03]			,;		//Local
								::aLojas[nPosLoja][05]		})		//Filial

				aLote := {	::aProdutos[nI][10]		,;		//Sub Lote
							::aProdutos[nI][09]		,;		//Lote
							::aProdutos[nI][11]		,;		//Endereco
							::aProdutos[nI][12]		}		//Numero Serie

				aRet := Lj7CancRes(	aReserva	,;		//Dados do Produto para Reserva
									nil			,;		
									aLote		)		//Dados do Lote

				For nJ := 1 to Len(aRet)
					Aadd(aRetorno,{	aRet[nJ][01]	,;		//Numero da Reserva
									aRet[nJ][02] 	})		//Status do Cancelamento
				Next nJ
			EndIf
		EndIf
	Next nI
	
	If ::lLocal .AND. ::lConsWeb .AND. nCancWeb > 1
		//Cliente para Cancelamento
		oLJWEstoque:cKeyCli := ::GetCliente()[3]

		//Faz o Cancelamento via Web Services
		If oLJWEstoque:CancRes()
			For nI := 1 to Len(oLJWEstoque:oWSCancResResult:oWSNRetCanc:oWSItRetCanc)
				Aadd(aRetorno, {	oLJWEstoque:oWSCancResResult:oWSNRetCanc:oWSItRetCanc[nI]:cReserva	,;		//Numero da Reserva
									oLJWEstoque:oWSCancResResult:oWSNRetCanc:oWSItRetCanc[nI]:lCancela })		//Status do Cancelamento
			Next nI
		Else
			//Em caso de Erro mostra no Server
			cSvcError := GetWSCError()
			If Left(cSvcError, 9) == "WSCERR048"
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				Conout("LOJA1129 - 01  - " + Time() + " - Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			Else
				MsgAlert("LOJA1129 - 02  - " + Time() + " - " + STR0015 + ::cURL)		//"Sem Comunicacao com o Web Service: "
			EndIf
		EndIf
	EndIf
Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณRestFil   บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura a Filial Original.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RestFil() Class LJCEstoque
	If ValType(::cFilBkp) <> "U"
		cFilAnt	:= ::cFilBkp
		RestArea(::aAreaSM0)
	EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ GetOrcam บAutor  ณ Vendas Clientes    บ Data ณ  04/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reserva um Numero de Orcamento para a Reserva.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetOrcam() Class LJCEstoque
	Local cOrcam := GetSx8Num("SL1", "L1_NUM")
	ConfirmSX8()
Return cOrcam

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ GetPedidoบAutor  ณ Vendas Clientes    บ Data ณ  04/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reserva um Numero de Pedido de Venda para a Reserva.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPedido() Class LJCEstoque
	Local cPedido := GetSx8Num("SC5", "C5_NUM")
	ConfirmSX8()
Return cPedido
