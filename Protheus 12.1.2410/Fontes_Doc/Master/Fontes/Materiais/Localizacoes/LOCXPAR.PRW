#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOCXPAR.CH"

//Array aCfgNf
#Define SnTipo      1
#Define ScCliFor    2
#Define SlFormProp  3
#Define SAliasHead  4
#Define ScEspecie   8
#Define ScOpFin     9
#Define ScTipoDoc  10

Static lChkLxProp := FindFunction("ChkLxProp")

/*/{Protheus.doc} DocOriPAR
Función para seleccionar documentos origen.
@type function
@author raul.medina
@since 05/2022
@version 1.0
*/

Function DocOriPAR()
Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aCposF4		:= {}
Local aRecs    		:= {}
Local aRet     		:= {}
Local nI 			:= 0
Local nTaxaNf		:= 0
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
Local nTes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nItemCta   	:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nClVl			:= 0
Local cCondicao 	:= ""
Local cItem			:= ""
Local cTipoDoc 		:= ""
Local cCliFor		:= M->F2_CLIENTE
Local cLoja  		:= M->F2_LOJA
Local cSeek  		:= ""
Local cWhile 		:= ""
Local cAliasCab		:= ""
Local cAliasItem	:= ""
Local cAliasTRB		:= ""
Local cQuery		:= ""
Local cFilSD		:= ""
Local cFilSB1		:= xFilial("SB1")
Local cFilSD2		:= xFilial("SD2")
Local lLxDOrigNf	:= ExistBlock( "LXDORIGNF" )

Private aFiltro		:= {}

If Empty(cCliFor) .OR. Empty(cLoja)
	Aviso(cCadastro,STR0001,{STR0002}) //"Llene los datos del encabezado."###"OK"
	Return
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == "D2_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CCUSTO"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESCON"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMCC"
			nItemCta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLVL"
			nClVl := nI
	Endcase
Next nI
cAliasCab	:= "SF2"
cAliasItem	:= "SD2"
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAliasCab))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAliasCab
	If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
		AAdd(aCposF4,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo

If aCfgNF[1] == 2

	cTipoDoc	:= "'01'" //Tipo documento origem 
	cSeek  	:= "'" + xFilial(cAliasCab)+cCliFor+cLoja + "'"
	cWhile 	:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA)== " + cSeek
	cCondicao	:= "Ascan(aFiltro,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_TIPODOC)) > 0"
	cItem		:= aCols[Len(aCols),nItem]

	cAliasTRB := GetNextAlias()
	cQuery := "select distinct D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC,D2_ITEM"
	cQuery += " from " + RetSqlName("SD2") + " SD2 where "
	cQuery += " D2_FILIAL ='" + xFilial("SD2") + "'"
	cQuery += " and D2_CLIENTE = '" + cCliFor + "'"
	cQuery += " and D2_LOJA = '" + cLoja + "'"
	cQuery += " and D2_TIPODOC in (" + cTipoDoc + ")"
	cQuery += " and D2_QUANT > D2_QTDEDEV"
	cQuery += " and SD2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
    DbSelectArea(cAliasTRB)

    While (cAliasTRB)->(!Eof())
    	nI := Ascan(aCols,{|x| x[nNFORI] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
    	If nI == 0
			Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
		Endif
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
EndIf

If !Empty(aFiltro)	
	aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,STR0003,cCondicao,.T.,,,,,.F.)  // Retorn
Else
	Help(" ",1,"A103F4")
	Return
EndIf
If ValType(aRet)=="A" .AND. Len(aRet)==3
	aRecs := aRet[3]
EndIf
If ValType(aRecs)!="A" .OR. (ValType(aRecs)=="A" .AND. Len(aRecs)==0)
	Return
EndIf
SD2->(DbSetOrder(3))
cFilSD := cFilSD2
ProcRegua(Len(aRecs))

For nI := 1 To Len(aRecs)
	SF2->(MsGoTo(aRecs[nI]))
	SD2->(DbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	IncProc(STR0004 + "(" + SF2->F2_DOC + ")")
	While SD2->D2_FILIAL == cFilSD .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA
		If SD2->D2_QUANT > SD2->D2_QTDEDEV
        	If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
				nLenAcols := Len(aCols)
				If !Empty(aCols[nLenAcols,nCod])
					AAdd(aCols,Array(Len(aHeader)+1))
					nLenAcols := Len(aCols)
					cItem := Soma1(cItem)
				Endif
			 	aCols[nLenAcols][Len(aHeader)+1] := .F.
				SB1->(MsSeek(cFilSB1+SD2->D2_COD))
				If (nUm      >  0  ,  aCOLS[nLenAcols][nUm     ] := SD2->D2_UM	,)
				If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm  ] := SB1->B1_SEGUM,)
				If (nCod     >  0  ,  aCOLS[nLenAcols][nCod    ] := SD2->D2_COD,)
				If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal  ] := SD2->D2_LOCAL,)
				If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri  ] := SD2->D2_DOC,)
				If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri] := SD2->D2_SERIE,)
				If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri] := SD2->D2_ITEM,)
				If (nItem    >  0  ,  aCOLS[nLenAcols][nItem   ] := cItem,)
				If (nConta   >  0  ,  aCOLS[nLenAcols][nConta  ] := SD2->D2_CONTA,)
	   			If (nCCusto  >  0  ,  aCOLS[nLenAcols][nCCusto ] := SD2->D2_CCUSTO,)
			   	If (nItemCta >  0  ,  aCOLS[nLenAcols][nItemCta] := SD2->D2_ITEMCC,)
			   	If (nClVl    >  0  ,  aCOLS[nLenAcols][nClVl]  	:= SD2->D2_CLVL,)
				If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl] := SD2->D2_LOTECTL,)
				If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote] := SD2->D2_NUMLOTE,)
				If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid] := SD2->D2_DTVALID,)
				If lLxDOrigNf
					ExecBlock( "LXDORIGNF", .F., .F.) 
				EndIf
				If nTES <> 0
					aCols[nLenAcols][nTES] := SD2->D2_TES
					aCols[nLenAcols][nCf] := SD2->D2_CF
				EndIf
				nTaxaNF := MaFisRet(,'NF_TXMOEDA')
				nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDatabase,M->F1_MOEDA),nTaxaNF)
				AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
				MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)
				MaFisAlt("IT_RECORI",SD2->(Recno()),nLenAcols)

			EndIf
		Endif
		SD2->(DbSkip())
	EndDo
Next nI
oGetDados:lNewLine:=.F.
oGetDados:obrowse:refresh()
Eval(bDoRefresh)
AtuLoadQt()
RestArea(aSD2)
RestArea(aSF2)
RestArea(aArea)

