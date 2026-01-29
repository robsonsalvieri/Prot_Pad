#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI86.CH"

Static _oDN2    := Nil
//-- Mapa do vetor aIteJSon
//-- 01 - Registro ao qual o registro principal é item
//-- 02 - JSon
//-- 05 - Código da fonte de integração
//-- 04 - Código do registro
//-- 05 - Prioridade
//-- 06 - Tipo de Envio
//-- 07 - EndPoint
//-- 08 - Retorno dos recnos agrupados

/*{Protheus.doc} TMSAI86()
Funcao de Job Envio Coleta entrega (Envio)

@author     Carlos A. Gomes Jr.
@since      22/06/2022
*/
Function TMSAI86()
    FWMsgrun(,{|| TMSAI86AUX()}, STR0005, STR0006 )
RETURN

/*{Protheus.doc} TMSAI86()
Funcao auxiliar do Job Envio Coleta entrega (Envio)
@author     Carlos A. Gomes Jr.
@since      18/08/2022
*/
Function TMSAI86AUX(cProcess,cURLBase, aAliasPro)
    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()
    Local aAlias    := {}
    Local nN        := 0
    Local cJSon     := ""
    Local aResult   := {}
    Local cIDExt    := ""
    Local cErroInt  := ""
    Local cFuncPre  := ""
    Local lExecAlt  := .F.
    Local oColEnt As Object
    Local cProcAtu  := ""
    Local lTipEnv   := DN2->(ColumnPos("DN2_TIPENV"))>0
    Local lIteReg   := DN2->(ColumnPos("DN2_ITEREG")) > 0
    Local lDefEsp   := DN1->(ColumnPos("DN1_DEFESP")) > 0
    Local lVerboAl  := DN2->(ColumnPos("DN2_VERBOA")) > 0

    Local nCntFor1  := 0
    Local nCntFor2  := 0
    Local lJSonAgr  := .F.
    Local cProcAnt  := ""
    Local aCodFon   := {}
    Local nCodFon   := 0

    Local aIteJson  := {}

    DEFAULT cProcess := ""
    DEFAULT cURLBase := ""
    DEFAULT aAliasPro:= {}

    If Len(aAliasPro) == 0
        //COLETA ENTREGA
        If AliasInDic("DN1")
            AAdd(aAlias,"DN1")
        EndIf

        //PORTAL LOGISTICO
        If AliasInDic("DND")
            AAdd(aAlias,"DND")
        EndIf
        
        // YMS
        If AliasInDic("DNS")
            AAdd(aAlias,"DNS")
        EndIf

        // Agendamento
        If AliasInDic("DNT")
            AAdd(aAlias,"DNT")
        EndIf

        //HERE
        If AliasInDic("DNM")
            AAdd(aAlias,"DNM")
        EndIf
    Else
        aAlias := AClone(aAliasPro)
        FwFreeArray(aAliasPro)
    EndIf

    If LockByName("TM86JbLoop",.T.,.T.)
        For nN := 1 To Len(aAlias)
            If aAlias[nN] == "DN1" .And. lDefEsp
                aCodFon := {"01","03","04","05","10","11","12"}
            Else
                aCodFon := {""}
            Endif
            For nCodFon := 1 To Len(aCodFon)
                oColEnt := TMSBCACOLENT():New( aAlias[nN], aCodFon[nCodFon] )
                If oColEnt:DbGetToken() 
                    (oColEnt:Alias_Config)->(DbGoTo(oColEnt:config_recno))
                    DNC->(DbSetOrder(1))

                    cQuery := "SELECT DN5.DN5_CODFON, DN5.DN5_PROCES, DN2.DN2_PRIORI, DN4.R_E_C_N_O_ DN4REC, DN5.R_E_C_N_O_ DN5REC, DN2.R_E_C_N_O_ DN2REC "
                    cQuery += "FROM "+RetSQLName("DN5")+" DN5 "
                    cQuery += "INNER JOIN "+RetSQLName("DN4")+" DN4 ON "
                    cQuery += "  DN4.DN4_FILIAL = '"+xFilial("DN4")+"' AND "
                    cQuery += "  DN4.DN4_CODFON = DN5.DN5_CODFON AND "
                    cQuery += "  DN4.DN4_CODREG = DN5.DN5_CODREG AND "
                    cQuery += "  DN4.DN4_CHAVE  = DN5.DN5_CHAVE AND "
                    cQuery += "  DN4.D_E_L_E_T_ = '' "
                    cQuery += "INNER JOIN "+RetSQLName("DN2")+" DN2 ON  "
                    cQuery += "  DN2.DN2_FILIAL = '"+xFilial("DN2")+"' AND  "
                    cQuery += "  DN2.DN2_CODFON = DN5.DN5_CODFON AND  "
                    cQuery += "  DN2.DN2_CODREG = DN5.DN5_CODREG AND  "
                    cQuery += "  DN2.D_E_L_E_T_ = ''  "
                    cQuery += "WHERE "
                    cQuery += "DN5.DN5_FILIAL = '"+xFilial("DN5")+"' AND "
                    cQuery += "DN5.DN5_FILORI = '"+cFilAnt+"' AND "
                    cQuery += "DN5.DN5_STATUS = '2' AND "
                    cQuery += "DN5.DN5_SITUAC = '1' AND "
                    If !Empty(cProcess)
                        cQuery += "DN5.DN5_PROCES = '" + cProcess + "' AND "
                    EndIf
                    If oColEnt:codfon == "01"
                        cQuery += "( DN5.DN5_CODFON = '" + oColEnt:codfon + "' OR DN5.DN5_CODFON = '06' ) AND "
                    Else
                        cQuery += "DN5.DN5_CODFON = '" + oColEnt:codfon + "' AND "
                    Endif
                    cQuery += "DN5.D_E_L_E_T_ = '' "
                    cQuery += "ORDER BY DN5.DN5_CODFON, DN5.DN5_PROCES, DN2.DN2_PRIORI "

                    cQuery := ChangeQuery(cQuery)
                    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

                    aIteJSon := {}
                    
                    Begin Transaction
                        Do While !(cAliasQry)->(Eof())

                            DN2->(DbGoTo((cAliasQry)->DN2REC))
                            DN4->(DbGoTo((cAliasQry)->DN4REC))
                            DN5->(DbGoTo((cAliasQry)->DN5REC))

                            If (cAliasQry)->DN5_CODFON + (cAliasQry)->DN5_PROCES != cProcAnt
                                cProcAnt := (cAliasQry)->DN5_CODFON + (cAliasQry)->DN5_PROCES
                            EndIf

                            lJSonAgr := !Empty( If( lIteReg, DN2->DN2_ITEREG, "" ) )
                            If lIteReg .AND. !lJSonAgr
                                lJSonAgr := IsJSonAgr( DN5->DN5_CODFON, DN2->DN2_CODREG )
                            EndIf

                            If !Empty(cProcAtu) .And. DN5->DN5_PROCES == cProcAtu .And. !Empty(cErroInt)
                                RecLock("DN5",.F.)
                                DN5->DN5_STATUS := '7' //-- Erro Processo
                                DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + DtoC(dDataBase) + "-" + Time() + CRLF + cErroInt + CRLF + CRLF
                                MsUnLock()
                                If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                                    RecLock("DNC", .F.)
                                    DNC->DNC_STATUS := '3' //-- Erro Envio
                                    DNC->DNC_DATULT := dDataBase
                                    DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                                    MsUnlock()
                                EndIf
                                (cAliasQry)->(DbSkip())
                                Loop
                            ElseIf !Empty(cProcAtu) .And. DN5->DN5_PROCES != cProcAtu
                                If !Empty(aIteJSon)
                                    //-- Existe item nos layouts, então o sistema irá tratar o 
                                    //-- Json de forma diferenciada.
                                    aIteJSon := Tmsai86JIt(Aclone(aIteJSon))

                                    For nCntFor1 := 1 To Len(aIteJSon)
                                        cJSon     := aIteJSon[nCntFor1,2]
                                        cEndPoint := aIteJSon[nCntFor1,7]
                                        If aIteJSon[nCntFor1,6] == "2"	//-- Parâmetros
                                            If (aResult := oColEnt:Get(AllTrim(cEndPoint),AllTrim(cJson),,DN5->DN5_PROCES,DN2->DN2_CODPRC))[1]
                                                aResGet := Aclone(aResult[2])
                                            Else
                                                TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        Else	//-- Corpo
                                            If (aResult := oColEnt:Post( cEndPoint, cJson, ,DN5->DN5_PROCES ))[1]
                                                cIDExt := aResult[2]
                                            Else
                                                TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        EndIf
                                        For nCntFor2 := 1 To Len(aIteJSon[nCntFor1,8])
                                            If nCntFor2 == 1
                                                cErroInt := TMSAC30GEr()
                                            EndIf
                                            Atualiza( cIdExt, aIteJSon[nCntFor1,8,nCntFor2,1], aIteJSon[nCntFor1,8,nCntFor2,2], .T., cErroInt, aAlias[nN] )
                                            DN5->(GrvHeranca(DN5_CODFON,DN5_CODREG,DN5_SEQUEN))
                                        Next nCntFor2
                                    Next nCntFor1

                                    aIteJSon := {}

                                EndIf
                                cProcAtu := DN5->DN5_PROCES
                            Else
                                cProcAtu := DN5->DN5_PROCES
                            EndIf

                            cErroInt := ""
                            cIDExt   := ""
                            lExecAlt := .T.

                            If !Empty(DN2->DN2_GETFUN)
                                aLayout   := DN5->(BscLayout(DN5_CODFON,DN5_CODREG))
                                aConteudo := DN5->(QuebraReg(DN5_CODFON,DN5_CODREG,DN5_SEQUEN,AClone(aLayout)))
                                cFuncPre  := StrTran(AllTrim(DN2->DN2_GETFUN),"()","(oColEnt,AClone(aLayout),AClone(aConteudo),@lExecAlt)")
                                cIDExt    := &(cFuncPre)
                            EndIf
                            If Empty(cURLBase)
                                cURLBase := &(aAlias[nN] + "->" + aAlias[nN] + "_URLAPP")
                            EndIf

                            If Empty(cIDExt)
                                cJSon := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, DN2->DN2_BASE, DN5->DN5_CONTEU, .F., Iif(lTipEnv,(DN2->DN2_TIPENV $ " 1"),.F.) )
                                cEndPoint := &(AllTrim(DN2->DN2_ENDPNT))
                                cEndPoint := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, cEndPoint, DN5->DN5_CONTEU, .T., Iif(lTipEnv,(DN2->DN2_TIPENV $ " 1"),.F.) )
                                If !Empty(cEndPoint)
                                    If lJSonAgr
                                        If (Iif(lTipEnv,DN2->DN2_TIPENV,"1")) == "2"	//-- Parâmetros
                                            If lIteReg
                                                If !Empty(DN2->DN2_ITEREG)
                                                    If (nLinha := Ascan(aIteJson,{|x| x[1] == DN2->DN2_ITEREG})) == 0
                                                        Aadd(aIteJSon,{Iif(lIteReg,DN2->DN2_ITEREG,"") ,AllTrim(cJSon),DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_PRIORI,;
                                                                    Iif(lTipEnv,DN2->DN2_TIPENV,"1"),cEndPoint,{{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC}}})
                                                    Else
                                                        aIteJson[nLinha,2] += AllTrim(cJSon)
                                                        Aadd(aIteJSon[nLinha,8],{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC})
                                                    EndIf
                                                Else
                                                    If (nLinha := Ascan(aIteJson,{|x| x[1] == DN2->DN2_CODREG})) > 0
                                                        If At("#@",cJSon) > 0
                                                            Aadd(aIteJSon,{Iif(lIteReg,DN2->DN2_ITEREG,"") ,AllTrim(cJSon),DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_PRIORI,;
                                                                        Iif(lTipEnv,DN2->DN2_TIPENV,"1"),cEndPoint,{{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC}}})
                                                        Else
                                                            aIteJSon[nLinha,2] := cJSon + aIteJson[nLinha,2]
                                                            Aadd(aIteJSon[nLinha,8],{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC})
                                                        EndIf
                                                    EndIf
                                                EndIf
                                            EndIf
                                        Else	//-- Corpo
                                            Aadd(aIteJSon,{ Iif(lIteReg,DN2->DN2_ITEREG,"") , AllTrim(cJSon), DN2->DN2_CODFON, DN2->DN2_CODREG, DN2->DN2_PRIORI,;
                                                            Iif(lTipEnv,DN2->DN2_TIPENV,"1"), cEndPoint, { { (cAliasQry)->DN4REC, (cAliasQry)->DN5REC } } } )
                                        EndIf
                                    Else
                                        If (Iif(lTipEnv,DN2->DN2_TIPENV,"1")) == "2"	//-- Parâmetros
                                            If (aResult := oColEnt:Get(AllTrim(cEndPoint),AllTrim(cJson),,DN5->DN5_PROCES,DN2->DN2_CODPRC))[1]
                                                aResGet := Aclone(aResult[2])
                                            Else
                                                TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        Else	//-- Corpo
			                            If (aResult := oColEnt:Post( cEndPoint, cJson, ,DN5->DN5_PROCES ))[1]
                                                cIDExt := aResult[2]
                                            Else
                                                TMSAC30Err( "TMSAI86003", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        EndIf

                                    EndIf
                                EndIf
                            ElseIf !Empty(DN2->DN2_ALTPNT) .And. lExecAlt
                                cJSon := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, DN2->DN2_ALTERN, DN5->DN5_CONTEU, .F., Iif(lTipEnv,(DN2->DN2_TIPENV $ " 1"),.F.) )
                                cEndPoint := &(AllTrim(DN2->DN2_ALTPNT))
                                cEndPoint := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, cEndPoint, DN5->DN5_CONTEU, .T., Iif(lTipEnv,(DN2->DN2_TIPENV $ " 1"),.F.) )
                                cEndPoint := StrTran(cEndPoint,"#IDEXT#",cIDExt)
                                cJSon     := StrTran(cJSon,"#IDEXT#",cIDExt)
                                If !Empty(cEndPoint)
                                    If lJSonAgr
                                        If (Iif(lTipEnv,DN2->DN2_TIPENV,"1")) == "2"	//-- Parâmetros
                                            If lIteReg
                                                If !Empty(DN2->DN2_ITEREG)
                                                    If (nLinha := Ascan(aIteJson,{|x| x[1] == DN2->DN2_ITEREG})) == 0
                                                        Aadd(aIteJSon,{Iif(lIteReg,DN2->DN2_ITEREG,"") ,AllTrim(cJSon),DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_PRIORI,;
                                                                    Iif(lTipEnv,DN2->DN2_TIPENV,"1"),cEndPoint,{{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC}}})
                                                    Else
                                                        aIteJson[nLinha,2] += AllTrim(cJSon)
                                                    EndIf
                                                Else
                                                    If (nLinha := Ascan(aIteJson,{|x| x[1] == DN2->DN2_CODREG})) > 0
                                                        If At("#@",cJSon) > 0
                                                            Aadd(aIteJSon,{Iif(lIteReg,DN2->DN2_ITEREG,"") ,AllTrim(cJSon),DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_PRIORI,;
                                                                        Iif(lTipEnv,DN2->DN2_TIPENV,"1"),cEndPoint,{{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC}}})
                                                        Else
                                                            aIteJSon[nLinha,2] := cJSon + aIteJson[nLinha,2]
                                                            Aadd(aIteJSon[nLinha,8],{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC})
                                                        EndIf
                                                    EndIf
                                                EndIf
                                            EndIf
                                        Else	//-- Corpo
                                            Aadd(aIteJSon,{Iif(lIteReg,DN2->DN2_ITEREG,"") ,AllTrim(cJSon),DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_PRIORI,;
                                                        Iif(lTipEnv,DN2->DN2_TIPENV,"1"),cEndPoint,{{(cAliasQry)->DN4REC,(cAliasQry)->DN5REC}}})
                                        EndIf
                                    Else
                                        If (Iif(lTipEnv,DN2->DN2_TIPENV,"1")) == "2"	//-- Parâmetros
                                            If (aResult := oColEnt:Get(AllTrim(cEndPoint),AllTrim(cJson),,DN5->DN5_PROCES,DN2->DN2_CODPRC))[1]
                                                aResGet := Aclone(aResult[2])
                                            Else
                                                TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        Else	//-- Corpo
                                            If lVerboAl .And. DN2->DN2_VERBOA == "1"
                                                If !(aResult := oColEnt:Put( cEndPoint, cJson ))[1]
                                                    TMSAC30Err( "TMSAI86006", oColEnt:last_error, oColEnt:desc_error )
                                                EndIf
                                            ElseIf !(aResult := oColEnt:Post( cEndPoint, cJson, ,DN5->DN5_PROCES ))[1]
                                                TMSAC30Err( "TMSAI86004", oColEnt:last_error, oColEnt:desc_error )
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                            
                            If !lJSonAgr
                                If Atualiza(cIdExt,(cAliasQry)->DN4REC,(cAliasQry)->DN5REC,,@cErroInt)
                                    DN5->(GrvHeranca(DN5_CODFON,DN5_CODREG,DN5_SEQUEN))
                                EndIf
                            EndIf
        
                            (cAliasQry)->(DbSkip())
                        EndDo

                        If !Empty(aIteJSon)
                            //-- Existe item nos layouts, então o sistema irá tratar o 
                            //-- Json de forma diferenciada.
                            aIteJSon := Tmsai86JIt(Aclone(aIteJSon))

                            For nCntFor1 := 1 To Len(aIteJSon)
                                cJSon     := aIteJSon[nCntFor1,2]
                                cEndPoint := aIteJSon[nCntFor1,7]
                                If aIteJSon[nCntFor1,6] == "2"	//-- Parâmetros
                                    If (aResult := oColEnt:Get(AllTrim(cEndPoint),AllTrim(cJson),,DN5->DN5_PROCES,DN2->DN2_CODPRC))[1]
                                        aResGet := aResult[2]
                                    Else
                                        TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                    EndIf
                                Else	//-- Corpo
                                    If (aResult := oColEnt:Post( cEndPoint, cJson, ,DN5->DN5_PROCES ))[1]
                                        cIDExt := aResult[2]
                                    Else
                                        TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                                    EndIf
                                EndIf
                                If Len(aIteJSon) >= nCntFor1
                                    For nCntFor2 := 1 To Len(aIteJSon[nCntFor1,8])
                                        If nCntFor2 == 1
                                            cErroInt := TMSAC30GEr()
                                        EndIf
                                        Atualiza( cIdExt, aIteJSon[nCntFor1,8,nCntFor2,1], aIteJSon[nCntFor1,8,nCntFor2,2], .T., cErroInt, aAlias[nN] )
                                        DN5->(GrvHeranca(DN5_CODFON,DN5_CODREG,DN5_SEQUEN))
                                    Next nCntFor2
                                EnDIf
                            Next nCntFor1

                            aIteJSon := {}

                        EndIf

                    End Transaction
                    (cAliasQry)->(DbCloseArea())
                EndIf
                FWFreeObj(oColEnt)
            Next
        Next
        UnLockByName("TM86JbLoop", .T., .T.)
    EndIf
    FWFreeObj(oColEnt)
    
