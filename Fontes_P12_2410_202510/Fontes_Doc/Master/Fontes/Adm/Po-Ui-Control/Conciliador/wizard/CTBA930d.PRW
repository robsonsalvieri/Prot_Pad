#Include "CTBA930D.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"

Static __oQryCT2
Static __jChvKey
Static __jCpoVlr
Static __jIdGrvd
Static __lPostgres
/*{Protheus.doc} PopUUID
Cria o SDF para inclusão dos capos UUID

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function CTBA930d()
Local aSM0		:= {}
Local aHeader   := {}
Local aCols930d 	:= {}
Local lWizFinal := .F.
Local lBack     := .F.
Local cMens		:=	STR0001+CRLF+; //"Essa rotina fará o preenchimento dos campos CV3_IDORIG e CV3_IDDEST para utilização na rotina de conciliação. "
					STR0002+CRLF+; //"Informe o intervalo de datas para gravar o conteúdo dos campos de ID criados anteriormente. "
					STR0003+; //"Atenção - Informe apenas o período que realmente deseja utilizar no conciliador. "
					STR0004 //"O tempo de processamento é proporcional ao tamanho do período escolhido."
Local lVldDic := .F.
Private oWizard
Private lContinua  := .T.
Private lCriouSDF  := .F.
Private cListTab   := ""
Private dDatAte    := Date()
Private dDatDe	   := FirstDay(MonthSub(dDatAte,1))

Rptstatus({|| lVldDic := C930IniDad(aHeader,aCols930d,aSM0) },STR0005, STR0006 ) //"Aguarde..." //"Preparando os dados para o wizard..."

If lVldDic
    //Painel 1 - Tela inicial do Wizard
    oWizard := APWizard():New(STR0007/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
    STR0008/*<chMsg>*/, ""/*<cTitle>*/, ; //"Preenchimento dos campos CV3_IDORIG e CV3_IDDEST"
    cMens, ;
    {|| !Empty(dDatDe) .And. !Empty(dDatAte)} /*<bNext>*/ ,;
    {||.T.}/*<bFinish>*/,;
    .T./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

    //Painel 2 - Definição das Novas Entidades
    oWizard:NewPanel(STR0007/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
    STR0008/*<chMsg>*/,; //"Preenchimento dos campos CV3_IDORIG e CV3_IDDEST"
    {||lBack := .T.}/*<bBack>*/,;
    {||.F.} /*<bNext>*/ ,;
    {|| lWizFinal := C930VldSel(aCols930d)}/*<bFinish>*/,;
    .T./*<.lPanel.>*/ ,;
    {|| aCols930d := IIf(lBack, aCols930d, C930MARK(aHeader,aCols930d,aSM0))}/*<bExecute>*/) //Montagem da tela

    oWizard:Activate( .T./*<.lCenter.>*/,;
    {|| .T.}/*<bValid>*/,;
    {|| C930GetDat()}/*<bInit>*/,;
    {||.T.}/*<bWhen>*/)

    If lWizFinal
        If MsgYesNo(STR0012 +; //"A funcionalidade de preenchimento do rastreamento contábil é um facilitador para a conciliação dos registros de legado do ambiente. "
            STR0013 + CRLF + CRLF +; //"O processo de rastreamento é feito conforme o Tracker Contábil se baseando nos campos de RECNO dos registros gravados na tabela CV3 (CV3_RECORI para o registro de origem e CV3_RECDES para o lançamento contábil). "
            STR0014 + CRLF + CRLF +; //"Para o correto preenchimento do rastreamento contábil na tabela CV3 é imprescindível a integridade dos campos de RECNO das tabelas selecionadas para que seja possível relacionar o registro de origem e destino e o preenchimento dos campos CV3_IDORIG e CV3_IDDEST seja feito de maneira correta. "
            STR0015 , STR0016) //"Deseja continuar?" // "Atenção!"
                WizGrvCV3(aCols930d,aSM0)
        EndIf
        FreeObj(__oQryCT2)
    EndIf
EndIf

Return .T.

