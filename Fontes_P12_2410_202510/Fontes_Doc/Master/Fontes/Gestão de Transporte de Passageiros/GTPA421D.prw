#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "GTPA421D.CH"

/*/{Protheus.doc} GTPA421D()
Função que faz a chamada para geração dos títulos POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421D(lJob, cEmp, cFil, cAgencia, cNumFch, cTipoOp, cCodArrec)
Local lRet        := Nil
Default lJob      := .F.
Default cAgencia  := ''
Default cNumFcha  := ''
Default cCodArrec := ''

If lJob
    RpcSetType(3)
    RpcClearEnv()
    RpcSetEnv(cEmp,cFil,,,'GTP',,)
Endif

lRet := GeraTit(lJob, cAgencia, cNumFch, cTipoOp, cCodArrec)

Return lRet 

/*/{Protheus.doc} GeraTit()
Geração de títulos das vendas por POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraTit(lJob, cAgencia, cNumFch, cTipoOp, cCodArrec)

Local cAliasQry	    := GetNextAlias()
Local cFilAtu	    := cFilAnt
Local nRecno        := 0
Local cStatus       := ""
Local aNewFlds      := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_FILTIT'}
Local lNewFlds      := GTPxVldDic('GZG', aNewFlds, .F., .T.)
Local lNewFldsGZC   := GTPxVldDic('GZC', {'GZC_NATURD', 'GZC_PREFID', 'GZC_GERTID'}, .F., .T.)
Local cTitulo       := ''
Local lGerTit       := .F.
Local cPrefixo      := ''
Local cNaturez      := ''
Local cQryAgencia   := Iif(!Empty(cAgencia),"% AND GZG.GZG_AGENCI = '"+cAgencia+"' %","%%")
Local cQryNumFch    := Iif(!Empty(cNumFch),"% AND GZG.GZG_NUMFCH = '"+cNumFch+"' %","%%")
Local lProc         := .T.
Local lRetorno      := .T.
Local cMsgErro	    := ""
Local cQryTipo      := ""
Default cMsgTit		:= ""
Default lJob		:= .F.
Default cCodArrec   := ""
Private lMsErroAuto	:= .F.

If !(lNewFlds) .OR. !(lNewFldsGZC)
    If !(lJob)
        FwAlertHelp(STR0001, STR0002 ) //"Dicionário desatualizado" //"Atualize o dicionário para utilizar esta rotina"
    Endif

    Return .F.
Endif

Do Case             
	Case cTipoOp = '1'
		cTitulo := STR0006 // Receita  		
        cQryTipo := " AND GZG.GZG_TIPO = '1' "           
	Case cTipoOp = '2'
		cTitulo	:= STR0007 // Despesa
        cQryTipo := " AND GZG.GZG_TIPO = '2' "
	Case cTipoOp = '3'
		cTitulo	:= "Receitas e Despesas"
        cQryTipo := " AND GZG.GZG_TIPO IN ('1','2') " 
EndCase

cQryTipo := "%"+cQryTipo+"%"

// GZG_STATIT --> 0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.
BeginSql Alias cAliasQry

    SELECT GZG.GZG_COD
        , GZG.GZG_SEQ
        , GZG.GZG_VALOR
        , GZG_AGENCI
        , GZG_NUMFCH
        , GZG_TIPO
        , GZG.R_E_C_N_O_ RECNO
        , GI6_CLIENT
        , GI6_LJCLI
        , GI6_FORNEC
        , GI6_LOJA
        , GI6_FILRES
        , GZC_TIPO
        , GZC_NATUR
        , GZC_NATURD
        , GZC_PREFIX
        , GZC_PREFID
        , GZC_GERTIT
        , GZC_GERTID
    FROM %Table:GZG% GZG 
    INNER JOIN %Table:GZC% GZC 
        ON GZC.GZC_FILIAL = %xFilial:GZC%
        AND GZC.GZC_CODIGO = GZG.GZG_COD
        AND GZC.%NotDel%
    INNER JOIN %Table:GI6% GI6 
        ON GI6.GI6_FILIAL = %xFilial:GI6%
        AND GI6.GI6_CODIGO = GZG.GZG_AGENCI
        AND GI6.%NotDel%
    WHERE GZG.GZG_FILIAL = %xFilial:GZG%
        %Exp:cQryTipo%
        AND GZG.GZG_CONFER = '2'
        %Exp:cQryAgencia%
        AND GZG.GZG_STATIT In ('0','2','3')
        %Exp:cQryNumFch%
        AND GZG.%NotDel%
    ORDER BY GZG.GZG_TIPO    

