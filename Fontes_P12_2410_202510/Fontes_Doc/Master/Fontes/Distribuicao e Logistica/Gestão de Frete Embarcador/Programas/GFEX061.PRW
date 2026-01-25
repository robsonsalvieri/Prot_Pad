#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "GFEX061.CH"
 
#DEFINE CLRF CHR(13)+CHR(10)
#DEFINE STROUTRASIM "Simulação com outras transportadoras" 
 
Static aSaveFld := {}
Static cFilLog	:= cFilAnt // Filial Logada

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX061 

Comparativo de Frete

@author Jorge Matos Valcanaia, Luciano de Araujo
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------    
Function GFEX061() 
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Sair"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	Private cAliLDOC

	FWExecView("Simulação",'GFEX061', 3, , { || .T. },{|| .F.},,aButtons ) //"Comparativo de Frete"

	GFEDelTab(cAliLDOC)
	cFilAnt	:= cFilLog 

Return .T.

///------------------------------------------------------------------------------------------------    
Static Function ModelDef()

	Local oModel
	Local oStruTransp  := GetStrTrp(1)  // Struct com os campos da tela de seleção dos documentos de carga
	Local oStruTab     := GetStrTab(1)  // Struct com os dados da tabela informada
	Local oStruSimFrt  := GetStrSim(1)  // Struct com os campos do grid de valores de frete simulados com outras transportadoras
	Local oStruCompo   := GetStrComp(1) // Struct com os campos do grid de componentes da tabela informada
	Local oStruClFld   := GetCalcFld(1)
	
	oStruClFld:AddTrigger("COM__TOT03","COM__DIFER",{|| .T. },{|| FwFldGet("COM__TOT02") - FwFldGet("COM__TOT03") } )
	oStruClFld:AddTrigger("COM__DIFER","COM__PERCE",{|| .T. },{|| ((FwFldGet("COM__DIFER") / FwFldGet("COM__TOT02")) * 100) } )
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEX061", /*bPre*/,/*bPost*/, {|| GFEX61CMT()}, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEX061_01", Nil, oStruTransp, /*bPre*/,/*bPost*/,/*bLoad*/)   

	oModel:AddGrid( 'DETAIL_02', 'GFEX061_01', oStruSimFrt , /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

	oModel:AddFields("GFEX061_02", "GFEX061_01", oStruTab, /*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( 'DETAIL_03', 'GFEX061_02', oStruCompo, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

	oModel:AddFields("GFEX061CALC1", "GFEX061_01", oStruClFld, /*bPre*/,/*bPost*/,/*bLoad*/)   
	oModel:SetOnDemand()
	oModel:SetDescription( "Comparativo de Tabelas de Frete" ) //"Comparativo de Frete"
	oModel:GetModel("GFEX061_01"):SetDescription(STR0003) //"Dados do Comparativo"
	oModel:GetModel("GFEX061_02"):SetDescription(STR0004) //"Dados Tabela de Frete"
	oModel:GetModel("GFEX061_02"):SetOptional(.T.)
	oModel:GetModel('GFEX061CALC1'):SetDescription("Campos calculados") //"Campos calculados"
	oModel:GetModel('GFEX061CALC1'):SetOptional(.T.)
	
	oModel:GetModel('DETAIL_02' ):SetDescription("Simulações") //"Componentes Tabela Frete"
	oModel:GetModel('DETAIL_03' ):SetDescription(STR0007) //"Componentes Tabela Frete"
	oModel:GetModel('DETAIL_03' ):SetOptional(.T.)

	oModel:GetModel("DETAIL_02"):SetNoInsertLine(.T.)   
	oModel:GetModel("DETAIL_02"):SetNoDeleteLine(.T.)   
	oModel:GetModel("DETAIL_02"):SetOnlyQuery(.T.)
	oModel:GetModel("DETAIL_02"):SetOptional(.T.)

Return oModel  

//------------------------------------------------------------------------------------------------    
Static Function ViewDef()

	Local oModel       := FWLoadModel("GFEX061")
	Local oStruTransp  := GetStrTrp(2)
	Local oStruTab     := GetStrTab(2)
	Local oStruSimFrt  := GetStrSim(2)   
	Local oStruCompo   := GetStrComp(2)   
	Local oStruClFld   := GetCalcFld(2)

	Local oView        := FWFormView():New() 
	Static oBrwDoc                                                        
	// Criação dos grupos    
	// <obj_struct>:AddGroup(<cId>,<cTitulo>,<cIdFolder>,<nTipo>), onde nTipo 1=Janela, 2=Separador
	oStruTransp:AddGroup("GrpSelDC",STR0008,"",2) //"Seleção de Documentos de Carga"
	oStruTransp:AddGroup("GrpTrpCmp",STR0009,"",2) //"Transportador p/ Comparação"

	oStruTab:AddGroup("GrpTabGeral",STR0010,"",2) //"Dados Gerais"
	oStruTab:AddGroup("GrpTabMin",STR0011,"",2) //"Frete Mínimo"
	oStruTab:AddGroup("GrpTabPrz",STR0012,"",2) //"Prazo de Entrega"
	oStruTab:AddGroup("GrpTabImp",STR0013,"",2) //"Impostos"

	// Ajuste dos campos aos novos grupos
	oStruTransp:SetProperty("*"         ,MVC_VIEW_GROUP_NUMBER,"GrpSelDC" )
	oStruTransp:SetProperty("GWU_TRPCOM",MVC_VIEW_GROUP_NUMBER,"GrpTrpCmp")
	oStruTransp:SetProperty("GWU_DESCOM",MVC_VIEW_GROUP_NUMBER,"GrpTrpCmp")
	oStruTransp:SetProperty("GWU_TABCMP",MVC_VIEW_GROUP_NUMBER,"GrpTrpCmp")
	oStruTransp:SetProperty("GWU_NEGCMP",MVC_VIEW_GROUP_NUMBER,"GrpTrpCmp")

	oStruTab:setProperty("*"         ,MVC_VIEW_GROUP_NUMBER,"GrpTabPrz"  )
	oStruTab:setProperty("FRT_TPVEI" ,MVC_VIEW_GROUP_NUMBER,"GrpTabGeral")
	oStruTab:setProperty("FRT_DESVEI",MVC_VIEW_GROUP_NUMBER,"GrpTabGeral")
	oStruTab:setProperty("FRT_UNMED" ,MVC_VIEW_GROUP_NUMBER,"GrpTabGeral")
	oStruTab:setProperty("FRT_KGM3"  ,MVC_VIEW_GROUP_NUMBER,"GrpTabGeral")
	oStruTab:setProperty("FRT_ATRFAI",MVC_VIEW_GROUP_NUMBER,"GrpTabGeral")
	oStruTab:setProperty("FRT_QTDMIN",MVC_VIEW_GROUP_NUMBER,"GrpTabMin"  )
	oStruTab:setProperty("FRT_FRTMIN",MVC_VIEW_GROUP_NUMBER,"GrpTabMin"  )
	oStruTab:setProperty("FRT_COMPGR",MVC_VIEW_GROUP_NUMBER,"GrpTabMin"  )
	oStruTab:setProperty("FRT_ADISS" ,MVC_VIEW_GROUP_NUMBER,"GrpTabImp"  )
	oStruTab:setProperty("FRT_ADICMS",MVC_VIEW_GROUP_NUMBER,"GrpTabImp"  )
	oStruTab:setProperty("FRT_RATIMP",MVC_VIEW_GROUP_NUMBER,"GrpTabImp"  )
	oStruTab:setProperty("FRT_COMIMP",MVC_VIEW_GROUP_NUMBER,"GrpTabImp"  )

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)  

	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.
	oView:AddField("GFEX061_01", oStruTransp  , /*cLinkID*/ )    

	oView:AddOtherObject("DETAIL_01",{|oPanel, oObj| GFEX061DOC(oPanel, oObj)},,{|oPanel| oBrwDoc:Refresh()}) 
	oView:AddGrid( 'VIEW_02'   , oStruSimFrt  , 'DETAIL_02' )  

	// Habilita titulos nos grids
	//oView:EnableTitleView("VIEW_01")
//	oView:EnableTitleView("VIEW_02")

	oView:AddField( "GFEX061_02", oStruTab  , /*cLinkID*/ )    
	oView:AddGrid(  'VIEW_03'   , oStruCompo, 'DETAIL_03' )  

//	oView:EnableTitleView("VIEW_03")

	oView:AddField( 'VIEW_CALC', oStruClFld, 'GFEX061CALC1' )

	// Cria os folders da tela principal
	oView:CreateFolder("IDFOLDER", /* cParentID */)
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0020) //"Comparativo"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0021) //"Tabela Frete"

	// Parâmetros dos métodos CreateHorizontalBox e CreateVerticalBox 
	// cID          Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura/Largura do box ( caso o lFixPixel seja .T. é a qtd de pixel exato, senão é dada em percentagem).
	// cIdOwner     Id do Box pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel    Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder    Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o box.

	// Elementos do 1o folder
	oView:CreateHorizontalBox( "SELECAO_BOX", 40, /*cIDOwner*/, /*lFixPixel*/, "IDFOLDER", "IDSHEET01" )
	oView:CreateHorizontalBox( "TOPO"       , 60, /*cIDOwner*/, /*lFixPixel*/, "IDFOLDER", "IDSHEET01" )
//	oView:CreateHorizontalBox( "MEIO"	    , 08, /*cIDOwner*/, /*lFixPixel*/, "IDFOLDER", "IDSHEET01" )
//	oView:CreateHorizontalBox( "RODAPE"     , 70, /*cIDOwner*/, /*lFixPixel*/, "IDFOLDER", "IDSHEET01" )
	oView:CreateFolder("FOLDERTAB", "TOPO")
	oView:AddSheet("FOLDERTAB","IDSHEET01","Comparação de Frete") 
	oView:AddSheet("FOLDERTAB","IDSHEET02","Simulação com outras transportadoras")
	
	oView:CreateHorizontalBox( "TOPO_COMP"       , 80, /*cIDOwner*/, /*lFixPixel*/, "FOLDERTAB", "IDSHEET01" )
	oView:CreateHorizontalBox( "TOPO_COMPRES"    , 20, /*cIDOwner*/, /*lFixPixel*/, "FOLDERTAB", "IDSHEET01" )
	oView:CreateHorizontalBox( "TOPO_OUTR"       , 100, /*cIDOwner*/, /*lFixPixel*/, "FOLDERTAB", "IDSHEET02" )

	// Elementos do box TOPO_COMP
	oView:CreateVerticalBox( "TOPO_ESQ", 100,"TOPO_COMP",,"FOLDERTAB", "IDSHEET01" )
//	oView:CreateVerticalBox( "TOPO_DIR", 10,"TOPO_COMP",,"FOLDERTAB", "IDSHEET01" )

	// Elementos do box TOPO_OUTR
	oView:CreateVerticalBox( "RODAPE_ESQ", 90,"TOPO_OUTR",,"FOLDERTAB", "IDSHEET02" )
	oView:CreateVerticalBox( "RODAPE_DIR", 10,"TOPO_OUTR",,"FOLDERTAB", "IDSHEET02" )

	// Elemento do box TOPO_DIR
//	oView:AddOtherObject( "BTN_EXCEL_PANEL"  , {|oPanel| GFEX61BTN(oPanel,1)})
//	oView:AddOtherObject( "BTN_CARREGA_PANEL", {|oPanel| GFEX61BTN(oPanel,3)})

	// Elemento do box RODAPE_DIR
	oView:AddOtherObject( "BTN_SIMULAR_PANEL", {|oPanel| GFEX61BTN(oPanel,2)})
	oView:AddOtherObject( "BTN_EXCEL_PANEL2" , {|oPanel| GFEX61BTN(oPanel,4)})
	oView:SetViewProperty( "VIEW_CALC", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP, 6 , 85 } )
	// Vinculando elementos de interface (grids, campos, etc.) aos elementos continentes (boxes, folders, etc.)
	oView:SetOwnerView( "GFEX061_01"       , "SELECAO_BOX" )
	oView:SetOwnerView( "DETAIL_01"        , "TOPO_ESQ"    )
//	oView:SetOwnerView( "BTN_EXCEL_PANEL"  , "TOPO_DIR"    )
//	oView:SetOwnerView( "BTN_CARREGA_PANEL", "TOPO_DIR"    )
	oView:SetOwnerView( "VIEW_CALC"        , "TOPO_COMPRES"        )
	oView:SetOwnerView( "VIEW_02"          , "RODAPE_ESQ"  )
	oView:SetOwnerView( "BTN_SIMULAR_PANEL", "RODAPE_DIR"  )
	oView:SetOwnerView( "BTN_EXCEL_PANEL2" , "RODAPE_DIR"  )
	
	// Elementos do 2o folder
	oView:CreateHorizontalBox( "DADOS_BOX", 60,/*cIDOwner*/,/*lFixPixel*/,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "COMP_BOX" , 40,/*cIDOwner*/,/*lFixPixel*/,"IDFOLDER","IDSHEET02" )

	// Vinculando elementos de interface (grids, campos, etc.) aos elementos continentes (boxes, folders, etc.)
	oView:SetOwnerView("GFEX061_02", "DADOS_BOX")
	oView:SetOwnerView("VIEW_03"   , "COMP_BOX" )

	// Adiciona uma nova opção ao menu "Ações Relacionadas"
	oView:AddUserButton("Comparar","",{|| GFEX061CR()})
	
	SX1->(dbSetOrder(1))
	If SX1->(MsSeek('GFEX061   01'))
		oView:AddUserButton("Filtros Avançados","",{|| Filtros()})
	EndIf
	oView:AddUserButton("Cadastrar nova tabela/negociação","",{|| NovaTab()}) //"Carregar"Cadastrar nova tabela/negociação
	oView:AddUserButton("Registrar comparativo","",{|| RegistComp() }) //"Registrar comparativo"
	oView:AddUserButton("Verificar comparativo","",{|| VerifComp() }) //"Registrar comparativo"
	
Return oView

Static Function Filtros()

	Pergunte("GFEX061",.T.)
	
Return

/*------------------------------------------------------------------- 
Função para sobrepor o COMMIT padrão do model
------------------------------------------------------------------- */
Static Function GFEX61CMT()
Return .T.

/*------------------------------------------------------------------- 
Cria a estrutura que será usada na seleção dos documentos de carga
nTipo Indica se a estrutura será de model (1) ou de view (2)
--------------------------------------------------------------------*/
Static Function GetStrTrp(nTipo)    

	Local aAux 	  := {}
	Local aAux1	  := {}
	Local oStruct := NIL  
	Local nI      := 0 
	Local bValid  := NIL  
	Local bInic   := NIL
	Local cAux    := ""
	Local cGV9F   := "GV9F"
	Local cGV9T   := "GV9T"
	
	// aCampos [1] Titulo, [2] Descrição, [3] Nome do campo, [4] Tipo de dado, [5] Tamanho, [6] Decimais, [7] Picture, [8] F3
	Local aCampos
	// Lista de campos obrigatorios
	Local cObrigat := "GWU_TRP,GWU_TRPCOM,GWU_TABCMP,GWU_PERINI,GWU_PERFIM"

	// Lista de campos que recebem lista de valores
	Local cLista := "GWU_DCCALC,GWU_MANRED,GWU_FRTENT,GWU_FRTSAI"
	Local aLista := {"1="+STR0049,"2="+STR0050} //"Sim" ### "Não" 

	// Lista de campos do tipo COMBO
	Local cCombo := "GWU_DCCALC,GWU_MANRED,GWU_FRTENT,GWU_FRTSAI"
	
	SXB->(dbSetOrder(1))
	If !SXB->(MsSeek('GV9F  101DB'))
		cGV9F := NIL
	EndIf
	If !SXB->(MsSeek('GV9T  101DB'))
		cGV9T := NIL
	EndIf
	
	aCampos := {;
	{STR0023, STR0024, 'GWU_TRP'   ,'C',TamSX3("GU3_CDEMIT")[1],0,TRIM(X3PICTURE("GU3_CDEMIT")),'GU3GVA'},; //"Transportadora" ### "Código da Transportadora"
	{STR0025, STR0026, 'GWU_DESTRP','C',TamSX3("GU3_NMEMIT")[1],0,TRIM(X3PICTURE("GU3_NMEMIT")),NIL     },; //"Nome Transp." ### "Nome da Transportadora"
	{STR0027, STR0028, 'GWU_NRTAB' ,'C',TamSX3("GVA_NRTAB" )[1],0,TRIM(X3PICTURE("GVA_NRTAB" )),"GVA3"  },; //"Nr Tabela" ### "Número da Tabela de Frete"
	{"Nr Negociação", "Nr Negociação de Frete", 'GWU_NRNEG' ,'C',TamSX3("GV9_NRNEG" )[1],0,TRIM(X3PICTURE("GV9_NRNEG" )),cGV9F  },; //"Nr Negociação" ### "Nr Negociação de Frete"	
	{STR0029, STR0030, 'GWU_TRPCOM','C',TamSX3("GU3_CDEMIT")[1],0,TRIM(X3PICTURE("GU3_CDEMIT")),'GU3GVA'},; //"Transp. Comp." ### "Transportadora p/ Comparativo"
	{STR0031, STR0032, 'GWU_DESCOM','C',TamSX3("GU3_NMEMIT")[1],0,TRIM(X3PICTURE("GU3_NMEMIT")),NIL     },; //"Nome Transp. Comp" ### "Nome da Transportadora p/ Comparativo"
	{STR0033, STR0034, 'GWU_TABCMP','C',TamSX3("GVA_NRTAB" )[1],0,TRIM(X3PICTURE("GVA_NRTAB" )),'GVA4'  },; //"Nr Tab Comp" ### "Nr Tabela de Frete p/ Comparativo"
	{"Nr Neg Comp", "Nr Negociação de Frete p/ Comparativo", 'GWU_NEGCMP','C',TamSX3("GV9_NRNEG" )[1],0,TRIM(X3PICTURE("GV9_NRNEG" )),cGV9T  },; //"Nr Neg Comp" ### "Nr Negociação de Frete p/ Comparativo"
	{STR0035, STR0035, 'GWU_PERINI','D',TamSX3("GW1_DTEMIS")[1],0,TRIM(X3PICTURE("GW1_DTEMIS")),NIL     },; //"Período De" ### "Período De"
	{STR0036, STR0036, 'GWU_PERFIM','D',TamSX3("GW1_DTEMIS")[1],0,TRIM(X3PICTURE("GW1_DTEMIS")),NIL     },; //"Período Até" ### "Período Até"
	{STR0037, STR0038, 'GWU_CIDINI','C',TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" )),'GU7GUA'},; //"Cidade De" ### "Cidade Destino De"
	{STR0039, STR0040, 'GWU_CIDFIM','C',TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" )),'GU7GUA'},; //"Cidade Até" ### "Cidade Destino Até"
	{STR0041, STR0041, 'GWU_UFINI' ,'C',TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  )),'12'    },; //"UF De" ### "UF De"
	{STR0042, STR0042, 'GWU_UFFIM' ,'C',TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  )),'12'    },; //"UF Até" ### "UF Até"
	{STR0043, STR0044, 'GWU_DCCALC','C',1                      ,0,'@!'                         ,NIL     },; //"Somente DC Calc." ### "Somente Doc Carga Calculados"
	{STR0045, STR0046, 'GWU_MANRED','C',1                      ,0,'@!'                         ,NIL     },; //"Mantém Redesp" ### "Mantém Redespacho"
	{STR0047, STR0047, 'GWU_FRTENT','C',1                      ,0,'@!'                         ,NIL     },; //"Frete entrada" ### "Frete Entrada"
	{STR0048, STR0048, 'GWU_FRTSAI','C',1                      ,0,'@!'                         ,NIL     }} //"Frete Saída" ### "Frete Saída"

	if nTipo == 1	// Model     

		oStruct := FWFormModelStruct():New()
		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		oStruct:AddTable( ;
		'GWU'                           , ;       // [01] Alias da tabela
		{'GWU_TRP'}                     , ;       // [02] Array com os campos que correspondem a primary key
		STR0003    )               // [03] Descrição da tabela //"Dados do Comparativo"

		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		oStruct:AddIndex( ;
		01               , ;               // [01] Ordem do indice
		'1'              , ;               // [02] ID
		'GWU_TRP'      , ;                 // [03] Chave do indice
		STR0023 , ;               // [04] Descrição do indice //"Transportadora"
		''               , ;               // [05] Expressão de lookUp dos campos de indice
		''               , ;               // [06] Nickname do indice
		.T.               )                // [07] Indica se o indice pode ser utilizado pela interface 

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------

		For nI := 1 to len(aCampos)

			Do Case
				Case aCampos[nI,3] == "GWU_TRP"
					cAux   := 'GU3->GU3_SIT=="1".AND.(GU3->GU3_TRANSP=="1".OR.GU3->GU3_AUTON=="1")'
					bValid := "GFEExistC('GU3',,M->GWU_TRP,'" + cAux + "')"
				Case aCampos[nI,3] == "GWU_NRTAB"
					bValid := 'Vazio().OR.ExistCpo("GVA",M->GWU_TRP+M->GWU_NRTAB,1)'
				Case aCampos[nI,3] == "GWU_TRPCOM"              	
					bValid := "GFEExistC('GU3',,M->GWU_TRPCOM,'" + cAux + "')"
				Case aCampos[nI,3] == "GWU_TABCMP"
					bValid := 'Vazio().OR.ExistCpo("GVA",M->GWU_TRPCOM+M->GWU_TABCMP,1)'
				Case aCampos[nI,3] == "GWU_NEGCMP"
					bValid := 'Vazio().OR.(ExistCpo("GV9",M->GWU_TRPCOM+M->GWU_TABCMP+M->GWU_NEGCMP,1))'
				Otherwise
					bValid := ''
			EndCase

			Do Case
				Case aCampos[nI,3] == "GWU_CIDFIM"
					bInic := '"999999"'
				Case aCampos[nI,3] == "GWU_UFFIM"
					bInic := '"ZZ"'
				Case aCampos[nI,3] == "GWU_MANRED" .OR. aCampos[nI,3] == "GWU_FRTSAI"
					bInic := '"1"'
				Case aCampos[nI,3] == "GWU_DCCALC"
					bInic := '"1"'
				Case aCampos[nI,3] == "GWU_FRTENT"
					bInic := '"2"'
				Otherwise
					bInic := ""
			EndCase

			bValid := FWBuildFeature(1,bValid)	      
			bInic  := FWBuildFeature(3,bInic)	

			oStruct:AddField(          ;
							aCampos[nI,1]            , ;              // [01] Titulo do campo
							aCampos[nI,2]            , ;              // [02] ToolTip do campo
							aCampos[nI,3]            , ;              // [03] Id do Field
							aCampos[nI,4]            , ;              // [04] Tipo do campo
							aCampos[nI,5]            , ;              // [05] Tamanho do campo
							aCampos[nI,6]	         , ;              // [06] Decimal do campo
							bValid                   , ;              // [07] Code-block de validação do campo
							NIL		                 , ;              // [08] Code-block de validação When do campo
							IF(aCampos[nI,3]$cLista,aLista,NIL), ;    // [09] Lista de valores permitido do campo
							aCampos[nI,3]$cObrigat	 , ;              // [10] Indica se o campo tem preenchimento obrigatório
							bInic              		 , ;              // [11] Code-block de inicializacao do campo
							NIL                      , ;              // [12] Indica se trata-se de um campo chave
							!("GWU_DES"$aCampos[nI,3]) , ;            // [13] Indica se o campo pode receber valor em uma operação de update.
							.T.						  )               // [14] Indica se o campo é virtual    

		Next nI		

		//------------------------------------------------------------------
		//------------------------------------------------------------------

		aAux := FwStruTrigger(;
							'GWU_TRP'                    								,; // Campo de Dominio (tem que existir no Model)
							'GWU_DESTRP'                 								,; // Campo de ContraDominio (tem que existir no Model)
							'Posicione("GU3",1,xFilial("GU3")+GWU_TRP,"GU3_NMEMIT")' 	,; // Regra de Preenchimento
							,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
							,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
							,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
							)  // Condição para execução do gatilho (Opcional)

		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho 
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )      

		//------------------------------------------------------------------ 
		//------------------------------------------------------------------ 

		aAux1 := FwStruTrigger(;
		'GWU_TRPCOM'                    							,; // Campo de Dominio (tem que existir no Model)
		'GWU_DESCOM'                 								,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("GU3",1,xFilial("GU3")+M->GWU_TRPCOM,"GU3_NMEMIT")' ,; // Regra de Preenchimento
		,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
		,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
		)  // Condição para execução do gatilho (Opcional)

		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho 
		oStruct:AddTrigger( aAux1[1], aAux1[2], aAux1[3], aAux1[4] )
		oStruct:AddTrigger( "GWU_TRP", "GWU_NRTAB",  , {||""})
		oStruct:AddTrigger( "GWU_TRP", "GWU_NRNEG",  , {||""})
		oStruct:AddTrigger( "GWU_NRTAB", "GWU_NRNEG",  , {||""})
		oStruct:AddTrigger( "GWU_TRPCOM", "GWU_TABCMP",  , {||""})
		oStruct:AddTrigger( "GWU_TRPCOM", "GWU_NEGCMP",  , {||""})
		oStruct:AddTrigger( "GWU_TABCMP", "GWU_NEGCMP",  , {||""})
		
	Else
		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos)
			oStruct:AddField( 			   ;
			aCampos[nI,3]  				 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]		      	 , ;                // [03] Titulo
			aCampos[nI,2]		         , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			If(aCampos[nI,3]$cCombo,"COMBO","GET"), ;       // [06] Tipo do campo COMBO, GET ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			aCampos[nI,8]          		 , ;                // [09] F3
			!("GWU_DES"$aCampos[nI,3])	 , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			If(aCampos[nI,3]$cLista,aLista,NIL), ;          // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual      
		Next nI
	EndIf

Return oStruct


