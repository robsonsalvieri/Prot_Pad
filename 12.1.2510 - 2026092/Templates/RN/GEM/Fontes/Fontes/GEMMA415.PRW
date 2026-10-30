#include "protheus.ch"
#include "GEMMA415.ch"

Static dHabite := stod("")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA415CVNบAutor  ณReynaldo Miyashita  บ Data ณ  30.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog para customizar a condicao de venda e simular os    บฑฑ
ฑฑบ          ณ titulos a receber.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA415.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA415CVND()
Local nOpcX	    := PARAMIXB[1] //nOpc
Local cNumORC   := PARAMIXB[2] //M->CJ_NUM
Local cCondPag  := PARAMIXB[3] //M->CJ_CONDPAG
Local d1Venc    := PARAMIXB[4] // Data do primeiro vencimento
Local nVlrTotal := PARAMIXB[5] // Valor total do Orcamento

Local cCadastro   := STR0001 //"Condi็ใo de Venda"
Local cCodCndVnd  := ""
Local cDescCndVnd := ""
Local cX3_Valid   := ""
Local nUsado      := 0
Local nY          := 0
Local nOpcGD      := 0
Local aObjects    := {}
Local aSize       := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aColsOri    := {}
Local aHeadLJT    := {}
Local aColsLJT    := {}
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
Private aHeadTit  := { "Parcela" ,"Vencto" ,"Tipo Parcela" ,"Valor do Titulo" }
Private nSaldoDup := nVlrTotal
	
// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( .T. )
EndIf

	If Type("aGEMCVnd") == "U"
		PRIVATE aGEMCVnd :={"",{},{}}
	Endif

	// carrega o aheader e acols do browse dos itens de pagamento da tabela LJT
	A415LJTLoad( cNumORC ,cCondPag ,d1Venc ,nVlrTotal ,@aGEMCVnd )
    
	aHeadLJT := aGEMCVnd[2]
	aColsLJT := aGEMCVnd[3]

	If Len(aHeadLJT) > 0 .AND. Len(aColsLJT) > 0 
	    // Os registros com valor original
		aColsOri := aClone(aColsLJT)

		dbSelectArea("LJT")
		RegToMemory( "LJT" ,(nOpcX==3) )

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
		@ 5 ,240 SAY OemToAnsi("Valor Total:")+Transform(nVlrTotal ,"@E 999,999,999,999.999" ) FONT oArialBold SIZE 200,16 PIXEL OF oDlg
		
		// visualiza a condicao de venda
		// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
		oGetCVnd := MsNewGetDados():New( 20,10,100,350 ,nOpcGD ,"AllwaysTrue","t_GMMA415BrwOk","+LJT_ITEM",,,9999,,,,oDlg,aHeadLJT,aColsLJT)
	
		// visualiza as parcelas conforme a condicao de venda informado
		oPnlTit := TPanel():New(110,10,'',oDlg, ,.T.,.T.,, ,340,100,.T.,.T. )
		
		oBrwTit := TWBrowse():New( 5,10,100,340,,aHeadTit ,/*tamanho*/ ,oPnlTit,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
		oBrwTit:Align := CONTROL_ALIGN_ALLCLIENT
		a415BrwRefresh( oGetCVnd:aHeader ,aColsLJT ,@oBrwTit )
	
		@ 220,170 BUTTON OemToAnsi(STR0008)		SIZE 040,11 ACTION a415BrwRefresh( oGetCVnd:aHeader ,oGetCVnd:aCols ,@oBrwTit ) OF oDlg WHEN nOpcGD <> 0 PIXEL //"Recalculo"
		@ 220,220 BUTTON OemToAnsi(STR0009)		SIZE 040,11 ACTION (Iif( A415Conf( @oDlg ,aGEMCVnd[1] ,aColsOri ),oDlg:End(),.F.)) OF oDlg WHEN nOpcGD <> 0 PIXEL   // Confirmar
		@ 220,270 BUTTON OemToAnsi(STR0010)			SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL //Sair
		
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgBox(STR0011)   //"Erro na montagem da condicao de venda"
	EndIf
	
	RestArea(aArea)
	
Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa415BrwRefบAutor  ณReynaldo Miyashita  บ Data ณ  31.01.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o browse com os valores dos titulos conforme       บฑฑ
ฑฑบ          ณ condicao de venda montado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a415BrwRefresh( aHeader ,aCols ,oBrw )
Local aTitulos := {}
Local aTits    := {}
                  
	CursorWait()
	
	aTitulos := {{}}
	aEval(aHeader ,{|aIt|aAdd(aTitulos[1],CriaVar(aIt[2])) })
   	oBrw:SetArray(aTitulos)
	oBrw:bLine := {|| aTitulos[oBrw:nAT] }
	oBrw:refresh()
	
	// gera os titulos a receber para visualizar conforme a customizacao da condicao de venda
	aTitulos := a415GeraDupl( aHeader ,aCols )
	If Empty(aTitulos)
		aTitulos := {{strzero(1,TamSX3("LJT_ITEM")[1]),stod(""),"",0}}
	EndIf
	Aeval(aTitulos ,{|aTitulo| aAdd(aTits ,{ aTitulo[1] ,transform(aTitulo[2],x3Picture("E1_VENCTO")) ,aTitulo[3] ,transform(aTitulo[4],x3Picture("E1_VALOR")) } ) })
   	oBrw:SetArray(aTits)
	oBrw:bLine := {|| aTits[oBrw:nAT] }
	
	CursorArrow()
	
Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA415DupบAutor  ณReynaldo Miyashita  บ Data ณ  31.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera os titulos a receber conforme a condicao de venda.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA415Dupl()
Local cNumORC   := iIf( PARAMIXB[1] == NIL ,""        ,PARAMIXB[1] ) 
Local cCondPag  := iIf( PARAMIXB[2] == NIL ,""        ,PARAMIXB[2] ) 
Local d1Venc    := iIf( PARAMIXB[3] == NIL ,dDataBase ,PARAMIXB[3] ) 
Local cTipoDupl := iIf( PARAMIXB[4] == NIL ,1         ,PARAMIXB[4] ) 
Local nVlrTotal := iIf( PARAMIXB[5] == NIL ,0         ,PARAMIXB[5] ) 
Local aVencto   := iIf( PARAMIXB[6] == NIL ,{}        ,PARAMIXB[6] ) 
Local aRetorno  := {}

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( aVencto )
EndIf

	If Type("aGEMCVnd") == "U"
		PRIVATE aGEMCVnd :={"",{},{}}
	Endif
	
	// carrega o aheader e acols do browse dos itens de pagamento da tabela LJT
	A415LJTLoad( cNumORC ,cCondPag ,d1Venc ,nVlrTotal ,@aGEMCVnd )
       
   	// gera as duplicatas conforme a condicao de venda informada
	aRetorno := a415GeraDupl( aGEMCVnd[2] ,aGEMCVnd[3] ,cTipoDupl )
	
	If Empty(aRetorno)
		aRetorno := aClone(aVencto)
	EndIf
	
Return( aRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa415GeraDuบAutor  ณReynaldo Miyashita  บ Data ณ  31.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera as duplicadas conforme a condicao de venda customizadoบฑฑ
ฑฑบ          ณ no browse.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a415GeraDupl( aHeader ,aCols ,nTipo )
Local cParcela     := ""
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
Local aTitTmp      := {}
Local aTitulos     := {}
Local aArea        := GetArea()
Local aConjunto := {}
Local nCnt2 := 0

DEFAULT nTipo := 2

	nPos_ITEM    := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_ITEM" } )
	nPos_TIPPAR  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_TIPPAR" } )
	nPos_TPDESC  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_TPDESC" } )
	nPos_DT1VCTO := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_1VENC" } )
	nPos_VALOR   := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_VALOR" } )
	
	nPos_TPSIST  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_TPSIST" } )
	nPos_TAXANO  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_TAXANO" } )
	nPos_NUMPARC := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_NUMPAR" } )
	nPos_TPPRIC  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_TPPRIC" } )

	For nCount := 1 to Len(aCols)
		// se o item nao foi deletado 
		If !aCols[nCount][Len(aHeader)+1] ;
			.AND. !Empty(aCols[nCount][nPos_TPSIST]) .and. !Empty(aCols[nCount][nPos_DT1VCTO]) ;
			.and. (aCols[nCount][nPos_NUMPAR]>0) .and. (aCols[nCount][nPos_VALOR] >0)

			// existencia do tipo de titulo para obtencao do intervalo entre titulos.
			dbSelectArea("LFD")
			dbSetOrder(1) // LFD_FILIAL+LFD_COD
			If MsSeek( xFilial("LFD")+aCols[nCount][nPos_TIPPAR] )
				// calcula o valor a ser financiado neste item de condicao de venda
				nPerCorr := 0
				
				// gera os titulos de acordo com o sistema de amortizacao escolhida.
				aTitTmp := T_GMGeraTit( aCols[nCount][nPos_TPSIST] ,aCols[nCount][nPos_DT1VCTO] ,aCols[nCount][nPos_TAXANO] ,LFD->LFD_INTERV ;
				                       ,aCols[nCount][nPos_NUMPAR] ,aCols[nCount][nPos_VALOR] ,/*% do indice de correcao*/ ,nPerCorr ,aCols[nCount][nPos_TPPRIC] ,iIf(Empty(dHabite),dDatabase,t_GMIniJur(dHabite)) )

				//
				aAdd( aConjunto ,{ aCols[nCount][nPos_ITEM] ;
				                  ,aCols[nCount][nPos_TIPPAR] ;
				                  ,aCols[nCount][nPos_TPDESC] ;
				                  ,iIf(LFD->(FieldPos("LFD_EXCLUS"))>0,iIf(Empty(LFD->LFD_EXCLUS),"2",LFD->LFD_EXCLUS),"2") ;
				                  ,LFD->LFD_INTERV ;
				                  ,aTitTmp } )

			EndIf
		EndIf
	Next nCount       
	
	// reordena as datas das parcelas
	GMPRCPARC( @aConjunto ) 
	
	//
	// aTitulos[1] Item da condicao de venda   
	// aTitulos[2] Numero da parcela do Titulo 
	// aTitulos[3] Data de Vencimento          
	// aTitulos[4] Descricao do tipo de parcela
	// aTitulos[5] Valor da Parcela            
	// aTitulos[6] Valor do Juros Financiamento
	// aTitulos[7] Saldo Devedor
	//
	aTitulos := {}
	For nCount := 1 To Len( aConjunto )
		For nCnt2 := 1 To Len( aConjunto[nCount][6] )
			aAdd( aTitulos ,{ aConjunto[nCount][1]           ;  // [1] Item da condicao de venda   
			                 ,aConjunto[nCount][6][nCnt2][1] ;  // [2] Numero da parcela do Titulo 
			                 ,aConjunto[nCount][6][nCnt2][2] ;  // [3] Data de Vencimento          
			                 ,aConjunto[nCount][3]           ;  // [4] Descricao do tipo de parcela
			                 ,aConjunto[nCount][6][nCnt2][3] ;  // [5] Valor da Parcela            
			                 ,aConjunto[nCount][6][nCnt2][4] ;  // [6] Valor do Juros Financiamento
			                 ,aConjunto[nCount][6][nCnt2][5] }) // [7] Saldo Devedor
		Next nCnt2
	Next nCount
	
	// ordena pela data de vencimento e item da condicao de venda
	aSort( aTitulos ,,,{|x,y|dtos(x[3])+x[1] < dtos(y[3])+y[1]})
	
	// se aTitulos estiver vazio	
	If ! Empty(aTitulos) 
		aTitTmp := aClone(aTitulos)
		aTitulos := {}
		Do Case
			// Padrao Siga (data vencto,valor)
			Case nTipo == 1
				For nCount := 1 To len(aTitTmp)
					aAdd(aTitulos ,{ aTitTmp[nCount][3] ,aTitTmp[nCount][5] } )
				Next nCount
			// GEM Detalhe 1 ( Numero parcela , data vencto ,Tipo de Parcela ,valor )
			Case nTipo == 2
				cParcela := SuperGetMv("MV_1DUP")
				// re-ordena os numeros da parcela
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ cParcela ,aTitTmp[nCount][3],aTitTmp[nCount][4] ,aTitTmp[nCount][5] } )
					cParcela := MaParcela(cParcela)
				Next nCount 
			// GEM - Detalhe da Amortizacao 
			OtherWise
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ aTitTmp[nCount][1] ,aTitTmp[nCount][2] ,aTitTmp[nCount][3] ,aTitTmp[nCount][5] ,aTitTmp[nCount][6] ,aTitTmp[nCount][7] } )
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
ฑฑบPrograma  ณGMMA415PerบAutor  ณMicrosiga           บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a coluna de porcentagem do browse de condicao de    บฑฑ
ฑฑบ          ณ venda.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA415Perc()
Local lOk        := .T.
Local nPosPerc   := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJT_PERCLT"})
Local nPosValor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJT_VALOR"})
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
	Case cVar == "M->LJT_VALOR"
		nVlrTotal := nSaldoDup - nVlrParc
		If M->LJT_VALOR <= nVlrTotal
			M->LJT_PERCTL := Round(((100 * M->LJT_VALOR) / nSaldoDup ),oGetCVnd:aHeader[nPosPerc,5])
			oGetCVnd:aCols[n][nPosPerc] := M->LJT_PERCTL
		Else
			Alert(STR0012 + transform( nVlrTotal ,"@E 999,999,999.99") ) //"Valor nใo pode ser superior a"
			lOk := .F.
		EndIf
		
	// Porcentagem
	Case cVar == "M->LJT_PERCLT"
		nPorcTotal := 100 - nPorc 
		If M->LJT_PERCLT <= nPorcTotal
			M->LJT_VALOR := Round(( nSaldoDup * M->LJT_PERCLT / 100),2)
			oGetCVnd:aCols[n][nPosValor] := M->LJT_VALOR
		Else
			Alert(STR0013 + transform( nPorcTotal ,"@E 999.99%") )   //"A porcentagem nใo pode ser superior a"
			lOk := .F.
		EndIf
