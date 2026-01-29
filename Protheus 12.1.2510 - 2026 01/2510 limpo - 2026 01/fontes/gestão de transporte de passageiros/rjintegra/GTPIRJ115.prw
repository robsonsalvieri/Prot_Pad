#Include "GTPIRJ115.ch"
#Include "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ115

Adapter REST da rotina de BILHETE 

@type 		function
@sample 	GTPIRJ115()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@param 	 	aParams, logical - informações pertinentes ao processo para filtro (.T.) ou não (.F.)
@param 	 	lMonit, logical - indica se a chamada foi realizada através de monitor (.T.) ou não (.F.)
@param 	 	lAuto, logical - indica se a chamada foi realizada através de automação (.T.) ou não (.F.)
@param 	 	cResultAuto, char - Vindo de script de automação
@param 	 	cXmlAuto, char - Vindo de script de automação
@return		lRet, Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	henrique.toyada
@since 		31/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ115(lJob,aParams,lMonit,lAuto,cResultAuto,cXmlAuto,cChvBPE,cTipoBPE)

	Local aArea   := GetArea() 
	Local lRet    := .T.
	Local cEmpRJ  := nil
	Local dDtIni  := nil
	Local cHrIni  := nil
	Local dDtFim  := nil
	Local cHrFim  := nil
	Local cAgeIni := nil
	Local cAgeFim := nil	

	Default lJob 	    := .F. 
	Default aParams	    := {}
	Default lAuto       := .F.
	Default cResultAuto := ''
	Default cXmlAuto    := ''
	Default cChvBPE		:= ''
	Default cTipoBPE	:= ''

	If ( Len(aParams) == 0 )
	
		If ( Pergunte('GTPIRJ115',!lJob) )

			cEmpRJ  := MV_PAR01
			dDtIni  := MV_PAR02
			cHrIni  := MV_PAR03
			dDtFim  := MV_PAR04
			cHrFim  := MV_PAR05
			cAgeIni := AllTrim(MV_PAR06)
			cAgeFim := AllTrim(MV_PAR07)
		Else
			lRet := .F.
		EndIf

	ElseIf lJob

		cEmpRJ  := aParams[1]
		dDtIni  := aParams[2]
		cHrIni  := aParams[3]
		dDtFim  := aParams[4]
		cHrFim  := aParams[5]
		cAgeIni := aParams[6]
		cAgeFim := aParams[7]		

	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI115Receb(lJob, oSelf, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim,@lMonit, lAuto,cResultAuto,cXmlAuto,cChvBPE,cTipoBPE)}, , STR0001) //"Processando registros de Bilhetes... Aguarde!"
	EndIF

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI115Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	henrique.toyada
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI115Receb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim, lMonit, lAuto, cResultAuto, cXmlAuto, cChvBPE, cTipoBPE)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA115")
Local oMdlGIC	  := Nil
Local oMdlGZP     := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GIC_FILIAL", "GIC_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nPos        := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'
Local cFilAux     := ""
Local cAgencia      := ""
Local cItemSeq		:= ""
Local aFldsGZP	    := {}
Local aDPXXFGZP     := {}
Local cFPValid      := "II|TP|IM|CR|DE|OS|CO|DO|GO|RC|RS|NC|CC|FA|PY|PC|PD|RB|VT|CD|JR|TB|LI|TS|PP|CL"
Local cFormaPag1    := ""
Local cFormaPag2    := ""
Local cFormaPag3    := ""
Local cTipoPag1    	:= ""
Local cTipoPag2    	:= ""
Local cTipoPag3    	:= ""
Local aFormPag      := {}
Local nLenGZP       := 0
Local nFormaPag     := 0
Local nField        := 0
Local lAddLine      := .F.
Local cTPExcecao    := 'D|E'
//Local cMotivoExcec:= '27'
Local cRotina	  	:= "GTPIRJ115"
Local aError	  	:= {}
Local cChvSub		:= ""
Local _cKeySub      :=  "SSC|SCC"
Local lHabForPagt	:= GTPGetRules("HABFRMAPGT",,,.F.)

//DSERGTP-11094
Local aRequisicao   := {} 
Local cCodReq		:= ""
Local cCliReq		:= ""
Local cCliCgc		:= ""
Local cDesReq 		:= ""
Local lIntReq       := GTPGetRules("HABINTREQ",,,.F.)
Local cCancBpe		:= ""
Local lPEIntId	  	:= Existblock("GTPINTEGID")
Local xValorPE		:= ""
Local cCodePE	  	:= ""
Local cRefer1		:= ""

Local lBCA			:= .F. //Só gera fiscal
Local lIVP			:= .F. 

Public cValDi 		:= 0

