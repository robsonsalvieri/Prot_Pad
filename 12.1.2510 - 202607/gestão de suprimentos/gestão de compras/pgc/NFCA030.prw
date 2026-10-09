#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "NFCA030.CH"

PUBLISH MODEL REST NAME NFCA030 SOURCE NFCA030

Static _lNFCWFENV	:= Existblock("NFCWFENV")
Static _oPnlColors	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NFCA030
Tela de cadastro dos dados para workflow personalizado.

@author Leandro Fini
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function NFCA030()
	Local oBrowse := Nil
	If FwAliasInDic('DKK') .And. FwAliasInDic('DKL')

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("DKK")
		oBrowse:SetDescription(STR0001) //Itens do template WF

		oBrowse:Activate()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.NFCA030' 	OPERATION 3 ACCESS 0 //-- Incluir
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.NFCA030' 	OPERATION 2 ACCESS 0 //-- Visualizar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.NFCA030' 	OPERATION 4 ACCESS 0 //-- Editar
	ADD OPTION aRotina Title STR0024 Action 'VIEWDEF.NFCA030' 	OPERATION 5 ACCESS 0 //-- Excluir
	ADD OPTION aRotina Title STR0029 Action 'NF030CRHTE'   		OPERATION 3 ACCESS 0 //-- Gerar HTML
	ADD OPTION aRotina Title STR0019 Action 'NF030TstEmail'   	OPERATION 3 ACCESS 0 //-- Teste de E-mail
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model da tela
@author Leandro Fini
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStrDKK	:= FWFormStruct(1,'DKK')
	Local oStrDKL	:= FWFormStruct(1,'DKL')
	Local oModel	:= nil

	oModel := MPFormModel():New('NFCA030',/*bPreVld*/, /*bPosVld*/, {|oModel| CommitData(oModel)}, {|oModel| NF030Cancel(oModel)}) 

	oModel:AddFields( 'DKKMASTER', , oStrDKK )

	oModel:AddGrid("DKLDETAIL", "DKKMASTER",oStrDKL )

	oModel:GetModel('DKLDETAIL'):SetUniqueLine({"DKL_TABELA", "DKL_CAMPO"})

	oModel:SetRelation('DKLDETAIL', {{'DKL_FILIAL','fwxFilial("DKK")'}, {'DKL_CODDKK','DKK_CODIGO'}}, DKL->(IndexKey(1)))

	oModel:GetModel('DKLDETAIL'):SetOptional(.T.) //Define a DKL como opcional
	oModel:GetModel('DKLDETAIL'):SetDescription( STR0002 ) //Campos adicionados - Template WF

	oModel:SetPrimaryKey({'DKK_FILIAL', 'DKK_CODIGO'})

	oStrDKK:SetProperty( "DKK_CODIGO", MODEL_FIELD_INIT   , {|| NF030Num()})
	oStrDKK:SetProperty( "DKK_COR"	 , MODEL_FIELD_INIT   , {|| '#0088CB'})
	oStrDKK:SetProperty( "DKK_COR"   , MODEL_FIELD_OBRIGAT, .T. )
	oStrDKK:SetProperty( "DKK_COR"   , MODEL_FIELD_VALID  , {|| NF030HxRGB(fwfldget('DKK_COR'), .T., !IsBlind(), "2")})

	oStrDKL:SetProperty( "DKL_CAMPO" , MODEL_FIELD_OBRIGAT, .T. )
	oStrDKL:SetProperty( "DKL_VINC"  , MODEL_FIELD_INIT   , {|| ''})
	oStrDKL:SetProperty( "DKL_VINC"  , MODEL_FIELD_VALID  , {|| NF030VdTable(oModel, fwfldget('DKL_VINC'))})
	oStrDKL:SetProperty( "DKL_CAMPO" , MODEL_FIELD_VALID  , {|| NF030VdCmp(oModel, fwfldget('DKL_CAMPO'), fwfldget('DKL_TABELA'))})
	oStrDKL:SetProperty( "DKL_EDIT"  , MODEL_FIELD_VALID  , {|| NF030VdEdit(oModel, fwfldget('DKL_EDIT'))})
	oStrDKL:SetProperty( "DKL_EDIT"  , MODEL_FIELD_WHEN   , {|| !(fwfldget('DKL_VINC') $ '1/3' .Or. NF030Virtual(fwfldget('DKL_CAMPO'))) .Or. (_lNFCWFENV .And. fwfldget('DKL_TABELA') != 'DHU' .And. fwfldget('DKL_VINC') != '1' )})
	oStrDKL:SetProperty( "DKL_OBRIGA", MODEL_FIELD_WHEN   , {|| !(fwfldget('DKL_VINC') $ '1/3' .Or. NF030Virtual(fwfldget('DKL_CAMPO')) .Or. fwfldget('DKL_EDIT') == "2") .Or. (_lNFCWFENV .And. fwfldget('DKL_TABELA') != 'DHU' .And. fwfldget('DKL_VINC') != '1' .And. fwfldget('DKL_EDIT') == "1" )})
	oStrDKL:SetProperty( "DKL_TABELA", MODEL_FIELD_WHEN   , {|| _lNFCWFENV})

	If _lNFCWFENV
		oStrDKL:SetProperty( "DKL_TABELA", MODEL_FIELD_VALID  , {|| VldTable(oModel, fwfldget('DKL_TABELA'))})
	EndIf
	
	oModel:SetVldActivate( {|| VldActive(oModel)})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface com usuário
@author Leandro Fini
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:= FWLoadModel("NFCA030")
	Local oView			:= FWFormView():New()
	Local oStrDKK		:= Nil
	Local oStrDKL		:= Nil

	oStrDKK		:= FWFormStruct(2,'DKK', {|cCampo| !AllTrim(cCampo)$ "DKK_FILIAL|DKK_REVIS"})
	oStrDKL		:= FWFormStruct(2,'DKL', {|cCampo| !AllTrim(cCampo)$ "DKL_FILIAL|DKL_CODDKK"})

	oView:SetModel( oModel )

	oView:AddField('VIEW_DKK'	,oStrDKK	,'DKKMASTER')
	oView:AddGrid('VIEW_DKL'	,oStrDKL	,'DKLDETAIL')

	oView:CreateHorizontalBox('CABEC'	,020)
	oView:CreateHorizontalBox('DETAIL'	,080)

	oView:CreateVerticalBox("CAMPOS", 90,'CABEC')
    oView:CreateVerticalBox("COR", 10, 'CABEC')

	oView:SetOwnerView('VIEW_DKK'		,'CAMPOS' )
	oView:AddOtherObject('PANCAM',{|oPanel| PnlCores(oPanel, oModel)})
	oView:SetOwnerView('PANCAM', 'COR')
	oView:SetOwnerView('VIEW_DKL'		,'DETAIL' )

	oStrDKL:SetProperty('DKL_VINC',		MVC_VIEW_ORDEM, '01')
	oStrDKL:SetProperty('DKL_TABELA',	MVC_VIEW_ORDEM, '02')
	oStrDKL:SetProperty('DKL_CAMPO',	MVC_VIEW_ORDEM, '03')
	oStrDKL:SetProperty('DKL_EDIT',		MVC_VIEW_ORDEM, '04')

	oView:SetCloseOnOk({||.T.})

	oView:AddUserButton(STR0011, '', {|| NF030COR()}) //Escolha de Cores
	oView:SetAfterViewActivate({|| NF030After(oView, oModel)})

Return oView


