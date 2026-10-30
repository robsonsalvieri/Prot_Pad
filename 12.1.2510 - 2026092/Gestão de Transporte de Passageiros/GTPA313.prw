#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA313.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA313()
Cadastro de Escala extraordinária
 
@sample	GTPA313()
 
@return	oBrowse	Retorna o Cadastro de Plantões
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA313(cFiltDefault)

Local oBrowse	:= Nil

Default cFiltDefault	:= ""

If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
			
	oBrowse	:= FWMBrowse():New()	
	oBrowse:SetAlias('GQK')
	oBrowse:SetMenuDef('GTPA313')

	If !Empty(cFiltDefault)
		oBrowse:SetFilterDefault(cFiltDefault)
	Endif

	oBrowse:SetDescription(STR0009)//"Cadastro de Escalas Extraordinárias"
	oBrowse:Activate()

EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA313' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA313' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA313' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA313' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local bPosValid	:= {|oModel|TP313TdOK(oModel)}
Local bVldActive:= {|oModel| VldActivate(oModel)}
Local oModel 	:= MPFormModel():New('GTPA313', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
Local oStruGQK	:= FWFormStruct(1,'GQK')

SetModelStruct(oStruGQK)

oModel:AddFields('GQKMASTER',/*cOwner*/,oStruGQK)
oModel:SetDescription(STR0010)	//"Escalas Extraordinárias"
oModel:GetModel('GQKMASTER'):SetDescription(STR0011)	//"Dados da Escala Extraordinária"

oModel:SetVldActivate(bVldActive)
Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oStruGQK, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGQK)
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|Tp313VlDt(oMdl,cField,cNewValue,cOldValue) }
Local bTrigger	:= {|oModel| cValToChar(IntToHora(SubtHoras(oModel:GetValue("GQK_DTINI"), TransForm(oModel:GetValue("GQK_HRINI"),PesqPict("GQK","GQK_HRINI")), oModel:GetValue("GQK_DTFIM"), TransForm(oModel:GetValue("GQK_HRFIM"),PesqPict("GQK","GQK_HRFIM")))))	}

oStruGQK:AddField(	STR0035,;								// 	[01]  C   Titulo do campo // "Periodo"
				  	STR0035,;								// 	[02]  C   ToolTip do campo //"Periodo"
					"GQK_HRSPER",;							// 	[03]  C   Id do Field // 
					"C",;									// 	[04]  C   Tipo do campo
					7,; 									// 	[05]  N   Tamanho do campo
					0,;										// 	[06]  N   Decimal do campo
					Nil,;									// 	[07]  B   Code-block de validação do campo
					Nil,;									// 	[08]  B   Code-block de validação When do campo
					Nil,;									//	[09]  A   Lista de valores permitido do campo
					.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					Nil,;									//	[11]  B   Code-block de inicializacao do campo
					.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)									// 	[14]  L   Indica se o campo é virtual
			

oStruGQK:AddTrigger("GQK_RECURS", "GQK_DRECUR", { || .T.}, { |oModel| Posicione('GYG',1,xFilial('GYG')+oModel:GetValue('GQK_RECURS'),'GYG_NOME')	})
oStruGQK:AddTrigger("GQK_RECURS", "GQK_FUNCIO", { || .T.}, { |oModel| Posicione('GYG',1,xFilial('GYG')+oModel:GetValue('GQK_RECURS'),'GYG_FUNCIO')	})
oStruGQK:AddTrigger("GQK_TCOLAB", "GQK_DCOLAB", { || .T.}, { |oModel| Posicione('GYK',1,xFilial('GYK')+oModel:GetValue('GQK_TCOLAB'),'GYK_DESCRI')	})
oStruGQK:AddTrigger("GQK_LOCORI", "GQK_DESORI", { || .T.}, { |oModel| Posicione('GI1',1,xFilial('GI1')+oModel:GetValue('GQK_LOCORI'),'GI1_DESCRI')	})
oStruGQK:AddTrigger("GQK_LOCDES", "GQK_DESDES", { || .T.}, { |oModel| Posicione('GI1',1,xFilial('GI1')+oModel:GetValue('GQK_LOCDES'),'GI1_DESCRI')	})
oStruGQK:AddTrigger("GQK_CODGZS", "GQK_DSCGZS", { || .T.}, { |oModel| Posicione('GZS',1,xFilial('GZS')+oModel:GetValue('GQK_CODGZS'),'GZS_DESCRI')	})
oStruGQK:AddTrigger("GQK_HRFIM" , "GQK_HRSPER", { || .T.}, bTrigger)