Default cEmpRJ      := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtIni      := dDataBase-1
Default cHrIni      := '0000'
Default dDtFim      := dDataBase-1
Default cHrFim      := '2359'
Default cAgeIni     := ''
Default cAgeFim     := ''
Default cResultAuto := ''
Default cXmlAuto    := ''
Default cChvBPE		:= ''
Default cTipoBPE    := ''

oRJIntegra:SetPath("/bilhete/venda2")
oRJIntegra:SetServico('Bilhete')

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataHoraInicial', SubStr(DtoS(dDtIni), 3,8) + STRTRAN(cHrIni,":",""))
oRJIntegra:SetParam('dataHoraFinal'	 , SubStr(DtoS(dDtFim), 3,8) + STRTRAN(cHrFim,":",""))


If !Empty(cAgeIni)
	oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
Endif
If !Empty(cAgeFim)
	oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
Endif

If !Empty(cChvBPE)
	oRJIntegra:SetParam('chaveBPE', AllTrim(cChvBPE))
	oRJIntegra:SetParam('indstatusboleto', cTipoBPE)
Endif

aFldDePara	:= aClone(oRJIntegra:GetFieldDePara())
aDeParaXXF  := aClone(oRJIntegra:GetFldXXF())

oRJIntegra:SetServico("Bilhete/FormaPagamento",.T.)

aFldsGZP := aClone(oRJIntegra:GetFieldDePara())
aDPXXFGZP  := aClone(oRJIntegra:GetFldXXF())

oRJIntegra:SetServico('Bilhete')

