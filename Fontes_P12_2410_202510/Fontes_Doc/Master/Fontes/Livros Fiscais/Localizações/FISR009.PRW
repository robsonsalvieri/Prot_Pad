#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR009.CH"

/*/{Protheus.doc} FR009Qry
Generación de archivo plano de libro 9.1 Registro de consignaciones – para el consignador localización Perú
@type funcion
@author oscar.lopez
@since 10/10/2023
@version 1.0
@param 
@return Nil
@example
	FISR009()
/*/
Function FISR009()
	Local cPerg		:= "FISR009"
	Local cTRem		:= ""
	Local nTotItms	:= 0
	Local nRegFil	:= 0
	Local nRegTot	:= 0
	Local nHdl		:= 0
	Local nItera	:= 0
	Local nCont		:= 0
	Local cResFil	:= cFilAnt
	Local cDir		:= ""
	Local cArq		:= ""
	Local cSaltLin	:= chr(13)+chr(10) // Salto de línea
	Local cMsg		:= ""
	Local cMsgErr	:= ""
	Local lLinError	:= .F.
	Local nLinError	:= 0
	Local cFilDoc	:= ""
	Local cSerDoc	:= ""
	Local cNumDoc	:= ""
	Local cProDoc	:= ""
	Local cTipDoc	:= ""
	Local cQuery	:= ""
	Local lCreaArq	:= .F.
	Local aSelFil	:= {}
	Local aTotCan	:= {0,0,0}
	Local lAuto		:= IsBlind()

	If lAuto .Or. Pergunte(cPerg, .T.)
		cDir := AllTrim(MV_PAR04)
		
		If MV_PAR03 == 1
			aSelFil := AdmGetFil()	// Llama a la pantalla de seleccion de filiales
		Else
			aSelFil := {cFilAnt}
		EndIf

		If Empty(cDir)
			cMsgErr := STR0002 // "No se ha informado un directorio valido."
		EndIf

		cDir += IIf(SubStr(cDir,Len(cDir)) == "\","", "\")

		If !Empty(aSelFil) .And. Empty(cMsgErr)
			For nCont := Len(AllTrim(cDir)) To 1 Step -1
				If SubStr(cDir,nCont,1) == '\'
					cDir:=Substr(cDir, 1, nCont)
					Exit
				EndIf
			Next

			For nItera := 1 To Len(aSelFil)
				cTRem := GetNextAlias()
				cQuery := FR009Qry(aSelFil[nItera])
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRem,.T.,.T.)

				(cTRem)->(DbGoTop())
				Count to nRegFil
				If !lCreaArq .And. (nRegFil > 0 .Or. nItera == Len(aSelFil))
					nRegTot += nRegFil

					// Nombre de archivo TXT a ser creado
					cArq := "LE"								// (01-02) Fijo 'LE'
					cArq += AllTrim(SM0->M0_CGC)				// (03-13) Ruc
					cArq += AllTrim(Str(Year(MV_PAR01)))		// (14-17) Año
					cArq += AllTrim(Strzero(Month(MV_PAR01),2))	// (18-19) Mes
					cArq += "00"								// (20-21) Fijo '00'
					cArq += "090100"							// (22-27) Fijo '090100'
					cArq += "00"								// (28-29) Fijo '00'
					cArq += "1"									// (30-30) Indicador de operaciones 1 - Empresa o entidad operativa
					cArq += IIf(nRegTot==0,"0","1")				// (31-31) Si se encuentran registros añade '1', si no entonces '0'
					cArq += "1"									// (32-32) Indicador de la moneda utilizada
					cArq += "1"									// (33-33) Indicador de libro electrónico generado por el PLE (Fijo)
					cArq += ".TXT"								// Extensión

					nHdl := fCreate(cDir+UPPER(cArq),Nil,Nil,.F.)
					lCreaArq := (nHdl > 0)
					If !lCreaArq
						cMsgErr := STR0003 // "Ha ocurrido un error al crear el archivo. Intente nuevamente."
						(cTRem)->(DbCloseArea())
						Exit
					EndIf
				EndIf

				(cTRem)->(DbGoTop())
				While (cTRem)->(!EoF())
					nContador := 1
					cFilDoc	:= (cTRem)->FILIAL
					cSerDoc	:= (cTRem)->SERIE
					cNumDoc	:= (cTRem)->NUMDOCITM
					cTipDoc	:= (cTRem)->TIPODOC
					cProDoc	:= (cTRem)->PRODUCTO
					cLin	:= ""
					aTotCan	:= {0,0,0}
					nTotItms++
					lLinError := .F.
					While (cTRem)->FILIAL == cFilDoc .And. (cTRem)->SERIE == cSerDoc .And. (cTRem)->NUMDOCITM == cNumDoc .And.;
							(cTRem)->TIPODOC == cTipDoc .And. (cTRem)->PRODUCTO == cProDoc
						cTotales := ""
						lCreaReg := (nContador == 1)
						GerArq(cTRem, @lLinError, lCreaReg, aTotCan, @cLin, @cTotales)
						IIf(lLinError, nLinError++, .T.)
						(cTRem)->(DbSkip())
						nContador++
					EndDo
					cLin += cTotales + cSaltLin
					fWrite(nHdl,cLin)
				EndDo
				(cTRem)->(DbCloseArea())
			Next nItera

			fClose(nHdl)

			If Empty(cMsgErr) .And. !lAuto
				cMsg += STR0004 + cArq + STR0005 + cSaltLin // "Archivo " ## " generado exitosamente."
				cMsg += STR0006 + AllTrim(Str(nTotItms))+cSaltLin // "Total registros: "
				cMsg += STR0007 + AllTrim(Str(nTotItms-nLinError))+cSaltLin // "Registros correctos: "
				cMsg += STR0008 + AllTrim(Str(nLinError)) // "Registros con errores: "
				MsgAlert(cMsg)
			EndIf

		EndIf

		If !Empty(cMsgErr) .And. !lAuto
			MsgStop(cMsgErr)
		EndIf

		ConOut(IIf(!Empty(cMsgErr), cMsgErr, cMsg))

	EndIf

	cFilAnt := cResFil

