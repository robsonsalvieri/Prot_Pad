#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA994.CH' 
#INCLUDE "FWEditPanel.CH"

Static lFA944QRY := nil
Static lFA944ARR := nil
Static lRlOrigem := nil 
Static aTamValor := nil
Static lAvisoFOD := .F.
Static __lDicNw := nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA994
Cadastro de socios da sociedade em conta de participação SCP e seus lucros/dividendos mensais

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function FINA994()

	Local oBrowse as Object 

	If AliasInDic("FOD") .AND. cPaisLoc == "BRA"

		//Novo campo de CNPJ da filial SCP
		If __lDicNw == NIL
			__lDicNw := FOD->(ColumnPos("FOD_CGCSCP")) > 0
		Endif

		DbSelectArea("FOD")
		If ColumnPos("FOD_FILCEN") > 0
			DbSelectArea("FOE")
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias('FOD')
			oBrowse:SetDescription(STR0001)//'Cadastro de sócio SCP e dos lucros/dividendos' 

			oBrowse:Activate()
		Else
			MsgStop( STR0013 + " " + STR0015 )	//Campo FOD_FILCEN não existe. / "Necessário rodar o UPDDISTR!"
		EndIf	
	Else
		MsgStop( STR0026 + cPaisLoc + STR0027 ) //"O Ambiente Protheus está configurado para o País " + cPaisLoc + ". Esta rotina não pode ser utilizada, porque é especifica para o Brasil."
	EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina as Array 

	aRotina := {}

	ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.FINA994' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FINA994' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.FINA994' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.FINA994' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruFOD 	as Object 
	Local oStruFOE 	as Object 
	Local oModel 	as Object 


	oStruFOD 	:= FWFormStruct( 1, 'FOD', /*bAvalCampo*/, /*lViewUsado*/ )
	oStruFOE 	:= FWFormStruct( 1, 'FOE', /*bAvalCampo*/, /*lViewUsado*/ )
	oModel 		:= NIL

	oStruFOD:SetProperty('FOD_FILSCP', MODEL_FIELD_VALID, {|| F994FILSOC("FOD_FILSCP") })
	oStruFOD:SetProperty('FOD_FILSOC', MODEL_FIELD_VALID, {|| F994FILSOC("FOD_FILSOC") })
	oStruFOD:SetProperty('FOD_FILCEN', MODEL_FIELD_VALID, {|| F994FILSOC("FOD_FILCEN") }) 
	oStruFOD:SetProperty('FOD_FILCEN', MODEL_FIELD_WHEN , {|| f994WHEN() })
	oStruFOD:SetProperty('FOD_CGCCPF', MODEL_FIELD_OBRIGAT, .T.)

	If __lDicNw
		oStruFOD:SetProperty( 'FOD_CGCSCP', MODEL_FIELD_OBRIGAT, .T.)
	Endif

	oStruFOD:AddField(			  ;
	STR0023					, ;	// [01] Titulo do campo		//"Descrição Filial Centralizadora"
	STR0023					, ;	// [02] ToolTip do campo 	//"Descrição Filial Centralizadora"
	"FOD_FILNOM"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	60						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SM0',1,cEmpAnt+FOD->FOD_FILCEN,'M0_NOMECOM'),'')") ,,,;// [11] Inicializador Padrão do campo
	.T.)						// [14] Virtual

	If __lDicNw
		oStruFOD:AddField(			  ;
		STR0023					, ;	// [01] Titulo do campo		//"Descrição Filial Centralizadora"
		STR0023					, ;	// [02] ToolTip do campo 	//"Descrição Filial Centralizadora"
		"FOD_NOMSCP"			, ;	// [03] Id do Field
		"C"						, ;	// [04] Tipo do campo
		60						, ;	// [05] Tamanho do campo
		0						, ;	// [06] Decimal do campo
		{ || .T. }				, ;	// [07] Code-block de validação do campo
		{ || .F. }				, ;	// [08] Code-block de validação When do campo
								, ;	// [09] Lista de valores permitido do campo
		.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SM0',1,cEmpAnt+FOD->FOD_FILSCP,'M0_NOMECOM'),'')") ,,,;// [11] Inicializador Padrão do campo
		.T.)						// [14] Virtual
	Endif

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'FINA994', /*bPreValidacao*/, {|| F994TIPOP() } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'FODMASTER', /*cOwner*/, oStruFOD )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'FOEDETAIL', 'FODMASTER', oStruFOE, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:SetPrimaryKey({'FOD_FILIAL','FOD_FILCEN','FOD_FILSCP','FOD_FILSOC'})

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'FOEDETAIL', { { 'FOE_FILIAL', 'xFilial( "FOE" )' }, { 'FOE_FILCEN', 'FOD_FILCEN' },{ 'FOE_FILSCP', 'FOD_FILSCP' }, { 'FOE_FILSOC', 'FOD_FILSOC' } }, FOE->( IndexKey( 1 ) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'FOEDETAIL' ):SetUniqueLine( {"FOE_MES","FOE_ANO"})

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'FOEDETAIL' ):SetOptional(.T.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0007 )//'Cadastro de Sócio(s) SCP'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'FODMASTER' ):SetDescription( STR0007 )
	oModel:GetModel( 'FOEDETAIL' ):SetDescription( STR0008  ) //'Lucro/Dividendos mensais'

	oModel:SetVldActivate( {|oModel| F994VldAct(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria a view

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oStruFOD 	as Object
	Local oStruFOE 	as Object
	// Cria a estrutura a ser usada na View
	Local oModel   	as Object
	Local oView		as Object

		
	oStruFOD := FWFormStruct( 2, 'FOD' , { |x| !ALLTRIM(x) $ "FOD_TIPOPE"} )
	oStruFOE := FWFormStruct( 2, 'FOE' )
	oModel   := FWLoadModel( 'FINA994' )

	//Ordena os campos na tela superior
	oStruFOD:SetProperty( 'FOD_FILCEN' , MVC_VIEW_ORDEM, '02' )
	
	oStruFOD:SetProperty( 'FOD_FILSCP' , MVC_VIEW_ORDEM, '04' )

	oStruFOD:SetProperty( 'FOD_FILSOC' , MVC_VIEW_ORDEM, '07' )
	oStruFOD:SetProperty( 'FOD_NOME'   , MVC_VIEW_ORDEM, '08' )
	oStruFOD:SetProperty( 'FOD_CGCCPF' , MVC_VIEW_ORDEM, '09' )
	oStruFOD:SetProperty( 'FOD_PERCEN' , MVC_VIEW_ORDEM, '11' )

	oStruFOD:SetProperty( 'FOD_FILCEN'	, MVC_VIEW_TITULO    , STR0016 )	//"Filial centralizadora da S.C.P."
	oStruFOD:SetProperty( 'FOD_FILSCP'	, MVC_VIEW_TITULO    , STR0017 )	//"Filial da S.C.P."
	oStruFOD:SetProperty( 'FOD_FILSOC'	, MVC_VIEW_TITULO    , STR0018 )	//"Filial do Sócio"
	oStruFOD:SetProperty( 'FOD_NOME'	, MVC_VIEW_TITULO    , STR0019 )	//"Descrição da Filial do Sócio"
	oStruFOD:SetProperty( 'FOD_CGCCPF'	, MVC_VIEW_TITULO    , STR0020 )	//"CNPJ da Filial Sócio"

	If __lDicNw	//Novos campos de SCP para atender o REINF 2.1.1
		oStruFOD:SetProperty( 'FOD_CGCSCP'  , MVC_VIEW_ORDEM, '10' )
		oStruFOD:SetProperty( 'FOD_CGCSCP'	, MVC_VIEW_TITULO    , STR0021 )	//"CNPJ da Filial S.C.P."
		oStruFOD:SetProperty( 'FOD_CGCSCP', MVC_VIEW_PICT   , '@!R NN.NNN.NNN/NNNN-99' )
		oStruFOD:SetProperty( 'FOD_CGCSCP', MVC_VIEW_PICTVAR, "F994PcCgc('FOD_CGCSCP')" )
		oStruFOD:AddField("FOD_NOMSCP" , "05", STR0022, STR0022 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/)//"Descrição Filial Centralizadora"
	EndIf

	oStruFOD:AddField("FOD_FILNOM" , "03", STR0023, STR0023 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/)//"Descrição Filial Centralizadora"

	oStruFOD:SetProperty( 'FOD_CGCCPF', MVC_VIEW_PICT   , '@!R NN.NNN.NNN/NNNN-99' )
	oStruFOD:SetProperty( 'FOD_CGCCPF', MVC_VIEW_PICTVAR, "F994PcCgc('FOD_CGCCPF')" )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FOD', oStruFOD, 'FODMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_FOE', oStruFOE, 'FOEDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_FOD', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_FOE', 'INFERIOR' )

	//Aqui é a definição de exibir dois campos por linha
	oView:SetViewProperty( "VIEW_FOD", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	oView:EnableTitleView('VIEW_FOE',STR0008)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F994TIPOP
preenche o campo tipo pessoa

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function F994TIPOP() 

	Local oModel      	as Object
	Local oModelFOD 	as Object
	
	oModel      := FWModelActive()
	oModelFOD 	:= oModel:GetModel( "FODMASTER" )

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If 	Len(Alltrim(oModelFOD:GetValue("FOD_CGCCPF"))) < 14
			oModelFOD:SetValue("FOD_TIPOPE","F")
		Else
			oModelFOD:SetValue("FOD_TIPOPE","J")
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F994ValMes
Valid do campo FOE_MES

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994ValMes()    

	Local lRet as Logical

	lRet := .T.

	If !PERTENCE("01,02,03,04,05,06,07,08,09,10,11,12")
		Help( ,,"FOE_MESVAL",,STR0009, 1, 0 ) //"Mês Inválido! Informe um mês entre 01 a 12!(Formato MM)"
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F994ValAno
Valid do campo FOE_ANO

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994ValAno()

	Local oModel    as Object
	Local oModelFOE as Object                                                                                                             
	Local lRet 		as Logical

	oModel    	:= FWModelActive()
	oModelFOE 	:= oModel:GetModel( "FOEDETAIL" )                                                                                                               
	lRet 		:= .T.

	If	Len(Alltrim(oModelFOE:GetValue("FOE_ANO"))) != 4
		lRet := .F.
		Help( ,,"FOE_ANOVAL",,STR0010, 1, 0 )//"Ano inválido! Informe o ano no formato AAAA."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F994FILSOC
Valid do campo FOD_FILSOC, FOD_FILSCP, FOD_FILCEN

@param cCampo = Campo de filial que está sendo validado

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function F994FILSOC(cCampo)

	Local oModel	as Object
	Local oModelFOD as Object
	Local lRet 		as Logical
	Local cSocio	as Char
	Local cCentral	as Char
	Local cFilSCP	as Char

	oModel		:= FWModelActive()
	oModelFOD 	:= oModel:GetModel( "FODMASTER" )
	lRet 		:= .T.
	cSocio		:= oModelFOD:GetValue("FOD_FILSOC")
	cCentral	:= oModelFOD:GetValue("FOD_FILCEN")
	cFilSCP		:= oModelFOD:GetValue("FOD_FILSCP")


	FOD->(dbSetOrder(1))
	If FOD->(MsSeek(xFilial("FOD") + cCentral+cFilSCP+cSocio))
		oModel:SetErrorMessage('FODMASTER', , 'FILIAIS SCP', , , STR0024, STR0025, , )//"Já existe um cadastro com mesmas Filiais Centralizadora, SCP e do Socio."###"Por favor, verifique a combinação Filial Centralizadora, Filial SCP e Filial do Sócio."
		lRet := .F.
	EndIf
	If lRet .and. !Empty(cCentral) .and. !ExistCpo("SM0",cEmpAnt+cCentral)
		lRet := .F. 
	EndIf
	If lRet .and. !Empty(cFilSCP) .and. !ExistCpo("SM0",cEmpAnt+cFilSCP)
		lRet := .F. 
	EndIf
	If lRet .and. !Empty(cSocio) .and. !ExistCpo("SM0",cEmpAnt+cSocio)
		lRet := .F. 
	EndIf

	If lRet .and. !Empty(cCampo)

		//Valida filial centralizadora do SCP
		If lRet .and. !Empty(cCentral) .and. cCampo == "FOD_FILCEN"
			dbSelectArea( 'SM0' )
			If SM0->(dbSeek(cEmpAnt + cCentral))
				If !Empty(SM0->M0_NOMECOM)
					oModelFOD:LoadValue("FOD_FILNOM",SM0->M0_NOMECOM)
				EndIf
			EndIf
		EndIf

		//Valida filial centralizadora do Sócio
		If lRet .and. !Empty(cSocio) .and. cCampo == "FOD_FILSOC"
			dbSelectArea( 'SM0' )
			If SM0->(dbSeek(cEmpAnt + cSocio))
				If !Empty(SM0->M0_NOMECOM)
					oModelFOD:LoadValue("FOD_NOME",SM0->M0_NOMECOM)
				EndIf
				If !Empty(SM0->M0_CGC)	
					oModelFOD:LoadValue("FOD_CGCCPF",SM0->M0_CGC)
				EndIf	
			EndIf
		EndIf

		//Valida filial centralizadora do SCP
		If lRet .and. !Empty(cFilSCP) .and. __lDicNw .and. cCampo == "FOD_FILSCP"
			If SM0->(dbSeek(cEmpAnt + cFilSCP))
				If !Empty(SM0->M0_NOMECOM)
					oModelFOD:LoadValue("FOD_NOMSCP",SM0->M0_NOMECOM)
				EndIf
				If !Empty(SM0->M0_CGC)	
					oModelFOD:LoadValue("FOD_CGCSCP",SM0->M0_CGC)
				EndIf
			EndIf
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f994WHEN
WHEN do campo  FOD_FILCEN

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
                   
Static function f994WHEN()

	Local oModel    as Object
	Local lRet  	as Logical

	oModel  := FWModelActive()
	lRet  	:= .F.

	If Empty(FOD->FOD_FILCEN) .or. oModel:GetOperation() == MODEL_OPERATION_INSERT
		lRet := .T.
	EndIf

Return lRet
                   
//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994DIRF()
Retorna array com as informações cadastradas do socio

@param cAno,caracter, informa qual ano deve ser retornado

@return aSCP, array, array multidimensional contendo a filial SCP e seus socios e seus lucros/dividendos

array[1] - array socio ostensivo
array[1][1] - Filial socio ostensivo
array[1][2] - Nome socio ostensivo
array[1][3] - CNPJ socio ostensivo
array[1][4] - array sócios da sCP 
array[1][4][1] - array informacoes sócios da sCP
array[1][4][1][1] - Filial socio da SCP
array[1][4][1][2] - Tipo Pessoa F ou J
array[1][4][1][3] - Nome do socio
array[1][4][1][4] - CPF ou CGC do socio
array[1][4][1][5] - Percentual de participacao
array[1][4][1][6] - array com os valores mensais
array[1][4][1][6][1][1] - Mes
array[1][4][1][6][1][2] - Ano
array[1][4][1][6][1][3] - Valor

array[1][4][1][6][2][1] - Mes
array[1][4][1][6][2][2] - Ano
array[1][4][1][6][2][3] - Valor

array[1][4][2] - array informacoes do segundo socio da sCP
array[1][4][2][1] - Filial socio da SCP
array[1][4][2][2] - Tipo Pessoa F ou J
array[1][4][2][3] - Nome do socio
array[1][4][2][4] - CPF ou CGC do socio
array[1][4][2][5] - Percentual de participacao
array[1][4][2][6] - array com os valores mensais
array[1][4][2][6][1][1] - Mes
array[1][4][2][6][1][2] - Ano
array[1][4][2][6][1][3] - Valor

array[1][4][2][6][2][1] - Mes
array[1][4][2][6][2][2] - Ano
array[1][4][2][6][2][3] - Valor

array[2] - array o segundo socio ostensivo
array[2][1] - Filial socio ostensivo
array[2][2] - Nome socio ostensivo
array[2][3] - CNPJ socio ostensivo
array[2][4] - array sócios da sCP 
array[2][4][1] - array informacoes sócios da sCP

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------

Function F994DIRF(cAno,cFilCen)
Local aSCP := {}
Local cQuery := "" 
Local cAliasQry := GetNextAlias()
Local aTamPercen := TamSX3("FOD_PERCEN")
Local aTamValor := TamSX3("FOE_VALOR")
Local cFilScpAnt := ""
Local cFilSocAnt := ""
Local aSocio := {}
Local aMeses := {}
Local lSkip := .F. 
Local cNome := ""
Local cCNPJ := ""
Local aRetARR := {}
Local aAreaAnt := GetArea()

If !AliasInDic("FOD")
	Return aClone(aSCP)
EndIf

DbSelectArea("FOD")

If ColumnPos("FOD_FILCEN") == 0 
	If !lAvisoFOD
		MsgStop(STR0013+" "+STR0015)
	EndIf	
	lAvisoFOD := .T.
	Return aClone(aSCP)
EndIf

DbSelectArea("FOE")
If lFA944QRY == nil
	lFA944QRY := ExistBlock("FA944QRY")
EndIf	
If lFA944ARR == nil
	lFA944ARR := ExistBlock("FA944ARR")
EndIf

#IFDEF TOP
	cQuery := "SELECT FOD.FOD_FILSCP, FOD.FOD_FILSOC, FOD.FOD_NOME, FOD.FOD_CGCCPF, FOD.FOD_PERCEN ,"
	cQuery += "FOD.FOD_TIPOPE, FOE.FOE_MES,FOE.FOE_ANO, FOE.FOE_VALOR "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD LEFT JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOD.FOD_FILCEN = FOE.FOE_FILCEN "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' " 
	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_FILCEN = '" + cFilCen + "' "
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FOD.FOD_FILSCP, FOD.FOD_TIPOPE, FOD.FOD_CGCCPF, FOE.FOE_MES " 

	If lFA944QRY
		cQuery := ExecBlock("FA944QRY",.F.,.F.,{cQuery, cAno})
		cQuery := ChangeQuery(cQuery)
	EndIf	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
		
	TCSetField(cAliasQry, "FOD_PERCEN", "N", aTamPercen[1] ,aTamPercen[2])
	TCSetField(cAliasQry, "FOE_VALOR", "N", aTamValor[1] ,aTamValor[2])	
	
	If Select('SM0') == 0
		OpenSM0()
	EndIf
	dbSelectArea( 'SM0' )
	
	While (cAliasQry)->(!Eof())
		If cFilScpAnt != (cAliasQry)->FOD_FILSCP
			If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSCP ))
				cNome := SM0->M0_NOMECOM
				cCNPJ := SM0->M0_CGC
			EndIf
			If Empty(cFilScpAnt)
				aAdd(aSCP,{ (cAliasQry)->FOD_FILSCP, cNome, cCNPJ })
			Else
				aAdd(aSCP[nLen], aClone(aSocio))
				aAdd(aSCP,{ (cAliasQry)->FOD_FILSCP, cNome, cCNPJ  })
			EndIf
			cFilScpAnt := (cAliasQry)->FOD_FILSCP
			cFilSocAnt := (cAliasQry)->FOD_FILSOC
			aSize(aSocio,0)
			aSocio := {}
			aSize(aMeses,0)
			aMeses := {}
		EndIf
			
		nLen := Len(aSCP)
		lSkip := .F. 
		aAdd(aSocio, {(cAliasQry)->FOD_FILSOC, (cAliasQry)->FOD_TIPOPE,(cAliasQry)->FOD_NOME, (cAliasQry)->FOD_CGCCPF, (cAliasQry)->FOD_PERCEN })
		aMeses := {}
		While (cAliasQry)->(!Eof()) .and. (cAliasQry)->FOD_FILSOC == cFilSocAnt
			If !Empty((cAliasQry)->FOE_MES )
				aAdd(aMeses, {(cAliasQry)->FOE_MES, (cAliasQry)->FOE_ANO, (cAliasQry)->FOE_VALOR} )
			EndIf	  
			lSkip := .T.
			(cAliasQry)->(DBSkip())
		EndDo
		
		If (cAliasQry)->FOD_FILSOC != cFilSocAnt .or. (cAliasQry)->(Eof())
			aAdd(aSocio[Len(aSocio)], aClone(aMeses) )
			cFilSocAnt := (cAliasQry)->FOD_FILSOC
			Loop
		EndIf
		If !lSkip
			aAdd(aSocio[Len(aSocio)], aClone(aMeses) )
			(cAliasQry)->(DBSkip())
		EndIf
		
	EndDo
	
	If Len(aSCP) > 0
		//adiciona o ultimo laco
		aAdd(aSCP[Len(aSCP)], aClone(aSocio))
	EndIf	
	
	(cAliasQry)->(DBCloseArea())
#ENDIF


aSize(aSocio,0)
aSocio := {}
aSize(aMeses,0)
aMeses := {}

If lFA944ARR
	aRetARR := ExecBlock("FA944ARR",.F.,.F.,aClone(aSCP))
	If ValType(aRetARR)== "A"
		aSCP := aClone(aRetARR)
	EndIf	
EndIf	

aSort(aSCP,,,{ |x,y| x[3] <  y[3] } )
RestArea(aAreaAnt)
Return aClone(aSCP)

//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994SRL()
Alimenta a SRL com os dados dos socios SCP

@cAno cAno,caracter, informa qual ano deve ser pesquisado

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------

Function F994SRL(cAno,cFilCen)
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local aAreaSRL := SRL->(GetArea())
Local cCodRet := "6910"
Local cRaMat := ""
Local cTipoFj := ""
Local cCGCMatriz := ""
Local cNomeMatriz := ""
Local nRegEmp	:= SM0->(Recno())
Local lF994CodD := Existblock("F994CodD")

Default cAno := Year(ddatabase)

#IFDEF TOP
	IF lRlOrigem == nil
		lRlOrigem := SRL->(FieldPos("RL_ORIGEM")) > 0
	EndIF

	dbSelectArea( 'SM0' )
	SM0->(MsSeek(cEmpAnt+cFilCen))
	cCGCMatriz := SM0->M0_CGC
	cNomeMatriz := SM0->M0_NOMECOM

	cQuery := "SELECT DISTINCT FOD.FOD_FILSOC, FOD.FOD_NOME, FOD.FOD_CGCCPF, FOD.FOD_PERCEN , FOD.FOD_TIPOPE "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD INNER JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOD.FOD_FILCEN = FOE.FOE_FILCEN "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' " 
	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_FILCEN = '" + cFilCen + "' "
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FOD.FOD_TIPOPE" 
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
	
	
	dbSelectArea("SRL")
	SRL->(dbSetOrder(2))
	
	While (cAliasQry)->(!Eof())
		If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSOC ))
			cTipoFj := If((cAliasQry)->FOD_TIPOPE == "F" , "1", "2")
			If lF994CodD
				cCodRet := ExecBlock("FA944QRY",.F.,.F.)
			EndIf
			If !SRL->(MsSeek(xFilial("SRL")+Padr(SM0->M0_CGC,Len(SRL->RL_CGCFONT))+ ;
					cCodRet +cTipoFj+ (cAliasQry)->FOD_CGCCPF  ))
	
				Reclock("SRL", .T.)
	
				cRaMat := GetSxENum( "SRL" , "RL_MAT")
	
				SRL->RL_FILIAL  := xFilial("SRL")
				SRL->RL_MAT     := If(Val(SRA->RA_MAT) < 900000 .And. Val(cRaMat) < 900000, "900000",cRaMat)
				SRL->RL_CODRET  := cCodRet
				SRL->RL_TIPOFJ  := cTipoFj
				SRL->RL_CPFCGC  := (cAliasQry)->FOD_CGCCPF
				SRL->RL_BENEFIC := (cAliasQry)->FOD_NOME
				SRL->RL_ENDBENE := Alltrim(SM0->M0_ENDCOB) 
				SRL->RL_UFBENEF := Alltrim(SM0->M0_ESTCOB) 
				SRL->RL_COMPLEM := Alltrim(SM0->M0_COMPCOB) 
				SRL->RL_CGCFONT := cCGCMatriz
				SRL->RL_NOMFONT := cNomeMatriz
	
				If lRlOrigem
					SRL->RL_ORIGEM := "2"
				Endif
	
				SRL->(MsUnlock())
			EndIf	
		EndIf
		(cAliasQry)->(DbSkip())	
	EndDo
	
	(cAliasQry)->(DBCloseArea())

