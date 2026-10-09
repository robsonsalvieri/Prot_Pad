#INCLUDE "JURA201J.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JApag(oParams)
Pré-Faturamento - Apagar / Substituir pré-faturas existentes.
- Movimentar pré-faturas pendentes (situação 2,3,4) para substituir a
 pré-fatura (situação 8)

- Movimentar pré-faturas com minuta (situação 5, 6) para a
situação 7 - minuta cancelada

- Desvincular os lançamentos da pré-fatura em todos os casos

@param 		cNVVCOD   			Código da Fatura Adicional
			cNW2COD				Código da Junção de Contratos
			cNT0COD				Código do Contrato
			cNVECCLIEN			Código do Cliente
			cNVELCLIEN			Código da Loja
			cNVENUMCAS			Código do Caso

@Return 	aRet	 	  		Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 12/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201JApag(oParams, cNVVCOD, cNW2COD, cNT0COD, cNVECCLIEN, cNVELCLIEN, cNVENUMCAS, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA, cTEMLM, cCodPre, cMsg)
Local aArea       := GetArea()
Local aRet        := {.T., "JA201JApag"}
Local aParams     := {}
Local cQuery      := ""
Local cQrySub     := GetNextAlias()
Local cQuery2     := ""
Local cQryApg     := GetNextAlias()
Local cPreFat     := ""
Local cQryLanc    := JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Local cPart       := JurUsuario(__CUSERID)
Local cSituac     := ""
Local lCpoFxNc    := NX0->(ColumnPos('NX0_FXNC')) > 0 // Proteção para campo de contratos fixos ou não cobráveis 

