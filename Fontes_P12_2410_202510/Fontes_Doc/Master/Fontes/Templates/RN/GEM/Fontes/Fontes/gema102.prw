#INCLUDE "gema102.ch" 
#include "protheus.ch"

#define TIT_LENGHT     15

#define TIT_SELECT     1
#define TIT_PARCELA    2
#define TIT_TIPO       3
#define TIT_VENCTO     4
#define TIT_VLRTITULO  5
#define TIT_AMORT      6
#define TIT_CMAMORT    7
#define TIT_JUROS      8
#define TIT_CMJUROS    9
#define TIT_PRORATA    10
#define TIT_JUROSMORA  11
#define TIT_MULTA      12
#define TIT_SLDOTITULO 13
#define TIT_PREFIXO    14
#define TIT_NUMERO     15

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA102   บAutor  ณReynaldo Miyashita  บ Data ณ  04.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento de quitacao de titulos, seja por antecipacao    บฑฑ
ฑฑบ          ณ ou atraso.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMA102(cAlias,nReg,nOpc)
Local lA102Inclui := .F.
Local lA102Visual := .F.
Local lA102Altera := .F.
Local lA102Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.
Local lMovBD
Local nRecLIZ     := 0
Local nX          := 0
Local nY          := 0
Local nCount      := 0
//Local nResiduo    := 0
Local aConjLJU    := {}
Local aDefFields  := {}
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}
Local aTitSelect  := {}
Local aArea       := GetArea()
Local oDlg 
Local oPainel
Local oPanel1
Local oPanel2
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local oChkResi
Local oGetResi

Local oChkProRata
Local oChkDescto
Local oGetProRata
Local oGetPerc
Local oChkVenc
Local oChkJuros
Local oChkJurMora
Local oChkMulta
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oSay1Parc
//Local oSay1Resi
Local oSal1Pena
Local oSay1Desc
Local oSay1Nego
Local oSay1Sald
Local oSay2Parc
//Local oSay2Resi
Local oSay2Pena
Local oSay2Sald
// utilizada na rotina FINA460(LIQUIDACAO)
Private lUsaGE		:= Upper(AllTrim(FunName())) == "ACAA710"
Private oChkPRatAtr
Private aGets[0]
Private aTela[0][0]
Private oEnch 
Private oLBoxTit
Private oGet1Parc 
//Private oGet1Resi
Private oGet1Pena 
Private oGet1Desc 
Private oGet1Nego 
Private oGet2Parc
//Private oGet2Resi
Private oGet2Pena
Private oGet2Sald
Private aTitulos     := {}
//Private lResiduo   := .F.
Private lPRatAtr     := .F.
Private lProRata     := .F.
Private lDescto      := .F.
Private lVenc        := .F.
Private lJuros       := .F.
Private lJurMora     := .T.
Private lMulta       := .T.
Private nPerDesc     := 0
Private nProRata     := 0
Private n1Parcela    := 0
//Private n1Residuo  := 0
Private n1Penalidade := 0
Private n1Desconto   := 0
Private n1Negociado  := 0
Private a1AcuDesc    := {}
Private n2Parcela    := 0
//Private n2Residuo  := 0
Private n2Penalidade := 0
Private n2Total      := 0  
Private cParcela     := ""
Private aPontoEntra  := {}
PRIVATE dHabite      := stod("")
PRIVATE lNaoAltera

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA102Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui		:= .T.
		Altera      := .F.
		lA102Inclui	:= .T.
	Case (aRotina[nOpc][4] == 4)
		Inclui      := .F.
		Altera		:= .T.
		lA102Altera	:= .T.
	Case (aRotina[nOpc][4] == 5)
		lA102Exclui	:= .T.
		lA102Visual	:= .T.
EndCase

lNaoAltera 	:= lA102Visual
lMovBD  	:= (lA102Inclui .Or. lA102Altera)
//
// Customizacao da condicao de venda
//
aadd(aButtons,{STR0001,{||A102DLGCVN( aRotina[nOpc][4] ,M->LIZ_NCONTR ,M->LIZ_REVISA ,M->LIZ_COND ,dDataBase ,@aConjLJU ) },STR0002, STR0002 })
If lA102Visual
	aAdd(aButtons,{"PMSDOC",{|| T_GMViewContr(M->LIZ_NCONTR,M->LIZ_REVISA ) } ,OemtoAnsi(STR0046),OemtoAnsi(STR0047) } )    //"Visualiza o Contrato"###"Contrato"
EndIf

// caso exista a rotina, sera incluido os botoes especificos.
If ExistBlock("GMA102BTN")
	If ValType( aUsrButtons := ExecBlock( "GMA102BTN",.F., .F. ) ) == "A"
		aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
	EndIf
EndIf

aDefFields := {"LIZ_NCONTR" ,"LIZ_REVISAO" ,"LIZ_DTNEG" ,"LIZ_TIPREG"  ,"LIZ_COND" , "LIZ_HIST"}
aCampos := t_GEMA100LizLoad( aDefFields )

RegToMemory( "LIZ" ,lA102Inclui )

If lA102Inclui
	M->LIZ_FILIAL := xFilial("LIZ")
	M->LIZ_DTNEG  := dDataBase
	M->LIZ_TIPREG := "4" // Quitacao
EndIf

If !lA102Inclui
	If lA102Altera.Or.lA102Exclui
		If !SoftLock("LIZ")
			lContinua := .F.
		Else
			nRecLIZ := LIZ->(RecNo())
		Endif
		
		// verifica o status do contrato
		lContinua := T_GMContrStatus( LIZ->LIZ_NCONTRAT )
	EndIf
//	lResiduo  := LIZ->LIZ_RESID
	lPRatAtr  := LIZ->LIZ_CMATRAS
	lDescto   := (LIZ->LIZ_PERDES<>0)
	lProRata  := (LIZ->LIZ_PRORAT<>0)
	lVenc     := LIZ->LIZ_VENCID
	lJuros    := LIZ->LIZ_RETJUR
	lJurMora  := LIZ->LIZ_JURMOR
	lMulta    := LIZ->LIZ_MULTA
	nPerDesc  := LIZ->LIZ_PERDES
	nProRata  := LIZ->LIZ_PRORAT
EndIf

