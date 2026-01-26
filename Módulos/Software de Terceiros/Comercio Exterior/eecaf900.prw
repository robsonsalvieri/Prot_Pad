#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EECAF900.CH"

#Define SEPARADOR Repl("_", 60) + Chr(13) + Chr(10)

/*
Função   : EECAF900
Autor    : Rodrigo Mendes Diaz
Data     : 01/08/18
Objetivo : Cria painel para gerenciamento centralizado das parcelas de câmbio (EEQ)
*/
Function EECAF900()
Local aCoors := FWGetDialogSize( oMainWnd )
Local oDlg, oPanel, oColumn, oLayer :=  FWLayer():new()
Local nPos
Local bFilterOri
//Quando é selecionada uma view com um filtro relacional (acessa outra tabela), o filtro anterior não é removido. Desta forma, caso seja selecionada uma View relacional primeiro remove a view anterior antes de aplicar
Local lAtuView := .T., bAtuView := {|| If(lAtuView .And. ValType(oBrwCambio:oBrowseUI:oViewWidget:getviewactive()) == "O" .And. aScan(aViewsRelacionais, (cId:= oBrwCambio:oBrowseUI:oViewWidget:getviewactive():cId)) > 0, (lAtuView := .F., oBrwCambio:oBrowseUI:oViewWidget:selectview("FWNOVIEW"), oBrwCambio:oBrowseUI:oViewWidget:selectview(cID), lAtuView := .T.), Nil) }
local lLibAccess := .F.
local lExecFunc  := .F. // existFunc("FwBlkUserFunction") 
local cFiltro    := ""
local cFiltroSQL := ""

Private aViewsRelacionais := {}
Private oMarca := AF900Mark():New()
Private oBrwCambio
Private bTotaliza := {|| MsAguarde({|| Totaliza() }, STR0001) } //"Totalizando parcelas"
//Objetos dos totalizadores (devem ser private para atualização posterior)
Private oMoeda, oTotaRec, oTotaLiq, oTotLiq, oTotMarcado, oTotaPag, oTotPag, oMoeMarcado
//Variáveis com os valores a serem exibidos nos totalizadores (devem ser private para atualização posterior)
Private cMoeTot := "", nTotaRec := 0, nTotaLiq := 0, nTotLiq := 0, nTotaPag := 0, nTotPag := 0, nTotMarcado := 0

// variavel de/para para os filtros
private aFilAF900 := {}

      if lExecFunc
            FwBlkUserFunction(.T.)
      endif

      lLibAccess := AmIIn(29)

      if lExecFunc
            FwBlkUserFunction(.F.)
      endif

      if !lLibAccess
            return nil
      endif

      if !avflags("PAINELCAMBIO")
            MsgStop(STR0003,STR0002) //"Necessário atualizar o sistema para executar essa rotina." , "Aviso"
            Return Nil
      EndIf

      //Cria a tela principal, sem bordas, títulos ou botões
      oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0004,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,) //"Painel de Operações de Câmbio Exportação"

      //Cria o objeto visual principal, que será divido entre browse e totais
      oLayer:Init(oDlg,.F.)
      oLayer:AddCollumn('COL_MAIN',100,.F.)
      oCol := oLayer:getColPanel ('COL_MAIN')
      
      //Define o percentual para o rodapé de acordo com o tamanho mínimo para exibição dos campos: 75 pxls
      nPercBottom := (75 / oCol:nClientHeight)*100
      //Cria as divisões entre browse e rodapé. O tamanho percentual do rodapé será o calculado acima e do browse será o espaço restante
      oLayer:AddWindow('COL_MAIN','WIN_TOP',STR0006,100-nPercBottom,.T.,.f.) //"Parcelas de Cambio"
      oLayer:AddWindow('COL_MAIN','WIN_DOWN', STR0007,nPercBottom,.T.,.f.) //"Totais"

      //Cria o objeto do browse das parcelas na porção superior
      oBrwCambio := FWmBrowse():New()
      oBrwCambio:SetOwner(oLayer:getWinPanel ('COL_MAIN','WIN_TOP'))
      oBrwCambio:SetDescription(STR0005) //"Câmbio - Exportação"
      oBrwCambio:SetAlias("EEQ")
      oBrwCambio:SetMenuDef("EECAF900")
      oBrwCambio:DisableDetails()//Desabilita a exibição dos detalhes do registro

      //Cria o filtro padrão para o Browse. Devem ser exibidas todas as parcelas exceto: Adiantamentos da Fase de Cliente, Pedido e Fornencedor e câmbio tipo 4
//      oBrwCambio:AddFilter(STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' .And. EEQ_TP_CON <> '3'", .T., .T.)  //"Parcelas de Câmbio" //NCF - 04/07/2019
      cFiltro :=  "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' "
      cFiltroSQL := "EEQ_EVENT <> '602' AND EEQ_EVENT <> '605' AND EEQ_EVENT <> '606' AND EEQ_EVENT <> '609' AND EEQ_TIPO <> 'F' "
      cFiltro += " .and. (EEQ_EVENT <> '101' .or. EEQ_CONTMV <> '3') "
      cFiltroSQL += " AND (EEQ_EVENT <> '101' OR EEQ_CONTMV <> '3') "
      oBrwCambio:AddFilter(STR0006, cFiltro, .T., .T.)  //"Parcelas de Câmbio" //NCF - 04/07/2019
      aFilAF900 := {}
//      aAdd( aFilAF900 , { STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' .And. EEQ_TP_CON <> '3'", "EEQ_EVENT <> '602' AND EEQ_EVENT <> '605' AND EEQ_EVENT <> '606' AND EEQ_EVENT <> '609' AND EEQ_TIPO <> 'F' AND EEQ_TP_CON <> '3'"})
      aAdd( aFilAF900 , { STR0006, cFiltro, cFiltroSQL})

      //Cria a coluna do marca/desmarca
      ADD MARKCOLUMN oColumn DATA { || If(oMarca:Marcado(EEQ->(Recno())),'LBOK','LBNO') } DOUBLECLICK {|| AF900Mark() } HEADERCLICK {|| oMarca:MarcaTodos() } OF oBrwCambio

      //Configura as legendas
      aLegendas := GetLegenda(.T.)
      aEval(aLegendas, {|x| oBrwCambio:AddLegend(x[1], x[2], x[3]) })

      //Habilita a exibição de visões e gráficos
      oBrwCambio:SetAttach( .T. )
      //Configura as visões padrão
      oBrwCambio:SetViewsDefault(GetVisions())
      //Define a opção de marcação como a opção padrão do browse no duplo clique sobre os registros
      If (nPos := aScan(Menudef(), {|x| x[2] == "AF900MARK" })) > 0
            oBrwCambio:SetExecuteDef(nPos)
      EndIf
      //Força a exibição do botão fechar o browse para fechar a tela
      oBrwCambio:ForceQuitButton()
      //Ativa o Browse
      oBrwCambio:Activate()

      //Cria os objetos dos totalizadores
      CriaTotalizador(oLayer:getWinPanel('COL_MAIN','WIN_DOWN'))
      //Inicializa os valores dos totalizadores
      Eval(bTotaliza)

      //Ajusta o codeblock do filtro para forçar a execução do totalizador após filtrar/remover filtros
      bFilterOri := oBrwCambio:oFwFilter:bFilter
      oBrwCambio:oFwFilter:setExecute(&("{ || Eval(bFilterOri), Eval(bTotaliza) }"))

      //Altera o codeblock de alteração das visões para avaliar os casos de filtro relacional e executar o totalizador
      bExecVOri := oBrwCambio:oBrowseUI:oViewWidget:bRefresh
      oBrwCambio:oBrowseUI:oViewWidget:SetBRefresh(&("{|| Eval(bAtuView), Eval(bExecVOri), Eval(bTotaliza) }"))

      If EasyEntryPoint("AF900BROWSE")
            ExecBlock("AF900BROWSE", .F., .F., Nil)
      EndIf

      ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*
Função     : MenuDef()
Objetivo   : Define as opções dos botões do Browse
*/
Static Function MenuDef()
Local aRotina := {}
Local aRotAdic

      aAdd(aRotina, {STR0008,"AF900REC",0,4}) //"Receber no Exterior"
      aAdd(aRotina, {STR0009,"AF900LIQ",0,4}) // "Liquidar"
      aAdd(aRotina, {STR0010,"AF900EREC",0,4}) //"Estornar Recebimento no Exterior"
      aAdd(aRotina, {STR0011,"AF900ELIQ",0,4}) //"Estornar Liquidação"
      aAdd(aRotina, {STR0012,"AF900PAG",0,4}) //"Pagar"
      aAdd(aRotina, {STR0013,"AF900EPAG",0,4}) //"Estornar Pagamento"
      aAdd(aRotina, {STR0101,"AF900ALTP",0,4}) //"Alterar Parcelas"
      aAdd(aRotina, {STR0102,"AF900EXCP",0,4}) //"Excluir"
      aAdd(aRotina, {STR0015,"AF900ALTE",0,4}) //"Alterar por Embarque"
      aAdd(aRotina, {STR0016,"AF900Legenda",0,4}) //"Legenda"
      aAdd(aRotina, {STR0017,"AF900MARK",0,4}) //"Marca/Desmarca"

      If EasyEntryPoint("AF900MNU")
            aRotAdic := ExecBlock("AF900MNU", .F., .F., Nil)
      EndIf

	If ValType(aRotAdic) == "A"
		aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf

Return aRotina

/*
Função     : AF900Legenda()
Objetivo   : Exibe tela com o detalhamento das legendas do browse
*/
Function AF900Legenda()
Return BrwLegenda(STR0006, STR0016, GetLegenda())//"Parcelas de Câmbio" , 'Legendas'

/*
Função     : GetLegenda
Objetivo   : Retorna as opções de legenda para o browse
Parâmetro  : lFiltro - Indica se deve retornar as condições de filtro, além das informações das cores e títulos (Default Falso)
*/
Static Function GetLegenda(lFiltro)
Local aLegenda := {}
local lVarFil := isMemVar("aFilAF900")
local cFiltro := ""

Default lFiltro := .F.

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_ABERTO")
            aAdd(aLegenda[Len(aLegenda)],cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0018, cFiltro, RetFilter("REC_ABERTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_VERDE")
      aAdd(aLegenda[Len(aLegenda)], STR0018 ) //"Aguardando Recebimento no Exterior"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_ALIQUIDAR_EMBARCADO") + " .Or. " + RetFilter("REC_ALIQUIDAR_NAOEMBARCADO") + " .Or. " + RetFilter("ADIANTAMENTO_TRANSFERIR")
            aAdd(aLegenda[Len(aLegenda)], cFiltro )
            if lVarFil
                  aAdd( aFilAF900 , { STR0019, cFiltro ,  RetFilter("REC_ALIQUIDAR_EMBARCADO",,.T.) + " OR " + RetFilter("REC_ALIQUIDAR_NAOEMBARCADO",,.T.) + " OR " + RetFilter("ADIANTAMENTO_TRANSFERIR",,.T.) })
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_AZUL")
      aAdd(aLegenda[Len(aLegenda)], STR0019 ) //"Aguardando Contratação de Câmbio a Receber"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("PAG_ABERTO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0020, cFiltro, RetFilter("PAG_ABERTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_LARANJA")
      aAdd(aLegenda[Len(aLegenda)], STR0020 ) //"Aguardando Pagamento"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_LIQUIDADO_CAMBIO") + " .Or. " + RetFilter("PAG_FECHADO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0021,  cFiltro,  RetFilter("REC_LIQUIDADO_CAMBIO",,.T.) + " OR " + RetFilter("PAG_FECHADO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_VERMELHO")
      aAdd(aLegenda[Len(aLegenda)], STR0021 ) //"Câmbio a Receber Contratado/Pagamento Efetuado"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_LIQUIDADO_ADIANTAMENTO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0022, cFiltro, RetFilter("REC_LIQUIDADO_ADIANTAMENTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_PRETO")
      aAdd(aLegenda[Len(aLegenda)], STR0022 ) //"Adiantamento Liquidado em Fase de Pedido/Cliente"

Return aLegenda

/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("EEQ")
Local aContextos := if( AvFlags("NACIONALIZACAO_RA_CLIENTE_SEM_EMBARQUE") , {"REC_ABERTO", "REC_ALIQUIDAR_EMBARCADO", "REC_ALIQUIDAR_NAOEMBARCADO", "ADIANTAMENTO_TRANSFERIR", "REC_LIQUIDADO_CAMBIO", "PAG_ABERTO", "PAG_FECHADO"}, {"REC_ABERTO", "REC_ALIQUIDAR_EMBARCADO", "REC_ALIQUIDAR_NAOEMBARCADO", "REC_LIQUIDADO_CAMBIO", "PAG_ABERTO", "PAG_FECHADO"})
Local cFiltro
Local i
local cNomeFil := ""
local lVarFil := isMemVar("aFilAF900")

      If aScan(aColunas, "EEQ_FILIAL") == 0
            aAdd(aColunas, "EEQ_FILIAL")
      EndIf

      For i := 1 To Len(aContextos)
            cFiltro := RetFilter(aContextos[i])
            cNomeFil := RetFilter(aContextos[i], .T.)
            if lVarFil
                  aAdd( aFilAF900 , { cNomeFil, cFiltro, RetFilter(aContextos[i],,.T.)})
            endif
            If At("EEC", cFiltro) > 0//Se o filtro acionar a tabela EEC, indica que é uma view relacional
                  aAdd(aViewsRelacionais, AllTrim(Str(i)))
            EndIf
            oDSView    := FWDSView():New()
            oDSView:SetName(AllTrim(Str(i)) + "-" + cNomeFil)
            oDSView:SetPublic(.T.)
            oDSView:SetCollumns(aColunas)
            oDSView:SetOrder(1)
            oDSView:AddFilter(AllTrim(Str(i)) + "-" + cNomeFil, cFiltro)
            oDSView:SetID(AllTrim(Str(i)))
            oDsView:SetLegend(.T.)
            aAdd(aVisions, oDSView)
      Next

Return aVisions

/*
Função   : CriaTotalizador(oLayer)
Objetivo : Criar os objetos com os totalizadores da tela
Parâmetro: oPanel - Painel onde os objetos serão criados
*/
Static Function CriaTotalizador(oPanel)
Local cPicVal := AvSx3("EEQ_VL", AV_PICTURE)
Local nCol :=2, nLine := 2

      @ nLine, nCol SAY STR0023 of oPanel Pixel SIZE 30,08 //"Moeda:"
      nCol += 20
      @ nLine-1, nCol ComboBox oMoeda VAR cMoeTot Items GetMoedas() Size 35, 08 OF oPanel On Change Eval(bTotaliza) Pixel
      nCol += 37
      @ nLine, nCol SAY STR0024 of oPanel Pixel SIZE 30,08 //"A Receber"
      nCol += 28
      @ nLine-1, nCol MSGET oTotaRec Var nTotaRec SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0025 of oPanel Pixel SIZE 30,08 //"A Liquidar"
      nCol += 28
      @ nLine-1, nCol MSGET oTotaLiq Var nTotaLiq SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0026 of oPanel Pixel SIZE 30,08 //"Liquidado"
      nCol += 28
      @ nLine-1, nCol MSGET oTotLiq Var nTotLiq SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0027 of oPanel Pixel SIZE 30,08 //"A Pagar"
      nCol += 25
      @ nLine-1, nCol MSGET oTotaPag Var nTotaPag SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0028 of oPanel Pixel SIZE 30,08 //"Pago"
      nCol += 20
      @ nLine-1, nCol MSGET oTotPag Var nTotPag SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0029 of oPanel Pixel SIZE 30,08 //"Marcados"
      nCol += 28
      @ nLine, nCol SAY oMoeMarcado VAR oMarca:cMoeda of oPanel Pixel SIZE 30,08
      nCol += 18
      @ nLine-1, nCol MSGET oTotMarcado Var nTotMarcado SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY

Return Nil

/*
Função   : GetMoedas()
Objetivo : Retorna array com todos os códigos de moedas disponíveis entre as parcelas de câmbio da tabela EEQ
*/
Static Function GetMoedas()
Local aMoedas := {""}
Local nPos

      BeginSql Alias "MOEDAS"
            Select EEQ_MOEDA From %table:EEQ% Where %NotDel% Group By EEQ_MOEDA
      EndSql
      While MOEDAS->(!Eof())
            aAdd(aMoedas, MOEDAS->EEQ_MOEDA)
            MOEDAS->(DbSkip())
      EndDo
      MOEDAS->(DbCloseArea())
      //Seta a varíavel do combobox do filtro de moedas com a moeda dolar caso exista alguma parcela nesta moeda. Caso negativo, considera a primeira moeda encontrada.
      If Len(aMoedas) > 0
            If (nPos := aScan(aMoedas, {|x| AllTrim(x) == "US$" })) > 0
                  cMoeTot := aMoedas[nPos]
            Else
                  cMoeTot := aMoedas[1]
            EndIf
      EndIf

Return aMoedas

/*
Função     : Totaliza()
Objetivo   : Totaliza os valores da parcelas para exibição na barra de totais
*/
Static Function Totaliza()
local aOrd      := SaveOrd("EEQ")
local cQuery    := ""
local cAliasQry := ""
local oQuery    := nil
local aFilter   := {}
local nFilter   := 0

nTotaRec := 0
nTotaLiq := 0
nTotLiq  := 0
nTotaPag := 0
nTotPag  := 0

if !empty(cMoeTot)
      cQuery := " SELECT "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE = ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaRec, "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaLiq, "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotLiq, "
      cQuery += " SUM ( CASE WHEN ( EEQ_TIPO = 'P' AND EEQ_PGT =  ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaPag, "
      cQuery += " SUM ( CASE WHEN ( EEQ_TIPO = 'P' AND EEQ_PGT <> ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotPag "
      cQuery += " FROM " + RetSqlName('EEQ') + " EEQ "
      cQuery += " LEFT JOIN " + RetSqlName('EEC') + " EEC ON  EEC.D_E_L_E_T_ = ' ' AND EEC_FILIAL = EEQ_FILIAL AND EEC_PREEMB = EEQ_PREEMB " 
      cQuery += " WHERE EEQ.D_E_L_E_T_ = ' ' AND EEQ_MOEDA = ? " 

      if isMemVar("oBrwCambio") .and. len(oBrwCambio:oFWFilter:aFilter) > 0
            aFilter := aClone( oBrwCambio:oFWFilter:aFilter ) //:GetFilter()
      endif
 
      for nFilter := 1 to len(aFilter)
            // filtros selecionados
            if aFilter[nFilter][6]
                  cQuery += TrataWhere( nFilter, aFilter[nFilter])
            endif
      next

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,cMoeTot)
      cQuery := oQuery:GetFixQuery()

      cAliasQry := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
            nTotaRec := (cAliasQry)->TotaRec
            nTotaLiq := (cAliasQry)->TotaLiq
            nTotLiq  := (cAliasQry)->TotLiq
            nTotaPag := (cAliasQry)->TotaPag
            nTotPag  := (cAliasQry)->TotPag
      endif
      (cAliasQry)->(dbCloseArea())

      oQuery:Destroy()
      FwFreeObj(oQuery)
