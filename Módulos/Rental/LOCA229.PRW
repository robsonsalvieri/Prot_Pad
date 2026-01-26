#Include "loca229.ch"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"


#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
/*/{Protheus.doc} LOCA229
Rotina de Gestão de Demanda
@type function
@version  24.10
@author Alexandre Circenis
@since 2/12/2025
/*/
Function LOCA229()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oFold
Local oAba01
Local oAba02
LOCAL lRelease24 := (GetRPORelease() >= "12.1.2410")
Local lMvLocBac	:= GetMv("MV_LOCBAC") //Integração com Módulo de Locações SIGALOC

Private oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacFQV
Private oDlgPrinc
Private aCols := {}
Private aHeader := {}
Private oGetD   := {}

if !lRelease24 
    MsgAlert(STR0001,STR0002 )  //"Está rotina só está disponivel para a versão do 12.1.2410 e posteriores!" //"Atenção"
    Return
endif

if !lMvLocBac
        Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
		Nil,STR0030,1,0,Nil,Nil,Nil,Nil,Nil,;  //"Inconsistência nos dados."
		{STR0031})  //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
endif

    Define MsDialog oDlgPrinc Title STR0003 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  //"Gestão de Expedição"
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
    oFold:AddItem(STR0004) //"AS" //"A.S."
    oFold:AddItem(STR0005) //STR0005 //"Resumo"
    oFold:bSetOption := { |nIndo| Loca229CGF(nIndo, oGetD )}
    oAba01 := oFold:aDialogs[1]
    oAba02 := oFold:aDialogs[2]
    //
    // FWmBrowse Superior Demandas
    //
    oBrowseUp:= FWmBrowse():New()
    oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
    oBrowseUp:SetDescription( STR0006 )  //"Romaneio"
    oBrowseUp:SetAlias( 'FQU' )
    oBrowseUp:SetMenuDef( 'LOCA229' )                   // Define de onde virao os botoes deste browse
    oBrowseUp:SetProfileID( 'LOCA229UP' )
    oBrowseUp:SetTopFun('xFilial("FQU")')
    oBrowseUp:SetBotFun('xFilial("FQU")')
    oBrowseUP:DisableDetails()
    oBrowseUp:ForceQuitButton()
    //oBrowseUp:SetFilterDefault("FQT_DEMAND >='"+aRet[1]+"' .and. FQT_DEMAND <='"+aRet[2]+"'"+;
    //    " .and. FQT_PROJET >= '"+aRet[3]+"' .and. FQT_PROJET <= '"+aRet[4]+"'"+;
    //    " .and. FQT_OBRA >= '"+aRet[5]+"' .and. FQT_OBRA <= '"+aRet[6]+"'")
    //oBrowseUp:SetFilterDefault("@FQT_DEMAND >='"+aRet[1]+"' and FQT_DEMAND <='"+aRet[2]+"'"+;
    //    " and FQT_PROJET >= '"+aRet[3]+"' and FQT_PROJET <= '"+aRet[4]+"'"+;
    //    " and FQT_OBRA >= '"+aRet[5]+"' and FQT_OBRA <= '"+aRet[6]+"' "+;
    //    " and ( FQT_ITENS = 0 or EXISTS ( SELECT FQ5_XPROD FROM "+RetSqlName("FQ5")+" FQ5 WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'" +;
    //    " and FQ5_DEMAND = FQT_DEMAND and FQ5_XPROD >= '"+aRet[7]+"' and FQ5_XPROD <= '"+aRet[8]+"' "+;
    //    " and FQ5.D_E_L_E_T_ = ' ' ))")
    //oBrowseUp:oBrowse:setChange({||MsgStop("TROCOU DE LINHA")})

    oBrowseUp:AddLegend( "FQU->FQU_STATUS = '4'"              , "GRAY"   , STR0007	)  //"Em Conferencia"
    oBrowseUp:AddLegend( "FQU->FQU_STATUS = '6'"              , "GREEN"  , STR0008	)  //"Pedido Venda Gerado"
    oBrowseUp:AddLegend( "FQU->FQU_STATUS = '5'"              , "ORANGE" , STR0011)  //"Conferido"
	oBrowseUP:AddLegend( "FQU->FQU_FCHEMB = '1' .and. FQU->FQU_STATUS = '3'"              , "BR_VIOLETA"	  , STR0028 ) //"Embarque Fechado"
    oBrowseUp:AddLegend( "FQU->FQU_STATUS = '3'"              , "YELLOW" , STR0009	)  //"Separado"
    oBrowseUp:AddLegend( "FQU->FQU_STATUS = '1'"              , "RED"	 , STR0010	)  //"Agendado (Vazio)"
	oBrowseUp:AddLegend( "FQU->FQU_STATUS = '2'"              , "BLUE"	 , STR0012	) //"Em Separação"
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
    oBrowseDown:SetDescription( STR0013 ) //"Itens Romaneio"
    oBrowseDown:SetMenuDef( 'LOCA229D' )  
    oBrowseDown:DisableDetails()
    oBrowseDown:SetAlias( 'FQV' )
    oBrowseDown:SetProfileID( 'LOCA229DW')
  	oBrowseDown:SetAmbiente(.F.)
	oBrowseDown:SetWalkthru(.F.)
    oBrowseDown:OptionReport(.F.)
    //
    // Adicionando a legenda
    //
    oBrowseDown:AddLegend( 'FQV->FQV_STATUS == "5"', "GRAY"		, STR0018 ) //"NF Emitida"
    oBrowseDown:AddLegend( 'FQV->FQV_STATUS == "4"', "YELLOW"	, STR0017 )  //"Embarcada"
    oBrowseDown:AddLegend( 'FQV->FQV_STATUS == "3"', "BLUE"		, STR0016 )  //"Conferida"
    oBrowseDown:AddLegend( 'FQV->FQV_STATUS == "6"', "ORANGE"	, STR0015 )  //"Separada"
    oBrowseDown:AddLegend( 'FQV->FQV_STATUS == "1"', "GREEN"	, STR0014 ) //"Pendente"
    
    //
    // Relacionamento entre os Browses
    //
    oRelacFQV:= FWBrwRelation():New()
    oRelacFQV:AddRelation( oBrowseUp  , oBrowseDown , { { 'FQV_FILIAL', 'FQU_FILIAL' }, { 'FQV_NUM' , 'FQU_NUM'  }  } )
    oRelacFQV:Activate()

    //
    // Ativa o Browse Filho
    //
    oBrowseDown:Activate()

    //Aba resumo
    HeadResum()
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
Local aRot2   := {}
Local aRot3   := {}

