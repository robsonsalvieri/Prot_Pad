#INCLUDE "loca073.ch" 
#include "totvs.ch"
#include "topconn.ch"
#Include "fwmvcdef.ch"
#Include "RESTFUL.CH"
#Include "PcoTryException.ch"
#Include "RPTDEF.CH" // DSERLOCA-13040
#Include "FWPrintSetup.ch" // DSERLOCA-13040

/*/{Protheus.doc} LOCA073
Emissor de faturas e boletos
@type function
@version v1 
@author Frank Zwarg Fuga
@since 11/05/2026
/*/
Function LOCA073(aParamAuto) 
Local aProcessa := {}
Local cArqLock := "LOCA073"
Local lRet := .T.
Local lLocSim := .T. //supergetmv("MV_LOCSIM",,.F.) retirada do parâmetro DSERLOCA-12988
Local lLocJunt := .T. //supergetmv("MV_LOCJUNT",,.F.) retirada do parâmetro DSERLOCA-12988
Local aPergs := {}
Local aRet := {}
Local aSit := {}
Local cArqLogFim := "" // DSERLOCA-13040 - nome do arquivo de log consolidado exibido ao usuario
Local cDirLogFim := "" // DSERLOCA-13040 - pasta do log consolidado

Private lAuto  := .F.
Private cCliDe
Private cLojDe
Private cCliAte
Private cLojAte
Private cProDe
Private cProAte
Private cObraDe
Private cObraAte
Private dEmisDe
Private dEmisAte
Private nTipo
Private cSerDe
Private cSerAte
Private nEnvia
Private cDocDe
Private cDocAte
Private cNfe
Private cLog := "" // DSERLOCA-13040 - acumula o log de pendencias (boleto/fatura nao gerados/enviados) para exibicao ao final do processamento

Default aParamAuto := {}

    aSit := {"1 - " + STR0022,; //"NF não transmitida"
			 "2 - " + STR0023,; //"NF autorizada"
			 "3 - " + STR0024,; //"NF transmitida"
			 "4 - " + STR0025,; //"NF uso denegado"
			 "5 - " + STR0026,; //"NF não autorizada"
             "6 - " + STR0028; //"Ambos"
            } 

    lMsErroAuto := .F.

    If len(aParamAuto) > 0

        // Tratativa para evitar o processamento em redundancia
        If !LockByName( CARQLOCK, .F., .F. )
            Help(" ",1,STR0021) // "Bloqueio por uso exclusivo."
            Return .F.
        EndIf

        lAuto := .T.
        cCliDe   := aParamAuto[01]
        cLojDe   := aParamAuto[02]
        cCliAte  := aParamAuto[03]
        cLojAte  := aParamAuto[04]
        cProDe   := aParamAuto[05]
        cProAte  := aParamAuto[06]
        cObraDe  := aParamAuto[07]
        cObraAte := aParamAuto[08]
        dEmisDe  := aParamAuto[09]
        dEmisAte := aParamAuto[10]
        nTipo    := aParamAuto[11]
        cSerDe   := aParamAuto[12]
        cSerAte  := aParamAuto[13]
        nEnvia   := aParamAuto[14]
        cDocDe   := aParamAuto[15]
        cDocAte  := aParamAuto[16]
        cNfe     := "2" //aParamAuto[17]
    EndIf

    If !lAuto

        // A opção de envia boletos é o MV_PAR14 (1=envia, 2=não envia) - numérico
        // Se MV_LOCSIM e MV_LOCJUNT forem .T. vamos apresentar o pergunte se envia, ou não o boleto
        // do contrário MV_PAR14 será 2- não envia
        // lLocSim == MV_LOCSIM
        // lLocJunt == MV_LOCJUNT

        //tipo 1 get  , descricao, picture, validacao, f3, whem, tamanho do get, obrigatorio
        //tipo 2 combo, descricao, opcao inicial do combo, array com as opcoes do combo, tamanho do combo, validacao, obrigatorio
        aAdd( aPergs ,{1, STR0040, Space(tamsx3("A1_COD")[1]),     "@!", "","SA1", ".T." ,60 , .F.}) // "Cliente de ?"
		aAdd( aPergs ,{1, STR0041, Space(tamsx3("A1_LOJA")[1]),    "@!", "",""   , ".T." ,30 , .F.}) // "Loja de ?"
        aAdd( aPergs ,{1, STR0042, Space(tamsx3("A1_COD")[1]),     "@!", "","SA1", ".T." ,60 , .F.}) // "Cliente até?"
        aAdd( aPergs ,{1, STR0043, Space(tamsx3("A1_LOJA")[1]),    "@!", "",""   , ".T." ,30 , .F.}) // "Loja até ?"
        aAdd( aPergs ,{1, STR0044, Space(tamsx3("FP0_PROJET")[1]), "@!", "","FP0", ".T." ,60 , .F.}) // "Projeto de ?"
        aAdd( aPergs ,{1, STR0045, Space(tamsx3("FP0_PROJET")[1]), "@!", "","FP0", ".T." ,60 , .F.}) // "Projeto até ?"
        aAdd( aPergs ,{1, STR0046, Space(tamsx3("FPA_OBRA")[1]),   "@!", "",""   , ".T." ,30 , .F.}) // "Obra de ?"
        aAdd( aPergs ,{1, STR0047, Space(tamsx3("FPA_OBRA")[1]),   "@!", "",""   , ".T." ,30 , .F.}) // "Obra Ate ?"
        aAdd( aPergs ,{1, STR0048, ctod(""),                       "",   "",""   , ".T." ,60 , .F.}) // "Emissão de ?"
        aAdd( aPergs ,{1, STR0049, ctod(""),                       "",   "",""   , ".T." ,60 , .F.}) // "Emissão até ?"
        aAdd( aPergs ,{2, STR0050, 3,                              {STR0058, STR0059, STR0060}, 60, ".T.", .F. }) // "Tipo de envio ?" {"1-Pendente", "2-Enviado", "3-Ambos"}
        aAdd( aPergs ,{1, STR0051, Space(tamsx3("F2_SERIE")[1]),   "@!", "","01" , ".T." ,6 , .F.}) // "Série de ?"
        aAdd( aPergs ,{1, STR0052, Space(tamsx3("F2_SERIE")[1]),   "@!", "","01" , ".T." ,6 , .F.}) // "Série até ?"
        If lLocSim .and. lLocJunt
            aAdd( aPergs ,{2, STR0053, 1,                          {STR0061, STR0062}, 60, ".T.", .F. }) // "Enviar boletos ?" {"1-Sim", "2-Não"}
        EndIf
        aAdd( aPergs ,{1, STR0054, Space(tamsx3("FPB_CODIGO")[1]), "@!", "",""   , ".T." ,6 , .F.}) // "Cod.Doc. de ?"
        aAdd( aPergs ,{1, STR0055, Space(tamsx3("FPB_CODIGO")[1]), "@!", ""          ,""   , ".T." ,6 , .F.}) // "Cod.Doc. até ?"
        //aAdd( aPergs ,{2, STR0056, 6,                              aSit, 60, ".T.", .F.  }) // "Status da NFe nacional ?"*/

        If ParamBox(aPergs , STR0057,@aRet,,,,,,,,.F.) //"Parâmetros para o envio"
			MV_PAR01 := aRet[1]
            MV_PAR02 := aRet[2]
            MV_PAR03 := aRet[3]
            MV_PAR04 := aRet[4]
            MV_PAR05 := aRet[5]
            MV_PAR06 := aRet[6]
            MV_PAR07 := aRet[7]
            MV_PAR08 := aRet[8]
            MV_PAR09 := aRet[9]
            MV_PAR10 := aRet[10]
            MV_PAR11 := aRet[11]
            MV_PAR12 := aRet[12]
            MV_PAR13 := aRet[13]
            If lLocSim .and. lLocJunt
                MV_PAR14 := aRet[14] // fixar o não envio do boleto
                MV_PAR15 := aRet[15] // [14] pois retiramos o parametro do parambox 14
                MV_PAR16 := aRet[16]
            Else
                MV_PAR14 := 2
                MV_PAR15 := aRet[14] // [14] pois retiramos o parametro do parambox 14
                MV_PAR16 := aRet[15]
            EndIf
            MV_PAR17 := 2 // Status da NFe nacional
        Else
            Return .F.
        EndIf

        cCliDe   := MV_PAR01
        cLojDe   := MV_PAR02
        cCliAte  := MV_PAR03
        cLojAte  := MV_PAR04
        cProDe   := MV_PAR05
        cProAte  := MV_PAR06
        cObraDe  := MV_PAR07
        cObraAte := MV_PAR08
        dEmisDe  := MV_PAR09
        dEmisAte := MV_PAR10
        nTipo    := MV_PAR11
        cSerDe   := MV_PAR12
        cSerAte  := MV_PAR13
        nEnvia   := MV_PAR14
        cDocDe   := MV_PAR15
        cDocAte  := MV_PAR16
        cNfe     := MV_PAR17
	EndIf

    TRY EXCEPTION
    
        If lAuto
            aProcessa := LOCA0731()
            LOCA0734(aProcessa)
            UnLockByName( CARQLOCK, .F., .F. )
        else
            PROCESSA({|| aProcessa := LOCA0731()}, STR0001,STR0002) //"Aguarde... processando o envio das informações."###"Envio dos documentos Rental."
            PROCESSA({|| LOCA0734(aProcessa)}, STR0010,STR0002) //"Enviando os documentos."###"Envio dos documentos Rental."
        EndIf
        
        lRet := .t.
    
    CATCH EXCEPTION
        

        Help(" ",1,STR0030) // "Erro de execução na rotina."

        lRet := .F.
        lMsErroAuto := .T.
        
    END TRY

    // DSERLOCA-13040 - Se houver pendencias (boleto ou fatura nao gerados/enviados) e a execucao for
    // interativa (nao automatica/job), grava um log consolidado e abre ele automaticamente para o
    // usuario, no mesmo padrao usado pelo LOCA105 (MemoWrite + ShellExecute).
    If !lAuto .and. !Empty(cLog) // DSERLOCA-13040
        cLog := "Processamento concluido com pendencias:" + chr(13) + chr(10) + chr(13) + chr(10) + cLog // DSERLOCA-13040
        cArqLogFim := "LOG-PENDENCIAS-" + dtos(dDataBase) + "-" + strtran(time(),":","-") + ".log" // DSERLOCA-13040
        cDirLogFim := "\relato\" // DSERLOCA-13040
        MemoWrite(cDirLogFim + cArqLogFim, cLog) // DSERLOCA-13040
        ShellExecute("OPEN", cArqLogFim, "", cDirLogFim, 1) // DSERLOCA-13040
    EndIf // DSERLOCA-13040

