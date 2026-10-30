#include "TOTVS.CH"
#include "protheus.ch"

#DEFINE INDICE_CAMPO    1
#DEFINE NOME_CAMPO      2
#DEFINE EH_FILIAL       2
#DEFINE TIPO_CAMPO      3
#DEFINE CAMPO_VALIDO    4
#DEFINE EH_PRI_KEY      5
#DEFINE ALIAS_PARAM     1
#DEFINE CHAVE_PARAM     2

Static _cGetDb := TCGetDB()

function PrjImpCsv(cPath,aParam,cEmp,cFil)
    local aFiles  := Directory(PrjWzLinux(cPath) + "*.csv*")
    local oImport := Nil
    local nFiles  := 0
    local cHoraInicio := TIME()
    local nFileName := 1
    Local lLock     := .F.
    Default cEmp    := cEmpAnt
    Default cFil    := xFilial()
    Default aParam  := {"",""}

    If isBlind()
        lLock := LockByName(aParam[ALIAS_PARAM], .F., .F.)
        If lLock
            RpcSetType(3)
            RpcSetEnv(cEmp,cFil,,,'CEN')
        Else
            MsgAlert("A tabela " + aParam[ALIAS_PARAM] + " já se encontra em outro processo de carga. O Processo será finalizado.","TOTVS")
            Return
        EndIf
    EndIf

    if len(aFiles)>0
        For nFiles := 1 to len(aFiles)
            If empty(aParam[ALIAS_PARAM])
                aParam[ALIAS_PARAM] := SubStr(aFiles[nFiles][nFileName],1,3)
            EndIf
            If empty(aParam[CHAVE_PARAM])
                aParam[CHAVE_PARAM] := SubStr(aFiles[nFiles][nFileName],5,1)
            EndIf
            conOut("Importacao do arquivo " + aFiles[nFiles][nFileName] + " | Inicio : " + TIME())
            nIndice := val(aParam[CHAVE_PARAM])
            oImport := PrjImpCsv():New()
            oImport:setAlias(aParam[ALIAS_PARAM])
            oImport:setFilial()
            oImport:setIndex(nIndice)
            oImport:setFile(cPath,aFiles[nFiles][nFileName])
            oImport:import()
            oImport:destroy()
            oImport := Nil
        Next nFiles
    endif
    If isBlind()
        UnlockByName(aParam[ALIAS_PARAM], .F., .F.)
    EndIf
    conOut("Horario de termino : " + TIME())
    conOut("Tempo gasto na execucao : " + ElapTime( cHoraInicio, TIME() ))
return

/*/{Protheus.doc}
    Classe que faz importação de arquivo .csv
    @type  Class
    @author p.drivas
    @since 12/08/2020
    @version version
/*/

Class PrjImpCsv

    Data cAlias
    Data cFilialCsv
    Data nIndex
    Data oFile

    Data cError
    Data cFileName
    Data aHeader
    Data cKey
    Data aOrder
    Data aLinha

    Method new() Constructor

    Method getAlias()
    Method setAlias(cAlias)
    Method getFilial()
    Method setFilial()
    Method getIndex()
    Method setIndex(nIndex)
    Method getFile()
    Method setFile(oFile)
    Method getKey()
    Method setKey(cKey)
    Method getOrder()
    Method setOrder(aOrder)
    Method getErro()
    Method setErro(cError)

    Method getHeader()
    Method setHeader()
    Method validHeader()
    Method validQuery(cValue, nIndField)
    Method validField(cValue, nIndField)
    Method openConnection()
    Method closeConnection()

    Method import()
    Method processa()
    Method prepare()
    Method exists()
    Method delete()
    Method commit()

    Method destroy()

EndClass

Method New() Class PrjImpCsv
    self:setOrder({})
Return self

Method getAlias() Class PrjImpCsv
Return self:cAlias

Method setAlias(cAlias) Class PrjImpCsv
    Default cAlias  := ""
    self:cAlias := cAlias
Return

Method getFilial() Class PrjImpCsv
Return self:cFilialCsv

Method setFilial(cFil) Class PrjImpCsv
    Default cFil := xFilial(self:cAlias)
    self:cFilialCsv := cFil
Return

Method getIndex() Class PrjImpCsv
Return self:nIndex

Method setIndex(nIndex) Class PrjImpCsv
    Default nIndex := 1
    self:nIndex := nIndex
Return

Method getFile() Class PrjImpCsv
Return self:oFile

Method setFile(cPath, cFileName) Class PrjImpCsv
    self:cFileName := cFileName
    self:oFile := FWFILEREADER():New(cPath + cFileName)
