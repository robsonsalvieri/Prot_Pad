#include "protheus.ch"
#include "GEMA105.ch"

#define TIT_LENGHT     19

#define TIT_SELECT       1
#define TIT_ITEMPARCELA  2
#define TIT_TIPO         3
#define TIT_VENCTO       4
#define TIT_PRINCIPAL    5
#define TIT_JUROSFCTO    6
#define TIT_CMPRINCIPAL  7
#define TIT_CMJUROSFCTO  8
#define TIT_PRORATA      9
#define TIT_JUROSMORA   10
#define TIT_MULTA       11
#define TIT_ABONO       12
#define TIT_DESCONTO    13
#define TIT_VLRTITULO   14
#define TIT_PERCJUROS   15
#define TIT_PERCMULTA   16
#define TIT_PREFIXO     17
#define TIT_NUMERO      18
#define TIT_PARCELA     19

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMA105DlgºAutor  ³Reynaldo Miyashita  º Data ³  17/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetivacao da Quitacao das Parcelas                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMA105Dlg(cAlias,nReg,nOpc)

Local nX := 0
Local nY := 0
Local oDlg
Local lContinua     := .T.
Local lEstornar     := .F.
Local lQuitar       := .F.
Local lCancel		:= .F.
Local aVetor		:= {}
Local aTotais		:= {0,0,0,0,0}
Local cBanco  		:= space(3) 
Local cAgencia		:= space(5) 
Local cConta		:= space(10) 

Local aArea := GetArea()

Private nMulta := 0
Private nJuros := 0

Private	oLbx
Private cTitulo := "" 

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case                              
	Case aRotina[nOpc][4] == 2 // Visualizar
		lContinua := .F.
	Case aRotina[nOpc][4] == 4 // Simular
		lContinua := .F.
	Case aRotina[nOpc][4] == 5 // Estornar
		lEstornar := .T.
		cTitulo := STR0001 // "Estorno das parcelas renegociadas."
	Case aRotina[nOpc][4] == 6 // Quitar
		lQuitar := .T.
		cTitulo := STR0002 //"Efetiva Quitacao das Parcelas do Contrato."
	Case aRotina[nOpc][4] == 7 // Cancelar
		lCancel := .T.
		cTitulo := STR0046		//"Cancelar Quitacao das Parcelas do Contrato."
EndCase

dbSelectArea(cAlias)
(cAlias)->(dbGoto(nReg))   
cContrato := LIT->LIT_NCONTR

If lContinua .AND. (((lEstornar .AND. lQuitar) .OR. (!lEstornar .AND. !lQuitar)) .and. !lCancel)
	lContinua := .F.
EndIf

If lContinua .AND. (cAlias)->LIT_STATUS <> "1"
	lContinua := .F.
EndIf

If lContinua .AND. !LoadParc( cContrato ,@aVetor ,@aTotais ,lEstornar ,lQuitar, lCancel )
	lContinua := .F.
