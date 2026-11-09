#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA450.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA450
Tela de cadastro de Recursos Físicos

@author Tiago Filipe da Silva
@since 08/10/2013
@version P12
/*/
//-------------------------------------------------------------------
Function WMSA450()
Local oBrowse
		
	carregaD05()
		
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('D05')
	oBrowse:SetDescription(STR0001) // Recurso Físico
	oBrowse:Activate()
Return NIL
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author  Tiago Filipe da Silva
@since   08/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruD05 := FWFormStruct(1, 'D05')
Local oModel
	oModel := MPFormModel():New('WMSA450', /*bPre*/,/*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields('D05MASTER', /*cOwner*/, oStruD05)
	oModel:SetDescription( STR0001 )     // Cadastro Recurso Fisico
	oModel:SetPrimaryKey({"D05_CODREC"})
Return oModel
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada View do MVC.

@author  Tiago Filipe da Silva
@since   08/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel := FWLoadModel('WMSA450')
Local oStruD05 := FWFormStruct(2, 'D05')
Local oView
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_D05',oStruD05,'D05MASTER')
Return oView
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Tiago Filipe da Silva
@since   08/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0008 Action 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.WMSA450' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.WMSA450' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.WMSA450' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.WMSA450' OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.WMSA450' OPERATION 8 ACCESS 0 // Imprimir
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.WMSA450' OPERATION 9 ACCESS 0 // Copiar
Return aRotina
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} carregaD05
Função para carga da D05 caso esteja vazia.

@author  Tiago Filipe da Silva
@since   08/10/2013
@version 2.0
/*/
//---------------------------------------------------------------------------------------------
Static Function carregaD05()
Local aAreaAnt := GetArea() 
Local lRet := .T.
Local cQuery := ""
Local cAliasQry := ""
	
	cQuery := "SELECT 1"
	cQuery +=  " FROM "+RetSqlName("D05")
	cQuery += " WHERE D05_FILIAL = '"+xFilial("D05")+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias() 
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(Eof()) // Não há registros na D05 para a filial corrente
		(cAliasQry)->(dbCloseArea())
		cQuery := "SELECT DISTINCT DC6_TPREC"
        cQuery +=  " FROM "+RetSqlName("DC6")
        cQuery += " WHERE DC6_FILIAL = '"+xFilial("DC6")+"'"
        cQuery +=   " AND D_E_L_E_T_ = ' '"
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		Do While (cAliasQry)->(!Eof())
			// Carrega D05 com os recursos utilizados no cadastro de tarefa x atividade
			RecLock("D05",.T.)
			D05->D05_FILIAL := xFilial("D05")
			D05->D05_CODREC := (cAliasQry)->DC6_TPREC
			D05->D05_DESREC := Tabela("L1",(cAliasQry)->DC6_TPREC)
			D05->(MsUnlock())
			
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())
	
RestArea(aAreaAnt)
Return lRet