/*/{Protheus.doc} CommitData
	Bloco de commit
@author Leandro Fini
@since 06/2025
/*/
Static Function CommitData(oModel)

	Local lRet 		:= .T.
	Local oModelDKK	:= oModel:GetModel("DKKMASTER")
	Local oModelDKL	:= oModel:GetModel("DKLDETAIL")
	Local cColor	:= oModelDKK:GetValue("DKK_COR")
	Local cPicture	:= Lower(AllTrim(oModelDKK:GetValue("DKK_LOGO")))
	Local nX 		:= 1
	Local aCabCpo 	:= {}
	Local aItCpo  	:= {}
	Local aRodCpo 	:= {}

	if ( oModel:GetOperation() == MODEL_OPERATION_INSERT)
		oModelDKK:LoadValue("DKK_REVIS", "000001")
	elseif (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		oModelDKK:LoadValue("DKK_REVIS", SOMA1(oModelDKK:GetValue("DKK_REVIS")))
	endif

	for nX := 1 to oModelDKL:Length()
		oModelDKL:GoLine(nX)
		if !oModelDKL:Isdeleted() .and. oModelDKL:GetValue("DKL_VINC") == "1" // -- Cabeçalho
			aAdd(aCabCpo,{Alltrim(oModelDKL:GetValue("DKL_CAMPO")), "VISUAL", .F.})

		elseif !oModelDKL:Isdeleted() .and. oModelDKL:GetValue("DKL_VINC") == "2"// -- Itens
			aAdd(aItCpo,{Alltrim(oModelDKL:GetValue("DKL_CAMPO")), iif(oModelDKL:GetValue("DKL_EDIT") == "1", "EDIT", "VISUAL"), iif(oModelDKL:GetValue("DKL_OBRIGA")== "1", .T., .F.), oModelDKL:GetValue("DKL_TABELA")})

		elseif !oModelDKL:Isdeleted() .and. oModelDKL:GetValue("DKL_VINC") == "3"// -- Rodape
			aAdd(aRodCpo,{Alltrim(oModelDKL:GetValue("DKL_CAMPO")), iif(oModelDKL:GetValue("DKL_EDIT") == "1", "EDIT", "VISUAL"), iif(oModelDKL:GetValue("DKL_OBRIGA")== "1", .T., .F.), oModelDKL:GetValue("DKL_TABELA")})
		endif

	next nX

	lRet := FwFormCommit( oModel )

	if (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		FWMsgRun(, {|| NF030Html(aCabCpo,aItCpo,aRodCpo,cColor, cPicture) }, STR0006, STR0007) //"Aguarde" - "Gerando template html..."
	endif

	FwFreeArray(aCabCpo)
	FwFreeArray(aItCpo)
	FwFreeArray(aRodCpo)
Return lRet


/*/{Protheus.doc} NF030Html
	Geração do template HTML para workflow
@author Leandro Fini
@since 06/2025
/*/
Function NF030Html(aCabCpo,aItCpo,aRodCpo,cColor, cPicture, cMessage, lShowHelp)

	Local nCab 			:= 1
	Local nIt  			:= 1
	Local nRod 			:= 1
	Local nX 			:= 1
	Local cCpoType		:= "C"
	Local aSizeCpo		:= {}
	Local aCombo    	:= {}
	Local nRet			:= 0
	Local cString		:= ""
	Local cPathFile		:= AllTrim(SuperGetMV( "MV_WFDIR", .F., "" ) )
	Local aRetFun		:= {}
	Local lRetFun		:= .F.
	Local cFileName		:= "pgca030_mail001.html"
	Local lObrigat		:= .F.
	Local lCombo		:= .F.
	Local lLogic		:= .F.
	Local cStrVrNum		:= ""
	Local cStrAtNum		:= ""
	Local cClass	    := ""
	Local aCombosGen	:= {}
	Local aCombosFoot	:= {}
	Local aLogicalGen	:= {}
	Local aLogicFooter	:= {}
	Local aMemoFlds  	:= {}
	Local lRetCreate	:= .T.
	Local nSize			:= 0
	Default aCabCpo 	:= {}
	Default aItCpo  	:= {}
	Default aRodCpo 	:= {}
	Default cColor 		:= "#0088cb"
	Default cPicture	:= ""
	Default cMessage    := ""
	Default lShowHelp   := .T.

	If Empty(cColor)
		cColor := "#0088cb"
	EndIf

	//Função para verificar se está vazio o cPathFile e se pode gravar na pasta
	aRetFun := NF030PathFile(cPathFile)

	if ( aRetFun[1] == .F. )
		If lShowHelp
			Help(nil, nil , STR0009, nil, aRetFun[2], 1, 0, nil, nil, nil, nil, nil, {STR0017} ) //Atenção - "O arquivo html não será gerado na pasta. Revise as configurações, acesse o registro e salve novamente, para o arquivo ser gerado."
		EndIf

		lRetCreate 	:= lRetFun
		cMessage := aRetFun[2] + ' - ' + STR0032 //-- Revise as configurações. Acesse a documentação do NFC na seção de Workflow para mais informações.
	else
		lRetFun 	:= NF030HtBeg(aCabCpo, cColor, aRetFun[3], cPicture, @cMessage, lShowHelp)
		lRetCreate 	:= lRetFun

		if lRetFun
			cString :='<html>'
			cString += CRLF + CRLF +'	<head>'
			cString += CRLF +'		<meta charset="windows-1252">'
			cString += CRLF +'		<meta charset="UTF-8">'
			cString += CRLF +'		<style>
					/* Os estilos devem ser colocados nas proprias tags para compatibilidade com diversos webmails */
			cString += CRLF +'		</style>
			cString += CRLF +'	</head>	
			cString += CRLF +'	<body style="width: 100%; font: normal normal normal 14px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;overflow-x: hidden" onload="loadValues()">'

			//Logotipo e texto da solicitação
			If !Empty(cPicture)
				cString += CRLF +'<div class="logoitem" style="display: flex; align-items: center;">'
				cString += CRLF + '<img class="logo" style="max-width:130px; height:auto;" src="' + cPicture + '" alt="logo">'
			EndIf

			cString += CRLF +'<h1 style="font: normal normal normal 22px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;color: '+ cColor + ';padding-top: 5px;padding-bottom:3px;margin: 5px auto 5px 10px;">'
			cString += CRLF +'			%cSTR0001% %cNumCot% %cSTR0040% %cProposta%'
			cString += CRLF +'		</h1>'
			cString += CRLF +'</div>'

			//Parte que verifica se a versão está atual ou não - Atualizar sempre que houver alteração por nossa parte e no pgc.workflow.repository
			cString += CRLF +'	<input type=hidden name="CVERSAOHTMLNFC002" value="1">

			cString += CRLF +'        <input name="fornece" id="fornece" type="text" value="%cFornece%" style="display: none;"/>'
			cString += CRLF +'        <input name="loja" id="loja" type="text" value="%cLoja%" style="display: none;"/>'
			cString += CRLF +'		<input name="forNome" id="forNome" type="text" value="%cForNome%" style="display: none;"/>'
			cString += CRLF +'		<input name="paisLoc" id="paisLoc" type="text" value="%cPaisLoc%" style="display: none;"/>'
			cString += CRLF +'		<input name="hasSupObs" id="hasSupObs" type="text" value="%cHasSupObs%" style="display: none;"/>'
			cString += CRLF +'        <input name="draftString" id="draftString" class="draftString" type="text" value="%cSTR0078%" style="display: none;"/>'
			cString += CRLF +'        <input name="savedString" id="savedString" class="savedString" type="text" value="%cSTR0079%" style="display: none;"/>'
			cString += CRLF +'        <input name="replicateDataString" id="replicateDataString" class="replicateDataString" type="text" value="%cSTR0103%" style="display: none;"/>'
			cString += CRLF +'        <input name="requiredObsString" id="requiredObsString" class="requiredObsString" type="text" value="%cSTR0104%" style="display: none;"/>'

			cString += CRLF +'		<!-- Cabeçalho do Pedido --> '
			cString += CRLF +'		<div style="border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">
			cString += CRLF +'			<table style="font: normal normal normal 14px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;text-align: left;border-width:0px;width:100%;">
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0002%</td> 
			cString += CRLF +'					<td style="width:500px;">%cNomeFor%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0003% </td>
			cString += CRLF +'					<td style="width:500px;">%cDataEmis%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0004%</td> 
			cString += CRLF +'					<td style="width:500px;">%cCNPJFor%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr><td colspan="04"><hr></td></tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0005%</td> 
			cString += CRLF +'					<td style="width:500px;">%cNomeCli%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0041%</td> 
			cString += CRLF +'					<td style="width:500px;">%cFilCot% - %cNomeFil%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0004%</td> 
			cString += CRLF +'					<td style="width:500px;">%cCNPJCli%</td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0006%</td> 
			cString += CRLF +'					<td colspan="03">%cEndeCli%		   </td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0007%</td>
			cString += CRLF +'					<td style="width:500px;">%cCepCli% </td>
			cString += CRLF +'				</tr>
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">%cSTR0008%</td>
			cString += CRLF +'					<td style="width:500px;">%cFoneCli%</td>
			cString += CRLF +'				</tr>

				for nCab := 1 to len(aCabCpo)
					cString += CRLF +'				<tr>
					cString += CRLF +'					<td style="width:100px;">'  + GetSX3Cache(aCabCpo[nCab][1], "X3_TITULO") + '</td>
					cString += CRLF +'					<td style="width:500px;">%' + aCabCpo[nCab][1] + '%</td>
					cString += CRLF +'				</tr>
				next nCab

			cString += CRLF +'			</table>
			cString += CRLF +'		</div>
					
			cString += CRLF +'		<!-- Itens do Pedido -->
			cString += CRLF +'		<form name="FrontPage_Form1" id="FrontPage_Form1" method="post" action="mailto:%25WFMailTo%25">
			cString += CRLF +'			<div style="overflow: auto; border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">
			cString += CRLF +'				<h2 style="font: normal normal normal 18px'
			cString += CRLF +" 'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #4a5c60;;">
			cString += CRLF +'					%cSTR0009%
			cString += CRLF +'				</h2>
			cString += CRLF +'				<table id="tableItems" class="tableItems" style="font: normal normal normal 14px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;text-align: left;width:100%;border-collapse: collapse;">'
			cString += CRLF +'					<thead style="font: normal normal normal 12px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif; background: ' + cColor + '; color:White; text-align: left; border-width: 0px;">'
			cString += CRLF +'						<tr>'
			cString += CRLF +'							<th align="center" style="display: none; white-space: nowrap; padding: 4px 8px;">%cSTR0066%</th> <!-- Produto-->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0010%</th> <!-- Descrição -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0069%</th> <!-- Un.Medida -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0011%</th> <!-- Quantidade -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0012%</th> <!-- Entrega -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0013%</th> <!-- Valor Unitário -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0014%</th> <!-- Qtde.Disponível -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0046%</th> <!-- Subtotal -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0026%</th> <!-- Desconto% -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0048%</th> <!-- Desconto Moeda -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;" id="thValorIPI" class="thValorIPI" >%cSTR0080%</th> <!-- Valor IPI -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;" id="thValorIPI" class="thValorICMSSOL" >%cSTR0081%</th> <!-- Val ICMS Sol -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0049%</th> <!-- Situacao -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;">%cSTR0097%</th> <!-- Observações -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;" id="thcObservacao" class="thcObservacao">%cSTR0093%</th> <!-- Observacao SC -->'
			cString += CRLF +'							<th align="center" style="white-space: nowrap; padding: 4px 8px;" id="thcObsForn" class="thcObsForn">%cSTR0094%</th> <!-- Observacao fornecedor -->'

			for nIt := 1 to len(aItCpo)
				cCpoType := GetSx3Cache(aItCpo[nIt][1], 'X3_TIPO')

				If cCpoType == "M"
					cString += CRLF +'<th align="center" style="white-space: nowrap; padding: 4px 8px;" id="th'+aItCpo[nIt][1]+'" class="th'+aItCpo[nIt][1]+'">' + GetSX3Cache(aItCpo[nIt][1], "X3_TITULO") + '</th>
				Else
					cString += CRLF +'<th align="center" style="white-space: nowrap; padding: 4px 8px;">' + GetSX3Cache(aItCpo[nIt][1], "X3_TITULO") + '</th>
				EndIf
			next nIt

			cString += CRLF +'						</tr>'
			cString += CRLF +'					</thead>'

			cString += CRLF +'					<tbody>'
			cString += CRLF +'						<tr style="height: 30px;" class="item">
			cString += CRLF +'							<td style="display: none;">%It.cCodProd%</td> <!-- Produto -->
			cString += CRLF +'							<td class="product" id="%It.cItem%" style="width:155px; border-bottom: 1px solid #ddd;">%It.cProDesc%</td> <!-- Descrição -->
			cString += CRLF +'							<td class="measureUnit" align="center" style="width:70px; border-bottom: 1px solid #ddd;">%It.cUnMedida%</td> <!-- Un.Medida -->
			cString += CRLF +'							<td class="quantityRequested" align="center" value="It.nQuant" style="width:79px; border-bottom: 1px solid #ddd;">%It.nQuant%</td><!-- Quantidade -->
			cString += CRLF +'							<td align="center" style="width:75px; border-bottom: 1px solid #ddd;"><!-- Entrega -->
			cString += CRLF +'								<input id="deliverydate" class="deliverydate" onblur="myFunction(event)" type="date" required style="width: 110px;border-radius: 5px;height: 30px;border: solid 1px;" name="dataentrega" value="%It.cDtEnt%">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td style="width:79px; border-bottom: 1px solid #ddd;" ><!-- Valor Unitário -->
			cString += CRLF +'								<input id="unitaryValue" class="unitaryValue" onchange="myFunction(event)" size="%It.cSizeValor%" style="text-align:right;width: 100%; " type="number" step="%It.cStepValor%" min="0" name="nValor" value="%It.nValor%">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td align="right" style="width:45px;border-bottom: 1px solid #ddd;"><!-- Qtde.Disponível -->
			cString += CRLF +'								<input id="quantity" class="quantity" onchange="myFunction(event)" size=12 style="text-align:right;width: 100%; " type="number" min="0" step="%It.cStepQuant%" name="nQtDisp" value="%It.nQtDisp%">
			cString += CRLF +'								<input class="centralized" name="centralized" id="centralized" type="text" value="%It.Desativado%" style="display: none;"/>
			cString += CRLF +'							</td>
			cString += CRLF +'							<td class="totalItem" align="center" style="width:95px; border-bottom: 1px solid #ddd;" size="%It.cSizeTotal%" step="%It.cStepTotal%"> %It.nSubTotal% </td><!-- subtotal -->
			cString += CRLF +'							<td align="right" style="width:30px;border-bottom: 1px solid #ddd;"><!-- Desconto %-->
			cString += CRLF +'								<input id="descPercent" class="descPercent" onchange="myFunction(event)" style="text-align:right;width: 100%; " type="number" min="0" max="100" step="%It.cStepDesc%" name="nPercDesc" value="%It.nPercDesc%" size="7" maxlength="5">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td align="right" style="width:55px;border-bottom: 1px solid #ddd;"><!-- Desconto moeda -->
			cString += CRLF +'								<input id="desconto" class="desconto" onchange="myFunction(event)" size=12 style="text-align:right;width: 100%; " type="number" min="0"  name="nValDesc" value="%It.nValDesc%" step="0.01">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td align="right" id="tdValorIPI" class="tdValorIPI" style="width:55px;border-bottom: 1px solid #ddd;"><!-- Valor IPI -->
			cString += CRLF +'								<input id="valorIPI" class="valorIPI" onchange="myFunction(event)" size=12 style="text-align:right;width: 100%; " type="number" min="0"  name="nValIPI" value="%It.nValIPI%" step="%It.cStepValIPI%">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td align="center" id="tdValorICMSSOL" class="tdValorICMSSOL" style="width:55px;border-bottom: 1px solid #ddd;"><!-- Valor ICMS Sol -->
			cString += CRLF +'								<input id="valorICMSSOL" class="valorICMSSOL" onchange="myFunction(event)" size=12 style="text-align:right;width: 100%; " type="number" min="0"  name="nValICMS" value="%It.nValICMSSOL%" step="%It.cStepValICMS%">
			cString += CRLF +'							</td>
			cString += CRLF +'							<td align="center" style="width:83px; border-bottom: 1px solid #ddd;">
			cString += CRLF +'								<select id="cSituacao" class="cSituacao" name="cSituacao" onchange="changeStatus(event)" style="width: 100%; height: 21px;"><!-- Situacao -->
			cString += CRLF +'									<option value="1">%cSTR0056%</option>
			cString += CRLF +'									<option value="2">%cSTR0058%</option>
			cString += CRLF +'									<option value="3">%cSTR0057%</option>
			cString += CRLF +'								</select>
			cString += CRLF +'								<input class="situacao" style="display: none;" value=%It.cSituacao%>
			cString += CRLF +'							</td>

			cString += CRLF +'							<td align="center" style="width:40px; border-bottom: 1px solid #ddd;">
			cString += CRLF +'								<button onclick="editObservation(this, 
			cString += "'%It.cObservacao%', '%It.cObsForn%'

			For nIt := 1 to len(aItCpo)
				cCpoType := GetSx3Cache(aItCpo[nIt][1], 'X3_TIPO')

				If cCpoType == "M"
					cString += ", '%It." + aItCpo[nIt][1] + "%'
				EndIf
			Next nIt

			cString += ')" type="button" style="background: none; border: none; cursor: pointer; font-size: 16px; color: ' + cColor + ';">
			cString += CRLF +'									(...)
			cString += CRLF +'								</button>
			cString += CRLF +'							</td>
										
			cString += CRLF +'							<td align="right" style="width:150px;border-bottom: 1px solid #ddd; display: none;">
			cString += CRLF +'								<input size=12 style="text-align:left;width: 100%;" type="text" class="cObservacao" name="cObservacao" value="%It.cObservacao%" disabled="true">
			cString += CRLF +'							</td>
											
			cString += CRLF +'							<td align="right" style="width:150px;border-bottom: 1px solid #ddd; display: none;">
			cString += CRLF +'								<input size=12 style="text-align:left;width: 100%;" type="text" class="cObsForn" name="cObsForn" value="%It.cObsForn%">
			cString += CRLF +'							</td>

				for nIt := 1 to len(aItCpo)
					aSizeCpo := TamSX3(aItCpo[nIt][1])
					cCpoType := aSizeCpo[3]

					aCombo := GetCombo(aItCpo[nIt][4], aItCpo[nIt][1])
					
					nSize 	 := aSizeCpo[1]
					lObrigat := aItCpo[nIt][3]

					cString += CRLF +'<td style="width:79px; border-bottom: 1px solid #ddd;' + iif(cCpoType == "M", 'display: none;', '') + '"  >

					if Len(aCombo) > 0
						if aItCpo[nIt][2] == "VISUAL"
							cString += CRLF +'	<select disabled=true class="a'+aItCpo[nIt][1]+'" id="a'+aItCpo[nIt][1]+'" name="a'+aItCpo[nIt][1]+'" style="text-align:left;width: 100%;">'
						Else
							cString += CRLF +'	<select ' + iif(lObrigat, 'required', '') + ' class="a'+aItCpo[nIt][1]+'" id="a'+aItCpo[nIt][1]+'" name="a'+aItCpo[nIt][1]+'" style="text-align:left;width: 100%;" onchange="fRefreshCombo(event,' + "'" + aItCpo[nIt][1] + "'" +' )">' "
						EndIf

						For nX := 1 To Len(aCombo)
							cString += CRLF +'		<option value="'+aCombo[nX]['value']+'">'+aCombo[nX]['label']+'</option>'
						Next nX

						cString += CRLF +'  </select>'
						cString += CRLF +'  <input class="cb'+aItCpo[nIt][1]+'" id ="' + aItCpo[nIt][1] + '" name ="' + aItCpo[nIt][1] + '"style="display: none;" value="%It.'+aItCpo[nIt][1]+'%">'
						aadd(aCombosGen, aItCpo[nIt][1])

					elseif cCpoType == "M"
						cString += CRLF +' <input size=12 style="text-align:left;width: 100%;" type="text" class="'+aItCpo[nIt][1]+'" name="'+aItCpo[nIt][1]+'" value="%It.'+aItCpo[nIt][1]+'%">
						aadd(aMemoFlds, {aItCpo[nIt][1], aItCpo[nIt][2], aItCpo[nIt][3]})
					elseif cCpoType == "C"
						if aItCpo[nIt][2] == "VISUAL"
							cString += CRLF +'<input disabled=true style="text-align:left;width: 100%;" type="text" maxlength="' + cValtoChar(nSize) + '" class="'+aItCpo[nIt][1]+'" name="'+aItCpo[nIt][1]+'" value="%It.'+aItCpo[nIt][1]+'%" />'
						Else
							cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' style="text-align:left;width: 100%;" type="text" maxlength="' + cValtoChar(nSize) + '" class="'+aItCpo[nIt][1]+'" name="'+aItCpo[nIt][1]+'" value="%It.'+aItCpo[nIt][1]+'%" />'
						EndIf
					elseif cCpoType == "N"
						if ( aSizeCpo[2] > 0 )
							cStep    := IIf(aSizeCpo[2] > 8, "0." + PADR("0", aSizeCpo[2]-1 ,"0") + '1' , Alltrim(STR(1/10**aSizeCpo[2],aSizeCpo[2]+2,aSizeCpo[2])))
						else
							cStep    := Alltrim(STR(1))
						endif

						if aItCpo[nIt][2] == "VISUAL"
							cString += CRLF +'	 <input disabled=true id="'+aItCpo[nIt][1]+'" class="'+aItCpo[nIt][1]+'"  size="'+ALLTRIM(STR(nSize))+'"  style="text-align:right;width: 100%;" type="number"  step="'+cStep+'" name="'+aItCpo[nIt][1]+'"  value="%It.'+aItCpo[nIt][1]+'%"/>
						else
							cString += CRLF +'	 <input ' + iif(lObrigat, 'required min="'+ cStep +'"', 'min="0"') + ' id="'+aItCpo[nIt][1]+'" class="'+aItCpo[nIt][1]+'"  size="'+ALLTRIM(STR(nSize))+'"  style="text-align:right;width: 100%;"  onchange="myFunction(event)"  type="number"  step="'+cStep+'" name="'+aItCpo[nIt][1]+'"  value="%It.'+aItCpo[nIt][1]+'%"/>
						EndIf
						//Bloco para formatar o número, conforme decimais
						//--------------------------------------------------------
						cStrVrNum	+= CRLF + ' let td' + aItCpo[nIt][1] + ' = item.querySelector(".' + aItCpo[nIt][1] + '");'
						cStrVrNum	+= CRLF + ' let vr' + aItCpo[nIt][1] +' = td' + aItCpo[nIt][1] + '.value;'
						if ( aSizeCpo[2] > 0 )
							cStrVrNum 	+= CRLF + '	let nStep' + aItCpo[nIt][1] + ' = Number(td' + aItCpo[nIt][1] + '.getAttribute("step").length-2);'
						endif
						cStrVrNum   += CRLF + ' if ( (vr' + aItCpo[nIt][1] + ' === "") || (vr' + aItCpo[nIt][1] + ' < 0)) { '
						cStrVrNum 	+= CRLF + '		vr' + aItCpo[nIt][1] + ' = (0).toFixed(nStepValor); }'

						if ( aSizeCpo[2] > 0 )
							cStrAtNum 	+= CRLF + ' td' + aItCpo[nIt][1] + '.value = parseFloat(vr' + aItCpo[nIt][1] + ').toFixed(nStep' +  aItCpo[nIt][1] + ');'
						else
							cStrAtNum 	+= CRLF + ' td' + aItCpo[nIt][1] + '.value = parseInt(vr' + aItCpo[nIt][1] + ');'
						endif
						//--------------------------------------------------------
					
					elseif cCpoType == "D"
						if aItCpo[nIt][2] == "VISUAL"
							cString += CRLF +'<input disabled=true name="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" class="'+aItCpo[nIt][1]+'" type="date" value="%It.'+aItCpo[nIt][1]+'%" style="text-align:right;width: 100%;"/>			
						Else
							cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' name="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" class="'+aItCpo[nIt][1]+'" type="date" value="%It.'+aItCpo[nIt][1]+'%" style="text-align:right;width: 100%;" />'
						EndIf
					elseif cCpoType == "L"
						if aItCpo[nIt][2] == "VISUAL"
							cString += CRLF +'<input class="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" name="'+aItCpo[nIt][1]+'" value="%It.'+aItCpo[nIt][1]+'_%" type="hidden">'
							cString += CRLF +'<input disabled=true name="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" type="checkbox" class="' + aItCpo[nIt][1] + '" value="%It.'+aItCpo[nIt][1]+'%" style="text-align:right;width: 100%;"/>'
						Else
							cString += CRLF +'<input class="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" name="'+aItCpo[nIt][1]+'" value="%It.'+aItCpo[nIt][1]+'_%" type="hidden">'
							cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' name="'+aItCpo[nIt][1]+'" id="'+aItCpo[nIt][1]+'" type="checkbox" class="' + aItCpo[nIt][1] + '" value="%It.'+aItCpo[nIt][1]+'%" style="text-align:right;width: 100%;" onchange="fValidClickItems(event,' + "'" + aItCpo[nIt][1] + "'" +' )"/>'
						EndIf
						aAdd(aLogicalGen, aItCpo[nIt][1])
					endif
					cString += CRLF +'</td>
				next nIt	

			cString += CRLF +'						</tr>
			cString += CRLF +'					</tbody>
			cString += CRLF +'				</table>
			cString += CRLF +'			</div>	

			cString += CRLF +'            <!-- Frete e entrega -->
			cString += CRLF +'            <div style="border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">
			cString += CRLF +'                <h2 style="font: normal normal normal 18px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #4a5c60;">'
			cString += CRLF +'                    %cSTR0028%'
			cString += CRLF +'                </h2>'

			cString += CRLF +'				<div style="display: flex; flex-wrap: wrap; gap: 12px;">'
							
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">'
			cString += CRLF +'						<label for="tipoFrete" style="font-weight: bold; color: #4a5c60;">%cSTR0031%</label>'
			cString += CRLF +'						<select onchange="checkFrete(value)" class="tipoFrete" id="tipoFrete" name="tipoFrete" value="%cTipoFrete%" required style="width: 120px;border-radius: 5px;height: 30px;">'
			cString += CRLF +'							<option value="C">%cSTR0036%</option>'
			cString += CRLF +'							<option value="F">%cSTR0037%</option>'
			cString += CRLF +'							<option value="T">%cSTR0038%</option>'
			cString += CRLF +'							<option value="S">%cSTR0039%</option>'
			cString += CRLF +'							<option value="R">%cSTR0099%</option>'	
			cString += CRLF +'							<option value="D">%cSTR0100%</option>'		
			cString += CRLF +'						</select>'
			cString += CRLF +'					</div>'
				
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0033%</label>
			cString += CRLF +'						<input min="0" name="valorFrete" onchange="nStepFrete()" step="0.01" class="valorFrete" type="number" size="15" value="%nValorFrete%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px;"/>
			cString += CRLF +'						<input name="oldValorFrete" id="oldValorFrete" type="number" step="0.01" style="display: none;" value="%nOldValorFrete%" min="0" size="15"/>
			cString += CRLF +'					</div>
								
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0067%</label>
			cString += CRLF +'						<input  min="0" name="valorDespesa" onchange="nStepDespesa()" step="0.01" class="valorDespesa" type="number" size="15" value="%nValorDespesa%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px;"/>
			cString += CRLF +'						<input name="oldValorDespesa" id="oldValorDespesa" type="number" step="0.01" style="display: none;" value="%nOldValorDespesa%" min="0" size="15"/>
			cString += CRLF +'					</div>
					
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0068%</label>
			cString += CRLF +'						<input  min="0" name="valorSeguro" onchange="nStepSeguro()" step="0.01" class="valorSeguro" type="number" size="15" value="%nValorSeguro%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px;"/>
			cString += CRLF +'						<input name="oldValorSeguro" id="oldValorSeguro" type="number" step="0.01" style="display: none;" value="%nOldValorSeguro%" min="0" size="15"/>
			cString += CRLF +'					</div>
			cString += CRLF +'				</div>

			cString += CRLF +'            </div>
				
			cString += CRLF +'            <!-- Pagamento -->
			cString += CRLF +'            <div style="border-top: solid ' + cColor + ' 2px;padding: 10px 10px 0 10px;margin-right: 15px;margin-top: 10px;">
			cString += CRLF +'                <h2 style="font: normal normal normal 18px'
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #4a5c60;">
			cString += CRLF +'                    %cSTR0027%
			cString += CRLF +'                </h2>
			cString += CRLF +'				<div style="display: flex; flex-wrap: wrap; gap: 12px;">
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0047%</label>
			cString += CRLF +'                		<input class="totalPagar" name="totalPagar" id="totalPagar" type="number" value="%nTotalPagar%" disabled="" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px;" step="%It.cStepTotal%"/>
			cString += CRLF +'					</div>
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label for="listCond" style="font-weight: bold; color: #4a5c60;">%cSTR0029%</label>
			cString += CRLF +'						<input autocomplete="on" list="CONDPGTO" name="listCond" id="listCond" value="%cCondicao%" required style="width: 170px;border-radius: 5px;height: 30px; border: solid 1px;"/> 
			cString += CRLF +'						<datalist name="CONDPGTO" id="CONDPGTO">
			cString += CRLF +'						</datalist>
			cString += CRLF +'					</div>
				
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label for="listMoeda" style="font-weight: bold; color: #4a5c60;">%cSTR0050%</label>
			cString += CRLF +'						<input onchange="checkOption()" autocomplete="on" list="MOEDALIST" name="listMoeda" id="listMoeda" value="%cMoeda1%" required style="width: 170px;border-radius: 5px;height: 30px; border: solid 1px;"/> 
			cString += CRLF +'						<datalist name="MOEDALIST" id="MOEDALIST">
			cString += CRLF +'						</datalist>
			cString += CRLF +'					</div>
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0051%</label>
			cString += CRLF +'               		<input name="taxaMoeda" class="taxaMoeda" onchange="nStepTaxa()" type="number" min="0" value="%nTaxaMoeda%" step="%cStepMoeda%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px;"/>			
			cString += CRLF +'					</div>'
			cString += CRLF +'					<div style="display: flex; flex-direction: column;">'
			cString += CRLF +'						<label style="font-weight: bold; color: #4a5c60;">%cSTR0055%</label>
			cString += CRLF +'                		<input name="validade" id="validade" type="date" value="%dValidade%" required style="width: 110px;border-radius: 5px;height: 30px;border: solid 1px;"/>			
			cString += CRLF +'					</div>'

					for nRod := 1 to len(aRodCpo)
						cString += CRLF +'<div style="display: flex; flex-direction: column;">
						cString += CRLF +'	 <label style="font-weight: bold; color: #4a5c60;">'+GetSX3Cache(aRodCpo[nRod][1], "X3_TITULO")+'</label>

						aSizeCpo := TamSX3(aRodCpo[nRod][1])
						aCombo := GetCombo(aRodCpo[nRod][4], aRodCpo[nRod][1])
						cCpoType := aSizeCpo[3]
						lObrigat := aRodCpo[nRod][3]
						nSize 	 := aSizeCpo[1]
						
						if Len(aCombo) > 0
							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF +'	<select disabled=true class="a'+aRodCpo[nRod][1]+'" id="a'+aRodCpo[nRod][1]+'" name="a'+aRodCpo[nRod][1]+'" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;">'
							Else
								cString += CRLF +'	<select ' + iif(lObrigat, 'required', '') + ' class="a'+aRodCpo[nRod][1]+'" id="a'+aRodCpo[nRod][1]+'" name="a'+aRodCpo[nRod][1]+'" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;" onchange="fRefreshComboRodape(event,' + "'" + aRodCpo[nRod][1] + "'" +' )">' "
							EndIf

							For nX := 1 To Len(aCombo)
								cString += CRLF +'		<option value="'+aCombo[nX]['value']+'">'+aCombo[nX]['label']+'</option>'
							Next nX
							cString += CRLF +'  </select>'
							cString += CRLF + ' <input class="cr' + aRodCpo[nRod][1] + '" id ="' + aRodCpo[nRod][1] + '" name ="' + aRodCpo[nRod][1] + '" value="%'+aRodCpo[nRod][1]+'%" style="display: none;" >'
							aadd(aCombosFoot, aRodCpo[nRod][1])

						elseif cCpoType == "C"
							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF +'<input disabled=true style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;" type="text" class="'+aRodCpo[nRod][1]+'" name="'+aRodCpo[nRod][1]+'" value="%'+aRodCpo[nRod][1]+'%" />'
							Else
								cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;" type="text" maxlength="' + cValtoChar(nSize) + '" class="'+aRodCpo[nRod][1]+'" name="'+aRodCpo[nRod][1]+'" value="%'+aRodCpo[nRod][1]+'%" />'
							EndIf
						elseif cCpoType == "N"
							cStep    := IIf(aSizeCpo[2] > 8, "0." + PADR("0", aSizeCpo[2]-1 ,"0") + '1' , Alltrim(STR(1/10**aSizeCpo[2],aSizeCpo[2]+2,aSizeCpo[2])))
							nSize 	 := aSizeCpo[1]

							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF +'	 <input disabled=true class="'+aRodCpo[nRod][1]+'" name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" type="number" value="%'+aRodCpo[nRod][1]+'%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;" size="' + ALLTRIM(STR(nSize)) + '" step="'+cStep+'" />'
							Else
								cString += CRLF +'	 <input ' + iif(lObrigat, 'required min="'+ cStep +'"', 'min="0"') + ' class="'+aRodCpo[nRod][1]+'" name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" type="number" value="%'+aRodCpo[nRod][1]+'%" style="width: 100px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;" size="' + ALLTRIM(STR(nSize)) + '" step="'+cStep+'" onchange="nStepRodape(' +"'"+ aRodCpo[nRod][1] + "'" + ')" />'
							EndIf
						elseif cCpoType == "D"
							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF +'<input disabled=true name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" class="'+aRodCpo[nRod][1]+'" type="date" value="%'+aRodCpo[nRod][1]+'%" style="width: 110px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;"/>			
							Else
								cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" class="'+aRodCpo[nRod][1]+'" type="date" value="%'+aRodCpo[nRod][1]+'%" style="width: 110px;border-radius: 5px;height: 30px;border: solid 1px; margin-right: 10px;"/>			
							EndIf
						elseif cCpoType == "M"
							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF + '<textarea disabled=true id="' + aRodCpo[nRod][1] + '" class="' + aRodCpo[nRod][1] + '" name="' + aRodCpo[nRod][1] + '" style="width: 150px; height: 80px; border: 1px solid #ccc; border-radius: 4px; padding: 5px;">%' + aRodCpo[nRod][1] + '%</textarea>'
							Else
								cString += CRLF + '<textarea ' + iif(lObrigat, 'required', '') + ' id="' + aRodCpo[nRod][1] + '" class="' + aRodCpo[nRod][1] + '" name="' + aRodCpo[nRod][1] + '" style="width: 150px; height: 80px; border: 1px solid #ccc; border-radius: 4px; padding: 5px;">%' + aRodCpo[nRod][1] + '%</textarea>'
							EndIf
						elseif cCpoType == "L"
							If aRodCpo[nRod][2] == "VISUAL"
								cString += CRLF +'<input disabled=true name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" type="checkbox" value="%'+aRodCpo[nRod][1]+'_%" class="' + aRodCpo[nRod][1] + '"style="width: 15px;border-radius: 5px;height: 15px;border: solid 1px; margin-right: 10px;" />'
							Else
								cString += CRLF +'<input class="'+aRodCpo[nRod][1]+'_" id="'+aRodCpo[nRod][1]+'_" name="'+aRodCpo[nRod][1]+'_" value="%'+aRodCpo[nRod][1]+'_%" type="hidden">'
								cString += CRLF +'<input ' + iif(lObrigat, 'required', '') + ' name="'+aRodCpo[nRod][1]+'" id="'+aRodCpo[nRod][1]+'" type="checkbox" value="%'+aRodCpo[nRod][1]+'%" class="' + aRodCpo[nRod][1] + '"style="width: 15px;border-radius: 5px;height: 15px;border: solid 1px; margin-right: 10px;" onchange="fValidClickRodape(' + "'"+ aRodCpo[nRod][1] + "'" + ')"/>'
							EndIf
							aAdd(aLogicFooter, aRodCpo[nRod][1])
						endif

						cString += CRLF +'</div>
					next nRod

			cString += CRLF +'				</div>'
			cString += CRLF +'            </div>'

			cString += CRLF +'			<!-- Tabela oculta que carrega as condições de pagamento -->
			cString += CRLF +'            <table id="tableMoeda" style="display: none;">'
			cString += CRLF +'                <thead>'
			cString += CRLF +'                    <tr>'
			cString += CRLF +'						<td>Value</td>'
			cString += CRLF +'                        <td>Code</td>'
			cString += CRLF +'                    </tr>'
			cString += CRLF +'                </thead>'
			cString += CRLF +'                <tbody>'
			cString += CRLF +'                    <tr>'
			cString += CRLF +'						<td id="value">%Moeda.cValue%</td>
			cString += CRLF +'						<td id="moeda">%Moeda.cMoeda%</td>
			cString += CRLF +'                    </tr>
			cString += CRLF +'                </tbody>
			cString += CRLF +'            </table>
						
			cString += CRLF +'            <!-- Tabela oculta que carrega as condições de pagamento -->
			cString += CRLF +'            <table id="tableCondPgto" style="display: none;">'
			cString += CRLF +'                <thead>'
			cString += CRLF +'                    <tr>'
			cString += CRLF +'                        <td>Code</td>'
			cString += CRLF +'                        <td>Description</td>'
			cString += CRLF +'                    </tr>'
			cString += CRLF +'                </thead>'
			cString += CRLF +'                <tbody>'
			cString += CRLF +'                    <tr>'
			cString += CRLF +'                        <td id="condition">%Cond.cCond%</td>'
			cString += CRLF +'                        <td id="description">%Cond.cDesc%</td>'
			cString += CRLF +'                    </tr>'
			cString += CRLF +'                </tbody>'
			cString += CRLF +'            </table>'
						
			cString += CRLF +'			<!-- Tabela oculta que armazena as situações dos produtos -->
			cString += CRLF +'            <table id="tableStatus" style="display: none;">
			cString += CRLF +'                <thead>
			cString += CRLF +'                    <tr>
			cString += CRLF +'                        <td>Item</td>
			cString += CRLF +'                        <td>Status</td>
			cString += CRLF +'                    </tr>
			cString += CRLF +'                </thead>
			cString += CRLF +'                <tbody>
			cString += CRLF +'                    <tr class="status">
			cString += CRLF +'                        <td id="item">%Stat.cItem%</td>
			cString += CRLF +'                        <td>
			cString += CRLF +'							<input id="status" size=12 style="text-align:left;width: 100%;" type="text" name="cStatus" value="%Stat.cSituacao%">
			cString += CRLF +'						</td>
			cString += CRLF +'                    </tr>
			cString += CRLF +'                </tbody>
			cString += CRLF +'            </table>

			cString += CRLF +'            <!-- Botões de Resposta -->
			cString += CRLF +'            <div style="display: flex;border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;justify-content: flex-end;">
			cString += CRLF +'				<label style="font-weight: bold; color: #4a5c60; margin-right: 5px; margin-top: 18px;">%cSTR0098%</label>
			cString += CRLF +'				<select id="cHasResumWf" class="cHasResumWf" name="cHasResumWf" value="%cHasResumWf%" style="width: 100px;border-radius: 5px;height: 30px; margin-right: 15px; margin-top: 10px;">
			cString += CRLF +'					<option value="1" selected>%cSTR0053%</option>
			cString += CRLF +'					<option value="2">%cSTR0054%</option>
			cString += CRLF +'				</select>

			cString += CRLF +'				<button type="button" name="replicatedate" id="replicatedate"
			cString += CRLF +'					style="border-radius: 5px;cursor: pointer;width: 95px;height: 40px;margin-right: 1em;color: ' + cColor + ';border: solid 2px ' + cColor + ';background-color: white;font-weight: bolder;font-size: 16px;"> %cSTR0088% </button>
			cString += CRLF +'				<button type="button" value="%cSTR0016%" name="B2" id="rejectBtn"
			cString += CRLF +'					style="border-radius: 5px;cursor: pointer;width: 95px;height: 40px;margin-right: 1em;color: ' + cColor + ';border: solid 2px ' + cColor + ';background-color: white;font-weight: bolder;font-size: 16px;"> %cSTR0016% </button>
			cString += CRLF +'				<button type="button" id="draftButton" name="draftButton"
			cString += CRLF +'					style="border-radius: 5px;cursor: pointer;width: 95px;height: 40px;margin-right: 1em;color: ' + cColor + ';border: solid 2px ' + cColor + ';background-color: white;font-weight: bolder;font-size: 16px;"></button>
			cString += CRLF +'				<button id="enviarBtn" type="submit" value="2" name="enviarBtn" 
			cString += CRLF +'					style="border-radius: 5px;cursor: pointer;width: 140px;height: 40px;background-color: ' + cColor + ';border: solid ' + cColor + ';color: white;font-weight: bolder; font-size: 16px;"> %cSTR0015% </button>
			cString += CRLF +'            </div>
			
			cString += CRLF +'			<!-- Modal Recusar -->
			cString += CRLF +'			<div id="modal" class="modal"
			cString += CRLF +'				style=" display: none;position: fixed;z-index: 1;padding-top: 100px;left: 0;
			cString += CRLF +'							top: 0;width: 100%;height: 100%;overflow: auto;	background-color: rgb(0, 0, 0);background-color:rgba(5,45,62,0.7); ">
			cString += CRLF +'				<div class="modal-content"
			cString += CRLF +'					style="background-color: #fefefe;margin: auto;padding: 20px;border: 1px solid #888;width: 50%;">
			cString += CRLF +'					<span class="close" style="color: ' + cColor + ';float: right;font-size: 28px; cursor: pointer;">
			cString += CRLF +'						&times;
			cString += CRLF +'					</span>
			cString += CRLF +'					<p style="font: normal normal normal 18px '
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #4a5c60;">%cSTR0052%
			cString += CRLF +'					</p>
			cString += CRLF +'					<div style="display: flex; justify-content: flex-end;">
			cString += CRLF +'						<button type="button" id="noBtn"
			cString += CRLF +'							style="border-radius: 5px;cursor: pointer;width: 65px;height: 40px;margin-right: 1em;color: ' + cColor + ';border: solid 2px ' + cColor + ';background-color: white;font-weight: bolder;font-size: 16px;">
			cString += CRLF +'							%cSTR0054%
			cString += CRLF +'						</button>
			cString += CRLF +'						<button type="submit" id="yesRejectBtn" value="1" name="%cRecusa%"
			cString += CRLF +'							style="border-radius: 5px;cursor: pointer;width: 65px;height: 40px;background-color: ' + cColor + ';border: solid ' + cColor + ';color: white;font-weight: bolder; font-size: 16px;">
			cString += CRLF +'							%cSTR0053A%
			cString += CRLF +'						</button>
			cString += CRLF +'					</div>
			cString += CRLF +'				</div>
			cString += CRLF +'			</div>


			cString += CRLF +'			<!-- Modal Replicar data -->
			cString += CRLF +'			<div id="modalPrt" class="modalPrt"
			cString += CRLF +'				style=" display: none;position: fixed;z-index: 1;padding-top: 100px;left: 0;
			cString += CRLF +'							top: 0;width: 100%;height: 100%;overflow: auto;	background-color: rgb(0, 0, 0);background-color:rgba(5,45,62,0.7); ">
			cString += CRLF +'				<div class="modalPrt-content"
			cString += CRLF +'					style="background-color: #fefefe;margin: auto;padding: 20px;border: 1px solid #888;width: 50%;">
			cString += CRLF +'					<span class="close2" style="color: ' + cColor + ';float: right;font-size: 28px; cursor: pointer;">
			cString += CRLF +'						&times;
			cString += CRLF +'					</span>
			cString += CRLF +'					<p style="font: normal normal normal 18px' 
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #4a5c60;">%cSTR0085% </p>
			cString += CRLF +'					<p style="font: normal normal normal 14px' 
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #000000;">%cSTR0086% </p>
			cString += CRLF +'					<p style="font: normal normal normal 14px' 
			cString += CRLF +"'open sans'"
			cString += CRLF +', sans-serif;font-weight: bold;color: #000000;">%cSTR0087% </p>
			cString += CRLF +'					<div style="display: flex; justify-content: flex-end;">
			cString += CRLF +'						<button type="button" id="noReplicate" value="0"
			cString += CRLF +'							style="border-radius: 5px;cursor: pointer;width: 65px;height: 40px;margin-right: 1em;color:' + cColor + ';border: solid 2px ' + cColor + ';background-color: white;font-weight: bolder;font-size: 16px;">
			cString += CRLF +'							%cSTR0054%
			cString += CRLF +'						</button>
			cString += CRLF +'						<button type="button" id="yesReplicate" name="%yesReplicate%" value="1"
			cString += CRLF +'							style="border-radius: 5px;cursor: pointer;width: 65px;height: 40px;background-color: ' + cColor + ';border: solid ' + cColor + ';color: white;font-weight: bolder; font-size: 16px;">
			cString += CRLF +'							%cSTR0053%
			cString += CRLF +'						</button>
			cString += CRLF +'					</div>
			cString += CRLF +'				</div>
			cString += CRLF +'			</div>

			cString += CRLF +'			<!-- Modal Editar Observação -->
			cString += CRLF +'			<div id="modalEditObservation" class="modal" style="display: none; position: fixed; z-index: 1000; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5);">
			cString += CRLF +'				<div class="modal-content" style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background-color: #fff; border-radius: 8px; width: 400px; padding: 20px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);">
			cString += CRLF +'					<span id="closeModalEdit" style="float: right; font-size: 28px; cursor: pointer; color: ' + cColor + ';">&times;</span>
			cString += CRLF +'					<h3 style="font-size: 18px; color: ' + cColor + '; margin-bottom: 15px;">%cSTR0092%</h3> <!--Editar observações-->
								
			cString += CRLF +'					<div style="margin-bottom: 15px;">
			cString += CRLF +'						<label for="modalObsSC" style="font-weight: bold; display: block; margin-bottom: 5px;">%cSTR0093%</label> <!--Observação da solicitação de compra-->
			cString += CRLF +'						<textarea id="modalObsSC" style="width: 100%; height: 60px; border: 1px solid #ccc; border-radius: 4px; padding: 5px;" readonly></textarea>
			cString += CRLF +'					</div>
								
			cString += CRLF +'					<div style="margin-bottom: 15px;" id="textObsFornece" class="textObsFornece">
			cString += CRLF +'						<label for="modalObsFornecedor" style="font-weight: bold; display: block; margin-bottom: 5px;">%cSTR0094%</label> <!--Observação do fornecedor-->
			cString += CRLF +'						<textarea id="modalObsFornecedor" style="width: 100%; height: 60px; border: 1px solid #ccc; border-radius: 4px; padding: 5px;"></textarea>
			cString += CRLF +'					</div>

			For nIt := 1 To len(aMemoFlds)
				cString += CRLF +'				<div style="margin-bottom: 15px;">
				cString += CRLF +'					<label for="modalObs' + aMemoFlds[nIt][1] + '" style="font-weight: bold; display: block; margin-bottom: 5px;">' + AllTrim(GetSX3Cache(aMemoFlds[nIt][1], "X3_TITULO")) + Iif(aMemoFlds[nIt][3], '*', '') + '</label>
				cString += CRLF +'					<textarea id="modalObs' + aMemoFlds[nIt][1] + '" '+Iif(aMemoFlds[nIt][2] == "VISUAL", 'readonly', '')+' style="width: 100%; height: 60px; border: 1px solid #ccc; border-radius: 4px; padding: 5px;"></textarea>
				cString += CRLF +'				</div>'
			Next nIt
								
			cString += CRLF +'					<div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 25px;">
			cString += CRLF +'						<button id="cancelObservation" type="button" 
			cString += CRLF +'							style="border-radius: 5px; cursor: pointer; width: 95px; height: 35px; color:' + cColor + '; border: solid 2px' + cColor + '; background-color: white; font-weight: bolder; font-size: 14px;">
			cString += CRLF +'							%cSTR0095% <!-- Cancelar -->
			cString += CRLF +'						</button>
			cString += CRLF +'						<button id="saveObservation" type="button" 
			cString += CRLF +'							style="border-radius: 5px; cursor: pointer; width: 120px; height: 35px; background-color: ' + cColor + '; border: solid 2px ' + cColor + '; color: white; font-weight: bolder; font-size: 14px;">
			cString += CRLF +'							%cSTR0096% <!-- Salvar -->
			cString += CRLF +'						</button>
			cString += CRLF +'					</div>
			cString += CRLF +'				</div>
			cString += CRLF +'			</div>
			cString += CRLF +'		</form>

			cString += CRLF +"		<script>
			cString += CRLF +"			const condPgto = document.querySelector('#CONDPGTO');
			cString += CRLF +"           const tableCondPgto = document.querySelectorAll('#tableCondPgto tbody tr');
			cString += CRLF +"			const form = document.getElementById('FrontPage_Form1');
			cString += CRLF +"			const isBrazil = document.querySelector('#paisLoc').value === 'BRA';
			cString += CRLF +"			const hasSupObs = document.querySelector('#hasSupObs').value === 'true';
						
			cString += CRLF +"			const moeda = document.querySelector('#MOEDALIST');
			cString += CRLF +"			const tableMoeda = document.querySelectorAll('#tableMoeda tbody tr');

			cString += CRLF +'			let rejectBtn = document.getElementById("rejectBtn");
			cString += CRLF +'			let yesRejectBtn = document.getElementById("yesRejectBtn");
			cString += CRLF +'			let enviarBtn = document.getElementById("enviarBtn");
			cString += CRLF +"			let draftButton = document.getElementById('draftButton');
			cString += CRLF +'			let modal = document.getElementById("modal");
			cString += CRLF +'			let noBtn = document.getElementById("noBtn");
			cString += CRLF +'			let span = document.getElementsByClassName("close")[0];
			cString += CRLF +'			let isSubmitEvent = false;
			cString += CRLF +'			let _isValidMemo = true;
			cString += CRLF +'			let _isMemoEvent = false;
			cString += CRLF +'			let replicatedate = document.getElementById("replicatedate");
			cString += CRLF +'			let modalReplicate = document.getElementById("modalPrt");
			cString += CRLF +"			let noReplicate = document.getElementById('noReplicate');
			cString += CRLF +"			let yesReplicate = document.getElementById('yesReplicate');
			cString += CRLF +'			let span2 = document.getElementsByClassName("close2")[0];

			cString += CRLF +"			form.addEventListener('keydown', function(event) {
			cString += CRLF +"				if (event.key === 'Enter') { // Impede o envio do formulário quando a tecla Enter é pressionada
			cString += CRLF +'					event.preventDefault();
			cString += CRLF +'				}
			cString += CRLF +'			});

			cString += CRLF +"			window.addEventListener('beforeunload', function (event) {
			cString += CRLF +'				if (!isSubmitEvent && !_isMemoEvent) {
			cString += CRLF +"					const message = 'message'; // Mensagem de confirmação
			cString += CRLF +'					event.returnValue = message; // Standard para navegadores modernos
			cString += CRLF +'					return message;
			cString += CRLF +'				}
			cString += CRLF +'			});

			cString += CRLF +'			minValidity();
			cString += CRLF +'			loadCheckItems();
			cString += CRLF +"			dataListEvent('listCond', 'CONDPGTO');
			cString += CRLF +"			dataListEvent('listMoeda', 'MOEDALIST');

			cString += CRLF +'			for (let i = 0; i < tableCondPgto.length; i++) {
			cString += CRLF +'                let itemCond = tableCondPgto[i];
			cString += CRLF +"                let condition = itemCond.querySelector('#condition').textContent;
			cString += CRLF +"                let description = itemCond.querySelector('#description').textContent;
			cString += CRLF +"                let option = document.createElement('option');

			cString += CRLF +'                option.value = condition;
			cString += CRLF +'                option.innerHTML = description;
			cString += CRLF +'                condPgto.appendChild(option); 
			cString += CRLF +'            }

						//Moeda
			cString += CRLF +'			for (let i = 0; i < tableMoeda.length; i++) {
			cString += CRLF +'                let itemMoeda = tableMoeda[i];
			cString += CRLF +"                let moedaValue = itemMoeda.querySelector('#moeda').textContent;
			cString += CRLF +"				let value = itemMoeda.querySelector('#value').textContent;
			cString += CRLF +"                let option = document.createElement('option');

			cString += CRLF +'                option.value = value;
			cString += CRLF +'                option.innerHTML = moedaValue;
			cString += CRLF +'                moeda.appendChild(option); 
			cString += CRLF +'            }


						// modal
			cString += CRLF +'			rejectBtn.onclick = function() {
			cString += CRLF +'				changeRequiredFields(true, true);
			cString += CRLF +'				changeRequiredItems(true, false, true);
			cString += CRLF +'			}
						
			cString += CRLF +'			yesRejectBtn.onclick = function() {
			cString += CRLF +'				isSubmitEvent = true;
			cString += CRLF +'			}

			cString += CRLF +'			enviarBtn.onclick = function(event) {
			cString += CRLF +"				const form = document.getElementById('FrontPage_Form1');
			cString += CRLF +'				changeRequiredFields(false);
			cString += CRLF +'				changeRequiredItems();

			cString += CRLF +'				if (form.checkValidity() && _isValidMemo) {
			cString += CRLF +'					isSubmitEvent = true;
			cString += CRLF +'				} else if (!_isValidMemo) {
			cString += CRLF +'					event.preventDefault();
			cString += CRLF +'				}
			cString += CRLF +'			}

			cString += CRLF +'			draftButton.onclick = function() {
			cString += CRLF +"				let alertMessage = 'Rascunho salvo com sucesso!';
			cString += CRLF +"				const savedString = document.querySelector('.savedString').value;
							
			cString += CRLF +'				if (savedString) {
			cString += CRLF +'					alertMessage = savedString;
			cString += CRLF +'				}
							
			cString += CRLF +'				changeRequiredFields(true);
			cString += CRLF +'				changeRequiredItems(false, false, true);
			cString += CRLF +'				saveStorage();

			cString += CRLF +'				alert(alertMessage);
			cString += CRLF +'			}

			cString += CRLF +'			//modal para replicar a data para os demais itens
			cString += CRLF +'			replicatedate.onclick = function() {		
			cString += CRLF +'				modalPrt.style.display = "block";
			cString += CRLF +'			}			

			cString += CRLF +'			span.onclick = function() {
			cString += CRLF +'				changeRequiredFields(false);
			cString += CRLF +'				changeRequiredItems(false, false, true);
			cString += CRLF +'				modal.style.display = "none";
			cString += CRLF +'			}

			cString += CRLF +'			noBtn.onclick = function() {
			cString += CRLF +'				changeRequiredFields(false);
			cString += CRLF +'				changeRequiredItems(false, false, true);
			cString += CRLF +'				modal.style.display = "none";
			cString += CRLF +'			}

			cString += CRLF +'			noReplicate.onclick = function() {
			cString += CRLF +'				modalReplicate.style.display = "none";
			cString += CRLF +'			}

			cString += CRLF +'			yesReplicate.onclick = function() {
			cString += CRLF +"				let Message = document.querySelector('.replicateDataString').value;
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');
			cString += CRLF +'				let dateSel		 = tableItems[0].querySelector(".deliverydate").value;;
						
			cString += CRLF +'				for(let i = 0; i < tableItems.length; i++) {
			cString += CRLF +"					tableItems[i].querySelector('.deliverydate').value = dateSel;
			cString += CRLF +'				}
			cString += CRLF +'				modalReplicate.style.display = "none";
			cString += CRLF +'				alert(Message);
			cString += CRLF +'			}

			cString += CRLF +'			span2.onclick = function() {
			cString += CRLF +'				modalReplicate.style.display = "none";
			cString += CRLF +'			}

						//-- Altera obrigatoriedade dos campos do formulário
			cString += CRLF +'			function changeRequiredFields(isRemoveRequired, isRejectModal = false) {
			cString += CRLF +"				let tipoFrete = document.querySelector('#tipoFrete');
			cString += CRLF +"				let listCond = document.querySelector('#listCond');
			cString += CRLF +"				let listMoeda = document.querySelector('#listMoeda');
			cString += CRLF +"				let validade = document.querySelector('#validade');
							
			cString += CRLF +'				if (isRemoveRequired) {
			cString += CRLF +"					tipoFrete.removeAttribute('required');
			cString += CRLF +"					listCond.removeAttribute('required');
			cString += CRLF +"					listMoeda.removeAttribute('required');
			cString += CRLF +"					validade.removeAttribute('required');
			cString += CRLF +'					if (isRejectModal) {
			cString += CRLF +'						modal.style.display = "block";
			cString += CRLF +'					}

			For nRod := 1 To len(aRodCpo)
				If aRodCpo[nRod][3]
					cClass := ''
					aSizeCpo := TamSX3(aRodCpo[nRod][1])
					cCpoType := aSizeCpo[3]

					If aScan(aCombosFoot, aRodCpo[nRod][1]) > 0
						cClass := 'a'
					EndIf

					cString += CRLF + '				const field_'+aRodCpo[nRod][1]+' = document.querySelector(".'+cClass+aRodCpo[nRod][1]+'")
					cString += CRLF + '				field_'+aRodCpo[nRod][1]+'.removeAttribute("required")

					If cCpoType == 'N'
						cString += CRLF + '			field_'+aRodCpo[nRod][1]+'.removeAttribute("min")
					EndIf
				EndIf
			Next nRod

			cString += CRLF +'				} else {
			cString += CRLF +"					tipoFrete.setAttribute('required', 'true');
			cString += CRLF +"					listCond.setAttribute('required', 'true');
			cString += CRLF +"					listMoeda.setAttribute('required', 'true');
			cString += CRLF +"					validade.setAttribute('required', 'true');

			For nRod := 1 To len(aRodCpo)
				If aRodCpo[nRod][3]
					cClass := ''
					aSizeCpo := TamSX3(aRodCpo[nRod][1])
					cCpoType := aSizeCpo[3]

					If aScan(aCombosFoot, aRodCpo[nRod][1]) > 0
						cClass := 'a'
					EndIf

					cString += CRLF + '				const field_'+aRodCpo[nRod][1]+' = document.querySelector(".'+cClass+aRodCpo[nRod][1]+'");
					cString += CRLF + '				field_'+aRodCpo[nRod][1]+'.setAttribute("required", "true");
					
					If cCpoType == 'N'
						cString += CRLF + '			field_'+aRodCpo[nRod][1]+'.setAttribute("min", "0.'+ PADR("0", aSizeCpo[2]-1 ,"0")+'1");
					EndIf
				Endif
			Next nRod

			cString += CRLF +'				}
			cString += CRLF +'			}

						//-- Altera itens obrigatórios
			cString += CRLF +'			function changeRequiredItems(isRejectModal = false, isLoad = false, noValidMemo = false) {
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');
			cString += CRLF +'				let hasValue = true;
			cString += CRLF +'				let isValid = true;
			cString += CRLF +'				let count = 0;
			cString += CRLF +'				_isValidMemo = true;
			cString += CRLF +'				_isMemoEvent = false;

			cString += CRLF +'				for (let i = 0; i < tableItems.length; i++) { //-- Verifica se ao menos um item foi preenchido
			cString += CRLF +'					const tdQuantity = tableItems[i].querySelector(".quantity");
			cString += CRLF +'					const tdUnitaryValue = tableItems[i].querySelector(".unitaryValue");
			cString += CRLF +'					const tdSituation = tableItems[i].querySelector(".cSituacao");

			For nIt := 1 To len(aItCpo)
				If aItCpo[nIt][3]
					cClass := ''
					cCpoType := GetSx3Cache(aItCpo[nIt][1], 'X3_TIPO')
					
					If aScan(aCombosGen, aItCpo[nIt][1]) > 0
						cClass := 'a'
					EndIf

					cString += CRLF + '					const tdField_'+aItCpo[nIt][1]+' = tableItems[i].querySelector(".'+cClass+aItCpo[nIt][1]+'");
					cString += CRLF + '					isValid = isValid && !(!tdField_'+aItCpo[nIt][1]+'.value);

					If cCpoType == 'M'
						cString += CRLF + "					if (tdField_"+aItCpo[nIt][1]+".value.length === 0) { //-- Verifica se o campo memo está preenchido
						cString += CRLF + '						_isValidMemo = false;
						cString += CRLF + '						_isMemoEvent = true;
						cString += CRLF + '					}
					EndIf
				EndIf
			Next nIt

			cString += CRLF +"					if (!_isValidMemo && !isLoad && !isRejectModal && !noValidMemo) { //-- Todos os campos memos obrigatórios devem estar preenchidos
			cString += CRLF +"						let message = document.querySelector('.requiredObsString').value;
			cString += CRLF +"						alert(message);
			cString += CRLF +'						hasValue = false;
			cString += CRLF +'						break;
			cString += CRLF +"					} else if ((tdQuantity.value == 0 || tdUnitaryValue.value == 0 || !isValid) && tdSituation.value == '1') { //-- Todos os itens com situação considerada, devem estar preenchidos
			cString += CRLF +'						hasValue = false;
			cString += CRLF +'						break;
			cString += CRLF +"					} else if (tdSituation.value != '1') {
			cString += CRLF +'						count ++;
			cString += CRLF +'					}
			cString += CRLF +'				}

			cString += CRLF +'				if (count == tableItems.length) { //-- Todos os itens são não vende ou sem estoque
			cString += CRLF +'					hasValue = true;
			cString += CRLF +'				}

			cString += CRLF +'				for(let i = 0; i < tableItems.length; i++) {
			cString += CRLF +'					const tdQuantity = tableItems[i].querySelector(".quantity");
			cString += CRLF +'					const tdUnitaryValue = tableItems[i].querySelector(".unitaryValue");
			cString += CRLF +"					let stepQuant = tdQuantity.getAttribute('step');
			cString += CRLF +"					let stepValor = tdUnitaryValue.getAttribute('step');

			cString += CRLF +'					if ((isRejectModal || hasValue) && !isLoad) { //-- Se for o modal de rejeição ou tem valores preenchidos, deve remover obrigatoriedade de todos os itens
			cString += CRLF +"						tdQuantity.removeAttribute('required');
			cString += CRLF +"						tdQuantity.removeAttribute('min');

			cString += CRLF +"						tdUnitaryValue.removeAttribute('required');
			cString += CRLF +"						tdUnitaryValue.removeAttribute('min');

			For nIt := 1 To len(aItCpo)
				If aItCpo[nIt][3]
					cClass := ''
					cCpoType := GetSx3Cache(aItCpo[nIt][1], 'X3_TIPO')

					If cCpoType == 'M'
						Loop
					EndIf

					If aScan(aCombosGen, aItCpo[nIt][1]) > 0
						cClass := 'a'
					EndIf

					cString += CRLF + '					const tdField_'+aItCpo[nIt][1]+' = tableItems[i].querySelector(".'+cClass+aItCpo[nIt][1]+'");
					cString += CRLF + '					tdField_'+aItCpo[nIt][1]+'.removeAttribute("required");

					If cCpoType == 'N'
						cString += CRLF + '				tdField_'+aItCpo[nIt][1]+'.removeAttribute("min");
					EndIf
				EndIf
			Next nIt

			cString += CRLF +'					} else {
			cString += CRLF +"						tdQuantity.setAttribute('required', 'true');
			cString += CRLF +"						tdQuantity.setAttribute('min', stepQuant);

			cString += CRLF +"						tdUnitaryValue.setAttribute('required', 'true');
			cString += CRLF +"						tdUnitaryValue.setAttribute('min', stepValor);

			For nIt := 1 To len(aItCpo)
				If aItCpo[nIt][3]
					cClass := ''
					aSizeCpo := TamSX3(aItCpo[nIt][1])
					cCpoType := aSizeCpo[3]

					If cCpoType == 'M'
						Loop
					EndIf

					If aScan(aCombosGen, aItCpo[nIt][1]) > 0
						cClass := 'a'
					EndIf

					cString += CRLF + '					const tdField_'+aItCpo[nIt][1]+' = tableItems[i].querySelector(".'+cClass+aItCpo[nIt][1]+'");
					cString += CRLF + '					tdField_'+aItCpo[nIt][1]+'.setAttribute("required", "true");

					If cCpoType == 'N'
						cStep := iif( (aSizeCpo[2] > 0), "0." + PADR("0", aSizeCpo[2]-1, "0") + "1", Alltrim(STR(1)))
						cString += CRLF + '				tdField_'+aItCpo[nIt][1]+'.setAttribute("min", "' + cStep + '");'
					EndIf
				EndIf
			Next nIt

			cString += CRLF +'					}
			cString += CRLF +'				}
			cString += CRLF +'			}

			cString += CRLF +'			function minValidity() {
			cString += CRLF +"				const dataInput = document.getElementById('validade');
			cString += CRLF +"				const dataDelivery = document.getElementById('deliverydate');
			cString += CRLF +'				const dataAtual = new Date();
			cString += CRLF +'				const ano = dataAtual.getFullYear();
			cString += CRLF +"				const mes = (dataAtual.getMonth() + 1).toString().padStart(2, '0');
			cString += CRLF +"				const dia = dataAtual.getDate().toString().padStart(2, '0');

			cString += CRLF +'				const dataMinima = `${ano}-${mes}-${dia}`;
			cString += CRLF +"				dataInput.setAttribute('min', dataMinima);
			cString += CRLF +"				dataDelivery.setAttribute('min', dataMinima);
			cString += CRLF +'			}

						// function paymentConditionEvent () {
			cString += CRLF +'			function dataListEvent (input, table) {
			cString += CRLF +"				document.getElementById(input).addEventListener('change', function() {
			cString += CRLF +'					let input = this;
			cString += CRLF +'					let datalist = document.getElementById(table);
			cString += CRLF +'					let validOption = false;
			cString += CRLF +'					for (let i = 0; i < datalist.options.length; i++) { // Verifica se o valor inserido corresponde a uma opção da datalist
			cString += CRLF +'						if (input.value === datalist.options[i].value) {
			cString += CRLF +'							validOption = true;
			cString += CRLF +'							break;
			cString += CRLF +'						}
			cString += CRLF +'					}
			cString += CRLF +'					if (!validOption) { // Se o valor não for válido, limpa o campo
			cString += CRLF +"						input.value = '';
			cString += CRLF +'					}
			cString += CRLF +'				});
			cString += CRLF +'			}

			cString += CRLF +'			function nStepTaxa(){
			cString += CRLF +"				let tdTaxaMoeda = document.querySelector('.taxaMoeda');
			cString += CRLF +'				let taxaMoeda = tdTaxaMoeda.value;
			cString += CRLF +"				let nStepTaxa = parseFloat(tdTaxaMoeda.getAttribute('step').length-2);

			cString += CRLF +'				if (taxaMoeda == 0 || taxaMoeda < 0 || isNaN(taxaMoeda)) {
			cString += CRLF +'					taxaMoeda = 0;
			cString += CRLF +'				}

			cString += CRLF +'				tdTaxaMoeda.value = Number(taxaMoeda).toFixed(nStepTaxa);	
			cString += CRLF +'			}

			cString += CRLF +'			function nStepFrete() {
			cString += CRLF +"				let tdValorFrete = document.querySelector('.valorFrete');
			cString += CRLF +"				let tdTotalPagar = document.querySelector('.totalPagar');
			cString += CRLF +"				let tdOldValorFrete = document.querySelector('#oldValorFrete');
			cString += CRLF +'				let valorFrete = parseFloat(tdValorFrete.value);
			cString += CRLF +'				let oldValorFrete = parseFloat(tdOldValorFrete.value);
			cString += CRLF +'				let valorTotal = parseFloat(tdTotalPagar.value);
			cString += CRLF +'			let tdTotalItem = document.querySelector(".totalItem");
			cString += CRLF +"				let nStepTotal = parseFloat(tdTotalItem.getAttribute('step').length-2);

			cString += CRLF +'				if (valorFrete == 0 || valorFrete < 0 || isNaN(valorFrete)) {
			cString += CRLF +'					valorTotal = valorTotal - oldValorFrete;
			cString += CRLF +'					tdTotalPagar.value = valorTotal.toFixed(nStepTotal);
			cString += CRLF +'					tdValorFrete.value = parseFloat(0).toFixed(2);
			cString += CRLF +'					tdOldValorFrete.value = parseFloat(0).toFixed(2);
			cString += CRLF +'				} else {
			cString += CRLF +'					valorTotal = valorTotal - oldValorFrete + valorFrete;
			cString += CRLF +'					tdTotalPagar.value = valorTotal.toFixed(nStepTotal);
			cString += CRLF +'					tdValorFrete.value = valorFrete.toFixed(2);
			cString += CRLF +'					tdOldValorFrete.value = valorFrete.toFixed(2);
			cString += CRLF +'				}
			cString += CRLF +'			}

			cString += CRLF +'			function nStepDespesa() {
			cString += CRLF +"				let tdValorDespesa = document.querySelector('.valorDespesa');
			cString += CRLF +"				let tdTotalPagar = document.querySelector('.totalPagar');
			cString += CRLF +"				let tdOldValorDespesa = document.querySelector('#oldValorDespesa');
			cString += CRLF +'				let valorDespesa = parseFloat(tdValorDespesa.value);
			cString += CRLF +'				let oldValorDespesa = parseFloat(tdOldValorDespesa.value);
			cString += CRLF +'				let valorTotal = parseFloat(tdTotalPagar.value);
			cString += CRLF +'				let tdTotalItem = document.querySelector(".totalItem");
			cString += CRLF +"				let nStepTotal = parseFloat(tdTotalItem.getAttribute('step').length-2);

			cString += CRLF +'				if (valorDespesa == 0 || valorDespesa < 0 || isNaN(valorDespesa)) {
			cString += CRLF +'					valorTotal = valorTotal - oldValorDespesa;
			cString += CRLF +'					tdTotalPagar.value = parseFloat(valorTotal).toFixed(nStepTotal);
			cString += CRLF +'					tdValorDespesa.value = parseFloat(0).toFixed(2);
			cString += CRLF +'					tdOldValorDespesa.value = parseFloat(0).toFixed(2);
			cString += CRLF +'				} else {
			cString += CRLF +'					let diff = valorDespesa - oldValorDespesa;
			cString += CRLF +'					valorTotal = valorTotal - (diff*-1);
			cString += CRLF +'					tdTotalPagar.value = parseFloat(valorTotal).toFixed(nStepTotal);
			cString += CRLF +'					tdValorDespesa.value = parseFloat(tdValorDespesa.value).toFixed(2);
			cString += CRLF +'					tdOldValorDespesa.value = valorDespesa.toFixed(2);
			cString += CRLF +'				}
			cString += CRLF +'			}

			cString += CRLF +'			function nStepSeguro() {
			cString += CRLF +"				let tdValorSeguro = document.querySelector('.valorSeguro');
			cString += CRLF +"				let tdTotalPagar = document.querySelector('.totalPagar');
			cString += CRLF +"				let tdOldValorSeguro = document.querySelector('#oldValorSeguro');
			cString += CRLF +'				let valorSeguro = parseFloat(tdValorSeguro.value);
			cString += CRLF +'				let oldValorSeguro = parseFloat(tdOldValorSeguro.value);
			cString += CRLF +'				let valorTotal = parseFloat(tdTotalPagar.value);
			cString += CRLF +'				let tdTotalItem = document.querySelector(".totalItem");
			cString += CRLF +"				let nStepTotal = parseFloat(tdTotalItem.getAttribute('step').length-2);

			cString += CRLF +'				if (valorSeguro == 0 || valorSeguro < 0 || isNaN(valorSeguro)) {
			cString += CRLF +'					valorTotal = valorTotal - oldValorSeguro;
			cString += CRLF +'					tdTotalPagar.value = parseFloat(valorTotal).toFixed(nStepTotal);
			cString += CRLF +'					tdValorSeguro.value = parseFloat(0).toFixed(2);
			cString += CRLF +'					tdOldValorSeguro.value = parseFloat(0).toFixed(2);
			cString += CRLF +'				} else {
			cString += CRLF +'					let diff = valorSeguro - oldValorSeguro; // Calcula a diferença entre o novo valor do seguro e o valor antigo.
			cString += CRLF +'					valorTotal = valorTotal - (diff*-1);
			cString += CRLF +'					tdTotalPagar.value = parseFloat(valorTotal).toFixed(nStepTotal);
			cString += CRLF +'					tdValorSeguro.value = parseFloat(tdValorSeguro.value).toFixed(2);
			cString += CRLF +'					tdOldValorSeguro.value = valorSeguro.toFixed(2);
			cString += CRLF +'				}
			cString += CRLF +'			}

			//Função para atualizar o campo numérico, quando for campos do rodapé
			cString += CRLF +'			//Função para atualizar o campo numérico, quando for campos do rodapé'
			cString += CRLF +'			function nStepRodape(cCampo){'

			cString += CRLF +"				let tdCmpRodape	= document.querySelector(`.${cCampo}`);"
			cString += CRLF +'				let valorCampo	= tdCmpRodape.value;
			cString += CRLF +"				let nTamStep	= tdCmpRodape.getAttribute('step').length;"
			cString += CRLF +"				let nStepCampo	= ( nTamStep > 1 ) ? parseFloat(tdCmpRodape.getAttribute('step').length-2) : 0;"			

			cString += CRLF +'				if (valorCampo == 0 || valorCampo < 0 || isNaN(valorCampo)) {'
			cString += CRLF +'					valorCampo = 0;'
			cString += CRLF +'				}'

			cString += CRLF +'				tdCmpRodape.value = Number(valorCampo).toFixed(nStepCampo);	'
			cString += CRLF +'			}'

			//Função para atualizar o campo lógico, quando for campos do rodapé
			cString += CRLF +'			//Função para atualizar os campos lógicos, quando for campos do rodapé'
			cString += CRLF +'			function fValidClickRodape(cCampo){'
			cString += CRLF +'				(document.getElementById(cCampo).checked) ? document.getElementById(cCampo+"_").value = true : document.getElementById(cCampo+"_").value = false;'
			cString += CRLF +'			}'

			//Função para atualizar o campo lógico, quando for campos dos itens
			cString += CRLF +'			//Função para atualizar os campos lógicos, quando for campos dos itens'
			cString += CRLF +' 			function fValidClickItems(e, cCampo) {'
			cString += CRLF +'				let tdOrigem   = e.target.parentNode;'
			cString += CRLF +'				let inputValue = tdOrigem.querySelector(`input[id="${cCampo}"]`);'
			cString += CRLF +'				(e.target.checked) ? inputValue.value = "true" : inputValue.value = "false"'
			cString += CRLF +'			}'

			//Função para atualizar os checkbox lógico, quando for campos dos itens
			cString += CRLF +'			//Função para atualizar os checkbox, quando for campos dos itens'
			cString += CRLF +'			function loadCheckItems(){'
			cString += CRLF +'				let tableItems = document.querySelectorAll(".item td input[type=checkbox]");'
			cString += CRLF +'				tableItems.forEach(function(item) {'
			cString += CRLF +'					let hdnCheckVal = item.parentElement.querySelector("input[type=hidden]").value;'
			cString += CRLF +'					item.checked = (hdnCheckVal == "true") ? true : false'  
			cString += CRLF +'				});'
			cString += CRLF +'			}'

			cString += CRLF +'			function myFunction(e) {
			cString += CRLF +'				let tdOrigem = e.target.parentNode;				
			cString += CRLF +'				let item = tdOrigem.parentNode; //TR items[i];
			cString += CRLF +'				let tdUnitaryValue = item.querySelector(".unitaryValue");
			cString += CRLF +'				let tdProduct = item.querySelector(".product");
			cString += CRLF +'				let unitaryValue = tdUnitaryValue.value;
			cString += CRLF +'				let tdQuantity = item.querySelector(".quantity");
			cString += CRLF +'				let quantity = tdQuantity.value;
			cString += CRLF +'				let tdTotalItem = item.querySelector(".totalItem");
			cString += CRLF +'				let tdTotalPagar = document.querySelector(".totalPagar");
			cString += CRLF +'				let totalPagar = 0;
			cString += CRLF +'				let desconto = item.querySelector(".desconto");
			cString += CRLF +'				let descPercent = item.querySelector(".descPercent");
			cString += CRLF +'				let quantityRequested = item.querySelector(".quantityRequested");
			cString += CRLF +"				let tdValorFrete = document.querySelector('.valorFrete');
			cString += CRLF +'				let valorFrete = tdValorFrete.value;
			cString += CRLF +"				let tdValorDespesa = document.querySelector('.valorDespesa');
			cString += CRLF +'				let valorDespesa = tdValorDespesa.value;
			cString += CRLF +"				let tdValorSeguro = document.querySelector('.valorSeguro');
			cString += CRLF +'				let valorSeguro = tdValorSeguro.value;
			cString += CRLF +'				let tddataEntrega = item.querySelector(".deliverydate");
			cString += CRLF +'				let cdataEntrega = tddataEntrega.value;						
			cString += CRLF +'				let tdIPIValue;
			cString += CRLF +'				let valorIPI;
			cString += CRLF +'				let tdICMSValue;
			cString += CRLF +'				let valorICMS;

			cString += CRLF +'				if (isBrazil) {
			cString += CRLF +'					tdIPIValue  = item.querySelector(".valorIPI");
			cString += CRLF +'					valorIPI    = tdIPIValue.value;
			cString += CRLF +'					tdICMSValue = item.querySelector(".valorICMSSOL");
			cString += CRLF +'					valorICMS   = tdICMSValue.value;
			cString += CRLF +'				}
															
			cString += CRLF +'				let items = document.querySelectorAll(".item");

			cString += CRLF +"				let nStepQuant = Number(tdQuantity.getAttribute('step').length-2);
			cString += CRLF +"				let nStepValor = Number(tdUnitaryValue.getAttribute('step').length-2);
			cString += CRLF +"				let nStepDesc = Number(descPercent.getAttribute('step').length-2);
			cString += CRLF +"				let nStepTotal = Number(tdTotalItem.getAttribute('step').length-2);
			cString += CRLF +'				let nStepIPI;
			cString += CRLF +'				let nStepICMS;

			if ( !empty(cStrVrNum) )
				cString += CRLF + cStrVrNum
			endif

			if ( !empty(cStrAtNum) )
				cString += CRLF + cStrAtNum
			endif			
							
			cString += CRLF +"				if (unitaryValue === '') {
			cString += CRLF +'					unitaryValue = "0";
			cString += CRLF +'				}

			cString += CRLF +"				if (quantity === '') {
			cString += CRLF +'					quantity = "0";
			cString += CRLF +'				}

			cString += CRLF +'				tdUnitaryValue.value = parseFloat(unitaryValue).toFixed(nStepValor);
			cString += CRLF +'				tdQuantity.value = parseFloat(quantity).toFixed(nStepQuant);
			cString += CRLF +'				tdTotalItem.textContent = parseFloat(quantity*unitaryValue).toFixed(nStepTotal);

			cString += CRLF +'				if (isBrazil) {
			cString += CRLF +"					nStepIPI = Number(tdIPIValue.getAttribute('step').length-2);
			cString += CRLF +"					nStepICMS = Number(tdICMSValue.getAttribute('step').length-2);
			cString += CRLF +'					tdIPIValue.value = Number(valorIPI).toFixed(nStepIPI);
			cString += CRLF +'					tdICMSValue.value = Number(valorICMS).toFixed(nStepICMS);
			cString += CRLF +'				}
							

			cString += CRLF +"				if (e.target.getAttribute('class') == 'unitaryValue') {
			cString += CRLF +'					let linDesc= item.querySelector(".desconto");
			cString += CRLF +'					let linDescPer= item.querySelector(".descPercent");
			cString += CRLF +'					linDesc.value = (0).toFixed(2);
			cString += CRLF +'					linDescPer.value = (0).toFixed(nStepDesc);

			cString += CRLF +'					if (isBrazil) {
			cString += CRLF +'						tdIPIValue.value = (0).toFixed(nStepIPI);
			cString += CRLF +'						tdICMSValue.value = (0).toFixed(nStepICMS);		
			cString += CRLF +'					}
			cString += CRLF +'				} 

			cString += CRLF +"				else if (e.target.getAttribute('class') == 'descPercent'){
			cString += CRLF +'					desconto.value = parseFloat(parseFloat(tdTotalItem.textContent) * descPercent.value / 100).toFixed(2);
			cString += CRLF +'				}

			cString += CRLF +"				else if (e.target.getAttribute('class') == 'deliverydate') {
			cString += CRLF +'					let newDateCmp = new Date().toISOString().substring(0,10);
			cString += CRLF +'					var dataComp = new Date(cdataEntrega);

			cString += CRLF +"					if ( cdataEntrega === '' || dataComp < new Date() ) {
			cString += CRLF +'						tddataEntrega.value = newDateCmp;
			cString += CRLF +'					} 
			cString += CRLF +'				}

			cString += CRLF +"				else if (e.target.getAttribute('class') == 'desconto'){
			cString += CRLF +'					descPercent.value = Number(desconto.value / parseFloat(tdTotalItem.textContent) * 100).toFixed(nStepDesc);	
			cString += CRLF +'				}

			cString += CRLF +'				desconto.value = Number(desconto.value).toFixed(2);
			cString += CRLF +'				descPercent.value = Number(descPercent.value).toFixed(nStepDesc);

							// Valores invalidos
			cString += CRLF +'				if (descPercent.value > 99.99){
			cString += CRLF +'					descPercent.value = 99.99;
			cString += CRLF +'					desconto.value = Number(parseFloat(tdTotalItem.textContent) * descPercent.value / 100).toFixed(2);
			cString += CRLF +'				}

			cString += CRLF +'				else if (descPercent.value < 0 || desconto.value < 0 ){
			cString += CRLF +'					descPercent.value = (0).toFixed(nStepDesc);
			cString += CRLF +'					desconto.value = parseFloat((tdTotalItem.textContent) * descPercent.value / 100).toFixed(2);
			cString += CRLF +'				}

			cString += CRLF +'				else if ( tdQuantity.value > parseFloat(quantityRequested.textContent) || tdQuantity.value < 0) {
			cString += CRLF +'					tdQuantity.value = parseFloat(quantityRequested.textContent).toFixed(nStepQuant);
			cString += CRLF +'					tdTotalItem.textContent = parseFloat(tdQuantity.value*unitaryValue).toFixed(nStepTotal);
			cString += CRLF +'				}

			cString += CRLF +'				else if ( tdUnitaryValue.value < 0 ) {
			cString += CRLF +'					tdUnitaryValue.value = (0).toFixed(nStepValor);
			cString += CRLF +'					tdTotalItem.textContent = parseFloat(quantity*tdUnitaryValue.value).toFixed(nStepTotal);
			cString += CRLF +'				}

			cString += CRLF +'				else if (isBrazil && ( valorIPI >= Number(parseFloat(tdTotalItem.textContent)) || valorIPI < 0 )) {
			cString += CRLF +'					tdIPIValue.value = (0).toFixed(nStepIPI);
			cString += CRLF +'				}

			cString += CRLF +'				else if (isBrazil && ( valorICMS >= Number(parseFloat(tdTotalItem.textContent)) || valorICMS < 0)) {
			cString += CRLF +'					tdICMSValue.value = (0).toFixed(nStepICMS);
			cString += CRLF +'				}
							
			cString += CRLF +'				for (let i = 0; i < items.length; i++) {
			cString += CRLF +'					let totalItem 		= items[i].querySelector(".totalItem");				
			cString += CRLF +'					let desconto 		= items[i].querySelector(".desconto");
			cString += CRLF +'					let ipivalorimp; 	
			cString += CRLF +'					let icmssolvalorimp;

			cString += CRLF +'					if (isBrazil) {
			cString += CRLF +'						ipivalorimp  	= items[i].querySelector(".valorIPI");
			cString += CRLF +'						icmssolvalorimp = items[i].querySelector(".valorICMSSOL");
			cString += CRLF +'					}

			cString += CRLF +'					totalPagar += parseFloat(totalItem.textContent);
			cString += CRLF +'					totalPagar -= parseFloat(desconto.value);

			cString += CRLF +'					if (isBrazil) {
			cString += CRLF +'						totalPagar += Number(ipivalorimp.value);
			cString += CRLF +'						totalPagar += Number(icmssolvalorimp.value);
			cString += CRLF +'					}
			cString += CRLF +'				}
			cString += CRLF +'				totalPagar += parseFloat(valorFrete);
			cString += CRLF +'				totalPagar += parseFloat(valorDespesa);
			cString += CRLF +'				totalPagar += parseFloat(valorSeguro);
			cString += CRLF +'				tdTotalPagar.value = parseFloat(totalPagar).toFixed(nStepTotal);
			cString += CRLF +'			}

						// desabilita/habilita campo de taxa de moeda
			cString += CRLF +'			function checkOption() {
			cString += CRLF +"				let taxaMoeda = document.querySelector('.taxaMoeda');
			cString += CRLF +"				let nStepTaxa = Number(taxaMoeda.getAttribute('step').length-2);
			cString += CRLF +"				let moeda = document.querySelector('#listMoeda').value
							
			cString += CRLF +'				if (moeda == "1") {
			cString += CRLF +'					taxaMoeda.readOnly = true;
			cString += CRLF +'					taxaMoeda.value = Number(0).toFixed(nStepTaxa);
			cString += CRLF +'				} else {
			cString += CRLF +'					taxaMoeda.readOnly = false;
			cString += CRLF +'				}		
			cString += CRLF +'			}

						// desabilita/habilita campo de tipo de frete
			cString += CRLF +'			function checkFrete(value) {
			cString += CRLF +"				let tdValorFrete = document.querySelector('.valorFrete');
			cString += CRLF +"				let tdTotalPagar = document.querySelector('.totalPagar');
			cString += CRLF +'				let valorTotal = tdTotalPagar.value;
			cString += CRLF +'				let valorFrete = tdValorFrete.value;
			cString += CRLF +"				let tdOldValorFrete = document.querySelector('#oldValorFrete');
			cString += CRLF +'				let tdTotalItem = document.querySelector(".totalItem");
			cString += CRLF +"				let nStepTotal = parseFloat(tdTotalItem.getAttribute('step').length-2);

			cString += CRLF +'				if (value != "C") {
			cString += CRLF +'					tdValorFrete.readOnly = true;
			cString += CRLF +'					tdValorFrete.value = Number(0).toFixed(2);
			cString += CRLF +'					valorTotal = parseFloat(valorTotal) - parseFloat(valorFrete);
			cString += CRLF +'					tdTotalPagar.value = parseFloat(valorTotal).toFixed(nStepTotal);
			cString += CRLF +'					tdOldValorFrete.value = valorFrete;
			cString += CRLF +'				} else {
			cString += CRLF +'					tdValorFrete.readOnly = false;
			cString += CRLF +'				}
			cString += CRLF +'			}

						// atualiza o Status na tabela de status
			cString += CRLF +'			function changeStatus(e) {
			cString += CRLF +'				let tdOrigem = e.target.parentNode;				
			cString += CRLF +'				let item = tdOrigem.parentNode; //TR items[i];
			cString += CRLF +'				let tdProduct = item.querySelector(".product");
			cString += CRLF +'				let tdSituacao = item.querySelector("#cSituacao");
			cString += CRLF +'				let situacao = tdSituacao.options[tdSituacao.selectedIndex].value;
			cString += CRLF +'				let cItem = tdProduct.getAttribute("id");
			cString += CRLF +'				let status = document.querySelectorAll(".status");				
			cString += CRLF +'				
			cString += CRLF +'				for (let i = 0; i < status.length; i++) {
			cString += CRLF +'					let tdItem = status[i].querySelector("#item");
			cString += CRLF +'					let tdStatus = status[i].querySelector("#status");
			cString += CRLF +'					let itemStatus = tdItem.textContent;
								
			cString += CRLF +'					if (itemStatus==cItem) {
			cString += CRLF +'						tdStatus.value = situacao;						
			cString += CRLF +'					}					
			cString += CRLF +'				}

			cString += CRLF +'				let quantity 		= item.querySelector(".quantity");
			cString += CRLF +'				let desconto 		= item.querySelector(".desconto");
			cString += CRLF +'				let descPercent		= item.querySelector(".descPercent");
			cString += CRLF +'				let unitaryValue 	= item.querySelector(".unitaryValue");
			cString += CRLF +'				let valorICMSSOL;
			cString += CRLF +'				let valorIPI;

			cString += CRLF +'				if (isBrazil) {
			cString += CRLF +'					valorICMSSOL = item.querySelector(".valorICMSSOL");
			cString += CRLF +'					valorIPI	 = item.querySelector(".valorIPI");
			cString += CRLF +'				}
							
			cString += CRLF +'				if (situacao != "1") { //-- Zera valores e desativa os campos
			cString += CRLF +'					quantity.value 		= 0;
			cString += CRLF +'					desconto.value 		= 0;
			cString += CRLF +'					descPercent.value 	= 0;
			cString += CRLF +'					unitaryValue.value 	= 0;

			cString += CRLF +'					if (isBrazil) {
			cString += CRLF +'						valorICMSSOL.value	  = 0;
			cString += CRLF +'						valorIPI.value		  = 0;
			cString += CRLF +'						valorICMSSOL.readOnly = true;
			cString += CRLF +'						valorIPI.readOnly 	  = true;	
			cString += CRLF +'					}

			cString += CRLF +'					quantity.readOnly 		= true;
			cString += CRLF +'					desconto.readOnly 		= true;
			cString += CRLF +'					descPercent.readOnly 	= true;
			cString += CRLF +'					unitaryValue.readOnly 	= true;
			cString += CRLF +'				} else {
			cString += CRLF +'					quantity.readOnly		= false;
			cString += CRLF +'					desconto.readOnly 		= false;
			cString += CRLF +'					descPercent.readOnly 	= false;
			cString += CRLF +'					unitaryValue.readOnly 	= false;
			cString += CRLF +'					quantity.value			= (quantity || quantity === 0) ? parseFloat(item.querySelector(".quantityRequested").textContent) : quantity.value;
			cString += CRLF +'					disableQuantity();

			cString += CRLF +'					if (isBrazil) {
			cString += CRLF +'						valorICMSSOL.readOnly = false;
			cString += CRLF +'						valorIPI.readOnly 	  = false;	
			cString += CRLF +'					}
			cString += CRLF +'				}
			cString += CRLF +'				myFunction(e);
			cString += CRLF +'			}


			//Atualiza os combos genéricos na tabela de Itens da cotação
			cString += CRLF +'			//Atualiza os combos genéricos na tabela de Itens da cotação'
			cString += CRLF +'			function fRefreshCombo(e, cCampo) {'
			cString += CRLF +'				let tdOrigem 		= e.target.parentNode;'			
			cString += CRLF +'				let item 			= tdOrigem.parentNode;'
			cString += CRLF +'				let tdCombo 		= item.querySelector(`.a${cCampo}`);'
			cString += CRLF +'				if (tdCombo.selectedIndex >= 0) {
			cString += CRLF +'					let cOptionSlc 		= tdCombo.options[tdCombo.selectedIndex].value;'
			cString += CRLF +'					let cHiddenField 	= item.querySelector(`.cb${cCampo}`);'
			cString += CRLF +'					cHiddenField.value	= cOptionSlc;'
			cString += CRLF +'				}
			cString += CRLF +'			}'


			//Atualiza os combos genéricos no rodapé da cotação
			cString += CRLF +'			//Atualiza os combos genéricos no rodapé da cotação'
			cString += CRLF +'			function fRefreshComboRodape(e, cCampo) {'
			cString += CRLF +"				let tdCombo 		= document.querySelector(`.a${cCampo}`);
			cString += CRLF +'				if (tdCombo.selectedIndex >= 0) {
			cString += CRLF +'					let cOptionSlc 		= tdCombo.options[tdCombo.selectedIndex].value;'
			cString += CRLF +'					let cHiddenField 	= document.querySelector(`.cr${cCampo}`);'
			cString += CRLF +'					cHiddenField.value	= cOptionSlc;'
			cString += CRLF +'				}
			cString += CRLF +'			}'
	
			// Carrega valores pré-definidos
			cString += CRLF +'			function loadValues() {
			cString += CRLF +"				let buttonString = 'Salvar rascunho';
			cString += CRLF +"				const draftString = document.querySelector('.draftString').value;
			cString += CRLF +"				const thValorIpi = document.querySelector('.thValorIPI');
			cString += CRLF +"				const thValorIcmsSol = document.querySelector('.thValorICMSSOL');
			cString += CRLF +"				const table = document.querySelector('.tableItems');
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');
			cString += CRLF +'				changeRequiredItems(false, true);
							
			cString += CRLF +'				if (draftString) {
			cString += CRLF +'					buttonString = draftString;
			cString += CRLF +'				}
							
			cString += CRLF +"				document.querySelector('#draftButton').innerHTML = buttonString;
			cString += CRLF +'				hideTableFields();

			cString += CRLF +'				if (!hasSupObs) { //-- Remove campo observação do fornecedor caso não exista no dicionário
			cString += CRLF +"					const textObsFornece = document.querySelector('.textObsFornece');
			cString += CRLF +"					textObsFornece.style.display = 'none';
			cString += CRLF +'				}

			cString += CRLF +'				if (localStorage.getItem(lastURLParam())) {
			cString += CRLF +'					loadDataByStorage(); //- Carrega dados através do storage
			cString += CRLF +'				} else {
			cString += CRLF +'					loadDataByQuotation(); //-- Carrega dados através da cotação
			cString += CRLF +'				}
			cString += CRLF +'				disableQuantity();
			cString += CRLF +'       	}

						//-- Oculta campos da tabela
			cString += CRLF +'			function hideTableFields() {
			cString += CRLF +'				let hideFields = [];
			cString += CRLF +"				const table = document.querySelector('.tableItems');
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');

			cString += CRLF +'				if (!isBrazil) {
			cString += CRLF +"					hideFields.push('ValorIPI');
			cString += CRLF +"					hideFields.push('ValorICMSSOL');
			cString += CRLF +'				}

			cString += CRLF +"				hideFields.push('cObsForn');
			cString += CRLF +"				hideFields.push('cObservacao');

			For nIt := 1 To Len(aMemoFlds)
				cString += CRLF +"			hideFields.push('" + aMemoFlds[nIt][1] + "');
			Next nIt

			cString += CRLF +'				hideFields.forEach(fieldClass => {
			cString += CRLF +'					// Ocultar o cabeçalho
			cString += CRLF +'					const thElement = document.querySelector(`.th${fieldClass}`);
			cString += CRLF +'					if (thElement) {
			cString += CRLF +"						thElement.style.display = 'none';
			cString += CRLF +'					}

								// Ocultar os elementos da tabela
			cString += CRLF +'					tableItems.forEach(item => {
			cString += CRLF +'						const tdElement = item.querySelector(`.td${fieldClass}`);
			cString += CRLF +'						if (tdElement) {
			cString += CRLF +"							tdElement.style.display = 'none';
			cString += CRLF +'						}
			cString += CRLF +'					});
			cString += CRLF +'				});

							// Ajustar o tamanho das colunas
			cString += CRLF +'				const totalLength = table.offsetWidth;
			cString += CRLF +'				const numCels = table.rows[0].cells.length;
			cString += CRLF +'				const newLength = totalLength / numCels;

			cString += CRLF +'				for (let i = 0; i < numCels; i++) {
			cString += CRLF +'					table.rows[0].cells[i].style.width = newLength + "px";
			cString += CRLF +'				}
			cString += CRLF +'			}

			//-- Carrega valores da cotação na tela
			cString += CRLF +'			function loadDataByQuotation() {
			cString += CRLF +'				// Define valor padrão do select tipoFrete
			cString += CRLF +"				select = document.querySelector('select.tipoFrete');
			cString += CRLF +'				select.value = select.attributes.value.value;
							
			cString += CRLF +'				checkFrete(select.value);'
			cString += CRLF +'				let cGenRodapeValue = "";'
			cString += CRLF +'				let cComboRodapeGen = "";'
			cString += CRLF +'				let cLogRodapeValue = "";'
			cString += CRLF +'				let aGenLogic;'
			cString += CRLF +'				let cGenValue = "";'
			cString += CRLF +'				let aGenSelect; '
			cString += CRLF +'				let cComboGen ; '

			//Atualiza os combos genéricos dos itens
			if ( Len(aCombosGen) > 0 )
				cString += CRLF + "//Atualiza os combos dos itens com os valores provenientes do BD, ao carregar a página"
				cString += CRLF +"		let tableItems = document.querySelectorAll('.item');"
				For nRod := 1 to len(aCombosGen)
					cString += CRLF +'		for (var i = 0; i < tableItems.length; i++) {'
					cString += CRLF +"			aGenSelect = document.querySelectorAll('.item')[i];"
					cString += CRLF +"			cGenValue  = aGenSelect.querySelector('.cb" + aCombosGen[nRod] + "').value;"
					cString += CRLF +"			cComboGen  = aGenSelect.querySelector('.a" + aCombosGen[nRod] + "');"
					cString += CRLF +'			cComboGen.value = cGenValue;'
					cString += CRLF +'		}' + CRLF
				next
				cString += CRLF + ""
			endif


			//Atualiza os combos do rodapé com os valores provenientes do BD, ao carregar a página
			if ( Len(aCombosFoot) > 0 )
				cString += CRLF + "//Atualiza os combos do rodapé com os valores provenientes do BD, ao carregar a página"
				For nRod := 1 to len(aCombosFoot)
					cString += CRLF +"		cGenRodapeValue  = document.querySelector('.cr" + aCombosFoot[nRod] + "').value;"
					cString += CRLF +"		cComboRodapeGen  = document.querySelector('.a" + aCombosFoot[nRod] + "');"
					cString += CRLF +'		cComboRodapeGen.value = cGenRodapeValue;' + CRLF
				next
				cString += CRLF + ""
			endif


			//Atualiza os campos lógicos genéricos do rodapé
			if ( Len(aLogicFooter) > 0 )
				cString += CRLF + "//Atualiza os campos lógicos genéricos do rodapé, com os valores provenientes do BD, ao carregar a página"
				For nRod := 1 to len(aLogicFooter)
					cString += CRLF +"			cLogRodapeValue  = document.getElementById('" + aLogicFooter[nRod] + "').value;"
					cString += CRLF +"			document.getElementById('" + aLogicFooter[nRod] + "').checked = (cLogRodapeValue.toLowerCase() === 'true') ? true : false;"
					cString += CRLF +"			(cLogRodapeValue.toLowerCase() === 'true') ? document.getElementById('"+ aLogicFooter[nRod] + "').value = true : document.getElementById('"+ aLogicFooter[nRod] + "').value = false;
				next
				cString += CRLF + ""
			endif

			// Define valores padrões dos selects de situação
			cString += CRLF +"				var selects = document.querySelectorAll('select.cSituacao');
			cString += CRLF +"				var inputs = document.querySelectorAll('input.situacao');

			cString += CRLF +'				if (selects.length == inputs.length) {
			cString += CRLF +'					for(var i = 0; i < selects.length; i++) {
			cString += CRLF +'						selects[i].value = inputs[i].value;
			cString += CRLF +'						triggerChangeEvent(selects[i]); //-- Atualiza situação
			cString += CRLF +'					}
			cString += CRLF +'				}

			cString += CRLF +"				const listCond = document.querySelector('#listCond');
			cString += CRLF +'				listCond.value = listCond.value.trim();

			cString += CRLF +'				triggerChangeEvent(listCond);


			cString += CRLF +"				const listMoeda = document.querySelector('#listMoeda');
			cString += CRLF +'				listMoeda.value = listMoeda.value.trim();

			cString += CRLF +'				triggerChangeEvent(listMoeda);
			cString += CRLF +"			}

						//-- Carrega valores da cotação através do storage
			cString += CRLF +'			function loadDataByStorage() {
			cString += CRLF +'				let storageValue = localStorage.getItem(lastURLParam());

			cString += CRLF +'				if (storageValue) {
								// Converter a string JSON de volta para um objeto
			cString += CRLF +'					let quotation = JSON.parse(storageValue);

								// Define valor padrão do select tipoFrete
			cString += CRLF +"					select = document.querySelector('select.tipoFrete');
			cString += CRLF +"					select.value = quotation['tipoFrete'];
								
			cString += CRLF +'					checkFrete(select.value); //-- Atualiza frete

								//-- Preenche cabeçalho
			cString += CRLF +"					document.querySelector('select.tipoFrete').value = quotation['tipoFrete'];
			cString += CRLF +"					document.querySelector('.valorFrete'     ).value = quotation['valorFrete'];
			cString += CRLF +"					document.querySelector('.valorDespesa'   ).value = quotation['valorDespesa'];
			cString += CRLF +"					document.querySelector('.valorSeguro'    ).value = quotation['valorSeguro'];
			cString += CRLF +"					document.querySelector('#listCond'       ).value = quotation['listCond'];
			cString += CRLF +"					document.querySelector('#listMoeda'      ).value = quotation['listMoeda'];
			cString += CRLF +"					document.querySelector('.taxaMoeda'      ).value = quotation['taxaMoeda'];
			cString += CRLF +"					document.querySelector('#validade'       ).value = quotation['validade'];

			For nRod := 1 To len(aRodCpo)
				cClass := ''
				lCombo := aScan(aCombosFoot, aRodCpo[nRod][1]) > 0
				lLogic := aScan(aLogicFooter, aRodCpo[nRod][1]) > 0

				If lCombo
					cClass := 'a'
				EndIf
				
				If aRodCpo[nRod][2] == "EDIT" //Só considerar os campos do tipo "Editavel"
				
					cString += CRLF + '				const field_'+aRodCpo[nRod][1]+' = document.querySelector(".'+cClass+aRodCpo[nRod][1]+'");
					cString += CRLF + "				field_"+aRodCpo[nRod][1]+".value = quotation['"+aRodCpo[nRod][1]+"'];

					If lCombo
						cString += CRLF +"			triggerChangeEvent(field_"+aRodCpo[nRod][1]+");
					ElseIf lLogic
						cString += CRLF +"			field_"+aRodCpo[nRod][1]+".checked = (quotation['"+aRodCpo[nRod][1]+"'].toLowerCase() === 'true');"
					EndIf
				EndIf
			Next nRod

			cString += CRLF +"					const selectResumWf = document.querySelector('#cHasResumWf');
			cString += CRLF +"					selectResumWf.value = quotation['resumWf'];

			cString += CRLF +"					triggerChangeEvent(selectResumWf);

			cString += CRLF +"					const tableItems = document.querySelectorAll('.item');

			cString += CRLF +"					if (tableItems.length == quotation['items'].length) {
			cString += CRLF +"						for(let i = 0; i < tableItems.length; i++) {
										//-- Preenche itens
			cString += CRLF +"							tableItems[i].querySelector('.quantity'    ).value = quotation['items'][i]['quantity'];
			cString += CRLF +"							tableItems[i].querySelector('.unitaryValue').value = quotation['items'][i]['unitaryValue'];
			cString += CRLF +"							tableItems[i].querySelector('.descPercent' ).value = quotation['items'][i]['descPercent'];
			cString += CRLF +"							tableItems[i].querySelector('.desconto'    ).value = quotation['items'][i]['desconto'];
			cString += CRLF +"							tableItems[i].querySelector('.cSituacao'   ).value = quotation['items'][i]['cSituacao'];
			cString += CRLF +"							tableItems[i].querySelector('.cObservacao' ).value = quotation['items'][i]['cObservacao'];
			cString += CRLF +"							tableItems[i].querySelector('.cObsForn'    ).value = quotation['items'][i]['cObsForn'];
			cString += CRLF +"							tableItems[i].querySelector('.deliverydate').value = quotation['items'][i]['deliverydate'];
			cString += CRLF +"							if (isBrazil) {
			cString += CRLF +"								tableItems[i].querySelector('.valorIPI'    ).value = quotation['items'][i]['valorIPI'];
			cString += CRLF +"								tableItems[i].querySelector('.valorICMSSOL').value = quotation['items'][i]['valorICMSSOL'];
			cString += CRLF +"							}
				
			cString += CRLF +"							triggerChangeEvent(tableItems[i].querySelector('.cSituacao')); //-- Atualiza status

			For nIt := 1 To len(aItCpo)
				cClass := ''
				lCombo := aScan(aCombosGen, aItCpo[nIt][1]) > 0
				lLogic := aScan(aLogicalGen, aItCpo[nIt][1]) > 0

				If lCombo
					cClass := 'a'
				EndIf

				If lLogic
					cString += CRLF + '						const field_'+aItCpo[nIt][1]+' = tableItems[i].querySelectorAll(".'+cClass+aItCpo[nIt][1]+'")[0]
					cString += CRLF + '						const fieldchk_'+aItCpo[nIt][1]+' = tableItems[i].querySelectorAll(".'+cClass+aItCpo[nIt][1]+'")[1]
				Else 
					cString += CRLF + '						const field_'+aItCpo[nIt][1]+' = tableItems[i].querySelector(".'+cClass+aItCpo[nIt][1]+'")
				EndIf

				cString += CRLF + "						field_"+aItCpo[nIt][1]+".value = quotation['items'][i]['"+aItCpo[nIt][1]+"']

				If lCombo
					cString += CRLF +"					triggerChangeEvent(field_"+aItCpo[nIt][1]+");
				ElseIf lLogic
					cString += CRLF +"					fieldchk_"+aItCpo[nIt][1]+".checked = (quotation['items'][i]['"+aItCpo[nIt][1]+"'].toLowerCase() === 'true');"
				EndIf
			Next nIt

			cString += CRLF +"						}
			cString += CRLF +"					}
			cString += CRLF +"				}
			cString += CRLF +"			}

						//-- Salva o storage
			cString += CRLF +"			function saveStorage() {
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');
			cString += CRLF +"				let items = [];
							
			cString += CRLF +"				tableItems.forEach(function(item) {
			cString += CRLF +"					const itemValues = {
			cString += CRLF +"						'quantity': item.querySelector('.quantity').value,
			cString += CRLF +"						'unitaryValue': item.querySelector('.unitaryValue').value,
			cString += CRLF +"						'descPercent': item.querySelector('.descPercent').value,
			cString += CRLF +"						'desconto': item.querySelector('.desconto').value,
			cString += CRLF +"						'cSituacao': item.querySelector('.cSituacao').value,
			cString += CRLF +"						'cObservacao': item.querySelector('.cObservacao').value,
			cString += CRLF +"						'cObsForn': item.querySelector('.cObsForn').value,
			cString += CRLF +"						'deliverydate': item.querySelector('.deliverydate').value,
			cString += CRLF +"					}

			For nIt := 1 To len(aItCpo)
				cClass := ''
				lCombo := aScan(aCombosGen, aItCpo[nIt][1]) > 0
				lLogic := aScan(aLogicalGen, aItCpo[nIt][1]) > 0
				If aScan(aCombosGen, aItCpo[nIt][1]) > 0
					cClass := 'cb'
				EndIf

				If lLogic
					cString += CRLF + "					itemValues['"+aItCpo[nIt][1]+"'] = item.querySelectorAll('."+cClass+aItCpo[nIt][1]+"')[0].value
				Else 
					cString += CRLF + "					itemValues['"+aItCpo[nIt][1]+"'] = item.querySelector('."+cClass+aItCpo[nIt][1]+"').value
				EndIf
			Next nIt

			cString += CRLF +"					if (isBrazil) {
			cString += CRLF +"						itemValues['valorIPI'] = item.querySelector('.valorIPI').value;
			cString += CRLF +"						itemValues['valorICMSSOL'] = item.querySelector('.valorICMSSOL').value;
			cString += CRLF +"					}
			cString += CRLF +"					items.push(itemValues);
			cString += CRLF +"				});

			cString += CRLF +"				const data = {
			cString += CRLF +"					'tipoFrete': document.querySelector('select.tipoFrete').value,
			cString += CRLF +"					'valorFrete': document.querySelector('.valorFrete').value,
			cString += CRLF +"					'valorDespesa': document.querySelector('.valorDespesa').value,
			cString += CRLF +"					'valorSeguro': document.querySelector('.valorSeguro').value,
			cString += CRLF +"					'listCond': document.querySelector('#listCond').value,
			cString += CRLF +"					'listMoeda': document.querySelector('#listMoeda').value,
			cString += CRLF +"					'taxaMoeda': document.querySelector('.taxaMoeda').value,
			cString += CRLF +"					'validade': document.querySelector('#validade').value,
			cString += CRLF +"					'resumWf': document.querySelector('#cHasResumWf').value,
			cString += CRLF +"					'items': items
			cString += CRLF +"				};

			For nRod := 1 To len(aRodCpo)
				cClass := ''
				If aScan(aCombosFoot, aRodCpo[nRod][1]) > 0
					cClass := 'cr'
				EndIf
				
				If aRodCpo[nRod][2] == "EDIT" //Só considerar os campos do tipo "Editavel"
					cString += CRLF + "			data['"+aRodCpo[nRod][1]+"'] = document.querySelector('."+cClass+aRodCpo[nRod][1]+"').value
				EndIf
			Next nRod

			cString += CRLF +"				localStorage.setItem(lastURLParam(), JSON.stringify(data));
			cString += CRLF +"			}

						//-- Dispara evento change manualmente
			cString += CRLF +"			function triggerChangeEvent(element) {
			cString += CRLF +"				var event = new Event('change');
			cString += CRLF +"				element.dispatchEvent(event);
			cString += CRLF +"			}

						//-- Obter último parâmetro da URL
			cString += CRLF +"			function lastURLParam() {
			cString += CRLF +"				const url = window.location.href;
			cString += CRLF +"				const urlParts = url.split('/');
			cString += CRLF +"				const lastParam = urlParts[urlParts.length - 1].split('.')[0]; // Remover a extensão .htm
			cString += CRLF +"				return lastParam;
			cString += CRLF +"			}


						//-- Desabilitar campo de quantidade disponivel, quando compra centralizada
			cString += CRLF +"			function disableQuantity() {
			cString += CRLF +"				const tableItems = document.querySelectorAll('.item');	
			cString += CRLF +"				for(let i = 0; i < tableItems.length; i++) {
			cString += CRLF +"					if ( tableItems[i].querySelector('.centralized').value === '0') {
			cString += CRLF +"						tableItems[i].querySelector('.quantity').setAttribute('readonly', 'readonly');
			cString += CRLF +"					}
			cString += CRLF +"				}
			cString += CRLF +"			}

			cString += CRLF +"			let currentRow; // Variável para armazenar a linha atual que está sendo editada

						// Função para abrir o modal e carregar os dados da linha
			cString += CRLF +"			function editObservation(button) {
							// Obtém a linha correspondente ao botão clicado
			cString += CRLF +"				currentRow = button.closest('tr');

							// Seleciona os valores existentes na linha
			cString += CRLF +"				const obsSCValue = currentRow.querySelector('.cObservacao')?.value || '';" // Valor da célula "Obs. SC"
			cString += CRLF +"				const obsFornecedorValue = currentRow.querySelector('.cObsForn')?.value || '';" // Valor da célula "Obs. Fornecedor"

							// Define os valores no modal
			cString += CRLF +"				document.getElementById('modalObsSC').value = obsSCValue;
			cString += CRLF +"				document.getElementById('modalObsFornecedor').value = obsFornecedorValue;

			For nIt := 1 To len(aMemoFlds)
				cString += CRLF +"				const memoFieldValue_" + aMemoFlds[nIt][1] + " = currentRow.querySelector('." + aMemoFlds[nIt][1] + "')?.value || '';"
				cString += CRLF +"				document.getElementById('modalObs" + aMemoFlds[nIt][1] + "').value = memoFieldValue_" + aMemoFlds[nIt][1] + ";
			Next nIt

							// Exibe o modal
			cString += CRLF +"				document.getElementById('modalEditObservation').style.display = 'block';
			cString += CRLF +"			}

						// Função para salvar as alterações no modal
			cString += CRLF +"			function saveObservation() {
			cString += CRLF +"				let ok = true
			cString += CRLF +"				if (currentRow) {

			For nIt := 1 To len(aMemoFlds)
				cString += CRLF +"				const memoFieldCell_" + aMemoFlds[nIt][1] + " = currentRow.querySelector('." + aMemoFlds[nIt][1] + "');"
				cString += CRLF +"				if (memoFieldCell_" + aMemoFlds[nIt][1] + ") {"
				
				If aMemoFlds[nIt][3]
					cString += CRLF +"				ok = ok && (document.getElementById('modalObs" + aMemoFlds[nIt][1] + "').value.length > 0); // Verifica se o campo memo não está vazio
				EndIf

				cString += CRLF +"					if (ok) {"
				cString += CRLF +"						memoFieldCell_" + aMemoFlds[nIt][1] + ".value = document.getElementById('modalObs" + aMemoFlds[nIt][1] + "').value; // Atualiza o valor do campo memo"
				cString += CRLF +"					}
				
				cString += CRLF +"				}"
			Next nIt

			cString += CRLF +"					// Atualiza os valores na linha correspondente
			cString += CRLF +"					const obsFornCell = currentRow.querySelector('.cObsForn');
			cString += CRLF +"					if (obsFornCell && ok) {
			cString += CRLF +'						obsFornCell.value = document.getElementById("modalObsFornecedor").value; // Atualiza o valor de "Obs. SC"
			cString += CRLF +"					}

			cString += CRLF +"				}
						// Fecha o modal
			cString += CRLF +"				if (ok) {
			cString += CRLF +"					closeModal();
			cString += CRLF +"				} else {
			cString += CRLF +"					let message = document.querySelector('.requiredObsString').value;
			cString += CRLF +"					alert(message);
			cString += CRLF +"				}
			cString += CRLF +"			}

						// Função para fechar o modal
			cString += CRLF +"			function closeModal() {
			cString += CRLF +"				document.getElementById('modalEditObservation').style.display = 'none';
			cString += CRLF +"			}

						// Eventos para os botões do modal
			cString += CRLF +"			document.getElementById('saveObservation').onclick = saveObservation;
			cString += CRLF +"			document.getElementById('cancelObservation').onclick = closeModal;
			cString += CRLF +"			document.getElementById('closeModalEdit').onclick = closeModal;
			cString += CRLF +"		</script>
			cString += CRLF +"	</body>
			cString += CRLF +"</html>

			if File(aRetFun[3] + cFileName)
				nRet := FErase(aRetFun[3] + cFileName)

				if nRet == 0
					MemoWrite(aRetFun[3] + cFileName, cString)
				else
					If lShowHelp
						Help(nil, nil , STR0009, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção - "Não foi possível apagar o arquivo pgca030_mail001 existente, verifique se o mesmo não está aberto."
					EndIf
					
					cMessage := STR0008 //Não foi possível criar o arquivo <Arquivo>, verifique se o mesmo não está aberto.
					lRetCreate := .F.
				endif
			else 
				MemoWrite(aRetFun[3] + cFileName, cString)
			endif
		endif
	endif

	FwFreeArray(aCombo)
	FwFreeArray(aRetFun)
	FwFreeArray(aCombosGen)
	FwFreeArray(aCombosFoot)
	FwFreeArray(aLogicalGen)
	FwFreeArray(aLogicFooter)
	FwFreeArray(aMemoFlds)
Return lRetCreate


/*/{Protheus.doc} NF030FldWF
	Devolve os campos que deverão ser inseridos no html
@author Leandro Fini
@since 06/2025
@param cOpc --> 1 = Cabeçalho, 2 --> Itens, 3 --> Rodapé
@param cTabPad --> 1 = Retorna todas tabelas, inclusive SC8 e DHU
			   --> 2 = Retorna todas tabelas, exceto SC8 e DHU
@return Nil, nulo.
/*/
Function NF030FldWF(cOpc,cTabPad)
    Local cQuery        as character
    local cAliasTmp     as character
    local oQuery        as object
	local aRet          as array

    default cOpc := ""
	default cTabPad := "1"

    cQuery := ""
	aRet   := {}

    cQuery += "SELECT DKL_TABELA, DKL_CAMPO, DKL_EDIT " 
    cQuery += " FROM "+RetSqlName("DKL")+" DKL "
    cQuery += "WHERE DKL_FILIAL = ? "
    cQuery += "AND DKL_VINC = ? "
    cQuery += " AND DKL.D_E_L_E_T_ = ' '" 

    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetString(1, FWxFilial('DKL'))
    oQuery:SetString(2, cOpc)
    
    cAliasTmp := GetNextAlias()
    cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

    While ( (cAliasTmp)->(!Eof()) )
		if cTabPad == "1" .or. (cTabPad == "2" .and. !(Alltrim((cAliasTmp)->DKL_TABELA) $ "DHU|SC8"))
			aSizeCpo := TamSX3(Alltrim((cAliasTmp)->DKL_CAMPO))
            Aadd(aRet,{Alltrim((cAliasTmp)->DKL_TABELA),Alltrim((cAliasTmp)->DKL_CAMPO),aSizeCpo[3],(cAliasTmp)->DKL_EDIT == "1"})
		endif
		(cAliasTmp)->(DbSkip())
    EndDo

    (cAliasTmp)->(dbCloseArea())
    oQuery:Destroy()
    
Return aRet


/*/{Protheus.doc} NF030COR
Função que exibe uma modal com as cores para seleção do usuário. Como devolve em formato próprio, convertemos para RGB e depois hexadecimal.
@author Renan Martins
@since 06/2025
@return Nil, nulo.
/*/
function NF030COR(lAutoma, oViewAutoma, oModel)
	Local nColor 		:= 0
	Local oModelDKK		:= Nil
	Local oView 		:= FwViewActive()
	Local aRGB			:= {}
	Local cHexColor		:= ""
	Default lAutoma 	:= .F.
	Default oViewAutoma := FwViewActive()
	Default oModel := FwModelActive()

	nColor := if( (!lAutoma), ColorTriangle(), 10000)
	oView := if( (!lAutoma), oView, oViewAutoma)

	if nColor != 0 //Quando cancela, o valor é zero
		aRGB   := ConvRGB(nColor) //a numeração da função é própria, sendo necessário converter para RGB
		oModelDKK := oModel:GetModel("DKKMASTER")

		cHexColor := NTOC(aRGB[1], 16, 2)
		cHexColor += NTOC(aRGB[2], 16, 2)
		cHexColor += NTOC(aRGB[3], 16, 2)
		oModelDKK:LoadValue("DKK_COR", "#" + cHexColor)
		_oPnlColors:nClrPane := nColor 
		NF030RfVw(oView, "VIEW_DKK")
	endif

	FwFreeArray(aRGB)

return nil


//-------------------------------------------------------------------
/*/ {Protheus.doc} NF030VdTable
Atualiza o campo de tabela automaticamente, enquanto pode selecionar apenas as tabelas DHU e SC8, para facilitar a inserção dos dados.
@author renan.martins
@since 06/2025
@version P12
/*/
//-------------------------------------------------------------------
function NF030VdTable(oModel, cValOption)
	Local oObjDKL   	:= oModel:GetModel("DKLDETAIL")
	Local lRet 			:= .T.
	Local cTable		:= ""
	Default oModel		:= FwModelActive()
	Default cValOption	:= "1"

	if !_lNFCWFENV
		if cValOption == "2"
			oObjDKL:LoadValue("DKL_TABELA", "SC8")
		elseif (cValOption $ '1/3')
			oObjDKL:LoadValue("DKL_TABELA", "DHU")
		endif
	endif

	cTable := oObjDKL:GetValue("DKL_TABELA")
	oObjDKL:LoadValue("DKL_CAMPO", "")

	
	if ( cValOption == '2' .And. cTable == 'DHU') //Não deve permitir a tabela DHU nos itens
		oObjDKL:LoadValue("DKL_TABELA", "")
	elseif ( cValOption == '1' .Or. oObjDKL:GetValue("DKL_TABELA") == "DHU" .And. cValOption $ '1/3' ) //Se for cabeçalho ou rodapé, é apenas visualização e não pode obrigar a preencher
		NF030EdtObr(oModel, { {"DKL_OBRIGA", "2"}, {"DKL_EDIT", "2"} })
	endif
return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} NF030VdCmp
Verifica se o campo informado existe na tabela, para constar apenas campos existentes nas tabelas.
@author renan.martins
@since 06/2025
@version P12
/*/
//-------------------------------------------------------------------
function NF030VdCmp(oModel, cValField, cValTable)
	Local lRet			:= .T.
	Local cMsgExb		:= ''
	Local nFor			:= 0
	Local aProtected	:= {"C8_COND", "C8_DATPRF", "C8_DESC", "C8_FILENT", "C8_FILIAL", "C8_FORNECE", "C8_FORNOME", "C8_IDENT", "C8_ITEM", "C8_ITEMSC", "C8_LOJA", "C8_MOEDA", "C8_NUM", "C8_NUMPRO", "C8_NUMSC", "C8_OBS", "C8_OBSFOR", "C8_PRECO", "C8_PRODUTO", +;
						   "C8_QTDISP", "C8_QUANT", "C8_SITUAC", "C8_TOTAL", "C8_TPFRETE", "C8_TXMOEDA", "C8_UM", "C8_VALIPI", "C8_VALSOL", "C8_VLDESC", "C8_WF", "DHU_AGPCOT", "DHU_COMPWF", "DHU_FILIAL", "DHU_LEGACY", "DHU_NUM", "DHU_STATUS", "DHU_TPAMR"}
	Local nTamProtected	:= Len(aProtected)
	Default oModel		:= FwModelActive()
	Default cValField 	:= "XYZ123"
	Default cValTable	:= "ZJ4"

	if Empty(cValTable) .Or. !( (cValTable)->(FieldPos(cValField)) > 0 )
		lRet  	:= .F.
		cMsgExb := STR0010 //"O campo informado não existe na tabela selecionada. Verifique se o nome do campo está correto e existe na tabela."
	else
		For nFor := 1 to nTamProtected
			if ( Alltrim(cValField) == aProtected[nFor] )
				lRet := .F.
				cMsgExb := STR0025 //"O campo informado não pode ser usado, por questões de integridade do sistema."
				exit
			endif
		next
		if ( lRet .And. GetSX3Cache(cValField, "X3_VISUAL") == "V" ) //Se visual, não pode obrigar a ter preenchimentou ou edição
			NF030EdtObr(oModel, { {"DKL_OBRIGA", "2"}, {"DKL_EDIT", "2"} })	
		endif
	endif

	if !lRet
		Help(nil, nil , STR0009, nil, cMsgExb, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção 
	endif
	FwFreeArray(aProtected)		

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} NF030PathFile
Função para validar se o parâmetro do caminho do MV_WFDIR está preenchido e se tem acesso para gravar arquivo na pasta
@author renan.martins
@since 06/2025
@version P12
/*/
//-------------------------------------------------------------------
function NF030PathFile(cPathFile)
	Local lRet			:= .T.
	Local nFile			:= 0
	Local cNameFile		:= "nfca030_save_test.txt"
	Local cMsgError		:= ""
	Default cPathFile	:= ""

	if ( empty(cPathFile) )
		lRet := .F.
		cMsgError := STR0016 //"Parâmetro MV_WFDIR está em branco. Configure o Workflow do NFC corretamente."
	elseif !( ExistDir(cPathFile) )
		lRet := .F.
		cMsgError := STR0020 + " '" + cPathFile + "' " + STR0027 //A pasta definida no parâmetro MV_WFDIR não existe. É necessário criar a pasta: - no diretório do Protheus. Contate o administrador do sistema.
	else
		if Right(cPathFile, 1) != "\"
			cPathFile := cPathFile + "\"
		endif

		nFile := FCreate(cPathFile + cNameFile)
		if ( nFile != -1 )
			FClose(nFile)
			FErase(cPathFile + cNameFile)
		else
			lRet := .F.
			cMsgError := STR0014 + STR0015 + cValtoChar(Ferror()) //"Não foi possível gravar o arquivo no diretório do parâmetro MV_WFDIR." / "Erro retornado: "			
		endif
	endif			

return {lRet, cMsgError, cPathFile}


Function NF030RfVw(oView, cViewName)
	Default oView 		:= FwViewActive()
	Default cViewName	:= "VIEW_DKK"

	If ValType(oView) == "O" .And. oView:IsActive() //Atualizar a view
		oView:Refresh(cViewName)
	EndIf
Return .T.


/*/{Protheus.doc} NF030HtBeg
	Geração do template HTML para workflow, que é recebido direto no e-mail
@author renan.martins
@param aCabCpo, array, campos do cabeçalho.
@param cColor, character,  cor hexadecimal selecionada pelo usuário.
@param cPathFile, character, caminho dos arquivos HTML.
@since 06/2025
/*/
Function NF030HtBeg(aCabCpo, cColor, cPathFile, cPicture, cMessage, lShowHelp)

	Local nCab 			:= 1
	Local nRet			:= 0
	Local cString		:= ""
	Local cFileName		:= "pgca030_mail002.html"
	Local lRetFun		:= .T.
	Default aCabCpo 	:= {}
	Default cColor 		:= "#0088cb"
	Default cPathFile	:= ""
	Default cPicture	:= ""
	Default cMessage	:= ""
	Default lShowHelp	:= .T.

	cString :='<html>'
	cString += CRLF + CRLF +'	<head>'
	cString += CRLF +'		<meta charset="windows-1252">'
	cString += CRLF +'		<meta charset="UTF-8">'
	cString += CRLF +'		<style>
			/* Os estilos devem ser colocados nas proprias tags para compatibilidade com diversos webmails */
	cString += CRLF +'		</style>
	cString += CRLF +'	</head>	

	cString += CRLF +'	<body style="width: 100%; font: normal normal normal 14px '
	cString += CRLF + "'open sans'"
	cString += CRLF + ', sans-serif;overflow-x: hidden">'

	//Logotipo e texto da Solicitação
	If !Empty(cPicture)
		cString += CRLF + '	<div class="logoitem" style="display: flex; align-items: center; gap: 20px; margin: 20px">'
		cString += CRLF + '	<img class="logo" style="max-width:150px; height:auto;" src="' + cPicture + '" alt="logo">'
	EndIf

	cString += CRLF + '	<h1 style="font: normal normal normal 22px '
	cString += CRLF + "	'open sans'"
	cString += CRLF + '	, sans-serif;color: '+ cColor + ';padding-top: 5px;padding-bottom:3px;margin: 5px auto 5px 10px;">'
	cString += CRLF + '				%cSTR0001% %cNumCot% '
	cString += CRLF + '			</h1>'
	cString += CRLF +  	'	</div>'

	cString += CRLF +'		<!-- Cabeçalho do Pedido --> '
	cString += CRLF +'		<div style="border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">
	cString += CRLF +'			<table style="font: normal normal normal 14px '
	cString += CRLF +"'open sans'"
	cString += CRLF +', sans-serif;text-align: left;border-width:0px;width:100%;">
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0002%</td> 
	cString += CRLF +'					<td style="width:500px;">%cNomeFor%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0003% </td>
	cString += CRLF +'					<td style="width:500px;">%cDataEmis%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0004%</td> 
	cString += CRLF +'					<td style="width:500px;">%cCNPJFor%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr><td colspan="04"><hr></td></tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0005%</td> 
	cString += CRLF +'					<td style="width:500px;">%cNomeCli%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0004%</td> 
	cString += CRLF +'					<td style="width:500px;">%cCNPJCli%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0006%</td> 
	cString += CRLF +'					<td colspan="03">%cEndeCli%		   </td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0007%</td>
	cString += CRLF +'					<td style="width:500px;">%cCepCli% </td>
	cString += CRLF +'				</tr>
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0008%</td>
	cString += CRLF +'					<td style="width:500px;">%cFoneCli%</td>
	cString += CRLF +'				</tr>
	cString += CRLF +'			<tr><td colspan="04"><hr></td></tr>'

		for nCab := 1 to len(aCabCpo)
			cString += CRLF +'				<tr>
			cString += CRLF +'					<td style="width:100px;">'  + GetSX3Cache(aCabCpo[nCab][1], "X3_TITULO") + '</td>
			cString += CRLF +'					<td style="width:500px;">%' + aCabCpo[nCab][1] + '%</td>
			cString += CRLF +'				</tr>
		next nCab
		
	cString += CRLF +'				<tr>
	cString += CRLF +'					<td style="width:100px;">%cSTR0059%</td>
	cString += CRLF +'					<td style="width:500px;">%cMessage%</td>
	cString += CRLF +'				</tr>

	cString += CRLF +'			</table>
	cString += CRLF +'		</div>
			
	cString += CRLF +'		<!-- Itens do Pedido -->
	cString += CRLF +'		<form name="FrontPage_Form1" method="post" action="mailto:%25WFMailTo%25">
	cString += CRLF +'		<div style="border-top: solid ' + cColor + ' 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">
	cString += CRLF +' 			<table style="font: normal normal normal 14px '
	cString += CRLF +"				'open sans', " 
	cString += CRLF +' 				sans-serif;text-align: left;width:100%;border-collapse: collapse;">	'
	cString += CRLF +'				<thead style="font: normal normal normal 12px '
	cString += CRLF +"'open sans'"
	cString += CRLF +', sans-serif; background:' + cColor + '; color:White; text-align: left; border-width: 0px;">'
	cString += CRLF +'						<tr>'
	cString += CRLF +'							<th align="center" <th align="center" style="width:300px;">%cSTR0010%</th>'
	cString += CRLF +'							<th align="center" <th align="center" style="width:80px;">%cSTR0069%</th>'
	cString += CRLF +'							<th align="center" <th align="center" style="width:100px;">%cSTR0011%</th>'
	cString += CRLF +'							<th align="center" <th align="center" style="width:100px;">%cSTR0012%</th>'
	cString += CRLF +'						</tr>'
	cString += CRLF +'					</thead>'

	cString += CRLF +'					<tbody>'
	cString += CRLF +'						<tr style="height: 28px;">'
	cString += CRLF +'							<td style="width:250px; border-bottom: 1px solid #ddd;">%It.cProDesc%</td>'
	cString += CRLF +'							<td align="center" style="width:80px; border-bottom: 1px solid #ddd;">%It.cUnMedida%</td>'
	cString += CRLF +'							<td align="center" style="width:100px; border-bottom: 1px solid #ddd;">%It.nQuant%</td>'
	cString += CRLF +'							<td align="center" style="width:100px; border-bottom: 1px solid #ddd;">%It.cDtEnt%</td>'
	cString += CRLF +'						</tr>'
	cString += CRLF +'					</tbody>'
	cString += CRLF +'			</table>'
	cString += CRLF +'		</div>	'
	cString += CRLF +'	</form>	'

	cString += CRLF +'	<br>	'

	cString += CRLF +'	<div style="font: normal normal normal 20px '
	cString += CRLF +"'open sans'"
	cString += CRLF +', sans-serif;margin-right: 15px;margin-top: 10px;">'
	cString += CRLF +" 		<a href='!proc_link!' title='!titulo!'>%cSTR0018%</a> %cSTR0017% "
	cString += CRLF +'	</div>	'

	cString += CRLF +"	</body>
	cString += CRLF +"</html>

	if File(cPathFile + cFileName)
		nRet := FErase(cPathFile + cFileName)

		if nRet == 0
			MemoWrite(cPathFile + cFileName, cString)
		else 
			if lShowHelp
				Help(nil, nil , STR0009, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção - "Não foi possível apagar o arquivo pgca030_mail001 existente, verifique se o mesmo não está aberto."	
			EndIf
			cMessage := STR0008 //"Não foi possível apagar o arquivo pgca030_mail001 existente, verifique se o mesmo não está aberto."
			lRetFun := .F.
		endif
	else 
		MemoWrite(cPathFile + cFileName, cString)
	endif

Return lRetFun


/*/{Protheus.doc} NF030TstEmail
Função para envio de teste de e-mail
@author renan.martins
@since 06/2025
/*/
function NF030TstEmail()
	local aButtons := { {.F., Nil},;            //- Copiar
                        {.F., Nil},;            //- Recortar
                        {.F., Nil},;            //- Colar
                        {.F., Nil},;            //- Calculadora
                        {.F., Nil},;            //- Spool
                        {.F., Nil},;            //- Imprimir
                        {.T., STR0022},;        //- "Enviar"
                        {.T., STR0021},;        //- "Cancelar"
                        {.F., Nil},;            //- WalkThrough
                        {.F., Nil},;            //- Ambiente
                        {.F., Nil},;            //- Mashup
                        {.F., Nil},;            //- Help
                        {.F., Nil},;            //- Formulário HTML
                        {.F., Nil},;            // - ECM
                        {.F., nil}}             // - Desabilitar o botão Salvar e Criar Novo
	FWExecView(STR0019, "NFCA030SDE", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, /*bOk*/, 80, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, /*oModelAct*/)//"Teste de E-mail"
return


/*//-------------------------------------------------------------------
{Protheus.doc} PnlCores
Montagem do TPanel e do Tsay, para exibição das cores
@author renan.martins
@since    06/2025
//-------------------------------------------------------------------*/
Static function PnlCores(oPanel, oModel)
	Local oFont 	:= nil
	Local aColorRGB := {}
	Local oSayCmp	:= "" 

	oFont := TFont():New('Arial',,-13,,.T.)
	oSayCmp  := TSay():New(005,005,{|| STR0018 },oPanel,,oFont,,,,.t.,CLR_BLUE,,700,10) //"Cor Selecionada: "

	aColorRGB 	:= NF030HxRGB(oModel:GetModel("DKKMASTER"):GetValue("DKK_COR"))
	_oPnlColors	:= tPanel():Create(oPanel, 15, 16, , oFont, .F.,,, RGB(aColorRGB[1], aColorRGB[2], aColorRGB[3]), 30, 20)
	oSayCmp:Refresh()
	_oPnlColors:Refresh()

	FwFreeArray(aColorRGB)
return


/*/{Protheus.doc} NF030HxRGB
	Função para converter hexadecimal para RGB
	https://tdn.totvs.com/display/tec/__HEXTODEC
@author renan.martins
@since 06/2025
/*/
Function NF030HxRGB(cValCor, lHelp, lRfshPanel, cOrigem)
	Local cChar         := ''
	Local cValCorAux    := ''
	Local nRed			:= 0
	Local nGreen		:= 0
	Local nBlue			:= 0
	Local nX			:= 0
	Local aRetRGB 		:= {0,0,0}
	Local xRetFun		:= nil
	Local lRetFun		:= .T.
	Local lIsHex		:= .T.
	Local oModelX		:= FwModelActive()
	Default cValCor		:= "#ff0010"
	Default lHelp		:= .F.
	Default lRfshPanel	:= .F.
	Default cOrigem		:= "1"

	cValCor := iif( !empty(cValCor), cValCor, oModelX:GetModel("DKKMASTER"):GetValue("DKK_COR"))
	cValCorAux := Upper(AllTrim(cValCor))

	For nX := 1 To Len(cValCorAux)
		cChar := SubStr(cValCorAux, nX, 1)
		If !(cChar $ "#0123456789ABCDEF")
			lIsHex := .F.
			Exit
		EndIf
	Next nX

	if ( !Empty(cValcor) .and. (Len(AllTrim(cValcor)) != 7 .Or. !lIsHex))
		if ( lHelp )
			Help(nil, nil , STR0009, nil, STR0023, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "Insira um valor válido de cor Hexadecimal, com o prefixo #, como #FF0010."
			lRetFun := .F.
		endif
	elseif ( !Empty(cValcor) )
		cValCor := StrTran(cValCor, "#", "")
		nRed 	:= __HEXTODEC(Substring(cValCor, 1,2))
		nGreen 	:= __HEXTODEC(Substring(cValCor, 3,2))
		nBlue 	:= __HEXTODEC(Substring(cValCor, 5,2))
		aRetRGB := {nRed, nGreen, nBlue}
		if ( lRfshPanel )
			_oPnlColors:nClrPane := RGB(nRed, nGreen, nBlue)
			NF030RfVw(nil, "VIEW_DKK")
		endif
	endif

	xRetFun := iif( cOrigem == "1", aRetRGB, lRetFun)

return xRetFun


/*/{Protheus.doc} NF030EdtObr
	Função para verificar se determinados campos podem ou não ser editáveis ou obrigatórios, conforme valores passados em aCmpModif
	@author renan.martins
	@param oModel, objeto, Modelo de Dados
	@param aCmpModf, array, array que armazena o nome do campo e seu valor, para ser obrigatóriou ou editável, conforme tipo (cabeçalho e outros)
@since 06/2025
/*/
function NF030EdtObr(oModel, aCmpModif)
	Local nFor 			:= 0
	Local nTamaCmp		:= 0
	Local oObjDKL   	:= nil
	Local oView			:= FwViewActive()
	Default oModel 		:= FwModelActive()
	Default aCmpModif 	:= {}

	nTamaCmp := Len(aCmpModif)
	oObjDKL	 := oModel:GetModel("DKLDETAIL")

	if ( nTamaCmp > 0 )
		oModel:GetModel("DKLDETAIL"):GetStruct():SetProperty('DKL_EDIT', MODEL_FIELD_WHEN, {|| .T.})

		for nFor := 1 to nTamaCmp
			oObjDKL:LoadValue(aCmpModif[nFor][1], aCmpModif[nFor][2])
		next
		
		oModel:GetModel("DKLDETAIL"):GetStruct():SetProperty('DKL_EDIT', MODEL_FIELD_WHEN, {|| !(fwfldget('DKL_VINC') $ '1/3' .Or. NF030Virtual(fwfldget('DKL_CAMPO'))) .Or. (_lNFCWFENV .And. fwfldget('DKL_TABELA') != 'DHU' .And. fwfldget('DKL_VINC') != '1' )})
		NF030RfVw(oView, "VIEW_DKK")
	endif
return


/*/{Protheus.doc} NF030Virtual
	Função que verifica se o campo informado é virtual.
	@author totvs
	@param cValField, character, nome do campo.
	@return lRet, logico, virtual ou não.
@since 06/2025
/*/
static function NF030Virtual(cValField)
	Local lRet 			:= .F.
	Default cValField	:= ""

	lRet := GetSX3Cache(cValField, "X3_VISUAL") == "V"
	
return lRet


/*/{Protheus.doc} VldActive
	Validação de ativação do modelo
@author juan.felipe
@since 16/06/2025
/*/
Function VldActive(oModel)
	Local lRet			:= .T.
	Local cAliasTemp 	:= ""
    Local cQuery 		:= ""
	Local oQuery		:= Nil
	Default oModel 		:= FwModelActive()

	If ( oModel:GetOperation() == MODEL_OPERATION_INSERT )
		cQuery += " SELECT DKK.DKK_CODIGO "
		cQuery += " 	FROM " + RetSQLName("DKK") + " DKK "
		cQuery += " WHERE "
		cQuery += " 	DKK.DKK_FILIAL = ? " 
		cQuery += " 	AND DKK.D_E_L_E_T_ = ' ' "

		oQuery := FWPreparedStatement():New(cQuery)
		oQuery:SetString(1, FWxFilial('DKK'))
		cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

		If !(cAliasTemp)->(Eof())
			Help(nil, nil , 'NF030INSERT', nil, STR0026, 1, 0) //'Não é permitido incluir mais de um template.'
			lRet := .F.
		endif

		(cAliasTemp)->(dbCloseArea())
		oQuery:Destroy()
		FreeObj(oQuery)
	EndIf
Return lRet


/*/{Protheus.doc} GetCombo
	Retorna opções de um campo combo.
@author juan.felipe
@since 17/06/2025
@version 1.0
/*/
Static Function GetCombo(cAlias, cField)
	Local aOptions 	:= {}
	Local aValue 	:= {}
	Local aRet 		:= {}
	Local cOptions 	:= ""
	Local nX 		:= 0
	Local nLen 		:= 0
	
	DbSelectArea(cAlias)

	If (cAlias)->(FieldPos(cField))
		cOptions := AllTrim(GetSX3Cache(cField, 'X3_CBOX'))

		If !Empty(cOptions)
			aOptions := StrToArray(cOptions, ';')

			For nX := 1 To Len(aOptions)
				aValue := StrToArray(AllTrim(aOptions[nX]), '=')
				Aadd(aRet, JsonObject():New())

				nLen := Len(aRet)

				aRet[nLen]['value'] := aValue[1]
				aRet[nLen]['label'] := aValue[2]
			Next nX
		EndIf
	EndIf
	FwFreeArray(aOptions)
	FwFreeArray(aValue)
Return aRet


/*/{Protheus.doc} NF030CRHTEVirtual
	Função que gera o arquivo HTML no botão Outras Ações, do browser, sem necessidade de entrar no cadastro.
	@author renan.martins
	@param cMessage, character, mensagem de erro retornada por referência.
	@param lShowHelp, logical, exibe help em caso de erro.
	@return lRet, logico, true.
@since 06/2025
/*/
Function NF030CRHTE(cMessage, lShowHelp)
	Local aAreas	:= {}
	Local aCabCpo 	:= {}
	Local aItCpo  	:= {}
	Local aRodCpo 	:= {}
	Local cCodDKL	:= ''
	Local cColor	:= ''
	Local cPicture	:= ''
	Local lRet      := .T.
	Default cMessage := ''
	Default lShowHelp := .T.

	If FwAliasInDic('DKK') .And. FwAliasInDic('DKL')
		aAreas := {DKK->(GetArea()), DKL->(GetArea()), GetArea()}
		cCodDKL := DKK->DKK_CODIGO
		cColor := DKK->DKK_COR
		cPicture := Lower(AllTrim(DKK->DKK_LOGO))

		DKL->(DbSetOrder(1)) //DKL_FILIAL+DKL_CODDKK
		if DKL->(DbSeek(FWxFilial("DKL") + cCodDKL))

			While (DKL->DKL_CODDKK == cCodDKL)

				if DKL->DKL_VINC == "1" // -- Cabeçalho
					aAdd(aCabCpo,{Alltrim(DKL->DKL_CAMPO), "VISUAL", .F.})

				elseif DKL->DKL_VINC == "2"// -- Itens
					aAdd(aItCpo,{Alltrim(DKL->DKL_CAMPO), iif(DKL->DKL_EDIT == "1", "EDIT", "VISUAL"), iif(DKL->DKL_OBRIGA == "1", .T., .F.), DKL->DKL_TABELA})

				elseif DKL->DKL_VINC == "3"// -- Rodape
					aAdd(aRodCpo,{Alltrim(DKL->DKL_CAMPO), iif(DKL->DKL_EDIT == "1", "EDIT", "VISUAL"), iif(DKL->DKL_OBRIGA == "1", .T., .F.), DKL->DKL_TABELA})
				endif

				DKL->(DbSkip())
			Enddo
		endif
	EndIf

	lRet := NF030Html(aCabCpo,aItCpo,aRodCpo,cColor, cPicture, @cMessage, lShowHelp)

	if (lRet .And. lShowHelp)
		Help(nil, nil , STR0009, nil, STR0028, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção - "Arquivo HTML gerado na pasta corretamente."
	endif

	aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
	FwFreeArray(aCabCpo)
	FwFreeArray(aItCpo)
	FwFreeArray(aRodCpo)
return lRet


/*/{Protheus.doc} NF030VdEdit
	Função que verifica se o campo está para editar ou visual, para quando for visual, colocar automaticamente o obrigatório como não.
	@author renan.martins
	@param oModel, object, objeto da Model.
	@param cTypeEdit, character, se é visual ou edição.
	@return lRet, logico, true.
@since 06/2025
/*/
static function NF030VdEdit(oModel, cTypeEdit)
	Local lRet			:= .T.
	Default oModel		:= FwModelActive()
	Default cTypeEdit	:= "1"

	if (cTypeEdit == "2") //Visualização
		oModel:GetModel("DKLDETAIL"):LoadValue("DKL_OBRIGA", "2") //Se visualização, campo não é obrigatório
	endif

return lRet


/*/{Protheus.doc} NF30SetPColor
	Define variavel estática do painel de cores
	@author ali.neto
	@param oModel, object, objeto da Model.
	@param oPnlColors
	@return Nil
@since 06/2025
/*/
Function NF30SetPColor(oPnlColors)
    _oPnlColors := oPnlColors
Return Nil

/*/{Protheus.doc} VldTable
	Função que valida se o campo tabela está preenchido com uma tabela válida, para habilitar ou não os campos obrigatórios e edição.
	@author juan.felipe
	@param oModel, object, objeto da Model.
	@param cTable, character, alias da tabela.
	@return lRet, logical, validado com sucesso ou não.
	@since 09/09/2025
/*/
Static Function VldTable(oModel, cTable)
	Local lRet As Logical
	Local aFields As Array
	Local oModelDKL As Object


	lRet := FwAliasInDic(cTable, .T.)
	oModelDKL := oModel:GetModel('DKLDETAIL')

	If lRet
		If (oModelDKL:GetValue('DKL_VINC') == '2' .And. cTable == 'DHU') .Or. cTable $ 'DKK|DKL'
			cMessage := Iif(cTable == 'DHU', STR0033 + ' ' + cTable + ' ' + STR0034, STR0033 + ' ' + cTable + '.') //Não é permitido selecionar a tabela DHU para itens. / Não é permitido selecionar as tabelas DKK ou DKL.
			oModel:SetErrorMessage(,,,, 'NF030INVTAB', cMessage)
			lRet := .F.
		Else
			oModelDKL:LoadValue('DKL_CAMPO', '')
			aFields := { {"DKL_OBRIGA", "2"}, {"DKL_EDIT", "2"} }

			If oModelDKL:GetValue('DKL_TABELA') != 'DHU' .And. oModelDKL:GetValue('DKL_VINC') $ '2/3'
				aFields := { {"DKL_OBRIGA", "2"}, {"DKL_EDIT", "1"} }
			EndIf

			NF030EdtObr(oModel, aFields)
		EndIf
	EndIf

	FwFreeArray(aFields)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030Num
    Inicializador padrão do campo DKK_CODIGO
@author juan.felipe
@since 17/09/2025
@version 1.0
@return cNum, character, número do template.
/*/
//-------------------------------------------------------------------
Function NF030Num()
    Local aAreas As Array
    Local cNum As Character

	cNum := ''

	If FwAliasInDic("DKK")
		aAreas := {DKK->(GetArea()), GetArea()}
		cNum  := GetSx8Num("DKK","DKK_CODIGO")

		DKK->(dbSetOrder(1))

		While DKK->(MsSeek(xFilial("DKK")+cNum))
			While __lSx8
				ConfirmSX8()
			EndDo
			cNum := GetSx8Num("DKK","DKK_CODIGO")
		EndDo

		aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
	EndIf
Return cNum

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030Cancel
    Cancela a inclusão dos dados.
@author juan.felipe
@since 17/06/2025
@version 1.0
@param oModel, object, modelo de dados.
@return lRet, logical, cancelar dados.
/*/
//-------------------------------------------------------------------
Function NF030Cancel(oModel)
    Local lRet := .T.
	// Local nStack := GetSX8Len()
    Default oModel := FwModelActive()
    
    FwFormCancel(oModel)

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		While __lSx8
			RollBackSX8()
		End
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030After
    Função executada após a inicialização da view
@author juan.felipe
@since 18/07/2025
@version 1.0
@param oView, object, objecto da view.
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
//-------------------------------------------------------------------
Function NF030After(oView, oModel)
	Default oView  := FwViewActive()
	Default oModel := FwModelActive()

	If oModel:GetOperation() == MODEL_OPERATION_INSERT //-- Realiza alteração no cabeçalho para conseguir salvar sem alterar nenhuma informação
		oModel:SetValue('DKKMASTER', 'DKK_COR', '#0088CC')
		oModel:SetValue('DKKMASTER', 'DKK_COR', '#0088CB')
		oView:ApplyModifyToViewByModel()
	EndIf
Return Nil
