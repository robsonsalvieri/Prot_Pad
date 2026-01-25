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
/*/{Protheus.doc} PLSRDSMCR

Geração de arquivo PDF. DIOPS - Segregação do Montante de Contraprestações a Repassar

@author RogerC
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDSMCR(lTodosQuadros, lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - Segreg.Montante Contraprestações a Repassar"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.

	If !lTodosQuadros
		
		Private cPerg     := "DIOPSINT"
		Private cTitulo   := cCadastro
		Private oReport   := nil
		Private cFileName := "DIOPS_Seg_Mont_Contr_Repassar_"+CriaTrab(NIL,.F.)
		Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

        If !lAuto
    	    Pergunte(cPerg,.F.)            
        EndIf

		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)
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

	Processa( {|| aResult := PLSDSMCR() }, cCadastro)

	// Se não há dados a apresentar
	If !aResult[1]
        If !lAuto
			MsgAlert('Não há dados a apresentar referente a '+cCadastro)
        EndIf	
		Return
	EndIf 

	PlsRDCab("Segregação do Montante de Contraprestações a Repassar")		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTSMCR(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf
	
Return

Static Function PRINTSMCR(aValores)

	Local lRet		:= .T.
	Local nI		:= 1
	Local nLinha	:= 105
	Local aTotal	:= { 0, 0, 0 }		 
	Local nTotLin	:= 0
	Local cMsgCabec	:= "Segregação do Montante de Contraprestações a Repassar"
	Local cMsgTotal	:= ''
	Local nPosTotal	:= 0
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

	Cabec1(@nLinha)

	// Prepara Totalização Mensal
	For nI := 1 to Len(aValores)

		aTotal[1] += aValores[nI,2]
		aTotal[2] += aValores[nI,3]
		aTotal[3] += aValores[nI,4]

	Next

	For nI := 1 to Len( aValores )

		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab(cMsgCabec)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
			Cabec1(@nLinha)
		EndIf

		oReport:box(nLinha+5, 020, nLinha-10, 805) // Box

		oReport:Say(nLinha, 023, getInfoSMCR(aValores[nI,1]), oFnt12C)						// Descrição  
		oReport:Say(nLinha, 375, PadL(Transform(aValores[nI,2], Moeda),20), oFnt10L)		// Valor Mes 3
		oReport:Say(nLinha, 489, PadL(Transform(aValores[nI,3], Moeda),20), oFnt10L)		// Valor Mes 2
		oReport:Say(nLinha, 597, PadL(Transform(aValores[nI,4], Moeda),20), oFnt10L)		// Valor Mes 1

		nTotLin := aValores[nI,2]+aValores[nI,3]+aValores[nI,4]
		oReport:Say(nLinha, 708, PadL(Transform(nTotLin, Moeda),20), oFnt10L)		// "TOTAL"

		// Antes da PEONA dá um salto maior
		nLinha += IIf(aValores[nI,1] == '78', 30, 15 )	

	Next

	// Imprime o totalizador
	cMsgTotal	:= 'Total da Segregação de Montantes de Contraprestações a Repassar'

	nLinha += 1
	oReport:box(nLinha+5, 020, nLinha-10, 805) // Box
	oReport:Fillrect( {nLinha+4, 021, nLinha-9, 804 }, oBrush1)			
	oReport:Say(nLinha, 023, cMsgTotal, oFnt12N)						// Descrição  
	oReport:Say(nLinha, 375, PadL(Transform(aTotal[1], Moeda),20), oFnt10T)		// Valor Mes 3
	oReport:Say(nLinha, 489, PadL(Transform(aTotal[2], Moeda),20), oFnt10T)		// Valor Mes 2
	oReport:Say(nLinha, 597, PadL(Transform(aTotal[3], Moeda),20), oFnt10T)		// Valor Mes 1

	nTotLin := aTotal[1]+aTotal[2]+aTotal[3]
	oReport:Say(nLinha, 708, PadL(Transform(nTotLin, Moeda),20), oFnt10T)		// "TOTAL"
	nLinha += 15

Return lRet

Static Function PLSDSMCR()

	Local nCount	:= 0
	Local aRetSMCR	:= 	{}

	Local cSql 		:= ""
	Local lRet 		:= .T.

	cSql := " SELECT BVS_CODIGO, BVS_VLMES1, BVS_VLMES2, BVS_VLMES3 "
	cSql += " FROM " + RetSqlName("BVS")
	cSql += " WHERE BVS_FILIAL = '" + xFilial("BVS") + "' " 
	cSql += " AND BVS_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BVS_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BVS_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BVS_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BVS_CODIGO " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMCR",.F.,.T.)
	TcSetField("TRBMCR", "BVS_VLMES1",  "N", 16, 2 )
	TcSetField("TRBMCR", "BVS_VLMES2",  "N", 16, 2 )
	TcSetField("TRBMCR", "BVS_VLMES3",  "N", 16, 2 )

	If !TRBMCR->(Eof())
		TRBMCR->(dbGoTop())
		Do While !TRBMCR->(Eof())
			nCount++
			aAdd( aRetSMCR, { TRBMCR->BVS_CODIGO, TRBMCR->BVS_VLMES3, TRBMCR->BVS_VLMES2, TRBMCR->BVS_VLMES1 } )
			TRBMCR->(DbSkip())		
		EndDo
	EndIf
	TRBMCR->(DbCloseArea())

Return( { nCount>0 , aRetSMCR } )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cabec1

Função para facilitar a impressão de cabeçalho

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Cabec1(nLinha)

	Local aMes := { 'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez' }
	Local nMes	:= Val(B3DRefere())			// Vai me retornar 1, 2, 3 ou 4 conforme o trimestre selecionado.
	Default nLinha	:= 105

	cMes3 := aMes[nMes*3]		// 3, 6, 9, 12
	cMes2 := aMes[nMes*3-1]	// 2, 5, 8, 11 
	cMes1 := aMes[nMes*3-2]	// 1, 4, 7, 10	

	oReport:box(nLinha+5, 020, nLinha-10, 361) // Box
	oReport:Say(nLinha, 023, "Débitos de Operações de Administração de Beneficios", oFnt12N)

	oReport:box(nLinha+5, 361, nLinha-10, 472) // Box
	oReport:Say(nLinha, 366, B3D->B3D_ANO+'/'+cMes3, oFnt12N)

	oReport:box(nLinha+5, 472, nLinha-10, 586) // Box
	oReport:Say(nLinha, 477, B3D->B3D_ANO+'/'+cMes2, oFnt12N)

	oReport:box(nLinha+5, 586, nLinha-10, 694) // Box
	oReport:Say(nLinha, 591, B3D->B3D_ANO+'/'+cMes1, oFnt12N)

	oReport:box(nLinha+5, 694, nLinha-10, 805) // Box
	oReport:Say(nLinha, 699, "Total Período", oFnt12N)

	nLinha += 15

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getInforSMCR

Função de retorno da descrição

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function getInfoSMCR(cCodigo)
Local cRet	:= ''
Default cCodigo := '' 

Do Case
	Case cCodigo == '1'
		cRet	:= 'Vencidos até 30 dias'
	Case cCodigo == '2'
		cRet	:= 'Vencidos há mais de 30 dias e até 60 dias'
	Case cCodigo == '3'
		cRet	:= 'Vencidos há mais de 60 dias e até 90 dias'	
	Case cCodigo == '4'
		cRet	:= 'Vencidos há mais de 90 dias'	
	Case cCodigo == '7'
		cRet	:= 'A Vencer'	
	OtherWise
		cRet := 'Código não encontrado'
EndCase 	

Return(cRet)
