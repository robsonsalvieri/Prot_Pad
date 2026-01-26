#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA316.CH"


Static cQryMD5CJU				as character
Static oExecCJU 				as object
Static cIDCJT	:="CJT_IDFIL"	as character
Static cIDCJU	:="CJU_ID"		as character
Static cQryMD5CJT				as character
Static oExecCJT					as object
Static oRegex					as object

PUBLISH MODEL REST NAME FISA316 SOURCE FISA316

/*/{Protheus.doc} FISA316
	(Função que cria a tela MVC para cadastro do pré agendamento do schedule. 
	A rotina carrega a tela com o cadastro dos parâmetros para gerar a apuração e o arquivo do EFD Contribuições)
	@type Function
	@author Matheus Massarotto
	@since 22/03/2024
	@version version 12.1.2410
	@param N/A
	@return Nil, Nil, N/A
	@example
	(examples)
	@see (https://tdn.totvs.com/pages/viewpage.action?pageId=844256967)
/*/
Function FISA316()
	Local   oBrowse as object

	If AliasIndic("CJT") .AND. AliasIndic("CJU")
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CJT")
		oBrowse:SetDescription(STR0001) //"Pré Agendamento Schedule"
		oBrowse:Activate()    
	else
		Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, não foi encontrado a(s) tabela(s) CJT/CJU, verifique as atualizações do sistema"
	Endif

	FreeObj(oExecCJU)
	FreeObj(oExecCJT)
	cQryMD5CJT:=""
	cQryMD5CJU:=""
	FreeObj(oRegex)
Return

/*/{Protheus.doc} MenuDef
	(Função padrão menudef)
	@type  Static Function
	@author Matheus Massarotto
	@since 22/03/2024
	@version version 12.1.2410
	@param N/A
	@return aRotina, Array, Array
	@example
	(examples)
	@see ()
/*/
Static Function MenuDef()
Local aRotina	:= {} as array

	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.FISA316' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.FISA316' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.FISA316' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.FISA316' OPERATION 5 ACCESS 0 //'Excluir'

	If FindFunction('CallSchedule')
		ADD OPTION aRotina TITLE 'Monitor do Schedule'  ACTION 'EfdAgenda()' OPERATION 8 ACCESS 0
	Endif

Return aRotina