Return

/*/{Protheus.doc} FR009Qry
Creación de consulta para obtener ítems de sucursal proporcionada.
@type funcion
@author oscar.lopez
@since 10/10/2023
@version 1.0
@param cFilCons, caracter, Codigo de Sucursal para actualizar cFilAnt antes de armar consulta.
@return cQuery, caracter, Consulta generada para la filial proporcionada.
@example
	FR009Qry(cFilCons)
/*/
Function FR009Qry(cFilCons)
	Local cFilSF1	:= ""
	Local cFilSD1	:= ""
	Local cFilSF2	:= ""
	Local cFilSD2	:= ""
	Local cFilSB1	:= ""
	Local cFilSA1	:= ""
	Local cFilSAH	:= ""
	Local cQuery	:= ""
	Local aCposQry	:= {}

					// RFN/NF		// NCC			// Alias	// Incluye en Group By
	Aadd(aCposQry,{"SF2.F2_NODIA"	,"SF1.F1_NODIA"	,"NODIA"	,.T.})
	Aadd(aCposQry,{"SF2.F2_SERIE2"	,"SF1.F1_SERIE2","SERIE2"	,.T.})
	Aadd(aCposQry,{"D2_FILIAL"		,"D1_FILIAL"	,"FILIAL"	,.T.})
	Aadd(aCposQry,{"D2_CLIENTE"		,"D1_FORNECE"	,"CLIFOR"	,.T.})
	Aadd(aCposQry,{"D2_LOJA"		,"D1_LOJA"		,"LOJA"		,.T.})
	Aadd(aCposQry,{"D2_COD"			,"D1_COD"		,"PRODUCTO"	,.T.})
	Aadd(aCposQry,{"D2_EMISSAO"		,"D1_EMISSAO"	,"EMISSAO"	,.T.})
	Aadd(aCposQry,{"D2_ESPECIE"		,"D1_ESPECIE"	,"TIPODOC"	,.T.})
	Aadd(aCposQry,{"D2_DOC"			,"D1_DOC"		,"NUMDOCITM",.T.})
	Aadd(aCposQry,{"D2_SERIE"		,"D1_SERIE"		,"SERIE"	,.T.})
	Aadd(aCposQry,{"D2_UM"			,"D1_UM"		,"UM"		,.T.})
	Aadd(aCposQry,{"D2_DTDIGIT"		,"D1_DTDIGIT"	,"DTDIGIT"	,.T.})
	Aadd(aCposQry,{"D2_ITEM"		,"D1_ITEM"		,"XITEM"	,.T.})
	Aadd(aCposQry,{"sum(D2_QUANT)"	,"sum(D1_QUANT)","QUANT"	,.F.})
	Aadd(aCposQry,{"B1_PRODSAT"		,"B1_PRODSAT"	,"PRODSAT"	,.T.})
	Aadd(aCposQry,{"B1_CODBAR"		,"B1_CODBAR"	,"CODBAR"	,.T.})
	Aadd(aCposQry,{"B1_TIPOEX"		,"B1_TIPOEX"	,"TPEXIST"	,.T.})
	Aadd(aCposQry,{"B1_DESC"		,"B1_DESC"		,"DSCPROD"	,.T.})
	Aadd(aCposQry,{"AH_UNIMED"		,"AH_UNIMED"	,"UNIMED"	,.T.})
	Aadd(aCposQry,{"AH_CODERP"		,"AH_CODERP"	,"UNMEDERP"	,.T.})
	Aadd(aCposQry,{"A1_TIPO"		,"A1_TIPO"		,"TIPOCLI"	,.T.})
	Aadd(aCposQry,{"A1_TIPDOC"		,"A1_TIPDOC"	,"CPTIPDOC"	,.T.})
	Aadd(aCposQry,{"A1_NOME"		,"A1_NOME"		,"CPNOMBRE"	,.T.})
	Aadd(aCposQry,{"A1_CGC"			,"A1_CGC"		,"CPCGC"	,.T.})
	Aadd(aCposQry,{"A1_PFISICA"		,"A1_PFISICA"	,"CPPFIS"	,.T.})
	Aadd(aCposQry,{"SF2R.F2_DOC"	,"SF2R.F2_DOC"	,"NREM"		,.T.})
	Aadd(aCposQry,{"SF2R.F2_SERIE2"	,"SF2R.F2_SERIE2","S2REM"	,.T.})
	
	cFilAnt	:= cFilCons

	cFilSF1 := xFilial("SF1")
	cFilSD1 := xFilial("SD1")
	cFilSF2 := xFilial("SF2")
	cFilSD2 := xFilial("SD2")
	cFilSB1 := xFilial("SB1")
	cFilSA1 := xFilial("SA1")
	cFilSAH := xFilial("SAH")

	// RFN
	cQuery += " SELECT"
	cQuery += " '1' TIPO"
	AEval(aCposQry, {|x| cQuery += ", " + IIf(x[3]$"NREM|S2REM","''",x[1]) + " " + x[3]})
	cQuery += " FROM"
	cQuery += " "+RetSqlName("SF2")+" SF2"
	cQuery += " ,"+RetSqlName("SB1")+" SB1"
	cQuery += " ,"+RetSqlName("SAH")+" SAH"
	cQuery += " ,"+RetSqlName("SA1")+" SA1"
	cQuery += " ,"+RetSqlName("SD2")+" SD2"
	cQuery += " WHERE"
	cQuery += " SF2.F2_EMISSAO >= '"+Dtos(MV_PAR01)+"'"
	cQuery += " AND SF2.F2_EMISSAO <= '"+Dtos(MV_PAR02)+"'"
	cQuery += " AND SF2.F2_FILIAL = SD2.D2_FILIAL"
	cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE"
	cQuery += " AND SF2.F2_DOC = SD2.D2_DOC"
	cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE"
	cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA"
	cQuery += " AND SF2.F2_ESPECIE = 'RFN'"
	cQuery += " AND SF2.F2_TIPODOC = '50'"
	cQuery += " AND SF2.F2_TIPOREM = 'A'"
	cQuery += " AND SD2.D2_FILIAL = '"+cFilSD2+"'"
	cQuery += " AND SAH.AH_UNIMED = SD2.D2_UM"
	cQuery += " AND SB1.B1_COD = SD2.D2_COD"
	cQuery += " AND SA1.A1_COD = SF2.F2_CLIENTE"
	cQuery += " AND SA1.A1_LOJA = SF2.F2_LOJA"
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY"
	cQuery += " D2_FILIAL"
	AEval(aCposQry, {|x| IIf(x[4], cQuery += IIf(x[3]$"NREM|S2REM","",", " + x[1]),) })
	
	// NF
	cQuery += " UNION"
	cQuery += " SELECT"
	cQuery += " '2' TIPO"
	AEval(aCposQry, {|x| cQuery += ", " + x[1] + " " + x[3]})
	cQuery += " FROM"
	cQuery += " "+RetSqlName("SF2")+" SF2"
	cQuery += " ,"+RetSqlName("SB1")+" SB1"
	cQuery += " ,"+RetSqlName("SAH")+" SAH"
	cQuery += " ,"+RetSqlName("SA1")+" SA1"
	cQuery += " ,"+RetSqlName("SD2")+" SD2"
	cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2R ON"
	cQuery += " SF2R.F2_FILIAL = SD2.D2_FILIAL"
	cQuery += " AND SF2R.F2_SERIE = SD2.D2_SERIREM"
	cQuery += " AND SF2R.F2_DOC = SD2.D2_REMITO"
	cQuery += " AND SF2R.F2_TIPODOC = '50'"
	cQuery += " AND SF2R.F2_TIPOREM = 'A'"
	cQuery += " AND SF2R.D_E_L_E_T_ = ' '"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " WHERE"
	cQuery += " SF2.F2_EMISSAO >= '"+Dtos(MV_PAR01)+"'"
	cQuery += " AND SF2.F2_EMISSAO <= '"+Dtos(MV_PAR02)+"'"
	cQuery += " AND SF2.F2_FILIAL = SD2.D2_FILIAL"
	cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE"
	cQuery += " AND SF2.F2_DOC = SD2.D2_DOC"
	cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE"
	cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA"
	cQuery += " AND SF2.F2_ESPECIE = 'NF '"
	cQuery += " AND SF2.F2_TIPODOC = '01'"
	cQuery += " AND SF2.F2_ESPECIE = SD2.D2_ESPECIE"
	cQuery += " AND SD2.D2_FILIAL = '"+cFilSD2+"'"
	cQuery += " AND SAH.AH_UNIMED = SD2.D2_UM"
	cQuery += " AND SB1.B1_COD = SD2.D2_COD"
	cQuery += " AND SA1.A1_COD = SF2.F2_CLIENTE"
	cQuery += " AND SA1.A1_LOJA = SF2.F2_LOJA"
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY"
	cQuery += " D2_FILIAL"
	AEval(aCposQry, {|x| IIf(x[4], cQuery += ", " + x[1],) })

	// NCC
	cQuery += " UNION"
	cQuery += " SELECT"
	cQuery += " '2' TIPO"
	AEval(aCposQry, {|x| cQuery += ", " + x[2] + " " + x[3]})
	cQuery += " FROM"
	cQuery += " "+RetSqlName("SF2")+" SF2"
	cQuery += " ,"+RetSqlName("SF1")+" SF1"
	cQuery += " ,"+RetSqlName("SD1")+" SD1"
	cQuery += " ,"+RetSqlName("SB1")+" SB1"
	cQuery += " ,"+RetSqlName("SAH")+" SAH"
	cQuery += " ,"+RetSqlName("SA1")+" SA1"
	cQuery += " ,"+RetSqlName("SD2")+" SD2"
	cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2R ON"
	cQuery += " SF2R.F2_FILIAL = SD2.D2_FILIAL"
	cQuery += " AND SF2R.F2_SERIE = SD2.D2_SERIREM"
	cQuery += " AND SF2R.F2_DOC = SD2.D2_REMITO"
	cQuery += " AND SF2R.F2_TIPODOC = '50'"
	cQuery += " AND SF2R.F2_TIPOREM = 'A'"
	cQuery += " AND SF2R.D_E_L_E_T_ = ' '"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " WHERE"
	cQuery += " SF2.F2_FILIAL = SD2.D2_FILIAL"
	cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE"
	cQuery += " AND SF2.F2_DOC = SD2.D2_DOC"
	cQuery += " AND SD2.D2_REMITO > ' '"
	cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE"
	cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA"
	cQuery += " AND SD2.D2_UM = SAH.AH_UNIMED"
	cQuery += " AND SD2.D2_COD = SB1.B1_COD"
	cQuery += " AND SF2.F2_CLIENTE = SA1.A1_COD"
	cQuery += " AND SF2.F2_LOJA = SA1.A1_LOJA"
	cQuery += " AND SD2.D2_ESPECIE = 'NF '"
	cQuery += " AND SF2.F2_ESPECIE = SD2.D2_ESPECIE"
	cQuery += " AND SF1.F1_FILIAL = SD1.D1_FILIAL"
	cQuery += " AND SF1.F1_DOC = SD1.D1_DOC"
	cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE"
	cQuery += " AND SF1.F1_ESPECIE = SD1.D1_ESPECIE"
	cQuery += " AND SF1.F1_ESPECIE = 'NCC'"
	cQuery += " AND SF1.F1_TIPODOC = '04'"
	cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE"
	cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA"
	cQuery += " AND SD1.D1_FILIAL = '"+cFilSD1+"'"
	cQuery += " AND SD1.D1_NFORI = SF2.F2_DOC"
	cQuery += " AND SD1.D1_SERIORI = SF2.F2_SERIE"
	cQuery += " AND SD1.D1_NFORI > ' '"
	cQuery += " AND SF1.F1_EMISSAO >= '"+Dtos(MV_PAR01)+"'"
	cQuery += " AND SF1.F1_EMISSAO <= '"+Dtos(MV_PAR02)+"'"
	cQuery += " AND SAH.AH_UNIMED = SD1.D1_UM"
	cQuery += " AND SB1.B1_COD = SD1.D1_COD"
	cQuery += " AND SA1.A1_COD = SD1.D1_FORNECE"
	cQuery += " AND SA1.A1_LOJA = SD1.D1_LOJA"
	cQuery += " AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"
	cQuery += " AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY"
	cQuery += " D1_FILIAL"
	AEval(aCposQry, {|x| IIf(x[4], cQuery += ", " + x[2],) })

	cQuery += " ORDER BY"
	cQuery += " FILIAL"	
	cQuery += " ,EMISSAO"

