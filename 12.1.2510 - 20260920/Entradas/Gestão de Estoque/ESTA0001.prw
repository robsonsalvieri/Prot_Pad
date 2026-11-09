#INCLUDE "ESTA0001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

Static __aPrepared := {} As Array

PUBLISH MODEL REST NAME ESTA0001 SOURCE ESTA0001 RESOURCE OBJECT oRestESTA0001

//-------------------------------------------------------------------
/*{Protheus.doc} ESTA0001
Cadastro Fator de Conversao Unidade de Medida (Modelo 2)

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Function ESTA0001()
Local oBrowse
Local aErrorMsg
aErrorMsg := ESTAD3Q()

If(Len(aErrorMsg) > 0)
    ESTADlg(aErrorMsg)
Else
	D3Q->(dbSetOrder(1))

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'D3Q' )
	oBrowse:SetDescription( STR0001 )
	//Função do Browser SMARTX 
	If hasSmartX()
		oBrowse:setSmartX()
	Endif 
	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Monta opcoes de rotina do programa

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Static Function MenuDef() 

Private aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 //"Visualizar"	
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"		
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"		
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"	

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Fator de Conversao de Medida

@since 01/08/2022
@version P12
@author Adriano Vieira
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 	:= NIL
Local oStruD3Q	:= FWFormStruct(1,'D3Q',{|cCampo| AllTRim(cCampo) $ "D3Q_PROD"})
Local oStruGrid := FWFormStruct(1,'D3Q',{|cFields| AllTRim(cFields) $ "D3Q_ITEM|D3Q_UNICOM|D3Q_FATOR|D3Q_CODBAR|D3Q_PCOMP|D3Q_PMOVI|D3Q_PVEND|D3Q_DESCUM"})
Local oEvent    := ESTA0001EVDEF():New()

oStruD3Q:AddField(   STR0010			,;	// 	[01]  C   Titulo do campo
					 STR0010			,;	// 	[02]  C   ToolTip do campo
					 "D3Q_DESCPR"		,;	// 	[03]  C   Id do Field
					 "C"				,;	// 	[04]  C   Tipo do campo
					 TamSX3("B1_DESC")[1],;	// 	[05]  N   Tamanho do campo
					 0					,;	// 	[06]  N   Decimal do campo
					 NIL                ,;	// 	[07]  B   Code-block de validacao do campo
					 NIL				,;	// 	[08]  B   Code-block de validacao When do campo
					 NIL				,;	//	[09]  A   Lista de valores permitido do campo
					 .F.				,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "IniPadProd()")	,;  // [11] BCode-block de inicializacao do campo
					 NIL				,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL				,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update.
					 .T.				)	// 	[14]  L   Indica se o campo e virtual

aAux :=    FwStruTrigger("D3Q_PROD","D3Q_DESCPR","POSICIONE('SB1',1,xFilial('SB1')+FWFldGet('D3Q_PROD') ,'B1_DESC')")

oStruD3Q:AddTrigger(	aAux[1],; // [01] Id do campo de origem
                        aAux[2],; // [02] Id do campo de destino
                        aAux[3],; // [03] Bloco de codigo de validacao da execucao do gatilho
                        aAux[4])  // [04] Bloco de codigo de execucao do gatilho


oStruD3Q:AddField(   STR0008			,;	// 	[01]  C   Titulo do campo
					 STR0008			,;	// 	[02]  C   ToolTip do campo
					 "D3Q_UNIEST"		,;	// 	[03]  C   Id do Field
					 "C"				,;	// 	[04]  C   Tipo do campo
					 TamSX3("AH_UNIMED")[1],;//	[05]  N   Tamanho do campo
					 0					,;	// 	[06]  N   Decimal do campo
					 NIL                ,;	// 	[07]  B   Code-block de validacao do campo
					 NIL				,;	// 	[08]  B   Code-block de validacao When do campo
					 NIL				,;	//	[09]  A   Lista de valores permitido do campo
					 .F.				,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "IniPadUM()")	,;  // [11] BCode-block de inicializacao do campo
					 NIL				,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL				,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update.
					 .T.				)	// 	[14]  L   Indica se o campo e virtual

aAux :=    FwStruTrigger("D3Q_PROD","D3Q_UNIEST","POSICIONE('SB1',1,xFilial('SB1')+FWFldGet('D3Q_PROD') ,'B1_UM')")

oStruD3Q:AddTrigger(	aAux[1],; // [01] Id do campo de origem
                        aAux[2],; // [02] Id do campo de destino
                        aAux[3],; // [03] Bloco de codigo de validacao da execucao do gatilho
                        aAux[4])  // [04] Bloco de codigo de execucao do gatilho

oModel := MPFormModel():New('ESTA0001', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescription(STR0002)

oModel:AddFields('D3QMASTER',/*cOwner*/,oStruD3Q)
oModel:AddGrid('D3QDETAILS','D3QMASTER',oStruGrid)