/*------------------------------------------------------------------
Cria a estrutura que será usada na informação dos dados para cálculo
------------------------------------------------------------------*/
Static Function GetStrTab(nTipo)

	Local aAux 	  := {} 
	Local aLista  := NIL
	Local oStruct := NIL
	Local nI      := 0  
	Local bValid  := NIL
	Local bWhen   := NIL
	Local bInic   := NIL                                                               
	Local cCombo  := ""
	Local aCampos := {{STR0051, STR0052, 'FRT_TPVEI' , 'C', TamSX3("GV3_CDTPVC")[1],0,TRIM(X3PICTURE("GV3_CDTPVC")),'GV3'},; //"Tipo Veíc." ### "Tipo Veiculo"
	{STR0053, STR0054, 'FRT_DESVEI', 'C', TamSX3("GV3_DSTPVC")[1],0,TRIM(X3PICTURE("GV3_DSTPVC")),NIL  },; //"Descrição" ### "Descrição Veiculo"
	{STR0055, STR0056, 'FRT_ATRFAI', 'C', TamSX3("GV9_ATRFAI")[1],0,TRIM(X3PICTURE("GV9_ATRFAI")),NIL  },; //"Atrib. Faixa" ### "Atributo Faixa"
	{STR0057, STR0057, 'FRT_UNMED' , 'C', TamSX3("GV9_UNIFAI")[1],0,'@!',"SAH"},; //"Unidade Medida" ### "Unidade Medida"
	{STR0058, STR0059, 'FRT_KGM3'  , 'N', TamSX3("GV9_QTKGM3")[1],TamSX3("GV9_QTKGM3")[2],TRIM(X3PICTURE("GV9_QTKGM3")),NIL},; //"Kg/M3" ### "Fator de Cubagem"
	{STR0060, STR0060, 'FRT_QTDMIN', 'N', TamSX3("GV6_QTMIN" )[1],TamSX3("GV6_QTMIN" )[2],TRIM(X3PICTURE("GV6_QTMIN" )),NIL},; //"Qtde Minima" ### "Qtde Minima"
	{STR0061, STR0061, 'FRT_FRTMIN', 'N', TamSX3("GV6_FRMIN" )[1],TamSX3("GV6_FRMIN" )[2],TRIM(X3PICTURE("GV6_FRMIN" )),NIL},; //"Frete Minimo" ### "Frete Minimo"
	{STR0062, STR0062, 'FRT_COMPGR', 'C', TamSX3("GV6_COMFRG")[1],0,TRIM(X3PICTURE("GV6_COMFRG")),"GV2FRT"},; //"Comp Garantia" ### "Comp Garantia"
	{STR0063, STR0064, 'FRT_CNPRAZ', 'C', TamSX3("GV6_CONSPZ")[1],0,TRIM(X3PICTURE("GV6_CONSPZ")),NIL},; //"Cons. Prazo" ### "Considera Prazo"
	{STR0065, STR0066, 'FRT_TPPRAZ', 'C', TamSX3("GV6_TPPRAZ")[1],0,TRIM(X3PICTURE("GV6_TPPRAZ")),NIL},; //"Tipo Prazo" ### "Tipo de Prazo"
	{STR0067, STR0067, 'FRT_PRAZO' , 'N', TamSX3("GV6_QTPRAZ")[1],TamSX3("GV6_QTPRAZ")[2],TRIM(X3PICTURE("GV6_QTPRAZ")),NIL},; //"Prazo" ### "Prazo"
	{STR0068, STR0069, 'FRT_CNTPRA', 'C', TamSX3("GV6_CONTPZ")[1],0,TRIM(X3PICTURE("GV6_CONTPZ")),NIL},; //"Cont. Prazo" ### "Contagem do prazo"
	{STR0070, STR0071, 'FRT_ADISS' , 'C', TamSX3("GV9_ADISS" )[1],0,TRIM(X3PICTURE("GV9_ADISS" )),NIL},; //"Adic. ISS?" ### "Adiciona ISS no frete?"
	{STR0072, STR0073, 'FRT_ADICMS', 'C', TamSX3("GV9_ADICMS")[1],0,TRIM(X3PICTURE("GV9_ADICMS")),NIL},; //"Adic. ICMS?" ### "Adiciona ICMS no frete?"
	{STR0074, STR0075, 'FRT_RATIMP', 'C', TamSX3("GV9_RATIMP")[1],0,TRIM(X3PICTURE("GV9_RATIMP")),NIL},; //"Rateia Imp.?" ### "Rateia imposto?"
	{STR0076, STR0077, 'FRT_COMIMP', 'C', TamSX3("GV9_COMIMP")[1],0,TRIM(X3PICTURE("GV9_COMIMP")),"GV2FRT"}} //"Comp. Imposto" ### "Componente para imposto"

	If nTipo == 1 // Model

		oStruct := FWFormModelStruct():New()

		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		oStruct:AddTable( ;
		'FRT'                   , ;       // [01] Alias da tabela
		{'FRT_TPVEI'}           , ;       // [02] Array com os campos que correspondem a primary key
		STR0078    )            // [03] Descrição da tabela //"Dados da tabela" 

		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		oStruct:AddIndex( ;
		01               , ;               // [01] Ordem do indice
		'FRT_TPVEI'      , ;               // [02] ID
		'FRT_TPVEI'      , ;               // [03] Chave do indice
		STR0079   , ;               // [04] Descrição do indice //"Tipo Veiculo"
		''               , ;               // [05] Expressão de lookUp dos campos de indice
		''               , ;               // [06] Nickname do indice
		.T.               )                // [07] Indica se o indice pode ser utilizado pela interface 

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------
		For nI := 1 to len(aCampos)

			aLista := NIL
			bValid := ""
			bWhen  := ""
			bInic  := ""

			Do Case
				Case aCampos[nI,3] == "FRT_TPVEI"
				bValid := 'Vazio() .Or. ExistCpo("GV3",M->FRT_TPVEI,1)'
				Case aCampos[nI,3] == "FRT_UNMED"
				bValid := 'Vazio() .Or. ExistCpo("SAH",M->FRT_UNMED,1)'
				Case aCampos[nI,3] == "FRT_COMPGR"
				bValid := "Vazio().OR.ExistCpo('GV2',M->FRT_COMPGR,1)"
				Case aCampos[nI,3] == "FRT_PRAZO"
				bWhen  := 'M->FRT_CNPRAZ=="1"'
				bInic  := "0"
				Case aCampos[nI,3] == "FRT_RATIMP"
				bWhen  := 'M->FRT_ADISS=="1".OR.M->FRT_ADICMS="1"'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_RATIMP","X3_CBOX")),";")
				bInic  := "'1'"
				Case aCampos[nI,3] == "FRT_COMIMP"
				bValid := 'Vazio().OR.ExistCpo("GV2",M->FRT_COMIMP,1)'
				bWhen  := '(M->FRT_ADISS=="1".OR.M->FRT_ADICMS="1").AND.M->FRT_RATIMP=="2"'
				Case aCampos[nI,3] == "FRT_CNPRAZ"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_CONSPZ","X3_CBOX")),";")
				bInic  := "'1'"	
				Case aCampos[nI,3] == "FRT_TPPRAZ"
				bWhen  := 'M->FRT_CNPRAZ=="1"'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_TPPRAZ","X3_CBOX")),";")
				bInic  := "'1'"
				Case aCampos[nI,3] == "FRT_CNTPRA"
				bWhen  := 'M->FRT_CNPRAZ=="1"'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_CONTPZ","X3_CBOX")),";")
				bInic  := "'1'"
				Case aCampos[nI,3] == 'FRT_ADISS'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ADISS","X3_CBOX" )),";")
				bInic  := "'1'"
				Case aCampos[nI,3] == 'FRT_ADICMS'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ADICMS","X3_CBOX")),";")	
				bInic  := "'1'"
				Case aCampos[nI,3] == 'FRT_KGM3'
				bInic  := "300"
				Case aCampos[nI,3] == 'FRT_ATRFAI'
				bInic  := "'1'"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ATRFAI","X3_CBOX")),";")	
			EndCase

			bValid := FwBuildfeature( 1, bValid )
			bWhen  := FwBuildfeature( 2, bWhen )
			bInic  := FwBuildfeature( 3, bInic )	

			oStruct:AddField( ;
			aCampos[nI,1]	  , ;       // [01] Titulo do campo
			aCampos[nI,2]     , ;       // [02] ToolTip do campo
			aCampos[nI,3]     , ;       // [03] Id do Field
			aCampos[nI,4]     , ;       // [04] Tipo do campo
			aCampos[nI,5]     , ;       // [05] Tamanho do campo
			aCampos[nI,6]	  , ;       // [06] Decimal do campo
			bValid            , ;       // [07] Code-block de validação do campo
			bWhen       	  , ;       // [08] Code-block de validação When do campo
			aLista            , ;       // [09] Lista de valores permitido do campo
			NIL				  , ;       // [10] Indica se o campo tem preenchimento obrigatório
			bInic             , ;       // [11] Code-block de inicializacao do campo
			NIL               , ;       // [12] Indica se trata-se de um campo chave 			
			.T.               , ;       // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.				  )         // [14] Indica se o campo é virtual  
		Next nI

		//------------------------------------------------------------------
		//------------------------------------------------------------------

		aAux := FwStruTrigger(;
		'FRT_TPVEI'                    								,; // Campo de Dominio (tem que existir no Model)
		'FRT_DESVEI'                 								,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("GV3",1,xFilial("GV3")+FRT_TPVEI,"GV3_DSTPVC")' 	,; // Regra de Preenchimento
		,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
		,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
		)  // Condição para execução do gatilho (Opcional)

		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	Else 
		// Lista de campos definidos como COMBO
		cCombo  := "FRT_CNPRAZ,FRT_TPPRAZ,FRT_CNTPRA,FRT_ADISS,FRT_ADICMS,FRT_RATIMP"		
		oStruct := FWFormViewStruct():New()	

		For nI := 1 to len(aCampos)  

			Do Case
				Case aCampos[nI,3] == "FRT_RATIMP"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_RATIMP","X3_CBOX")),";")
				Case aCampos[nI,3] == "FRT_CNPRAZ"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_CONSPZ","X3_CBOX")),";")
				Case aCampos[nI,3] == "FRT_TPPRAZ"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_TPPRAZ","X3_CBOX")),";")
				Case aCampos[nI,3] == "FRT_CNTPRA"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV6_CONTPZ","X3_CBOX")),";")
				Case aCampos[nI,3] == 'FRT_ADISS'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ADISS" ,"X3_CBOX")),";")
				Case aCampos[nI,3] == 'FRT_ADICMS'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ADICMS","X3_CBOX")),";")
				Case aCampos[nI,3] == 'FRT_ATRFAI'
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV9_ATRFAI","X3_CBOX")),";")
				Otherwise
				aLista := NIL
			EndCase

			oStruct:AddField( 			       ;
			aCampos[nI,3]   			 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]			 	 , ;                // [03] Titulo
			aCampos[nI,2]		         , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			if(aCampos[nI,3]$cCombo,'COMBO','GET') ,;       // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			aCampos[nI,8]         	     , ;                // [09] F3
			aCampos[nI,3]!="FRT_DESVEI"  , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			aLista                       , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual     
		Next nI

		//------------------------------------------------------------------    
		//------------------------------------------------------------------       
	EndIf

Return oStruct                                                      


/*------------------------------------------------------------------
Retorna a estrutura de Model dos valores simulados com outras transportadoras
------------------------------------------------------------------*/
Static Function GetStrSim(nTipo)    

	Local aCampos := {;
	{"Filial"   ,"Filial"   ,'SIM_FILIAL','C',TamSX3("GW1_FILIAL")[1],0                      ,TRIM(X3PICTURE("GW1_FILIAL"))},; //Filial
	{"Tp Docto" ,"Tp Docto" ,'SIM_CDTPDC','C',TamSX3("GW1_CDTPDC")[1],0                      ,TRIM(X3PICTURE("GW1_CDTPDC"))},; //TipoDocumento  
	{"Emissor"  ,"Emissor"  ,'SIM_EMISDC','C',TamSX3("GW1_EMISDC")[1],0                      ,TRIM(X3PICTURE("GW1_EMISDC"))},; //emissor
	{"Série"    ,"Série"    ,'SIM_SERDC' ,'C',TamSX3("GW1_SERDC")[1] ,0                      ,TRIM(X3PICTURE("GW1_SERDC")) },; //serie
	{"Doc Carga","Doc Carga",'SIM_NRDC'  ,'C',TamSX3("GW1_NRDC")[1]  ,0                      ,TRIM(X3PICTURE("GW1_NRDC"))  },; //Documento carga
	{STR0110    ,STR0111    ,'SIM_NRCALC','C',TamSX3("GWF_NRCALC")[1],0                      ,TRIM(X3PICTURE("GWF_NRCALC"))},; //"Simul." ### "Número Simulação"
	{STR0081    ,STR0081    ,'SIM_TRECHO','C',TamSX3("GWU_SEQ"   )[1],0                      ,'@'                          },; //"Trecho" ### "Trecho"
	{STR0112    ,STR0113    ,'SIM_TRANSP','C',TamSX3("GU3_CDEMIT")[1],0                      ,'@'                          },; //"Transp." ### "Transportador"
	{STR0114    ,STR0115    ,'SIM_NRTAB' ,'C',TamSX3("GVA_NRTAB" )[1],0                      ,TRIM(X3PICTURE("GVA_NRTAB" ))},; //"Número Tabela" ### "Número Tabela"
	{STR0016    ,STR0089    ,'SIM_TOTFRE','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Realizado" ### "Frete dos calculos atuais"
	{STR0018    ,STR0090    ,'SIM_TOTSIM','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Simulado" ### "Frete usando nova tabela"
	{STR0116    ,STR0117    ,'SIM_FRTVL' ,'N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Valor Real." ### "Frete Valor Realizado"
	{STR0118    ,STR0119    ,'SIM_FRTVLS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Valor Sim." ### "Frete Valor Simulado"
	{STR0120    ,STR0121    ,'SIM_FRTUNI','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Unid. Real." ### "Frete Unidade Realizado"
	{STR0122    ,STR0123    ,'SIM_FRTUNS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Unid. Sim. ### "Frete Unidade Simulação"
	{STR0124    ,STR0125    ,'SIM_TOTTAX','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Taxas Real." ### "Total Taxas Realizado"
	{STR0126    ,STR0127    ,'SIM_TOTAXS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Taxas Simul." ### "Total Taxas Simulação"
	{STR0128    ,STR0129    ,'SIM_PEDAG' ,'N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Pedágio Real." ### "Pedágio Realizado"
	{STR0130    ,STR0131    ,'SIM_PEDAGS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))}}  //"Pedágio Sim." ### "Pedágio Simulação"

	Local oStruct := NIL
	Local nI := 0

	if nTipo == 1	// Model

		oStruct := FWFormModelStruct():New()

		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		oStruct:AddTable( 	  ;
		'SIM'               , ;       // [01] Alias da tabela
		{'SIM_NRCALC'}      , ;       // [02] Array com os campos que correspondem a primary key
		STR0132)            // [03] Descrição da tabela //"Simulação Frete"

		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		oStruct:AddIndex( 	  ;
		01               	, ;         // [01] Ordem do indice
		'1'              	, ;         // [02] ID
		'SIM_NRCALC'      	, ;         // [03] Chave do indice
		STR0132             , ;         // [04] Descrição do indice //"Simulação Frete"
		''               	, ;         // [05] Expressão de lookUp dos campos de indice
		''               	, ;         // [06] Nickname do indice
		.T.              )              // [07] Indica se o indice pode ser utilizado pela interface 

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------

		For nI := 1 to len(aCampos)
			oStruct:AddField(        ;
			aCampos[nI,1]	         , ;              // [01] Titulo do campo
			aCampos[nI,2]	         , ;              // [02] ToolTip do campo
			aCampos[nI,3]            , ;              // [03] Id do Field
			aCampos[nI,4]            , ;              // [04] Tipo do campo
			aCampos[nI,5]	         , ;              // [05] Tamanho do campo
			aCampos[nI,6]	         , ;              // [06] Decimal do campo
			NIL						 , ;       		  // [07] Code-block de validação do campo
			NIL		                 , ;              // [08] Code-block de validação When do campo
			NIL                      , ;              // [09] Lista de valores permitido do campo
			NIL						 , ;              // [10] Indica se o campo tem preenchimento obrigatório
			NIL                		 , ;              // [11] Code-block de inicializacao do campo
			NIL                      , ;              // [12] Indica se trata-se de um campo chave
			.T.                      , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.						  )               // [14] Indica se o campo é virtual		
		Next nI

	Else	

		oStruct := FWFormViewStruct():New() 	

		For nI := 1 to len(aCampos)

			oStruct:AddField( 			       ;
			aCampos[nI,3]   			 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]			 	 , ;                // [03] Titulo
			aCampos[nI,2]		         , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			'GET'                        , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			NIL           	             , ;                // [09] F3
			.F.                          , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			NIL                          , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual     		
		Next nI
	EndIf    

Return oStruct                                                       


/*------------------------------------------------------------------
Retorna a estrutura de model do grid de componentes da tabela de frete
------------------------------------------------------------------*/
Static Function GetStrComp(nTipo)

	Local aAux    := {}
	Local oStruct := NIL
	Local bValid  := NIl
	Local nI      := 0
	Local bInic   := NIL
	Local bWhen	:= NIL
	Local aLista  := NIL  
	Local cLista  := "COP_TOTFRT,COP_IMPOST,COP_PISCOF,COP_FREMIN"
	Local aCampos := {{"Componente","Componente",'COP_COMP'  ,'C',TamSX3("GV2_CDCOMP")[1],0,TRIM(X3PICTURE("GV2_CDCOMP")),''},; //"Componente" ### "Componente"
	{STR0053,STR0133,'COP_DESCOM','C',TamSX3("GV2_DSCOMP")[1],TamSX3("GV2_DSCOMP")[2],TRIM(X3PICTURE("GV2_DSCOMP")),''},; //"Descrição" ### "Descrição Componente"
	{STR0134,STR0135,'COP_VLFIXO','N',TamSX3("GV1_VLFIXN")[1],TamSX3("GV1_VLFIXN")[2],TRIM(X3PICTURE("GV1_VLFIXN")),'GV1_VLFIXN'},; //"Vl Fixo Norm" ### "Valor Fixo Normal"
	{STR0136,STR0137,'COP_PCNORM','N',TamSX3("GV1_PCNORM")[1],TamSX3("GV1_PCNORM")[2],TRIM(X3PICTURE("GV1_PCNORM")),'GV1_PCNORM'},; //"% Normal" ### "Percentual Normal"
	{STR0138,STR0139,'COP_VLUNNM','N',TamSX3("GV1_VLUNIN")[1],TamSX3("GV1_VLUNIN")[2],TRIM(X3PICTURE("GV1_VLUNIN")),'GV1_VLUNIN'},; //"Vl Unid Norm" ### "Valor Unidade Normal"
	{STR0140,STR0141,'COP_VLFRAC','N',TamSX3("GV1_VLFRAC")[1],TamSX3("GV1_VLFRAC")[2],TRIM(X3PICTURE("GV1_VLFRAC")),'GV1_VLFRAC'},; //"Vl Fração Norm" ### "Valor Fração Normal"
	{STR0142,STR0143,'COP_VLMINN','N',TamSX3("GV1_VLMINN")[1],TamSX3("GV1_VLMINN")[2],TRIM(X3PICTURE("GV1_VLMINN")),'GV1_VLMINN'},; //"Vl Min Nor" ### "Valor Minimo Normal"
	{STR0144,STR0145,'COP_VLLIMI','N',TamSX3("GV1_VLLIM" )[1],TamSX3("GV1_VLLIM" )[2],TRIM(X3PICTURE("GV1_VLLIM" )),'GV1_VLLIM '},; //"Vl Limite" ### "Valor Limite"
	{STR0146,STR0147,'COP_VLFXEX','N',TamSX3("GV1_VLFIXE")[1],TamSX3("GV1_VLFIXE")[2],TRIM(X3PICTURE("GV1_VLFIXE")),'GV1_VLFIXE'},; //"Vl Fixo Extra" ### "Valor Fixo Extra"
	{STR0148,STR0149,'COP_PCEXTR','N',TamSX3("GV1_PCEXTR")[1],TamSX3("GV1_PCEXTR")[2],TRIM(X3PICTURE("GV1_PCEXTR")),'GV1_PCEXTR'},; //"% Extra" ### "Percentual Extra"
	{STR0150,STR0151,'COP_VLUNEX','N',TamSX3("GV1_VLUNIE")[1],TamSX3("GV1_VLUNIE")[2],TRIM(X3PICTURE("GV1_VLUNIE")),'GV1_VLUNIE'},; //"Vl Unid Extra" ### "Valor Unidade Extra"
	{STR0152,STR0153,'COP_CALCEX','C',TamSX3("GV1_CALCEX")[1],TamSX3("GV1_CALCEX")[2],TRIM(X3PICTURE("GV1_CALCEX")),''},; //"Calc. Exced." ### "Forma de cálculo do excedente"
	{STR0154,STR0154,'COP_TOTFRT','C',TamSX3("GUY_TOTFRE")[1],TamSX3("GUY_TOTFRE")[2],TRIM(X3PICTURE("GUY_TOTFRE")),''},; //"Total Frete?" ### "Total Frete?"
	{STR0155,STR0155,'COP_IMPOST','C',TamSX3("GUY_BASIMP")[1],TamSX3("GUY_BASIMP")[2],TRIM(X3PICTURE("GUY_BASIMP")),''},; //"Base Imposto?" ### "Base Imposto?"
	{STR0156,STR0157,'COP_PISCOF','C',TamSX3("GUY_BAPICO")[1],TamSX3("GUY_BAPICO")[2],TRIM(X3PICTURE("GUY_BAPICO")),''},; //"Base PIS/COF?" ### "Base PIS/COF?"
	{STR0158,STR0159,'COP_FREMIN','C',TamSX3("GUY_FREMIN")[1],TamSX3("GUY_FREMIN")[2],TRIM(X3PICTURE("GUY_FREMIN")),''}}  //"Frete Minimo?" ### "Considera Frete Min?"

	If nTipo == 1	// Model
		oStruct := FWFormModelStruct():New()

		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		oStruct:AddTable( 	  ;
		'COP'               , ;       // [01] Alias da tabela
		{'COP_COMP'}      	, ;       // [02] Array com os campos que correspondem a primary key
		"Simulação Frete")            // [03] Descrição da tabela //"Simulação Frete"

		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		oStruct:AddIndex( 	  ;
		01               	, ;         // [01] Ordem do indice
		'COP_COMP'          , ;         // [02] ID
		'COP_COMP'      	, ;         // [03] Chave do indice
		STR0042      	    , ;         // [04] Descrição do indice //"Componente"
		''               	, ;         // [05] Expressão de lookUp dos campos de indice
		''               	, ;         // [06] Nickname do indice
		.T.              )              // [07] Indica se o indice pode ser utilizado pela interface 

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------
		For nI := 1 to len(aCampos) 

			bValid := ""
			bInic  := ""
			bWhen	:= Nil
			aLista := NIL

			if aCampos[nI,3]=='COP_COMP'
				bValid := 'ExistCpo("GV2",M->COP_COMP) .And. GFEX061LCP(M->COP_COMP)'
			EndIf	    	    

			if aCampos[nI,3]$cLista
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GUY_TOTFRE","X3_CBOX")),";")
				bInic  := '"1"'
			ElseIf aCampos[nI,3]=="COP_CALCEX"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV1_CALCEX","X3_CBOX")),";")
				bInic  := '"1"'
			EndIf
			
			If !Empty(aCampos[nI,8])
				bWhen := "GFEX61FWHN('" + aCampos[nI,8] + "')"
			EndIf

			bValid := FwBuildFeature(1,bValid)
			
			If !Empty(bWhen)
				bWhen	:= FwBuildFeature(2,bWhen)
			EndIf
			
			bInic  := FwBuildFeature(3,bInic)

			oStruct:AddField(        ;
			aCampos[nI,1]		     , ;              // [01] Titulo do campo
			aCampos[nI,2]		     , ;              // [02] ToolTip do campo
			aCampos[nI,3]            , ;              // [03] Id do Field
			aCampos[nI,4]            , ;              // [04] Tipo do campo
			aCampos[nI,5]	         , ;              // [05] Tamanho do campo
			aCampos[nI,6]            , ;              // [06] Decimal do campo
			bValid                   , ;              // [07] Code-block de validação do campo
			bWhen		                 , ;              // [08] Code-block de validação When do campo
			aLista                   , ;              // [09] Lista de valores permitido do campo
			NIL						 , ;              // [10] Indica se o campo tem preenchimento obrigatório
			bInic              		 , ;              // [11] Code-block de inicializacao do campo
			NIL                      , ;              // [12] Indica se trata-se de um campo chave
			aCampos[nI,3]!='COP_DESCOM', ;            // [13] Indica se o campo pode receber valor em uma operação de update.
			aCampos[nI,3]=='COP_DESCOM')              // [14] Indica se o campo é virtual    
		Next nI	

		//------------------------------------------------------------------
		//------------------------------------------------------------------

		aAux := FwStruTrigger(;
		'COP_COMP'                    								 ,; // Campo de Dominio (tem que existir no Model)
		'COP_DESCOM'                 								 ,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("GV2",1,xFilial("GV2")+M->COP_COMP,"GV2_DSCOMP")' ,; // Regra de Preenchimento
		,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
		,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
		,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
		)  // Condição para execução do gatilho (Opcional)

		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho 
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )      

	Else
		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos)

			aLista := NIL

			if aCampos[nI,3]$cLista
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GUY_TOTFRE","X3_CBOX")),";")
			ElseIf aCampos[nI,3]=="COP_CALCEX"
				aLista := StrTokArr(Trim(Posicione("SX3",2,"GV1_CALCEX","X3_CBOX")),";")
			EndIf

			oStruct:AddField( 			   ;
			aCampos[nI,3]  				 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]				 , ;                // [03] Titulo
			aCampos[nI,2]			     , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			if(aCampos[nI,3]$cLista,'COMBO','GET'), ;       // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			if(aCampos[nI,3]=="COP_COMP",Trim(Posicione("SX3",2,"GVB_CDCOMP","X3_F3")),NIL), ;   // [09] F3
			aCampos[nI,3]!="COP_DESCOM"	 , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			aLista                       , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual      
		Next nI	
	EndIf

Return oStruct


/*--------------------------------------------------------------------
Cria um botão no painel informado, de acordo com o tipo
--------------------------------------------------------------------*/                                   
Static Function GFEX61BTN(oPanel, nTipo)

	Do Case
		//Case nTipo == 1
		//@ 25, 10 Button STR0160 Size 36, 13 Message STR0161 Pixel Action GFEX061XLS() of oPanel //"Exportar" ### "Exportar resultado para planilha"
		Case nTipo == 2
		@ 10, 10 Button STR0162  Size 36, 13 Message STR0163 Pixel Action ProcSim() of oPanel //"Simular" ### "Simular documento com outras transportadoras"
		Case nTipo == 3
		@ 10, 10 Button STR0022  Size 36, 13 Message "Carregar dados para Simulação" Pixel Action GFEX061CR() of oPanel //"Carregar" ### "Simular documento com outras transportadoras"
		Case nTipo == 4
		@ 25, 10 Button STR0160 Size 36, 13 Message STR0161 Pixel Action GFEX061XL2() of oPanel //"Exportar" ### "Exportar resultado para planilha"
	EndCase

Return .T.                            


/*------------------------------------------------------------------- 
Função criada para permitir a exibição da tela de processamento durante 
a execução da carga de documentos
------------------------------------------------------------------- */
Function GFEX061CR()
	
	Processa({|| GFEX061CRG()},STR0164) //"Realizando comparativo de frete"

Return NIL          



/*------------------------------------------------------------------- 
Função criada para permitir a exibição da tela de processamento durante 
a execução da carga de documentos
------------------------------------------------------------------- */
Static Function ProcSim()

	Processa({|| GFEX061SIM()},STR0165) //"Simulando com outras transportadoras"

Return NIL 


/*--------------------------------------------------------------------
Carrega o browse com os documentos de carga, de acordo com a seleção
--------------------------------------------------------------------*/
Static Function GFEX061CRG()
	Local cCdTransp  := FwFldGet("GWU_TRP")     
	Local cNrTab     := FwFldGet("GWU_NRTAB")
	Local cNrNeg     := FwFldGet("GWU_NRNEG")
	Local dDtPerIni  := FwFldGet("GWU_PERINI")
	Local dDtPerFim  := FwFldGet("GWU_PERFIM")
	Local cCidDesIni := FwFldGet("GWU_CIDINI")
	Local cCidDesFim := FwFldGet("GWU_CIDFIM")
	Local cUFDesIni  := FwFldGet("GWU_UFINI")
	Local cUFDesFim  := FwFldGet("GWU_UFFIM")
	Local cDCCalc    := FwFldGet("GWU_DCCALC")
	Local cManRed    := FwFldGet("GWU_MANRED")
	Local cFretEnt   := FwFldGet("GWU_FRTENT")
	Local cFretSai   := FwFldGet("GWU_FRTSAI")
	Local cTrpComp   := FwFldGet("GWU_TRPCOM")
	Local cNrTabCmp  := FwFldGet("GWU_TABCMP")
	Local cNrNegCmp  := FwFldGet("GWU_NEGCMP")
	Local cAliasQry  := getNextAlias()
	Local oModel     := FWModelActive()
	Local oView      := FwViewActive()
	Local oModelSim  := oModel:GetModel("DETAIL_02")
	Local oModelComp := oModel:GetModel("DETAIL_03")
	Local oCalc      := oModel:getModel("GFEX061CALC1")
	Local aChaveDC
	Local aCidades
	Local aUfs
	Local nI := 0, nPos := 0, nAuxPos := 0, nVlFrete := 0, nPrazo := 0, nX := 0, nY := 0, nZ := 0, nAux := 0
	Local nQtMerc   := 0, nPesoR    := 0, nPesoC    := 0, nVlMerc   := 0, nVolume   := 0
	Local nQtMerTot := 0, nPesoRTot := 0, nPesoCTot := 0, nVlMerTot := 0, nVolumTot := 0
	Local cQuery := "", cLista := "'0'", cChaveDC := ""
	Local aAgrFrt := {}, aDocCar := {}, aItDoc  := {}, aTrcDoc := {}, aTblFrt := {}, aComp := {}, aResult := {}, aAuxAgrp := {}
	Local aFil01 := aFil02 := aFil03 := aFilPerm := {}
	Local nVlSimu    := 0    
	Local nVlFrtReal := 0  
	Local nQtdDoc    := 0 
	Local nQtdDocSim := 0
	Local nContUnid  := 0
	Local cFiltroAv  := ""
	Local cUnidCalc	 := ""
	Local aCalcAux   := {}
	Local aAuxDc     := {}
	Local aAuxItDoc  := {}
	Local aCalcsDC   := {}	// Armazena, por documento de carga, os cálculos existentes
	Local lChkCalc   := .T.
	Local lTemCalc   := .T.
	Local cFilAux	 := cFilAnt
	Local cCriRat    := SuperGetMv("MV_CRIRAT",,"1")
	Local lPEx0611   := ExistBlock("GFEX0611")
	Local lXFBGWUDC  := FindFunction("XFBGWUDC")

	Static cAlQryCrg := GetNextAlias()
	
/*************************************************************/
	Private lTabTemp
	Private aTRBCCF1 := {} // Indice 3
	
	Private idpCCF   := 1 // posição do array cTRBCCF
	Private idxCCF   := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {	"NRCALC",; // 1
							"CDCLFR",; // 2
							"CDTPOP",; // 3
							"SEQ"   ,; // 4
							"CDCOMP",; // 5
							"CATVAL",; // 6
							"QTDE"  ,; // 7
							"VALOR" ,; // 8
							"TOTFRE",; // 9
							"BASIMP",; // 10
							"BAPICO",; // 11
							"FREMIN",; // 12
							"IDMIN" ,; // 13
							"VLFRMI",; // 14
							"DELETE"}  // 15
/*************************************************************/
	Private aTRBTRE  := {} // Indice 1
	Private idpTRE   := 1 // posição do array cTRBTRE
	Private idxTRE   := 1 // Indice  da array cTRBTRE
	Private _aCmpTRE := {"EMISDC",; // 1
						 "SERDC" ,; // 2
						 "NRDC"  ,; // 3
						 "CDTPDC",; // 4
						 "SEQ"   ,; // 5
						 "CDTRP" ,; // 6
						 "NRCIDD",; // 7
						 "CDTPVC",; // 8
						 "PAGAR" ,; // 9
						 "NRCIDO",; // 10
						 "CEPO"  ,; // 11
						 "CEPD"  ,; // 12
						 "CDCLFR",; // 13
						 "CDTPOP",; // 14
						 "ORIGEM",; // 15
						 "DESTIN",; // 16
						 "NRGRUP",; // 17
						 "NRCALC",; // 18
						 "DELETE" } // 19
/*************************************************************/
	Private aTRBUNC := {} // Indice 1

	Private idpUNC := 1 // posição do array cTRBUNC
	Private idxUNC := 1 // Indice  da array cTRBUNC
	Private _aCmpUNC := {"NRCALC",; // 1
						 "TIPO"  ,; // 2
						 "FINALI",; // 3
						 "DTPREN",; // 4
						 "HRPREN",; // 5
						 "TPTRIB",; // 6
						 "BASICM",; // 7
						 "PCICMS",; // 8
						 "VLICMS",; // 9
						 "ICMRET",; // 10
						 "BASISS",; // 11
						 "PCISS" ,; // 12
						 "VLISS" ,; // 13
						 "BAPICO",; // 14
						 "VLPIS" ,; // 15
						 "VLCOFI",; // 16
						 "PCREIC",; // 17
						 "VALTAB",; // 18
						 "NRAGRU",; // 19
						 "IDFRVI",; // 20
						 "SEQTRE",; // 21
						 "CALBAS",; // 22
						 "ADICIS",; // 23
						 "CHVGWU",; // 24
						 "DELETE"}  // 25
/*************************************************************/
	Private aTRBTCF := {} // Indice 1

	Private idpTCF := 1 // posição do array de Documentos de carga cTRBTCF
	Private idxTCF := 1 // Indice da array de Documentos de carga cTRBTCF

	Private _aCmpTCF := {"NRCALC",; //1
						 "CDCLFR",; //2
						 "CDTPOP",; //3
						 "SEQ"   ,; //4
						 "DTVIGE",; //5
						 "ITEM"  ,; //6
						 "CDTRP" ,; //7
						 "NRTAB" ,; //8
						 "NRNEG" ,; //9
						 "CDFXTV",; //10
						 "CDTPVC",; //11
						 "NRROTA",; //12
						 "QTCALC",; //13
						 "QTDE"  ,; //14
						 "PESOR" ,; //15
						 "PESCUB",; //16
						 "QTDALT",; //17
						 "VALOR" ,; //18
						 "VOLUME",; //19
						 "NRGRUP",; //20
						 "CDEMIT",; //21
						 "PEDROM",; //22
						 "PESPED",; //23
						 "PRAZO" ,;  //24
						 "DELETE"}

/*************************************************************/
/*************************************************************/
/*************************************************************/

	// Valor 0 (zero) indica processamento sem barra de progresso
	ProcRegua(0)
	IncProc(STR0166) //"Validando parâmetros de seleção"

	// Validação dos parâmetros de seleção   
	If Empty(cCdTransp)
		//Alert("Transportadora não foi informada")
		GFEMsgErro( STR0167 ) //"Transportadora não foi informada"
		Return .F.
	EndIf	 

	If Empty(dDtPerIni).OR.Empty(dDtPerFim)
		GFEMsgErro( STR0168) //"Periodo De ou Periodo Até não foram informados"
		Return .F.
	EndIf

	If dDtPerIni > dDtPerFim
		GFEMsgErro( STR0169) //"Período De é maior que Período Até"
		Return .F.
	EndIf

	If Empty(cCidDesFim)
		GFEMsgErro( STR0170) //"Cidade Até não foi informada"
		Return .F.
	EndIf	

	If cCidDesIni > cCidDesFim
		GFEMsgErro( STR0171) //"Cidade De é maior que Cidade Até"
		Return .F.
	EndIf

	If Empty(cUfDesFim)
		GFEMsgErro( STR0172) //"UF Até não foi informada"
		Return .F.
	EndIf	

	If cUfDesIni > cUfDesFim
		GFEMsgErro( STR0173) //"UF De é maior que UF Até"
		Return .F.
	EndIf

	If Empty(cTrpComp)
		GFEMsgErro( STR0174) //"Não foi informada transportadora para comparativo"
		Return .F.
	EndIf

	If Empty(cNrTabCmp)
		If oModelComp:isEmpty()
			GFEMsgErro( STR0175) //"Não foi informada tabela para comparativo, nem dados da tabela de frete que permitam fazer a simulação dos valores"
			Return .F.
		Else
			// Validar se unidade de medida está informada
			if Empty(FwFldGet("FRT_UNMED"))
				GFEMsgErro( STR0176) //"Unidade de medida não foi informada"
				Return .F.
			EndIf

			// Validar se o componente para frete garantia está listado entre os componentes
			if !Empty(FwFldGet("FRT_COMPGR")) .AND. !oModelComp:seekLine({{"COP_COMP",FwFldGet("FRT_COMPGR")}})
				GFEMsgErro( STR0177) //"Componente para frete garantia não consta entre os componentes informados."
				Return .F.
			EndIf

			// Validar se o componente para imposto está listado entre os componentes
			if !Empty(FwFldGet("FRT_COMIMP")) .AND. !oModelComp:seekLine({{"COP_COMP",FwFldGet("FRT_COMIMP")}})
				GFEMsgErro( STR0178) //"Componente para imposto não consta entre os componentes informados."
				Return .F.
			EndIf
		EndIf
	Else
		if !oModelComp:isEmpty()
			GFEMsgErro(STR0179) //"Tabela para comparativo foi informada e há dados no folder Tabela Frete. Será considerada a tabela para comparativo."
		EndIf
	EndIf	

	If cFretEnt == cFretSai .AND. cFretEnt == "2"	// 1-Sim, 2-Não
		GFEMsgErro( STR0180) //"Selecione pelo menos uma opção entre Frete Entrada e Frete Saída"
		Return .F.
	EndIf

	If GetNrLin() > 0 // Retorna se existem linhas carregadas no markbrowse
		If !MsgYesNo(STR0181) //"Deseja recarregar a lista de documentos de carga? A lista atual será perdida."
			Return .F.
		EndIf	
	EndIf

	LimpaAbaOutr()

	IncProc(STR0182) //"Selecionando documentos de carga"

	If cFretEnt == '1'	// Considera Frete de Entrada
		cLista := "'1'"
	EndIf
	If cFretSai == '1'	// Considera Frete de Saida
		cLista += ",'2'"
	EndIf

	If !Empty(cCdTransp) .And. !Empty(cNrTab) .And. !Empty(cNrNeg) .And. cDCCalc == "2"
		Help(,,"HELP",,"Foi selecionado 'Somente DC Calc.' como '2=Não' e informado uma negociação na seleção de documentos de carga, portanto somente documentos de carga com cálculo de frete que possuam a negociação informada serão selecionados.",1,0)
	EndIf

	// Utiliza filtro avançado 1=Sim
	cFiltroAv := ""
	Pergunte("GFEX061",.F.)
	If !(cValToChar(MV_PAR01) $ '12') //Proteção
		MV_PAR01 := 2
	EndIf
	If MV_PAR01 == 1
		If !Empty(MV_PAR04)
			aFil01		:= Str2Arr(Upper(MV_PAR04), ";") //Filiais informadas em tela
			aFilPerm	:= FWUsrEmp(__cUserID) // Lista as filiais que o usuário tem permissão.
			for nX:= 1 to Len(aFilPerm)
				AADD(aFil02,SubStr(aFilPerm[nX], Len(cEmpAnt)+1))
			next
			aFil03 := {}
			// Como o usuário pode ter informado filiais que não tem permissão, é preciso verificar quais tem permissão.
			for nX:= 1 to Len(aFil01)
				nPos := ASCAN(aFil02,{|X| Alltrim(X) == Alltrim(aFil01[nX])}) 
				if nPos > 0 .OR. AScan(aFilPerm,"@@@@") > 0
					AADD(aFil03,aFil01[nX])
				EndIf
			next
		EndIf

		aUfs		:= Iif(!Empty(MV_PAR02),Str2Arr(Upper(MV_PAR02), ";"),{}) //Parametro tipo 'Range'
		aCidades	:= Iif(!Empty(MV_PAR03),Str2Arr(Upper(MV_PAR03), ";"),{}) //Parametro tipo 'Range'

		If !Empty(aCidades) .And. !Empty(aUfs)
			cFiltroAv += "   AND (" + GetListSql(aCidades,"GU3_NRCID","GU3DEST.GU3_NRCID")
			cFiltroAv += "   OR " + GetListSql(aUfs,"GU7_CDUF","GU7DEST.GU7_CDUF") + ")"
		Else
			If !Empty(aCidades)
				cFiltroAv += "   AND " + GetListSql(aCidades,"GU3_NRCID","GU3DEST.GU3_NRCID")
			EndIf
			If !Empty(aUfs)
				cFiltroAv += "   AND " + GetListSql(aUfs,"GU7_CDUF","GU7DEST.GU7_CDUF")
			EndIf
		EndIf
	Else
		cFiltroAv += " AND   (GU3DEST.GU3_NRCID >= '" + cCidDesIni + "' AND GU3DEST.GU3_NRCID <= '" + cCidDesFim + "')"
		cFiltroAv += " AND   (GU7DEST.GU7_CDUF  >= '" + cUfDesIni  + "' AND GU7DEST.GU7_CDUF  <= '" + cUfDesFim  + "')"
	EndIf
	
	// Se não foi informado nenhuma, usa a filial corrente 
	If Len(aFil03) == 0
		AADD(aFil03,cFilAnt)
	EndIf

	For nX:= 1 To Len(aFil03)
		// Selecionar os registros de documento de carga
		cFilAnt := aFil03[nX]
		cQuery := "SELECT GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC, GW1.GW1_DTEMIS,GW1.GW1_CDREM,GW1.GW1_CDDEST,GW1.GW1_NRROM"
     	cQuery += " , GWU.GWU_SEQ, GWU.GWU_NRCIDO AS GU3ORI_NRCID, GWU.GWU_NRCIDD AS GU3DES_NRCID"
     	cQuery += " , GU3ORI.GU3_NMEMIT AS NMREM, GU3DEST.GU3_NMEMIT AS NMDEST, GU3DEST.GU3_IDFED AS GU3DES_IDFED"
     	cQuery += " , GU7ORI.GU7_NMCID AS NMCIDO, GU7ORI.GU7_CDUF AS GU7ORI_CDUF, GU7DEST.GU7_NMCID AS NMCIDD, GU7DEST.GU7_CDUF AS GU7DES_CDUF"
     	cQuery += " , SUM(GW8.GW8_VALOR) AS GW8_VLRNF,SUM(GW8.GW8_PESOR) AS GW8_PESOB"
		cQuery += " FROM " + RetSqlName("GW1") + " GW1"
		cQuery += " INNER JOIN " + RetSqlName("GW8") + " GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
		cQuery += " AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
		cQuery += " AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
		cQuery += " AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
		cQuery += " AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
		cQuery += " JOIN " + RetSqlName("GWU") + " GWU ON GW1.GW1_FILIAL = GWU.GWU_FILIAL"
		cQuery += " AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC"
		cQuery += " AND GW1.GW1_EMISDC = GWU.GWU_EMISDC"
		cQuery += " AND GW1.GW1_SERDC  = GWU.GWU_SERDC"
		cQuery += " AND GW1.GW1_NRDC   = GWU.GWU_NRDC"
		cQuery += " JOIN " + RetSqlName("GU3") + " GU3ORI  ON GW1.GW1_CDREM     = GU3ORI.GU3_CDEMIT"
		cQuery += " JOIN " + RetSqlName("GU7") + " GU7ORI  ON GWU.GWU_NRCIDO  = GU7ORI.GU7_NRCID"
		cQuery += " JOIN " + RetSqlName("GU3") + " GU3DEST ON GW1.GW1_CDDEST    = GU3DEST.GU3_CDEMIT"
		cQuery += " JOIN " + RetSqlName("GU7") + " GU7DEST ON GWU.GWU_NRCIDD = GU7DEST.GU7_NRCID"
		cQuery += " JOIN " + RetSqlName("GV5") + " GV5     ON GV5.GV5_CDTPDC    = GW1.GW1_CDTPDC"
		cQuery += " WHERE (GW1.GW1_DTEMIS >= '" + DTOS(dDtPerIni) + "' AND GW1.GW1_DTEMIS <= '" + DTOS(dDtPerFim) + "')"
		cQuery += " AND   GWU.GWU_CDTRP = '" + cCdTransp + "'"
		cQuery += " AND   GWU.GWU_PAGAR = '1'"	// Apenas trechos pagos
		cQuery += " AND   GV5.GV5_SENTID IN(" + cLista + ")"
		cQuery += cFiltroAv

		// Ponto de Entrada Vicunha
		If lPEx0611
			cQuery := ExecBlock("GFEX0611",.f.,.f.,{cQuery})
		EndIf

		// Filtra somente os documentos de carga que possuírem algum cálculo de frete com a negociação informada
		If !Empty(cCdTransp) .And. !Empty(cNrTab) .And. !Empty(cNrNeg)
			cQuery += " AND EXISTS ("
			cQuery +=     " SELECT 1"
			cQuery +=       " FROM "+RetSqlName("GWH")+" GWH"
			cQuery +=      " WHERE GWH.GWH_FILIAL = '"+xFilial("GWH")+"'"
			cQuery +=        " AND GWH.GWH_NRDC   = GW1.GW1_NRDC"
			cQuery +=        " AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC"
			cQuery +=        " AND GWH.GWH_EMISDC = GW1.GW1_EMISDC"
			cQuery +=        " AND GWH.GWH_SERDC  = GW1.GW1_SERDC"
			cQuery +=        " AND GWH.D_E_L_E_T_ = ' '"
			cQuery +=        " AND EXISTS ("
			cQuery +=            " SELECT 1"
			cQuery +=              " FROM "+RetSqlName("GWG")+" GWG"
			cQuery +=             " WHERE GWG.GWG_FILIAL = '"+xFilial("GWG")+"'"
			cQuery +=               " AND GWG.GWG_NRCALC = GWH.GWH_NRCALC"
			cQuery +=               " AND GWG.GWG_CDEMIT = '"+cCdTransp+"'"
			cQuery +=               " AND GWG.GWG_NRTAB  = '"+cNrTab+"'"
			cQuery +=               " AND GWG.GWG_NRNEG  = '"+cNrNeg+"'"
			cQuery +=               " AND GWG.D_E_L_E_T_ = ' ' ) )"
		EndIf
		cQuery += " AND GW1.GW1_FILIAL     = '"+xFilial("GW1")+"'"
		cQuery += " AND GU7DEST.GU7_FILIAL = '"+xFilial("GU7")+"'"
		cQuery += " AND GU3DEST.GU3_FILIAL = '"+xFilial("GU3")+"'"
		cQuery += " AND GV5.GV5_FILIAL     = '"+xFilial("GV5")+"'"
		cQuery += " AND GW1.D_E_L_E_T_ = ' '"
		cQuery += " AND GU7DEST.D_E_L_E_T_ = ' '"
		cQuery += " AND GU3DEST.D_E_L_E_T_ = ' '"
		cQuery += " AND GV5.D_E_L_E_T_ = ' '"
		cQuery += " AND GW1.GW1_NRROM <> ''"
		cQuery += " GROUP BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC, GW1.GW1_DTEMIS,GW1.GW1_CDREM,GW1.GW1_CDDEST,GW1.GW1_NRROM"
		cQuery += " , GWU.GWU_SEQ, GWU.GWU_NRCIDO, GWU.GWU_NRCIDD"
		cQuery += " , GU3ORI.GU3_NMEMIT, GU3DEST.GU3_NMEMIT, GU3DEST.GU3_IDFED"
		cQuery += " , GU7ORI.GU7_NMCID, GU7ORI.GU7_CDUF, GU7DEST.GU7_NMCID, GU7DEST.GU7_CDUF"
		cQuery := changeQuery(cQuery)

		cAliasQry  := getNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		// Salva os valores digitados pelo usuário para comparar se houve alguma alteração para a opção 'Registrar Comparativo'
		// Ao incluir um novo campo no formulário, adionar no array aSaveFld e aValorFld da função RegistComp
		aSaveFld := {{cCdTransp,cNrTab,cNrNeg,cTrpComp,cNrTabCmp,cNrNegCmp,dDtPerIni,dDtPerFim,cCidDesIni,cCidDesFim,cUFDesIni,cUFDesFim,cDCCalc,cManRed,cFretEnt,cFretSai,MV_PAR01 == 1/*Se utilizou filtro avançado*/},aUfs,aCidades}

		// Verificar notas calculadas, de acordo com cDCCalc
		(cAliasQry)->(dbGoTop())
		While !(cAliasQry)->(Eof())
			
			cChaveDC := (cAliasQry)->GW1_CDTPDC + (cAliasQry)->GW1_EMISDC + (cAliasQry)->GW1_SERDC + (cAliasQry)->GW1_NRDC
			aChaveDC := {(cAliasQry)->GW1_FILIAL, ;
						 (cAliasQry)->GW1_CDTPDC, ;
						 (cAliasQry)->GW1_EMISDC, ;
						 (cAliasQry)->GW1_SERDC , ;
						 (cAliasQry)->GW1_NRDC}
						 
			// Armazena, para cada documento de carga, os cálculos aos quais ele está relacionado
			// a função GFETemCalc retorna um array com estes cálculos
			aAdd(aCalcsDC, {cChaveDC, GFETemCalc(aChaveDC), (cAliasQry)->GW1_FILIAL})
			lTemCalc := (len(aTail(aCalcsDC)[2]) > 0)
			 
			If  (!lTemCalc .AND. cDCCalc == "2") .OR.; // Considera DC sem cálculo
				(lTemCalc  .AND. ValidCalc(aTail(aCalcsDC)[2], cNrTab))
	
				nPosDc := aScan(aAuxDC,{|x| x[1] == (cAliasQry)->GW1_FILIAL .And. x[2] == (cAliasQry)->GW1_NRROM})
				If nPosDc == 0
					aadd(aAuxDC, {(cAliasQry)->GW1_FILIAL, (cAliasQry)->GW1_NRROM, {}})
					nPosDc := Len(aAuxDc)
				EndIf

				aadd(Atail(aAuxDC[nPosDc]), {(cAliasQry)->GW1_FILIAL,;		// 1
											(cAliasQry)->GW1_CDTPDC,;		// 2
											(cAliasQry)->GW1_EMISDC,;		// 3
											(cAliasQry)->GW1_SERDC,;		// 4
											(cAliasQry)->GW1_NRDC,;			// 5
											(cAliasQry)->GWU_SEQ,;			// 6
											STOD((cAliasQry)->GW1_DTEMIS),;	// 7
											(cAliasQry)->GW1_CDREM,;		// 8
											(cAliasQry)->GU3ORI_NRCID,;		// 9
											(cAliasQry)->GU7ORI_CDUF,;		// 10
											(cAliasQry)->GW1_CDDEST,;		// 11
											(cAliasQry)->GU3DES_NRCID,;		// 12
											(cAliasQry)->GU7DES_CDUF,;		// 13
											(cAliasQry)->GU3ORI_NRCID,;		// 14
											(cAliasQry)->GU7ORI_CDUF,;		// 15
											(cAliasQry)->GU3DES_NRCID,;		// 16
											(cAliasQry)->GU7DES_CDUF,;		// 17
											(cAliasQry)->GW1_NRROM,;		// 18
											(cAliasQry)->NMREM,;			// 19
											(cAliasQry)->NMDEST,;			// 20
											(cAliasQry)->NMCIDO,;			// 21
											(cAliasQry)->NMCIDD,;			// 22
											(cAliasQry)->NMCIDO,;			// 23
											(cAliasQry)->NMCIDD,;			// 24
											Iif(lTemCalc, cValToChar(aTail(aCalcsDC)[2,1])," "),;  // 25
											0,; 							// 26 - VLFRTDC
											stod(space(8)),; 				// 27 - PRAZO
											0,;								// 28 - VLSIMU
											stod(space(8)),;				// 29 - PRASIM
											(cAliasQry)->GU3DES_IDFED,;		// 30 - CPF/CNPJ do Destinatário
											(cAliasQry)->GW8_VLRNF,;		// 31 - Valor do Documento de Carga
											(cAliasQry)->GW8_PESOB})		// 32 - Peso Bruto do Documento de Carga
												
				GWH->(dbSetOrder(2))
				If GWH->(dbSeek((cAliasQry)->GW1_FILIAL + (cAliasQry)->GW1_CDTPDC + (cAliasQry)->GW1_EMISDC + (cAliasQry)->GW1_SERDC + (cAliasQry)->GW1_NRDC))
					While GWH->(!Eof()) .And. ( GWH->GWH_FILIAL == (cAliasQry)->GW1_FILIAL .And. ;
												GWH->GWH_CDTPDC == (cAliasQry)->GW1_CDTPDC .And. ;
												GWH->GWH_EMISDC == (cAliasQry)->GW1_EMISDC .And. ;
												GWH->GWH_SERDC == (cAliasQry)->GW1_SERDC .And. ;
												GWH->GWH_NRDC == (cAliasQry)->GW1_NRDC )
												
						If GWH->GWH_TRECHO == (cAliasQry)->GWU_SEQ
							nPos := aScan(aCalcAux,{|x| x[1] == GWH->GWH_NRCALC})
							If nPos > 0

								nAuxPos := aScan(aCalcAux[nPos][2], {|x| x[1]==GWH->GWH_FILIAL .And. x[2]==GWH->GWH_CDTPDC .And. x[3]==GWH->GWH_EMISDC .And. x[4]==GWH->GWH_SERDC .And. x[5]==GWH->GWH_NRDC .And. x[6] == GWH->GWH_TRECHO })
								If nAuxPos == 0
									aadd(aCalcAux[nPos][2], {(cAliasQry)->GW1_FILIAL,;					// 1
															(cAliasQry)->GW1_CDTPDC,;					// 2
															(cAliasQry)->GW1_EMISDC,;					// 3
															(cAliasQry)->GW1_SERDC,;					// 4
															(cAliasQry)->GW1_NRDC,;					// 5
															GWH->GWH_TRECHO,;							// 6
															STOD((cAliasQry)->GW1_DTEMIS)})			// 7
								EndIf

							Else
								aadd(aCalcAux, { GWH->GWH_NRCALC, {{(cAliasQry)->GW1_FILIAL,;			// 1
																	(cAliasQry)->GW1_CDTPDC,;			// 2
																	(cAliasQry)->GW1_EMISDC,;			// 3
																	(cAliasQry)->GW1_SERDC,;			// 4
																	(cAliasQry)->GW1_NRDC,;				// 5
																	GWH->GWH_TRECHO,;					// 6
																	STOD((cAliasQry)->GW1_DTEMIS)}} })	// 7
							EndIf
						EndIf

						GWH->(dbSkip())
					EndDo
				EndIf
			EndIf

			(cAliasQry)->(dbSkip())
		EndDo
	
		// Libera a tabela indicada por cAliasQry
		(cAliasQry)->(dbCloseArea())
	Next

	cFilAnt := cFilAux

	For nX := 1 To Len(aAuxDC)
		For nAux := 1 To Len(aCalcAux)	// Percorrendo cada calculo origem para enviar dados de DCs/Trecho somente usado no calculo origem para novo calculo comparativo
			aDocCar  := {}
			aItDoc   := {}
			aTrcDoc  := {}
			aAgrFrt  := {}
			lChkCalc := .T.
			cFilAnt  := aAuxDC[nX][1]

			For nY := 1 To Len(aAuxDC[nX][3])

				// Verifica se o documento posicionado faz parte do calculo origem para enviar ao novo calculo
				nAuxPos := aScan(aCalcAux[nAux][2],{|x| x[1] == aAuxDC[nX][3][nY][1] .And.;
														x[2] == aAuxDC[nX][3][nY][2] .And.;
														x[3] == aAuxDC[nX][3][nY][3] .And.;
														x[4] == aAuxDC[nX][3][nY][4] .And.;
														x[5] == aAuxDC[nX][3][nY][5] .And.;
														x[6] == aAuxDC[nX][3][nY][6] })
				If nAuxPos > 0
					cChaveDC := aAuxDC[nX][3][nY][2]+aAuxDC[nX][3][nY][3]+aAuxDC[nX][3][nY][4]+aAuxDC[nX][3][nY][5]
					aChaveDC := {aAuxDC[nX][3][nY][1],;
								aAuxDC[nX][3][nY][2],;
								aAuxDC[nX][3][nY][3],;
								aAuxDC[nX][3][nY][4],;
								aAuxDC[nX][3][nY][5]}

					incProc(STR0183 + AllTrim(cChaveDC)) //"Verificando "

					// Gerar array do documentos de carga
					aAdd(aDocCar, aTail(GFEArrDoc(aChaveDC)))

					// Carregar array de Itens do Documento de Carga
					aAuxItDoc := GFEArrIt(aChaveDC)
					For nI := 1 To Len(aAuxItDoc)
						aAdd(aItDoc, aAuxItDoc[nI])
					Next

					// Carregar array de Trechos do documento de Carga
					aAdd(aTrcDoc, aTail(GFEArrTrc(aChaveDC, ,aAuxDC[nX][3][nY][6], lXFBGWUDC)))

					If !Empty(aAuxDC[nX][2])		                       
						aAuxAgrp := GFEArrAgr(aAuxDC[nX][2])
						// Carregar array de Agrupadores dos documentos de carga
						If aScan(aAgrFrt,{|x| x[1] == aTail(aAuxAgrp)[1] .And. x[2] == aTail(aAuxAgrp)[2] .And. x[3] == aTail(aAuxAgrp)[3] .And. x[4] == aTail(aAuxAgrp)[4] .And. x[5] == aTail(aAuxAgrp)[5]}) == 0
							aAdd(aAgrFrt, aTail(aAuxAgrp))
						EndIf
					Else // Desconsidera Documentos de Carga sem romaneios
						Loop
					EndIf			

					// Procura o documento de carga corrente no array de calculos
					nPos := aScan(aCalcsDC,{|x| x[1] == cChaveDC})
					If Len(aCalcsDC[nPos,2]) == 0 	// Se documento de carga sem calculo, simular um frete real
						lChkCalc := .F.
						If Empty(aAgrFrt) 			//Se estiver em branco adiciona para evitar erro na função GFECLCFRT.
							aAdd(aAgrFrt, {'','','','','',0,'','','0'})
						EndIf
						aTblFrt := Array(20)
						aTblFrt[1] := cCdTransp
						aTblFrt[2] := cNrTab
						aTblFrt[20]:= cNrNeg
					Else
						// Passa por todos os cálculos do documento de carga
						GWH->(dbSetOrder(01))
						For nI := 1 To Len(aCalcsDC[nPos,2])
							cFilAnt := aCalcsDC[nPos,3]

							// Se o cálculo for do transportador informado na seleção...
							If Posicione("GWF", 1, xFilial("GWF") + aCalcsDC[nPos,2,nI], "GWF_TRANSP") == cCdTransp
								// Ratear o valor do frete e atribuir ao documento de carga
								aAuxDC[nX][3][nY][25] := aCalcsDC[nPos,2,nI]
								aAuxDC[nX][3][nY][26] := GFERatFrtDC(aCalcsDC[nPos,2,nI], cChaveDC)
								aAuxDC[nX][3][nY][27] := GFEPrazo(aCalcsDC[nPos,2,nI])

								Exit	// Sai do loop de calculos do documento de carga
							EndIf
						Next nI
					EndIf

					// Tratar parâmetro Mantem Redespacho = NO
					If cManRed == "2"
						GFEMudaDest(@aTrcDoc)	// Altera os destinos do trechos ignorando os redespachos

						nI := aScan(aTrcDoc, {|x| x[4]+x[1]+x[2]+x[3] == cChaveDC})
						If nI > 0
							// Ajustar Cidade e UF destino da simulação
							aAuxDC[nX][3][nY][16] := aTrcDoc[nI,7]
							aAuxDC[nX][3][nY][17] := Posicione("GU7", 1, xFilial("GU7") + aAuxDC[nX][3][nY][16], "GU7_CDUF")
							aAuxDC[nX][3][nY][24] := Posicione("GU7", 1, xFilial("GU7") + aAuxDC[nX][3][nY][16], "GU7_NMCID")
						EndIf
					EndIf

					incProc(STR0184 + AllTrim(cFilAnt + cChaveDC)) //"Simulando "

					// Atribui os dados da tabela de frete de comparação informada
					aComp   := {}
					aTblFrt := {cTrpComp, cNrTabCmp}
					aAdd(aTblFrt, If(Empty(FwFldGet("FRT_TPVEI")),"1","2"))	// Tipo de Lotação 1-Fracionada, 2-Fechada
					aAdd(aTblFrt, FwFldGet("FRT_ATRFAI"))					// Atributo da Faixa
					aAdd(aTblFrt, FwFldGet("FRT_TPVEI" ))					// Tipo de Veiculo
					aAdd(aTblFrt, FwFldGet("FRT_UNMED" ))					// Unidade de Medida
					aAdd(aTblFrt, FwFldGet("FRT_KGM3"  ))					// Fator de cubagem (kg/m3)
					aAdd(aTblFrt, FwFldGet("FRT_QTDMIN"))					// Quantidade minima
					aAdd(aTblFrt, FwFldGet("FRT_FRTMIN"))					// Frete Mínimo
					aAdd(aTblFrt, FwFldGet("FRT_COMPGR"))					// Componente para frete garantia
					aAdd(aTblFrt, FwFldGet("FRT_CNPRAZ"))					// Considera prazo de entrega?
					aAdd(aTblFrt, FwFldGet("FRT_TPPRAZ"))					// Tipo de prazo. 1-Dias, 2-Horas
					aAdd(aTblFrt, FwFldGet("FRT_PRAZO" ))					// Quantidade de prazo
					aAdd(aTblFrt, FwFldGet("FRT_CNTPRA"))					// Tipo de contagem do prazo. 1-Dias corridos, 2-Dias uteis
					aAdd(aTblFrt, FwFldGet("FRT_ADISS" ))					// Adiciona ISS no frete?
					aAdd(aTblFrt, FwFldGet("FRT_ADICMS"))					// Adiciona ICMS no frete?
					aAdd(aTblFrt, FwFldGet("FRT_RATIMP"))					// Rateia imposto adicionado (ISS/ICMS)?
					aAdd(aTblFrt, FwFldGet("FRT_COMIMP"))					// Componente para o ISS/ICMS adicionado, quando não rateia
				
					For nI := 1 To oModelComp:getQtdLine()
						If !oModelComp:isDeleted(nI)
							aAdd(aComp,{FwFldGet("COP_COMP"  ,nI),;	// Codigo do componente de frete
										FwFldGet("COP_VLFIXO",nI),;	// Valor fixo normal
										FwFldGet("COP_PCNORM",nI),;	// Percentual normal
										FwFldGet("COP_VLUNNM",nI),;	// Valor unitario normal
										FwFldGet("COP_VLFRAC",nI),;	// Valor fração normal
										FwFldGet("COP_VLMINN",nI),;	// Valor minimo normal
										FwFldGet("COP_VLLIMI",nI),;	// Valor limite
										FwFldGet("COP_VLFXEX",nI),;	// Valor fixo extra
										FwFldGet("COP_PCEXTR",nI),;	// Percentual extra
										FwFldGet("COP_VLUNEX",nI),;	// Valor unitario extra
										FwFldGet("COP_CALCEX",nI),;	// Forma de calculo do excedente
										FwFldGet("COP_TOTFRT",nI),;	// Componente considera no total do frete?
										FwFldGet("COP_IMPOST",nI),;	// Componente considera na base de cálculo de ISS/ICMS?
										FwFldGet("COP_PISCOF",nI),;	// Componente considera na base de cálculo de PIS/COFINS?
										FwFldGet("COP_FREMIN",nI),;	// Componente considera na base de cálculo de PIS/COFINS?
										"0"})						// Indica se o componente é de Tarifa ou de Emitente
						EndIf
					Next nI
				EndIf
			Next nY

			aResult := {}

			If !Empty(aDocCar) 
				aAdd(aTblFrt, aComp)
				aAdd(aTblFrt, cNrNegCmp)

				XFUNBTRB()
				// Simular o frete com a nova transportadora
				aResult := GFECLCFRT(	aAgrFrt,; 				// contem os romaneios de carga para cálculo
										aDocCar,;				// contem os documentos de carga para cálculo
										aTrcDoc,;				// contém os trechos dos documentos de carga
										aItDoc,;				// contém os itens dos documentos de carga
										aTblFrt,; 				// contem a tabela de frete para cálculo
										.F.,; 					// lReal - indica se o cálculo será gravado
										0,;   					// iLogProc - indica quando o log é mostrado: 0-nunca, 1-somente erro, 2-sempre
										.F.,; 					// lTabProv - indica se é cálculo de provisão
										!Empty(aTblFrt[20]),; 	// lParCons - indica se devem ser consideradas tabelas em negociação
										1, .F., .T. )   		// iTpSimul - 0=simulação geral, 1=simulação específica
	
				lTabTemp := aResult[07]
			EndIf
 
			If Len(aResult) > 0 .And. aResult[1]
				// Retorna o valor de frete e o prazo calculado para o documento de carga
				aTRBTCF  := aResult[06]
				aTRBUNC	 := aResult[08]
				aTRBTRE	 := aResult[09]
				aTRBCCF1 := aResult[10]

				For nY := 1 To Len(aAuxDC[nX][3])
					// Verifica se o documento posicionado faz parte do calculo origem para enviar ao novo calculo
					nAuxPos := aScan(aCalcAux[nAux][2],{|x| x[1] == aAuxDC[nX][3][nY][1] .And.;
															x[2] == aAuxDC[nX][3][nY][2] .And.;
															x[3] == aAuxDC[nX][3][nY][3] .And.;
															x[4] == aAuxDC[nX][3][nY][4] .And.;
															x[5] == aAuxDC[nX][3][nY][5] .And.;
															x[6] == aAuxDC[nX][3][nY][6] })
					If nAuxPos > 0
						aResCalc := GFEResCalc({aAuxDC[nX][3][nY][2], aAuxDC[nX][3][nY][3], aAuxDC[nX][3][nY][4], aAuxDC[nX][3][nY][5]}, cCdTransp)
						nVlFrete := aResCalc[1]
						nPrazo   := aResCalc[2]
						dPrazo   := aResCalc[3]

						nPos := aScan(aResult[5], {|x| AllTrim(x[2]) == AllTrim(aAuxDC[nX][3][nY][3]) .And.;
													AllTrim(x[3]) == AllTrim(aAuxDC[nX][3][nY][4]) .And.;
													AllTrim(x[4]) == AllTrim(aAuxDC[nX][3][nY][5]) .And.;
													AllTrim(x[5]) == AllTrim(aAuxDC[nX][3][nY][2])})

						If nPos > 0
							cUnidCalc := aResult[5][nPos][1]
							nContUnid := 0

							For nI := 1 to Len(aResult[5])
								If aResult[5][nI][1] == cUnidCalc
									nContUnid++
								EndIf
							Next nI
						EndIf

						If nContUnid > 1
							// Ratear o valor por documento de carga
							nQtMerc   := nPesoR    := nPesoC    := nVlMerc   := nVolume   := 0
							nQtMerTot := nPesoRTot := nPesoCTot := nVlMerTot := nVolumTot := 0

							For nI := 1 to Len(aResult[5])
								If aResult[5][nI][1] == cUnidCalc
									nPosIt := aScan(aItDoc, {|x| AllTrim(x[1]) == AllTrim(aResult[5][nI][2]) .And. AllTrim(x[2]) == AllTrim(aResult[5][nI][3]) .And.;
																AllTrim(x[3]) == AllTrim(aResult[5][nI][4]) .And. AllTrim(x[4]) == AllTrim(aResult[5][nI][5])})

									If nPosIt > 0
										For nZ := 1 to Len(aItDoc)
											If (aItDoc[nZ,4] + aItDoc[nZ,1] + aItDoc[nZ,2] + aItDoc[nZ,3]) == (aAuxDC[nX][3][nY][2] + aAuxDC[nX][3][nY][3] + aAuxDC[nX][3][nY][4] + aAuxDC[nX][3][nY][5])
												nQtMerc += aItDoc[nZ,8]
												nPesoR  += aItDoc[nZ,9]
												nPesoC  += aItDoc[nZ,10]
												nVlMerc += aItDoc[nZ,12]
												nVolume += aItDoc[nZ,13]
											EndIf

											nQtMerTot += aItDoc[nZ,8]
											nPesoRTot += aItDoc[nZ,9]
											nPesoCTot += aItDoc[nZ,10]
											nVlMerTot += aItDoc[nZ,12]
											nVolumTot += aItDoc[nZ,13]
										Next
									EndIf
								EndIf
							Next nI

							Do Case
								Case cCriRat == "1" // Peso
									If nPesoRTot > nPesoCTot
										nVlFrete := nVlFrete * (nPesoR / nPesoRTot)
									Else
										nVlFrete := nVlFrete * (nPesoC / nPesoCTot)
									EndIf
								Case cCriRat == "2" // Valor
									nVlFrete := nVlFrete * (nVlMerc / nVlMerTot)
								Case cCriRat == "3" // Volume
									nVlFrete := nVlFrete * (nVolume / nVolumTot)
								Case cCriRat == "4" // Qtde
									nVlFrete := nVlFrete * (nQtMerc / nQtMerTot)
							EndCase
						EndIf

						If !lChkCalc
							aAuxDC[nX][3][nY][26] := nVlFrete
							aAuxDC[nX][3][nY][27] := dPrazo
						Else
							aAuxDC[nX][3][nY][28] := nVlFrete
							aAuxDC[nX][3][nY][29] := dPrazo
						EndIf
					EndIf
				Next
			EndIf

			// Eliminar as tabelas temporárias do cálculo
			GFEDelTabCal(.F.)			

			// Limpar os arrays de calculo para o proximo documento de carga
			aAgrFrt := {}
			aDocCar := {}
			aTrcDoc := {}
			aItDoc  := {} 
		Next
	Next

	incProc(STR0185) //"Preparando para exibir"

	// Reativa o model dos campos calculados, atualizando o contador
	oCalc:Activate()
	oCalc:SetValue("COM__TOT01",0)
	oCalc:SetValue("COM__TOT02",0)
	oCalc:SetValue("COM__TOT03",0)
	oCalc:SetValue("COM__TOT04",0)
	// Desativa o model dos campos calculados, visando zerá-los
	oCalc:Deactivate(.T.)

	// Limpa o model, e consequentemente o grid
	oModelSim:Deactivate(.T.)
	oModelSim:Activate()

	// Permite adicionar linhas no Model que alimentará o grid
	dbSelectArea(cAliLDOC)
	ZAP

	For nX := 1 To Len(aAuxDC)
		For nY := 1 To Len(aAuxDC[nX][3])
			RecLock(cAliLDOC, .T.)
				(cAliLDOC)->COM_FILIAL := aAuxDC[nX][3][nY][1]
				(cAliLDOC)->COM_TPDC   := aAuxDC[nX][3][nY][2]
				(cAliLDOC)->COM_EMISDC := aAuxDC[nX][3][nY][3]
				(cAliLDOC)->COM_SERDC  := aAuxDC[nX][3][nY][4]
				(cAliLDOC)->COM_NRDC   := aAuxDC[nX][3][nY][5]
				(cAliLDOC)->COM_TRECHO := aAuxDC[nX][3][nY][6]
				(cAliLDOC)->COM_EMISS  := aAuxDC[nX][3][nY][7]
				(cAliLDOC)->COM_REMET  := aAuxDC[nX][3][nY][8]
				(cAliLDOC)->COM_CIDORI := aAuxDC[nX][3][nY][9]	//Cidade Origem Real
				(cAliLDOC)->COM_UFORI  := aAuxDC[nX][3][nY][10] //UF Origem Real		
				(cAliLDOC)->COM_DEST   := aAuxDC[nX][3][nY][11]
				(cAliLDOC)->COM_CIDDES := aAuxDC[nX][3][nY][12]	//Cidade Destino Real
				(cAliLDOC)->COM_UFDES  := aAuxDC[nX][3][nY][13] //UF Destino Real	
				(cAliLDOC)->COM_CIORSI := aAuxDC[nX][3][nY][14]	//Cidade Origem Simulação
				(cAliLDOC)->COM_UFORSI := aAuxDC[nX][3][nY][15]	//UF Origem Simulação
				(cAliLDOC)->COM_CIDESI := aAuxDC[nX][3][nY][16]	//Cidade Destino Simulação
				(cAliLDOC)->COM_UFDESI := aAuxDC[nX][3][nY][17]	//UF Destino Simulação	
				(cAliLDOC)->COM_NRROM  := aAuxDC[nX][3][nY][18]
				(cAliLDOC)->COM_NMREM  := aAuxDC[nX][3][nY][19] 		
				(cAliLDOC)->COM_NMDES  := aAuxDC[nX][3][nY][20]
				(cAliLDOC)->COM_NMCORI := aAuxDC[nX][3][nY][21]
				(cAliLDOC)->COM_NMCDES := aAuxDC[nX][3][nY][22]
				(cAliLDOC)->COM_NMCORS := aAuxDC[nX][3][nY][23]
				(cAliLDOC)->COM_NMCDSS := aAuxDC[nX][3][nY][24]
				(cAliLDOC)->COM_NRCALC := aAuxDC[nX][3][nY][25]
				(cAliLDOC)->COM_VLFRET := aAuxDC[nX][3][nY][26]
				(cAliLDOC)->COM_PRAZO  := aAuxDC[nX][3][nY][27]
				(cAliLDOC)->COM_VLSIMU := aAuxDC[nX][3][nY][28]
				(cAliLDOC)->COM_PRASIM := aAuxDC[nX][3][nY][29]
				(cAliLDOC)->COM_CNPJ   := aAuxDC[nX][3][nY][30]
				(cAliLDOC)->COM_VLRNF  := aAuxDC[nX][3][nY][31]
				(cAliLDOC)->COM_PESOB  := aAuxDC[nX][3][nY][32]
			(cAliLDOC)->(MSUnlock()) 

			nVlSimu    += aAuxDC[nX][3][nY][28] //Frete Simulado
			nVlFrtReal += aAuxDC[nX][3][nY][26] // Frete Realizado
			nQtdDoc++ // Quantidade de documentos de carga
			If aAuxDC[nX][3][nY][28] > 0
				nQtdDocSim++// Quantidade de documentos de carga simulados com sucesso
			EndIf
		Next
	Next

	// Reativa o model dos campos calculados, atualizando o contador
	oCalc:Activate()
	oCalc:SetValue("COM__TOT01",nQtdDoc)
	oCalc:SetValue("COM__TOT02",nVlFrtReal)
	oCalc:SetValue("COM__TOT03",nVlSimu)
	oCalc:SetValue("COM__TOT04",nQtdDocSim)

	//Atualiza a view como um todo, e não apenas o browse de documentos de carga
	oView:Refresh()
	oBrwDoc:Refresh(.T.)
	
	GFEDelTabCal(.T.)
	
	cFilAnt := cFilLog 

Return .T.


/*------------------------------------------------------------------------
Verifica se dentre os cálculos do array, existe algum usando a tabela informada.
Retorna verdadeiro se pelo menos um dos cálculos usar a tabela.
------------------------------------------------------------------------*/
Static Function ValidCalc(aCalcsDC, cNrTabela)
	Local lTemTab := .F.
	Local nI      := 0
	Local cFiltro := ""
	Local cOr		:= ""
	Local cAliasGWG
	Local cQueryGWG

	if Len(aCalcsDC) == 0
		Return .T.
	EndIf
	
	If !Empty(cNrTabela)
		cFiltro := " AND GWG_FILIAL = '" + xFilial('GWG') + "' "
		
		If Len(aCalcsDC) > 0
			cFiltro += " AND ( "
		EndIf
		
		For nI := 1 To Len(aCalcsDC)
			
			If nI < Len(aCalcsDC)
				cOr := " OR "
			Else
				cOr := ""
			EndIf
			
			cFiltro += " (GWG_NRCALC = '" + aCalcsDC[nI] + "' AND GWG_NRTAB = '" + cNrTabela+ "')" + cOr
		Next nI

		If Len(aCalcsDC) > 0
			cFiltro += " )"
		EndIf
			
		cQueryGWG := "SELECT GWG.GWG_FILIAL "
		cQueryGWG += "FROM " + RetSqlName("GWG") + " GWG "
		cQueryGWG += "WHERE D_E_L_E_T_ = '' " + cFiltro
		cAliasGWG := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cQueryGWG)),cAliasGWG,.F.,.T.)
		
		If !(cAliasGWG)->(Eof())
				lTemTab := .T.
			EndIf

		(cAliasGWG)->(dbCloseArea())
	Else
		lTemTab := .T.
	EndIf

Return lTemTab


/*------------------------------------------------------------------------
Elimina todas as tabelas temporárias geradas pela rotina de calculo
------------------------------------------------------------------------*/
Static Function GFEDelTabCal(lDelArray)
	if lTabTemp
		GFEDelTab(cTRBDOC)
		GFEDelTab(cTRBAGRU)
		GFEDelTab(cTRBCCF)
		GFEDelTab(cTRBITE)
		GFEDelTab(cTRBTRE)
		GFEDelTab(cTRBSIM)
		GFEDelTab(cTRBUNC)
		GFEDelTab(cTRBTCF)
	EndIf
	if lDelArray
		IIF(aTRBCCF1==NIL,,aSize(aTRBCCF1,0))
		IIF(aTRBTRE ==NIL,,aSize(aTRBTRE ,0))
		IIF(aTRBUNC ==NIL,,aSize(aTRBUNC ,0))
		IIF(aTRBTCF ==NIL,,aSize(aTRBTCF ,0))
		
		aTRBCCF3 := Nil
		aTRBTRE  := Nil
		aTRBUNC  := Nil
		aTRBTCF  := Nil
		
		IIF(_aCmpCCF ==NIL,,aSize(_aCmpCCF, 0 ))
		IIF(_aCmpTRE ==NIL,,aSize(_aCmpTRE, 0 ))
		IIF(_aCmpUNC ==NIL,,aSize(_aCmpUNC, 0 ))
		IIF(_aCmpTCF ==NIL,,aSize(_aCmpTCF, 0 ))
		
		_aCmpCCF := Nil
		_aCmpTRE := Nil
		_aCmpUNC := Nil
		_aCmpTCF := Nil
	EndIf

Return NIL


/*------------------------------------------------------------------------
Muda os destinos dos trechos das notas, deixando apenas um trecho que segue
até o destino da mercadoria, ignorando os redespachos.
------------------------------------------------------------------------*/
Static Function GFEMudaDest(aTrcDoc)
	Local aTrechoDC := {}
	Local cChaveDC  := "", cRomaneio := "", cCidEnt := "", cCdDest := ""
	Local nI        := 0

	// Ordena os registros para facilitar o tratamento
	aSort(aTrcDoc,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5]})	

	For nI := 1 to len(aTrcDoc)
		// Considera apenas o 1o trecho de cada documento de carga, já que o redespacho não será mantido
		If cChaveDC != aTrcDoc[nI,4]+aTrcDoc[nI,1]+aTrcDoc[nI,2]+aTrcDoc[nI,3] 
			// Ajusta o destino do trecho para ser igual a
			// 1. Cidade de destino do romaneio, se informada
			// 2. Cidade de entrega do documento de carga, se informada
			// 3. Cidade do destinatário do documento de carga						
			aAdd(aTrechoDC,aClone(aTrcDoc[nI]))
			cRomaneio := Posicione("GW1",1,xFilial("GW1")+aTrcDoc[nI,4]+aTrcDoc[nI,1]+aTrcDoc[nI,2]+aTrcDoc[nI,3],"GW1_NRROM" )
			cCidEnt   := Posicione("GW1",1,xFilial("GW1")+aTrcDoc[nI,4]+aTrcDoc[nI,1]+aTrcDoc[nI,2]+aTrcDoc[nI,3],"GW1_ENTNRC")
			cCdDest   := Posicione("GW1",1,xFilial("GW1")+aTrcDoc[nI,4]+aTrcDoc[nI,1]+aTrcDoc[nI,2]+aTrcDoc[nI,3],"GW1_CDDEST")
			// Este trecho se prevalece do fato do array ser um endereço de memória
			// Sendo assim, aTail retorna o endereço de memória de um array cuja posição 7 será modificada
			If !Empty(cRomaneio) .AND. !Empty(Posicione("GWN",1,xFilial("GWN")+cRomaneio,"GWN_NRCIDD"))
				aTail(aTrechoDC)[7] := Posicione("GWN",1,xFilial("GWN")+cRomaneio,"GWN_NRCIDD")
			ElseIf !Empty(cCidEnt) .AND. Val(cCidEnt) != 0
				aTail(aTrechoDC)[7] := cCidEnt
			Else					
				aTail(aTrechoDC)[7] := Posicione("GU3",1,xFilial("GU3")+cCdDest,"GU3_NRCID")
			EndIf								
		EndIf
		cChaveDC := aTrcDoc[nI,4]+aTrcDoc[nI,1]+aTrcDoc[nI,2]+aTrcDoc[nI,3]
	Next nI	

	aTrcDoc := aTrechoDC

Return NIL


/*------------------------------------------------------------------------
Retorna o valor de frete e o prazo calculados pela rotina de calculo
de frete 
------------------------------------------------------------------------*/
Static Function GFEResCalc(aChaveDC, cCdTransp)
  	Local ddtprev
	Local nVlFrete := 0
	Local nPrazo   := 0
  	Local dDataRef := Date()	
  	Local cHoraRef := Substr(Time(), 1, 5)

	// Para cada documento de carga, obter o cálculo correspondente

	nVlFrete := 0
	GFEXFB_BORDER(lTabTemp,cTRBTRE,02,07)
	If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 07,aChaveDC)
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE, 07) .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"CDTPDC") == aChaveDC[1];
														 	.And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"EMISDC") == aChaveDC[2];
															.And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SERDC")  == aChaveDC[3];
															.And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRDC")   == aChaveDC[4]
			If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"CDTRP") == cCdTransp
				// Obtem o prazo
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,05)
				If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 05,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRCALC")})
					nPrazo := 0
					While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF, 05) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRCALC")							
						nPrazo := If(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"PRAZO") > nPrazo,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"PRAZO"),nPrazo)							
	
						GV9->( dbSetOrder(1) )
						GV9->( msSeek(xFilial("GV9") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRNEG")) )
							
						GV6->( dbSetOrder(1) )
						GV6->( msSeek(xFilial("GV6")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDFXTV") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRROTA")) )
					
						ddtprev := PrevDtEnt(dDataRef, cHoraRef, GV6->GV6_CDEMIT, GV6->GV6_NRTAB, GV6->GV6_NRNEG, GV6->GV6_CDFXTV, GV6->GV6_NRROTA)[1]
						GFEXFB_8SKIP(lTabTemp, cTRBTCF, 05)
					EndDo
				EndIf				

				// Soma os valores de frete
				GFEXFB_BORDER(lTabTemp,cTRBCCF,01,09)
				If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 09,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRCALC")}) //msSeek()
					While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 09) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRCALC")
						
						nVlFrete += If(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"TOTFRE") == "1", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR"), 0)
						GFEXFB_8SKIP(lTabTemp, cTRBCCF, 09)

					EndDo

					Exit
				EndIf
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 07)
		EndDo
	EndIf

