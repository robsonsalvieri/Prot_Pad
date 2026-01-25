#Include "loca259.ch"
#Include "TOTVS.CH"


#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
/*/{Protheus.doc} LOCA259
Rotina de Gestão de Demanda
@type function
@version  24.10
@author Alexandre Circenis
@since 2/12/2025
/*/
FUNCTION LOCA259()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacFQ5
Local oFold
Local oAba01
Local oAba02
Local aParam := {}
Local aRet   := {}
Local aCampos := {"FQ5_FILORI","FQ5_AS","FQ5_VIAGEM","FQ5_DATGER","FQ5_HORGER","FQ5_XPROD","FQ5_XQTD","FQ5_GUINDA","FQ5_DATIN","FQ5_DATFIM"}
LOCAL lRelease24 := (GetRPORelease() >= "12.1.2410")
Local aFields   := {}
Private oDlgPrinc
Private aCols := {}
Private aHeader := {}
Private oGetD   := {}

if !lRelease24 
    MsgAlert(STR0047,STR0046) //"Atenção" //"Está rotina só está disponivel para a versão do 12.1.2410 e posteriores!"
    Return
endif

// Array a ser passado para ParamBox?
aAdd(aParam,{1,STR0001 ,space(TamSx3("FQT_DEMAND")[1]),"@!", "","FQT","",50,.F.}) //"Demanda de"
aAdd(aParam,{1,STR0002 ,space(TamSx3("FQT_DEMAND")[1]),"@!", "","FQT","",50,.F.}) //"Demanda até"
aAdd(aParam,{1,STR0003 ,space(TamSx3("FQT_PROJET")[1]),"@!", "","FP0","",50,.F.}) //"Projeto de"
aAdd(aParam,{1,STR0004 ,space(TamSx3("FQT_PROJET")[1]),"@!", "","FP0","",50,.F.}) //"Projeto até"
aAdd(aParam,{1,STR0005 ,space(TamSx3("FQT_OBRA")[1]),"@!", "","","",50,.F.}) //"Obra de"
aAdd(aParam,{1,STR0006 ,space(TamSx3("FQT_OBRA")[1]),"@!", "","","",50,.F.}) //"Obra até"
aAdd(aParam,{1,STR0007 ,space(TamSx3("FQ5_XPROD")[1]),"@!", "","SB1","",115,.F.}) //"Produto de"
aAdd(aParam,{1,STR0008 ,space(TamSx3("FQ5_XPROD")[1]),"@!", "","SB1","",115,.F.}) //"Produto até"
aAdd(aParam,{1,STR0009 ,Criavar("FQ5_DATGER", .T.),"", "","","",50,.F.}) //"Data de Geração de"
aAdd(aParam,{1,STR0010 ,Criavar("FQ5_DATGER", .T.),"", "","","",50,.F.}) //"Data de Geração até"
aAdd(aParam,{1,STR0011 ,Criavar("FQ5_DATINI", .T.),"", "","","",50,.F.}) //"Data inicio de"
aAdd(aParam,{1,STR0012 ,Criavar("FQ5_DATINI", .T.),"", "","","",50,.F.}) //"Data inicio até"
aAdd(aParam,{1,STR0013 ,space(TamSx3("FQT_CLIPRO")[1]),"@!", "","SA1","",50,.F.}) //"Cliente de"
aAdd(aParam,{1,STR0014 ,space(TamSx3("FQT_LOJPRO")[1]),"@!", "","","",50,.F.}) //"Loja de"
aAdd(aParam,{1,STR0015 ,space(TamSx3("FQT_CLIPRO")[1]),"@!", "","SA1","",50,.F.}) //"Cliente até"
aAdd(aParam,{1,STR0016 ,space(TamSx3("FQT_LOJPRO")[1]),"@!", "","","",50,.F.}) //"Loja até"

// Caso confirme a tela de parametros processa a rotina de demanda

