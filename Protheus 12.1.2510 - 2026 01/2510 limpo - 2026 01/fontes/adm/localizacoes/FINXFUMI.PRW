#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINXFUMI.CH"
#INCLUDE "FWMVCDEF.CH"

Static lChkLxProp:= FindFunction("ChkLxProp")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINXFUMI   ³ Autor ³ gSantacruz            ³ Data ³ 15.10.19           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funciones de uso exclusivo para Mercado Internacional  	             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/{Protheus.doc} CallsMI
	Criada para integrações com módulos de Ativos Fixos (ATFA012) e Compras (MATA103X).
	@type  Function
	@author Gpe. Santacruz  . - SQUAD Norte Andino
	@since 15/10/2019
	@version P12.1.17
	@return lRet, logico.
/*/
Function CallsMI

Local lRet := FWIsInCallStack("MATA102N").or. FWIsInCallStack("MATA101N") .Or. FWIsInCallStack("MATA143") .Or. (lChkLxProp .and. ChkLxProp("NoObligatoriosSN3")) // .Or. ...

Return lRet 

/*/{Protheus.doc} MovBanc
	Funcion que permite la modificacion de los campos del modelo usado para la generacion de movimientos bancarios
	desde el proceso de Eliminacion de residuos(fina415).
	@type  Function
	@author Eduardo Pérez  . - SQUAD Norte Andino
	@since 25/05/2020
	@version 1.0
	@param oSubFK1 modelo que contiene los datos del movimiento bancario (tabla FK1)
	@param lTipMovBco variable logica que valida si existe afectacion de saldo bancario.
	@param nValEstrang varible numerica que contiene el valor original del titulo
	@param nValRec variable numerica que contiene el valor del titulo convertido a la moneda del banco.
/*/

Function MovBanc(oSubFK1,lTipMovBco,nValEstrang,nValRec,nMoedaBco)
	Default nValEstrang := 0
	Default nValRec := 0
	Default nMoedaBco := 1
	Default lTipMovBco := .F.

	If nValEstrang > 0 
	    If !lTipMovBco
	    	oSubFK1:SetValue( "FK1_VLMOE2"	, nValEstrang )
	    Else 
	    	If nMoedaBco > 1
	    		oSubFK1:SetValue( "FK1_VLMOE2"	, nValRec )
	    	Else
	    		oSubFK1:SetValue( "FK1_VLMOE2"	, nValEstrang )
	    	EndIf
	    EndIf
	Else
		oSubFK1:SetValue( "FK1_VLMOE2"	, nValRec )
	Endif
Return 

/*/{Protheus.doc} fn450Cpo
	Agrega campos a encabezado de oMark y a la tabla temporal TRB
	desde el proceso de compensación entre carteras (fina450).
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 13/08/2020
	@version 1.0
	@param aCampos array de salida Campos en Tabla temporal TRB
	@param aCpoBro array de salida Campos en grid de oMark
	@param aOfuscar array de salida indica campos desmarcados
/*/
Function fn450Cpo(aCampos, aCpoBro, aOfuscar,cMoeda450)
	Default aCampos := {}
	Default aCpoBro := {}
	Default aOfuscar := {}

	//Campos en Tabla temporal TRB
	aadd(aCampos,{"MONEDA"  ,"N", 2,0})
	aadd(aCampos,{"TASA"   ,"N", 11,4})
	aadd(aCampos,{"VALORM"   ,"N", 15,2})
	//Campos en grid de oMark
	aadd(aCpoBro,{"MONEDA"	,, STR0003,"@X"} )  //"Moneda"
	aadd(aCpoBro,{"TASA"	,, STR0004  ,"@E 999999.9999"} )  //"Tasa"
	aadd(aCpoBro,{"VALORM",, STR0005 + cMoeda450  ,"@E 9,999,999,999.99"} )  //"Val en "
	//indica campos desmarcados
	aadd(aOfuscar,.f.)
	aadd(aOfuscar,.f.)
	
Return 


/*/{Protheus.doc} fn450SEX
	se forma Query con filtros para las Cuentas por Pagar(SE2)           
	desde el proceso de compensación entre carteras (fina450).
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 13/08/2020
	@version 1.0
	@param lMonedaC Cualquier Moneda (check en compensación)
	@param nMoeda 	Moneda seleccionada en la compensación
	@param cTabC 	Tabla de Cobro / Pago
/*/
Function fn450SEX(lMonedaC, nMoeda, cTabC)
	Local cStrQ 	:= ""
	default lMonedaC:= .F. 
	default nMoeda 	:= 1 
	default cTabC 	:= ""

	If cTabC == 'SE1' .and. !lMonedaC
		cStrQ := " SE1.E1_MOEDA = " + Alltrim(Str(nMoeda,2)) + " AND "
	ElseIf cTabC == 'SE2' .and. !lMonedaC
		cStrQ := " SE2.E2_MOEDA = " + Alltrim(Str(nMoeda,2)) + " AND "
	Endif
Return cStrQ

/*/{Protheus.doc} fn450GrTmp
	Llena archivo temporal TRB        
	desde el proceso de compensación entre carteras (fina450).
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 13/08/2020
	@version 1.0
	@param Ctbl 		indicador de valores(Tabla SE1 o SE2) a procesar
	@param TRB 			archivo temporal
	@param nAbat		Reembolsos
	@param nJuros  		Interes Calculado
	@param nVa 		 	Interes
	@param nDescont  	Valor decuentos
	@param nMulta 		Valor Multas
/*/
Function fn450GrTmp(cTbl,TRB, nAbat,nJuros,nVa,nDescont,nMulta)
	Local nRcbr 		:= 0
	Local nCasDec 		:= TamSx3("E1_TXMOEDA")[2]
	Local nValMoe		:= 0
	Local nSdacRes		:= 0
	Local nSaldo 		:= 0
	Local nSdecRe 		:= 0
	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final	
		nValMoe := 0
		nRcbr := 0
		If cTbl == 'SE1'
		
			nSdacRes:= SE1->E1_SDACRES
			nSaldo 	:=SE1->E1_SALDO
			nSdecRe :=SE1->E1_SDDECRE
			nRcbr := nSaldo - nAbat + nSdacRes - nSdecRe + nJuros - nDescont + nMulta + nVA
			nValMoe := Round(xMoeda(nRcbr, SE1->E1_MOEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[SE1->E1_MOEDA][2], aTxMoedas[nMoeda][2] ), 2)
			
			RecLock("TRB",.T.)
			Replace P_R			With "R"
			Replace TITULO		With SE1->E1_PREFIXO + "-" + SE1->E1_NUM + "-" + SE1->E1_PARCELA+ "-" + SE1->E1_TIPO
			Replace EMISSAO		With SE1->E1_EMISSAO
			Replace VENCTO		With SE1->E1_VENCREA
			Replace RECEBER		With nRcbr
			Replace MARCA		With " "
			Replace TIPO		With SE1->E1_TIPO
			Replace PRINCIP		With nSaldo
			Replace ABATIM		With nAbat
			Replace JUROS		With nJuros
			Replace MULTA		With nMulta	 //Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
			Replace VALACES		With nVA
			Replace DESCONT		With nDescont
			Replace ACRESC		With nSdacRes
			Replace DECRESC		With nSdecRe
			Replace PCC			With 0
			Replace IRRF		With 0
			Replace CLIFOR		With SE1->E1_CLIENTE+"-"+SE1->E1_LOJA
			Replace NOME		With SE1->E1_NOMCLI
			Replace CHAVE		With SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
			Replace VALORM		With nValMoe
			Replace MONEDA		With SE1->E1_MOEDA
			Replace TASA		With aTxMoedas[SE1->E1_MOEDA][2] 
			MsUnlock()
			nTotalR	+= VALORM
			
		ElseIf cTbl == 'SE2'
		
			nSdacRes:= SE2->E2_SDACRES
			nSaldo 	:= SE2->E2_SALDO
			nSdecRe := SE2->E2_SDDECRE
			nRcbr := nSaldo - nAbat + nSdacRes - nSdecRe + nJuros + nVA + nMulta 
			nValMoe := Round(xMoeda(nRcbr, SE2->E2_MOEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[SE2->E2_MOEDA][2], aTxMoedas[nMoeda][2]), 2)
			
			RecLock("TRB",.T.)
			Replace	P_R			With "P"
			Replace	TITULO		With SE2->E2_PREFIXO + "-" + SE2->E2_NUM + "-" + SE2->E2_PARCELA+ "-" + SE2->E2_TIPO
			Replace	EMISSAO		With SE2->E2_EMISSAO
			Replace	VENCTO		With SE2->E2_VENCREA
			Replace PAGAR 		With nRcbr
			Replace	MARCA 		With " "
			Replace TIPO     	With SE2->E2_TIPO
			Replace	PRINCIP		With nSaldo
			Replace	ABATIM		With nAbat
			Replace JUROS		With nJuros
			Replace MULTA		With nMulta	
			Replace VALACES		With nVA	
			Replace DESCONT		With 0
			Replace ACRESC		With nSdacRes
			Replace DECRESC		With nSdecRe
			Replace PCC			With 0
			Replace IRRF		With 0
			Replace CLIFOR		With SE2->E2_FORNECE+"-"+SE2->E2_LOJA
			Replace NOME		With SE2->E2_NOMFOR
			Replace	CHAVE 		With SE2->(E2_FILIAL+E2_PREFIXO+SE2->E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			Replace PIS			With 0
			Replace COF			With 0
			Replace CSL			With 0
			Replace VALORM		With nValMoe
			Replace MONEDA		With SE2->E2_MOEDA
			Replace TASA		With aTxMoedas[SE2->E2_MOEDA][2] 
			MsUnlock()
			nTotalP	+= VALORM
		
		EndIf
Return 

/*/{Protheus.doc} fn450DbEvx
	Validacion para Marcar y desmarcar item en oMark  
	desde el proceso de compensación entre carteras (fina450)       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 13/08/2020
	@version 1.0
	@param nLim450		Valor asignado para compensación
	@param aChaveLbn - 	array con id's de registros Seleccionados
	@param aChavePag -  array con id's de registros a pagar
	@param aChaveRec -  array con id's de registros a cobrar
	@param lPrimeiro - 	valor boleano
/*/
Function fn450DbEvx(nLim450,lMarcaTodos,aChaveLbn , aChavePag, aChaveRec,lPrimeiro)
	Local nTamChavE1	:= TamSx3("E1_PREFIXO")[1]+TamSx3("E1_NUM")[1]+TamSx3("E1_PARCELA")[1]+TamSx3("E1_TIPO")[1]+TamSx3("E1_FILIAL")[1]
	Local nTamChavE2	:= TamSx3("E2_PREFIXO")[1]+TamSx3("E2_NUM")[1]+TamSx3("E2_PARCELA")[1]+TamSx3("E2_TIPO")[1]+TamSx3("E2_FILIAL")[1]+TamSx3("E2_FORNECE")[1]+TamSx3("E2_LOJA")[1]
	Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)
	Local aArea			:= GetArea()
	Local aAreaSE2		:= SE2->(GetArea())
	Local nX			:= 0
	Local lMarcar		:= .F.
	Local nValOld		:= 0
	Local nVCobrar := 0
	Local nVPagar	:= 0
	Local nCasDec 		:= TamSx3("E1_TXMOEDA")[2]
	Default lPrimeiro:=.F.

	SE2->(dbSEtORder(1))

	lMarcaTodos := Iif(lMarcaTodos == Nil, .F., lMarcaTodos)

	If Right(TRB->TIPO,1) != "-"
		cChaveLbn := "CEC" + TRB->(P_R+CHAVE)
		If lMarcaTodos
			If LockByName(cChaveLbn,.T.,.F.)
				nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				RecLock("TRB")
				If RECEBER != 0
					nSelecR += nVCobrar
					TRB->MARCA := cMarca
				Else
					If AllTrim(TRB->(P_R))=="P" .and. lFinVDoc
						SE2->(dbSeek(TRB->(CHAVE)))
						IF CN062ValDocs("07",.F.,.F.,.T.,@lPrimeiro)
							nSelecP += nVPagar
							TRB->MARCA := cMarca
						Endif
					Else
						nSelecP += nVPagar
						TRB->MARCA := cMarca
					Endif
				EndIf
				
				Msunlock()
				Aadd(aChaveLbn,cChaveLbn)
			Endif	
		Else
			nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
			nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
			IF RECEBER != 0
				If !lF450Auto
					lMarcar := (nSelecR < nLim450 .And. (nVCobrar+nSelecR) <= nLim450)
				Else
					nX := aScan(aChaveRec, {|x| x[1]==Substr(CHAVE,1,nTamChavE1) })
					lMarcar := nX > 0 .And. ( (nSelecR < nLim450 .And. (nVCobrar+nSelecR) <= nLim450) .OR. ( nlim450 == 0) )
				EndIf

				If lMarcar
					If LockByName(cChaveLbn,.T.,.F.)
						If AllTrim(TRB->(P_R))=="P" .and. lFinVDoc
							SE2->(dbSeek(TRB->(CHAVE)))
							IF CN062ValDocs("07",.F.,.F.,.T.,@lPrimeiro)
								RecLock("TRB")
								nSelecR += nVCobrar
								TRB->MARCA := cMarca
								MsUnlock( )
								Aadd(aChaveLbn,cChaveLbn)
							Endif
						Else
							RecLock("TRB")
							nSelecR += nVCobrar
							TRB->MARCA := cMarca
							MsUnlock( )
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						
						If lF450Auto .And. VALTYPE(aChaveRec[nX]) == "A" .And. Len(aChaveRec[nX]) == 5
							nValOld := aChaveRec[nX,2] - ( aChaveRec[nX,3] + aChaveRec[nX,4] + aChaveRec[nX,5] )
							F450VldOk(If(nVCobrar > aChaveRec[nX,2], nVCobrar, aChaveRec[nX,2]), nValOld, aChaveRec[nX,3], aChaveRec[nX,5], aChaveRec[nX,4])
						EndIf
					Endif	
				ElseIf (lF450Auto .And. nX > 0 .And. ((nVCobrar+nSelecR) > nLim450) .And. !(nSelecR == nLim450))
					If LockByName(cChaveLbn,.T.,.F.)
						If AllTrim(TRB->(P_R))=="P" .and. lFinVDoc
							SE2->(MsSeek(TRB->(CHAVE)))
							IF CN062ValDocs("07",.F.,.F.,.T.,@lPrimeiro)
								RecLock("TRB")
								nSelecR := nLim450
								TRB->MARCA := cMarca
								MsUnlock( )
								Aadd(aChaveLbn,cChaveLbn)
							Endif
						Else
							RecLock("TRB")
							nSelecR := nLim450
							TRB->MARCA := cMarca
							MsUnlock( )
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						
						If lF450Auto .And. VALTYPE(aChaveRec[nX]) == "A" .And. Len(aChaveRec[nX]) == 5
							nValOld := aChaveRec[nX,2] - ( aChaveRec[nX,3] + aChaveRec[nX,4] + aChaveRec[nX,5] )
							F450VldOk(nVCobrar, nValOld, aChaveRec[nX,3], aChaveRec[nX,5], aChaveRec[nX,4])
						EndIf
					Endif				
				Else
					RecLock("TRB")
					TRB->MARCA := " "
					MsUnlock( )
				EndIf
			Else
				nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				If !lF450Auto
					lMarcar := (nSelecP < nLim450 .And. (nVPagar+nSelecP) <= nLim450)
				Else
					nX := aScan(aChavePag, {|x| x[1] == Substr(CHAVE,1,nTamChavE2) })
					lMarcar := nX > 0 .And. ( (nSelecP < nLim450 .And. (nVPagar+nSelecP) <= nLim450) .OR. ( nlim450 == 0) )
				EndIf
				
				If lMarcar
					If LockByName(cChaveLbn,.T.,.F.)
						If AllTrim(TRB->(P_R))=="P" .and. lFinVDoc
							SE2->(dbSeek(TRB->(CHAVE)))
							IF CN062ValDocs("07",.F.,.F.,.T.,@lPrimeiro)
								RecLock("TRB")
								nSelecP += nVPagar
								TRB->MARCA := cMarca
								MsUnlock( )
								Aadd(aChaveLbn,cChaveLbn)
							Endif
						Else
							RecLock("TRB")
							nSelecP += nVPagar
							TRB->MARCA := cMarca
							MsUnlock( )
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						If lF450Auto .And. VALTYPE(aChavePag[nX]) == "A" .And. Len(aChavePag[nX]) == 5
							nValOld := aChavePag[nX,2] - ( aChavePag[nX,3] + aChavePag[nX,4] + aChavePag[nX,5] )
							F450VldOk(aChavePag[nX,2],nValOld,aChavePag[nX,3],aChavePag[nX,5],aChavePag[nX,4])
						EndIf
					Endif	
				ElseIF (lF450Auto .AND. nX > 0 .AND. (((nVPagar+nSelecP) >= nLim450) .and. !(nSelecP == nLim450)))
					If LockByName(cChaveLbn,.T.,.F.)
						If AllTrim(TRB->(P_R))=="P" .and. lFinVDoc
							SE2->(MsSeek(TRB->(CHAVE)))
							IF CN062ValDocs("07",.F.,.F.,.T.,@lPrimeiro)
								RecLock("TRB")
								nSelecP := nLim450
								TRB->MARCA := cMarca
								MsUnlock( )
								Aadd(aChaveLbn,cChaveLbn)
							Endif
						Else
							RecLock("TRB")
							nSelecP := nLim450
							TRB->MARCA := cMarca
							MsUnlock( )
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						
						If lF450Auto .And. VALTYPE(aChavePag[nX]) == "A" .And. Len(aChavePag[nX]) == 5
							nValOld := aChavePag[nX,2] - ( aChavePag[nX,3] + aChavePag[nX,4] + aChavePag[nX,5] )
							F450VldOk(aChavePag[nX,2],nValOld,aChavePag[nX,3],aChavePag[nX,5],aChavePag[nX,4])
						EndIf
					Endif				
				Else
					RecLock("TRB")
					TRB->MARCA := " "
					MsUnlock( )
				EndIf
			EndIF
		EndIf
		MsUnlock( )
	EndIf
	
	RestArea(aAreaSE2)
	RestArea(aArea)
Return Nil


/*/{Protheus.doc} fn450Invet
	Invierte markbrowse desde el proceso de compensación entre carteras (fina450)       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 13/08/2020
	@version 1.0
	@param cMarca  - Marca de registro
	@param oTotalP - Objeto Total Pago
	@param oTotalR - Objeto Total Cobro
	@param oSelecP - Objeto Total seleccionado Pago
	@param oSelecR - Objeto Total seleccionado Cobro
	@param lTodos  - Indica todos los registros
	@param aChaveLbn - array con id's de registros Seleccionados
