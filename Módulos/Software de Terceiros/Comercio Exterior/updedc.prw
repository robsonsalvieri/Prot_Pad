#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UPD_EDC
    Função para atualização de tabelas do módulo SIGAEDC

    @type  Function
    @author bruno kubagawa
    @since 31/05/2023
    @version version
    @param cRelease, caractere, release do sistema
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
function UPD_EDC( cRelease )
    //local oUpd       := nil
    local cRelFinish := ""

    default cRelease := GetRPORelease()

    cRelFinish := SubSTR(cRelease,Rat(".",cRelease)+1)

    /*oUpd := AVUpdate01():New()
    oUpd:lSimula := .F.
    oUpd:aChamados := {}

    oUpd:Init(,.T.) */

return nil