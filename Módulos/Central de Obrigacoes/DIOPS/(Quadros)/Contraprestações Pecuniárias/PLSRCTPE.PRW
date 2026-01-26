#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt09L := TFont():New("MS LineDraw Regular",09,09,,.F., , , , .T., .F.)
STATIC oFnt09T := TFont():New("MS LineDraw Regular",10,10,,.T., , , , .T., .F.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.f., , , , .t., .f.)
STATIC oFnt10C := TFont():New("Arial",09,09,,.f., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)


Function PLSRCTPE(lTodosQuadros,lAuto)

	Local cCadastro := "DIOPS - Contraprestação Pecuniária / Prêmios de Preço Preestabelecido"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		Private cTitulo   := cCadastro
		Private oReport   := nil
		Private cRelName  := "DIOPS_Contraprestacao_Pecuniaria_"+CriaTrab(NIL,.F.)
		Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		Pergunte(cPerg,.F.)

		oReport := FWMSPrinter():New(cRelName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(08,08,08,08)
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

	Processa( {|| aResult := PLSDIDSA() }, "DIOPS - Contraprestação Pecuniária / Prêmios de Preço Preestabelecido")

	// Se não há dados a apresentar
	If !aResult[1]
        If !lAuto
			MsgAlert('Não há dados a apresentar referente a Contraprestação Pecuniária / Prêmios de Preço Preestabelecido')
        EndIf			
		Return
	EndIf 

	cTitulo 	:= "Contraprestações Pecuniárias"
	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRI18IDSA(aResult[2]) //Recebe Resultado da Query e Monta Relatório para DIOPS 2018	

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} PRI18IDSA

@description Imprime Contraprestação Pecuniária / Prêmios de Preço Preestabelecido para DIOPS 2019
@author José Paulo
@since 28/05/2019
@version P12