If oRJIntegra:Get(cResultAuto)

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "GIC", "GIC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGIC:GetValue('GIC_CODIGO'), 'GIC'))) },.T.)

	GIC->(DbSetOrder(1))	// GIC_FILIAL+GIC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui
		
		For nX := 0 To nTotReg

			GIC->(DbSetOrder(1))	// GIC_FILIAL+GIC_CODIGO

			lContinua := .T.
			
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))  //"Processando registros de Bilhetes - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf
			// para essa integração é preciso localizar a filial. Caso não encontrada, pular para próximo item do JSON
			If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nX, 'empresa', 'C'), , "2")))
				Loop
			Else
				cFilAnt := cFilAux
			EndIf
			//Incluir quando o motivo de cancelamento não for o 27 E
			//If oRJIntegra:GetJsonValue(nX, "motivoCancelamento", "N") <> 27 .AND. oRJIntegra:GetJsonValue(nX, "statusBilhete", "C") <> 'E' .Or.;
				//(oRJIntegra:GetJsonValue(nX, "statusBilhete", "C") == 'E' .And. oRJIntegra:GetJsonValue(nX, "statusBilhete", "C") == 'V')
				
				lBCA := oRJIntegra:GetJsonValue(nX, "codigoVenda", "C") == "BCA"
				lIVP := oRJIntegra:GetJsonValue(nX, "codigoVenda", "C") == "IVP" .And. oRJIntegra:GetJsonValue(nX, 'integra', 'C') == "F"
				
				If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTransacao', 'C')) .And. (oRJIntegra:GetJsonValue(nX, 'integra', 'C') == "T" .or.lBCA .Or. lIVP)
					cCode := GTPxRetId("TotalBus", "GIC", "GIC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
					cRefer1 := oRJIntegra:GetJsonValue(nX, 'numerobpe', 'C')

					If lPEIntId
						cCodePE := ExecBlock("GTPINTEGID",.F.,.F.,{"GIC_BILHET",nX,oRJIntegra})
						If ValType(cCodePE) == "C" .AND. !Empty(cCodePE)
							cCode := cCodePE
						Endif
					EndIf

					If lPEIntId .AND. !Empty(cCodePE)
						GIC->(DBSetOrder(4)) //GIC_FILIAL+GIC_BILHET

						If !GIC->(DbSeek(xFilial('GIC') + cCodePE))
							nOpc := MODEL_OPERATION_INSERT
						Else
							nOpc := MODEL_OPERATION_UPDATE
						Endif
					ElseIf Empty(cIntID) 
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. GIC->(DbSeek(xFilial('GIC') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0008,; //"Bilhetes"
											oRJIntegra:cUrl,;
											oRJIntegra:cPath,;
											cRotina,;
											oRJIntegra:cParam,;
											cErro,;
											Nil,;
											cRefer1)
							aAdd(aError, cErro)
						Endif
					EndIf
					
					If lContinua
						
							oModel:SetOperation(nOpc)
							oModel:Activate()
							oMdlGIC := oModel:GetModel("GICMASTER")
							oMdlGZP	:= oModel:GetModel("GZPPAGTO")
							//Pegando os dados do pagamento
							cFormaPag1 	:= oRJIntegra:GetJsonValue(nX, "formaPagamento1", "C")
							cformaPag2 	:= oRJIntegra:GetJsonValue(nX, "formaPagamento2", "C")
							cformaPag3 	:= oRJIntegra:GetJsonValue(nX, "formaPagamento3", "C")
							cCodVenda  	:= oRJIntegra:GetJsonValue(nX, "codigoVenda", "C")
							cChvSub		:= oRJIntegra:GetJsonValue(nX, "chSubstitutivabpe", "C")
							cTipoPag1 	:= oRJIntegra:GetJsonValue(nX, "tipoPago1", "C")
							cTipoPag2 	:= oRJIntegra:GetJsonValue(nX, "tipoPago2", "C")
							cTipoPag3 	:= oRJIntegra:GetJsonValue(nX, "tipoPago3", "C")

							If lHabForPagt
								cFPValid      := "DI|DE|CR|NC|TP|IM|OS|BA|PT|RS|DP|CD|SM|LP|TI|MB|AD|MP|EJ|CL"
								If !Empty(cTipoPag1)
									cFormaPag1	:=	siglatipopagto(cTipoPag1,cFormaPag1)
								Endif
								
								If !Empty(cTipoPag2)
									cFormaPag2	:=	siglatipopagto(cTipoPag2,cFormaPag2)								
								Endif

								If !Empty(cTipoPag3)
									cFormaPag3	:=	siglatipopagto(cTipoPag3,cFormaPag3)		
								Endif
							Endif
							
							cItemSeq := "001"
							If !oRJIntegra:GetJsonValue(nX, "statusBilhete", "C") $ cTPExcecao
								cValDi := 0
								If (cformaPag1 $ cFPValid)
									aAdd(aFormPag, {cformaPag1,;//formaPagamento1 - GZP_TPAGTO
													oRJIntegra:GetJsonValue(nX, "nsu1", "C"),; //nsu1 - GZP_NSU
													oRJIntegra:GetJsonValue(nX, "descCartao1", "C"),;//descCartao1 - GZP_DCART
													oRJIntegra:GetJsonValue(nX, "valorPagamento1", "N"),;//valorPagamento1 - GZP_VALOR
													oRJIntegra:GetJsonValue(nX, "qtdParcelas1", "N"),;//qtdParcelas1 - GZP_QNTPAR
													oRJIntegra:GetJsonValue(nX, "autorizacao1", "C"); //autorizacao1 - GZP_AUT
													})
								ElseIf !Empty(cformaPag1)
									cValDi += oRJIntegra:GetJsonValue(nX, "valorPagamento1", "N")
								EndIf
								If (cformaPag2 $ cFPValid)
									aAdd(aFormPag, {cformaPag2,;//formaPagamento1 - GZP_TPAGTO
													oRJIntegra:GetJsonValue(nX, "nsu2", "C"),; //nsu1 - GZP_NSU
													oRJIntegra:GetJsonValue(nX, "descCartao2", "C"),;//descCartao2 - GZP_DCART
													oRJIntegra:GetJsonValue(nX, "valorPagamento2", "N"),;//valorPagamento1 - GZP_VALOR
													oRJIntegra:GetJsonValue(nX, "qtdParcelas2", "N"),;//qtdParcelas1 - GZP_QNTPAR
													oRJIntegra:GetJsonValue(nX, "autorizacao2", "C"); //autorizacao1 - GZP_AUT
													})
								ElseIf !Empty(cformaPag2)
									cValDi += oRJIntegra:GetJsonValue(nX, "valorPagamento2", "N")
								EndIf
								If (cformaPag3 $ cFPValid)
									aAdd(aFormPag, {cformaPag3,;//formaPagamento1 - GZP_TPAGTO
													oRJIntegra:GetJsonValue(nX, "nsu3", "C"),; //nsu1 - GZP_NSU
													oRJIntegra:GetJsonValue(nX, "descCartao3", "C"),;//descCartao3 - GZP_DCART
													oRJIntegra:GetJsonValue(nX, "valorPagamento3", "N"),;//valorPagamento1 - GZP_VALOR
													oRJIntegra:GetJsonValue(nX, "qtdParcelas3", "N"),;//qtdParcelas1 - GZP_QNTPAR
													oRJIntegra:GetJsonValue(nX, "autorizacao3", "C"); //autorizacao1 - GZP_AUT
													})
								ElseIf !Empty(cformaPag3)
									cValDi += oRJIntegra:GetJsonValue(nX, "valorPagamento3", "N")
								EndIf
							EndIf

							
							For nY := 1 To Len(aFldDePara)
								// recuperando a TAG e o respectivo campo da tabela 
								cTagName    := aFldDePara[nY][1]
								cCampo      := aFldDePara[nY][2]
								cTipoCpo    := aFldDePara[nY][3]
								lOnlyInsert := aFldDePara[nY][6]
								lOverWrite  := aFldDePara[nY][7]
								xValor      := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)
								// recuperando através da TAG o valor a ser inserido no campo 
								If !Empty(cTagName) .And. (ValType(xValor) == 'N' .Or. !Empty(xValor))
									If cCampo == "GIC_AGENCI"
										xValor := AllTrim(cEmpRJ) + '|' + xValor //Campo na xxf é gravado composto empresa + "|" + id
										cAgencia := xValor
									ElseIf cTagName == "dataHoraVendaT" .and. cCampo == "GIC_HRVEND"
										xValor := substr(xValor,12,5)
									ElseIf cTagName == "dataHoraViagemT"  .and. cCampo == "GIC_HORA"
										xValor := STRTRAN(substr(xValor,12,5),":","")
									ElseIf cTagName == "sentido"  .and. cCampo == "GIC_SENTID"
										xValor := IIF(xValor == "V",'1','2')
									ElseIf cCampo == "GIC_TELPAS"
										xValor := RemoverCaracteresTelefone(xValor)
									ENDIF
									// verificando a necessidade de realizar o DePara XXF
									If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
										xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
									EndIf
									If cTagName == "tipoVenda"  .And. cCampo == "GIC_TIPO"
										If GYB->(DbSeek(xFilial('GYB') + xValor)) 
											xValor := GYB->GYB_TIPO
										Endif
										If cCodVenda $ _cKeySub //cCodVenda == 'SSC' .OR. cCodVenda == 'SCC'
											xValor := 'T'
										Endif
									EndIf

									If lPEIntId .AND. cCampo $ "GIC_AGENCI|GIC_LINHA"
										xValorPE := ExecBlock("GTPINTEGID",.F.,.F.,{cCampo,nX,oRJIntegra})
										If ValType(xValorPE) == 'C' .AND. !Empty(xValorPE)
											xValor := xValorPE
										Endif
									Endif
									
									If cCampo == "GIC_BILHET" .AND. lPEIntId .AND. !Empty(cCodePE) .AND. nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, SUBSTR(cCodePE,0,TAMSX3(cCampo)[1]))
									ElseIf nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGIC:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									EndIf

									If !lContinua
										cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
										If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
											GtpGrvLgRj(		STR0008,; //"Bilhetes"
															oRJIntegra:cUrl,;
															oRJIntegra:cPath,;
															cRotina,;
															oRJIntegra:cParam,;
															cErro,;
															Nil,;
															cRefer1)
											aAdd(aError, cErro)
										Endif
									EndIf

								EndIf
							Next nY

							//Pegando dados de requisição DSERGTP-11094
							aRequisicao := {}	
							If lIntReq .AND. (!EMPTY(oRJIntegra:GetJsonValue(nX, "codigoClienteRequisicao1", "C")) .OR.;
											  !EMPTY(oRJIntegra:GetJsonValue(nX, "cnpjRequisicao1", "C")))

								cCode 	 := oMdlGIC:GetValue('GIC_CODIGO')	
								cAgencia := oMdlGIC:GetValue('GIC_AGENCI')														
								cCodReq	 := oRJIntegra:GetJsonValue(nX, "numeroRequisicao1", "C")
								cCliReq	 := oRJIntegra:GetJsonValue(nX, "codigoClienteRequisicao1", "C")
								cCliReq  := IIF(!EMPTY(cCliReq),cCliReq,"******")
								cCliCgc	 := oRJIntegra:GetJsonValue(nX, "cnpjRequisicao1", "C")
								cCliCgc  := IIF(!EMPTY(cCliCgc),cCliCgc,"******")					
								cDesReq  := STR0009 + ALLTRIM(cCodReq) + STR0010 //"Requisição numero" | " realizada por integração";
								cCancBpe := IIF(oRJIntegra:GetJsonValue(nX, "statusBilhete", "C") == "C",oRJIntegra:GetJsonValue(nX, "chbpe", "C"),"")
								
								cCliReq := ValidReqSA1(cCliReq,cCliCgc)
								If !Empty(cCliReq)

									aAdd(aRequisicao, {	cCode,;
														Padr(cCodReq,TamSx3('GQW_CODORI')[1]),; //GQW_CODORI
														cCliReq,; 						//GQW_CODCLI + GQW_CODLOJ
														ALLTRIM(cCliCgc),; 						//CNPJ
														cDesReq,; 								//GQW_REQDES
														cAgencia,; 								//GQW_CODAGE
														oMdlGIC:GetValue('GIC_DTVEND'),;		//GQW_DATEMI
														cCancBpe;								//Bpe cancelado										
														})	
								Else
									lContinua := .F.
									cErro := STR0014 +Chr(10)+Chr(13) //"Falha ao criar requisição. Não há cliente ou parâmetro cadastrado. "
									cErro += STR0015 +oMdlGIC:GetValue('GIC_BILHET') //"Referência: "
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008+'|'+STR0013,; //"Bilhetes|Requisição"
														oRJIntegra:cUrl,;
														oRJIntegra:cPath,;
														cRotina,;
														oRJIntegra:cParam,;
														cErro,;
														Nil,;
														cRefer1)
										aAdd(aError, cErro)
					
									Endif
								EndIf							

							ENDIF
						
							If lContinua
								lContinua := oMdlGIC:SetValue("GIC_INTEGR", '1', .T.)//Integrado					
							EndIf
							If lContinua
								lContinua := oMdlGIC:SetValue("GIC_ORIGEM", '2', .T.)//Eletronica					
							EndIf
							If lContinua
								lContinua := oMdlGIC:SetValue("GIC_CONFER", '2', .T.)//Conferencia
							EndIf
							
							nLenGZP := IIF(lBCA,0,len(aFormPag))
							If nLenGZP > 0 .And. lContinua
								// Para o array de formas de pagamento
								For nFormaPag := 1 to nLenGZP
									lAddLine := .F.
									cItem := Replicate('0', TamSx3('GZP_ITEM')[1] - Len(cValtoChar(nFormaPag))) + RTrim(LTrim(cValtoChar(nFormaPag)))
									If lContinua .And. !oMdlGZP:SeekLine({{'GZP_CODBIL', oMdlGIC:GetValue("GIC_BILHET") },{'GZP_ITEM', cItem }}) .And. nFormaPag > 1
										lAddLine := .T.
										oMdlGZP:addLine(.T.)
									EndIf

									//Campos sem a config no xml
									If lContinua .And. Empty(oMdlGZP:GetValue("GZP_ITEM"))
										lContinua := oMdlGZP:SetValue("GZP_ITEM",cItem)
									Endif
									If lContinua .And. Empty(oMdlGZP:GetValue("GZP_BILREF"))
										lContinua := oMdlGZP:SetValue("GZP_BILREF",oMdlGIC:GetValue("GIC_BILHET"))
									Endif
									If lContinua .And. Empty(oMdlGZP:GetValue("GZP_STAPRO"))
										lContinua := oMdlGZP:SetValue("GZP_STAPRO","0")
									Endif													
									If lContinua .And. Empty(oMdlGZP:GetValue("GZP_DTVEND"))											
										lContinua := oMdlGZP:SetValue("GZP_DTVEND",oMdlGIC:GetValue("GIC_DTVEND"))
									Endif
									If lContinua
										//para os campos da gzp
										For nField := 1 To Len(aFldsGZP)
											xValor      := ""
											cTagName    := aFldsGZP[nField][1]
											cCampo      := aFldsGZP[nField][2]
											cTipoCpo    := aFldsGZP[nField][3]
											lOnlyInsert := aFldsGZP[nField][6]
											lOverWrite  := aFldsGZP[nField][7]

											// verificando a necessidade de realizar o DePara XXF
											If (nPos := aScan(aDPXXFGZP, {|x| x[1] == cCampo})) > 0
												xValor := GTPxRetId("TotalBus", aDPXXFGZP[nPos, 2], aDPXXFGZP[nPos, 3], xValor, @cIntAux, aDPXXFGZP[nPos, 4], @lOk, @cErro, aDPXXFGZP[nPos, 6], aDPXXFGZP[nPos, 5])
											EndIf
											
											If cCampo $ "GZP_TPAGTO"												
												xValor := aFormPag[nFormaPag][1]
											ElseIf cCampo $ "GZP_NSU"
												xValor := aFormPag[nFormaPag][2]
											ElseIf cCampo $ "GZP_DCART"
												xValor := aFormPag[nFormaPag][3]
											ElseIf cCampo $ "GZP_VALOR"
												xValor := aFormPag[nFormaPag][4]
											ElseIf cCampo $ "GZP_QNTPAR"
												xValor := aFormPag[nFormaPag][5]
											ElseIf cCampo $ "GZP_AUT"
												xValor := aFormPag[nFormaPag][6]
											EndIf

											If lAddLine .And. lOnlyInsert .And. Empty(oMdlGZP:GetValue(cCampo))	
												lContinua := oMdlGZP:SetValue(cCampo, xValor)
											ElseIf (lAddLine .And. !lOnlyInsert) .Or. (!lAddLine .And. lOverWrite) 
												lContinua := oMdlGZP:SetValue(cCampo, xValor)
											EndIf

											If !lContinua
												cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
												If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
													GtpGrvLgRj(		STR0008,; //"Bilhetes"
															oRJIntegra:cUrl,;
															oRJIntegra:cPath,;
															cRotina,;
															oRJIntegra:cParam,;
															cErro,;
															Nil,;
															cRefer1)
													aAdd(aError, cErro)
													EXIT
												Endif
											EndIf

										Next nField
									EndIf
								Next nFormaPag
							EndIf

							If lContinua .And. oModel:lModify
								lContinua := oModel:VldData() .And. oModel:CommitData()
								If !lContinua
									cErro := I18N(STR0005, {GTPXErro(oModel),cExtID,cIntId})	//"Falha ao carregar modelos de dados (#1)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008,; //"Bilhetes"
														oRJIntegra:cUrl,;
														oRJIntegra:cPath,;
														cRotina,;
														oRJIntegra:cParam,;
														cErro,;
														Nil,;
														cRefer1)
										aAdd(aError, cErro)
									Endif
								EndIf

								//DSERGTP-11094
								IF lContinua .AND. Len(aRequisicao) > 0 .AND. !GI115Req(aRequisicao, @cErro)									
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008+'|'+STR0013,; //"Bilhetes|Requisição"
														oRJIntegra:cUrl,;
														oRJIntegra:cPath,;
														cRotina,;
														oRJIntegra:cParam,;
														cErro,;
														Nil,;
														cRefer1)
										aAdd(aError, cErro)
									Endif									
								ENDIF

							Endif

							oModel:DeActivate()

					EndIf
				EndIf

			//EndIf
			aSize(aFormPag,0)
		Next nX
	ElseIf lJob
		lMonit := .F.
		lRet := .F.
	Else
		lMonit := .F.	//Precisará efetuar o disarmTransaction
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
	EndIf

