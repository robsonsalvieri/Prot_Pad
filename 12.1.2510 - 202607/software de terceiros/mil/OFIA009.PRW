#Include "Protheus.ch"
#Include "OFIA009.CH"

/*/{Protheus.doc} OFIA009()
Manutencao VB8_CODIGO com divergencia

@author João Victor Silva
@since 18/06/2026
@version 1.0
@return  
/*/

Function OFIA009()

Local bBlocoExec := {|oSelf| FS_ALTVB8QRY(oSelf)}

	TNewProcess():New(STR0002 , STR0003, bBlocoExec, STR0004, /*cPerg*/, /*aInfoCustom*/, /*lPanelAux*/, /*nSizePanelAux*/, STR0005,.T.,.T.,.F.) //OFIA009 //Manutenção // Rotina que realiza a manutenção dos campos VB8_CODIGO gravados com divergência // Ajuste será feito apenas na filia corrente

Return

/*/{Protheus.doc} FS_ALTVB8QRY()
Função buscar as VB8_CODIGO com divergencia
e realizar a manutencao 

@author João Victor Silva
@since 18/06/2026
@version 1.0
@return  
/*/

Static Function FS_ALTVB8QRY(oSelf)

	Local cQuery := ""
	Local cVB8 := "SQLVB8HA"
	Local cCodigoVB8 := FS_ULTVB8()
	Local cMensagem := ""
	local lAlterado := .t.
	local nCont := 0
	Local nQtdRegua := 0

	dbSelectArea("VB8")

	cQuery += "SELECT R_E_C_N_O_, COUNT(*) OVER() AS QTDE_REGISTROS "
	cQuery +=	 "FROM " + RetSqlName('VB8')
	cQuery +=  " WHERE VB8_CODIGO LIKE '%[^0-9]%' AND VB8_FILIAL = '" + xFilial("VB8") + "' AND D_E_L_E_T_ = ' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cVB8 , .F., .T. )

	If (cVB8)->(EOF())
		lAlterado := .f.
	Else
		nQtdRegua := ((cVB8)->(QTDE_REGISTROS) / 1000 )
		oSelf:SetRegua1( nQtdRegua )
		
		While ! (cVB8)->(EOF())

			nCont++

			If nCont >= 1000
				nCont := 0
				cMensagem := STR0006 + " " + cValToChar((cVB8)->(R_E_C_N_O_)) //Ajustando o RECNO 
       			oSelf:IncRegua1(cMensagem)
    		EndIf

			VB8->(DbGoTo( (cVB8)->R_E_C_N_O_) )
			cCodigoVB8 := (Soma1(cCodigoVB8))
			RecLock("VB8", .F.)
				VB8->VB8_CODIGO := cCodigoVB8
			MsUnlock()

			(cVB8)->(DBSkip())
		EndDo
	Endif

	(cVB8)->(dbCloseArea())

	if lAlterado
		FWAlertSuccess(STR0007,STR0001) // Atenção // Realizado a manutenção do VB8_CODIGO com divergências.
	else 
		FWAlertInfo(STR0008,STR0001) // Atenção // "Nenhum registro com VB8_CODIGO divergente encontrado.
	endif
Return

/*/{Protheus.doc} FS_ULTVB8()
Função buscar o maior VB8_CODIGO sem divergencia
e realizar a manutencao 

@author João Victor Silva
@since 18/06/2026
@version 1.0
@return cCodigo
/*/

Static Function FS_ULTVB8()
	
	Local cQuery := ""
	Local cCodigo := ""

	cQuery += "SELECT TOP 1 VB8_CODIGO "
	cQuery +=	 "FROM " + RetSqlName('VB8')
	cQuery +=  " WHERE VB8_CODIGO NOT LIKE '%[^0-9]%' AND VB8_FILIAL = '" + xFilial("VB8") + "' AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VB8_CODIGO DESC"

	cCodigo := Alltrim(FM_SQL(cQuery))

return cCodigo