Return
/*/{Protheus.doc} valPreAuto
	(long_description)
	@author adrian.perez
	@since 18/05/2022
	@version version
	@param cFilAnt, Caracter, Filial.
	@param cSerie, Caracter, Serie del documento en este caso es fijo en 1 (especie NF). 
	@param cEspecie, Caracter, Tipo de documento. 
	@param cnFiscal, Caracter, Número de documento. 
		
	@return cRet,caracter, valor asiganado, regresar valor asiganado
	/*/
Function CtrFolAutPAR(cFilAnt,cSerie,cEspecie,cnFiscal)

	Local lRet		:= .T.
	Local alAreaSFP	:= {}
	Local lNoAutoFac:=.F.
	Local dFecha:= dDataBase
	Local lActivo:= .T.
	Local nTamNumTim := GetSX3Cache("F1_NUMTIM", "X3_TAMANHO")
	DEFAULT cFilAnt:=""
	DEFAULT cSerie:=""
	DEFAULT cEspecie:="1"
	DEFAULT cnFiscaL:=""
	
	If !Empty(cEspecie)
		
				alAreaSFP := GetArea()

				dbSelectArea("SFP")
				SFP->(dbGoTop())
				dbSetOrder(5)
				If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
					lRet := .F.
					While !SFP->(Eof()) .AND.AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)

							IF !Empty(cNFIscal)
								If (Empty(SFP->FP_NUMINI) .or. Empty(SFP->FP_NUMFIM))  .OR.  SFP->FP_NUMINI <= cnFiscal .and. SFP->FP_NUMFIM >= cnFiscal
									IF SFP->FP_ATIVO == "1"
										IF SFP->FP_AUTOFAC== "1"
											M->F1_SERIE2:= SFP->FP_SERIE2
											M->F1_NUMTIM:= Padr(SFP->FP_CAI, nTamNumTim)
											dFecha:= SFP->FP_DTAVAL
										ELSE
												lNoAutoFac:=.T.
										ENDIF
										lRet := .T.
									ELSE
										lActivo:=.F.
									ENDIF
									
								Else
									lRet := .F.
								EndIf
							Else
								IF SFP->FP_ATIVO == "1"
									IF SFP->FP_AUTOFAC== "1"
										M->F1_SERIE2:= SFP->FP_SERIE2
										M->F1_NUMTIM:= Padr(SFP->FP_CAI, nTamNumTim)
										dFecha:= SFP->FP_DTAVAL
									ELSE
											lNoAutoFac:=.T.
									ENDIF
									lRet := .T.
								ELSE
										lActivo:=.F.
								ENDIF
								
							ENDIF


						SFP->(dbSkip())
					EndDo
					If lRet
						If dDataBase <= dFecha
							
							lRet := .T.
						Else
							Help("", 1, STR0020, , STR0007, 1, 0) //"Serie"###"La fecha de emisión de este documento está fuera del límite registrado en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"

							lRet := .F.
						EndIf
						
							IF lNoAutoFac
								Help("", 1, STR0020, , STR0008, 1, 0) // "Serie"###Serie no configurada para auto factura
								lRet := .F.
							ENDIF
					
						
					Else
						IF !lActivo
							
								Help("", 1, STR0020, , STR0011, 1, 0)  //"Serie"###La serie no esta activ
								lRet := .F.
						ELSE
								Help("", 1, STR0020, , STR0009, 1, 0) //"Serie"###"No existe este número registrado en ningún rango con esta serie o clase."###"OK"
								lRet := .F.
						ENDIF
					
					EndIf
				Else
					Help("", 1, STR0020, , STR0010, 1, 0)//"Serie"###"Esta serie o especie no está registrada en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"
					lRet := .F.
				EndIf

				SFP->(dbCloseArea())
				RestArea(alAreaSFP)

	EndIf
Return lRet

/*/{Protheus.doc} valPreAuto
	(long_description)
	@author adrian.perez
	@since 18/05/2022
	@version version
	@param cDato,caracter, valor asiganado en este caso proviene del parametro MV_PAR01 pregunta MT101N
	@param lAutoFac,booleano, .T. indica si es autofactura, .f. no es autofactura
	
	@return cRet,caracter, valor asiganado, regresar valor asiganado
	/*/
Function autoFactPar(cDato,lAutoFac)
	Local cRet:=0
	DEFAULT cDato:=""
	DEFAULT lAutofac:=.f.
	IF cFunName$"MATA101N" 
		cRet:=cDato	
	ENDIF
	IF(cRet==5)
		lAutoFac:=.T.
	ELSE
		lAutoFac:=.F.
	ENDIF	
Return cRet


/*/{Protheus.doc} xGrvCabPAR
	Funcitón de grabado de encabezado para Paraguay
	@type  Function
	@author Arturo Samaniego
	@since 15/07/2022
	/*/
Function xGrvCabPAR(cFunName, aCabNota, cAlias)
Local nPosParAux := 0
Local cCpo       := ""

Default cFunName := FunName()

	IF (cFunName == "MATA101N") .Or. (lChkLxProp .and. ChkLxProp("GrabaCampoAutofactura"))
		nPosParAux := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim("F1_AUTOFAC") } )
		IF nPosParAux<>0
			aCabNota[2][nPosParAux] := cValToChar(aCabNota[2][nPosParAux])
		ENDIF
	ENDIF
	IF ((cFunName == "MATA101N") .OR.(cFunName == "MATA466N") .Or. (lChkLxProp .and. ChkLxProp("GrabaDOCEL")) .OR. IsBlind() )
		nPosParAux := 0
		cCpo := PrefixoCpo(cAlias)
		nPosParAux := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim(cCpo+"_DOCEL") } )
		IF nPosParAux <> 0
			aCabNota[2][nPosParAux] := cValToChar(aCabNota[2][nPosParAux])
		ENDIF
	ENDIF

Return

/*/{Protheus.doc} xCliForPAR
	Función para asignar valor en encabezado
	@type  Function
	@author Arturo Samaniego
	@since 15/07/2022
	/*/
Function xCliForPAR()
	If aCfgNf[ScCliFor]=="SA2" .AND. !Empty(SA2->A2_NUMTIM) .OR.  StrZero(aCfgNf[SnTipo],2)=="54"
		If aCfgNf[SAliasHead] == "SF2"
			M->F2_NUMTIM := SA2->A2_NUMTIM
		ElseIf aCfgNf[SAliasHead] == "SF1"
			M->F1_NUMTIM := SA2->A2_NUMTIM
		Endif
	EndIf
Return


