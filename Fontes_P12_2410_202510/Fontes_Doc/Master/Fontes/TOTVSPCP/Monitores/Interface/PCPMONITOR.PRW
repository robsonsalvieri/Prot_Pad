#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"


/*/{Protheus.doc} PCPMONITOR
Fonte chamador da tela de Monitores do PCP em Po UI
@type Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Function PCPMONITOR()
    If AliasInDic("HZB")
        If UPDMONITOR()
            If PCPVldApp(.T.)
                FwCallApp("totvs-supply-monitor")
            EndIf
        Else
            Help(,,"Help",,"Ocorrem erros na atualização dos Monitores!",1,0)
            Return
        EndIf
    Else
        Help(,,"Help",,STR0232,1,0) //"Dicionário de dados não atualizado com as tabelas do programa!"
        Return
    EndIf
Return

/*/{Protheus.doc} MenuDef
Função responsável por atribuir os monitores disponíveis ao menu para validar acesso no cadastro de regras
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return aRotina, array, Array com a lista dos Monitores disponíveis
/*/
Static Function MenuDef()
    Local aMonitores := PCPMonitorUtils():RetornaListaMonitores()
    //Local aRotAdic
    Local nIndice    := 0

    Private aRotina := {}

    For nIndice := 1 To Len(aMonitores)
        aAdd(aRotina,{aMonitores[nIndice][2],aMonitores[nIndice][1], 0, 2, 0, Nil })
    Next nIndice
    /*
    If ExistBlock("PCPMONITOR")
        aRotAdic := ExecBlock("PCPMONITOR",.F.,.F.)
        If ValType(aRotAdic) == "A"
            AEval(aRotAdic,{|x| AAdd(aRotina,x)})
        EndIf
    EndIf
    */
    FwFreeArray(aMonitores)
Return aRotina

Static Function PCPMONITLOG(cMessage)
    LogMsg('PCPMONITOR', 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + cMessage + CHR(10) + Replicate("-",70))
Return

Static Function PCPMONITERR(e)
	Local cMessage := AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack)

    PCPMONITLOG(cMessage)
	If InTransact()
		DisarmTransaction()
	EndIf
Return

Static Function UPDMONITOR()
    Local bErrorBloc := ErrorBlock({|e| PCPMONITERR(e), Break(e) })
    Local lRet       := .T.
        
    Begin Transaction
        Begin Sequence
            lRet := UPDHZFPOS()
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
Return lRet

Static Function UPDHZFPOS()
    Local cAlias  := GetNextAlias()
    Local cBanco  := Upper(TcGetDb())
    Local cSql    := ""
    Local cSubstr := IIf("MSSQL" $ cBanco, "SUBSTRING", "SUBSTR")
    Local lRet    := .T.

    dbSelectArea("HZF")
    If HZF->(FieldPos("HZF_POSIC")) > 0
        BeginSql Alias cAlias
            %noparser%
            SELECT MAX(HZF_POSIC) AS HZF_POSIC FROM %Table:HZF% WHERE %NotDel%
        EndSql
        If (cAlias)->HZF_POSIC < 1
            cSql := "UPDATE "+RetSqlName("HZF")+" SET HZF_POSIC = CAST("+cSubstr+"(HZF_CODIGO,1,2) AS INTEGER) WHERE D_E_L_E_T_  = ' ' "
            If TCSQLExec(cSql) < 0
                lRet := .F.
                PCPMONITLOG(TCSQLError())
                DisarmTransaction()
            EndIf
        EndIf
    EndIf
Return lRet
