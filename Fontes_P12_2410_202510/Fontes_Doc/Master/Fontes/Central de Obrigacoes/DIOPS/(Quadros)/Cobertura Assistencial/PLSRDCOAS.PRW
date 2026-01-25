#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7   5
#Define __NTAM8   9
#Define __NTAM9   7
#Define __NTAM10 30
#Define __NTAM11  8
#Define Moeda "@E 9,999,999,999,999.99"

#Define PRODUTO    1
#Define ORIGEM     2
#Define VLRCONSU   3
#Define VLREXAME   4
#Define VLRTERAP   5
#Define VLRINTERN  6
#Define VLROUTROS  7
#Define VLRDEMAIS  8
#Define REDEPROP  '0'
#Define REDECONT  '1'
#Define REEMBOLS  '2'
#Define INTERCAM  '3'
#Define CORRESP   '6'

STATIC oFnt10C := TFont():New("Arial",10,10,,.F., , , , .t., .f.)
STATIC oFnt10N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C := TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12L := TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt12N := TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",14,14,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDCOAS³

Geração de arquivo PDF. DIOPS - Cobertura Assitencial
@return oModel	objeto model criado

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDCOAS(lTodosQuadros,lAuto)

	Local cCadastro := "DIOPS - Cobertura Assistencial"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cFileName := "DIOPS_Cobertura_Assistencial_" + CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		If !lAuto
			Pergunte(cPerg,.F.)
		EndIf

		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)
		If lAuto
			oReport:cPathPDF := "c:\"
		Else
			oReport:Setup()  //Tela de configurações

			If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
				Return ()
			EndIf

		EndIf

	Else
		nPagina	:= 0	// Já declarada PRIVATE na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDCOAS() }, "DIOPS - Cobertura Assistencial")

	// Se não há dados a apresentar
	lRet := aResult[1]
	If lRet
		cTitulo 	:= "Cobertura Assistencial"
		PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
		lRet := PRINTCOAS(aResult[2]) //Recebe Resultado da Query e Monta Relatório 
		If !lTodosQuadros .and. lRet
			oReport:EndPage()
			oReport:Print()
		EndIf
	Else
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Cobertura Assistencial')
		EndIf	
	EndIf 
	
Return 

