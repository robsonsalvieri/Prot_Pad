#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPRECAD.CH"
#DEFINE TCABC 1,1
#DEFINE TPRCRS 2,1
#DEFINE TPROC 3,1
#DEFINE DELTCABC 1,2
#DEFINE DELTRCRS 2,2
#DEFINE DELTPROC 3,2
#DEFINE EMPRESA 1
#DEFINE UNIDADE 2
#DEFINE FILIAL  3

Static __lApurBx

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFApRecAD
Rotinas de apuração de Recursos Recebidos/Repassados para Associação Desportiva 
Registros R-2030 e R-2040 da Reinf

@author Henrique Pereira; Anieli Rodrigues
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFApRecAD(cReg ,cPerApu,dtIni ,dtFin , cIdApReinf, aFil, oProcess, lValid, lSucesso)

	Local lProc As logical

	Default lSucesso := .F.
	
	lProc := oProcess <> nil

	If lProc
		oProcess:IncRegua2(STR0001 + cReg ) //"Processando apuração "
	EndIf
	TAFRecAd(cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lvalid, @lSucesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRecAd
Rotinas de apuração de Recursos Recebidos/Repassados para Associação Desportiva 
Registros R-2030 e R-2040 da Reinf
Contem a inteligencia de verificação de cada status do modelo, e toma a ação necessário de acordo com o status retornado

@author Henrique Pereira; Anieli Rodrigues
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFRecAd(cReg ,cPerApu,dtIni ,dtFin , cIdApReinf, aFil, oProcess, lValid, lSucesso )

	Local aInfoEUF		As Array
	Local aLog 			As Array
	Local aRegApur		As Array
	Local aAreaSM0 		As Array
	Local aMovs			As Array
	Local cPerApuGrv	As Character
	Local lDsarm		As Logical
	Local lProc			As Logical
	Local nContLog		As Numeric
	Local nContApur 	As Numeric 
	Local nTotReg		As Numeric
	Local nC1EArray		As Numeric
	Local nTamFil   	As Numeric

	aInfoEUF	:= {}
	aLog  		:= {}
	aRegApur	:= {}
	aMovs		:= {}
	aAreaSM0 	:= SM0->(GetArea())
	cPerApuGrv := cPerApu
	cPerApu 	:= SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
	lProc 		:= oProcess <> nil
	nContLog	:= 0
	nContApur	:= 0
	nTotReg	:= 0
	nC1EArray	:= ASCAN(aFil,{|x|x[7]})
	nTamFil		:= 0
	
	//CIE MATRIZ
	aInfoC1E := {}
	nTamFil := len( aFil )
	
	If nC1EArray > 0 
		AADD(aInfoC1E,aFil[nC1EArray][1])
		AADD(aInfoC1E,aFil[nC1EArray][4])
	elseif nTamFil > 0
		AADD(aInfoC1E,aFil[nTamFil][1])
		AADD(aInfoC1E,aFil[nTamFil][4])
	EndIf
 	
 	Default cPerApu	:= ""
 	
 	If !Empty(cPerApu)
		If lProc 
			oProcess:IncRegua2(STR0002) // "Selecionando dados a serem apurados"
		EndIf
		aInfoEUF:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
		aApurac	:= Apurac3040(cPerApu, cReg, aFil, aInfoEUF, @aMovs) 
		lExecApr 	:= aApurac[4]		
	EndIf 
	
	RestArea(aAreaSM0)
	
		If lExecApr
			
			(aApurac[TCABC])->(DbSetOrder(1))
			(aApurac[TCABC])->(DbEval({|| ++nTotReg }))
			(aApurac[TCABC])->(DbGoTop())
			
			DbSelectArea('C9B')
			C9B->(DbSetOrder(2))
			
			DbSelectArea('T9K')
			T9K->(DbSetOrder(2))
			
			If lProc
				oProcess:IncRegua2(STR0003) //"Gravando registros"
				oProcess:SetRegua2(nTotReg) 
			EndIf
			
			Begin Transaction
				While !(aApurac[TCABC])->(Eof())
				
					If cReg == 'R-2040'
						cNrInsc := (aApurac[TCABC])->CNRINSC
						cStatus := StatsReg(cReg, cPerApuGrv, "1", cNrInsc)
					Else
						cNrInsc := (aApurac[TCABC])->CNRINSC
						cStatus := 	StatsReg(cReg, cPerApuGrv, (aApurac[TCABC])->CTPINSC, cNrInsc)
					EndIf

					If lProc
						oProcess:IncRegua2(STR0004 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) //Gravando
					EndIf

					Do Case					
					//Alteração direta na base, e retono do T9K_STATUS / C9B_STATUS para branco
					Case cStatus $ ' |0|1|3|7'
		
						If ExcluiReg(cIdApReinf, cReg, @aLog)
							If cReg == 'R-2040'
								If !Grava2040(MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, /*T9K->T9K_VERANT*/, /*T9K->T9K_PROTPN*/, cIdApReinf, @aLog, T9K->T9K_ID, lValid, cStatus )
									lDsarm 		:= .T.
									lSucesso 	:= .F.
								else
									lSucesso 	:= .T.
								EndIf 
							Else
								If !Grava2030( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, /*C9B->C9B_VERANT*/, /*C9B->C9B_PROTPN*/, cIdApReinf, @aLog, C9B->C9B_ID, lValid, cStatus )
									lDsarm 		:= .T.
									lSucesso 	:= .F.
								else
									lSucesso 	:= .T.
								EndIf 
							EndIf 
						Else 
							lDsarm := .T.
							(aApurac[TCABC])->(DbSkip())
						EndIf						
						
					//Registro transmitido ao governão e sem retorno, não deve ser alaterado
					Case cStatus $ '2|6'
						cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
						
						If cReg == "R-2030"
							cErro 	+= "tpInscEstab: " + (aApurac[TCABC])->CTPINSC + CRLF
							cErro 	+= "nrInscEstab: " + cNrInsc + CRLF
							cErro  	+= "cnpjPrestador: " + (aApurac[TCABC])->CNPJORIGR + CRLF	
						Else 
							cErro 	+= "tpInscEstab: " + "1"
							cErro 	+= "nrInscEstab: " + cNrInsc + CRLF
							cErro  	+= "tpInscTomador: " +  (aApurac[TCABC])->CTPINSC + CRLF
							cErro  	+= "nrInscTomador: " +	(aApurac[TCABC])->CNPJORIGR + CRLF
						EndIf 
						
						cErro 	+= STR0006 + CRLF //"A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
						Aadd(aLog, {cReg, "ERRO", cErro})
						lDsarm := .T.
						(aApurac[TCABC])->(DbSkip())
		
					Case cStatus == '4'
						If cReg == 'R-2040'
							cVerAnt := T9K->T9K_VERSAO
							cProTpn := T9K->T9K_PROTUL

							FAltRegAnt( 'T9K', '2', .F. )
							If !Grava2040( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, T9K->T9K_ID, lValid, cStatus )
								lDsarm 		:= .T.
								lSucesso 	:= .F.
							else
								lSucesso 	:= .T.
							EndIf					 
						Else						
							cVerAnt := C9B->C9B_VERSAO
							cProTpn := C9B->C9B_PROTUL

							FAltRegAnt( 'C9B', '2', .F. )
							If !Grava2030( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, C9B->C9B_ID, lValid, cStatus )
								lDsarm 		:= .T.
								lSucesso 	:= .F.
							else
								lSucesso 	:= .T.
							EndIf
						EndIf
		
					Case cStatus == "Z" // Commit do modelo em modo de inclusão
						if Upper(cReg) == "R-2040"								
							if !Grava2040( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, , , cIdApReinf, @aLog,, lValid, cStatus )
								lDsarm 		:= .T.
								lSucesso 	:= .F.
							else
								lSucesso 	:= .T.
							EndIf
						else
							If !Grava2030( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, , , cIdApReinf, @aLog,, lValid, cStatus )
								lDsarm 		:= .T.
								lSucesso 	:= .F.
							else
								lSucesso 	:= .T.
							EndIf
						EndIf
					EndCase
				EndDo
				
				If lDsarm
					DisarmTransaction()
				Else 
					GravaId(aMovs,cIdApReinf)
				EndIf 
			End Transaction
			For nContLog := 1 to Len (aLog) 
				TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3] )
			Next nContLog	
			//Destruo as tabelas temporárias
			aApurac[DELTCABC]:Delete()
			aApurac[DELTRCRS]:Delete()
			aApurac[DELTPROC]:Delete()			
		Else
			//Alimenta aLog com Informação de que a Data Inicial está vazia
			TafXLog(cIdApReinf, cReg, "ALERTA", STR0007) //"Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
		EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QuryAprAD
