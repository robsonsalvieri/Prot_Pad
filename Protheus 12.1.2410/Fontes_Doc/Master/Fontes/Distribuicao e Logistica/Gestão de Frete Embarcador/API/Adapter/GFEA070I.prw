#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWFreightInvoicesAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cFreightInvoice	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oArr2Json  		as OBJECT
	DATA oArr3Json			as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD GetFreightInvoice()
	METHOD GetNames()
	METHOD GetNmsW()
//	METHOD IncludeFreightInvoices()
	METHOD UpdateFreightInvoices()
	//METHOD DeleteFreightInvoice()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Silvana Vieira Torres Streit
@since 21/10/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWFreightInvoicesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cFreightInvoice	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Faturas de Frete'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	self:oArrayJson	  		:= self:GetNames()[2]
	self:oArr2Json	  		:= self:GetNames()[3]
	self:oArr3Json			:= self:GetNames()[4]
	self:oFieldsJsw   		:= self:GetNmsW()
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= FWEAIObj():NEW()
	self:oEaiObjRec 		:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Silvana Vieira Torres Streit
@since 21/10/2019
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWFreightInvoicesAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson 	:= &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')
	oArr2Json 	:= &('JsonObject():New()')
	oArr3Json	:= &('JsonObject():New()')

	oFieldsJson['InternalId']   				:= 'GW6_FILIAL + GW6_EMIFAT + GW6_SERFAT + GW6_NRFAT + GW6_DTEMIS'
	oFieldsJson['BranchId']						:= 'GW6_FILIAL'
	oFieldsJson['IssuerCode']			    	:= 'GW6_EMIFAT'
	oFieldsJson['InvoiceSeries']			    := 'GW6_SERFAT'	
	oFieldsJson['InvoiceNumber']			    := 'GW6_NRFAT'	
	oFieldsJson['IssueDate']			        := 'GW6_DTEMIS'	
	oFieldsJson['InvoiceGrossValue']			:= 'GW6_VLFATU'	
	oFieldsJson['DiscountValue']			    := 'GW6_VLDESC'
	
	If GFXCP12117("GW6_DINDEN") 
		oFieldsJson['CompensatoryDiscount']   	:= 'GW6_DINDEN'
	EndIf		
	
	oFieldsJson['ICMSValue']			        := 'GW6_VLICMS'	
	oFieldsJson['WithheldICMSValue']			:= 'GW6_VLICRE'	
	oFieldsJson['ISSValue']			    		:= 'GW6_VLISS'	
	oFieldsJson['WithheldISSValue']			    := 'GW6_VLISRE'	
	oFieldsJson['InterestValue']			    := 'GW6_VLJURO'
	oFieldsJson['InputDate']			   		:= 'GW6_DTCRIA'
	oFieldsJson['ExpirationDate']				:= 'GW6_DTVENC'
	oFieldsJson['ApprovalStatus']			    := 'GW6_SITAPR'
	oFieldsJson['ApprovalDate']		    		:= 'GW6_DTAPR'
	oFieldsJson['ApprovalTime']		            := 'GW6_HRAPR'
	oFieldsJson['ApprovalUser']      			:= 'GW6_USUAPR'
	oFieldsJson['BlockageDate']		            := 'GW6_DTBLOQ'
	oFieldsJson['BlockageTime']		    		:= 'GW6_HRBLOQ'
	oFieldsJson['InputUser ']		        	:= 'GW6_USUIMP'
	oFieldsJson['BlockageUser']		        	:= 'GW6_USUBLO'
	oFieldsJson['BlockageReason']		        := 'GW6_MOTBLO2'
	oFieldsJson['Note']		            		:= 'GW6_OBS2'
	oFieldsJson['WithheldICMSTaxCode']			:= 'GW6_DSICCD2'
	oFieldsJson['WithheldICMSTaxCategory']		:= 'GW6_DSICCL2'
	oFieldsJson['WithheldISSTaxCode']		    := 'GW6_DSISCD2'
	oFieldsJson['WithheldISSTaxCategory']		:= 'GW6_DSISCL2'
	oFieldsJson['FinancialDate']		        := 'GW6_DTFIN'
	oFieldsJson['FinancialTime']		    	:= 'GW6_HRFIN'
	oFieldsJson['FinancialStatus']		    	:= 'GW6_SITFIN'	
	oFieldsJson['FinancialUser']		    	:= 'GW6_USUFIN'
	oFieldsJson['FinancialRejectionReason']		:= 'GW6_MOTFIN2'
		
	oArrayJson['LedgerAccount']					:= 'GW7_CTACTB'
	oArrayJson['CostCenter']					:= 'GW7_CCUSTO'
	oArrayJson['BusinessUnit']			        := 'GW7_UNINEG'
	oArrayJson['Value']			        		:= 'GW7_VLMOV'
	oArrayJson['TransactionType']			    := 'GW7_TRANS'
	
	oArr2Json['DocumentSerie']			        := 'GW3_SERDF'
	oArr2Json['DocumentNumber']			        := 'GW3_NRDF'
	oArr2Json['ElectronicAccessKey']			:= 'GW3_CTE'
	
	oArr3Json['FederalID']						:= 'GU3_IDFED'
	
