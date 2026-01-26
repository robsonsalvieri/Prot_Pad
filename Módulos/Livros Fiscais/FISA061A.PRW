#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA061A.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} FISA061A
	Função que cria uma tela MVC para informar a data-limite de vigência de um produto acabado na apuração da FCI. 
	A rotina mostra a tela com os produtos apurados pela FCI (tabela CFD) e um menu com a opção Alterar Vigência.

	@type  Function
	@author Gabriela Dalle Luche
	@since 20/09/2024
	@version 12.1.2310
/*/

Function FISA061A( oCenterPanel )
Local 	oBrowse			as object
Local	cAlias			as character

oBrowse	:= Nil 
cAlias 	:= "CFD"

//Monta browse com os registros da CFD
oBrowse := FWMBrowse():New()

oBrowse:SetOwner( oCenterPanel )
oBrowse:SetMenuDef('FISA061A')
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription( STR0001 ) // Descricao

oBrowse:Activate()


Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina as array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION 'VIEWDEF.FISA061A'    OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION 'VIEWDEF.FISA061A' 	OPERATION 4 ACCESS 0 //"Alterar Vigencia"

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object
Local oStructCFD as object
Local oCommit as object

	oStructCFD	:=	FWFormStruct(1, "CFD" )
	oModel 		:=	MPFormModel():New('FISA061AMOD',,, )
	oCommit		:= 	FA061ACOMMIT():New()

	//Remove alguns campos do modelo				    
	oStructCFD:RemoveField( 'CFD_OP' )
	oStructCFD:RemoveField( 'CFD_VSAIIE' )
	oStructCFD:RemoveField( 'CFD_VPARIM' )

	oModel:AddFields( 'FISA061AMOD' ,, oStructCFD )

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"CFD_FILIAL"},{"CFD_PERCAL"},{"CFD_PERVEN"},{"CFD_COD"},{"CFD_OP"},{"CFD_FILOP"})	
	
	//Neste modelo, somente o campo CFD_VIGE ficara disponivel para edição

	//Bloqueando demais campos para edicao
	oStructCFD:SetProperty('CFD_PERVEN' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )
	oStructCFD:SetProperty('CFD_COD' 	, MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )	
	oStructCFD:SetProperty('CFD_CONIMP' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )	
	oStructCFD:SetProperty('CFD_FCICOD' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )	
	oStructCFD:SetProperty('CFD_ORIGEM' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )	

	oStructCFD:SetProperty('CFD_VIGE'  , MODEL_FIELD_VALID , {|| ValidReg('FISA061AMOD','CFD_VIGE'  ) })
	
	//Adicionando a descricao do modelo
	oModel:SetDescription(STR0001) //"Ficha de Conteudo de Importacao
	
	//Instancia o metodo responsável pelo commit das alterações
	oModel:InstallEvent("FA061ACOMMIT", /*cOwner*/, oCommit)

Return oModel


/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	//Criacao do objeto do modelo de dados da Interface do Cadastro
	Local oView      as object
	Local oModel     as object
	Local oStructCFD as object
	
	oView      := FWFormView():New()
	oModel     := FWLoadModel( "FISA061A" )
	oStructCFD := FWFormStruct(2, "CFD" )	

	oView:SetModel(oModel)
	
	//Atribuindo formularios para interface
	oView:AddField( "VIEW" , oStructCFD , 'FISA061AMOD')

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( "TELA" , 100 )

	//Remove os campos da exibição
	oStructCFD:RemoveField( 'CFD_OP' )
	oStructCFD:RemoveField( 'CFD_VSAIIE' )
	oStructCFD:RemoveField( 'CFD_VPARIM' )
	
	//Colocando tÃ­tulo do formulario
    oView:EnableTitleView('VIEW', STR0001 )
    
    //ForÃ§a o fechamento da janela na confirmacao
    oView:SetCloseOnOk({||.T.})
    
    //O formulario da interface sera colocado dentro do container
    oView:SetOwnerView("VIEW","TELA")	
	
	

Return oView


//-------------------------------------------------------------------
/*/ { Protheus.doc } FA061ACOMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Class FA061ACOMMIT FROM FWModelEvent

	Method New()
	Method InTTS()

End Class

Method New() Class FA061ACOMMIT
Return


/*/{Protheus.doc} InTTS
Método acionado durante as gravações da transação

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310
/*/

Method InTTS(oModel) Class FA061ACOMMIT
	Local oExec 	as object
	Local cQuery 	as character

	oExec 		:= Nil
	cQuery 		:= ""

	//Obtem o conteúdo dos campos do modelo de dados
	cFilCFD 	:= oModel:GetValue("FISA061AMOD","CFD_FILIAL")
	cProd	  	:= oModel:GetValue("FISA061AMOD","CFD_COD")
	cVige		:= oModel:GetValue("FISA061AMOD","CFD_VIGE")

	//Atualiza o campo CFD_VIGE com o periodo informado pelo usuário
	cQuery := " UPDATE  " + RetSqlName('CFD')+" "
	cQuery += " SET CFD_VIGE 		= ?  "
	cQuery += " WHERE CFD_FILIAL 	= ?  "
	cQuery += " 	AND CFD_COD 	= ?  "
	cQuery += " 	AND D_E_L_E_T_ 	= ?	 "

	oExec := FwExecStatement():New(cQuery)
	oExec:SetString(1,cVige)
	oExec:SetString(2,cFilCFD)
	oExec:SetString(3,cProd)
	oExec:SetString(4,' ')
 
	TcSqlExec(oExec:GetFixQuery())

Return



/*/{Protheus.doc} ValidReg
Função para validar o conteudo digitado no campo

@author Gabriela Dalle Luche
@since 20/09/2024
@version 12.1.2310
/*/

Static Function ValidReg(cModel,cCampo)

	Local lRet    as boolean
	Local oModel  as object
	Local cPeriod as character
	Local oRegex  as object

	lRet    := .T. 
	oModel  := FWModelActive()
	cPeriod := ""

	// Inicializa objeto com Pattern de mes e ano
	oRegex := tRegex():new('^("?0[1-9]|1[012])(20)(\d{2}"?)$',.T.) //mês aceita de 1 a 12, ano aceita de 19,20 com 2 digitos finais de 0-9

	if  ValType(oRegex) == "O"
		cPeriod := oModel:GetValue(cModel, cCampo )

		// Valida o valor do campo periodo no formato mm/aaaa (mês e ano preenchidos) ou vazio (branco)
		If Empty(cPeriod)
			lRet := .T.
		Else
			lRet := oRegex:Search(cPeriod)
		Endif
	endif


Return lRet