Local lJ170GRAVA  := FindFunction("J170GRAVA") .And. (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Proteção em caso de atualização deste fonte sem os demais da integração com Legal Desk
Local lIntNX0     := lJ170GRAVA .And. SuperGetMV("MV_JREVILD", .F., '2') == '1' //Controla a integracao da revisão de pré-fatura com o Legal Desk
Local lAltDelPF   := .F. // Variavel de controle para enviar ou não a pre-fatura para a fila de sync
Local oQuery      := Nil
Local cTamPrefat  := Space(TamSx3('NX0_COD')[1])
Local cFilNX0     := xFilial("NX0")
Local cFilNX1     := xFilial("NX1")
Local cFilNX8     := xFilial("NX8")

Default cMsg      := "JA201JApag ->"

	// Seleciona as pré-faturas que serão alteradas para a situação 8 (substituicao) e situação 7 (minuta cancelada)
	cQuery := " SELECT NX0.NX0_COD, NX0.R_E_C_N_O_ NRECNO, NX0.NX0_SITUAC"
	cQuery +=   " FROM " + RetSqlName("NX0") + " NX0"
	cQuery +=  " INNER JOIN " + RetSqlName("NX8") + " NX8"
	cQuery +=     " ON NX8.NX8_FILIAL = ?"
	cQuery +=    " AND NX8.NX8_CPREFT = NX0.NX0_COD"
	cQuery +=    " AND NX8.D_E_L_E_T_ = ?"
	cQuery +=  " INNER JOIN " + RetSqlName("NX1") + " NX1"
	cQuery +=     " ON NX1.NX1_FILIAL = ?"
	cQuery +=    " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT"

	Aadd(aParams, {"C", cFilNX8})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", cFilNX1})

	If Empty(cNVVCOD)
		cQuery +=    " AND NX1.NX1_CCLIEN = ?"
		cQuery +=    " AND NX1.NX1_CLOJA  = ?"
		Aadd(aParams, {"C", cNVECCLIEN})
		Aadd(aParams, {"C", cNVELCLIEN})

		If !Empty(cNVENUMCAS)
			cQuery +=    " AND NX1.NX1_CCASO = ?"
			Aadd(aParams, {"C", cNVENUMCAS})
		Else
			cQuery +=    " AND NX1.NX1_CCONTR = ?"
			Aadd(aParams, {"C", cNT0COD})
		EndIf
	EndIf

	cQuery +=    " AND NX1.D_E_L_E_T_ = ?"
	cQuery +=  " WHERE NX0.NX0_FILIAL = ?"
	cQuery +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery +=    " AND NX1.R_E_C_N_O_ IS NULL"

	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2','3','5'"})

	If !Empty(cNVVCOD)
		cQuery += " AND NX8.NX8_CFTADC = ?"
		Aadd(aParams, {"C", cNVVCOD})
	Else
		cQuery += cQryLanc
	EndIf

	cQuery +=     " AND NX0.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})

	cQuery := ChangeQuery(cQuery, .F.)

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery := JQueryPSPr(oQuery, aParams)
	cQuery := oQuery:GetFixQuery()
	MpSysOpenQuery(cQuery, cQrySub)

	BEGIN TRANSACTION

		While !(cQrySub)->(EOF())

			cPreFat := (cQrySub)->NX0_COD
			cSituac := (cQrySub)->NX0_SITUAC

			oParams:PtInternal("Erasing - 1° Sit - Pré: " + cPreFat + " Alterando para 8")

			// Altera a situação da pré-fatura
			If cSituac == "5"     
				aRet := JA201JAlt("NX0", (cQrySub)->NRECNO, "NX0_SITUAC", "7", cPreFat)
			Else
				aRet := JA201JAlt("NX0", (cQrySub)->NRECNO, "NX0_SITUAC", "8", cPreFat)
				J202HIST('99', cPreFat, cPart, cMsg) //Insere o Histórico na pré-fatura
			EndIf

			//Desvincular lançamentos
			If (aRet[1])
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Desvinculando")
				aRet := JA201JDesv(cPreFat)
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NWE")
				IIF(aRet[1], aRet := JA201JCanc("NWE", cPreFat), )
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NW0")
				IIF(aRet[1], aRet := JA201JCanc("NW0", cPreFat), )
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NVZ")
				IIF(aRet[1], aRet := JA201JCanc("NVZ", cPreFat), )
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NW4")
				IIF(aRet[1], aRet := JA201JCanc("NW4", cPreFat), )
				oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NWD")
				IIF(aRet[1], aRet := JA201JCanc("NWD", cPreFat), )
			EndIf

			If !aRet[1]
				DisarmTransaction()
				Exit
			Else

				If lJ170GRAVA .And. !lIntNX0
					//Grava na fila de sincronização a alteração de pré-fatura
					J170GRAVA("NX0", cFilNX0 + cPreFat, "4")
				EndIf

			EndIf

			(cQrySub)->( DbSkip() )

		EndDo

	END TRANSACTION

	(cQrySub)->( DbCloseArea() )

	JurFreeArr(@aParams)
	FreeObj(oQuery)

	// 2a. Situacao - Seleciona as pré-faturas que serão excluídas
	cQuery2 :=	"SELECT NX0.NX0_COD"
	cQuery2 +=	 " FROM " + RetSqlName("NX0") + " NX0"
	cQuery2 +=	 " LEFT OUTER JOIN " + RetSqlName("NXG") + " NXG"
	cQuery2 +=     " ON NXG.NXG_FILIAL = ?"
	cQuery2 +=    " AND NXG.NXG_CPREFT = NX0.NX0_COD"
	cQuery2 +=    " AND NXG.NXG_CFATUR > ?"
	cQuery2 +=    " AND NXG.NXG_CESCR  > ?"
	cQuery2 +=    " AND NXG.D_E_L_E_T_ = ?"
	cQuery2 +=  " INNER JOIN " + RetSqlName("NX8") + " NX8"
	cQuery2 +=     " ON NX8.NX8_FILIAL = ?"
	cQuery2 +=    " AND NX8.NX8_CPREFT = NX0.NX0_COD"
	cQuery2 +=    " AND NX8.D_E_L_E_T_ = ?"
	cQuery2 +=  " INNER JOIN " + RetSqlName("NX1") + " NX1"
	cQuery2 +=     " ON NX1.NX1_FILIAL = ?"
	cQuery2 +=    " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT"

	Aadd(aParams, {"C", xFilial("NXG")})
	Aadd(aParams, {"C", Space(TamSx3('NXG_CFATUR')[1])})
	Aadd(aParams, {"C", Space(TamSx3('NXG_CESCR')[1])})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", cFilNX8})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", cFilNX1})

	If Empty(cNVVCOD)
		If cTEMFX == "2"
			cQuery2 +=    " AND NX1.NX1_CCLIEN = ?"
			cQuery2 +=    " AND NX1.NX1_CLOJA  = ?"
			Aadd(aParams, {"C", cNVECCLIEN})
			Aadd(aParams, {"C", cNVELCLIEN})
			If !Empty(cNVENUMCAS)
				cQuery2 +=    " AND NX1.NX1_CCASO = ?"
				Aadd(aParams, {"C", cNVENUMCAS})
			EndIf
		EndIf
		If !Empty(cNT0COD)
			cQuery2 +=    " AND NX1.NX1_CCONTR =  NX8.NX8_CCONTR"
			cQuery2 +=    " AND NX1.NX1_CCONTR = ?"
			Aadd(aParams, {"C", cNT0COD})
		EndIf
	EndIf
	cQuery2 +=    " AND NX1.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NX0.NX0_FILIAL = ?"
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", cFilNX0})
	If oParams:GetChkApaga() .And. oParams:GetSituac() != '1'
		If oParams:GetChkApaMP()
			cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
			Aadd(aParams, {"U", "'1', '2', '3', '5', '6', '7', '9', 'A', 'B'"})
		Else
			cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
			Aadd(aParams, {"U", "'1', '2', '3'"})
		EndIf
	Else
		cQuery2 +=    " AND NX0.NX0_SITUAC = ?"
		Aadd(aParams, {"C", '1'})
	EndIf

	cQuery2 +=    " AND NXG.R_E_C_N_O_ IS NULL"

	If !Empty(cNVVCOD)
		cQuery2 +=    " AND NX8.NX8_CFTADC = ?"
		Aadd(aParams, {"C", cNVVCOD})
	Else
		cQuery2 += cQryLanc
	EndIf

	If (cTEMTS == "1" .Or. cTEMDP == "1" .Or. cTEMLT == "1" .Or. cTEMFX  == "1")
		cQuery2 +=    J201JFilDt(oParams, "ALL", @aParams) // Não apagar pré-faturas com períodos de emissão distintos
	EndIf

	If lCpoFxNc
		If oParams:GetFltrFxNc() // Indica se é uma emissão de pré de TSs de contratos fixos ou não cobráveis
			cQuery2 +=    " AND NX0.NX0_FXNC = ?"
			Aadd(aParams, {"C", '1'})
		Else // NÃO é uma emissão de TS de contrato fixo ou não cobrável
			cQuery2 +=    " AND NX0.NX0_FXNC = ?"
			Aadd(aParams, {"C", '2'})
		EndIf
	EndIf

	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})
	
	cQuery2 +=  " UNION"

	cQuery2 += " SELECT NUE.NUE_CPREFT"
	cQuery2 +=   " FROM "+ RetSqlName("NUE") + " NUE"
	cQuery2 +=   " LEFT OUTER JOIN " + RetSqlName("NX0") + " NX0"
	cQuery2 +=     " ON NX0.NX0_FILIAL = ?"
	cQuery2 +=    " AND NX0.NX0_COD = NUE.NUE_CPREFT"
	cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NUE.NUE_FILIAL = ?"
	cQuery2 +=    " AND NUE.NUE_CPREFT > ?"
	cQuery2 +=    " AND NUE.NUE_CPREFT <> ?"
	cQuery2 +=    " AND NUE.NUE_CCLIEN = ?"
	cQuery2 +=    " AND NUE.NUE_CLOJA  = ?"
	cQuery2 +=    " AND NUE.NUE_CCASO  = ?"

	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2', '3', '4', '5', '6', '7', '9', 'A', 'B', 'C', 'D', 'E', 'F'"})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", xFilial("NUE")})
	Aadd(aParams, {"C", cTamPrefat})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"C", cNVECCLIEN})
	Aadd(aParams, {"C", cNVELCLIEN})
	Aadd(aParams, {"C", cNVENUMCAS})

	cQuery2 +=    J201JFilDt(oParams, "TS", @aParams) // Não apagar pré-faturas com períodos de emissão distintos
	cQuery2 +=    " AND NX0.R_E_C_N_O_ IS NULL"
	cQuery2 +=    " AND NUE.D_E_L_E_T_ = ?"

	Aadd(aParams, {"C", ' '})

	cQuery2 +=  " UNION"

	cQuery2 += " SELECT NVY.NVY_CPREFT"
	cQuery2 +=   " FROM " + RetSqlName("NVY") + " NVY"
	cQuery2 +=   " LEFT OUTER JOIN " + RetSqlName("NX0") + " NX0"
	cQuery2 +=     " ON NX0.NX0_FILIAL = ?"
	cQuery2 +=    " AND NX0.NX0_COD = NVY.NVY_CPREFT"
	cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NVY.NVY_FILIAL = ?"
	cQuery2 +=    " AND NVY.NVY_CPREFT > ?"
	cQuery2 +=    " AND NVY.NVY_CPREFT <> ?"
	cQuery2 +=    " AND NVY.NVY_CCLIEN = ?"
	cQuery2 +=    " AND NVY.NVY_CLOJA = ?"
	cQuery2 +=    " AND NVY.NVY_CCASO = ?"

	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2', '3', '4', '5', '6', '7', '9', 'A', 'B', 'C', 'D', 'E', 'F'"})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", xFilial("NVY")})
	Aadd(aParams, {"C", cTamPrefat})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"C", cNVECCLIEN})
	Aadd(aParams, {"C", cNVELCLIEN})
	Aadd(aParams, {"C", cNVENUMCAS})

	cQuery2 +=    J201JFilDt(oParams, "DP", @aParams) // Não apagar pré-faturas com períodos de emissão distintos
	cQuery2 +=    " AND NX0.R_E_C_N_O_ IS NULL"
	cQuery2 +=    " AND NVY.D_E_L_E_T_ = ?"

	Aadd(aParams, {"C", ' '})

	cQuery2 +=  " UNION"

	cQuery2 += " SELECT NV4.NV4_CPREFT"
	cQuery2 +=   " FROM "+ RetSqlName("NV4") + " NV4"
	cQuery2 +=   " LEFT OUTER JOIN "+ RetSqlName("NX0") + " NX0"
	cQuery2 +=     " ON NX0.NX0_FILIAL = ?"
	cQuery2 +=    " AND NX0.NX0_COD = NV4.NV4_CPREFT"
	cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NV4.NV4_FILIAL = ?"
	cQuery2 +=    " AND NV4.NV4_CPREFT > ?"
	cQuery2 +=    " AND NV4.NV4_CPREFT <> ?"
	cQuery2 +=    " AND NV4.NV4_CCLIEN = ?"
	cQuery2 +=    " AND NV4.NV4_CLOJA = ?"
	cQuery2 +=    " AND NV4.NV4_CCASO = ?"

	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2', '3', '4', '5', '6', '7', '9', 'A', 'B', 'C', 'D', 'E', 'F'"})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", xFilial("NV4")})
	Aadd(aParams, {"C", cTamPrefat})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"C", cNVECCLIEN})
	Aadd(aParams, {"C", cNVELCLIEN})
	Aadd(aParams, {"C", cNVENUMCAS})

	cQuery2 +=    J201JFilDt(oParams, "TB", @aParams) // Não trazer pré-faturas com períodos de emissão distintos
	cQuery2 +=    " AND NX0.R_E_C_N_O_ IS NULL"
	cQuery2 +=    " AND NV4.D_E_L_E_T_ = ?"

	Aadd(aParams, {"C", ' '})

	cQuery2 += " UNION "

	cQuery2 += " SELECT NT1.NT1_CPREFT"
	cQuery2 +=   " FROM " + RetSqlName("NT1") + " NT1"
	cQuery2 +=   " LEFT OUTER JOIN " + RetSqlName("NX0") + " NX0"
	cQuery2 +=     " ON NX0.NX0_FILIAL = ?"
	cQuery2 +=    " AND NX0.NX0_COD = NT1.NT1_CPREFT"
	cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NT1.NT1_FILIAL = ?"
	cQuery2 +=    " AND NT1.NT1_CPREFT > ?"
	cQuery2 +=    " AND NT1.NT1_CPREFT <> ?"
	cQuery2 +=    " AND NT1.NT1_CCONTR = ?"

	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2', '3', '4', '5', '6', '7', '9', 'A', 'B', 'C', 'D', 'E', 'F'"})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", xFilial("NT1")})
	Aadd(aParams, {"C", cTamPrefat})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"C", cNT0COD})

	cQuery2 +=    J201JFilDt(oParams, "FX", @aParams) // Não apagar pré-faturas com períodos de emissão distintos
	cQuery2 +=    " AND NX0.R_E_C_N_O_ IS NULL"
	cQuery2 +=    " AND NT1.D_E_L_E_T_ = ?"

	Aadd(aParams, {"C", ' '})

	cQuery2 +=	" UNION "

	cQuery2 += " SELECT NVV.NVV_CPREFT"
	cQuery2 +=   " FROM " + RetSqlName("NVV") + " NVV"
	cQuery2 +=   " LEFT OUTER JOIN " + RetSqlName("NX0") + " NX0"
	cQuery2 +=     " ON NX0.NX0_FILIAL = ?"
	cQuery2 +=    " AND NX0.NX0_COD = NVV.NVV_CPREFT"
	cQuery2 +=    " AND NX0.NX0_SITUAC IN (?)"
	cQuery2 +=    " AND NX0.D_E_L_E_T_ = ?"
	cQuery2 +=  " WHERE NVV.NVV_FILIAL = ?"
	cQuery2 +=    " AND NVV.NVV_CPREFT > ?"
	cQuery2 +=    " AND NVV.NVV_CPREFT <> ?"
	cQuery2 +=    " AND NVV.NVV_COD = ?"

	Aadd(aParams, {"C", cFilNX0})
	Aadd(aParams, {"U", "'2', '3', '4', '5', '6', '7', '9', 'A', 'B', 'C', 'D', 'E', 'F'"})
	Aadd(aParams, {"C", ' '})
	Aadd(aParams, {"C", xFilial("NVV")})
	Aadd(aParams, {"C", cTamPrefat})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"C", cNVVCOD})

	cQuery2 +=    J201JFilDt(oParams, "FA", @aParams) // Não apagar pré-faturas com períodos de emissão distintos
	cQuery2 +=    " AND NX0.R_E_C_N_O_ IS NULL"
	cQuery2 +=    " AND NVV.D_E_L_E_T_ = ?"

	Aadd(aParams, {"C", ' '})

	cQuery2 := ChangeQuery(cQuery2, .F.)
	DbCommitAll()

	oQuery  := FWPreparedStatement():New(cQuery2)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery2 := oQuery:GetFixQuery()
	MpSysOpenQuery(cQuery2, cQryApg)

	BEGIN TRANSACTION

		While !(cQryApg)->(EOF())

			cPreFat := (cQryApg)->NX0_COD
			oParams:PtInternal("Erasing - 2° Sit - Pré: " + cPreFat)

			//Verifica se não é PF em conferência, para enviar para a fila de sync
			lAltDelPF := !(Posicione('NX0', 1, cFilNX0 + cPrefat, 'NX0_SITUAC') == '1')

			//Desvincular lançamentos
			If (aRet[1])
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Desvinculando")
				aRet := JA201JDesv(cPreFat)
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NWE")
				IIF(aRet[1], aRet := JA201JCanc("NWE", cPreFat), )
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NW0")
				IIF(aRet[1], aRet := JA201JCanc("NW0", cPreFat), )
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NVZ")
				IIF(aRet[1], aRet := JA201JCanc("NVZ", cPreFat), )
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NW4")
				IIF(aRet[1], aRet := JA201JCanc("NW4", cPreFat), )
				oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NWD")
				IIF(aRet[1], aRet := JA201JCanc("NWD", cPreFat), )
			EndIf

			//Apaga itens da tabela de pagadores da pré-faturas
			If (aRet[1])
				aRet := JA201JSubC("NXG", cPreFat)
			EndIf

			//Cancela/Substitui itens da tabela de pré-faturas
			If (aRet[1])
				aRet := JA201JSubC("NX0", cPreFat)
			EndIf  

			If (aRet[1]) .And. oParams:GetChkApaga() .And. oParams:GetChkApaMP()
				If J202CanMin( cPreFat, STR0005 ) //"Cancelamento de minuta"
					aRet := {.T., "J202CanMin"}
				Else
					aRet := {.F., "J202CanMin"}
				EndIf
			EndIf

			If !aRet[1]
				DisarmTransaction()
				Exit
			Else
				If lJ170GRAVA .And. lAltDelPF
					//Grava na fila de sincronização a exclusão de pré-fatura
					J170GRAVA("NX0", cFilNX0 + cPreFat, "5")
					J170GRAVA("JURA202E", cFilNX0 + cPreFat, "5")
				EndIf

			EndIf

			(cQryApg)->( DbSkip() )
		EndDo

	END TRANSACTION

	(cQryApg)->( DbCloseArea() )

	RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JDesv(cPreFat)
