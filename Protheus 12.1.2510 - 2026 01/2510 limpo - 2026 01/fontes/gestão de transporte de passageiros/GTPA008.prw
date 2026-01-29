#Include 'Totvs.ch'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'GTPA008.CH'

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA008
Cadastro de Colaborador
@author Gestão de Transporte de Passageiros 
@version 12
@since 26/09/2014
@return Nil
@obs 
@sample
 /*/
 //--------------------------------------------------------------------------------------------------------
Function GTPA008()

	Local oBrowse

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('GYG')
		oBrowse:SetDescription(STR0001) //"Cadastro de Colaboradores"

		oBrowse:SetMenuDef('GTPA008')

		oBrowse:Activate()

	EndIf

Return()

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu
@author Gestão de Transporte de Passageiros 
@version 12
@since 26/09/2014
@return Nil
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.GTPA008' 	OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.GTPA008'  	OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.GTPA008'  	OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.GTPA008'  	OPERATION 5 ACCESS 0 // #Excluir
	ADD OPTION aRotina Title STR0006	Action 'Tp008Func'  		OPERATION 3 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados do cadastro de colaboradores
@author Gestão de Transporte de Passageiros
@version 12
@since 26/09/2014
@return oModel
@obs 
@sample
 /*/
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStru     := FWFormStruct( 1, "GYG" )
	Local bPosValid :={|oModel|TP008TdOK(oModel)}
	Local bWhen     :={|oModel, cField, uVal| GTP013WHEN(oModel, cField, uVal)}
	Local aTrigAux  := {}
	Local cMarca    := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
	
	// GATILHO - para descrição da localidade do campo fake             
	aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_FILSRA", "SRA->RA_FILIAL", , , , , "!EMPTY(M->GYG_FUNCIO)")
	oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])

	If cMarca == 'RM'
		oStru:SetProperty('GYG_FUNCIO', MODEL_FIELD_VALID,{|| .T.})	
	Else
		oStru:SetProperty('GYG_FUNCIO', MODEL_FIELD_VALID,{|oMdl,cField,uNewValue,uOldValue|TP008ValFu(oMdl,cField,uNewValue,uOldValue) } )
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_FUNCOD", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_FUNDES", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_TURDES", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_CARCOD", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_CARDES", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
		aTrigAux := FwStruTrigger("GYG_FUNCIO", "GYG_FILSRA", " ", , , , , "EMPTY(M->GYG_FUNCIO)")
		oStru:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	Endif
	
	oStru:SetProperty('GYG_CPF' ,   MODEL_FIELD_VALID,{|oMdl,cField,uNewValue,uOldValue|TP008ValFu(oMdl,cField,uNewValue,uOldValue) } )

	If GYG->(FieldPos("GYG_USR")) > 0
		oStru:SetProperty( 'GYG_USR' ,MODEL_FIELD_VALID,{|oMdl,cField,uNewValue,uOldValue|TP008ValFu(oMdl,cField,uNewValue,uOldValue) } )
	EndIf

	oModel := MPFormModel():New('GTPA008',/*bPreValid*/,bPosValid, /*bCommit*/ )

	oModel:AddFields( 'GYGMASTER', /*cOwner*/, oStru)

	oModel:SetPrimaryKey({"GYG_FILIAL", "GYG_CODIGO"})

	oModel:SetDescription( STR0001 )

	oStru:SetProperty("GYG_TURNO" , MODEL_FIELD_WHEN, bWhen)
	oStru:SetProperty("GYG_STATUS", MODEL_FIELD_WHEN, bWhen)
	oStru:SetProperty("GYG_TPDOC" , MODEL_FIELD_WHEN, bWhen)

	GTPDestroy(aTrigAux)

