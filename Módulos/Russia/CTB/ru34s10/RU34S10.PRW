#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34S10.CH"
#INCLUDE "RESTFUL.CH"


FUNCTION RU34S10()
	If !CtbIsCube()
		MsgAlert('Cubes not setup','This routine uses cubes balances, plese request to admin to set them up')
	Else
	  //F61 table was release in R9 with wrong setup and rebuild on R11
	  //This Adjustment is run by RUP_CTB and does not change anything in tables structure, that?s why it can be called from here
	  AjustaF61()
	  Conout("RMT VERSION " + GetRmtVersion())
     FWCALLAPP('RU34S10',/*@oMainDlg*/)
	Endif
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Fun??o que pode ser chamada do PO-UI quando dentro do Protheus

@param oWebChannel - TWebEngine utilizado para renderizar o PO-UI
@param cType - Par?metro de tipo
@param cContent - Conteudo passado pelo PO-UI

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
Static lShowing := .F.
Local aFiliais     := {}
	conout(cType)
	conout(cContent)
	Do Case
		Case cType == "preLoad"
			sendFilEmp(oWebChannel)
		Case cType == "OpenDoc"
			If !lShowing //(LockByName("RU34S10_OPENDOC"+StrZero(ThreadId(),6)))
				lShowing	=	.T.
				oContent	:= JsonObject():New()
				oContent:FromJson(cContent)
				cCadastro := ""
				CV3->(DbSetOrder(2))
				cv3->(DbSeek(xFilial("CV3")+alltrim(oContent['CV3_RECDES']),.F.))
				DbSelectArea('CT2')
				ct2->(DbGoto(Val(oContent['CV3_RECDES'])))

				CTBC010ROT( oContent['CV3_TABORI'],Val(oContent['CV3_RECORI']), 4,Val(oContent['CV3_RECDES']))
				lShowing	=	.F.
			Else
				Conout('JS command ignored RU34S10')
			Endif
			//UnLockByName("RU34S10_OPENDOC"+StrZero(ThreadId(),6))
		Case cType == "anexo"
			Processa({ || CriaAnx(cContent, .F. )}, "Gerando planilha", "Aguarde...", .F.) //"Gerando planilha" "Aguarde..."
		Case cType == "exportar"
			Processa({ || CriaAnx(cContent, .T. )}, "Gerando impress?o" , "Aguarde...", .F.) //"Gerando impress?o" "Aguarde..."
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaAnx(cContent, lTemp)
Cria o arquivo excel utilizando as fun??es do Protheus

@param cContent - Conteudo do arquivo em formato blob
@param lTemp - Flag de arquivo tempor?rio ou n?o

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaAnx(cContent, lTemp)
Local oReqJSon    := Nil
Local aArqData    := {}
Local nI          := 0
Local nRet        := 0
Local cCamArq     := ""
Local cExcel      := ""
Local lCriaPast   := .F.

Default lTemp     := .F.
/*
	IncProc()

	// Verifica se a cria??o ser? em diret?rio tempor?rio ou n?o
	If lTemp
		cCamArq   := GetTempPath()
		lCriaPast := JurMkDir(cCamArq,.F.,.F.)
		cCamArq   += "tmprel" + GetMark()
	Else
		cCamArq     := cGetFile("Todos os arquivos" + "|*.*", "Selecionar caminho", , "C:\", .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), ,.F.) //"Todos os arquivos" "Selecionar caminho"
	EndIf

	// Verifica se h? caminho para o arquivo ser criado
	If (!Empty(cCamArq))
		If At(".xls",cCamArq) == 0
			cCamArq += ".xlsx"
		Endif

		FWJsonDeserialize(cContent,@oReqJSon)
		aArqData := oReqJSon:data

		nHDestino := FCREATE(cCamArq)
		
		For nI := 1 To Len(aArqData)
			cExcel += Chr(aArqData[nI])
		Next nI

		nBytesSalvo := FWRITE(nHDestino, cExcel)

		FCLOSE(nHDestino)

		if lTemp
			nRet := ShellExecute( 'open', cCamArq , '', "C:\", 1 )
		EndIf

		ApMsgInfo("O documento foi gerado com sucesso!") //"O documento foi gerado com sucesso!"
	EndIf
*/
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sendFilEmp
Envia os dados de pr?-carregamento para o Angular