#ENDIF

RestArea(aAreaSRL)
SM0->(dbGoTo(nRegEmp))
Return 


//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994Rend(cAno, cCGCCPF)
retorna o rendimento anual do socio

@cAno cAno,caracter, informa qual ano deve ser pesquisado
@cCGCCPF , caracter, informar o cpf/cgc do socio 

@return  array
Array[1][1]: Filial do Socio Ostensiva (pagador)
Array[1][2]: CNPJ do Socio Ostensiva
Array[1][3]: Valor repassado no ano

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994Rend(cAno,cCGCCPF)
Local aRet := {}
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local nRegEmp	:= SM0->(Recno())

#IFDEF TOP
	If aTamValor == nil
		aTamValor := TamSX3("FOE_VALOR")
	EndIf	
	cQuery := "SELECT FOD.FOD_FILSCP,FOD.FOD_FILSOC, SUM(FOE.FOE_VALOR) FOE_VALOR "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD INNER JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' "
 	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_CGCCPF = '" + cCGCCPF + "' "	
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY FOD.FOD_FILSCP,FOD.FOD_FILSOC" 
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
	
	TCSetField(cAliasQry, "FOE_VALOR", "N", aTamValor[1] ,aTamValor[2])	
	
	While (cAliasQry)->(!Eof())
		If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSCP ))
			aAdd(aRet,{(cAliasQry)->FOD_FILSCP, SM0->M0_CGC, Iif(Empty((cAliasQry)->FOE_VALOR), 0, (cAliasQry)->FOE_VALOR )  })
		EndIf
		(cAliasQry)->(DbSkip())
				
	EndDo
	
	(cAliasQry)->(DBCloseArea())
	
	SM0->(dbGoTo(nRegEmp))
