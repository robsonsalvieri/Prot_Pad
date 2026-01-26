#INCLUDE "FDVN106.ch"
#include "eADVPL.ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Limite de Credito   ³Autor - Paulo Lima   ³ Data ³05/09/02 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visitas de Negocios e Pedidos				 			  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodCli    -> Codigo Cliente *                                ´±±
±±³          ³cLojaCli   -> Loja Cliente   *    						    ´±±
±±³			 ³nPedAtual  -> Valor Total Pedido Atual                      	´±±
±±³			 ³cCodPedAlt -> Cod. Pedido, se for alteracao                	´±±
±±³			 ³(*) Parametro Obrigatorio							            ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³1, 2 ou 3 					                               	´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Verificar o Limite de Credito						      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Function VrfLimCred(cCodCli,cLojaCli, nPedAtual,cCodPedAlt)
// Retorno
// 1 - Credito Liberado
// 2 - Credito Bloqueado
// 3 - Credito Bloqueado (Avisa e permite fazer pedido)
Local nAcum:= 0.00, nSaldUp:=0.00, nSalPedl:=0.00, nCalcPed :=0.00, nDtVenc:=0
Local dDtAtual:=Date()
Local cLimParam := ""
Local cRet := ""


// Verifica a Condicao do Parametro de Limite de Credito
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_SFABLOQ")
	cLimParam := AllTrim(HCF->CF_VALOR)	
	cRet := cLimParam
EndIf

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(cCodCli+cLojaCli)
If HA1->(Found()) .And. cLimParam <> "1"
	If HA1->A1_RISCO = "A"
		cRet := "1"	
		//Return .T.
	Elseif HA1->A1_RISCO = "B" .Or. HA1->A1_RISCO = "C" .Or. HA1->A1_RISCO = "D"
		// Verifica Vencto.  e Saldo do Credito
		if HA1->A1_LC<=0
			MsgStop(STR0001,STR0002) //"O Limite de Credito do Cliente selecionado está 0!"###"Aviso"
			//cRet := cLimParam
			//Return .F.
		Else
			If Empty(HA1->A1_VENCLC)                                        
				nDtVenc:=0  
			Else
				nDtVenc:= dDtAtual - HA1->A1_VENCLC
			Endif
			If nDtVenc > 0
				MsgStop(STR0003,STR0002) //"O limite de crédito está vencido!"###"Aviso"
				//cRet := cLimParam
				//Return .F.
			Else
				If Empty(HA1->A1_SALPEDL) .Or. HA1->A1_SALPEDL = 0
					nSalPedl	:=0
				Else
					nSalPedl	:= HA1->A1_SALPEDL
				Endif
																		
				If Empty(HA1->A1_SALDUP) .Or. HA1->A1_SALDUP = 0
					nSaldUp		:=0
				Else
					nSaldUp		:= HA1->A1_SALDUP
				Endif                            
				nCalcPed	:= CalculaPed(cCodCli,cLojaCli,cCodPedAlt)
                nAcum 		:= nSalPedl + nSaldUp + nCalcPed  
                If nAcum >= HA1->A1_LC
					MsgStop(STR0004,STR0002) //"O limite de crédito está ultrapassado!"###"Aviso"
					//cRet := cLimParam
                 	//Return .F.
                Else
                	If nPedAtual > 0 
                 		If (nAcum + nPedAtual) > HA1->A1_LC
							If cLimParam = "3"
								MsgYesOrNo(STR0005 + Str(((nAcum + nPedAtual) - HA1->A1_LC), 2) + STR0006 ,STR0002) //"Saldo do cliente + Total, Ultrapassa o Limite de Crédito em "###". Confirma Gravação ?"###"Aviso"
							Else
	                        	MsgStop (STR0007 + Str(((nAcum + nPedAtual) - HA1->A1_LC), 2) + ".",STR0002) //"Não foi possível gravar. Saldo do cliente + Total, Ultrapassa o Limite de Crédito em "###"Aviso"
	      					Endif
                        Else
                        	cRet:="1" //10/03/2004 (nao existia o else)
                        EndIf
                    Else
                    	cRet:="1"
                    EndIf
                EndIf
    		Endif
		Endif 				
	Elseif HA1->A1_RISCO = "E" 
		MsgStop(STR0008,"Aviso") //"Cliente Bloqueado!"
		cRet := cLimParam
		//Return .F.
	Else                
		MsgStop(STR0009,STR0002) //"Risco do Cliente Indeterminado!"###"Aviso"
		cRet := cLimParam
	Endif
//Else
//	MsgStop("Erro Inesperado, cliente selecionado nao Cadastrado!","Aviso")
//	cRet := cLimParam
Endif

Return cRet


Function CalculaPed(cCodCli,cLojaCli,cCodPedAlt)
Local nResult:=0.00, nDesc:=0.00
Local cNumPed:=""

dbSelectArea("HC5")
dbSetOrder(2)
dbSeek(cCodCli + cLojaCli)
If HC5->(Found())
	While !Eof() .And. HC5->C5_CLI == cCodCli .And. HC5->C5_LOJA
		If HC5->C5_STATUS == "N" .And. HC5->C5_NUM <> cCodPedAlt
			dbSelectArea("HC6")
			dbSetOrder(1)
			dbSeek(HC5->C5_NUM)
			If HC6->(Found())
				While !Eof() .And. HC6->C6_NUM == HC5->C5_NUM
            		If HC6->C6_DESC > 0 
						nDesc:= HC6->C6_VALOR * (HC6->C6_DESC /100 )					
						nResult := nResult + (HC6->C6_VALOR-nDesc)
					Else
						nResult := nResult + HC6->C6_VALOR
					Endif
					dbSkip()				
				Enddo			 
			Endif
        Endif
		dbSelectArea("HC5")
    	dbSkip()
    Enddo
Endif

Return nResult


Function VrfDebito(aDuplicatas)
// Retorno
// 1 - Credito Liberado
// 2 - Credito Bloqueado
// 3 - Credito Bloqueado (Avisa e permite fazer pedido)
Local nDebAcum:= 0.00
Local ni := 0, nPos := 0
Local nDup := 0
Local dDtAtual:=Date()
Local cDebParam := ""
Local cRet := ""
Local cTitulos := ""
Local nRisco := 0
Local cRisco := HA1->A1_RISCO

// Verifica a Condicao do Parametro de Limite de Credito
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_SFADEB")
	cDebParam := AllTrim(HCF->CF_VALOR)	
	cRet := cDebParam
EndIf

If cRisco = "B"
	dbSeek("MV_RISCOB")
ElseIf cRisco = "C"
	dbSeek("MV_RISCOC")
ElseIf cRisco = "D"
	dbSeek("MV_RISCOC")
EndIf

If HCF->(Found())
	nRisco := Val(HCF->CF_VALOR)	
EndIf

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif
        
If cRet <> "1"
	nDup := Len(aDuplicatas)
	cRet := "1"
	For ni := 1 To nDup
		
		nPos := At(aDuplicatas[ni,1], cTitulos)
		If nPos == 0
			If aDuplicatas[ni,6] > nRisco
				MsgAlert(STR0010) //"O pedido do cliente ficará bloqueado, pois há títulos em atraso."
				cRet := cDebParam //restaura o conteudo do parametro
				Exit
			EndIf       
		Endif
		
	Next
EndIf
Return cRet