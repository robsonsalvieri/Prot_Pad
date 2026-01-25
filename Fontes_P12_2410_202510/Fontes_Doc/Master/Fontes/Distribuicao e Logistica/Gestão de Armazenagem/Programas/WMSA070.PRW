#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA070.CH"

#DEFINE WMSA07001 "WMSA07001"
#DEFINE WMSA07002 "WMSA07002"
#DEFINE WMSA07003 "WMSA07003"
#DEFINE WMSA07004 "WMSA07004"
#DEFINE WMSA07005 "WMSA07005"
#DEFINE WMSA07006 "WMSA07006"
#DEFINE WMSA07007 "WMSA07007"
#DEFINE WMSA07008 "WMSA07008"
#DEFINE WMSA07009 "WMSA07009"
#DEFINE WMSA07010 "WMSA07010"
#DEFINE WMSA07011 "WMSA07011"
#DEFINE WMSA07012 "WMSA07012"
#DEFINE WMSA07013 "WMSA07013"
#DEFINE WMSA07014 "WMSA07014"
#DEFINE WMSA07015 "WMSA07015"
#DEFINE WMSA07016 "WMSA07016"
#DEFINE WMSA07017 "WMSA07017"
#DEFINE WMSA07018 "WMSA07018"
#DEFINE WMSA07019 "WMSA07019"
#DEFINE WMSA07020 "WMSA07020"
#DEFINE WMSA07021 "WMSA07021"
#DEFINE WMSA07022 "WMSA07022"
#DEFINE WMSA07023 "WMSA07023"
#DEFINE WMSA07024 "WMSA07024"
#DEFINE WMSA07025 "WMSA07025"
#DEFINE WMSA07026 "WMSA07026"
#DEFINE WMSA07027 "WMSA07027"
#DEFINE WMSA07028 "WMSA07028"
#DEFINE WMSA07029 "WMSA07029"
#DEFINE WMSA07030 "WMSA07030"
#DEFINE WMSA07031 "WMSA07031"
#DEFINE WMSA07032 "WMSA07032"
#DEFINE WMSA07033 "WMSA07033"
#DEFINE WMSA07034 "WMSA07034"
#DEFINE WMSA07035 "WMSA07035"
#DEFINE WMSA07036 "WMSA07036"
#DEFINE WMSA07037 "WMSA07037"
#DEFINE WMSA07038 "WMSA07038"
#DEFINE WMSA07039 "WMSA07039"
#DEFINE WMSA07040 "WMSA07040"
#DEFINE WMSA07041 "WMSA07041"
#DEFINE WMSA07042 "WMSA07042"
#DEFINE WMSA07043 "WMSA07043"
#DEFINE WMSA07044 "WMSA07044"
#DEFINE WMSA07045 "WMSA07045"
#DEFINE WMSA07046 "WMSA07046"
#DEFINE WMSA07047 "WMSA07047"
#DEFINE WMSA07048 "WMSA07048"
#DEFINE WMSA07049 "WMSA07049"
#DEFINE WMSA07050 "WMSA07050"
#DEFINE WMSA07051 "WMSA07051"

Static aCposCab := {}
//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSA070
Cadastro dos Sevicos x Tarefa

A tabela Servico Tarefa (Ser_Tar) e resultante das tabelas
Servico e Tarefas. Permite ao usuario cadastrar as tarefas
geradas por um determinado servico no armazem , bem como
indica a ordem de execucao das tarefas dentro de um servico
@author Denilson
@since 20/12/2000
@version 2.0
@param cCodServ, Character, (Codigo do serviço)
@param nRotina, Numerico, (Rotina)
@obs Mauro Paladini 28/08/13 -> Conversao da rotina para o padrao MVC
@obs Mauro Paladini 06/12/13 -> Ajustes para o funcionamento do Mile
/*/
//---------------------------------------------------------------------------
Function WMSA070(cCodServ,nRotina)
Local oBrowse    := Nil
Local aOpcRotina := {}

	If nModulo == 43
		SIX->(DbSetOrder(1))
		If !SIX->(DbSeek("DUX4"))
			Final(STR0010) // Execute Update TMS10R134
		Else
			If "DUX_FILIAL+DUX_SERVIC" # AllTrim(SIX->CHAVE)
				Final(STR0010) // Execute Update TMS10R134
			EndIf
		EndIf
	EndIf

	If AMiIn(39,42,43) // Somente autorizado para OMS, WMS E TMS
		// Endereca a funcao de BROWSE
		DC5->(DbSetOrder(1))

		If nRotina == Nil
			oBrowse:= FWMBrowse():New()
			oBrowse:SetAlias("DC5")
			oBrowse:SetMenuDef("WMSA070")   // Nome do fonte onde esta a função MenuDef
			oBrowse:SetDescription(STR0001) // Servico x Tarefa
			oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
			oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
			oBrowse:SetCacheView(.F.)       // Desabilita Cache da View, pois gera colunas dinamicamente
			If cCodServ <> Nil
				oBrowse:SetFilterDefault( 'xFilial("DC5")+cCodServ' )
			EndIf
			oBrowse:Activate()
		Else
			aOpcRotina := WRetMvcOpc(nRotina)
			If aOpcRotina[1] > 0
				FWExecView(aOpcRotina[2],"VIEWDEF.WMSA070", aOpcRotina[1]  ,, { || .T. } ,,  /*nPerReducTela*/ )
			EndIf
		EndIf
		RetIndex("DC5") // Devolve os indices padroes do SIGA.
	EndIf
