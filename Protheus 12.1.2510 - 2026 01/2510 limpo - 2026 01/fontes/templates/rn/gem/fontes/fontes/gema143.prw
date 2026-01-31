#INCLUDE "gema143.ch"
#INCLUDE "protheus.ch"

///////////////////////////////////////
// melhor tamanho do objeto oMeter para
// o Size do campo criado na oDlg.
#define nMaxTamMeter		100

////////
// Cores
#define CLR_FUNDO		RGB(240,240,240)
#define CLR_FONTB		RGB(000,000,255)
#define CLR_FONTT		RGB(000,000,000)
#define CLR_FONTP		RGB(180,180,180)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA143   บ Autor ณ Cristiano Denardi  บ Data ณ  02.02.06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Wizard para geracao de unidades							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template GEM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
TEMPLATE Function GEMA143(nOpc)

Local oPanel
Local oMeter
Local oFontB 
Local oFontT
Local oFontP
Local oFontE
Local nVal  	:= 0
Local cTxtPro	:= STR0001 //"Processando..."
Local cTxtTer	:= STR0002 //"PROCESSADO!"
Local cTxtUni	:= STR0003 //"Unidade em gravacao:"
Local cCodUni	:= Space(	TamSX3("LIQ_COD" )[1] )
Local aItens	:= {}
Local lProc		:= .F.
Local nMarg		:= 0.3
Local cTxtHlp	:= STR0004 //"Informe os campos acima para o funcionamento ideal do Wizard."

Private nQtdeUni	:= 2
Private oDlg
Private oBtnOk  // Botao OK
Private oBtnCa  // Botao CANCELA
Private oTxtPro 
Private oTxtTer 
Private oTxtUni
Private oCodUni
Private oQtdeUni
Private oComboBox
Private oTxtHlp
Private cChoice := ""

aItens  := { STR0005, STR0006, STR0007 } //"1 - Somente Atual"###"2 - Todas Estruturas"###"3 - Perguntar uma a uma"
cChoice := aItens[1]

/////////////////////////////////
// Tela para Parametros do Wizard
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0008) FROM 010,010 TO 400,600 OF oMainWnd PIXEL //"Wizard para Cadastro de Unidades"

	////////////////////
	// Qtde de unidades 
	// que serao geradas
	@ 00+nMarg,00+nMarg SAY		OemToAnsi(STR0009) //"Qtde de Unidades a gerar ?"
	@ 00+nMarg,10+nMarg MSGET	oQtdeUni VAR nQtdeUni Valid (nQtdeUni>1) SIZE 20,10 hasbutton Picture "@E 9,999"
	
	
	///////////////////////////////////////
	// .: ComboBox - sobre quais estruturas 
	// serao criadas as unidades replicadas
	//
	// 1 - Somente Atual
	// 2 - Todas Estruturas
	// 3 - Perguntar uma a uma
	@ 01+nMarg,00+nMarg SAY		OemToAnsi(STR0010) //"Replicar em quais estruturas ?"
	@ 01+nMarg,10+nMarg COMBOBOX oComboBox VAR cChoice ITEMS aItens SIZE 73,10 OF oDlg
	
	/////////
	// Botoes
	@ 03,200 TO 40,238 LABEL " "+STR0012+" " OF oDlg Pixel COLOR CLR_FONTT //"Acoes"
		DEFINE SBUTTON oBtnOk FROM 13,206 TYPE 1 ACTION ( GEMA143Wiz(@oMeter,@lProc	) ) ENABLE OF oDlg Pixel
		DEFINE SBUTTON oBtnCa FROM 25,206 TYPE 2 ACTION ( GEMA143Exi(lProc         	) ) ENABLE OF oDlg Pixel
	
	////////
	// Panel - controla mensagens do processamento
	@ 45,04 MSPANEL oPanel PROMPT "" COLOR CLR_FONTT,CLR_FUNDO SIZE 238,047 OF oDlg LOWERED
	
		DEFINE FONT oFontB NAME "Arial" 	  		SIZE 7,20 BOLD	// "Unidade:"
		DEFINE FONT oFontT NAME "Arial" 			SIZE 5,15 		// "Unidade em gravacao:"
		DEFINE FONT oFontP NAME "Courier New"	SIZE 7,20 BOLD	// "Processando..."
		DEFINE FONT oFontE NAME "Arial"			SIZE 9,20 BOLD	// "PROCESSADO!"
		
		@ 10,020 SAY oTxtHlp PROMPT cTxtHlp	FONT oFontB COLOR CLR_FONTB,CLR_FUNDO OF oPanel PIXEL
		
		@ 01,100 SAY oTxtPro PROMPT cTxtPro	FONT oFontP COLOR CLR_FONTP,CLR_FUNDO OF oPanel PIXEL
		@ 01,085 SAY oTxtTer PROMPT cTxtTer	FONT oFontE COLOR CLR_FONTB,CLR_FUNDO OF oPanel PIXEL
		
		@ 10,002 SAY oTxtUni PROMPT cTxtUni	FONT oFontB COLOR CLR_FONTB,CLR_FUNDO OF oPanel PIXEL
		@ 10,075 SAY oCodUni PROMPT cCodUni	FONT oFontT COLOR CLR_FONTT,CLR_FUNDO OF oPanel PIXEL
		
		///////////////
		// Progress Bar
		@ 19,02 METER oMeter VAR nVal SIZE 230,010 TOTAL nMaxTamMeter OF oPanel PIXEL    
	
		oPanel:Show()
		oTxtHlp:Show()
		oMeter:Disable()
		oTxtPro:Hide()
		oTxtTer:Hide()
		oTxtUni:Hide()
		oCodUni:Hide()
	// Panel
	////////