/*/{Protheus.doc} ParLinOk
//Funcion destinada a validaciones para pARAGUAY en la funcion NfLinok.
@author raul.medina
@since 07/2022
@version 1.0

@type function
/*/
Function ParLinOk(cAliasI,aCposIOri,cAliasCF,aDadosIOri,cTipDoc,nLinha,lFormP,nMoedaNF,l103Class)
Local lRet			:= .T.
Local nI 			:= 0
Local nPosTes		:= 0
Local nPosQuant		:= 0
Local nPosVUnit		:= 0
Local nPosTotal		:= 0
Local aCposI		:= aClone(aCposIOri)
Local aDadosI		:= aClone(aDadosIOri)
Local cTes 			:= ""
Local nAdt 			:= 0
Local nX			:= 0
Local cFilSF4       := xFilial("SF4")

	nPosTes 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TES' })
	nPosQuant 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_QUANT' })
	nPosVUnit 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+IIf(cAliasI=="SD1","_VUNIT","_PRCVEN") })
	nPosTotal	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TOTAL'})
	nAdt 		:= Ascan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_VALADI'})

	For nI := IIf(nLinha>0,nLinha,1) to IIf(nLinha>0,nLinha,Len(aDadosI))

		If aDadosI[nI][Len(aDadosI[nI])]
			Loop
		EndIf

		If ( MsDecimais(nMoedaNF) == 0 .or. (FunName()$"MATA143"))
			If nPosTes>0 .AND. nPosQuant>0 .AND. nPosVUnit>0 .AND. nPosTotal>0 .AND.;
				lRet .And. Iif(MaTesSel(aDadosI[nI][nPosTes]).And.aDadosI[nI][nPosQuant]==0,aDadosI[nI][nPosVUnit]<>aDadosI[nI][nPosTotal],;
					(Abs(aDadosI[nI][nPosTotal] - (aDadosI[nI][nPosVUnit]*aDadosI[nI][nPosQuant])) > 1 )).and. !l103Class
				Aviso(STR0013,STR0014,{STR0002}) //"ATENCIÓN" ## "Inconsistencia en los valores del documento" ##"STR0002"
				lRet := .F.
			EndIf
		EndIf
	
	Next

    If lRet .And. cTipDoc == "A" .And. cAliasI == "SD2"
        If nPosTes > 0
            For nX := 1 To Len(aDadosI)
                If !aDadosI[nX][Len(aDadosI[nX])]
                    If cTes == ""
                        cTes := aDadosI[nX][nPosTes]
                        // Verificar se a TES gera duplicata e não movimenta estoque
                        DbSelectArea("SF4")
                        DbSetOrder(1)
                        If MsSeek(cFilSF4+cTes) .AND. (SF4->F4_ESTOQUE == "S" .OR. SF4->F4_DUPLIC == "N")
                            Help(" ", 1, STR0013, , STR0024, 2, 0,,,,,, ) // Atenção#"En la operacion de anticipo el TES utilizado debe afectar financiero y no movilizar stock.
                            lRet := .F.
                            Exit
                        EndIf
                    ElseIf aDadosI[nX][nPosTes] <> cTes
                        Help(" ", 1, STR0013, , STR0027, 2, 0,,,,,, ) // Atenção#"Na operação de adiantamento os itens da Nota de Saída devem possuir o mesmo TES."#OK                       
                        lRet := .F.
                        Exit
                    EndIf
                EndIf
            Next nX
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxExSer2()
Validación para uso de serie 2
@author raul.medina
@since 07/2022
/*/
Function ParExSer2()
Local aArea    	:= GetArea()
Local cVarAct	:= readvar()
Local cOp 		:= "1"
Local lRETPAR	:=.F. //RTS PARAGUAY
Local lF1NumTim := SF1->(ColumnPos("F1_NUMTIM")) > 0
Local lF2NumTim := SF2->(ColumnPos("F2_NUMTIM")) > 0

Local oJFolio   := JsonObject():New()

	If (FunName() $ 'MATA462TN')
		lRETPAR := .T.
	EndIf

	If FunName() $ 'MATA467N|MATA462N' .OR. lRETPAR
		cOp := IIF(FunName() $ 'MATA462N' .OR. lRETPAR,"6","1")
		If ALLTRIM(cVaract) $ "M->F2_DOC|M->F2_SERIE" //factura de Venta
			oJFolio := fVldFolPAR(cFilAnt, M->F2_SERIE, cOp)
			If oJFolio:HasProperty('FP_CAI') .And. oJFolio:HasProperty('FP_SERIE2')
				M->F2_SERIE2 := oJFolio['FP_SERIE2']
				If lF2NumTim
					M->F2_NUMTIM := oJFolio['FP_CAI']
				EndIf
			Else
				M->F2_SERIE2 := ''
			EndIf
		Endif
	EndIf
	IF FunName() $ 'MATA465N'//  Nota de Debito/Credito
		If ALLTRIM(cVaract) $ "M->F1_DOC|M->F1_SERIE"  //NCC  CREDITO
			oJFolio := fVldFolPAR(cFilAnt, M->F1_SERIE, '4')
			If oJFolio:HasProperty('FP_CAI') .And. oJFolio:HasProperty('FP_SERIE2')
				M->F1_SERIE2:= oJFolio['FP_SERIE2']
				If lF1NumTim
					M->F1_NUMTIM := oJFolio['FP_CAI']
				EndIf
			Else
				M->F1_SERIE2:= ''
			EndIf
		Else
			If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //NDC  DEBITO
				oJFolio := fVldFolPAR(cFilAnt, M->F2_SERIE, '5')
				If oJFolio:HasProperty('FP_CAI') .And. oJFolio:HasProperty('FP_SERIE2')
					M->F2_SERIE2 := oJFolio['FP_SERIE2']
					If lF2NumTim
						M->F2_NUMTIM := oJFolio['FP_CAI']
					EndIf
				Else
					M->F2_SERIE2 := ''
				EndIf
			Endif
		EndIf
	EndIf
	RestArea(aArea)

Return .T.

/*/{Protheus.doc} LxExSer2()
Validaciones para el control de formularios
@author raul.medina
@since 07/2022
/*/
Function CtrFolPar(cFilAnt,cSerie,cEspecie,cnFiscal)
Local lRet      := .T.
Local oJFolio   := JsonObject():New()
	
	cEspecie := Alltrim(cEspecie)
	If !Empty(cEspecie) .And. !Empty(cnFiscal)

		If Upper(Alltrim(FunName())) $ "MATA465N/MATA466N/MATA467N/MATA462N"
			
			If cEspecie $ "NF|NCC|NDC|NDI|NCI|RFN"

				Do Case
					Case cEspecie == "NF"
						cEspecie := "1"
					Case cEspecie == "NCI"
						cEspecie := "2"
					Case cEspecie == "NDI"
						cEspecie := "3"
					Case cEspecie == "NCC"
						cEspecie := "4"
					Case cEspecie == "NDC"
						cEspecie := "5"
					Case cEspecie == "RFN"
						cEspecie := "6"
				EndCase
				
				oJFolio := fVldFolPAR(cFilAnt, SubStr(cSerie,1,3), cEspecie, cnFiscal)
				If !oJFolio:HasProperty('FP_CAI')
					lRet := .F.
				EndIf

			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} NfTudOkPar
    La función es llamada en NfTudOk (LOCXNF.PRW)
    @type  Function
    @author adrian.perez
    @since 15/02/2023
    @version version
    @param  aCfgNf: Array con la configuración del documento.
			aDupli: Array con valores financieros.
            nBaseDup: Valor del título financiero de la nota fiscal.
			nMoedaNF: Moneda del documento.
			nMoedaCor: Moneda a convertir el valor.
			nTaxa: Valor de la tasa de cambio.
			l103Class: Indica si existe integración.
			cFunName: Nombre de la función.
			nNFTipo : Tipo Fatura
			cCondicao : Condição de Pagamento
			cNatureza : Natureza Financeira  
    @return lRet: .T. si cumple con las condiciones.
    /*/
