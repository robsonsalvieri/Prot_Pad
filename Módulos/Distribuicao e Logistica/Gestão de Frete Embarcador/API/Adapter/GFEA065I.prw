#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWFreightDocumentsAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cFreightDocument	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oArr2Json  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD GetFreightDocument()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD UpdateFreightDocuments()
	METHOD DeleteFreightDocument()
	
	METHOD CreateQuery()
	
EndClass

/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Fabiane Schulze
@since 10/10/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWFreightDocumentsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cFreightDocument	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Documentos de Frete'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	self:oArrayJson	  		:= self:GetNames()[2]
	self:oArr2Json	  		:= self:GetNames()[3]
	self:oFieldsJsw   		:= self:GetNmsW()
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= FWEAIObj():NEW()
	self:oEaiObjRec 		:= Nil
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Fabiane Schulze 
@since 10/10/2019
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWFreightDocumentsAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson 	:= &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')
	oArr2Json 	:= &('JsonObject():New()')

	oFieldsJson['InternalId']   				:= 'GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF + GW3_DTEMIS'
	oFieldsJson['BranchId']						:= 'GW3_FILIAL'
	oFieldsJson['DocumentSpecie']			    := 'GW3_CDESP'
	oFieldsJson['IssuerCode']			        := 'GW3_EMISDF'	
	oFieldsJson['DocumentSerie']			    := 'GW3_SERDF'	
	oFieldsJson['DocumentNumber']			    := 'GW3_NRDF'	
	oFieldsJson['IssueDate']			        := 'GW3_DTEMIS'	
	oFieldsJson['TypeofDocument']			    := 'GW3_TPDF'	
	oFieldsJson['InputDate']			        := 'GW3_DTENT'		
	oFieldsJson['TaxOpCode']			        := 'GW3_CFOP'	
	oFieldsJson['InputUser']			        := 'GW3_USUIMP'	
	oFieldsJson['DocumentValue']			    := 'GW3_VLDF'

	oFieldsJson['TollValue']			        := 'GW3_PEDAG'	
	If GFXCP12117("GW3_PDGFRT")
	    oFieldsJson['FreightToll']			        := 'GW3_PDGFRT'
	EndIf 
	oFieldsJson['ICMSBaseToll']			        := 'GW3_ICMPDG'
	oFieldsJson['PisCofinsBaseToll']			:= 'GW3_PDGPIS'
	oFieldsJson['TaxType']			            := 'GW3_TPIMP2' 
	oFieldsJson['TaxationType']			        := 'GW3_TRBIMP'
	oFieldsJson['TaxCalculationBase']		    := 'GW3_BASIMP'
	oFieldsJson['TaxRate']		                := 'GW3_PCIMP'
	oFieldsJson['WithheldTaxValue']      		:= 'GW3_IMPRET'
	oFieldsJson['WithheldTaxRate']		        := 'GW3_PCRET' 
	oFieldsJson['Note']		                    := 'GW3_OBS2' 
	oFieldsJson['TaxCredit']		            := 'GW3_CRDICM'
	oFieldsJson['ElectronicAccessKey']		    := 'GW3_CTE'
	oFieldsJson['IntegrationDate']		        := 'GW3_DTFIS'
	oFieldsJson['CofinsBaseValue']		        := 'GW3_BASCOF'
	oFieldsJson['CofinsValue']		            := 'GW3_VLCOF'
	oFieldsJson['PisBaseValue']		            := 'GW3_BASPIS'
	oFieldsJson['PisValue']		                := 'GW3_VLPIS'	
	oFieldsJson['GenerateCredit']		        := 'GW3_CRDPC'
	oFieldsJson['NaturSped']		            := 'GW3_NATFRE'
	oFieldsJson['Purpose']		                := 'GW3_TPCTE'
	oFieldsJson['Status']		                := 'GW3_SITFIS'
	oFieldsJson['TaxRejectionReason']		    := 'GW3_MOTFIS2'
	oFieldsJson['ServiceType']		    		:= 'GW3_CDTPSE'

	If GFXCP2510("GW3_BASIBS")
		oFieldsJson['IBSCalculationBase']		    := 'GW3_BASIBS'
		oFieldsJson['IBSRate']		                := 'GW3_PCIBS'
	EndIf

	If GFXCP2510("GW3_BASCBS")
		oFieldsJson['CBSCalculationBase']		    := 'GW3_BASCBS'
		oFieldsJson['CBSRate']		                := 'GW3_PCCBS'	
	EndIf
		
	oArrayJson['BranchId']						:= 'GWA_FILIAL'
	oArrayJson['Transaction']					:= 'GWA_CDTRAN'
	oArrayJson['Number']			            := 'GWA_NRDOC'
	oArrayJson['DebitAccount']			        := 'GWA_CTADEB'
	oArrayJson['CostCenter']			        := 'GWA_CCDEB'
	oArrayJson['BusinessUnit']			        := 'GWA_UNINEG'
	oArrayJson['Value']			                := 'GWA_VLMOV'
		
	oArr2Json['FederalID']						:= 'GU3_IDFED'
	
