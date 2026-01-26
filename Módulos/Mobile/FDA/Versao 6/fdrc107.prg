#INCLUDE "FDrc107.ch"

/*********************************************************************************/
/* Funcao: ConsultaCQ                                                            */
/* Realiza a consulta do cheque                                                  */
/*********************************************************************************/
Function ConsultaCQ(aItems)
Local nCon    := 0
Local cFunc   := "U_CHQ001" 
Local cRetRpc := ""
Local cCheques:= "" 
Local nCheques                      
Local cLin_ind,cLin_txt,nCorta,nIndArray

nCheques:=Len(aItems)

If Len(aItems)=0
   MsgAlert( STR0001,STR0002) //"Nao existem cheques para consultar"###"Aviso"
   Return nil
Else
  // tirar depois
    //Converte o Array de itens para string
    //              1   2     3        4    5       6      7       8    9     10   11   12
    //AADD(aItems,{.t.,cBanco,cAgencia,cCta,cCheque,nValor,dVencto,cCli,cCnpj,cMes,cAno,nDias

    For n:=1 to nCheques
        cCheques+=alltrim(strzero(n,4))     // Indice do array
        ccheques+=aItems[n,2] 				// Banco
        ccheques+="|"
        ccheques+=aItems[n,3] 				// Agencia
        ccheques+="|"
        ccheques+=aItems[n,4] 				// Nr da Conta
        ccheques+="|"
        ccheques+=ALLTRIM(Str(aItems[n,6],11))   //Valor com centavos
        ccheques+="|"
        ccheques+=DtoS(aItems[n,7])       // Data de vencimento
        ccheques+="|"
        ccheques+=aItems[n,8]             // Nome do Cliente
        ccheques+="|"
        ccheques+=aItems[n,9]             //Cgc/CPF
        ccheques+="|"
        ccheques+=aItems[n,10]            //Mes da abertura da conta
        ccheques+="|"
        ccheques+=aItems[n,11]            //Ano da abertura da conta 
    Next    

    ALERT( cCheques )
    
	// Faz a Conexao com o Servidor
	
    //alert(2)
	nCon := connectserver()
	
    //Alert( "Resultado da conexao:" + str(nCon,4) )
	If nCon != 0
		// Executa a funcao do Protheus         
		cRetRpc := rpcprotheus( nCon , cFunc , ccheques )
		// Diconecta do Servidor
		disconnectserver(nCon)
		MsgAlert(STR0003 + cRetRpc, "" ) //"Resultado da Consulta = "
	Else                                                   
	         
		MsgAlert(STR0004, STR0005 +str(nCon,4)) //"Não foi possivel conectar ao servidor"###"Conexão"
	EndIf
//tirar depois	
EndIf


//Retorno da consulta 
cRetorno:="0001Reprovado0002Aprovado 0003Reprovado"
// Com Base na String de Retorno os cheques serao 
While Len(cRetorno)>0                
      //Pega a posicao do array para atualizar
      cLin_ind:=Substr(cRetorno,1,4)         
      //Pega a posicao do array para atualizar
      cLin_txt:=Substr(cRetorno,5,9) 
      //Quantos caracteres teremos que cortar da string
      nCorta:=Len(cLin_ind+clin_txt)+1 
      nIndArray:=Val(cLin_ind)      
      // Grava no Cheque correspondente o retorno da consulta
      aItems[nIndArray,1]:= cLin_txt    
      // Tira da string o pedaco que nao precisa mais
      cRetorno:=Substr(cRetorno,nCorta) 
Enddo

Return nil

/*********************************************************************************/
/* Funcao: ExcCheque                                                             */
/* Realiza a exclusao do cheque dos itens                                        */
/*********************************************************************************/
Function ExcCheque(oBrw,aItems,nSaldo,oSaldo,aCheqsBx)
Local nRec, nValor
nRec:=0
nValor:=0
if len(aitems)=0
   Alert(STR0006) //"Nao existem itens para excluir"
   Return nil
endif
nRec:=GridRow(oBrw)
nValor:=aItems[nRec,6]

// Devolve o valor excluido ao valor da divida.
nSaldo:=nSaldo+ nValor

aDel(aItems,nRec )
aSize(aItems,(len(aItems)-1) )
SetArray(oBrw,aItems)
SetText( oSaldo,nSaldo)