/*/
Function fn450Invet(cMarca,oTotalP,oTotalR,oSelecP,oSelecR,lTodos,aChaveLbn)
	Local nReg			:= TRB->(Recno())
	Local lCompensa		:= .F. 
	Local nTamChavE2	:= TamSx3("E2_PREFIXO")[1]+TamSx3("E2_NUM")[1]+TamSx3("E2_PARCELA")[1]+TamSx3("E2_TIPO")[1]+TamSx3("E2_FILIAL")[1]+TamSx3("E2_FORNECE")[1]+TamSx3("E2_LOJA")[1]
	Local nTamChavE1	:= TamSx3("E2_PREFIXO")[1]+TamSx3("E2_NUM")[1]+TamSx3("E2_PARCELA")[1]+TamSx3("E2_TIPO")[1]+2
	Local cTipo			:= ""
	Local lValDocs		:= .T.
	Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)		//Controle de validacao de documentos obrigatorios
	Local lPrimeiro		:= .T. // na validação de amarração fin x documentos, deve passar apenas uma vez pelo help
	Local lSelecP		:= .F.
	Local lSelecR		:= .F.
	Local nVlPagar		:= 0
	Local nVlReceb		:= 0
	Local lAlterado		:= .F.
	Local nVCobrar := 0
	Local nVPagar	:= 0
	Local nCasDec 		:= TamSx3("E1_TXMOEDA")[2]

	Default lTodos		:= .T.

	If lTodos
		dbSelectArea("TRB")
		dbGoTop()
	Endif

	While !lTodos .Or. !Eof()
		lValDocs := .T.
		lCompensa := .T.      
            
		//--------------------------------------------------------------
		// So executa o P.E. quando o registro/titulo está sendo marcado. 
		// Nao chama na "desmarcação".                                     
		//--------------------------------------------------------------
		If ExistBlock("F450Conf") .and. MARCA != cMarca
			//-------------------------------------------------
			// Procura registro no SE1 ou SE2, conforme titulo	
			//-------------------------------------------------
			If TRB->RECEBER != 0
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek(Substr(TRB->CHAVE,1,nTamChavE1))     
				//----------------------------------------------------------------------------------
				// Caso seja um Titulo à Receber, o parametro passado para o PE terah conteudo "R", 
				// nesse caso o RDMake devera consultar o SE1.										
				//----------------------------------------------------------------------------------
				cTipo := "R"
			Else
				dbSelectArea("SE2")
				dbSetOrder(1)
				dbSeek(Substr(TRB->CHAVE,1,nTamChavE2))
				//--------------------------------------------------------------------------------
				// Caso seja um Titulo à Pagar, o parametro passado para o PE terah conteudo "P", 
				// nesse caso o RDMake deverah consultar o SE2.                                   
				//--------------------------------------------------------------------------------
				cTipo := "P"
			EndIf

			lCompensa := ExecBlock("F450Conf",.F.,.F.,{cTipo})
			dbSelectArea("TRB")
		EndIf
	
		If lCompensa
			//-- Parametros da Funcao LockByName() :
			//   1o - Nome da Trava
			//   2o - usa informacoes da Empresa na chave
			//   3o - usa informacoes da Filial na chave 
			
			cChaveLbn := "CEC" + TRB->(P_R+CHAVE)
			If !(TRB->TIPO $ MVABATIM)	
				IF TRB->MARCA == cMarca
					nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
					nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
					RecLock("TRB")
					TRB->MARCA := "  "
					If TRB->RECEBER != 0
						nSelecR -= nVCobrar
					Else
						nSelecP -= nVPagar					
					EndIf
					nAscan := Ascan(aChaveLbn, cChaveLbn )
					If nAscan > 0
						UnLockByName(aChaveLbn[nAscan],.T.,.F.) 
					Endif
				Else
					If (Upper(TRB->P_R) == "P") .And. lFinVDoc
						If !F450VldDoc(TRB->CHAVE,lTodos,.T.,,@lPrimeiro)
							lValDocs := .F.
						EndIf
					EndIf
					If lValDocs
						If (TRB->P_R == "P")
							dbSelectArea("SE2")
							DbSetOrder(1)
							If dbSeek(TRB->(CHAVE))
								If SE2->E2_SALDO != TRB->PRINCIP
									lAlterado := .T.
								Endif
							EndIf
						Else
							dbSelectArea("SE1")
							DbSetOrder(1)
							If dbSeek(TRB->(CHAVE))
								If SE1->E1_SALDO != TRB->PRINCIP
									lAlterado := .T.  
								Endif
							EndIf					
						EndIf
						If ExistBlock("F450GRAVA")
							lAlterado := .F. 
						Endif
						DbSelectArea("TRB")
						If LockByName(cChaveLbn,.T.,.F.) .and. !lAlterado
							nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
							nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
							RecLock("TRB")
							TRB->MARCA := cMarca
							If TRB->RECEBER != 0
								nSelecR += nVCobrar
							Else
								nSelecP += nVPagar
								DbSelectArea("TRB")							
							EndIf
							Aadd(aChaveLbn, cChaveLbn )
						Else
							If !lTodos
								MsgAlert(STR0001, STR0002) // "Existe otro usuario utilizando el título" ## "Atención"
							Endif
						Endif
					EndIf
				Endif
				MsUnlock()
			Endif	
		EndIf
		If lTodos
			dbSkip()
		Else
			Exit	
		Endif
	Enddo

	If nLim450 != 0
		If lTodos
			TRB->(dbGoTop())
			
			While TRB->(!Eof()) .And. (!lSelecP .OR. !lSelecR)
				
				nVCobrar :=  Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				nVPagar  :=  Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
				
				If nLim450 < nSelecP .And. TRB->PAGAR > 0
					nSelecP := nLim450
					lSelecP := .T.
				ElseIf nLim450 > nSelecP .And. TRB->PAGAR > 0 .And. Empty(TRB->MARCA)
					nSelecP := 0	
				ElseIf TRB->PAGAR > 0
					nVlPagar += nVPagar	
				EndIf 
				
				If nLim450 < nSelecR .And. TRB->RECEBER > 0
					nSelecR := nLim450
					lSelecR := .T.	
				ElseIf nLim450 > nSelecR .And. TRB->RECEBER > 0 .And. Empty(TRB->MARCA) 
					nSelecR := 0	
				ElseIf TRB->RECEBER > 0
					nVlReceb += nVCobrar	
				EndIf 	
									
				TRB->(dbSkip())		
			EndDo	
			
			If nSelecP <= 0 .And. nVlPagar > 0
				nSelecP := nVlPagar	 
			EndIf  
			
			If nSelecR <= 0 .And. nVlReceb > 0
				nSelecR := nVlReceb	
			EndIf  	 
		Else	
			If nLim450 < nSelecP
				nSelecP := nLim450
			ElseIf nLim450 < nSelecR
				nSelecR := nLim450
			EndIf
			If nSelecR < 0
				nSelecR:= 0
			Elseif nSelecP < 0
				nSelecP:= 0
			Endif	
		EndIf
	EndIf

	oSelecP:Refresh()
	oSelecR:Refresh()
	TRB->(MsGoto(nReg))

Return ( lAlterado )

/*/{Protheus.doc} fn450OtrVl
	Convierte valores a moneda seleccionada 
	desde el proceso de compensación entre carteras (fina450)       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 19/08/2020
	@version 1.0
	@param cTab - Tabla a procesar
/*/
Function fn450OtrVl(cTab, nDecse1)

	If (DECRESC + ACRESC + DESCONT + JUROS + MULTA + VALACES) != 0
		If ACRESC != 0
			nAcresc	:= Round(xMoeda(ACRESC,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif

		If DECRESC != 0	
			nDecresc := Round(xMoeda(DECRESC,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif
		
		If DESCONT != 0 	
			nDescont := Round(xMoeda(DESCONT,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif
								
		If JUROS != 0	
			nJuros := Round(xMoeda(JUROS,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif
								
		If MULTA != 0	
			nMulta := Round(xMoeda(MULTA,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif
		
		If VALACES != 0	
			nVA	:= Round(xMoeda(VALACES,MONEDA,nMoeda,dDataBase,nDecse1,TASA,aTxMoedas[nMoeda][2]),nDecse1)
		Endif	
	Endif	
	
Return

/*/{Protheus.doc} fn450mFk2
	Actualiza FK2_VALOR, FK2_VLMOE2 y nMoedaBco desde rutina fina080       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 20/08/2020
	@version 1.0
	@param oSubFK2  - Objeto modelo FK2
	@param cCpoTp 	- Campo con Valor de Pago
	@param nMoedaBco- Moneda seleccionada en la compensación. Valor de salida
	@param nMoedaTit- Moneda del titulo 
	@param nTxModTit- Tasa moneda del titulo 
	@param nTxModBco- Tasa moneda del compensación
/*/
Function fn450mFk2(oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,cTpDoc)
	Local nDcms 	:= 0
	Local nValMoe2 	:= 0
	Local nMoedMd	:= 0
	Local nTxMoeDt	:= 0
	
	nMoedaBco := nMoeda
	If !(cTpDoc $ "DC|JR|MT")
		nDcms 	:= MsDecimais(nMoedaTit)
		nValMoe2:= Round(xMoeda( &cCpoTp, nMoedaBco , nMoedaTit ,,,aTxMoedas[nMoedaBco][2], aTxMoedas[nMoedaTit][2] ),nDcms)
		nMoedMd := nMoedaBco
		nTxMoeDt:= nTxModBco
	Else
		nValMoe2 := &cCpoTp
		nMoedMd := nMoedaTit
		nTxMoeDt := nTxModTit
	EndIf
	oSubFK2:SetValue( "FK2_VALOR" ,&cCpoTp )
	oSubFK2:SetValue( "FK2_VLMOE2", nValMoe2 )
	oSubFK2:SetValue( "FK2_TXMOED", nTxMoeDt )
	oSubFK2:SetValue( "FK2_MOEDA" , StrZero(nMoedMd,2) )

return nil

/*/{Protheus.doc} fn450AsgVl
	Obtiene diferencia de cambio monetario 
	desde el proceso de compensación entre carteras (fina450)         
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 20/08/2020
	@version 1.0
	@param cTab  		- Tabla a procesar
	@param nValDia 	 	- Valor en moneda regional (1)
	@param nDifCambio	- Valor de diferencia en cambio monetario. valor de salida
	@param nCM			- alor de diferencia en cambio monetario. valor de salida
	@param nValMo		- Valor del Pago/Cobro 
	@param nMonDc		- Moneda de titulo 
	@param nTxMoDc		- Tasa de titulo 
	@param nDecse		- Decimales
/*/
Function fn450AsgVl(cTab, nValDia,nDifCambio,nCM,nValMo,nMonDc,nTxMoDc,nDecse)
	
	Local nDifCamLoc := 0
	Local nValCbo := 0
	
	If nMonDc ==1
		nValDia		:= Round(xMoeda(nValMo,nMoeda,1,dDataBase, nDecse, ,aTxMoedas[nMoeda][2]),nDecse)
	Else
		nValDia		:= Round(xMoeda(nValMo,nMoeda,1,dDataBase, nDecse, nTxMoDc),nDecse)
	EndIF
	
	nValCbo 	:= Round(xMoeda(nValMo,nMoeda,1,dDataBase,nDecse,aTxMoedas[nMoeda][2]),nDecse)	
	
	nDifCamLoc	:= nValCbo - nValDia   			
	nDifCambio  := nDifCamLoc
	nCM			:= Round(xMoeda(nDifCambio, 1, nMoeda, dDataBase, nDecse,aTxMoedas[nMonDc][2],aTxMoedas[nMoeda][2]),nDecse)
return

/*/{Protheus.doc} Fn450VlMnd
	Convierte valor a cobrar / pagar a valor de moneda seleccionada 
	desde el proceso de compensación entre carteras (fina450)         
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 20/08/2020
	@version 1.0
	@param nValMnd		- Valor del Pago/Cobro 
	@param nMonTit		- Moneda Titulo
	@param nDecse		- Decimales
/*/

Function Fn450VlMnd (nValMnd,nMonTit,nDecse )
	Local nValCbo := 0
	nValCbo := Round(xMoeda(nValMnd,nMonTit,nMoeda,dDataBase,nDecse,aTxMoedas[nMonTit][2],aTxMoedas[nMoeda][2] ),nDecse)
Return nValCbo

/*/{Protheus.doc} fn450AsgMn
	Asigna moneda seleccionada en la compensación desde rutina fina080 y finxbx        
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 21/08/2020
	@version 1.0
	@param nMoedaBco	- Moneda seleccionada en la compensación. Valor de salida.
	@param nTxModBco	- Tasa de moneda seleccionada en la compensación. Valor de salida.
/*/

Function fn450AsgMn(nMoedaBco, nTxModBco,nTxMoAux  )
	nMoedaBco := nMoeda
	nTxModBco := aTxMoedas[nMoeda][2] 
	nTxMoAux := nTxModBco
Return

/*/{Protheus.doc} fn450AgnBc
	Realiza conversion de valor a moneda de titulo desde rutina finxbx       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 21/08/2020
	@version 1.0
	@param nValRec		- Valor de compensación
	@param nMoedaBco	- Moneda seleccionada en la compensación. Valor de salida.
	@param nMoedTit		- Moneda de titulo
	@param nTxModBco	- Tasa de moneda seleccionada en la compensación. Valor de salida.
/*/

Function fn450AgnBc(cOpc,nMoedaBco,nMoedTit, nTxMoeda )
	Local nDcms := 0
	Local nDesc := 0
	Local nMlta := 0
	Local nJros := 0
	
	nDcms := MsDecimais(nMoedTit)
	If cOpc == '1'
		nDesc := fn450CmMon(nDescont,nMoedTit,nMoedaBco, nTxMoeda)
		nMlta := fn450CmMon(nMulta,nMoedTit,nMoedaBco, nTxMoeda)
		nJros := fn450CmMon(nJuros,nMoedTit,nMoedaBco, nTxMoeda)
		Replace E1_DESCONT   With nDesc
		Replace E1_MULTA	  With nMlta
		Replace E1_JUROS	  With nJros
	ElseIf cOpc == '2'
		Replace E1_VALLIQ With fn450CmMon(nValRec,nMoedTit,nMoedaBco, nTxMoeda)
	ElseIf cOpc == '3'
		Replace E1_CORREC   With fn450CmMon(nCm,nMoedTit,nMoedaBco, nTxMoeda)
	EndIf
Return

/*/{Protheus.doc} fn450Fk1
	Actualiza  FK1_VLMOE2 desde rutina finxbx       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 21/08/2020
	@version 1.0
	@param oSubFK1		- Objeto FK1
	@param nValor		- Valor a compensar
	@param nMoedTit		- Moneda de titulo
	@param nMoedaBco	- Moneda seleccionada en la compensación.
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación.
/*/
Function fn450Fk1(oSubFK1,nValor,nMoedTit,nMoedaBco, nTxMoeda)
	Local nValFk := 0
	Local nDcms := 0
	nDcms := MsDecimais(nMoedTit)
	nValFk := fn450CmMon(nValor,nMoedTit,nMoedaBco, nTxMoeda)
	oSubFK1:SetValue('FK1_VLMOE2',nValFk)
Return

/*/{Protheus.doc} fn450nSal
	Obtiene Saldo con redondeo desde rutina finxbx       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 24/08/2020
	@version 1.0
	@param nValRec		- Valor a compensar
	@param nMoedTit		- Moneda de titulo
	@param nMoedaBco	- Moneda seleccionada en la compensación.
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación.
	@param nCalc		- Otros gastos
	@param nSaldo		- Saldo. Valor de salida.
