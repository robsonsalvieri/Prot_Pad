#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UPD_EFF
    Função para atualização de tabelas do módulo SIGAEFF

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
function UPD_EFF( cRelease )
	local oUpd       := nil
	local cRelFinish := ""

	default cRelease := GetRPORelease()

	cRelFinish := SubSTR(cRelease,Rat(".",cRelease)+1)

	if existfunc("TELinkDado")
		oUpd := AVUpdate01():New()
		oUpd:lSimula := .F.
		oUpd:aChamados := {}

		aAdd(oUpd:aChamados,  {nModulo, {|o| TELinkDado(o)}} )
		oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."

		oUpd:Init(,.T.) 
	endif

return nil
