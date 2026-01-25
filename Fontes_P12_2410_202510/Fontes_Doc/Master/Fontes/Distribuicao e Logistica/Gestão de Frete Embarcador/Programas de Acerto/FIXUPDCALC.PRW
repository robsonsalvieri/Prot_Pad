#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 

User Function FIXUPDCALC() 
	Local dDataIni := StoD("20180101")
	Local dDataFim := StoD("20190101")
	Local lRet := .T.
	Local oDlg
	
	DEFINE MSDIALOG oDlg TITLE "Informe a faixa de Data" From 4,0 To 16,40 OF oMainWnd //"Liberar"

		@ 19, 006  SAY "Data Inicial: " SIZE 70,7 PIXEL OF oDlg 
		@ 34, 006  SAY "Data Final: " SIZE 70,7 PIXEL OF oDlg

		@ 18, 060  MSGET dDataIni  When .T. PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlg hasbutton
		@ 33, 060  MSGET dDataFim  When .T. PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlg hasbutton

		oButtonOK   := tButton():New(80,5,'OK',oDlg,{||If(GFEFixUC(DtoS(dDataIni), DtoS(dDataFim)),oDlg:End(),lRet:=.F.)},25,10,,,,.T.)
		oButtonCanc := tButton():New(80,35,"Cancelar",oDlg,{||lRet:=.F.,oDlg:End()},25,10,,,,.T.) //"Cancelar"

	ACTIVATE MSDIALOG oDlg

Return .T.

Function GFEFixUC(cDataIni, cDataFim)

Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local cVLCNPJ 	:=  SuperGetMV('MV_VLCNPJ',,'1')