Function NfTudOkPar(aCfgNf, aDupli, nBaseDup, nMoedaNF, nMoedaCor, nTaxa, l103Class, cFunName,nNFTipo, cCondicao,cNatureza)
Local lRet      := .T.
Local nI        := 0
Local nTotDup   := 0
Local cCentavos := ""
Local cTpDoc    := ''

Default aCfgNf    := {}
Default aDupli    := {}
Default nBaseDup  := 0
Default nMoedaNF  := 1
Default nMoedaCor := 1
Default nTaxa     := 0
Default l103Class := .F.
Default cFunName  := Funname() // a futuro
Default nNFTipo	  := 0
Default cCondicao := ''
Default cNatureza := ''

    cCentavos  := Iif(nMoedaNF==1,"MV_CENT",("MV_CENT"+AllTrim(Str(nMoedaNF))))

	cTpDoc := aCfgNf[ScTipoDoc]

    // Valida que exista informacion de los titulos cuando la condicion de pago es informada
	//			// Valida que exista informacion de los titulos cuando la condicion de pago es informada
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .AND. nBaseDup > 0 .AND. DesTrans(Alltrim(Extrae(aDupli[1],5)))==0
       Aviso(STR0013,STR0015,{STR0002})  //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
        lRet	:= .F.
    EndIf

    //Controla se o valor total das duplicatas bate com o total
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .and. Val(Substr(aDupli[1],rat("³",aDupli[1])+1,len(aDupli[1]))) > 0  // O sistema gera uma estrutura vazia para duplicata.
        For nI := 1 To Len(aDupli)
            nTotDup += DesTrans(Extrae(aDupli[nI],5,))
        Next nI
        If lRet
            If Abs(Round(xMoeda(nBaseDup,nMoedaNF,nMoedaCor,dDataBase,,nTaxa),SuperGetMV(cCentavos,.F.,0)) - nTotDup) > SuperGetMV("MV_LIMPAG")
               Aviso(STR0013,STR0015,{STR0002})				 //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
                lRet	:= .F.
            EndIf
        EndIf
    Endif

	// Valida Natureza
	if lRet 
		lRet := ParVLdNt(cNatureza, cTpDoc)
	endif

	//Valida Condição de Pagamento
	if lRet
		lRet := ParVLdCd(cCondicao, cTpDoc)
	endif

Return lRet


/*/{Protheus.doc} fCposPAR
	Habilitar el campo F1_NUMTIM ó F2_NUMTIM
	@type  Function
	@author cristian.franco
	@since 08/08/2023
	@param aCposNF - Array - Campos
	@param aCfgNf - Array - Configuración de notas fiscales.
	@param cFunname - Caracter - Nombre de rutina.
	@param lAutoFact - Logico - .T. = Si es del tipo autofactura.
	@return lRet 
	/*/
Function fCposPAR(aCposNF, aCfgNF, cFunname, lAutoFact)
Local nPosNumTim :=0

Default aCposNF   :={}
Default aCfgNF    :={}
Default cFunname  := ""
Default lAutoFact := .F.

If Len(aCfgNf) > 0
	nPosNumTim := AScan(aCposNF,{|x| Alltrim(x[2])$"F1_NUMTIM|F2_NUMTIM"})
	If nPosNumTim > 0
		If (!aCfgNF[SlFormProp] .And.  !lAutoFact) .Or. AllTrim(aCfgNf[ScEspecie]) $ "RCD"
			aCposNF[nPosNumTim] := {,aCposNF[nPosNumTim][2],,,,,,,,,,,,,,,".T."}
		EndIf
	EndIf	
EndIf	
Return Nil

/*/{Protheus.doc} fVldFolPAR
	Validación de control de formularios
	@type  Function
	@author luis.samaniego
	@since 17/08/2023
	@version version
	@param 	cFilUso - Character - Filial de uso.
			cSerieDoc - Character - Serie del documento.
			cTipoEspec - Character - Especie del documento.
			cNumFiscal - Character - Número de documento.
	@return oJFolio - jSon - Información del registro en SFP.
	/*/
Function fVldFolPAR(cFilUso, cSerieDoc, cTipoEspec, cNumFiscal) As Object
Local aArea    as Array
Local aCpoQry  as Array
Local cQryCpos as Character
Local cQrySFP  as Character
Local nCpo     as Numeric
Local nStatus  as Numeric //1-OK, 2-No existe, 3-No activo, 4-No vigente, 5-Fuera de rango
Local oJFolio  as Object