oStruGQK:SetProperty("GQK_STATUS"	,MODEL_FIELD_VALUES,{"1=Sim","2=Não"})

oStruGQK:SetProperty("GQK_STATUS"	,MODEL_FIELD_INIT,{||If(FwIsInCallStack('GTPA313'),'1','2')})

If ( FwIsInCallStack("GTPA425") )
	oStruGQK:SetProperty("*", MODEL_FIELD_OBRIGAT, .F. )
Endif

oStruGQK:SetProperty('GQK_DTREF',MODEL_FIELD_VALID,bFldVld)
oStruGQK:SetProperty('GQK_DTINI',MODEL_FIELD_VALID,bFldVld)
oStruGQK:SetProperty('GQK_DTFIM',MODEL_FIELD_VALID,bFldVld) 
oStruGQK:SetProperty('GQK_HRINI',MODEL_FIELD_VALID,bFldVld) 
oStruGQK:SetProperty('GQK_HRFIM',MODEL_FIELD_VALID,bFldVld) 
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function VldActivate(oModel)
Local lRet	:= .T.
Local nOpc	:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE 
	If GQK->GQK_MARCAD == "1"
		oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "VldActivate", 'Não é permitido alterar ou excluir um registro que se encontra enviado para o ponto')
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA313') 
Local oView		:= FWFormView():New()
Local oStruGQK	:= FWFormStruct(2, 'GQK')

SetViewStruct(oStruGQK)

oView:SetModel(oModel)
 
oView:AddField('VIEW_GQK' ,oStruGQK,'GQKMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GQK','TELA')

oView:SetDescription(STR0010)//"Escalas Extraordinárias"

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oStruGQK, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGQK)
//Remoção de Campos
oStruGQK:RemoveField("GQK_OCOVIA")
oStruGQK:RemoveField("GQK_ESPHIN")
oStruGQK:RemoveField("GQK_ESPHFM")
oStruGQK:RemoveField("GQK_CODGYQ")

oStruGQK:AddField(	"GQK_HRSPER",;				// [01]  C   Nome do Campo
	                "40",;						// [02]  C   Ordem
	                STR0035,;					// [03]  C   Titulo do campo // "Periodo"
	                STR0035,;					// [04]  C   Descricao do campo // "Periodo"
	                {STR0035},;					// [05]  A   Array com Help // "Periodo"
	                "GET",;						// [06]  C   Tipo do campo
	                "",;						// [07]  C   Picture
	                NIL,;						// [08]  B   Bloco de Picture Var
	                "",;						// [09]  C   Consulta F3
	                .F.,;						// [10]  L   Indica se o campo é alteravel
	                NIL,;						// [11]  C   Pasta do campo
	                "",;						// [12]  C   Agrupamento do campo
	                NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                NIL,;						// [15]  C   Inicializador de Browse
	                .T.,;						// [16]  L   Indica se o campo é virtual
	                NIL,;						// [17]  C   Picture Variavel
	                .F.)						// [18]  L   Indica pulo de linha após o campo	


//Sepração dos campos
oStruGQK:AddGroup( "RECURSO", "Recurso", "" , 2 )
oStruGQK:SetProperty("GQK_CODIGO" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )
oStruGQK:SetProperty("GQK_RECURS" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )
oStruGQK:SetProperty("GQK_DRECUR" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )

oStruGQK:AddGroup( "TIPORECURSO"  , "", "" , 1)
oStruGQK:SetProperty("GQK_TCOLAB" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )
oStruGQK:SetProperty("GQK_DCOLAB" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )
oStruGQK:SetProperty("GQK_FUNCIO" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )

oStruGQK:AddGroup( "ALOCACAO", "Alocações", "" , 2 )
oStruGQK:SetProperty("GQK_DTREF"  , MVC_VIEW_GROUP_NUMBER, "ALOCACAO" )
oStruGQK:SetProperty("GQK_TPDIA"  , MVC_VIEW_GROUP_NUMBER, "ALOCACAO" )

