#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FINA474MI.CH"

Static cArqEnt	:= ""

/*/{Protheus.doc} FINA474MI
	Importación de movimientos de extracto bancario.
	Ejecución desde MILE (CFGA600).
	Usa funcionalidad de Mantenimiento de Extractos (FINA474).
	@type  Function
	@author ARodriguez
	@since 07/11/2025
	@version >= 12.1.2410
	@param aParam1, array, datos del banco
	@param aParam2, array, movimientos
	@return nil, nil, nil
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FINA474MI(aParam1, aParam2)
	Local aConfig1	:= {}
	Local aConfig2	:= {}
	Local cBanco	:= ""
	Local cAgencia	:= ""
	Local cConta	:= ""
	Local cSubCta	:= "" 
	Local cDesc		:= "" 
	Local cBcoMov	:= ""
	Local cAgeMov	:= ""
	Local cCtaMov	:= ""
	Local dDataMov	:= CtoD("")
	Local cNumMov	:= ""
	Local nValorMov	:= 0
	Local cCodMov	:= ""
	Local cDescrMov	:= ""
	Local cTipoMov	:= ""
	Local cDescMov	:= ""
	Local cDebCred	:= ""
	Local cIdProc	:= ""
	Local cItem		:= ""
	Local cChkSum	:= ""
	Local lGravaSIF	:= .T.
	Local lTemLacto	:= .F.
	Local lRet		:= .F.
	Local nContReg	:= 0
	Local nLinha	:= 0
	Local nCampo	:= 0
	Local nX		:= 0
	Local aLog		:= {}
	Local aLogLanc	:= {}
	Local cDescFail	:= ""
	Local cFailSIF	:= ""

	Default aParam1	:= {}
	Default aParam2	:= {}

	If Len(aParam2) > 0
		lRet := .T.
	EndIf

	cIdProc := F474ProxNum("SIF")
	cItem	:= Replicate("0", GetSx3Cache("IG_ITEM", "X3_TAMANHO"))
	
	If !Empty(cArqEnt)
		cChkSum := F474VLDARQ(cArqEnt)

		If Empty(cChkSum)
			aAdd(aLog,{0 , OemToAnsi(STR0002)}) //"Archivo de Extracto ya importado."
			lRet := .F.
		EndIf

	Else
		aAdd(aLog,{0 , OemToAnsi(STR0020)}) //"Archivo de Extracto no identificado, debe configurar la función 'F474MIPar' en el campo 'Valid. Operación' del layout de MILE."
		lRet := .F.

	EndIf

	Pergunte("FINA474MI", .F.)
	cBanco := MV_PAR01
	cAgencia := MV_PAR02
	cConta := MV_PAR03
	cSubCta := MV_PAR04
	cDesc := MV_PAR05

	aConfig1 := {cIdProc, cBanco, cAgencia, cConta, cSubCta, cDesc}
	aConfig2 := {"", cArqEnt}

	If lRet

		SA6->(dbSetOrder(1))	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		SEE->(dbSetOrder(1))	//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		SEJ->(dbSetOrder(1))	//EJ_FILIAL+EJ_BANCO+EJ_OCORBCO

		// Banco
		For nLinha := 1 to Len(aParam1)
			If Trim(aParam1[nLinha][1]) == "IG_BCOEXT"
				cBcoMov := aParam1[nLinha][2]
			ElseIf Trim(aParam1[nLinha][1]) == "IG_AGEEXT"
				cAgeMov := aParam1[nLinha][2]
			ElseIf Trim(aParam1[nLinha][1]) == "IG_CONEXT"
				cCtaMov := aParam1[nLinha][2]
			EndIf
		Next nLinha

		// validar banco
		If !Empty(cBanco) .And. Empty(cBcoMov)
			// Datos del banco en el grupo de preguntas
			lRet := .T. // No es necesario, solo para evitar observación en CR

		ElseIf Empty(cBanco) .And. !Empty(cBcoMov)
			// Datos del banco en el extracto
			cBanco := cBcoMov
			cAgencia := cAgeMov
			cConta := cCtaMov
			aConfig1 := {cIdProc, cBanco, cAgencia, cConta, cSubCta, cDesc}

			If SEE->(MsSeek(xFilial("SEE") + cBanco + cAgencia + cConta))
				// No existe grupo de preguntas o no se indicaron; Toma datos de la primera sub cuenta configurada (SEE)
				cSubCta := SEE->EE_SUBCTA
				aConfig1[5] := cSubCta
			Else
				aAdd(aLog,{0 , OemToAnsi(STR0003)})	//"No se encontró registro con Parámetros del Banco (SEE)."
				lRet := .F.
			Endif

		ElseIf Empty(cBanco) .And. Empty(cBcoMov)
			// Datos del banco sin definir en grupo de preguntas y no están en el extracto
			aAdd(aLog,{0 , OemToAnsi(STR0004)})	//"Extracto sin datos del Banco."
			lRet := .F.

		Else
			// Datos del banco en el grupo de preguntas y en el extracto; comparar valores
			F474BcoMov(@cBcoMov, @cAgeMov, @cCtaMov)

			If !(cBanco == cBcoMov .And. Alltrim(cAgencia) == Alltrim(cAgeMov) .And. Alltrim(cConta) == Alltrim(cCtaMov))
				aADD(aLog,{0 , OemToAnsi(STR0005)} ) //"Archivo de Extracto no pertenece al banco informado. Verifique archivo de configuración y extracto."
				lRet := .F.
			EndIf

		EndIf

		If !A474VldBco(@cBanco , @cAgencia , @cConta, @nLinha, @aLog)
			aADD(aLog,{nLinha, OemToAnsi(STR0006) } ) //"Banco no registrado."
			lRet := .F.
		EndIf

		If !SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta)) .Or. SA6->A6_BLOCKED == "1" 	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
			aADD(aLog,{nLinha , OemToAnsi(STR0008)  + cBanco + OemToAnsi(STR0009) + cAgencia + OemToAnsi(STR0010) + cConta + OemToAnsi(STR0011) } )		//"Banco: "##" Agencia: "##" Cuenta: "##" no existe."
			lRet := .F.
		EndIf

		If Empty(cDesc)
			cDesc := Alltrim(SA6->A6_NOME)
			aConfig1[6] := cDesc
		EndIf

		If lRet
	
			BEGIN TRANSACTION

				// Movimientos
				For nLinha := 1 to Len(aParam2)

					For nCampo := 1 to Len(aParam2[nLinha])
						If Trim(aParam2[nLinha][nCampo][1]) == "IG_DTEXTR"
							dDataMov := aParam2[nLinha][nCampo][2]
						ElseIf Trim(aParam2[nLinha][nCampo][1]) == "IG_DOCEXT"
							cNumMov := aParam2[nLinha][nCampo][2]
						ElseIf Trim(aParam2[nLinha][nCampo][1]) == "IG_VLREXT"
							nValorMov := aParam2[nLinha][nCampo][2]
						ElseIf Trim(aParam2[nLinha][nCampo][1]) == "IG_TIPEXT"
							cCodMov := aParam2[nLinha][nCampo][2]
						ElseIf Trim(aParam2[nLinha][nCampo][1]) == "IG_HISTEXT"
							cDescrMov := aParam2[nLinha][nCampo][2]
						EndIf

						lTemLacto := .T.
					Next nCampo

					If SEJ->(dbSeek(xFilial("SEJ")+cBanco+cCodMov))
						cTipoMov := SEJ->EJ_OCORSIS
						cDescMov := SEJ->EJ_DESCR
						cDebCred := SEJ->EJ_DEBCRE

					Else
						aADD(aLog,{nLinha , OemToAnsi(STR0007) + " - " + cCodMov } ) //"Ocurrencia no encontrada."
						lRet 	:= .F.

					Endif

					//Grava se não tiver inconsistência
					If lRet
						// Grava dados no arquivo de trabalho
						If lGravaSIF
							F474GRVSIF(aConfig1, aConfig2 , dDatabase , '1', cChkSum)
							lGravaSIF := .F.
						EndIf

						// Grava SIG
						cItem := Soma1(cItem)
						F474GRVSIG(aConfig1[1], cItem, '1', dDataMov, cNumMov, nValorMov, cCodMov, cDebCred, cBanco, cAgencia, cConta, cDescrMov, "")
						nContReg++
					Endif

				Next nLinha

				If !lRet
					DisarmTransaction()
				EndIf

			END TRANSACTION			

		EndIf

		If nContReg == 0
			If !lTemLacto	
				aADD(aLogLanc,{ 0 , OemToAnsi(STR0012) } )	//"Este archivo de extracto no tiene registros."
				lRet := .F.
			ElseIf !lRet
				aADD(aLog,{ 0 , OemToAnsi(STR0013) } )		//"Archivo de extracto no válido. Verifique archivo de configuración y extracto."
			EndIf
		EndIf

	EndIf

	If !lRet

		BEGIN TRANSACTION
			For nX := 1 to Len(aLog)
				cDescFail := "[ERRO] " + OemToAnsi(STR0014) + cValtoChar(aLog[nX][1]) +"|"+ aLog[nX][2] + CRLF		//"Línea del archivo "
				cFailSIF += cDescFail
			Next nX	
			
			For nX := 1 to len(aLogLanc)
				cDescFail := "[ALERTA] " + aLogLanc[nX][2] + CRLF
				cFailSIF += cDescFail
			Next nX

			F474GRVSIF(aConfig1, aConfig2 , dDatabase , '4', "", cFailSIF)
		END TRANSACTION			

		MsgAlert( OemToAnsi(STR0016) + CRLF + OemToAnsi(STR0017) , OemToAnsi(STR0015) )	//"Ocurrieron problemas en la importación del archivo de extracto."###"Haga clic en Visualizar para verificar las ocurrencias."###"ATENCIÓN"

	Else
		MsgInfo( OemToAnsi(STR0019), OemToAnsi(STR0018) )		//"Extracto importado con éxito."###"AVISO"

	EndIf

	cArqEnt := ""

Return Nil

/*/{Protheus.doc} F474BcoMov
	Lee banco del extracto
	Recibe parámetros por referencia. Si el banco existe, retorna valores como están en la tabla
	@type  Static Function
	@author ARodriguez
	@since 19/11/2025
	@version >= 12.1.2410
	@param cBanco, caracter, Banco
	@param cAgencia, caracter, Agencia
	@param cConta, caracter, Cuenta
	@return nil, nil, nil
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function F474BcoMov( cBanco , cAgencia , cConta )
Local aAreaATU := GetArea()
Local aAreaSA6 := SA6->( GetArea() )
Local cFilSA6  := xFilial( 'SA6' )
Local nSubAge  := 0
Local nSubCon  := 0
Local lStop    := .F.

