#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "OFINJD49.CH"

/*/{Protheus.doc} OFINJD49

Rotina de atualização manual de valores na solicitação de garantia 
(Mercado Internacional)

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OFINJD49()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) // "Solicitação de Garantia"
oBrowse:SetAlias('VMB')
oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('OFINJD49')

Return aRotina

/*/{Protheus.doc} ModelDef

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ModelDef()
Local oModel
Local oStrVMB    := FWFormStruct(1, "VMB" )
Local oStrVMCPEC := FWFormStruct(1, "VMC" )
Local oStrVMCSRV := FWFormStruct(1, "VMC" )
Local oStrVMCOUT := FWFormStruct(1, "VMC" )

//Alteração de estrutura de campo da Solicitação de Garantia
oStrVMB:SetProperty( "VMB_CONVAR" , MODEL_FIELD_WHEN   , {|| Alltrim(FWFldGet('VMB_TIPGAR')) == 'ZSPA' } )
oStrVMB:SetProperty( "VMB_CLIVAR" , MODEL_FIELD_WHEN   , {|| Alltrim(FWFldGet('VMB_TIPGAR')) == 'ZSPA' } )

//Alteração de estrutura de campo de Peças
oStrVMCPEC:SetProperty("VMC_FILIAL" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL")} )
oStrVMCPEC:SetProperty("VMC_CODGAR" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")} )
oStrVMCPEC:SetProperty("VMC_SEQGAR" , MODEL_FIELD_INIT , { || OFNJD15SEQ( oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL"), oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")) } )
oStrVMCPEC:SetProperty("VMC_TIPOPS" , MODEL_FIELD_INIT , { || "P"} )
oStrVMCPEC:SetProperty("VMC_TIPTEM" , MODEL_FIELD_INIT , { || OFNJD49065_TipodeTempoGarantia( oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR") ) } )
oStrVMCPEC:SetProperty("VMC_ORIGEM" , MODEL_FIELD_INIT , { || "3"} )
oStrVMCPEC:SetProperty("VMC_GRUITE" , MODEL_FIELD_VALID, { || .t. } )
oStrVMCPEC:SetProperty("VMC_GRUITE" , MODEL_FIELD_WHEN , { || oModel:GetModel( 'VMCPECA' ):IsInserted() } )
oStrVMCPEC:SetProperty("VMC_CODITE" , MODEL_FIELD_VALID, { || .t. } )
oStrVMCPEC:SetProperty("VMC_CODITE" , MODEL_FIELD_WHEN , { || oModel:GetModel( 'VMCPECA' ):IsInserted() } )

//Alteração de estrutura de campo de Serviços
oStrVMCSRV:SetProperty("VMC_FILIAL" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL")} )
oStrVMCSRV:SetProperty("VMC_CODGAR" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")} )
oStrVMCSRV:SetProperty("VMC_SEQGAR" , MODEL_FIELD_INIT , { || OFNJD15SEQ( oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL"), oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")) } )
oStrVMCSRV:SetProperty("VMC_TIPOPS" , MODEL_FIELD_INIT , { || "S"} )
oStrVMCSRV:SetProperty("VMC_ORIGEM" , MODEL_FIELD_INIT , { || "3"} )
oStrVMCSRV:SetProperty("VMC_GRUSER" , MODEL_FIELD_WHEN , { || oModel:GetModel( 'VMCSERV' ):IsInserted() } )
oStrVMCSRV:SetProperty("VMC_CODSER" , MODEL_FIELD_WHEN , { || oModel:GetModel( 'VMCSERV' ):IsInserted() } )

//Alteração de estrutura de campo de Outros Créditos
oStrVMCOUT:SetProperty("VMC_FILIAL" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL")} )
oStrVMCOUT:SetProperty("VMC_CODGAR" , MODEL_FIELD_INIT , { || oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")} )
oStrVMCOUT:SetProperty("VMC_SEQGAR" , MODEL_FIELD_INIT , { || OFNJD15SEQ( oModel:GetModel("VMBMASTER"):GetValue("VMB_FILIAL"), oModel:GetModel("VMBMASTER"):GetValue("VMB_CODGAR")) } )
oStrVMCOUT:SetProperty("VMC_TIPOPS" , MODEL_FIELD_INIT , { || "O"} )
oStrVMCOUT:SetProperty("VMC_ORIGEM" , MODEL_FIELD_INIT , { || "3"} )
oStrVMCOUT:SetProperty("VMC_CODMAT" , MODEL_FIELD_WHEN , { || oModel:GetModel( 'VMCOUTR' ):IsInserted() } )

// Gatilhos campos de Totais
oStrVMB:AddTrigger( "VMB_TOTAPC", "VMB_TOTALW", {|| .T.}, { |oModel| OFNJD49075_ValorTotalGarantia(oModel,1) } )
oStrVMB:AddTrigger( "VMB_TOTASV", "VMB_TOTALW", {|| .T.}, { |oModel| OFNJD49075_ValorTotalGarantia(oModel,1) } )
oStrVMB:AddTrigger( "VMB_OUTRAS", "VMB_TOTALW", {|| .T.}, { |oModel| OFNJD49075_ValorTotalGarantia(oModel,1) } )
oStrVMB:AddTrigger( "VMB_TOTALW", "VMB_JDVAR" , {|| Alltrim(FWFldGet('VMB_TIPGAR')) == 'ZSPA' }, { |oModel| OFNJD49075_ValorTotalGarantia(oModel,2) } )

// Gatilhos campos de Peças
oStrVMCPEC:AddTrigger( "VMC_VPECDG", "VMC_VTPECR", {|| .T.}, { |oModel| OFNJD49025_ValorPeca(oModel,1) } )
oStrVMCPEC:AddTrigger( "VMC_QPCRET", "VMC_VUPECR", {|| .T.}, { |oModel| OFNJD49025_ValorPeca(oModel,2) } )
oStrVMCPEC:AddTrigger( "VMC_VTPECR", "VMC_VUPECR", {|| .T.}, { |oModel| OFNJD49025_ValorPeca(oModel, If(Alltrim(FWFldGet('VMB_TIPGAR')) == 'ZSPA', 3, 2) ) } )

// Gatilhos campos de Serviços
oStrVMCSRV:AddTrigger( "VMC_VSERDG", "VMC_VTSERR", {|| .T.}, { |oModel| OFNJD49035_ValorServico(oModel,1) } )
oStrVMCSRV:AddTrigger( "VMC_QSRRET", "VMC_VALHRR", {|| .T.}, { |oModel| OFNJD49035_ValorServico(oModel,2) } )
oStrVMCSRV:AddTrigger( "VMC_VTSERR", "VMC_VALHRR", {|| .T.}, { |oModel| OFNJD49035_ValorServico(oModel, If(Alltrim(FWFldGet('VMB_TIPGAR')) == 'ZSPA', 3, 2) ) } )

// Gatilhos campos de Outros Créditos
oStrVMCOUT:AddTrigger( "VMC_VCUSDG", "VMC_CUSMAR", {|| .T.}, { |oModel| OFNJD49045_ValorOutrosCreditos(oModel,1) } )
oStrVMCOUT:AddTrigger( "VMC_CUSMAR", "VMC_CUSMAR", {|| .T.}, { |oModel| OFNJD49045_ValorOutrosCreditos(oModel,2) } )

oModel := MPFormModel():New('OFINJD49',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/ ,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VMBMASTER',/*cOwner*/ 	, oStrVMB)

oModel:AddGrid('VMCPECA'	,'VMBMASTER'	, oStrVMCPEC, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* bLoad */ )
oModel:AddGrid('VMCSERV'	,'VMBMASTER'	, oStrVMCSRV, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* bLoad */ )
oModel:AddGrid('VMCOUTR'	,'VMBMASTER'	, oStrVMCOUT, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* bLoad */ )

//Totalizadores de Peças
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCPECA', 'VMC_VTPECE' , 'TOTVEPEC' , 'SUM',,,STR0013 ) //'Tot Pec Env'
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCPECA', 'VMC_VTPECR' , 'TOTVRPEC' , 'SUM',,,STR0014 ) //'Tot Pec Ret'

//Totalizadores de Serviços
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCSERV', 'VMC_VTSERE' , 'TOTVESRV' , 'SUM',,,STR0015 ) //'Tot Srv Env'
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCSERV', 'VMC_VTSERR' , 'TOTVRSRV' , 'SUM',,,STR0016 ) //'Tot Srv Ret'

//Totalizadores de Outros Créditos
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCOUTR', 'VMC_CUSMAT' , 'TOTVEOUT' , 'SUM',,,STR0017 ) // 'Tot Out Cred Env'
oModel:AddCalc('CALCTOT_GAR', 'VMBMASTER', 'VMCOUTR', 'VMC_CUSMAR' , 'TOTVROUT' , 'SUM',,,STR0018 ) // 'Tot Out Cred Ret'

oModel:SetRelation( 'VMCPECA', { { 'VMC_FILIAL', 'VMB_FILIAL' }, { 'VMC_CODGAR+VMC_TIPOPS', 'VMB_CODGAR+"P"' } }, VMC->( IndexKey( 3 ) ) )
oModel:SetRelation( 'VMCSERV', { { 'VMC_FILIAL', 'VMB_FILIAL' }, { 'VMC_CODGAR+VMC_TIPOPS', 'VMB_CODGAR+"S"' } }, VMC->( IndexKey( 4 ) ) )
oModel:SetRelation( 'VMCOUTR', { { 'VMC_FILIAL', 'VMB_FILIAL' }, { 'VMC_CODGAR+VMC_TIPOPS', 'VMB_CODGAR+"O"' } }, VMC->( IndexKey( 5 ) ) )

oModel:GetModel("VMCPECA"):SetNoDeleteLine( .T. )
oModel:GetModel("VMCSERV"):SetNoDeleteLine( .T. )
oModel:GetModel("VMCOUTR"):SetNoDeleteLine( .T. )
oModel:GetModel("VMCOUTR"):SetNoInsertLine( .T. )

oModel:SetPrimaryKey( { "VMB_FILIAL", "VMB_CODGAR" } )
oModel:SetDescription(STR0001) // "Solicitação de Garantia"
oModel:GetModel('VMBMASTER'):SetDescription(STR0002) // "Informações da solicitação de garantia"
oModel:GetModel('VMCPECA'):SetDescription(STR0003) // "Informações das peças da solicitação de garantia"
oModel:GetModel('VMCSERV'):SetDescription(STR0004) // "Informações dos serviços da solicitação de garantia"
oModel:GetModel('VMCOUTR'):SetDescription(STR0005) // "Informações dos outros créditos da solicitação de garantia"

oModel:GetModel( 'VMCPECA' ):SetOptional( .T. )
oModel:GetModel( 'VMCSERV' ):SetOptional( .T. )
oModel:GetModel( 'VMCOUTR' ):SetOptional( .T. )

oModel:SetCommit( { |oModel| OFNJD49055_TudoOk(oModel) } )
oModel:SetActivate( {|| OFNJD49015_Inicializador() } )

oModel:InstallEvent("OFINJD49EVDEF", /*cOwner*/, OFINJD49EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ViewDef()

	Local oView
	Local oModel     := ModelDef()
	Local oStrVMB    := FWFormStruct(2, "VMB" , {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "VMB_NUMOSV|VMB_REPARO|VMB_CODGAR|VMB_CHASSI|VMB_CLAIM|VMB_TIPGAR|VMB_DTWMEM|VMB_STATSG|VMB_MEMTYP|VMB_STOTPC|VMB_ADITPC|VMB_RETEPC|VMB_TOTAPC|VMB_STOTSV|VMB_ADITSV|VMB_RETESV|VMB_TOTASV|VMB_DESLOC|VMB_OUTRAS|VMB_TOTALW|VMB_MREEMS|VMB_MREEMP|VMB_WAROBS|VMB_JDVAR|VMB_CONVAR|VMB_CLIVAR|VMB_CLIVAL|VMB_CONVAL|VMB_JDVAL|"} )
	Local oStrVMCPEC := FWFormStruct(2, "VMC" , {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "VMC_GRUITE|VMC_CODITE|VMC_DESCRI|VMC_PARTNO|VMC_UM|VMC_QTDPEC|VMC_QPCRET|VMC_VUPECE|VMC_VUPECR|VMC_VTPECE|VMC_VTPECR|VMC_VPECDG|"} )
	Local oStrVMCSRV := FWFormStruct(2, "VMC" , {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "VMC_GRUSER|VMC_CODSER|VMC_TIPTRA|VMC_TIPTRD|VMC_LOCTRA|VMC_QTDTRA|VMC_QSRRET|VMC_VALHRE|VMC_VALHRR|VMC_VTSERE|VMC_VTSERR|VMC_VSERDG|"} )
	Local oStrVMCOUT := FWFormStruct(2, "VMC" , {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "VMC_GRUSER|VMC_CODSER|VMC_GRUITE|VMC_CODITE|VMC_CODMAT|VMC_CODMAD|VMC_CUSMAT|VMC_CUSMAR|VMC_COMENT|VMC_VCUSDG|"} )
	Local oCalcTOT   := FWCalcStruct( oModel:GetModel( 'CALCTOT_GAR') )

	oStrVMB:SetProperty( "VMB_CONVAR" , MVC_VIEW_CANCHANGE , .t. )
	oStrVMB:SetProperty( "VMB_CLIVAR" , MVC_VIEW_CANCHANGE , .t. )

	oStrVMB:SetProperty( "VMB_CONVAL" , MVC_VIEW_CANCHANGE , .f. )
	oStrVMB:SetProperty( "VMB_CLIVAL" , MVC_VIEW_CANCHANGE , .f. )
	oStrVMB:SetProperty( "VMB_JDVAL"  , MVC_VIEW_CANCHANGE , .f. )

	//Alteração de estrutura de campo de Peças
	oStrVMCPEC:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
	oStrVMCPEC:SetProperty( "VMC_GRUITE" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCPEC:SetProperty( "VMC_CODITE" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCPEC:SetProperty( "VMC_QPCRET" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCPEC:SetProperty( "VMC_VPECDG" ,MVC_VIEW_CANCHANGE, .t. )

	oStrVMCPEC:SetProperty( "VMC_GRUITE" ,MVC_VIEW_LOOKUP   , "SBM" )
	oStrVMCPEC:SetProperty( "VMC_CODITE" ,MVC_VIEW_LOOKUP   , "B01" )

	//Alteração de estrutura de campo de Serviços
	oStrVMCSRV:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
	oStrVMCSRV:SetProperty( "VMC_GRUSER" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCSRV:SetProperty( "VMC_CODSER" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCSRV:SetProperty( "VMC_QSRRET" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCSRV:SetProperty( "VMC_VSERDG" ,MVC_VIEW_CANCHANGE, .t. )

	//Alteração de estrutura de campo de Outros Créditos
	oStrVMCOUT:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
	oStrVMCOUT:SetProperty( "VMC_CODMAT" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCOUT:SetProperty( "VMC_VCUSDG" ,MVC_VIEW_CANCHANGE, .t. )
	oStrVMCOUT:SetProperty( "VMC_VCUSDG" ,MVC_VIEW_ORDEM    , '40' )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVMB', 25)
	oView:AddField('VIEW_VMB', oStrVMB, 'VMBMASTER')
	oView:EnableTitleView('VIEW_VMB', STR0001 ) // "Solicitação de Garantia"
	oView:SetOwnerView('VIEW_VMB','BOXVMB')

	oView:CreateHorizontalBox( 'ITEGAR', 60)
	oView:CreateFolder( 'ABAS', 'ITEGAR' )

	oView:AddSheet( 'ABAS', 'ABA_PECA', STR0006 ) //"Peças"
	oView:CreateHorizontalBox( 'BOXPEC' , 100,,, 'ABAS', 'ABA_PECA' )
	oView:AddGrid("VIEW_PEC",oStrVMCPEC, 'VMCPECA')
	oView:SetOwnerView('VIEW_PEC','BOXPEC')

	oView:AddSheet( 'ABAS', 'ABA_SERV', STR0007 ) //"Serviços"
	oView:CreateHorizontalBox( 'BOXSERV' , 100,,, 'ABAS', 'ABA_SERV' )
	oView:AddGrid("VIEW_SRV",oStrVMCSRV, 'VMCSERV')
	oView:SetOwnerView('VIEW_SRV','BOXSERV')

	oView:AddSheet( 'ABAS', 'ABA_OUTR', STR0008 ) //"Outros Créditos"
	oView:CreateHorizontalBox( 'BOXOUTR' , 100,,, 'ABAS', 'ABA_OUTR' )
	oView:AddGrid("VIEW_OUT",oStrVMCOUT, 'VMCOUTR')
	oView:SetOwnerView('VIEW_OUT','BOXOUTR')

	oView:CreateHorizontalBox( 'BOXTOT', 15)
	oView:AddField("VIEW_TOT",oCalcTOT, 'CALCTOT_GAR')
	oView:SetOwnerView('VIEW_TOT','BOXTOT')

Return oView

/*/{Protheus.doc} OFNJD49015_Inicializador

Função que inicializa os campos de retorno de acordo com os valores enviados

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49015_Inicializador()

	Local oModel     := FWModelActive()
	Local oView      := FWViewActive()
	Local oModelCAB  := oModel:GetModel( 'VMBMASTER' )
	Local oModelPEC  := oModel:GetModel( 'VMCPECA' )
	Local oModelSER  := oModel:GetModel( 'VMCSERV' )
	Local oModelOUT  := oModel:GetModel( 'VMCOUTR' )
	Local nTamPec    := oModelPEC:Length()
	Local nTamSer    := oModelSER:Length()
	Local nTamOut    := oModelOUT:Length()
	Local aSaveLines := FWSaveRows()
	Local nI         := 0
	Local nAba       := 0
	Local oWsRet
	Local lContinue  := .f.

	lContinue := OFNJD15CM("VMB",VMB->(Recno()),3,.f.,@oWsRet)

	If lContinue

		//Inicializa os campos de retorno de acordo com os valores enviados
		For nI := 1 To Len(oWsRet:oOUTPUT:oREPLACEPART)

			lSeek := oModelPEC:SeekLine({{ "VMC_PARTNO" , oWsRet:oOUTPUT:oREPLACEPART[nI]:cPARTNO }})

			If lSeek .and. oModelPEC:GetValue("VMC_QPCRET") == 0

				oModelPEC:SetValue("VMC_QPCRET", oWsRet:oOUTPUT:oREPLACEPART[nI]:nQTY )
				oModelPEC:SetValue("VMC_VUPECR", oWsRet:oOUTPUT:oREPLACEPART[nI]:nPRICE )
				oModelPEC:SetValue("VMC_VTPECR", oWsRet:oOUTPUT:oREPLACEPART[nI]:nQTY * oWsRet:oOUTPUT:oREPLACEPART[nI]:nPRICE )

				If oModelCAB:GetValue("VMB_TIPGAR") == "ZSPA"
					oModelPEC:SetValue("VMC_VTPECR",( oModelPEC:GetValue("VMC_VTPECE") * oModelCAB:GetValue("VMB_JDPER") ) / 100)
				EndIf

			EndIf
		Next

		For nI := 1 To Len(oWsRet:oOUTPUT:oLABOR)

			lSeek := oModelSER:SeekLine({{ "VMC_TIPTRA" , oWsRet:oOUTPUT:oLABOR[nI]:cTYPE },{ "VMC_LOCTRA" , oWsRet:oOUTPUT:oLABOR[nI]:cSUBTYPE }})

			If lSeek .and.oModelSER:GetValue("VMC_QSRRET") == 0
				oModelSER:SetValue("VMC_QSRRET", oWsRet:oOUTPUT:oLABOR[nI]:nHOURS )
				oModelSER:SetValue("VMC_VALHRR", oWsRet:oOUTPUT:oLABOR[nI]:nRATE )
				oModelSER:SetValue("VMC_VTSERR", oWsRet:oOUTPUT:oLABOR[nI]:nHOURS * oWsRet:oOUTPUT:oLABOR[nI]:nRATE )

				If oModelCAB:GetValue("VMB_TIPGAR") == "ZSPA"
					oModelSER:SetValue("VMC_VTSERR",( oModelSER:GetValue("VMC_VTSERE") * oModelCAB:GetValue("VMB_JDPER") ) / 100)
				EndIf

			EndIf
		Next

	Else

		MsgInfo(STR0021,STR0022) //Ocorreu uma falha no processo, os valores serão preenchidos conforme enviados à fábrica. //Atenção

		For nI := 1 To nTamPec
			oModelPEC:GoLine( nI )
			If oModelPEC:GetValue("VMC_QPCRET") == 0
				oModelPEC:SetValue("VMC_QPCRET",oModelPEC:GetValue("VMC_QTDPEC"))
				oModelPEC:SetValue("VMC_VUPECR",oModelPEC:GetValue("VMC_VUPECE"))
				oModelPEC:SetValue("VMC_VTPECR",oModelPEC:GetValue("VMC_VTPECE"))

				If oModelCAB:GetValue("VMB_TIPGAR") == "ZSPA"
					oModelPEC:SetValue("VMC_VTPECR",( oModelPEC:GetValue("VMC_VTPECE") * oModelCAB:GetValue("VMB_JDPER") ) / 100)
				EndIf

			EndIf
		Next

		For nI := 1 To nTamSer
			oModelSER:GoLine( nI )
			If oModelSER:GetValue("VMC_QSRRET") == 0
				oModelSER:SetValue("VMC_QSRRET",oModelSER:GetValue("VMC_QTDTRA"))
				oModelSER:SetValue("VMC_VALHRR",oModelSER:GetValue("VMC_VALHRE"))
				oModelSER:SetValue("VMC_VTSERR",oModelSER:GetValue("VMC_VTSERE"))

				If oModelCAB:GetValue("VMB_TIPGAR") == "ZSPA"
					oModelSER:SetValue("VMC_VTSERR",( oModelSER:GetValue("VMC_VTSERE") * oModelCAB:GetValue("VMB_JDPER") ) / 100)
				EndIf

			EndIf
		Next

	EndIf

	For nI := 1 To nTamOut
		oModelOUT:GoLine( nI )
		If oModelOUT:GetValue("VMC_CUSMAR") == 0
			oModelOUT:SetValue("VMC_CUSMAR",oModelOUT:GetValue("VMC_CUSMAT"))

			If oModelCAB:GetValue("VMB_TIPGAR") == "ZSPA"
				oModelSER:SetValue("VMC_CUSMAR",( oModelSER:GetValue("VMC_CUSMAT") * oModelCAB:GetValue("VMB_JDPER") ) / 100)
			EndIf

		EndIf
	Next

	//Atualiza os campos de totalizadores no cabeçalho da garantia
	oModel:LoadValue("VMBMASTER","VMB_TOTAPC",oModel:GetValue("CALCTOT_GAR","TOTVRPEC"))
	oModel:LoadValue("VMBMASTER","VMB_TOTASV",oModel:GetValue("CALCTOT_GAR","TOTVRSRV"))
	oModel:LoadValue("VMBMASTER","VMB_OUTRAS",oModel:GetValue("CALCTOT_GAR","TOTVROUT"))

	If !Empty(oModel:GetValue("VMBMASTER","VMB_CLIVAL"))
		oModel:LoadValue("VMBMASTER","VMB_CLIVAR",oModel:GetValue("VMBMASTER","VMB_CLIVAL"))
	EndIf

	If !Empty(oModel:GetValue("VMBMASTER","VMB_CONVAL"))
		oModel:LoadValue("VMBMASTER","VMB_CONVAR",oModel:GetValue("VMBMASTER","VMB_CONVAL"))
	EndIf

	If !Empty(oModel:GetValue("VMBMASTER","VMB_JDVAL"))
		oModel:LoadValue("VMBMASTER","VMB_JDVAR",oModel:GetValue("VMBMASTER","VMB_JDVAL"))
	EndIf

	If nTamPec == 0 .or. ( nTamPec == 1 .and. Empty(oModelPEC:GetValue("VMC_CODITE")))
		oView:HideFolder('ABAS'	, 1, 2)
	ElseIf nAba == 0
		nAba := 1
	EndIf

	If nTamSer == 0 .or. ( nTamSer == 1 .and. Empty(oModelSER:GetValue("VMC_CODSER")))
		oView:HideFolder('ABAS'	, 2, 2)
	ElseIf nAba == 0
		nAba := 2
	EndIf

	If nTamOut == 0 .or. ( nTamOut == 1 .and. Empty( oModelOUT:GetValue("VMC_CODITE") ) .and. Empty(oModelOUT:GetValue("VMC_CODSER")) )
		oView:HideFolder('ABAS'	, 3, 2)
	ElseIf nAba == 0
		nAba := 3
	EndIf

	oView:SelectFolder("ABAS", nAba, 2)

	FWRestRows( aSaveLines )

Return .t.

/*/{Protheus.doc} OFNJD49025_ValorPeca

Função usada na digitação dos campos de quantidade, valor unitário e total na grid de peças

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49025_ValorPeca(oModel,nTpOp)

	Local nRetorno := 0
	Local oModCab  := FwModelActive()

	if nTpOp == 1

		Pergunte('OFINJD49',.f.)
		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+VMB->VMB_NUMOSV))
		nRetorno := round( FG_MOEDA( oModel:GetValue("VMC_VPECDG"), MV_PAR01, Max(VO1->VO1_MOEDA,1) ) , GetSX3Cache("VMC_VTPECR","X3_DECIMAL") )

	ElseIf nTpOp == 2 .or. nTpOp == 3

		If nTpOp == 3
			nRetorno := oModel:GetValue("VMC_VUPECR")
		Else
			nRetorno := round( oModel:GetValue("VMC_VTPECR") / oModel:GetValue("VMC_QPCRET") , GetSX3Cache("VMC_VUPECR","X3_DECIMAL") )
		EndIf

		oModCab:SetValue("VMBMASTER","VMB_TOTAPC",oModCab:GetValue("CALCTOT_GAR","TOTVRPEC"))

	EndIf


Return nRetorno

/*/{Protheus.doc} OFNJD49035_ValorServico

Função usada na digitação dos campos de hora, valor unitário e total na grid de serviços

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49035_ValorServico(oModel,nTpOp)

	Local nRetorno := 0
	Local oModCab := FwModelActive()

	if nTpOp == 1

		Pergunte('OFINJD49',.f.)
		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+VMB->VMB_NUMOSV))
		nRetorno := round( FG_MOEDA( oModel:GetValue("VMC_VSERDG"), MV_PAR01, Max(VO1->VO1_MOEDA,1)) , GetSX3Cache("VMC_VTSERR","X3_DECIMAL") )

	ElseIf nTpOp == 2 .or. nTpOp == 3

		If nTpOp == 3
			nRetorno := oModel:GetValue("VMC_VALHRR")
		Else
			nRetorno := round( oModel:GetValue("VMC_VTSERR") / oModel:GetValue("VMC_QSRRET") , GetSX3Cache("VMC_VALHRR","X3_DECIMAL") )
		EndIf

		oModCab:SetValue("VMBMASTER","VMB_TOTASV",oModCab:GetValue("CALCTOT_GAR","TOTVRSRV"))

	EndIf

Return nRetorno

/*/{Protheus.doc} OFNJD49045_ValorOutrosCreditos

Função usada na digitação dos campos de hora, valor unitário e total na grid de serviços

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49045_ValorOutrosCreditos(oModel,nTpOp)

	Local nRetorno := 0
	Local oModCab := FwModelActive()

	if nTpOp == 1

		Pergunte('OFINJD49',.f.)
		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+VMB->VMB_NUMOSV))
		nRetorno := round( FG_MOEDA( oModel:GetValue("VMC_VCUSDG"), MV_PAR01, Max(VO1->VO1_MOEDA,1)) , GetSX3Cache("VMC_CUSMAR","X3_DECIMAL") )

	ElseIf nTpOp == 2

		oModCab:SetValue("VMBMASTER","VMB_OUTRAS",oModCab:GetValue("CALCTOT_GAR","TOTVROUT"))

	EndIf

Return nRetorno

/*/{Protheus.doc} OFNJD49055_TudoOk

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49055_TudoOk(oModel)

	Local lRet    := .t.
	Local cMsgErr := ""
	
	lRet := MSGYesNo(STR0009) // "Deseja finalizar a atualização dos valores da garantia?"
	If lRet

		If Alltrim(oModel:GetValue("VMBMASTER","VMB_TIPGAR")) == "ZSPA"
			IF !Empty(oModel:GetValue("VMBMASTER","VMB_CLIPER")) .and. Empty(oModel:GetValue("VMBMASTER","VMB_CLIVAR"))
				cMsgErr := STR0019 // "Valores de retorno da parte do cliente não preenchido."
			EndIf
			IF !Empty(oModel:GetValue("VMBMASTER","VMB_CONPER")) .and. Empty(oModel:GetValue("VMBMASTER","VMB_CONVAR"))
				cMsgErr := STR0020 // "Valores de retorno da parte do concessionário não preenchido."
			EndIf
		EndIf

	Else
		cMsgErr := STR0010
	EndIf

	If !Empty(cMsgErr)
		oModel:SetErrorMessage(oModel:GetId(), "", oModel:GetId(), "VMB_STATSG", "OFNJD49055_TudoOk", cMsgErr ) //"Operação abortada."
	Else
		oModel:LoadValue("VMBMASTER","VMB_MEMTYP","4")
		oModel:LoadValue("VMBMASTER","VMB_STATSG","4")
		oModel:LoadValue("VMBMASTER","VMB_DTWMEM",dDataBase)
		oModel:LoadValue("VMBMASTER","VMB_WARRME",oModel:GetValue("VMBMASTER","VMB_CLAIM"))
		lRet := FwFormCommit(oModel)
	EndIf

Return lRet

/*/{Protheus.doc} OFNJD49065_TipodeTempoGarantia

Função para preenchimento do tipo de tempo de garantia para linhas de peças acrescentada

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49065_TipodeTempoGarantia( cCodGar )

	Local cSQL := ""
	Local cAuxTipTem := ""

	Default cCodGar := ""

	cSQL := "SELECT VMC_TIPTEM "
	cSQL +=  " FROM " + RetSQLName("VMC")
	cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
	cSQL +=   " AND VMC_CODGAR = '" + cCodGar + "'"
	cSQL +=   " AND VMC_TIPOPS = 'P'" // Pecas
	cSQL +=   " AND D_E_L_E_T_ = ' '"

	cAuxTipTem := FM_SQL(cSQL)

Return cAuxTipTem

/*/{Protheus.doc} OFNJD49075_ValorTotalGarantia

Função para preenchimento do tipo de tempo de garantia para linhas de peças acrescentada

@author Renato Vinicius
@since 13/01/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OFNJD49075_ValorTotalGarantia(oModel,nTpOp)

	Local oModCab := FwModelActive()
	Local nRetorno:= 0

	If nTpOp == 1
		nRetorno += oModCab:GetValue("VMBMASTER","VMB_TOTAPC")
		nRetorno += oModCab:GetValue("VMBMASTER","VMB_TOTASV")
		nRetorno += oModCab:GetValue("VMBMASTER","VMB_OUTRAS")
	Elseif nTpOp == 2
		nRetorno := oModCab:GetValue("VMBMASTER","VMB_TOTALW")
	EndIf

Return nRetorno