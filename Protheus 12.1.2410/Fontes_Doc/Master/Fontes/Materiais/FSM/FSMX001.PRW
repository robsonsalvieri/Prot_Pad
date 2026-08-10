#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMX001(cCodigo, cMsgRet, cCodRet) 
Função que gera o formulário do checklist
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Function FSMX001(cCodigo, cMsgRet, cCodRet) 

Local lRet      := .T.
Local cVersao   := ''

dbSelectArea("JND")
JND->(dbSetOrder(1))

If JND->(dbSeek(xFilial('JND')+cCodigo))
    
    While !(JND->(Eof()))

        If (JND->JND_STATUS == '2')
            cVersao := JND->JND_VERSAO
            Exit
        Endif

        JND->(dbSkip())

    EndDo

    If (cVersao == '')
        cMsgRet := 'Checklist não possui versão publicada'
        lRet := .F.
    Else
        lRet := GeraForm(cCodigo, cVersao, @cCodRet)
    Endif

Else 
    cMsgRet := 'Código de checklist não encontrado'
    lRet := .F.
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GeraForm(cCodigo, cVersao, cCodRet)
Função que gera o formulário do checklist
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Static Function GeraForm(cCodigo, cVersao, cCodRet)
Local lRet := .T.
Local oMdlChk  := FwLoadModel('FSMA016')
Local oMdlForm := FwLoadModel('FSMA021')
Local oMdlJNE  := Nil
Local oMdlJNF  := Nil
Local oMdlJNG  := Nil
Local oMdlJNO  := Nil
Local oMdlJNP  := Nil
Local oMdlJNQ  := Nil
Local nPasso   := 0
Local nPerg    := 0
Local nOpcao   := 0

JND->(dbSetOrder(1))

If JND->(dbSeek(xFilial('JND')+cCodigo+cVersao))

    oMdlChk:SetOperation(MODEL_OPERATION_VIEW)
    oMdlChk:Activate()

    oMdlForm:SetOperation(MODEL_OPERATION_INSERT)
    oMdlForm:Activate()

    oMdlForm:GetModel('JNNMASTER'):SetValue('JNN_CODJND', oMdlChk:GetValue('JNDMASTER', 'JND_CODIGO'))
    oMdlForm:GetModel('JNNMASTER'):SetValue('JNN_VERSAO', oMdlChk:GetValue('JNDMASTER', 'JND_VERSAO'))

    oMdlJNE := oMdlChk:GetModel('JNEDETAIL')
    oMdlJNO := oMdlForm:GetModel('JNODETAIL')

    For nPasso := 1 To oMdlJNE:Length()

        oMdlJNE:GoLine(nPasso)

        If !(oMdlJNO:IsEmpty())
            oMdlJNO:AddLine()
        Endif

        oMdlJNO:SetValue('JNO_CODJNE', oMdlJNE:GetValue('JNE_CODIGO'))
        oMdlJNO:SetValue('JNO_ITEM', oMdlJNE:GetValue('JNE_ITEM'))

        oMdlJNF := oMdlChk:GetModel('JNFDETAIL')
        oMdlJNP := oMdlForm:GetModel('JNPDETAIL')

        For nPerg := 1 To oMdlJNF:Length()

            oMdlJNF:GoLine(nPerg)


            If !(oMdlJNP:IsEmpty())
                oMdlJNP:AddLine()
            Endif

            oMdlJNP:SetValue('JNP_CODJNF', oMdlJNF:GetValue('JNF_CODIGO'))
            oMdlJNP:SetValue('JNP_ITEM', oMdlJNF:GetValue('JNF_ITEM'))

            oMdlJNG := oMdlChk:GetModel('JNGDETAIL')
            oMdlJNQ := oMdlForm:GetModel('JNQDETAIL')

            For nOpcao := 1 to oMdlJNG:Length()

                If !(oMdlJNQ:IsEmpty())
                    oMdlJNQ:AddLine()
                Endif

                oMdlJNQ:SetValue('JNQ_CODJNG', oMdlJNG:GetValue('JNG_CODIGO', nOpcao))

            Next

        Next

    Next

    If oMdlForm:VldData()
        oMdlForm:CommitData()
        cCodRet := oMdlForm:GetValue('JNNMASTER', 'JNN_CODIGO')
    Else 
        lRet := .F.
    Endif

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmUpdPar()
Função para criar ou atualizar os parâmetros do SIGAFSM
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmUpdPar()
Local lRet      := .T.
Local aParams   := {}
Local nX        := 0
Local oModel    := Nil