Return lRet

/*/{Protheus.doc} LOCA0731
Rotina para o envio dos documentos fiscais
@type function
@version v1 
@author Frank Zwarg Fuga
@since 12/05/2026
/*/
Function LOCA0731
Local cQuery
Local nProcessa
Local aBindParam
Local nPos := 1
Local aProcessa := {}
Local cObra := ""
Local lGrava

    aBindParam := {}
	cQuery := " SELECT COUNT(*) AS TOTAL "
	cQuery += " FROM "+RetSQLName("SF2")+" SF2"
	cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery += " AND SF2.F2_SERIE >= ? "
   	Aadd(aBindParam, cSerDe)
    cQuery += " AND SF2.F2_SERIE <= ? "
   	Aadd(aBindParam, cSerAte)
    cQuery += " AND SF2.F2_CLIENTE >= ? "
   	Aadd(aBindParam, cCliDe)
    cQuery += " AND SF2.F2_CLIENTE <= ? "
   	Aadd(aBindParam, cCliAte)
    cQuery += " AND SF2.F2_LOJA >= ? "
   	Aadd(aBindParam, cLojDe)
    cQuery += " AND SF2.F2_LOJA <= ? "
   	Aadd(aBindParam, cLojAte)
    cQuery += " AND SF2.F2_EMISSAO >= ? "
   	Aadd(aBindParam, dtos(dEmisDe))
    cQuery += " AND SF2.F2_EMISSAO <= ? "
   	Aadd(aBindParam, dtos(dEmisAte))
	cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery := CHANGEQUERY(cQuery)
	MPSysOpenQuery(cQuery,"TRBSF2",,,aBindParam)

    nProcessa := TRBSF2->TOTAL
    
    If !lAuto
        ProcRegua(nProcessa)
    EndIf

    aBindParam := {}
	cQuery := " SELECT SF2.R_E_C_N_O_ REG "
	cQuery += " FROM "+RetSQLName("SF2")+" SF2"
	cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery += " AND SF2.F2_SERIE >= ? "
   	Aadd(aBindParam, cSerDe)
    cQuery += " AND SF2.F2_SERIE <= ? "
   	Aadd(aBindParam, cSerAte)
    cQuery += " AND SF2.F2_CLIENTE >= ? "
   	Aadd(aBindParam, cCliDe)
    cQuery += " AND SF2.F2_CLIENTE <= ? "
   	Aadd(aBindParam, cCliAte)
    cQuery += " AND SF2.F2_LOJA >= ? "
   	Aadd(aBindParam, cLojDe)
    cQuery += " AND SF2.F2_LOJA <= ? "
   	Aadd(aBindParam, cLojAte)
    cQuery += " AND SF2.F2_EMISSAO >= ? "
   	Aadd(aBindParam, dtos(dEmisDe))
    cQuery += " AND SF2.F2_EMISSAO <= ? "
   	Aadd(aBindParam, dtos(dEmisAte))
	cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery := CHANGEQUERY(cQuery)
	MPSysOpenQuery(cQuery,"TRBSF2",,,aBindParam)
	While !TRBSF2->(Eof()) 

        SF2->(dbGoto(TRBSF2->REG))

        If !lAuto
            IncProc( STR0003 + alltrim(str(nPos)) + STR0004 + alltrim(str(nProcessa)) ) //"Registro: "###" de: "
            SysRefresh()
            nPos ++
        EndIf

        SC6->(dbSetOrder(4))
        If SC6->(dbSeek(xFilial("SC6")+SF2->(F2_DOC+F2_SERIE)))
            FPY->(dbSetOrder(1))
            If FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
                If alltrim(FPY->FPY_STATUS) <> "2" .and. FPY->FPY_TIPFAT <> "R"

                    // Filtro do projeto
                    If FPY->FPY_PROJET < cProDe .or. FPY->FPY_PROJET > cProAte
                        TRBSF2->(dbSkip())
                        Loop
                    EndIF


                    // Parametro 11 Pendente e enviado
                    If nTipo == 1 .and. ( FPY->FPY_ENVIO == "1" .and. !empty(FPY->FPY_ENVIO))
                        TRBSF2->(dbSkip())
                        Loop
                    EndIF

                    // Parametro 11 enviado e enviado
                    If nTipo == 2 .and. FPY->FPY_ENVIO <> "1"
                        TRBSF2->(dbSkip())
                        Loop
                    EndIF

                    lGrava := .F.

                    aEmail := {}
                    FPB->(dbSetOrder(1))
                    FPB->(dbSeek(xFilial("FPB")+FPY->FPY_PROJET))
                    While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+FPY->FPY_PROJET

                        If FPB->FPB_CODIGO >= cDocDe .and. FPB->FPB_CODIGO <= cDocAte .and. FPB->FPB_OBRA >= cObraDe .and. FPB->FPB_OBRA <= cObraAte .and. FPB->FPB_OBRA == FPY->FPY_OBRA

                            // Estando posicionado em uma nota de saída de faturamento
                            // Validaremos se o usuário/e-mail que receberá a informação valida a obra
                            If FPB->FPB_VALOBR == "1" // Validar a obra
                                cObra := FPB->FPB_OBRA
                                FPZ->(dbSetOrder(1))
                                FPZ->(dbSeek(xFilial("FPZ")+FPY->FPY_PROJET))
                                FPA->(dbSetorder(3))
                                FPA->(dbSeek(xFilial("FPA")+FPZ->FPZ_AS))
                                If FPA->FPA_OBRA <> cObra
                                    FPB->(dbskip())
                                    Loop
                                endIf
                            EndIf

                            FPC->(dbSetOrder(1))
                            If FPC->(dbSeek(xFilial("FPC")+FPB->FPB_CODIGO))

                                If !empty(FPB->FPB_EMAIL) .and. FPC->FPC_TPENV $ ("1234")
                                    lGrava := .T.
                                    aadd(aProcessa,{FPB->FPB_EMAIL,;
                                                    FPC->FPC_TPENV,;
                                                    FPY->FPY_PROJET,;
                                                    SF2->F2_DOC,;
                                                    SF2->F2_SERIE,;
                                                    SF2->F2_EMISSAO,;
                                                    SF2->F2_CLIENTE,;
                                                    SF2->F2_LOJA,;
                                                    "",;
                                                    "",;
                                                    "",;
                                                    SF2->(RecNo()),;
                                                    FPC->FPC_PROG,;
                                                    alltrim(FPC->FPC_MSGENV);
                                                   })
                                EndIF

                            Endif
                        EndIf
                        FPB->(dbSkip())
                    EndDo

                    If lGrava
                        FPY->(RecLock("FPY",.F.))
                        FPY->FPY_ENVIO := "1"
                        FPY->(MsUnlock())
                    EndIf

                EndIf
            EndIf
        EndIf

        TRBSF2->(dbSkip())

    EndDo

    TRBSF2->(dbCloseArea())

