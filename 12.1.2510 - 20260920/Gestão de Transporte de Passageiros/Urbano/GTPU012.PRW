#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU012.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU012
	Cartões Provisórios - Urbano

	@author Silas Gomes
	@since 02/05/2024   
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU012()

	Local oBrowse as object

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription(STR0001) //Cadastro de Cartões Provisórios
    oBrowse:SetAlias("H7H")
    oBrowse:SetLocate()
    oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef - Menu Funcional


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
    @since 02/05/2024 
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina as array

    aRotina := {}

    aadd(aRotina, {STR0002, "PesqBrw"        , 0, 1, 0, .T.}) //"Pesquisar"
    aadd(aRotina, {STR0003, "VIEWDEF.GTPU012", 0, 2, 0, NIL}) //"Visualizar"
    aadd(aRotina, {STR0004, "VIEWDEF.GTPU012", 0, 3, 0, NIL}) //"Incluir"
    aadd(aRotina, {STR0005, "VIEWDEF.GTPU012", 0, 4, 0, NIL}) //"Alterar"
    aadd(aRotina, {STR0006, "VIEWDEF.GTPU012", 0, 5, 0, NIL}) //"Excluir"
    aadd(aRotina, {STR0007, "VIEWDEF.GTPU012", 0, 8, 0, NIL}) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Silas Gomes
    @since 02/05/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel  as object
    Local oStrH7H as object

    oModel  := Nil
    oStrH7H := FWFormStruct( 1, 'H7H' )

    oModel	:= MPFormModel():New('GTPU012',, {|oModel| ValidModel( oModel ) },,)
	oModel:AddFields( 'H7HMASTER',, oStrH7H,,,)
	oModel:SetDescription( STR0001 ) //Cadastro de Cartões Provisórios

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Silas Gomes
    @since 02/05/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView   as object
    Local oModel  as object
    Local oStrH7H as object

    oView   := FWFormView():New()
    oModel  := FwLoadModel( 'GTPU012' )
    oStrH7H := FWFormStruct( 2, 'H7H' )

    oView:SetModel(oModel)
    oView:AddField( 'VIEW_H7H' , oStrH7H, 'H7HMASTER' )
    oView:SetDescription( STR0001 ) //Cadastro de Cartões Provisórios

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validação do Model
@author Silas Gomes
@since 02/05/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel as object )

    Local oModelH7H  := oModel:GetModel( 'H7HMASTER' )
    Local nOperation := oModel:GetOperation()
    local lRet       := .T.
    local cAliasTmp  := GetNextAlias()
    local cQuery     := ''
    Local cColaborad := oModelH7H:GetValue('H7H_COLABO')
    Local cNumCartao := oModelH7H:GetValue('H7H_NUMCAR')

    If nOperation != MODEL_OPERATION_DELETE

        cQuery := " SELECT H7H_FILIAL FILIAL, "
        cQuery +=        " H7H_CODIGO CODIGO, "
        cQuery +=        " H7H_NUMCAR NUMCARTAO, "
        cQuery +=        " H7H_COLABO COLABORADOR, "
        cQuery +=        " H7H_DSCCOL DESCRICAO, "
        cQuery +=        " H7H_DTINIC DTINICIO, "
        cQuery +=        " H7H_DTFINA DTFINAL "
        cQuery += " FROM " + RetSqlName('H7H') + " H7H "
        cQuery += " WHERE H7H_FILIAL = '" + xFilial('H7H') + "'"
        cQuery +=       " AND H7H_CODIGO <> '" + AllTrim(oModelH7H:GetValue('H7H_CODIGO')) + "'"
        cQuery +=       " AND ( H7H_COLABO = '" + cColaborad + "'"
        cQuery +=             " OR H7H_NUMCAR = '" + cNumCartao + "')"
        cQuery +=       " AND ('" + DtoS(oModelH7H:GetValue('H7H_DTINIC')) + "' BETWEEN H7H_DTINIC AND H7H_DTFINA"
        cQuery +=       " OR '" + DtoS(oModelH7H:GetValue('H7H_DTFINA')) + "'  BETWEEN H7H_DTINIC AND H7H_DTFINA)"
        cQuery +=       " AND H7H.D_E_L_E_T_ = '' "

        cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )
		(cAliasTmp)->(DbGoTop())

        If !(cAliasTmp)->( EOF() )
            If (cAliasTmp)->NUMCARTAO == cNumCartao
                lRet   := .F.
                oModel:SetErrorMessage( ,,,,, STR0009,,, )// O cartão informado já se encontra em uso 
            Else 
                lRet   := .F.
                oModel:SetErrorMessage( ,,,,,STR0008,,, )// "Já existe um cartão válido para colaborador informado "
            EndIf
            
        EndIf

    EndIf
    
Return( lRet )
