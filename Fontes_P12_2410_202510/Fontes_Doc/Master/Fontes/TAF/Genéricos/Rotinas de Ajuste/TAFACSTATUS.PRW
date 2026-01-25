#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"


//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFACSTATUS
Rotina para limpeza dos registros inconsistentes na TAFXERP

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFACSTATUS()

    Local oDlg := ""
    Local oFont1 := Nil
    Local oPanel := Nil
    Local lExcluCons := .F.
    Local lExcSt2 := .T.
    Local lExcIntegr := .F.
    Local cTafKey := Space(100)
    Local oGetTafK := Nil


    Define MsDialog oDlg From 0,0 To 250,500 Pixel Title OemToAnsi("Limpeza de Registros Inconsistentes")

        oFont1 := TFont():New("Tahoma",,-12,.T.)
        oFont1:Bold = .T.

        oPanel := TPanel():New(000,000,'',oDlg,,.F.,.F.,,CLR_WHITE,000,000,.F.,.F.)
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT


        oGetTafK := TGet():New(12,15,{|u|If( PCount()==0,cTafKey,cTafKey := u )},oPanel,0150,009,"@!",,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Para a execução considerando somente 1 TafKey, insira a chave abaixo:",1,,CLR_BLUE)


        oTCExl := TCheckBox():New(040,15,"Considera Excluidos",,oPanel,100,210,,,,,,,,.T.,,,)
        oTCExl:bSetGet 	:= {|| lExcluCons }
        oTCExl:bLClicked 	:= {|| lExcluCons:= !lExcluCons}
        oTCExl:bWhen 		:= {||.T.}

        oTCaST2 := TCheckBox():New(055,15,"Apaga Rejeitados da TAFST2",,oPanel,100,210,,,,,,,,.T.,,,)
        oTCaST2:bSetGet 	:= {|| lExcSt2}
        oTCaST2:bLClicked 	:= {|| lExcSt2 := !lExcSt2}
        oTCaST2:bWhen 		:= {||.T.}

        oTCaST2 := TCheckBox():New(070,15,"Somente Integrados",,oPanel,100,210,,,,,,,,.T.,,,)
        oTCaST2:bSetGet 	:= {|| lExcIntegr}
        oTCaST2:bLClicked 	:= {|| lExcIntegr := !lExcIntegr}
        oTCaST2:bWhen 		:= {||.T.}

    Activate MsDialog oDlg Centered On Init Enchoicebar (oDlg	,{||FwMsgRun(,{||runApplication(cTafkey,lExcluCons,lExcSt2,lExcIntegr)},"Rotina de Limpeza","Realizando limpeza, Aguarde ..."),oDlg:End()};
                                                                ,{||oDlg:End() };
                                                                ,,,,,.F.,.F.,.F.,.T.,.F.)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} runApplication
Realiza a Execuçao da rotina