Default cFilUso    := ""
Default cSerieDoc  := ""
Default cTipoEspec := ""
Default cNumFiscal := ""

	aArea := GetArea()
	oJFolio := JsonObject():New()
	cQrySFP := GetNextAlias()
	cQryCpos := "%SFP.FP_FILUSO, SFP.FP_SERIE, SFP.FP_NUMINI, SFP.FP_NUMFIM, SFP.FP_CAI, SFP.FP_ESPECIE, SFP.FP_ATIVO, SFP.FP_SERIE2, SFP.FP_AUTOFAC, SFP.FP_DTAVAL %"

	BeginSql alias cQrySFP
		Column FP_DTAVAL as Date
		SELECT %Exp:cQryCpos%
		FROM %Table:SFP% SFP
		WHERE SFP.FP_FILIAL = %Exp:(xFilial("SFP"))%
		AND SFP.FP_FILUSO = %Exp:cFilUso%
		AND SFP.FP_SERIE = %Exp:cSerieDoc%
		AND SFP.FP_ESPECIE = %Exp:cTipoEspec%
		AND SFP.%NotDel%
		ORDER BY %Order:SFP,6%
	EndSql

	nStatus := 2 //2-No existe
	aCpoQry := (cQrySFP)->(dbStruct())
	(cQrySFP)->(dbGoTop())
	While (cQrySFP)->(!EoF())
		If (cQrySFP)->(FP_ATIVO) == "2" 
			nStatus := 3 //3-No activo
		ElseIf !(dDataBase <= (cQrySFP)->FP_DTAVAL)
			nStatus := 4 //4-No vigente
		Else
			If !Empty(cNumFiscal) .And. (((cQrySFP)->FP_NUMINI <= cNumFiscal .And.  cNumFiscal > (cQrySFP)->FP_NUMFIM) .Or. ((cQrySFP)->FP_NUMINI > cNumFiscal .And.  cNumFiscal < (cQrySFP)->FP_NUMFIM))
				nStatus := 5 //5-Fuera de rango
			Else
				nStatus := 1 //1-OK
				For nCpo := 1 To Len(aCpoQry)
					oJFolio[aCpoQry[nCpo][1]] := &(aCpoQry[nCpo][1])
				Next nCpo
				Exit
			EndIf
		EndIf
		(cQrySFP)->(DbSkip())
	EndDo
	(cQrySFP)->(DbCloseArea())

	Do Case
		Case nStatus == 2 //2-No existe
			Help(" ", 1, "CtrFolio02", , STR0010, 2, 0,,,,,, {STR0016}) //"Esta serie o especie no está registrada en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal"
		Case nStatus == 3 //3-No activo
			Help(" ", 1, "CtrFolio03", , STR0012, 2, 0,,,,,, {STR0017}) //"Este rango de hojas esta registrado pero no esta activo. Por lo tanto, no podra utilizarse para la emisión del documento fiscal."
		Case nStatus == 4 //4-No vigente
			Help(" ", 1, "CtrFolio04", , STR0007, 2, 0,,,,,, {STR0018}) //"La fecha de emisión de este documento está fuera del límite registrado en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal"
		Case nStatus == 5 //5-Fuera de rango
			Help(" ", 1, "CtrFolio05", , STR0009, 2, 0,,,,,, {STR0019}) //"No existe este número registrado en ningún rango con esta serie o clase"
	EndCase

	RestArea(aArea)
	
Return oJFolio

/*/{Protheus.doc} LxCustoNC
	Calcula el costo en documentos NCP y NDI. 
	@type  Function
	@author luis.samaniego
	@since 18/09/2023
	@version version
	@param 	nItem - Numeric - Número de ítem de documentos fiscal.
			aEnvCus - Array - Valores para el cálculo del costo.
	@return aRet - Valores del costo para las 5 monedas.
	/*/
Function LxCustoNC(nItem, aEnvCus)
Local aCusto 	:= {}
Local aRet   	:= {}

Default nItem := 1
Default aEnvCus := {}

	aAdd(aEnvCus, SF4->F4_CREDST)
	aAdd(aEnvCus, 0)
	aAdd(aEnvCus, MaRetIncIV(nItem,"1"))
	aAdd(aEnvCus, SF4->F4_PISCOF)
	aAdd(aEnvCus, SF4->F4_PISCRED)
	aAdd(aEnvCus, 0)

	aAdd(aCusto, aEnvCus)

	aRet := RetCusEnt( , aCusto,,)
	
Return aRet[1]


/*/{Protheus.doc} ActItemPAR
	Actualiza valores de ítems cuando MV_DESCSAI = 2.
	@type  Function
	@author luis.samaniego
	@since 03/10/2023
	@version version
	@param 	cAlias - Caracter - Alias de tabla (SD1/SD2).
			aCfgNf - Array - Arrya con configuración para nota fiscal.
			cDescSai - Caracter - Valor de MV_DESCSAI.
			nMoeda - Numerico - Moneda del documento fiscal.
	@return Nil
	/*/
Function ActItemPAR(cAlias, aCfgNf, cDescSai, nMoeda)
Local nDec := 0
Local nT_PRCVEN	:= 0

Default cAlias   := ""
Default aCfgNf   := {}
Default cDescSai := SuperGetMV("MV_DESCSAI",.T., '1' )
Default nMoeda   := 1

	If cAlias == "SD2"
		nDec := MsDecimais(nMoeda)
		nT_PRCVEN := GetSX3Cache("D2_PRCVEN","X3_DECIMAL")
		If cDescSai == '2'
			SD2->D2_TOTAL := Round(SD2->D2_TOTAL - SD2->D2_DESCON, nDec)
			SD2->D2_PRCVEN := Round(SD2->D2_TOTAL / SD2->D2_QUANT, nT_PRCVEN)
		EndIf
	EndIf

Return

/*/{Protheus.doc} fCpoPrcPAR
	Actualiza valores de ítems en la visualización de un documento fiscal cuando MV_DESCSAI = 2. 
	@type  Function
	@author luis.samaniego
	@since 05/10/2023
	@version version
	@param 	aC - Array - Array con ítems de documento fiscal (aCols); la variable se pasa por referencia (@aC).
			aH - Array - Array con los campos de los ítems del documento fiscal.
			cFunName - Caracter - Función que detona el proceso.
			cAliasI - Caracter - Alias de tabla de items (SD1/SD2).
			nMoeda - Numerico - Moneda del documento. 
	@return Nil
	/*/
Function fCpoPrcPAR(aC, aH, cFunName, cAliasI, nMoeda)
Local nI      := 0
Local nPosUni := 0
Local nPosDes := 0
Local nPosTot := 0
Local nPosQtd := 0
Local nDecPUnit := GetSX3Cache("D2_PRCVEN","X3_DECIMAL")

Default aC       := {}
Default aH       := {}
Default cFunName := ""
Default cAliasI  := ""
Default nMoeda  := 1

	nPosUni:=Ascan(aH,{|x| Alltrim(x[2])=="D2_PRCVEN"})
	nPosDes:=Ascan(aH,{|x| Alltrim(x[2])=="D2_DESCON"})
	nPosTot:=Ascan(aH,{|x| Alltrim(x[2])=="D2_TOTAL" })
	nPosQtd:=Ascan(aH,{|x| Alltrim(x[2])=="D2_QUANT" })

	For nI:= 1 To Len(aC)
		aC[nI][nPosTot]	:= Round(aC[nI][nPosTot] + aC[nI][nPosDes], MsDecimais(nMoeda))
		aC[nI][nPosUni]	:= Round(aC[nI][nPosTot] / aC[nI][nPosQtd], nDecPUnit)
	Next

Return




/*/{Protheus.doc} fM143VCH
    función para obtener el campo asignado al IVC
    @author adrian.perez
    @since 10/10/2023
    @param cTabla, carácter, tabla usada en la MATA143 para guardar información de la TES
    @param cAux, carácter, indica el número de campo asignado para el IVC
    @return nil, nulo
    /*/

