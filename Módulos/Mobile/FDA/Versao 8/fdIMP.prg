#INCLUDE "FDIMP.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVImp     บAutor  ณCleber M.           บ Data ณ  15/05/03   บฑฑ
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
Function PVImp(oBrwPedido,aPedido)
Local cNumPed := "",cResp := ""
Local nLinha := GridRow(oBrwPedido)
Local nCol:=1

if Len(aPedido) <= 0 .Or. nLinha <= 0
	MsgAlert(STR0001) //"Nenhum Pedido Selecionado para imprimir!"
	Return nil
Endif
cNumPed:=aPedido[nLinha,1]
               
dbSelectArea("HC5")
dbSetOrder(1)
dbSeek(RetFilial("HC5")+cNumPed)
If HC5->(Found())
    cResp:=If(MsgYesOrNo(STR0002+cNumPed+" ?",STR0003),"Sim","Nใo") //"Confirma a impressใo do pedido "###"Impressใo"
    If cResp == "Sim"
    
		HCF->( dbSetOrder(1) )
		HCF->( dbSeek(RetFilial("HCF")+"MV_PRINTER") )
		If HCF->(Found()) .And. Val(HCF->HCF_VALOR) == 2 //Impressora Monarch (2)
			ImpMonarch(cNumPed,aPedido,nLinha)
		Else // Impressora Sipix (1 = default)
			Imprime(cNumPed,aPedido,nLinha)
		Endif 
		
	Endif
Else
	MsgAlert("Pedido " + cNumPed + STR0004) //" nใo encontrado!"
Endif

Return nil


//Layout de Impressao do Pedido
Function Imprime(cNumPed,aPedido,nLinha)
Local cEntrega := ""
Local cObs := ""

MsgStatus( STR0005 ) //"Aguarde..."

if File("adprintlib-syslib.prc") .Or. File("Advprint.dll") 
   SET DEVICE TO PRINT		//Direciona p/ impressora
else 
   MsgStop( "impressora nใo encontrada", "Aviso")   
   Return 
endif

HA1->( dbSeek(RetFilial("HA1")+HC5->HC5_CLI+HC5->HC5_LOJA) )	//Cliente
HA3->( dbSeek(RetFilial("HA3")+HC5->HC5_VEND1) )				//Vendedor
HE4->( dbSeek(RetFilial("HE4")+HC5->HC5_COND) )				//Condicao de Pagto
HA4->( dbSeek(RetFilial("HA4")+HC5->HC5_TRANSP) )			//Transportadoras
HTC->( dbSeek(RetFilial("HTC")+HC5->HC5_TAB) )			    //Tabela de Preco

//Cabec. do Pedido
@ 0,1 PSAY EMP->EMP_NOMCOM
@ Prow()+2,1  PSAY STR0006 //"PEDIDO"
@ Prow()  ,13 PSAY ": " + cNumPed
@ Prow()  ,24 PSAY STR0007 + Dtoc(HC5->HC5_EMISS)  //"EMISSAO : "
@ Prow()+1,1  PSAY STR0008 //"CLIENTE"
@ Prow()  ,13 PSAY ": " + HC5->HC5_CLI + "/" + HC5->HC5_LOJA
@ Prow()  ,24 PSAY "-" + HA1->HA1_NOME
@ Prow()+1,1  PSAY STR0009      //"VENDEDOR"
@ Prow()  ,13 PSAY ": " + HC5->HC5_VEND1 + " - " + HA3->HA3_NREDUZ
@ Prow()+1,1  PSAY STR0010 //"COND. PAGTO."
@ Prow()  ,13 PSAY ": " + HC5->HC5_COND + " - " + HE4->HE4_DESCRI
@ Prow()  ,40 PSAY STR0011 + HC5->HC5_TAB + " - " + HTC->HTC_DESCRI //"TABELA : "
@ Prow()+1,1  PSAY STR0012  //"TRANSPORTADOR"
@ Prow()  ,13 PSAY ": " +  HC5->HC5_TRANSP + " - " + HA4->HA4_NOME
cObs := HC5->HC5_MENNOTA
@ Prow()+1,1  PSAY Replicate("_",245) //replicate
@ Prow()+2,1         PSAY STR0013 //"ITEM"
@ Prow()  ,6  PSAY STR0014 //"CODIGO"
@ Prow()  ,21 PSAY STR0015 //"DESCRICAO"
@ Prow()  ,49 PSAY STR0016 //"QTDE"
@ Prow()  ,59 PSAY STR0017 //"PRECO"
@ Prow()  ,69 PSAY STR0018 //"DESC"
@ Prow()  ,75 PSAY STR0019 //"VLR TOTAL"
@ Prow()+1,1  PSAY Replicate("_",245) //replicate
                              
