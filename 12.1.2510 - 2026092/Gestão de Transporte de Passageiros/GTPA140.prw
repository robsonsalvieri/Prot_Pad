#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA140.CH"

#DEFINE WS_COLS 05	//Quantidade de colunas da WorkSheet
#DEFINE WS_ROWS 10	//Quantidade de linhas da WorkSheet

Static oWorkSheet	:= nil	//Objeto da Planilha de Cálculo
Static __cXmlPlanilha:= ""


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA140()
Rotina responsável por cadastrar os custos de uma viagem especial. 
@sample		GTPA140() 
@return		oBrowse  Retorna o Cadastro de Custos de Viagens
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA140()

Local oBrowse := nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
 
	DbSelectArea("GIM")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('GIM')
	oBrowse:SetDescription(STR0001)//"Custo de Viagem"

	oBrowse:Activate()

EndIf

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo de Dados
@sample		ModelDef() 
@return		oModel	Objeto do Modelo de Dados
@author		Inovação

@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= nil
Local oStruct	:= FWFormStruct(1, 'GIM')

oModel := MPFormModel():New('GTPA140',/*bPreVld*/, {|| GA140PosVld(oModel)})

oModel:AddFields( 'GIMMASTER', /*cOwner*/, oStruct )
oModel:SetPrimaryKey({ 'GIM_FILIAL', 'GIM_COD'})
oModel:SetDescription(STR0001)		//""Custo de Viagem"


oStruct:SetProperty('*' ,MODEL_FIELD_WHEN   , {||  !FWIsInCallStack("GTPA140ExVw")  } )

oModel:SetActivate( {|oModel| TP140SetXml( oModel ) } )

oModel:DeActivate({|| TP140ClearObj(oWorkSheet) })

Return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface 
 
@sample		ViewDef() 
@return		oView  Retorna a View
 
@author		Inovação

@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel('GTPA140')
Local oStruct		:= FWFormStruct(2, 'GIM')
Local oView			:= nil
Local oPanel		:= nil

oStruct:RemoveField("GIM_PLAN")

oStruct:SetProperty("GIM_COD"  		,MVC_VIEW_ORDEM,"01")
oStruct:SetProperty("GIM_DESCRI"  	,MVC_VIEW_ORDEM,"02")

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	oStruct:SetProperty("GIM_UTILIZ"  	,MVC_VIEW_ORDEM,"03")
Endif

oStruct:SetProperty("GIM_UM"  		,MVC_VIEW_ORDEM,"04")
oStruct:SetProperty("GIM_DESUM"  	,MVC_VIEW_ORDEM,"05")
oStruct:SetProperty("GIM_PRODUT"  	,MVC_VIEW_ORDEM,"06")
oStruct:SetProperty("GIM_DESPRO"  	,MVC_VIEW_ORDEM,"07")
//oStruct:SetProperty("GIM_TPCUST"  	,MVC_VIEW_ORDEM,"07")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('CABECALHO', oStruct, 'GIMMASTER')
oView:AddOtherObject('PLANILHA', {|oPanel| TP140CreatePlan(oPanel)})

oView:CreateHorizontalBox('MAIN', 30)
oView:CreateHorizontalBox('BODY', 70)

oView:SetOwnerView('CABECALHO', 'MAIN')
oView:SetOwnerView('PLANILHA', 'BODY')

oView:SetContinuousForm(.T.) //Exibe a tela como se fosse uma página web com barra de rolagem
	
oView:AddUserButton( STR0035, ""	, {|oView| Tp140MrkBr(oView) } ) //"Inclusão de Campos Plan."

Return oView


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample		MenuDef() 
@return		aRotina  Retorna as opções do Menu
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.GTPA140' OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA140' OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA140' OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA140' OPERATION 5 ACCESS 0 // #Excluir
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA140' OPERATION 8 ACCESS 0 // #Imprimir
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.GTPA140' OPERATION 9 ACCESS 0 // #Copiar

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140SetXml()
Alimenta variavel static __cXmlPlanilha - (Formula de Calculo)
 
@sample		TP140SetXml() 
@return		oModel  Modelo de Dados
@author		Inovação
@since		20/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP140SetXml( oModel )

Local oField := oModel:GetModel("GIMMASTER")

//-- Reinicia var
__cXmlPlanilha := ""


//-- Se a inclusão vier de uma cópia alimenta campo da planilha da calculo.
If oModel:Getoperation() == MODEL_OPERATION_INSERT .And. oModel:IsCopy() .And. !Empty(GIM->GIM_PLAN)
	oField:LoadValue("GIM_PLAN",GIM->GIM_PLAN)
	__cXmlPlanilha := GIM->GIM_PLAN
