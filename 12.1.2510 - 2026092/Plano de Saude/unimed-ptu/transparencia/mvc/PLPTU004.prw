#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} PLPTU004
Consulta do log de recebimento das mensagens do processo
de Serviços de Protocolos Pagos (Transparência) PTU.
Rotina somente para consulta.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
/*/
Function PLPTU004()

    Local aParam := {}
    Local cFiltro := ""

    /*
        Tela de parâmetros
    */
    If !BIWParametros(@aParam)
        Return
    EndIf

    /*
        Monta filtro do Browse
    */
    cFiltro := BIWMontaFiltro(aParam)

    /*
        Abre consulta MVC
    */
    BIWBrowse(cFiltro)

Return

/*/{Protheus.doc} ModelDef
Modelo MVC da consulta BIW.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
/*/
Static Function ModelDef()

    Local oModel := Nil
    Local oStruct := FWFormStruct(1, "BIW")

    /*
        Modelo somente leitura
    */

    oModel := MPFormModel():New("PLPTU004")

    oModel:SetDescription( ;
        "Log de Recebimento - Transparência PTU")

    oModel:AddFields( ;
        "BIWMASTER", ;
        Nil, ;
        oStruct )

    /*
        Define a chave primária do modelo.
        Necessária para a ativação do FWFormModel.
    */
    oModel:SetPrimaryKey( { "BIW_FILIAL", "BIW_CTRL" } )

Return oModel

/*/{Protheus.doc} ViewDef
Interface MVC da consulta BIW.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
/*/
Static Function ViewDef()

    Local oView  := Nil
    Local oModel := FWLoadModel("PLPTU004")
    Local oStruct := FWFormStruct(2, "BIW")

    /*
        Remove campos técnicos
    */

    oStruct:RemoveField("BIW_FILIAL")

    /*
        Cria View
    */

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField( ;
        "BIWFORM", ;
        oStruct, ;
        "BIWMASTER" )

    oView:CreateHorizontalBox( ;
        "BOXFORM", ;
        100 )

    oView:SetOwnerView( ;
        "BIWFORM", ;
        "BOXFORM" )

    oView:SetDescription( ;
        "Visualização - Log Transparência PTU")

Return oView