//Itens do Pedido
dbSelectArea("HC6")
dbSetOrder(1)
dbSeek(RetFilial("HC6")+cNumPed)
While !Eof() .And. HC6->HC6_FILIAL == RetFilial("HC6") .And. HC6->HC6_NUM == cNumPed
	HB1->( dbSeek(RetFilial("HB1")+HC6->HC6_PROD) )

    @ Prow()+1,1  PSAY HC6->HC6_ITEM		         //Nr. Item
	@ Prow()  ,6  PSAY HC6->HC6_PROD             //Cod. produto
    @ Prow()  ,21 PSAY HB1->HB1_DESC	             //Descr. produto
  
    @ Prow()  ,45 PSAY Str(HC6->HC6_QTDVEN,6,2)	 //Qtde
 	@ Prow()  ,58 PSAY Str(HC6->HC6_PRCVEN,7,2)	 //Preco de venda
	@ Prow()  ,67 PSAY Str(HC6->HC6_DESC,7,2)	 //Descto
	@ Prow()  ,76 PSAY Str(HC6->HC6_VALOR,8,2)	 //Valor Total do Item

	cEntrega := HC6->HC6_ENTREG 
	HC6->(dbSkip())
Enddo

@ Prow()+2,1 PSAY STR0020 //"TOTAL PEDIDO  : "
@ Prow(),13  PSAY Str(HC5->HC5_VALOR,9,2) //Picture "@E 9,999,999.99" 

@ Prow()+1,1 PSAY STR0021 //"DATA ENTREGA : "
@ Prow(),13 PSAY Dtoc(cEntrega)

@ Prow()+1,1 PSAY STR0022 //"OBSERVACAO   : "
@ Prow(),13   PSAY UPPER(SUBSTR(cObs,  1,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,101,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,201,100) )
@ Prow()+1,1  PSAY Replicate("_",245) //replicate

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()
Alert(STR0023) //"Impressao finalizada"
Return nil


//Layout de impressao especifico p/ impressora Monarch
Function ImpMonarch(cNumPed,aPedido,nLinha)
Local cEntrega := ""
Local cObs := "", nTotItem := 0

MsgStatus( STR0005 ) //"Aguarde..."

SET DEVICE TO PRINT		//Direciona p/ impressora

HA1->( dbSeek(RetFilial("HA1")+HC5->HC5_CLI+HC5->HC5_LOJA) )	//Cliente
HA3->( dbSeek(RetFilial("HA3")+HC5->HC5_VEND1) )				//Vendedor
HE4->( dbSeek(RetFilial("HE4")+HC5->HC5_COND) )				//Condicao de Pagto
HA4->( dbSeek(RetFilial("HA4")+HC5->HC5_TRANSP) )			//Transportadoras
HTC->( dbSeek(RetFilial("HTC")+HC5->HC5_TAB) )			    //Tabela de Preco

