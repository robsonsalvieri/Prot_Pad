#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCBENE.CH'

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar

#DEFINE MVCERRCOD 5
#DEFINE MVCERRDES 6
#DEFINE MVCERRSOL 7
#DEFINE PDTE_VALID		"1" // Pendente Validacao
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO			"3" // Invalido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado
#DEFINE JOB_VALID		"1" // Job Validacao
#DEFINE ESPELHO_COMP	"2" // Comparacao de Espelhos
#DEFINE ARQ_RETORNO    "3" // Arquivo Retorno

#DEFINE CAMPO    		1
#DEFINE VALOR_NOVO    	2
#DEFINE VALOR_ANTIGO    3


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCBENE

Manutencao de beneficiarios no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016.
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCBENE(lAuto,cFiltro,cDescript)
	Local   oMark	    := Nil
	Local   aCoors    := FWGetDialogSize( oMainWnd )
	Local   oFWLayer  := FWLayer():New()
	Local   oPnl
	Local   cAlias	  := "B3K"

	Static lTotSelec  := .F.
	Static aMarkInd   := {} 

	Private lMark	  := .F.
	Private cFilBrw	  := ''
	Private oDlgB3K
	Private aRotina	  :=	{}
	Default cFiltro   := ''
	Default cDescript := STR0001
	Default lAuto		  := .F.

	DbSelectArea("B3K")

	(cAlias)->(dbSetOrder(1))
	// Criação dos Componentes Visuais
	If !lAuto
		Define MsDialog oDlgB3K Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgB3K, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	// Cria a Tela do Browse
	oMark:= FWMarkBrowse():New()
	oMark:SetOwner( oPnl )
	oMark:SetFilterDefault( cFiltro )
	oMark:SetDescription( cDescript )
	oMark:SetFieldMark("B3K_MARK")
	oMark:SetAllMark({|| FwMsgRun(,{|oMsgRun| SetMrkAll(oMark, oMsgRun, lAuto)},"Selecionando Todas as Linhas","Identificando linhas afetadas...")})
	oMark:SetMenuDef( 'PLSMVCBENE' )
	oMark:SetAlias( cAlias )
	oMark:SetProfileID( '1' )
	oMark:SetAfterMark({||SelLinha(oMark, lAuto)})
	oMark:ForceQuitButton()
	oMark:DisableDetails(.T.)
	oMark:SetWalkthru(.F.)
	oMark:SetAmbiente(.F.)

	If !lAuto
		oMark:Activate()
		Activate MsDialog oDlgB3K Center
		
		//Desmarca todos os registros marcados no MarkBrowse da tabela B3K
		FwMsgRun(,{|oMgRun| FinalMrk(oMark, lAuto, oMgRun)},"Finalizando Programa","Retirando marcação de linhas...")
	Else
		//Desmarca todos os registros marcados no MarkBrowse da tabela B3K
		FinalMrk(oMark, .T., NIL)
	EndIf

