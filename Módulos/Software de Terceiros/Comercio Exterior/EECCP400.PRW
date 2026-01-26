#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'eeccp400.ch'

/*/{Protheus.doc} EECCP400
    Rotina de catálogo de produto para o módulo de exportação SIGAEEC

    @type  Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return nil
/*/
function EECCP400()
    local aArea       := GetArea()
    local lProc       := .T.
    local cModoAcEK9  := FWModeAccess("EK9",3)
    local cModoAcEKA  := FWModeAccess("EKA",3)
    local cModoAcEKB  := FWModeAccess("EKB",3)
    local cModoAcEKD  := FWModeAccess("EKD",3)
    local cModoAcEKE  := FWModeAccess("EKE",3)
    local cModoAcEKF  := FWModeAccess("EKF",3)
    local cModoAcSB1  := FWModeAccess("SB1",3)
    local cModoAcSA2  := FWModeAccess("SA2",3)
    local oBrowse
    local lLibAccess  := .F.
    local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

    // privates do fonte EICCP400
    private aRotina      := {}
    private aAtrib       := {}
    private cNcm         := "          "
    private cModalEK9    := ""
    private cPrdRefEK9   := ""
    Private cFilRefEK9   := ""
    private lRetAux      :=.T.
    private lMultiFil    := cModoAcEK9 == "C" .and. ( cModoAcSB1 == "E" .and. cModoAcSA2 == "E" )
    Private oJsonAtt     := jsonObject():New()
    Private oChannel
    Private lCanWrite := .T.
    Private oCpObrig  := jSonObject():New()
    Private oCondicao := jsonObject():New()
    Private lCpPOUIOK := .F.
    Private lPOUIOKCM := .F.
    Private lPOUIOKLD := .F.
    Private lAltPOUI  := .F.
    private cFilSB1F3  := ""
    private cFilSA2F3  := ""

    if lExecFunc
        FwBlkUserFunction(.T.)
    endif

    lLibAccess := AmIin(29)

    if lExecFunc
        FwBlkUserFunction(.F.)
    endif

    if lLibAccess

	    if( !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF), ( lProc := .F. , EasyHelp(STR0001,STR0002)), nil ) // "Modo de compartilhamento está diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF." ### "Atenção"
	
	    if lProc
	        oBrowse := FWMBrowse():New()
	        oBrowse:SetAlias("EK9")
	        oBrowse:SetMenuDef("EECCP400")
	        oBrowse:SetDescription(STR0003) // "Catálogo de Produtos"
	        oBrowse:AddFilter(STR0004,"@EK9_MODALI = '2'", .F., .T.) // "Modalidade de Catálogo de Produtos"
	        oBrowse:Activate()
		endif

    endif

    restArea(aArea)

return nil

/*/{Protheus.doc} ViewDef
    Função para definição da Viewdef (EICCP400) 
    @type  Static Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return oView, objeto, View do modelo de dados EICCP400
/*/
static function ViewDef()
    local oView := FWLoadView("EICCP400")
return oView

/*/{Protheus.doc} Menudef
    Função para definição da Menudef
    @type  Static Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return aRotina, vetor, opções de manutenção da rotina
/*/
static function Menudef()
    local aRotina := {}

    //Adiciona os botões na MBROWSE
    ADD OPTION aRotina TITLE STR0005 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EECCP400" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.EECCP400" OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.EECCP400" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.EECCP400" OPERATION 5 ACCESS 0 // "Excluir"

return aRotina