Return aResult

/*{Protheus.doc} TMSAI86VCL()
Retorna Vetor com os dados do cliente

@author     Carlos A. Gomes Jr.
@since      01/04/2022
*/
Function TMSAI86VCL( aDocEnd, nCli )
Local aRet    := {}
Local aEndNum := { "", "", "", "" }
Local aEstado := {}

    If !Empty(aDocEnd[nCli][06]) .Or. nCli == 5 .Or. aDocEnd[nCli][14] == "SM0"
	    aEstado := FWGetSX5( "12", aDocEnd[nCli][05] )
	    If Len(aEstado) == 0 .Or. Len(aEstado[1]) < 4 .Or. Empty(aEstado[1][4])
	        aEstado := { { "", "12", aDocEnd[nCli][05], aDocEnd[nCli][05] } }
	    EndIf
	
	    If !Empty(aDocEnd[nCli][01])
	        aEndNum := FisGetEnd(aDocEnd[nCli][01])
        EndIf
		
	    AAdd(aRet, aDocEnd[nCli][10] )                                          //01 - CGC
	    AAdd(aRet, aDocEnd[nCli][09] )                                          //02 - Nome
	    AAdd(aRet, Iif(aDocEnd[nCli][11] == 'J',aDocEnd[nCli][08],"") )         //03 - Nome Fantasia
	    AAdd(aRet, AClone(aDocEnd[nCli][12]) )                                  //04 - Pais
	    AAdd(aRet, { AllTrim(aDocEnd[nCli][05]), AllTrim(aEstado[1][4]) } )     //05 - Estado
	    AAdd(aRet, AllTrim(aDocEnd[nCli][04]) )                                 //06 - Municipio
	    AAdd(aRet, AllTrim(aDocEnd[nCli][02]) )                                 //07 - Bairro
	    AAdd(aRet, AllTrim(aEndNum[1]) )                                        //08 - Logradouro
	    AAdd(aRet, AllTrim(aEndNum[3]) )                                        //09 - Numero
	    AAdd(aRet, AllTrim(aEndNum[4]) )                                        //10 - Complemento
	    AAdd(aRet, Left(aDocEnd[nCli][03],5)+"-"+Right(aDocEnd[nCli][03],3) )   //11 - CEP
	    AAdd(aRet, aDocEnd[nCli][13])                                           //12 - Telefone
	    AAdd(aRet, aDocEnd[nCli][06]+aDocEnd[nCli][07])                         //13 - Código+Loja
	    AAdd(aRet, Iif(aDocEnd[nCli][11] == 'J',"CNPJ","CPF") )                 //14 - Tipo Documento
	Else
        AAdd(aRet, "" )             //01 - CGC
        AAdd(aRet, "" )             //02 - Nome
        AAdd(aRet, "" )             //03 - Nome Fantasia
        AAdd(aRet, { "", "" } )     //04 - Pais
        AAdd(aRet, { "", "" } )     //05 - Estado
        AAdd(aRet, "" )             //06 - Municipio
        AAdd(aRet, "" )             //07 - Bairro
        AAdd(aRet, "" )             //08 - Logradouro
        AAdd(aRet, "" )             //09 - Numero
        AAdd(aRet, "" )             //10 - Complemento
        AAdd(aRet, "" )             //11 - CEP
        AAdd(aRet, "" )             //12 - Telefone
        AAdd(aRet, "" )             //13 - Código+Loja
        AAdd(aRet, "" )             //14 - Tipo Documento
    EndIf
    
    FwFreeArray(aEstado)
    FwFreeArray(aEndNum)