Montagem da query para apuração dos recursos recebidos/repassados para Associação Desportiva
Registro R-2030/R-2040 da Reinf

@author Henrique Pereira; Anieli Rodrigues
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function QryApRecAd(cPerApu, lApur, lIdProc , aFil, cReg, lApi, aBind)

	Local aInfoEUF	as array
	Local aFilC20   as array
	Local cCompC1H	as Character
	Local cFiliais	as Character
	Local cQuery 	as Character
	Local cBd		as Character
	Local lFormat	as Logical
	Local cDataIni  as  Character
	Local cDataFim  as  Character

	Default lApi	:= .F.
	Default aBind	:= {}
	
	aInfoEUF := TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	aFilC20  := {}
	aBind    := {}
	cBd		 := TcGetDb()
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cFiliais := StrTran(StrTran(StrTran(TafRetFilC("C20", aFil),"(",""),")",""),"'","")
	cQuery	 := ""
	lFormat	 := .F.
	cDataIni := cPerApu + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

	aSize(aFilC20,0)
	aFilC20 := Separa( cFiliais, "," )

	SetalApurBx()

	cQuery	:= " SELECT "

	If !__lApurBx
		If lApur 
			cQuery	+= "  'NFS' AS ROTINA, C20.C20_FILIAL AS FIL, '0' AS ID, C20.C20_NUMDOC AS NUMDOCTO, ' ' AS PREFIX, C20.C20_CHVNF AS CHVNF, C1H.C1H_CNPJ AS CNPJORIREC,  C30.C30_TPREPA AS TPREPASSE, "
			cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_ID ELSE ?     END AS CIDEXTE, "
			cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_CODPAR ELSE ? END AS CCODPAR, "
			cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_NOME ELSE ?   END AS CDESPART, "
			cQuery	+= "  C30.C30_TOTAL VLRBRUTO, C35.C35_VALOR AS VLRRETAPUR, C20.R_E_C_N_O_ AS RECNO  "
			aAdd(aBind, Space(1))
			aadd(aBind, Space(1))
			aadd(aBind, '2')
			aadd(aBind, Space(1))
			aAdd(aBind, Space(1))
			aadd(aBind, Space(1))
			aadd(aBind, '2')
			aadd(aBind, Space(1))
			aAdd(aBind, Space(1))
			aadd(aBind, Space(1))
			aadd(aBind, '2')
			aadd(aBind, Space(1))
		Elseif lApi
			cQuery	+= "  COUNT(*) TOTAL, "
			cQuery	+= "  C20.C20_FILIAL AS FIL, "
			cQuery	+= "  C20.C20_CHVNF AS CHVNF "
		Else
			cQuery	+= "  COUNT(*) TOTAL "
		EndIf
				
		cQuery	+= " FROM " + RetSqlName("C20") + " C20"
		
		cQuery	+= " INNER JOIN " + RetSqlName("C30") + " C30 On C20.C20_FILIAL 	= C30.C30_FILIAL AND C30.D_E_L_E_T_ = ? AND C20.C20_CHVNF = C30.C30_CHVNF AND "
		cQuery	+= " C30.C30_TPREPA <> ? "
		cQuery	+= " INNER JOIN " + RetSqlName("C35") + " C35 On C30.C30_FILIAL 	= C35.C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND "
		cQuery	+= " C30.C30_NUMITE = C35.C35_NUMITE AND C35.C35_CODTRI = ? AND C35.D_E_L_E_T_ = ? "
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, '000013')
		aAdd(aBind, Space(1))
		
		cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND "
		
		If cReg == "R-2030"
			cQuery 	+= " C1H.C1H_PPES IN (?) AND "
			cQuery 	+= " (C1H.C1H_CNPJ <> ? OR (C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ?)) "
			aAdd(aBind, {'2','3'})
			aAdd(aBind, Space(1))
			aAdd(aBind, Space(1))
			aAdd(aBind, Space(1))
			aAdd(aBind, '2')
		ElseIf cReg == "R-2040"
			cQuery 	+= " C1H.C1H_PPES = ? AND C1H.C1H_CNPJ <> ? AND "
			cQuery 	+= " C1H.C1H_INDDES = ? "
			aAdd(aBind, '2')
			aAdd(aBind, Space(1))
			aAdd(aBind, '1')
		EndIf

		If cCompC1H == "EEE"
			cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
		Else
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
			EndIf
		EndIf
		
		cQuery	+= " AND C1H.D_E_L_E_T_ = ? "
		aAdd(aBind, Space(1))
		
		// Where
		cQuery	+= " WHERE C20.C20_FILIAL IN (?) AND C20.D_E_L_E_T_ = ? AND "
		aAdd(aBind, aFilC20)
		aAdd(aBind, Space(1))
		
		If !lApur // Consulta Status
			If lIdProc
				cQuery	+= " C20.C20_PROCID <> ? AND "
			Else
				cQuery	+= " C20.C20_PROCID = ? AND "
			EndIf	
			aAdd(aBind, Space(1)) 
		EndIf
		
		If cReg == "R-2030"	
			cQuery	+=  " C20.C20_INDOPE = ? AND "
			aAdd(aBind, '1')
		Else 
			cQuery	+=  " C20.C20_INDOPE = ? AND "
			aAdd(aBind, '0')
		EndIf

		cQuery += "C20.C20_CODSIT IN (?) AND "
		cQuery += " C20.C20_DTDOC BETWEEN ? AND ? "
		aAdd(aBind, {'000001','000002','000007','000008', '000009'})
		aAdd(aBind, cDataIni)
		aAdd(aBind, cDataFim)
		
		If lApi
			cQuery += " GROUP BY C20_FILIAL, C20_CHVNF "
		EndIf

		cQuery	+= " UNION ALL "
	EndIf	
	// Faturas

	If !__lApurBx
		cQuery	+= " SELECT "
	EndIf	
	If lApur 
		If __lApurBx
			cQuery	+= " T5P.T5P_VLPGTO VLPGTO, T5P.R_E_C_N_O_ RECNOT5P, "	
		EndIf	
		cQuery	+= "  'FAT' AS ROTINA, LEM.LEM_FILIAL AS FIL, LEM.LEM_ID AS ID, LEM.LEM_NUMERO AS NUMDOCTO, LEM.LEM_PREFIX AS PREFIX, LEM.LEM_NUMERO AS CHVNF, C1H.C1H_CNPJ AS CNPJORIREC, T5M.T5M_TPREPA AS TPREPASSE, "
		cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_ID     ELSE ? END AS CIDEXTE, "
		cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_CODPAR ELSE ? END AS CCODPAR, "
		cQuery  += "  CASE WHEN C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ? THEN C1H.C1H_NOME   ELSE ? END AS CDESPART, "
		cQuery	+= "  T5M.T5M_VLBRUT AS VLRBRUTO, T5M_VLREAP AS VLRRETAPUR, LEM.R_E_C_N_O_ AS RECNO "
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, '2')
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, '2')
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, '2')
		aAdd(aBind, Space(1))
	ElseIf lApi
		cQuery	+= "  COUNT(*) TOTAL,  "
		cQuery	+= " LEM.LEM_FILIAL AS FIL, "
		cQuery	+= " LEM.LEM_NUMERO AS CHVNF " 
	Else
		cQuery	+= " COUNT(*) TOTAL "
	EndIf
	
	cQuery	+= " FROM " + RetSqlName("LEM") + " LEM"
	
	cQuery	+= " INNER JOIN " + RetSqlName("T5M") + " T5M ON LEM.LEM_FILIAL = T5M.T5M_FILIAL AND T5M.D_E_L_E_T_ = ? AND T5M.T5M_ID = LEM.LEM_ID AND  "
	cQuery	+= " T5M.T5M_IDPART = LEM.LEM_IDPART AND T5M.T5M_TPREPA <> ? "
	aAdd(aBind, Space(1))
	aAdd(aBind, Space(1))
	If __lApurBx 
		cQuery	+= " INNER JOIN " + RetSqlName("T5P") + " T5P ON LEM.LEM_FILIAL = T5P.T5P_FILIAL AND T5P.D_E_L_E_T_ = ? AND T5P.T5P_ID = LEM.LEM_ID AND  "
		cQuery	+= " T5P.T5P_IDPART = LEM.LEM_IDPART "
		aAdd(aBind, Space(1))
	EndIf
	
	cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART "

	If cReg == "R-2030"
		cQuery 	+= " AND C1H.C1H_PPES IN (?) "
		cQuery 	+= " AND (C1H.C1H_CNPJ <> ? OR (C1H.C1H_CNPJ = ? AND C1H.C1H_PAISEX != ? AND C1H.C1H_PEEXTE = ?)) "
		aAdd(aBind, {'2','3'})
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))
		aAdd(aBind, '2')
	ElseIf cReg == "R-2040"
		cQuery 	+= " AND C1H.C1H_PPES = ? AND C1H.C1H_CNPJ <> ? "
		cQuery 	+= " AND C1H.C1H_INDDES = ? "
		aAdd(aBind, '2')
		aAdd(aBind, Space(1))
		aAdd(aBind, '1')
	EndIf

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
	Else
		If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
		EndIf
	EndIf
	
	// Where
	cQuery	+= " WHERE LEM.LEM_FILIAL IN (?) AND LEM.D_E_L_E_T_ = ? AND "
	cQuery	+= " LEM.LEM_DOCORI = ? AND "
	aAdd(aBind, aFilC20)
	aAdd(aBind, Space(1))
	aAdd(aBind, Space(1))

	If !lApur // Consulta Status

		If __lApurBx 
			If lIdProc
				cQuery	+= " T5P.T5P_PROCID <> ? AND "
			Else
				cQuery	+= " T5P.T5P_PROCID = ? AND "
			EndIf
		Else		
			If lIdProc
				cQuery	+= " LEM.LEM_PROCID <> ? AND "
			Else
				cQuery	+= " LEM.LEM_PROCID = ? AND "
			EndIf	
		EndIf
		aAdd(aBind, Space(1))
	EndIf
	
	If cReg == "R-2030"	
		cQuery	+=  " LEM.LEM_NATTIT = ? AND "
		aAdd(aBind, '1')
	Else 
		cQuery	+=  " LEM.LEM_NATTIT = ? AND "
		aAdd(aBind, '0')
	EndIf 
	
	If __lApurBx
		cQuery += " T5P.T5P_DTPGTO BETWEEN ? AND ? "
	Else
		cQuery += " LEM.LEM_DTEMIS BETWEEN ? AND ? "
	EndIf
	aAdd(aBind, cDataIni)
	aAdd(aBind, cDataFim)

	If lApi 
		cQuery += " GROUP BY LEM_FILIAL, LEM_NUMERO " 
		cQuery += " ORDER BY FIL "
	ElseIf lApur
		cQuery += " ORDER BY 2,3"
	EndIf 

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} Apurac3040
Montagem da query para apuração dos recursos recebidos/repassados para Associação Desportiva
Registro R-2030/R-2040 da Reinf
Executa a quary principal, esta que é montada por QryApRecAd()

