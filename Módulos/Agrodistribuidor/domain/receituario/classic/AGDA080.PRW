#Include "protheus.ch"
#Include "fwmvcdef.ch"
#Include "agda080.ch"

#DEFINE TIPO_RECEITUARIO '1'
#DEFINE TIPO_GUIATRANSITO '2'

/*/{Protheus.doc} AGDA080
Rotina que salva o Dados Guia/Receituário (NER) com base na SF1/MATA103/Documento de Entrada posicionado.
@type function
@version 12
@author carlos.augusto
@see (https://jiraproducao.totvs.com.br/browse/DAGRODIST-1678)
@since 05/09/2025
/*/
Function AGDA080()
	Local oMBrowse := Nil

	If .Not. TableInDic('NER')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "SF1" )
	oMBrowse:SetDescription( STR0005 )  //"Dados Receituario/Guia de Trânsito"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil


/*/{Protheus.doc} MenuDef
@type function
@version 12
@author carlos.augusto
@since 05/09/2025
/*/
Static Function MenuDef()
	Private aRotina := {}
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.AGDA080" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.AGDA080" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.AGDA080" OPERATION 5 ACCESS 0  // Excluir
Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef da rotina
@type function
@version 12
@author carlos.augusto
@since 05/09/2025
/*/
Static Function ModelDef()
	local oModel as object
	local oStrField as object

	Local oStrSF1   := FWFormStruct(1, 'SF1')
	Local oStruSD1R := FWFormStruct(1, 'SD1')
	Local oStruSD1G := FWFormStruct(1, 'SD1')

	Local oStrNERRec := FWFormStruct(1, 'NER')
	Local oStrNERGui := FWFormStruct(1, 'NER')

	oStrSF1:SetProperty( '*' , MODEL_FIELD_OBRIGAT , .F.)


	oStruSD1R:SetProperty('*' , MODEL_FIELD_WHEN , {|| .F. })
	oStruSD1G:SetProperty('*' , MODEL_FIELD_WHEN , {|| .F. })

	oStrSF1:SetProperty( 'F1_DOC' , MODEL_FIELD_WHEN ,  {|| .F.})
	oStrSF1:SetProperty( 'F1_SERIE' , MODEL_FIELD_WHEN ,  {|| .F.})
	oStrSF1:SetProperty( 'F1_FORNECE' , MODEL_FIELD_WHEN ,  {|| .F.})
	oStrSF1:SetProperty( 'F1_LOJA' , MODEL_FIELD_WHEN ,  {|| .F.})
	oStrNERRec:SetProperty("NER_TPVINC", MODEL_FIELD_INIT 	, {|| '1' })
	oStrNERGui:SetProperty("NER_TPVINC", MODEL_FIELD_INIT 	, {|| '2' })

	oStrField := FWFormModelStruct():New()
	oModel := MPFormModel():New("AGDA080")
	oModel:addFields("CAB_NOTA", /*cOwner*/, oStrSF1)

	oModel:AddGrid(  "NER_RECEIT", "CAB_NOTA", oStrNERRec)
	oModel:GetModel( "NER_RECEIT"):SetForceLoad(.T.)
	oModel:GetModel( "NER_RECEIT" ):SetDescription(STR0001) //"Receituario"
	oModel:GetModel( "NER_RECEIT" ):SetNoUpdateLine( !AGDA080OPN(TIPO_RECEITUARIO)  )
	oModel:GetModel( "NER_RECEIT" ):SetOptional( .T. )
	oModel:SetRelation("NER_RECEIT",{{"NER_FILIAL",'xFilial("NER")'},{"NER_DOC","F1_DOC"},{"NER_SERIE","F1_SERIE"},{"NER_FORNEC","F1_FORNECE"},{"NER_LOJA","F1_LOJA"},{"NER_TPVINC","'1'"}},"NER_DOC")

	oModel:AddGrid(  "NER_GUIA", "CAB_NOTA", oStrNERGui)
	oModel:GetModel( "NER_GUIA" ):SetDescription(STR0002) //"Guia de Transporte"
	oModel:GetModel( "NER_GUIA" ):SetNoInsertLine(.T.)
	oModel:GetModel( "NER_GUIA" ):SetNoUpdateLine( !AGDA080OPN(TIPO_GUIATRANSITO)  )
	oModel:GetModel( "NER_GUIA" ):SetOptional( .T. )
	oModel:SetRelation("NER_GUIA",{{"NER_FILIAL",'xFilial("NER")'},{"NER_DOC","F1_DOC"},{"NER_SERIE","F1_SERIE"},{"NER_FORNEC","F1_FORNECE"},{"NER_LOJA","F1_LOJA"},{"NER_TPVINC","'2'"}},"NER_DOC")

	oModel:addGrid("SD1_RECEB", "CAB_NOTA", oStruSD1R, /*bLinePre*/, /*bLinePost*/, /*bLinePre */, /*bPost*/, {|oMdl| AGDA080QRY(oMdl,TIPO_RECEITUARIO)})
	oModel:GetModel("SD1_RECEB"):SetOptional(.T.)
	oModel:GetModel("SD1_RECEB"):SetOnlyQuery(.T.)
	oModel:GetModel("SD1_RECEB"):SetOnlyView(.T.)

	oModel:addGrid("SD1_GUIA", "CAB_NOTA", oStruSD1G, /*bLinePre*/, /*bLinePost*/, /*bLinePre */, /*bPost*/, {|oMdl| AGDA080QRY(oMdl,TIPO_GUIATRANSITO)})
	oModel:GetModel("SD1_GUIA"):SetOptional(.T.)
	oModel:GetModel("SD1_GUIA"):SetOnlyQuery(.T.)
	oModel:GetModel("SD1_GUIA"):SetOnlyView(.T.)

	oModel:SetPrimaryKey({"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA,F1_FORMUL"})