If ParamBox(aParam,STR0017,@aRet) //"Importar Classifica?o Ativo" //"Gestão de Demanda"

    Define MsDialog oDlgPrinc Title STR0018 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //'Gestão de Demandas'
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
    oFold:AddItem(STR0019) //"AS"
    oFold:AddItem(STR0020) //"Resumo"
    oFold:bSetOption := { |nIndo| Loca259CGF(nIndo, oGetD )}
    oAba01 := oFold:aDialogs[1]
    oAba02 := oFold:aDialogs[2]
    //
    // FWmBrowse Superior Demandas
    //
    oBrowseUp:= FWmBrowse():New()
    oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
    oBrowseUp:SetDescription( STR0021 ) //"Demandas"
    oBrowseUp:SetAlias( 'FQT' )
    oBrowseUp:SetMenuDef( 'LOCA259' )                   // Define de onde virao os botoes deste browse
    oBrowseUp:SetProfileID( 'LOCA259UP' )
    oBrowseUp:SetTopFun('xFilial("FQT")')
    oBrowseUp:SetBotFun('xFilial("FQT")')
    oBrowseUP:DisableDetails()
    oBrowseUp:ForceQuitButton()
    //oBrowseUp:SetFilterDefault("FQT_DEMAND >='"+aRet[1]+"' .and. FQT_DEMAND <='"+aRet[2]+"'"+;
    //    " .and. FQT_PROJET >= '"+aRet[3]+"' .and. FQT_PROJET <= '"+aRet[4]+"'"+;
    //    " .and. FQT_OBRA >= '"+aRet[5]+"' .and. FQT_OBRA <= '"+aRet[6]+"'")
    oBrowseUp:SetFilterDefault("@FQT_DEMAND >='"+aRet[1]+"' and FQT_DEMAND <='"+aRet[2]+"'"+;
        " and FQT_PROJET >= '"+aRet[3]+"' and FQT_PROJET <= '"+aRet[4]+"'"+;
        " and FQT_OBRA >= '"+aRet[5]+"' and FQT_OBRA <= '"+aRet[6]+"' "+;
        " and FQT_CLIPRO >= '"+aRet[13]+"' and FQT_CLIPRO <= '"+aRet[15]+"' "+;
        " and FQT_LOJPRO >= '"+aRet[14]+"' and FQT_LOJPRO <= '"+aRet[16]+"' "+;
        " and ( FQT_ITENS = 0 or EXISTS ( SELECT FQ5_XPROD FROM "+RetSqlName("FQ5")+" FQ5 WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'" +;
        " and FQ5_DEMAND = FQT_DEMAND and FQ5_XPROD >= '"+aRet[7]+"' and FQ5_XPROD <= '"+aRet[8]+"' "+;
        " and FQ5_DATGER >= '"+Dtos(aRet[9])+"' and FQ5_DATGER <= '"+Dtos(aRet[10])+"'"+;
        " and FQ5_DATINI >= '"+Dtos(aRet[11])+"' and FQ5_DATINI <= '"+Dtos(aRet[12])+"'"+;
        " and FQ5.D_E_L_E_T_ = ' ' ))")
    //oBrowseUp:oBrowse:setChange({||MsgStop("TROCOU DE LINHA")})

    oBrowseUp:AddLegend( "FQT->FQT_ITENS = 0"               , "GRAY"  , STR0035	)     //"Vazia"
    oBrowseUp:AddLegend( "FQT->FQT_FATURA = FQT->FQT_QTDPRO", "GREEN" , STR0036	) //"Atendida"
    oBrowseUp:AddLegend( "FQT->FQT_FATURA > 0"              , "YELLOW", STR0037	) //"Parcialmente"
    oBrowseUp:AddLegend( "FQT->FQT_FATURA = 0"              , "RED"	  , STR0031	) //"Pendente"
	oBrowseUp:SetAmbiente(.F.)
	oBrowseUp:SetWalkthru(.F.)
    oBrowseUp:OptionReport(.F.)

    oBrowseUp:Activate()
    oBrowseUp:bChange := {|| oFold:SetOption(1) , oFold:ReFresh() }
    //
    // FWmBrowse inferior itens das demandas
    //
    oBrowseDown:= FWMBrowse():New()
    oBrowseDown:SetOwner( oAba01 )
    oBrowseDown:SetDescription( STR0022 ) //'Itens Demanda'
    oBrowseDown:SetMenuDef( 'LOCA259D' )                       // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
    oBrowseDown:DisableDetails()
    oBrowseDown:SetAlias( 'FQ5' )
    oBrowseDown:SetProfileID( 'LOCA259DW')
    oBrowseDown:SetOnlyFields(aCampos)
	oBrowseDown:SetAmbiente(.F.)
	oBrowseDown:SetWalkthru(.F.)
    oBrowseDown:OptionReport(.F.)

    oBrowseDown:AddLegend( 'FQ5->FQ5_STATUS == "1"', "GREEN"	, STR0031	) //"Pendente"
    oBrowseDown:AddLegend( 'FQ5->FQ5_STDEMA == "4"', "YELLOW"	, STR0040	) //"Embarcada"
    oBrowseDown:AddLegend( 'FQ5->FQ5_STATUS == "6"', "ORANGE"	, STR0038	) //"Separada"
    oBrowseDown:AddLegend( 'FQ5->FQ5_STATUS == "7"', "BLUE"		, STR0039	) //"Conferida"
    oBrowseDown:AddLegend( 'FQ5->FQ5_STATUS == "A"', "GRAY"		, STR0041	)  //"NF Emitida"
     Aadd(aFields,{FWX3Titulo('FQ5_XROMAN')    ,'FQ5_XROMAN','C',TamSx3('FQ5_XROMAN')[1]  ,Nil  ,})
    oBrowseDown:Setfields(aFields)
    
    //
    // Relacionamento entre os Browses
    //
    oRelacFQ5:= FWBrwRelation():New()
    
    oRelacFQ5:AddRelation( oBrowseUp  , oBrowseDown , { { 'FQ5_FILIAL', 'xFilial( "FQ5" )' }, { 'FQ5_DEMAND' , 'FQT_DEMAND'  }, { 'FQ5_SOT' , 'FQT_PROJET' }  } )
    oRelacFQ5:Activate()

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

