#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWFreightAccountingBatchesAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cCottonGinMachine	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oArrayGXE  		as OBJECT
	DATA oArrayGXF  		as OBJECT
	DATA oArrayGXN  		as OBJECT
	DATA oArrayGXO  		as OBJECT
	DATA oFieldsGXE   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD GetFreightAccountingBatch()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD UpdateFreightAccountingBatch()
	METHOD DeleteCottonGinMachine()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Gabriela Lima
@since 21/10/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWFreightAccountingBatchesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cCottonGinMachine	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Conjuntos'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oArrayGXE  		:= self:GetNames()[1]
	self:oArrayGXF	  		:= self:GetNames()[2]
	self:oArrayGXN	  		:= self:GetNames()[3]
	self:oArrayGXO	  		:= self:GetNames()[4]
	self:oFieldsGXE   		:= self:GetNmsW()
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= JsonObject():New()
	self:oEaiObjRec 		:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Gabriela Lima 
@since 21/10/2019
@version 1.0
@Return oArrayGXE, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWFreightAccountingBatchesAdapter
	Local oArrayGXE as OBJECT
	
	oArrayGXE := &('JsonObject():New()')
	oArrayGXF := &('JsonObject():New()')
	oArrayGXN := &('JsonObject():New()')
	oArrayGXO := &('JsonObject():New()')

    // Tags Lote contábil para integração 
	oArrayGXE['InternalId']   				:= 'GXE_FILIAL + GXE_CODLOT'
	oArrayGXE['BranchId']                   := 'GXE_FILIAL'
	oArrayGXE['IssuerCode']			        := 'GXE_CDEMIT'	
	oArrayGXE['AccountLotCode']			    := 'GXE_CODLOT'
	oArrayGXE['Period']			            := 'GXE_PERIOD'	
	oArrayGXE['FinancialStatus']			:= 'GXE_SIT'	
	oArrayGXE['FinancialDate']			    := 'GXE_DTSIT'	
	oArrayGXE['FinancialRejectionReason']   := 'GXE_MOTIVO2'	

    //Tags Lançamento Provisão Contábil 
    oArrayGXF['AccountingProvisionEntry/CostCenter']        := 'GXF_CCUSTO'	
    oArrayGXF['AccountingProvisionEntry/LedgerAccount']    := 'GXF_CONTA'		
	oArrayGXF['AccountingProvisionEntry/BusinessUnit']      := 'GXF_UNINEG'	
	oArrayGXF['AccountingProvisionEntry/Value']             := 'GXF_VALOR'	
	oArrayGXF['AccountingProvisionEntry/EntryType']         := 'GXF_TPLANC'	

	//Tags Sublote Estorno de Provisão 
	oArrayGXN['ReversalProvisionSubBatch/Code']			    := 'GXN_CODEST'
	oArrayGXN['ReversalProvisionSubBatch/Period']           := 'GXN_PERIES'
	oArrayGXN['ReversalProvisionSubBatch/CreationDate']		:= 'GXN_DTCRIA'
	oArrayGXN['ReversalProvisionSubBatch/FinancialStatus']  := 'GXN_SIT'
	oArrayGXN['ReversalProvisionSubBatch/CreationUser']		:= 'GXN_USUCRI'

    //Tags Lançamento de estornos 
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/EntryDate']        := 'GXO_DATA'
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/CostCenter']       := 'GXO_CCUSTO'
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/LedgerAccount']    := 'GXO_CONTA'
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/BusinessUnit']     := 'GXO_UNINEG'
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/Value']            := 'GXO_VALOR'
	oArrayGXO['ReversalProvisionSubBatch/ReversalEntry/EntryType']        := 'GXO_TPLANC'

Return {oArrayGXE,oArrayGXF,oArrayGXN,oArrayGXO}	

Method GetNmsW() CLASS FWFreightAccountingBatchesAdapter
	Local oFieldsGXE as OBJECT
	
	oFieldsGXE := &('JsonObject():New()')

	oFieldsGXE['INTERNALID']   			   := 'GXE_FILIAL + GXE_CODLOT'
	oFieldsGXE['BRANCHID']                 := 'GXE_FILIAL'
	oFieldsGXE['ISSUERCODE']			   := 'GXE_CDEMIT'	
	oFieldsGXE['ACCOUNTLOTCODE']		   := 'GXE_CODLOT'
	oFieldsGXE['PERIOD']			       := 'GXE_PERIOD'	
	oFieldsGXE['FINANCIALSTATUS']		   := 'GXE_SIT'	
	oFieldsGXE['FINANCIALDATE']			   := 'GXE_DTSIT'	
	oFieldsGXE['FinancialRejectionReason'] := 'GXE_MOTIVO2'	