endif

RestOrd(aOrd, .T.)

oTotaRec:Refresh()
oTotaLiq:Refresh()
oTotLiq:Refresh()
oTotaPag:Refresh()
oTotPag:Refresh()

Return Nil

static function TrataWhere(nFilter, aFilter)
      local cRet       := ""
      local lVarFil    := isMemVar("aFilAF900")
      local nPos       := 0
      local cNomeFil   := ""
      local cFilADVPL  := ""
      local nPosFil    := 0
      local cExpr      := ""
      local nPosIni    := 0
      local nPosFim    := 0
      local cFunExp    := ""
      local cFunExpRun := ""
      local nPosField  := 0
      local nPosOper   := 0
      local nPosExpr   := 0
      local cField     := ""
      local cOper      := ""
      local cExpres    := ""
      local cExpNew    := ""
      local cIN        := ""
      local aInfIN     := {}
      local nIn        := 0
      local nOper      := 0
      local cOR_AND    := ""
      local aExpres    := {}
      local aFiltro    := {}
      local nFiltro    := 0
      local cFiltro    := ""
      local lAddCond   := .F.
      local cTipoCpo   := ""

      default nFilter   := 0 
      default aFilter   := {}

      cNomeFil := alltrim( substr( aFilter[1], at("-", aFilter[1]) + 1) )
      cFilADVPL := alltrim( StrTran(aFilter[2],"!=", "<>") )

      // filtros padrões do sistema
      if lVarFil .and. ( nPos := aScan( aFilAF900, { |X| cNomeFil == alltrim(X[1]) .and. alltrim(X[2]) == cFilADVPL}) ) > 0
            cRet := " AND ( " + aFilAF900[nPos][3] + " ) "
      elseif len(aFilter) > 0
            // filtro com pergunte
            if aFilter[7] .and. ( nPosFil := aScan( oBrwCambio:oFWFilter:aObjFilAsk , { |X| X[1]:cProfielId == cValToChar(nFilter) } ) ) > 0
                  cFiltro := oBrwCambio:oFWFilter:aObjFilAsk[nPosFil,1]:cExpression
                  aFiltro := oBrwCambio:oFWFilter:aObjFilAsk[nPosFil,2]
            else
                  cFiltro := if( empty(aFilter[3]), aFilter[2], aFilter[3])
                  aFiltro := aFilter[4]
            endif

            if len(aFiltro) > 0 .and. !empty(cFiltro)

                  nPosField := aScan( aFiltro , { |X| X[2] == "FIELD"} )
                  nPosOper := aScan( aFiltro , { |X| X[2] == "OPERATOR"} )
                  nPosExpr := aScan( aFiltro , { |X| X[2] == "EXPRESSION"} )
                  cField := if( nPosField == 0, "", aFiltro[nPosField][1])
                  cExpres := if( nPosExpr == 0, "", aFiltro[nPosExpr][1])
                  cOper := if(nPosOper == 0, "", aFiltro[nPosOper][1])
                  nOper := aScan( aFiltro , { |X| empty(X[2])})
                  cExpNew := ""
                  aExpres := {}
                  cExpr := cFiltro
                  cFiltro := "" 

                  while nPosOper > 0
                        lAddCond := .F.
                        cTipoCpo := if( !empty(cField), getSX3Cache(cField,"X3_TIPO"), "")
                        if  cTipoCpo == "C" .and. (( cOper == '$' ) .or. ( cOper == '!x' ) .or. ( cOper == '..' ) .or. ( cOper == '!.' ))
                              cExpres := if( len(aFiltro[nPosExpr]) > 5 .and. !aFiltro[nPosExpr][6], upper(aFiltro[nPosExpr][1]), aFiltro[nPosExpr][1])
                              cExpNew := "("
                              if (( cOper == '$' ) .or. ;// Esta contido
                              ( cOper == '!x' ) )// Nao Esta contido
                                    aInfIN := StrTokArr(AllTrim(cExpres), ',')
                                    cIN := ""
                                    for nIn := 1 to len(aInfIN)              
                                          cIN += if( !empty(aInfIN[nIn]), "'" + aInfIN[nIn] + "',",  "")
                                    next nIn
                                    cIN := SubStr(cIN, 1, len(cIN)-1)
                                    cIN := if(empty(cIN), "''", cIN)
                                    if !empty(cIN)
                                          cExpNew += cField + if( cOper == '$' , " IN(" + cIN + ")" ,  " NOT IN(" + cIN + ")")
                                    endif
                              elseif (( cOper == '..' ) .or. ; // Contem a expressao
                                    ( cOper == '!.' ))// Nao Contem a expressao
                                    cExpNew += cField + if( ( cOper == '..' ) , " LIKE " , " NOT LIKE ") + "'%" + if( empty(cExpres) , cExpres,  alltrim(cExpres)) + "%'"
                              endif
                              cExpNew += ")"
                              lAddCond := .T.
                              aAdd( aExpres, cExpNew )
                        elseif cTipoCpo == "D" // !(cOper == '$') .and. !(cOper == '!x') .and. !(cOper == '..') .and. !(cOper == '!.')
                              nPosIni := at("#", cExpr )
                              nPosFim := at("#", cExpr,  nPosIni + 1)
                              if nPosIni > 0 .and. nPosFim > 0
                                    cFunExp := substr( cExpr, nPosIni, nPosFim - nPosIni + 1)
                                    if !empty( cFunExp )
                                          cFunExpRun := &(StrTran( cFunExp, "#", ""))
                                          cFunExpRun := StrTran( StrTran( upper( cFunExpRun ) , "DTOS", ""), "DTOC", "")
                                          lAddCond := .T.
                                          aAdd( aExpres, cFunExpRun)
                                    endif
                              endif
                        else
                              cExpNew := "("
                              cExpNew += cField + " " + cOper + " "
                              cExpNew += if( cTipoCpo == "C" , "'" + cExpres + "'" , if( cTipoCpo == "D" ,  "'" + DTOS(cExpres) + "'" , cValTochar(cExpres)))
                              cExpNew += ")"
                              lAddCond := .T.
                              aAdd( aExpres, cExpNew )
                        endif

                        if nOper > 0 .and. lAddCond
                              cOR_AND := StrTran( StrTran( aFiltro[nOper][1] , ".AND.", "AND") , ".OR.", "OR" )
                              aAdd( aExpres, cOR_AND )
                        endif

                        nPosField := aScan( aFiltro , { |X| X[2] == "FIELD"}, nPosField + 1 )
                        nPosOper := aScan( aFiltro , { |X| X[2] == "OPERATOR"}, nPosOper + 1 )
                        nPosExpr := aScan( aFiltro , { |X| X[2] == "EXPRESSION"}, nPosExpr + 1 )
                        nOper := aScan( aFiltro , { |X| empty(X[2])}, nOper + 1 )
                        cField := if( nPosField == 0, "", aFiltro[nPosField][1])
                        cExpres := if( nPosExpr == 0, "", aFiltro[nPosExpr][1])
                        cOper := if(nPosOper == 0, "", aFiltro[nPosOper][1])

                  end

                  if len(aExpres) > 0
                        for nFiltro := 1 to len(aExpres)
                              cFiltro += aExpres[nFiltro]
                        next
                  endif
            endif
            if !empty(cFiltro)
                  cRet := " AND ( " + StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( cFiltro , '"', "'" ), "==", "=" ) , ".AND.", "AND") , ".OR.", "OR" ), "ALLTRIM", ""), "!=", "<>") + " ) "
            endif
      endif

return cRet

/*
Função     : RetFilter(cTipo)
Objetivo   : Retorna a chave ou nome do filtro da tabela EEQ de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome, lExpSQL)
Local cRet := ""
Default lNome := .F.
default lExpSQL := .F.

      Do Case
            Case cTipo == "REC_ABERTO" .And. lExpSQL
                  cRet := " ( EEQ_TIPO <> 'P' AND EEQ_DTCE = ' ' ) "
            Case cTipo == "REC_ABERTO" .And. !lNome
                  cRet := " ( EEQ->EEQ_TIPO <> 'P' .And. Empty(EEQ->EEQ_DTCE) ) "
            Case cTipo == "REC_ABERTO" .And. lNome
                  cRet := STR0084 //"Parcelas a Receber"

            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. lExpSQL
                  cRet := " ( (EEQ_TIPO = 'R' OR EEQ_TIPO = 'A') AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' AND EEC_DTEMBA <> ' ' AND EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. !lNome
                  cRet := " ( (EEQ->EEQ_TIPO == 'R' .Or. EEQ->EEQ_TIPO == 'A') .And. !Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT) .And. !Empty(Posicione('EEC', 1, EEQ->(EEQ_FILIAL+EEQ_PREEMB), 'EEC_DTEMBA')) .And. EEQ->EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. lNome
                  cRet := STR0085 // "Parcelas a Receber não Liquidadas - Processo Embarcado"

            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. lExpSQL
                  cRet := " ( (EEQ_TIPO = 'R' OR EEQ_TIPO = 'A') AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' AND EEC_DTEMBA = ' ' AND EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. !lNome
                  cRet := " ( (EEQ->EEQ_TIPO == 'R' .Or. EEQ->EEQ_TIPO == 'A') .And. !Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT) .And. Empty(Posicione('EEC', 1, EEQ->(EEQ_FILIAL+EEQ_PREEMB), 'EEC_DTEMBA')) .And. EEQ->EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. lNome
                  cRet := STR0086 // "Parcelas a Receber não Liquidadas - Processo Não Embarcado"

            Case cTipo == "ADIANTAMENTO_TRANSFERIR" .And. lExpSQL
                  cRet := " ( EEQ_TIPO = 'A' AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' AND EEQ_CONTMV = '3' ) "
            Case cTipo == "ADIANTAMENTO_TRANSFERIR" .And. !lNome
                  cRet := " ( EEQ->EEQ_TIPO = 'A' .And. !Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_CONTMV == '3' ) "
            Case cTipo == "ADIANTAMENTO_TRANSFERIR" .And. lNome
                  cRet := STR0134 // "Parcelas a Receber não Liquidadas - Adiantamentos"

            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. lExpSQL
                  cRet := " ( (EEQ_TIPO = 'R' OR EEQ_TIPO = 'A') AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' ) "
            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. !lNome
                  cRet := " ( (EEQ->EEQ_TIPO == 'R' .Or. EEQ->EEQ_TIPO == 'A') .And. !Empty(EEQ->EEQ_DTCE) .And. !Empty(EEQ->EEQ_PGT) ) "
            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. lNome
                  cRet := STR0087 // "Parcelas a Receber Liquidadas"

            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. lExpSQL
                  cRet := " ( EEQ_TIPO = 'A' AND EEQ_MODAL = '1'  AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' AND EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. !lNome
                  cRet := " ( EEQ->EEQ_TIPO == 'A' .And. EEQ->EEQ_MODAL == '1' .And. !Empty(EEQ->EEQ_DTCE) .And. !Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_CONTMV <> '3' ) "
            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. lNome
                  cRet := STR0088 // "Adiantamento Liquidado em Fase de Pedido/Cliente"

            Case cTipo == "PAG_ABERTO" .And. lExpSQL
                  cRet := " ( EEQ_TIPO = 'P' AND ((EEQ_MODAL = ' ' AND EEQ_PGT = ' ') OR (EEQ_TP_CON <> '4' AND EEQ_PGT = ' ') OR (EEQ_TP_CON = '4' AND ((EEQ_MODAL = '1' AND EEQ_PGT = ' ') OR (EEQ_MODAL = '2' AND EEQ_DTCE = ' ')))) ) "
            Case cTipo == "PAG_ABERTO" .And. !lNome
                  cRet := " ( EEQ->EEQ_TIPO == 'P' .And. ((Empty(EEQ->EEQ_MODAL) .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON <> '4' .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON == '4' .And. ((EEQ->EEQ_MODAL == '1' .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_MODAL == '2' .And. Empty(EEQ->EEQ_DTCE))))) ) "
            Case cTipo == "PAG_ABERTO" .And. lNome
                  cRet := STR0089 // "Parcelas a Pagar"

            Case cTipo == "PAG_FECHADO" .And. lExpSQL
                  cRet := " ( EEQ_TIPO = 'P' AND ((EEQ_MODAL = ' ' AND EEQ_PGT <> ' ') OR (EEQ_TP_CON <> '4' AND EEQ_PGT <> ' ') OR (EEQ_TP_CON = '4' AND ((EEQ_MODAL = '1' AND EEQ_PGT <> ' ') OR (EEQ_MODAL = '2' AND EEQ_DTCE <> ' ')))) ) "
            Case cTipo == "PAG_FECHADO" .And. !lNome
                  cRet := " ( EEQ->EEQ_TIPO == 'P' .And. ((Empty(EEQ->EEQ_MODAL) .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON <> '4' .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON == '4' .And. ((EEQ->EEQ_MODAL == '1' .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_MODAL == '2' .And. !Empty(EEQ->EEQ_DTCE))))) ) "
            Case cTipo == "PAG_FECHADO" .And. lNome
                  cRet := STR0090 // "Parcelas a Pagar - Liquidadas ou Pagas no Exterior"

      EndCase

Return cRet

/*
Classe  : AF900Mark
Objetivo: Gerenciar a marcação das parcelas no browse de câmbio
Autor   : Rodrigo Mendes Diaz
Data    : 01/08/18
*/
Class AF900Mark

      Data aParcelas
      Data nTotal
      Data cMoeda
      Data aSoftLock
      Data cNrOp
      Data lNrOpEFF

      Method New() Constructor
      Method Marca()
      Method Desmarca()
      Method MarcaTodos()
      Method Marcado()
      Method LenMarcados()
      Method GetMoeda()
      Method SetMoeda(cCodMoeda)
      Method GetNrOp()
      Method SetNrOp(cNrOp)
      Method Valida()
      Method GetMarcados()
      Method PossuiParcela()
      Method ReservaRegistros()
      Method LiberaRegistros()
      Method SetParcela(nRecParc, cTipo, nValor)
      Method SetContratoEFF()
      Method isContratoEFF()
      Method MarkAllEFF()

EndClass

/*
Método    : New()
Classe    : AF900Mark
Objetivo  : Construtor da Classe
*/
Method New() Class AF900Mark

      Self:nTotal    := 0
      Self:aParcelas := {}
      Self:cMoeda    := ""
      Self:aSoftLock := {}
      Self:lNrOpEFF  := .F.