Function fM143VCH(cTabla,aAux)

	Local aAreaAnt :=GetArea()
	DEFAULT cTabla:=""
	DEFAULT aAux:={}

	dbSelectArea(cTabla)

    While (cTabla)->(!Eof())

		IF (cTabla)->FC_INCDUPL=="3" .AND. (cTabla)->FC_INCNOTA=="3"
		 	AADD( aAux,(cTabla)->FB_CPOLVRO  )
		ENDIF

		(cTabla)->(DbSkip())
	EndDo
	
	RESTAREA(aAreaAnt)   
Return nil

/*/{Protheus.docn fIVC143
    Se usa para restar el valor calculado del IVC ya que en la MATA143 lo suma 
    sin tener en cuenta la configuración de la TES.
    @author adrian.perez
    @since 10/10/2023
    @param cAux, carácter, indica el número de campo asignado para el IVC
    @param nTotalNf, numérico, total del documento de entrada a generar
    @return nil, nulo
    /*/

Function fIVC143(aAux,nTotalNf)
	Local nA:=0

	DEFAULT aAux:={}
	DEFAULT nTotalNf:=0
	 
		FOR nA:=1 To len(aAux)
			IF 	aAux[nA]!="0" .AND.	aAux[nA]!=""
				nTotalNf:=nTotalNf-DBC->&("DBC_VLIMP"+aAux[nA])
			ENDIF
		NEXT nA
	aAux:={}
Return NIL


/*/
{Protheus.doc} CHX5FILPAR
Funcão para o ponto de entrada CHGX5FIL, ajuste filial da SX5 exclusiva
@Obs Permitir filial exclusiva nas series das notas para mercado internacional
@type Function
@author e.tinti - DMICAS-84
@since 25/11/2024 
@param cSerie (Char) - Serie da Nota
@return cFilSX5 (Char) - Filial para busca da sequencia da nota na serie
/*/
Function CHX5FILPAR(cSerie)
Local cDescri := ""
Local cFilSX5 := xFilial("SX5")
Local aArea   := GetArea()
Local aSX5    := SX5->(GetArea())

Default cSerie := ""

If ExistBlock("CHGX5FIL")
	cFilSX5 := ExecBlock("CHGX5FIL",.F.,.F.,cSerie)
	If ! Empty(cFilSX5) .And. ! Empty(cSerie)
		DbSelectArea("SX5")
		DbSetOrder(1)
		If Empty(xFilial("SX5")) .And. DbSeek(cFilSX5 + "01" + cSerie) //Busca serie exclusiva na SX5
			cDescri := X5Descri() //Para mater a sequencia da serie para filial compartilhada da serie
			If ! DbSeek(xFilial("SX5") + "01" + cSerie) //Se não existir a serie compartilhada
				//Ajusta a serie compartilhada para uso na consulta F3
				FWPutSX5(Nil, "01", cSerie, cDescri, cDescri, cDescri, cDescri) //Inclui a serie
				//(BUG) Forca abertura da SX5 porque a rotina acima FWPutSX5 fecha esta tabela e nao deveria
				//(BUG) RestArea nao recupera a tabela do array caso esta for fechada pelo caminho  
				DbSelectArea("SX5") 
			Endif	
		Else //Nao existe uma serie exclusiva na SX5, retorna padrão
			cFilSX5 := xFilial("SX5")		
		Endif
	Endif
Endif
RestArea(aSX5)
RestArea(aArea)
Return(cFilSX5)


/*/
{Protheus.doc} GetSA2PAR
Funcão para obter o codigo do fornecedor para transfernecia entre filiais - Mata462TN
@type Function
@author e.tinti - DMICAS-94
@since 26/11/2024 
@param cNumFil (Char) - Filial
@return cCodFor (Char) - Fornecedor + Loja
/*/
Function GetSA2PAR(cNumFil)
Local nLenFil := Len(cFilAnt+cEmpAnt+cFilAnt)
Local nLenFor := TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1]
Local aDados  := FWGetSX5("75")
Local cCodFor := ""
Local cChave  := ""
Local cDescr  := ""
Local nPos    := 0

Default cNumFil := ""

If ! Empty(cNumFil)
	cChave := cNumFil+cEmpAnt+cFilAnt
	//Busca pela chave cadastrada das filiais
	For nPos := 1 To Len(aDados)
		cDescr := aDados[nPos,4]
		If Substr(cDescr,1,nLenFil) == cChave
			cCodFor := SubStr(cDescr,nLenFil+1,nLenFor)
		EndIf
	Next
Endif	
Return(cCodFor)


/*/
{Protheus.doc} AddSA2PAR
Funcão para gravar os parametros tabela SX5(75) Filiais: Origem x Destino x Fornecedor - Mata462TN
@type Function
@author e.tinti - DMICAS-94
@since 06/11/2024 
@param cNewFil (Char) - Filial
@return lRet (Bolean) - Confirme Consulta  
/*/
Function AddSA2PAR(cNewFil)
Local aDados := {}
Local cChave := ""
Local cDescr := ""
Local lRet   := .F.

Default cNewFil := ""

DbSelectArea("SA2")
DbSetOrder(1)
lRet := ConPad1(,,,"SA2",,,,"") //Seleciona o fornecedor para gravar
If lRet .And. ! Empty(cNewFil)
	aDados := FWGetSX5("75") //Dados da Tabela SX5
	cChave := StrZero(Len(aDados),6) //Pega ultima sequencia
	cChave := Soma1(cChave) //Incrementa 1
	cDescr := cFilAnt+cEmpAnt+cNewFil+SA2->A2_COD+SA2->A2_LOJA //Parametro Filial Origem x Empresa + Destino + Fornecedor
	FWPutSX5(Nil, "75", cChave, cDescr, cDescr, cDescr, cDescr) //BUG - se a tabela 75 estiver vazia, não inclui. 
Endif
Return(lRet)


/*/
{Protheus.doc} GetLvrPAR
Obter a posicao do imposto no livro conforme base redudida 30%x70%
@type Function
@author e.tinti
@since 08/01/1025 
@uso M460Livr e M100Livr - Paraguay (DMICAS-71) 
@param cTES (Char) - TES de Entrada ou TES de Saida
@return cRet (Char) - Posicao do campo referente ao imposto do livro 
/*/
Function GetLvrPAR(cTES)
Local cRet := ""
Local cTmp := ""
Local aSav := {}
Default cTES := ""
If !Empty(cTES)
	aSav := GetArea()
	cTmp := GetNextAlias()
	BeginSQL Alias cTmp
		SELECT FB_CPOLVRO
		FROM %Table:SFC% SFC
		INNER JOIN %Table:SFB% SFB ON SFB.%NotDel% AND FB_FILIAL = %xFilial:SFB% AND FB_CODIGO = FC_IMPOSTO AND FB_CODIMP = '1' AND FB_CLASSE = 'I'
		INNER JOIN %Table:SFF% SFF ON SFF.%NotDel% AND FF_FILIAL = %xFilial:SFF% AND FF_IMPOSTO = FB_CODIGO AND FF_COEF > 0 AND FF_RBASCAL > 0
		WHERE SFC.%NotDel% AND FC_FILIAL = %xFilial:SFC% AND FC_TES = %Exp:cTES%
		ORDER BY FB_CPOLVRO
	EndSQL
	If !(cTmp)->(Eof()) 
		cRet := (cTmp)->FB_CPOLVRO
	Endif	
	(cTmp)->(DBCloseArea())
	RestArea(aSav)