Return {nVlFrete,nPrazo,ddtprev}


/*------------------------------------------------------------------------
Retorna um array com o número dos cálculos aos quais o documento de carga está 
relacionado.
Cálculos agrupados serão desconsiderados.
Parâmetros de entrada:
cChaveDc  contem os campos chave de um documento de carga na seguinte seqüência:
Tipo Documento de Carga + Emissor DC + Serie DC + Numero DC
------------------------------------------------------------------------*/
Static Function GFETemCalc(aChaveDC)
	Local aCalcs  := {}
	Local cQueryGWH
	Local cAliasGWH  

	cQueryGWH := " SELECT GWH.GWH_NRCALC "
	cQueryGWH += " FROM " + RetSqlName("GWH") + " GWH "
	cQueryGWH += " JOIN " + RetSqlName("GWF") + " GWF ON (GWF.GWF_FILIAL = '" + xFilial("GWF") + "' AND GWF.GWF_NRCALC = GWH.GWH_NRCALC) "
	cQueryGWH += " WHERE GWF.D_E_L_E_T_ = ' '  "
	cQueryGWH += " AND GWH.D_E_L_E_T_ = ' ' "
	cQueryGWH += " AND GWF.GWF_AGRUP <> '1' "
	cQueryGWH += " AND GWF.GWF_TPCALC IN ('1','6') "
	cQueryGWH += " AND GWH.GWH_FILIAL = '"+xFilial("GWH")+"' "
	cQueryGWH += " AND GWH.GWH_CDTPDC = '" + aChaveDC[2] + "' "
	cQueryGWH += " AND GWH.GWH_EMISDC = '" + aChaveDC[3] + "' "
	cQueryGWH += " AND GWH.GWH_SERDC  = '" + aChaveDC[4] + "' "
	cQueryGWH += " AND GWH.GWH_NRDC   = '" + aChaveDC[5] + "' "

	cAliasGWH := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cQueryGWH)),cAliasGWH,.F.,.T.)
	
	While ( (cAliasGWH)->(!Eof()) )
		aAdd(aCalcs,(cAliasGWH)->GWH_NRCALC)	// Armazenar os cálculos para obter os outros documentos de carga
		(cAliasGWH)->(dbSkip())
	EndDo

	(cAliasGWH)->(dbCloseArea())