return {oFieldsJson, oArrayJson, oArr2Json}

Method GetNmsW() CLASS FWFreightDocumentsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')
	
	oFieldsJsw['INTERNALID']   				:= 'GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF + GW3_DTEMIS'
	oFieldsJsw['BRANCHID']					:= 'GW3_FILIAL'
	oFieldsJsw['DOCUMENTNUMBER']			:= 'GW3_NRDF'
	oFieldsJsw['DocumentSpecie']			:= 'GW3_CDESP'
	oFieldsJsw['IssuerCode']			    := 'GW3_EMISDF'
	oFieldsJsw['DOCUMENTSERIE']			    := 'GW3_SERDF'	
	oFieldsJsw['IssueDate']			        := 'GW3_DTEMIS'	
	oFieldsJsw['TypeofDocument']			:= 'GW3_TPDF'	
	oFieldsJsw['InputDate']			        := 'GW3_DTENT'		
	oFieldsJsw['TaxOpCode']			        := 'GW3_CFOP'	
	oFieldsJsw['InputUser']			        := 'GW3_USUIMP'	
	oFieldsJsw['DocumentValue']			    := 'GW3_VLDF'	
	oFieldsJsw['TollValue']			        := 'GW3_PEDAG'	
	If GFXCP12117("GW3_PDGFRT")
	    oFieldsJsw['FreightToll'] := 'GW3_PDGFRT'
	EndIf 
	oFieldsJsw['ICMSBaseToll']			    := 'GW3_ICMPDG'
	oFieldsJsw['PisCofinsBaseToll']			:= 'GW3_PDGPIS'
	oFieldsJsw['TaxType']			        := 'GW3_TPIMP2'
	oFieldsJsw['TaxationType']			    := 'GW3_TRBIMP'
	oFieldsJsw['TaxCalculationBase']		:= 'GW3_BASIMP'
	oFieldsJsw['TaxRate']		            := 'GW3_PCIMP'
	oFieldsJsw['WithheldTaxValue']      	:= 'GW3_IMPRET'
	oFieldsJsw['WithheldTaxRate']		    := 'GW3_PCRET'
	oFieldsJsw['Note']		                := 'GW3_OBS2'
	oFieldsJsw['TaxCredit']		            := 'GW3_CRDICM'
	oFieldsJsw['ElectronicAccessKey']		:= 'GW3_CTE'
	oFieldsJsw['IntegrationDate']		    := 'GW3_DTFIS'
	oFieldsJsw['CofinsBaseValue']		    := 'GW3_BASCOF'
	oFieldsJsw['CofinsValue']		        := 'GW3_VLCOF'
	oFieldsJsw['PisBaseValue']		        := 'GW3_BASPIS'
	oFieldsJsw['PisValue']		            := 'GW3_VLPIS'	
	oFieldsJsw['GenerateCredit']		    := 'GW3_CRDPC'
	oFieldsJsw['NaturSped']		            := 'GW3_NATFRE'
	oFieldsJsw['Purpose']		            := 'GW3_TPCTE'
	oFieldsJsw['STATUS']		            := 'GW3_SITFIS'
	oFieldsJsw['TaxRejectionReason']		:= 'GW3_MOTFIS2'
	oFieldsJsw['ServiceType']		        := 'GW3_CDTPSE'	

	If GFXCP2510("GW3_BASIBS")
		oFieldsJsw['IBSCalculationBase']		    := 'GW3_BASIBS'
		oFieldsJsw['IBSRate']		                := 'GW3_PCIBS'
	EndIf

	If GFXCP2510("GW3_BASCBS")
		oFieldsJsw['CBSCalculationBase']		    := 'GW3_BASCBS'
		oFieldsJsw['CBSRate']		                := 'GW3_PCCBS'	
	EndIf	

