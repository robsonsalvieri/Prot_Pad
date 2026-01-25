#INCLUDE "PROTHEUS.CH"

Static cMHQ         := ""
Static cMIQ         := ""
Static cProcessos   := ""
Static nQtdReg      := 600

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiEnviaPdv
Função principal para chamada das threads por grupo

@type    function
@param 	 cEmpAmb,   Caractere, Empresa
@param 	 cFilAmb,   Caractere, Filial
@param 	 cGrupos,   Caractere, Grupos que serão considerados para gravar a MIP
@param 	 cTempoMax, Caractere, Configuração do tempo para permanecer a thread ativa
@author  Bruno Almeida
@since   04/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiEnviaPdv(cEmpAmb, cFilAmb, cTempoMax, cGrupos)

Local nX            := 0
Local cHoraInicio   := Time()
Local aGrupos       := {}

Default cTempoMax   := "00:05:00"
Default cGrupos     := ""

//Limita a 15m para a thread não ficar muito tempo sem desativar e limpar a memoria
if cTempoMax > "00:15:00"
    cTempoMax := "00:15:00"
endIf

If !Empty(cEmpAmb) .AND. !Empty(cFilAmb) .AND. !Empty(cGrupos)
    
    RpcSetType(3)
    RpcSetEnv(cEmpAmb, cFilAmb, , ,"LOJA")

    If FwBulk():CanBulk()

        LjGrvLog("RMIEnviaPdv", "JOB RMIEnviaPdv iniciado:", {cEmpAmb, cFilAmb, cGrupos, cTempoMax})

        If !LockByName("RMIENVIAPDV" + cGrupos, .T./*lEmpresa*/, .F./*lFilial*/)
            LjGrvLog("RMIEnviaPdv", "Serviço RMIENVIAPDV já esta sendo utilizado por outra instância.")
            RpcClearEnv()
            Return Nil
        EndIf

        aGrupos := StrTokArr(cGrupos, ",")

        While !KillApp() .AND. ElapTime(cHoraInicio, Time()) <= cTempoMax

            For nX := 1 To Len(aGrupos)
            
                //Verifica se tem registros para processar para o grupo
                if grupoTemReg(aGrupos[nX])

                    startJob("RmiGeraMip", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aGrupos[nX], cTempoMax, cGrupos )
                    sleep(1000)
                endIf

            Next nX

            sleep(5000)
        EndDo
        
        UnLockByName("RMIENVIAPDV" + cGrupos, .T./*lEmpresa*/, .F./*lFilial*/)
        LjGrvLog("RMIEnviaPdv", "JOB RMIEnviaPdv finalizado:", {cEmpAmb, cFilAmb, cGrupos, cTempoMax})

    Else
        LjGrvLog("RMIEnviaPdv", "Esse ambiente não esta preparado para trabalhar com a classe FwBulk, necessario rever a atualização do dbAccess e Lib conforme a documentação https://tdn.totvs.com/display/public/framework/FWBulk")
    EndIf

Else
    LjGrvLog("RMIEnviaPdv", "Não foram informados os parâmetros de empresa e filial na configuração do JOB RMIEnviaPdv")
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiGeraMip
Serviço para alimentar a tabela MIP por PDV para cada uma das publicações MHQ

@type    function
@param 	 cEmpAmb,   Caractere, Empresa
@param 	 cFilAmb,   Caractere, Filial
@param 	 cGrupos,   Caractere, Grupos que serão considerados para gravar a MIP
@param 	 cTempoMax, Caractere, Configuração do tempo para permanecer a thread ativa
@author  Bruno Almeida
@since   04/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiGeraMip(cEmpMip, cFilMip, cGrupo, cTempoMax, cGrupos)

Local nTamCProce    := 0
Local nTamChvUni    := 0
Local nTamPdv       := 0
Local cFilPub       := ""
Local cAliasMhq     := ""
Local aMiq          := ""
Local nX            := 0
Local oFwBulk       := Nil
Local aStruct       := {}
Local cFiltroUpd    := ""
Local cStatus       := ""
Local cFiltroDel    := ""
Local nContador     := 0
Local aProcessos    := {}
Local nProc         := 0

RpcSetType(3)
RpcSetEnv(cEmpMip, cFilMip, , ,"LOJA")