/*/
Function fn450nSal(cOpc, nValRec,nMoedTit,nMoedaBco, nTxMoeda,nCalc,nSaldo)
Local nDcms := 0
Local nMonSal := 0
nDcms := MsDecimais(nMoedTit)
	If cOpc =='SE1'
		If SE1->E1_MOEDA > 1
			nMonSal := xMoeda(nCalc,nMoedaBco,nMoedTit,dBaixa,nDcms,nTxMoeda,aTxMoedas[nMoedTit][2])
		    If (SE1->E1_SALDO+SE1->E1_ACRESC-SE1->E1_DECRESC) - nMonSal >= 0.01
		        nSaldo := Round(NoRound(SE1->E1_SALDO-nMonSal,nDcms+1),nDcms)
		    Else
		        nSaldo := 0
		    Endif
	    Else
	    	nSaldo := Round(NoRound(SE1->E1_SALDO - xMoeda(nValRec,nMoedaBco,nMoedTit,dBaixa,nDcms,nTxMoeda,aTxMoedas[nMoedTit][2]),nDcms+1),nDcms)
	    EndIf
    ElseIf cOpc =='SE2'
    		nSaldo := Round(NoRound(SE2->E2_SALDO-xMoeda(nValRec,nMoedaBco,nMoedTit,dBaixa,nDcms+1,nTxMoeda,aTxMoedas[nMoedTit][2]),nDcms+1),nDcms)
    EndIf
Return

/*/{Protheus.doc} Fn450Gsts
	Realiza convercion moneda y actualiza E2_DESCONT, E2_MULTA, E2_SDACRES, y E2_JUROS
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 25/08/2020
	@version 1.0
	@param cOpc			- indica campos a actualizar
	@param nMoedaBco	- Moneda seleccionada en la compensación.
	@param nMoedTit		- Moneda titulo
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación.
/*/
Function Fn450Gsts(cOpc,nMoedaBco,nMoedTit, nTxMoeda)
Local nDcms	:= 0
Local nAcrc	:= 0
Local nDscto:= 0
Local nDcrs	:= 0
Local nJrs	:= 0
Local nMlta	:= 0

nDcms := MsDecimais(nMoedTit)
If cOpc =='1'
	nDscto	:= fn450CmMon(nDescont,nMoedTit,nMoedaBco, nTxMoeda)
	nDcrs 	:= fn450CmMon(nDecresc,nMoedTit,nMoedaBco, nTxMoeda)
	nMlta 	:= fn450CmMon(nMulta,nMoedTit,nMoedaBco, nTxMoeda)
	
	SE2->E2_DESCONT := nDscto + nDcrs
	SE2->E2_MULTA	:= nMlta
ElseIf cOpc =='2'
	If SE2->E2_MOEDA > 1 .And. nMoedaBco == 1 //Título em moeda estrangeira com banco em moeda 1
		SE2->E2_SDACRES    -=  fn450CmMon(nValEstrang,nMoedTit,nMoedaBco, nTxMoeda)
	Else
		SE2->E2_SDACRES  -=  fn450CmMon(nValPgto,nMoedTit,nMoedaBco, nTxMoeda)
	EndIf
ElseIf cOpc =='3'
	nJrs 			:= fn450CmMon(nJuros,nMoedTit,nMoedaBco, nTxMoeda)
	nAcrc 			:= fn450CmMon(nAcresc,nMoedTit,nMoedaBco, nTxMoeda)
	SE2->E2_JUROS	:= nJrs + nAcresc
	SE2->E2_CORREC	:=  fn450CmMon(nCm,nMoedTit,nMoedaBco, nTxMoeda)
EndIf

Return

/*/{Protheus.doc} fn450Fk6
	Actualiza  FK6_VALMOV y FK6_VALCAL desde rutina finxbx y fina080       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 25/08/2020
	@version 1.0
	@param oSubFK6		- Objeto FK6
	@param nValor		- Valor Movimiento
	@param nValCalc		- Valor de cálculo	
	@param nMoedTit		- Moneda titulo
	@param nMoedaBco	- Moneda seleccionada en la compensación.
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación.
/*/
Function fn450fk6(oSubFK6,nValor,nValCalc,nMoedTit,nMoedaBco, nTxMoeda,cTpDoc)
	Local nValMo 	:= 0
	Local nValClc 	:= 0
	Local nDcms 	:= 0
	
	nDcms  := MsDecimais(nMoedTit)
	nValMo := fn450CmMon(nValor,nMoedTit,nMoedaBco, nTxMoeda)
	nValClc := fn450CmMon(nValCalc,nMoedTit,nMoedaBco, nTxMoeda)

	oSubFK6:SetValue("FK6_VALMOV",nValMo)
	oSubFK6:SetValue("FK6_VALCAL",nValClc)
	
Return

/*/{Protheus.doc} fn450CmMon
	Conversión de valores de moneda de compensación a moneda del Titulo desde rutina finxbx       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 27/08/2020
	@version 1.0
	@param nEnVal		- Valor a convertir
	@param nMoedTit		- Moneda titulo
	@param nMoedaBco	- Moneda seleccionada en la compensación.
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación.
/*/
Function fn450CmMon(nEnVal,nMoedTit,nMoedaBco, nTxMoeda)
	Local nDcms	 := 0
	Local nCmSal := 0
	nDcms := MsDecimais(nMoedTit)
	nCmSal := Round(xMoeda(nEnVal,nMoedaBco,nMoedTit,dDatabase,nDcms,nTxMoeda,aTxMoedas[nMoedTit][2]),nDcms)
Return nCmSal

/*/{Protheus.doc} Fn450Mark
	Actualiza los totalizadores de las Cuentas pr Cobrar /Pagar  
	desde el proceso de compensación entre carteras (fina450)       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 04/09/2020
	@version 1.0
	@param nOldVal - Valor Titulo
	@param oSelecp - Objeto total Cuentas por Pagar
	@param oSelecR - Objeto total Cuentas por Cobrar
	@param nValor  - valor mas otros gastos
/*/
Function Fn450Mark(nOldVal,oSelecp,oSelecR,nValor)
	Local _nRectrb := TRB->(Recno())
	Local nCasDec 		:= TamSx3("E1_TXMOEDA")[2]
	Local nValRP := 0
	Local nVlTRBRe := 0
	Local nVlAcces := 0
	Local nVlTRBPa := 0
	Default nValor := 0

	nSelecR := 0 
	nSelecP := 0
	DbSelectArea("TRB")
	TRB->(DbGoTop())
	While TRB->(!Eof())
		If !Empty(TRB->MARCA)
			If TRB->RECEBER != 0	
				nValRP := Round(xMoeda(nValor, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
				nVlTRBRe := Round(xMoeda(TRB->RECEBER, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
				nVlAcces := Round(xMoeda(TRB->(PRINCIP + JUROS + MULTA - DESCONT + VALACES), TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
				If TRB->(Recno()) == _nRecTrb .And. nValor <> 0  
					nSelecR += nValRP
				Else
					If TRB->RECEBER <> TRB->PRINCIP
						nSelecR += nVlTRBRe	
					Else
						nSelecR += nVlAcces
					EndIf				
				EndIf
				If nLim450 > 0 .and. nSelecR >= nLim450
					nSelecR := nLim450
				Endif
			Else 
				nValRP := Round(xMoeda(nValor, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)
				nVlTRBPa := Round(xMoeda(TRB->PAGAR, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2)  
				nVlAcces := Round(xMoeda(TRB->(PRINCIP + JUROS + MULTA - DESCONT + VALACES), TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
				If TRB->(Recno()) == _nRecTrb .And. nValor <> 0
					nSelecP += nValRP 	
				Else			
					If TRB->PAGAR <> TRB->PRINCIP
						nSelecP += nVlTRBPa
					Else
						nSelecP += nVlAcces
					EndIf			
				EndIf
				If nLim450 > 0 .and. nSelecP >= nLim450
					nSelecP := nLim450
				Endif
			Endif
		Endif
		TRB->(DbSkip())	
	Enddo

	TRB->(DbGoto(_nRectrb))

	If !lF450Auto
		oSelecP:Refresh()
		oSelecR:Refresh()
	EndIf

Return Nil

/*/{Protheus.doc} Fn450Mark
	Asigna Valores Intereses, Multas y descuentos en la 
	moneda origen de la compensación y utilizada en finxbx      
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 04/09/2020
	@version 1.0
/*/
Function Fn450VlAux()
	Local nJurAux := 0
	Local nMulAux := 0
	Local nDesAux := 0
	
	nJurAux := nJuros
	nMulAux := nMulta
	nDesAux := nDescont
Return Nil

/*/{Protheus.doc} Fn450Mark
	Asigna Valores Intereses, Multas y descuentos en la 
	moneda origen de la compensación y utilizada en FINA080      
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 04/09/2020
	@version 1.0
	@param nJRBaixa - Intereses
	@param nMulta 	- Multas
	@param nCMBaixa - Cmabio Monetario
	@param nDescont - Descuento
	@param nAcresc  - Acrementos
	@param nDecresc - Decrementos
	@param nMoedaBco- Moneda de la compensación
	@param nTxMoeda - Tasa de la moneda de Compensación
	@param cCamposE5- Cadena con estructura de SE5
/*/		
Function Fn450CnvAc(nJRBaixa,nMulta,nCMBaixa,nDescont,nAcresc,nDecresc,nMoedaBco,nTxMoeda,cCamposE5 )
Local nJRsC := 0
Local nMltC := 0
Local nCMBxC := 0
Local nDstoC := 0
Local nAcrC := 0
Local nDecrC := 0
	//Conversión de valores de moneda de compensación a moneda del Titulo
	nJRsC 	:= fn450CmMon(nJRBaixa,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
	nMltC	:= fn450CmMon(nMulta,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
	nCMBxC 	:= fn450CmMon(nCMBaixa,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
	nDstoC 	:= fn450CmMon(nDescont,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
	nAcrC  	:= fn450CmMon(nAcresc,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
	nDecrC 	:= fn450CmMon(nDecresc,SE2->E2_MOEDA,nMoedaBco, nTxMoeda)
		
	cCamposE5 += ",{'E5_VLJUROS' , "+cValToChar(nJRsC)+" }"
	cCamposE5 += ",{'E5_VLMULTA' , "+cValToChar(nMltC)+" }"
	cCamposE5 += ",{'E5_VLCORRE' , "+cValToChar(nCMBxC)+" }"
	cCamposE5 += ",{'E5_VLDESCO' , "+cValToChar(nDstoC)+" }"
	cCamposE5 += ",{'E5_VLACRES' , "+cValToChar(nAcrC)+" }"
	cCamposE5 += ",{'E5_VLDECRE' , "+cValToChar(nDecrC)+" }"
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa080SetMd
Mostra a tela de taxas de moeda 

@author Fernando Machima
@since 09/01/2001
/*/
//-------------------------------------------------------------------
Function Bx080SetMd(aTxMoedas)

	Local nCentMd1	:= MsDecimais(1)
	Local oDlg, nLenMoedas	
	Local nOpc := 0
	Local aBkpMoedas := {}
	Default aTxMoedas := {}

	nLenMoedas	:= Len(aTxMoedas)

	aBkpMoedas := aClone(aTxMoedas)

	If nLenMoedas > 1
		DEFINE MSDIALOG oDlg From 200,0 TO 362,230 TITLE OemToAnsi(STR0006) PIXEL
		@ 005,005  To 062,110 OF oDlg PIXEL
		@ 012,010 SAY  aTxMoedas[2][1]  Of oDlg PIXEL
		@ 010,060 MSGET aTxMoedas[2][2] PICTURE aTxMoedas[1][3] VALID aTxMoedas[2][2]>0 Of oDlg PIXEL  HASBUTTON
		If nLenMoedas > 2
			@ 024,010 SAY  aTxMoedas[3][1]  Of oDlg PIXEL
			@ 022,060 MSGET aTxMoedas[3][2] PICTURE aTxMoedas[2][3] VALID aTxMoedas[3][2]>0 Of oDlg PIXEL HASBUTTON
			If nLenMoedas > 3
				@ 036,010 SAY  aTxMoedas[4][1]  Of oDlg PIXEL
				@ 034,060 MSGET aTxMoedas[4][2] PICTURE aTxMoedas[3][3] VALID aTxMoedas[4][2]>0 Of oDlg PIXEL  HASBUTTON
				If nLenMoedas > 4
					@ 048,010 SAY  aTxMoedas[5][1]  Of oDlg PIXEL
					@ 046,060 MSGET aTxMoedas[5][2] PICTURE aTxMoedas[4][3] VALID aTxMoedas[5][2]>0 Of oDlg PIXEL  HASBUTTON
				Endif
			Endif
		Endif
		DEFINE SButton FROM 064,80 TYPE 1 Action (nOpc:=1, oDlg:End() ) ENABLE OF oDlg PIXEL

		ACTIVATE MSDialog oDlg CENTERED

		If nOpc <> 1  // nao confirmou, volta o backup das taxas
			aTxMoedas := aClone( aBkpMoedas)
		EndIf
		nDifCambio	:= ( Round( (SE2->E2_VALOR * aTxMoedas[SE2->E2_MOEDA][2]), nCentMd1 ) - Round( SE2->E2_VLCRUZ, nCentMd1 ) )

	Endif

Return( aTxMoedas[SE2->E2_MOEDA][2] )

//-------------------------------------------------------------------
/*{Protheus.doc} F450VldOk
Verifica na confirmacao da tela, a validacao do valor - WIN
Copiada de FINA450 (Fa450ValOk)
@author Pilar S Albaladejo
@since   12/03/1997
*/
//-------------------------------------------------------------------
Static Function F450VldOk(nValor,nOldVal,nJur,nDesc,nMulta)
	Local nCasDec 		:= TamSx3("E1_TXMOEDA")[2]
	RecLock("TRB")
	If TRB->RECEBER != 0
		If Empty(TRB->MARCA)
			nSelecR += nOldVal
		ElseIf nJur != JUROS
			nSelecR := nOldVal - nJur
		EndIf
		If nDesc != DESCONT .And. !Empty(TRB->MARCA)
			nSelecR := nOldVal + nDesc
		EndIf
		If nMulta != MULTA .And. !Empty(TRB->MARCA)
			nSelecR := nOldVal - nMulta		
		Endif
		Replace RECEBER	With nValor
	Else
		If Empty(TRB->MARCA)
			nSelecP += nOldVal
		ElseIf nJur != JUROS
			nSelecP := nOldVal + nJur
		EndIf
		If nDesc != DESCONT .And. !Empty(TRB->MARCA)
			nSelecP := nOldVal - nDesc
		EndIf
		If nMulta != MULTA .And. !Empty(TRB->MARCA)
			nSelecP := nOldVal + nMulta		
		Endif
		Replace PAGAR With nValor
	EndIf
	If cPaisLoc == "MEX" .and. lMonedaC
		Replace VALORM	With  Round(xMoeda(nValor, TRB->MONEDA, nMoeda, dBaixa, nCasDec, aTxMoedas[TRB->MONEDA][2], aTxMoedas[nMoeda][2]), 2) 
	Endif
	Replace MARCA		With cMarca
	Replace JUROS		With nJur
	Replace DESCONT	With nDesc
	Replace MULTA 	With nMulta
	MsUnlock()

Return

//-------------------------------------------------------------------------
/*/{Protheus.doc} F450VldDoc
Posiciona o titulo na tabela SE2 para validacao dos documentos obrigatorios
Copiada de FINA450 (FA450ValDocs)
@author Renan G. Alexandre
@since  25/02/2011
@version 12
/*/
//-------------------------------------------------------------------------
Static Function F450VldDoc(cTitulo,lTodos,lArea,lEmail,lPrimeiro)
	Local aArea			:= {}
	Local aAreaSE2		:= {}
	Local cSE2Filtro	:= SE2->(dbFilter())
	Local lRet			:= .T.
	Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)		//Controle de validacao de documentos obrigatorios

	Default lTodos 		:= .F.
	Default lArea		:= .F.
	Default lEmail		:= .F.
	Default lPrimeiro		:=.F.

	If lFinVDoc
		
		aArea := GetArea()
		If Select("SE2") > 0
			aAreaSE2 := SE2->(GetArea())
		EndIf
		
		If lArea
			If !Empty(cSE2Filtro) 
				SE2->(dbClearFilter())
			EndIf
		EndIf
		
		dbSelectArea("SE2")
		dbSetOrder(1)		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		dbGoTop()

		If dbSeek(cTitulo)
			If lEmail
				CN062ValDocs("07",.F.,.T.)
			Else
				If !CN062ValDocs("07",.F.,.F.,lTodos,@lPrimeiro)
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lArea
			If !Empty(cSE2Filtro)
				SE2->(dbSetfilter({||&cSE2Filtro},cSE2Filtro)) 
			EndIf
		EndIf
		
		RestArea(aAreaSE2)
		RestArea(aArea)
		
	EndIf

Return(lRet)

/*/{Protheus.doc} fVldCheque
Verifica si el movimiento bancario es del tipo Cheque

@param cTipoSE5 Tipo de documento
@param cMoedaCH Moneda del movimiento

@author Luis Gerardo Cabrera Mata
@since  21/04/2021
@return	lRet - Retorna .T. si el movimiento es del tipo Cheque
/*/
function fVldCheque(cTipoSE5, cMoedaCH)
Local aAreaFJS := GetArea()
Local lTpCheq  := .F.

	FJS->(dbSetOrder(1))
	FJS->(dbSeek(xFilial("FJS") + cTipoSE5))
	If FJS->FJS_TIPOIN == "CH" .And. cMoedaCH $ "C1|C2|C3|C4|C5|CH"
		lTpCheq := .T.
	EndIf

	RestArea(aAreaFJS)

Return lTpCheq


// Calculo ITF


