#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE LOG_CONTINGENCIA_TAE "contingencia_tae.log"
#DEFINE LOG_MONITORAMENTO_TAE "monitoramento_tae.log"
#DEFINE LOG_ENV_TAE "envio_tae.log"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203
Browse Assinatura Eletronica

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203()

oBrw := FWmBrowse():New()
oBrw:SetAlias( 'BQ6' )
oBrw:SetDescription( 'Assinatura Eletronica' )
oBrw:SetMenuDef("PLSA203")
oBrw:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 	   Action 'ViewDef.PLSA203'		OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Reenvio Manual'  Action 'PL203RETRY'       OPERATION 6 ACCESS 0

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Lucas Nonato
@since 04/06/2024
@version P12
/*/
Static Function ModelDef()
    Local oModel 
    Local oStrBQ6 := FWFormStruct(1, 'BQ6')
    Local oStrBQ8 := FWFormStruct(1, 'BQ8')

    oModel := MPFormModel():New( 'PLSA203' )        
    oModel:addFields('MasterBQ6', , oStrBQ6)
    oModel:SetPrimaryKey( {"BQ6_FILIAL", "BQ6_NUMGUI", "BQ6_TPSIGN"} )
    oModel:addGrid('DetailBQ8', 'MasterBQ6', oStrBQ8)
    oModel:GetModel("DetailBQ8"):SetMaxLine(999999)
    oModel:setRelation('DetailBQ8', { { 'BQ8_FILIAL', 'xFilial("BQ8")' }, { 'BQ8_NUMGUI', 'BQ6_NUMGUI' } }, "4")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Lucas Nonato
@since 04/06/2024
@version P12
/*/
Static Function ViewDef()
    Local oView
    Local oModel   := ModelDef()
    Local oStrBQ6  := FWFormStruct(2, 'BQ6') 
    Local oStrBQ8  := FWFormStruct(2, 'BQ8') 

    oStrBQ8:RemoveField('BQ8_NUMGUI')

    oView := FWFormView():New()                                     
    oView:SetModel(oModel)
    oView:AddField('VIEW_BQ6', oStrBQ6, 'MasterBQ6')
    oView:AddGrid('VIEW_BQ8',  oStrBQ8, 'DetailBQ8')
    oView:CreateHorizontalBox('SUPERIOR', 40)
    oView:CreateHorizontalBox('INFERIOR', 60)
    oView:EnableTitleView("VIEW_BQ8", "Histórico de Transações e Logs (TAE)")
    oView:SetOwnerView('VIEW_BQ6', 'SUPERIOR')
    oView:SetOwnerView('VIEW_BQ8', 'INFERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL203SHOW
Função executada nativamente pelas consultas F3 criadas na SXB.
@author GuilhermeBonni
@since 28/05/2026
@version P12
/*/
Function PL203SHOW(cCampoLog)
    Local lRet     := .T. 
    Local oModel   := FwModelActive()
    Local oDlgLog

    PRIVATE cRetTAEMemo := ""

    If oModel != Nil .And. oModel:GetModel('DetailBQ8') != Nil
        cRetTAEMemo := ALLTRIM(oModel:GetValue('DetailBQ8', cCampoLog))
    EndIf

    If Empty(cRetTAEMemo)
        cRetTAEMemo := "[Este log está vazio]"
    EndIf

    Define MsDialog oDlgLog Title "Conteúdo do Log - " + cCampoLog From 0, 0 To 350, 250 Pixel

        TButton():New( 150, 040, "Fechar", oDlgLog, {|| oDlgLog:End() }, 040, 012, , , , .T., , , , , , .F. )

    Activate MsDialog oDlgLog Center

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL203RETRY
Função de validação e disparo do Reenvio Manual.
@author GuilhermeBonni
@since 28/05/2026
@version P12
/*/
Function PL203RETRY()
    Local aRecsBQ6 := {}
    Local cTpInc   := GetNewPar("MV_PLTPTAE", '') // 1-Benef; 2-Prestador; 3-Ambos
    Local aTipo    := Iif(!Empty(cTpInc), Iif(cTpInc == '3', {'1', '2'}, {cTpInc}), {})
    Local cNumGui  := BQ6->BQ6_NUMGUI
    Local cTipGui  := BQ6->BQ6_TIPGUI
    Local nX       := 1

    If BQ6->BQ6_STATUS == '2'
        Aviso("Operacao Abortada", "A Guia numero " + cNumGui + " ja consta como ASSINADA/FINALIZADA no portal e nao pode ser reenviada.", {'Ok'}, 2)
        Return .F.
    EndIf

    If Aviso("Confirmacao de Envio", "Deseja realizar o reenvio manual da Guia " + cNumGui + "?", { "Sim", "Não"}, 2 ) == 1
        
        AAdd(aRecsBQ6, BQ6->(RecNo()))

        BQ6->(DbSelectArea("BQ6"))
        BQ6->(DbSetOrder(1))
        For nX := 1 To Len(aTipo)
            If BQ6->(MsSeek(xFilial("BQ6") + cNumGui + aTipo[nX]))
                While !BQ6->(Eof()) .and. BQ6->BQ6_FILIAL == xFilial("BQ6") .and. BQ6->BQ6_NUMGUI == cNumGui
                    If BQ6->(RecNo()) != aRecsBQ6[1]
                        AAdd(aRecsBQ6, BQ6->(RecNo()))
                    EndIf
                    BQ6->(DbSkip())
                EndDo
            EndIf
        Next nX

        MsgRun("Conectando ao provedor e retransmitindo dados da guia...", "Aguarde", {|| PLSA203ENV(cNumGui, aRecsBQ6, cTipGui) })
        
        FWAlertSuccess("Processo de reenvio manual executado. Verifique a grid de rastreio para acompanhar o log.", "Sucesso")
        
        oBrw:Refresh()
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203GRV
Browse Assinatura Eletronica

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203GRV(cNumGui, cTipGui)
    Local cTpInc    := GetNewPar("MV_PLTPTAE", '') // 1-Benef; 2-Prestador; 3-Ambos
    Local aTipo     := Iif(!Empty(cTpInc), Iif(cTpInc == '3', {'1', '2'}, {cTpInc}), {})
    Local aRecsBQ6  := {}
    Local nX        := 1

    BQ6->(dbSetOrder(1))
    
    For nX := 1 To Len(aTipo)
        If !BQ6->(MsSeek(xFilial("BQ6") + cNumGui + aTipo[nX]))
            RecLock("BQ6", .T.)
            BQ6->BQ6_FILIAL := xFilial("BQ6")
            BQ6->BQ6_NUMGUI := cNumGui
            BQ6->BQ6_TIPGUI := cTipGui
            BQ6->BQ6_TPSIGN := aTipo[nX]
            BQ6->BQ6_DTENV  := Date()
            BQ6->BQ6_HORENV := Time()
            BQ6->BQ6_STATUS := 'X' // Pendente
            BQ6->(MsUnlock())
            AAdd(aRecsBQ6, BQ6->(RecNo()))
        Else
            AAdd(aRecsBQ6, BQ6->(RecNo()))
        EndIf
        
        // PE Possibilitando utilizar outra tabela de gravação, além da BQ6
        If ExistBlock("PL203GRV")
            ExecBlock("PL203GRV", .F., .F., {cNumGui, cTipGui})
        EndIf
    Next nX

    If !Empty(aRecsBQ6)
        StartJob("JOBENV203",GetEnvServer(), .F.,cEmpAnt, cFilAnt, cNumGui, aRecsBQ6, cTipGui)
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JOBENV203
Job para processamento do envio das guias para assinatura eletrônica, geração de PDF, busca de dados do participante e integração com TotvsSign

@author  GuilhermeBonni
@since   28/05/2026
@version P12
/*/
Function JOBENV203(cEmp, cFil, cNumGui, aRecsBQ6, cTipGui)
    RpcSetType(3)
    RpcSetEnv(cEmp, cFil,,,'PLS',,)

    PLSA203ENV(cNumGui, aRecsBQ6, cTipGui)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203ENV
Geração do PDF, busca de dados do participante e integração com TotvsSign

@author  GuilhermeBonni
@since   28/05/2026
@version P12

@param   cNumGui, Caractere, Número da Guia
@param   aRecsBQ6, Array, Lista de RecNos da tabela BQ6 a serem atualizados
@param   cTipGui, Caractere, Tipo da Guia
/*/
//-------------------------------------------------------------------
Function PLSA203ENV(cNumGui, aRecsBQ6, cTipGui)
    Local oSign          := PLSTotvsSign():New()
    Local jDestinatario  := JsonObject():New()
    Local aDadosGuia     := {}
    Local aDestinatarios := {}
    Local cCaminArquivo  := ''
    Local cEmail         := ''
    Local cMatric        := ''
    Local nDocId         := 0
    Local nIdPublicacao  := 0
    Local nStatus        := 0
    Local nX             := 1
    Local lUsaTae        := .T.
    Local lLogin         := .T.

    Do Case
        Case cTipGui == "02" // Guias SADT/Consulta/Odontologica
            aDadosGuia := PdfGuiaSADT(cNumGui)
        
        Case cTipGui == "03" // Guias Internação
            aDadosGuia := PdfGuiaInternacao(cNumGui)
        
        Case cTipGui == "11" // Guias Prorrogação de Internação
            aDadosGuia := PdfGuiaProrrogacao(cNumGui)
            
        Case cTipGui $ '07,08,09' // Guias Anexo Clinico
            aDadosGuia := PdfGuiaAnexo(cNumGui)	

        Case cTipGui == 'IN' // Situação Inicial
            aDadosGuia := PdfGuiaSituacaoInicial(cNumGui)
    EndCase

    if !Empty(aDadosGuia)
        cCaminArquivo := aDadosGuia[1]
        cMatric       := cValToChar(aDadosGuia[2])

        cMatric := StrTran(cMatric, ".", "")
        cMatric := StrTran(cMatric, "-", "")
        cMatric := AllTrim(cMatric)
        
        BA1->(dbSetOrder(2))
        If BA1->(MsSeek(xFilial("BA1") + cMatric))
            cEmail := AllTrim(BA1->BA1_EMAIL)
        EndIf

        // PE para enviar por fora do TAE (Customização de plataforma)
        If ExistBlock("PL203ENV")
            lUsaTae := ExecBlock("PL203ENV", .F., .F., {cNumGui, cEmail, aDadosGuia, cCaminArquivo})
        EndIf

        If lUsaTae
            If !oSign:login()
                lLogin := .F.
            EndIf

            If lLogin
                nDocId := oSign:uploadDocument(cCaminArquivo)

                If nDocId > 0
                    jDestinatario["email"]              := cEmail
                    jDestinatario["acao"]               := 1  // Assinar
                    jDestinatario["tipoAutenticacao"]   := 2  // Código via e-mail
                    jDestinatario["notificaEnvio"]      := .T.
                    jDestinatario["tipoEnvioDocumento"] := 1  // E-mail

                    If !Empty(aDadosGuia[3])
                        jDestinatario["nomeCompleto"]   := AllTrim(aDadosGuia[3])
                    EndIf

                    AAdd(aDestinatarios, jDestinatario)

                    nIdPublicacao := oSign:createPublication(nDocId, aDestinatarios, "Documento para assinatura eletrônica", "Por favor, revise e assine o documento anexo.", cNumGui)
                    
                    If nIdPublicacao > 0
                        nStatus := oSign:getPublicationStatus(nIdPublicacao)
                        
                        For nX := 1 To Len(aRecsBQ6)
                            BQ6->(dbGoto(aRecsBQ6[nX]))
                            
                            If BQ6->(RecLock("BQ6", .F.))
                                BQ6->BQ6_ENVELO := cValToChar(nIdPublicacao)
                                BQ6->BQ6_STATUS := cValToChar(nStatus)
                                BQ6->BQ6_EMAIL  := cEmail
                                BQ6->(MsUnlock())
                            EndIf
                        Next nX
                    Else
                        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSA203ENV: --- ERRO AO CRIAR PUBLICAÇÃO NO TAE ---", LOG_ENV_TAE)
                    EndIf
                Else
                    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSA203ENV: --- ERRO AO ENVIAR DOCUMENTO PARA O TAE ---", LOG_ENV_TAE)
                EndIf
            Else
                PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSA203ENV: --- ERRO AO TENTAR LOGIN NO TAE ---", LOG_ENV_TAE)
            EndIf
        EndIf
    Else
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSA203ENV: --- ERRO AO GERAR PDF DA GUIA ---", LOG_ENV_TAE)
    EndIf


    oSign:destroy()
    FreeObj(oSign)
    FreeObj(jDestinatario)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203STA
Browse Assinatura Eletronica
//X=Pend Envio;E=Erro;0=Pend Assinatura;1=Assinado parcialmente;2=Finalizado;4=Rejeitado;5=Rascunho;6=Pend PLS;7=Cancelado
@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203STA(cNumGui)
local cSql      := ''
local cAlias    := GetnextAlias()
local cRet      := ''
cSql := "SELECT BQ6_STATUS,BQ6_TPSIGN FROM " + RetSqlName("BQ6") + " BQ6 "
cSql += " WHERE BQ6_FILIAL 		= '" + xFilial("BQ6") + "' "	
cSql += " AND BQ6_NUMGUI		= '" + cNumGui + "' "	
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAlias,.F.,.T.)

