#INCLUDE 'TOTVS.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA907.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA907
	Forma de pagamento - Urbano
	
	@author Breno Gomes
	@since 01/12/2024
	@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPA907()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Configurador de integração RJ"
	oBrowse:SetAlias("H8B")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

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

@author Breno Gomes
@since 01/12/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPA907", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPA907", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPA907", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPA907", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPA907", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 10/09/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := nil
	Local oStrH8B   := FWFormStruct(1,'H8B')
	Local bPosValid  := {|oModel| PosValid(oModel)}

	oModel := MPFormModel():New('GTPA907', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('H8BMASTER',/*cOwner*/,oStrH8B,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001)// "Forma de pagamento"
	oModel:GetModel('H8BMASTER'):SetDescription(STR0001) //"Forma de pagamento"

	oStrH8B:SetProperty('H8B_TPCADA', MODEL_FIELD_WHEN , {|| INCLUI } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 13/09/2021
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   := FWFormView():New()
	Local oModel  := FwLoadModel('GTPA907')
	Local oStrH8B := FWFormStruct(2, 'H8B')

	oView:SetModel(oModel)
	oView:AddField('VIEW_H8B' ,oStrH8B,'H8BMASTER')
	oView:SetDescription(STR0001) //"Forma de pagamento"
	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid
Função de validação

@type Static Function
@author karyna.martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)  

	Local lRet 		:= .T. 
	Local oMdl 		:= oModel:GetModel()
	Local cMsgErro	:= ""
	Local cMsgSol	:= ""	
	Local nOpc      := oModel:GetOperation()
	
	H8B->(DbSetOrder(2)) //H8B_FILIAL+H8B_TPCADA
	If nOpc == MODEL_OPERATION_INSERT .And. H8B->(DbSeek(xFilial("H8B") + oMdl:GetValue('H8BMASTER', 'H8B_TPCADA')))	

		lRet     := .F.
		cMsgErro := STR0008 //"O tipo de cadastro já existe para essa filial"
		cMsgSol	 := STR0009 //"É necessário informar o tipo diferente do cadastrado"		

		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GTPA907PosVld", cMsgErro, cMsgSol)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TCadastro
Função dos tipos de cadastros de integração

@type Static Function
@author karyna.martins
@since 12/03/2026
/*/
//-------------------------------------------------------------------
Function TCadastro()
	Local cTipo := ""
	
	cTipo := "01=Colaboradores;"
	cTipo += "02=Linha;"
	cTipo += "03=Bilhete;"
	cTipo += "04=Agencia;"
	/*cTipo := "05=Orgao Concedentes;"
	cTipo += "06=Receitas e Despesas;"
	cTipo += "07=Horarios/Servicos;"
	cTipo += "08=Trechos da Linha;"
	cTipo += "09=Tipos de localidade;"
	cTipo += "10=Estado;"
	cTipo += "11=Cidade;"
	cTipo += "12=Localidade;"
	cTipo += "13=Categoria Linha;"	
	cTipo += "14=Vias;"	            
	cTipo += "15=Tipo de Agencia;"	
	cTipo += "16=Categoria Bilhete;"
	cTipo += "17=Trechos;"
	cTipo += "18=Tipos de Venda;"
	cTipo += "19=Bilhetes noShow"*/

Return cTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} RotInteg
Função de/para Rotina de integração

@type Static Function
@author karyna.martins
@since 12/03/2026
/*/
//-------------------------------------------------------------------
Function RotInteg(cRotina)
	Local cTipo:= ""

	Default cRotina := ""

	Do Case
		//Colaboradores
        Case ( "GTPIRJ008" $ cRotina )
            cTipo := "01"
		//Linhas
        Case ( "GTPIRJ002" $ cRotina )
            cTipo := "02"
		 //Bilhetes
        Case ( "GTPIRJ115" $ cRotina ) 
            cTipo := "03"
		//Agência
        Case ( "GTPIRJ006" $ cRotina ) 
            cTipo := "04"
		/* //Orgãos
        Case ( "GTPIRJ000" $ cRotina ) 
           cTipo := "05"       
        //Receitas e Despesas
        Case ( "GTPIRJ427" $ cRotina ) 
            cTipo := "06"           
        //Horários
        Case ( "GTPIRJ004" $ cRotina )
            cTipo := "07"           
        //Trechos da Linha
        Case ( "GTPIRJ003" $ cRotina ) 
            cTipo := "08"
        //Tipos de localidade
        Case ( "GTPIRJ035" $ cRotina ) 
           cTipo := "09"
        //Estado
        Case ( "GTPIRJ001A" $ cRotina ) 
           cTipo := "10"
        //Cidade
        Case ( "GTPIRJ001B" $ cRotina ) 
            cTipo := "11"
        //Localidade
        Case ( "GTPIRJ001" $ cRotina )
            cTipo := "12"
        //Categoria Linha
        Case ( "GTPIRJ011" $ cRotina ) 
            cTipo := "13"        
        //Vias
        Case ( "GTPIRJ005" $ cRotina ) 
           cTipo := "14"        
        //Tipo de Agência
        Case ( "GTPIRJ711" $ cRotina ) 
            cTipo := "15"        
        //Categoria Bilhetes
        Case ( "GTPIRJ118" $ cRotina ) 
            cTipo := "16"
        //Trechos (Pedágio)
        Case ( "GTPIRJ120" $ cRotina ) 
            cTipo := "17"        "
        //Tipos de Venda
        Case ( "GTPIRJ050" $ cRotina ) 
            cTipo := "18"        
        //Bilhetes noShow
        Case ( "GTPIRJ119" $ cRotina ) 
            cTipo := "19"       */   
    EndCase

Return cTipo
