#INCLUDE "FDnf104.ch"
#include "eADVPL.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±
±± @1.  NFPrepNot -> Funcao que Prepara a Nota Saida da tela de Pedido
±± @2.  NFNumNot -> Captura o Codigo do Pedido do Array na Linha Selecionada
±±      (Caso seja Alteracao ou Ult. Pedidos)
±± @3.  PVProxPed -> Controle da Faixa de Cod. de Pedido, capturando o CodProxPed 
±± @4.  PVAtuaProxPed -> Controle da Faixa de Cod. de Pedido, atualizando o CodProxPed 
±± @5.  Funcoes de Carga e Manipulacao dos Arrays do Mod. do Pedido 
±± 		(Carrega ComboBox do InitPedido)
±± @5A. PVCrgCond -> Carga das Condicoes de Pagto.
±± @5B. PVCrgTab -> Carga das Tabelas de Preco
±± @5C. PVCrgTes -> Carga do Tes
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ Prep. Notas         ≥Autor-Marcelo Vieira ≥ Data ≥23/07/03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Modulo de Notas                                            ≥±±
±±≥          ≥ NFPreNot  -> Prepara a Nota de Saida da Tela de Notas      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFA PRONTA ENTFEGA 6.0                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥NOperacao 1- Inclusao /2 - Alteracao /3 -                   ¥±±
±±≥          ≥4 -                                                         ¥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista    ≥ Data   ≥Motivo da Alteracao                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function NFPrepNot(nOperacao,oBrwNotas,aNotas,cNumNot,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente)
//Variaveis Locais
Local aCabNot	:= {}, aIteNot	:= {}, aColIteNf := {}, aCond :={}, aTab	:= {}
Local cObs := "", cNumNotSrc := "", cCondicao:="" ,cSTATUS:="", cTPFrete:=""
Local nTotNot :=0.00, nRTotNot :=0.00 //NRTotNot Total da Nota Arrendondada
Local nCond	:= 1, nTab := 1, nI:=1, cGeraDup:="N"
Local cDoc:="",cSerie:="",cDupli:="",dEmissao:=Date(),cEst:="", cTipo:=""
Local nFrete:=0,nSeguro:=0,nIcmFrete:=0,cTipoCLi:="", nValBrut:=0,nValICM:=0
Local nBaseIcm:=0,nValIpi:=0,nBaseIPI:=0,nValMerc:=0, nDescont:=0,nIcmsRet:=0,nPliqui:=0          
Local nPBruto:=0, cTransp:="", cVend1:="", cOk:="", cFimp:="", cFilial:="",nBaseISS:=0
Local nValIss:=0, nValFat:=0,nBRicms:=0, cPrefixo:=0,nValCofi:=0, nValPIS:=0,nValIRRF:=0
Local nSeqCar:=0, nBaseINS:=0,dDtEntr:=ctod(""),cTipoDoc:="",cDupl:="",nICMFREt:=0,cTabela:="",cFpgto:=""
Local cNovaNF:="000001"  
Local cNf    :="" 

SET DATE BRITISH 
SET DELETE ON

cNf:=GridRow(oBrwNotas)
                                     
If nOperacao==2  

   /*If Len(aNotas)=0
      MsgAlert("Nenhuma Nota Selecionada para ser alterada","Aviso" ) 
	  Return Nil
   Endif*/
	If !NFNumNF(oBrwNotas,aNotas,@cDoc)
		return nil	
	Endif
	cSerie := AllTrim(GetParam("MV_SERIEPE","RUA"))
	
	If Alltrim(aNotas[cNf,3])==STR0001  //"Transmitida"
		msgAlert(STR0002 , STR0003  )    //"Nota ja transmitida, nao pode ser alterada"###"Atencao"
 		Return
	Endif
Endif   


// Verifica se existe alguma ocorrencia de nao positivacao
dbSelectArea("HA1")
dbSetOrder(1)
If dbSeek(cCodCli + cLojaCli)
	If HA1->A1_FLGVIS = "2"  //.OR. HA1->A1_FLGVIS = "4"
		If MsgYesorNo(STR0004, STR0005) //"Existe ocorrencia para este cliente. Deseja exclui-la ?"###"Ocorrencia"
		    //ACGrvTabOco(cCodPer,cCodRot,cIteRot,"0",cOco,)
			ACGrvTabOco("",cCodRot,cIteRot,"0","",)
			GrvAtend(4, , "", HA1->A1_COD, HA1->A1_LOJA,)
			aClientes[nCliente,1]:=STR0006 //"NOTA"
		Else
			Return Nil
		EndIf
	EndIf
