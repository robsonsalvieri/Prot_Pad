#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'TOTVS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GtpjGerTit
Função que processa a fila de geração e/ou estorno dos títulos financeiros das receitas e despesas
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function GtpjGerTit(aParam, oMessage)
Local cQuery    := ''
Local oQryTmp   as object
Local cAliasTmp as character
Local nRecnoH8C := 0
Local lJob      := .F.
Local nTotal    := 0
Local nReg      := 0
Local lRet      := .T.
Local aFichas   := {}

Default  oMessage := Nil

If Select("SX6") == 0 // Rotina automatica (schedule)

    RPCSetType(3)
    PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "GTP"
    lJob := .T.

Endif

Private dDataAtu := dDatabase

If LockByName("GTPJGERTIT", .T., .F.) // Tenta efetuar o lock para a filial atual

    ChkMotBx("BXR") 
    ChkMotBx("BXP") 

    cQuery += " SELECT "
    cQuery += "   H8C.H8C_CODIGO, "
    cQuery += "   H8C.H8C_AGENCI, "
    cQuery += "   H8C.H8C_NUMFCH, "
    cQuery += "   H8C.H8C_SEQ, "
    cQuery += "   H8C.H8C_TIPO, "
    cQuery += "   H8C.H8C_VALOR, "
    cQuery += "   H8C.H8C_CODGZC, "
    cQuery += "   H8C.H8C_TPPROC, "
    cQuery += "   H8C.R_E_C_N_O_ RECNOH8C "
    cQuery += " FROM " + RetSqlName('H8C') + " H8C "
    cQuery += " WHERE "
    cQuery += "   H8C.H8C_FILIAL = ? "
    cQuery += "   AND H8C.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY H8C.H8C_DTINCL, H8C.H8C_HRINCL "

    cQuery := ChangeQuery(cQuery)

    oQryTmp := FwExecStatement():New(cQuery)
    oQryTmp:SetString(1, xFilial("H8C"))

    cAliasTmp := oQryTmp:OpenAlias()

    nTotal := (cAliasTmp)->(ScopeCount())
    (cAliasTmp)->(dbGoTop())    

    While (cAliasTmp)->(!Eof())
        
        nReg += 1

        If !lJob
            oMessage:SetText(I18N("Processando fila de títulos... " + AllTrim(Str(nReg)) + '/' + AllTrim(Str(nTotal))))  
            ProcessMessages()
        Endif

        nRecnoH8C := (cAliasTmp)->RECNOH8C

        If (cAliasTmp)->H8C_TPPROC == "1"

            lRet := GeraTit(nRecnoH8C)

        
        ElseIf (cAliasTmp)->H8C_TPPROC == "2"

            lRet := EstornaTit(nRecnoH8C)
        
        Endif

        H8C->(dbGoto(nRecnoH8C))

        Reclock("H8C",.F.)

        If lRet 
            H8C->(dbDelete())
        Endif

        H8C->(MsUnlock())

        If aScan(aFichas , { |x| x[1] == (cAliasTmp)->H8C_AGENCI .And. x[2] == (cAliasTmp)->H8C_NUMFCH } ) == 0
            AAdd(aFichas, { (cAliasTmp)->H8C_AGENCI, (cAliasTmp)->H8C_NUMFCH })
        Endif

        (cAliasTmp)->(dbSkip())
    EndDo

    UpdStsG59(aFichas) // Atualiza o status financeiro da arrecadação

    (cAliasTmp)->(dbCloseArea())

    FwFreeObj(oQryTmp)

    UnlockByName("GTPJGERTIT", .T., .T.) // Libera o lock após o término do processamento

Else 
    FwAlertWarning('Processo já em execução para esta filial.')
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTit(nRecnoH8C)
Função que gera os títulos financeiros das receitas e despesas
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function GeraTit(nRecnoH8C)
Local lRet       := .T.   
Local aTitulo    := {}
Local aBaixa     := {}
Local dDataTit   := Nil
Local cHistTit   := ''
Local cPath      := GetSrvProfString("StartPath","")
Local cFile      := ""
Local lBaixa     := .T.
Local cFilAmb    := cFilAnt
Local cFilRes    := ''

