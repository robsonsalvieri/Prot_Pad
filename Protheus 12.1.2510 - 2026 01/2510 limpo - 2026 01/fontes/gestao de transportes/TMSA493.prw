#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TMSA493.CH'

#DEFINE SIMP_STMARKA 01
#DEFINE SIMP_TES     02
#DEFINE SIMP_UFINI   03
#DEFINE SIMP_UFFIM   04
#DEFINE SIMP_MUNFIM  05
#DEFINE SIMP_VALTOT  06
#DEFINE SIMP_DETTELA 07
#DEFINE SIMP_DETDOC  08
#DEFINE SIMP_FILDOC  09
#DEFINE SIMP_DOC     10
#DEFINE SIMP_SERIE   11
#DEFINE SIMP_COLS1   {"","ST",STR0001,STR0032,STR0002,STR0003,STR0004} //--"TES","UF Inic.","UF Final","Municipio Final","Frete Total"
#DEFINE SIMP_TAMCOL1 {05,05,10,10,10,30,60}
#DEFINE SIMP_COLS2   {"","ST",STR0005,STR0006,STR0007} //--"Filial","Documento","Serie"
#DEFINE SIMP_TAMCOL2 {05,05,30,40,20,}
#DEFINE DET_MARKA  1
#DEFINE DET_FILDOC 2
#DEFINE DET_DOC    3
#DEFINE DET_SERIE  4
#DEFINE DET_REM    5
#DEFINE DET_DES    6
#DEFINE DET_REMDES 7
#DEFINE DET_FILORI 8
#DEFINE DET_VIAGEM 9


#DEFINE DET_COLS   {"",STR0005,STR0006,STR0007,STR0008,STR0009,"Origem","Viagem"} //--"Filial","Documento","Serie","Remetente","Destinatario"
#DEFINE DET_TAMCOL {05,30,40,20,70,70,40,40}

/*/{Protheus.doc} TMSA493
CT-e Simplificado - Rotina de Manutenção
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Function TMSA493()
    Local oBrowse

    Private cCadastro := STR0010 //--"CT-e Simplificado"
    Private aRotina := MenuDef()
    
    //DT6_SITCTE = 0=Nao Se Aplica;1=Aguardando;2=Autorizado;3=Nao Autorizado;4=Em Contingencia;5=Falha Comunicacao;6=Nao Transmitido

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('DT6')
    oBrowse:SetDescription(cCadastro)
    oBrowse:AddLegend( "Empty(DT6_NUM) .And. DT6_DOCTMS == 'U'"                                    , "Green" , STR0011 ) //--"Apoio sem Simplificado"
    oBrowse:AddLegend( "!Empty(DT6_NUM) .And. DT6_DOCTMS == 'U'"                                   , "Black" , STR0012 ) //--"Apoio com Simplificado Calculado"
    oBrowse:AddLegend( "DT6_DOCTMS == 'S' .And. !(DT6_STATUS $ 'B,D') .And. DT6_SITCTE $ '0,1,4,6'", "Orange", STR0013 ) //--"CT-e Simplificado Não Transmitido"
    oBrowse:AddLegend( "DT6_DOCTMS == 'S' .And. !(DT6_STATUS $ 'B,D') .And. DT6_SITCTE == '2'"     , "Blue"  , STR0014 ) //--"CT-e Simplificado Autorizado"
    oBrowse:AddLegend( "DT6_DOCTMS == 'S' .And. !(DT6_STATUS $ 'B,D') .And. DT6_SITCTE $ '3,5'"    , "Red"   , STR0015 ) //--"CT-e Simplificado Não Autorizado"
    oBrowse:AddLegend( "DT6_DOCTMS == 'S' .And. DT6_STATUS $ 'B,D'"                                , "Yellow", STR0033 ) //--"CT-e Simplificado Aguardando Cancelamento SEFAZ"
    oBrowse:SetFilterDefault( "DT6_DOCTMS == 'U' .Or. DT6_DOCTMS == 'S'")
    oBrowse:DisableDetails()

    oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
CT-e Simplificado - Menu
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE STR0016 ACTION 'TMSA493Mnt(2)' OPERATION 2 ACCESS 0 //--"Visualizar"
    ADD OPTION aRotina TITLE STR0017 ACTION 'TMSA493Mnt(3)' OPERATION 6 ACCESS 0 //--"Calcular"
    ADD OPTION aRotina TITLE STR0018 ACTION 'TMSA493Mnt(7)' OPERATION 7 ACCESS 0 //--"Cancelar"
    ADD OPTION aRotina TITLE STR0031 ACTION 'TMSAE70(1)'    OPERATION 2 ACCESS 0 //--"Ct-e"
Return aRotina

/*/{Protheus.doc} TMSA493Mnt
Função principal de manutenção
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Function TMSA493Mnt( nOpcx )

    If nOpcx == 2
        If Empty( DT6->DT6_NUM )
            SetFunName("TMSA500")
            TmsA500Mnt( "DT6", DT6->(RecNo()), 1 )
            SetFunName("TMSA493")
        Else
            TMSA493Cal(,,,nOpcx)
        EndIf
    ElseIf nOpcx == 3
        If DT6->DT6_DOCTMS == 'S'
            Help(" ", 1,"TMSA49301") //--CT-e Simplificado já calculado. //--Selecione um documento de apoio sem simplificado.
        ElseIf DT6->DT6_DOCTMS == 'U'.And. !Empty(DT6->DT6_NUM)
            Help(" ", 1,"TMSA49302") //--CT-e Simplificado já calculado. //--Selecione um documento de apoio sem simplificado.
        Else
            TMSA493Cal()
        EndIf
    ElseIf nOpcx == 7
        If DT6->DT6_DOCTMS == 'U'.And. Empty(DT6->DT6_NUM)
            Help(" ", 1,"TMSA49306") //--CT-e Simplificado não calculado. //--Para cancelar o documento de apoio utilize a rotina de manutenção de documentos.
        ElseIf DT6->DT6_STATUS $ "B,D"
            Help(" ", 1,"TMSA49307") //--CT-e Simplificado aguardando cancelamento SEFAZ. //--Transmita o cancelamento para a SEFAZ e aguarde o retorno.
        Else
            TMSA493Cal(,,,nOpcx)
        EndIf
    EndIf