ACTIVATE MSDIALOG oDlg CENTERED
// Tela para Parametros do Wizard
/////////////////////////////////
	
Return( lProc )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA143Vldบ Autor ณ Cristiano Denardi  บ Data ณ  02.02.06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa Wizard ou retorna .T. conforme opcao do menu 		  บฑฑ
ฑฑบ          ณ escolhida na tela principal										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template GEM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Template Function GEMA143Vld( lWzd )

Local   lRet  := .T.
Default lWzd  := .F.

If lWzd
	lRet := t_GEMA143()
Endif

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ GEMA143Wiz ณ Autor ณ Cristiano Denardi     ณ Data ณ 06.03.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Processa Wizard.															 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Template GEM				 											    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GEMA143Wiz( oMt, lPrc )

Local nA 	  := 0
Local nB 	  := 0
Local nPos	  := 0
Local nSalto  := 0
Local nLoop	  := nQtdeUni
Local lMsg	  := .F.
Local aValCpos:= {}
Local aParam  := {}
Local aEstru  := {}
Local aGrava  := {}
Local aUniPri := {} // Unidade Principal vindo da Dialog
Local cCodEst := Left( Alltrim(M->LIQ_COD), Len(Alltrim(M->LIQ_COD))-1 ) 
Local cCodEmp := M->LIQ_CODEMP
Local cCodInc := ""
Local cCaract := ""
Local cCpo	  := ""

////////////////////////////
// .: Estrutura de aEstru :.
// -------------------------
// 1 - Codigo da Estrutura a gerar unidades
// 2 - Descricao da Estrutura

///////////////////////
// Var: para  manipular 
//      dados do Wizard
// nQtdeUni
// oComboBox:nAt
// cFunc

/////////////////////////////
// Desabilita botoes e campos
oBtnOk:Disable()
oBtnCa:Disable()
oTxtPro:Show()
oTxtUni:Show()
oCodUni:Show()
oQtdeUni:Disable()
oComboBox:Disable()
oTxtHlp:Hide()

////////////////
// Ajusta oMeter
oMt:Show()
oMt:SetTotal(nMaxTamMeter)
oMt:Set(0)

///////////////////////////////////////////
// Inicia calculo para saber numero de Loop
Do Case
	Case oComboBox:nAt == 1 // Somente Estrutura Atual
		nLoop  := nQtdeUni
		Aadd( aEstru, {cCodEst,""} )
		
		
	Case oComboBox:nAt == 2 // Todas as Estruturas
		aEstru := T_GEMRetEstU( cCodEmp, cCodEst )
		nLoop  := Len(aEstru) * nQtdeUni
	
	Case oComboBox:nAt == 3 // Perguntar uma a uma
		aEstru := T_GEMRetEstU( cCodEmp, cCodEst )
		aEstru := GEMConfEst( aEstru, cCodEst ) // Tela de confirmacoes das estruturas
		nLoop  := Len(aEstru) * nQtdeUni
	
EndCase

///////////////////////////
// Guarda valores digitados
// na tela de cadastro
Aadd( aUniPri, { "LIQ_UNID", M->LIQ_UNID } )
For nA := 1 TO FCount()
	Aadd( aUniPri, { Eval(bCampo,nA), M->&(Eval(bCampo,nA)) })
Next nA

///////////////////////
// Encontra o caractere 
// ao final do Codigo
cCodInc := Alltrim(M->LIQ_COD)
nPos := aScan( aEstru, {|x| AllTrim(x[1]) == Left(cCodInc,Len(cCodInc)-1) } )
If (nPos > 0) .And. (Len(aEstru[nPos][1]) <> Len(cCodInc))
	cCaract := Right( cCodInc, 1 )
Else
	cCaract := ""
Endif

