#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA6010.ch"

/*/{Protheus.doc} LOJA6010
    Cadastro de Codigos Referenciais
    @type    function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
/*/
Function LOJA6010()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MG5')
    oBrowse:SetDescription(STR0001) //"Códigos Referenciais"

    If hasSmartX() //Proteção para garantir que o ambiente atende os pré-requisitos de uso do SmartX
        oBrowse:setSmartX() //Define uso de SmartX 
    EndIf
    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de códigos Referenciais
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Array,  Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6010" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6010" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6010" Operation 4 Access 0 //"Modificar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6010" Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006 Action "VIEWDEF.LOJA6010" Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de códigos Referenciais
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de Model
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MG5')
    Local oModel  := MPFormModel():New('LOJA6010', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Códigos Referenciais"
    oModel:AddFields('MG5MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MG5_FILIAL', 'MG5_CODPRD', 'MG5_CODREF', 'MG5_CODMON'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de códigos Referenciais
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de View
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MG5')
    Local oModel  := FWLoadModel('LOJA6010')

    oView:SetDescription(STR0001) //"Códigos Referenciais"
    oView:SetModel(oModel)
    oView:AddField('MG5', oStruct, 'MG5MASTER')
    oView:EnableTitleView('MG5', STR0001) //"Códigos Referenciais"

Return oView


/*/{Protheus.doc} Lj6010VChv
    Validacao de chave composta do cadastro de Codigos Referenciais
    @type  Function
    @author eduardo.FLima
    @since 10/06/2026
    @version P12
    @return Logical, .T. se validacao ok
/*/
Function Lj6010VChv()
    Local lRet := .T. as Logical
    lRet := ExistChav("MG5",M->MG5_CODPRD+M->MG5_CODREF+M->MG5_CODMON)
    If !lRet
        Help(" ", 1, "LJ6010VCHV", , STR0007; //"Já existe um registro de código referencial com os mesmos dados informados"
         + chr(10) + STR0008 + xfilial(); //"Filial"
         + chr(10) + STR0009 + M->MG5_CODREF; //"Cód. Referencial: "
         + chr(10) + STR0010 + M->MG5_CODPRD; //"Cód. Produto: "
         + chr(10) + STR0011 + M->MG5_CODMON, 1, 0; //"Cód. Montadora: "
        ,,,,,,{STR0012}) //"Verifique os dados informados"
    Endif 
Return lRet


/*/{Protheus.doc} Lj6010VRPr
    Validacao de referencia principal do cadastro de códigos Referenciais
    @type  Function
    @author eduardo.FLima
    @since 10/06/2026
    @version P12
    @return Logical, .T. se validacao ok
/*/
Function Lj6010VRPr()
    Local lRet := .T. as Logical
    lRet := (ExistChav("MG5",M->MG5_CODMON+M->MG5_CODPRD+"1",3) .Or. M->MG5_REFPRI='2') //Valida se existe outro registro com o mesmo codigo de produto e montadora com referencia principal igual a 1 ou se o proprio registro tem referencia principal igual a 2
    If !lRet
        Help(" ", 1, "LJ6010VRPR", , STR0013; // "Já existe um registro de código referencial principal para essa montadora e produto. Só pode existir um registro com referência principal para cada código de produto e montadora"
        + chr(10) + STR0008 + xfilial(); //"Filial"
        + chr(10) + STR0010 + M->MG5_CODPRD; //"Cód. Produto: "
        + chr(10) + STR0011 + M->MG5_CODMON, 1, 0; //"Cód. Montadora: "
        ,,,,,,{STR0014}) //"Altere um dos registros para que apenas um seja a referência principal"
    Endif 
Return lRet


/*/{Protheus.doc} Lj6010VRSb
    Validacao de referencia substituta do cadastro de códigos Referenciais
    @type  Function
    @author eduardo.FLima
    @since 15/06/2026
    @version P12
    @return Logical, .T. se validacao ok
/*/
Function Lj6010VRSb()
    Local lRet as Logical
    Local aArea 	:= GetArea()
    If empty(M->MG5_REFSUB)//Aceita Valor em branco, ou seja, sem referência substituta
        lRet := .T.
    Else
        lRet := ExistCPO( "MG5", M->MG5_REFSUB,4 ) // Valido se existe o codigo referencial 
        if lRet
            lRet := ExistCPO( "MG5", M->MG5_REFSUB+"2",4 ) //Caso exista valido se ele e do tipo referencia substituta
            if !lRet
                Help(" ", 1, "Lj6010VRSb", , STR0015, 1, 0; //"O código referencial selecionado é do tipo referencia principal e não pode ser utilizado como referência substituta"
                ,,,,,,{STR0016}) //"Escolha um codigo referencial do tipo referência substituta ou altere o tipo do código referencial selecionado"                                                                                                                    
            Endif 
        Endif 
    Endif 
    RestArea(aArea)
Return lRet