Return aRet

/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()
Local aParam := { "P",;       //Tipo R para relatorio P para processo
                  "",;        //Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;     //Alias
                  ,;          //Array de ordens
                  STR0002 }   //Descrição do Schedule
Return aParam

/*{Protheus.doc} Tmsai86JIt
Retorna array com os JSon e EndPoint quando a estrutura de layouts possui registros que são itens de outros registros
@type Function
@author Valdemar Roberto Mognon
@since 16/02/2024
*/
Function Tmsai86JIt(aVetJSon)
Local nLinSeq    := 1		//-- Variável de loop no vetor
Local nItemPai   := 0		//-- Item pai
Local nPosMac    := 0		//-- Posição da macro
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nLinha     := 0
Local cJSonFil   := ""		//-- JSon filho
Local cJSonPai   := ""		//-- JSon pai
Local aNewJSon   := {}
Local aVetWrk    := {}

Default aVetJSon := {}

//-- Concatena registros iguais
For nCntFor1 := 1 To Len(aVetJSon)
	If (nLinha := Ascan(aNewJSon,{|x| x[4] == aVetJSon[nCntFor1,4]})) == 0
		aVetWrk := {}
		For nCntFor2 := 1 To Len(aVetJSon[nCntFor1])
			Aadd(aVetWrk,aVetJSon[nCntFor1,nCntFor2])
		Next nCntFor2
		Aadd(aNewJSon,Aclone(aVetWrk))
	Else
		Aadd(aNewJSon[nLinha,8],{aVetJSon[nCntFor1,8,1,1],aVetJSon[nCntFor1,8,1,2]})
		aNewJSon[nLinha,2] := aNewJSon[nLinha,2] + "," + aVetJSon[nCntFor1,2]
	EndIf