Return aProcessa


/*/{Protheus.doc} LOCA073V
Validação do campo FPC_PROG
@type function
@version v1 
@author Frank Zwarg Fuga
@since 13/05/2026
/*/
Function LOCA073V(cTipo)
Local lRet := .T.
    
    // cTipo = W -> when do campo
    If cTipo == "W"
        If M->FPC_TPENV <> "1" .and. M->FPC_TPENV <> "5" // Específico
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LOCA073C
@type function
X3_CBOX do campo FPC_TPENV
@author Frank Zwarg Fuga
@since 13/05/2026
/*/
Function LOCA073C(cTipo)
Local xRetorno := ""

    // cTipo = V -> Validação
    If cTipo == "V"
        If !M->FPC_TPENV $ ("012345")
            xRetorno := .F.
        Else
            xRetorno := .T.
        EndIf
    EndIf

    // cTipo = C -> cBox
	If cTipo == "C"
        xRetorno += ( "0=" + STR0005 + ";"	) // "Não se aplica"
        xRetorno += ( "1=" + STR0006 + ";"	) // "Específico"
        xRetorno += ( "2=" + STR0007 + ";"	) // "NF Municipal"
        xRetorno += ( "3=" + STR0008 + ";"	) // "NFS-e Nacional"
        xRetorno += ( "4=" + STR0009 + ";" 	) // "Fatura"
        xRetorno += ( "5=" + STR0063    	) // "Reajuste"
    EndIf

Return xRetorno

/*/{Protheus.doc} LOCA0734
Envio dos documentos fiscais
@type function
@version v1 
@author Frank Zwarg Fuga
@since 13/05/2026
/*/
Function LOCA0734(aProcessa)
Local lRet := .T.
Local nX
Local nY
Local cNota
Local cSerie
Local cEmail
Local cProjeto
Local cArquivo
Local cDireto := "\relato\"
Local dEmiss
Local cCliente
Local cLoja
Local lEspec := .F.
Local lNfMun := .F.
Local lNfsNa := .F.
Local lFatur := .F.
Local lXml   := .F.
Local aArquivos := {}
Local cAssunto := STR0011 // "RENTAL - Envio dos documentos fiscais"
Local cCorpo
Local aRet
Local cTipox
Local aEmail := {}
Local aAnexos := {}
Local cDel
Local aAreaSF2 
Local aPdf
Local aNotas := {}
Local aEnv := {}
Local lEnv
Local aDelBol := {}
Local cConteudo := ""
Local nZ
Local nW
Local cFuncExec := ""

// Nota fiscal nacional
Private cTipo := "3" // para executar o xml
Private lImNac := .F. // para executar o xml
Private aAIDF :={}
Private cCodmun := SM0->M0_CODMUN
Private cAviso := ""
Private cIDEnt := SM0->M0_CIDENT
Private cAmbiente 	:= SubStr(GetAmbNfse( cIdEnt, .F. ),1,1)

// Nota fical municipal
Private cModeloNFSe := "1-NFS-e Prefeitura"

    ProcRegua(len(aProcessa))

    For nX := 1 to len(aProcessa)
        
        cNota := aProcessa[nX,4]
        cSerie := aProcessa[nX,5]
        cTipox := aProcessa[nX,2]
        cEmail := aProcessa[nX,1]
        cProjeto := aProcessa[nX,3]
        dEmiss := aProcessa[nX,6]
        cCliente := aProcessa[nX,7]
        cLoja := aProcessa[nX,8]

        SF2->(dbGoto(aProcessa[nX,12]))

// Desativado por Alessandro Gois em 31/08/2026
// Estava travando o fonte, nao prosseguia após o processmessage()
        If !lAuto
            IncProc( STR0003 + alltrim(str(nX)) + STR0004 + alltrim(str(len(aProcessa))) ) //"Registro: "###" de: "
            //ProcessMessage() -- alessandro gois
            //SysRefresh()
        EndIf

        aadd(aNotas, {aProcessa[nX,12], aProcessa[nX,1]} )

        lEspec := .F.
        lNfMun := .F.
        lNfsNa := .F.
        lFatur := .F.
        lXml   := .F.

        If cTipox == "1" // Especifico
            // o fonte na FPC não pode vir com () e deve começar com U_
            // o fonte deve retornar com o arquivo que foi gerado
            If !empty(aProcessa[nX,13])
                If FindFunction( alltrim(aProcessa[nX,13]) )
                    aAreaSF2 := SF2->(GetArea())
                    cArquivo := &(alltrim(aProcessa[nX,13])+"()")
                    SF2->(RestArea(aAreaSF2))
                    If file(cDireto+cArquivo)
                        aProcessa[nX,9]  := STR0013 //"Específico"
                        aProcessa[nX,10] := cDireto+cArquivo
                        aProcessa[nX,11] := cArquivo
                    EndIf
                EndIf
            EndIf
        ElseIf cTipox == "2" // NF Municipal - mandar o xml também

            cArquivo := "XML-" + alltrim(str(Year(dDataBase))) + strzero(month(dDataBase),2,0) + strzero(day(dDataBase),2,0)+alltrim(str(seconds()))
            cArquivo := strtran(cArquivo,".","")
            cArquivo += ".xml"

            /*If MV_PAR17 == 1 //"NF não transmitida"
                If SF2->F2_FIMP <> " "
                    Loop
                EndIf
            ElseIf MV_PAR17 == 2 //"NF autorizada"
                If SF2->F2_FIMP <> "S"
                    Loop
                EndIf
            ElseIf MV_PAR17 == 3 //"NF transmitida"
                If SF2->F2_FIMP <> "T"
                    Loop
                EndIf
            ElseIf MV_PAR17 == 4 //"NF uso denegado"
                If SF2->F2_FIMP <> "D"
                    Loop
                EndIf
            ElseIf MV_PAR17 == 5 //"NF não autorizada"
                If SF2->F2_FIMP <> "N"
                    Loop
                EndIf
            EndIf*/

            If MV_PAR17 == 2 //"NF autorizada"
                If SF2->F2_FIMP <> "S"
                    Loop
                EndIf
            EndIf

            aAIDF := {}
            if (cCodmun $ Fisa022Cod( "010" ) ) .and. !( cCodmun $ "5221858" ) 
                aAIDF := getAidfRps(cCodmun, cSerie, cNota, @cAviso)
            endif

            aRet := nfseXMLEnv( "1", SF2->F2_EMISSAO, cSerie, cNota, cCliente, cLoja, "", aAIDF )
            
            If len(aRet) > 0
                 MemoWrite(cDireto+cArquivo, aRet[1])
                 If File(cDireto+cArquivo)
                    aProcessa[nX,9] := STR0014 //"NFS-e Municipal"
                    aProcessa[nX,10] := cDireto+cArquivo
                    aProcessa[nX,11] := cArquivo
                Endif
            EndIf

        ElseIf cTipox == "3" // NFS-e Nacional - mandar o xml também

            cArquivo := "XML-" + alltrim(str(Year(dDataBase))) + strzero(month(dDataBase),2,0) + strzero(day(dDataBase),2,0)+alltrim(str(seconds()))
            cArquivo := strtran(cArquivo,".","")
            cArquivo += ".xml"
            cDireto  := "\relato\"

            if (cCodmun $ Fisa022Cod( "010" ) ) .and. !( cCodmun $ "5221858" ) 
                aAIDF := getAidfRps(cCodmun, cSerie, cNota, @cAviso)
            endif

            aRet := {}

            /*If MV_PAR17 == "1" //"NF não transmitida"
                If SF2->F2_FIMP <> " "
                    Loop
                EndIf
            ElseIf MV_PAR17 == "2" //"NF autorizada"
                If SF2->F2_FIMP <> "S"
                    Loop
                EndIf
            ElseIf MV_PAR17 == "3" //"NF transmitida"
                If SF2->F2_FIMP <> "T"
                    Loop
                EndIf
            ElseIf MV_PAR17 == "4" //"NF uso denegado"
                If SF2->F2_FIMP <> "D"
                    Loop
                EndIf
            ElseIf MV_PAR17 == "5" //"NF não autorizada"
                If SF2->F2_FIMP <> "N"
                    Loop
                EndIf
            EndIf*/
            If MV_PAR17 == 2 //"NF autorizada"
                If SF2->F2_FIMP <> "S"
                    Loop
                EndIf
            EndIf

            cFuncExec := "NFSEXMLNAC"

			aRet := tssExecRdm(cFuncExec,.T.,{cTipo, dEmiss, cSerie, cNota, cCliente, cLoja, "", aAIDF, "", cAmbiente})  

            If len(aRet) > 0
                 MemoWrite(cDireto+cArquivo, aRet[1])
                 If File(cDireto+cArquivo)
                    aProcessa[nX,9] := STR0015 //"NFS-e Nacional"
                    aProcessa[nX,10] := cDireto+cArquivo
                    aProcessa[nX,11] := cArquivo
                Endif
            EndIf

        ElseIf cTipox == "4" // Fatura
            cArquivo := "fatura-" + alltrim(str(Year(dDataBase))) + strzero(month(dDataBase),2,0) + strzero(day(dDataBase),2,0)+alltrim(str(seconds()))
            cArquivo := strtran(cArquivo,".","")
            cArquivo += ".pdf"
            cDireto  := "\relato\"
            LOCR003(.T., cNota, cSerie, cFilAnt, cArquivo, cDireto)
            If File(cDireto+cArquivo)
                aProcessa[nX,9] := STR0012 //"Fatura"
                aProcessa[nX,10] := cDireto+cArquivo
                aProcessa[nX,11] := cArquivo
            Else // DSERLOCA-13040
                LOCA0739(cDireto, "Fatura - Serie: "+alltrim(cSerie)+" NF: "+alltrim(cNota)+" Cliente: "+alltrim(cCliente)+"/"+alltrim(cLoja), "Falha ao gerar o arquivo da fatura atraves da rotina LOCR003. Arquivo nao encontrado: "+cDireto+cArquivo) // DSERLOCA-13040
            Endif
        EndIf

    Next

    // aProcessa contem todos os e-mails que serão disparados
    // faremos a aglutinação dos lançamentos por projeto
    aEmail := {}
    cEmail := ""
    cProjx := ""
    aProcessa := asort(aProcessa,,,{|X,Y| X[3]<Y[3]})
    For nX := 1 to len(aProcessa)
        If aProcessa[nX,1] <> cEmail
            aadd(aEmail,{aProcessa[nX,1],;
                         aProcessa[nX,2],;
                         aProcessa[nX,3],;
                         aProcessa[nX,4],;
                         aProcessa[nX,5],;
                         aProcessa[nX,6],;
                         aProcessa[nX,7],;
                         aProcessa[nX,8],;                  
                         {}})
            aArquivos := {}
            For nY := 1 to len(aProcessa)
                If aProcessa[nY,1] == aProcessa[nX,1]
                    aadd(aArquivos,{aProcessa[nY,9],aProcessa[nY,10],aProcessa[nY,11],aProcessa[nY,14]})
                EndIf
            Next
            aEmail[len(aEmail)][9] := aArquivos
            cEmail := aProcessa[nX,1]
        EndIf
    Next

    For nX := 1 to len(aEmail)

        cEmail := aEmail[nX,1]
        cProjeto := ""
        For nY := 1 to len(aProcessa)
            If aProcessa[nY,1] == aEmail[nX,1]
                If at( alltrim(aProcessa[nY,3]), cProjeto ) <= 0
                    If !empty(cProjeto)
                        cProjeto += ", "
                    EndIF
                    cProjeto += alltrim(aProcessa[nY,3])
                EndIf
            EndIf
        Next

        cCorpo := STR0017 //"Envio de documentos Rental"
        cCorpo += "<p>"
        cCorpo += STR0018+cProjeto //"Projeto: "
        cCorpo += "<p>"
        cCorpo += STR0019 //"Estamos encaminhando no anexo os seguintes arquivos:"
        cCorpo += "<p>"
        aAnexos := {}
        For nY := 1 to len(aEmail[nX,9])

            cCorpo += alltrim(aEmail[nX,9,nY,4])
            cCorpo += "<p>"
            cCorpo += aEmail[nX,9,nY,3] 
            cCorpo += "<p>"
            aadd(aAnexos,aEmail[nX,9,nY,2])

        Next            

        // Emissão dos boletos
        If type("nEnvia") == "C"
            nEnvia := val(substr(nEnvia,1,1))
        EndIf

        If nEnvia == 1
            aEnv := {}
            For nZ := 1 to len(aNotas)

                /*lProcNota := .F.
                For nW := 1 to len(aEmail)
                    If aNotas[nW,2] == aEmail[nX,1]
                        lProcNota := .T.
                        exit
                    EndIf
                Next
                If !lProcNota
                    Loop
                Endif*/

                If aNotas[nZ,2] <> cEmail
                    loop
                EndIf
              
                lEnv := .T.
                For nW := 1 to len(aEnv)
                    If aEnv[nW] == aNotas[nZ,1]
                        lEnv := .F.
                        Exit
                    EndIf
                Next
                If lEnv
                    aadd(aEnv,aNotas[nZ,1])
                EndIf

                If lEnv
                    SF2->(dbGoto(aNotas[nZ,1]))
                    SE1->(dbSetOrder(1))
                    SE1->(dbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC)))
                    While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+SF2->(F2_SERIE+F2_DOC)
                        aPdf := LOCA0737(cDireto)
                        If len(aPdf) > 0
                            cArquivo := aPdf[1,1]
                            cCorpo += STR0029 // "Boleto"
                            cCorpo += "<p>"
                            cCorpo += aPdf[1,1]
                            cCorpo += "<p>"
                            aadd(aAnexos,aPdf[1,2])
                            aadd(aDelBol,aPdf[1,2])
                        EndIf
                        SE1->(dbSkip())
                    EndDo
                EndIf
            Next
        EndIf

        LOCA0735(cEmail, cAssunto, cCorpo, aAnexos, cProjeto)

        // Arquivo com o log do envio
        cArquivo := "DOCENV-" + alltrim(str(Year(dDataBase))) + strzero(month(dDataBase),2,0) + strzero(day(dDataBase),2,0)+"-"+alltrim(str(seconds()))
        cArquivo := strtran(cArquivo,".","")
        cArquivo += ".txt"

        cConteudo := "Data: "+dtoc(dDataBase)+" Horário: "+time() + chr(13) + chr(10)
        cConteudo += "E-mail: "+cEmail + chr(13) + chr(10)
        cConteudo += "Anexos: " + chr(13) + chr(10)
        For nW := 1 to len(aAnexos)
            cConteudo += aAnexos[nW] + chr(13) + chr(10)
        Next
        MemoWrite(cDireto+cArquivo, cConteudo )

    Next

    // Deleção dos arquivos gerados
    For nX := 1 to len(aProcessa)
        If file(aProcessa[nX,10])
            FERASE(aProcessa[nX,10])
        EndIF
        cDel := STR0012 // "Fatura"
        If upper(substr(aProcessa[nX,11],1,6)) == upper(cDel) 
            cDel := strtran(aProcessa[nX,10],".pdf",".rel")   
            If file(cDel)
                FERASE(cDel)
            EndIF
        EndIf
    Next

    // DSERLOCA-13040 - O boleto deve ficar salvo em disco (cDireto) apos o envio, entao a exclusao
    // automatica do arquivo do boleto foi desativada (antes ele era apagado logo apos o e-mail).
    // aDelBol continua sendo preenchido em LOCA0737/LOCA0734 apenas para rastreabilidade, mas nao
    // e mais usado para apagar o arquivo.