oModel:GetModel("D3QDETAILS"):SetUseOldGrid()
oModel:SetPrimaryKey({"D3Q_PROD","D3Q_UNICOM"})

oModel:SetRelation('D3QDETAILS',{{'D3Q_FILIAL','xFilial("D3Q")'},{"D3Q_PROD","D3Q_PROD"}},D3Q->(IndexKey(1)))
oModel:GetModel("D3QDETAILS"):SetDelAllLine(.T.)

oModel:GetModel("D3QDETAILS"):SetUniqueLine({"D3Q_UNICOM"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'D3QMASTER' ):SetDescription( STR0003 )
oModel:GetModel( 'D3QDETAILS'):SetDescription( STR0009 )

oModel:InstallEvent("ESTA0001EVDEF", /*cOwner*/, oEvent)

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados Fator Conversao de Medida

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= NIL
Local oModel	:= FWLoadModel('ESTA0001')
Local oStruD3Q  := FWFormStruct(2,"D3Q", {|cCampo| AllTRim(cCampo) $ "D3Q_PROD"})
Local oStruGRID := FWFormStruct(2,"D3Q", {|cFields| AllTRim(cFields) $ "D3Q_ITEM|D3Q_UNICOM|D3Q_FATOR|D3Q_CODBAR|D3Q_PCOMP|D3Q_PMOVI|D3Q_PVEND|D3Q_DESCUM"})

oView:= FWFormView():New() 
oView:SetModel(oModel)

oStruD3Q:AddField(  "D3Q_DESCPR"		,;	// [01]  C   Nome do Campo
					"02"				,;	// [02]  C   Ordem
					STR0010				,;	// [03]  C   Titulo do campo//"Descricao"
					STR0010				,;	// [04]  C   Descricao do campo//"Descricao"
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					"@!"				,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo e alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opcao do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo e virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

oStruD3Q:AddField(  "D3Q_UNIEST"		,;	// [01]  C   Nome do Campo
					"03"				,;	// [02]  C   Ordem
					STR0008				,;	// [03]  C   Titulo do campo//"Descricao"
					STR0008				,;	// [04]  C   Descricao do campo//"Descricao"
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					NIL					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo e alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opcao do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo e virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)

oStruD3Q:SetProperty('D3Q_PROD', MVC_VIEW_ORDEM, '01')
If oStruGRID:HasField("D3Q_DESCUM")
	oStruGRID:SetProperty('D3Q_DESCUM', MVC_VIEW_ORDEM, GetSx3Cache('D3Q_UNICOM','X3_ORDEM'))
EndIf

oView:AddField('VIEW_D3Q', oStruD3Q, 'D3QMASTER')
oView:CreateHorizontalBox("MAIN",25)
oView:SetOwnerView('VIEW_D3Q','MAIN')

oView:AddGrid('GRID_D3Q', oStruGRID, 'D3QDETAILS' )
oView:CreateHorizontalBox("GRID",75)
oView:SetOwnerView('GRID_D3Q','GRID')

oView:EnableTitleView('VIEW_D3Q',"Cabecalho")
oView:EnableTitleView('GRID_D3Q',"Grid") 

oView:AddIncrementField( 'GRID_D3Q', 'D3Q_ITEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA0001EVDEF
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author  Jorge Martins | Protheus Retail
@since   26/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Class ESTA0001EVDEF FROM FWModelEvent
	Data aModelSLK  // Model para operações em códigos de barras (SLK)

	Method New()
	Method FieldPreVld()
	Method GridLinePreVld()
	Method ModelPosVld()
	Method InTTS()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
New FWModelEvent
/*/
//-------------------------------------------------------------------
Method New() Class ESTA0001EVDEF
	self:aModelSLK := {}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cCamp     , nome do campo
@param xValue    , Novo valor do campo

@author  Jorge Martins | Protheus Retail
@since   26/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oSubModel, cModelId, cAction, cIdField, xValue) Class ESTA0001EVDEF
Local lRet   as Logical
Local oModel as Object

	oModel := oSubModel:GetModel()

	lRet := PreVldField(oModel, cAction, cIdField, xValue)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld()
Metodo de pré-validação do grid.

@param oSubModel    , Modelo principal
@param cModelId     , Id do submodelo
@param nLine        , Linha do grid
@param cAction      , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cIdField     , Nome do campo
@param xValue       , Novo valor do campo
@param xCurrentValue, Valor atual do campo

@author  Jorge Martins | Protheus Retail
@since   26/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cIdField, xValue, xCurrentValue) Class ESTA0001EVDEF
Local lRet   as Logical

	lRet := PreVldGrid(oSubModel, nLine, cAction, cIdField, xValue)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Model.

@author  Jorge Martins | Protheus Retail
@since   26/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class ESTA0001EVDEF
Local lRet     as Logical
Local aRetTemp as Array
	
	self:aModelSLK := {}

	lRet := AESTVldGrv(oModel) // Valida se existem linhas ativas no grid

	If lRet .And. D3Q->(ColumnPos("D3Q_CODBAR")) > 0 .And. !FwIsInCallStack("LJ210MANUT") // LJ210MANUT faz a sincronização da SLK para D3Q, então só sincroniza se não estiver sendo chamado por essa rotina, evitando loop infinito de chamadas
		aRetTemp := SincSLK(oModel) // Sincroniza dados da D3Q para SLK (Códigos de Barra por Produto)
		lRet := aRetTemp[1] // Atualiza o status de retorno com base no resultado da sincronização
		If lRet
			self:aModelSLK := aRetTemp[2] // Guarda o model atualizado da SLK para commit
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit 
após as gravações porém antes do final da transação

@param oModel  , Model que está sendo manipulado no momento do commit
@param cModelId, Id do model que está sendo manipulado, útil para identificar qual model está sendo processado em casos de múltiplos models

@author  Jorge Martins | Protheus Retail
@since   26/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oModel) Class ESTA0001EVDEF
Local nQtdMdls  as numeric
Local nMdl      as numeric

Default oModel := Nil

	If oModel <> Nil .And. !Empty(self:aModelSLK)

		nQtdMdls := Len(self:aModelSLK)

		For nMdl := 1 To nQtdMdls
			self:aModelSLK[nMdl]:CommitData()
			self:aModelSLK[nMdl]:DeActivate()
			self:aModelSLK[nMdl]:Destroy()
		Next
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} aESTVldGrv
Validacao de linhas ativas no grid

@since 01/08/2022;
@version P12
@author Adriano Vieira
/*/
//-------------------------------------------------------------------
Static Function AESTVldGrv(oModel)

Local lRet	 	 := .T.
Local nCount 	 := 0
Local nI		 := 0
Local oModelGRID := oModel:GetModel('D3QDETAILS')

If lRet  
	For nI := 1 To oModelGRID:Length() 
		oModelGRID:GoLine(nI) 
		If oModelGRID:IsDeleted()
			nCount := (nCount+1)
		EndIf
	Next nI 

	If oModelGRID:length()==nCount
		lRet :=.F.
		Help(" ",1,STR0011,,STR0012,1,4, NIL, NIL, NIL, NIL, NIL, {STR0013})	
	EndIf
Endif

Return lRet

/*/{Protheus.doc} IniPadProd()
Inicializador padrao do campo descricao do produto
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return cDescri
/*/
Function IniPadProd()

Local oModel    := FWModelActive()
Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aArea     := {}
Local cDescri   := ""

If !lInclui
    aArea := GetArea()
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek( xFilial("SB1")+D3Q->D3Q_PROD))
        cDescri := Alltrim(SB1->B1_DESC)
    EndIf

    RestArea(aArea)
EndIf

Return cDescri

/*/{Protheus.doc} IniPadProd()
Inicializador padrao do campo Unidade de Estoque do produto
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return cDescri
/*/
Function IniPadUM()

Local oModel    := FWModelActive()
Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aArea     := {}
Local cUm       := ""

If !lInclui
    aArea := GetArea()
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek( xFilial("SB1")+D3Q->D3Q_PROD))
        cUM := Alltrim(SB1->B1_UM)
    EndIf
    RestArea(aArea)
EndIf

Return cUM


/*/{Protheus.doc} EstConvUM
//Componente que realizar o calculo do Fator de Conversao da UM
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return ${nFator}

@type function
/*/
Function EstConvUM(cProd,cUniCom,nQuant) 
    Local nFator := 0
    Local aArea := {}
	Local lD3QExist := AliasIndic('D3Q')
    
    Default cProd   := ""
    Default cUniCom	:= ""
    Default nQuant  := 0

    If !Empty(cProd) .AND. !Empty(cUniCom)
		IF lD3QExist
			aArea := GetArea()

			DbSelectArea('D3Q')
			D3Q->(dbSetOrder(1))
			
			If D3Q->(dbSeek( xFilial("D3Q")+PadR(cProd,TamSX3("D3Q_PROD")[1])+cUniCom))
	
				nFator := nQuant * D3Q->D3Q_FATOR

			EndIf

			RestArea(aArea)	
		EndIf
    EndIf
    
Return nFator

/*/{Protheus.doc} PreVldField
Valida edição de campo no Cabelhaco

@author Adriano Vieira
@since 01/08/2022
@version 1.0
/*/
Function PreVldField(oModel,cAction,cIdField,cProd)

Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lAltera   := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local aArea 	:= {}
Local lRet  	:= .T.
Private cUnicom   := ""
If lInclui .OR. lAltera
	If cIdField == "D3Q_PROD" .AND. cAction == "SETVALUE"
		aArea := GetArea()
		D3Q->(dbSetOrder(1))
		if !empty(cUnicom)
			if D3Q->(dbSeek( xFilial("D3Q")+cProd+cUnicom))
				lRet := .F.
				Help(" ",1,STR0014,,STR0015, 1, 0,,,,,,{STR0016})
			EndIf
		elseif D3Q->(dbSeek( xFilial("D3Q")+cProd))
			lRet := .F.
			Help(" ",1,STR0014,,STR0015, 1, 0,,,,,,{STR0016})
		EndIf
		RestArea(aArea)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} ESTAD3Q
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Function ESTAD3Q()
Local lD3QExist := AliasIndic('D3Q')
Local lRet		:= .F.
Local aError := {}