LjGrvLog("RMIGERAMIP", "Inicio da thread do grupo " + cGrupo)
if LockByName("RMIGERAMIP" + cGrupo, .T./*lEmpresa*/, .F./*lFilial*/)

    aStruct     := StructMip()
    nTamCProce  := TamSx3("MIP_CPROCE")[1]
    nTamChvUni  := TamSx3("MIP_CHVUNI")[1]
    nTamPdv     := TamSx3("MIP_PDV")[1]

    cMHQ        := RetSqlName("MHQ")
    cMIQ        := RetSqlName("MIQ")
    aProcessos  := RetProcesso(cGrupo)

    dbSelectArea("MIP")

    aMiq := ConsMiq()

    If Len(aMiq) > 0
        
        oFwBulk := FwBulk():New(RetSqlName("MIP"), nQtdReg)
        oFwBulk:SetFields(aStruct)

        for nProc:=1 to len(aProcessos)
            
            cProcessos := aProcessos[nProc]

            MipStatus4(aMiq)

            cAliasMhq := ConsMhq(cProcessos, "1")
            
            While !(cAliasMhq)->( Eof() )

                MHQ->(dbGoTo((cAliasMhq)->REC))
                cFilPub := AllTrim(MHQ->MHQ_IDEXT)

                For nX := 1 To Len(aMiq)

                    MIQ->(dbGoTo(aMiq[nX][1]))

                    If Empty(cFilPub) .OR. SubStr( MIQ->MIQ_FILPC, 1, Len(cFilPub) ) == cFilPub

                        ljGrvLog("RMIEnviaPdv", "Processando a publicação... do ponto de carga...:", {cProcessos, MHQ->MHQ_UUID, MIQ->MIQ_FILPC, MIQ->MIQ_COD})

                        nContador++

                        If nContador == 1
                            //-- Monta o filtro para deletar os registros na MIP antes de inclui-los novamente
                            cFiltroDel += "'" + MHQ->MHQ_CHVUNI + "',"

                            //-- Monta o filtro para fazer a atualização de status na MHQ
                            cFiltroUpd += "'" + MHQ->MHQ_UUID + "',"
                        EndIf

                        If (oFwBulk:Count()) == nQtdReg
                            DelMip(cFiltroDel, cProcessos)
                        EndIf

                        oFwBulk:AddData({MIQ->MIQ_FILPC,MHQ->MHQ_CPROCE,MHQ->MHQ_CHVUNI,"",Date(),TimeFull(),CtoD(""),"","1",FwUUID("MIP" + DtoS(MIP->MIP_DATGER) + MIP->MIP_HORGER),MHQ->MHQ_UUID,"",MIQ->MIQ_COD,"0"})

                        If oFwBulk:Count() == 0
                    
                            If !Empty(oFwBulk:GetError())
                                cStatus := "4"
                                LjGrvLog("RMIEnviaPdv", "Erro ao fazer a inserção dos registros pelo FWBulk, status sera atualizado para 4 na MHQ.", oFwBulk:GetError())
                                Exit
                            Else
                                cStatus := "2"

                                UpdMhq(cFiltroUpd, cStatus) 

                                cFiltroDel  := ""
                                cFiltroUpd  := ""   
                                nContador   := 0
                                cStatus     := ""

                            EndIf

                        EndIf

                    EndIf

                Next nX

                If cStatus == "4"

                    UpdMhq(cFiltroUpd, cStatus)                   

                    cFiltroDel  := ""
                    cFiltroUpd  := ""                 

                EndIf
                
                cStatus     := ""
                nContador   := 0
            
                (cAliasMhq)->( DbSkip() )
            EndDo

            If oFwBulk:Count() > 0
                DelMip(cFiltroDel, cProcessos)
                oFwBulk:Close()

                If !Empty(oFwBulk:GetError())
                    cStatus := "4"
                Else
                    cStatus := "2"
                EndIf

                UpdMhq(cFiltroUpd, cStatus)

            EndIf
            
            cFiltroDel  := ""
            cFiltroUpd  := ""
            nContador   := 0

            (cAliasMhq)->( DbCloseArea() )
        next nProc
        
        oFwBulk:Destroy()
        oFwBulk := Nil

    Else
        LjGrvLog("RMIEnviaPdv", "Gravação da tabela MIP não efetuada porque não existem pontos de integração ativos no cadastros.")
    EndIf