Return Self

/*
Método    : Marca(nRec, lRefresh)
Classe    : AF900Mark
Objetivo  : Marca a parcela, validando antes se a parcela é da mesma moeda das parcelas já marcadas
Parâmetros: nRec - Recno a ser marcado
            lAtuStatus - Quando chamado após a integração da parcela, para que seja atualizado o Tipo (Status) da aprcela. É chamado um desmarca e um marca em seguida
            lRefresh - Indica se será efetuado o refresh do browse principal
*/
Method Marca(nRec, lRefresh, lAtuStatus) Class AF900Mark
Local lRet := .F.
Local cTipo := ""
Local cSolucao := ""
Default lAtuStatus := .F.

Begin Sequence
      If EEQ->(Recno()) <> nRec
            EEQ->(DbGoTo(nRec))
      EndIf

      If Self:GetNrOp() == Nil
             Self:SetNrOp(EEQ->EEQ_NROP)
      ElseIf Self:GetNrOp() <> EEQ->EEQ_NROP
            EasyHelp(STR0091,STR0002,STR0092)//"Não é possível marcar parcelas que possuem Número de Operação diferentes."###"Devem ser marcadas parcelas com o mesmo Número de Operação."
            Break
      EndIf

      If !lAtuStatus .And. Self:LenMarcados() > 0 .And. ((Self:isContratoEFF() .And. !IsContrEFF()) .Or. (!Self:isContratoEFF() .And. IsContrEFF()))
            If Self:isContratoEFF()
                  cSolucao := STR0095 + Alltrim(Self:GetNrOp()) + STR0096 //"Devem ser marcadas parcelas que possuem vínculo com contrato de Financiamento "####" no Easy Financing (SIGAEFF)." 
            Else
                  cSolucao := STR0097//"Devem ser marcadas parcelas que não possuem vínculo com contrato de Financiamento no Easy Financing (SIGAEFF)."
            EndIf
            EasyHelp(STR0098,STR0002,cSolucao)//"Não é possível marcar parcelas que estão vinculadas a um contrato de Financiamento com parcelas que não possuem o vinculo."###""
            Break
      EndIf 

      If Empty(Self:GetMoeda())
            Self:SetMoeda(EEQ->EEQ_MOEDA)
      ElseIf Self:GetMoeda() <> EEQ->EEQ_MOEDA
            If MsgYesNo( STR0030,STR0002 ) //"A parcela selecionada é de uma moeda diferente das parcelas já marcadas. Deseja demarcar as parcelas já marcadas para prosseguir?", "Aviso"
                  Self:SetMoeda(EEQ->EEQ_MOEDA)
            EndIf
      EndIf

      If Self:GetMoeda() == EEQ->EEQ_MOEDA
            Do Case
                  Case &(RetFilter("REC_ABERTO"))
                        cTipo := "REC_ABERTO"
                  Case &(RetFilter("REC_ALIQUIDAR_EMBARCADO"))
                        cTipo := "REC_ALIQUIDAR_EMBARCADO"
                  Case &(RetFilter("REC_ALIQUIDAR_NAOEMBARCADO"))
                        cTipo := "REC_ALIQUIDAR_NAOEMBARCADO"
                  Case &(RetFilter("ADIANTAMENTO_TRANSFERIR"))
                        cTipo := "ADIANTAMENTO_TRANSFERIR"
                  Case &(RetFilter("REC_LIQUIDADO_CAMBIO"))
                        cTipo := "REC_LIQUIDADO_CAMBIO"
                  Case &(RetFilter("REC_LIQUIDADO_ADIANTAMENTO"))
                        cTipo := "REC_LIQUIDADO_ADIANTAMENTO"
                  Case &(RetFilter("PAG_ABERTO"))
                        cTipo := "PAG_ABERTO"
                  Case &(RetFilter("PAG_FECHADO"))
                        cTipo := "PAG_FECHADO"
            EndCase
            
            //Caso seja a primeira parcela marcada, tenha integração com SIGAEFF Habilitada e parcela possua contrato do EFF vinculada
            If !lAtuStatus .And. Self:LenMarcados() == 0 .And. EasyGParam("MV_EEC_EFF",,.F.) .And. !Empty(Self:GetNrOp()) .And. IsContrEFF()
                  lRet := Self:MarkAllEFF(EEQ->(Recno()), cTipo, RetFilter(cTipo,,.T.), Self:GetNrOp(), IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"), EEQ->EEQ_BANC) //Verifica se irá marcar todas as parcelas do mesmo contrato
            Else
                  //aAdd(Self:aParcelas, {EEQ->(Recno()), cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON})
                  Self:SetParcela(EEQ->(Recno()), cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)
                  lRet := .T.
            EndIf
      EndIf
      If lRet
            nTotMarcado := Self:nTotal
            oTotMarcado:Refresh()
            oMoeMarcado:Refresh()
      EndIf
      If lRefresh
            oBrwCambio:Refresh()
      EndIf

End Sequence
Return lRet

/*
Método    : Desmarca(nRec, lRefresh)
Classe    : AF900Mark
Objetivo  : Desmarca a parcela
Parâmetros: nRec - Recno a ser desmarcado
            lRefresh - Indica se será efetuado o refresh do browse principal
*/
Method Desmarca(nRec, lRefresh) Class AF900Mark
Local nPos

      If (nPos := aScan(Self:aParcelas, {|x| x[1] == nRec })) > 0
            Self:nTotal -= Self:aParcelas[nPos][3]
            aDel(Self:aParcelas, nPos)
            aSize(Self:aParcelas, Len(Self:aParcelas)-1)
      EndIf
      If Empty(Self:aParcelas)
            Self:SetMoeda("")
            Self:SetNrOp(Nil)
            Self:SetContratoEFF(.F.)
      EndIf
      nTotMarcado := Self:nTotal
      oTotMarcado:Refresh()
      oMoeMarcado:Refresh()
      If lRefresh
            oBrwCambio:LineRefresh()
      EndIf

Return .T.

/*
Método    : PossuiParcela(cTipo)
Classe    : AF900Mark
Objetivo  : Verifica se existe alguma parcela marcada do tipo informado
Parâmetro : cTipo - Código do tipo de parcela
*/
Method PossuiParcela(cTipo) Class AF900Mark
Return aScan(Self:aParcelas, {|x| x[2] $ cTipo }) > 0

/*
Método    : Marcado(nRecno)
Classe    : AF900Mark
Objetivo  : Retorna .t./.f. caso o recno informado esteja marcado
Parâmetro : nRecno - Recno do registro da tabela EEQ a ser verificado
*/
Method Marcado(nRecno) Class AF900Mark
Return aScan(Self:aParcelas, {|x| x[1] == nRecno}) > 0

/*
Método    : GetMarcados()
Classe    : AF900Mark
Objetivo  : Retorna cópia do array com as parcelas marcadas
*/
Method GetMarcados() Class AF900Mark
Return aClone(Self:aParcelas)

/*
Método    : LenMarcados()
Classe    : AF900Mark
Objetivo  : Retorna a quantidade de parcelas marcadas
*/
Method LenMarcados() Class AF900Mark
Return Len(Self:aParcelas)

/*
Método    : GetMoeda()
Classe    : AF900Mark
Objetivo  : Retorna a moeda definida como padrão para marcação
*/
Method GetMoeda() Class AF900Mark
Return Self:cMoeda

/*
Método    : SetMoeda(cCodMoeda)
Classe    : AF900Mark
Objetivo  : Define a moeda para validação das parcelas a serem marcadas
Parâmetros: cCodMoeda - Código da moeda
*/
Method SetMoeda(cCodMoeda) Class AF900Mark
      If Self:cMoeda <> cCodMoeda
            If Self:LenMarcados() > 0//Caso tenha mudado a moeda e existam parcelas marcadas, desmarca estas parcelas
                  Self:MarcaTodos(.T.,, .F.)
            EndIf
            Self:cMoeda := cCodMoeda
      EndIf
Return Self:cMoeda


/*
Método    : GetNrOp()
Classe    : AF900Mark
Objetivo  : Retorna o Numero da Operacao (EEQ_NROP) definida como padrão para marcação
*/
Method GetNrOp() Class AF900Mark
Return Self:cNrOp

/*
Método    : SetNrOp(cNrOp)
Classe    : AF900Mark
Objetivo  : Define o número de operação (EEQ_NROP) para validação das parcelas a serem marcadas
Parâmetros: cNrOp - Código da Operação
*/
Method SetNrOp(cNrOp) Class AF900Mark
      If Self:cNrOp <> cNrOp
            Self:cNrOp := cNrOp
            If cNrOp <> nil .And. IsContrEFF()
                  Self:SetContratoEFF(.T.)
            EndIf
      EndIf
Return Self:cNrOp

/*
Método    : MarcaTodos(lDesmarca, cNaoDesmarca, lRefresh)
Classe    : AF900Mark
Objetivo  : Efetua a marcação ou desmarcação de todas as parcelas da mesma moeda (já definida anteriomente no atributo cMoeda).
Parâmetros: lDesmarca - Indica que será feita a desmarcação (default - marcação)
            cNaoDesmarca - Se informado, não serão desmarcadas parcelas do código de ação informado
            lRefresh - Indica se será feito o refresh do browse
*/
Method MarcaTodos(lDesmarca, cNaoDesmarca, lRefresh) Class AF900Mark
Local aOrd, nPos
Local lMV_EECEFF := EasyGParam("MV_EEC_EFF",,.F.)

Default lDesmarca := !Empty(Self:aParcelas)
Default cNaoDesmarca := ""
Default lRefresh := .T.

      If lDesmarca
            If Empty(cNaoDesmarca)
                  Self:aParcelas := {}
                  Self:nTotal := 0
                  Self:SetMoeda("")
                  Self:SetNrOp(Nil)
                  Self:SetContratoEFF(.F.)
            Else
                  While (nPos := aScan(Self:aParcelas, {|x| !(x[2] $ cNaoDesmarca) })) > 0
                        Self:nTotal -= Self:aParcelas[nPos][3]
                        aDel(Self:aParcelas, nPos)
                        aSize(Self:aParcelas, Len(Self:aParcelas)-1)
                  EndDo
            EndIf
      Else
            If Empty(Self:GetMoeda())
                  Self:SetMoeda(EEQ->EEQ_MOEDA)
            EndIf
            If Self:GetNrOp() == Nil
                  Self:SetNrOp(EEQ->EEQ_NROP)
            EndIf
            aOrd := SaveOrd("EEQ")
            EEQ->(DbGoTop())
            While EEQ->(!Eof())
                  If EEQ->EEQ_MOEDA == Self:GetMoeda() .And. EEQ->EEQ_NROP == Self:GetNrOp() .And. (!lMV_EECEFF .Or. ((Self:isContratoEFF() .And. IsContrEFF()) .Or. (!Self:isContratoEFF() .And. !IsContrEFF())))
                        Self:Marca(EEQ->(Recno()), .F.,.T.)
                  EndIf
                  EEQ->(DbSkip())
            EndDo
            RestOrd(aOrd, .T.)
      EndIf
      nTotMarcado := Self:nTotal
      oTotMarcado:Refresh()
      oMoeMarcado:Refresh()
      If lRefresh
            oBrwCambio:Refresh()
      EndIf

Return Nil

/*
Método   : Valida(cAcao)
Classe   : AF900Mark
Objetivo : Valida se as parcelas marcadas correspondem à ação desejada.
           Caso não existam parcelas marcadas do tipo desejado, exibe mensagem e retorna falso.
           Caso existam parcelas marcadas do tipo desejado mas também existam parcelas de outros tipos, pergunta se o usuário desejam que 
           sejam desmarcadas automaticamente estas parcelas, e somente retorna true caso ele confirme.
Parâmetro: cAcao - Código da Ação a ser validada
*/
Method Valida(cAcao, cExecAcao) Class AF900Mark
Local lRet := .T.
Local lOkTipo := .F.
Local lTipoDiferente := .F.
Local aAcoes := StrTokArr(cAcao, "|")
Local cMsgTipo := ""
Local aTiposErro := {}, cMsgTiposErro := ""
Local bAddErro := {|x| If(aScan(aTiposErro, x) == 0, aAdd(aTiposErro, x), Nil) }
local nParc      := 0
local aParcDesm  := {}
local lMovExt    := .F.
local lRecLiq    := .F.
local lRASemProc := .F.

default cExecAcao := ""

   if !(cAcao == "EXCLUIR_PARCELA")
      aEval(aAcoes, {|x| cMsgTipo += If(!Empty(cMsgTipo), " "  + STR0112 + " ", "") + "'" + RetFilter(x, .T.) + "'" }) // "ou"
   endif

   If Self:LenMarcados() == 0
      EasyHelp( STR0031 + if( !empty(cMsgTipo), ENTER + StrTran( STR0032 , "XXX", cMsgTipo), "") , STR0002 ) // "Não foram identificadas parcelas marcadas." + ENTER + "Efetue a marcação de ao menos uma parcela do tipo correspondente a XXX para continuar." , "Aviso"
      lRet := .F.
   Else  
      if cAcao == "EXCLUIR_PARCELA"

         for nParc := 1 to Self:LenMarcados()

            EEQ->(dbGoTo(Self:aParcelas[nParc][1]))
            lMovExt := .F.
            lRecLiq := TEIsCambRec("EEQ", @lMovExt)
            lRASemProc := existFunc("EasyRADesv") .and. EasyRADesv()
            if lRASemProc
               if ( empty(EEQ->EEQ_ORIGEM) .and. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN .and. lRecLiq ) .or. ; // parcelas principais liquidades/recebidas
                  ( !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC) .and. lMovExt .and. !empty(EEQ->EEQ_PGT) ) // parcela tranferencia bancaria
                  aAdd( aParcDesm, Self:aParcelas[nParc][1])
               endif
            elseif !(EEQ->EEQ_TP_CON $ "3|4")
               if ( empty(EEQ->EEQ_ORIGEM) .and. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN ) .or. ; // parcelas principais
                  ( ((!lMovExt .and. !empty(EEQ->EEQ_PGT)) .or. (lMovExt .and. !empty(EEQ->EEQ_DTCE))) ) // parcelas a receber ou pagar recebidas no exterior ou liquidadas
                  aAdd( aParcDesm, Self:aParcelas[nParc][1])
               endif
            elseif EEQ->EEQ_TP_CON $ "3|4"
               if (!lMovExt .and. lRecLiq) .or. ; // parcela liquidada (contrato de cambio)
                  (lMovExt .and. lRecLiq .and. ( ( empty(EEQ->EEQ_ORIGEM) .and. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN ) .or. ; // parcela original recebida (movimento no exterior)
                                                 ( !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC) .and. !empty(EEQ->EEQ_PGT) ) ) ) // parcela recebida desmembrada liquidada (movimento no exterior)
                  aAdd( aParcDesm, Self:aParcelas[nParc][1])
               endif
            endif

         next

         if len(aParcDesm) > 0
            if len(aParcDesm) == Self:LenMarcados()
               lRet := .F.
               EasyHelp(STR0113, STR0116, STR0114) // "Não é possível realizar a exclusão das parcelas principais, ou que estejam recebidas, liquidadas ou pagas" ### "Atenção" ### "Verifique as parcelas selecionadas."
            else
               lRet := MsgYesNo(STR0115, STR0002 ) // "Foram encontras parcelas que não poderão ser excluídas. Caso confirme, serão desmarcadas automaticamente. Deseja continuar?"
               if lRet
                  for nParc := 1 to len(aParcDesm)
                     Self:Desmarca(aParcDesm[nParc], .T.)
                  next
               endif
            endif
         else
            lRet := MsgYesNo(STR0119, STR0002 ) // "Deseja excluir as parcelas selecionadas?"
         endif

      else
         aEval(Self:aParcelas, {|x| if(!(x[2] $ cAcao), Eval(bAddErro, x[2]), ) })
         aEval(aTiposErro, {|x| cMsgTiposErro += RetFilter(x, .T.) + ENTER })
         If aScan(Self:aParcelas, {|x| x[2] $ cAcao }) == 0
            EasyHelp( STR0033 + ENTER + StrTran( STR0034 , "XXX", cMsgTipo) + ENTER + ENTER;
                           + STR0035 + ENTER +;
                           cMsgTiposErro, STR0002 ) // "Não foi marcada nenhuma parcela do tipo correspondente à ação selecionada." + ENTER + "Efetue a marcação de ao menos uma parcela com o tipo correspondente a XXX para continuar." + ENTER + "Somente foram identificadas parcelas marcadas com os tipos abaixo, que são inválidos para a operação desejada:" , "Aviso"
            lRet := .F.
         EndIf
         If lRet .And. Len(cMsgTiposErro) > 0
            If lRet := MsgYesNo( STR0036 + ENTER;
                     + cMsgTiposErro + ENTER;
                     + STR0037 , STR0002 ) // "Foram marcadas parcelas dos tipos:" + +  "Estes tipos de parcela são inválidos para a operação desejada e serão desmarcados automaticamente ao confirmar. Deseja continuar?", "Aviso"
               Self:MarcaTodos(.T., cAcao, .F.)
            EndIf
         EndIf
      endif
   EndIf