/*/{Protheus.doc} ModelDef
	(Função padrão ModelDef do MVC)
	@type  Static Function
	@author Matheus Massarotto
	@since 22/03/2024
	@version version 12.1.2310
	@param N/A
	@return oModel, Objeto, objeto modelo do MVC
	@example
	(examples)
	@see ()
/*/
Static Function ModelDef()
	Local oStruGener 		 as object
	Local oStruItem	 		 as object
	Local oModel	 		 as object
	Local oFdFoldCJU		 as object
	Local nFldItens	 := 1  	 as numeric
	Local bLoadItem  := { |oGridModel, lCopy| f316LdGrid(oGridModel, lCopy, oModel) } as codeblock
	Local bCommit	 := { |oModel|f316Commit(oModel)} 								  as codeblock
	Local bValid 	 := { |oModel| ValidForm(oModel) }								  as codeblock

	oFdFoldCJU	:= totvs.protheus.backoffice.fiscal.fisa001.utils.FieldForFolder():new("CJU")
	oFdFoldCJU:getFieldsToJson()

	oStruGener 	:= FWFormStruct( 1,"CJT")
	oStruItem 	:= FWFormStruct( 1,"CJU")

	//Adiciona campos adicionais
	AddCampos(oStruItem,"MODEL")

	//Setando X3_WHEN dos campos
	SetOCamp(@oStruItem ,oFdFoldCJU,nFldItens,MODEL_FIELD_WHEN, {|| .F. } )

	//Setando inicialização do campo de ID e do código de registro
	oStruGener:SetProperty(cIDCJT	, MODEL_FIELD_INIT	 , {|| FWUUIDV4()})

	oModel	:=	MPFormModel():New('FISA316CAB',,bValid,bCommit)

	oModel:AddFields( 'FISA316CAB' ,, oStruGener )
	oModel:AddGrid( 'FISA316ITEM', 'FISA316CAB', oStruItem,,,,,bLoadItem)
	oModel:GetModel("FISA316ITEM"):SetForceLoad(.T.) //carga(load) do subformulário será executado em todas as Operações
	oModel:GetModel("FISA316ITEM"):SetNoInsertLine(.T.)
	oModel:GetModel("FISA316ITEM"):SetNoDeleteLine(.T.)
	
	oModel:SetRelation( 'FISA316ITEM', { { 'CJU_FILIAL', 'xFilial( "CJU" )' }, { cIDCJT, cIDCJU }  },CJU->( IndexKey( 1 ) )  )
	oModel:SetPrimaryKey( { "CJU_ID","CJU_EMPSEL","CJU_FILSEL" } )
	
	//==================================Propriedades dos campos=============================================

	//Não permite alterar codigo quando alteração
	oStruGener:SetProperty('CJT_CODREG' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == 3) })

	//Validação para não permitir informar um código de agendamento que já exista.
	oStruGener:SetProperty('CJT_CODREG' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})
	oStruGener:SetProperty('CJT_TPPROC' , MODEL_FIELD_VALID, {||( SetObrigat(oStruGener, oModel) )})

	//Validação dos campos da pasta geral da tela
	oStruGener:SetProperty( 'CJT_FDTINI' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_FDTINI',oModel) })
	oStruGener:SetProperty( 'CJT_FDTFIM' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_FDTFIM',oModel) })

	oStruGener:SetProperty( 'CJT_TPPER' , MODEL_FIELD_WHEN, { ||TpPerFor(oModel,oStruGener) })

	//Validação dos campos da pasta Apuração
	oStruGener:SetProperty( 'CJT_DETRCX' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_DETRCX',oModel) })
	oStruGener:SetProperty( 'CJT_IREGCM' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_IREGCM',oModel) })

	//Validação dos campos da pasta Apuração - Guia de pagamento
	oStruGener:SetProperty( 'CJT_DIAVCT' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_DIAVCT',oModel) })
	oStruGener:SetProperty( 'CJT_TPVCTO' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_TPVCTO',oModel) })
	oStruGener:SetProperty( 'CJT_MESSUB' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_MESSUB',oModel) })
	oStruGener:SetProperty( 'CJT_ANTPOS' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_ANTPOS',oModel) })
	oStruGener:SetProperty( 'CJT_CRPISC' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_CRPISC',oModel) })
	oStruGener:SetProperty( 'CJT_CRCOFC' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_CRCOFC',oModel) })
	oStruGener:SetProperty( 'CJT_CRPSNC' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_CRPSNC',oModel) })
	oStruGener:SetProperty( 'CJT_CRCFNC' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_CRCFNC',oModel) })
	oStruGener:SetProperty( 'CJT_CRCPRB' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_CRCPRB',oModel) })

	//Validação dos campos da Pasta Arquivos
	oStruGener:SetProperty( 'CJT_NRECIB' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_NRECIB',oModel) })
	oStruGener:SetProperty( 'CJT_ISCCOP' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_ISCCOP',oModel) })
	oStruGener:SetProperty( 'CJT_BLOCOI' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_BLOCOI',oModel) })
	oStruGener:SetProperty( 'CJT_ITPCUM' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_ITPCUM',oModel) })
	oStruGener:SetProperty( 'CJT_ENVPOS' , MODEL_FIELD_WHEN, { ||HabCmpo('CJT_ENVPOS',oModel) })
	oStruGener:SetProperty( 'CJT_EMAIL'  , MODEL_FIELD_VALID, {||( VldEmail(oModel) )})
	
	SetObrigat(oStruGener,oModel)

	oFdFoldCJU:Destroy()
	FreeObj(oFdFoldCJU)

Return oModel

/*/{Protheus.doc} ViewDef
	(Função padrão ViewDef do MVC)
	@type  Static Function
	@author Matheus Massarotto
	@since 22/03/2024
	@version version 12.1.2310
	@param N/A
	@return oView, Objeto, objeto view do MVC
	@example
	(examples)
	@see ()
/*/
Static Function ViewDef()
	Local	oModel 		:= 	FWLoadModel('FISA316') as object
	Local	oStruGener 	as object
	Local	oStruApur 	as object
	Local	oStruArq 	as object
	Local 	oStruItem	as object
	Local	oView 		:= 	FWFormView():New()	as object 
	Local 	oFildFold	as object
	Local 	aFolders	as array
	Local 	oFields		as object	
	Local	nFldGeral	:= 1 as numeric
	Local	nFldApur	:= 2 as numeric
	Local	nFldArq		:= 3 as numeric
	Local	nFldCont	:= 4 as numeric
	Local	nFldGuia	:= 5 as numeric

	oFildFold 	:= totvs.protheus.backoffice.fiscal.fisa001.utils.FieldForFolder():new("CJT")
	aFolders 	:= oFildFold:getFolders()

	if len(aFolders)==5
		oFields	:= oFildFold:getFieldsToJson()

		oView:SetModel(oModel)
		oStruGener	:= 	FWFormStruct(2,"CJT", { |x| ALLTRIM(x)+"," $ oFields[cvaltochar(nFldGeral)] })	//Geral
		oStruApur	:= 	FWFormStruct(2,"CJT", { |x| ALLTRIM(x)+"," $ oFields[cvaltochar(nFldApur)]+ oFields[cvaltochar(nFldGuia)] })	//Apuração + Guia de Pagamento
		oStruArq	:= 	FWFormStruct(2,"CJT", { |x| ALLTRIM(x)+"," $ oFields[cvaltochar(nFldArq)] + oFields[cvaltochar(nFldCont)] })	//Arquivo + Contabilista
		oStruItem	:= 	FWFormStruct(2,"CJU")

		//Adiciona campos adicionais
		AddCampos(oStruItem,"VIEW")

		oStruApur:AddGroup( 'GRUPO01', STR0003	, '', 2 )//"Parâmetros de geração"
		oStruApur:AddGroup( 'GRUPO02', STR0004  , '', 2 )//"Dados do título a pagar"
		oStruArq:AddGroup( 'GRUPO03' , STR0003	, '', 2 )//"Parâmetros de geração"
		oStruArq:AddGroup( 'GRUPO04' , STR0005	, '', 2 )//"Dados do contabilista"

		//Setando os grupos dos campos
		SetOCamp(@oStruApur,oFildFold,nFldApur,MVC_VIEW_GROUP_NUMBER,'GRUPO01')
		SetOCamp(@oStruApur,oFildFold,nFldGuia,MVC_VIEW_GROUP_NUMBER,'GRUPO02')
		SetOCamp(@oStruArq ,oFildFold,nFldArq ,MVC_VIEW_GROUP_NUMBER,'GRUPO03')
		SetOCamp(@oStruArq ,oFildFold,nFldCont,MVC_VIEW_GROUP_NUMBER,'GRUPO04')

		//Setando descrições dos campos

		SetOCamp(@oStruGener,oFildFold,nFldGeral,MVC_VIEW_TITULO , MVC_VIEW_DESCR, "X3_DESCRI")
		SetOCamp(@oStruApur ,oFildFold,nFldApur ,MVC_VIEW_TITULO , MVC_VIEW_DESCR, "X3_DESCRI")
		SetOCamp(@oStruApur ,oFildFold,nFldGuia ,MVC_VIEW_TITULO , MVC_VIEW_DESCR, "X3_DESCRI")
		SetOCamp(@oStruArq  ,oFildFold,nFldArq  ,MVC_VIEW_TITULO , MVC_VIEW_DESCR, "X3_DESCRI")
		SetOCamp(@oStruArq  ,oFildFold,nFldCont ,MVC_VIEW_TITULO , MVC_VIEW_DESCR, "X3_DESCRI")

		//Remove os campos
		oStruItem:RemoveField(cIDCJU)
		oStruGener:RemoveField(cIDCJT)

		//Desabilita os folders padrões
		oStruGener:SetNoFolder()
		oStruApur:SetNoFolder()
		oStruArq:SetNoFolder()

		oView:AddField( 'VIEW_GEN'  , oStruGener, 'FISA316CAB' )
		oView:AddField( 'VIEW_APUR' , oStruApur , 'FISA316CAB' )
		oView:AddField( 'VIEW_ARQ'  , oStruArq  , 'FISA316CAB' )

		oView:AddGrid(  'VIEW_ITEM' , oStruItem , 'FISA316ITEM')

		oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
		oView:CreateHorizontalBox( 'MEIO'  , 50 )
		oView:CreateHorizontalBox( 'INFERIOR'  , 30 )

		//Cria o Folder Principal
		oView:CreateFolder( 'Folder_CJT', 'MEIO' )

		//Cria as Abas Principais do folder central
		oView:AddSheet( 'Folder_CJT', 'ABA_APUR', "Apuração" ) //"Apuração"
		oView:AddSheet( 'Folder_CJT', 'ABA_ARQ'	, "Arquivo" ) //"Arquivo"

		//Cria box da aba de Principais
		oView:CreateHorizontalBox( 'PAINEL_APUR'  , 100,,, 'Folder_CJT', 'ABA_APUR'     )
		oView:CreateHorizontalBox( 'PAINEL_ARQ'   , 100,,, 'Folder_CJT', 'ABA_ARQ'      )

		//Faz vínculo do box com a view
		oView:SetOwnerView( 'VIEW_GEN'  , 'SUPERIOR'    )
		oView:SetOwnerView( 'VIEW_APUR' , 'PAINEL_APUR' )
		oView:SetOwnerView( 'VIEW_ARQ'  , 'PAINEL_ARQ'  )
		oView:SetOwnerView( 'VIEW_ITEM' , 'INFERIOR'    )

		//Colocando título do formulário
		oView:EnableTitleView('VIEW_GEN'  , STR0006 ) //"Dados gerais para apuração e arquivo"
		oView:EnableTitleView('VIEW_APUR' , STR0007 ) //"Dados somente da apuração"
		oView:EnableTitleView('VIEW_ARQ'  , STR0008 ) //"Dados somente do arquivo"

		oView:SetViewProperty("VIEW_ITEM","GRIDFILTER",{.T.})//habilita filtro
		oView:SetViewProperty("VIEW_ITEM","GRIDSEEK",{.T.})//habilita pesquisa

		oView:SetFieldAction('CJT_TPPROC' , {|oView| AtuAba(oView,oModel) })
		oStruArq:SetProperty( 'CJT_DIR'   , MVC_VIEW_LOOKUP, { ||"DIRFIS" })

		oView:SetAfterViewActivate({|oView| MudaCaptio(oView),AtuAba(oView,oModel)}) // Pós ativação da view

	else
		oView:SetModel(oModel)
		oStruGener	:= 	FWFormStruct(2,"CJT")
		oView:AddField( 'VIEW_GEN'  , oStruGener, 'FISA316CAB' )

		oStruItem	:= 	FWFormStruct(2,"CJU")
		//Adiciona campos adicionais
		AddCampos(oStruItem,"VIEW")
		oView:AddGrid(  'VIEW_ITEM' , oStruItem , 'FISA316ITEM')

		oStruItem:RemoveField(cIDCJU)
		oStruGener:RemoveField(cIDCJT)

		oView:CreateHorizontalBox( 'SUPERIOR'  , 70 )
		oView:CreateHorizontalBox( 'INFERIOR'  , 30 )

		oView:SetOwnerView( 'VIEW_GEN'  , 'SUPERIOR'    )
		oView:SetOwnerView( 'VIEW_ITEM' , 'INFERIOR'    )

		oView:SetViewProperty("VIEW_ITEM","GRIDFILTER",{.T.})//habilita filtro
		oView:SetViewProperty("VIEW_ITEM","GRIDSEEK",{.T.})//habilita pesquisa
		
		oStruGener:SetProperty( 'CJT_DIR'   , MVC_VIEW_LOOKUP, { ||"DIRFIS" })

	endif

	oFildFold:Destroy()
	FreeObj(oFildFold)
	FreeObj(oFields)
	FwFreeArray(aFolders)

Return oView

/*/{Protheus.doc} SetOCamp
	(Funcao para setar propriedades em campos enviados por parâmetro)
	@type Static Function
	@author Matheus Massarotto
	@since 28/03/2024
	@version version 12.1.2410
	@param oStru, object, Objeto de estrutura da view ou model
	@param oFildFold, object, Objeto com estrutura de campos e pastas de uma tabela
	@param nFolder, numeric, número da pasta
	@param nOpcMVC, numeric, opção do MVC que representa onde que será alterado
	@param xConfigura, numeric, Conteúdo que será setado
	@param cCmpVl, character,Identificador de onde será a validação, incluído para tratar especificidades 
	@return Nil, Nil, N/A
	@example
	(examples)
	@see ()
/*/
Static Function SetOCamp(oStru,oFildFold,nFolder,nOpcMVC,xConfigura, cCmpVl)
Local aCamps	:= oFildFold:getFieldsToArray()[nFolder] as array
Local nI		:= 1 									 as numeric
Local nLenCamps	:= len(aCamps) 							 as numeric

Default cCmpVl := ""

	If cCmpVl == "X3_DESCRI"
		for nI:=1 to nLenCamps
				oStru:SetProperty(aCamps[nI],nOpcMVC, oStru:GetProperty(aCamps[nI], xConfigura ) )
		next
	Else
		for nI:=1 to nLenCamps
				oStru:SetProperty(aCamps[nI],nOpcMVC,xConfigura )
		next
	Endif
	FwFreeArray(aCamps)
Return

/*/{Protheus.doc} AddCampos
	(Funcao para adicionar campos a uma estrutura)
	@type  Static Function
	@author Matheus Massarotto
	@since 02/04/2024
	@version version 12.1.2410
	@param oStru, object, Objeto que recebe os campos
	@param cModVie, character, flag de indicação onde o campos será adicionado, 
			MODEL para modelo 
			VIEW para setar o campo na view
	@return Nil, Nil, N/A
	@example
	(examples)
	@see ()
/*/
Static Function AddCampos(oStru,cModVie)

	if cModVie=="MODEL"
		oStru:AddField( ;                      // Ord. Tipo Desc.
						STR0014               			 , ;      // [01]  C   Titulo do campo //Marca
						STR0015  						 , ;      // [02]  C   ToolTip do campo //Campo de Marcação
						'CJU_XMARCA'                     , ;      // [03]  C   Id do Field
						'L'                              , ;      // [04]  C   Tipo do campo
						1                                , ;      // [05]  N   Tamanho do campo
						0                                , ;      // [06]  N   Decimal do campo
						NIL                              , ;      // [07]  B   Code-block de valida  o do campo
						NIL                              , ;      // [08]  B   Code-block de valida  o When do campo
						NIL                              , ;      // [09]  A   Lista de valores permitido do campo
						NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigat rio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,'.F.' )         , ;      // [11]  B   Code-block de inicializacao do campo
						NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
						NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma opera  o de update.
						.T.                              )        // [14]  L   Indica se o campo   virtual

		oStru:AddField( ;                    // Ord. Tipo Desc.
						STR0016      				                                , ;      // [01]  C   Titulo do campo //"Descrição"
						STR0016                  		  				            , ;      // [02]  C   ToolTip do campo //"Descrição "
						"CJU_DESCRI"                                                , ;      // [03]  C   Id do Field
						'C'                                                         , ;      // [04]  C   Tipo do campo
						50										                    , ;      // [05]  N   Tamanho do campo
						0                                                           , ;      // [06]  N   Decimal do campo
						NIL                                                         , ;      // [07]  B   Code-block de validação do campo
						NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
						NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
						NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
						&( '  ' )    , ;      // [11]  B   Code-block de inicializacao do campo
						NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
						NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                                         )        // [14]  L   Indica se o campo é virtual

		oStru:AddField( ;                    // Ord. Tipo Desc.
						STR0017			                                      		, ;      // [01]  C   Titulo do campo //"CNPJ"
						STR0017         		         		            		, ;      // [02]  C   ToolTip do campo //"CNPJ"
						"CJU_CNPJ"                                                	, ;      // [03]  C   Id do Field
						'C'                                                         , ;      // [04]  C   Tipo do campo
						14										                    , ;      // [05]  N   Tamanho do campo
						0                                                           , ;      // [06]  N   Decimal do campo
						NIL                                                         , ;      // [07]  B   Code-block de validação do campo
						NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
						NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
						NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
						&( '  ' )    , ;      // [11]  B   Code-block de inicializacao do campo
						NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
						NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                                         )        // [14]  L   Indica se o campo é virtual

	elseif cModVie=="VIEW"

		oStru:AddField( ;                        // Ord. Tipo Desc.
						'CJU_XMARCA'                       , ;      // [01]  C   Nome do Campo
						'01'                               , ;      // [02]  C   Ordem
						STR0014  				           , ;      // [03]  C   Titulo do campo
						STR0015          				   , ;      // [04]  C   Descricao do campo
						{ STR0015   }          			   , ;      // [05]  A   Array com Help
						'L'                                , ;      // [06]  C   Tipo do campo
						'@!'                               , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						NIL                                , ;      // [09]  C   Consulta F3
						.T.                                , ;      // [10]  L   Indica se o campo   alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior op  o do combo
						NIL                                , ;      // [15]  C   Inicializador de Browse
						.T.                                , ;      // [16]  L   Indica se o campo   virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha ap s o campo

		oStru:AddField( ;                        // Ord. Tipo Desc.
						'CJU_DESCRI'                       , ;      // [01]  C   Nome do Campo
						'06'                               , ;      // [02]  C   Ordem
						STR0016     					   , ;      // [03]  C   Titulo do campo //Descrição
						STR0016     					   , ;      // [04]  C   Descricao do campo //Descrição
						{ STR0016   }         			   , ;      // [05]  A   Array com Help //Descrição
						'C'                                , ;      // [06]  C   Tipo do campo
						'@!'                               , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						NIL                                , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo   alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior op  o do combo
						NIL                                , ;      // [15]  C   Inicializador de Browse
						.T.                                , ;      // [16]  L   Indica se o campo   virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha ap s o campo

		oStru:AddField( ;                        // Ord. Tipo Desc.
						'CJU_CNPJ'                         , ;      // [01]  C   Nome do Campo
						'07'                               , ;      // [02]  C   Ordem
						STR0017           				   , ;      // [03]  C   Titulo do campo //CNPJ
						STR0017           				   , ;      // [04]  C   Descricao do campo //CNPJ
						{ STR0017   }         			   , ;      // [05]  A   Array com Help //CNPJ
						'C'                                , ;      // [06]  C   Tipo do campo
						'@R! NN.NNN.NNN/NNNN-99'           , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						NIL                                , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo   alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior op  o do combo
						NIL                                , ;      // [15]  C   Inicializador de Browse
						.T.                                , ;      // [16]  L   Indica se o campo   virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha ap s o campo

	endif

Return

/*/{Protheus.doc} f316LdGrid
	(Função para carga da grid de filiais)
	@type  Static Function
	@author Matheus Massarotto
	@since 02/04/2024
	@version version 12.1.2310
	@param oGridModel, object, objeto da grid do model
	@param lCopy, logical, indica se é um ato de cópia
	@param oModel, object, objeto modelo do MVC
	@return aLoad, array, array com os itens da grid
	@example
	(examples)
	@see (https://tdn.totvs.com/display/public/framework/MPFormModel)
/*/
Static Function f316LdGrid(oGridModel, lCopy,oModel)
Local nX 			:= 0									as numeric
Local aLoad 		:= {}									as array
Local nOperation 	:= oGridModel:GetOperation() 			as numeric
Local aFil			:= MatFilCalc( .F. ) 					as array
Local cCodReg												as character
Local oJson													as object
Local lMark			:= .F.									as logical
Local lContrl		:= .F.									as logical
Local cFilGrid		:= xFilial("CJU")						as character
Local nLin 			:= 0 									as numeric
Local lInclusao		:= nOperation==MODEL_OPERATION_INSERT 	as logical

if !lInclusao
	cCodReg:= oModel:GetValue('FISA316CAB',cIDCJT)
	if !empty(cCodReg)
		oJson:=JsonCJU(cCodReg)
		lContrl:=.T.
	endif
endif
/*
aFil[nX][2] .T. OU .F.
aFil[nX][2] FILIAL
aFil[nX][3] DESCRIÇÃO
aFil[nX][4] CNPJ
*/
for nX:=1 to len(aFil)
	if lContrl .and. oJson:HasProperty(aFil[nX][2])
		lMark	:=.T.
		nLin	:=oJson[aFil[nX][2]]
	else
		nLin	:= 0
		
		if lInclusao .and. aFil[nX][2]==cFilAnt
			lMark	:=.T.
		endif
	endif
	aAdd( aLoad, { nLin,  {cFilGrid 		,"ID"+cvaltochar(nX),cEmpAnt,aFil[nX][2],lMark,aFil[nX][3],aFil[nX][4]} } )
	//						filial			id				empresa		filial,marcação,descrição,cnpj
	lMark:=.F.
next

Return( aLoad )

/*/{Protheus.doc} QueryCJU
	(Função que faz a consulta na tabela CJU, com uma query)
	@type  Static Function
	@author Matheus Massarotto
	@since 03/04/2024
	@version version 12.1.2410
	@param cId, character, Chave de busca da CJU
	@return cAlias, character, alias da query CJU
	@example
	(examples)
	@see (https://tdn.totvs.com/display/public/framework/FWExecStatement)
/*/
Static Function QueryCJU(cId)
Local cQuery 	:=""	as character
Local cAlias 	:=""	as character

cQuery := " SELECT CJU_FILSEL, R_E_C_N_O_ FROM "+RetSqlName('CJU') 
cQuery += " WHERE CJU_FILIAL = ? AND CJU_ID = ? AND CJU_EMPSEL = ? AND D_E_L_E_T_ = ? "

if !cQryMD5CJU == MD5(cQuery)
	cQuery := ChangeQuery(cQuery)
	cQryMD5CJU	:= MD5(cQuery)
	
	oExecCJU := FwExecStatement():New(cQuery)
endif
 
oExecCJU:SetString(1, xFilial("CJU"))
oExecCJU:SetString(2, cId)
oExecCJU:SetString(3, cEmpAnt)
oExecCJU:SetString(4, ' ')
 
cAlias:= oExecCJU:OpenAlias()

Return(cAlias)

/*/{Protheus.doc} JsonCJU
	(Função que alimenta Json com dados retornados da query)
	@type Static Function
	@author Matheus Massarotto
	@since 03/04/2024
	@version version 12.1.2310
	@param cId, character, Chave de busca da CJU
	@return oJson, object, json com a filial como chave e o recno como conteudo
	@example
	(examples)
	@see ()
/*/
Static Function JsonCJU(cId)
Local oJson		:= JsonObject():New() as object
Local cAlias						  as character 

cAlias:= QueryCJU(cId)

While (cAlias)->(!Eof())
	oJson[(cAlias)->CJU_FILSEL]:=(cAlias)->R_E_C_N_O_
	(cAlias)->(DbSkip())
Enddo

(cAlias)->(DBCloseArea())

Return(oJson)

/*/{Protheus.doc} f316Commit
	(Gravação do modelo de dados)
	@type  Static Function
	@author Matheus Massarotto
	@since 10/04/2024
	@version version 12.1.2310
	@param oModel, object, Modelo de dados
	@return lRet, logical, retona .T. se fez o commit e .F. caso não
	@example
	(examples)
	@see ()
/*/
Static Function f316Commit(oModel)

Local lRet		:= .T. 			  			as logical
Local oMdlGrid		   			  			as object
Local cFilCJU	:= xFilial("CJU") 			as character
Local nCount					  			as numeric
Local cCodReg 					  			as character
Local aAreaCJU	:= CJU->(GetArea()) 		as array
Local oJson									as object
Local aRegs		:= {}						as array
Local nLen		:= 0 						as numeric
Local lModify	:= .F.						as logical
Local nOpc 		:= oModel:GetOperation() 	as numeric
Local cEmpSel	:=""						as character
Local cFilSel	:=""						as character
Local nMdlLen								as numeric			

oMdlGrid	:= oModel:GetModel("FISA316ITEM")
cCodReg		:= oModel:GetValue('FISA316CAB',cIDCJT)
cEmpSel		:= oMdlGrid:GetValue("CJU_EMPSEL")
nMdlLen		:= oMdlGrid:Length()

oMdlGrid:SetNoDeleteLine(.F.) //Seto para permitir deletar linhas da grid
lModify		:=oMdlGrid:IsModified()

CJU->(DbSetOrder(1))

If nOpc == MODEL_OPERATION_INSERT

		For nCount := 1 To nMdlLen
			oMdlGrid:GoLine(nCount)

			If oMdlGrid:GetValue("CJU_XMARCA")
				cFilSel		:= oMdlGrid:GetValue("CJU_FILSEL")
			
				LoadCJU(@oModel,cFilCJU,cCodReg,cEmpSel,cFilSel)

			Else

				oMdlGrid:DeleteLine()

			EndIf

		Next nCount


Elseif nOpc == MODEL_OPERATION_UPDATE

	oJson:=JsonCJU(cCodReg) //Busco as informações salvas no banco de dados
	
		For nCount := 1 To nMdlLen
			oMdlGrid:GoLine(nCount)
			cFilSel		:= oMdlGrid:GetValue("CJU_FILSEL")			
			
			If oMdlGrid:GetValue("CJU_XMARCA") //Se estiver marcado na tela
				
				If !oJson:HasProperty(cFilSel) //Se não existir no banco de dados
					LoadCJU(@oModel,cFilCJU,cCodReg,cEmpSel,cFilSel)
				EndIf

			Else //Se não estiver marcado na tela

				oMdlGrid:DeleteLine() //Deleto virtualmente

				If oJson:HasProperty(cFilSel) //Se existir no banco de dados
					DelCJU(cFilCJU,cCodReg,cEmpSel,cFilSel)
				EndIf

			EndIf

		Next nCount

Elseif nOpc == MODEL_OPERATION_DELETE
	oJson:=JsonCJU(cCodReg) //Busco as informações salvas no banco de dados

	aRegs := oJson:GetNames()
	nLen  := len(aRegs)
	for nCount := 1 to nLen
		DelCJU(cFilCJU,cCodReg,cEmpSel,aRegs[nCount])
	next nCount
EndIf

lRet := FwFormCommit(oModel) //Salva o modelo

oMdlGrid:SetNoDeleteLine(.T.) //Seto para NÃO permitir deletar linhas da grid

RestArea(aAreaCJU)
ASize(aRegs,0)
FreeObj(oJson)
FwFreeArray(aAreaCJU)

Return lRet

/*/{Protheus.doc} LoadCJU
	(Função para dar load nos campos da CJU)
	@type  Static Function
	@author Matheus Massarotto
	@since 10/04/2024
	@version 12.1.2310
	@param oMdlGrid, object, Objeto da grid do model
	@param cFilCJU, character, Código da Filial (xFilial)
	@param cCodReg, character, Id do registro
	@param cEmpSel, character, Código da Empresa selecionada
	@param cFilSel, character, Código da Filial selecionada
	@return Nil, Nil, N/A
	@example
	(examples)
	@see (https://tdn.totvs.com/display/public/framework/FWFormGridModel)
/*/
Static Function LoadCJU(oMdlGrid,cFilCJU,cCodReg,cEmpSel,cFilSel)
	oMdlGrid:LoadValue( 'FISA316ITEM',"CJU_FILIAL"  , cFilCJU   )
	oMdlGrid:LoadValue( 'FISA316ITEM',"CJU_ID"      , cCodReg   )
	oMdlGrid:LoadValue( 'FISA316ITEM',"CJU_EMPSEL"  , cEmpSel   )
	oMdlGrid:LoadValue( 'FISA316ITEM',"CJU_FILSEL"  , cFilSel   )
Return 

/*/{Protheus.doc} DelCJU
	(Função para deletar fisicamente registros da tabela CJU)
	@type  Static Function
	@author Matheus Massarotto
	@since 10/04/2024
	@version version 12.1.2410
	@param cFilCJU, character, Código da Filial (xFilial)
	@param cCodReg, character, Id do registro
	@param cEmpSel, character, Código da Empresa selecionada
	@param cFilSel, character, Código da Filial selecionada
	@return Nil, Nil, N/A
	@example
	(examples)
	@see (https://tdn.totvs.com/display/tec/DBDelete)
/*/
Static Function DelCJU(cFilCJU,cCodReg,cEmpSel,cFilSel)
	if CJU->(MsSeek(cFilCJU+cCodReg+cEmpSel+cFilSel)) //CJU_FILIAL+CJU_ID+CJU_EMPSEL+CJU_FILSEL
		RecLock('CJU',.F.)
			CJU->(DbDelete()) //Deleto fisicamente
		CJU->(MsUnlock())
	endif
Return

/*/{Protheus.doc} ValidForm
	(Validação das informações digitadas no form)
	@type  Static Function
	@author Matheus Massarotto
	@since 12/04/2024
	@version version 12.1.2310
	@param oModel, object, objeto do model
	@return lRet, logical, retorna .T. se tem pelo menos um item marcado na grid
	@example
	(examples)
	@see (https://tdn.totvs.com/display/tec/DBDelete)
/*/
Static Function ValidForm(oModel)

Local lRet		:= .F.	as logical
Local nCount	:= 1	as numeric
Local oMdlGrid			as object
Local nMdlLen			as numeric

oMdlGrid	:= oModel:GetModel("FISA316ITEM")
nMdlLen		:= oMdlGrid:Length()

	For nCount := 1 To nMdlLen
		oMdlGrid:GoLine(nCount)

		If oMdlGrid:GetValue("CJU_XMARCA")
			lRet:=.T.
			exit
		EndIf

	Next nCount

	if !lRet
		Help(" ",1,"Help","Help",STR0009,1,0)//É preciso informar pelo menos uma filial
	endif

Return lRet

/*/{Protheus.doc} VldCodigo
	Função Estatica que valida se o código inserido já exista na base de dados,
	também valida o uso de alguns caracteres especiais ou espaço em branco.
	@type  Static Function
	@author Alexandre Esteves
	@since 08/04/2024
	@version 12.1.2410
	@param oModel, Object, carrega o modelo de dados do MVC
	@return lret, logical, True or False
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VldCodigo(oModel)

Local cCodigo   := oModel:GetValue ('FISA316CAB', "CJT_CODREG") as character
Local lRet		:= .T.											as logical

//Verifico se existe o registro
If !empty(QueryCJT(cCodigo))
	Help( ,, 'Help',, STR0010, 1, 0 )
	lRet:=.F.
EndIF

If !ValidRegex(cCodigo) //Regex para só permitir letras e numeros
	Help( ,, 'Help',, STR0011, 1, 0 ) //"Código não pode conter os caracteres especiais."
	lRet:=.F.
EndIf

Return lRet

/*/{Protheus.doc} HabCmpo
	Função Estatica que vai determinar quais campos ficarão ativos na tela dependendo da;
	regra de negocio mapeada no modelo de dados. Algumas hierarquias deverão ser respeitadas.
	@type  Static Function
	@author Alexandre Esteves
	@since 08/04/2024
	@version 12.1.2410
	@param oModel, Object, carrega o modelo de dados do MVC
	@param cCampo, String, carrega o campo que precisa ser validado
	@return lret, logical, True or False
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function HabCmpo(cCampo,oModel)

Local lRet		:= .F.												as logical
Local cTpPer	:= oModel:GetValue ('FISA316CAB', "CJT_TPPER") 		as character
Local cTpProc	:= oModel:GetValue ('FISA316CAB', "CJT_TPPROC") 	as character
Local cGerTit	:= oModel:GetValue ('FISA316CAB', "CJT_GERTIT")		as character
Local cRegime	:= oModel:GetValue ('FISA316CAB', "CJT_REGIME")		as character
Local cTpEscr	:= oModel:GetValue ('FISA316CAB', "CJT_TPESCR")		as character
Local cSocCop	:= oModel:GetValue ('FISA316CAB', "CJT_SOCCOP")		as character
Local cInsFin	:= oModel:GetValue ('FISA316CAB', "CJT_INSFIN")		as character

Do Case   		
	Case cCampo $ "CJT_FDTINI/CJT_FDTFIM"
		IF cTpPer == "4" // Formula
			lRet := .T.
		EndIF	
	Case cCampo $ "CJT_DETRCX"
		IF cRegime == "3" 
			lRet := .T.
		EndIF	
	Case cCampo $ "CJT_IREGCM"
		If cRegime <> "1"
			lRet := .T.
		Endif
	Case cCampo $ "CJT_DIAVCT/CJT_TPVCTO/CJT_MESSUB/CJT_ANTPOS/CJT_CRPISC/CJT_CRCOFC/CJT_CRPSNC/CJT_CRCFNC/CJT_CRCPRB"
		If cGerTit <> "2"
			lRet := .T.
		Endif
	Case cCampo $ "CJT_ITPCUM"
		If cTpEscr <> "1"
			lRet := .T.
		Endif
	Case cCampo $ "CJT_ISCCOP"
		If cSocCop == "1" .or. cTpProc == "2" 
			lRet := .T.
		Endif
	Case cCampo $ "CJT_BLOCOI"
		If cInsFin == "1" .or. cTpProc == "2" 
			lRet := .T.
		Endif
EndCase 

Return lRet

/*/{Protheus.doc} TpPerFor
	Função que habilita os campos de fórmula inicial e final como obrigatórios
	@type  Static Function
	@author Matheus Massarotto
	@since 16/05/2024
	@version 12.1.2410
	@param oModel, Object, carrega o modelo de dados do MVC
	@param oStruGener, Object, estrutua de dados genérico do modelo 
	@return lRet, Retorna .T. para validação ok ou .F. para validação inconsistente
	@example
	(examples)
	@see (https://tdn.totvs.com/display/public/framework/FWFormView)
/*/
Static Function TpPerFor(oModel,oStruGener)
Local cTpPer		:= oModel:GetValue ('FISA316CAB', "CJT_TPPER") 		as character
Local lRet			:= .T.												as logical
Local oViewAux    														as object
Local oReferencia														as object
Local cPadraoOb															as character

If IsBlind()
	Return lRet
EndIf

oViewAux   	:= FWViewActive()
oReferencia	:= oViewAux:GetViewObj("VIEW_GEN")[3] //pega o padrão de um campo obrigatório

cPadraoOb:=StrTran( oReferencia:GetFWEditCTRL("CJT_CODREG"):CTITLE, oReferencia:GetFWEditCTRL("CJT_CODREG"):OCTRL:CTOOLTIP, "???") //texto padrão sem o título do campo

if cTpPer == "4" // Formula
	oStruGener:SetProperty( 'CJT_FDTINI'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_FDTFIM'   	, MODEL_FIELD_OBRIGAT,  .T. ) 

	oReferencia:GetFWEditCTRL("CJT_FDTINI"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_FDTINI"):OCTRL:CTOOLTIP)
	oReferencia:GetFWEditCTRL("CJT_FDTFIM"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_FDTFIM"):OCTRL:CTOOLTIP)
else
	oStruGener:SetProperty( 'CJT_FDTINI'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_FDTFIM'   	, MODEL_FIELD_OBRIGAT,  .F. ) 

	oReferencia:GetFWEditCTRL("CJT_FDTINI"):OCTRL:CCAPTION	:= oReferencia:GetFWEditCTRL("CJT_FDTINI"):OCTRL:CTOOLTIP
	oReferencia:GetFWEditCTRL("CJT_FDTFIM"):OCTRL:CCAPTION	:= oReferencia:GetFWEditCTRL("CJT_FDTFIM"):OCTRL:CTOOLTIP
endif

Return lRet

/*/{Protheus.doc} AtuAba
	Função Estatica que vai atualizar as informações das abas
	@type  Static Function
	@author Alexandre Esteves
	@since 09/04/2024
	@version 12.1.2410
	@param oView, Object, carrega a view do MVC
	@param oModel, Object, carrega o modelo de dados do MVC
	@return Nil, Nil, Nenhum retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AtuAba(oView,oModel)

Local cTpProc	:= oModel:GetValue ('FISA316CAB', "CJT_TPPROC")	as character

If cTpProc == "1"
	oView:HideFolder("Folder_CJT","Arquivo",2)
	oView:SelectFolder("Folder_CJT","Apuração",2)
Elseif cTpProc == "2"
	oView:HideFolder("Folder_CJT","Apuração",2)
	oView:SelectFolder("Folder_CJT","Arquivo",2)
Else
	oView:SelectFolder("Folder_CJT","Apuração",2)
	oView:SelectFolder("Folder_CJT","Arquivo",2)
Endif

//Atualizo a view
oView:Refresh( 'VIEW_GEN')
oView:Refresh( 'VIEW_APUR')
oView:Refresh( 'VIEW_ARQ')

Return

/*/{Protheus.doc} SetObrigat
	Função Estatica que vai definir a obrigatoriedade dos campos de acordo com o tipo de procesamento
	@type  Static Function
	@author Alexandre Esteves
	@since 10/04/2024
	@version 12.1.2410
	@param oStruGener, Object, carrega a estrutura de campos da tabela CJT no MVC
	@param oModel, Object, carrega o modelo de dados do MVC
	@return Nil, Nil, Nenhum retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetObrigat(oStruGener,oModel)

Local lRet 		:= .T. 	as logical
Local cTpProc			as character 

if oModel:IsActive()
	cTpProc:= oModel:GetValue ('FISA316CAB', "CJT_TPPROC")
else
	cTpProc:= "3"
endif

If cTpProc == "1"

	oStruGener:SetProperty( 'CJT_TRIBUT'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_REGIME'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_GERTIT'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_INATPJ'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_DIR'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_ARQ'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_TPESCR'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_INDNAT'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_ATIVIP'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_NOME'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_CRC'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_CEP'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_CODMUN'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_END'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_BAIRRO'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_TEL'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_EMAIL'   	, MODEL_FIELD_OBRIGAT,  .F. )

Elseif cTpProc == "2"

	oStruGener:SetProperty( 'CJT_TRIBUT'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_REGIME'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_GERTIT'   	, MODEL_FIELD_OBRIGAT,  .F. ) 
	oStruGener:SetProperty( 'CJT_INATPJ'   	, MODEL_FIELD_OBRIGAT,  .F. )
	oStruGener:SetProperty( 'CJT_DIR'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_ARQ'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_TPESCR'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_INDNAT'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_ATIVIP'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_NOME'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_CRC'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_CEP'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_CODMUN'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_END'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_BAIRRO'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_TEL'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_EMAIL'   	, MODEL_FIELD_OBRIGAT,  .T. )

Elseif cTpProc == "3"

	oStruGener:SetProperty( 'CJT_TRIBUT'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_REGIME'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_GERTIT'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_INATPJ'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_DIR'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_ARQ'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_TPESCR'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_INDNAT'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_ATIVIP'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_NOME'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_CRC'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_CEP'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_CODMUN'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_END'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_BAIRRO'   	, MODEL_FIELD_OBRIGAT,  .T. ) 
	oStruGener:SetProperty( 'CJT_TEL'   	, MODEL_FIELD_OBRIGAT,  .T. )
	oStruGener:SetProperty( 'CJT_EMAIL'   	, MODEL_FIELD_OBRIGAT,  .T. )
Else
	lRet:=.F.
Endif

Return lRet

/*/{Protheus.doc} MudaCaptio
	Função para adicionar o negrito e o asterisco nos campos que serão alterados como obrigatórios dentro do MVC
	@type  Static Function
	@author Matheus Massarotto
	@since 09/05/2024
	@version 12.1.2410
	@param oView, object, objeto da view
	@return Nil, Nil, Nenhum retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MudaCaptio(oView)
Local oViewAux    	:= FWViewActive()	as object
Local oReferencia						as object
Local cPadraoOb							as character


oReferencia:= oViewAux:GetViewObj("VIEW_GEN")[3]:GetFWEditCTRL("CJT_CODREG") //pega o padrão de um campo obrigatório
cPadraoOb:=StrTran( oReferencia:CTITLE, oReferencia:OCTRL:CTOOLTIP, "???") //texto padrão sem o título do campo

oReferencia:= oViewAux:GetViewObj("VIEW_APUR")[3]
oReferencia:GetFWEditCTRL("CJT_TRIBUT"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_TRIBUT"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_REGIME"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_REGIME"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_GERTIT"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_GERTIT"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_INATPJ"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_INATPJ"):OCTRL:CTOOLTIP)

oReferencia:= oViewAux:GetViewObj("VIEW_ARQ")[3]
oReferencia:GetFWEditCTRL("CJT_DIR"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_DIR"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_ARQ"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_ARQ"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_TPESCR"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_TPESCR"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_INDNAT"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_INDNAT"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_ATIVIP"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_ATIVIP"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_NOME"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_NOME"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_CRC"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_CRC"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_CEP"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_CEP"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_CODMUN"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_CODMUN"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_END"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_END"):OCTRL:CTOOLTIP)	
oReferencia:GetFWEditCTRL("CJT_BAIRRO"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_BAIRRO"):OCTRL:CTOOLTIP)
oReferencia:GetFWEditCTRL("CJT_TEL"):OCTRL:CCAPTION		:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_TEL"):OCTRL:CTOOLTIP)	
oReferencia:GetFWEditCTRL("CJT_EMAIL"):OCTRL:CCAPTION	:= StrTran( cPadraoOb, "???" , oReferencia:GetFWEditCTRL("CJT_EMAIL"):OCTRL:CTOOLTIP)

Return

/*/{Protheus.doc} VldEmail
	Função Estatica que valida se o Email inserido tem o formato valido,
	@type  Static Function
	@author Alexandre Esteves
	@since 10/04/2024
	@version 12.1.2410
	@param oModel, Object, carrega o modelo de dados do MVC
	@return lret, logical, True or False
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VldEmail(oModel)

	Local cEmail     	:= oModel:GetValue ('FISA316CAB', "CJT_EMAIL") as character
	Local lRet          := .T.										   as logical

	If !IsEMail(cEmail)
		Help( ,, 'Help',, STR0013, 1, 0 ) //"E-mail digitado no formato inválido"
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} QueryCJT
	(Função para buscar registros da CJT de acordo com o ID)
	@type  Static Function
	@author Matheus Massarotto
	@since 18/04/2024
	@version version 12.1.2410
	@param cCodReg, character, Código de registro da CJT
	@return cRecno, character, recno do registro encontrado
	@example
	(examples)
	@see (https://tdn.totvs.com/display/tec/DBDelete)
/*/
Static Function QueryCJT(cCodReg)
Local cQuery 	:=""	as character
Local cRecno 	:=""	as character

cQuery := " SELECT R_E_C_N_O_ REGISTRO FROM "+RetSqlName('CJT') 
cQuery += " WHERE CJT_FILIAL = ? AND CJT_CODREG = ? AND D_E_L_E_T_ = ? "

if !cQryMD5CJT == MD5(cQuery)
	cQuery 		:= ChangeQuery(cQuery)
	cQryMD5CJT	:= MD5(cQuery)
	
	oExecCJT := FwExecStatement():New(cQuery)
endif
 
oExecCJT:SetString(1, xFilial("CJT"))
oExecCJT:SetString(2, cCodReg)
oExecCJT:SetString(3, ' ')
 
cRecno:= oExecCJT:ExecScalar('REGISTRO')

Return(cRecno)

/*/{Protheus.doc} ValidRegex
	(Validação de campos através do Regex)
	@type  Static Function
	@author Matheus Massarotto
	@since 10/04/2024
	@version version 12.1.2410
	@param cConteud, character, Conteúdo que será verificado no Regex
	@return .T. ou .F., logical, retorna .T. caso o conteudo seja aprovado na regra do Regex
	@example
	(examples)
	@see (https://tdn.totvs.com/display/tec/Classe+tRegEx)
/*/
Static Function ValidRegex(cConteud)

if ValType(oRegex) <> "O"
	// Inicializa objeto com Pattern
	oRegex := totvs.protheus.backoffice.fiscal.fisa001.utils.RegexValids():new() //Regex para só permitir letras e numeros
endif

Return oRegex:VldRegex(cConteud)

/*/{Protheus.doc} EfdAgenda()
	Chama a função do Frame Call Schedule
	@type  Function
	@author Alexandre Esteves
	@since 24/04/2024
	@version 12.1.2410
	@return .T., logico 
	
/*/
Function EfdAgenda()

    callSchedule("FISA317")

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F316FORMUL
 Função para validar se o retorno do campo formula é uma data
    @type  Static Function
    @author Alexandre Esteves
    @since 10/05/2024
    @version 12.1.2410
    @param cFormula, character, Codigo da Formula cadastrada
    @return lRet, logical,Retorno logico sobre o ponto de validação das vigencias
/*/
//-------------------------------------------------------------------
Function F316FORMUL(cFormula as character) 

Local uRet    		 as undefined
Local lRet    := .F. as logical

Default cFormula := ""

SM4->( DbSetOrder( 1 ))
If SM4->( MsSeek( xFilial("SM4") + cFormula ) )
	 uRet := &(SM4->M4_FORMULA)
EndIf

If Valtype(uRet) == "D"
	lRet:= .T.
Else
	FwAlertInfo(STR0018 , STR0019)
Endif

Return lRet