EndIf

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
If lContinua

  	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 391,760 PIXEL

	@005,005 LISTBOX oLBx FIELDS HEADER  STR0003    ,STR0004       ,STR0005   ;
	                                    ,STR0006  ,STR0007 ,STR0008       ,STR0009 ;
	                                    ,STR0010 ,STR0011      ,STR0012    ,STR0013 ,STR0014    ;
	                          SIZE 370,140 OF oDLG PIXEL 

	oLbx:SetArray( aVetor )
	oLBx:bLine := {|| { aVetor[oLbx:nAt][TIT_ITEMPARCELA ]                                  ,aVetor[oLbx:nAt][TIT_TIPO      ] ,;
	                    aVetor[oLbx:nAt][TIT_VENCTO  ]                                      ,Transform( aVetor[oLbx:nAt][TIT_PRINCIPAL ] ,x3Picture("E1_VALOR")) ,;
	                    Transform( aVetor[oLbx:nAt][TIT_JUROSFCTO ] ,x3Picture("E1_VALOR")) ,Transform( aVetor[oLbx:nAt][TIT_CMPRINCIPAL]+aVetor[oLbx:nAt][TIT_CMJUROSFCTO] ,x3Picture("E1_VALOR")) ,;
 			            Transform( aVetor[oLbx:nAt][TIT_PRORATA   ] ,x3Picture("E1_VALOR")) ,Transform( aVetor[oLbx:nAt][TIT_JUROSMORA ] ,x3Picture("E1_VALOR")) ,;
 			            Transform( aVetor[oLbx:nAt][TIT_MULTA     ] ,x3Picture("E1_VALOR")) ,Transform( aVetor[oLbx:nAt][TIT_ABONO     ] ,x3Picture("E1_VALOR")) ,;
 			            Transform( aVetor[oLbx:nAt][TIT_DESCONTO  ] ,x3Picture("E1_VALOR")) ,Transform( aVetor[oLbx:nAt][TIT_VLRTITULO ] ,x3Picture("E1_VALOR")) }}

	If lQuitar
		@152,327 BUTTON STR0015 	SIZE 50,12 ACTION (iIf( Efetivar( (cAlias)->LIT_NCONTR ,@aVetor ,cBanco ,cAgencia ,cConta ), oDlg:End(),.F.) ) Of oDlg PIXEL    //efetivar
	EndIf
	If lCancel
		@166,327 BUTTON STR0044 	SIZE 50,12 ACTION (IIf( Estorno(  (cAlias)->LIT_NCONTR ,@aVetor ,lQuitar ,lEstornar, lCancel ), oDlg:End(),.F.) )     Of oDlg PIXEL  // cancelar	
	Else
		@166,327 BUTTON STR0016 	SIZE 50,12 ACTION (IIf( Estorno(  (cAlias)->LIT_NCONTR ,@aVetor ,lQuitar ,lEstornar, lCancel ), oDlg:End(),.F.) )     Of oDlg PIXEL  // estornar
	Endif
	@180,327 BUTTON STR0017  		SIZE 50,12 ACTION (oDlg:End()) Of oDlg PIXEL  //sair

    nx := 10 
    ny := 005
    
    @nx+155,ny+00 to @nx+182,ny+230 PROMPT STR0018 Of oDlg PIXEL     //negociado
	
	@nx+160,ny+05  SAY STR0019    Of oDlg PIXEL   //parcelas
	@nx+160,ny+50  SAY STR0020 Of oDlg PIXEL  // penalidades
	@nx+160,ny+095 SAY STR0021   Of oDlg PIXEL  // descontos
	@nx+160,ny+140 SAY STR0022      Of oDlg PIXEL  // abonos
	@nx+160,ny+185 SAY STR0023	  Of oDlg PIXEL   // negociado
	
	@nx+167,ny+005 MSGET aTotais[01] PICTURE "@e 9,999,999.99"  SIZE 040,010 WHEN .F. Of oDlg PIXEL
	@nx+167,ny+050 MSGET aTotais[02] PICTURE "@e 9,999,999.99"  SIZE 040,010 WHEN .F. Of oDlg PIXEL
	@nx+167,ny+095 MSGET aTotais[03] PICTURE "@e 9,999,999.99"  SIZE 040,010 WHEN .F. Of oDlg PIXEL
	@nx+167,ny+140 MSGET aTotais[04] PICTURE "@e 9,999,999.99"  SIZE 040,010 WHEN .F. Of oDlg PIXEL
	@nx+167,ny+185 MSGET aTotais[05] PICTURE "@e 9,999,999.99"  SIZE 040,010 WHEN .F. Of oDlg PIXEL

	If lQuitar
		// BANCO/AGENCIA/CONTA
	    nX := -05
	    nY := 056                                                                  
	
	  	@nX+152,nY+184 TO @nX+197,nY+267 PROMPT STR0024 Of oDlg PIXEL //banco
	  		
		@nX+160,nY+194 SAY STR0025   Of oDlg PIXEL   //banco
		@nX+172,nY+190 SAY STR0026 Of oDlg PIXEL    //agencia
		@nX+184,nY+196 SAY STR0027   Of oDlg PIXEL  //conta
		@nX+159,nY+217 MSGET cBanco   PICTURE "@!"  SIZE 015,010 F3 "SA6" Of oDlg PIXEL
		@nX+171,nY+217 MSGET cAgencia PICTURE "@!"  SIZE 020,010          Of oDlg PIXEL
		@nX+183,nY+217 MSGET cConta   PICTURE "@!"  SIZE 035,010          Of oDlg PIXEL 
    EndIf
    
	ACTIVATE MSDIALOG oDlg CENTER

Else
   	Aviso( cTitulo, STR0028, {STR0029} )    //Nao foi encontrado titulos negociados para este contrato! # Ok
Endif

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadParc  ºAutor  ³Reynaldo Miyashita  º Data ³  20/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o vetor conforme a condicao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadParc( cContrato ,aAllTits ,aTotais ,lEstornar ,lQuitar ,lCancel)
Local nVlrJurosFcto := 0
Local nVlrPrincipal := 0
Local nMes          := 0
Local nCntRegua     := 0
Local dHabite       := stod("")
Local cItParc       := ""
Local cTaxa         := ""
Local aArea         := GetArea()
Local nTam

DEFAULT aAllTits := {}
DEFAULT aTotais  := {}

n2Parcela := 0

nPorcJurMor := LIT->LIT_JURMOR
nPorcMulta  := LIT->LIT_MULTA

// Itens do Contrato
dbSelectArea("LIU")
dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
dbSeek(xFilial()+LIT->(LIT_NCONTR))
While LIU->(!eof()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == LIT->(xFilial("LIT")+LIT_NCONTR))
	// Unidades
	dbSelectArea("LIQ")
	dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
	If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
		dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
	EndIf
	dbSelectArea("LIU")
	dbSkip()
EndDo

ProcRegua(100)
nCntRegua := 0

