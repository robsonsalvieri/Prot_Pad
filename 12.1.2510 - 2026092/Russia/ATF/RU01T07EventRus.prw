#include 'protheus.ch'
#include 'fwmvcdef.ch'
#INCLUDE "TOPCONN.CH"
#include "ru01t07.ch"

#DEFINE FIELDS_STRUCT_RELACAO 11
#DEFINE FIELDS_STRUCT_ID 3
#DEFINE OPERATION_INSERT '1'
#DEFINE OPERATION_STORNO '2'
#DEFINE N4_OPER_STORNO '1'

Class RU01T07EventRUS From FwModelEvent

Method New() CONSTRUCTOR
Method Activate()
Method AfterTTS()
Method BeforeTTS()
Method Abort()

Data aSN1RecList
Data aSN3RecList

EndClass

Method New() Class RU01T07EventRUS

    self:aSN1RecList := {}
    self:aSN3RecList := {}

Return Nil

Method Activate(oModel) Class RU01T07EventRUS
Local lRet := .T.
Local aArea := GetArea()
Local aAreaSN3 := {}
Local aAreaSN1 := {}
Local nI
Local aBlocked := {}
Local cBlocked := ''

    If oModel:GetOperation() == MODEL_OPERATION_INSERT

        oModel:LoadValue('F6NMASTER', 'F6N_FILIAL', cFilAnt)
        oModel:LoadValue('F6NMASTER', 'F6N_DATE', dDataBase)
        oModel:LoadValue('F6NMASTER', 'F6N_USRCOD', __cUserID)
        oModel:LoadValue('F6NMASTER', 'F6N_USER', FWSFAllUsers({__cUserID},{'USR_NOME'})[1][3])
        oModel:LoadValue('F6NMASTER', 'F6N_OPER', OPERATION_INSERT)
        oModel:LoadValue('F6NMASTER', 'F6N_UUID', RU01UUIDV4())

        aAreaSN1 := SN1->(GetArea())
        DBSELECTAREA('SN1')
        SN1->(DBSETORDER(1))

        aAreaSN3 := SN3->(GetArea())
        DBSELECTAREA('SN3')
        SN3->(DBSETORDER(1))

        (cArqTrab)->(DBGoTop())

        While (cArqTrab)->(!Eof())
            If  SN3->(DBSEEK( xFilial('SN3')+(cArqTrab)->N3_CBASE+(cArqTrab)->N3_ITEM+(cArqTrab)->N3_TIPO)) ;
                .AND. !Empty((cArqTrab)->N3_OK) .AND. AScan(self:aSN3RecList, SN3->(RecNo())) == 0
                If  SN3->(DBRLOCK(SN3->(RecNo())))
                    AAdd(self:aSN3RecList, SN3->(RecNo()))
                    If SN1->(DBSEEK(xFilial('SN1')+(cArqTrab)->N3_CBASE+(cArqTrab)->N3_ITEM)) .AND. AScan(self:aSN1RecList, SN1->(RecNo())) == 0  .AND. RU01T07006()
                        SN1->(DBRLOCK(SN1->(RecNo())))
                        AAdd(self:aSN1RecList, SN1->(RecNo()))
                    EndIf
                    If !(Empty(oModel:GetValue('F6OGRID', 'F6O_UUID')))
                        oModel:GetModel('F6OGRID'):AddLine()
                    Endif
                    oModel:LoadValue('F6OGRID', 'F6O_CBASE', (cArqTrab)->N3_CBASE)
                    oModel:LoadValue('F6OGRID', 'F6O_ITEM', (cArqTrab)->N3_ITEM)
                    oModel:LoadValue('F6OGRID', 'F6O_FADESC', (cArqTrab)->N1_DESCRIC)
                    oModel:LoadValue('F6OGRID', 'F6O_TIPO', (cArqTrab)->N3_TIPO)
                    oModel:LoadValue('F6OGRID', 'F6O_HISTOR', (cArqTrab)->N3_HISTOR)
                    oModel:LoadValue('F6OGRID', 'F6O_COMMEN', STR0017 + AllTrim(oModel:GetModel("F6OGRID"):GetValue("F6O_CBASE")) + "-" +;
                                    oModel:GetModel("F6OGRID"):GetValue("F6O_ITEM") + "/" + oModel:GetModel("F6OGRID"):GetValue("F6O_TIPO"))
                    oModel:LoadValue('F6OGRID', 'F6O_LIQVAL', (cArqTrab)->N3_LIQVAL1)
                    oModel:LoadValue('F6OGRID', 'F6O_NLQVAL', (cArqTrab)->N3_LIQVAL1)
                    oModel:LoadValue('F6OGRID', 'F6O_PERDEP', (cArqTrab)->N3_PERDEPR)
                    oModel:LoadValue('F6OGRID', 'F6O_NPERDP', (cArqTrab)->N3_PERDEPR) 
                    oModel:LoadValue('F6OGRID', 'F6O_TPDEPR', (cArqTrab)->N3_TPDEPR)
                    oModel:LoadValue('F6OGRID', 'F6O_NTPDPR', (cArqTrab)->N3_TPDEPR)
                    oModel:LoadValue('F6OGRID', 'F6O_SN3UID', (cArqTrab)->N3_UUID)
                    oModel:LoadValue('F6OGRID', 'F6O_DATSTR', oModel:GetModel("F6NMASTER"):GetValue("F6N_DATE"))
                    oModel:LoadValue('F6OGRID', 'F6O_UUID', RU01UUIDV4())
                    oModel:LoadValue('F6OGRID', 'F6O_F6NUID', oModel:GetModel("F6NMASTER"):GetValue("F6N_UUID"))
                    oModel:LoadValue('F6OGRID', 'F6O_BAIXA', (cArqTrab)->N3_BAIXA)
                    oModel:LoadValue('F6OGRID', 'F6O_SEQ', (cArqTrab)->N3_SEQ)
                    oModel:LoadValue('F6OGRID', 'F6O_SEQREA', (cArqTrab)->N3_SEQREAV)
                    oModel:LoadValue('F6OGRID', 'F6O_TPSALD', (cArqTrab)->N3_TPSALDO)                    
                    oModel:LoadValue('F6OGRID', 'F6O_OSPRDP', RU01T07007())
                Else
                    AAdd(aBlocked, AllTrim((cArqTrab)->N3_CBASE) + "-" + (cArqTrab)->N3_ITEM + "/" + (cArqTrab)->N3_TIPO)
                EndIf
            EndIf
            (cArqTrab)->(DBSkip())
        EndDo
        If !EMPTY( aBlocked )
            For nI := 1 to Len(aBlocked)
                cBlocked += aBlocked[nI] + CRLF
            Next nI
            MSGALERT(STR0018 + cBlocked + STR0019,;
                    STR0020)
        EndIf
        RestArea(aAreaSN1)
        RestArea(aAreaSN3)
        RestArea(aArea)

    EndIf
    If oModel:GetOperation() == MODEL_OPERATION_UPDATE
        oModel:LoadValue('F6NMASTER', 'F6N_OPER', OPERATION_STORNO)
    EndIf
    oModel:GetModel('F6OGRID'):SetNoInsertLine(.T.)