IF lD3QExist
	lRet := .T.
	If !TcCanOpen("D3Q")
		dbSelectArea("D3Q")
  	EndIf
Else
	AADD(aError, STR0017)
	lRet := .F.
EndIf

Return aError

//-----------------------------------------------------------
/*{Protheus.doc} ESTADlg 
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Function ESTADlg(aErrorMsg)

Local nOpc := 0
Local cLink := "https://tdn.totvs.com/pages/viewpage.action?pageId=701678746"

nOpc := Aviso(STR0018, ESTAStr(aErrorMsg), { STR0019, STR0020 }, 3, "",, , .F.)

If nOpc == 1
    Return .F.
ElseIf nOpc == 2
    ShellExecute("open",cLink  ,"","",1)
Endif

Return

//-----------------------------------------------------------
/*{Protheus.doc} ESTAStr
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Static Function ESTAStr(aErrorMsg)

Local nX := 1
Local cString := ''

For nX := 1 to Len(aErrorMsg)
    cString += aErrorMsg[nX] + CRLF
    cString += CRLF
Next nX

return cString

//Funcionalidades REST API

/*/{Protheus.doc} oRestESTA0001
	Instancia do FwRestModel 
	@type  Class
	@author Rodrigo Lombardi
	@since 02/02/2024
	@version 1.0	