Local cAgencia   := ''
Local cNumFch    := ''
Local cSeq       := ''
Local cTipo      := ''
Local cCodGZC    := ''
Local cNatureza  := GPA281PAR("NATUREZA")
Local cNumTit    := ''
Local cTipoTit   := 'TF'
Local cPrefixo   := ''
Local cParcela   := Padr('1',TamSx3("E2_PARCELA")[1])
Local cCliente   := ''
Local cLojCli    := ''
Local cFornec    := ''
Local cLojFor    := ''
Local cHistBxR   := 'Baixa automatica de título de receita'
Local cHistBxD   := 'Baixa automatica de título de despesa'
Local cStatusGZG := ''
Local lIncluiH8D := .T.
    
Private lMsErroAuto := .F.

H8C->(dbGoto(nRecnoH8C))

If !Empty(H8C->H8C_CODIGO)

    cAgencia := H8C->H8C_AGENCI
    cNumFch  := H8C->H8C_NUMFCH
    cSeq     := H8C->H8C_SEQ
    cTipo    := H8C->H8C_TIPO
    cCodGZC  := H8C->H8C_CODGZC
    nValor   := H8C->H8C_VALOR

    dDataTit  := StoD(cNumFch) // Atribui a data base com a data origem do fechamento para atualizar o campo E2_EMIS com a data base do sistema.
    dDataBase := dDataTit
    cHistTit  := cCodGZC+cAgencia+cNumFch+cTipo

    dbSelectArea('GI6')
    GI6->(dbSetOrder(1))

    If GI6->(dbSeek(xFilial("GI6")+cAgencia))
        cCliente := GI6->GI6_CLIENT
        cLojCli  := GI6->GI6_LJCLI
        cFornec  := GI6->GI6_FORNEC
        cLojFor  := GI6->GI6_LOJA
        cFilRes  := GI6->GI6_FILRES
    Endif

    If cFilRes != cFilAnt 
        cFilAnt := cFilRes
    Endif

    If H8C->H8C_TIPO == '1' // Receitas  

        dbSelectArea('GZC')
        GZC->(dbSetOrder(1))

        cPrefixo := 'REC'

        If GZC->(dbSeek(xFilial("GZC")+cCodGZC))
            cPrefixo := GZC->GZC_PREFIX

            If !Empty(GZC->GZC_NATUR) 
                cNatureza := GZC->GZC_NATUR
            Endif
        Endif

        cNumTit   := GetNextNum('SE1' , cPrefixo, cParcela, cTipoTit)

        aTitulo :=	{;
                        { "E1_PREFIXO"	, cPrefixo  , Nil },; //Prefixo 
                        { "E1_NUM"		, cNumTit	, Nil },; //Numero
                        { "E1_TIPO"		, cTipoTit	, Nil },; //Tipo
                        { "E1_PARCELA"	, cParcela 	, Nil },; //Parcela
                        { "E1_NATUREZ"	, cNatureza	, Nil },; //Natureza
                        { "E1_CLIENTE"	, cCliente  , Nil },; //Cliente
                        { "E1_LOJA"		, cLojCli   , Nil },; //Loja
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
            
            dbSelectArea('H8D')
            H8D->(dbSetOrder(1))
            
            If H8D->(dbSeek(xFilial("H8D")+cAgencia+cNumFch+cSeq+cTipo))
                lIncluiH8D := .F.
            Endif

            RecLock("H8D", lIncluiH8D)

                H8D->H8D_FILIAL := xFilial("H8D")
                H8D->H8D_AGENCI := H8C->H8C_AGENCI
                H8D->H8D_NUMFCH := H8C->H8C_NUMFCH
                H8D->H8D_SEQ    := H8C->H8C_SEQ
                H8D->H8D_TIPO   := H8C->H8C_TIPO
                H8D->H8D_FILTIT := SE1->E1_FILIAL
                H8D->H8D_PRETIT := SE1->E1_PREFIXO
                H8D->H8D_NUMTIT := SE1->E1_NUM
                H8D->H8D_PARTIT := SE1->E1_PARCELA
                H8D->H8D_TIPTIT := SE1->E1_TIPO
            H8D->(MsUnlock())

            cStatusGZG := '1'
            
            UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit)
          
        Else
            lBaixa := .F.
            cMsgErro := MostraErro(cPath,cFile)        
            
            cStatusGZG := '2'

            UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)

        Endif
                            
        If lBaixa
            lMsErroAuto := .F.
            aBaixa := { {"E1_PREFIXO"	,cPrefixo 	                        ,Nil},;
                        {"E1_NUM"		,Padr(cNumTit,TamSx3("E2_NUM")[1])  ,Nil},;
                        {"E1_TIPO"		,cTipoTit	                        ,Nil},;
                        {"E1_FILIAL"	,xFilial("SE1")                     ,Nil},;
                        {"AUTMOTBX"		,"BXR"			                    ,Nil},;
                        {"AUTDTBAIXA"	,dDataTit   	                    ,Nil},;
                        {"AUTDTCREDITO"	,dDataTit    	                    ,Nil},;
                        {"AUTHIST"		,cHistBxR	 	                    ,Nil},;
                        {"AUTJUROS"		,0             	                    ,Nil,.T.},;
                        {"AUTVALREC"	,nValor     	                    ,Nil}}  
                    
            MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
                
            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)
                cMsgErro := 'Falha na baixa título: '+CRLF+cMsgErro   //'Falha na baixa título: '
                
                cStatusGZG := '2'

                UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)

            EndIf 
        EndIf                 

    ElseIf H8C->H8C_TIPO == '2' // Despesas  

        dbSelectArea('GZC')
        GZC->(dbSetOrder(1))

        cPrefixo := 'DSP'

        If GZC->(dbSeek(xFilial("GZC")+cCodGZC))
            cPrefixo := GZC->GZC_PREFID

            If !Empty(GZC->GZC_NATURD) 
                cNatureza := GZC->GZC_NATURD
            Endif
        Endif

        cNumTit := GetNextNum('SE2' , cPrefixo, cParcela, cTipoTit)
        aTitulo :=	{;
                        { "E2_PREFIXO"	, cPrefixo  , Nil },; //Prefixo 
                        { "E2_NUM"		, cNumTit	, Nil },; //Numero
                        { "E2_TIPO"		, cTipoTit	, Nil },; //Tipo
                        { "E2_PARCELA"	, cParcela  , Nil },; //Parcela
                        { "E2_NATUREZ"	, cNatureza	, Nil },; //Natureza
                        { "E2_FORNECE"	, cFornec	, Nil },; //Fornecedor
                        { "E2_LOJA"		, cLojFor   , Nil },; //Loja
                        { "E2_EMISSAO"	, dDataTit	, Nil },; //Data Emissão
                        { "E2_VENCTO"	, dDataTit	, Nil },; //Data Vencto
                        { "E2_VENCREA"	, dDataTit	, Nil },; //Data Vencimento Real
                        { "E2_MOEDA"	, 1			, Nil },; //Moeda
                        { "E2_VALOR"	, nValor    , Nil },; //Valor
                        { "E2_HIST"		, cHistTit	, Nil },; //Historico
                        { "E2_ORIGEM"	, "GTPA421D", Nil };  //Origem
                    }
                                        
        MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
            
        If !lMsErroAuto
            
            dbSelectArea('H8D')
            H8D->(dbSetOrder(1))
            
            If H8D->(dbSeek(xFilial("H8D")+cAgencia+cNumFch+cSeq+cTipo))
                lIncluiH8D := .F.
            Endif

            RecLock("H8D", lIncluiH8D)

                H8D->H8D_FILIAL := xFilial("H8D")
                H8D->H8D_AGENCI := H8C->H8C_AGENCI
                H8D->H8D_NUMFCH := H8C->H8C_NUMFCH
                H8D->H8D_SEQ    := H8C->H8C_SEQ
                H8D->H8D_TIPO   := H8C->H8C_TIPO
                H8D->H8D_FILTIT := SE2->E2_FILIAL
                H8D->H8D_PRETIT := SE2->E2_PREFIXO
                H8D->H8D_NUMTIT := SE2->E2_NUM
                H8D->H8D_PARTIT := SE2->E2_PARCELA
                H8D->H8D_TIPTIT := SE2->E2_TIPO
            H8D->(MsUnlock())

            cStatusGZG := '1'

            UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit)

        Else 
            lBaixa := .F.
            cMsgErro := MostraErro(cPath,cFile)      

            cStatusGZG := '2'

            UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)
  
        EndIf 

        If lBaixa

            aBaixa := { {"E2_PREFIXO"   ,Padr(cPrefixo,TamSx3("E2_PREFIXO")[1]) ,Nil},;
                        {"E2_NUM"		,Padr(cNumTit,TamSx3("E2_NUM")[1])      ,Nil},;
                        {"E2_PARCELA"	,cParcela                               ,Nil},;
                        {"E2_TIPO"		,Padr(cTipoTit,TamSx3("E2_TIPO")[1])    ,Nil},;
                        {"E2_FORNECE"	,Padr(cFornec,TamSx3("E2_FORNECE")[1])  ,Nil},;
                        {"E2_LOJA"		,Padr(cLojFor,TamSx3("E2_LOJA")[1])     ,Nil},;
                        {"E2_FILIAL"	,xFilial("SE2")	                        ,Nil},;
                        {"AUTMOTBX"		,"BXP"		                            ,Nil},;
                        {"AUTDTBAIXA"	,dDataTit  	                            ,Nil},;
                        {"AUTDTCREDITO"	,dDataTit  	                            ,Nil},;
                        {"AUTHIST"		,cHistBxD	                            ,Nil},;
                        {"AUTVLRPG"		,nValor                                 ,Nil},;
                        {"AUTVLRME"		,nValor                                 ,Nil};
                    }  
                    
            MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
                
            If lMsErroAuto
                cMsgErro := MostraErro(cPath,cFile)
                cMsgErro := 'Falha na baixa título: '+CRLF+cMsgErro   //'Falha na baixa título: '

                cStatusGZG := '2'

                UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)

            Endif
                
        Endif

    Endif

