#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXINT.CH"

#DEFINE D_PRELAN	"9"

STATIC __aTamVlr 	:= Nil
STATIC lFWCodFil := FindFunction("FWCodFil")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³IncLast    ³ Autor ³ Claudio Donizete    			   ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Soma um no ultimo byte de uma string, normalmente para ser utilizado  ³±±
±±³			 ³ em pesquisas com softseek on, para posicionar no	ultimo registro + 1	 ³±±
±±³          ³de uma chave.															 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³IncLast(cString)                                                    	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³LEFT(cString, LEN(cString)-1)+ CHR(ASC(RIGHT(cString,1))+1) 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String a ser pesquisada          				 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³  Ex.:																 ³±±
±±³			 ³	// cChave := "CLAUDIO"											     ³±±
±±³			 ³	// MsSeek(IncLast(cChave)),.T.) // MsSeek("CLAUDIP")				 ³±±
±±³			 ³	// Se na base tiver:												 ³±±
±±³			 ³	// CLAUDIO <-- Ponteiro atual    (1)                                 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// DANIELA <-- Apos o MsSeek     (2)								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION IncLast( cString )

	Local cLeft    := LEFT(cString, LEN(cString)-1)
	Local cLastChr := CHR(ASC(RIGHT(cString,1))+1)

	If ! ( CHR(ASC(RIGHT(cString,1))) $ "Z/z/9" )	//	Se o ultimo caracter nao for "Z", "z" e "9"
		cLeft	+= cLastChr							//	Incrementa um
	Else
		If CHR(ASC(RIGHT(cString,1))) == "9"
			cLeft	+= "A"
		ElseIf CHR(ASC(RIGHT(cString,1))) == "Z"
			cLeft	+= "a"
		ElseIf CHR(ASC(RIGHT(cString,1))) == "z"
			cLeft	:= Soma1(cString)
		Endif
	EndIf