Return

/*/{Protheus.doc} TMSA493Cal
Rotina de calculo do CT-e Simplificado
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Function TMSA493Cal(cFilDoc,cDoc,cSerie,nOpcx)
    Local aAreas    := { SA1->(GetArea()),DUI->(GetArea()), DT6->(GetArea()), GetArea() }
    Local cAliasQry := ""
    Local cQuery    := ""
    Local aDocSim   := {}
    Local cTES      := ""
    Local cProduto  := ""
    Local lFiscalOk := .F.
    Local nPosSim   := 0
    Local nOpcA     := 0
    Local cCliDEV   := ""
    Local cLojDEV   := ""
    Local cTipFre   := ""
    Local cServic   := ""
    Local cPrefDT6  := ""
    Local aButtons  := {}
    Local cNome     := ""
    Local cRemDes   := ""
    Local oQry  As Object
    Local oDlg  As Object
    Local oSimp As Object
    Local oDet  As Object

    DEFAULT cFilDoc := DT6->DT6_FILDOC
    DEFAULT cDoc    := DT6->DT6_DOC
    DEFAULT cSerie  := DT6->DT6_SERIE
    DEFAULT nOpcx   := 3

	// Busca prefixo do tipo de documento Simplificado
    DUI->(DbSetOrder(1))
	If DUI->(DbSeek(xFilial("DUI")+"S"))
		cPrefDT6 := DUI->DUI_SERIE		  
	EndIf

    SD2->(DbSetOrder(3))
    DT6->(DbSetOrder(1))
    If Empty(cPrefDT6)
        Help(" ", 1,"TMSA49303") //--Tipo de Documento Simplificado não encontrado. //--Verifique a configuração do documento CT-e simplificado ("S").
    ElseIf DT6->( MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie ) )
        cCliDEV   := DT6->DT6_CLIDEV
        cLojDEV   := DT6->DT6_LOJDEV
        cTipFre   := DT6->DT6_TIPFRE
        cServic   := DT6->DT6_SERVIC
        cNome     := Posicione("SA1",1,FWxFilial("SA1")+cCliDEV+cLojDEV,"A1_NOME")
        cCondicao := SA1->A1_COND
        cQuery := "SELECT DT6.R_E_C_N_O_ AS DT6REG "
        cQuery += "FROM " + RetSQLName("DT6") + " DT6 "
        cQuery += "WHERE "
        cQuery += "DT6.DT6_FILIAL = ? AND "
        If nOpcx == 3
            cQuery += "DT6.DT6_CLIDEV = ? AND "
            cQuery += "DT6.DT6_LOJDEV = ? AND "
            cQuery += "DT6.DT6_DOCTMS = 'U' AND "
            cQuery += "DT6.DT6_NUM = ' ' AND "
        Else
            cQuery += "DT6.DT6_PREFIX = ? AND "
            cQuery += "DT6.DT6_NUM = ? AND "
            cQuery += "DT6.DT6_TIPO = ? AND "
        EndIf
        cQuery += "DT6.D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE"

        cQuery := ChangeQuery(cQuery)
        oQry := FwExecStatement():New( cQuery )
        oQry:SetString( 1, FWxFilial("DT6") )
        If nOpcx == 3
            oQry:SetString( 2, DT6->DT6_CLIDEV )
            oQry:SetString( 3, DT6->DT6_LOJDEV )
        Else
            oQry:SetString( 2, DT6->DT6_PREFIX )
            oQry:SetString( 3, DT6->DT6_NUM )
            oQry:SetString( 4, DT6->DT6_TIPO )
        EndIf
        cAliasQry := oQry:OpenAlias()
        Do While !(cAliasQry)->(Eof())
            DT6->(DbGoTo((cAliasQry)->DT6REG))

            /* - SIMP_STMARKA
            0="Ok - Não Marcado"
            1="Ok - Marcado"
            2="Quantidade Mínima de Remetentes ou Destinatarios não atendida."
            3="Mais de um produto ou regra fiscal (TES)."
            4="Ct-e Simplificado Gerado"
            */

            //Busca TES para quebra por regra fiscal e verfica se produto fiscal único.
            SD2->( MsSeek( DT6->( DT6_FILDOC + DT6_DOC + DT6_SERIE + DT6_CLIDEV + DT6_LOJDEV ) ) )
            cTES      := SD2->D2_TES
            cProduto  := SD2->D2_COD
            If nOpcx == 3
                lFiscalOk := !Empty(cTES) .And. !Empty(cProduto)
                aUFMun    := {}
                Do While lFiscalOk .And. !SD2->(Eof()) .And. DT6->( DT6_FILDOC+DT6_DOC+DT6_SERIE+DT6_CLIDEV+DT6_LOJDEV ) == ;
                                    SD2->( D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA )
                    lFiscalOk := ( cTES == SD2->D2_TES .And. cProduto == SD2->D2_COD )
                    SD2->(DbSkip())
                EndDo
                If lFiscalOk
                    aUFMun := DT6->( TMSCTUFMun(DT6_FILDOC,DT6_DOC,DT6_SERIE) )
                    If ( nPosSim := AScan( aDocSim, {|x| x[SIMP_STMARKA] == 0 .And. x[SIMP_TES]+x[SIMP_UFINI]+x[SIMP_UFFIM]+x[SIMP_MUNFIM] == cTES+aUFMun[1]+aUFMun[3]+aUFMun[4] } ) ) == 0
                        DT6->( AAdd( aDocSim, { 0, cTES, aUFMun[1], aUFMun[3], aUFMun[4], DT6_VALTOT, { RetVetDoc(.T.) }, { RetVetDoc() } } ) )
                    Else
                        aDocSim[nPosSim][SIMP_VALTOT] += DT6->DT6_VALTOT
                        DT6->( AAdd( aDocSim[nPosSim][SIMP_DETTELA], RetVetDoc(.T.) ) )
                        DT6->( AAdd( aDocSim[nPosSim][SIMP_DETDOC], RetVetDoc() ) )
                    EndIf
                Else
                    If ( nPosSim := AScan( aDocSim, {|x| x[SIMP_STMARKA] == 3 } ) ) == 0
                        DT6->( AAdd( aDocSim, { 3, "", "", "", "", DT6_VALTOT, { RetVetDoc(.T.) }, { RetVetDoc() } } ) )
                    Else
                        aDocSim[nPosSim][SIMP_VALTOT] += DT6->DT6_VALTOT
                        DT6->( AAdd( aDocSim[nPosSim][SIMP_DETTELA], RetVetDoc(.T.) ) )
                        DT6->( AAdd( aDocSim[nPosSim][SIMP_DETDOC], RetVetDoc() ) )
                    EndIf
                EndIf
            Else //Visualizar ou Excluir
                If DT6->DT6_DOCTMS == "S"
                    If Len(aDocSim) == 0
                        DT6->( AAdd( aDocSim, { 4, "", "", "", "", 0, { }, { }, DT6_FILDOC, DT6_DOC, DT6_SERIE } ) )
                    Else
                        aDocSim[1][SIMP_FILDOC] := DT6->DT6_FILDOC
                        aDocSim[1][SIMP_DOC]    := DT6->DT6_DOC
                        aDocSim[1][SIMP_SERIE]  := DT6->DT6_SERIE
                    EndIf
                Else
                    If Len(aDocSim) == 0
                        DT6->( AAdd( aDocSim, { 4, "", "", "", "", DT6_VALTOT, { RetVetDoc(.T.) }, { RetVetDoc() }, "", "", "" } ) )
                    Else
                        aDocSim[1][SIMP_VALTOT] += DT6->DT6_VALTOT
                        DT6->( AAdd( aDocSim[1][SIMP_DETTELA], RetVetDoc(.T.) ) )
                        DT6->( AAdd( aDocSim[1][SIMP_DETDOC], RetVetDoc() ) )
                    EndIf
                EndIf

            EndIf
            (cAliasQry)->(DbSkip())
        EndDo
        (cAliasQry)->(DbCloseArea())
        DbSelectArea("DT6")
        oQry:Destroy()
        oQry := Nil

        AEval( aDocSim, {|x,y| cRemDes := x[SIMP_DETTELA][1][DET_REMDES], If( x[SIMP_STMARKA] == 0 .And. (Len(x[SIMP_DETDOC]) < 2 .Or. AScan(x[SIMP_DETTELA],{|a| a[DET_REMDES] != cRemDes }) == 0 ), aDocSim[y][SIMP_STMARKA] := 2,  ) })
        ASort( aDocSim,,, {|x,y| x[SIMP_STMARKA] < y[SIMP_STMARKA] } )

        If nOpcx != 3
            Aadd(aButtons, {"DESTINOS",{|| A493VisDoc(1, oSimp, oDet, aDocSim) }, STR0019, STR0019 }) //--"Detalhes CT-e"
        EndIf
        Aadd(aButtons, {"DESTINOS",{|| A493VisDoc(2, oSimp, oDet, aDocSim) }, STR0020, STR0020 }) //--"Detalhes Apoio"

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM 2, 0 TO 40, 153  OF oMainWnd

            TSay():New( 35, 02, {|| "<b>" + STR0029 + "</b>" }, oDlg,,,,,, .T.,,, 0,10,,,,,, .T.) //--"Cliente Pagador:"
            TSay():New( 35, 47, {|| cNome }, oDlg,,,,,, .T.,,, 0,10,,,,,, .T.) //--"Mais de um produto ou regra fiscal (TES)."
            TGroup():New( 043, 002, 222, 202, STR0021, oDlg, ,, .T. ) //--"CT-e Simplificado à gerar"
            oSimp := TWBrowse():New( 48, 03, 198, 170, ,Iif( nOpcx == 3, SIMP_COLS1, SIMP_COLS2 ),;
                        Iif( nOpcx == 3, SIMP_TAMCOL1, SIMP_TAMCOL2 ), oDlg,,,,;
                        {|| AtuBrowses( oSimp, oDet, aDocSim, .T., nOpcx ) }, ;
                        {|| If( nOpcx == 3, MudaMarca(1,oSimp,oDet,aDocSim,.F.), ) }, ,,,,,,,,.T.,,,,, )
            oSimp:bHeaderClick := {|| MudaMarca(1, oSimp, oDet, aDocSim, .T. ) }
            TGroup():New( 043, 203, 222, 604, STR0022, oDlg, ,, .T. ) //--"Documentos de Apoio origem"
            oDet := TWBrowse():New( 48, 205, 398, 170, , DET_COLS, DET_TAMCOL, oDlg,,,,;
            			{|| AtuBrowses( oSimp, oDet, aDocSim, .T., nOpcx ) }, ;
            			{|| If( nOpcx == 3, MudaMarca(2,oSimp,oDet,aDocSim,.F.), ) }, ,,,,,,,,.T.,,,,, )
            AtuBrowses( oSimp, oDet, aDocSim, , nOpcx )
            TGroup():New( 235, 002, 285, 290, STR0023, oDlg, ,, .T. ) //--"Leganda"
            TBitmap():New( 245, 05, 10, 10,, "BR_VERDE", .T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
            TSay():New( 246, 15, {|| STR0023 }, oDlg,,,,,, .T.,,, 0, 10,,,,,, .T. ) //--"Pronto para gerar CT-e Simplificado."
            TBitmap():New( 255, 05, 10, 10,,"BR_AMARELO", .T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
            TSay():New( 256, 15, {|| STR0024 }, oDlg,,,,,, .T.,,, 0, 10,,,,,, .T. ) //--"Quantidade Mínima de Remetentes ou Destinatarios não atendida."
            TBitmap():New( 265, 05, 10, 10,, "BR_VERMELHO", .T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
            TSay():New( 266, 15, {|| STR0025 }, oDlg,,,,,, .T.,,, 0,10,,,,,, .T.) //--"Mais de um produto ou regra fiscal (TES)."
            TBitmap():New( 275, 05, 10, 10,, "BR_AZUL", .T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
            TSay():New( 276, 15, {|| STR0026 }, oDlg,,,,,, .T.,,, 0,10,,,,,, .T.) //--"Ct-e Simplificado Gerado"

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If( TMSA493Vld(nOpcx,aDocSim), ( nOpcA := 1, oDlg:End() ), ) },{||oDlg:End()},, aButtons )

        If nOpcA == 1
            If nOpcx == 3
                Processa( {|| GrvCTeSimp( aDocSim, cCliDEV, cLojDEV, cTipFre, cServic, cPrefDT6 ) }, STR0027 ) //--"Gerando CT-e Simplificado."
            ElseIf nOpcx == 7
                A493ExcDoc( aDocSim )
            EndIf

        EndIf

    EndIf

    AEval(aAreas, {|x| RestArea(x) })

Return

/*/{Protheus.doc} AtuBrowses
Atualização do TWBrowse
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function AtuBrowses(oSimp,oDet,aDocSim,lRefresh,nOpcx)
    Local oOk  := LoadBitmap(GetResources(), "LBOK")
    Local oNo  := LoadBitmap(GetResources(), "LBNO")
    Local oST0 As Object
    Local oST1 As Object
    Local oST2 As Object
    Local oST3 As Object
    Local oST4 As Object

    oST0 := LoadBitmap( GetResources(), "BR_VERDE" )
    oST1 := LoadBitmap( GetResources(), "BR_VERDE" )
    oST2 := LoadBitmap( GetResources(), "BR_AMARELO" )
    oST3 := LoadBitmap( GetResources(), "BR_VERMELHO" )
    oST4 := LoadBitmap( GetResources(), "BR_AZUL" )

    DEFAULT lRefresh := .F.
    DEFAULT nOpcx    := 3
    
    oSimp:SetArray(aDocSim)
    If nOpcx == 3
        oSimp:bLine := { || { Iif( aDocSim[oSimp:nAt,SIMP_STMARKA] == 0, oNo, Iif( aDocSim[oSimp:nAt,SIMP_STMARKA] == 1, oOk, "" ) ), ;
                            &("oST"+AllTrim(Str(aDocSim[oSimp:nAt,SIMP_STMARKA],1,0))), ;
                            aDocSim[oSimp:nAt,SIMP_TES],;
                            aDocSim[oSimp:nAt,SIMP_UFINI],;
                            aDocSim[oSimp:nAt,SIMP_UFFIM],;
                            aDocSim[oSimp:nAt,SIMP_MUNFIM],;
                            AllTrim(Transform(aDocSim[oSimp:nAt,SIMP_VALTOT],PesqPict("DT6","DT6_VALTOT"))) } }
    Else
        oSimp:bLine := { || { Iif( aDocSim[oSimp:nAt,SIMP_STMARKA] == 0, oNo, Iif( aDocSim[oSimp:nAt,SIMP_STMARKA] == 1, oOk, "" ) ), ;
                            &("oST"+AllTrim(Str(aDocSim[oSimp:nAt,SIMP_STMARKA],1,0))), ;
                            aDocSim[oSimp:nAt,SIMP_FILDOC],;
                            aDocSim[oSimp:nAt,SIMP_DOC],;
                            aDocSim[oSimp:nAt,SIMP_SERIE] } }
    EndIf
    oDet:SetArray(aDocSim[Iif( lRefresh, oSimp:nAt, 1 )][SIMP_DETTELA] )
    oDet:bLine := { || { Iif( nOpcx == 3, Iif( aDocSim[oSimp:nAt,SIMP_DETTELA][oDet:nAt][DET_MARKA], oOk, oNo), "" ) ,;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_FILDOC],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_DOC],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_SERIE],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_REM],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_DES],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_FILORI],;
                         aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_VIAGEM] } }
    If lRefresh
        oSimp:DrawSelect()
        oSimp:Refresh()
        oDet:DrawSelect()
        oDet:Refresh()
    EndIf
Return

/*/{Protheus.doc} MudaMarca
Atualização da marca no TWBrowse
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static nMarca := 0
Static Function MudaMarca(nBrowse,oSimp,oDet,aDocSim,lTodos)

	Local nCteMark := 0
	Local nCntFor1 := 0
    
    DEFAULT nBrowse := 0
    DEFAULT lTodos  := .F.

	If nBrowse == 1	//-- Cte Simplificado
	    If lTodos
	        nMarca := Iif(nMarca == 0,1,0)
	        AEval(aDocSim,{|x,y| If(x[1] < 2, aDocSim[y][1] := nMarca, ) })
	    Else
	        Do Case
	        Case aDocSim[oSimp:nAt,SIMP_STMARKA] == 0
	            aDocSim[oSimp:nAt,SIMP_STMARKA] := 1
	        Case aDocSim[oSimp:nAt,SIMP_STMARKA] == 1
	            aDocSim[oSimp:nAt,SIMP_STMARKA] := 0
	        Case aDocSim[oSimp:nAt,SIMP_STMARKA] == 2
	            Help(" ", 1,"TMSA49304") //--Quantidade Mínima de Remetentes ou Destinatarios não atendida. //--O CT-e Simplificado exige que entre os documentos tenham mais de um remetente ou destinatario.
	        Case aDocSim[oSimp:nAt,SIMP_STMARKA] == 3
	            Help(" ", 1,"TMSA49305") //--Mais de um produto ou regra fiscal (TES). //--O CT-e Simplificado exige que todos documentos tenham a mesma regra fiscal.
	        EndCase
	    EndIf
    ElseIf nBrowse == 2	//-- Cte Apoio
        Do Case
        Case aDocSim[oSimp:nAt,SIMP_DETTELA,oDet:nAt,DET_MARKA] == .T.
            aDocSim[oSimp:nAt,SIMP_DETTELA,oDet:nAt,DET_MARKA] := .F.
            aDocSim[oSimp:nAt,SIMP_DETDOC,oDet:nAt,DET_MARKA] := .F.
        Case aDocSim[oSimp:nAt,SIMP_DETTELA,oDet:nAt,DET_MARKA] == .F.
            aDocSim[oSimp:nAt,SIMP_DETTELA,oDet:nAt,DET_MARKA] := .T.
            aDocSim[oSimp:nAt,SIMP_DETDOC,oDet:nAt,DET_MARKA] := .T.
		EndCase
    EndIf

    //-- Analisa quantidade de CTes marcados
   	For nCntFor1 := 1 To Len(aDocSim[oSimp:nAt,SIMP_DETTELA])
        If aDocSim[oSimp:nAt,SIMP_DETTELA,nCntFor1,DET_MARKA] == .T.
            nCteMark ++
        EndIf
   	Next nCntFor1

    If nBrowse == 2
        If nCteMark < 2
            aDocSim[oSimp:nAt,SIMP_STMARKA] := 2
        Else
			If aDocSim[oSimp:nAt,SIMP_STMARKA] == 2
	            aDocSim[oSimp:nAt,SIMP_STMARKA] := 0
	  		EndIf
        EndIf
    EndIf

    AtuBrowses(oSimp,oDet,aDocSim,.T.)

Return

/*/{Protheus.doc} RetVetDoc
Monta vetores de tela e utilizado no TMSA491/TMSA850
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function RetVetDoc(lTela)
    Local aAreas := { DTA->(GetArea()), GetArea() }
    Local aDocAp := { .T. }
    Local a491   := {}

    DEFAULT lTela := .F.

    If lTela
        /*[02] DET_FILDOC*/ AAdd( aDocAp, DT6->DT6_FILDOC )
        /*[03] DET_DOC   */ AAdd( aDocAp, DT6->DT6_DOC    )
        /*[04] DET_SERIE */ AAdd( aDocAp, DT6->DT6_SERIE  )
        /*[05] DET_REM   */ AAdd( aDocAp, Posicione("SA1",1,FWxFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM),"A1_NOME") )
        /*[06] DET_DES   */ AAdd( aDocAp, Posicione("SA1",1,FWxFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES),"A1_NOME") )
        /*[07] DET_REMDES*/ AAdd( aDocAp, DT6->(DT6_CLIREM+DT6_LOJREM+DT6_CLIDES+DT6_LOJDES) )
        DTA->( DbSetOrder(1) )
        If DTA->( MsSeek( FWxFilial("DTA") + DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE ) ) )
            /*[08] DET_FILORI*/ AAdd( aDocAp, DTA->DTA_FILORI )
            /*[09] DET_VIAGEM*/ AAdd( aDocAp, DTA->DTA_VIAGEM )
        Else
            /*[08] DET_FILORI*/ AAdd( aDocAp, "" )
            /*[09] DET_VIAGEM*/ AAdd( aDocAp, "" )
        EndIf
    Else
        TMSA491AAdd( ,, DT6->(RecNo()), @a491 )
        aDocAp := AClone(a491[1])
    EndIf
    
    AEval(aAreas,{|x| RestArea(x) })