else
    ljGrvLog("RMIGERAMIP", "Grupo já esta em execução por outra thread.", {cGrupo})
endIf

UnLockByName("RMIGERAMIP" + cGrupo, .T./*lEmpresa*/, .F./*lFilial*/)
LjGrvLog("RMIGERAMIP", "Fim da thread do grupo " + cGrupo)

FwFreeArray(aMiq)
fwFreeArray(aProcessos)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsMhq
Função para filtrar os registros da tabela MHQ.

@type    function
@param 	 cProcessos, Caractere, Parâmetro opcional, quando informado filtra na MHQ somente os processos que estão no parâmetro.
@author  Bruno Almeida
@since   04/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsMhq(cProcessos, cStatus)

Local cQueryMhq  := ""
Local cAlias     := GetNextAlias()
Local cBanco     := AllTrim( Upper( TcGetDB() ) )
Local aFilsProce := rmixFilial("TOTVS PDV", cProcessos, "1")
Local cTabela    := posicione("MHN", 1, xFilial("MHN") + cProcessos, "MHN_TABELA")
Local nX         := 0

cQueryMhq := "SELECT TOP 12000 R_E_C_N_O_ REC" 
If cBanco == "MSSQL"
    cQueryMhq += "  FROM " + cMHQ + " WITH (NOLOCK) "
Else
    cQueryMhq += "  FROM " + cMHQ
EndIf
cQueryMhq += " WHERE D_E_L_E_T_ = ' '"
cQueryMhq +=    " AND MHQ_FILIAL = '" + xFilial("MHQ") + "'"
cQueryMhq +=    " AND MHQ_CPROCE = '" + cProcessos + "'"
cQueryMhq +=    " AND MHQ_STATUS = '" + cStatus + "'"

cQueryMhq +=    " AND ("

//Filtra os registros relacionados as filiais que estão no processo
for nX := 1 To Len(aFilsProce)
    cQueryMhq += " MHQ_IDEXT = '" + xFilial(cTabela, aFilsProce[nX]) + "'"
    cQueryMhq += IIF(nX == Len(aFilsProce), " ", " OR ")
next nX

cQueryMhq +=    " )"

cQueryMhq += " ORDER BY R_E_C_N_O_"

If !(cBanco == "MSSQL")
    cQueryMhq := ChangeQuery(cQueryMhq)
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry2( , , cQueryMhq, {}), cAlias, .T., .F.)

ljGrvLog("RMIEnviaPdv", "Consulta que retornar os registros da MHQ que serão processados:", {cQueryMhq, cAlias})

Return cAlias


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsMiq
Função para filtrar os pontos de integração que estão ativos.

@type    function
@param 	 
@author  Bruno Almeida
@since   04/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsMiq()

Local aRet := {}

cQueryMiq := "SELECT R_E_C_N_O_ REC"
cQueryMiq += "  FROM " + cMIQ
cQueryMiq += " WHERE MIQ_FILIAL = '" + xFilial("MIQ") + "'"
cQueryMiq += "   AND MIQ_ATIVO = '1'"
cQueryMiq += "   AND D_E_L_E_T_ = ' '"
cQueryMiq += " ORDER BY MIQ_FILPC, MIQ_COD"

aRet := RmiXSql(cQueryMiq, "*", /*lCommit*/, /*aReplace*/)

ljGrvLog("RMIEnviaPdv", "Consulta que retornar os pontos de integração ativos:", {cQueryMiq, aRet})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProcesso
Função responsavel em converter os grupos em processos.
Na configuração do JOB são informados os códigos de grupos, porém, para
realizar o filtro na MHQ devera ser passado os processos.

@type    function
@param 	 cGrupo, Caractere, Grupo que que foi informado na configuração do JOB.
@author  Bruno Almeida
@since   04/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetProcesso(cGrupo)

Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aRet      := {}

