#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDAGCN

Relatório do Quadro Agrupamento de Contratos

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDAGCN(lTodosQuadros,lAuto)

	Local aSays      := {}
	Local aButtons   := {}
	Local cCadastro  := "DIOPS - Agrupamento de Contratos"
	Local aResult    := {}
	Local lB8K_PLACC := B8K->(FieldPos("B8K_PLACC") > 0)

	Default lTodosQuadros := .F.
	Default lAuto := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		Private cTitulo   := cCadastro
		Private oReport   := nil
		Private cRelName := "DIOPS_Agrupamento_de_Contratos_"+CriaTrab(NIL,.F.)
		Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		If !lAuto
			Pergunte(cPerg,.F.)
		EndIf

		oReport := FWMSPrinter():New(cRelName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
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
		nPagina	:= 0	// Já declarada PRIVATE na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDAGRP() }, cCadastro)

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Agrupamento de Contratos')		
		EndIf		
		Return
	EndIf 

	lRet := PRINTAGCN(aResult[2], lB8K_PLACC) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf
	
Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTAGCIN

@description Imprime Agrupamento de Contratos
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------
Static Function PRINTAGCN(aValores,lB8K_PLACC)

	Local lRet		:= .T.
	Local nSom		:= 0
	Local nSomLine  := 0
	Local nI		:= 0
	Local nVez		:= 0
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
	Local cTitulo	:= "Receita e Despesa dos Contratos Agreg. ao Agrupamento"
	Local nMemoLin	:= 0  

	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
	nLin := 105
	oReport:box(nLin, 5, nLin+100, 830 ) //Box principal  290 original

	oReport:box(nLin, 185, nLin+100, 508)
	oReport:box(nLin, 508, nLin+100, 830)

	nLin += 20
	oReport:Say(nLin, 280, "Planos Coletivos Adesão", oFnt12N)
	oReport:Say(nLin, 580, "Planos Coletivos por Empresariais", oFnt12N)

	nLin += 15
	oReport:Say(nLin, 012, "Cobertura Assistencial com", oFnt12N)
	oReport:box(nLin, 185,   nLin+100, 293.3)
	oReport:box(nLin, 293.2, nLin+100, 400  )
	oReport:box(nLin, 400,   nLin+100, 508  )
	oReport:box(nLin, 508,   nLin+100, 615  )
	oReport:box(nLin, 615,   nLin+100, 723  )
	oReport:box(nLin, 723,   nLin+100, 830  )

	nLin += 10 
	oReport:Say(nLin, 012, "Preço Pré Estabelecido Pós Lei", oFnt12N) 

	nLin += 15
	oReport:Say(nLin, 195, "Contraprestação", oFnt10c)
	oReport:Say(nLin, 303, "Eventos/Sinistros", oFnt10c)
	oReport:Say(nLin, 410, "Corresponsabilidade", oFnt10c)
	oReport:Say(nLin, 518, "Contraprestação", oFnt10c)
	oReport:Say(nLin, 625, "Eventos/Sinistros", oFnt10c)
	oReport:Say(nLin, 732, "Corresponsabilidade", oFnt10c)

	nLin += 10
	oReport:Say(nLin, 195, "Emitida", oFnt10c)
	oReport:Say(nLin, 303, "Conhecidos", oFnt10c)
	oReport:Say(nLin, 410, "Cedida", oFnt10c)
	oReport:Say(nLin, 518, "Emitida", oFnt10c)
	oReport:Say(nLin, 625, "Conhecidos", oFnt10c)
	oReport:Say(nLin, 732, "Cedida", oFnt10c)

	// Memoria da linha para impressão dos valores
	nMemoLin := nLin

	nLin += 15
	oReport:box(nLin, 05, nLin+25, 830)

	nLin += 13
	oReport:Say(nLin + 3, 8, "Contratos Agregados ao Pool de Risco", oFnt10N)

	nLin += 12 
	oReport:box(nLin, 05, nLin+25, 830)

	nLin += 13
	oReport:Say(nLin + 3, 8, "Demais Contratos", oFnt10N) 

	nLin += 12
	oReport:box(nLin, 05, nLin+25, 830)
	oReport:Fillrect({nLin+1, 06, nLin+24, 829 }, oBrush1)

	nLin += 13	
	oReport:Say(nLin + 3, 8, "TOTAL", oFnt10N) 

	//Line das colunas
	nLin := nMemoLin + 14
	nSom := 0
	For nI := 1 to 6
		oReport:Line(nLin, 185 + nSom, nLin+77, 185 + nSom)
		nSom += 107.5
	Next

	nLin += 3 
	
	//****************************
	//Impressão dos Valores
	//****************************
	nSom := 0
	nSomLine := 13
	nLin += nSomLine

	For nVez := 1 to 3

		if lB8K_PLACC
			For nI := 1 to 6
				If nVez == 1
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI],Moeda), 20), oFnt12L)
					EndIf
				ElseIf nVez==2
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI+6],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI+6],Moeda), 20), oFnt12L)
					EndIf
				Else
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI]+aValores[nI+6],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI]+aValores[nI+6],Moeda), 20), oFnt12L)
					EndIf
				EndIf
				nSom += 108
			Next

			nSom := 0
			nLin -= (nVez + 3)
		
		Else
			For nI := 1 to 4	
				If nVez==1
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI],Moeda), 20), oFnt12L)
					EndIf
				ElseIf nVez==2
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI+4],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI+4],Moeda), 20), oFnt12L)	
					EndIf
				Else
					If nI != 6
						oReport:Say( nLin, 195 + nSom, PADL(Transform(aValores[nI]+aValores[nI+4],Moeda), 20), oFnt12L)
					Else
						oReport:Say( nLin, 193 + nSom, PADL(Transform(aValores[nI]+aValores[nI+4],Moeda), 20), oFnt12L)
					EndIf				
				EndIf
				nSom += 108
			Next

			nSom := 0
			nLin -= (nVez + 3)

		EndIf

		nLin += nSomLine + 17

	Next