Return lRet

/*/{Protheus.doc} LOCA0735
Envio do e-mail
@type function
@version v1  
@author Frank Zwarg Fuga
@since 13/05/2026
/*/

Function LOCA0735(cPara, cAssunto, cCorpo, aAnexos, cProjeto)
Local lEnvioOK 		:= .F.	// Variavel que verifica se foi conectado OK
Local lMailAuth		:= SuperGetMv("MV_RELAUTH",,.F.) // Servidor de email necessita autenticação
Local cMailServer	:= SuperGetMv("MV_RELSERV",, "") // Nome do servidor de email
Local cMailConta	:= SuperGetMV("MV_RELACNT",, "") // Conta no envio de emails
Local cMailSenha	:= SuperGetMV("MV_RELPSW" ,, "") // Senha da conta
Local lUseSSL		:= SuperGetMV("MV_RELSSL" ,,.F.) // utiliza conexão segura
Local lUseTLS		:= SuperGetMV("MV_RELTLS" ,,.F.) // SMTP com conexão segura
Local oMail			:= NIL
Local nErro			:= 0
Local cFrom         := SuperGetMV("MV_RELFROM",,"" ) // email remetente
Local oMessage		:= NIL
Local nPort			:= 0
Local nPortIMAP		:= 0
Local nAt			:= 0
Local cServer		:= ""
Local lErroFile	    := .F.
Local nI
Local cSubject		:= cAssunto
Local cMensagem		:= cCorpo
Local cEmail 		:= cPara
Local aLog          := {}
Local cDescr        := ""
Local nY
Local cRastreio     := ""
Local aProjetos     := {}
Local cTemp
Local lUltimo
Local cCodCli       := ""
Local cLojCli       := ""
Local cProj         := ""
Local cObra         := ""