ADD OPTION aRot2   TITLE STR0029 ACTION 'LOCA229H(.T.)' OPERATION 4 ACCESS 0  //"Fechar Embarque"
ADD OPTION aRot2   TITLE STR0033 ACTION 'LOCA229H(.F.)' OPERATION 4 ACCESS 0   //"Reabrir Embarque"


ADD OPTION aRotina TITLE STR0019   ACTION 'VIEWDEF.LOCA229A' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0020   ACTION 'VIEWDEF.LOCA229A' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0021   ACTION 'VIEWDEF.LOCA229A' OPERATION 4 ACCESS 0 //'Alterar'
//ADD OPTION aRotina TITLE STR0022   ACTION 'VIEWDEF.LOCA229A' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0023   ACTION 'LOCA229C'    OPERATION 3 ACCESS 0 //"Romaneio" //"Inc. Itens"
ADD OPTION aRotina TITLE STR0006   ACTION 'VIEWDEF.LOCA229B' OPERATION 2 ACCESS 0 //"Romaneio"
ADD OPTION aRot3 TITLE STR0034   ACTION 'VIEWDEF.LOCA229E' OPERATION 4 ACCESS 0 //"Separacao" //"Separar"
ADD OPTION aRot3 TITLE STR0025   ACTION 'VIEWDEF.LOCA229F' OPERATION 4 ACCESS 0 //"Estornar Separacao"
ADD OPTION aRotina TITLE STR0024 ACTION aRot3 OPERATION 4 ACCESS 0 //"Separacao"
ADD OPTION aRotina TITLE STR0035 ACTION aRot2 OPERATION 4 ACCESS 0  //"Fechar Embarque" //"Embarque"