Return

Method getKey() Class PrjImpCsv
Return self:cKey

Method setKey(cKey) Class PrjImpCsv
    self:cKey := cKey
Return

Method getOrder() Class PrjImpCsv
Return self:aOrder

Method setOrder(aOrder) Class PrjImpCsv
    self:aOrder := aOrder
Return

Method getErro() Class PrjImpCsv
Return self:cError

Method setErro(cError) Class PrjImpCsv
    self:cError := cError
Return

Method getHeader() Class PrjImpCsv
return self:aHeader

Method setHeader() Class PrjImpCsv
    local cIndex    := (self:cAlias)->(IndexKey(self:nIndex))
    local nIndField := 0
    local nLenaFields := 0
    local aFields   := self:aLinha

    self:aHeader := {}
    If !Empty(aFields)
        nLenaFields := len(aFields)
        For nIndField := 1 to nLenaFields
            aAdd(self:aHeader,{;
                nIndField,;       //INDICE_CAMPO
                aFields[nIndField],;    //NOME_CAMPO
                FWSX3Util():GetFieldType( aFields[nIndField] ),;    //TIPO_CAMPO
                Iif(FWSX3Util():GetFieldType( aFields[nIndField] ) != "", .T.,Iif(aFields[nIndField] == "D_E_L_E_T_",.T.,.F.)),;      //CAMPO_VALIDO
                Iif(aFields[nIndField] $ cIndex, .T., .F. )};     //EH_PRI_KEY
                )
            If self:aHeader[nIndField][EH_PRI_KEY] == .T.
                aAdd(self:aOrder,{nIndField,Iif(self:aHeader[nIndField][NOME_CAMPO]==self:cAlias+"_FILIAL",.T.,.F.)})
            EndIf
        Next nIndField
    EndIf
return

Method validHeader() Class PrjImpCsv
    local cMsg    := ""
    local lValid  := .T.
    local nFields := 0

    For nFields := 1 to len(self:aHeader)
        if empty(self:aHeader) .Or. self:aHeader[nFields][CAMPO_VALIDO] == .F.
            If Empty(cMsg)
                cMsg := "Campo(s) não existe(m): " + self:aHeader[nFields][NOME_CAMPO] + ","
            Else
                cMsg += self:aHeader[nFields][NOME_CAMPO] + ","
            EndIF
        EndIf
    Next nFields
    If Empty(self:aOrder)
        cMsg += "Chave de pesquisa não encontrada para o Alias informado (" + self:cAlias + "). Verifique."
    EndIF
    If !Empty(cMsg)
        lValid := .F.
        self:setErro(cMsg + " Atualize seu dicionário de dados" )
        MsgAlert(self:getErro())
    EndIF
return lValid

Method exists() Class PrjImpCsv
    Local lAchou  := .F.
    Local cSQLSeek  := ''
    Local nOrders   := 0
    Local aKeyFields := {}
    Local cAliasTemp := GetNextAlias()

    For nOrders := 1 to len(self:aOrder)
        aadd(aKeyFields,self:aHeader[self:aOrder[nOrders][INDICE_CAMPO]][NOME_CAMPO])
    Next nOrders
    cSQLSeek := "SELECT "
    cSQLSeek += ArrTokStr(aKeyFields,",")
    cSQLSeek += ", R_E_C_N_O_ AS RECNO, D_E_L_E_T_ "
    cSQLSeek += " FROM " + RetSqlName(self:cAlias)
    cSQLSeek += " WHERE "
    For nOrders := 1 to len(self:aOrder)
        if nOrders > 1
            cSQLSeek += " AND "
        EndIF
        cSQLSeek += aKeyFields[nOrders] + " = "
        cSQLSeek += "'"
        If self:aOrder[nOrders][EH_FILIAL] == .T.
            cSQLSeek += self:cFilialCsv
        Else
            cSQLSeek += self:validQuery(self:aLinha[self:aOrder[nOrders][INDICE_CAMPO]],self:aOrder[nOrders][INDICE_CAMPO])
        EndIf
        cSQLSeek += "'"
    Next nOrders
    cSQLSeek += " AND D_E_L_E_T_ = ' ' "

    If _cGetDb != "MSSQL" .OR. _cGetDb != "POSTGRES" .OR. _cGetDb != "ORACLE"
        cSQLSeek := changeQuery(cSQLSeek)
    EndIf
    If Select(cAliasTemp) > 0
        dbSelectArea(cAliasTemp)
        (cAliasTemp)->(DBCloseArea())
    EndIf
    DBUseArea(.T.,"TOPCONN",TCGenQry(,,cSQLSeek),cAliasTemp,.F.,.T.)
    (cAliasTemp)->(dbgotop())
    lAchou := (cAliasTemp)->(!Eof())
    If lAchou
        (self:cAlias)->(DbGoTo((cAliasTemp)->RECNO))
    EndIf
    (cAliasTemp)->(DBCloseArea())