DEFAULT aFiles 		:= {}
DEFAULT lMensagem 	:= .T.
DEFAULT cError		:= ""
DEFAULT cProjeto    := ""

If (!Empty(cMailServer)) .AND. (!Empty(cMailConta)) .AND. (!Empty(cMailSenha))
	
	oMail := TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	nAt	:=  At(':' , cMailServer)
	
	If ( nAt > 0 )
		cServer		:= SubStr(cMailServer , 1 , (nAt - 1) )
		nPort		:= Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
	Else
		cServer		:= cMailServer
	EndIf
	
	oMail:Init(cServer, cServer, cMailConta, cMailSenha , nPortIMAP , nPort)	

	nErro := oMail:SMTPConnect()
		
	If ( nErro == 0 )

		If lMailAuth
			nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
		Endif
		
		oMessage := TMailMessage():New()
		
		oMessage:Clear()
		
		oMessage:cFrom 		:= cFrom
		oMessage:cTo 		:= cEmail
		oMessage:cCc 		:= ""
		oMessage:cBcc 		:= ""
		oMessage:cSubject 	:= cSubject
		oMessage:cBody 		:= cMensagem

        For nI := 1 To Len( aAnexos )
            oMessage:AttachFile( aAnexos[ nI ] )
        Next nI

		If !lErroFile
			//Envia o e-mail
			nErro := oMessage:Send( oMail )
			
			If nErro == 0
				lEnvioOk	:= .T.
			EndIf
		EndIf
	
		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	EndIf

    // Registro do log dos e-mais enviados
    // Frank em 26/08/2026
    If FindFunction( "LOCA224B1" ) .and. FindFunction( "LOCA086E1" ) 
        If LOCA224B1("FH8_ID", "FH8")

            // Validar quantos projetos estão sendo enviados no LOCA073
            cTemp := ""
            cProjeto := alltrim(cProjeto)
            For nY := 1 to len(cProjeto)
                If substr(cprojeto,nY,1) <> ","
                    cTemp += substr(cprojeto,nY,1)
                Else
                    aadd(aProjetos,alltrim(cTemp))
                    cTemp := ""
                EndIf
            Next
            If len(cProjeto) > 0
                lUltimo := .F.
                For nY := 1 to len(aProjetos)
                    If alltrim(aProjetos[nY]) == alltrim(cTemp)
                        lUltimo := .T.
                        Exit
                    EndIf
                Next
                If !lUltimo
                    aadd(aProjetos,alltrim(cTemp))
                EndIf
            EndIf

            If len(aProjetos) == 1
                FP0->(dbSetOrder(1))
                If FP0->(dbSeek(xFilial("FP0")+aProjetos[1]))
                    cCodCli := FP0->FP0_CLI
                    cLojCli := FP0->FP0_LOJA
                    cProj   := aProjetos[1]
                    cObra   := ""
                EndIF
            EndIf

            /* aLog
            1 - Reservado
            2 - Código do cliente
            3 - Loja do cliente
            4 - Projeto
            5 - Obra
            6 - Data da geração
            7 - Hora da geração
            8 - Código do usuário
            9 - e-Mail
            10 - Origem
            11 - Doc
            12 - Descrição
            13 - Rastreio
            */

            aadd(aLog,"")
            aadd(aLog,cCodCli)
            aadd(aLog,cLojCli)
            aadd(aLog,cProj)
            aadd(aLog,cObra)
            aadd(aLog,dDataBase)
            aadd(aLog,time())
            aadd(aLog,RetCodUsr())
            aadd(aLog,cEmail)
            aadd(aLog,"LOCA073")
            aadd(aLog,"") // código do documento

            cDescr := STR0002+": LOCA073" + Chr(13) + Chr(10) //"Envio dos documentos Rental"
            cDescr += STR0064+cProjeto + Chr(13) + Chr(10) //"Projeto (s): "
            cDescr += STR0065+cSubject + Chr(13) + Chr(10) //"Assunto do e-mail: "
            cDescr += STR0066+cMensagem + Chr(13) + Chr(10) //"Corpo do e-mail: "

            aadd(aLog,cDescr)
                    
            cRastreio := STR0002+": LOCA073" + Chr(13) + Chr(10) //"Envio dos documentos Rental"
            cRastreio += STR0064+cProjeto + Chr(13) + Chr(10) //"Projeto (s): "
            cRastreio += STR0067+dtoc(dDataBase)+" "+time() //"Data: "

            aadd(aLog,cRastreio)

            If LOCA086E1(aLog, .T.  , .F.  , "0000", cEmail, cSubject , cMensagem, aAnexos) // Log do e-mail
                If nErro > 0
                    FH8->(RecLock("FH8",.F.))
                    FH8->FH8_DTENV	:= ctod("")
                    FH8->FH8_HENV	:= ""
                    FH8->FH8_STATUS	:= "2"
                    FH8->(MsUnlock())
                EndIF
            EndIf
        EndIf
    EndIf
	
EndIf

Return( lEnvioOK )

