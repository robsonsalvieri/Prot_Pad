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

If ExisteSX2("H86")
    DBSelectArea("H86")
    H86->(DBSetOrder(1)) //H86_FILIAL+H86_CODH7O+H86_TIPLIN
Endif

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

    If lRet .And. oModel:GetModel('H81DEPOSITO'):Length() > 0 
        lRet := GerTitDeposito(oModel)
    Endif

    If lRet .And. oModel:VldData()
        FwFormCommit(oModel)
    Endif

    oModel:DeActivate()
    oModel:Destroy()

Endif

If Select("H86")
    H86->(DBCloseArea())
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
Local cTRecNat  := ''
Local cPrefixo  := ''
Local cNatureza := ''
Local cCodCli   := ''
Local cLojCli   := ''
Local cNumTit   := ''
Local cTipo     := 'TF'
Local nValor    := 0
Local cParcela  := StrZero(1,TamSx3('E1_PARCELA')[1])
Local aTitSE1   := {}
Local cBancoH7M := ''
Local cAgencH7M := ''
Local cContaH7M := ''
Local cBanco    := ''
Local cAgencia  := ''
Local cConta    := ''
Local cMotBaixa := AllTrim(GTPGetRules("MOTBAIXARE",,,"NOR"))
Local cMotivo   := ''
Local dDtFecham := oModel:GetValue('H7PMASTER', 'H7P_DTFECH')
Local dDtSystem := dDataBase
H7M->(dbSetOrder(1))

If H7M->(dbSeek(xFilial('H7M')+cCodLocal))

    cCodcli   := H7M->H7M_CODCLI 
    cLojCli   := H7M->H7M_LOJCLI
    cBancoH7M := H7M->H7M_BANCO
    cAgencH7M := H7M->H7M_AGENCI
    cContaH7M := H7M->H7M_CONTA  

Endif

If Empty(cCodcli) .Or. Empty(cLojCli)
    lRet := .F.
    FwAlertHelp(STR0001, STR0002) // "Cliente não informado no local de arrecadação", "Cadastre o cliente antes de gerar os títulos"
    Return lRet
Endif

If dDataBase <> dDtFecham
    dDataBase := dDtFecham
EndIf 

H7O->(dbSetOrder(1))


For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)

    If oModel:GetValue('H7QRECEITA', 'H7Q_CONFER') == '2' .And. H7O->(dbSeek(xFilial('H7O')+oModel:GetValue('H7QRECEITA', 'H7Q_CODH7O'))) .And.;
        H7O->H7O_GERTIT == '1'

        cPrefixo  := H7O->H7O_PREREC
        cNatureza := H7O->H7O_NATREC
        
        If ExisteSX2("H86") .AND. H86->(DBSeek(xFilial("H86") + H7O->H7O_CODIGO + oModel:GetValue('H7QRECEITA', 'H7Q_TPLINH') ))
            cPrefixo  := H86->H86_PREREC
            cNatureza := H86->H86_NATREC
        Endif

        If !Empty(oModel:GetValue('H7QRECEITA', 'H7Q_CODBCO'))
            cBanco   := oModel:GetValue('H7QRECEITA','H7Q_CODBCO')
            cAgencia := oModel:GetValue('H7QRECEITA','H7Q_AGEBCO')
            cConta   := oModel:GetValue('H7QRECEITA','H7Q_CTABCO')
            cMotivo  := cMotBaixa
        Else
            cBanco    := cBancoH7M
            cAgencia  := cAgencH7M
            cConta    := cContaH7M
            cMotivo   := cMotBaixa
        Endif
        cTRecNat  :=  ":" + oModel:GetValue('H7QRECEITA', 'H7Q_CODH7O')  + "-" + oModel:GetValue('H7QRECEITA', 'H7Q_DSCH7O') 

        nValor := oModel:GetValue('H7QRECEITA', 'H7Q_VALOR')

        cNumTit := GtpTitNum('SE1', cPrefixo, cParcela, cTipo)

        aTitSE1 := {{ "E1_PREFIXO"	, cPrefixo  		   , Nil },; //Prefixo 
                    { "E1_NUM"		, cNumTit	    	   , Nil },; //Numero
                    { "E1_PARCELA"	, cParcela 		       , Nil },; //Parcela
                    { "E1_TIPO"		, cTipo			       , Nil },; //Tipo
                    { "E1_NATUREZ"	, cNatureza		       , Nil },; //Natureza
                    { "E1_CLIENTE"	, cCodCli		       , Nil },; //Cliente
                    { "E1_LOJA"		, cLojCli 		       , Nil },; //Loja
                    { "E1_EMISSAO"	, dDtFecham	           , Nil },; //Data Emissão
                    { "E1_VENCTO"	, dDtFecham 	       , Nil },; //Data Vencimento
                    { "E1_VENCREA"	, dDtFecham 	       , Nil },; //Data Vencimento Real
                    { "E1_VALOR"	, nValor	    	   , Nil },; //Valor
                    { "E1_SALDO"	, nValor	           , Nil },; //Saldo
                    { "E1_HIST"		, cCodCaixa + cTRecNat , Nil },; //HIstórico
                    { "E1_ORIGEM"	, "GTPU015C"	       , Nil }} //Origem

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
                    lRet := BaixTitRec(aTitSE1, cCodCaixa, cBanco, cAgencia, cConta, cMotivo,dDtFecham)
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