Next nCntFor1

//-- Monta JSon final
aVetJSon := Aclone(aNewJSon)
While nLinSeq <= Len(aVetJSon)

	If !Empty(aVetJSon[nLinSeq,1])
		cJSonFil := aVetJSon[nLinSeq,2]

		nItemPai := Ascan(aVetJSon,{|x| "#@" + aVetJSon[nLinSeq,4] + "@#" $ x[2]})
		
		If nItemPai > 0
			cJSonPai := aVetJSon[nItemPai,2]
			nPosMac := At("#@" + aVetJSon[nLinSeq,4] + "@#",cJSonPai)
			If nPosMac > 0
				cJSonPai := SubStr(cJSonPai,1,nPosMac - 1) + cJSonFil + SubStr(cJSonPai,nPosMac + 8)
				aVetJSon[nItemPai,2] := cJSonPai
                For nCntFor1 := 1 To Len(aVetJSon[nLinSeq,8])
                    Aadd(aVetJSon[nItemPai,8],{aVetJSon[nLinSeq,8,nCntFor1,1],aVetJSon[nLinSeq,8,nCntFor1,2]})
				Next nCntFor1
                Adel(aVetJSon,nLinSeq)
				Asize(aVetJSon,Len(aVetJSon) - 1)
				nLinSeq := nLinSeq - 1
			EndIf
		EndIf
	EndIf
    nLinSeq := nLinSeq + 1
