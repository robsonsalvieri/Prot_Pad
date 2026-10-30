#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPA421G.CH"

/*/{Protheus.doc} GTPA421G()
Função que faz o estorno dos titulos de receitas/despesas da arrecação
@type function
@author flavio.martins
@since 09/09/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421G(lJob, cEmp, cFil, cAgencia, cNumFch, cCodArrec, lret)

Default lRet      := .F.
Default lJob      := .F.
Default cAgencia  := ''
Default cNumFcha  := ''
Default cCodArrec := ''

If lJob
    RpcSetType(3)
    RpcClearEnv()
    RpcSetEnv(cEmp,cFil,,,'GTP',,)
Endif

lRet := EstornaTit(lJob, cAgencia, cNumFch, cCodArrec)

Return lRet 

/*/{Protheus.doc} EstornaTit()
Estorno de títulos de receita e despesas da arrecadação
@type function
@author flavio.martins
@since 09/09/2025
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function EstornaTit(lJob, cAgencia, cNumFch, cCodArrec)
Local cAliasQry	    := GetNextAlias()
Local cFilAtu	    := cFilAnt
Local nRecno        := 0
Local aNewFlds      := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_FILTIT'}
Local lNewFlds      := GTPxVldDic('GZG', aNewFlds, .F., .T.)
Local lNewFldsGZC   := GTPxVldDic('GZC', {'GZC_NATURD', 'GZC_PREFID', 'GZC_GERTID'}, .F., .T.)
Local aDados        := {}
Local cQryAgencia   := Iif(!Empty(cAgencia),"% AND GZG.GZG_AGENCI = '"+cAgencia+"' %","%%")
Local cQryNumFch    := Iif(!Empty(cNumFch),"% AND GZG.GZG_NUMFCH = '"+cNumFch+"' %","%%")
Local lRetorno      := .T.
Local cMsgErro	    := ""
Local aTitulo       := {}
Local cPath         := GetSrvProfString("StartPath","")
Local cFile         := ""

Default cMsgTit		:= ""
Default lJob		:= .F.
Default cCodArrec   := ""