Return oFieldsGXE

/*/{Protheus.doc} GetFreightAccountingBatch
//Responsável por trazer a busca dos lotes de provisão
@author Gabriela Lima
@since 21/10/2019
@version 1.0
@Return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method GetFreightAccountingBatch(cCodId) CLASS FWFreightAccountingBatchesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasGXE 	as CHARACTER
	Local cAliasGXF 	as CHARACTER
	Local cAliasGXN		as CHARACTER
	Local cCodId 	    as CHARACTER
	Local iTp 	        as Numeric
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
	
	If Self:lApi
		If !(Empty(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasGXE := 'GXE'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasGXE := aRetAlias[1]
		cAliasGXF := aRetAlias[2]
		cAliasGXN := aRetAlias[3]
		cAliasGXO := aRetAlias[4]
		
		If Self:lOk 
			If self:cTipRet = '1'
				Self:oEaiobjSnd:setBatch(1) //Retorna array
			Else
				Self:oEaiobjSnd:setBatch(2) //Retorna um item só
			EndIf
		EndIf
		
		If Self:lOk 
			If !Empty(self:cSelectedFields)
				aSelFields := StrTokArr( self:cSelectedFields, ",")
				lFields := .T. // mandou na URL os campos a serem exibidos
			Else
				aSelFields := Self:oArrayGXE:getProperties()
			EndIf
		EndIf
	EndIf
		
	If Self:lOk	
		If self:cTipRet = '1'
			If !((cAliasGXE)->(Eof()))					
				While !((cAliasGXE)->(EOF()))
					nCount++
					
					For nJ := 1 To Len(aSelFields)
						If aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasGXE)->&(Self:oArrayGXE['BranchId']) + "|" +  (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode'])) 
						Else
							cField := aSelFields[nJ]
							cValue := Iif(Self:oArrayGXE[cField] = NIL, NIL, (cAliasGXE)->&(Self:oArrayGXE[cField]))
							If cValue != NIL
								If VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, AllTrim(cValue))
								ElseIf VALTYPE(cValue) = "N"
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
					
					//Se os campos a serem exibidos foram mandados na URL, os filhos não devem aparecer na requisição
					If !lFields
						nX := 1
						(cAliasGXF)->(dbGotop())
						While ((cAliasGXF)->(!Eof())) 					
											
							If (cAliasGXF)->GXF_FILIAL == (cAliasGXE)->&(Self:oArrayGXE['BranchId']) .AND. ;
							   (cAliasGXF)->GXF_CODLOT == (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode']) 									
							
                                Self:oEaiObjSnd:setProp('AccountingProvisionEntry', {})	 

                                Self:oEaiObjSnd:getPropValue('AccountingProvisionEntry')[nX]:setprop('CostCenter',        (cAliasGXF)->(GXF_CCUSTO))
                                Self:oEaiObjSnd:getPropValue('AccountingProvisionEntry')[nX]:setprop('LedgerAccount',     (cAliasGXF)->(GXF_CONTA))
                                Self:oEaiObjSnd:getPropValue('AccountingProvisionEntry')[nX]:setprop('BusinessUnit',      (cAliasGXF)->(GXF_UNINEG))
                                Self:oEaiObjSnd:getPropValue('AccountingProvisionEntry')[nX]:setprop('Value',		      (cAliasGXF)->(GXF_VALOR))
                                Self:oEaiObjSnd:getPropValue('AccountingProvisionEntry')[nX]:setprop('EntryType',		  (cAliasGXF)->(GXF_TPLANC))			 		
                                
                                nX++	
							EndIf
							(cAliasGXF)->(DbSkip())
													
						EndDo
						
                        nX := 1
                        (cAliasGXN)->(dbGotop())
                        While ((cAliasGXN)->(!Eof())) 
                    
                            If (cAliasGXN)->GXN_FILIAL = (cAliasGXE)->&(Self:oArrayGXE['BranchId']) .AND. ;
                                (cAliasGXN)->GXN_CODLOT = (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode']) 
    
								Self:oEaiObjSnd:setProp('ReversalProvisionSubBatch', {})	 
								
								Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('Code',	         (cAliasGXN)->(GXN_CODEST))
								Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('Period',          (cAliasGXN)->(GXN_PERIES))
								Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('CreationDate',    (cAliasGXN)->(GXN_DTCRIA))
								Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('FinancialStatus', (cAliasGXN)->(GXN_SIT))
								Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('CreationUser',    (cAliasGXN)->(GXN_USUCRI))

								nY := 1
								(cAliasGXO)->(dbGotop())
								While ((cAliasGXO)->(!Eof()))                
									
									If (cAliasGXO)->GXO_FILIAL = (cAliasGXN)->GXN_FILIAL .AND. ;
										(cAliasGXO)->GXO_CODLOT = (cAliasGXN)->GXN_CODLOT .AND. ;
										(cAliasGXO)->GXO_CODEST = (cAliasGXN)->GXN_CODEST 
										
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:setprop('ReversalEntry', {})	 
										
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('EntryDate',(cAliasGXO)->(GXO_DATA))
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('CostCenter',     (cAliasGXO)->(GXO_CCUSTO))
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('LedgerAccount',  (cAliasGXO)->(GXO_CONTA))
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('BusinessUnit',   (cAliasGXO)->(GXO_UNINEG))
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('Value',          (cAliasGXO)->(GXO_VALOR))
										Self:oEaiObjSnd:getPropValue('ReversalProvisionSubBatch')[nX]:getPropValue('ReversalEntry')[nY]:setprop('EntryType',      (cAliasGXO)->(GXO_TPLANC))
										
										nY++
									EndIf
									(cAliasGXO)->(DbSkip())
								EndDo	
								nX++
                            EndIf
                            (cAliasGXN)->(DbSkip())
                        EndDo	

					EndIf
					
					RestArea(aArea)			
					(cAliasGXE)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				EndDo
				
				If nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,Iif(Empty(nMaxRec),nLastRec,nMaxRec) )
			EndIf	
			(cAliasGXE)->(DBCloseArea())	
			(cAliasGXF)->(DBCloseArea())
			(cAliasGXN)->(DBCloseArea())
			(cAliasGXO)->(DBCloseArea())
		Else		
			If !((cAliasGXE)->(EOF()))
				For nJ := 1 To Len(aSelFields)
				
					If aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasGXE)->&(Self:oArrayGXE['BranchId']) + "|" + (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode']) 
					Else
						cField := aSelFields[nJ]
						cValue := Iif(Self:oArrayGXE[cField] = NIL, NIL, (cAliasGXE)->&(Self:oArrayGXE[cField]))
						
						If cValue != NIL
							If VALTYPE(cValue) = "C"
								self:oEaiObjSn2[cField]	:= AllTrim(cValue)
							ElseIf VALTYPE(cValue) = "N"
								self:oEaiObjSn2[cField]	:= cValToChar(cValue)
							EndIf
						Else
							Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
							Self:lOk := .F.
							Return()
						EndIf
					EndIf
				Next nJ
				
				self:oEaiObjSn2['AccountingProvisionEntry'] := {}
				Aadd(self:oEaiObjSn2['AccountingProvisionEntry'], JsonObject():New())
							
				aArea := GetArea()
				(cAliasGXF)->(dbGoTop())	
				nX := 1
				
				While ((cAliasGXF)->(!Eof())) 					
									
					If (cAliasGXF)->GXF_FILIAL == (cAliasGXE)->&(Self:oArrayGXE['BranchId']) .AND. ;
					   (cAliasGXF)->GXF_CODLOT == (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode']) 
                       
					 	If nX != 1
					 		Aadd(self:oEaiObjSn2['AccountingProvisionEntry'], JsonObject():New())
					 	EndIf
					 	
					 	self:oEaiObjSn2['AccountingProvisionEntry'][nX]['CostCenter']     := (cAliasGXF)->(GXF_CCUSTO)
					 	self:oEaiObjSn2['AccountingProvisionEntry'][nX]['LedgerAccount']  := (cAliasGXF)->(GXF_CONTA)
				 		self:oEaiObjSn2['AccountingProvisionEntry'][nX]['BusinessUnit']   := (cAliasGXF)->(GXF_UNINEG)
				 		self:oEaiObjSn2['AccountingProvisionEntry'][nX]['Value']          := (cAliasGXF)->(GXF_VALOR)
				 		self:oEaiObjSn2['AccountingProvisionEntry'][nX]['EntryType']      := (cAliasGXF)->(GXF_TPLANC)			 					 					 		
						
						nX++							
					EndIf
					(cAliasGXF)->(DbSkip())
				EndDo

				self:oEaiObjSn2['ReversalProvisionSubBatch'] := {}
				Aadd(self:oEaiObjSn2['ReversalProvisionSubBatch'], JsonObject():New())
							
				aArea := GetArea()
				(cAliasGXN)->(dbGoTop())	
				nX := 1
				
				While ((cAliasGXN)->(!Eof())) 				
									
					If (cAliasGXN)->GXN_FILIAL == (cAliasGXE)->&(Self:oArrayGXE['BranchId']) .AND. ;
					   (cAliasGXN)->GXN_CODLOT == (cAliasGXE)->&(Self:oArrayGXE['AccountLotCode']) 
                       
					 	If nX != 1
					 		Aadd(self:oEaiObjSn2['ReversalProvisionSubBatch'], JsonObject():New())
					 	EndIf
					 	
					 	self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['Code']     		:= (cAliasGXN)->(GXN_CODEST)
					 	self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['Period']  	    := (cAliasGXN)->(GXN_PERIES)
				 		self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['CreationDate']    := (cAliasGXN)->(GXN_DTCRIA)
				 		self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['FinancialStatus'] := (cAliasGXN)->(GXN_SIT)
				 		self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['CreationUser']    := (cAliasGXN)->(GXN_USUCRI)	

						nY := 1
						self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'] := {}
						Aadd(self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'], JsonObject():New())
									
						aArea := GetArea()
						(cAliasGXO)->(dbGoTop())	
						
						While ((cAliasGXO)->(!Eof())) 				
											
							If (cAliasGXO)->GXO_FILIAL = (cAliasGXN)->GXN_FILIAL .AND. ;
								(cAliasGXO)->GXO_CODLOT = (cAliasGXN)->GXN_CODLOT .AND. ;
								(cAliasGXO)->GXO_CODEST = (cAliasGXN)->GXN_CODEST 
							
								If nY != 1
									Aadd(self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'], JsonObject():New())
								EndIf
								
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['EntryDate']     	 := (cAliasGXO)->(GXO_DATA)
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['CostCenter']  	 := (cAliasGXO)->(GXO_CCUSTO)
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['LedgerAccount']   := (cAliasGXO)->(GXO_CONTA)
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['BusinessUnit']    := (cAliasGXO)->(GXO_UNINEG)
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['Value']      	 := (cAliasGXO)->(GXO_VALOR)	
								self:oEaiObjSn2['ReversalProvisionSubBatch'][nX]['ReversalEntry'][nY]['EntryType']       := (cAliasGXO)->(GXO_TPLANC)	
							
								nY++							
							EndIf
							(cAliasGXO)->(DbSkip())
						EndDo	 					 		
						nX++	
					EndIf
					(cAliasGXN)->(DbSkip())
				EndDo

			Else
				Self:cError := 'Não existe registro com este código.' + CRLF
			EndIf
			(cAliasGXE)->(DBCloseArea())	
			(cAliasGXF)->(DBCloseArea())	
			(cAliasGXN)->(DBCloseArea())
			(cAliasGXO)->(DBCloseArea())
		EndIf		
	EndIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Gabriela Lima
@since 21/10/2019
@version 1.0
@Return cAliasGXE, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWFreightAccountingBatchesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local nY 		   as NUMERIC
	Local cBranch	   as CHARACTER	
	Local cWhere	   as CHARACTER
	Local cWhere2	   as CHARACTER
	Local cWhereGXF	   as CHARACTER
	Local cWhereGXN	   as CHARACTER
	Local cWhereGXO	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasGXE    as CHARACTER
	Local cAliasGXF    as CHARACTER
	Local cAliasGXN    as CHARACTER
	Local cAliasGXO    as CHARACTER
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
	Local lPrimeiro    
	Local lSit  := .F.
	
	lRet 		:= .T.
	cAliasGXE 	:= GetNextAlias()
	cAliasGXF 	:= GetNextAlias()
	cAliasGXN 	:= GetNextAlias()
	cAliasGXO 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cWhere2		:= "1=1"
	cWhereGXF 	:= "1=1"
	cWhereGXN 	:= "1=1"
	cWhereGXO 	:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	If SELECT(cAliasGXE) > 0
		dbCloseArea(cAliasGXE)
		cAliasGXE := GetNextAlias()
		If SELECT(cAliasGXF) > 0 
			dbCloseArea(cAliasGXF)
			cAliasGXF := GetNextAlias()
		EndIf
		If SELECT(cAliasGXN) > 0 
			dbCloseArea(cAliasGXN)
			cAliasGXN := GetNextAlias()
			If SELECT(cAliasGXO) > 0 
				dbCloseArea(cAliasGXO)
				cAliasGXO := GetNextAlias()
			EndIf
		EndIf
	EndIf
	
	//Pega os atributos passados para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	If oJsonFilter != Nil
	
		aTemp := oJsonFilter:getProperties()
		
		For nX := 1 To Len(aTemp)
			cValWhe := aTemp[nX]
			
			If !Empty(Self:oFieldsGXE[aTemp[nX]])
			
				cWhere += ' AND '
				aRet := StrTokArr( oJsonFilter[aTemp[nX]], "|" )
				
				If ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
				EndIf
				
				If Len(aRet) == 1
					cWhere += Self:oFieldsGXE[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
				Else 
					// Quando houver mais de um parâmetro para o mesmo filtro
					// Ex: GFEA096API/api/gfe/v1/FreightAccountingBatches/?Status=2|5
					If Len(aRet) >= 2
                        cWhere += '('
						For nY := 1 To Len(aRet)						
							If nY >= 2
								cWhere += ' OR '
							EndIf
							cWhere += Self:oFieldsGXE[aTemp[nX]] + '=' + "'" + aRet[nY] + "'"
						Next nY	
                        cWhere += ')'			
					EndIf	
				EndIf								
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
				lRet := .F.
			EndIf
		Next nX	
		
		aTemp := Self:oEaiObjRec:getOrder()
		cOrder := ''
		For nX := 1 To Len(aTemp)
			If nX != 1
				cOrder += ','
			EndIf
			
			cValOrd := aTemp[nX]
	
			If SubStr(aTemp[nX],1,1) == '-'
				If !Empty(Self:oArrayGXE[SubStr(aTemp[nX],2)])
					cOrder += Self:oArrayGXE[SubStr(aTemp[nX],2)] + ' desc'
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			Else
				If !Empty(Self:oArrayGXE[cValOrd])
					cOrder += Self:oArrayGXE[aTemp[nX]]
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			EndIf
		Next nX
	Else
		If !Empty(cCod)	// InternalId	
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " GXE_FILIAL = '" + aRet[1] + "' AND GXE_CODLOT = '" + aRet[2] + "'"	
			cWhere2 :=	" GXN_FILIAL = '" + aRet[1] + "' AND GXN_CODLOT = '" + aRet[2] + "'"	
		ElseIf !Empty(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )	
			cWhere := " GXE_FILIAL = '" + aRet[1] + "' AND GXE_CODLOT = '" + aRet[2] + "'"			
			cWhere2 :=	" GXN_FILIAL = '" + aRet[1] + "' AND GXN_CODLOT = '" + aRet[2] + "'"	
		EndIf	
	EndIf
	
	If lRet
		Self:lOk := .T.

		cQuery1 := " SELECT  * , ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GXE_MOTIVO)),'') AS GXE_MOTIVO2 "
		cQuery2 := " FROM  " + RetSqlName("GXE") + " GXE"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND GXE.D_E_L_E_T_ = ' '"
		
		If !(Empty(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		EndIf

		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasGXE,.F.,.T.)
		
		If !Empty(cValWhe)
			If GetDataSQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			Else
				self:cTipRet = '2'
				cCod := (cAliasGXE)->GXE_FILIAL + "|" + (cAliasGXE)->GXE_CODLOT
			EndIf
		EndIf
		
		cQuery3 := " SELECT  * "
		cQuery3 += " FROM  " + RetSqlName("GXF") + " GXF"
		cQuery3 += " INNER JOIN " + RetSqlName("GXE") + " GXE"
		cQuery3 += " ON  GXF.GXF_FILIAL = GXE.GXE_FILIAL "
		cQuery3 += " AND  GXF.GXF_CODLOT = GXE.GXE_CODLOT "
		cQuery3 += " AND  " + cWhere  		
		cQuery3 += " WHERE " + cWhereGXF 	
		cQuery3 += " AND GXF.D_E_L_E_T_ = ' '"			
				
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasGXF,.F.,.T.)
		
		cQuery4 := " SELECT  * "
		cQuery4 += " FROM  " + RetSqlName("GXN") + " GXN"
		cQuery4 += " INNER JOIN " + RetSqlName("GXE") + " GXE"
		cQuery4 += " ON  GXN.GXN_FILIAL = GXE.GXE_FILIAL "
		cQuery4 += " AND  GXN.GXN_CODLOT = GXE.GXE_CODLOT "
		cQuery4 += " AND  " + cWhere				
		cQuery4 += " WHERE " + cWhereGXN
		cQuery4 += " AND GXN.D_E_L_E_T_ = ' '"

		cQuery4 := ChangeQuery(cQuery4)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery4),cAliasGXN,.F.,.T.)

        cQuery5 := " SELECT  * "
		cQuery5 += " FROM  " + RetSqlName("GXO") + " GXO"
		cQuery5 += " INNER JOIN " + RetSqlName("GXN") + " GXN"
		cQuery5 += " ON  GXO.GXO_FILIAL = GXN.GXN_FILIAL "
		cQuery5 += " AND  GXO.GXO_CODLOT = GXN.GXN_CODLOT "
		cQuery5 += " AND  GXO.GXO_CODEST = GXN.GXN_CODEST "
		cQuery5 += " AND  " + cWhere2					
		cQuery5 += " WHERE " + cWhereGXO
		cQuery5 += " AND GXO.D_E_L_E_T_ = ' '"

		cQuery5 := ChangeQuery(cQuery5)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery5),cAliasGXO,.F.,.T.)
		
	Else
		Self:lOk := .F.
	EndIf
Return {cAliasGXE,cAliasGXF,cAliasGXN,cAliasGXO}	

/*/{Protheus.doc} UpdateFreightAccountingBatch
//Responsável por alterar o registro passado por parametro.
@author Gabriela Lima
@since 21/10/2019
@version 1.0
@Return cCodId, código da entidade alterada.

