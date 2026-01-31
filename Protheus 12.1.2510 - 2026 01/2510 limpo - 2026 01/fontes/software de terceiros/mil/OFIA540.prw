#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "OFIA540.CH" 

/*/{Protheus.doc} OFIA540 ------------------------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Rotina espelho do Pedido de Compras para processos Scania.
         Reaproveita o browse padrão da rotina MATA120 com transações específicas.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------/*/
Function OFIA540()
    Private aRotina := MenuDef()
    MATA120(1) // Reaproveita browse padrão SC7
Return

/*/{Protheus.doc} MenuDef -------------------------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Cria o menu principal e submenu específico da rotina SC7 Scania.
@returns Array com definições de menu.
---------------------------------------------------------------------------------------------------*/
Static Function MenuDef() As Array
Local aRotina := {}, aSub := {}

aAdd(aRotina, { STR0001, 'AxPesqui'           , 0, 1}) // 'Pesquisar' 
aAdd(aRotina, { STR0002, 'A120Pedido'         , 0, 2}) // 'Visualizar'
aAdd(aRotina, { STR0003, 'A120Pedido'         , 0, 3}) // 'Incluir'   
aAdd(aRotina, { STR0004, 'OFIA540MENU(0)'     , 0, 4}) // 'Alterar'   
aAdd(aRotina, { STR0005, 'OFIA540MENU(0)'     , 0, 5}) // 'Excluir'    
aAdd(aRotina, { STR0022,  'A120Copia'         , 0, 9, 0, Nil }) //"Copia"

If SuperGetMv("MV_ENVPED") $ "1|2"
	aAdd(aRotina,{STR0023,"A120Mail"  , 0, 2, 0, Nil }) //"Reenvia e-mail"
EndIf
aAdd(aRotina, { STR0024 , 'A120Impri'        , 0, 6}) // Imprimir
aAdd(aRotina, { STR0006 , 'A120Legend'       , 0, 1}) // 'Legenda'  
aAdd(aRotina, { STR0025 ,  'MsDocument'      , 0, 4, 0, Nil }) //"Conhecimento" 
aAdd(aRotina, { STR0026 ,  'A120Contr'       , 0, 2, 0, Nil }) //"Rastr.Contrato"
aAdd(aRotina, { STR0027 ,  'CTBC662'         , 0, 7, 0, Nil }) //"Tracker Contábil" 

// Submenu Scania
aAdd(aSub, {STR0007  , "OFIA540MENU(1)"    , 0, 7})  // Vincular Pedido de Fábrica
aAdd(aSub, {STR0008  , "OFIA540MENU(2)", 0, 7})      // Exportar Pedido em Excel
aAdd(aRotina, {STR0007, aSub, 0, 7})                 // Scania

aAdd(aRotina, { STR0031 , 'OFIA542'        , 0, 6}) // Importar Pedido Peças
aAdd(aRotina, { STR0032 , 'OFIA601'        , 0, 6}) // Eliminar Resíduos BO

Return aRotina

/*/{Protheus.doc} OFIA540MENU ----------------------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@param   nOpc , numeric, opção do menu selecionada (0=Validação VEI, 1=Vincular, 2=Exportar Excel)
@desc    Controla o direcionamento da execução com base na opção selecionada no menu Scania.
         Redireciona para validação de edição, vinculação de pedido de fábrica ou exportação Excel.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Function OFIA540MENU(nOpc)

   Do Case 
      Case nOpc == 0
         OC540001N_ValidaEdicaoPedidoVEI()
      Case nOpc == 1
         OC540002N_VinculaPedidoFabrica()
      Case nOpc == 2
         OC540007N_ExportaPedidoExcel()
   EndCase 

return()

/*/{Protheus.doc} OC540002N_VinculaPedidoFabrica --------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Vincula um pedido SC7 a um pedido de fábrica (tabela VEI), com parâmetros via MT297A.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Static Function OC540002N_VinculaPedidoFabrica()
Local aArea    := GetArea()
Local cFil     := FWxFilial("VEI")
Local cNumPed  := SC7->C7_NUM
Local cCodMar  := GetNewPar("MV_MIL0006") // Marca da montadora (Scania)
Local cPedFab  := ""
Local cTipPed  := ""
Local cViaTra  := ""
Local cTransp  := ""
Local cPgt48h  := ""

