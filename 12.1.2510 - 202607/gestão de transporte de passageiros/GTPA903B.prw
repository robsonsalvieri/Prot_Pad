#Include "GTPA903B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903B
Efetivação da apuração e envio para medição do contrato CNTA121
@type Function
@author
@since 06/04/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA903B()
    Local cCorApura := ""
    Local cMsgErro  := ""
    Local cMsgSol   := ""
    Local lRet      := .T.
    If GQR->GQR_STATUS == "2"
        FwAlertHelp(STR0005, STR0004,) //"Atenção" //"Status deve estar em apuração para gerar a medição"
        Return .F.
    Endif

    If !ValidaVig(GQR->GQR_CODIGO, @cMsgErro, @cMsgSol)
        FwAlertHelp(cMsgErro, cMsgSol)
        Return .F.
    Endif

    If !IsBlind()
        If MsgYesNo(STR0001,STR0002) //'Deseja gerar a medição da apuração' //'Atenção!'
            cCorApura := GQR->GQR_CODIGO//Deixado assim para testes

            If ValidDocs(GQR->GQR_CODIGO)
                FwMsgRun(,{|| PreparaMed(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
                AtualContr(cCorApura,lRet)
            Endif

        EndIf
    Else
        cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
        FwMsgRun(,{|| PreparaMed(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
        AtualContr(cCorApura,lRet)
    EndIf

Return lRet

/*/{Protheus.doc} AtualContr
(long_description)
@type  Static Function
@author user
@since 12/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualContr(cCorApura,lRet)
    Local aArea := GetArea()

    DbSelectArea("GQR")
    DbSetOrder(1)
    If GQR->(DbSeek(xFilial("GQR") + cCorApura))
        If lRet
            RecLock("GQR",.F.)
            GQR->GQR_STATUS := "2"
            GQR->(MsUnLock())
        Else
            RecLock("GQR",.F.)
            GQR->GQR_STATUS := "3"
            GQR->(MsUnLock())
        EndIf
    EndIf
    RestArea(aArea)

Return
/*/{Protheus.doc} PreparaMed
(long_description)
@type  Static Function
@author user
@since 30/05/2023
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PreparaMed( cCorApura as character, lRet as logical )

    Local oModel        as object
    Local oCNE          as object
    Local oCNR          as object
    Local cAliasTmp     as character
    Local cProduto      as character
    Local cTs           as character
    Local aDados        as array
    Local aSeek         as array
    Local aMsgDeErro    as array
    Local nItem         as numeric
    Local nTotalLn      as numeric
    Local nDiscount     as numeric
    Local nAddition     as numeric
    Local lBreak        as logical
    Local lReinicia     as logical

    Default cCorApura   := ""
    Default lRet        := .T.

    oModel        := FwLoadModel("CNTA121")
    oCNE          := NIL
    oCNR          := NIL
    cAliasTmp     := ""
    cProduto      := ""
    cTs           := ""
    aDados        := Array(7)
    aSeek         := {}
    aMsgDeErro    := {}
    nItem         := 0
    nTotalLn      := 0
    nDiscount     := 0
    nAddition     := 0
    lBreak        := .T.
    lReinicia     := .T.

    cAliasTmp := QueryOrc(cCorApura)

    (cAliasTmp)->(DbGoTop())

    // Captura os valores de desconto e acréscimo
    nDiscount := (cAliasTmp)->G9W_VLDESC
    nAddition := (cAliasTmp)->G9W_VLACRE

    aFill(aDados,"")

    oModel:SetOperation(MODEL_OPERATION_INSERT)

    lBreak :=   Alltrim(aDados[1]+aDados[2]) <>;
                Alltrim((cAliasTmp)->(GY0_CODCN9+GY0_REVISA))

    Begin Transaction

    While (cAliasTmp)->(!Eof())

        If ( lBreak )

            oModel:Activate()

            lRet := oModel:SetValue("CNDMASTER","CND_CONTRA", CN9->CN9_NUMERO) .And.;//oModel:LoadValue("CNDMASTER","CND_RCCOMP", "1")  .And.;
                    oModel:LoadValue("CNRDETAIL1","CNR_TIPO"     , (cAliasTmp)->G54_TIPCNR)   .And.;//1=Multa/2=Bonificação
                    oModel:SetValue("CNRDETAIL1","CNR_DESCRI"   , (cAliasTmp)->G54_DESCRI)   .And.;
                    oModel:SetValue("CNRDETAIL1","CNR_VALOR"    , (cAliasTmp)->G54_VLFIXO)

        EndIf

        If ( lRet )

            aSeek := {  {'CXN_FORCLI',(cAliasTmp)->G54_CLIENT},;
                        {'CXN_LOJA',(cAliasTmp)->G54_LOJACL},;
                        {'CXN_CONTRA',(cAliasTmp)->GY0_CODCN9}}

            oModel:GetModel('CXNDETAIL'):Goline(1)

            If oModel:GetModel('CXNDETAIL'):SeekLine(aSeek)

                oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)

                //Quando tiver valor extra adicionar mais uma linha com o mesmo produto
                IIf( !Empty(oModel:GetModel('CNEDETAIL'):GetValue("CNE_ITEM")),oModel:GetModel('CNEDETAIL'):AddLine(), Nil)

                If ( lReinicia )
                    nItem := 1
                EndIf

                cProduto := IIf(Empty((cAliasTmp)->H6Q_PRODUT),(cAliasTmp)->G54_PRODNT,(cAliasTmp)->H6Q_PRODUT)
                nTotalLn := IIf( (cAliasTmp)->VAL_RATEIO == 0,; //condição IF
                                    (cAliasTmp)->TOTLIN+(cAliasTmp)->TOTLEXT,;       //.T.
                                    (cAliasTmp)->VAL_RATEIO)    //.F.

                cTs := Posicione('SB1',1,xFilial('SB1') + cProduto, "B1_TS")
                oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', StrZero(nItem,TamSX3("CNE_ITEM")[1]))//Adiciona um item a planilha
                oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' , cProduto)
                oModel:SetValue( 'CNEDETAIL' , 'CNE_TES', cTs)
                oModel:SetValue( 'CNEDETAIL' , 'CNE_TS' , cTs)
                oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT'  , 1)    // Qtd. deve ser sempre 1, pq o agrupamento de linhas pode conter linhas com unidades e valores
                oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , nTotalLn)  //será o valor do item medido

                nItem++

            EndIf

        EndIf

        aDados[1] := (cAliasTmp)->GY0_CODCN9
        aDados[2] := (cAliasTmp)->GY0_REVISA
        aDados[3] := (cAliasTmp)->G54_CLIENT
        aDados[4] := (cAliasTmp)->G54_LOJACL
        aDados[5] := (cAliasTmp)->G54_CODGQR
        aDados[6] := (cAliasTmp)->G54_NUMGY0
        aDados[7] := (cAliasTmp)->G54_CODGI2

        (cAliasTmp)->(DbSkip())

        lBreak :=   Alltrim(aDados[1]+aDados[2]) <>;
                    Alltrim((cAliasTmp)->(GY0_CODCN9+GY0_REVISA))

        lReinicia   :=  Alltrim(aDados[3]+aDados[4]) <>;
                        Alltrim((cAliasTmp)->(G54_CLIENT+G54_LOJACL))

        If ( lBreak )            

            // Captura o submodelo de multas/bonificações globais do contrato
            oCNR := oModel:GetModel("CNRDETAIL1")

            // Adiciona o acréscimo da apuração na medição (multa)
            If (nAddition > 0)
                // Adiciona uma nova linha no modelo caso a atual já esteja preenchida
                If (!oCNR:IsEmpty() .And. !Empty(oCNR:GetValue("CNR_DESCRI")) .And. !Empty(oCNR:GetValue("CNR_VALOR")))
                    oCNR:AddLine()
                EndIf

                // Define os valores de acréscimo como globais no contrato
                oCNR:SetValue("CNR_TIPO", "1")
                oCNR:SetValue("CNR_DESCRI", STR0013) // "Acréscimo de Apuração de Contrato do SIGAGTP"
                oCNR:SetValue("CNR_VALOR", nAddition)
                oCNR:SetValue("CNR_FLGPED", "1")
            EndIf

            // Adiciona o desconto da apuração na medição (bonificação)
            If (nDiscount > 0)
                // Adiciona uma nova linha no modelo caso a atual já esteja preenchida
                If (!oCNR:IsEmpty() .And. !Empty(oCNR:GetValue("CNR_DESCRI")) .And. !Empty(oCNR:GetValue("CNR_VALOR")))
                    oCNR:AddLine()
                EndIf

                // Define os valores de acréscimo como globais no contrato
                oCNR:SetValue("CNR_TIPO", "2")
                oCNR:SetValue("CNR_DESCRI", STR0014) // "Desconto de Apuração de Contrato do SIGAGTP"
                oCNR:SetValue("CNR_VALOR", nDiscount)
                oCNR:SetValue("CNR_FLGPED", "1")
            EndIf

            lRet := oModel:VldData()

            If ( lRet )

                lRet := oModel:CommitData() .And. !Empty(CND->CND_NUMMED)

                If ( lRet )

                    oModel:DeActivate()

                    lRet    := AtuCont(CND->CND_NUMMED,aDados)
                    //Adicionar o código da medição no contrato
                    lRet := CN121Encerr(.T.) //Realiza o encerramento da medição
                EndIf

            Else

                aMsgDeErro := oModel:GetErrorMessage()
                FwAlertHelp(aMsgDeErro[5], aMsgDeErro[6])

            EndIf

        EndIf

        If ( !lRet )

            IIf(oModel:IsActive(),oModel:DeActivate(),Nil)
            DisarmTransaction()
            Exit

        EndIf

    EndDo

    End Transaction

    // Fecha o arquivo temporário se ainda estiver na memória
    If (Select(cAliasTmp) > 0)
        (cAliasTmp)->(DBCloseArea())
    EndIf
    
Return lRet

/*/{Protheus.doc} AtuCont
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuCont(cNumMed,aDados)

    Local aArea     := G54->(GetArea())
    Local aSeek     := {}
    Local aResult   := {}

    Local nI        := 0

    Local lRet  := .F.

    If !Empty(cNumMed)

        aAdd(aSeek,{"G54_CODGQR",aDados[5]})
        aAdd(aSeek,{"G54_NUMGY0",aDados[6]})
        aAdd(aSeek,{"G54_REVISA",aDados[2]})

        If ( GTPSeekTable("G54",aSeek,aResult) .And. Len(aResult) > 1 )

            For nI := 2 to Len(aResult)

                G54->(DbGoTo(aResult[nI][Len(aResult[nI])]))

                RecLock("G54",.F.)

                    G54->G54_CODCND := cNumMed

                G54->(MsUnLock())

            Next nI

            lRet := .t.

        EndIf

    EndIf

    RestArea(aArea)

Return lRet

/*/{Protheus.doc} QueryOrc
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function QueryOrc(cCorApura)

    Local cAliasAUX := ''

    Default cCorApura := ''

    cAliasAUX := GetNextAlias()

    BeginSQL alias cAliasAUX
        SELECT DISTINCT
            GYD.GYD_CODGYD,
            G54.G54_CLIENT,
            G54.G54_LOJACL,
            GY0.GY0_CODCN9,
            GY0.GY0_REVISA,
            G54.G54_CODGQR,
            G54.G54_NUMGY0,
            G54.G54_TIPCNR,
            G54.G54_DESCRI,
            G54.G54_PRODNT,
            G54.G54_VLFIXO,
            G54.G54_CODGI2,
            G54.G54_QTDEXT,
            ((G54.G54_QTDCON * G54.G54_VLRCON) + G54.G54_VLRACO) AS TOTLIN,
            ((G54.G54_QTDEXT * G54.G54_VLREXT)) AS TOTLEXT,
            ISNULL(H6Q_SEQ,' ') H6Q_SEQ,
	        ISNULL(H6Q_PRODUT,' ') H6Q_PRODUT,
            ISNULL(H6Q_RATEIO,0) RATEIO,
            ISNULL(H6Q_RATEIO/100 * ((G54.G54_QTDCON * G54.G54_VLRCON) + G54.G54_VLRACO),0) VAL_RATEIO,
            G9W.G9W_VLDESC,
            G9W.G9W_VLACRE,
            G9W.G9W_TOTAPU
        FROM
            %Table:GQR% GQR
        INNER JOIN
            %Table:G9W% G9W
        ON
            G9W.G9W_FILIAL     = GQR.GQR_FILIAL
            AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
            AND G9W.%NotDel%
        INNER JOIN
            %Table:G54% G54
        ON
            G54.G54_FILIAL     = GQR.GQR_FILIAL
            AND G54.G54_CODGQR = G9W.G9W_CODGQR
            AND G54.G54_NUMGY0 = G9W.G9W_NUMGY0
            AND G54.G54_REVISA = G9W.G9W_REVISA
            AND G54.%NotDel%
        INNER JOIN
            %Table:GY0% GY0
        ON
            GY0.GY0_FILIAL      = G54.G54_FILIAL
            AND GY0.GY0_NUMERO  = G54.G54_NUMGY0
            AND GY0.GY0_REVISA  = G54.G54_REVISA
            AND GY0.%NotDel%
        INNER JOIN
            %Table:GYD% GYD
        ON
            GYD.GYD_FILIAL      = G54.G54_FILIAL
            AND GYD.GYD_NUMERO  = G54.G54_NUMGY0
            AND GYD.GYD_CODGYD = G54.G54_CODGYD
            AND GYD.GYD_CODGI2  = G54.G54_CODGI2
            AND GYD.%NotDel%
        LEFT JOIN
            %Table:H6A% H6A
        ON
            H6A.H6A_FILIAL = %xFilial:H6A%
            AND H6A.H6A_CLIENT = G54.G54_CLIENT
            AND H6A.H6A_LOJA = G54.G54_LOJACL
            AND H6A.H6A_STATUS = '1'
            AND H6A.%NotDel%
        LEFT JOIN
            %Table:H6Q% H6Q
        ON
            H6Q.H6Q_FILIAL = H6A.H6A_FILIAL
            AND H6Q.H6Q_CODH6A = H6A.H6A_CODIGO
            AND H6Q.%NotDel%
        WHERE
            GQR.GQR_FILIAL     = %xFilial:GQR%
            AND GQR.GQR_CODIGO = %exp:cCorApura%
            AND GQR.%NotDel%
        UNION ALL 
        SELECT DISTINCT
            GYD.GYD_CODGYD,
            G54.G54_CLIENT,
            G54.G54_LOJACL,
            GY0.GY0_CODCN9,
            GY0.GY0_REVISA,
            G54.G54_CODGQR,
            G54.G54_NUMGY0,
            G54.G54_TIPCNR,
            G54.G54_DESCRI,
            G54.G54_PRODNT,
            G54.G54_VLFIXO,
            G54.G54_CODGI2,
            G54.G54_QTDEXT,
            0 AS TOTLIN,
            ((G54.G54_QTDEXT * G54.G54_VLREXT)) AS TOTLEXT,
            ISNULL(H6Q_SEQ,' ') H6Q_SEQ,
	        ISNULL(H6Q_PRODUT,' ') H6Q_PRODUT,
            0 RATEIO,
            0 VAL_RATEIO,
            G9W.G9W_VLDESC,
            G9W.G9W_VLACRE,
            G9W.G9W_TOTAPU
        FROM
            %Table:GQR% GQR
        INNER JOIN
            %Table:G9W% G9W
        ON
            G9W.G9W_FILIAL     = GQR.GQR_FILIAL
            AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
            AND G9W.%NotDel%
        INNER JOIN
            %Table:G54% G54
        ON
            G54.G54_FILIAL     = GQR.GQR_FILIAL
            AND G54.G54_CODGQR = G9W.G9W_CODGQR
            AND G54.G54_NUMGY0 = G9W.G9W_NUMGY0
            AND G54.G54_REVISA = G9W.G9W_REVISA
            AND G54.%NotDel%
        INNER JOIN
            %Table:GY0% GY0
        ON
            GY0.GY0_FILIAL      = G54.G54_FILIAL
            AND GY0.GY0_NUMERO  = G54.G54_NUMGY0
            AND GY0.GY0_REVISA  = G54.G54_REVISA
            AND GY0.%NotDel%
        INNER JOIN
            %Table:GYD% GYD
        ON
            GYD.GYD_FILIAL      = G54.G54_FILIAL
            AND GYD.GYD_NUMERO  = G54.G54_NUMGY0
            AND GYD.GYD_CODGYD = G54.G54_CODGYD
            AND GYD.%NotDel%
        LEFT JOIN
            %Table:H6A% H6A
        ON
            H6A.H6A_FILIAL = %xFilial:H6A%
            AND H6A.H6A_CLIENT = G54.G54_CLIENT
            AND H6A.H6A_LOJA = G54.G54_LOJACL
            AND H6A.H6A_STATUS = '1'
            AND H6A.%NotDel%
        LEFT JOIN
            %Table:H6Q% H6Q
        ON
            H6Q.H6Q_FILIAL = H6A.H6A_FILIAL
            AND H6Q.H6Q_CODH6A = H6A.H6A_CODIGO
            AND H6Q.%NotDel%
        WHERE
            GQR.GQR_FILIAL     = %xFilial:GQR%
            AND GQR.GQR_CODIGO = %exp:cCorApura%
            AND G54.G54_QTVESL > 0 
            AND GQR.%NotDel%
        ORDER BY
            G54_NUMGY0,
            G54_CODGQR,
            GY0_CODCN9,
            GY0_REVISA,
            GYD_CODGYD,
            G54_CLIENT,
            G54_LOJACL,
            H6Q_SEQ
    EndSql

Return cAliasAUX

/*/{Protheus.doc} ValidDocs(codApura)
Valida pendência de checklist dos documentos operacionais do contrato
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ValidDocs(codApura)
    Local lRet 	:= .T.

    Default codApura := ''

    UpdateDocs(GQR->GQR_CODIGO)

    If ExistDocs(codApura)

        If FwAlertYesNo(STR0009, STR0004) // "Encontrado documentos obrigatórios para a apuração. Deseja realizar o checklist agora ? ", "Atenção"
            GTPA903D()
        Endif

        If ExistDocs(codApura)
            lRet := .F.
            FwAlertWarning(STR0010) // "A medição não poderá ser realizada até que os documentos exigidos sejam validados.", "Atenção"
        Endif

    Endif

Return lRet

/*/{Protheus.doc} ExistDocs(codApura)
Verifica se existem documentos pendentes de checklist
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ExistDocs(codApura)
    Local lRet 		:= .T.
    Local cAliasTmp	:= GetNextAlias()

    Default codApura := ''

    BeginSql Alias cAliasTmp

        SELECT COALESCE(COUNT(H69_NUMERO), 0) AS TOTREG
        FROM %Table:G9W% G9W
        INNER JOIN %Table:H69% H69 ON H69.H69_FILIAL = %xFilial:H69%
        AND H69.H69_NUMERO = G9W.G9W_NUMGY0
        AND H69.H69_REVISA = G9W.G9W_REVISA
        AND H69.H69_EXIGEN IN ('2','3')
        AND H69.H69_CHKLST = 'F'
        AND H69.%NotDel%
        WHERE G9W.G9W_FILIAL = %xFilial:G9W%
        AND G9W.G9W_CODGQR = %Exp:codApura%
        AND G9W.%NotDel%

    EndSql

    lRet := (cAliasTmp)->TOTREG > 0

    (cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} ValidaVig()
Verifica se a medição está dentro da vigência do contrato
@author flavio.martins
@since 16/02/2023
@version 1.0
@return lógico
@type function
/*/
Static Function ValidaVig(cCodApura, cMsgErro, cMsgSol)
    Local lRet := .T.
    Local cAliasTmp := GetNextAlias()

    BeginSql Alias cAliasTmp

        SELECT G9W_CONTRA
        FROM %Table:G9W%
        WHERE G9W_FILIAL = %xFilial:G9W%
        AND G9W_CODGQR = %Exp:cCodApura%
        AND %NotDel%

    EndSql

    dbSelectArea('CN9')
    CN9->(dbSetOrder(7))

    While ((cAliasTmp)->(!Eof()))

        If CN9->(dbSeek(xFilial('CN9')+(cAliasTmp)->G9W_CONTRA+'05'))

            lRet := ((dDataBase >= CN9->CN9_DTINIC) .And. (dDataBase <= CN9->CN9_DTFIM))

        Endif

        If !lRet
            cMsgErro := I18n(STR0011, {(cAliasTmp)->G9W_CONTRA}) // "Data atual do sistema fora da vigência do contrato #1"
            cMsgSol  := STR0012                                  // "Altere a data do sistema para uma data dentro da vigência do contrato"
            Exit
        Endif

        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} UpdateDocs(codApura)
Atualiza os status dos documentos exigidos na apuração
@author flavio.martins
@since 16/02/2023
@version 1.0
@return lógico
@type function
/*/
Static Function UpdateDocs(codApura)
    Local cAliasTmp	:= GetNextAlias()

    Default codApura := ''

    BeginSql Alias cAliasTmp

        SELECT H69.R_E_C_N_O_ as RECNO
        FROM %Table:G9W% G9W
        INNER JOIN %Table:H69% H69 ON H69.H69_FILIAL = %xFilial:H69%
        AND H69.H69_NUMERO = G9W.G9W_NUMGY0
        AND H69.H69_REVISA = G9W.G9W_REVISA
        AND H69.H69_EXIGEN IN ('2','3')
        AND H69.%NotDel%
        WHERE G9W.G9W_FILIAL = %xFilial:G9W%
        AND G9W.G9W_CODGQR = %Exp:codApura%
        AND G9W.%NotDel%

    EndSql

    dbSelectArea('H69')

    While (cAliasTmp)->(!Eof())
        H69->(dbGoto((cAliasTmp)->RECNO))
        RecLock('H69', .F.)
            H69->H69_CHKLST := .F.
        H69->(MsUnLock())
        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

Return