@author Willian.Kazahaya
@since 04/08/2020
/*/ 
//-------------------------------------------------------------------
Static Function sendFilEmp(oWebChannel)
Local cJsonCompany := ""
Local aJson        := {}
Local aFiliais     := FWLoadSM0()
Local nI           := 0
Local nPos         := 0
Local oJSonResp    := Nil
Local cTranslation
Local cPath
Local nHdl
 	oJSonResp := JsonObject():New()

	For nI := 1 To Len(aFiliais)
		If (aFiliais[nI][11])
			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['company' ]   := aFiliais[nI][1]
			aJson[nPos]['branch' ]    := aFiliais[nI][2]
			aJson[nPos]['description' ] := EncodeUTF8(aFiliais[nI][7])
		EndIf
	Next nI

	oJSonResp:Set(aJson)
	cJsonCompany	:=	'{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
	oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )
	oWebChannel:AdvPLToJS( "setListBranchsUser", Encode64(oJSonResp:toJSon()))
	
	// cCode := '[{"key": "multiBranch", "value":'+iif(Empty(xFilial('CT2')),'false','true')+'}]'
    // oWebChannel:AdvPLToJS( "setSession"   , cCode )
	/*
     oWebChannel:AdvPLToJS( "setSession"   , cCode )
	cCode := '[{"key": "test1252_1", "value":"ççççççç"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )
     
     cCode := '[{"key": "test1252_2", "value":"'+EncodeUtf8('ççççççç')+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )

	cCode := '[{"key": "test1252_3", "value":"'+StrIConv('ççççççç','CP1251','UTF-8')+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )

     cCode := '[{"key": "test1252_64_1", "value":"'+Encode64('ççççççç')+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )
     
     cCode := '[{"key": "test1252_64_2", "value":"'+Encode64(EncodeUtf8('ççççççç'))+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )

	cCode := '[{"key": "test1252_64_3", "value":"'+Encode64(StrIConv('ççççççç','CP1251','UTF-8'))+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )
*/
	cTranslation := GetTranslation()
	
	//Temporary commented Code, while encoding is solved. Wen solkved should be sent Session variable
//	cCode := '[{"key": "literals", "value":"'+Encode64(EncodeUtf8(cTranslation))+'"}]'
	lOKClient:= GetRmtVersion()>'19.3.1.2'
	Conout("RMT VERSION " + GetRmtVersion())
	If lOKClient
	//	cCode := '[{"key": "literals", "value":"'+Encode64((cTranslation))+'"}]'
		//cCode := '[{"key": "literals", "value":"'+((cTranslation))+'"}]'
//		cCode := '[{"key": "literals", "value":"'+Encode64(('ççççççççç'))+'"}]'
		//cCode := '[{"key": "literalsX", "value": window.btoa(JSON.stringify('+((cTranslation))+'))}]'
		//cCode := '[{"key": "literalsX", "value": '+((cTranslation))+'}]'
		//oWebChannel:AdvPLToJS( "setSession"   , cCode )
		oWebChannel:AdvPLToJS( "setLiterals"   , cTranslation )
	Else
		cPath	:=	GetPvProfString('HTTP', 'PATH', "",	GetSrvIniName() ) + "\app-root\RU34S10\assets\literals\"
		nHdl:=Fopen(cPath+'literals.json',1)
		fSeek(nHdl,0)
		FWrite(nHdl,EncodeUtf8(cTranslation))
		Fclose(nHdl)
	Endif
	cCode := '[{"key": "ERPLanguage", "value":"'+Alltrim(FwRetIdiom())+'"}]'
	oWebChannel:AdvPLToJS( "setSession"   , cCode )
Return Nil