/*/{Protheus.doc} LOCA0736
Rotina para a execução do envio dos e-mails por ExecAuto
@type function
@version v1 
@author Frank Zwarg Fuga
@since 15/05/2026
/*/
Function LOCA0736(aParamAuto, lForca)
Local lRet := .T.
Private lMsErroAuto := .F.
Default aParamAuto := {}
Default lForca := .F.
    
    If len(aParamAuto) == 0 .and. !lForca
        aadd( aParamAuto, "      " )              // Cliente de
        aadd( aParamAuto, "   " )                 // Loja de
        aadd( aParamAuto, "ZZZZZZ" )              // Cliente ate
        aadd( aParamAuto, "ZZ" )                  // Loja até
        aadd( aParamAuto, "               " )     // Produto de
        aadd( aParamAuto, "ZZZZZZZZZZZZZZZ" )     // Produto até
        aadd( aParamAuto, "   " )                 // Obra de
        aadd( aParamAuto, "ZZZ" )                 // Obra até
        aadd( aParamAuto, ctod("01/01/2000") )    // Emissão de
        aadd( aParamAuto, ctod("31/12/2050") )    // Emissão até
        aadd( aParamAuto, 3 )                     // 1=Pendente, 2=Enviado, 3=Ambos
        aadd( aParamAuto, "   " )                 // Série de
        aadd( aParamAuto, "ZZZ" )                 // Série até
        aadd( aParamAuto, 1 )                     // 1=Envia, 2=Não envia
        aadd( aParamAuto, "   " )                 // Documento de
        aadd( aParamAuto, "ZZZ" )                 // Documento até
        aadd( aParamAuto, "2" )                   // NFE somente transmitida
    EndIf
    
    If lForca
        Pergunte("LOCA073",.F.)
        aadd( aParamAuto, MV_PAR01 ) // Cliente de
        aadd( aParamAuto, MV_PAR02 ) // Loja de
        aadd( aParamAuto, MV_PAR03 ) // Cliente ate
        aadd( aParamAuto, MV_PAR04 ) // Loja até
        aadd( aParamAuto, MV_PAR05 ) // Produto de
        aadd( aParamAuto, MV_PAR06 ) // Produto até
        aadd( aParamAuto, MV_PAR07 ) // Obra de
        aadd( aParamAuto, MV_PAR08 ) // Obra até
        aadd( aParamAuto, MV_PAR09 ) // Emissão de
        aadd( aParamAuto, MV_PAR10 ) // Emissão até
        aadd( aParamAuto, MV_PAR11 ) // 1=Pendente, 2=Enviado, 3=Ambos
        aadd( aParamAuto, MV_PAR12 ) // Série de
        aadd( aParamAuto, MV_PAR13 ) // Série até
        aadd( aParamAuto, MV_PAR14 ) // 1=Envia, 2=Não envia
        aadd( aParamAuto, MV_PAR15 ) // Documento de
        aadd( aParamAuto, MV_PAR16 ) // Documento até
        aadd( aParamAuto, "2" ) // NFE somente transmitida
    EndIF
    
    MSExecAuto({|x| LOCA073(x) }, aParamAuto )
    
    If lMsErroAuto
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} LOCA0737
Rotina para a geração dos boletos
Estão posicionados SF2 e SE1
@type function
@version v1 
@author Frank Zwarg Fuga
@since 20/05/2026
/*/
Function LOCA0737(cDireto)
Local lImprime    := .T.
Local cErro       := ""
Local cPortado
Local cBanco
Local cAgencia
Local cConta
Local cLinha
Local cBarra
Local cNosso
Local cCarteira
Local cEspecie
Local cEmissao
Local cVencimento
Local cValor
Local cMoeda
Local cBenNome
Local cBenCNPJ
Local cBenRua
Local cBenNum
Local cBenBairro
Local cBenCidade
Local cBenUF
Local cBenCep
Local cNome
Local cDocumento
Local cRua
Local cNumero
Local cBairro
Local cCidade
Local cUF
Local cCEP
Local cArquivo
Local aRet := {}
Local oBoleto     := Nil // DSERLOCA-13040 - objeto FwMsPrinter usado para desenhar o boleto
Local oFont07     := Nil // DSERLOCA-13040 - fontes utilizadas no desenho do boleto
Local oFont07N    := Nil // DSERLOCA-13040
Local oFont08     := Nil // DSERLOCA-13040
Local oFont09     := Nil // DSERLOCA-13040
Local oFont14N    := Nil // DSERLOCA-13040
Local oFont18N    := Nil // DSERLOCA-13040
Local nLin        := 0   // DSERLOCA-13040 - controla a linha (Y) corrente no desenho
Local nColB       := 032 // DSERLOCA-13040 - margem esquerda do quadro do boleto
Local nColD       := 578 // DSERLOCA-13040 - margem direita do quadro do boleto
Local nTopoFic    := 0   // DSERLOCA-13040 - marca o topo da ficha de compensacao
Local cPathAbs    := ""  // DSERLOCA-13040 - caminho absoluto (com drive) do servidor, exigido pelo FwMsPrinter para gravar o PDF
Local cNumDoc     := ""  // DSERLOCA-13040 - numero do documento sem hifen sobrando quando parcela vazia

    cArquivo := "boleto-"+alltrim(SE1->E1_PREFIXO)+"-"+alltrim(SE1->E1_NUM)
    If !empty(SE1->E1_PARCELA)
        cArquivo += "-"+alltrim(SE1->E1_PARCELA)
    EndIf
    cArquivo += ".pdf"

    // DSERLOCA-13040 - Falha intermitente observada: como o nome do arquivo e fixo por titulo (sem
    // timestamp) e o boleto agora fica salvo em disco (nao e mais apagado apos o envio), uma execucao
    // seguinte pode tentar sobrescrever um arquivo que ainda esta com lock (aberto por outro processo,
    // antivirus, etc.), fazendo o FwMsPrinter falhar silenciosamente ao gravar. Remove o arquivo antigo
    // antes de gerar; se nao conseguir remover (lock), usa um nome alternativo unico para nao colidir.
    //If File(cDireto+cArquivo) // DSERLOCA-13040
    //    FErase(cDireto+cArquivo) // DSERLOCA-13040
        If File(cDireto+cArquivo) // DSERLOCA-13040 - nao conseguiu apagar (arquivo com lock)
            cArquivo := strtran(cArquivo,".pdf","") + "-" + alltrim(str(seconds())) // DSERLOCA-13040
            cArquivo := strtran(cArquivo,".","") + ".pdf" // DSERLOCA-13040
        EndIf // DSERLOCA-13040
    //EndIf // DSERLOCA-13040    

    SA6->(dbSetOrder(1))
    If !SA6->(dbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))) 
        lImprime := .F.
        cErro += "Banco/AG/CC não localizado: "+alltrim(SE1->E1_PORTADO)+" - "+alltrim(SE1->E1_AGEDEP)+" - "+alltrim(SE1->E1_CONTA) + chr(13) + chr(10)
    EndIf

    SEE->(dbSetOrder(1))
    If !SEE->(dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))) 
        lImprime := .F.
        cErro += "Comunicação Remota tabela SEE, não localizada: "+alltrim(SE1->E1_PORTADO)+" - "+alltrim(SE1->E1_AGEDEP)+" - "+alltrim(SE1->E1_CONTA) + chr(13) + chr(10)
    EndIf

    SEA->(dbSetOrder(1))
    If !SEA->(dbSeek(xFilial("SEA")+SE1->(E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
        lImprime := .F.
        cErro += "Não localizado o vínculo com a tabela de títulos enviado ao banco, tabela SEA."
    EndIF

    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

    If lImprime
        cPortado    := alltrim(SE1->E1_PORTADO)
        cBanco      := alltrim(SA6->A6_NOME)
        cAgencia    := alltrim(SE1->E1_AGEDEP)
        cConta      := alltrim(SE1->E1_CONTA)
        cLinha      := alltrim(SE1->E1_CODDIG)
        cBarra      := alltrim(SE1->E1_CODBAR)
        cNosso      := alltrim(SE1->E1_NUMBCO)
        cCarteira   := alltrim(SEE->EE_CODCART)
        cEspecie    := alltrim(SEA->EA_ESPECIE) // DSERLOCA-13040
        If empty(cEspecie) // DSERLOCA-13040
            cEspecie := "NF" // DSERLOCA-13040
        EndIf // DSERLOCA-13040
        cEmissao    := strzero(day(SE1->E1_EMISSAO),2,0)+"/"+strzero(month(SE1->E1_EMISSAO),2,0)+"/"+alltrim(str(year(SE1->E1_EMISSAO))) // DSERLOCA-13040 - corrige dia sem zero a esquerda
        cVencimento := strzero(day(SE1->E1_VENCTO),2,0)+"/"+strzero(month(SE1->E1_VENCTO),2,0)+"/"+alltrim(str(year(SE1->E1_VENCTO))) // DSERLOCA-13040 - corrige dia sem zero a esquerda
        cValor      := alltrim(Transform(SE1->E1_VALOR, "@E 99999999.99"))
        cValor      := StrTran(cValor, ",", ".")
        cMoeda      := "R$"
        cBenNome    := alltrim(SM0->M0_NOME)
        cBenCNPJ    := alltrim(SM0->M0_CGC)
        cBenRua     := alltrim(SM0->M0_ENDENT)
        cBenNum     := ""
        cBenBairro  := alltrim(SM0->M0_BAIRENT)
        cBenCidade  := alltrim(SM0->M0_CIDENT)
        cBenUF      := alltrim(SM0->M0_ESTENT)
        cBenCep     := alltrim(SM0->M0_CEPENT)
        cNome       := alltrim(SA1->A1_NOME)
        cDocumento  := alltrim(SA1->A1_CGC)
        cRua        := alltrim(SA1->A1_END)
        cNumero     := ""
        cBairro     := alltrim(SA1->A1_BAIRRO)
        cCidade     := alltrim(SA1->A1_MUN)
        cUF         := alltrim(SA1->A1_EST)
        cCEP        := alltrim(SA1->A1_CEP)
    EndIf

    If empty(cPortado) 
        lImprime := .F.
        cErro += STR0031 + chr(13) + chr(10) //"Falta o preenchimento do portador. "
    EndIf
    
    If empty(cBanco)
        lImprime := .F.
        cErro += STR0032 + chr(13) + chr(10) //"Falta o preenchimento do banco. "
    EndIf
        
    If empty(cAgencia)
        lImprime := .F.
        cErro += STR0033 + chr(13) + chr(10) //"Falta o preenchimento da agência. "
    EndIf
        
    If empty(cConta)
        lImprime := .F.
        cErro += STR0034+ chr(13) + chr(10) //"Falta o preenchimento da conta. "
    EndIf
        
    If empty(cLinha)
        lImprime := .F.
        cErro += STR0035 + chr(13) + chr(10) //"Falta o preenchimento da linha digitável. "
    EndIf
        
    If empty(cBarra)
        lImprime := .F.
        cErro += STR0036 + chr(13) + chr(10) //"Falta o preenchimento do código de barras. "
    EndIf
        
    If empty(cNosso)
        lImprime := .F.
        cErro += STR0037 + chr(13) + chr(10) //"Falta o preenchimento do nosso número. "
    EndIf
        
    If empty(cCarteira)
        lImprime := .F.
        cErro += STR0038 + chr(13) + chr(10) //"Falta o preenchimento da carteira. "
    EndIf
        
    If empty(cEspecie)
        lImprime := .F.
        cErro += STR0039+ chr(13) + chr(10) //"Falta o preenchimento da espécie. "
    EndIf


    If lImprime // DSERLOCA-13040

        // DSERLOCA-13040 - Geracao do boleto (Ficha de Compensacao) via FwMsPrinter, no padrao FEBRABAN,
        // ao inves de chamada a API/servico externo. O layout usa os mesmos campos ja validados acima,
        // vindos do SE1 (titulo), SEE (carteira), SEA (especie) e SA6 (nome do banco).

        //TRY EXCEPTION // DSERLOCA-13040 - protege TODA a geracao do boleto (fontes, objeto FwMsPrinter, desenho), para que qualquer falha vire log em vez de abortar o lote inteiro
        oFont07  := TFont():New("Arial",,-14,.F.,.F.) // DSERLOCA-13040
        oFont07N := TFont():New("Arial",,-14,.T.,.F.) // DSERLOCA-13040
        oFont08  := TFont():New("Arial",,-16,.F.,.F.) // DSERLOCA-13040
        oFont09  := TFont():New("Arial",,-18,.F.,.F.) // DSERLOCA-13040
        oFont14N := TFont():New("Courier New",,-20,.T.,.T.) // DSERLOCA-13040 - reduzida de -24 para -20: com -24 a linha digitavel (54 caracteres monoespacados) ultrapassava a largura da caixa (~606pt vs ~544pt uteis)
        oFont18N := TFont():New("Arial",,-30,.T.,.F.) // DSERLOCA-13040

        oBoleto := FwMsPrinter():New(cArquivo, IMP_PDF, .F.,, .T.) // DSERLOCA-13040
        oBoleto:SetResolution(72) // DSERLOCA-13040
        oBoleto:SetPortrait() // DSERLOCA-13040
        oBoleto:SetPaperSize(DMPAPER_A4) // DSERLOCA-13040
        oBoleto:SetMargin(20,20,20,20) // DSERLOCA-13040
        // DSERLOCA-13040 - FwMsPrinter exige caminho absoluto (com letra de unidade) para a copia
        // interna do PDF (funcao CpyS2T), mesmo que o resto do Protheus aceite o caminho relativo
        // cDireto ("\relato\") normalmente. Monta o caminho absoluto so para esta atribuicao.
        cPathAbs := GetSrvProfString("ROOTPATH","") // DSERLOCA-13040
        If !empty(cPathAbs) // DSERLOCA-13040
            If right(cPathAbs,1) <> "\" // DSERLOCA-13040
                cPathAbs += "\" // DSERLOCA-13040
            EndIf // DSERLOCA-13040
            cPathAbs += "relato\" // DSERLOCA-13040
        //Else // DSERLOCA-13040
        //    cPathAbs := cDireto // DSERLOCA-13040 - fallback: se nao conseguir resolver o ROOTPATH, mantem o caminho relativo original
        EndIf // DSERLOCA-13040
        oBoleto:cPathPDF := cPathAbs // DSERLOCA-13040
        oBoleto:lServer := .T. // DSERLOCA-13040 - impede a copia do arquivo para o cliente/navegador (evita o dialogo "salvar como" / erro CpyS2T); o PDF fica somente no servidor, em cDireto
        oBoleto:lViewPDF := .F. // DSERLOCA-13040 - garante que nao tenta abrir/visualizar o PDF no cliente

        oBoleto:StartPage() // DSERLOCA-13040

        // DSERLOCA-13040 - Reforcado o espacamento vertical: antes o rotulo (label) ficava a apenas 2
        // unidades da linha divisoria acima dele, e a fonte cruzava/riscava o texto. Agora cada rotulo
        // fica a pelo menos 16 unidades (~12,5pt) da linha, e o valor mais abaixo ainda, com folga.

        // Moldura externa da ficha de compensacao // DSERLOCA-13040
        nTopoFic := 030 // DSERLOCA-13040
        oBoleto:Box(nTopoFic, nColB, nTopoFic+368, nColD, "-4") // DSERLOCA-13040

        // Cabecalho: codigo do banco (linha 1) e linha digitavel (linha 2) // DSERLOCA-13040
        nLin := nTopoFic // DSERLOCA-13040
        oBoleto:Line(nLin+060, nColB, nLin+060, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+018, nColB+002, cPortado+"-"+cBanco, oFont09) // DSERLOCA-13040
        oBoleto:Say(nLin+038, nColB+002, Transform(cLinha,"@R 99999.99999 99999.999999 99999.999999 9 999999999999999"), oFont14N) // DSERLOCA-13040
        nLin += 060 // DSERLOCA-13040

        // Linha: Local de pagamento / Vencimento // DSERLOCA-13040
        oBoleto:Line(nLin+038, nColB, nLin+038, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 450, nLin+038, 450, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Local de Pagamento", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, nColB+002, "Pagável em qualquer banco até o vencimento", oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 452, "Vencimento", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 452, cVencimento, oFont09) // DSERLOCA-13040
        nLin += 038 // DSERLOCA-13040

        // Linha: Beneficiario / Agencia-Conta // DSERLOCA-13040
        oBoleto:Line(nLin+038, nColB, nLin+038, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 450, nLin+038, 450, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Beneficiário", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, nColB+002, cBenNome+" - CNPJ/CPF: "+cBenCNPJ, oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 452, "Agência/Código Cedente", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 452, cAgencia+" / "+cConta, oFont08) // DSERLOCA-13040 - fonte reduzida (oFont09 estourava ~15pt para fora da caixa neste campo, o mais longo da coluna direita)
        nLin += 038 // DSERLOCA-13040

        // Linha: Data doc / Num doc / Especie / Aceite / Carteira / Nosso Numero // DSERLOCA-13040
        oBoleto:Line(nLin+038, nColB, nLin+038, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 130, nLin+038, 130, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 230, nLin+038, 230, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 280, nLin+038, 280, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 330, nLin+038, 330, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 450, nLin+038, 450, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Data do Documento", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, nColB+002, cEmissao, oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 132, "Num. Documento", oFont07) // DSERLOCA-13040
        cNumDoc := alltrim(SE1->E1_NUM) // DSERLOCA-13040
        If !empty(SE1->E1_PARCELA) // DSERLOCA-13040
            cNumDoc += "-"+alltrim(SE1->E1_PARCELA) // DSERLOCA-13040
        EndIf // DSERLOCA-13040
        oBoleto:Say(nLin+030, 132, cNumDoc, oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 232, "Especie", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 232, cEspecie, oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 282, "Aceite", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 282, "N", oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 332, "Carteira", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 332, cCarteira, oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 452, "Nosso Numero", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 452, cNosso, oFont09) // DSERLOCA-13040
        nLin += 038 // DSERLOCA-13040

        // Linha: Instrucoes / Valor do documento // DSERLOCA-13040
        oBoleto:Line(nLin+038, nColB, nLin+038, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Line(nLin, 450, nLin+038, 450, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Instruções - Texto de Responsabilidade do Cedente", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, nColB+002, "Não receber após o vencimento.", oFont08) // DSERLOCA-13040
        oBoleto:Say(nLin+016, 452, "(=) Valor do Documento", oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+030, 452, cMoeda+" "+cValor, oFont09) // DSERLOCA-13040
        nLin += 038 // DSERLOCA-13040

/*
        // Linha: Sacado // DSERLOCA-13040
        oBoleto:Line(nLin+065, nColB, nLin+065, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Sacado", oFont07) // DSERLOCA-13040

        oBoleto:Say(nLin+032, nColB+002, cNome+" - CNPJ/CPF: "+cDocumento, oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+045, nColB+002, cRua, oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+058, nColB+002, cBairro+" - "+cCidade+"/"+cUF+" - CEP: "+cCEP, oFont07) // DSERLOCA-13040
        nLin += 065 // DSERLOCA-13040
*/
        // Linha: Sacado // DSERLOCA-13040
        oBoleto:Line(nLin+078, nColB, nLin+078, nColD, 0, "-4") // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Sacado", oFont07) // DSERLOCA-13040
        
        oBoleto:Say(nLin+030, nColB+002, cNome, oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+043, nColB+002, "CNPJ/CPF: "+cDocumento, oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+056, nColB+002, cRua, oFont07) // DSERLOCA-13040
        oBoleto:Say(nLin+069, nColB+002, cBairro+" - "+cCidade+"/"+cUF+" - CEP: "+cCEP, oFont07) // DSERLOCA-13040
        nLin += 078 // DSERLOCA-13040

        
        // Autenticacao mecanica / codigo de barras // DSERLOCA-13040
        oBoleto:Say(nLin+016, nColB+002, "Autenticação Mecânica / Ficha de Compensação", oFont07) // DSERLOCA-13040
        // DSERLOCA-13040 - Usa o metodo Int25() dedicado (em vez do generico FwMsBar) pois usa o mesmo
        // sistema de coordenadas (nRow/nCol) do Say/Box/Line acima, ja validado. O FwMsBar generico
        // desenhou as barras fora da pagina (Y negativo) e com largura zero neste ambiente.
        //TRY EXCEPTION // DSERLOCA-13040
            oBoleto:Int25(nLin+034, nColB+30, alltrim(cBarra), 0.87, 37, .F., .F., oFont08) // DSERLOCA-13040 - largura calibrada: medicao real ~103mm (padrao FEBRABAN)
       // CATCH EXCEPTION // DSERLOCA-13040
            ///LOCA0739(cDireto, "Boleto - Pref: "+alltrim(SE1->E1_PREFIXO)+" Num: "+alltrim(SE1->E1_NUM)+" Parcela: "+alltrim(SE1->E1_PARCELA)+" Cliente: "+alltrim(SE1->E1_CLIENTE)+"/"+alltrim(SE1->E1_LOJA), "Falha ao desenhar o codigo de barras (metodo Int25). O boleto foi gerado sem o codigo de barras.") // DSERLOCA-13040
        //END TRY // DSERLOCA-13040

        oBoleto:EndPage() // DSERLOCA-13040
        oBoleto:Print() // DSERLOCA-13040 - necessario para efetivamente gravar o PDF em disco (sem isso o FwMsPrinter monta o relatorio em memoria mas nao grava o arquivo)
       // CATCH EXCEPTION // DSERLOCA-13040
        //    LOCA0739(cDireto, "Boleto - Pref: "+alltrim(SE1->E1_PREFIXO)+" Num: "+alltrim(SE1->E1_NUM)+" Parcela: "+alltrim(SE1->E1_PARCELA)+" Cliente: "+alltrim(SE1->E1_CLIENTE)+"/"+alltrim(SE1->E1_LOJA), "Falha ao desenhar o boleto via FwMsPrinter (excecao capturada). O boleto pode nao ter sido gerado/completo para este titulo.") // DSERLOCA-13040
        //END TRY // DSERLOCA-13040

        If ValType(oBoleto) == "O" // DSERLOCA-13040 - so libera se o objeto chegou a ser criado
            FreeObj(oBoleto) // DSERLOCA-13040
        EndIf // DSERLOCA-13040
        Ms_Flush() // DSERLOCA-13040

        // DSERLOCA-13040 - Segunda checagem com pequena espera: em execucoes intermitentes, o arquivo
        // pode ainda nao estar visÃ­vel no disco no instante exato apos o Print()/FreeObj (timing de
        // flush do SO/rede). Antes de declarar falha, aguarda meio segundo e confere novamente.
        If !File(cDireto+cArquivo) // DSERLOCA-13040
            Sleep(500) // DSERLOCA-13040
        EndIf // DSERLOCA-13040

        If File(cDireto+cArquivo) // DSERLOCA-13040
            aadd(aRet,{cArquivo, cDireto+cArquivo}) // DSERLOCA-13040
        Else // DSERLOCA-13040
            LOCA0739(cDireto, "Boleto - Pref: "+alltrim(SE1->E1_PREFIXO)+" Num: "+alltrim(SE1->E1_NUM)+" Parcela: "+alltrim(SE1->E1_PARCELA)+" Cliente: "+alltrim(SE1->E1_CLIENTE)+"/"+alltrim(SE1->E1_LOJA), "Falha ao gerar o PDF do boleto atraves do FwMsPrinter. Arquivo nao encontrado: "+cDireto+cArquivo) // DSERLOCA-13040
        EndIf // DSERLOCA-13040

    Else // DSERLOCA-13040
        LOCA0739(cDireto, "Boleto - Pref: "+alltrim(SE1->E1_PREFIXO)+" Num: "+alltrim(SE1->E1_NUM)+" Parcela: "+alltrim(SE1->E1_PARCELA)+" Cliente: "+alltrim(SE1->E1_CLIENTE)+"/"+alltrim(SE1->E1_LOJA), cErro) // DSERLOCA-13040
    EndIf // DSERLOCA-13040