/*{Protheus.doc} WizGrvCV3
Grava campos ID na tabela CV3

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGrvCV3(aCols,aSM0)
Local nI := 1
Local aSelFil := {}
Local cAlias := ""

DEFAULT aCols := {}
DEFAULT aSM0 := {}

For nI := 1 to Len(aCols)
	If aCols[nI,1]
		If Len(aSelFil) == 0
			aEval(aSM0,{|x| IIf(x[1]==cEmpAnt,aAdd(aSelFil,x[2]),)})
		EndIf
		If cEmpAnt <> Left(aCols[nI,2],2)
			If (nPos := aScan(aSM0,{|x| x[1]==Left(aCols[nI,2],2)})) > 0
				C930SelEmp(aSM0[nPos,1],aSM0[nPos,2])
				aSelFil := {}
				aEval(aSM0,{|x| IIf(x[1]==cEmpAnt,aAdd(aSelFil,x[2]),)})
			EndIf
		EndIf

		cAlias := Left(aCols[nI,3],3)
		Rptstatus({|| WizProcEmp(cAlias, aCols[nI,4], aSelFil) },STR0010, STR0009+cAlias+" - "+aCols[nI,2]) 			 //"Gravando: " //"Aguarde"
	EndIf
Next

C930MsgBox(STR0011) //"Processo de atualização finalizado"

Return .T.

/*/{Protheus.doc} WizProcEmp
Função para leitura dos registros que serão processados.

@Author	TOTVS
@since	27/04/2021
/*/
Static Function WizProcEmp(cAlias, cCpoUUID, aSelFil)
Local cAliasQry := GetNextAlias()
Local cOrdem    := ""
Local cSequen   := ""
Local cTipDC    := ""
Local cDebito   := ""
Local cCredit   := ""
Local cCustoD   := ""
Local cCustoC   := ""
Local cItemD    := ""
Local cItemC    := ""
Local cClassD   := ""
Local cClassC   := ""
Local cRecOri   := ""
Local cRecdes   := ""
Local cKeyCV3   := ""
Local cCodUUID  := ""
Local nVlrReg   := 0
Local nRecCounts:= 0
Local lContinua := .F.
Local dDtSeq    := StoD("")
Local aChaves   := {}
Local cCT2FldUID := CtbCpoUID("CT2")

__jIdGrvd := NIL
__jIdGrvd := JsonObject():New()

If __lPostgres == NIL
    __lPostgres := AllTrim(Upper(TcGetDb())) $ "POSTGRES"
EndIf

WizRetQry(cAlias, aSelFil, @cAliasQry)

If !(cAliasQry)->(Eof())

    //Count to nRecCounts
    //(cAliasQry)->(dbGoTop())
    SetRegua(nRecCounts)

    While !(cAliasQry)->(Eof())

        //Se mudou o documento eu zero a variável jagrav
        If DtoS((cAliasQry)->CV3_DTSEQ) <> DtoS(dDtSeq) .Or.;
            (cAliasQry)->CV3_SEQUEN <> cSequen
            cLinJaGrav := ""
        EndIf

        cFilCV3 := (cAliasQry)->CV3_FILIAL
        dDtSeq  := (cAliasQry)->CV3_DTSEQ
        cSequen := (cAliasQry)->CV3_SEQUEN
        cTipDC  := (cAliasQry)->CV3_DC
        cDebito := (cAliasQry)->CV3_DEBITO
        cCredit := (cAliasQry)->CV3_CREDIT
        cCustoD := (cAliasQry)->CV3_CCD
        cCustoC := (cAliasQry)->CV3_CCC
        cItemD  := (cAliasQry)->CV3_ITEMD
        cItemC  := (cAliasQry)->CV3_ITEMC
        cClassD := (cAliasQry)->CV3_CLVLDB
        cClassC := (cAliasQry)->CV3_CLVLCR
        cRecOri := (cAliasQry)->CV3_RECORI
        cRecdes := (cAliasQry)->CV3_RECDES
        cKeyCV3 := (cAliasQry)->CV3_KEY
        aChaves := {}
        nVlrReg := 0
        cCodUUID := ""
        lContinua := .T.

        //Laço em todos os CV3 com o mesmo RECDES (mesmo registro CT2)
        While !(cAliasQry)->(Eof()) .And. (cAliasQry)->CV3_FILIAL == cFilCV3 .And.;
            DtoS((cAliasQry)->CV3_DTSEQ) == DtoS(dDtSeq) .And.;
            (cAliasQry)->CV3_SEQUEN == cSequen .And. (cAliasQry)->CV3_RECDES == cRecdes

            lContinua := .F.
            cRecOri := (cAliasQry)->CV3_RECORI

            &(cAlias+"->(dbSetOrder("+cOrdem+"))")
            &(cAlias+"->(dbGoTo("+cRecOri+"))")

            If !&(cAlias)->(Eof()) .And. &(cAlias)->(Recno())==Val(cRecOri)
                lContinua := .T.

                cCodUUID := &(cAlias+"->("+cCpoUUID+")")
                aAdd(aChaves,{(cAliasQry)->REC,cCodUUID})
            EndIf

            If !lContinua
                //Se não achou a origem, não gravo CV3
                Exit
            EndIf

			IncRegua()
            (cAliasQry)->(dbSkip())
        EndDo

        If !lContinua .Or. (cAliasQry)->CV3_RECDES == cRecdes
            (cAliasQry)->(dbSkip())
            Loop
        EndIf

        CT2->(dbGoTo(Val(cRecdes)))
        If !CT2->(Eof()) .And. !CT2->(Deleted())    //Se conseguir posicionar no registro e não estiver deletado, seguir para gravar o rastreamento
            WizSetCV3(aChaves, &("CT2->("+cCT2FldUID+")"))
        EndIF

    EndDo

    (cAliasQry)->(dbCloseArea())
    TcDelFile(cAliasQry)

    //Após o uso da tabela desposiciono para evitar erros de match
    (cAlias)->(dbGoTo(0))
EndIf

Return

/*/{Protheus.doc} WizRetQry
Filtra os dados da CV3 para gravação dos ID's