EndIf

If ( oModel:Getoperation() != MODEL_OPERATION_INSERT )
	If Empty(__cXmlPlanilha)
		__cXmlPlanilha := oField:GetValue('GIM_PLAN')
	EndIf
EndIf


Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA140PosVld()
Faz a gravação do modelo de dados. O commit foi persolanizado para permitir a gravação da
Planilha de cálculo usada para personalizar o cálculo do custo.
 
@sample		GA140PosVld(oModel)

@param		oModel	Objeto com o modelo de dados.
@return		lRet	Booleano indicando se a gravação foi bem sucedida.
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA140PosVld(oModel)
Local lRet 			:= .T.
Local nOperation	:= oModel:GetOperation()
Local cUtiliz		:= ''

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	cUtiliz := oModel:GetModel('GIMMASTER'):GetValue('GIM_UTILIZ')
Endif

If ValidWorkSheet(cUtiliz)	//Valida os dados da planilha de cálculo
	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		SaveWorkSheet(oModel)
	EndIf
Else
    lRet := .F. 
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140CreatePlan()
Cria a planilha de cálculo para uso no custo.
 
@sample	TP140CreatePlan() 
@param	oPanel	Painel onde será criado o objeto FWUIWorkSheet.
@author	Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140CreatePlan(oPanel)

Local oModel			:= FwModelActive()
Local oView				:= FwViewActive()
Local oFWLayer			:= nil
Local oWinPlanilha		:= nil
Local bPosChange		:= {|| PosChangeWorkSheet(oWorkSheet,oModel, oView)}		//Função acionada após a alteração da planilha
Local nOperation		:= oModel:GetOperation()		//Opearação que está sendo realizada


oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F.)
oFWLayer:AddCollumn( "C1", 100, .T. )
oFWLayer:AddLine( "L1", 100)
oFWLayer:addWindow( "C1", "W2", STR0015, 100,.F., .F., {|| Nil } )//"Planilha de Cálculo"

//---------------------------------------
// PLANILHA de Cálculo
//---------------------------------------
oWinPlanilha 	:= oFWLayer:getWinPanel( "C1", "W2" )
oWorkSheet 		:= FWUIWorkSheet():New(oWinPlanilha,iif(nOperation == 3 .And. !oModel:IsCopy(),.T.,.F. ), WS_ROWS, WS_COLS)

oWorkSheet:SetbPosChange(bPosChange)

If (nOperation == MODEL_OPERATION_INSERT .And. !oModel:IsCopy() )
	//Monta cabeçalho da planilha
	oWorkSheet:SetCellValue("A1", STR0010) 	//"Campo Referencia"
	oWorkSheet:SetCellValue("B1", STR0011)	//"Descrição"
	oWorkSheet:SetCellValue("C1", STR0012)	//"VALOR"	
	oWorkSheet:SetCellValue("D1", STR0013)	//"FORMULA"	

EndIf	

//-- Carrega planilha de calculo
If !Empty(__cXmlPlanilha) 
	oWorkSheet:lShow := .T.
	oWorkSheet:LoadXmlModel(__cXmlPlanilha)
EndIf

	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosChangeWorkSheet()
Função executada após uma alteração na planilha de cálculo.
@sample	PosChangeWorkSheet(oModel, oView)
@param		oModel	Objeto com o modelo de dados.
@param		oView	Objeto com a interface.
@author	Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function PosChangeWorkSheet(oWorkSheet,oModel, oView)

Local nOperation 	:= oModel:GetOperation()

//Seta as propriedades do model e da view para o status de alterada quando a planilha 
//sofrer uma modificação, forçando a obrigatoriedade de salvar os dados.
If (nOperation == MODEL_OPERATION_UPDATE .Or. (nOperation == MODEL_OPERATION_INSERT .And. oModel:IsCopy()) )
	oView:SetModified()
	oWorkSheet:OOWNER:LMODIFIED := .T.
	oModel:lModify := .T.
	SaveWorkSheet(oModel)
EndIf

Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveWorkSheet()
Função para salvar os dados da planilha de cálculo em formato XML em um campo
da tabela do modelo de dados.
@sample	SaveWorkSheet(oModel, cCampo)
@param		oModel	Objeto com o modelo de dados para salvar a planilha de cálculo.
@author	Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function SaveWorkSheet(oModel)

