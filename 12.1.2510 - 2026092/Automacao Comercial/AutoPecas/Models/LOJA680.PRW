#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "LOJA680.ch"

/*/{Protheus.doc} LOJA680
    Cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA680()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('MG1')
    oBrowse:SetDescription(STR0001) //"Produto x Fabricante"
    oBrowse:SetMenuDef('LOJA680')   // Vincula ao MenuDef da rotina

    oBrowse:Activate()

    FreeObj(oBrowse) // Libera o objeto da memoria
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet As Array
    aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA680" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA680" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA680" Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA680" Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Produto x Fabricante
/*/
Static Function ModelDef()
    Local oStruct As Object
    Local oModel  As Object

    oStruct := FWFormStruct(1, 'MG1')
    oModel  := MPFormModel():New('LOJA680', /*bPre*/, /*bPost*/ { |oModel| Lj680VldPos( oModel ) },/*bCommit*/,/*bCancel*/)

    oModel:SetDescription(STR0001) //"Produto x Fabricante"
    oModel:AddFields('MG1MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MG1_FILIAL', 'MG1_FILFAB', 'MG1_CODFAB', 'MG1_LOJFAB', 'MG1_FILPRD', 'MG1_CODPRD'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Produto x Fabricante
/*/
Static Function ViewDef()
    Local oModel  := FWLoadModel('LOJA680')
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MG1')

    // Remove campos da estrutura que nao serao apresentados na tela
    oStruct:RemoveField('MG1_FILPRD')
    oStruct:RemoveField('MG1_FILFAB')

    oView:SetDescription(STR0001) //"Produto x Fabricante"
    oView:SetModel(oModel)
    oView:AddField('MG1', oStruct, 'MG1MASTER')
    oView:EnableTitleView('MG1', STR0001) //"Produto x Fabricante"

Return oView

/*/{Protheus.doc} Lj680VldPos
    Bloco de Validacao do cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @param   oModel, Object, Objeto de Model do cadastro de Produto x Fabricante
    @return  lRet, Logical, Resultado da validacao do cadastro de Produto x Fabricante
/*/
Static Function Lj680VldPos( oModel )
Local nOperation As Numeric
Local lRet       As Logical
Local cChave     As Character
Local aAreaMG1   As Array
Local aAreaSA2   As Array
Local nRecnoMG1  As Numeric

nOperation  := oModel:GetOperation()
lRet        := .T.

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
    cChave := oModel:GetValue('MG1MASTER', 'MG1_FILFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_CODFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_LOJFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_FILPRD')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_CODPRD')

    aAreaMG1    := MG1->(GetArea())
    aAreaSA2    := SA2->(GetArea())
    nRecnoMG1   := MG1->(Recno())

    DbSelectArea("MG1")
    MG1->(DbSetOrder(1)) //MG1_FILIAL+MG1_FILFAB+MG1_CODFAB+MG1_LOJFAB+MG1_FILPRD+MG1_CODPRD

    //Valida se ja existe registro cadastrado com a mesma chave
    If MG1->(DbSeek(xFilial("MG1") + cChave))
        If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. nRecnoMG1 != MG1->(Recno()))
            lRet := .F.
            oModel:SetErrorMessage(oModel:GetId(),,,,, STR0006, STR0007) //"Já existe registro cadastrado para este Produto x Fabricante." ### "Informe uma combinação de Fabricante e Produto diferente."
        EndIf
    EndIf

    IF lRet .and. Posicione('SA2', 1, oModel:GetValue('MG1MASTER', 'MG1_FILFAB') + oModel:GetValue('MG1MASTER', 'MG1_CODFAB') +  oModel:GetValue('MG1MASTER', 'MG1_LOJFAB') ,  'A2_FABRICA') $"1|3" //Verifica se o fornecedor informado é cadastrado como fabricante
        If lj680ChkFb(oModel, nRecnoMG1) 
            lRet := .F.
            oModel:SetErrorMessage(oModel:GetId(),,,,, STR0008, STR0009) //"Ja existe um fornecedor cadastrado como fabricante para esse produto" ### "Verifique os dados do fornecedor informado"
        EndIf
    Endif 

    RestArea(aAreaMG1)
    RestArea(aAreaSA2)
EndIf

Return lRet



/*/{Protheus.doc} lj680ChkFb
    Verifica se existe algum fornecedor cadastrado como fabricante para o produto informado
    @type  Static Function
    @author eduardo.Flima
    @since 15/07/2026
    @version P12
    @param oModel, Object, Objeto de Model do cadastro de Produto x Fabricante
    @param nRecnoMG1, Numeric, Recno do registro em MG1
    @return Logical, Resultado da verificação
/*/
Static Function lj680ChkFb(oModel AS Object, nRecnoMG1 AS Numeric)
    Local lRet as Logical
    Local oQueryQry := Nil as Object
    Local cQry      := "" as Character
    Local nSeq      := 1 as Numeric
    Local nOperation  := oModel:GetOperation() as Numeric


    cQry := " SELECT COUNT(1) AS TOTAL "
    cQry += " FROM " + RetSqlName('MG1') + " MG1 "
    cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2 "
    cQry += " ON SA2.A2_FILIAL = MG1.MG1_FILFAB "
    cQry += " AND SA2.A2_COD = MG1.MG1_CODFAB "
    cQry += " AND SA2.A2_LOJA = MG1.MG1_LOJFAB "
    cQry += " AND SA2.D_E_L_E_T_ = ? "  
    cQry += " WHERE MG1.MG1_FILIAL  = ? "
    cQry += " AND MG1.MG1_FILFAB  = ? "        
    cQry += " AND MG1.MG1_FILPRD  = ? "        
    cQry += " AND MG1.MG1_CODPRD  = ? "        
    cQry += " AND MG1.D_E_L_E_T_  = ? "        
    If nOperation == MODEL_OPERATION_UPDATE//Verifica se o registro em MG1 é diferente do registro que está sendo alterado
        cQry += " AND MG1.R_E_C_N_O_ <> ? "
    EndIf    
    cQry += " AND SA2.A2_FABRICA IN (?,?) "        
    
    cQry := ChangeQuery(cQry)

    oQueryQry := FwExecStatement():New(cQry)
    oQueryQry:SetString(nSeq++, Space(1))
    oQueryQry:SetString(nSeq++, xFilial("MG1"))     
    oQueryQry:SetString(nSeq++, oModel:GetValue('MG1MASTER', 'MG1_FILFAB'))
    oQueryQry:SetString(nSeq++, oModel:GetValue('MG1MASTER', 'MG1_FILPRD'))
    oQueryQry:SetString(nSeq++, oModel:GetValue('MG1MASTER', 'MG1_CODPRD'))
    oQueryQry:SetString(nSeq++, Space(1))
    If nOperation == MODEL_OPERATION_UPDATE //Verifica se o registro em MG1 é diferente do registro que está sendo alterado
        oQueryQry:SetNumeric(nSeq++, nRecnoMG1)        
    EndIf    
    oQueryQry:SetString(nSeq++, "1")//"1" - Fabricante: Indica que o cadastro se refere a um fabricante.
    oQueryQry:SetString(nSeq++, "3")//"3" - Todos: Indica que o cadastro é válido para ambos, fabricante e fornecedor.
    
    lRet := Val(cValToChar(oQueryQry:ExecScalar('TOTAL'))) > 0  

    oQueryQry:Destroy()
    oQueryQry := Nil
        
Return lRet