/*/
Class oRestESTA0001 From FwRestModel	
	Method Activate()
	Method DeActivate()
	Method Seek()
	Method Skip()
	Method SaveData()	
EndClass
/*/{Protheus.doc} 
	Activate
/*/
Method Activate() Class oRestESTA0001
    dbSelectArea("D3Q")   
	dbSetOrder(1)
Return _Super:Activate()
/*/{Protheus.doc} 
	DeActivate
/*/
Method DeActivate() Class oRestESTA0001
    D3Q->(dbCloseArea())    
Return _Super:DeActivate()


//-------------------------------------------------------------------
/*/{Protheus.doc} Seek
Método responsável buscar um registro em específico no alias selecionado.
Se o parametro cPK não for informaodo, indica que deve-se ser posicionado
no primeiro registro da tabela.
@param	cPK						PK do registro.
@return	lRet	Indica se foi encontrado algum registro.
@author Rodrigo Lombardi
@since 27/02/2024
/*/
//-------------------------------------------------------------------
Method Seek(cPK) Class oRestESTA0001
Local lRet := .F.

if empty(cPK)		
	D3Q->(DbGotop())
    lRet := !D3Q->(Eof())
elseif !Empty(cPK)    
	If D3Q->(dbSeek(cPK)) //cPK == Filial + Codigo + UniCom
       lRet := .T. 
    EndIf	
EndIf

Return lRet

/*/{Protheus.doc} Skip
	Pula registro
	@author Rodrigo Lombardi
	@since 27/02/2024
	@version 1.0
	@param nSkip
	@return lRet
