#INCLUDE "loca073.ch" 
#include "totvs.ch"
#include "topconn.ch"
#Include "fwmvcdef.ch"
#Include "RESTFUL.CH"
#Include "PcoTryException.ch"

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

Default aParamAuto := {}

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
        If !Pergunte("LOCA073", .T.)
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
        cNfe     := "2" //MV_PAR17
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
        If M->FPC_TPENV <> "1" // Específico
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
        If !M->FPC_TPENV $ ("01234")
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
        xRetorno += ( "4=" + STR0009    	) // "Fatura"
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
Local cDireto
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

        If !lAuto
            IncProc( STR0003 + alltrim(str(nX)) + STR0004 + alltrim(str(len(aProcessa))) ) //"Registro: "###" de: "
            ProcessMessage()
            SysRefresh()
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

            If MV_PAR17 == "1" //"NF não transmitida"
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
            If FindFunction( "U_NFSEXMLNAC" )

                If MV_PAR17 == "1" //"NF não transmitida"
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
                EndIf

                aRet := u_nfseXmlNac(cTipo, dEmiss, cSerie, cNota, cCliente, cLoja, "",aAIDF, "", cAmbiente)
            EndIf

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
            Endif
        EndIf

    Next

    // aProcessa contem todos os e-mails que serão disparados
    // faremos a aglutinação dos lançamentos por projeto
    aEmail := {}
    cEmail := ""
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

        LOCA0735(cEmail, cAssunto, cCorpo, aAnexos)

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

    // Exclusão dos boletos
    For nX := 1 to len(aDelBol)
        If file(aDelBol[nX])
            FERASE(aDelBol[nX])
        EndIf
    Next

Return lRet

/*/{Protheus.doc} LOCA0735
Envio do e-mail
@type function
@version v1  
@author Frank Zwarg Fuga
@since 13/05/2026
/*/

Function LOCA0735(cPara, cAssunto, cCorpo, aAnexos)
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

