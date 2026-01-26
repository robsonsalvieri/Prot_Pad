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
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C := TFont():New("Arial",10,10,,.F., , , , .t., .f.)
STATIC oFnt10N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt10L := TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt10T := TFont():New("MS LineDraw Regular",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C := TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12N := TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",14,14,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDEVIN

Relatório do Quadro Movimentação de Eventos Indenizáveis

@author Roger C
@since 22/01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDEVIN(lTodosQuadros,lAuto)
	
	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - Movimentação de Eventos Indenizáveis"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		Private cTitulo   := cCadastro
		Private oReport   := nil
		Private cRelName := "DIOPS_Mov_Eventos_Indenizaveis_"+CriaTrab(NIL,.F.)
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

	Processa( {|| aResult := PLSDEVIN() }, "DIOPS - Movimentação de Eventos Indenizáveis")
	aResult:= PLSVERQRY(aResult[2])

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Movimentação de Eventos Indenizáveis')
		EndIf		
		Return
	EndIf 

	cTitulo := "Movimentação de Eventos Indenizáveis"
	PlsRDCab(cTitulo) // Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTEVIN(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

Static Function PRINTEVIN(aValores)

	Local lRet		:= .T.
	Local nI		:= 1
	Local nLinha	:= 105
	Local aTotal	:= { { 0, 0, 0 }, { 0,0,0 }, { 0,0,0 } }		 
	Local nTotLin	:= 0
	Local cMsgCabec	:= "Movimentação de Eventos Indenizáveis"
	Local cMsgTotal	:= ''
	Local nPosTotal	:= 0
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

	Cabec1(@nLinha)

	// Prepara Totalização Mensal por Grupo de Eventos para Impressão
	For nI := 1 to Len(aValores)
		Do Case
			// 33 a 46 - Total dos novos avisos reconhecidos no mes 
			Case aValores[nI,1] >= '33' .and. aValores[nI,1] <= '46'  
				nPosTotal	:= 1

			// 47 a 60 - Total de baixa por glosa reconhecidas no mes 
			Case aValores[nI,1] >= '47' .and. aValores[nI,1] <= '60'  
				nPosTotal	:= 2

			// 65 a 78 - Total de outras recuperações reconhecidas no mes 
			Case aValores[nI,1] >= '65' .and. aValores[nI,1] <= '78'  
				nPosTotal	:= 3

			// Pular Peona
			Case aValores[nI,1] == '79'
				Loop

		EndCase

		aTotal[nPosTotal,1] += aValores[nI,2]
		aTotal[nPosTotal,2] += aValores[nI,3]
		aTotal[nPosTotal,3] += aValores[nI,4]

	Next

	For nI := 1 to Len( aValores )

		If nLinha >= 572
			oReport:EndPage()
			PlsRDCab(cMsgCabec)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			Cabec1(@nLinha)
		EndIf

		// Se for o primeiro item de cada grupo de eventos, imprime o totalizador
		If aValores[nI,1] == '33' .or. aValores[nI,1] == '47' .or. aValores[nI,1] == '65' 
			If aValores[nI,1] == '33' 
				cMsgTotal := 'Total dos novos avisos reconhecidos no mês (+)'
				nPosTotal := 1
			ElseIf aValores[nI,1] == '47'
				cMsgTotal := 'Total de baixas por glosas reconhecidas no mês (-)'
				nPosTotal := 2
			Else
				cMsgTotal := 'Total de outras recuperações reconhecidas no mês'
				nPosTotal := 3
			EndIf

			nLinha += 1
			oReport:box(nLinha+5, 020, nLinha-10, 805) // Box
			oReport:Fillrect( {nLinha-10, 021, nLinha+5, 804 }, oBrush1)			
			oReport:Say(nLinha, 063, cMsgTotal, oFnt12N)						// Descrição  
			oReport:Say(nLinha, 440, PadL(Transform(aTotal[nPosTotal,1], Moeda),20), oFnt10T)		// Valor Mes 3
			oReport:Say(nLinha, 528, PadL(Transform(aTotal[nPosTotal,2], Moeda),20), oFnt10T)		// Valor Mes 2
			oReport:Say(nLinha, 618, PadL(Transform(aTotal[nPosTotal,3], Moeda),20), oFnt10T)		// Valor Mes 1

			nTotLin := aTotal[nPosTotal,1]+aTotal[nPosTotal,2]+aTotal[nPosTotal,3]
			oReport:Say(nLinha, 708, PadL(Transform(nTotLin, Moeda),20), oFnt10T)		// "TOTAL"
			nLinha += 15
			
		EndIf

		If nLinha >= 572
			oReport:EndPage()
			PlsRDCab(cMsgCabec)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			Cabec1(@nLinha)
		EndIf

		oReport:box(nLinha+5, 020, nLinha-10, 805) // Box

		// Se for PEONA faz acabamento assurado 
		If aValores[nI,1] == '79'
			oReport:Fillrect( {nLinha-10, 021, nLinha+5, 804 }, oBrush1)
			oReport:box(nLinha+5, 020, nLinha-10, 805) // Box

		EndIf			

		oReport:Say(nLinha, 022, aValores[nI,1], oFnt12C)			// Código  
		oReport:Say(nLinha, 063, getInfoCdEve(aValores[nI,1]), oFnt12C)			// Descrição  
		oReport:Say(nLinha, 440, PadL(Transform(aValores[nI,2], Moeda),20), oFnt10L)		// Valor Mes 3
		oReport:Say(nLinha, 528, PadL(Transform(aValores[nI,3], Moeda),20), oFnt10L)		// Valor Mes 2
		oReport:Say(nLinha, 618, PadL(Transform(aValores[nI,4], Moeda),20), oFnt10L)		// Valor Mes 1

		nTotLin := aValores[nI,2]+aValores[nI,3]+aValores[nI,4]
		oReport:Say(nLinha, 708, PadL(Transform(nTotLin, Moeda),20), oFnt10L)		// "TOTAL"

		// Antes da PEONA dá um salto maior
		nLinha += IIf(aValores[nI,1] == '78', 30, 15 )

	Next

Return lRet

Static Function PLSDEVIN()

	Local nCount	:= 0
	Local aRetEVIN	:= 	{}
	Local cSql 		:= ""
	Local lRet 		:= .T.

	cSql := " SELECT B8L_CODIGO, B8L_VLMES1, B8L_VLMES2, B8L_VLMES3 "
	cSql += " FROM " + RetSqlName("B8L")
	cSql += " WHERE B8L_FILIAL = '" + xFilial("B8L") + "' " 
	cSql += " AND B8L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8L_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8L_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8L_CODIGO IN ('33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79') "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8L_CODIGO " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEVI",.F.,.T.)
	TcSetField("TRBEVI", "B8L_VLMES1",  "N", 16, 2 )
	TcSetField("TRBEVI", "B8L_VLMES2",  "N", 16, 2 )
	TcSetField("TRBEVI", "B8L_VLMES3",  "N", 16, 2 )

	If !TRBEVI->(Eof())
		TRBEVI->(dbGoTop())
		Do While !TRBEVI->(Eof())
			nCount++
			aAdd( aRetEVIN, { TRBEVI->B8L_CODIGO, TRBEVI->B8L_VLMES3, TRBEVI->B8L_VLMES2, TRBEVI->B8L_VLMES1 } )
			TRBEVI->(DbSkip())		
		EndDo
	EndIf
	TRBEVI->(DbCloseArea())