Endif
Return(cRet)


/*/{Protheus.doc} LxDelNfPar
	La función es llamada en LocxDelNF (LOCXNF.PRW)
	@type  Function
	@author Rafael Parma
	@since 23/12/2024
	@param 	aCfgNf, array, Datos con la configuración del documento.
	@param 	lAnulaSF3, lógico, Indica verdadero para anular el documento fiscal.
	@param 	lDeleta, lógico, Indica verdadero para eliminar el documento fiscal.
	@param 	cFunname, caráter, Nombre de rutina.
	@return lRet, lógico, Devuelve verdadero para eliminar el documento.
	/*/
Function LxDelNfPar(aCfgNf, lDeleta, lAnulaSF3, cFunname)
Local lRet := .T.
Default aCfgNf := {}
Default lDeleta := .F.
Default lAnulaSF3 := .F.
Default cFunname := ""

	If lDeleta .and. !lAnulaSF3 .and. cFunname $ "MATA467N|MATA462TN" .and. aCfgNf[SAliasHead]=="SF2" .and. FindFunction("LxParVldDl")
		lRet := LxParVldDl()
	EndIf

Return lRet


/*/{Protheus.doc} LxParVldDl
	Validaciones sobre el estado de transmisión de la factura electrónica al eliminar el documento.
	La función es llamada en LxDelNfPar (LOCXPAR.PRW)
	@type  Function
	@author Rafael Parma
	@since 23/12/2024
	@return lRet, lógico, Devuelve verdadero si cumple con las condiciones para eliminar el documento.
	/*/
Function LxParVldDl()
Local lRet := .T.

	If SF2->(FieldPos('F2_FLFTEX') > 0)
		If SF2->F2_FLFTEX == "1" //1=Enviado						
			Help("", 1, STR0021, , STR0022, 1, 0) // "SIFEN"###"No fue posible eliminar este documento, ya que tiene estatus Enviado en el SIFEN"
			lRet := .F.		
		ElseIf SF2->F2_FLFTEX == "6" //6=Autorizado
			Help("", 1, STR0021, , STR0023, 1, 0) // "SIFEN"###"No fue posible eliminar este documento, ya que tiene estatus Autorizado en el SIFEN"
			lRet := .F.		
		EndIf
	EndIf

Return lRet


/*/
{Protheus.doc} VLDRUCPAR
Validacao ao digitar o RUC PARAGUAY para A2_CGC
Validação do campo X3_VALID = 'VAZIO() .OR. VLDRUCPAR(M->A2_CGC)'
Picture X3_PICTURE '@R 9999999999'
Permite digitar sem o hifem, mas o retorno coloca o hifen
Não permite repetido, exeto para o mesmo codigo e loja diferente
Permitido repetidos para os RUCs especiais:
44444401-7 = Consumido Final IC
66666601-6 = Clientes Exportación
77777701-0 = Agentes Diplomáticos
88888801-5 = Clientes Exterior
99999901-0 = Proveedores Exterior
@type Function
@author e.tinti
@since 20/01/2025
@param cRUC as Character
@return lRet as Logical 
/*/
Function VLDRUCPAR(cRUC)
	Local lRet := .F.
	Local cDig := ""
	Local cCpo := ""
	Local cCod := ""
	Local cVal := ""
	Local	cTab := ""
	Local aSav := GetArea()
	Local cVar := ReadVar()
	Local oMod := FWModelActive()
	Default cRUC := iif(Empty(cVar),"",&(cVar))
	cCpo := StrTran(cVar,"M->","")
	cTab := "S"+SubStr(cCpo,1,At("_",cCpo)-1)
	cRUC := AllTrim(StrTran(cRUC,"-",""))
	cDig := Right(cRUC,1)
	cRUC := SubStr(cRUC,1,Len(cRUC)-1)
	cVal := PadR(cRUC+"-"+cDig, GetSX3Cache(cCpo,"X3_TAMANHO"))
	If Len(cRUC) >= 3 .And. Len(cRUC) <= 9
		lRet := DvRucPar(cRUC) == cDig //Validacao do DV pela rotina padrão
	Endif	
	If !lRet 
		Help(" ",1,"RUC") //Digito Verificador Incorreto.
	ElseIf (cRUC+"-"+cDig) $ "|44444401-7|66666601-6|77777701-0|88888801-5|99999901-0|" //RUC Generico
		lRet := .T.
	ElseIf "_CGC" $ cCpo
		cCod := StrTran(cCpo,"_CGC","_COD")
		(cTab)->(DbSetOrder(3)) //_FILIAL + _CGC
		(cTab)->(MsSeek(xFilial(cTab)+cRUC))
		While (cTab)->(!Eof()) .And. ((cTab)->&(cCpo) == cVal .Or. Trim((cTab)->&(cCpo)) == cRUC+cDig)
			If (cTab)->&(cCod) != M->&(cCod)
				lRet := .F. //Existente
			Endif
			(cTab)->(DbSkip())
		End
		iif(lRet, Nil, Help(" ",1,"JAEXISTINF"))
	Endif	
	iif(lRet, iif(Empty(oMod), &(cVar) := cVal, FWFldPut(cCpo, cVal)), Nil)
	RestArea(aSav)	
Return(lRet)


