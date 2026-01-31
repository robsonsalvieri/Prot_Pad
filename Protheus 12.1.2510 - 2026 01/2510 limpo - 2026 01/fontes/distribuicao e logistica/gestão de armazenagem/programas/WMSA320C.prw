#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA320C.CH"

#DEFINE CABECALHO "DCW_EMBARQ/DCW_SITEMB/DCW_QTVOLU"
#DEFINE GRID "DCX_DOC/DCX_SERIE/DCX_FORNEC/DCX_LOJA/DCX_QTVOLU/DCXNOMUSU"

// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function WMSA320CDUMMY()
Return Nil
/*--------------------------------------------------------------------------------
---ModelDef
---Funcao generica MVC do model
---Reinaldo Dias - 19/09/2014
----------------------------------------------------------------------------------*/
Static Function ModelDef()
Local oStruDCW := FWFormStruct( 1, 'DCW')       //( <nTipo>, <cAlias> ) nTipo: Tipo da construção da estrutura: 1 para Modelo de dados (Model) e 2 para interface (View), cAlias: Alias da tabela no metadado;
Local oStruDCX := FWFormStruct( 1, 'DCX')       //( <nTipo>, <cAlias> ) nTipo: Tipo da construção da estrutura: 1 para Modelo de dados (Model) e 2 para interface (View), cAlias: Alias da tabela no metadado;
local cID      := 'WMSA320C'                    //Identificador do modelo
Local bPre     := Nil                           //Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
Local bPost    := {|oModel| PosVal(oModel) }    //Code-Block de validação do formulário de edição - TudoOK
Local bCommit  := {|oModel| GravaDados(oModel)} //Code-Block de persistência do formulário de edição
Local bCancel  := Nil                           //Code-Block de cancelamento do formulário de edição
Local oModel   := MPFormModel():New(cID, bPre, bPost, bCommit, bCancel)
Local aColsSX3 := {}

BuscarSX3('DCX_NOMUSU',,@aColsSX3)
oStruDCX:AddField( aColsSX3[1],;								    // [01] C Titulo do campo
				   aColsSX3[1],;									// [02] C ToolTip do campo
				   'DCXNOMUSU',;									// [03] C identificador (ID) do Field
				   'C',;											// [04] C Tipo do campo
				   aColsSX3[3],;									// [05] N Tamanho do campo
				   aColsSX3[4],;									// [06] N Decimal do campo
				   NIL,;											// [07] B Code-block de validação do campo
				   NIL,;											// [08] B Code-block de validação When do campo
				   NIL,;											// [09] A Lista de valores permitido do campo
				   NIL,;											// [10] L Indica se o campo tem preenchimento obrigatório
				   { || Posicione('DCD',1,xFilial('DCD')+DCX->DCX_CODUSU,'DCD_NOMFUN')},;// [11] B Code-block de inicializacao do campo
				   NIL,;											// [12] L Indica se trata de um campo chave
				   .F.,;											// [13] L Indica se o campo pode receber valor em uma operação de update.
				   .T. )											// [14] L Indica se o campo é virtual

// Adiciona ao modelo um componente de formulário
oModel:AddFields('DCWMASTER',/*cOwner*/,oStruDCW)
	
// Adiciona ao modelo uma componente de grid
//oModel:AddGrid('DCXDETAIL','DCWMASTER', oStruDCX)
oModel:AddGrid('DCXDETAIL','DCWMASTER', oStruDCX , /*bLinePre*/, , /*bPre*/ , /*bPost*/,/*bLoad*/)
	
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'DCXDETAIL', { { 'DCX_FILIAL', 'xFilial( "DCX" )' }, { 'DCX_EMBARQ', 'DCW_EMBARQ' } }, DCX->( IndexKey( 1 ) ) )

//Não permite apagar linhas do grid.
oModel:GetModel('DCXDETAIL'):SetNoDeleteLine(.T.)

//Não permitir serem inseridas linhas no grid.
oModel:GetModel('DCXDETAIL'):SetNoInsertLine(.T.)

oModel:SetActivate({|oModel| InitFields(oModel) } )

Return oModel
/*--------------------------------------------------------------------------------
---ViewDef
---Funcao generica MVC do model
---Reinaldo Dias - 19/09/2014
----------------------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel   := FWLoadModel( 'WMSA320C' )
Local oStruDCW := FWFormStruct( 2, 'DCW', { |cCampo| AllTrim( cCampo ) $ CABECALHO } ,/*lViewUsado*/ )
Local oStruDCX := FWFormStruct( 2, 'DCX', { |cCampo| AllTrim( cCampo ) $ GRID } ,/*lViewUsado*/ )
Local oView    := FWFormView():New()
Local aColsSX3 := {}