Return oModel


/*/{Protheus.doc} ViewDef
@type function
@version 12
@author carlos.augusto
@since 05/09/2025
/*/
Static Function ViewDef()
	local oView as object
	local oModel as object

	Local oStrSF1 := FWFormStruct(2, 'SF1', {|x| ALLTRIM(x) $ "F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA"})
	Local oStrNERRec := FWFormStruct(2, 'NER', {|x| ALLTRIM(x) $ "NER_ITEM,NER_NUMREC,NER_CGC"})
	Local oStrNERGui := FWFormStruct(2, 'NER', {|x| ALLTRIM(x) $ "NER_ITEM,NER_TPGUIA,NER_UF,NER_SERGUI,NER_NUMGUI"})

	Local oStrSD1R := FWFormStruct(2, 'SD1', {|x| ALLTRIM(x) $ "D1_FILIAL,D1_ITEM ,D1_COD, D1_UM,D1_SEGUM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_PESO,D1_LOCAL,D1_EMISSAO,D1_DTDIGIT,D1_LOTECTL"})
	Local oStrSD1G := FWFormStruct(2, 'SD1', {|x| ALLTRIM(x) $ "D1_FILIAL,D1_ITEM ,D1_COD, D1_UM,D1_SEGUM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_PESO,D1_LOCAL,D1_EMISSAO,D1_DTDIGIT,D1_LOTECTL"})


	oModel := FWLoadModel("AGDA080")
	oView := FwFormView():New()
	oView:setModel(oModel)

	oView:addField("CAB", oStrSF1, "CAB_NOTA")

	oView:AddGrid('VIEW_RECEIT', oStrNERRec, 'NER_RECEIT' )
	oView:AddIncrementField("VIEW_RECEIT", "NER_ITEM")

	oView:AddGrid('VIEW_SD1R', oStrSD1R, 'SD1_RECEB' )
	oView:AddGrid('VIEW_SD1G', oStrSD1G, 'SD1_GUIA' )

	oView:AddGrid('VIEW_GUIA', oStrNERGui, 'NER_GUIA' )
	oView:AddIncrementField("VIEW_GUIA", "NER_ITEM")

	oView:CreateHorizontalBox("SUPERIOR",10)
	oView:CreateHorizontalBox("INFERIOR",90)

	oView:CreateFolder("FOLDERS", "INFERIOR")
	oView:AddSheet("FOLDERS", "FOLDER_RECE", STR0001) // "Receituario"
	oView:AddSheet("FOLDERS", "FOLDER_GUIA", STR0002) //"Guia de Transporte"
	oView:CreateHorizontalBox("PNEL_RECEIT", 20,,, "FOLDERS", "FOLDER_RECE" )
	oView:CreateHorizontalBox("PNEL_GUIA", 20,,, "FOLDERS", "FOLDER_GUIA" )

	oView:CreateHorizontalBox("PN_INF_REC", 80,,, "FOLDERS", "FOLDER_RECE" )
	oView:CreateHorizontalBox("PN_INF_GUI", 80,,, "FOLDERS", "FOLDER_GUIA" )

	oView:CreateFolder("SUBF_RECEB", "PN_INF_REC")
	oView:AddSheet("SUBF_RECEB", "FD_NCR_REC", STR0003) // "Produtos da nota fiscal que necessitam de Receituário Agronomico"
	oView:CreateHorizontalBox("SUBPN_PDRE", 100,,, "SUBF_RECEB", "FD_NCR_REC" )

	oView:CreateFolder("SUBF_GUIA", "PN_INF_GUI")
	oView:AddSheet("SUBF_GUIA", "FD_NCR_GUI", STR0004) // "Produtos da Nota Fiscal que necessitam de Guia de Trânsito"
	oView:CreateHorizontalBox("SUBPN_PDGU", 100,,, "SUBF_GUIA", "FD_NCR_GUI" )

	oView:SetOwnerView( 'CAB',	'SUPERIOR')
	oView:SetOwnerView( 'VIEW_RECEIT', 'PNEL_RECEIT')
	oView:SetOwnerView( 'VIEW_SD1R', 'SUBPN_PDRE')
	oView:SetOwnerView( 'VIEW_GUIA', 'PNEL_GUIA')
	oView:SetOwnerView( 'VIEW_SD1G', 'SUBPN_PDGU')
	oView:SetCloseOnOk({||.T.})