Desvincula lançamentos da Pré-Fatura

@param   cPreFat código da pré-fatura

@Return  aRet    Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 08/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201JDesv(cPreFat)
Local aRet      := {.T., "JA201JDesv"}
Local cQuery    := ""
Local aArea     := GetArea()
Local cQryRes   := GetNextAlias()

// Desvincular Time Sheet
If (aRet[1])
	cQuery := " SELECT NUE.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=    " AND NUE.NUE_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NUE.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NUE", (cQryRes)->NRECNO, "NUE_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Despesas
If (aRet[1])
	cQuery := " SELECT NVY.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NVY") + " NVY "
	cQuery +=  " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=    " AND NVY.NVY_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NVY.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NVY", (cQryRes)->NRECNO, "NVY_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Lançamento Tabelado
If (aRet[1])
	cQuery := " SELECT NV4.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NV4") + " NV4 "
	cQuery +=  " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=    " AND NV4.NV4_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NV4.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
 	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->(Eof() ) )
		aRet := JA201JAlt("NV4", (cQryRes)->NRECNO, "NV4_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Parcelas de Fixo
If (aRet[1])
	cQuery := " SELECT NT1.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NT1") + " NT1 "
	cQuery +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cQuery +=    " AND NT1.NT1_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NT1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
 	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NT1", (cQryRes)->NRECNO, "NT1_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Fatura Adicional