Return aDocAp

/*/{Protheus.doc} GrvCTeSimp
Grava CT-e Simplificado e Fatura
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function GrvCTeSimp(aDocSim, cCliDEV, cLojDEV, cTipFre, cServic, cPrefDT6 )
    Local nPos          := 0
    Local nRecDT6       := 0
    Local nValFat       := 0
    Local aVFContr      := {}
    Local cNatRod       := ""
    Local aDocFat       := {}
    Local aMsgFat       := {}
    Local lMV_TMSNFAT   := SuperGetMv("MV_TMSNFAT",.F.,.T.)
    Local cNumCte       := ''
    Local cNumFat       := ''

    //-- Estas Variaveis sao utilizados pelo programa TMSA850 .. NAO RETIRAR !!!
    Private cDocFat     := "S"
    Private cPrefix     := SuperGetMv("MV_FATPREF",, "") // Prefixo da Fatura.
    Private cTipo       := SuperGetMv("MV_TIPFAT" ,, "") // Tipo da Fatura.
    Private cMvSrvFat   := SuperGetMv("MV_SRVFAT" ,, "") // Servicos da Fatura
    Private nTipoDoc    := 0
	Private cCliFat     := cCliDev
	Private cLojaFat    := cLojDev
    Private cCli        := cCliDev
    Private _cLoja      := cLojDev
    Private nQtdCtrc    := 0  // Qtde. de Documentos de cada Fatura
    Private nMinCtrc    := 1  // Valor Minimo de CTRC por Fatura
    Private nMaxCtrc    := 9999
    Private nValorFat   := 0 // Valor Total da Fatura
    Private nValorF     := 0 // Deve ficar com 0 para permitir que o usuario realize ajustes nos ctrcs da fatura
    Private aHeader     := {}
    Private aCols       := {}
    Private lFtAut      := .T.
    Private cFilDeb     := ""
    MV_PAR02 := 2

    TMSA491Nat(cNatRod, @cNatRod,cNatRod,cNatRod)

    Begin Transaction
        For nPos := 1 To Len(aDocSim)
            If aDocSim[nPos][SIMP_STMARKA] == 1
                
                nValorFat   := aDocSim[nPos][SIMP_VALTOT]
                cFilDeb     := aDocSim[nPos][SIMP_DETTELA][1][DET_FILDOC]
                nQtdCtrc    := Len(aDocSim[nPos][SIMP_DETDOC])
                aVFContr    := TMSA491VlrC( cCliDev, cLojDev, cTipFre , cServic, dDataBase )
                cNumCte     := TMS491GSD2( aDocSim[nPos][SIMP_DETDOC], cCliDEV, cLojDEV, cPrefDT6, '1', aVFContr, @nRecDT6, @nValFat )

                cNumFat     := cNumCte

                If lMV_TMSNFAT    //verifica se numeração deve olhar o MV_NUMFAT e documento diferente do tipo "normal" 
				    cNumFat := "" //o número da fatura corresponderá ao conteúdo do parametro MV_NUMFAT
			    EndIf
                
                aDocFat    := TMSA850Grv( .F., cCondicao, 1, aDocSim[nPos][SIMP_DETDOC], dDataBase,, cNumFat,;
                                            '', cPrefDT6 , nValorFat, cNatRod, nRecDT6, .F., .F. )
                AaddMsgErr( { { STR0030 + cNumCte + "/" + cPrefDT6 } }, @aMsgFat ) //--"Ct-e Simplificado gerado: "
  
                If Len( aDocFat ) > 0
                    AaddMsgErr( aDocFat, @aMsgFat )
                EndIf
            EndIf
        Next
    End Transaction
    If Len( aMsgFat ) > 0
        TmsMsgErr( aMsgFat, STR0028 ) //--"CT-e Simplificado Gerado."
    EndIf

Return

/*/{Protheus.doc} A493VisDoc
Visualização de detalhe do documento apoio e CT-e Simplificado
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function A493VisDoc( nTipo, oSimp, oDet, aDocsim )
    Local cFildoc := ""
    Local cDoc    := ""
    Local cSerie  := ""

    If nTipo == 1
        cFildoc := aDocSim[oSimp:nAt][SIMP_FILDOC]
        cDoc    := aDocSim[oSimp:nAt][SIMP_DOC]
        cSerie  := aDocSim[oSimp:nAt][SIMP_SERIE]
    Else
        cFildoc := aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_FILDOC]
        cDoc    := aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_DOC]
        cSerie  := aDocSim[oSimp:nAt][SIMP_DETTELA][oDet:nAt][DET_SERIE]
    EndIf

    DT6->(DbSetOrder(1))
    If DT6->( MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie ) )
        SetFunName("TMSA500")
        TmsA500Mnt( "DT6", DT6->(RecNo()), 1 )
        SetFunName("TMSA493")
    EndIf