Function  FINCALITF( nRecnoSE5,nOpc,nBaseITF, lHeadPrv,aHdlPrv, aFlagCTB, cBuscaMod , aRecnoITF,cNumPRC)
	Local aAliasATU  := GetArea()
	Local aAreaSED   := SED->( GetArea() )
	Local aAreaSE5   := SE5->( GetArea() )
	Local aAreaFRM	  := If(cPaisLoc$"DOM|COS",FRM->( GetArea()),NIL)
	Local cProcTra	  := ''
	Local cCCC       := ''
	Local cCCD       := ''
	Local nMoed      := ''
	Local nTaxM      := ''
	Local cBanco     := ''
	Local cAgencia   := ''
	Local cConta     := ''
	Local lRet       := .F.
	Local nLinLoc    := 2
	Local nTotalLanc := 0
	Local nHdlPrv    := 0
	Local lFinITF    := ExistBlock("FinProcITF")
	Local cArquivo   := ''
	Local lLancPad   := .F.
	Local lRetorno
	Local cPadrao    := ""  //REVISAR O CODIGO ANTES DE FINALIZAR
	Local cProcesso  := ''
	Local nAliqITF   := 0
	Local nValor     := 0
	Local cPrograma := ''
	Local cLote     := ''
	Local nRecOpc5 := 0
	Local nValITF		:= 0
	Local nMinITF		:= 0
	Local lDomITF		:= .F.
	Local lDomDtVld	:= .F.
	Local lCalcBanc	:= .T.
	Local cNatITF		:= ""
	Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
	Local cTipoDoc		:= "IT" //Tipo para los registros de ITF
	Local cTipMov		:= ""
	
	Local nTotLc		:= 0
	Local aAreaAtu		:= {}

	/*
	* Reestrutura das tabelas do processo de movimento bancário
	*/
	Local oModelMov		:= NIL //FWLoadModel("FINM030") //Model de Mov. Bco.
	Local oModelDel		:= NIL //FWLoadModel("FINM030")
	Local oSubFKA		:= Nil	//RELACIONAMENTO
	Local oSubFK5		:= Nil	//MOVTO BANCARIO
	Local cFilSE5		:= FWxFilial("SE5")
	Local cCamposE5		:= ""
	Local cIdFK5		:= ""
	Local cLog			:= ""
	Local lArFlag			:= IIF(Type("aFlagCTB") != "A",.F.,.T.)  //  Verifica a existencia do Flag contabil
	Local cTipoM:= ""
	Local dData:= dDataBase

	Default nRecnoSE5 := 0
	Default nOpc      := 0
	Default nBaseITF  := 0
	Default lHeadPrv  := .F.
	Default aFlagCTB  := {}
	Default aHdlPrv   := {}
	Default aRecnoITF := {}
	Default cNumPRC	  := ""

	if cPaisLoc<>"COL"
		// PERU O BOLIVIA
		cCalcITF   := SuperGetMv("MV_CALCITF",.F.,"2")
		nPAliqITF  := SuperGetMv("MV_ALIQITF",.F.,0)
		cNatITF    := SuperGetMv("MV_NATITF",.F.,"")
	Else
		//SI ES COLOMBIA
		lCalcITF   := SuperGetMv("MV_IMP4MIL",.F.,.F.)
		nPAliqITF  := SuperGetMv("MV_AL4XMIL",.F.,0)
		lCalcBanc := IIF(POSICIONE("SA6",1,xfilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA,"A6_IMP4MIL")$"S|1",.T.,.F.)
	EndIf

	If Len(aHdlPrv) > 0
		cPrograma := aHdlPrv[4]
		cLote     := aHdlPrv[5]
	EndIf
	/* variavel nOpc
		nOpc == 1  " Valida se e o Peru, e se o parametro MV_CALCITF esta ativo. Caso positivo, verifica se os outros paramentros estao preenchidos, se nao estiverem retorna .F."
		nOpc == 2  " Valida se toda parametricao para utilizar a ITF na contabilizacao e se a natureza do movimento bancario e a da ITF
		nOpc == 3  " Realizo tentiva de incluir lancamento de imposto ITF no movimento bancario. "
		nOpc == 5  " Realizo lancamento oposto do lancamento de imposto ITF no movimento bancario "
		nOpc == 6  " Realizo estorno do lancamento de imposto ITF no movimento bancario "
		nOpc == 7  " Realizo exclusao do lancamento de imposto ITF no movimento bancario "
		nOpc == 8  " Realizo preparação para lançamento contabil utilizado na rotina FINA089"
	*/
	/* formato para o array aHdlPrv
	[1] = nHdlPrv
	[2] = codigo do lancamento padrao
	[3] = Programa inicializador do lancamento
	[4] = Programa
	[5] = Lote
	*/

	If SE5->( Recno() ) <> nRecnoSE5
		SE5->( DbGoTo( nRecnoSE5) )
	EndIf

	Default cBuscaMod :=SE5->E5_NATUREZ

	If cPaisLoc $ "DOM|COS"
		If nOpc >=1 .and. nOpc <=3
			SED->(DbSetOrder(1))
			If SED->(DbSeek(xFilial("SED")+cBuscaMod))
				FRM->(DbSetOrder(3))
				If (SED->ED_USO $ "24" .and.FRM->( DbSeek( xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"1"+"2"))) .OR. ;
					(SED->ED_USO $ "24" .and. FRM->(DbSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"3"+"2"))) .OR. ;
					(SED->ED_USO $ "13" .and. FRM->( DbSeek( xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"2"+"2"))) .OR. ;
					(SED->ED_USO $ "13" .and. FRM->(DbSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"3"+"2")))

				While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==("ITF"+Space(TamSX3("FRM_SIGLA")[1]-3))
					If FRM->FRM_MSBLQL <> "1" .and. FRM->FRM_BLOQ <> "1" .and. FRM->FRM_SEQ <> "000" .and. (SED->ED_USO $ "24" .and. FRM->FRM_CARTEI $ "13" .or. SED->ED_USO $ "13" .and. FRM->FRM_CARTEI $ "23") .and. FRM->FRM_INIVIG <= dDataBase .and. FRM->FRM_FIMVIG >= dDataBase
						lDomDtVld:=.T.
						Exit
					Else
						FRM->(DbSkip())
					Endif
				Enddo
				If lDomDtVld
					FRN->(DbSetOrder(2))
					If FRN->(DbSeek(xFilial("FRN")+SED->ED_CODIGO+FRM->FRM_COD+FRM->FRM_SEQ))
						While !FRN->(EOF()) .and. FRN->FRN_FILIAL==xFilial("FRN") .AND. FRN->FRN_CODNAT==SED->ED_CODIGO .AND. FRN->FRN_IMPOST==FRM->FRM_COD .AND. FRN->FRN_SEQ==FRM->FRM_SEQ
							If FRN->FRN_MSBLQL == "2"
								If !Empty(FRN->FRN_CONCEP)
									If CCR->(DbSeek(xFilial("CCR")+FRN->FRN_CONCEP))
										If CCR->CCR_REDUC > 0
											nAliqITF := CCR->CCR_ALIQ - (CCR->CCR_ALIQ * (CCR->CCR_REDUC / 100))
										Else
											nAliqITF := CCR->CCR_ALIQ / 100
										Endif
									Else
										nAliqITF := FRM->FRM_ALIQ / 100
									Endif
								Else
									nAliqITF := FRM->FRM_ALIQ / 100
								Endif
								lDomITF:=.T.
								Exit
							Endif
							FRN->(DbSkip())
							Enddo
						Endif
					Endif
				Endif
		Endif
	Endif
	Else
		nAliqITF := nPAliqITF / 100
	Endif

	cCCC     := SE5->E5_CCC
	cCCD     := SE5->E5_CCD
	nMoed    := SE5->E5_MOEDA
	nTaxM    := SE5->E5_TXMOEDA
	cBanco   := SE5->E5_BANCO
	cAgencia := SE5->E5_AGENCIA
	cConta   := SE5->E5_CONTA
	cCredito := SE5->E5_CREDITO
	cDebito  := SE5->E5_DEBITO
	nValor   := SE5->E5_VALOR
	cTipMov	 := SE5->E5_RECPAG	

	Begin Transaction

	If nOpc == 3
		cPadrao := '56A'
		If Len(aHdlPrv) > 0
			lLancPad := VerPadrao(cPadrao)
		EndIf

		SED->( DbSetOrder(1) )

		If nBaseITF == 0 .And. FinProcITF( nRecnoSE5,1 ,,,,,cBuscaMod)
			nBaseITF := SE5->E5_VALOR
		EndIf
		if cPaisLoc $ "BOL".And. cCalcITF == "1" .and. SA6->A6_MOEDA <> 1 .and. SA6->A6_EST <> "EX" .and. !(GetMv("MV_CXFIN") $ SA6->A6_COD).OR. (cPaisLoc $ "BOL" .and. SA2->A2_EST = 'EX')
			nBaseITF:=IIf(cPaisLoc == "BOL"  .and. cCalcITF == "1" .and. SA6->A6_MOEDA <> 1 .and. SA6->A6_EST <> "EX" .and. SE5->E5_VALOR == 0.OR. (cPaisLoc $ "BOL" .and.SA2->A2_EST = 'EX'),SE5->E5_VLMOED2,SE5->E5_VALOR)
		EndIf

		If Funname() $ "FINA087A|FINA085A"
			nBaseITF:=IIf(cPaisLoc == "BOL"  .and. cCalcITF == "1" .and. SA6->A6_MOEDA <> 1 .and. SA6->A6_EST <> "EX".and.SE5->E5_VALOR == 0,SE5->E5_VLMOED2,SE5->E5_VALOR)
		EndIf

		nValITF := Round(nBaseITF * nAliQITF,MsDecimais(Val(nMoed)))
		If nValITF > nMinITF
			If cPaisloc=="BOL" .And. !Empty(cNumPRC)
				cProcTra	:= cNumPRC
			Else
				cProcTra	:= GetSx8Num("SE5","E5_PROCTRA","E5_PROCTRA"+cEmpAnt)
			Endif
			//Realizo a gravacao de vinculo entre os lancamentos no se5 para o caso de ser necessario excluir o movimento original e o lancamento ITF
			Reclock("SE5",.F.)
			SE5->E5_PROCTRA      := cProcTra
			ConfirmSx8()
			SE5->( MsUnlock() )

			//Carrego model de movimento bancario
			oModelMov:= FWLoadModel("FINM030")
			oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "IDPROC", FINFKSID('FKA','FKA_IDPROC') )
			//Informo os campos que devem ser gravados somente na SE5
			oSubFK5	:= oModelMov:GetModel("FK5DETAIL")
			oSubFKA	:= oModelMov:GetModel("FKADETAIL")

			//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
			cCamposE5 += " { "
			cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5	+ "'}"
			cCamposE5 += ",{'E5_CCC'		,'" + cCCC		+ "'}"
			cCamposE5 += ",{'E5_CCD'		,'" + cCCD		+ "'}"
			cCamposE5 += ",{'E5_CREDITO'	,'" + cCredito	+ "'}"
			cCamposE5 += ",{'E5_DEBITO'		,'" + cDebito	+ "'}"
			cCamposE5 += ",{'E5_PROCTRA'	,'" + cProcTra	+ "'}"
			cCamposE5 += ",{'E5_TIPO'		,'TF'}"
			cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"

			cCamposE5 += " } "

			If !oSubFKA:IsEmpty()
				oSubFKA:AddLine()
			EndIf
			cIdFK5 := FWUUIDV4()
			oSubFKA:SetValue( "FKA_IDORIG"  , cIdFK5 )
			oSubFKA:SetValue( "FKA_TABORI" , 'FK5' ) //Todo o recibo precisa do mesmo número de processo

			If !oSubFK5:IsEmpty()
				oSubFK5:AddLine()
			EndIf

			oSubFK5:SetValue( "FK5_RECPAG"	, "P")
			oSubFK5:SetValue( "FK5_HISTOR"	, IIF(cPaisLoc<>"COL","ITF","GMF")) //"Valor recebido por Recibo "
			oSubFK5:SetValue( "FK5_DATA"	, dDataBase)
			oSubFK5:SetValue( "FK5_DTDISP"	, dDataBase)	// 1-Imediato  2-Vencimento
			oSubFK5:SetValue( "FK5_TPDOC"	, "IT")
			oSubFK5:SetValue( "FK5_MOEDA"	, nMoed)
			oSubFK5:SetValue( "FK5_VALOR"	, nValITF)
			oSubFK5:SetValue( "FK5_BANCO"	, cBanco)
			oSubFK5:SetValue( "FK5_AGENCI"	, cAgencia)
			oSubFK5:SetValue( "FK5_CONTA"	, cConta)
			oSubFK5:SetValue( "FK5_NATURE"	, cNatITF)
			oSubFK5:SetValue( "FK5_TXMOED"	, nTaxM)
			oSubFK5:SetValue( "FK5_ORIGEM"	, FunName())
			
			oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

			If oModelMov:VldData()
				oModelMov:CommitData()

			Else
				lRet := .F.
				cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
				Help( ,,"M030VALID",,cLog, 1, 0 )
			Endif

			oModelMov:DeActivate()
			oModelMov:Destroy()
			oModelMov:= Nil
			//atualizo o saldo bancario reduzindo o valor da ITF
			AtuSalBco( cBanco, cAgencia, cConta, dDatabase, nValITF , "-" )
			lRet := .T.
		EndIf

	ElseIf nOpc == 1 //verificacao se e o sistema esta parametrizado corretamente para lancamento de ITF
		SED->( DbSetOrder(1) )
		If cPaisLoc $ "PER|DOM|COS" .And. AllTrim(cCalcITF) == "1" .And. ValType(nAliqITF) == "N"	 .And. nAliqITF > 0 .And. !Empty(cNatITF) ;
			.And. SED->( MsSeek( xFilial("SED") + cNatITF ) ) .And. SED->( MsSeek( xFilial("SED") + cBuscaMod ) ) .And. ;
			If(cPaisLoc=="PER" .And. SED->ED_CALCITF == '1',.T., iF(lDomITF,.T.,.F.) )
			lRet := .T.
		Else
			If cPaisLoc $ "COL"	.and. lCalcITF .And. ValType(nAliqITF) == "N"	 .And. nAliqITF > 0 .and. lcalcBanc .And. cTipMov == "P"
				lRet:= .T.
			Elseif cPaisLoc $ "BOL".And. cCalcITF == "1" .and. SA6->A6_MOEDA <> 1 .and. SA6->A6_EST <> "EX" .and. ((!(GetMv("MV_CXFIN") $ SA6->A6_COD) .And. !(SA6->A6_COD $ GetMv("MV_CARTEIR"))    ) .Or. IsCaixaLoja(cBanco)) .or. ;
			 (cPaisLoc $ "BOL" .and. POSICIONE("SA2",1,xfilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A2_EST")  == 'EX')
				lRet:= .T.
			EndIf
		EndIf
	ElseIf nOpc == 2//verificacao para identificar se o movimento e de ITF
		If cPaisLoc $ "PER|DOM|COS|BOL" .And. AllTrim(cCalcITF) == "1" .And. ValType(nAliqITF) == "N"	 .And. nAliqITF > 0 .And. !Empty(cNatITF)
			If !Empty(AllTrim(SE5->E5_NATUREZ))
				lRet := AllTrim(SE5->E5_NATUREZ) == AllTrim(cNatITF)
			Else
				lRet := .T.
			EndIf
		EndIf
	ElseIf nOpc == 6

		cPadrao := '56B'
		If Len(aHdlPrv) > 0
			lLancPad := VerPadrao(cPadrao)
		EndIf
		If FinProcITF( nRecnoSE5,1 )
			If cPaisLoc $ "COL|BOL"
				nValor := Round(nValor * nAliQITF,MsDecimais(Val(nMoed)))

				SE5->(DbSetOrder(15))
				cProcesso := SE5->E5_PROCTRA
				cTipoM:= Alltrim(SE5->E5_RECPAG)
				dData:= SE5->E5_DATA
				If SE5->( MsSeek(xFilial("SE5") + cProcesso ))
					Do While SE5->( SE5->E5_FILIAL + SE5->E5_PROCTRA == xFilial("SE5") + cProcesso )
						If Alltrim(SE5->E5_TIPODOC) == Alltrim(SE5->E5_TIPODOC) .And. AllTrim(SE5->E5_NATUREZ) == AllTrim(cNatITF)
							RecLock("SE5",.F.)
							IF cPaisLoc == "BOL" .And. Alltrim(SE5->E5_RECPAG) == "P" .And. Alltrim(SE5->E5_TIPODOC) =="IT"
								nRecOpc5 := SE5->(Recno())
								SE5->E5_SITUACA      := 'X'
							ElseIf cPaisLoc <> "BOL"
								nRecOpc5 := SE5->(Recno())
								SE5->E5_SITUACA      := 'X'
							EndIf
							SE5->(MsUnlock())
						EndIf
						SE5->( DbSkip() )
					EndDo
				EndIf
			EndIf
			If cPaisLoc== "BOL" .and. nRecOpc5 > 0
				SE5->(DbGoTo(nRecOpc5))
			EndIf
			//Carrego model de movimento bancario
			oModelMov:= FWLoadModel("FINM030")
			oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "IDPROC", FINFKSID('FKA','FKA_IDPROC') )
			//Informo os campos que devem ser gravados somente na SE5
			oSubFK5	:= oModelMov:GetModel("FK5DETAIL")
			oSubFKA	:= oModelMov:GetModel("FKADETAIL")

			//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
			cCamposE5 += " { "
			cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5	+ "'}"
			cCamposE5 += ",{'E5_CCC'		,'" + cCCC		+ "'}"
			cCamposE5 += ",{'E5_CCD'		,'" + cCCD		+ "'}"
			cCamposE5 += ",{'E5_CREDITO'	,'" + cDebito	+ "'}"
			cCamposE5 += ",{'E5_DEBITO'		,'" + cCredito	+ "'}"
			cCamposE5 += ",{'E5_PROCTRA'	,'" + cProcesso	+ "'}"
			cCamposE5 += ",{'E5_TIPO'		,'TF'}"
			cCamposE5 += ",{'E5_SITUACA'	,'E'}"
			cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"

			cCamposE5 += " } "

			If !oSubFKA:IsEmpty()
				oSubFKA:AddLine()
			EndIf
			cIdFK5 := FWUUIDV4()
			oSubFKA:SetValue( "FKA_IDORIG"  , cIdFK5 )
			oSubFKA:SetValue( "FKA_TABORI" , 'FK5' ) //Todo o recibo precisa do mesmo número de processo

			If !oSubFK5:IsEmpty()
				oSubFK5:AddLine()
			EndIf

			//Realizo a gravacao do lancamento da ITF na movimentacao bancaria de estorno
			oSubFK5:SetValue( "FK5_RECPAG"	, "R")
			oSubFK5:SetValue( "FK5_HISTOR"	, IIF(cPaisLoc<>"COL","ITF","GMF")) //"Valor recebido por Recibo "
			oSubFK5:SetValue( "FK5_DATA"	, dDataBase)
			oSubFK5:SetValue( "FK5_DTDISP"	, dDataBase)	// 1-Imediato  2-Vencimento
			oSubFK5:SetValue( "FK5_TPDOC"	, "IT")
			oSubFK5:SetValue( "FK5_MOEDA"	, nMoed)
			oSubFK5:SetValue( "FK5_VALOR"	, nValor)
			oSubFK5:SetValue( "FK5_BANCO"	, cBanco)
			oSubFK5:SetValue( "FK5_AGENCI"	, cAgencia)
			oSubFK5:SetValue( "FK5_CONTA"	, cConta)
			oSubFK5:SetValue( "FK5_NATURE"	, cNatITF)
			oSubFK5:SetValue( "FK5_TXMOED"	, nTaxM)
			oSubFK5:SetValue( "FK5_ORIGEM"	, FunName())

			oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

			If oModelMov:VldData()
				oModelMov:CommitData()

			Else
				lRet := .F.
				cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
				Help( ,,"M030VALID",,cLog, 1, 0 )
			Endif
				oModelMov:DeActivate()
				oModelMov:Destroy()
				oModelMov:= Nil
			//atualizo o saldo bancario reduzindo o valor da ITF
			AtuSalBco( cBanco, cAgencia, cConta, dDatabase, nValor , "+" )
			lRet := .T.
		EndIf
	ElseIf nOpc == 5
		cPadrao := '56B'
		If Len(aHdlPrv) > 0
			lLancPad := VerPadrao(cPadrao)
		EndIf
		SE5->(DbSetOrder(15))
		cProcesso := SE5->E5_PROCTRA
		If SE5->( MsSeek(xFilial("SE5") + cProcesso ))
			Do While SE5->( SE5->E5_FILIAL + SE5->E5_PROCTRA == xFilial("SE5") + cProcesso )
				If cPaisLoc $ "BOL" .AND. AllTrim(SE5->E5_NATUREZ) == AllTrim(cNatITF) .And. AllTrim(SE5->E5_TIPODOC) == cTipoDoc  .OR.;
					cPaisLoc <> "BOL" .AND. (SE5->E5_TIPODOC == Space(Len(SE5->E5_TIPODOC)) .Or. AllTrim(SE5->E5_TIPODOC) == cTipoDoc).And. AllTrim(SE5->E5_NATUREZ) == AllTrim(cNatITF)
					nRecOpc5 := SE5->(Recno())

					//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
					cCamposE5 += " { "
					cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5	+ "'}"
					cCamposE5 += ",{'E5_CCC'		,'" + cCCC		+ "'}"
					cCamposE5 += ",{'E5_CCD'		,'" + cCCD		+ "'}"
					cCamposE5 += ",{'E5_CREDITO'	,'" + cDebito	+ "'}"
					cCamposE5 += ",{'E5_DEBITO'		,'" + cCredito	+ "'}"
					cCamposE5 += ",{'E5_PROCTRA'	,'" + cProcesso	+ "'}"
					cCamposE5 += ",{'E5_SITUACA'	,'C'}"
					cCamposE5 += " } "

					oModelDel:= FWLoadModel("FINM030")
					oModelDel:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
					oModelDel:Activate()
					oModelDel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
					//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
					//E5_OPERACAO 2 = Grava E5 com E5_TIPODOC = 'ES' e gera estorno na FK5
					//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
					oModelDel:SetValue( "MASTER", "E5_OPERACAO", 1 ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
					oModelDel:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					oSubFKA := oModelDel:GetModel( "FKADETAIL" )
					If oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

						If oModelDel:VldData()
							oModelDel:CommitData()
						Else
							lRet := .F.
							cLog := cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
							cLog += cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])

							Help( ,,"M030VALID",,cLog, 1, 0 )
						Endif
					Endif
					oModelDel:DeActivate()
					oModelDel:Destroy()
					oModelDel:= Nil
					If(cPaisLoc == "BOL" .AND. (IsInCallStack("FINA090") .OR. IsInCallStack("FINA086")))
						nValor:= SE5->E5_VALOR
					EndIf
					AtuSalBco( cBanco, cAgencia, cConta, dDatabase, nValor , "+" )
					lRet := .T.
				EndIf
				SE5->( DbSkip() )
			EndDo
			If nRecOpc5>0
				SE5->(DbGoTo(nRecOpc5))
			Endif
		EndIf
	ElseIf nOpc == 7
		cPadrao := '56B'
		If Len(aHdlPrv) > 0
			lLancPad := VerPadrao(cPadrao)
		EndIf
		SE5->(DbSetOrder(15))
		cProcesso := SE5->E5_PROCTRA
		If SE5->( MsSeek(xFilial("SE5") + cProcesso ))
			Do While SE5->( SE5->E5_FILIAL + SE5->E5_PROCTRA == xFilial("SE5")+cProcesso )
				If SE5->E5_TIPODOC == Space(Len(SE5->E5_TIPODOC)) .And. SE5->E5_NATUREZ == cNatITF
					oModelDel:= FWLoadModel("FINM030")
					oModelDel:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
					oModelDel:Activate()
					oModelDel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
					//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
					//E5_OPERACAO 2 = Grava E5 com E5_TIPODOC = 'ES' e gera estorno na FK5
					//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
					oModelDel:SetValue( "MASTER", "E5_OPERACAO", 3 ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					oSubFKA := oModelDel:GetModel( "FKADETAIL" )
					If oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

						If oModelDel:VldData()
							oModelDel:CommitData()
						Else
							lRet := .F.
							cLog := cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
							cLog += cValToChar(oModelDel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])

							Help( ,,"M030VALID",,cLog, 1, 0 )
						Endif
					Endif
					oModelDel:DeActivate()
					oModelDel:Destroy()
					oModelDel:= Nil

					AtuSalBco( cBanco, cAgencia, cConta, dDatabase, nValor , "+" )
					lRet := .T.
				EndIf
				SE5->( DbSkip() )
			EndDo
		EndIf
	ElseIf nOpc==8
		lRet := .T.
	EndIf

	If lRet .And. (nOpc == 3 .Or. nOpc == 5 .Or. nOpc == 6 .Or. nOpc==8)
		If nOpc==8
		cPadrao := '56A'
		If Len(aHdlPrv) > 0
			lLancPad := VerPadrao(cPadrao)
		EndIf
		Endif
		// utilizo a variavel aFlagCTB para o caso em que a chamada da gravacao da ITF ja esteja dentro de uma contabilizacao
		If lLancPad
			If lHeadPrv
				nHdlPrv := HeadProva( aHdlPrv[5],;
									aHdlPrv[3],;
									substr( cUsuario, 7, 6 ),;
									@cArquivo )

				If nHdlPrv <= 0
					Help(" ",1,"A100NOPROV")
					lRet := .F.
				EndIf
			Else
				nHdlPrv := aHdlPrv[1]
			EndIf
			If Len(aHdlPrv) > 0 .And. lRet .And. Valtype(nHdlPrv) == "N" .And. nHdlPrv > 0
				nTotLc:=  DetProva( 	nHdlPrv,;
														cPadrao/*cPadrao*/,;
														cPrograma/*cPrograma*/,;
														cLote/*Lote*/,;
														@nLinLoc,;
														/*lExecuta*/,;
														/*cCriterio*/,;
														/*lRateio*/,;
														/*cChaveBusca*/,;
														/*aCT5*/,;
														/*lPosiciona*/,;
														@aFlagCTB,;
														/*aTabRecOri*/,;
														/*aDadosProva*/ )
														
				//+-----------------------------------------------------+
				//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
				//+-----------------------------------------------------+
				nTotalLanc := nTotalLanc +  nTotLc 
				If cPaisLoc == "BOL"  .And.  nTotLc >0 
					If  lArFlag .And. lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil se o array existir
						aAdd( aFlagCTB, { "E5_LA" , "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )     
						aAdd( aFlagCTB, { "FK5_LA", "S", "FK5", FK5->( RecNo() ), 0, 0, 0} )     
					Else	          
					    aAreaAtu:=GetArea()

						dbSelectArea("SE5")
						RecLock("SE5",.F.)
						SE5->E5_LA    := "S"
			   			MsUnLock()
						
						dbSelectArea("FK5") 
						RecLock("FK5",.F.)
						FK5->FK5_LA    := "S"
		   				MsUnLock()
		   			
						RestArea(aAreaAtu)
					EndIf	
					
				EndIf  
				 nTotLc:=0
			EndIf
		EndIf
	EndIf
	End Transaction

	//Realizo a gravacao do lancamento da ITF na movimentacao bancaria
	AADD(aRecnoITF,SE5->(Recno()))

	If lFinITF
		lRetorno:= ExecBlock("FINPROCITF",.F.,.F.,{nRecnoSE5,nOpc})
		If Valtype(lRetorno)== "L"
			lRet := lRetorno
		EndIf
	EndIf
	If cPaisLoc$"DOM|COS"
		RestArea(aAreaFRM)
	Endif
	RestArea( aAreaSED )
	RestArea( aAreaSE5 )
	RestArea( aAliasATU)
Return(lRet)



// Valida script de anulaçao FINA100 - ADVPR.

Function  VldAdvpr(aAutoCab,nOpcAuto)
Local aAreaSE5  := GetArea()
Default aAutoCab := {}
Default nOpcAuto := 5 // Anulação.

nPosData := AScan(aAutoCab, {|campo| Upper(campo[1]) == "E5_DATA"}) 
nPosBanc := AScan(aAutoCab, {|campo| Upper(campo[1]) == "E5_BANCO"}) 
nPosAgen := AScan(aAutoCab, {|campo| Upper(campo[1]) == "E5_AGENCIA"}) 
nPosCont := AScan(aAutoCab, {|campo| Upper(campo[1]) == "E5_CONTA"})
nPosCheq := AScan(aAutoCab, {|campo| Upper(campo[1]) == "E5_NUMCHEQ"}) 

dbSelectArea("SE5")
IF nPosBanc > 0 .and. nPosAgen > 0 .and. nPosCont > 0 .and. nPosCheq > 0 
	dbSetOrder(1)
	dbSeek(xFilial("SE5")+DTOS(aAutoCab[nPosData][2])+aAutoCab[nPosBanc][2]+aAutoCab[nPosAgen][2]+aAutoCab[nPosCont][2]+aAutoCab[nPosCheq][2] )
	Fa100Can("SE5",SE5->(Recno()),nOpcAuto)
Else
	Fa100Can("SE5",SE5->(Recno()),nOpcAuto)
EndIF

RestArea(aAreaSE5)
Return

// Valida Anulaçao de movimento bancarios vinculado a cheque. FINA100

Function  VldCanCh(nPos)
Local aAreaSE5  := GetArea()
Local aAreaSEF  := GetArea()
Local lAchoCH 	:= .F.
Local nSitCH	:= ""
Default nPos 	:= 1

DbSelectArea("SEF")
DbSetOrder(10)
If DbSeek(xFilial("SEF") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA + SE5->E5_TALAO, .F.) // EF_FILIAL, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_TALAO, R_E_C_N_O_, D_E_L_E_T_
	lAchoCH := .F.
	While SEF->(!Eof()) .and. SE5->E5_TALAO == SEF->EF_TALAO .and. !lAchoCH
		If SEF->EF_NUM == SE5->E5_NUMCHEQ 
			lAchoCH := .T.
			nSitCH := SEF->EF_STATUS
		Else
			SEF->(dbSkip())
		EndIF
	EndDo
EndIf

IF nPos = 1
	IF  !(nSitCH $ "00|02|03|06") 
		MSGALERT(STR0008, STR0009) // "El movimiento bancario no puede ser anulado, pues tiene un cheque vinculado.", "Aviso"  
		lAchoCH := .F.
	Else
		IF nSitCH $ "00|06"
			MSGALERT( STR0007, STR0009) //El movimiento bancario no puede ser anulado, puesto que el cheque origen se encuentra en estatus sustituido., Aviso
			lAchoCH := .F.
		EndIF
	EndIF
Else
	IF nSitCH == "02"
		RecLock("SEF",.F.)
			SEF->EF_STATUS		:= "00"
			SEF->EF_BENEF		:= ""
			SEF->EF_VENCTO		:= Ctod("")
			SEF->EF_DATA		:= Ctod("")
			SEF->EF_DATAPAG		:= Ctod("")
			SEF->EF_HIST 		:= ""
			SEF->EF_REFTIP 		:= ""
			SEF->EF_LIBER 		:= "S"
			SEF->EF_FORNECE		:= ""
			SEF->EF_LOJA		:= ""
			SEF->EF_LA     		:= ""
			SEF->EF_SEQUENC		:= ""
			SEF->EF_PARCELA		:= ""
			SEF->EF_TITULO  	:=	""
			SEF->EF_TIPO    	:=	"CH"
			SEF->EF_IMPRESS    	:=	""
			SEF->EF_VALOR		:=	0
		SEF->(MSUnlock())
		f100GrvFRF("P","99","ANULADO NA MOV. BANCARIA")
	Else
		IF nSitCH == "03"
			RecLock("SEF",.F.)
				SEF->EF_STATUS		:= "05"
			SEF->(MSUnlock())
			f100GrvFRF("P","99","ANULADO NA MOV. BANCARIA")
		EndIf
	EndIF
EndIF
SEF->(DbCloseArea())
RestArea(aAreaSE5)
RestArea(aAreaSEF)
Return(lAchoCH)


// Rotina fA100GrvFRF do fonte FINA100 é Static.
// Foi criada a função f100GrvFRF para gravar os itens da funcao VldCanCh
Static Function f100GrvFRF(cCarteira,cMotivo,cDescricao)
Local cSavArea := GetArea()
Local cSeqFRF := GetSx8Num("FRF","FRF_SEQ")

//Gravar o histórico para as alterações de status do cheque.
RecLock("FRF",.T.)
FRF->FRF_FILIAL	 := xFilial("FRF")
FRF->FRF_BANCO	 := SEF->EF_BANCO
FRF->FRF_AGENCIA := SEF->EF_AGENCIA
FRF->FRF_CONTA	 := SEF->EF_CONTA
FRF->FRF_NUM	 := SEF->EF_NUM
FRF->FRF_PREFIX	 := SEF->EF_PREFIXO
FRF->FRF_CART	 := cCarteira
FRF->FRF_DATPAG	 := SEF->EF_DATA
FRF->FRF_MOTIVO	 := cMotivo
If cCarteira == "P"
	FRF->FRF_FORNEC  := SEF->EF_FORNECE
Else
	FRF->FRF_CLIENT  := SEF->EF_CLIENTE
EndIf
FRF->FRF_LOJA	 := IIF(cCarteira == "P",SEF->EF_LOJA,SEF->EF_LOJACLI)
FRF->FRF_NUMDOC	 := SEF->EF_TITULO
FRF->FRF_DESCRI	 := cDescricao
FRF->FRF_SEQ	 := cSeqFRF
FRF->(MsUnLock())
ConfirmSX8()

RestArea(cSavArea)
Return

/*/{Protheus.doc} F030RetTit
Funcion que retorna el valor de retenciones del título.

@type Function
@author Marco Augusto González Rivera
@since  20/08/2021
@return	nValRet, Numerico, Retorna el valor de los titulos correspondientes a Retenciones.
@example F030RetTit() 
/*/
Function F030RetTit(cOrdPag, cPrefix, cNumDoc, cParcela)

	Local aArea			:= GetArea()
	Local nValRet		:= 0
	Local cTipoNot		:= ""
	Local cQuery		:= ""
	Local cLayoutSM0	:= ""
	Local lGestao		:= .F.
	Local lSE2Comp		:= .F.
	Local nPosAlias		:= 0
	Local cAliasTRB		:= ""

	If cPaisLoc == "EQU"
		
		cAliasTRB	:= GetNextAlias()
		cTipoNot	:= F030TipoIN(MVABATIM)
		cLayoutSM0	:= FWSM0Layout()
		lGestao		:= Substr(cLayoutSM0,1,1) $ "E|U"

		If lGestao
			If Substr(cLayoutSM0,1,1) == "E"
				lSE2Comp := FWModeAccess("SE2",1) == "C"
			Else
				lSE2Comp := FWModeAccess("SE2",2) == "C"
			EndIf
		Else
			lSE2Comp := FWModeAccess("SE2",3) == "C"
		EndIF

		cQuery := "SELECT E2_VALOR"
		cQuery += " FROM "+RetSqlName("SE2")+" SE2 "

		If !lSE2Comp
			nPosAlias := FC030QFil(1,"SE2")
			cQuery += "WHERE E2_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
		Else
			cQuery += "WHERE E2_FILIAL = '" + Space(TamSx3("E2_FILIAL")[1]) + "' AND "
		EndIf

		cQuery += "E2_ORDPAGO='" + cOrdPag    +"' AND "
		cQuery += "E2_PREFIXO='" + cPrefix    +"' AND "
		cQuery += "E2_NUM='" + cNumDoc    +"' AND "
		cQuery += "E2_PARCELA='" + cParcela    +"' AND "
		cQuery += "E2_FORNECE='" + SA2->A2_COD    +"' AND "
		cQuery += "E2_LOJA='"    + SA2->A2_LOJA   +"' AND "
		cQuery += "E2_EMISSAO>='"+ Dtos(mv_par01) +"' AND "
		cQuery += "E2_EMISSAO<='"+ Dtos(mv_par02) +"' AND "
		cQuery += "E2_VENCREA>='"+ Dtos(mv_par03) +"' AND "
		cQuery += "E2_VENCREA<='"+ Dtos(mv_par04) +"' AND "
		cQuery += "E2_TIPO IN " + cTipoNot +" AND "
		cQuery += "E2_VALOR != E2_SALDO AND "
		cQuery += "D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .T., .T.)

		(cAliasTRB)->(DBGoTop())

		While (cAliasTRB)->(!Eof())
			nValRet += (cAliasTRB)->E2_VALOR
			(cAliasTRB)->(DBSkip())
		End

		(cAliasTRB)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return nValRet
/*/{Protheus.doc} fn080ERFk2
	Actualiza FK2_VALOR, FK2_VLMOE2 y nMoedaBco desde rutina fina080       
	@type  Function
	@author Alf. Medrano  . - SQUAD Norte Andino
	@since 22/09/2022
	@version 1.0
	@param oSubFK2  - Objeto modelo FK2
	@param cCpoTp 	- Campo con Valor de Pago
	@param nMoedaBco- Moneda Banco. Valor de salida
	@param nMoedaTit- Moneda del titulo 
	@param nTxModTit- Tasa moneda del titulo 
	@param nTxModBco- Tasa moneda del compensación
	@param nCentMd1 - Decimales
/*/
Function fn080ERFk2(oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nCentMd1)
	
	nMoedaBco := SE2->E2_MOEDA
	oSubFK2:SetValue( "FK2_VALOR" , Round(NoRound(xMoeda( &cCpoTp, SE2->E2_MOEDA, nMoedaBco,,nCentMd1+1,, nTxModBco ),nCentMd1+1),nCentMd1) )
	oSubFK2:SetValue( "FK2_VLMOE2", Round(NoRound(xMoeda( &cCpoTp, SE2->E2_MOEDA, nMoedaTit,,nCentMd1+1,, nTxModTit ),nCentMd1+1),nCentMd1) )
	
Return Nil

/*/{Protheus.doc} FnAjBxOPMI
	Tratamiento de registros en SE5 con E5_SITUACA = 'C' que no cuenten con movimiento de retorno (tipo ES) en FKs
	@type Function
	@author oscar.lopez
	@since 30/10/2022
	@version version
	@param nPosSE5, numero, Recno tabla SE5
	@param dFchIni, fecha, Fecha de inicio periodo a procesar
	@param dFchFin, fecha, Fecha de fin periodo a procesar
	@return Nil
	@example
		FnAjBxOPMI(nPosSE5, dFchIni, dFchFin)
	/*/
Function FnAjBxOPMI(nPosSE5, dFchIni, dFchFin)
	Local aAreaTmp	:= {}
	Local cAliasSE2	:= GetNextAlias()
	Local cCliente	:= Space(FWSX3Util():GetFieldStruct("E5_CLIENTE",.F.)[3])
	
	Default nPosSE5 := 0 //Variavel com posição da SE5 que deve ser atualizada.

	If cPaisLoc	<> "BRA" .And. FunName() == "FINXSE5"
		aAreaTmp := GetArea()
		
		BeginSQL Alias cAliasSE2
			SELECT SE5.R_E_C_N_O_ RECNO, SE5.E5_TIPODOC TPDOC
			FROM %Table:SE5% SE5
			JOIN %Table:SE2% SE2
				ON
					SE5.E5_FILORIG     = SE2.E2_FILORIG
					AND SE5.E5_PREFIXO = SE2.E2_PREFIXO
					AND SE5.E5_NUMERO  = SE2.E2_NUM
					AND SE5.E5_PARCELA = SE2.E2_PARCELA
					AND SE5.E5_TIPO    = SE2.E2_TIPO
					AND SE5.E5_CLIFOR  = SE2.E2_FORNECE
					AND SE5.E5_CLIENTE = %Exp:cCliente%
					AND SE5.E5_LOJA    = SE2.E2_LOJA
					AND SE5.E5_NATUREZ = SE2.E2_NATUREZ
					AND SE2.%notDel%
			WHERE
				E5_DATA     >= %Exp:dFchIni%
				AND E5_DATA <= %Exp:dFchFin%
				AND E5_SITUACA IN ('C')
				AND E5_MOVFKS = 'S'
				AND E5_TIPODOC NOT IN ('PA')
				AND SE5.%notDel%
			UNION
			SELECT SE5.R_E_C_N_O_ RECNO, SE5.E5_TIPODOC TPDOC
			FROM %Table:SE5% SE5
			JOIN %Table:SE2% SE2
				ON
					SE5.E5_FILORIG     = SE2.E2_FILORIG
					AND SE5.E5_PREFIXO = SE2.E2_PREFIXO
					AND SE5.E5_NUMERO  = SE2.E2_NUM
					AND SE5.E5_PARCELA = SE2.E2_PARCELA
					AND SE5.E5_TIPO    = SE2.E2_TIPO
					AND SE5.E5_CLIFOR  = SE2.E2_FORNECE
					AND SE5.E5_CLIENTE = %Exp:cCliente%
					AND SE5.E5_LOJA    = SE2.E2_LOJA
					AND SE5.E5_NATUREZ = SE2.E2_NATUREZ
					AND SE2.%notDel%
			WHERE
				E5_TIPODOC IN('PA','BA')
				AND E5_DATA  >= %Exp:dFchIni%
				AND E5_DATA  <= %Exp:dFchFin%
				AND E5_MOTBX <> 'CMP'
				AND (E5_SITUACA IN ('C') OR SE5.D_E_L_E_T_ = '*')
				AND E5_MOVFKS = 'S'
			ORDER BY
				RECNO, TPDOC
		EndSQL

		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(DbGotop())

		While (cAliasSE2)->(!EoF())
			FnAjBxFKMI((cAliasSE2)->(RECNO))
			(cAliasSE2)->(DbSkip())
		EndDo
		(cAliasSE2)->(DbCloseArea())
		RestArea(aAreaTmp)
	EndIf
Return Nil

/*/{Protheus.doc} FnAjBxFKMI
	Anulación mediante modelo FINM020 de movimiento de Orden de Pago.
	@type Function
	@author oscar.lopez
	@since 27/10/2022
	@version version
	@param nRecSE5, número, Recno tabla SE5
	@return Nil
	@example
		FnAjBxFKMI(nRecSE5)
/*/
Function FnAjBxFKMI(nRecSE5)
	Local aArea		:= {}
	Local aAreaSE5	:= {}
	Local oModelBx	:= Nil
	Local oSubFKA	:= Nil
	Local cLog		:= ""
	Local cChavRes	:= ""

	Default nRecSE5 := 0
	
	If nRecSE5 > 0
		aArea		:= GetArea()
		aAreaSE5	:= SE5->(GetArea())

		DbSelectArea("SE5")
		SE5->(DbGoTo(nRecSE5))
		
		cIDFK	:= SE5->E5_IDORIG
		cHistFK := Alltrim(SE5->E5_HISTOR)
		cChave	:=  xFilial("SE5", SE5->E5_FILORIG) + ;
					"|" + SE5->E5_PREFIXO + ;
					"|" + SE5->E5_NUMERO + ;
					"|" + SE5->E5_PARCELA + ;
					"|" + SE5->E5_TIPO + ;
					"|" + SE5->E5_CLIFOR + ;
					"|" + SE5->E5_LOJA

		//Valida si ya existe movimiento de retorno (ES) para el documento a partir de la llave informada.
		cChavRes := FindBxKey(SE5->E5_TABORI,cChave, SE5->E5_SEQ, .T.)
		
		If SE5->E5_TIPODOC $ "VL|BA" .And. Empty(cChavRes)
			oModelBx := FWLoadModel("FINM020")
			oModelBx:SetOperation( 4 ) //Alteração

			oModelBx:Activate()
			oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
			oSubFKA := oModelBx:GetModel( "FKADETAIL" )
			oSubFKA:SeekLine( { {"FKA_IDORIG", cIDFK } } )

			//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
			//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
			//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
			oModelBx:SetValue( "MASTER", "E5_OPERACAO"	, IIf(!Empty(SE5->E5_SITUACA), 1,3) )
			oModelBx:SetValue( "MASTER", "HISTMOV"		, "ESTORNO " + cHistFK )

			If oModelBx:VldData()
				oModelBx:CommitData()
				oModelBx:DeActivate()
			Else
				cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelBx:GetErrorMessage()[6])
				IIf(FWIsInCallStack("FINXSE5") .Or. IsBlind(), ConOut(cLog), Help( ,,"M020VLD",,cLog, 1, 0 ))
			EndIf
			oModelBx:DeActivate()
			oModelBx:Destroy()
			oModelBx := NIL
		EndIf
		SE5->(RestArea(aAreaSE5))
		RestArea(aArea)
	EndIf
Return Nil

/*/{Protheus.doc} OriCobrDiv
	Función que retorna el nombre de la rutina nueva de rutina de Recibos, el cual se compara con
	el contenido del campo E1_ORIGEM
	@type Function
	@author eduardo.manriquez
	@since 30/03/2023
	@version version
	@return cOrigem, caracter, nombre de la nueva rutina de recibos
	@example
		OriCobrDiv()
/*/
Function OriCobrDiv()
	Local cOrigem := Iif(cPaisLoc $ "ARG|URU" .AND. IsInCallStack('Sel070Baixa'),"","FINA887")
Return cOrigem

/*/{Protheus.doc} OriSqlCob
	Función que retorna una instrucción SQL con el nombre 
	de la rutina nueva de rutina de Recibos.
	@type Function
	@author eduardo.manriquez
	@since 30/03/2023
	@version version
	@return cOriSql, caracter, Instrucción SQL con el nombre de la nueva rutina de recibos
	@example
		OriSqlCob()
/*/
Function OriSqlCob()
	Local cOriSql := " OR SE1.E1_ORIGEM ='FINA887'"
Return cOriSql

/*/{Protheus.doc} Fn134VlPg
	Valida, para el informe FINR134, si el registro corresponde a retención (IR-|IV-) y si debe ser impreso.
	@type Function
	@author oswaldo.diego
	@since 25/05/2023
	@version version
	@param cProveedor, Caracter, Campo auxiliar para el manejo del cambio de proveedor (es pasado como referencia)
	@param cNumMov, Caracter, Campo auxiliar para el manejo del cambio de número de título (es pasado como referencia)
	@param lValPago, Lógico, Campo auxiliar para el manejo de pagos parciales o totales del título (es pasado como referencia)
	@param nSaldo, Número, Saldo del título
	@param cE2Fornece, Caracter, Proveedor "actual", obtenido de la tabla SE2
	@param cE2Num, Caracter, Número del título "actual", obtenido de la tabla SE2
	@param cE2Tipo, Caracter, Tipo de documento "actual", obtenido de la tabla SE2
	@param nE2Valor, Número, Valor del documento "actual", obtenido de la tabla SE2
	@return lLoop, Lógico, Determina si el registro será "saltado" debido a que es una retención (IR-|IV-)
	                       y el título al que pertenece ya fue saldado total o parcialmente.
	@example
		Fn134VlPg(@cProveedor, @cNumMov, @lValPago, nSaldo, SE2->E2_FORNECE, SE2->E2_NUM, SE2->E2_TIPO, SE2->E2_VALOR)
/*/
Function Fn134VlPg(cProveedor, cNumMov, lValPago, nSaldo, cE2Fornece, cE2Num, cE2Tipo, nE2Valor)
	Local lLoop := .F.

	If cProveedor <> cE2Fornece .Or. cNumMov <> cE2Num
		cProveedor := cE2Fornece
		cNumMov    := cE2Num
		lValPago   := .F.
	EndIf

	If !(cE2Tipo $ "IV-|IR-")
		If (nE2Valor <> nSaldo .And. nSaldo > 0) .Or. nSaldo <= 0
			lValPago := .T.
		EndIf
	ElseIf lValPago 
		lLoop = .T.
	EndIf
	
Return lLoop

/*/{Protheus.doc} IsCallCobr
	Función que retorna una variable lógica que determina si
	la rutina nueva de rutina de Recibos esta en la pila de llamadas.
	@type Function
	@author eduardo.manriquez
	@since 05/04/2023
	@version version
	@return lRet, logical, Variable lógica que retorna .T. si la rutina nueva de rutina de Recibos esta en la pila de llamadas.
	@example
		IsCallCobr()
/*/
Function IsCallCobr()
	
	Local lRet := Iif(!(cPaisLoc $ "BRA|ARG"),IsInCallStack("FINA087A") .or. IsInCallStack("FINA887") .or. IsInCallStack("FINA998"),IsInCallStack("FINA087A"))

Return lRet

/*/{Protheus.doc} DelCHRepo()
	Función que retorna una variable lógica que determina si
	la liberación del cheque de talonario que se vinculó a la reposición fue exitosa.
	@type Function
	@author luis.mata
	@since 15/08/2023
	@version version
	@param aBco, Arreglo, arreglo que contiene la información bancaria del cheque.
	@param cTitulo, caracter,campo que contiene el  numero del cheque.
	@param cTalon, caracter, campo que contiene el numero correspondiente del talonario del cheque.
	@param cTipoDeb, caracter, campo que contiene el tipo de debitación.
	@param cFornece, caracter, campo que contiene el codigo del proveedor.
	@param cLoja, caracter, campo que contiene la loja del proveedor
	@return lRet, logical, Variable lógica que retorna .T. si la liberación del cheque de talonario que se vinculó a la reposición fue exitosa.
	@example
		DelCHRepo(aBco, SEU->EU_TITULO, SEU->EU_TALAO,SEU->EU_TIPDEB,SET->ET_FORNECE,SET->ET_LOJA)
/*/
Function DelCHRepo(aBco, cTitulo, cTalon,cTipoDeb, cFornece, cLoja)
Local aSef   := GetArea()
Local aSE2   := {}
Local cChave := ""

DEFAULT aBco := {}
DEFAULT cTitulo := ""
DEFAULT cTalon := ""
DEFAULT cTipoDeb := ""
DEFAULT cFornece := ""
DEFAULT cLoja := ""

//Verificar Status do Cheque para verificar si es posible su cancelación
dbSelectArea("SEF")
SEF->(DbSetOrder(9))//EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_TITULO                                                                                                                                                                                                           
If SEF->(dbSeek(xFilial("SEF")+aBco[1]+aBco[2]+aBco[3]+cTitulo,.T.))
	While !SEF->(Eof()) .and. SEF->EF_BANCO == aBco[1] ;
 			.and. SEF->EF_AGENCIA == aBco[2] ;
			.and. SEF->EF_CONTA == aBco[3];
			.and. AllTrim(SEF->EF_NUM) == AllTrim(cTitulo)
			
		If AllTrim(SEF->EF_TALAO) == AllTrim(cTalon) .And. !(SEF->EF_STATUS $ "06|03|04") //Verifica que no sea un CH Sustituido|Emitido|Liquidado
			RecLock("SEF",.F.)
			SEF->EF_STATUS		:= "00"
			SEF->EF_BENEF		:= ""
			SEF->EF_VENCTO		:= Ctod("")
			SEF->EF_DATA		:= Ctod("")
			SEF->EF_DATAPAG		:= Ctod("")
			SEF->EF_HIST 		:= ""
			SEF->EF_REFTIP 		:= ""
			SEF->EF_LIBER 		:= "S"
			SEF->EF_FORNECE		:= ""
			SEF->EF_LOJA		:= ""
			SEF->EF_LA     		:= ""
			SEF->EF_SEQUENC		:= ""
			SEF->EF_PARCELA		:= ""
			SEF->EF_TITULO  	:=	""
			SEF->EF_TIPO    	:=	"CH"
			SEF->EF_IMPRESS    	:=	""
			SEF->EF_VALOR		:=	0
			SEF->(MsUnLock())
			If !IsBlind()
				Help(,,"Help",,STR0010 + AllTrim(SEU->EU_TITULO) + STR0011,1,0) 
			EndIf	
			If Left(cTipoDeb,1)=="1"  //debito deferido apagar registro do SE2
				aSE2:=GetArea()
				DbSelectArea("SE2")
				DbSetOrder(1)
				cChave:=xFilial("SE2")+SEF->EF_PREFIXO+cTitulo+Space(Len(E2_PARCELA))
				cChave+=Substr(cTipoDeb,2)+cFornece+cLoja
				If SE2->(DbSeek(cChave))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoIniLan("000002")
					FINDELFKs(xFilial("SE2")+ "|" + SE2->E2_PREFIXO+ "|" + SE2->E2_NUM+ "|" + SE2->E2_PARCELA+ "|" + SE2->E2_TIPO+ "|" + SE2->E2_FORNECE+ "|" + SE2->E2_LOJA, "SE2")
					RecLock("SE2",.F.)
					DbDelete()
					MsUnLock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						PcoDetLan("000002","01","FINA550", .T.)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoFinLan("000002")
				Endif
			RestArea(aSE2)
		Endif	
		EndIf
		SEF->(dbSkip())
	EndDo 
Endif
SEF ->(dbCloseArea())
RestArea(aSef)


Return 

/*/{Protheus.doc} MI_EdiSDir
	Funcion para seleccionar directorio o archivo desde campo.
	@type  Function
	@author oscar.lopez
	@since 03/01/2024
	@version 1.0
	@return .T. (Verdadero)
	@example
		MI_EdiSDir()
	/*/
Function MI_EdiSDir()
	Local aArea		:= GetArea()
	Local cTipo		:= ""
	Local cCpoVld	:= ReadVar()

	If Type("lSelectArq") == "L" .And. lSelectArq
		cTipo := "*.JPG|*.jpg|*.bmp|*.BMP|*.png|*.PNG"
		&(cCpoVld) := cGetFile( cTipo, STR0012, 1, "c:\", .T., GETF_LOCALHARD + GETF_NETWORKDRIVE) //"Selección de Archivo"
	Else
		&(cCpoVld) := cGetFile( cTipo, STR0013, , , .F., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) //"Selección de Directorio"
	EndIf

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} fFA550RCan
	Validar reversión de reposición
	@type  Function
	@author ARodriguez
	@since 13/06/2024
	@version 1.0
	@param aEstor, array, lista de reposiciones para revertir
	@param nCanRep, caracter, reposición seleccionada del array aEstor
	@return lRet, lógico, se puede revertir?
	/*/
Function fFA550RCan(aEstor, nCanRep)
	Local aArea		:= GetArea()
	Local aAreaSEU	:= {}
	Local aAreaMov	:= {}
	Local cNroAdia	:= ""
	Local cSeqCxa	:= ""
	Local cCaixa	:= ""
	Local cFilSEU	:= xFilial("SEU")
	Local lRet		:= .T.
	Local lEncontro	:= .F.
	Local cTipo		:= ""

	Default aEstor	:= {}
	Default nCanRep	:= 0

	If Len(aEstor) > 0 .And. nCanRep > 0
		aAreaSEU := SEU->(GetArea())
		SEU->(dbSetOrder(1))	//EU_FILIAL+EU_NUM
		SEU->(msSeek(cFilSEU + aEstor[nCanRep,1]))
		cNroAdia := SEU->EU_NUM
		cSeqCxa := SEU->EU_SEQCXA
		cCaixa := SEU->EU_CAIXA
		SEU->(dbSetOrder(5))  //EU_FILIAL+EU_CAIXA+EU_SEQCXA+EU_NUM

		While !SEU->(Eof()) .And. (SEU->EU_FILIAL == cFilSEU) .And. (SEU->EU_CAIXA == cCaixa) .And. (SEU->EU_SEQCXA == cSeqCxa)
			If !SEU->EU_TIPO $ "10/02"
				cNroAdia := SEU->EU_NUM 
				aAreaMov := SEU->(GetArea())
				SEU->(dbSetOrder(3))  //EU_FILIAL+EU_NROADIA+EU_NUM
				lEncontro := SEU->( dbSeek( cFilSEU + cNroAdia ))
				cTipo := SEU->EU_TIPO
				SEU->(RestArea(AareaMov))
				If !( lEncontro .And. cTipo == "02" )
					Help(" ",1,"F560MOVREP")
					lRet := .F.
					Exit
				Endif
			EndIf
	
			SEU->(dbSkip())
		EndDo

		SEU->(RestArea(aAreaSEU))
		RestArea(aArea)
	EndIf

Return lRet

/*/{Protheus.doc} Fa550BxEU
Funcion para actualizar la fecha del documento dado de baja. 
@type function
@version  1.1
@author luis.mata
@since 10/17/2024
@param cCaixa, character, Codigo de caja 
@return null, return_no devuelve contenido
/*/
Function Fa550BxEU(cFilSEU,cCaixa)
	Local cSeqCxa := PadL((Val(Fa570SeqAtu( cCaixa))-1),6,'0')
	Local aAreaSEU := SEU->( GetArea() )

	Default cFilSEU := xFilial("SEU")
	Default cCaixa 	:= ""

	dbSelectArea("SEU")
	SEU->(dbSetOrder(5))  //EU_FILIAL+EU_CAIXA+EU_SEQCXA+EU_NUM
	SEU->(MsSeek(cFilSEU+ cCaixa + cSeqCxa))
	While !SEU->(Eof()) .And. cFilSEU+cCaixa+cSeqCxa == SEU->EU_FILIAL+SEU->EU_CAIXA+SEU->EU_SEQCXA
		If ( SEU->EU_TIPO == "00" .And. !Empty(SEU->EU_BAIXA))
			RecLock('SEU',.F.)
			Replace SEU->EU_BAIXA With CtoD("//")
			SEU->(MsUnlock())
		Endif
		SEU->(dbSkip())
	EndDo
	RestArea( aAreaSEU )
Return NIL

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXSE5
Función auxiliar para generar registro de reversión en la tabla FK5 para recibos de cobro que no poseen registro en la tabla FK1 y se encuentran ya anulados.
@type  Function
@author carlos.espinoza
--------------------
@since 09/01/2025
@version P12
/*/
//-----------------------------------------------------------------------------------------
Function EstorRaFK5(dDataI, dDataF)

	Local aAreaTmp	:= {}
	Local cAliasSE5	:= GetNextAlias()
	Local cAliasFK5	:= ""
	Local cDataIni  := DTOS(dDataI)
	Local cDataFin  := DTOS(dDataF)
	Local cProcAux  := ""
	Local cProc     := ""
	Local cRecSkip  := ""
	Local oModelBxR := Nil
	Local oFKA	    := Nil
	Local cRecibo   := ""
	Local aProcFK5  := {}
	Local nProcPos  := 0

	Default dDataI := dDataBase
	Default dDataF := dDataBase 

	aAreaTmp := GetArea()
	
	//Consulta de movimientos bancarios de recibos de cobros que ya fueron anulados
	BeginSQL Alias cAliasSE5
		SELECT 
			SE5.E5_IDORIG IDORIG, 
			SE5.E5_TIPODOC TIPODOC, 
			SE5.E5_TABORI TABORI, 
			SE5.E5_ORDREC ORDREC, 
			SE5.R_E_C_N_O_ RECNO
		FROM 
			%Table:SE5% SE5
		WHERE
			E5_DATA     >= %Exp:cDataIni%
			AND E5_DATA <= %Exp:cDataFin%
			AND E5_SITUACA = 'C'
			AND E5_MOVFKS = 'S'
			AND E5_RECPAG = 'R'
			AND E5_ORIGEM IN ('FINA087A','FINA887','FINA846')
			AND SE5.%notDel%
		ORDER BY 
			ORDREC, 
			TABORI
	EndSQL

	dbSelectArea(cAliasSE5)
	(cAliasSE5)->(DbGotop())

	While (cAliasSE5)->(!EoF())

		//Se ignoran los recibos de cobro que poseen movimientos bancarios diferentes de "VL" ya que esto es el indicador de que posee títulos financieros seleccionados
		If (cAliasSE5)->(TIPODOC) <> "VL" .Or. (cAliasSE5)->(ORDREC) == cRecSkip
			cRecSkip := (cAliasSE5)->(ORDREC)
			(cAliasSE5)->(dbSkip())
			Loop
		EndIf

		//Se verifica que no exista ningún registro en la tabla de Cuentas a Recibir FK1
		cProcAux := FINProcFKs((cAliasSE5)->(IDORIG), "FK1")
		If Empty(cProcAux)
			cRecibo := (cAliasSE5)->(ORDREC)
			//Se realiza consulta a la tabla FK5 para verificar que no exista el registro de reversión, ya que si este existe, no se debe de generar nuevamente el registro de reversión porque causaría una duplicidad
			cAliasFK5 := GetNextAlias()
			BeginSQL Alias cAliasFK5
				SELECT 
					FK5.FK5_ORDREC,
					FK5.FK5_IDMOV
				FROM 
					%Table:FK5% FK5
				WHERE
					FK5_ORDREC = %Exp:cRecibo%
					AND FK5_TPDOC = 'ES'
					AND FK5_RECPAG = 'P'
					AND FK5.%notDel%
			EndSQL

			//Se almacena el IDPROC referente al recibo de cobro en el arreglo aProcFK5 ya que pueden existir recibos de cobro con misma numeración pero distinta serie
			While (cAliasFK5)->(!EoF())
				AADD(aProcFK5, FINProcFKs((cAliasFK5)->(FK5_IDMOV), "FK5"))
				(cAliasFK5)->(DbSkip())
			EndDo

			cProcAux := FINProcFKs((cAliasSE5)->(IDORIG), "FK5")
			//Se valida que para el movimiento bancario actual no exista su movimiento de reversión utilizando la variable aProcFK5 que almacena los IDPROC de los movimientos de reversión encontrados
			nProcPos := aScan(aProcFK5,{|x| x == cProcAux})
			If nProcPos == 0 .And. (cAliasSE5)->(TIPODOC) $ "VL" .And. cProc <> cProcAux
				cProc := cProcAux
				SE5->(dbGoTo((cAliasSE5)->RECNO))
				oModelBxR := FWLoadModel("FINM010") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
				oModelBxR:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
				oModelBxR:Activate()
				oModelBxR:SetValue("MASTER", "E5_GRV", .T.) //Habilita gravação SE5
				//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
				oModelBxR:SetValue("MASTER", "E5_OPERACAO", 1)
				// oModelBxR:SetValue("MASTER", "HISTMOV", STR0013 + cRecibo)
				oModelBxR:SetValue("MASTER", "HISTMOV", "Reversión del recibo. " + cRecibo)
			
				//Posiciona a FKA com base no IDORIG da SE5 posicionada
				oFKA := oModelBxR:GetModel("FKADETAIL")
				oFKA:SeekLine({{"FKA_IDORIG", (cAliasSE5)->(IDORIG)}})
				oFKA:SetMaxLine(9999)
			
				If oModelBxR:VldData()
					oModelBxR:CommitData()
					oModelBxR:DeActivate()
				Endif
			EndIf
			nProcPos := 0
			aProcFK5 := {}
			(cAliasFK5)->(DbCloseArea())
		EndIf

		(cAliasSE5)->(DbSkip())
	EndDo

	(cAliasSE5)->(DbCloseArea())
	
	RestArea(aAreaTmp)
Return

/*/{Protheus.doc} fn080mFk2
	Graba valores de FK2_VALOR y FK2_VLMOE2 en baja de anticipo, de acuerdo al DT:
	https://tdn.totvs.com/pages/releaseview.action?pageId=6070740
	Uso: fa080Adiant(), en base a fn086mFk2()
	@type  Function
	@author Alberto Rodríguez
	@since 21/11/2024
	@version 1.0
	@param oSubFK2, objeto, modelo FK2
	@param cCpoTp, caracter, variable con el valor a grabar
	@param nMoedaBco, numérico, moneda banco
	@param nMoedaTit, numérico, moneda título
	@param nTxModTit, numérico, tasa moneda título
	@param nTxModBco, numérico, tasa moneda banco 
	@return nulo, nulo, ninguno
	@example
	fn080mFk2(@oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco)
	@see (links_or_references)
	/*/
Function fn080mFk2(oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco)
	Local nDecimal		:= GetSx3Cache("E2_TXMOEDA", "X3_DECIMAL")

	Default	oSubFK2 	:= Nil
	Default cCpoTp		:= ""
	Default nMoedaBco	:= 0
	Default nMoedaTit	:= 0
	Default nTxModTit	:= 0
	Default nTxModBco	:= 0

	If oSubFK2 != Nil
		oSubFK2:SetValue( "FK2_VALOR" ,  &cCpoTp)
		oSubFK2:SetValue( "FK2_VLMOE2", Round(xMoeda( &cCpoTp, nMoedaBco , nMoedaTit,,nDecimal,, nTxModTit),2) )
	EndIf

Return Nil

/*/{Protheus.doc} fn080mFk5
	Graba valores de FK5_VALOR y FK5_VLMOE2 en baja de anticipo, de acuerdo al DT:
	https://tdn.totvs.com/pages/releaseview.action?pageId=6070740
	Uso: fa080Adiant(), en base a fn086mFk5()
	@type  Function
	@author Alberto Rodríguez
	@since 21/11/2024
	@version 1.0
	@param oSubFK5, objeto, modelo FK2
	@param cCpoTp, caracter, variable con el valor a grabar
	@param nMoedaBco, numérico, moneda banco
	@param nMoedaTit, numérico, moneda título
	@param nTxModTit, numérico, tasa moneda título
	@param nTxModBco, numérico, tasa moneda banco
	@param nJuros, numérico, intereses
	@return nulo, nulo, ninguno
	@example
	fn080mFk5(@oSubFK5,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nJuros)
	@see (links_or_references)
	/*/
Function fn080mFk5(oSubFK5,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nJuros)
	Local nDecimal		:= GetSx3Cache("E5_TXMOEDA", "X3_DECIMAL")

	Default	oSubFK5 	:= Nil
	Default cCpoTp		:= ""
	Default nMoedaBco	:= 0
	Default nMoedaTit	:= 0
	Default nTxModTit	:= 0
	Default nTxModBco	:= 0
	Default nJuros		:= 0

	If oSubFK5 != Nil
		oSubFK5:SetValue( "FK5_VALOR" ,&cCpoTp )
		oSubFK5:SetValue( "FK5_VLMOE2", Round(xMoeda( &cCpoTp, nMoedaBco , nMoedaTit,,nDecimal,, nTxModTit),2) )
	EndIf

Return Nil

/*/{Protheus.doc} fn080BxFk2
	Graba valores de FK2_VALOR y FK2_VLMOE2 en baja de título, de acuerdo al DT:
	https://tdn.totvs.com/pages/releaseview.action?pageId=6070740
	Uso: Fa080Grv(), en base a fn086mFk2()
	@type  Function
	@author Alberto Rodríguez
	@since 28/10/2024
	@version 1.0
	@param oSubFK2, objeto, modelo FK2
	@param cCpoTp, caracter, variable con el valor a grabar
	@param nMoedaBco, numérico, moneda banco
	@param nMoedaTit, numérico, moneda título
	@param nTxModTit, numérico, tasa moneda título
	@param nTxModBco, numérico, tasa moneda banco 
	@param nCentMd1, numérico, decimales
	@return nulo, nulo, ninguno
	@example
	fn080BxFk2(@oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nCentMd1)
	@see (links_or_references)
	/*/
Function fn080BxFk2(oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nCentMd1)
	Default	oSubFK2 	:= Nil
	Default cCpoTp		:= ""
	Default nMoedaBco	:= 0
	Default nMoedaTit	:= 0
	Default nTxModTit	:= 0
	Default nTxModBco	:= 0
	Default nCentMd1	:= 0

	If oSubFK2 != Nil
		oSubFK2:SetValue( "FK2_VALOR" , &cCpoTp )
		oSubFK2:SetValue( "FK2_VLMOE2", Round(NoRound(xMoeda( &cCpoTp, nMoedaBco, nMoedaTit,, nCentMd1+1,, nTxModTit ), nCentMd1+1), nCentMd1) )
	EndIf

Return Nil

/*/{Protheus.doc} F080ActPA
	Actualiza el valor de PA, por baja o anulación de baja
	Uso: Fa080Grv(), en base a F086ActPA()
	@type Función
	@author ARodriguez
	@since 09/11/2024
	@version 1.0
	@param cPrefixo , caracter	, Prefijo de la orden de pago
	@param cNumOP 	, caracter 	, Numero de la orden de pago
	@param cFornec 	, caracter 	, Codigo del Proveedor de la orden de pago
	@param cTienda	, caracter	, Codigo de la tienda del Proveedor
	@param dEmision , data		, Fecha de emision de la orden de pago
	@param nValDev	, numerico	, Valor pago del PA
	@param nMoedaBco, numerico	, Moneda del Banco 
	@param nMoedaTit, numerico	, Moneda del Titulo (PA) 
	@param dBaixa	, data		, Fecha de baja
	@param nTxModBco, numerico	, Tasa moenda del Banco 
	@param nTxModTit, numerico	, Tasa moneda del Título 
	@return Nulo
	@example
	F080ActPA(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_EMISSAO, nValPgto, nMoedaBco, nMoedaTit, dBaixa, nTxModBco, nTxModTit)
	@see (links_or_references)
	/*/
Function F080ActPA(cPrefixo,cNumOP,cFornec,cTienda,dEmision,nValDev,nMoedaBco,nMoedaTit,dBaixa,nTxModBco,nTxModTit)
	Local aAreaSE5 	:= SE5->(GetArea())
	Local aAreaFK5 	:= FK5->(GetArea())
	Local cEstorDP	:= SuperGetMV('MV_ESTORDP', .F., 'N')
	Local cFilFK5	:= xFilial("FK5")
	Local nVlDevVl	:= 0
	Local nVlDevM2	:= 0

	Default cPrefixo	:= ""
	Default cNumOP		:= ""
	Default cFornec		:= ""
	Default cTienda		:= ""
	Default dEmision	:= CtoD("")
	Default nValDev		:= 0
	Default nMoedaBco   := 0
	Default nMoedaTit   := 0
	Default dBaixa		:= CriaVar("E2_BAIXA")
	Default nTxModBco	:= 0
	Default nTxModTit   := 0
	
	If cEstorDP == "N" // Actualiza/Cancela registro SE5 (no genera movimiento de reversión)
		nVlDevVl := Round(xMoeda(nValDev, nMoedaBco, nMoedaTit, dBaixa, 3, nTxModBco, nTxModTit),2)
		nVlDevM2 := nVlDevVl

		If nMoedaTit <> nMoedaBco .And. nMoedaTit > 1
			nVlDevM2 := Round(xMoeda(nVlDevVl, nMoedaTit, nMoedaBco, dBaixa, 3, nTxModTit, nTxModBco),2)
		ElseIf nMoedaTit == nMoedaBco .And. nMoedaBco > 1
			nVlDevM2 := Round(xMoeda(nVlDevVl, nMoedaBco, 1, dBaixa, 3, nTxModBco, nTxModTit),2)
		Endif

		FK5->(DbSetOrder(1))	//FK5_FILIAL+FK5_IDMOV
		SE5->(dbSetOrder(2))	//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ

		If SE5->(MsSeek( xFilial("SE5") + "VL" + cPrefixo + cNumOP ))
			While SE5->(!Eof()) .And. SE5->E5_PREFIXO == cPrefixo .And. SE5->E5_NUMERO == cNumOP
				If SE5->E5_CLIFOR == cFornec .And. SE5->E5_LOJA == cTienda .And. SE5->E5_DATA == dEmision
					RecLock("SE5",.F.)
					SE5->E5_VALOR := Max(SE5->E5_VALOR - nVlDevVl, 0)
					SE5->E5_VLMOED2 := Max(SE5->E5_VLMOED2 - nVlDevM2, 0)
					If SE5->E5_VALOR == 0
						SE5->E5_SITUACA := "C"
					EndIf
					SE5->(MsUnlock())

					If SE5->E5_TABORI == "FK5"
						If FK5->( MsSeek( cFilFK5 + SE5->E5_IDORIG ) )
							RecLock("FK5",.F.)
							FK5->FK5_VALOR := Max(FK5->FK5_VALOR - nVlDevVl, 0)
							FK5->FK5_VLMOE2 := Max(FK5->FK5_VLMOE2 - nVlDevM2, 0)
							FK5->( MsUnlock() )
						Endif
					EndIf
				EndIf

				SE5->(DBSkip())
			EndDo
		EndIf

		FK5->(RestArea(aAreaFK5))
		SE5->(RestArea(aAreaSE5))
	EndIf

Return Nil

/*/{Protheus.doc} F080ActSEK
	Actualiza campo EK_CANCEL de PA en la tabla SEK al Dar de baja / Anular baja de título (FINA080)
	Uso: Fa080Can() y Fa080Grv(), en base a F086ActSEK()
	@type  Function
	@author ARodriguez
	@since 11/11/2024
	@version 1.0
	@param cNoOrdP, caracter, Número de Orden de Pago
	@param lCancel, lógica, .T.=Cancelar (Default), .F.=Reactivar 
	@example
	F080ActSEK(cNoOrdP)
	F080ActSEK(cNoOrdP, .F.)
	/*/
Function F080ActSEK(cNoOrdP, lCancel)

	Local cFilSEK	:= xFilial("SEK")
	Local aAreaSEK	:= SEK->(GetArea())
	Local lBajaOP	:= .T.

	Default cNoOrdP	:= ""
	Default lCancel	:= .T.

	cNoOrdP := Substr(cNoOrdP,1,Len(SEK->EK_ORDPAGO))

	DbSelectArea("SEK")
	SEK->(dbSetOrder(1))	//EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
	SEK->(dbGoTop())

	If !Empty(cNoOrdP) .And. SEK->(DbSeek(cFilSEK + cNoOrdP))
		Do While !SEK->(EoF()) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cNoOrdP
			If SEK->EK_TIPODOC == 'TB'
				lBajaOP := .F. // No procesa toda la OP si hay pagos, además del PA 
				Exit
			EndIf

			SEK->(DbSkip())
		EndDo

		SEK->(DbGotop())
		SEK->(DbSeek(cFilSEK + cNoOrdP))

		Do While !SEK->(EoF()) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cNoOrdP
			If !(SEK->EK_CANCEL == lCancel) .And. (SEK->EK_TIPODOC == 'PA' .Or. lBajaOP)
				RecLock("SEK",.F.)
				SEK->EK_CANCEL := lCancel
				SEK->(MsUnLock())
			EndIf

			SEK->(DbSkip())
		EndDo
	EndIf

	SEK->(RestArea(aAreaSEK))

Return Nil

/*/{Protheus.doc} FA080MI
	Valida si es país de MI con uso de FINA080
	@type  Function
	@author ARodriguez
	@since 13/02/2025
	@version 1.0
	@param 
	@return lRet, lógico, país localizado
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FA080MI()
	
	Local lRet := (cPaisLoc $ "ARG|BOL|CHI|COL|DOM|EQU|MEX|PAR|PER|URU")

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FGrvSEF
	Esta función actualiza la tabla SEF durante la conciliación manual realizada en la 
	rutina CTBA940, cambiando el estado del cheque de "Liquidado" a "Conciliado" en la 
	rutina de cheques emitidos (FINA095). En caso de que se cancele la conciliación, 
	el estado del cheque se revertirá a "Liquidado".

	@type  Function
	@author Walter Krebs 
	@since 06/02/2025
	@version 12.1.2310
/*/
//-------------------------------------------------------------------------------------
Function FGrvSEF(lConcil)
	Local aArea as Array 
	Local cChaveSEF := "" as Character
	Default lConcil := .F. 
	
	aArea := SEF->(GetArea())

	If SE5->E5_RECPAG == "R"
		cChaveSEF := SE5->E5_RECPAG+SE5->E5_BCOCHQ+SE5->E5_AGECHQ+SE5->E5_CTACHQ+SUBSTR(SE5->E5_NUMERO,1,GetSX3Cache("EF_NUM", "X3_TAMANHO"))
	Else 
		cChaveSEF := SE5->E5_RECPAG+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SUBSTR(SE5->E5_NUMERO,1,GetSX3Cache("EF_NUM", "X3_TAMANHO"))+SE5->E5_PREFIXO
	EndIf 

	SEF->(DbSetOrder(6))//EF_FILIAL+EF_CART+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO                
	IF SEF->(DbSeek(xFilial("SEF")+cChaveSEF))
		RecLock("SEF")                                            
		SEF->EF_RECONC := IIf(lConcil,"x"," ")
		SEF->(MSUnlock())
	Endif

	SEF->(RestArea(aArea))
Return 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} CodExpMI
    
    Genera un filtro personalizado para la rutina del Conciliador BackOffice,
	restringido al uso en el módulo MI.
    @type  Static Function
    @author Walter Krebs 
    @since 27/09/2025
    @return cCodExpMI, retorna o filtro 

