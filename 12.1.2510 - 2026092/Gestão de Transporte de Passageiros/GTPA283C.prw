#Include "GTPA283c.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"

/*/{Protheus.doc} GTPC300S
FunÃ§Ã£o da Tela de Aglutinador de Requisições
@type  function Static
@author Kaique Schiller
@since  19/03/2024
/*/

Function GTPA283C()

oBrowse := FWMBrowse():New()	
oBrowse:SetAlias('H7A')
oBrowse:SetDescription(STR0001)//'Aglutinador de Requisições'

oBrowse:Activate()
oBrowse:Destroy()

Return Nil

/*/{Protheus.doc} MenuDef
Função para criação dos menus.
@type  Static MenuDef
@author Kaique Schiller
@since  19/03/2024
/*/

Static Function MenuDef()
Local aRot := {}

ADD OPTION aRot TITLE STR0002 		ACTION 'VIEWDEF.GTPA283C' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //'Visualizar'
ADD OPTION aRot TITLE STR0003		ACTION 'VIEWDEF.GTPA283C' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //'Incluir' 
ADD OPTION aRot TITLE STR0004		ACTION 'VIEWDEF.GTPA283C' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //'Alterar' 
ADD OPTION aRot TITLE STR0005 		ACTION 'VIEWDEF.GTPA283C' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //'Excluir'

Return aRot

/*/{Protheus.doc} ModelDef
Função para criação do Modelo da Tela em MVC
@type  Static ModelDef
@author Kaique Schiller
@since  19/03/2024
/*/

Static Function ModelDef()
Local oStruH7A  := FWFormStruct( 1 , "H7A" )
Local oStruH7B  := FWFormStruct( 1 , "H7B" )
Local oModel
Local aGatilho := {}