Static Function GetTranslation()
Local nX,nY,nI
Local aKeys,aKeys2
Local aFields:= {"CV3_LP","CV3_LPSEQ","CV3_KEY","CV3_HIST","CV3_VLR01","CV3_VLR02","CV3_VLR03","CV3_VLR04","CV3_VLR05"}
Local oJSonResp 	:= JsonObject():New()
Local cIdiom 		:= FwRetIdiom()
Local aIdioms		:=	{'en','pt-BR','pt-PT','es','ru'}
For nI:=1 To Len(aIdioms)
	FwSetIdiom(aIdioms[nI])
	oJsonResp[aIdioms[nI]]	:=	JsonObject():New()
	oJsonResp[aIdioms[nI]]['entityType'] := STR0018   //Entity type';
	oJsonResp[aIdioms[nI]]['class'] := STR0019   //"Entity class"
	oJsonResp[aIdioms[nI]]['summarizedType'] := STR0020   //Summarized';
	oJsonResp[aIdioms[nI]]['analyticType'] := STR0021   //Analytic';
	oJsonResp[aIdioms[nI]]['summarizedBalances'] := STR0023   //Summarized balances';
	oJsonResp[aIdioms[nI]]['notSummarizedBalances'] := STR0024   //Summarized balances';
	oJsonResp[aIdioms[nI]]['allBalances'] := STR0025   //All balances';
	oJsonResp[aIdioms[nI]]['hide'] := STR0026   //Hide';
	oJsonResp[aIdioms[nI]]['show'] := STR0027   //Show';
	oJsonResp[aIdioms[nI]]['noDivision'] := STR0028   //Nop division';
	oJsonResp[aIdioms[nI]]['thousand'] := STR0029   //Thousand';
	oJsonResp[aIdioms[nI]]['milion'] := STR0030   //Milion';
	oJsonResp[aIdioms[nI]]['lastYear'] := STR0031   //Last Year';
	oJsonResp[aIdioms[nI]]['yearToDate'] := STR0032   //Year to date';
	oJsonResp[aIdioms[nI]]['lastMonth'] := STR0033   //Last Month';
	oJsonResp[aIdioms[nI]]['thisMonth'] := STR0034   //This Month';
	oJsonResp[aIdioms[nI]]['fixedDate'] := STR0035   //Fixed Date';
	oJsonResp[aIdioms[nI]]['onDemandHelp'] := STR0036   //On Demand: data will be processed by request on each node. Recomended for large amount of data and needed for printing';
	oJsonResp[aIdioms[nI]]['loadingPre'] := STR0037   //Loading pre-setup...';
	oJsonResp[aIdioms[nI]]['loadingPostings'] := STR0038   //Loading postings';
	oJsonResp[aIdioms[nI]]['preparingView'] := STR0039   //Preparing view';
	oJsonResp[aIdioms[nI]]['checkAndCorrectParameters'] := STR0040   //Check and correct parameters';
	oJsonResp[aIdioms[nI]]['description'] := STR0041   //Description';
	oJsonResp[aIdioms[nI]]['accessType'] := STR0042   //Access type';
	oJsonResp[aIdioms[nI]]['unrestricted'] := STR0043   //Unrestricted';
	oJsonResp[aIdioms[nI]]['user'] := STR0044   //User';
	oJsonResp[aIdioms[nI]]['userGroup'] := STR0045   //User group';
	oJsonResp[aIdioms[nI]]['group'] := STR0046   //Group';
	oJsonResp[aIdioms[nI]]['equalTo'] := STR0047   //Equal to ';
	oJsonResp[aIdioms[nI]]['notEqualTo'] := STR0048   //Not equal to ';
	oJsonResp[aIdioms[nI]]['greaterThan'] := STR0049   //Greater than ';
	oJsonResp[aIdioms[nI]]['lowerThan'] := STR0050   //Lower than ';
	oJsonResp[aIdioms[nI]]['greaterOrEqualTo'] := STR0051   //Greater or equal to ';
	oJsonResp[aIdioms[nI]]['lowerOrEqualTo'] := STR0052   //Lower or equal to ';
	oJsonResp[aIdioms[nI]]['between'] := STR0053   //between ';
	oJsonResp[aIdioms[nI]]['notBetween'] := STR0054   //not between ';
	oJsonResp[aIdioms[nI]]['resetFilter'] := STR0055   //Reset filter';
	oJsonResp[aIdioms[nI]]['or'] := STR0056   //or';
	oJsonResp[aIdioms[nI]]['and'] := STR0057   //and';
	oJsonResp[aIdioms[nI]]['dragAndDropWarning'] := STR0058   //Please drag and drop at least one entity for reporting.';
	oJsonResp[aIdioms[nI]]['correctFilterExpression'] := STR0059   //Correct filter expression';
	oJsonResp[aIdioms[nI]]['line'] := STR0060   //line';
	oJsonResp[aIdioms[nI]]['savingSetup'] := STR0061   //Saving setup';
	oJsonResp[aIdioms[nI]]['succesfullyUpdated'] := STR0062   //Succesfully updated';
	oJsonResp[aIdioms[nI]]['errorOnSetupUpdate'] := STR0063   //Error on setup update';
	oJsonResp[aIdioms[nI]]['expected'] := STR0064   //Expected';
	oJsonResp[aIdioms[nI]]['parenthesesUnbalanced'] := STR0065   //Parentheses not balanced ';
	oJsonResp[aIdioms[nI]]['loadingReport'] := STR0066   //Loading report';
	oJsonResp[aIdioms[nI]]['loadingOrigin'] := STR0067   //Loading origin';
	oJsonResp[aIdioms[nI]]['originNotFound'] := STR0068   //Origin not found';
	oJsonResp[aIdioms[nI]]['entity'] := STR0069   //Entity'      ;
	oJsonResp[aIdioms[nI]]['key'] := STR0070   //Key'         ;
	oJsonResp[aIdioms[nI]]['parentKey'] := STR0071   //Parent Key'  ;
	oJsonResp[aIdioms[nI]]['currency'] := STR0072   //Currency'    ;
	oJsonResp[aIdioms[nI]]['balanceType'] := STR0073   //Balance Type';
	oJsonResp[aIdioms[nI]]['entities'] := STR0074   //Entities'    ;
	oJsonResp[aIdioms[nI]]['balances'] := STR0075   //Balances'    ;
	oJsonResp[aIdioms[nI]]['startCredit'] := STR0076   //Credit initial balance'      ;
	oJsonResp[aIdioms[nI]]['startDebit'] := STR0077   //Debit initial balance'       ;
	oJsonResp[aIdioms[nI]]['startBalance'] := STR0078   //Initial balance'     ;
	oJsonResp[aIdioms[nI]]['credit'] := STR0079   //Credit'  ;
	oJsonResp[aIdioms[nI]]['debit'] := STR0080   //Debit'   ;
	oJsonResp[aIdioms[nI]]['balanceVariation'] := STR0081   //Balance variation';
	oJsonResp[aIdioms[nI]]['creditFinal'] := STR0082   //Credit final balance';
	oJsonResp[aIdioms[nI]]['debitFinal'] := STR0083   //Debit final balance' ;
	oJsonResp[aIdioms[nI]]['balanceFinal'] := STR0084   //Final balance';
	oJsonResp[aIdioms[nI]]['summarized'] := STR0085   //Summarized';
	oJsonResp[aIdioms[nI]]['confirm'] := STR0086   //"Entity type"';
	oJsonResp[aIdioms[nI]]['entityType'] := STR0018   //Summarized';
	oJsonResp[aIdioms[nI]]['class'] := STR0019   //"Entity class"
	oJsonResp[aIdioms[nI]]['summarizedType'] := STR0020   //Summarized';
	oJsonResp[aIdioms[nI]]['analyticType'] := STR0021   //Analytic';

	oJsonResp[aIdioms[nI]]['poTableLiterals'] := JsonObject():New()
	oJsonResp[aIdioms[nI]]['poTableLiterals']['columnsManager']:=STR0011
	oJsonResp[aIdioms[nI]]['poTableLiterals']['loadMoreData']:=STR0012
	oJsonResp[aIdioms[nI]]['poTableLiterals']['loadingData']:=STR0013
	oJsonResp[aIdioms[nI]]['poTableLiterals']['noColumns']:=STR0014
	oJsonResp[aIdioms[nI]]['poTableLiterals']['noData']:=STR0015
	oJsonResp[aIdioms[nI]]['poTableLiterals']['seeCompleteSubtitle']:=STR0016
	oJsonResp[aIdioms[nI]]['poTableLiterals']['completeSubtitle']:=STR0017

	oJsonResp[aIdioms[nI]]['poPageDynamicSearchLiterals']:= JsonObject():New()
	oJsonResp[aIdioms[nI]]['poPageDynamicSearchLiterals']['disclaimerGroupTitle']:=STR0008
	oJsonResp[aIdioms[nI]]['poPageDynamicSearchLiterals']['quickSearchLabel']:=STR0009
	oJsonResp[aIdioms[nI]]['poPageDynamicSearchLiterals']['searchPlaceholder']:=STR0010

	oJsonResp[aIdioms[nI]]['turnOverSheet'] := STR0001   
	oJsonResp[aIdioms[nI]]['loadingDefinitions'] := STR0002
	oJsonResp[aIdioms[nI]]['reloadReport'] := STR0003   
	oJsonResp[aIdioms[nI]]['poLookupLiterals']:= JsonObject():New()
	oJsonResp[aIdioms[nI]]['poLookupLiterals']['modalPrimaryActionLabel']:=STR0004
	oJsonResp[aIdioms[nI]]['poLookupLiterals']['modalSecondaryActionLabel']:=STR0005
	oJsonResp[aIdioms[nI]]['poLookupLiterals']['modalPlaceholder']:=STR0006
	oJsonResp[aIdioms[nI]]['poLookupLiterals']['modalTitle']:=STR0007

	oJsonResp[aIdioms[nI]]['parameters'] := STR0087
	oJsonResp[aIdioms[nI]]['preSetup'] := STR0088
	oJsonResp[aIdioms[nI]]['reload'] := STR0089
	oJsonResp[aIdioms[nI]]['runSelected'] := STR0090
	oJsonResp[aIdioms[nI]]['reviewParams'] := STR0091
	oJsonResp[aIdioms[nI]]['expression'] := STR0092
	oJsonResp[aIdioms[nI]]['previous'] := STR0093
	oJsonResp[aIdioms[nI]]['next'] := STR0094
	oJsonResp[aIdioms[nI]]['selectDDandFilterEntities'] := STR0095
	oJsonResp[aIdioms[nI]]['availableEntities'] := STR0096
	oJsonResp[aIdioms[nI]]['reportEntities'] := STR0097
	oJsonResp[aIdioms[nI]]['onlyFilter'] := STR0098
	oJsonResp[aIdioms[nI]]['filters'] := STR0099
	oJsonResp[aIdioms[nI]]['runReport'] := STR0100
	oJsonResp[aIdioms[nI]]['startingDate'] := STR0101
	oJsonResp[aIdioms[nI]]['date'] := STR0102
	oJsonResp[aIdioms[nI]]['finishDate'] := STR0103
	oJsonResp[aIdioms[nI]]['balanceTypes'] := STR0104
	oJsonResp[aIdioms[nI]]['dataRetrieveMode'] := STR0105
	oJsonResp[aIdioms[nI]]['expandToLevel'] := STR0106
	oJsonResp[aIdioms[nI]]['expandToLevelHelp'] := STR0107
	oJsonResp[aIdioms[nI]]['saveAsNew'] := STR0108
	oJsonResp[aIdioms[nI]]['saveChanges'] := STR0109
	oJsonResp[aIdioms[nI]]['reset'] := STR0110
	oJsonResp[aIdioms[nI]]['showSummarizedLedgerAccount'] := STR0111
	oJsonResp[aIdioms[nI]]['divideBy'] := STR0112
	oJsonResp[aIdioms[nI]]['entitiesData'] := STR0113
	oJsonResp[aIdioms[nI]]['filterMode'] := STR0114
	oJsonResp[aIdioms[nI]]['saveConfiguration'] := STR0115
	oJsonResp[aIdioms[nI]]['all'] := STR0116
	oJsonResp[aIdioms[nI]]['postings'] := STR0117
	oJsonResp[aIdioms[nI]]['returningToTurnoverSheet'] := STR0118

	oJsonResp[aIdioms[nI]]['viewDocument'] := STR0119
	oJsonResp[aIdioms[nI]]['postingOrigins'] := STR0120

	oJsonResp[aIdioms[nI]]['matchOnly'] := STR0121
	oJsonResp[aIdioms[nI]]['withAncestors'] := STR0122
	oJsonResp[aIdioms[nI]]['fullBranch'] := STR0123
	
	oJsonResp[aIdioms[nI]]['creditDef'] := STR0124
	oJsonResp[aIdioms[nI]]['debitDef'] := STR0125
	oJsonResp[aIdioms[nI]]['type'] := STR0126


	oJsonResp[aIdioms[nI]]['summarizedBalancesAbbr'] 	 := STR0127   
	oJsonResp[aIdioms[nI]]['notSummarizedBalancesAbbr'] := STR0128   

	oJsonResp[aIdioms[nI]]['reloadWarning'] 	 := STR0129
	oJsonResp[aIdioms[nI]]['saveSetup'] 	 := STR0130   
	oJsonResp[aIdioms[nI]]['exportToExcel'] 	 := STR0131   
	oJsonResp[aIdioms[nI]]['saveCurrentSetupWithLayout'] 	 := STR0132
	oJsonResp[aIdioms[nI]]['confirmDelete'] 	 := STR0133   
	oJsonResp[aIdioms[nI]]['doYouConfirm'] 	 := STR0134   
	oJsonResp[aIdioms[nI]]['delete'] 	 := STR0135   
	oJsonResp[aIdioms[nI]]['expandAll'] 	 := STR0136   
	oJsonResp[aIdioms[nI]]['collapseAll'] 	 := STR0137   
	oJsonResp[aIdioms[nI]]['totals'] 	 := STR0138   
   
	oJsonResp[aIdioms[nI]]['saveLayoutAsStandardOrOnlyForCurrent'] 	 := STR0139

	oJsonResp[aIdioms[nI]]['restoreStandard'] 	 := STR0140
	oJsonResp[aIdioms[nI]]['cancel'] 	 := STR0141
	oJsonResp[aIdioms[nI]]['saveCurrentLayout'] 	 := STR0142
	oJsonResp[aIdioms[nI]]['saveLayout'] 	 := STR0143
	oJsonResp[aIdioms[nI]]['asStandard'] 	 := STR0144
	oJsonResp[aIdioms[nI]]['onlyForCurrentSetup'] 	 := STR0145
	oJsonResp[aIdioms[nI]]['saveAsStandard'] 	 := STR0146
	oJsonResp[aIdioms[nI]]['save'] 	 := STR0147
	oJsonResp[aIdioms[nI]]['close'] 	 := STR0148
	oJsonResp[aIdioms[nI]]['turnOvers'] 	 := STR0149
	
	oJsonResp[aIdioms[nI]]['parameter'] := STR0150
	
	oJsonResp[aIdioms[nI]]['company'] := STR0151
	oJsonResp[aIdioms[nI]]['branch'] := STR0152

	oJsonResp[aIdioms[nI]]['orientation'] := STR0153
	oJsonResp[aIdioms[nI]]['landscape'] := STR0154
	oJsonResp[aIdioms[nI]]['portrait'] := STR0155
	oJsonResp[aIdioms[nI]]['pageSize'] := STR0156
	oJsonResp[aIdioms[nI]]['tablesStyle'] := STR0157
	oJsonResp[aIdioms[nI]]['headerLineOnly'] := STR0158
	oJsonResp[aIdioms[nI]]['noBorders'] := STR0159
	oJsonResp[aIdioms[nI]]['lightHorizontalLines'] := STR0160
	oJsonResp[aIdioms[nI]]['alternateRowsColor'] := STR0161
	oJsonResp[aIdioms[nI]]['printParametersPage'] := STR0162
	oJsonResp[aIdioms[nI]]['optimizeColumnsSize'] := STR0163
	oJsonResp[aIdioms[nI]]['optimizeColumnsSizeHint'] := STR0164


	SX3->(DbSetOrder(2))
	For nX:=1 To Len(aFields)
		If SX3->(Dbseek(aFields[nX]))
			oJsonResp[aIdioms[nI]][aFields[nX]] := (Alltrim(X3Descric(aFields[nX])))
		Endif
	Next
	/*
	aKeys := oJsonResp:GetNames()
	For nX:=1 TO Len(aKeys)
		If valtype(oJsonResp[aIdioms[nI][akeys[nX]])== "J"
				aKeys2 := oJsonResp[aIdioms[nI][aKeys[nX]]:getNames()
				For nY:=1 TO Len(aKeys2)
					oJsonResp[aIdioms[nI][akeys[nX]][aKeys2[nY]] := Encode64(oJsonResp[aIdioms[nI][akeys[nX]][aKeys2[nY]])
				Next
		Else
				oJsonResp[aIdioms[nI][akeys[nX]] := Encode64(oJsonResp[aIdioms[nI][akeys[nX]])
		Endif
	Next
	*/
