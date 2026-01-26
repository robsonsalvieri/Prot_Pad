#Include "loca106.ch"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106
Formulário para edição de parâmetros BÁSICOS DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Main Function LOCA106(cCombo1)
Local oDlg
Local oPanel
    
    // Variáveis para os gets
Local cPar01   := Space(10)

Local cPar11   := Space(30)
Local cPar14   := Space(20)
Local cPar15   := Space(20)

Local cCombo02 := ""
Local cCombo03 := ""
Local cCombo04 := ""
Local cCombo05 := ""
Local cCombo06 := ""
Local cCombo07 := ""
Local cCombo08 := ""
Local cCombo09 := ""
Local cCombo10 := ""
Local cCombo12 := ""
Local cCombo13 := ""  

Private aCombo02 := {".T.", ".F."}// MV_LOCX020
Private aCombo03 := {".T.", ".F."}// MV_LOCX022
Private aCombo04 := {".T.", ".F."}// MV_LOCX023
Private aCombo05 := {".T.", ".F."}// MV_LOCX028
Private aCombo06 := {".T.", ".F."}// MV_LOCX030
Private aCombo07 := {".T.", ".F."}// MV_LOCX051
Private aCombo08 := {".T.", ".F."}// MV_LOCX305
Private aCombo09 := {".T.", ".F."}// MV_LOCX308
Private aCombo10 := {".T.", ".F."}// MV_LOCX211
Private aCombo12 := {"S", "N"}// MV_LOCX006
Private aCombo13 := {"S", "N"}// MV_LOCX207
    
    // Cria a janela principal
    DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000,000 TO 700,900 PIXEL //"Editor de Parâmetros SX6"
    
    // Cria o painel principal com scroll
    oPanel := TScrollBox():New(oDlg, 0, 0, 350, 450, .T., .T.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    // Monta a tela
    LOCA1061(oPanel, @cPar01, @cCombo02, @cCombo03, @cCombo04, @cCombo05, @cCombo06, @cCombo07, @cCombo08, @cCombo09, @cCombo10, @cPar11, @cCombo12, @cCombo13, @cPar14, @cPar15)
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| LOCA1062(cPar01, cCombo02, cCombo03, cCombo04, cCombo05, cCombo06, cCombo07, cCombo08, cCombo09,cCombo10, cPar11, cCombo12, cCombo13, cPar14, cPar15), oDlg:End()}, {|| oDlg:End()})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1061
Monta os campos de edição dos parâmetros BÁSICO
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1061(oPanel, cPar01, cCombo02, cCombo03, cCombo04, cCombo05, cCombo06, cCombo07, cCombo08, cCombo09,cCombo10, cPar11, cCombo12, cCombo13, cPar14, cPar15)
Local nLinha  := 20
Local nCol1   := 10
Local nEspaco  := 25
    
    // Título
    @ nLinha, nCol1 SAY STR0002 OF oPanel PIXEL COLOR CLR_BLUE //"Configure os valores dos parâmetros abaixo:"
    nLinha += 30
    
    // MV_LOCX014
    @nLinha, nCol1 SAY "MV_LOCX014:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0003 OF oPanel PIXEL //"Grupos de produtos no Rental sem patrimônio (controle de locação por estoque SB2) ex: 0008;0094;0095"
    @nLinha+9, nCol1 MSGET cPar01 F3 "SBM" VALID ExistCPO( "SBM", cPar01, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX020
    @nLinha, nCol1 SAY "MV_LOCX020:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0004 OF oPanel PIXEL //"Habilita rotina de Aprovação de projetos."
    @nLinha+9, nCol1 COMBOBOX cCombo02 ITEMS aCombo02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX022
    @nLinha, nCol1 SAY "MV_LOCX022:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0005 OF oPanel PIXEL //"Se controla o retorno parcial dos equipamentos (controle de locação por estoque SB2)"
    @nLinha+9, nCol1 COMBOBOX cCombo03 ITEMS aCombo03 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco  

    // MV_LOCX023
    @nLinha, nCol1 SAY "MV_LOCX023:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0006 OF oPanel PIXEL //"Seleção do tipo de serviço"
    @nLinha+9, nCol1 COMBOBOX cCombo04 ITEMS aCombo04 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco                   

    // MV_LOCX028
    @nLinha, nCol1 SAY "MV_LOCX028:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0007 OF oPanel PIXEL //"Habilita a estrutura de produto (SB1) país e filhos no RENTAL. (controle de locação por estoque SB2)"
    @nLinha+9, nCol1 COMBOBOX cCombo05 ITEMS aCombo05 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX030
    @nLinha, nCol1 SAY "MV_LOCX030:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0008 OF oPanel PIXEL //"Valida estrutura SG1 no orçamento Rental (controle de locação por estoque SB2"
    @nLinha+9, nCol1 COMBOBOX cCombo06 ITEMS aCombo06 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX051
    @nLinha, nCol1 SAY "MV_LOCX051:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0009 OF oPanel PIXEL //"Habilita a geração automática da classe de valor na contabilidade"
    @nLinha+9, nCol1 COMBOBOX cCombo07 ITEMS aCombo07 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX305
    @nLinha, nCol1 SAY "MV_LOCX305:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0010 OF oPanel PIXEL //"Define se aceita geração de contrato sem equipamento"
    @nLinha+9, nCol1 COMBOBOX cCombo08 ITEMS aCombo08 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX308
    @nLinha, nCol1 SAY "MV_LOCX308:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0011 OF oPanel PIXEL //"Filtrar os itens do contrato conforme os parâmetros informados no inicio da rotina de contratos (LOCA001)."
    @nLinha+9, nCol1 COMBOBOX cCombo09 ITEMS aCombo09 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX211
    @nLinha, nCol1 SAY "MV_LOCX211:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0012 OF oPanel PIXEL //"Transforma prospect em cliente na geração contrato."
    @nLinha+9, nCol1 COMBOBOX cCombo10 ITEMS aCombo10 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX303
    @nLinha, nCol1 SAY "MV_LOCX303:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0013 OF oPanel PIXEL //"Adicionar campos no momento do prospect tornar cliente no RENTAL ex: US_DDD/A1_DDD;US_TEL/A1_TEL; obs. Não pode conter espaços entre os campos"
    @nLinha+9, nCol1 MSGET cPar11 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX006
    @nLinha, nCol1 SAY "MV_LOCX006:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0014 OF oPanel PIXEL //"Se aceita aglutinar qtd nos itens de estrutura SG1 (controle de locação por estoque SB2)"
    @nLinha+9, nCol1 COMBOBOX cCombo12 ITEMS aCombo12 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX207
    @nLinha, nCol1 SAY "MV_LOCX207:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0015 OF oPanel PIXEL //"Se .T. AS e aceita no momento da geração de contrato"
    @nLinha+9, nCol1 COMBOBOX cCombo13 ITEMS aCombo13 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX068
    @nLinha, nCol1 SAY "MV_LOCX068:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0016 OF oPanel PIXEL //"codigo da responsabilidade para carregar o custos de frete do conj. transportador para aba responsab"
    @nLinha+9, nCol1 MSGET cPar14 F3 "FP7" VALID ExistCPO( "FP7", cPar14, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX248
    @nLinha, nCol1 SAY "MV_LOCX248:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0017 OF oPanel PIXEL //"Label do LOCA001 - Texto usado no título do Dialog - Substituição da Nomenclatura Projeto"
    @nLinha+9, nCol1 MSGET cPar15 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco      
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1062
Salva todos os parâmetros BASICOS
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1062(cPar01, cCombo02, cCombo03, cCombo04, cCombo05, cCombo06, cCombo07, cCombo08, cCombo09,cCombo10, cPar11, cCombo12, cCombo13, cPar14, cPar15)
Local lOk  := .T.
    
    ProcessMessages()
    Sleep(2000)

    //oSay:SetText(STR0124) //"Alterando Parâmentos"
    ProcessMessages()     

    PutMV("MV_LOCX014", cPar01)
    PutMV("MV_LOCX020", cCombo02)
    PutMV("MV_LOCX022", cCombo03)
    PutMV("MV_LOCX023", cCombo04)
    PutMV("MV_LOCX028", cCombo05)
    PutMV("MV_LOCX030", cCombo06)
    PutMV("MV_LOCX051", cCombo07)
    PutMV("MV_LOCX305", cCombo08)
    PutMV("MV_LOCX308", cCombo09)
    PutMV("MV_LOCX211", cCombo10)
    PutMV("MV_LOCX303", cPar11)
    PutMV("MV_LOCX006", cCombo12)
    PutMV("MV_LOCX207", cCombo13)
    PutMV("MV_LOCX068", cPar14)
    PutMV("MV_LOCX248", cPar15)
     
    MsgInfo(STR0019, STR0018) //"Sucesso" //"Parâmetros Atualizados!"
    
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1063
Formulário para edição de parâmetros FATURAMENTO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOCA1063(cCombo1)
Local oDlg
Local oPanel

Local cPar00   := Space(10)
Local cPar02   := Space(10)
Local cPar03   := Space(10)
Local cPar04   := Space(30)
Local cPar05   := Space(10)
Local cPar06   := Space(10)
Local cPar07   := Space(10)
Local cPar08   := Space(10)
Local cPar09   := Space(10)
Local cPar10   := Space(20)
Local cPar11   := Space(30)
Local cPar12   := Space(30)
Local cCombo02 := Space(10)
Local cCombo03 := Space(10)
Local cCombo04 := Space(10)

Private aCombo02 := {".T.", ".F."}
Private aCombo03 := {".T.", ".F."}
Private aCombo04 := {".T.", ".F."}
    
    // Cria a janela principal
    DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000,000 TO 700,900 PIXEL //"Editor de Parâmetros SX6"
    
    // Cria o painel principal com scroll
    oPanel := TScrollBox():New(oDlg, 0, 0, 350, 450, .T., .T.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    // Monta a tela
    LOCA1064(oPanel, @cPar00, @cPar02, @cPar03, @cPar04, @cPar05, @cPar06, @cPar07, @cPar08, @cPar09, @cPar10, @cPar11, @cPar12, @cCombo02, @cCombo03, @cCombo04)
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| LOCA1065(cPar00, cPar02, cPar03, cPar04, cPar05, cPar06, cPar07, cPar08, cPar09, cPar10, cPar11, cPar12, cCombo02, cCombo03, cCombo04), oDlg:End()}, {|| oDlg:End()})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1061
Monta os campos de edição dos parâmetros FATURAMENTO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1064(oPanel, cPar00, cPar02, cPar03, cPar04, cPar05, cPar06, cPar07, cPar08, cPar09, cPar10, cPar11, cPar12, cCombo02, cCombo03, cCombo04)
Local nLinha  := 20
Local nCol1   := 10
Local nEspaco  := 25
    
    // Título
    @ nLinha, nCol1 SAY STR0002 OF oPanel PIXEL COLOR CLR_BLUE //"Configure os valores dos parâmetros abaixo:"
    nLinha += 30
    
    // MV_LOCX019
    @nLinha, nCol1 SAY "MV_LOCX019:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0020 OF oPanel PIXEL //" Natureza padrão para PV de Custos Extras, será utilizado caso o campo Natureza (FPG_NATURE) não esteja preenchido"
    @nLinha+9, nCol1 MSGET cPar00 F3 "SED" VALID ExistCPO( "SED", cPar00, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX024
    @nLinha, nCol1 SAY "MV_LOCX024:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0021 OF oPanel PIXEL //"NSérie usada para emitir NF de faturamento"
    @nLinha+9, nCol1 MSGET cPar02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco      

    // MV_LOCX049
    @nLinha, nCol1 SAY "MV_LOCX049:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0022 OF oPanel PIXEL //"(.T.)=Gera pedido de venda  e nota fiscal  |  (.F.)=Gera pedido de venda, sem nota fiscal no Faturamento automático"
    @nLinha+9, nCol1 COMBOBOX cCombo02 ITEMS aCombo02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX065
    @nLinha, nCol1 SAY "MV_LOCX065:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0023 OF oPanel PIXEL //"Informa a natureza financeira utilizada nos pedidos de venda de faturamento no processo de faturamento automático."
    @nLinha+9, nCol1 MSGET cPar03 F3 "SED" VALID ExistCPO( "SED", cPar03, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX067
    @nLinha, nCol1 SAY "MV_LOCX067:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0024 OF oPanel PIXEL //"Se .F. o faturamento automático pode ser gerado sem NF de REMESSA."
    @nLinha+9, nCol1 COMBOBOX cCombo03 ITEMS aCombo03 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX069
    @nLinha, nCol1 SAY "MV_LOCX069:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0025 OF oPanel PIXEL //" Produto de frete no faturamento automático."
    @nLinha+9, nCol1 MSGET cPar04 F3 "SB1" VALID ExistCPO( "SB1", cPar04, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX078
    @nLinha, nCol1 SAY "MV_LOCX078:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0026 OF oPanel PIXEL //"Informe a TES da rotina de  custos extras."
    @nLinha+9, nCol1 MSGET cPar05 F3 "SF4" VALID ExistCPO( "SF4", cPar05, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX079
    @nLinha, nCol1 SAY "MV_LOCX079:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0027 OF oPanel PIXEL //"TES utilizada na geração do PV medição (Extra)"
    @nLinha+9, nCol1 MSGET cPar06 F3 "SF4" VALID ExistCPO( "SF4", cPar06, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX080
    @nLinha, nCol1 SAY "MV_LOCX080:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0028 OF oPanel PIXEL //"Informa o TES utilizado nos pedidos de venda de Faturamento no processo de faturamento automático."
    @nLinha+9, nCol1 MSGET cPar07 F3 "SF4" VALID ExistCPO( "SF4", cPar07, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX083
    @nLinha, nCol1 SAY "MV_LOCX083:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0029 OF oPanel PIXEL //"Informa o TES a ser utilizado na operação de REMESSA do faturamento automático"
    @nLinha+9, nCol1 MSGET cPar08 F3 "SF4" VALID ExistCPO( "SF4", cPar08, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX278
    @nLinha, nCol1 SAY "MV_LOCX278:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0030 OF oPanel PIXEL //"Gera titulo PR na geração do contrato. .T. ou .F."
    @nLinha+9, nCol1 COMBOBOX cCombo04 ITEMS aCombo04 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX279
    @nLinha, nCol1 SAY "MV_LOCX279:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0031 OF oPanel PIXEL //"Natureza utilizada no titulo provisório do Rental"
    @nLinha+9, nCol1 MSGET cPar09 F3 "SED" VALID ExistCPO( "SED", cPar09, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_1DUPNAT
    @nLinha, nCol1 SAY "MV_1DUPNAT:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0032 OF oPanel PIXEL //"Campo ou dado a ser gravado na natureza do titulo. Quando o mesmo for gerado automaticamente pelo mo- dulo de faturamento."
    @nLinha+9, nCol1 MSGET cPar10 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX063
    @nLinha, nCol1 SAY "MV_LOCX063:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0033 OF oPanel PIXEL //"Produto equipamento para medição"
    @nLinha+9, nCol1 MSGET cPar11 F3 "SB1" VALID ExistCPO( "SB1", cPar11, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX064
    @nLinha, nCol1 SAY "MV_LOCX064:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0034 OF oPanel PIXEL //"Produto para MDO de medicao (usando percentual de MDO)"
    @nLinha+9, nCol1 MSGET cPar12 F3 "SB1" VALID ExistCPO( "SB1", cPar12, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco                        


    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1062
Salva todos os parâmetros FATURAMENTO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1065(cPar01, cPar02, cPar03, cPar04, cPar05, cPar06, cPar07, cPar08, cPar09, cPar10, cPar11, cPar12, cCombo02, cCombo03, cCombo04)
Local lOk  := .T.
    
    ProcessMessages()
    Sleep(2000)

    //oSay:SetText(STR0124) //"Alterando Parâmentos"
    ProcessMessages()     

    PutMV("MV_LOCX019", cPar01)
    PutMV("MV_LOCX024", cPar02)
    PutMV("MV_LOCX049", cCombo02)
    PutMV("MV_LOCX065", cPar03)
    PutMV("MV_LOCX067", cCombo03)
    PutMV("MV_LOCX069", cPar04)
    PutMV("MV_LOCX078", cPar05)
    PutMV("MV_LOCX079", cPar06)
    PutMV("MV_LOCX080", cPar07)
    PutMV("MV_LOCX083", cPar08)
    PutMV("MV_LOCX278", cCombo04)
    PutMV("MV_LOCX279", cPar09)
    PutMV("MV_1DUPNAT", cPar10)
    PutMV("MV_LOCX063", cPar11)
    PutMV("MV_LOCX064", cPar12)
     
    MsgInfo(STR0019, STR0018) //"Sucesso" //"Parâmetros Atualizados!"
    
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1066
Formulário para edição de parâmetros LOGISTICO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOCA1066(cCombo1)
Local oDlg
Local oPanel

Local cPar00   := Space(10)
Local cPar02   := Space(10)
Local cPar03   := Space(10)

Local cCombo02 := Space(10)
Local cCombo03 := Space(10)
Local cCombo04 := Space(10)
Local cCombo05 := Space(10)
Local cCombo06 := Space(10)
Local cCombo07 := Space(10)

Private aCombo02 := {".T.", ".F."}
Private aCombo03 := {".T.", ".F."}
Private aCombo04 := {".T.", ".F."}
Private aCombo05 := {".T.", ".F."}
Private aCombo06 := {".T.", ".F."}
Private aCombo07 := {".T.", ".F."}
    
    // Cria a janela principal
    DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000,000 TO 700,900 PIXEL //"Editor de Parâmetros SX6"
    
    // Cria o painel principal com scroll
    oPanel := TScrollBox():New(oDlg, 0, 0, 350, 450, .T., .T.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    // Monta a tela
    LOCA1067(oPanel, @cPar00, @cPar02, @cPar03, @cCombo02, @cCombo03, @cCombo04, @cCombo05, @cCombo06, @cCombo07,cCombo1)
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| LOCA1069(cPar00, cPar02, cPar03, cCombo02, cCombo03, cCombo04, cCombo05,cCombo07,cCombo07,cCombo1), oDlg:End()}, {|| oDlg:End()})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1067
Monta os campos de edição dos parâmetros LOGISTICO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1067(oPanel, cPar00, cPar02, cPar03, cCombo02, cCombo03, cCombo04, cCombo05,cCombo06,cCombo07,cCombo1)
Local nLinha  := 20
Local nCol1   := 10
Local nEspaco  := 25
    
    // Título
    @ nLinha, nCol1 SAY "Configure os valores dos parâmetros abaixo:" OF oPanel PIXEL COLOR CLR_BLUE
    nLinha += 30

    // MV_LOCX008
    @nLinha, nCol1 SAY "MV_LOCX008:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0035 OF oPanel PIXEL //"Habilita a rotina Gera NF REMESSA na rotina de Orçamento."
    @nLinha+9, nCol1 COMBOBOX cCombo02 ITEMS aCombo02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco    
    
    // MV_LOCX025
    @nLinha, nCol1 SAY "MV_LOCX025:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0036 OF oPanel PIXEL //"TES da nota de entrada  da NF de retorno para Romaneio - NF de retorno para remessa."
    @nLinha+9, nCol1 MSGET cPar00 F3 "SF4" VALID ExistCPO( "SF4", cPar00, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX066
    @nLinha, nCol1 SAY "MV_LOCX066:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0037 OF oPanel PIXEL //"Informa a natureza a ser utilizada no processo de NF de REMESSA de locação - Automático"
    @nLinha+9, nCol1 MSGET cPar02 F3 "SED" VALID ExistCPO( "SED", cPar02, 1 ) OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco      

    // MV_LOCX071
    @nLinha, nCol1 SAY "MV_LOCX071:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0038 OF oPanel PIXEL //"Habilita utilização da rotina de romaneio no Apontador de AS ? .T. = Habilita, .F. = Desabilita"
    @nLinha+9, nCol1 COMBOBOX cCombo03 ITEMS aCombo03 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX201
    @nLinha, nCol1 SAY "MV_LOCX201:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0039 OF oPanel PIXEL //"Serie usada para emitir NF REMESSA"
    @nLinha+9, nCol1 MSGET cPar03 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco 

    // MV_LOCX304
    @nLinha, nCol1 SAY "MV_LOCX304:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0040 OF oPanel PIXEL //"Informa que será utilizado o cliente da aba conjunto transportador"
    @nLinha+9, nCol1 COMBOBOX cCombo04 ITEMS aCombo04 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_GERNFS
    @nLinha, nCol1 SAY "MV_GERNFS:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0041 OF oPanel PIXEL //"(.T.)=Gera pedido de venda  e nota fiscal  |  (.F.)=Gera pedido de venda, sem nota fiscal no Faturamento de REMESSA"
    @nLinha+9, nCol1 COMBOBOX cCombo05 ITEMS aCombo05 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco   

    //SE FOR ESCOPO MÉDIO ADICIONA
    If cCombo1 == "M" .OR. cCombo1 == "G"
        // MV_LOCX008
        @nLinha, nCol1 SAY "MV_LOCX008:" OF oPanel PIXEL
        @nLinha, nCol1+40 SAY STR0035 OF oPanel PIXEL //"Habilita a rotina Gera NF REMESSA na rotina de Orçamento."
        @nLinha+9, nCol1 COMBOBOX cCombo06 ITEMS aCombo06 OF oPanel PIXEL SIZE 200, 12
        nLinha += nEspaco

        // MV_LOCX071
        @nLinha, nCol1 SAY "MV_LOCX071:" OF oPanel PIXEL
        @nLinha, nCol1+40 SAY STR0038 OF oPanel PIXEL //"Habilita utilização da rotina de romaneio no Apontador de AS ? .T. = Habilita, .F. = Desabilita"
        @nLinha+9, nCol1 COMBOBOX cCombo07 ITEMS aCombo07 OF oPanel PIXEL SIZE 200, 12
        nLinha += nEspaco          
    EndIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA1069
Salva todos os parâmetros LOGISTICO DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA1069(cPar00, cPar02, cPar03, cCombo02, cCombo03, cCombo04, cCombo05,cCombo06,cCombo07,cCombo1)
Local lOk  := .T.
    
    ProcessMessages()
    Sleep(2000)

    //oSay:SetText(STR0124) //"Alterando Parâmentos"
    ProcessMessages()     

    PutMV("MV_LOCX008", cCombo02)
    PutMV("MV_LOCX025", cPar00)
    PutMV("MV_LOCX066", cPar02)
    PutMV("MV_LOCX071", cCombo03)
    PutMV("MV_LOCX201", cPar03)
    PutMV("MV_LOCX304", cCombo04)
    PutMV("MV_GERNFS", cCombo05)

    //SE FOR ESCOPO MÉDIO ADICIONA
    If cCombo1 == "M" .OR. cCombo1 == "G"
        PutMV("MV_LOCX079", cCombo06)
        PutMV("MV_LOCX080", cCombo07)
    EndIf      
    MsgInfo("Parâmetros Atualizados!", STR0018) //"Sucesso"
    
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106A
Formulário para edição de parâmetros INTEGRAÇÕES DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOCA106A(cCombo1)
Local oDlg
Local oPanel

Local cPar00   := Space(100)

Local cCombo02 := Space(10)
Local cCombo03 := Space(10)
Local cCombo04 := Space(10)
Local cCombo05 := Space(10)

Private aCombo02 := {".T.", ".F."}
Private aCombo03 := {".T.", ".F."}
Private aCombo04 := {".T.", ".F."}
Private aCombo05 := {".T.", ".F."}
    
    // Cria a janela principal
    DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000,000 TO 700,900 PIXEL //"Editor de Parâmetros SX6"
    
    // Cria o painel principal com scroll
    oPanel := TScrollBox():New(oDlg, 0, 0, 350, 450, .T., .T.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    // Monta a tela
    LOCA106B(oPanel, @cPar00, @cCombo02, @cCombo03, @cCombo04, @cCombo05,cCombo1)
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| LOCA106C(cPar00, cCombo02, cCombo03, cCombo04, cCombo05,cCombo1), oDlg:End()}, {|| oDlg:End()})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106B
Monta os campos de edição dos parâmetros INTEGRAÇÕES DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA106B(oPanel, cPar00, cCombo02, cCombo03, cCombo04, cCombo05,cCombo1)
Local nLinha  := 20
Local nCol1   := 10
Local nEspaco  := 25
    
    // Título
    @ nLinha, nCol1 SAY STR0002 OF oPanel PIXEL COLOR CLR_BLUE //"Configure os valores dos parâmetros abaixo:"
    nLinha += 30

    // MV_LOCX007
    @nLinha, nCol1 SAY "MV_LOCX007:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0042 OF oPanel PIXEL //"Gera Custo Extra na finalizacao da OS"
    @nLinha+9, nCol1 COMBOBOX cCombo02 ITEMS aCombo02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_NG1LOC
    @nLinha, nCol1 SAY "MV_NG1LOC:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0043 OF oPanel PIXEL //"Integração com OS corretiva gerando custo extra"
    @nLinha+9, nCol1 COMBOBOX cCombo03 ITEMS aCombo03 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCBAC
    @nLinha, nCol1 SAY "MV_LOCBAC:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0044 OF oPanel PIXEL //"Integração com backoffice em notas fiscais de entrada em saída."
    @nLinha+9, nCol1 COMBOBOX cCombo04 ITEMS aCombo04 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_GSXRENT
    @nLinha, nCol1 SAY "MV_GSXRENT:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0045 OF oPanel PIXEL //"Integração com a base instalada do Field service."
    @nLinha+9, nCol1 COMBOBOX cCombo05 ITEMS aCombo05 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco                  
    
    //SE FOR ESCOPO MÉDIO ADICIONA
    If cCombo1 == "M" .OR. cCombo1 == "G"
        // MV_LOCX299
        @nLinha, nCol1 SAY "MV_LOCX299:" OF oPanel PIXEL
        @nLinha, nCol1+40 SAY STR0046 OF oPanel PIXEL //"De/Para TES-Cod.RM - SIGALOC x RM"
        @nLinha+9, nCol1 MSGET cPar00 F3 "SF4" VALID ExistCPO( "SF4", cPar00, 1 ) OF oPanel PIXEL SIZE 200, 12
        nLinha += nEspaco       
    EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106C
Salva todos os parâmetros INTEGRAÇÕES DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA106C(cPar00, cCombo02, cCombo03, cCombo04, cCombo05,cCombo1)
Local lOk  := .T.
    
    ProcessMessages()
    Sleep(2000)

    //oSay:SetText(STR0124) //"Alterando Parâmentos"
    ProcessMessages()     

    PutMV("MV_LOCX007", cCombo02)
    PutMV("MV_NG1LOC", cCombo03)
    PutMV("MV_LOCBAC", cCombo04)
    PutMV("MV_GSXRENT", cCombo05)

    //SE FOR ESCOPO MÉDIO ADICIONA
    If cCombo1 == "M" .OR. cCombo1 == "G"
        PutMV("MV_LOCX299", cPar00)
    EndIf      
    MsgInfo(STR0019, "Sucesso") //"Parâmetros Atualizados!"
    
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106D
Formulário para edição de parâmetros MDO/MINUTA DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOCA106D(cCombo1)
Local oDlg
Local oPanel

Local cPar00   := Space(100)
Local cPar01   := Space(100)
Local cPar02   := Space(100)

Local cCombo02 := Space(10)

Private aCombo02 := {".T.", ".F."}
    
    // Cria a janela principal
    DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000,000 TO 700,900 PIXEL //"Editor de Parâmetros SX6"
    
    // Cria o painel principal com scroll
    oPanel := TScrollBox():New(oDlg, 0, 0, 350, 450, .T., .T.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    // Monta a tela
    LOCA106E(oPanel, @cPar00,@cPar01,@cPar02, @cCombo02,cCombo1)
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| LOCA106F(cPar00,cPar01,cPar02, cCombo02, cCombo1), oDlg:End()}, {|| oDlg:End()})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106E
Monta os campos de edição dos parâmetros MDO/MINUTA DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA106E(oPanel, cPar00,cPar01,cPar02, cCombo02, cCombo1)
Local nLinha  := 20
Local nCol1   := 10
Local nEspaco  := 25
    
    // Título
    @ nLinha, nCol1 SAY STR0002 OF oPanel PIXEL COLOR CLR_BLUE //"Configure os valores dos parâmetros abaixo:"
    nLinha += 30

    // MV_LOCX191
    @nLinha, nCol1 SAY "MV_LOCX191:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0047 OF oPanel PIXEL //"disparo de e-mail Rontina de integração 7 dia antes de vencer Dt Limite"
    @nLinha+9, nCol1 MSGET cPar00 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX159
    @nLinha, nCol1 SAY "MV_LOCX159:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0048 OF oPanel PIXEL //"E-mails para a solicitacao de desativação do crachá."
    @nLinha+9, nCol1 MSGET cPar01 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco

    // MV_LOCX056
    @nLinha, nCol1 SAY "MV_LOCX056:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0049 OF oPanel PIXEL //"Envio de email, para a desativar o crachá do funcionário."
    @nLinha+9, nCol1 MSGET cPar02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco               

    // MV_LOCX097
    @nLinha, nCol1 SAY "MV_LOCX097:" OF oPanel PIXEL
    @nLinha, nCol1+40 SAY STR0042 OF oPanel PIXEL //"Gera Custo Extra na finalizacao da OS"
    @nLinha+9, nCol1 COMBOBOX cCombo02 ITEMS aCombo02 OF oPanel PIXEL SIZE 200, 12
    nLinha += nEspaco


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA106F
Salva todos os parâmetros MDO/MINUTA DO RENTAL
@author DENNIS CALABREZ
@since 23/09/2025
/*/
//-------------------------------------------------------------------
Static Function LOCA106F(cPar00,cPar01,cPar02, cCombo02, cCombo1)
Local lOk  := .T.
    
    ProcessMessages()
    Sleep(2000)

    //oSay:SetText(STR0124) //"Alterando Parâmentos"
    ProcessMessages()     

    PutMV("MV_LOCX159", cPar00)
    PutMV("MV_LOCX191", cPar01)
    PutMV("MV_LOCX056", cPar02)
    PutMV("MV_LOCX097", cCombo02)
     
    MsgInfo("Parâmetros Atualizados!", STR0018) //"Sucesso"
    
Return lOk