// Carrrego as MV_PAR's sem exibir tela
Pergunte("MT297A", .F.)

   // Sempre limpar antes
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR01", 1)
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR02", "")
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR03", 1)
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR04", "")
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR05", "")

/* Se já existir vínculo, carregar dados para MV_PARxx */
If OC540003N_VerificaVinculoVEI(cFil, cNumPed)
    
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR01", Val(VEI->VEI_VIATRA)) // Via transporte
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR02", VEI->VEI_TRANSP) // Transportadora
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR03", Val(VEI->VEI_PGT48H)) // Pagamento 48h
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR04", VEI->VEI_PEDFAB) // Pedido fábrica
   OC540006N_AtualizaParametroPergunta("MT297A","MV_PAR05", VEI->VEI_TIPPED) // Tipo pedido
    
EndIf

/* Pergunte MT297A */
If Pergunte("MT297A", .T.)
   // Recupera parâmetros
   cViaTra := cValToChar(MV_PAR01)
   cTransp := AllTrim(MV_PAR02)
   cPgt48h := cValToChar(MV_PAR03)
   cPedFab := AllTrim(MV_PAR04)
   cTipPed := AllTrim(MV_PAR05)
   
   If !Empty(cPedFab)
      // Trata chave conforme MV_PEDANO
      If GetNewPar("MV_PEDANO","N") == "S"
         cPedFab := AllTrim(cPedFab) + "/" + Right(DtoC(Date()),2)
      Else
         cPedFab := AllTrim(cPedFab) // cPedFab := PadL(AllTrim(cPedFab), 13)
      EndIf
   Endif

   Processa({|| OC540004N_GravaOuAtualizaVEI(cFil, cNumPed, cCodMar, cPedFab, ;
                          cTipPed, cViaTra, cTransp, cPgt48h, ;
                          "", "")}, STR0010) // "Gravando vínculo VEI..."

   FWAlertSuccess(STR0011,STR0012 ) // "Pedido de Fábrica vinculado com sucesso!" # "DMS Scania"
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} OC540001N_ValidaEdicaoPedidoVEI ------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Verifica se o pedido já está vinculado à VEI antes de permitir alteração ou exclusão.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Static Function OC540001N_ValidaEdicaoPedidoVEI()

Local lExist   := OC540003N_VerificaVinculoVEI(FWxFilial("VEI"), SC7->C7_NUM)
Local lInclui  := INCLUI
Local lAltera  := ALTERA
Local lExclui  := (!lInclui .AND. !lAltera)

If lExist .and. !Empty(VEI->VEI_PEDFAB)
   FMX_HELP("OC540003N", STR0013, STR0030)
Else
   If lAltera
      A120Pedido("SC7", SC7->(Recno()), 4)
   ElseIf lExclui
      A120Pedido("SC7", SC7->(Recno()), 5)
   EndIf
EndIf
Return

/*/{Protheus.doc} OC540003N_VerificaVinculoVEI ------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Verifica a existência de vínculo VEI (pedido de fábrica) para um pedido SC7.
@returns Booleano indicando existência do vínculo.
---------------------------------------------------------------------------------------------------*/
Static Function OC540003N_VerificaVinculoVEI(cFil, cNumPed)
Local lExistVEI := .F.
Local cMarcaVEI := GetNewPar("MV_MIL0006")
Local aArea     := GetArea()

cMarcaVEI   := PADR(cMarcaVEI,TAMSX3("VEI_CODMAR")[1])
cNumPed     := PADR(cNumPed,TAMSX3("VEI_NUM")[1])

dbSelectArea("VEI")
dbSetOrder(1) // índice VEI_FILIAL+VEI_CODMAR+VEI_NUM 
lExistVEI := VEI->(dbSeek(cFil + cMarcaVEI + cNumPed))

RestArea(aArea)

Return(lExistVEI)