Return NIL
/*---------------------------------------------------------------------------
---ModelDef
---Modelo de dados
---Mauro Paladini 23/08/2013
---------------------------------------------------------------------------*/
Static Function ModelDef()
Local aRetPE     := {}
Local oModel     := Nil
Local oStruCDC5  := Nil
Local oStruIDC5  := Nil
Local bPosValid  := { |oModel| PosVldMdl(oModel) }
Local lWmA070Enc := ExistBlock('DLA070ENC') .And. (IntDL() .Or. IntWMS())
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local aRelation  := {}

	// Campos que nao devem ser exibidos na Grid
	// Não deve ser tratado por módulo - Gera erro. Deve ser tratado no cadastro do ATUSX
	aCposCab := {  'DC5_TIPTRA','DC5_DOCTMS','DC5_DESDOC','DC5_COBSER','DC5_SERTMS','DC5_DESCOB','DC5_DESTPT',;
						'DC5_DESSVT','DC5_SEGPER','DC5_DESC1' ,'DC5_DESC2' ,'DC5_DESC3' ,'DC5_DESC4' ,'DC5_TABSEG',;
						'DC5_TPTSEG','DC5_CATSER','DC5_SEROPE','DC5_DSEOPE','DC5_TIPRAT','DC5_TIPO'  ,'DC5_TPSELE',;
						'DC5_SERVIC','DC5_DESSER','DC5_TPEXEC','DC5_UTSUBS'}

	AAdd(aCposCab,'DC5_UTISDC')
	AAdd(aCposCab,"DC5_NATURE")
	AAdd(aCposCab,'DC5_COFEXP')
	AAdd(aCposCab,'DC5_LIBPED')

	AAdd(aCposCab,'DC5_MNTVOL')
	AAdd(aCposCab,'DC5_UPDEND')
	AAdd(aCposCab,'DC5_UPDPRD')
	AAdd(aCposCab,'DC5_DISSEP')
	AAdd(aCposCab,'DC5_MNTEXC')
	AAdd(aCposCab,'DC5_IMPETI')
	AAdd(aCposCab,'DC5_BXESTO')

	// Tratamento de campos
	// Ponto de entrada DLA070ENC p/possibilitar a inclusao de campos na enchoice
	If lWmA070Enc
		Private aNoFields := AClone(aCposCab)
		// O formato do vetor retornado pelo ponto de entrada deve ser:
		// [01] Nome do campo
		aRetPE := ExecBlock("DLA070ENC",.F.,.F.)
		If ValType(aRetPE) == "A"
			WmA070Cpo(aRetPE,aCposCab)
		EndIf
	EndIf

	oStruCDC5 := FwFormStruct( 1, "DC5" , { |cCampo| AllTrim(cCampo) == "DC5_FILIAL" .Or. aScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
	oStruIDC5 := FwFormStruct( 1, "DC5" , { |cCampo| AllTrim(cCampo) == "DC5_FILIAL" .Or. aScan(aCposCab , AllTrim( cCampo ) ) == 0 } )

	//Valida se o campo pode ser editado
	If lWmsNew
		oStruCDC5:SetProperty('DC5_MNTVOL'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruCDC5:SetProperty('DC5_DISSEP'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruCDC5:SetProperty('DC5_MNTEXC'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruCDC5:SetProperty('DC5_IMPETI'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruIDC5:SetProperty('DC5_FUNEXE'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruCDC5:SetProperty('DC5_BXESTO'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
		oStruIDC5:SetProperty('DC5_OPERAC'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'WMS070VFld(A,B,C)'))

		If nModulo == 39 .Or. nModulo == 42
			oStruIDC5:SetProperty('DC5_OPERAC'  , MODEL_FIELD_OBRIGAT , .T.)
		EndIf
	EndIf

	oStruCDC5:SetProperty('DC5_SEROPE'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. WMS070VFld(A,B,C)'))
	oStruCDC5:SetProperty('DC5_TABSEG'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'WMS070VFld(A,B,C)'))
	oStruCDC5:SetProperty('DC5_TPTSEG'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'WMS070VFld(A,B,C)'))
	oStruIDC5:SetProperty('DC5_BLQLOT'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. WMS070VFld(A,B,C)'))
	oStruIDC5:SetProperty('DC5_FUNEXE'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. WMS070VFld(A,B,C)'))
	oStruIDC5:SetProperty('DC5_MLTATI'  , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_VALID,'Pertence("012") .And. WMS070VFld(A,B,C)'))

	oStruCDC5:SetProperty('DC5_COFEXP'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))
	oStruCDC5:SetProperty('DC5_LIBPED'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'Wms070WFld(A,B)'))

	oStruIDC5:SetProperty('DC5_DESTAR'  , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD,'Wms070GetD(A,B)'))
	oStruIDC5:SetProperty('DC5_DESOPE'  , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD,'Wms070GetD(A,B)'))

	// Cria o formulario
	oModel:= MpFormMOdel():New("WMSA070",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
	oModel:SetDescription(STR0001)         // "Tarefas x Atividades"

	oModel:AddFields("MdFieldCDC5",Nil,oStruCDC5,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({ 'DC5_FILIAL','DC5_SERVIC' })

	oModel:AddGrid("MdGridIDC5", "MdFieldCDC5" /*cOwner*/, oStruIDC5 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,/*bLoad*/)

	aRelation := { { "DC5_FILIAL", "xFilial('DC5')" },;
						{ 'DC5_SERVIC', 'DC5_SERVIC' },;
						{ 'DC5_TPEXEC', 'DC5_TPEXEC' },;
						{ 'DC5_TIPO', 'DC5_TIPO' } }
	AAdd(aRelation,{ 'DC5_COFEXP', 'DC5_COFEXP' })
	AAdd(aRelation,{ 'DC5_LIBPED', 'DC5_LIBPED' })

	AAdd(aRelation,{ 'DC5_MNTVOL', 'DC5_MNTVOL' })
	AAdd(aRelation,{ 'DC5_UPDEND', 'DC5_UPDEND' })
	AAdd(aRelation,{ 'DC5_UPDPRD', 'DC5_UPDPRD' })
	AAdd(aRelation,{ 'DC5_DISSEP', 'DC5_DISSEP' })
	AAdd(aRelation,{ 'DC5_MNTEXC', 'DC5_MNTEXC' })
	AAdd(aRelation,{ 'DC5_IMPETI', 'DC5_IMPETI' })
	AAdd(aRelation,{ 'DC5_BXESTO', 'DC5_BXESTO' })

	oModel:SetRelation( "MdGridIDC5", aRelation, DC5->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridIDC5" ):SetUniqueLine( {'DC5_TAREFA'} )
Return ( oModel )

/*---------------------------------------------------------------------------
---ViewDef
---Exibe browse de acordo com a estrutura
---Mauro Paladini 23/08/2013
---------------------------------------------------------------------------*/
Static Function ViewDef()
Local nX       := 1
Local oModel   := FwLoadModel("WMSA070")
Local oView    := Nil

Local oStruCDC5 := FwFormStruct( 2, "DC5" , { |cCampo| aScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
Local oStruIDC5 := FwFormStruct( 2, "DC5" )

Local lRastro   := (SuperGetMV("MV_RASTRO") == "S")
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)

	For nX := 1 To Len(aCposCab)
		oStruIDC5:RemoveField( aCposCab[nX] )
	Next nX

	If !lRastro
		oStruIDC5:RemoveField('DC5_BLQLOT')
	EndIf
	If !lWmsNew .Or. (nModulo != 39 .And. nModulo != 42)
		oStruIDC5:RemoveField('DC5_MLTATI')
		oStruIDC5:RemoveField('DC5_OPERAC')
		oStruIDC5:RemoveField('DC5_DESOPE')

		oStruCDC5:RemoveField('DC5_MNTVOL')
		oStruCDC5:RemoveField('DC5_UPDEND')
		oStruCDC5:RemoveField('DC5_UPDPRD')
		oStruCDC5:RemoveField('DC5_DISSEP')
		oStruCDC5:RemoveField('DC5_MNTEXC')
		oStruCDC5:RemoveField('DC5_IMPETI')
		oStruCDC5:RemoveField('DC5_BXESTO')
	EndIf

	oView := FwFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VwFieldCDC5', oStruCDC5 , 'MdFieldCDC5')
	oView:AddGrid( 'VwGridIDC5', oStruIDC5 , 'MdGridIDC5')

	oView:CreateHorizontalBox("SUPERIOR",IIf(lWmsNew,45,30))
	oView:CreateHorizontalBox("INFERIOR",IIf(lWmsNew,55,70))

	oView:EnableTitleView('VwFieldCDC5',STR0011 ) // Serviço
	oView:EnableTitleView('VwGridIDC5',STR0012)   // Tarefas

	oView:AddIncrementField( 'VwGridIDC5', 'DC5_ORDEM' )

	oView:SetOwnerView("VwFieldCDC5","SUPERIOR")
	oView:SetOwnerView("VwGridIDC5","INFERIOR")
Return(oView)
/*---------------------------------------------------------------------------
---MenuDef
---MenuDef com as rotinas do Browse
---Mauro Paladini 14/08/2013
---------------------------------------------------------------------------*/
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.WMSA070" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.WMSA070" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.WMSA070" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.WMSA070" OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0013    ACTION "VIEWDEF.WMSA070" OPERATION 9 ACCESS 0 // Copiar
	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("DLG070MNU")
		ExecBlock("DLG070MNU",.F.,.F.)
	EndIf
Return ( aRotina )

/*---------------------------------------------------------------------------
---PosVldMdl
---Funcao de validacao da model (compatibilizacao)
---Mauro Paladini 27/08/2013
---oModel, Onjeto, (Objeto do modelo de dados)
---------------------------------------------------------------------------*/
Static Function PosVldMdl(oModel)
Local oMdlDC5Fld := oModel:GetModel("MdFieldCDC5")
Local oMdlDC5Grd := oModel:GetModel("MdGridIDC5")
Local oView      := FWViewActive()
Local lRet       := .T.
Local lAchou     := .F.
Local lOutTip    := .F.
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local cLibPed    := ""
Local cMntVol    := ""
Local cCofExp    := ""
Local cDisSep    := ""
Local nI         := 0
Local nOrdem     := 0
Local nAchou     := 0
Local aLibPed    := {}
Local cAliasQry  := ""
Local cQuery     := ""
Local aMvAtivid  := {}
Local cAtivid    := ""
Local nX         := 0
Local nAtivApo   := 0
Local nAtivChg   := 0
Local nLenDC5Grd := 0
Local cTipoAglut := ""

	If oModel <> Nil
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			lRet := WMSA070DEL()
		ElseIf ( oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() ==  MODEL_OPERATION_UPDATE )
			lRet := WMA70TudOk( oModel:GetOperation() )
			If lRet .And. (nModulo == 39 .Or. nModulo == 42)
				// Verifica se tipo de serviço e operação estão respeitando a regra
				If lWmsNew
					If oMdlDC5Fld:GetValue("DC5_TIPO") == '1'
						For nI := 1 To oMdlDC5Grd:Length()
							oMdlDC5Grd:GoLine(nI)
							If !oMdlDC5Grd:isdeleted(nI)
								If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "1|2|6"
									lAchou := .T.
								EndIf
								If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "3|4|5|7|8"
									lOutTip := .T.
									Exit
								EndIf
							EndIf
						Next nI
						If lOutTip
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07045,STR0068,STR0069) // Existe tarefa cadastrada com operação diferente da definida para o tipo de serviço! // Informe a operação com uma das opções (0-Customizada/1-Endereçamento/2-Endereçamento Crossdocking/6-Conferência de entrada).
							lRet := .F.
						EndIf
						If lRet .And. !lAchou
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07040,STR0062,STR0067) // Não há operação de endereçamento definido para o tipo de serviço! // Informe pelo menos uma operação com uma das opções (1-Endereçamento/2-Endereçamento Crossdocking/6-Conferência de entrada).
							lRet := .F.
						EndIf
					ElseIf oMdlDC5Fld:GetValue("DC5_TIPO") == '2'

						If oMdlDC5Fld:GetValue("DC5_COFEXP") == '1' .And. (oMdlDC5Fld:GetValue("DC5_MNTEXC") == '1' .Or. oMdlDC5Fld:GetValue("DC5_MNTEXC") == '3')//Conf Exped / Carga Pedido / Loja Cliente
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If !oMdlDC5Grd:isdeleted(nI)
									If oMdlDC5Fld:GetValue("DC5_MNTVOL") == "1" .And. oMdlDC5Grd:GetValue("DC5_OPERAC") == "3"
										cTipoAglut := Posicione("DC6",1,xFilial("DC6")+oMdlDC5Grd:GetValue("DC5_TAREFA"),"DC6_TPAGLU")
										If cTipoAglut != "1" .And. cTipoAglut != "2" //1 - Nao Aglutina, 2 - Documento
											//"Não é possível configurar o serviço com conferência de expedição, informando a montagem de volume '1 - Por Carga/Pedido' ou '3 - Por Loja Cliente' e que tenha a tarefa aglutinando a separação que não seja por '2 - Documento'. O processo de conferência de expedição no serviço não atende a essa configuração."
											//"Informe a montagem de volume no serviço '2 - Por Pedido' ou altere a tarefa para o tipo de aglutinação para '2 - Documento'."
											oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07051,STR0077,STR0078) 
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
							Next nI					
						EndIf
						If lRet
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If !oMdlDC5Grd:isdeleted(nI)
									If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "0|3|4|7"
										lAchou := .T.
									EndIf
									If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "1|2|5|6|8"
										lOutTip := .T.
										Exit
									EndIf
								EndIf
							Next nI
						EndIf
						If lRet .And. lOutTip
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07046,STR0068,STR0070) // Existe tarefa cadastrada com operação diferente da definida para o tipo de serviço! // Informe a operação com uma das opções (0-Customizada/3-Separação/4-Separação Crossdocking/7-Conferência de saída).
							lRet := .F.
						EndIf
						If lRet .And. !lAchou
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07041,STR0063,STR0066) // Não há operação de separação definido para o tipo de serviço! // Informe pelo menos uma operação com uma das opções (3-Separação/4-Separação Crossdocking/7-Conferência de saída).
							lRet := .F.
						EndIf
					ElseIf oMdlDC5Fld:GetValue("DC5_TIPO") == '3'
						For nI := 1 To oMdlDC5Grd:Length()
							oMdlDC5Grd:GoLine(nI)
							If !oMdlDC5Grd:isdeleted(nI)
								If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "0|5|8"
									lAchou := .T.
									nAchou ++
								EndIf
								If oMdlDC5Grd:GetValue("DC5_OPERAC") $ "1|2|3|4|7"
									lOutTip := .T.
									Exit
								EndIf
							EndIf
						Next nI
						If lOutTip
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07047,STR0068,STR0071) // Existe tarefa cadastrada com operação diferente da definida para o tipo de serviço! // Informe a operação com uma das opções (0-Customizada/5-Abastecimento/6-Conferência de entrada/8-Tranferência).
							lRet := .F.
						EndIf
						If lRet .And. !lAchou
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07043,STR0064,STR0065) // Não há operação de movimento interno definido para o tipo de serviço! // Informe somente uma operação com uma das opções (5-Abastecimento/8-Tranferência).
							lRet := .F.
						EndIf
						If lRet .And. nAchou > 1
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07048,STR0072,STR0065) // Há mais de uma operação de movimento interno definido para o tipo de serviço! // Informe somente uma operação com uma das opções (5-Abastecimento/8-Tranferência).
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If lRet
					lAchou  := .F.
					cLibPed := oMdlDC5Fld:GetValue("DC5_LIBPED")
					cCofExp := oMdlDC5Fld:GetValue("DC5_COFEXP")
					cMntVol := Iif(lWmsNew,oMdlDC5Fld:GetValue("DC5_MNTVOL"),"0")
					cDisSep := Iif(lWmsNew,oMdlDC5Fld:GetValue("DC5_DISSEP"),"2")
					aLibPed := RetSx3Box(Posicione("SX3",2,"DC5_LIBPED","X3CBox()"),,,1)
					// Liberação na conferência expedição ou manual, a conferência expedição deve estar habilitada
					If lRet .And. cLibPed $ "34" .And. cCofExp != "1"
						oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0036,{{"[VAR01]",aLibPed[Val(cLibPed),1]}}),STR0037) // Para liberação de pedido ([VAR01]) a conferência de expedição deve ser habilitada. // A conferência de expedição será habilitada.
						oMdlDC5Fld:SetValue("DC5_COFEXP","1")
						lRet := .F.
					EndIf
					If lWmsNew
						// Liberação nas tarefas de separação ou conferência ou conferência de expedição ou manual, não pode ter montagem de volumes
						If lRet .And. cLibPed $ "1234" .And. (cMntVol != "0" .And. !Empty(cMntVol))
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07022,WmsFmtMsg(STR0032,{{"[VAR01]",aLibPed[Val(cLibPed),1]}}),STR0033) // Para liberação de pedido ([VAR01]) a montagem de volume não pode ser habilitada.
							oMdlDC5Fld:SetValue("DC5_MNTVOL","0")
							lRet := .F.
						EndIf
						// Liberação na montagem de volumes ou via romaneio, a montagem de volumes deve estar habilitada
						If lRet .And. cLibPed $ "56" .And. cMntVol == "0"
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0038,{{"[VAR01]",aLibPed[Val(cLibPed),1]}}),STR0039) // Para liberação de pedido ([VAR01]) a montagem de volume deve ser habilitada. // A montagem de volume será habilitada.
							oMdlDC5Fld:SetValue("DC5_MNTVOL","2")
							lRet := .F.
						EndIf
						If lRet .And. cLibPed == "2"
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If !oMdlDC5Grd:isdeleted(nI)
									If oMdlDC5Grd:GetValue("DC5_OPERAC") == '7' // Se a operação for de conferência de saída
										lAchou := .T.
										Exit
									EndIf
								EndIf
							Next nI
							If !lAchou
								oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0034,{{"[VAR01]",aLibPed[Val(cLibPed),1]}}),STR0050) // Para liberação de pedido ([VAR01]) é preciso uma tarefa de conferência de expedição definida. // Cadastre uma tarefa de conferência com a função DLConfSai().
								lRet := .F.
							EndIf
						EndIf
						// Valida se a distribuição de separação ocorre junto com a montagem de volume durante a separação
						If lRet .And. cDisSep == "1" .And. cMntVol == "1"
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07044,STR0059,STR0060) // Durante a separação na montagem do volume, a distribuição de separação não pode ser habilitada. // A distribuição da separação será desabilitada.
							oMdlDC5Fld:SetValue("DC5_DISSEP","2")
							lRet := .F.
						EndIf
						If lRet
							//Verifica operação customizada e função de execução
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If oMdlDC5Grd:GetValue("DC5_OPERAC") == '0' .And. Empty(oMdlDC5Grd:GetValue("DC5_FUNEXE"))
									oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07039,STR0058) // Para operações customizadas é necessário informar a função de execução.
									lRet := .F.
									Exit
								EndIf
							Next nI
							//Verifica campo de baixa de estoque na requsição (DC5_BXESTO)
							//Só permite a baixa de estoque permaneça como "sim" se houver uma operação de separação
							If lRet .And. oModel:GetModel():GetValue('MdFieldCDC5','DC5_TIPO') == '2' .And.  oMdlDC5Fld:GetValue("DC5_BXESTO") == "1"
								lAchou := .F.
								For nI := 1 To oMdlDC5Grd:Length()
									oMdlDC5Grd:GoLine(nI)
									If !oMdlDC5Grd:isdeleted(nI) .And. oMdlDC5Grd:GetValue("DC5_OPERAC") == '3'
										lAchou := .T.
										Exit
									EndIf
								Next nI
								//Se é um serviço de saída marcada para baixar estoque mas sem um serviço de separação, grava o campo de baixa de estoque como não
								If !lAchou
									oMdlDC5Fld:LoadValue("DC5_BXESTO","2")
								EndIf
							EndIf
						EndIf
					Else
						// Liberação na tarefa de conferência, a função DLConfSai deve estar cadastrada
						If lRet .And. cLibPed == "2"
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If !oMdlDC5Grd:isdeleted(nI)
									If 'DLCONFSAI' $ Upper(Tabela("L6",oMdlDC5Grd:GetValue("DC5_FUNEXE"),.F.))
										lAchou := .T.
										Exit
									EndIf
								EndIf
							Next nI
							If !lAchou
								oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0034,{{"[VAR01]",aLibPed[Val(cLibPed),1]}}),STR0035) // Para liberação de pedido ([VAR01]) é preciso uma tarefa de conferência de expedição definida. // Cadastre uma tarefa de conferência com a função DLConfSai().
								lRet := .F.
							EndIf
						EndIf
						lAchou := .F.
						If lRet
							For nI := 1 To oMdlDC5Grd:Length()
								oMdlDC5Grd:GoLine(nI)
								If !oMdlDC5Grd:isdeleted(nI)
									If 'DLAPANHEVL' $ Upper(Tabela("L6",oMdlDC5Grd:GetValue("DC5_FUNEXE"),.F.)) .Or.;
									   'DLAPANHEC2' $ Upper(Tabela("L6",oMdlDC5Grd:GetValue("DC5_FUNEXE"),.F.))
										lAchou := .T.
										Exit
									EndIf
								EndIf
							Next nI
							// Quando possuir montagem de volumes, só poderá realizar a liberação do pedido ao final deste processo
							If cLibPed $ "1234" .And. lAchou
								oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07022,WmsFmtMsg(STR0032,{{"[VAR01]",aLibPed[Val(cLibPed),1]}})) // Para liberação de pedido ([VAR01]) a montagem de volume não pode ser habilitada.
								lRet := .F.
							EndIf
							// Para liberação na montagem de volumes, a mesma deve estar habilitada
							If cLibPed == "6" .And. !lAchou
								oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0038,{{"[VAR01]",aLibPed[Val(cLibPed),1]}})) // Para liberação de pedido ([VAR01]) a montagem de volume deve ser habilitada.
								lRet := .F.
							EndIf
						EndIf
						// No WMS Atual não é permitido parametrizar liberação de pedido no romaneio de embarque
						If lRet .And. cLibPed == "5"
							oModel:SetErrorMessage('MdFieldCDC5',,,,WMSA07023,WmsFmtMsg(STR0061,{{"[VAR01]",aLibPed[Val(cLibPed),1]}})) // Atualmente a liberação de pedido ([VAR01]) não está disponível para utilização.
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet .And. nModulo == 43
				//--- Controle de Chegada/Saida de Cliente x Apoio
				aMvAtivid:=	WMSA070TMS()

				For nX := 1 To Len(aMvAtivid)
					If !Empty(aMvAtivid[nx])
						cAtivid +=  "'" + aMvAtivid[nx] + "', "
					EndIf
				Next nX

				If !Empty(cAtivid)
					cAtivid := Substr(cAtivid, 1, Rat(",", cAtivid)-1)
				EndIf

				If !Empty(cAtivid)
					nLenDC5Grd:= oMdlDC5Grd:Length()

					For nI := 1 To nLenDC5Grd
						oMdlDC5Grd:GoLine(nI)
						If !oMdlDC5Grd:IsDeleted(nI)
							cAliasQry:= GetNextAlias()
							cQuery := " SELECT DC6.DC6_TAREFA, DC6.DC6_ATIVID "
							cQuery += " FROM " + RetSqlName("DC6") + " DC6 "
							cQuery += " WHERE DC6.DC6_FILIAL = '" + xFilial("DC6") + "'
							cQuery += " AND DC6.DC6_TAREFA = '" + oMdlDC5Grd:GetValue("DC5_TAREFA") + "'"
							cQuery += " AND DC6.DC6_ATIVID IN  ( "+ cAtivid + ")"
							cQuery += " AND DC6.D_E_L_E_T_ = ' ' "
							cQuery += " GROUP BY DC6.DC6_TAREFA, DC6.DC6_ATIVID  "
							cQuery := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
							While (cAliasQry)->(!Eof())

								If (cAliasQry)->DC6_ATIVID $  aMvAtivid[1] + " | " + aMvAtivid[2]
									nAtivChg++
									If nAtivApo > 0
										lRet:= .F.
									EndIf
								ElseIf (cAliasQry)->DC6_ATIVID $  aMvAtivid[3] + " | " + aMvAtivid[4]
									nAtivApo++
									If nAtivChg > 0
										lRet:= .F.
									EndIf
								EndIf
								If M->DC5_SERTMS ==  StrZero(2,Len(DC5->DC5_SERTMS))
									lRet := .F.
								EndIf

								If !lRet
									nI:= nLenDC5Grd + 1
								EndIf

								(cAliasQry)->(dbSkip())
							EndDo
							(cAliasQry)->(dbCloseArea())
						EndIf
					Next nI
				EndIf

				//Não sera permitido selecionar Atividade de Saida/Chegada de Cliente x Atividade de Saida/Chegada de Apoio na mesma TAREFA
				If !lRet
					If M->DC5_SERTMS ==  StrZero(2,Len(DC5->DC5_SERTMS))
						//'Não é permitido selecionar Tarefa de Saida/Chegada em Cliente para este Serviço de Transporte.','Verifique a Tarefa: '
						oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07050, Iif(Len(aMvAtivid)>=3 .And. Empty(aMvAtivid[3]), STR0073, STR0076 ),STR0074 + oMdlDC5Grd:GetValue("DC5_TAREFA")  )
					EndIf
					//"Não é permitido selecionar Tarefa de Saida/Chegada de Cliente e Tarefa de Saida/Chegada de Apoio para o mesmo Serviço."
					oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07050,STR0075,STR0074 + oMdlDC5Grd:GetValue("DC5_TAREFA"))
				EndIf

				aMvAtivid:= aSize(aMvAtivid,0)
			EndIf

			//Ordena serviços
			If lRet
				For nI := 1 To oMdlDC5Grd:Length()
					oMdlDC5Grd:GoLine( nI )
					If !oMdlDC5Grd:IsDeleted()
						nOrdem++
						oMdlDC5Grd:SetValue("DC5_ORDEM",StrZero(nOrdem, 2))
					EndIf
				Next nI
			EndIf
			If !(oView == Nil)
				oView:Refresh()
			EndIf
		EndIf
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMSA070DEL
---Validacao da exclusao
---VICCO 01/12/2009
---------------------------------------------------------------------------*/
Static Function WMSA070DEL()
Local aArea     := GetArea()
Local cQuery    := ""
Local lRet      := .T.
Local cAliasNew := ""
Local cAliasDUX := ""
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

	DCG->(dbSetOrder(1)) // DCG_FILIAL+DCG_PRODUTO+DCG_SERVIC
	cAliasNew := GetNextAlias()
	cQuery := " SELECT 1"
	cQuery +=   " FROM "+ RetSqlName("DCG")+" DCG"
	cQuery +=  " WHERE DCG.DCG_FILIAL = '"+xFilial("DCG")+"'"
	cQuery +=    " AND DCG.DCG_SERVIC = '"+M->DC5_SERVIC+"'"
	cQuery +=    " AND DCG.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->(!EOF())
		WmsMessage(STR0017,WMSA07005,,,,STR0018) // Produto não poderá ser excluído. // Verificar o cadastro de Produtos x Serviços do WMS.
		lRet := .F.
	EndIf
	dbSelectarea(cAliasNew)
	dbCloseArea()

	If nModulo == 43 // TMS
		DUX->(dbSetOrder(4)) // DUX_FILIAL+DUX_SERVIC
		cAliasDUX := GetNextAlias()
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+ RetSqlName("DUX")+" DUX"
		cQuery +=  " WHERE DUX.DUX_FILIAL = '"+xFilial("DUX")+"'"
		cQuery +=    " AND DUX.DUX_SERVIC = '"+M->DC5_SERVIC+"'"
		cQuery +=    " AND DUX.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUX,.F.,.T.)
		If (cAliasDUX)->(!EOF())
			WmsMessage(STR0049,WMSA07024,5) // Nao foi possivel excluir este servico, pois esta vinculado em um Contrato de Cliente.
			lRet := .F.
		EndIf
		dbSelectarea(cAliasDUX)
		dbCloseArea()
	Endif

	If lRet
		If !lWmsNew
			SDB->(dbSetOrder(3)) // DB_FILIAL+DB_SERVIC+DB_TAREFA_DB_ATIVID
			If SDB->(dbSeek(xFilial("SDB")+M->DC5_SERVIC))
				WmsMessage(STR0019,WMSA07006,5 /*MSG_HELP*/) // Não foi possível excluir este serviço, pois já foram executadas operações com esta configuração.
				lRet := .F.
			EndIf
		Else
			D12->(dbSetOrder(2)) // D12_FILIAL+D12_SERVIC+D12_TAREFA+D12_ATIVID
			If D12->(dbSeek(xFilial("D12")+M->DC5_SERVIC))
				WmsMessage(STR0019,WMSA07006,5 /*MSG_HELP*/) // Não foi possível excluir este serviço, pois já foram executadas operações com esta configuração.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return lRet