If (aRet[1])
	cQuery := " SELECT NVV.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NVV") + " NVV "
	cQuery +=  " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
	cQuery +=    " AND NVV.NVV_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NVV.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NVV", (cQryRes)->NRECNO, "NVV_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JAlt(cAlias,nRecno,cCampo,uValor)
Função genérica para alterar em lote o valor de um campo
Utilizado para alterar a situação da pré-fatura (substituir)

@Params		cAlias		Alias da Tabela.
	   		nRecno		Recno da Tabela as ser alterada.
			cCampo     	Campo para ser alterado
			uValor		Informação para ser gravada no campo

@Return 	aRet    	Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 08/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201JAlt(cAliasTb, nRecno, cCampo, uValor, cCodPre)
Local aArea     := GetArea()
Local aAreaA    := (cAliasTb)->(GetArea())
Local aRet      := {.T., "JA201JAlt"}
Local cErro     := ""

DbSelectArea(cAliasTb)
(cAliasTb)->(DbGoTo(nRecno))
If RecLock( cAliasTb , .F., .F., .F., .T.)
	(cAliasTb)->&(cCampo) := uValor
	(cAliasTb)->( DbCommit())
	(cAliasTb)->( MsUnlock())
	(cAliasTb)->( DbSkip() )
Else
	cErro := STR0001 + cCodPre + "! " //"Erro ao apagar a pré-fatura "
	cErro += STR0002 + alltrim(Str(nRecno)) + STR0003 + cAliasTb + " ("+ JurX2Nome(cAliasTb) +")"+ STR0004  //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
	aRet := {.F., cErro }
