#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015C.CH'

/*/{Protheus.doc} GTPU015C
(long_description)
@type  Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU015C(cCodCaixa)
Local lRet   := .T.
Local oModel := Nil

Private lMsErroAuto := .F.

dbSelectArea('H7P')
H7P->(dbSetOrder(1))

If H7P->(dbSeek(xFilial('H7P')+cCodCaixa))

    oModel := FwLoadModel('GTPU015')
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    If oModel:GetModel('H7QRECEITA'):Length() > 0
        lRet := GerTitRec(oModel)
    Endif

    If lRet .And. oModel:GetModel('H7QDESPESA'):Length() > 0 
        lRet := GerTitDes(oModel)
    Endif

    If lRet .And. oModel:VldData()
        FwFormCommit(oModel)
    Endif

    oModel:DeActivate()
    oModel:Destroy()

Endif

Return lRet

/*/{Protheus.doc} GerTitRec(oMdl)
Função que gera os títulos das receitas do caixa do urbano
@type Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0
/*/
Static Function GerTitRec(oModel)
Local lRet      := .T.
Local aAreaH7O  := GetArea()
Local aAreaH7M  := GetArea()
Local nX        := 0
Local cCodLocal := oModel:GetValue('H7PMASTER', 'H7P_CODH7M')
Local cCodCaixa := oModel:GetValue('H7PMASTER', 'H7P_CODIGO')
Local cPrefixo  := ''
Local cNatureza := ''
Local cCodCli   := ''
Local cLojCli   := ''
Local cNumTit   := ''
Local cTipo     := 'TF'
Local nValor    := 0
Local cParcela  := StrZero(1,TamSx3('E1_PARCELA')[1])
Local aTitSE1   := {}

H7M->(dbSetOrder(1))

If H7M->(dbSeek(xFilial('H7M')+cCodLocal))

    cCodcli := H7M->H7M_CODCLI 
    cLojCli := H7M->H7M_LOJCLI

Endif

If Empty(cCodcli) .Or. Empty(cLojCli)
    lRet := .F.
    FwAlertHelp(STR0001, STR0002) // "Cliente não informado no local de arrecadação", "Cadastre o cliente antes de gerar os títulos"
    Return lRet
Endif

H7O->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)

    If H7O->(dbSeek(xFilial('H7O')+oModel:GetValue('H7QRECEITA', 'H7Q_CODH7O'))) .And.;
        H7O->H7O_GERTIT == '1'

        cPrefixo  := H7O->H7O_PREREC
        cNatureza := H7O->H7O_NATREC

        nValor := oModel:GetValue('H7QRECEITA', 'H7Q_VALOR')

        cNumTit := GtpTitNum('SE1', cPrefixo, cParcela, cTipo)

        aTitSE1 := {{ "E1_PREFIXO"	, cPrefixo  		   , Nil },; //Prefixo 
                    { "E1_NUM"		, cNumTit	    	   , Nil },; //Numero
                    { "E1_PARCELA"	, cParcela 		       , Nil },; //Parcela
                    { "E1_TIPO"		, cTipo			       , Nil },; //Tipo
                    { "E1_NATUREZ"	, cNatureza		       , Nil },; //Natureza
                    { "E1_CLIENTE"	, cCodCli		       , Nil },; //Cliente
                    { "E1_LOJA"		, cLojCli 		       , Nil },; //Loja
                    { "E1_EMISSAO"	, dDataBase	           , Nil },; //Data Emissão
                    { "E1_VENCTO"	, dDataBase 	       , Nil },; //Data Vencimento
                    { "E1_VENCREA"	, dDataBase 	       , Nil },; //Data Vencimento Real
                    { "E1_VALOR"	, nValor	    	   , Nil },; //Valor
                    { "E1_SALDO"	, nValor	           , Nil },; //Saldo
                    { "E1_HIST"		, cCodCaixa            , Nil },; //HIstórico
                    { "E1_ORIGEM"	, "GTPU015C"	       , Nil }}  //Origem
        
        dbSelectArea("SE1")
        SE1->(dbSetOrder(1))

        If !SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNumTit+cParcela+cTipo))

            MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 3)  // 3 - Inclusao

            If lMsErroAuto
                MostraErro()
                RollbackSx8()
                lRet := .F.
            Else 

                If H7O->H7O_BXATIT == '1'
                    lRet := BaixTitRec(aTitSE1, cCodCaixa)
                Endif

                If lRet 

                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_FILTIT', xFilial('SE1'))
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_PRETIT', cPrefixo)
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_NUMTIT', cNumTit)
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_PARTIT', cParcela)
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_TIPTIT', cTipo)
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_CLIFOR', cCodCli)
                    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_LOJTIT', cLojCli)

                Endif

            Endif
        Else
            FwAlertWarning(STR0003, STR0004) // "Número do título encontra-se em duplicidade no financeiro", "A geração dos títulos será canceladda"
            lRet := .F.
        EndIf    

    Endif

Next

RestArea(aAreaH7O)
RestArea(aAreaH7M)

Return lRet

/*/{Protheus.doc} BaixTitRec(aTitulo, cCodCaixa)
Função que baixa os títulos das receitas do caixa do urbano
@type Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0
/*/
Static Function BaixTitRec(aTitulo, cCodCaixa)
Local lRet   := .T.
Local aBaixa := {}

aBaixa := { {"E1_PREFIXO"	,aTitulo[1][2] 	,Nil},;
            {"E1_NUM"		,aTitulo[2][2] 	,Nil},;
            {"E1_TIPO"		,aTitulo[3][2]	,Nil},;
            {"E1_FILIAL"	,xFilial("SE1") ,Nil},;
            {"AUTMOTBX"		,"NOR"			,Nil},;
            {"AUTDTBAIXA"	,dDataBase	    ,Nil},;
            {"AUTDTCREDITO"	,dDataBase	    ,Nil},;
            {"AUTHIST"		,STR0005+cCodCaixa, Nil},; // "Bx tit. no fechamento do Caixa: "
            {"AUTJUROS"		,0             	,Nil,.T.},;
            {"AUTVALREC"	,aTitulo[12][2]	,Nil}}  
        
MsExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	

If lMsErroAuto
    lRet := .F.
    cMsgErro := MostraErro()
Endif

Return lRet

/*/{Protheus.doc} GerTitDes(oMdl)
Função que gera os títulos das despesas do caixa do urbano
@type Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0
/*/
Static Function GerTitDes(oModel)
Local lRet      := .T.
Local aAreaH7O  := GetArea()
Local aAreaH7M  := GetArea()
Local nX        := 0
Local cCodLocal := oModel:GetValue('H7PMASTER', 'H7P_CODH7M')
Local cCodCaixa := oModel:GetValue('H7PMASTER', 'H7P_CODIGO')
Local cPrefixo  := ''
Local cNatureza := ''
Local cCodFor   := ''
Local cLojFor   := ''
Local cBanco    := ''
Local cAgencia  := ''
Local cConta    := ''
Local cNumTit   := ''
Local cTipo     := 'TF '
Local nValor    := 0
Local cParcela  := StrZero(1,TamSx3('E2_PARCELA')[1])
Local aTitSE2   := {}

H7M->(dbSetOrder(1))

If H7M->(dbSeek(xFilial('H7M')+cCodLocal))

    cCodFor  := H7M->H7M_CODFOR 
    cLojFor  := H7M->H7M_LOJFOR
    cBanco   := H7M->H7M_BANCO
    cAgencia := H7M->H7M_AGENCI
    cConta   := H7M->H7M_CONTA

Endif

If Empty(cCodFor) .Or. Empty(cLojFor)
    lRet := .F.
    FwAlertHelp(STR0006, STR0007) // "Fornecedor não informado no local de arrecadação", "Cadastre o fornecedor antes de gerar os títulos"
    Return lRet
Endif

If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
    lRet := .F.
    FwAlertHelp(STR0008, STR0009) // "Conta bancária não informada no local de arrecadação", "Cadastre as informações bancárias antes de gerar os títulos"
    Return lRet
Endif

H7O->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H7QDESPESA'):Length()

    oModel:GetModel('H7QDESPESA'):GoLine(nX)

    If H7O->(dbSeek(xFilial('H7O')+oModel:GetValue('H7QDESPESA', 'H7Q_CODH7O'))) .And.;
        H7O->H7O_GERTIT == '1'

        cPrefixo  := H7O->H7O_PREDES
        cNatureza := H7O->H7O_NATDES
        nValor    := oModel:GetValue('H7QDESPESA', 'H7Q_VALOR')
        cNumTit   := GtpTitNum('SE2', cPrefixo, cParcela, cTipo)

        aTitSE2 := {{ "E2_PREFIXO"	, cPrefixo  		   , Nil },; //Prefixo 
                    { "E2_NUM"		, cNumTit	    	   , Nil },; //Numero
                    { "E2_TIPO"		, cTipo			       , Nil },; //Tipo
                    { "E2_PARCELA"	, cParcela 		       , Nil },; //Parcela
                    { "E2_NATUREZ"	, cNatureza		       , Nil },; //Natureza
                    { "E2_FORNECE"	, cCodFor		       , Nil },; //Cliente
                    { "E2_LOJA"		, cLojFor 		       , Nil },; //Loja
                    { "E2_EMISSAO"	, dDataBase	           , Nil },; //Data Emissão
                    { "E2_VENCTO"	, dDataBase 	       , Nil },; //Data Vencimento
                    { "E2_VENCREA"	, dDataBase 	       , Nil },; //Data Vencimento Real
                    { "E2_MOEDA"	, 1     	    	   , Nil },; //Moeda
                    { "E2_VALOR"	, nValor	    	   , Nil },; //Valor
                    { "E2_SALDO"	, nValor	           , Nil },; //Saldo
                    { "E2_HIST"		, cCodCaixa            , Nil },; //HIstórico
                    { "E2_ORIGEM"	, "GTPU015C"	       , Nil }}  //Origem
        
        dbSelectArea("SE2")
        SE2->(dbSetOrder(1))

        If !SE2->(dbSeek(xFilial("SE2")+cPrefixo+cNumTit+cParcela+cTipo))

            MsExecAuto( { |x,y| FINA050(x,y)} , aTitSE2, 3)  // 3 - Inclusao

            If lMsErroAuto
                MostraErro()
                RollbackSx8()
                lRet := .F.
            Else 

                If H7O->H7O_BXATIT == '1'
                    lRet := BaixTitDes(aTitSE2, cCodCaixa)
                Endif

                If lRet 

                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_FILTIT', xFilial('SE1'))
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_PRETIT', cPrefixo)
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_NUMTIT', cNumTit)
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_PARTIT', cParcela)
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_TIPTIT', cTipo)
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_CLIFOR', cCodFor)
                    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_LOJTIT', cLojFor)

                Endif

            Endif
        Else
            FwAlertWarning(STR0003, STR0004) // "Número do título encontra-se em duplicidade no financeiro", "A geração dos títulos será cancelada"
            lRet := .F.
        EndIf    

    Endif

Next

RestArea(aAreaH7O)
RestArea(aAreaH7M)

Return lRet

/*/{Protheus.doc} BaixTitDes(aTitulo, cCodCaixa)
Função que baixa os títulos das despesas do caixa do urbano
@type Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0
/*/
Static Function BaixTitDes(aTitulo, cCodCaixa)
Local lRet   := .T.
Local aBaixa := {}
Local cChave := ''

cChave := xFilial("SE2")+aTitulo[1][2]+aTitulo[2][2]+aTitulo[4][2]+aTitulo[3][2]+aTitulo[6][2]+aTitulo[7][2]

dbSelectArea("SE2")
SE2->(DbSetOrder(1))
					
If SE2->(dbSeek(cChave))

    aBaixa := { {"E2_PREFIXO"	,aTitulo[1][2] 	,Nil},;
                {"E2_NUM"		,aTitulo[2][2] 	,Nil},;
                {"E2_PARCELA"	,aTitulo[4][2]	,Nil},;
                {"E2_TIPO"		,aTitulo[3][2]	,Nil},;
                {"E2_FORNECE"	,aTitulo[6][2]	,Nil},;
                {"E2_LOJA"		,aTitulo[7][2]	,Nil},;
                {"E2_FILIAL"	,xFilial("SE2") ,Nil},;
                {"AUTBANCO"	    ,'GTP'          ,Nil},;
                {"AUTAGENCIA"	,'00001'        ,Nil},;
                {"AUTCONTA"	    ,'0000001   '   ,Nil},;
                {"AUTMOTBX"		,"NOR"			,Nil},;
                {"AUTDTBAIXA"	,dDataBase	    ,Nil},;
                {"AUTDTCREDITO"	,dDataBase	    ,Nil},;
                {"AUTHIST"		,STR0005+cCodCaixa, Nil},; // "Bx tit. no fechamento do Caixa: "
                {"AUTVLRPG"		,aTitulo[12][2]	,Nil,.T.},;
                {"AUTVLRME"	    ,aTitulo[12][2]	,Nil}}  
            
    MsExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	

    If lMsErroAuto
        lRet := .F.
        cMsgErro := MostraErro()
    Endif

Endif

Return lRet
