#INCLUDE "PROTHEUS.CH"

// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 35     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "VEIVC060.CH"

Static lMultMoeda := FGX_MULTMOEDA() // Verifica se Trabalha com Multimoeda

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVC060 ³ Autor ³  Manoel               ³ Data ³ 15/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Estoque de Veiculos                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIVC060
Local aArea := GetArea()
VC0600019_ImprimeRelatorio() // Imprime o relatório Estoque de Veículos
RestArea( aArea )
Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600019_ImprimeRelatorio
Imprime o relatório Estoque de Veículos
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
/*/
Function VC0600019_ImprimeRelatorio()
Local cPerg := "CONEST"
Local oReport

If !Pergunte(cPerg,.t.)
	Return(.f.)
EndIf

oReport:=VC0600029_ReportDef(cPerg)
oReport:PrintDialog()

Return
//-----------------------------------------------------------------------------

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Imp_VEIVC060³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Relatorio.	                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imp_VEIVC060()

Local cSQL, cAliasTMP := "TFILMOV", cHoraEnt, cHoraSai, cPoder3, cSGBD := Upper(TcGetDb())
Local cCHAINT := ""

Local aFilAtu   := FWArrFilAtu()
Local nCont 	:= 0

Local cNamVV1   := RetSQLName("VV1")
Local cNamVVH   := RetSQLName("VVH")
Local cNamVVC   := RetSQLName("VVC")
Local cNamVV0   := RetSQLName("VV0")
Local cNamVVA   := RetSQLName("VVA")
Local cNamVVF   := RetSQLName("VVF")
Local cNamVVG   := RetSQLName("VVG")
Local cNamSF4   := RetSQLName("SF4")
Local cNamSA2   := RetSQLName("SA2")
Local cNamSA1   := RetSQLName("SA1")
Local cNamVVP   := RetSQLName("VVP")
Local cNamSB2   := RetSQLName("SB2")

Local cFilVV1   := ""
Local cFilVV2   := ""
Local cFilVVH   := ""
Local cFilVVC   := ""
Local cFilVV0   := ""
Local cFilVVF   := ""
Local cFilSF4   := ""
Local cFilSA2   := ""
Local cFilSA1   := ""
Local cFilVVP   := ""
Local cFilSB1   := ""
Local cFilSB2   := ""
Local cFornece  := ""
Local oSql       := DMS_SqlHelper():New()
Local cSQLSubs   := oSQL:CompatFunc("SUBSTR")
Local cVVFConc   := ""
Local cVV0Conc   := ""
Local aVVFConc   := {}
Local aVV0Conc   := {}

Local cVVFDTH   := '21'
Local cVV0DTH   := '21'

Local nRegistros := 0 // Total de registros do arquivo temporário

Private aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo

lc_depto  := (MV_PAR08 == 1) // MV_DEPTO"  //.T.  faz a quebra na parte de remessa por deptos (pontos de venda)

&& Cria Arquivo de Trabalho
aVetCampos := {}
aadd(aVetCampos,{ "TRB_FILIAL" , "C" , FWSizeFilial()  , 0 })
aadd(aVetCampos,{ "TRB_FILENT" , "C" , FWSizeFilial()  , 0 })
aadd(aVetCampos,{ "TRB_TIPOVV" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_PROVVV" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_DIAEST" , "N" , 6  , 0 })
aadd(aVetCampos,{ "TRB_NUMNFI" , "C" , 9  , 0 })
aadd(aVetCampos,{ "TRB_DTDIGI" , "D" , 8  , 0 })
aadd(aVetCampos,{ "TRB_FORNEC" , "C" , 10  , 0 })
aadd(aVetCampos,{ "TRB_DATEMI" , "D" , 8  , 0 })
aadd(aVetCampos,{ "TRB_MODELO" , "C" , 24 , 0 })
aadd(aVetCampos,{ "TRB_MARMOD" , "C" , 25 , 0 })
aadd(aVetCampos,{ "TRB_CHASSI" , "C" , 25 , 0 })
aadd(aVetCampos,{ "TRB_CORVEI" , "C" , 10 , 2 })
aadd(aVetCampos,{ "TRB_VALNFI" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_ICMRET" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_PICRET" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_VALFRE" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_VALTAB" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_CODIND" , "C" , 2  , 0 })
aadd(aVetCampos,{ "TRB_DESIND" , "C" , 15 , 0 })
aadd(aVetCampos,{ "TRB_TIPFAT" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_CUSTOV" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_CUSATU" , "N" , 15 , 2 })
aadd(aVetCampos,{ "TRB_SITVEI" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_PLAVEI" , "C" , 10 , 0 })
aadd(aVetCampos,{ "TRB_ANOMOD" , "C" , 8  , 0 })
aadd(aVetCampos,{ "TRB_DEPTO " , "C" , 2  , 0 })
aadd(aVetCampos,{ "TRB_NFSAI " , "C" , 9  , 0 })
aadd(aVetCampos,{ "TRB_MODVEI" , "C" , 30 , 0 })
aadd(aVetCampos,{ "TRB_POSIPI" , "C" , 8 , 0 })
aadd(aVetCampos,{ "TRB_DISEIX" , "N" , 6 , 0 })

If lMultMoeda // Trabalha com Multimoeda
	aadd(aVetCampos,{ "TRB_MOEDA"  , "N" , 2 , 0 }) // Moeda utilizada na movimentação
EndIf

oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetCampos
If lc_depto
	oObjTempTable:AddIndex(, {"TRB_TIPOVV","TRB_SITVEI","TRB_PROVVV","TRB_DEPTO","TRB_MODELO","TRB_CORVEI","TRB_CHASSI"} )
Else
	oObjTempTable:AddIndex(, {"TRB_TIPOVV","TRB_SITVEI","TRB_PROVVV","TRB_MODELO","TRB_CORVEI","TRB_CHASSI"} )
EndIf
oObjTempTable:CreateTable()

dbSelectArea("VVF")
dbSetOrder(1)

dbSelectArea("VVG")
dbSetOrder(1)

dbSelectArea("VV1")
dbSetOrder(1)

dbSelectArea("VV2")
dbSetOrder(1)

dbSelectArea("VVH")
dbSetOrder(1)

If len(aSM0) > 0

	aVVFConc := {	"VVF_DATMOV" ,;
					cSQLSubs + "(VVF_DTHEMI,7,2)" ,;
					cSQLSubs + "(VVF_DTHEMI,4,2)" ,;
					cSQLSubs + "(VVF_DTHEMI,1,2)" ,;
					cSQLSubs + "(VVF_DTHEMI,10,2)",;
					cSQLSubs + "(VVF_DTHEMI,13,2)",;
					cSQLSubs + "(VVF_DTHEMI,16,2)",;
					"VVF_TRACPA" }
	cVVFConc := oSql:Concat(aVVFConc)

	aVV0Conc := {	"VV0_DATMOV" ,;
					cSQLSubs + "(VV0_DTHEMI,7,2)" ,;
					cSQLSubs + "(VV0_DTHEMI,4,2)" ,;
					cSQLSubs + "(VV0_DTHEMI,1,2)" ,;
					cSQLSubs + "(VV0_DTHEMI,10,2)",;
					cSQLSubs + "(VV0_DTHEMI,13,2)",;
					cSQLSubs + "(VV0_DTHEMI,16,2)",;
					"VV0_NUMTRA" }
	cVV0Conc := oSql:Concat(aVV0Conc)

	ProcRegua(Len(aSM0))

	For nCont := 1 to Len(aSM0)
		
		IncProc()
		
		cFilAnt := aSM0[nCont]
		
		If !(cFilAnt >= Mv_Par01 .and. cFilAnt <= Mv_Par02)
			loop
		Endif
		
		cFilVV1 := xFilial("VV1")
		cFilVV2 := xFilial("VV2")
		cFilVVH := xFilial("VVH")
		cFilVVC := xFilial("VVC")
		cFilVV0 := xFilial("VV0")
		cFilVVF := xFilial("VVF")
		cFilSF4 := xFilial("SF4")
		cFilSA2 := xFilial("SA2")
		cFilSA1 := xFilial("SA1")		
		cFilVVP := xFilial("VVP")
		cFilSB1 := xFilial("SB1")
		cFilSB2 := xFilial("SB2")
		
		cSQL := "SELECT CASE WHEN TENTRADA.CHAINT IS NOT NULL THEN TENTRADA.CHAINT"
		cSQL +=            " ELSE TSAIDA.CHAINT"
		cSQL +=        " END CHAINT,"
		cSQL +=        " TENTRADA.VVF_DATMOV, TENTRADA.VVF_OPEMOV, TENTRADA.VVF_TRACPA, TENTRADA.VVG_CODTES, TENTRADA.VVF_DTHEMI,"
		cSQL +=        " TSAIDA.VV0_DATMOV, TSAIDA.VV0_OPEMOV, TSAIDA.VV0_NUMTRA, TSAIDA.VVA_CODTES, TSAIDA.VV0_DTHEMI, TSAIDA.VV0_DEPTO, TSAIDA.VV0_NUMNFI"
		cSQL += " FROM ( SELECT TENTTMP.CHAINT, VVF2.VVF_DATMOV, VVF2.VVF_OPEMOV, VVF2.VVF_TRACPA, VVG2.VVG_CODTES, VVF2.VVF_DTHEMI, VVG2.VVG_ESTVEI"
		cSQL += " FROM ( SELECT VVG_CHAINT CHAINT , MAX("+cVVFConc+") VVFTMP"
		cSQL += " FROM "+cNamVVF+" VVF "
		cSQL += " JOIN "+cNamVVG+" VVG ON ( VVG_FILIAL=VVF_FILIAL AND VVG_TRACPA=VVF_TRACPA AND VVG.D_E_L_E_T_=' ' ) "
		cSQL += " JOIN "+cNamSF4+" F4 ON ( F4.F4_FILIAL='"+cFilSF4+"' AND F4.F4_CODIGO=VVG.VVG_CODTES AND "  // Somente TES que movimenta estoque
		if mv_par06 == 1
			cSQL += " F4.F4_ESTOQUE='S' AND "
		Elseif mv_par06 == 2
			cSQL += " F4.F4_ESTOQUE='N' AND "
		Endif	
		cSQL += " F4.D_E_L_E_T_=' ') "  
		if !Empty(MV_PAR03)
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVG_CHAINT AND VV1_CODMAR='"+MV_PAR03+"' "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) " 
		Elseif MV_PAR07 <> 3
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVG_CHAINT "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		endif
		cSQL +=                  " WHERE "
		cSQL +=                    " VVF_FILIAL = '"+cFilVVF+"' AND "
		cSQL +=                    " VVF_OPEMOV IN ('0','1','2','3','4','5','7','8') "
		cSQL +=                    " AND VVF_DATMOV <= '"+DtoS(mv_par04)+"'"
		cSQL +=                    " AND VVF_SITNFI <> '0'"
		cSQL +=                    " AND VVF.D_E_L_E_T_ = ' '"
		cSQL +=                  " GROUP BY VVG_CHAINT ) TENTTMP"
		cSQL +=                 " JOIN "+cNamVVF+" VVF2 ON VVF2.VVF_FILIAL = '"+cFilVVF+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                             " AND VVF2.VVF_TRACPA = SUBSTRING(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		else
			cSQL +=                             " AND VVF2.VVF_TRACPA = SUBSTR(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		endif
		cSQL +=                                 " AND VVF2.D_E_L_E_T_ = ' '"
		cSQL +=                 " JOIN "+cNamVVG+" VVG2 ON VVG2.VVG_FILIAL = '"+cFilVVF+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                             " AND VVG2.VVG_TRACPA = SUBSTRING(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		else
			cSQL +=                             " AND VVG2.VVG_TRACPA = SUBSTR(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		endif
		cSQL +=                                 " AND VVG2.VVG_CHAINT = TENTTMP.CHAINT "
		cSQL +=                                 " AND VVG2.D_E_L_E_T_ = ' '"
		cSQL +=        " ) TENTRADA"
		cSQL +=        " FULL JOIN"
		cSQL +=        " ( SELECT TSAITMP.CHAINT, VV02.VV0_DATMOV, VV02.VV0_OPEMOV, VV02.VV0_NUMTRA, VVA2.VVA_CODTES, VV02.VV0_DTHEMI, VV02.VV0_DEPTO, VV02.VV0_NUMNFI "
		cSQL += " FROM ( SELECT VVA_CHAINT CHAINT, MAX("+cVV0Conc+") VV0TMP"
		cSQL += " FROM "+cNamVV0+" VV0 "
		cSQL += " JOIN "+cNamVVA+" VVA ON ( VVA_FILIAL=VV0_FILIAL AND VVA_NUMTRA=VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cSQL += " JOIN "+cNamSF4+" F4 ON ( F4.F4_FILIAL='"+cFilSF4+"' AND F4.F4_CODIGO=VVA.VVA_CODTES AND "  // Somente TES que movimenta estoque
		if mv_par06 == 1
			cSQL += " F4.F4_ESTOQUE='S' AND "
		Elseif mv_par06 == 2
			cSQL += " F4.F4_ESTOQUE='N' AND "
		Endif	                  
		cSQL += " F4.D_E_L_E_T_=' ') "  
		if !Empty(MV_PAR03)
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVA_CHAINT AND VV1_CODMAR='"+MV_PAR03+"' "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		Elseif MV_PAR07 <> 3
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVA_CHAINT " 
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		Endif
		cSQL +=  " WHERE "
		cSQL +=  " VV0_FILIAL = '"+cFilVV0+"' AND"
		cSQL +=  " VV0_OPEMOV IN ('0','2','3','4','5','6','7')"
		cSQL +=  " AND VV0_DATMOV <= '"+DtoS(mv_par04)+"'"
		cSQL +=  " AND VV0_SITNFI <> '0'"
		cSQL +=  " AND VV0_NUMNFI <> ' '"
		cSQL +=  " AND VV0.D_E_L_E_T_ = ' '"
		cSQL +=  " GROUP BY VVA_CHAINT ) TSAITMP"
		cSQL +=  " JOIN "+cNamVV0+" VV02 ON VV02.VV0_FILIAL = '"+cFilVV0+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                               " AND VV02.VV0_NUMTRA = SUBSTRING(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		else
			cSQL +=                               " AND VV02.VV0_NUMTRA = SUBSTR(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		endif
		cSQL +=                                   " AND VV02.D_E_L_E_T_ = ' '"
		cSQL +=                   " JOIN "+cNamVVA+" VVA2 ON VVA2.VVA_FILIAL = '"+cFilVV0+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                               " AND VVA2.VVA_NUMTRA = SUBSTRING(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		else
			cSQL +=                               " AND VVA2.VVA_NUMTRA = SUBSTR(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		endif
		cSQL +=                                  " AND VVA2.VVA_CHAINT = TSAITMP.CHAINT "
		cSQL +=                                  " AND VVA2.D_E_L_E_T_ = ' '"
		cSQL +=        " ) TSAIDA"
		cSQL += " ON TENTRADA.CHAINT = TSAIDA.CHAINT"
		// Filtro por Estado do Veiculo
		if mv_par05 == 1 		// Veiculos Novos
			cSQL += " WHERE TENTRADA.VVG_ESTVEI = '0'"
			// Filtro por Estado do Veiculo
		Elseif mv_par05 == 2	// Veiculos Usados
			cSQL += " WHERE TENTRADA.VVG_ESTVEI = '1'"
		endif
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasTMP, .T., .T. )
		
		cCHAINT := ""
		
		dbSelectArea(cAliasTMP)
		dbGoTop()
		
		while !Eof()

			If (cAliasTMP)->VV0_DATMOV > (cAliasTMP)->VVF_DATMOV .or. ( (cAliasTMP)->VV0_DATMOV == (cAliasTMP)->VVF_DATMOV .and. AllTrim((cAliasTMP)->VV0_DTHEMI) > AllTrim((cAliasTMP)->VVF_DTHEMI))
				// Veiculo não esta no estoque
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			ENDIF
			
			If cCHAINT <> (cAliasTMP)->CHAINT
				cCHAINT := (cAliasTMP)->CHAINT
			Else
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			EndIf
			
			If !VV1->(dbSeek(cFilVV1+(cAliasTMP)->CHAINT))
				If Len(aReturn[7]) == 0
					MsgAlert(STR0063+" '"+(cAliasTMP)->CHAINT+"' "+STR0064,STR0062) // ChaInt 'XXXXXX' não encontrado no Cadastro de Veículos! / Atencao
				EndIf	
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			endif
			
			// Controla o Status do veiculo ...
			cTRB_SITVEI := ""
			
			c_ptodep := "**"
			c_nfsda  := space(9)
			
			// Houve saida dentro do periodo
			IF !Empty((cAliasTMP)->VV0_NUMTRA)
				
				cHoraEnt := AllTrim(Right((cAliasTMP)->VVF_DTHEMI,Len((cAliasTMP)->VVF_DTHEMI)-9))
				cHoraSai := AllTrim(Right((cAliasTMP)->VV0_DTHEMI,Len((cAliasTMP)->VV0_DTHEMI)-9))
				
				// Verifica se a ultima transacao foi de entrada ou saida
				// Se for a mesma data, verifica pela hora da transacao
				// Se a ultima for de saida, deve verificar qual foi o tipo da movimentacao
				IF ( (cAliasTMP)->VVF_DATMOV == (cAliasTMP)->VV0_DATMOV .and. cHoraSai > cHoraEnt) ;
					.or. (cAliasTMP)->VV0_DATMOV > (cAliasTMP)->VVF_DATMOV
					
					// Se for Saida por Remessa ou Consignacao , verifica se é uma remessa em poder de terceiro
					IF (cAliasTMP)->VV0_OPEMOV $ "3,5"
						// Se não for uma TES de remessa com controle de 3º, veiculo nao esta mais no estoque
						cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVA_CODTES+"' AND D_E_L_E_T_=' '")
						IF cPoder3 == "R"
							IF (cAliasTMP)->VV0_OPEMOV == "3"
								cTRB_SITVEI = "7" // Remessa de Propria em Poder de Terceiro
								
								if lc_depto
									c_ptodep := if(!empty((cAliasTMP)->VV0_DEPTO),(cAliasTMP)->VV0_DEPTO,"**")
									c_nfsda := (cAliasTMP)->VV0_NUMNFI
								endif
							ELSEIF  (cAliasTMP)->VV0_OPEMOV == "5"
								cTRB_SITVEI = "4" // Consignado
							ENDIF
						ELSE
							// Veiculo não esta no estoque
							dbSelectArea(cAliasTMP)
							dbSkip()
							Loop
						ENDIF
						// Veiculo não esta no estoque
					ELSE
						dbSelectArea(cAliasTMP)
						dbSkip()
						Loop
					ENDIF
				ENDIF
			ENDIF
			
			If ExistBlock("VVC060PE")
				lRet := ExecBlock("VVC060PE",.f.,.f.)
				If !lRet
					dbSelectArea(cAliasTMP)
					dbSkip()
					Loop
				Endif
			Endif
			
			// Se nao tiver em branco, se trata de uma remessa propria para terceiros e ja foi encontrado o STATUS do veiculo
			IF Empty(cTRB_SITVEI)
				
				// Mov. de Entrada Normal, Devolucao, Retorno de Remessa ou Retorno de Consig.
				if (cAliasTMP)->VVF_OPEMOV $ "0,5"
					cTRB_SITVEI := "0" // Estoque
					
					// Mov. de Entrada por Remessa ou Consignacao
				elseif (cAliasTMP)->VVF_OPEMOV $ "2,4"
					// Verifica se a TES é uma [R]emessa de poder de Terceiros
					cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVG_CODTES+"' AND D_E_L_E_T_=' '")
					IF cPoder3 == "R"
						IF (cAliasTMP)->VVF_OPEMOV == "2"
							cTRB_SITVEI := "3" // Remessa de Terceiro em Nosso Poder
						ELSEIF (cAliasTMP)->VVF_OPEMOV == "4"
							cTRB_SITVEI := "4" // Consignado
						ENDIF
					ENDIF
					
					// Mov. de Entrada por Transferencia
				elseif (cAliasTMP)->VVF_OPEMOV == "3"
					cTRB_SITVEI := "5" // Transferido
					
					// Mov. de Entrada por Retorno de Remessa e Retorno de Consignacao
				elseif (cAliasTMP)->VVF_OPEMOV $ "7,8"
					// Verifica se a TES é uma [D]emessa de poder de Terceiros
					cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVG_CODTES+"' AND D_E_L_E_T_=' '")
					IF cPoder3 == "D"
						cTRB_SITVEI := "0" // Estoque
					Else
						DBSelectArea("SB1")
						DBSetOrder(7)
						MsSeek(cFilSB1+cGruVei+VV1->VV1_CHAINT)
						If FM_SQL("SELECT R_E_C_N_O_ FROM "+cNamSB2+" WHERE B2_FILIAL='"+cFilSB2+"' AND B2_COD='"+SB1->B1_COD+"' AND B2_QATU>0  AND D_E_L_E_T_=' '") > 0
							cTRB_SITVEI := "0" // Estoque
						EndIf
					ENDIF
				endif
				//
				
			ENDIF
			
			// Veiculo nao esta no estoque
			if Empty(cTRB_SITVEI)
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			endif
			
			VVF->(MsSeek(cFilVVF+(cAliasTMP)->VVF_TRACPA))
			VVG->(MsSeek(cFilVVF+(cAliasTMP)->VVF_TRACPA+VV1->VV1_CHAINT))
			VV2->(MsSeek(cFilVV2+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			
			nValTab := 0
			if "DB2" $ cSGBD
				cSQL := "SELECT VVP_VALTAB "
			elseif "ORACLE" $ cSGBD
				cSQL := "SELECT * FROM ( SELECT VVP_VALTAB "
			else
				cSQL := "SELECT TOP 1 VVP_VALTAB "
			endif
			cSQL += " FROM "+cNamVVP+" VVP"
			cSQL += " WHERE "
			cSQL += "VVP.VVP_FILIAL='"+cFilVVP+"' AND"
			cSQL += " VVP.VVP_CODMAR = '"+VV1->VV1_CODMAR+"'"
			cSQL += " AND VVP.VVP_MODVEI = '"+VV1->VV1_MODVEI+"'"
			cSQL += " AND VVP.VVP_SEGMOD = '"+VV2->VV2_SEGMOD+"'"
			cSQL += " AND VVP.VVP_DATPRC >= '" + DtoS(MV_PAR04) + "'"
			cSQL += " AND VVP.D_E_L_E_T_ = ' '"
			cSQL += " ORDER BY VVP_DATPRC"
			if "DB2" $ cSGBD
				cSQL += " FETCH FIRST 1 ROW ONLY"
			elseif "ORACLE" $ cSGBD
				cSQL += " ) WHERE ROWNUM <= 1"
			endif
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), "TVALTAB", .T., .T. )
			IF !TVALTAB->(Eof())
				nValtab := TVALTAB->VVP_VALTAB
			ENDIF
			TVALTAB->(dbCloseArea())
			
			cTipFat := VVG->VVG_ESTVEI
			
			
			if VVF->VVF_CLIFOR = "F"
				cFornece := FM_SQL("SELECT A2_NOME FROM "+cNamSA2+" WHERE A2_FILIAL='"+cFilSA2+"' AND A2_COD='"+VVF->VVF_CODFOR+"' AND A2_LOJA='"+VVF->VVF_LOJA+"' AND D_E_L_E_T_=' '")
			else
				cFornece := FM_SQL("SELECT A1_NOME FROM "+cNamSA1+" WHERE A1_FILIAL='"+cFilSA1+"' AND A1_COD='"+VVF->VVF_CODFOR+"' AND A1_LOJA='"+VVF->VVF_LOJA+"' AND D_E_L_E_T_=' '")			
			endif
			
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			
			DBSelectArea("SB2")
			DBSetOrder(1)
			MsSeek(cFilSB2+SB1->B1_COD+VV1->VV1_LOCPAD)
			
			DbSelectArea("TRB")
			RecLock("TRB",.t.)
			TRB_FILIAL := VV1->VV1_FILENT
			TRB_FILENT := VVF->VVF_FILIAL
			TRB_TIPOVV := VVG->VVG_ESTVEI
			TRB_PROVVV := if(left(VV1->VV1_PROVEI,1)$"0,3,4,5,8","0","1") //0-nacional, 1-importado
			TRB_DIAEST := mv_par04-VVF->VVF_DATMOV
			TRB_NUMNFI := VVF->VVF_NUMNFI
			TRB_DATEMI := VVF->VVF_DATEMI
			TRB_FORNEC := cFornece
			TRB_DTDIGI := VVF->VVF_DATMOV
			TRB_MODELO := VV1->VV1_CODMAR+" "+Left(VV2->VV2_DESMOD,20)
			TRB_MARMOD := VV1->VV1_CODMAR+" "+left(VV1->VV1_MODVEI,10)+"-"+Left(VV2->VV2_DESMOD,10)
			TRB_CHASSI := VV1->VV1_CHASSI
			TRB_CORVEI := left(FM_SQL("SELECT VVC_DESCRI FROM "+cNamVVC+" WHERE VVC_FILIAL='"+cFilVVC+"' AND VVC_CODMAR='"+VV1->VV1_CODMAR+"' AND VVC_CORVEI='"+VV1->VV1_CORVEI+"' AND D_E_L_E_T_=' '"),10)
			TRB_VALNFI := VVG->VVG_VALUNI+iif(cPaisLoc=="BRA",VVG->VVG_VALIPI,0)+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+iif(cPaisLoc=="BRA",VVG->VVG_ICMRET,0)  
			TRB_PICRET := iif(cPaisLoc=="BRA",VVG->VVG_PISENT,0)+VVG->VVG_COFENT
			TRB_VALFRE := VVG->VVG_VALFRE
			TRB_VALTAB := nValTab
			TRB_CODIND := VVG->VVG_CODIND
			TRB_DESIND := FM_SQL("SELECT VVH_DESCRI FROM "+cNamVVH+" WHERE VVH_FILIAL='"+cFilVVH+"' AND VVH_CODIND='"+VVG->VVG_CODIND+"' AND D_E_L_E_T_=' '")
			TRB_TIPFAT := cTipFat
			
			TRB_CUSTOV := SB2->B2_CM1
			TRB_CUSATU := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATMOV,dDataBase)+FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATMOV,dDataBase,"V")
			TRB_SITVEI := cTRB_SITVEI
			TRB_PLAVEI := VV1->VV1_PLAVEI
			TRB_MODVEI := VV1->VV1_MODVEI
			TRB_ANOMOD := VV1->VV1_FABMOD
			TRB_POSIPI := VV1->VV1_POSIPI
			TRB_DISEIX := VV1->VV1_DISEIX
			TRB_DEPTO  := c_ptodep
			TRB_NFSAI  := c_NFSda
			If lMultMoeda // Trabalha com Multimoeda
				TRB_MOEDA  := VVF->VVF_MOEDA // Moeda utilizada na movimentação
			EndIf
			MsUnlock()
			DbSelectArea(cAliasTMP)
			DbSkip()

			nRegistros++ // Total de registros do arquivo temporário

		Enddo
		
		(cAliasTMP)->(dbCloseArea())
		
	Next
	
Endif

Return(nRegistros) // Total de registros do arquivo temporário
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600029_ReportDef
Prepara o Relatório
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param cPerg, character, Pergunte do Relatório
@return object, Objeto report.
/*/
Static Function VC0600029_ReportDef(cPerg)
Local oReport
Local oSection