EndIf

// ---------------------- < - >  CABECALHO DA NOTA < - > ----------------------
/*    
Informacoes do Array do Cabec. da Nota
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos (Campo da Tabela Associado HF2)
Linha Descricao
1 - 
2 -
3 -
*/
//Abre as tabelas de Notas ( Cab e Itens )

dbSelectarea("HF2")
AADD(aCabNot,{cDoc     ,HF2->(FieldPos("F2_DOC"))})         //1
AADD(aCabNot,{nOperacao,0                         })         //2
AADD(aCabNot,{cSerie   ,HF2->(FieldPos("F2_SERIE"))    })   //3
AADD(aCabNot,{cCodCli  ,HF2->(FieldPos("F2_CLIENTE"))  })   //4
AADD(aCabNot,{cLojaCli ,HF2->(FieldPos("F2_LOJA"))     })   //5
AADD(aCabNot,{cCondicao,HF2->(FieldPos("F2_COND"))     })   //6
AADD(aCabNot,{cTabela  ,HF2->(FieldPos("F2_TABELA"))   })   //7
AADD(aCabNot,{cDupl    ,HF2->(FieldPos("F2_DUPL"))     })   //8
AADD(aCabNot,{dEmissao ,HF2->(FieldPos("F2_EMISSAO"))  })   //9
AADD(aCabNot,{cEst     ,HF2->(FieldPos("F2_EST"))      })   //10
AADD(aCabNot,{nFrete   ,HF2->(FieldPos("F2_FRETE"))    })   //11
AADD(aCabNot,{nSeguro  ,HF2->(FieldPos("F2_SEGURO"))   })   //12
AADD(aCabNot,{nICMFret ,HF2->(FieldPos("F2_ICMFRET"))  })   //13
AADD(aCabNot,{cTipoCli ,HF2->(FieldPos("F2_TIPOCLI"))  })   //14
AADD(aCabNot,{nValBrut ,HF2->(FieldPos("F2_VALBRUT"))  })   //15
AADD(aCabNot,{nValICM  ,HF2->(FieldPos("F2_VALICM"))   })   //16
AADD(aCabNot,{nBaseICM ,HF2->(FieldPos("F2_BASEICM"))  })   //17
AADD(aCabNot,{nValIPI  ,HF2->(FieldPos("F2_VALIPI"))   })   //18
AADD(aCabNot,{nBaseIPI ,HF2->(FieldPos("F2_BASEIPI"))  })   //19
AADD(aCabNot,{nValMerc ,HF2->(FieldPos("F2_VALMERC"))  })   //20
AADD(aCabNot,{nDescont ,HF2->(FieldPos("F2_DESCONT"))  })   //21
AADD(aCabNot,{cTipo    ,HF2->(FieldPos("F2_TIPO"))     })   //22
AADD(aCabNot,{nIcmsRet ,HF2->(FieldPos("F2_ICMSRET"))  })   //23
AADD(aCabNot,{nPliqui  ,HF2->(FieldPos("F2_PLIQUI"))   })   //24
AADD(aCabNot,{nPBruto  ,HF2->(FieldPos("F2_PBRUTO"))   })   //25
AADD(aCabNot,{cTransp  ,HF2->(FieldPos("F2_TRANSP"))   })   //26
AADD(aCabNot,{cVend1   ,HF2->(FieldPos("F2_VEND1"))    })   //27
AADD(aCabNot,{cOk      ,HF2->(FieldPos("F2_OK"))       })   //28
AADD(aCabNot,{cFimp    ,HF2->(FieldPos("F2_FIMP"))     })   //29
AADD(aCabNot,{cFilial  ,HF2->(FieldPos("F2_FILIAL"))   })   //30
AADD(aCabNot,{nBaseISS ,HF2->(FieldPos("F2_BASEISS"))  })   //31
AADD(aCabNot,{nValISS  ,HF2->(FieldPos("F2_VALISS"))   })   //32