Return oMark
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotEnv	 := {}
	Local aRotVld	 := {}
	Private aRotina	 := {}

	aAdd( aRotEnv, { "Inclusão"     , 'SIBAddMov("' + SIB_INCLUIR + '")' , 0 , 4 , 0 , NIL } )
	aAdd( aRotEnv, { "Cancelamento"	, 'SIBAddMov("' + SIB_CANCELA + '")' , 0 , 4 , 0 , NIL } )
	aAdd( aRotEnv, { "Reativação"	, 'SIBAddMov("' + SIB_REATIVA + '")' , 0 , 4 , 0 , NIL } )

	aAdd( aRotVld, { "Regras gerais SIB"	, 'TypeVldBen("SIB")' , 0 , 9 , 0 , NIL } )
	aAdd( aRotVld, { "Regras SIP"			, 'TypeVldBen("SIP")' 	, 0 , 9 , 0 , NIL } )
	aAdd( aRotVld, { "Benef x CNX"			, 'PLSSIBESP(B3K->(RECNO()),oMark)', 0 , 9 , 0 , NIL } )

	aAdd( aRotina, { STR0002	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { STR0006	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 8 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Inc. Movto SIB"	, aRotEnv		, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Valid. Selec."	, aRotVld		, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Exibir dif. CNX"	, 'PLSB3KB3W(B3K->(Recno()),,.F.)'			, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { STR0008	, 'PLSCARBEN'			, 0 , 3 , 0 , NIL } ) //Imp. Beneficiarios
	aAdd( aRotina, { "Críticas"	, 'PlCenCriBen()'		, 0 , 9 , 0 , NIL } )

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3K

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3K := FWFormStruct( 1, 'B3K')
	Local oStruB3X := FWFormStruct( 1, 'B3X')
	Local oStruB4W := FWFormStruct( 1, 'B4W')
	Local oStruB3F := FWFormStruct( 1, 'B3F')
	Local cExp     := "GetAdvFVal('B3D','B3D_REFERE',xFilial('B3D')+B3F->B3F_CODOPE+B3F->B3F_CDOBRI+B3F->B3F_ANO+B3F->B3F_CDCOMP+'2',1,'',.T.)"
	oStruB3F:AddField(;
		'REF. OBRIG',;
		'REF. OBRIG',;
		'B3F_REFERE',;
		'C',;
		10,;
		0,;
		/*[ bValid ]*/,;
		/*[ bWhen ]*/,;
		/*[ aValues ]*/,;
		/*[ lObrigat ]*/,;
		FwBuildFeature( STRUCT_FEATURE_INIPAD, cExp ),;
		Nil,;
		/*[ lNoUpd ]*/,;
		/*[ lVirtual ]*/,;
		/*[ cValid ]*/;
		)

	oStruB3K:AddField("Hora Mov.",;	// [01] C Titulo do campo
		"Hora Mov.",; // [02] C ToolTip do campo
		"B3K_HORMOV",;// [03] C identificador (ID) do Field
		"C",;			// [04] C Tipo do campo
		8,; 			// [05] N Tamanho do campo
		0,; 			// [06] N Decimal do campo
		Nil,;			// [07] B Code-block de validação do campo
		Nil,; 		// [08] B Code-block de validação When do campo
		Nil,; 		// [09] A Lista de valores permitido do campo
		Nil,; 		// [10] L Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" ),; // [11] B Code-block de inicializacao do campo
		Nil,; 		// [12] L Indica se trata de um campo chave
		Nil,; 		// [13] L Indica se o campo pode receber valor em uma operação de update.
		Nil,; 		// [14] L Indica se o campo é virtual
		)

	oStruB3K:AddField("ID BCA",;	// [01] C Titulo do campo
		"ID BCA",; // [02] C ToolTip do campo
		"B3K_IDBCA",;// [03] C identificador (ID) do Field
		"C",;			// [04] C Tipo do campo
		10,; 			// [05] N Tamanho do campo
		0,; 			// [06] N Decimal do campo
		Nil,;			// [07] B Code-block de validação do campo
		Nil,; 		// [08] B Code-block de validação When do campo
		Nil,; 		// [09] A Lista de valores permitido do campo
		Nil,; 		// [10] L Indica se o campo tem preenchimento obrigatório
		nil,; //
		)

	oModel := MPFormModel():New( STR0001,,,{ |oModel| PLCenGrvBen( oModel ) } )
	oModel:AddFields( 'B3KMASTER', NIL, oStruB3K )
	oModel:AddGrid( 'B3XDETAIL', 'B3KMASTER', oStruB3X )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B3XDETAIL',  { 	{ 'B3X_FILIAL', 'xFilial( "B3K" )' },;
		{ 'B3X_BENEF' , 'B3K->(Recno())' };
		}, B3X->( IndexKey( 1 ) ) )

	oModel:GetModel( 'B3KMASTER' ):SetDescription( STR0001 )
	oModel:GetModel( 'B3XDETAIL' ):SetDescription( "Movimentações" )
	oModel:SetDescription( STR0001 )

	oModel:GetModel( 'B3XDETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3XDETAIL' ):SetOptional(.T.)


	oModel:addGrid('B4WDETAIL','B3KMASTER',oStruB4W)
	oModel:getModel("B4WDETAIL"):SetOptional(.T.)
	oModel:getModel('B4WDETAIL'):SetDescription('Dados das Notas do Aluno')
	oModel:setRelation("B4WDETAIL", ;
		{{"B4W_FILIAL",'xFilial("B4W")'},;
		{"B4W_MATRIC","B3K_MATRIC"  }},;
		B4W->(IndexKey(1)))

	oModel:addGrid('B3FDETAIL','B3XDETAIL',oStruB3F)
	oModel:getModel("B3FDETAIL"):SetOptional(.T.)
	oModel:getModel('B3FDETAIL'):SetDescription('Críticas Movimento')
	oModel:setRelation("B3FDETAIL", ;
		{{"B3F_FILIAL",'xFilial("B3F")'},;
		{"B3F_ORICRI",'"B3X"'},;
		{AllTrim("B3F_IDEORI"),AllTrim("B3K->B3K_MATRIC")}},;
		B3F->(IndexKey(1)))

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3K

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCBENE' )
	Local oStruB3K := FWFormStruct( 2, 'B3K' )
	Local oStruB3X := FWFormStruct( 2, 'B3X' )
	Local oStruB4W := FWFormStruct( 2, 'B4W' )
	Local oStruB3F := FWFormStruct( 2, 'B3F' )

	Local oView    := FWFormView():New()

	oStruB3F:AddField( ; // Ord. Tipo Desc.
		'B3F_REFERE' , ; // [01] C Nome do Campo
		'00' , ; // [02] C Ordem
		'Ref. Obrig', ; // [03] C Titulo do campo
		'REFERENCIA OBRIGAÇÃO', ; // [04] C Descrição do campo
		{ 'Referência obrigação movimento crítica' } , ; // [05] A Array com Help
		'C' , ; // [06] C Tipo do campo
		'@!' , ; // [07] C Picture
		NIL , ; // [08] B Bloco de Picture Var
		'' , ; // [09] C Consulta F3
		.T. , ; // [10] L Indica se o campo é evitável
		NIL , ; // [11] C Pasta do campo
		NIL , ; // [12] C Agrupamento do campo
		NIL, ; // [13] A Lista de valores permitido do campo (Combo)
		NIL , ; // [14] N Tamanho Máximo da maior opção do combo
		NIL , ; // [15] C Inicializador de Browse
		.T. , ; // [16] L Indica se o campo é virtual
		NIL ) // [17] C Picture Variável

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3K' , oStruB3K, 'B3KMASTER' )
	oView:AddGrid( 'VIEW_B3X'  , oStruB3X, 'B3XDETAIL' )
	oView:AddGrid( 'VIEW_B4W'  , oStruB4W, 'B4WDETAIL' )
	oView:AddGrid( 'VIEW_B3F'  , oStruB3F, 'B3FDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 50 )

	oView:CreateHorizontalBox( 'BOXFOLDER', 50)
	oView:CreateFolder( 'FOLDER', 'BOXFOLDER')
	oView:addSheet("FOLDER","ABA1","Movimento SIB")
	oView:addSheet("FOLDER","ABA2","Historico")
	oView:addSheet("FOLDER","ABA3","Criticas Movi.")

	oView:createHorizontalBox("BOX_SUPERIOR",100,,,"FOLDER","ABA1")
	oView:createHorizontalBox("BOX_INFERIOR",100,,,"FOLDER","ABA2")
	oView:createHorizontalBox("BOX_CRITICAS",100,,,"FOLDER","ABA3")

	oView:CreateVerticalBox( 'BOX_MOVI', 100, 'BOX_SUPERIOR',,"FOLDER","ABA1")
	oView:CreateVerticalBox( 'BOX_HIST', 100, 'BOX_INFERIOR',,"FOLDER","ABA2")
	oView:CreateVerticalBox( 'BOX_CRIT', 100, 'BOX_CRITICAS',,"FOLDER","ABA3")

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_B3K', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3X', 'BOX_MOVI' )
	oView:SetOwnerView( 'VIEW_B4W', 'BOX_HIST' )
	oView:SetOwnerView( 'VIEW_B3F', 'BOX_CRIT' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_B3K', "Beneficiário" )
	oView:EnableTitleView( 'VIEW_B3X', "Movimento SIB" )
	oView:EnableTitleView( 'VIEW_B4W', "Historico do Bloqueio" )
	oView:EnableTitleView( 'VIEW_B3F', "Críticas do Movimento" )

Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCGrvBen

Funcao criada para encapsular a gravação e limpar o model depois

@author everton.mateus
@since 21/07/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLCGrvBen( oModel,lSoVld,aCrit,lEnvOpe,dDatAlt, lAuto)

	Local lGravou   := .F.
	Default oModel	:= Nil
	Default lSoVld	:= .F.
	Default aCrit	:= {}
	Default lEnvOpe	:= .T.
	Default dDatAlt	:= dDataBase
	Default lAuto   := .F.

	lGravou := PLCenGrvBen( oModel,lSoVld,aCrit,lEnvOpe,,,,,,, dDatAlt,lAuto)

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return lGravou
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGrvBen

Funcao criada para validar e persistir os dados

@author everton.mateus
@since 21/07/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLCenGrvBen( oModel,lSoVld,aCrit,lEnvOpe,lUsaSIB,lUsaSIP,lSIBSincrono,lVldSibSin,lGrvCritic,lAltCancel, dDatAlt, lAuto, aDadosAlt,lDatAlt, aDadEnv,lChange)

	Local lGravou    := .F.
	Local nOpc       := oModel:GetOperation()
	Local nI         := 0
	Local nRecno     := B3K->(Recno())
	Local cCampos    := ""
	Local cRegAns    := oModel:GetValue( "B3KMASTER", 'B3K_CODOPE' )
	Local cMatric    := oModel:GetValue( "B3KMASTER", 'B3K_MATRIC' )
	Local cSitAns    := ""
	Local cSitAnsAnt := ""
	Local cNome      := ""
	Local cMotBlo    := ""
	Local cOpera     := ""
	Local cHoraMov   := ""
	Local cCodCco    := ""
	Local dDatInc    := STOD("")
	Local dDatBlo    := STOD("")
	Local dDatRea    := STOD("")
	Local lBenVld    := .T.
	Local lModelFake := GetClassName(oModel) == 'CENLOADMODEL'
	Local lValid     := .T.
	Local cTimeMov   := ""
	Local cTbBCAId   := ""

	Default aCrit 	     := {}
	Default lSoVld 	     := .F.
	Default lEnvOpe      := .T.
	Default lUsaSIB		 := "2" $ GetNewPar("MV_PLSTIPO","")
	Default lUsaSIP		 := "1" $ GetNewPar("MV_PLSTIPO","")
	Default lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
	Default lVldSibSin 	 := "2" $ GetNewPar("MV_PLVLDSI","2") .AND. lSIBSincrono
	Default lGrvCritic	 := GetNewPar("MV_PLGRCRI",.T.) //Indica se pode gravar o registro mesmo com críticas.
	Default lAltCancel	 := GetNewPar("MV_PLATCAN",.F.) //Indica se beneficiarios inativos enviarao retificacoes para a ANS
	Default	dDatAlt		 := dDataBase
	Default	lAuto        := .F.
	Default aDadosAlt    := IIf(aDadosAlt == Nil,{},aDadosAlt)
	Default lDatAlt      := lDatAlt
	Default aDadEnv      := {}
	Default lAuto        := .T.
	Default lChange      := .F.

	lGrava := !lSoVld

	//Preencho o model com os dados que vieram da rotina
	If lUsaSib .AND. lEnvOpe

		cSitAns    := oModel:GetValue( "B3KMASTER", "B3K_SITANS" )
		cSitAnsAnt := IIf(cSitAns == 'A','I','A')
		cMatric    := oModel:GetValue( "B3KMASTER", 'B3K_MATRIC' )
		cNome      := oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN' )
		cMotBlo    := oModel:GetValue( "B3KMASTER", 'B3K_MOTBLO' )
		cOpera     := oModel:GetValue( "B3KMASTER", 'B3K_OPESIB' )
		cHoraMov   := Time()
		lBenNaAns  := PlBenNaANS(oModel)
		cDesOpe    := RetOpeSIB(cOpera,lBenNaAns)
		dDatInc    := oModel:GetValue( "B3KMASTER", 'B3K_DATINC' )
		dDatInc    := IIf(Empty(dDatInc),dDataBase,dDatInc)
		dDatBlo    := oModel:GetValue( "B3KMASTER", 'B3K_DATBLO' )
		dDatRea    := oModel:GetValue( "B3KMASTER", 'B3K_DATREA' )
		cCodCco    := oModel:GetValue( "B3KMASTER", 'B3K_CODCCO' )
		cTimeMov   := oModel:GetValue( "B3KMASTER", "B3K_HORMOV" )
		cTbBCAId   := oModel:GetValue( "B3KMASTER", "B3K_IDBCA"  )

		If ValType(cTimeMov) <> "U" .And. !Empty(cTimeMov)
			cHoraMov := cTimeMov
		EndIf

		/*/
			Caso tenha sido chamado
			de outra fonte
			a não ser o CenLoadModel
		/*/
		If !lDatAlt
			RetDadosAlt(oModel,aDadosAlt,@cCampos)
		EndIf

	EndIf

	//Se nao tiver crítica ou Se permite gravar mesmo criticado ou a Validacao e assincrona (Schedulada)
	If lGrava .AND. (lBenVld .OR. lGrvCritic .OR. !lVldSibSin )

		If lModelFake
			lValid	:= oModel:VldData()
			cRotUpd	:= 'oModel:commitData('+cValToChar(lEnvOpe)+')'
		Else
			cRotUpd	:= 'FWFormCommit( oModel )'
		EndIf

		If lValid

			lGravou :=  &(cRotUpd)

			If lGravou

				If nOpc == MODEL_OPERATION_DELETE
					lGravou := CnLmpCriBen(nRecno,"B3K")
					If lGravou
						lGravou := CnLmpHisBlo(cMatric)
						If lGravou
							lGravou := CnLmpMovSib(nRecno)
						EndIf
					EndIf
				Else
					//Atualizo a tabela de historico de operacoes do SIB
					If lUsaSib .AND. lEnvOpe

						If (cDesOpe $ "Incluir,Alterar,Transferir" .AND. !lBenNaAns)

						If ( cSitAns == 'A' .OR. lAltCancel)

							If cDesOpe == "Transferir"
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_MUDCONT,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
							ElseIf cDesOpe == "Alterar"
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_RETIFIC,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"",cSitAns,cCodCco)
							Else
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_INCLUIR,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
							EndIf


							//Se o beneficiario nao esta na ANS e veio bloqueado, eu gero um bloqueio pra ele
							If GetNewPar("MV_PLINBLS",.F.) .AND. !Empty(dDatBlo) .AND. !Empty(cMotBlo) .AND. cSitAns == "I"

								B3X->(DbSetOrder(3)) //B3X_FILIAL+B3X_BENEF+B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+DTOS(B3X_DATA)
								If  !B3X->(MsSeek(xFilial("B3X")+PADL(AllTrim(Str(B3K->(Recno()))),10)+PADR("",tamSX3("B3X_CAMPO")[1])+SIB_CANCELA))
									//Atualizo o historico de cancelamentos
									PLInHisCanCO(dDatBlo,.T.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco, NIL, cTbBCAId)
									PlAtuHisOpe(B3K->(Recno()),"",dDatBlo,SIB_CANCELA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco, NIL, cTbBCAId)
								EndIf

							EndIf

						EndIf

					ElseIf cDesOpe == "Cancelar"

						If !lBenNaAns
							PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_INCLUIR,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco, NIL, cTbBCAId)
						EndIf
						//Atualizo o historico de cancelamentos
						PLInHisCanCO(dDatBlo,.T.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco, NIL, cTbBCAId)
						PlAtuHisOpe(B3K->(Recno()),"",dDatBlo,SIB_CANCELA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco, NIL, cTbBCAId)
						CnVldSibBn(.T.)

					ElseIf cDesOpe == "Reativar"
						//Atualizo o historico de cancelamentos
						PLInHisCanCO(dDatRea,.F.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco, NIL, cTbBCAId)
						PlAtuHisOpe(B3K->(Recno()),"",dDatRea,SIB_REATIVA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco, NIL, cTbBCAId)

					ElseIf cDesOpe == "Transferir"

						PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_MUDCONT,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)

					ElseIf lBenNaAns //As opeacoes abaixo so podem ser incluídas se o beneficiario ja esta na base da ANS.

						If cDesOpe == "Alterar" .AND. (cSitAns == 'A' .OR. lAltCancel)

							lGera := Len(aDadosAlt) == 0 .AND. Len(aDadEnv) > 0

							If lGera
								nLen := Len(aDadEnv)
								For nI := 1 to nLen
									/*/
											Quando enviado pela API movimentações de retificação que não possuem
											diferença entre o registro na central e os dados enviados na API,
											o array aDadEnv é preenchido com os campos enviados na API
											e gerado uma retificação com os campos enviados na requisição PUT
									/*/
									PlAtuHisOpe(B3K->(Recno()),aDadEnv[nI,CAMPO],dDatAlt,SIB_RETIFIC,cMatric,;
										cNome,lVldSibSin,lGrvCritic,cRegAns,,;
										cHoraMov,aDadEnv[nI,VALOR_NOVO],aDadEnv[nI,VALOR_NOVO],cCodCco,lChange)
								Next nI
							Else
								nLen := Len(aDadosAlt)
								For nI := 1 to nLen
									PlAtuHisOpe(B3K->(Recno()),aDadosAlt[nI,CAMPO],dDatAlt,SIB_RETIFIC,cMatric,;
										cNome,lVldSibSin,lGrvCritic,cRegAns,,;
										cHoraMov,aDadosAlt[nI,VALOR_ANTIGO],aDadosAlt[nI,VALOR_NOVO],cCodCco,lChange)
								Next nI
							EndIf

						EndIf //If cDesOpe == "Alterar"

					EndIf //If cDesOpe == "Incluir"

					CnVldSibBn(.T.)

				EndIf //If lUsaSib .AND. lEnvOpe

			EndIf //If nOpc != MODEL_OPERATION_DELETE

		EndIf

	EndIf //VldData

	EndIf //If lGrava .AND. (lBenVld .OR. lGrvCritic .OR. !lVldSibSin )

	If lUsaSib .AND. lEnvOpe
		If cDesOpe == "Alterar" .AND. lBenNaAns
			If !Empty(cCampos)
				lBenVld := PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,oModel,JOB_VALID,aCrit,,,,cCampos,cDesOpe)
			EndIf
		Else
			lBenVld := PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,oModel,JOB_VALID,aCrit,IIf(lGrava,B3X->(Recno()),0) ,,,cCampos,cDesOpe)
		EndIf
	EndIf

