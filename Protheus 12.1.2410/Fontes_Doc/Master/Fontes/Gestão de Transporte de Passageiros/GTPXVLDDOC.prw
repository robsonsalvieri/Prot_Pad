#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"           
#INCLUDE "GTPXVLDDOC.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpxVldDoc
Função responsavel pela validação dos documentos do recurso e do orgão
@type Function
@author flavio.martins
@since 20/04/2023
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpxVldDoc(aDados,lShowView,aMsgErro,cFunction,lShowMsg)
Local lRet          := .T.
Local cCodOrgao     := ''
Local nX            := 0
Local cTpRecurso    := ''
Local cCodRec       := ''
Local cCodViagem    := ''
Local dData         

Private cTpViagem   := ''

Default lShowView  := .T.
Default aMsgErro   := {}
Default cFunction  := ''
Default lShowMsg   := .T.
Default aDados     := {}

For nX := 1 To Len(aDados)

    cTpRecurso := aDados[nX][1]
    cCodRec    := aDados[nX][2]
    cCodViagem := aDados[nX][3]
    dData      := aDados[nX][4]     

    VldDocRec(cTpRecurso,cCodRec,cCodViagem,dData,@aMsgErro)

    If !Empty(cCodViagem)
        cCodOrgao := GetCodOrg(cCodViagem,cFunction)
    Endif

    If !Empty(cCodOrgao)
        VldDocOrg(cTpRecurso,cCodRec,cCodViagem,dData,cCodOrgao,@aMsgErro)
    Endif

Next

If lShowView .AND. Len(aMsgErro) > 0
    GTPC300X(@aMsgErro)

    For nX := 1 To Len(aDados)

        If (aScan(aMsgErro, {|x| x[1] == .F. .And.;
                                 x[4] == aDados[nX][2] .And.;
                                 x[5] == aDados[nX][3] .And.;
                                 x[6] == aDados[nX][4]}))

            aDados[nX][5] := .F.

        Endif

    Next

ElseIf !lShowView .AND. Len(aMsgErro) > 0
    lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetCodOrg
Função que retorna o código do orgão concedente da viagem
@type Function
@author flavio.martins
@since 20/04/2023
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetCodOrg(cCodViagem,cFunction)
Local cCodOrg   := ''
Local lNewFlds  := (GYN->(FieldPos('GYN_CODG6R')) > 0 .And. G6R->(FieldPos('G6R_ORGAO')) > 0)

dbSelectArea('GYN')
GYN->(dbSetOrder(1))

If GYN->(dbSeek(xFilial('GYN')+cCodViagem))

    cTpViagem := GYN->GYN_TIPO
        
    If GYN->GYN_TIPO == '2' .And. lNewFlds .And. !Empty(GYN->GYN_CODG6R)

        G6R->(dbSetOrder(1))
        If G6R->(dbSeek(xFilial('G6R')+GYN->GYN_CODG6R))
            cCodOrg := G6R->G6R_ORGAO
        Endif

    ElseIf GYN->GYN_TIPO $ '1|3'

        dbSelectArea('GI2')
        GI2->(DbSetOrder(4))

        If dbSeek(xFilial('GI2')+GYN->GYN_LINCOD+"2")
            cCodOrg := GI2->GI2_ORGAO
        Endif

    Endif
Else
    If cFunction == 'GTPA300'
        If M->GYN_TIPO $ '1|3'
            
            dbSelectArea('GI2')
            GI2->(DbSetOrder(4))

            If dbSeek(xFilial('GI2')+M->GYN_LINCOD+"2")
                cCodOrg := GI2->GI2_ORGAO
            Endif
        EndIf
    EndIf
Endif

Return cCodOrg

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldDocRec
Função responsavel pela validação dos documentos do recurso
@type Function
@author 
@since 16/10/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldDocRec(cTpRecurso,cCodRec,cCodViagem,dData,aMsgErro)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cJoinH68  := ""
Local cWhereH68 := ""
Local cTypeErr  := ""
Local cMsgErro  := ""

If AliasInDic("H68")
    cJoinH68 := " LEFT JOIN " + RetSqlName('H68') + " H68 ON H68.H68_FILIAL = '" + xFilial('H68') + "' "
    cJoinH68 += " AND H68.H68_CODG6U = G6W.G6W_CODG6U "
    cJoinH68 += " AND H68.H68_STATUS = '1' "
    cJoinH68 += " AND H68.D_E_L_E_T_ = '' "

    cWhereH68 += " AND (H68.H68_CODG6U IS NULL) "
Endif

cJoinH68 := "%" + cJoinH68 + "%"
cWhereH68 := "%" + cWhereH68 + "%"