while !(cAlias)->(eof())
    cRet := (cAlias)->BQ6_STATUS
    (cAlias)->(dbskip())
enddo

if empty(cRet)
    cRet := '0'
endif

(cAlias)->(dbCloseArea())
return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL203RETRY
Gera o arquivo PDF da Guias de SADT/Consulta/Odontologica.
@author GuilhermeBonni
@since 28/05/2026
@version P12

@return aRet, Array: [1] CaminhoFisico, [2] MatriculaLimpa, [3] NomeBenef
/*/
Static Function PdfGuiaSADT(cGuia) 
    Local cPathRelWeb  := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\") 
    Local cNameArquivo := ""
    Local aDadosGuia   := {}
    Local cVersaoTISS  := PLSTISSVER()
    Local cMatric      := ""
    Local cNome        := ""

    BEA->(DbSetOrder(1))
    If BEA->(MsSeek(xFilial("BEA") + cGuia))
        cMatric := BEA->(BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO)
        cNome   := AllTrim(BEA->BEA_NOMUSR)

        Do Case 
            Case BEA->BEA_TIPO == "1" // Guia Consulta
                aAdd(aDadosGuia, PLSGSADT(BEA->BEA_TIPO))

                If ExistBlock("PLR430CONS")
                    aDadosGuia := ExecBlock("PLR430CONS", .F., .F., {aDadosGuia})
                EndIf
                    
                cNameArquivo := IIf(cVersaoTISS >= "3", PlsTISSD(aDadosGuia, .F., 2, "", .T., cPathRelWeb), PlsTISS1(aDadosGuia, .F., 2, "", .T., cPathRelWeb))

            Case BEA->BEA_TIPO == "2" // Guia SADT  
                aAdd(aDadosGuia, PLSGSADT(BEA->BEA_TIPO))

                If ExistBlock("PLR430SADT")
                    aDadosGuia := ExecBlock("PLR430SADT", .F., .F., {aDadosGuia})
                EndIf

                cNameArquivo := IIf(cVersaoTISS >= "3", PlsTISSC(aDadosGuia, .F., 2, "", .T., cPathRelWeb,.F.), PlsTISS2(aDadosGuia, .F., 2, "", .T., cPathRelWeb))
                
            Case BEA->BEA_TIPO == "4" // Guia Odontologica
                aAdd(aDadosGuia, PLSGODCO())
                
                cNameArquivo := PLSTISS9(aDadosGuia, 2, "", .F., .T., cPathRelWeb)
        EndCase
    EndIf

Return {  cPathRelWeb + cNameArquivo, cMatric, cNome }

//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaInternacao
Gera o arquivo PDF da Guias de Internação.
@author GuilhermeBonni
@since 28/05/2026
@version P12

@return aRet, Array: [1] CaminhoFisico, [2] MatriculaLimpa, [3] NomeBenef
/*/
Static Function PdfGuiaInternacao(cGuia)
    Local cNameArquivo := ""
    Local cVersaoTISS  := PLSTISSVER()
    Local aDadosGuia   := {}
    Local cPathRelWeb  := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\") 
    Local cMatric      := ""
    Local cNome        := ""

    BE4->(DbSetOrder(2))
    If BE4->(MsSeek(xFilial("BE4") + cGuia))
        cMatric := BE4->(BE4_OPEUSR + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO)
        cNome   := AllTrim(BE4->BE4_NOMUSR)

        aAdd(aDadosGuia, PLSGINT(1))

        If ExistBlock("PLR430INT")
            aDadosGuia := ExecBlock("PLR430INT", .F., .F., {aDadosGuia})
        EndIf

        cNameArquivo := IIf(cVersaoTISS >= "3", PlsTISSE(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3], PlsTISS3(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3])
    EndIf

