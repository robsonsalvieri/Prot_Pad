#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt09L := TFont():New("MS LineDraw Regular",08,08,,.F., , , , .T., .F.)
STATIC oFnt09T := TFont():New("MS LineDraw Regular",08,08,,.T., , , , .T., .F.)
STATIC oFnt10N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12N := TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",08,08,,.f., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",18,18,,.t., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDISP

Relatório do Quadro Idade dos Saldos Passivo

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDISA(lTodosQuadros,lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - Idade de Saldos Passivo"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros
		
		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cFileName := "DIOPS_Idade_de_Saldos_Passivos_"+CriaTrab(NIL,.F.)
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
			oReport:CFILENAME  := cFileName
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

	Processa( {|| aResult := PLSDIDSP() }, "DIOPS - Idade de Saldos Passivo")

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Idade de Saldos Passivo')
		EndIf
		Return
	EndIf 

	cTitulo 	:= "Distribuição dos Saldos do Contas a Pagar"
	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTIDSP(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

Static Function PRINTIDSP(aValores)

	Local cMsg    := ""
	Local lRet    := .T.
	Local nI      := 0
	Local nSom    := 0
	Local nLinha  := 105
	Local nValor  := 0
	Local nTotal  := 0
	Local oBrush1 := TBrush():New( , RGB(224,224,224))  //Cinza claro
	Local aTotais := {0,0,0,0,0,0,0,0,0,0,0,0}
	Local nValor  := 0

	oReport:box(100, 03, 200, 68)          //Box Vencimento Financeiro
	oReport:Say(160, 10, STR0042, oFnt11N) //"Vencimento"
	oReport:Say(175, 10, STR0043, oFnt11N) //"Financeiro"

	oReport:box(100, 68, 175 , 604)         //580 Largura
	oReport:Say(120, 185, STR0044, oFnt12N) //"Débitos de Operações com Planos de Saúde"

	oReport:box(100, 604, 175 , 834)
	oReport:Say(112, 625, "Outros Débitos Não Relacionados", oFnt12N)
	oReport:Say(125, 665, "com Planos de Saúde", oFnt12N) 

	oReport:box(130, 68, 200, 145)
	oReport:Say(155, 73, STR0003, oFnt09C)  //"Eventos/"
	oReport:Say(165, 73, STR0004, oFnt09C)  //"Sinistros a"
	oReport:Say(175, 73, STR0005, oFnt09C)  //"Liquidar"
	oReport:Say(185, 73, STR0006, oFnt09C)  //"(SUS)"	

	oReport:box(130, 145, 200, 221)
	oReport:Say(155, 150, STR0003, oFnt09C)	//"Eventos/"
	oReport:Say(165, 150, STR0004, oFnt09C)	//"Sinistros a"  
	oReport:Say(175, 150, STR0005, oFnt09C)	//"Liquidar"

	oReport:box(130, 221, 200, 298) 
	oReport:Say(155, 226, STR0007, oFnt09C)  //"Comerciali-"
	oReport:Say(165, 226, STR0008, oFnt09C)  //"zação sobre"
	oReport:Say(175, 226, STR0009, oFnt09C)  //"operações"	

	oReport:box(130, 298, 200, 374) 
	oReport:Say(155, 303, STR0010, oFnt09C)  //"Débitos"
	oReport:Say(165, 303, STR0011, oFnt09C)  //"com"
	oReport:Say(175, 303, STR0012, oFnt09C)  //"operadoras"

	oReport:box(130, 374, 200, 451)
	oReport:Say(155, 380, STR0013, oFnt09C)  //"Outros"
	oReport:Say(165, 380, STR0014, oFnt09C)  //"Débitos de"
	oReport:Say(175, 380, STR0015, oFnt09C)  //"Operações"
	oReport:Say(185, 380, STR0016, oFnt09C)  //"com Planos"

	oReport:box(130, 451, 200, 527) 
	oReport:Say(155, 457, STR0017, oFnt09C)  //"Tributos e"
	oReport:Say(165, 457, STR0018, oFnt09C)  //"Encargos a"
	oReport:Say(175, 457, STR0019, oFnt09C)  //"Recolher"

	oReport:box(130, 527, 200, 604) 
	oReport:Say(155, 534, STR0020, oFnt09C)  //"Depósitos de"
	oReport:Say(165, 534, STR0021, oFnt09C)  //"Beneficiários -"
	oReport:Say(175, 534, STR0022, oFnt09C)  //"Contraprest/"
	oReport:Say(185, 534, STR0023, oFnt09C)  //"Seguros"
	oReport:Say(195, 534, STR0024, oFnt09C)  //"Recebidos"


	//Outros débitps não relacionados com Plano de Saúde

	oReport:box(130, 604, 200, 680) 
	oReport:Say(155, 611, STR0026, oFnt09C)  //"Prestadores"
	oReport:Say(165, 611, STR0027, oFnt09C)  //"de Serv. de"
	oReport:Say(175, 611, STR0028, oFnt09C)  //"Assistência"
	oReport:Say(185, 611, STR0029, oFnt09C)  //"a Saúde"

	oReport:box(130, 680, 200, 757)
	oReport:Say(155, 688, STR0030, oFnt09C)  //"Débitos com"
	oReport:Say(165, 688, STR0031, oFnt09C)  //"Aquisição de"
	oReport:Say(175, 688, STR0032, oFnt09C)  //"Carteira"

	oReport:box(130, 757, 200, 834) 
	oReport:Say(155, 765, STR0013, oFnt09C)  //"Outros"
	oReport:Say(165, 765, STR0033, oFnt09C)  //"Débitos a"
	oReport:Say(175, 765, STR0034, oFnt09C)  //"Pagar"

	//Box Linha dos vencimentos 
	oReport:box(200, 03, 215, 834)
	oReport:Fillrect( {201, 04, 216, 833 }, oBrush1)		

	oReport:box(215, 03, 240, 834)
	oReport:Say(228, 05, "A vencer", oFnt11N) //"A vencer"

	oReport:box(240, 03, 265, 834)
	oReport:Say(250, 05, "Vencidos de 1", oFnt11N)
	oReport:Say(260, 05, "a 30 dias", oFnt11N)

	oReport:box(265, 03, 290, 834)
	oReport:Say(275, 05, "Vencidos de 31", oFnt11N) //"Vencidos de 31 a 60 dias"
	oReport:Say(285, 05, "a 60 dias", oFnt11N) //"a 60 dias"

	oReport:box(290, 03, 315, 834)
	oReport:Say(300, 05, "Vencidos de 61", oFnt11N)  //"Vencidos de 61"
	oReport:Say(310, 05, "a 90 dias", oFnt11N)  //"a 90 dias"

	oReport:box(315, 03, 340, 834)
	oReport:Say(325, 05, "Vencidos de 91", oFnt11N)	 //"Vencidos de 91"
	oReport:Say(335, 05, "a 120 dias", oFnt11N)	 //"a 120 dias"

	oReport:box(340, 03, 365, 834)
	oReport:Say(350, 05, "Vencidos a mais", oFnt10N)  //"Vencidos a mais"
	oReport:Say(360, 05, "de 120 dias", oFnt10N)  //"de 120 dias"

	oReport:box(365, 03, 390, 834)
	oReport:Say(378, 05, STR0041, oFnt11N)  //Saldos

	//Line das colunas
	nSom := 0
	For nI := 1 to 10 

		oReport:Line(200, 68 + nSom, 390, 68 + nSom)
		if nI <> 10
			nSom += 76.5
		endif

	Next

	//****************************
	//Impressão dos Valores
	//****************************
	nSom := 0
	For nI := 2 to 11
		
		nValor := aValores[1][nI]
		oReport:Say(228, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO" Linha dos "A VENCER"
		nTotal += nValor

		nValor := aValores[2][nI]
		oReport:Say(253, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO" "VENCIDOS de 1 a 30 dias"
		nTotal += nValor

		nValor := aValores[3][nI]
		oReport:Say(278, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO" "VENCIDOS de 31 a 60 dias"
		nTotal += nValor

		nValor := aValores[4][nI]
		oReport:Say(303, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO" Linha dos "VENCIDOS de 61 a 90 dias"
		nTotal += nValor

		nValor := aValores[5][nI]
		oReport:Say(328, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO" Linha dos "VENCIDOS de 90 a 120 dias"
		nTotal += nValor

		nValor := aValores[6][nI]
		oReport:Say(353, 56.4 + nSom, PADL(Transform(FormtValue(nValor),Moeda),20), oFnt09L)  //"SALDO"  Linha dos "VENCIDOS a MAIS de 120 dias"
		nTotal += nValor

		aTotais[nI - 1] := nTotal
		nSom += 76.5
		nTotal := 0

	Next

	nSom := 0

	For nI := 1 to 10
		oReport:Say(378, 56.4 +  nSom, PADL(Transform(FormtValue(aTotais[nI]),Moeda),20), oFnt09T)  //"SALDO"
		nSom += 76.5
	Next

return lRet

Static Function FormtValue(nValor)
	
	Default nValor := 0
	If Empty(nValor)
		nValor := 0
	EndIf

Return nValor

Static Function PLSDIDSP()

	Local cSql 		:= ""
	Local lRet 		:= .T.
	Local nCount	:= 0
	Local aRetIDSP	:= 	{	{'000', 0,0,0,0,0,0,0,0,0,0 },;		
							{'030', 0,0,0,0,0,0,0,0,0,0 },;
							{'060', 0,0,0,0,0,0,0,0,0,0 },;
							{'090', 0,0,0,0,0,0,0,0,0,0 },;
							{'099', 0,0,0,0,0,0,0,0,0,0 },;
							{'400', 0,0,0,0,0,0,0,0,0,0 } }	

	cSql := " SELECT B8F_VENCTO, B8F_EVESUS, B8F_EVENTO, B8F_COMERC, B8F_DEBOPE, B8F_OUDBOP, B8F_TITSEN, B8F_DEPBEN, B8F_SERASS, B8F_AQUCAR, B8F_OUDBPG "
	cSql += " FROM " + RetSqlName("B8F")
	cSql += " WHERE B8F_FILIAL = '" + xFilial("B8F") + "' " 
	cSql += " AND B8F_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8F_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8F_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8F_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8F_VENCTO " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBISA",.F.,.T.)
	TcSetField("TRBISA", "B8F_EVESUS",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_EVENTO",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_COMERC",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_DEBOPE",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_OUDBOP",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_TITSEN",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_DEPBEN",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_SERASS",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_AQUCAR",  "N", 16, 2 )
	TcSetField("TRBISA", "B8F_OUDBPG",  "N", 16, 2 )

	If !TRBISA->(Eof())
		Do While !TRBISA->(Eof())
			nCount++
			nLinha	:= 0		// Linha do array em que se encaixa o registro
			Do Case
				Case TRBISA->B8F_VENCTO = '000'
					nLinha := 1
				Case TRBISA->B8F_VENCTO = '030'
					nLinha := 2
				Case TRBISA->B8F_VENCTO = '060'
					nLinha := 3
				Case TRBISA->B8F_VENCTO = '090'
					nLinha := 4
				Case TRBISA->B8F_VENCTO = '120'
					nLinha := 5
				Case TRBISA->B8F_VENCTO = '999'
					nLinha := 6
			EndCase
			If nLinha > 0 
				aRetIDSP[nLinha,2]  := TRBISA->B8F_EVESUS
				aRetIDSP[nLinha,3]  := TRBISA->B8F_EVENTO
				aRetIDSP[nLinha,4]  := TRBISA->B8F_COMERC
				aRetIDSP[nLinha,5]  := TRBISA->B8F_DEBOPE
				aRetIDSP[nLinha,6]  := TRBISA->B8F_OUDBOP
				aRetIDSP[nLinha,7]  := TRBISA->B8F_TITSEN
				aRetIDSP[nLinha,8]  := TRBISA->B8F_DEPBEN
				aRetIDSP[nLinha,9]  := TRBISA->B8F_SERASS
				aRetIDSP[nLinha,10] := TRBISA->B8F_AQUCAR
				aRetIDSP[nLinha,11] := TRBISA->B8F_OUDBPG			
				TRBISA->(DbSkip())
			Else
				TRBISA->(DbSkip())
			EndIf
		EndDo
	EndIf
	TRBISA->(DbCloseArea())
	
Return( { nCount>0 , aRetIDSP } )