Static Function PRINTCOAS(aValores)

	Local lRet		:= .T.
	Local nI		:= 1
	Local nLinha	:= 105
	Local nTotCon	:= 0
	Local nTotExa	:= 0
	Local nTotTer	:= 0
	Local nTotInt	:= 0
	Local nTotOut	:= 0
	Local nTotDem	:= 0
	Local nTotLin	:= 0
	Local nRegAtual	:= 1
	Local nRegMax	:= 21
	Local cLastProd	:= ''
	Local aOrigem	:= { 'Rede Própria', 'Rede Contratada', 'Reembolso', 'Intercâmbio Eventual', '' , '' ,'Corresponsabilidade Cedida' }  
	Local nFor      := 0

	Cabec1(@nLinha, @cLastProd, aValores, nI)

	For nI := 1 to Len( aValores )

		If aValores[nI,PRODUTO] <> cLastProd .and. nRegAtual + 7 > nRegMax
			oReport:EndPage()
			PlsRDCab("Cobertura Assistencial")		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			nRegAtual := 1
			Cabec1(@nLinha, @cLastProd, aValores, nI, .F.)
		EndIf
		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab("Cobertura Assistencial")		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			nRegAtual := 1
			Cabec1(@nLinha, @cLastProd, aValores, nI)
		EndIf

		If 	aValores[nI,PRODUTO] <> cLastProd
			Cabec1(@nLinha, @cLastProd, aValores, nI, .F.)
		EndIf

		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab("Cobertura Assistencial")		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			nRegAtual := 1
			Cabec1(@nLinha, @cLastProd, aValores, nI)
		EndIf

		// Se chegou em Corresponsabilidade cedida, emite o total por Produto e não é somado nos totais
		If ( aValores[nI,PRODUTO] <> 'CRAS' .AND. aValores[nI,ORIGEM] == CORRESP)
			oReport:Say(nLinha, 023, 'TOTAL', oFnt12C)		// 
			cProd:= Alltrim(aValores[nI,PRODUTO])
			nTotCon := 0
			nTotExa := 0
			nTotTer := 0
			nTotInt := 0
			nTotOut := 0
			nTotDem := 0    

			For nFor:=1 to Len(aValores)  
				If Alltrim(aValores[nFor,1]) == cProd .And. aValores[nFor,ORIGEM] <> CORRESP
					nTotCon	+= aValores[nFor,VLRCONSU]
					nTotExa	+= aValores[nFor,VLREXAME]
					nTotTer += aValores[nFor,VLRTERAP]
					nTotInt += aValores[nFor,VLRINTERN]
					nTotOut += aValores[nFor,VLROUTROS]
					nTotDem += aValores[nFor,VLRDEMAIS]
				EndIf	
			Next

			oReport:Say(nLinha, 157, PadL(Transform(nTotCon, Moeda),20), oFnt12L)		// "Consulta Médica"
			oReport:Say(nLinha, 249, PadL(Transform(nTotExa, Moeda),20), oFnt12L)		// "Exames"
			oReport:Say(nLinha, 341, PadL(Transform(nTotTer, Moeda),20), oFnt12L)		// "Terapias"
			oReport:Say(nLinha, 433, PadL(Transform(nTotInt, Moeda),20), oFnt12L)		// "Internações"
			oReport:Say(nLinha, 525, PadL(Transform(nTotOut, Moeda),20), oFnt12L)		// "Outros Atend."
			oReport:Say(nLinha, 617, PadL(Transform(nTotDem, Moeda),20), oFnt12L)		// "Demais Despesas"
			nTotLin := nTotCon + nTotExa + nTotTer + nTotInt + nTotOut + nTotDem
			oReport:Say(nLinha, 709, PadL(Transform(nTotLin, Moeda),20), oFnt12L)		// "TOTAL"	
			nLinha += 15

			// Zera Variáveis para a próxima totalização por Produto
			
			nTotCon	:= 0
			nTotExa	:= 0
			nTotTer := 0
			nTotInt := 0
			nTotOut := 0
			nTotDem := 0
		Else
			nTotCon	+= aValores[nI,VLRCONSU]
			nTotExa	+= aValores[nI,VLREXAME]
			nTotTer += aValores[nI,VLRTERAP]
			nTotInt += aValores[nI,VLRINTERN]
			nTotOut += aValores[nI,VLROUTROS]
			nTotDem += aValores[nI,VLRDEMAIS]
		EndIf

		If aValores[nI,PRODUTO] <> 'CRAS' .OR. aValores[nI,ORIGEM] <> CORRESP
		
			oReport:Say(nLinha, 023, aOrigem[Val(aValores[nI,ORIGEM])+1], oFnt12C)
			oReport:Say(nLinha, 157, PadL(Transform(aValores[nI,VLRCONSU], Moeda),20), oFnt12L)
			oReport:Say(nLinha, 249, PadL(Transform(aValores[nI,VLREXAME], Moeda),20), oFnt12L)
			oReport:Say(nLinha, 341, PadL(Transform(aValores[nI,VLRTERAP], Moeda),20), oFnt12L)
			oReport:Say(nLinha, 433, PadL(Transform(aValores[nI,VLRINTERN], Moeda),20), oFnt12L)
			oReport:Say(nLinha, 525, PadL(Transform(aValores[nI,VLROUTROS], Moeda),20), oFnt12L)
			oReport:Say(nLinha, 617, PadL(Transform(aValores[nI,VLRDEMAIS], Moeda),20), oFnt12L)

			nTotLin := aValores[nI,VLRCONSU]+aValores[nI,VLREXAME]+aValores[nI,VLRTERAP]+aValores[nI,VLRINTERN]+aValores[nI,VLROUTROS]+aValores[nI,VLRDEMAIS]
			oReport:Say(nLinha, 709, PadL(Transform(nTotLin, Moeda),20), oFnt12L)
		
		EndIf
		
			If ( aValores[nI,PRODUTO] == 'CRAS' .AND. aValores[nI,ORIGEM] == INTERCAM)

				nLinha += 15
				oReport:Say(nLinha, 023, 'TOTAL', oFnt12C)		//  
				oReport:Say(nLinha, 157, PadL(Transform(nTotCon, Moeda),20), oFnt12L)		// "Consulta Médica"
				oReport:Say(nLinha, 249, PadL(Transform(nTotExa, Moeda),20), oFnt12L)		// "Exames"
				oReport:Say(nLinha, 341, PadL(Transform(nTotTer, Moeda),20), oFnt12L)		// "Terapias"
				oReport:Say(nLinha, 433, PadL(Transform(nTotInt, Moeda),20), oFnt12L)		// "Internações"
				oReport:Say(nLinha, 525, PadL(Transform(nTotOut, Moeda),20), oFnt12L)		// "Outros Atend."
				oReport:Say(nLinha, 617, PadL(Transform(nTotDem, Moeda),20), oFnt12L)		// "Demais Despesas"

				nTotLin := nTotCon + nTotExa + nTotTer + nTotInt + nTotOut + nTotDem

				oReport:Say(nLinha, 709, PadL(Transform(nTotLin, Moeda),20), oFnt12L)		// "TOTAL"	
				nLinha += 15	
				// Zera Variáveis para a próxima totalização por Produto
				nTotCon	:= 0
				nTotExa	:= 0
				nTotTer := 0
				nTotInt := 0
				nTotOut := 0
				nTotDem := 0
			EndIf

			nLinha += 15	
			nRegAtual++

	Next