Next
FwSetIdiom(cIdiom)
cRet :=oJSonResp:toJSon() 
FreeObj(oJSonResp)

Return cRet

Function RuFilXBCT1(cCtaSup)
    Local lRet as logic
    lRet:= .T.
Return lRet

//-----------------------------------------------------------------------

/*/{Protheus.doc} RU34S10001_RuFilXBeNTITTE
Filter accounting entities in SXB not to be displayed when XXX_CLASE == 1
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
@return lRet (True - Show in SXB , False do not show on SXB)
/*/
Function RU34S10001_RuFilXBeNTITTE(cAlias)
    Local lRet as logical
    Local cClass as Character
    
    DEFAULT cAlias = alias()

    cClass:= cAlias+"->"+cAlias+"_CLASSE"
    lRet:= .T.

    If (&(cClass)=='1' .AND. RU34S10004_IsBsProc())  //payment request payment order baks statment and gererate payment order
        lRet:= .F.
    EndIf
Return lRet

/*/{Protheus.doc} RU34S10002_VldEntiti
Validates accounting entities
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
    cAlias: alias of the standart entrie case empty will take the cottent of X3_F3 if its is a valid entity in SX2
    cField: cottent to be validated if empty will take the field that is been used (readvar)
    lSint:  If true allow sumyrized itens othewise it does not accept and show the message by defalt it is false
@return lRet (True - is a valid entitie , False is not a valid entitie)
/*/
Function RU34S10002_VldEntiti(cAlias,cField,lSint)
    Local lRet as logical
    Local cClass as Character

    DEFAULT cAlias = ""
    DEFAULT cField = ""
    DEFAULT lSint  = .F.
    
    If EMPTY( cAlias )
        cAlias = RU34S10003_getAliasRead_var(READVAR())
    EndIf
    If EMPTY( cField )
        cField = &(READVAR())
    EndIf

    cClass:= cAlias+"->"+cAlias+"_CLASSE"
    lRet:= .T.

    If !(ExistCpo(cAlias)) 
        lRet:= .F.
    ElseIf !lSint .AND. (Posicione(cAlias, 1, xFilial(cAlias) + cField, cClass) == '1')
        Help(" ",1,"NOCLASSE")    
        lRet:= .F.
    EndIf