endif

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

aadd(aRotina, {STR0023, 'VIEWDEF.LOCA259A', 0, 2, 0, NIL}) //'Visualizar'
aadd(aRotina, {STR0024, 'VIEWDEF.LOCA259A', 0, 3, 0, NIL}) //'Incluir'
aadd(aRotina, {STR0025, 'VIEWDEF.LOCA259A', 0, 4, 0, NIL}) //'Alterar'
aAdd(aRotina, {STR0051, "EXDEMAN"         , 0, 5, 0, NIL}) //"Excluir" //"Excluir Demanda"
aadd(aRotina, {STR0026, 'LOCA259B'        , 0, 3, 0, NIL}) //'Movimentar AS' 
aAdd(aRotina, {STR0048, "LOCA259F"        , 0, 4, 0, NIL}) //"Desvincular AS" //"Desvincular A.S."
aadd(aRotina, {STR0052, 'VIEWDEF.LOCA259E', 0, 4, 0, NIL}) //"Separacao"
aadd(aRotina, {STR0053, 'LOCA229A'        , 0, 4, 0, NIL}) //"Incluir Romaneio"
aadd(aRotina, {STR0055, 'LOCA259G'        , 0, 2, 0, NIL}) //"Documento/Responsabilidade"
aadd(aRotina, {STR0056, 'VIEWDEF.LOCA259H'        , 0, 4, 0, NIL})  //"Estornar Separacao"


Return aRotina