/*/
Method Skip(nSkip) Class oRestESTA0001
Local lRet := .F. 
    D3Q->(DbSkip(nSkip))
    lRet := !D3Q->(Eof()) 
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Método responsável por salvar o registro recebido pelo metodo PUT ou POST.
Se o parametro cPK não for informado, significa que é um POST.

@param	cPK			PK do registro.
@param	cData		Conteúdo a ser salvo
@param	@cError	Retorna o alguma mensagem de erro
@return	lRet		Indica se o registro foi salvo

@author Rodrigo Lombardi
@since 27/02/2024
/*/
//-------------------------------------------------------------------
Method SaveData(cPK, cData, cError) Class oRestESTA0001
local lRet := .T.
Local oJson  as oBject

Default cData	:= ""

	If Empty(cPk)
		self:oModel:SetOperation(MODEL_OPERATION_INSERT)
	Else
		self:oModel:SetOperation(MODEL_OPERATION_UPDATE)
		lRet := self:Seek(cPK)
	EndIf

	If lRet
		self:oModel:Activate()
		//Pega o texto e transforma em objeto
   		oJson := JsonObject():New()
    	oJson:FromJson(cData)
		cUnicom := oJson["models"][1]["models"][1]["items"][1]["fields"][2]["value"]		
		lRet := self:oModel:LoadJsonData(cData)			
		If lRet
			If !(self:oModel:VldData() .And. self:oModel:CommitData())
				lRet := .F.
				cError := ErrorMessage(self:oModel:GetErrorMessage())					
			EndIf			
		Else
			cError := ErrorMessage(self:oModel:GetErrorMessage())			
		EndIf
		Self:oModel:DeActivate()
	Else
		cError := i18n("Invalid record '#1' on table #2", {cPK, self:cAlias})
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ErrorMessage
Funcao responsavel por retonar o erro do modelo.

@param aErroMsg Array de erro do modelo de dados

@return cRet Formato texto do array de erro do modelo de dados