EndIf

RestArea( aAreaA )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Função para concatenar as flags de lançamento e devolver um filtro para
as querys da função JA201JApag.

@Params		cTEMTS		Desvincula Time Sheet?    : 1 - Sim; 2 - Não.
	   		cTEMDP		Desvincula Despesa?       : 1 - Sim; 2 - Não.
			cTEMLT     	Desvincula Lanc. Tab.     : 1 - Sim; 2 - Não.
			cTEMFX		Desvincula Fixo 	      : 1 - Sim; 2 - Não.
			cTEMLM		Desvincula Saldo de Limte : 1 - Sim; 2 - Não.

@Return 	cRet    	filtro sql para condição de existência das querys de
						desvinculo da lançamentos.

@author Luciano Pereira dos Santos
@since 08/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Local cRet := " AND ( "

If cTEMTS == "1"
	cRet += " NX1.NX1_TS = '1' OR "
EndIf

If cTEMDP == "1"
	cRet += " NX1.NX1_DESP = '1' OR "
EndIf

If cTEMLT == "1"
	cRet += " NX1.NX1_LANTAB = '1' OR "
EndIf

If cTEMFX == "1"
	cRet += " NX8.NX8_FIXO = '1' OR "
EndIf

If cTEMLM == "1"
	cRet +=  " (NX1.NX1_VTSVIN = 0 AND NX1.NX1_VTS > 0) OR "  