Return lGravou

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlGrvDesHis

Função que busca no banco a descrição do campo B3X_CAMPO com uma melhor descrição,
incluindo o campo B3X_DESCRI para traduzir o campo.

@author vinicius.nicolau
@since 23/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PlGrvDesHis()

Return PlGrvDesCri(ALLTRIM(B3X->B3X_CAMPO))

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlGrvDesCri

Função que busca no banco a descrição do campo B3F_CAMPOS com uma melhor descrição,
incluindo o campo B3F_LEGEN para traduzir o campo.

@author vinicius.nicolau
@since 23/06/2020
/*/
//--------------------------------------------------------------------------------------------------

Function PlGrvDesCri(cCampos)

	Local cRet := ""
	Local cSep := " / "
	Local nCampo := 0
	Local aCampos := {}
	Default cCampos := AllTrim(B3F->B3F_CAMPOS)

	aCampos := StrTokArr(cCampos,".")

	For nCampo := 1 To Len(aCampos)
		Iif(nCampo > 1, cRet += cSep,)
		cRet += X3Desc(aCampos[nCampo])
	Next nCampo

Return cRet

Static Function X3Desc(cCampo)
	Local cDesc := ""
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek( cCampo ) )
		cDesc := X3Descric()
	EndIf
Return cDesc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetOpe

Retorna o texto descritivo da operação do SIB

@param cOpera		Código da Operação SIB. 1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar;6=Atualizado ANS

@return cOpe		Descrição da Operação

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function RetOpeSIB(cOpera,lBenNaAns)
	Local cOpe := ""
	Default cOpera := "1"

	Do Case

		Case cOpera == '1' .OR. (cOpera == '2' .AND. !lBenNaAns)

			cOpe := "Incluir"

		Case cOpera == '2'

			cOpe := "Alterar"

		Case cOpera == '3'

			cOpe := "Transferir"

		Case cOpera == '4'

			cOpe := "Cancelar"

		Case cOpera == '5'

			cOpe := "Reativar"

	EndCase

Return cOpe

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreencheModel

Verifico se o beneficiario ja foi incluído na base da ANS

@param cAlias		Area de trabalho corrente
@param oModel		Objeto do model de beneficiarios
@param aDados		Dados que vieram do ERP
@param aDadosAlt	Campos que serao enviados para a ANS

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function RetDadosAlt(oModel,aDadosAlt,cCampos)

	Local cNaoEnvia	:=  "B3K_TRADES,B3K_TRAORI,B3K_SITANS,B3K_MATANT,B3K_STASIB,B3K_DATREA,B3K_STAESP,"+;
		"B3K_STATUS,B3K_DATBLO,B3K_MOTBLO,B3K_UF,B3K_CODCCO,B3K_OPESIB,B3K_SUSEP,B3K_CODPRO,"+;
		"B3K_SCPA,B3K_CRINOM,B3K_CRIMAE,B3K_HRINVL,B3K_HRTEVL,B3K_NOMECO"

	Local cCampo	 := ""
	Local cValorAnt	 := ""
	Local cValorNovo := ""
	Local nI 		 := 0
	Local nLen 		 := 0
	Local lVlrMudou	 := 0

	Default oModel    := nil
	Default aDadosAlt := {}
	Default cCampos   := ""

	If oModel <> nil
		aCampos := FWFORMSTRUCT(1,"B3K"):aFields
		nLen := Len(aCampos)
		For nI := 1 to nLen

			cCampo := aCampos[nI,3]

			//So grava valores que foram alterados
			cValorNovo := oModel:GetValue( "B3KMASTER", cCampo)
			cValorAnt := &("B3K->"+cCampo)

			If ValType(cValorAnt) == 'C'
				cValorAnt := AllTrim(cValorAnt)
				cValorNovo := AllTrim(cValorNovo)
			EndIf

			//Para evitar atualizacoes desnecessarias, so atualizo se o valor mudou
			lVlrMudou := cValorNovo != Nil .AND. !(cValorNovo == cValorAnt)
			//Regra para saber se deve atualizar o valor no NIO
			If lVlrMudou .AND. !(cCampo $ cNaoEnvia) //Verifica se deve enviar o campo para a ANS
				aAdd(aDadosAlt, {cCampo,cValorNovo,cValorAnt} )
				cCampos += cCampo + "."
			EndIf

		Next nI

		//Remove o último ponto
		nLen := Len(AllTrim(cCampos))
		If nLen > 0
			cCampos := SubStr(cCampos ,1, nLen-1)
		EndIf

	EndIf //If oModel <> nil

Return len(aDadosAlt) > 0

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExibeCadastro

Funcao criada para exibir as telas de cadastros de beneficiario, produto ou despesa

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCenCriBen()
	Local cFiltro := " B3F_FILIAL = xFilial( 'B3F' ) .AND. " +;
		" B3F_ORICRI = 'B3K' .AND. " +;
		" B3F_CHVORI = " + AllTrim( Str( B3K->( Recno() )  ) ) + " "
	PLBRWCrit(cFiltro)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSENVANS

Força o envio de uma operação para a ANS

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSENVANS(cOpe, aMark, lJob, cEmp, cFil)

	Local lRet       := .T.
	Local lCSV
	Local cPath      := "\sib\"
	Local cNamArq    := "log_erros_movimentacoes"
	Local cMatric    := ""
	Local cMotBlo    := ""
	Local dDtRef     := iif(!lJob,dDataBase,date())
	Local dDatInc    := CTOD("")
	Local aBeneError := {}
	Local aBeneOK    := {}
	Local aHeaderCSV := {}
	Local aAreaB3K
	Local nBene
	Local nErrors
	Local oCSV
	Local cCodCco := ""
	Default cOpe  := SIB_INCLUIR
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	DbSelectArea("B3K")
	aAreaB3K   := B3K->(GetArea())

	cNome 	:= B3K->B3K_NOMBEN
	dDatInc := B3K->B3K_DATINC
	cMatric := B3K->B3K_MATRIC
	cRegANS := B3K->B3K_CODOPE
	cCodCCO := B3K->B3K_CODCCO

	If Len(aMark)>0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		aAreaB3K   := B3K->(GetArea())
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			lRet := .T.
			B3K->(DBGOTO(aMark[nBene][2]))

			cNome 	:= B3K->B3K_NOMBEN
			dDatInc := B3K->B3K_DATINC
			cMatric := B3K->B3K_MATRIC
			cRegANS := B3K->B3K_CODOPE
			cCodCCO := B3K->B3K_CODCCO

			If cOpe == SIB_INCLUIR
				If !Empty(B3K->B3K_CODCCO)

					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O Beneficiário já possui CCO, não é possível enviar uma inclusão."})
					lRet := .F.

				Else
					dDtRef := B3K->B3K_DATINC
					B3X->(DbSetOrder(3)) //B3X_FILIAL+B3X_BENEF+B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+DTOS(B3X_DATA)
					If B3X->(MsSeek(xFilial("B3X")+PADL(AllTrim(Str(B3K->(Recno()))),10)+PADR("",tamSX3("B3X_CAMPO")[1])+cOpe ) )
						aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O Beneficiário já possui um movimento de inclusão, não é possível enviar outra inclusão."})
						lRet := .F.
					EndIf
				EndIf

			ElseIf cOpe == SIB_CANCELA

				If Empty(B3K->B3K_DATBLO)
					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O beneficiário não possui dados de bloqueio. Realize o bloqueio pelo sistema de origem."})
					lRet := .F.
				Else
					DadosBloq("0",@dDtRef,@cMotBlo)
				EndIf

			ElseIf cOpe == SIB_REATIVA
				If Empty(B3K->B3K_DATREA)
					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O beneficiário não possui dados de desbloqueio. Realize o desbloqueio pelo sistema de origem."})
					lRet := .F.
				Else
					DadosBloq("1",@dDtRef,@cMotBlo)
				EndIf

			EndIf

			//Recupera valores

			If lRet
				cHoraMov := Time()
				sleep(750)

				If cOpe $ SIB_CANCELA + "," + SIB_REATIVA
					//Atualizo o histórico de cancelamentos
					PLInHisCanCO(dDtRef,cOpe==SIB_CANCELA,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco)
				EndIf

				PlAtuHisOpe(B3K->(Recno()),"",dDtRef,cOpe,cMatric,cNome,,,cRegANS,,cHoraMov,"","",cCodCCO)

				aAdd(aBeneOK,{B3K->B3K_MATRIC,"Movimentação incluída."})
			EndIf

		Next nBene
		RestArea(aAreaB3K)

	Elseif !isblind()
		Alert("Selecione ao menos um beneficiário")
	EndIf

	If len(aBeneOK) > 0 .AND. !isblind()
		msgInfo(cValtoChar(len(aBeneOK)) + ' movimentações incluídas. ', "Aviso")
	EndIf

	If len(aBeneError) > 0
		aHeaderCSV:={"Matrícula","CCO","Erro"}
		oCSV := CenCSV():New(aHeaderCSV)
		For nErrors := 1 to len(aBeneError)
			oCSV:AddLine(aBeneError[nErrors])
		Next nErrors
		If !lJob .AND. !ISBLIND()
			If MsgYesNo(cValtoChar(len(aBeneError)) + ' movimentações não incluídas. Deseja baixar o arquivo de log?')
				cPath := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
				lCSV := oCSV:createFile(cPath, cNamArq)
				If lCSV
					msgInfo("Arquivo log gerado com sucesso.")
				EndIf
			EndIf
		Else
			cPath := "\sib\"
			lCSV := oCSV:createFile(cPath, cNamArq)
		EndIf

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DadosBloq

Retorna o RetMatric do beneficiário

@return lRet .T. pendente envio de inclusão

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function DadosBloq(cTipo,dData,cMotBlo)

	Local lRet := .T.

	Default cTipo := "0" //0=Bloqueio;1=Desbloqueio
	Default dData := CTOD("")
	Default cMotBlo := ""

	If (cTipo =='0' .AND. Empty(B3K->B3K_DATBLO) ) .OR.;
			(cTipo =='1' .AND. Empty(B3K->B3K_DATREA) )//Se o beneficiário estiver ativo
		//Busco no histórico os dados do último (des)bloqueio para reenviar

		cSql := " SELECT B4W_DATA ,B4W_MOTBLO "
		cSql += " FROM " + RetSqlName("B4W") + " "
		cSql += " WHERE "
		cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
		cSql += "	AND B4W_MATRIC = '"+ B3K->B3K_MATRIC +"' "
		cSql += "	AND B4W_TIPO = '" + cTipo + "' "
		cSql += "	AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY B4W_DATA DESC "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBLO",.F.,.T.)

		If TRBBLO->(Eof())
			lRet := .F.
		Else
			dData := TRBBLO->DATA
			cMotBlo := TRBBLO->B4W_MOTBLO
		EndIf

		TRBBLO->(DbCloseArea())

	Else
		If cTipo == "0"
			dData   := B3K->B3K_DATBLO
			cMotBlo := B3K->B3K_MOTBLO
		Else
			dData   := B3K->B3K_DATREA
			cMotBlo := B3K->B3K_MOTBLO
		EndIf
	EndIf

Return lRet

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} PLSVLDHIST
Verifica se o Histórico de bloqueio do beneficiario pode ser alterado
respeitando as regras da Central de Obrigações

@param dDatAnt, Data  , Data anterior a alteração
@param oMdPrin,	Objeto,	Model principal

@return lPermAlt,	Permissão para alterar o histórico
/*/
Function PLSVLDHIST(dDatAnt, oMdPrin)
	
	LOCAL lPermAlt   := .T.
	LOCAL dDataAtu   := CTOD("")
	Local cTbIdBca   := ""
	Local cMatricFam := ""
	Local cTpReg     := ""
	Local cDigBen    := ""
	Local cQryBA1    := ""
	Local oBCAMd     := NIL
	Local nQtdBA1	 := 0
	
	Default dDatAnt  := STOD("")
	Default oMdPrin  := NIL

	oBCAMd := oMdPrin:GetModel("BCADETAIL")

	cAutomato := AllTrim(oBCAMd:GetValue("BCA_OBS"))		

	cMatricFam := oBCAMd:GetValue("BCA_MATRIC")
	cTpReg     := oBCAMd:GetValue("BCA_TIPREG")
	cDigBen    := oMdPrin:GetModel("BA1MASTER"):GetValue("BA1_DIGITO")
	dDataAtu   := oBCAMd:GetValue("BCA_DATA")//Data apos a alteração do Grid
	cTbIdBca   := oBCAMd:GetValue("BCA_ID")

	//////////////////////////////////////////////////////////////////////////////////////////
	//Pesquiso movimentação na BD5 - Digitação de Contas     
	//////////////////////////////////////////////////////////////////////////////////////////
	BD5->(DbSetOrder(5)) 
	If	BD5->(MsSeek( xFilial("BD5") + (cMatricFam + cTpReg + cDigBen)))		
		
		While !BD5->(Eof())	.and. BD5->(BD5_FILIAL + BD5_OPEUSR + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO) ==  ;
								  xFilial("BD5") + (cMatricFam + cTpReg + cDigBen)
			
			If (BD5->BD5_DATPRO >= dDataAtu .and. BD5->BD5_DATPRO <= dDatAnt) .or. (BD5->BD5_DATPRO>= dDatAnt .and. BD5->BD5_DATPRO <= dDataAtu )
				
				lPermAlt := .F.
				If cAutomato != "lAutomato" 
					oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
								     		"Existe movimentação na BD5", "Não será possível alterar a data de bloqueio")  
				EndIf	
				exit				
			EndIf
			BD5->(DbSkip())
		EndDo		
	EndIf

	//////////////////////////////////////////////////////////////////////////////////////////
	//Pesquiso movimentação na BE4 - Digitação de contas - Internações     
	//////////////////////////////////////////////////////////////////////////////////////////
	BE4->(DbSetOrder(4))
	If lPermAlt .AND. BE4->(MsSeek(xFilial("BE4") + cMatricFam))
		
		While !BE4->(Eof()) .and. BE4->(BE4_FILIAL + BE4_OPEUSR + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG)  == xFilial("BE4") + cMatricFam + cTpReg
			
			If (BE4->BE4_DTDIGI >= dDataAtu .and. BE4->BE4_DTDIGI <= dDatAnt) .or. (BE4->BE4_DTDIGI>= dDatAnt .and. BE4->BE4_DTDIGI <= dDataAtu )
				
				lPermAlt := .F.
				If cAutomato != "lAutomato"
					oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
								     		"Existe movimentação na BE4", "Não será possível alterar a data de bloqueio") 
				EndIf	
				exit				
			EndIf
			BE4->(DbSkip())
		EndDo		
	EndIf

	//////////////////////////////////////////////////////////////////////////////////////////
	//Pesquiso movimentação na BOW - Protocolo de Reembolso		
	//////////////////////////////////////////////////////////////////////////////////////////
	BOW->(DbSetOrder(5))	
	If lPermAlt .AND. BOW->(MsSeek(xFilial("BOW") + (cMatricFam + cTpReg + cDigBen)))								 			
		
		While !BOW->(Eof()) .and. BOW->(BOW_FILIAL + BOW_USUARI) == xFilial("BOW") + (cMatricFam + cTpReg + cDigBen)
			
			If (BOW->BOW_DTDIGI >= dDataAtu .and. BOW->BOW_DTDIGI <= dDatAnt) .or. (BOW->BOW_DTDIGI >= dDatAnt .and. BOW->BOW_DTDIGI <= dDataAtu )

				lPermAlt := .F.
				If cAutomato != "lAutomato"
					oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
								     		"Existe movimentação na BOW", "Não será possível alterar a data de bloqueio") 
				EndIf
				exit
			EndIf
		
			BOW->(DbSkip())
		EndDo
	EndIf	

	If lPermAlt
		
		//////////////////////////////////////////////////////////////////////////////////////////
		//verifica se nao houve movimentacao no periodo de bloqueio na tabela de faturamento
		//////////////////////////////////////////////////////////////////////////////////////////
		BM1->(DbSetOrder(1))
		If BM1->(MsSeek(xFilial("BM1") + cMatricFam + cValToChar(Year(dDatAnt)) + StrZero(Month(dDatAnt), 2) + cTpReg))
			
			lPermAlt := .F.
			If cAutomato != "lAutomato"
				oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
										"Este beneficiário já possui faturamento gerado no mês de bloqueio",;
										"Não será possível alterar a data de bloqueio pois irá causar inconsistência no período considerado para o faturamento";
									   ) 
			EndIf
		EndIf
	EndIf
	
	If lPermAlt .and. oBCAMd:GetValue("BCA_NIVBLQ") == "F"

		//////////////////////////////////////////////////////////////////////////////////////////
		//Verifica se possui mais de um beneficiario na familia
		//////////////////////////////////////////////////////////////////////////////////////////
		cQryBA1 := "SELECT COUNT(BA1_MATRIC) CT_MATRIC FROM " +  RetSqlName("BA1") 
		cQryBA1 += "	WHERE "
		cQryBA1 += "	BA1_FILIAL = '" + xFilial("BA1") + "' AND "
		cQryBA1 += "	BA1_CODINT = ?   					  AND "
		cQryBA1 += "	BA1_CODEMP = ?   					  AND "
		cQryBA1 += "	BA1_MATRIC = ?   					  AND "
		cQryBA1 += "	D_E_L_E_T_ = ' ' "

		nQtdBA1 := MPSysExecScalar(cQryBA1,'CT_MATRIC',{SUBSTR(cMatricFam,1,4), SUBSTR(cMatricFam,5,4), SUBSTR(cMatricFam,9  )})

		If nQtdBA1 > 1

			//////////////////////////////////////////////////////////////////////////////////////////
			//Se possuir mais de um beneficiario na familia (titular e dependente), so permite alterar
			//a data de bloqueio caso a familia nao esteja bloqueada
			//////////////////////////////////////////////////////////////////////////////////////////
			BA3->(DbSetOrder(1))
			If BA3->(MsSeek(xFilial("BA3") + cMatricFam))
				If !Empty(BA3->BA3_DATBLO)
					
					lPermAlt := .F.
					If cAutomato != "lAutomato"
						oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
												"Esse bloqueio foi aplicado à família inteira e não pode ser alterado individualmente.",;
												"Desbloqueie a família e bloqueie apenas este beneficiário.") 
					EndIf
				else
					lPermAlt := .F.
					if cAutomato != "lAutomato"
						oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
												"Esse desbloqueio foi aplicado à família inteira e não pode ser alterado individualmente.",;
												"Necessário realizar um novo bloqueio e em seguida um desbloqueio para a data desejada.")
					endif
				EndIf
			EndIf
		EndIf
	EndIf	

	If lPermAlt
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		//Caso o registro do bloqueio nao possua ID, e possuir mais de um bloqueio com a mesma data
		// o sistema ira exibir um aviso informando que existem registros de bloqueio com a mesma data
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		If !Inconsistencia(cMatricFam, cTpReg, cTbIdBca, DTOS(dDatAnt))
			
			If oMdPrin:GetModel("BA1MASTER"):GetValue("BA1_INFSIB") == "1"/*SIM*/
			
				B4W->(DbSetOrder(3))

				If B4W->(MsSeek(xFilial("B4W") + PADR((cMatricFam + cTpReg + cDigBen), tamSX3("B4W_MATRIC")[1]) + cTbIdBca + DTOS(dDatAnt) + "0" /*bloqueio*/))

					/////////////////////////////////////////////////////////////////////////////////////////////////////
					//Se a movimentacao ja foi enviada, nao permite alteracao
					If B4W->B4W_STATUS == "1" //ativo
						
						B3X->(DbSetOrder(6))
						If B3X->(MsSeek(xFilial("B3X") + PADR((cMatricFam + cTpReg + cDigBen), tamSX3("B3x_IDEORI")[1]) + cTbIdBca + DTOS(dDatAnt) + "4" /*cancelar*/))

							/////////////////////////////////////////////////////////////////////////////////////////////////////
							//Se a movimentacao ja foi enviada, nao permite alteracao
							If B3X->B3X_STATUS $('4,6') 
								lPermAlt := .F.

								oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
														"Houve movimentação no SIB", "Não será possível alterar a data de bloqueio") 
							EndIf
						Else
							
							oMdPrin:SetErrorMessage("BCADETAIL", "", "BCADETAIL", "", "Atenção",;
													"Não foi possível localizar o registro de movimentação do SIB",;
													"Apenas o histórico de bloqueio e a data de bloqueio do beneficiário serão alterados") 
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lPermAlt := .F.
		EndIf
	EndIf

