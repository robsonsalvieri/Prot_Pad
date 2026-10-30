/*/{Protheus.doc}
	Local lRet 
lRet := (long_description	RU34XREP01(cProgName, lBrowse))
@type user lRet
@author user
@since 23/08/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function tstR34XR()
	Local lRet as logical
	Local nRec as Numeric
	Local aRet as Array 

	lRet := RU34XREP01()
	lRet := RU34XREP02_DataValidation(0,"")
	RU34XREP08()
	lRet := RU34XREP02_DataValidation(12,"", 'XXX', 'cDesc', 'RU06D07')
	lRet := RU34XREP02_DataValidation(12,"", 'XXX', 'cDesc', 'PMSA410')
	lRet := RU34XREP02_DataValidation(12,"", 'XXX', 'cDesc', 'ATFA012')
	nRec := DeletaSx2("CV0")
	lRet := RU34XREP02_DataValidation(12,"", 'F4C', 'cDesc', 'RU06D05')
	lRet := RecuperSx2(nRec)
	aRet := MudaModo("CV0")
	lRet := RU34XREP02_DataValidation(12,"", 'F43', 'cDesc', 'RU06D05')
	lRet := RecupModo("CV0",aRet)
	lRet := RU34XREP02_DataValidation(12,"", '', 'cDesc', 'RU06D05')
	DBSelectArea('F4C')
	lRet := RU34XREP02_DataValidation(2,"F4C->F4C_PAYNAM", '', 'cDesc', 'RU06D05')

	// Deletar CV0 na SX2 e depois retornaro o registro a validade
	// //https://devforum.totvs.com.br/838-forma-certa-de-se-posicionar-em-um-item-marcado-para-ser-deletado--um-item-que-sofreu-um-dbdelete

	
Return lRet

/*/{Protheus.doc} DeletaSx2
	(long_description)
	@type  Static Function
	@author user
	@since 24/08/2024
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function DeletaSx2(cTable)
	Local  nRet as Numeric
	DbSelectArea("SX2")
	If SX2->(dbSeek(cTable))
		nRet := SX2->(RecNo())
		RecLock('SX2', .F.)
			SX2->(DbDelete())
		SX2->(MsUnlock())		
	Else
		nRet := 0
	EndIf
	SX2->(DbCloseArea())
Return nRet


Static Function RecuperSx2(nRec)
	Local  lRet as Logical
	Set Deleted Off
	DbSelectArea("SX2")
	If nRec > 0 
		SX2->(dbGoto(nRec))
		RecLock('SX2', .F.)
			lRet := SX2->(DbRecall())
		SX2->(MsUnlock())
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	SX2->(DbCloseArea())
	Set Deleted On
Return lRet


/*/{Protheus.doc} MudaModo
	(long_description)
	@type  Static Function
	@author user
	@since 25/08/2024
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MudaModo(cTable)
	Local aRet as array
	aRet :={}
	DbSelectArea("SX2")
	If SX2->(dbSeek(cTable))
		aRet := {SX2->X2_MODO,SX2->X2_MODOUN,SX2->X2_MODOEMP}
		RecLock('SX2', .F.)
			SX2->X2_MODO 	:= 'E'
			SX2->X2_MODOUN	:= 'E'
			SX2->X2_MODOEMP := 'E'
		SX2->(MsUnlock())		
	EndIf
	SX2->(DbCloseArea())	
Return aRet

/*/{Protheus.doc} RecupModo("CV0",aRet)
	(long_description)
	@type  Static Function
	@author user
	@since 26/08/2024
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RecupModo(cTable,aRet)
	Local lRet as Logical
	lRet := .f.
	IF !empty(aRet)
		If SX2->(dbSeek(cTable))
			RecLock('SX2', .F.)
				SX2->X2_MODO 	:= aRet[1]
				SX2->X2_MODOUN	:= aRet[2]
				SX2->X2_MODOEMP := aRet[3]
			SX2->(MsUnlock())		
		Endif
	Endif
Return lRet


/*/{Protheus.doc} RU34Xx33
)
@type user 	RU34XREP03_AnalyticsAutofill()function
@author .t.
@since 30/08/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function RU34Xx33()
	__cInterNet := "AUTOMATICO"
	RU34XREP03_AnalyticsAutofill()
Return .t.