EndDo

FwFreeArray(aVetWrk)
FwFreeArray(aNewJSon)

Return Aclone(aVetJSon)

/*{Protheus.doc} Atualiza as tabelas de integração
Atualiza as tabelas de relação entre chaves Protheus/externo e da tabela de histórico de integrações
@type Static Function
@author Valdemar Roberto Mognon
@since 23/04/2024
*/
Static Function Atualiza( cIdExt, nRecDN4, nRecDN5, lJsonAgr, cErroInt, cAlias )
Local aAreas := {DNC->(GetArea()),DN4->(GetArea()),DN5->(GetArea()),GetArea()}
Local lDNP   := FWAliasInDic("DNP", .F.)
Local aAreaDNP := IIf(lDNP, DNP->(GetArea()), {})

Default cIdExt      := ""
Default nRecDN4     := 0
Default nRecDN5     := 0
Default lJsonAgr    := .F.
Default cErroInt    := ""
Default cAlias      := ""

If nRecDN4 > 0 .And. nRecDN5 > 0
	DN4->(DbGoTo(nRecDN4))
	DN5->(DbGoTo(nRecDN5))
    If !lJsonAgr
	    cErroInt := TMSAC30GEr()
    EndIf
	If !Empty(cErroInt)
		RecLock("DN5",.F.)
		DN5->DN5_STATUS := '3' //-- Erro Envio
		DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + cErroInt
		MsUnLock()
		cErroInt := STR0003 + DN5->DN5_CODREG + STR0004 + DN5->DN5_SEQUEN + "." + CRLF + CRLF
		If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
			RecLock("DNC", .F.)
			DNC->DNC_STATUS := '3' //-- Erro Envio
			DNC->DNC_DATULT := dDataBase
			DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
			MsUnlock()
		EndIf
	ElseIf DN5->DN5_CODFON != "06" .Or. !Empty(cIDExt)
		RecLock("DN4",.F.)
		If !Empty(cIDExt)
			DN4->DN4_IDEXT  := cIDExt
		EndIf
		DN4->DN4_STATUS := '1' //-- Integrado
		MsUnLock()
		RecLock("DN5",.F.)
		If !Empty(cIDExt)
			DN5->DN5_IDEXT  := cIDExt
		EndIf
		DN5->DN5_STATUS := '1' //-- Integrado
		DN5->DN5_SITUAC := '2' //-- Enviado
		DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + DtoC(dDataBase) + "-" + Time() + CRLF + STR0001 + CRLF + CRLF
		MsUnLock()
		If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
			RecLock("DNC", .F.)
			DNC->DNC_STATUS := '1' //-- Integrado
			DNC->DNC_SITUAC := '2' //-- Enviado
			DNC->DNC_DATULT := dDataBase
			DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
			MsUnlock()
		EndIf
		//-- Atualiza planejamento Here
        If cAlias == "DNM" .And. lDNP
            DNP->(DbSetOrder(1))
            If DNP->(DbSeek(xFilial("DNP") + SubStr(DN5->DN5_PROCES,8,TamSx3("DNP_CODIGO")[1]))) .And. ;
                    DNP->DNP_STATUS != StrZero(3,Len(DNP->DNP_STATUS))
                RecLock("DNP",.F.)
                DNP->DNP_STATUS := StrZero(1,Len(DNP->DNP_STATUS))
                DNP->(MsUnlock())
            EndIf

        EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