return oFieldsJsw

/*/{Protheus.doc} GetFreightDocument
//Responsável por trazer a busca dos documentos de frete
@author Fabiane Schulze
@since 10/10/2019
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method GetFreightDocument(cCodId) CLASS FWFreightDocumentsAdapter
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
	Local cAliasGWA 	as CHARACTER
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
	Local aCidades		as ARRAY
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	lRet     	:= .T.
	lFields		:= .F.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	aCidades	:= {}
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasGW3 := 'GW3'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasGW3 := aRetAlias[1]
		cAliasGWA := aRetAlias[2]
		cAliasGU3 := aRetAlias[3]
		
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
		
			While !((cAliasGW3)->(EOF())) 

				nCount++
					
				For nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSnd:setProp('InternalId', (cAliasGW3)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasGW3)->&(Self:oFieldsJson['DocumentSpecie']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['IssuerCode']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['DocumentSerie']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['DocumentNumber']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['IssueDate'])) 
					else
						
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasGW3)->&(Self:oFieldsJson[cField]))
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
				If !lFields
					
					nX := 1
						
					(cAliasGWA)->(dbGotop())
					While ((cAliasGWA)->(!Eof())) 
											
						If (cAliasGWA)->GWA_FILIAL == (cAliasGW3)->&(Self:oFieldsJson['BranchId']) .AND. ;
						   (cAliasGWA)->GWA_NRDOC == (cAliasGW3)->&(Self:oFieldsJson['DocumentNumber']) .AND. ;
						   (cAliasGWA)->GWA_CDESP == (cAliasGW3)->&(Self:oFieldsJson['DocumentSpecie']) .AND. ;
						   (cAliasGWA)->GWA_CDEMIT == (cAliasGW3)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
						   (cAliasGWA)->GWA_SERIE == (cAliasGW3)->&(Self:oFieldsJson['DocumentSerie']) 									
							
						 	Self:oEaiObjSnd:setProp('AccountingMovements', {})	 
						 
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('BranchId',			(cAliasGWA)->(GWA_FILIAL))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('Transaction',		(cAliasGWA)->(GWA_CDTRAN))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('Number',			(cAliasGWA)->(GWA_NRDOC))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('DebitAccount',		(cAliasGWA)->(GWA_CTADEB))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('CostCenter',		(cAliasGWA)->(GWA_CCDEB))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('BusinessUnit',		(cAliasGWA)->(GWA_UNINEG))
					 		Self:oEaiObjSnd:getpropvalue('AccountingMovements')[nX]:setprop('Value',			(cAliasGWA)->(GWA_VLMOV))			 		
							
							nX++	
						EndIf

						(cAliasGWA)->(DbSkip())
					End
						
					nX := 1
						
					(cAliasGU3)->(dbGotop())
					WHILE ((cAliasGU3)->(!Eof()))
						
						IF (cAliasGU3)->GU3_FILIAL == FWxFilial("GU3") .AND. ;
							(cAliasGU3)->GU3_CDEMIT == (cAliasGW3)->&(Self:oFieldsJson['IssuerCode']) 									
							
							Self:oEaiObjSnd:setProp('ShippingIssuer', {})	 
							
						 	Self:oEaiObjSnd:getpropvalue('ShippingIssuer')[nX]:setprop('FederalID', (cAliasGU3)->(GU3_IDFED))
						 		
						 	Exit
								
							nX++	
						ENDIF
						(cAliasGU3)->(DbSkip())
													
					end
						
				endIf

				aCidades := {}

				If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   		   !(Empty((cAliasGW3)->GW3_MUNINI) .And. Empty((cAliasGW3)->GW3_UFINI) .And. Empty((cAliasGW3)->GW3_MUNFIM) .And. Empty((cAliasGW3)->GW3_UFFIM))   			   					   
				
					aAdd(aCidades, {(cAliasGW3)->GW3_MUNINI, (cAliasGW3)->GW3_MUNFIM})
				Else	
					aCidades   := (GFEWSCITY( (cAliasGW3)->GW3_FILIAL, (cAliasGW3)->GW3_EMISDF, (cAliasGW3)->GW3_CDESP, (cAliasGW3)->GW3_SERDF, (cAliasGW3)->GW3_NRDF, (cAliasGW3)->GW3_DTEMIS, (cAliasGW3)->GW3_TPDF))
				EndIf

				Self:oEaiObjSnd:setProp('cityOrigin', aCidades[1][1])
				Self:oEaiObjSnd:setProp('UFOrigin', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"))
				Self:oEaiObjSnd:setProp('cityOriginName', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_NMCID"))
				Self:oEaiObjSnd:setProp('cityDestination', aCidades[1][2])
				Self:oEaiObjSnd:setProp('cityDestinationName', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_NMCID"))
				Self:oEaiObjSnd:setProp('UFDestination', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF"))

				RestArea(aArea)			
				(cAliasGW3)->(DbSkip())		
					
				Self:oEaiobjSnd:nextItem()

				nLastRec := nCount
			endDo
				
			if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
				Self:oEaiobjSnd:setHasNext(.T.)			
			EndIf
				
			Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
			Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			
			(cAliasGW3)->(DBCloseArea())	
			(cAliasGWA)->(DBCloseArea())
			(cAliasGU3)->(DBCloseArea())
		else
		
			if !((cAliasGW3)->(EOF()))
			
				for nJ := 1 to Len(aSelFields)
				
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2:setProp('InternalId', (cAliasGW3)->&(Self:oFieldsJson['BranchId']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['DocumentSpecie']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['IssuerCode']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['DocumentSerie']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['DocumentNumber']) + "|" + (cAliasGW3)->&(Self:oFieldsJson['IssueDate']))
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasGW3)->&(Self:oFieldsJson[cField]))
						
						if cValue != NIL
							If VALTYPE(cValue) = "C"
								self:oEaiObjSn2:setProp(cField, AllTrim(cValue))
							ElseIf VALTYPE(cValue) = "N"
								self:oEaiObjSn2:setProp(cField, cValToChar(cValue))
							EndIf
						Else
							Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
							Self:lOk := .F.
							Return()
						endIf
					endIf
				next nJ
				
				self:oEaiObjSn2:setProp('AccountingMovements', {})
							
				aArea := GetArea()
				
				(cAliasGWA)->(dbGoTop())	
				nX := 1
				
				While ((cAliasGWA)->(!Eof())) 	
				
					If (cAliasGWA)->GWA_FILIAL == (cAliasGW3)->&(Self:oFieldsJson['BranchId']) .AND. ;
					   (cAliasGWA)->GWA_NRDOC == (cAliasGW3)->&(Self:oFieldsJson['DocumentNumber']) .AND. ;
					   (cAliasGWA)->GWA_CDESP == (cAliasGW3)->&(Self:oFieldsJson['DocumentSpecie']) .AND. ;
					   (cAliasGWA)->GWA_CDEMIT == (cAliasGW3)->&(Self:oFieldsJson['IssuerCode']) .AND. ;
					   (cAliasGWA)->GWA_SERIE == (cAliasGW3)->&(Self:oFieldsJson['DocumentSerie'])				

					 	If nX != 1
					 		self:oEaiObjSn2:setProp('AccountingMovements', {})
					 	EndIf

						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('BranchId',			(cAliasGWA)->(GWA_FILIAL))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('Transaction',		(cAliasGWA)->(GWA_CDTRAN))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('Number',			(cAliasGWA)->(GWA_NRDOC))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('DebitAccount',		(cAliasGWA)->(GWA_CTADEB))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('CostCenter',		(cAliasGWA)->(GWA_CCDEB))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('BusinessUnit',		(cAliasGWA)->(GWA_UNINEG))
						Self:oEaiObjSn2:getpropvalue('AccountingMovements')[nX]:setprop('Value',			(cAliasGWA)->(GWA_VLMOV))
					Endif
					(cAliasGWA)->(DbSkip())
					nX++							
				End

				self:oEaiObjSn2:setProp('ShippingIssuer', {})
				Aadd(self:oEaiObjSn2:getpropvalue('ShippingIssuer'), JsonObject():New())

				aCidades := {}

				If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   		   !(Empty((cAliasGW3)->GW3_MUNINI) .And. Empty((cAliasGW3)->GW3_UFINI) .And. Empty((cAliasGW3)->GW3_MUNFIM) .And. Empty((cAliasGW3)->GW3_UFFIM))   			   					   
				
					aAdd(aCidades, {(cAliasGW3)->GW3_MUNINI, (cAliasGW3)->GW3_MUNFIM})
				Else	
					aCidades   := (GFEWSCITY( (cAliasGW3)->GW3_FILIAL, (cAliasGW3)->GW3_EMISDF, (cAliasGW3)->GW3_CDESP, (cAliasGW3)->GW3_SERDF, (cAliasGW3)->GW3_NRDF, (cAliasGW3)->GW3_DTEMIS, (cAliasGW3)->GW3_TPDF))
				EndIf
				
				self:oEaiObjSn2:setProp('cityOrigin', aCidades[1][1])
				self:oEaiObjSn2:setProp('UFOrigin', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"))
				self:oEaiObjSn2:setProp('cityOriginName', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_NMCID"))
				self:oEaiObjSn2:setProp('cityDestination', aCidades[1][2])
				self:oEaiObjSn2:setProp('cityDestinationName', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_NMCID"))
				self:oEaiObjSn2:setProp('UFDestination', Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF"))
				
				aArea := GetArea()
				(cAliasGU3)->(dbGoTop())	
				WHILE (cAliasGU3)->(!Eof()) 
				
				 	If (cAliasGU3)->GU3_FILIAL == FWxFilial("GU3") .AND. ;
					   (cAliasGU3)->GU3_CDEMIT == (cAliasGW3)->&(Self:oFieldsJson['IssuerCode'])				

						Self:oEaiObjSn2:getpropvalue('ShippingIssuer')[1]:setprop('FederalID', (cAliasGU3)->(GU3_IDFED))

					 	Exit
					EndIf

					(cAliasGU3)->(DbSkip())
				End				
			Else
				Self:cError := 'Não existe registro com este código.' + CRLF
			EndIf

			(cAliasGW3)->(DBCloseArea())	
			(cAliasGWA)->(DBCloseArea())	
			(cAliasGU3)->(DBCloseArea())
		EndIf		
	EndIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Fabiane Schulze
@since 10/10/2019
@version 1.0
@return cAliasGW3, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWFreightDocumentsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local nY 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cWhereGWA	   as CHARACTER
	Local cWhereGW4	   as CHARACTER
	Local cWhereGU3	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasGW3    as CHARACTER
	Local cAliasGWA    as CHARACTER
	Local cAliasGU3    as CHARACTER
	Local cAliasGW4    as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cQuery4	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	Local cLimit	:= ""
	
	lRet 		:= .T.
	cAliasGW3 	:= GetNextAlias()
	cAliasGWA 	:= GetNextAlias()
	cAliasGU3 	:= GetNextAlias()
	cAliasGW4 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cWhereGWA 	:= "1=1"
	cWhereGW4 	:= "1=1"
	cWhereGU3 	:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	//Pega os atributos que foram passado para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	If oJsonFilter != Nil
	
		aTemp := oJsonFilter:getProperties()
		
		for nX := 1 to len(aTemp)
			cValWhe := aTemp[nX]

			If aTemp[nX] == "LIMIT"
				cLimit := oJsonFilter[aTemp[nX]]
			Else
				if !Empty(Self:oFieldsJsw[aTemp[nX]])
				
					cWhere += ' AND '
					aRet := StrTokArr( oJsonFilter[aTemp[nX]], "|" )
					
					if ValType(oJsonFilter[aTemp[nX]]) != "C"
						oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
					EndIf
					
					if len(aRet) == 1
						cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
					Else 
						// Quando houver mais de um parâmetro para o mesmo filtro
						// Ex: GFEA065API/api/gfe/v1/FreightDocuments/?Status=2|5
						If Len(aRet) >= 2
							For nY := 1 to len(aRet)						
								If nY >= 2
									cWhere += ' OR '
								Endif
								cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + aRet[nY] + "'"
							Next nY				
						Endif	
					Endif								
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
					lRet := .F.
				EndIf
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
		If !Empty(cCod)		//
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " GW3_FILIAL = '" + aRet[1] + "' AND GW3_CDESP = '" + aRet[2] + "' AND GW3_EMISDF = '" + aRet[3] + "' AND GW3_SERDF = '" + aRet[4] + "' AND GW3_NRDF = '" + aRet[5] + "' AND GW3_DTEMIS = '" + aRet[6] + "'"		
		ElseIf !EMPTY(Self:oEaiObjRec:getPathParam('InternalID')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalID'), "|" )	
			cWhere := " GW3_FILIAL = '" + aRet[1] + "' AND GW3_CDESP = '" + aRet[2] + "' AND GW3_EMISDF = '" + aRet[3] + "' AND GW3_SERDF = '" + aRet[4] + "' AND GW3_NRDF = '" + aRet[5] + "' AND GW3_DTEMIS = '" + aRet[6] + "'"			
		EndIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := ""
		cQuery2 := ""
		cQuery3 := ""

		If !Empty(cLimit)
			cQuery1 := "TOP " + cLimit
		EndIf

		cQuery1 := "%" + cQuery1 + "%"

		cQuery2 := "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GW3_MOTFIS)),'') AS GW3_MOTFIS2, "
		cQuery2 += "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GW3_OBS)),'') AS GW3_OBS2, "
		cQuery2 += "'' AS GW3_TPIMP2 " //cQuery2 += "(POSICIONE('GVT',1,XFILIAL('GVT'),'GVT_TPIMP')) AS GW3_TPIMP2 "

		cQuery2 := "%" + cQuery2 + "%"

		If !(EMPTY(cOrder))
			cQuery3 := " ORDER BY " + cOrder + " "
		EndIf

		cQuery3 := "%" + cQuery3 + "%"

		cQuery4 := " FROM  " + RetSqlName("GW3") + " GW3"
		cQuery4 += " WHERE " + cWhere + " "
		cQuery4 += "  AND GW3.D_E_L_E_T_ = ' '" 

		cWhere := "%" + cWhere + "%"

		BeginSQL Alias cAliasGW3
			SELECT %Exp:cQuery1% *, %Exp:cQuery2% 
			FROM %Table:GW3% GW3
			WHERE %Exp:cWhere%
			AND GW3.%NotDel%
			%Exp:cQuery3%
		EndSQL

		If !EMPTY(cValWhe)
			If GETDATASQL("SELECT COUNT(*) " + cQuery4) > 1
				self:cTipRet = '1'
			Else
				self:cTipRet = '2'
				cCod := (cAliasGW3)->GW3_FILIAL + "|" + (cAliasGW3)->GW3_NRDF
			EndIf
		EndIf
		
		cWhereGWA := "%" + cWhereGWA + "%"

		If cLimit == "1"
			BeginSQL Alias cAliasGWA
				SELECT  * 
				FROM %Table:GWA% GWA
				WHERE %Exp:cWhereGWA%
				AND GWA.GWA_FILIAL = %Exp:(cAliasGW3)->GW3_FILIAL%
				AND GWA.GWA_CDESP = %Exp:(cAliasGW3)->GW3_CDESP%
				AND GWA.GWA_CDEMIT = %Exp:(cAliasGW3)->GW3_EMISDF%
				AND GWA.GWA_SERIE = %Exp:(cAliasGW3)->GW3_SERDF%
				AND GWA.GWA_NRDOC = %Exp:(cAliasGW3)->GW3_NRDF%
				AND GWA.GWA_TPDOC = '2'
				AND GWA.%NotDel%
			EndSQL
		Else
			BeginSQL Alias cAliasGWA
				SELECT  * 
				FROM %Table:GWA% GWA
				INNER JOIN %Table:GW3% GW3
				ON  GWA.GWA_FILIAL = GW3.GW3_FILIAL
				AND  GWA.GWA_CDESP = GW3.GW3_CDESP
				AND  GWA.GWA_CDEMIT = GW3.GW3_EMISDF
				AND  GWA.GWA_SERIE = GW3.GW3_SERDF
				AND  GWA.GWA_NRDOC = GW3.GW3_NRDF
				AND  %Exp:cWhere%  		
				WHERE %Exp:cWhereGWA% 
				AND GWA.GWA_TPDOC = '2'
				AND GWA.%NotDel%
			EndSQL
		EndIf

		cWhereGU3 := "%" + cWhereGU3 + "%"
		
		If cLimit == "1"
			BeginSQL Alias cAliasGU3
				SELECT  *
				FROM %Table:GU3% GU3
				WHERE %Exp:cWhereGU3% 
				AND GU3.GU3_FILIAL = %Exp:FWxFilial("GU3")% 
				AND GU3.GU3_CDEMIT = %Exp:(cAliasGW3)->GW3_EMISDF%
				AND GU3.%NotDel%
			EndSQL
		Else
			BeginSQL Alias cAliasGU3
				SELECT  *
				FROM %Table:GU3% GU3
				INNER JOIN %Table:GW3% GW3
				ON GU3.GU3_FILIAL = %Exp:FWxFilial("GU3")% 
				AND GU3.GU3_CDEMIT = GW3.GW3_EMISDF
				AND %Exp:cWhere%  		
				WHERE %Exp:cWhereGU3% 
				AND GU3.%NotDel%
			EndSQL
		EndIf
	Else
		Self:lOk := .F.
	EndIf
Return {cAliasGW3, cAliasGWA, cAliasGU3}

/*/{Protheus.doc} UpdateFreightDocuments
//Responsável por alterar o registro passado por parametro.
@author Fabiane Schulze
@since 10/10/2019
@version 1.0
@return cCodId, código da entidade alterada.