// Clono o Array para depois usar na gravacao da Baixa os Cheques 
//aCheqsBx := aClone(aItems)


Return nil

/*********************************************************************************/
/* Funcao: CalculaPM                                                             */
/* Realiza o Calculo do prazo medio												 */
/*********************************************************************************/
Function CalculaPM(aItems)
Local oDlg
Local oTotal,oMnu,oItem,oPrazoM,oBtnPrint 
Local nTotal,nPrazoM,nPercVP,n,nx
Local oMtr1,oMtr2,oMtr3,oMtr4
Local nMeter1:=0,nMeter2:=0,nMeter3:=0,nMeter4:=0,nRange
Local oMtr1Perc,oMtr2Perc,oMtr3Perc,oMtr4Perc

nTotal :=0
nPrazoM:=0 

If Len(aItems)=0  
   MsgAlert( STR0007,STR0008) //"Nao existem cheques para calcular o prazo medio"###"Atencao"
   Return Nil
endif

DEFINE DIALOG oDlg TITLE STR0009 //"Calculo Prazo Medio"
ADD MENUBAR oMnu CAPTION STR0010 OF oDlg  //"Opções"
ADD MENUITEM oItem CAPTION STR0011 ACTION CloseDialog() OF oMnu  //"Retorna"

// Busca Valor Total 
nRange:=Len(aItems)
For n:=1 to Len(aItems)
    nTotal:=nTotal+aItems[n,6] 

    //calculo para grafico
    if aItems[n,12] <= 30
       nMeter1 := nMeter1 + 1 
    elseif aItems[n,12] > 30 .And. aItems[n,12] <= 60
       nMeter2 := nMeter2 + 1 
    elseif aItems[n,12] > 60 .And. aItems[n,12] <= 90
       nMeter3 := nMeter3 + 1
    else
       nMeter4 := nMeter4 + 1 
    endif
Next 

//Calcula valor por valor sobre o total
For nx:=1 to Len(aItems)                             
    nPercVP:=(aItems[nx,6]/nTotal)*100
    nPrazoM:=nPrazoM+(nPercVP*aItems[nx,6])
Next 
nPrazoM:=nPrazoM/100

@ 25,05 SAY STR0012 OF oDlg //"Total"
@ 25,49 SAY oTotal VAR nTotal PICTURE "@E 999,999.99" OF oDlg

@ 40,05 SAY STR0013 OF oDlg //"Prazo Médio"
@ 40,66 SAY oPrazoM VAR nPrazoM  PICTURE "@E 9999.99999"  OF oDlg

@ 55,02 SAY STR0014 +Str(nRange,5)  OF oDlg    //"Total de Cheques: "
@ 65,02 SAY STR0015 OF oDlg                         //" 30 dias"
@ 65,132 SAY  oMtr1Perc VAR nMeter1 PICTURE "@E 9999" OF oDlg
@ 69,40 METER oMtr1 SIZE 90,5 FROM 0 TO nRange OF oDlg
@ 75,02 SAY STR0016 OF oDlg //" 60 dias"
@ 75,132 SAY  oMtr2Perc VAR nMeter2 PICTURE "@E 9999" OF oDlg
@ 79,40 METER oMtr2 SIZE 90,5 FROM 0 TO nRange  OF oDlg
@ 85,02 SAY STR0017 OF oDlg //" 90 dias"
@ 85,132 SAY  oMtr3Perc VAR nMeter3 PICTURE "@E 9999" OF oDlg
@ 89,40 METER oMtr3 SIZE 90,5 FROM 0 TO nRange OF oDlg
@ 95,02 SAY STR0018 OF oDlg //"120 dias"
@ 95,132 SAY  oMtr4Perc VAR nMeter4 PICTURE "@E 9999" OF oDlg
@ 99,40 METER oMtr4 SIZE 90,5 FROM 0 TO nRange OF oDlg

@ 140,75 BUTTON oBtnPrint CAPTION BTN_BITMAP_PRINTER SYMBOL ACTION ImpCheq(aItems,nPrazoM,nTotal) CANCEL OF oDlg

//if File("ADVPRINTLIB-SYSLIB.PRC") .OR. FILE("A6PrinterLib.PRC") .OR. FILE("ADVPRINT.DLL")
//   EnableControl(oBtnPrint)
//Else
//   DisableControl(oBtnPrint)
//Endif   