/*/
//------------------------------------------------------------------

Static Function PRI18IDSA(aValores)

	LOCAL lRet		:= .T.
	Local nLin		:= 0
	Local aSomaCols	:= { 0, 0, 0, 0, 0, 0, 0, 0}	// Somatorio das Colunas de Valores em todos os Vencimentos
	Local nI		:= 0
	Local nJ		:= 0
	Local cTitulo 	:= "Contraprestações Pecuniárias"
	Local nPagina   := 0
	Local nCol01	:= 20
	Local nCol02	:= 148
	Local nCol03	:= 232
	Local nCol04	:= 316
	Local nCol05	:= 400
	Local nCol06	:= 480
	Local nCol07	:= 565
	Local nCol08	:= 652
	Local nCol09	:= 732
	Local nCol10	:= 800
	Local nCol11	:= 880
	Local nCol12    := 150

	while nPagina < 2
	
		oReport:box(100, 008, 170, 828) //Box principal
		oReport:box(100, 008, 170, 80) //Box Vencimento Financeiro
	
		oReport:Say(115, 011, "Período de", oFnt11N)
		oReport:Say(130, 011, "Cobertura", oFnt11N)  		
		oReport:Say(145, 011, "Associado à", oFnt11N)
		oReport:Say(160, 011, "Contraprestação", oFnt11N)
	
		oReport:Line(150, 80, 150, 828)
		oReport:Line(130, 80, 130, 828)
	
		oReport:Say(115, 320, "Contraprestações Pecuniárias / Prêmios por Período de Cobertura", oFnt11N) //"Contraprestações Pecuniárias / Prêmios por Período de Cobertura"
		oReport:Say(140, 168, "Mensalidades - Planos Individuais/Familiares (Pessoa Física)"	, oFnt11N)  //"Contraprestação Pecuniária"	
		oReport:Say(140, 565, "Faturas - Planos Coletivos (Pessoa Juridica)"	, oFnt11N)  //"Contraprestação Pecuniária"	

		//pessoa fisica
		oReport:Say(160,  85, "Valor Emitido Líquido     ", oFnt11N)
		oReport:Say(160, 179, "Valor Recebido            ", oFnt11N)
		oReport:Say(160, 273, "Valor Vencido             ", oFnt11N)
		oReport:Say(160, 367, "Valor a Vencer            ", oFnt11N)

		//pessoa juridica
		oReport:Say(160, 461, "Valor Emitido Líquido   ", oFnt11N) 	
		oReport:Say(160, 555, "Valor Recebido          ", oFnt11N) 	
		oReport:Say(160, 649, "Valor Vencido           ", oFnt11N) 	
		oReport:Say(160, 743, "Valor a Vencer          ", oFnt11N) 	

		nSom := 0
		For nI := 1 To 17
			oReport:box(170 + nSom, 008, 195 + nSom, 828)
			nSom += 25
		Next

		If nPagina == 0
			oReport:Say(185, 011, "À iniciar"             , oFnt10C) //"A vencer"
			oReport:Say(210, 011, "Iniciado no dia 1 (*)" , oFnt10C) 	
			oReport:Say(235, 011, "Iniciado no dia 2 (*)" , oFnt10C) 
			oReport:Say(260, 011, "Iniciado no dia 3 (*)" , oFnt10C) 
			oReport:Say(285, 011, "Iniciado no dia 4 (*)" , oFnt10C)
			oReport:Say(310, 011, "Iniciado no dia 5 (*)" , oFnt10C)
			oReport:Say(335, 011, "Iniciado no dia 6 (*)" , oFnt10C)
			oReport:Say(360, 011, "Iniciado no dia 7 (*)" , oFnt10C)
			oReport:Say(385, 011, "Iniciado no dia 8 (*)" , oFnt10C)
			oReport:Say(410, 011, "Iniciado no dia 9 (*)" , oFnt10C)	 
			oReport:Say(435, 011, "Iniciado no dia 10 (*)", oFnt10C)	 
			oReport:Say(460, 011, "Iniciado no dia 11 (*)", oFnt10C)	 
			oReport:Say(485, 011, "Iniciado no dia 12 (*)", oFnt10C)	 
			oReport:Say(510, 011, "Iniciado no dia 13 (*)", oFnt10C)	 
			oReport:Say(535, 011, "Iniciado no dia 14 (*)", oFnt10C)	 
			oReport:Say(560, 011, "Iniciado no dia 15 (*)", oFnt10C)	 
			oReport:Say(585, 011, "Iniciado no dia 16 (*)", oFnt10C)	 
		Else
			oReport:Say(185, 011, "Iniciado no dia 17 (*)", oFnt10C) 	
			oReport:Say(210, 011, "Iniciado no dia 18 (*)", oFnt10C) 	
			oReport:Say(235, 011, "Iniciado no dia 19 (*)", oFnt10C) 
			oReport:Say(260, 011, "Iniciado no dia 20 (*)", oFnt10C) 
			oReport:Say(285, 011, "Iniciado no dia 21 (*)", oFnt10C)
			oReport:Say(310, 011, "Iniciado no dia 22 (*)", oFnt10C)
			oReport:Say(335, 011, "Iniciado no dia 23 (*)", oFnt10C)
			oReport:Say(360, 011, "Iniciado no dia 24 (*)", oFnt10C)
			oReport:Say(385, 011, "Iniciado no dia 25 (*)", oFnt10C)
			oReport:Say(410, 011, "Iniciado no dia 26 (*)", oFnt10C)	 
			oReport:Say(435, 011, "Iniciado no dia 27 (*)", oFnt10C)	 
			oReport:Say(460, 011, "Iniciado no dia 28 (*)", oFnt10C)	 
			oReport:Say(485, 011, "Iniciado no dia 29 (*)", oFnt10C)	 
			oReport:Say(510, 011, "Iniciado no dia 30 (*)", oFnt10C)	 
			oReport:Say(535, 011, "Iniciado no dia 31 (*)", oFnt10C)	 
			oReport:Say(555, 011, "Iniciado em meses", oFnt10C)
			oReport:Say(565, 011, "anteriores (**)"  , oFnt10C)
			oReport:Say(585, 011, "Total", oFnt11N)	 
		EndIf

		nCol := 80
		For nI := 2 to 9

			If nI == 6
				nCol12 := 130
			Else
				nCol12 := 150
			EndIf
			oReport:Line(nCol12, nCol, 594, nCol)
			nCol := nCol + 94

		Next

		nCol := 86
		For nI := 1 To 8

			//nCol := &('nCol'+StrZero(nI+IIf(nI==9,2,1), 2))
			nLin := 185

			If nPagina == 0 
				For nJ := 1 To 17
					If nI != 8
						oReport:Say(nLin, nCol, PADL(Transform(aValores[nJ, nI+1], Moeda),20), oFnt09L)					
					Else
						oReport:Say(nLin, nCol - 3, PADL(Transform(aValores[nJ, nI+1], Moeda),20), oFnt09L)							
					EndIf
					nLin += 25
				Next
			Else
				For nJ := 18 To 33
					If nI != 8
						oReport:Say(nLin, nCol, PADL(Transform(aValores[nJ, nI+1], Moeda),20), oFnt09L)	
					Else
						oReport:Say(nLin, nCol - 3, PADL(Transform(aValores[nJ, nI+1], Moeda),20), oFnt09L)	
					EndIf
					nLin += 25
				Next
			ENdIf
			nCol += 94
		Next

		If nPagina == 0 
			PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nPagina:=1
		Else

			For nI:= 1 to len(aValores)			

				aSomaCols[1]+=aValores[nI,2]
				aSomaCols[2]+=aValores[nI,3]
				aSomaCols[3]+=aValores[nI,4]
				aSomaCols[4]+=aValores[nI,5]
				aSomaCols[5]+=aValores[nI,6]
				aSomaCols[6]+=aValores[nI,7]
				aSomaCols[7]+=aValores[nI,8]
				aSomaCols[8]+=aValores[nI,9]

			Next

			oReport:Say(585,  77, PADL(Transform(aSomaCols[1], Moeda),20), oFnt09T)
			oReport:Say(585, 171, PADL(Transform(aSomaCols[2], Moeda),20), oFnt09T)
			oReport:Say(585, 265, PADL(Transform(aSomaCols[3], Moeda),20), oFnt09T)
			oReport:Say(585, 359, PADL(Transform(aSomaCols[4], Moeda),20), oFnt09T)
			oReport:Say(585, 453, PADL(Transform(aSomaCols[5], Moeda),20), oFnt09T)
			oReport:Say(585, 547, PADL(Transform(aSomaCols[6], Moeda),20), oFnt09T)
			oReport:Say(585, 641, PADL(Transform(aSomaCols[7], Moeda),20), oFnt09T)
			oReport:Say(585, 732, PADL(Transform(aSomaCols[8], Moeda),20), oFnt09T)
			nPagina:=2

		ENdIf
	EndDo

Return lRet

Static Function PLSDIDSA()

	Local nCount	:= 0
	Local aRetCtPc	:= 	{}						
	Local cSql 		:= ""
	Local lRet 		:= .T.

	aRetCtPc	:= 	{	{'084', 0,0,0,0,0,0,0,0},{'085', 0,0,0,0,0,0,0,0},{'086', 0,0,0,0,0,0,0,0},{'087', 0,0,0,0,0,0,0,0},{'088', 0,0,0,0,0,0,0,0},;
						{'089', 0,0,0,0,0,0,0,0},{'090', 0,0,0,0,0,0,0,0},{'091', 0,0,0,0,0,0,0,0},{'092', 0,0,0,0,0,0,0,0},{'093', 0,0,0,0,0,0,0,0},;
						{'094', 0,0,0,0,0,0,0,0},{'095', 0,0,0,0,0,0,0,0},{'096', 0,0,0,0,0,0,0,0},{'097', 0,0,0,0,0,0,0,0},{'098', 0,0,0,0,0,0,0,0},;
						{'099', 0,0,0,0,0,0,0,0},{'100', 0,0,0,0,0,0,0,0},{'101', 0,0,0,0,0,0,0,0},{'102', 0,0,0,0,0,0,0,0},{'103', 0,0,0,0,0,0,0,0},;
						{'104', 0,0,0,0,0,0,0,0},{'105', 0,0,0,0,0,0,0,0},{'106', 0,0,0,0,0,0,0,0},{'107', 0,0,0,0,0,0,0,0},{'108', 0,0,0,0,0,0,0,0},;
						{'109', 0,0,0,0,0,0,0,0},{'110', 0,0,0,0,0,0,0,0},{'111', 0,0,0,0,0,0,0,0},{'112', 0,0,0,0,0,0,0,0},{'113', 0,0,0,0,0,0,0,0},;
						{'114', 0,0,0,0,0,0,0,0},{'115', 0,0,0,0,0,0,0,0},{'116', 0,0,0,0,0,0,0,0}}	

	cSql := " SELECT B37_EMITID, B37_RECEBI,B37_VENCID,B37_AVENCE,B37_PLANO,B37_PERCOB  "
	cSql += " FROM " + RetSqlName("B37")
	cSql += " WHERE B37_FILIAL = '" + xFilial("B37") + "' " 
	cSql += " AND B37_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B37_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B37_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B37_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B37_PERCOB, B37_PLANO " 	
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCTP",.F.,.T.)
	TcSetField("TRBCTP", "B37_EMITID",  "N", 16, 2 )
	TcSetField("TRBCTP", "B37_RECEBI",  "N", 16, 2 )
	TcSetField("TRBCTP", "B37_VENCID",  "N", 16, 2 )
	TcSetField("TRBCTP", "B37_AVENCE",  "N", 16, 2 )

	If !TRBCTP->(Eof())
		Do While !TRBCTP->(Eof())
			nCount++
			nLinha	:= 0		// Linha do array em que se encaixa o registro
			Do Case
				Case TRBCTP->B37_PERCOB = '084'
					nLinha := 1
				Case TRBCTP->B37_PERCOB = '085'
					nLinha := 2
				Case TRBCTP->B37_PERCOB = '086'
					nLinha := 3
				Case TRBCTP->B37_PERCOB = '087'
					nLinha := 4
				Case TRBCTP->B37_PERCOB = '088'
					nLinha := 5
				Case TRBCTP->B37_PERCOB = '089'
					nLinha := 6
				Case TRBCTP->B37_PERCOB = '090'
					nLinha := 7
				Case TRBCTP->B37_PERCOB = '091'
					nLinha := 8
				Case TRBCTP->B37_PERCOB = '092'
					nLinha := 9
				Case TRBCTP->B37_PERCOB = '093'
					nLinha := 10
				Case TRBCTP->B37_PERCOB = '094'
					nLinha := 11
				Case TRBCTP->B37_PERCOB = '095'
					nLinha := 12
				Case TRBCTP->B37_PERCOB = '096'
					nLinha := 13
				Case TRBCTP->B37_PERCOB = '097'
					nLinha := 14
				Case TRBCTP->B37_PERCOB = '098'
					nLinha := 15
				Case TRBCTP->B37_PERCOB = '099'
					nLinha := 16
				Case TRBCTP->B37_PERCOB = '100'
					nLinha := 17
				Case TRBCTP->B37_PERCOB = '101'
					nLinha := 18
				Case TRBCTP->B37_PERCOB = '102'
					nLinha := 19
				Case TRBCTP->B37_PERCOB = '103'
					nLinha := 20
				Case TRBCTP->B37_PERCOB = '104'
					nLinha := 21
				Case TRBCTP->B37_PERCOB = '105'
					nLinha := 22
				Case TRBCTP->B37_PERCOB = '106'
					nLinha := 23
				Case TRBCTP->B37_PERCOB = '107'
					nLinha := 24
				Case TRBCTP->B37_PERCOB = '108'
					nLinha := 25
				Case TRBCTP->B37_PERCOB = '109'
					nLinha := 26
				Case TRBCTP->B37_PERCOB = '110'
					nLinha := 27
				Case TRBCTP->B37_PERCOB = '111'
					nLinha := 28
				Case TRBCTP->B37_PERCOB = '112'
					nLinha := 29
				Case TRBCTP->B37_PERCOB = '113'
					nLinha := 30
				Case TRBCTP->B37_PERCOB = '114'
					nLinha := 31
				Case TRBCTP->B37_PERCOB = '115'
					nLinha := 32
				Case TRBCTP->B37_PERCOB = '116'
					nLinha := 33

				OtherWise	
					nLinha := 1
			EndCase
			If TRBCTP->B37_PLANO <> "PCJ"			
				aRetCtPc[nLinha,2] := TRBCTP->B37_EMITID
				aRetCtPc[nLinha,3] := TRBCTP->B37_RECEBI
				aRetCtPc[nLinha,4] := TRBCTP->B37_VENCID
				aRetCtPc[nLinha,5] := TRBCTP->B37_AVENCE	
			Else	
				aRetCtPc[nLinha,6] := TRBCTP->B37_EMITID
				aRetCtPc[nLinha,7] := TRBCTP->B37_RECEBI
				aRetCtPc[nLinha,8] := TRBCTP->B37_VENCID
				aRetCtPc[nLinha,9] := TRBCTP->B37_AVENCE	
			EndIf
			TRBCTP->(DbSkip())		

		EndDo
	EndIf
	TRBCTP->(DbCloseArea())
	
Return( { nCount>0 , aRetCtPc } )
