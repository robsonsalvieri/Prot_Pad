#Include "PROTHEUS.Ch"       
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.f., , , , .T., .F.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.t., , , , .T., .F.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",12,12,,.F., , , , .T., .F.)
STATIC oFnt12T 		:= TFont():New("MS LineDraw Regular",12,12,,.T., , , , .T., .F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDFLCX

Relatório do Quadro Fluxo de Caixa

@author Roger C
@since 22/01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDFLCX(lTodosQuadros,lAuto)

	Local aSays			:= {}
	Local aButtons		:= {}
	Local cCadastro		:= "DIOPS - FLUXO DE CAIXA"
	Local aResult		:= {}
	Local aPergs   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros

		Private cPerg		:= "DIOPSINT"
		PRIVATE cTitulo 	:= cCadastro
		PRIVATE oReport     := nil
		PRIVATE cRelName	:= "DIOPS_FLCX_Trimestral_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina		:= 0		// Já declarada PRIVATE na chamada de todos os quadros
		PRIVATE cTipDiops := "1"
		PRIVATE cMesDiops := Space(2)

		aAdd(aPergs, {2, "Tipo",               cTipDiops, {"1=Diops Trimestral",              "2=Diops Mensal"},     120, "PERTENCE('01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12')", .F.})
		aAdd(aPergs, {1, "Mês Competência",               cMesDiops,  "",             ".T.",        "", ".T.", 50,  .F.})
	
		If !lAuto .And. ParamBox(aPergs, "Imprimir Quadro - Informe os parâmetros", /*aRet*/, {|| fValSimpl()}, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
			cTipDiops := MV_PAR01
			cMesDiops := MV_PAR02
		EndIf

		If cTipDiops == "2" .And. !lAuto
			cRelName := "DIOPS_FLCX_Mensal_"+ MesExtenso(cMesDiops)+"_"+CriaTrab(NIL,.F.)
		EndIf

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

	Processa( {|| aResult := PLSDFLCX() }, "DIOPS - FLUXO DE CAIXA")

	aResult:= PLSVERQRY(aResult[2])

	cTitulo 	:= "Fluxo de Caixa"
	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTFLCX(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTFLCX

@description Imprime FLUXO DE CAIXA
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------

Static Function PRINTFLCX(aValores)

	LOCAL lRet		:= .T.
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
	Local nLinha	:= 105
	Local nMemoLin	:= 0
	Local nVez		:= 0
	Local nPos		:= 0
	Local nSubTotal	:= 0
	Local nTotal	:= 0

	oReport:Say(nLinha, 020, "Código", oFnt12N)	//
	oReport:Say(nLinha, 060, "Descrição", oFnt12N)	//
	oReport:Say(nLinha, 760, "Valor", oFnt12N)			//
	nLinha += 5
	// ATIVIDADES OPERACIONAIS - 101 a 115
	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)		
	nLinha += 15
	nMemoLin := nLinha-5
	For nVez := 101 to 115
		nLinha += 15
		If ( nPos := aScan( aValores, {|x| x[1] == AllTrim(StrZero(nVez,3,0) )  } ) ) == 0   
			Loop
		EndIf
		nSubTotal	+= aValores[nPos,2]
		nTotal		+= aValores[nPos,2]
		oReport:Say(nLinha , 020, aValores[nPos,1], oFnt12C)			
		oReport:Say(nLinha , 060, B8HDescri(aValores[nPos,1]), oFnt12C)			
		oReport:Say(nLinha , 680, PadL(Transform(aValores[nPos,2], Moeda),20), oFnt12L)
	Next	
	oReport:Say(nMemoLin, 060, "ATIVIDADES OPERACIONAIS", oFnt12N)			
	oReport:Say(nMemoLin, 680, PadL(Transform(nSubTotal, Moeda),20), oFnt12T)

	nLinha += 15
	nSubTotal := 0

	// ATIVIDADES DE INVESTIMENTO - 201 a 210
	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)		
	nLinha += 15
	nMemoLin := nLinha-5
	For nVez := 201 to 210
		nLinha += 15
		If ( nPos := aScan( aValores, {|x| x[1] == AllTrim(StrZero(nVez,3,0) )  } ) ) == 0   
			Loop
		EndIf
		nSubTotal	+= aValores[nPos,2]
		nTotal		+= aValores[nPos,2]
		oReport:Say(nLinha , 020, aValores[nPos,1], oFnt12C)			
		oReport:Say(nLinha , 060, B8HDescri(aValores[nPos,1]), oFnt12C)			
		oReport:Say(nLinha , 680, PadL(Transform(aValores[nPos,2], Moeda),20), oFnt12L)
	Next	
	oReport:Say(nMemoLin, 060, "ATIVIDADES DE INVESTIMENTO", oFnt12N)			
	oReport:Say(nMemoLin, 680, PadL(Transform(nSubTotal, Moeda),20), oFnt12T)
	nSubTotal := 0

	oReport:EndPage()
	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
	nLinha := 105

	oReport:Say(nLinha, 020, "Código", oFnt12N)	//
	oReport:Say(nLinha, 060, "Descrição", oFnt12N)	//
	oReport:Say(nLinha, 760, "Valor", oFnt12N)			//

	nLinha += 5

	// ATIVIDADES DE FINANCIAMENTO - 301 a 308
	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)		
	nLinha += 15
	nMemoLin := nLinha-5
	For nVez := 301 to 308
		nLinha += 15
		If ( nPos := aScan( aValores, {|x| x[1] == AllTrim(StrZero(nVez,3,0) )  } ) ) == 0   
			Loop
		EndIf
		nSubTotal	+= aValores[nPos,2]
		nTotal		+= aValores[nPos,2]
		oReport:Say(nLinha , 020, aValores[nPos,1], oFnt12C)			
		oReport:Say(nLinha , 060, B8HDescri(aValores[nPos,1]), oFnt12C)			
		oReport:Say(nLinha , 680, PadL(Transform(aValores[nPos,2], Moeda),20), oFnt12L)
	Next	
	oReport:Say(nMemoLin, 060, "ATIVIDADES DE FINANCIAMENTO", oFnt12N)			
	oReport:Say(nMemoLin, 680, PadL(Transform(nSubTotal, Moeda),20), oFnt12T)

	// CAIXA LIQUIDO
	nLinha += 5
	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)		
	nLinha += 10
	oReport:Say(nLinha, 060, "CAIXA LIQUIDO", oFnt12N)			
	oReport:Say(nLinha, 680, PadL(Transform(nTotal, Moeda),20), oFnt12T)