Return( { nCount>0 , aRetEVIN } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cabec1

Função para facilitar a impressão de cabeçalho

@author Roger C
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Cabec1(nLinha)

	Local aMes := { 'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez' }
	Local nMes	:= Val(B3DRefere())			// Vai me retornar 1, 2, 3 ou 4 conforme o trimestre selecionado.
	Default nLinha	:= 105

	cMes3	:= aMes[nMes*3]		// 3, 6, 9, 12
	cMes2	:= aMes[nMes*3-1]	// 2, 5, 8, 11 
	cMes1	:= aMes[nMes*3-2]	// 1, 4, 7, 10	

	oReport:box(nLinha+5, 020, nLinha-10, 445) // Box
	oReport:Say(nLinha, 022, "Código", oFnt12N)

	oReport:Say(nLinha, 063, "Descrição", oFnt12N)

	oReport:box(nLinha+5, 445, nLinha-10, 535) // Box
	oReport:Say(nLinha, 450, B3D->B3D_ANO+'/'+cMes3, oFnt12N)

	oReport:box(nLinha+5, 535, nLinha-10, 625) // Box
	oReport:Say(nLinha, 540, B3D->B3D_ANO+'/'+cMes2, oFnt12N)

	oReport:box(nLinha+5, 625, nLinha-10, 715) // Box
	oReport:Say(nLinha, 630, B3D->B3D_ANO+'/'+cMes1, oFnt12N)

	oReport:box(nLinha+5, 715, nLinha-10, 805) // Box
	oReport:Say(nLinha, 720, "Total Período", oFnt12N)

	nLinha += 15

Return                                 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVERQRY

Função para facilitar a impressão de cabeçalho

@author José Paulo
@since 16/07/2019
/*/
//--------------------------------------------------------------------------------------------------

Static Function PLSVERQRY(aRes)

	Local aResult := {}  
	Local nI      := 0
	Local lRet    := .T.
	Local nJ      := 0
	Default aRes  := {}
	
	aAdd(aResult,{"33",0,0,0 } )
	aAdd(aResult,{"34",0,0,0 } )
	aAdd(aResult,{"35",0,0,0 } )
	aAdd(aResult,{"36",0,0,0 } )
	aAdd(aResult,{"37",0,0,0 } )
	aAdd(aResult,{"38",0,0,0 } )
	aAdd(aResult,{"39",0,0,0 } )
	aAdd(aResult,{"40",0,0,0 } )
	aAdd(aResult,{"41",0,0,0 } )
	aAdd(aResult,{"42",0,0,0 } )
	aAdd(aResult,{"43",0,0,0 } )
	aAdd(aResult,{"44",0,0,0 } )
	aAdd(aResult,{"45",0,0,0 } )
	aAdd(aResult,{"46",0,0,0 } )
	aAdd(aResult,{"47",0,0,0 } )
	aAdd(aResult,{"48",0,0,0 } )
	aAdd(aResult,{"49",0,0,0 } )
	aAdd(aResult,{"50",0,0,0 } )
	aAdd(aResult,{"51",0,0,0 } )
	aAdd(aResult,{"52",0,0,0 } )
	aAdd(aResult,{"53",0,0,0 } )
	aAdd(aResult,{"54",0,0,0 } )
	aAdd(aResult,{"55",0,0,0 } )
	aAdd(aResult,{"56",0,0,0 } )
	aAdd(aResult,{"57",0,0,0 } )
	aAdd(aResult,{"58",0,0,0 } )
	aAdd(aResult,{"59",0,0,0 } )
	aAdd(aResult,{"60",0,0,0 } )
	aAdd(aResult,{"65",0,0,0 } )
	aAdd(aResult,{"66",0,0,0 } )
	aAdd(aResult,{"67",0,0,0 } )
	aAdd(aResult,{"68",0,0,0 } )
	aAdd(aResult,{"69",0,0,0 } )
	aAdd(aResult,{"70",0,0,0 } )
	aAdd(aResult,{"71",0,0,0 } )
	aAdd(aResult,{"72",0,0,0 } )
	aAdd(aResult,{"73",0,0,0 } )
	aAdd(aResult,{"74",0,0,0 } )
	aAdd(aResult,{"75",0,0,0 } )
	aAdd(aResult,{"76",0,0,0 } )
	aAdd(aResult,{"77",0,0,0 } )
	aAdd(aResult,{"78",0,0,0 } )
	
	For nI:=1 To Len(aResult)                  
		For nJ:=1 To Len(aRes) 
			If aResult[nI,1] == aRes[nJ,1] 
				aResult[nI,2]:=aRes[nJ,2]
				aResult[nI,3]:=aRes[nJ,3]
				aResult[nI,4]:=aRes[nJ,4]
			EndIf					   			
		Next
	Next

Return({lRet,aClone(aResult)})