If !Empty(cGrupo)

    cQuery := " SELECT MHN.MHN_COD"
    cQuery += " FROM " + RetSqlName("MHN") + " MHN"
    cQuery +=   " INNER JOIN " + RetSqlName("MHP") + " MHP"
    cQuery +=       " ON MHP.MHP_FILIAL = MHN.MHN_FILIAL"
    cQuery +=       " AND MHP.MHP_CPROCE = MHN.MHN_COD"
    cQuery += " WHERE MHN.MHN_FILIAL = '" + xFilial("MHN") + "'"
    cQuery +=   " AND MHN.MHN_CODGRP = '" + cGrupo + "'"
    cQuery +=   " AND MHP.MHP_TIPO = '1'"   //Envio
    cQuery +=   " AND MHP.MHP_ATIVO = '1'"  //Ativo
    cQuery +=   " AND MHN.D_E_L_E_T_ = ' '"
    cQuery +=   " AND MHP.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TcGenQry2( , , cQuery, {}), cAlias, .T., .F.)

    While !(cAlias)->( Eof() )
        Aadd(aRet, (cAlias)->MHN_COD )
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )

    ljGrvLog("RMIEnviaPdv", "Consulta que retornar os processos ativos para um determinado grupo:", {cQuery, aRet})
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} StructMip
Monta a estrutura de campos para ser adiciona na classe FWBulk

@type    function
@author  Bruno Almeida
@since   06/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function StructMip()

Local aStruct := {}

//-- É montado essa estrutura pois preciso ter uma sequencia fixa dos campos, pegando pelo dbStruct pode dar diferença

aAdd(aStruct,{"MIP_FILIAL",TamSx3("MIP_FILIAL")[3],TamSx3("MIP_FILIAL")[1],TamSx3("MIP_FILIAL")[2]})
aAdd(aStruct,{"MIP_CPROCE",TamSx3("MIP_CPROCE")[3],TamSx3("MIP_CPROCE")[1],TamSx3("MIP_CPROCE")[2]})
aAdd(aStruct,{"MIP_CHVUNI",TamSx3("MIP_CHVUNI")[3],TamSx3("MIP_CHVUNI")[1],TamSx3("MIP_CHVUNI")[2]})
aAdd(aStruct,{"MIP_LOTE",TamSx3("MIP_LOTE")[3],TamSx3("MIP_LOTE")[1],TamSx3("MIP_LOTE")[2]})
aAdd(aStruct,{"MIP_DATGER",TamSx3("MIP_DATGER")[3],TamSx3("MIP_DATGER")[1],TamSx3("MIP_DATGER")[2]})
aAdd(aStruct,{"MIP_HORGER",TamSx3("MIP_HORGER")[3],TamSx3("MIP_HORGER")[1],TamSx3("MIP_HORGER")[2]})
aAdd(aStruct,{"MIP_DATPRO",TamSx3("MIP_DATPRO")[3],TamSx3("MIP_DATPRO")[1],TamSx3("MIP_DATPRO")[2]})
aAdd(aStruct,{"MIP_HORPRO",TamSx3("MIP_HORPRO")[3],TamSx3("MIP_HORPRO")[1],TamSx3("MIP_HORPRO")[2]})
aAdd(aStruct,{"MIP_STATUS",TamSx3("MIP_STATUS")[3],TamSx3("MIP_STATUS")[1],TamSx3("MIP_STATUS")[2]})
aAdd(aStruct,{"MIP_UUID",TamSx3("MIP_UUID")[3],TamSx3("MIP_UUID")[1],TamSx3("MIP_UUID")[2]})
aAdd(aStruct,{"MIP_UIDORI",TamSx3("MIP_UIDORI")[3],TamSx3("MIP_UIDORI")[1],TamSx3("MIP_UIDORI")[2]})
aAdd(aStruct,{"MIP_IDRET",TamSx3("MIP_IDRET")[3],TamSx3("MIP_IDRET")[1],TamSx3("MIP_IDRET")[2]})
aAdd(aStruct,{"MIP_PDV",TamSx3("MIP_PDV")[3],TamSx3("MIP_PDV")[1],TamSx3("MIP_PDV")[2]})
aAdd(aStruct,{"MIP_TENTAT",TamSx3("MIP_TENTAT")[3],TamSx3("MIP_TENTAT")[1],TamSx3("MIP_TENTAT")[2]})

Return aStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} DelMip
Função responsavel em fazer a exclusão dos registros na MIP antes de ser inseridos pela FWBulk.
A exclusão é efetuada ao inves de simplesmente atualizar o registro porque a performance de torna melhor
quando estamos fazendo somente insert pelo FWBulk ao invês de atualizar o registro por RecLock(.F.).

