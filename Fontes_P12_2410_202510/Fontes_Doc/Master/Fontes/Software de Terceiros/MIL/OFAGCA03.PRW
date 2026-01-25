#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} OFAGCA03
	Rotina para envio de dados do VMI

	@author Vinicius Gati
	@since  26/11/2015
/*/
Function OFAGCA03(aParams, lTeste)
	Local nX     := 0
	Local cQuery
	Local cAl
	Private oSqlHlp, oLogger
	Private oVmi
	Private cCod
	Default aParams := {}

	If len(aParams) > 0
		Prepare Environment Empresa aParams[1] Filial aParams[2] Modulo "PEC"
	EndIf
	
	cAl             := GetNextAlias()
	oSqlHlp         := DMS_SqlHelper():New()
	oVmi            := OFAGVmi():New()
	oLogger         := DMS_Logger():New()

	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "  FROM " + oSqlHlp:NoLock('VB6')
	cQuery += " WHERE VB6_FILIAL = '"+xFilial("VB6")+"' "
	cQuery += "   AND VB6_FLGENV = '0' "
	cQuery += "   AND VB6_IMPEDI = '0' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery := oSqlHlp:TopFunc(cQuery,200)
	For nX := 1 to 10
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
		while !(cAl)->(eof())
			oVmi:Enviar((cAl)->RECNO,.f.)
			(cAl)->(DBSkip())
		end
		(cAl)->(dbCloseArea())
	Next
	dbSelectArea("VB6")

Return .T.