@param cTafkey -  Tafkey
@param lExcluCons - Define se considera os registros deletados
@param lExcSt2 - Define se apaga o registro da TAFST2

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function runApplication(cTafkey,lExcluCons,lExcSt2,lExcIntegr)


    Local cCodFils := ""
    Local cAliasPXERP := ""
    Local lGo := .T.
    Local nCont := 0
    Local lRegIntTAF := .F. 

    Default cTafKey := ""
    Default lExcluCons := .F.
    Default lExcSt2 := .T.

    cTafKey := AllTrim(cTafKey)

    If Empty(cTafKey)
        If MsgYesNo("Não foi especificado nenhum TafKey para a execução da rotina, deseja realizar o processo para todos registros?","Limpeza de Registros Inconsistentes")
            lGo := .T.
        Else
            lGo := .F.
        EndIf
    EndIf

    If lGo

        cAliasPXERP := GetNextAlias()

        cCodFils := TAFArrErpFils()
        getQueryXERP(cTafKey,cCodFils,cAliasPXERP,lExcluCons)

        While (cAliasPXERP)->(!Eof())

            If (cAliasPXERP)->REGSERR > 0
                If lExcSt2
                    lRegIntTAF := (cAliasPXERP)->QTDTAF > 0
                    zeraST2Err(AllTrim((cAliasPXERP)->TAFKEY),lExcluCons,lRegIntTAF)
                EndIf
                zeraXERPErr(AllTrim((cAliasPXERP)->TAFKEY),lExcluCons)
            EndIf

            //Fazer Verificaçao de Status dentro do TAF
            If (cAliasPXERP)->QTDTAF > 1
                verificaStatusTAF(AllTrim((cAliasPXERP)->TAFKEY),lExcluCons,lExcSt2)
            EndIf

            nCont++
            (cAliasPXERP)->(dbSkip())
        EndDo
        (cAliasPXERP)->(dbCloseArea())

        //Elimina os registros que não foram integrados
        If !lExcIntegr
         	qryNaoInt(cTafKey,cCodFils,cAliasPXERP)

	        While (cAliasPXERP)->(!Eof())
            	If lExcSt2
                    apagaST2(AllTrim((cAliasPXERP)->TAFKEY),lExcluCons)
                EndIf
                zeraXERPErr(AllTrim((cAliasPXERP)->TAFKEY),lExcluCons,(cAliasPXERP)->RECNO)

	            nCont++
	            (cAliasPXERP)->(dbSkip())
	        EndDo
	        (cAliasPXERP)->(dbCloseArea())
        EndIf

        MsgInfo("Processo Finalizado. " + cValToChar(nCont) + " avaliado(s) com base na TAFXERP.")
    EndIf

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} getQueryXERP
Define os itens a serem excluidos na TAFXERP

@param cTafkey -  Tafkey
@param cFilsERP - Filiais do ERP
@param cAliasPXERP - RecordSet da Consulta
@param lExcluCons - Define se considera os registros deletados


@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------

Static Function getQueryXERP(cTafKey,cFilsERP,cAliasPXERP,lExcluCons)

    Local cQuery := ""
    Default cTafKey := ""
    Default lExcluCons := .F.

    cQuery := " SELECT DISTINCT XERP.TAFKEY TAFKEY "

    //Quantidade de registros com STATUS de inconsistencia na TAFXERP
    cQuery += " ,(SELECT COUNT(TAFKEY) FROM TAFXERP COUNTERP
    cQuery += " WHERE COUNTERP.TAFKEY = XERP.TAFKEY AND XERP.TAFALIAS <> ' ' "
    If !Empty(cTafKey)
        cQuery += " AND TAFKEY = '" + cTafKey +  "' "
    EndIf
    cQuery += " AND XERP.D_E_L_E_T_ = ' ' AND TAFALIAS = ' ' AND TAFRECNO = 0 ) REGSERR "

    //Quantidade de registros com o mesmo TAF que foram aceitos pelo TAF
    cQuery += " ,(SELECT COUNT(TAFKEY) FROM TAFXERP COUNTERP
    cQuery += " WHERE COUNTERP.TAFKEY = XERP.TAFKEY AND XERP.TAFALIAS <> ' ' "
    If !Empty(cTafKey)
        cQuery += " AND TAFKEY = '" + cTafKey +  "' "
    EndIf
    cQuery += " AND XERP.D_E_L_E_T_ = ' ' AND TAFALIAS != ' ' AND TAFRECNO > 0 ) QTDTAF "

    cQuery += " ,TAFALIAS "
    cQuery += " FROM TAFXERP XERP "
    cQuery += " INNER JOIN TAFST2 ST2 ON XERP.TAFKEY = ST2.TAFKEY AND ST2.TAFFIL IN (" + cFilsERP +  ")  " //AND ST2.D_E_L_E_T_ = ' '
    cQuery += " AND ST2.TAFCODMSG = '2' "

    If lExcluCons
        cQuery += " WHERE  "
        cQuery += " XERP.TAFSTATUS IN ('1','2') "
    Else
        cQuery += " WHERE XERP.D_E_L_E_T_ = ' ' "
        cQuery += " AND XERP.TAFSTATUS IN ('1','2') "
    EndIf

    If !Empty(cTafKey)
        cQuery += " AND XERP.TAFKEY = '" + cTafKey + "'"
    EndIf

    TCQuery cQuery New Alias (cAliasPXERP)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} qryNaoInt