/*---------------------------------------------------------------------------
---WMA70TudOk
---Valida o Cadastro antes da Gravacao
---Fernando Joly Siquini 27/07/2001
---nOpcx, Numerico, (Operação)
---------------------------------------------------------------------------*/
Function WMA70TudOk(nOpcx)
Local lRet := .T.
	If lRet .And. nModulo == 43 // TMS
		// Categoria de Negociacao, eh obrigatorio o preenchimento do servico operacional
		If M->DC5_CATSER == StrZero( 1, Len( DC5->DC5_CATSER ) )
			If Empty( M->DC5_SEROPE )
				WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",RetTitle( "DC5_SEROPE" )}}),WMSA07007,5 /*MSG_HELP*/) // Campo [VAR01] obrigatório não foi preenchido no objeto Grid.
				lRet := .F.
			EndIf
		EndIf

		// Validacao de campos que sao obrigatorios somente para o TMS.
		If Empty( M->DC5_SERTMS )
			WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",RetTitle( "DC5_SERTMS" )}}),WMSA07009,5 /*MSG_HELP*/) // Campo [VAR01] obrigatório não foi preenchido no objeto Grid.
			lRet := .F.
		EndIf

		If Empty( M->DC5_TIPTRA )
			WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",RetTitle( "DC5_TIPTRA" )}}),WMSA07010,5 /*MSG_HELP*/) // Campo [VAR01] obrigatório não foi preenchido no objeto Grid.
			lRet := .F.
		EndIf

		If Empty( M->DC5_CATSER )
			WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",RetTitle( "DC5_CATSER" )}}),WMSA07011,5 /*MSG_HELP*/) // Campo [VAR01] obrigatório não foi preenchido no objeto Grid.
			lRet := .F.
		EndIf

		// Posiciona novamente, pois o campo DC5_SEROPE pode ter desposicionado
		If lRet .And.  !Inclui
			DC5->(dbSetOrder(1))
			DC5->(MsSeek(xFilial('DC5')+M->DC5_SERVIC))
		EndIf
		DU4->(DbSetOrder(1))
		If lRet .And. !Empty(M->DC5_TABSEG+M->DC5_TPTSEG) .And.;
			!DU4->(MsSeek(xFilial("DU4")+M->DC5_TABSEG+M->DC5_TPTSEG))
			WmsMessage(STR0021,WMSA07012,5 /*MSG_HELP*/) // Tabela de Seguro nao localizada.
			lRet := .F.
		EndIf
	EndIf
	// Integracao com o Modulo de Transporte (TMS)
	If lRet .And. nOpcx == 5 .And. nModulo == 43 // TMS
		DA8->(dbSetOrder(4))
		If DA8->(MsSeek(xFilial('DA8')+ M->DC5_SERTMS + M->DC5_TIPTRA + M->DC5_SERVIC))
			WmsMessage(STR0022,WMSA07013,,,,STR0023) // Este serviço não pode ser excluído, pois está relacionado a uma rota. // Exclua antes a rota associada a este serviço.
			lRet := .F.
		EndIf
		If lRet
			DUX->(DbSetOrder(4))
			IF DUX->(MsSeek(xFilial("DUX")+ M->DC5_SERVIC))
				WmsMessage(STR0031,WMSA07014,5/*MSG_HELP*/) // O serviço encontra-se vinculado a um contrato.
				lRet := .F.
			EndIF
		EndIF
	EndIf
