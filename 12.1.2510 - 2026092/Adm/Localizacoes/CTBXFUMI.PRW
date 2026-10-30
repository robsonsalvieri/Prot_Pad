#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"

Static lChkLxProp := FindFunction("ChkLxProp")

/*/{Protheus.doc} DtMoeAstMI
	Obtiene Fecha de conversión a mostrar en ventana de poliza
	@type  Function
	@author oscar.lopez
	@since 22/08/2022
	@version 1.0
	@param dFechaTx, fecha, Fecha a mostrar en campos CT2_DTTX** al cargar ventana de poliza
	@return lRet, logico, Verdadero/Falso si se debe actualizar la fecha
	@example
		DtMoeAstMI(@dFechaTx)
	/*/
Function DtMoeAstMI(dFechaTx)
	Local lRet		:= .F.
	Local aArea		:= GetArea()

	If FunName() $ "MATA101N" .Or. (lChkLxProp .and. ChkLxProp("ObtieneFechaPoliza"))
		DbSelectArea("SF1")
		If SF1->(!EoF())
			dFechaTx := SF1->F1_EMISSAO
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DtMoeComMI
	Obtiene fecha de tasa para asiento complementario a partir de asiento origen en misma moneda.
	@type  Function
	@author oscar.lopez
	@since 22/08/2022
	@version 1.0
	@param cMoneda, caracter, Moneda del movimiento origen
	@param dFechaTx, fecha, Fecha de conversion de la moneda
	@param lActFch, logico, Verdadero/Falso si existe registro de asiento origen en moneda indicada
	@example
		DtMoeComMI(cMoneda, @dFechaTx, @lActFch)
	/*/
Function DtMoeComMI(cMoneda, dFechaTx, lActFch)
	Local aArea		:= GetArea()
	Local aAreaCT2	:= CT2->(GetArea())
	Local cChave	:= ""

	dFechaTx	:= CToD("  /  /  ")
	lActFch		:= .F.

	DbSelectArea("CT2")
	CT2->(DbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
	If CT2->(!EoF())
		cChave := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI)+cMoneda
		If CT2->(MsSeek(cChave)) .And. !Empty(CT2_DATATX)
			dFechaTx	:= CT2->CT2_DATATX
			lActFch		:= .T.
		EndIf
	EndIf
	RestArea(aAreaCT2)
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FinGetDateNum
   Obtiene la numeración de la conciliación por mes y por los filtros del Banco.
   Funcion utilizada en backoffice.reconciliation.matchreconciliate.data.protheus.tlpp
   	@type  Function
    @author Alfredo Medrano
    @since 03/05/2026
    @version 12.1.2510
    @param cCodCfg, Character, Código do processo de conciliación
    @param oProfile, Objeto, Objeto que contiene el perfil del usuario y los filtros aplicados.
	@country ARG
	@see backoffice.reconciliation.matchreconciliate.data.protheus.tlpp 
/*/
//-------------------------------------------------------------------

Function FinGetDateNum(cCodCfg,oProfile)

	Local cQuery        := "" 
	Local cConciliation := "" 
	Local cAliasQLC     := "" 
	Local dIniDate      := STOD("")
	Local dFinDate      := STOD("")
	Local oFilter       := JsonObject():new()
	Local oFilout      	:= JsonObject():new()
	Local oExecImp      := Nil
	Local aFilter       := {}
	Local nParam        := 1
	Local uRet          := Nil
	Local aTabOrig      := {}
	Local aTabComp      := {}
	Local cFechaIni     := "" 
	Local cFechaFin     := "" 
	Local cBanco        := ""
	Local cAgencia      := "" 
	Local cCuenta       := "" 
	Local lRet			:= .F.

	Default cCodCfg  := ""
	Default oProfile := Nil

	If oProfile != Nil
		aFilter := oProfile:getProfile(cCodCfg) // Extrae el filtro de la conciliación
		If Len(aFilter) > 0 .And. aFilter[1]
			uRet := oFilter:fromJson(aFilter[2][1])
			If ValType(uRet) == "U"
				aTabOrig := oFilter["tabori"] // Extrae el contenido de tabori, fecha Inicial y final, y datos del banco.
				IF Len(aTabOrig) >= 5
					cFechaIni 	:= aTabOrig[1]["value"]
					cFechaFin 	:= aTabOrig[2]["value"]
					cBanco		:= aTabOrig[3]["value"]
					cAgencia 	:= aTabOrig[4]["value"]
					cCuenta 	:= aTabOrig[5]["value"]
				EndIf
			EndIf
		EndIf
	EndIf

	IF !Empty(cFechaIni) .And. !Empty(cFechaFin) .And. !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cCuenta)

		dIniDate := FirstDate(dDataBase) // primer día del mes
		dFinDate := LastDate(dDataBase) // úlltimo día del mes
		//Consulta sessao do usuario na tabela QLC
		cQuery := "SELECT QLC_CODCON, QLC_CODCFG, QLC_FILTER"
		cQuery += " FROM " + RetSQLName("QLC")
		cQuery += " WHERE QLC_FILIAL = ? "
		cQuery += " AND QLC_CODCFG = ? "
		cQuery += " AND QLC_DATCON >= ? "
		cQuery += " AND QLC_DATCON <= ? "
		cQuery += " AND D_E_L_E_T_ = ?"

		cQuery := ChangeQuery(cQuery)
		oExecImp := FwExecStatement():New( cQuery )

		oExecImp:SetString( nParam++, xFilial("QLC"))	// QLC_FILIAL =
		oExecImp:SetString( nParam++, cCodCfg )         // QLC_CODCFG
		oExecImp:setDate( nParam++, dIniDate ) 			// QLC_DATCON >=
		oExecImp:setDate( nParam++, dFinDate )			// QLC_DATCON <=
		oExecImp:SetString( nParam++, '' )				// D_E_L_E_T_ =
		
		cAliasQLC := oExecImp:OpenAlias() 

		If !Empty(cAliasQLC) .And. Select(cAliasQLC) > 0

			While (cAliasQLC)->(!EOF()) 
				lRet := .F.
				If !Empty((cAliasQLC)->QLC_CODCON)  .And. !Empty((cAliasQLC)->QLC_FILTER)
					uRet := oFilout:fromJson((cAliasQLC)->QLC_FILTER)
					If ValType(uRet) == "U"
						aTabComp := oFilout["tabori"]
						IF Len(aTabComp) >= 5
							IF Substr(aTabComp[1]["value"],1,7) == Substr(cFechaIni,1,7) ;
								.And. Substr(aTabComp[2]["value"],1,7) == Substr(cFechaFin,1,7) ;
								.And. aTabComp[3]["value"] == cBanco ;
								.And. aTabComp[4]["value"] == cAgencia ;
								.And. aTabComp[5]["value"] == cCuenta
								lRet := .T.
							EndIf
						Endif
					EndIf
				EndIf
				If lRet
					cConciliation := (cAliasQLC)->QLC_CODCON
					Exit
				Endif	
				(cAliasQLC)->(dbSkip())
			EndDo
			(cAliasQLC)->(dbCloseArea()) //Fecha temporario
		EndiF
		
		If oExecImp <> Nil
			oExecImp:Destroy()
			oExecImp := Nil
		EndIf
	EndIf

Return cConciliation