return lAchou

Method Import() Class PrjImpCsv
    Processa({|| self:processa()}, "Importando arquivo " + self:cFileName + " ..." )
Return

Method processa() Class PrjImpCsv
    Local nLinhaCsv := 1

    self:aLinha  := {}
    if (self:oFile:Open())
        ProcRegua(Ceiling(self:oFile:getFileSize() / 1000))
        if self:openConnection()
            self:aLinha := StrTokArr2(StrTran(self:oFile:getLine(),'"',''),";",.T.)
            self:setHeader()
            If self:validHeader()
                While (self:oFile:hasLine())
                    self:aLinha := StrTokArr2(StrTran(self:oFile:getLine(),'"',''),";",.T.)
                    self:prepare()
                    nLinhaCsv++
                    If nLinhaCsv == 2 .Or. nLinhaCsv % 1000 == 0
                        Conout("Inserindo registro " + cValToChar(nLinhaCsv))
                        IncProc("Inserindo registro " + cValToChar(nLinhaCsv) + " ...")
                        IncProc()
                    EndIf
                EndDo
            EndIf
            IncProc("Inserindo registro " + cValToChar(nLinhaCsv) + " ...")
            self:closeConnection()
        Else
            self:setErro("Não foi possível conectar na tabela especificada (" + self:cAlias + "). Verifique" )
            MsgAlert(self:getErro())
        EndIF
        self:oFile:Close()
    EndIf
Return

Method delete() Class PrjImpCsv
    Local lDelete := .F.
    If aTail(self:aHeader)[NOME_CAMPO] == "D_E_L_E_T_" .And. !Empty(self:aLinha[Len(self:aHeader)])
        lDelete := .T.
    EndIF
return lDelete

Method commit() Class PrjImpCsv
    local nLenaLinha  := len(self:aLinha)
    local nFields     := 0
    local xRegistro
    For nFields := 1 to nLenaLinha
        If self:aHeader[nFields][NOME_CAMPO] == self:cAlias + "_FILIAL"
            xRegistro := self:cFilialCsv
        Else
            xRegistro := self:validField(self:aLinha[nFields], nFields)
        EndIF
        (self:cAlias)->&(self:aHeader[nFields][NOME_CAMPO]) := xRegistro
    Next nFields
Return

Method prepare() Class PrjImpCsv
    local lExiste     := self:exists()
    If !lExiste
        (self:cAlias)->(DBAppend())
        self:commit()
    Else
        RecLock(self:cAlias, !lExiste)
        If !self:delete()
            self:commit()
        Else
            DBDelete()
        EndIf
        MsUnlock()
    EndIF
Return

Method validQuery(xValue, nIndField) Class PrjImpCsv
    Do Case
        Case !Empty(Val(xValue)) .And. Len(xValue) > 6 .And. !Empty(At("/",xValue))
            xValue := DTOS(CTOD(xValue))
    EndCase
return xValue

Method validField(xValue, nIndField) Class PrjImpCsv
    Do Case
        Case self:aHeader[nIndField][TIPO_CAMPO]=="D"
            xValue := CTOD(xValue)
        Case self:aHeader[nIndField][TIPO_CAMPO]=="N"
            xValue := Val(xValue)
        Case self:aHeader[nIndField][TIPO_CAMPO]=="L"
            If xValue == "T"
                xValue := .T.
            ElseIf xValue == "F"
                xValue := .F.
            EndIf
    EndCase
return xValue

Method openConnection() Class PrjImpCsv
    local lConnect := .F.
    IF  ChkFile(self:cAlias)
        DBSelectArea(self:cAlias)
        (self:cAlias)->(DBSetOrder(self:nIndex))
        lConnect := .T.
    EndIf
Return lConnect

Method closeConnection() Class PrjImpCsv
    DBUnlockAll()
    (self:cAlias)->(DBCloseArea())
Return

Method Destroy() Class PrjImpCsv
    self:cAlias   := ""
    self:cFilialCsv := ""
    self:nIndex   := 0
    self:oFile    := nil
    self:aHeader  := {}
    self:cKey     := ""
    self:aOrder   := {}
    self:aLinha   := {}
Return