AADD(aCabNot,{nValFat  ,0 }) //33
AADD(aCabNot,{nBRicms  ,0 }) //34
AADD(aCabNot,{cPrefixo ,0 }) //35
AADD(aCabNot,{nValCofi ,0 }) //36
AADD(aCabNot,{nValPIS  ,0 }) //37
AADD(aCabNot,{nValIRRF ,0 }) //38
AADD(aCabNot,{nSeqCar  ,0 }) //39
AADD(aCabNot,{nBaseINS ,0 }) //40
AADD(aCabNot,{dDtEntr  ,0 }) //41
AADD(aCabNot,{cTipoDoc ,0 }) //42
AADD(aCabNot,{cTPFrete ,0 }) //43
AADD(aCabNot,{cFpgto   ,0 }) //44
AADD(aCabNot,{cSTATUS  ,HF2->(FieldPos("F2_STATUS"))}) //45

// Se for Inclusao
If nOperacao==1
    aCabNot[4,1]:=cCodCLi
    aCabNot[5,1]:=cLojaCLi
endif


MontaColIteNf(aColIteNf)

// ---------------------- < PARTE 1: ENTRADA DA TELA DO PEDIDO > ----------------------
//Carga dos Arrays da Tela de nota (com o uso da consulta padrao n„o sera mais necessario)

// Se for Inclusao da Nota Traz novo Numero
If aCabNot[2,1] == 1     
   HF2->( dbSetorder(1) )
   HF2->( dbGobottom()  )
   cNovaNf:=Val(HF2->F2_DOC)+1 
   cNovaNf:=StrZero(cNovaNf,6)   
   if !MsgYesOrNo(STR0007 + cNovaNf,"Nota" ) //"Confirma este Nr. de nota :"
      NFProxNF(@cNovaNf)    
      aCabNot[1,1]:=cNovaNF
   Endif
Else	// Alteracao da N.F.
	cNovaNF:=aCabNot[1,1]
 	HF2->( dbSetOrder(1) )
 	HF2->( dbSeek(cNovaNF+cSerie) )
 	If HF2->(Found())
        // O For Inicia em 2, para que o numero da NF nao seja alterado
  		For nI:=2 to Len(aCabNot)
        	If aCabNot[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
        		aCabNot[nI,1] := HF2->(FieldGet(aCabNot[nI,2]))
         	Endif
        Next

   		//Restaura total da NF
   		aCabNot[35,1] := Round(HF2->F2_VALBRUT,2)
   		    		
		//Carrega os itens da NF
		NFItNot(aCabNot,aColIteNf,aIteNot)
		dbSelectArea("HF2")
 	Endif
EndIf         
aCabNot[1,1]:=cNovaNF

// Chama funcao que prepara a nota fiscal
InitNF2(aCabNot,aIteNot,aCond,aTab,aColIteNf,@cGeraDup)

// ---------------------- < PARTE 3: SAIDA DA TELA DA N.F. > ----------------------------
//Se for Inclusao, Atualizar Informacoes Array de Roteiros ou Cliente

If aCabNot[2,1] == 1 .Or. aCabNot[2,1] == 4
	dbSelectArea("HF2")
	dbSetOrder(1)
	dbSeek(aCabNot[1,1]) 
	If HF2->(Found())
		AADD(aNotas,{aCabNot[1,1],HF2->F2_EMISSAO,"Nao transmitida" }) 
		SetArray(oBrwNotas,aNotas)
		NFAtuaProxNot(aCabNot[1,1])
	EndIf
	If Len(aNotas)>0 
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(aCabNot[4,1]+aCabNot[5,1])
			HA1->A1_FLGVIS := "4"
    		dbCommit()
		Endif
		If Empty(aCabNot[5,1])
			dbSelectArea("HD7")
			dbSetOrder(3)
			If dbSeek(DtoS(Date()) + aCabNot[4,1]+aCabNot[5,1])
				HD7->AD7_FLGVIS := "4"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)
			If dbSeek(aCabNot[4,1]+aCabNot[5,1])
				HD7->AD7_FLGVIS := "4"
	    		dbCommit()
			Endif
		Endif		
		aClientes[nCliente,1] := "NOTA"

	Endif
Endif	

Return Nil

// Carrega os Itens da Nota no Array utilizado no Browser da Tela de Notas
Function NFItNot(aCabNot, aColIteNf,aIteNot)
Local cNumNot := ""
Local cStNota := ""

cNumNot:= aCabNot[1,1]

