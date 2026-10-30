#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999CTB
	Clase responsable por el evento de reglas de negocio de 
localización padrón para contabilidad
	@type 		Class
	@author 	Jose.Gonzalez
	@version	12.1.2510 / Superior
	@since		09/06/2026
/*/
Class F999CTB From FwModelEvent 

	DATA lDigita   As Logical

	DATA lAglutina As Logical

	DATA lGeraLanc As Logical

	Method New() CONSTRUCTOR

	Method VldActivate()		

	Method AfterTTS()

	Method F999CONT()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	Jose.Gonzalez
	@version	12.1.2510 / Superior
	@since		09/06/2026
/*/
Method New() Class F999CTB
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@param 		oModel	 - objeto	 - Modelo de datos.
	@author 	Jose.Gonzalez
	@version	12.1.2510 / Superior
	@since		09/06/2026
/*/
Method VldActivate(oModel) Class F999CTB
Local lRet			:= .T.
Local nOperation 	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT

		Pergunte("FIN850P", .F., /*cTitle*/, .F., /*oDlg*/, .T.)   //Pergunta model
		
		self:lDigita	:= MV_PAR07 == 1
		
		self:lAglutina	:= MV_PAR08 == 1
		
		self:lGeraLanc	:= MV_PAR09 == 1
	EndIf
	
Return lRet

