#INCLUDE "protheus.ch"
#INCLUDE "TPESAGCOMPOSITION.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWcompositionAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA ccomposition	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT
	
	DATA oRest				as OBJECT
	DATA aHeader			as OBJECT

	METHOD NEW()	
	METHOD Getcomposition()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD Includecomposition()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWcompositionAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:ccomposition		:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Romaneio de Entrada'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson 		:= JsonObject():New()
	self:oRest 				:= FWRest():New("http://localhost:8080/rest/oga250api")
	self:aHeader 			:= {}

	self:oEaiObjSn2 		:= JsonObject():New()

Return

/*/{Protheus.doc} Includecomposition
//Responsável por incluir o registro passado por parametro.
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return cCodId, código do romaneio incluído.

@type function
/*/
METHOD Includecomposition() CLASS FWcompositionAdapter
	Local lRet 		 	as LOGICAL
	Local cCodId		as CHARACTER
	Local nX, nDesconto	as NUMERIC
	Local aArea      	as ARRAY
	Local oJson			as OBJECT
	Local oRetPost		as OBJECT
	Local cErro 		as CHARACTER
	Local cKeyTab 		as CHARACTER
	Local cQuery		as CHARACTER
	Local cAliasNJJ 	as CHARACTER
	Local erpCode		as CHARACTER
	Private lFilLog		as LOGICAL
	
	self:oRest:setPAth("/api/oga/v1/PackingSlipEntry")
	
	aArea 		:= GetArea()	
	cCodId 		:= ""
	lRet 		:= .T.
	nX 			:= 0
	nDesconto	:= 0
	cErro 		:= ""
	cQuery		:= ""
	cAliasNJJ   := ""
	erpCode		:= ""
	oJson		:= JsonObject():New()
	oRetPost	:= JsonObject():New()
	
	oJson:FromJson(Self:oEaiObjRec:getJSON()) //converte para json para realizar validações
		
	Self:oFieldsJson['EntityCode']		:= ''
	Self:oFieldsJson['EntityStore']		:= ''
	Self:oFieldsJson['PackingListCrop']	:= ''
	Self:oFieldsJson['LocationCode']	:= ''
	Self:oFieldsJson['DiscountsTable']	:= ''
	for nX := 1 To LEN(Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes'))
		if Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJ0_CODENT'
			//api manda # pois no envio enviamos os # para atender uma necessidade lá, então quando recebemos removemos o #
			cKeyTab := STRTRAN( Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value'),"#","") //remove #
			DBSELECTAREA( "NJ0" )
			DBSETORDER( 1 )
			If NJ0->(DBSEEK(cKeyTab)) .AND. NJ0->(NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT) = cKeyTab//API envia chave primaria da tabela
				Self:oFieldsJson['EntityCode'] := NJ0->NJ0_CODENT			
			else
				cErro += STR0002 //"Atributo NJ0_CODENT não informado ou inválido!"
			EndIf			
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJ0_LOJENT'
			cKeyTab := STRTRAN( Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value'),"#","") //remove #			
			DBSELECTAREA( "NJ0" )
			DBSETORDER( 1 )
			If NJ0->(DBSEEK(cKeyTab)) .AND. NJ0->(NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT) = cKeyTab
				Self:oFieldsJson['EntityStore'] := NJ0->NJ0_LOJENT			
			else
				cErro += STR0003 //"Atributo NJ0_LOJENT não informado ou inválido!"
			EndIf	
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJU_CODSAF'			 		 
			cKeyTab := STRTRAN( Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value'),"#","") //remove #			
			DBSELECTAREA( "NJU" )
			DBSETORDER( 1 )
			If NJU->(DBSEEK(cKeyTab)) .AND. NJU->(NJU_FILIAL+NJU_CODSAF) = cKeyTab
				Self:oFieldsJson['PackingListCrop'] := NJU->NJU_CODSAF
			else
				cErro += STR0004 //"Atributo NJU_CODSAF não informado ou inválido!"
			EndIf
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NNR_CODIGO'
			cKeyTab := STRTRAN(  Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value'),"#","") //remove #
			DBSELECTAREA( "NNR" )
			DBSETORDER( 1 )
			If NNR->(DBSEEK(cKeyTab)) .AND. NNR->(NNR_FILIAL+NNR_CODIGO) = cKeyTab
				Self:oFieldsJson['LocationCode'] := NNR->NNR_CODIGO
			else
				cErro += STR0005 //"Atributo NNR_CODIGO não informado ou inválido!"
			EndIf
		endif
	next
	
	if EMPTY(Self:oFieldsJson['EntityCode']) .or. EMPTY(Self:oFieldsJson['EntityStore']) .or. ;
	   EMPTY(Self:oFieldsJson['PackingListCrop']) .or. EMPTY(Self:oFieldsJson['LocationCode'])
	    Self:cError := STR0001 + CRLF + cErro //'Existem atributos não informados e/ou incorretos.'
		Self:lOk := .F. 
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] 	:= {}
		Self:oEaiObjSn2['errors'] 		:= {}
		Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
		Self:oEaiObjSn2['errors'][1]['codeMessage'] := 400
		Self:oEaiObjSn2['errors'][1]['field'] :=  Self:cError
	   	Return()
	endif

	cAliasNJJ := GetNextAlias()
	cQuery := " SELECT NJJ.NJJ_CODROM AS ROMANEIO "
	cQuery += " FROM " + RetSqlName("NJJ") + " NJJ"
	cQuery += " WHERE NJJ.NJJ_TKTCLA = '" + Self:oEaiObjRec:getPropValue('trackingTicket') + "' "
	cQuery += "   AND NJJ.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJJ,.F.,.T.)
	DbselectArea( cAliasNJJ )
	DbGoTop()
	If (cAliasNJJ)->( !Eof() )
		cErro := (cAliasNJJ)->ROMANEIO
	EndIf
	(cAliasNJJ)->(DbCloseArea())

	// Pesagem já cadastrada no romaneio XXXX 
	If !Empty( cErro )
	    Self:cError := STR0007 + CRLF + cErro
	   	Self:lOk := .F. 
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] 	:= {}
		Self:oEaiObjSn2['errors'] 		:= {}
		Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
		Self:oEaiObjSn2['errors'][1]['codeMessage'] := 400
		Self:oEaiObjSn2['errors'][1]['field'] :=  Self:cError
	   	Return()
	EndIf

	Self:oFieldsJson['BranchId']		:= FwXFilial('NJM')
	Self:oFieldsJson['ProductCode']		:= Self:oEaiObjRec:getPropValue('product'):getPropValue('productCode')
	Self:oFieldsJson['ProdMeasureUnit']	:= Self:oEaiObjRec:getPropValue('product'):getPropValue('unitMeasurementCode')
	Self:oFieldsJson['Weight1Date']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),1,4);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),6,2);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),9,2)
										  
	Self:oFieldsJson['WeightTime1']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),12,5)
	Self:oFieldsJson['FirstWeight']		:= Self:oEaiObjRec:getPropValue('weight1')
	if Self:oEaiObjRec:getPropValue('manualWeighing') == 'S'
		Self:oFieldsJson['WeightModel1']	:= 'M'
	elseif Self:oEaiObjRec:getPropValue('manualWeighing') == 'N'
		Self:oFieldsJson['WeightModel1']	:= 'A'
	endif
	Self:oFieldsJson['Weight2Date']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),1,4);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),6,2);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),9,2)
										  
	Self:oFieldsJson['WeightTime2']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),12,5)
	Self:oFieldsJson['SecondWeight']	:= Self:oEaiObjRec:getPropValue('weight2')
	if Self:oEaiObjRec:getPropValue('manualWeighing') == 'S'
		Self:oFieldsJson['WeightModel2']	:= 'M'
	elseif Self:oEaiObjRec:getPropValue('manualWeighing') == 'N'
		Self:oFieldsJson['WeightModel2']	:= 'A'
	endif
	Self:oFieldsJson['VehiclePlate']	:= Self:oEaiObjRec:getPropValue('plateTruck')
	Self:oFieldsJson['CarrierCode']		:= ''
	Self:oFieldsJson['CNPJ/CPF']		:= ''	
	Self:oFieldsJson['trackingTicket']	:= Self:oEaiObjRec:getPropValue('trackingTicket')
	Self:oFieldsJson['producerInvoice']	:= Self:oEaiObjRec:getPropValue('producerInvoice')
	Self:oFieldsJson['producerSeries']	:= Self:oEaiObjRec:getPropValue('producerSeries')
	erpCode								:= Self:oEaiObjRec:getPropValue('movementType'):getPropValue('erpCode')

	If !EMPTY(erpCode)
		IF !erpCode $ "1|2|3|4|5|6|7|8|9"
			Self:cError := STR0008 + CRLF + " " + erpCode //Tag eprCode inválida para geração do romaneio
			Self:lOk := .F. 
			Self:oEaiObjSn2 := oJson
			Self:oEaiObjSn2['_messages'] 	:= {}
			Self:oEaiObjSn2['errors'] 		:= {}
			Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
			Self:oEaiObjSn2['errors'][1]['codeMessage'] := 400
			Self:oEaiObjSn2['errors'][1]['field'] :=  Self:cError
	   		Return()
		EndIF

		Self:oFieldsJson['erpCode']	:= erpCode
	Else
		Self:oFieldsJson['erpCode']	:= '1' // 1-Entrada por Produção
	Endif

	Self:oFieldsJson['PackingSlipRating'] := {}
	If oJson:GetJsonObject('Content'):GetJsonObject('cargos')[1]:GetJsonObject('classificAnalysis') != nil  .and. oJson:GetJsonObject('Content'):GetJsonObject('cargos')[1]:GetJsonObject('classificAnalysis')[1]:GetJsonObject('discountRange'):GetJsonObject('analysisHE'):GetJsonObject('cdAnalysis') != nil //Valida se a tag existe
		Self:oFieldsJson['DiscountsTable']	:= Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[1]:getPropValue('discountRange'):getPropValue('analysisHE'):getPropValue('cdAnalysis')

		For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis'))
			Aadd(self:oFieldsJson['PackingSlipRating'], JsonObject():New())
			nDesconto := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[nX]:getPropValue('percDiscount')					   
			Self:oFieldsJson['PackingSlipRating'][nX]['DiscountPercentage']		:= nDesconto
			Self:oFieldsJson['PackingSlipRating'][nX]['InformedResult']			:= ''
			Self:oFieldsJson['PackingSlipRating'][nX]['BaseWeightForClassific']	:= Self:oEaiObjRec:getPropValue('netWeight')
			Self:oFieldsJson['PackingSlipRating'][nX]['ClassificationResult']	:= val(cValToChar(Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[nX]:getPropValue('value')))
			Self:oFieldsJson['PackingSlipRating'][nX]['ClassificationType']		:= '2'
			Self:oFieldsJson['PackingSlipRating'][nX]['DiscountCode']			:= Self:oEaiObjRec:getPropValue('cargos')[1];
								:getPropValue('classificAnalysis')[nX]:getPropValue('analysisDe'):getPropValue('cdAnlDe')
			Self:oFieldsJson['PackingSlipRating'][nX]['Discountity']			:= Self:oEaiObjRec:getPropValue('netWeight') * nDesconto / 100
			Self:oFieldsJson['PackingSlipRating'][nX]['SequenceItem']			:= nX
			Self:oFieldsJson['PackingSlipRating'][nX]['ResultDescription']		:= ''
		next nX
	else
		Self:cError := STR0006 //"Tabela de Analise não informada(cdAnalysis). "
		Self:lOk := .F. 
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] 	:= {}
		Self:oEaiObjSn2['errors'] 		:= {}
		Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
		Self:oEaiObjSn2['errors'][1]['codeMessage'] := 400
		Self:oEaiObjSn2['errors'][1]['field'] :=  Self:cError
	   	Return()
	EndIf
	
	Self:oRest:SetPostParams(EncodeUTF8(FWJsonSerialize(Self:oFieldsJson, .F., .F., .T.)))
	Self:oRest:Post(self:aHeader)
	oRetPost:FromJson(Self:oRest:GetResult())
	If oRetPost:GetJsonObject('PackingSlipCode') != nil .and. !Empty(oRetPost:GetJsonObject('InternalId'))
		Self:lOk := .T.
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] := {}
		Aadd(self:oEaiObjSn2['_messages'], JsonObject():New())
		Self:oEaiObjSn2['_messages'][1]['code'] 			:= oRetPost:GetJsonObject('InternalId')
		Self:oEaiObjSn2['_messages'][1]["message"] 			:= "Registro inserido com sucesso!"		
		Self:oEaiObjSn2['_messages'][1]["details"] 			:= {}	
		Aadd(Self:oEaiObjSn2['_messages'][1]["details"], JsonObject():New())
		Self:oEaiObjSn2['_messages'][1]['details'][1] 		:= oRetPost

	elseIf oRetPost:GetJsonObject('errorCode') != nil .and. !Empty(oRetPost:GetJsonObject('errorMessage'))
		Self:lOk := .F.
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] 	:= {}
		Self:oEaiObjSn2['errors'] 		:= {}
		Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
		Self:oEaiObjSn2['errors'][1]['codeMessage'] := oRetPost:GetJsonObject('errorCode')
		Self:oEaiObjSn2['errors'][1]['field'] 		:= oRetPost:GetJsonObject('errorMessage')

	elseIf oRetPost:GetJsonObject('code') != nil .and. oRetPost:GetJsonObject('message') != nil 
		Self:lOk := .F.
		Self:oEaiObjSn2 := oJson
		Self:oEaiObjSn2['_messages'] 	:= {}
		Self:oEaiObjSn2['errors'] 		:= {}
		Aadd(self:oEaiObjSn2['errors'], JsonObject():New())
		Self:oEaiObjSn2['errors'][1]['codeMessage'] := oRetPost:GetJsonObject('code')
		Self:oEaiObjSn2['errors'][1]['field'] 		:= oRetPost:GetJsonObject('message')
	EndIf
		
Return