Return lPermAlt

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnLmpHisBlo

Limpa o historico de bloqueio de um beneficiários

@return lRetorno	.F. registros nao apagados ou .T. registros apagados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnLmpHisBlo(cMatric)

	Local cSql			:= ""	//Query a ser executada
	Local lRet			:= .T.

	cSql := " DELETE FROM " + RetSqlName('B4W') + " "
	cSql += " WHERE "
	cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
	cSql += "	AND B4W_MATRIC = '" + cMatric + "' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnVldSibBn

Executa a rotina de validação de regras gerais do SIB para o beneficiario selecionada

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnVldSibBn(lAuto, aMark, lJob, cEmp, cFil)
	Local nBene
	local aAreaB3K

	Default	lAuto := .F.
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	aAreaB3K := B3K->(GetArea())

	If len(aMark) > 0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			B3K->(DBGOTO(aMark[nBene][2]))
			PLSIBVLBN(cEmpAnt,cFilAnt,nil,DTOS(dDataBase),B3K->B3K_CODOPE,cEmpAnt,nil,"Incluir","1",nil,B3K->(RECNO()))
		Next nBene
		RestArea(aAreaB3K)
		if !lAuto .AND. !lJob
			msgInfo("Validação concluída!")
		EndIf

	Else
		if !lAuto .AND. !lJob
			msgAlert("Selecione ao menos um beneficiário para validar","Atenção")
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnVldSipBn

