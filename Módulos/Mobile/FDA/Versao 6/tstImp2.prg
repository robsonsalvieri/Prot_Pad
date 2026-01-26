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
Local cNumPed := "123456", cResp:=1
Local nLinha := 1

cNumPed:="123456"
// ALERT(cNumPed)
               
// cResp:=MsgYesOrNo("Confirma a impressใo do pedido "+cNumPed+" ?","Impressใo")
// ALERT(cresp)
If cResp = 1
      //  Alert( "vai para imprime") 
		Imprime(cNumPed)          
Else
	MsgAlert("Pedido " + cNumPed + " nใo encontrado!")
Endif

Return nil

//Layout de Impressao do Pedido
Function Imprime(cNumPed)
Local cEntrega := ""
Local cObs := ""
Local n:=1

MsgStatus( "Imprimindo..." )

SET DEVICE TO PRINT		//Direciona p/ impressora
//Cabec. do Pedido
@ Prow(),70  PSAY "X                No 9999999"  
@ Prow()+2,1  PSAY "VENDA MERC.ADQUIR./RECEB.TERC.,EFETUADA FORA DO ESTABEL.       5.15"  

@ Prow()+2,1  PSAY "MICROSIGA SOFTWARE S/A"
@ Prow(),54 PSAY "99.999.999/0001-99        " + DTOC(DATE())
@ Prow()+1,1  PSAY "AV. BRAZ LEME,1631                     JD. SAO BENTO   09663-080"
@ Prow()+1,1  PSAY "SAO PAULO                 (11) 3981-7033        SP"
cObs := " - Nota fiscal em conformidade com o regime especial - obtido em 01/01/2003 para Sao Paulo"

@ Prow()+1,1  PSAY Replicate("_",245) //replicate
//@ Prow()+2,1  PSAY "ITEM"
//@ Prow()  ,6  PSAY "CODIGO"
//@ Prow()  ,21 PSAY "DESCRICAO"
//@ Prow()  ,49 PSAY "QTDE"
//@ Prow()  ,59 PSAY "PRECO"
//@ Prow()  ,69 PSAY "DESC"
//@ Prow()  ,76 PSAY "VLR TOTAL"
//@ Prow()+1,1  PSAY Replicate("_",245) //replicate
                             
While n < 10 

    @ Prow()+1,1   PSAY str(n,3)		 //Nr. Item
	@ Prow()  ,6   PSAY "123456789012345"            //Cod. produto 
                 @ Prow()  ,21  PSAY "AAAAAAAAAABBBBBBBBBBCCCCCCC"	 //Descr. produto
                 @ Prow()  ,48 PSAY Str(123456)	+ " PC"     //Qtde
 	@ Prow()  ,58 PSAY Str(12345,7,2)	 //Preco de venda
	@ Prow()  ,67 PSAY Str(1234,7,2)	 //Descto
	@ Prow()  ,74 PSAY Str(123456789,8,2)	 //Valor Total do Item

	n:=n+1
Enddo

@ Prow()+2,1 PSAY "base icms    valor icms     Base Calc.icms subst.  Icms Subst.   Vl total dos produtos"
@ Prow()+1,1 PSAY "  9999,99       9999,99                 99999,99     99999,99.                9999,99 "
@ Prow()+2,1 PSAY "Valor frete  valor seguro   outras despesas acess   Total IPI     Valor Total da nota "
@ Prow()+1,1 PSAY "  9999,99       9999,99                 99999,99     99999,99.                9999,99 "

@ Prow()+1,1 PSAY "Transportadora: "
@ Prow()+1,1   PSAY "Nosso carro                  SFA-2211         SP"
@ Prow()+1,1   PSAY "................................................"
@ Prow()+1,1 PSAY "Quantidade   Especie        Marca        Numero    Peso Bruto    Peso liquido"

@ Prow()+1,1 PSAY "Reservado ao fisco: "
@ Prow(),13   PSAY UPPER(SUBSTR(cObs,  1,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,101,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,201,100) )
@ Prow()+1,1  PSAY Replicate("_",245) //replicate

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()
Alert("Impressao finalizada")
Return nil