Return lRet
/*-----------------------------------------------------------------------------
---WMSA070XBI
---Chama a rotina de Inclusao de Servicos x Tarefa
---Patricia A. Salomao 04/04/2002
-----------------------------------------------------------------------------*/
Function WMSA070XBI()
Local lGetD  := Type("n")=="N"
Local nLinha := 0
	If lGetD
		nLinha := n
		n := 1
	EndIf

	WMSA070(,3)

	If lGetD
		n := nLinha
	EndIf
Return

/*-----------------------------------------------------------------------------
---WMSA070XBV
---Chama a rotina de Visualizacao de Servicos x Tarefa
---Patricia A. Salomao 04/04/2002
-----------------------------------------------------------------------------*/
Function WMSA070XBV()
Local lGetD  := Type("n")=="N"
Local nLinha := 0
	If lGetD
		nLinha := n
		n := 1
	EndIf

	WMSA070(,2)

	If lGetD
		n := nLinha
	EndIf
Return

//----------------------------------------------------------------------------//
// Função responsável pela validação dos campos
//----------------------------------------------------------------------------//
Function WMS070VFld(oModel,cField,xValue)
Local lRet    := .T.
Local cFuncao := ""

	If SuperGetMv("MV_WMSNEW",.F.,.F.) //Validações novo WMS
		If cField == "DC5_FUNEXE"
			//Para o novo WMS, só é permitida a inforamação do função de execução quando o tipo de operação (DC5_FUNEXE) for "0"
			If !Empty(xValue) .And. oModel:GetValue("DC5_OPERAC") != "0"
				WmsMessage(STR0051,WMSA07025) //Para informar a função de execução somente a operação customizada deve ser utilizada.
				oModel:SetValue("DC5_OPERAC","0")
			EndIf
		ElseIf cField == "DC5_BLQLOT"
			If xValue == "1"
				If oModel:GetValue("DC5_OPERAC") != "1" .And. oModel:GetValue("DC5_OPERAC") != "2" //Se a operação for diferente de Endereçamento e Endereçamento Crossdocking
					oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07037,STR0057,STR0052) // Operação inválida. Para bloqueio de lote somente operações de endereçamento podem ser utilizadas.
					lRet := .F.
				EndIf
			EndIf
		ElseIf cField == "DC5_MLTATI"
			If xValue == "1"
				If  oModel:GetValue("DC5_OPERAC") != '3' .And. oModel:GetValue("DC5_OPERAC") != '4' //Se a operação for diferente de Separação e Separação Crossdocking
					oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07038,STR0057,STR0053) // Operação inválida. //Para multipla atividades automatica até a norma somente operações de separação podem ser utilizadas.
					lRet := .F.
				EndIf
			EndIf
		ElseIf cField == "DC5_OPERAC"
			If !Empty(xValue) .And. oModel:GetValue("DC5_BLQLOT") == "1"
				If M->DC5_OPERAC != '1' .And. M->DC5_OPERAC != '2' //Se a operação for diferente de Endereçamento e Endereçamento Crossdocking
					oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07032,STR0057,STR0052) // Operação inválida. // Para bloqueio de lote somente operações de endereçamento podem ser utilizadas.
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(xValue) .And. oModel:GetValue("DC5_MLTATI") == "1"
					If  M->DC5_OPERAC != "3" .And. M->DC5_OPERAC != "4" //Se a operação for diferente de Separação e Separação Crossdocking
						oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07033,STR0057,STR0053) // Operação inválida. // Para multipla atividades automatica até a norma somente operações de separação podem ser utilizadas.
						lRet := .F.
					EndIf
				EndIf
			EndIf
			If !Empty(xValue) .And. xValue != "0" .And. !Empty(oModel:GetValue("DC5_FUNEXE"))
				WmsMessage(STR0054,WMSA07034) //Para informar a operação diferente de 'Customizado' a função de execução não deve ser informada.
				oModel:LoadValue("DC5_FUNEXE","")
			EndIf
		EndIf
	Else //Validações do WMS atual
		If cField == "DC5_FUNEXE"
			If !Empty(xValue) .And. !ExistCpo("SX5","L6"+M->DC5_FUNEXE)
				lRet := .F.
			EndIf
			If 'DLCONFEREN' $ Upper(Tabela("L6",M->DC5_FUNEXE,.F.))
				// Apenas mensagem informativa
				WmsMessage("A função DLConferen() foi descontinuada e não receberá mais melhorias. Recomenda-se a utilização da função DLConfEnt() para serviços de endereçamento e a função DLConfSai() para serviços de expedição.",WMSA07049,1)
			EndIf
			If lRet
				If !Empty(xValue) .And. oModel:GetValue("DC5_BLQLOT") == "1"
					cFuncao := Upper(Tabela("L6",xValue))
					If !('DLENDERECA' $ cFuncao .Or. 'DLCROSSDOC' $ cFuncao)
						oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07026,STR0026,STR0040) // Serviço inválido. // Para bloqueio de lote somente serviço de endereçamento pode ser usado.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf cField == "DC5_BLQLOT"
			If xValue == "1"
				cFuncao := Upper(Tabela("L6",oModel:GetValue("DC5_FUNEXE")))
				If !('DLENDERECA' $ cFuncao .Or. 'DLCROSSDOC' $ cFuncao)
					oModel:GetModel():SetErrorMessage('MdGridIDC5',,,,WMSA07029,STR0026,STR0040) // Serviço inválido. Para bloqueio de lote somente serviço de endereçamento pode ser usado.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	//Validações genéricas (WMS Atual e Novo WMS)
	If cField == "DC5_SEROPE"
		DC5->( DbSetOrder( 1 ) )
		If DC5->( !MsSeek( xFilial('DC5')+M->DC5_SEROPE ) )
			oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07015,STR0024,STR0025) // Não existe registro relacionado a este código. // Informe um código que exista no cadastro de serviços e tenha categoria 'Operacional'.
			lRet := .F.
		EndIf
		If lRet .And. DC5->DC5_CATSER == StrZero( 1, Len( DC5->DC5_CATSER ) ) // Negociacao
			oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07016,STR0026,STR0027) // Serviço inválido. // Informe um serviço operacional.
			lRet := .F.
		EndIf
		If lRet .And. DC5->DC5_SERTMS != M->DC5_SERTMS
			oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07017,STR0026,STR0028) // Serviço inválido. // Informe um serviço com o mesmo serviço de transporte informado.
			lRet := .F.
		EndIf
		If lRet .And. DC5->DC5_TIPTRA != M->DC5_TIPTRA
			oModel:getModel():SetErrorMessage('MdFieldCDC5',,,,WMSA07018,STR0026,STR0029) // Serviço inválido.  // Informe um serviço com o mesmo tipo de transporte informado
			lRet := .F.
		EndIf
	ElseIf cField == "DC5_TABSEG"
		If Vazio()
			M->DC5_TPTSEG := CriaVar("DC5_TPTSEG",.F.)
		Else
			lRet := (ExistCpo('DU4') .And. TMSTbAtiva(M->DC5_TABSEG,M->DC5_TPTSEG,,.T.))
		EndIf
	ElseIf cField == "DC5_TPTSEG"
		If Vazio()
			M->DC5_TABSEG := CriaVar("DC5_TABSEG",.F.)
		Else
			lRet := (ExistCpo('DU4',M->DC5_TABSEG+M->DC5_TPTSEG) .And. TMSTbAtiva(M->DC5_TABSEG,M->DC5_TPTSEG,,.T.))
		EndIf
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WmA070Cpo
---Valida os campos definidos pelo Ponto de entrada WmA070ENC
---Alex Egydio 11/02/2005
---aRetPE, Record, (Campos definidos pelo ponto de entrada DLA070ENC)
---aCposCab, Record, (Campos que nao serao apresentados na GetDados)
---------------------------------------------------------------------------*/
Static Function WmA070Cpo(aRetPE,aCposCab)
Local oStructDC5 := FwFormStruct(2,"DC5") // Engloba campos reais, virtuais e de usuário
Local aFieldsDC5 := oStructDC5:aFields
Local nI         := 0

	For nI := 1 To Len(aRetPE)
		// Verifica se retornou o código do campo em formato Caracter
		If ValType(aRetPE[nI]) != "C"
			WmsMessage(STR0007,WMSA07002) // O vetor retornado pelo ponto de entrada DLA070ENC nao foi definido corretamente
			Exit
		EndIf
		// Verifica se o campo retornado pelo PE existe na estrutura da DC5
		If AScan(aFieldsDC5,{|x| AllTrim(x[1]) == AllTrim(aRetPE[nI])}) <= 0
			WmsMessage( WmsFmtMsg(STR0009,{{"[VAR01]",aRetPE[nI]}}),WMSA07003 ) // O campo [VAR01] retornado pelo ponto de entrada DLA070ENC nao foi definido no dicionario de dados SX3
			Exit
		EndIf
		AAdd(aCposCab,aRetPE[nI])
	Next

