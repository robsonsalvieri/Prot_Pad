#include "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "totvs.ch"
#INCLUDE "Fileio.ch"

/*/{Protheus.doc} GrvI16
    (long_description)
    @type  Function
    @author user
    @since 26/09/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GrvI16(oData,oJsonA)
    Local nI:=0
    Local lInclui := .T.
    Local nInsert := 1
    Local nUpdate := 1

    If ValType(oJsonA['companyGroup']) <> "U" 
        //Se for diferente, limpa o ambiente e seta o novo company group
        If FindFunction( "totvs.protheus.backoffice.ba.insights.util.settingEnvironment", .T. )
            totvs.protheus.backoffice.ba.insights.util.settingEnvironment(oJsonA['companyGroup'], "" ,"CTB" , {"I16"})
        Endif
        aDicSX2 := FwSX2Util():GetSX2Data('I16', {"X2_ARQUIVO"}, .T.)
        if len(aDicSX2) > 0
            aAlerts := oData["alerts"]
            DbSelectArea("I16")
            DbSetOrder(5)
            CONOUT('Inicio da gravação')
            For nI:= 1 to LEN(aAlerts)
                // I16_FILIAL+I16_BRANCH+I16_ID+I16_MATHID
                // I16_FILIAL+I16_TBNAME+I16_PINSID
                cChave:= PADR(aAlerts[nI]["branch"],TAMSX3("I16_FILIAL")[1])+;
                PADR(aAlerts[nI]["table_name"], TAMSX3("I16_TBNAME")[1])+;
                PADR(aAlerts[nI]["msuidt"],TAMSX3("I16_PINSID")[1])
            
                lInclui := !I16->(DbSeek(cChave)) 
                RecLock("I16",lInclui)
                if lInclui
                    I16->I16_FILIAL := aAlerts[nI]["branch"]
                    I16->I16_BRANCH := aAlerts[nI]["branch"] 
                    I16->I16_DTRESP := stod(substr(oJsonA["dataResponse"],1,4)+substr(oJsonA["dataResponse"],6,2)+substr(oJsonA["dataResponse"],9,2))
                    
                    /*Campos usados para filtragem do front*/
                    I16->I16_SRCTB  := aAlerts[nI]["src_table"]
                    I16->I16_DSTABL := aAlerts[nI]["dst_table"]
                    I16->I16_MATHID := cValToChar(aAlerts[nI]["match_id"])//CONVERTER PARA string
                    I16->I16_TBNAME := aAlerts[nI]["table_name"]
                    I16->I16_FILTER := aAlerts[nI]["dst_table"]+aAlerts[nI]["src_table"]//que filtro aplicar?
                    /*****************************************/
                    
                    I16->I16_ID     := aAlerts[nI]["msuidt"]+aAlerts[nI]["table_name"]// Id deve vir do backend

                    I16->I16_INSIGH := oJsonA["insight"]
                    I16->I16_ITTYPE := aAlerts[nI]["item_type"]
                    I16->I16_PINSID := aAlerts[nI]["msuidt"]
                    I16->I16_MDMUPD := aAlerts[nI]["mdmLastUpdated"]
                    I16->I16_MODULO := oJsonA["modulo"]
                    I16->I16_RULE   := aAlerts[nI]["rule"]
                    I16->I16_SCORE  := aAlerts[nI]["score"]
                    I16->I16_STATUS := "AVAILABLE"
                    I16->I16_TENID  := oJsonA["tenantID"]
                    I16->I16_TRANID := oJsonA["transactionID"]
                    nInsert++
                Else
                    If (I16->I16_STATUS !="CONCILIATED")
                        I16->I16_STATUS := "RESEND"
                    EndIf
                    nUpdate++
                endif
                MsUnlock()
            Next
            conout("Registros inseridos:"+CVALTOCHAR( nInsert )+", Atualizados: "+ cValtoChar(nUpdate)+" Registros contabilizados:"+CVALTOCHAR( nI ))
        else
            conout("Tabela I16 não existe na empresa: " + oJsonA['companyGroup'])
        endif
    Else
        conout("Json com erro, Verifique o payload gerado no backend , registros nao serão gravados no banco de dados!")
    Endif
Return 
