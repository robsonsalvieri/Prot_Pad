#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1029 ; Return  			// "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCServicoH      บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em tratar os dados retornados no servico H. 	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCServicoH From LJAAbstrataServico

	Data cCodResp 		 						//Codigo retornado pela Institui็ใo ou pelo SiTef. Caso retorne "SC"
												//deve-se solicitar aprovacao da transacao ao Operador/Supervisor.
												//Alfanumerico(2)

	Data cDtTrans								//Data da efetivacao da transacao.
												//MMDD
												
	Data cHora									//Hora da efetivacao da transacao.
												//HHMMSS

	Data nDoc									//Numero unico que identifica a transacao, e retornado pela instituicao.
												//Numerico(9)

	Data nCodEstab								//Codigo do estabelecimento do lojista perante a Instituicao.
												//Numerico(15)

	Data cNumAuto								//Numero da autorizacao da transacao de compra com cartao de credito
												//Alfanumerico(6)

	Data nDocCanc								//Numero do documento da transacao cancelada.
												//Numerico(9)

	Data cDtCanc								//Data de efetivacao da compra cancelada.
												//MMDD

	Data cHrCanc								//Hora de efetivacao da compra cancelada.
												//HHMMSS

	Data cInstituic								//Descricao da Instituicao que processou a transacao.
												//Alfanumerico(16)

	Data nNSUSitef								//Numero sequencial unico gerado pelo SiTef, para identificar 
												//uma transacao.
												//Numerico(6)

	Data nCodRede								//Codigo interno ao SiTef que define a rede que tratou essa 
												//transacao. E necessario para a confirmacao da transacao.
												//Numerico(2)

    
	Method ServicoH(cTipo)						//Metodo construtor
	Method TratarServ(cDados)                  	//Metodo que ira tratar os dados do servico

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณServicoH  บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCServicoH.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cTipo) - Tipo do servico.		   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ServicoH(cTipo) Class LJCServicoH

	::cTpServ 		:= cTipo
	::cCodResp		:= ""
	::cDtTrans		:= ""						
	::cHora			:= ""
	::nDoc			:= 0
	::nCodEstab		:= 0
	::cNumAuto		:= ""
	::nDocCanc		:= 0
	::cDtCanc		:= ""
	::cHrCanc		:= ""
	::cInstituic	:= ""
	::nNSUSitef		:= 0
	::nCodRede		:= 0

Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTratarServบAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que ira tratar os dados retornados no servico.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cDados)   - String com os dados do servico.	  บฑฑ
ฑฑบ			 ณExpN1 (2 - nPosicao) - Posicao da string dos dados.		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TratarServ(cDados, nPosicao) Class LJCServicoH

	Local nCount := 1				//Variavel de controle contador
	
	::cCodResp := Substr(cDados, nCount, 2)
	nCount += 2
	
	::cDtTrans := Substr(cDados, nCount, 4)
	nCount += 4
										
	::cHora := Substr(cDados, nCount, 6)								
	nCount += 6
	
	::nDoc := Val(Substr(cDados, nCount, 9))
	nCount += 9
	
	::nCodEstab := Val(Substr(cDados, nCount, 15))
	nCount += 15
	
	::cNumAuto := Substr(cDados, nCount, 6)					
	nCount += 6

	::nDocCanc := Val(Substr(cDados, nCount, 9))				
	nCount += 9
	
	::cDtCanc := Substr(cDados, nCount, 4)						
	nCount += 4
	
	::cHrCanc := Substr(cDados, nCount, 6)						
	nCount += 6

	::cInstituic := Substr(cDados, nCount, 16)					
	nCount += 16
	
	::nNSUSitef := Val(Substr(cDados, nCount, 6))							
	nCount += 6
	
	::nCodRede := Val(Substr(cDados, nCount, 2))
	nCount += 2
	
Return Nil