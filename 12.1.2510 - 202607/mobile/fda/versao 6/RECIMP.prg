#INCLUDE "RECIMP.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RecImp    ºAutor  ³Marcelo Vieira      º Data ³  16/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Recebimentos por cliente                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SFA CRM 6.0.1                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³                  									      ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RecImp(cCodCli,cLojaCli,aForma)
Local cNumNota := "",cResp := ""
Local nCol :=1
Local nRecb:=Len(aForma)

if nRecb > 0 
	if MsgYesOrNo(STR0001,STR0002) //"Confirma a impressão dos recebimentos ?"###"Impressão"
       ImprimeRC(cCodCli,cLojaCli,aForma,nRecb)              
	else
       Return nil
	endif 
else	
	MsgAlert(STR0003)	 //"Nenhum recebimento para imprimir!"
Endif

Return nil

//Layout de Impressao dos Recebimentos
Function ImprimeRC(cCodCli,cLojaCli,aForma,nRecb)
Local cObs    :=""
Local cNomeCli:=""
Local cEmissao:="",cTipoDoc:="", cDescrTipo:=""
Local nValor  :=0

MsgStatus( STR0004 ) //"Aguarde..."

if File("adprintlib-syslib.prc") .Or. File("Advprint.dll") 
   SET DEVICE TO PRINT		//Direciona p/ impressora
else 
   MsgStop( "impressora não encontrada", "Aviso")   
   Return 
endif

if HA1->( dbSeek(  cCodCli+cLojaCli ) )//Cliente
   cNomeCli:=HA1->A1_NOME
else
   cNomeCli:=STR0005 //"Cliente indefinido"
endif

//Cabec. do Recebimento 
@ Prow()+1,1  PSAY EMP->EMP_NOME
@ Prow()+2,1  PSAY STR0006 //"RECEBIMENTO DO DIA :"
@ Prow()  ,23 PSAY Dtoc( Date() )
@ Prow()+1,1  PSAY STR0007      //"Vendedor"
@ Prow()  ,13 PSAY ": " + HA3->A3_COD + " - " + HA3->A3_NREDUZ
@ Prow()+1,1  PSAY Replicate("_",55) //replicate
@ Prow()+1,1  PSAY cCodCli + "/" + cLojaCli + " " + cNomeCli
cObs := ""
@ Prow()+1,1  PSAY Replicate("_",55) //replicate

//Itens do Recebimento 

For ni:=1 to nRecb

    cEmissao := dToC( aForma[ni,1] )
    cTipoDoc := aForma[ni,2]
    nValor   := aForma[ni,3]     
    
    if cTipoDoc=="EF"   
      cDescrTipo:=STR0008 //"Dinheiro"
    elseif cTipoDoc=="CH"   
      cDescrTipo:=STR0009     //"Cheque"
    elseif cTipoDoc=="TF"   
      cDescrTipo:=STR0010     //"Deposito"
    elseif cTipoDoc=="VL"   
      cDescrTipo:=STR0011     //"Vale"
    endif
    
    @ Prow()+1,1  PSAY cEmissao                //data do pagamento
    @ Prow()  ,10 PSAY cDescrTipo    		     //Tipo de pagamento 
    @ Prow()  ,30 PSAY Str(nValor,8,2)	        //Valor Total do Recebimento
    
Next 

// Caso tenha que acrescentar um resumo 
/*
@ Prow()+2,1 PSAY "base icms    valor icms     Base Calc.icms subst." 
@ Prow()+1,1 PSAY        Transform(HF2->F2_BASEICM,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALICM,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_BRICMS,"@E 9,999.99")   
@ Prow()+1,pCol()+2 PSAY  "Icms Subst.   Vl total dos produtos"
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_ICMSRET,"@E 9,999.99")       
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALMERC,"@E 9,999.99")       
// Na nota oficial tirar esta linha
@ Prow()+2,1 PSAY "Valor frete  valor seguro   outras despesas acess"   
@ Prow()+1,1 PSAY        Transform(HF2->F2_FRETE,"@E 9.999,99")   
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_SEGURO,"@E 9,999.99")   
@ Prow()  ,pCol()+2 PSAY Transform(0,"@E 9,999.99" )                   

@ Prow()  ,pCol()+2 PSAY "Total IPI     Valor Total da nota "
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALIPI,"@E 9,999.99")       
@ Prow()  ,pCol()+2 PSAY Transform(HF2->F2_VALBRUT,"@E 9,999.99")       
*/                       

// Dados Para assinatura 
@ Prow()+2,1 PSAY STR0012 //"Assinatura"
@ Prow()+1,1 PSAY Replicate("_",40) //replicate

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()
Alert(STR0013) //"Impressao finalizada"

Return nil