#ENDIF		

Return aClone(aRet)	

//-------------------------------------------------------------------
/*/{Protheus.doc} F994PcCgc(cCampo)
Retorna a Picture variável para os campos de CNPJ/CPF

@param cCampo Campo o qual está sendo validado para obter a picture

@return  cRet - Picture para o campo

@author Pequim
@since 17/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function F994PcCgc(cCampo)

	Local oModel as Object
	Local cRet   as Char
	Local cCnpj  as Char

	DEFAULT cCampo := ""

	oModel := FWModelActive()
	cRet   := '@!R NN.NNN.NNN/NNNN-99'
	cCnpj  := ""	

	cCnpj := Alltrim(oModel:GetValue("FODMASTER", cCampo))

	cRet := PICPES(If(Len(cCnpj) > 11 , "J", "F"))

Return cRet

/*/{Protheus.doc} F994VldAct
	(long_description)
	@type  Function
	@author rafael.rondon
	@since 12/12/2019
	@version 12.1.27
	@param 
	@return lRet, Logical, 
	@see (links_or_references)
/*/
Function F994VldAct(oModel AS Object) As Logical

	Local lRet 			As Logical
	Local nOperation	As Numeric

	lRet := .T.
	nOperation := oModel:GetOperation()

	If nOperation <> 1 // Visualizar
		If GetHlpLGPD({'FOD_NOME', 'FOD_CGCCPF'})
			lRet := .F.
		EndIf
	EndIf	

Return lRet