Return lRet

/*
Método    : ReservaRegistros()
Classe    : AF900Mark
Objetivo  : Efetua o Softlock dos processos de embarque envolvidos nas parcelas que serão atualizadas. Caso o processo esteja travado, exibe mensagem informando 
            quais são os processos e perguntando se deseja aguardar ou cancelar.
Parâmetros: aParcelas - Array com o Recno das parcelas do EEQ que devem ter os processos travados.
*/
Method ReservaRegistros() Class AF900Mark
Local aOrd := SaveOrd({"EEQ", "EEC"})
Local aErroTrava := {}
Local i
Local lAborta := .F.
Local cMensagem

      EEC->(DbSetOrder(1))
      For i := 1 to Len(Self:aParcelas)
            EEQ->(DbGoTo(Self:aParcelas[i][1]))
            If !(EEQ->EEQ_TP_CON $ "3|4") .And. EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
                  If !EEC->(SimpleLock() .And. SoftLock("EEC"))
                        aAdd(aErroTrava, {"EEC", EEC->(Recno()), STR0038 + AllTrim(EEC->EEC_FILIAL) + STR0039 + AllTrim(EEC->EEC_PREEMB)}) // "Filial: " // " Embarque: "
                  Else
                        aAdd(Self:aSoftLock, {"EEC", EEC->(Recno())})
                  EndIf
            EndIf
      Next

      While !lAborta .And. Len(aErroTrava) > 0
            cMensagem := STR0040 + ENTER //"O seguintes processos de embarque estão bloqueados por outro acesso ou usuário:"
            aEval(aErroTrava, {|x| cMensagem += x[3] + ENTER })
            cMensagem += STR0041 //"Deseja tentar novamente? Caso contrário a operação será cancelada."
            If !(lAborta := !EECView(cMensagem, STR0002 )) //"Aviso"
                  i := 1
                  While i <= Len(aErroTrava)
                        EEC->(DbGoTo(aErroTrava[i][2]))
                        If EEC->(SimpleLock() .And. SoftLock("EEC"))
                              aAdd(Self:aSoftLock, {"EEC", EEC->(Recno())})
                              aDel(aErroTrava, i)
                              aSize(aErroTrava, Len(aErroTrava)-1)
                              i -= 1
                        EndIf
                        i++
                  EndDo
            EndIf
      EndDo

      If lAborta
            Self:LiberaRegistros()
      EndIf

      RestOrd(aOrd, .T.)
Return !lAborta

/*
Método    : LiberaRegistros()
Classe    : AF900Mark
Objetivo  : Cancela o Softlock dos registros reservados durante a validação
*/
Method LiberaRegistros() Class AF900Mark
Local i
Local aOrd := SaveOrd("EEC")

      For i := 1 To Len(Self:aSoftLock)
            EEC->(DbGoTo(Self:aSoftLock[i][2]))
            If EEC->(IsLocked())
                  EEC->(MsUnlock())
            EndIf
      Next
      Self:aSoftLock := {}

RestOrd(aOrd, .T.)
Return Nil

/*
Método    : SetParcela()
Classe    : AF900Mark
Objetivo  : Adicionar os dados da parcela marcada no array de controle aParcelas
*/
Method SetParcela(nRecParc, cTipo, nValor) Class AF900Mark
      aAdd(Self:aParcelas, {nRecParc, cTipo, nValor})
      Self:nTotal += nValor
Return nil

/*
Método    : SetContratoEFF()
Classe    : AF900Mark
Objetivo  : Seta se a parcela marcada possui um número de operação que pertence a um contrato
*/
Method SetContratoEFF(lNrOpEFF) Class AF900Mark
If Self:lNrOpEFF <> lNrOpEFF
      Self:lNrOpEFF := lNrOpEFF
EndIf

Return Self:lNrOpEFF

/*
Método    : isContratoEFF()
Classe    : AF900Marksubiu
Objetivo  : Retorna se a primeira parcela marcada possio numero de operação um contrato com vínculo ao SIGAEFF
*/
Method isContratoEFF() Class AF900Mark
Return Self:lNrOpEFF
/*
Função     : AF900Mark()
Objetivo   : Executa a opção de Marca/Desmarca da parcela posicionada. Função relacionada no MenuDef e associada à ação de duplo clique do browse.
*/
Function AF900Mark()
      If oMarca:Marcado(EEQ->(Recno()))
            oMarca:Desmarca(EEQ->(Recno()), .T.)
      Else
            oMarca:Marca(EEQ->(Recno()), .T.)
      EndIf
Return .T.

/*
Função     : AF900ALTE()
Objetivo   : Executa a opção de alteração da rotina de câmbio padrão para a parcela selecionada, caso corresponda a câmbio de embarque.
*/
Function AF900ALTE()
Local aOrd := SaveOrd("EEC")
Local cFilLogado := cFilAnt
Local nRecEEQ := EEQ->(Recno())
local nParc := 0
local aMarcados := oMarca:GetMarcados()

      cFilAnt := EEQ->EEQ_FILIAL
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
            aCab := {}
            aAdd(aCab, {"EEC_FILIAL", EEC->EEC_FILIAL, Nil})
            aAdd(aCab, {"EEC_PREEMB", EEC->EEC_PREEMB, Nil})
            Eval({|x,y| EECAF200(x,y) },aCab, 3)
            //Desmarca e marca a parcela para atualizar o valor no controle de parcelas marcadas
            for nParc := 1 to len( aMarcados )
                  If oMarca:Marcado(aMarcados[nParc][1])
                        oMarca:Desmarca(aMarcados[nParc][1], .F.)
                        oMarca:Marca(aMarcados[nParc][1], .F., .T.)
                  EndIf
            next
            EEQ->(DbGoTo(nRecEEQ))

      Else
            EasyHelp( STR0042 , STR0002 ) // "Não foi localizado um embarque associado a esta parcela." , "Aviso"
      EndIf

cFilAnt := cFilLogado
RestOrd(aOrd, .T.)
Eval(bTotaliza)
Return Nil

/*
Função     : AF900ALTP()
Objetivo   : Executa a opção de alteração em lote de dados das parcelas selecionadas
*/
Function AF900ALTP()
local aArea      := {}
local aAreaEEQ   := {}
Local aCoors     := FWGetDialogSize( oMainWnd )
local cTitulo    := ""
local oDlg
local bOk        := {|| If(VldAction("ALTERA_LOTE", , , , aInfoParc, oGridParc), (lRet := .T., oDlg:End()), ) }
local lRet       := .F.
local oLayerAltP := nil
local oPanelSup  := nil
local oPanelInf  := nil
local aCampos    := {}
local aCposVis   := {}
local nField     := 0
local cField     := ""
local aInfoCpo   := {}
local cFieldRep  := ""
local aFieldsGet := {}
local aFieldChv  := {}
local aFieldGrid := {}
local cTitSeek   := ""
local aSeekCpos  := {}
local aSeek      := {}
local aMarcados  := {}
local nInfo      := 0
local aInfo      := {}
local aColParc   := {}
local oEnch      := nil
local aParcAuto  := {}

Private lTelaLote := .T.
Private oProgress := EasyProgress():New()
Private cCadastro := ""
private oGridParc  := nil
private aInfoParc  := {}

aArea := getArea()
aAreaEEQ := EEQ->(getArea())

If oMarca:Valida("REC_ABERTO|PAG_ABERTO|REC_ALIQUIDAR_EMBARCADO|REC_ALIQUIDAR_NAOEMBARCADO|ADIANTAMENTO_TRANSFERIR", "ALTERA_LOTE")

   cTitulo := STR0101 // "Alterar Parcelas"
   cCadastro := cTitulo

   oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.)
   EnchoiceBar(oDlg,bOk,{|| oDlg:End() })

   oLayerAltP := FWLayer():new()
   oLayerAltP:Init(oDlg,.F.)
   oLayerAltP:AddCollumn("PANEL",100, .F.)
   oLayerAltP:AddWindow("PANEL","SUPERIOR",STR0103,50,.F.,.T.) // "Replicar dados"
   oLayerAltP:AddWindow("PANEL","INFERIOR",STR0104,50,.F.,.F.) // "Dados das parcelas"
   oPanelSup := oLayerAltP:getWinPanel("PANEL","SUPERIOR")
   oPanelSup:FreeChildren()
   oPanelInf := oLayerAltP:getWinPanel("PANEL","INFERIOR")
   oPanelInf:FreeChildren()

   // Adiciona os campos chaves para o GRID
   aFieldChv := {}
   aAdd( aFieldChv, "EEQ_EVENT"  )
   aAdd( aFieldChv, "EEQ_PREEMB" )
   aAdd( aFieldChv, "EEQ_NRINVO" )
   aAdd( aFieldChv, "EEQ_PARC"   )

   cTitSeek := ""
   for nField := 1 to len(aFieldChv)
      cField := aFieldChv[nField]
      aInfoCpo := AvSX3(cField)
      if len(aInfoCpo) > 0 .and. !(aInfoCpo[1] == "0")

         aAdd(aFieldGrid, cField)
         addCpoGrid(@aColParc, aInfoCpo, cField, { || .T. } , .F.)

         cTitSeek += alltrim(aInfoCpo[AV_TITULO]) + "+"
         aAdd( aSeekCpos, {"", aInfoCpo[AV_TIPO], aInfoCpo[AV_TAMANHO], aInfoCpo[AV_DECIMAL], aInfoCpo[AV_TITULO]} )
      endif
   next
   cTitSeek := substr(cTitSeek,1,len(cTitSeek)-1)
   aAdd(aSeek, {cTitSeek, aSeekCpos, 1, .T.} )

   // Atualiza os campos da replicação para não confrontar com os campos da grid
   aCposVis := GetFields("ALT_LOTE_VISUALIZA")
   aCampos := aClone(GetFields("ALT_LOTE_ALTERA"))
   for nField := 1 to len(aCposVis)
      if !(aCposVis[nField] == "NOUSER")
         if ( aScan( aCampos, { |X| X == aCposVis[nField]}) == 0,  aAdd( aCampos, aCposVis[nField]), nil )
         aCposVis[nField] := strTran(aCposVis[nField] , "EEQ_", "TRB_")
      endif
   next

   // Trata os campos para o MsmGet e MsNewGetDados  
   for nField := 1 to len(aCampos)

      cField := aCampos[nField]
      aInfoCpo := AvSX3(cField)

      if len(aInfoCpo) > 0 .and. !(aInfoCpo[1] == "0")

         cFieldRep := strTran(cField, "EEQ_", "TRB_")
         aCampos[nField] := cFieldRep
         M->&(cFieldRep) := criaVar(cField)
         lVisual := aScan(aCposVis, { |X| X == cFieldRep} ) > 0 .or. getSX3Cache(cField, "X3_VISUAL") == "V"

         addCpoGet(@aFieldsGet, aInfoCpo, cFieldRep, { || AltLoteVd("C") }, lVisual)

         if aScan( aFieldGrid, { |X| X == cField}) == 0
            aAdd(aFieldGrid, cField)
            addCpoGrid(@aColParc, aInfoCpo, cField, { |lCancel, oObj| AltLoteVd("D", lCancel, oObj) }, !lVisual)
         endif

      endif
   next

   aMarcados := oMarca:GetMarcados()
   for nInfo := 1 to len(aMarcados)
      EEQ->(DbGoTo(aMarcados[nInfo][1]))

      aInfo := {}
      for nField := 1 to len(aFieldGrid)
         aAdd( aInfo, EEQ->&(aFieldGrid[nField]) )
      next
      aAdd( aInfoParc, aClone(aInfo))

      aSize(aInfo,0)

   next

   oEnch := MsmGet():New(,,3,,,,aCposVis,PosDlg(oPanelSup),aCampos,,;
                         /*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oPanelSup,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,;
                         /*lNoFolder*/,/*lProperty*/,aFieldsGet, /*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/, .T.)    
   oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

   oGridParc := FWBrowse():New(oPanelInf)
   oGridParc:SetProfileID("BRALTPARC")
   oGridParc:SetDataArray()
   oGridParc:SetDescription("")
   oGridParc:SetArray( aInfoParc )
   oGridParc:SetColumns( aColParc )
   oGridParc:SetEditCell(.T.)
   oGridParc:DisableFilter()
   oGridParc:DisableLocate()
   oGridParc:DisableReport()
   //oGridParc:DisableConfig()
   oGridParc:SetInsert(.F.)
   oGridParc:SetDelete(.F.)
   oGridParc:SetSeek(,aSeek)
   oGridParc:Activate()

   oDlg:Activate(,,,.T.)

   lTelaLote := .F.

   If lRet .and. len( aParcAuto := VldAltParc(oMarca:GetMarcados(), aFieldGrid, aInfoParc)) > 0

      If oMarca:LenMarcados() > 1
         oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), aParcAuto, 5, oProgress, "ALTERA_LOTE") }, STR0045 + " " + cTitulo) // "Executando"
         oProgress:Init()
      Else
         MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), aParcAuto, 5, , "ALTERA_LOTE") }, STR0045 + " " + cTitulo) // "Executando"
      EndIf
      If lRet
         MsgInfo( STR0046 , STR0002 ) // "Operação concluída." , "Aviso"
      EndIf

      if isMemVar("oBrwCambio")
         oBrwCambio:Refresh()
      endif

   EndIf

   FwFreeArray(aInfoParc)
   FwFreeArray(aColParc)
   FwFreeObj(oGridParc)
   FwFreeObj(oDlg)

EndIf

//Desbloqueia os registros travados durante a validação
oMarca:LiberaRegistros()

restArea(aAreaEEQ)
restArea(aArea)

Return lRet

/*/{Protheus.doc} addCpoGrid
   Função para adicionar os campos no FWBrowse, é necessário ser private as variáveis: aInfoParc e oGridParc
   E a variavel aColParc tem que ser referenciada

   @type  Function
   @author user
   @since 14/03/2024
   @version version
   @param aInfoCpo, vetor, definições do campo
          bValid, codeblock, validação do campo
          lEdit, logico, .T. é para editar e .F. é apenas visual
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
   /*/
static function addCpoGrid(aColParc, aInfoCpo, cField, bValid, lEdit)
   local lRet       := .T.

   default aColParc   := {}
   default aInfoCpo   := {}
   default cField     := ""
   default bValid     := aInfoCpo[AV_VALID]
   default lEdit      := .T.

   aAdd(aColParc, FWBrwColumn():New())
   aColParc[len(aColParc)]:SetData(&("{|| aInfoParc[oGridParc:At()][" + cValToChar(len(aColParc)) + "]}"))
   aColParc[len(aColParc)]:SetTitle( aInfoCpo[AV_TITULO] )
   aColParc[len(aColParc)]:SetSize( aInfoCpo[AV_TAMANHO] )
   aColParc[len(aColParc)]:SetDecimal( aInfoCpo[AV_DECIMAL] )
   aColParc[Len(aColParc)]:SetPicture( aInfoCpo[AV_PICTURE] )
   if( !empty( aInfoCpo[AV_X3CBOX] ), aColParc[Len(aColParc)]:SetOptions( StrTokArr2(aInfoCpo[AV_X3CBOX], ";") ), nil )
   if( !empty( aInfoCpo[AV_F3] ), aColParc[Len(aColParc)]:XF3 := aInfoCpo[AV_F3], nil )
   aColParc[Len(aColParc)]:SetValid( bValid )
   aColParc[len(aColParc)]:SetEdit( lEdit )
   aColParc[len(aColParc)]:SetReadVar("M->" + cField)

return lRet

/*/{Protheus.doc} addCpoGet
   Função para adicionar os campos no MsmGet
   É a variavel aFieldsGet tem que ser referenciada

   @type  Function
   @author user
   @since 14/03/2024
   @version version
   @param aInfoCpo, vetor, definições do campo
          bValid, codeblock, validação do campo
          lVisual, logico, .T. é para visual e .F. é apenas editar
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
   /*/
static function addCpoGet(aFieldsGet, aInfoCpo, cField, bValid, lVisual)
   local lRet       := .T.

   default aFieldsGet := {}
   default aInfoCpo   := {}
   default cField     := ""
   default bValid     := aInfoCpo[AV_VALID]
   default lVisual    := .F.

   if aScan( aFieldsGet, { |X| X[2] == cField}) == 0
      aAdd( aFieldsGet, {;
                     aInfoCpo[AV_TITULO],;
                     cField,;
                     aInfoCpo[AV_TIPO],;
                     aInfoCpo[AV_TAMANHO],;
                     aInfoCpo[AV_DECIMAL],;
                     aInfoCpo[AV_PICTURE],;
                     bValid,;
                     .F.,;
                     aInfoCpo[AV_NIVEL],;
                     "",;
                     aInfoCpo[AV_F3],;
                     aInfoCpo[AV_WHEN],;
                     lVisual,;
                     .F.,;
                     aInfoCpo[AV_X3CBOX],;
                     0,;
                     .F.,;
                     "",;
                     "N"}) // Gatilhos desconsiderados
   endif

return lRet

/*
Função     : AF900REC()
Objetivo   : Efetua o recebimento no exterior das parcelas a receber marcadas
*/
Function AF900REC()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0047 , STR0048 ) //"Recebimento no Exterior em Lote" , "Recebimento no Exterior"
Local oDlg
Local bOk := {|| If(VldAction("RECEBE"), (lRet := .T., oDlg:End()), ) }
Local lRet := .F.
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