/*/
//-------------------------------------------------------------------------------
Function CodExpMI(cCodCfg)
    Local cRetorno := "" as Character 
    Local cWhere   := "" as Character 
    Default cCodCfg := "" 

    IF cCodCfg $ '0023|0024'
    	IF cPaisLoc == "MEX" 
    	    cRetorno := '},'+;
    	                '{'+;
    	                '"idquery": "002",'+;
    	                '"tableaux": ['+;
    	                    '{'+;
    	                        '"table": "SE5",'+;
    	                        '"alias": "SE5"'+;
    	                    '}'+;
    	                '],'+;
    	                '"query": "SELECT SE5.E5_IDORIG FROM {SE5} SE5 '+;
    	                ' WHERE SE5.E5_SITUACA <> ' + "'C' " + ' AND SE5.E5_FILIAL = FK5.FK5_FILIAL AND SE5.E5_IDORIG = FK5.FK5_IDMOV AND SE5.D_E_L_E_T_ = ' + "' '" + '"'   
    	Else    
    	    cWhere := ' AND SEF.EF_STATUS <> ' + "'05'"
    	    cRetorno := '},'+;
    	                '{'+;
    	                '"idquery": "002",'+;
    	                '"tableaux": ['+;
    	                    '{'+;
    	                        '"table": "FK7",'+;
    	                        '"alias": "FK7"'+;
    	                    '},'+;
    	                    '{'+;
    	                        '"table": "SEF",'+;
    	                        '"alias": "SEF"'+;
    	                    '}'+;
    	                '],'+;
    	                '"query": "SELECT FK7.FK7_IDDOC FROM {FK7} FK7 '+;
    	                            'LEFT JOIN {SEF} SEF ON SEF.EF_FILIAL = FK7.FK7_FILTIT AND SEF.EF_NUM = FK7.FK7_NUM AND SEF.EF_PREFIXO = FK7.FK7_PREFIX AND SEF.EF_PARCELA = FK7.FK7_PARCEL AND SEF.EF_CLIENTE = FK7.FK7_CLIFOR AND SEF.EF_LOJACLI = FK7.FK7_LOJA AND SEF.D_E_L_E_T_ = ' + "' ' " + ;
    	                            'WHERE FK7.FK7_FILIAL = FK5.FK5_FILIAL AND FK7.FK7_IDDOC = FK5.FK5_IDFK7' + cWhere + ' AND FK7.D_E_L_E_T_ = ' + "' '" + '"'                                 
    	EndIf
     EndIf 
Return cRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXCHKSUM
	Retorna el CheckSum del archivo.

	@type  Function
	@author Luis Enríquez 
	@since 15/08/2025
	@version 1.0
	@param nHdlBco, numerico, Handle del archivo abierto 
	@param cFilePath, caracter, Ruta del archivo
	@return cIdArq, CheckSum del archivo
/*/
//-------------------------------------------------------------------------------------
Function FINXCHKSUM(nHdlBco, cFilePath)
	Local cIdArq    as Character
	Local cRet      as Character
	Local cTrailler as Character
	Local nTamArq   as Numeric
	Local oFile     as Object

	Default nHdlBco   := 0
	Default cFilePath := ""

	cRet      := ""
	cIdArq    := ""
	cTrailler := ""

	//Lee archivo hasta el final
	oFile := FWFileReader():New(cFilePath)
	If (oFile:Open())
		nTamArq := oFile:getFileSize()
		While (oFile:hasLine())
			cRet += oFile:GetLine()
		End
		oFile:Close()
	EndIf

	cTrailler := cRet+Transform(nTamArq,"")

	cIdArq	 := Str(MsCrc32(cTrailler),10) 
	oFile := Nil 
	FreeObj(oFile)