@type function
/*/
Method UpdateFreightDocuments() CLASS FWFreightDocumentsAdapter
	Local lRet 		as LOGICAL
	Local oModel 	as OBJECT
	Local oMdlGW3 	as OBJECT
	Local cCodId	as CHARACTER

	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf

	GW3->(dbSetOrder( 1 ))
	If GW3->(dbSeek( aRet[1] + aRet[2] + aRet[3] + aRet[4] + aRet[5] + aRet[6]))
	
		// 2=Pendente | 5=Pendente Desatualização
		if  GW3->GW3_SITFIS != '2' .AND. GW3->GW3_SITFIS != '5'
		
			Self:oEaiObjRec:setError("O documento de frete deve estar com situação fiscal como 'Pendente' ou 'Pendente Desatualização'")	
			Self:lOk := .F.			
			Self:cError := "O documento de frete deve estar com situação fiscal como 'Pendente' ou 'Pendente Desatualização'"
	
		ElseIf lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Status'))
		
			RecLock("GW3", .F.)			
	
			GW3->GW3_SITFIS := Self:oEaiObjRec:getPropValue('Status')
			
			If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('TaxRejectionReason'))
				GW3->GW3_MOTFIS := Self:oEaiObjRec:getPropValue('TaxRejectionReason')
			Endif
			
			Self:lOk := .T.
			
			GW3->( MSUnlock() )
				
		Else
		
			oModel := FWLoadModel('GFEA065')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			lRet := oModel:Activate()	
			
			If !lRet			
				Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])	
				Self:lOk := .F.			
				Self:cError := cValToChar(oModel:GetErrorMessage()[6])
			Else
				oMdlGW3 := oModel:GetModel('GFEA065_GW3')
				If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CFOP'))
					lRet := oMdlGW3:SetValue('GW3_CFOP', Self:oEaiObjRec:getPropValue('CFOP'))
				Endif
				
				If lRet .And. oModel:VldData()		
					lRet := oModel:CommitData()		
					Self:lOk := .T.
				EndIf	
				
				If !oModel:VldData()
					RollBackSX8()
					Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])
					Self:lOk := .F.
					Self:cError := cValToChar(oModel:GetErrorMessage()[6])
				Elseif !lRet .and. oModel:VldData() 
					RollBackSX8()
					Self:oEaiObjRec:setError("Verifique se todos os campos estão preenchidos.")
					Self:lOk := .F.
					Self:cError := "Verifique se todos os campos estão preenchidos."
				endIf	
				oModel:DeActivate()				
															
			Endif						
		Endif
	Else
		Self:oEaiObjRec:setError("Conjunto não encontrado com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Conjunto não encontrado com a chave informada."
	EndIf
Return cCodId