Private lFinanciamento := .F.
Private lIsEmb := .T.
Private oProgress := EasyProgress():New()
Private lTelaLote := .T.
Private cCadastro := ""

      nRecEEQ := EEQ->(recno())

      If oMarca:Valida("REC_ABERTO")
            cCadastro := cTitulo 
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)
                  cLote := EasyGetMVSeq("EEQ_LTRC")
                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_MODAL := iif(EEQ->EEQ_TP_CON $ "34",EEQ->EEQ_MODAL,"2")
                  M->EEQ_EVENT := "101"
                  M->EEQ_LTRC := cLote // GetSxeNum("EEQ","EEQ_LTRC","EEQ_LTRC" + cEmpAnt)
                  if !lMutParc
                        EEQ->(dbgoto(oMarca:GetMarcados()[1][1]))
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  Enchoice("EEQ",0,3,,,,GetFields("RECEBE_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("RECEBE_ALTERA",,lMutParc),3,,,.T.,,,,,,.T.)
            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| oDlg:End() }) CENTERED
            lTelaLote := .F.
            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE",,lMutParc), 5, oProgress,"RECEBE") }, STR0045 + " " + cTitulo) //"Executando"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE",, lMutParc ),5,,"RECEBE") }, STR0045 + " " + cTitulo) //"Executando"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote, STR0002 ) //"Operação concluída. Lote de referência: " , "AVISO"
                  EndIf
            EndIf
      EndIf

      If !lRet
            RollbackSx8()
      EndIf

      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()

      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Função     : AF900ELIQ()
Objetivo   : Efetua o estorno do recebimento no exterior das parcelas a receber marcadas
*/
Function AF900EREC()
Local aEEQAuto := {}
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("REC_ALIQUIDAR_EMBARCADO|REC_ALIQUIDAR_NAOEMBARCADO|ADIANTAMENTO_TRANSFERIR" ) .And. VldAction("RECEBE_CANCELA") .And. MsgYesNo( STR0050 , STR0002 ) //"Confirma o estorno do recebimento das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE_CANCELA"), 5, oProgress, "RECEBE_CANCELA") }, STR0051 ) //"Executando Estorno do Recebimento em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE_CANCELA"), 5, , "RECEBE_CANCELA") }, STR0052 ) // "Executando Estorno do Recebimento da Parcela"
            EndIf
      EndIf
      If lRet
            MsgInfo( STR0046 , STR0002 ) //"Operação concluída com sucesso." , "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()

Return lRet

/*
Função     : AF900LIQ()
Objetivo   : Efetua a liquidação das parcelas a receber marcadas
*/
Function AF900LIQ()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0053 , STR0054 ) //"Liquidação em Lote", "Liquidação"
Local oDlg
Local bOk := {|| If(VldAction("LIQUIDA"), (lRet := .T., oDlg:End()), ) }
Local lRet := .T.
Local nEEQRecno
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

//** Variáveis usadas na validação dos campos no EECAF200
Private lFinanciamento := .F.
Private lIsEmb := .T.
Private nTipoDet := 99
Private lTelaLote := .T.
//***
Private oProgress := EasyProgress():New()
Private cCadastro := ""

      nRecEEQ := EEQ->(recno())

      If oMarca:PossuiParcela("REC_ALIQUIDAR_EMBARCADO") .And. oMarca:PossuiParcela("REC_ALIQUIDAR_NAOEMBARCADO")
            If lRet := MsgYesNo( STR0055 , STR0002 ) //"Foram identificadas parcelas associadas a processos embarcados e parcelas associadas a processos não embarcados. Para prosseguir, as parcelas vinculadas a processos não embarcados serão desmarcadas. Deseja continuar?", "Aviso"
                  oMarca:MarcaTodos(.T., "REC_ALIQUIDAR_EMBARCADO|ADIANTAMENTO_TRANSFERIR" , .F.)
            EndIf
      EndIf

      If lRet
            lRet := oMarca:Valida("REC_ALIQUIDAR_EMBARCADO|REC_ALIQUIDAR_NAOEMBARCADO|ADIANTAMENTO_TRANSFERIR")
      EndIf
      If lRet
            cCadastro := cTitulo
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)
                  cLote := EasyGetMVSeq("EEQ_LTBX") 
                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_MODAL := "1"
                  M->EEQ_NROP := oMarca:GetNrOp()
                  M->EEQ_LTBX := cLote // GetSxeNum("EEQ","EEQ_LTBX","EEQ_LTBX" + cEmpAnt)
                  nEEQRecno := oMarca:aParcelas[1][1]
                  EEQ->(DBGOTO(nEEQRecno))
                  M->EEQ_EVENT := EEQ->EEQ_EVENT //OSSME-7209 MFR 10/01/2022
                  if !lMutParc
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  If EasyGParam("MV_EEC_EFF",,.F.) .And. !Empty(M->EEQ_NROP) .And. oMarca:isContratoEFF() //Se integrado com SIGAEFF, verifica se o Numero de Contrato pertence a um contrato do EFF
                        M->EEQ_BANC   := EEQ->EEQ_BANC
                        M->EEQ_AGEN   := EEQ->EEQ_AGEN
                        M->EEQ_NCON   := EEQ->EEQ_NCON
                        M->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6") + AvKey(M->EEQ_BANC,"A6_COD") + AvKey(M->EEQ_AGEN,"A6_AGENCIA") + AvKey(M->EEQ_NCON,"A6_NUMCON") , "A6_NOME")
                  EndIf

                  Enchoice("EEQ",0,3,,,,GetFields("LIQUIDA_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("LIQUIDA_ALTERA",oMarca:GetNrOp(),lMutParc, oMarca:isContratoEFF()),3,,,,,,,,,.T.)

            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| lRet := .F., oDlg:End() }) CENTERED

            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("LIQUIDA",,lMutParc), 99, oProgress, "LIQUIDA") }, STR0056 ) // "Executando Liquidação em Lote"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("LIQUIDA",,lMutParc), 99, ,"LIQUIDA") }, STR0057 ) // "Executando Liquidação da Parcela"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote, STR0002 ) //"Operação concluída. Lote de referência: " , "Aviso"
                  EndIf
            EndIf
      EndIf
      If !lRet
            RollbackSx8()
      EndIf
      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()
      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Função     : AF900ELIQ()
Objetivo   : Efetua o estorno de liquidação das parcelas a receber marcadas
*/
Function AF900ELIQ()
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("REC_LIQUIDADO_CAMBIO") .And. VldAction("LIQUIDA_CANCELA") .And. MsgYesNo( STR0058 , STR0002 ) //"Confirma o estorno da liquidação das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, oProgress, "LIQUIDA_CANCELA") }, STR0059 ) // "Executando Estorno da Liquidação em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, , "LIQUIDA_CANCELA") }, STR0060 ) //"Executando Estorno da Liquidação da Parcela"
            EndIf
      EndIf
      If lRet
            MsgInfo(STR0046,STR0002) //"Operação concluída com sucesso.", "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()

Return lRet

/*
Função     : AF900PAG()
Objetivo   : Efetua o pagamento das parcelas a pagar marcadas
*/
Function AF900PAG()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0061 , STR0062 ) //"Pagamento em Lote", "Pagamento"
Local oDlg
Local bOk := {|| If(VldAction("PAGA"), (lRet := .T., oDlg:End()), ) }
Local lRet := .T.
Local nEEQRecno
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

//** Variáveis usadas na validação dos campos no EECAF200
Private lFinanciamento := .F.
Private lIsEmb := .T.
Private nTipoDet := 99
Private lTelaLote := .T.
//***
Private oProgress := EasyProgress():New()
Private cCadastro := ""

      nRecEEQ := EEQ->(recno())

      If lRet
            lRet := oMarca:Valida("PAG_ABERTO")
      EndIf
      If lRet
            cCadastro := cTitulo
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)
                  cLote := EasyGetMVSeq("EEQ_LTPG") 
                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_NROP := oMarca:GetNrOp()
                  M->EEQ_LTPG := cLote // GetSxeNum("EEQ","EEQ_LTPG","EEQ_LTPG" + cEmpAnt)
                  nEEQRecno := oMarca:aParcelas[1][1]
                  EEQ->(DBGOTO(nEEQRecno))
                  M->EEQ_EVENT := EEQ->EEQ_EVENT //OSSME-7209 MFR 10/01/2022
                  M->EEQ_MODAL := if(EEQ->EEQ_TP_CON $ "34",EEQ->EEQ_MODAL,criavar("EEQ_MODAL"))
                  if !lMutParc
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  Enchoice("EEQ",0,3,,,,GetFields("PAGA_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("PAGA_ALTERA",oMarca:GetNrOp(),lMutParc),3,,,,,,,,,.T.)

            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| lRet := .F., oDlg:End() }) CENTERED

            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields(IF(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR"),,lMutParc), 99, oProgress, if(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR") ) }, STR0063 ) //"Executando Pagamento em Lote"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields(IF(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR"),,lMutParc), 99, , if(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR")) }, STR0064 ) //"Executando Pagamento da Parcela"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote , STR0002 ) //"Operação concluída. Lote de referência: " + cLote, "Aviso"
                  EndIf
            EndIf
      EndIf
      If !lRet
            RollbackSx8()
      EndIf
      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()
      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Função     : AF900EPAG()
Objetivo   : Efetua o estorno de pagamento das parcelas a pagar marcadas
*/
Function AF900EPAG()
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("PAG_FECHADO") .And. VldAction("PAGA_CANCELA") .And. MsgYesNo( STR0065 , STR0002 ) //"Confirma o estorno do pagamento das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, oProgress, "PAGA_CANCELA") }, STR0066 ) //"Executando Estorno do Pagamento em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, ,"PAGA_CANCELA") }, STR0067 )
            EndIf
      EndIf
      If lRet
            MsgInfo(STR0046 , STR0002 ) //"Operação concluída com sucesso.", "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a validação
      oMarca:LiberaRegistros()

Return lRet

/*
Função     : VldAction(cAction)
Objetivo   : Valida a execução das ações de tela, verificando os campos obrigatórios de acordo com o contexto
Parâmetros : cAction - Indica a ação executada
*/
Static Function VldAction(cAction, lBloqueia, nOpc, aEEQAuto, aAltParc, oBrwParc, cRotAction)
Local lRet      := .T.
Local i         := 0
Local aCampos   := {}
Local cMensagem := ""
Local aOrd      := {}
local nParc     := 0
local aFieldVld := {}
local aFieldTit := {}
local nPosCol   := {}
local aAreaEEQ  := {}
local cChaveEEQ := ""
local cEvento   := ""
local nPosEvent := 0
local lRASemVin := .F.
local lMovExt   := .F.
local lRecLiq   := .F.
local aParcDes  := {}
local cParcs    := ""
local cPedidos  := ""
local cEmbarques:= ""