Return aRet


/*/{Protheus.doc} LOCA0739 // DSERLOCA-13040
@author 
Grava log de erro para dar visibilidade ao motivo pelo qual o boleto ou a fatura nao foi gerado/enviado // DSERLOCA-13040
@type function // DSERLOCA-13040
@param cDireto, character, diretorio de destino do arquivo de log // DSERLOCA-13040
@param cChave, character, identificacao do documento (nota/serie ou titulo/parcela) // DSERLOCA-13040
@param cMotivo, character, motivo do erro ocorrido // DSERLOCA-13040
@version v1 // DSERLOCA-13040
@since 24/07/2026 // DSERLOCA-13040
/*/ // DSERLOCA-13040
Function LOCA0739(cDireto, cChave, cMotivo) // DSERLOCA-13040
Local cArqErro  := "" // DSERLOCA-13040
Local cConteudo := "" // DSERLOCA-13040

    cArqErro := "ERRO-" + alltrim(str(Year(dDataBase))) + strzero(month(dDataBase),2,0) + strzero(day(dDataBase),2,0) + "-" + alltrim(str(seconds())) // DSERLOCA-13040
    cArqErro := strtran(cArqErro,".","") // DSERLOCA-13040
    cArqErro += ".txt" // DSERLOCA-13040

    cConteudo := "Data: " + dtoc(dDataBase) + " Horario: " + time() + chr(13) + chr(10) // DSERLOCA-13040
    cConteudo += "Documento: " + cChave + chr(13) + chr(10) // DSERLOCA-13040
    cConteudo += "Motivo: " + chr(13) + chr(10) // DSERLOCA-13040
    cConteudo += cMotivo + chr(13) + chr(10) // DSERLOCA-13040

    MemoWrite(cDireto+cArqErro, cConteudo) // DSERLOCA-13040

    // DSERLOCA-13040 - Alem do .txt individual, acumula no log agregado (cLog, Private) que sera
    // exibido/aberto automaticamente ao final do processamento, no padrao usado pelo LOCA105.
    cLog += "Documento: " + cChave + chr(13) + chr(10) // DSERLOCA-13040
    cLog += "Motivo: " + cMotivo + chr(13) + chr(10) + chr(13) + chr(10) // DSERLOCA-13040