If lDNP
    RestArea(aAreaDNP)
EndIf

Return Empty(cErroInt)

Static Function IsJSonAgr( cCodFon, cCodReg )

Local cQuery    := ""
Local cAliasDN2 := ""
Local lRet      := .F.

Default cCodfon := ""
Default cCodReg := ""

    cAliasDN2 := GetNextAlias()

    If _oDN2 == Nil
        cQuery := " SELECT 1 "
        cQuery += " FROM " + RetSqlName("DN2") + " DN2 "
        cQuery += " WHERE DN2.DN2_FILIAL = ? "
        cQuery +=	" AND DN2.DN2_CODFON = ? "
        cQuery += 	" AND DN2.DN2_ITEREG = ? "
        cQuery +=	" AND DN2.D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)

        _oDN2 := FWPreparedStatement():New()
        _oDN2:SetQuery(cQuery)

    EndIf

    _oDN2:SetString( 1, xFilial("DN2")  )
    _oDN2:SetString( 2, cCodFon         )
    _oDN2:SetString( 3, cCodReg         )
    
    cQuery  := _oDN2:GetFixQuery()

    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDN2, .F., .T. )

    If !(cAliasDN2)->( Eof() )
        lRet := .T.
    EndIf

    (cAliasDN2)->(DbCloseArea())

Return lRet
