#include "protheus.ch"
#include "GEMMA410.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA410CVNบAutor  ณReynaldo Miyashita  บ Data ณ  01.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDialog da customizacao da condicao de venda no pedido de    บฑฑ
ฑฑบ          ณvenda.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA410CVND()
Local nOpcX	    := PARAMIXB[1] //nOpc
Local cNumPed   := PARAMIXB[2] //M->C5_NUM
Local cCondPag  := PARAMIXB[3] //M->C5_CONDPAG
Local d1Venc    := PARAMIXB[4] // Data do primeiro vencimento
Local nVlrTotal := PARAMIXB[5] // Valor total do pedido

Local cCadastro   := STR0001 //"Condi็ใo de Venda"
Local cCodCndVnd  := ""
Local cDescCndVnd := ""
Local cX3_Valid   := ""
Local cCodEmpr    := ""
Local nUsado      := 0
Local nY          := 0
Local nOpcGD      := 0

Local nI := 0
                                                   
Local lContinua   := .F. 
Local aObjects    := {}
Local aSize       := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aColsOri    := {}
Local aHeadLJN    := {}
Local aColsLJN    := {}
Local aArea       := {}
Local aDadAnal    := { 0, 0, 0, 0,{{ 0, 0 } ,{ 0, 0} ,{ 0, 0}} }
/*
aDadAnal[1]       := // Total a Prazo
aDadAnal[2]       := // Juros Financiado
aDadAnal[3]       := // Taxa Mensal
aDadAnal[4]       := // Valor Presente Liquido
aDadAnal[5][1][1] := // Valor do Habite-se
aDadAnal[5][1][2] := // % do habite-se relativo ao valor da venda
aDadAnal[5][2][1] := // Valor do principal ate o Habite-se
aDadAnal[5][2][2] := // % do acumulado do principal relativo ao valor da venda
*/

Local oDlg
Local oPnlCab 
Local oCod 
Local oDescr
Local oValor
Local oPnlTit 
Local oArialBold 
Local oArial12

Local nTaxAnual  := 0
Local nVlrVenda  := 0

Private oGetVlrVenda 
Private oGetTotJuros 
Private oGetTotPrazo 
Private oGetTaxDesc  
Private oGetVPL      
Private oGetPrevHab  
Private oGetHabite 
Private oGetPrinc
Private oGetAcuPrinc
Private oGetPercPrinc

Private aGets[0]
Private aTela[0][0]
Private oGetCVnd
Private oBrwTit 
Private aHeadTit   := { STR0002 ,STR0003 ,STR0004 ,STR0005 ,STR0006 ,STR0007 } //"Parcela" ,"Vencto" ,"Tipo Parcela" ,"Valor do Titulo" ,"Valor Principal" ,"Valor Juros Fcto"
Private nVlrPedido := nVlrTotal
PRIVATE dHabite    := stod("")

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return .T. 
EndIf

aArea := GetArea()
	 
If Type("aGEMCVnd") == "U"
	PRIVATE aGEMCVnd :={"",{},{}}
Endif

	nVlrVenda  := nVlrTotal
	nTaxAnual  := SuperGetMv("MV_GMTXDSC",.F.,14)

	// Calcula a porcentagem da taxa de desconto para mensal atrav้s de equivalencia
	nTaxMensal := t_GEMTaxEq( nTaxAnual ,12 )
	  
// aheader da SC5 criada na MATA410.PRX, buscar a coluna do empreendimento
If Type("aHeader") == "A"
	If (nCOL_CODEMPR := aScan( aHeader ,{|aDefCol| aDefCol[2] == "C6_CODEMPR"} ) )>0
		// aCols da SC5 criada na MATA410.PRX, buscar o valor na coluna do empreendimento
		For nY := 1 To Len(aCols)
			If ! Empty(aCols[nY][nCOL_CODEMPR])
				cCodEmpr := aCols[nY][nCOL_CODEMPR]
				Exit
			EndIf
		Next nY
		
		If ! Empty( cCodEmpr )
			dbSelectArea("LIQ")
			dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
			If dbSeek(xFilial("LIQ")+cCodEmpr)
				dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
				lContinua := .T.
			EndIf
		EndIf
	EndIf
EndIf
	
