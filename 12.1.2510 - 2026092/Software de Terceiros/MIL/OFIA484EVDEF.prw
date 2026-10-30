#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA484EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD BeforeTTS()

ENDCLASS


METHOD New() CLASS OFIA484EVDEF

RETURN .T.


METHOD BeforeTTS(oModel, cModelID) CLASS OFIA484EVDEF

	Local nOperation := oModel:GetOperation()
	Local nVS3Rec    := ""

	If nOperation == MODEL_OPERATION_DELETE

		cQuery := "SELECT VS3.R_E_C_N_O_ VS3RECNO "
		cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
		cQuery += " WHERE VS3.VS3_FILIAL = '" + oModel:GetValue("VB5MASTER","VB5_FILORC") + "' "
		cQuery += 	" AND VS3.VS3_NUMORC = '" + oModel:GetValue("VB5MASTER","VB5_NUMORC") + "' "
		cQuery += 	" AND VS3.VS3_SEQUEN = '" + oModel:GetValue("VB5MASTER","VB5_SEQITE") + "' "
		cQuery += 	" AND VS3.VS3_GRUITE = '" + oModel:GetValue("VB5MASTER","VB5_GRUITE") + "' "
		cQuery += 	" AND VS3.VS3_CODITE = '" + oModel:GetValue("VB5MASTER","VB5_CODITE") + "' "
		cQuery += 	" AND VS3.VS3_QTDAGU > 0 "
		cQuery += 	" AND VS3.D_E_L_E_T_ = ' '"

		nVS3Rec := FM_SQL(cQuery)

		If nVS3Rec > 0

			DbSelectArea("VS3")
			DbGoto(nVS3Rec)

			RecLock("VS3", .f.)
				VS3->VS3_QTDAGU -= oModel:GetValue("VB5MASTER","VB5_QTDSUG")
			MsUnLock()

		EndIf

		cQuery := "SELECT VSJ.R_E_C_N_O_ VSJRECNO "
		cQuery += " FROM " + RetSqlName("VSJ") + " VSJ "
		cQuery += " WHERE VSJ.VSJ_FILIAL = '" + oModel:GetValue("VB5MASTER","VB5_FILOSV") + "' "
		cQuery += 	" AND VSJ.VSJ_NUMOSV = '" + oModel:GetValue("VB5MASTER","VB5_NUMOSV") + "' "
		cQuery += 	" AND VSJ.VSJ_GRUITE = '" + oModel:GetValue("VB5MASTER","VB5_GRUITE") + "' "
		cQuery += 	" AND VSJ.VSJ_CODITE = '" + oModel:GetValue("VB5MASTER","VB5_CODITE") + "' "
		cQuery += 	" AND VSJ.VSJ_QTDAGU > 0 "
		cQuery += 	" AND VSJ.D_E_L_E_T_ = ' '"

		nVS3Rec := FM_SQL(cQuery)

		If nVS3Rec > 0

			DbSelectArea("VSJ")
			DbGoto(nVS3Rec)

			RecLock("VSJ", .f.)
				VSJ->VSJ_QTDAGU -= oModel:GetValue("VB5MASTER","VB5_QTDSUG")
			MsUnLock()

		EndIf

	EndIf

RETURN .t.