If lContinua
	// Carrega os Titulos
	aTitulos := A102LoadTitulo( M->LIZ_NCONTR ,M->LIZ_REVISA ,lA102Visual )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de  objetos    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd( aObjects, {  100 ,075 ,.T. ,.F. } )
	aAdd( aObjects, {  200 ,100 ,.T. ,.F. } )
	aAdd( aObjects, {  300 ,100 ,.T. ,.F. ,.T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo ,aObjects ,.T. )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
                                                                              
	//
	// Painel 
	// 
	oPainel := TPanel():New( aPosObj[1,1] ,aPosObj[1,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],.T.,.T. )
	oPainel:Align := CONTROL_ALIGN_TOP
	
	nGetLin := 5
	aPosGet := MsObjGetPos( aSize[3]-aSize[1], 315,;
		                    {{003,028,160,185}} )
	
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[1,2] )             SIZE  72,16 PIXEL Of oPainel
	@ nGetLin ,aPosGet[1,2] MSGET oGet1 VAR &("M->"+aCampos[1,1])    SIZE  75,09 PIXEL Of oPainel ;
	                        PICTURE iIf(Empty(aCampos[1,3]) ,"" ,aCampos[1,3] )      ;
	                        WHEN aCampos[1,5]!="V"                                   ;
	                        VALID If(lMovBD,a102Valid( aCampos[1]),.T.)  F3 aCampos[1,6] HASBUTTON
	                        
	oGet1:lReadOnly := lA102Visual
	
	@ nGetLin ,aPosGet[1,3] SAY OemToAnsi(aCampos[2,2] )             SIZE  72,16 PIXEL Of oPainel
	@ nGetLin ,aPosGet[1,4] MSGET oGet2 VAR &("M->"+aCampos[2,1])    SIZE  25,09 PIXEL Of oPainel ;
	                        PICTURE iIf(Empty(aCampos[2,3]) ,"" ,aCampos[2,3] ) ;
	                        WHEN aCampos[2,5]!="V"
	oGet2:lReadOnly := lA102Visual

	nGetLin += 12
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[3,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,2] MSGET oGet3 VAR &("M->"+aCampos[3,1])    SIZE  80,09 PIXEL Of oPainel ;
	                        PICTURE iIf(Empty(aCampos[3,3]) ,"" ,aCampos[3,3] ) ;
	                        WHEN aCampos[3,5]!="V"
	oGet3:lReadOnly := lA102Visual
	@ nGetLin ,aPosGet[1,3] SAY OemToAnsi(aCampos[4,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,4] COMBOBOX oGet4 VAR &("M->"+aCampos[4,1]) SIZE  80,09 PIXEL Of oPainel ;
                            WHEN aCampos[4,5]!="V"                              ;
                            ITEMS aClone(aCampos[4,8]) 
	oGet4:lReadOnly := lA102Visual
	
	nGetLin += 12
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[5,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,2] MSGET oGet5 VAR &("M->"+aCampos[5,1])    SIZE  25,09 PIXEL Of oPainel ;
	                        PICTURE iIf(Empty(aCampos[5,3]) ,"" ,aCampos[5,3] ) ;
	                        WHEN aCampos[5,5]!="V" ;
	                        VALID If(lMovBD,a102Valid( aCampos[5] ),.T.)  F3 aCampos[5,6] HASBUTTON
	oGet5:lReadOnly := lA102Visual
	
	nGetLin += 12
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[6,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,2] GET oGet6 VAR &("M->"+aCampos[6,1])      SIZE 250,32 PIXEL Of oPainel WHEN aCampos[6,5]!="V" ;
	                        MULTILINE VALID If(lMovBD,a102Valid( aCampos[6] ),.T.)  
	oGet6:lReadOnly := lA102Visual

	//
	// Painel com listbox dos titulos a receber
	// 
	oPanel1 := TPanel():New( aPosObj[2,1] ,aPosObj[2,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	
	@005,005 LISTBOX oLBoxTit FIELDS HEADER  " "            ,STR0003    ,STR0004       ,STR0005   ;
	                                        ,STR0006 ,STR0007 ,STR0008  ,STR0009 ,STR0010 ;
	                                        ,STR0011     ,STR0012 ,STR0013      ;
	                          SIZE 370,140 OF oPanel1 PIXEL ;
	                          ON DBLCLICK( iif(!lA102Visual ,(aTitulos[oLBoxTit:nAt,TIT_SELECT] := !aTitulos[oLBoxTit:nAt,TIT_SELECT] ,A102Refresh()) ,.T.) )

	oLBoxTit:SetArray( aTitulos )
	oLBoxTit:bLine := {|| { Iif(aTitulos[oLBoxTit:nAt][TIT_SELECT ],oOk,oNo) ,;
	                        aTitulos[oLBoxTit:nAt][TIT_PARCELA ]                                     ,aTitulos[oLBoxTit:nAt][TIT_TIPO      ] ,;
	                        aTitulos[oLBoxTit:nAt][TIT_VENCTO  ]                                     ,aTitulos[oLBoxTit:nAt][TIT_VLRTITULO ] ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_AMORT    ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_CMAMORT  ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_JUROS    ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_CMJUROS  ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_PRORATA  ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_JUROSMORA] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_MULTA    ] ,x3Picture("E1_VALOR")) }}
	oLBoxTit:Align := CONTROL_ALIGN_ALLCLIENT
	
	// monta o painel com os totais
	oPanel2 := TPanel():New( aPosObj[3,1] ,aPosObj[3,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[3,3] ,aPosObj[3,4] ,.T. ,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
    
	//
	// Quadro com os Parametros da renegociacao
	//
	nX := 0
	nY := 5
	@nX+05,nY to nX+72,nY+200 PROMPT STR0014 Of oPanel2 PIXEL

	@nX+22,nY+05 CHECKBOX oChkProRata   VAR lProRata   PROMPT STR0015 /*"Conceder Pro Rata (%a.a.)"*/ ;
   	              ON CHANGE {iIf( lProRata ,oGetProRata:enable() ,oGetProRata:Disable()) ,oGetProRata:refresh() ,A102Refresh() ,.T.} Of oPanel2 PIXEL SIZE 075,010 WHEN !lA102Visual
	@nX+22,nY+080 MSGET oGetProRata VAR nProRata VALID iIf(nProRata >= 0 .AND. nProRata <= 100,(A102Refresh(),.T.),.F.) PICTURE "@E 999.99" WHEN lProRata .AND. !lA102Visual Of oPanel2 PIXEL SIZE 030,010 HASBUTTON
   	
	@nX+34,nY+05 CHECKBOX oChkDescto   VAR lDescto   PROMPT STR0016 /*"Conceder % Desconto"*/ ;
   	              ON CHANGE {iIf( lDescto ,oGetPerc:enable() ,oGetPerc:disable()) ,oGetPerc:refresh() ,A102Refresh() ,.T.} Of oPanel2 PIXEL SIZE 075,010 WHEN !lA102Visual
	@nX+34,nY+080 MSGET oGetPerc VAR nPerDesc VALID iIf(nPerDesc >= 0 .AND. nPerDesc <= 100,(A102Refresh(),.T.),.F.) PICTURE PesqPict("LIZ","LIZ_PERDES") WHEN lDescto .AND. !lA102Visual Of oPanel2 PIXEL SIZE 030,010 HASBUTTON
   	
	@nX+46,nY+05 CHECKBOX oChkVenc     VAR lVenc     PROMPT STR0017 /*"Considerar desconto em Parcela Vencida" */ ON CHANGE {A102Refresh() ,.T.} Of oPanel2 PIXEL SIZE 140,010 WHEN !lA102Visual

	@nX+10,nY+120 CHECKBOX oChkJuros   VAR lJuros    PROMPT STR0018 /* "Retirar Juros" */ 			  ON CHANGE {A102Refresh(),oChkPRatAtr:Refresh(),.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !lA102Visual
	@nX+22,nY+120 CHECKBOX oChkPRatAtr VAR lPRatAtr  PROMPT STR0019 /* "Aplicar Pro Rata Atraso" */   ON CHANGE {A102Refresh(),.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !lA102Visual
	@nX+34,nY+120 CHECKBOX oChkJurMora VAR lJurMora  PROMPT STR0020 /* "Aplicar Juros Mora" */        ON CHANGE {A102Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !lA102Visual
	@nX+46,nY+120 CHECKBOX oChkMulta   VAR lMulta    PROMPT STR0021 /* "Aplicar Multa"    */          ON CHANGE {A102Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !lA102Visual

			
	//
	// Quadro com a situa็ใo financeiros dos titulos em renegociacao.
	//
	nX := 0
	nY := aPosObj[3,3] - 210

  	@nX+05,nY to nX+72,nY+95 PROMPT STR0022 /* NEGOCIADO */ Of oPanel2 PIXEL 
	
	@nX+10,nY+05 SAY oSay1Parc VAR STR0023 /* "Parcelas:" */   Of oPanel2 PIXEL
	@nX+22,nY+05 SAY oSay1Pena VAR STR0024 /* "Penalidades:" */ Of oPanel2 PIXEL
	@nX+34,nY+05 SAY oSay1Desc VAR STR0025 /* "Descontos:"   */ Of oPanel2 PIXEL 
	@nX+46,nY+05 SAY oSay1Nego VAR STR0026 /* "Negociado:"   */ Of oPanel2 PIXEL 

	
	@nX+10,nY+40 MSGET oGet1Parc VAR n1Parcela	  Of oPanel2 PIXEL PICTURE "@E 9,999,999.99" SIZE 040,010 WHEN .F.
	@nX+22,nY+40 MSGET oGet1Pena VAR n1Penalidade Of oPanel2 PIXEL PICTURE "@E 9,999,999.99" SIZE 040,010 WHEN .F.
	@nX+34,nY+40 MSGET oGet1Desc VAR n1Desconto   Of oPanel2 PIXEL PICTURE "@E 9,999,999.99" SIZE 040,010 WHEN .F.
	@nX+46,nY+40 MSGET oGet1Nego VAR n1Negociado  Of oPanel2 PIXEL PICTURE "@E 9,999,999.99" SIZE 040,010 WHEN .F.
	                                                     
	//
	// Quadro com a situa็ใo financeira do contrato.
	//
	If !lA102Visual
		nX := 0
		nY := aPosObj[3,3] - 100
	
		@nX+05,nY to nX+72,nY+95 PROMPT " SALDO DO CONTRATO " Of oPanel2 PIXEL
	
		@nX+10,nY+05 SAY oSay2Parc VAR STR0023 /* "Parcelas:" */       Of oPanel2 PIXEL
		@nX+22,nY+05 SAY oSay2Pena VAR STR0024 /* "Penalidades:" */    Of oPanel2 PIXEL
		@nX+34,nY+05 SAY oSay2Sald VAR STR0027 /* "Total do Saldo:" */ Of oPanel2 PIXEL
		                                                           
		n2Total := n2Parcela + n2Penalidade
	
		@nX+10,nY+45 MSGET oGet2Parc VAR n2Parcela    Of oPanel2 PIXEL PICTURE "@E 9,999,999.99"  SIZE 040,010 WHEN .F.
		@nX+22,nY+45 MSGET oGet2Pena VAR n2Penalidade Of oPanel2 PIXEL PICTURE "@E 9,999,999.99"  SIZE 040,010 WHEN .F.
		@nX+34,nY+45 MSGET oGet2Sald VAR n2Total      Of oPanel2 PIXEL PICTURE "@E 9,999,999.99"  SIZE 040,010 WHEN .F.
	Else             
		//
		A102Refresh(lA102Visual)
	EndIf
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( a102VldDlg( aCampos, n1Parcela, aConjLJU, aTitulos, (lMovBD) ) ;
								                           ,(lOk := .T.,oDlg:End()) ,Nil ) ;
								                    },{||lOk := .F.,oDlg:End()},,aButtons) VALID lOk
  
	If lOk .AND. (lA102Inclui .Or. lA102Altera .Or. lA102Exclui)
		// Separa os titulos selecionados
		For nCount := 1 TO Len(aTitulos)
			// Se o Titulo foi selecionado
			If aTitulos[nCount][TIT_SELECT]
				aAdd( aTitSelect ,aTitulos[nCount] )
			EndIf
		Next nCount
		
		If len(aTitSelect) > 0
			Begin Transaction
				Processa({||A102Grava( aTitSelect ,n1Negociado ,lA102Altera,lA102Exclui,nRecLIZ ,aConjLJU ) },STR0048,STR0049,.F.) //"Processando os titulos"###"Aguarde..."
				
				If ExistBlock("GEM102RE")
					ExecBlock("GEM102RE",.F.,.F.,{M->LIZ_NCONTR, aPontoEntra})
				EndIf

			End Transaction
		EndIf
		
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

//
// Valida os get do objeto painel 
//
Static Function A102Valid(aCampo)
Local lRet := .F.

	If Empty(&("M->"+aCampo[1]) )
		lRet := .T.
	Else
		If Empty(aCampo[7]) .Or. &(aCampo[7]) 
			RunTrigger(1,,,,aCampo[1])
			lRet := .T.
		EndIf
	EndIf
	
Return( lRet )	
   
//
// Valida os campos antes de sair da dialog
//
Static Function A102VldDlg( aCampos ,n1Parcela ,aConjLJU ,aAllTit, lAltera)
Local nX         := 1
Local nPosVal    := 0
Local nValor     := 0
Local nSldTitReg := 0
Local cText      := ""
Local lRet       := .T.
Local nQtdCnd	 := 0
Local nCount	 := 0

If lAltera
	aEval(aAllTit ,{|aTitulo,nPos| nSldTitReg += iIf( aTitulo[TIT_SELECT] ,aTitulo[TIT_VLRTITULO],0) } )
	
	If n1Parcela > 0 .and. n1Parcela == nSldTitReg //aScan(aAllTit ,{|aTitulo| aTitulo[TIT_SELECT] }) > 0
		For nX := 1 to len(aCampos)
			// Se o campo for obrigatorio.
			If aCampos[nX][9]
				If Empty(&("M->"+aCampos[nX][1]))
					cText := aCampos[nX][2] + Space(50-Len(aCampos[nX][2]))
					Help(1," ","OBRIGAT",,cText,3,0)
					lRet := .F.
					Exit
				EndIf
				
				// validacao da condicao de venda 
				If Alltrim(aCampos[nX][1]) == "LIZ_COND"
					// se a condicao de pagamento esta cadastrada
					If SE4->(dbSeek( xFilial("SE4")+&("M->"+aCampos[nX][1]) ))
						// se a condicao de pagamento for a personalizada
						If &("M->"+aCampos[nX][1]) == GetMV("MV_GMCPAG")
							If len(aConjLJU) != 3
								cText := STR0028    //"Condi็ใo de Venda nใo foi definida."
								cText += Space(50-Len(cText))
								Help(1," ","GEMA102",,cText,1,0)
								lRet := .F.
								Exit
							Else
								nPosVal := aScan(aConjLJU[2] ,{|e|Trim(e[2])=="LJU_VALOR"})
								nQtdCnd := aScan(aConjLJU[2], {|x| alltrim(x[2])==alltrim("LJU_NUMPAR")})		
						
								For nCount := 1 to Len(aConjLJU[3]) 
									If (aConjLJU[3][nCount][nQtdCnd] == 0) .AND. !(aConjLJU[3][nCount][Len(aConjLJU[3][nCount])])
										Alert(STR0050)  //"Existe quantidade zerada em algum item desta condi็ใo. Favor verificar." 
										lRet := .F.										
										Exit								
									Endif
								Next nCount
						
								If ! Empty(aConjLJU[3])
									aEval( aConjLJU[3] ,{|aColuna| iIf( !aColuna[Len(aColuna)]       ;
									                                   ,(nValor += aColuna[nPosVal] ) ;
									                                   ,.F.)})
	
									If !(n1Negociado == nValor)
										cText := STR0029   //"Condi็ใo de Venda nใo foi definida corretamente."
										cText += Space(50-Len(cText))
										Help(1," ","GEMA102",,cText,1,0)
										lRet := .F.
										Exit
									EndIf
							    EndIf
							
							EndIf
						EndIf
					Else
						cText := STR0030    //"Condi็ใo de Venda nใo foi existe."
						cText += Space(50-Len(cText))
						Help(1," ","GEMA102",,cText,1,0)
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
			
		Next nX
	Else
		lRet := .F.
		cText := STR0031  //"Nใo foi selecionada nenhuma parcela."
		cText += Space(50-Len(cText))
		Help(1," ","GEMA102",,cText,1,0)
	
	EndIf   
EndIf

Return( lRet )

//
// Carrega os titulos referentes ao contrato
//
Static Function A102LoadTitulo( cContrato ,cRevisa ,lVisual )
Local nVlrProRata   := 0
Local nVlrParcela   := 0
Local nVlrPrinc     := 0
Local nVlrCMPrinc   := 0
Local nVlrJuros     := 0
Local nVLrCMJuros   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nMeses        := 0
Local cUltFech      := GetMV("MV_GMULTFE")
Local aAllTits      := {}
Local aRet          := {}
Local aArea         := GetArea()
Local aVlrCM        := {}

//
// Visualizacao de uma renegociacao
// 
If lVisual
	// parcelas que foram renegociadas
	dbSelectArea("LJQ")
	dbSetOrder(1) // LJQ_FILIAL+LJQ_NCONTR+LJQ_REVISA+LJQ_PARCEL
	dbSeek(xFilial("LJQ")+cContrato+cRevisa)
	While LJQ->(!eof()) .AND. LJQ->LJQ_FILIAL+LJQ->LJQ_NCONTR+LJQ->LJQ_REVISA == xFilial("LJQ")+cContrato+cRevisa
	
		nVlrParcela := LJQ->LJQ_AMORT+LJQ->LJQ_CMAMOR+LJQ->LJQ_JUROS+LJQ->LJQ_CMJUR

		aAdd( aAllTits ,Array(TIT_LENGHT) )
		aAllTits[Len(aAllTits)][TIT_SELECT    ] := .T.
		aAllTits[Len(aAllTits)][TIT_PARCELA   ] := LJQ->LJQ_PARCEL
		aAllTits[Len(aAllTits)][TIT_TIPO      ] := LJQ->LJQ_TIPO
		aAllTits[Len(aAllTits)][TIT_VENCTO    ] := LJQ->LJQ_VENCTO
		aAllTits[Len(aAllTits)][TIT_VLRTITULO ] := nVlrParcela
		aAllTits[Len(aAllTits)][TIT_PRORATA   ] := LJQ->LJQ_CMATRA
		aAllTits[Len(aAllTits)][TIT_JUROSMORA ] := LJQ->LJQ_JURMOR
		aAllTits[Len(aAllTits)][TIT_MULTA     ] := LJQ->LJQ_MULTA
		aAllTits[Len(aAllTits)][TIT_AMORT     ] := LJQ->LJQ_AMORT
		aAllTits[Len(aAllTits)][TIT_CMAMORT   ] := LJQ->LJQ_CMAMOR
		aAllTits[Len(aAllTits)][TIT_JUROS     ] := LJQ->LJQ_JUROS
		aAllTits[Len(aAllTits)][TIT_CMJUROS   ] := LJQ->LJQ_CMJUR
		aAllTits[Len(aAllTits)][TIT_SLDOTITULO] := nVlrParcela
		
		LJQ->(dbSkip())
	EndDo        
	
//
// Inclusao de renegociacao
//	
Else
	If Empty(cUltFech)
		cUltFech := left(dtos(GMPrevMonth( dDataBase ,1 )),6)
	EndIf

	n2Parcela := 0

	// cadastro de contratos	
	dbSelectArea("LIT")   
	dbSetOrder(2) //LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato)
	
		nPorcJurMor := LIT->LIT_JURMOR
		// calcula o juros mora diario pelo indice proporcional
		If LIT->(FieldPos("LIT_JURTIP")) >0 .AND. LIT->LIT_JURTIP == "3"
			nPorcJurMor := LIT->LIT_JURMOR
		EndIf
		nPorcMulta  := LIT->LIT_MULTA
	
		// Itens do Contrato
		dbSelectArea("LIU")
		dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
		dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
		While LIU->(!eof()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == xFilial("LIT")+LIT->LIT_NCONTR)
			// Unidades
			dbSelectArea("LIQ")
			dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
			If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
				dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
			EndIf
			dbSelectArea("LIU")
			dbSkip()
		EndDo
		
		//
		// Detalhes da parcela
		//
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
		While LIX->(!eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+LIT->LIT_NCONTR
			//
			// titulos a receber
			dbSelectArea("SE1")
			dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If dbSeek(xFilial("SE1")+LIX->LIX_PREFIX+PadR(LIX->LIX_NUM, Len(LIX->LIX_NUM))+LIX->(LIX_PARCEL+LIX_TIPO))
				//		
				If SE1->E1_SALDO > 0
			
					nVlrPrinc     := LIX->LIX_ORIAMO  //LIX->LIX_ORIAMO - SE1->E1_VALLIQ
					nVlrJuros     := LIX->LIX_ORIJUR
					aVlrCM        := GMA102CM( LIX->(Recno()) ,dDatabase )
					cTaxa         := aVlrCM[1]
					nVlrCMPrinc   := aVlrCM[2]
					nVlrCMJuros   := aVlrCM[3]
					nMeses        := aVlrCM[4]
					
					//
					// valor do titulo corrigido
					//
					nVlrParcela := nVlrPrinc + nVlrJuros + nVlrCMPrinc + nVlrCMJuros
					
					nVlrProRata   := 0
					nVlrJurosMora := 0
					nVlrMulta     := 0
		
					// parcela em atraso, calcula-se a Pro-Rata por atraso diario, Juros Mora e Multa
					If dTos(SE1->E1_VENCREA) < dTos(dDatabase)
						// Condicao de venda
						dbSelectArea("LJO")
						dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
						If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
			
							If Empty(cTaxa)
								If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
									cTaxa := LJO->LJO_INDPOS
									nMeses:= LJO->LJO_NMES1
								Else               
									cTaxa := LJO->LJO_IND
									nMeses:= LJO->LJO_NMES2
								EndIf
							EndIf

						EndIf
						
						//
						// calcula a Pro-Rata Dia de Atraso, Juros mora e Multa do titulo
						//
						aRet := t_GEMAtraCalc( nVlrParcela ,SE1->E1_VENCREA ,cTaxa ,nMeses ,LJO->LJO_DIACOR ,nPorcJurMor ,nPorcMulta ,dDataBase ,LIT->LIT_JURTIP)
						
						nVlrProRata   := aRet[1] // Pro-Rata dia (CM diaria) por atraso na baixa do titulo 
						nVlrJurosMora := aRet[2] // Juros Mora dia por atraso na baixa do titulo
						nVlrMulta     := aRet[3] // Multa por atraso na baixa do titulo
						
					EndIf
					
					aAdd( aAllTits ,Array(TIT_LENGHT) )
					aAllTits[Len(aAllTits)][TIT_SELECT    ] := .F.            
					aAllTits[Len(aAllTits)][TIT_PARCELA   ] := SE1->E1_PARCELA
					aAllTits[Len(aAllTits)][TIT_TIPO      ] := SE1->E1_TIPO   
					aAllTits[Len(aAllTits)][TIT_VENCTO    ] := SE1->E1_VENCTO
					aAllTits[Len(aAllTits)][TIT_VLRTITULO ] := nVlrParcela    
					aAllTits[Len(aAllTits)][TIT_PRORATA   ] := nVlrProRata   
					aAllTits[Len(aAllTits)][TIT_JUROSMORA ] := nVlrJurosMora  
					aAllTits[Len(aAllTits)][TIT_MULTA     ] := nVlrMulta      
					aAllTits[Len(aAllTits)][TIT_AMORT     ] := nVlrPrinc
					aAllTits[Len(aAllTits)][TIT_CMAMORT   ] := nVlrCMPrinc
					aAllTits[Len(aAllTits)][TIT_JUROS     ] := nVlrJuros
					aAllTits[Len(aAllTits)][TIT_CMJUROS   ] := nVlrCMJuros 
					aAllTits[Len(aAllTits)][TIT_SLDOTITULO] := SE1->E1_SALDO  
					aAllTits[Len(aAllTits)][TIT_PREFIXO   ] := SE1->E1_PREFIXO
					aAllTits[Len(aAllTits)][TIT_NUMERO    ] := PadR(SE1->E1_NUM, Len(SE1->E1_NUM))
			
		   		Else
					aAdd( aAllTits ,Array(TIT_LENGHT) )
					aAllTits[Len(aAllTits)][TIT_SELECT    ] := .F.            
					aAllTits[Len(aAllTits)][TIT_PARCELA   ] := SE1->E1_PARCELA
					aAllTits[Len(aAllTits)][TIT_TIPO      ] := SE1->E1_TIPO   
					aAllTits[Len(aAllTits)][TIT_VENCTO    ] := SE1->E1_VENCTO
					aAllTits[Len(aAllTits)][TIT_VLRTITULO ] := SE1->E1_SALDO
					aAllTits[Len(aAllTits)][TIT_PRORATA   ] := 0
					aAllTits[Len(aAllTits)][TIT_JUROSMORA ] := 0
					aAllTits[Len(aAllTits)][TIT_MULTA     ] := 0
					aAllTits[Len(aAllTits)][TIT_AMORT     ] := 0
					aAllTits[Len(aAllTits)][TIT_CMAMORT   ] := 0
					aAllTits[Len(aAllTits)][TIT_JUROS     ] := 0
					aAllTits[Len(aAllTits)][TIT_CMJUROS   ] := 0
					aAllTits[Len(aAllTits)][TIT_SLDOTITULO] := SE1->E1_SALDO  
					aAllTits[Len(aAllTits)][TIT_PREFIXO   ] := SE1->E1_PREFIXO
					aAllTits[Len(aAllTits)][TIT_NUMERO    ] := PadR(SE1->E1_NUM, Len(SE1->E1_NUM))
				EndIf
				
				n2Parcela += SE1->E1_SALDO
			EndIf
			
			dbSelectArea("LIX")	
			dbSkip()
		EndDo
	EndIf
EndIf

If len(aAllTits) == 0
	aAdd( aAllTits ,Array(TIT_LENGHT) )
	aAllTits[Len(aAllTits)][TIT_SELECT    ] := .F.            
	aAllTits[Len(aAllTits)][TIT_PARCELA   ] := ""
	aAllTits[Len(aAllTits)][TIT_TIPO      ] := ""
	aAllTits[Len(aAllTits)][TIT_VENCTO    ] := ""
	aAllTits[Len(aAllTits)][TIT_VLRTITULO ] := 0
	aAllTits[Len(aAllTits)][TIT_PRORATA   ] := 0
	aAllTits[Len(aAllTits)][TIT_JUROSMORA ] := 0
	aAllTits[Len(aAllTits)][TIT_MULTA     ] := 0
	aAllTits[Len(aAllTits)][TIT_AMORT     ] := 0
	aAllTits[Len(aAllTits)][TIT_CMAMORT   ] := 0
	aAllTits[Len(aAllTits)][TIT_JUROS     ] := 0
	aAllTits[Len(aAllTits)][TIT_CMJUROS   ] := 0
	aAllTits[Len(aAllTits)][TIT_SLDOTITULO] := 0
	aAllTits[Len(aAllTits)][TIT_PREFIXO   ] := ""
	aAllTits[Len(aAllTits)][TIT_NUMERO    ] := ""
EndIf

restArea(aArea)
		
Return( aAllTits )


//
// Processa os dados para atualizar o listbox de titulos
//
Template Function GEMA102PRC( cContrato )
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

    // Carrega os titulos referentes ao contrato
	aTitulos := A102LoadTitulo( cContrato )
	
	oLBoxTit:SetArray( aTitulos )
	oLBoxTit:bLine := {|| { Iif(aTitulos[oLBoxTit:nAt][TIT_SELECT    ],oOk,oNo) ,;
	                        aTitulos[oLBoxTit:nAt][TIT_PARCELA   ]                                    ,aTitulos[oLBoxTit:nAt][TIT_TIPO      ] ,;
	                        aTitulos[oLBoxTit:nAt][TIT_VENCTO    ]                                    ,Transform( aTitulos[oLBoxTit:nAt][TIT_VLRTITULO ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_AMORT     ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_CMAMORT   ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_JUROS     ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_CMJUROS   ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_PRORATA   ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_JUROSMORA ] ,x3Picture("E1_VALOR")) ,;
 			                Transform( aTitulos[oLBoxTit:nAt][TIT_MULTA     ] ,x3Picture("E1_VALOR")) }}
 			                
 	oLBoxTit:refresh()
	n2Penalidade := 0                         
//	n2Residuo    := 0      
	aEval( aTitulos ,{|aTit| n2Penalidade := n2Penalidade + aTit[TIT_PRORATA]+aTit[TIT_JUROSMORA]+aTit[TIT_MULTA]} )
//	n2Total := n2Parcela + n2Penalidade + n2Residuo
	n2Total := n2Parcela + n2Penalidade

	oGet2Parc:refresh()
//	oGet2Resi:refresh()
	oGet2Pena:refresh()
	oGet2Sald:refresh() 

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A102Refresh บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os objeto do panel inferior                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Refresh(lVisual)
Local nX          := 0
Local nVlrParc    := 0
Local nPercent    := 0
Local nIndProRata := 0      

Default lVisual		:= .F.

	// Percentual do desconto na renegociacao
	nPercent     := nPerDesc/100

	n1Parcela	 := 0
//	n1Residuo	 := 0
	n1Penalidade := 0
	n1Desconto   := 0
	n1Negociado  := 0
    
	a1AcuDesc    := Array(4)
	aFill(a1AcuDesc,0)

	For nX := 1 To len(aTitulos)
	
	    // Titulo selecionado
		If aTitulos[nX][TIT_SELECT]
			// Saldo da Parcela 
			nVlrParc := aTitulos[nX][TIT_VLRTITULO]
			n1Parcela += nVlrParc
			// Retira o Juros da prestacao somente de prestacoes a vencer.
			If lJuros                 
				lPRatAtr := .F.	
				oChkPRatAtr:Disable()
				If SubStr(DTOS(aTitulos[nX][TIT_VENCTO]),1,6) > SubStr(DTOS(dDataBase),1,6)
					a1AcuDesc[1] += aTitulos[nX][TIT_JUROS]+aTitulos[nX][TIT_CMJUROS]
				EndIf 
			else
				oChkPRatAtr:Enable()
			Endif   
//			n1Residuo	 := 0
			
			// Se aplica Juros Mora
			n1Penalidade += aTitulos[nX][TIT_JUROSMORA]
			If !lJurMora  
				a1AcuDesc[2] += aTitulos[nX][TIT_JUROSMORA]
			Endif
			
			// Se aplica Multa
			n1Penalidade += aTitulos[nX][TIT_MULTA]
			If !lMulta
				a1AcuDesc[3] += aTitulos[nX][TIT_MULTA]
			EndIf
			
			// Aplica a Pro Rata nos titulos
			If lProRata
				If nProRata > 0
					If dTos(aTitulos[nX][TIT_VENCTO]) > dTos(dDataBase)
						nIndProRata := round((1+(nProRata/100))^(1/360)-1,7)
						a1AcuDesc[4] += NoRound( nVlrParc - nVlrParc*((1+nIndProRata)^((aTitulos[nX][4]-dDataBase)*-1)) ,TamSX3("E1_SALDO")[2])
					EndIf
				EndIf
			EndIf
			
			// Se desconta os titulos
			If lDescto
				If nPercent > 0
					If dTos(aTitulos[nX][TIT_VENCTO]) < dTos(dDataBase)
						If lVenc
							a1AcuDesc[4] += NoRound( nVlrParc*nPercent ,TamSX3("E1_SALDO")[2])
						EndIf
					Else
						a1AcuDesc[4] += NoRound( nVlrParc*nPercent ,TamSX3("E1_SALDO")[2])
					EndIf
				EndIf
			EndIf
			
			// se considera a Pro Rata diario de atraso do titulo a receber
			If lPRatAtr
				n1Penalidade += aTitulos[nX][TIT_PRORATA]
			EndIf
			
		EndIf
	Next nX
	                   
	aEval( a1AcuDesc,{|nValor| n1Desconto += nValor })
//	n1Negociado := NoRound( (n1Parcela+n1Residuo+n1Penalidade)-n1Desconto ,TamSX3("E1_SALDO")[2])
	n1Negociado := NoRound( (n1Parcela+n1Penalidade)-n1Desconto ,TamSX3("E1_SALDO")[2])
	
	oGet1Parc:refresh()
//	oGet1Resi:refresh() 
	oGet1Pena:refresh()
	oGet1Desc:refresh()
	oGet1Nego:refresh()
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA120DLGCVNบAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog para customizar a condicao de venda e simular os    บฑฑ
ฑฑบ          ณ titulos a receber.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMA120.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102DLGCVN( nOpcX ,cContrato ,cRevisa ,cCondPag ,d1Venc ,aConjLJU )
Local cCadastro   := STR0032
Local nUsado      := 0
Local nY          := 0
Local nOpcGD      := 0
Local nVlrTotal   := 0
Local lContinua   := .T. 
Local aHeadTit    := { STR0003, STR0005, STR0033, STR0006, STR0034, STR0035 }
Local aObjects    := {}
Local aSize       := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aColsOri    := {}
Local aHeadLJU    := {}
Local aColsLJU    := {}
Local aArea       := GetArea()

Local oDlg
Local oPnlCab 
Local oCod 
Local oDescr
Local oValor
Local oPnlTit 
Local oArialBold 

Private aGets[0]
Private aTela[0][0]
Private oGetCVnd
Private oBrwTit 
Private nSaldoDup := 0
	
	If n1Negociado != NIL
		nVlrTotal := n1Negociado 
		nSaldoDup := nVlrTotal
	EndIf

	// carrega o aheader e acols do browse dos itens de pagamento da tabela LJU
	A102LJULoad( cContrato ,cRevisa ,cCondPag ,d1Venc ,nVlrTotal ,@aConjLJU )
    
	aHeadLJU := aConjLJU[2]
	aColsLJU := aConjLJU[3]
	
	If lContinua
	    // Os registros com valor original
		aColsOri := aClone(aColsLJU)

		dbSelectArea("LJU")
		RegToMemory( "LJU" ,(nOpcX==3) )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz o calculo automatico de dimensoes de objetos     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,00 TO 40,90 of oMainWnd 
		DEFINE FONT oArialBold NAME "Arial" SIZE 0, -16 BOLD
		
		If nOpcX == 3 .Or. nOpcX == 4
			nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
		Else
			nOpcGD := 0
		EndIf
	
	    // Valor total da venda
		@ 5 ,240 SAY OemToAnsi(STR0036)+Transform(nVlrTotal ,x3Picture("LIZ_NEGOC") ) FONT oArialBold SIZE 200,16 PIXEL OF oDlg

		// visualiza a condicao de venda
		// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
		oGetCVnd := MsNewGetDados():New( 20,10,100,350 ,nOpcGD ,"AllwaysTrue","AllwaysTrue","+LJU_ITEM",,,9999,,,,oDlg,aHeadLJU,aColsLJU)
	
		// visualiza as parcelas conforme a condicao de venda informado
		oPnlTit := TPanel():New(110,10,'',oDlg, ,.T.,.T.,, ,340,100,.T.,.T. )
		
		oBrwTit := TWBrowse():New( 5,10,100,340,,aHeadTit ,/*tamanho*/ ,oPnlTit,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
		oBrwTit:Align := CONTROL_ALIGN_ALLCLIENT
		a102BrwRefresh( oGetCVnd:aHeader ,aColsLJU ,@oBrwTit )
	
		@ 220,170 BUTTON OemToAnsi(STR0037)/*recalcular*/ SIZE 040,11 ACTION a102BrwRefresh( oGetCVnd:aHeader ,oGetCVnd:aCols ,@oBrwTit ) OF oDlg WHEN nOpcGD <> 0 PIXEL
		@ 220,220 BUTTON OemToAnsi(STR0038)/*confirmar*/  SIZE 040,11 ACTION (Iif( A102Conf( @oDlg ,nVlrTotal ,aConjLJU[1] ,aColsOri ,@aConjLJU, aHeadLJU ),oDlg:End(),.F.)) OF oDlg WHEN nOpcGD <> 0 PIXEL
		@ 220,270 BUTTON OemToAnsi(STR0039)/*sair*/       SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL
		
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	
	RestArea(aArea)
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa102LJULoaบAutor  ณReynalo Miyashita   บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os dados da condicao de venda conforme a condicao  บฑฑ
ฑฑบ          ณ de pagamento informado no Contrato.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102LJULoad( cContrato ,cRevisa ,cCondPag ,d1Venc ,nVlrTotal ,aConjLJU )
Local nPos_FIXVNC := 0
Local nPos_VALOR  := 0
Local nPos_PERCLT := 0
Local nPos_1VENC  := 0
Local nPosJurIni  := 0
Local nY          := 0
Local aHeadLJU    := {}
Local aColsLJU    := {}
Local aArea       := GetArea()

DEFAULT d1Venc    := 0
DEFAULT nVlrTotal := 0
	
If !Empty(aConjLJU)
	If cCondPag == aConjLJU[1]
		aHeadLJU := aConjLJU[2]
		aColsLJU := aConjLJU[3]
	EndIf
EndIf
	
If len(aHeadLJU)==0
	// monta o aHeadLJU
	aHeadLJU := aClone(TableHeader("LJU"))
	aEval( aHeadLJU ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
	nY := aScan( aHeadLJU ,{|aCampo| alltrim(aCampo[2])=="LJU_PERCLT"})
	If nY > 0
		If Empty(aHeadLJU[nY][6])
			aHeadLJU[nY][6] := "t_GMA102Perc()"
		Else
			aHeadLJU[nY][6] := aHeadLJU[nY][6] + " .AND. t_GMA102Perc()"
		EndIf
	EndIf
	
	nY := aScan( aHeadLJU ,{|aCampo| alltrim(aCampo[2])=="LJU_VALOR"})
	If nY > 0
		If Empty(aHeadLJU[nY][6])
			aHeadLJU[nY][6] := "t_GMA102Perc()"
		Else
			aHeadLJU[nY][6] := aHeadLJU[nY][6] + " .AND. t_GMA102Perc()"
		EndIf
	EndIf
	
	nY := aScan( aHeadLJU ,{|aCampo| alltrim(aCampo[2])=="LJU_TPSIST"})
	If nY > 0
		If Empty(aHeadLJU[nY][6])
			aHeadLJU[nY][6] := "t_GEMDTJUR('LJU', dHabite)"
		Else
			aHeadLJU[nY][6] := aHeadLJU[nY][6] + " .AND. t_GEMDTJUR('LJU', dHabite)"
		EndIf
	EndIf

EndIf
                   
nUsado := Len(aHeadLJU)
	
If Len(aColsLJU) == 0
	If cCondPag != GetMV("MV_GMCPAG")
		// condicao de pagamento
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
		If dbSeek(xFilial("SE4")+cCondPag)
			// condicao de venda - cabecalho
			dbSelectArea("LIR")
			LIR->(dbSetOrder(1)) // LIR_FILIAL+LIR_CODCND
			If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Faz a montagem do aColsLJU                                   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("LIS")
				LIS->(dbSetOrder(1)) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
				If dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Faz a montagem do aColsLJU                                   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					While !Eof() .And. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
						aAdd(aColsLJU,Array(Len(aHeadLJU)+1))
						For nY := 1 to Len(aHeadLJU)
							If LIS->(FieldPos("LIS"+substr(aHeadLJU[ny][2],4))) >0
								If ( aHeadLJU[ny][10] != "V")
									aColsLJU[Len(aColsLJU)][nY] := FieldGet(FieldPos("LIS"+substr(aHeadLJU[nY][2],4)))
								Else
									aColsLJU[Len(aColsLJU)][nY] := CriaVar(aHeadLJU[ny][2])
								EndIf
							Else
								aColsLJU[Len(aColsLJU)][nY] := CriaVar(aHeadLJU[ny][2])
							EndIf
							
						Next nY
							
						If (nPos_PERCLT := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_PERCLT"}) ) >0
							If (nPos_VALOR := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_VALOR"} )) >0
								aColsLJU[Len(aColsLJU)][nPos_VALOR] := nVlrTotal*(aColsLJU[Len(aColsLJU)][nPos_PERCLT]/100)
							Endif
						EndIf
						
						If (nPos_1VENC := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_1VENC" }) ) >0
							nPos_FIXVNC := aScan( aHeadLJU ,{|x|x[2]=="LJU_FIXVNC" })
							If nPos_FIXVNC > 0 .and. aHeadLJU[nPos_FIXVNC][2] == "2"
								aColsLJU[Len(aColsLJU)][nPos_1VENC] := d1Venc
							Endif
       					EndIf
       					
						aColsLJU[Len(aColsLJU)][Len(aHeadLJU)+1] := .F.
						
						dbSelectArea("LIS")
						dbSkip()
					EndDo
				EndIf
	        EndIf
		EndIf
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz a montagem do aColsLJU                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("LJU")
		LJU->(dbSetOrder(1)) // LJU_FILIAL+LJU_NCONTR+LJU_REVISA+LJU_ITEM
		dbSeek(xFilial("LJU")+cContrato+cRevisa)
		While !Eof() .And. LJU->LJU_FILIAL+LJU->LJU_NCONTR+LJU->LJU_REVISA==xFilial("LJU")+cContrato+cRevisa
			aAdd(aColsLJU,Array(Len(aHeadLJU)+1))
			For nY := 1 to Len(aHeadLJU)
				If ( aHeadLJU[ny][10] != "V")
					aColsLJU[Len(aColsLJU)][nY] := FieldGet(FieldPos(aHeadLJU[nY][2]))
				Else
					aColsLJU[Len(aColsLJU)][nY] := CriaVar(aHeadLJU[nY][2])
				EndIf
			Next nY
			If (nPos_1VENC := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_1VENC" }) ) >0
				nPos_FIXVNC := aScan( aHeadLJU ,{|x|x[2]=="LJU_FIXVNC" })
				If nPos_FIXVNC > 0 .and. aHeadLJU[nPos_FIXVNC][2] == "2"
					aColsLJU[Len(aColsLJU)][nPos_1VENC] := d1Venc
				Endif
  			EndIf
			If (nPos_PERCLT := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_PERCLT"}) ) >0
				If (nPos_VALOR := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_VALOR"} )) >0
					// Calcula a percentual
					aColsLJU[Len(aColsLJU)][nPos_PERCLT] := round( (aColsLJU[Len(aColsLJU)][nPos_VALOR]/nVlrTotal)*100,aHeadLJU[nPos_PERCLT][5])
		        EndIf
  			EndIf
			aColsLJU[Len(aColsLJU)][Len(aHeadLJU)+1] := .F.
			dbSelectArea("LJU")
			dbSkip()
		EndDo
	EndIf   

	//
	// atualiza os valores a serem financiados 
	//
Else        
	nPos_VALOR := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_VALOR" } ) 
	nPos_PERCLT := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_PERCLT" } ) 
	If nPos_Valor > 0 .AND. nPos_PERCLT > 0
		For nY := 1 to Len(aColsLJU)
			// se o item nao foi deletado 
			If !aColsLJU[nY][Len(aHeadLJU)+1]
				// Calcula a percentual
				aColsLJU[nY][nPos_PERCLT] := round( (aColsLJU[nY][nPos_VALOR]/nVlrTotal)*100,aHeadLJU[nPos_PERCLT][5])
			Endif
		Next nY
	EndIf
EndIf
    
// Se naum tiver nenhum item
If Empty(aColsLJU)
	aadd(aColsLJU,Array(Len(aHeadLJU)+1))
	For nY := 1 to Len(aHeadLJU)
		If Trim(aHeadLJU[nY][2]) == "LJU_ITEM"
			aColsLJU[1][nY] := StrZero(1, TamSX3("LJU_ITEM")[1])
		Else
			aColsLJU[1][nY] := CriaVar(aHeadLJU[nY][2])
		EndIf
	Next nY
	aColsLJU[1][Len(aHeadLJU)+1] := .F.

	LIU->(DbSetOrder(3)) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
	LIU->(DbSeek(xFilial("LIU")+cContrato))
	nPosJurIni := aScan( aHeadLJU ,{|aCol| aCol[2] == "LJU_JURINI" } ) 
	While !LIU->(Eof()) .And. xFilial("LIU")+cContrato==LIU->(LIU_FILIAL+LIU_NCONTR)
		If !Empty(LIU->LIU_CODEMP)
			If LIQ->(DbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)) //LIQ_FILIAL+LIQ_COD
				aColsLJU[1][nPosJurIni] := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
				Exit
			EndIf
		EndIf
		LIU->(DbSkip())
	EndDo
Endif

RestArea(aArea)
	
aConjLJU := aClone({cCondPag ,aHeadLJU ,aColsLJU})
	
Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA102PercบAutor  ณReynaldo Miyashita  บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a coluna de porcentagem do browse de condicao de    บฑฑ
ฑฑบ          ณ venda.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMA102.PRW                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA102Perc()
Local lOk        := .T.
Local nPosPerc   := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJU_PERCLT"})
Local nPosValor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJU_VALOR"})
Local nPorc      := 0
Local nPorcTotal := 0
Local nVlrParc   := 0
Local nVlrTotal  := 0
Local cVar       := ReadVar()

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

aEval( oGetCVnd:aCols ,{|aColuna,nIndex| iIf( !aColuna[Len(aColuna)] .AND. n <> nIndex ;
                                    ,(nPorc += aColuna[nPosPerc] ,nVlrParc += aColuna[nPosValor]) ;
                                    ,.F.)})

Do Case
	// Valor 
	Case cVar == "M->LJU_VALOR"
		nVlrTotal := nSaldoDup - nVlrParc
		If M->LJU_VALOR <= nVlrTotal
			M->LJU_PERCTL := Round(((100 * M->LJU_VALOR) / nSaldoDup ),oGetCVnd:aHeader[nPosPerc,5])
			oGetCVnd:aCols[n][nPosPerc] := M->LJU_PERCTL
		Else
			MsgAlert(STR0040 + transform( nVlrTotal ,x3Picture("E1_VALOR")) ) //"Valor nใo pode ser superior a
			lOk := .F.
		EndIf
		
	// Porcentagem
	Case cVar == "M->LJU_PERCLT"
		nPorcTotal := 100 - nPorc 
		If M->LJU_PERCLT <= nPorcTotal
			M->LJU_VALOR := Round(( nSaldoDup * M->LJU_PERCLT / 100),2)
			oGetCVnd:aCols[n][nPosValor] := M->LJU_VALOR
		Else
			MsgAlert(STR0041 + transform( nPorcTotal ,"@E 999.99%") ) //A porcentagem nใo pode ser superior a
			lOk := .F.
		EndIf
EndCase

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa102BrwRefบAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o browse com os valores dos titulos conforme       บฑฑ
ฑฑบ          ณ condicao de venda montado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a102BrwRefresh( aHeader ,aCols ,oBrw )
Local aTitSimul := {}
Local aTits     := {}

	
	// gera os titulos a receber para visualizar conforme a customizacao da condicao de venda
	aTitSimul := GeraDuplCond( aHeader, aCols, 4, "LJU" )
	
	If Empty(aTitSimul)
		aTitSimul := {{"" ,stod(""),"",0,0,0 }}
	EndIf
	Aeval(aTitSimul ,{|aTitulo| aAdd(aTits ,{ aTitulo[1] , ;
															transform(aTitulo[2],x3Picture("E1_VENCTO")) , ;
															aTitulo[3] , ;
															transform(aTitulo[4],x3Picture("E1_VALOR")), ;
															transform(aTitulo[4]-aTitulo[5],x3Picture("E1_VALOR")), ;
															transform(aTitulo[5],x3Picture("E1_VALOR")) } ) })

	oBrw:SetArray(aTits)
	oBrw:bLine := {|| aTits[oBrw:nAT] }
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102Conf  บAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirmacao da customizacao da condicao de venda.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Conf( oDlg ,nVlrNegoc ,cCondPag ,aColsOri ,aConjLJU , aHeadOri) 
Local nPos        := 0
Local nTotal      := 0
Local nCount      := 0
Local nPos_Valor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJU_VALOR"})
Local lModificado := .F.
Local lContinua   := .T.
Local aColsLJU    := {}
Local nQtdCnd	  := 0
    
aEval( oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[Len(aColuna)]     ;
                                ,(nTotal += aColuna[nPos_Valor] ) ;
                                ,.F.)})

nQtdCnd := aScan(aHeadOri,{|x| alltrim(x[2])==alltrim("LJU_NUMPAR")})

If nTotal <> nVlrNegoc
	MsgAlert(STR0042)  //O valor de renegociacao difere do valor total de titulos negociados.
	lContinua := .F.
EndIf
         
If lContinua
	If cCondPag <> GetMV("MV_GMCPAG")
    	//
    	// avalia o oGetCVnd:aCols com o aColsOri para verificar se houve alteracao nos itens da condicao de venda, Dia da correcao monetaria,tipo de price
    	//                                             
		For nCount := 1 to Len(aColsOri)
	    	// numero de parcelas, valor , tipo de parcela, Fixa data de vencimento, Data de vencimento, Tipo de Sistema, TAXA anual , indice
	    	// for diferente do original
	    	nPos := aScan( oGetCVnd:aCols ,{|aColuna| !aColuna[len(oGetCVnd:aHeader)+1] .AND. ;
	    	                                          aColuna[02] == aColsOri[nCount][02] .AND. aColuna[03] == aColsOri[nCount][03] .AND. aColuna[05] == aColsOri[nCount][05] .AND. aColuna[07] == aColsOri[nCount][07] .AND. ;
	     	                                          aColuna[07] == aColsOri[nCount][07] .AND. aColuna[10] == aColsOri[nCount][10] .AND. aColuna[12] == aColsOri[nCount][12] .AND. aColuna[13] == aColsOri[nCount][13] .AND. ;
	     	                                          aColuna[14] == aColsOri[nCount][14] .AND. aColuna[15] == aColsOri[nCount][15] .AND. aColuna[16] == aColsOri[nCount][16] })
	    	If nPos == 0
	    		lModificado := .T.
				Exit
			EndIf

		Next nCount                   
	
	EndIf
	
	If lModificado
		M->LIZ_COND := GetMV("MV_GMCPAG")
	EndIf                       
	
	aColsLJU := {}
	aEval(oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[len(oGetCVnd:aHeader)+1] ,aAdd( aColsLJU ,aColuna ) ,.F.)}) 
	
	aConjLJU := aClone({M->LIZ_COND ,oGetCVnd:aHeader ,aColsLJU })
	
EndIf

Return( lContinua )

//
// Processa os dados para atualizar o listbox de titulos
//
Static Function A102Grava( aTitSelect ,n1Negociado ,lA102Altera,lA102Exclui,nRecLIZ ,aConjLJU )
Local bCampo       := {|n| FieldName(n) }
Local nMoeda       := 1
Local nVlrFin      := 0
Local nPerCorr     := 0 
Local nCount       := 0
Local nCntFor      := 0
Local nAbatim      := 0
Local nTitDescto   := 0
Local nTotalDesc   := 0
Local nPosParcela  := 0
Local nPosItem     := 0
Local nPosTIPPAR   := 0
Local nPosPERCLT   := 0
Local nPosVALOR    := 0
Local nPosTPSIST   := 0
Local nPosTAXANO   := 0
Local nPosNUMPAR   := 0
Local nPosTPPRIC   := 0
Local nPos1VENC    := 0
Local nPosJURINI   := 0
Local nPosField    := 0
Local nQtdTit      := 0
Local cNewRevisa   := ""
Local cTipoParc    := ""
Local cSA1_NATUR   := ""
Local lCondVenda   := .F.
Local aAcumula     := {}
Local aTitRec      := {}
Local aNewTitRec   := {}

Local aSE1Recno    := {}
Local aLiquidacao  := {}
Local aSE1Dados    := {}
Local aNewSE1      := {}
Local aDetTit      := {}
Local aLJUxLJO     := {}
Local aArea        := GetArea()
Local dJurosINI

Local aUltParc     := {}
Local nX           := 0
Local aCamposLJO   := {}
Local aVetor	   := {}
Local aEstorno     := {}
If ! lA102Exclui

	If ! lA102Altera
		// LIT - cadastro de contratos
		dbSelectArea("LIT")
		dbSetOrder(2)//LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+M->LIZ_NCONTR)
		
			dbSelectArea("SA1")
			dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			If dbSeek(xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA)
				cSA1_NATUR := &(SuperGetMv("MV_1DUPNAT"))
			EndIf
			
			cNewRevisa := Soma1(LIT->LIT_REVISA)
			
			//
			// Grava o Historico do contrato
			//
			t_GMHistContr( M->LIZ_NCONTR ,M->LIZ_REVISA ,cNewRevisa ,"" )
			
			//
			// Grava a renegociacao da condicao de pagamento
			//
			RecLock("LIZ",.T.)
				For nCount := 1 TO FCount()
					LIZ->(FieldPut(nCount,M->&(EVAL(bCampo,nCount))))
				Next nCount
				
				LIZ->LIZ_NEGOC   := n1Negociado
//				LIZ->LIZ_RESID   := lResiduo 
				LIZ->LIZ_CMATRAS := lPRatAtr
				LIZ->LIZ_DESCTO  := lDescto 
				LIZ->LIZ_VENCID  := lVenc   
				LIZ->LIZ_RETJUR  := lJuros  
				LIZ->LIZ_JURMOR  := lJurMora
				LIZ->LIZ_MULTA   := lMulta
				LIZ->LIZ_PERDES  := iIf( lDescto ,nPerDesc ,0)
				LIZ->LIZ_PRORAT  := iIf( lProRata ,nProRata ,0)
				
			LIZ->(MsUnlock())
			   
			// Gravar a condicao de venda
			// se for uma condicao de venda personalizada.
			If LIZ->LIZ_COND == GetMV("MV_GMCPAG")
				// a condicao de pagamento tem uma condicao de venda referenciada
				lCondVenda := .T.

				nPosParcela := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_NUMPAR"})
				nPosItem    := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_ITEM"})
				
				dbSelectArea("LJU")
				For nCount := 1 To len(aConjLJU[3])
					// se o item nao foi deletado
					If !aConjLJU[3][nCount][Len(aConjLJU[2])+1]
						// se a qtd de parcelas no item ้ maior q zero
						If aConjLJU[3][nCount][nPosParcela]>0
						
							RecLock("LJU",.T.)
							
							For nCntFor := 1 To Len(aConjLJU[2])
								If ( aConjLJU[2][nCntFor][10] != "V" )
									LJU->(FieldPut(FieldPos(aConjLJU[2][nCntFor][2]),aConjLJU[3][nCount][nCntFor]))
								EndIf
							Next nCntFor
							
							LJU->LJU_FILIAL := xFilial("LJU")
							LJU->LJU_NCONTR := M->LIZ_NCONTR 
							LJU->LJU_REVISA := M->LIZ_REVISA
							
							MsUnlock()
							
							A102LJOGrv( LJU->(Recno()) ,aLJUxLJO )
							
						EndIf
					EndIf
				Next nCount
			Else
				If Empty(aConjLJU)
					aConjLJU := {"",{},{}}
				EndIf
				
				// Condicao de pagamento
				dbSelectArea("SE4")
				dbSetOrder(1) // E4_FILIAL+E4_CODIGO
				If dbSeek(xFilial("SE4")+LIZ->LIZ_COND)
					//
					If ! Empty(SE4->E4_CODCND)
						// Condicao de venda
						dbSelectArea("LIR")
						dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
						If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
									
							// a condicao de pagamento tem uma condicao de venda referenciada
							lCondVenda := .T.
							
							aConjLJU[2] := aClone(TableHeader("LJU"))
							aConjLJU[3] := {}
							nPosItem    := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_ITEM"})
							
							// Itens da Condicao de venda
							dbSelectArea("LIS")
							dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
							dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
	
							// Copia a condicao de venda referenciado na condicao de pagamento do 
							// pedido de venda para o contrato
							While LIS->(!eof()) .AND. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
							
								RecLock("LJU",.T.)
								
								LJU->LJU_FILIAL := xFilial("LJU")
								LJU->LJU_NCONTR := M->LIZ_NCONTR 
								LJU->LJU_REVISA := M->LIZ_REVISA 
								
								LJU->LJU_ITEM   := LIS->LIS_ITEM
								LJU->LJU_NUMPAR := LIS->LIS_NUMPAR
								If LJU->(FieldPos("LJU_PERCLT"))>0
									LJU->LJU_PERCLT := LIS->LIS_PERCLT
								EndIf
								LJU->LJU_TIPPAR := LIS->LIS_TIPPAR
								LJU->LJU_TPDESC := LIS->LIS_TPDESC
								LJU->LJU_FIXVNC := "2"
								LJU->LJU_1VENC  := dDatabase
								LJU->LJU_TPSIST := LIS->LIS_TPSIST
								LJU->LJU_TAXANO := LIS->LIS_TAXANO
								LJU->LJU_COEF   := LIS->LIS_COEF
								LJU->LJU_IND    := LIS->LIS_IND
								LJU->LJU_DIACOR := LIS->LIS_DIACOR
								LJU->LJU_TPPRIC := LIS->LIS_TPPRIC
//								LJU->LJU_RESID  := LIS->LIS_RESID
//								LJU->LJU_PARRES := LIS->LIS_PARRES
								
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณ Faz a montagem do aColsLJU                                ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								dbSelectArea("LIS")
								dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
								aAdd(aConjLJU[3] ,Array(Len(aConjLJU[2])+1))
								For nCount := 1 to Len(aConjLJU[2])
									If (nPosField := LIS->(FieldPos("LIS"+substr(aConjLJU[2][nCount][2],4)))) >0
										If ( aConjLJU[2][nCount][10] != "V")
											aConjLJU[3][Len(aConjLJU[3])][nCount] := FieldGet(nPosField)
										Else
											aConjLJU[3][Len(aConjLJU[3])][nCount] := CriaVar(aConjLJU[2][nCount][2])
										EndIf
									Else
										aConjLJU[3][Len(aConjLJU[3])][nCount] := CriaVar(aConjLJU[2][nCount][2])
									EndIf
										
								Next nCount
								
								If (nPosPERCLT := aScan( aConjLJU[2] ,{|aCol| aCol[2] == "LJU_PERCLT" }) ) >0
									If (nPos_VALOR := aScan( aConjLJU[2] ,{|aCol| aCol[2] == "LJU_VALOR" })) >0
										aConjLJU[3][Len(aConjLJU[3])][nPos_VALOR] := nVlrContrato*(aConjLJU[3][Len(aConjLJU[3])][nPosPERCLT]/100)
									Endif
								EndIf
									
								aConjLJU[3][Len(aConjLJU[3])][Len(aConjLJU[2])+1] := .F.
								
								LJU->(MSUnLock())
								A102LJOGrv( LJU->(Recno()) ,aLJUxLJO )

								LIS->(dbSkip())
								
							EndDo
						EndIf
					EndIf
				EndIf
			EndIf
			
			aAcumula := aClone(a1AcuDesc)
			nQtdTit  := Len(aTitSelect)
			
			// Grava os Titulos renegociados
			For nCount := 1 TO nQtdTit
				// Se o Titulo foi selecionado
				If aTitSelect[nCount][TIT_SELECT]
					
					// Troca o Tipo de titulo, se for necessario
					If A102SubTitCr( aTitSelect[nCount][TIT_PREFIXO],aTitSelect[nCount][TIT_NUMERO],aTitSelect[nCount][TIT_PARCELA],aTitSelect[nCount][TIT_TIPO],MVNOTAFIS )
						aTitSelect[nCount][TIT_TIPO] := MVNOTAFIS
					EndIf
					
					RecLock("LJQ" ,.T.)
						LJQ->LJQ_FILIAL := xFilial("LJQ")
						LJQ->LJQ_NCONTR := M->LIZ_NCONTR
						LJQ->LJQ_REVISA := M->LIZ_REVISA
						LJQ->LJQ_PARCEL := aTitSelect[nCount][TIT_PARCELA  ]
						LJQ->LJQ_TIPO   := aTitSelect[nCount][TIT_TIPO     ]
						LJQ->LJQ_VENCTO := aTitSelect[nCount][TIT_VENCTO   ]
						LJQ->LJQ_CMATRA := aTitSelect[nCount][TIT_PRORATA  ]
						LJQ->LJQ_JURMOR := aTitSelect[nCount][TIT_JUROSMORA]
						LJQ->LJQ_MULTA  := aTitSelect[nCount][TIT_MULTA    ]
						LJQ->LJQ_AMORT  := aTitSelect[nCount][TIT_AMORT    ]
						LJQ->LJQ_CMAMOR := aTitSelect[nCount][TIT_CMAMORT  ]
						LJQ->LJQ_JUROS  := aTitSelect[nCount][TIT_JUROS    ]
						LJQ->LJQ_CMJUR  := aTitSelect[nCount][TIT_CMJUROS  ]
					LJQ->(MsUnlock())
					

					// DETALHES dos titulos a receber selecionados
					dbSelectArea("LIX")
					dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
					If dbSeek(xFilial("LIX")+aTitSelect[nCount,TIT_PREFIXO]+aTitSelect[nCount,TIT_NUMERO]+aTitSelect[nCount,TIT_PARCELA]+aTitSelect[nCount,TIT_TIPO])
						// baixa os titulos a receber selecionados
						dbSelectArea("SE1")
						dbSetOrder(1) //  E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL))
							//	
							// Cabecalho do contrato
							//
							dbSelectArea("LIT")
							dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
							If dbSeek(xFilial("LIT")+LIX->LIX_NCONTR)
								//	
								// Condicao de venda
								//
								dbSelectArea("LJO")
								dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
								If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND)
									RecLock("LJO",.F.)
										LJO->LJO_NUMPAR := LJO->LJO_NUMPAR-1
										LJO->LJO_VALOR  := LJO->LJO_VALOR-LIX->LIX_ORIAMO
									LJO->(MsUnLock())
								EndIf
						 	EndIf
						EndIf
						
						// Valor de abatimento
						nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
						// Saldo Corrente do Titulo na Moeda do Titulo
						nSldTitulo := Max(SE1->E1_SALDO-nAbatim ,0)
						nSldTitulo += aTitSelect[nCount][TIT_CMAMORT] + aTitSelect[nCount][TIT_CMJUROS]
						nTotalDesc := 0
						
						// Desconta o Juros Mensal e CM do Juros Mensal
						If lJuros
							aAcumula[1] -= aTitSelect[nCount][TIT_JUROS]+aTitSelect[nCount][TIT_CMJUROS] 
							If nQtdTit == nCount
								aTitSelect[nCount][TIT_JUROS] += aAcumula[1]
							EndIf  
							If SubStr(DTOS(aTitSelect[nCount][4]),1,6) > SubStr(DTOS(dDataBase),1,6)
								nTotalDesc +=  aTitSelect[nCount][TIT_JUROS]+aTitSelect[nCount][12]+aTitSelect[nCount][TIT_CMJUROS] 
							EndIF
						EndIf
						
						// Desconta o Juros Mora
						If ! lJurMora
							aAcumula[2] -= aTitSelect[nCount][TIT_JUROSMORA]
							If nQtdTit == nCount                
								aTitSelect[nCount][TIT_JUROSMORA] += aAcumula[2]
							EndIf
							nTotalDesc += aTitSelect[nCount][TIT_JUROSMORA]
						EndIf
						
						// Desconta a Multa
						If ! lMulta
							aAcumula[3] -= aTitSelect[nCount][TIT_MULTA]
							If nQtdTit == nCount
								aTitSelect[nCount][TIT_MULTA] += aAcumula[3]
							EndIf
							nTotalDesc += aTitSelect[nCount][TIT_MULTA]
						EndIf
						
						// Aplica a Pro Rata no titulo
						If lProRata .AND. nProRata > 0
							If dTos(aTitSelect[nCount][TIT_VENCTO]) > dTos(dDataBase)
								nIndProRata := round((1+(nProRata/100))^(1/360)-1,7)
								nTitDescto := NoRound( nSldTitulo*((1+nIndProRata)^((aTitSelect[nCount][TIT_VENCTO]-dDataBase)*-1)) ,TamSX3("E1_SALDO")[2])
								nTitDescto := nSldTitulo-nTitDescto
								aAcumula[4] -= nTitDescto
								If nQtdTit == nCount
									nTitDescto += aAcumula[4]
								EndIf
								nTotalDesc += nTitDescto
							EndIf
						EndIf
						
						// Concede % de desconto
						If lDescto    
							// se sใo titulos a vencer ou vencidas.
							If (aTitSelect[nCount][TIT_VENCTO] >= dDatabase) .or. lVenc
								nTitDescto := NoRound( nSldTitulo*(nPerDesc/100) ,TamSX3("E1_SALDO")[2])
								aAcumula[4] -= nTitDescto
								If nQtdTit == nCount
									nTitDescto += aAcumula[4]
								EndIf
								nTotalDesc += nTitDescto
							EndIf
						EndIf
					
						aVlrFin := Array(13)
						aVlrFin[ 1] := SE1->E1_VALOR                 // [ 1] Valor Original do Titulo
						aVlrFin[ 2] := nAbatim                       // [ 2] Abatimentos
						aVlrFin[ 3] := SE1->E1_VALOR - SE1->E1_SALDO // [ 3] Pagto Parcial
						aVlrFin[ 4] := SE1->E1_SDDECRE               // [ 4] Decrescimo
						aVlrFin[ 5] := SE1->E1_SDACRES               // [ 5] Acrescimo
						aVlrFin[ 6] := nSldTitulo                    // [ 6] Saldo do Titulo na Moeda do Titulo
						aVlrFin[ 7] := xMoeda(aVlrFin[ 6] ,SE1->E1_MOEDA,1,dDataBase) // [ 7] Saldo do Titulo na Moeda Corrente
						aVlrFin[ 8] := aTitSelect[nCount][TIT_CMAMORT]+aTitSelect[nCount][TIT_CMJUROS] // [ 8] Juros Mora (CM do Principal e do Juros)
						// considera a pro-rata de atraso
						If lPRatAtr
							aVlrFin[ 8] += aTitSelect[nCount][TIT_PRORATA]   // [ 8] Juros Mora (Pro Rata diario por atraso)
						EndIf
						aVlrFin[ 8] += aTitSelect[nCount][TIT_JUROSMORA] // [ 8] Juros Mora

						aVlrFin[ 9] := nTotalDesc  // [ 9] Desconto
						
						aVlrFin[10] := 0  // [10] Correcao Monetaria
						aVlrFin[13] := aTitSelect[nCount][TIT_MULTA] // [13] Multa
						
						aVlrFin[11] := aVlrFin[ 1]+xMoeda(aVlrFin[ 8]+aVlrFin[13]-aVlrFin[ 9],1,SE1->E1_MOEDA,dDataBase) // [11] Valor a ser Recebido na moeda do titulo
						aVlrFin[12] := xMoeda(aVlrFin[ 1],SE1->E1_MOEDA,1,dDataBase)+aVlrFin[ 8]+aVlrFin[13]-aVlrFin[ 9] // [12] Valor a ser Recebido na moeda corrente
						
						aAdd( aSE1Recno ,SE1->(Recno()) )
						aAdd( aSE1Dados ,{ SE1->(Recno()) ,STR0043 ,aVlrFin ,LIZ->LIZ_COND } )

					EndIf
		            
				EndIf
			Next nCount
			
			If lCondVenda
				
				nPosITEM   := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_ITEM"})
				nPosTIPPAR := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_TIPPAR"})
				nPos1VENC  := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_1VENC"})
				nPosVALOR  := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_VALOR"})
	
				nPosTPSIST := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_TPSIST"})
				nPosTAXANO := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_TAXANO"})
				nPosNUMPAR := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_NUMPAR"})
				nPosTPPRIC := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_TPPRIC"})
				nPosJURINI := aScan(aConjLJU[2],{|x|AllTrim(x[2])=="LJU_JURINI"})
				
				
				//
				// gera as parcelas
				//
				For nCount := 1 to len(aConjLJU[3])
					// existencia do tipo de titulo para obtencao do intervalo entre titulos.
					dbSelectArea("LFD")
					dbSetOrder(1) // LFD_FILIAL+LFD_COD
					If MsSeek( xFilial("LFD")+aConjLJU[3][nCount][nPosTIPPAR] )
						// calcula o valor a ser financiado neste item de condicao de venda
						nVlrFin := aConjLJU[3][nCount][nPosVALOR]
					
						nPerCorr := 0 //LFD->LFD_INTCOR

						If !(nPosJURINI == 0)
							dJurosINI := aConjLJU[3][nCount][nPosJURINI]
						Else
							dJurosINI := aConjLJU[3][nCount][nPos1VENC]
						EndIf

						// gera os titulos de acordo com o sistema de amortizacao escolhida.
						//
						// Retorno do array ้:
						// aTitRec[n][1] - Numero do titulo
						// aTitRec[n][2] - Data de vencimento do titulo
						// aTitRec[n][3] - Valor do titulo
						// aTitRec[n][4] - Juros Fcto
						// aTitRec[n][5] - Saldo Devedor
						aTitRec := T_GMGeraTit( aConjLJU[3][nCount][nPosTPSIST] ,aConjLJU[3][nCount][nPos1VENC] ,aConjLJU[3][nCount][nPosTAXANO] ,LFD->LFD_INTERV ;
						                       ,aConjLJU[3][nCount][nPosNUMPAR] ,nVlrFin  ,/*% do indice de correcao*/ ,nPerCorr ,aConjLJU[3][nCount][nPosTPPRIC] ,dJurosINI )

						For nCntFor := 1 to len(aTitRec)
							aAdd( aNewTitRec ,aTitRec[nCntFor] )
							
							nPosLJO := aScan( aLJUxLJO ,{|e|e[1] == aConjLJU[3][nCount][nPosITEM] })
							
							// aDetTit[n][1] - Item da condicao de venda
							// aDetTit[n][2] - Item do Item da condicao de venda
							// aDetTit[n][3] - Data de Vencimento
							// aDetTit[n][4] - NULL
							// aDetTit[n][5] - NULL
							// aDetTit[n][6] - Juros Fcto do Titulo
							// aDetTit[n][7] - Numero de parcelas
							aAdd( aDetTit ,{ aLJUxLJO[nPosLJO][2] ;
							                ,aTitRec[nCntFor][1] ;
							                ,aTitRec[nCntFor][2] ;
							                ,/*[4]*/,/*[5]*/ ;
							                ,aTitRec[nCntFor][4] ;
							                ,aConjLJU[3][nCount][nPosNUMPAR] ;
							                })
						Next nCntFor
					EndIf
				Next nCount
				
			// Condicao de pagamento padrao
			Else 
				aTitRec := Condicao( LIZ->LIZ_NEGOC ,LIZ->LIZ_COND ,0 ,dDataBase ,0 )
	        	aNewTitRec := {}
				For nCount := 1 to len(aTitRec)
					aAdd( aNewTitRec ,{ /*1*/,aTitRec[nCount][1]/*2-vencto*/,aTitRec[nCount][2]/*3-valor*/ } )
				Next nCount
			EndIf
	        
			nQtdParc := 0
			For nCount := 1 To Len(aNewTitRec)
			
				//
				// Template GEM - Gestao de empreendimentos imobiliarios
				// Define o Tipo de Parcela como Nota Fiscal.
				//
				cTipoParc := MVNOTAFIS
				
				//
				// Template GEM - Gestao de empreendimentos imobiliarios
				// Condicao de pagto com condicao de venda
				//
				If ExistTemplate("GEMTipTit") 
					cTipoParc := ExecTemplate("GEMTipTit",.F.,.F.,{cTipoParc,aNewTitRec[nCount][2],aConjLJU[1], IIF(LIT->(FIELDPOS("LIT_FECHAM"))>0, StoD(LIT->LIT_FECHAM+"01"), dDataBase)})
				EndIf
			
				aAdd( aLiquidacao ,{ LIT->LIT_PREFIX       ;// [1] Prefixo
									,""                    ;// [2] Banco
									,""                    ;// [3] Agencia
									,""                    ;// [4] Conta
									,LIT->LIT_DUPL         ;// [5] Numero do Cheque (no. do titulo)
									,aNewTitRec[nCount][2] ;// [6] Data Boa
									,aNewTitRec[nCount][3] ;// [7] Valor
									,cTipoParc             ;// [8] Tipo
									,cSA1_NATUR            ;// [9] Natureza
									,nMoeda                ;// [A] Moeda
			                       } )
			Next nCount
            
			// executa a liquidacao dos titulos a receber
			MaIntBxCR( 2, aSE1Recno,NIL,NIL,aLiquidacao,NIL,NIL,NIL,aSE1Dados,aNewSE1)
                
			For nCount := 1 To Len(aNewSE1)
				dbSelectArea("SE1")
				dbGoto(aNewSE1[nCount])
            	
				Reclock("SE1",.F.)

					SE1->E1_ITPARC  := STRZERO(aDetTit[nCount][2] ,TamSX3("LJO_NUMPAR")[1]) ; //- Item do Item da condicao de venda
   					                 + "/" ;
   					                 + STRZERO(aDetTit[nCount][7] ,TamSX3("LJO_NUMPAR")[1]) ;
   					                 + "-" ;
   					                 + aDetTit[nCount][1]
					SE1->E1_NCONTR  := M->LIZ_NCONTR
					
				MsUnLock()
            	
				//
				// Template GEM - Gestao de Empreendimentos Imobiliarios
				//
				// Verifica se a condicao de pagamento tem vinculacao com uma condicao de venda
				//
				If ExistTemplate("GEMLIXPARC")
					ExecTemplate("GEMLIXPARC",.F.,.F.,{SE1->E1_PREFIXO ,SE1->E1_NUM  ,SE1->E1_PARCELA ;
					                                  ,SE1->E1_TIPO    ,M->LIZ_COND ,SE1->E1_VALOR   ;
					                                  ,iIf(Len(aDetTit)>=nCount,aDetTit[nCount],{}) })  ; // Detalhes do Titulo a receber(amortizacao,juros,etc)
                    // Detalhes do titulos a receber
					dbSelectArea("LIX")
					dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
					If dbSeek(xFilial("LIX")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
						RecLock("LIX",.F.)
							LIX->LIX_NCONTR := M->LIZ_NCONTR
						MsUnLock()
					EndIf
					
				EndIf

			Next nCount
			
		EndIf // busca contrato
	EndIf
Else	                                                        
	//VERIFICA SE A RENEGOCIACAO A SER EXCLUIDA E A ULTIMA REFERENTE A ESTE CONTRATO
	If A102VLDREN(LIZ->LIZ_NCONTR,LIZ->LIZ_REVISA)
	 
		DbSelectArea("LJE")                                      
		dbSetOrder(1) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
		If dbSeek(xFilial("LJE")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA, .T.)

	        //VERIFICA A PRIMEIRA PARCELA GERADA NA RENEGOCIACAO
	        aUltParc := a102LastParc(LJE->LJE_NCONTR,LJE->LJE_REVISA) 
			         
      	DbSelectArea("SE1")
			dbSetOrder(1) // E1_FILIAL +E1_NUM +E1_PREFIXO +E1_PARCELA +E1_TIPO
			dbSeek(xFilial("SE1")+LJE->(LJE_PREFIX+LJE_NUM)+aUltParc[2])
			While SE1->( !EOF() ) .AND.;
				(xFilial("SE1")+SE1->(E1_NUM +E1_PREFIXO) == xFilial("LJQ")+LJE->(LJE_NUM +LJE_PREFIX)) .and.;
				(SE1->E1_PARCELA>=aUltParc[2])
	
				FA460CAN("SE1",SE1->(Recno()),4,,.T.)
			   	
				SE1->( dbSkip() )				
                    
			EndDo

		EndIf
        
    	DbSelectArea("LIX")
		dbSetOrder(1)     // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		If DbSeek( xFilial("LIX")+LJE->(LJE_PREFIX+LJE_NUM)+aUltParc[2],.T.) 
        	
        	WHILE LIX->(!EOF()) .AND. (LIX->(LIX_PREFIX+LIX_NUM)==LJE->(LJE_PREFIX+LJE_NUM) .AND. LIX->LIX_PARCEL>=aUltParc[2])
				RecLock("LIX", .F.)
					
				LIX->( dbDelete() )              
				
				MsUnlock("LIX")    
                
				LIX->( dbSkip() )
			ENDDO
			
	    EndIf
			
		DbSelectArea("LJQ")                                      
		dbSetOrder(1) 
		If dbSeek(xFilial("LJQ")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA, .T.)
			While LJQ->(!EOF()) .AND. (LJQ->LJQ_NCONTR+LJQ->LJQ_REVISA == LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)       
		
		        DbSelectArea("SE1")
				dbSetOrder(1)    
				DbSeek( xFilial("SE1")+LJE->(LJE_PREFIX+LJE_NUM) +LJQ->LJQ_PARCEL )
				IF SE1->( !EOF() ) .AND. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA) == LJE->(LJE_PREFIX+LJE_NUM)+LJQ->LJQ_PARCEL
		
	
		    		DbSelectArea("LJE")
					dbSetOrder(2)    
					DbSeek( xFilial("LJE")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA ))

   					RecLock("SE1", .F.)
					
					SE1->E1_TIPO := LJE->LJE_TIPO
					
					MsUnlock("SE1")    
		
				EndIf
				
				DbSelectArea("LIX")
				dbSetOrder(1)     // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				DbSeek( xFilial("LIX")+LJE->(LJE_PREFIX+LJE_NUM)+LJQ->(LJQ->LJQ_PARCEL) )
				IF LIX->( !EOF() ) .AND. LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL) == LJE->(LJE_PREFIX+LJE_NUM)+LJQ->(LJQ->LJQ_PARCEL)
		
					RecLock("LIX", .F.)
					
					LIX->LIX_TIPO := LJE->LJE_TIPO               
					
					MsUnlock("LIX")    
		
				EndIf
				
				LJQ->( dbSkip() )                                                                             
		    EndDO
		EndIf
		        
		
		DbSelectArea("LJQ")
		dbSetOrder(1)   // LJQ_FILIAL+LJQ_NCONTR+LJQ_REVISA+LJQ_PARCEL
		DbSeek(xFilial("LJQ")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA )
		While LJQ->(!EOF()) .AND. (LJQ->LJQ_NCONTR+LJQ->LJQ_REVISA == LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)                                                                   

			Reclock("LJQ", .F.)          			
			
			DbDelete()
			
			MsUnlock("LJQ")
				
						 
    		LJQ->( dbSkip() ) 

    	EndDo
    	
		DbSelectArea("LJO")
		dbSetOrder(1)	// LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		DbSeek(xFilial("LJO")+LIZ->LIZ_NCONTR)
		While LJO->( !EOF() ) .AND. (xFilial("LJO")+LJO->LJO_NCONTR ==xFilial("LIZ")+LIZ->LIZ_NCONTR)
		    
		    RecLock("LJO", .F.)
		
			DbDelete()
			
		    MsUnlock("LJO")
		
			LJO->( dbSkip() )
		EndDo
	    
		For nX := 1 to LJO->( FCOUNT() )
			If FieldName(nX) <> "LJO_JURINI"
				Aadd( aCamposLJO, FieldName( nX ) )
			EndIf
		next nX       
		
		
	  	DbSelectArea("LJP")
		dbSetOrder(1) //LJP_FILIAL+LJP_NCONTR+LJP_REVISA+LJP_ITEM
		dbSeek(xFilial("LJP")+LIZ->LIZ_NCONTR)
		While LJP->( !EOF() ) .AND. (xFilial("LJP")+LJP->LJP_NCONTR == xFilial("LJO")+LIZ->LIZ_NCONTR) .AND.;
		(LJP->LJP_REVISA <= LIZ->LIZ_REVISA)
		                  
		 	RecLock("LJO", .T.)
			For nX := 1 to Len(aCamposLJO)
				LJO->&(aCamposLJO[nX]) := LJP->&("LJP_" + SubSTR(aCamposLJO[nX],5,Len(aCamposLJO[nX])))
			next nX
			
			MsUnLock("LJO")
		    
			LJP->( dbSkip() )	
		EndDo    
	
		DbSelectArea("LJU")
		dbSetOrder(1) //LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
		If dbSeek(xFilial("LJU")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
		
			Reclock("LJU", .F.)        
			
			dbDelete()
			
			MsUnlock("LJU")
		EndIf     
			
		DbSelectArea("LJA")
		dbSetOrder(2) //LJA_FILIAL+LJA_NCONTR+LJA_REVISA
		If dbSeek(xFilial("LJA")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
			
			Reclock("LJA", .F.)        
			
			dbDelete()
				
			MsUnlock("LJA")
		EndIf
			
	    DbSelectArea("LJP")
		dbSetOrder(1) //LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
		If dbSeek(xFilial("LJP")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
			
			Reclock("LJP", .F.)        
			
			dbDelete()
				
			MsUnlock("LJP")
		EndIf

		DbSelectArea("LJE")                                      
		dbSetOrder(1) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
		If dbSeek(xFilial("LJE")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA, .T.)
			While LJE->(!EOF()) .AND. (LJE->LJE_NCONTR+LJE->LJE_REVISA == LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
			
		        Reclock("LJE", .F.)        
				
				DbDelete()
				
				MsUnlock("LJE")   
				          
			    LJE->( dbSkip() )
			EndDo
		
		EndIF
		
		DbSelectArea("LIT")
		dbSetOrder(2)
		If dbSeek(xFilial("LIT")+LIZ->LIZ_NCONTR)  
		
			
			RecLock("LIT",.F.)
			
			LIT->LIT_REVISA := STRZERO(Val(LIT->LIT_REVISA)-1,3)
				
			MsUnlock("LIT")
		                         
			DbSelectArea("LJB") 
			dbSetOrder(1) //LJB_FILIAL+LJB_DOC+LJB_SERIE+LJB_REVISA+LJB_CLIENT+LJB_LOJA+LJB_COD+LJB_ITEM
			If dbSeek(xFilial("LJB")+LIT->(LIT_DOC+LIT_SERIE)+LIZ->LIZ_REVISA)
		
			Reclock("LJU", .F.)        
			
			dbDelete()
			
			MsUnlock("LJU")
	   		EndIf              
		
		EndIf 	    
		
		DbSelectArea("LIZ")
		dbSetOrder(1) //LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
		If dbSeek(xFilial("LIZ")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
		
			Reclock("LIZ", .F.)        
			
			dbDelete()
			
			MsUnlock("LIZ")
		EndIf 
			
	Else
		Alert(STR0044)     //Somente poderแ excluir a ๚ltima renegocia็ใo referente a este contrato!
	EndIf
Endif

RestArea(aArea)

Return( .T. )


//
// altera o tipo de titulo de um titulo a receber.
//
Static Function A102SubTitCr( cPrefixo ,cNumero ,cParcela ,cAtualTipo ,cNovoTipo )

Local aRecord := {}
Local nCount  := 0
Local lReturn := .F.
local cContrato := ""    
	// se os tipos forem diferente, processa
	If ! (cAtualTipo==cNovoTipo)
		// busca o titulo a receber
		dbSelectArea("SE1")
		dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If dbSeek( xFilial("SE1")+cPrefixo+cNumero+cParcela+cAtualTipo )
			
			cContrato := SE1->E1_NCONTR
			
			RecLock("SE1",.F.,.T.)
			For nCount := 1 to FCount()
				aAdd( aRecord ,FieldGet( nCount ) )
			Next nCount                                                                    
			
			SE1->(dbDelete())
			SE1->(MsUnlock())
				
			RecLock("SE1",.T.)
				For nCount := 1 to Len(aRecord)
					SE1->(FieldPut( nCount ,aRecord[nCount] ))
				Next nCount
				
				SE1->E1_TIPO := cNovoTipo
				
			SE1->(MsUnlock())
			
			lReturn := .T.
			
			//
			// Detalhes do titulos a receber
			//
			dbSelectArea("LIX")
			dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
			If MsSeek( xFilial("LIX")+SE1->E1_PREFIXO +SE1->E1_NUM+SE1->E1_PARCELA+cAtualTipo )
			
				aRecord := {}
				
				RecLock("LIX",.F.,.T.)
				For nCount := 1 to FCount()
					aAdd( aRecord ,FieldGet( nCount ) )
				Next nCount
				dbDelete()
				MsUnlock()
			
				RecLock("LIX",.T.)
					For nCount := 1 to Len(aRecord)
				   		LIX->(FieldPut( nCount ,aRecord[nCount] ))
					Next nCount
					LIX->LIX_TIPO := cNovoTipo
				MsUnlock()
			EndIf
			//
			// Detalhes da C.M.
			//       
			dbSelectArea("LIT")
			dbsetorder(2)
			dbseek(xFilial("LIT")+cContrato)
			
			dbSelectArea("LIW")
			dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
			If DbSeek( xFilial("LIW")+SE1->E1_PREFIXO +SE1->E1_NUM+SE1->E1_PARCELA+cAtualTipo+LIT->LIT_FECHAM )

				RecLock("LIW",.F.,.T.)
					LIW->LIW_TIPO := cNovoTipo
				MsUnlock()
			
			EndIf
			
		EndIf
	EndIf
Return( lReturn )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    |GMA102CM  ณ Autor ณ Reynaldo Miyashita     ณ Data ณ 27.03.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cm do amortizado e juros mensal do titulo atraves da           ณฑฑ
ฑฑณ          ณ data informada                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GMA102CM( nRecLIX ,dRef )
Local aRet := {}

	aRet := GEMCmTit( nRecLIX ,dRef )

Return( aRet )

Static Function A102LJOGrv( nRecnoLJU ,aLJUxLJO )
Local aArea := GetArea()
Local cItem := "00" 

DEFAULT aLJUxLJO := {}

	dbSelectArea("LJU")
	dbGoto(nRecnoLJU)
	
	dbSelectArea("LJO")
	dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	dbSeek(xFilial("LJO")+M->LIZ_NCONTR)
	While LJO->(!Eof()) .AND. LJO->LJO_FILIAL+LJO->LJO_NCONTR == xFilial("LJO")+M->LIZ_NCONTR
		cItem := LJO->LJO_ITEM
		dbSkip()
	EndDo
	
	cItem := Soma1(cItem)
	
	aAdd( aLJUxLJO ,{ LJU->LJU_ITEM ,cItem } )

	RecLock("LJO",.T.)
	
	LJO->LJO_FILIAL := xFilial("LJO")
	LJO->LJO_NCONTR := LIT->LIT_NCONTR 
	
	LJO->LJO_ITEM   := cItem
	LJO->LJO_NUMPAR := LJU->LJU_NUMPAR
	LJO->LJO_VALOR  := LJU->LJU_VALOR 
	LJO->LJO_TIPPAR := LJU->LJU_TIPPAR
	LJO->LJO_TPDESC := LJU->LJU_TPDESC
	LJO->LJO_DIAVEN := DAY(LJU->LJU_1VENC)
	LJO->LJO_FIXVNC := LJU->LJU_FIXVNC
	LJO->LJO_1VENC  := LJU->LJU_1VENC
	LJO->LJO_TPSIST := LJU->LJU_TPSIST
	LJO->LJO_TAXANO := LJU->LJU_TAXANO
	LJO->LJO_COEF   := LJU->LJU_COEF
	LJO->LJO_IND    := LJU->LJU_IND
	LJO->LJO_NMES1  := LJU->LJU_NMES
	LJO->LJO_INDPOS := LJU->LJU_INDPOS
	LJO->LJO_NMES2  := LJU->LJU_NMES1
	LJO->LJO_DIACOR := LJU->LJU_DIACOR
	LJO->LJO_TPPRIC := LJU->LJU_TPPRIC
	If LJO->(FieldPos("LJO_JURINI")) > 0 .And. LJU->(FieldPos("LJU_JURINI")) > 0
		LJO->LJO_JURINI := LJU->LJU_JURINI
	ElseIf LJO->(FieldPos("LJO_JURINI")) > 0 .And. LJU->LJU_TPSIST <> "4"
		LJO->LJO_JURINI := LJU->LJU_1VENC
	EndIf
	
	MSUnLock()

RestArea(aArea)
	
Return( .T. )
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102VLDRENบAutor  ณClovis Magenta      บ Data ณ  21/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se a revisao da renegociacao que sera excluida e a   บฑฑ
ฑฑบ          ณultima referente ao contrato.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ A102GRAVA                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
   
STATIC FUNCTION A102VLDREN(cContrato, cRevisa)

Local lValida	:= .T.
Local aArea     := GetArea()   
Local aAreaLIZ	:= LIZ->( GetArea() )
Local cLIZRevisa:= ""

DbSelectArea("LIZ") 
DbSetOrder(1)
If dbSeek(xFilial("LIZ")+cContrato, .T.)
	
	While LIZ->( !EOF() ) .AND. (LIZ->LIZ_NCONTR == cContrato)
    	cLIZRevisa := LIZ->LIZ_REVISA
    	LIZ->( dbSkip() )
    EndDO
     
    If Alltrim(cRevisa) <> Alltrim(cLIZRevisa)
		lValida := .F.
	EndIf       
	                                  
EndIf                 

RestArea( aAreaLIZ )
RestArea( aArea )

Return lValida
                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa102UltParบAutor  ณClovis Magenta      บ Data ณ  21/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura a ultima parcela referente ao contrato e a revisao บฑฑ
ฑฑบ          ณ anterior para fazer a exclusao da renegociacao corretamenteบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ A102GRAVA                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function a102LastParc(cContrato,cRevisa)

Local aArea     	:= GetArea()   
Local aAreaLJE		:= LJE->( GetArea() )
Local cNewRevisa	:= ""
Local cParcAnt		:= ""
Local cParAtual		:= ""   
Local aPosParcel	:= {}


IIF( cRevisa<>"001", cNewRevisa := STRZERO(Val(cRevisa)-1,3), cNewRevisa := cRevisa)  

dbSelectArea("LJE")
dbSetOrder(1) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
If dbSeek(xFilial("LJE")+cContrato+cNewRevisa, .T.)
	While LJE->( !EOF() ) .AND. (cContrato+cNewRevisa == LJE->LJE_NCONTR+LJE->LJE_REVISA)
		
		cParcAnt := LJE->LJE_PARCEL     
	
		LJE->( dbSkip() )
	EndDo
EndIf
		
dbSelectArea("LJE")
dbSetOrder(1) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
If dbSeek(xFilial("LJE")+cContrato+cRevisa, .T.)
	While LJE->( !EOF() ) .AND. (cContrato+cRevisa == LJE->LJE_NCONTR+LJE->LJE_REVISA)
		
		cParAtual := LJE->LJE_PARCEL     
	
		LJE->( dbSkip() )
	EndDo
EndIf
 
cParAtual := STRZERO(Val(cParAtual)+1,3)		             
aPosParcel := {cParcAnt,cParAtual }

RestArea( aAreaLJE )
RestArea( aArea )

Return aPosParcel
