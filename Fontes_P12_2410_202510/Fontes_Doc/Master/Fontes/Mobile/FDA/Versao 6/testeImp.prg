#include "eadvpl.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTstSipix  บAutor  ณCleber M.           บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Pedido selecionado                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SFA CRM 6.0.1                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ oBrwPedido,aPedido										  ดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista    ณ Data   ณMotivo da Alteracao                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tsipix()
Local cNumPed := "123456",cResp:=1
Local nLinha := 1

cNumPed:="123456"
// ALERT(cNumPed)
               
// cResp:=MsgYesOrNo("Confirma a impressใo do pedido "+cNumPed+" ?","Impressใo")
// ALERT(cresp)
 If cResp = 1
      //  Alert( "vai para imprime") 
		Imprime(cNumPed)          
		Alert( "saiu da imprime")
Else
	MsgAlert("Pedido " + cNumPed + " nใo encontrado!")
Endif

Return nil

//Layout de Impressao do Pedido
Function Imprime(cNumPed)
Local cEntrega := ""
Local cObs := ""
Local n:=1
//Alert( "vai..")
//MsgStatus( "Imprimindo..." )

//Alert( "vai dar setprint" )
SET DEVICE TO PRINT		//Direciona p/ impressora


//Cabec. do Pedido

@ Prow(),1  PSAY "MICROSIGA SOFTWARE S/A"
//Alert("Impressao finalizada 2");

@ Prow()+2,1  PSAY "PEDIDO"
@ Prow()  ,13 PSAY ": " + cNumPed
@ Prow()  ,24 PSAY "EMISSAO : " + Dtoc(date()) 
@ Prow()+1,1  PSAY "CLIENTE"
@ Prow()  ,13 PSAY ": " + "123456/99" 
@ Prow()  ,24 PSAY "-" + "CLIENTE TESTE PARA IMPRESSAO XXXXXX "
@ Prow()+1,1  PSAY "VENDEDOR"     
@ Prow()  ,13 PSAY ": " + "123456 - MARCELO VIEIRA" 
@ Prow()+1,1  PSAY "COND. PAGTO."
@ Prow()  ,13 PSAY ": " + "003 - 30 DIAS "
@ Prow()  ,40 PSAY "TABELA : " + "001"
@ Prow()+1,1  PSAY "TRANSPORTADOR" 
@ Prow()  ,13 PSAY ": " + "123456 - " + "TRANSPORTADOR LEVA E TRAZ"
cObs := "MENSAGEM PARA O FATURAMENTO MENSAGEM PARA O FATURAMENTOMENSAGEM PARA O FATURAMENTOMENSAGEM PARA O FATURAMENTO"
@ Prow()+1,1  PSAY Replicate("_",245) //replicate
@ Prow()+2,1  PSAY "ITEM"
@ Prow()  ,6  PSAY "CODIGO"
@ Prow()  ,21 PSAY "DESCRICAO"
@ Prow()  ,49 PSAY "QTDE"
@ Prow()  ,59 PSAY "PRECO"
@ Prow()  ,69 PSAY "DESC"
@ Prow()  ,78 PSAY "VLR TOTAL"
@ Prow()+1,1  PSAY Replicate("_",245) //replicate
                             
While n < 65 

    @ Prow()+1,1   PSAY str(n,3)		 //Nr. Item
	@ Prow()  ,6   PSAY "123456789012345"            //Cod. produto 
                 @ Prow()  ,21  PSAY "AAAAAAAAAAAAAAABBBBBBBBBBBBB"	 //Descr. produto
                 @ Prow()  ,48 PSAY Str(123456)	     //Qtde
 	@ Prow()  ,58 PSAY Str(12345,7,2)	 //Preco de venda
	@ Prow()  ,67 PSAY Str(1234,7,2)	 //Descto
	@ Prow()  ,76 PSAY Str(123456789,8,2)	 //Valor Total do Item

	//cEntrega := HC6->C6_ENTREG 
	//HC6->(dbSkip())
	n:=n+1
Enddo

@ Prow()+2,1 PSAY "TOTAL PEDIDO  : "
@ Prow(),13  PSAY Str(123456789,9,2) //Picture "@E 9,999,999.99" 

@ Prow()+1,1 PSAY "DATA ENTREGA : "
@ Prow(),13 PSAY Dtoc(DATE()+10)

@ Prow()+1,1 PSAY "OBSERVACAO   : "
@ Prow(),13   PSAY UPPER(SUBSTR(cObs,  1,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,101,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,201,100) )
@ Prow()+1,1  PSAY Replicate("_",245) //replicate

SET DEVICE TO SCREEN	//Redireciona p/ tela
Alert( "seta para tela e fim")

ClearStatus()
Alert("Impressao finalizada")
Return nil