/*/{Protheus.doc} HeadResum
Cria o Header do resumo 
@type function
@version 25.10
@author Alexandre Circenis
@since 4/17/2025
@return variant, Array do aHeader do resumo
/*/
Function HeadResum()

	aadd(aHeader, {STR0027, "FQ5_XPROD" , "@!"               , TamSx3("FQ5_XPROD")[1] , 0                      , "", USADO, "C", , "V", , , /*"Empty(aCols[n][1])"*/}) //"Produto"
	aadd(aHeader, {STR0028, "FQ5_XQTD"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , , /*"Empty(aCols[n][2])"*/}) //"Quantidade"
	aadd(aHeader, {STR0029, "QSEGUNID"  , "@E 999,999,999.99", TamSx3("FQ5_QTD2")[1]  , TamSx3("FQ5_QTD2")[2]  , "", USADO, "N", , "V", , , /*"Empty(aCols[n][3])"*/}) //"Qtde 2nd"
	aadd(aHeader, {STR0030, "ARMAZEM"   , "@!"               , TamSx3("FPA_LOCAL")[1] , 0                      , "", USADO, "C", , "V", , ,}) //"Armazém"
	aadd(aHeader, {STR0031, "PENDENTE"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) //"Pendente"
    aadd(aHeader, {STR0032, "SEPARADO"  , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) //"Separado"
    aadd(aHeader, {STR0033, "CONFERIDO" , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) //"Conferido"
    aadd(aHeader, {STR0042, "EMBARCADO" , "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) //STR0042 //"Embarcado"
    aadd(aHeader, {STR0034, "NOTAGERADA", "@E 999,999,999.99", TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , "", USADO, "N", , "V", , ,}) //"Nota Emitida"
    aadd(aHeader, {STR0043, "PESLIQ"    , "@E 999,999,999.99", TamSx3("FQ5_PESLIQ")[1], TamSx3("FQ5_PESLIQ")[2], "", USADO, "N", , "V", , ,}) //"Nota Emitida" //"Peso Liquido"
    aadd(aHeader, {STR0044, "PESBRU"    , "@E 999,999,999.99", TamSx3("FQ5_PESBRU")[1], TamSx3("FQ5_PESBRU")[2], "", USADO, "N", , "V", , ,}) //"Nota Emitida" //"Peso Bruto"
    aadd(aHeader, {STR0054, "M3"        , "@E 999,999,999.99", TamSx3("FQ5_M3")[1]    , TamSx3("FQ5_M3")[2]    , "", USADO, "N", , "V", , ,}) //"Nota Emitida" //"m3"

Return
/*/{Protheus.doc} ColResum
Retorna os dados para o aCols do resumo
@type function
@version 25.10
@author Alexandre Circenis
@since 4/17/2025
@return variant, Array com os dados para o acols de resumo
/*/
Static Function ColResum()
Local aArea    := GetArea()
Local aAreaFQ5 := FQ5->(GetArea()) 
Local nLinha   := 0

aCols := {}
// Preenche o Resumo do Browse
FQ5->(dbSetOrder(22))
if FQ5->(dbSeek(xFilial("FQ5")+FQT->FQT_DEMAND)) // Buscar Demanda 
    // Encontrada demanda preencher resumo
    while !FQ5->(Eof()) .and. FQ5->FQ5_FILIAL = xFilial("FQ5") .and. FQ5->FQ5_DEMAND = FQT->FQT_DEMAND
        nLinha := Ascan( aCols, {|x| x[1] = FQ5->FQ5_XPROD})
        if nLinha = 0 
           Aadd( aCols, {FQ5->FQ5_XPROD,0,0,Posicione("FPA",1,xFilial("FPA")+FQ5->FQ5_AS, "FPA_LOCAL"),0,0,0,0,0,0,0,0,.F.}) 
           nLinha := Len(aCols)
        endif
        aCols[nLinha, 2] += FQ5->FQ5_XQTD
        aCols[nLinha, 3] += FQ5->FQ5_QTD2
        if FQ5->FQ5_STDEMA = '1'
            aCols[nLinha, 5] += FQ5->FQ5_XQTD
        elseif FQ5->FQ5_STDEMA = '2'
            aCols[nLinha, 6] += FQ5->FQ5_XQTD
        elseif FQ5->FQ5_STDEMA = '3'
            aCols[nLinha, 7] += FQ5->FQ5_XQTD
        elseif FQ5->FQ5_STDEMA = '4'
            aCols[nLinha, 8] += FQ5->FQ5_XQTD
        elseif FQ5->FQ5_STDEMA = '5'
            aCols[nLinha, 9] += FQ5->FQ5_XQTD
        endif
        aCols[nLinha, 10] += FQ5->FQ5_PESLIQ
        aCols[nLinha, 11] += FQ5->FQ5_PESBRU
        aCols[nLinha, 12] += FQ5->FQ5_M3
        FQ5->(dbSkip())
    enddo
else // Não encontrada incluir linha em Branco
    Aadd( Acols, {"",0,0,"",0,0,0,0,0,0,0,0,.F.})
endif
RestArea(aAreaFQ5)
RestArea(aArea)

Return aCols

/*/{Protheus.doc} Loca259CGF
Troca de folder 
@type function
@version  24.10
@author Alexandre Circenis
@since 2/28/2025
@param nIndo, numeric, Folder para onde está indo
@param oGetD, object, Newgetdados do REsumo
@return variant, True Permitindo a troca
/*/
Function Loca259CGF(nIndo, oGetD )

if nIndo = 2 // Indo para a tela resumo

    oGetD:SetArray(ColResum())
    oGetD:oBrowse:Refresh()
endif

return .t.

/*/{Protheus.doc} EXDEMAN
Exclusão da demanda
@type function
@version 25.10
@author Alexandre Circenis
@since 6/10/2025
@return variant, sem retorno esperado
/*/
Function EXDEMAN()
Local aArea     := FWGetArea()
Local cNum      := FQT->FQT_DEMAND
      
    FQT->(DbSetOrder(1)) 
      

    If FQT->(MsSeek(FWxFilial('FQT')+cNum))

        If Empty(FQT->FQT_ITENS)
          
            While ! FQT->(EoF()) .AND. FQT->FQT_FILIAL == FWxFilial('FQT') .AND. FQT->FQT_DEMAND == cNum
              
                RecLock('FQT', .F.)
                    DbDelete()
                FQT->(MsUnlock())
          
                FQT->(DbSkip())

            EndDo

            FWAlertSuccess(STR0049)             //"Demanda Excluída com sucesso!"

        Else
         
            MsgStop(STR0050)     //"Não é possível Excluir Demandas com A.S. vinculada!"

        EndIf
          
    EndIf
  
    FWRestArea(aArea)
Return()