/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio de retenciones 
después de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	 - Modelo de datos.
@author 	Jose.Gonzalez
@version	12.1.2510 / Superior
@since		09/06/2026 
/*/
Method AfterTTS(oModel) Class F999CTB
Local nOperation := oModel:GetOperation()
Local oModelEOP  := oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		self:F999CONT(oModel)
	EndIf

Return Nil


/*/{Protheus.doc} F999CONT
Metodo responsable por realizar la contabilidad de las operaciones de contabilidad de localización padrón.
@type 		Method
@param 		oModel	 - objeto	 - Modelo de datos.
@author 	Jose.Gonzalez
@version	12.1.2510 / Superior
@since		09/06/2026
/*/
Method F999CONT(oModel) Class F999CTB
Local oModelCTB    := oModel:GetModel('CTB_DETAIL')
Local oModelFJR    := oModel:GetModel('FJR_MASTER')
Local oModelSE2    := oModel:GetModel('SE2_DETAIL')
Local lUsaFlag     := SuperGetMV("MV_CTBFLAG" , .T., .F.)
Local lLanPd570    := .F.
Local lLanPd5B9    := .F.
Local lLanPd5BA    := .F.
Local lLanPd5BB    := .F.
Local lLanPd5BC    := .F.
Local lLanPd5BD    := .F.
Local lLanPd5BE    := .F.
Local lLanPd5BF    := .F.
Local lLanctOk     := .F.
Local aGetSx5      := {}
Local cLoteCom     := ""
Local aHdlPrv      := {}
Local nHdlPrv      := 0
Local nRECSEKDia   := 0
Local aAreaSEK     := {}
Local aAreaSA2     := {}
Local aAreaSA6     := {}
Local cPadrao      := ""
Local cAlias       := ""
Local cKeyImp      := ""
Local nVlLanc      := 0
Local nTotalLanc   := 0
Local aDiario      := {}
Local cArquivo     := ""
Local cOrdPago     := ""
Local aFlagCTB	   := {}
Local cOpcElt	   := oModel:GetModel("EOP_MASTER"):GetValue("CPGTOELT")
Local cDebMed	   := MVCHEQUE
Local cDebInm	   := "TF|EF"
Local nX           := 0
Local nJ           := 0
Local cFilSEK      := xFilial("SEK")
Local cFilSE2      := ""

If self:lGeraLanc 
	lLanPd570 := VerPadrao("570")
	lLanPd5B9 := VerPadrao("5B9")
	lLanPd5BA := VerPadrao("5BA")
	lLanPd5BB := VerPadrao("5BB")
	lLanPd5BC := VerPadrao("5BC")
	lLanPd5BD := VerPadrao("5BD")
	lLanPd5BE := VerPadrao("5BE")
	lLanPd5BF := VerPadrao("5BF")
EndIf

If lLanPd570
	aGetSx5 := FwGetSX5("09", "FIN")
	cLoteCom := "FIN"
	If Len(aGetSx5) > 0
		cLoteCom := AllTrim(aGetSx5[1][4])
	EndIf
EndIf

If lLanPd570
	nHdlPrv := HeadProva(cLoteCom,"PAGO011",substr(cUsuario, 7, 6),@cArquivo)
	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")   
	EndIf
	aHdlPrv := {nHdlPrv, "570", "FINA850", "PAGO011", cLoteCom}
EndIf
	
For nX := 1 To oModelFJR:Length()
	oModelFJR:GoLine(nX)

	If oModelFJR:GetValue("MARK") <> 1
		Loop
	EndIf

	aFlagCTB := {}
	cOrdPago := oModelFJR:GetValue("FJR_ORDPAG")

	If oModelSE2:SeekLine({{"E2_ORDPAGO", cOrdPago}}, .F., .T.)
		SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
		cFilSE2 := SE2->E2_FILORIG
	EndIf

	For nJ := 1 To oModelCTB:Length()
		oModelCTB:GoLine(nJ)

		If oModelCTB:GetValue("ORDPAGO") == cOrdPago
			aAdd(aFlagCTB, {Alltrim(oModelCTB:GetValue("CAMPO")),;
									oModelCTB:GetValue("VALOR"),;
									oModelCTB:GetValue("TABLA"),;
									oModelCTB:GetValue("RECNO"), 0, 0, 0})
		EndIf
	Next

	//Gerar os lancamento Contabeis On-Line                           
	If nHdlPrv > 0 .And. self:lGeraLanc .And. cOpcElt <> "1"

		//Gera Lancamento Contab. para Orden de Pago.
		If self:lGeraLanc
			DbSelectArea("SEK")
			aAreaSEK := SEK->(GetArea()) //Pega area para depois restaurar e gravar
			aAreaSA2 := SA2->(GetArea())
			aAreaSA6 := SA6->(GetArea())
			SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
			SEK->(MsSeek(cFilSEK+cOrdPago,.F.))
			nRECSEKDia := SEK->(Recno())
			SA2->(DbsetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			SA2->(MsSeek(xFilial("SA2",cFilSE2)+SEK->EK_FORNECE+SEK->EK_LOJA))
			Do while !SEK->(EOF()) .And. SEK->EK_ORDPAGO == cOrdPago

				Do Case  
					Case SEK->EK_TIPODOC == "TB" .And. SEK->(EK_TIPO) $ MV_CPNEG+"/"+MVPAGANT .And. lLanPd5B9
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5B9", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5B9"
					Case SEK->EK_TIPODOC == "TB" .And. !SEK->(EK_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. lLanPd5BA
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BA", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BA"
					Case SEK->EK_TIPODOC == "PA" .And. lLanPd5BB
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BB", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BB"
					Case SEK->EK_TIPODOC == "CP" .And. Alltrim(SEK->EK_TIPO) $ cDebMed .And. lLanPd5BC
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BC", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BC"
					Case SEK->EK_TIPODOC == "CP" .And. Alltrim(SEK->EK_TIPO) $ cDebInm .And. lLanPd5BD
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BD", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BD"
					Case SEK->EK_TIPODOC == "CT" .And. lLanPd5BE
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BE", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BE"
					Case SEK->EK_TIPODOC == "RG" .And. lLanPd5BF
						lLanPd570 := .T.
						aHdlPrv := {nHdlPrv, "5BF", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "5BF"
					Otherwise
						aHdlPrv := {nHdlPrv, "570", "FINA850", "PAGO011", cLoteCom}
						cPadrao := "570"	
				EndCase

				If lLanPd570
					SA6->(DbsetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
					SA6->(MsSeek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))
					Do Case  
						Case (Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")))
							cAlias := "SF2"
						Case (Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")))
							cAlias := "SF2"
						Otherwise
							cAlias := "SF1"
					EndCase

					cKeyImp := xFilial(cAlias, cFilSE2)+SEK->EK_NUM+SEK->EK_PREFIXO+SEK->EK_FORNECE+SEK->EK_LOJA

					If (cAlias == "SF1")
						cKeyImp += SE1->E1_TIPO
					EndIf

					If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd(aFlagCTB, {"EK_LA", "S", "SEK", SEK->(RecNo()), 0, 0, 0})
					EndIf

					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

					nVlLanc := DetProva(nHdlPrv,;
					cPadrao,;
					"FINA850" /*cPrograma*/,;
					cLoteCom,;
					/*@nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/,;
					.F.,;
					"CTK",;  
					"CT2",;
					"CV3")
					If nVlLanc == 0 .And. Len(aFlagCTB) > 0 .And. Len(aFlagCTB[Len(aFlagCTB)]) >= 2    
						aFlagCTB[Len(aFlagCTB)][2]:= ""
					EndIf
					nTotalLanc := nTotalLanc + nVlLanc
				EndIf
				SEK->(DbSkip())
			EndDo
			RestArea(aAreaSEK)
			RestArea(aAreaSA2)
			RestArea(aAreaSA6)
		EndIf

		If lLanPd570
			RodaProva(nHdlPrv,nTotalLanc)
			aDiario := {}
			If UsaSeqCor()
				aDiario := {{"SEK",nRECSEKDia,cCodDiario,"EK_NODIA","EK_DIACTB"}}
			EndIf

			lLanctOk := cA100Incl(cArquivo,;
			nHdlPrv,;
			3 /*nOpcx*/,;
			cLoteCom,;
			self:lDigita,;
			self:lAglutina,;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			aDiario,;
			/*aTpSaldo*/,;
			.F.,;
			"CTK",;
			"CT2",;
			"CTF")

			SET KEY VK_F4 to
			SET KEY VK_F5 to
			SET KEY VK_F6 to
			SET KEY VK_F7 to

			If lLanctOk .And. !lUsaFlag
				SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
				SEK->(MsSeek(cFilSEK+cOrdPago))
				Do while  !SEK->(EOF()) .And. cFilSEK == SEK->EK_FILIAL .And. cOrdPago == SEK->EK_ORDPAGO
					RecLock("SEK",.F.)
						SEK->EK_LA := "S"
					MsUnLock()
					SEK->(DbSkip())
				Enddo
			EndIf
		EndIf
	EndIf
Next

Return Nil