Busca os registros que nunca foram integrados para eliminá-los

@param cTafkey -  Tafkey
@param cFilsERP - Filiais do ERP
@param cAliasPXERP - RecordSet da Consulta

@author Marceo Neumann
@since 18/09/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function qryNaoInt(cTafKey,cFilsERP,cAliasPXERP)

    Local cQuery := ""
    Default cTafKey := ""

    cQuery := "SELECT XERP.TAFKEY, MAX(XERP.R_E_C_N_O_) RECNO"
    cQuery +=  " FROM TAFXERP XERP"
    cQuery += " INNER JOIN TAFST2 ST2"
    cQuery +=    " ON XERP.TAFKEY = ST2.TAFKEY"
    cQuery +=   " AND ST2.TAFFIL IN (" + cFilsERP +  ")"
    cQuery +=   " AND ST2.TAFCODMSG = '2'"
    cQuery += " WHERE XERP.TAFSTATUS NOT IN ('1','2','3')" //Buscar somente os sem sucesso
    cQuery +=   " AND XERP.D_E_L_E_T_ = ' '" //Se algum teve sucesso, os registros já foram apagados no processamento anterior

    If !Empty(cTafKey)
        cQuery += " AND XERP.TAFKEY = '" + cTafKey + "'"
    EndIf

    cQuery += " GROUP BY XERP.TAFKEY"

    TCQuery cQuery New Alias (cAliasPXERP)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} zeraXERPErr
Apaga os registros da TAFXERP

@param cTafkey -  Tafkey
@param lExcluCons - Define se considera os registros deletados
@param nRecExce - Recno exceção (que não deve ser excluído)

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function zeraXERPErr(cTafKey,lExcluCons,nRecExce)

    Local cSql := ""
    Local lRecDel := Ascan( TCStruct('TAFXERP'), {|x| x[1] == 'R_E_C_D_E_L_' }) > 0

    Default nRecExce := 0

    cSql := " UPDATE TAFXERP "
    cSql += " SET D_E_L_E_T_ = '*', TAFCODERR = 'TAFCOR' "
    If lRecDel
        cSql += ",R_E_C_D_E_L_ = R_E_C_N_O_  "
    EndIf
    cSql += " WHERE TAFKEY = '" + cTafKey + "'"
    cSql += " AND TAFALIAS = ' ' "
    cSql += " AND TAFRECNO = 0 "

    If nRecExce != 0
    	cSql += " AND R_E_C_N_O_ <> " + cValToChar(nRecExce)
    EndIf

    If TCSQLExec (cSql) < 0
        If IsBlind()
            TAFConOut(TCSQLError())
        Else
            MsgStop(TCSQLError())
        EndIf
    Else
        TAFConOut("[TAFAJUST][TAFKEY] " + cTafKey + " Date: " + DTOC(dDataBase) + " Time: " + Time() )
	EndIf

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} zeraST2Err
Apaga os registros da TAFST2