RETURN(cLeft)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjuBarPath ³ Autor ³ Cristiano Denardi     ³ Data ³ 06.07.05 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta string de path com ultimo caractere com "/" 					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Path ajustado                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AjuBarPath( cPath )

	Local 	cBarra := ""
	Default cPath  := ""

	If !Empty( cPath )
		cBarra := If(isSrvUnix(),"/","\")
		If Right(cPath,1) != cBarra
			cPath += cBarra
		Endif
	Endif

Return cPath
//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT7SP
Saldo do Plano de Contas com Stored Procedure.
Utilizada na geração do Manad (Registro I150)

@author Alvaro Camillo Neto
@param dDataIni  Data Inicial para buscar o saldo
@param dDataFim  Data Final   para buscar o saldo
@param cMoeda    Moeda
@param cFilIni   Filial Inicial
@param cFilFim   Filial Final
@param lObj      Se existe a barra de progresso
@param oMeter    Barra de progresso


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldoCT7SP(dDataIni,dDataFim,cMoeda,cFilIni,cFilFim,lObj,oMeter)

	Local aSaveCT7	:= CT7->(GetArea())
	Local aSaveAnt	:= GetArea()
	Local aStruct
	Local aPeriodos := {}
	Local aValPer

	Local dData
	Local dDataIniProc
	Local dDataFimProc

	Local cConta
	Local cIniPer
	Local cFimPer
	Local cQueryCT7 := ""
	Local cQuery	:= ""
	Local lPriVez
	Local lAchouPer
	Local nPar		:= 0
	Local nPer
	Local nSldAnt
	Local nTotReg
	Local nMeter	:= 0
	Local nTam		:= 0
	Local oQuery		:= Nil
	Private oBulkCTB		:= FWBulk():CanBulk()

	DEFAULT cFilIni	:= xFilial("CT2")
	DEFAULT cFilFim	:= xFilial("CT2")
	DEFAULT __aTamVlr := TamSX3("CT2_VALOR")

	dData := dDataIni-1
	nTam  := TamSX3("CT1_CONTA")[1]

	// Mantida estrutura da tabela temporária para compatibilização
	aStruct :=	{{ "CT7_FILIAL"	, "C", IIf( lFWCodFil, FWGETTAMFILIAL, 2 ), 0 },;	// Filial
		{ "CT7_CONTA"	, "C", nTam, 0 },;	// Codigo da Conta
		{ "CT7_DATA"	, "C",    8, 0 },;	// Data
		{ "CT7_ANTDEB"	, "N",   16, 2 },; 	// Saldo Anterior
		{ "CT7_ANTCRD"	, "N",   16, 2 },; 	// Debito no Mes
		{ "CT7_DEBITO"	, "N",   16, 2 },; 	// Credito no Mes
		{ "CT7_CREDIT"	, "N",   16, 2 },;	// Saldo Atual
		{ "CT7_ATUDEB"	, "N",   16, 2 },;	// Saldo Atual
		{ "CT7_ATUCRD"	, "N",   16, 2 },;	// Saldo Atual
		{ "ZERADO"		, "C",    1, 0 }}	// Flag zerado



	If TcCanOpen("SLDCT7_I_"+cEmpAnt+"0")
		// Se a tabela existir, apagar os registros"
		TCSqlExec("TRUNCATE TABLE SLDCT7_I_"+cEmpAnt+"0")
	Else
		DbCreate("SLDCT7_I_"+cEmpAnt+"0", aStruct, "TOPCONN")
	EndIf
	oBulkCTB := FwBulk():New("SLDCT7_I_"+cEmpAnt+"0")
	oBulkCTB:setFields(aStruct)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Cria Query que vai popular a tabela temporaria                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cData := DTOS(dData)
	CriaManad1(cFilIni, cFilFim, DtoS(dData), cMoeda )
	
	cQueryCT7 :=""

	// Refaz para os outros periodos
	dDataIniProc := dDataIni
	dDataFimProc := dDataFim

	If dDataFim > LastDay(dDataIni)
		dDataFimProc := LastDay(dDataIni)
	EndIf
	
	cQuery := CriaManad2(cFilIni, cFilFim, cMoeda, DtoS(dDataIniProc), DtoS(dDataFimProc) )
	oQuery := FwExecStatement():New( ChangeQuery(cQuery) )

	While dDataFimProc <= dDataFim
		nPar := 1
		aadd( aPeriodos, { DtoS(dDataIniProc), DtoS(dDataFimProc) } )

		conoutR( STR0005+ DtoS(dDataIniProc) + ": " + DtoC(DATE()) + " - " + TIME() )  //"Inicio Periodo "
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Cria Query que vai popular a tabela temporaria                    		³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		if cFilIni == cFilFim
			oQuery:setString(nPar++, cFilIni)
		else
			oQuery:setString(nPar++, cFilIni)
			oQuery:setString(nPar++, cFilFim)
		endif
		if DtoS(dDataIniProc) == DtoS(dDataFimProc)
			oQuery:setString(nPar++, DtoS(dDataIniProc))
		else
			oQuery:setString(nPar++, DtoS(dDataIniProc))
			oQuery:setString(nPar++, DtoS(dDataFimProc))
		endif
		oQuery:setString(nPar++, cMoeda)
		oQuery:setString(nPar++, '1') //CQ1_TPSALD
		oQuery:setString(nPar++, ' ') //D_E_L_E_T_
		oQuery:setString(nPar++, ' ') //D_E_L_E_T_
		oQuery:setString(nPar++, '2') //CT1_CLASSE = '2'
		if cFilIni == cFilFim
			oQuery:setString(nPar++, cFilIni)
		else
			oQuery:setString(nPar++, cFilIni)
			oQuery:setString(nPar++, cFilFim)
		endif
		if DtoS(dDataIniProc) == DtoS(dDataFimProc)
			oQuery:setString(nPar++, DtoS(dDataIniProc))
		else
			oQuery:setString(nPar++, DtoS(dDataIniProc))
			oQuery:setString(nPar++, DtoS(dDataFimProc))
		endif
		oQuery:setString(nPar++, cMoeda)
		oQuery:setString(nPar++, '1') //CQ1_TPSALD
		oQuery:setString(nPar++, ' ') //D_E_L_E_T_
		cQuery := oQuery:GetFixQuery()
		cQuery := STRTRAN(cQuery,'[XDATAX]',DtoS(dDataFimProc))
		MPSysOpenQuery(cQuery, "QRYTRB")
		While QRYTRB->(!EOF())
			if !QRYTRB->(oBulkCTB:AddData({'',CQ1_CONTA,CQ1_DATA,0,0,CQ1_DEBITO,CQ1_CREDIT,0,0,ZERADO}))
				UserException(oBulkCTB:GetError())
			endif
			QRYTRB->(dbskip())
		end
		If !oBulkCTB:Close()
			//- quebra a execução com erro, pois não atualizou o registro
			UserException(oBulkCTB:GetError())
		EndIF
		QRYTRB->(DBCloseArea())
		conoutR( STR0006+ DtoS(dDataIniProc) + ": " + DtoC(DATE()) + " - " + TIME() )  //"Final  Periodo "

		dDataIniProc := dDataFimProc + 1
		dDataFimProc := LastDay(dDataIniProc)

		If (dDataIniProc <= dDataFim) .And. (dDataFimProc > dDataFim)
			dDataFimProc := dDataFim
		EndIf
	EndDo
	oQuery:destroy()
	freeObj(oQuery)
	oBulkCTB:Destroy()
	FreeObj(oBulkCTB)

	dbUseArea( .T.,"TOPCONN", "SLDCT7_I_"+cEmpAnt+"0", "SLDCT7", .F., .F. )
	SLDCT7->( DbGoBottom() )
	nTotReg := SLDCT7->( Recno() )
	SLDCT7->( DbGoTop() )

	TcSetField("SLDCT7","CT7_ANTDEB"  ,"N",__aTamVlr[1],__aTamVlr[2])
	TcSetField("SLDCT7","CT7_ANTCRD"  ,"N",__aTamVlr[1],__aTamVlr[2])
	TcSetField("SLDCT7","CT7_DEBITO"  ,"N",__aTamVlr[1],__aTamVlr[2])
	TcSetField("SLDCT7","CT7_CREDIT"  ,"N",__aTamVlr[1],__aTamVlr[2])
	TcSetField("SLDCT7","CT7_ATUDEB"  ,"N",__aTamVlr[1],__aTamVlr[2])
	TcSetField("SLDCT7","CT7_ATUCRD"  ,"N",__aTamVlr[1],__aTamVlr[2])

	IndRegua("SLDCT7","SLDCT7_I_"+cEmpAnt+"0","CT7_CONTA, CT7_DATA",,,OemToAnsi(STR0007))  //"Selecionando Registros..."

	dbSelectArea("SLDCT7")

	conoutR( STR0008 + DtoC(DATE()) + " - " + TIME() + " - " + AllTrim(Str(nTotReg,10)) + STR0009 )  //"Inicio Gravacao AT7: "###" Registros"

	If lObj
		oMeter:SetTotal(nTotReg)
		oMeter:Set(0)
	EndIf

	If Len( aPeriodos ) > 0

		Do While ! SLDCT7->(EOF())

			cConta		:= SLDCT7->CT7_CONTA
			lPriVez		:= .T.
			nPer		:= 1
			nSldAnt		:= 0

			Do While !SLDCT7->(EOF()) .And. SLDCT7->CT7_CONTA == cConta

				If lPriVez
					aValPer    := {}
					lPriVez    := .F.
				Else
					nPer++
				EndIf

				cIniPer	:= aPeriodos[nPer,1]
				cFimPer	:= aPeriodos[nPer,2]

				Aadd( aValPer, { 0,0,0 } )
				// [1] : Saldo   Anterior
				// [2] : Debito  Atual	//	Debito  Anterior
				// [3] : Credito Atual	//	Debito  Atual

				lAchouPer	:=	.F.
				Do While !SLDCT7->(EOF()) .And. SLDCT7->CT7_CONTA == cConta .And. SLDCT7->CT7_DATA <= cFimPer

					If SLDCT7->ZERADO == '0'

						// Se estiver dentro do periodo
						IF SLDCT7->CT7_DATA >= cIniPer .And. SLDCT7->CT7_DATA <= cFimPer

							aValPer[nPer,1] := nSldAnt				// Saldo Anterior
							aValPer[nPer,2] += SLDCT7->CT7_DEBITO	// Débito  atual do periodo
							aValPer[nPer,3] += SLDCT7->CT7_CREDIT	// Crédito atual do periodo

							lPriVez 	:= .F.
							lAchouPer	:= .T.

						ELSEIF SLDCT7->CT7_DATA < cIniPer	//	Aqui, trata-se do saldo anterior ao 1º periodo

							nSldAnt	+= (SLDCT7->CT7_ATUCRD - SLDCT7->CT7_ATUDEB)	//	Saldo Anterior ao Primeiro Periodo

						ENDIF
					Endif

					If lObj
						nMeter++
						oMeter:Set(nMeter)
					EndIf

					SLDCT7->( DbSkip() )
				EndDo

				If !lAchouPer  //Se nao teve movimento no periodo, igualar o saldo final ao saldo inicial
					aValPer[nPer,1] := nSldAnt
					aValPer[nPer,2] := 0
					aValPer[nPer,3] := 0
				Endif

				// Gravar AT7 (Temporario utilizado no Manad.ini)

				dbSelectArea("AT7")
				RecLock("AT7",.T.)
				AT7->CONTA		:= Trim(cConta)
				AT7->DATASLD	:= CtoD( Right(cFimPer,2) + "/" + SubStr(cFimPer,5,2) + "/" + Left(cFimPer,4) )
				AT7->SALDOANT	:= aValPer[nPer,1]									// Saldo Anterior
				AT7->SALDODEB	:= aValPer[nPer,2]									// Debito  no Mes
				AT7->SALDOCRD	:= aValPer[nPer,3]									// Credito no Mes
				AT7->SALDOATU	:= (AT7->SALDOANT - AT7->SALDODEB + AT7->SALDOCRD) 	// Saldo Atual
				AT7->TIPOCONTA	:= "2"		//	"2"-Conta Analitica (No CT7 só há contas analíticas)

				AT7->(MsUnlock())

				nSldAnt	:= AT7->SALDOATU	//	Sld Anterior      do prx periodo
			EndDo

		EndDo
	Else
		conoutR( STR0010 )  //'Nao encontrou periodos. Confira os parametros [Data Inicial] e [Data Final].'
	EndIf

	If Select("SLDCT7") > 0
		SLDCT7->( dbCloseArea() )
	EndIf

	If Select("AT7") > 0
		dbSelectArea("AT7")
		If IndexOrd() > 0
			dbSetOrder(1)
		EndIf
	Endif

	// Tabela
	If TcCanOpen("SLDCT7_I_"+cEmpAnt+"0")
		TcDelFile("SLDCT7_I_"+cEmpAnt+"0")
	EndIf

	conoutR( STR0011 + DtoC(DATE()) + " - " + TIME() )  //"Final  Gravacao AT7: "

	CT7->(RestArea(aSaveCT7))
	RestArea(aSaveAnt)


Return .T.


/*/{Protheus.doc} CriaManad1
Rotina para alimentar a tabela temporaria 
@type function
@version 12.1.25 
@author Leandro Duarte
@since 11/11/2025
@param cFilIni, character, filial inicial
@param cFilFim, character, Filial Final
@param cData, character, Data final
@param cMoeda, character, Moeda listada
/*/
Function CriaManad1(cFilIni, cFilFim, cData, cMoeda)
	Local cQuery   := ""
	Local cTrb 		:= GetNextAlias()
	Local nANTDEB	:= 0
	Local nANTCRD	:= 0
	Local nDEBITO 	:= 0
	Local nCREDIT 	:= 0
	Local nATUDEB 	:= 0
	Local nATUCRD 	:= 0
	Local cCQ1FILIAL	:= "" 
	Local cCQ1CONTA		:= "" 
	Local cCQ1DATA		:= ""

	cQuery += "   select "+CRLF
	cQuery += "   	CQ1_FILIAL, "+CRLF
	cQuery += "   	CQ1_CONTA,"+CRLF
	cQuery += "   	CQ1_DATA, "+CRLF
	cQuery += "   	0 ANTDEB, "+CRLF
	cQuery += "   	0 ANTCRD, "+CRLF
	cQuery += "   	SUM(CQ1_DEBITO) DEBITO, "+CRLF
	cQuery += "   	SUM(CQ1_CREDIT) CREDIT,"+CRLF
	cQuery += "   	0 ATUDEB,"+CRLF
	cQuery += "   	0 ATUCRD,"+CRLF
	cQuery += "   	'0' FLAG"+CRLF
	cQuery += "   FROM"+CRLF
	cQuery += "   	"+RetSqlName("CQ1")+" CQ1"+CRLF
	cQuery += "   where "+CRLF
	If cFilIni == cFilFim
		cQuery += "   	CQ1_FILIAL = '" + cFilIni + "'  "+CRLF
	Else
		cQuery += "   	CQ1_FILIAL between '" + cFilIni + "' and '" + cFilFim + "'"+CRLF
	EndIf

	cQuery += "   	and CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   	and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   	and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   	and CQ1_DATA   = "+CRLF
	cQuery += "   			("+CRLF
	cQuery += "   		select max(CQ1_DATA) "+CRLF
	cQuery += "   			from "+RetSqlName("CQ1")+" CQ11"+CRLF
	cQuery += "   		where CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   			and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   			and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
	cQuery += "   			and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
	cQuery += "   			)"+CRLF
	cQuery += "   	and CQ1_LP = "+CRLF
	cQuery += "   		( "+CRLF
	cQuery += "   		select max(CQ1_LP)"+CRLF
	cQuery += "   		from "+RetSqlName("CQ1")+" CQ11"+CRLF
	cQuery += "   		where "+CRLF
	If cFilIni == cFilFim
		cQuery += "   	CQ1_FILIAL = '" + cFilIni + "'  "+CRLF
	Else
		cQuery += "   	CQ1_FILIAL between '" + cFilIni + "' and '" + cFilFim + "'"+CRLF
	EndIf
	cQuery += "   		and CQ1_MOEDA  = '" + cMoeda + "'"+CRLF
	cQuery += "   		and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   		and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   		and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
	cQuery += "   		and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
	cQuery += "   		and CQ1_DATA   = "+CRLF
	cQuery += "   			("+CRLF
	cQuery += "   			select max(CQ1_DATA)"+CRLF
	cQuery += "   			from "+RetSqlName("CQ1")+" CQ12"+CRLF
	cQuery += "   			where "+CRLF
	If cFilIni == cFilFim
		cQuery += "   	CQ1_FILIAL = '" + cFilIni + "'  "+CRLF
	Else
		cQuery += "   	CQ1_FILIAL between '" + cFilIni + "' and '" + cFilFim + "'"+CRLF
	EndIf
	cQuery += "   			and CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   			and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   			and CQ11.CQ1_FILIAL=CQ12.CQ1_FILIAL"+CRLF
	cQuery += "   			and CQ11.CQ1_CONTA =CQ12.CQ1_CONTA  "+CRLF
	cQuery += "   			)"+CRLF
	cQuery += "   		)"+CRLF
	cQuery += "   	and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   group by CQ1_FILIAL,CQ1_CONTA,CQ1_DATA"+CRLF

	cQuery += "   UNION ALL"+CRLF

	cQuery += "   select "+CRLF
	cQuery += "   			CQ1_FILIAL,"+CRLF
	cQuery += "   			CQ1_CONTA, "+CRLF
	cQuery += "   			'' CQ1_DATA,"+CRLF
	cQuery += "   			SUM(CQ1_DEBITO) ANTDEB,"+CRLF
	cQuery += "   			SUM(CQ1_CREDIT) ANTCRD, "+CRLF
	cQuery += "   			0 DEBITO, "+CRLF
	cQuery += "   			0 CREDIT,"+CRLF
	cQuery += "   		   0 ATUDEB,"+CRLF
	cQuery += "   		   0 ATUCRD,"+CRLF
	cQuery += "   		   '1' FLAG"+CRLF
	cQuery += "   		FROM"+CRLF
	cQuery += "   			"+RetSqlName("CQ1")+" CQ1"+CRLF
	cQuery += "   		where "+CRLF
	If cFilIni == cFilFim
		cQuery += "   	CQ1_FILIAL = '" + cFilIni + "'  "+CRLF
	Else
		cQuery += "   	CQ1_FILIAL between '" + cFilIni + "' and '" + cFilFim + "'"+CRLF
	EndIf
	cQuery += "   			and CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   			and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   			and CQ1_DATA   < "+CRLF
	cQuery += "   					("+CRLF
	cQuery += "   				select max(CQ1_DATA)"+CRLF
	cQuery += "   					from "+RetSqlName("CQ1")+" CQ11"+CRLF
	cQuery += "   				where CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   					and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   					and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   					and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   					and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
	cQuery += "   					and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
	cQuery += "   					)"+CRLF
	cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   		group by CQ1_FILIAL,CQ1_CONTA"+CRLF
	cQuery += "   UNION ALL"+CRLF

	cQuery += "   select "+CRLF
	cQuery += "   			CQ1_FILIAL,"+CRLF
	cQuery += "   			CQ1_CONTA, "+CRLF
	cQuery += "   			'' CQ1_DATA,"+CRLF
	cQuery += "   			0 ANTDEB, "+CRLF
	cQuery += "   			0 ANTCRD, "+CRLF
	cQuery += "   			0 DEBITO, "+CRLF
	cQuery += "   			0 CREDIT,"+CRLF
	cQuery += "   			SUM(CQ1_DEBITO) ATUDEB,"+CRLF
	cQuery += "   			SUM(CQ1_CREDIT) ATUCRD,"+CRLF
	cQuery += "   			'2' FLAG"+CRLF
	cQuery += "   		FROM"+CRLF
	cQuery += "   			"+RetSqlName("CQ1")+" CQ1"+CRLF
	cQuery += "   		where "+CRLF
	If cFilIni == cFilFim
		cQuery += "   	CQ1_FILIAL = '" + cFilIni + "'  "+CRLF
	Else
		cQuery += "   	CQ1_FILIAL between '" + cFilIni + "' and '" + cFilFim + "'"+CRLF
	EndIf
	cQuery += "   			and CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   			and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   			and CQ1_DATA   <= "+CRLF
	cQuery += "   					("+CRLF
	cQuery += "   				select max(CQ1_DATA)"+CRLF
	cQuery += "   					from "+RetSqlName("CQ1")+" CQ11"+CRLF
	cQuery += "   				where CQ1_DATA <= '" + cData + "'"+CRLF
	cQuery += "   					and CQ1_MOEDA = '" + cMoeda + "'"+CRLF
	cQuery += "   					and CQ1_TPSALD = '1'"+CRLF
	cQuery += "   					and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   					and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
	cQuery += "   					and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
	cQuery += "   					)"+CRLF
	cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   		group by CQ1_FILIAL,CQ1_CONTA"+CRLF
	cQuery += "   ORDER BY CQ1_FILIAL,CQ1_CONTA ASC, FLAG DESC"+CRLF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrb)

	if (cTrb)->(!EOF())
		While (cTrb)->(!EOF())
			if empty(cCQ1FILIAL)
				cCQ1FILIAL	:= (cTrb)->CQ1_FILIAL
			endif
			if empty(cCQ1CONTA)
				cCQ1CONTA	:= (cTrb)->CQ1_CONTA
			endif
			if empty(cCQ1DATA)
				cCQ1DATA	:= (cTrb)->CQ1_DATA
			endif
			if nANTDEB = 0
				nANTDEB	:= (cTrb)->ANTDEB
			endif
			if nANTCRD = 0
				nANTCRD	:= (cTrb)->ANTCRD
			endif
			if nDEBITO = 0
				nDEBITO	:= (cTrb)->DEBITO
			endif
			if nCREDIT = 0
				nCREDIT	:= (cTrb)->CREDIT
			endif
			if nATUDEB = 0
				nATUDEB	:= (cTrb)->ATUDEB
			endif
			if nATUCRD = 0
				nATUCRD	:= (cTrb)->ATUCRD
			endif
			if (cTrb)->FLAG == '0'
				if !(cTrb)->(oBulkCTB:AddData({cCQ1FILIAL,cCQ1CONTA,cCQ1DATA,nANTDEB,nANTCRD,nDEBITO,nCREDIT,nATUDEB,nATUCRD,'0'}))
					UserException(oBulkCTB:GetError())
				endif
				nANTDEB := nANTCRD := nDEBITO := nCREDIT := nATUDEB := nATUCRD := 0
				cCQ1FILIAL := cCQ1CONTA := cCQ1DATA := ""
			endif
			(cTrb)->(dbskip())
		end
		If !oBulkCTB:Close()
			//- quebra a execução com erro, pois não atualizou o registro
			UserException(oBulkCTB:GetError())
		EndIF
	endif
	(cTrb)->(dbclosearea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CriaManad2 ³ Autor  ³ Alice Y. Yamamoto       ³ Data 31.05.7 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure para popular a tabela temporaria             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CriaManad2(cFilIni, cFilFim, cMoeda, cDataIni, cDataFim  )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Dados para a geracao do MANAD - REGISTRO I150                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cFilIni  - Filial Inicial                           ³±±
±±³           ³ ExpC2 = cFilFim  - Filial Final                             ³±±
±±³           ³ ExpC3 = cMoeda   - Moeda                                    ³±±
±±³           ³ ExpC4 = cDataIni - Perido Inicial para os movimentos        ³±±
±±³           ³ ExpC5 = cDataFim - Perido Final para os movimentos          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CriaManad2(cFilIni, cFilFim, cMoeda, cDataIni, cDataFim)
	Local cQuery   := ""

	cQuery +="   select '0' ZERADO, '[XDATAX]' CQ1_DATA, CQ1_CONTA, SUM(CQ1_DEBITO) CQ1_DEBITO, SUM(CQ1_CREDIT) CQ1_CREDIT"+CRLF
	cQuery +="     from "+RetSqlName("CQ1")+" CQ1"+CRLF
	If cFilIni ==cFilFim
		cQuery +="    where CQ1_FILIAL = ? "+CRLF
	Else
		cQuery +="    where CQ1_FILIAL between ? and ?"+CRLF
	EndIf
	If cDataIni == cDataFim
		cQuery +="      and CQ1_DATA = ? "+CRLF
	Else
		cQuery +="      and CQ1_DATA between ? and ? "+CRLF
	EndIf
	cQuery +="      and CQ1_MOEDA = ? "+CRLF
	cQuery +="      and CQ1_TPSALD = ? "+CRLF
	cQuery +="      AND D_E_L_E_T_ = ? "+CRLF
	cQuery +="      group by CQ1_CONTA"+CRLF

	cQuery +="   union"+CRLF

	cQuery +="   select '1' ZERADO, '[XDATAX]' CQ1_DATA, CT1_CONTA  CQ1_CONTA, 0 CQ1_DEBITO, 0 CQ1_CREDIT"+CRLF
	cQuery +="         from "+RetSqlName("CT1")+" CT1"+CRLF
	cQuery +="   where CT1_FILIAL  = '"+xFilial("CT1")+"'"+CRLF
	cQuery +="         and D_E_L_E_T_ = ? "+CRLF
	cQuery +="         and CT1_CLASSE = ? "+CRLF
	cQuery +="   and not exists"+CRLF
	cQuery +="    ( select CQ1_CONTA from "+RetSqlName("CQ1")+" CQ1"+CRLF
	If cFilIni == cFilFim
		cQuery +="          where CQ1_FILIAL = ? "+CRLF
	Else
		cQuery +="          where CQ1_FILIAL between ? and ? "+CRLF
	EndIf
	If cDataIni == cDataFim
		cQuery +="            and CQ1_DATA = ? "+CRLF
	Else
		cQuery +="            and CQ1_DATA between ? and ? "+CRLF
	EndIf
	cQuery +="            and CQ1_MOEDA = ? "+CRLF
	cQuery +="            and CQ1_TPSALD = ? "+CRLF
	If xFilial("CT1") = xFilial("CQ1")
		cQuery +="            AND CQ1.CQ1_FILIAL=CT1.CT1_FILIAL"+CRLF
	EndIf
	cQuery +="            and CQ1.CQ1_CONTA =CT1.CT1_CONTA "+CRLF
	cQuery +="            and D_E_L_E_T_ = ? "+CRLF
	cQuery +="      )"+CRLF
	cQuery +="   order by 3,2"+CRLF

Return( cQuery )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CHKDTEXIST  ³ Autor ³ Davi Torchio            ³ Data ³ 15/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a data de existencia da conta para estar criando       ³±±
±±³          ³ o saldo do Registro I150 no manad.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CHKDTEXIST()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ CARACTER                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConta - Conta do arquivo temporario AT7.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function CHKDTEXIST (cConta)

	Local cDataStr := ""

	Default cConta := ""

	If ! Empty( cConta )
		DbSelectArea("CT1")
		If DbSeek(xFilial()+cConta)
			cDataStr := DTOS(CT1->CT1_DTEXIS)
		Endif
	Endif

Return cDataStr

