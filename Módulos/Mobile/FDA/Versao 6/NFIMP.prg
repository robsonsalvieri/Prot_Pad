#INCLUDE "NFIMP.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณNFImp     บAutor  ณMarcelo Vieira      บ Data ณ  28/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Nota fiscal selecionada ( exemplo em Sipix)         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SFA CRM 6.0.1                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ oBrwNota,aNotas										      ดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista    ณ Data   ณMotivo da Alteracao                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function NFImp(oBrwNotas,aNotas)
Local cNumNota := "",cResp := ""
Local nLinha := GridRow(oBrwNotas)
Local nCol:=1

if Len(aNotas) <= 0 .Or. nLinha <= 0
	MsgAlert(STR0001) //"Nenhuma nota Selecionada para imprimir!"
	Return nil
Endif
cNumNota:=aNotas[nLinha,1]
               
dbSelectArea("HF2")
dbSetOrder(1)
dbSeek(cNumNota)
If HF2->(Found())
    cResp:=If(MsgYesOrNo(STR0002+cNumNota+" ?",STR0003),"Sim","Nใo") //"Confirma a impressใo da nota "###"Impressใo"
    If cResp == "Sim"
		ImprimeNF(cNumNota,aNotas,nLinha)
	Endif
Else
	MsgAlert(STR0004 + cNumNota + STR0005) //"Nota "###" nใo encontrada!"
Endif

Return nil


//Layout de Impressao do Pedido
Function ImprimeNF(cNumNota,aNotas,nLinha)
Local cObs := ""

MsgStatus( STR0006 ) //"Aguarde..."

if File("adprintlib-syslib.prc") .Or. File("Advprint.dll") 
   SET DEVICE TO PRINT		//Direciona p/ impressora
else 
   MsgStop( "impressora nใo encontrada", "Aviso")   
   Return 
endif

HA1->( dbSeek(HF2->F2_CLIENTE+HF2->F2_LOJA) )	//Cliente
HA3->( dbSeek(HF2->F2_VEND1) )				//Vendedor
HE4->( dbSeek(HF2->F2_COND) )				//Condicao de Pagto
HA4->( dbSeek(HF2->F2_TRANSP) )			//Transportadoras

//Cabec. da Nota
@ Prow(),20   PSAY "X"
@ Prow(),35  PSAY cNumNota
@ Prow()+2,1  PSAY STR0007   //"VENDA MERC.ADQUIR./RECEB.TERC.,EFETUADA FORA DO ESTABEL. 5.15"

@ Prow()+2,1  PSAY HF2->F2_CLIENTE + "/" + HF2->F2_LOJA + " " + HA1->A1_NOME
@ Prow()+1,1  PSAY HA1->A1_CGC  + DTOC(HF2->F2_EMISSAO)
@ Prow()+1,1  PSAY HA1->A1_END  + " " + HA1->A1_BAIRRO + "  " + HA1->A1_CEP
@ Prow()+1,1  PSAY HA1->A1_MUN  + " " + HA1->A1_TEL    + "  " + HA1->A1_EST
@ Prow()+1,1  PSAY HA1->A1_INSCR

cObs := STR0008 //" - Nota fiscal em conformidade com o regime especial - obtido em 01/01/2003 para Sao Paulo"
@ Prow()+1,1  PSAY Replicate("_",40) //replicate

//Itens do Pedido
dbSelectArea("HD2")
dbSetOrder(1)
dbSeek(cNumNota)   
While HD2->(!Eof()) .And. HD2->D2_DOC == cNumNota
	  HB1->( dbSeek(HD2->D2_COD) )

      dbSelectArea("HD2")
      @ Prow()+1,1   PSAY HD2->D2_ITEM		 //Nr. Item
      @ Prow()  ,6   PSAY HD2->D2_COD       //Cod. produto
      @ Prow()  ,21  PSAY HD2->D2_DESCR     //Descr. produto

      @ Prow()+1,1  PSAY Str(HD2->D2_QUANT)	     //Qtde
 	  @ Prow()  ,10 PSAY Str(HD2->D2_PRCVEN,7,2)	 //Preco de venda
	  @ Prow()  ,20 PSAY Str(HD2->D2_DESC,7,2)	     //Descto
	  @ Prow()  ,30 PSAY Str(HD2->D2_TOTAL,8,2)	 //Valor Total do Item

	 HD2->(dbSkip())
Enddo

// Na nota oficial tirar esta linha
@ Prow()+2,1 PSAY STR0009  //"base icms    valor icms     Base Calc.icms subst."
@ Prow()+1,1 PSAY        Transform(HF2->F2_BASEICM,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALICM,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_BRICMS,"@E 9,999.99")   
@ Prow()+1,pCol()+2 PSAY  STR0010 //"Icms Subst.   Vl total dos produtos"
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_ICMSRET,"@E 9,999.99")       
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALMERC,"@E 9,999.99")       
// Na nota oficial tirar esta linha
@ Prow()+2,1 PSAY STR0011    //"Valor frete  valor seguro   outras despesas acess"
@ Prow()+1,1 PSAY        Transform(HF2->F2_FRETE,"@E 9.999,99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_SEGURO,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(0,"@E 9,999.99" )                   

@ Prow()  ,pCol()+2 PSAY STR0012 //"Total IPI     Valor Total da nota "
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALIPI,"@E 9,999.99")       
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALBRUT,"@E 9,999.99")       

// Dados do Transportador
@ Prow()+2,1 PSAY STR0013 //"Transportadora: "
@ Prow()+1,1 PSAY STR0014 //"Nosso carro                  SFA-99999         SP"
@ Prow()+1,1 PSAY "................................................"
@ Prow()+1,1 PSAY STR0015 //"Quantidade   Especie        Marca        Numero "
@ Prow()+2,1 PSAY STR0016 //"Peso Bruto    Peso liquido"
@ Prow()+1,1 PSAY STR0017 //"Reservado ao fisco: "
@ Prow(),13   PSAY UPPER(SUBSTR(cObs,  1,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,101,100) )
@ Prow()+1,13 PSAY UPPER(SUBSTR(cObs,201,100) )
@ Prow()+1,1  PSAY Replicate("_",45) //replicate

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()
Alert(STR0018) //"Impressao finalizada"

Return nil
