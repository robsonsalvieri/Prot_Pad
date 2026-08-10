#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'GTPU003.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU003
    Cadastro de Linhas - Urbano

    @author Silas Gomes
    @since 08/02/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU003()

    Local oBrowse as object

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription(STR0001) //Cadasto de Linhas
    oBrowse:SetAlias("H6V")
    oBrowse:SetLocate()
    oBrowse:Activate()
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef


    @return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
    [n,2] Nome da Rotina associada
    [n,3] Reservado
    [n,4] Tipo de Transação a ser efetuada:
    1 - Pesquisa e Posiciona em um Banco de Dados
    2 - Simplesmente Mostra os Campos
    3 - Inclui registros no Bancos de Dados
    4 - Altera o registro corrente
    5 - Remove o registro corrente do Banco de Dados
    6 - Alteração sem inclusão de registros
    7 - Cópia
    8 - Imprimir
    [n,5] Nivel de acesso
    [n,6] Habilita Menu Funcional

    @author Silas Gomes
    @since 08/02/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina as array

    aRotina := {}

    aadd(aRotina, {STR0002, "PesqBrw"        , 0, 1, 0, .T.}) //"Pesquisar"
    aadd(aRotina, {STR0003, "VIEWDEF.GTPU003", 0, 2, 0, NIL}) //"Visualizar"
    aadd(aRotina, {STR0004, "VIEWDEF.GTPU003", 0, 3, 0, NIL}) //"Incluir"
    aadd(aRotina, {STR0005, "VIEWDEF.GTPU003", 0, 4, 0, NIL}) //"Alterar"
    aadd(aRotina, {STR0006, "VIEWDEF.GTPU003", 0, 5, 0, NIL}) //"Excluir"
    aadd(aRotina, {STR0007, "VIEWDEF.GTPU003", 0, 8, 0, NIL}) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Silas Gomes
    @since 08/02/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel     := Nil
    Local oStrH6V    := FWFormStruct(1, 'H6V')
	Local oStructH79 := FWFormStruct(1, 'H79')
    Local oStructH6X := FWFormStruct(1, 'H6X')
    Local bFieldTrig := {|oMdl, cField, uVal| FieldTrigger(oMdl, uVal)}

    oModel	:= MPFormModel():New('GTPU003',, {|oModel| ValidModel( oModel ) },,)
	
    oModel:AddFields( 'H6VMASTER',, oStrH6V,/*Pre-Validacao*/, /*Pos-Validacao*/ )
    oModel:AddGrid( "H79DETAIL", "H6VMASTER" /*cOwner*/, oStructH79, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //Tarifas
    oModel:AddGrid( "H6XDETAIL", "H6VMASTER" /*cOwner*/, oStructH6X, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //Seções

    oModel:SetRelation("H79DETAIL", {{"H79_FILIAL", "xFilial('H79')" }, {"H79_CODH6V", "H6V_CODIGO" }}, H79->( IndexKey( 1 )))   //Tarifas
    oModel:SetRelation("H6XDETAIL", {{"H6X_FILIAL", "xFilial('H6X')" }, {"H6X_CODLIN", "H6V_CODIGO" }}, H6X->( IndexKey( 2 )))   //Seções

    oModel:GetModel("H6VMASTER"):SetDescription( STR0001 ) //Cadastro de Linhas
    oModel:GetModel("H79DETAIL"):SetDescription( STR0010 ) //Tarifas relacionadas   
    oModel:GetModel("H6XDETAIL"):SetDescription( STR0011 ) //Seções relacionadas 

    oModel:GetModel('H6XDETAIL'):SetUniqueLine({"H6X_CODIGO"}) 

    oStructH6X:AddTrigger("H6X_CODIGO", "H6X_CODIGO", {||.T.}, bFieldTrig)
    
    oModel:SetOptional( "H79DETAIL" , .T. )
    oModel:SetOptional( "H6XDETAIL" , .T. )
    
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Silas Gomes
    @since 08/02/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView   as object
    Local oModel  as object
    Local oStrH6V as object
    Local oStrH79 as object

    oView   := FWFormView():New()
    oModel  := FwLoadModel( 'GTPU003' )
    oStrH6V := FWFormStruct( 2, 'H6V' )
    oStrH79 := FWFormStruct( 2, 'H79' )
    oStrH6X := FWFormStruct( 2, 'H6X' )

    oView:SetModel(oModel)
    oView:AddField('VIEW_H6V', oStrH6V, 'H6VMASTER' )
    oView:AddGrid( 'VIEW_H79', oStrH79, "H79DETAIL" )  
    oView:AddGrid( 'VIEW_H6X', oStrH6X, "H6XDETAIL" )  

    oView:CreateHorizontalBox( "CABEC", 50 )
    oView:CreateHorizontalBox( "GRID1" , 25 )
    oView:CreateHorizontalBox( "GRID2" , 25 )

    oView:SetOwnerView("VIEW_H6V" , "CABEC")   
    oView:SetOwnerView("VIEW_H79" , "GRID1" )
    oView:SetOwnerView("VIEW_H6X" , "GRID2" )

    oView:EnableTitleView("VIEW_H6V", STR0001) //Cadastro de Linhas
    oView:EnableTitleView("VIEW_H79", STR0010) //"Tarifas relacionadas"
    oView:EnableTitleView("VIEW_H6X", STR0011) //"Seções relacionadas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidModel
Funcao de validação do Model
@author Silas Gomes
@since 21/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

    Local oModelH6V  as object
    Local nOperation as numeric
    Local aAreaH6V   as array
    local lRet       as logical
    Local cStatus    as character
    Local cCod       as character
    Local cCodLinha  as character
    Local cChave     as character

    Default oModel := Nil

    oModelH6V      := oModel:GetModel( 'H6VMASTER' )
    nOperation     := oModel:GetOperation()
    aAreaH6V       := H6V->( GetArea() )
    lRet           := .T.
    cStatus        := ''
    cCod           := ''
    cCodLinha      := ''
    cChave         := xFilial( 'H6V' ) + oModelH6V:GetValue( 'H6V_PREFIX' ) + oModelH6V:GetValue( 'H6V_CODLIN' )

    If nOperation != MODEL_OPERATION_DELETE

        dbSelectArea( 'H6V' )
        H6V->( DBSetOrder( 2 ) )
        If H6V->( DbSeek( xFilial( 'H6V' ) + oModelH6V:GetValue('H6V_PREFIX') + oModelH6V:GetValue('H6V_CODLIN'), .T. ) )

            While H6V->(!Eof()) .And. H6V->H6V_FILIAL + H6V->H6V_PREFIX + H6V->H6V_CODLIN == cChave
                cCod := H6V->H6V_CODIGO 
                cCodLinha := H6V->H6V_CODLIN

                If Alltrim(cCod) != Alltrim(oModelH6V:GetValue('H6V_CODIGO')) .And. Alltrim(cCodLinha) == Alltrim(oModelH6V:GetValue('H6V_CODLIN'))

                    cStatus := Posicione("H6V", 1, xFilial("H6V") + cCod + H6V->H6V_PREFIX, "H6V_STATUS")

                    If cStatus == oModelH6V:GetValue('H6V_STATUS')
                        oModel:SetErrorMessage( ,,,,, STR0009, STR0009,, )
                        lRet := .F.
                        Exit
                    EndIf
                EndIf

                H6V->(dbSkip())

            EndDo
        EndIf
    EndIf

    RestArea( aAreaH6V )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função chamada pelo bloco de gatilhos dos campos

@type static function
@version 12.1.2310
@author Karyna Martins
@since 6/24/2024
@param oMdl, object, Modelo
@param cField, character, Campo
@param uVal, variant, Conteúdo do campo
@return uVal, Conteúdo do campo
/*/
//-------------------------------------------------------------------
Static Function FieldTrigger(oMdl, uVal)
    Local oModel    := oMdl:GetModel()
    Local oModelH6V := oModel:GetModel("H6VMASTER")    
    Local oModelH6X := oModel:GetModel("H6XDETAIL")    
    
    oModelH6X:LoadValue('H6X_DESLIN', oModelH6V:getvalue('H6V_DESCRI'))    
    oModelH6X:LoadValue('H6X_PREFIX', oModelH6V:getvalue('H6V_PREFIX')) 
    oModelH6X:LoadValue('H6X_CODILN', oModelH6V:getvalue('H6V_CODLIN')) 
   
Return uVal
