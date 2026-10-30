#Include "PROTHEUS.Ch"
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C := TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N := TFont():New("Arial",12,12,,.t., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",12,12,,.t., , , , .t., .f.)
STATIC oFnt11C := TFont():New("MS LineDraw Regular",13,13,,.t., , , , .t., .f.)
STATIC oFnt12C := TFont():New("Arial",14,14,,.f., , , , .t., .f.)
STATIC oFnt12L := TFont():New("MS LineDraw Regular",13,13,,.F., , , , .t., .f.)
STATIC oFnt12N := TFont():New("Arial",14,14,,.t., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.f., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",18,18,,.t., , , , .t., .f.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PLSRDPESL	³ Autor ³ Roger Cangianeli 	³ Data ³ 22.01.18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PROVISÃO DE EVENTOS E SINISTROS A LIQUIDAR - Inicio do processo				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRDPESL(lTodosQuadros,lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - PROVISÃO DE EVENTOS E SINISTROS A LIQUIDAR"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cRelName := "DIOPS_PESL_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

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
		nPagina		:= 0		// Já declarada PRIVATE na chamada de todos os quadros
	EndIf

	Processa( {|| aResult := PLSDPESL(lAuto) }, "DIOPS - Composição do Saldo da Provisão de Eventos/Sinistros a Liquidar")

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a PROVISÃO DE EVENTOS E SINISTROS A LIQUIDAR')
		EndIf
		Return
	EndIf

	cTitulo := "                                              Composição do Saldo da Provisão de Eventos/Sinistros a Liquidar"
	PlsRDCab(cTitulo,160)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTPESL(aResult) //Recebe Resultado da Query e Monta Relatório

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTPESL

@description Imprime PROVISÃO DE EVENTOS E SINISTROS A LIQUIDAR
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------
Static Function PRINTPESL(aValores)

	LOCAL lRet		:= .T.
	Local cData		:= '31/12/'+Strzero(Val(B3D->B3D_ANO)-1, 4, 0)
	Local nLin		:= 125
	Local lNew22    := Val(B3D->B3D_ANO)>=2022
	local nI        := 0

	If !lNew22
		oReport:box(100, 020, 130, 805)	//Box qtd de beneficiários
		oReport:Say(nLin-5, 025, "Quantidade de Beneficiários em "+cData, oFnt10C)	//
		oReport:Say(nLin, 700, Transform(aValores[2][1][1], "@E 999,999,999,999"), oFnt12L)			// Qtde Beneficiarios

		nLin += 75
		oReport:box(158, 020, 300, 415)
		oReport:box(158, 415, 300, 805)
		oReport:box(158, 020, 185, 415)
		oReport:box(158, 020, 208, 415)
		oReport:box(158, 415, 185, 805)	//PESL - Atendimento Assumido por Corresponsabilidade
		oReport:box(185, 020, 300, 250)	 //acerta o box
		oReport:box(185, 415, 300, 650)	 //acerta o box

		oReport:Line(185, 20, 185, 805)
		oReport:Line(208, 20, 208, 805)
		oReport:Line(235, 20, 235, 805)
		oReport:Line(268, 20, 268, 805)

		oReport:Say(171,  120, 'PESL - Atendimento dos Beneficiários', oFnt10N)
		oReport:Say(nLin, 120, 'Vencimento', oFnt10N)
		oReport:Say(nLin, 300,'Saldo Contabilizado', oFnt10N)

		nLin += 30
		oReport:Say(nLin, 025, "Eventos/Sinistros avisados nos últimos 30/60 dias (*)", oFnt10C)
		oReport:Say(nLin, 290, Transform(aValores[2][1][2], Moeda), oFnt12L)

		nLin += 30
		oReport:Say(nLin, 025, "Eventos/Sinistros avisados há mais de 30/60 dias (*)", oFnt10C)
		oReport:Say(nLin, 290, Transform(aValores[2][1][3], Moeda), oFnt12L)

		nLin += 30

		oReport:Say(nLin, 025, "Saldo Total: ", oFnt11N)
		oReport:Say(nLin, 290, Transform(aValores[2][1][2]+aValores[2][1][3], Moeda), oFnt11C)

		nLin := 170
		oReport:Say(171, 495, 'PESL - Atendimento Assumido por Corresponsabilidade', oFnt10N)

		nLin += 30
		oReport:Say(nLin, 690, 'Saldo Contabilizado', oFnt10N)
		oReport:Say(nLin, 495, 'Vencimento', oFnt10N)

		nLin += 30
		oReport:Say(nLin, 420, "Eventos/Sinistros avisados nos últimos 30/60 dias (*)", oFnt10C)
		oReport:Say(nLin, 680, Transform(aValores[2][1][4], Moeda), oFnt12L)

		nLin += 30
		oReport:Say(nLin, 420, "Eventos/Sinistros avisados há mais de 30/60 dias (*)", oFnt10C)
		oReport:Say(nLin, 680, Transform(aValores[2][1][5], Moeda), oFnt12L)

		nLin += 30
		oReport:Say(nLin, 420, Transform(aValores[2][1][4], Moeda), oFnt11C)
		oReport:Say(nLin, 680, Transform(aValores[2][1][4]+aValores[2][1][5], Moeda), oFnt11C)

		nLin += 75
		oReport:Say(nLin+50, 020, "(*) considerar os "+IIf(aValores[2][1][1]>= IIf(B3D->B3D_ANO<'2018',100000,20000),"30","60")+" dias que antecedem a data-base do fechamento do trimestre, inclusive o último dia.", oFnt10C)		//
	Else

		//----------------------------------------

		/*Quadro Pré-Estabelecido*/

		//----------------------------------------

		nLin := 168
		nbox := 130
		nFim := 420
		n620 := 620
		n300 := 300

		oReport:box( 100, 020, 130, 805)
		oReport:box(nbox, 020, n300, nFim)
		oReport:box(nbox, nFim, n300, 805)
		oReport:box(nbox, 020, n300, nFim)
		oReport:box(nbox, 020, n300, nFim)
		oReport:box(nbox, nFim, n300, 805)
		oReport:box(nbox, 020, n300, 230)
		oReport:box(nbox, nFim, n300, n620)

		oReport:Say(120, 025, "Segregação da Provisão de Eventos/Sinistros a Liquidar - Contratos de Preço Preestabelecido", oFnt10C)	//
		oReport:Say(nLin, 100, 'Vencimento', oFnt10N)
		oReport:Say(nLin, n300,'PESL-SUS', oFnt10N)
		nLin += 30
		oReport:Say(nLin, 025, "Eventos/sinistros avisados até 30 dias", oFnt10C)
		oReport:Say(nLin, 290, Transform(aValores[2][1][1], Moeda), oFnt12L)
		nLin += 30
		oReport:Say(nLin, 025, "Eventos/Sinistros avisados de 31 a 60 dias", oFnt10C)
		oReport:Say(nLin, 290, Transform(aValores[2][1][4], Moeda), oFnt12L)
		nLin += 30
		oReport:Say(nLin, 025, "Eventos/Sinistros avisados há mais de 60 dias", oFnt10C)
		oReport:Say(nLin, 290, Transform(aValores[2][1][7], Moeda), oFnt12L)
		nLin += 30
		oReport:Say(nLin, 025, "Saldo Total: ", oFnt11N)
		oReport:Say(nLin, 290, Transform(aValores[2][1][1]+aValores[2][1][4]+aValores[2][1][7], Moeda), oFnt11C)
		nLin := 146
		oReport:Say(nLin, 690, 'PESL-OUTROS', oFnt10N)
		oReport:Say(nLin+20, 650, 'Corresponsabilidade Assumida', oFnt10N)
		oReport:Say(nLin, 495, 'PESL-OUTROS', oFnt10N)
		oReport:Say(nLin+20, 495, 'Carteira Própria', oFnt10N)
		nLin := 198
		oReport:Say(nLin, 495, Transform(aValores[2][1][2], Moeda), oFnt12L)
		oReport:Say(nLin, 680, Transform(aValores[2][1][3], Moeda), oFnt12L)
		nLin += 30
		oReport:Say(nLin, 495, Transform(aValores[2][1][5], Moeda), oFnt12L)
		oReport:Say(nLin, 680, Transform(aValores[2][1][6], Moeda), oFnt12L)
		nLin += 30
		oReport:Say(nLin, 495, Transform(aValores[2][1][8], Moeda), oFnt12L)
		oReport:Say(nLin, 680, Transform(aValores[2][1][9], Moeda), oFnt12L)

		oReport:Say(288, 495, Transform(aValores[2][1][2]+aValores[2][1][5]+aValores[2][1][8], Moeda), oFnt11C)
		oReport:Say(288, 680, Transform(aValores[2][1][3]+aValores[2][1][6]+aValores[2][1][9], Moeda), oFnt11C)


		//----------------------------------------

		/*Quadro Pós-Estabelecido*/

		//----------------------------------------

		nLinP := 373
		nboxP := 335
		nFimP := 420
		n300P := 505

		oReport:box( 305, 020, 335, 805)
		oReport:box(nboxP, 020, n300P, nFimP)
		oReport:box(nboxP, nFimP, n300P, 805)
		oReport:box(nboxP, 020, n300P, nFimP)
		oReport:box(nboxP, 020, n300P, nFimP)
		oReport:box(nboxP, nFimP, n300P, 805)
		oReport:box(nboxP, 020, n300P, 230)
		oReport:box(nboxP, nFimP, n300P, n620)

		oReport:Say(325, 025, "Segregação da Provisão de Eventos/Sinistros a Liquidar - Contratos de Preço Pós-Estabelecido", oFnt10C)	//
		oReport:Say(nLinP, 100, 'Vencimento', oFnt10N)
		oReport:Say(nLinP, 300,'PESL-SUS', oFnt10N)
		nLinP += 30
		oReport:Say(nLinP, 025, "Eventos/sinistros avisados até 30 dias", oFnt10C)
		oReport:Say(nLinP, 290, Transform(aValores[2][2][1], Moeda), oFnt12L)
		nLinP += 30
		oReport:Say(nLinP, 025, "Eventos/Sinistros avisados de 31 a 60 dias", oFnt10C)
		oReport:Say(nLinP, 290, Transform(aValores[2][2][4], Moeda), oFnt12L)
		nLinP += 30
		oReport:Say(nLinP, 025, "Eventos/Sinistros avisados há mais de 60 dias", oFnt10C)
		oReport:Say(nLinP, 290, Transform(aValores[2][2][7], Moeda), oFnt12L)
		nLinP += 30
		oReport:Say(nLinP, 025, "Saldo Total: ", oFnt11N)
		oReport:Say(nLinP, 290, Transform(aValores[2][2][1]+aValores[2][2][4]+aValores[2][2][7], Moeda), oFnt11C)
		nLinP := 350
		oReport:Say(nLinP, 690, 'PESL-OUTROS', oFnt10N)
		oReport:Say(nLinP+20, 650, 'Corresponsabilidade Assumida', oFnt10N)
		oReport:Say(nLinP, 495, 'PESL-OUTROS', oFnt10N)
		oReport:Say(nLinP+20, 495, 'Carteira Própria', oFnt10N)
		nLinP := 402
		oReport:Say(nLinP, 495, Transform(aValores[2][2][2], Moeda), oFnt12L)
		oReport:Say(nLinP, 680, Transform(aValores[2][2][3], Moeda), oFnt12L)
		nLinP += 30
		oReport:Say(nLinP, 495, Transform(aValores[2][2][5], Moeda), oFnt12L)
		oReport:Say(nLinP, 680, Transform(aValores[2][2][6], Moeda), oFnt12L)
		nLinP += 30
		oReport:Say(nLinP, 495, Transform(aValores[2][2][8], Moeda), oFnt12L)
		oReport:Say(nLinP, 680, Transform(aValores[2][2][9], Moeda), oFnt12L)

		oReport:Say(493, 495, Transform(aValores[2][2][2]+aValores[2][2][5]+aValores[2][2][8], Moeda), oFnt11C)
		oReport:Say(493, 680, Transform(aValores[2][2][3]+aValores[2][2][6]+aValores[2][2][9], Moeda), oFnt11C)
		oReport:Line(185, 20, 185, 805)// Pré-Estabelecido
		oReport:Line(208, 20, 208, 805)
		oReport:Line(235, 20, 235, 805)
		oReport:Line(268, 20, 268, 805)

		oReport:Line(390, 20, 390, 805)// Pós-Estabelecido
		oReport:Line(413, 20, 413, 805)
		oReport:Line(440, 20, 440, 805)
		oReport:Line(473, 20, 473, 805)

	EndIf


Return lRet


Static Function PLSDPESL(lAuto)

	Local cSql 		:= ""
	Local lRet 		:= .F.
	Local aResult	:= {}
	Local lNew22    := Val(B3D->B3D_ANO)>=2022
	Local nCnt      := 0

	Default lAuto   := .F.

	If !lNew22
		cSql:=" SELECT B8J_QTDE,B8J_EVULTI,B8J_EVMAIS,B8J_CAULTI,B8J_CAMAIS "
	Else
		cSql:=" SELECT B8J_UMMSUS,B8J_UMCARP,B8J_UMCOAS,B8J_DOMSUS,B8J_DOCARP,B8J_DOCOAS,B8J_TRMSUS,B8J_TRCARP,B8J_TRCOAS,B8J_TIPOES "
	EndIf

	cSql += " FROM " + RetSqlName("B8J")
	cSql += " WHERE B8J_FILIAL = '" + xFilial("B8J") + "' "
	cSql += " AND B8J_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8J_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8J_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8J_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	If lNew22
		cSql += " ORDER BY B8J_TIPOES "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPES",.F.,.T.)
	If !lNew22
		TcSetField("TRBPES", "B8J_QTDE",   "N", 16, 0 )
		TcSetField("TRBPES", "B8J_EVULTI", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_EVMAIS", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_CAULTI", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_CAMAIS", "N", 16, 2 )
	EndIf

	TRBPES->(dbGoTop())
	If !TRBPES->(Eof())
		lRet := .T.
		While !TRBPES->(Eof())
			nCnt ++
			if !lNew22
				aAdd(aResult, { TRBPES->B8J_QTDE , TRBPES->B8J_EVULTI , TRBPES->B8J_EVMAIS , TRBPES->B8J_CAULTI , TRBPES->B8J_CAMAIS } )
			Else

				If TRBPES->B8J_TIPOES == "2" .And. nCnt == 1
					aAdd(aResult,{0,0,0,0,0,0,0,0,0,"1"})
					aAdd(aResult,{TRBPES->B8J_UMMSUS,TRBPES->B8J_UMCARP,TRBPES->B8J_UMCOAS,TRBPES->B8J_DOMSUS,TRBPES->B8J_DOCARP,TRBPES->B8J_DOCOAS,TRBPES->B8J_TRMSUS,TRBPES->B8J_TRCARP,TRBPES->B8J_TRCOAS,TRBPES->B8J_TIPOES})
					exit
				EndIf

				If TRBPES->B8J_TIPOES == "2" .And. nCnt == 2
					aAdd(aResult,{TRBPES->B8J_UMMSUS,TRBPES->B8J_UMCARP,TRBPES->B8J_UMCOAS,TRBPES->B8J_DOMSUS,TRBPES->B8J_DOCARP,TRBPES->B8J_DOCOAS,TRBPES->B8J_TRMSUS,TRBPES->B8J_TRCARP,TRBPES->B8J_TRCOAS,TRBPES->B8J_TIPOES})
				EndIf

				If TRBPES->B8J_TIPOES == "1" .And. nCnt == 1
					aAdd(aResult,{TRBPES->B8J_UMMSUS,TRBPES->B8J_UMCARP,TRBPES->B8J_UMCOAS,TRBPES->B8J_DOMSUS,TRBPES->B8J_DOCARP,TRBPES->B8J_DOCOAS,TRBPES->B8J_TRMSUS,TRBPES->B8J_TRCARP,TRBPES->B8J_TRCOAS,TRBPES->B8J_TIPOES})
				EndIf

			endif
			TRBPES->(dbSkip())
		EndDo
		If Len(aResult) == 1
			aAdd(aResult,{0,0,0,0,0,0,0,0,0,"2"})
		EndIf
	Else
		aResult	:= {0,0,0,0,0}
	EndIf

	TRBPES->(DbCloseArea())

Return( { lRet, aResult } )