/*/{Protheus.doc} OC540004N_GravaOuAtualizaVEI -----------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Insere ou atualiza dados de vínculo VEI para um pedido SC7.
@returns Booleano indicando sucesso da operação.
---------------------------------------------------------------------------------------------------*/
Static Function OC540004N_GravaOuAtualizaVEI(cFil, cNumPed, cCodMar, cPedFab, cTipPed, cViaTra, cTransp, cPgt48h, cNumOSV, cChaInt)
Local lNovo := .F.

dbSelectArea("VEI")
dbSetOrder(1) // índice VEI_FILIAL+VEI_CODMAR+VEI_NUM

cCodMar   := PADR(cCodMar,TAMSX3("VEI_CODMAR")[1])
cNumPed   := PADR(cNumPed,TAMSX3("VEI_NUM")[1])

If !(dbSeek(cFil + cCodMar + cNumPed))
   RecLock("VEI", .T.)
   lNovo := .T.
Else
   RecLock("VEI", .F.)
EndIf

// Chaves só na inclusão - Indice 1 VEI_FILIAL+VEI_CODMAR+VEI_NUM
If lNovo
   VEI->VEI_FILIAL := cFil
   VEI->VEI_CODMAR := cCodMar
   VEI->VEI_NUM    := cNumPed
EndIf

// Sempre atualizáveis
VEI->VEI_PEDFAB := cPedFab
VEI->VEI_TIPPED := cTipPed
VEI->VEI_VIATRA := cViaTra
VEI->VEI_TRANSP := cTransp
VEI->VEI_PGT48H := cPgt48h
VEI->VEI_NUMOSV := cNumOSV
VEI->VEI_CHAINT := cChaInt
VEI->VEI_DATSC7 := dDatabase
VEI->VEI_HORSC7 := Val(Substr(Time(),1,2)+Substr(Time(),4,2))

VEI->( MsUnlock() )
Return .T.

/*/{Protheus.doc} OC540006N_AtualizaParametroPergunta ------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Atualiza os parâmetros da pergunta MT297A com valores programaticamente, utilizando SetMVValue.
@param   cPergAux, caractere: Código da pergunta que será atualizada.
@param   cParAux, caractere: Nome do parâmetro (MV_...) que será atualizado.
@param   xConteud, genérico: Valor que será atribuído ao parâmetro.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Static Function OC540006N_AtualizaParametroPergunta(cPergAux, cParAux, xConteud)
    Local aArea      := GetArea()
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''

    // Valida parâmetros obrigatórios
    If Empty(cPergAux) .Or. Empty(cParAux)
        Return
    EndIf

    // Carrega pergunta em memória
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

    // Procura o parâmetro na estrutura da pergunta
    nLinEncont := aScan(aPergAux, {|x| Upper(AllTrim(x[nPosPar])) == Upper(cParAux) })

    // Se encontrado, define o novo valor
    If nLinEncont > 0
        // Atribui valor ao parâmetro via SetMVValue (persistente e seguro)
        SetMVValue(cPergAux, cParAux, xConteud, .F.)
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} OC540007N_ExportaPedidoExcel -----------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@desc    Exporta os dados do pedido SC7 (Pedido de Compras) em formato Excel (.xls),
         permitindo ao usuário escolher o diretório de salvamento. Utiliza o Excel nativo do Protheus.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Static Function OC540007N_ExportaPedidoExcel()
   
   Local cNum        := SC7->C7_NUM
   Local cName       := cNum + "__LPCNet.xls" 
   Local cDir        := ""
   Local cFull       := ""
   Local lPrintAtu:= PrinterVersion():fromServer() >= "2.1.0" 

   if ( lPrintAtu )
      // 1) Pede SÓ a pasta (modo Open = 0). Com GETF_RETDIRECTORY o retorno é um diretório.
      //cDir := cGetFile( "", GetTempPath(), 0, "", .F., nFlags, .T., , .T. )
      cDir := &("cGetFile('*.xls', '*.xls', 1, 'SERVIDOR', .F., " + str(nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)) + ", .T., .T.)")

      If Empty(cDir)
         Return
      EndIf

      cFull := cDir + cName

      Processa({|| OC540008N_GeraArquivoPedidoExcel(SC7->C7_NUM, cFull, cName)}, STR0015) // "Gerando Excel..."

      FMX_HELP(STR0016,STR0017 + cFull ) // "Exportação Pedido" ### "Arquivo gerado em: "

   Else 

      FMX_HELP("printer.exe",; 
               STR0028,; // "A geração de arquivo Excel depende primariamente do printer.exe com a versão igual ou superior a 2.1.0."
               STR0029)  // "Por favor, acesse a central de downloads para atualizar o arquivo." 
   Endif 
Return

/*/{Protheus.doc} OC540008N_GeraArquivoPedidoExcel -------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   22/09/2025
@version 1.0
@param   cNum  , char, número do pedido SC7 a ser exportado
@param   cFull , char, caminho completo onde o arquivo Excel será salvo
@desc    Executa a geração do arquivo Excel com os dados do pedido SC7,
         incluindo código do item e quantidade, sem cabeçalho, usando a classe FWMsExcelEx.