@author Felipe Bonvicini Conti
@since 05/04/2016
@version P11, P12
/*/
//-------------------------------------------------------------------
Static Function ErrorMessage(aErroMsg)
Local cRet := CRLF + " --- Error on Model ---" + CRLF
	cRet += "Id submodel origin: [" + aErroMsg[1] + "]" + CRLF
	cRet += "Id field origin: [" + aErroMsg[2] + "]" + CRLF
	cRet += "Id submodel error: [" + aErroMsg[3] + "]" + CRLF
	cRet += "Id field error: [" + aErroMsg[4] + "]" + CRLF
	cRet += "Id error: [" + aErroMsg[5] + "]" + CRLF
	cRet += "Error menssage: [" + aErroMsg[6] + "]" + CRLF
	cRet += "Solution menssage: [" + aErroMsg[7] + "]" + CRLF
	cRet += "Assigned value: [" + cValToChar( aErroMsg[8] ) + "]" + CRLF
	cRet += "Previous value: [" + cValToChar( aErroMsg[9] ) + "]" + CRLF
	aErroMsg := aSize(aErroMsg, 0)
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SincSLK
Realiza a sincronizacao automatica de registros entre D3Q (Fatores de Conversao)
e SLK (Codigos de Barra), mantendo consistencia entre os cadastros.

Logica:
- INSERT ou UPDATE com D3Q_CODBAR: cria ou atualiza registro em SLK com LK_QUANT=D3Q_FATOR
- UPDATE limpando D3Q_CODBAR: nao faz nada em SLK (embalagem continua)
- DELETE com D3Q_CODBAR: deleta registro em SLK respeitando ponto de entrada LJ7210EXC

@param  oModel, Objeto do modelo (FWFormModel)
@return lRet  , Indica sucesso da sincronizacao

@author  Jorge Martins | Protheus Retail
@since   12/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function SincSLK(oModel)
Local lRet       as Logical
Local lDeleted   as Logical
Local nFator     as Numeric
Local nI         as Numeric
Local nOpc       as Numeric
Local cProd      as Character
Local cCodBar    as Character
Local oModelGRID as Object
Local aModelSLK  as Array

Default oModel := Nil

	lRet := .T.
	aModelSLK := {}

	If oModel <> Nil

		cProd      := oModel:GetModel("D3QMASTER"):GetValue('D3Q_PROD', nI)
		oModelGRID := oModel:GetModel("D3QDETAILS")
		nOpc       := oModel:GetOperation()

			For nI := 1 To oModelGRID:GetQtdLines()

				cCodBar  := oModelGRID:GetValue('D3Q_CODBAR', nI)
				nFator   := oModelGRID:GetValue('D3Q_FATOR' , nI)
				lDeleted := oModelGRID:IsDeleted(nI) .Or. nOpc == MODEL_OPERATION_DELETE
				
				// Se possui código de barras, sincroniza com SLK
				If !Empty(cCodBar)
				lRet := AjustaSLK(cProd, cCodBar, nFator, lDeleted, @aModelSLK)
				If !lRet
					Exit
				EndIf
				EndIf

			Next nI

	EndIf

Return {lRet, aModelSLK}

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSLK
Realiza a inclusão, atualização ou exclusão de registros na SLK (Códigos de Barra) 
com base nas alterações realizadas em D3Q (Fatores de Conversão), 
mantendo a consistência entre os cadastros.

@param  cProd  , Código do produto
@param  cCodBar  , Código de barras
@param  nFator , Fator de conversão (quantidade)
@param  lDelete  , Flag indicando se a operação é de exclusão (true para delete, false para insert/update)
@param  aModelSLK, Array para armazenar os modelos de SLK a serem commitados posteriormente
@return lRet   , Indica sucesso da sincronizacao

@author  Jorge Martins | Protheus Retail
@since   12/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function AjustaSLK(cProd, cCodBar, nFator, lDelete, aModelSLK)
Local lValid    as Logical
Local aAreaSLK as Array
Local oModel   as Object

Default cProd   := ""
Default cCodBar := ""
Default nFator  := 0
Default lDelete := .F.
Default aModelSLK := {}

	lValid    := .T.

	If !Empty(cProd) .And. !Empty(cCodBar)

		aAreaSLK := SLK->(GetArea())
		SLK->(dbSetOrder(2)) // LK_FILIAL + LK_CODIGO + LK_CODBAR

		If SLK->(dbSeek(xFilial('SLK') + cProd + cCodBar))

			If lDelete
				oModel := FWLoadModel('LOJA210')
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				oModel:Activate()
			Else
				oModel := FWLoadModel('LOJA210')
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()

				oModel:GetModel("LOJA210_SLK"):SetValue("LK_QUANT" , nFator)
				oModel:GetModel("LOJA210_SLK"):SetValue("LK_CODBAR", cCodBar)
			EndIf
		Else

			oModel := FWLoadModel('LOJA210')
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			oModel:GetModel("LOJA210_SLK"):SetValue("LK_QUANT" , nFator)
			oModel:GetModel("LOJA210_SLK"):SetValue("LK_CODBAR", cCodBar)
			oModel:GetModel("LOJA210_SLK"):SetValue("LK_CODIGO", cProd)
	EndIf

		If oModel:VldData()
			Aadd(aModelSLK, oModel) // Se válido, adiciona o model atualizado da SLK para commit posterior
		Else
			cProblema := cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cProblema += cValToChar(oModel:GetErrorMessage()[6])
			cSolucao  := cValToChar(oModel:GetErrorMessage()[7])
			lValid    := .F.
			aModelSLK := {}
			
			Help('', 1, '', ProcName(1), cProblema, 1,,,,,,, {cSolucao})
		EndIf

		RestArea(aAreaSLK)

	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldGrid
Valida edição de campos na grid

@param oModel  - Modelo de dados D3QDETAILS
@param nLine   - Número da linha editada
@param cAction - Tipo da ação realizada
@param cField  - Id do campo editado
@param xValue  - Valor informado no campo editado
@return lRet   - Indica se a edição do campo é válida ou não

@author  Daniel Tonon
@since   13/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function PreVldGrid(oModel, nLine, cAction, cField, xValue)
Local lRet as Logical

Default oModel   := Nil
Default nLine    := 0
Default cAction  := ""
Default cField   := ""
Default xValue   := Nil

	lRet := .T.

	If oModel <> Nil .And. !Empty(cField) .And. !Empty(cAction)
		If cField == "D3Q_CODBAR" .AND. cAction == "SETVALUE" .AND. !Empty(xValue)
			lRet := VldCdbar(xValue, oModel)
		ElseIf cField == "D3Q_PCOMP" .AND. cAction == "SETVALUE" .AND. xValue == .T.
			lRet := VldProc("D3Q_PCOMP", oModel)
		ElseIf cField == "D3Q_PMOVI" .AND. cAction == "SETVALUE" .AND. xValue == .T.
			lRet := VldProc("D3Q_PMOVI", oModel)
		ElseIf cField == "D3Q_PVEND" .AND. cAction == "SETVALUE" .AND. xValue == .T.
			lRet := VldProc("D3Q_PVEND", oModel)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCdbar
Valida duplicidade do código de barras na base e na grid

@param cValor     - Código de barras a ser validado
@param oModelGRID - Modelo de dados D3QDETAILS
@return lRet      - Indica se o código de barras é válido ou não

@author  Daniel Tonon
@since   13/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function VldCdbar(cValor, oModelGRID)
Local lRet           As Logical
Local aArea          As Array
Local cProblema      As Character
Local cSolucao       As Character
Local nI             As Numeric
Local cCodBar        As Character
Local nLinAtual      As Numeric

Default cValor     := ""
Default oModelGRID := Nil

	lRet := .T.

	If !Empty(cValor) .And. oModelGRID <> Nil
		aArea := GetArea()

		// Validação na base de dados
		D3Q->(dbSetOrder(1))
		D3Q->(dbGoTop())

		nLinAtual := oModelGRID:GetLine()

		// Validação de duplicidade na grid
		If lRet
			For nI := 1 To oModelGRID:Length()
				If nI != nLinAtual .AND. !oModelGRID:IsDeleted(nI)
					cCodBar := oModelGRID:GetValue("D3Q_CODBAR", nI)

					If !Empty(cCodBar) .AND. AllTrim(cCodBar) == AllTrim(cValor)
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nI
		EndIf

		If lRet // Se não encontrou duplicidade na grid, valida na base de dados
			lRet := ExistCdbar(oModelGRID, cValor)
		EndIf

		// Exibe mensagem de erro se houve duplicidade
		If !lRet
			cProblema := STR0021 // "Código de barras já cadastrado!"
			cSolucao  := STR0022 // "O código de barras informado já existe. Altere para um código de barras diferente."
			Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
		EndIf

		RestArea(aArea)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistCdbar
Verifica se código de barras já existe cadastrado

@param   oModel - Modelo de dados D3QDETAILS
@param   cValor - Código de barras a ser verificado
@return  lValid - Indica se o código de barras é válido (não existe) ou não (já existe)

@author  Daniel Tonon
@since   19/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ExistCdbar(oModel, cValor)
Local lValid    As Logical
Local cQuery    As Character
Local cAliasDup As Character
Local oDup      As Object
Local nParam    As Numeric

Default oModel := Nil
Default cValor := ""

	lValid := .T.

	If oModel <> Nil .And. !Empty(cValor)

		nParam    := 1
		cAliasDup := GetNextAlias()

		cQuery := "SELECT COUNT(1) QTDE"
		cQuery +=  " FROM " + RetSqlName("D3Q") + " D3Q"
		cQuery += " WHERE D3Q.D3Q_FILIAL = ?" // #1
		cQuery +=   " AND D3Q.D3Q_CODBAR = ?" // #2
		cQuery +=   " AND D3Q.D_E_L_E_T_ = ?" // #3

		oDup := D3QGetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

		oDup:SetString(nParam++, FWxFilial("D3Q")) // #1
		oDup:SetString(nParam++, cValor) // #2
		oDup:SetString(nParam++, Space(1)) // #3

		oDup:OpenAlias(cAliasDup)

		If !(cAliasDup)->(EOF()) .And. (cAliasDup)->QTDE > 0 // Se existir vínculo com os mesmos parâmetros informa o erro
			lValid := .F.
		EndIf

		(cAliasDup)->(DBCloseArea())
	EndIf

Return lValid

//------------------------------------------------------------------------------
/*/{Protheus.doc} D3QGetQry
Obtém o objeto (FwExecStatement) de query preparada para a expressão SQL informada.

