#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA095SCH
Geração de Movimentos Contábeis via Schedule

@author Israel A. Possoli
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA095SCH()
	Private cGFETrace := GetPvProfString("General" , "GFETrace" , "ERROR" , GetAdv97() )
	
	
	If !IsBlind()
		MsgInfo("Este programa deve ser executado apenas via Schedule. " + CHR(13) + CHR(10) + "Para contabilzar documentos em lote, usar o programa GFEA095, localizado no menu 'Movimentações > Contabilização > Gerar Contabilização'.")
		Return
	EndIf
	
	If cGFETrace == "1"
		GFEConout("INFO","[" + Time() + "] [GFEA095SCH] [FATURA] [MONITORING]")
	EndIf
		
	Contabilizar()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Contabilizar
Função interna

@author Israel A. Possoli
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Contabilizar()
	Private cTipoDoct
	Private cFilialIni
	Private cFilialFim
	Private cTranspIni
	Private cTranspFim
	Private cSerieIni
	Private cSerieFim
	Private cNrDocIni
	Private cNrDocFim
	Private dDtEntrIni
	Private dDtEntrFim	
	Private dDtFiscIni
	Private dDtFiscFim	
	Private cNrContrIni
	Private cNrContrFim
	Private dDtImprIni
	Private dDtImprFim
	Private cIntFatFin
	
	cTipoDoct	:= MV_PAR01
	cFilialIni	:= MV_PAR02
	cFilialFim	:= MV_PAR03
	cTranspIni	:= MV_PAR04
	cTranspFim	:= MV_PAR05
	cSerieIni	:= MV_PAR06
	cSerieFim	:= MV_PAR07
	cNrDocIni	:= MV_PAR08 
	cNrDocFim	:= MV_PAR09
	dDtEntrIni	:= MV_PAR10
	dDtEntrFim	:= MV_PAR11
	dDtFiscIni	:= MV_PAR12
	dDtFiscFim	:= MV_PAR13
	cNrContrIni := MV_PAR14
	cNrContrFim := MV_PAR15
	dDtImprIni	:= MV_PAR16
	dDtImprFim	:= MV_PAR17
	cIntFatFin	:= MV_PAR18
	
	// Documento de Frete ----------------------------
	If cTipoDoct == 1
		ContabDoctoFrete()
	EndIf

	// Fatura ----------------------------	
	If cTipoDoct == 2
		ContabFatura()
	EndIf

	
	// Contrato ----------------------------	
	If cTipoDoct == 3
		ContabContrato()
	EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ContabFatura
Contabilização da Fatura