EndSql

While (cAliasQry)->(!Eof()) 

    nRecno  := (cAliasQry)->RECNO
    cStatus := "1"
    lGerTit := .F.

    GZG->(dbGoto(nRecno))
   

    If !Empty((cAliasQry)->GI6_FILRES)

        cFilAnt := (cAliasQry)->GI6_FILRES
    
        IF (cAliasQry)->GZC_GERTID == "1" .AND. (cAliasQry)->GZC_TIPO $ '2|3'
            
            lGerTit     := .T.
            cPrefixo    := (cAliasQry)->GZC_PREFID
            cNaturez    := (cAliasQry)->GZC_NATURD

        ElseIf (cAliasQry)->GZC_GERTIT == "1" .AND. (cAliasQry)->GZC_TIPO $ '1|3'

            lGerTit     := .T.
            cPrefixo    := (cAliasQry)->GZC_PREFIX
            cNaturez    := (cAliasQry)->GZC_NATUR

        EndIf

        //Só gera se tipo de documentos estiver com o campo GCZ_GERTIT igual a Sim 
        If lGerTit
                    
            If (cAliasQry)->GZG_TIPO == "1"
                If Empty((cAliasQry)->GI6_CLIENT)     // Código do cliente
                    If lJob
                        Reclock("GZG", .F.)
                            GZG->GZG_STATIT := '2'
                            GZG->GZG_MOTERR := STR0011 // //'Não informado o código do cliente no cadastro de agência.'
                        GZG->(MsUnlock())
                    Else 
                        SetLogArrDadosProc({nRecno, 2     , STR0011,'',    '',  '', '',   ''})  //'Não informado o código do cliente no cadastro de agência.'
                    Endif
                    lProc := .F.
                Else 
                    lProc:= CanTitRec(cAliasQry,lJob,cStatus, cNaturez, cPrefixo )
                EndiF                     
            Else
                If Empty((cAliasQry)->GI6_FORNEC)     // Código do Fornecedor
                    
                    If lJob
                        Reclock("GZG", .F.)
                            GZG->GZG_STATIT := '2'
                            GZG->GZG_MOTERR := STR0012 // //'Não informado o código do cliente no cadastro de agência.'
                        GZG->(MsUnlock())
                    Else 
                        SetLogArrDadosProc({nRecno, 2     , STR0012,'',    '',  '', '',   ''})  //'Não informado o código do fornecedor no cadastro de agência.'            
                    Endif
                    lProc := .F.
                Else                     
                    lProc:= CanTitDesp(cAliasQry,lJob,cStatus, cNaturez, cPrefixo )
                EndIf
            EndIf
            
            If !lProc
                lRetorno := .F.
            EndIf 
            
        Else 

            SetLogArrDadosProc({nRecno, 4, '', '', '', '', '', ''})

        Endif   

    Else     

        cMsgErro := STR0003 //'Filial responsável não informada no cadastro de agência'
                           //Recno  nAcao   Msg      Filial Pref Num Parc Tipo
        If ljob
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := STR0011 // //'Não informado o código do cliente no cadastro de agência.'
            GZG->(MsUnlock())
        Else 
            SetLogArrDadosProc({nRecno, 2     , cMsgErro,'',    '',  '', '',   ''})
        Endif          

        lRetorno := .F.
      
    EndIf
 
    (cAliasQry)->(dbSkip())

EndDo

cFilAnt := cFilAtu

(cAliasQry)->(dbCloseArea())