return {oFieldsJson, oArrayJson, oArr2Json, oArr3Json}


Method GetNmsW() CLASS FWFreightInvoicesAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')
	
	oFieldsJsw['INTERNALID']   				:= 'GW6_FILIAL + GW6_EMIFAT + GW6_SERFAT + GW6_NRFAT + GW6_DTEMIS'
	oFieldsJsw['BRANCHID']					:= 'GW6_FILIAL'
	oFieldsJsw['ISSUERCODE']				:= 'GW6_EMIFAT'
	oFieldsJsw['INVOICESERIES']				:= 'GW6_SERFAT'
	oFieldsJsw['INVOICENUMBER']			    := 'GW6_NRFAT'
	oFieldsJsw['ISSUEDATE']			    	:= 'GW6_DTEMIS'	
	oFieldsJsw['INVOICEGROSSVALUE']			:= 'GW6_VLFATU'	
	oFieldsJsw['DISCOUNTVALUE']				:= 'GW6_VLDESC'
	
	If GFXCP12117("GW6_DINDEN") 
		oFieldsJsw['COMPENSATORYDISCOUNT']	:= 'GW6_DINDEN'
	EndIf
		
	oFieldsJsw['ICMSVALUE']			        := 'GW6_VLICMS'		
	oFieldsJsw['WITHHELDICMSVALUE']			:= 'GW6_VLICRE'	
	oFieldsJsw['ISSVALUE']			        := 'GW6_VLISS'	
	oFieldsJsw['WITHHELDISSVALUE']			:= 'GW6_VLISRE'	
	oFieldsJsw['INTERESTVALUE']			    := 'GW6_VLJURO'	
	oFieldsJsw['INPUTDATE']			    	:= 'GW6_DTCRIA'
	oFieldsJsw['EXPIRATIONDATE']			:= 'GW6_DTVENC'
	oFieldsJsw['APPROVALSTATUS']			:= 'GW6_SITAPR'
	oFieldsJsw['APPROVALDATE']			    := 'GW6_DTAPR'
	oFieldsJsw['APPROVALTIME']				:= 'GW6_HRAPR'
	oFieldsJsw['APPROVALUSER']		        := 'GW6_USUAPR'
	oFieldsJsw['BLOCKAGEDATE']      		:= 'GW6_DTBLOQ'
	oFieldsJsw['BLOCKAGETIME']		        := 'GW6_HRBLOQ'
	oFieldsJsw['INPUTUSER']					:= 'GW6_USUIMP'
	oFieldsJsw['BLOCKAGEUSER']		    	:= 'GW6_USUBLO'
	oFieldsJsw['BLOCKAGEREASON']		    := 'GW6_MOTBLO2'
	oFieldsJsw['NOTE']		        		:= 'GW6_OBS2'
	oFieldsJsw['WITHHELDICMSTAXCODE']		:= 'GW6_DSICCD2'
	oFieldsJsw['WITHHELDICMSTAXCATEGORY']	:= 'GW6_DSICCL2'	
	oFieldsJsw['WITHHELDISSTAXCODE']		:= 'GW6_DSISCD2'
	oFieldsJsw['WITHHELDISSTAXCATEGORY']	:= 'GW6_DSISCL2'
	oFieldsJsw['FINANCIALDATE']		        := 'GW6_DTFIN'
	oFieldsJsw['FINANCIALTIME']		        := 'GW6_HRFIN'
	oFieldsJsw['FINANCIALSTATUS']			:= 'GW6_SITFIN'		
	oFieldsJsw['FINANCIALUser']		    	:= 'GW6_USUFIN'
	oFieldsJsw['FinancialRejectionReason']	:= 'GW6_MOTFIN2'