Return aCalcs   


/*------------------------------------------------------------------------
Carregar array de Agrupadores de documentos de carga
------------------------------------------------------------------------*/
Static Function GFEArrAgr(cNrRom,aAgrFrt)

	Default aAgrFrt := {}

	if aScan(aAgrFrt,{|x| x[1] == cNrRom}) == 0
		GWN->(dbSetOrder(1))
		if GWN->(dbSeek(xFilial("GWN")+cNrRom))
			aAdd(aAgrFrt,{	GWN->GWN_NRROM ,;	//Numero do Agrupador
							GWN->GWN_CDTRP ,;	//Transportador
							GWN->GWN_CDTPVC,;	//Tipo de Veiculo
							GWN->GWN_CDCLFR,;	//Classificacao de Frete
							GWN->GWN_CDTPOP,;	//Tipo de Operacao
							GWN->GWN_DISTAN,;	//Distancia Percorrida
							GWN->GWN_NRCIDD,;	//Cidade Destino
							GWN->GWN_CEPD,;		//CEP Destino
							"0"})				// DELETE
		EndIf
	EndIf

Return aAgrFrt


/*------------------------------------------------------------------------
Carregar array de Documentos de Carga
------------------------------------------------------------------------*/
Static Function GFEArrDoc(aChaveDC,aDocCar)

	Local nQtdeUnit := 0
	Local cQuery
	Local lFound := .F.
	Local cChaveDC := aChaveDC[1] + aChaveDC[2] + aChaveDC[3] + aChaveDC[4] + aChaveDC[5]
	Local aStrDoc := GetAStr("GWB","GWB_QTDE")
	
	Static cAlQryDoc  := GetNextAlias()

	Default aDocCar := {}

	GW1->(dbSetOrder(1))
	If GW1->(&(IndexKey())) != cChaveDC
		lFound := GW1->(msSeek(cChaveDC))
	Else
		lFound := .T.
	EndIf
	
	if lFound 

		// Obtem a quantidade de unitizadores (embalagens) do documento de carga
				
		cQuery := "SELECT SUM(GWB_QTDE) GWB_QTDE"+;
				"	FROM " + RetSqlName("GWB")+;
				"	WHERE D_E_L_E_T_ = ' '"+;
				"	AND GWB_FILIAL = '" + xFilial("GWB") + "'"+;
				"	AND GWB_CDTPDC = '" + GW1->GW1_CDTPDC + "'"+;
				"	AND GWB_EMISDC = '" + GW1->GW1_EMISDC + "'"+;
				"	AND GWB_SERDC  = '" + GW1->GW1_SERDC  + "'"+;
				"	AND GWB_NRDC   = '" + GW1->GW1_NRDC	 + "'"
		
		MPSysOpenQuery(ChangeQuery(cQuery),cAlQryDoc,aStrDoc)
		
		If Empty((cAlQryDoc)->GWB_QTDE)
			nQtdeUnit := 0
		Else
			nQtdeUnit := (cAlQryDoc)->GWB_QTDE
		EndIf
		
		aAdd(aDocCar, {GW1->GW1_EMISDC,; //Emitente do Documento
		GW1->GW1_SERDC,;  //Serie do Documento
		GW1->GW1_NRDC,;   //Numero do Documento
		GW1->GW1_CDTPDC,; //Tipo do Documento
		GW1->GW1_CDREM,;  //Remetente do Documento
		GW1->GW1_CDDEST,; //Destinatario do Documento
		'',; //Endereco de Entrega
		'',; //Bairro de entrega
		'',; //Cidade de Entrega
		'',; //CEP de Entrega
		'',;  //Região de destino
		GW1->GW1_TPFRET,; //Tipo de Frete
		GW1->GW1_ICMSDC,; //ICMS?
		GW1->GW1_USO,;    //Finalidade da mercadoria
		GW1->GW1_CARREG,; //Número do carregamento
		GW1->GW1_NRROM,;  //Numero do Agrupador
		MAX(nQtdeUnit,GW1->GW1_QTVOL)}) //Quantidade de Unitizadores
		(cAlQryDoc)->(dbClosearea())
	EndIf

Return aDocCar

Static Function GetAStr(cAlias,cCampos)
	Local aStr
	Local aStruct := {}
	Local nX
	
	If Select('SX2') > 0
		aStr := (cAlias)->(dbStruct())
		For nX := 1 To Len(aStr)
			If aStr[nX][2] != "C" .And. aStr[nX][1] $ 'cCampos'
				aAdd(aStruct,aClone(aStr[nX]))
			EndIf
		Next nX
	EndIf
Return aStruct
/*------------------------------------------------------------------------
Carregar array de Itens do Documento de Carga
------------------------------------------------------------------------*/
Static Function GFEArrIt(aChaveDC, aItDoc) 
	Static cAlQryIt  := GetNextAlias()
	
	Local cQuery := ""
	Local cChaveDC := aChaveDC[1] + aChaveDC[2] + aChaveDC[3] + aChaveDC[4] + aChaveDC[5]
	
	Default aItDoc := {}
	
	GW1->(dbSetOrder(1))
	If GW1->(&(IndexKey())) != cChaveDC
		GW1->(msSeek(cChaveDC))
	EndIf
		
	cQuery := "SELECT GW8_ITEM,"+;  
				"GW8_CDCLFR,"+;
				"GW8_TPITEM,"+;
				"GW8_QTDE,"+;  
				"GW8_PESOR,"+; 
				"GW8_PESOC,"+; 
				"GW8_QTDALT,"+;
				"GW8_VALOR,"+; 
				"GW8_VOLUME,"+;
				"GW8_TRIBP"+;
				"	FROM " + RetSqlName("GW8")+;
				"	WHERE D_E_L_E_T_ = ' '"+;
				"	AND GW8_FILIAL = '" + xFilial("GW8") + "'"+;
				"	AND GW8_CDTPDC = '" + GW1->GW1_CDTPDC + "'"+;
				"	AND GW8_EMISDC = '" + GW1->GW1_EMISDC + "'"+;
				"	AND GW8_SERDC  = '" + GW1->GW1_SERDC  + "'"+;
				"	AND GW8_NRDC   = '" + GW1->GW1_NRDC	 + "'"
	
	aStrIt := GetAStr("GW8","GW8_ITEM,"+;  
				"GW8_CDCLFR,"+;
				"GW8_TPITEM,"+;
				"GW8_QTDE,"+;  
				"GW8_PESOR,"+; 
				"GW8_PESOC,"+; 
				"GW8_QTDALT,"+;
				"GW8_VALOR,"+; 
				"GW8_VOLUME,"+;
				"GW8_TRIBP")
	
	If Empty(aStrIt)
		aStrIt := GetAStr("GW8","GW8_ITEM,"+;  
				"GW8_CDCLFR,"+;
				"GW8_TPITEM,"+;
				"GW8_QTDE,"+;  
				"GW8_PESOR,"+; 
				"GW8_PESOC,"+; 
				"GW8_QTDALT,"+;
				"GW8_VALOR,"+; 
				"GW8_VOLUME,"+;
				"GW8_TRIBP")
	EndIf
	
	MPSysOpenQuery(ChangeQuery(cQuery),cAlQryIt,aStrIt)
	
	While (cAlQryIt)->(!Eof())

		aAdd(aItDoc, {;
		GW1->GW1_EMISDC,; //Emitente do Documento
		GW1->GW1_SERDC,;  //Serie do Documento
		GW1->GW1_NRDC,;   //Numero do Documento
		GW1->GW1_CDTPDC,; //Tipo do Documento
		(cAlQryIt)->GW8_ITEM,;   //Item
		(cAlQryIt)->GW8_CDCLFR,; //Classificacao de Frete
		(cAlQryIt)->GW8_TPITEM,; //Classificacao de Frete
		(cAlQryIt)->GW8_QTDE,;   //Quantidade do Item
		(cAlQryIt)->GW8_PESOR,;  //Peso do Item
		(cAlQryIt)->GW8_PESOC,;  //Peso Cubado
		(cAlQryIt)->GW8_QTDALT,; //Quantidade/Peso Alternativo
		(cAlQryIt)->GW8_VALOR,;  //Valor do Item
		(cAlQryIt)->GW8_VOLUME,; //Volume ocupado (m3)
		(cAlQryIt)->GW8_TRIBP})  //Tributa PIS?

		(cAlQryIt)->(dbSkip())
	EndDo
	
	(cAlQryIt)->(dbCloseArea())

Return aItDoc