Return cIdArq
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXVLTOTL
	Retorna el valor del cobro con todos sus decimales.
	@type  Function
	@author Alfredo Medrano	
	@since 25/08/2025
	@version 1.0
	@param nVlMoed1, numérico, Valor en la moneda 1.
	@param nTxDocCbr, numérico, Tasa de la moneda.
	@param nElValor, numérico, Valor del cobro.
	@param nMoedFil, numérico, moneda seleccionada en el grupo de preguntas FIR13X
	@param nElMoed, numérico, moneda del título cobrado.
	@return nValDcCbr, numerico, Valor del cobro con todos sus decimales.
/*/
//-------------------------------------------------------------------------------------
Function FINXVLTOTL(nVlMoed1, nTxDocCbr, nElValor, nMoedFil, nElMoed)

	Local nValDcCbr   := 0
	Local nDec		  := 8
	Default nVlMoed1  := 0
	Default nTxDocCbr := 0
	Default nElValor  := 0
	Default nMoedFil  := 0
	Default nElMoed   := 0

	If nTxDocCbr > 0 .and. nMoedFil <> nElMoed
		nValDcCbr := NoRound(nVlMoed1 / nTxDocCbr, nDec)
	Else
		nValDcCbr := nElValor
	EndIf

Return nValDcCbr

/*/{Protheus.doc} fn080mFk6
	Actualiza campos de FK6 desde fina080       
	@type  Function
	@author Alberto Rodríguez
	@since 24/09/2025
	@version 12.1.2410
	@param oSubFK6		- Objeto FK6
	@param nValor		- Valor Movimiento
	@param nMoedTit		- Moneda titulo
	@param nMoedaBco	- Moneda seleccionada en la compensación
	@param nTxMoeda		- Tasa de moneda seleccionada en la compensación
	@param nTxModBco	- Tasa de moneda del banco
	@param cTpDoc		- Tipo de movimiento