@param   cQuery, Character, Expressão SQL
@return  oPrepared, Object, Objeto de query preparada

@author  Daniel Tonon
@since   19/05/2026
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function D3QGetQry(cQuery)
Local oPrepared    as Object
Local nPosPrepared as Numeric
Local cMD5         as Character

Default cQuery := ""

	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared,{FwExecStatement():New(cQuery), cMD5})
		nPosPrepared := Len(__aPrepared)
	Endif

	oPrepared := __aPrepared[nPosPrepared][1]

Return oPrepared

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldProc
Valida seleção de processo para evitar duplicidade em linhas diferentes
Garante que apenas uma linha possa ter o processo marcado

@param cCampo     - Campo do processo a ser validado (D3Q_PCOMP, D3Q_PMOVI ou D3Q_PVEND)
@param oModelGRID - Modelo de dados da grid (D3QDETAILS)
@return lRet      - Indica se a seleção do processo é válida ou não

@author  Daniel Tonon
@since   19/05/2026
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function VldProc(cCampo, oModelGRID)
Local lRet        as Logical
Local oView       as Object
Local nI          as Numeric
Local nLinAtual   as Numeric
Local nQtdLinha   as Numeric
Local lEncontrou  as Logical

Default cCampo     := ""
Default oModelGRID := Nil

	lRet := .T.

	If !Empty(cCampo) .And. oModelGRID <> Nil

		nLinAtual   := oModelGRID:GetLine()
		nQtdLinha   := oModelGRID:Length()
		lEncontrou  := .F.

		// Se está marcando como verdadeiro, deve desmarcar as demais linhas
		For nI := 1 To nQtdLinha
			If !oModelGRID:IsDeleted(nI)
				If nI != nLinAtual .AND. oModelGRID:GetValue(cCampo, nI) == .T.
					oModelGRID:GoLine(nI)
					oModelGRID:SetValue(cCampo, .F.) // Desmarca as demais linhas
					lEncontrou := .T.
				EndIf
			EndIf
		Next nI

		oModelGRID:GoLine(nLinAtual)

		// Se encontrou alguma marcação prévia, atualiza a view
		If lEncontrou .AND. !IsBlind()
			oView := FWViewActive()
			oView:Refresh("D3QDETAILS")
		EndIf
	EndIf

Return lRet
