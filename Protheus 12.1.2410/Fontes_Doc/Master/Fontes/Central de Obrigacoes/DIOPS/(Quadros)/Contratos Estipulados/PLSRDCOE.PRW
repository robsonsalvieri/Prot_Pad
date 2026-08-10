#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"
#Define QUANTI "@E 9,999,999"
#Define QUANTI1 "@E 999,999,999,999"

STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",12,12,,.F., , , , .T., .F.)
STATIC oFnt12T 		:= TFont():New("MS LineDraw Regular",12,12,,.T., , , , .T., .F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSPLSRDCOERDEVIN

Relatório do Quadro Contratos Estipulados

@author Roger C
@since 22/01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDCOE(lTodosQuadros, lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - Contratos Estipulados"
	Local aResult   := {}
	Local lAtu22    := BUP->(fieldpos("BUP_CONREP")) > 0 .And. Val(B3D->B3D_ANO) >= 2022
	Local nI        := 0
	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.

	If BUP->(fieldpos("BUP_CONREP")) == 0  .And. !lAuto .And. Val(B3D->B3D_ANO) >= 2022
		MsgInfo("DIOPS 2022 - Para imprimir esta versão da DIOPS, favor atualizar o dicionário. Entre em contato com Administrador do sistema.")
		Return (.F.)
	EndIf

	If !lTodosQuadros

		Private cTitulo   := cCadastro
		Private oReport   := nil
		Private cRelName := "DIOPS_Contratos_Estipulados_"+CriaTrab(NIL,.F.)
		Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		oReport := FWMSPrinter():New(cRelName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)

		IIf(lAuto,oReport:CFILENAME := cRelName,"")
		IIf(lAuto,oReport:CFILEPRINT:= oReport:CPATHPRINT + oReport:CFILENAME,"")
		IIf(lAuto,.t.,oReport:Setup())

		If !lAuto .And. oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ()
		EndIf

	Else
		nPagina	:= 0

	EndIf


	Processa( {|| aResult := PLSDCOE(lAtu22) }, "DIOPS - Contratos Estipulados")

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Contratos Estipulados')
		EndIf
		Return
	EndIf
	If lAtu22

		For nI:=1 To 2
			If aScan(aResult[2],{ |x| AllTrim(x[4]) == cValToChar(nI) })
				cTitulo 	:= IIF(nI == 1,"Contratos Estipulados","Contratos não Estipulados")
				PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
				lRet := PRINTCOE(aResult[2],cValToChar(nI),.T.) //Recebe Resultado da Query e Monta Relatório
			EndIf
		next nI

	Else
		cTitulo 	:= "Contratos Estipulados"
		PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

		lRet := PRINTCOE(aResult[2],,.F.) //Recebe Resultado da Query e Monta Relatório

	EndIf
	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

Static Function PRINTCOE(aValores,cTipo,lNew)

	Local lRet		:= .T.
	Local nI		:= 1
	Local nLinha	:= 105
	Local nTotFat	:= 0
	Local cTitulo 	:= ""
	Local cCampo1	:= 'Núm.Registro Operadora'
	Local cCampo2	:= 'Total do Faturamento'
	Local cCampo3   := ""
	Local nTotVid   := 0
	Default cTipo   := ""
	Default lNew    := .F.

	If lNew
		cCampo2	:= 'Qtd de Vidas Administradas*'
		cCampo3   := 'Contraprestação a Repassar - R$'
	EndIf

	cTitulo 	:= IIF(cTipo == "1",'Contratos Estipulados',IIF(lNew,'Contratos não Estipulados','Contratos Estipulados'))

	Cabec1(@nLinha, cCampo1, cCampo2,cCampo3,lNew)

	For nI := 1 to Len( aValores )
		If cTipo == "1"
			If aValores[nI,4]=="1"
				If nLinha >= 580
					oReport:EndPage()
					PlsRDCab(cTitulo)
					nLinha	:= 105
					Cabec1(@nLinha, cCampo1, cCampo2,cCampo3,lNew)
				EndIf

				oReport:Say(nLinha, 050, aValores[nI,1], oFnt12C)		// N.o Reg ANS
				oReport:Say(nLinha, 380, Padl(Transform(aValores[nI,2],QUANTI),10), oFnt12L)
				oReport:Say(nLinha, 670, PadL(Transform(aValores[nI,3],Moeda),20), oFnt12L)

				nTotFat	+= aValores[nI,3]
				nTotVid	+= aValores[nI,2]
				nLinha += 15
			EndIf
		ElseIf cTipo == "2"
			If aValores[nI,4]=="2"
				If nLinha >= 580
					oReport:EndPage()
					PlsRDCab(cTitulo)
					nLinha	:= 105
					Cabec1(@nLinha, cCampo1, cCampo2,cCampo3,lNew)
				EndIf

				oReport:Say(nLinha, 050, aValores[nI,1], oFnt12C)		// N.o Reg ANS
				oReport:Say(nLinha, 380, Padl(Transform(aValores[nI,2],QUANTI),10), oFnt12L)
				oReport:Say(nLinha, 670, PadL(Transform(aValores[nI,3],Moeda),20), oFnt12L)

				nTotFat	+= aValores[nI,3]
				nTotVid	+= aValores[nI,2]
				nLinha += 15
			EndIf
		Else
			If nLinha >= 580
				oReport:EndPage()
				PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
				nLinha	:= 105
				Cabec1(@nLinha, cCampo1, cCampo2,cCampo3,lNew)
			EndIf

			oReport:Say(nLinha, 050, aValores[nI,1], oFnt12C)		// N.o Reg ANS
			oReport:Say(nLinha, 200, PadL(Transform(aValores[nI,2], Moeda),20), oFnt12L)		// "Consulta Médica"
			nTotFat	+= aValores[nI,2]
			nLinha += 15
		EndIf

	Next

	If nLinha >= 580
		oReport:EndPage()
		PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
		nLinha	:= 105
		Cabec1(@nLinha, cCampo1, cCampo2,cCampo3,lNew)
	EndIf

	oReport:Say(nLinha, 023, 'TOTAL', oFnt12N)		// N.o Reg ANS
	If lNew
		oReport:Say(nLinha, 325, PadL(Transform(nTotVid,QUANTI1),20), oFnt12T)
	EndIf

	oReport:Say(nLinha, IIF(lNew,670,200), PadL(Transform(nTotFat, Moeda),20), oFnt12T)

Return lRet

Static Function PLSDCOE(lAtu22)
	Local nCount	:= 0
	Local aRetCOE	:= 	{}
	Local cSql 		:= ""
	Default lAtu22  := .F.

	If !lAtu22
		cSql := " SELECT BUP_OPECOE, BUP_VLRFAT "
	Else
		cSql := " SELECT BUP_OPECOE, BUP_QTDVIA, BUP_CONREP, BUP_CONESP "
	EndIf
	cSql += " FROM " + RetSqlName("BUP")
	cSql += " WHERE BUP_FILIAL = '" + xFilial("BUP") + "' "
	cSql += " AND BUP_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUP_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUP_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BUP_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	If !lAtu22
		cSql += " ORDER BY BUP_OPECOE "
	Else
		cSql += " ORDER BY BUP_CONESP, BUP_OPECOE "
	EndIf
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOE",.F.,.T.)
	iF !lAtu22
		TcSetField("TRBCOE", "BUP_VLRFAT",  "N", 16, 2 )
	EndIf

	If !TRBCOE->(Eof())
		TRBCOE->(dbGoTop())
		Do While !TRBCOE->(Eof())
			nCount++
			iF !lAtu22
				aAdd( aRetCOE, { TRBCOE->BUP_OPECOE, TRBCOE->BUP_VLRFAT } )
			Else
				aAdd( aRetCOE, { TRBCOE->BUP_OPECOE, TRBCOE->BUP_QTDVIA, TRBCOE->BUP_CONREP,BUP_CONESP } )
			EndIf
			TRBCOE->(DbSkip())
		EndDo
	EndIf
	TRBCOE->(DbCloseArea())

Return( { nCount>0 , aRetCOE } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cabec1

Função para facilitar a impressão de cabeçalho

@author Roger C
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Cabec1(nLinha, cCampo1, cCampo2,cCampo3,lNew)

	Default nLinha	:= 105
	Default cCampo1	:= ''
	Default cCampo2 := ''
	Default cCampo3 := ''
	Default lNew    := .F.

	oReport:box(nLinha+5, 020, nLinha-10, 805) // Box

	oReport:Say(nLinha, 023, cCampo1, oFnt12N)
	If lNew
		oReport:Say(nLinha, 650, cCampo3, oFnt12N)
		oReport:Say(nLinha, 350, cCampo2, oFnt12N)
	Else
		oReport:Say(nLinha, 217, cCampo2, oFnt12N)
	EndIf
	nLinha += 15

Return