// Atualiza os valores na tela 
SetText(oMtr1Perc,nMeter1)
SetText(oMtr2Perc,nMeter2)
SetText(oMtr3Perc,nMeter3)
SetText(oMtr4Perc,nMeter4)

// Divide pelo Total de Cheques
SetMeter(oMtr1,nMeter1)
SetMeter(oMtr2,nMeter2)
SetMeter(oMtr3,nMeter3)
SetMeter(oMtr4,nMeter4)       

ACTIVATE DIALOG oDlg

Return nil

/*********************************************************************************/
Function FldChq1(aObjs)
Local n
For n:=1 to Len(aObjs)
   ShowControl(aObjs[n])
Next    
Return 

/*********************************************************************************/
Function FldChq2(aObjs,aGets)
Local n

For n:=1 to Len(aObjs)
    HideControl(aObjs[n])
Next    

Return  

/*********************************************************************************/
/* Funcao: ImpCheq                                                               */
/* Realiza a impressao do Cheque												 */
/*********************************************************************************/
Function ImpCheq( aItems,nPrazoM,nTotal)
Local nItens:=1, n  
Local cColuna2,cColuna3,cColuna4,cColuna5,cColuna6,cColuna7

MsgStatus( STR0019) //"Aguarde impressao..."
SET DEVICE TO PRINT

@ Prow()+2,1 PSAY STR0020 + DTOC(DATE())  //"RELACAO DE CHEQUES - "
@ prow()+1 ,1  PSAY Replicate("=",80) 

@ Prow()+1,1  PSAY STR0021 //"BCO"
@ Prow()  ,5  PSAY STR0022 //"CHEQUE"
@ Prow()  ,10 PSAY STR0023 //"VALOR"
@ Prow()  ,18 PSAY STR0024 //"VENCTO"
@ Prow()  ,23 PSAY STR0025 //"PZM"
@ Prow()  ,26 PSAY STR0026 //"CGC/CPF"

for n:=1 to Len(aItems)                 
    //Transfere valores convertendo para caracteres do arrey para variaveis
    cColuna2:=	aitems[n,2]  
    cColuna3:=	aitems[n,3]  
    cColuna4:=	Transform(aitems[n,6],"@E 999,999.99")
    cColuna5:=	DtoC(aitems[n,5])  
    cColuna6:=	Str(aitems[n,6],4)    
    cColuna7:=	aitems[n,7]    

    @ prow()+1,01  PSAY cColuna2
    @ prow()  ,05  PSAY cColuna3
    @ prow()  ,10  PSAY cColuna4
    @ prow()  ,18  PSAY cColuna5
    @ prow()  ,23  PSAY cColuna6
    @ prow()  ,26  PSAY cColuna7          

Next
@ prow()+1 ,1 PSAY Replicate("=",80) 

@ prow()+1 ,1 PSAY STR0027 //"Valor Total: "
@ Prow()   ,8 PSAY Transform(nTotal,"@E 999,999.99")

@ prow()+1 ,1 PSAY STR0028 //"Prazo Medio: "
@ Prow()   ,8 PSAY STR( nPrazoM,6,6) 

SET DEVICE TO SCREEN 

ClearStatus()        

Return Nil

/*-------------------------*/
// Funcao cria arquivo 
/*-------------------------*/
Function CriaChq()
Local aCheques := {}

aadd( aCheques,{"chq_dbase"  ,"D",  8,   0 })
aadd( aCheques,{"chq_banco"  ,"C",  3,   0 })
aadd( aCheques,{"chq_agenc"  ,"C",  3,   0 })
aadd( aCheques,{"chq_numer"  ,"C",  3,   0 })
aadd( aCheques,{"chq_valor"  ,"N", 10,   2 })
aadd( aCheques,{"chq_vencto" ,"D",  8,   0 })
aadd( aCheques,{"chq_cgccpf" ,"C", 14,   0 })

dbCreate( "CHQ001", aCheques,"LOCAL")             
USE CHQ001 ALIAS CHQ SHARED NEW VIA "LOCAL"
INDEX ON DTOS(chq_dbase)+chq_banco+chq_agenc+chq_numer TO CHQ0011

/*-----------------------------*/
// Consulta do Cheque via RPC  */
/*-----------------------------*/