#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP12.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} fVacCount
    Contagem para o inicio das férias
    @type  Function
    @author henrique ferreira
    @since 15/03/2023
    @version version
    @param cBranchVld - Filial do Funcionário
           cMatSRA    - Matrícula do Funcionário
    @return .T.
    /*/
Function fVacCount(cBranchVld, cMatSRA, aQryParam, oVac)

Local aArea     := GetArea()
Local dDtIni    := ctod("//")
Local dDate     := dDataBase
Local nPos      := 0

DEFAULT cBranchVld := ""
DEFAULT cMatSRA    := ""
DEFAULT oVac       := JsonObject():New()

If !Empty( cBranchVld ) .And. !Empty( cMatSRA )

    //Obtem a data do queryparam que existe apenas na automação de testes
    If ( nPos := aScan(aQryParam, {|x| x[1] == "DDATEROBOT" })) > 0
        dDate := sToD( aQryParam[nPos,2] )
    EndIf

    If fRetFer( cBranchVld, cMatSRA, @dDtIni, dDate )
        oVac["initVacation"] := formatGMT( dToS(dDtIni), .T. )
        oVac["statusVacation"] := "calculated"
    Else    
        If fRetSRF( cBranchVld, cMatSRA, @dDtIni, dDate )
            oVac["initVacation"] := formatGMT( dToS(dDtIni), .T. )
            oVac["statusVacation"] := "approved"
        EndIf
    EndIf
Endif

RestArea( aArea )
    
Return .T.


Static Function fRetSRF( cBranchVld, cMatSRA, dDtIni, dDate )

Local cQuery := GetNextAlias()
Local aArea  := GetArea()
Local lRet   := .F.

DEFAULT cBranchVld := ""
DEFAULT cMatSRA    := ""
DEFAULT dDtIni     := ctod("//")
DEFAULT dDate      := dDataBase

If !Empty( cBranchVld ) .And. !Empty( cMatSRA )

    BEGINSQL ALIAS cQuery
        COLUMN RF_DATAINI AS DATE
        COLUMN RF_DATINI2 AS DATE
        COLUMN RF_DATINI3 AS DATE
    SELECT
        SRF.RF_FILIAL,
        SRF.RF_MAT,
        SRF.RF_DATABAS, 
        SRF.RF_DATAINI,
        SRF.RF_DATINI2,
        SRF.RF_DATINI3
    FROM %table:SRF% SRF
    WHERE
        SRF.RF_FILIAL = %exp:cBranchVld% AND
        SRF.RF_MAT = %exp:cMatSRA% AND
        SRF.RF_STATUS = '1' AND
        SRF.%notDel%
        ORDER BY 3
    ENDSQL

    If (cQuery)->(!Eof())
        If !Empty( (cQuery)->RF_DATAINI ) .And. (cQuery)->RF_DATAINI > dDate
            dDtIni := (cQuery)->RF_DATAINI
        elseif !Empty( (cQuery)->RF_DATINI2 ) .And. (cQuery)->RF_DATINI2 > dDate
            dDtIni := (cQuery)->RF_DATINI2
        elseif !Empty( (cQuery)->RF_DATINI3 ) .And. (cQuery)->RF_DATINI3 > dDate
            dDtIni := (cQuery)->RF_DATINI3
        Endif
    EndIf
Endif

lRet := !Empty( dDtIni )
RestArea( aArea )

Return lRet

Static Function fRetFer( cBranchVld, cMatSRA, dDtIni, dDate )

Local aArea  := GetArea()
Local lRet   := .F.
Local cQuery := GetNextAlias()

DEFAULT cBranchVld := ""
DEFAULT cMatSRA    := ""
DEFAULT dDtIni     := cTod("//")
DEFAULT dDate      := dDataBase


If !Empty( cBranchVld ) .And. !Empty( cMatSRA )

    BEGINSQL ALIAS cQuery
        COLUMN RH_DATAINI AS DATE
    SELECT
        SRH.RH_FILIAL,
        SRH.RH_MAT, 
        SRH.RH_DATAINI
    FROM %table:SRH% SRH
    WHERE
        SRH.RH_FILIAL = %exp:cBranchVld% AND
        SRH.RH_MAT = %exp:cMatSRA% AND
        SRH.RH_DATAINI > %exp:dDate% AND
        SRH.%notDel%
    ENDSQL

    If (cQuery)->(!Eof())
        lRet     := .T.
        dDtIni   := (cQuery)->RH_DATAINI
    EndIf
Endif

RestArea( aArea )

Return lRet