return oFieldsJsw

/*/{Protheus.doc} GetFreightInvoice
//Responsável por trazer a busca das Faturas de frete
@author Silvana Vieira Torres Streit
@since 21/10/2019
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único da fatura de frete
@type function
/*/
Method GetFreightInvoice(cCodId) CLASS FWFreightInvoicesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasGW3 	as CHARACTER
	Local cAliasGW6 	as CHARACTER
	Local cAliasGW7 	as CHARACTER
	Local cAliasGU3		as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aArea      	as ARRAY
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	Local oTempJson    	as OBJECT
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	lRet     	:= .T.
	lFields		:= .F.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasGW6 := aRetAlias[1]
		cAliasGW7 := aRetAlias[2]
		cAliasGW3 := aRetAlias[3]
		cAliasGU3 := aRetAlias[4]
		
		if Self:lOk 
			if self:cTipRet = '1'
				Self:oEaiobjSnd:setBatch(1) //Retorna array
			else
				Self:oEaiobjSnd:setBatch(2) //Retorna um item só!
			endIf
		endif
		
		if Self:lOk 
			if !EMPTY(self:cSelectedFields)
				aSelFields := StrTokArr( self:cSelectedFields, ",")
				lFields := .T. //ele mandou na URL os campos que quer exibir.
			else
				aSelFields := Self:oFieldsJson:getProperties()
			endIf
		endIf
	endIf
	
	if Self:lOk	
		if self:cTipRet = '1'
			If !((cAliasGW6)->(Eof()))					
				While !((cAliasGW6)->(EOF()))
					nCount++
					
					For nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasGW6)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['IssueDate']) ) 
						else
						
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasGW6)->&(Self:oFieldsJson[cField]))
							if cValue != NIL
								IF VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, AllTrim(cValue))
								elseif VALTYPE(cValue) = "N"
									Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
								EndIf
							Else
								Self:cError := 'O campo "' + cField + '" não é valido.' + CRLF
								Self:lOk := .F.
								Return()
							EndIf
						EndIf
					Next nJ		
					
					aArea := GetArea()						
					
					//Se os campos a serem exibidos foram mandados na URL, os filhos não devem aparecer na requisição.
					if !lFields
						nX := 1
						
						(cAliasGW7)->(dbGotop())
						WHILE ((cAliasGW7)->(!Eof())) 				
											
							IF (cAliasGW7)->(GW7_FILIAL)	== (cAliasGW6)->&(Self:oFieldsJson['BranchId']) .AND. ;
							   (cAliasGW7)->(GW7_EMIFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
							   (cAliasGW7)->(GW7_SERFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) .AND. ;
							   (cAliasGW7)->(GW7_NRFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) .AND. ;
							   (cAliasGW7)->(GW7_DTEMIS)  	== (cAliasGW6)->&(Self:oFieldsJson['IssueDate']) 									
							
							 	Self:oEaiObjSnd:setProp('AccountingMovements', {})	 
							 		
						 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('LedgerAccount',	(cAliasGW7)->(GW7_CTACTB))
						 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('CostCenter',		(cAliasGW7)->(GW7_CCUSTO))
						 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('BusinessUnit',		(cAliasGW7)->(GW7_UNINEG))
						 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('Value',			(cAliasGW7)->(GW7_VLMOV))
						 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('TransactionType',	(cAliasGW7)->(GW7_TRANS))			 		
								
								nX++	
							ENDIF
							
							(cAliasGW7)->(DbSkip())
						end
						
						nX := 1
						
						(cAliasGW3)->(dbGotop())
						WHILE ((cAliasGW3)->(!Eof())) 				
											
							IF (cAliasGW3)->(GW3_FILFAT)	== (cAliasGW6)->&(Self:oFieldsJson['BranchId']) .AND. ;
							   (cAliasGW3)->(GW3_EMIFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
							   (cAliasGW3)->(GW3_SERFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) .AND. ;
							   (cAliasGW3)->(GW3_NRFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) .AND. ;
							   (cAliasGW3)->(GW3_DTEMFA)  	== (cAliasGW6)->&(Self:oFieldsJson['IssueDate']) 									
							
							 	Self:oEaiObjSnd:setProp('FreightDocuments', {})	 
							 		
						 		Self:oEaiObjSnd:getpropvalue('FreightDocuments')[nX]:setprop('DocumentSerie',		(cAliasGW3)->(GW3_SERDF))
						 		Self:oEaiObjSnd:getpropvalue('FreightDocuments')[nX]:setprop('DocumentNumber',		(cAliasGW3)->(GW3_NRDF))
						 		Self:oEaiObjSnd:getpropvalue('FreightDocuments')[nX]:setprop('ElectronicAccessKey',	(cAliasGW3)->(GW3_CTE))
								
								nX++	
							ENDIF
							
							(cAliasGW3)->(DbSkip())
						end
						
						nX := 1
								
						(cAliasGU3)->(dbGotop())
						WHILE ((cAliasGU3)->(!Eof())) 
											
							IF (cAliasGU3)->GU3_FILIAL == FWxFilial("GU3") .AND. ;
							   (cAliasGU3)->GU3_CDEMIT == (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) 									
							
							 	Self:oEaiObjSnd:setProp('ShippingIssuer', {})	 
							 							 		
						 		Self:oEaiObjSnd:getpropvalue('ShippingIssuer')[nX]:setprop('FederalID', (cAliasGU3)->(GU3_IDFED))
						 		
						 		nX++
						 		Exit
							ENDIF
							
							(cAliasGU3)->(DbSkip())					
						End
					EndIf
					
					RestArea(aArea)			
					(cAliasGW6)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasGW6)->(DBCloseArea())	
			(cAliasGW7)->(DBCloseArea())
			(cAliasGW3)->(DBCloseArea())
			(cAliasGU3)->(DBCloseArea())
		Else		
		
			If !((cAliasGW6)->(EOF()))
				For nJ := 1 To Len(aSelFields)
				
					If aSelFields[nJ] == 'InternalId'
						Self:oEaiObjSn2:setProp('InternalId', (cAliasGW6)->&(Self:oFieldsJson['BranchId']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) + "|" + (cAliasGW6)->&(Self:oFieldsJson['IssueDate']))
					Else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] == NIL, NIL, (cAliasGW6)->&(Self:oFieldsJson[cField]))

						If cValue != NIL
							IF VALTYPE(cValue) = "C"
								self:oEaiObjSn2:setProp(cField,	AllTrim(cValue))
							elseif VALTYPE(cValue) = "N"
								self:oEaiObjSn2:setProp(cField, cValToChar(cValue))
							endIf
						Else
							Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
							Self:lOk := .F.
							Return()
						endIf
					endIf
				Next nJ
				
				self:oEaiObjSn2:setProp('AccountingMovements', {})
	
				nX := 1
				aArea := GetArea()
				(cAliasGW7)->(dbGoTop())	
				While ((cAliasGW7)->(!Eof())) 		
									
					If (cAliasGW7)->(GW7_FILIAL) 	== (cAliasGW6)->&(Self:oFieldsJson['BranchId']) .AND. ;
					   (cAliasGW7)->(GW7_EMIFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
					   (cAliasGW7)->(GW7_SERFAT) 	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) .AND. ;
					   (cAliasGW7)->(GW7_NRFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) .AND. ;
					   (cAliasGW7)->(GW7_DTEMIS)  	== (cAliasGW6)->&(Self:oFieldsJson['IssueDate']) 		
				
					 	if nX != 1
					 		self:oEaiObjSn2:setProp('AccountingMovements', {})
					 	endIf
					 	
					 	self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setProp('LedgerAccount', (cAliasGW7)->(GW7_CTACTB))
					 	self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setProp('CostCenter', (cAliasGW7)->(GW7_CCUSTO))
				 		self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setProp('BusinessUnit', (cAliasGW7)->(GW7_UNINEG))
				 		self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setProp('Value', (cAliasGW7)->(GW7_VLMOV))
				 		self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setProp('TransactionType', (cAliasGW7)->(GW7_TRANS))
					Endif
					(cAliasGW7)->(DbSkip())
					nX++							
				EndDo

				self:oEaiObjSn2:setProp('FreightDocuments', {})

				nX := 1
				(cAliasGW3)->(dbGoTop())	
				While ((cAliasGW3)->(!Eof())) 		
					If (cAliasGW3)->(GW3_FILFAT)	== (cAliasGW6)->&(Self:oFieldsJson['BranchId']) .AND. ;
					   (cAliasGW3)->(GW3_EMIFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
					   (cAliasGW3)->(GW3_SERFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceSeries']) .AND. ;
					   (cAliasGW3)->(GW3_NRFAT)  	== (cAliasGW6)->&(Self:oFieldsJson['InvoiceNumber']) .AND. ;
					   (cAliasGW3)->(GW3_DTEMFA)  	== (cAliasGW6)->&(Self:oFieldsJson['IssueDate']) 	

					 	If nX != 1
							self:oEaiObjSn2:setProp('FreightDocuments', {})
					 	EndIf
					 	
					 	self:oEaiObjSn2:getpropvalue('FreightDocuments')[nX]:setProp('DocumentSerie', (cAliasGW3)->(GW3_SERDF))
					 	self:oEaiObjSn2:getpropvalue('FreightDocuments')[nX]:setProp('DocumentNumber', (cAliasGW3)->(GW3_NRDF))
				 		self:oEaiObjSn2:getpropvalue('FreightDocuments')[nX]:setProp('ElectronicAccessKey', (cAliasGW3)->(GW3_CTE))
					Endif
					(cAliasGW3)->(DbSkip())
					nX++							
				EndDo

				self:oEaiObjSn2:setProp('ShippingIssuer', {})
							
				nX := 1
				(cAliasGU3)->(dbGoTop())	
				While (cAliasGU3)->(!Eof()) 
				 	If (cAliasGU3)->GU3_FILIAL == FWxFilial("GU3") .AND. ;
					   (cAliasGU3)->GU3_CDEMIT == (cAliasGW6)->&(Self:oFieldsJson['IssuerCode'])				

					 	self:oEaiObjSn2:getpropvalue('ShippingIssuer')[nX]:setProp('FederalID', (cAliasGU3)->(GU3_IDFED))

					 	nX++					 	
					 	Exit
					EndIf

					(cAliasGU3)->(DbSkip())					
				End	
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			(cAliasGW6)->(DBCloseArea())	
			(cAliasGW7)->(DBCloseArea())
			(cAliasGW3)->(DBCloseArea())	
			(cAliasGU3)->(DBCloseArea())	
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Silvana Vieira Torres Streit
@since 22/10/2019
@version 1.0
@return cAliasGW6, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWFreightInvoicesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local nY 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cWhereGW7	   as CHARACTER
	Local cWhereGW3	   as CHARACTER
	Local cWhereGU3	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasGW6    as CHARACTER
	Local cAliasGW7    as CHARACTER
	Local cAliasGW3    as CHARACTER
	Local cAliasGU3    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cQuery4	   as CHARACTER
	Local cQuery5	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasGW6 	:= GetNextAlias()
	cAliasGW7 	:= GetNextAlias()
	cAliasGW3 	:= GetNextAlias()
	cAliasGU3 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cWhereGW7 	:= "1=1"
	cWhereGW3 	:= "1=1"
	cWhereGU3 	:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	If SELECT(cAliasGW6) > 0
		dbCloseArea(cAliasGW6)
		cAliasGW6 := GetNextAlias()
		
		if SELECT(cAliasGW7) > 0 
			dbCloseArea(cAliasGW7)
			cAliasGW7 := GetNextAlias()
		endIf
		
		if SELECT(cAliasGW3) > 0 
			dbCloseArea(cAliasGW3)
			cAliasGW3 := GetNextAlias()
		endIf
		
		if SELECT(cAliasGU3) > 0 
			dbCloseArea(cAliasGU3)
			cAliasGU3 := GetNextAlias()
		endIf
	endIf
	
	//Pega os atributos que foram passado para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	if oJsonFilter != Nil
	
		aTemp := oJsonFilter:getProperties()
		
		for nX := 1 to len(aTemp)
			cValWhe := aTemp[nX]
			
			if !Empty(Self:oFieldsJsw[aTemp[nX]])
			
				cWhere += ' AND '
				aRet := StrTokArr( oJsonFilter[aTemp[nX]], "|" )
				
				if ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
				EndIf
				
				if len(aRet) == 1 //apenas uma condição
					cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
				Else //mais de uma condição
					// Quando houver mais de um parâmetro para o mesmo filtro
					// Ex: GFEA070API/api/gfe/v1/FreightInvoices/?Status=2|5
					If Len(aRet) >= 2
						cWhere += "("
						
						For nY := 1 to len(aRet)						
							If nY >= 2
								cWhere += ' OR '
							Endif
							cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + aRet[nY] + "'"
						Next nY
						
						cWhere += ")"				
					Endif	
				Endif								
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
				lRet := .F.
			EndIf
		next nX	
		
		aTemp := Self:oEaiObjRec:getOrder()
		cOrder := ''
		for nX := 1 to len(aTemp)
			if nX != 1
				cOrder += ','
			Endif
			
			cValOrd := aTemp[nX]
	
			if substr(aTemp[nX],1,1) == '-'
				if !empty(Self:oFieldsJson[substr(aTemp[nX],2)])
					cOrder += Self:oFieldsJson[substr(aTemp[nX],2)] + ' desc'
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			Else
				if !Empty(Self:oFieldsJson[cValOrd])
					cOrder += Self:oFieldsJson[aTemp[nX]]
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			EndIf
		next nX
	Else
		If !Empty(cCod)		
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " GW6_FILIAL = '" + aRet[1] + "' AND GW6_EMIFAT = '" + aRet[2] + "' AND GW6_SERFAT = '" + aRet[3] + "' AND GW6_NRFAT = '" + aRet[4] + "' AND GW6_DTEMIS = '" + aRet[5] + "' "		
		ElseIf !EMPTY(Self:oEaiObjRec:getPathParam('InternalID')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalID'), "|" )	
			cWhere := " GW6_FILIAL = '" + aRet[1] + "' AND GW6_EMIFAT = '" + aRet[2] + "' AND GW6_SERFAT = '" + aRet[3] + "' AND GW6_NRFAT = '" + aRet[4] + "' AND GW6_DTEMIS = '" + aRet[5] + "' "			
		EndIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * , ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GW6_MOTBLO)),'') AS GW6_MOTBLO2, "
		cQuery1 += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GW6_OBS)),'') AS GW6_OBS2, "
		cQuery1 += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GW6_MOTFIN)),'') AS GW6_MOTFIN2, "
		cQuery1 += " ('" + BuscaParam("MV_DSICCD",FWxFilial("GW6"),"") + "') AS GW6_DSICCD2, "
		cQuery1 += " ('" + BuscaParam("MV_DSICCL",FWxFilial("GW6"),"") + "') AS GW6_DSICCL2, "
		cQuery1 += " ('" + BuscaParam("MV_DSISCD",FWxFilial("GW6"),"") + "') AS GW6_DSISCD2, "
		cQuery1 += " ('" + BuscaParam("MV_DSISCL",FWxFilial("GW6"),"") + "') AS GW6_DSISCL2 "		
		cQuery2 := " FROM  " + RetSqlName("GW6") + " GW6"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND GW6.D_E_L_E_T_ = ' '"
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasGW6,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
				cCod := (cAliasGW6)->GW6_FILIAL + "|" + (cAliasGW6)->GW6_NRFAT
			endIf
		endIf
		
		cQuery3 := " SELECT  * "
		cQuery3 += " FROM  " + RetSqlName("GW7") + " GW7"
		cQuery3 += " INNER JOIN " + RetSqlName("GW6") + " GW6"
		cQuery3 += " ON  GW7.GW7_FILIAL = GW6.GW6_FILIAL "
		cQuery3 += " AND GW7.GW7_EMIFAT = GW6.GW6_EMIFAT "
		cQuery3 += " AND GW7.GW7_SERFAT = GW6.GW6_SERFAT "
		cQuery3 += " AND GW7.GW7_NRFAT = GW6.GW6_NRFAT "
		cQuery3 += " AND GW7.GW7_DTEMIS = GW6.GW6_DTEMIS " 
		cQuery3 += " AND  " + cWhere  		
		cQuery3 += " WHERE " + cWhereGW7 
		cQuery3 += " AND GW7.D_E_L_E_T_ = ' '"			
				
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasGW7,.F.,.T.)
		
		cQuery4 := " SELECT * "
		cQuery4 += "   FROM  " + RetSqlName("GW3") + " GW3"
		cQuery4 += "   INNER JOIN " + RetSqlName("GW6") + " GW6"
		cQuery4 += "   ON  GW3.GW3_FILFAT = GW6.GW6_FILIAL "
		cQuery4 += "   AND GW3.GW3_EMIFAT = GW6.GW6_EMIFAT "
		cQuery4 += "   AND GW3.GW3_SERFAT = GW6.GW6_SERFAT "
		cQuery4 += "   AND GW3.GW3_NRFAT  = GW6.GW6_NRFAT  "
		cQuery4 += "   AND GW3.GW3_DTEMFA = GW6.GW6_DTEMIS " 		
		cQuery4 += "   AND  " + cWhere  		
		cQuery4 += "  WHERE " + cWhereGW3 
		cQuery4 += "    AND GW3.D_E_L_E_T_ = ' '"			
			
		cQuery4 := ChangeQuery(cQuery4)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery4),cAliasGW3,.F.,.T.)
		
		If cWhere = "1=1" 
			cQuery5 := " SELECT  * "
			cQuery5 += " FROM  " + RetSqlName("GU3") + " GU3"  		
			cQuery5 += " WHERE " + cWhereGU3 
			cQuery5 += " AND GU3.D_E_L_E_T_ = ' '"
		Else
			cQuery5 := " SELECT  * "
			cQuery5 += " FROM  " + RetSqlName("GU3") + " GU3"
			cQuery5 += " INNER JOIN " + RetSqlName("GW6") + " GW6"
			cQuery5 += " ON  GU3.GU3_FILIAL = '" + FWxFilial("GU3") + "' " 
			cQuery5 += " AND  GU3.GU3_CDEMIT = GW6.GW6_EMIFAT "
			cQuery5 += " AND  " + cWhere  		
			cQuery5 += " WHERE " + cWhereGU3 
			cQuery5 += " AND GU3.D_E_L_E_T_ = ' '"
		EndIf		
				
		cQuery5 := ChangeQuery(cQuery5)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery5),cAliasGU3,.F.,.T.)
		
	else
		Self:lOk := .F.
	EndIf	