Return

/*/{Protheus.doc} A493ExcDoc
Exclusão do CT-e Simplificado e Fatura.
@author Carlos Alberto Gomes Junior
@since 10/04/2025
/*/
Static Function A493ExcDoc( aDocSim )
    Local lCont   := .F.
    Local cFildoc := ""
    Local cDoc    := ""
    Local cSerie  := ""
    Local cSE1Key := ""
    Local cTipo   := ""
    Local cPREFIX := ""
    Local cNUM    := ""
    Local dVENCTO := CToD("")
    Local nACRESC := 0
    Local nDECRES := 0

    DT6->(DbSetOrder(1))
    Begin Transaction
        cFildoc := aDocSim[1][SIMP_FILDOC]
        cDoc    := aDocSim[1][SIMP_DOC]
        cSerie  := aDocSim[1][SIMP_SERIE]
        If DT6->( MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie ) )
            cSE1Key := FWxFilial("SE1",DT6->DT6_FILDOC) + DT6->(DT6_CLIDEV+DT6_LOJDEV+DT6_PREFIX+DT6_NUM)
            cPREFIX := DT6->DT6_PREFIX
            cNUM    := DT6->DT6_NUM   
            cTipo   := DT6->DT6_TIPO
            dVENCTO := DT6->DT6_VENCTO
            nACRESC := DT6->DT6_ACRESC
            nDECRES := DT6->DT6_DECRES
            TMLimpaFat()
            SetFunName("TMSA500")
            lCont := ( TmsA500Mnt( "DT6", DT6->(RecNo()), 3 ) > 0 )
            SetFunName("TMSA493")
        EndIf
        If lCont
            If !DT6->(Eof()) .And. DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) == cFilDoc + cDoc + cSerie .And. DT6->DT6_STATUS $ "B,D"
                RecLock("DT6",.F.)
                DT6->DT6_PREFIX := cPREFIX
                DT6->DT6_NUM    := cNUM
                DT6->DT6_TIPO   := cTIPO
                DT6->DT6_VENCTO := dVENCTO
                DT6->DT6_ACRESC := nACRESC
                DT6->DT6_DECRES := nDECRES
                DT6->(MsUnlock())
            Else
                lCont := TMSA493Exc(cSE1Key,AClone(aDocSim[1][SIMP_DETDOC]), aDocSim[1][SIMP_VALTOT], cTipo)
            EndIf
        EndIf
        If !lCont
            DisarmTransaction()
        EndIf
    End Transaction 