Return oModel 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da visão do cadastro de colaboradores
@author Gestão de serviços 
@version 12
@since 26/09/2014
@return oView
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'GTPA008' )
	Local oStru     := FWFormStruct( 2, 'GYG' )
	Local oView
	Local cMarca    := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
	Local lCpoRM    := GYG->( ColumnPos( 'GYG_VEND' ) ) > 0 .And. GYG->( ColumnPos( 'GYG_CC' ) ) > 0
	Local lWSUrbano := IsInCallStack( 'PUT' )
	Local aCombo    :={"1=Manhã", "2=Tarde", "3=Noite", "12=Manhã/Tarde", "13=Manhã/Noite", "23=Tarde/Noite", "123=Manhã/Tarde/Noite"}

	oStru:SetProperty( 'GYG_FILSRA' , MVC_VIEW_GROUP_NUMBER, '002' )
	If GYG->(FieldPos("GYG_USR")) > 0
		oStru:SetProperty( 'GYG_USR'    , MVC_VIEW_GROUP_NUMBER, '001' )
	EndIf
	oStru:SetProperty( 'GYG_FILSRA' , MVC_VIEW_CANCHANGE, .F. )
	If !lWSUrbano
		oStru:SetProperty( 'GYG_FUNCOD' , MVC_VIEW_CANCHANGE, .F. )
	EndIf
	If lCpoRM
		oStru:SetProperty( 'GYG_VEND' , MVC_VIEW_GROUP_NUMBER, '002' )
		oStru:SetProperty( 'GYG_CC' , MVC_VIEW_GROUP_NUMBER, '002' )
	EndIf 

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oStru:RemoveField("GYG_TURNO")

	IF FUNNAME() == "GTPA290"
		oStru:RemoveField("GYG_RG")
		oStru:RemoveField("GYG_CPF")
	EndIf

	oStru:AddField("GYG_TURNO"				,;	// [01]  C   Nome do Campo
					"07"					,;	// [02]  C   Ordem
					"Turno" 				,;	// [03]  C   Titulo do campo
					"Turno"					,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					'COMBO'					,;	// [06]  C   Tipo do campo
					X3Picture("GYG_TURNO")	,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.T.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					aCombo				    ,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.F.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo

	oView:AddField( 'VIEW_GYG', oStru, 'GYGMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_GYG', 'TELA' )

	If cMarca == "RM"
		oStru:RemoveField("GYG_FUNCOD")
		oStru:RemoveField("GYG_FUNDES")
		oStru:RemoveField("GYG_TURCOD")
		oStru:RemoveField("GYG_TURDES")
		oStru:RemoveField("GYG_CARCOD")
		oStru:RemoveField("GYG_CARDES")
	EndIf 

	If lCpoRM .And. cMarca <> "RM"
		oStru:RemoveField("GYG_VEND")
		oStru:RemoveField("GYG_CC")
	EndIf

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tp008Func
Importa cadastro de funcionários para cadastro de colaborador 
@author Gestão de Transporte de Passageiros 
@version 12
@since 26/09/2014
@return Nil
@obs 
@sample
 /*/
//--------------------------------------------------------------------------------------------------------
Function Tp008Func

	If MsgYesNo(STR0007) //"Deseja realizar a importação de todo o cadastro de funcionários"
		FwMsgRun(,{|| GTPA008X(.F.) },,STR0008 ) // "Aguarde abrindo Caixa..."
	Endif

Return Nil

/*/{Protheus.doc} TP008ValFu
Valida se existe funcionário cadastrado na tabela
@type function
@author henrique.toyada
@since 05/02/2019
@version 1.0
@param oMdlGYG, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function TP008ValFu(oMdl,cField,uNewValue,uOldValue )

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaGYG := GYG->( GetArea() )
	Local cFilGYG  := xFilial("SRA")//SRA->RA_FILIAL
	Local cCPFSRA  := ""
	Local lUsaRH   := SuperGetMV("MV_USARH")
	
	Do Case
	    Case Empty(uNewValue)
	        lRet := .T.
	    Case cField == "GYG_USR"
	        lRet := UsrExist(uNewValue)

	    Case cField == "GYG_FUNCIO"
	        DbSelectArea("GYG")
	        GYG->(DbSetOrder(6)) //GYG_FILIAL + GYG_FILSRA + GYG_FUNCIO
	
	        // Se o código do funcionário já estiver vinculado a um colaborador.
	        If GYG->(dbSeek(xFilial("GYG") + cFilGYG + uNewValue))
	            oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"TP008VALFU",I18n(STR0013,{uNewValue}),"")//"O funcionário #1 já está vinculado a um colaborador."
	            lRet := .F.
	        EndIf	
		Case cField == "GYG_CPF"
			If !CGC(uNewValue) 
				oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"TP008VALFU",I18n(STR0023,{uNewValue}),"")//"CPF inválido"		
				lRet := .F.
			EndIf

			If lUsaRH .and. lRet

				If !Empty(oMdl:GetValue("GYG_FUNCIO"))
					cCPFSRA := GetAdvFval("SRA", "RA_CIC", xFilial("SRA") + oMdl:GetValue("GYG_FUNCIO"), 1)
					If cCPFSRA <> uNewValue
						oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"TP008VALFU",I18n(STR0025,{uNewValue}),"")//"Informação digitada diferente ao cadastro de Funcionário.Favor avaliar!"		
						lRet := .F.
					EndIf 
				Else
					DbSelectArea('GYG')
					GYG->(DbSetOrder(5))
					If GYG->(dbSeek(xFilial('GYG')+uNewValue))
						oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"TP008VALFU",I18n(STR0024,{uNewValue}),"")//"CPF já cadastrado"		
						lRet := .F.
					Endif
				Endif
			EndIf

	EndCase

	RestArea( aAreaGYG )
	RestArea( aArea )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Return GTPI008( cXml, nTypeTrans, cTypeMessage )

