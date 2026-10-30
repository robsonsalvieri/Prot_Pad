#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt09L := TFont():New("MS LineDraw Regular",09,09,,.F., , , , .T., .F.)
STATIC oFnt09T := TFont():New("MS LineDraw Regular",09,09,,.T., , , , .T., .F.)
STATIC oFnt10N := TFont():New("Arial",10,10,,.T., , , , .T., .F.)
STATIC oFnt11N := TFont():New("Arial",11,11,,.T., , , , .T., .F.)
STATIC oFnt12N := TFont():New("Arial",14,14,,.T., , , , .T., .F.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.F., , , , .T., .F.)
STATIC oFnt14N := TFont():New("Arial",18,18,,.T., , , , .T., .F.)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRBCTP

Relatório do Quadro Conta Tributo Passivo

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRBCTP(lTodosQuadros, lAuto)

	Local cCadastro := "DIOPS - Conta Tributo Passivo"
	Local aResult   := {}
	
    DEFAULT lTodosQuadros := .F.
    DEFAULT lAuto         := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		Private cTitulo   := cCadastro
		Private oReport   := Nil
		Private cRelName := "DIOPS_ConTriPas_"+CriaTrab(Nil,.F.)
		Private nPagina   := 0// Já declarada Private na chamada de todos os quadros

        If !lAuto
    	    Pergunte(cPerg,.F.)            
        EndIf

		oReport := FWMSPrinter():New(cRelName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)

		If lAuto
			oReport:CFILENAME  := cRelName
			oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
		Else
			oReport:Setup()  //Tela de configurações

			If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
				Return ()
			EndIf

		EndIf
	

	Else
		nPagina	:= 0	// Já declarada Private na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDCTP() }, "DIOPS - Conta Tributo Passivo")

    // Se não há dados a apresentar
	If !aResult[1]
        If !lAuto
			MsgAlert('Não há dados a apresentar referente a Conta Tributo Passivo')
        EndIf	
		Return
	EndIf

	cTitulo := "Conta Tributo Passivo"
	PlsRDCab(cTitulo)// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTCTP(aResult[2]) //Recebe Resultado da Query e Monta Relatório

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PRINTCTP

Impressão do Quadro Conta Tributo Passivo

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PRINTCTP(aValores)

	Local lRet    := .T.
	Local nIndLin := 0
	Local nIndCol := 0
	Local aColuna := {{20,100},{100,240},{240,380},{380,520},{520,660},{660,805}}//Posições das Colunas
	Local nVlrIni := 0
	Local nVlrPag := 0
	Local nAtuMon := 0
	Local nSldFin := 0
	CabecItens()

    //Impressão das linhas de valores
	Li := 150
	Lf := 170

	For nIndLin := 1 TO Len(aValores)

		aAux := aValores[nIndLin]
		nVlrIni	+= aValores[nIndLin,3]//Valor Inicio Trimestre
		nVlrPag	+= aValores[nIndLin,4]//Total Pago Trimestre
		nAtuMon	+= aValores[nIndLin,5]//Atualizacao Monetaria
		nSldFin	+= aValores[nIndLin,6]//Saldo Final Trimestre

		For nIndCol := 1 TO Len(aAux)

			If nIndCol <= 2//Ajusta Conta Contábil Passivo, Periodo de Competência
				nTam := 2
			Else
				nTam := 0//Valores numéricos não ajusta
			EndIf
		
			cTexto := GetTexto(aValores[nIndLin,nIndCol])
			oReport:box(Li,aColuna[nIndCol,1],Lf,aColuna[nIndCol,2])
			If nIndCol == 1
				oReport:Say(Li+10,aColuna[nIndCol,1]+nTam,cTexto, oFnt09L)//Alterar a Posicao no acolunas
			ElseIf nIndCol == 2
				oReport:Say(Li+10,aColuna[nIndCol,1]+nTam+40,cTexto, oFnt09L)//Alterar a Posicao no acolunas
			Else
				oReport:Say(Li+10,aColuna[nIndCol,1]+nTam+20,cTexto, oFnt09L)//Alterar a Posicao no acolunas
			EndIf		
		Next nIndCol

		Li += 20
		Lf += 20
		
		If Li >= 580//Quebra de Pagina

			oReport:EndPage()
			PlsRDCab("Conta Tributo Passivo")
			CabecItens()
			Li := 150
			Lf := 170

		EndIf

	Next nIndLin

	//Totais
	For nIndCol := 1 TO Len(aAux)

		If nIndCol == 2
			cTexto := "TOTAL "
		ElseIf nIndCol == 3
			cTexto := GetTexto(nVlrIni)
		ElseIf nIndCol == 4
			cTexto := GetTexto(nVlrPag)
		ElseIf nIndCol == 5
			cTexto := GetTexto(nAtuMon)
		ElseIf nIndCol == 6
			cTexto := GetTexto(nSldFin)
		Else
			cTexto := ""
		EndIf

		If !Empty(cTexto)
			If nIndCol == 2
				oReport:box(Li,aColuna[1,1],Lf,aColuna[nIndCol,2])   
				oReport:Say(Li+10,aColuna[nIndCol,1]+50,cTexto, oFnt09T)
			Else
				oReport:box(Li,aColuna[nIndCol,1],Lf,aColuna[nIndCol,2])   
				oReport:Say(Li+10,aColuna[nIndCol,1]+20,cTexto, oFnt09T)
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
		cTexto := PADL(Transform(cTexto,Moeda),20)
	ElseIf ValType( cTexto ) == "D"
		cTexto := AllTrim(DTOS(cTexto))
		cTexto := Subs(cTexto,7,2) +"/"+ Subs(cTexto,5,2) +"/"+ Subs(cTexto,1,4)
	Else
		cTexto := "undefined"
	EndIf