/*------------------------------------------------------------------------
Carregar array de Trechos do documento de Carga
------------------------------------------------------------------------*/
Static Function GFEArrTrc(aChaveDC, aTrcDoc, cTrecho, lXFBGWUDC)
	Static cAlQryTrc := GetNextAlias()
	
	Local cQuery := ""
	Local cChaveDC := aChaveDC[1] + aChaveDC[2] + aChaveDC[3] + aChaveDC[4] + aChaveDC[5]
	
	Default aTrcDoc := {}
	Default cTrecho := '' 
	Default lXFBGWUDC := .F.

	if lXFBGWUDC
		aTrcDoc := XFBGWUDC(,aChaveDC[1], aChaveDC[2], aChaveDC[3], aChaveDC[4], aChaveDC[5],cTrecho)
		Return aTrcDoc
	EndIf
	
	GW1->(dbSetOrder(1))
	If GW1->(&(IndexKey())) != cChaveDC
		GW1->(msSeek(cChaveDC))
	EndIf

	if Empty(cTrecho) == .F.
		cTrecho := " AND GWU_SEQ = '" + cTrecho + "'"
	EndIf
		
	cQuery := "SELECT GWU_SEQ,"+;   
				"GWU_CDTRP,"+; 
				"GWU_NRCIDD,"+;
				"GWU_CDTPVC,"+;
				"GWU_PAGAR"+; 
				"	FROM " + RetSqlName("GWU")+;
				"	WHERE D_E_L_E_T_ = ' '"+;
				"	AND GWU_FILIAL = '" + xFilial("GWU") + "'"+;
				"	AND GWU_CDTPDC = '" + GW1->GW1_CDTPDC + "'"+;
				"	AND GWU_EMISDC = '" + GW1->GW1_EMISDC + "'"+;
				"	AND GWU_SERDC  = '" + GW1->GW1_SERDC  + "'"+;
				"	AND GWU_NRDC   = '" + GW1->GW1_NRDC	 + "'"+;
				cTrecho
	
	
	aStrTrc := GetAStr("GWU","GWU_SEQ,"+;   
				"GWU_CDTRP,"+; 
				"GWU_NRCIDD,"+;
				"GWU_CDTPVC,"+;
				"GWU_PAGAR")
	
	If Empty(aStrTrc)
		aStrTrc := GetAStr("GWU","GWU_SEQ,"+;   
				"GWU_CDTRP,"+; 
				"GWU_NRCIDD,"+;
				"GWU_CDTPVC,"+;
				"GWU_PAGAR")
	EndIf
				
	MPSysOpenQuery(ChangeQuery(cQuery),cAlQryTrc,aStrTrc)
	
	While (cAlQryTrc)->(!Eof())

		aAdd(aTrcDoc, {;
		GW1->GW1_EMISDC,; //Emitente do Documento
		GW1->GW1_SERDC,;  //Serie do Documento
		GW1->GW1_NRDC,;   //Numero do Documento
		GW1->GW1_CDTPDC,; //Tipo do Documento
		(cAlQryTrc)->GWU_SEQ,;    //Sequencia do Trecho
		(cAlQryTrc)->GWU_CDTRP,;  //Transportador do Trecho
		(cAlQryTrc)->GWU_NRCIDD,; //Cidade Destino
		(cAlQryTrc)->GWU_CDTPVC,; //Tipo de Veiculo do Trecho
		(cAlQryTrc)->GWU_PAGAR})  //Pagar trecho ou nao  

		(cAlQryTrc)->(dbSkip())					  
	EndDo
	
	(cAlQryTrc)->(dbCloseArea())	  

Return aTrcDoc


/*--------------------------------------------------------------------
Executa a simulação do frete para o documento de carga selecionado
--------------------------------------------------------------------*/
Static Function GFEX061SIM()

	Local oModelPai := FWModelActive()
	Local oModelSim := oModelPai:GetModel("DETAIL_02")
	Local oView     := FwViewActive()
	Local cCdTransp := FwFldGet("GWU_TRP")
	Local aResult   := {}, aDocCar := {}, aTrcDoc := {}, aItDoc := {}, aDadosSim := {}//, aAux := {}
	Local aAgrFrt := {{ "", "" , "" , "" , "", 0, "", "",""}}
	Local cChaveDC  := "", cNrRom := "", cChaveDCAux := ""
	Local nI        := 0
	Local nVlFrtUni := 0, nVlFrtVal := 0, nVlTaxas := 0, nVlPedagio := 0
	Local lFirst	:= .T.
	Local aChaveDC	:= {}
	Local aChaveDCAux := {}
	Local lXFBGWUDC := FindFunction("XFBGWUDC")
	Local nTamTrp := TamSx3("GWU_CDTRP")[1]
	Local aTotFrt

/*************************************************************/
	Private lTabTemp
	Private aTRBCCF1 := {} // Indice 3
	
	Private idpCCF := 1 // posição do array cTRBCCF
	Private idxCCF := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {	"NRCALC",; // 1
							"CDCLFR",; // 2
							"CDTPOP",; // 3
							"SEQ"   ,; // 4
							"CDCOMP",; // 5
							"CATVAL",; // 6
							"QTDE"  ,; // 7
							"VALOR" ,; // 8
							"TOTFRE",; // 9
							"BASIMP",; // 10
							"BAPICO",; // 11
							"FREMIN",; // 12
							"IDMIN" ,; // 13
							"VLFRMI",; // 14
							"DELETE"}  // 15
/*************************************************************/
	Private aTRBTRE := {} // Indice 1
	Private idpTRE := 1 // posição do array cTRBTRE
	Private idxTRE := 1 // Indice  da array cTRBTRE
	Private _aCmpTRE := {"EMISDC",; // 1
						 "SERDC" ,; // 2
						 "NRDC"  ,; // 3
						 "CDTPDC",; // 4
						 "SEQ"   ,; // 5
						 "CDTRP" ,; // 6
						 "NRCIDD",; // 7
						 "CDTPVC",; // 8
						 "PAGAR" ,; // 9
						 "NRCIDO",; // 10
						 "CEPO"  ,; // 11
						 "CEPD"  ,; // 12
						 "CDCLFR",; // 13
						 "CDTPOP",; // 14
						 "ORIGEM",; // 15
						 "DESTIN",; // 16
						 "NRGRUP",; // 17
						 "NRCALC",; // 18
						 "DELETE" } // 19
/*************************************************************/
	Private aTRBUNC := {} // Indice 1

	Private idpUNC := 1 // posição do array cTRBUNC
	Private idxUNC := 1 // Indice  da array cTRBUNC
	Private _aCmpUNC := {"NRCALC",; // 1
						 "TIPO"  ,; // 2
						 "FINALI",; // 3
						 "DTPREN",; // 4
						 "HRPREN",; // 5
						 "TPTRIB",; // 6
						 "BASICM",; // 7
						 "PCICMS",; // 8
						 "VLICMS",; // 9
						 "ICMRET",; // 10
						 "BASISS",; // 11
						 "PCISS" ,; // 12
						 "VLISS" ,; // 13
						 "BAPICO",; // 14
						 "VLPIS" ,; // 15
						 "VLCOFI",; // 16
						 "PCREIC",; // 17
						 "VALTAB",; // 18
						 "NRAGRU",; // 19
						 "IDFRVI",; // 20
						 "SEQTRE",; // 21
						 "CALBAS",; // 22
						 "ADICIS",; // 23
						 "CHVGWU",; // 24
						 "DELETE"}  // 25
/*************************************************************/
	Private aTRBTCF := {} // Indice 1

	Private idpTCF := 1 // posição do array de Documentos de carga cTRBTCF
	Private idxTCF := 1 // Indice da array de Documentos de carga cTRBTCF

	Private _aCmpTCF := {"NRCALC",; //1
						 "CDCLFR",; //2
						 "CDTPOP",; //3
						 "SEQ"   ,; //4
						 "DTVIGE",; //5
						 "ITEM"  ,; //6
						 "CDTRP" ,; //7
						 "NRTAB" ,; //8
						 "NRNEG" ,; //9
						 "CDFXTV",; //10
						 "CDTPVC",; //11
						 "NRROTA",; //12
						 "QTCALC",; //13
						 "QTDE"  ,; //14
						 "PESOR" ,; //15
						 "PESCUB",; //16
						 "QTDALT",; //17
						 "VALOR" ,; //18
						 "VOLUME",; //19
						 "NRGRUP",; //20
						 "CDEMIT",; //21
						 "PEDROM",; //22
						 "PESPED",; //23
						 "PRAZO" ,;  //24
						 "DELETE"}

/*************************************************************/
/*************************************************************/
/*************************************************************/

	oModelSim:ClearData()
	oModelSim:SetNoInsertLine(.F.)
	oModelSim:SetNoDeleteLine(.T.)

//	//Atualiza a view como um todo, e não apenas o browse de documentos de carga
//	oView:Refresh()
//	oBrwDoc:Refresh(.T.)
	
	lFirst := .T.

	(cAliLDOC)->(dbSetOrder(2))
	(cAliLDOC)->(dbGoTop())
	While !(cAliLDOC)->( EOF() )
		If (cAliLDOC)->OK == oBrwDoc:Mark()

			ProcRegua(0)
			IncProc(STR0188) //"Preparando dados para cálculo"
			
			cFilAnt := (cAliLDOC)->COM_FILIAL

			cChaveDc :=  (cAliLDOC)->COM_TPDC + (cAliLDOC)->COM_EMISDC + (cAliLDOC)->COM_SERDC + (cAliLDOC)->COM_NRDC //aRetMbrLin[1]
			aChaveDC := {(cAliLDOC)->COM_FILIAL,  (cAliLDOC)->COM_TPDC,  (cAliLDOC)->COM_EMISDC,  (cAliLDOC)->COM_SERDC,  (cAliLDOC)->COM_NRDC}

			cNrRom  := (cAliLDOC)->COM_NRROM
			cNrTrec := (cAliLDOC)->COM_TRECHO
			cNrCalc := (cAliLDOC)->COM_NRCALC

			// Gerar array do documentos de carga
			aDocCar := GFEArrDoc(aChaveDC)

			// Carregar array de Itens do Documento de Carga
			aItDoc := GFEArrIt(aChaveDC)

			// Carregar array de Trechos do documento de Carga
			aTrcDoc := GFEArrTrc(aChaveDC,,cNrTrec,lXFBGWUDC)

			if !Empty(cNrRom)
				aAgrFrt := GFEArrAgr(cNrRom)
			EndIf

			//Retorna um array com os cálculos do documento de carga
			aCalcsDC := GFETemCalc(aChaveDC)

			// Passa por todos os cálculos do documento de carga
			For nI := 1 to len(aCalcsDC)

				// Se o cálculo for do transportador informado na seleção...
				if Posicione("GWF",1,xFilial("GWF")+aCalcsDC[nI],"GWF_TRANSP") == cCdTransp

					// Obtem as outras notas do cálculo
					GWH->(dbSetOrder(01))
					if GWH->(msSeek(xFilial("GWH")+aCalcsDC[nI]))
						While GWH->(!Eof()) .AND. GWH->GWH_FILIAL == xFilial("GWH") .AND. GWH->GWH_NRCALC == aCalcsDC[nI]
							cChaveDCAux := GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC
							aChaveDCAux := {GWH->GWH_FILIAL,  GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC}

							// Considera apenas os documentos de carga que não foram inseridos ainda nos arrays
							If cChaveDCAux <> cChaveDC .AND. aScan(aDocCar,{|x| x[1]+x[5]+x[2]+x[3]+x[4] == cChaveDCAux}) == 0

								// Carregar array de Documentos de Carga
								aDocCar := GFEArrDoc(aChaveDCAux, aDocCar)

								// Carregar array de Itens do Documento de Carga
								aItDoc := GFEArrIt(aChaveDCAux, aItDoc)

								// Carregar array de Trechos do documento de Carga
								aTrcDoc := GFEArrTrc(aChaveDCAux, aTrcDoc,cNrTrec,lXFBGWUDC)

								if !Empty(Posicione("GW1",1,xFilial("GW1")+cChaveDCAux,"GW1_NRROM"))
									// Carregar array de Agrupadores dos documentos de carga
									aAgrFrt := GFEArrAgr(Posicione("GW1",1,xFilial("GW1")+cChaveDCAux,"GW1_NRROM"), aAgrFrt)
								EndIf
							EndIf

							GWH->(dbSkip())
						EndDo		
					EndIf

					// Sai do loop de calculos do documento de carga
					Exit
				EndIf
			Next nI

			if FwFldGet("GWU_MANRED") == "2" 	// Não mantem redespacho
				// Altera os destinos do trechos ignorando os redespachos
				GFEMudaDest(@aTrcDoc)
			EndIf

			// Retira os transportadores informados no romaneio, se houver, e nos trechos
			// Desta forma, a rotina irá selecionar os transportadores por conta própria
			If !Empty(aAgrFrt)
				For nI := 1 to len(aAgrFrt)
					aAgrFrt[nI,2] := PadR("",nTamTrp)
				Next nI
			EndIf
			If !Empty(aTrcDoc)
				For nI := 1 to len(aTrcDoc)
					aTrcDoc[nI,6] := PadR("",nTamTrp)
				Next nI
			EndIf

			IncProc(STR0189) //"Realizando cálculo de frete"
			XFUNBTRB()
			aResult := GFECLCFRT( 	aAgrFrt,; // contem os romaneios de carga para cálculo
									aDocCar,;	// contem os documentos de carga para cálculo
									aTrcDoc,;	// contém os trechos dos documentos de carga
									aItDoc ,;	// contém os itens dos documentos de carga
									,;        // aTblFrt - contem a tabela de frete para cálculo
									.F.,;     // lReal - indica se o cálculo será gravado
									0,;	    // iLogProc - indica quando o log é mostrado: 0-nunca, 1-somente erro, 2-sempre
									.F.,;     // lTabProv - indica se é cálculo de provisão
									.F.,;     // lParCons - indica se devem ser consideradas tabelas em negociação
									0 )       // iTpSimul - 0=simulação geral, 1=simulação específica

			lTabTemp	:= aResult[07]

			If aResult[1]	// Cálculo realizado com sucesso
				aTRBTCF 	:= aResult[06]
				aTRBUNC		:= aResult[08]
				aTRBTRE		:= aResult[09]
				aTRBCCF1	:= aResult[10]
				
				aSort(aTRBCCF1,,,{|x,y| x[01]+x[02]+x[03]+x[04]       < y[01]+y[02]+y[03]+y[04]})
				aSort(aTRBTRE ,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
				
				IncProc(STR0190) //"Totalizando valores de cálculo"

				aDadosSim := {}
				GFEXFB_BORDER(lTabTemp,cTRBTRE,02,07)
				if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 07,{aChaveDC[2],aChaveDC[3],aChaveDC[4],aChaveDC[5]})
					While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE, 07) .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"CDTPDC") == aChaveDC[2] .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"EMISDC") == aChaveDC[3] .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SERDC")  == aChaveDC[4] .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"NRDC")   == aChaveDC[5] 
						If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SEQ")     == cNrTrec				                    
							GFEXFB_BORDER(lTabTemp,cTRBUNC,01,06)
							GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC, 06)
							While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC, 06)
								if GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"SEQTRE") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SEQ")

									GFEXFB_BORDER(lTabTemp,cTRBTCF,01,05)
									GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 05,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC")})
									While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF, 05) .AND. ;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC")

										// Percorrer os componentes e somar os valores
										nVlFrete   := 0
										nVlFrtUni  := 0
										nVlFrtVal  := 0
										nVlTaxas   := 0
										nVlPedagio := 0
										GFEXFB_BORDER(lTabTemp,cTRBCCF,01,09)
										If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 09,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDTPOP")})
											While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 09) .AND. ;
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC") .AND. ;
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDCLFR") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDCLFR") .AND. ;
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDTPOP") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDTPOP")
												If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"TOTFRE") == "1"
													nVlFrete += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
													cCatVal := Posicione("GV2",1,xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDCOMP"),"GV2_CATVAL")
													Do Case
														Case cCatVal == "1"	// Frete Unidade
															nVlFrtUni += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
														Case cCatVal == "2"	// Frete Valor
															nVlFrtVal += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
														Case cCatVal == "3"	// Taxas
															nVlTaxas += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
														Case cCatVal == "4" // Pedagio
															nVlPedagio += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
													EndCase
												EndIf
												GFEXFB_8SKIP(lTabTemp, cTRBCCF, 09)
											EndDo
										EndIf					

										nPos := aScan(aDadosSim,{|x| x[1]+x[2]+x[3]+x[4] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC") + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SEQ")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRTAB")})
										if nPos == 0
											aTotFrt := GFEValCalc(cNrCalc)
											aAdd(aDadosSim,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC"),; // Sequencia do cálculo simulado. Pode haver mais de um por transportador
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 07,"SEQ"),;	// Trecho do documento de carga
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"CDTRP"),;	// Transportador do frete simulado
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 05,"NRTAB"),;	// Tabela de frete usada na simulação
															aTotFrt[1],;	// Valor de frete real
															nVlFrete,;	// Valor de frete simulado
															aTotFrt[3],;	// "Ad-valorem" real
															nVlFrtVal,;	// "Ad-valorem" simulado
															aTotFrt[2],;	// Frete Unidade real
															nVlFrtUni,;	// Frete Unidade simulado
															aTotFrt[4],;	// Taxas real
															nVlTaxas,;	// Taxas simulado
															aTotFrt[5],;	// Pedagio real
															nVlPedagio}) // Pedagio simulado
										Else
											aDadosSim[nPos,6]  += nVlFrete
											aDadosSim[nPos,8]  += nVlFrtVal
											aDadosSim[nPos,10] += nVlFrtUni
											aDadosSim[nPos,12] += nVlTaxas
											aDadosSim[nPos,14] += nVlPedagio
										EndIf
										GFEXFB_8SKIP(lTabTemp, cTRBTCF, 05)
									EndDo

									// Soma os componentes corresponentes à taxa na última linha
									GFEXFB_BORDER(lTabTemp,cTRBCCF,01,09)
									If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 09,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC")})
										While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 09) .AND. ;
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 06,"NRCALC")
											If 	Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDCLFR")) .AND. ;
												Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDCLFR")) .AND. ;
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"TOTFRE") == "1"
												
												aTail(aDadosSim)[6] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
												cCatVal := Posicione("GV2",1,xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"CDCOMP"),"GV2_CATVAL")
												Do Case
													Case cCatVal == "1"	// Frete Unidade
														aTail(aDadosSim)[10] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
													Case cCatVal == "2"	// Frete Valor
														aTail(aDadosSim)[8] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
													Case cCatVal == "3"	// Taxas
														aTail(aDadosSim)[12] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
													Case cCatVal == "4" // Pedagio
														aTail(aDadosSim)[14] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 09,"VALOR")
												EndCase
											EndIf
											GFEXFB_8SKIP(lTabTemp, cTRBCCF, 09)
										EndDo
									EndIf
								EndIf
								GFEXFB_8SKIP(lTabTemp, cTRBUNC, 06)
							EndDo
							Exit	// Encontrou o calculo correspondente ao trecho
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBTRE, 07)
					EndDo
				EndIf

				IncProc(STR0191) //"Preparando para exibir"

				For nI := 1 to len(aDadosSim)

					If lFirst
						lFirst := .F.
						oModelSim:GoLine(1)
					Else
						oModelSim:AddLine()
					EndIf

					oModelSim:SetValue("SIM_FILIAL",(cAliLDOC)->COM_FILIAL) // aRetMbrLin[3])
					oModelSim:SetValue("SIM_CDTPDC",(cAliLDOC)->COM_TPDC)   // aRetMbrLin[3])
					oModelSim:SetValue("SIM_EMISDC",(cAliLDOC)->COM_EMISDC) // aRetMbrLin[4])
					oModelSim:SetValue("SIM_SERDC ",(cAliLDOC)->COM_SERDC)  // aRetMbrLin[5])
					oModelSim:SetValue("SIM_NRDC  ",(cAliLDOC)->COM_NRDC)   // aRetMbrLin[6])
					oModelSim:SetValue("SIM_NRCALC",aDadosSim[nI,1])
					oModelSim:SetValue("SIM_TRECHO",aDadosSim[nI,2])
					oModelSim:SetValue("SIM_TRANSP",aDadosSim[nI,3])
					oModelSim:SetValue("SIM_NRTAB" ,aDadosSim[nI,4])
					oModelSim:SetValue("SIM_TOTFRE",aDadosSim[nI,5])
					oModelSim:SetValue("SIM_TOTSIM",aDadosSim[nI,6])
					oModelSim:SetValue("SIM_FRTVL" ,aDadosSim[nI,7])
					oModelSim:SetValue("SIM_FRTVLS",aDadosSim[nI,8])
					oModelSim:SetValue("SIM_FRTUNI",aDadosSim[nI,9])
					oModelSim:SetValue("SIM_FRTUNS",aDadosSim[nI,10])
					oModelSim:SetValue("SIM_TOTTAX",aDadosSim[nI,11])
					oModelSim:SetValue("SIM_TOTAXS",aDadosSim[nI,12]) 
					oModelSim:SetValue("SIM_PEDAG" ,aDadosSim[nI,13])
					oModelSim:SetValue("SIM_PEDAGS",aDadosSim[nI,14])

				Next nI	                     
			Else
				// TODO: Tratar quando ocorrer erro de cálculo
			EndIf 

			// Elimina as tabelas temporárias do cálculo
			GFEDelTabCal(.F.)

		EndIf
		(cAliLDOC)->( dbSkip() )
	EndDo

	// Desabilita a inclusão de linhas no model. 
	// Necessário para bloquear a inclusão de linhas no grid.	
	oModelSim:SetNoInsertLine(.T.) 
	oModelSim:SetLine(1)
	(cAliLDOC)->(dbGoTop())
	// Esta chamada é necessária para atualizar o grid com os valores atribuidos ao model
	oView:Refresh()
	
	GFEDelTabCal(.T.)

Return .T. 


/*--------------------------------------------------------------------
Retorna array com os valores do cálculo informado
--------------------------------------------------------------------*/
Static Function GFEValCalc(cNrCalculo)

	Local aValores := {0,0,0,0,0}  //[1] Valor Total, [2] Frete Unidade, [3] Frete Valor, [4] Taxas, [5] Pedagio
	Local cCatVal  := ""

	GWI->(dbSetOrder(1))
	if GWI->(msSeek(xFilial("GWI")+cNrCalculo))
		While GWI->(!Eof()) .AND. xFilial("GWI")+cNrCalculo == GWI->GWI_FILIAL+GWI->GWI_NRCALC

			If GWI->GWI_TOTFRE == "1"
				// Valor Total do Frete
				aValores[1] += GWI->GWI_VLFRET

				cCatVal := Posicione("GV2",1,xFilial("GV2")+GWI->GWI_CDCOMP,"GV2->GV2_CATVAL")

				Do Case
					Case cCatVal == "1"  // Frete Unidade
					aValores[2] += GWI->GWI_VLFRET

					Case cCatVal == "2"  // Frete Valor
					aValores[3] += GWI->GWI_VLFRET

					Case cCatVal == "3"  // Taxas
					aValores[4] += GWI->GWI_VLFRET

					Case cCatVal == "4"  // Valor do Pedagio
					aValores[5] += GWI->GWI_VLFRET
				EndCase
			EndIf

			GWI->(dbSkip())
		EndDo 
	EndIf

Return aValores


/*--------------------------------------------------------------------
Exporta o conteúdo do grid de comparativo para planilha
--------------------------------------------------------------------*/
/*Static Function GFEX061XLS()

	Local aStruct   := {} 
	Local aDados    := {} 
	Local nI        := 0, nI2 := 0
	Local cNrCols   := ""
	Private aCabExcel    := {}

	If GetNrLin() == 0
		GFEMsgErro( STR0192) //"Não há documentos de carga para exportar"
	Else                                   
		aStruct := GetHeadDoc()

		//aStructcontem a estrutura dos campos no model. Para cada campo, é possível determinar informações como:
		//[1] - Título do campo
		//[2] - Nome do campo
		//[4] - Tamanho
		//[5] - Decimais
		//[8] - Tipo de dado (caracter, data, etc.)

		For nI := 1 to len(aStruct)  
			// Deixa as colunas de seleção e do emissor de fora da exportação
			If ! (aStruct[nI,2] == "COM_EMISDC" .Or. aStruct[nI,2] == "COM_NRROM")
				aADD(aCabExcel, Array(4))
				aCabExcel[Len(aCabExcel), 1] := aStruct[nI][1]
				aCabExcel[Len(aCabExcel), 2] := aStruct[nI][3]
				aCabExcel[Len(aCabExcel), 3] := aStruct[nI][4]
				aCabExcel[Len(aCabExcel), 4] := aStruct[nI][5]

				// Grava o numero das colunas que serão exportadas
				if !Empty(cNrCols)
					cNrCols += ","
				EndIf

				cNrCols += STRZERO(nI, 2)
			EndIf
		Next nI

		(cAliLDOC)->(dbSetOrder(1))
		(cAliLDOC)->(dbGoTop())
		aDados := {}
		While !(cAliLDOC)->(EOF())
			aADD(aDados, Array(21))

			aDados[len(aDados),1 ] := (cAliLDOC)->COM_TRECHO 		  
			aDados[len(aDados),2 ] := (cAliLDOC)->COM_FILIAL 		  
			aDados[len(aDados),3 ] := (cAliLDOC)->COM_TPDC
			aDados[len(aDados),4 ] := (cAliLDOC)->COM_SERDC 		   
			aDados[len(aDados),5 ] := (cAliLDOC)->COM_NRDC 
			aDados[len(aDados),6 ] := Posicione("GU3",1,xFilial("GU3")+(cAliLDOC)->COM_REMET,"GU3_NMEMIT") 		  
			aDados[len(aDados),7 ] := Posicione("GU3",1,xFilial("GU3")+(cAliLDOC)->COM_DEST,"GU3_NMEMIT")  		  
			aDados[len(aDados),8 ] := (cAliLDOC)->COM_EMISS 		  
			aDados[len(aDados),9 ] := (cAliLDOC)->COM_PRAZO 		  
			aDados[len(aDados),10] := (cAliLDOC)->COM_PRASIM 		  
			aDados[len(aDados),11] := (cAliLDOC)->COM_VLFRET 		  
			aDados[len(aDados),12] := (cAliLDOC)->COM_VLSIMU 		  
			aDados[len(aDados),13] := Posicione("GU7",1,xFilial("GU7")+ (cAliLDOC)->COM_CIDORI ,"GU7_NMCID") 		  
			aDados[len(aDados),14] := (cAliLDOC)->COM_UFORI 		  
			aDados[len(aDados),15] := (cAliLDOC)->COM_CIDDES 		  
			aDados[len(aDados),16] := (cAliLDOC)->COM_UFDES 		  
			aDados[len(aDados),17] := Posicione("GU7",1,xFilial("GU7")+ (cAliLDOC)->COM_CIORSI ,"GU7_NMCID")  		  
			aDados[len(aDados),18] := (cAliLDOC)->COM_UFORSI 		  
			aDados[len(aDados),19] := Posicione("GU7",1,xFilial("GU7")+ (cAliLDOC)->COM_CIDESI  ,"GU7_NMCID") 		  
			aDados[len(aDados),20] := (cAliLDOC)->COM_UFDESI 		  
			aDados[len(aDados),21] := (cAliLDOC)->COM_NRCALC 		  

			(cAliLDOC)->(dbSkip())
		EndDo
		(cAliLDOC)->(dbGotop())

		Processa( {|| DlgToExcel({{"GETDADOS",STR0196,aCabExcel,aDados}})},STR0194,STR0195)
	EndIf

Return .T. */

/*--------------------------------------------------------------------
Exporta o conteúdo do grid de comparativo para planilha
--------------------------------------------------------------------*/
Static Function GFEX061XL2()

	Local oModelPai := FWModelActive()
	Local oModelSim := oModelPai:GetModel("DETAIL_02")
	Local aStruct   := {} 
	Local aDados    := {} 
	Local nI        := 0
	Local cNrCols   := ""
	Private aCabExcel    := {}

	If oModelSim:Length() == 0
		GFEMsgErro("Não há informação para ser exportada.") //"Não há documentos de carga para exportar"
	Else                                   
		aStruct := GetHeadSim()
		/* 
		aStructcontem a estrutura dos campos no model. Para cada campo, é possível determinar informações como:
		[1] - Título do campo
		[2] - Nome do campo
		[4] - Tamanho
		[5] - Decimais
		[8] - Tipo de dado (caracter, data, etc.)
		*/

		For nI := 1 to len(aStruct)  
			// Deixa as colunas de seleção e do emissor de fora da exportação
			aADD(aCabExcel, Array(4))
			aCabExcel[Len(aCabExcel), 1] := aStruct[nI][1]
			aCabExcel[Len(aCabExcel), 2] := aStruct[nI][3]
			aCabExcel[Len(aCabExcel), 3] := aStruct[nI][4]
			aCabExcel[Len(aCabExcel), 4] := aStruct[nI][5]

			// Grava o numero das colunas que serão exportadas
			if !Empty(cNrCols)
				cNrCols += ","
			EndIf

			cNrCols += STRZERO(nI, 2)
		Next nI

		for nI:= 1 to oModelSim:Length()
			aADD(aDados, Array(20))
			oModelSim:GoLine(nI)

			aDados[len(aDados),1 ] := oModelSim:GetValue("SIM_FILIAL")
			aDados[len(aDados),2 ] := oModelSim:GetValue("SIM_CDTPDC")
			aDados[len(aDados),3 ] := oModelSim:GetValue("SIM_EMISDC")
			aDados[len(aDados),4 ] := oModelSim:GetValue("SIM_SERDC ")
			aDados[len(aDados),5 ] := oModelSim:GetValue("SIM_NRDC"  )
			aDados[len(aDados),6 ] := oModelSim:GetValue("SIM_NRCALC")
			aDados[len(aDados),7 ] := oModelSim:GetValue("SIM_TRECHO")
			aDados[len(aDados),8 ] := oModelSim:GetValue("SIM_TRANSP")
			aDados[len(aDados),9 ] := oModelSim:GetValue("SIM_NRTAB" )
			aDados[len(aDados),10] := oModelSim:GetValue("SIM_TOTFRE")
			aDados[len(aDados),11] := oModelSim:GetValue("SIM_TOTSIM")
			aDados[len(aDados),12] := oModelSim:GetValue("SIM_FRTVL" )
			aDados[len(aDados),13] := oModelSim:GetValue("SIM_FRTVLS")
			aDados[len(aDados),14] := oModelSim:GetValue("SIM_FRTUNI")
			aDados[len(aDados),15] := oModelSim:GetValue("SIM_FRTUNS")
			aDados[len(aDados),16] := oModelSim:GetValue("SIM_TOTTAX")
			aDados[len(aDados),17] := oModelSim:GetValue("SIM_TOTAXS")
			aDados[len(aDados),18] := oModelSim:GetValue("SIM_PEDAG" )
			aDados[len(aDados),19] := oModelSim:GetValue("SIM_PEDAGS")
			aDados[len(aDados),20] := 0
		next

		Processa( {|| DlgToExcel({{"GETDADOS",STR0196,aCabExcel,aDados}})},STR0194,STR0195)
	EndIf