/*/
Function fn080mFk6(oSubFK6, nValor, nMoedTit, nMoedaBco, nTxMoeda, nTxModBco, cTpDoc)
	Local nValMon 		:= 0
	Local nLenFK6Mon	:= GetSx3Cache("FK6_MOEDA", "X3_TAMANHO")
	
	Default oSubFK6		:= Nil
	Default nValor		:= 0
	Default nMoedTit	:= 0
	Default nMoedaBco	:= 0
	Default nTxMoeda	:= 0
	Default nTxModBco	:= 0
	Default cTpDoc		:= ""

	nValMon := fn450CmMon(nValor, nMoedTit, nMoedaBco, nTxMoeda)

	oSubFK6:SetValue("FK6_VLMOE2", nValMon)
	oSubFK6:SetValue("FK6_MOEDA" , StrZero(nMoedaBco,nLenFK6Mon))
	oSubFK6:SetValue("FK6_TXMOED", nTxModBco)

Return

/*/{Protheus.doc} FINX4XMIL
	Verifica si el PA esta relacionado al impuesto 4XMIL (GMF) 
	Esta funcion es utilizada en la función fA080Tit()
	@type  Static Function
	@author alfredo.medrano
	@since 04/09/2025
	@version 1
	@param cNumOPg, Carácter, Núm Orden Pago
	@param cPrefix, Carácter, Prefixo Orden Pago
	@param cFornec, Carácter, Proveedor
	@param cLoja, Carácter, Tienda
	@param dEmision, date , Fecha emisión de PA
	@return Nil
	@example
		If !FINX4XMIL(cNumOPg,cPrefix,cFornec,cLoja,dEmision) ; Return nil
	@see (links_or_references)