Return lRet

Method BeforeTTS(oModel) Class RU01T07EventRUS
Local nI
Local aArea := GetArea()
Local aAreaSN3 := SN3->(GetArea())
Local aAreaSN4 := Nil
Local cIdMov := ""
Local cOcorr := "71"
Local nSN4Rec
Local cSeq := ''

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        cSeq := RU09D03Nmb("CHGLIQ")
        oModel:LoadValue('F6NMASTER', 'F6N_LOT', cSeq)
    EndIf

    Begin Transaction

        DBSELECTAREA('SN3')
        SN3->(DBSetOrder(1))
        For nI := 1 to oModel:GetModel('F6OGRID'):Length()
            oModel:GetModel('F6OGRID'):GoLine(nI)
            If  !oModel:GetModel('F6OGRID'):IsDeleted(nI)
                If SN3->(DBSeek(xFilial('SN1') + oModel:GetValue('F6OGRID', 'F6O_CBASE') +;
                oModel:GetValue('F6OGRID','F6O_ITEM') + oModel:GetValue('F6OGRID', 'F6O_TIPO');
                 + oModel:GetValue('F6OGRID', 'F6O_BAIXA') + oModel:GetValue('F6OGRID', 'F6O_SEQ')))
                    RECLOCK('SN3', .F. )
                    If oModel:GetOperation() == MODEL_OPERATION_INSERT
                        oModel:LoadValue('F6OGRID', 'F6O_LOT', cSeq)
                        SN3->N3_LIQVAL1 := oModel:GetValue('F6OGRID', 'F6O_NLQVAL')
                        SN3->N3_PERDEPR := oModel:GetValue('F6OGRID', 'F6O_NPERDP')
                        SN3->N3_TPDEPR := oModel:GetValue('F6OGRID', 'F6O_NTPDPR')
                        SN3->N3_DTLQVL := oModel:GetValue('F6NMASTER', 'F6N_DATE')
                    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
                        SN3->N3_LIQVAL1 := oModel:GetValue('F6OGRID', 'F6O_LIQVAL')
                        SN3->N3_PERDEPR := oModel:GetValue('F6OGRID', 'F6O_PERDEP')
                        SN3->N3_TPDEPR := oModel:GetValue('F6OGRID', 'F6O_TPDEPR')
                        SN3->N3_DTLQVL := oModel:GetValue('F6NMASTER', 'F6N_DATE')
                    EndIf
                    MsUnlock()
                    aAreaSN4 := SN4->(GetArea())
                    If oModel:GetValue('F6OGRID', 'F6O_LIQVAL') != oModel:GetValue('F6OGRID', 'F6O_NLQVAL') .AND. oModel:GetOperation() == MODEL_OPERATION_INSERT
                        nSN4Rec := ATFXMOV(;
                            xFilial("SN3"),;
                            @cIdMov,;
                            dDataBase,;
                            cOcorr,;// занести новый тип операции в RU01XN4MOV()
                            oModel:GetValue('F6OGRID', 'F6O_CBASE'),;
                            oModel:GetValue('F6OGRID', 'F6O_ITEM'),;
                            oModel:GetValue('F6OGRID', 'F6O_TIPO'),;
                            oModel:GetValue('F6OGRID', 'F6O_BAIXA'),;
                            oModel:GetValue('F6OGRID', 'F6O_SEQ'),;
                            oModel:GetValue('F6OGRID', "F6O_SEQREA"),;
                            "1",;
                            ,;
                            oModel:GetValue('F6OGRID', "F6O_TPSALD"),;
                            Nil,;
                            ,;//aValues
                            ,;//aCompData
                            Nil,;
                            ,;//.T.
                            Nil,;
                            Nil,;
                            Nil,;
                            Nil,;
                            "RU07T01",;
                            oModel:GetValue('F6OGRID', 'F6O_UUID'))
                        If oModel:GetOperation() == MODEL_OPERATION_INSERT
                            SN4->(DBGoTo(nSN4Rec))
                            oModel:LoadValue('F6OGRID', 'F6O_SN4UID', SN4->N4_UID)
                        EndIf
                    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. oModel:GetValue('F6OGRID', 'F6O_LIQVAL') != oModel:GetValue('F6OGRID', 'F6O_NLQVAL')
                        SN4->(DBSetOrder(10))
                        If !empty(oModel:GetValue('F6OGRID', 'F6O_SN4UID')) .and.  SN4->(DBSeek(FWxFilial("SN4") +oModel:GetValue('F6OGRID', 'F6O_SN4UID')))
                            RecLock('SN4', .F.)
                            SN4->N4_STORNO := N4_OPER_STORNO
                            MsUnlock()
                        Endif
                    EndIf
                EndIf
            EndIf
        Next nI

        If aAreaSN4 != Nil 
            RestArea(aAreaSN4)
        EndIf
        RestArea(aAreaSN3)
        RestArea(aArea)

    End Transaction

Return Nil

Method AfterTTS() Class RU01T07EventRUS

    self:Abort()

Return Nil

Method Abort() Class RU01T07EventRUS
Local nI
Local aArea := {}
Local nSize

    DbSelectArea("SN1")
    aArea := SN1->(GetArea())
    SN1->(DbSetOrder(1))

    nSize := Len(self:aSN1RecList) 

    For nI := 1 to nSize
        SN1->(DBGoTo(self:aSN1RecList[1]))
        SN1->(DBRUNLOCK(self:aSN1RecList[1]))
        ADel(self:aSN1RecList, 1)
        ASize(self:aSN1RecList, Len(self:aSN1RecList) - 1)
    Next nI

    RestArea(aArea)
    DbSelectArea("SN3")
    aArea := SN3->(GetArea())
    SN3->(DbSetOrder(1))

    nSize := Len(self:aSN3RecList)

    For nI := 1 to nSize
        SN3->(DBGoTo(self:aSN3RecList[1]))
        SN3->(DBRUNLOCK(self:aSN3RecList[1]))
        ADel(self:aSN3RecList, 1)
        ASize(self:aSN3RecList, Len(self:aSN3RecList) - 1)
    Next nI

    RestArea(aArea)

Return .T.