Default lBloqueia := .T.
Default nOpc := 0
Default aEEQAuto := {}
default aAltParc := {}
default cRotAction := ""

      Do Case
            Case cAction $ "LIQUIDA"
                  aCampos := GetFields("LIQUIDA_OBRIGATORIO")
                  If !Empty(M->EEQ_NROP) .And. !IsContrEFF()//THTS - 16/09/2022 - Se o Contrato vinculado for do EFF, não executar a validação
                        lRet := AF200VldOpr()
                  EndIf
            Case cAction == "RECEBE"
                  If M->EEQ_MODAL == "2"
                        aCampos := GetFields("RECEBE_OBRIGATORIO_EXTERIOR")
                  Else
                        aCampos := GetFields("RECEBE_OBRIGATORIO")
                  EndIf
            Case cAction == "PAGA"
                  If M->EEQ_MODAL == "2"
                        aCampos := GetFields("PAGA_OBRIGATORIO_EXTERIOR")
                  Else
                        aCampos := GetFields("PAGA_OBRIGATORIO_BRASIL")
                  EndIf
            Case cAction == "ALTERA_LOTE"
                  aCampos := GetFields("ALT_LOTE_OBRIGATORIO")

            Case cAction == "INTEGEEQ"
                  lRASemVin := existFunc("EasyRADesv") .and. EasyRADesv()
                  If !lRASemVin .and. nOpc == 5 .And. EEQ->EEQ_TIPO == "A" .And. EEQ->EEQ_MODAL == "2" .And. aScan(aEEQAuto, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0
                        cMensagem += STR0068 + ENTER // "Operação não permitida. Por se tratar de uma parcela de adiantamento, o crédito no exterior deve ser estornado no cadastro de clientes."
                        EasyHelp(cMensagem, STR0002 ) //"Aviso"
                        lRet := .F.
                  EndIf
                  If !(EEQ->EEQ_TP_CON $ "3|4")
                        //Se não for câmbio 3/4deve possuir um embarque obrigatoriamente

                        if !lRASemVin
                              aOrd := SaveOrd("EEC")
                              EEC->(DbSetOrder(1))
                              If !EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
                                    EasyHelp(StrTran(StrTran( STR0069 , "XXX", Alltrim(EEQ->EEQ_PREEMB)), "YYY", Alltrim(xFilial("EEC"))), STR0002 ) // "O processo de embarque 'XXX' da Filial 'YYY' associado a esta parcela não foi localizado." , "Aviso"
                                    lRet := .F.
                              EndIf
                        else
                              cEvento := EEQ->EEQ_EVENT
                              lMovExt := .F.
                              lRecLiq := TEIsCambRec("EEQ", @lMovExt)
                              if lMovExt .and. (; // Modalidade movimento no exterior
                                 (nOpc == 5 .and. cRotAction == "ALTERA_LOTE" .and. (lRecLiq .or. !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC))) .or. ; // alteração de cambio já recebida no exterior ou uma alteração de uma parcela desmembrada
                                 (nOpc == 95 .and. cRotAction == "EXCLUIR_PARCELA" .and. !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC) ) .or. ; // exclusão de parcela desmembrada
                                 (nOpc == 99 .or. nOpc == 98) ) // Liquidação ou estorno de liquidação para cambio de adiantamento na modalidade no Exterior 
                                    lRet := .T.
                                    if AvFlags("EEC_LOGIX") .and. empty(EEQ->EEQ_ORIGEM) .and. ;
                                          ( nOpc == 99 .or. ; // liquidação da parcela de origem para verificar se os titulos foram gerados corretamente (605 e 620)
                                           (nOpc == 5 .and. cRotAction == "ALTERA_LOTE" ) ) .and. ; // alteração da parcela de origem foram gerados corretamente (605 e 620)
                                          !TELogixRA(EEQ->(Recno()) ) 
                                          EasyHelp( STR0135 + CRLF + ; // "Foi identificado uma tentativa de estorno não concluída e que impede que o adiantamento na modalidade Movimento no Exterior seja alterado ou liquidado."
                                                    STR0136 , STR0116) // "Efetue o estorno do Recebimento no Exterior e, se necessário, realize novamente o recebimento no exterior para prosseguir com esta operação." ### "Atenção"
                                          lRet := .F.
                                    endif
                              else

                                    if nOpc == 5 .and. cRotAction == "RECEBE_CANCELA" .and. lMovExt .and. lRecLiq
                                          aParcDes := {}
                                          cParcs := ""
                                          if empty(EEQ->EEQ_ORIGEM) .and. EEQ->EEQ_PARVIN == EEQ->EEQ_PARC .and. TEParcDesm(cEvento, EEQ->EEQ_PARC, EEQ->EEQ_PREEMB, @aParcDes, @cParcs)
                                                EasyHelp(STR0123 + CRLF + ; // "O estorno do recebimento no exterior não pode ser realizado pois este adiantamento possui desmembramento dos valores." 
                                                         STR0124 + " [ " + STR0125 + ": " + alltrim(EEQ->EEQ_PREEMB) + " - " + STR0126 + ": " + cParcs + " ].", STR0116) // "Atenção" ### "Realize a exclusão das parcelas filhas" ### "Processo" ### "Parcelas"
                                                lRet := .F.
                                          endif

                                          if lRet .and. !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC)
                                                EasyHelp(STR0127 + CRLF + ; // "Esta operação não é permitida em parcelas filhas."
                                                         STR0128 + " [ " + STR0125 + ": " + alltrim(EEQ->EEQ_PREEMB) + " - " + STR0133 + ": " + EEQ->EEQ_PARVIN + " ].", STR0116) // "Atenção" ### "Efetue a exclusão desta parcela e realize esta operação na parcela original" ### "Processo" ### "Parcelas"
                                                lRet := .F.
                                          endif
                                    endif

                                    if lRet
                                          if cEvento == "620"
                                                cEvento := "605"
                                          endif
                                          
                                          if ( nPosEvent := aScan(aEEQAuto, {|x| x[1] == "EEQ_EVENT" } ) ) > 0
                                                aEEQAuto[nPosEvent][2] := cEvento
                                          endif

                                          cChaveEEQ := xFilial("EEQ") + EEQ->EEQ_PROR + EEQ->EEQ_PAOR + EEQ->EEQ_FAOR

                                          aAreaEEQ := EEQ->(getArea())
                                          EEQ->(DbSetOrder(1)) // EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
                                          
                                          // posiciona no cambio de origem do adiantamento com evento 605
                                          lRet := EEQ->(dbSeek( cChaveEEQ )) .and. ( empty(cEvento) .or. EEQ->EEQ_EVENT == cEvento )
                                          if( !(lRet), EasyHelp( STR0122, STR0002 ), nil) // "Não foi encontrado a parcela de adiantamento original."
                                          
                                          if lRet .and. nOpc == 5 .and. cRotAction == "RECEBE_CANCELA" .and. lMovExt .and. lRecLiq .and. EEQ->EEQ_VL <> EEQ->EEQ_SALDO 
                                                   cPedidos := ""
                                                   cEmbarques := ""
                                                   if getPrcParc( EEQ->EEQ_PREEMB, EEQ->EEQ_PARC, EEQ->EEQ_FASE, EEQ->EEQ_TIPO, @cPedidos, @cEmbarques )
                                                         EasyHelp(STR0129 + CRLF + ; // "O estorno do recebimento no exterior não pode ser realizado pois este adiantamento possui saldos vinculados em outras fases do processo."
                                                                  STR0130 + ": " + ; // "Cancele a associação do adiantamento aos processos"
                                                                  if( !empty(cPedidos) .and. !empty(cEmbarques), STR0131 + ": [" + cPedidos + "] / " + STR0132 + ": [" + cEmbarques + "]", if( !empty(cPedidos), STR0131 + ": [" + cPedidos + "]", STR0132 + ": ["+ cEmbarques + "]" )) + ".", STR0116 ) // "Atenção" ### "Pedidos" ### "Embarques" 
                                                         lRet := .F.
                                                   endif
                                          endif

                                          restArea(aAreaEEQ)
                                    endif

                              endif
                        endif
                  Else
                        If EEQ->EEQ_SOURCE == Avkey("ESS", "EEQ_SOURCE")
                              //Somente se for originado do Siscoserv, precisa localizar a Invoice
                              aOrd := SaveOrd("ELA")
                              //O módulo deve ser alterado para ESS devido ao controle de eventos contábeis
                              cModulo := "ESS"
                              ELA->(DbSetOrder(4))
                              If !ELA->(DbSeek(xFilial("ELA")+AvKey(EEQ->EEQ_TPPROC,"ELA_TPPROC")+AvKey(EEQ->EEQ_PROCES,"ELA_PROCES")+AvKey(EEQ->EEQ_NRINVO,"ELA_NRINVO")))
                                    EasyHelp(StrTran(StrTran(StrTran( STR0070 , "XXX", Alltrim(EEQ->EEQ_NRINVO)), "YYY", Alltrim(xFilial("ELA"))), "ZZZ", If(EEQ->EEQ_TPPROC == "P", STR0027 , STR0024 )), STR0002 ) //"A Invoice 'XXX' da Filial 'YYY' do tipo 'ZZZ' associada a esta parcela não foi localizada.","Aviso" //"A Pagar" // "A Receber" 
                                    lRet := .F.
                              EndIf
                        EndIf
                  EndIf
      EndCase
      
      If lRet
         if cAction == "ALTERA_LOTE"
            if len(aCampos) > 0
               aEval(aCampos, { |X| aAdd( aFieldTit, AvSx3(X, AV_TITULO))})
               for i := 1 to len(aFieldTit)
                  nPosCol := aScan( oBrwParc:aColumns, { |X| alltrim(X:GetTitle()) == alltrim(aFieldTit[i]) } ) 
                  if nPosCol > 0
                     aAdd( aFieldVld, { nPosCol, aFieldTit[i]} )
                  endif
               next

               for nParc := 1 to len(aAltParc)
                  for i := 1 to len(aFieldVld)
                     if empty(aAltParc[nParc][aFieldVld[i][1]])
                        EasyHelp( StrTran( StrTran( STR0105, "XXX", aFieldVld[i][2]), "YYY", cValToChar(nParc) ) , STR0002 ) //"O campo 'XXX' deve ser informado em 'Dados das parcelas' para prosseguir com a operação - Linha YYY.",,"Aviso"
                        lRet := .F.
                        Exit
                     endif
                  next
                  if !lRet
                     exit
                  endif
               next
            endif
         else
            For i := 1 To Len(aCampos)
                  If Empty(&("M->"+aCampos[i]))
                        EasyHelp(StrTran(STR0071, "XXX", AvSx3(aCampos[i], AV_TITULO)), STR0002 ) //"O campo 'XXX' deve ser informado para prosseguir com a operação.","Aviso"
                        lRet := .F.
                        Exit
                  EndIf
            Next
         endif
      EndIf

      if lRet
            if ( cAction == "RECEBE" .or. cAction == "PAGA" ) .and. existfunc('AF200VdBancExt') 
                  lRet := AF200VdBancExt(.F.)
            endif
      endif

      If lRet .And. EasyEntryPoint("AF900VLD")
            lRet := ExecBlock("AF900VLD", .F., .F., {cAction, lBloqueia, nOpc, aEEQAuto, lRet})
      EndIf

      If lRet .And. lBloqueia
            //Bloqueia os processos de embarque relacionados às parcelas
            MsAguarde({|| lRet := oMarca:ReservaRegistros() }, STR0072 ) //"Verificando disponibilidade de registros"
      EndIf

      If len(aOrd) > 0 
            RestOrd(aOrd)
      EndIf

Return lRet