Return
/*--------------------------------------------------------------------------
---WRetMvcOpc
---Retorna a opcao equivalente para a chamada da View em MV
---Mauro Paladini 27/08/2013
---nOpcRot, Numerico, (Opcao do aRotina 2-Visualizar,3-Incluir,4-Alterar)
--------------------------------------------------------------------------*/
Function WRetMvcOpc( nOpcRot )
Local aRet  := {}

Default nOpcRot := 0
	aRet := { 0,"" }

	If nOpcRot == 2
		aRet[1]  := MODEL_OPERATION_VIEW
		aRet[2]  := STR0003 // Visualizar
	Elseif nOpcRot == 3
		aRet[1]  := MODEL_OPERATION_INSERT
		aRet[2]  := STR0004 // Incluir
	Elseif nOpcRot == 4
		aRet[1]  := MODEL_OPERATION_UPDATE
		aRet[2]  := STR0005 // Alterar
	Elseif nOpcRot == 5
		aRet[1]  := MODEL_OPERATION_DELETE
		aRet[2]  := STR0014 // Deletar
	Elseif nOpcRot == 6
		aRet[1]  := MODEL_OPERATION_ONLYUPDATE
		aRet[2]  := STR0015  // Atualizar
	Else
		WmsMessage(STR0016,WMSA07020,5/*MSG_HELP*/) // Opção inválida informada na chamada da função.
	EndIf