Default cBanco		:= ""
Default cAgencia	:= ""
Default cConta		:= ""

If !SA6->( MsSeek( cFilSA6 + cBanco + cAgencia + cConta ) )
	SA6->( MsSeek( cFilSA6 + cBanco ) )

	While !SA6->( Eof() ) .And. cFilSA6 == SA6->A6_FILIAL .And. cBanco == AllTrim(SA6->A6_COD) .And. !lStop
		
		If SA6->A6_BLOCKED = '1' //Se banco estiver bloqueado ceverá ser pulado
			SA6->( DbSkip() )
			Loop
		EndIf
			
		nSubAge := At( Alltrim( SA6->A6_AGENCIA ) , cAgencia )
		nSubCon := At( Alltrim( SA6->A6_NUMCON  ) , cConta   )
		If nSubAge > 0 .And. nSubCon > 0
			If ( SubStr( cAgencia , 1 , nSubAge-1 ) == StrZero( 0 , nSubAge-1 ) .Or. ;// Valida 0 a esquerda: Agencia 
			     Alltrim( SA6->A6_AGENCIA ) == AllTrim( cAgencia ) ) ;
			   .And. ;
			   ( SubStr( cConta   , 1 , nSubCon-1 ) == StrZero( 0 , nSubCon-1 ) .Or. ;// Valida 0 a esquerda: Conta Corrente
			     Alltrim( SA6->A6_NUMCON  ) == AllTrim( cConta   ) )
				cAgencia := SA6->A6_AGENCIA
				cConta   := SA6->A6_NUMCON
				cBanco   := SA6->A6_COD
				lStop    := .T.
			EndIf
		EndIf
		SA6->( DbSkip() )
	EndDo
	
EndIf

RestArea( aAreaSA6 )
RestArea( aAreaATU )
aSize( aAreaSA6 , 0 )
aSize( aAreaATU , 0 )
aAreaSA6 := Nil
aAreaATU := Nil

Return Nil

/*/{Protheus.doc} F474MIPar
	Guarda parámetros
	@type  Function
	@author user
	@since 24/11/2025
	@version >= 12.1.2410
	@param lParam1, lógico, Se ejecuta con interfaz? (.T. / .F.)
	@param aParam2, matriz, Vector con información adicional
	@param aParam3, matriz, Definición del layout 
	@param aParam4, matriz, Datos de salida
	@param aParam5, matriz, Vectores de rutina automática
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function F474MIPar(lParam1, aParam2, aParam3, aParam4, aParam5)

	Default lParam1	:= .F.
	Default aParam2	:= {}
	Default aParam3	:= {}
	Default aParam4	:= {}
	Default aParam5	:= {}

	If Len(aParam2) >= 3
		cArqEnt := aParam2[3]	// Nombre del archivo de texto que se está procesando
	EndIf

Return .T.