Return // DSERLOCA-13040


/*/{Protheus.doc} LOCA073
Seleção do tipo de xml sped nacional
@type function
@version v1 
@author Frank Zwarg Fuga
@since 19/05/2026
/*/
Function LOCA0738
Local cTitulo:=""
Local MvPar
Local MvParDef:=""
Local nTam	:= 0
Local aArea := GetArea()

Private aSit:={}
Default lTipoRet := .T.

	IF lTipoRet
		MvPar:=Rtrim(&(Alltrim(ReadVar())))	
		mvRet:=Alltrim(ReadVar())
		nTam := Len(&mvRet)
	EndIf

	aSit := {"1 - " + STR0022,; //"NF não transmitida"
			 "2 - " + STR0023,; //"NF autorizada"
			 "3 - " + STR0024,; //"NF transmitida"
			 "4 - " + STR0025,; //"NF uso denegado"
			 "5 - " + STR0026,; //"NF não autorizada"
             "6 - " + STR0028; //"Ambos"
            } 

    MvParDef:="123456"
    cTitulo := STR0027 //"Situação"

	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49, .T.)  // Chama funcao f_Opcoes
			&MvRet := mvpar                                                                          // Devolve Resultado
			If nTam > Len(aSit)
				&MvRet += Replicate("*",nTam-Len(aSit))
			EndIf
		EndIf
	EndIf

    RestArea(aArea)


Return( IF( lTipoRet , .T. , MvParDef ) )