EndIf

If cRet == " AND ( "
	cRet := " "
Else
	cRet := SubStr( cRet, 1, Len( cRet ) - 3 ) + " ) "
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JCanc(cTabela, cCodPre)
Função para cancelar o vínculo dos lançamentos com a pré-fatura.

@Params		cTabela		Tabela que será desvinculada os lançamentos
	   		cCodPre		Pré-fatura que terão os lançamentos desvinculados

@Return 	aRet    	Retorno {True/False, Mensagem de erro}

@author 
@since 
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201JCanc(cTabela, cCodPre)
Local aRet      := {.T., "JA201JCanc"}
Local aArea     := GetArea()
Local aAreaA    := (cTabela)->(GetArea())
Local aParams   := {}
Local cQry      := ""
Local cErro     := ""
Local cAlias    := ""
Local oQuery    := Nil

	cQry += " SELECT R_E_C_N_O_ RECNO"
	cQry +=   " FROM " + RetSqlName(cTabela)
	cQry +=  " WHERE ?_FILIAL = ?"
	cQry +=    " AND ?_PRECNF = ?"
	cQry +=    " AND ?_CANC = ?"
	cQry +=    " AND D_E_L_E_T_ = ?"

	Aadd(aParams, {"U", cTabela})
	Aadd(aParams, {"C", xFilial(cTabela)})
	Aadd(aParams, {"U", cTabela})
	Aadd(aParams, {"C", cCodPre})
	Aadd(aParams, {"U", cTabela})
	Aadd(aParams, {"C", '2'})
	Aadd(aParams, {"C", ' '})
	cQry := ChangeQuery(cQry)

	oQuery := FWPreparedStatement():New(cQry)
	oQuery := JQueryPSPr(oQuery, aParams)
	cQry   := oQuery:GetFixQuery()
	cAlias := GetNextAlias()
	MpSysOpenQuery(cQry, cAlias)

	While (cAlias)->(!Eof())
		(cTabela)->(DBGoTo((cAlias)->RECNO))

		If RecLock(cTabela,.F., .F., .F., .T.)
			(cTabela)->&(cTabela+"_CANC") := "1"
			(cTabela)->(MsUnLock())
			(cTabela)->(DbCommit())
		Else
			cErro := STR0001 + cCodPre + "! " //"Erro ao apagar a pré-fatura "
			cErro += STR0002 + alltrim(Str((cAlias)->RECNO)) + STR0003 + cTabela + " (" + JurX2Nome(cTabela) + ")" + STR0004 //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
			aRet := {.F., cErro }
			Exit
		EndIf

		(cAlias)->(Dbskip())
	End

	(cAlias)->(DbCloseArea())

RestArea( aAreaA )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201JFilDt
Função para retornar um String sql para tabela NX0 contendo o filtro para impedir
a exclusão de pré-faturas do mesmo contrato ou cliente, loja e caso emitidas
usando intervalo de periodos distintos.

@Param   oParams  - Objeto contendo os metodos para recuperar os periodos
                    dos lançamentos da tela de emissão de pré-fatura
@Param   cLanc    - Tipo de lançamento: TS, TB, DP, FX ou ALL (todos)
@Param   aParams  - Array contendo os conteúdos para a substituição (Binds)

@Return  cQuery   - String sql para tabela NX0 contendo o filtro.

