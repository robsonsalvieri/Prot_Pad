#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999.99"

STATIC oFnt09L 		:= TFont():New("MS LineDraw Regular",08,08,,.F., , , , .T., .F.)
STATIC oFnt09T 		:= TFont():New("MS LineDraw Regular",08,08,,.T., , , , .T., .F.)
STATIC oFnt09C 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRBCCC

Relatório do Quadro Conta Corrente Cooperado

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRBCCC(lTodosQuadros)
	Local cCadastro         := "DIOPS - Conta Corrente Cooperado"
	Local aResult           := {}
	Default lTodosQuadros   := .F.

	If !lTodosQuadros
		Private cPerg       := "DIOPSINT"
		Private cTitulo     := cCadastro
		Private oReport     := Nil
		Private cFileName   := "DIOPS_ConCorCoo_"+CriaTrab(Nil,.F.)
		Private nPagina     := 0// Já declarada Private na chamada de todos os quadros

		Pergunte(cPerg,.F.)

		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.F.,Nil,.T.,Nil,@oReport,Nil,Nil,.F.,.F.,.T.)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)
		oReport:Setup()  //Tela de configurações
		If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ()
		EndIf

	Else
		nPagina	:= 0	// Já declarada Private na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDCCC() }, "DIOPS - Conta Corrente Cooperado")

    // Se não há dados a apresentar
	If !aResult[1]
		MsgAlert('Não há dados a apresentar referente a Conta Corrente Cooperado')
		Return
	EndIf

	cTitulo := "Conta Corrente Cooperado"
	PlsRDCab(cTitulo)// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTCCC(aResult[2]) //Recebe Resultado da Query e Monta Relatório

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PRINTCCC

Impressão do Quadro Conta Corrente Cooperado

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PRINTCCC(aValores)
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
	Local lRet		:= .T.
	Local nIndLin	:= 0
	Local nIndCol	:= 0
	Local aColuna   := {{02,30},{30,160},{160,210},{210,260},{260,300},{300,376},{376,452},{452,528},{528,568},{568,644},{644,684},{684,760},{760,836}}//Posições das Colunas
	Local nVlrFin	:= 0
	Local nVlrPag	:= 0
	Local nSldIni	:= 0
	Local nVlPgTr	:= 0
	Local nAtuMon	:= 0
	Local nSldFin	:= 0
	
	CabecItens()

    //Impressão das linhas de valores
	Li := 150
	Lf := 170

	For nIndLin := 1 TO Len(aValores)

		aAux := aValores[nIndLin]
		nVlrFin	+= aValores[nIndLin,6]//Valor Total Financiado 
		nVlrPag	+= aValores[nIndLin,7]//Valor Total Pago
		nSldIni	+= aValores[nIndLin,8]//Saldo Início Trimestre
		nVlPgTr	+= aValores[nIndLin,10]//Valor Pago no Trimestre
		nAtuMon	+= aValores[nIndLin,12]//Atualização Monetária
		nSldFin	+= aValores[nIndLin,13]//Saldo Final Trimestre

		For nIndCol := 1 TO Len(aAux)

			If nIndCol >= 1 .And. nIndCol <= 4//Ajusta Tipo, Denominação, Periodo de Competência, Data de Adesão Refis
				nTam := 4
			ElseIf nIndCol == 5 .Or. nIndCol == 9 .Or. nIndCol == 11//Centraliza Valor Total Financiado, Qtde Parcela Devida e Qtde Parcela Paga
				nTam := 12
				cTexto := " "
			Else
				nTam := 5//Valores numéricos ajusto apenas com tamanho 5
			EndIf
		
			cTexto := GetTexto(aValores[nIndLin,nIndCol])
			oReport:box(Li,aColuna[nIndCol,1],Lf,aColuna[nIndCol,2])
			oReport:Say(Li+10,aColuna[nIndCol,1]+nTam,cTexto, oFnt09L)//Alterar a Posicao no acolunas
		
		Next nIndCol

		Li += 20
		Lf += 20
		
		If Li >= 580//Quebra de Pagina

			oReport:EndPage()
			PlsRDCab(cTitulo)
			CabecItens()
			Li := 150
			Lf := 170

		EndIf

	Next nIndLin

	//Totais
	For nIndCol := 1 TO Len(aAux)
		If nIndCol == 5
			cTexto := "TOTAL"
		ElseIf nIndCol == 6
			cTexto := GetTexto(nVlrFin)
		ElseIf nIndCol == 7
			cTexto := GetTexto(nVlrPag)
		ElseIf nIndCol == 8
			cTexto := GetTexto(nSldIni)
		ElseIf nIndCol == 10
			cTexto := GetTexto(nVlPgTr)
		ElseIf nIndCol == 12
			cTexto := GetTexto(nAtuMon)
		ElseIf nIndCol == 13
			cTexto := GetTexto(nSldFin)
		Else
			cTexto := ""
		EndIf

		If !Empty(cTexto) .Or. nIndCol == 9 .Or. nIndCol == 11

			If nIndCol == 5
				oReport:box(Li,aColuna[1,1],Lf,aColuna[nIndCol,2])   
				oReport:Say(Li+10,aColuna[nIndCol,1]-60,cTexto, oFnt09T)
			Else
				If nIndCol == 9 .Or. nIndCol == 11
					oReport:box(Li,aColuna[nIndCol,1],Lf,aColuna[nIndCol,2])   
					oReport:Fillrect({Li+1, aColuna[nIndCol,1]+1, Lf-1, aColuna[nIndCol,2]-1}, oBrush1)
				Else
					oReport:box(Li,aColuna[nIndCol,1],Lf,aColuna[nIndCol,2])   
					oReport:Say(Li+10,aColuna[nIndCol,1]+5,cTexto, oFnt09T)
				EndIf	
			EndIF	
		EndIf		
		
	Next nIndCol
	
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTexto

Retorna o texto formatado a ser impresso na célula do relatório

@author timoteo.bega
@since 21/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetTexto(cTexto)
	Default cTexto	:= ""

	If ValType( cTexto ) == "C"
		cTexto := AllTrim(cTexto)
	ElseIf ValType( cTexto ) == "N"
		cTexto := PADL(Transform(cTexto,Moeda),16)
	ElseIf ValType( cTexto ) == "D"
		cTexto := AllTrim(DTOS(cTexto))
		cTexto := Subs(cTexto,7,2) +"/"+ Subs(cTexto,5,2) +"/"+ Subs(cTexto,1,4)
	Else
		cTexto := "undefined"
	EndIf

Return cTexto

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSDCCC

Dados para o Relatório do Quadro Conta Corrente Cooperado

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLSDCCC()
	Local nCount	:= 0
	Local cSql 		:= ""
	Local lRet 		:= .T.
	Local aRetCCC	:= 	{}

	cSql := "SELECT BUW_TIPO, BUW_DENOMI, BUW_DTCOMP, BUW_DTREFI, BUW_NUMPAR, BUW_VLRFIN, BUW_VLRPAG, BUW_SLDINI, BUW_QTPAIN, BUW_VLPGTR, BUW_QTPAPG, BUW_ATUMON, BUW_SLDFIN "
	cSql += "FROM " + RetSqlName("BUW") + " WHERE BUW_FILIAL = '" + xFilial("BUW") + "' "
	cSql += " AND BUW_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUW_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUW_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BUW_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCCC",.F.,.T.)

	If !TRBCCC->(Eof())

		Do While !TRBCCC->(Eof())

			nCount++

            aAdd(aRetCCC, {TRBCCC->BUW_TIPO,TRBCCC->BUW_DENOMI,STOD(TRBCCC->BUW_DTCOMP),STOD(TRBCCC->BUW_DTREFI),Str(TRBCCC->BUW_NUMPAR),;
				TRBCCC->BUW_VLRFIN,TRBCCC->BUW_VLRPAG,TRBCCC->BUW_SLDINI,Str(TRBCCC->BUW_QTPAIN),TRBCCC->BUW_VLPGTR,;
				Str(TRBCCC->BUW_QTPAPG),TRBCCC->BUW_ATUMON,TRBCCC->BUW_SLDFIN} )

			TRBCCC->(DbSkip())

		EndDo

	EndIf

	TRBCCC->(DbCloseArea())
	
Return( { nCount>0 , aRetCCC } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CabecItens

Função escreve o cabeçalho dos itens

@author timoteo.bega
@since 22/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CabecItens()

	//Cabeçalho dos itens
	oReport:box(100, 02, 135, 30)
	oReport:Say(120, 08, "Tipo", oFnt09C)

    oReport:box(100, 30, 135, 160)
	oReport:Say(120, 68, "Denominação", oFnt09C)

    oReport:box(100, 160, 135, 210)
	oReport:Say(110, 162, "Período de", oFnt09C)
	oReport:Say(120, 160, "Competência", oFnt09C)

    oReport:box(100, 210, 135, 260)
	oReport:Say(110, 212, "Data Adesão", oFnt09C)
	oReport:Say(120, 215, "   Refis   ", oFnt09C)

    oReport:box(100, 260, 135, 300)
	oReport:Say(110, 264, " Número ", oFnt09C)
	oReport:Say(120, 265, "Total de", oFnt09C)
	oReport:Say(130, 265, "Parcelas", oFnt09C)

    oReport:box(100, 300, 135, 376)                        
	oReport:Say(110, 315, "  Valor   ", oFnt09C)
	oReport:Say(120, 315, "  Total   ", oFnt09C)
	oReport:Say(130, 313, "Financiado", oFnt09C)

    oReport:box(100, 376, 135, 452)   
	oReport:Say(110, 400, "Valor", oFnt09C)
	oReport:Say(120, 400, "Total", oFnt09C)
	oReport:Say(130, 400, "Pago", oFnt09C)

    oReport:box(100, 452, 135, 528)  
	oReport:Say(110, 473, "  Saldo  ", oFnt09C)
	oReport:Say(120, 473, "  Início ", oFnt09C)
	oReport:Say(130, 473, "Trimestre", oFnt09C)  

    oReport:box(100, 528, 135, 568) 
	oReport:Say(110, 529, "Qt.Parcel.", oFnt09C)
	oReport:Say(120, 529, "  Devidas  ", oFnt09C)
	oReport:Say(130, 529, "Início Trim", oFnt09C)

    oReport:box(100, 568, 135, 644)   
	oReport:Say(110, 590, "  Valor  ", oFnt09C)
	oReport:Say(120, 590, " Pago no ", oFnt09C)
	oReport:Say(130, 590, "Trimestre", oFnt09C)

    oReport:box(100, 644, 135, 684) 
	oReport:Say(110, 645, "Qt.Parcel.", oFnt09C)
	oReport:Say(120, 645, " Pagas no  ", oFnt09C)
	oReport:Say(130, 645, " Trimestre ", oFnt09C)

    oReport:box(100, 684, 135, 760)  
	oReport:Say(110, 700, "Atualização", oFnt09C)
	oReport:Say(120, 700, " Monetária ", oFnt09C)

    oReport:box(100, 760, 135, 836) 
	oReport:Say(110, 779, "Saldo Final", oFnt09C)
	oReport:Say(120, 780, " Trimestre ", oFnt09C)


Return
