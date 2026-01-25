#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapJson
Classe para montagem do JSON

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapJson
        
    Method New() Constructor
    Method SetAtributo(xValor, cTipo)
    Method FormatDatHora(cData, cHora)
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New() Class PLMapJson
Return self


//-----------------------------------------------------------------
/*/{Protheus.doc} setAtributo
Set Atributo no JSON

@author Vinicius Queiros Teixeira
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method SetAtributo(xValor, cTipo) Class PLMapJson
    
    Local xRetorno 
    Local dAuxData := CToD(" / / ")

    Default xValor := ""
    Default cTipo := ""

    If !Empty(xValor)
        xRetorno := xValor
        Do Case
            Case cTipo == "N" .And. ValType(xRetorno) == "C"
                xRetorno := Val(xRetorno)

            Case cTipo == "C" .And. ValType(xRetorno) == "N"
                xRetorno := cValToChar(xRetorno)
            
            Case cTipo == "D" .And. ValType(xRetorno) == "C"
                dAuxData := CToD(xRetorno)
                If Empty(dAuxData)
                    xRetorno := ""
                EndIf
        EndCase

        If ValType(xRetorno) == "C" .And. !Empty(xRetorno)
            xRetorno := Alltrim(xRetorno) 
        EndIf        
    Else
        xRetorno := ""
    EndIf

Return xRetorno


//-----------------------------------------------------------------
/*/{Protheus.doc} FormatDatHora
Data e Hora no formato: 23/10/2017 17:35:29

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method FormatDatHora(cData, cHora) Class PLMapJson

    Local cDataHora := ""
    Local cFormatData := ""
    Local cFormatHora := ""

    If !Empty(cData) .And. !Empty(cHora)
        cFormatData := Substr(cData, 7, 2)+"/"+Substr(cData, 5, 2)+"/"+Substr(cData, 1, 4)

        If Len(Alltrim(cHora)) == 4
            cFormatHora := Substr(cHora, 1, 2)+":"+Substr(cHora, 3, 2)+":00"
        Else
            cFormatHora := Substr(cHora, 1, 2)+":"+Substr(cHora, 3, 2)+":"+Substr(cHora, 5, 2)
        EndIf

        cDataHora := cFormatData+" "+cFormatHora
    EndIf

Return cDataHora