Return lRet

Static Function PLSDAGRP(lB8K_PLACC)

	Local nCount   := 0
	Local aRetAgCn := {0,0,0,0,0,0,0,0}
	Local cSql 	   := ""
	Local lRet 	   := .T.
	Local lB8K_PLACC := B8K->(FieldPos("B8K_PLACC") > 0)

	aRetAgCn := {0,0,0,0,0,0,0,0,0,0,0,0}

	cSql := " SELECT B8K_TIPO, B8K_PLACE, B8K_PLAEV, B8K_PCECE, B8K_PCEEV "
	if lB8K_PLACC
		cSql += " ,B8K_PLACC , B8K_PCECC "
	EndIf
	cSql += " FROM " + RetSqlName("B8K")
	cSql += " WHERE B8K_FILIAL = '" + xFilial("B8K") + "' " 
	cSql += " AND B8K_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8K_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8K_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8K_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8K_TIPO " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBAGCN",.F.,.T.)
	TcSetField("TRBAGCN", "B8K_PLACE",  "N", 16, 2 )
	TcSetField("TRBAGCN", "B8K_PLAEV",  "N", 16, 2 )
	TcSetField("TRBAGCN", "B8K_PCECE",  "N", 16, 2 )
	TcSetField("TRBAGCN", "B8K_PCEEV",  "N", 16, 2 )
	if lB8K_PLACC
		TcSetField("TRBAGCN", "B8K_PLACC",  "N", 16, 2 )
		TcSetField("TRBAGCN", "B8K_PCECC",  "N", 16, 2 )
	EndIf

	If !TRBAGCN->(Eof())
		Do While !TRBAGCN->(Eof())
			nCount++		
			If TRBAGCN->B8K_TIPO == '1'
				aRetAgCn[1] += TRBAGCN->B8K_PLACE
				aRetAgCn[2] += TRBAGCN->B8K_PLAEV
				if lB8K_PLACC
					aRetAgCn[3] := TRBAGCN->B8K_PLACC
				EndIf
				aRetAgCn[4] += TRBAGCN->B8K_PCECE
				aRetAgCn[5] += TRBAGCN->B8K_PCEEV
				if lB8K_PLACC
					aRetAgCn[6] := TRBAGCN->B8K_PCECC
				EndIf								
			Else
				aRetAgCn[7] += TRBAGCN->B8K_PLACE
				aRetAgCn[8] += TRBAGCN->B8K_PLAEV
				if lB8K_PLACC
					aRetAgCn[9] := TRBAGCN->B8K_PLACC
				EndIf				
				aRetAgCn[10] += TRBAGCN->B8K_PCECE
				aRetAgCn[11] += TRBAGCN->B8K_PCEEV
				if lB8K_PLACC
					aRetAgCn[12] := TRBAGCN->B8K_PCECC
				EndIf
			EndIf
			TRBAGCN->(DbSkip())		
		EndDo
	EndIf
	TRBAGCN->(DbCloseArea())
	
Return( { nCount > 0 , aRetAgCn } )

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTAGCIN

@description Imprime Agrupamento de Contratos
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------
Static Function GeraQdr(nMeio, qTd, oBrush1, line, nNegativo, oReport)

	Local nQuadros := 1

	DEFAULT nNegativo := 0
	DEFAULT nMeio := 0
	DEFAULT qTd := 0

	nNegativo := nNegativo * 10
	
	For nQuadros := 1 to qTd
		oReport:box(nLin, nMeio - nNegativo, nLin+10, (nMeio+10) - nNegativo)
		nMeio += 10
	Next
	
Return
