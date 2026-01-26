#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} rmixFilial
Função que retorna as filiais utilizadas na integração a partir
do Assinante e Processo

@type    Function
@author  Rafael Tenorio da Costa
@since   12/03/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Function rmixFilial(cAssinante, cProcesso, cTipo)

    Local aArea     := getArea()
    Local aAreaMHP  := MHP->( getArea() )    
    Local cRetorno  := ""
    Local aRetorno  := {}

    Default cTipo   := "1"

    MHP->( dbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
    if MHP->( dbSeek(xFilial("MHP") + padR(cAssinante, tamSx3("MHP_CASSIN")[1]) + padR(cProcesso, tamSx3("MHP_CPROCE")[1])  + cTipo) )

        if MHP->(columnPos("MHP_LAYFIL")) > 0 .and. !empty( strTran(MHP->MHP_LAYFIL, CRLF, "") )
            cRetorno := MHP->MHP_LAYFIL
        else
            cRetorno := MHP->MHP_FILPRO
        endIf

        aRetorno := strTokArr( alltrim(cRetorno), ";")
    endIf

    ljGrvLog("RmixFilial", "Retorno da função rmixFilial:", aRetorno)

    restArea(aAreaMHP)
    restArea(aArea)

return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} rmixFilCmp
Função que retorna o nome do campo que tem as filiais utilizadas na integração a partir
do Assinante e Processo

@type    Function
@author  Rafael Tenorio da Costa
@since   17/04/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Function rmixFilCmp(cAssinante, cProcesso, cTipo)

    Local aArea     := getArea()
    Local aAreaMHP  := MHP->( getArea() )
    Local cRetorno  := "MHP_FILPRO"

    Default cTipo   := "1"

    MHP->( dbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
    if MHP->( dbSeek(xFilial("MHP") + padR(cAssinante, tamSx3("MHP_CASSIN")[1]) + padR(cProcesso, tamSx3("MHP_CPROCE")[1]) + cTipo) )

        if MHP->(columnPos("MHP_LAYFIL")) > 0 .and. !empty( strTran(MHP->MHP_LAYFIL, CRLF, "") )
            cRetorno := "MHP_LAYFIL"
        endIf
    endIf

    ljGrvLog("RmixFilial", "Retorno da função rmixFilCmp:", cRetorno)

    restArea(aAreaMHP)
    restArea(aArea)

return cRetorno