@author Israel A. Possoli
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ContabFatura()
	Local cFilAntOri := cFilAnt
	Local lContDoctFrete	:= .T.
	Local aRetRateio	:= Nil
	Local cAliasGW6 := GetNextAlias()
	Local cStatusLog := "[UNKNOW]"
	Local cErroLog   := ""
	
	cQuery := " SELECT GW6.* FROM " + RetSQLName("GW6") + " GW6 WHERE"
	cQuery += " 	GW6.GW6_FILIAL >= '" + cFilialIni       + "' AND GW6.GW6_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW6.GW6_EMIFAT >= '" + cTranspIni       + "' AND GW6.GW6_EMIFAT <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW6.GW6_SERFAT >= '" + cSerieIni        + "' AND GW6.GW6_SERFAT <= '" + cSerieFim        + "' AND "
	cQuery += " 	GW6.GW6_NRFAT  >= '" + cNrDocIni        + "' AND GW6.GW6_NRFAT  <= '" + cNrDocFim        + "' AND "
	cQuery += " 	GW6.GW6_DTEMIS >= '" + DTOS(dDtEntrIni) + "' AND GW6.GW6_DTEMIS <= '" + DTOS(dDtEntrFim) + "' AND "
	cQuery += " 	(GW6.GW6_SITAPR  = '3' OR GW6.GW6_SITAPR  = '4')  AND "
	cQuery += " 	(GW6.GW6_SITFIN  = '1' OR GW6.GW6_SITFIN  = '3')  AND "
	cQuery += "     GW6.D_E_L_E_T_ = ' ' AND"
	cQuery += " NOT EXISTS ( "
	cQuery += "SELECT 1 FROM " + RetSQLName("GW7") + " GW7 "
	cQuery += "WHERE GW7.GW7_FILIAL = GW6.GW6_FILIAL AND "
	cQuery += "      GW7.GW7_EMIFAT = GW6.GW6_EMIFAT AND "
	cQuery += "      GW7.GW7_SERFAT = GW6.GW6_SERFAT AND "
	cQuery += "      GW7.GW7_NRFAT  = GW6.GW6_NRFAT  AND "
	cQuery += "      GW7.GW7_DTEMIS = GW6.GW6_DTEMIS AND "
	cQuery += "      GW7.D_E_L_E_T_ = '')"	
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW6, .F., .T.)
	
	dbSelectArea((cAliasGW6))
	(cAliasGW6)->( dbGoTop() )
	
	If (cAliasGW6)->( Eof() )
		(cAliasGW6)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGW6)->( Eof() )
		cStatusLog := "[UNKNOW]"	
		dbSelectArea("GW3")
		dbSetOrder(8)
		If dbSeek((cAliasGW6)->GW6_FILIAL + (cAliasGW6)->GW6_EMIFAT + (cAliasGW6)->GW6_SERFAT + (cAliasGW6)->GW6_NRFAT + (cAliasGW6)->GW6_DTEMIS)
			
			lContDoctFrete := .T.
			While !GW3->( EOF() ) .And. ;
				   GW3->GW3_FILFAT == (cAliasGW6)->GW6_FILIAL .AND. ;
				   GW3->GW3_EMIFAT == (cAliasGW6)->GW6_EMIFAT .AND. ;
				   GW3->GW3_SERFAT == (cAliasGW6)->GW6_SERFAT .AND. ;
				   GW3->GW3_NRFAT  == (cAliasGW6)->GW6_NRFAT  .AND. ;
				   GW3->GW3_DTEMFA == STOD((cAliasGW6)->GW6_DTEMIS) .AND. ;
				   lContDoctFrete
				   
				// Realiza a o rateio do Documento de Frete
				cFilAnt := GW3->GW3_FILIAL
				aRetRateio := GFERatDF(.T., GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS)
				
				If (aRetRateio[1] == .F.)
					lContDoctFrete := .F.
					cErroLog := aRetRateio[2]
				EndIf
				
				aSize(aRetRateio, 0)
				aRetRateio := Nil
				
				GW3->( dbSkip() )	   
			EndDo
			
			If lContDoctFrete
				// Elimina os Movimentos Contábeis
				GFECTBFATD((cAliasGW6)->GW6_FILIAL, (cAliasGW6)->GW6_EMIFAT, (cAliasGW6)->GW6_SERFAT, (cAliasGW6)->GW6_NRFAT, STOD((cAliasGW6)->GW6_DTEMIS))
					
				// Criação dos movimentos contábeis
				GFECTBFATC((cAliasGW6)->GW6_FILIAL, (cAliasGW6)->GW6_EMIFAT, (cAliasGW6)->GW6_SERFAT, (cAliasGW6)->GW6_NRFAT, STOD((cAliasGW6)->GW6_DTEMIS))
				
				If cIntFatFin == 1
					dbSelectArea("GW6")
					dbSeek((cAliasGW6)->GW6_FILIAL + (cAliasGW6)->GW6_EMIFAT + (cAliasGW6)->GW6_SERFAT + (cAliasGW6)->GW6_NRFAT + (cAliasGW6)->GW6_DTEMIS)
					RecLock("GW6", .F.)
						GW6->GW6_SITFIN	:= "2"
						GW6->GW6_DTFIN	:= Date()
						GW6->GW6_HRFIN	:= SubStr(Time(), 1, 5)
						GW6->GW6_MOTFIN	:= ""
						GW6->GW6_USUFIN	:= "[SCHEDULE]"
					MsUnlock("GW6")
				EndIf
				
				cStatusLog := "[OK]"
			Else
				cStatusLog := "[ERRO] ** " + cErroLog
			EndIf
			
			If cGFETrace == "1"
				GFEConout("INFO","[" + Time() + "] [GFEA095SCH] [FATURA] Empresa/Filial: " + cEmpAnt + "/" + (cAliasGW6)->GW6_FILIAL + " [Doc: " + AllTrim((cAliasGW6)->GW6_NRFAT) + ", Serie: " + AllTrim((cAliasGW6)->GW6_SERFAT) + ", Transportador: " + AllTrim((cAliasGW6)->GW6_EMIFAT) +  "] " + cStatusLog)
			EndIf			
		EndIf
		
		(cAliasGW6)->( dbSkip() )
	EndDo
	
	(cAliasGW6)->(dbCloseArea())
	cFilAnt := cFilAntOri
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ContabDoctoFrete
Contabilização do Documento de Frete