Return lRet

/*/{Protheus.doc} RU34S10003_getAliasRead_var
Returns the alias of the entity based on the X3_F3 of the field in the parameter that is 
triggered when using the routine RU34S10002_VldEntiti when the parameter cAlias is empty
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
    cReadVar: Nome do cammpo da entidade contabil podendo recever o proprio readVar 
@return cAlias: Alias da entidade contabil baseada no X3_F3
/*/
Static Function RU34S10003_getAliasRead_var(cReadVar)
    Local cAlias as Character 
    Local aReadVar as Array 
    Local aArea	as array
    DEFAULT cReadVar = ''
    aReadVar:= {}
    cAlias := ''
    aArea := GetArea()
        If !empty(cReadVar)
            cReadVar:= StrTran( cReadVar, "M->", "" )  
        EndIf
        cAlias:= alltrim(GetSx3Cache(cReadVar,'X3_F3'))
    RestArea(aArea)
Return cAlias

Static Function RU34S10004_IsBsProc()
    Local lRet      as Logical
    Local aFuncs    as Array 
    Local nX        as Numeric

    lRet    :=.F.
    aFuncs  := {}

    //Add here Functions to be considered in Bs process and related to accountty entityes 
    //-----------------------------------------------------------------------------------
        AADD( aFuncs, 'RU06D04RUS' ) // PAYMENT REQUEST
        AADD( aFuncs, 'RU06D05RUS' ) // PAYMENT ORDER
        AADD( aFuncs, 'RU06D07RUS' ) // Bank Statment
        AADD( aFuncs, 'RU09D08' )   // Configuration for Payment Request to Budget Payment.
    //-----------------------------------------------------------------------------------

    For nX:=1 To Len(aFuncs)
        lRet =  IsInCallStack(aFuncs[nX])
        If lRet 
            Exit
        EndIf   
    Next nX

Return lRet
                   
//Merge Russia R14 
                   