@author Henrique Pereira; Anieli Rodrigues
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function Apurac3040(cPerApu,cReg, aFil, aInfoEUF, aMovs)

	Local oPrepare  as object
	Local aBind     as array		
	Local cAliasApr	as character	
	Local cQuery 	as character
	Local nI        as numeric

	oPrepare  := Nil
	aBind     := {}
	cAliasApr := GetNextAlias()
	cQuery    := QryApRecAd(cPerApu, .T., .F. , aFil, cReg, .F., @aBind)

	cQuery := ChangeQuery(cQuery)

	oPrepare := FwExecStatement():New(cQuery)

	For nI := 1 To Len(aBind)
		If Valtype(aBind[nI]) == 'A'
        	oPrepare:setIn(nI, aBind[nI])
    	Else
        	oPrepare:setString(nI, aBind[nI])
    	Endif
	Next nI

    oPrepare:OpenAlias(cAliasApr)
	
	aRegApur := RegPrinc(cAliasApr, cPerApu, cReg, aInfoEUF, @aMovs)

	freeObj(oPrepare)
		
Return aRegApur

//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author Henrique Pereira; Anieli Rodrigues
@since 03/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam

//-------------------------------------------------------------------
/*/{Protheus.doc} PopArray
Popula os 3 array com a estrutura das temporary tables

@author Henrique Pereira; Anieli Rodrigues
@since 03/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PopArray(aCampCabc, aCampRcrs, aCampProc)

	aCampCabc	:=  {{'ID'			,'C', 36 ,0},;
				    {'CPERIODO'		,'C', 06 ,0},;	//perApur
				    {'CTPINSC'		,'C', 01 ,0},; 	//tpInscEstab
				    {'CNRINSC'		,'C', 14 ,0},; 	//nrInscEstab	
				    {'CNPJORIGR'	,'C', 14 ,0},;	//cnpjOrigRecurso
				    {'CIDEXTE'      ,'C', 36 ,0},;	//ID Participante
                    {'CCODPAR'      ,'C', 60 ,0},;	//Código Participante
					{'CDESPART'     ,'C', 70 ,0},;	//Descrição Participante
				    {'VLRTOTAL'		,'N', 14 ,2},; 	//R-2030 vlrTotalRec	/ R-2040 vlrTotalRep
				    {'VLRTOTRET'	,'N', 14 ,2},; 	//vlrTotalRet
				    {'VLRTOTNRT'	,'N', 14 ,2}} 	//vlrTotalNRet
					  
	aCampRcrs	:=	{{'ID'			,'C', 36 ,0},;
					{'TPREPASSE'	,'C', 01 ,0},;	//tpRepasse
					{'CNPJORIGR'	,'C', 14 ,0},;	//cnpjOrigRecurso
					{'CIDEXTE'      ,'C', 36 ,0},;	//ID Participante			    
					{'DESCRECRS'	,'C', 20 ,0},; 	//descRecurso
					{'VLRBRUTO'		,'N', 14 ,2},; 	//vlrBruto	
					{'VLRRETAPR'	,'N', 14 ,2}}	//vlrRetApur

	aCampProc	:= {{'ID'			,'C', 36 ,0},;
					{'CTPPROC'		,'C', 01 ,0},; 	//tpProc
					{'NUMPRO'		,'C', 06 ,0},;
					{'C1GNUMPRO'	,'C', TamSx3("C1G_NUMPRO")[1] ,0},;	//nrProc
					{'CODSUS'		,'C', 14 ,0},; 	//codSusp
					{'CNPJORIGR'	,'C', 14 ,0},;	//cnpjOrigRecurso		
					{'CIDEXTE'      ,'C', 36 ,0},;	//ID Participante			    
					{'VLRNRET'		,'N', 14 ,2},; 	//vlrNRet	
					{'C1GID'		,'C', 06 ,0},;
					{'C1GVERSAO'	,'C', 14 ,0},;
					{'C1GFILIAL'	,'C', TamSx3("C1G_FILIAL")[1] ,0}}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Seta o indice das temporary table

@author Henrique Pereira; Anielle Rodrigues
@since 03/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopIdxObj(oTTCabc, oTTRcrs, oTTProc )

	oTTCabc:AddIndex("1", {"ID"})
	oTTCabc:AddIndex("2", {"CPERIODO", "CTPINSC", "CNRINSC", "CNPJORIGR", "CIDEXTE"})


	oTTRcrs:AddIndex("1", {"ID", "CNPJORIGR", "CIDEXTE"})
	oTTRcrs:AddIndex("2", {"ID", "TPREPASSE", "CNPJORIGR", "CIDEXTE"})

	oTTProc:AddIndex("1", {"ID", "CNPJORIGR", "CIDEXTE"})
	oTTProc:AddIndex("2", {"CTPPROC", "C1GNUMPRO", "CODSUS", "CNPJORIGR", "CIDEXTE", "ID"})

	oTTCabc:Create()
	oTTRcrs:Create()
	oTTProc:Create()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Rotinas de apuração de Recursos Repassados/ recebido para Associação Desportiva
Registros R-2030 e R-2040 da Reinf
Recebe o alias da query principal, cria e alimenta as temporary tables

@author Henrique Pereira; Anieli Rodrigues
@since 03/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RegPrinc( cAlias , cPeriod,  cReg, aInfoEUF, aMovs)

	Local aCampCabc		as Array
	Local aCampRcrs		as Array
	Local aCampProc		as Array	
	Local cCNPJTmPr		as Character		
	Local cChvReg		as Character
	Local cChvAnt       as Character   
	Local cTpInsc		as Character
	Local cTpInscTom	as Character	
	Local cNrInsc		as Character
	Local cIndObra		as Character
	Local cIdObra		as Character
	Local cDsObra		as Character
	Local cAlsTTCabc	as Character
	Local cAlsTTRcrs	as Character
	Local cAlsTTProc	as Character
	Local cCompart		as Character
	Local cIDEXTE       as Character
	Local oTTCabc		as Object
	Local oTTRcrs		as Object
	Local oTTProc		as Object
	Local nPos			as Numeric
	Local nVlrNRet		as Numeric
	Local nProp			as Numeric
	Local nVlrBruto		as Numeric
	Local nVlrImposto	as Numeric
	Local lAvanc		as Logical
	Local lV1GEX        as Logical	

	aCampCabc	:= {}
	aCampRcrs	:= {}
	aCampProc	:= {}
	nPos 	    := 0
	cAlsTTCabc  := ""
	cAlsTTRcrs  := ""
	cAlsTTProc	:= ""
	cChvReg	    := ""
	cChvAnt     := ""
	cCNPJTmPr	:= ""
	cTpInsc	    := ""
	cTpInscTom	:= ""
	cNrInsc	    := ""
	cIndObra	:= "" 
	cIdObra 	:= ""
	cDsObra 	:= ""
	cCompart	:= ""
	cIDEXTE     := ""
	lAvanc		:= .T.
	lV1GEX      := TAFColumnPos("V1G_IDEXTE")
	oTTCabc	    := Nil
	oTTRcrs	    := Nil
	oTTProc		:= Nil
	
	cNrInsc	    := ''
	SetalApurBx()
	nVlrBruto	:= 0
	nVlrImposto := 0

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial
		
		cAlsTTCabc	:= getNextAlias()
		cAlsTTRcrs	:= getNextAlias()
		cAlsTTProc	:= getNextAlias() 
		
		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc, @aCampRcrs,@aCampProc)
		
		// Instancia o objeto Temporary Table 
		oTTCabc	:= FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTRcrs	:= FWTemporaryTable():New(cAlsTTRcrs, aCampRcrs)
		oTTProc	:= FWTemporaryTable():New(cAlsTTProc, aCampProc)
		
		// Seta os devidos indices 
		PopIdxObj(@oTTCabc,@oTTRcrs,@oTTProc)

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(2)) //"CPERIODO", "CTPINSC", "CNRINSC", "CNPJORIGR", "CIDEXTE"
			
		DbSelectArea(cAlsTTRcrs)
		(cAlsTTRcrs)->(DbSetOrder(2)) //"ID", "TPREPASSE", "CNPJORIGR", "CIDEXTE"  
	
		(cAlias)->(DbGoTop())
		While (cAlias)->(!EOF())
			
			cNrInsc	:=	Posicione("SM0", 1, cEmpAnt+(cAlias)->FIL, "M0_CGC")
			nVlrNRet := 0 // Prestar atenção nesta variável
			nProp := 1

			If __lApurBx
				nProp :=  TafCalProp((cAlias)->VLRBRUTO, (cAlias)->VLPGTO) 
				nVlrBruto	:= (cAlias)->VLPGTO
				nVlrImposto := Round((cAlias)->VLRRETAPUR * nProp, 2)
			Else
				nVlrBruto	:= (cAlias)->VLRBRUTO
				nVlrImposto := (cAlias)->VLRRETAPUR	
			EndIf

			If (cAlias)->ROTINA == "NFS"
				cChvReg := (cAlias)->CHVNF
			Else
				cChvReg := (cAlias)->NUMDOCTO + (cAlias)->PREFIX + (cAlias)->CNPJORIREC
			EndIf

			If cChvReg <> cChvAnt 
				cChvAnt := cChvReg
				If !__lApurBx
					AADD(aMovs,{(cAlias)->ROTINA, (cAlias)->RECNO})
					RetProc(cAlsTTProc, cAlias, aCampProc, cPeriod + '1' + cNrInsc , cCompart, aInfoEUF, @nVlrNRet, nProp)
				EndIf
			EndIf

			If __lApurBx
				RetProc(cAlsTTProc, cAlias, aCampProc, cPeriod + '1' + cNrInsc , cCompart, aInfoEUF, @nVlrNRet, nProp)
				AADD(aMovs,{(cAlias)->ROTINA, (cAlias)->RECNOT5P})
			EndIf

			Iif (lV1GEX, cIDEXTE := (cAlias)->CIDEXTE, cIDEXTE := Space(36))
			
			If !(cAlsTTCabc)->(DbSeek(cPeriod + '1' + cNrInsc + (cAlias)->CNPJORIREC + cIDEXTE))

				RecLock(cAlsTTCabc,.T.)	

				(cAlsTTCabc)->ID		:= cPeriod + '1' + cNrInsc							
				(cAlsTTCabc)->CPERIODO	:= cPeriod
				(cAlsTTCabc)->CTPINSC	:= '1'
				(cAlsTTCabc)->CNRINSC	:= cNrInsc
				(cAlsTTCabc)->CNPJORIGR	:= (cAlias)->CNPJORIREC
				(cAlsTTCabc)->CIDEXTE   := cIDEXTE

				If lV1GEX
					(cAlsTTCabc)->CCODPAR   := (cAlias)->CCODPAR
					(cAlsTTCabc)->CDESPART  := SUBSTR((cAlias)->CDESPART,1,70)
				Else
					(cAlsTTCabc)->CCODPAR   := ' '
					(cAlsTTCabc)->CDESPART  := ' '
				EndIf

				(cAlsTTCabc)->VLRTOTAL	:= nVlrBruto				
				(cAlsTTCabc)->VLRTOTRET	:= nVlrImposto
				(cAlsTTCabc)->VLRTOTNRT	:= nVlrNRet
			
				(cAlsTTCabc)->(MsUnlock())
			Else 
							
				RecLock(cAlsTTCabc,.F.)	
				
				(cAlsTTCabc)->VLRTOTAL	+= nVlrBruto			
				(cAlsTTCabc)->VLRTOTRET	+= nVlrImposto
				(cAlsTTCabc)->VLRTOTNRT	+= nVlrNRet 
				
				(cAlsTTCabc)->(MsUnlock())
				
			EndIf 			
			
			If !(cAlsTTRcrs)->(DbSeek((cAlsTTCabc)->ID + (cAlias)->TPREPASSE + (cAlias)->CNPJORIREC + cIDEXTE))
				RecLock(cAlsTTRcrs,.T.)
				
				(cAlsTTRcrs)->ID		:= (cAlsTTCabc)->ID
				(cAlsTTRcrs)->TPREPASSE	:= (cAlias)->TPREPASSE
				(cAlsTTRcrs)->CNPJORIGR := (cAlias)->CNPJORIREC
				(cAlsTTRcrs)->CIDEXTE   := cIDEXTE
				(cAlsTTRcrs)->DESCRECRS := DescRepass( (cAlias)->TPREPASSE )
				(cAlsTTRcrs)->VLRBRUTO	:= nVlrBruto
				(cAlsTTRcrs)->VLRRETAPR	:= nVlrImposto

				(cAlsTTRcrs)->(MsUnlock())
			Else
				RecLock(cAlsTTRcrs,.F.)
				
				(cAlsTTRcrs)->VLRBRUTO	+= nVlrBruto
				(cAlsTTRcrs)->VLRRETAPR	+= nVlrImposto				
				
				(cAlsTTRcrs)->(MsUnlock())
				
			EndIf
		
			(cAlias)->(DbSkip())
		EndDo
	Else
		lAvanc := .F.
	EndIf
	(cAlias)->(DbCloseArea())

Return {{cAlsTTCabc,oTTCabc}, {cAlsTTRcrs,oTTRcrs}, {cAlsTTProc,oTTProc}, lAvanc}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProc

@author Henrique Pereira
@since 20/02/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetProc(cAlsTTProc, cAlias, aCampProc, cChavProc, cCompC1G, aSM0EUF, nVlrNRet, nProp)

	Local aRet			As Array
	Local cSelect		AS Character
	Local cFrom			AS Character
	Local cJoin			AS Character
	Local cJoinC1G		AS Character
	Local cWhere		AS Character
	Local cChave		AS Character
	Local cAliasT9Q		AS Character
	Local cChavSeek		AS Character
	Local cFilC1G		AS Character
	Local cBd			As Character
	Local cIDEXTE       As Character
	Local nTam			As Numeric
	Local nTamIDSUSP 	As Numeric
	Local lFormat		As Logical
	Local lProcessa		As Logical
	Local lV1GEX        as Logical

	Default nProp := 1

	aRet		:= {}
	cSelect		:= ''
	cFrom		:= ''
	cJoin		:= ''
	cJoinC1G	:= ''
	cWhere		:= ''
	cChave		:= ''
	cChavSeek	:= ''
	cIDEXTE     := ''
	cFilC1G		:= xFilial("C1G")
	cAliasT9Q	:= GetNextAlias()
	cBd			:= TcGetDb()
	nTam		:= 0
	nTamIDSUSP	:= 0
	lProcessa	:= .F.
	lFormat		:= .F.
	lV1GEX      := TAFColumnPos("V1G_IDEXTE")

	If 'NFS' $ ALLTRIM((cAlias)->ROTINA)

		cSelect 	:= "'" + cChavProc + "' AS ID,  '"+ (cAlias)->CHVNF + "' AS CCHAVE, 'NFS' AS ROTINA, T9Q.T9Q_TPPROC AS CTPPROC , "
		cSelect	+= " T9Q.T9Q_NUMPRO AS NUMPRO, T5L.T5L_CODSUS AS CODSUS, T9Q.T9Q_VALSUS AS VALSUS, C1G.C1G_TPPROC AS C1GTPPROC, "
		cSelect	+= " C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL "
		cFrom		:= RetSqlName("T9Q") + " T9Q"

		cJoinC1G	:=  RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL AND "	 
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				nTam += iif(nTam == 0, aSM0EUF[FILIAL], 0)
				lFormat := .T.
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				nTam += iif(nTam == 0, aSM0EUF[FILIAL], 0)
				lFormat := .T.		
			EndIf
			if lFormat
				If cBd $ "ORACLE|POSTGRES|DB2"
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(T9Q.T9Q_FILIAL,1," + cValToChar(nTam) + " ) AND "
				ElseIf cBd $ "INFORMIX"
					cJoinC1G += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL[1," + cValToChar(nTam) + "] AND "
				Else //MSSQL,MYSQL,PROGRESS
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(T9Q.T9Q_FILIAL,1," + cValToChar(nTam) + " ) AND "
				EndIf
			EndIf		
		EndIf

		cJoinC1G += " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

		If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
			
			if cBd $ "POSTGRES"
				nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = SUBSTR(T5L_ID || T5L_VERSAO || T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9Q.T9Q_FILIAL = '" +  (cAlias)->FIL + "' AND "
			Else
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L_ID || T5L_VERSAO || T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (cAlias)->FIL + "' AND "
			Endif
		Else
			cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L_ID+T5L_VERSAO+T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (cAlias)->FIL + "' AND "
		EndIf
		cJoin += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := "  T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CHVNF = '" + (cAlias)->CHVNF +  "' AND T9Q.T9Q_CODTRI = '000013' "
		
		cSelect 	:= "%" +	cSelect 	+ 	"%"
		cFrom		:= "%" +	cFrom	 	+ 	"%"
		cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
		cJoin 		:= "%" +	cJoin 		+ 	"%"
		cWhere 	:= "%" +	cWhere 	+ 	"%"

	Elseif 'FAT' $ ALLTRIM((cAlias)->ROTINA)

		cSelect 	:= "'" + cChavProc + "' AS ID, '"+ (cAlias)->NUMDOCTO + "' AS CCHAVE, 'FAT' AS ROTINA, T9E.T9E_TPPROC AS CTPPROC , "
		cSelect 	+= " T9E.T9E_NUMPRO AS NUMPRO, T5L.T5L_INDDEC AS INDSUSP ,T5L.T5L_CODSUS AS CODSUS, T9E.T9E_VALSUS AS VALSUS, C1G.C1G_TPPROC AS C1GTPPROC, "
		cSelect 	+= " C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL " 
		
		cFrom		:= RetSqlName("T9E") + " T9E"

		cJoinC1G 	:=  RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9E.T9E_FILIAL AND "			
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				nTam += iif(nTam == 0, aSM0EUF[FILIAL], 0)
				lFormat := .T.
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				nTam += iif(nTam == 0, aSM0EUF[FILIAL], 0)
				lFormat := .T.		
			EndIf
			if lFormat
				If cBd $ "ORACLE|POSTGRES|DB2"
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(T9E.T9E_FILIAL,1," + cValToChar(nTam) + " ) AND "
				ElseIf cBd $ "INFORMIX"
					cJoinC1G += " C1G.C1G_FILIAL = T9E.T9E_FILIAL[1," + cValToChar(nTam) + "] AND "
				Else //MSSQL,MYSQL,PROGRESS
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(T9E.T9E_FILIAL,1," + cValToChar(nTam) + " ) AND "
				EndIf
			EndIf
		EndIf

		cJoinC1G	+= " C1G.C1G_ID = T9E.T9E_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

		If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
			cJoin :=  RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L_ID || T5L_VERSAO || T5L_CODSUS AND  T9E.T9E_FILIAL = '" +  (cAlias)->FIL + "' AND "
		Else
			cJoin :=  RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L_ID+T5L_VERSAO+T5L_CODSUS AND  T9E.T9E_FILIAL = '" +  (cAlias)->FIL + "' AND "
		EndIf
		cJoin += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere		:= " T9E.D_E_L_E_T_ = ' ' AND T9E.T9E_ID = '" + (cAlias)->ID +  "' AND T9E.T9E_CODTRI = '000013' "
		
		cSelect 	:= "%" +	cSelect 	+ 	"%"
		cFrom		:= "%" +	cFrom	 	+ 	"%"
		cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
		cJoin 		:= "%" +	cJoin 		+ 	"%"
		cWhere		:= "%" +	cWhere 	+ 	"%"
		
	EndIf

	BeginSql Alias cAliasT9Q
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		INNER JOIN
		%Exp:cJoinC1G%
		INNER JOIN
		%Exp:cJoin%
		Where
		%Exp:cWhere%
	EndSql

	Iif (lV1GEX, cIDEXTE := (cAlias)->CIDEXTE, cIDEXTE := Space(36))
	
	If!(cAliasT9Q)->(EOF())
		cChavSeek := Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1") + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS + (cAlias)->CNPJORIREC + cIDEXTE + (cAliasT9Q)->ID
		lProcessa	:= .T.
	EndIf
	
	DbSelectArea(cAlsTTProc)
	
	(cAlsTTProc)->(DbSetOrder(2)) //"CTPPROC","C1GNUMPRO","CODSUS","CNPJORIGR","ID"
	(cAliasT9Q)->(DbGoTop())
	
	If lProcessa
		If !(cAliasT9Q)->(EOF())
			While !(cAliasT9Q)->(EOF())

				If !(cAlsTTProc)->(MsSeek(cChavSeek))
					 RecLock(cAlsTTProc, .T.)
					(cAlsTTProc)->ID		:= (cAliasT9Q)->ID
					(cAlsTTProc)->CTPPROC	:= Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1") 
					(cAlsTTProc)->C1GNUMPRO	:= (cAliasT9Q)->C1GNUMPRO
					(cAlsTTProc)->CODSUS	:= (cAliasT9Q)->CODSUS
					(cAlsTTProc)->CNPJORIGR	:= (cAlias)->CNPJORIREC
					(cAlsTTProc)->CIDEXTE   := cIDEXTE

					//If (cAliasT9Q)->INDSUSP <> '000015'
					(cAlsTTProc)->VLRNRET	:= (cAliasT9Q)->VALSUS * nProp
					//EndIf
					
					(cAlsTTProc)->C1GID		:= (cAliasT9Q)->C1GID
					(cAlsTTProc)->C1GVERSAO	:= (cAliasT9Q)->C1GVERSAO
					(cAlsTTProc)->C1GFILIAL	:= (cAliasT9Q)->C1GFILIAL				  
				Else
				  RecLock(cAlsTTProc, .F.)
				  //If (cAliasT9Q)->INDSUSP <> '000015'
				  (cAlsTTProc)->VLRNRET		+= (cAliasT9Q)->VALSUS * nProp
				  //EndIf
				EndIf
				
				//If (cAliasT9Q)->INDSUSP <> '000015'
				nVlrNRet += (cAliasT9Q)->VALSUS * nProp
				//EndIf
				
				(cAliasT9Q)->(DbSkip())
				 cChavSeek := Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1") + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS + (cAlias)->CNPJORIREC + cIDEXTE + (cAliasT9Q)->ID
			EndDo
			(cAlsTTProc)->(MsUnlock())
		Endif
	EndIf
	(cAliasT9Q)->(DbCloseArea())
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DescRepass
Retorna a descrição de acordo com o tipo de repasse
@author Henrique Pereira
@since 03/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function DescRepass(cTpRepass)
	Local cDesc as Character
	cDesc := ''
	Default cTpRepass := ''

	Do Case 
		Case cTpRepass = '1'
			cDesc	:= "Patrocinio"
		Case cTpRepass = '2'
			cDesc	:= "Lic de marcas e simb"
		Case cTpRepass = '3'
			cDesc	:= "Publicidade"
		Case cTpRepass = '4'
			cDesc 	:= "Propaganda"
		Case cTpRepass = '5'
			cDesc	:= "Transmis. espetaculo" 	
	EndCase

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2030
Efetua gravação no modelo da tabela espelho do evento R-2030 - Recursos Recebidos por Associação Desportiva

@author Henrique Pereira; Anieli Rodrigues
@since 04/04/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2030(nOpc, cPerApu, aApuracao, aInfoC1E,  cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus )

	Local cEvento		As Character
	Local cTpInsc 		As Character
	Local cRempEx       As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local nContLaco		As Numeric
	Local nContLac2		As Numeric
	Local nContLac3		As Numeric
	Local nErro			As Numeric
	Local oModel		As Object
	Local oModelC9B		As Object
	Local oModelV1G		As Object
	Local oModelV1H		As Object
	Local oModelV1I		As Object
	Local aProcErro		As Array			
	
	cEvento		:= "I"
	cTpInsc		:= (aApuracao[TCABC])->CTPINSC
	cRempEx     := ""
	cNrInsc		:= (aApuracao[TCABC])->CNRINSC
	lVldData	:= .T.
	lVldProc	:= .T.
	nContLaco	:= 1 
	nContLac2 	:= 1
	nContLac3 	:= 1
	nErro		:= 0
	oModel 		:= FWLoadModel("TAFA255")
	oModelC9B 	:= oModel:GetModel("MODEL_C9B")
	oModelV1G 	:= oModel:GetModel("MODEL_V1G")
	oModelV1H 	:= oModel:GetModel("MODEL_V1H")
	oModelV1I 	:= oModel:GetModel("MODEL_V1I")
	aProcErro	:= {}

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''
	
	T9V->(DbSetOrder(1))

	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_C9B', 'C9B_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_C9B', 'C9B_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_C9B', 'C9B_ID'		, cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_C9B', 'C9B_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_C9B', 'C9B_PERAPU'	, cPerApu)
	oModel:LoadValue('MODEL_C9B', 'C9B_STATUS'  , '')
	oModel:LoadValue('MODEL_C9B', 'C9B_EVENTO'  , cEvento)
	oModel:LoadValue('MODEL_C9B', 'C9B_ATIVO'   , '1')
	oModel:LoadValue('MODEL_C9B', 'C9B_TPINSC'	, (aApuracao[TCABC])->CTPINSC)		//tpInscEstab - CNPJ
	oModel:LoadValue('MODEL_C9B', 'C9B_NRINSC'	, (aApuracao[TCABC])->CNRINSC) 		//nrInscEstab
	oModel:LoadValue('MODEL_C9B', 'C9B_IDESTA' 	, aInfoC1E[1])
	oModel:LoadValue('MODEL_C9B', 'C9B_DESTAB' 	, aInfoC1E[2])
								
	While !(aApuracao[TCABC])->(Eof()) .And. (aApuracao[TCABC])->CTPINSC == cTpInsc .And. (aApuracao[TCABC])->CNRINSC == cNrInsc
	
		If nContLaco > 1 .And. !oModelC9B:VldData() 
			lVldData := .F.
		EndIf 
		
		
		If TAFColumnPos("V1G_IDEXTE")
			If Empty((aApuracao[TCABC])->CNPJORIGR) .and. !Empty((aApuracao[TCABC])->CIDEXTE)
				cRempEx := '1'
			Else
				cRempEx := '2'
			EndIf
		EndIf
		
		If nContLaco > 1
			oModelV1G:AddLine() 
		EndIf 

		oModel:LoadValue('MODEL_V1G', 'V1G_CNPJOR'	, (aApuracao[TCABC])->CNPJORIGR) //cnpjOrigRecurso

		If TAFColumnPos("V1G_IDEXTE")
			oModel:LoadValue('MODEL_V1G', 'V1G_REMPEX'	, (cRempEx))
			oModel:LoadValue('MODEL_V1G', 'V1G_IDEXTE'	, (aApuracao[TCABC])->CIDEXTE)	 
			oModel:LoadValue('MODEL_V1G', 'V1G_CODPAR'	, (aApuracao[TCABC])->CCODPAR)	 	 
			oModel:LoadValue('MODEL_V1G', 'V1G_NEMPEX'	, (aApuracao[TCABC])->CDESPART)
		EndIf	

		oModel:LoadValue('MODEL_V1G', 'V1G_VLREPA'	, (aApuracao[TCABC])->VLRTOTAL)	 //vlrTotalRec
		oModel:LoadValue('MODEL_V1G', 'V1G_VLRET'	, (aApuracao[TCABC])->VLRTOTRET) //vlrTotalRet
		oModel:LoadValue('MODEL_V1G', 'V1G_VLNRET'	, (aApuracao[TCABC])->VLRTOTNRT) //vlrTotalNRet	
		
		(aApuracao[TPRCRS])->(DbSetOrder(1))
		(aApuracao[TPRCRS])->(DbSeek((aApuracao[TCABC])->ID + (aApuracao[TCABC])->CNPJORIGR + (aApuracao[TCABC])->CIDEXTE))

		While !(aApuracao[TPRCRS])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TPRCRS])->ID .And. (aApuracao[TCABC])->CNPJORIGR == (aApuracao[TPRCRS])->CNPJORIGR .And. (aApuracao[TCABC])->CIDEXTE == (aApuracao[TPRCRS])->CIDEXTE
	
			If nContLac2 > 1 .And. (!oModelV1G:VldData() .Or. !oModelV1H:VldData()) 
				lVldData := .F.
			EndIf 
			
			If nContLac2 > 1
				oModelV1H:AddLine()  
			EndIf 
			
			If TAFColumnPos("V1H_IDEXTE")
				oModel:LoadValue('MODEL_V1H', 'V1H_IDEXTE'	, (aApuracao[TPRCRS])->CIDEXTE) 
			EndIf
			oModel:LoadValue('MODEL_V1H', 'V1H_TPREPA'	, (aApuracao[TPRCRS])->TPREPASSE) //tpRepasse
			oModel:LoadValue('MODEL_V1H', 'V1H_DESCRE'	, (aApuracao[TPRCRS])->DESCRECRS) //descRecurso
			oModel:LoadValue('MODEL_V1H', 'V1H_VLBRUT'	, (aApuracao[TPRCRS])->VLRBRUTO)  //vlrBruto
			oModel:LoadValue('MODEL_V1H', 'V1H_VLRECP'	, (aApuracao[TPRCRS])->VLRRETAPR) //vlrRetApur
		
			(aApuracao[TPRCRS])->(DbSkip())
			nContLac2++
		EndDo
		
		(aApuracao[TPROC])->(DbSetOrder(1))
		(aApuracao[TPROC])->(DbSeek((aApuracao[TCABC])->ID + (aApuracao[TCABC])->CNPJORIGR + (aApuracao[TCABC])->CIDEXTE))
	
		While !(aApuracao[TPROC])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TPROC])->ID .And. (aApuracao[TCABC])->CNPJORIGR == (aApuracao[TPROC])->CNPJORIGR .And. (aApuracao[TCABC])->CIDEXTE == (aApuracao[TPROC])->CIDEXTE
			If nContLac3 > 1 .And. (!oModelV1H:VldData() .Or. !oModelV1I:VldData()) 
				lVldData := .F. 
			EndIf
				 
			If nContLac3 > 1 
				oModelV1I:AddLine()
			EndIf
			
			If TAFColumnPos("V1I_IDEXTE")
				oModel:LoadValue('MODEL_V1I', 'V1I_IDEXTE', (aApuracao[TPROC])->CIDEXTE)
			EndIf

			oModel:LoadValue('MODEL_V1I', 'V1I_IDPROC', (aApuracao[TPROC])->C1GID)
			oModel:LoadValue('MODEL_V1I', 'V1I_TPPROC', (aApuracao[TPROC])->CTPPROC)	//tpProc
			oModel:LoadValue('MODEL_V1I', 'V1I_NRPROC', (aApuracao[TPROC])->C1GNUMPRO)	//nrProc
			oModel:LoadValue('MODEL_V1I', 'V1I_IDSUSP', (aApuracao[TPROC])->C1GID + (aApuracao[TPROC])->C1GVERSAO + (aApuracao[TPROC])->CODSUS)
			oModel:LoadValue('MODEL_V1I', 'V1I_CODSUS', (aApuracao[TPROC])->CODSUS)		//codSusp
			oModel:LoadValue('MODEL_V1I', 'V1I_VLNRET', (aApuracao[TPROC])->VLRNRET)	//vlrNRet
			
			T9V->(DbSetOrder(5))
			If !T9V->(DbSeek(cFilAnt + (aApuracao[TPROC])->C1GID + "1"))
				lVldProc := .F. 
				Aadd(aProcErro,{Nil ,Alltrim((aApuracao[TPROC])->C1GNUMPRO), NIl, oModel:GetErrorMessage()}  )
			EndIf
			
			(aApuracao[TPROC])->(DbSkip())
			nContLac3++
		EndDo 
		
		nContLac2 := 1
		nContLac3 := 1
		(aApuracao[TCABC])->(DbSkip())
		nContLaco++
	EndDo
			
	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		TafEndGRV( "C9B","C9B_PROCID", cIdApReinf, C9B->(Recno()))
	    lRollBack := .T.
	Else
		cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
		cErro 	+= "tpInscEstab: "	+ cTpInsc + CRLF
		cErro 	+= "nrInscEstab: " 	+ cNrInsc + CRLF
		
		If !lVldProc 
			//oModel:VldData()
			//cErro	+= STR0008 + Alltrim((aApuracao[TPROC])->C1GNUMPRO) + STR0009  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
			For nErro := 1 to Len(aProcErro)
				
				cErro	+= '----------------------------------------------' + CRLF
				cErro	+= "Existe o seguinte impedimento: " + CRLF
				cErro	+= "Processo número " + Alltrim(aProcErro[nErro][2]) + " não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
				
			Next nErro	
		EndIf
		
		cErro  	+= STR0010 + CRLF + CRLF //"Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)
		
		Aadd(aErro, {"R-2030", "ERRO", cErro})
		lRollBack := .F.

	EndIf

Return(lRollBack)

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2040
Efetua gravação no modelo da tabela espelho do evento R-2040 - Recursos Repassados para Associação Desportiva

@author Henrique Pereira; Anieli Rodrigues
@since 04/04/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2040(nOpc, cPerApu, aApuracao, aInfoC1E,  cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus )

	Local cEvento		As Character
	Local cTpInsc 		As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local nContLaco		As Numeric
	Local nContLac2		As Numeric
	Local nContLac3		As Numeric
	Local nErro			as Numeric
	Local oModel		As Object
	Local oModelT9K		As Object
	Local oModelV1J		As Object
	Local oModelV1K		As Object
	Local oModelV1L		As Object
	Local aProcErro		As Array			
	
	cEvento		:= "I"
	cTpInsc		:= (aApuracao[TCABC])->CTPINSC
	cNrInsc		:= (aApuracao[TCABC])->CNRINSC
	lVldData	:= .T.
	lVldProc	:= .T.
	nContLaco	:= 1 
	nContLac2 	:= 1
	nContLac3 	:= 1
	nErro		:= 0
	oModel 		:= FWLoadModel("TAFA491")
	oModelT9K 	:= oModel:GetModel("MODEL_T9K")
	oModelV1J 	:= oModel:GetModel("MODEL_V1J")
	oModelV1K 	:= oModel:GetModel("MODEL_V1K")
	oModelV1L 	:= oModel:GetModel("MODEL_V1L")
	aProcErro	:= {}

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''
	
	T9V->(DbSetOrder(1))

	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_T9K', 'T9K_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_T9K', 'T9K_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_T9K', 'T9K_ID'		, cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_T9K', 'T9K_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_T9K', 'T9K_PERAPU'	, cPerApu)
	oModel:LoadValue('MODEL_T9K', 'T9K_STATUS'  , '')
	oModel:LoadValue('MODEL_T9K', 'T9K_EVENTO'  , cEvento)
	oModel:LoadValue('MODEL_T9K', 'T9K_ATIVO'   , '1')
	oModel:LoadValue('MODEL_T9K', 'T9K_TPINSC'	, (aApuracao[TCABC])->CTPINSC)		//tpInscEstab - CNPJ
	oModel:LoadValue('MODEL_T9K', 'T9K_NRINSC'	, (aApuracao[TCABC])->CNRINSC) 		//nrInscEstab
	oModel:LoadValue('MODEL_T9K', 'T9K_IDESTA' 	, aInfoC1E[1])
	oModel:LoadValue('MODEL_T9K', 'T9K_DESTAB' 	, aInfoC1E[2])
								
	While !(aApuracao[TCABC])->(Eof()) .And. (aApuracao[TCABC])->CTPINSC == cTpInsc .And. (aApuracao[TCABC])->CNRINSC == cNrInsc
	
		If nContLaco > 1 .And. !oModelT9K:VldData() 
			lVldData := .F.
		EndIf 
		
		If nContLaco > 1
			oModelV1J:AddLine() 
		EndIf 

		oModel:LoadValue('MODEL_V1J', 'V1J_CNPJAD'	, (aApuracao[TCABC])->CNPJORIGR)	//cnpjAssocDesp
		oModel:LoadValue('MODEL_V1J', 'V1J_VLREPA'	, (aApuracao[TCABC])->VLRTOTAL)		//vlrTotalRep
		oModel:LoadValue('MODEL_V1J', 'V1J_VLRET'	, (aApuracao[TCABC])->VLRTOTRET)	//vlrTotalRet
		oModel:LoadValue('MODEL_V1J', 'V1J_VLNRET'	, (aApuracao[TCABC])->VLRTOTNRT)	//vlrTotalNRet	
		
		(aApuracao[TPRCRS])->(DbSetOrder(1))
		(aApuracao[TPRCRS])->(DbSeek((aApuracao[TCABC])->ID + (aApuracao[TCABC])->CNPJORIGR))

		While !(aApuracao[TPRCRS])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TPRCRS])->ID .And. (aApuracao[TCABC])->CNPJORIGR == (aApuracao[TPRCRS])->CNPJORIGR
	
			If nContLac2 > 1 .And. (!oModelV1J:VldData() .Or. !oModelV1K:VldData()) 
				lVldData := .F.
			EndIf 
			
			If nContLac2 > 1
				oModelV1K:AddLine() 
			EndIf 
		
			oModel:LoadValue('MODEL_V1K', 'V1K_TPREPA'	, (aApuracao[TPRCRS])->TPREPASSE)	//tpRepasse
			oModel:LoadValue('MODEL_V1K', 'V1K_DESCRE'	, (aApuracao[TPRCRS])->DESCRECRS)	//descRecurso
			oModel:LoadValue('MODEL_V1K', 'V1K_VLBRUT'	, (aApuracao[TPRCRS])->VLRBRUTO)		//vlrBruto
			oModel:LoadValue('MODEL_V1K', 'V1K_VLRECP'	, (aApuracao[TPRCRS])->VLRRETAPR)	//vlrRetApur
		
			(aApuracao[TPRCRS])->(DbSkip())
			nContLac2++
		EndDo
		
		(aApuracao[TPROC])->(DbSetOrder(1))
		(aApuracao[TPROC])->(DbSeek((aApuracao[TCABC])->ID + (aApuracao[TCABC])->CNPJORIGR))
	
		While !(aApuracao[TPROC])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TPROC])->ID .And. (aApuracao[TCABC])->CNPJORIGR == (aApuracao[TPROC])->CNPJORIGR
			If nContLac3 > 1 .And. (!oModelV1K:VldData() .Or. !oModelV1L:VldData()) 
				lVldData := .F. 
			EndIf
				 
			If nContLac3 > 1 
				oModelV1L:AddLine()
			EndIf
			
			oModel:LoadValue('MODEL_V1L', 'V1L_IDPROC', (aApuracao[TPROC])->C1GID)
			oModel:LoadValue('MODEL_V1L', 'V1L_TPPROC', (aApuracao[TPROC])->CTPPROC)	//tpProc
			oModel:LoadValue('MODEL_V1L', 'V1L_IDSUSP', (aApuracao[TPROC])->C1GID + (aApuracao[TPROC])->C1GVERSAO + (aApuracao[TPROC])->CODSUS)
			oModel:LoadValue('MODEL_V1L', 'V1L_NRPROC', (aApuracao[TPROC])->C1GNUMPRO)	//nrProc
			oModel:LoadValue('MODEL_V1L', 'V1L_CODSUS', (aApuracao[TPROC])->CODSUS)		//codSusp
			oModel:LoadValue('MODEL_V1L', 'V1L_VLNRET', (aApuracao[TPROC])->VLRNRET)	//vlrNRet
			
			T9V->(DbSetOrder(5))
			If !T9V->(DbSeek(cFilAnt + (aApuracao[TPROC])->C1GID + "1"))
				lVldProc := .F. 
				Aadd(aProcErro,{Nil ,Alltrim((aApuracao[TPROC])->C1GNUMPRO), NIl, oModel:GetErrorMessage()}  )
			EndIf
			
			(aApuracao[TPROC])->(DbSkip())
			nContLac3++
		EndDo 
		
		nContLac2 := 1
		nContLac3 := 1
		(aApuracao[TCABC])->(DbSkip())
		nContLaco++
	EndDo
			
	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		TafEndGRV( "T9K","T9K_PROCID", cIdApReinf, T9K->(Recno()))
	    lRollBack := .T.
	Else
		cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
		cErro 	+= "tpInscEstab: "	+ cTpInsc + CRLF
		cErro 	+= "nrInscEstab: " 	+ cNrInsc + CRLF
		
		If !lVldProc 
			//oModel:VldData()
			//cErro	+= STR0008 + Alltrim((aApuracao[TPROC])->C1GNUMPRO) + STR0009  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
			For nErro := 1 to Len(aProcErro)
				
				cErro	+= '----------------------------------------------' + CRLF
				cErro	+= "Existe o seguinte impedimento: " + CRLF
				cErro	+= "Processo número " + Alltrim(aProcErro[nErro][2]) + " não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
				
			Next nErro	
		EndIf
		
		cErro  	+= STR0010 + CRLF + CRLF //"Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)
		
		Aadd(aErro, {"R-2040", "ERRO", cErro})
		lRollBack := .F.

	EndIf

Return(lRollBack)

//-------------------------------------------------------------------
/*/{Protheus.doc} StatsReg
Verifica a existência ou não do registro que será apurado

