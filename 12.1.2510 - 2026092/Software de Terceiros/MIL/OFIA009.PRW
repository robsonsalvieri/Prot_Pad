#Include "Protheus.ch"
#Include "OFIA009.CH"

static cBanco := TCGetDB() 

/*/{Protheus.doc} OFIA009()
Manutencao VB8_CODIGO com divergencia

@author João Victor Silva
@since 18/06/2026
@version 1.0
@return  
/*/

Function OFIA009()

Local bBlocoExec := {|oSelf| FS_ALTVB8QRY(oSelf)}

	TNewProcess():New(STR0002 , STR0003, bBlocoExec, STR0004, /*cPerg*/, /*aInfoCustom*/, /*lPanelAux*/, /*nSizePanelAux*/, STR0005,.T.,.T.,.F.) //OFIA009 //Manutenção // Rotina que identifica os registros do campo VB8_CODIGO com a informação diferente do sequencial esperado (por exemplo: 'PROBLEMX3').,  e realiza a manutenção, incrementando o sequencial com base no último registro correto // Ajuste será feito apenas na filia corrente

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
	
	If cBanco == "POSTGRES" // Separei a Query do POSTGRES por conta que o DBACESS adiciona FLOAT após o count
		cQuery += "SELECT A.R_E_C_N_O_, B.QTDE_REGISTROS FROM " + RetSqlName('VB8') + " A "
		cQuery += 	"CROSS JOIN ( "
		cQuery += 		"SELECT COUNT(*) AS QTDE_REGISTROS "
		cQuery += 			" FROM " + RetSqlName('VB8') + " "
		cQuery += 		" WHERE VB8_CODIGO ~ '[^0-9]'
		cQuery += 		" AND VB8_FILIAL = '" +xFilial("VB8") + "' "
		cQuery += 		" AND D_E_L_E_T_ = ' ' "
		cQuery += 	" ) B " 
		cQuery += " WHERE A.VB8_CODIGO ~ '[^0-9]' "
		cQuery += " AND A.VB8_FILIAL = '" + xFilial("VB8") + "' "
		cQuery += " AND A.D_E_L_E_T_ = ' ' "
	else
		cQuery += "SELECT R_E_C_N_O_, COUNT(*) OVER() AS QTDE_REGISTROS "
		cQuery +=	 "FROM " + RetSqlName('VB8') + " WHERE "	
		
		if cBanco == "MSSQL"
			cQuery += "VB8_CODIGO LIKE '%[^0-9]%' "

		elseif cBanco == "ORACLE"
			cQuery += "REGEXP_LIKE(VB8_CODIGO, '[^0-9]') "
		endif

		cQuery += "AND VB8_FILIAL = '" + xFilial("VB8") + "' AND D_E_L_E_T_ = ' ' "
	endif

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
		FWAlertSuccess(STR0007,STR0001) // Atenção // Realizado com sucesso a manutenção dos registros do campo VB8_CODIGO com a informação diferente do sequencial esperado.
	else 
		FWAlertInfo(STR0008,STR0001) // Atenção // Não foi encontrado nenhum registro com o sequencial incorreto do campo VB8_CODIGO.
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
	
	Local cQuery    := ""
	Local cCodigo   := ""
	Local oSql      := DMS_SqlHelper():New()
	Local cTopQry   := ""

	dbSelectArea("VB8")

	cQuery += "SELECT  VB8_CODIGO "
	cQuery +=	 "FROM " + RetSqlName('VB8') + " WHERE "

	if cBanco == "MSSQL"
		cQuery +=  "VB8_CODIGO NOT LIKE '%[^0-9]%' "

	elseif cBanco  == "ORACLE"
		cQuery += "REGEXP_LIKE(VB8_CODIGO, '^[0-9]+$') "
	
	elseif cBanco == "POSTGRES"
		cQuery += "VB8_CODIGO ~ '^[0-9]+$' "
	endif

	cQuery += "AND VB8_FILIAL = '" + xFilial("VB8") + "' AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VB8_CODIGO DESC"

	cTopQry := oSql:TOPFunc(cQuery, 1)

	cCodigo := Alltrim(FM_SQL(cTopQry))

return cCodigo