Executa a rotina de validação de regras gerais do SIP para o beneficiario selecionada

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnVldSipBn(lAuto, aMark, lJob, cEmp, cFil)

	Local nBene
	local aAreaB3K

	Default	lAuto := .F.
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	aAreaB3K := B3K->(GetArea())

	If len(aMark) > 0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			B3K->(DBGOTO(aMark[nBene][2]))
			PLSIPVLBN(cEmpAnt,cFilAnt,nil,DTOS(dDataBase),B3K->B3K_CODOPE,cEmpAnt,B3K->(RECNO()),"1",.F.)
		Next nBene
		RestArea(aAreaB3K)
		if !lAuto .AND. !lJob
			msgInfo("Validação concluída!")
		EndIf

	Else
		if !lAuto .AND. !lJob
			msgAlert("Selecione ao menos um beneficiário para validar","Atenção")
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkMark

Verifica os registros selecionados no MarkBrowse da B3K

@author p.drivas
@since 22/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function checkMark()
Return aMarkInd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBAddMov

Verifica se a inclusao de movimento SIB sera via JOB

@author p.drivas
@since 26/10/2020
/*/
//--------------------------------------------------------------------------------------------------

function SIBAddMov(cOpe)
	local lJob  := .F.
	Local aMark := checkMark()
	if msgyesno("Deseja processar o(s) movimentos(s) em segundo plano?")
		msgAlert("Caso sejam encontrados erros em uma ou mais movimentação, será gerado um arquivo de nome log_erros_movimentacoes na pasta \sib do servidor. ")
		lJob := .T.
		startjob("PLSENVANS",getenvserver(),.F.,cOpe, aMark, lJob, cEmpAnt, cFilAnt)
	else
		Processa({|| PLSENVANS(cOpe, aMark)}, "Incluindo...")
	Endif
return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TypeVldBen

Verifica se a validação do beneficiário será via JOB

@author p.drivas
@since 27/10/2020
/*/
//--------------------------------------------------------------------------------------------------