Return {  cPathRelWeb + cNameArquivo, cMatric, cNome }

//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaProrrogacao
Gera o arquivo PDF da Guias de Prorrogação de Internação
@author GuilhermeBonni
@since 28/05/2026
@version P12

@return aRet, Array: [1] CaminhoFisico, [2] MatriculaLimpa, [3] NomeBenef
/*/
Static Function PdfGuiaProrrogacao(cGuia)
    Local cNameArquivo := ""
    Local aDadosGuia   := {}  
    Local cPathRelWeb  := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\") 
    Local cMatric      := ""
    Local cNome        := ""

    B4Q->(DbSetOrder(1))
    If B4Q->(MsSeek(xFilial("B4Q") + cGuia))
        cMatric := B4Q->(B4Q_OPEUSR + B4Q_CODEMP + B4Q_MATRIC + B4Q_TIPREG + B4Q_DIGITO)
        cNome   := AllTrim(B4Q->B4Q_NOMUSR)

        aAdd(aDadosGuia, PLSGINT(3))
        cNameArquivo := PLSTISSP(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3]
    EndIf

Return {  cPathRelWeb + cNameArquivo, cMatric, cNome }

//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaAnexo
Gera o arquivo PDF da Guias de Anexo Clinico
@author GuilhermeBonni
@since 28/05/2026
@version P12

@return aRet, Array: [1] CaminhoFisico, [2] MatriculaLimpa, [3] NomeBenef
/*/
Static Function PdfGuiaAnexo(cGuia)
    Local aArquivo     := {}
    Local cNameArquivo := ""
    Local cPathRelWeb  := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\") 
    Local cMatric      := ""
    Local cNome        := ""

    B4A->(DbSetOrder(1))
    If B4A->(MsSeek(xFilial("B4A") + cGuia))
        cMatric := B4A->(B4A_OPEUSR + B4A_CODEMP + B4A_MATRIC + B4A_TIPREG + B4A_DIGITO)
        cNome   := AllTrim(B4A->B4A_NOMUSR)
        
        aArquivo := PLS09AIma(.T., cPathRelWeb)

        If !Empty(aArquivo) .And. aArquivo[1]
            cNameArquivo := aArquivo[3]
        EndIf
    EndIf