ADD OPTION aRotina TITLE STR0032 ACTION 'LOCA229I(.F.)' OPERATION 4 ACCESS 0  //"Emitir Nota"
//ADD OPTION aRotina TITLE "Estornar" ACTION 'MsgInfo("Estorno realizado com sucesso","Estorno")'OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0036 ACTION 'LOCSV013(FQU->FQU_NUM)' OPERATION 4 ACCESS 0 //"Imprimir Romaneio"
ADD OPTION aRotina TITLE STR0026   ACTION 'LOCA229AC' OPERATION 4 ACCESS 0  //"Analisar Carregamento"

Return aRotina

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
Local aAreaFQV := FQV->(GetArea()) 
Local nLinha   := 0

aCols := {}
// Preenche o Resumo do Browse
FQV->(dbSetOrder(1))
if FQV->(dbSeek(xFilial("FQV")+FQU->FQU_NUM)) // Buscar Itens Romaneio
    // Encontrada demanda preencher resumo
    while !FQV->(Eof()) .and. FQV->FQV_FILIAL = xFilial("FQV") .and. FQV->FQV_NUM= FQU->FQU_NUM
        nLinha := Ascan( aCols, {|x| x[1] = FQV->FQV_PROD})
        if nLinha = 0 
           Aadd( aCols, {FQV->FQV_PROD,0,0,Posicione("FPA",1,xFilial("FPA")+FQV->FQV_AS, "FPA_LOCAL"),0,0,0,0,0,0,0,0,.F.}) 
           nLinha := Len(aCols)
        endif
        dbSelectArea("FQ5")
        dbSetOrder(9)
        dbSeek(xFilial("FQ5")+FQV->FQV_AS)
        aCols[nLinha, 2] += FQV->FQV_QTD
        aCols[nLinha, 3] += FQ5->FQ5_QTD2
        if FQV->FQV_STATUS = '1' // Pendente
            aCols[nLinha, 5] += FQV->FQV_QTD
        elseif FQV->FQV_STATUS = '6' // Separado
            aCols[nLinha, 6] += FQV->FQV_QTD
        elseif FQV->FQV_STATUS = '3' // Conferida
            aCols[nLinha, 7] += FQV->FQV_QTD
        elseif FQV->FQV_STATUS = '4' // Embarcado
            aCols[nLinha, 8] += FQV->FQV_QTD
        elseif FQV->FQV_STATUS = '5' // Nota Emitida
            aCols[nLinha, 9] += FQV->FQV_QTD
        endif
        aCols[nLinha, 10] += FQ5->FQ5_PESLIQ
        aCols[nLinha, 11] += FQ5->FQ5_PESBRU
        aCols[nLinha, 12] += FQ5->FQ5_M3
        FQV->(dbSkip())
    enddo
else // Não encontrada incluir linha em Branco
    Aadd( Acols, {"",0,0,"",0,0,0,0,0,0,0,0,.F.})
endif
RestArea(aAreaFQV)
RestArea(aArea)

Return aCols

/*/{Protheus.doc} Loca229CGF
Troca de folder 
@type function
@version  24.10
@author Alexandre Circenis
@since 2/28/2025
@param nIndo, numeric, Folder para onde está indo
@param oGetD, object, Newgetdados do REsumo
@return variant, True Permitindo a troca
/*/
Function Loca229CGF(nIndo, oGetD )

if nIndo = 2 // Indo para a tela resumo

    oGetD:SetArray(ColResum())
    oGetD:oBrowse:Refresh()
endif

return .t.
/*/{Protheus.doc} LOCA229AC
Analisa a capacidade de transporte do romaneio
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/10/2025
/*/
Function LOCA229AC()
LOcal aEventos := {}

// Processar os eventos de Sobreposição e Capacidade do Romaneio

aEventos := Loca229AOK()

LOCA229G(STR0027+FQU->FQU_NUM, aEventos) //"Análise de Alocação e Capacidade de Transporte do Romaneio "

Return