EndCase

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMMA415BrwบAutor  ณReynaldo Miyashita  บ Data ณ  30.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMMA415BrwOk()
Local lOk        := .T.
Local nPosPerc   := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJT_PERCLT"})
Local nPosValor  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJT_VALOR"})
Local nPorcTotal := 0
Local nVlrTotal  := 0

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

aEval( oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[Len(aColuna)] ;
                                      ,(nPorcTotal += aColuna[nPosPerc] ,nVlrTotal += aColuna[nPosValor]) ;
                                      ,.F.)})

	If (nPorcTotal <> 100) .OR. (nVlrTotal <> nSaldoDup)
		Alert(STR0014 ) //"A porcentagem de distribuicao deve ser igual a 100.00%."
		lOk := .F.	
	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA415Conf  บAutor  ณReynaldo Miyashita  บ Data ณ  30.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirmacao da customizacao da condicao de venda.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A415Conf( oDlg ,cCondPag ,aColsOri ) 
Local nPos        := 0
Local nPos2       := 0
Local nPorc       := 0
Local nCount      := 0
Local nPosPerc    := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJT_PERCLT"})
Local lModificado := .F.
Local lContinua   := .T.
Local aColsLJT    := aClone(oGetCVnd:aCols)
    
	aEval( aColsLJT ,{|aColuna| iIf( !aColuna[Len(aColuna)]        ;
	                                ,(nPorc += aColuna[nPosPerc] ) ;
	                                ,.F.)})
	                                
	If nPorc <> 100
		MsgAlert(STR0015) //"A soma dos percentuais das parcelas deve ser igual a 100.00%"
		lContinua := .F.
	EndIf
         
	If lContinua
		If cCondPag <> GetMV("MV_GMCPAG")
	    	//
	    	// avalia o aColsLJT com o aColsOri para verificar se houve alteracao nos itens da condicao de venda, Dia da correcao monetaria,tipo de price
	    	//                                             
			For nCount := 1 to Len(aColsOri)
		    	// numero de parcelas, valor , tipo de parcela, Fixa data de vencimento, Data de vencimento, Tipo de Sistema, TAXA anual , indice
		    	// for diferente do original
		    	nPos := aScan( aColsLJT ,{|aColuna| !aColuna[len(oGetCVnd:aHeader)+1] .AND. ;
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
			M->CJ_CONDPAG := GetMV("MV_GMCPAG")
		EndIf
		
		aGEMCVnd := {M->CJ_CONDPAG ,oGetCVnd:aHeader ,oGetCVnd:aCols }
		
	EndIf
	
Return( lContinua )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMXGRA415บAutor  ณReynaldo Miyashita  บ Data ณ  30.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava a condicao de venda "customizada" pro Orcamento       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA415.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMXGRA415()

Local nOpcX      := PARAMIXB[1] // nOpcX
Local cNumOrc    := PARAMIXB[2]	// SCJ->CJ_NUM
Local cCondPag   := PARAMIXB[3] // SCJ->CJ_CONDPAG
Local nX,nY,nPos
Local nUsado     := 0
Local aHeadLJT   := {}
Local aColsLJT   := {}
Local aArea	     := {}

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return .T.
EndIf

aArea	     := GetArea()

If Type("aGEMCVnd") == "U"
	PRIVATE aGEMCVnd :={"",{},{}}
EndIf

If aGEMCVnd[1] == "" .AND. len(aGEMCVnd[2]) >0 .AND. len(aGEMCVnd[3]) >0
	A415LJTLoad( cNumORC ,cCondPag ,d1Venc ,nVlrTotal ,@aGEMCVnd )
EndIf
	
aHeadLJT := aClone(aGEMCVnd[2])
aColsLJT := aClone(aGEMCVnd[3])

nUsado := Len(aHeadLJT)

dbSelectArea("LJT")
LJT->(dbSetOrder(1)) // LJT_FILIAL+LJT_NUM+LJT_ITEM

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ1 - Inclusao de um orcamento                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2 - Alteracao de um orcamento                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcx==1 .OR. nOpcx==2
	// se for uma condicao de pagamento "personalizado"              
	If (cCondPag == GetMV("MV_GMCPAG")) .OR. (ExecTemplate("GMCondPagto",.F.,.F.,{cCondPag,} ))
		If len(aColsLJT) > 0
			// exclui todos os itens da condicao de venda do orcamento
			If LJT->(MSSeek(xFilial("LJT")+cNumOrc))
				While !Eof() .And. xFilial("LJT")+cNumOrc == LJT->LJT_FILIAL+LJT->LJT_NUM
					RecLock("LJT",.F.)
						LJT->(dbDelete())
					MsUnLock()
					LJT->(dbSkip())
				EndDo
			EndIf
			
			For nX := 1 To Len(aColsLJT)
				// se o item nao foi deletado 
				If !(aColsLJT[nX,nUsado+1])
					RecLock("LJT",.T.)
					For nY := 1 to fCount()
						nPos := aScan( aHeadLJT ,{|aHeader|alltrim(aHeader[2])==alltrim(FieldName(nY)) })
						If nPos >0 
							LJT->(FieldPut(nY ,aColsLJT[nX][nPos]))
						EndIf
					Next nY
					LJT->LJT_FILIAL := xFilial("LJT")
					LJT->LJT_NUM    := cNumOrc
					MsUnLock()
				EndIf
			Next nX
		EndIf
	Else    
		// exclui todos os itens da condicao de venda do orcamento
		If LJT->(MSSeek(xFilial("LJT")+cNumOrc))
			While !Eof() .And. xFilial("LJT")+cNumOrc == LJT->LJT_FILIAL+LJT->LJT_NUM
				RecLock("LJT",.F.)
				LJT->(dbDelete())
				MsUnLock()
				LJT->(DbSkip())
			EndDo
		EndIf
	EndIf
	
	aGEMCVnd := {"",{},{}}
	
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ3 - Exclusao de um orcamento                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcx==3
	// exclui todos os itens da condicao de venda do orcamento
	If LJT->(MSSeek(xFilial("LJT")+cNumOrc))
		While !Eof() .And. xFilial("LJT")+cNumOrc == LJT->LJT_FILIAL+LJT->LJT_NUM
			RecLock("LJT",.F.)
			LJT->(dbDelete())
			MsUnLock()
			LJT->(DbSkip())
		EndDo
	EndIf
EndIf
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA415LJTLoaบAutor  ณReynalo Miyashita   บ Data ณ  31.07.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os dados da condicao de venda conforme a condicao  บฑฑ
ฑฑบ          ณ de pagamento informado no orcamento.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A415LJTLoad( cNumORC ,cCondPag ,d1Venc ,nVlrTotal ,aConjLJT )
Local aHeadLJT     := {}
Local aColsLJT     := {}
Local nPos_TPSIST  := 0
Local nPos_FIXVNC  := 0
Local nPos_VALOR   := 0
Local nPos_PERCLT  := 0
Local nCOL_CODEMPR := 0
Local nY           := 0
Local nRecno       := 0
Local aArea        := GetArea()

DEFAULT cCondPag  := ""
DEFAULT d1Venc    := stod("")
DEFAULT nVlrTotal := 0
DEFAULT aConjLJT  := {"",{},{}}

	If Len(aConjLJT) == 3
		If aConjLJT[1] <> cCondPag
			aConjLJT[1] := cCondPag
			aConjLJT[2] := {}
			aConjLJT[3] := {}
		EndIf
	Else
		aConjLJT  := {"",{},{}}
	EndIf

	aHeadLJT := aConjLJT[2]
	aColsLJT := aConjLJT[3]
	
	// aheader da SC5 criada na MATA410.PRX, buscar a coluna do empreendimento
	If Type("aHeader") == "A"
		If (nCOL_CODEMPR := aScan( aHeader ,{|aDefCol| aDefCol[2] == "CK_CODEMPR"} ) )>0
			nRecno := TMP1->(Recno())
			TMP1->(dbGotop())
			// aCols da SC5 criada na MATA410.PRX, buscar o valor na coluna do empreendimento
			While TMP1->(!Eof())
				If ! Empty(TMP1->CK_CODEMPR)
					dbSelectArea("LIQ")
					dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
					If dbSeek(xFilial("LIQ")+TMP1->CK_CODEMPR)
						dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
					EndIf
					Exit
				EndIf
				TMP1->(dbSkip())
			EndDo
			TMP1->(dbGoto(nRecno))
		EndIf
	EndIf
	
	If len(aHeadLJT)==0
		// monta o aHeadLJT
		aHeadLJT := aClone(TableHeader("LJT"))
		aEval( aHeadLJT ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
		nY := aScan( aHeadLJT ,{|aCampo| alltrim(aCampo[2])=="LJT_PERCLT"})
		If nY > 0
			If Empty(aHeadLJT[nY][6])
				aHeadLJT[nY][6] := "t_GMMA415Perc()"
			Else
				aHeadLJT[nY][6] := aHeadLJT[nY][6] + " .AND. t_GMMA415Perc()"
			EndIf
		EndIf
		
		nY := aScan( aHeadLJT ,{|aCampo| alltrim(aCampo[2])=="LJT_VALOR"})
		If nY > 0
			If Empty(aHeadLJT[nY][6])
				aHeadLJT[nY][6] := "t_GMMA415Perc()"
			Else
				aHeadLJT[nY][6] := aHeadLJT[nY][6] + " .AND. t_GMMA415Perc()"
			EndIf
		EndIf
		
		If (nY := aScan( aHeadLJT ,{|aCampo| alltrim(aCampo[2])=="LJT_TIPPAR"})) > 0
			If Empty(aHeadLJT[nY][6])
				aHeadLJT[nY][6] := "t_GEMOrcJur()"
			Else
				aHeadLJT[nY][6] := aHeadLJT[nY][6] + " .AND. t_GEMOrcJur()"
			EndIf
		EndIf

	EndIf
	                   
	nUsado := Len(aHeadLJT)
	
	If Len(aColsLJT) == 0 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz a montagem do aColsLJT                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("LJT")
		LJT->(dbSetOrder(1)) // LJT_FILIAL+LJT_NUM+LJT_ITEM
		dbSeek(xFilial("LJT")+cNumORC)
		While !Eof() .And. LJT->LJT_FILIAL+LJT->LJT_NUM==xFilial("LJT")+cNumORC
			aAdd(aColsLJT,Array(nUsado+1))
			For nY := 1 to nUsado
				If ( aHeadLJT[ny][10] != "V")
					aColsLJT[Len(aColsLJT)][nY] := FieldGet(FieldPos(aHeadLJT[nY][2]))
				Else
					aColsLJT[Len(aColsLJT)][nY] := CriaVar(aHeadLJT[nY][2])
				EndIf
			Next nY

			If (nY := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_VALOR" } )) >0
				nPos_PERCLT := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_PERCLT" } ) 
				If nPos_PERCLT > 0
					aColsLJT[Len(aColsLJT)][nPos_PERCLT] := round((aColsLJT[Len(aColsLJT)][nY]/nVlrTotal)*100 ,aHeadLJT[nPos_PERCLT][5] )
				Endif
			EndIf
			
			If (nY := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_1VENC" } )) >0
				nPos_FIXVNC := aScan( aHeadLJT ,{|x|x[2]=="LJT_FIXVNC" })
				If nPos_FIXVNC > 0 .and. aHeadLJT[nPos_FIXVNC][2] == "2"
					aColsLJN[Len(aColsLJT)][nY] := d1Venc
				Endif
			EndIf
			
			If (nY := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_JURINI" } )) >0
				If (nPos_TPSIST := aScan( aHeadLJT ,{|x| x[2] == "LJT_TPSIST" } ) ) > 0
					If Empty(aColsLJT[Len(aColsLJT)][nY]);
					   .AND. aColsLJT[Len(aColsLJT)][nPos_TPSIST] <> "4"
					 	aColsLJT[Len(aColsLJT)][nY]:= t_GMIniJur(dHabite)
					EndIf
				Endif
			EndIf
			
			aColsLJT[Len(aColsLJT)][nUsado+1] := .F.
			
			dbSelectArea("LJT")
			dbSkip()
		EndDo
		
		//
		// Se continuar vazio, entao eh um processo de incluaso de orcamento.
		// caso exista uma condicao de venda conforme a codigo da condicao de pagamento 
		// alimenta o aColsLJT.
		//
		If Len(aColsLJT) == 0 .AND. cCondPag != GetMV("MV_GMCPAG")
			// condicao de pagamento
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
			If dbSeek(xFilial("SE4")+cCondPag)
				// condicao de venda - cabecalho
				dbSelectArea("LIR")
				LIR->(dbSetOrder(1)) // LIR_FILIAL+LIR_CODCND
				If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Faz a montagem do aColsLJT                                   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea("LIS")
					LIS->(dbSetOrder(1)) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
					dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
					While !Eof() .And. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
						aAdd(aColsLJT,Array(nUsado+1))
						For nY := 1 to nUsado
							If FieldPos("LIS"+substr(aHeadLJT[ny][2],4)) >0 
							//	If ( aHeadLJT[ny][10] != "V")
									aColsLJT[Len(aColsLJT)][nY] := FieldGet(FieldPos("LIS"+substr(aHeadLJT[nY][2],4)))
							//	Else
					//				aColsLJT[Len(aColsLJT)][nY] := CriaVar(aHeadLJT[ny][2])
							//	EndIf
							Else
					  			aColsLJT[Len(aColsLJT)][nY] := CriaVar(aHeadLJT[ny][2])
							EndIf
							
							If aHeadLJT[nY][2]=="LJT_PERCLT"
								nPos_VALOR := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_VALOR" } ) 
								If nPos_VALOR > 0
									aColsLJT[Len(aColsLJT)][nPos_VALOR] := round(nVlrTotal*(aColsLJT[Len(aColsLJT)][nY]/100) ,aHeadLJT[nPos_VALOR][5] )
								Endif
							EndIf
							
							If aHeadLJT[nY][2]=="LJT_FIXVNC" 
								aColsLJT[Len(aColsLJT)][nY] := "2"
	        				EndIf

							If aHeadLJT[nY][2]=="LJT_1VENC" 
								nPos_FIXVNC := aScan( aHeadLJT ,{|x|x[2]=="LJT_FIXVNC" })
								If nPos_FIXVNC > 0 .and. aColsLJT[Len(aColsLJT)][nPos_FIXVNC] == "2"
									aColsLJT[Len(aColsLJT)][nY] := d1Venc
								Endif
	        				EndIf
	        				
							If aHeadLJT[nY][2]=="LJT_JURINI"
							//If (nY := aScan( aHeadLJT ,{|x|x[2] == "LJT_JURINI" } )) >0
								nPos_TPSIST := aScan( aHeadLJT ,{|x| x[2] == "LJT_TPSIST" })
									If (nPos_TPSIST > 0) .AND. (aColsLJT[Len(aColsLJT)][nPos_TPSIST] <> "4")
									 	aColsLJT[Len(aColsLJT)][nY]:= t_GMIniJur(dHabite)
									EndIf
							//	Endif
							EndIf       
							
						Next nY
						aColsLJT[Len(aColsLJT)][nUsado+1] := .F.
						dbSelectArea("LIS")
						dbSkip()
					EndDo
		        EndIf
			EndIf // cond pagto
		EndIf // len(aColsLJT) == 0
	//
	// atualiza o valor parcelado dos itens
	//
	Else
		nPos_VALOR := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_VALOR" } ) 
		nPos_PERCLT := aScan( aHeadLJT ,{|aCol| aCol[2] == "LJT_PERCLT" } ) 
		If nPos_Valor > 0 .AND. nPos_PERCLT > 0
			For nY := 1 to Len(aColsLJT)
				// se o item nao foi deletado 
				If !aColsLJT[nY][Len(aHeadLJT)+1]
					// se o item nao foi deletado 
					aColsLJT[nY][nPos_PERCLT] := round( (aColsLJT[nY][nPos_VALOR]/nVlrTotal)*100,aHeadLJT[nPos_PERCLT][5])
				Endif
			Next nY
		EndIf
		If aHeadLJT[nY][2]=="LJT_1VENC" 
			nPos_FIXVNC := aScan( aHeadLJT ,{|x|x[2]=="LJT_FIXVNC" })
			If nPos_FIXVNC > 0 .and. aColsLJT[Len(aColsLJT)][nPos_FIXVNC] == "2"
				aColsLJT[Len(aColsLJT)][nY] := d1Venc
			Endif
		EndIf
	EndIf	// len(aColsLJT) == 0
    
	// Se naum tiver nenhum item
	If Empty(aColsLJT)
		aadd(aColsLJT,Array(nUsado+1))
		For nY := 1 to nUsado
			If Trim(aHeadLJT[nY][2]) == "LJT_ITEM"
				aColsLJT[1][nY] := StrZero(1, TamSX3("LJT_ITEM")[1])
			Else         
				aColsLJT[1][nY] := CriaVar(aHeadLJT[nY][2])
			EndIf
			aColsLJT[1][nUsado+1] := .F.
		Next nY
	Endif
	
	RestArea(aArea)

	//
	// atualiza o array para retorno
	//
	aConjLJT := {cCondPag ,aHeadLJT ,aColsLJT}

Return( aConjLJT )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMXOrcEmpบAutor  ณReynaldo Miyashita  บ Data ณ 30.07.2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valid e Trigger do Campo Codigo do Empreendimento no       บฑฑ
ฑฑบ          ณ orcamento.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Valid do Campo CK_CODEMPR                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMXOrcEmp()
Local lRet	:=.F.
Local aArea := GetArea()

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios
ChkTemplate("LOT")

dbSelectArea("LIQ")
LIQ->(dbSetOrder(1)) // LIQ_FILIAL+LIQ_COD
If LIQ->(dbSeek(xFilial("LIQ")+M->CK_CODEMPR))
	// "LV" - LIVRE
	If LIQ->LIQ_STATUS == "LV"
		M->CK_PRODUTO := LIQ->LIQ_CODPRD
		__readvar := "M->CK_PRODUTO"
	
		lRet:=CheckSX3("CK_PRODUTO",M->CK_PRODUTO)
	
		IF lRet
			TMP1->CK_PRODUTO := M->CK_PRODUTO
		
			//-- Executa Gatilhos
			If ExistTrigger("CK_PRODUTO")
				RunTrigger(1,,,, "CK_PRODUTO")
			EndIf
		Endif
	Else
		Help( " " ,1 ,"EMPRSTAT" ,,STR0016,1)   //"Este Empreendimento nใo pode ser reservado."
		
    EndIf
EndIf

RestArea(aArea)
	
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMORCxPV บAutor  ณReynaldo Miyashita  บ Data ณ 30.07.2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem a condicao de venda do orcamento para a condicao de  บฑฑ
ฑฑบ          ณ venda do pedido.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA416.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMORCxPV()
Local cNumOrc      := PARAMIXB[1]
Local cCondPag     := PARAMIXB[2]
Local nCol         := 0
Local nIt          := 0
Local nPos         := 0
Local nCOL_CODEMPR := 0
Local nPos_FIXVNC  := 0
Local nPos_TPSIST  := 0
Local nY           := 0
Local nCount       := 0
Local nRecno       := 0
Local cCodEmpr     := ""
Local aRetorno     := {}
Local aCVndLJT     := {}
Local aHeadLJN     := {}
Local aColsLJN     := {}
Local aNewCols     := {}
Local aArea		   := {}

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If HasTemplate("LOT")

	aArea := GetArea()
	
	If Type("aGEMCVnd") == "U"
		PRIVATE aGEMCVnd :={"",{},{}}
	EndIf
	
	If Len(aGEMCVnd) <> 3
		aGEMCVnd :={"",{},{}}
	EndIf

	If ExecTemplate("GMCondPagto",.F.,.F.,{cCondPag,} )
	    //carrega os dados da condicao de venda do orcamento
		A415LJTLoad( cNumORC ,cCondPag ,,,@aCVndLJT )
	
		If len(aCVndLJT[2])> 0 .AND. len(aCVndLJT[3])> 0
			// aheader da SC5 criada na MATA416.PRX, buscar a coluna do empreendimento
			If Type("aHeader") == "A"
				If (nCOL_CODEMPR := aScan( aHeader ,{|aDefCol| aDefCol[2] == "CK_CODEMPR"} ) )>0
					nRecno := TMP1->(Recno())
					TMP1->(dbGotop())
					// aCols da SC5 criada na MATA410.PRX, buscar o valor na coluna do empreendimento
					While TMP1->(!Eof())
						If ! Empty(TMP1->CK_CODEMPR)
							dbSelectArea("LIQ")
							dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
							If dbSeek(xFilial("LIQ")+TMP1->CK_CODEMPR)
								dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
							EndIf
							Exit
						EndIf
						TMP1->(dbSkip())
					EndDo
					TMP1->(dbGoto(nRecno))
				EndIf
			EndIf
					// carrega a estrutura da condicao de venda do pedido de venda
			aHeadLJN := aClone(TableHeader("LJN"))
	
			For nCount := 1 To len(aCVndLJT[3])
			
				aAdd( aNewCols ,Array(Len(aHeadLJN)+1) )
				For nY := 1 to Len(aHeadLJN)
					nPosLJT := aScan( aCVndLJT[2],{|aHeader| AllTrim(subStr(aHeader[2],4)) == AllTrim(subStr(aHeadLJN[nY][2],4))} )
	   				If nPosLJT >0 
						aNewCols[Len(aNewCols)][nY] := aCVndLJT[3][nCount][nPosLJT]
					Else
						aNewCols[Len(aNewCols)][nY] := CriaVar(aHeadLJN[nY][2])
					EndIf
					
					If aHeadLJN[nY][2]=="LJN_JURINI"
						If (nPos_TPSIST := aScan( aHeadLJN ,{|x| x[2] == "LJN_TPSIST" } ) ) > 0
							If Empty(aNewCols[Len(aNewCols)][nY]);
							   .AND. aNewCols[Len(aNewCols)][nPos_TPSIST] <> "4"
							 	aNewCols[Len(aNewCols)][nY] := t_GMIniJur(dHabite)
							EndIf
						Endif
					EndIf
					
				Next nY 
				aNewCols[Len(aNewCols)][Len(aHeadLJN)+1] := .F.
			Next nCount 
			
			If len(aNewCols) == 0
				aAdd( aNewCols ,Array(Len(aHeadLJN)+1) )
			EndIf
			          
			aRetorno := {}
			aAdd( aRetorno ,cCondPag )
			aAdd( aRetorno ,aClone(aHeadLJN))
			aAdd( aRetorno ,aClone(aNewCols))
		Else
			aRetorno := aGEMCVnd
		EndIf
	EndIf
	
	RestArea(aArea)
	
Else	
	aRetorno := {}
EndIf

Return( aRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMCPYORC บAutor  ณReynaldo Miyashita  บ Data ณ 02.08.2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Copia a condicao de venda de um orcamento para outro.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA415.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMCPYORC()
Local aRetorno   := PARAMIXB[1]
Local cOldNumOrc := PARAMIXB[2]
Local cCondPag   := PARAMIXB[3]

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( aRetorno )
EndIf

	//
	// Valida se a condicao de pagamento ้ uma condicao de pagamento do template GEM.
	//
	If ExecTemplate("GMCondPagto",.F.,.F.,{cCondPag,} )
    	//carrega os dados da condicao de venda do pedido de venda
		A415LJTLoad( cOldNumOrc ,cCondPag ,,,@aRetorno )
	Endif

Return( aRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMOrcJur  บAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a data do primeiro vencimento conforme a data de    บฑฑ
ฑฑบ          ณ previsao de habite-se.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMOrcJur()
Local nPos_JURINI := 0

	If (nPos_JURINI := aScan( oGetCVnd:aHeader ,{|aCol| alltrim(aCol[2]) == "LJT_JURINI" } ))>0
		oGetCVnd:aCols[n][nPos_JURINI] := iIf( M->LJT_TPSIST <> "4" ,t_GMIniJur(dHabite) ,stod(""))
	EndIf

Return( .T. )