Private lMsErroAuto	:= .F.

    If !(lNewFlds) .OR. !(lNewFldsGZC)
        If lJob
            Return .F.	//FwAlertHelp(STR0001, STR0002) // "Dicionário desatualizado","Atualize o dicionário para utilizar esta rotina"
        Endif

        Return .F.
    Endif

    BeginSql Alias cAliasQry

        SELECT GZG.GZG_COD
            , GZG.GZG_SEQ
            , GZG.GZG_VALOR
            , GZG_AGENCI
            , GZG_NUMFCH
            , GZG_TIPO
            , GZG_FILTIT
            , GZG_PRETIT
            , GZG_NUMTIT
            , GZG_PARTIT
            , GZG_TIPTIT
            , GZG.R_E_C_N_O_ RECNO
            , GI6_CLIENT
            , GI6_LJCLI
            , GI6_FORNEC
            , GI6_LOJA
            , GI6_FILRES
        FROM %Table:GZG% GZG 
        INNER JOIN %Table:GI6% GI6 
            ON GI6.GI6_FILIAL = %xFilial:GI6%
            AND GI6.GI6_CODIGO = GZG.GZG_AGENCI
            AND GI6.%NotDel%
        WHERE GZG.GZG_FILIAL = %xFilial:GZG%
            AND GZG.GZG_CONFER = '2'
            %Exp:cQryAgencia%
            AND GZG.GZG_STATIT IN ('1','2')
            %Exp:cQryNumFch%
            AND GZG.%NotDel%
        ORDER BY GZG.GZG_TIPO    

    EndSql

    While (cAliasQry)->(!Eof()) 

        nRecno  := (cAliasQry)->RECNO

        If !Empty((cAliasQry)->GI6_FILRES)
            cFilAnt := (cAliasQry)->GI6_FILRES
        Endif

        GZG->(dbGoto((cAliasQry)->RECNO))

        If (cAliasQry)->GZG_TIPO == '1'

            aTitulo :=	{;
                            { "E1_FILIAL"	, (cAliasQry)->GZG_FILTIT   , Nil },; //Filial
                            { "E1_PREFIXO"	, (cAliasQry)->GZG_PRETIT   , Nil },; //Prefixo 
                            { "E1_NUM"		, (cAliasQry)->GZG_NUMTIT	, Nil },; //Numero
                            { "E1_PARCELA"	, (cAliasQry)->GZG_PARTIT	, Nil },; //Parcela
                            { "E1_TIPO"		, (cAliasQry)->GZG_TIPTIT	, Nil },; //Tipo
                            { "E1_CLIENT"	, (cAliasQry)->GI6_CLIENT	, Nil },; //Cliente
                            { "E1_LOJA"		, (cAliasQry)->GI6_LJCLI	, Nil };  //Loja
                        }

            SE1->(dbSetOrder(2))
            If SE1->(dbSeek((cAliasQry)->(GZG_FILTIT+GI6_CLIENT+GI6_LJCLI+GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT)))                                         
            
                If !Empty(SE1->E1_BAIXA)
                    MsExecAuto( { |x,y| Fina070(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
                Endif 

                If !lMsErroAuto                
                    MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 5) // 3-Inclusao,4-Alteração,5-Exclusão     
                EndIf 

            Endif

        Else

            aTitulo :=	{;
                            { "E2_PREFIXO"	, (cAliasQry)->GZG_PRETIT   , Nil },; //Prefixo 
                            { "E2_NUM"		, (cAliasQry)->GZG_NUMTIT	, Nil },; //Numero
                            { "E2_TIPO"		, (cAliasQry)->GZG_TIPTIT	, Nil },; //Tipo
                            { "E2_PARCELA"	, (cAliasQry)->GZG_PARTIT	, Nil },; //Parcela
                            { "E2_FORNECE"	, (cAliasQry)->GI6_FORNEC	, Nil },; //Fornecedor
                            { "E2_LOJA"		, (cAliasQry)->GI6_LOJA		, Nil }; //Loja
                        }

            SE2->(dbSetOrder(1))
            If SE2->(dbSeek((cAliasQry)->(GZG_FILTIT+GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT+GI6_FORNEC+GI6_LOJA)))                                        
                
                If !Empty(SE2->E2_BAIXA)
                    MsExecAuto( { |x,y| Fina080(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa
                Endif 

                If !lMsErroAuto               
                    MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)// 3-Inclusao,4-Alteração,5-Exclusão
                EndIf 

            Endif

        Endif

        If lMsErroAuto
            cMsgErro := MostraErro(cPath,cFile)

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro
            GZG->(MsUnlock())

            lRetorno := .F.
        Else 
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '0'
                GZG->GZG_FILTIT := ''
                GZG->GZG_PRETIT := ''
                GZG->GZG_NUMTIT := ''
                GZG->GZG_PARTIT := ''
                GZG->GZG_TIPTIT := ''
                GZG->GZG_MOTERR := ''

            GZG->(MsUnlock())

        EndIf 
    
        lMsErroAuto := .F.
        (cAliasQry)->(dbSkip())

    EndDo

    cFilAnt := cFilAtu

    G59->(dbSetOrder(1))

    If G59->(dbSeek(xFilial("G59")+cCodArrec))

        RecLock('G59',.F.)
            If lRetorno
                G59->G59_STATUS := .F. // Muda o novo status para 1=Aberto 
                G59->G59_STFINA := '0'   
            Else
                G59->G59_STFINA :=  '2'      
            Endif

        G59->(MsUnLock())

    Endif

    (cAliasQry)->(dbCloseArea())

    aSize(aDados,0)
    aDados := Nil

Return lRetorno