If lGerTit .And. !lJob .and. !isBlind() .And. !FwIsInCallStack("G500Reproc")
    If lRetorno
        FwAlertSuccess(STR0008, STR0009 + cTitulo) //"Títulos gerados com sucesso", "Geração dos Títulos de "
    Else 
        FWAlertWarning(STR0013, STR0009 + cTitulo) //'Ocorreu alguma falha na geração do título.', "Geração dos Títulos de "
    EndIf         
Endif

Return lRetorno

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitDesp()

Função para geração dos títulos de despesas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		09/12/2018
@version	P12
/*/
Static Function CanTitDesp(cAliasQry, lJob, cStatus, cNaturez, cPrefix)
Local lRet       := .T.
Local aTitulo    := {}
Local aBaixa     := {}
Local cNum       := ''
Local cHistTit   := ''
Local cTipo      := Padr('TF',TamSx3( 'E2_TIPO' )[1]) 
Local cParcela   := StrZero(1, TamSx3( 'E2_PARCELA' )[1])
Local cNatTit    := IIf(Empty(cNaturez), GPA281PAR("NATUREZA"), cNaturez) //Codigo da natureza
Local cPrefixo   := PadR(Gtpa281Prfx("DSP",cPrefix), TamSx3( 'E2_PREFIXO' )[1]) //Codigo de Prefixo
Local cHistBaixa := STR0004 //'Baixa automatica de título de despesa'
Local dDataTit   := Stod((cAliasQry)->GZG_NUMFCH)
Local cPath      := GetSrvProfString("StartPath","")
Local cFile      := ""
Local cMsgErro   := ""
Local dDtBsBkp   := dDataBase // Data base Backup
private lMsErroAuto	:= .F.

Default cStatus := "1"
    cNum	:= GetSxEnum('SE2', 'E2_NUM')

	cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  (cAliasQry)->GZG_COD + (cAliasQry)->GZG_AGENCI + (cAliasQry)->GZG_NUMFCH + (cAliasQry)->GZG_TIPO
	
	SE2->(DbSetOrder(1))
	
	If !Empty((cAliasQry)->GI6_FILRES) // GI6_FILRES
	
		cFilAnt := (cAliasQry)->GI6_FILRES
		
	Endif 

    // Atribui a data base com a data origem do fechamento para atualizar o campo E2_EMIS com a data base do sistema.
    dDataBase := dDataTit

	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED") + cNatTit ))						
	aTitulo :=	{;
					{ "E2_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E2_NUM"		, cNum						, Nil },; //Numero
					{ "E2_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E2_PARCELA"	, cParcela					, Nil },; //Parcela
					{ "E2_NATUREZ"	, cNatTit					, Nil },; //Natureza
					{ "E2_FORNECE"	, (cAliasQry)->GI6_FORNEC	, Nil },; //Fornecedor
					{ "E2_LOJA"		, (cAliasQry)->GI6_LOJA		, Nil },; //Loja
					{ "E2_EMISSAO"	, dDataTit					, Nil },; //Data Emissão
					{ "E2_VENCTO"	, dDataTit					, Nil },; //Data Vencto
					{ "E2_VENCREA"	, dDataTit					, Nil },; //Data Vencimento Real
					{ "E2_MOEDA"	, 1							, Nil },; //Moeda
					{ "E2_VALOR"	, (cAliasQry)->GZG_VALOR	, Nil },; //Valor
					{ "E2_HIST"		, cHistTit					, Nil },; //Historico
					{ "E2_ORIGEM"	, "GTPA421D"	    		, Nil };  //Origem
				}
									
	MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
		
    GZG->(dbGoto((cAliasQry)->RECNO))

	If !lMsErroAuto

        CONFIRMSX8()

        If lJob

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '1'
                GZG->GZG_FILTIT := SE2->E2_FILIAL
                GZG->GZG_PRETIT := SE2->E2_PREFIXO
                GZG->GZG_NUMTIT := SE2->E2_NUM
                GZG->GZG_PARTIT := SE2->E2_PARCELA
                GZG->GZG_TIPTIT := SE2->E2_TIPO
            GZG->(MsUnlock())
        Else
            SetLogArrDadosProc({(cAliasQry)->RECNO, 3, '', SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO})    
        Endif
						
	Else
					
		lRet := .F.
		RollbackSx8()

		If lJob
            cMsgErro := MostraErro(cPath,cFile)

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro
            GZG->(MsUnlock())

        Else
            cMsgErro := MostraErro()
             SetLogArrDadosProc({(cAliasQry)->RECNO, 2, cMsgErro,'',    '',  '', '',   ''})
        Endif

	Endif
						
	If lRet

		aBaixa := { {"E2_PREFIXO"		    ,aTitulo[1][2] 	,Nil},;
						{"E2_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E2_PARCELA"		,aTitulo[4][2] 	,Nil},;
						{"E2_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E2_FORNECE"		,aTitulo[6][2] 	,Nil},;
						{"E2_LOJA"			,aTitulo[7][2] 	,Nil},;
						{"E2_FILIAL"		,xFilial("SE2")	,Nil},;
						{"AUTMOTBX"			,"BXP"			,Nil},;
						{"AUTDTBAIXA"		,dDataTit  		,Nil},;
						{"AUTDTCREDITO"		,dDataTit  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 	,Nil},;
						{"AUTVLRPG"			,aTitulo[12][2] ,Nil},;
						{"AUTVLRME"			,aTitulo[12][2] ,Nil}}  
				
		MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto
			lRet := .F.
            cMsgErro := STR0010+CRLF //'Falha na baixa título: '

            If !lJob
				cMsgErro += MostraErro()
                SetLogArrDadosProc({(cAliasQry)->RECNO, 2, cMsgErro,'',    '',  '', '',   ''})
			Else
				cMsgErro += MostraErro(cPath,cFile)
              
                Reclock("GZG", .F.)
                    GZG->GZG_STATIT := '2'
                    GZG->GZG_MOTERR := cMsgErro
                GZG->(MsUnlock())

			EndIf

		Endif
			
	Endif
	
dDataBase := dDtBsBkp // Retorna Data base Origem
aSize(aTitulo,0)
aSize(aBaixa,0)
aTitulo := Nil
aBaixa := Nil

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitRec()

Função para geração dos títulos de receitas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		09/12/2018
@version	P12
/*/
Static Function CanTitRec(cAliasQry, lJob, cStatus, cNaturez, cPrefix)
Local lRet       := .T.
Local aTitulo    := {}
Local aBaixa     := {}
Local cNum       := ''
Local cHistTit   := ''
Local cTipo      := Padr('TF', TamSx3('E1_TIPO')[1] ) 
Local cParcela   := StrZero(1,TamSx3( 'E1_PARCELA' )[1])
Local cNatTit    := IIf(Empty(cNaturez), GPA281PAR("NATUREZA"), cNaturez) 
Local cPrefixo   := PadR(Gtpa281Prfx("REC",cPrefix), TamSx3( 'E1_PREFIXO' )[1])
Local cHistBaixa := STR0005 //'Baixa automatica de título de receita'
Local dDataTit   := Stod((cAliasQry)->GZG_NUMFCH)
Local cPath      := GetSrvProfString("StartPath","")
Local cFile      := ""
Local cMsgErro   := ""
Private lMsErroAuto	:= .F.
Default cStatus := "1"

	cNum	:= GetSxEnum('SE1', 'E1_NUM')

	cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  (cAliasQry)->GZG_COD + (cAliasQry)->GZG_AGENCI + (cAliasQry)->GZG_NUMFCH + (cAliasQry)->GZG_TIPO  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
			
	SE1->(DbSetOrder(1))
	
	If !Empty((cAliasQry)->GI6_FILRES) // GI6_FILRES
	
		cFilAnt := (cAliasQry)->GI6_FILRES
		
	Endif 

	SED->(DbSetOrder(1))		
	SED->(DbSeek(xFilial("SED") + cNatTit ))	
	aTitulo :=	{   { "E1_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
				    { "E1_NUM"		, cNum						, Nil },; //Numero
					{ "E1_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E1_PARCELA"	, cParcela					, Nil },; //Parcela
					{ "E1_NATUREZ"	, cNatTit					, Nil },; //Natureza
					{ "E1_CLIENTE"	, (cAliasQry)->GI6_CLIENT	, Nil },; //Cliente
					{ "E1_LOJA"		, (cAliasQry)->GI6_LJCLI	, Nil },; //Loja
					{ "E1_EMISSAO"	, dDataTit					, Nil },; //Data Emissão
					{ "E1_VENCTO"	, dDataTit					, Nil },; //Data Vencto
					{ "E1_VENCREA"	, dDataTit					, Nil },; //Data Vencimento Real
					{ "E1_EMIS1"	, dDataTit					, Nil },; //DT Contab.
					{ "E1_MOEDA"	, 1							, Nil },; //Moeda
					{ "E1_VALOR"	, (cAliasQry)->GZG_VALOR	, Nil },; //Valor
					{ "E1_SALDO"	, (cAliasQry)->GZG_VALOR	, Nil },; //Valor
					{ "E1_HIST"		, cHistTit					, Nil },; //Historico
					{ "E1_ORIGEM"	, "GTPA421D"				, Nil };  //Origem
				}
					
	MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
	If !lMsErroAuto
    
        CONFIRMSX8()

        If lJob

            GZG->(dbGoto((cAliasQry)->RECNO))

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '1'
                GZG->GZG_FILTIT := SE1->E1_FILIAL
                GZG->GZG_PRETIT := SE1->E1_PREFIXO
                GZG->GZG_NUMTIT := SE1->E1_NUM
                GZG->GZG_PARTIT := SE1->E1_PARCELA
                GZG->GZG_TIPTIT := SE1->E1_TIPO
            GZG->(MsUnlock())
		
        Else 
            SetLogArrDadosProc({(cAliasQry)->RECNO, 3, '', SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO})
        Endif
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If lJob
			cMsgErro := MostraErro(cPath,cFile)
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro
            GZG->(MsUnlock())
		Else
			cMsgErro := MostraErro()
            SetLogArrDadosProc({(cAliasQry)->RECNO, 2, cMsgErro,'',    '',  '', '',   ''})
		Endif

	Endif
						
	If lRet
					
		aBaixa := { {"E1_PREFIXO"	,aTitulo[1][2] 	,Nil},;
					{"E1_NUM"		,aTitulo[2][2] 	,Nil},;
					{"E1_TIPO"		,aTitulo[3][2]	,Nil},;
					{"E1_FILIAL"	,xFilial("SE1") ,Nil},;
					{"AUTMOTBX"		,"BXR"			,Nil},;
					{"AUTDTBAIXA"	,dDataTit   	,Nil},;
					{"AUTDTCREDITO"	,dDataTit    	,Nil},;
					{"AUTHIST"		,cHistBaixa	 	,Nil},;
	           		{"AUTJUROS"		,0             	,Nil,.T.},;
					{"AUTVALREC"	,aTitulo[13][2]	,Nil}}  
				
		MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto

			lRet := .F.
            cMsgErro := STR0010+CRLF+cMsgErro   //'Falha na baixa título: '

			If lJob
                cMsgErro += MostraErro(cPath,cFile)
                Reclock("GZG", .F.)
                    GZG->GZG_STATIT := '2'
                    GZG->GZG_MOTERR := cMsgErro
                GZG->(MsUnlock())

            Else
                cMsgErro += MostraErro()
                SetLogArrDadosProc({(cAliasQry)->RECNO, 2, cMsgErro,'',    '',  '', '',   ''})
            Endif

		Endif
			
	Endif

    aSize(aTitulo,0)
    aSize(aBaixa,0)
    aTitulo := Nil
    aSize   := Nil

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Gtpa281Prfx()

Função para selecionar o prefixo do titulo

@sample	Gtpa281Prfx() 
@return	cPrefixRet
 
@author	kaique.olivero
@since		27/10/2023
/*/
//-----------------------------------------------------------------------------------------
Static Function Gtpa281Prfx(cPreFx,cPreFxGZC)
    Local cPrefixRet := cPreFx
    If !Empty(cPreFxGZC)
        cPrefixRet := cPreFxGZC
    Endif
Return cPrefixRet