@author Henrique Pereira; Anieli Rodrigues
@since 14/02/2018
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------

Static Function StatsReg(cReg, cPerApu, cTpInsc, cNrInsc)

	Local cRetStat as Character //retorno do status do registro
	cRetStat := "Z"
	Default cPerApu := ""
	
	If cReg == 'R-2030'
		If C9B->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + '1'))
			cRetStat := C9B->C9B_STATUS
		Else 
			cRetStat := "Z"
		EndIf
	
	ElseIf cReg == 'R-2040'
		If T9K->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + '1'))
			cRetStat := T9K->T9K_STATUS
		Else 
			cRetStat := "Z"
		EndIf
	EndIf
	
Return cRetStat

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author anieli.rodrigues
@since 05/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(cIdApReinf, cReg, aErro)

	Local cErro		As Character
	Local cNrInscEst	As Character
	Local cTpInscEst	As Character
	Local lExcluiu	As Logical 
	Local oModel 		As Object
	
	cErro := "" 
	cTpInscEst := ""
	lExcluiu := .F.
	
	If cReg == 'R-2030'
		oModel 	:= FWLoadModel("TAFA255")
		cNrInscEst	:= C9B->C9B_NRINSC
		cTpInscEst	:= C9B->C9B_TPINSC
	Else
		oModel 	:= FWLoadModel("TAFA491")
		cNrInscEst	:= T9K->T9K_NRINSC
		cTpInscEst	:= T9K->T9K_TPINSC
	EndIf
 
	oModel:SetOperation(5)
	oModel:Activate()
	
	If FwFormCommit(oModel)
	    lExcluiu := .T.
	Else
		cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	
		cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF	
		cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF

		cErro  	+= STR0006 + CRLF
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {cReg, "ERRO", cErro})
		lExcluiu := .F.
	EndIf

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()