Local cReport   :=cPerg
Local cTitle    :=OemToAnsi(STR0001) // Estoque de Veiculos
Local uParam    :=cPerg
Local bAction   :={|oReport| VC0600039_PrintReport(oReport, cTitle)}
Local cDescripti:=cTitle

Local cMaskVal := If(cPaisLoc == "BRA", "@E 99,999,999.99", "@E 999,999,999,999.99")
Local cMaskFre := If(cPaisLoc == "BRA", "@E 999,999.99"   , "@E 999,999,999,999.99")
Local cMaskCus := If(cPaisLoc == "BRA", "@E 99999,999.99" , "@E 999,999,999,999.99")

Pergunte(cPerg,.f.)

oReport := TReport():New(cReport,cTitle,uParam,bAction,cDescripti)
oReport:SetTotalInLine(.F.)
oReport:SetLandScape(.T.)

oSection := TRSection():New(oReport,cTitle,"TRB")
TRCell():New(oSection, "TRB_DIAEST", "TRB", STR0022          , "99999" ,05           ,,,"RIGHT",,"RIGHT",,,.F.) // "Dias"
TRCell():New(oSection, "TRB_FILIAL", "TRB", Subs(STR0075,1,6), "@X"    ,06                                    ) // "FilialAtu"
TRCell():New(oSection, "TRB_FILENT", "TRB", Subs(STR0076,1,6), "@X"    ,06                                    ) // "FilCompra"
TRCell():New(oSection, "TRB_NUMNFI", "TRB", STR0024          , "@X"    ,09                                    ) // "NF"
TRCell():New(oSection, "TRB_DTDIGI", "TRB", STR0077          , "@D"    ,10                                    ) // "Digitação"
TRCell():New(oSection, "TRB_DATEMI", "TRB", STR0025          , "@D"    ,10                                    ) // "Emissão"
TRCell():New(oSection, "TRB_FORNEC", "TRB", STR0078          , "@X"    ,10                                    ) // "Fornecedor"
TRCell():New(oSection, "TRB_MARMOD", "TRB", STR0079          , "@X"    ,25                                    ) // "Marca / Modelo"
TRCell():New(oSection, "TRB_ANOMOD", "TRB", STR0080          , "@X"    ,04                                    ) // "Ano"
TRCell():New(oSection, "TRB_CHASSI", "TRB", STR0028          , "@X"    ,21                                    ) // "Chassi"
TRCell():New(oSection, "TRB_CORVEI", "TRB", STR0029          , "@X"    ,10                                    ) // "Cor"