Aadd(aParams, {"MINUTOSATRASO"   , "2",  "5", "TOLERÂNCIA EM MINUTOS DE ATRASO", "Este parâmetro configura o tempo em minutos da tolerância permitido do atendimento antes do mesmo ter o status atualizado para Atrasado"})
Aadd(aParams, {"TEMPOREFRESH"    , "2", "10", "TEMPO DE ATUALIZAÇÃO DA TIMELINE DO ATENDIMENTO"  , "Este parâmetro configura o tempo em minutos para atualização da timeline"})
Aadd(aParams, {"APONTAHORAS" , "2", "5", "NUMERO DE DIAS PERMITIDO PARA APONTAMENTO DE HORAS", "Este parâmetro configura o tempo em dias para apontamento de horas"})
Aadd(aParams, {"TIPOSMIDIA" , "1", "JPG,BMP,PNG", "TIPOS DE ARQUIVO DE MÍDIA PERMITIDOS", "Este parâmetro configura o tipos de arquivo de mídias permitidos"})
Aadd(aParams, {"TAMANHOMIDIA" , "2", "1024", "TAMANHO MÁXIMO(KB) PERMITIDO PARA ARQUIVOS DE MÍDIA", "Este parâmetro configura o tamanho máximo permitido para os arquivos de mídia anexados"})
Aadd(aParams, {"URLHTTPMIDIA" , "1", "HTTP://LOCALHOST", "URL DO SERVIDOR HTTP PROTHEUS", "Este parâmetro configura a url do servidor http do protheus"})
Aadd(aParams, {"TIMELINEHORAINI" , "1", "08:00", "HORA INICIAL DA TIMELINE/CALENDARIO", "Este parâmetro configura a hora inicial a ser utilizada na timeline e calendário"})
Aadd(aParams, {"TIMELINEHORAFIM" , "1", "18:00", "HORA FINAL DA TIMELINE/CALENDARIO", "Este parâmetro configura a a hora final a ser utilizada na timeline e calendário"})
Aadd(aParams, {"LIBERAPREREQ"   , "2", "2", "Liberar pre-requisição automaticamente", "Este parâmetro configura a liberaçao automatica da Pré requisição"})
Aadd(aParams, {"SOLICITAAPROVA" , "1", "S", "ATIVA APROVACAO ESTOQUE", "Este parâmetro configura a ativação da aprovação de estoque"})
Aadd(aParams, {"VALORMINAPROVA" , "2", "10", "VALOR MINIMNO APROVACAO", "Este parâmetro configura estipula o valor minimo para requisição ao estoque"})
Aadd(aParams, {"REFRESHREQUISI" , "2", "1", "ATIVA REFRESH TELA DE ESTOQUE", "Este parâmetro ativa o refresh de tela da requisição de estoque"})
Aadd(aParams, {"TIMEREQUISICAO" , "2", "1", "TEMPO REFRESH TELA DE ESTOQUE", "Este parâmetro estipula o tempo do refresh de tela da requisição de estoque"})
Aadd(aParams, {"PERMITETRANSF" , "4", ".T.", "Habilita transf. da base de atend.", "Este parâmetro configura se permite a tranferência da base de atendimento"})

oModel := FwLoadModel("FSMA023")

JNU->(dbSetOrder(1))

For nX := 1 To Len(aParams)

    If !JNU->(dbSeek(xFilial('JNU') + PadR(aParams[nX][1], TamSx3("JNU_CODPAR")[1])))

        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()

        oModel:GetModel('JNUMASTER'):LoadValue('JNU_CODPAR', aParams[nX][1])
        oModel:GetModel('JNUMASTER'):LoadValue('JNU_TIPO'  , aParams[nX][2])
        oModel:GetModel('JNUMASTER'):LoadValue('JNU_CONTEU', aParams[nX][3])
        oModel:GetModel('JNUMASTER'):LoadValue('JNU_DESCRI', aParams[nX][4])
        oModel:GetModel('JNUMASTER'):LoadValue('JNU_OBSERV', aParams[nX][5])

        If oModel:VldData()
            oModel:CommitData()
            oModel:DeActivate()
        Endif

    Endif

Next 


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMCriaJNK()
 Retorna os eventos padroes
/*/
//-------------------------------------------------------------------
Function FSMCriaJNK()

    Local nVar      := 0
    Local aCodEven  := {} 

    aCodEven        := {{'0000000001' ,"Em atendimento"               , '01'  },;               
                        {'0000000002' ,"Em aberto"                    , '02'  },;           
                        {'0000000003' ,"Em pausa"                     , '03'  },;           
                        {'0000000004' ,"Encerrado"                    , '04'  },;       
                        {'0000000005' ,"Cancelado"                    , '05'  },;           
                        {'0000000006' ,"Em deslocamento"              , '06'   },;           
                        {'0000000007' ,"Fim do deslocamento"          , '07'   },;       
                        {'0000000008' ,"Aguardando cliente"           , '08'   },;           
                        {'0000000009' ,"Atendimento improdutivo"      , '09'   },;           
                        {'0000000010' ,"Atendimento pendente"         , '10'   },;                           
                        {'0000000011' ,"Retorno pendencia"            , '11'   },;                           
                        {'0000000012' ,"Atraso atendimento"           , '12'   }}                            
   
    DbselectArea('JNK')
    JNK->(Dbsetorder(1))

    If !(JNK->(dbSeek(xFilial('JNK')+JNK->JNK_CODIGO))) 
        For nVar := 1 to Len(aCodEven)
            RecLock('JNK',.T.)
                JNK->JNK_FILIAL    := xFilial('JNK')    
                JNK->JNK_CODIGO    := aCodEven[nVar][1]
                JNK->JNK_DESCRI    := aCodEven[nVar][2]             
                JNK->JNK_SITUAC    := aCodEven[nVar][3]                            
            JNK->(MsUnlock())                                                         
        Next nVar

    Endif    

Return