////////////////////////////////
// Monta Estrutura para gravacao
For nA := 1 To Len(aEstru)
	cCodInc := AllTrim(M->LIQ_UNID)
	For nB := 1 To nQtdeUni
	
		If nB <> 1
		
			aParam := { nB, cCodInc, aEstru, nA, nQtdeUni }
			cCodInc := GEMA143Inc( aParam )
			
		Endif
		
		Aadd( aGrava, { aEstru[nA][1], Alltrim(aEstru[nA][1])+cCaract, cCodInc } )
	Next nB
Next nA

////////////////////////
// Realiza Processamento
// Gravacao das unidades
For nA := 1 To nLoop

	cCodInc := aGrava[nA][2] + aGrava[nA][3]
	oCodUni:cCaption := cCodInc
	
	///////////////////////////
	// Inicia Bloco de gravacao
	RecLock("LIQ",.T.)
		// Grava Cpos que estao na Memoria
		For nB := 1 To Len(aUniPri)
			If	LIQ->(FieldPos(aUniPri[nB,1])) > 0
				cCpo  := "LIQ->"+aUniPri[nB,1]
				&cCpo := aUniPri[nB,2]
			Endif
		Next nB
		
		// Grava Cpos especificos para cada Unidade
		LIQ->LIQ_FILIAL	:= xFilial("LIQ")
		LIQ->LIQ_CODEMP	:= M->LIQ_CODEMP	// 01
		LIQ->LIQ_STRPAI	:=	aGrava[nA,1]	// 01.01
		LIQ->LIQ_COD	:=	cCodInc			// 01.01.201
		
		//////////////////////////////////////////
		// PE para trocar valores de outros Campos
		If ExistBlock( "GEM143Cpos" )
			aValCpos := ExecBlock( "GEM143Cpos", .F., .F., {nA,aGrava,aUniPri} )
		Endif
		// Atualiza Cpos com novo valor pelo PE
		If Len( aValCpos ) > 0
			For nB := 1 To Len(aValCpos)
				If	LIQ->(FieldPos(aValCpos[nB,1])) > 0
					cCpo  := "LIQ->"+aValCpos[nB,1]
					&cCpo := Alltrim(aValCpos[nB,2])
				Endif
			Next nB
		Endif
	MsUnLock()

	////////////////////////
	// Ajusta pulo no oMeter
	nSalto := (nA/nLoop)*nMaxTamMeter
	nSalto := Round(nSalto,0)
	oMt:Set( nSalto )
	oCodUni:Refresh()
	oMt:Refresh()
Next nA

/////////////////
// Ja' processado
lPrc := .T.
oMt:Refresh()
oTxtTer:Show()
oTxtPro:Hide()
oTxtUni:Hide()
oCodUni:Hide()
oTxtHlp:Hide()
oBtnCa:Enable()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ GEMA143Exi ณ Autor ณ Cristiano Denardi     ณ Data ณ 06.03.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Finaliza rotina.												ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ GEMA143Exi()												    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Template GEM												    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GEMA143Exi( lPrc )

Local lExit	:= .F.
Local cMsg  := ""

cMsg := STR0015 //"Processo de gravar multiplas unidades nao confirmado,"
cMsg += Chr(13)+Chr(10)
cMsg += STR0016 //"Gostaria de sair sem gerar unidades ?"

If !lPrc
	If MsgYesNo( cMsg )
		lExit := .T.
	Else
		lExit := .F.
    Endif
Else
	lExit := .T.
Endif

If lExit    
	oDlg:End()
Endif

Return Nil        


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ GEMConfEst ณ Autor ณ Cristiano Denardi     ณ Data ณ 06.03.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Tela de confirmacao para quais estruturas serao processadas  ณฑฑ
ฑฑณ          ณ pelo Wizard de geracao de unidades. 							ณฑฑ
ฑฑณ          ณ (Item 3 ComboBox - PERGUNTAR UMA A UMA)       				ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ GEMA143Exi()													ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Template GEM				 									ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GEMConfEst( aEst, cCodObrig )

Local oDlgCnf
Local oListBox
Local nA			:= 0
Local nPos		:= 0
Local nOpcao	:= 2
Local oOk		:= LoadBitMap(GetResources(), "LBOK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")
Local aButtons	:= {}
Local lEstTrt	:= .T. // Trata retorno da aEst
	
Private aList 	:= {}

///////////////////////////////////////
// Ajusta aList para a primeira Posicao
// para uso em TwBrowse
For nA := 1 To Len(aEst)
	Aadd( aList, {.T.,aEst[nA][1],aEst[nA][2]} )
Next nA

