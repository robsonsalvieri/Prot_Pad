#INCLUDE "PROTHEUS.CH"
#INCLUDE "TDSBIRT.CH"
#INCLUDE "FileIO.CH"


Function RU07R01()

    Local oRpt As object
    local lR13 As logical
    local lR15 As logical
    local lR30 As logical
    Local cType As Char
    Local o2NDFL As object

    Local cTN As Char
    Local cDate As Date

    Pergunte('RU07R01DS',.T.)

    cTN := MV_PAR01
    cDate := MV_PAR02

    o2NDFL := RU2NDFL():New(cTN, cDate)
    o2NDFL:GetData()

    lR13  := o2NDFL:lRate13
    lR15  := o2NDFL:lRate15
    lR30  := o2NDFL:lRate30
    
    If lR30
        cType := '30'
    ElseIf lR13
        cType := '13'
    Else
        cType := '15'
    EndIf
    
    AddDataFile(cType)
    DEFINE REPORT oRpt NAME RU07R01 TITLE "2NDFL"
    ACTIVATE REPORT oRpt

    If lR15
        AddDataFile('15')
        DEFINE REPORT oRpt NAME RU07R01 TITLE "2NDFL"
        ACTIVATE REPORT oRpt
    EndIf

    FErase("2NDFL.INI")

Return Nil

Function AddDataFile(caData)
    
    //VALTYPE(caData)
    If File("2NDFL.INI")
        FErase("2NDFL.INI")
    EndIf 

    If !File("2NDFL.INI")
        nHdlCusto := MSFCreate("2NDFL.INI",0)
        If nHdlCusto == -1
            Help(" ",1,"CTB_ERROR")
            Final("Erro F_" + Str(Ferror(),2) + " em 2NDFL.INI")
        EndIf
        
        FWrite(nHdlCusto,caData)
        FClose(nHdlCusto)
    EndIf
Return