Return .T. 

/*------------------------------------------------------------------------
Criar a estrutura da tabela temporária que conterá os documentos de carga selecionados
-------------------------------------------------------------------------*/
Static Function GFEStrTab()

	Local aStrTab :=  {;
	{"FILIAL" ,"C",TamSX3("GW1_FILIAL")[1],0},;
	{"CDTPDC" ,"C",TamSX3("GW1_CDTPDC")[1],0},;
	{"EMISDC" ,"C",TamSX3("GW1_EMISDC")[1],0},;
	{"SERDC"  ,"C",TamSX3("GW1_SERDC" )[1],0},;
	{"NRDC"   ,"C",TamSX3("GW1_NRDC"  )[1],0},;
	{"DTEMIS" ,"D",TamSX3("GW1_DTEMIS")[1],0},;                  
	{"TRECHO" ,"C",TamSX3("GWU_SEQ"   )[1],0},;
	{"CDREM"  ,"C",TamSX3("GW1_CDREM" )[1],0},;
	{"NMREM"  ,"C",TamSX3("GU3_NMEMIT" )[1],0},;
	{"CDDEST" ,"C",TamSX3("GW1_CDDEST")[1],0},;      
	{"NMDEST"  ,"C",TamSX3("GU3_NMEMIT" )[1],0},;                  
	{"NRCIDO" ,"C",TamSX3("GU7_NRCID" )[1],0},;	// Cidade Origem Real
	{"NMCIDO" ,"C",TamSX3("GU7_NMCID" )[1],0},;	// Cidade Origem Real
	{"CDUFO"  ,"C",TamSX3("GU7_CDUF"  )[1],0},;	// Uf Origem Real	                   
	{"NRCIDD" ,"C",TamSX3("GU7_NRCID" )[1],0},;	// Cidade Destino Real
	{"NMCIDD" ,"C",TamSX3("GU7_NMCID" )[1],0},;	// Cidade Origem Real
	{"CDUFD"  ,"C",TamSX3("GU7_CDUF"  )[1],0},;	// Uf Destino Real 
	{"NRCIOS" ,"C",TamSX3("GU7_NRCID" )[1],0},;	// Cidade Origem Simulação
	{"NMCIOS" ,"C",TamSX3("GU7_NMCID" )[1],0},;	// Cidade Origem Real
	{"CDUFOS" ,"C",TamSX3("GU7_CDUF"  )[1],0},;	// Uf Origem Simulação
	{"NRCIDS" ,"C",TamSX3("GU7_NRCID" )[1],0},;	// Cidade Destino Simulação
	{"NMCIDS" ,"C",TamSX3("GU7_NMCID" )[1],0},;	// Cidade Origem Real
	{"CDUFDS" ,"C",TamSX3("GU7_CDUF"  )[1],0},;	// Uf Destino Simulação
	{"NRROM"  ,"C",TamSX3("GW1_NRROM" )[1],0},;
	{"VLFRTDC","N",TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2]},;
	{"PRAZO"  ,"D", 08, 0},;
	{"VLSIMU" ,"N",TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2]},;
	{"PRASIM" ,"D", 08, 0},;
	{"NRCALC" ,"C",TamSX3("GWF_NRCALC")[1],0}}

	Local aIndex := {"FILIAL+CDTPDC+EMISDC+SERDC+NRDC"}
	
Return {aStrTab,aIndex}


/*------------------------------------------------------------------------
Retorna o prazo de entrega (em horas) para um determinado calculo de frete
------------------------------------------------------------------------*/
Static Function GFEPrazo(cNrCalc)

	Local aAreaGWG := getArea("GWG")
	Local aAreaGV6 := getArea("GV6")
	Local aPreData[1]		// Retorno da função PrevDtEnt
	Local dDataRef := Date()	
	Local cHoraRef := Substr(Time(), 1, 5)
	Local dDtPrazo
	

	GWG->(dbSetOrder(1))
	if GWG->(msSeek(xFilial("GWG")+cNrCalc))
		GV6->(dbSetOrder(1))
		if GV6->(msSeek(xFilial("GV6")+GWG->GWG_CDEMIT+GWG->GWG_NRTAB+GWG->GWG_NRNEG+GWG->GWG_CDFXTV+GWG->GWG_NRROTA))
			aPreData := PrevDtEnt(dDataRef, cHoraRef, GWG->GWG_CDEMIT, GWG->GWG_NRTAB, GWG->GWG_NRNEG, GWG->GWG_CDFXTV, GWG->GWG_NRROTA)
			dDtPrazo := aPreData[1] 
		EndIf
	EndIf

	RestArea(aAreaGWG)
	RestArea(aAreaGV6)

Return dDtPrazo

/*-------------------------------------------------------------------
{Protheus.doc} GFEX061DOC

Criação do MarkBrowse dos documentos de carga. 

@author Lidiomar Fernando dos Santos Machado
@since 15/08/13
@version 1.0
-------------------------------------------------------------------*/

Function GFEX061DOC(oPanel, oObj)

	Local aStruct := GETTABDOC()

	cAliLDOC := GFECriaTab(aStruct)

	oBrwDoc := FWMarkBrowse():New()
	oBrwDoc:SetTemporary(.T.)
	oBrwDoc:SetAlias(cAliLDOC)
	oBrwDoc:SetFields(GetHeadDoc())
	oBrwDoc:SetOwner(oPanel)
	oBrwDoc:SetMenuDef("GFEX061")
	oBrwDoc:SetFieldMark("OK")
	oBrwDoc:SetDescription("Documentos de Carga")
//	oBrwDoc:DisableReport()
	oBrwDoc:SetSeeAll(.T.)
	oBrwDoc:SetAllMark({|| GFEX061MARK(oBrwDoc)})
	oBrwDoc:SetAfterMark({|| GFEX061MKB(oBrwDoc)})
	//oBrwDoc:SetAllMark({|| })
	//oBrwDoc:SetAllMark({|| })
	oBrwDoc:Activate()

Return

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE 'Comparar'   ACTION 'GFEX061CR()' OPERATION 3 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Consultar Doc Carga'   ACTION 'GFEX061DC()' OPERATION 2 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Consultar Cálculo'   ACTION 'GFEX061CL()' OPERATION 2 ACCESS 0 DISABLE MENU

Return aRotina

Function GFEX061DC()
	Local aAreaGW1	:= GW1->(GetArea())
	Local cFilAux	:= cFilAnt 
	
	cFilAnt := (cAliLDOC)->(COM_FILIAL)
	
	GW1->(dbSetOrder(1))

	If GW1->(dbSeek((cAliLDOC)->(COM_FILIAL) + (cAliLDOC)->(COM_TPDC) + (cAliLDOC)->(COM_EMISDC) + (cAliLDOC)->(COM_SERDC) + (cAliLDOC)->(COM_NRDC)) )
		FwExecView("Documento de Carga","GFEC040")
	Else
		MsgInfo("Documento de carga não localizado!")
	EndIf
	
	RestArea(aAreaGW1)
	cFilAnt := cFilAux
Return

Function GFEX061CL()
	Local aAreaGWF := GWF->(GetArea())
	Local cFilAux	:= cFilAnt 
	
	cFilAnt := (cAliLDOC)->(COM_FILIAL)
	
	GWF->(dbSetOrder(1))

	If GWF->(dbSeek((cAliLDOC)->(COM_FILIAL) + (cAliLDOC)->(COM_NRCALC) ))
		FwExecView("Cálculo de Frete"," GFEC080")
	Else
		MsgInfo("Cálculo não localizado!")
	EndIf
	
	RestArea(aAreaGWF)
	cFilAnt := cFilAux
Return

Static Function LimpaAbaOutr()
	Local nX := 2
	Local nY := 5
	Local oView := FwViewActive()
	oView:aFolders[NX][nY]:SetUpdatesEnabled( .F. )
	oView:aFolders[NX][nY]:HidePage(2)
	OVIEW:AFOLDERS[NX][nY]:aDialogs[2]:cTitle :=	STROUTRASIM
	oView:aFolders[NX][nY]:ShowPage(2)
	oView:aFolders[NX][nY]:ShowPage(1)
	oView:aFolders[NX][nY]:SetUpdatesEnabled( .T. )
Return

Function GFEX061MKB(oMrkAllAtd)

Local lRetorno    := .T.                                           // Retorno da rotina.                           
Local aAreaTmp    := (oMrkAllAtd:Alias())->(GetArea())        // Guarda a area do browse.
Local nQtd := 0
Local oView := FwViewActive()
Local nX := 2
Local nY := 5

	oView:aFolders[NX][nY]:SetUpdatesEnabled( .F. )
	
	(oMrkAllAtd:Alias())->(DbGoTop())

	While (oMrkAllAtd:Alias())->(!Eof())
		If oMrkAllAtd:IsMark()
			nQtd++
		EndIf
		(oMrkAllAtd:Alias())->(DbSkip())
	EndDo
	oView:aFolders[NX][nY]:HidePage(2)
	
	If nQtd == 0
		OVIEW:AFOLDERS[NX][nY]:aDialogs[2]:cTitle :=	STROUTRASIM
	Else
		OVIEW:AFOLDERS[NX][nY]:aDialogs[2]:cTitle :=	"Simular " + cValToChar(nQtd) + " documento(s) com outras transportadoras"
	EndIf
	
	RestArea(aAreaTmp)
	
	oMrkAllAtd:Refresh()
	
	oView:aFolders[NX][nY]:ShowPage(2)
	oView:aFolders[NX][nY]:ShowPage(1)
	oView:aFolders[NX][nY]:aDialogs[1]:SetFocus()
	oView:aFolders[NX][nY]:SetUpdatesEnabled( .T. )
	
Return (lRetorno) 

/*-------------------------------------------------------------------
{Protheus.doc} GetTabDoc

Retorna a estrutura da tabela temporária.

Utilizada na criação do MarkBrowse dos documentos de carga. 

@author Lidiomar Fernando dos Santos Machado
@since 15/08/13
@version 1.0
-------------------------------------------------------------------*/

Function GetTabDoc()
	Local aCampos :=    {;
	{ 'OK'       , 'C', 02                     ,0},; //"Selecionado"
	{'COM_TRECHO', 'C', TamSX3("GWU_SEQ"   )[1],0},; //"Trecho" ### "Trecho"
	{'COM_FILIAL', 'C', TamSX3("GW1_FILIAL")[1],0},; //"Filial" ### "Filial"
	{'COM_TPDC'  , 'C', TamSX3("GW1_CDTPDC")[1],0},; //"Tp Docto" ### "Tp Docto"
	{'COM_SERDC' , 'C', TamSX3("GW1_SERDC" )[1],0},; //"Serie DC" ### "Serie DC"
	{'COM_NRDC'  , 'C', TamSX3("GW1_NRDC"  )[1],0},; //"Docto Carga" ### "Docto Carga"
	{'COM_REMET' , 'C', TamSX3("GW1_CDREM" )[1],0},; //"Remetente" ### "Remetente"
	{'COM_NMREM' , 'C', TamSX3("GU3_NMEMIT" )[1],0},; //"Remetente" ### "Remetente"
	{'COM_DEST'  , 'C', TamSX3("GW1_CDDEST")[1],0},; //"Destinatário" ### "Destinatário"
	{'COM_NMDES' , 'C', TamSX3("GU3_NMEMIT" )[1],0},; //"Remetente" ### "Remetente"
	{'COM_EMISS' , 'D', TamSX3("GW1_DTEMIS")[1],0},; //"Emissão" ### "Emissão"
	{'COM_PRAZO' , "D", 08, 0},; //"Prazo" ### "Prazo"
	{'COM_PRASIM', "D", 08, 0},; //,TamSX3("GV6_QTPRAZ")[2]},; //"Prazo Simulação" ### "Prazo Simulação"
	{'COM_VLFRET', 'N', TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2]},; //"Frete Realizado" ### "Frete dos cálculos atuais"
	{'COM_VLSIMU', 'N', TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2]},; //"Frete Simulado" ### "Frete usando nova tabela"
	{'COM_CIDORI', 'C', TamSX3("GU7_NRCID" )[1],0},; //"Cidade Origem" ### "Cidade Origem"
	{'COM_NMCORI', 'C', TamSX3("GU7_NMCID" )[1],0},; //"Cidade Origem" ### "Cidade Origem"
	{'COM_UFORI' , 'C', TamSX3("GU7_CDUF"  )[1],0},; //"UF Origem" ### "UF Origem"
	{'COM_CIDDES', 'C', TamSX3("GU7_NRCID" )[1],0},; //"Cidade Destino" ### "Cidade Destino"
	{'COM_NMCDES', 'C', TamSX3("GU7_NMCID" )[1],0},; //"Cidade Origem" ### "Cidade Origem"
	{'COM_UFDES' , 'C', TamSX3("GU7_CDUF"  )[1],0},; //"UF Destino" ### "UF Destino"
	{'COM_CIORSI', 'C', TamSX3("GU7_NRCID" )[1],0},; //"Cid. Orig. Sim." ### "Cidade Origem Simulação"
	{'COM_NMCORS', 'C', TamSX3("GU7_NMCID" )[1],0},; //"Cidade Origem" ### "Cidade Origem"
	{'COM_UFORSI', 'C', TamSX3("GU7_CDUF"  )[1],0},; //"UF Orig. Sim." ### "UF Origem Simulação"
	{'COM_CIDESI', 'C', TamSX3("GU7_NRCID" )[1],0},; //"Cid. Dest. Sim." ### "Cidade Destino Simul."
	{'COM_NMCDSS', 'C', TamSX3("GU7_NMCID" )[1],0},; //"Cidade Origem" ### "Cidade Origem"
	{'COM_UFDESI', 'C', TamSX3("GU7_CDUF"  )[1],0},; //"UF Dest. Sim." ### "UF Destino Simul."
	{'COM_NRCALC', 'C', TamSX3("GWF_NRCALC")[1],0},; //"Cálculo" ### "Número do Cálculo"
	{'COM_EMISDC', 'C', TamSX3("GW1_EMISDC")[1],0,},; //"Emissor" ### "Emissor Docto Carga"
	{'COM_NRROM' , 'C', TamSX3("GW1_NRROM" )[1],0,},; //"Romaneio" ### "Número do Romaneio"
	{'COM_CNPJ'  , 'C', TamSX3("GU3_IDFED" )[1],0,},;
	{'COM_VLRNF' , 'N', TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR")[2],},;
	{'COM_PESOB' , 'N', TamSX3("GW8_PESOR" )[1],TamSX3("GW8_PESOR")[2],}}

	Local aIndexes := {"COM_NRROM+COM_FILIAL+COM_TPDC+COM_EMISDC+COM_SERDC+COM_NRDC","COM_FILIAL+COM_TPDC+COM_EMISDC+COM_SERDC+COM_NRDC"}

Return {aCampos,aIndexes}

Function GetHeadDoc()
	Local aHeader :=   {;
	{STR0081,                'COM_TRECHO', 'C', TamSX3("GWU_SEQ"   )[1],0,TRIM(X3PICTURE("GWU_SEQ"   ))},; //"Trecho" ### "Trecho"
	{"Filial",               'COM_FILIAL', 'C', TamSX3("GW1_FILIAL")[1],0,TRIM(X3PICTURE("GW1_FILIAL"))},; //"Filial" ### "Filial"
	{STR0082,                'COM_TPDC'  , 'C', TamSX3("GW1_CDTPDC")[1],0,TRIM(X3PICTURE("GW1_CDTPDC"))},; //"Tp Docto" ### "Tp Docto"
	{STR0083,                'COM_SERDC' , 'C', TamSX3("GW1_SERDC" )[1],0,TRIM(X3PICTURE("GW1_SERDC" ))},; //"Serie DC" ### "Serie DC"
	{STR0084,                'COM_NRDC'  , 'C', TamSX3("GW1_NRDC"  )[1],0,TRIM(X3PICTURE("GW1_NRDC"  ))},; //"Docto Carga" ### "Docto Carga"
	{STR0085,                'COM_REMET' , 'C', TamSX3("GW1_CDREM" )[1],0,TRIM(X3PICTURE("GW1_CDREM" ))},; //"Remetente" ### "Remetente"
	{"Nome Remetente",       'COM_NMREM' , 'C', TamSX3("GU3_NMEMIT")[1],0,TRIM(X3PICTURE("GU3_NMEMIT" ))},; //"Remetente" ### "Remetente"
	{STR0086,                'COM_DEST'  , 'C', TamSX3("GW1_CDDEST")[1],0,TRIM(X3PICTURE("GW1_CDDEST"))},; //"Destinatário" ### "Destinatário"
	{"Nome Destinatário",    'COM_NMDES' , 'C', TamSX3("GU3_NMEMIT")[1],0,TRIM(X3PICTURE("GU3_NMEMIT" ))},; //"Remetente" ### "Remetente"
	{"CPF/CNPJ Destinat",    'COM_CNPJ'  , 'C', TamSX3("GU3_IDFED" )[1],0,TRIM(X3PICTURE("GU3_IDFED" ))},;
	{STR0087,                'COM_EMISS' , 'D', TamSX3("GW1_DTEMIS")[1],0,TRIM(X3PICTURE("GW1_DTEMIS"))},; //"Emissão" ### "Emissão"
	{"Valor Nota",           'COM_VLRNF' , 'N', TamSX3("GW8_VALOR" )[1],0,TRIM(X3PICTURE("GW8_VALOR" ))},;
	{"Peso Bruto",           'COM_PESOB' , 'N', TamSX3("GW8_PESOR" )[1],0,TRIM(X3PICTURE("GW8_PESOR" ))},;
	{"Prazo Previsto",       'COM_PRAZO' , 'N', TamSX3("GV6_QTPRAZ")[1],TamSX3("GV6_QTPRAZ")[2],TRIM(X3PICTURE("GV6_QTPRAZ"))},; //"Prazo Previsto" ### "Prazo"
	{STR0088,                'COM_PRASIM', 'N', TamSX3("GV6_QTPRAZ")[1],TamSX3("GV6_QTPRAZ")[2],TRIM(X3PICTURE("GV6_QTPRAZ"))},; //"Prazo Simulação" ### "Prazo Simulação"
	{STR0016,                'COM_VLFRET', 'N', TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Realizado" ### "Frete dos cálculos atuais"
	{STR0018,                'COM_VLSIMU', 'N', TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Simulado" ### "Frete usando nova tabela"
	{STR0091,                'COM_CIDORI', 'C', TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" ))},; //"Cidade Origem" ### "Cidade Origem"
	{"Nome Cidade Origem",   'COM_NMCORI', 'C', TamSX3("GU7_NMCID" )[1],0,TRIM(X3PICTURE("GU7_NMCID" ))},; //"Cidade Origem" ### "Cidade Origem"
	{STR0092,                'COM_UFORI' , 'C', TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  ))},; //"UF Origem" ### "UF Origem"
	{STR0093,                'COM_CIDDES', 'C', TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" ))},; //"Cidade Destino" ### "Cidade Destino"
	{"Nome Cidade Destino",  'COM_NMCDES', 'C', TamSX3("GU7_NMCID" )[1],0,TRIM(X3PICTURE("GU7_NMCID" ))},; //"Cidade Origem" ### "Cidade Origem"
	{STR0094,                'COM_UFDES' , 'C', TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  ))},; //"UF Destino" ### "UF Destino"
	{STR0095,                'COM_CIORSI', 'C', TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" ))},; //"Cid. Orig. Sim." ### "Cidade Origem Simulação"
	{"Nome Cid. Orig. Sim.", 'COM_NMCORS', 'C', TamSX3("GU7_NMCID" )[1],0,TRIM(X3PICTURE("GU7_NMCID" ))},; //"Cidade Origem" ### "Cidade Origem"
	{STR0097,                'COM_UFORSI', 'C', TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  ))},; //"UF Orig. Sim." ### "UF Origem Simulação"
	{STR0099,                'COM_CIDESI', 'C', TamSX3("GU7_NRCID" )[1],0,TRIM(X3PICTURE("GU7_NRCID" ))},; //"Cid. Dest. Sim." ### "Cidade Destino Simul."
	{"Nome Cid. Dest. Sim.", 'COM_NMCDSS', 'C', TamSX3("GU7_NMCID" )[1],0,TRIM(X3PICTURE("GU7_NMCID" ))},; //"Cidade Origem" ### "Cidade Origem"
	{STR0101,                'COM_UFDESI', 'C', TamSX3("GU7_CDUF"  )[1],0,TRIM(X3PICTURE("GU7_CDUF"  ))},; //"UF Dest. Sim." ### "UF Destino Simul."
	{STR0103,                'COM_NRCALC', 'C', TamSX3("GWF_NRCALC")[1],0,TRIM(X3PICTURE("GWF_NRCALC"))},; //"Cálculo" ### "Número do Cálculo"
	{STR0105,                'COM_EMISDC', 'C', TamSX3("GW1_EMISDC")[1],0,},; //"Emissor" ### "Emissor Docto Carga"
	{STR0107,                'COM_NRROM' , 'C', TamSX3("GW1_NRROM" )[1],0,}} //"Romaneio" ### "Número do Romaneio"

Return aHeader