If dDataBase <> dDtSystem
    dDataBase := dDtSystem
EndIf 
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
Static Function BaixTitRec(aTitulo, cCodCaixa,cBanco, cAgencia, cConta, cMotBaixa, dDataBx)
Local lRet      := .T.
Local aBaixa    := {}
Default dDataBx := dDataBase
aBaixa := { {"E1_PREFIXO"	,aTitulo[1][2] 	,Nil},;
            {"E1_NUM"		,aTitulo[2][2] 	,Nil},;
            {"E1_TIPO"		,aTitulo[3][2]	,Nil},;
            {"E1_FILIAL"	,xFilial("SE1") ,Nil},;
            {"AUTBANCO"	    ,cBanco         ,Nil},;
            {"AUTAGENCIA"	,cAgencia       ,Nil},;
            {"AUTCONTA"	    ,cConta         ,Nil},;
            {"AUTMOTBX"		,cMotBaixa		,Nil},;
            {"AUTDTBAIXA"	,dDataBx	    ,Nil},;
            {"AUTDTCREDITO"	,dDataBx	    ,Nil},;
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
Local cBancoH7M := ''
Local cAgencH7M := ''
Local cContaH7M := ''
Local cMotBaixa := AllTrim(GTPGetRules("MOTBAIXA",,,"NOR"))
Local cMotivo   := ''
Local dDtFecham := oModel:GetValue('H7PMASTER', 'H7P_DTFECH')
Local dDtSystem := dDataBase
H7M->(dbSetOrder(1))

If H7M->(dbSeek(xFilial('H7M')+cCodLocal))

    cCodFor   := H7M->H7M_CODFOR 
    cLojFor   := H7M->H7M_LOJFOR
    cBancoH7M := H7M->H7M_BANCO
    cAgencH7M := H7M->H7M_AGENCI
    cContaH7M := H7M->H7M_CONTA    

Endif

If Empty(cCodFor) .Or. Empty(cLojFor)
    lRet := .F.
    FwAlertHelp(STR0006, STR0007) // "Fornecedor não informado no local de arrecadação", "Cadastre o fornecedor antes de gerar os títulos"
    Return lRet
Endif

If dDataBase <> dDtFecham
    dDataBase := dDtFecham
EndIf 

H7O->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H7QDESPESA'):Length()

    oModel:GetModel('H7QDESPESA'):GoLine(nX)

    If oModel:GetValue('H7QDESPESA', 'H7Q_CONFER') == '2' .And. H7O->(dbSeek(xFilial('H7O')+oModel:GetValue('H7QDESPESA', 'H7Q_CODH7O'))) .And.;
        H7O->H7O_GERTIT == '1'

        cPrefixo  := H7O->H7O_PREDES
        cNatureza := H7O->H7O_NATDES

        If ExisteSX2("H86") .AND. H86->(DBSeek( xFilial("H86") + H7O->H7O_CODIGO + oModel:GetValue('H7QDESPESA', 'H7Q_TPLINH') ))
            cPrefixo  := H86->H86_PREDES
            cNatureza := H86->H86_NATDES
        Endif

        If !Empty(oModel:GetValue('H7QDESPESA', 'H7Q_CODBCO'))
            cBanco   := oModel:GetValue('H7QDESPESA','H7Q_CODBCO')
            cAgencia := oModel:GetValue('H7QDESPESA','H7Q_AGEBCO')
            cConta   := oModel:GetValue('H7QDESPESA','H7Q_CTABCO')     
            cMotivo  := cMotBaixa    
        Else
            cBanco    := cBancoH7M
            cAgencia  := cAgencH7M
            cConta    := cContaH7M
            cMotivo   := cMotBaixa    
        Endif

        If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
            lRet := .F.
            FwAlertHelp(STR0008, STR0009) // "Conta bancária não informada no local de arrecadação", "Cadastre as informações bancárias antes de gerar os títulos"
            Exit
        Endif

        cTRecNat  :=  ":" + oModel:GetValue('H7QDESPESA','H7Q_CODH7O')  + "-" + oModel:GetValue('H7QDESPESA','H7Q_DSCH7O') 
        nValor    := oModel:GetValue('H7QDESPESA','H7Q_VALOR')
        cNumTit   := GtpTitNum('SE2', cPrefixo, cParcela, cTipo)

        aTitSE2 := {{ "E2_PREFIXO"	, cPrefixo  		   , Nil },; //Prefixo 
                    { "E2_NUM"		, cNumTit	    	   , Nil },; //Numero
                    { "E2_TIPO"		, cTipo			       , Nil },; //Tipo
                    { "E2_PARCELA"	, cParcela 		       , Nil },; //Parcela
                    { "E2_NATUREZ"	, cNatureza		       , Nil },; //Natureza
                    { "E2_FORNECE"	, cCodFor		       , Nil },; //Cliente
                    { "E2_LOJA"		, cLojFor 		       , Nil },; //Loja
                    { "E2_EMISSAO"	, dDtFecham	           , Nil },; //Data Emissão
                    { "E2_VENCTO"	, dDtFecham 	       , Nil },; //Data Vencimento
                    { "E2_VENCREA"	, dDtFecham 	       , Nil },; //Data Vencimento Real
                    { "E2_MOEDA"	, 1     	    	   , Nil },; //Moeda
                    { "E2_VALOR"	, nValor	    	   , Nil },; //Valor
                    { "E2_SALDO"	, nValor	           , Nil },; //Saldo
                    { "E2_HIST"		, cCodCaixa + cTRecNat , Nil },; //HIstórico
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
                    lRet := BaixTitDes(aTitSE2, cCodCaixa, cBanco, cAgencia, cConta, cMotivo, dDtFecham)
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

If dDataBase <> dDtSystem
    dDataBase := dDtSystem
EndIf 
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
Static Function BaixTitDes(aTitulo, cCodCaixa, cBanco, cAgencia, cConta, cMotBaixa, dDtFecham)
Local lRet      := .T.
Local aBaixa    := {}
Local cChave    := ''

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
                {"AUTBANCO"	    ,cBanco         ,Nil},;
                {"AUTAGENCIA"	,cAgencia       ,Nil},;
                {"AUTCONTA"	    ,cConta         ,Nil},;
                {"AUTMOTBX"		,cMotBaixa		,Nil},;
                {"AUTDTBAIXA"	,dDtFecham	    ,Nil},;
                {"AUTDTCREDITO"	,dDtFecham	    ,Nil},;
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

/*/{Protheus.doc} GerTitDeposito(oMdl)
Função que gera os títulos deposito do caixa do urbano
@type Static Function
@author flavio.martins
@since 20/06/2024
@version 1.0
/*/
Static Function GerTitDeposito(oModel)
Local lRet          := .T.
Local aAreaH7O      := GetArea()
Local aAreaH7M      := GetArea()
Local nX            := 0
Local cCodLocal     := oModel:GetValue('H7PMASTER', 'H7P_CODH7M')
Local cCodCaixa     := oModel:GetValue('H7PMASTER', 'H7P_CODIGO')
Local cHistDep      := AllTrim(GTPGetRules("HISTDEPOSI",,,""))
Local cPrefixo      := AllTrim(GTPGetRules("PRFTITDEPO"))
Local cPrefixoE     := AllTrim(GTPGetRules("PRFTITESTO"))
Local lBaixa        := GTPGetRules("HABBXDEPOS")
Local lBaixaE       := GTPGetRules("HABBXESTOR")
Local cCodCli       := ''
Local cLojCli       := ''
Local cCodFor       := ''
Local cLojFor       := ''
Local cNumTit       := ''
Local cTipo         := 'TF'
Local nValor        := 0
Local cParcela      := StrZero(1,TamSx3('E1_PARCELA')[1])
Local cParcelaE     := StrZero(1,TamSx3('E2_PARCELA')[1])
Local aTitSE1       := {}
Local cBanco        := ''
Local cAgencia      := ''
Local cConta        := ''
Local cBancoH7M     := ''
Local cAgenciaH7M   := ''
Local cContaH7M     := ''
Local cMotBaixa     := AllTrim(GTPGetRules("MOTVBXDEPO",,,"NOR"))
Local cMotBaixaE    := AllTrim(GTPGetRules("MOTVBXESTO",,,"NOR"))
Local cNatureza     := AllTrim(GTPGetRules("NATDEPOSIT"))
Local cNaturezaE    := AllTrim(GTPGetRules("NATESTORNO"))
Local dDataBx       := Ctod('//') 
Local dDtSystem     := dDataBase
Local dDtFecham     := oModel:GetValue('H7PMASTER', 'H7P_DTFECH')
Local lEstorno      := .F.
Local cHistTit      := ''
Local lAtuHist      := GTPGetRules("HABREPROH",,,.F.)
Local cComentario   := ''

H7M->(dbSetOrder(1))

If H7M->(dbSeek(xFilial('H7M')+cCodLocal))

    cCodCli     := H7M->H7M_CODCLI 
    cLojCli     := H7M->H7M_LOJCLI
    cCodFor     := H7M->H7M_CODFOR 
    cLojFor     := H7M->H7M_LOJFOR
    cBancoH7M   := H7M->H7M_BANCO
    cAgenciaH7M := H7M->H7M_AGENCI
    cContaH7M   := H7M->H7M_CONTA

Endif

For nX := 1 To oModel:GetModel('H81DEPOSITO'):Length()

    oModel:GetModel('H81DEPOSITO'):GoLine(nX)

    nValor      := oModel:GetValue( 'H81DEPOSITO' , 'H81_VLRDEP' )
    lEstorno    := oModel:GetValue( 'H81DEPOSITO' , 'H81_TPMOV' ) == '2'
    cComentario := oModel:GetValue( 'H81DEPOSITO' , 'H81_COMENT' )

    If nValor > 0

        If lAtuHist .And. !Empty(cComentario)
            cHistTit := Left( cCodCaixa + ": " + cComentario,Iif(!lEstorno,TamSx3('E1_HIST')[1],TamSx3('E2_HIST')[1]))
        Else 
            cHistTit  := Left(cCodCaixa + ": " + cHistDep,Iif(!lEstorno,TamSx3('E1_HIST')[1],TamSx3('E2_HIST')[1]))
        EndIf 

        cBanco    := oModel:GetValue('H81DEPOSITO', 'H81_CODBCO')
        cAgencia  := oModel:GetValue('H81DEPOSITO', 'H81_AGEBCO')
        cConta    := oModel:GetValue('H81DEPOSITO', 'H81_CTABCO')
        If Empty(cBanco) .OR. Empty(cAgencia) .OR. Empty(cConta)
            cBanco   := cBancoH7M
            cAgencia := cAgenciaH7M
            cConta   := cContaH7M
        Endif
        dDataBx   := Iif( !Empty(oModel:GetValue('H81DEPOSITO', 'H81_DTDEPO')),oModel:GetValue('H81DEPOSITO', 'H81_DTDEPO'),dDtFecham )
        If !lEstorno           
            cNumTit := GtpTitNum('SE1', cPrefixo, cParcela, cTipo)
        Else 
            cNumTit := GtpTitNum('SE2', cPrefixoE, cParcelaE, cTipo)    
        Endif

        If dDataBase <> dDtFecham
            dDataBase := dDtFecham
        EndIf 

        If !lEstorno
            aTitSE1 := {{ "E1_PREFIXO"	, cPrefixo  		   , Nil },; //Prefixo 
                        { "E1_NUM"		, cNumTit	    	   , Nil },; //Numero
                        { "E1_PARCELA"	, cParcela 		       , Nil },; //Parcela
                        { "E1_TIPO"		, cTipo                , Nil },; //Tipo
                        { "E1_NATUREZ"	, cNatureza		       , Nil },; //Natureza
                        { "E1_CLIENTE"	, cCodCli		       , Nil },; //Cliente
                        { "E1_LOJA"		, cLojCli 		       , Nil },; //Loja
                        { "E1_EMISSAO"	, dDataBase	           , Nil },; //Data Emissão
                        { "E1_VENCTO"	, dDataBase	           , Nil },; //Data Vencimento
                        { "E1_VENCREA"	, dDataBase   	       , Nil },; //Data Vencimento Real
                        { "E1_VALOR"	, nValor	    	   , Nil },; //Valor
                        { "E1_SALDO"	, nValor	           , Nil },; //Saldo
                        { "E1_HIST"		, cHistTit             , Nil },; //HIstórico
                        { "E1_ORIGEM"	, "GTPU015C"	       , Nil }}  //Origem

            dbSelectArea("SE1")
            SE1->(dbSetOrder(1))

            MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 3)  // 3 - Inclusao

        Else

            aTitSE1 := {{ "E2_PREFIXO"	, cPrefixoE  		   , Nil },; //Prefixo 
                        { "E2_NUM"		, cNumTit	    	   , Nil },; //Numero
                        { "E2_TIPO"		, Padr(cTipo,3)	       , Nil },; //Tipo
                        { "E2_PARCELA"	, cParcelaE		       , Nil },; //Parcela                        
                        { "E2_NATUREZ"	, cNaturezaE	       , Nil },; //Natureza
                        { "E2_FORNECE"	, cCodFor		       , Nil },; //Fornecedor
                        { "E2_LOJA"		, cLojFor 		       , Nil },; //Loja
                        { "E2_EMISSAO"	, dDataBase	           , Nil },; //Data Emissão
                        { "E2_VENCTO"	, dDataBase	           , Nil },; //Data Vencimento
                        { "E2_VENCREA"	, dDataBase   	       , Nil },; //Data Vencimento Real
                        { "E2_VALOR"	, nValor	    	   , Nil },; //Valor
                        { "E2_SALDO"	, nValor	           , Nil },; //Saldo
                        { "E2_HIST"		, cHistTit             , Nil },; //HIstórico
                        { "E2_ORIGEM"	, "GTPU015C"	       , Nil }}  //Origem

            dbSelectArea("SE2")
            SE2->(dbSetOrder(1))

            MsExecAuto( { |x,y| FINA050(x,y)} , aTitSE1, 3)  // 3 - Inclusao

        Endif

        If lMsErroAuto
            MostraErro()
            RollbackSx8()
            lRet := .F.
        Else 

            If !lEstorno .AND. lBaixa
                If !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta)
                    dDataBase := dDataBx
                    lRet := BaixTitRec(aTitSE1, cCodCaixa, cBanco, cAgencia, cConta, cMotBaixa, dDataBx)
                Else 
                    lRet := .F.
                    FwAlertHelp(STR0008, STR0009) // "Conta bancária não informada no local de arrecadação", "Cadastre as informações bancárias antes de gerar os títulos"
                EndIf 

            ElseIf lEstorno .AND. lBaixaE

                If !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta)
                    dDataBase := dDataBx
                    lRet := BaixTitDes(aTitSE1, cCodCaixa, cBanco, cAgencia, cConta, cMotBaixaE, dDataBx)
                Else 
                    lRet := .F.
                    FwAlertHelp(STR0008, STR0009) // "Conta bancária não informada no local de arrecadação", "Cadastre as informações bancárias antes de gerar os títulos"
                EndIf   

            EndIf 

            If !lEstorno .AND. lRet 

                oModel:GetModel('H81DEPOSITO'):SetValue('H81_FILTIT', xFilial('SE1'))
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_PRETIT', cPrefixo)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_NUMTIT', cNumTit)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_PARTIT', cParcela)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_TIPTIT', cTipo)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_CLIFOR', cCodCli)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_LOJTIT', cLojCli)
            
            ElseIf lEstorno .AND. lRet 

                oModel:GetModel('H81DEPOSITO'):SetValue('H81_FILTIT', xFilial('SE2'))
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_PRETIT', cPrefixoE)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_NUMTIT', cNumTit)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_PARTIT', cParcelaE)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_TIPTIT', cTipo)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_CLIFOR', cCodFor)
                oModel:GetModel('H81DEPOSITO'):SetValue('H81_LOJTIT', cLojFor)

            Endif

        Endif

    EndIf 

Next

If dDtSystem <> dDataBase
    dDataBase := dDtSystem
EndIf 

RestArea(aAreaH7O)
RestArea(aAreaH7M)

Return lRet