BeginSql Alias cAliasTmp

    Column G6W_DTINI as Date
    Column G6W_DTFIM as Date
    Column G6W_DTMAX as Date

    SELECT 
        (CASE
            WHEN G6W_DTMAX < %Exp:dData% THEN 'ERRO'
            WHEN G6W_DTFIM < %Exp:dData% THEN 'ATENÇÃO'
            ELSE ''
        END) AS PROBLEMA,
        G6W.G6W_CODG6U,
        G6U.G6U_DESCRI,
        G6W.G6W_DTINI,
        G6W.G6W_DTFIM,
        G6W.G6W_DTMAX
    From %Table:G6V% G6V
        Inner Join %Table:G6W% G6W on
            G6W.G6W_FILIAL = G6V.G6V_FILIAL
            AND G6W_CODIGO = G6V.G6V_CODIGO
            AND G6W_STATUS <> '2'
            AND G6W_DTFIM < %Exp:dData%
            AND G6W.%NotDel%
        Inner Join %Table:G6U% G6U on
            G6U.G6U_FILIAL = %xFilial:G6U%
            AND G6U.%NotDel%
            AND G6U.G6U_CODIGO = G6W.G6W_CODG6U
            %Exp:cJoinH68%
    Where
        G6V.G6V_FILIAL = %xFilial:G6V%
        AND G6V_TRECUR = %Exp:cTpRecurso%
        AND G6V_RECURS = %Exp:cCodRec%
        AND G6V_STATUS <> '2'
        %Exp:cWhereH68%
        AND G6V.%NotDel%
EndSql