@author anieli.rodriges
@since 05/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function GravaId(aMovs, cIdApur)

	Local	nX	as numeric
 
	Default aMovs 	:= {}
	Default cIdApur	:= ''

	For nX := 1 to Len(aMovs)
		Do case
		case Alltrim(aMovs[nX][1]) == 'NFS'
			TafEndGRV( "C20","C20_PROCID", cIdApur, aMovs[nX][2]  )
		case Alltrim(aMovs[nX][1]) == 'FAT'
			If __lApurBx
				TafEndGRV( "T5P","T5P_PROCID", cIdApur, aMovs[nX][2]  )
			Else
				TafEndGRV( "LEM","LEM_PROCID", cIdApur, aMovs[nX][2]  )
			EndIf	
		EndCase
	Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TafCalProp()
Calcula o % proporcional do valor do pagto em relação ao valor total

@param nValTotal, numérico, Valor total da fatura
@param nValPago, numérico, Valor do pagamento

@author Karen Honda
@since 20/05/2021
@version 1.0
@return nAliq, numérico, % proporcional do pagto em relação ao total

/*/ 
//-------------------------------------------------------------------

Function TafCalProp(nValTotal, nValPago)
Local nAliq as Numeric

nAliq := (nValPago * 100)/nValTotal
nAliq := nAliq/100

Return nAliq

//-------------------------------------------------------------------
/*/{Protheus.doc} SetalApurBx()
Seta a variavel __lApurBx conforme o parâmetro

@author Karen Honda
@since 20/05/2021
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function SetalApurBx()
If __lApurBx == nil
	__lApurBx	:= SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID")// "1"- Emissão ; "2" - Baixa 
EndIf
Return