/*
Função     : GetFields(cOpc)
Objetivo   : Define a relação de campos para tela (Visualização, Alteração e Obrigatórios) de acordo com cada contexto para tela
Parâmetros : cOpc - Código do contexto desejado
*/
Static Function GetFields(cOpc, cOperacao, lMultParcela, lContraEFF)
Private aFields := {}
Default lMultParcela := .T.
Default lContraEFF   := .F.

      Do Case
            Case cOpc == "LIQUIDA_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_EQVL","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_LTBX", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "LIQUIDA_ALTERA"
                  If Empty(cOperacao)
                        aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_RFBC"}
                  Else                  
                        aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX"}
                        If !EasyGParam("MV_EEC_EFF",,.F.) .Or. !lContraEFF
                              aAdd(aFields, "EEQ_BANC")
                              aAdd(aFields, "EEQ_AGEN")
                              aAdd(aFields, "EEQ_NCON")
                        EndIf
                        aAdd(aFields, "EEQ_RFBC")
                  EndIf
                  if EasyGParam("MV_AVG0131",,.F.) .and. ( lMultParcela .or. !(AllTrim(EEQ->EEQ_MODAL) == "2" .and. !empty(EEQ->EEQ_DTCE)))
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") .and. !(AllTrim(EEQ->EEQ_MODAL) == "2" .and. !empty(EEQ->EEQ_DTCE))
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "LIQUIDA_OBRIGATORIO"
                  aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX"}
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BANC")
                        aAdd(aFields, "EEQ_AGEN")
                        aAdd(aFields, "EEQ_NCON")
                  endif
            Case cOpc == "RECEBE_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_EQVL", "EEQ_DTCE", "EEQ_OBS", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT", "EEQ_MOEBCO", "EEQ_PRINBC", "EEQ_VLMBCO", "EEQ_LTRC", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "RECEBE_ALTERA"
                  aFields := {"EEQ_DTCE", "EEQ_OBS", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "RECEBE_OBRIGATORIO"
                  aFields := {"EEQ_DTCE", "EEQ_MODAL"}

            Case cOpc == "RECEBE_OBRIGATORIO_EXTERIOR"
                  aFields := GetFields("RECEBE_OBRIGATORIO")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BCOEXT")
                        aAdd(aFields, "EEQ_CNTEXT")
                        aAdd(aFields, "EEQ_AGCEXT")
                  endif

            Case cOpc == "PAGA_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_EQVL","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC","EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT", "EEQ_MOEBCO", "EEQ_PRINBC", "EEQ_VLMBCO", "EEQ_LTPG", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "PAGA_ALTERA"
                  If Empty(cOperacao)
                        aFields := {"EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
                  Else
                        aFields := {"EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX", "EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
                  EndIf
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "PAGA_OBRIGATORIO"
                  aFields := {"EEQ_DTCE", "EEQ_MODAL"}

            Case cOpc == "PAGA_OBRIGATORIO_BRASIL"
                  aFields := GetFields("PAGA_OBRIGATORIO")
                  aAdd(aFields, "EEQ_SOL")
                  aAdd(aFields, "EEQ_DTNEGO")
                  aAdd(aFields, "EEQ_PGT")
                  aAdd(aFields, "EEQ_TX")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BANC")
                        aAdd(aFields, "EEQ_AGEN")
                        aAdd(aFields, "EEQ_NCON")
                  endif
                  aAdd(aFields, "EEQ_DTCE")
            
            Case cOpc == "PAGA_OBRIGATORIO_EXTERIOR"
                  aFields := GetFields("PAGA_OBRIGATORIO")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BCOEXT")
                        aAdd(aFields, "EEQ_CNTEXT")
                        aAdd(aFields, "EEQ_AGCEXT")
                  endif
            
            Case cOpc == "ALT_LOTE_VISUALIZA"
                  aFields := {}
                  aAdd(aFields, "NOUSER")

            Case cOpc == "ALT_LOTE_ALTERA"
                  aFields := {}
                  aAdd(aFields, "EEQ_VCT")
                  aAdd(aFields, "EEQ_SOL")
                  aAdd(aFields, "EEQ_DTNEGO")
                  aAdd(aFields, "EEQ_VL")
                  if AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                     aAdd( aFields, "EEQ_ACRESC" )
                     aAdd( aFields, "EEQ_DECRES" )
                     aAdd( aFields, "EEQ_DESCON" )
                     aAdd( aFields, "EEQ_MULTA" )
                     aAdd( aFields, "EEQ_JUROS" )
                  endif
                  aAdd(aFields, "EEQ_NROP")
                  aAdd(aFields, "EEQ_OBS")
                  aAdd(aFields, "EEQ_CORR")
                  aAdd(aFields, "EEQ_VLCOR")

            Case cOpc == "ALT_LOTE_OBRIGATORIO"
                  aAdd(aFields, "EEQ_VCT")
                  
      EndCase

      If EasyEntryPoint("AF900GETFIELDS")
            ExecBlock("AF900GETFIELDS",.F.,.F., cOpc)
      EndIf

Return aFields

/*
Função     : IntegEEQ(aMarcados, aEEQAuto, nOpc, oProgress)
Objetivo   : Efetua a integração das parcelas marcadas via ExecAuto (EECAF200 ou EECAF500)
Parâmetros : aMarcados - Array contendo as parcelas marcadas
             aEEQAuto - Array com os dados chave para o ExecAuto
             nOpc - Opção a ser enviada para o ExecAuto
             oProgress - Objeto contendo a tela de progresso opc=5 receber no exterior, 99 pagar  98 estornar pagamento           
*/
Static Function IntegEEQ(aMarcados, aEEQAuto, nOpc, oProgress, cAcao)
Local cFilLogado := cFilAnt
Local aOrd := SaveOrd({"EEC", "EEQ"}), i
Local aCab
Local cErros := "", cMensagem := ""
Local lRet, lProcErro := .F.
Local cCodModulo := cModulo
Local nErroCount := 0
Local cMotivoEst := ""
local aEEQExAuto := {}
local nPosParc   := 0
local nOpcAdiant := 0
local lMovExt    := .F.
local lRecLiq    := .F.
local lRASemProc := .F.

default aMarcados := {}
default aEEQAuto  := {}
default cAcao     := ""

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.//Indica que todas as mensagens de help devem ser direcionadas para o arquivo de log
Private lELinkBlind := Len(aMarcados) > 1//Caso tenha mais de uma parcela marcada desliga a janela do EasyLink
Private lELinkAuto := .T.//Indica para o EasyLink que o mesmo está sendo executado em uma rotina automática e que os erros devem ser retornados por EasyHelp

      //Somente haverá regua de processamento quando existir mais de uma parcela marcada
      If oProgress <> Nil
            oProgress:SetRegua(Len(aMarcados))
      EndIf

      EEC->(DbSetOrder(1))
      For i := 1 To Len(aMarcados)
            EEQ->(DbGoTo(aMarcados[i][1]))

            if cAcao == "ALTERA_LOTE"
               nPosParc := aScan( aEEQAuto , { |X| X[1] == aMarcados[i][1] } )
               if nPosParc == 0
                  loop
               endif
               aEEQExAuto := aEEQAuto[nPosParc][2]
            elseif !(cAcao == "EXCLUIR_PARCELA")
               aEEQExAuto := aEEQAuto
            endif

            //Altera a filial corrente para a filial da parcela
            If !Empty( EEQ->EEQ_FILIAL)
                  cFilAnt := EEQ->EEQ_FILIAL
            EndIf
            lMsErroAuto := .F.
            lProcErro := .F.
            //Busca os campos chave de acordo com a parcela
            aIntegra := GetIntegFields("CHAVE_EEQ", aClone(aEEQExAuto))
            //Valida se a operação pode ser efetuada e inclui campos adicionais no array de integração caso sejam exigidos pela operação
            If !(lMsErroAuto := !VldAction("INTEGEEQ", .F., nOpc, aIntegra, , , cAcao))
                  If !(EEQ->EEQ_TP_CON $ "3|4")
                        lRASemProc := existFunc("EasyRADesv") .and. EasyRADesv()
                        if !lRASemProc 
                              //Se for câmbio tipo 1 ou 2 executa o EECAF200
                              aCab := GetIntegFields("CHAVE_EEC")
                              If nOpc == 98 .And. IsContrEFF()
                                    If Empty(cMotivoEst)
                                          cMotivoEst := MotHistEFF() //Necessário informar um motivo para o estorno
                                    EndIf
                                    aAdd(aIntegra, {"AUTMOTIVO"   , cMotivoEst , Nil})
                              EndIf
                              MsExecAuto({|a,b,c,d| EECAF200(a,b,c,d) },aCab, 3, aIntegra, nOpc)
                        else
                              if EEQ->EEQ_EVENT == "620" // Cambio de adiantamento 

                                    // nOpc == 5  // Movimentação do exterior
                                    //       cAcao == "RECEBE" // liquidação
                                    //       cAcao == "RECEBE_CANCELA" // Estorno
                                    //       cAcao == "ALTERA_LOTE" // alteração de parcelas não recebida/liquidada
                                    // nOpc == 98 // Estorno da liquidação
                                    // nOpc == 99 // liquidação
                                    // nOpc == 95 // Exclusão de parcelas
                                    //       cAcao == "EXCLUIR_PARCELA"

                                    lMovExt := .F.
                                    lRecLiq := TEIsCambRec("EEQ", @lMovExt)

                                    if nOpc == 5 .and. cAcao == "ALTERA_LOTE" .and. (lRecLiq .or. !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC)) .and. lMovExt

                                          aAdd(aIntegra, {"EEQ_FASE" , EEQ->EEQ_FASE , nil})
                                          aAdd(aIntegra, {"EEQ_FAOR" , EEQ->EEQ_FAOR , nil})
                                          aAdd(aIntegra, {"EEQ_PROR" , EEQ->EEQ_PROR , nil})
                                          aAdd(aIntegra, {"EEQ_PAOR" , EEQ->EEQ_PAOR , nil})
                                          MsExecAuto({|a,b,c| EECAF500(a,,,b,c) }, "EEQ", aIntegra, 4)
      
                                    elseif nOpc == 95 .and. cAcao == "EXCLUIR_PARCELA" .and. !empty(EEQ->EEQ_ORIGEM) .and. !(EEQ->EEQ_PARVIN == EEQ->EEQ_PARC) .and. lMovExt 

                                          aAdd(aIntegra, {"EEQ_FASE" , EEQ->EEQ_FASE , nil})
                                          aAdd(aIntegra, {"EEQ_FAOR" , EEQ->EEQ_FAOR , nil})
                                          aAdd(aIntegra, {"EEQ_PROR" , EEQ->EEQ_PROR , nil})
                                          aAdd(aIntegra, {"EEQ_PAOR" , EEQ->EEQ_PAOR , nil})
                                          MsExecAuto({|a,b,c| EECAF500(a,,,b,c) }, "EEQ", aIntegra, 5)

                                    elseif (nOpc == 99 .or. nOpc == 98) .and. lMovExt // Liquidação ou estorno de liquidação para cambio de adiantamento na modalidade no Exterior 

                                          if nOpc == 99 // Liquidação 
                                                aAdd(aIntegra, {"EEQ_FASE" , EEQ->EEQ_FASE , nil})
                                          elseif nOpc == 98 // Estorno
                                                aAdd(aIntegra, {"EEQ_FASE" , EEQ->EEQ_FASE , nil})
                                                aAdd(aIntegra, {"EEQ_PGT"  , CTod("") , nil})
                                                aAdd(aIntegra, {"EEQ_LTBX" , ""       , nil})
                                          endif

                                          MsExecAuto({|a,b,c| EECAF500(a,,,b,c) }, "EEQ", aIntegra, 4)

                                    else
                                          aCab := GetIntegFields("CHAVE_CLIENTE")
                                          nOpcAdiant := 4
                                          if nOpc == 95 .and. cAcao == "EXCLUIR_PARCELA" // Exclusão de parcelas
                                                nOpcAdiant := 5
                                          elseif nOpc == 98 // Estorno da liquidação
                                                aAdd(aIntegra, {"EEQ_PGT"  , CTod("") , nil})
                                                aAdd(aIntegra, {"EEQ_LTBX" , ""       , nil})
                                          elseif nOpc == 5 .and. cAcao == "RECEBE_CANCELA" // Estorno da Movimentação do exterior
                                                aAdd(aIntegra, {"EEQ_PGT"    , CTod("")       , nil})
                                                if lMovExt
                                                      aAdd(aIntegra, {"EEQ_LTRC"    , ""       , nil})
                                                endif
                                          endif

                                          MSExecAuto( {|X,Y,Z,Aux| EECAC100(aCab,,nOpcAdiant,aIntegra,"AC100ADIAN") } )
                                    endif
                              endif
                        endif
                  Else
                        aAdd(aIntegra, {"EEQ_MODAL"  , if( ((nOpc == 5 .and. cAcao == "RECEBE") .or. (nOpc == 99 .and. ( cAcao == "PAGA_EXTERIOR" .or. cAcao == "PAGA_CAMBIO" ))), M->EEQ_MODAL, EEQ->EEQ_MODAL) , Nil})
                        if nOpc == 98
                           if cAcao == "PAGA_CANCELA"
                              aAdd(aIntegra, {"EEQ_DTCE" , cTod("") , Nil}) 
                              aAdd(aIntegra, {"EEQ_TX"   , 0        , Nil})
                           endif
                           aAdd(aIntegra, {"EEQ_PGT"    , cTod("")       , Nil})
                           aAdd(aIntegra, {"EEQ_SOL"    , cTod("")       , Nil})
                           aAdd(aIntegra, {"EEQ_DTNEGO" , cTod("")       , Nil})
                           aAdd(aIntegra, {"EEQ_RFBC"   , ""             , Nil})
                        endif
                        //Se for câmbio tipo 3 ou 4 executa o EECAF500
                        MsExecAuto({|a,b,c| EECAF500(a,,,b,c) }, "EEQ", aIntegra, if( nOpc == 95 .and. cAcao == "EXCLUIR_PARCELA", 5, 4))
                  EndIf
                  //Retorna para a parcela caso tenha sido desposicionado na rotina automática
                  EEQ->(DbGoTo(aMarcados[i][1]))
            EndIf
            If lMsErroAuto
                  nErroCount++
                  //Caso tenha ocorrido erro informa a parcela onde ocorreu o erro e as mensagens retornadas
                  If nErroCount > 1
                        cErros += SEPARADOR
                  EndIf
                  cErros += StrTran( STR0073 , "XXX", AllTrim(Str(nErroCount))) + ENTER //"Erro XXX:"
                  cErros += StrTran(StrTran( STR0074 , "XXX", AllTrim(EEQ->EEQ_PARC)), "YYY", AllTrim(If(!Empty(EEQ->EEQ_PROCES), EEQ->EEQ_PROCES, EEQ->EEQ_PREEMB))) + ENTER //"Não foi possível atualizar a parcela 'XXX' do processo 'YYY': "
                  //Recupera os erros da rotina automática (caso existam)
                  If ValType(NomeAutoLog()) == "C"
                        cErros += STR0075 + ENTER //"A execução da rotina automática retornou a(s) seguinte(s) mensagem(ns): "
                        cErros += MemoRead(NomeAutoLog())
                        //Apaga o arquivo de log para que não seja concatenado no próximo erro
                        FErase(NomeAutoLog())
                  Else
                        cErros += STR0076 + ENTER //"A rotina não retornou uma mensagem de erro específica."
                  EndIf
                  oMarca:Desmarca(EEQ->(Recno()), .F.)
            Else
                  //Verifica se precisa atualizar o número do lote
                  AtualizaLote(nOpc, EEQ->EEQ_TIPO, aIntegra)
                  //Desmarca e marca a parcela para atualizar o tipo da parcela no controle de parcelas marcadas
                  oMarca:Desmarca(EEQ->(Recno()), .F.)
                  oMarca:Marca(EEQ->(Recno()), .F., .T.)
            EndIf
            //Retorna a filial original
            cFilAnt := cFilLogado
            //Nas operações de atualização de parcelas do Siscoserv o módulo é alterado para ESS na rotina de valida (VldAction("INTEGEEQ", ...))
            cModulo := cCodModulo
            //Incrementa a regua de processamento
            If oProgress <> Nil
                  oProgress:IncRegua()
            EndIf
      Next
      lRet := oMarca:LenMarcados() > 0
      If lRet
            ConfirmSX8()
      EndIf
      If nErroCount > 0
            cMensagem := STR0077 + ENTER + ENTER //"Atenção: Ocorreram erros na operação."
            if !cAcao == "ALTERA_LOTE" .and. !(cAcao == "EXCLUIR_PARCELA")
               If Len(aMarcados) == nErroCount
                     cMensagem += STR0078 + ENTER + ENTER //"Devido aos erros o lote foi cancelado e a numeração descartada."
               Else
                     cMensagem += STR0079 + ENTER + ENTER
               EndIf
            endif
            If nErroCount > 1
                  cMensagem += StrTran(STR0080 , "XXX", AllTrim(Str(nErroCount)) + STR0081 + AllTrim(Str(Len(aMarcados)))) + ENTER + ENTER // "Das parcelas selecionadas XXX não foram atualizadas devido aos erros, os quais serão apresentados abaixo: " " de "
            Else
                  cMensagem += STR0082 + ENTER + ENTER
            EndIf
            EECView(cMensagem + cErros, STR0083 ) //"Aviso: Ocorreram erros na operação"
      EndIf

cFilAnt := cFilLogado
RestOrd(aOrd)
Eval(bTotaliza)
Return lRet

/*
Função     : AtualizaLote(cOpc, cTipo, aIntegra)
Objetivo   : Verifica se o lote precisa ser removido da parcela
Parâmetros : nOpc - Opção que foi executada no ExecAuto
             cTipo - Tipo da parcela (P-Pagar, R-Receber, A-Adiantamento)
             aIntegra - Array com os campos do ExecAuto
*/
Static Function AtualizaLote(nOpc, cTipo, aIntegra)
Local cCampo := ""

      If cTipo == "P"
            If nOpc == 98 .Or. aScan(aIntegra, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0 .Or. aScan(aIntegra, {|x| x[1] == "EEQ_PGT" .And. Empty(x[2]) }) > 0
                  cCampo := "EEQ_LTPG"                                 
            EndIf
      Else
            If nOpc == 5 .And. aScan(aIntegra, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0
                  cCampo := "EEQ_LTRC"
            EndIf
            If nOpc == 98
                  cCampo := "EEQ_LTBX"
            EndIf
      EndIf

      If !Empty(cCampo) .And. !Empty(EEQ->&(cCampo))
            EEQ->(Reclock("EEQ", .F.))
            EEQ->&(cCampo) := ""
            EEQ->(MsUnlock())
      EndIf

Return Nil

/*
Função     : GetIntegFields(cOpc, aFields)
Objetivo   : Prepara o array com os dados do ExecAuto na tabela EEQ com base no registro posicionado ou dados da memória
Parâmetros : cOpc - Opção Selecionada para retornar os campos de acordo com o contexto
             aFields - Array com campos já definidos anteriormente, onde serão incluídos os novos campos
*/
Static Function GetIntegFields(cOpc, aFields, lMultParcela)
Private aCustom
Default aFields := {}
Default lMultParcela := .T.

      Do Case
            Case cOpc == "CHAVE_EEQ"
                  aAdd(aFields, {"EEQ_EVENT"    , EEQ->EEQ_EVENT  , Nil})
                  aAdd(aFields, {"EEQ_PREEMB"   , EEQ->EEQ_PREEMB , Nil})
                  aAdd(aFields, {"EEQ_NRINVO"   , EEQ->EEQ_NRINVO , Nil})
                  aAdd(aFields, {"EEQ_PARC"     , EEQ->EEQ_PARC   , Nil})
                  If EEQ->EEQ_TP_CON $ "3|4"
                        aAdd(aFields, {"EEQ_PROCES", EEQ->EEQ_PROCES, Nil})
                        aAdd(aFields, {"EEQ_TPPROC", EEQ->EEQ_TPPROC, Nil})
                  EndIf
            Case cOpc == "CHAVE_EEC"
                  aAdd(aFields, {"EEC_FILIAL", EEC->EEC_FILIAL, Nil})
                  aAdd(aFields, {"EEC_PREEMB", EEC->EEC_PREEMB, Nil})
            Case cOpc == "LIQUIDA"
                  aAdd(aFields, {"EEQ_SOL"     , M->EEQ_SOL      , Nil})
                  aAdd(aFields, {"EEQ_DTNEGO"  , M->EEQ_DTNEGO   , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})
                  aAdd(aFields, {"EEQ_NROP"    , M->EEQ_NROP     , Nil})
                  aAdd(aFields, {"EEQ_RFBC"    , M->EEQ_RFBC     , Nil})
                  aAdd(aFields, {"EEQ_TX"      , M->EEQ_TX       , Nil})
                  aAdd(aFields, {"EEQ_BANC"    , M->EEQ_BANC     , Nil})
                  aAdd(aFields, {"EEQ_AGEN"    , M->EEQ_AGEN     , Nil})
                  aAdd(aFields, {"EEQ_NCON"    , M->EEQ_NCON     , Nil})
                  aAdd(aFields, {"EEQ_LTBX"    , M->EEQ_LTBX     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "RECEBE"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_BCOEXT"  , M->EEQ_BCOEXT   , Nil})
                  aAdd(aFields, {"EEQ_AGCEXT"  , M->EEQ_AGCEXT   , Nil})
                  aAdd(aFields, {"EEQ_CNTEXT"  , M->EEQ_CNTEXT   , Nil})
                  aAdd(aFields, {"EEQ_LTRC"    , M->EEQ_LTRC     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "RECEBE_CANCELA"
                  aAdd(aFields, {"EEQ_DTCE"    , CTod("")       , Nil})
            Case cOpc == "PAGA_EXTERIOR"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})//RMD - 02/10/18
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_BCOEXT"  , M->EEQ_BCOEXT   , Nil})
                  aAdd(aFields, {"EEQ_AGCEXT"  , M->EEQ_AGCEXT   , Nil})
                  aAdd(aFields, {"EEQ_CNTEXT"  , M->EEQ_CNTEXT   , Nil})
                  aAdd(aFields, {"EEQ_LTPG"    , M->EEQ_LTPG     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "PAGA_CAMBIO"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_SOL"     , M->EEQ_SOL      , Nil})
                  aAdd(aFields, {"EEQ_DTNEGO"  , M->EEQ_DTNEGO   , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})
                  aAdd(aFields, {"EEQ_NROP"    , M->EEQ_NROP     , Nil})
                  aAdd(aFields, {"EEQ_RFBC"    , M->EEQ_RFBC     , Nil})
                  aAdd(aFields, {"EEQ_TX"      , M->EEQ_TX       , Nil})
                  aAdd(aFields, {"EEQ_BANC"    , M->EEQ_BANC     , Nil})
                  aAdd(aFields, {"EEQ_AGEN"    , M->EEQ_AGEN     , Nil})
                  aAdd(aFields, {"EEQ_NCON"    , M->EEQ_NCON     , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_LTPG"    , M->EEQ_LTPG     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. AvFlags("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "CHAVE_CLIENTE"
                  aAdd(aFields, {"A1_COD" , EEQ->EEQ_IMPORT , Nil})
                  aAdd(aFields, {"A1_LOJA", EEq->EEQ_IMLOJA , Nil})

      EndCase

      If EasyEntryPoint("AF900INTCP")
            aCustom := aClone(aFields)
            If ExecBlock("AF900INTCP",.F.,.F., cOpc)
                  aFields := aClone(aCustom)
            EndIf
      EndIf

Return aFields

/*
Função   : AF900DtEmb()
Objetivo : Inicializa o campo virtual EEQ_DTEMBA com a data de embarque para parcelas relacionadas a embarque
*/
Function AF900DtEmb()
Local dRet := CToD("")

      If !Empty(EEQ->EEQ_PREEMB) .AND. EEQ->EEQ_EVENT <> '602' .And. EEQ->EEQ_EVENT <> '605' .And. EEQ->EEQ_EVENT <> '606' .And. EEQ->EEQ_EVENT <> '609' .And. EEQ->EEQ_TIPO <> 'F' .And. EEQ->EEQ_TP_CON <> '3' .And. EEQ->EEQ_TP_CON <> '4'
            dRet := Posicione('EEC', 1, EEQ->EEQ_FILIAL+EEQ->EEQ_PREEMB, 'EEC_DTEMBA')
      EndIf

Return dRet

/*
Função      : IsContrEFF()
Objetivo    : Verifica se o numero de contrato informado no campo EEQ_NROP pertence a um contrato de Financiamento do SIGAEFF
Retorno     : .T. - Contrato existe no EFF; .F. - Contrato não existe no EFF;
*/
Static Function IsContrEFF()
Local lRet := .F.

If EasyGParam("MV_EEC_EFF",,.F.)
      EF3->(dbSetOrder(3))//EF3_FILIAL + EF3_TPMODU + EF3_INVOIC + EF3_PARC + EF3_CODEVE
      If EF3->(dbSeek(xFilial("EF3") + IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E") + EEQ->EEQ_NRINVO + If(Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) + "600"))
            lRet := .T.
      EndIf      
EndIf

Return lRet

/*
Função      : MotHistEFF()
Objetivo    : Caso encontre a parcela no contrato EFF, abre a tela para digitar o motivo do estorno.
Retorno     : Retorna o texto digitado para o Motivo do Estorno
*/
Static Function MotHistEFF()
Local cRet := ""

Private lEFFTpMod := .T.
Private lTemChave := .T.

If EasyGParam("MV_EEC_EFF",,.F.)
      //EF3->(dbSetOrder(3))//EF3_FILIAL + EF3_TPMODU + EF3_INVOIC + EF3_PARC + EF3_CODEVE
      //EF1->(dbSetORder(1))//EF1_FILIAL + EF1_TPMODU + EF1_CONTRA + EF1_BAN_FI + EF1_PRACA + EF1_SEQCNT
      //If EF3->(dbSeek(xFilial("EF3") + IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E") + EEQ->EEQ_NRINVO + If(Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) + "600")) .And.;
      //   EF1->(dbSeek(xFilial("EF1") + EF3->EF3_TPMODU + EF3->EF3_CONTRA + EF3->EF3_BAN_FI + EF3->EF3_PRACA + EF3->EF3_SEQCNT))
            cRet := STR0093 + FWTimeStamp(2) + STR0094 + FwGetUserName(RetCodUsr())+"." //EX400MotHis("LIQ", EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA, EF1->EF1_TP_FIN, EF3->EF3_PREEMB, EF3->EF3_INVOIC, EF3->EF3_PARC, EF3->EF3_CODEVE, EF3->EF3_SEQ, EF1->EF1_TPMODU, EF1->EF1_SEQCNT) //"Estorno em lote via Painel de Câmbio (EECAF900) em "###" por "
      //EndIf      
EndIf

Return cRet

/*
Função      : MarkAllEFF()
Objetivo    : Ao marcar a primeira parcela, caso a mesma esteja vinculada a um contrato do EFF, verifica se será marcadas todas as parcelas do mesmo contrato
Retorno     : -
*/
Method MarkAllEFF(nRecEEQ, cTipo, cExpSQL, cContrato, cTpModu, cBanco) Class AF900MARK
Local cAliasOper := GetNextAlias()
Local lRet := .F.
CriaTmpEFF(cAliasOper, cContrato, cTpModu, cBanco, nRecEEQ, cExpSQL)

If (cAliasOper)->(!EOF()) .And. MsgYesNo(STR0099 + Alltrim(Self:GetNrOp()) + "." + ENTER + STR0100, STR0002) //"Esta parcela possui vinculação com o contrato de financiamento "### "Deseja que todas as demais parcelas vinculadas ao mesmo contrato de financiamento sejam marcadas pelo sistema?"####Aviso
      Self:SetParcela(nRecEEQ, cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)//Marca a parcela selecionada
      //Marca as outras parcelas do contrato
      While (cAliasOper)->(!EOF())
            Self:SetParcela((cAliasOper)->(R_E_C_N_O_), cTipo, (cAliasOper)->EEQ_VL - (cAliasOper)->EEQ_CGRAFI + (cAliasOper)->EEQ_ACRESC - (cAliasOper)->EEQ_DECRES + (cAliasOper)->EEQ_MULTA + (cAliasOper)->EEQ_JUROS - (cAliasOper)->EEQ_DESCON)
            (cAliasOper)->(dbSkip())
      End
      lRet := .T.
Else //Marca somente a parcela selecionada            
      Self:SetParcela(nRecEEQ, cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)
      lRet := .T.
EndIf

(cAliasOper)->(dbCloseArea())

Return lRet

/*
Função      : BuscaOperac()
Objetivo    : Verifica se existem mais parcelas com o mesmo contrato de financiamento com o mesmo status da parcela que está sendo verificada
Retorno     : 
*/
Static Function CriaTmpEFF(cAliasOper, cContrato, cTpModu, cBanco, nReqEEQ, cExpSQL)

cExpSQL := "% " + cExpSQL + " %"

BeginSQL Alias cAliasOper

SELECT
  EEQ.R_E_C_N_O_,
  EEQ_VL,
  EEQ_CGRAFI,
  EEQ_ACRESC,
  EEQ_DECRES,
  EEQ_MULTA,
  EEQ_JUROS,
  EEQ_DESCON
FROM
  %table:EEQ% EEQ
  INNER JOIN %table:EF3% EF3 ON (
    EF3_FILIAL = %xFilial:EF3%
    AND EF3_TPMODU = %Exp:cTpModu%
    AND EF3_INVOIC = EEQ_NRINVO
    AND EF3_PREEMB = EEQ_PREEMB
    AND EF3_PARC   = EEQ_PARC	
    AND EF3_CONTRA = EEQ_NROP 
    AND EF3_BAN_FI = EEQ_BANC
  )
  INNER JOIN %table:EEC% EEC ON (
    EEC_FILIAL = %xFilial:EEC%
    AND EEC_PREEMB = EEQ_PREEMB
  ) 
WHERE 
  EEQ_FILIAL         = %xFilial:EEQ%
  AND EEQ_NROP       = %Exp:cContrato%
  AND EF3_CODEVE     = '600' 
  AND EF3_BAN_FI     = %Exp:cBanco%
  AND %Exp:cExpSQL%
  AND EEQ.R_E_C_N_O_ <> %Exp:nReqEEQ%
  AND EEQ.%NotDel%
  AND EF3.%NotDel%
  AND EEC.%NotDel%
ORDER BY EEQ.EEQ_FILIAL, EEQ.EEQ_NRINVO, EEQ.EEQ_PREEMB, EEQ.EEQ_PARC, EEQ.EEQ_FASE, EEQ.EEQ_PROCES

EndSQL

Return

/*/{Protheus.doc} AF900AltVd
   Validação dos campos da alteração de parcelas em lote

   @type  Static Function
   @author user
   @since 14/03/2024
   @version version
   @param cTipo, caractere, "C" campos da Capa e "D" campos das parcelas
   @return lRet, lógico, .T. se tudo ok
   @example
   (examples)
   @see (links_or_references)
   /*/
static function AltLoteVd(cTipo, lCancel, oBrowse)
   local lRet       := .T.
   local cCpo       := ""
   local xValor     := nil
   local cField     := ""
   local aInfoCpo   := {}
   local cTypeInf   := ""
   local cValor     := ""
   local cTitulo    := ""
   local nTamanho   := 0
   local cMensagem  := ""
   local lGrid      := .F.
   local nPosLine   := 0

   default cTipo   := ""
   default lCancel := .F.

   if !empty((cCpo := ReadVar()))

      cField := StrTran(cCpo, "M->", "")
      if cTipo == "C"
         cField := strTran( cField, "TRB_", "EEQ_")
      endif

      aInfoCpo := AvSX3(cField)

      if (lRet := len(aInfoCpo) > 0 .and. !(aInfoCpo[1] == "0"))

         xValor := &(cCpo)

         // Validação dos campos da replicação
         if cTipo == "C" 

            cTypeInf := Valtype(xValor)
            cValor := alltrim(Transform(xValor, aInfoCpo[AV_PICTURE]))
            cTitulo := alltrim(aInfoCpo[AV_TITULO])
            nTamanho := aInfoCpo[AV_TAMANHO]

            lRet := validCpo(cField, xValor, aInfoCpo)
            if lRet .and. ( !cField == "EEQ_VL" .or. xValor > 0 )
               lGrid := isMemVar("oGridParc")
               if lGrid
                  nPosLine := oGridParc:At()
               endif
               if VerifVlr(lGrid, cField, xValor, cTitulo)
                  if !empty(xValor)
                     cMensagem := strTran(strTran(STR0106, "XXX", cValor), "YYY", cTitulo) // "Confirma a replicação do valor 'XXX' no campo 'YYY' em todas as parcelas?"
                  else
                     cMensagem := strTran(STR0107, "YYY", cTitulo) // "Deseja limpar o campo 'YYY' em todas as parcelas?"
                  endif
                  lRet := MsgYesNo( cMensagem , STR0002 )

                  if lRet 
                     lRet := AtuPrcGrid(lGrid, cField, xValor, cTitulo)
                  endif

                  lRet := lRet .or. empty(xValor)
               endif
               
               if lRet
                  if cTypeInf == "D"
                     xValor := ctod("")
                  elseif cTypeInf == "N"
                     xValor := 0
                  else
                     xValor := space(nTamanho)
                  endif
                  &(cCpo) := xValor
               endif

               if lGrid
                  oGridParc:GoTo(nPosLine)
               endif
            else
               lRet := (cField == "EEQ_VL" .and. xValor == 0)
            endif

         // Validação dos campos das parcelas
         elseif cTipo == "D" .and. !lCancel

            lRet := validCpo(cField, xValor, aInfoCpo, .T.)
            if lRet 
               oBrowse:oData:aArray[oBrowse:At()][oBrowse:colPos()] := xValor
            endif

         endif

      endif

   endif

return lRet

/*/{Protheus.doc} validCpo
   Validação de campo na alteração das parcelas

   @type  Static Function
   @author user
   @since 15/03/2024
   @version version
   @param cField, caractere, campo alterado
          xValor, indefinido, valor do campo
          aInfoCpo, vetor, informações do campo
   @return lRet, lógico, .T. se tudo ok
   @example
   (examples)
   @see (links_or_references)
/*/
static function validCpo(cField, xValor, aInfoCpo, lGrid)
   local lRet       := .T.
   local cMsg       := ""
   local aArea      := {}

   default cField   := ""
   default aInfoCpo := AvSX3(cField)
   default lGrid    := .F.

   do case
      case cField $ "EEQ_VL||EEQ_ACRESC||EEQ_DECRES||EEQ_DESCON||EEQ_MULTA||EEQ_JUROS||EEQ_VLCOR"

         if (cField == "EEQ_VL" .and. if( lGrid, xValor <= 0, xValor < 0))
            cMsg := STR0109 // "O valor da parcela deverá ser maior que zero."
         elseif xValor < 0
            cMsg := STR0108 // "Informe um valor maior ou igual a zero."
         endif

      case cField == "EEQ_CORR"

         aArea := SY5->(GetArea())
         SY5->(dbSetOrder(3))
         if !empty(xValor) .and. !(SY5->(dbSeek( xFilial("SY5") + AvKey("5-CORRETORA CAMBIO","Y5_TIPOAGE") + AvKey(xValor, "Y5_COD"))))
            cMsg := STR0110 + CRLF + CRLF + STR0111 // "Não foi encontrado o registro." ### "Verifique o cadastro de empresa com a classificação 'Corretora de Cambio'."
         endif
         restArea(aArea)
 
   endcase

   lRet := empty(cMsg)
   if !lRet
      EasyHelp(cMsg, STR0116) // "Atenção"
   endif

return lRet

/*/{Protheus.doc} VerifVlr
   Função para validação dos campos

   @type  Static Function
   @author user
   @since 14/03/2024
   @version version
   @param lGrid, logico, se a grid existe
          cField, caractere, campo alterado
          xValor, indefinido, valor do campo
          cTitulo, caractere, titulo do campo
   @return lRet, lógico, .T. se tudo ok
   @example
   (examples)
   @see (links_or_references)
   /*/
static function VerifVlr(lGrid, cField, xValor, cTitulo)
   local lRet       := .F.
   local nParc      := 0
   local oData      := nil
   local aParcelas  := {}

   default lGrid        := isMemVar("oGridParc")
   default cField       := ""
   default cTitulo      := ""

   if lGrid .and. !empty(cTitulo)
      nPosCol := aScan( oGridParc:aColumns, { |X| alltrim(X:GetTitle()) == cTitulo } ) 
      if nPosCol > 0
         oData := oGridParc:data()
         aParcelas := oData:GetArray()
         for nParc := 1 to len(aParcelas)
            if !(aParcelas[nParc][nPosCol] == xValor)
               lRet := .T.
               exit
            endif
         next
      endif
   endif

return lRet 

/*/{Protheus.doc} AtuPrcGrid
   Função para validação do grip das parcelas na alteração em lote

   @type  Static Function
   @author user
   @since 14/03/2024
   @version version
   @param lGrid, logico, se a grid existe
          cField, caractere, campo alterado
          xValor, indefinido, valor do campo
          cTitulo, caractere, titulo do campo
   @return lRet, lógico, .T. se tudo ok
   @example
   (examples)
   @see (links_or_references)
   /*/
static function AtuPrcGrid(lGrid, cField, xValor, cTitulo)
   local lRet       := .T.
   local nParc      := 0
   local oData      := nil
   local aParcelas  := {}

   default lGrid        := isMemVar("oGridParc")
   default cField       := ""
   default cTitulo      := ""

   if lGrid .and. !empty(cTitulo)
      nPosCol := aScan( oGridParc:aColumns, { |X| alltrim(X:GetTitle()) == cTitulo } ) 
      if nPosCol > 0
         oData := oGridParc:data()
         aParcelas := oData:GetArray()
         for nParc := 1 to len(aParcelas)
            aParcelas[nParc][nPosCol] := xValor
         next
      endif
   endif

return lRet 

/*/{Protheus.doc} VldAltParc
   Função para tratamento de envio para o ExecAuto do EECAF200

   @type  Function
   @author user
   @since 14/03/2024
   @version version
   @param aMarcados, array, parcelas marcadas no browse principal
          aFieldGrid, array, campos do grid
          aInforParc, array, vetor com os dados das parcelas alteradas
   @return lRet, lógico, .T. se tudo ok
   @example
   (examples)
   @see (links_or_references)
   /*/
static function VldAltParc( aMarcados, aFieldGrid, aInfoParc)
   local aRet       := {}
   local nParc      := 0
   local nField     := 0
   local aInfo      := {}

   default aMarcados  := {}
   default aFieldGrid := {}
   default aInfoParc  := {}

   for nParc := 1 to len(aMarcados)

      EEQ->(DbGoTo(aMarcados[nParc][1]))

      aInfo := {}

      for nField := 1 to len(aFieldGrid)

         if aFieldGrid[nField] $ "EEQ_EVENT||EEQ_PREEMB||EEQ_NRINVO||EEQ_PARC||EEQ_PROCES||EEQ_TPPROC||EEQ_MODAL"
            loop
         endif

         if !EEQ->&(aFieldGrid[nField]) == aInfoParc[nParc][nField]
            aAdd( aInfo, { aFieldGrid[nField], aInfoParc[nParc][nField], nil }  )
         endif
      next

      if len(aInfo) > 0
         aAdd( aRet, { aMarcados[nParc][1], aClone(aInfo)})
      endif

      aSize(aInfo, 0)
      
   next

return aRet 

/*/{Protheus.doc} AF900EXCP
   Função para ação de exclusão das parcelas filhas

   @type  Function
   @author user
   @since 14/03/2024
   @version version
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
   /*/
function AF900EXCP()
local lRet       := .T.
local aArea      := {}
local aAreaEEQ   := {}
local oProgress  := nil

aArea := getArea()
aAreaEEQ := EEQ->(getArea())

if (lRet := oMarca:Valida("EXCLUIR_PARCELA"))

   if oMarca:LenMarcados() > 1
      oProgress  := EasyProgress():New()
      oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(),, 95, oProgress, "EXCLUIR_PARCELA") }, STR0117 ) //"Executando exclusão das parcelas"
      oProgress:Init()
   else
      MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(),, 95,,"EXCLUIR_PARCELA") }, STR0118 ) // "Executando exclusão da parcela"
   endif

   if lRet
      MsgInfo( STR0046 , STR0002 ) //"Operação concluída com sucesso." , "Aviso"
      oMarca:MarcaTodos(.T.,,.T.)
   endif

   if isMemVar("oBrwCambio")
      oBrwCambio:Refresh()
   endif

endif

//Desbloqueia os registros travados durante a validação
oMarca:LiberaRegistros()

restArea(aAreaEEQ)
restArea(aArea)

return lRet

/*/{Protheus.doc} getPrcParc
   Retorna os pedidos e/ou embarques nos quais os adiantamentos foram vinculados

   @type  Static Function
   @author user
   @since 18/04/2024
   @version version
   @param cProcesso, caractere, código do processo de origem
          cParc, caractere, parcela de origem
          cFase, caractere, fase de origem
          cTpo, caractere, tipoe de origem
          cPedidos, caractere, pedidos associados (referência)
          cEmbarques, caractere, embarques associados (referência)
   @return lRet, logico, se possui parcelas desmembradas
   @example
   (examples)
   @see (links_or_references)
/*/
static function getPrcParc( cProcesso, cParc, cFase, cTpo, cPedidos, cEmbarques)
   local lRet       := .F.
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil

   default cProcesso  := ""
   default cParc      := ""
   default cFase      := ""
   default cTpo       := ""
   default cPedidos   := ""
   default cEmbarques := ""

   cAliasQry := getNextAlias()
   cQuery := " SELECT EEQ_PREEMB, EEQ_FASE, EEQ_EVENT "
   cQuery += "  FROM " + RetSqlName("EEQ") + " EEQ "
   cQuery += " WHERE EEQ.D_E_L_E_T_ = ' ' "
   cQuery += "  AND EEQ.EEQ_FILIAL = ? "
   cQuery += "  AND EEQ.EEQ_PROR = ? "
   cQuery += "  AND EEQ.EEQ_PAOR = ? "
   cQuery += "  AND EEQ.EEQ_FAOR = ? "
   cQuery += "  AND EEQ.EEQ_TIPO = ? "
   cQuery += "  AND EEQ.EEQ_FASE <> 'Q' "
   cQuery += "  AND EEQ.EEQ_PREEMB <> ' ' "
   cQuery += " ORDER BY EEQ_ORIGEM, EEQ_PARC "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("EEQ") )
   oQuery:SetString( 2, cProcesso )
   oQuery:SetString( 3, cParc )
   oQuery:SetString( 4, cFase )
   oQuery:SetString( 5, cTpo )

   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   while !(cAliasQry)->(Eof())
      if (cAliasQry)->EEQ_EVENT == "101" .and. (cAliasQry)->EEQ_FASE == "E"
         cEmbarques += alltrim((cAliasQry)->EEQ_PREEMB) + ", "
      else
         cPedidos += alltrim((cAliasQry)->EEQ_PREEMB) + ", "
      endif
      (cAliasQry)->(dbSkip())
   end
   cEmbarques := substr( cEmbarques, 1, len(cEmbarques) - 2 )
   cPedidos := substr( cPedidos, 1, len(cPedidos) - 2 )

   lRet := !empty(cEmbarques) .or. !empty(cPedidos)

   FwFreeObj(oQuery)

return lRet