BuscarSX3('DCX_NOMUSU',,@aColsSX3)
oStruDCX:AddField( 'DCXNOMUSU',; 	    // [01] C Nome do Campo
					'06',;				// [02] C Ordem
					aColsSX3[1],;		// [03] C Titulo do campo
					aColsSX3[1],;		// [04] C Descrição do campo
					NIL,;				// [05] A Array com Help
					'C',;				// [06] C Tipo do campo
					aColsSX3[2],;		// [07] C Picture
					NIL,;				// [08] B Bloco de Picture Var
					'',;				// [09] C Consulta F3
					.F.,;				// [10] L Indica se o campo é evitável
					NIL,;				// [11] C Pasta do campo
					NIL,;				// [12] C Agrupamento do campo
					NIL,;				// [13] A Lista de valores permitido do campo (Combo)
					NIL,;				// [14] N Tamanho Maximo da maior opção do combo
					NIL,;				// [15] C Inicializador de Browse
					.T.,;				// [16] L Indica se o campo é virtual
					NIL)				// [17] C Picture Variável

//Alteração de propriedades do campo	
oStruDCW:SetProperty("*"         ,MVC_VIEW_CANCHANGE,.F.)
oStruDCX:SetProperty("*"         ,MVC_VIEW_CANCHANGE,.F.)
oStruDCX:SetProperty("DCX_QTVOLU",MVC_VIEW_CANCHANGE,.T.)

//Alteração de ordem do campo	
oStruDCX:SetProperty("DCX_DOC"   ,MVC_VIEW_ORDEM,"01")
oStruDCX:SetProperty("DCX_SERIE" ,MVC_VIEW_ORDEM,"02")
oStruDCX:SetProperty("DCX_FORNEC",MVC_VIEW_ORDEM,"03")
oStruDCX:SetProperty("DCX_LOJA"  ,MVC_VIEW_ORDEM,"04")
oStruDCX:SetProperty("DCX_QTVOLU",MVC_VIEW_ORDEM,"05")
oStruDCX:SetProperty("DCXNOMUSU" ,MVC_VIEW_ORDEM,"06")

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField('VIEW_DCW',oStruDCW,'DCWMASTER')

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
           //(cId       ,cOwner   , oModelStruct, bLinePre , bLinePost                   , bPreVal, bPosVal, bLoad )
oView:AddGrid('VIEW_DCX',oStruDCX,'DCXDETAIL')
   
// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox('SUPERIOR',20)
oView:CreateHorizontalBox('INFERIOR',80)
	
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('VIEW_DCW','SUPERIOR')
oView:SetOwnerView('VIEW_DCX','INFERIOR')

//Titulo do componente
oView:EnableTitleView('VIEW_DCX',STR0001)
	
oView:SetCloseOnOk({||.T.})

Return oView
/*--------------------------------------------------------------------------------
---InitFields
---Atribui os valores aos campos
---Reinaldo Dias - 19/09/2015
----------------------------------------------------------------------------------*/
Static Function InitFields(oModel)
Local nI := 0
Local oModelDCW := oModel:GetModel('DCWMASTER')
Local oModelDCX := oModel:GetModel('DCXDETAIL')

For nI := 1 To oModelDCX:Length()
  oModelDCX:GoLine(nI)
  oModelDCX:LoadValue("DCX_CODUSU",__cUserId)
  oModelDCX:LoadValue("DCXNOMUSU",Posicione('DCD',1,xFilial('DCD')+oModelDCX:GetValue("DCX_CODUSU",nI),'DCD_NOMFUN'))
Next

IF oModelDCW:GetValue('DCW_SITEMB') >= "2"  
   oModelDCW:LoadValue("DCW_SITEMB", IIF(oModelDCW:GetValue('DCW_QTCONF') > 0,"2","1"))
Endif

Return .T.
/*--------------------------------------------------------------------------------
---PosVal
---Pós validação do modelo de dados equivale ao TodoOk
---Reinaldo Dias - 19/09/2015
----------------------------------------------------------------------------------*/
Static Function PosVal(oModel)
Local lRet := .T.
Local nI := 0
Local oModelDCW := oModel:GetModel('DCWMASTER')
Local oModelDCX := oModel:GetModel('DCXDETAIL')
Local nQtdVol := 0

If lRet
   For nI := 1 To oModelDCX:Length()
     oModelDCX:GoLine(nI)
     nQtdVol += oModelDCX:GetValue("DCX_QTVOLU",nI)
   Next nI
   oModelDCW:SetValue('DCW_QTVOLU', nQtdVol)
EndIf

Return lRet
/*--------------------------------------------------------------------------------
---GravaDados
---Finalização das movimentações
---Reinaldo Dias - 19/09/2015
----------------------------------------------------------------------------------*/
Static Function GravaDados(oModel)
Return FwFormCommit(oModel,/*bBefore*/, {|oModel,cID,cAlias| PosAtuMVC(oModel,cID,cAlias)})
/*--------------------------------------------------------------------------------
---PosAtuMVC
---Função para atualização das informações complementares com base na
---atividade que está sendo finalizada pelo monitor de serviços
---Reinaldo Dias - 19/09/2015
----------------------------------------------------------------------------------*/
Static Function PosAtuMVC(oModel,cID,cAlias)
Local lRet       := .T.

	If (lRet:=RecLock('DCW',.F.))
   		IF DCW->DCW_QTCONF > 0
      		DCW->DCW_SITEMB := IIF(QtdComp(DCW->DCW_QTVOLU) == QtdComp(DCW->DCW_QTCONF),"3","4")	    
   		Endif
   		DCW->(MsUnlock())
	Endif

Return lRet