Local cXML 		:= ""
Local oModelGIM	:= oModel:GetModel("GIMMASTER")

	cXML := oWorkSheet:GetXmlModel()
	
	oModelGIM:SetValue("GIM_PLAN", cXML)
	
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidWorkSheet(cUtiliz)
Função para validar os dados da planilha de cálculo.
@sample	ValidWorkSheet()
@return	lRet	Valor lógico indicando se os dados da planilha são válidos.
@author	Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ValidWorkSheet(cUtiliz)

	Local lRet			:= .T.
	Local nLinha		:= 0
	Local nColuna		:= 0
	Local cCampo		:= ''
	Local cMsg			:= ''
	Local aColValid		:= {'A'}	//Colunas que devem ser validadas com relação a seu conteúdo.
	Local aTitulo		:= {STR0010,STR0011,STR0012, STR0013}	//'Campo Referência'| 'Descrição' | 'Valor' | 'Formula'

	For nLinha := 2 To oWorkSheet:NTOTALLINES

		For nColuna := 1 To Len(aColValid)
	
			//Valida se o valor preenchido na célula é válido.
			cColuna := aColValid[nColuna] + AllTrim(Str(nLinha))
			
			If (oWorkSheet:CellExists(cColuna))
				cCampo := oWorkSheet:GetCellValue(cColuna)
			
				If (!Empty(cCampo))
				
					If (ValType(cCampo) != 'C')
						lRet := .F.
						cMsg := STR0016 + cColuna + STR0017	//#O valor informado na célula + cColuna + #  deve ser um nome de campo ou um valor precedido de "#".
						Exit
					Else
						If (SubStr(cCampo, 1, 1) != "'")
						
							If (!ExistCampo(cCampo, cUtiliz))
								lRet := .F.
								cMsg := STR0018 + cColuna + STR0019 + aTitulo[nColuna] + STR0020	//'O nome do campo informado na célula "' | '" como "' | '" não é válido.'
								Exit
							EndIf
						
						EndIf
					EndIf
				EndIf
			EndIf
		
		Next
	
		If (!lRet)
			Exit
		EndIf
	Next

	If (!lRet)
		Alert(cMsg)
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistCampo()
Função para validar se o campo utilizado na planilha de cálculo existe no dicionário.
@sample		ExistCampo(cCampo)
@param		cCampo	Nome do campo que que deve ser validado.
@return		lRet	Valor booleano indicando se o campo foi encontrado ou não.
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ExistCampo(cCampo, cUtiliz)

	Local aArea	:= GetArea()
	Local lRet		:= .F.
	Local cTables := ''

	Do Case
		Case cUtiliz == '1'
			cTables := "ADZ|ADY|GIN|GIP|GIO|G6R|"
		Case cUtiliz == '2'
			cTables := "GY0|GQJ|GYD|GQI|GYX|GQZ|GQR|G9W|G54"
		Case cUtiliz == '3'
			cTables := "G99|G5J|G9S|GZN|H66|G9R|G9Q|G9P|GIR|GIY"
	EndCase

	DbSelectArea("SX3")		//Tabela de Campos do Dicionário
	SX3->(DbSetOrder(2))	//X3_CAMPO

	If SubStr(cCampo,1,3) $ cTables .And. (SX3->(DbSeek(cCampo)))
		lRet := .T.
	EndIf

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140ClearObj()
Destroi/Limpa  objeto (Planilha)
@sample		TP140ClearObj(oWorkSheet)
@param		oWorkSheet	Objeto FwUIWorksheet - (Planilha)
@return			
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140ClearObj(oWorkSheet)

If ValType(oWorkSheet) == "O"
	oWorkSheet:Close()
	oWorkSheet:Destroy()
	FreeObj(oWorkSheet)
EndIf 

__cXmlPlanilha := ""

Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140CusTot()
Calcula o valor total de um custo.
 
@sample		TP140CusTot()

@return		nCusto	Valor Total do Custo.
 
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140CusTot()

Local nCusto	:= 0
Local nQuant	:= FwFldGet('GIO_QUANT')
Local nCusUni	:= FwFldGet('GIO_CUSUNI')

If (!Empty(nQuant)) .And. (!Empty(nCusUni))
	nCusto := nQuant * nCusUni
EndIf

Return nCusto
/*/{Protheus.doc} Tp140MrkBr
FWMarkBrowse para selecionar os campos que serão inclusos na planilha
@type  Static Function
@author Kaique Olivero
@since 18/09/2023
@param oView, Recebe a View para alteração do modelo
/*/
Static Function Tp140MrkBr(oView)
Local aStruct		:= {}
Local aIdx			:= {}
Local aSeek			:= {}
Local aInsertTmp	:= {}
Local aColumns		:= {}
Local aCampSX3		:= {}
Local lOk			:= .T.
Local nStepCmmIns	:= 900
Local nX			:= 0
Local oMrkBrowse	:= Nil 
Local oGTPTmpTb		:= Nil

