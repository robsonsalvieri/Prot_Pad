#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF95.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAF95
Subprocesso das Fontes de Integração
@type Function
@author Valdemar Roberto Mognon
@since 06/12/2023
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF95()
(examples)
@see (links_or_references)
*/

Function TMSAF95()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DNO")
oBrowse:SetMenuDef("TMSAF95")
oBrowse:SetDescription(STR0001)	//-- Subprocesso das Fontes de Integração
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 06/12/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAF95" OPERATION 2 ACCESS 0	//-- Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAF95" OPERATION 3 ACCESS 0	//-- Incluir
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAF95" OPERATION 4 ACCESS 0	//-- Alterar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAF95" OPERATION 5 ACCESS 0	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 06/12/2023
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel
Local oStruDNO := FwFormStruct(1,"DNO")

oModel := MpFormModel():New("TMSAF95", /*bPreValidacao*/, /*bPosValid*/ , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Subprocesso das Fontes de Integração

//-- Cabeçalho
oModel:AddFields("MdFieldDNO",,oStruDNO,,,)
oModel:SetPrimaryKey({"DNO_CODPRC"})
oModel:GetModel("MdFieldDNO"):SetDescription(STR0001)	//-- Subprocesso das Fontes de Integração

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 06/12/2023
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAF95")
Local oStruDNO := FwFormStruct(2,"DNO")
Local oView

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",100)

//-- Cria área da tabela pai
oView:AddField("VwFieldDNO",oStruDNO,"MdFieldDNO") 
oView:EnableTitleView("VwFieldDNO",STR0001)	//-- Subprocesso das Fontes de Integração
oView:SetOwnerView("VwFieldDNO","Cabecalho")

Return oView