If lMultMoeda // Trabalha com Multimoeda
	TRCell():New(oSection, "TRB_MOEDAV", "TRB", STR0085          , "@X"    ,03                                    ) // "$"
EndIf

TRCell():New(oSection, "TRB_VALNFI", "TRB", STR0081          , cMaskVal,Len(cMaskVal),,,"RIGHT",,"RIGHT",,,.F.) // "Vlr Unitário"

If cPaisLoc == "BRA"
	TRCell():New(oSection, "TRB_VALFRE", "TRB", STR0033          , cMaskFre,Len(cMaskFre),,,"RIGHT",,"RIGHT",,,.F.) // "Frete"
EndIf

If lMultMoeda // Trabalha com Multimoeda
	TRCell():New(oSection, "TRB_MOEDAC", "TRB", STR0085          , "@X"    ,03                                    ) // "$"
EndIf

TRCell():New(oSection, "TRB_CUSTOV", "TRB", STR0034          , cMaskCus,Len(cMaskCus),,,"RIGHT",,"RIGHT",,,.F.) // "s/Correção"

If cPaisLoc == "BRA"
	TRCell():New(oSection, "TRB_CUSATU", "TRB", STR0035          , cMaskCus,Len(cMaskCus),,,"RIGHT",,"RIGHT",,,.F.) // "c/Correção"