/*/
{Protheus.doc} A103HDEPAR
Ponto Entrada para alterar e/ou incluir campos em A103DigEnd (Endereçamento Lotes)
Chamado de A103DigEnd do Programa Mata103.prw
@type Function
@author e.tinti
@since 20/05/2025 
@param aFields as Array (Campos SD1 do aHeader)
@param aDigEnd as Array (Dados SD1 aCols)
@return Logical 
/*/
Function A103HDEPAR(aFields, aDigEnd)
	Local cKey := ""
	Local nPos := 0
	Local nDig := 0
	Local aDig := {}
	Local aRet := {}
	Local aSav := GetArea()
	Local lRet := ExistBlock("A103HGDE")
	If lRet 
		aRet := ExecBlock("A103HGDE",.F.,.F.,aFields)
		If ValType(aRet) == "A"
			DbSelectArea("SD1")
			DbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			For nDig := 1 To Len(aDigEnd)
				cKey := aDigEnd[nDig,9]+aDigEnd[nDig,10]+aDigEnd[nDig,11]+aDigEnd[nDig,12]+aDigEnd[nDig,2]+aDigEnd[nDig,1]
				If MsSeek(xFilial("SD1")+cKey)
					aAdd(aDig, Array(Len(aRet)))
					For nPos := 1 To Len(aRet)
						aDig[Len(aDig),nPos] := &(aRet[nPos])
					Next nPos
					aAdd(aDig[Len(aDig)], .F.)
				Endif
			Next nDig
			If Len(aDig) > 0
				aDigEnd := aClone(aDig)
				aFields := aClone(aRet)
			Endif
		Endif
		RestArea(aSav)	
	Endif
Return(lRet)

/*/{Protheus.doc} ParVLdNt
	Valida a natureza da operação conforme o tipo de documento para o país Paraguai.
	@author Alan Lunardi
	@type  Function
	@since 27/03/2025
	@version 1.0
	@param cNatureza, Character, Código da natureza da operação.
	@param cTipoDoc, Character, Tipo do documento fiscal (ex: "A" para adiantamento).
	@return lRet, Logical, Retorna .T. se a validação for bem-sucedida ou exibe uma mensagem de erro caso contrário.
	@example
		? ParVLdNt("NAT001", "A")
	@see 
	/*/
Function ParVLdNt(cNatureza, cTipoDoc)
	Local cFilSed 	 	:= xFilial("SED")
	Local lRet		 	:= .T.
	Local aSED		 	:= SED->(GetArea())
	Default cNatureza	:= ''
	Default cTipoDoc 	:= ''
	
	If Trim(cNatureza) <> ""
		DbSelectArea("SED")
		DbSetOrder(1)
		IF MsSeek(cFilSed + cNatureza)		
			If cTipoDoc == "A" .AND. SED->ED_OPERADT <> "1"
				Help("", 1, STR0013, , STR0029, 1, 0,,,,,, ) // "Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
				lRet := .F.
			EndIf
		endif
	ElseIf cTipoDoc == "A"
		Help("", 1, STR0013, , STR0029, 1, 0,,,,,, ) // "Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
		lRet := .F.
	EndIf

	RestArea(aSED)

Return lRet

/*/{Protheus.doc} ParVLdCd
	Valida a condição de pagamento conforme o tipo de documento para o país Paraguai.
	@author Alan Lunardi
	@type  Function
	@since 27/03/2025
	@version 1.0
	@param cCondicao, Character, Código da condição de pagamento.
	@param cTipoDoc, Character, Tipo do documento fiscal (ex: "A" para adiantamento, "N" para nota fiscal normal).
	@return lRet, Logical, Retorna .T. se a validação for bem-sucedida ou exibe uma mensagem de erro caso contrário.
	@example
		? ParVLdCd("COND001", "A")
	@see 
	/*/
Function ParVLdCd(cCondicao, cTipoDoc)
	Local cFilSE4	 	:= xFilial("SE4")
	Local lRet		 	:= .T.
	Local aSED		 	:= SE4->(GetArea())
	Default cCondicao	:= ''
	Default cTipoDoc 	:= ''
	
	If Trim(cCondicao) <> ""
		DbSelectArea("SE4")
		DbSetOrder(1)
		If MsSeek(cFilSE4+cCondicao)
			If cTipoDoc == "A" .AND. SE4->E4_CTRADT == "1"
				Help("", 1, STR0013, , STR0032, 1, 0,,,,,, )  //"Na Nota Fiscal de Adiantamento não é possível utilizar uma condição de pagamento que compense adiantamentos."
				lRet := .F.
			EndIf
		endif
	EndIf

	RestArea(aSED)

Return lRet


/*/{Protheus.doc} QIECMD1PAR 
	Atualiza array aCusto adcionando o custo das notas de gastos armazem do CQ SD1 Posicionado DMICAS-669 PAR 
	@Uso FunName("QIEA215") - Function PegaCMD1(sigacusa.prx)
	@type Function
	@author e.tinti
	@since 10.07.2025
	@version v1.0
	@param aCusto,  array,  Valor custo do produto
	@param cSerOri, string, D1_SERIE
	@param cNFOri,  string, D1_DOC	
	@param cItem,   string, D1_ITEM	
	@param cNumCQ,  string, D1_NUMCQ
	@return aCusto, array,  Valor custo do produto + gastos
/*/
Function QIECMD1PAR(aCusto, cSerOri, cNFOri, cItem, cNumCQ)
	Local cLCQ := SuperGetMV("MV_CQ",.F.,"98") As String
	Local cQry As String
	Local cTmp As String
	Local oExe AS Object
	Default aCusto	 := {0,0,0,0,0}
	Default cSerOri := SD1->D1_SERIE
	Default cNFOri  := SD1->D1_DOC
	Default cItem   := SD1->D1_ITEM
	Default cNumCQ  := SD1->D1_NUMCQ
	If !Empty(cNumCQ) //Controle de Qualidade
		cQry := " SELECT D1_CUSTO, D1_CUSTO2, D1_CUSTO3, D1_CUSTO4, D1_CUSTO5"
		cQry += " FROM " + RetSqlName("SD1")
		cQry += " WHERE D1_FILIAL = ? AND D1_SERIORI = ? AND D1_NFORI = ?" //Index(19)
		cQry += " AND D1_ITEM = ? AND D1_NUMCQ = ? AND D1_LOCAL = ? AND D1_QUANT = ? AND D_E_L_E_T_= ?"
		cQry := ChangeQuery(cQry)
		oExe := FWExecStatement():New(cQry)
		oExe:SetString(1, xFilial("SD1"))
		oExe:SetString(2, cSerOri)
		oExe:SetString(3, cNFOri)	
		oExe:SetString(4, cItem)
		oExe:SetString(5, cNumCQ)
		oExe:SetString(6, cLCQ)		
		oExe:SetString(7, "0")	
		oExe:SetString(8, " ")
		cTmp := oExe:OpenAlias()
		While (cTmp)->(!Eof())
			aCusto[1] += (cTmp)->D1_CUSTO
			aCusto[2] += (cTmp)->D1_CUSTO2
			aCusto[3] += (cTmp)->D1_CUSTO3
			aCusto[4] += (cTmp)->D1_CUSTO4
			aCusto[5] += (cTmp)->D1_CUSTO5
			(cTmp)->(DbSkip())
		EndDo
		(cTmp)->(DbCloseArea())
		oExe:Destroy()
		FreeObj(oExe)
	Endif
Return(aCusto)
