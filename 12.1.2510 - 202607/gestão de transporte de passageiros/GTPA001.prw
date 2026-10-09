#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA001.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA001()
Cadastro de Localidades
 
@sample	GTPA001()
 
@return	oBrowse	Retorna o Cadastro de Localidades
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA001()

Local oBrowse		:= Nil	

Private aRotina 	:= {}

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
	
	aRotina 	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('GI1')
	oBrowse:SetDescription(STR0001)	//Cadastro de Localidades
	oBrowse:Activate()

EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel     := MPFormModel():New('GTPA001', , {|oModel|TP001TdOK(oModel)}, ,)
	Local oStruGI1   := FWFormStruct(1, 'GI1' )
	Local lCmpUrbano := GI1->( ColumnPos( 'GI1_STATUS' ) ) > 0

	//Muda propriedade dos campos, para fretamento urbano
	If lCmpUrbano .Or. FwIsInCallStack("GTPIRJ001")
		oStruGI1:SetProperty( '*' , MODEL_FIELD_WHEN, {||.T.})
		oStruGI1:SetProperty( 'GI1_CODTIP', MODEL_FIELD_OBRIGAT, .F. )
		oStruGI1:SetProperty("GI1_UF", MODEL_FIELD_NOUPD, .F.)	
		oStruGI1:SetProperty("GI1_CDMUNI", MODEL_FIELD_NOUPD, .F.)	
		oStruGI1:SetProperty("GI1_PAIS", MODEL_FIELD_NOUPD, .F.)
	EndIf

	oModel:AddFields('GI1MASTER',,oStruGI1)
	oModel:SetDescription(STR0001)
	oModel:GetModel('GI1MASTER'):SetDescription(STR0002)//Dados da Localidade
	oModel:SetPrimaryKey({"GI1_FILIAL","GI1_COD"})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( "GTPA001" )
	Local oView      := FWFormView():New()
	Local oStruGI1   := FWFormStruct(2, 'GI1' )
	Local lCmpUrbano := GI1->( ColumnPos( 'GI1_STATUS' ) ) > 0

	// Remove os campos criados para o fretamento Urbano
	If lCmpUrbano 
		oStruGI1:RemoveField("GI1_STATUS")
		oStruGI1:RemoveField("GI1_CEP")
		oStruGI1:RemoveField("GI1_ENDERE")
		oStruGI1:RemoveField("GI1_BAIRRO")
		oStruGI1:RemoveField("GI1_TPLOC")
	EndIf

	oView:SetModel(oModel)
	oView:SetDescription(STR0001)
	oView:AddField( 'VIEW_GI1' ,oStruGI1, 'GI1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100)
	oView:SetOwnerView( 'VIEW_GI1' , 'TELA' )

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA001' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA001' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA001' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA001' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função responsável por acionar a integração via mensagem única do cadastro de Localidades.

Nome da mensagem: Locality
Fonte da Mensagem: GTPI001 

@sample	IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )
 
@param		cXml			Texto da mensagem no formato XML.
@param		nTypeTrans		Código do tipo de transação que está sendo executada.
@param		cTypeMessage	Código com o tipo de Mensagem. (DELETE ou UPSERT)
@param		cVersionRec	Versão da mensagem.

@return	aRet  			Array contendo as informações dos parâmetros para o Adapter.
 
@author	Danilo Dias
@since		16/02/2016
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )

	Local aRet := {}

	aRet :=  GTPI001( cXML, nTypeTrans, cTypeMessage, cVersionRec )

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP001TdOK()
Definição do Menu
 
@sample	TP001TdOK()
 
@return	lRet - verifica se validação está ok
 