DEFAULT aFiles 		:= {}
DEFAULT lMensagem 	:= .T.
DEFAULT cError		:= ""

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
Local cUrl        := "https://us-central1-plataformasaas1.cloudfunctions.net/api/relatorios/boleto/render" 
Local cPayload    := "" // Corpo da requisição (JSON)
Local cResponse   := "" // Variável que receberá o retorno
Local cError      := "" // Variável para tratamento de erro
Local aHeadOut    := {} // Headers da requisição
Local nTimeOut    := 30 // Tempo limite em segundos
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
Local nX
Local cBase64
Local lIni1
Local nIni := 0
Local nHandle := 0
Local nRet := 0
Local cArquivo
Local aRet := {}

    cArquivo := "boleto-"+alltrim(SE1->E1_PREFIXO)+"-"+alltrim(SE1->E1_NUM)
    If !empty(SE1->E1_PARCELA)
        cArquivo += "-"+alltrim(SE1->E1_PARCELA)
    EndIf
    cArquivo += ".pdf"

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
        cEspecie    := alltrim(SEA->EA_ESPECIE)
        cEmissao    := alltrim(str(year(SE1->E1_EMISSAO)))+"-"+alltrim(strzero(month(SE1->E1_EMISSAO),2,0))+"-"+alltrim(str(day(SE1->E1_EMISSAO)))
        cVencimento := alltrim(str(year(SE1->E1_VENCTO)))+"-"+alltrim(strzero(month(SE1->E1_VENCTO),2,0))+"-"+alltrim(str(day(SE1->E1_VENCTO)))
        cValor      := alltrim(Transform(SE1->E1_VALOR, "@E 99999999.99"))
        cValor      := StrTran(cValor, ",", ".")
        cMoeda      := "BRL"
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


    If lImprime
        cPayload := '{'
        cPayload += '"boleto": {'
        cPayload += '"banco": {'
        cPayload += '"codigo": "'+cPortado+'",'
        cPayload += '"nome": "'+cBanco+'"'
        cPayload += '},'
        cPayload += '"titulo": {'
        cPayload += '"linha_digitavel": "'+cLinha+'",' 
        cPayload += '"codigo_barras": "'+cBarra+'",' 
        cPayload += '"nosso_numero": "'+cNosso+'",' 
        cPayload += '"carteira": "'+cCarteira+'",' 
        cPayload += '"especie_documento": "'+cEspecie+'",' 
        cPayload += '"aceite": "N",'
        cPayload += '"data_emissao": "'+cEmissao+'",' 
        cPayload += '"data_vencimento": "'+cVencimento+'",'
        cPayload += '"valor": '+cValor+','
        cPayload += '"moeda": "'+cMoeda+'",'
        cPayload += '"valor_documento": '+cValor
        cPayload += '},'
        cPayload += '"beneficiario": {'
        cPayload += '"nome": "'+cBenNome+'",'
        cPayload += '"cnpj": "'+cBenCNPJ+'",'
        cPayload += '"endereco": {'
        cPayload += '"logradouro": "'+cBenRua+'",'
        cPayload += '"numero": "'+cBenNum+'",'
        cPayload += '"bairro": "'+cBenBairro+'",'
        cPayload += '"cidade": "'+cBenCidade+'",'
        cPayload += '"uf": "'+cBenUF+'",'
        cPayload += '"cep": "'+cBenCEP+'"'
        cPayload += '},'
        cPayload += '"agencia": "'+cAgencia+'",'
        cPayload += '"conta": "'+cConta+'"'
        cPayload += '},'
        cPayload += '"pagador": {'
        cPayload += '"nome": "'+cNome+'",'
        cPayload += '"documento": "'+cDocumento+'",'
        cPayload += '"endereco": {'
        cPayload += '"logradouro": "'+cRua+'",'
        cPayload += '"numero": "'+cNumero+'",'
        cPayload += '"bairro": "'+cBairro+'",'
        cPayload += '"cidade": "'+cCidade+'",'
        cPayload += '"uf": "'+cUF+'",'
        cPayload += '"cep": "'+cCEP+'"'
        cPayload += '}'
        cPayload += '}'
        cPayload += '}'
        cPayload += '}'
    EndIf

    // Adiciona os headers necessários para a API
    AAdd(aHeadOut, "Content-Type: application/json")
    AAdd(aHeadOut, "x-boleto-senha: BOL@RENTAL12")

    // Executa a requisição HTTPS POST
    //cResponse := HTTPSPost(cUrl, cPayload, aHeadOut, @cError, nTimeOut)
    cResponse := HTTPSPost(cUrl, "", "", "", "", cPayload, nTimeOut, aHeadOut, @cError)

    // Avalia o resultado
    If substr(cResponse,12,7) == "success"
        cBase64 := ""
        lIni1 := .F.
        nIni := 0
        For nX := 1 to len(cResponse)
            If substr(cResponse,nX,13) == 'pdf_base64":"'
                lIni1 := .T.
                nIni := nX + 12
            EndIf
            If substr(cResponse,nX,10) == '","pdf_url'
                lIni1 := .F.
            EndIf

            If lIni1 .and. nX > nIni .and. substr(cResponse,nX,1) <> '"'
                cBase64 += substr(cResponse,nX,1)
            EndIf

        Next

        If !empty(cBase64)

            aBytes := StrTokArr(cBase64, ",")
            cBinario := ""

            For nX := 1 To Len(aBytes)
                cBinario += Chr( Val(AllTrim(aBytes[nX])) )
            Next

            nHandle := FCreate(cDireto+cArquivo)
            If nHandle > 0
                nRet := FWrite(nHandle, cBinario)
                FClose(nHandle)
                aadd(aRet,{cArquivo, cDireto+cArquivo})
            EndIf

        EndIF

    EndIf

Return aRet


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