@returns Não possui retorno.
---------------------------------------------------------------------------------------------------*/
Static Function OC540008N_GeraArquivoPedidoExcel(cNum As Char, cFull As Char, cName As Char )
   Local cQry    := ""
   Local cAlias  := ""
   Local oSQL    := FWPreparedStatement():New()
   Local oExcel  := FWMSExcelXLSX():New() //FWMsExcelEx():New()    FWMSEXCEL():New() 
   Local cSheet  := cName //STR0018 // "Pedido Compra Scania"
   Local cTable  := STR0019 // "Pedido"
   Local aRow    := {}

   cQry += "SELECT SB1.B1_CODITE, SC7.C7_QUANT " + CRLF
   cQry += "  FROM " + RetSQLName("SC7") + " SC7 " + CRLF
   cQry += "  JOIN " + RetSQLName("SB1") + " SB1 " + CRLF
   cQry += "    ON SB1.B1_FILIAL   = '" + FWxFilial("SB1") + "' " + ;
           "   AND SB1.B1_COD      = SC7.C7_PRODUTO " + ;
           "   AND SB1.D_E_L_E_T_  = ' ' " + CRLF
   cQry += " WHERE SC7.C7_FILIAL   = '" + FWxFilial("SC7") + "' " + ;
           "   AND SC7.C7_NUM      = '" + cNum + "' " + ;
           "   AND SC7.D_E_L_E_T_  = ' ' " + CRLF
   cQry += " ORDER BY SC7.C7_ITEM "

   oSQL:SetQuery(cQry)
   cQry   := oSQL:GetFixQuery()
   cAlias := MPSysOpenQuery(cQry)

   If (cAlias)->(EOF())
      (cAlias)->(dbCloseArea())
      FMX_HELP(STR0020,STR0021) // Exportação ### "Pedido sem itens para exportar."
      Return
   EndIf

   oExcel:AddworkSheet(cSheet)
   oExcel:AddTable   (cSheet, cTable, .F./*lPrintHead*/)
   // sem cabeçalho: títulos vazios
   lFirst := .F. 
   While !(cAlias)->(EOF())
      
      If (!lFirst)
      
         oExcel:AddColumn  (cSheet, cTable, (cAlias)->B1_CODITE   , 1, 1) // B1_CODITE (texto à esquerda)
         oExcel:AddColumn  (cSheet, cTable, (cAlias)->C7_QUANT    , 3, 1) // C7_QUANT  (número à direita)

         lFirst := .T.

      Else  
   
         aRow := { AllTrim((cAlias)->B1_CODITE), (cAlias)->C7_QUANT }
         oExcel:AddRow(cSheet, cTable, aRow)

      EndIf 
      
      (cAlias)->(dbSkip())
   EndDo
   (cAlias)->(dbCloseArea())

   oExcel:Activate()
   // AQUI: caminho COMPLETO garantido (pasta + arquivo)
   oExcel:GetXMLFile(AllTrim(cFull))

Return