Endif

cFilant   := cFilAmb
dDataBase := dDataAtu

aSize(aTitulo,0)
aSize(aBaixa,0)
aTitulo := Nil
aBaixa  := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EstornaTit(nRecnoH8C)
Função que estorna os títulos financeiros das receitas e despesas
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function EstornaTit(nRecnoH8C)
Local lRet     := .T.
Local aTitulo  := {}
Local cPath    := GetSrvProfString("StartPath","")
Local cFile    := ""
Local cMsgErro := ""
Local dDataTit := Nil
Local cFilAmb  := cFilAnt
Local cFilRes  := ''
Local cParcela := Padr('1',TamSx3("E2_PARCELA")[1])
Local cCliente := ''
Local cLojCli  := ''
Local cFornec  := ''   
Local cLojFor  := ''
Local cAgencia := ''
Local cNumFch  := ''
Local cSeq     := ''
Local cTipo    := ''
Local cPrefixo := ''
Local cNumTit  := ''

Private lMsErroAuto := .F.

H8C->(dbGoto(nRecnoH8C))

If !Empty(H8C->H8C_CODIGO)

    dbSelectArea("H8D")
    H8D->(dbSetOrder(1))

    If H8D->(dbSeek(xFilial('H8D')+H8C->H8C_AGENCI+H8C->H8C_NUMFCH+H8C->H8C_SEQ+H8C->H8C_TIPO))
        
        cAgencia := H8C->H8C_AGENCI
        cNumFch  := H8C->H8C_NUMFCH
        cSeq     := H8C->H8C_SEQ
        cTipo    := H8C->H8C_TIPO
        cPrefixo := Padr(H8D->H8D_PRETIT, TamSx3("E1_PREFIXO")[1])
        cNumTit  := Padr(H8D->H8D_NUMTIT, TamSx3("E1_NUM")[1])
        cTipoTit := Padr(H8D->H8D_TIPTIT, TamSx3("E1_TIPO")[1])
        cParcela := Padr(H8D->H8D_PARTIT, TamSx3("E1_PARCELA")[1])

        dbSelectArea('GI6')
        GI6->(dbSetOrder(1))

        If GI6->(dbSeek(xFilial("GI6")+cAgencia))
            cCliente := GI6->GI6_CLIENT
            cLojCli  := GI6->GI6_LJCLI
            cFornec := GI6->GI6_FORNEC
            cLojFor := GI6->GI6_LOJA
            cFilRes := GI6->GI6_FILRES
        Endif

        If cFilRes != cFilAnt 
            cFilAnt := cFilRes
        Endif

        dDataTit  := StoD(cNumFch) // Atribui a data base com a data origem do fechamento para atualizar o campo E2_EMIS com a data base do sistema.
        dDataBase := dDataTit

        If H8C->H8C_TIPO == '1' //Receita

            aTitulo :=	{;
                            { "E1_FILIAL"	, xFilial('SE1')            , Nil },; //Filial
                            { "E1_PREFIXO"	, cPrefixo   , Nil },; //Prefixo 
                            { "E1_NUM"		, cNumTit	, Nil },; //Numero
                            { "E1_PARCELA"	, cParcela	, Nil },; //Parcela
                            { "E1_TIPO"		, cTipoTit	, Nil },; //Tipo
                            { "E1_CLIENT"	, cCliente	, Nil },; //Cliente
                            { "E1_LOJA"		, cLojCli	, Nil };  //Loja
                        }
     
            SE1->(dbSetOrder(2))
            If SE1->(dbSeek(xFilial('SE1')+cCliente+cLojCli+cPrefixo+cNumTit+cParcela+cTipoTit))        
            
                If !Empty(SE1->E1_BAIXA)
                    MsExecAuto( { |x,y| Fina070(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
                Endif 

                If lMsErroAuto
                    cMsgErro := MostraErro(cPath,cFile)

                    cStatusGZG := '2'

                    UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

                Else 
                    lMsErroAuto := .F.
                    MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 5) // 3-Inclusao,4-Alteração,5-Exclusão

                    If lMsErroAuto
                        cMsgErro := MostraErro(cPath,cFile)
                        cStatusGZG := '2'
                    Else 
                        cStatusGZG := '0'
                    EndIf 

                    UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

                    If cStatusGZG == '0'
                        DeleteH8D(cAgencia, cNumFch, cSeq, cTipo) // Exclui o registro de controle de título gerado no H8D, pois o estorno foi concluído com sucesso.
                    Endif

                EndIf 
            Else 
                cMsgErro := 'Não localizdo título ' + CRLF 
                cMsgErro += 'Filial título: ' + xFilial('SE1') + CRLF  
                cMsgErro += 'Prefixo: ' + cPrefixo + ' Número: ' + cNumTit + ' Parcela: ' + cParcela + ' Tipo: ' + cTipoTit + CRLF 
                cMsgErro += 'Cliente/Loja: ' + cCliente+'/'+cLojCli
                cMsgErro += ' para baixa.  '

                cStatusGZG := '2'
                UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

            Endif

        ElseIf H8C->H8C_TIPO == '2'  //Despesa

            lMsErroAuto := .F.
            aTitulo :=	{;
                            { "E2_PREFIXO"	, cPrefixo  , Nil },; //Prefixo 
                            { "E2_NUM"		, cNumTit	, Nil },; //Numero
                            { "E2_TIPO"		, cTipoTit	, Nil },; //Tipo
                            { "E2_PARCELA"	, cParcela	, Nil },; //Parcela
                            { "E2_FORNECE"	, cFornec   , Nil },; //Fornecedor
                            { "E2_LOJA"		, cLojFor   , Nil };  //Loja
                        }

            SE2->(dbSetOrder(1))
            If SE2->(dbSeek(xFilial('SE2')+cPrefixo+cNumTit+cParcela+cTipoTit+cFornec+cLojFor))
                
                If !Empty(SE2->E2_BAIXA)
                    MsExecAuto( { |x,y| Fina080(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
                Endif 

                If lMsErroAuto
                    cMsgErro := MostraErro(cPath,cFile)

                    cStatusGZG := '2'

                    UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

                Else 
                    lMsErroAuto := .F.
                    MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)// 3-Inclusao,4-Alteração,5-Exclusão

                    If lMsErroAuto
                        cMsgErro := MostraErro(cPath,cFile)
                        cStatusGZG := '2'
                    Else 
                        cStatusGZG := '0'
                    EndIf 

                    UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

                    If cStatusGZG == '0'
                        DeleteH8D(cAgencia, cNumFch, cSeq, cTipo) // Exclui o registro de controle de título gerado no H8D, pois o estorno foi concluído com sucesso.
                    Endif

                EndIf 
            Else 
                cMsgErro := 'Não localizdo título ' + CRLF 
                cMsgErro += 'Filial título: ' + xFilial('SE1') + CRLF  
                cMsgErro += 'Prefixo: ' + cPrefixo + ' Número: ' + cNumTit + ' Parcela: ' + cParcela + ' Tipo: ' + cTipoTit + CRLF 
                cMsgErro += 'Cliente/Loja: ' + cFornec+'/'+cLojFor
                cMsgErro += ' para baixa.  '
                
                cStatusGZG := '2'
                UpdateGZG(cStatusGZG, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro) 

            Endif
        Endif

    Endif    

Endif

cFilant   := cFilAmb
dDataBase := dDataAtu
aSize(aTitulo,0)
aTitulo := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateGZG(cStatus, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)
Função que atualiza o status dos lançamentos de receitas e despesas da ficha de remessa
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function UpdateGZG(cStatus, cAgencia, cNumFch, cSeq, cTipo, cPrefixo, cNumTit, cParcela, cTipoTit, cMsgErro)

Default cStatus  := ''
Default cAgencia := ''
Default cNumFch  := ''
Default cSeq     := ''
Default cTipo    := ''
Default cPrefixo := ''
Default cNumTit  := ''
Default cParcela := ''
Default cTipoTit := ''
Default cMsgErro := ''

If cStatus != '1'
    cPrefixo := ''
    cNumTit  := ''
    cTipoTit := ''
    cParcela := ''
Endif
  
dbSelectArea('GZG')
GZG->(dbSetOrder(1))

If GZG->(dbSeek(xFilial("GZG")+cAgencia+cNumFch+cSeq+cTipo))

    RecLock("GZG", .F.)
        GZG->GZG_STATIT := cStatus
        GZG->GZG_FILTIT := xFilial('GZG')
        GZG->GZG_PRETIT := cPrefixo
        GZG->GZG_NUMTIT := cNumTit
        GZG->GZG_PARTIT := cParcela
        GZG->GZG_TIPTIT := cTipoTit
        GZG->GZG_MOTERR := cMsgErro
    GZG->(MsUnlock())

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteH8D(cAgencia, cNumFch, cSeq, cTipo)
Função que exclui o registro de controle de título gerado no H8D
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function DeleteH8D(cAgencia, cNumFch, cSeq, cTipo)

Default cAgencia := ''
Default cNumFch  := ''
Default cSeq     := ''
Default cTipo    := ''
 
dbSelectArea('H8D')
H8D->(dbSetOrder(1))

If H8D->(dbSeek(xFilial("H8D")+cAgencia+cNumFch+cSeq+cTipo))

    RecLock("H8D", .F.)
        H8D->(dbDelete())
    H8D->(MsUnlock())

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdStsG59(aFichas)
Função que atualiza o status da arrecadação da ficha de remessa
@author flavio.martins
@since 09/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function UpdStsG59(aFichas)
Local nX     := 0
Local cQuery := ' '
Local oQryGZG   as object
Local cAliasGZG as character

For nX := 1 To Len(aFichas)

    cQuery := " SELECT "
    cQuery += "   GZG.GZG_STATIT, G59.G59_CODIGO, COUNT(GZG.GZG_COD) "
    cQuery += " FROM " + RetSqlName('GZG') + " GZG "
    cQuery += "   INNER JOIN " + RetSqlName('GZC') + " GZC ON GZC.GZC_FILIAL = ? "
    cQuery += "   AND GZC.GZC_CODIGO = GZG.GZG_COD "
    cQuery += "   AND (GZC.GZC_GERTIT = '2' OR GZC.GZC_GERTID = '2') "
    cQuery += "   AND GZC.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('G59') + " G59 ON G59.G59_FILIAL = ? "
    cQuery += "   AND G59.G59_AGENCI = GZG.GZG_AGENCI "
    cQuery += "   AND G59.G59_NUMFCH = GZG.GZG_NUMFCH "
    cQuery += "   AND G59.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery += "   GZG.GZG_FILIAL = ? "
    cQuery += "   AND GZG.GZG_AGENCI = ? "
    cQuery += "   AND GZG.GZG_NUMFCH = ? "
    cQuery += "   AND GZG.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY GZG.GZG_STATIT, G59.G59_CODIGO "
    cQuery += " ORDER BY GZG.GZG_STATIT "

    cQuery := ChangeQuery(cQuery)

    oQryGZG := FwExecStatement():New(cQuery)
    oQryGZG:SetString(1, xFilial("GZC"))
    oQryGZG:SetString(2, xFilial("G59"))
    oQryGZG:SetString(3, xFilial("GZG"))
    oQryGZG:SetString(4, aFichas[nX][1]) // Agencia
    oQryGZG:SetString(5, aFichas[nX][2]) // NumFch

    cAliasGZG := oQryGZG:OpenAlias()

    While (cAliasGZG)->(!Eof())

        If (cAliasGZG)->GZG_STATIT == '0' // Não processado
            cStaFina := '0' // Aguardando fechamento
        ElseIf (cAliasGZG)->GZG_STATIT == '1' // Titulo gerado
            cStaFina := '1' // Processado com sucesso
        ElseIf (cAliasGZG)->GZG_STATIT == '2' // Erro na geração
            cStaFina := '2' // Inconsistência na geração
        Endif

        If !Empty((cAliasGZG)->G59_CODIGO)  

            dbSelectArea('G59')
            G59->(dbSetOrder(1))

            If G59->(dbSeek(xFilial("G59")+(cAliasGZG)->G59_CODIGO))
                RecLock("G59", .F.)
                    G59->G59_STFINA := cStaFina
                G59->(MsUnlock())
            Endif
        Endif

        (cAliasGZG)->(dbSkip())

    EndDo

    (cAliasGZG)->(dbCloseArea())

Next

Return

/*{Protheus.doc} GetNextNum(cTabela, cPrefixo, cParcela, cTipo)
    Funcção de retorno de próximo número do título a receber ou a a pagar
    type    Function
    author  José Carlos
    since   22/10/2025
    param   cTabela SE1 ou SE2, 
            cPrefixo Prefixo do título, 
            cParcela Parcela , 
            cTipo Tipo do título
return  Caracter 
*/
Static Function GetNextNum(cTabela, cPrefixo, cParcela, cTipo)
    Local cNum      := ''
    Local cTitChave := ''
    
    If cTabela == 'SE1'
        SE1->(DbSetOrder(1))
        cNum      := GetSxEnum( 'SE1' , 'E1_NUM' )
        cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
        While SE1->(DbSeek(cTitChave))
            CONFIRMSX8()
            cNum:= GetSxEnum('SE1', 'E1_NUM')
            cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
        EndDo 
        CONFIRMSX8()
    ElseIf cTabela == 'SE2'
        SE2->(DbSetOrder(1))
        cNum      := GetSxEnum( 'SE2' , 'E2_NUM' )
        cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
        While SE2->(DbSeek(cTitChave))
            CONFIRMSX8()
            cNum      := GetSxEnum( 'SE2' , 'E2_NUM' )
            cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
        EndDo
        CONFIRMSX8()         
    EndIf 

Return cNum 

/*/{Protheus.doc} ChkMotBx()
Cria motivos de baixa BXP/BXR, caso não existam
@type function
@author eduardo.martinez
@since 29/01/2026
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function ChkMotBx(cMot)

Local aArea     := GetArea()
Local cAliasF7G := ''
Local cSeq      := ''

	dbSelectArea('F7G')
    F7G->(dbSetOrder(1))
        If !F7G->(dbSeek(xFilial('F7G')+cMot))
           	cAliasF7G := GetNextAlias()

            	BeginSql Alias cAliasF7G
                    SELECT MAX(F7G_SEQUEN) AS SEQ
                    FROM %Table:F7G% F7G
                    WHERE F7G.%NotDel%
	            EndSql

            cSeq := Soma1((cAliasF7G)->(SEQ))    
            
            (cAliasF7G)->(DBCloseArea())

            RecLock('F7G',.T.)
                F7G_FILIAL  := xFilial('F7G')
                F7G_SIGLA	:= cMot
                F7G_DESCRI	:= 'BAIXA GTP'
                F7G_CART	:= iif(cMot == 'BXP','P','R')
                F7G_MOVBCO	:= 'S'
                F7G_COMIS	:= 'N'
                F7G_CHEQUE	:= 'N'
                F7G_ESPEC	:= 'N'
                F7G_SEQUEN  := cSeq
			msUnLock()	
		EndIF

RestArea(aArea)

Return