Return lRet

Static Function PLSDCOAS()

	Local nCount   := 0
	Local aRetCOAS := 	{}
	Local cSql     := ""
	Local lRet     := .T.

	cSql := " SELECT "
	cSql += " 	B8I_PLANO, B8I_ORIGEM, B8I_CONSUL,"
	cSql += " 	B8I_EXAMES, B8I_TERAPI, B8I_INTERN, "
	cSql += " 	B8I_OUTROS, B8I_DEMAIS, "
	cSql += " 	CASE
	cSql += " 		WHEN B8I_PLANO = 'IFAL' THEN 1 "
	cSql += " 		WHEN B8I_PLANO = 'IFPL' THEN 2 "
	cSql += " 		WHEN B8I_PLANO = 'PLAL' THEN 3 "
	cSql += " 		WHEN B8I_PLANO = 'PLAP' THEN 4 "
	cSql += " 		WHEN B8I_PLANO = 'PCEA' THEN 5 "
	cSql += " 		WHEN B8I_PLANO = 'PCEL' THEN 6 "
	cSql += " 		WHEN B8I_PLANO = 'CRAS' THEN 7 "
	cSql += " 	END AS ORDEM "
	cSql += " FROM " + RetSqlName("B8I")
	cSql += " WHERE "
	cSql += " 	B8I_FILIAL = '" + xFilial("B8I") + "' " 
	cSql += " 	AND B8I_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " 	AND B8I_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " 	AND B8I_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " 	AND B8I_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY "
	cSql += " 	ORDEM, B8I_ORIGEM " 	
	
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOA",.F.,.T.)
	TcSetField("TRBCOA", "B8I_CONSUL",  "N", 16, 2 )
	TcSetField("TRBCOA", "B8I_EXAMES",  "N", 16, 2 )
	TcSetField("TRBCOA", "B8I_TERAPI",  "N", 16, 2 )
	TcSetField("TRBCOA", "B8I_INTERN",  "N", 16, 2 )
	TcSetField("TRBCOA", "B8I_OUTROS",  "N", 16, 2 )
	TcSetField("TRBCOA", "B8I_DEMAIS",  "N", 16, 2 )

	If !TRBCOA->(Eof())
		TRBCOA->(dbGoTop())
		Do While !TRBCOA->(Eof())
			nCount++
			aAdd( aRetCOAS, { TRBCOA->B8I_PLANO, TRBCOA->B8I_ORIGEM, TRBCOA->B8I_CONSUL, TRBCOA->B8I_EXAMES, TRBCOA->B8I_TERAPI, TRBCOA->B8I_INTERN, TRBCOA->B8I_OUTROS, TRBCOA->B8I_DEMAIS } )
			TRBCOA->(DbSkip())		
		EndDo
	EndIf

	TRBCOA->(DbCloseArea())