Return {cAliasGW6, cAliasGW7, cAliasGW3, cAliasGU3}

/*/{Protheus.doc} UpdateFreightDocuments
//Responsável por alterar o registro passado por parametro.
@author Silvana Vieira Torres Streit
@since 21/10/2019
@version 1.0
@return cCodId, código da entidade alterada.

@type function
/*/
Method UpdateFreightInvoices() CLASS FWFreightInvoicesAdapter
	Local lRet 		as LOGICAL
	Local oModel 	as OBJECT
	Local oMdlGW6 	as OBJECT
	Local cCodId	as CHARACTER

	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf

	GW6->(dbSetOrder( 1 ))
	If GW6->(dbSeek( aRet[1] + aRet[2] + aRet[3] + aRet[4] + aRet[5]))

		// 2=Pendente | 5=Pendente Desatualização
		If GW6->GW6_SITFIN != '2' .AND. GW6->GW6_SITFIN != '5'

			Self:oEaiObjRec:setError("A fatura deve estar com situação financeira como 'Pendente' ou 'Pendente Desatualização'")	
			Self:lOk := .F.			
			Self:cError := "A fatura deve estar com situação financeira como 'Pendente' ou 'Pendente Desatualização'"

		ElseIf lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('FinancialStatus')) 
			
			oModel := FWLoadModel('GFEA070')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			lRet := oModel:Activate()	
			
			If !lRet
				Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])	
				Self:lOk := .F.			
				Self:cError := cValToChar(oModel:GetErrorMessage()[6])
			Else
				oMdlGW6 := oModel:GetModel('GFEA070_GW6')
				
				If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('FinancialStatus'))
					lRet := oMdlGW6:SetValue('GW6_SITFIN', Self:oEaiObjRec:getPropValue('FinancialStatus'))
				Endif
				
				If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('FinancialRejectionReason'))
					lRet := oMdlGW6:SetValue('GW6_MOTFIN', Self:oEaiObjRec:getPropValue('FinancialRejectionReason'))
				Endif
				
				If lRet 
					If oModel:VldData()		
						lRet := oModel:CommitData()		
						Self:lOk := .T.
					Else				
						RollBackSX8()
						Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])
						Self:lOk := .F.
						Self:cError := cValToChar(oModel:GetErrorMessage()[6])
					EndIf
				else
					Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])	
					Self:lOk := .F.			
					Self:cError := cValToChar(oModel:GetErrorMessage()[6])
				EndIf
				
				oModel:DeActivate()
			EndIf				

		Else
			oModel := FWLoadModel('GFEA070')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			lRet := oModel:Activate()	
			
			If !lRet
				Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])	
				Self:lOk := .F.			
				Self:cError := cValToChar(oModel:GetErrorMessage()[6])
			Else
				oMdlGW6 := oModel:GetModel('GFEA070_GW6')
				
			 	if oModel:VldData()	
					lRet := oModel:CommitData()		
					Self:lOk := .T.			
				else 					
					RollBackSX8()
					Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])
					Self:lOk := .F.
					Self:cError := cValToChar(oModel:GetErrorMessage()[6])
				EndIf
				
				oModel:DeActivate()				

			Endif				
		Endif
	Else
		Self:oEaiObjRec:setError("Fatura de frete não encontrada com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Fatura de frete não encontrada com a chave informada."
	EndIf
Return cCodId

Static Function BuscaParam(cParam,cFil,xPadrao)
	Local xConteudo

	xConteudo := GETNEWPAR(cParam, xPadrao ,cFil )

	If Empty(xConteudo)
		xConteudo := GETNEWPAR(cParam, "" )
	EndIf

Return xConteudo
