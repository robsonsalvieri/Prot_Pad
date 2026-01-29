#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPA421D.CH'

/*/{Protheus.doc} GTPA421D()
Função Geração dos títulos a Receber ou a Pagar
@type function
@author jose.darocha
@since 22/10/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421D(cAcao,nPosGZG,cPrefixo,cNum,cParcela,cTipo,cCodCliFor,cLjCliFor,cGerTit,cNatTit,cFilTit)
    If cAcao == 'INCLUI'
        GeraTitulo(nPosGZG,cPrefixo,cNum,cParcela,cTipo,cCodCliFor,cLjCliFor,cGerTit,cNatTit,cFilTit)
    ElseIf cAcao == 'ESTORNO'
        EstornoTitulo(nPosGZG,cCodCliFor,cLjCliFor)                    
    EndIf 
Return

/*/{Protheus.doc} GeraTitulo()
Inclusão dos títulos a Receber ou a Pagar
@type function
@author jose.darocha
@since 22/10/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraTitulo(nPosGZG,cPrefixo,cNum,cParcela,cTipo,cCodCliFor,cLjCliFor,cGerTit,cNatTit,cFilTit)
    Local aTitulo       := {}
    Local aBaixa        := {}
    Local dDataTit      := NiL
    Local cHistTit      := ''
    Local cPath         := GetSrvProfString("StartPath","")
    Local cFile         := ""
    Local nValor        := 0
    Local lBaixa        := .T.
    Local cHistBxR      := STR0005  //'Baixa automatica de título de receita'
    Local cHistBxD      := STR0004  //'Baixa automatica de título de despesa'
    Local dDtBsBkp      := dDataBase // Data base Backup
    Local cFilSys       := cFilAnt
    
    Private lMsErroAuto := .F.

    SetModulo("SIGAGTP", "GTP")

    If !Empty(cFilTit)
        cFilAnt := cFilTit
    EndIF 

    GZG->(DbGoTo(nPosGZG))

    If cGerTit == '2'
        RecLock("GZG",.F.)
            GZG->GZG_STATIT:= '3'
        GZG->(MsUnlock())
    ElseIf GZG->GZG_TIPO $ '2|3'    // Despesas  
        dDataTit := Stod(GZG->GZG_NUMFCH)
        // Atribui a data base com a data origem do fechamento para atualizar o campo E2_EMIS com a data base do sistema.
        dDataBase := dDataTit
        cHistTit  := GZG->(GZG_COD+GZG_AGENCI+GZG_NUMFCH+GZG_TIPO)
        nValor    := GZG->GZG_VALOR 
        aTitulo :=	{;
                        { "E2_PREFIXO"	, cPrefixo  , Nil },; //Prefixo 
                        { "E2_NUM"		, cNum		, Nil },; //Numero
                        { "E2_TIPO"		, cTipo		, Nil },; //Tipo
                        { "E2_PARCELA"	, cParcela	, Nil },; //Parcela
                        { "E2_NATUREZ"	, cNatTit	, Nil },; //Natureza
                        { "E2_FORNECE"	, cCodCliFor, Nil },; //Fornecedor
                        { "E2_LOJA"		, cLjCliFor , Nil },; //Loja
                        { "E2_EMISSAO"	, dDataTit	, Nil },; //Data Emissão
                        { "E2_VENCTO"	, dDataTit	, Nil },; //Data Vencto
                        { "E2_VENCREA"	, dDataTit	, Nil },; //Data Vencimento Real
                        { "E2_MOEDA"	, 1			, Nil },; //Moeda
                        { "E2_VALOR"	, nValor    , Nil },; //Valor
                        { "E2_HIST"		, cHistTit	, Nil },; //Historico
                        { "E2_ORIGEM"	, "GTPA421D", Nil };  //Origem
                    }
                                        
        MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
            
        //GZG_STATIT 0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.                                
        If !lMsErroAuto
            RecLock("GZG",.F.)
                GZG->GZG_STATIT:= '1'
                GZG->GZG_FILTIT:= xFilial("SE2")
                GZG->GZG_PRETIT:= cPrefixo
                GZG->GZG_NUMTIT:= cNum
                GZG->GZG_PARTIT:= cParcela
                GZG->GZG_TIPTIT:= cTipo
                GZG->GZG_MOTERR:= ''
            GZG->(MsUnlock())
        Else 
            lBaixa := .F.
            cMsgErro := MostraErro(cPath,cFile)        
            RecLock("GZG",.F.)
                GZG->GZG_STATIT:= '2'
                GZG->GZG_FILTIT:= ''
                GZG->GZG_PRETIT:= ''
                GZG->GZG_NUMTIT:= ''
                GZG->GZG_PARTIT:= ''
                GZG->GZG_TIPTIT:= ''
                GZG->GZG_MOTERR:= cMsgErro
            GZG->(MsUnlock())
        EndIF 

        If lBaixa

            aBaixa := { {"E2_PREFIXO"   ,cPrefixo 	,Nil},;
                        {"E2_NUM"		,cNum 	    ,Nil},;
                        {"E2_PARCELA"	,cParcela 	,Nil},;
                        {"E2_TIPO"		,cTipo	    ,Nil},;
                        {"E2_FORNECE"	,cCodCliFor ,Nil},;
                        {"E2_LOJA"		,cLjCliFor 	,Nil},;
                        {"E2_FILIAL"	,xFilial("SE2")	,Nil},;
                        {"AUTMOTBX"		,"BXP"		,Nil},;
                        {"AUTDTBAIXA"	,dDataTit  	,Nil},;
                        {"AUTDTCREDITO"	,dDataTit  	,Nil},;
                        {"AUTHIST"		,cHistBxD	,Nil},;
                        {"AUTVLRPG"		,nValor     ,Nil},;
                        {"AUTVLRME"		,nValor     ,Nil};
                    }  
                    
            MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
                
            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)
                cMsgErro := STR0010+CRLF+cMsgErro   //'Falha na baixa título: '
                RecLock("GZG",.F.)
                    GZG->GZG_STATIT:= '2'
                    GZG->GZG_MOTERR:= cMsgErro
                GZG->(MsUnlock())
            Endif
                
        Endif
    ElseIf GZG->GZG_TIPO $ '1|3'    // Receitas  
        dDataTit := Stod(GZG->GZG_NUMFCH)
        // Atribui a data base com a data origem do fechamento para atualizar o campo E2_EMIS com a data base do sistema.
        dDataBase := dDataTit
        cHistTit  := GZG->(GZG_COD+GZG_AGENCI+GZG_NUMFCH+GZG_TIPO)
        nValor    := GZG->GZG_VALOR 
        aTitulo :=	{;
                        { "E1_PREFIXO"	, cPrefixo  , Nil },; //Prefixo 
                        { "E1_NUM"		, cNum		, Nil },; //Numero
                        { "E1_TIPO"		, cTipo		, Nil },; //Tipo
                        { "E1_PARCELA"	, cParcela	, Nil },; //Parcela
                        { "E1_NATUREZ"	, cNatTit	, Nil },; //Natureza
                        { "E1_CLIENTE"	, cCodCliFor, Nil },; //Cliente
                        { "E1_LOJA"		, cLjCliFor , Nil },; //Loja
                        { "E1_EMISSAO"	, dDataTit	, Nil },; //Data Emissão
                        { "E1_VENCTO"	, dDataTit	, Nil },; //Data Vencto
                        { "E1_VENCREA"	, dDataTit	, Nil },; //Data Vencimento Real
                        { "E1_EMIS1"	, dDataTit	, Nil },; //DT Contab.
                        { "E1_MOEDA"	, 1			, Nil },; //Moeda
                        { "E1_VALOR"	, nValor	, Nil },; //Valor
                        { "E1_SALDO"	, nValor    , Nil },; //Valor
                        { "E1_HIST"		, cHistTit	, Nil },; //Historico
                        { "E1_ORIGEM"	, "GTPA421D", Nil };  //Origem
                    }
                        
        MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
        
        If !lMsErroAuto
            RecLock("GZG",.F.)
                GZG->GZG_STATIT:= '1'
                GZG->GZG_FILTIT:= SE1->E1_FILIAL
                GZG->GZG_PRETIT:= SE1->E1_PREFIXO
                GZG->GZG_NUMTIT:= SE1->E1_NUM
                GZG->GZG_PARTIT:= SE1->E1_PARCELA
                GZG->GZG_TIPTIT:= SE1->E1_TIPO
                GZG->GZG_MOTERR:= ''
            GZG->(MsUnlock())
        Else
            lBaixa := .F.
            cMsgErro := MostraErro(cPath,cFile)        
            RecLock("GZG",.F.)
                GZG->GZG_STATIT:= '2'
                GZG->GZG_FILTIT:= ''
                GZG->GZG_PRETIT:= ''
                GZG->GZG_NUMTIT:= ''
                GZG->GZG_PARTIT:= ''
                GZG->GZG_TIPTIT:= ''
                GZG->GZG_MOTERR:= cMsgErro
            GZG->(MsUnlock())
        Endif
                            
        If lBaixa
            lMsErroAuto := .F.
            aBaixa := { {"E1_PREFIXO"	,cPrefixo 	    ,Nil},;
                        {"E1_NUM"		,cNum 	        ,Nil},;
                        {"E1_TIPO"		,cTipo	        ,Nil},;
                        {"E1_FILIAL"	,xFilial("SE1") ,Nil},;
                        {"AUTMOTBX"		,"BXR"			,Nil},;
                        {"AUTDTBAIXA"	,dDataTit   	,Nil},;
                        {"AUTDTCREDITO"	,dDataTit    	,Nil},;
                        {"AUTHIST"		,cHistBxR	 	,Nil},;
                        {"AUTJUROS"		,0             	,Nil,.T.},;
                        {"AUTVALREC"	,nValor     	,Nil}}  
                    
            MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
                
            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)
                cMsgErro := STR0010+CRLF+cMsgErro   //'Falha na baixa título: '
                RecLock("GZG",.F.)
                    GZG->GZG_STATIT:= '2'
                    GZG->GZG_MOTERR:= cMsgErro
                GZG->(MsUnlock())
            EndIf 
        EndIf                 

    EndIF 

    dDataBase := dDtBsBkp // Retorna Data base Origem
    aSize(aTitulo,0)
    aSize(aBaixa,0)
    aTitulo := Nil
    aBaixa  := Nil
    cFilAnt := cFilSys