//Permitido apenas para Orçamento de Viagens Especiais
If oView:GetModel('GIMMASTER'):GetValue('GIM_UTILIZ') == "1"
	//Aviso sobre alteração da planilha
	If MsgYesNo( STR0022, STR0023) //"Ao selecionar os campos e confirmar, o sistema irá sobrepor as informações da planilha, deseja continuar?"##"Inclusão de Campos"
		aCampSX3 := Tp140ColX3()
		If len(aCampSX3) > 0
			//Cria estrutura e tabela tmp com os campos necessarios
			Aadd(aStruct, {"OK"        	, "C", 1 	, 0	})
			Aadd(aStruct, {"SX3_CAMPO"	, "C", 10	, 0 })
			Aadd(aStruct, {"SX3_TITULO"	, "C", 12	, 0 })
			Aadd(aStruct, {"SX3_DESCRI" , "C", 25	, 0 })
			
			//Cria indices para a tabela temporária 
			Aadd(aIdx, {"I1",{ 'SX3_CAMPO' }})
			Aadd(aIdx, {"I2",{ 'SX3_TITULO'}})
		
			//Cria array da busca de acordo com os indices da tabela temporária
			aAdd(aSeek, {STR0024,{{'','C',10,0,STR0024,PesqPict('SX3','X3_CAMPO'),NIL}},1}) //"Cód. Campo"
			aAdd(aSeek, {STR0025,{{'','C',12,0,STR0025,PesqPict('SX3','X3_TITULO'),NIL}},2}) //"Nome Campo"
			
			//Instancia o método NEW para criação da tabela temporária
			oGTPTmpTb := GSTmpTable():New('RESGYG',aStruct, aIdx, {}, nStepCmmIns )
			cRetTab  := 'RESGYG'
			
			//Validação para a criação da tabela temporária
			If oGTPTmpTb:CreateTMPTable()
				//Preenche Tabela temporária com as informações filtradas
				For nX := 1 To Len(aCampSX3)
					aInsertTmp :={}
					Aadd(aInsertTmp, {'SX3_CAMPO'  ,aCampSX3[nX,1]})
					Aadd(aInsertTmp, {'SX3_TITULO' ,aCampSX3[nX,2]})
					Aadd(aInsertTmp, {'SX3_DESCRI' ,aCampSX3[nX,3]})
						
					If oGTPTmpTb:Insert(aInsertTmp)
						lOk := oGTPTmpTb:Commit()
					EndIf

				Next nX
			Else
				oGTPTmpTb:ShowErro()
			EndIf
			
			oMrkBrowse := FWMarkBrowse():New()			
			
			//Colunas MarkBrowse
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+"SX3_CAMPO"+"}") )
			aColumns[Len(aColumns)]:SetTitle(STR0024) //"Cód. Campo"
			aColumns[Len(aColumns)]:SetSize(10)
			aColumns[Len(aColumns)]:SetDecimal(0)
			aColumns[Len(aColumns)]:SetPicture(PesqPict('SX3','X3_CAMPO'))

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+"SX3_TITULO"+"}") )
			aColumns[Len(aColumns)]:SetTitle(STR0025) //"Nome Campo"
			aColumns[Len(aColumns)]:SetSize(12)
			aColumns[Len(aColumns)]:SetDecimal(0)
			aColumns[Len(aColumns)]:SetPicture(PesqPict('SX3','X3_TITULO'))

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+"SX3_DESCRI"+"}") )
			aColumns[Len(aColumns)]:SetTitle(STR0026) //"Descr. Campo"
			aColumns[Len(aColumns)]:SetSize(12)
			aColumns[Len(aColumns)]:SetDecimal(0)
			aColumns[Len(aColumns)]:SetPicture(PesqPict('SX3','X3_DESCRIC'))

			DEFINE MSDIALOG oDlg TITLE STR0027 From 300,0 To 700,800 PIXEL //"Inclusão de campos na planilha" 
			oMrkBrowse:SetOwner(oDlg)
			oMrkBrowse:DisableFilter()
			
			oMrkBrowse:SetDescription(STR0028) //"Incluir campos"
			oMrkBrowse:SetTemporary(.T.)
			oMrkBrowse:AddButton(STR0029, {|| At140Conf(oView,oMrkBrowse) ,oDlg:End(), oMrkBrowse:Refresh(.T.) },,3,) //"Confirmar"
			oMrkBrowse:AddButton(STR0030, {|| oDlg:End(), oMrkBrowse:Refresh(.T.)}) // "Cancelar"
			oMrkBrowse:SetFieldMark("OK")
			oMrkBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			oMrkBrowse:SetSeek(.T., aSeek)
			oMrkBrowse:SetAllMark( { || oMrkBrowse:AllMark() } )
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:DisableReport()
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:DisableDetails()
			oMrkBrowse:Activate(oDlg)
			ACTIVATE MSDIALOG oDlg CENTERED
			oGTPTmpTb:Close()
			TecDestroy(oGTPTmpTb)			 
		EndIf
	EndIf