Default cDataIni := "20181201"
Default cDataFim := "20191201"

	dbSelectArea("GW0")
	GW0->(dbSetOrder(1))//GW0_FILIAL+GW0_TABELA+GW0_CHAVE
	
	If SuperGetMV("MV_DPSERV", .F., "1") == "1"
		cQuery := " SELECT DISTINCT GWF.R_E_C_N_O_ RECNOGWF, GWF_NRCALC, GWF_TRANSP, GWF_TPCALC, GW4_TPDC, GW4_EMISDC, GW4_SERDC, GW4_NRDC,  "
		cQuery += "   GU3A.GU3_IDFED AS GU3A_IDFED, GU3B.GU3_IDFED AS GU3B_IDFED, GW3.GW3_FILIAL, GW3.GW3_CDESP, GW3.GW3_EMISDF, GW3.GW3_SERDF, GW3.GW3_NRDF, GW3.GW3_DTEMIS, GW3.GW3_CDTPSE "  
		cQuery += "   FROM "+RetSqlName('GW4')+" GW4 "
		cQuery += "  INNER JOIN "+RetSqlName('GW3')+" GW3 ON "
		cQuery += "        GW4.GW4_FILIAL = GW3.GW3_FILIAL "
		cQuery += "    AND GW4.GW4_EMISDF = GW3.GW3_EMISDF "
		cQuery += "    AND GW4.GW4_CDESP  = GW3.GW3_CDESP  "
		cQuery += "    AND GW4.GW4_SERDF  = GW3.GW3_SERDF  "
		cQuery += "    AND GW4.GW4_NRDF   = GW3.GW3_NRDF   "
		cQuery += "    AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS "
		cQuery += "  INNER JOIN "+RetSqlName('GU3')+" GU3A ON (GU3A.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3A.GU3_CDEMIT = GW3.GW3_EMISDF AND GU3A.D_E_L_E_T_ = ' ') "
		cQuery += "  INNER JOIN "+RetSqlName('GWH')+" GWH"
		cQuery += "     ON GWH.GWH_FILIAL = GW4.GW4_FILIAL"
		cQuery += "    AND GWH.GWH_CDTPDC = GW4.GW4_TPDC"
		cQuery += "    AND GWH.GWH_EMISDC = GW4.GW4_EMISDC"
		cQuery += "    AND GWH.GWH_SERDC  = GW4.GW4_SERDC"
		cQuery += "    AND GWH.GWH_NRDC   = GW4.GW4_NRDC"
		cQuery += "    AND GWH.D_E_L_E_T_ = ' '"
		cQuery += "  INNER JOIN "+RetSqlName('GWF')+" GWF "
		cQuery += "     ON GWF.GWF_FILIAL = GWH_FILIAL "
		cQuery += "    AND GWF.GWF_NRCALC = GWH_NRCALC "
		cQuery += "    AND GWF.GWF_TPCALC = GW3.GW3_TPDF "
		cQuery += "    AND GWF.GWF_CDTPSE = GW3.GW3_CDTPSE "
		cQuery += "    AND GWF.GWF_CDESP  = '"+Space(TamSX3("GWF_CDESP")[1])+"'"
		cQuery += "    AND GWF.GWF_EMISDF = '"+Space(TamSX3("GWF_EMISDF")[1])+"'"
		cQuery += "    AND GWF.GWF_SERDF  = '"+Space(TamSX3("GWF_SERDF")[1])+"'"
		cQuery += "    AND GWF.GWF_NRDF   = '"+Space(TamSX3("GWF_NRDF")[1])+"'"
		cQuery += "    AND GWF.GWF_DTEMDF = '"+Space(TamSX3("GWF_DTEMDF")[1])+"'"
		If cVLCNPJ == "1"
			cQuery += " AND GWF.GWF_TRANSP = GW3.GW3_EMISDF "
		EndIf
		cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
		cQuery += "  INNER JOIN "+RetSqlName('GU3')+" GU3B ON (GU3B.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3B.GU3_CDEMIT = GWF.GWF_TRANSP AND GU3B.D_E_L_E_T_ = ' ') "
		cQuery += "    WHERE GW4.D_E_L_E_T_ = ' '"
		cQuery += "	 AND GW3.GW3_SIT IN ('2','3','4') "
		cQuery += " AND GW3.GW3_DTEMIS >= '" + cDataIni + "' AND GW3.GW3_DTEMIS <= '" + cDataFim + "' "
		cQuery += "	 AND GW3.D_E_L_E_T_ = ' ' "
		cQuery += "    ORDER BY GW4_TPDC, GW4_EMISDC, GW4_SERDC, GW4_NRDC, GWF_NRCALC"
		cQuery := ChangeQuery(cQuery)
		GFEConout("INFO",cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
		While (cAlias)->(!EoF())	    
			
			If cVLCNPJ == "1" .Or. SubStr((cAlias)->GU3A_IDFED, 1, 8) == SubStr((cAlias)->GU3B_IDFED, 1, 8)			
		        GWF->(dbsetorder(6))
				If (cAlias)->GWF_TPCALC == "1" .Or. !GWF->(msseek((cAlias)->GW3_FILIAL + (cAlias)->GW3_CDESP + (cAlias)->GW3_EMISDF + (cAlias)->GW3_SERDF + (cAlias)->GW3_NRDF + (cAlias)->GW3_DTEMIS))
				
			        GWF->(dbGoTo((cAlias)->RECNOGWF))					
				
					RecLock("GWF",.F.)
					GWF->GWF_CDESP := (cAlias)->GW3_CDESP  
					GWF->GWF_EMISDF:= (cAlias)->GW3_EMISDF 
					GWF->GWF_SERDF := (cAlias)->GW3_SERDF  
					GWF->GWF_NRDF  := (cAlias)->GW3_NRDF   
					GWF->GWF_DTEMDF:= SToD((cAlias)->GW3_DTEMIS)  
					GFEConout("INFO",'[RUP_GFE] - Doc. Frete ' + (cAlias)->GW3_CDESP + (cAlias)->GW3_EMISDF + (cAlias)->GW3_SERDF + (cAlias)->GW3_NRDF + (cAlias)->GW3_DTEMIS + ' relacionado ao calculo ' + GWF->GWF_NRCALC) 
					MsUnlock("GWF")					
								   						
				EndIf
			EndIf				
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())  
	ElseIf SuperGetMV("MV_DPSERV", .F., "1") == "2"

		GWF->(dbGoTop())
		While GWF->(!EoF())
			RecLock("GWF",.F.)
				GWF->GWF_CDESP := ""  
				GWF->GWF_EMISDF:= ""
				GWF->GWF_SERDF := ""
				GWF->GWF_NRDF  := ""
				GWF->GWF_DTEMDF:= STOD("")  
			MsUnlock("GWF")
			GWF->(dbSkip())
		EndDo
		 
	EndIf
	
	IF !GW0->( dbSeek(Space(Len(xFilial("GW0"))) + PadR("GWF", TamSX3("GW0_TABELA")[1]) + PadR("MV_DPSERV", TamSX3("GW0_CHAVE")[1])) )
		RecLock("GW0", .T.)
			GW0->GW0_TABELA := "GWF"
			GW0->GW0_CHAVE  := "MV_DPSERV"
			GW0->GW0_CHAR01 := GetComputerName() + "Data Exec - De: " + cDataIni + " Até: " + cDataFim
			GW0->GW0_DATA01 := Date()
		GW0->( MSUnlock() )
	EndIf
	
	//Mensagem de Conclusão da atualização.
	Alert("Execução Finalizada com Sucesso!")
	
Return .T.