function TypeVldBen(cType)
	local lJob  := .F.
	Local aMark := checkMark()
	if msgyesno("Deseja validar o(s) beneficiário(s) em segundo plano?")
		lJob := .T.
		If cType == 'SIB'
			startjob("CnVldSibBn",getenvserver(),.F.,.F., aMark, lJob, cEmpAnt, cFilAnt)
		ElseIf cType == 'SIP'
			startjob("CnVldSipBn",getenvserver(),.F.,, aMark, lJob, cEmpAnt, cFilAnt)
		EndIf
	else
		If cType == 'SIB'
			Processa({|| CnVldSibBn(.F., aMark)}, "Validando...")
		ElseIf cType == 'SIP'
			Processa({|| CnVldSipBn(, aMark)}, "Validando...")
		EndIf
	Endif
return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMrkAll
Função para execução do MarkAll da MarkBrowse

/*/
//-------------------------------------------------------------------
Static Function SetMrkAll(oMarkBrw as Object, oMsgRun as Object, lRotAut as Logical)

	Local nRegPos := B3K->(Recno())
	Local nTotReg := 0

	Default oMarkBrw := Nil
	Default oMsgRun  := Nil
	Default lRotAut  := .F.

	/*variavel utilizada para identificar se todas as linhas foram selecionadas ou desmarcadas, com isso irá permitir realizar a 
	marcação ou desmarcação de linhas que foram selecionadas ou desmarcadas isoladamente antes de clicar na coluna 
	para selecionar ou desmarca todas as linhas*/
	If !lTotSelec 
		lTotSelec := .T.
	Else
		lTotSelec := .F.
	EndIf 

	B3K->(dbGotop())

	While !B3K->(Eof())

		nTotReg++
		
		If lTotSelec 

			If !oMarkBrw:IsMark(oMarkBrw:Mark())
				oMarkBrw:MarkRec()
			EndIf
		Else
			If oMarkBrw:IsMark(oMarkBrw:Mark())
				oMarkBrw:MarkRec()
			EndIf
		EndIf

		If !lRotAut
			oMsgRun:SetText("Até o momento " + cValToChar(nTotReg) + " linhas foram afetadas, aguarde...")
			ProcessMessages()
		EndIf

		B3K->(dbSkip())
	Enddo

	B3K->(dbGoto(nRegPos))
	oMarkBrw:Refresh()
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinalMrk

Desmarca todos os registros marcados no MarkBrowse da tabela B3K 

/*/
//--------------------------------------------------------------------------------------------------
Static Function	FinalMrk(oMarkB3K as Object, lRtAuto as Logical, oMensRun as Object)
	
	Local nRegDesmarc := 0

	Default oMarkB3K := Nil
	Default oMensRun := Nil
	Default lRtAuto  := .F.

	If oMarkB3K:Mark() <> nil
		// Desmarca tudo que foi marcado. Devido ao controle de semaforo do FWMarkBrowse não podemos usar
		// O update direto no banco.
		cSql := " Select R_E_C_N_O_ RECNO FROM "+RetSqlName("B3K")
		cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
		cSql += " AND B3K_MARK     = '" + oMarkB3K:Mark() + "' "
		cSql += " AND D_E_L_E_T_   = ' '"
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB3K1",.F.,.T.)
		
		While !TRBB3K1->( Eof() )
			B3K->( dbGoto(TRBB3K1->RECNO) )

			// Desmarca
			oMarkB3K:MarkRec()

			If !lRtAuto
				
				nRegDesmarc++
				oMensRun:SetText("Desmarcando " + cValToChar(nRegDesmarc) + " linhas, aguarde...")
				ProcessMessages()
			EndIf

			TRBB3K1->( dbSkip() )
		Enddo

		TRBB3K1->( dbCloseArea() )
	Endif
Return

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelLinha

Armazena no array utilizado para realizar os processamentos do sib e sip 
o recno de todas as linhas selecionadas ou exclui o recno caso a linha seja desmarcada 

/*/
//-------------------------------------------------------------------------------------------
Static Function SelLinha(oMrkBrw as Object, lAutma)

	Local nScanB3K := 0
	
	Default oMrkBrw  := Nil
	Default lAutma   := .F.

	If lAutma .AND. oMrkBrw == Nil .OR. ;
	  !lAutma .AND. oMrkBrw:IsMark(oMrkBrw:Mark())  

		aAdd(aMarkInd,{B3K->B3K_MATRIC,B3K->(Recno())})
	Else
		nScanB3K := Ascan(aMarkInd,{ |x| x[2] == B3K->(Recno())})

		//deleta o registro desmarcado
		If nScanB3K > 0
			
			//Deleta os dados da posicao
			ADEL(aMarkInd, nScanB3K)

			//Deleta a posição do array que ficou vazio apos o ADEL
			ASIZE(aMarkInd, LEN(aMarkInd) - 1)
		EndIf
	EndIf