oStruGQK:AddGroup( "ALOCAINICIAL"  , "", "" , 1)
oStruGQK:SetProperty("GQK_DTINI"  , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_HRINI"  , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_LOCORI" , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_DESORI" , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )

oStruGQK:AddGroup( "ALOCAFINAL"  , "", "" , 1)
oStruGQK:SetProperty("GQK_DTFIM"  , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_HRFIM"  , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_LOCDES" , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_DESDES" , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_HRSPER" , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )

oStruGQK:AddGroup( "ALOCDEMAIS"  , "", "" , 1)
oStruGQK:SetProperty("GQK_CODGZS" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
oStruGQK:SetProperty("GQK_DSCGZS" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
If GQK->(FieldPos("GQK_INTERV")) > 0
	oStruGQK:SetProperty("GQK_INTERV" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
EndIf

oStruGQK:AddGroup( "STATUS", "Status", "" , 2 )
oStruGQK:SetProperty("GQK_STATUS" , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_TPCONF" , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_CONF"   , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_MARCAD" , MVC_VIEW_GROUP_NUMBER, "STATUS" )

//Ordenação dos campos
oStruGQK:SetProperty("GQK_CODIGO" 	, MVC_VIEW_ORDEM,'01')
oStruGQK:SetProperty("GQK_RECURS" 	, MVC_VIEW_ORDEM,'02')
oStruGQK:SetProperty("GQK_DRECUR" 	, MVC_VIEW_ORDEM,'03')
oStruGQK:SetProperty("GQK_TCOLAB" 	, MVC_VIEW_ORDEM,'04')
oStruGQK:SetProperty("GQK_DCOLAB" 	, MVC_VIEW_ORDEM,'05')
oStruGQK:SetProperty("GQK_FUNCIO" 	, MVC_VIEW_ORDEM,'06')
oStruGQK:SetProperty("GQK_DTREF"  	, MVC_VIEW_ORDEM,'07')
oStruGQK:SetProperty("GQK_TPDIA"  	, MVC_VIEW_ORDEM,'08')
oStruGQK:SetProperty("GQK_DTINI"  	, MVC_VIEW_ORDEM,'09')
oStruGQK:SetProperty("GQK_HRINI"  	, MVC_VIEW_ORDEM,'10')
oStruGQK:SetProperty("GQK_LOCORI" 	, MVC_VIEW_ORDEM,'11')
oStruGQK:SetProperty("GQK_DESORI" 	, MVC_VIEW_ORDEM,'12')
oStruGQK:SetProperty("GQK_DTFIM"  	, MVC_VIEW_ORDEM,'13')
oStruGQK:SetProperty("GQK_HRFIM"  	, MVC_VIEW_ORDEM,'14')
oStruGQK:SetProperty("GQK_HRSPER" 	, MVC_VIEW_ORDEM,'15')
oStruGQK:SetProperty("GQK_LOCDES" 	, MVC_VIEW_ORDEM,'16')
oStruGQK:SetProperty("GQK_DESDES" 	, MVC_VIEW_ORDEM,'17')
oStruGQK:SetProperty("GQK_CODGZS" 	, MVC_VIEW_ORDEM,'18')
oStruGQK:SetProperty("GQK_DSCGZS" 	, MVC_VIEW_ORDEM,'19')
If GQK->(FieldPos("GQK_INTERV")) > 0
	oStruGQK:SetProperty("GQK_INTERV" 	, MVC_VIEW_ORDEM,'20')
EndIf
oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_ORDEM,'21')
oStruGQK:SetProperty("GQK_TPCONF" 	, MVC_VIEW_ORDEM,'22')
oStruGQK:SetProperty("GQK_CONF"   	, MVC_VIEW_ORDEM,'23')
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_ORDEM,'24')
oStruGQK:SetProperty("GQK_JUSTIF" 	, MVC_VIEW_ORDEM,'25')
oStruGQK:SetProperty("GQK_USRCON" 	, MVC_VIEW_ORDEM,'26')
oStruGQK:SetProperty("GQK_CODVIA" 	, MVC_VIEW_ORDEM,'27')

oStruGQK:SetProperty("GQK_FUNCIO" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_CONF" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_USRCON" 	, MVC_VIEW_CANCHANGE,.F.)

oStruGQK:SetProperty("GQK_STATUS"	,MVC_VIEW_COMBOBOX,{"1=Sim","2=Não"})


oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_TITULO,'Confirmado?')
oStruGQK:SetProperty("GQK_CONF" 	, MVC_VIEW_TITULO,'Apurado?')
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_TITULO,'Enviado?')

Return 

/*/{Protheus.doc} TP313TdOK
(long_description)
@type function
@author henrique.toyada
@since 01/02/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${lRet}, ${Permite a inclusão}
@example
(examples)
@see (links_or_references)
/*/
Static Function TP313TdOK(oModel)

Local lRet 	    := .T.
Local oMdlGQK	:= oModel:GetModel('GQKMASTER')
Local cMsgErro  := ""
Local cRecurso  := oMdlGQK:GetValue('GQK_RECURS')
Local dDtRef	:= oMdlGQK:GetValue('GQK_DTREF' )
Local dDtIni    := oMdlGQK:GetValue('GQK_DTINI' ) 
Local cHrIni    := oMdlGQK:GetValue('GQK_HRINI' ) 
Local dDtFim    := oMdlGQK:GetValue('GQK_DTFIM' ) 
Local cHrFim    := oMdlGQK:GetValue('GQK_HRFIM' )
Local cTpDia    := oMdlGQK:GetValue('GQK_TPDIA' ) 
Local nRecGQK   := oMdlGQK:GetDataId()
Local lVldRh	:= cTpDia <> '5' 

//Ajustar filial para pegar do funcionário na validação
// Validar o tipo de recurso para pegar apenas o colaborador e validar o TIPO DE DIA QUANDO FOR diferente de 4
If oMdlGQK:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGQK:GetOperation() == MODEL_OPERATION_UPDATE
	If dDtFim < dDtIni
		Help( ,, 'Help',"TP313TdOK", STR0007, 1, 0,,,,,,{STR0008} )
		lRet := .F.		
	Endif	 
	If lRet .and. cTpDia != "4"
		If !Gc300VldAloc(cRecurso,"1",dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,lVldRh,nRecGQK,cTpDia)
			Help( ,, 'Help',"TP313TdOK", cMsgErro, 1, 0 )
			lRet := .F.
		Endif
	EndIf
EndIf

Return lRet
/*/{Protheus.doc} Tp313VlDt
(long_description) Validação de datas do campo GQK_DTREF, GQK_DTINI, GQK_DTFIM, GQK_HRINI e GQK_HRFIM
@author kaique.olivero
@since 13/07/2023
@return ${lRet}, ${Permite a inclusão das datas}
/*/
Static Function Tp313VlDt(oMdl,cField,cNewValue,cOldValue)
Local lRet := .T.
Local cMsgErro := ""
Local cMsgSol := ""

If cField == "GQK_DTINI"
	If !Empty(oMdl:GetValue("GQK_DTINI")) .And. !Empty(cNewValue)
		If cNewValue < oMdl:GetValue("GQK_DTREF")
			cMsgErro := STR0012 //"Não é possível inserir a data inicial menor que a data de referência."
			cMsgSol := STR0013 //"Informe uma data igual ou maior que a data de referência."
			lRet := .F.
		Elseif !Empty(oMdl:GetValue("GQK_DTFIM")) .And. cNewValue > oMdl:GetValue("GQK_DTFIM")
			cMsgErro := STR0014 //"Não é possível inserir a data inicial maior que a data final."
			cMsgSol := STR0015 //"Informe uma data igual ou maior que a data de referência."
			lRet := .F.
		Elseif !Empty(oMdl:GetValue("GQK_HRINI")) .And. !Empty(oMdl:GetValue("GQK_HRFIM")) .And.;
		 		cNewValue == oMdl:GetValue("GQK_DTFIM") .And. oMdl:GetValue("GQK_HRINI") >= oMdl:GetValue("GQK_HRFIM")
			cMsgErro := STR0016 //"Não é possível inserir essa data, a hora inicial ficará maior ou igual a hora final para o mesmo dia."
			cMsgSol := STR0017 //"Informe a data corretamente."
			lRet := .F.
		Endif
	Endif
Elseif cField == "GQK_DTREF"
	If !Empty(oMdl:GetValue("GQK_DTINI")) .And. !Empty(cNewValue)
		If cNewValue > oMdl:GetValue("GQK_DTINI")
			cMsgErro := STR0018 //"Não é possível inserir a data de referência maior que a data inicial."
			cMsgSol := STR0019 //"Informe uma data de referência igual ou menor que a data inicial."
			lRet := .F.
		Endif
	Endif
Elseif cField == "GQK_DTFIM"
	If !Empty(oMdl:GetValue("GQK_DTINI")) .And. !Empty(cNewValue)
		If cNewValue < oMdl:GetValue("GQK_DTINI")
			cMsgErro := STR0020 //"Não é possível inserir a data de referência maior que a data inicial."
			cMsgSol := STR0021 //"Informe uma data de referência igual ou menor que a data inicial."
			lRet := .F.
		Elseif !Empty(oMdl:GetValue("GQK_HRINI")) .And. !Empty(oMdl:GetValue("GQK_HRFIM")) .And.; 
				oMdl:GetValue("GQK_DTINI") == cNewValue .And. oMdl:GetValue("GQK_HRINI") >= oMdl:GetValue("GQK_HRFIM")
			cMsgErro := STR0022 //"Não é possível inserir essa data, a hora inicial ficará maior ou igual a hora final para o mesmo dia."
			cMsgSol := STR0023 //"Informe a data corretamente."
			lRet := .F.
		Endif
	Endif
Elseif cField == "GQK_HRINI"
	If !Empty(oMdl:GetValue("GQK_DTINI")) .And. !Empty(oMdl:GetValue("GQK_DTFIM"))
		If oMdl:GetValue("GQK_DTINI") == oMdl:GetValue("GQK_DTFIM")
			If !Empty(oMdl:GetValue("GQK_HRFIM")) .And. !Empty(cNewValue) .And. cNewValue >= oMdl:GetValue("GQK_HRFIM")
				cMsgErro := STR0024 //"Não é possível inserir a hora inicial maior ou igual a hora final para o mesmo dia."
				cMsgSol := STR0025 //"Informe a hora inicial menor que a hora final
				lRet := .F.
			Endif
		Endif
	Endif
	If lRet .And. TransForm(cNewValue,PesqPict("GQK","GQK_HRINI")) == "24:00"
		cMsgErro := STR0026 //"Não é possível inserir 24:00 horas."
		cMsgSol := STR0027 //"Informe a hora corretamente."
		lRet := .F.
	Endif	
	If lRet .And. !vldHoraGQK(oMdl:GetValue("GQK_HRINI")) 
		cMsgErro := STR0036	//'Hora inválida' 
		cMsgSol  := STR0037	//'Verifique a hora digitada' 
		lRet := .F.
	Endif
Elseif cField == "GQK_HRFIM"
	If !Empty(oMdl:GetValue("GQK_DTINI")) .And. !Empty(oMdl:GetValue("GQK_DTFIM"))
		If oMdl:GetValue("GQK_DTINI") == oMdl:GetValue("GQK_DTFIM")
			If !Empty(cNewValue) .And. !Empty(oMdl:GetValue("GQK_HRINI")) .And. cNewValue <= oMdl:GetValue("GQK_HRINI")
				cMsgErro := STR0028 //"Não é possível inserir a hora final menor ou igual a hora inicial para o mesmo dia."
				cMsgSol := STR0029 //"Informe a hora final maior que a hora inicial."
				lRet := .F.
			Endif
		Endif
	Endif
	If lRet .And. TransForm(cNewValue,PesqPict("GQK","GQK_HRFIM")) == "24:00"
		cMsgErro := STR0026 //"Não é possível inserir 24:00 horas."
		cMsgSol := STR0027 //"Informe a hora corretamente."
		lRet := .F.
	Endif
	If lRet .And. !vldHoraGQK(oMdl:GetValue("GQK_HRFIM")) 
		cMsgErro := STR0036	//'Hora inválida' 
		cMsgSol  := STR0037	//'Verifique a hora digitada' 
		lRet := .F.
	Endif	
Endif

If !lRet .And. !Empty(cMsgSol) .And. !Empty(cMsgErro)
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),,oMdl:GetId(),,"Tp313VlDt", cMsgErro, cMsgSol) 
Endif

Return lRet

/*/{Protheus.doc} vldHoraGQK
(long_description) Validação de horas dos campos GQK_HRINI e GQK_HRFIM
@author mateus.ribeiro 
@since 13/03/2024
@return ${lRet}, ${Permite a inclusão das horas}
/*/

Static Function vldHoraGQK(nCampo)

	Local lRet 		:= .T.
	Local nHoras	:= 0
	Local nMinutos 	:= 0

	nHoras	 := Val(Left(nCampo,2))
	nMinutos := Val(Right(nCampo,2))

	If nHoras < 0 .Or. nHoras > 23 .Or. nMinutos < 0 .Or. nMinutos > 59
		lRet := .F.
	EndIf
Return lRet