Else
	FWAlertHelp(STR0031,STR0032,"Tp140MrkBr") //"Não é possível utlizar a inclusão de campos."##"Inclusão de campo habilitado só para Viagens Especiais."
Endif

Return

/*/{Protheus.doc} Tp140ColX3
Colunas com as informações de cada campo da G6R
@type  Static Function
@author Kaique Olivero
@since 18/09/2023
@ret aHeader, Retorno com as informações da estrutura da G6R
/*/
Static Function Tp140ColX3()
Local aStruct := G6R->(dBStruct())
Local aHeader := {}
Local nX := 0

//Percorre todos os campos da estrutura da tabela
For nX := 1 To Len(aStruct)
	If GetSX3Cache(aStruct[nX,1], "X3_CONTEXT") == "R"
		AAdd(aHeader, { GetSX3Cache(aStruct[nX,1], "X3_CAMPO"),;
						GetSX3Cache(aStruct[nX,1], "X3_TITULO"),;
						GetSX3Cache(aStruct[nX,1], "X3_DESCRIC")})	
	Endif
Next nX

Return aHeader

/*/{Protheus.doc} At140Conf
Array com os dados da planilha 
@type  Static Function
@author Kaique Olivero
@since 18/09/2023	
@param oVw, Recebe a View para alteração do modelo
		oMark, Obejto com o FWMarkBrowse
/*/
Static function At140Conf(oVw,oMark)
Local nX        := 1
Local cAlias 	:= oMark:Alias()
Local aPlanilha := {}

(cAlias)->(DbGoTop())
 While (cAlias)->(!Eof())
	If !Empty((cAlias)->OK)
		Aadd(aPlanilha,{{"A"+cValTochar(nX+1), (cAlias)->SX3_CAMPO },;
						{"B"+cValTochar(nX+1), (cAlias)->SX3_DESCRI },;
						{"C"+cValTochar(nX+1), (cAlias)->SX3_CAMPO }})
		nX++
	Endif
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbGoTop())

//Se houver registros selecionados realiza o processamento 
If !Empty(aPlanilha)
	FwMsgRun(Nil,{|| At140ExecPl(oVw,aPlanilha)},STR0033,STR0034) //"Inserindo campos."##"Inserindo campos na planilha..."
Endif

Return .T.

/*/{Protheus.doc} At140ExecPl
Executa inclusão dos campos na planilha 
@type  Static Function
@author Kaique Olivero
@since 18/09/2023	
@param oVw, Recebe a View para alteração do modelo
		aPlan, Registros selecionados no FWMarkBrowse
/*/
Static Function At140ExecPl(oVw,aPlan)
Local nX := 0
Local nTotPlan := Len(aPlan)
If nTotPlan > 0
	oWorkSheet:ReInit(1,1,.F.)
	oWorkSheet:ResizePlan(nTotPlan+5,WS_COLS)
	oWorkSheet:SetCellValue("A1", STR0010) 	//"Campo Referencia"
	oWorkSheet:SetCellValue("B1", STR0011)	//"Descrição"
	oWorkSheet:SetCellValue("C1", STR0012)	//"Valor"	
	oWorkSheet:SetCellValue("D1", STR0013)	//"Formula"	
	For nX := 1 to nTotPlan
		oWorkSheet:SetCellValue(aPlan[nX,1,1],aPlan[nX,1,2]) //Coluna A
		oWorkSheet:SetCellValue(aPlan[nX,2,1],aPlan[nX,2,2]) //Coluna B
		oWorkSheet:SetCellValue(aPlan[nX,3,1],0)			 //Coluna C
		oWorkSheet:SetNickName(aPlan[nX,3,1],aPlan[nX,3,2])  //Nick name coluna C
	Next nX
	//Salva a planilha no campo de xml
	SaveWorkSheet(oVw:GetModel())
Endif

Return