Else
	lRet := .F.
	cErro := I18N( STR0006, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(		STR0008,; //"Bilhetes"
					oRJIntegra:cUrl,;
					oRJIntegra:cPath,;
					cRotina,;
					oRJIntegra:cParam,;
					cErro)
EndIf

If !lJob
	If lMessage
		oMessage:SetText(STR0007) // "Processo finalizado."
		ProcessMessages()
	EndIf
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGIC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI115Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	henrique.toyada
@since 		28/03/2019
@version 	1.0
/*/
//GI115Job('10','20200326','0000','20200326','2359','000000','999999')
//------------------------------------------------------------------------------------------
Function GI115Job(aParam, lAuto)
Local nPosEmp := 0
Local nPosFil := 0

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 11, 8, IF(Len(aParam) == 9, 6, 1))
nPosFil := IF(Len(aParam) == 11, 9, IF(Len(aParam) == 9, 7, 2))

If ValType(aParam[2]) == 'C'
	aParam[2] := STOD(aParam[2])
Endif

If ValType(aParam[4]) == 'C'
	aParam[4] := STOD(aParam[4])
Endif

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])
If Len(aParam) == 11
	GI115Receb(.T., Nil, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], aParam[6], aParam[7],,lAuto)
ElseIf Len(aParam) == 9
	GI115Receb(.T., Nil, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5],,,,lAuto)
Else
	GTPIRJ115(.F.,,,lAuto)
EndIf

RpcClearEnv()

Return

Static Function RemoverCaracteresTelefone(cTexto)
Local cResultado := ""
Local nIndex     := 0
Local nTamanho   := Len(cTexto)
Local cCaracter  := SubStr(cTexto, nIndex, 1)
	If nTamanho > 13
		for nIndex := 1 to nTamanho
			cCaracter := SubStr(cTexto, nIndex, 1)
			if cCaracter >= "0" .and. cCaracter <= "9"
				cResultado += cCaracter
			endif
		next
	Else
		cResultado := cTexto
	EndIf
return cResultado

Static Function siglatipopagto(cTipoPagto,cFormaPag)

Local cResultado := ""

	Do Case
		Case cTipoPagto == '0'	//DINHEIRO
			cResultado := "DI"
		Case cTipoPagto == '1'	//DEBITO
			cResultado := "DE"
		Case cTipoPagto == '2'	//CREDITO
			cResultado := "CR"
		Case cTipoPagto == '3'	//NOTA DE CREDITO
			cResultado := "NC"
		Case cTipoPagto == '4'	//TROCA PASSAGEM
			cResultado := "TP"
		Case cTipoPagto == '5'	//IMPRESSAO PASSAGEM
			cResultado := "IM"
		Case cTipoPagto == '6'	//ORDEM SERVIÇO
			cResultado := "OS"
		Case cTipoPagto == '7'	//BOLETO ABERTO
			cResultado := "BA"
		Case cTipoPagto == '8' //PACOTE
			cResultado := "PT"
		Case cTipoPagto == '9'	//RESERVA
			cResultado := "RS"
		Case cTipoPagto == '10' //CHEQUE	
			cResultado := "CH"
		Case cTipoPagto == '11' //DEPOSITO
			cResultado := "DP"
		Case cTipoPagto == '12' .And. cFormaPag <> 'CL'	//CARTEIRA DIGITAL
			cResultado := "CD"
		Case cTipoPagto == '13' //SMART CARD
			cResultado := "SM"
		Case cTipoPagto == '14' //LOGPAY
			cResultado := "LP"
		Case cTipoPagto == '15' //TPI
			cResultado := "TI"
		Case cTipoPagto == '16' //MOBIPIX
			cResultado := "MB"
		Case cTipoPagto == '17' //ADYEN
			cResultado := "AD"
		Case cTipoPagto == '18' //MERCADO PAGO
			cResultado := "MP"
		Case cTipoPagto == '19' //EMBARQUE JÁ
			cResultado := "EJ"
		Case cTipoPagto == '12' .And. cFormaPag == 'CL'	//CIELO LINK
			cResultado := "CL"			
	EndCase

return cResultado

/*/{Protheus.doc} GI115Req
	Manutenção de requisições dos bilhetes

	@type  Static Function
	@author João Pires
	@since 04/07/2024
	@version 1.0
	@param aRequisicao, Array, Array com os dados da requisição
	@return lRet, Logico, Retorna false se ocorrer falha
/*/
Function GI115Req(aRequisicao, cErro)
	Local lRet		:= .F.
	Local oMdlGQW   := Nil 
	Local cCliente  := ""
	Local aArea		:= GetArea()
	Local aAreaGIC  := GIC->(GetArea())
	Local cCancBpe	:= ""
	Local cCodReq	:= ""
	Local lIsActiv  := .F.
	Local cRequisicao := ''
	Default INCLUI  	:= .F.
	Default cErro  		:= ""
	Default aRequisicao := {}

	cErro 	 := ""
	cCliente := aRequisicao[1][3]

	cCancBpe := aRequisicao[1][8]
	
	IF !EMPTY(cCliente)
		oMdlGQW	:= FwLoadModel("GTPA283") 

		DBSelectArea('GQW')
		GQW->(DbSetOrder(5)) //GQW_FILIAL+GQW_CODORI+GQW_CODCLI+GQW_CODLOJ

		cCodReq := POSICIONE('GIC',1,xFilial('GIC') + aRequisicao[1][1],'GIC_CODREQ')
		
		If !Empty(cCancBpe)
			GIC->(DBSetOrder(12)) //GIC_FILIAL+GIC_CHVBPE
			GIC->(DBGoTop())

			If GIC->(DBSeek(xFilial("GIC")+cCancBpe))
				GQW->(DBSetOrder(1)) //GQW_FILIAL+GQW_CODIGO

				If !Empty(GIC->GIC_CODREQ) .AND. GQW->(DBSeek(xFilial("GQW")+GIC->GIC_CODREQ))
				
					oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
					oMdlGQW:Activate()		
					lIsActiv := oMdlGQW:IsActive()

					GIC->(DBSeek(xFilial("GIC")+cCancBpe))

					IF lIsActiv .AND. oMdlGQW:GetModel('GRIDGIC'):Length() <= 1 

						oMdlGQW:DeActivate()
						oMdlGQW:SetOperation(MODEL_OPERATION_DELETE) 
						oMdlGQW:Activate()	

					ELSEIF lIsActiv .AND. oMdlGQW:GetModel('GRIDGIC'):SeekLine({{'GIC_NUMBPE',GIC->GIC_NUMBPE}}) 

						oMdlGQW:GetModel('GRIDGIC'):DeleteLine()   

					ENDIF
				Endif
			Endif

		ElseIf !Empty(cCodReq) .AND. Empty(aRequisicao[1][2]) 
			lIsActiv := .F. //Ignorar Bilhete que já possui requisição

		ElseIF !Empty(aRequisicao[1][2]) .AND. GQW->(DBSeek(xFilial('GQW') + aRequisicao[1][2] + cCliente))
			
			oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
			oMdlGQW:Activate()		
			lIsActiv := oMdlGQW:IsActive()			
		
		ElseIF Empty(aRequisicao[1][2])	// Codigo da requisição em branco
			cRequisicao := GetRequisicao(cCliente, aRequisicao[1][6])

			SA1->(DBSetOrder(1))
			SA1->(DBSeek(xFilial('SA1') + cCliente))			

			If Empty(cRequisicao)
				oMdlGQW:SetOperation(MODEL_OPERATION_INSERT)
			Else 
				GQW->(DbSetOrder(1))
				GQW->(DbSeek(xFilial("GQW")+cRequisicao))
				oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
			EndIf 				
			
			oMdlGQW:Activate()		
			lIsActiv := oMdlGQW:IsActive()	

			IF lIsActiv .And. oMdlGQW:GetOperation() == MODEL_OPERATION_INSERT
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODORI",  aRequisicao[1][2]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_REQDES",  aRequisicao[1][5]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODCLI",  SA1->A1_COD  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODLOJ",  SA1->A1_LOJA )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODAGE",  aRequisicao[1][6]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_DATEMI",  aRequisicao[1][7]  )
			ENDIF

			SA1->(DBCloseArea())			

		ELSE
			DBSelectArea('SA1')
			SA1->(DBSetOrder(1))
			SA1->(DBSeek(xFilial('SA1') + cCliente))

			oMdlGQW:SetOperation(MODEL_OPERATION_INSERT)
			oMdlGQW:Activate()
			lIsActiv := oMdlGQW:IsActive()

			IF lIsActiv
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODORI",  aRequisicao[1][2]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_REQDES",  aRequisicao[1][5]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODCLI",  SA1->A1_COD  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODLOJ",  SA1->A1_LOJA )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODAGE",  aRequisicao[1][6]  )
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_DATEMI",  aRequisicao[1][7]  )
			ENDIF

			SA1->(DBCloseArea())
		ENDIF

		IF lIsActiv .AND. EMPTY(cCancBpe)
			cCodReq := POSICIONE('GIC',1,xFilial('GIC') + aRequisicao[1][1],'GIC_CODREQ') 
			IF !EMPTY(cCodReq) .AND. cCodReq == oMdlGQW:GetModel('FIELDGQW'):GetValue("GQW_CODIGO")
				lRet := .T.
				oMdlGQW:DeActivate()
			ELSE
				oMdlGQW:GetModel('GRIDGIC'):AddLine(.T.)
				oMdlGQW:GetModel('GRIDGIC'):SetValue("GIC_CODIGO",  aRequisicao[1][1]  )
			ENDIF
		ENDIF

		IF lIsActiv .AND. !lRet
			lRet := oMdlGQW:VldData() .And. oMdlGQW:CommitData()

			IF !lRet
				cErro := GTPXErro(oMdlGQW)
			ENDIF			
		ENDIF

		lRet := IIF(!lIsActiv,.T.,lRet)
		
		GTPDestroy(oMdlGQW)
	ELSE	
		cErro := "Cliente "+aRequisicao[1][3]+STR0011+aRequisicao[1][2] //"Cliente" | " sem cadastro ou sem parametro de cliente (contrato) na requisição: "
	ENDIF

	GIC->(DbSetOrder(1))// GIC_FILIAL+GIC_CODIGO

	RestArea(aArea)
	RestArea(aAreaGIC)
Return lRet


/*/{Protheus.doc} GetRequisicao(cCodCliLj)
	Pesquisa REquisição por código de cliente e loja

	@type  Static Function
	@author José Carlos
	@since 01/10/2025
	@version 1.0
	@param 
	@return caracter, código da requisição
/*/
Static Function GetRequisicao(cCodCliLj,cCodAgencia)
	Local cRetorno := ''
	Local aAreaAtu := GetArea()
	Local cAliasQry:= GetNextAlias()

	BeginSql Alias cAliasQry
		Select GQW_CODIGO
		From %table:GQW%
		Where GQW_FILIAL = %xFilial:GQW% and GQW_CODCLI||GQW_CODLOJ = %Exp:cCodCliLj%
		and GQW_CODAGE = %Exp:cCodAgencia%
		and GQW_STATUS = '2'
		and %NotDel%
	EndSql 

	If (cAliasQry)->(!Eof())
		cRetorno := (cAliasQry)->GQW_CODIGO
	EndIF 

	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAtu)
Return cRetorno


/*/{Protheus.doc} ValidReqSA1(cCliente,cCgc)
	Validar o cliente da requisição

	@type  Static Function
	@author João Pires
	@since 22/10/2025
	@version 1.0
	@param 
	@return caracter, código do cliente
/*/
Static Function ValidReqSA1(cCliente,cCgc)
	Local cRetorno 	:= ""
	Local lValLj 	:= GTPGetRules("VALIDLJCLI",,,.F.)
	Local nTamLoj	:= 0
	Local nTamCod	:= 0

	nTamCod  := TamSx3('A1_COD')[1]
	IF lValLj
		nTamLoj := TamSx3('A1_LOJA')[1]
		cCliente := padl(LEFT(cCliente,Len(cCliente)-nTamLoj),nTamCod,'0') + RIGHT(cCliente,nTamLoj)
	ELSE
		cCliente := Padl(cCliente,nTamCod,'0')
	ENDIF 

	cRetorno := POSICIONE('SA1',1,xFilial('SA1') + cCliente,'A1_COD+A1_LOJA')
	cRetorno := IIF(!EMPTY(cRetorno),cRetorno,POSICIONE('SA1',3,xFilial('SA1') + cCgc,'A1_COD+A1_LOJA'))
	cRetorno := IIF(EMPTY(cRetorno),cRetorno,POSICIONE('GQV',1,xFilial('GQV')+cRetorno,'GQV_CODIGO+GQV_CODLOJ'))

Return cRetorno