Return {  cPathRelWeb + cNameArquivo, cMatric, cNome }

//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaSituacaoInicial
Gera o arquivo PDF da Guias de Situação Inicial
@author GuilhermeBonni
@since 28/05/2026
@version P12

@return aRet, Array: [1] CaminhoFisico, [2] MatriculaLimpa, [3] NomeBenef
/*/
Static Function PdfGuiaSituacaoInicial(cGuia)
    Local cNameArquivo := ""
    Local aDadosGuia   := {}  
    Local cPathRelWeb  := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\") 
    Local cMatric      := ""
    Local cNome        := ""
    Local cVersaoTISS  := PLSTISSVER()


    aAdd(aDadosGuia, PLSGODSO(cGuia))
    cNome   := iif(cVersaoTISS >= "3", aDadosGuia[1][5], aDadosGuia[1][8])
    cMatric := iif(cVersaoTISS >= "3", aDadosGuia[1][6], aDadosGuia[1][4])

    cNameArquivo := PLSSOLINI(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3]

Return {  cPathRelWeb + cNameArquivo, cMatric, cNome }

//-------------------------------------------------------------------
/*/{Protheus.doc} PL203SCHA
Schedule de Contingência: Reenvio de Guias com Falha

@param   cEmp, Caractere, Empresa enviada pelo Schedule
@param   cFil, Caractere, Filial enviada pelo Schedule
@author  GuilhermeBonni
@since   28/05/2026
@version P12
/*/
Function PL203SCHA(cEmp, cFil)
    Local cSql          := "" as character
    Local cAlias        := "" as character
    Local cGuiaAtual    := "" as character
    Local cTipGui       := "" as character
    Local aRecsBQ6      := {}

    RpcSetType(3)
    RpcSetEnv(cEmp, cFil,,,"PLS",,)

    If LockByName("PL203SCHA", .T., .F., .T.)
        
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHA: --- INICIANDO REENVIO DE FALHAS VIA RECNOS ---", LOG_CONTINGENCIA_TAE)

        cAlias := GetNextAlias()
        cSql := " SELECT BQ6_NUMGUI, BQ6_TIPGUI, R_E_C_N_O_ AS RECBQ6 "
        cSql += " FROM " + RetSqlName("BQ6") + " BQ6 "
        cSql += " WHERE BQ6_FILIAL = '" + xFilial("BQ6") + "' "
        cSql += " AND BQ6_STATUS IN ('X', 'E') "
        cSql += " AND D_E_L_E_T_ = ' ' "
        cSql += " ORDER BY BQ6_NUMGUI "

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAlias, .F., .T.)

        While !(cAlias)->(Eof())
            cGuiaAtual := (cAlias)->BQ6_NUMGUI
            cTipGui    := (cAlias)->BQ6_TIPGUI
            aRecsBQ6   := {}

            PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHA: Agrupando registros da Guia: " + cGuiaAtual, LOG_CONTINGENCIA_TAE)

            While !(cAlias)->(Eof()) .and. (cAlias)->BQ6_NUMGUI == cGuiaAtual
                AAdd(aRecsBQ6, (cAlias)->RECBQ6)
                (cAlias)->(DbSkip())
            EndDo

            If !Empty(aRecsBQ6)
                PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHA: Disparando PLSA203ENV para a Guia: " + cGuiaAtual + " com " + cValToChar(Len(aRecsBQ6)) + " registro(s).", LOG_CONTINGENCIA_TAE)
                
                PLSA203ENV(cGuiaAtual, aRecsBQ6, cTipGui)
            EndIf
        EndDo
        
        (cAlias)->(DbCloseArea())

        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHA: --- FIM DO PROCESSAMENTO DE REENVIO ---", LOG_CONTINGENCIA_TAE)

        RpcClearEnv()
        UnLockByName("PL203SCHA", .F., .F.)
    Else
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHA: ALERTA - Processo de reenvio ja esta em execucao.", LOG_CONTINGENCIA_TAE)
    EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PL203SCHB
Schedule de Monitoramento: Buscar status de assinaturas ativas (D-1)

@param   cEmp, Caractere, Empresa enviada pelo Schedule
@param   cFil, Caractere, Filial enviada pelo Schedule
@author  GuilhermeBonni
@since   28/05/2026
@version P12
/*/
//-------------------------------------------------------------------
Function PL203SCHB(cEmp, cFil)
    Local cSql        := "" as character
    Local cAlias      := "" as character
    Local oSign       := Nil as object
    Local nStatus     := 0 as numeric
    Local cIdEnvelope := "" as character
    Local cNumGui     := "" as character

    RpcSetType(3)
    RpcSetEnv(cEmp, cFil,,,"PLS",,)

    If LockByName("PL203SCHB", .T., .F., .T.)

        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: --- INICIANDO MONITORAMENTO DE ASSINATURAS ---", LOG_MONITORAMENTO_TAE)

        cAlias := GetNextAlias()
        cSql := " SELECT BQ6_NUMGUI, BQ6_ENVELO, R_E_C_N_O_ AS RECBQ6 "
        cSql += " FROM " + RetSqlName("BQ6") + " BQ6 "
        cSql += " WHERE BQ6_FILIAL = '" + xFilial("BQ6") + "' "
        cSql += " AND BQ6_STATUS = '0' " // '0' = Pendente de Assinatura
        cSql += " AND BQ6_DTENV >= '" + DtoS(Date() - 1) + "' " // Filtro D-1 (Máximo 1 dia)
        cSql += " AND D_E_L_E_T_ = ' ' "

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAlias, .F., .T.)

        If !(cAlias)->(Eof())
            oSign := PLSTotvsSign():New()
            
            If oSign:login()
                While !(cAlias)->(Eof())
                    cIdEnvelope := AllTrim((cAlias)->BQ6_ENVELO)
                    cNumGui     := (cAlias)->BQ6_NUMGUI

                    If !Empty(cIdEnvelope)
                        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: Consultando status do envelope " + cIdEnvelope, LOG_MONITORAMENTO_TAE)
                        
                        nStatus := oSign:getPublicationStatus(Val(cIdEnvelope))
                        
                        if !Empty(nStatus) .and. cValToChar(nStatus) != '0'
                            BQ6->(DbGoto((cAlias)->RECBQ6))
                            If BQ6->(RecLock("BQ6", .F.))
                                BQ6->BQ6_STATUS := cValToChar(nStatus)
                                If BQ6->BQ6_STATUS $ '1,2'
                                    BQ6->BQ6_DTSIGN := Date()
                                    BQ6->BQ6_HRSIGN := Time()
                                EndIf
                                BQ6->(MsUnlock())
                                PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: Guia " + cNumGui + " atualizada para status: " + cValToChar(nStatus), LOG_MONITORAMENTO_TAE)
                            EndIf
                        Endif
                    EndIf
                    (cAlias)->(DbSkip())
                EndDo
            Else
                PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: ERRO - Falha na autenticação com a API TotvsSign", LOG_MONITORAMENTO_TAE)
            EndIf

            oSign:destroy()
            FreeObj(oSign)
        EndIf
        (cAlias)->(DbCloseArea())

        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: --- FIM DO PROCESSAMENTO DE MONITORAMENTO ---", LOG_MONITORAMENTO_TAE)

        RpcClearEnv()
        UnLockByName("PL203SCHB", .F., .F.)
    Else
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PL203SCHB: ALERTA - Processo de monitoramento ja esta em execucao.", LOG_MONITORAMENTO_TAE)
    EndIf
Return .T.