dbSelectArea("HD2")     
dbSetOrder(1)
If dbSeek(cNumNot)
	aSize(aIteNot,0)
	if aCabNot[2,1] ==  4 	// Se for Ult. Notas
		aCabNot[9,1] := Date()
	Else      // Se for Alteracao do Pedido
		aCabNot[9,1] := Date()					
	Endif						

	While !HD2->(Eof()) .And. HD2->D2_DOC == cNumNot
				
     	For nI:=1 to Len(aColIteNf)
     		If aColIteNf[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
               aColIteNf[nI,1]:= HD2->(FieldGet(aColIteNf[nI,2]))
			Endif
		Next 
		AADD(aIteNot,Array(Len(aColIteNf)))
		For nI := 1 to Len(aColIteNf)
		  aIteNot[Len(aIteNot),nI] := aColIteNf[nI,1]
		Next

		//Restaura o valor do estoque original do HB6 na alteracao da NF
		RestauraHB6(HD2->D2_COD, HD2->D2_QUANT)

		dbSelectArea("HD2")
		dbSkip()
	Enddo
EndIf
Return Nil

//CAPTURA O CODIGO DA NOTA NO ARRAY NA LINHA SELECIONADA (N.F.)
Function NFNumNF(oBrw,aArray,cNumNot)
Local nLinha :=0
if Len(aArray)<=0
	MsgAlert(STR0008) //"Nenhuma nota Selecionada"
	Return .F.
Endif
nLinha:=GridRow(oBrw)
cNumNot:=aArray[nLinha,1]
Return .T.

// Obtem novo numero da nota fiscal
Function NFProxNF(cNovaNf)
Local oDlgNf,oGet,oBtnFechar
DEFINE DIALOG oDlgNf TITLE "PrÛxima NF"
@ 25,15 TO 100,150 OF oDlgNF
@ 31,38  SAY oSay PROMPT  STR0009 BOLD OF oDlgNF //"N˙mero :"
@ 31,85  GET oGet VAR cNovaNf OF oDlgNF
@ 115,50 BUTTON oBtnFechar CAPTION BTN_BITMAP_OK SYMBOL ACTION CloseDialog() SIZE 65,17 OF oDlgNf
SetFocus(oGet)
ACTIVATE DIALOG oDlgNf

Return cNovaNf

// CARGA DE ARRAYS DA TELA DE Notas
Function MontaColIteNf(aColIteNf)
/*
// ---------------------- < - >  COLUNAS DO ARRAY DO ITEM DO PEDIDO  < - > ----------------------
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos ( Campo da Tabela Associado)
Linha Descricao
1 - 
2 - 
3 -
*/
dbSelectarea("HD2")
aSize(aColIteNf,0)

aadd( aColIteNf,{"",HD2->(FieldPos("D2_FILIAL" )) }) // (01)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_ITEM"   )) }) // (02)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_COD"    )) }) // (03)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_UM"     )) }) // (04)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_SEGUM"  )) }) // (05)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_QUANT"  )) }) // (06)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_PRCVEN" )) }) // (07)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_TOTAL"  )) }) // (08)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_VALIPI" )) }) // (09)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_VALICM" )) }) // (10)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_TES"    )) }) // (11)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_CF"     )) }) // (12)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_DESC"   )) }) // (13)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_IPI"    )) }) // (14)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_PICM"   )) }) // (15)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_CLIENTE")) }) // (16)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_LOJA"   )) }) // (17)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_DOC"    )) }) // (18)
aadd( aColIteNf,{Ctod(""),HD2->(FieldPos("D2_EMISSAO")) }) // (19)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_GRUPO"  )) }) // (20)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_TP"     )) }) // (21)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_SERIE"  )) }) // (22)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_PRUNIT" )) }) // (23)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_EST"    )) }) // (24)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_DESCON" )) }) // (25)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_TIPO"   )) }) // (26)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_BRICMS" )) }) // (27)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_BASEICM")) }) // (28)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_VALACRS")) }) // (29)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_ICMSRET")) }) // (30)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_LOTECTL")) }) // (31)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_CLASFIS")) }) // (32)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_ALIQISS")) }) // (33)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_BASEIPI")) }) // (34)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_BASEISS")) }) // (35)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_VALISS" )) }) // (36)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_SEGURO" )) }) // (37)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_VALFRE" )) }) // (38)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_ICMFRET")) }) // (39)
aadd( aColIteNf,{"",HD2->(FieldPos("D2_OK"     )) }) // (40)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_QTDEFAT")) }) // (41)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_QTDAFAT")) }) // (42)
aadd( aColIteNf,{0 ,HD2->(FieldPos("D2_DESCR"  )) }) // (43)

Return Nil

//Calcula desconto conforme parametro (T=Protheus, F=Outros)
Function NFCalcDescto(aColIteNf,aIteNot,nItePed,lAdcIte)
Local nTotItem := 0
If cCalcProtheus == "T"	//Desconto Protheus
	If lAdcIte
		// Total item = qtde * (preco - (preco * (desct / 100)))
		nTotItem := aColIteNf[6,1] * Round((aColIteNf[23,1] - (aColIteNf[23,1] * (aColIteNf[13,1] / 100))),2)
	Else
		nTotItem := aIteNot[nItePed,6] * Round((aIteNot[nItePed,23] - (aIteNot[nItePed,23] * (aIteNot[nItePed,13] / 100))),2)
	Endif
Else	//Desconto Padrao
	If lAdcIte 
		// Total item = total item - (total item * (desct / 100))
		nTotItem := aColIteNf[8,1] - Round((aColIteNf[8,1] * (aColIteNf[13,1] / 100)),2)
	Else
		nTotItem := aIteNot[nItePed,8] - Round((aIteNot[nItePed,8] * (aIteNot[nItePed,13] / 100)),2)
	Endif
Endif
Return nTotItem

          
Function NFCalcNF(aCabNot,aColIteNf,aIteNot,nItePed,lAdcIte,aObj,lIncPed)
Local nVlrItem := 0
	If lAdcIte
		If aColIteNf[13,1] > 0
			nVlrItem := NFCalcDescto(aColIteNf,aIteNot,nItePed,lAdcIte)
			aCabNot[15,1] := aCabNot[15,1] + nVlrItem
		Else
			aCabNot[15,1] := aCabNot[15,1] + aColIteNf[8,1]
		EndIf
		aCabNot[35,1] := Round(aCabNot[15,1],2)
	Else
		if aIteNot[nItePed,13] > 0
			nVlrItem := NFCalcDescto(aColIteNf,aIteNot,nItePed,lAdcIte)
			aCabNot[15,1] := aCabNot[15,1] - nVlrItem
		else
			aCabNot[15,1] := aCabNot[15,1] - aIteNot[nItePed,8]
		endif
		//Subtrai os impostos (IPI e ICMS) antes de totalizar  //
		aCabNot[15,1] := aCabNot[15,1] - (aIteNot[nItePed,9] ) //+ aIteNot[nItePed,10]) nao considera ICMS
		aCabNot[35,1] := Round(aCabNot[15,1],2)
	Endif		
	if lIncPed
	    SetText(aObj[1,4],aCabNot[35,1])
		//SetArray(aObj[3,1],aIteNot)
	Endif
Return Nil

/*                                                                                       
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
 Carga das Notas - 01/08/2003
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
*/
Function ACCrgNot(cCodCli, cLojaCli, aNotas)
Local cStNot   := ""
Local cNumNot  := ""     
Local cStatus  := ""

dbSelectArea("HF2")
dbSetOrder(2)

HF2->( dbSeek( cCodCli+cLojaCli,.f. ) )

While !Eof() .and. HF2->F2_CLIENTE == cCodCli .and. HF2->F2_LOJA == cLojaCli
	cStnota:=""
	cNumNot:=""
	cNumNot:=HF2->F2_DOC
    // Se for NovA NOTA: Carrega nas Notas.
	if HF2->F2_STATUS = "N"      

       //-> aNotas: Array do Mod. de Notas
		If HF2->(IsDirty())		//Nao transmitido
		   cStatus:=STR0010 //"Nao Transmitida"
		else
		   cStatus:=STR0001 //"Transmitida"
		Endif

    	AADD(aNotas,{cNumNot,HF2->F2_EMISSAO,cStatus}) 

	Endif

	dbSkip()  
	
Enddo

Return Nil                                                        

//Atualiza o Prox. Nota do HA3
Function NFAtuaProxNot(cNovaNf)
/*
Local nNumNF:=0
dbSelectArea("HF2")
dbGoBottom()                
nNumNf:=Val(HF2->F2_DOC) + 1
cNovaNf:=StrZero(cNovanf,6)
*/
Return Nil