//
// Titulos renegociados
//
dbSelectArea("LK7")
dbSetOrder(1)
dbSeek(xFilial("LK7")+cContrato)
While !LK7->(Eof()) .and. LK7->(LK7_FILIAL+LK7_NCONTR) == xFilial("LK7")+cContrato

	lContinua := .F.
	
	If !lCancel
	
		If lEstornar .AND. (LK7->LK7_APROV == "1")
			lContinua := .T. 
		EndIf
	
		If lQuitar .AND. Empty(LK7->LK7_APROV)
			lContinua := .T. 
		EndIf
	
		If lContinua
			//
			// Detalhes dos titulos a receber
			//
			nTam := TamSx3("LIX_NUM")[1]
			dbSelectArea("LIX")
			dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
			If dbSeek(xFilial("LIX")+LK7->LK7_NCONTR+LK7->LK7_PREFIX+LK7->LK7_NUM+LK7->LK7_PARCEL+LK7->LK7_TIPO)
				IncProc()
				nCntRegua++
				If nCntRegua >100
					ProcRegua(100)
					nCntRegua := 0
				EndIf
			
				//
				// Titulos a receber
				//
				dbSelectArea("SE1")
				dbSetOrder(1)
				If MSSeek(xFilial("SE1")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
					//		
					If SE1->E1_SALDO > 0
						
						//
						// valor do titulo corrigido
						//
						nVlrPrincipal := LIX->LIX_ORIAMO 
						nVlrJurosFcto := LIX->LIX_ORIJUR 
			
						// Condicao de venda
						dbSelectArea("LJO")
						dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
						If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
							// parcela em atraso, calcula-se a Pro-Rata por atraso diario, Juros Mora e Multa
		                    cItParc := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM
		
							If dTos(SE1->E1_VENCREA) < dTos(dDatabase)
							
								If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
									cTaxa := LJO->LJO_INDPOS
									nMes  := LJO->LJO_NMES1
								Else
									cTaxa := LJO->LJO_IND
									nMes  := LJO->LJO_NMES2
								EndIf
								
							EndIf
							
						EndIf
						
						aAdd( aAllTits ,Array(TIT_LENGHT) )
						aAllTits[Len(aAllTits)][TIT_SELECT      ] := .T.
						aAllTits[Len(aAllTits)][TIT_ITEMPARCELA ] := cItParc
						aAllTits[Len(aAllTits)][TIT_TIPO        ] := SE1->E1_TIPO   
						aAllTits[Len(aAllTits)][TIT_VENCTO      ] := SE1->E1_VENCTO
						
						aAllTits[Len(aAllTits)][TIT_PRINCIPAL   ] := LK7->LK7_AMORT
						aAllTits[Len(aAllTits)][TIT_JUROSFCTO   ] := LK7->LK7_JURFCT
						aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL ] := LK7->LK7_CMAMOR
						aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO ] := LK7->LK7_CMJRFC
						
						aAllTits[Len(aAllTits)][TIT_PRORATA     ] := LK7->LK7_PRORAT
						aAllTits[Len(aAllTits)][TIT_JUROSMORA   ] := LK7->LK7_JURMOR 
						aAllTits[Len(aAllTits)][TIT_MULTA       ] := LK7->LK7_MULTA
						aAllTits[Len(aAllTits)][TIT_ABONO       ] := LK7->LK7_ABONO
						aAllTits[Len(aAllTits)][TIT_DESCONTO    ] := LK7->((LK7_AMORT+LK7_JURFCT+LK7_CMAMOR+LK7_CMJRFC)*(LK7_DESC/100))
						
						aAllTits[Len(aAllTits)][TIT_VLRTITULO   ] := aAllTits[Len(aAllTits)][TIT_PRINCIPAL  ]+aAllTits[Len(aAllTits)][TIT_JUROSFCTO  ] ;
						                                           + aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL]+aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO] ;
						                                           + aAllTits[Len(aAllTits)][TIT_PRORATA    ]+aAllTits[Len(aAllTits)][TIT_JUROSMORA  ] ;
						                                           + aAllTits[Len(aAllTits)][TIT_MULTA      ] ;
						                                           -(aAllTits[Len(aAllTits)][TIT_ABONO      ]+aAllTits[Len(aAllTits)][TIT_DESCONTO ])
						
	
						aAllTits[Len(aAllTits)][TIT_PREFIXO     ] := SE1->E1_PREFIXO
						aAllTits[Len(aAllTits)][TIT_NUMERO      ] := SE1->E1_NUM
						aAllTits[Len(aAllTits)][TIT_PARCELA     ] := SE1->E1_PARCELA
		
						aTotais[01] += LK7->(LK7_AMORT+LK7_JURFCT+LK7_CMAMOR+LK7_CMJRFC)
						aTotais[02] += LK7->(LK7_PRORAT+LK7_JURMOR+LK7_MULTA)
						aTotais[03] += aAllTits[Len(aAllTits) ,TIT_DESCONTO]
						aTotais[04] += aAllTits[Len(aAllTits) ,TIT_ABONO]
						aTotais[05] += aAllTits[Len(aAllTits) ,TIT_VLRTITULO]
						
	                EndIf
				EndIf
			EndIf
		EndIf
	
	Else

		If LK7->LK7_APROV == "1"
			lContinua := .T. 
		EndIf
	
		If lContinua
			//
			// Detalhes dos titulos a receber
			//
			nTam := TamSx3("LIX_NUM")[1]
			dbSelectArea("LIX")
			dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
			If dbSeek(xFilial("LIX")+LK7->LK7_NCONTR+LK7->LK7_PREFIX+LK7->LK7_NUM+LK7->LK7_PARCEL+LK7->LK7_TIPO)
				IncProc()
				nCntRegua++
				If nCntRegua >100
					ProcRegua(100)
					nCntRegua := 0
				EndIf

				//
				// Titulos a receber
				//
				dbSelectArea("SE1")
				dbSetOrder(1)
				If MSSeek(xFilial("SE1")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
					//		
					If SE1->E1_SALDO == 0
						
						//
						// valor do titulo corrigido
						//
						nVlrPrincipal := LIX->LIX_ORIAMO
						nVlrJurosFcto := LIX->LIX_ORIJUR

						// Condicao de venda
						dbSelectArea("LJO")
						dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
						If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
							// parcela em atraso, calcula-se a Pro-Rata por atraso diario, Juros Mora e Multa
							cItParc := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM
		
							If dTos(SE1->E1_VENCREA) < dTos(dDatabase)

								If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
									cTaxa := LJO->LJO_INDPOS
									nMes  := LJO->LJO_NMES1
								Else
									cTaxa := LJO->LJO_IND
									nMes  := LJO->LJO_NMES2
								EndIf
	
							EndIf
	
						EndIf

						aAdd( aAllTits ,Array(TIT_LENGHT) )
						aAllTits[Len(aAllTits)][TIT_SELECT      ] := .T.
						aAllTits[Len(aAllTits)][TIT_ITEMPARCELA ] := cItParc
						aAllTits[Len(aAllTits)][TIT_TIPO        ] := SE1->E1_TIPO
						aAllTits[Len(aAllTits)][TIT_VENCTO      ] := SE1->E1_VENCTO
						
						aAllTits[Len(aAllTits)][TIT_PRINCIPAL   ] := LK7->LK7_AMORT
						aAllTits[Len(aAllTits)][TIT_JUROSFCTO   ] := LK7->LK7_JURFCT
						aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL ] := LK7->LK7_CMAMOR
						aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO ] := LK7->LK7_CMJRFC
						
						aAllTits[Len(aAllTits)][TIT_PRORATA     ] := LK7->LK7_PRORAT
						aAllTits[Len(aAllTits)][TIT_JUROSMORA   ] := LK7->LK7_JURMOR 
						aAllTits[Len(aAllTits)][TIT_MULTA       ] := LK7->LK7_MULTA
						aAllTits[Len(aAllTits)][TIT_ABONO       ] := LK7->LK7_ABONO

						aAllTits[Len(aAllTits)][TIT_DESCONTO    ] := LK7->((LK7_AMORT+LK7_JURFCT+LK7_CMAMOR+LK7_CMJRFC)*(LK7_DESC/100))
						
						aAllTits[Len(aAllTits)][TIT_VLRTITULO   ] := aAllTits[Len(aAllTits)][TIT_PRINCIPAL  ]+aAllTits[Len(aAllTits)][TIT_JUROSFCTO  ] ;
						                                           + aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL]+aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO] ;
						                                           + aAllTits[Len(aAllTits)][TIT_PRORATA    ]+aAllTits[Len(aAllTits)][TIT_JUROSMORA  ] ;
						                                           + aAllTits[Len(aAllTits)][TIT_MULTA      ] ;
						                                           -(aAllTits[Len(aAllTits)][TIT_ABONO      ]+aAllTits[Len(aAllTits)][TIT_DESCONTO ])
						
	
						aAllTits[Len(aAllTits)][TIT_PREFIXO     ] := SE1->E1_PREFIXO
						aAllTits[Len(aAllTits)][TIT_NUMERO      ] := PadR(SE1->E1_NUM, Len(SE1->E1_NUM))
						aAllTits[Len(aAllTits)][TIT_PARCELA     ] := SE1->E1_PARCELA
		
						aTotais[01] += LK7->(LK7_AMORT+LK7_JURFCT+LK7_CMAMOR+LK7_CMJRFC)
						aTotais[02] += LK7->(LK7_PRORAT+LK7_JURMOR+LK7_MULTA)
						aTotais[03] += aAllTits[Len(aAllTits) ,TIT_DESCONTO]
						aTotais[04] += aAllTits[Len(aAllTits) ,TIT_ABONO]
						aTotais[05] += aAllTits[Len(aAllTits) ,TIT_VLRTITULO]
						
					EndIf
				EndIf
			EndIf
		EndIf

	Endif	
	dbSelectArea("LK7")	
	dbSkip()