Return cTexto

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSDCTP

Dados para o Relatório do Quadro Conta Tributo Passivo

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLSDCTP()

	Local nCount	:= 0
	Local cSql 		:= ""
	Local lRet 		:= .T.
	Local aRetCTP	:= 	{}

	cSql := "SELECT BUY_CONTA, BUY_DTCOMP, BUY_VLRINI, BUY_VLRPAG, BUY_ATUMON, BUY_SLDFIN "
	cSql += "FROM " + RetSqlName("BUY") + " WHERE BUY_FILIAL = '" + xFilial("BUY") + "' "
	cSql += " AND BUY_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUY_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUY_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BUY_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCTP",.F.,.T.)

	If !TRBCTP->(Eof())

		Do While !TRBCTP->(Eof())

			nCount++
            aAdd(aRetCTP, {TRBCTP->BUY_CONTA,STOD(TRBCTP->BUY_DTCOMP),TRBCTP->BUY_VLRINI,TRBCTP->BUY_VLRPAG,TRBCTP->BUY_ATUMON,TRBCTP->BUY_SLDFIN} )
			TRBCTP->(DbSkip())

		EndDo

	EndIf

	TRBCTP->(DbCloseArea())
	
Return( { nCount>0 , aRetCTP } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetConta

Função que retorna a conta e a descrição a ser impressa no relatorio

@author timoteo.bega
@since 22/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetConta()

	Local cSql := ""
	Local aConta := {"1319","Provisão para Ações Tributárias",0}

	cSql := "SELECT B8A_SALFIN FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += "AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' AND B8A_CONTA = '" + aConta[1] + "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"RETCON",.F.,.T.)

	If !RETCON->(Eof())
		aConta[3] := RETCON->B8A_SALFIN
	EndIf

	RETCON->(DbCloseArea())

Return aConta

Static Function CabecItens()

	//Cabeçalho dos itens
	oReport:box(100, 20, 135, 100)
	oReport:Say(120, 23, "Conta Contábil Passivo", oFnt09C)

    oReport:box(100, 100, 135, 240)
	oReport:Say(120, 127, "Período de Competência", oFnt09C)

    oReport:box(100, 240, 135, 380)
	oReport:Say(120, 273, "Valor Início Trimestre ", oFnt09C)

    oReport:box(100, 380, 135, 520)
	oReport:Say(120, 415, "Total Pago no Trimestre", oFnt09C)

    oReport:box(100, 520, 135, 660)
	oReport:Say(120, 555, "Atualização Monetária", oFnt09C)

    oReport:box(100, 660, 135, 805)
	oReport:Say(120, 695, "Saldo Final Trimestre", oFnt09C)

Return