oStruH7B:AddField(  STR0006,;			    // 	[01]  C   Titulo do campo //"Item"
                    STR0006,;				// 	[02]  C   ToolTip do campo //"Item"
                    "H7B_ITEM",;				// 	[03]  C   Id do Field
                    "C",;						// 	[04]  C   Tipo do campo
                    3,;		// 	[05]  N   Tamanho do campo
                    0,;							// 	[06]  N   Decimal do campo
                    Nil,;						// 	[07]  B   Code-block de validação do campo
                    Nil,;						// 	[08]  B   Code-block de validação When do campo
                    Nil,;						//	[09]  A   Lista de valores permitido do campo
                    .F.,;						//	[10]  L   Indica se o campo tem preenchimento obrigatório
                    ,;//	[11]  B   Code-block de inicializacao do campo
                    .F.,;						//	[12]  L   Indica se trata-se de um campo chave
                    .F.,;						//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                    .T.)						// 	[14]  L   Indica se o campo é virtual

oStruH7B:AddField(  STR0007,;			    // 	[01]  C   Titulo do campo //"Descrição"
                    STR0007,;				// 	[02]  C   ToolTip do campo //"Descrição"
                    "H7B_DSCCLI",;				// 	[03]  C   Id do Field
                    "C",;						// 	[04]  C   Tipo do campo
                    TAMSX3("A1_NOME")[1],;		// 	[05]  N   Tamanho do campo
                    0,;							// 	[06]  N   Decimal do campo
                    Nil,;						// 	[07]  B   Code-block de validação do campo
                    Nil,;						// 	[08]  B   Code-block de validação When do campo
                    Nil,;						//	[09]  A   Lista de valores permitido do campo
                    .F.,;						//	[10]  L   Indica se o campo tem preenchimento obrigatório
                    {|| Iif(!Inclui,Posicione( "SA1", 1, xFilial('SA1') + H7B->(H7B_CODCLI+H7B_CODLOJ), 'A1_NOME'),"") },;//	[11]  B   Code-block de inicializacao do campo
                    .F.,;						//	[12]  L   Indica se trata-se de um campo chave
                    .F.,;						//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                    .T.)						// 	[14]  L   Indica se o campo é virtual

oStruH7B:SetProperty("H7B_CODCLI", MODEL_FIELD_OBRIGAT, .T.)
oStruH7B:SetProperty("H7B_CODLOJ", MODEL_FIELD_OBRIGAT, .T.)

aGatilho := FwStruTrigger("H7B_CODLOJ", "H7B_DSCCLI", 'Posicione("SA1",1,XFilial("SA1")+FwFldGet("H7B_CODCLI")+FwFldGet("H7B_CODLOJ"),"A1_NOME")')
oStruH7B:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

oModel := MPFormModel():New( 'GTPA283C', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields('H7AMASTER',, oStruH7A )
oModel:AddGrid('H7BDETAIL','H7AMASTER',oStruH7B,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

oModel:SetRelation('H7BDETAIL',{{'H7B_FILIAL','xFilial("H7B")'},{'H7B_CODH7A','H7A_CODIGO'}},H7B->(IndexKey(1)))

oModel:GetModel( 'H7AMASTER' ):SetDescription( STR0008 ) //'Aglutinação de Requisição'
oModel:GetModel( 'H7BDETAIL' ):SetDescription( STR0009 ) //'Item de Aglutinação de Requisição'

oModel:GetModel('H7BDETAIL'):SetUniqueLine( { "H7B_CODCLI","H7B_CODLOJ" } )

Return oModel 

/*/{Protheus.doc} ViewDef
função para criação da View em MVC
@type  Static ViewDef
@author Kaique Schiller
@since  19/03/2024
/*/
Static Function ViewDef()
Local oModel := FWLoadModel( 'GTPA283C' )
Local oView 
Local oStruH7A := FWFormStruct(2, 'H7A',  ) 
Local oStruH7B := FWFormStruct(2, 'H7B',  )

oStruH7B:RemoveField('H7B_CODH7A')
oStruH7B:RemoveField('H7B_CODIGO')

oStruH7B:AddField(	"H7B_ITEM",;	// [01]  C   Nome do Campo
                    "01",;			// [02]  C   Ordem
                    STR0006,;	// [03]  C   Titulo do campo //"Item"
                    STR0006,;	// [04]  C   Descricao do campo //"Item"
                    {STR0006},;	// [05]  A   Array com Help //"Descrição"
                    "GET",;			// [06]  C   Tipo do campo
                    "@!",;			// [07]  C   Picture
                    NIL,;			// [08]  B   Bloco de Picture Var
                    "",;			// [09]  C   Consulta F3
                    .F.,;			// [10]  L   Indica se o campo é alteravel
                    NIL,;			// [11]  C   Pasta do campo
                    "",;			// [12]  C   Agrupamento do campo
                    NIL,;			// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;			// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;			// [15]  C   Inicializador de Browse
                    .T.,;			// [16]  L   Indica se o campo é virtual
                    NIL,;			// [17]  C   Picture Variavel
                    .F.)			// [18]  L   Indica pulo de linha após o campo
                    
oStruH7B:AddField(	"H7B_DSCCLI",;	// [01]  C   Nome do Campo
                    "08",;			// [02]  C   Ordem
                    STR0007,;	// [03]  C   Titulo do campo //"Descrição"
                    STR0007,;	// [04]  C   Descricao do campo //"Descrição"
                    {STR0007},;	// [05]  A   Array com Help //"Descrição"
                    "GET",;			// [06]  C   Tipo do campo
                    "@!",;			// [07]  C   Picture
                    NIL,;			// [08]  B   Bloco de Picture Var
                    "",;			// [09]  C   Consulta F3
                    .F.,;			// [10]  L   Indica se o campo é alteravel
                    NIL,;			// [11]  C   Pasta do campo
                    "",;			// [12]  C   Agrupamento do campo
                    NIL,;			// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;			// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;			// [15]  C   Inicializador de Browse
                    .T.,;			// [16]  L   Indica se o campo é virtual
                    NIL,;			// [17]  C   Picture Variavel
                    .F.)			// [18]  L   Indica pulo de linha após o campo

oView := FWFormView():New()  
oView:SetModel(oModel)    
oView:AddField('VIEW_H7A', oStruH7A, 'H7AMASTER' )  
oView:AddGrid( 'VIEW_H7B', oStruH7B, 'H7BDETAIL' )

oView:CreateHorizontalBox('SUPERIOR' , 15)  
oView:CreateHorizontalBox('INFERIOR' , 85)

oView:SetOwnerView('VIEW_H7A', 'SUPERIOR')
oView:SetOwnerView('VIEW_H7B', 'INFERIOR')

oView:EnableTitleView('VIEW_H7A',STR0008) //'Aglutinação de Requisição'
oView:EnableTitleView('VIEW_H7B',STR0009) //'Item de Aglutinação de Requisição'

oView:AddIncrementField('VIEW_H7B','H7B_ITEM')

Return oView
