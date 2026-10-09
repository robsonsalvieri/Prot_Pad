#INCLUDE "LOCA104.CH"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"


#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
/*/{Protheus.doc} LOCA104
Rotina de Gestão de Demanda
@type function
@version  24.10
@author Alexandre Circenis
@since 2/12/2025
/*/
Function LOCA104()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oFold
Local oAba01
Local oAba02
LOCAL lRelease24 := (GetRPORelease() >= "12.1.2410")
Local lMvLocBac	:= GetMv("MV_LOCBAC") //Integração com Módulo de Locações SIGALOC

Private oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacFQX
Private oDlgPrinc
Private aCols := {}
Private aHeader := {}
Private oGetD   := {}

if !lRelease24 
    MsgAlert(STR0001,STR0002 )   //"Está rotina só está disponivel para a versão do 12.1.2410 e posteriores!" //"Atenção"
    Return .F.
endif

if !lMvLocBac
        Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
		Nil,STR0003,1,0,Nil,Nil,Nil,Nil,Nil,;   //"Inconsistência nos dados."
		{STR0004})   //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
endif

    Define MsDialog oDlgPrinc Title STR0005 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  //"Gestão de Expedição" //"Gestao de Devolução"
    //
    // Cria o conteiner onde serão colocados os browses
    //
    oFWLayer := FWLayer():New()
    oFWLayer:Init( oDlgPrinc, .F., .T. )
    //
    // Define Painel Superior
    //
    oFWLayer:AddLine( 'UP', 50, .F. )                       // Cria uma "linha" com 50% da tela
    oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
    oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container
    //
    // Painel Inferior
    //
    
    oFWLayer:AddLine( 'DOWN', 50, .F. )                     // Cria uma "linha" com 50% da tela
    oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
    oPanelDown  := oFWLayer:GetColPanel( 'ALL' , 'DOWN' )  // Pego o objeto desse pedaço do container

    oFold := TFolder():New(0,0,{},,oPanelDown,,,,.T.,.F.,0,1000)
    oFold:Align := CONTROL_ALIGN_ALLCLIENT
    oFold:Hide()
    oFold:Show()
    oFold:AddItem(STR0006)  //"Itens Devolução"
    oFold:AddItem(STR0007)  //"Resumo"
    oFold:bSetOption := { |nIndo| Loca104CGF(nIndo, oGetD )}
    oAba01 := oFold:aDialogs[1]
    oAba02 := oFold:aDialogs[2]
    
    //
    // FWmBrowse Superior Demandas
    //
    oBrowseUp:= FWmBrowse():New()
    oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
    oBrowseUp:SetDescription( STR0008 )  //"Romaneio" //"Romaneio de Devolução"
    oBrowseUp:SetAlias( 'FQW' )
    oBrowseUp:SetMenuDef( 'LOCA104' )                   // Define de onde virao os botoes deste browse
    oBrowseUp:SetProfileID( 'LOCA104UP' )
    oBrowseUp:SetTopFun('xFilial("FQW")')
    oBrowseUp:SetBotFun('xFilial("FQW")')
    oBrowseUP:DisableDetails()
    oBrowseUp:ForceQuitButton()
 
    oBrowseUp:AddLegend( "FQW->FQW_STATUS $ '56'"             , "RED" , STR0009	)    //"Devolução Encerrada"
	oBrowseUP:AddLegend( "FQW->FQW_STATUS = '4'"              , "BR_VIOLETA"	  , STR0010 )   //"Contagens Divergentes"
    oBrowseUp:AddLegend( "FQW->FQW_STATUS = '3'"              , "ORANGE" , STR0011 )   //"Segunda Contagem"
	oBrowseUp:AddLegend( "FQW->FQW_STATUS = '2'"              , "GREEN"	 , STR0012	)   //"Primeira Contagem"
    oBrowseUp:AddLegend( "FQW->FQW_STATUS = '1'"              , "BLUE"	 , STR0013	)   //"Agendado (Vazio)"
	oBrowseUp:SetAmbiente(.F.)
	oBrowseUp:SetWalkthru(.F.)
    oBrowseUp:OptionReport(.F.)

    oBrowseUp:Activate()
    oBrowseUp:bChange := {|| oFold:SetOption(1) , oFold:ReFresh(), oBrowseDown:Refresh() }
    //
    // FWmBrowse inferior itens das demandas
    //
   
    oBrowseDown:= FWMBrowse():New()
    oBrowseDown:SetOwner( oAba01 )
    oBrowseDown:SetDescription( STR0014) //"Itens Romaneio"
    oBrowseDown:SetMenuDef( 'LOCA104E' )  
    oBrowseDown:DisableDetails()
    oBrowseDown:SetAlias( 'FQX' )
    oBrowseDown:SetProfileID( 'LOCA104DX')
  	oBrowseDown:SetAmbiente(.F.)
	oBrowseDown:SetWalkthru(.F.)
    oBrowseDown:OptionReport(.F.)
    //
    // Adicionando a legenda
    //
    oBrowseDow:AddLegend( "FQX->FQX_STATUS $ '56'"             , "RED" , STR0009	)    //"Devolução Encerrada"
	oBrowseDow:AddLegend( "FQX->FQX_STATUS = '4'"              , "BR_VIOLETA"	  , STR0010 )   //"Contagens Divergentes"
    oBrowseDow:AddLegend( "FQX->FQX_STATUS = '3'"              , "ORANGE" , STR0011 )   //"Segunda Contagem"
	oBrowseDow:AddLegend( "FQX->FQX_STATUS = '2'"              , "GREEN"	 , STR0012	)   //"Primeira Contagem"
    oBrowseDow:AddLegend( "FQX->FQX_STATUS = '1'"              , "BLUE"	 , STR0013	)  //"Agendado (Vazio)"
    
    //
    // Relacionamento entre os Browses
    //
    oRelacFQX:= FWBrwRelation():New()
    oRelacFQX:AddRelation( oBrowseUp  , oBrowseDown , { { 'FQX_FILIAL', 'FQW_FILIAL' }, { 'FQX_NUM' , 'FQW_NUM'  }  } )
    oRelacFQX:Activate()

    //
    // Ativa o Browse Filho
    //
    oBrowseDown:Activate()

    //Aba resumo
    HeadResDev()
    ColResum()
    oGetD := MsNewGetDados():New(16, 0, 080, 396,0,"","",,,, 999,,,,oAba02,@aHeader,@aCols,, )
	oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    oFold:SetOption(1)
    
    Activate MsDialog oDlgPrinc Center