If lContinua

	// carrega o aheader e acols do browse dos itens de pagamento da tabela LJN
	aGEMCVnd := a410LJNLoad( cNumPed ,cCondPag ,d1Venc ,nVlrTotal ,aGEMCVnd )
    
	aHeadLJN := aGEMCVnd[2]
	aColsLJN := aGEMCVnd[3]
	
	// Os registros com valor original
	aColsOri := aClone(aColsLJN)
	
	dbSelectArea("LJN")
	RegToMemory( "LJN" ,(nOpcX==3) )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de objetos     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,00 TO 42,90 of oMainWnd 
	DEFINE FONT oArialBold NAME "Arial" SIZE 0, -16 BOLD
	DEFINE FONT oArial12   NAME "Arial" SIZE 0, -12 
	
	If nOpcX == 3 .Or. nOpcX == 4
		nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
	Else
		nOpcGD := 0
	EndIf
	
    // Valor total da venda
	@ 5 ,240 SAY OemToAnsi("Valor Total:")+Transform(nVlrTotal ,x3Picture("C6_VALOR") ) FONT oArialBold SIZE 200,16 PIXEL OF oDlg
	
	aTitles := {"Plano" ,"Anแlise"}
	oFolder := TFolder():New(13,0,aTitles,{},oDlg,,,, .T., .T.,355,215)

	oFolder:bSetOption:={|nFolder| .T. }
	For nI := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nI]
	Next nI

	oFolder:aDialogs[1]:oFont := oDlg:oFont
	// visualiza a condicao de venda
	// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
	oGetCVnd := MsNewGetDados():New( 06,10,100,350 ,nOpcGD ,"t_CVndLinOk","t_CVndBrwOk","+LJN_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadLJN,aColsLJN)

	// visualiza as parcelas conforme a condicao de venda informado
	oPnlTit := TPanel():New(103,10,'',oFolder:aDialogs[1], ,.T.,.T.,, ,340,98,.T.,.T. )
	
	oBrwTit := TWBrowse():New( 5,10,78,340,,aHeadTit ,/*tamanho*/ ,oPnlTit,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
	oBrwTit:Align := CONTROL_ALIGN_ALLCLIENT
	
////////////////////////////////////////////////////////////////////////		
//
//
	oFolder:aDialogs[2]:oFont := oDlg:oFont

    // Valor Venda
	@ 10,10 SAY OemToAnsi("Valor Venda: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 09,90 MSGET oGetVlrVenda VAR nVlrVenda          SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"

    // Total Juros de Financimento
	@ 22,10 SAY OemToAnsi("Total Juros Fcto: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 21,90 MSGET oGetTotJuros VAR aDadAnal[2]          SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"

    // Total a Prazo
	@ 34,10 SAY OemToAnsi("Total a Prazo: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 33,90 MSGET oGetTotPrazo VAR aDadAnal[1]          SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"

    // Taxa de Desconto anual
	@ 46,10 SAY OemToAnsi("Taxa de Desconto (Anual): ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 45,90 MSGET oGetTaxDesc VAR nTaxAnual           SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .T. ;
	          Picture "@E 999.99%"

    // Taxa de desconto mensal
	@ 58,10 SAY OemToAnsi("Taxa de Desconto (Mensal): ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 57,90 MSGET oGetVPL VAR aDadAnal[3]              SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture "@E 999.99%"

    // VPL
	@ 70,10 SAY OemToAnsi("Valor Presente Liquido: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 69,90 MSGET oGetVPL VAR aDadAnal[4]            SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"


    // Data do Habite-se
	@ 118,010 SAY OemToAnsi("Habite-se: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 117,090 MSGET oGetPrevHab VAR dHabite           SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("LIQ","LIQ_PREVHB") //"@D"

    // Valor da parcela do Habite-se, somente se existir.
	@ 130,010 SAY OemToAnsi("Parcela do Habite-se: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 129,090 MSGET oGetHabite VAR aDadAnal[5][1][1]  SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"
	
    // % do Habite relativo ao valor de venda
	@ 129,160 MSGET oGetPercPrinc VAR aDadAnal[5][1][2]  SIZE 20, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture "@E 999.99%"
	          
    // Total do Principal ateh a data do habite-se
	@ 142,010 SAY OemToAnsi("Principal at้ o Habite-se: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 141,090 MSGET oGetPrinc VAR aDadAnal[5][2][1]  SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"
	
    // % do Principal ateh a data do habite-se relativo ao valor de venda
	@ 141,160 MSGET oGetPercPrinc VAR aDadAnal[5][2][2]  SIZE 20, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture "@E 999.99%"

    // Total 
	@ 154,010 SAY OemToAnsi("Total: ") FONT oArial12 SIZE 100,16 PIXEL OF oFolder:aDialogs[2]
	@ 153,090 MSGET oGetAcuPrinc VAR aDadAnal[5][3][1]           SIZE 66, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"
	
    // % Recebido do Principal ateh a data do habite-se
	@ 153,160 MSGET oGetPercPrinc VAR aDadAnal[5][3][2]  SIZE 20, 10 PIXEL OF oFolder:aDialogs[2] HASBUTTON When .F. ;
	          Picture "@E 999.99%"
	          
	ProcTitulos( oGetCVnd:aHeader ,oGetCVnd:aCols ,nVlrVenda ,dHabite ,nTaxAnual ,aDadAnal )

////////////////////////////////////////////////////////////////////////

	@ 233,170 BUTTON OemToAnsi("Recalculo") SIZE 040,11 ACTION ProcTitulos( oGetCVnd:aHeader ,oGetCVnd:aCols ,nVlrVenda ,dHabite ,nTaxAnual ,aDadAnal ) OF oDlg PIXEL
	@ 233,220 BUTTON OemToAnsi("Confirma")  SIZE 040,11 ACTION (Iif( GMMA410Conf( @oDlg ,aGEMCVnd[1] ,aColsOri ,nVlrTotal ,aHeadLJN),oDlg:End(),.F.)) OF oDlg WHEN nOpcGD <> 0 PIXEL
	@ 233,270 BUTTON OemToAnsi("Sair")      SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf
RestArea(aArea)
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMA410  บAutor  ณMicrosiga           บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o browse com os valores dos titulos conforme       บฑฑ
ฑฑบ          ณ condicao de venda montado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcTitulos( aHeaderLJN ,aColsLJN ,nVlrVenda ,dHabite ,nTaxAnual ,aDadAnal )
Local aTitulos := {}
Local aTits    := {}
Local nCnt     := 0
Local nCntX    := 0
Local dRef     := stod("")
Local aTotPer  := {}

	// Calcula a porcentagem da taxa de desconto para mensal atrav้s de equivalencia
	aDadAnal[3] := t_GEMTaxProp( nTaxAnual ,1 )

	//
	// gera as parcelas, conforme o aheader e acols.
	//
	aTitulos := GeraDuplCond( aHeaderLJN ,aColsLJN ,4 )
	
	If Empty(aTitulos)
		aTitulos := {{ strzero(1,TamSX3("LJN_ITEM")[1]) ,stod("") ,"" ,0 ,0 ,"" ,0 }}
	EndIf
	
	aDadAnal[1]       := 0
	aDadAnal[2]       := 0
	aDadAnal[4]       := 0
	aDadAnal[5][1][1] := 0
	aDadAnal[5][1][2] := 0
	aDadAnal[5][2][1] := 0
	aDadAnal[5][2][2] := 0
	aDadAnal[5][3][1] := 0
	aDadAnal[5][3][2] := 0

	For nCnt := 1 To Len(aTitulos)
	    //
		// [1] Numero parcela 
		// [2] data vencto 
		// [3] Descricao do Tipo de Parcela 
		// [4] Valor da parcela
		//
		// [5] Juros Mensal
		// [6] Item do Plano
		// [7] Numero da parcela contido nas parcelas pertencentes ao Item do Plano
		//
		aAdd(aTits ,{ aTitulos[nCnt][1] ;
		             ,Transform(aTitulos[nCnt][2],x3Picture("E1_VENCTO")) ;
		             ,aTitulos[nCnt][3]                                   ;
		             ,Transform(aTitulos[nCnt][4],x3Picture("E1_VALOR"))  ;
		             ,Transform(aTitulos[nCnt][4]-aTitulos[nCnt][5],x3Picture("E1_VALOR"))  ;
		             ,Transform(aTitulos[nCnt][5],x3Picture("E1_VALOR"))  ;
		            })
		
		If nCnt == 1
			dRef  := aTitulos[nCnt][2]
		EndIf

		// se a data de vencimetnto da parcela for inferior a data do habite-se		
		If dHabite > aTitulos[nCnt][2]
			aDadAnal[5][2][1] += (aTitulos[nCnt][4]-aTitulos[nCnt][5])
		EndIf

		// se a data de vencimento da parcela for igual a data do habite-se		
		If dHabite == aTitulos[nCnt][2]
			aDadAnal[5][1][1] += (aTitulos[nCnt][4]-aTitulos[nCnt][5])
		EndIf

		aDadAnal[1] += aTitulos[nCnt][4]
		aDadAnal[2] += aTitulos[nCnt][5]

		nPos := aScan(aTotPer ,{|x|left(dTos(aTitulos[nCnt][2]),6)==x[1] } )
		If nPos > 0
			aTotPer[nPos][2] += aTitulos[nCnt][4]
		Else
			aAdd( aTotPer,{left(dTos(aTitulos[nCnt][2]),6) ,aTitulos[nCnt][4] } )
		EndIf
		
	Next nCnt

	aSort(aTotPer,,, {|x,y| x[1] < y[1] })

	nCntX := 0
	For nCnt := 1 To Len(aTotPer)
		If left(dTos(dDataBase),6) >= aTotPer[nCnt][1]
			aDadAnal[4] += aTotPer[nCnt][2]
		Else
			nCntX++
			aDadAnal[4] += T_GEMVPL( aTotPer[nCnt][2] ,aDadAnal[3]/100 ,nCntX)
		EndIf
	Next nCnt
	
	aDadAnal[5][1][2] := round(aDadAnal[5][1][1]/nVlrVenda,2)*100
	aDadAnal[5][2][2] := round(aDadAnal[5][2][1]/nVlrVenda,2)*100
	
	aDadAnal[5][3][1] := round(aDadAnal[5][1][1]+aDadAnal[5][2][1],2)
	aDadAnal[5][3][2] := round(aDadAnal[5][3][1]/nVlrVenda,2)*100
	
   	oBrwTit:SetArray(aTits)
	oBrwTit:bLine := {|| aTits[oBrwTit:nAT] }
	
	oGetVlrVenda:refresh()
	oGetTotJuros:refresh()
	oGetTotPrazo:refresh()
	oGetTaxDesc:refresh()
	oGetVPL:refresh()
	oGetPrevHab:refresh()
	oGetPrinc:refresh()
	oGetAcuPrinc:refresh()
	oGetPercPrinc:refresh()

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA410DupบAutor  ณReynaldo Miyashita  บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA410Dupl()
Local cNumPed   := iIf( PARAMIXB[1] == NIL ,""        ,PARAMIXB[1] ) 
Local cCondPag  := iIf( PARAMIXB[2] == NIL ,""        ,PARAMIXB[2] ) 
Local d1Venc    := iIf( PARAMIXB[3] == NIL ,dDataBase ,PARAMIXB[3] ) 
Local nTipoDupl := iIf( PARAMIXB[4] == NIL ,1         ,PARAMIXB[4] ) 
Local nVlrTotal := iIf( PARAMIXB[5] == NIL ,0         ,PARAMIXB[5] ) 
Local aVencto   := iIf( PARAMIXB[6] == NIL ,{}        ,PARAMIXB[6] ) 
Local aRetorno  := {}

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( aVencto )
EndIf

	If Type("aGEMCVnd") == "U"
		PRIVATE aGEMCVnd := {"",{},{}}
	Endif
	
	// carrega o aheader e acols do browse dos itens de pagamento da tabela LJN
	aGEMCVnd := a410LJNLoad( cNumPed ,cCondPag ,d1Venc ,nVlrTotal ,aGEMCVnd )
        
	// gera as duplicatas conforme a condicao de venda informada
	aRetorno := GeraDuplCond( aGEMCVnd[2] ,aGEMCVnd[3] ,nTipoDupl )
	
	If Empty(aRetorno)
		aRetorno := aClone(aVencto)
	EndIf
	
Return( aRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMA410  บAutor  ณMicrosiga           บ Data ณ  07/11/05            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ calcula os titulos com base na qtde e tipo de parcelas escolhidas   บฑฑ
ฑฑบ          ณ pelo usuario                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeader : aHeader dos tipos de parcelas que darao origem aos titulosบฑฑ
ฑฑบ          ณ aCols : aCols dos tipos de parcelas que darao origem aos titulos    บฑฑ
ฑฑบ          ณ nTipo :                                                             บฑฑ
ฑฑบ          ณ cIniTab : inicial do campo que sera buscado no aHeader              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aTitulos : array com os valores dos titulos calculados              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GeraDuplCond( aHeader, aCols, nTipo, cIniTab )
Local cParcela     := ""
Local cDescr       := ""
Local nCount       := 0
Local nPos_ITEM    := 0
Local nPos_TIPPAR  := 0
Local nPos_TPDESC  := 0
Local nPos_DT1VCTO := 0
Local nPos_VALOR   := 0
Local nPos_TPSIST  := 0
Local nPos_TAXANO  := 0
Local nPos_INTERV  := 0
Local nPos_NUMPARC := 0
Local nPos_TPPRIC  := 0
Local nPos_JURINI  := 0
Local nCnt2        := 0
local nLin         := 0
LocAL aConjunto    := {}
Local aTitTmp      := {}
Local aTitulos     := {}
Local dJurosINI    := stod("")
Local aArea        := GetArea()

DEFAULT nTipo   := 2
DEFAULT cIniTab := "LJN"

	nPos_ITEM    := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_ITEM" } )
	nPos_TIPPAR  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_TIPPAR" } )
	nPos_TPDESC  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_TPDESC" } )
	nPos_DT1VCTO := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_1VENC" } )
	nPos_VALOR   := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_VALOR" } )
	
	nPos_TPSIST  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_TPSIST" } )
	nPos_TAXANO  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_TAXANO" } )
	nPos_NUMPARC := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_NUMPAR" } )
	nPos_TPPRIC  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_TPPRIC" } )
	nPos_JURINI  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == cIniTab+"_JURINI" } )

	For nCount := 1 to Len(aCols)
		// se o item nao foi deletado e se foi definido tipo de sistema de amortizacao, 
		// data do 1o. vencimento, quantidade de parcelas e valor a financiar
		If !aCols[nCount][Len(aHeader)+1] ;
			.and. !Empty(aCols[nCount][nPos_TPSIST]) .and. !Empty(aCols[nCount][nPos_DT1VCTO]) ;
			.and. (aCols[nCount][nPos_NUMPAR]>0) .and. (aCols[nCount][nPos_VALOR]>0)

			// existencia do tipo de titulo para obtencao do intervalo entre titulos.
			dbSelectArea("LFD")
			dbSetOrder(1) // LFD_FILIAL+LFD_COD
			If MsSeek( xFilial("LFD")+aCols[nCount][nPos_TIPPAR] )

				If !(nPos_JURINI == 0)
					dJurosINI := aCols[nCount][nPos_JURINI]
				Else
					dJurosINI := aCols[nCount][nPos_DT1VCTO]
				EndIf

				// calcula o valor a ser financiado neste item de condicao de venda
				nPerCorr := 0
				
				// gera os titulos de acordo com o sistema de amortizacao escolhida.
				aTitTmp := T_GMGeraTit( aCols[nCount][nPos_TPSIST] ,aCols[nCount][nPos_DT1VCTO] ,aCols[nCount][nPos_TAXANO] ,LFD->LFD_INTERV ;
				                       ,aCols[nCount][nPos_NUMPAR] ,aCols[nCount][nPos_VALOR] ,/*% do indice de correcao*/ ,nPerCorr ,aCols[nCount][nPos_TPPRIC] ,dJurosINI )

				//
				aAdd( aConjunto ,{ aCols[nCount][nPos_ITEM]   ;
				                  ,aCols[nCount][nPos_TIPPAR] ;
				                  ,aCols[nCount][nPos_TPDESC] ;
				                  ,iIf(LFD->(FieldPos("LFD_EXCLUS"))>0,iIf(Empty(LFD->LFD_EXCLUS),"2",LFD->LFD_EXCLUS),"2") ;
				                  ,LFD->LFD_INTERV  ;
				                  ,aTitTmp ;
				                 } )
			EndIf				
		EndIf
	Next nCount       
	
	// reordena as datas das parcelas
	GMPRCPARC( @aConjunto ) 
	
	//
	// aTitulos[1] Item da Condicao de venda
	// aTitulos[2] Numero da parcela do Titulo
	// aTitulos[3] Data de vencimento
	// aTitulos[4] Descricao do Tipo de Parcela
	// aTitulos[5] Valor da Parcela
	// aTitulos[6] Valor Juros Financiamento
	// aTitulos[7] Saldo Devedor
	//
	aTitulos := {}
	For nCount := 1 To Len( aConjunto )
		For nCnt2 := 1 To Len( aConjunto[nCount][6] )
			aAdd( aTitulos ,{ aConjunto[nCount][1]           ; // [1] Item da Condicao de venda
			                 ,aConjunto[nCount][6][nCnt2][1] ; // [2] Numero da parcela do Titulo
			                 ,aConjunto[nCount][6][nCnt2][2] ; // [3] Data de vencimento 
			                 ,aConjunto[nCount][3]           ; // [4] Descricao do Tipo de Parcela
			                 ,aConjunto[nCount][6][nCnt2][3] ; // [5] Valor da Parcela
			                 ,aConjunto[nCount][6][nCnt2][4] ; // [6] Valor da Juros Financiamento
			                 ,aConjunto[nCount][6][nCnt2][5] ; // [7] Saldo Devedor
			                })
		Next nCnt2
	Next nCount

	// ordena pela data de vencimento e item da condicao de venda
	aSort( aTitulos ,,,{|x,y|dtos(x[3])+x[1] < dtos(y[3])+y[1]})
	
	// se aTitulos estiver vazio	
	If ! Empty(aTitulos) 
		aTitTmp := aClone(aTitulos)
		aTitulos := {}
		Do Case
			//
			// Padrao Siga (data vencto,valor)
			//
			// [1] data vencto 
			// [2] Valor da parcela
			//
			Case nTipo == 1
				For nCount := 1 To len(aTitTmp)
					aAdd(aTitulos ,{ aTitTmp[nCount][3] ,aTitTmp[nCount][5] } )
				Next nCount
				
			//
			// GEM Detalhe (nTipo == 2)
			//
			// [1] Numero parcela 
			// [2] data vencto 
			// [3] Descricao do Tipo de Parcela 
			// [4] Valor da parcela
			//
			Case nTipo == 2
				cParcela := SuperGetMv("MV_1DUP")
				// re-ordena os numeros da parcela
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ cParcela ;
					                ,aTitTmp[nCount][3] ;
					                ,aTitTmp[nCount][4] ;
					                ,aTitTmp[nCount][5] } )
					cParcela := MaParcela(cParcela)
				Next nCount 
				
			//
			// GEM Parcelas detalhadas (nTipo == 3)
			//	
			// [1] Item do Plano
			// [2] Numero da parcela contido nas parcelas pertencentes ao Item do Plano
			// [3] Data de Vencimento
			// [4] Descricao do Tipo de Parcela 
			// [5] Valor da Parcela
			// [6] Juros Mensal
			// [7] Saldo Devedor
			//
			Case nTipo == 3
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ aTitTmp[nCount][1] ;
					                ,aTitTmp[nCount][2] ;
					                ,aTitTmp[nCount][3] ;
					                ,aTitTmp[nCount][4] ;
					                ,aTitTmp[nCount][5] ;
					                ,aTitTmp[nCount][6] ;
					                ,aTitTmp[nCount][7] } )	
				Next nCount 
			
			//
			// GEM Detalhado (nTipo == 4)
			//
			// [1] Numero parcela 
			// [2] data vencto 
			// [3] Descricao do Tipo de Parcela 
			// [4] Valor da parcela
			// [5] Juros Mensal
			// [6] Item do Plano
			// [7] Numero da parcela contido nas parcelas pertencentes ao Item do Plano
			//
			Case nTipo == 4
			
				cParcela := SuperGetMv("MV_1DUP")
				// 
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ cParcela           ;
					                ,aTitTmp[nCount][3] ;
					                ,aTitTmp[nCount][4] ;
					                ,aTitTmp[nCount][5] ;
					                ,aTitTmp[nCount][6] ;
					                ,aTitTmp[nCount][1] ;
					                ,aTitTmp[nCount][2] } )
					cParcela := MaParcela(cParcela)
				Next nCount 
			
		EndCase
	EndIf
    
	restArea(aArea)
	
Return( aTitulos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMA410  บAutor  ณMicrosiga           บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Valida a coluna porcentagem do browse de itens de         บฑฑ
ฑฑบ          ณ  condicao de venda.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMVlrPerc()
Local lOk        := .T.
Local nPosPerc   := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJN_PERCLT"})
Local nPosValor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJN_VALOR"})
Local nPorc      := 0
Local nPorcTotal := 0
Local nVlrParc   := 0
Local nVlrTotal  := 0
Local cVar       := ReadVar()

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

aEval( oGetCVnd:aCols ,{|aColuna,nIndex| iIf( !aColuna[Len(aColuna)] .AND. n <> nIndex ;
                                        ,nVlrParc += aColuna[nPosValor] ;
                                        ,.F.)})

Do Case
	// Valor 
	Case cVar == "M->LJN_VALOR"
		nVlrTotal := nVlrPedido - nVlrParc
		If M->LJN_VALOR <= nVlrTotal 
			If nPosPerc > 0
				M->LJN_PERCLT := Round(((100 * M->LJN_VALOR) / nVlrPedido ),oGetCVnd:aHeader[nPosPerc,5])
				oGetCVnd:aCols[n][nPosPerc] := M->LJN_PERCLT
			EndIf		
		Else
			Alert("Valor nใo pode ser superior a" + transform( nVlrTotal ,x3Picture("C6_VALOR")) )
			lOk := .F.
		EndIf
		
	// Porcentagem
	Case cVar == "M->LJN_PERCLT"
		
		If nPosPerc > 0
			If M->LJN_VALOR > 0 
				M->LJN_PERCLT := Round(((100 * M->LJN_VALOR) / nVlrPedido ),oGetCVnd:aHeader[nPosPerc,5])
			Else
				M->LJN_PERCLT := 0
			EndIf
			oGetCVnd:aCols[n][nPosPerc] := M->LJN_PERCLT
		EndIf		

EndCase

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCVndLinOk บAutor  ณReynaldo Miyashita  บ Data ณ  05.06.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CVndLinOk()
Local lOk          := .T.
Local aLineLJN     := aClone(oGetCVnd:aCols[n])
Local nPos_DT1VCTO := 0
Local nPos_TPSIST  := 0
Local nPos_TAXANO  := 0
Local nPos_NUMPARC := 0
Local nPos_TPPRIC  := 0
Local nPos_JURINI  := 0
Local nPos_IND     := 0
Local nPos_INDPOS  := 0
Local nPos_DIACOR  := 0

	nPos_DT1VCTO := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_1VENC" } )
	
	nPos_TPSIST  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_TPSIST" } )
	nPos_TAXANO  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_TAXANO" } )
	nPos_NUMPARC := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_NUMPAR" } )
	nPos_TPPRIC  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_TPPRIC" } )
	nPos_JURINI  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_JURINI" } )

	nPos_IND     := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_IND" } )
	nPos_INDPOS  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_INDPOS" } )
	nPos_DIACOR  := aScan( oGetCVnd:aHeader ,{|e|Trim(e[2]) == "LJN_DIACOR" } )
	
    // item nao deletado
	If !aLineLJN[Len(aLineLJN)] 
		// Data do primeiro vencimento em branco
		If Empty(aLineLJN[nPos_DT1VCTO])
			msgAlert(STR0024) //"Data do 1o. vencimento nao informada."
			lOk := .F.
		EndIf
	
		// Se foi escolhido um sistema de amortizacao
		If aLineLJN[nPos_TPSIST] $ "12356"
			// Taxa anual deve estar preechido
			If aLineLJN[nPos_TAXANO] <= 0
				msgAlert(STR0025) //"Taxa anual nao informada."
				lOk := .F.
			EndIf
			
			// Se a data de Inicio do juros nao foi preenchido
			If lOk .AND. Empty(aLineLJN[nPos_JURINI])
				msgAlert(STR0026)   //"Informe a data de inicio do Juros."
				lOk := .F.
			EndIf
		EndIf
		
		// Indexador de PRE ou POS habite informado. 
		If lOk .and. (!Empty(aLineLJN[nPos_IND]) .OR. !Empty(aLineLJN[nPos_INDPOS]))
			// naum foi informado o dia da correcao monetaria
			If aLineLJN[nPos_DIACORR]== 0
				MsgAlert(STR0027)    //"Dia da Corre็ao monetaria nao foi informado."
				lOK := .F.
			EndIf
		EndIf		
	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCVndBrwOk บAutor  ณReynaldo Miyashita  บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CVndBrwOk()
Local lOk        := .T.
Local nPosValor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJN_VALOR"})
Local nPorcTotal := 0
Local nVlrTotal  := 0 
Local nNOrig     := 0
Local nCount     := 0

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

aEval( oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[Len(aColuna)] ;
                                      ,nVlrTotal += aColuna[nPosValor] ;
                                      ,.F.)})

	If (nVlrTotal <> nVlrPedido)
	 	// "Diferenca de "  #  " entre o valor do Pedido de Venda com a soma dos valores das parcelas."
		MsgAlert(STR0028 + Transform(nVlrPedido-nVlrTotal,x3Picture("C6_VALOR") ) + STR0029 )
		lOk := .F.	
	EndIf
	
	If lOk
		nNOrig := n 
		For nCount := 1 to len(oGetCVnd:aCols)
			n := nCount
			oGetCVnd:oBrowse:nAt := n
			If ! t_CVndLinOk()
				lOk := .F.
			EndIf
		Next nCount
		n := nNOrig                  
		oGetCVnd:oBrowse:nAt := n
	EndIf    

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMA410  บAutor  ณMicrosiga           บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GMMA410Conf( oDlg ,cCondPag ,aColsOri ,nVlrVenda ,aHeadOri) 
Local nPos        := 0
Local nCount      := 0
Local lModificado := .F.
Local lContinua   := .F.
Local aColsLJN    := aClone(oGetCVnd:aCols)
Local nQtdCnd     := 0

    // Valida a condicao de venda informada
	If T_CVndBrwOk()    
		lContinua   := .T.
		If cCondPag <> GetMV("MV_GMCPAG")
	    	//
	    	// avalia o aColsLJN com o aColsOri para verificar se houve alteracao nos itens da condicao de venda, Dia da correcao monetaria,tipo de price
	    	//                                   
			For nCount := 1 to Len(aColsOri)
		    	// numero de parcelas, valor , tipo de parcela, Fixa data de vencimento, Data de vencimento, Tipo de Sistema, TAXA anual , indice
		    	// for diferente do original
		    	nPos := aScan( aColsLJN ,{|aColuna| !aColuna[len(oGetCVnd:aHeader)+1] .AND. ;
		    	                                    aColuna[02] == aColsOri[nCount][02] .AND. aColuna[03] == aColsOri[nCount][03] .AND. aColuna[05] == aColsOri[nCount][05] .AND. aColuna[07] == aColsOri[nCount][07] .AND. ;
		                                            aColuna[07] == aColsOri[nCount][07] .AND. aColuna[10] == aColsOri[nCount][10] .AND. aColuna[12] == aColsOri[nCount][12] .AND. aColuna[13] == aColsOri[nCount][13] .AND. ;
		                                            aColuna[14] == aColsOri[nCount][14] .AND. aColuna[15] == aColsOri[nCount][15] .AND. aColuna[16] == aColsOri[nCount][16] .AND. aColuna[17] == aColsOri[nCount][17] .AND. ;
		                                            aColuna[18] == aColsOri[nCount][18] })
		    	If nPos == 0
		    		lModificado := .T.
					Exit
				EndIf
			
			Next nCount
		EndIf

   		If lModificado
			M->C5_CONDPAG := GetMV("MV_GMCPAG")
		EndIf
		
		aGEMCVnd :={M->C5_CONDPAG ,oGetCVnd:aHeader ,oGetCVnd:aCols }
			
	EndIf
Return( lContinua )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMXGRCVNDบAutor  ณReynaldo Miyashita  บ Data ณ  10.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava a condicao de venda "personalizada" pro Pedido de     บฑฑ
ฑฑบ          ณVenda.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA410 (A410Grava)                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMXGRCVND()

Local nOpcX      := PARAMIXB[1] // nOpcao
Local cNumPed    := PARAMIXB[2]	// SC5->C5_NUM
Local cCondPag   := PARAMIXB[3] // SC5->C5_CONDPAG
Local nX,nY,nPos
Local nUsado     := 0 
Local nPos_VALOR := 0 
Local aHeadLJN   := {}
Local aColsLJN   := {}
Local aArea	     := {}

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If HasTemplate("LOT")

	aArea := GetArea()
	
	If Type("aGEMCVnd") == "U"
		PRIVATE aGEMCVnd := {"",{},{}}
	EndIf
		
	//cCPag    := aGEMCVnd[1]
	aHeadLJN := iIf( Len(aGEMCVnd)>1 ,aClone(aGEMCVnd[2]) ,{} )
	aColsLJN := iIf( Len(aGEMCVnd)>2 ,aClone(aGEMCVnd[3]) ,{} )
	
	If ! (Empty(aHeadLJN) .AND. Empty(aColsLJN))
	
		nPos_VALOR := aScan( aHeadLJN ,{|e|Trim(e[2]) == "LJN_VALOR" } )
	
		nUsado := Len(aHeadLJN)
		
		dbSelectArea("LJN")
		dbSetOrder(1) // LJN_FILIAL+LJN_NUM+LJN_ITEM
		
		//Se nใo for exclusao
		If ! (nOpcX==3)
			// se for uma condicao de pagamento "personalizado"              
			If cCondPag == GetMV("MV_GMCPAG")
				If len(aColsLJN) > 0
					// exclui todos os itens da condicao de venda do pedido
					MSSeek(xFilial("LJN")+cNumPed)
					While !Eof() .And. xFilial("LJN")+cNumPed == LJN->LJN_FILIAL+LJN->LJN_NUM
						RecLock("LJN",.F.)
						dbDelete()
						MsUnLock()
						dbSkip()
					EndDo
					
					For nX := 1 To Len(aColsLJN)
						// se o item nao foi deletado 
						If !(aColsLJN[nX,nUsado+1]) .AND.(aColsLJN[nX,nPos_VALOR] >0)
							RecLock("LJN",.T.)
							For nY := 1 to fCount()
								If (nPos := aScan( aHeadLJN ,{|aHeader|alltrim(aHeader[2])==alltrim(FieldName(nY)) })) >0 
									LJN->(FieldPut(nY ,aColsLJN[nX][nPos]))
								EndIf
							Next nY
							LJN->LJN_FILIAL := xFilial("LJN")
							LJN->LJN_NUM    := cNumPed
							MsUnLock()
						EndIf
					Next nX
				EndIf
			Else    
				// exclui todos os itens da condicao de venda do pedido
				MSSeek(xFilial("LJN")+cNumPed)
				While !Eof() .And. xFilial("LJN")+cNumPed == LJN->LJN_FILIAL+LJN->LJN_NUM
					RecLock("LJN",.F.)
					dbDelete()
					MsUnLock()
					DbSkip()
				Enddo
			EndIf
		Else	
			// excluir todos os itens da condicao de venda do pedido
			dbSelectArea("LJN")
			dbSeek(xFilial("LJN")+cNumPed)
			While !Eof() .And. xFilial("LJN")+cNumPed == LJN->LJN_FILIAL+LJN->LJN_NUM
				RecLock("LJN",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
		aGEMCVnd := {"",{},{}}
		
	EndIf

RestArea(aArea)

EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa410LJNLoad บAutor  ณReynaldo Miyashita บ Data ณ 07.11.2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os dados sobre a condicao de venda do pedido de    บฑฑ
ฑฑบ          ณ venda e os campos referentes para a montagem do browse     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMMA410.PRW                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a410LJNLoad( cNumPed ,cCondPag ,d1Venc ,nVlrTotal ,aDados )
Local aHeadLJN     := {}
Local aColsLJN     := {}
Local nPos_NUMPAR  := 0
Local nPos_VALOR   := 0
Local nPos_VLPARC  := 0
Local nPos_PERCLT  := 0
Local nPos_FIXVNC  := 0
Local nPos_TPSIST  := 0
Local nPos_JURINI  := 0
Local nY           := 0
Local nCOL_CODEMPR := 0
Local cCodEmpr     := ""
Local lHabite      := .F.
Local aArea		   := GetArea()
Local nTipPar 	   := 0
Local	n1Venc 		:= 0    
DEFAULT d1Venc    := stod("")
DEFAULT nVlrTotal := 0
DEFAULT aDados    := {"" ,{} ,{}}

	dHabite:= iIf(Type("dHabite")== "U" ,stod("") ,dHabite)

	If len(aDados)<>3
		aDados := {"" ,{} ,{}}
	EndIf
	                        
	If aDados[1] <> cCondPag
		aDados[1] := cCondPag
		aDados[3] := {}
	EndIf
	aHeadLJN := aDados[2]
	aColsLJN := aDados[3]
	
	// aheader da SC5 criada na MATA410.PRX, buscar a coluna do empreendimento
	If Type("aHeader") == "A"
		If (nCOL_CODEMPR := aScan( aHeader ,{|aDefCol| aDefCol[2] == "C6_CODEMPR"} ) )>0
			// aCols da SC5 criada na MATA410.PRX, buscar o valor na coluna do empreendimento
			For nY := 1 To Len(aCols)
				If ! Empty(aCols[nY][nCOL_CODEMPR])
					cCodEmpr := aCols[nY][nCOL_CODEMPR]
					Exit
				EndIf
			Next nY
			
			If ! Empty( cCodEmpr )
				dbSelectArea("LIQ")
				dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
				If dbSeek(xFilial("LIQ")+cCodEmpr)
					dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
				EndIf
			EndIf
		EndIf
	EndIf
	
	If len(aHeadLJN)==0
		// monta o aHeadLJN
		aHeadLJN := aClone(TableHeader("LJN"))
		aEval( aHeadLJN ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
		If (nY := aScan( aHeadLJN ,{|aCampo| alltrim(aCampo[2])=="LJN_PERCLT"})) > 0
			If Empty(aHeadLJN[nY][6])
				aHeadLJN[nY][6] := "t_GMVlrPerc()"
			Else
				aHeadLJN[nY][6] := aHeadLJN[nY][6] + " .AND. t_GMVlrPerc()"
			EndIf
		EndIf
		
		nY := aScan( aHeadLJN ,{|aCampo| alltrim(aCampo[2])=="LJN_VALOR"})
		If nY > 0
			If Empty(aHeadLJN[nY][6])
				aHeadLJN[nY][6] := "t_GMVlrPerc()"
			Else
				aHeadLJN[nY][6] := aHeadLJN[nY][6] + " .AND. t_GMVlrPerc()"
			EndIf
		EndIf
		
		nY := aScan( aHeadLJN ,{|aCampo| alltrim(aCampo[2])=="LJN_TPSIST"})
		If nY > 0
			If Empty(aHeadLJN[nY][6])
				aHeadLJN[nY][6] := "t_GEMDTJUR('LJN', dHabite)"
			Else
				aHeadLJN[nY][6] := aHeadLJN[nY][6] + " .AND. t_GEMDTJUR('LJN', dHabite)"
			EndIf
		EndIf

		nY := aScan( aHeadLJN ,{|aCampo| alltrim(aCampo[2])=="LJN_TIPPAR"})
		If nY > 0
			If Empty(aHeadLJN[nY][6])
				aHeadLJN[nY][6] := "t_GEMDTVenc()"
			Else
				aHeadLJN[nY][6] := aHeadLJN[nY][6] + " .AND. t_GEMDTVenc()"
			EndIf
		EndIf
		
	Else
		aEval( aHeadLJN ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
	EndIf
	                   
	nUsado := Len(aHeadLJN)
		
		//verifica tipos de parcelas para saber se existe alguma CHAVES
	dbSelectArea("LFD")
	dbSetOrder(1)  
	nTipPar := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_TIPPAR" } )
	n1Venc := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_1VENC" } ) 	
	If (nTipPar > 0) .and. (n1Venc > 0)    
		For nY := 1 to Len(aColsLJN)
			dbSeek(xFilial("LFD")+aColsLJN[nY][nTipPar],.T.)
			If Alltrim(LFD->LFD_COD) == "4"
				aColsLJN[nY][n1Venc] := dHabite
			EndIF							
		Next nY				
	EndIf	

	If Len(aColsLJN) > 0 .and. ! Empty(cNumPed)
		nPos_VALOR  := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_VALOR" } ) 
 		nPos_PERCLT := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_PERCLT" } ) 
		If nPos_Valor > 0 .AND. nPos_PERCLT > 0
			For nY := 1 to Len(aColsLJN)
				// se o item nao foi deletado 
				If !aColsLJN[nY][Len(aHeadLJN)+1]
					aColsLJN[nY][nPos_PERCLT] := round( (aColsLJN[nY][nPos_VALOR]/nVlrTotal)*100,aHeadLJN[nPos_PERCLT][5])
				EndIf
			Next nY
        EndIf
 		
	Else
		//
		// Condicao de venda personalizada
		//
		If cCondPag == GetMV("MV_GMCPAG")
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz a montagem do aColsLJN                                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("LJN")
			dbSetOrder(1) // LJN_FILIAL+LJN_NUM+LJN_ITEM
			dbSeek(xFilial("LJN")+cNumPed)
			While !Eof() .And. LJN->LJN_FILIAL+LJN->LJN_NUM==xFilial("LJN")+cNumPed
			
				aAdd(aColsLJN,Array(Len(aHeadLJN)+1))
				For nY := 1 to Len(aHeadLJN)
					If ( aHeadLJN[ny][10] != "V")
						aColsLJN[Len(aColsLJN)][ny] := FieldGet(FieldPos(aHeadLJN[ny][2]))
					Else
						aColsLJN[Len(aColsLJN)][ny] := CriaVar(aHeadLJN[ny][2])
					EndIf
					If aHeadLJN[nY][2]=="LJN_VALOR"
						// Porcentagem referente ao valor total do pedido
						If (nPos_PERCLT := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_PERCLT" } )) > 0
							aColsLJN[Len(aColsLJN)][nPos_PERCLT] := round( (aColsLJN[Len(aColsLJN)][nY]/nVlrTotal)*100,aHeadLJN[nPos_PERCLT][5] )
						Endif

					EndIf
					
					If aHeadLJN[nY][2]=="LJN_1VENC" 
						nPos_FIXVNC := aScan( aHeadLJN ,{|x|x[2]=="LJN_FIXVNC" })
						If nPos_FIXVNC > 0 .and. aColsLJN[Len(aColsLJN)][nPos_FIXVNC] == "2"
							aColsLJN[Len(aColsLJN)][nY] := d1Venc
						Endif
        			EndIf
        			
					If aHeadLJN[nY][2]=="LJN_JURINI"
						If (nPos_TPSIST := aScan( aHeadLJN ,{|x| x[2] == "LJN_TPSIST" } ) ) > 0
							If Empty(aColsLJN[Len(aColsLJN)][nY]);
							   .AND. aColsLJN[Len(aColsLJN)][nPos_TPSIST] <> "4"
							 	aColsLJN[Len(aColsLJN)][nY]:= t_gmIniJur(dHabite)
							EndIf
						Endif
					EndIf
					
				Next nY
				aColsLJN[Len(aColsLJN)][Len(aHeadLJN)+1] := .F.
				dbSelectArea("LJN")
				dbSkip()
			End
		Else
			// Condicao de Pagamento
			dbSelectArea("SE4")
			dbSetOrder(1) // E4_FILIAL+E4_CODIGO
			If dbSeek(xFilial("SE4")+cCondPag)
				// condicao de venda - cabecalho
				dbSelectArea("LIR")
				dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
				If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Faz a montagem do aColsLJN                                   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea("LIS")
					dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
					If dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Faz a montagem do aColsLJN                                   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						While !Eof() .And. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
							aAdd(aColsLJN,Array(Len(aHeadLJN)+1))
							For nY := 1 to Len(aHeadLJN)
								If ( aHeadLJN[ny][10] != "V")
									If FieldPos("LIS"+substr(aHeadLJN[ny][2],4)) >0 
										aColsLJN[Len(aColsLJN)][ny] := FieldGet(FieldPos("LIS"+substr(aHeadLJN[ny][2],4)))
									Else   
										aColsLJN[Len(aColsLJN)][ny] := CriaVar(aHeadLJN[ny][2])
									EndIf
								Else
									aColsLJN[Len(aColsLJN)][ny] := CriaVar(aHeadLJN[ny][2])
								EndIf
								
								If aHeadLJN[nY][2]=="LJN_PERCLT"
									aColsLJN[Len(aColsLJN)][nY] := FieldGet(FieldPos("LIS_PERCLT"))
									If (nPos_VALOR := aScan( aHeadLJN ,{|aCol| aCol[2] == "LJN_VALOR" } ) ) > 0
										aColsLJN[Len(aColsLJN)][nPos_VALOR] := round( nVlrTotal*(aColsLJN[Len(aColsLJN)][nY]/100) ,aHeadLJN[nPos_VALOR][5])
									Endif
								EndIf    
								
								If aHeadLJN[nY][2]=="LJN_1VENC" 
									nPos_FIXVNC := aScan( aHeadLJN ,{|x|x[2]=="LJN_FIXVNC" })
									If nPos_FIXVNC > 0 .and. aColsLJN[Len(aColsLJN)][nPos_FIXVNC] == "2"
										aColsLJN[Len(aColsLJN)][nY] := d1Venc
									Endif
	        					EndIf
	        					
								If aHeadLJN[nY][2]=="LJN_JURINI"
									If (nPos_TPSIST := aScan( aHeadLJN ,{|x| x[2] == "LJN_TPSIST" } ) ) > 0
										If Empty(aColsLJN[Len(aColsLJN)][nY]);
										   .AND. aColsLJN[Len(aColsLJN)][nPos_TPSIST] <> "4"
											aColsLJN[Len(aColsLJN)][nY] := t_gmIniJur(dHabite)
										EndIf
									Endif
								EndIf
								
							Next nY
							
							aColsLJN[Len(aColsLJN)][Len(aHeadLJN)+1] := .F.
							
							dbSelectArea("LIS")
							dbSkip()
						End
					EndIf
		        EndIf
			EndIf
		EndIf
    EndIf
    
	// Se naum tiver nenhum item
	If Empty(aColsLJN)
		aadd(aColsLJN,Array(Len(aHeadLJN)+1))
		For nY := 1 to Len(aHeadLJN)
			If Trim(aHeadLJN[nY][2]) == "LJN_ITEM"
				aColsLJN[1][nY] := StrZero(1, TamSX3("LJN_ITEM")[1])
			Else
				aColsLJN[1][nY] := CriaVar(aHeadLJN[nY][2])
			EndIf
			aColsLJN[1][Len(aHeadLJN)+1] := .F.
		Next nY
	Endif
	RestArea(aArea)
	
Return( {cCondPag ,aHeadLJN ,aColsLJN} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEM410PV  บAutor  ณReynaldo Miyashita  บ Data ณ 02.08.2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a condicao de venda do pedido de venda.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA410.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEM410PV()
Local cNumPV    := PARAMIXB[1]
Local cCondPag  := PARAMIXB[2]
Local d1Venc    := PARAMIXB[3]
Local nTotalPed := PARAMIXB[4]
Local aRetorno  := {} 

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return {"",{},{}}
EndIf

	//
	// Valida se a condicao de pagamento ้ uma condicao de pagamento do template GEM.
	//
	If ExecTemplate("GMCondPagto",.F.,.F.,{cCondPag,} )
		//
	    //carrega os dados da condicao de venda do pedido de venda
	    //
		aRetorno := A410LJNLoad( cNumPV ,cCondPag ,d1Venc ,nTotalPed )
		
	EndIf 
	
Return( aRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMCVndVLDบAutor  ณReynaldo Miyashita  บ Data ณ  08/02/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA410.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMCVndVLD( )

Local lRetorno   := iIf( ParamIXB[1] == NIL ,.T. ,ParamIXB[1] )
Local aHeader    := iIf( ParamIXB[2] == NIL ,{}  ,ParamIXB[2] )
Local aCols      := iIf( ParamIXB[3] == NIL ,{}  ,ParamIXB[3] )
Local aCondVnd   := iIf( ParamIXB[4] == NIL ,{}  ,ParamIXB[4] )

Local aArea		 := {}
Local aAreaSA1	 := {}
Local aFisGet	:= {}
Local aFisGetSC5:= {}
Local aSC5Fields:= {}
Local nPLocal   := 0
Local nPTotal   := 0
Local nPValDesc := 0
Local nPPrUnit  := 0
Local nPPrcVen  := 0
Local nPQtdVen  := 0         
Local nQtdCnd   := 0
Local nCount	:= 0
Local nPDtEntr  := 0
Local nPProduto := 0
Local nPTES     := 0
Local nPNfOri   := 0
Local nPSerOri  := 0
Local nPItemOri := 0
Local nPIdentB6 := 0
Local nUsado    := 0
Local nX        := 0
Local nY        := 0 
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local nAcresFin := 0
Local nQtdPeso  := 0
Local nRecOri   := 0
Local nItem     := 0
Local nPosCpo   := 0
Local nPosValor := 0
Local nVlrTotal := 0
Local dDataCnd  := sTod("")
Local cProduto  := ""
Local cCliente  := ""
Local cLoja     := ""
Local lContinua := .T.

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
lContinua := HasTemplate("LOT")

aArea		 := GetArea()
aAreaSA1	 := SA1->(GetArea())

If lContinua .AND. ExecTemplate("GMCondPagto",.F.,.F.,{M->C5_CONDPAG,} )
		
	If lContinua .and. Len(aHeader)>0 .and. Len(aCols) > 0
		nUsado    := Len(aHeader)
		nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
		nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
		nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
		nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
		nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
		nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
		nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
	Else
		lContinua := .F.
	EndIf
	
	If lContinua 
		  
		If Empty(M->C5_CLIENT)
			cCliente := M->C5_CLIENTE
		Else
			cCliente := M->C5_CLIENT
		EndIf
		
		cLoja := M->C5_LOJAENT
		     
		dDataCnd  := M->C5_EMISSAO
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBusca referencias no SC6                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aFisGet	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1) // X3_FILIAL+X3_ALIAS
		MsSeek("SC6")
		While !Eof().And.X3_ARQUIVO=="SC6"
			cValid := UPPER(X3_VALID+X3_VLDUSER)
			If 'MAFISGET("'$cValid
				nPosIni 	:= AT('MAFISGET("',cValid)+10
				nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
				cReferencia := Substr(cValid,nPosIni,nLen)
				aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			If 'MAFISREF("'$cValid
				nPosIni		:= AT('MAFISREF("',cValid) + 10
				cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
				aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			dbSkip()
		EndDo
		aSort(aFisGet,,,{|x,y| x[3]<y[3]})
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBusca referencias no SC5                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aFisGetSC5	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1) // X3_FILIAL+X3_ALIAS
		MsSeek("SC5")
		While !Eof().And.X3_ARQUIVO=="SC5"
			cValid := UPPER(X3_VALID+X3_VLDUSER)
			If 'MAFISGET("'$cValid
				nPosIni 	:= AT('MAFISGET("',cValid)+10
				nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
				cReferencia := Substr(cValid,nPosIni,nLen)
				aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			If 'MAFISREF("'$cValid
				nPosIni		:= AT('MAFISREF("',cValid) + 10
				cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
				aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			dbSkip()
		EndDo
		aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa a funcao fiscal                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		MaFisSave()
		MaFisEnd()
		MaFisIni(cCliente,;						// 1-Codigo Cliente/Fornecedor
			     cLoja,;						// 2-Loja do Cliente/Fornecedor
			     IIf(M->C5_TIPO$'DB',"F","C"),;	// 3-C:Cliente , F:Fornecedor
			     M->C5_TIPO,;					// 4-Tipo da NF
			     M->C5_TIPOCLI,;				// 5-Tipo do Cliente/Fornecedor
			     Nil,;
			     Nil,;
			     Nil,;
			     Nil,;
			     "MATA461")
		
		//Na argentina o calculo de impostos depende da serie.
		If cPaisLoc == 'ARG'
			SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
			SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
			MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAgrega os itens para a funcao fiscal         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
			For nX := 1 To Len(aCols)
				nQtdPeso := 0
				If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
					nItem++
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณPosiciona Registros                          ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cProduto := aCols[nX][nPProduto]
					MatGrdPrRf(@cProduto)
					SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD
					If SB1->(MsSeek(xFilial("SB1")+cProduto))
						nQtdPeso := aCols[nX][nPQtdVen]*SB1->B1_PESO
					EndIf
					
		        	If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
						SD1->(dbSetOrder(4)) // D1_FILIAL+D1_NUMSEQ
						If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
							nRecOri := SD1->(Recno())
						EndIf
		        	ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
						If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
							SD1->(dbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
							If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+cCliente+cLoja+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
								nRecOri := SD1->(Recno())
							EndIf
						EndIf
					EndIf
		            SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
		            SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
		            SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
		            SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCalcula o preco de lista                     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					nValMerc  := aCols[nX][nPTotal]
					nPrcLista := aCols[nX][nPPrUnit]
					If ( nPrcLista == 0 )
						nPrcLista := NoRound(nValMerc/aCols[nX][nPQtdVen],TamSX3("C6_PRCVEN")[2])
					EndIf
					nAcresFin := A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
					nValMerc  += A410Arred(aCols[nX][nPQtdVen]*nAcresFin,"D2_TOTAL")
					nDesconto := a410Arred(nPrcLista*aCols[nX][nPQtdVen],"D2_DESCON")-nValMerc
					nDesconto := IIf(nDesconto==0,aCols[nX][nPValDesc],nDesconto)
					nDesconto := Max(0,nDesconto)
					nPrcLista += nAcresFin
					
					//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
					If cPaisLoc=="BRA"
						nValMerc  += nDesconto
					Endif
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica a data de entrega para as duplicatasณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If ( nPDtEntr > 0 )
						If ( dDataCnd > aCols[nX][nPDtEntr] .And. !Empty(aCols[nX][nPDtEntr]) )
							dDataCnd := aCols[nX][nPDtEntr]
						EndIf
					Else
						dDataCnd  := M->C5_EMISSAO
					EndIf
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAgrega os itens para a funcao fiscal         ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					MaFisAdd(cProduto,;   			// 1-Codigo do Produto ( Obrigatorio )
						     aCols[nX][nPTES],;	   	// 2-Codigo do TES ( Opcional )
						     aCols[nX][nPQtdVen],; 	// 3-Quantidade ( Obrigatorio )
						     nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
						     nDesconto,; 			// 5-Valor do Desconto ( Opcional )
						     "",;	   				// 6-Numero da NF Original ( Devolucao/Benef )
						     "",;					// 7-Serie da NF Original ( Devolucao/Benef )
						     nRecOri,;				// 8-RecNo da NF Original no arq SD1/SD2
						     0,;					// 9-Valor do Frete do Item ( Opcional )
						     0,;					// 10-Valor da Despesa do item ( Opcional )
						     0,;					// 11-Valor do Seguro do item ( Opcional )
						     0,;					// 12-Valor do Frete Autonomo ( Opcional )
						     nValMerc,;				// 13-Valor da Mercadoria ( Obrigatorio )
						     0)						// 14-Valor da Embalagem ( Opiconal )	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCalculo do ISS                               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
					SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
					If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N")
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAltera peso para calcular frete              ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					MaFisAlt("IT_PESO",nQtdPeso,nItem)
					MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
					MaFisAlt("IT_VALMERC",nValMerc,nItem)
				EndIf
			Next nX
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIndica os valores do cabecalho               ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		MaFisAlt("NF_FRETE",M->C5_FRETE)
		MaFisAlt("NF_SEGURO",M->C5_SEGURO)
		MaFisAlt("NF_AUTONOMO",M->C5_FRETAUT)
		MaFisAlt("NF_DESPESA",M->C5_DESPESA)
		If M->C5_DESCONT > 0
			MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,M->C5_DESCONT+MaFisRet(,"NF_DESCONTO")))
		EndIf
		If M->C5_PDESCAB > 0
			MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*M->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza alteracoes de referencias do SC6         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SC6")
		If Len(aFisGet) > 0
			For nX := 1 to Len(aCols)
				If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
					For nY := 1 to Len(aFisGet)
						nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
						If nPosCpo > 0	
							If !Empty(aCols[nX][nPosCpo])
								MaFisAlt(aFisGet[ny][1],aCols[nX][nPosCpo],nX,.F.)
							Endif
						EndIf
					Next nX	
				Endif
			Next nY
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza alteracoes de referencias do SC5         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Len(aFisGetSC5) > 0	
			dbSelectArea("SC5")
			For nY := 1 to Len(aFisGetSC5)
				If (nPosCPO := aScan(aSC5Fields,{|x| AllTrim(x[1])==Alltrim(aFisGetSC5[ny][2]) })) > 0 
					If !Empty(aSC5Fields[nPosCPO][2])
						If aFisGetSC5[ny][1] == "NF_SUFRAMA"
							MaFisAlt(aFisGetSC5[ny][1],Iif(aSC5Fields[nPosCPO][2] == "1",.T.,.F.),nItem,.F.)
						Else
							MaFisAlt(aFisGetSC5[ny][1],aSC5Fields[nPosCPO][2],nItem,.F.)
						Endif
					EndIf
				EndIf
			Next nY
		Endif
		
		MaFisWrite(1)
		
		// Se for condicao de venda personalizada
		If M->C5_CONDPAG == GetMV("MV_GMCPAG")
			If len(aCondVnd) <= 2 .or. (len(aCondVnd[2]) <= 0 .AND. len(aCondVnd[3]) <= 0 )
				MsgAlert(STR0030)  //"Nใo foi informado a condicao de venda."
				lContinua := .F.
				lRetorno  := .F.
			EndIf
		// se for uma condicao de venda padrao
		Else
			// e naum foi informado
			If len(aCondVnd) <= 2 .or. (len(aCondVnd[2]) <= 0 .AND. len(aCondVnd[3]) <= 0 )
				aCondVnd := A410LJNLoad( "" ,M->C5_CONDPAG ,dDataCnd,MaFisRet(,"NF_BASEDUP") )
			Endif
		EndIf
		
		If lContinua .AND. (nPosValor := aScan(aCondVnd[2] ,{|e|Trim(e[2])=="LJN_VALOR"})) > 0
		
			aEval( aCondVnd[3] ,{|aColuna| iIf( !aColuna[Len(aColuna)] ;
			                              ,nVlrTotal += aColuna[nPosValor] ;
			                              ,.F. )})
	        // Diferenca de    ###  " entre o valor do Pedido e a soma dos valores da condicao de venda."
			If (nVlrTotal <> MaFisRet(,"NF_BASEDUP") )
				MsgAlert(STR0028+ Transform(MaFisRet(,"NF_BASEDUP")-nVlrTotal ,x3Picture("LJN_VALOR") ) + STR0031)
				lRetorno := .F.
			EndIf
		
		EndIf             
		
		nQtdCnd := aScan(aCondVnd[2],{|x| alltrim(x[2])==alltrim("LJN_NUMPAR")})		

		For nCount := 1 to Len(aCondVnd[3]) 
			If (aCondVnd[3][nCount][nQtdCnd] == 0) .AND. !(aCondVnd[3][nCount][Len(aCondVnd[3][nCount])])
				Alert(STR0041)  //"Existe quantidade zerada em algum item desta condi็ใo. Favor verificar." 
				lRetorno := .F.
				Exit								
			Endif
		Next nCount
		
		EndIf

		
		MaFisEnd()
		MaFisRestore()

EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA410BUTบAutor  ณReynaldo Miyashita  บ Data ณ  20.02.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona o botใo para cadastro de solidarios no Dialog do   บฑฑ
ฑฑบ          ณpedido de venda.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA410.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA410BUT()
Local nOpcX       := PARAMIXB[1] //nOpc
Local cC5_NUM     := PARAMIXB[2] //M->C5_NUM
Local cC5_CLIENTE := PARAMIXB[3] //M->C5_CLIENTE
Local cC5_LOJACLI := PARAMIXB[4] //M->C5_LOJACLI

Local aButtons := {}

If HasTemplate("LOT")
	Aadd(aButtons,{"GROUP", {|| ExecTemplate("GEMDLGSOL",.F.,.F.,{nOpcx,M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI}) } ,STR0032,STR0033}) //"Cadastro de Solidarios"#Solidarios
EndIf

Return( aButtons )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMVPL    บAutor  ณReynaldo Miyashita  บ Data ณ  11/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula o Valor Presente Liquido                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nVF      = Valor Futuro                                    บฑฑ
ฑฑบ          ณ nTaxa    = Taxa de Juros a ser aplicado (desconto)         บฑฑ
ฑฑบ          ณ nPeriodo = Periodo                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ nVPL     = Valor Presente Liquido                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMVPL( nVF ,nTaxa ,nPeriodo )
Local nVPL := 0

	nVPL = nVF / ((1+nTaxa)^nPeriodo)

Return( nVPL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMDTVenc บAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a data do primeiro vencimento conforme a data de    บฑฑ
ฑฑบ          ณ previsao de habite-se.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMDTVenc()
Local nPos_1VENCTO := 0
Local aArea := GetArea()

	If (nPos_1VENCTO := aScan( oGetCVnd:aHeader ,{|aCol| alltrim(aCol[2]) == "LJN_1VENC" } ))>0
		oGetCVnd:aCols[n][nPos_1VENCTO] := dDataBase
		dbSelectArea("LFD")	
		dbSetOrder(1) // LFD_FILIAL+LFD_COD
		If dbSeek(xFilial("LFD")+M->LJN_TIPPAR)
			oGetCVnd:aCols[n][nPos_1VENCTO] := iIf( LFD->LFD_TIPO == "C" ,dHabite ,dDataBase)
		EndIf
	EndIf

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMDTJUR  บAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a data de juros inicio conforme a data de previsao  บฑฑ
ฑฑบ          ณ de habite-se.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cIniTab : inicial do campo que sera buscado no aHeader     บฑฑ
ฑฑบ          ณ dInicio : data de inicio do juros                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMDTJUR( cIniTab, dInicio )
Local nPos_JURINI := 0

dInicio := t_GMIniJur(dInicio)
If cIniTab == "LJN"
	If (nPos_JURINI := aScan( oGetCVnd:aHeader ,{|aCol| alltrim(aCol[2]) == "LJN_JURINI" } ))>0
		oGetCVnd:aCols[n][nPos_JURINI] := iIf( M->LJN_TPSIST <> "4" ,dInicio ,stod(""))
	EndIf
ElseIf cIniTab == "LJU"
	If (nPos_JURINI := aScan( oGetCVnd:aHeader ,{|aCol| alltrim(aCol[2]) == "LJU_JURINI" } ))>0
		oGetCVnd:aCols[n][nPos_JURINI] := iIf( M->LJU_TPSIST <> "4" ,dInicio ,stod(""))
	EndIf
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    |GEM410LI   ณ Autor ณ Reynaldo Miyashita     ณ Data ณ 07.06.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Valida a linha do browse de itens de pedido de venda para caso ณฑฑ
ฑฑณ          ณ tenha sido informado uma unidade do empreendimento.            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEM410LI()
Local nLinPos      := iIf( ParamIXB[1] == NIL ,N ,ParamIXB[1] ) 
Local nPos_CODEMPR := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CODEMPR"})
Local nPos_PRODUTO := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local aBrwLin      := 0 
Local nCount       := 0
Local lRet		   := .T.
Local aArea        := GetArea()
Local aAreaLIQ     := {}
Local aAreaSC6     := SC6->(GetArea())

	// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios
	If !HasTemplate("LOT")
		Return( lRet )
	EndIf

	aAreaLIQ := LIQ->(GetArea())
	aBrwLin  := aCols[nLinPos]

	If nPos_CODEMPR > 0
		// se foi informado o codigo da unidade
		If !Empty(aBrwLin[nPos_CODEMPR])
			// Unidades do empreendimento
			dbSelectArea("LIQ")
			dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
			If dbSeek(xFilial("LIQ")+aBrwLin[nPos_CODEMPR])
			    // Produto referenciado a uma unidade do empreendimento
				If LIQ->LIQ_CODPRD == aBrwLin[nPos_PRODUTO]
					// unidade reservada ou com contrato assinado
					If LIQ->LIQ_STATUS $ "CA/RE"
						// Itens do pedido de venda
						dbSelectArea("SC6")
						dbSetOrder(2) // C6_PRODUTO+C6_NUM+C6_ITEM
						dbSeek(xFilial("SC6")+aBrwLin[nPos_PRODUTO])
						While SC6->(!EOF()) .AND. SC6->C6_PRODUTO == aBrwLin[nPos_PRODUTO]
							
							If SC6->C6_CODEMPR == aBrwLin[nPos_CODEMPR] .AND. !(M->C5_NUM == SC6->C6_NUM)
							
								// Unidade Reservada
				    			If LIQ->LIQ_STATUS $ "RE" 
				    				// sem nota
				    				If Empty(SC6->C6_NOTA) .and. Empty(SC6->C6_SERIE) .and. Empty(SC6->C6_DATFAT)
				    					// Template GEM   ## A Unidade   ##" estแ reservada no pedido: "  ## Ok
										Aviso(STR0034 ,STR0035 + Alltrim(aBrwLin[nPos_CODEMPR]) + STR0036 + Alltrim(SC6->C6_NUM) + ".", {STR0037})
										lRet := .F.
										Exit
									EndIf
								EndIf
							
								// Unidade com contrato Assinado
				    			If LIQ->LIQ_STATUS $ "CA"
									dbSelectArea("LIT")
									dbSetOrder(1) // LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
									If dbSeek(xFilial("LIT")+ SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA)
				    					// Template GEM   ## A Unidade   ##" foi vendido no contrato: "  ## Ok
										Aviso(STR0034 ,STR0035 + Alltrim(aBrwLin[nPos_CODEMPR]) + STR0038 + Alltrim(LIT->LIT_NCONTR) + ".", {STR0037})
									Else
				    					// Template GEM   ## A Unidade   ##" jแ foi vendida."  ## Ok
										Aviso(STR0034 ,STR0035 + Alltrim(aBrwLin[nPos_CODEMPR]) + STR0039, {STR0037})
									EndIf
									lRet := .F.
									Exit
								EndIf
							
							EndIf
							
							dbSelectArea("SC6")
							dbSkip()
						EndDo
					EndIf
				Else
					// Template GEM   ## "O produto informado nใo se refere a unidade do empreendimento."
					Aviso(STR0039 ,STR0040, {STR0037})
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
		
	EndIf

RestArea(aAreaSC6)
RestArea(aAreaLIQ)
RestArea(aArea)
	
Return( lRet )


Function TableHeader(cAlias)
Local aArea := GetArea()
Local aHead := {}

	aHead := aClone(APBuildHeader(cAlias))
/*	
	// montagem do aHeaderAFA
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !EOF() .And. (x3_arquivo == cAlias)
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel 
			AADD(aHead ,{ TRIM(x3titulo()), x3_campo, x3_picture,;
					      x3_tamanho, x3_decimal, x3_valid,;
					      x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	EndDo
*/
RestArea(aArea)

Return( aHead )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMIniJur  บAutor  ณReynaldo Miyashita  บ Data ณ  05.08.2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o inicio de juros de um financiamento baseado na    บฑฑ
ฑฑบ          ณdata informada.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMIniJur(dHabite)
Local dReturn := stod("")
Local nMeses := GetNewPar("MV_GEMNJRF",0)
Local dNewReturn

	If nMeses >0
		dReturn := GMNextMonth( dHabite ,nMeses )
	Else
		dReturn := dHabite
	EndIf
	
If ExistBlock("GEMINIJUR")
	dNewReturn := ExecBlock("GEMINIJUR", .F., .F., {dReturn})
	If ValType(dNewReturn) == "D"
		dReturn := dNewReturn
	EndIf
EndIf
Return dReturn
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerWhenLJNบAutor  ณClovis Magenta      บ Data ณ  08/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o valor da aCols no campo LJN_TPSIST para tratame- บฑฑ
ฑฑบ          ณto do x3_when do campo LJN_TPPRIC                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function VerWhenLJN()

Local lRet		:= .F. 
Local nPosTpSis := 0
                                 
If (ValType(aHeader) == "A") .and. (ValType(aCols) == "A")
	nPosTpSis := aScan(aHeader, { |x| AllTrim(x[2]) == "LJN_TPSIST"} )    
	If (nPosTpSis > 0)
		If aCols[n,nPosTpSis] == "1"  // Se tipo de sistema = Price, libera uso do campo LJN_TPPRIC
			lRet := .T.
		EndIf
    EndIf
EndIf

Return(lRet)