Return

/*/{Protheus.doc} TMSA493Exc
Rotina complementar de exclusão do CT-e Simplificado e Fatura.
Também é executada no Monitor CT-e na exclusão no TMSA200.
@author Carlos Alberto Gomes Junior
@since 23/04/2025
/*/
Function TMSA493Exc(cSE1Key,aDocApo,nValTot,cTipo)

    Local aAreas := { SE1->(GetArea()), DT6->(GetArea()), GetArea() }
    Local cQuery := ""
    Local lRet   := .F.
    Local nDoc   := 0
    Local oQry As Object

    DEFAULT cSE1Key := ""
    DEFAULT aDocApo := {}
    DEFAULT nValTot := 0
    DEFAULT cTipo   := ""

    If Empty(cSE1Key) .Or. Len(aDocApo) == 0 .Or. nValTot == 0 .Or. Empty(cTipo)
        cQuery := "SELECT DT6.R_E_C_N_O_ AS DT6REG "
        cQuery += "FROM " + RetSQLName("DT6") + " DT6 "
        cQuery += "WHERE "
        cQuery += "DT6.DT6_FILIAL = ? AND "
        cQuery += "DT6.DT6_CLIDEV = ? AND "
        cQuery += "DT6.DT6_LOJDEV = ? AND "
        cQuery += "DT6.DT6_DOCTMS = 'U' AND "
        cQuery += "DT6.DT6_PREFIX = ? AND "
        cQuery += "DT6.DT6_NUM = ? AND "
        cQuery += "DT6.DT6_TIPO = ? AND "
        cQuery += "DT6.D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE"

        cQuery := ChangeQuery(cQuery)
        oQry := FwExecStatement():New( cQuery )
        oQry:SetString( 1, FWxFilial("DT6") )
        oQry:SetString( 2, DT6->DT6_CLIDEV )
        oQry:SetString( 3, DT6->DT6_LOJDEV )
        oQry:SetString( 4, DT6->DT6_PREFIX )
        oQry:SetString( 5, DT6->DT6_NUM )
        oQry:SetString( 6, DT6->DT6_TIPO )
        cAliasQry := oQry:OpenAlias()
        Do While !(cAliasQry)->(Eof())
            DT6->( DbGoTo((cAliasQry)->DT6REG) )
            DT6->( AAdd( aDocApo, RetVetDoc() ) )
            If Empty(cSE1Key)
                cTipo := DT6->DT6_TIPO
                cSE1Key := FWxFilial("SE1",DT6->DT6_FILDOC) + DT6->(DT6_CLIDEV+DT6_LOJDEV+DT6_PREFIX+DT6_NUM)
            EndIf
            nValTot += DT6->DT6_VALTOT
            (cAliasQry)->(DbSkip())
        EndDo
        (cAliasQry)->(DbCloseArea())
        DbSelectArea("DT6")
        oQry:Destroy()
        oQry := Nil
    EndIf

    If !Empty(cSE1Key) .And. Len(aDocApo) > 0 .And. nValTot > 0
        SE1->(DbSetOrder(2))
        If SE1->(MsSeek( cSE1Key ))
            Do While !SE1->(Eof()) .And. cSE1Key == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM )
                If SE1->E1_TIPO == cTipo
                    Processa( {|| lRet := T850ProcExc(AClone(aDocApo), nValTot, nValTot, {}, , ) }, STR0034 ) //--"Cancelando fatura no financeiro."
                EndIf
                SE1->(DbSkip())
            EndDo
        EndIf
        If lRet
            For nDoc := 1 To Len(aDocApo)
                DT6->(DbGoTo(aDocApo[nDoc][11]))
                TMLimpaFat()
            Next
        EndIf
    EndIf

    AEval( aAreas, {|x| RestArea(x) } )