/*/{Protheus.doc} BIWParametros
Tela de parâmetros da consulta.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
@param aParam, array, parâmetros de filtro
/*/
Static Function BIWParametros(aParam)

    Local lRet := .F.

    Local dDataIni := Date() - 30
    Local dDataFim := Date()

    Local cControle := Space(30)
    Local cCnpjCpf  := Space(14)

    Local aPerg := {}
    Local aRet  := {}

    /*
        Perguntas
    */
    
    AAdd(aPerg, {1, "Data Inicial", dDataIni, "@D", ;
        "", ;
        "", "", 60, .T.})

    AAdd(aPerg, {1, "Data Final", dDataFim, "@D", ;
        "", ;
        "", "", 60, .T.})

    AAdd(aPerg, {1, "Nº Controle", cControle, "@!", ;
        "", ;
        "", "", 80, .F.})

    AAdd(aPerg, {1, "CPF/CNPJ", cCnpjCpf, "@!", ;
        "", ;
        "", "", 80, .F.})

    /*
        Execução da tela de parâmetros.
    */
    
    If paramBox( aPerg,"Filtro de Tela",aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLPTU004',/*lCanSave*/.T.,/*lUserSave*/.T. )
        /*
            Validação do período
        */

        If aRet[1] > aRet[2]

            MsgStop( ;
                "A Data Inicial não pode ser maior que a Data Final.", ;
                "Consulta")

            Return .F.

        EndIf

        /*
            Limita consulta para evitar pesquisas acidentais
            muito grandes.
        */

        If (aRet[2] - aRet[1]) > 365

            MsgStop( ;
                "O período máximo permitido para consulta é de 365 dias.", ;
                "Consulta")

            Return .F.

        EndIf

        /*
            Retorno dos parâmetros
        */

        aParam := { ;
            aRet[1], ;
            aRet[2], ;
            AllTrim(aRet[3]), ;
            AllTrim(aRet[4]), ;
        }

        lRet := .T.
    endif
Return lRet

/*/{Protheus.doc} BIWMontaFiltro
Monta expressão de filtro para o FWMBrowse.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
@param aParam, array, filtros selecionados
/*/
Static Function BIWMontaFiltro(aParam)

    Local dDataIni  := aParam[1]
    Local dDataFim  := aParam[2]

    Local cControle := aParam[3]
    Local cCnpjCpf  := aParam[4]

    Local cFiltro := ""

    /*
        Filial
    */

    cFiltro := 'BIW_FILIAL == "' + xFilial("BIW") + '"'

    /*
        Período
    */

    cFiltro += ;
        ' .And. BIW_DATA >= CTOD("' + ;
        DToS(dDataIni) + '")'

    cFiltro += ;
        ' .And. BIW_DATA <= CTOD("' + ;
        DToS(dDataFim) + '")'

    /*
        Número de controle
    */

    If !Empty(cControle)

        cFiltro += ;
            ' .And. BIW_CTRL == "' + ;
            cControle + '"'

    EndIf

    /*
        CPF/CNPJ
    */

    If !Empty(cCnpjCpf)
        cFiltro += ;
            ' .And. BIW_CNPJ == "' + ;
            cCnpjCpf + '"'
    EndIf
Return cFiltro

/*/{Protheus.doc} BIWBrowse
Abre o Browse MVC da consulta.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
@param cFiltro, character, filtro da pesquisa
/*/
Static Function BIWBrowse(cFiltro)    
    Local oBrowse := Nil

    /*
        Seleciona tabela
    */

    DbSelectArea("BIW")

    /*
        Instancia Browse MVC
    */

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("BIW")

    oBrowse:SetDescription( ;
        "Log de Recebimento - Transparência PTU")

    /*
        Filtro inicial
    */

    oBrowse:SetFilterDefault(cFiltro)

    /*
        Não permite manutenção
    */

    oBrowse:SetExecuteDef(2)

    /*
        Legendas
    */

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'S ' .and. BIW_TPTRA == '1'", ;
        "GREEN", ;
        "Respondido Protocolo com sucesso")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'E ' .and. BIW_TPTRA == '1'", ;
        "RED", ;
        "Falha na Resposta do Protocolo")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'NA' .and. BIW_TPTRA == '1'", ;
        "YELLOW", ;
        "Não há dados de Protocolo")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'R ' .and. BIW_TPTRA == '1'", ;
        "BLACK", ;
        "Mensagem de Protocolo Recebida")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'S ' .and. BIW_TPTRA == '2'", ;
        "BLUE", ;
        "Respondido Detalhe de Protocolo com sucesso")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'E ' .and. BIW_TPTRA == '2'", ;
        "ORANGE", ;
        "Falha na Resposta do Detalhe de Protocolo")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'NA' .and. BIW_TPTRA == '2'", ;
        "WHITE", ;
        "Não há dados de Detalhe Protocolo")

    oBrowse:AddLegend( ;
        "BIW_STATUS == 'R ' .and. BIW_TPTRA == '2'", ;
        "BROWN", ;
        "Mensagem de Detalhe Protocolo Recebida")

    /*
        Ativa filtros adicionais do Browse
    */

    oBrowse:SetUseFilter(.T.)

    oBrowse:SetUseCaseFilter(.T.)
   

    /*
        Abre tela
    */

    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Menu funcional da consulta.
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
/*/
Static Function MenuDef()

    Local aRotina := {}

    /*
        Visualização
    */

    ADD OPTION aRotina ;
        TITLE "Visualizar" ;
        ACTION "VIEWDEF.PLPTU004()" ;
        OPERATION MODEL_OPERATION_VIEW ;
        ACCESS 0

    /*
        Download do ZIP
    */

    ADD OPTION aRotina ;
        TITLE "Baixar arquivo ZIP" ;
        ACTION "BIWDownload()" ;
        OPERATION 1 ;
        ACCESS 0

Return aRotina

/*/{Protheus.doc} BIWDownload
Realiza o download do arquivo ZIP referente
ao registro selecionado.

O arquivo encontra-se no servidor Protheus em:

\ptutransparencia
@type function
@version 12.1.2510
@author zaar.goes
@since 27/08/2026
/*/
Function BIWDownload()

    Local cArquivo := ""
    Local cDestino := ""
    Local cOrigem := ""  

    /*
        Verifica arquivo informado
    */

    cArquivo := AllTrim(BIW->BIW_ARQZIP)

    If Empty(cArquivo)

        MsgStop( ;
            "Não existe arquivo ZIP associado a esta transação.", ;
            "Download")

        Return

    EndIf

    /*
        Caminho no servidor
    */

    cOrigem := "\ptutransparencia\" + cArquivo

    /*
        Verifica existência
    */

    If !File(cOrigem)

        MsgStop( ;
            "O arquivo ZIP não foi localizado no servidor:" + ;
            CRLF + ;
            cOrigem, ;
            "Download")

        Return

    EndIf

    /*
        Solicita local no computador do usuário.
    */

    cDestino := cGetFile( ;
        "Arquivos ZIP (*.zip)|*.zip", ;
        "Salvar arquivo ZIP", ;
        0, ;
        cArquivo, ;
        .T. )

    If !Empty(cDestino)

        /*
            Servidor -> estação
        */

        If CpyS2T(cOrigem, cDestino)

            MsgInfo( ;
                "Arquivo transferido com sucesso." + ;
                CRLF + CRLF + ;
                cDestino, ;
                "Download")
        Else
            MsgStop( ;
                "Não foi possível transferir o arquivo ZIP.", ;
                "Download")
        EndIf
    EndIf
Return
