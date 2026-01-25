#INCLUDE "GFEA061.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE GFEA061001 "GFEA061001"
#DEFINE GFEA061002 "GFEA061002"
#DEFINE GFEA061003 "GFEA061003"
#DEFINE GFEA061004 "GFEA061004"
#DEFINE GFEA061005 "GFEA061005"
#DEFINE GFEA061006 "GFEA061006"
#DEFINE GFEA061007 "GFEA061007"
#DEFINE GFEA061008 "GFEA061008"
#DEFINE GFEA061009 "GFEA061009"
#DEFINE GFEA061010 "GFEA061010"
#DEFINE GFEA061011 "GFEA061011"
#DEFINE GFEA061012 "GFEA061012"

#DEFINE EMTITENTE_ADICIONAL 1
#DEFINE COMPONENTES_EMITENTE 2  

Static s_INTTAB  := SuperGetMv("MV_INTTAB",.F.,"1")
Static s_CPLINT  := SuperGetMv("MV_CPLINT",.F.,"")
Static s_ERPGFE  := SuperGetMv("MV_ERPGFE",.F.,"2")
Static s_TFMLA   := SuperGetMv("MV_TFMLA",.F.,"2")
Static s_GFEEDIL := SuperGetMV('MV_GFEEDIL',,'1')
Static s_CPLZTO  := SuperGetMv("MV_CPLZTO",.F.,"")
Static s_CPLZTD  := SuperGetMv("MV_CPLZTD",.F.,"")
Static _MVERPGFE := SuperGetMv("MV_ERPGFE",.F.,"2")
Static _MVTFMLA	 := SuperGetMv("MV_TFMLA",.F.,"2")

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061
Tabela de Frete

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oLayerTabFrete, oLayerNeg
	Local oDialog061
	Local oRelacGV9
	Private oBrwTabFrete, oBrwNeg
	Private cAliasGV9, aCamposGV9, aStructGV9
	Private cAliasGV1, aCamposGV1, aStructGV1
	Private cAliasGUC, aCamposGUC, aStructGUC
	Private nCountGV1
	Private nCountGUC
	Private aFaixas := {}
	Private aColsFaixas := {}
	Private aComponentes := {}
	Private aClientesCompAdicionais := {}

	GVA->(dbClearFilter())
	GVA->(dbGoTop())
	
	GV9->(dbClearFilter())
	GV9->(dbGoTop())
	
	Define MsDialog oDialog061 Title "Tabela de Frete" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		/* -- Layers -------------------------------------------------- */
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDialog061, .F., .T.)
		
		// Tabela de Frete
		oFWLayer:AddLine('TOP', 50, .F.)
		oFWLayer:AddCollumn('TABFRETE', 100, .T., 'TOP') // Tabela de Frete
		oLayerTabFrete := oFWLayer:GetColPanel('TABFRETE', 'TOP')
		
		// Negociação
		oFWLayer:AddLine('BOTTON', 50, .F.) 
		oFWLayer:AddCollumn('NEGOC', 100, .T., 'BOTTON') // Negociação
		oLayerNeg := oFWLayer:GetColPanel('NEGOC', 'BOTTON')
		

		/* -- Browse -------------------------------------------------- */
		oBrwTabFrete := FWMBrowse():New()
		oBrwTabFrete:SetAlias('GVA')
		oBrwTabFrete:SetOwner(oLayerTabFrete)
		oBrwTabFrete:SetDescription("Tabelas de Frete")
		oBrwTabFrete:DisableDetails()
		//oBrwTabFrete:SetFilterDefault("GVA->GVA_FILIAL == xFilial('GVA')")
		oBrwTabFrete:SetMenuDef("GFEA061")
		oBrwTabFrete:SetProfileID("1")
		oBrwTabFrete:SetAmbiente(.F.)
		oBrwTabFrete:SetWalkthru(.F.)	
		oBrwTabFrete:SetSeeAll(.F.)
		
		oBrwNeg := FWMBrowse():New()
		oBrwNeg:SetAlias('GV9')
		oBrwNeg:SetOwner(oLayerNeg)
		oBrwNeg:SetDescription("Negociações")
		oBrwNeg:DisableDetails()
		oBrwNeg:SetMenuDef("GFEA061A")

		oBrwNeg:ForceQuitButton(.T.)
		oBrwNeg:SetProfileID("2")
		oBrwNeg:SetAmbiente(.F.)
        oBrwNeg:SetMainProc('GFEA061A')
		oBrwNeg:SetWalkthru(.F.)
		
		//O relacionamento deve ser feito e ativado após criar os browses e definir o alias mas antes de ativá-los;		
		oRelacGV9:= FWBrwRelation():New()
		oRelacGV9:AddRelation(oBrwTabFrete, oBrwNeg, {{'GV9_FILIAL', 'GVA_FILIAL'}, {'GV9_CDEMIT', 'GVA_CDEMIT'}, {'GV9_NRTAB', 'GVA_NRTAB'}})
		oRelacGV9:Activate()

		// Retirados os comandos duplicados de activate e update do browse, pois foi identificada relação com um erro
		// na consulta padrão de class. frete. Além disso, mesmo com os comandos, o sistema gerava error.log ao tentar
		// incluir uma tabela de frete via menu funcional do protheus. Por isso, foram removidas também todas as opções
		// de manipulação que estavam disponibilizadas neste menu.

		// Ativar os grids após o relation para exibir o primeiro registro da tabela pai e os filhos corretamente.
		oBrwTabFrete:Activate()
		oBrwNeg:Activate()

		oBrwNeg:DelColumn(1)
		oBrwNeg:DelColumn(2)
		oBrwNeg:DelColumn(3)
		oBrwNeg:DelColumn(4)
		oBrwNeg:UpdateBrowse() //Para atualizar após a exclusão das colunas

		oBrwTabFrete:UpdateBrowse() //Para dar foco no grid de tabelas.

	Activate MsDialog oDialog061 Center