DEFINE MSDIALOG oDlgCnf TITLE OemToAnsi(STR0017) FROM 010,010 TO 200,500 OF oMainWnd PIXEL //"Selecione as Estruturas"

	////////////////////////////////////
	// Objeto para selecionar Estruturas
	// a serem geradas as unidades
	oListBox := TWBrowse():New( 010,010,500,200,,{"  ",STR0018,STR0019},,oDlgCnf,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Codigo"###"Estrutura"
	oListBox:SetArray(aList)
	oListBox:bLine      := { || {If(aList[oListBox:nAt,1],oOk,oNo),aList[oListBox:nAT][2],aList[oListBox:nAT][3]}}
	oListBox:bLDblClick := { || InverteSel(oListBox, oListBox:nAt, .T.,, cCodObrig) }
	oListBox:Align      := CONTROL_ALIGN_ALLCLIENT
	
	/////////////////////////////
	// Funcionalidades Adicionais
	Aadd( aButtons, {"LBOK"    ,{ || MarcaTodos(oListBox, .F., .T.	, cCodObrig	) },STR0020,STR0021} ) //"Marca Todos"###"Marca.Td"
	Aadd( aButtons, {"LBNO"    ,{ || MarcaTodos(oListBox, .F., .F.	, cCodObrig	) },STR0022,STR0023} ) //"Desmarca Todos"###"Desmar.Td"
	Aadd( aButtons, {"PENDENTE",{ || MarcaTodos(oListBox, .T.,    	, cCodObrig	) },STR0024,STR0025} ) //"Inverter Selecao"###"Inverter"

ACTIVATE MSDIALOG oDlgCnf ON INIT EnchoiceBar(oDlgCnf,{|| If(VldOK(aList),(nOpcao:=1,oDlgCnf:End()),Nil)},{|| If(VldCancel(),(nOpcao:=2,oDlgCnf:End()),Nil)},,aButtons) CENTERED

///////////
// Cancelou
If nOpcao == 2
	nPos := aScan( aList, {|x| AllTrim(x[2]) == AllTrim(cCodObrig) } )
	If nPos > 0
		aEst := { aList[nPos][2], aList[nPos][3] }
	Endif
	lEstTrt := .F. // Nao precisa tratar retorno de aEst
	nOpcao  := 1
Endif

////////////
// Confirmou
If nOpcao == 1

	If lEstTrt
		aEst := {}
		///////////////////////////////////////
		// Ajusta aEst para seu retorno
		// conforme itens selecionados em aList
		For nA := 1 To Len(aList)
			If aList[nA][1]
				Aadd( aEst, { aList[nA][2], aList[nA][3] } )
			Endif
		Next nA
	Endif
	
Endif

Return( aEst )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInverteSelบAutor  ณPaulo Carnelossi    บ Data ณ  04/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte Selecao do list box 										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InverteSel(oListBox,nLin, lInverte, lMarca, cObr) 

Local lObrigat := Alltrim(Upper(oListbox:aArray[nLin,2])) == Alltrim(Upper(cObr))
Default nLin   := oListBox:nAt

If !lObrigat
	If lInverte
		oListbox:aArray[nLin,1] := ! oListbox:aArray[nLin,1]
	Else
	   If lMarca
		   oListbox:aArray[nLin,1] := .T.
	   Else
		   oListbox:aArray[nLin,1] := .F.
	   EndIf
	EndIf   
	aList[nLin,1] := oListbox:aArray[nLin,1]
Endif

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcaTodosบAutor  ณPaulo Carnelossi    บ Data ณ  04/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos as opcoes do list box                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaTodos(oListBox, lInverte, lMarca, cObr)

Local nX
Default lMarca := .T.

For nX := 1 TO Len(oListbox:aArray)
	InverteSel(oListBox,nX, lInverte, lMarca, cObr)
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldOK     บAutor  ณCristiano Denardi   บ Data ณ  10.03.06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida confirmacao da Tela.										     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldOk( aLst )

Local nX		:= 0
Local lRet	:= .F.

For nX := 1 TO Len(aLst)
  If aLst[nX][1]
     lRet := .T.
     Exit
  EndIf   
Next 

If !lRet
	MsgAlert(STR0026) //"Nao selecionada nenhuma estrutura. Verifique!"
EndIf	

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldCancel บAutor  ณCristiano Denardi   บ Data ณ  10.03.06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida cancelamento da Tela.										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCancel()

Local lRet := .F.
Local cMsg := ""

cMsg := STR0027 //"Caso cancele, somente serao geradas unidades na estrutura atual."
cMsg += Chr(13)+Chr(10)
cMsg += STR0028 //"Gostaria de sair sob essa condicao ?"

lRet := MsgYesNo( cMsg )

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA143Incบ Autor ณ Cristiano Denardi  บ Data ณ  16.03.06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao padrao de incremento para codigo da unidade.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template GEM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GEMA143Inc( aParam )

Local cCodNew := ""
Local cCod    := aParam[2]

	cCodNew := Soma1( cCod )
	
	If ExistBlock("GEMA143Inc") 
		cCodNew := ExecBlock( "GEMA143Inc", .F., .F., aParam )
	EndIf

Return( cCodNew )