Function GetHeadSim()
	Local aHeader := {;
	{"Filial" ,  'SIM_FILIAL','C',TamSX3("GW1_FILIAL")[1],0                      ,TRIM(X3PICTURE("GW1_FILIAL"))},; //Filial 
	{"Tp Docto" ,'SIM_CDTPDC','C',TamSX3("GW1_CDTPDC")[1],0                      ,TRIM(X3PICTURE("GW1_CDTPDC"))},; //TipoDocumento
	{"Emissor"  ,'SIM_EMISDC','C',TamSX3("GW1_EMISDC")[1],0                      ,TRIM(X3PICTURE("GW1_EMISDC"))},; //emissor
	{"Série"    ,'SIM_SERDC' ,'C',TamSX3("GW1_SERDC")[1] ,0                      ,TRIM(X3PICTURE("GW1_SERDC")) },; //serie
	{"Doc Carga",'SIM_NRDC'  ,'C',TamSX3("GW1_NRDC")[1]  ,0                      ,TRIM(X3PICTURE("GW1_NRDC"))  },; //Documento carga
	{STR0111,    'SIM_NRCALC','C',TamSX3("GWF_NRCALC")[1],0                      ,TRIM(X3PICTURE("GWF_NRCALC"))},; //"Simul." ### "Número Simulação"
	{STR0081,    'SIM_TRECHO','C',TamSX3("GWU_SEQ"   )[1],0                      ,'@'                          },; //"Trecho" ### "Trecho"
	{STR0113,    'SIM_TRANSP','C',TamSX3("GU3_CDEMIT")[1],0                      ,'@'                          },; //"Transp." ### "Transportador"
	{STR0115,    'SIM_NRTAB' ,'C',TamSX3("GVA_NRTAB" )[1],0                      ,TRIM(X3PICTURE("GVA_NRTAB" ))},; //"Número Tabela" ### "Número Tabela"
	{STR0089,    'SIM_TOTFRE','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Realizado" ### "Frete dos calculos atuais"
	{STR0090,    'SIM_TOTSIM','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Simulado" ### "Frete usando nova tabela"
	{STR0117,    'SIM_FRTVL' ,'N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Valor Real." ### "Frete Valor Realizado"
	{STR0119,    'SIM_FRTVLS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Valor Sim." ### "Frete Valor Simulado"
	{STR0121,    'SIM_FRTUNI','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Unid. Real." ### "Frete Unidade Realizado"
	{STR0123,    'SIM_FRTUNS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Frete Unid. Sim. ### "Frete Unidade Simulação"
	{STR0125,    'SIM_TOTTAX','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Taxas Real." ### "Total Taxas Realizado"
	{STR0127,    'SIM_TOTAXS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Taxas Simul." ### "Total Taxas Simulação"
	{STR0129,    'SIM_PEDAG' ,'N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))},; //"Pedágio Real." ### "Pedágio Realizado"
	{STR0131,    'SIM_PEDAGS','N',TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],TRIM(X3PICTURE("GWI_VLFRET"))}}  //"Pedágio Sim." ### "Pedágio Simulação"
Return aHeader


/*-------------------------------------------------------------------
Retorna a estrutura do view dos campos calculados
-------------------------------------------------------------------*/
Static Function GetCalcFld(nTipo)

	Local oStruct 
	Local nI      := 0  
	Local aCampos := {{STR0014, STR0015, 'COM__TOT01'   , 'N',   5  ,0, '99999' },; //Qtde. Doc. Carga ## Total de documentos de carga selecionados
	{STR0016, STR0017, 'COM__TOT02'   , 'N',   15 ,2, '@E 999,999,999,999.99' },; //Frete Realizado  ## Total de frete calculado atualmente
	{"Qtde. Doc. Simulado", "Total de documentos de carga simulados", 'COM__TOT04'   , 'N',   5  ,0, '99999' },; //Qtde. Doc. Carga ## Total de documentos de carga selecionados 
	{STR0018, STR0019, 'COM__TOT03'   , 'N',   15 ,2, '@E 999,999,999,999.99' },;  //Frete Simulado   ## Total do frete simulado com a nova transporadora
	{"Diferença"    , "Diferença entre Frete Realizado x Frete Simulado."              ,"COM__DIFER","N",15,2,'@E 999,999,999,999.99'},;
	{"Diferença (%)", "Percentual da diferença entre Frete Realizado x Frete Simulado.","COM__PERCE","N", 5,0,'@E 99,999.99'}}

	If nTipo == 1	// Model
		oStruct := FWFormModelStruct():New()

		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		oStruct:AddTable( 	  ;
		'COM__TOT'               , ;       // [01] Alias da tabela
		{'COM__TOT01'}        , ;       // [02] Array com os campos que correspondem a primary key
		'Campos Calculados')          // [03] Descrição da tabela //"Comparativo Frete"

		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		oStruct:AddIndex( 	  ;
		01               	, ;         // [01] Ordem do indice
		'1'              	, ;         // [02] ID
		'COM__TOT01'      	, ;         // [03] Chave do indice
		'Campos Calculados' , ;         // [04] Descrição do indice //"Comparativo Frete"
		''               	, ;         // [05] Expressão de lookUp dos campos de indice
		''               	, ;         // [06] Nickname do indice
		.T.              )              // [07] Indica se o indice pode ser utilizado pela interface

		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------
		For nI := 1 to len(aCampos)
			oStruct:AddField(        ;
			aCampos[nI,1]	         , ;              // [01] Titulo do campo
			aCampos[nI,2]	         , ;              // [02] ToolTip do campo
			aCampos[nI,3]            , ;              // [03] Id do Field
			aCampos[nI,4]            , ;              // [04] Tipo do campo
			aCampos[nI,5]	         , ;              // [05] Tamanho do campo
			aCampos[nI,6]	         , ;              // [06] Decimal do campo
			NIL						 , ;       		  // [07] Code-block de validação do campo
			NIL		                 , ;              // [08] Code-block de validação When do campo
			NIL                      , ;              // [09] Lista de valores permitido do campo
			NIL						 , ;              // [10] Indica se o campo tem preenchimento obrigatório
			NIL                		 , ;              // [11] Code-block de inicializacao do campo
			NIL                      , ;              // [12] Indica se trata-se de um campo chave
			.T.                      , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.						  )               // [14] Indica se o campo é virtual
		Next nI
	Else	
		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos) // Os campos COM_EMISDC e COM_NRROM não são visualizados	
			oStruct:AddField( 			       ;
			aCampos[nI,3]   			 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]			 	 , ;                // [03] Titulo
			aCampos[nI,2]		         , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			'GET'                        , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			NIL           	             , ;                // [09] F3
			.F.                          , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			NIL                          , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual     		
		Next nI
	EndIf

Return oStruct 

//Função que retorna o numero de linhas selecionadas no markBrowse

Function GetNrLin()
	Local nCont := 0
	(cAliLDOC)->(dbGoTop())
	While !(cAliLDOC)->( EOF() ) .AND. nCont == 0
		nCont++		
		(cAliLDOC)->( dbSkip() )
	EndDo
Return nCont

Static Function GFEX061MARK(oMrkAllAtd)

Local lRetorno    := .T.                                           // Retorno da rotina.                           
Local aAreaTmp    := (oMrkAllAtd:Alias())->(GetArea())        // Guarda a area do browse.
Local lGoTop     := .T.                                        // Posiciona no primeiro registro.

	(oMrkAllAtd:Alias())->(DbGoTop())

	While (oMrkAllAtd:Alias())->(!Eof())
		If ( !oMrkAllAtd:IsMark() )
			RecLock(oMrkAllAtd:Alias(),.F.)
			(oMrkAllAtd:Alias())->OK  := oMrkAllAtd:Mark()
			(oMrkAllAtd:Alias())->(MsUnLock())
		Else
			RecLock(oMrkAllAtd:Alias(),.F.)
			(oMrkAllAtd:Alias())->OK  := ""
			(oMrkAllAtd:Alias())->(MsUnLock())
		EndIf
	    (oMrkAllAtd:Alias())->(DbSkip())
	Enddo
	
	GFEX061MKB(oMrkAllAtd)

	RestArea(aAreaTmp)  
	oMrkAllAtd:Refresh(lGoTop)

Return (lRetorno) 

//-----------------------------------------------------------------
Static aTabScan := {}

Static Function GetInfo(cCampo)
	Local nPos
	Local xRet := ""
	If ValType(aTabScan) == "A" .Or. Type("aTabScan") == "A"
		nPos := aScan(aTabScan,{|x| x[1] == cCampo})
		If nPos > 0
			xRet := aTabScan[nPos][2]
		EndIf
	EndIf
Return xRet

Static Function SetInfo(cCampo,xValor)
	Local nPos := 0

	If ValType(aTabScan) == "A" .Or. Type("aTabScan") == "A"
		nPos := aScan(aTabScan,{|x| x[1] == cCampo})
		If nPos > 0
			aTabScan[nPos][2] := xValor
		Else
			aAdd(aTabScan,{cCampo,xValor})
			nPos := Len(aTabScan)
		EndIf
	EndIf
Return nPos

Static Function SetTabScan(aTab)
	aTabScan := aTab
Return

Static Function NovaTab()
	Local aTabGVA := {}
	Local aTabGV9 := {}
	Local aTabGV7 := {}
	Local aTabGUY := {}
	Local aTabGV6 := {}
	Local aTabGV1 := {}
	Local aLinha  := {}
	Local aData   := {}
	Local cTpLota 
	Local oModel	:= FwModelActive()
	Local oModelComp := oModel:GetModel("DETAIL_03")
	Local oModelSet := oModel:GetModel("GFEX061_01")
	Local aRetGv9 := {,,}
	Local nI
	
	// Validar se o componente para frete garantia está listado entre os componentes
	if !Empty(FwFldGet("FRT_COMPGR")) .AND. !oModelComp:seekLine({{"COP_COMP",FwFldGet("FRT_COMPGR")}})
		GFEMsgErro( STR0177) //"Componente para frete garantia não consta entre os componentes informados."
		Return .F.
	EndIf

	// Validar se o componente para imposto está listado entre os componentes
	if !Empty(FwFldGet("FRT_COMIMP")) .AND. !oModelComp:seekLine({{"COP_COMP",FwFldGet("FRT_COMIMP")}})
		GFEMsgErro( STR0178) //"Componente para imposto não consta entre os componentes informados."
		Return .F.
	EndIf
	
	If Empty(FwFldGet("FRT_TPVEI")) .And. Empty(FwFldGet("FRT_UNMED"))
		cTpLota := "0" //Deve ser informado pelo usuário
	ElseIf Empty(FwFldGet("FRT_TPVEI"))
		cTpLota := "1" //Fracionado
	Else
		cTpLota := "2" //Fechado
	EndIf
	
	aAdd(aTabGVA,{"GVA_CDEMIT",FwFldGet("GWU_TRPCOM")})
	aAdd(aTabGVA,{"GVA_NRTAB" ,FwFldGet("GWU_TABCMP")})
	
	If cTpLota != "0"
		aAdd(aTabGV9,{"GV9_TPLOTA",cTpLota})
	EndIf

	If cTpLota == "1"
		aAdd(aTabGV9,{"GV9_ATRFAI",oModel:GetModel("GFEX061_02"):GetValue("FRT_ATRFAI")})
		aAdd(aTabGV9,{"GV9_UNIFAI",FwFldGet("FRT_UNMED")})
	EndIf
	
	aAdd(aTabGV9,{"GV9_QTKGM3",FwFldGet("FRT_KGM3")})
	aAdd(aTabGV9,{"GV9_ADISS" ,FwFldGet("FRT_ADISS")})
	aAdd(aTabGV9,{"GV9_ADICMS",FwFldGet("FRT_ADICMS")})
	
	If FwFldGet("FRT_ADISS") == '1' .Or. FwFldGet("FRT_ADICMS") == '1'
		aAdd(aTabGV9,{"GV9_RATIMP",FwFldGet("FRT_RATIMP")})
		If FwFldGet("FRT_RATIMP") == '2'
			aAdd(aTabGV9,{"GV9_COMIMP",FwFldGet("FRT_COMIMP")})
		EndIf
	EndIf
	
	If cTpLota == '2'
		aAdd(aTabGV7,{"GV7_CDTPVC",FwFldGet("FRT_TPVEI")})
		aAdd(aTabGV7,{"GV7_UNICAL",FwFldGet("FRT_UNMED")})
	ElseIf cTpLota == '1'
		aAdd(aTabGV7,{"GV7_QTFXFI",999999999.99999})
		aAdd(aTabGV7,{"GV7_UNICAL",FwFldGet("FRT_UNMED")})
	EndIf
	
	If !oModelComp:isEmpty()

		For nI := 1 to oModelComp:getQtdLine()
			
			
			If !oModelComp:isDeleted(nI)
				
				aSize(aLinha,0)
				
				aAdd(aLinha,{"GUY_CDCOMP",FwFldGet("COP_COMP"  ,nI)})		// Codigo do componente de frete
				aAdd(aLinha,{"GUY_TOTFRE",FwFldGet("COP_TOTFRT",nI)})		// Componente considera no total do frete?
				aAdd(aLinha,{"GUY_BASIMP",FwFldGet("COP_IMPOST",nI)})		// Componente considera na base de cálculo de ISS/ICMS?
				aAdd(aLinha,{"GUY_BAPICO",FwFldGet("COP_PISCOF",nI)})		// Componente considera na base de cálculo de PIS/COFINS?
				aAdd(aLinha,{"GUY_FREMIN",FwFldGet("COP_FREMIN",nI)})		// Componente considera na base de cálculo de PIS/COFINS?
				
				aAdd(aTabGUY,aClone(aLinha))
				
				aSize(aLinha,0)
				
				aAdd(aLinha,{"GV1_CDCOMP",FwFldGet("COP_COMP"  ,nI)})		// Codigo do componente de frete
				aAdd(aLinha,{"GV1_VLFIXN",FwFldGet("COP_VLFIXO",nI)})		// Valor fixo normal
				aAdd(aLinha,{"GV1_PCNORM",FwFldGet("COP_PCNORM",nI)})		// Percentual normal
				aAdd(aLinha,{"GV1_VLUNIN",FwFldGet("COP_VLUNNM",nI)})		// Valor unitario normal
				aAdd(aLinha,{"GV1_VLFRAC",FwFldGet("COP_VLFRAC",nI)})		// Valor fração normal
				aAdd(aLinha,{"GV1_VLMINN",FwFldGet("COP_VLMINN",nI)})		// Valor minimo normal
				aAdd(aLinha,{"GV1_VLLIM" ,FwFldGet("COP_VLLIMI",nI)})		// Valor limite
				aAdd(aLinha,{"GV1_VLFIXE",FwFldGet("COP_VLFXEX",nI)})		// Valor fixo extra
				aAdd(aLinha,{"GV1_PCEXTR",FwFldGet("COP_PCEXTR",nI)})		// Percentual extra
				aAdd(aLinha,{"GV1_VLUNIE",FwFldGet("COP_VLUNEX",nI)})		// Valor unitario extra
				aAdd(aLinha,{"GV1_CALCEX",FwFldGet("COP_CALCEX",nI)})		// Forma de calculo do excedente
				
				aAdd(aTabGV1,aClone(aLinha))
			EndIf
			
		Next nI
		
	EndIf
	
	aAdd(aTabGV6,{"GV6_QTMIN",FwFldGet("FRT_QTDMIN")})		// Quantidade minima
	aAdd(aTabGV6,{"GV6_FRMIN",FwFldGet("FRT_FRTMIN")})		// Frete Mínimo
	aAdd(aTabGV6,{"GV6_COMFRG",FwFldGet("FRT_COMPGR")})		// Componente para frete garantia
	aAdd(aTabGV6,{"GV6_CONSPZ",FwFldGet("FRT_CNPRAZ")})		// Considera prazo de entrega?
	
	If FwFldGet("FRT_CNPRAZ") == "1"
		aAdd(aTabGV6,{"GV6_TPPRAZ",FwFldGet("FRT_TPPRAZ")})		// Tipo de prazo. 1-Dias, 2-Horas
		aAdd(aTabGV6,{"GV6_QTPRAZ",FwFldGet("FRT_PRAZO" )})		// Quantidade de prazo
		aAdd(aTabGV6,{"GV6_CONTPZ",FwFldGet("FRT_CNTPRA")})		// Tipo de contagem do prazo. 1-Dias corridos, 2-Dias uteis
	EndIf

	aAdd(aData,aTabGVA)
	aAdd(aData,aTabGV9)
	aAdd(aData,aTabGV7)
	aAdd(aData,aTabGUY)
	aAdd(aData,aTabGV6)
	aAdd(aData,aTabGV1)
	
	aRetGv9 := GFEX61WZRD(aData)
	
	GV9->(dbSetOrder(1))
	
	If !Empty(aRetGv9[1]) .And. !Empty(aRetGv9[2]) .And. !Empty(aRetGv9[3]) .And. GV9->(msSeek(xFilial("GV9") + aRetGv9[1] + aRetGv9[2] + aRetGv9[3]))
		oModelSet:LoadValue('GWU_TRPCOM',aRetGv9[1])
		oModelSet:LoadValue('GWU_DESCOM',Posicione("GU3",1,xFilial("GU3")+aRetGv9[1],"GU3_NMEMIT"))
		oModelSet:LoadValue('GWU_TABCMP',aRetGv9[2])
		oModelSet:LoadValue('GWU_NEGCMP',aRetGv9[3])
	End		
	
	aSize(aTabGVA,0)
	aSize(aTabGV9,0)
	aSize(aTabGV7,0)
	aSize(aTabGUY,0)
	aSize(aTabGV6,0)
	aSize(aTabGV1,0)
	aSize(aLinha ,0)
	
Return

/*/{Protheus.doc} GFEX61WZRD
Wizard de cadastro de tabela de frete. Informando um tipo de lotação, o campo fica bloqueado para edição
@author siegklenes.beulke
@since 12/02/2016
@version 1.0
@param aData, array, Ao passar o array aData, é obrigatório enviar uma array com pelo menos 6 posicoes
aData[1] := aTabGVA // {}
aData[2] := aTabGV9 // {}
aData[3] := aTabGV7 // {}
aData[4] := aTabGUY // {}
aData[5] := aTabGV6 // {}
aData[6] := aTabGV1 // {}
Default aData := {{},{},{},{},{},{}}
@return Nil
@example
GFEX61WZRD(aData)
@see PCREQ-9316
/*/
Function GFEX61WZRD(aData)
	Local oAreaModel := FwModelActive()
	Local oAreaView := FwViewActive()
	Local oModel
	Local oView
	Local lAbre061	:= .T.
	Local lAbre061A	:= .T.
	Local lAbre061F	:= .T.
	Local lAval061F	:= .T.
	Local lDel061		:= .F.
	Local lDel061A	:= .F.
	Local lDel061F	:= .F.
	Local aCoors		:= FWGetDialogSize(oMainWnd)
	Local oFWMVCWindow
	Local cQuery
	Local cAliasQry
	Local dDataIni
	Local lRet
	Local aAreaGVA
	Local aAreaGV9
	Local aAreaGV91
	Local nRotas
	Local nFaixas
	Local nQtdNeg    := 0
	Local nX
	Local aGv6Ger := {}
	Local aGV9Ret := {,,}
	Local oStru
	Private apData
	Default aData := {{},{},{},{},{},{}}
	apData := aData
	
	SetTabScan(apData[1])
	
	If !Empty(GetInfo("GVA_CDEMIT")) .And. !Empty(GetInfo("GVA_NRTAB"))
		GVA->(dbSetOrder(1))
		If GVA->(msSeek(xFilial("GVA") + GetInfo("GVA_CDEMIT") + GetInfo("GVA_NRTAB")))
			lAbre061 := .F. //Tabela já cadastrada
		EndIf
	ElseIf !Empty(GetInfo("GVA_CDEMIT")) // Sugere próxima numeração	
		cQuery  := " SELECT MAX(GVA_NRTAB) GVA_NRTAB FROM " + RetSqlName("GVA") + " WHERE GVA_FILIAL = '" + xFilial("GV9") + "' AND GVA_CDEMIT = '" + GetInfo("GVA_CDEMIT") + "' AND D_E_L_E_T_ = ''"
		cAliasQry := GetNextAlias()
		
		cQuery := changeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
		SetInfo("GVA_NRTAB",Soma1(PadL(AllTrim((cAliasQry)->GVA_NRTAB),Len(GVA->GVA_NRTAB),"0")))
		
		(cAliasQry)->(dbCloseArea())
	EndIf
		
		
	If lAbre061
		
		oView	:= FwLoadView("GFEA061")
		oView:SetOperation(MODEL_OPERATION_INSERT)
		oView:oModel:SetActivate({|oModel|X061Load(oModel:GetModel("GFEA061_GVA"),apData[1])})
		oView:SetCloseOnOk({|| .T.})
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
		oFWMVCWindow:Activate()
		
		If oView:GetbuttonWasPressed() == 1 // Cancelar
			lAbre061A	:= .F.
			lAbre061F	:= .F.
		EndIf
		
		oView:DeActivate()
		FreeObj(oView)
		oFWMVCWindow:DeActivate()
		FreeObj(oFWMVCWindow)
		
	EndIf
	
	If lAbre061A
		aAreaGVA := GVA->(GetArea())
		cQuery  := " SELECT MAX(GV9_NRNEG) GV9_NRNEG, MAX(GV9_DTVALI) GV9_DTVALI, MAX(GV9_DTVALF) GV9_DTVALF, COUNT(GV9_NRNEG) GV9_QTDNEG  FROM " + RetSqlName("GV9") + " WHERE GV9_FILIAL = '" + xFilial("GV9") + "' AND GV9_CDEMIT = '" + GVA->GVA_CDEMIT + "' AND GV9_NRTAB = '" + GVA->GVA_NRTAB + "' AND D_E_L_E_T_ = ''"
		cAliasQry := GetNextAlias()
		
		cQuery := changeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->GV9_DTVALI)
			nQtdNeg := (cAliasQry)->GV9_QTDNEG
			If (cAliasQry)->GV9_DTVALF > (cAliasQry)->GV9_DTVALI
				dDataIni := STOD((cAliasQry)->GV9_DTVALF)
			Else
				dDataIni := STOD((cAliasQry)->GV9_DTVALI) + 1
			EndIf
		Else
			dDataIni := DDATABASE
		EndIf 
		
		SetTabScan(apData[2])
		SetInfo("GV9_NRNEG" ,Soma1(PadL(AllTrim((cAliasQry)->GV9_NRNEG),Len(GV9->GV9_NRNEG),"0")))
		SetInfo("GV9_DTVALI",dDataIni)
		
		oView	:= FwLoadView("GFEA061A")
		If aScan(apData[2],{|x| x[1] == "GV9_TPLOTA"}) != 0
			oStru := oView:GetViewStruct("GFEA061A_GV9")
			oStru:SetProperty("GV9_TPLOTA",MVC_VIEW_CANCHANGE,.F.)
		EndIf
		oView:SetOperation(MODEL_OPERATION_INSERT)
		oView:oModel:SetActivate({|oModel|;
									X061Load(oModel:GetModel("GFEA061A_GV9"),apData[2]),;
									X061Load(oModel:GetModel("DETAIL_GV7"),apData[3]),;
									X061Load(oModel:GetModel("DETAIL_GUY"),apData[4]);
									})
		oView:SetCloseOnOk({|| .T.})
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
		oFWMVCWindow:Activate()
		
		If oView:GetbuttonWasPressed() == 1 // Cancelar
			lAbre061F	:= .F.
			If nQtdNeg == 0 
				lDel061 := .T.
			EndIf
		Else
			aGV9Ret[1] := GV9->GV9_CDEMIT
			aGV9Ret[2] := GV9->GV9_NRTAB
			aGV9Ret[3] := GV9->GV9_NRNEG
			aAreaGV91 := GV9->(GetArea())
		EndIf
		
		oView:DeActivate()
		FreeObj(oView)
		oFWMVCWindow:DeActivate()
		FreeObj(oFWMVCWindow)
		
		(cAliasQry)->(dbCloseArea())
		
		RestArea(aAreaGVA)
	EndIf
	
	If lAbre061F .And. MsgYesNo("Deseja gerar as tarifas da negociação?")
		aAreaGV9 := GV9->(GetArea())
		cQuery  := " SELECT GV8_NRROTA FROM " + RetSqlName("GV8") + " WHERE GV8_FILIAL = '" + xFilial("GV8") + "'  AND GV8_CDEMIT = '" + GVA->GVA_CDEMIT + "' AND GV8_NRTAB = '" + GVA->GVA_NRTAB + "' AND GV8_NRNEG = '" + GV9->GV9_NRNEG + "' AND D_E_L_E_T_ = ''"
		cAliasQry1 := GetNextAlias()
		
		cQuery := changeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry1,.F.,.T.)
		
		nRotas := 0
		While !(cAliasQry1)->(Eof())
			nRotas++
			(cAliasQry1)->(dbSkip())
		EndDo
		
		cQuery  := " SELECT GV7_CDFXTV FROM " + RetSqlName("GV7") + " WHERE GV7_FILIAL = '" + xFilial("GV7") + "'  AND GV7_CDEMIT = '" + GVA->GVA_CDEMIT + "' AND GV7_NRTAB = '" + GVA->GVA_NRTAB + "' AND GV7_NRNEG = '" + GV9->GV9_NRNEG + "' AND D_E_L_E_T_ = ''"
		cAliasQry2 := GetNextAlias()
		
		cQuery := changeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)
		
		nFaixas := 0
		While !(cAliasQry2)->(Eof())
			nFaixas++
			(cAliasQry2)->(dbSkip())
		EndDo
		
		If nRotas > 1 .Or. nFaixas > 1
			lAval061F := MsgYesNo("Foram encontradas mais de uma combinação de rotas e faixas. Deseja avaliar todas as tarifas que serão geradas?")
		EndIf
		
		cQuery  := " SELECT GUY_CDCOMP FROM " + RetSqlName("GUY") + " WHERE GUY_FILIAL = '" + xFilial("GUY") + "'  AND GUY_CDEMIT = '" + GVA->GVA_CDEMIT + "' AND GUY_NRTAB = '" + GVA->GVA_NRTAB + "' AND GUY_NRNEG = '" + GV9->GV9_NRNEG + "' AND D_E_L_E_T_ = ''"
		cAliasQry := GetNextAlias()
		
		cQuery := changeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
		If Len(apData[6]) > 0 // Garantir que a tabela guy e gv1 fiquem sincronizadas após alteração do usuário
			
			While !(cAliasQry)->(Eof())
				lTemComp := .F.
				
				For nX := 1 To Len(apData[6])
					SetTabScan(apData[6][nX])
					If GetInfo("GV1_CDCOMP") == (cAliasQry)->GUY_CDCOMP
						lTemComp := .T.
						Exit
					EndIf
				Next nX
				
				If !lTemComp
					aAdd(apData[6],{{"GV1_CDCOMP",(cAliasQry)->GUY_CDCOMP}})
				EndIf
				
				(cAliasQry)->(dbSkip())
			EndDo
			
			nX := 1
			While nX <= Len(apData[6])
				SetTabScan(apData[6][nX])
				(cAliasQry)->(dbGoTop())
				lTemComp := .F.
				While !(cAliasQry)->(Eof())
					If GetInfo("GV1_CDCOMP") == (cAliasQry)->GUY_CDCOMP
						lTemComp := .T.
						Exit
					EndIf
					(cAliasQry)->(dbSkip())
				EndDo
				
				If !lTemComp
					aDel(apData[6],nX)
					aSize(apData[6],Len(apData[6])-1)
				Else
					nX++
				EndIf
				
			EndDo
			
		Else
		
			While !(cAliasQry)->(Eof())
				aAdd(apData[6],{{"GV1_CDCOMP",(cAliasQry)->GUY_CDCOMP}})
				(cAliasQry)->(dbSkip())
			EndDo
			
		EndIf
		
		If lAval061F
			(cAliasQry1)->(dbGoTop())
			While !(cAliasQry1)->(Eof()) .And. lAbre061F
				(cAliasQry2)->(dbGoTop())
				While !(cAliasQry2)->(Eof()) .And. lAbre061F
					RestArea(aAreaGV91)
					SetTabScan(apData[5])
					SetInfo("GV6_CDFXTV",(cAliasQry2)->GV7_CDFXTV)
					SetInfo("GV6_NRROTA",(cAliasQry1)->GV8_NRROTA)
									
					oView	:= FwLoadView("GFEA061F")
	
					oView:SetOperation(MODEL_OPERATION_INSERT)
					oView:oModel:SetActivate({|oModel|;
												X061Load(oModel:GetModel("GFEA061F_GV6"),apData[5]),;
												X061Load(oModel:GetModel("DETAIL_GV1"),apData[6]);
												})
					oView:SetCloseOnOk({|| .T.})
					oFWMVCWindow := FWMVCWindow():New()
					oFWMVCWindow:SetUseControlBar(.T.)
					oFWMVCWindow:SetView(oView)
					oFWMVCWindow:SetCentered(.T.)
					oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
					oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
					oFWMVCWindow:Activate()
					
					If oView:GetbuttonWasPressed() == 1 // Cancelar
						lAbre061F	:= .F.
						If Len(aGv6Ger) > 0
							If MsgYesNo("Deseja eliminar todas as tarifas geradas até o momento?")
								lDel061F := .T.
							EndIf
						EndIf
					Else
						aAdd(aGv6Ger,GV6->(Recno()))
					EndIf
					
					oView:DeActivate()
					FreeObj(oView)
					oFWMVCWindow:DeActivate()
					FreeObj(oFWMVCWindow)
					
					(cAliasQry2)->(dbSkip())
				EndDo
				(cAliasQry1)->(dbSkip())
			EndDo
		Else
			GFEA61FTAR(.T.,apData[5],apData[6])
		EndIf
		
		(cAliasQry1)->(dbCloseArea())
		(cAliasQry2)->(dbCloseArea())
		RestArea(aAreaGV9)
	EndIf
	
	If lDel061F
		aGV9Ret := {,,}
		For nX := 1 To Len(aGv6Ger)
			GV6->(DbGoTo(aGv6Ger[nX]))
			oModel := FwLoadModel("GFEA061F")
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			FwModelActive(oModel)
			If oModel:Activate() .And. oModel:VldData()
				lRet := oModel:CommitData()
				If !lRet
					MsgInfo(X061MdlMsg(oModel))
					lDel061F := .F.
				EndIf
			Else
				MsgInfo("Não foi possível eliminar a tarifa. Motivo:" + CRLF + X061MdlMsg(oModel))
				lDel061F := .F.
			EndIf
			oModel:DeActivate()
			FreeObj(oModel)
		Next nX
		
		If lDel061F
			If MsgYesNo("Deseja eliminar a negociação gerada?")
				lDel061A := .T.
			Else
				lDel061A := .F.
				lDel061 := .F.
			EndIf
		Else
			lDel061A := .F.
			lDel061 := .F.
		EndIf
		
	EndIf
	
	If lDel061A
		aGV9Ret := {,,}
		RestArea(aAreaGV9)
		oModel := FwLoadModel("GFEA061A")
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		FwModelActive(oModel)
		If oModel:Activate() .And. oModel:VldData()
			lRet := oModel:CommitData()
			If !lRet
				MsgInfo(X061MdlMsg(oModel))
				lDel061A := .F.
			EndIf
		Else
			MsgInfo("Não foi possível eliminar a negociação.Motivo:" + CRLF + X061MdlMsg(oModel))
			lDel061A := .F.
		EndIf
		oModel:DeActivate()
		FreeObj(oModel)
		
		If lDel061A
			If nQtdNeg == 0
				lDel061 := .T.
			Else
				lDel061 := .F.
			EndIf
		Else
			lDel061 := .F.
		EndIf
		
	EndIf
	
	If lAbre061 .And. lDel061 .And. MsgYesNo("Deseja eliminar a tabela gerada?")
		aGV9Ret := {,,}
		oModel := FwLoadModel("GFEA061")
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		FwModelActive(oModel)
		If oModel:Activate() .And. oModel:VldData()
			lRet := oModel:CommitData()
			If !lRet
				MsgInfo(X061MdlMsg(oModel))
			EndIf
		Else
			MsgInfo("Não foi possível eliminar a tabela.Motivo:" + CRLF + X061MdlMsg(oModel))
		Endif
		oModel:DeActivate()
		FreeObj(oModel)
	EndIf

	If !Empty(oAreaModel)
		FwModelActive(oAreaModel)
	EndIf
	
	If !Empty(oAreaView)
		FwViewActive(oAreaView)
	EndIf
	
	aSize(aTabScan,0)
	
Return aGV9Ret

Function X061MdlMsg(oModel)
	Local cErro := ""
	Local aErro := oModel:GetErrorMessage()
	
	cErro += "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' + CRLF
	cErro += "Id do campo de origem: "     + ' [' + AllToChar( aErro[2] ) + ']' + CRLF
	cErro += "Id do formulário de erro: "  + ' [' + AllToChar( aErro[3] ) + ']' + CRLF
	cErro += "Id do campo de erro: "       + ' [' + AllToChar( aErro[4] ) + ']' + CRLF
	cErro += "Id do erro: "                + ' [' + AllToChar( aErro[5] ) + ']' + CRLF
	cErro += "Mensagem do erro: "          + ' [' + AllToChar( aErro[6] ) + ']' + CRLF
	cErro += "Mensagem da solução: "       + ' [' + AllToChar( aErro[7] ) + ']' + CRLF
	cErro += "Valor atribuído: "           + ' [' + AllToChar( aErro[8] ) + ']' + CRLF
	cErro += "Valor anterior: "            + ' [' + AllToChar( aErro[9] ) + ']' + CRLF
	
Return cErro

Function X061Load(oModel,aTab)
	Local nX
	Local nY
	
	If Len(aTab) > 0
		If ValType(aTab[1][1]) == "A"
			For nX := 1 To Len(aTab)
				If nX > 1
					oModel:AddLine()
				EndIf
				For nY := 1 To Len(aTab[nX])
					If !oModel:SetValue(aTab[nX][nY][1],aTab[nX][nY][2])
						Return .F.
					EndIf
				Next nY
			Next nX
		Else
			For nX := 1 To Len(aTab)
				If !oModel:SetValue(aTab[nX][1],aTab[nX][2])
					Return .F.
				EndIf
			Next nX	
		EndIf
	EndIf
Return

Function GFEX61FWHN(cCampo)
	If Empty(FwFldGet('COP_COMP'))
		Return .F.
	Else
		Return GFEA61FWHN(cCampo,AllTrim(Posicione('GV2',1,xFilial('GV2')+FwFldGet('COP_COMP'),'GV2_ATRCAL')))
	EndIf
Return

Static Function GetListSql(aList,cCampo,cCampoSql)
	Local cRet := ""
	Local nX
	Local aDeAte := {}
	Local aIn := {} 
	Local cTab
	Local nLen
	Private cSeek
	Private cSeek2
	Default cCampoSql := cCampo
	
	If SubStr(cCampo,3,1) == "_"
		cTab := "S" + SubStr(cCampo,1,2)
	Else
		cTab := SubStr(cCampo,1,3)
	EndIf
	
	nLen := Len(&(cTab + "->" + cCampo))
	
	cRet := "("
	
	If Len(aList) > 0
		For nX := 1 To Len(aList)
			nPos := At("-",aList[nX])
			If nPos > 0
				cSeek := Padr(SubStr(aList[nX],1,(nPos-1)),nLen)
				cSeek2 := Padr(SubStr(aList[nX],nPos+1),nLen)
				If aScan(aDeAte,{|x|x[1] == cSeek .And. x[2] == cSeek2}) == 0
					aAdd(aDeAte, {cSeek,cSeek2})
				Endif
			Else
				cSeek := "'" + Padr(aList[nx],nLen) + "'"
				If aScan(aIn,{|x|x == cSeek}) == 0
					aAdd(aIn,cSeek)
				EndIf
			EndIf
		Next nX
		
		For nX := 1 to Len(aIn)
			
			If nX == 1
				cRet += cCampoSql + " IN (" + aIn[nX]
			Else
				cRet += "," + aIn[nX]
			EndIf
			
			If nX == Len(aIn)
				cRet += ")
			EndIf
			
		Next nX
		
		If Len(aDeAte) > 0
			If Len(aIn) > 0
				cRet += " OR "
			EndIf
			For nX := 1 To Len(aDeAte)
				If nX != 1
					cRet += " OR "
				EndIf
				cRet += "(" + cCampoSql + " >= '" + aDeAte[nX][1]  + "' AND " + cCampoSql + " <= '" + aDeAte[nX][2]  + "')"
			Next nX
		EndIf
	Else
		cRet += cCampoSql + " >= '" + Space(nLen)+ "' AND "
		cRet += cCampoSql + " <= '" + Replicate('Z',nLen)  + "'"
	EndIf
	
	cRet += ")"
Return cRet

Function GFEX061LCP(cGV1_CDCOMP)
	Local cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+cGV1_CDCOMP,"GV2_ATRCAL"))
	Local oModel := FwModelActive()
	Local oModelGV1 := oModel:GetModel('DETAIL_03')
	
	If cAtribCalc $ "29"
		oModelGV1:LoadValue("COP_VLFIXO",0)
		oModelGV1:LoadValue("COP_VLUNNM",0)
		oModelGV1:LoadValue("COP_VLFRAC",0)
		oModelGV1:LoadValue("COP_VLMINN",0)
		oModelGV1:LoadValue("COP_VLFXEX",0)
		oModelGV1:LoadValue("COP_VLUNEX",0)
		oModelGV1:LoadValue("COP_CALCEX",'2')  
	ElseIf cAtribCalc $ "8"
		oModelGV1:LoadValue("COP_PCNORM",0)
		oModelGV1:LoadValue("COP_VLUNNM",0)
		oModelGV1:LoadValue("COP_VLFRAC",0)
		oModelGV1:LoadValue("COP_VLMINN",0)
		oModelGV1:LoadValue("COP_VLLIMI",0)
		oModelGV1:LoadValue("COP_VLFXEX",0)
		oModelGV1:LoadValue("COP_PCEXTR",0)
		oModelGV1:LoadValue("COP_VLUNEX",0)
	Else
		oModelGV1:LoadValue("COP_PCNORM",0)
		oModelGV1:LoadValue("COP_PCEXTR",0)
	EndIf
		
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RegistComp
Registro do comparativo
@author felipe.m
@since 02/03/216
@version 1.0
@return Nil
@see PCREQ-9331
/*/
//---------------------------------------------------------------------
Static Function RegistComp()
Local aAreaAnt    := GetArea()
Local cCdTransp   := FwFldGet("GWU_TRP")     
Local cNrTab      := FwFldGet("GWU_NRTAB")
Local cNrNeg      := FwFldGet("GWU_NRNEG")
Local cTrpComp    := FwFldGet("GWU_TRPCOM")
Local cNrTabCmp   := FwFldGet("GWU_TABCMP")
Local cNrNegCmp   := FwFldGet("GWU_NEGCMP")
Local dDtPerIni   := FwFldGet("GWU_PERINI")
Local dDtPerFim   := FwFldGet("GWU_PERFIM")
Local cCidDesIni  := FwFldGet("GWU_CIDINI")
Local cCidDesFim  := FwFldGet("GWU_CIDFIM")
Local cUFDesIni   := FwFldGet("GWU_UFINI")
Local cUFDesFim   := FwFldGet("GWU_UFFIM")
Local cDCCalc     := FwFldGet("GWU_DCCALC")
Local cManRed     := FwFldGet("GWU_MANRED")
Local cFretEnt    := FwFldGet("GWU_FRTENT")
Local cFretSai    := FwFldGet("GWU_FRTSAI")
Local nFrtReal    := FwFldGet("COM__TOT02")
Local nFrtSimu    := FwFldGet("COM__TOT03")
Local aValorFld   := {}
Local aUfs        := {}
Local aCidades    := {}
Local aTotais     := {}
Local aGW1_VOLUME := {}
Local aGW1_PESOR  := {}
Local aGW1_VALOR  := {}
Local cQuery      := ""
Local cAliasQry   := ""
Local cCodCot     := ""
Local cSeqCot     := ""
Local cObsCot     := ""
Local cInfCmp     := ""
Local cAux        := ""
Local cPicture    := ""
Local nRecnoGV9   := 0
Local nRecnoGVQ   := 0
Local nI          := 0
Local nY		  := 0
Local aRange	  := {}
Local lNovoComp   := .F.
Local lContinue   := .T.
Local lUsaFiltro  := .F.
Local cOR         := ""
	
	If Empty(cTrpComp) .Or. Empty(cNrTabCmp) .Or. Empty(cNrNegCmp)
		Help(,,"HELP",,"Transportador, tabela e negociação de comparação precisam ser informados.",1,0)
		lContinue := .F.
	EndIf
	
	If lContinue .And. (Empty(cCdTransp) .Or. Empty(cNrTab) .Or. Empty(cNrNeg))
		Help(,,"HELP",,"Transportador, tabela e negociação de seleção precisam ser informados.",1,0)
		lContinue := .F.
	EndIf
	
	// Verifica se a negociação já está liberada
	If lContinue .And. NrNegLib(cTrpComp,cNrTabCmp,cNrNegCmp,@cCodCot,@cSeqCot,@nRecnoGV9,@nRecnoGVQ,@lNovoComp)
		Help(,,"HELP",,"Não é possível registrar comparativos através dessa ação quando a negociação já está liberada ou pendente de aprovação.",1,0)
		lContinue := .F.
	EndIf
	
	If lContinue
		// Caso não tenha realizado a comparação
		If FwFldGet("COM__TOT03") == 0
			Help(,,"HELP",,"Não possui valor em frete simulado, realize a operação 'Comparar'.",1,0)
			lContinue := .F.
		Else
			Pergunte("GFEX061",.F.)
			SX1->(dbSetOrder(1))
			If SX1->(MsSeek('GFEX061   01'))
				lUsaFiltro := MV_PAR01 == 1
				aUfs := Str2Arr(Upper(MV_PAR02), ";") // Parametro tipo 'Range'
				aCidades := Str2Arr(Upper(MV_PAR03), ";") // Parametro tipo 'Range'
			Else
				lUsaFiltro := .F.
				aUfs := {}
				aCidades := {}
			EndIf
			// Troca o valor das variáveis de UF de - até e Cidade de - até para que 
			// quando utilizar o filtro avançado, não barre dizendo que foi alterado
			// esses valores no formulário ao registrar o comparativo.
			If lUsaFiltro
				cCidDesIni := aSaveFld[1][9]  // Cidade de
				cCidDesFim := aSaveFld[1][10] // Cidade até
				cUFDesIni  := aSaveFld[1][11] // UF de
				cUFDesFim  := aSaveFld[1][12] // UF até
			EndIf
			
			aValorFld := {{cCdTransp,cNrTab,cNrNeg,cTrpComp,cNrTabCmp,cNrNegCmp,dDtPerIni,dDtPerFim,;
				cCidDesIni,cCidDesFim,cUFDesIni,cUFDesFim,cDCCalc,cManRed,cFretEnt,cFretSai,lUsaFiltro/*Se utilizou filtro avançado*/},aUfs,aCidades}
			
			// Verifica se houve alguma alteração no formulário para realizar a comparação novamente
			If DifVals(aSaveFld[1],aValorFld[1]) // Informações do formulário
				lContinue := .F.
			ElseIf lUsaFiltro
				// Verifica se o filtro avançado foi alterado
				If (Len(aSaveFld[2]) != Len(aValorFld[2])) .Or. (Len(aSaveFld[3]) != Len(aValorFld[3])) // UFs // Cidades
					lContinue := .F.
				Else
					If DifVals(aSaveFld[2],aValorFld[2]) // Diferença entre range de UFs
						lContinue := .F.
					ElseIf DifVals(aSaveFld[3],aValorFld[3]) // Diferença entre range de Cidades
						lContinue := .F.
					EndIf
				EndIf
			EndIf
			
			If !lContinue
				Help(,,"HELP",,"O formulário foi alterado, realize a operação 'Comparar' novamente.",1,0)
			EndIf
		EndIf
	EndIf
	
	If lContinue .And. !MsgYesNo("Confirma o registro do comparativo?")
		lContinue := .F.
	EndIf
	
	If lContinue
		(cAliLDOC)->(dbGoTop())
		aTotais := {0,0,0,0}
		
		cAux := ""
		aGW1_VOLUME := TamSx3("GW8_VOLUME")
		aGW1_PESOR  := TamSx3("GW8_PESOR")
		aGW1_VALOR  := TamSx3("GW8_VALOR")
		
		cQuery := " SELECT SUM(GW8.GW8_VOLUME) GW1_VOLUME,"
		cQuery +=        " SUM(GW8.GW8_PESOR) GW1_PESOR,"
		cQuery +=        " SUM(GW8.GW8_VALOR) GW1_VALOR"
		cQuery +=   " FROM "+RetSqlName("GW1")+" GW1"
		cQuery +=  " INNER JOIN "+RetSqlName("GW8")+" GW8"
		cQuery +=     " ON GW8.GW8_FILIAL = '"+xFilial("GW8")+"'"
		cQuery +=    " AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
		cQuery +=    " AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
		cQuery +=    " AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
		cQuery +=    " AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
		cQuery +=    " AND GW8.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE GW1.D_E_L_E_T_ = ' ' "
		cQuery +=  " AND ("

		Do While (cAliLDOC)->(!Eof())

			// Adiciona os documentos para buscar os totais de volume, peso e valor dos itens 
			cQuery +=  cOR +" (GW1.GW1_FILIAL = '" + (cAliLDOC)->COM_FILIAL + "'"
			cQuery +=    " AND GW1.GW1_CDTPDC = '" + (cAliLDOC)->COM_TPDC + "'"
			cQuery +=    " AND GW1.GW1_EMISDC = '" + (cAliLDOC)->COM_EMISDC + "'"
			cQuery +=    " AND GW1.GW1_SERDC  = '" + (cAliLDOC)->COM_SERDC + "'"
			cQuery +=    " AND GW1.GW1_NRDC   = '" + (cAliLDOC)->COM_NRDC + "'"
			cQuery +=    " ) "
			
			If cAux != (cAliLDOC)->COM_NRROM
				cAux := (cAliLDOC)->COM_NRROM
				aTotais[4] += 1 // Quantidade de Romaneios
			EndIf
			cOR := ' OR '
			(cAliLDOC)->(dbSkip())
		EndDo
		cQuery +=  " ) "

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		TCSetField(cAliasQry,"GW1_VOLUME","N",aGW1_VOLUME[1],aGW1_VOLUME[2])
		TCSetField(cAliasQry,"GW1_PESOR" ,"N",aGW1_PESOR[1] ,aGW1_PESOR[2])
		TCSetField(cAliasQry,"GW1_VALOR" ,"N",aGW1_VALOR[1] ,aGW1_VALOR[2])
		If (cAliasQry)->(!Eof())
			aTotais[1] += (cAliasQry)->GW1_PESOR  // Peso Real Total
			aTotais[2] += (cAliasQry)->GW1_VALOR  // Valor Mercadoria Total
			aTotais[3] += (cAliasQry)->GW1_VOLUME // Volume Total
		EndIf
		(cAliasQry)->(dbCloseArea())
	
		// Construção das informações gravadas na observação
		cObsCot := "Período De: "  + DtoC(dDtPerIni) + CLRF
		cObsCot += "Período Até: " + DtoC(dDtPerFim) + CLRF
		// Utiliza o filtro avançado
		If lUsaFiltro
			cObsCot += "UFs: " + MV_PAR02 + CLRF
			cObsCot += "Cidades: " + MV_PAR03 + CLRF
		Else
			cObsCot += "UF De: "      + PadR(cUfDesIni,Len(GU7->GU7_CDUF)) + CLRF
			cObsCot += "UF Até: "     + PadR(cUfDesFim,Len(GU7->GU7_CDUF)) + CLRF
			cObsCot += "Cidade De: "  + PadR(cCidDesIni,Len(GU7->GU7_NRCID)) + CLRF
			cObsCot += "Cidade Até: " + PadR(cCidDesFim,Len(GU7->GU7_NRCID)) + CLRF
		EndIf
		cObsCot += "Somente Dc Calc: " + Iif(PadR(cDCCalc,1)=="1","Sim","Não") + CLRF
		cObsCot += "Mantém Redesp: "   + IIf(PadR(cManRed,1)=="1","Sim","Não") + CLRF
		cObsCot += "Frete Entrada: "   + Iif(PadR(cFretEnt,1)=="1","Sim","Não") + CLRF
		cObsCot += "Frete Saída: "     + Iif(PadR(cFretSai,1)=="1","Sim","Não") + CLRF
		cObsCot += CLRF
		cObsCot += "Indicadores dos doctos selecionados"+ CLRF

		cPicture  := GetSx3Cache("GW8_VALOR","X3_PICTURE")
		
		cObsCot += "Peso Real Total: "        + AllTrim(Transform(aTotais[1],cPicture)) + CLRF
		cObsCot += "Valor Mercadoria Total: " + AllTrim(Transform(aTotais[2],cPicture)) + CLRF
		cObsCot += "Volume Total: "           + AllTrim(Transform(aTotais[3],cPicture)) + CLRF
		cObsCot += CLRF
		cObsCot += "Valor Realizado Indicador:" + CLRF
		cObsCot += " - Tonelada: "        + AllTrim(Transform( (nFrtReal / ( aTotais[1] / 1000 )),cPicture ))  + CLRF
		cObsCot += " - Valor Mercadoria (%):" + AllTrim(Transform( (nFrtReal / aTotais[2]) * 100,cPicture )) + CLRF
		cObsCot += " - Volume: "          + AllTrim(Transform( (nFrtReal / aTotais[3]),cPicture )) + CLRF
		cObsCot += "Valor Simulado Indicador:" + CLRF
		cObsCot += " - Tonelada: "        + AllTrim(Transform( (nFrtSimu / ( aTotais[1] / 1000 )),cPicture )) + CLRF
		cObsCot += " - Valor Mercadoria (%):" + AllTrim(Transform( (nFrtSimu / aTotais[2]) * 100,cPicture )) + CLRF
		cObsCot += " - Volume: "          + AllTrim(Transform( (nFrtSimu / aTotais[3]),cPicture )) + CLRF
		cObsCot += CLRF
		cObsCot += "Quantidade de Doctos: "    + cValtoChar(FwFldGet("COM__TOT01")) + CLRF
		cObsCot += "Quantidade de Doctos Simulados: "    + cValtoChar(FwFldGet("COM__TOT04")) + CLRF
		cObsCot += "Quantidade de Romaneios: " + cValtoChar(aTotais[4]) + CLRF
		
		// Guarda as informações do comparativo para a ação "Verificar Comparativo"
		cInfCmp := "FLAV" + IIf(lUsaFiltro,"1","2")
		cInfCmp += "PRDE" + DtoS(dDtPerIni)
		cInfCmp += "PRAT" + DtoS(dDtPerFim)
		If lUsaFiltro
			For nI := 1 To Len(aUfs)
				cInfCmp += "UFFL" + aUfs[nI]
			Next nI
			For nI := 1 To Len(aCidades)
				aRange := Str2Arr(aCidades[nI],'-')
				If Len(aRange) > 0
					cInfCmp += "CDFL"
				EndIf
				For nY := 1 To Len(aRange)
					If !Empty(aRange[nY])
						If nY > 1
							cInfCmp += "-"
						EndIf
						cInfCmp += aRange[nY]
					EndIf
				Next nY
			Next nI
		Else
			cInfCmp += "UNFD" + PadR(cUfDesIni,Len(GU7->GU7_CDUF)) + CLRF
			cInfCmp += "UNFA" + PadR(cUfDesFim,Len(GU7->GU7_CDUF)) + CLRF
			cInfCmp += "CIDD" + PadR(cCidDesIni,Len(GU7->GU7_NRCID)) + CLRF
			cInfCmp += "CIDA" + PadR(cCidDesFim,Len(GU7->GU7_NRCID)) + CLRF
		EndIf
		cInfCmp += "SDCL" + PadR(cDCCalc,1)
		cInfCmp += "MRES" + PadR(cManRed,1)
		cInfCmp += "FENT" + PadR(cFretEnt,1)
		cInfCmp += "FSAI" + PadR(cFretSai,1)
		
		// Quanto não há cotação ou quando gera uma nova sequência para a mesma negociação
		If Empty(cCodCot+cSeqCot) .Or. lNovoComp
			RecLock("GVQ",.T.)
			GVQ->GVQ_FILIAL := xFilial("GVQ")
			GVQ->GVQ_TPCOT  := "1"
			If Empty(cCodCot+cSeqCot)
				// Primeiro registro da cotação
				GVQ->GVQ_CODCOT := GetSxeNum("GVQ","GVQ_CODCOT")
				GVQ->GVQ_SEQCOT := StrZero(1,Len(GVQ->GVQ_SEQCOT))
				ConfirmSx8()
			Else
				// Registro de um novo comparativo para a mesma negociação
				GVQ->GVQ_CODCOT := cCodCot
				GVQ->GVQ_SEQCOT := Soma1(cSeqCot)
			EndIf
		Else
			// Posiciona GVQ para apenas atualizar
			GVQ->(dbGoTo( nRecnoGVQ ))
			RecLock("GVQ",.F.)
		EndIf
		
		// Atualiza as informações do comparativo
		GVQ->GVQ_DTIMPL := Date()
		GVQ->GVQ_HRIMPL := StrTran(SubStr(Time(),1,5),":")
		GVQ->GVQ_ENVCOP := "2" // Não enviado
		GVQ->GVQ_OBSCOT := cObsCot
		GVQ->GVQ_INFCMP := cInfCmp // Campo 'não usado' para guardar as informações do compatarivo
		GVQ->GVQ_VALCOT := nFrtSimu
		GVQ->GVQ_CDEMIT := cCdTransp
		GVQ->GVQ_NRTAB  := cNrTab
		GVQ->GVQ_NRNEG  := cNrNeg
		GVQ->(MsUnlock())
		
		// Atualização da ultima cotação na negociação processada
		GV9->(dbGoTo( nRecnoGV9 ))
		If GV9->GV9_SEQCOT != GVQ->GVQ_SEQCOT
			RecLock("GV9",.F.)
			GV9->GV9_CODCOT := GVQ->GVQ_CODCOT
			GV9->GV9_SEQCOT := GVQ->GVQ_SEQCOT
			GV9->(MsUnlock())
		EndIf
		
		// Utiliza Controle de Aprovação (1=Sim;2=Não)
		If SuperGetMv("MV_APRTAB",.F.,"2") == "1" .And. SuperGetMv("MV_APRCOP",.F.,"2") != "0"
			// Enviar negociação para aprovação (0=Não Utiliza;1=Automático;2=Perguntar)
			If SuperGetMv("MV_APRCOP",.F.,"2") == "1" .Or. MsgYesNo("Enviar negociação para aprovação?")
				GFEA61AENV()
			EndIf
		EndIf
	EndIf