Return

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} MenuDef
Definição de Menu

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}
	
	AAdd(aRotina, {STR0004              , "VIEWDEF.GFEA061", 0,  3, 0, .F. /*Habilita Menu Funcional*/}) // "Incluir"
	AAdd(aRotina, {STR0003              , "VIEWDEF.GFEA061", 0,  2, 0, .F. /*Habilita Menu Funcional*/}) // "Visualizar"
	AAdd(aRotina, {STR0005              , "VIEWDEF.GFEA061", 0,  4, 0, .F. /*Habilita Menu Funcional*/}) // "Alterar"
	AAdd(aRotina, {STR0002              , "AxPesqui"       , 0,  1, 0, .F. /*Habilita Menu Funcional*/}) // "Pesquisar"
	AAdd(aRotina, {"Copiar"             , "GFECPYTBFR()"   , 0,  4, 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {STR0006              , "VIEWDEF.GFEA061", 0,  5, 0, .F. /*Habilita Menu Funcional*/}) // "Excluir"
	AAdd(aRotina, {"Componentes Vínculo", "GFEA61VIN()"    , 0,  6, 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {STR0023              , "GFEA61ENV()"    , 0,  7, 0, .F. /*Habilita Menu Funcional*/}) // "Envia Tabela para Aprovação" //"Enviar Apro."
	If s_CPLINT == "1" .And. GFE61EXCPL()
		AAdd(aRotina, {"Enviar Cockpit Logístico", "GFEA61CPL()"     , 0, 8, 0, .F. /*Habilita Menu Funcional*/})
		AAdd(aRotina, {"Confirmar Integração Cockpit", "GFEA61CONF()", 0, 9, 0, .F. /*Habilita Menu Funcional*/})
	EndIf
	If s_INTTAB == "2"
		AAdd(aRotina, {"Enviar ERP Consulta", "GFEA61EINT('1','1')"    , 0, 10, 0, .F. /*Habilita Menu Funcional*/}) // "Integra Tabela de Frete"
		AAdd(aRotina, {"Desatualizar ERP Consulta", "GFEA61EINT('1','2')"    , 0, 11, 0, .F. /*Habilita Menu Funcional*/}) // "Integra Tabela de Frete"
	EndIf
	AAdd(aRotina, {'Anexo', "MsDocument('GVA',GVA->(RecNo()), 1)",  0, 4 , 0, .F. /*Habilita Menu Funcional*/})
Return aRotina


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} ModelDef
ModelDef

@author Israel A. Possoli
@since 18/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA061", /*bPre*/, {|oX| GFEA61POS(oX)},{|oModel| GFEA61CMT(oModel)} /*bCommit*/, /*bCancel*/)

	oModel:SetVldActivate({|oMod| GFEA061VLD(oMod)})
	oModel:AddFields("GFEA061_GVA", /*cOwner*/, FWFormStruct(1,"GVA"), /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:SetPrimaryKey({"GVA_FILIAL", "GVA_CDEMIT", "GVA_NRTAB"})
	oModel:AddRules( 'GFEA061_GVA', 'GVA_TABVIN', 'GFEA061_GVA', 'GVA_EMIVIN', 1)
Return oModel


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} ViewDef
ViewDef

@author Israel A. Possoli
@since 18/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA061")
	Local oView  := Nil
	Local oStructGVA := FWFormStruct(2, "GVA")
	
	oStructGVA:SetNoGroups()
	oStructGVA:AddGroup("IDENT", "Identificação", "1", 2)
	oStructGVA:AddGroup("COMPL", "Dados Complementares", "1", 2)
	oStructGVA:AddGroup("CONTR", "Controle", "1", 2)
	oStructGVA:AddGroup("TABVI", "Tabela Vinculada", "2", 2)
	oStructGVA:AddGroup("SITUA", "Situação", "2", 2)
	
	oStructGVA:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "COMPL")
	
	oStructGVA:SetProperty("GVA_CDEMIT", MVC_VIEW_GROUP_NUMBER,"IDENT")
	oStructGVA:SetProperty("GVA_NMEMIT", MVC_VIEW_GROUP_NUMBER,"IDENT")
	oStructGVA:SetProperty("GVA_NRTAB",  MVC_VIEW_GROUP_NUMBER,"IDENT")
	oStructGVA:SetProperty("GVA_DSTAB",  MVC_VIEW_GROUP_NUMBER,"IDENT")
	
	oStructGVA:SetProperty("GVA_DTCRIA", MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGVA:SetProperty("GVA_HRCRIA", MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGVA:SetProperty("GVA_USUCRI", MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGVA:SetProperty("GVA_DTATU",  MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGVA:SetProperty("GVA_HRATU",  MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGVA:SetProperty("GVA_USUATU", MVC_VIEW_GROUP_NUMBER,"CONTR")
	
	oStructGVA:SetProperty("GVA_EMIVIN", MVC_VIEW_GROUP_NUMBER,"TABVI")
	oStructGVA:SetProperty("GVA_TABVIN", MVC_VIEW_GROUP_NUMBER,"TABVI")
	oStructGVA:SetProperty("GVA_VLMULT", MVC_VIEW_GROUP_NUMBER,"TABVI")
	oStructGVA:SetProperty("GVA_VLADIC", MVC_VIEW_GROUP_NUMBER,"TABVI")
	
	oStructGVA:SetProperty("GVA_SITVIN", MVC_VIEW_GROUP_NUMBER,"SITUA")
	oStructGVA:SetProperty("GVA_ENVAPR", MVC_VIEW_GROUP_NUMBER,"SITUA")
	oStructGVA:SetProperty("GVA_DTAPR",  MVC_VIEW_GROUP_NUMBER,"SITUA")
	oStructGVA:SetProperty("GVA_HRAPR",  MVC_VIEW_GROUP_NUMBER,"SITUA")
	oStructGVA:SetProperty("GVA_USUAPR", MVC_VIEW_GROUP_NUMBER,"SITUA")
	oStructGVA:SetProperty("GVA_MTVRPR", MVC_VIEW_GROUP_NUMBER,"SITUA")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("GFEA061_GVA", oStructGVA, "GFEA061_GVA")
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:SetOwnerView( "GFEA061_GVA" , "MASTER" )
Return oView

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061NIN
Negociação - Inclusão

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061NIN()	
	Local lExclusiva := IF((FWModeAccess("GVA",1) == "E"), .T., .F.)
	Local cFilBkp := cFilAnt
	Local cFunBkp := FunName()
	
	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061A")	
	
	If !MPUserHasAccess('GFEA061A',1,RetCodUsr(),.T.)
		SetFunName(cFunBkp)
		Return .F.
	EndIf
	
	IF((lExclusiva), cFilAnt := GVA->GVA_FILIAL,)
	
	If GVA->GVA_TPTAB == "2"
		SetFunName(cFunBkp)
		Help( ,, 'Help',, 'Não é permitido incluir negociações para tabelas de vínculo.', 1, 0)
		Return .F.
	EndIf
		
	FWExecView("INCLUIR",'GFEA061A', MODEL_OPERATION_INSERT, , {|| .T. },{|| .T.},,,{|| .T.},,,)
	
	GVA->(dbClearFilter())
	
	SetFunName(cFunBkp)

	IF((lExclusiva), cFilAnt := cFilBkp,)
Return


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061NAL
Negociação - Alteração

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061NAL()
	Local lExclusiva := IF((FWModeAccess("GVA",1) == "E"), .T., .F.)
	Local cFilBkp := cFilAnt
	Local cFunBkp := FunName()
	
	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061A")		

	If !MPUserHasAccess('GFEA061A',2,RetCodUsr(),.T.)
		SetFunName(cFunBkp)
		Return .F.
	EndIf
	
	IF((lExclusiva), cFilAnt := GVA->GVA_FILIAL,)

	If GVA->GVA_TPTAB == "2"
		SetFunName(cFunBkp)
		Help( ,, 'Help',, 'Não há registro a ser alterado.', 1, 0)
		Return .F.
	EndIf
	
	FWExecView("ALTERAR",'GFEA061A', MODEL_OPERATION_UPDATE, , {|| .T. },{|| .T.},,,{|| .T.})
	
	SetFunName(cFunBkp)
	
	IF((lExclusiva),cFilAnt := cFilBkp,)
Return


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061NTA
Negociação - Tarifas

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061NTA()
	Local lExclusiva := IF((FWModeAccess("GVA",1) == "E"), .T., .F.)
	Local cFilBkp := cFilAnt
	Local cFunBkp := FunName()

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061A")		

	If !MPUserHasAccess('GFEA061A',3,RetCodUsr(),.T.)
		SetFunName(cFunBkp)
		Return .F.
	EndIf	
	
	IF((lExclusiva),cFilAnt := GVA->GVA_FILIAL,)	
	
	If GVA->GVA_TPTAB == "2"
		SetFunName(cFunBkp)
		Help( ,, 'Help',, 'Não é permitido incluir tarifas em tabelas de vínculo', 1, 0)
		Return .F.
	EndIf

	GFEA061F()
	
	SetFunName(cFunBkp)
	
	IF((lExclusiva),cFilAnt := cFilBkp,)
Return


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061NVI
Negociação - Tarifas

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061NVI()
	Local lExclusiva := IF((FWModeAccess("GVA",1) == "E"), .T., .F.)
	Local cFilBkp := cFilAnt
	Local cFunBkp := FunName()
	
	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061A")		

	If !MPUserHasAccess('GFEA061A',4,RetCodUsr(),.T.)
		SetFunName(cFunBkp)
		Return .F.
	EndIf

	IF((lExclusiva),cFilAnt := GVA->GVA_FILIAL,)	
	
	If GVA->GVA_TPTAB == "2"
		SetFunName(cFunBkp)
		Help( ,, 'Help',, 'Não há registro a ser visualizado.', 1, 0)
		Return .F.
	EndIf
	
	FWExecView("VISUALIZAR",'GFEA061A', MODEL_OPERATION_VIEW, , {|| .T. },{|| .T.},,,{|| .T.})
	
	SetFunName(cFunBkp)
	
	IF((lExclusiva),cFilAnt := cFilBkp,)
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61VIN
Ação relacionada para criação dos componentes de vínculo.

@sample
GFEA61VIN()

@author Alan Victor Lamb
@since 23/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA61VIN()
	If GVA->GVA_TPTAB == "2" // Vínculo
		FWExecView("Alteração", "GFEA061I", MODEL_OPERATION_UPDATE, , { || .T. }) 
	Else
		MsgStop("Opção disponível apenas para tabelas do tipo 'Vinculo'")
	EndIf
Return .T.



/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061VLD
Validação de ativação do Model (SetVldActivate)

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061VLD(oModel)
	Local _MVAPRTAB	:= SuperGetMv("MV_APRTAB",.F.,"2")
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		
		dbSelectArea("GV9")
		GV9->( dbSetOrder(1) )
		If GV9->( dbSeek(xFilial("GV9") + GVA->GVA_CDEMIT + GVA->GVA_NRTAB) )
			Help(,,'HELP',,"Para excluir a Tabela de Frete deve-se primeiro eliminar as Negocições relacionadas.",1,0)
			Return .F.
		EndIf
	EndIf
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		// Verifica se o controle de aprovação está ativo e se a tabela já foi liberada
		If _MVAPRTAB $ "1S"
			If GVA->GVA_SITVIN == "2"
				Help(,,'HELP',,"A Tabela de frete de vínculo já foi liberada e não pode ser alterada.", 1, 0)
				Return .F.                          
			Endif
		EndIf
	EndIf
	
Return .T.


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA61POS
Validação do formulário de edição (Post)

@author Israel A. Possoli
@since 11/08/2014
@version 1.0
-------------------------------------------------------------------*/
Function GFEA61POS(oModel)
	Local lRet       := .T.
	Local lAProv     := .F.
	Local _MVAPRTAB  := SuperGetMv("MV_APRTAB",.F.,"2")	
	Local oModelGVB  := oModel:GetModel("GFEA061_GVB")
	Local oModelGVA  := oModel:GetModel("GFEA061_GVA")
	Local cEmiTab    := GetNewPar("MV_GFETAB1", "1")
	Local cAliasGVA  := Nil
	Local cAliasGUY  := Nil
	Local cAliasGV9  := Nil
	Local cAliasGUX  := Nil
	Local nOp        := (oModel:GetOperation())
	Local nI         := 0
	Local nF         := 0
	
	If nOp == MODEL_OPERATION_INSERT
		If cEmiTab == "1"
			cAliasGVA := GetNextAlias()
			BeginSql Alias cAliasGVA
				SELECT 1
				FROM %Table:GVA% GVA
				WHERE GVA.GVA_FILIAL = %xFilial:GVA%
				AND GVA.GVA_CDEMIT = %Exp:oModelGVA:GetValue("GVA_CDEMIT")%
				AND GVA.%NotDel%
			EndSql
			If (cAliasGVA)->(!Eof())
				// O sistema está parametrizado para não permitir mais de uma Tabela de Frete para o mesmo Transportador.
				// Informe outro transportador ou ajuste o transportador [VAR01] já cadastrado!
				GFEMessage(5,GFEA061004,GFEMsgFmt(STR0045,{{"[VAR01]",AllTrim(oModelGVA:GetValue("GVA_CDEMIT"))}}),STR0046)
				lRet := .F.
			EndIf
			(cAliasGVA)->(dbCloseArea())
		EndIf
		
	EndIf
	If lRet
		If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE// Se for inclusao ou alteração
			//Validacao para que os dados da aba Vinculo so estejam habilitados para tabelas de frete do tipo Vinculo
			If oModel:GetValue("GFEA061_GVA","GVA_TPTAB") $ '1|3'
				aFields := {"GVA_EMIVIN","GVA_EMIVIN","GVA_VLADIC"}
				nNaoVazio := 0
				aEVAL(aFields, {|x| If( !Empty(oModel:GetValue("GFEA061_GVA",x)), nNaoVazio++, Nil) })
				If (nNaoVazio > 0)
					// Tabela de frete tipo Normal ou ICMS de Pauta não permite informações no folder Vínculo.
					// Informe o tipo Vínculo ou remova as informações no folder Vínculo
					GFEMessage(5,GFEA061001,STR0010,STR0041)
					lRet := .F.
				EndIf
				
				If !Empty(oModelGVB)
					//Valida se existem componentes cadastrados quando tipo tabela e' Normal ou ICMS de Pauta
					nF := oModelGVB:GetQtdLine()
					For nI := 1 To nF
						oModelGVB:GoLine( nI )
						If !oModelGVB:IsDeleted() .And. !Empty(FwFldGet("GVB_CDCOMP"))
							// Para a inclusão de componentes, a tabela de frete de deve ser do tipo Vínculo.
							// Informe o tipo Vínculo para inclusão de componentes.
							GFEMessage(5,GFEA061002,STR0042,STR0043)
							lRet := .F.
							Exit
						EndIf
					Next nI
				EndIf
			Else
				//Valida se foram informados Emitente Base e Tabela Base
				If Empty(oModel:GetValue("GFEA061_GVA","GVA_EMIVIN")) .Or. Empty(oModel:GetValue("GFEA061_GVA","GVA_TABVIN"))
					// É necessário informar Emitente Base e Tabela Base para Tabela de Frete Tipo Vínculo.
					// Informe Emitente Base e Tabela Base.
					GFEMessage(5,GFEA061003,STR0012,STR0044)
					lRet := .F.
				EndIf
				
				If !Empty(oModelGVB)
					//Valida se componentes estao cadastrados como componente padrao para a tabela de frete vinculada
					nF := oModelGVB:GetQtdLine()
					For nI := 1 To nF
						oModelGVB:GoLine( nI )
						If !oModelGVB:IsDeleted() .And. !Empty(FwFldGet("GVB_CDCOMP"))
							cAliasGUY := GetNextAlias()
							BeginSql Alias cAliasGUY
								SELECT 1
								FROM %Table:GUY% GUY
								WHERE GUY.GUY_FILIAL = %xFilial:GUY%
								AND GUY.GUY_CDEMIT = %Exp:FwFldGet("GVA_EMIVIN")%
								AND GUY.GUY_NRTAB = %Exp:FwFldGet("GVA_TABVIN")%
								AND GUY.GUY_CDCOMP = %Exp:FwFldGet("GVB_CDCOMP")%
								AND GUY.%NotDel%
							EndSql
							If (cAliasGUY)->(Eof())
								// O componente [VAR01] não está cadastrado como componente padrão para tabela de frete vinculada.
								// Informe o componente [VAR01] como componente padrão para tabela de frete vinculada.
								GFEMessage(5,GFEA061006,GFEMsgFmt(STR0020,{{"[VAR01]",AllTrim(FwFldGet("GVB_CDCOMP"))}}),GFEMsgFmt(STR0021,,{{"[VAR01]",AllTrim(FwFldGet("GVB_CDCOMP"))}}))
								lRet := .F.
							EndIf
							(cAliasGUY)->(dbCloseArea())
						EndIf
					Next nI
				EndIf
				
				If lRet
					cAliasGVA := GetNextAlias()
					BeginSql Alias cAliasGVA
						SELECT GVA.GVA_TPTAB
						FROM %Table:GVA% GVA
						WHERE GVA.GVA_FILIAL = %xFilial:GVA%
						AND GVA.GVA_CDEMIT = %Exp:FwFldGet("GVA_EMIVIN")%
						AND GVA.GVA_NRTAB = %Exp:FwFldGet("GVA_TABVIN")%
						AND GVA.GVA_TPTAB = '2'
						AND GVA.%NotDel%
					EndSql
					If (cAliasGVA)->(!Eof())
						// A tabela de frete de vínculo deve ser uma tabela Normal ou ICMS de Pauta
						// Informe o tipo Normal ou ICMS de Pauta.
						GFEMessage(5,GFEA061007,STR0019,STR0047)
						lRet := .F.
					EndIf
					(cAliasGVA)->(dbCloseArea())
				EndIf
				//Valida a tabela informada como vinculo
				If lRet
					cAliasGVA := GetNextAlias()
					BeginSql Alias cAliasGVA
						SELECT 1
						FROM %Table:GVA% GVA
						WHERE GVA.GVA_FILIAL = %xFilial:GVA%
						AND GVA.GVA_CDEMIT = %Exp:oModel:GetValue("GFEA061_GVA","GVA_EMIVIN")%
						AND GVA.GVA_NRTAB = %Exp:oModel:GetValue("GFEA061_GVA","GVA_TABVIN")%
						AND GVA.%NotDel%
					EndSql
					If (cAliasGVA)->(Eof())
						// A tabela de vínculo informada não existe para o transportador [VAR01] e tabela [VAR02].
						// Informe um transportador e tabela válido.
						GFEMessage(5,GFEA061005,GFEMsgFmt(STR0048,{{"[VAR01]",AllTrim(oModel:GetValue("GFEA061_GVA","GVA_EMIVIN"))},{"[VAR02]",AllTrim(oModel:GetValue("GFEA061_GVA","GVA_TABVIN"))}}),STR0049)
						lRet:= .F.
					EndIf
					(cAliasGVA)->(dbcloseArea())
				EndIf
			EndIf
			
			If lRet
				If oModel:GetValue( 'GFEA061_GVA', 'GVA_TPTAB' ) == '2'
					//Nao é possivel uma tabela de vinculos ter negociações
					cAliasGV9 := GetNextAlias()
					BeginSql Alias cAliasGV9
						SELECT 1
						FROM %Table:GV9% GV9
						WHERE GV9.GV9_FILIAL = %xFilial:GV9%
						AND GV9.GV9_CDEMIT = %Exp:FwFldGet("GVA_CDEMIT")%
						AND GV9.GV9_NRTAB = %Exp:FwFldGet("GVA_NRTAB")%
						AND GV9.%NotDel%
					EndSql
					If (cAliasGV9)->(!Eof())
						// Não é possivel gravar uma tabela de vínculo que possua negociações.
						// Informe uma tabela de vínculo que não possua negociações.
						GFEMessage(5,GFEA061008,STR0054,STR0055)
						lRet:= .F.
					EndIf
					(cAliasGV9)->(dbCloseArea())

					If lRet
						//Não é possivel criar vínculos com uma tabela do tipo "Vinculo"
						cAliasGVA := GetNextAlias()
						BeginSql Alias cAliasGVA
							SELECT 1
							FROM %Table:GVA% GVA
							WHERE GVA.GVA_FILIAL = %xFilial:GVA%
							AND GVA.GVA_CDEMIT = %Exp:FwFldGet("GVA_EMIVIN")%
							AND GVA.GVA_NRTAB = %Exp:FwFldGet("GVA_TABVIN")%
							AND GVA.GVA_TPTAB = '2'
							AND GVA.%NotDel%
						EndSql
						If (cAliasGVA)->(!Eof())
							// Não é possivel criar vínculos em uma tabela do tipo Vínculo.
							// Informe o tipo Normal ou ICMS de Pauta para criar vínculos.
							GFEMessage(5,GFEA061009,STR0050,STR0051)
							lRet:= .F.
						EndIf
						(cAliasGVA)->(dbCloseArea())
					EndIf
				EndIf
			EndIf
			
			If lRet
				If nOp == MODEL_OPERATION_INSERT
					cAliasGVA := GetNextAlias()
					BeginSql Alias cAliasGVA
						SELECT 1
						FROM %Table:GVA% GVA
						WHERE GVA.GVA_FILIAL = %xFilial:GVA%
						AND GVA.GVA_CDEMIT = %Exp:oModel:GetValue("GFEA061_GVA","GVA_CDEMIT")%
						AND GVA.GVA_NRTAB = %Exp:oModel:GetValue("GFEA061_GVA","GVA_NRTAB")%
						AND GVA.%NotDel%
					EndSql
					If (cAliasGVA)->(!Eof())
						// Já existe uma Tabela de Frete com a chave informada.
						// Informe outro transportador e tabela.
						GFEMessage(5,GFEA061010,STR0052,STR0053)
						lRet:= .F.
					EndIf
					(cAliasGVA)->(dbCloseArea())
				EndIf
			EndIf
			If lRet
				oModel:LoadValue('GFEA061_GVA','GVA_HRATU',Substring(TIME(),1,5))
				oModel:LoadValue('GFEA061_GVA','GVA_DTATU',DDATABASE)
				oModel:LoadValue('GFEA061_GVA','GVA_USUATU', cUserName)
			EndIf 
		ElseIf nOp == MODEL_OPERATION_DELETE// Se for exclusao
			cAliasGVA := GetNextAlias()
			
			BeginSql Alias cAliasGVA
				SELECT 1
				FROM %Table:GVA% GVA
				WHERE GVA.GVA_FILIAL = %xFilial:GVA%
				AND GVA.GVA_EMIVIN = %Exp:oModel:GetValue("GFEA061_GVA","GVA_CDEMIT")%
				AND GVA.GVA_TABVIN = %Exp:oModel:GetValue("GFEA061_GVA","GVA_NRTAB")%
				AND GVA.%NotDel%
			EndSql
			
			If (cAliasGVA)->(!Eof())
				// A tabela de frete está relacionada como tabela de vínculo e não pode ser excluída.
				// Será necessário desvincular a tabela para excluir.
				GFEMessage(5,GFEA061011,STR0014,STR0056)
				lRet := .F.
			EndIf 
			
			(cAliasGVA)->(dbCloseArea())

			If lRet
				If _MVAPRTAB $ "1S"
					cAliasGV9 := GetNextAlias()
						
					BeginSql Alias cAliasGV9
						SELECT 1
						FROM %Table:GV9% GV9
						WHERE GV9.GV9_FILIAL = %xFilial:GV9%
						AND GV9.GV9_CDEMIT = %Exp:oModel:GetValue("GFEA061_GVA","GVA_CDEMIT")%
						AND GV9.GV9_NRTAB = %Exp:oModel:GetValue("GFEA061_GVA","GVA_NRTAB")%
						AND GV9.GV9_SIT = '2'
						AND GV9.%NotDel%
					EndSql
						
					If (cAliasGV9)->(!Eof())
						lAProv := .T.
					EndIf
						
					(cAliasGV9)->(dbCloseArea())

					If lAProv
						cAliasGUX := GetNextAlias()
						BeginSql Alias cAliasGUX
							SELECT 1
							FROM %Table:GUX% GUX
							WHERE GUX.GUZ_FILIAL = %xFilial:GUX%
							AND GUX.GUX_USUAPR = %Exp:RetCodUsr()%
							AND GUX.%NotDel%
						EndSql
							
						If (cAliasGUX)->(Eof())
							// Usuário não está cadastrado como aprovador de Tabela de Frete.
							// Necessário acessar com usário cadastrado como aprovador de Tabela de Frete.
							GFEMessage(5,GFEA061012,STR0040,STR0057)
							lRet := .F.
						EndIf
							
						(cAliasGUX)->(dbCloseArea())
					EndIf
				EndIf
			EndIf

			If lRet
				If oModel:GetValue("GFEA061_GVA","GVA_TPTAB") == "2" // Vínculo
					GVB->(dbSetOrder(01))
					GVB->(dbSeek(xFilial("GVB") + oModel:GetValue("GFEA061_GVA","GVA_CDEMIT") + oModel:GetValue("GFEA061_GVA","GVA_NRTAB")))
					While !GVB->(Eof()) .And. GVB->GVB_FILIAL == xFilial("GVB") .And. ;
				  							  GVB->GVB_CDEMIT == oModel:GetValue("GFEA061_GVA","GVA_CDEMIT") .And. ;
				  							  GVB->GVB_NRTAB  == oModel:GetValue("GFEA061_GVA","GVA_NRTAB")
						RecLock("GVB",.F.)
							dbDelete()
						GVB->(MsUnLock())
						
						GVB->(dbSkip())                  
					EndDo    
				EndIF
			EndIf
		EndIf
	EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61APR
Verifica se o parametro MV_APRTAB esta setado como 2 aonde indica que a tabela pode ser 
criada com situação que for desejada, se estiver como 1 então o campo GVA_SITVIN vem setado como 
"Em Negociação"

@author Jorge Matos Valcanaia	
@since 21/04/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61APR()
	Local lRet 		:= .F.
	Local _MVAPRTAB	:= SuperGetMv("MV_APRTAB",.F.,"2")	
		
	If _MVAPRTAB $ "2N"
		lRet := .T.
	Endif	
Return lRet   


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61ENV
Função para enviar a Tabela de Frete para Aprovação.
   
@author Jorge Matos Valcanaia	
@since 21/04/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61ENV()     
	Local cAssunto  := STR0025 //"Nova Tabela de Frete para ser Aprovada"
	Local cMensagem := STR0026 + GVA->GVA_NRTAB + STR0027 + GVA->GVA_CDEMIT + STR0028 + cUserName //"A Tabela de Frete "###" do Transportador "###" foi enviada para aprovação pelo usuário "
	Local aRetMail
	Local lEmail 	:= .F.
	// Quando realiza integração com Datasul + aprovação da tabela de frete por MLA
	Local lMLA 		:= s_ERPGFE == "1" .And. s_TFMLA == "1"
	Local _MVAPRTAB	:= SuperGetMv("MV_APRTAB",.F.,"2")	

	If _MVAPRTAB $ "1S"
		If GVA->GVA_TPTAB == "1"
			If  GV9->GV9_SIT == "2"
				Help(,,'HELP',,STR0038,1,0) //"Tabela já foi enviada para aprovação."
				Return .F.
			Else
				If lMLA
					// Quanto utiliza MLA, o e-mail fica como pendência do MLA
					lEmail := .T.
				Else
					//Ponto de Entrada Britania
					If ExistBlock("GFEA0611")
						cRet := ExecBlock("GFEA0611",.f.,.f.,{cAssunto,cMensagem})
						If ValType(cRet) == 'A'
					    	cAssunto  := cRet[1]
							cMensagem := cRet[2]
						endIf
					EndIf
					//Fim Ponto de Entrada Britania

					//Chamada da Função de Envio de Email de Aprovação/Reprovação de tabela de frete que está no fonte GFEA064
					aRetMail := GFEMail(GFEA064USR(), cAssunto,cMensagem,.F.)
					lEmail   := aRetMail[1]
				EndIf
				
				//Caso a tabela de frete seja 'Normal' envia as negociações relacionadas para aprovação.
				If lEmail 
					If GVA->GVA_TPTAB == "1"
						GV9->( dbSetOrder(1) )
						If GV9->( dbSeek(xFilial("GV9") + GVA->GVA_CDEMIT + GVA->GVA_NRTAB) )
							While !GV9->( Eof() ) .And. GVA->GVA_FILIAL == xFilial("GVA") .And. GVA->GVA_NRTAB == GV9->GV9_NRTAB
								GV6->( dbSetOrder(1) )
								If GV9->GV9_ENVAPR != "1" .And. GV9->GV9_SIT != "2" .And. GV6->( dbSeek(xFilial("GV6")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG) )
									RecLock("GV9",.F.)
										GV9->GV9_ENVAPR := "1"
										GV9->GV9_MTVRPR := ""
										If GV9->(FieldPos("GV9_SITMLA")) > 0
											If lMLA
												GV9->GV9_SITMLA := "2" // Situação MLA Pendente
												GV9->GV9_MOTMLA := ""
											Else
												GV9->GV9_SITMLA := "6" // Não se Aplica
											EndIf
										EndIf
									GV9->(MsUnlock())
									
									If GV9->(FieldPos("GV9_CODCOT")) > 0 .And. !Empty(GV9->(GV9_CODCOT+GV9_SEQCOT))
										GVQ->(dbSetOrder(1))
										If GVQ->(dbSeek( xFilial("GVQ")+"1"+GV9->(GV9_CODCOT+GV9_SEQCOT) ))
											RecLock("GVQ",.F.)
												GVQ->GVQ_ENVCOP := "1" // Cotação enviada
											GVQ->(MsUnlock())
										EndIf
									EndIf
									
									MsgInfo(STR0029) //"Tabela Enviada para Aprovação"
								EndIf
								
								GV9->( dbSkip() )
							EndDo
						EndIf
					EndIf
				Else
					MsgAlert(STR0039 + CRLF + aRetMail[2])
					Return .F.
				EndIf
			EndIf
		EndIf

		IF  GVA->GVA_TPTAB == "2" //Tipo de Tabela - 1=Normal;2=Vinculo		
			If  GVA->GVA_SITVIN == "2"
				Help(,,'HELP',,STR0038,1,0) //"Tabela já foi enviada para aprovação."
				Return .F.
			Else
				If lMLA
					RecLock("GVA",.F.)
						GVA->GVA_ENVAPR := "2"
						GVA->GVA_DTAPR  := dDataBase
						GVA->GVA_HRAPR  := TIME()
						GVA->GVA_USUAPR := cUserName
						GVA->GVA_SITVIN := "2"			
					GVA->(MsUnLock())

					MsgAlert("Esta Tabela de Frete é do tipo Vínculo e a integração com o MLA está ativa, por isso esta tabela está sendo aprovada automaticamente. A aprovação via MLA será realizada apenas sobre a tabela base (do tipo Normal).","Tabela de Frete aprovada automaticamente!")				
				Else
					//Chamada da Função de Envio de Email de Aprovação/Reprovação de tabela de frete que está no fonte GFEA064
					aRetMail := GFEMail(GFEA064USR(), cAssunto,cMensagem,.F.)
					If aRetMail[1] //GFEEnvMail(GFEA064USR(),cAssunto,cMensagem,.F.)
						RecLock("GVA",.F.)
							GVA->GVA_ENVAPR := "1"
							If GVA->GVA_TPTAB == "2"
								GVA->GVA_MTVRPR := ""
							EndIf
						GVA->(MsUnLock())

						MsgInfo(STR0029) //"Tabela Enviada para Aprovação"
					Else
						MsgAlert(STR0039 + CRLF + aRetMail[2])
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		Help(,,'HELP',,STR0031,1,0)   //"Sistema não está parametrizado para fazer controle de aprovação de Tabela de Frete"
		Return .F.
	EndIf
	
Return

Function GFEA61CPL()
	Local aAreaGVA := GVA->(GetArea())
	Local cSeek

	MsgRun("Enviando tabela " + ALLTRIM(GVA->GVA_NRTAB) + " ao Cockpit Logístico","Aguarde",{||GFE61CPL()})
	
	cSeek := GVA->(GVA_FILIAL+GVA_CDEMIT+GVA_NRTAB)
	
	GVA->(dbSetorder(2))
	GVA->( dbSeek( cSeek ) )
	While !GVA->(Eof()) .And. GVA->(GVA_FILIAL+GVA_EMIVIN+GVA_TABVIN) == cSeek

		MsgRun("Enviando tabela " + ALLTRIM(GVA->GVA_NRTAB) + " ao Cockpit Logístico","Tabela Vinculada",{||GFE61CPL()})
		
		GVA->(dbSkip())
	EndDo

	If ExistBlock("GFEA0612")
		ExecBlock("GFEA0612",.f.,.f.)
	EndIf

	RestArea(aAreaGVA)
Return

Function GFE61CPL()
	Local oWsNeoLog
	Local aInfoTab
	Local cAlGV9
	Local oGrupo
	Local oItem
	Local lNormInverte := .F.
	Local lAddInverte := .F.
	Local lNormTarifa := .F.
	Local lAddTarifa := .F.
	Local lAddEntrega := .F.
	Local nX
	Local nY
	Local cVgFim := ""
	Local cVgIni := ""
	Local nNrneg := 0
	Local oStItem
	Local aComp
	Local aCompS
	Local lCancelaEnvio := .F.
	Local aEnvNeo := {}
	Local cInner := "% GV6.D_E_L_E_T_=' '"

	Private GFELog061
	Private aCompCPLFx := {}

	If Empty(Posicione("GU3",1,xFilial("GU3") + GVA->GVA_CDEMIT, "GU3_CDTERP"))
		MsgAlert("É necessário que o Emitente tenha um código do transportador do ERP para enviar a tabela para o Cockpit Logístico")
		Return .F.
	EndIf

	GFELog061 := GFELog():New("Tabela_" + AllTrim(GVA->GVA_NRTAB) + "_EnvioCPL", "Envio Cockpit logístico", s_GFEEDIL)
	oWsNeoLog := NovoEnvioGrupoFrete()
	aInfoTab := GFEInfoTab(GVA->GVA_CDEMIT, GVA->GVA_NRTAB)
	cAlGV9 := GetNextAlias()
	oStItem := oWsNeoLog:NovoItem(cAlGV9)

	dbSelectArea("GV1")
	GV1->(dbSetOrder(1))
	dbSelectArea("GV9")
	GV9->(dbSetOrder(1))
	dbSelectArea("GV8")
	GV8->(dbSetOrder(1))
	dbSelectArea("GV7")
	GV7->(dbSetOrder(1))
	dbSelectArea("GVA")
	GVA->(dbSetOrder(1))

	If aInfoTab[1]
		cInner += " INNER JOIN " + RetSqlName("GVA")
		cInner += " ON GVA_FILIAL = GV9_FILIAL"
		cInner += " AND GVA_EMIVIN = GV9_CDEMIT"
		cInner += " AND GVA_TABVIN = GV9_NRTAB"
		cInner += " AND GVA_SITVIN = '2' "
	EndIf
	cInner += "%"

	BeginSql Alias cAlGV9
		SELECT *
		FROM %Table:GV9% GV9
		INNER JOIN %Table:GV8% GV8
		ON GV8_FILIAL = GV9_FILIAL
		AND GV8_CDEMIT = GV9_CDEMIT
 		AND GV8_NRTAB = GV9_NRTAB
		AND GV8_NRNEG = GV9_NRNEG
		AND GV8_TPORIG IN ('0','1','3','4','5')
		AND GV8_TPDEST IN ('0','1','3','4','5')
		AND GV8.%NotDel%
		INNER JOIN %Table:GV7% GV7
		ON GV7_FILIAL = GV9_FILIAL
		AND GV7_CDEMIT = GV9_CDEMIT
		AND GV7_NRTAB = GV9_NRTAB
		AND GV7_NRNEG = GV9_NRNEG
		AND GV7.%NotDel%
		INNER JOIN %Table:GV6% GV6
		ON GV6_FILIAL = GV9_FILIAL
	  	AND GV6_CDEMIT = GV9_CDEMIT
		AND GV6_NRTAB = GV9_NRTAB
		AND GV6_NRNEG = GV9_NRNEG
		AND GV6_CDFXTV = GV7_CDFXTV
		AND GV6_NRROTA = GV8_NRROTA
		AND %Exp:cInner%
		WHERE GV9_FILIAL = %xFilial:GV9%
		AND GV9_CDEMIT = %Exp:aInfoTab[2]%
		AND GV9_NRTAB = %Exp:aInfoTab[3]%
		AND GV9_SIT = '2'
		AND GV9_TPLOTA IN ('1','2')
		AND (GV9_DTVALF = ' ' OR GV9_DTVALF >= %Exp:Date()%)
		AND GV9.%NotDel%
	  	ORDER BY GV9_FILIAL,GV9_CDEMIT,GV9_NRTAB,GV9_NRNEG,GV7_CDFXTV,GV9_DTVALI,GV9_DTVALF
	EndSql	
	If (cAlGV9)->(Eof())
		MsgInfo("Não há negociações aprovadas ou vigentes para o envio da tabela " + AllTrim(GVA->GVA_NRTAB) + ".")
		GFELog061:Add("Não há negociações aprovadas ou vigentes para o envio da tabela " + AllTrim(GVA->GVA_NRTAB) + ".")
		lCancelaEnvio := .T.
	Else
		oWsNeoLog := aAdd(aEnvNeo, NovoEnvioGrupoFrete())
	EndIf

	While !(cAlGV9)->(Eof()) .And. !lCancelaEnvio
		// Se negociação com vigencia expirada, não gera dados para envio
		If !Empty((cAlGV9)->GV9_DTVALF) .And. (cAlGV9)->GV9_DTVALF < Dtos(dDataBase)
			(cAlGV9)->(DbSkip())
			Loop
		EndIf

		lAddEntrega := GUZ->(dbSeek((cAlGV9)->(GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG)))

		If ((cAlGV9)->GV8_TPORIG =='0' .Or. lAddEntrega) .And. Empty(s_CPLZTO)
			MsgInfo("É necessário configurar a zona de transporte na rotina 'Parâmetros Integração' para integrar rotas com origens não informadas.")
			lCancelaEnvio := .T.
			Loop
		EndIf
		If ((cAlGV9)->GV8_TPDEST =='0' .Or. lAddEntrega) .And. Empty(s_CPLZTD)
			MsgInfo("É necessário configurar a zona de transporte na rotina 'Parâmetros Integração' para integrar rotas com destinos não informados.")
			lCancelaEnvio := .T.
			Loop
		EndIf

		lAdd := .F.
		If cVgFim != (cAlGV9)->GV9_DTVALF .Or. cVgIni != (cAlGV9)->GV9_DTVALI  .OR. nNrneg != (cAlGV9)->GV9_NRNEG
			lAdd 		:= .T.
			cVgIni      := (cAlGV9)->GV9_DTVALI
			cVgFim 		:= (cAlGV9)->GV9_DTVALF
			nNrneg 		:= (cAlGV9)->GV9_NRNEG
			aCompCPLFx  := {}
			oGrupo := oWsNeoLog:NovoGrupoFrete()

			oGrupo:cfreightRuleGroupName := oGrupo:CodigoGrupo(GVA->GVA_CDEMIT, GVA->GVA_NRTAB, (cAlGV9)->GV9_NRNEG)
			oGrupo:cdescription          := AllTrim(GVA->GVA_DSTAB)
			oGrupo:cname                 := AllTrim(Posicione("GU3",1, xFilial("GU3") + GVA->GVA_CDEMIT ,"GU3_NMEMIT"))

			oGrupo:cvigencyInitialDate  := oWsNeoLog:ConverteData((cAlGV9)->GV9_DTVALI,"00:00:00")
			oGrupo:cvalidityFinalDate   := oWsNeoLog:ConverteData((cAlGV9)->GV9_DTVALF,"23:59:59")

			//Adicional por Entrega - Cadastrado por negociação
			If lAddEntrega
				aCompS := oStItem:CompAdicEnt(cAlGV9)
				For nY := 1 To Len(aComps)
					aComp := aComps[nY,3]
					oItem := oWsNeoLog:NovoItem(cAlGV9)
					oItem:Cabecalho(oGrupo)
					oItem:DefineLocaiseZona( .F. , "" ,.T.)
					oItem:AdicionaComponentes( Nil , aComp)
					oItem:AdicionaFatorCubagem()
					oItem:ClassifFrete()        
					oItem:AdicionaFaixa(aComps[nY,1],aComps[nY,2])
					oGrupo:AddItem(oItem,(cAlGV9)->GV9_TPLOTA)
				Next nY
			EndIF
		EndIf

		If !( "[" + AllTrim((cAlGV9)->GV9_NRNEG) + "]" $ "[" + oGrupo:cNrNegociacao + "]")
			If !Empty(oGrupo:cNrNegociacao)
				oGrupo:cNrNegociacao += "/"
			EndIf
			oGrupo:cNrNegociacao += "[" + AllTrim((cAlGV9)->GV9_NRNEG) + "]"
		EndIf

		For nX := 1 To 2
			If nX == 1 .Or. lNormInverte
				lNormTarifa := GV1->(dbSeek((cAlGV9)->(GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG+GV7_CDFXTV+GV8_NRROTA)))
				lAddTarifa := GUC->(dbSeek((cAlGV9)->(GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG+GV7_CDFXTV+GV8_NRROTA)))

				If lNormTarifa  // A Tarifa normal
					lSameOrgDest := AddCompNormal(cAlGV9,@oWsNeoLog,@oGrupo,lNormInverte )
					If (cAlGV9)->GV8_DUPSEN == "1" .And. !lSameOrgDest
						lNormInverte := .T.
					EndIf
				EndIf

				If lAddTarifa 
					lSameOrgDest := AddCompAdc(cAlGV9,@oWsNeoLog,@oGrupo,lAddInverte )
					If (cAlGV9)->GV8_DUPSEN == "1" .And. !lSameOrgDest
						lAddInverte := .T.
					EndIf
				EndIf
			EndIf
		Next nX

		lNormInverte := .F.
		lAddInverte  := .F.

		If lAdd
			oWsNeoLog:AddGrupo(oGrupo)
		EndIf

		(cAlGV9)->(DbSkip())
	EndDo

	(cAlGV9)->(dbCloseArea())

	If !lCancelaEnvio .And. !Empty(aEnvNeo[Len(aEnvNeo)])
		DisparaEnvio(aEnvNeo[Len(aEnvNeo)])
		aSize(aEnvNeo,0)
	EndIf

	GFELog061:Save()

	If !EmptY(aCompS)
		aSize(aCompS,0)
	EndIf

	If !EmptY(aComp)
		aSize(aComp,0)
	EndIf

	If !Empty(aInfoTab)
		aSize(aInfoTab,0)
	EndIf

	If !Empty(oWsNeoLog)
		FreeObj(oWsNeoLog)
	EndIf

	FreeObj(GFELog061)
	FreeObj(oStItem)
Return

Function GFEA61CMT(oModel)
	Local nOp := oModel:GetOperation()
	Local lRet := .T.

	If nOp == MODEL_OPERATION_DELETE
		lRet := FwFormCommit(oModel)
	Else
		lRet := FWFormCommit(oModel, /*[ bBefore ]*/,/* [ bAfter ]*/, /*[ bAfterSTTS ]*/,{|oModel| GFE61ATDP(oModel:GetValue( 'GFEA061_GVA', 'GVA_CDEMIT' ) + oModel:GetValue( 'GFEA061_GVA', 'GVA_NRTAB' ))}, /*[ bABeforeTTS ]*/, /*<bIntegEAI >*/)
	EndIf
Return lRet

Static Function DisparaEnvio(oWsNeoLog)
	Local lCancelaEnvio := .F.
	Local cNrNeg
	Local aGrupos
	Local cSvcError  
	Local cSoapFCode 
	Local cSoapFDescr
	Local bErro
	Local cUsrExec

	Private cErroCls

	//Auxilio no tratamento de erro de string size overflow. 
	bErro := ErrorBlock( {|e| cErroCls := e:DESCRIPTION + " || " + e:ERRORSTACK} )
	BEGIN SEQUENCE
	oWsNeoLog:VerificaLimite()

	aGrupos := oWsNeoLog:oWSfreightRuleGroups:oWSfreightRuleGroup
	cNrNeg := StrTran(StrTran(aGrupos[Len(aGrupos)]:cNrNegociacao,"[",""),"]","")

	If !oWsNeoLog:lLiberado
		lCancelaEnvio := .T.
		cUsrExec := LogUserName()

		If valtype(cUsrExec) == 'C'
			GFELog061:Add("Envio da tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " cancelado pelo usuário " + AllTrim(cUsrExec) )
		Else
			GFELog061:Add("Envio da tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " cancelado pelo usuário ")
		EndIf
	EndIf

	If !lCancelaEnvio
		oWsNeoLog:Envia()

		cMsgRet := oWsNeoLog:cMsgRet

		cSvcError   := GetWSCError()  // Resumo do erro
		cSoapFCode  := GetWSCError(2) // Soap Fault Code
		cSoapFDescr := GetWSCError(3) // Soap Fault Description

		If Empty(cErroCls)
			If Empty(cSvcError) .And. Empty(cMsgRet)
				RecLock("GVA",.F.)
				GVA->GVA_CPLSIT := "2" //Enviada
				GVA->GVA_CPLDT  := DDATABASE
				MsUnLock()
				GFELog061:Add("Tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " enviada com sucesso!")
			Else
				RecLock("GVA",.F.)
				GVA->GVA_CPLSIT := "3" // Erro Envio
				GVA->GVA_CPLDT  := DDATABASE
				MsUnLock()
				MsgInfo("Ocorreu o seguinte erro ao enviar a tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " : " + AllTrim(cMsgRet) + " - " + cValTochar(cSvcError) + CRLF + " Detalhe : " + cValToChar(cSoapFCode) + CRLF + cValToChar(cSoapFDescr))
				GFELog061:Add("Ocorreu o seguinte erro ao enviar a tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " : " +  AllTrim(cMsgRet) + " - " + cValToChar(cSvcError) + CRLF + " Detalhe : " + cValToChar(cSoapFCode) + CRLF + cValToChar(cSoapFDescr))
				lCancelaEnvio := .T.
			EndIf
		EndIf

		GFELog061:Add(Replicate("-",20) + "Xml Enviado" + Replicate("-",20))
		GFELog061:Add(oWsNeoLog:cXmlEnviado)
	EndIf

	END SEQUENCE
	ErrorBlock(bErro)

	If !Empty(cErroCls)
		MsgInfo(cErroCls)
		GFELog061:Add("Ocorreu o seguinte erro ao enviar a tabela " + AllTrim(GVA->GVA_NRTAB) + " negociação " + AllTrim(cNrNeg) + " : ")
		GFELog061:Add(cErroCls)
		lCancelaEnvio := .T.
	EndIf

	oWsNeoLog:cXmlEnviado := ""
	FreeObj(oWsNeoLog)

Return lCancelaEnvio

Function GFEA61CONF()
	Local aAreaGVA := GVA->(GetArea())
	Local cSeek

	If !Empty(GVA->GVA_NRTAB)

		/*Validação*/
		If GVA->GVA_CPLSIT != "2"
			MsgInfo("Somente tabelas de frete na situação de integração 'Enviada' podem ser alteradas para a situação 'Integrada'")
			Return
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := " SELECT GVA_CDEMIT, GVA_NRTAB  FROM "+RetSQLName("GVA")
		cQuery += "   WHERE GVA_FILIAL = '" + GVA->GVA_FILIAL + "'"
		cQuery += "     AND GVA_EMIVIN = '" + GVA->GVA_CDEMIT + "'"
		cQuery += "     AND GVA_TABVIN = '" + GVA->GVA_NRTAB  + "'"
		cQuery += "     AND GVA_CPLSIT <> '2'"
		cQuery += "     AND D_E_L_E_T_ = ' '"
 		cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
        If !(cAliasQry)->(Eof())
            MsgInfo("Somente tabelas de frete na situação de integração 'Enviada' podem ser alteradas para a situação 'Integrada'" + CRLF +;
						"Tabela vinculada: " + AllTrim((cAliasQry)->GVA_CDEMIT) + "/" + AllTrim((cAliasQry)->GVA_NRTAB))

			Return
        EndIf
        (cAliasQry)->( dbCloseArea() )

		/*Confirma Integração*/
		BeginTran()
			//Tabela Normal
			Reclock("GVA",.F.)
			GVA->GVA_CPLSIT := "5" // Integrada
			MsUnlock()

			cSeek := GVA->(GVA_FILIAL+GVA_CDEMIT+GVA_NRTAB)

			//Tabelas Vínculo
			GVA->( dbSetorder( 2 ) )
			GVA->( dbSeek( cSeek ) )
			While !GVA->(Eof()) .And. GVA->(GVA_FILIAL+GVA_EMIVIN+GVA_TABVIN) == cSeek
				Reclock("GVA",.F.)
					GVA->GVA_CPLSIT := "5" // Integrada
				MsUnlock()

				GVA->(dbSkip())
			EndDo
		EndTran()
		MsUnlockAll()
	EndIf
	
	RestArea(aAreaGVA)
Return

Function GFE61EXCPL()
	Local lRet := .F.
	
	lRet := GFXCP12127("GVA_CPLSIT")
Return lRet 

/*/{Protheus.doc} GFEA061DS
Função para auxiliar no retorno da nova descrição de rotas e faixas compatíveis com todas as situações
@author siegklenes.beulke
@since 02/12/2016
@version undefined
@param xValor, , descricao
@example
(examples)
@see (links_or_references)
/*/
Function GFEA061DS(xValor,lTrigger,cTpLota)
	Local cDescricao := ""
	Local cVar := ReadVar()
	Local oModel := FwModelActive()
	Local oModelGV9
	Default cTpLota := "0"
	Default lTrigger := .F.

	If Type("INCLUI") == "U"
		INCLUI := .F.
	EndIf
	If oModel != Nil
		oModelGV9 := oModel:GetModel("GFEA061A_GV9")
		If cTpLota == "0"
			cTpLota := oModelGV9:GetValue("GV9_TPLOTA")
		EndIf
	EndIf
	Do Case
		Case ("GV7_DSTPVC" $ cVar) .Or. ("GV7_CDTPVC" $ cVar) .Or. ("GV9_TPLOTA" $ cVar) .Or. ("GV6_CDFXTV" $ cVar) .Or. Empty(cVar) .Or. ("GV6_INFFXA" $ cVar)
			If Empty(xValor)
				If cTpLota $ '2;3'
					cDescricao := "Todos os tipos de veículo"
				Else
					cDescricao := ""
				EndIf
			Else
				cDescricao := IF(!INCLUI .Or. lTrigger,POSICIONE("GV3",1,XFILIAL("GV3")+xValor,"GV3_DSTPVC") ,"")
			EndIf
	EndCase
Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} function GFEA061ANT
Nova Tarifa pelo botão "Outras Ações"
@author  Anonymous
/*/
//-------------------------------------------------------------------
Function GFEA061ANT()
	Local cFunBkp := FunName()

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061F")

	If !MPUserHasAccess('GFEA061F', 3, RetCodUsr(), .T.)
		SetFunName(cFunBkp)
		Return .F.
	EndIf
	If GV9->(Eof()) .Or. Empty(GV9->GV9_NRTAB)
		Help( ,, 'Help',, "Não há negociações cadastradas.", 1, 0)
	ElseIf GVA->GVA_TPTAB == "2"
		Help( ,, 'Help',, 'Não é permitido incluir tarifas em tabelas de vínculo', 1, 0)
	Else
		FwExecView(,'GFEA061F',3)
	EndIf

	SetFunName(cFunBkp)
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61EINT
Função para enviar a Tabela de Frete para Integração com Consulta Datasul.
   
@author João Leonardo Schmidt	
@since 25/04/17
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61EINT(cTipoInt,CTipoOp)     
	Local cCdEmit := ""
	Local cNrTab  := ""
	
	If cTipoInt == "1"
		If GVA->GVA_TPTAB == "1"
			cCdEmit := GVA->GVA_CDEMIT
			cNrTab  := GVA->GVA_NRTAB
		ElseIf GVA->GVA_TPTAB == "2"
			cCdEmit := GVA->GVA_EMIVIN
			cNrTab  := GVA->GVA_TABVIN
		EndIf
		
		If GFXCP12116("GV9","GV9_SITCON") .And. GFXCP12116("GV9","GV9_MOTCON")
			dbSelectArea("GV9")
			GV9->( dbSetOrder(1) )
			If GV9->( dbSeek(xFilial("GV9") + cCdEmit + cNrTab) )
				While !GV9->( Eof() ) .And. GVA->GVA_FILIAL == xFilial("GVA") .And. cCdEmit == GV9->GV9_CDEMIT .And. cNrTab == GV9->GV9_NRTAB
					RecLock("GV9",.F.)
					   If cTipoOp == "1" 
							GV9->GV9_SITCON := "2"
							GV9->GV9_MOTCON := ""
					   Else
					   		If GV9->GV9_SITCON == "4"
						   		GV9->GV9_SITCON := "5"
								GV9->GV9_MOTCON := "" 
							else
								Help(,,"HELP",,"A tabela deve estar Atualizada no ERP.",1,0)
								Return
							EndIf
						EndIf
					MsUnlock("GV9")	
					GV9->( dbSkip() )
				EndDo	
			EndIf
		EndIf
	Else
		If GFXCP12116("GV9","GV9_SITCON") .And. GFXCP12116("GV9","GV9_MOTCON")
			RecLock("GV9",.F.)
				If cTipoOp == "1" 
					GV9->GV9_SITCON := "2"
					GV9->GV9_MOTCON := ""
				Else
					If GV9->GV9_SITCON == "4"
						GV9->GV9_SITCON := "5"
						GV9->GV9_MOTCON := "" 
					else
						Help(,,"HELP",,"A tabela deve estar Atualizada no ERP.",1,0)
						Return
					EndIf
				EndIf
			MsUnlock("GV9")
		EndIf	
	EndIf
	
Return

/*/{Protheus.doc} AddCompNormal
Envio de Componentes
@author tamyris.g	
@since 08/04/2019
@version undefined 
@param 
@example
@see (links_or_references)
/*/
Static Function AddCompNormal(cAlGV9, oWsNeoLog,oGrupo,lNormInverte)
	Local lSameOrgDest := .T.
	Local lEnvFaixa    := .T.
	Local lEnvComp     := .T.
	Local oItem        := Nil
	Local cCampos      := ""
	Local cAliasQry    := Nil
	Local nX           := 0
	Local lMaxExced    := .F.

	If GFXCP12125("GV2_CPLFXA")
		cCampos += " GV2.GV2_CPLFXA,"
	EndIf
	cCampos := "%" + cCampos + "%"

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT GV1.GV1_CDCOMP CDCOMP,
				GVB.GVB_CDCOMP,
				GV1.GV1_VLLIM,
				GV2.GV2_ATRCAL,
				GV1.GV1_CALCEX,
				%Exp:cCampos%
				(GV1.GV1_VLMINN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) VALORMIN,
				(GV1.GV1_VLFIXN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) VALORFIXO,
				CASE WHEN GV2.GV2_ATRCAL IN ('2','2 ',' 2') THEN (GV1.GV1_PCNORM * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEVALOR,
				CASE WHEN GV2.GV2_ATRCAL IN ('9','9 ',' 9') THEN (GV1.GV1_PCNORM * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END SUBTOTFRET,
				CASE WHEN GV2.GV2_ATRCAL IN ('1','1 ',' 1') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEPESOB,
				CASE WHEN GV2.GV2_ATRCAL IN ('10')          THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEPESOL,
				GV1.GV1_VLFRAC FRACAO,
				CASE WHEN GV2.GV2_ATRCAL IN ('3','3 ',' 3') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEITENS,
				CASE WHEN GV2.GV2_ATRCAL IN ('5','5 ',' 5') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEVOLUM,
				CASE WHEN GV2.GV2_ATRCAL IN ('7','7 ',' 7') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEENTRG,
				CASE WHEN GV2.GV2_ATRCAL IN ('4','4 ',' 4') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END VOLUME,
				CASE WHEN GV2.GV2_ATRCAL IN ('6','6 ',' 6') THEN (GV1.GV1_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END DISTANCIA,
				/*Valores Excedente*/
				(GV1.GV1_VLFIXE * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) GV1_VLFIXE,
				(GV1.GV1_PCEXTR * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) GV1_PCEXTR,
				(GV1.GV1_VLUNIE * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0)  GV1_VLUNIE
		FROM %Table:GV1% GV1
		INNER JOIN %Table:GV2% GV2
		ON GV2.GV2_FILIAL = %xFilial:GV2%
		AND GV2.GV2_ATRCAL <> '11'
		AND GV2.GV2_SERVI <> '1'
		AND GV2.GV2_CDCOMP = GV1.GV1_CDCOMP
		AND GV2.%NotDel%
		LEFT JOIN %Table:GVB% GVB
		ON GVB.GVB_FILIAL = %Exp:GVA->GVA_FILIAL%
		AND GVB.GVB_CDEMIT = %Exp:GVA->GVA_CDEMIT%
		AND GVB.GVB_NRTAB = %Exp:GVA->GVA_NRTAB%
		AND GVB.GVB_CDCOMP = GV1.GV1_CDCOMP
		AND %Exp:GVA->GVA_TPTAB% = '2'
		AND GVB.%NotDel%
		WHERE GV1.GV1_FILIAL = %Exp:(cAlGV9)->GV9_FILIAL%
		AND GV1.GV1_CDEMIT = %Exp:(cAlGV9)->GV9_CDEMIT%
		AND GV1.GV1_NRTAB = %Exp:(cAlGV9)->GV9_NRTAB%
		AND GV1.GV1_NRNEG = %Exp:(cAlGV9)->GV9_NRNEG%
		AND GV1.GV1_CDFXTV = %Exp:(cAlGV9)->GV7_CDFXTV%
		AND GV1.GV1_NRROTA = %Exp:(cAlGV9)->GV8_NRROTA%
		AND GV1.GV1_CDCOMP <> %Exp:(cAlGV9)->GV6_COMFRG%
		AND GV1.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())		
	 	lEnvFaixa := .T.
	 	lEnvComp  := .T.
		 
	 	/*Tratamento CPL - Verifica se componente admite faixa*/
		If GFXCP12125("GV2_CPLFXA")
			If (cAlGV9)->GV9_TPLOTA == '1' /*Carga Fechada*/ .And. ; 
				(cAliasQry)->GV2_CPLFXA == '2' /*Não considera na faixa*/
				
				lEnvFaixa := .F.
	
				//Componente Por Faixa = Não, só envia uma vez o componente para cada rota
				If (nPos := aScan(aCompCPLFx, { |x| x[1]+x[2] == (cAlGV9)->GV8_NRROTA + (cAliasQry)->CDCOMP } ) ) == 0
					aAdd(aCompCPLFx, { (cAlGV9)->GV8_NRROTA , (cAliasQry)->CDCOMP} )
				Else
					lEnvComp := .F.
				EndIf
			EndIf
		EndIf
		
		For nX := 1 To 2
		
			lExcedente := (cAliasQry)->GV1_VLLIM <> 0    //Tem excedente informado
      lMaxExced  := (cAliasQry)->GV1_VLLIM >= val("999999999.99999")
			lNormal    := lEnvComp .And. (!lExcedente .Or. compVlNormal(cAliasQry))  //Não tem excedente informado ou tem valor normal
			
			If (nX == 1 .And. lNormal) .Or. (nX == 2 .And. lExcedente .And. !lMaxExced)
			
				oItem := oWsNeoLog:NovoItem(cAlGV9)   //Cria um novo <freightRule>
				oItem:Cabecalho(oGrupo)               //Cabeçalho 
				oItem:DefineLocaiseZona(lNormInverte) //Origem e destino
				oItem:AdicionaFatorCubagem()          //Fator de Cubagem
				oItem:ClassifFrete()                  //Classificação de Frete
				
				If nX == 1 /*Normal*/
					
					If lExcedente
						oItem:AdicionaFaixa(,,(cAliasQry)->GV1_VLLIM,(cAliasQry)->GV1_CALCEX,(cAliasQry)->GV2_ATRCAL,'1') //Faixa
					ElseIf lEnvFaixa 
						oItem:AdicionaFaixa() //Faixa
					EndIF
					
					oItem:AdicionaComponentes(cAliasQry)  //Valores dos Componentes
					
				Else /*Excedente*/

					aComp := oItem:AdicionaExcedente(cAliasQry)
					oItem:AdicionaFaixa(,,(cAliasQry)->GV1_VLLIM,(cAliasQry)->GV1_CALCEX,(cAliasQry)->GV2_ATRCAL,'2') //Faixa
					oItem:AdicionaComponentes( Nil , aComp)    //Valores dos Componentes

				EndIF
				oGrupo:AddItem(oItem,(cAlGV9)->GV9_TPLOTA)
			EndIf
		Next nX
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	If !Empty(oItem)
		lSameOrgDest := oItem:lSameOrgDest
	EndIf
Return lSameOrgDest

/*/{Protheus.doc} AddCompAdc
Envio de Componentes adicionais
@author Squad GFE
@since 23/03/2020
@version undefined 
@param 
@example
@see (links_or_references)
/*/
Static Function AddCompAdc(cAlGV9, oWsNeoLog,oGrupo,lAddInverte)
	Local lSameOrgDest := .T.
	Local lEnvFaixa    := .T.
	Local lEnvComp     := .T.
	Local oItem        := Nil
	Local cCampos      :=""
	Local cAliasQry    := Nil
	Local nX           := 0
	
	cCampos := ""
	If GFXCP12125("GV2_CPLFXA")
		cCampos += " GV2.GV2_CPLFXA,"
	EndIf	
	cCampos := "%" + cCampos + "%"

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		 SELECT GUC.GUC_CDCOMP CDCOMP,
		 		GUC.GUC_EMICOM DESTINA,
				GVB.GVB_CDCOMP,
				GUC.GUC_VLLIM,
				GV2.GV2_ATRCAL,
				GUC.GUC_CALCEX,
				%Exp:cCampos%
				(GUC.GUC_VLFIXN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) VALORFIXO,
				(GUC.GUC_VLMINN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) VALORMIN,
				CASE WHEN GV2.GV2_ATRCAL IN ('2','2 ',' 2') THEN (GUC.GUC_PCNORM * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEVALOR,
				CASE WHEN GV2.GV2_ATRCAL IN ('9','9 ',' 9') THEN (GUC.GUC_PCNORM * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END SUBTOTFRET,
				CASE WHEN GV2.GV2_ATRCAL IN ('1','1 ',' 1') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEPESOB,
				CASE WHEN GV2.GV2_ATRCAL IN ('10')          THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END FRETEPESOL,
				GUC.GUC_VLFRAC FRACAO,
				CASE WHEN GV2.GV2_ATRCAL IN ('3','3 ',' 3') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEITENS,
				CASE WHEN GV2.GV2_ATRCAL IN ('5','5 ',' 5') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEVOLUM,
				CASE WHEN GV2.GV2_ATRCAL IN ('7','7 ',' 7') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END QTDEENTRG,
				CASE WHEN GV2.GV2_ATRCAL IN ('4','4 ',' 4') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END VOLUME,
				CASE WHEN GV2.GV2_ATRCAL IN ('6','6 ',' 6') THEN (GUC.GUC_VLUNIN * Coalesce(GVB.GVB_VLMULT,1)) + Coalesce(GVB.GVB_VLADIC,0) ELSE 0 END DISTANCIA
		FROM %table:GUC% GUC
		INNER JOIN %Table:GV2% GV2
		ON GV2.GV2_CDCOMP = GUC.GUC_CDCOMP
		AND GV2.GV2_FILIAL = %xFilial:GV2%
		AND GV2.GV2_ATRCAL <> '11'
		AND GV2.GV2_SERVI <> '1'
		AND GV2.%NotDel%
		LEFT JOIN %Table:GVB% GVB
		ON GVB.GVB_FILIAL = %Exp:GVA->GVA_FILIAL%
		AND GVB.GVB_CDEMIT = %Exp:GVA->GVA_CDEMIT%
		AND GVB.GVB_NRTAB = %Exp:GVA->GVA_NRTAB%
		AND GVB.GVB_CDCOMP  = GUC.GUC_CDCOMP
		AND %Exp:GVA->GVA_TPTAB% = '2'
		AND GVB.%NotDel%
		WHERE GUC.GUC_FILIAL = %Exp:(cAlGV9)->GV9_FILIAL%
		AND GUC.GUC_CDEMIT = %Exp:(cAlGV9)->GV9_CDEMIT%
		AND GUC.GUC_NRTAB = %Exp:(cAlGV9)->GV9_NRTAB%
		AND GUC.GUC_NRNEG = %Exp:(cAlGV9)->GV9_NRNEG%
		AND GUC.GUC_CDFXTV = %Exp:(cAlGV9)->GV7_CDFXTV%
		AND GUC.GUC_NRROTA = %Exp:(cAlGV9)->GV8_NRROTA%
		AND GUC.GUC_CDCOMP <> %Exp:(cAlGV9)->GV6_COMFRG%
		AND GUC.%NotDel%
		ORDER BY GUC.GUC_EMICOM
	EndSql
	Do While (cAliasQry)->(!Eof())
		lEnvFaixa := .T.
		lEnvComp  := .T.
		
		/*Tratamento CPL - Verifica se componente admite faixa*/
		If GFXCP12125("GV2_CPLFXA")
			If (cAlGV9)->GV9_TPLOTA == '1' /*Carga Fechada*/ .And. ; 
				(cAliasQry)->GV2_CPLFXA == '2' /*Não considera na faixa*/
				
				lEnvFaixa := .F.

				//Componente Por Faixa = Não, só envia uma vez o componente para cada rota
				If (nPos := aScan(aCompCPLFx, { |x| x[1]+x[2] == (cAlGV9)->GV8_NRROTA + (cAliasQry)->CDCOMP } ) ) == 0
					aAdd(aCompCPLFx, { (cAlGV9)->GV8_NRROTA , (cAliasQry)->CDCOMP} )
				Else
					lEnvComp := .F.
				EndIf
			EndIf
		EndIf
	
		For nX := 1 To 2
		
			lExcedente := (cAliasQry)->GUC_VLLIM <> 0    //Tem excedente informado
			lNormal    := lEnvComp .And. (!lExcedente .Or. compVlNormal(cAliasQry))  //Não tem excedente informado ou tem valor normal
			
			If (nX == 1 .And. lNormal) .Or. (nX == 2 .And. lExcedente)
			
				oItem := oWsNeoLog:NovoItem(cAlGV9)                       //Cria um novo <freightRule>
				oItem:Cabecalho(oGrupo)                                   //Cabeçalho 
				oItem:DefineLocaiseZona(lAddInverte,(cAliasQry)->DESTINA) //Origem e destino
				oItem:AdicionaFatorCubagem()                              //Fator de Cubagem
				oItem:ClassifFrete()                  //Classificação de Frete
				
				If nX == 1 /*Normal*/
					
					If lExcedente
						oItem:AdicionaFaixa(,,(cAliasQry)->GUC_VLLIM,(cAliasQry)->GUC_CALCEX,(cAliasQry)->GV2_ATRCAL,'1') //Faixa
					ElseIf lEnvFaixa 
						oItem:AdicionaFaixa() //Faixa
					EndIF
					
					oItem:AdicionaComponentes(cAliasQry)  //Valores dos Componentes
					
				Else /*Excedente*/
					
					aComp := oItem:AdicionaExcedente(cAliasQry)
					oItem:AdicionaFaixa(,,(cAliasQry)->GUC_VLLIM,(cAliasQry)->GUC_CALCEX,(cAliasQry)->GV2_ATRCAL,'2') //Faixa
					oItem:AdicionaComponentes( Nil , aComp)    //Valores dos Componentes
					
				EndIF
				oGrupo:AddItem(oItem,(cAlGV9)->GV9_TPLOTA)
			EndIf
		Next nX
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	If !Empty(oItem)
		lSameOrgDest := oItem:lSameOrgDest
	EndIf
Return lSameOrgDest

Static Function compVlNormal(cAliasQry)
	Local lNormal := .F.
	
	lNormal := (cAliasQry)->(VALORMIN+VALORFIXO+FRETEVALOR+SUBTOTFRET+FRETEPESOB+FRETEPESOL+QTDEITENS+QTDEVOLUM+QTDEENTRG+VOLUME+DISTANCIA) <> 0
Return lNormal
