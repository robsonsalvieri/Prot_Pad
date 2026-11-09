#INCLUDE "AGDA040X.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA040X
Rotina para Cadastro de Solicitação de Receita
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
/*/
Function AGDA040X()
	Local oMBrowse := Nil

	If .Not. TableInDic('NET')
		MsgNextRel()
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NET" )
	oMBrowse:SetDescription( STR0001 ) //#"Solicitação de Receita"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Array, array com o menu da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA040X' OPERATION 2 ACCESS 0 //#"Visualizar"
	// ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA040X' OPERATION 3 ACCESS 0 //#"Incluir"
	// ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA040X' OPERATION 4 ACCESS 0 //#"Alterar"
	// ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA040X' OPERATION 5 ACCESS 0 //#"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStru		:= FwFormStruct( 1, "NET" )
	Local oStruNET  := FwFormStruct( 1, "NET" )
	Local oStruNEU	:= FwFormStruct( 1, "NEU" )
	//Local oEvent        := AGDA040EVT():New()

	//SETANDO INICILIZADOR PADRAO PARA EVITAR MESAGEM DE CAMPO NAO PREECHIDO
	oStruNET:SetProperty("NET_NUMPED"	, MODEL_FIELD_INIT 	, {| | M->NET_NUMPED 	})
	oStruNET:SetProperty("NET_CLIENT"	, MODEL_FIELD_INIT 	, {| | M->NET_CLIENT	})
	oStruNET:SetProperty("NET_LOJA"		, MODEL_FIELD_INIT 	, {| | M->NET_LOJA 		})

	oStruNEU:SetProperty( "NEU_CODIGO" 	, MODEL_FIELD_INIT 	, {| | M->NET_CODIGO } )

	oModel := MpFormModel():New( "AGDA040X")
	oModel:SetDescription( STR0001 ) //##"Solicitação de Receita"

	oStru:RemoveField( "NET_CODIGO" )

	oModel:AddFields("NETMASTER", , oStru)
	oModel:GetModel( "NETMASTER" ):SetDescription( STR0006 ) //#"Dados de Pedido"

	// Adiciona a field no modelo de dados
	oModel:AddGrid("AGDA040X_NET","NETMASTER",oStruNET,,,,,)
	oModel:GetModel( "AGDA040X_NET" ):SetDescription( STR0007 ) //#"Dados Solicitação de Receita"
	oModel:SetPrimaryKey( { "NET_FILIAL", "NET_NUMPED" } )

	oModel:AddGrid( "AGDA040X_NEU", "AGDA040X_NET", oStruNEU)
	oModel:GetModel( "AGDA040X_NEU" ):SetDescription( STR0008 ) //#"Itens Solicitação de Receita"

	If FWSIXUtil():ExistIndex( "NET" , "3" )  //DAGRODIST-3485-Pacote de dicionário não expedido da EC
		oModel:SetRelation( 'AGDA040X_NET', {{'NET_FILIAL', 'xFilial("NET")'},{ 'NET_CLIENT', 'NET_CLIENT' },{ 'NET_LOJA', 'NET_LOJA' },{ 'NET_NUMPED', 'NET_NUMPED' }}, NET->(IndexKey( 3 ) ) )
	Else
		oModel:SetRelation( 'AGDA040X_NET', {{'NET_FILIAL', 'xFilial("NET")'},{ 'NET_NUMPED', 'NET_NUMPED' },{ 'NET_CLIENT', 'NET_CLIENT' },{ 'NET_LOJA', 'NET_LOJA' }}, NET->(IndexKey( 1 ) ) )
	EndIf

	oModel:SetRelation( 'AGDA040X_NEU', {{'NEU_FILIAL', 'xFilial("NEU")'},{ 'NEU_CODIGO', 'NET_CODIGO' },{ 'NEU_NUMPED', 'NET_NUMPED' }}, NEU->(IndexKey( 4 ) ) )

	oModel:GetModel( "AGDA040X_NEU" ):SetUniqueLine( { 'NEU_ITEM' } )
	oModel:GetModel( "AGDA040X_NEU" ):SetOptional( .F. )
	oModel:GetModel('AGDA040X_NEU'):SetUseOldGrid(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da visualização dos dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Object, Objeto de dados da View
/*/
Static Function ViewDef()

	Local oModel	:= FwLoadModel( "AGDA040X" )
	Local oStru   	:= FWFormStruct( 2, "NET")
	Local oStruNET  := FwFormStruct( 2, "NET" )
	Local oStruNEU  := FwFormStruct( 2, "NEU")
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField("VIEW_NET", oStru, "NETMASTER")

	oView:AddGrid( 'GRID_NET', oStruNET, 'AGDA040X_NET' )
	oView:AddGrid( 'GRID_NEU', oStruNEU, 'AGDA040X_NEU' )
	oView:AddIncrementField( 'GRID_NEU', 'NEU_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 20 )
	oView:CreateHorizontalBox( 'GRIDNET', 40 )
	oView:CreateHorizontalBox( 'GRIDNEU', 40 )

	oView:SetOwnerView( 'VIEW_NET', 'CABEC' )
	oView:SetOwnerView( 'GRID_NET', 'GRIDNET' )
	oView:SetOwnerView( 'GRID_NEU', 'GRIDNEU' )

	oView:EnableTitleView("VIEW_NET")
	oView:EnableTitleView("GRID_NET")
	oView:EnableTitleView("GRID_NEU")


	oStru:RemoveField( "NET_CODIGO" )
	oStru:RemoveField( "NET_NUMREC" )
	oStru:RemoveField( "NET_URL" )
	oStru:RemoveField( "NET_DTEMIS" )
	oStru:RemoveField( "NET_HREMIS" )
	oStru:RemoveField( "NET_OBS" )
	oStru:RemoveField( "NET_EMISSA" )
	oStru:RemoveField( "NET_CULTRA" )
	oStru:RemoveField( "NET_STSSOL" )
	oStru:RemoveField( "NET_STSREC" )
	oStru:RemoveField( "NET_CODENG" )
	oStru:RemoveField( "NET_LOCDES" )


	oStruNET:RemoveField( "NET_CLIENT" )
	oStruNET:RemoveField( "NET_LOJA" )
	oStruNET:RemoveField( "NET_NUMPED" )

	oStruNEU:RemoveField( "NEU_CODREC" )
	oStruNEU:RemoveField( "NEU_SEQREC" )

	oView:AddUserButton(STR0009,"",{ |oView | fPreview(oView) },,, {MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT}) //"Visualizar Receita"

	oView:SetCloseOnOk({||.T.})
Return oView

/*/{Protheus.doc} fPreview
Função responsavel por realizar o preview do PDF da receita
@type function
@version 12
@author lindembergson.pacheco
@since 28/01/2026
@param oView, object, View
/*/
Static Function fPreview(oView)
	Local aArea      := FwGetArea()
	Local oModel     := oView:getModel()
	Local oGridNET   := oModel:GetModel("AGDA040X_NET")
	Local cURL    := ""

	DBSelectArea("NEU")
	NEU->(DBSetOrder(1))
	IF NEU->(DBSeek(FWxFilial("NEU") + oGridNET:GetValue("NET_CODIGO"))) .and. !Empty(NEU->NEU_CODREC)
		cURL :=  POSICIONE("NE6",1, FWXFILIAL("NE6")+NEU->NEU_CODREC, "NE6_URLREC")
	EndIf

	IF !Empty(cURL)
		ShellExecute("open",AllTrim(cURL),"","",5)
	ELSE
		AGDHELP(STR0010, STR0011) //"ATENÇÃO" //"Para exibição do Receituario Agronômico, é necessário que o registro esteja com o Status da Receita como Emitida. Favor Verificar!"
	ENDIF

	FWrestArea(aArea)
return


/*/{Protheus.doc} AGD40XINIT
Inicializa campos da NET com dados da Receita vinculada, caso tenha na solicitação
@type function
@version 12
@author carlos.augusto
@since 23/02/2026
/*/
Function AGD40XINIT()
	Local cReadVar   := ReadVar()
	Local cValor     := ""
	Local oState     := Nil
	Local aFieldsNET := {"NET_DOC", "NET_SERIE", "NET_NUMREC", "NET_DTEMIS", "NET_HREMIS", "NET_OBS", "NET_URL"}
	Local aFieldsNE6 := {"NE6_DOC", "NE6_SERIE", "NE6_NUMREC", "NE6_DTEMIS", "NE6_HREMIS", "NE6_OBS", "NE6_URLREC"}
	Local nPosNE6    := 1
	Local cQuery     := ""
	Local cAliasNE6  := ""

	If NET->NET_STSREC = '1'
		nPosNE6 := aScan(aFieldsNET,{|x| AllTrim(x) $ cReadVar})

		cQuery := "SELECT NE6." + aFieldsNE6[nPosNE6]
		cQuery += 	" FROM " + RetSqlname("NE6") + " NE6 "
		cQuery += 		" INNER JOIN " + RetSqlname("NEU") + " NEU"
		cQuery +=  			" ON (NEU.NEU_FILIAL = ? "
		cQuery += 				" AND NEU.NEU_CODIGO = ? "
		cQuery += 				" AND NEU.NEU_CODREC = NE6.NE6_CODREC "
		cQuery += 				" AND NEU.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE NE6.NE6_FILIAL = ? "
		cQuery += 	" AND NE6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )
		oState := FWPreparedStatement():New()
		oState:SetQuery(cQuery)
		oState:SetString(1, FWxFilial('NEU'))
		oState:SetString(2, NET->NET_CODIGO)
		oState:SetString(3,FWxFilial('NE6'))
		cQuery := oState:GetFixQuery()
		cAliasNE6 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNE6,.T.,.T.)
		If (cAliasNE6)->(!Eof())
			cValor := &("(cAliasNE6)->" + aFieldsNE6[nPosNE6])
			If aFieldsNE6[nPosNE6] = "NE6_DTEMIS"
				cValor := STOD(cValor)
			EndIf
		EndIf
		(cAliasNE6)->(DBCloseArea())
	EndIf

Return cValor