@param cTafkey -  Tafkey
@param lExcluCons - Define se considera os registros deletados
@param lRegIntTAF - Informa se o TAFKEY foi integrado no TAF.

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function zeraST2Err(cTafKey,lExcluCons,lRegIntTAF)

    Local cSql := ""
    Local aTicketsOK := {}
    Local nPosTicket := 0
    Local lRecDel := Ascan( TCStruct('TAFST2'), {|x| x[1] == 'R_E_C_D_E_L_' }) > 0

    Default := lExcluCons := .F.


    //Verifica os TICKETS aceitos pelo TAF, os mesmos nao podem ser apagados da TAFST2.
    If lRegIntTAF

        cSql := "SELECT TAFTICKET FROM TAFXERP WHERE TAFKEY = '" + cTafKey + "' AND TAFRECNO > 0 AND D_E_L_E_T_ = ' ' "

        TCQuery cSql New Alias 'rsTAFIInt'

        While rsTAFIInt->(!Eof())

            aAdd(aTicketsOK,AllTrim(rsTAFIInt->TAFTICKET))
            rsTAFIInt->(dbSkip())
        EndDo

        rsTAFIInt->(dbCloseArea())
    EndIf 

    cSql := " SELECT TAFTICKET"
    cSql += " FROM TAFXERP A "
    cSql += " WHERE A.TAFKEY = '" + cTafKey +  "'"
    cSql += "   AND A.TAFRECNO = 0 "

    If !lExcluCons
        cSql += " AND A.D_E_L_E_T_ = ' ' "
    EndIf

    cSql += " GROUP BY TAFTICKET "

    TCQuery cSql New Alias 'rsDelST2'

    While rsDelST2->(!Eof())

        cSql := "SELECT COUNT(*) FROM TAFXERP WHERE TAFTICKET = '" + AllTrim(rsDelST2->TAFTICKET) + "' AND TAFRECNO <> 0"
        
        If !lExcluCons
            cSql += " AND D_E_L_E_T_ = ' ' "
        EndIf
        TCQuery cSql New Alias 'xrsDelST2'

        nPosTicket := aScan(aTicketsOK,{|ticket|AllTrim(ticket) ==  AllTrim(rsDelST2->TAFTICKET) })

        If xrsDelST2->(!Eof()) .And. nPosTicket == 0
            cSql := " UPDATE TAFST2 "
            cSql += " SET D_E_L_E_T_ = '*', "
            If lRecDel
                cSql += "R_E_C_D_E_L_ = R_E_C_N_O_ , "
            EndIf
            cSql += "TAFOWNER = 'TAFAJ'  "
            cSql += " WHERE TAFKEY = '" + cTafKey + "'"
            cSql += " AND TAFTICKET = '" + AllTrim(rsDelST2->TAFTICKET) + "'"
    //     cSql += " AND D_E_L_E_T_ = ' ' "

            If TCSQLExec (cSql) < 0
                If IsBlind()
                    TAFConOut(TCSQLError())
                Else
                    MsgStop(TCSQLError())
                EndIf
            Else
                TAFConOut("[TAFAJUST][TAFST2] " + cTafKey + " Date: " + DTOC(dDataBase) + " Time: " + Time() )
            EndIf
        EndIf

        xrsDelST2->(DbCloseArea())
        rsDelST2->(dbSkip())
    EndDo

    rsDelST2->(dbCloseArea())

Return Nil