Return( { nCount > 0 , aRetCOAS } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cabec1

Função para facilitar a impressão de cabeçalho

@author Roger C
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Cabec1(nLinha, cLastProd, aValores, nI, lCompleto)

	Local cDesc	:= ''
	Default nLinha	:= 105
	Default cLastProd := ''
	Default aValores := { 'IFAL', 'erro' }
	Default nI 	:= 1
	Default lCompleto := .T.
	
	If lCompleto
		oReport:Say(nLinha, 300, "ASSISTÊNCIA MÉDICO-HOSPITALAR", oFnt14N)
		nLinha += 15 
	Else
		nLinha += 15
	EndIf
	
	cLastProd := aValores[nI,PRODUTO]
	Do Case
		Case aValores[nI,PRODUTO] == 'IFAL' 
			cDesc := "Planos Individuais/Familiares antes da Lei"
		Case aValores[nI,PRODUTO] == 'IFPL'
			cDesc := "Planos Individuais/Familiares pós Lei"
		Case aValores[nI,PRODUTO] == 'PLAL'
			cDesc := "Planos Coletivos por Adesão antes da Lei"
		Case aValores[nI,PRODUTO] == 'PLAP'
			cDesc := "Planos Coletivos por Adesão pós Lei"
		Case aValores[nI,PRODUTO] == 'PCEA'
			cDesc := "Planos Coletivos Empresariais antes da Lei"
		Case aValores[nI,PRODUTO] == 'PCEL'
			cDesc := "Planos Coletivos Empresariais pós Lei"		
		Case aValores[nI,PRODUTO] == 'CRAS'
			cDesc := "Corresponsabilidade Assumida"
	EndCase

	oReport:Say(nLinha, 020, cDesc, oFnt14N)
	nLinha += 15 

	oReport:box(nLinha+5, 020, nLinha-10, 160) // Box
	oReport:Say(nLinha, 023, "Origem", oFnt12N)

	oReport:box(nLinha+5, 160, nLinha-10, 252) // Box
	oReport:Say(nLinha, 163, "Consulta Médica", oFnt12N)

	oReport:box(nLinha+5, 252, nLinha-10, 344) // Box
	oReport:Say(nLinha, 255, "Exames", oFnt12N)

	oReport:box(nLinha+5, 344, nLinha-10, 436) // Box
	oReport:Say(nLinha, 347, "Terapias", oFnt12N)

	oReport:box(nLinha+5, 436, nLinha-10, 528) // Box
	oReport:Say(nLinha, 439, "Internações", oFnt12N)

	oReport:box(nLinha+5, 528, nLinha-10, 620) // Box
	oReport:Say(nLinha, 531, "Outros Atend.", oFnt12N)

	oReport:box(nLinha+5, 620, nLinha-10, 712) // Box
	oReport:Say(nLinha, 623, "Demais Despesas", oFnt12N)

	oReport:box(nLinha+5, 712, nLinha-10, 805) // Box
	oReport:Say(nLinha, 715, "TOTAL", oFnt12N)

	nLinha += 15

Return