Return aMarkInd

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inconsistencia

Caso o registro do bloqueio nao possua ID, e possuir mais de um bloqueio com a mesma data
o sistema ira exibir um aviso informando que existem registros de bloqueio com a mesma data

@cMatfam, Caracter,	Matricula da familia
@cTipReg, Caracter,	Tipo de registro
@cIdBCA , Caracter,	ID do BCA
@cDatBlq, Caracter,	Nova data de bloqueio

@return lIncon, .F. nao possui inconsistencia ou .T. possui inconsistencia
/*/
//-------------------------------------------------------------------------------------------
Static Function Inconsistencia(cMatfam, cTipReg, cIdBCA, cDatBlq)
	
	Local nOpcAviso := 0
	Local nQtdReg   := 0
	Local cQuery    := ""  
	Local lIncon    := .F.
	
	Default cMatfam := ""
	Default cTipReg := ""
	Default cIdBCA  := ""
	Default cDatBlq := ""
	
	cQuery := "SELECT COUNT(BCA_ID) CNT_ID FROM " +  RetSqlName("BCA") 
	cQuery += "		WHERE "
	cQuery += "		BCA_FILIAL = '" + xFilial("BCA") + "' AND "
	cQuery += "		BCA_MATRIC = ?   					  AND "
	cQuery += "		BCA_TIPREG = ?   					  AND "
	cQuery += "		BCA_ID     = ?   					  AND "
	cQuery += "		BCA_DATA   = ?   					  AND "
	cQuery += "		BCA_TIPO   = '0' 					  AND "
	cQuery += "		D_E_L_E_T_ = ' ' "

	nQtdReg := MPSysExecScalar(cQuery,'CNT_ID',{cMatfam, cTipReg, cIdBCA, cDatBlq})

	//se possuir mais de um registro com o mesmo id e data, significa que o campo BCA_ID esta sem codigo
	//e o sistema ira exibir um aviso informando que existem registros de bloqueio com a mesma data
	//e que se faz necessario a inclusao de um codigo no campo BCA_ID manualmente para nao causar
	//inconsistencia no sistema
	If nQtdReg > 1
		
		lIncon := .T.
		nOpcAviso := Aviso( "Entre em Contato Com o Administrador do Sistema",;
							"Foi identificado mais de um registro de bloqueio com a data de bloqueio anterior. No entanto, este registro "+;
							"específico não possui o campo BCA_ID preenchido. Como resultado, o sistema irá alterar automaticamente o primeiro "+;
							"registro de bloqueio encontrado com a data anterior." + CHR(13)+CHR(10)+CHR(13)+CHR(10) +;
							"Para evitar esse problema:" + CHR(13)+CHR(10) +;
							"Entre em contato com o administrador e solicite a inclusão manual de uma chave no campo BCA_ID correspondente a este "+;
							"bloqueio. Essa chave deve ser replicada em todos os registros " +;
							"relacionados nas tabelas BC3, B3X e B4W." + CHR(13)+CHR(10)+CHR(13)+CHR(10) +;
							"Para auxiliar no entendimento da rotina e na correção:" + CHR(13)+CHR(10) +;
							"1. Clique no botão de documentação." + CHR(13)+CHR(10) +;
							"2. Copie o link exibido no navegador." + CHR(13)+CHR(10) +;
							"3. Encaminhe-o ao administrador para referência.",;
							{"OK", "Documentação"},;
							3,,,"BR_AZUL";
					  	  )

		If nOpcAviso == 2 //Exibe documentacao

			ShellExecute("Open", "https://tdn.totvs.com/pages/releaseview.action?pageId=910665757", "", "", 1)
		EndIf
	EndIf
Return lIncon