Return lRet



Static Function PLSDFLCX()

	Local cSql 		:= ""
	Local lRet 		:= .F.
	Local aResult	:= {}

	Default cTipDiops := "1"


    If cTipDiops == "1"
		cSql := " SELECT B8H_CODIGO, SUM(B8H_VLRCON) AS VLRCON "
	Else 
		cSql := " SELECT B8H_CODIGO, B8H_VLRCON AS VLRCON "
	EndIf
	cSql += " FROM " + RetSqlName("B8H")
	cSql += " WHERE B8H_FILIAL = '" + xFilial("B8H") + "' " 
	cSql += " AND B8H_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8H_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8H_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8H_CDCOMP = '" + B3D->B3D_CODIGO + "' "

	If cTipDiops == "2" .And. B8H->(fieldpos("B8H_MESCMP")) > 0
		cSql += " AND B8H_MESCMP = '" + cMesDiops + "' "
	Endif 

	cSql += " AND D_E_L_E_T_ = ' ' "

	If cTipDiops == "1"
		cSql += " GROUP BY B8H_CODIGO "
	EndIf 

	cSql += " ORDER BY B8H_CODIGO "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBFLX",.F.,.T.)
	TcSetField("TRBFLX", "B8H_VLRCON", 	"N", 16, 2 )

	TRBFLX->(dbGoTop())
	If !TRBFLX->(Eof())
		lRet := .T.
		While !TRBFLX->(Eof())
			aAdd(aResult, { TRBFLX->B8H_CODIGO , TRBFLX->VLRCON  } )
			TRBFLX->(dbSkip())
		EndDo
	EndIf
	TRBFLX->(DbCloseArea())
	
Return( { lRet, aResult } )

//------------------------------------------------------------------
/*/{Protheus.doc} PLSVERQRY

@description Imprime as informações com zero caso não encontre o valor
@since 16/07/2019
/*/
//------------------------------------------------------------------

Static Function PLSVERQRY(aRes)
	
	Local aResult := {}  
	Local nI      := 0
	Local lRet    := .T.
	Local nJ      := 0
	Default aRes  := {}
	
	aAdd(aResult, {"101",0 })
	aAdd(aResult, {"102",0 })
	aAdd(aResult, {"103",0 })
	aAdd(aResult, {"104",0 })
	aAdd(aResult, {"105",0 })
	aAdd(aResult, {"106",0 })
	aAdd(aResult, {"107",0 })
	aAdd(aResult, {"108",0 })
	aAdd(aResult, {"109",0 })
	aAdd(aResult, {"110",0 })
	aAdd(aResult, {"111",0 })
	aAdd(aResult, {"112",0 })
	aAdd(aResult, {"113",0 })
	aAdd(aResult, {"114",0 })
	aAdd(aResult, {"115",0 })
	aAdd(aResult, {"201",0 })
	aAdd(aResult, {"202",0 })
	aAdd(aResult, {"203",0 })
	aAdd(aResult, {"204",0 })
	aAdd(aResult, {"205",0 })
	aAdd(aResult, {"206",0 })
	aAdd(aResult, {"207",0 })
	aAdd(aResult, {"208",0 })
	aAdd(aResult, {"209",0 })
	aAdd(aResult, {"210",0 })
	aAdd(aResult, {"301",0 })
	aAdd(aResult, {"302",0 })
	aAdd(aResult, {"303",0 })
	aAdd(aResult, {"304",0 })
	aAdd(aResult, {"305",0 })
	aAdd(aResult, {"306",0 })
	aAdd(aResult, {"307",0 })
	aAdd(aResult, {"308",0 })
	
	For nI:=1 To Len(aResult)                  
		For nJ:=1 To Len(aRes) 
			If aResult[nI,1] == aRes[nJ,1] 
				aResult[nI,2]:=aRes[nJ,2]
			EndIf					   			
		Next
	Next

Return({lRet,aClone(aResult)})
