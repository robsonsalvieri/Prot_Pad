#Include "Protheus.ch"
#Include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 
#include "FILEIO.CH"
#include "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} FIXCOMREIN
FIX - Atualização de ambiente REINF (Compras)

@param cDataIni     Data inicio para busca dos documentos

@author rodrigo.mpontes 
@since 06/10/2023
/*/

Function FIXCOMREIN(cDataIni)

    Private aDadosDoc   := FixDoc(cDataIni)
    Private cQryP       := "P"
    Private cQryAlt     := ""

    If Len(aDadosDoc) > 0
        FIXDHR(aDadosDoc)
    Endif

Return 

/*/{Protheus.doc} FixDoc
Query de busca pelos documentos a serem atualizados para o REINF

@param cDataIni     Data inicio para busca dos documentos

@author rodrigo.mpontes 
@since 06/10/2023
/*/

Static Function FixDoc(cDataIni) 

    Local cQry      := ""
    Local cQryStat  := ""
    Local cF1Ali    := ""
    Local oFindF1   := Nil
    Local aDocs     := {}
    Local nPosDoc   := 0

    cF1Ali     := GetNextAlias() 

    oFindF1 := FWPreparedStatement():New()

    cQry := " SELECT F1.F1_FILIAL, F1.F1_TIPO, F1.F1_DOC, F1.F1_SERIE, F1.F1_FORNECE, F1.F1_LOJA, D1.D1_ITEM, D1.D1_COD, F2Q.F2Q_NATREN, F1.F1_DTDIGIT FROM " + RetSqlName("SF1") + " F1"

    cQry += " INNER JOIN " + RetSqlName("SD1") + " D1"
    cQry += "       ON F1.F1_DOC = D1.D1_DOC"
    cQry += "       AND F1.F1_SERIE = D1.D1_SERIE"
    cQry += "       AND F1.F1_FORNECE = D1.D1_FORNECE"
    cQry += "       AND F1.F1_LOJA = D1.D1_LOJA"
    cQry += "       AND D1.D_E_L_E_T_ = ' '"
    cQry += "       AND D1.D1_FILIAL = '" + fwxFilial("SD1") + "'"

    cQry += " INNER JOIN " + RetSqlName("F2Q") + " F2Q"
    cQry += "       ON F2Q.F2Q_PRODUT = D1.D1_COD"
    cQry += "       AND F2Q.F2Q_NATREN <> ''"
    cQry += "       AND F2Q.D_E_L_E_T_ = ' '"
    cQry += "       AND F2Q.F2Q_FILIAL = '" + fwxFilial("F2Q") + "'"

    cQry += " INNER JOIN " + RetSqlName("SE2") + " E2"
    cQry += "       ON E2.E2_NUM = F1.F1_DOC"
    cQry += "       AND E2.E2_FORNECE = F1.F1_FORNECE"
    cQry += "       AND E2.E2_LOJA = F1.F1_LOJA"
    cQry += "       AND (E2.E2_SALDO > 0 OR (E2.E2_SALDO = 0 AND E2.E2_BAIXA >= '20230901'))" 
    cQry += "       AND E2.E2_ORIGEM IN ('MATA100','MATA103')"
    cQry += "       AND E2.D_E_L_E_T_ = ' '"
    cQry += "       AND E2.E2_FILIAL = '" + fwxFilial("SE2") + "'" 

    cQry += " WHERE F1.D_E_L_E_T_ = ' '"
    cQry += " AND F1.F1_STATUS = 'A'" 
    cQry += " AND F1.F1_TIPO IN ('N','C')" 
    cQry += " AND F1.F1_FILIAL = '" + fwxFilial("SF1") + "'"
    cQry += " AND F1.F1_EMISSAO >= '" + cDataIni + "' "
    cQry += " GROUP BY F1.F1_DTDIGIT, F1.F1_FILIAL,F1.F1_TIPO,F1.F1_DOC,F1.F1_SERIE,F1.F1_FORNECE,F1.F1_LOJA,D1.D1_ITEM,D1.D1_COD,F2Q.F2Q_NATREN"
    cQry += " ORDER BY F1.F1_DTDIGIT ASC, F1.F1_DOC, F1.F1_SERIE, F1.F1_FORNECE, F1.F1_LOJA, D1.D1_ITEM"

    If ExistBlock("FIXQRYR")
        cQryAlt := ExecBlock("FIXQRYR",.F.,.F.,{"02","",cQry}) 
        If ValType(cQryAlt) == "C" .And. !Empty(cQryAlt)
            cQry    := cQryAlt
            cQryP   := "C" //Indica que usuario customizou query
        EndIf	   
    EndIf

    cQry := ChangeQuery(cQry)

    oFindF1:SetQuery(cQry) 

    cQryStat := oFindF1:GetFixQuery()
    MpSysOpenQuery(cQryStat,cF1Ali) 

    DbSelectArea("DHR")
    DHR->(DbSetOrder(1))

    While (cF1Ali)->(!EOF()) 
        If !DHR->(DbSeek(fwxFilial("DHR") + (cF1Ali)->F1_DOC + (cF1Ali)->F1_SERIE + (cF1Ali)->F1_FORNECE + (cF1Ali)->F1_LOJA + (cF1Ali)->D1_ITEM)) 
            nPosDoc := aScan(aDocs,{|x| x[1] == (cF1Ali)->F1_FILIAL .And. x[2] == (cF1Ali)->F1_DOC .And. x[3] == (cF1Ali)->F1_SERIE .And. x[4] == (cF1Ali)->F1_FORNECE .And. x[5] == (cF1Ali)->F1_LOJA})
            If nPosDoc == 0
                aAdd(aDocs,{(cF1Ali)->F1_FILIAL,(cF1Ali)->F1_DOC,(cF1Ali)->F1_SERIE,(cF1Ali)->F1_FORNECE,(cF1Ali)->F1_LOJA,(cF1Ali)->D1_ITEM,(cF1Ali)->D1_COD,(cF1Ali)->F2Q_NATREN})
            Elseif nPosDoc > 0
                aDocs[nPosDoc,6] += "|" + (cF1Ali)->D1_ITEM
                aDocs[nPosDoc,7] += "|" + (cF1Ali)->D1_COD
                aDocs[nPosDoc,8] += "|" + (cF1Ali)->F2Q_NATREN
            Endif
        Endif
        (cF1Ali)->(DbSkip())
    Enddo

    (cF1Ali)->(DbCloseArea())

Return aDocs

Static Function FIXDHR(aDadosDoc)

    Local nI            := 0
    Local nX            := 0
    Local nY            := 0
    Local aAuxIt        := {}
    Local aAuxPrd       := {}
    Local aAuxNat       := {}
    Local aInDHR	    := {"DHR_NATREN"}
    Local aNotDHR		:= {"DHR_FILIAL","DHR_DOC","DHR_SERIE","DHR_FORNEC","DHR_LOJA"}
    Local aColNatRend   := {}
    Local aFKW          := {}
    Local lGeraDHR      := .F.
    Local lGeraFKW      := .F.
    Local lRegNew       := .F.
    Local cChvLog       := ""
    Local aCpoD1        := {}
    Local aCpoD1M       := {}
    
    Private aHeadDHR    := COMXHDCO("DHR",aInDHR)
    Private aHdSusDHR   := COMXHDCO("DHR",,aNotDHR)
    Private aColsDHR    := {}
    Private aCoSusDHR   := {}
    Private aHeader     := {}
    Private cNFiscal    := ""
    Private cSerie      := ""
    Private cA100For    := ""
    Private cLoja       := ""

    aCpoD1  := FWSX3Util():GetListFieldsStruct("SD1")
    If Len(aCpoD1) > 0
        For nI := 1 To Len(aCpoD1)
            If aCpoD1[nI,2] == "M" 
                aAdd(aCpoD1M,aCpoD1[nI,1])
            Endif
        Next nI
    Endif

    aHeader := COMXHDCO("SD1",,aCpoD1M) 

    DbSelectArea("SF1")
    SF1->(DbSetOrder(1))

    DbSelectArea("SD1")
    SD1->(DbSetOrder(1))

    For nI := 1 To Len(aDadosDoc)
        lGeraDHR      := .F.
        lGeraFKW      := .F.

        aAuxIt  := Separa(aDadosDoc[nI,6],"|")
        aAuxPrd := Separa(aDadosDoc[nI,7],"|")
        aAuxNat := Separa(aDadosDoc[nI,8],"|")

        If SF1->(DbSeek(aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5]))
            If Len(aAuxIt) > 0 .And. Len(aAuxNat) > 0 .And. Len(aAuxPrd) > 0
                aColsDHR := {}
                For nX := 1 To Len(aAuxIt)
                    aColNatRend := {}
                    aAdd(aColNatRend,Array(Len(aHeadDHR)+1))
                    For nY := 1 To Len(aHeadDHR)
                        aColNatRend[1,nY] := aAuxNat[nX]
                    Next nY
                    aColNatRend[1,Len(aHeadDHR)+1] := .F.

                    aAdd(aColsDHR,{aAuxIt[nX],aColNatRend}) 

                    If SD1->(DbSeek(aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5] + aAuxPrd[nX] + aAuxIt[nX]))
                        A103INCDHR(aHeadDHR,aColsDHR,nX,.F.) //Gravação DHR
                        lGeraDHR := .T.
                    Endif
                Next nX
            Endif
        Endif

        aFKW := FIXFKW(aDadosDoc[nI,1],aDadosDoc[nI,2],aDadosDoc[nI,3],aDadosDoc[nI,4],aDadosDoc[nI,5])
        If Len(aFKW) > 0
            cNFiscal    := aDadosDoc[nI,2]
            cSerie      := aDadosDoc[nI,3]
            cA100For    := aDadosDoc[nI,4]
            cLoja       := aDadosDoc[nI,5]
            A103FKW("I",aFKW[1],aFKW[2]) //Gravação FKW
            lGeraFKW    := .T.
        Endif

        If ChkFile("REINFLOG")
            DbSelectArea("REINFLOG") 
            DbSetIndex('IND1')
            cChvLog := aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5]
            lRegNew := REINFLOG->(MsSeek("DE" + cChvLog))
            If RecLock("REINFLOG",!lRegNew)
                REINFLOG->GRUPO    := cEmpAnt
                REINFLOG->EMPFIL   := aDadosDoc[nI,1]
                REINFLOG->DATAPROC := FWTimeStamp(2, DATE(), TIME())
                REINFLOG->TIPO     := "DE"
                REINFLOG->CHAVE    := aDadosDoc[nI,1]+aDadosDoc[nI,2]+aDadosDoc[nI,3]+aDadosDoc[nI,4]+aDadosDoc[nI,5]
                REINFLOG->COMDHR   := Iif(lGeraDHR,"I","") //I=Insert
                REINFLOG->COMFKW   := Iif(lGeraFKW,"I","") //I=Insert
                If REINFLOG->(FieldPos("CQUERYP")) > 0 
                    REINFLOG->CQUERYP  := cQryP
                Endif
                REINFLOG->(MsUnlock()) 
            Endif
        Endif
    Next nI

Return

Static Function FIXFKW(cFil,cDoc,cSer,cFor,cLoj)

    Local aRet      := {}
    Local aITD1     := {}
    Local aRecE2    := {}
    Local cQry      := ""
    Local cQryStat  := ""
    Local cD1Ali    := ""
    Local oFindD1   := Nil
    Local cE2Ali    := ""
    Local oFindE2   := Nil
    Local nI        := 0

    //Busca ITENS (SD1)
    cD1Ali     := GetNextAlias()

    oFindD1 := FWPreparedStatement():New()

    cQry    := " SELECT "

    For nI := 1 To Len(aHeader)
        If nI == 1
            cQry += aHeader[nI,2]
        Else
            cQry += ", " + aHeader[nI,2]
        Endif
    Next nI

    cQry    += " FROM " + RetSqlName("SD1") + " D1"
    cQry    += " WHERE D1.D1_FILIAL     = ?"
    cQry    += "   AND D1.D1_DOC        = ?"
    cQry    += "   AND D1.D1_SERIE      = ?"
    cQry    += "   AND D1.D1_FORNECE    = ?"
    cQry    += "   AND D1.D1_LOJA       = ?"
    cQry    += "   AND D1.D_E_L_E_T_ =' ' "
    cQry := ChangeQuery(cQry)

    oFindD1:SetQuery(cQry) 

    oFindD1:SetString(1,cFil)
    oFindD1:SetString(2,cDoc)
    oFindD1:SetString(3,cSer)
    oFindD1:SetString(4,cFor)
    oFindD1:SetString(5,cLoj)

    cQryStat := oFindD1:GetFixQuery()
    MpSysOpenQuery(cQryStat,cD1Ali)

    While (cD1Ali)->(!EOF())
        aadd(aITD1,Array(Len(aHeader)+1))
        For nI := 1 To Len(aHeader)
            aITD1[Len(aITD1),nI] := (cD1Ali)->&(aHeader[nI,2])
        Next nI
        aITD1[Len(aITD1),Len(aHeader)+1] := .F.
        (cD1Ali)->(DbSkip())
    Enddo

    (cD1Ali)->(DbCloseArea())

    //Busca TITULOS (SE2)
    cE2Ali     := GetNextAlias()

    oFindE2 := FWPreparedStatement():New()

    cQry    := " SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO, SE2.R_E_C_N_O_ SE2RECNO"
    cQry    += " FROM " + RetSqlName("SE2") + " SE2"
    cQry    += " WHERE SE2.E2_FILIAL  = ?"
    cQry    += "   AND SE2.E2_FORNECE = ?"
    cQry    += "   AND SE2.E2_LOJA    = ?"
    cQry    += "   AND SE2.E2_PREFIXO = ?"
    cQry    += "   AND SE2.E2_NUM     = ?"
    cQry    += "   AND SE2.E2_TIPO    = ?"
    cQry    += "   AND SE2.D_E_L_E_T_ =' ' "
    cQry := ChangeQuery(cQry)

    oFindE2:SetQuery(cQry) 

    oFindE2:SetString(1,cFil)
    oFindE2:SetString(2,cFor)
    oFindE2:SetString(3,cLoj)
    oFindE2:SetString(4,GetAdvFVal("SF1","F1_PREFIXO", cFil + cDoc + cSer + cFor + cLoj,1))
    oFindE2:SetString(5,cDoc)
    oFindE2:SetString(6,MVNOTAFIS)

    cQryStat := oFindE2:GetFixQuery()
    MpSysOpenQuery(cQryStat,cE2Ali)

    While (cE2Ali)->(!EOF())
        aadd(aRecE2,(cE2Ali)->SE2RECNO)
        (cE2Ali)->(DbSkip())
    Enddo

    (cE2Ali)->(DbCloseArea())

    If Len(aITD1) > 0 .And. Len(aRecE2) > 0
        aAdd(aRet,aITD1)
        aAdd(aRet,aRecE2)
    Endif

Return aRet