/*/
Function FINX4XMIL(cNumOPg,cPrefix,cFornec,cLoja,dEmision)
	
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaSEK	:= SEK->(GetArea())
	Local lRet		:= .F.
	Local cProctra	:= ""
	Local cNoOrdP	:= ""
	Local nTamOrdP	:= FWSX3Util():GetFieldStruct("EK_ORDPAGO")[3]
	Local cFilSEK	:= xFilial("SEK")
	Default cNumOPg := ""
	Default cPrefix := ""
	Default dEmision:= StoD("")
	Default cFornec	:= ""
	Default cLoja	:= ""
	

		dbSelectArea("SE5")
		SE5->(dbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
		cNoOrdP := Substr(cNumOPg,1,nTamOrdP)
		DbSelectArea("SEK")
		SEK->(dbSetOrder(1))	//EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
		SEK->(dbGoTop())

		If !Empty(cNoOrdP) .And. SEK->(DbSeek(cFilSEK + cNoOrdP))
			Do While !SEK->(EoF()) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cNoOrdP
				If SE5->(MsSeek( xFilial("SE5") + "VL" + cPrefix + SEK->EK_NUM ))
					cProctra := SE5->E5_PROCTRA
					Exit
				EndIf
				SEK->(DBSkip())
			EndDo
		EndIf

		If !Empty(cProctra) //Si el PA tiene impuesto(IT) relacionado
			SE5->(dbSetOrder(15))//E5_FILIAL+E5_PROCTRA
			If SE5->(MsSeek(xFilial("SE5")+cProctra))
				Do While SE5->(!Eof()) .and. SE5->E5_PROCTRA == cProctra 
					If SE5->E5_TIPODOC == "IT" .and. Alltrim(SE5->E5_HISTOR) == "GMF"
						lRet := .T.
						Exit
					EndIf
					SE5->(DBSkip())
				EndDo
			EndIf
		EndIf

	SE5->(RestArea(aAreaSE5))
	SEK->(RestArea(aAreaSEK))
	
Return lRet

/*/{Protheus.doc} FINXBJ4XML
	Verifica si el PA esta relacionado al impuesto 4XMIL (GMF) 
	y actualiza el estatus del mov. bancario del Impuesto 4xMil. 
	Esta funcion es utilizada en la función fA080Grv()
	@type  Static Function
	@author alfredo.medrano
	@since 04/09/2025
	@version 1
	@param cNumOPg, Carácter, Núm Orden Pago
	@param cPrefix, Carácter, Prefixo Orden Pago
	@param cFornec, Carácter, Proveedor
	@param cLoja, Carácter, Tienda
	@param dEmision, date , Fecha emisión de PA
	@param cBanco, Carácter, Proveedor
	@param cAgencia, Carácter, Tienda
	@param cConta, date , Fecha emisión de PA
	@param lStatus, logico , .F. =baja mov bancario, .T.= revierte la baja  
	@return Nil
	@example
		If !FINX4XMIL(cNumOPg,cPrefix,cFornec,cLoja,dEmision,cBanco,cAgencia,cConta,lStatus) ; Return nil
	@see (links_or_references)
/*/
Function FINXBJ4XML(cNumOPg, cPrefix, cFornec, cLoja, dEmision, cBanco, cAgencia, cConta, lStatus)
	
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaSEK	:= SEK->(GetArea())
	Local lRet		:= .F.
	Local cNoOrdP	:= ""
	Local cProctra	:= ""
	Local nTamOrdP	:= FWSX3Util():GetFieldStruct("EK_ORDPAGO")[3]
	Local cFilSEK	:= xFilial("SEK")
	Default cNumOPg := ""
	Default cPrefix := ""
	Default dEmision:= StoD("")
	Default cFornec	:= ""
	Default cLoja	:= ""
	Default lStatus	:= .F.
	Default cBanco	:= ""
	Default cAgencia:= ""
	Default cConta	:= ""
	

		dbSelectArea("SE5")
		SE5->(dbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
		cNoOrdP := Substr(cNumOPg,1,nTamOrdP)
		DbSelectArea("SEK")
		SEK->(dbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
		SEK->(dbGoTop())

		If !Empty(cNoOrdP) .And. SEK->(DbSeek(cFilSEK + cNoOrdP))
			Do While !SEK->(EoF()) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cNoOrdP
				If SE5->(MsSeek( xFilial("SE5") + "VL" + cPrefix + SEK->EK_NUM ))
					cProctra := SE5->E5_PROCTRA
					Exit
				EndIf
				SEK->(DBSkip())
			EndDo
		EndIf

		If !Empty(cProctra) //Si el PA tiene impuesto(IT) relacionado
			SE5->(dbSetOrder(15))//E5_FILIAL+E5_PROCTRA
			If SE5->(MsSeek(xFilial("SE5")+cProctra))
				Do While SE5->(!Eof()) .and. SE5->E5_PROCTRA == cProctra 
					If SE5->E5_TIPODOC == "IT" .and. Alltrim(SE5->E5_HISTOR) == "GMF"
						RecLock("SE5",.F.)
						If !lStatus
							SE5->E5_SITUACA:= "C"
							AtuSalBco( cBanco, cAgencia, cConta, dDatabase, SE5->E5_VALOR, "+" ) // actualiza saldo bancario
						Else
							SE5->E5_SITUACA:= " "
							AtuSalBco( cBanco, cAgencia, cConta, dDatabase, SE5->E5_VALOR, "-" ) // actualiza saldo bancario
						EndIf	
						SE5->(MsUnlock())
					EndIf
					SE5->(DBSkip())
				EndDo
			EndIf
		EndIf

	SE5->(RestArea(aAreaSE5))
	SEK->(RestArea(aAreaSEK))
	
Return lRet

/*/{Protheus.doc} FINXACTSE5
	Función que realiza la actualización del campo _LA de las tablas SE5, FK2 y FK5,
	cuando el parámetro MV_CTBFLAG está configurado con valor F
	@type  Function
	@author Luis.Enríquez
	@since 27/11/2025
	@version 1  
	@return Nil
	@example
		FINXACTSE5()
	@see (links_or_references)
/*/
Function FINXACTSE5()
	Local oModel  := Nil
	Local oSubFKA := Nil
	Local oSubFK5 := Nil
	Local oSubFK2 := Nil
	Local cModelo := Nil

	cModelo := IIf(SE5->E5_TABORI=="FK2","FINM020","FINM030")
	oModel := FWLoadModel(cModelo) //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
	oModel:SetOperation( 4 ) //Alteração
	oModel:Activate()
	oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
	oSubFKA := oModel:GetModel("FKADETAIL")
	If oSubFKA:SeekLine( { {"FKA_FILIAL", SE5->E5_FILIAL },{"FKA_IDORIG", SE5->E5_IDORIG } } )
		//Datos contables
		oSubFK5 := oModel:GetModel("FK5DETAIL")
		oSubFK5:SetValue( "FK5_LA", "S" )
		If SE5->E5_TABORI == "FK2"
			oSubFK2 := oModel:GetModel("FK2DETAIL")	
			oSubFK2:SetValue( "FK2_LA", "S" )
		EndIf
		If oModel:VldData()
			oModel:CommitData()
		Endif
	EndIf
	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL
Return Nil

/*/{Protheus.doc} FINXFLAG
	Función que actualiza la variable aFlagCTB para la actualización del campo_LA de las tablas SE5, FK2 y FK5,
	cuando el parámetro MV_CTBFLAG está configurado con valor T
	@type  Function
	@author Luis.Enríquez
	@since 27/11/2025
	@version 1
	@param cFilSE5, Carácter, Filial de la tabla SE5  
	@return Nil
	@example
		FINXFLAG(cFilSE5)
	@see (links_or_references)
/*/
Function FINXFLAG(cFilSE5, aFlagCTB)
	Local aAreaSE5 := GetArea()
	Default cFilSE5  := "" 
	Default aFlagCTB := {}
	DbSelectArea("SE5")
	SE5->(DbSetOrder(8)) //E5_FILIAL+E5_ORDREC+E5_SERREC
	SE5->(MsSeek(xFilial("SE5") + SEK->EK_ORDPAGO))
	Do while SE5->(!EOF()) .And. SE5->E5_FILIAL == cFilSE5 .And. SE5->E5_ORDREC == SEK->EK_ORDPAGO
		aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
		SE5->(DbSkip())
	EndDo
	RestArea(aAreaSE5)
Return Nil