@author Israel A. Possoli
@since 03/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ContabDoctoFrete()
	Local cFilAntOri
	Local aRetRateio
	Local nI
	Local nNovaFatura	 // RecNo da Fatura que será adicionada para ser recontabilizada, caso o rateio do DF seja realizado com sucesso
	Local aFaturas  := {} // Armazena as faturas relacionadas ao documento de frete, para regerar o rateio da fatura
	Local nCountGW3 := 0
	Local cAliasGW3 := GetNextAlias()
	
	cQuery := " SELECT GW3.* FROM " + RetSQLName("GW3") + " GW3 WHERE"
	cQuery += " 	GW3.GW3_FILIAL >= '" + cFilialIni       + "' AND GW3.GW3_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW3.GW3_EMISDF >= '" + cTranspIni       + "' AND GW3.GW3_EMISDF <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW3.GW3_SERDF  >= '" + cSerieIni        + "' AND GW3.GW3_SERDF  <= '" + cSerieFim        + "' AND "
	cQuery += " 	GW3.GW3_NRDF   >= '" + cNrDocIni        + "' AND GW3.GW3_NRDF   <= '" + cNrDocFim        + "' AND "
	cQuery += " 	GW3.GW3_DTENT  >= '" + DTOS(dDtEntrIni) + "' AND GW3.GW3_DTENT  <= '" + DTOS(dDtEntrFim) + "' AND "
	cQuery += " 	(GW3.GW3_DTFIS =  '' OR (GW3.GW3_DTFIS  >= '" + DTOS(dDtFiscIni) + "' AND GW3.GW3_DTFIS  <= '" + DTOS(dDtFiscFim) + "')) AND "
	cQuery += " 	(GW3.GW3_SIT   = '3' OR GW3.GW3_SIT   = '4')  AND "
	cQuery += "     GW3.D_E_L_E_T_ = ' ' AND "
	cQuery += "     NOT EXISTS ( " 
	cQuery += "     SELECT 1 FROM " + RetSQLName("GWA") + " GWA "
	cQuery += "     WHERE GWA_FILIAL = GW3_FILIAL AND "
	cQuery += "        GWA_TPDOC  = '2'		  AND "
	cQuery += "        GWA_CDESP  = GW3_CDESP  AND "
	cQuery += "        GWA_CDEMIT = GW3_EMISDF AND "
	cQuery += "        GWA_SERIE  = GW3_SERDF  AND "
	cQuery += "        GWA_NRDOC  = GW3_NRDF   AND "
	cQuery += "        GWA_DTEMIS = GW3_DTEMIS AND "
	cQuery += "        GWA.D_E_L_E_T_ = '')"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW3, .F., .T.)
	
	dbSelectArea((cAliasGW3))
	(cAliasGW3)->( dbGoTop() )
	
	cFilAntOri := cFilAnt
	
	If (cAliasGW3)->( Eof() )
		(cAliasGW3)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGW3)->( Eof() )
		nCountGW3++
		(cAliasGW3)->( dbSkip() )
	EndDo
	
	(cAliasGW3)->(dbGoTop())
	While !(cAliasGW3)->( Eof() )
		// Verifica se há fatura vinculada no documento de frete para regerar a contabilização 
		// A fatura deve estar aprovada e deve estar como "Não enviada" ou "Rejeitada"
		nNovaFatura := 0
		dbSelectArea("GW6")
	    dbSetOrder(1)
		If GW6->( dbSeek((cAliasGW3)->GW3_FILFAT + (cAliasGW3)->GW3_EMIFAT + (cAliasGW3)->GW3_SERFAT + (cAliasGW3)->GW3_NRFAT + (cAliasGW3)->GW3_DTEMFA) )
			// Desconsidera as Faturas que não estejam como "Não Enviada" ou "Rejeitada" no Financeiro
			If GW6->GW6_SITFIN != "1" .AND. GW6->GW6_SITFIN != "3"
				(cAliasGW3)->( dbSkip() )
			    Loop
			EndIF
			
			// Desconsidera as Faturas que não estejam aprovadas
			If GW6->GW6_SITAPR != "3" .AND. GW6->GW6_SITAPR != "4"
				(cAliasGW3)->( dbSkip() )
			    Loop
			EndIf
			nNovaFatura := GW6->( RecNo() )
		EndIF
		
		/* Realiza a o rateio do Documento de Frete */
		dbSelectArea("GW3")
		dbSetOrder(1)
		dbSeek((cAliasGW3)->GW3_FILIAL + (cAliasGW3)->GW3_CDESP + (cAliasGW3)->GW3_EMISDF + (cAliasGW3)->GW3_SERDF + (cAliasGW3)->GW3_NRDF + (cAliasGW3)->GW3_DTEMIS)
		cFilAnt := (cAliasGW3)->GW3_FILIAL
		aRetRateio := GFERatDF(.T.,(cAliasGW3)->GW3_CDESP, (cAliasGW3)->GW3_EMISDF, (cAliasGW3)->GW3_SERDF, (cAliasGW3)->GW3_NRDF, STOD((cAliasGW3)->GW3_DTEMIS))
		
		If (aRetRateio[1] == .T.)
			If nNovaFatura  > 0
				// Verifica se a fatura já foi adicionada no Array
				If AScan(aFaturas, nNovaFatura) == 0
					aADD( aFaturas, nNovaFatura )
				EndIf
			EndIf
		EndIf
		
		aSize(aRetRateio, 0)
		aRetRateio := Nil
		
		If cGFETrace == "1"
			GFEConout("INFO","[" + Time() + "] [GFEA095SCH] [DOC.FRETE] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + AllTrim((cAliasGW3)->GW3_NRDF) + ", Serie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", Transportador: " + AllTrim((cAliasGW3)->GW3_EMISDF) +  "] " + cStatusLog)
		EndIf
		
		(cAliasGW3)->( dbSkip() )
	EndDo
	(cAliasGW3)->( dbCloseArea() )
	
	// Regera a grade de rateio para as faturas dos cálculos que a grade contábil foi refeita
	If Len(aFaturas) > 0
			
		For nI := 1 To Len(aFaturas)
			dbSelectArea("GW6")
			dbGoTo(aFaturas[nI])
			// Elimina os Movimentos Contábeis
			GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
				
			// Criação dos movimentos contábeis
			GFECTBFATC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
			
			If cGFETrace == "1"
				GFEConout("INFO","[" + Time() + "] [GFEA095SCH] [FATURA] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + AllTrim(GW6->GW6_NRFAT) + ", Serie: " + AllTrim(GW6->GW6_SERFAT) + ", Transportador: " + AllTrim(GW6->GW6_EMIFAT) +  "] [OK]")
			EndIf
		Next
	EndIf
	cFilAnt := cFilAntOri
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ContabContrato
Contabilização do Contrato