//-------------------------------------------------------------------
/*/{Protheus.doc} TP008TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP008TdOK(oModel)

	Local lRet    := .T.
	Local oMdlGYG := oModel:GetModel( 'GYGMASTER' )
	Local cUser   := oMdlGYG:GetValue("GYG_USR")
	Local cColab  := oMdlGYG:GetValue("GYG_CODIGO")
	Local aArea   := nil

	// Se já existir a chave no banco de dados no momento do commit, a rotina
	If (oMdlGYG:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGYG:GetOperation() == MODEL_OPERATION_UPDATE)
		If (!ExistChav("GYG", oMdlGYG:GetValue("GYG_CODIGO")))
			Help( ,, 'Help',"TP008TdOK", STR0020, 1, 0 )//Chave duplicada!
			lRet := .F.
		EndIf

		If !(EMPTY(cUser))
	        DbSelectArea('GYG')
	        aArea := GYG->(GetArea())
			GYG->(DbsetOrder(7))
			If ( GYG->(DbSeek(xFilial("GYG")+cUser)) .And. GYG->GYG_CODIGO != cColab )
				lRet := .F.
				Help( ,, 'Help',"TP008TdOK", STR0022 , 1, 0 ) //O usuário selecionado já está vinculado a um colaborador.
			EndIf
	        RestArea(aArea)
		EndIf
	EndIf

	GtpDestroy(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTP013WHEN
	Valida se deve alterar os campos GYG_TURNO|GYG_STATUS|GYG_TPDOC

	@type Static Function
	@param  oModel, object
	@param  cTipo = 1-Total Passageiros, 2-Valor total
	@return nSaldoAtu - Saldo atualizado
	@authors Silas Gomes
	@since 13/12/2024
/*/
//-------------------------------------------------------------------
Static Function GTP013WHEN(oModel, cField, uVal)
    Local oMdl    := oModel:GetModel()
	Local oMdlGYG := oMdl:GetModel("GYGMASTER")

Return oMdlGYG:GetValue('GYG_URBANO')