@Author	TOTVS
@since	27/04/2021
/*/
Static Function WizRetQry(cAlias, aSelFil, cAliasQry)
Local cQuery  := ""
Local cTmpFil := ""

DEFAULT cAlias := ""
DEFAULT aSelFil := {}
DEFAULT cAliasQry := ""

cQuery :=   " SELECT CV3_FILIAL, CV3_DTSEQ, CV3_SEQUEN, CV3_LP, CV3_LPSEQ, CV3_KEY, CV3_DC, CV3_DEBITO, CV3_CREDIT, "+;
            " CV3_CCD, CV3_CCC, CV3_ITEMD, CV3_ITEMC, CV3_CLVLDB, CV3_CLVLCR, CV3_VLR01, "+;
            " CV3_RECORI, CV3_RECDES, R_E_C_N_O_ REC "+;
	        " FROM 	"+RetSQLName("CV3")+;
		    " WHERE CV3_FILIAL "+GetRngFil(aSelfil,"CV3",.T.,@cTmpFil)+" AND "+;
			" CV3_DTSEQ BETWEEN '"+DtoS(dDatDe)+"' AND '"+DtoS(dDatAte)+"' AND "+;
			" CV3_DC <> '4' AND "+;
            " CV3_TABORI = '"+cAlias+"' AND "+;
            " (CV3_IDORIG = ' ' OR CV3_IDDEST = ' ' )  AND "+;
            " CV3_RECDES <> ' '  AND "+;
			" D_E_L_E_T_ = ' ' "+;
            " ORDER BY CV3_FILIAL, CV3_DTSEQ, CV3_SEQUEN, CV3_RECDES, R_E_C_N_O_ "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .F.)
TcSetField(cAliasQry,"CV3_DTSEQ","D",8,0)
CtbTmpErase(cTmpFil)

Return

/*/{Protheus.doc} WizSetCV3
Faz a atualização da tabela CV3 com a chave encontrada

@Author	TOTVS
@since	27/04/2021
/*/
Static Function WizSetCV3(aChaves, cCT2UUID)
Local aArea := GetArea()
Local nI    := 0

DEFAULT aChaves := {}
DEFAULT cCT2UUID := ""

If !Empty(cCT2UUID) // Não gravar em caso de código UUID vazio na origem ou destino
    For nI := 1 to Len(aChaves)
        If !Empty(aChaves[nI,2])  // Não gravar em caso de código UUID vazio na origem ou destino
            CV3->(dbGoTo(aChaves[nI,1]))
            RecLock("CV3",.F.)
                If Empty(CV3->CV3_IDORIG)
                    CV3->CV3_IDORIG := IIf(__lPostgres,Lower(aChaves[nI,2]),aChaves[nI,2])
                EndIf

                If Empty(CV3->CV3_IDDEST)
                    CV3->CV3_IDDEST := IIf(__lPostgres,Lower(cCT2UUID),cCT2UUID)
                EndIf
            CV3->(MsUnLock())
        EndIf
    Next
EndIf

RestArea(aArea)

Return
