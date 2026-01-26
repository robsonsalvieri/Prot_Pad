#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA2147.CH"

User Function LOJA2147 ; Return  // "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCTesteCargaOrc บAutor  ณVendas Clientes     บ Data ณ  20/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  																 บฑฑ
ฑฑบ			 ณ											 						 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCTesteCargaOrcamento 

	Data dDtVenda											//Data da geracao do orcamento
	Data nCupom		                                       	//Numero do cupom e orcamento que sera gerado no front-loja
	Data lCancelado											//Informa se o wizard foi cancelado
	Data nQtde                                              //Quantidade de orcamento a ser gerado
	Data cProduto											//Produto a ser utilizado no orcamento
	Data oProduto											//Objeto do produto retornado da consulta.
	Data cCliente											//Cliente selecionado
	Data oGetCli											//Objeto get
	Data oGetData											//Objeto get
	Data oGetOrc											//Objeto get			 
	Data oGetQtde											//Objeto get
	Data oGetProd											//Objeto get

	Method New()
	Method Show()
	
	Method ValidaData()
	Method ValNumOrc()
	Method ValQtdeOrc()
	Method ValProd()
	Method ValidaDados()
	Method GerCargOrc()
	Method ExisteSL1()
	Method ValCli()
		
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew              บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCTesteCargaOrcamento.			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCTesteCargaOrcamento 

	::dDtVenda	 	:= CTOD("  /  /    ") 
	::nCupom    	:= 1
	::lCancelado	:= .T.
    ::nQtde			:= 1
    ::cProduto		:= Space(15)
	::cCliente		:= Space(20)    
	::oGetCli		:= Nil
	::oGetData		:= Nil
	::oGetOrc		:= Nil
	::oGetQtde		:= Nil
	::oGetProd		:= Nil

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShow             บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em iniciar o wizard.       				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Show() Class LJCTesteCargaOrcamento 
	
	Local oWizard 	:= Nil   						//Objeto do wizard
	Local oPanel 	:= Nil							//Objeto dos paineis do wizard    
	Local oGrupo	:= Nil							//Objeto dos grupos criados nos paineis    
	Local oFnt0		:= Nil							//Font utilizado no Wizard
	
	set date brit
	set epoch to 1911
	
	DEFINE FONT oFnt0 NAME "Courier New"  SIZE 7,19 
	
   	//Criando objeto Wizard
	DEFINE WIZARD oWizard TITLE STR0001 ; //"Teste de carga de integra็ใo"
	HEADER STR0002 ; //"Integra็ใo TOTVS"
	MESSAGE "" TEXT ;
	NEXT {|| .T.} FINISH {|| .T.} NOFIRSTPANEL PANEL
	
	oPanel := oWizard:GetPanel(1)
	@  05, 05 SAY STR0003 + Chr(10) + Chr(10) + ; //"Este Wizard tem como objetivo gerar diversos or็amentos no m๓dulo Front-Loja para efetuar o teste de carga da integra็ใo."
	          STR0004 ; //"Obs: A condi็ใo de pagamento utilizada serแ (A VISTA)  e forma (R$ - Dinheiro)"
	          OF oPanel PIXEL SIZE 280,200 FONT oFnt0
	
	//Criando painel para capturar a data do or็amento
	CREATE PANEL oWizard HEADER STR0005 ; //"Dados para gera็ใo do or็amento"
	MESSAGE "" ;
	BACK {|| .T. } NEXT {|| .T.} FINISH {|| ::ValidaDados()} PANEL         
	
	oPanel := oWizard:GetPanel(2)
	oGrupo := TGroup():New(5,2,135,287,STR0006,oPanel,,,.T.) //"Informe os dados para gera็ใo do or็amento:"

	TSay():New(25,08,{|| STR0007},oPanel,,,,,,.T.) //"Data do or็amento"
	::oGetData := TGet():New(24,90,bSETGET(::dDtVenda),oPanel,50,10,,{|| .T.},,,,,,.T.,,,,,,,.F.,,,)
	
	TSay():New(45,08,{|| STR0008},oPanel,,,,,,.T.) //"N๚mero do or็amento inicial:"
	::oGetOrc := TGet():New(44,90,bSETGET(::nCupom),oPanel,50,10,"@R 999999",{|| .T.},,,,,,.T.,,,,,,,.F.,,,)
		
	TSay():New(65,08,{|| STR0009},oPanel,,,,,,.T.) //"Quantidade de or็amentos:"
	::oGetQtde := TGet():New(64,90,bSETGET(::nQtde),oPanel,50,10,"@R 999",{|| .T.},,,,,,.T.,,,,,,,.F.,,,)
		
	TSay():New(85,08,{|| STR0010},oPanel,,,,,,.T.) //"C๓digo do produto:"
	::oGetProd := TGet():New(84,90,bSETGET(::cProduto),oPanel,50,10,"@! 999999999999999",{|| .T.},,,,,,.T.,,,,,,,.F.,,"FRT",)
	
	TSay():New(105,08,{|| STR0011},oPanel,,,,,,.T.) //"C๓digo do cliente:"
	::oGetCli := TGet():New(104,90,bSETGET(::cCliente),oPanel,50,10,"@! 99999999999999999999",{|| .T.},,,,,,.T.,,,,,,,.F.,,"SA1",)
			
	ACTIVATE WIZARD oWizard CENTER
    
	If !::lCancelado
		Processa({|| ::GerCargOrc()}, STR0012) //"Gerando or็amentos..."
	Else
		MsgAlert(STR0013) //"Processo cancelado pelo usuแrio."	
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExisteSL1        บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em verificar se o orcamento ja existe.		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cCupom) - Numero do orcamento e cupom.			  		 บฑฑ															 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExisteSL1(cCupom) Class LJCTesteCargaOrcamento
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	Local oEntSL1	:= Nil				//Objeto do tipo LJCEntOrcamento
	Local oRetorno	:= Nil				//Retorno da consulta
	
	oEntSL1 := LJCEntOrcamento():New()
	
	oEntSL1:DadosSet("L1_NUM", cCupom)
		
	oRetorno := oEntSL1:Consultar(1)
		
	If oRetorno:Count() == 0
		lRetorno := .F.	
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGerCargOrc       บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em gerar os orcamentos.					     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GerCargOrc() Class LJCTesteCargaOrcamento
	
	Local nCount 	:= 0
	Local cCupom	:= ""
	Local cHora		:= ""
	Local nPreco	:= ::oProduto:Elements(1):DadosGet("BI_PRV")
	Local cDescProd	:= ::oProduto:Elements(1):DadosGet("BI_DESC")
	Local cUn		:= ::oProduto:Elements(1):DadosGet("BI_UM")
	Local cTS		:= ::oProduto:Elements(1):DadosGet("BI_TS")
	Local cTabela	:= ::oProduto:Elements(1):DadosGet("BI_TABELA")
	Local cLocal	:= ::oProduto:Elements(1):DadosGet("BI_LOCPAD")
	Local nOrc		:= 0
	Local cSerie	:= LjGetStation("LG_SERIE")
	Local cPdv		:= LjGetStation("LG_PDV")
	
	ProcRegua(::nQtde)
	
	For nCount := 1 To ::nQtde
	    
	    cCupom 	:= Strzero(::nCupom, 6)
	   	cHora 	:= Substr(Time(), 1, 5)
	    
	    If !::ExisteSL1(cCupom)
	    
			Begin Transaction
		   	
	   			IncProc("Gerando or็amento (" + cCupom + "). Aguarde...") //"Gerando orcamento SA3. Aguarde..."
			   	 
				dbSelectArea("SL1")
				RecLock("SL1", .T.)
					
				aArray := {{"L1_DOC"	, cCupom}, ;
						 {"L1_SITUA"	, "00"}, ;
						 {"L1_FILIAL"	, xFilial("SL1")}, ;
						 {"L1_NUM"		, cCupom}, ;
						 {"L1_VEND"		, "000001"}, ;
						 {"L1_CLIENTE"	, ::cCliente}, ;
						 {"L1_LOJA"		, "01"}, ;
						 {"L1_TIPOCLI"	, "F"}, ;
						 {"L1_VLRTOT"	, nPreco}, ;
						 {"L1_VLRLIQ"	, nPreco}, ;
						 {"L1_DTLIM"	, ::dDtVenda}, ;
						 {"L1_SERIE"	, cSerie}, ;
						 {"L1_PDV"		, cPdv}, ;	
						 {"L1_EMISNF"	, ::dDtVenda}, ;
						 {"L1_VALBRUT"	, nPreco}, ;
						 {"L1_VALMERC"	, nPreco}, ;
						 {"L1_TIPO"		, "V"}, ;
						 {"L1_OPERADO"	, xNumCaixa()}, ;
						 {"L1_DINHEIR"	, nPreco}, ;
						 {"L1_ENTRADA"	, nPreco}, ;
						 {"L1_PARCELA"	, 1}, ;
						 {"L1_CONDPG"	, "CN"}, ;
						 {"L1_EMISSAO"	, ::dDtVenda}, ;
						 {"L1_CONFVEN"	, "SSSSSSSSNSSS"}, ;
						 {"L1_NUMCFIS"	, cCupom}, ;
						 {"L1_HORA"		, cHora}, ;
 						 {"L1_IMPRIME"	, "1S"}, ;
						 {"L1_ESTACAO"	, "001"}}
					
				AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
									
				dbSelectArea("SL2")
				RecLock("SL2", .T.)
				
				aArray := {{"L2_DOC"	, cCupom}, ;
						 {"L2_SITUA"	, "00"}, ;
						 {"L2_FILIAL"	, xFilial("SL2")}, ;
						 {"L2_NUM"		, cCupom}, ;
						 {"L2_ITEM"		, "01"}, ;
						 {"L2_DESCRI"	, cDescProd}, ;
						 {"L2_QUANT"	, 1}, ;
						 {"L2_VRUNIT"	, nPreco}, ;
						 {"L2_VLRITEM"	, nPreco}, ;
						 {"L2_LOCAL"	, cLocal}, ;
						 {"L2_UM"		, cUn}, ;
						 {"L2_TES"		, cTS}, ;
						 {"L2_CF"		, "512"}, ;	
						 {"L2_VENDIDO"	, "S"}, ;
						 {"L2_SERIE"	, cSerie}, ;
						 {"L2_PDV"		, cPdv}, ;
						 {"L2_TABELA"	, cTabela}, ;
						 {"L2_EMISSAO"	, ::dDtVenda}, ;
						 {"L2_PRCTAB"	, nPreco}, ;
						 {"L2_GRADE"	, "N"}, ;
			 			 {"L2_PRODUTO"	, ::cProduto}, ;
						 {"L2_VEND"		, "000001"}}
					
				AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
				
				dbSelectArea("SL4")
				RecLock("SL4", .T.)
					
				aArray := {{"L4_VALOR"	, nPreco}, ;
						 {"L4_DATA"		, ::dDtVenda}, ;
						 {"L4_FILIAL"	, xFilial("SL4")}, ;
						 {"L4_NUM"		, cCupom}, ;
						 {"L4_FORMA"	, "R$"}, ;
						 {"L4_TERCEIR"	, .F.}, ;
						 {"L4_SITUA"	, "00"}}
					
				AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
			
			End Transaction
		    
			nOrc++
		
		EndIf
		
		::nCupom++    
	
	Next
	
	If nOrc == 0
		MsgAlert(STR0014) //"Nใo foi gerado nenhum or็amento. Por que a numera็ใo informada jแ existe."
	ElseIf nOrc == 1
		MsgAlert(STR0015 + CVALTOCHAR(nOrc) + STR0016) //"Foi gerado " + CVALTOCHAR(nOrc) + " or็amento."	
	Else
		MsgAlert(STR0017 + CVALTOCHAR(nOrc) + STR0018) //"Foram gerados " + CVALTOCHAR(nOrc) + " or็amentos."
	EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValidaDados      บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar os dados informados.			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValidaDados() Class LJCTesteCargaOrcamento 
	
	Local lRetorno := .T.				//Variavel de retorno do metodo
	
	lRetorno := ::ValidaData()	
	
	If lRetorno
		lRetorno := ::ValNumOrc()		
	EndIf

	If lRetorno
		lRetorno := ::ValQtdeOrc()		
	EndIf
	
	If lRetorno
		lRetorno := ::ValProd()		
	EndIf
	
	If lRetorno
		lRetorno := ::ValCli()		
	EndIf
	  
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValidaData       บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar a data informada.				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValidaData() Class LJCTesteCargaOrcamento 
	
	Local lRetorno := .T.				//Variavel de retorno do metodo
	
	//Verifica se as data foram informadas
	If Empty(::dDtVenda)
		MsgAlert(STR0019) //"Informar a data do or็amento."
		lRetorno := .F.
	ElseIf ::dDtVenda < Date()
		MsgAlert(STR0020) //"Data tem que ser maior ou igual a data corrente."
		lRetorno := .F.	
	Endif	
	
	If !lRetorno
		::oGetData:SetFocus()
	EndIf
	  
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValNumOrc        บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar o numero do orcamento inicial.	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValNumOrc() Class LJCTesteCargaOrcamento 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	
	If Empty(::nCupom) .OR. ::nCupom == 0
		MsgAlert(STR0021) //"Informar o n๚mero do or็amento."
		lRetorno := .F.
		::oGetOrc:SetFocus()
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValQtdeOrc       บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar a quantidade de orcamentos.		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValQtdeOrc() Class LJCTesteCargaOrcamento 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	
	If Empty(::nQtde) .OR. ::nQtde == 0
		MsgAlert(STR0022) //"Informar a quantidade de or็amentos a ser gerado."
		lRetorno := .F.
	ElseIf ::nQtde > 500
		MsgAlert(STR0023) //"Valor maior que o limite permitido (Limite: 500 or็amentos)."
		lRetorno := .F.
	EndIf
    
	If !lRetorno
		::oGetQtde:SetFocus()
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValProd          บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar o produto informado.			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValProd() Class LJCTesteCargaOrcamento 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	Local oEntSBI	:= Nil				//Objeto do tipo LJCEntProdutoFront
	
	If Empty(::cProduto) .OR. AllTrim(::cProduto) == ""
		MsgAlert(STR0024) //"Informar o produto."
		lRetorno := .F.
	Else
	
		oEntSBI := LJCEntProdutoFront():New()
		
		oEntSBI:DadosSet("BI_COD", ::cProduto)
		
		::oProduto := oEntSBI:Consultar(1)
		
		If ::oProduto:Count() == 0
			MsgAlert(STR0025 + ::cProduto + STR0026) //"Produto (" + ::cProduto + ") nใo cadastrado."
			lRetorno := .F.
		EndIf
	
	EndIf
	
	If !lRetorno
		::oGetProd:SetFocus()
	EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValCli           บAutor  ณVendas Clientes     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em validar o cliente informado.			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValCli() Class LJCTesteCargaOrcamento 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	Local oEntSA1	:= Nil				//Objeto do tipo LJCEntCliente
	Local oRetorno	:= Nil				//Retorno da consulta
		
	If Empty(::cCliente) .OR. AllTrim(::cCliente) == ""
		MsgAlert(STR0027) //"Informar o cliente."
		lRetorno := .F.
	Else
	
		oEntSA1 := LJCEntCliente():New()
		
		oEntSA1:DadosSet("A1_COD", ::cCliente)
		
		oRetorno := oEntSA1:Consultar(1)
		
		If oRetorno:Count() == 0
			MsgAlert(STR0028 + ::cCliente + STR0029) //"Cliente (" + ::cCliente + ") nใo cadastrado."
			lRetorno := .F.
		Else
			::lCancelado := .F.
		EndIf
	
	EndIf
	
	If !lRetorno
		::oGetCli:SetFocus()
	EndIf
	
Return lRetorno