EndIf

TRCell():New(oSection, "TRB_CODIND", "TRB", STR0082          , "@X"    ,09                                    ) // "Ind.Correção"
TRCell():New(oSection, "XXX_SITVEI", "TRB", STR0040          , "@X"    ,08                                    ) // "Situac"
TRCell():New(oSection, "TRB_PLAVEI", "TRB", STR0041          , "@X"    ,12                                    ) // "Placa"
TRCell():New(oSection, "TRB_POSIPI", "TRB", STR0083          , "@X"    ,08                                    ) // "ClaFis"
TRCell():New(oSection, "TRB_DISEIX", "TRB", STR0084          , "@X"    ,07           ,,,"RIGHT",,"RIGHT",,,.F.) // "Eixos"

oSection:SetTotalInLine(.F.)

Return oReport
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600039_PrintReport
Chama a rotina de impressão do Relatório
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param oReport, object, Objeto report.
@param cTitle, character, Título do relatório
/*/
Static Function VC0600039_PrintReport(oReport, cTitle)
Local nRegistros := 0 // Total de registros do arquivo temporário

Private oObjTempTable // Utilizado na criação do arquivo temporário

Processa( { || nRegistros := Imp_VEIVC060() } , cTitle ) // Cria o arquivo temporário

VC0600049_Print(oReport, nRegistros, cTitle) // Efetua a impressão do Relatório

oObjTempTable:CloseTable()
FreeObj(oObjTempTable)

Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600049_Print
Efetua a impressão do Relatório
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param oReport, object, Objeto report
@param nRegistros, numeric, Total de registros do arquivo temporário
@param cTitle, character, Nome do relatório
/*/
Static Function VC0600049_Print(oReport, nRegistros, cTitle) // Efetua a impressão do Relatório
Local aArea     := GetArea()
Local oSection  := oReport:Section(1)