@author Israel A. Possoli
@since 03/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ContabContrato()
	Local cAliasGW2 := GetNextAlias()
	
	cQuery := " SELECT GW2.* FROM " + RetSQLName("GW2") + " GW2 WHERE"
	cQuery += " 	GW2.GW2_FILIAL >= '" + cFilialIni       + "' AND GW2.GW2_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW2.GW2_CDPROP >= '" + cTranspIni       + "' AND GW2.GW2_CDPROP <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW2.GW2_NRCONT >= '" + cNrContrIni      + "' AND GW2.GW2_NRCONT <= '" + cNrContrFim      + "' AND "
	cQuery += " 	GW2.GW2_DTIMPR >= '" + DTOS(dDtImprIni) + "' AND GW2.GW2_DTIMPR <= '" + DTOS(dDtImprFim) + "' AND "
	cQuery += "     GW2.D_E_L_E_T_ = ' ' AND "
	cQuery += "     NOT EXISTS ( " 
	cQuery += "     SELECT 1 FROM " + RetSQLName("GWA") + " GWA "
	cQuery += "     WHERE GWA_FILIAL = GW3_FILIAL AND "
	cQuery += "        GWA_TPDOC  = '3'		  AND "
	cQuery += "        GWA_CDEMIT = GW2_CDPROP AND "
	cQuery += "        GWA_NRDOC  = GW2_NRCONT AND "
	cQuery += "        GWA_DTEMIS = GW2_DTCRIA AND "
	cQuery += "        GWA.D_E_L_E_T_ = '')"	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW2, .F., .T.)
	
	dbSelectArea((cAliasGW2))
	(cAliasGW2)->( dbGoTop() )
	
	If (cAliasGW2)->( Eof() )
		(cAliasGW2)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGW2)->( Eof() )
		
		GFERatCon(.T.,(cAliasGW2)->GW2_NRCONT) // Executa a função GFERatCon que Gera o Rateio por Contrato que esta localizada no fonte GFEXFUNC
		
		GFEACTBCON((cAliasGW2)->GW2_NRCONT,(cAliasGW2)->GW2_CDPROP)
		
		If cGFETrace == "1"
			GFEConout("INFO","[" + Time() + "] [GFEA095SCH] [CONTRATO] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + AllTrim((cAliasGW2)->GW2_NRCONT) + ", Transportador: " + AllTrim((cAliasGW2)->GW2_CDPROP) +  "] [OK]")
		EndIf
		
		(cAliasGW2)->( dbSkip() )
	EndDo
	(cAliasGW2)->(dbCloseArea())
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Função interna para Schedule

@author Israel A. Possoli
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Scheddef()
	Local aParam
	Local aOrd := {}
	
	aParam := {"P"		,;
			   "GFEA095",;
			   "GW3"	,;
			   {}		,;
			   "Contabilização e integração "}

Return(aParam)
