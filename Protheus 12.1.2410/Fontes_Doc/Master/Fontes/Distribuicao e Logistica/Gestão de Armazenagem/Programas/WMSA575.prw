#INCLUDE "TOTVS.CH"
#INCLUDE "WMSA575.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA575
Recalcula nível do endereço
@author Squad WMS
@since 13/06/2018
@version 1.0

@return return, Nil
/*/
//--------------------------------------------------------------
Function WMSA575()
Local oProcess := MsNewProcess():New( { || Ajustar(oProcess) },STR0001 + "...", STR0002, .F. ) // Processamento // Finalizando 
	oProcess:Activate()
Return

Static Function Ajustar(oProcess)
Local cQuery    := ""
Local cAliasSBE := ""
Local aValNiv   := {}
Local nNruEnd   := 0

	If MsgYesNo(STR0003,STR0004) // Este programa irá recalcular os níveis do endereço com base no cadastro do configurador do endereço! Confirma processamento? // Recalculo de Níveis do Endereço
		If SBE->(FieldPos("BE_VALNV1"))>0
			cQuery := "SELECT COUNT(*) NRU_END"
			cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
			cQuery += " WHERE SBE.BE_FILIAL = '" + xFilial ("SBE")+ "'"
			cQuery +=   " AND SBE.BE_CODCFG <> '" + Space(TamSx3("BE_CODCFG")[1])+ "'"
			cQuery +=   " AND SBE.BE_LOCALIZ <> '" + Space(TamSx3("BE_LOCALIZ")[1])+ "'"
			cQuery +=   " AND SBE.BE_CODZON <> '" + Space(TamSx3("BE_CODZON")[1])+ "'"
			cQuery +=   " AND SBE.BE_ESTFIS <> '" + Space(TamSx3("BE_ESTFIS")[1])+ "'"
			cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSBE := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBE,.F.,.T. )
			If (cAliasSBE)->(!Eof())
				nNruEnd := (cAliasSBE)->NRU_END
			EndIf
			(cAliasSBE)->(dbCloseArea())
			
			If nNruEnd > 0 
				oProcess:SetRegua1(nNruEnd)
				cQuery := "SELECT SBE.BE_CODCFG,"
				cQuery +=       " SBE.BE_LOCALIZ,"
				cQuery +=       " SBE.R_E_C_N_O_ RECNOSBE"
				cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
				cQuery += " WHERE SBE.BE_FILIAL = '" + xFilial ("SBE")+ "'"
				cQuery +=   " AND SBE.BE_CODCFG <> '" + Space(TamSx3("BE_CODCFG")[1])+ "'"
				cQuery +=   " AND SBE.BE_LOCALIZ <> '" + Space(TamSx3("BE_LOCALIZ")[1])+ "'"
				cQuery +=   " AND SBE.BE_CODZON <> '" + Space(TamSx3("BE_CODZON")[1])+ "'"
				cQuery +=   " AND SBE.BE_ESTFIS <> '" + Space(TamSx3("BE_ESTFIS")[1])+ "'"
				cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasSBE := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBE,.F.,.T. )
				If (cAliasSBE)->(!Eof())
					Do While (cAliasSBE)->(!Eof())
						aValNiv := DLXCfgEnd((cAliasSBE)->BE_CODCFG, (cAliasSBE)->BE_LOCALIZ)
						If Len(aValNiv)>0 
							SBE->(dbGoTo((cAliasSBE)->RECNOSBE))
							
							oProcess:IncRegua1( WmsFmtMsg(STR0005 + "...",{{"[VAR01]",SBE->BE_LOCALIZ}}) ) // Processando endereço: [VAR01]
							oProcess:SetRegua2( 2 )
							oProcess:IncRegua2(STR0006) // Atualizando
							
							RecLock("SBE",.F.)
							SBE->BE_VALNV1 := IIf(Len(aValNiv)>0,Int(aValNiv[1,1]),0)
							SBE->BE_VALNV2 := IIf(Len(aValNiv)>1,Int(aValNiv[2,1]),0)
							SBE->BE_VALNV3 := IIf(Len(aValNiv)>2,Int(aValNiv[3,1]),0)
							SBE->BE_VALNV4 := IIf(Len(aValNiv)>3,Int(aValNiv[4,1]),0)
							SBE->BE_VALNV5 := IIf(Len(aValNiv)>4,Int(aValNiv[5,1]),0)
							SBE->BE_VALNV6 := IIf(Len(aValNiv)>5,Int(aValNiv[6,1]),0)
							SBE->(MsUnLock())
							oProcess:IncRegua2(STR0007) // Finalizando
						EndIf
						(cAliasSBE)->(dbSkip())
					EndDo
				EndIf
				(cAliasSBE)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
return