Return lRet

/*/{Protheus.doc} TMLimpaFat
Rotina complementar limpa campos de fatura do documento posicionado.
@author Carlos Alberto Gomes Junior
@since 23/04/2025
/*/
Static Function TMLimpaFat()
    RecLock("DT6",.F.)
    DT6->DT6_PREFIX := ""
    DT6->DT6_NUM    := ""
    DT6->DT6_TIPO   := ""
    DT6->DT6_VENCTO := CToD("")
    DT6->DT6_ACRESC := 0
    DT6->DT6_DECRES := 0
    DT6->(MsUnlock())
Return

/*/{Protheus.doc} TM493VeAut
Busca CT-e Simplificado e verifica se autorizado
@author Carlos Alberto Gomes Junior
@since 25/04/2025
/*/
Function TM493VeAut()
    Local lRet   := .F.
    Local cQuery := ""
    Local aArea  := GetArea()

    cQuery := "SELECT DT6.DT6_IDRCTE, DT6.DT6_CHVCTG "
    cQuery += "FROM " + RetSQLName("DT6") + " DT6 "
    cQuery += "WHERE "
    cQuery += "DT6.DT6_FILIAL = ? AND "
    cQuery += "DT6.DT6_CLIDEV = ? AND "
    cQuery += "DT6.DT6_LOJDEV = ? AND "
    cQuery += "DT6.DT6_DOCTMS = 'S' AND "
    cQuery += "DT6.DT6_PREFIX = ? AND "
    cQuery += "DT6.DT6_NUM = ? AND "
    cQuery += "DT6.DT6_TIPO = ? AND "
    cQuery += "DT6.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    oQry := FwExecStatement():New( cQuery )
    oQry:SetString( 1, FWxFilial("DT6") )
    oQry:SetString( 2, DT6->DT6_CLIDEV )
    oQry:SetString( 3, DT6->DT6_LOJDEV )
    oQry:SetString( 4, DT6->DT6_PREFIX )
    oQry:SetString( 5, DT6->DT6_NUM )
    oQry:SetString( 6, DT6->DT6_TIPO )
    cAliasQry := oQry:OpenAlias()
    Do While !(cAliasQry)->(Eof())
        lRet :=	Alltrim((cAliasQry)->DT6_IDRCTE) $ "100:136" .Or. !Empty((cAliasQry)->DT6_CHVCTG)
        (cAliasQry)->(DbSkip())
    EndDo
    (cAliasQry)->(DbCloseArea())
    DbSelectArea("DT6")
    oQry:Destroy()
    oQry := Nil

    RestArea(aArea)

Return lRet

/*/{Protheus.doc} TMSA493Vld
Valida tela de CT-e Simplificado.
@author Carlos Alberto Gomes Junior
@since 28/04/2025
/*/
Static Function TMSA493Vld(nOpcx,aDocSim)
    Local lRet := .T.
	
    Do Case
    Case nOpcx == 3
        If AScan( aDocSim , {|x| x[SIMP_STMARKA] == 1 } ) == 0
            Help(" ", 1,"TMSA49308") //--Nenhum CT-e marcado para calculo. //--Marque um CT-e para calcular.
            lRet := .F.
        EndIf
    Case nOpcx == 7
        If AScan( aDocSim[1][SIMP_DETTELA] , {|x| !Empty(x[DET_VIAGEM]) } ) > 0
            Help(" ", 1,"TMSA49309") //--Não é permitido estornar o cálculo com documentos de apoio carregados. //--Estorne carregamento do documento de apoio para estornar o calculo do CT-e Simplificado.
            lRet := .F.
        EndIf
    EndCase

Return lRet