@type function
/*/
Method UpdateFreightAccountingBatch() CLASS FWFreightAccountingBatchesAdapter
	Local lRet 		as LOGICAL
	Local oModel 	as OBJECT
	Local oMdlGXE 	as OBJECT
	Local cCodId	as CHARACTER

	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	If !Empty(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	EndIf

	GXE->(dbSetOrder(1))
	If GXE->(dbSeek( aRet[1] + aRet[2]))
	
		// 2=Pendente | 5=Pendente estorno | 7=Pendente Estorno Parcial
		If GXE->GXE_SIT != '2' .AND. GXE->GXE_SIT != '5' .AND. GXE->GXE_SIT != '7' 
			
			Self:oEaiObjRec:setError("O lote de provisão deve estar com situação financeira como 'Pendente', 'Pendente Desatualização' ou 'Pendente Estorno Parcial'")	
			Self:lOk := .F.			
			Self:cError := "O lote de provisão deve estar com situação financeira como 'Pendente', 'Pendente Desatualização' ou 'Pendente Estorno Parcial'"

		ElseIf lRet .And. !Empty(Self:oEaiObjRec:getPropValue('FinancialStatus'))
		
			RecLock("GXE", .F.)			
	
			GXE->GXE_SIT := Self:oEaiObjRec:getPropValue('FinancialStatus')
			
			If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('FinancialRejectionReason'))
				GXE->GXE_MOTIVO := Self:oEaiObjRec:getPropValue('FinancialRejectionReason')
			EndIf
			
			Self:lOk := .T.
			
			GXE->( MSUnlock() )
		
		Else
		
			oModel := FWLoadModel('GFEA096')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			lRet := oModel:Activate()
					
			If !lRet			
				Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])	
				Self:lOk := .F.			
				Self:cError := cValToChar(oModel:GetErrorMessage()[6])
			Else
				oMdlGXE := oModel:GetModel('GFEA096_GXE')
				
				If oModel:VldData()		
					lRet := oModel:CommitData()		
					Self:lOk := .T.
				 	If !lRet  
						RollBackSX8()
						Self:oEaiObjRec:setError("Verifique se todos os campos estão preenchidos.")
						Self:lOk := .F.
						Self:cError := "Verifique se todos os campos estão preenchidos."
					Endif
				Else
					RollBackSX8()
					Self:oEaiObjRec:setError(oModel:GetErrorMessage()[6])
					Self:lOk := .F.
					Self:cError := cValToChar(oModel:GetErrorMessage()[6])
				EndIf	

				oModel:DeActivate()				
				
			EndIf						
		EndIf
	Else
		Self:oEaiObjRec:setError("Lote de provisão não encontrado com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Lote de provisão não encontrado com a chave informada."
	EndIf
Return cCodId

Static Function BuscaParam(cParam,cFil,xPadrao)
	Local xConteudo

	xConteudo := GETNEWPAR(cParam, xPadrao ,cFil )

	If Empty(xConteudo)
		xConteudo := GETNEWPAR(cParam, "" )
	EndIf

Return xConteudo