RestArea(aAreaAnt)
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} DifVals
Realiza a comparação dos dois arrays com os valores utilizados 
na comparação vs valores do formulário para procurar por diferença 
@author felipe.m
@since 02/03/216
@version 1.0
@return lDiferent, Lógico, (se encontrar diferença)
/*/
//---------------------------------------------------------------------
Static Function DifVals(xVal1,xVal2,nPos)
Local lDiferent := .F.

Default nPos := 1
	
	If nPos <= Len(xVal1)
		If xVal1[nPos] != xVal2[nPos]
			lDiferent := .T.
		Else
			lDiferent := DifVals(xVal1,xVal2,++nPos)
		EndIf
	EndIf
Return lDiferent
//---------------------------------------------------------------------
/*/{Protheus.doc} NrNegLib
Verifica se a negociação já está liberada/enviada para aprovação
@author felipe.m
@since 02/03/216
@version 1.0
@param cCdEmit, Caracter, (Código do emitente/transportador)
@param cNrTab, Caracter, (Número da tabela de frete)
@param cNrNeg, Caracter, (Número da negociação)
@param @cCodCot, Caracter, (Código da cotação)
@param @cSeqCot, Caracter, (Sequência da cotação)
@param @nRecnoGV9, Numérico, (Registro da negociação de frete)
@param @nRecnoGVQ, Numérico, (Registro da cotação)
@param @lNovoComp, Lógico, (Indicador de criação de um novo comparativo)
@return lRet, Lógico, (se negociação está liberada/enviada para aprovação)
/*/
//---------------------------------------------------------------------
Static Function NrNegLib(cTrpComp,cNrTabCmp,cNrNegCmp,cCodCot,cSeqCot,nRecnoGV9,nRecnoGVQ,lNovoComp)
Local aAreaAnt := GetArea()
Local lRet := .F.
Local cQuery := ""
Local cAliasQry := ""

Default cCodCot := ""
Default cSeqCot := ""
Default nRecnoGV9 := 0
Default nRecnoGVQ := 0
Default lNovoComp := .F.

	cQuery := " SELECT GV9.GV9_CODCOT,"
	cQuery +=        " GV9.GV9_SEQCOT,"
	cQuery +=        " GV9.GV9_SIT,"
	cQuery +=        " GV9.GV9_ENVAPR,"
	cQuery +=        " GVQ.GVQ_ENVCOP,"
	cQuery +=        " GV9.R_E_C_N_O_ RECNOGV9,"
	cQuery +=        " GVQ.R_E_C_N_O_ RECNOGVQ"
	cQuery +=   " FROM "+RetSqlName("GV9")+" GV9"
	cQuery +=   " LEFT JOIN "+RetSqlName("GVQ")+" GVQ"
	cQuery +=     " ON GVQ.GVQ_FILIAL = '"+xFilial("GVQ")+"'"
	cQuery +=    " AND GVQ.GVQ_TPCOT  = '1'"
	cQuery +=    " AND GVQ.GVQ_CODCOT = GV9.GV9_CODCOT"
	cQuery +=    " AND GVQ.GVQ_SEQCOT = GV9.GV9_SEQCOT"
	cQuery +=    " AND GVQ.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE GV9.GV9_FILIAL = '"+xFilial("GV9")+"'"
	cQuery +=    " AND GV9.GV9_CDEMIT = '"+cTrpComp+"'"
	cQuery +=    " AND GV9.GV9_NRTAB  = '"+cNrTabCmp+"'"
	cQuery +=    " AND GV9.GV9_NRNEG  = '"+cNrNegCmp+"'"
	cQuery +=    " AND GV9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		// Situação Liberada ou Enviada para Aprovação
		If ((cAliasQry)->GV9_SIT == "2" .Or. (cAliasQry)->GV9_ENVAPR == "1") .And. SuperGetMv("MV_APRTAB",.F.,"2") == "1"
			lRet := .T.
		Else
			cCodCot   := (cAliasQry)->GV9_CODCOT
			cSeqCot   := (cAliasQry)->GV9_SEQCOT
			nRecnoGV9 := (cAliasQry)->RECNOGV9
			nRecnoGVQ := (cAliasQry)->RECNOGVQ
			lNovoComp := (cAliasQry)->GVQ_ENVCOP == "1" // Não enviado
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
	
RestArea(aAreaAnt)
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} VerifComp
Verificar comparativo
@author felipe.m
@since 08/03/216
@version 1.0
@return Nil
@see PCREQ-9331
/*/
//---------------------------------------------------------------------
Static Function VerifComp()
Local cTrpComp  := FwFldGet("GWU_TRPCOM")
Local cNrTabCmp := FwFldGet("GWU_TABCMP")
Local cNrNegCmp := FwFldGet("GWU_NEGCMP")
Local nAlt      := (GetScreenRes()[2])
Local nLrg      := (GetScreenRes()[1]-100)
Local oBrw      := Nil
Local oDlg      := Nil
Local oPnlA     := Nil
Local oPnlB     := Nil
Local cCodCot   := ""
// O que será executado ao confirmar ou clicar 2 vezes no registro
Local bConfirm  := { || InfoCompar(),oDlg:End(),GFEX061CR(),ShowDifer() }
	
	If Empty(cTrpComp) .Or. Empty(cNrTabCmp) .Or. Empty(cNrNegCmp)
		Help(,,"HELP",,"Informe o Transportador, Nr Tabela e Nr Negociação em 'Transportador p/ Comparação'.",1,0)
		Return Nil
	EndIf
	
	If Empty(cCodCot := Posicione("GV9",1,xFilial("GV9")+cTrpComp+cNrTabCmp+cNrNegCmp,"GV9_CODCOT"))
		Help(,,"HELP",,"Não existem cotações registradas.",1,0)
		Return Nil
	EndIf
	
	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	Define MsDialog oDlg Title "Cotações da negociação" From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_BOTTOM

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	@ 07,010 Say "Transportadora:" Of oPnlA COLOR CLR_BLACK Pixel
	@ 05,063 MSGET cTrpComp  Picture "@!" Of oPnlA When .F. Pixel
	
	@ 07,162 Say "Nr Tabela:"      Of oPnlA COLOR CLR_BLACK Pixel
	@ 05,190 MSGET cNrTabCmp Picture "@!" Of oPnlA When .F. Pixel
	
	@ 21,015 Say "Nr Negociação:"  Of oPnlA COLOR CLR_BLACK Pixel
	@ 19,063 MSGET cNrNegCmp Picture "@!" Of oPnlA When .F. Pixel
	
	oBrw := FWMBrowse():New()
	oBrw:SetOwner(oPnlB)
	oBrw:SetAlias("GVQ")
	oBrw:DisableDetail()
	oBrw:SetMenuDef("GFEX062")
	oBrw:AddLegend("GVQ_ENVCOP == '1'","GREEN" ,"Enviada") // "Enviada"
	oBrw:AddLegend("GVQ_ENVCOP == '2'","ORANGE","Não Enviada") // "Não Enviada"
	oBrw:SetFilterDefault("@ GVQ_FILIAL = '"+xFilial("GVQ")+"' AND GVQ_TPCOT = '1' AND GVQ_CODCOT = '"+cCodCot+"'")
	oBrw:Activate()
	oBrw:SetDoubleClick(bConfirm)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bConfirm,{||oDlg:End()},,{/*aButtons*/}) Centered

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} InfoCompar
Atribui as informação do comparativo ao formulário para a recomparação
@author felipe.m
@since 08/03/216
@version 1.0
@return Nil
@see PCREQ-9331
/*/
//---------------------------------------------------------------------
Static Function InfoCompar()
Local oModel     := FwModelActive()
Local oView      := FwViewActive()
Local oModelTrp  := oModel:GetModel("GFEX061_01")
Local cObsCot    := GVQ->GVQ_INFCMP
Local nPos       := 0
Local nAux       := 0
Local nUlt		 := 0
Local lUsaFiltro := .F.
Local cUFs       := ""
Local cCidades   := ""
	
	If Empty(GVQ->GVQ_CDEMIT)
		Return Nil
	EndIf
	
	// Atualiza a transportadora da tela
	oModelTrp:SetValue("GWU_TRP"  ,GVQ->GVQ_CDEMIT)
	// Atualiza o número da tabela de frete da tela
	oModelTrp:SetValue("GWU_NRTAB",GVQ->GVQ_NRTAB)
	// Atualiza o número da negociação da tabela de frete da tela
	oModelTrp:SetValue("GWU_NRNEG",GVQ->GVQ_NRNEG)
	
	If (nPos := At("FLAV",cObsCot) + 4) > 0
		// Verifica se o comparativo foi feito com Filtro Avançado
		lUsaFiltro := SubStr(cObsCot,nPos,1) == "1"
	EndIf
	
	If (nPos := At("PRDE",cObsCot) + 4) > 0
		// Atualiza o campo "Período De:" da tela
		oModelTrp:SetValue("GWU_PERINI", StoD( SubStr(cObsCot,nPos,TamSx3("GW1_DTEMIS")[1]) ) )
	EndIf
	
	If (nPos := At("PRAT",cObsCot,nPos) + 4) > 0
		// Atualiza o campo "Período Até:" da tela
		oModelTrp:SetValue("GWU_PERFIM", StoD( SubStr(cObsCot,nPos,TamSx3("GW1_DTEMIS")[1]) ) )
	EndIf
	
	If (nAux := At("UNFD",cObsCot,nPos) ) > 0
		nPos := nAux + 4
		// Atualiza o campo "UF De:" da tela
		oModelTrp:SetValue("GWU_UFINI", SubStr(cObsCot,nPos,Len(GU7->GU7_CDUF)) )
	EndIf
	
	If (nAux := At("UNFA",cObsCot,nPos)) > 0
		nPos := nAux + 4
		// Atualiza o campo "UF Até:" da tela
		oModelTrp:SetValue("GWU_UFFIM", SubStr(cObsCot,nPos,Len(GU7->GU7_CDUF)) )
	EndIf
	
	If (nAux := At("CIDD",cObsCot,nPos)) > 0
		nPos := nAux + 4
		// Atualiza o campo "UF De:" da tela
		oModelTrp:SetValue("GWU_CIDINI", SubStr(cObsCot,nPos,Len(GU7->GU7_NRCID)) )
	EndIf
	
	If (nAux := At("CIDA",cObsCot,nPos)) > 0
		nPos := nAux + 4
		// Atualiza o campo "Cidade Até:" da tela
		oModelTrp:SetValue("GWU_CIDFIM", SubStr(cObsCot,nPos,Len(GU7->GU7_NRCID)) )
	EndIf
	
	Do While (nAux := At("UFFL",cObsCot,nPos)) > 0
		nPos := nAux + 4
		// Atualização do campo "UFs" do pergunte
		If ( nUlt := At("UFFL",cObsCot,nPos) ) > 0 
			nUlt := nUlt - nPos
		Else
			If ( nUlt := At("CDFL",cObsCot,nPos) ) > 0
				nUlt := nUlt - nPos
			Else
				nUlt := At("SDCL",cObsCot,nPos)-nPos
			EndIf
		EndIf
		cUFs += AllTrim( SubStr( cObsCot, nPos, nUlt) ) + ';'
		
	EndDo
	
	Do While (nAux := At("CDFL",cObsCot,nPos)) > 0
		nPos := nAux + 4
		// Atualização do campo "Cidades" do pergunte
		cCidades += AllTrim( SubStr( cObsCot, nPos,If( ( At("CDFL",cObsCot,nPos) > 0 ), At("CDFL",cObsCot,nPos)-nPos, At("SDCL",cObsCot,nPos)-nPos ) ) )+";"
		
	EndDo
	
	// Atualização do pergunte GFEX061 (opção filtro avançado)
	If lUsaFiltro
		SetMVValue("GFEX061","MV_PAR01",1)
		SetMVValue("GFEX061","MV_PAR02",cUFs)
		SetMVValue("GFEX061","MV_PAR03",cCidades)
	Else
		SetMVValue("GFEX061","MV_PAR01",2)
	EndIf
	
	If (nPos := At("SDCL",cObsCot,nPos) + 4) > 0
		// Atualiza o campo "Somente Dc Calc:" da tela
		oModelTrp:SetValue("GWU_DCCALC", SubStr(cObsCot,nPos,1) )
	EndIf
	
	If (nPos := At("MRES",cObsCot,nPos) + 4) > 0
		// Atualiza o campo "Mantém Redesp:" da tela
		oModelTrp:SetValue("GWU_MANRED", SubStr(cObsCot,nPos,1) )
	EndIf
	
	If (nPos := At("FENT",cObsCot,nPos) + 4) > 0
		// Atualiza o campo "Frete Entrada:" da tela
		oModelTrp:SetValue("GWU_FRTENT", SubStr(cObsCot,nPos,1) )
	EndIf
	
	If (nPos := At("FSAI",cObsCot,nPos) + 4) > 0
		// Atualiza o campo "Frete Saída:" da tela
		oModelTrp:SetValue("GWU_FRTSAI", SubStr(cObsCot,nPos,1) )
	EndIf
	
	oView:Refresh()
	
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} ShowDifer
Mostra a diferença de valor entre o frete simulado recomparado e a cotação selecionada caso exista
@author felipe.m
@since 10/03/216
@version 1.0
@return Nil
@see PCREQ-9331
/*/
//---------------------------------------------------------------------
Static Function ShowDifer()
Local nValCot := GVQ->GVQ_VALCOT
Local nFrtSimu := FwFldGet("COM__TOT03")

	If nValCot != nFrtSimu
		Help(,,"HELP",,"Existe diferença entre o valor registrado do comparativo ("+cValtoChar(nValCot)+") e o frete simulado ("+cValtoChar(nFrtSimu)+").",1,0)
	EndIf
Return Nil
