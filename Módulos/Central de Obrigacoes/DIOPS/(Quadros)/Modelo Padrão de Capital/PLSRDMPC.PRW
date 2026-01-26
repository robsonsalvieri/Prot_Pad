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
#Define Qtd   "@E 999,999,999,999,999"

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
/*/{Protheus.doc} PLSRDMPC

Relatório do Quadro Modelo Padrão de Capital

@author lima.everton
@since 22/01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDMPC(lTodosQuadros, lAuto)
    
    Local aSays		:= {}
    Local aButtons	:= {}
    Local cCadastro := "DIOPS - Modelo Padrão de Capital"
    Local aResult	:= {}

    DEFAULT lTodosQuadros := .F.
    DEFAULT lAuto         := .F.

    If !lTodosQuadros

    	Private cPerg	  := "DIOPSINT"
    	PRIVATE cTitulo   := cCadastro
    	PRIVATE oReport   := nil
    	PRIVATE cFileName := "DIOPS_Modelo_Padrao_Capital_"+CriaTrab(NIL,.F.)
    	PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

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

    Processa( {|| aResult := PLSDMPC() }, "DIOPS - Modelo Padrão de Capital")

    // Se não há dados a apresentar
    If !aResult[1]
        If !lAuto
    	    MsgAlert('Não há dados a apresentar referente a Modelo Padrão de Capital')
        EndIf
    	Return
    EndIf 

    cTitulo := "Modelo Padrão de Capital"
    PlsRDCab(cTitulo)  // Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

    lRet := PRINTMPC(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

    If !lTodosQuadros .and. lRet
    	oReport:EndPage()
    	oReport:Print()
    EndIf

Return

Static Function PRINTMPC(aValores)

    Local lRet		:= .T.
    Local nI		:= 1
    Local nLinha	:= 105
    Local aTotal	:= { { 0, 0, 0 }, { 0,0,0 }, { 0,0,0 } }		 
    Local nTotLin	:= 0
    Local cMsgCabec	:= "Modelo Padrão de Capital"
    Local cMsgTotal	:= ''
    Local nPosTotal	:= 0
    Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

    Cabec1(@nLinha)

    If nLinha >= 580
    	oReport:EndPage()
    	PlsRDCab(cMsgCabec)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
    	nLinha	:= 110
    	Cabec1(@nLinha)
    EndIf

    oReport:box(nLinha, 020, nLinha+25, 805)
    oReport:box(nLinha, 580, nLinha+25, 805)    
    oReport:Say(nLinha+10, 023 , "Soma das contraprestações dos últimos doze meses dos beneficiários da remissão, não remidos, em ", oFnt10L)
    oReport:Say(nLinha+20, 023 , "contratos com remissão temporária; ", oFnt10L)
    oReport:Say(nLinha+20, 708 , PadL(Transform(aValores[1,1], Moeda),20), oFnt10L)
    
    nLinha+=25
    
    oReport:box(nLinha, 020, nLinha+25, 805)
    oReport:box(nLinha, 580, nLinha+25, 805)
    oReport:Say(nLinha+10, 023 , "Soma das contraprestações dos últimos doze meses dos beneficiários da remissão, não remidos, em ", oFnt10L)
    oReport:Say(nLinha+20, 023 , "contratos com remissão vitalícia; ", oFnt10L)    
    oReport:Say(nLinha+20, 708 , PadL(Transform(aValores[1,2], Moeda),20), oFnt10L)
    
    nLinha+=25
    
    oReport:box(nLinha, 020, nLinha+15, 805)
    oReport:box(nLinha, 580, nLinha+15, 805)    
    oReport:Say(nLinha+10, 023 , "Número de beneficiários remidos de contratos com remissão temporária;", oFnt10L)
    oReport:Say(nLinha+10, 708 , PadL(Transform(aValores[1,3], Qtd),20), oFnt10L)
    
    nLinha+=15
    
    oReport:box(nLinha, 020, nLinha+15, 805)
    oReport:box(nLinha, 580, nLinha+15, 805)    
    oReport:Say(nLinha+10, 023 , "Número de beneficiários remidos de contratos com remissão vitalícia;", oFnt10L)
    oReport:Say(nLinha+10, 708 , PadL(Transform(aValores[1,4], Qtd),20), oFnt10L)
    
    nLinha+=15
    
    oReport:box(nLinha, 020, nLinha+25, 805)
    oReport:box(nLinha, 580, nLinha+25, 805)    
    oReport:Say(nLinha+10, 023 , "Soma dos valores das expectativas de despesa de assistência à saúde de dos beneficiários remidos, em ", oFnt10L)
    oReport:Say(nLinha+20, 023 , "contratos com remissão temporária, nos doze meses subsequentes; ", oFnt10L)
    oReport:Say(nLinha+20, 708 , PadL(Transform(aValores[1,5], Moeda),20), oFnt10L)
    
    nLinha+=25
    
    oReport:box(nLinha, 020, nLinha+25, 805)
    oReport:box(nLinha, 580, nLinha+25, 805)    
    oReport:Say(nLinha+10, 023 , "Soma dos valores das expectativas de despesa de assistência à saúde dos beneficiários remidos, em ", oFnt10L)
    oReport:Say(nLinha+20, 023 , "contratos com remissão vitalícia, nos doze meses subsequentes; ", oFnt10L)
    oReport:Say(nLinha+20, 708 , PadL(Transform(aValores[1,6], Moeda),20), oFnt10L)
    
    nLinha+=25    

Return lRet

Static Function PLSDMPC()

    Local nCount	:= 0
    Local aRetMPC	:= 	{}
    Local cSql 		:= ""
    Local lRet 		:= .T.

    cSql := " SELECT B82_SMRMTP,B82_SMRMVI,B82_NMRMTP,B82_NMRMVI,B82_SMDETP,B82_SMDEVI "
    cSql += " FROM " + RetSqlName("B82")
    cSql += " WHERE B82_FILIAL = '" + xFilial("B82") + "' " 
    cSql += " AND B82_CODOPE = '" + B3D->B3D_CODOPE + "' "
    cSql += " AND B82_CODOBR = '" + B3D->B3D_CDOBRI + "' "
    cSql += " AND B82_ANOCMP = '" + B3D->B3D_ANO + "' "
    cSql += " AND B82_CDCOMP = '" + B3D->B3D_CODIGO + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMPC",.F.,.T.)
    TcSetField("TRBMPC", "B82_SMRMTP",  "N", 16, 2 )
    TcSetField("TRBMPC", "B82_SMRMVI",  "N", 16, 2 )
    TcSetField("TRBMPC", "B82_NMRMTP",  "N", 16, 2 )
    TcSetField("TRBMPC", "B82_NMRMVI",  "N", 16, 2 )
    TcSetField("TRBMPC", "B82_SMDETP",  "N", 16, 2 )
    TcSetField("TRBMPC", "B82_SMDEVI",  "N", 16, 2 )

    If !TRBMPC->(Eof())
    	TRBMPC->(dbGoTop())
    	Do While !TRBMPC->(Eof())
    		nCount++
    		aAdd( aRetMPC, { TRBMPC->B82_SMRMTP, TRBMPC->B82_SMRMVI, TRBMPC->B82_NMRMTP, TRBMPC->B82_NMRMVI, TRBMPC->B82_SMDETP, TRBMPC->B82_SMDEVI } )
    		TRBMPC->(DbSkip())		
    	EndDo
    EndIf
    TRBMPC->(DbCloseArea())

Return( { nCount > 0 , aRetMPC } )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cabec1

Função para facilitar a impressão de cabeçalho

@author lima.everton
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Cabec1(nLinha)

    Local nMes	:= Val(B3DRefere())			// Vai me retornar 1, 2, 3 ou 4 conforme o trimestre selecionado.
    Default nLinha	:= 105
    
    oReport:box(nLinha+15, 020, nLinha, 580) // Box
    oReport:Say(nLinha+11, 023 , "Descrição da informação requerida", oFnt12N)

    oReport:box(nLinha+15, 580, nLinha, 805) // Box
    oReport:Say(nLinha+11, 583, "Valores apurados ao fim do trimestre", oFnt12N)

    nLinha += 15

Return