Return

/*/{Protheus.doc} EstornoTitulo()
Estorno dos títulos a Receber ou a Pagar
@type function
@author jose.darocha
@since 22/10/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function EstornoTitulo(nPosGZG,cCodCliFor,cLjCliFor)
    Local aTitulo       := {}
    Local cPath         := GetSrvProfString("StartPath","")
    Local cFile         := ""
    Local cMsgErro      := ""

    Private lMsErroAuto := .F.

    SetModulo("SIGAGTP", "GTP")
    
    GZG->(dbGoto(nPosGZG))

    If  GZG->GZG_STATIT == '3'    //0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.
        InitRegs()      
    ElseIf GZG->GZG_TIPO == '1' //Receita

        aTitulo :=	{;
                        { "E1_FILIAL"	, GZG->GZG_FILTIT   , Nil },; //Filial
                        { "E1_PREFIXO"	, GZG->GZG_PRETIT   , Nil },; //Prefixo 
                        { "E1_NUM"		, GZG->GZG_NUMTIT	, Nil },; //Numero
                        { "E1_PARCELA"	, GZG->GZG_PARTIT	, Nil },; //Parcela
                        { "E1_TIPO"		, GZG->GZG_TIPTIT	, Nil },; //Tipo
                        { "E1_CLIENT"	, cCodCliFor	        , Nil },; //Cliente
                        { "E1_LOJA"		, cLjCliFor	        , Nil };  //Loja
                    }

        SE1->(dbSetOrder(2))
        If SE1->(dbSeek(GZG->GZG_FILTIT+cCodCliFor+cLjCliFor+GZG->(GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT)))                                         
        
            If !Empty(SE1->E1_BAIXA)
                MsExecAuto( { |x,y| Fina070(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
            Endif 

            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)

                Reclock("GZG", .F.)
                    GZG->GZG_STATIT := '2'
                    GZG->GZG_MOTERR := STR0014+CRLF+cMsgErro    //'Exclusão de baixa:'
                GZG->(MsUnlock())
            Else 
                lMsErroAuto := .F.
                MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 5) // 3-Inclusao,4-Alteração,5-Exclusão

                If lMsErroAuto
                    cMsgErro := MostraErro(cPath,cFile)

                    Reclock("GZG", .F.)
                        GZG->GZG_STATIT := '2'
                        GZG->GZG_MOTERR := STR0014+CRLF+cMsgErro  //'Exclusão de baixa:'
                    GZG->(MsUnlock())
                Else 
                    InitRegs()
                EndIf 
            EndIf 
        Else 
            cMsgErro := STR0016 + CRLF      //'Não localizdo título '
            cMsgErro += STR0017 + GZG->GZG_FILTIT + CRLF   //'Filial título: '
            cMsgErro += STR0018 + GZG->GZG_PRETIT + STR0019 + GZG->GZG_NUMTIT + STR0020 + GZG->GZG_PARTIT + STR0021 + GZG->GZG_TIPTIT + CRLF //'Prefixo: ' ' Número: ' ' Parcela: ' ' Tipo: '
            cMsgErro += STR0022 + cCodCliFor+'/'+cLjCliFor //'Cliente/Loja: '
            cMsgErro += STR0023  //' para baixa.'
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro 
            GZG->(MsUnlock())                      
        Endif
    ElseIf  GZG->GZG_TIPO == '2'  //Despesa
        lMsErroAuto := .f.
        aTitulo :=	{;
                        { "E2_PREFIXO"	, GZG->GZG_PRETIT   , Nil },; //Prefixo 
                        { "E2_NUM"		, GZG->GZG_NUMTIT	, Nil },; //Numero
                        { "E2_TIPO"		, GZG->GZG_TIPTIT	, Nil },; //Tipo
                        { "E2_PARCELA"	, GZG->GZG_PARTIT	, Nil },; //Parcela
                        { "E2_FORNECE"	, cCodCliFor        , Nil },; //Fornecedor
                        { "E2_LOJA"		, cLjCliFor		    , Nil };  //Loja
                    }

        SE2->(dbSetOrder(1))
        If SE2->(dbSeek( GZG->(GZG_FILTIT+GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT)+cCodCliFor+cLjCliFor))
            
            If !Empty(SE2->E2_BAIXA)
                MsExecAuto( { |x,y| Fina080(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
            Endif 

            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)

                Reclock("GZG", .F.)
                    GZG->GZG_STATIT := '2'
                    GZG->GZG_MOTERR := STR0014+CRLF+cMsgErro   //'Exclusão de baixa:'
                GZG->(MsUnlock())
            Else 
                lMsErroAuto := .F.
                MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)// 3-Inclusao,4-Alteração,5-Exclusão

                If lMsErroAuto
                    cMsgErro := MostraErro(cPath,cFile)

                    Reclock("GZG", .F.)
                        GZG->GZG_STATIT := '2'
                        GZG->GZG_MOTERR := STR0015+CRLF+cMsgErro  //'Exclusão do título:'
                    GZG->(MsUnlock())
                Else 
                    InitRegs()
                EndIf 
            EndIf 
        Else 
            cMsgErro := STR0016 + CRLF  //'Não localizdo título '
            cMsgErro += STR0017 + GZG->GZG_FILTIT + CRLF
            cMsgErro += STR0018 + GZG->GZG_PRETIT + STR0019 + GZG->GZG_NUMTIT + STR0020 + GZG->GZG_PARTIT + STR0021 + GZG->GZG_TIPTIT + CRLF //'Prefixo: ' ' Número: ' ' Parcela: ' ' Tipo: '
            cMsgErro += STR0024 + cCodCliFor+'/'+cLjCliFor  //'Fornecedor/Loja: '
            cMsgErro += STR0023 //' para baixa.' 
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro 
            GZG->(MsUnlock())                      
        Endif
    Endif

    aSize(aTitulo,0)
    aTitulo := Nil
Return


/*/{Protheus.doc} InitRegs()
Atualiza status e limpa dados do título
@type function
@author jose.darocha
@since 22/10/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function InitRegs()
    Reclock("GZG", .F.)
        GZG->GZG_STATIT := '0'
        GZG->GZG_FILTIT := ''
        GZG->GZG_PRETIT := ''
        GZG->GZG_NUMTIT := ''
        GZG->GZG_PARTIT := ''
        GZG->GZG_TIPTIT := ''
        GZG->GZG_MOTERR := ''
    GZG->(MsUnlock())
Return 
