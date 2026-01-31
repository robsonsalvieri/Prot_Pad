#Include "PROTHEUS.Ch"       
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 999,999,999,999.99"

STATIC oFnt09C 		:= TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt09L 		:= TFont():New("MS LineDraw Regular",09,09,,.F., , , , .t., .f.)
STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.F., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDBALT

Relatório do Balancete da DIOPS

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDBALT(lTodosQuadros,lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "Balancete"
	Local lResult   := .F.
	Local aPergs   := {}
	
	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.
	DEFAULT cTipDiops := "1"

	If !lTodosQuadros
		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cRelName := "DIOPS_Balancete_Trimestral_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros
		PRIVATE cTipDiops := "1"
		PRIVATE cMesDiops := Space(2)

		aAdd(aPergs, {2, "Tipo",               cTipDiops, {"1=Diops Trimestral",              "2=Diops Mensal"},     120, ".T.", .F.})
		aAdd(aPergs, {1, "Mês Competência",               cMesDiops,  "",             ".T.",        "", ".T.", 50,  .F.})
	
		If !lAuto .And. ParamBox(aPergs, "Imprimir Quadro - Informe os parâmetros", /*aRet*/, {|| fValSimpl()}, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
			cTipDiops := MV_PAR01
			cMesDiops := MV_PAR02
		EndIf

		If cTipDiops == "2" .And. !lAuto
			cRelName := "DIOPS_Balancete_Mensal_"+ MesExtenso(cMesDiops)+"_"+CriaTrab(NIL,.F.)
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

	Processa( {|| lResult := PLSDBALT() }, "DIOPS - Balancete Trimestral")

	// Se não há dados a apresentar
	If !lResult
		If !lAuto .AND. cTipDiops == "1"
			MsgAlert('Não há dados a apresentar referente a Balancete Trimestral')
		Else
			MsgAlert('Não há dados a apresentar referente a Balancete Mensal de '+ MesExtenso(cMesDiops) + ".")
		EndIf
		Return
	EndIf 

	PlsRDCab(cCadastro)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTBALT() //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf	

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTBALT

@description Imprime Balancete Trimestral
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------

Static Function PRINTBALT(aValores)

	LOCAL lRet		:= .T.
	Local nLinha	:= 105
	Local nCol1		:= 020
	Local nCol2		:= 060
	Local nCol3		:= 440
	Local nCol4		:= 535
	Local nCol5		:= 625
	Local nCol6		:= 715
	Local cCadastro		:= "Balancete"

	oReport:Say(nLinha, nCol1, "Conta", oFnt11N)
	oReport:Say(nLinha, nCol2, "Descrição", oFnt11N)
	oReport:Say(nLinha, 460, "Saldo Anterior", oFnt11N)
	oReport:Say(nLinha, 570, "Débitos", oFnt11N)
	oReport:Say(nLinha, 655, "Créditos", oFnt11N)
	oReport:Say(nLinha, 750, "Saldo Final", oFnt11N)

	TRBBAL->(dbGoTop())
	Do While !TRBBAL->(Eof())

		nLinha += 15
		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab(cCadastro)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105

			oReport:Say(nLinha, nCol1, "Conta", oFnt11N)
			oReport:Say(nLinha, nCol2, "Descrição", oFnt11N)
			oReport:Say(nLinha, 465, "Saldo Anterior", oFnt11N)
			oReport:Say(nLinha, 570, "Débitos", oFnt11N)
			oReport:Say(nLinha, 650, "Créditos", oFnt11N)
			oReport:Say(nLinha, 750, "Saldo Final", oFnt11N)
			nLinha += 15

		EndIf

		oReport:Say(nLinha, nCol1, TRBBAL->(B8A_CONTA), oFnt09C)			// Conta
		oReport:Say(nLinha, nCol2, SUBSTR(Posicione('B8B',1,xFilial('B8B')+TRBBAL->B8A_CODOPE+TRBBAL->B8A_CONTA,'B8B_DESCRI'),1,90), oFnt09C)			// Descrição

		oReport:Say(nLinha, nCol3, PadL(Transform(TRBBAL->SALANT, Moeda),20), oFnt09L)			// Saldo Anterior
		oReport:Say(nLinha, nCol4, PadL(Transform(TRBBAL->DEBITO, Moeda),20), oFnt09L)			// Débitos
		oReport:Say(nLinha, nCol5, PadL(Transform(TRBBAL->CREDIT, Moeda),20), oFnt09L)			// Créditos
		oReport:Say(nLinha, nCol6, PadL(Transform(TRBBAL->SALFIN, Moeda),20), oFnt09L)			// Saldo Final

		TRBBAL->(DbSkip())		

	EndDo

	TRBBAL->(DbCloseArea())

Return lRet

Static Function PLSDBALT()
	
	Local cSql 		:= ""
	Local lRet 		:= .F.
	Local aMesTri := {}

	Default cTipDiops := "1"

	If cTipDiops == "1"  //Trimestral

		//Retorna o mes ini e fin do trimestre para retorno do salant e salfin
		aMesTri := chkMesTri(B3D->B3D_CODIGO)

		cSql := " SELECT B8A_CODOPE, B8A_CONTA, 
		cSql += " ( SELECT B8A_SALANT
		cSql += " 	FROM " + RetSqlName("B8A")
		cSql += " 	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
		cSql += "      AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' "
        cSql += "      AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
        cSql += "      AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
        cSql += "      AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
		IIf(B8A->(fieldpos("B8A_MESCMP")) > 0,cSql += "      AND B8A_MESCMP = '" + aMesTri[1] + "' ","")
		cSql += " 	  AND D_E_L_E_T_ = ''
		cSql += "     AND B8A_CODOPE = B8A.B8A_CODOPE
		cSql += "     AND B8A_CONTA  = B8A.B8A_CONTA
        cSql += " ) AS SALANT ,  
		cSql += "  SUM(B8A_DEBITO) AS DEBITO,  SUM(B8A_CREDIT) AS CREDIT,  
		cSql += " ( SELECT B8A_SALFIN
        cSql += "   FROM " + RetSqlName("B8A")
        cSql += "   WHERE  B8A_FILIAL = '" + xFilial("B8A") + "' " 
		cSql += "      AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' "
        cSql += "      AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
        cSql += "      AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
        cSql += "      AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
		IIf(B8A->(fieldpos("B8A_MESCMP")) > 0,cSql += "      AND B8A_MESCMP = '" + aMesTri[2] + "' ","")
        cSql += "      AND D_E_L_E_T_ = ''
        cSql += "      AND B8A_CODOPE = B8A.B8A_CODOPE
        cSql += "      AND B8A_CONTA  = B8A.B8A_CONTA
        cSql += " ) AS SALFIN
	Else 
		cSql := " SELECT B8A_CODOPE, B8A_CONTA, B8A_SALANT AS SALANT, B8A_DEBITO AS DEBITO, B8A_CREDIT AS CREDIT, B8A_SALFIN AS SALFIN "
	Endif 
	
	cSql += " FROM " + RetSqlName("B8A")+ " B8A "
	cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
	cSql += " AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "

	If cTipDiops == "2" .And. B8A->(fieldpos("B8A_MESCMP")) > 0
		cSql += " AND B8A_MESCMP = '" + cMesDiops + "' "
	Endif 
	
	cSql += " AND D_E_L_E_T_ = ' ' "

	If cTipDiops == "1"
		cSql += " GROUP BY B8A_CODOPE, B8A_CONTA "
	Endif 

	cSql += " ORDER BY B8A_CONTA " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBAL",.F.,.T.)
	TcSetField("TRBBAL", "SALANT",  "N", 16, 2 )
	TcSetField("TRBBAL", "DEBITO",  "N", 16, 2 )
	TcSetField("TRBBAL", "CREDIT",  "N", 16, 2 )
	TcSetField("TRBBAL", "SALFIN",  "N", 16, 2 )

	If !TRBBAL->(Eof())
		lRet := .T.
	Else
		TRBBAL->(DbCloseArea())
	EndIf
	
Return( lRet )

/*/{Protheus.doc} fValSimpl
	Valida se foi digitado um mês validado para impressoa do quadro (Balancete ou Fluxo de Caixa)
	@type  Function
	@author PLS team
	@since 02/05/2024
/*/
Function fValSimpl()

	Local lRet := .T.

	If MV_PAR01 == "2"
		If MV_PAR02 $ ("01,02,03,04,05,06,07,08,09,10,11,12")
			lRet := .T.
		Else 
			lRet := .F.
			MSGALERT( "Informe um mês válido do trimeste a ser impresso." )
		Endif
	EndIf 
	
Return lRet

/*/{Protheus.doc} chkMesTri
	Retorna o mês inicial e final de cada trismeste
	@type  Function
	@author PLS team
	@since 02/05/2024
/*/
Function chkMesTri(cCodTri)

Local cAnt := ""
Local cFin := ""

	Do Case

		Case cCodTri == "001"
			cAnt := "01"
			cFin := "03"

		Case cCodTri == "002"
			cAnt := "04"
			cFin := "06"

		Case cCodTri == "003"
			cAnt := "07"
			cFin := "09"

		Case cCodTri == "004"
			cAnt := "10"
			cFin := "12"

	EndCase
	
Return {cAnt,cFin}