While (cAliasTmp)->(!Eof())

    If AllTrim((cAliasTmp)->PROBLEMA) == 'ERRO'
        cTypeErr := 'UPDERROR'
        cMsgErro := I18n(STR0004,{(cAliasTmp)->G6W_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento #1 - #2 encontra-se vencido e fora do prazo da tolerância permitida"
    ElseIf AllTrim((cAliasTmp)->PROBLEMA) == 'ATENÇÃO'
        cTypeErr := 'UPDWARNING'
        cMsgErro := I18n(STR0005,{(cAliasTmp)->G6W_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento #1 - #2 encontra-se vencido mas está dentro do prazo de tolerância permitida"
    Endif
        
    If !(aScan(aMsgErro, {|x| x[6] == dData .And. x[7] == (cAliasTmp)->G6W_CODG6U}))
        Aadd(aMsgErro, {.F.,;
                        AllTrim(cTypeErr),;
                        (cAliasTmp)->PROBLEMA,;
                        cCodRec,;
                        cCodViagem,;
                        dData,;
                        (cAliasTmp)->G6W_CODG6U,;
                        (cAliasTmp)->G6U_DESCRI,;
                        (cAliasTmp)->G6W_DTINI,;
                        (cAliasTmp)->G6W_DTFIM,;
                        (cAliasTmp)->G6W_DTMAX,;
                        cMsgErro})
    Endif

    (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldDocOrg
Função responsavel pela validação dos documentos do orgão
@type Function
@author flavio.martins
@since 16/10/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldDocOrg(cTpRecurso,cCodRec,cCodViagem,dData,cCodOrg,aMsgErro)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cQuery    := ""
Local cTypeErr  := ""
Local cMsgErro  := ""

If AliasInDic('H68')

    If !(Empty(cCodOrg))
        cQuery := " AND H68.H68_CODGI0 = '" + cCodOrg + "' "
    Endif

    If cTpViagem == '1'
        cQuery += " AND H68.H68_VIAREG = 'T' "
    ElseIf cTpViagem == '2'
        cQuery += " AND H68.H68_VIATUR = 'T' "
    ElseIf cTpviagem == '3'
        cQuery += " AND H68.H68_VIAFRT = 'T' "
    Endif

    cQuery += " AND G6U.G6U_TRECUR IN ('" + cTpRecurso + "','3') "

    cQuery := "%" + cQuery + "%"

    BeginSql Alias cAliasTmp 

        Column H68_DTINI as Date
        Column H68_DTFIM as Date
        Column H68_DTMAX as Date
        Column G6W_DTINI as Date
        Column G6W_DTFIM as Date
        Column G6W_DTMAX as Date

        SELECT H68.H68_DTINI,
               H68.H68_DTFIM,
               H68.H68_DTMAX, 
               H68.H68_CODG6U,
               G6U.G6U_DESCRI,
        (CASE
            WHEN (G6U.G6U_TRECUR = '3' 
                    AND H68.H68_DTMAX < %Exp:dData%) THEN 'ERRO'
            WHEN (G6U.G6U_TRECUR = '3' 
                    AND H68.H68_DTFIM < %Exp:dData%) THEN 'ATENÇÃO'
            WHEN (G6U.G6U_TRECUR != '3'
                    AND %Exp:dData% BETWEEN H68.H68_DTINI AND H68.H68_DTFIM 
                    AND G6W.G6W_CODIGO IS NULL) THEN 'DOCUMENTO EXIGIDO PELO ORGAO'
            WHEN (G6U.G6U_TRECUR <> '3'
                  AND %Exp:dData% BETWEEN H68.H68_DTINI AND H68.H68_DTFIM
                  AND G6W.G6W_CODIGO IS NOT NULL
				  AND G6W.G6W_DTMAX < %Exp:dData%) THEN 'DOCUMENTO VENCIDO'
            WHEN (G6U.G6U_TRECUR <> '3'
                  AND %Exp:dData% BETWEEN H68.H68_DTINI AND H68.H68_DTFIM
                  AND G6W.G6W_CODIGO IS NOT NULL
				  AND G6W.G6W_DTFIM < %Exp:dData%) THEN 'DOCUMENTO NO PRAZO DE TOLERANCIA'
            ELSE ''
        END) AS PROBLEMA

        FROM %Table:H68% H68
        INNER JOIN %Table:G6U% G6U ON G6U.G6U_FILIAL = %xFilial:G6U%
        AND G6U.G6U_CODIGO = H68.H68_CODG6U
        AND G6U.%NotDel%
        LEFT JOIN %Table:G6V% G6V ON G6V.G6V_FILIAL = %xFilial:G6V%
        AND G6V.G6V_RECURS = %Exp:cCodRec%
        AND G6V.G6V_TRECUR = %Exp:cTpRecurso%
        AND G6V.G6V_STATUS <> '2'
        AND G6V.%NotDel%
        LEFT JOIN %Table:G6W% G6W ON G6W.G6W_FILIAL = %xFilial:G6W%
        AND G6W.G6W_CODIGO = G6V.G6V_CODIGO
        AND G6W.G6W_CODG6U = G6U.G6U_CODIGO
        AND G6W.%NotDel%    
        WHERE H68.H68_STATUS <> '2'
          %Exp:cQuery%
          AND H68.%NotDel%

    EndSql
      
    While (cAliasTmp)->(!Eof())

        If AllTrim((cAliasTmp)->PROBLEMA) == 'ERRO'
            cTypeErr := 'UPDERROR'
            cMsgErro := I18n(STR0006,{(cAliasTmp)->H68_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento do órgão #1 - #2 encontra-se vencido e fora do prazo da tolerância permitida"
        ElseIf AllTrim((cAliasTmp)->PROBLEMA) == 'ATENÇÃO'
            cTypeErr := 'UPDWARNING'
            cMsgErro := I18n(STR0007,{(cAliasTmp)->H68_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento do órgão #1 - #2 encontra-se vencido mas está dentro do prazo de tolerância permitida"
        ElseIf AllTrim((cAliasTmp)->PROBLEMA) == 'DOCUMENTO EXIGIDO PELO ORGAO'
            cTypeErr := 'UPDERROR'
            cMsgErro := I18n(STR0008,{(cAliasTmp)->H68_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento do recurso #1 - #2 exigido pelo órgão não consta no cadastro de documentos x recurso"
        ElseIf AllTrim((cAliasTmp)->PROBLEMA) == 'DOCUMENTO VENCIDO'
            cTypeErr := 'UPDERROR'
            cMsgErro := I18n(STR0009,{(cAliasTmp)->H68_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento do recurso #1 - #2 exigido pelo órgão está vencido para o recurso selecionado"
        ElseIf AllTrim((cAliasTmp)->PROBLEMA) == 'DOCUMENTO NO PRAZO DE TOLERANCIA'
            cTypeErr := 'UPDWARNING'
            cMsgErro := I18n(STR0010,{(cAliasTmp)->H68_CODG6U,AllTrim((cAliasTmp)->G6U_DESCRI)}) // "O documento do recurso #1 - #2 exigido pelo órgão está vencido para o recurso selecionado mas ainda dentro do prazo de tolerância"
        Endif

        If !Empty((cAliasTmp)->PROBLEMA) .And. !(aScan(aMsgErro, {|x| x[6] == dData .And. x[7] == (cAliasTmp)->H68_CODG6U}))
            Aadd(aMsgErro, {.F.,;
                            AllTrim(cTypeErr),;
                            (cAliasTmp)->PROBLEMA,;
                            cCodRec,;
                            cCodViagem,;
                            dData,;
                            (cAliasTmp)->H68_CODG6U,;
                            (cAliasTmp)->G6U_DESCRI,;
                            (cAliasTmp)->H68_DTINI,;
                            (cAliasTmp)->H68_DTFIM,;
                            (cAliasTmp)->H68_DTMAX,;
                            cMsgErro})
        Endif

        (cAliasTmp)->(dbSkip())

    End

    (cAliasTmp)->(dbCloseArea())

Endif

Return lRet