@type    function
@param 	 cFiltro, Caractere, Filtros dos registros que devem ser excluídos da base
@author  Bruno Almeida
@since   06/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelMip(cFiltro, cProcesso)

    Local cDelete   := RetSqlName("MIP")

    cDelete += " WHERE D_E_L_E_T_ = ' '"
    cDelete += " AND MIP_CPROCE = '" + padR(cProcesso, tamSx3("MIP_CPROCE")[1]) + "'"
    cDelete += " AND MIP_CHVUNI IN (" + subStr(cFiltro, 1, Len(cFiltro) - 1) + ")"

    executaDelete(cDelete)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdMhq
Após o processamento dos registros pela FWBulk, a função UpdMhq faz a atualização do status
dos registros que foram inseridos com sucesso ou até mesmo dos registros que deram erro durante a inserção.

@type    function
@param 	 cFiltro, Caractere, Filtros dos registros que devem ser atualizados os status
@param 	 cStatusMhq, Caractere, O status pode ser 2 (sucesso), 3 (erro) ou 4 (erro da FWBulk)
@author  Bruno Almeida
@since   06/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UpdMhq(cFiltro, cStatusMhq)

Local cUpdate   := ""
Local nRetUpd   := 0

cUpdate := " UPDATE " + RetSqlName("MHQ")
cUpdate += " SET MHQ_STATUS = '" + cStatusMhq + "', MHQ_DATPRO = '" + dToS(date()) + "', MHQ_HORPRO = '" + Time() + "'"
cUpdate += " WHERE D_E_L_E_T_ = ' '"
cUpdate += " AND MHQ_FILIAL = '" + xFilial("MHQ") + "'"
cUpdate += " AND MHQ_ORIGEM = '" + padR("PROTHEUS", tamSx3("MHQ_ORIGEM")[1]) + "'"
cUpdate += " AND MHQ_CPROCE = '" + cProcessos + "'"
cUpdate += " AND MHQ_UUID IN ("

cUpdate += SubStr(cFiltro, 1, Len(cFiltro) - 1) + ")"
nRetUpd := TCSqlExec( cUpdate )

If nRetUpd == 0
    LjGrvLog("RMIEnviaPdv", "Atualização da MIP executado com sucesso!", cUpdate)
Else
    LjGrvLog("RMIEnviaPdv", "Erro ao executar o update na MIP!", cUpdate)
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MipStatus4
Os registros que foram processados pela FWBulk e deram erro, fica com status 4 na MHQ,
portanto a função MipStatus4 tem o objetivo de processar registro a registro para descobrirmos
qual dos registros que foram enviados para a FWBulk que deram erro. Quando é enviado um lote de registros
para a FWBulk, se 1 registro deu erro a rotina do frame invalida todos os registros fazendo o roolback.

@type    function
@param 	 aPtInteg, Array, Pontos de integração que estão ativos na tabela MIQ
@author  Bruno Almeida
@since   06/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MipStatus4(aPtInteg)

Local cAlias        := ConsMhq(cProcessos, "4")
Local nX            := 0
Local aPdv          := aPtInteg
Local cFiltroDel    := ""
Local cDelFull      := ""
Local cFiltroUpd    := ""
Local oFwBulk4      := Nil
Local aArea         := GetArea()
Local cStatus       := ""
Local nContador     := 0        //Define que é o primeiro processamento para aquela loja e ponto de carga

oFwBulk4 := FwBulk():New(RetSqlName("MIP"), nQtdReg)
oFwBulk4:SetFields(StructMip())