Return cQuery

/*/{Protheus.doc} GerArq
Creación de registro que será añadido al archivo TXT.
@type funcion
@author oscar.lopez
@since 10/10/2023
@version 1.0
@param cTab, caracter, Nombre de tabla con ítems encontrados en filial.
@param nLinEr, numero, Si se encuentra que falta algun dato obligatorio se actualiza Verdadero, de lo contrario permanece Falso.
@param lCreaReg, lógico, Verdader si es un nuevo registro, Falso si es el mismo item y solo sumar valor en aCant.
@param aCant, arreglo, Arreglo que acumula el valor total para NF, NCC o RFN si existe en más de un item de mismo documento.
@param cLin, caracter, Información de ítem que será agregado a archivo TXT
@param cLinTot, caracter, Información del valor acumulado en aCant que será agregado a cLin antes de añadir a TXT
@return Nil
@example
	GerArq(cTab, nLinEr, lCreaReg, aCant, cLin, cLinTot)
/*/
Static Function GerArq(cTab, nLinEr, lCreaReg, aCant, cLin, cLinTot)
	Local cSep		:= "|"
	Local lUsaTsx5	:= SuperGetMv("MV_USATSX5" ,.F.,.F.)
	Local aConSX5	:= {}
	Local cExisten	:= ""
	Local cTpComp	:= "00"
	Local cTpDoc	:= ""
	Local cCodCat	:= ""
	Local cCodExis	:= ""
	Local cNumDocID	:= ""
	Local cSerRem	:= ""
	Local cNumRem	:= ""
	Local cPictQ	:= "@E 999999999999.99"
	Local cFchEmi	:= AllTrim(StrZero(Day(SToD((cTab)->EMISSAO)),2)) + "/" + AllTrim(StrZero(Month(SToD((cTab)->EMISSAO)),2));
						+ "/" + AllTrim(Str(Year(SToD((cTab)->EMISSAO))))

	If lCreaReg
		// 01 - Periodo
		cLin += AllTrim(Str(Year(SToD((cTab)->EMISSAO)))) + AllTrim(Strzero(Month(SToD((cTab)->EMISSAO)),2)) + "00"
		cLin += cSep

		// 02 - Cod. Catalogo
		If RTrim((cTab)->PRODUCTO) == RTrim((cTab)->PRODSAT)
			cCodCat := "1"
		ElseIf RTrim((cTab)->PRODUCTO) == RTrim((cTab)->CODBAR)
			cCodCat := "3"
		Else
			cCodCat := "9"
		EndIf
		cLin += cCodCat
		cLin += cSep

		// 03 - Tipo de existencia
		cLin += AllTrim((cTab)->TPEXIST)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty((cTab)->TPEXIST), nLinEr)

		//04 - Codigo de la existencia
		If cCodCat == "1"
			cCodExis += (cTab)->PRODSAT
		ElseIf cCodCat == "3"
			cCodExis += (cTab)->CODBAR
		Else
			cCodExis += (cTab)->PRODUCTO
		EndIf
		cLin += Right(AllTrim(cCodExis),24)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty(cCodExis), nLinEr)

		// 05 - CUO / RER
		cLin += Right(RTrim((cTab)->NODIA), 40)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty((cTab)->NODIA), nLinEr)

		// 06 - Nombre existencia
		If lUsaTsx5
			aConSX5 := FWGetSX5( "P7",(cTab)->TPEXIST,"ES" )
			cExisten := Trim(aConSX5[1,4])
		Else
			cExisten := Trim(Substr((cTab)->DSCPROD,1,80))
		EndIf
		cLin += cExisten
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty(cExisten), nLinEr)

		// 07 - Cod. UM
		cLin += AllTrim((cTab)->UNMEDERP)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty((cTab)->UNMEDERP), nLinEr)

		// 08 - Fecha emision
		cLin += cFchEmi
		cLin += cSep

		// 09 - Serie guia remision
		cTpDoc := AllTrim((cTab)->TIPODOC)
		cSerRem := IIf(cTpDoc $ "RFN", (cTab)->SERIE2, (cTab)->S2REM)
		cLin += RTrim(cSerRem)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty(cSerRem), nLinEr)

		// 10 - Num. Guia de remisión
		cNumRem := IIf(cTpDoc $ "RFN", (cTab)->NUMDOCITM, (cTab)->NREM)
		cLin += Right(AllTrim(cNumRem),20)
		cLin += cSep
		nLinEr := IIf(!nLinEr, Empty(cNumRem), nLinEr)

		// 11 - Tipo de comprobate de pago
		If cTpDoc == 'NF'
			cTpComp := "01"
		ElseIf cTpDoc == 'NCC'
			cTpComp := "07"
		ElseIf cTpDoc == 'RFN'
			cTpComp := "09"
		EndIf
		cLin += cTpComp
		cLin += cSep

		// 12 - Fch. emision comprobante emitido por consignador
		cLin += cFchEmi
		cLin += cSep

		// 13 - Serie comprobante de pago emitido por el consignador
		cLin += IIf(!Empty((cTab)->SERIE2), RTrim((cTab)->SERIE2), "0000")
		cLin += cSep

		// 14 - Numero de comprobante de pago emitido por el consignador
		cLin += Right(AllTrim((cTab)->NUMDOCITM),IIf(cTpComp$"01|07",8, 20))
		cLin += cSep

		// 15 - Fecha de entrega o devolucion del bien
		If !(cTpComp == "00")
			cLin += cFchEmi
		EndIf
		cLin += cSep

		// 16 - Tipo de documento de identidad del consignatario
		cLin += AllTrim((cTab)->CPTIPDOC)
		cLin += cSep

		// 17 - Numero RUC consignatario o documento identidad
		If (cTab)->TIPOCLI == "1"
			cNumDocID := (cTab)->CPCGC //Persona Juridica
		ElseIf (cTab)->TIPOCLI == "2"
			cNumDocID := (cTab)->CPPFIS //Persona Natural
		EndIf
		cLin += Right(AllTrim(cNumDocID),15)
		cLin += cSep

		// 18 - Nombre, denominacion o razon social consignatario
		cLin += Right(AllTrim((cTab)->CPNOMBRE),100)
		cLin += cSep
	EndIf

	// 19 - Ctd. bienes entregados
	aCant[1] += IIf(cTpComp == "09", (cTab)->QUANT, 0.00)
	cLinTot +=  AllTrim(StrTran(Transform(aCant[1],cPictQ),",","."))
	cLinTot += cSep

	// 20 - Cantidad de bienes devueltos por el consignatario
	aCant[2] += IIf(cTpComp == "07", (cTab)->QUANT * -1, 0.00)
	cLinTot +=  AllTrim(StrTran(Transform(aCant[2],cPictQ),",","."))
	cLinTot += cSep

	// 21 - Cantidad de bienes vendidos
	aCant[3] += IIf(cTpComp == "01", (cTab)->QUANT * -1, 0.00)
	cLinTot +=  AllTrim(StrTran(Transform(aCant[3],cPictQ),",","."))
	cLinTot += cSep

	// 22 - Estado de la operacion
	cLinTot += "1"
	cLinTot += cSep

Return Nil