//----------------------------------------------------------------------------
/*/{Protheus.doc} apagaST2
Apaga os registros da TAFST2 mantendo o registro com maior R_E_C_N_O_

@param cTafkey -  Tafkey
@param lExcluCons - Define se considera os registros deletados

@author Marcelo Neumann
@since 18/09/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function apagaST2(cTafKey,lExcluCons)

    Local cSql := ""
    Local lRecDel := Ascan( TCStruct('TAFST2'), {|x| x[1] == 'R_E_C_D_E_L_' }) > 0

    Default lExcluCons := .F.

    cSql := "SELECT MAX(R_E_C_N_O_) RECNO"
    cSql +=  " FROM TAFST2"
    cSql += " WHERE TAFKEY = '" + cTafKey + "'"

    If !lExcluCons
        cSql += " AND D_E_L_E_T_ = ' ' "
    EndIf

    TCQuery cSql New Alias 'rsDelST2'

    If rsDelST2->(!Eof())
        cSql := "UPDATE TAFST2"
        cSql +=   " SET D_E_L_E_T_ = '*',
        IF lRecDel 
            cSql += "R_E_C_D_E_L_ = R_E_C_N_O_ , "
        EndIf 
        cSql += "TAFOWNER = 'TAFAJ2'"
        cSql += " WHERE TAFKEY = '" + cTafKey + "'"
        cSql +=   " AND R_E_C_N_O_ <> " + cValToChar(rsDelST2->RECNO)
        cSql +=   " AND TAFCODMSG = '2'"

	    If !lExcluCons
	        cSql += " AND D_E_L_E_T_ = ' '"
	    EndIf

        If TCSQLExec (cSql) < 0
            If IsBlind()
                TAFConOut(TCSQLError())
            Else
                MsgStop(TCSQLError())
            EndIf
        Else
            TAFConOut("[TAFAJUST_2][TAFST2] " + cTafKey + " Date: " + DTOC(dDataBase) + " Time: " + Time() )
        EndIf
    EndIf

    rsDelST2->(dbCloseArea())

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} verificaStatusTAF
Verifica o status dos registros dentro do TAF.

@param cTafkey -  Tafkey
@param lExcluCons - Define se considera os registros deletados
@param lExcSt2 - Define se o registro inconsistente tem que ser deletado da TAFST2

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function verificaStatusTAF(cTafKey,lExcluCons,lExcSt2)

    Local cSql := ""
    Local nRegsGov := 0
    Local nRegsTAF := 0
    Local nX := 0
    Local aRegsTAF := {}
    Local cAliasTAF := ""
    Local cCmpEvt := ""
    Local oModel := Nil
    Local cChave := ""
    Local lNoErro := .T.
    Local lRecDelExp := Ascan( TCStruct('TAFXERP'), {|x| x[1] == 'R_E_C_D_E_L_' }) > 0
    Local lRecDelSt2 := Ascan( TCStruct('TAFST2'), {|x| x[1] == 'R_E_C_D_E_L_' }) > 0
    

    Default lExcluCons := .F.

//   dbTAFOpenTab(TfSqlName("TFHISTDEL"))
//   (TfSqlName("TFHISTDEL"))->(dbSetOrder(1))

    cSql := " SELECT TAFKEY, TAFALIAS, TAFRECNO, R_E_C_N_O_ RECNO "
    cSql += " FROM TAFXERP "
    cSql += " WHERE TAFKEY = '" + cTafKey + "'"
    cSql += " AND TAFSTATUS IN ('1','2') "
    cSql += " AND TAFALIAS != ' ' "

    If !lExcluCons
        cSql += " AND D_E_L_E_T_ = ' ' "
    EndIf

    TCQuery cSql New Alias 'rsSTAF'

    While rsSTAF->(!Eof())

        cAliasTAF := rsSTAF->TAFALIAS

        (cAliasTAF)->(dbGoTo(rsSTAF->TAFRECNO))

        If (cAliasTAF)->(Eof())

            TAFConOut("[TAFAJUST][WARN] Recno Nao existe na base do TAF . Alias: " + cAliasTAF + " Recno: " + cValToChar(rsSTAF->TAFRECNO))
        Else

            //Se nao estiver aguardando retorno do governo e nao autorizado
            If ((cAliasTAF)->&(cAliasTAF+"_STATUS") $ '2|4|6|7')
                nRegsGov++
            Else 
                aAdd(aRegsTAF   ,{(cAliasTAF)->(RecNo());   //Recno do Registro no TAF
                                ,rsSTAF->RECNO;             //RecNo do Registro na TAFXERP
                                ,cAliasTAF;                 //Alias da Tabela
                                })
            EndIf 
        EndIf

        rsSTAF->(dbSkip())
    EndDo
    rsSTAF->(dbCloseArea())

    nRegsTAF := Len(aRegsTAF)

    If nRegsGov > 0 .And. nRegsTAF > 0

        Begin Transaction

        For nX := 1 To Len(aRegsTAF)

            cAliasTAF := aRegsTAF[nX][3]
            
            (cAliasTAF)->(dbGoTo(aRegsTAF[nX][1]))
            If !(cAliasTAF)->(Deleted()) .And. (cAliasTAF)->(!Eof())

                //(cAliasTAF)->(RecLock(cAliasTAF,.F.))
                //(cAliasTAF)->(dbDelete())
                //(cAliasTAF)->(MsUnlock())

                If cAliasTAF $ "C9V|C91"
                    cCmpEvt := (cAliasTAF)->&(cAliasTAF+"_NOMEVE")
                    If cCmpEvt == "TAUTO"
                        Loop
                    EndIf
                    cEvento := Substr(cCmpEvt,1,1) + "-" + Substr(cCmpEvt,2)
                    cFonte := TAFRotinas(cEvento,4,.F.,2)[1]
                Else
                    cFonte := TAFRotinas(cAliasTAF,3,.F.,2)[1]
                EndIf

                oModel := FWLoadModel(cFonte)
                oModel:SetOperation(5)
                oModel:Activate()

                FwFormCommit(oModel)

                oModel:DeActivate()
                FreeObj(oModel)
                oModel := Nil


                //Reabre registro anterior
                cChave := (cAliasTAF)->&( cAliasTAF + "_ID" + "+" + cAliasTAF + "_VERANT" )
                TAFRastro(cAliasTAF,1,cChave,.T.)

                //gravaHistDel()
                TAFConOut("[TAFAJUST][INFO] Registro deletado logicamente do TAF. Alias: " + cAliasTAF + " Filial: " + (cAliasTAF)->&(cAliasTAF+"_FILIAL") + " Id: " +  (cAliasTAF)->&(cAliasTAF+"_ID") )
            Else

                TAFConOut("[TAFAJUST][INFO] Registro já se encontra deletado logicamente. Alias: " + cAliasTAF + " RecNo: " + cvalToChar(aRegsTAF[nX][1]))
                //ConOut("[TAFAJUST][INFO] Registro já se encontra deletado Fisicamente. Alias: " + cAliasTAF + " Filial: " + &(cAliasTAF+"_FILIAL") + " Id: " +  &(cAliasTAF+"_ID") )
            EndIf


        Next nX

        For nX := 1 To Len(aRegsTAF)

            cSql := " UPDATE TAFXERP "
            cSql += " SET D_E_L_E_T_ = '*' "
            If lRecDelExp
                cSql += " ,R_E_C_D_E_L_ = R_E_C_N_O_ "
            EndIf
            cSql += " ,TAFCODERR = 'TAFCOR' "
            cSql += " WHERE "
            cSql += " R_E_C_N_O_ = " + cValToChar(aRegsTAF[nX][2])

            If TCSQLExec (cSql) < 0
                MsgInfo(TCSQLError(),"Warning")
                DisarmTransaction()
                lNoErro := .F. 
            EndIf 


            If lNoErro .And. lExcSt2

                //Order by para garatir caso exista + de 1 TAFKEY+TAFTICKETS iguais, neste caso o ultimo sempre será o aceito TAF e o mesmo será recuperado na TAFST2
                cSql := " SELECT TAFKEY, TAFTICKET FROM TAFXERP WHERE R_E_C_N_O_ = " + cValToChar(aRegsTAF[nX][2]) + " ORDER BY TAFALIAS ASC" 

                TCQuery cSql New Alias 'rsERPRec'

                cSql := " UPDATE TAFST2 "
                cSql += " SET D_E_L_E_T_ = '*' "
                If lRecDelSt2
                    cSql += " ,R_E_C_D_E_L_ = R_E_C_N_O_ "
                EndIf
                cSql += ", TAFOWNER = 'TAFAJ' "
                cSql += " WHERE "
                cSql += " TAFKEY = '" + AllTrim(rsERPRec->TAFKEY) + "' "
                cSql += " AND TAFTICKET = '" + AllTrim(rsERPRec->TAFTICKET) + "'"

                If TCSQLExec (cSql) < 0
                    MsgInfo(TCSQLError(),"Warning")
                    DisarmTransaction()
                EndIf

                rsERPRec->(dbCloseArea())

            EndIf 

            lNoErro := .T.

        Next nX

        End Transaction

    EndIf

     nRegsGov := 0
    nRegsTAF := 0
    aSize(aRegsTAF,0)

Return Nil