While !(cAlias)->( Eof() )

    MHQ->(dbGoTo((cAlias)->REC))
    cFilPub := AllTrim(MHQ->MHQ_IDEXT)

    For nX := 1 To Len(aPdv)
        MIQ->(dbGoTo(aPdv[nX][1]))

        If Empty(cFilPub) .OR. SubStr( MIQ->MIQ_FILPC, 1, Len(cFilPub) ) == cFilPub

            nContador++

            if nContador == 1
                //-- Monta o filtro para deletar os registros na MIP antes de inclui-los novamente
                cFiltroDel  := "'" + MHQ->MHQ_CHVUNI + "',"
                cDelFull    += cFiltroDel

                //-- Monta o filtro para fazer a atualização de status na MHQ
                cFiltroUpd := "'" + MHQ->MHQ_UUID + "',"
            endIf

            DelMip(cFiltroDel, cProcessos)

            oFwBulk4:AddData({MIQ->MIQ_FILPC,MHQ->MHQ_CPROCE,MHQ->MHQ_CHVUNI,"",Date(),TimeFull(),CtoD(""),"","1",FwUUID("MIP" + DtoS(MIP->MIP_DATGER) + MIP->MIP_HORGER),MHQ->MHQ_UUID,"",MIQ->MIQ_COD,"0"})
            oFwBulk4:Flush()

            If !Empty(oFwBulk4:GetError())
                cStatus := "3"
                LjGrvLog("RMIEnviaPdv", "Erro ao fazer a inserção do registro pelo FWBulk, status sera atualizado para 3 na MHQ.", oFwBulk4:GetError())
                LjGrvLog("RMIEnviaPdv", "Registro que aconteceu o erro.", cFiltroUpd)
                Exit
            Else
                cStatus := "2"
            EndIf

        EndIf

    Next nX

    If cStatus == "3"

        UpdMhq(cFiltroUpd, cStatus)                   
        DelMip(cDelFull, cProcessos)
        RmiGrvLog("3", "MHQ", MHQ->( Recno() ), "EnvPdv",oFwBulk4:GetError(), /*lRegNew*/, /*lTxt*/, /*cFilStatus*/,.F., /*nIndice*/, MHQ->MHQ_UUID, MHQ->MHQ_CPROCE, "TOTVS PDV", MHQ->MHQ_UUID, .T.)

    Else         
        UpdMhq(cFiltroUpd, cStatus) 
    EndIf

    cStatus     := ""                
    cFiltroDel  := ""
    cFiltroUpd  := ""
    cDelFull    := ""
    nContador   := 0

    (cAlias)->( DbSkip() )
EndDo

(cAlias)->( DbCloseArea() )
oFwBulk4:Destroy()
oFwBulk4 := Nil
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} grupoTemReg
Verifica se o grupo tem registro para processar na MHQ

@type    function
@param 	 
@author  Rafael Tenorio da Costa
@since   13/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function grupoTemReg(cGrupo)

    Local aSql      := {}
    Local cSql      := ""
    Local lRetorno  := .F.

    cSql := " SELECT COUNT(1)"
    cSql +=     " FROM " + retSqlName("MHN") + " MHN"
    cSql +=         " INNER JOIN " + retSqlName("MHP") + " MHP"
    cSql +=             " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHP_TIPO = '1' AND MHP_ATIVO = '1' AND MHN.D_E_L_E_T_ = MHP.D_E_L_E_T_"   //Tipo Envio e Ativo 
    cSql +=         " INNER JOIN " + retSqlName("MHQ") + " MHQ"
    cSql +=             " ON MHN_FILIAL = MHQ_FILIAL AND MHN_COD = MHQ_CPROCE AND MHQ_STATUS IN ('1','4') AND MHN.D_E_L_E_T_ = MHQ.D_E_L_E_T_"                     //Publicações que devem gerar MIP
    cSql += " WHERE MHN_FILIAL = '" + xFilial("MHN") + "'"
    cSql +=     " AND MHN_CODGRP = '" + cGrupo + "'"
    cSql +=     " AND MHN.D_E_L_E_T_ = ' '"

    aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    if aSql[1][1] > 0 
        lRetorno := .T.
    endIf

    fwFreeArray(aSql)

    ljGrvLog("RMIEnviaPdv", "Consulta que retornar se o grupo tem registros para processar:", {cSql, lRetorno})

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} executaDelete
Executa os deletes commitando por partes

@type    function
@author  Rafael Tenorio da Costa
@since   20/02/2025
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function executaDelete(cSql)

    Local cOrigem := procName(1)
    Local cDelete := ""

    cDelete := " WHILE 1=1"
    cDelete += " BEGIN"
    cDelete +=      " DELETE TOP (100) " + cSql + ";"
    cDelete +=      " IF @@ROWCOUNT = 0 BREAK;"
    cDelete += " END;"

    ljGrvLog(cOrigem, "Executando delete:", cDelete)

    IIF( tcSqlExec(cDelete) < 0, ljxjMsgErr("Não foi possível executar DELETE: " + tcSqlError(), /*Solucao*/, cOrigem), nil )

Return nil