@author Luciano Pereira dos Santos
@since  08/09/12
/*/
//-------------------------------------------------------------------
Static Function J201JFilDt(oParams, cLanc, aParams)
Local cDtIniHO   := DtoS(oParams:GetDIniH())
Local cDtFinHO   := DtoS(oParams:GetDFinH())
Local cDtIniDP   := DtoS(oParams:GetDIniD())
Local cDtFinDP   := DtoS(oParams:GetDFinD())
Local cDtIniTB   := DtoS(oParams:GetDIniT())
Local cDtFinTB   := DtoS(oParams:GetDFinT())
Local cDtIniFA   := DtoS(oParams:GetDIniFA())
Local cDtFinFA   := DtoS(oParams:GetDFinFA())
Local dDtIniFXNC := oParams:GetDIniFxNc()
Local dDtFinFXNC := oParams:GetDFinFxNc()
Local cDtIniFXNC := IIF(Type('dDtIniFXNC') == "U", "", DtoS(dDtIniFXNC)) // Protege por conta da automação. CTs antigos não fazem o SetDIniFxNc
Local cDtFinFXNC := IIF(Type('dDtFinFXNC') == "U", "", DtoS(dDtFinFXNC)) // Protege por conta da automação. CTs antigos não fazem o SetDFinFxNc
Local cQuery     := " "

Default cLanc   := "ALL"

	If oParams:GetSituac() != '1'

		If !Empty(cDtFinHO) .And. !Empty(cDtFinHO)
			If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
				cQuery +=    " AND ((? <= NX0.NX0_DINITS AND NX0.NX0_DINITS <= ?) OR"
				cQuery +=         " (? <= NX0.NX0_DFIMTS AND NX0.NX0_DFIMTS <= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINITS AND NX0.NX0_DFIMTS >= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINITS AND NX0.NX0_DFIMTS >= ?) OR"
				cQuery +=         " (NX0.NX0_DINITS = ? AND NX0.NX0_DFIMTS = ?))"

				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DINITS')[1])})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DFIMTS')[1])})
			ElseIf cLanc == "TS" // Query do left outer join da tabela NX0 e Time Sheet que estão no periodo
				cQuery +=    " AND NUE.NUE_DATATS >= ? AND NUE.NUE_DATATS <= ?"

				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
			EndIf
		EndIf

		If !Empty(cDtIniDP) .And. !Empty(cDtFinDP)
			If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
				cQuery +=    " AND ((? <= NX0.NX0_DINIDP AND NX0.NX0_DINIDP <= ?) OR"
				cQuery +=         " (? <= NX0.NX0_DFIMDP AND NX0.NX0_DFIMDP <= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINIDP AND NX0.NX0_DFIMDP >= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINIDP AND NX0.NX0_DFIMDP >= ?) OR"
				cQuery +=         " (NX0.NX0_DINIDP = ? AND NX0.NX0_DFIMDP = ?))"

				Aadd(aParams, {"C", cDtIniDP})
				Aadd(aParams, {"C", cDtFinDP})
				Aadd(aParams, {"C", cDtIniDP})
				Aadd(aParams, {"C", cDtFinDP})
				Aadd(aParams, {"C", cDtIniDP})
				Aadd(aParams, {"C", cDtIniDP})
				Aadd(aParams, {"C", cDtFinDP})
				Aadd(aParams, {"C", cDtFinDP})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DINIDP')[1])})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DFIMDP')[1])})
			ElseIf cLanc == "DP" // Query do left outer join da tabela NVY e Despesas que estão no periodo
				cQuery +=    " AND NVY.NVY_DATA >= ? AND NVY.NVY_DATA <= ?"

				Aadd(aParams, {"C", cDtIniDP})
				Aadd(aParams, {"C", cDtFinDP})
			EndIf
		EndIf

		If !Empty(cDtIniTB) .And. !Empty(cDtFinTB)
			If cLanc == "ALL" // Query da tabela NX0 - pré-faturas que estão no periodo
				cQuery +=    " AND ((? <= NX0.NX0_DINITB AND NX0.NX0_DINITB <= ?) OR"
				cQuery +=         " (? <= NX0.NX0_DFIMTB AND NX0.NX0_DFIMTB <= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINITB AND NX0.NX0_DFIMTB >= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINITB AND NX0.NX0_DFIMTB >= ?) OR"
				cQuery +=         " (NX0.NX0_DINITB = ? AND NX0.NX0_DFIMTB = ?))"

				Aadd(aParams, {"C", cDtIniTB})
				Aadd(aParams, {"C", cDtFinTB})
				Aadd(aParams, {"C", cDtIniTB})
				Aadd(aParams, {"C", cDtFinTB})
				Aadd(aParams, {"C", cDtIniTB})
				Aadd(aParams, {"C", cDtIniTB})
				Aadd(aParams, {"C", cDtFinTB})
				Aadd(aParams, {"C", cDtFinTB})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DINITB')[1])})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DFIMTB')[1])})
			ElseIf cLanc == "TB" // Query do left outer join da tabela NV4 e Tabeldos que estão no periodo
				cQuery +=    " AND NV4.NV4_DTCONC >= ? AND NV4.NV4_DTCONC <= ?"

				Aadd(aParams, {"C", cDtIniTB})
				Aadd(aParams, {"C", cDtFinTB})
			EndIf
		EndIf

		If !Empty(cDtFinHO) .And. !Empty(cDtFinHO) .And. oParams:GetFltrHO()
			If cLanc == "ALL" // Query da tabela NX0 - pré-faturas que estão no periodo
				cQuery +=    " AND ((? <= NX0.NX0_DINIFX AND NX0.NX0_DINIFX <= ?) OR"
				cQuery +=         " (? <= NX0.NX0_DFIMFX AND NX0.NX0_DFIMFX <= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINIFX AND NX0.NX0_DFIMFX >= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DINIFX AND NX0.NX0_DFIMFX >= ?) OR"
				cQuery +=         " (NX0.NX0_DINIFX = ? AND NX0.NX0_DFIMFX = ?))"

				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", cDtFinHO})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DINIFX')[1])})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DFIMFX')[1])})
			ElseIf cLanc == "FX" // Query do left outer join da NT1 Fixos que estão no periodo
				cQuery +=    " AND NT1.NT1_DATAFI >= ? AND NT1.NT1_DATAFI <= ?"

				Aadd(aParams, {"C", cDtIniHO})
				Aadd(aParams, {"C", cDtFinHO})
			EndIf
		EndIf

		If !Empty(cDtIniFA) .And. !Empty(cDtFinFA) .And. cLanc == "FA" // Query do outer join da NVV Faturas adicionais que estão no periodo
			cQuery +=    " AND NVV.NVV_DTBASE >= ? AND NVV.NVV_DTBASE <= ?"

			Aadd(aParams, {"C", cDtIniFA})
			Aadd(aParams, {"C", cDtFinFA})
		EndIf

		If !Empty(cDtIniFXNC) .And. !Empty(cDtFinFXNC)
			If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
				cQuery +=    " AND ((? <= NX0.NX0_DIFXNC AND NX0.NX0_DIFXNC <= ?) OR"
				cQuery +=         " (? <= NX0.NX0_DFFXNC AND NX0.NX0_DFFXNC <= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DIFXNC AND NX0.NX0_DFFXNC >= ?) OR"
				cQuery +=         " (? >= NX0.NX0_DIFXNC AND NX0.NX0_DFFXNC >= ?) OR"
				cQuery +=         " (NX0.NX0_DIFXNC = ? AND NX0.NX0_DFFXNC = ?))"

				Aadd(aParams, {"C", cDtIniFXNC})
				Aadd(aParams, {"C", cDtFinFXNC})
				Aadd(aParams, {"C", cDtIniFXNC})
				Aadd(aParams, {"C", cDtFinFXNC})
				Aadd(aParams, {"C", cDtIniFXNC})
				Aadd(aParams, {"C", cDtIniFXNC})
				Aadd(aParams, {"C", cDtFinFXNC})
				Aadd(aParams, {"C", cDtFinFXNC})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DIFXNC')[1])})
				Aadd(aParams, {"C", Space(TamSx3('NX0_DFFXNC')[1])})
			ElseIf cLanc == "TS" // Query do left outer join da tabela NX0 e Time Sheet que estão no periodo
				cQuery +=    " AND NUE.NUE_DATATS >= ? AND NUE.NUE_DATATS <= ?"

				Aadd(aParams, {"C", cDtIniFXNC})
				Aadd(aParams, {"C", cDtFinFXNC})
			EndIf
		EndIf

	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JSubC()
Função para alterar a situação 8-'Substituir/Cancelar' das pré-faturas existentes
e também desvincular o pagador da pré-fatura quando for uma pré-fatura de Fatura
Adicional.

@Params cAlias  Alias da Tabela.
@Params cPreFat Código da Pré-Fatura.

@Return aRet    Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Anderson Carvalho\ Queizy Nascimento
@since 30/11/2018
/*/
//-------------------------------------------------------------------
Static Function JA201JSubC(cAliasTb, cPreFat)
	Local aArea     := GetArea()
	Local aAreaA    := (cAliasTb)->(GetArea())
	Local aRet      := {.T., "JA201JSubC"}
	Local aQry      := ""
	Local cQry      := ""
	Local cErro     := ""
	Local nI        := 0
	Local cPart     := JurUsuario(__CUSERID)

	cQry += " SELECT R_E_C_N_O_"
	cQry +=   " FROM " + RetSqlName(cAliasTb)
	cQry +=  " WHERE D_E_L_E_T_ = ' ' "
	cQry +=    " AND " + cAliasTb + "_FILIAL = '" + xFilial(cAliasTb) + "' "
	If (cAliasTb == "NXG")
		cQry += " AND NXG_CPREFT = '" + cPreFat + "'"
	Else
		cQry += " AND NX0_COD = '" + cPreFat + "'"
	EndIf
	aQry := JurSQL(cQry, "R_E_C_N_O_")

	If !Empty(aQry)
		For nI := 1 To Len(aQry)

			(cAliasTb)->(DBGoTo(aQry[nI][1]))
			If RecLock((cAliasTb),.F., .F., .F., .T.)
				If cAliasTb == "NXG" .And. !Empty((cAliasTb)->NXG_CFATAD)
					NXG->NXG_CPREFT := ""
				ElseIf cAliasTb == "NX0" .And. NX0->NX0_SITUAC <> "1" // Não altera pré de conferência
					NX0->NX0_SITUAC := "8"				
					J202HIST('5', cPreFat, cPart) //Incluir o histórico do cancelamento
				EndIf
				(cAliasTb)->(DbCommit())
				(cAliasTb)->(MsUnlock())
			Else
				cErro += STR0002 + Alltrim(Str((cAliasTb)->(Recno()))) + STR0003 + cAliasTb + " (" + JurX2Nome(cAliasTb) + ")" + STR0004  //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
				aRet := {.F., cErro}
				Exit
			EndIf
		Next nI
	EndIf

	(cAliasTb)->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaA)

	JurFreeArr(@aQry)

Return (aRet)