Local aSimbMoeda := {} // Simbolos das Moedas
Local nQtdMoedas := MoedFin() // Retorna a Quantidade de Moedas Utilizadas
Local nMoeda     := 0
Local nPos       := 0
Local cAnoMod    := ""
Local cMoedaV    := ""
Local cMoedaC    := ""
Local cCodInd    := ""
Local cPlaVei    := ""
Local cPosIpi    := ""
Local cSitVei    := ""

Local nQuant     := 0
Local nValNfi    := 0
Local nCustoV    := 0
Local nValFre    := 0
Local nCusAtu    := 0

Local aTotGer    := {}
Local aTotTip    := {}
Local aTotSit    := {}
Local aTotPro    := {}
Local cTipAnt    := ""
Local cSitAnt    := ""
Local cProAnt    := ""
Local cTextoAux  := ""

Local nSeq       := 0
Local nTotGer    := 0

If lMultMoeda // Trabalha com MULTMOEDA
	For nPos := 1 to nQtdMoedas
		aAdd(aSimbMoeda,PadR(GETMV("MV_SIMB"+Alltrim(str(nPos))),4)) // Simbolos das Moedas
	Next
Else
	aAdd(aSimbMoeda,PadR("",4)) // Simbolos das Moedas
EndIf

oReport:SetMeter(nRegistros) // Total de registros do arquivo temporário