Return NIL

/*/{Protheus.doc} MENUDEF
Menu Principal da Gestão de Demandas
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Array com as opçoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0015   ACTION 'VIEWDEF.LOCA104A' OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0016   ACTION 'VIEWDEF.LOCA104A' OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0017   ACTION 'VIEWDEF.LOCA104A' OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0029   ACTION 'VIEWDEF.LOCA104F' OPERATION 5 ACCESS 0  //"Excluir Romaneio"
ADD OPTION aRotina TITLE STR0034   ACTION 'VIEWDEF.LOCA104J' OPERATION 2 ACCESS 0 //"Consulta Romaneio"

ADD OPTION aRotina TITLE STR0018   ACTION 'LOCA104B'    OPERATION 3 ACCESS 0  //"Incluir Itens"
ADD OPTION aRotina TITLE STR0027   ACTION 'LOCA104D'    OPERATION 3 ACCESS 0  //"Inc Itens Outros Contratos"

ADD OPTION aRotina TITLE STR0019   ACTION 'LOCA104AC' OPERATION 4 ACCESS 0  //"Analisar Carregamento"
ADD OPTION aRotina TITLE STR0028   ACTION 'LOCA104G' OPERATION 4 ACCESS 0   //"Gerar Doc Retorno"
ADD OPTION aRotina TITLE STR0030   ACTION 'LOCA104H' OPERATION 4 ACCESS 0    //"Estornar Doc Retorno"
ADD OPTION aRotina TITLE STR0032   ACTION 'VIEWDEF.LOCA104I' OPERATION 4 ACCESS 0  //"Controle de Acessórios por ID"
ADD OPTION aRotina TITLE STR0031   ACTION 'LOCSV025(FQW->FQW_NUM)' OPERATION 8 ACCESS 0    //"Imprimir Devolução" //'Imprimir Devolução'

Return aRotina

/*/{Protheus.doc} HeadResum
Cria o Header do resumo 
@type function
@version 25.10
@author Alexandre Circenis
@since 4/17/2025
@return variant, Array do aHeader do resumo
/*/
Function HeadResDev()

	aadd(aHeader, {STR0020, "FQ5_XPROD" , "@!"               , TamSx3("FQ5_XPROD")[1] , 0                      , "", USADO, "C", , "V", , , /*"Empty(aCols[n][1])"*/})  //"Produto"
    aadd(aHeader, {STR0033, "B1_DESC" , "@!"               , TamSx3("B1_DESC")[1] , 0                      , "", USADO, "C", , "V", , , /*"Empty(aCols[n][1])"*/})  //"Produto" //"Descrição"
	aadd(aHeader, {STR0021, "FQ5_XQTD"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , , /*"Empty(aCols[n][2])"*/})  //"Quantidade"
	aadd(aHeader, {STR0022, "QSEGUNID"  , "@E 999,999,999.99", TamSx3("FQ5_QTD2")[1]  , TamSx3("FQ5_QTD2")[2]  , "", USADO, "N", , "V", , , /*"Empty(aCols[n][3])"*/})  //"Qtde Seg Uni"
	aadd(aHeader, {"Pecas Boas", "FQX_ARMZ01"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) 
    aadd(aHeader, {"Avarias Leves", "FQX_ARMZ02"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,})
    aadd(aHeader, {"Avarias Graves", "FQX_ARMZ03" , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) "
    aadd(aHeader, {"Refugo", "FQX_ARMZ04" , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,})
    aadd(aHeader, {"Perdidas", "FQX_ARMZ05", "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) 
    aadd(aHeader, {STR0023, "PESLIQ"    , "@E 999,999,999.99", TamSx3("FQ5_PESLIQ")[1], TamSx3("FQ5_PESLIQ")[2], "", USADO, "N", , "V", , ,})  //"Peso Liquido"
    aadd(aHeader, {STR0024, "PESBRU"    , "@E 999,999,999.99", TamSx3("FQ5_PESBRU")[1], TamSx3("FQ5_PESBRU")[2], "", USADO, "N", , "V", , ,})  //"Peso Bruto"
    aadd(aHeader, {STR0025, "M3"        , "@E 999,999,999.99", TamSx3("FQ5_M3")[1]    , TamSx3("FQ5_M3")[2]    , "", USADO, "N", , "V", , ,})  //"m3"

Return

/*/{Protheus.doc} ColResum
Gera o array de dados para a tela de resumo
@type function
@version  25.10
@author Alexandre Circenis
@since 4/9/2025
@return variant, array com os dados do resumo
/*/
Static Function ColResum()
Local aArea    := GetArea()
Local aAreaFQX := FQX->(GetArea()) 
Local nLinha   := 0

aCols := {}
// Preenche o Resumo do Browse
FQX->(dbSetOrder(1))
if FQX->(dbSeek(xFilial("FQX")+FQW->FQW_NUM)) // Buscar Itens Romaneio
    // Encontrada demanda preencher resumo
    while !FQX->(Eof()) .and. FQX->FQX_FILIAL = xFilial("FQX") .and. FQX->FQX_NUM= FQW->FQW_NUM
        nLinha := Ascan( aCols, {|x| x[1] = FQX->FQX_PROD})
        if nLinha = 0 
           Aadd( aCols, {FQX->FQX_PROD,Posicione("SB1",1, xFilial("SB1")+FQX->FQX_PROD,"B1_DESC"),0,0,0,0,0,0,0,0,0,0,.F.}) 
           nLinha := Len(aCols)
        endif
        dbSelectArea("FQ5")
        dbSetOrder(9)
        dbSeek(xFilial("FQ5")+FQX->FQX_AS)
        aCols[nLinha, 3] += FQX->FQX_QTD
        aCols[nLinha, 4] += FQX->FQX_QTD2
        if FQX->FQX_STATUS = '1' // Pendente
            aCols[nLinha, 5] += FQX->FQX_QTD
        elseif FQX->FQX_STATUS = '6' // Separado
            aCols[nLinha, 6] += FQX->FQX_QTD
        elseif FQX->FQX_STATUS = '3' // Conferida
            aCols[nLinha, 7] += FQX->FQX_QTD
        elseif FQX->FQX_STATUS = '4' // Embarcado
            aCols[nLinha, 8] += FQX->FQX_QTD
        elseif FQX->FQX_STATUS = '5' // Nota Emitida
            aCols[nLinha, 9] += FQX->FQX_QTD
        endif
        aCols[nLinha, 10] += (FQ5->FQ5_PESLIQ / FQ5->FQ5_XQTD) * FQX->FQX_QTD
        aCols[nLinha, 11] += (FQ5->FQ5_PESBRU / FQ5->FQ5_XQTD) * FQX->FQX_QTD
        aCols[nLinha, 12] += (FQ5->FQ5_M3 / FQ5->FQ5_XQTD) * FQX->FQX_QTD
        FQX->(dbSkip())
    enddo
else // Não encontrada incluir linha em Branco
    Aadd( Acols, {"","",0,0,0,0,0,0,0,0,0,0,.F.})
endif
RestArea(aAreaFQX)
RestArea(aArea)

Return aCols

/*/{Protheus.doc} Loca104CGF
Troca de folder 
@type function
@version  24.10
@author Alexandre Circenis
@since 2/28/2025
@param nIndo, numeric, Folder para onde está indo
@param oGetD, object, Newgetdados do REsumo
@return variant, True Permitindo a troca
/*/
Function Loca104CGF(nIndo, oGetD )

if nIndo = 2 // Indo para a tela resumo

    oGetD:SetArray(ColResum())
    oGetD:oBrowse:Refresh()
endif

return .t.
/*/{Protheus.doc} LOCA104AC
Analisa a capacidade de transporte do romaneio
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/10/2025
/*/
Function LOCA104AC()
LOcal aEventos := {}

// Processar os eventos de Sobreposição e Capacidade do Romaneio

aEventos := Loca104AOK()

LOCA229G(STR0026+FQW->FQW_NUM, aEventos)  //"Análise de Alocação e Capacidade de Transporte do Romaneio "

Return