Return oView


/*/{Protheus.doc} AGDA080QRY
	Produtos que necessitam de guia ou receituario
	@type  Function
	@author carlos.augusto
	@since 05/09/2025
	/*/
Static Function AGDA080QRY(oModel, cTipo)
	Local aData     as array
	Local cAliasSD1 as char
	Local cWhere    as char

	cAliasSD1 := GetNextAlias()

	cWhere := "% "

	if cTipo == TIPO_RECEITUARIO
		cWhere += "	NCR.NCR_EMREC = '1'"
	ElseIf cTipo == TIPO_GUIATRANSITO
		cWhere += "	NCR.NCR_EMGUIA = '1'"
	EndIf
	cWhere += " %"

	BeginSql Alias cAliasSD1
        SELECT D1_FILIAL,D1_ITEM ,D1_COD, D1_UM, D1_SEGUM, D1_QUANT, D1_VUNIT, D1_TOTAL ,D1_PESO, D1_LOCAL, D1_EMISSAO, D1_DTDIGIT, D1_LOTECTL, SD1.R_E_C_N_O_ RECNO
          FROM %Table:SD1% SD1
         INNER JOIN %Table:NCR% NCR
            ON(NCR.NCR_FILIAL    = %Exp:xFilial("NCR")%
				AND NCR.NCR_PROD = SD1.D1_COD
				AND NCR.%NotDel%)
	 WHERE %Exp:cWhere%
	 AND SD1.D1_FILIAL = %Exp:xFilial("SD1")%
	 AND SD1.D1_DOC = %Exp:SF1->F1_DOC%        
	 AND SD1.D1_SERIE =  %Exp:SF1->F1_SERIE%  
	 AND SD1.D1_FORNECE =  %Exp:SF1->F1_FORNECE%  
	 AND SD1.D1_LOJA =  %Exp:SF1->F1_LOJA%  
	 AND SD1.D1_TIPO =  %Exp:SF1->F1_TIPO%  
     AND SD1.%NotDel%
	EndSql
	aData := FwLoadByAlias(oModel, cAliasSD1, "SD1", "RECNO", /*lCopy*/, .T.)
	(cAliasSD1)->(DBCloseArea())
Return aData


/*/{Protheus.doc} AGDI080VLD
Valida se existe produto com NCR_EMREC = 1 ou NCR_EMGUIA = 1
@type function
@version 12
@author carlos.augusto
@since 09/09/2025
/*/
Function AGDA080OPN(cOpcao)
	Local lRet 		 := .F.
	Local cQuery	 := ""
	Local cAliQry 	 := GetNextAlias()
	Local oStatement := nil
	Default cOpcao 	 := " "

	cQuery := " SELECT D1_FILIAL, D1_ITEM, D1_COD "
	cQuery += 	" FROM "+ RetSqlName('SD1') +" SD1 "
	cQuery += 		" INNER JOIN "+ RetSqlName('NCR') +" NCR 
	cQuery += 			" ON  (NCR.NCR_FILIAL = '"+xFilial("NCR")+"'"
	cQuery += 			" AND NCR.NCR_PROD = SD1.D1_COD
	cQuery += 			" AND NCR.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE SD1.D1_FILIAL = ? "
	cQuery += 	" AND SD1.D1_DOC = ? "
	cQuery += 	" AND SD1.D1_SERIE = ? "
	cQuery += 	" AND SD1.D1_FORNECE = ? "
	cQuery += 	" AND SD1.D1_LOJA = ? "
	cQuery += 	" AND SD1.D1_TIPO = ? "
	cQuery += 	" AND SD1.D_E_L_E_T_ = ' ' "

	If Empty(cOpcao)
		cQuery += " AND (NCR.NCR_EMREC = '1' OR NCR.NCR_EMGUIA = '1') "
	ElseIf cOpcao == TIPO_RECEITUARIO
		cQuery += " AND NCR.NCR_EMREC = '1' "
	ElseIf cOpcao == TIPO_GUIATRANSITO
		cQuery += " AND NCR.NCR_EMGUIA = '1' "
	EndIf
	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial('SD1'))
	oStatement:SetString(2, SF1->F1_DOC)
	oStatement:SetString(3, SF1->F1_SERIE)
	oStatement:SetString(4, SF1->F1_FORNECE)
	oStatement:SetString(5, SF1->F1_LOJA)
	oStatement:SetString(6, SF1->F1_TIPO)
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliQry,.T.,.T.)

	lRet := !(cAliQry)->(Eof())
	(cAliQry)->(dbCloseArea())

Return lRet