oReport:SetTitle(OemToAnsi(cTitle)) // Estoque de Veiculos

oSection:Init()

TRB->(dbGoTop())

aTotGer := VC0600059_ZeraTotais(lMultMoeda, nQtdMoedas) // Zera o array com os totais
nTotGer := 0
While TRB->(!Eof())
	aTotTip := VC0600059_ZeraTotais(lMultMoeda, nQtdMoedas) // Zera o array com os totais
	cTipAnt := TRB->TRB_TIPOVV

	cTipVei := VC0600069_Descricao("cTipVei", cTipAnt) // Retorna a descrição de acordo com o tipo informado

	While TRB->(!Eof() .and. TRB_TIPOVV == cTipAnt) // 0=Novo,1=Usado
		aTotSit := VC0600059_ZeraTotais(lMultMoeda, nQtdMoedas) // Zera o array com os totais
		cSitAnt := TRB->TRB_SITVEI

		cSitVei := VC0600069_Descricao("cSitVei", cSitAnt) // Retorna a descrição de acordo com o tipo informado

		While TRB->(!Eof() .and. TRB_TIPOVV + TRB_SITVEI == cTipAnt + cSitAnt) // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
			aTotPro := VC0600059_ZeraTotais(lMultMoeda, nQtdMoedas) // Zera o array com os totais
			cProAnt := TRB->TRB_PROVVV

			nSeq := 0
			While TRB->(!Eof() .and. TRB_TIPOVV + TRB_SITVEI + TRB_PROVVV == cTipAnt + cSitAnt + cProAnt) // 0=Nacional,1=Importado
				oReport:IncMeter()

				nMoeda := 1 // Moeda utilizada na movimentação
				If lMultMoeda // Trabalha com Multimoeda
					nMoeda  := TRB->( If(TRB_MOEDA >= 1 .and. TRB_MOEDA <= Len(aSimbMoeda), TRB_MOEDA, 1) ) // Moeda utilizada na movimentação
					cMoedaV := aSimbMoeda[nMoeda]
					cMoedaC := aSimbMoeda[1]
				EndIf

				cAnoMod := substr(TRB->TRB_ANOMOD,5,4)
				cCodInd := TRB->TRB_CODIND + "-" + substr(TRB->TRB_DESIND,1,06)
				cPlaVei := Trans(TRB->TRB_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI")))
				cPosIpi := left(TRB->TRB_POSIPI,8)

				aTotGer[nMoeda,1]++
				aTotGer[nMoeda,2] += TRB->TRB_VALNFI
				aTotGer[nMoeda,3] += TRB->TRB_CUSTOV
				aTotGer[nMoeda,4] += TRB->TRB_VALFRE
				aTotGer[nMoeda,5] += TRB->TRB_CUSATU

				aTotTip[nMoeda,1]++
				aTotTip[nMoeda,2] += TRB->TRB_VALNFI
				aTotTip[nMoeda,3] += TRB->TRB_CUSTOV
				aTotTip[nMoeda,4] += TRB->TRB_VALFRE
				aTotTip[nMoeda,5] += TRB->TRB_CUSATU

				aTotSit[nMoeda,1]++
				aTotSit[nMoeda,2] += TRB->TRB_VALNFI
				aTotSit[nMoeda,3] += TRB->TRB_CUSTOV
				aTotSit[nMoeda,4] += TRB->TRB_VALFRE
				aTotSit[nMoeda,5] += TRB->TRB_CUSATU

				aTotPro[nMoeda,1]++
				aTotPro[nMoeda,2] += TRB->TRB_VALNFI
				aTotPro[nMoeda,3] += TRB->TRB_CUSTOV
				aTotPro[nMoeda,4] += TRB->TRB_VALFRE
				aTotPro[nMoeda,5] += TRB->TRB_CUSATU

				nSeq++
				nTotGer++

				If nSeq == 1 // Primeira linha do bloco de impressão
					If nTotGer > 1 // Pula três linhas a partir do segundo bloco de impressão (primeiro bloco está junto do cabeçalho)
						oReport:SkipLine(3)
					EndIf
				EndIf

				oSection:Cell("TRB_DIAEST"):SetValue(TRB->TRB_DIAEST)
				oSection:Cell("TRB_FILIAL"):SetValue(TRB->TRB_FILIAL)
				oSection:Cell("TRB_FILENT"):SetValue(TRB->TRB_FILENT)
				oSection:Cell("TRB_NUMNFI"):SetValue(TRB->TRB_NUMNFI)
				oSection:Cell("TRB_DTDIGI"):SetValue(TRB->TRB_DTDIGI)
				oSection:Cell("TRB_DATEMI"):SetValue(TRB->TRB_DATEMI)
				oSection:Cell("TRB_FORNEC"):SetValue(TRB->TRB_FORNEC)
				oSection:Cell("TRB_MARMOD"):SetValue(TRB->TRB_MARMOD)
				oSection:Cell("TRB_ANOMOD"):SetValue(cAnoMod        )
				oSection:Cell("TRB_CHASSI"):SetValue(TRB->TRB_CHASSI)
				oSection:Cell("TRB_CORVEI"):SetValue(TRB->TRB_CORVEI)
				oSection:Cell("TRB_CODIND"):SetValue(cCodInd        )
				oSection:Cell("XXX_SITVEI"):SetValue(cSitVei        )
				oSection:Cell("TRB_PLAVEI"):SetValue(cPlaVei        )
				oSection:Cell("TRB_POSIPI"):SetValue(cPosIpi        )
				oSection:Cell("TRB_DISEIX"):SetValue(AllTrim(Trans(TRB->TRB_DISEIX,"@E 999,999")))

				oSection:Cell("TRB_VALNFI"):SetValue(TRB->TRB_VALNFI)
				oSection:Cell("TRB_CUSTOV"):SetValue(TRB->TRB_CUSTOV)

				If lMultMoeda // Trabalha com Multimoeda
					oSection:Cell("TRB_MOEDAV"):SetValue(cMoedaV        )
					oSection:Cell("TRB_MOEDAC"):SetValue(cMoedaC        )
				EndIf

				If cPaisLoc == "BRA"
					oSection:Cell("TRB_VALFRE"):SetValue(TRB->TRB_VALFRE)
					oSection:Cell("TRB_CUSATU"):SetValue(TRB->TRB_CUSATU)
				EndIf

				oSection:PrintLine()

				TRB->(dbSkip())
			End

			nSeq := 0
			cTextoAux := cTipVei + "   -   " + VC0600069_Descricao("cProAnt", cProAnt) // Retorna a descrição de acordo com o tipo informado
			For nPos := 1 to Len(aTotPro)
				If aTotPro[nPos,1] <> 0
					nQuant  := aTotPro[nPos,1]
					nValNfi := aTotPro[nPos,2]
					nCustoV := aTotPro[nPos,3]
					nValFre := aTotPro[nPos,4]
					nCusAtu := aTotPro[nPos,5]
					cMoedaV := aSimbMoeda[nPos]
					cMoedaC := aSimbMoeda[1]
					nSeq++
					VC0600079_ImprimeTotais(oReport, oSection, nSeq, cTextoAux, nQuant, nValNfi, nCustoV, nValFre, nCusAtu, cMoedaV, cMoedaC) // Imprime a linha com os totais
				EndIf
			Next
		End

		nSeq := 0
		cTextoAux := cTipVei + "   -   " + VC0600069_Descricao("cSitAnt", cSitAnt) // Retorna a descrição de acordo com o tipo informado
		For nPos := 1 to Len(aTotSit)
			If aTotSit[nPos,1] <> 0
				nQuant  := aTotSit[nPos,1]
				nValNfi := aTotSit[nPos,2]
				nCustoV := aTotSit[nPos,3]
				nValFre := aTotSit[nPos,4]
				nCusAtu := aTotSit[nPos,5]
				cMoedaV := aSimbMoeda[nPos]
				cMoedaC := aSimbMoeda[1]
				nSeq++
				VC0600079_ImprimeTotais(oReport, oSection, nSeq, cTextoAux, nQuant, nValNfi, nCustoV, nValFre, nCusAtu, cMoedaV, cMoedaC) // Imprime a linha com os totais
			EndIf
		Next
	End

	nSeq := 0
	cTextoAux := VC0600069_Descricao("cTipAnt", cTipAnt) // Retorna a descrição de acordo com o tipo informado
	For nPos := 1 to Len(aTotTip)
		If aTotTip[nPos,1] <> 0
			nQuant  := aTotTip[nPos,1]
			nValNfi := aTotTip[nPos,2]
			nCustoV := aTotTip[nPos,3]
			nValFre := aTotTip[nPos,4]
			nCusAtu := aTotTip[nPos,5]
			cMoedaV := aSimbMoeda[nPos]
			cMoedaC := aSimbMoeda[1]
			nSeq++
			VC0600079_ImprimeTotais(oReport, oSection, nSeq, cTextoAux, nQuant, nValNfi, nCustoV, nValFre, nCusAtu, cMoedaV, cMoedaC) // Imprime a linha com os totais
		EndIf
	Next
End

nSeq := 0
cTextoAux := VC0600069_Descricao("cTotGer", "") // Retorna a descrição de acordo com o tipo informado
For nPos := 1 to Len(aTotGer)
	If aTotGer[nPos,1] <> 0
		nQuant  := aTotGer[nPos,1]
		nValNfi := aTotGer[nPos,2]
		nCustoV := aTotGer[nPos,3]
		nValFre := aTotGer[nPos,4]
		nCusAtu := aTotGer[nPos,5]
		cMoedaV := aSimbMoeda[nPos]
		cMoedaC := aSimbMoeda[1]
		nSeq++
		VC0600079_ImprimeTotais(oReport, oSection, nSeq, cTextoAux, nQuant, nValNfi, nCustoV, nValFre, nCusAtu, cMoedaV, cMoedaC) // Imprime a linha com os totais
	EndIf
Next

oSection:Finish()

RestArea(aArea)
Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600059_ZeraTotais
Zera o array com os totais
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param lMultMoeda, logical, Se Trabalha com MULTMOEDA
@param nQtdMoedas, numeric, Quantidade de Moedas Utilizadas
@return array, Retorna o array com os totais zerados
/*/
Static Function VC0600059_ZeraTotais(lMultMoeda, nQtdMoedas) // Zera o array com os totais
Local nPos := 0
Local aRet := {}
nQtdMoedas := If(lMultMoeda, nQtdMoedas, 1) // Trabalha com MULTMOEDA
For nPos := 1 to nQtdMoedas
	aAdd(aRet, {0,0,0,0,0}) // nQuant,nValNFI,nCustoV,nValFre,nCustoAtu
Next
Return(aRet)
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600069_Descricao
Retorna a descrição de acordo com o tipo informado
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param cTipo, character, Tipo da descrição
@param cCodigo, character, Código da descrição
@return character, Retorna a descrição de acordo com o tipo informado
/*/
Static Function VC0600069_Descricao(cTipo, cCodigo) // Retorna a descrição de acordo com o tipo informado
Local cRet := "N/D"

Do Case
Case cTipo == "cTipVei"
	Do Case
	Case cCodigo == "0" // 0=Novo,1=Usado
		cRet := Upper(AllTrim(STR0065)) // "V E I C U L O S   N O V O S"
	Case cCodigo == "1" // 0=Novo,1=Usado
		cRet := Upper(AllTrim(STR0066)) // "V E I C U L O S   U S A D O S"
	EndCase
Case cTipo == "cSitVei" .or. cTipo == "cSitAnt"
	Do Case
	Case cCodigo = "0" // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
		cRet := Upper(AllTrim(STR0012)) // "Estoque"
	Case cCodigo = "3" // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
		cRet := Upper(AllTrim(STR0013)) // "Remessa "
	Case cCodigo = "4" // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
		cRet := Upper(AllTrim(STR0061)) // "Consignação"
	Case cCodigo = "5" // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
		cRet := Upper(AllTrim(STR0015)) // "Transfer"
	Case cCodigo = "7" // 0=Estoque,3=Remessa de Terceiro em Nosso Poder,4=Consignado,5=Transferido,7=Remessa Nossa em Poder de Terceiros
		cRet := Upper(AllTrim("R N P T"))
	EndCase
Case cTipo == "cProAnt"
	Do Case
	Case cCodigo == "0" // 0=Nacional,1=Importado
		cRet := Upper(AllTrim(STR0044)) // "   N a c i o n a i s"
	Case cCodigo == "1" // 0=Nacional,1=Importado
		cRet := Upper(AllTrim(STR0045)) // "   I m p o r t a d o s"
	EndCase
Case cTipo == "cTipAnt"
	Do Case
	Case cCodigo == "0" // 0=Novo,1=Usado
		cRet := Upper(AllTrim(STR0006)) + "   " + Upper(AllTrim(STR0065)) // "T O T A L   D E   "###"V E I C U L O S   N O V O S"
	Case cCodigo == "1" // 0=Novo,1=Usado
		cRet := Upper(AllTrim(STR0006)) + "   " + Upper(AllTrim(STR0066)) // "T O T A L   D E   "###"V E I C U L O S   U S A D O S"
	EndCase
Case cTipo == "cTotGer"
	cRet := Upper(AllTrim(STR0011)) // "T O T A L   G E R A L   D E   V E I C U L O S"
EndCase

Return(cRet)
//-----------------------------------------------------------------------------

/*/{Protheus.doc} VC0600079_ImprimeTotais
Imprime a linha com os totais
@type function
@version 1.0
@author João Carlos da Silva
@since 01/12/2025
@param oReport, object, Objeto Report
@param oSection, object, Objeto Section
@param nSeq, numeric, Sequência da impressão
@param cTextoAux, character, Título da Quebra
@param nQuant, numeric, Quantidade Total da Quebra
@param nValNfi, numeric, Valor Total da Quebra
@param nCustoV, numeric, Custo Total da Quebra
@param nValFre, numeric, Frete Total da Quebra
@param nCusAtu, numeric, Custo Atual Total da Quebra
@param cMoedaV, character, Moeda do Valor
@param cMoedaC, character, Moeda do Custo
/*/
Static Function VC0600079_ImprimeTotais(oReport, oSection, nSeq, cTextoAux, nQuant, nValNfi, nCustoV, nValFre, nCusAtu, cMoedaV, cMoedaC) // Imprime a linha com os totais

If nSeq == 1 // Na primeira vez, pula uma linha, imprime o título da quebra e a FatLine()
	oReport:SkipLine(1)
	oReport:PrintText(cTextoAux)
	oReport:FatLine()
EndIf

oSection:Cell("TRB_DIAEST"):SetValue("")
oSection:Cell("TRB_FILIAL"):SetValue("")
oSection:Cell("TRB_FILENT"):SetValue("")
oSection:Cell("TRB_NUMNFI"):SetValue("")
oSection:Cell("TRB_DTDIGI"):SetValue("")
oSection:Cell("TRB_DATEMI"):SetValue("")
oSection:Cell("TRB_FORNEC"):SetValue("")
oSection:Cell("TRB_MARMOD"):SetValue("")
oSection:Cell("TRB_ANOMOD"):SetValue("")
oSection:Cell("TRB_CORVEI"):SetValue("")
oSection:Cell("TRB_CODIND"):SetValue("")
oSection:Cell("XXX_SITVEI"):SetValue("")
oSection:Cell("TRB_PLAVEI"):SetValue("")
oSection:Cell("TRB_POSIPI"):SetValue("")
oSection:Cell("TRB_DISEIX"):SetValue("")

oSection:Cell("TRB_CHASSI"):SetValue(AllTrim(Trans(nQuant,"@E 999,999"))) // Utilizado para imprimir a quantidade
oSection:Cell("TRB_VALNFI"):SetValue(nValNfi)
oSection:Cell("TRB_CUSTOV"):SetValue(nCustoV)

If lMultMoeda // Trabalha com Multimoeda
	oSection:Cell("TRB_MOEDAV"):SetValue(cMoedaV)
	oSection:Cell("TRB_MOEDAC"):SetValue(cMoedaC)
EndIf

If cPaisLoc == "BRA"
	oSection:Cell("TRB_VALFRE"):SetValue(nValFre)
	oSection:Cell("TRB_CUSATU"):SetValue(nCusAtu)
EndIf

oSection:Cell("TRB_CHASSI"):SetAlign("RIGHT") // Utilizado para imprimir a quantidade

oSection:PrintLine()

oSection:Cell("TRB_CHASSI"):SetAlign("LEFT") // Utilizado para imprimir a quantidade

Return
//-----------------------------------------------------------------------------
