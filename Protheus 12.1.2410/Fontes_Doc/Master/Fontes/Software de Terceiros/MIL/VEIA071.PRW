#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA071.ch"

static aColFields

/*/{Protheus.doc} VEIA071
	Controle de Atualização do veículo

	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function VEIA071()
	Local oBrowse
	Private cMotivo := "000026" // Varivel utilizada na consulta padrao de motivos (VS0)

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return

/*/{Protheus.doc} ModelDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()
	local oModel
	Local oStruVW0 := FWFormStruct( 1, 'VW0' )

	VA0710023_AddTrigger(@oStruVW0)
	oStruVW0:SetProperty('VW0_USERID', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , '__cUserId' ))
	oStruVW0:SetProperty('VW0_DATREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Date()' ))
	oStruVW0:SetProperty('VW0_HORREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Val(StrTran(Time(),":",""))' ))
	oModel := MPFormModel():New('VEIA071' )
	oModel:AddFields('MODEL_VW0', /*cOwner*/ , oStruVW0 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
	oModel:SetDescription( 'LOG' )
	oModel:GetModel( 'MODEL_VW0' ):SetDescription(STR0002)	// 'Log Atualização do Veículo'
	//oModel:InstallEvent("PADRAO",, VEIA071EVDEF():New())
	//oModel:InstallEvent("LOGEV",, MVCLogEv():New("VEIA071"))
Return oModel

Static Function AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

Function VA0710023_AddTrigger(oStruVW0)
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_CHASSI","VW0_CHAINT","VV1->VV1_CHAINT",.T.,"VV1",2,"xFilial('VV1') + FWFldGet('VW0_CHASSI')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_TRACPA","VW0_OPMENT","VVF->VVF_OPEMOV",.T.,"VVF",1,"FWFldGet('VW0_FILENT') + FWFldGet('VW0_TRACPA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_TRACPA","VW0_SNFENT","VVF->VVF_SITNFI",.T.,"VVF",1,"FWFldGet('VW0_FILENT') + FWFldGet('VW0_TRACPA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_TRACPA","VW0_SERENT","VVF->VVF_SERNFI",.T.,"VVF",1,"FWFldGet('VW0_FILENT') + FWFldGet('VW0_TRACPA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_TRACPA","VW0_NFENT" ,"VVF->VVF_NUMNFI",.T.,"VVF",1,"FWFldGet('VW0_FILENT') + FWFldGet('VW0_TRACPA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_TRACPA","VW0_TESENT","VVG->VVG_CODTES",.T.,"VVG",1,"FWFldGet('VW0_FILENT') + FWFldGet('VW0_TRACPA') + FWFldGet('VW0_CHAINT')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_NUMTRA","VW0_OPMSAI","VV0->VV0_OPEMOV",.T.,"VV0",1,"FWFldGet('VW0_FILSAI') + FWFldGet('VW0_NUMTRA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_NUMTRA","VW0_SNFSAI","VV0->VV0_SITNFI",.T.,"VV0",1,"FWFldGet('VW0_FILSAI') + FWFldGet('VW0_NUMTRA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_NUMTRA","VW0_SERSAI","VV0->VV0_SERNFI",.T.,"VV0",1,"FWFldGet('VW0_FILSAI') + FWFldGet('VW0_NUMTRA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_NUMTRA","VW0_NFSAI" ,"VV0->VV0_NUMNFI",.T.,"VV0",1,"FWFldGet('VW0_FILSAI') + FWFldGet('VW0_NUMTRA')") )
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_NUMTRA","VW0_TESSAI","VVA->VVA_CODTES",.T.,"VVA",1,"FWFldGet('VW0_FILSAI') + FWFldGet('VW0_NUMTRA') + FWFldGet('VW0_CHASSI')") )
Return

/*/{Protheus.doc} ViewDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ViewDef()
	Local oView
	Local oModel := FWLoadModel( 'VEIA071' )
	Local oStruVW0 := FWFormStruct( 2, 'VW0' , { |cField| ! (AllTrim(Upper(cField)) $ "VW0_KILOME/VW0_HORTRI/VW0_DATA/VW0_HORA/VW0_ORIGEM/VW0_FILOSV/VW0_NUMOSV") })
	//Local oStruVO0 := FWFormStruct( 2, 'VO0' , { |cField| ! (AllTrim(Upper(cField)) $ "VO0_CODVW0") })

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:CreateHorizontalBox( 'TELA_VW0' , 100 )
	oView:AddField('VIEW_VW0', oStruVW0, 'MODEL_VW0' )
	oView:SetOwnerView('VIEW_VW0','TELA_VW0')
	//oView:EnableTitleView("VIEW_VW0", FwX2Nome("VW0"))
Return oView

/*/{Protheus.doc} MenuDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA071' OPERATION 2 ACCESS 0	// 'Visualizar'
	//ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.VEIA071' OPERATION 3 ACCESS 0	// 'Incluir'
	//ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.VEIA071' OPERATION 4 ACCESS 0	// 'Alterar'
	//ADD OPTION aRotina Title 'Transmitir' Action 'OA4300013_TransmitirBlackBird' OPERATION 4 ACCESS 0
Return aRotina

/*/{Protheus.doc} BrowseDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function BrowseDef()
	Local oBrowse
	local aVW0Stru
	local nPos

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VW0')
	oBrowse:SetDescription( STR0001 )
	if aColFields == nil
		aColFields := {}
		aVW0Stru := FWFormStruct(3,"VW0")

		for nPos := 1 to Len(aVW0Stru[FORM_STRUCT_TABLE_BROWSE])
			if ! aVW0Stru[FORM_STRUCT_TABLE_BROWSE, nPos , MVC_VIEW_IDFIELD] $ "VW0_KILOME/VW0_HORTRI/VW0_DATA  /VW0_HORA  /VW0_ORIGEM/VW0_FILOSV/VW0_NUMOSV"
				AADD( aColFields , aVW0Stru[FORM_STRUCT_TABLE_BROWSE, nPos , MVC_VIEW_IDFIELD] )
			endif
		next nPos
	endif
	oBrowse:SetOnlyFields(aColFields)
	oBrowse:AddLegend( 'VW0->VW0_STSAI == "0" .OR. VW0->VW0_STENT == "0"' , 'BR_VERMELHO', STR0006 )	// "Movimento Cancelado"
	oBrowse:AddLegend( 'VW0->VW0_STSAI == "1" .OR. VW0->VW0_STENT == "1"' , 'BR_VERDE'   , STR0006 )	// "Movimento Cancelado"
	oBrowse:AddStatusColumns( { || IIF( VW0->VW0_BBINTG == "1" , "PMSRELA","" ) }, { || VA0710013_Legenda() } )
Return oBrowse

Function VA0710013_Legenda()
	Local oLegenda := FWLegend():New()
	oLegenda:Add('', " "      , STR0007) // 'Não integrado'
	oLegenda:Add('', "PMSRELA", STR0008) // 'Integrado'
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
Return Nil