@author	Inovação
@since		11/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP001TdOK(oModel)
	Local aArea     := GetArea()
	Local lRet	    := .T.
	Local oMdlGI1   := oModel:GetModel('GI1MASTER')
	Local cStatus   := oMdlGI1:getValue("GI1_STATUS")
	Local cCodigo   := oMdlGI1:getValue("GI1_COD")
	Local cQuery    := ""
	Local cAlias    := ""
	Local cMsgError := ""

	// Se já existir a chave no banco de dados no momento do commit, a rotina 
	If (oMdlGI1:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGI1:GetOperation() == MODEL_OPERATION_UPDATE)
		If (!ExistChav("GI1", oMdlGI1:GetValue("GI1_COD")))
			Help( ,, 'Help',"TP001TdOK", STR0008, 1, 0 )//Chave duplicada!
	    	lRet := .F.
	    EndIf
	EndIf

	If oMdlGI1:GetOperation() == MODEL_OPERATION_UPDATE
		If oMdlGI1:IsFieldUpdated('GI1_STATUS') .AND. cStatus == '2'
			cAlias  := GetNextAlias()
			cQuery  := " SELECT H6V_ORIGEM LINHAORIGEM,"
    		cQuery  +=        " H6V_DESTIN LINHADESTINO,"
    		cQuery  +=        " H6W_ORIGEM SECAOORIGEM,"
    		cQuery  +=        " H6W_DESTIN SECAODESTINO,"
    		cQuery  +=        " H70.H70_LOCAL FROTALOCAL"
			cQuery  += " FROM " + RetSqlName("GI1") + " GI1"
			cQuery  +=        " LEFT JOIN " + RetSqlName("H6V") + " H6V"
			cQuery  +=               " ON ( H6V.H6V_FILIAL = '" + xFilial("H6V") + "'"
            cQuery  +=                    " AND H6V.H6V_STATUS = '1'"
			cQuery  +=                    " AND ( H6V.H6V_ORIGEM = GI1.GI1_COD"
            cQuery  +=                          " OR H6V.H6V_DESTIN = GI1.GI1_COD )"
            cQuery  +=                    " AND H6V.D_E_L_E_T_ = '' )"
			cQuery  +=        " LEFT JOIN " + RetSqlName("H6W") + " H6W"
			cQuery  +=               " ON ( H6W.H6W_FILIAL = '" + xFilial("H6W") + "'"
			cQuery  +=                    " AND H6W.H6W_STATUS = '1'"
			cQuery  +=                    " AND ( H6W.H6W_ORIGEM = GI1.GI1_COD"
            cQuery  +=                          " OR H6W.H6W_DESTIN = GI1.GI1_COD )"
            cQuery  +=                    " AND H6W.D_E_L_E_T_ = '' )"
			cQuery  +=        " LEFT JOIN " + RetSqlName("H70") + " H70"
			cQuery  +=               " ON ( H70.H70_FILIAL = '" + xFilial("H70") + "'"
			cQuery  +=                    " AND H70.H70_LOCAL = GI1.GI1_COD"
			cQuery  +=                    " AND H70.H70_STATUS = '1'"
			cQuery  +=                    " AND H70.D_E_L_E_T_ = '' )"
			cQuery  += " WHERE GI1.GI1_FILIAL = '" + xFilial("GI1") + "'"
			cQuery  +=       " AND GI1.GI1_COD = '" + cCodigo + "'"
			cQuery  +=       " AND GI1.D_E_L_E_T_ = ''"

			DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

			If !Empty((cAlias)->LINHAORIGEM) .OR. !Empty((cAlias)->LINHADESTINO)
				cMsgError := "Linhas"
			EndIf
			If !Empty((cAlias)->SECAOORIGEM) .OR. !Empty((cAlias)->SECAODESTINO)
				If !Empty(cMsgError)
					cMsgError += " / "
				EndIf
				cMsgError += "Seções"
			EndIf
			If !Empty((cAlias)->FROTALOCAL)
				If !Empty(cMsgError)
					cMsgError += " / "
				EndIf
				cMsgError += "Frotas"
			EndIf
			(cAlias)->(DbCloseArea())
			If !Empty(cMsgError)
				Help( ,, 'Help',"TP001TdOK", I18n(STR0009,{cMsgError}), 1, 0 )//Não é possivel alterar o status dessa localidade, pois existe(m) vinculo(s) ativo(s) com: #1 
				lRet := .F.
			EndIf
		Endif
	Endif
	RestArea(aArea)
Return (lRet)