//Cabec. do Pedido
@ Prow(),1 PSAY "            "
@ Prow(),1 PSAY "            "
@ Prow()+1,1 PSAY EMP->EMP_NOMCOM
@ Prow()+2,1  PSAY STR0024 + cNumPed + STR0025 + Dtoc(HC5->HC5_EMISS)  //"PEDIDO: "###"		EMISSAO: "
@ Prow()+1,1  PSAY STR0026 + HC5->HC5_CLI + "/" + HC5->HC5_LOJA + "-" + Alltrim(HA1->HA1_NOME) //"CLIENTE: "
@ Prow()+1,1  PSAY STR0027 + HC5->HC5_VEND1 + "-" + Alltrim(HA3->HA3_NREDUZ) //"VENDEDOR: "
@ Prow()+1,1  PSAY STR0028 + HC5->HC5_COND + "-" + Alltrim(HE4->HE4_DESCRI) //"COND. PAGTO.: "
@ Prow()+1,1  PSAY STR0029 + HC5->HC5_TAB + "-" + Alltrim(HTC->HTC_DESCRI) //"TABELA: "
@ Prow()+1,1  PSAY STR0030 + HC5->HC5_TRANSP + "-" + Alltrim(HA4->HA4_NOME) //"TRANSP.: "

cObs := HC5->HC5_MENNOTA
@ Prow()+1,1  PSAY Replicate("_",42)
@ Prow()+1,1  PSAY STR0031 +  STR0032 + STR0033  //"ITEM  "###"COD   "###"DESCRICAO  "
@ Prow()+1,1  PSAY STR0034   //"QTDE  X  PRECO  -  DESC  =  VLR.TOTAL"
@ Prow()+1,1  PSAY Replicate("_",42)
                              
//Itens do Pedido
dbSelectArea("HC6")
dbSetOrder(1)
dbSeek(RetFilial("HC6")+cNumPed)
While !Eof() .And. HC6->HC6_FILIAL == RetFilial("HC6") .And. HC6->HC6_NUM == cNumPed
	HB1->( dbSeek(RetFilial("HB1")+HC6->HC6_PROD) )

    @ Prow()+1,1  PSAY HC6->HC6_ITEM	 + " " + Alltrim(HC6->HC6_PROD) + " " + HB1->HB1_DESC
	// Total item = qtde * (preco - (preco * (desct / 100)))
	If HC6->HC6_DESC > 0
		nTotItem := HC6->HC6_QTDVEN * Round((HC6->HC6_PRCVEN - (HC6->HC6_PRCVEN * (HC6->HC6_DESC / 100))),2)
    	@ Prow()+1,1 PSAY Str(HC6->HC6_QTDVEN,5,2)	+ " X " + Str(HC6->HC6_PRCVEN,7,2) + " - " + Str(HC6->HC6_DESC,3,2)	+ "%  = " + Str(nTotItem,8,2)
	Else
    	@ Prow()+1,1 PSAY Str(HC6->HC6_QTDVEN,5,2)	+ " X " + Str(HC6->HC6_PRCVEN,7,2) + " - " + Str(HC6->HC6_DESC,3,2)	+ "%  = " + Str(HC6->HC6_VALOR,8,2)	
	Endif

	cEntrega := HC6->HC6_ENTREG 
	HC6->(dbSkip())
Enddo

@ Prow()+1,1 PSAY Replicate("_",42) 
@ Prow()+1,1 PSAY STR0035 + Str(HC5->HC5_VALOR,9,2) //"TOTAL PEDIDO: "
@ Prow()+1,1 PSAY STR0036 + Dtoc(cEntrega) //"DATA ENTREGA: "

@ Prow()+1,1 PSAY STR0037 + UPPER(cObs) //"OBS.: "
@ Prow()+1,1 PSAY Replicate("_",42) 
@ Prow()+1,1 PSAY "      " 
@ Prow()+1,1 PSAY "      " 
@ Prow()+1,1 PSAY "      " 
@ Prow()+1,1 PSAY "      " 

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()
Alert(STR0023) //"Impressao finalizada"
Return nil