EndDo
	
RestArea(aArea)
		
Return( Len(aAllTits) <> 0 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Estorno   ºAutor  ³Reynaldo Miyashita  º Data ³  20/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorna as parcelas negociadas                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Estorno( cContrato ,aParcelas ,lQuitar ,lEstornar , lCancel)
Local nCnt      := 0
Local nCntRegua := 0
Local lRetorno  := .T.
Local aArea     := GetArea()
Local aVetor	 := {}
Local nRecnoLK7 := 0
Local aCpyParcel:= {}
Local aSavParcel:= aClone(aParcelas)

If lQuitar
	If MsgYesNo(STR0030,STR0031)  //Confirma o Estorno na Negociacao de Quitacao? ## "Confirmação"
	
		lRetorno  := .T.
	
		//
		// Titulos renegociados
		//
		dbSelectArea("LK7")
		dbSetOrder(1)
		dbSeek(xFilial("LK7")+cContrato)
		While !LK7->(Eof()) .and. LK7->(LK7_FILIAL+LK7_NCONTR) == xFilial("LK7")+cContrato
			IncProc()
			nCntRegua++
			If nCntRegua >100
				ProcRegua(100)
				nCntRegua := 0
			EndIf
				
			If Empty(LK7->LK7_APROV)
				RecLock("LK7",.F.)
					dbDelete()
				MsUnLock()
			EndIf
				
			dbSelectArea("LK7")
			dbSkip()
		EndDo
	Else
		lRetorno  := .F.
	EndIf
	
ElseIf lEstornar

	If MsgYesNo(STR0032,STR0031)  //Confirma o Estorno dos titulos negociados? ## Confirmação
	
		lRetorno  := .T.
	
		For nCnt := 1 to Len(aParcelas)
		
			IncProc()
			nCntRegua++
			If nCntRegua >100
				ProcRegua(100)
				nCntRegua := 0
			EndIf
			
		    // Titulo selecionado
			If aTitulos[nX][TIT_SELECT]
	 			// Titulos negociados
				dbSelectArea("LK7")
				dbSetOrder(1) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
				If MsSeek( xFilial("LK7")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
					// detalhes do titulo a receber
					dbSelectArea("LIX")
					dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
					If MsSeek( xFilial("LIX")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
						// Titulos em aberto 
						dbSelectArea("SE1")
						dbSetOrder(1)
						If dbSeek(xFilial("SE1")+LIX->LIX_PREFIX+PadR(LIX->LIX_NUM, Len(LIX->LIX_NUM))+LIX->LIX_PARCELA+LIX->LIX_TIPO)
								
							RecLock("SE1",.F.)
								SE1->E1_DECRESC   -= aParcelas[nLoop ,TIT_ABONO]
								SE1->E1_SDDECRESC -= SE1->E1_DECRESC
							MsUnLock()
							
							RecLock("LK7",.F.)
								dbDelete()
							MsUnLock()
							
				   	EndIf
				   EndIf
				EndIf
			EndIf
		Next nCnt
	Else
		lRetorno  := .F.
	EndIf
	
Elseif lCancel

	// **  Pegamos somente o registro posicionado na tela **/
	aadd(aCpyParcel,aParcelas[oLBx:nat])
	aParcelas := aClone(aCpyParcel)

	If MsgYesNo(STR0045,STR0031)  //Confirma o Cancelamento dos titulos negociados? ## Confirmação
	
		lRetorno  := .T.

		For nCnt := 1 to Len(aParcelas)

			IncProc()
			nCntRegua++
			If nCntRegua >100
				ProcRegua(100)
				nCntRegua := 0
			EndIf
			
		    // Titulo selecionado
			If aParcelas[nCnt][TIT_SELECT]
	 			// Titulos negociados
				dbSelectArea("LK7")
				dbSetOrder(1) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
				If MsSeek( xFilial("LK7")+cContrato+aParcelas[nCnt ,TIT_PREFIXO]+aParcelas[nCnt ,TIT_NUMERO]+aParcelas[nCnt ,TIT_PARCELA]+aParcelas[nCnt ,TIT_TIPO] )
					nRecnoLK7 := LK7->(Recno())
					// detalhes do titulo a receber
					dbSelectArea("LIX")
					dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
					If MsSeek( xFilial("LIX")+cContrato+aParcelas[nCnt ,TIT_PREFIXO]+aParcelas[nCnt ,TIT_NUMERO]+aParcelas[nCnt ,TIT_PARCELA]+aParcelas[nCnt ,TIT_TIPO] )
						// Titulos em aberto 
						dbSelectArea("SE1")
						dbSetOrder(1)
						If dbSeek(xFilial("SE1")+LIX->LIX_PREFIX+PadR(LIX->LIX_NUM, Len(LIX->LIX_NUM))+LIX->LIX_PARCELA+LIX->LIX_TIPO)
								
							RecLock("SE1",.F.)
								SE1->E1_DECRESC   -= aParcelas[nCnt ,TIT_ABONO]
								SE1->E1_SDDECRESC -= SE1->E1_DECRESC
							MsUnLock()


							nMulta     := 0
							nProRata   := 0
							nRecebido  := 0
		
							nDecrescimo :=	aParcelas[nCnt][TIT_ABONO]
	
							// Valor de abatimento
							nAbatim := SomaAbat(SE1->E1_PREFIXO,PadR(SE1->E1_NUM, Len(SE1->E1_NUM)),SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
							
							// Saldo Corrente do Titulo na Moeda do Titulo
							nSldTitulo := Max(SE1->E1_SALDO-nAbatim ,0)
							
							// Correcao monetaria
							nCorrMonet := aParcelas[nCnt][TIT_CMPRINCIPAL]+aParcelas[nCnt][TIT_CMJUROSFCTO]
													
							// Adiciona a Juros Mora
							nJurosMora := aParcelas[nCnt][TIT_JUROSMORA]
	
							// Adiciona a Multa
							nMulta := aParcelas[nCnt][TIT_MULTA]
							
							// Adiciona a Pro Rata
							nProRata := aParcelas[nCnt][TIT_PRORATA]
	
							// valor de desconto
							nDesconto  := aParcelas[nCnt][TIT_DESCONTO]

							// valor a ser recebido
							nRecebido := ( aParcelas[nCnt][TIT_PRINCIPAL] + aParcelas[nCnt][TIT_JUROSFCTO] +nCorrMonet + nProRata + nJurosMora + nMulta) 
							
							nRecebido -= Round(nDesconto,2)
							nRecebido -= nDecrescimo
							
							IncProc(STR0039 + SE1->E1_PARCELA +")")
	
							aVetor := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO   	,Nil},;
			  		  					{"E1_NUM"		,PadR(SE1->E1_NUM, Len(SE1->E1_NUM))    	,Nil},;
										{"E1_PARCELA"	,SE1->E1_PARCELA    ,Nil},;
										{"E1_TIPO"	    ,SE1->E1_TIPO      	,Nil},;
										{"AUTMOTBX"	    ,"NOR"             	,Nil},;
										{"AUTDTBAIXA"	,dDataBase         	,Nil},;
										{"AUTDTCREDITO" ,dDataBase         	,Nil},;
										{"AUTHIST"	    ,STR0040 			,Nil},;  //## "Baixa Aut.Rotina Quitacao" ##
										{"AUTBANCO"		,""     	    ,Nil},;
										{"AUTAGENCIA"	,""			,Nil},;
										{"AUTCONTA"		,""			,Nil},;
			  							{"AUTDESCONT"	,nDesconto          ,Nil,.T.},;
			  							{"AUTCM1"       ,nCorrMonet         ,Nil,.T.},;
			  							{"AUTPRORATA"   ,nProRata           ,Nil,.T.},;
			  							{"AUTMULTA"		,nMulta             ,Nil,.T.},;
			  							{"AUTJUROS"		,nJurosMora         ,Nil,.T.},;
			  							{"AUTDECRESC"	,nDecrescimo		,Nil,.T.},;
			  							{"AUTVALREC"	,nRecebido          ,Nil}}
	
	                       
							lMsErroAuto = .F.
							MSExecAuto({|x,y| fina070(x,y)},aVetor,6)
							If lMsErroAuto  //## "Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " ##
								Alert(STR0043  + SE1->E1_PREFIXO + "/" + PadR(SE1->E1_NUM, Len(SE1->E1_NUM)) + "/" + SE1->E1_PARCELA + ")") // "Erro ao tentar excluir baixa do título: "
								MostraErro()
								lRetorno  := .F.
							Else

								If Empty(LIT->LIT_DTCM) .and. month(SE1->E1_VENCTO) > month(LIT->LIT_EMISSA)
									SubTipTitR( cContrato ,aParcelas[nCnt ,TIT_PREFIXO] ,aParcelas[nCnt ,TIT_NUMERO] ,aParcelas[nCnt ,TIT_PARCELA] ,aParcelas[nCnt ,TIT_TIPO], "PR ")
								Elseif !Empty(LIT->LIT_DTCM) .and. left(dtos(SE1->E1_VENCTO),6) > LIT->LIT_DTCM
									SubTipTitR( cContrato ,aParcelas[nCnt ,TIT_PREFIXO] ,aParcelas[nCnt ,TIT_NUMERO] ,aParcelas[nCnt ,TIT_PARCELA] ,aParcelas[nCnt ,TIT_TIPO], "PR ")
								Endif

								LK7->(dbGoTo(nRecnoLK7))
								RecLock("LK7",.F.,.T.)
									LK7->(dbDelete())
								LK7->(MsUnLock())

							Endif
							
							// Retorna o array original, evitando error.log caso cancele a tela.
							aParcelas := aClone(aSavParcel)

				   	EndIf
				   EndIf
				EndIf
			EndIf
		Next nCnt
	Else
		lRetorno  := .F.
	EndIf	

EndIf


RestArea(aArea)
	
Return( lRetorno )
                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Efetivar  ºAutor  ³Reynaldo Miyashita  º Data ³  20/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetiva a baixa dos titulos negociados                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Efetivar( cContrato ,aParcelas ,cBanco ,cAgencia ,cConta )
Local lRetorno    := .T.
Local nLoop       := 0
Local nResposta   := 0
Local nDesconto   := 0
Local nDecrescimo := 0
Local aArea       := GetArea()
                                                                //Baixa de Titulos#Deseja baixar automaticamente os titulos ?
	nResposta := Aviso(STR0033 ,STR0034 ; 						//Sim#Nao#Cancela
	                   ,{STR0035,STR0036,STR0037} ,3 )
    
	Do Case
			
		//
		// Baixa automaticamente o titulo
		//
		Case nResposta == 1
		
			lRetorno := CarregaSA6(cBanco,cAgencia,cConta,.T.,,.T.)
			
		//
		// Apenas substitui os titulos que sao provisorios por tipo NF
		//
		Case nResposta == 2
		
			lRetorno := .T.
		
		OtherWise
			lRetorno := .F.
		
	EndCase

	If lRetorno
		// Confirma a baixa dos titulos
		If (lRetorno := MsgYesNo(STR0038,STR0031)) //"Confirma a Baixa dos titulos na Negociacao de Quitacao?"## Confirmação

			For nLoop := 1 To len(aParcelas)
			
				// Valor de decrescimo do tituloa receber referente aos abonos de juros mora, multa e pro-rata
				nDecrescimo := aParcelas[nLoop ,TIT_ABONO]

				//
				// Substituir os titulos provisorio por tipo NF
				//
				If nResposta == 1 .OR. nResposta == 2

					If !(aParcelas[nLoop ,TIT_TIPO] == "NF ")
						SubTipTitR( cContrato ,aParcelas[nLoop ,TIT_PREFIXO] ,aParcelas[nLoop ,TIT_NUMERO] ,aParcelas[nLoop ,TIT_PARCELA] ,aParcelas[nLoop ,TIT_TIPO], "NF ")
						aParcelas[nLoop ,TIT_TIPO] := "NF
					EndIf

					// Titulos negociados
					dbSelectArea("LK7")
					dbSetOrder(1) //LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCEL+LK7_TIPO
					If MsSeek( xFilial("LK7")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
						// detalhes do titulo a receber
						dbSelectArea("LIX")
						dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
						If MsSeek( xFilial("LIX")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
							//
							// Titulos a receber
							//
							dbSelectArea("SE1")
							dbSetOrder(1)
							If MsSeek( xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO) )
								RecLock("SE1",.F.)
									SE1->E1_DECRESC   := nDecrescimo
									SE1->E1_SDDECRESC := SE1->E1_DECRESC
								MsUnLock()
								
							EndIf
						EndIf
					EndIf
				EndIf

				// baixa os titulos
				If nResposta == 1
					// Titulos a receber
					dbSelectArea("SE1")
					dbSetOrder(1)
					If MsSeek( xFilial("SE1")+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
		
						nDesconto  := 0
						nJurosMora := 0
						nMulta     := 0 
						nProRata   := 0
						nCorrMonet := 0
						nRecebido  := 0
	
						// Valor de abatimento
						nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
						
						// Saldo Corrente do Titulo na Moeda do Titulo
						nSldTitulo := Max(SE1->E1_SALDO-nAbatim ,0)
						
						// Correcao monetaria
						nCorrMonet := aParcelas[nLoop ,TIT_CMPRINCIPAL]+aParcelas[nLoop ,TIT_CMJUROSFCTO]
												
						// Adiciona a Juros Mora
						nJurosMora := aParcelas[nLoop ,TIT_JUROSMORA]

						// Adiciona a Multa
						nMulta := aParcelas[nLoop ,TIT_MULTA]
						
						// Adiciona a Pro Rata
						nProRata := aParcelas[nLoop ,TIT_PRORATA]

						// valor de desconto
						nDesconto  := aParcelas[nLoop ,TIT_DESCONTO]
					
						// valor a ser recebido
						nRecebido := ( nSldTitulo + nCorrMonet + nProRata + nJurosMora + nMulta) 
						nRecebido -= nDesconto
						nRecebido -= nDecrescimo
						
						IncProc(STR0039 + SE1->E1_PARCELA +")")

						aVetor := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO   	,Nil},;
		  		  					{"E1_NUM"		,SE1->E1_NUM    	,Nil},;
									{"E1_PARCELA"	,SE1->E1_PARCELA    ,Nil},;
									{"E1_TIPO"	    ,SE1->E1_TIPO      	,Nil},;
									{"AUTMOTBX"	    ,"NOR"             	,Nil},;
									{"AUTDTBAIXA"	,dDataBase         	,Nil},;
									{"AUTDTCREDITO" ,dDataBase         	,Nil},;
									{"AUTHIST"	    ,STR0040 			,Nil},;  //## "Baixa Aut.Rotina Quitacao" ##
									{"AUTBANCO"		,cBanco     	    ,Nil},;
									{"AUTAGENCIA"	,cAgencia			,Nil},;
									{"AUTCONTA"		,cConta      		,Nil},;
		  							{"AUTDESCONT"	,nDesconto          ,Nil,.T.},;
		  							{"AUTCM1"       ,nCorrMonet         ,Nil,.T.},;
		  							{"AUTPRORATA"   ,nProRata           ,Nil,.T.},;
		  							{"AUTMULTA"		,nMulta             ,Nil,.T.},;
		  							{"AUTJUROS"		,nJurosMora         ,Nil,.T.},;
		  							{"AUTDECRESC"	,nDecrescimo		,Nil,.T.},;
		  							{"AUTVALREC"	,nRecebido          ,Nil}}


						dbSelectArea("LK7")
						dbSetOrder(1) //LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCEL+LK7_TIPO
						If DbSeek( xFilial("LK7")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
							RecLock("LK7",.F.)
								LK7->LK7_APROV := "1"
							MsUnLock()
						EndIf

						lMsErroAuto = .F.
						MSExecAuto({|x,y| fina070(x,y)},aVetor,3)

						If lMsErroAuto  //## "Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " ##
							Alert(STR0041 + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")")
							MostraErro()
							dbSelectArea("LK7")
							dbSetOrder(1) //LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCEL+LK7_TIPO
							If DbSeek( xFilial("LK7")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
								RecLock("LK7",.F.)
									LK7->LK7_APROV := ""
								MsUnLock()
							EndIf
						EndIf

					EndIf
				Else
					dbSelectArea("LK7")
					dbSetOrder(1) //LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCEL+LK7_TIPO
					If MsSeek( xFilial("LK7")+cContrato+aParcelas[nLoop ,TIT_PREFIXO]+aParcelas[nLoop ,TIT_NUMERO]+aParcelas[nLoop ,TIT_PARCELA]+aParcelas[nLoop ,TIT_TIPO] )
						RecLock("LK7",.F.)
							LK7->LK7_APROV := "1"
						MsUnLock()
					EndIf
				EndIf
				
			Next nLoop
		EndIf
	EndIf

restArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SubTipTitRºAutor  ³Reynaldo Miyashita  º Data ³  12/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ substitui o tipo do titulos a receber.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SubTipTitR( cContrato ,cPrefixo ,cNumero ,cParcela ,cTipo ,cNewTipo )
Local aArea    := GetArea()
Local aAreaLK7 := LK7->(GetArea())
Local aAreaLIX := LIX->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aRecord  := {}
Local nCount   := 0

	// Titulos negociados
	dbSelectArea("LK7")
	dbSetOrder(1) // LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCELA+LK7_TIPO
	If MsSeek( xFilial("LK7")+cContrato+cPrefixo+cNumero+cParcela+cTipo)
		//
		// Detalhes do titulos a receber
		//
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
		If MsSeek( xFilial("LIX")+LK7->(LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCELA+LK7_TIPO) )
			// busca o titulo a receber
			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO) )
			
				dbSelectArea("SE1")
				
				aRecord := {}
				RecLock("SE1",.F.,.T.)
					For nCount := 1 to FCount()
						aAdd( aRecord ,FieldGet( nCount ) )
					Next nCount
					dbDelete()
				MsUnlock()
				
				RecLock("SE1",.T.)
					For nCount := 1 to Len(aRecord)
						SE1->(FieldPut( nCount ,aRecord[nCount] ))
					Next nCount
					SE1->E1_TIPO := cNewTipo
				MsUnlock()
				
				dbSelectArea("LIX")
				aRecord := {}
				RecLock("LIX",.F.,.T.)
					For nCount := 1 to FCount()
						aAdd( aRecord ,FieldGet( nCount ) )
					Next nCount
					dbDelete()
				MsUnlock()
								
				RecLock("LIX",.T.)
					For nCount := 1 to Len(aRecord)
						FieldPut( nCount ,aRecord[nCount] )
					Next nCount
					LIX->LIX_TIPO := cNewTipo 
				MsUnlock()
									
				aRecord := {}
					RecLock("LK7",.F.,.T.)
					For nCount := 1 to FCount()
						aAdd( aRecord ,FieldGet( nCount ) )
					Next nCount
					dbDelete()
				MsUnlock()
								
				RecLock("LK7",.T.)
					For nCount := 1 to Len(aRecord)
				   		FieldPut( nCount ,aRecord[nCount] )
					Next nCount
					LK7->LK7_TIPO := cNewTipo 
				MsUnlock()

			EndIf
		EndIf
	EndIf
	
RestArea(aAreaSE1)
RestArea(aAreaLIX)
RestArea(aAreaLK7)
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA070CHK  ºAutor  ³Reynaldo Miyashita  º Data ³  12/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se pode ser efetuada a baixa do titulo              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function FA070CHK()
Local lOk := .T.

	If HasTemplate("LOT") .And. SE1->(FieldPos("E1_NCONTR"))>0 .And. !Empty(SE1->E1_NCONTR)
		// Titulos negociados
		dbSelectArea("LK7")
		dbSetOrder(1) // LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCELA+LK7_TIPO
		If MsSeek( xFilial("LK7")+SE1->(E1_NCONTR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
			
			If Empty(LK7->LK7_APROV)
				MsgStop(STR0042) // # "Este titulo está com a renegociacao em aberto, favor verificar." #
				lOk := .F.
			EndIf
		EndIf
	EndIf
	
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA070POS  ºAutor  ³Reynaldo Miyashita  º Data ³  12/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Re-alimenta as variaveis em caso de renegociacao.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function FA070POS()
Local aArea    := GetArea()
Local aAreaLK7 := {}

	If HasTemplate("LOT") .And. SE1->(FieldPos("E1_NCONTR"))>0 .And. !Empty(SE1->E1_NCONTR)
		aAreaLK7 := LK7->(GetArea())

		// Titulos negociados
		dbSelectArea("LK7")
		dbSetOrder(1) // LK7_FILIAL+LK7_NCONTR+LK7_PREFIX+LK7_NUM+LK7_PARCELA+LK7_TIPO
		If MsSeek( xFilial("LK7")+SE1->(E1_NCONTR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
			If LK7->LK7_APROV == "1"
				nDescont  := LK7->((LK7_AMORT+LK7_JURFCT+LK7_CMAMOR+LK7_CMJRFC)*(LK7_DESC/100))
				nCM1      := LK7->(LK7_CMAMOR+LK7_CMJRFC)
				nProRata  := LK7->LK7_PRORAT
				nJuros    := LK7->LK7_JURMOR
				nMulta    := LK7->LK7_MULTA
			EndIf
		EndIf
		
		RestArea(aAreaLK7)
	EndIf
	
	RestArea(aArea)
	
Return( .T. )