Return aRet

//----------------------------------------------------------------------------//
// Retorna descrição da tarefa para o Grid
//----------------------------------------------------------------------------//
Function Wms070GetD(oModel,cField)
Local nLinha := oModel:GetQtdLine()
Local cRet   := ""
	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha > 0
		cRet := ""
	Else
		If cField == "DC5_DESTAR"
			cRet := Iif(Inclui,"",Tabela("L2",DC5->DC5_TAREFA,.F.))
		EndIf
		If cField == "DC5_DESOPE"
			cRet := Iif(Inclui,"",Tabela("LY",DC5->DC5_OPERAC,.F.))
		EndIf
	EndIf
Return cRet

//----------------------------------------------------------------------------//
// Função responsável por validar a edição do campo
//----------------------------------------------------------------------------//
Function Wms070WFld(oModel, cField)
Local lRet := .T.
	// Estes campos deverão estar habilitados apenas para serviços do tipo SAÍDA
	If cField == 'DC5_COFEXP' .Or. cField == 'DC5_LIBPED' .Or. cField == 'DC5_MNTVOL' .Or. cField == 'DC5_DISSEP' .Or. cField == 'DC5_BXESTO'
		If oModel:GetModel():GetValue('MdFieldCDC5','DC5_TIPO') != '2'
			lRet := .F.
		EndIf
	ElseIf cField == 'DC5_MNTEXC' .Or. cField == 'DC5_IMPETI' //Esses campos deverão ser habilitados apenas quando houver montagem de volume
		If oModel:GetModel():GetValue('MdFieldCDC5','DC5_MNTVOL') == '0' .Or. oModel:GetModel():GetValue('MdFieldCDC5','DC5_TIPO') != '2'
			lRet := .F.
		EndIf
	ElseIf cField == 'DC5_FUNEXE' // O campo de função só pode ser habilitado se a operação for zero(customizada)
		If oModel:GetModel():GetValue('MdGridIDC5','DC5_OPERAC') <> '0'
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*-----------------------------------------------------------------------------
---WMSA070TMS
---Rotina de parametrização do TMS
---Katia 27/08/2019
----------------------------------------------------------------------------*/
Static Function WMSA070TMS()
Local aMvAtivid  := {}

aAdd(aMvAtivid,SuperGetMv('MV_ATVSAIC',,''))  //-- Atividade de Saída do cliente
aAdd(aMvAtivid,SuperGetMv('MV_ATVCHGC',,''))  //-- Atividade de Chegada em Cliente
aAdd(aMvAtivid,SuperGetMv('MV_ATVSAPA',,''))  //-- Atividade de Saida do Ponto de Apoio
aAdd(aMvAtivid,SuperGetMv('MV_ATVCHPA',,''))  //-- Atividade de Chegada no Ponto de Apoio

Return aMvAtivid
