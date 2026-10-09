#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} MEU POSTO DE TRABALHO

serviços utilizados pelo aplicativo Meu Posto de Trabalho

@author     Diego Bezerra
@since      23/11/2025
/*/
//------------------------------------------------------------------------------

WSRESTFUL MEUPOSTODETRABALHO DESCRIPTION "Meu Posto de Trabalho"
    WSDATA cpf AS STRING
    WSDATA cAttendant AS STRING
    WSDATA cPswd AS STRING

    WSMETHOD PUT fotofunc DESCRIPTION "Atualização de foto do funcionário" PATH "fotofunc" PRODUCES APPLICATION_JSON
    WSMETHOD GET validfunc DESCRIPTION 'Verifica se o funcionário possui um contrato ativo' PATH "validfunc" PRODUCES APPLICATION_JSON
    WSMETHOD GET login  DESCRIPTION 'Login do atendente' PATH "login" PRODUCES APPLICATION_JSON 
END WSRESTFUL


WSMETHOD GET login WSRECEIVE cAttendant, cPswd WSREST MEUPOSTODETRABALHO

    Local lRet              := .T.
    Local cTemp             := GetNextAlias()
    Local cResponse		    := '{ "attendant":[], "count": 0 }'
    Local cMessage          := "Internal Server Error"
    Local nStatusCode       := 500
    Local cDescExp          := ""

    // define o tipo de retorno do método
    ::SetContentType("application/json")

    If Empty(Self:cAttendant)
        lRet := .F.
        cMessage := "Informe o usuário"
    EndIf

    If lRet .And. Empty(Self:cPswd)
        lRet := .F.
        cMessage := "informe a senha para o usuário" 
    EndIf

    If !Empty(Self:cAttendant) .And. !Empty(Self:cPswd)

        BeginSQL Alias cTemp
            
            SELECT 
                AA1_CODTEC, AA1_NOMTEC
            FROM 	
                %Table:AA1% AA1
            WHERE 
                AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND
                AA1.AA1_NREDUZ = %Exp:Self:cAttendant% AND
                AA1.AA1_SENHA = %Exp:Self:cPswd% AND
                AA1.%NotDel%
        EndSql

        If ( cTemp )->( !Eof() )

            lRet := .T.

            //-------------------------------------------------------------------
            // Posiciona no primeiro registro.
            //-------------------------------------------------------------------
            ( cTemp )->( DBGoTop() )

            cResponse	:= ""
            cResponse	+= '{ "attendant": '

            cResponse += '{"codtec":"' + ( cTemp )->AA1_CODTEC + '",'
            If CaracEsp(EncodeUTF8(( cTemp )->AA1_NOMTEC),@cDescExp)
                cResponse += '"nomtec":"' + cDescExp + '"}'
            Else
                cResponse += '"nomtec":"' + EncodeUTF8(( cTemp )->AA1_NOMTEC) + '"}'
            EndIf    
            cResponse += ' } '

            nStatusCode	:= 200
        Else
            lRet := .T.
            nStatusCode := 200
            cMessage 	:= "Usuário e senha inválidos" 
        EndIf
        (cTemp)->(dbCloseArea())
    Else
        nStatusCode	:= 400
        cMessage 	:= "necessario informar os parametros de usuario e senha do atendente" //"Necessario informar os parametros de usuario e senha do atendente"
    EndIf

    If lRet
        Self:SetResponse( cResponse )
    Else
        SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
    EndIf

Return lRet

WSMETHOD GET validfunc WSRECEIVE cpf WSSERVICE MEUPOSTODETRABALHO
    Local cTmp          := GetNextAlias()
    Local cQry          := ""
    Local oQry          := Nil
    Local cpf           := ""
    Local cResponse     := '0'
    Local lFirst        := .T.

    ::SetContentType("application/json;charset=UTF-8")

    If !Empty(::cpf)
        cpf := ::cpf
    EndIf

    cQry := " SELECT RA_MAT, RA_CIC, R_E_C_N_O_ "
    cQry += " FROM " + retSqlName("SRA")
    cQry += " WHERE RA_CIC = '" + cpf + "'"
    cQry += " AND RA_DEMISSA = ' '"
    cQry += " AND D_E_L_E_T_ = ' '"

    oQry := FwPreparedStatement():New(cQry)
    cQry := oQry:GetFixQuery()
    MPSysOpenQuery(cQry, cTmp)
    
    cResponse := '{"results":['
    
    If !(cTmp)->(Eof())
        lFirst := .T.
        While !(cTmp)->(Eof())
            If !lFirst
                cResponse += ","
            EndIf
            lFirst := .F.
            cResponse += '{'
            cResponse +=    '"matricula":"' + StrTran(StrTran(StrTran(ALLTRIM((cTmp)->RA_MAT), '"', '\"'), Chr(13), ''), Chr(10), ' ') + '",'
            cResponse +=    '"cpf":"' + StrTran(StrTran(StrTran(ALLTRIM((cTmp)->RA_CIC), '"', '\"'), Chr(13), ''), Chr(10), ' ') + '",'
            cResponse +=    '"RECNO":' + ALLTRIM(STR((cTmp)->R_E_C_N_O_))
            cResponse += '}'
            (cTmp)->(DbSkip())
        EndDo
    EndIf
    
    cResponse += ']}'

    (cTmp)->(DbCloseArea())

    ::SetResponse(cResponse)

Return .T.


WSMETHOD PUT fotofunc WSREST MEUPOSTODETRABALHO

    Local lRet          := .T.
    Local cBody         := ""
    Local oOppJson      := Nil
    Local nStatusCode   := 200
    Local cMessage	    := "Sucesso"
    Local cResponse     := ""
    Local cFotoBase64   := ""
    Local cErrorMsg     := ""
    Local aRecnos       := {}
    Local nRecno        := 0
    Local nPos          := 0
    Local nQtdSucesso   := 0
    Local nQtdErro      := 0
    Local aErros        := {}
    Local oRecnosJson   := Nil

    //BEGIN SEQUENCE
        Self:SetContentType("application/json;charset=UTF-8")

        cBody := Self:GetContent()
        
        If Empty(cBody)
            lRet := .F.
            nStatusCode := 400
            cMessage := "Body da requisicao vazio"
        Else
           // BEGIN SEQUENCE
                FWJsonDeserialize(cBody, @oOppJson)
           // RECOVER USING oErrorJson
           //     lRet := .F.
           //     nStatusCode := 400
           //     cMessage := "Erro ao deserializar JSON"
           //     If ValType(oErrorJson) == "O"
           //         cMessage += ": " + oErrorJson:Description
           //     EndIf
           // END SEQUENCE
            
                If lRet .And. oOppJson <> Nil
                cFotoBase64 := If(ValType(oOppJson:fotoBase64) == "C", AllTrim(oOppJson:fotoBase64), "")
                oRecnosJson := If(ValType(oOppJson:recnos) == "A", oOppJson:recnos, Nil)
                
                If Empty(cFotoBase64)
                    lRet := .F.
                    nStatusCode := 400
                    cMessage := "Foto em base64 nao informada"
                ElseIf oRecnosJson == Nil .Or. Len(oRecnosJson) == 0
                    lRet := .F.
                    nStatusCode := 400
                    cMessage := "Array de RECNOs nao informado ou vazio"
                Else
                    // Converte o array de RECNOs para array numérico
                    For nPos := 1 To Len(oRecnosJson)
                        If ValType(oRecnosJson[nPos]) == "N"
                            AAdd(aRecnos, oRecnosJson[nPos])
                        ElseIf ValType(oRecnosJson[nPos]) == "C"
                            nRecno := Val(oRecnosJson[nPos])
                            If nRecno > 0
                                AAdd(aRecnos, nRecno)
                            EndIf
                        EndIf
                    Next
                    
                    // If Len(aRecnos) == 0
                    //     lRet := .F.
                    //     nStatusCode := 400
                    //     cMessage := "Nenhum RECNO valido encontrado no array"
                    //     ConOut("TECM090 - PUT fotofunc - Erro: Nenhum RECNO valido")
                    // Else
                        // Processa cada RECNO
                        For nPos := 1 To Len(aRecnos)
                            nRecno := aRecnos[nPos]
                            //BEGIN SEQUENCE
                                cErrorMsg := sendFotoByRecno(nRecno, cFotoBase64)
                                //If !Empty(cErrorMsg)
                                //    nQtdErro++
                                //    AAdd(aErros, "RECNO " + AllTrim(Str(nRecno)) + ": " + cErrorMsg)
                                //Else
                                    nQtdSucesso++
                                //EndIf
                            // RECOVER USING oErrorRecno
                            //     nQtdErro++
                            //     cErrorMsg := "Erro ao processar foto: " + IIf(ValType(oErrorRecno) == "O", oErrorRecno:Description, "Desconhecido")
                            //     AAdd(aErros, "RECNO " + AllTrim(Str(nRecno)) + ": " + cErrorMsg)
                            // END SEQUENCE
                        Next
                        
                        // // Monta resposta com resultado
                        // If nQtdErro > 0 .And. nQtdSucesso == 0
                        //     lRet := .F.
                        //     nStatusCode := 500
                        //     cMessage := "Nenhuma foto foi atualizada"
                        // ElseIf nQtdErro > 0
                        //     lRet := .F.
                        //     nStatusCode := 500
                        //     cMessage := "Algumas fotos nao foram atualizadas"
                        // Else
                                lRet := .T.
                                cMessage := "Foto atualizada com sucesso"
                        // EndIf

                    //EndIf
                EndIf
            // ElseIf oOppJson == Nil
            //     lRet := .F.
            //     nStatusCode := 400
            //     cMessage := "Erro ao processar JSON - objeto nulo"
            //     ConOut("TECM090 - PUT fotofunc - Erro: oOppJson e nulo")
            EndIf
        EndIf

        If lRet
            cResponse := '{"successCode":200,"successMessage":"' + StrTran(StrTran(StrTran(cMessage, '"', '\"'), Chr(13), ''), Chr(10), ' ') + '"}'
            Self:SetResponse(EncodeUTF8(cResponse))
        Else
            SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
        EndIf

    // RECOVER USING oError
    //     lRet := .F.
    //     nStatusCode := 500
    //     cMessage := "Erro interno no servidor"
    //     If ValType(oError) == "O"
    //         cMessage += ": " + oError:Description
    //         ConOut("TECM090 - PUT fotofunc - Erro geral (exception): " + oError:Description + " | " + oError:ErrorStack)
    //     Else
    //         ConOut("TECM090 - PUT fotofunc - Erro geral (exception): Erro desconhecido")
    //     EndIf
    //     SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
    // END SEQUENCE

    If oOppJson <> Nil
        FreeObj(oOppJson)
    EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} sendFotoByRecno
Atualiza a foto do funcionário na tabela SRA usando o RECNO

@param nRecno, numerico, RECNO do funcionÃ¡rio na tabela SRA
@param cFotoBase64, caracter, Foto em base64

@return cErrorMsg, caracter, String vazia se sucesso, mensagem de erro caso contrario
/*/
//------------------------------------------------------------------------------
Static Function sendFotoByRecno(nRecno, cFotoBase64)

    Local cEntryName   := ""
    Local cTempPath    := ""
    Local cTempFile    := ""
    Local cBase64Data  := ""
    Local cMimeType    := ""
    Local cFileExt     := ".JPG"
    Local xFotoDecoded := ""
    Local nPosBase     := 0
    Local cEntryRet    := ""
    Local nHandle      := 0
    Local aAreaSRA     := SRA->(GetArea())
    Local oBmpRepo     := Nil
    Local lIncluiu     := .F.
    Local cErrorMsg    := ""
    Local nTamBmp      := TamSX3("RA_BITMAP")[1]
    Local cMatricula   := ""
    Local cFilialReg   := ""
    Local lEncontrado  := .F.

    If nRecno <= 0
        RestArea(aAreaSRA)
        Return "RECNO invalido"
    EndIf

    //BEGIN SEQUENCE
        // Posiciona no registro pelo RECNO
        DbSelectArea("SRA")
        SRA->(DbGoTo(nRecno))
        // Verifica se o posicionamento foi bem-sucedido
        If SRA->(RecNo()) != nRecno .Or. SRA->(Eof())
            RestArea(aAreaSRA)
            Return "Registro nao encontrado para o RECNO informado"
        EndIf

        // Verifica se o funcionário está demitido
        If !Empty(SRA->RA_DEMISSA)
            RestArea(aAreaSRA)
            Return "Nao e possivel atualizar fotos para funcionarios demitidos"
        EndIf

        lEncontrado := .T.
        cMatricula := AllTrim(SRA->RA_MAT)
        cFilialReg := AllTrim(SRA->RA_FILIAL)

        cBase64Data := AllTrim(cFotoBase64)

        If Upper(SubStr(cBase64Data,1,5)) == "DATA:"
            nPosBase := At("base64,", Lower(cBase64Data))
            If nPosBase > 0
                cMimeType := Lower(SubStr(cBase64Data, 6, nPosBase - 6))
                cBase64Data := SubStr(cBase64Data, nPosBase + Len("base64,"))
            EndIf
        EndIf

        If "image/png" $ cMimeType
            cFileExt := ".PNG"
        ElseIf "image/bmp" $ cMimeType
            cFileExt := ".BMP"
        Else
            cFileExt := ".JPG"
        EndIf

        cBase64Data := StrTran(StrTran(cBase64Data, Chr(13), ""), Chr(10), "")

        cEntryName := FWGrpCompany() + cFilialReg + cMatricula
        cEntryName := Upper(Left(cEntryName, nTamBmp))

        cTempPath  := GetSrvProfString("StartPath", "")
        If Right(cTempPath,1) <> "\"
            cTempPath += "\"
        EndIf
        cTempPath += "TEMP\"

        If !ExistDir(cTempPath)
            MakeDir(cTempPath)
        EndIf

        cTempFile := cTempPath + cEntryName + cFileExt

        nHandle   := FCreate(cTempFile)
        // If nHandle <= 0
        //     cErrorMsg := "Erro ao criar arquivo temporario: " + cTempFile + " - FCreate retornou: " + AllTrim(Str(nHandle))
        //     BREAK
        // EndIf

        //BEGIN SEQUENCE
            xFotoDecoded := Decode64(cBase64Data)
            FWrite(nHandle, xFotoDecoded)
        //RECOVER USING oDecErr
        //    cErrorMsg := "Erro ao decodificar imagem base64 e salvar no arquivo temporario: " + ;
        //                 IIf(ValType(oDecErr) == "O", oDecErr:Description, "Desconhecido")
        //END SEQUENCE

        FClose(nHandle)

        // If !Empty(cErrorMsg)
        //     BREAK
        // EndIf

        oBmpRepo := FWBmpRep():New()
        oBmpRepo:OpenRepository()
        // If !oBmpRepo:OpenRepository()
        //     cErrorMsg := "Nao foi possivel abrir o repositorio de imagens."
        //     BREAK
        // EndIf
        oBmpRepo:DeleteBmp(cEntryName)
        // If oBmpRepo:ExistBmp(cEntryName)
        //     oBmpRepo:DeleteBmp(cEntryName)
        // EndIf

        cEntryRet  := oBmpRepo:InsertBmp(cTempFile, cEntryName, @lIncluiu)
        // If !Empty(cEntryRet)
        //     cEntryName := cEntryRet
        // EndIf

        oBmpRepo:CloseRepository()

        // If !lIncluiu
        //     cErrorMsg := "Nao foi possivel incluir a foto no repositorio."
        //     BREAK
        // EndIf

        If File(cTempFile)
            FErase(cTempFile)
        EndIf

        // Posiciona novamente no registro e atualiza
        DbSelectArea("SRA")
        SRA->(DbGoTo(nRecno))
        // Verifica se o posicionamento foi bem-sucedido
        If SRA->(RecNo()) == nRecno .And. !SRA->(Eof())
            RecLock("SRA", .F.)
                SRA->RA_BITMAP := cEntryName
            SRA->(MsUnlock())
        // Else
        //     cErrorMsg := "Erro ao posicionar no registro para atualizar RA_BITMAP"
        //     BREAK
        EndIf

    //RECOVER USING oError
    //    cErrorMsg := "Erro ao processar foto: " + IIf(ValType(oError) == "O", oError:Description, "Desconhecido")
        // If ValType(oError) == "O"
        //     ConOut("TECM090 - sendFotoByRecno - Stack trace: " + oError:ErrorStack)
        // EndIf
    //END SEQUENCE

    RestArea(aAreaSRA)

    Return cErrorMsg
