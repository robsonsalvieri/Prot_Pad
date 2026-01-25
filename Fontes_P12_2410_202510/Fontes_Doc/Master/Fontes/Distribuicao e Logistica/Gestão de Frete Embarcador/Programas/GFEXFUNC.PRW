#INCLUDE "GFEXFUNC.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
 
#DEFINE _ICMS   1
#DEFINE _PIS    2
#DEFINE _COFINS 3
#DEFINE _VLFRET 4

/* Retorno do Rateio:
	[1] Sucesso Sim/Não
	[2] Última Mensagem gerada
*/

/*----------------------------------------------------------------------------------
Retorna a descrição do tipo de grupo contábil informado nos parâmetros MV_TPGRP[1-7]
----------------------------------------------------------------------------------*/
Function GFEContLab(nGrupo)
	Local cRet := ""
	Local nTpGrupo := SuperGetMv("MV_TPGRP" + ALLTRIM(STR(nGrupo)),,"0")

	/*
	1	Filial do documento de carga
	2	Tipo de Operação do romaneio de carga
	3	Item do documento de carga
	4	Região Comercial do destinatário do documento de carga
	5	Grupo de Cliente do destinatário do documento de carga
	6	Série do documento de carga
	7	Classificação Frete do item do documento de carga
	8	Tipo de Cálculo
	9	Inform. Contábil da nota 1
	10	Inform. Contábil da nota 2
	11	Inform. Contábil da nota 3
	12	Inform. Contábil da nota 4
	13	Inform. Contábil da nota 5
	*/
	
	If Empty(nTpGrupo)
		cRet := "(Não informado)"
		Return (cRet)
	EndIf

	Do Case
		Case nTpGrupo == "1"
   			cRet := STR0029 //"Filial do Documento de Carga"
		Case nTpGrupo == "2"
   			cRet := STR0030 //"Tipo de Operação do romaneio de carga"
		Case nTpGrupo == "3"
   			cRet := STR0031 //"Item do documento de carga"
		Case nTpGrupo == "4"
   			cRet := STR0032 //"Região Comercial do destinatário do documento de carga"
		Case nTpGrupo == "5"
   			cRet := STR0033 //"Grupo de Cliente do destinatário do documento de carga"
		Case nTpGrupo == "6"
   			cRet := STR0034 //"Tipo de Documento de Carga " 
		Case nTpGrupo == "7"
   			cRet := STR0035 //"Classificação Frete do item do documento de carga"
		Case nTpGrupo == "8"
   			cRet := STR0036 //"Tipo de Cálculo"
		Case nTpGrupo == "9"
   			cRet := STR0037 //"Inform. Contábil da nota 1"
		Case nTpGrupo == "10"
   			cRet := STR0038 //"Inform. Contábil da nota 2"
		Case nTpGrupo == "11"
   			cRet := STR0039 //"Inform. Contábil da nota 3"
		Case nTpGrupo == "12"
   			cRet := STR0040 //"Inform. Contábil da nota 4"
		Case nTpGrupo == "13"
   			cRet := STR0041 //"Inform. Contábil da nota 5"
		Case nTpGrupo == "14"
   			cRet := STR0042 + ALLTRIM(STR(nGrupo)) //"Grupo "
   		Case nTpGrupo == "15"
   			cRet := "Unidade de negócio do item do documento de carga"
   		OtherWise
   			cRet := "CFOP do item do documento de carga"
	EndCase
Return cRet

Static Function GFEInitLog(cRef)
	If SuperGetMv("MV_LOGCONT", , "1") == "1"
		lSaveLogC := .T.
	Else
		lSaveLogC := .F.
	EndIf

	// O parâmetro de geração do log da contabilização, é sobreposta se for chamada pelo programa GFEA088
	If IsInCallStack("GFEA088")
		If Type("lSaveLog") == "L"
			lSaveLogC := lSaveLog
		EndIf
	EndIf
	
	If Empty(SuperGetMv("MV_DRTLOG",,""))
		cArquivoLog := STR0043 + "_" + cRef + "_" + Dtos(Date()) + "_" + StrTran(Time(),":","") + ".LOG" //"RateioContabil"
	Else
		cArquivoLog := SuperGetMv("MV_DRTLOG",,"") + "\" + STR0043 + "_" + cRef + "_" + Dtos(Date()) + "_" + StrTran(Time(),":","") + ".LOG" //"RateioContabil"
	EndIf
	
	cLogCont = Replicate("-", 100) + CRLF
	cLogCont += "Log de rateio e contabilização - " + DtoC(Date()) + " - " + Time() + CRLF
	cLogCont += Replicate("-", 100) + CRLF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFERatLog
Adiciona uma mensagem de log na variável privada cLog

@param  cMsg  	Mensagem

@author Israel A Possoli
@since 29/11/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFERatLog(cMsg, lPulaLinha)

	Default lPulaLinha := .F.

	If lSaveLogC
		cMsg := Replace(cMsg, CRLF, CRLF + "[" + Time() + "] ")
	
		If lPulaLinha
			cLogCont += "[" + Time() + "] " + CRLF
		EndIf
		
		If Len(cMsg) + Len(cLogCont) > 1000000
			GFESaveLog()
		EndIf
		
		cLogCont += "[" + Time() + "] " + cMsg + CRLF
	EndIf

Return

/*----------------------------------------------------------------------------
{Protheus.doc} SaveLog
Salva o log em um arquivo texto
Uso: SaveLog

@sample SaveLog()

@author Luciano de Araujo
@since 25/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Static Function GFESaveLog(lEnd)
	Local nHandle := 0
	Default lEnd := .F.
	//
	// Utiliza escopo do GFEXFUNB para verificar se deve ou não salvar memória/log do cálculo
	//
	If lSaveLogC
	
		If lEnd
			cLogCont = Replicate("-", 100)
			cLogCont += CRLF + "Fim do Log de rateio e contabilização - " + DtoC(Date()) + " - " + Time() + CRLF
			cLogCont += Replicate("-", 100)	
		EndIf
	
		if !File(cArquivoLog)  // Arquivo não existe
			// Cria o arquivo de log
			nHandle := FCreate(cArquivoLog,FC_NORMAL)
			FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
		Else	// Arquivo existe
			nHandle := FOpen(cArquivoLog,FO_READWRITE)
			FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
		EndIf
	
		FWrite(nHandle,cLogCont,len(cLogCont)) // Grava o conteudo da variavel no arquivo de log
	
		FClose(nHandle) // Fecha o arquivo de log
		
		cLogCont := "" // "Zera" a variavel	
	EndIf	
	
Return

Static Function SetProcess(cText, nTotal)
	If oProcessC != Nil
		oProcess:SetRegua2(nTotal)
		oProcess:IncRegua2(cText)
	EndIf
Return

Static Function IncProcess(cText)
	Default cText := Nil
	
	If oProcessC != Nil
		oProcess:IncRegua2(cText)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFERatCal
Gera o Rateio por Cálculo

@param  lBatch  	Se é geração Batch
@param  nrCalc   	Número do Cálculo

@sample
	GFERatCal(.F., 1)


@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFERatCal(lBatch, nrCalc, oProc, cFilCalc)
	Local lRet := .T.	// Retorno da função
	Local aRet			// Retorno do rateio [1] Sucesso?, [2] Mensagem de erro
	Local cMensagem  := ""  // Última mensagem de aviso/erro
	Local aAreaGWF   := GWF->( GetArea() )
	
	Default cFilCalc := xFilial("GWF")
	Default oProc    := Nil
	
	Private lSaveLogC := .T.
	Private cArquivoLog
	Private cLogCont := ""	// Log de contabilização
	Private oProcessC := oProc
	Private aRetRateio := {} // Retorno do Rateio
	
	GFEInitLog("Calc_" + AllTrim(nrCalc))

	GFERatLog(STR0058) //"Contabilização por Cálculo de Frete"
	GFERatLog(STR0059 + ": " + nrCalc) //"Cálculo: "
	GFERatLog(STR0048 + if(lBatch,STR0049,STR0050)) //"Forma de execução: " ### "Batch" ### "On-line"
	
	dbSelectArea("GWF")
	dbSetOrder(1)
	If dbSeek(cFilCalc + nrCalc)

		dbSelectArea("GWJ")
		dbSetOrder(1)
	   	If dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRPREF)
		   If GWJ->GWJ_SITFIN == '4'
			   	GFERatLog("Não é possível regerar a grade contábil de pré-faturas já atualizadas no financeiro")
			   	lRet := .F.
			   	cMensagem := "Não é possível regerar a grade contábil de pré-faturas já atualizadas no financeiro"
	  	   EndIf
		EndIf

		If lRet <> .F.
			aRet := GFERateio(lBatch, If(GWF->GWF_TPCALC == "8", "4", "1")) // Quando cálculo de estimativa/provisão, TPDOC = 4
			lRet := aRet[1]
			cMensagem := aRet[2]
		EndIf
	Else
		GFERatLog(STR0060) //"Cálculo de frete não encontrado, cancelando operação."
		lRet := .F.
		cMensagem := STR0060
	EndIf

	RestArea(aAreaGWF)
	GFESaveLog()

	aAdd(aRetRateio, lRet)			// Sucesso Sim/Não
	aAdd(aRetRateio, cMensagem)     // Mensagem de aviso/erro quando a operação foi cancelada
Return aRetRateio

//-------------------------------------------------------------------
/*/{Protheus.doc} GFERatDF
Gera o Rateio por Documento de Frete

@param  lBatch  	Se é geração Batch
@param  cEmisDf   	Emissor do Documento de Frete
@param  cCdEsp   	Espécie do Documento de Frete
@param  cSerDf   	Série do Documento de Frete
@param  cNrDf   	Número do Documento de Frete
@param  cDtEmis   	Data de Emissão do Documento de Frete

@sample
	GFERatDF(.F., "001", "01", "", "00001", 27/01/2010)

@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFERatDF(lBatch, cCdEsp, cEmisDf, cSerDf, cNrDf, dDtEmis, oProc)
 	Local lRet := .T.	// Retorno da função
	Local aRet			// Retorno do rateio [1] Sucesso?, [2] Mensagem de erro
	Local cMensagem	:= ""  // Última mensagem de aviso/erro
	Local aAreaGW3  := GW3->( GetArea() )
	Local lGW3Pos	:= .T. // Verifica se a GW3 está posicionada
	Local lIntDocF  := SuperGetMv('MV_DSCTB',, '1') == "2" .And. SuperGetMv('MV_ERPGFE',, '1') == "1"  .OR. SuperGetMv('MV_ERPGFE',, '1') == "4" //Logix

	Default cCdEsp := Space(5)
	Default cSerDf := Space(5)
	Default oProc := Nil

	Private lSaveLogC := .T.
	Private cArquivoLog
	Private cLogCont := ""	 // Log de contabilização
	Private oProcessC := oProc
	Private aRetRateio := {} // Retorno do Rateio
	
	GFEInitLog("DocFret_" + AllTrim(cNrDf))
	
	GFERatLog(STR0061) //"Contabilização por Documento de Frete"
	GFERatLog(STR0052 + " : "        + AllTrim(cCdEsp)  +; //"Espécie : "
	          ", " + STR0046 + " : " + AllTrim(cEmisDf) +; //"Emissor :"
	          ", " + STR0047 + " : " + AllTrim(cSerDf)  +; //"Série :"
	          ", " + STR0053 + " : " + AllTrim(cNrDf)   +; //"Número :"
	          ", " + STR0062 + " : " + cValToChar(dDtEmis)) //"Data Emissão :"
	GFERatLog(STR0048 + if(lBatch,STR0049,STR0050)) //"Forma de execução: " ### "Batch" ### "On-line"

	//comando para verificar se a tabela GW3 já está posicionada
	If Alias() != "GW3"
		dbSelectArea("GW3")
		dbSetOrder(1)
	EndIf

	//esse trecho foi inserido pois aparentemete o sistema se perde se executa um dbseek no registro que já está posicionado
	If cCdEsp+cEmisDf+cSerDf+cNrDf+DTOS(dDtEmis) != GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)
		lGW3Pos := dbSeek(xFilial("GW3")+cCdEsp+cEmisDf+cSerDf+cNrDf+DTOS(dDtEmis))
	Endif

	// Validações para a Data de Contabilização da fatura
	If lBatch .AND. lGW3Pos
		GFERatLog(Space(3) + STR0063) //"Validando documento de frete"

		GFERatLog(Space(3) + /* STR0064 + */ "Fatura de Frete") //"Data para contabilização: " trocar .ch pela string corrent

		dbSelectArea("GW6")
		dbSetOrder(1)
		If dbSeek(xFilial("GW6") + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)) .Or. dbSeek(xFilial("GW6") + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT)

			If GW6->GW6_SITFIN != "1" .And. GW6->GW6_SITFIN != "3"
				cMensagem := "A Fatura deve estar com situação 'Não atualizada' ou 'Rejeitada' para geração da contabilização."//STR0065
				GFERatLog(cMensagem)
				lRet := .F.
			EndIf

		EndIf
	EndIf

	If lRet
		If lGW3Pos
			aRet := GFERateio(lBatch, "2")
			lRet 	  := aRet[1]
			cMensagem := aRet[2]
		Else
			cMensagem := STR0001 + ALLTRIM(cCdEsp) + ", " + STR0002 + ALLTRIM(cEmisDf) + ", " + STR0003 + ALLTRIM(cSerDf) + ", " + STR0004 + ALLTRIM(cNrDf)
			GFERatLog(STR0069) //"Documento de Frete não encontrado, cancelando operação."
			lRet 	  :=  .F.
	    Endif
	EndIf
	
	If lRet 
		If lIntDocF .And. GW3->GW3_SITFIS == "4" .And. GW3->GW3_ACINT == "1"   
			cMensagem :=  " Com a opção atualizar Fiscal pelo Recebimento, apenas Documentos de Frete não atualizados no Fiscal podem ser recontabilizados."
			GFERatLog(" Com a opção atualizar Fiscal pelo Recebimento, apenas Documentos de Frete não atualizados no Fiscal podem ser recontabilizados.")
			lRet := .F.
		EndIf
	EndIF
	RestArea(aAreaGW3)

	GFESaveLog(.T.)

	aAdd(aRetRateio, lRet)			// Sucesso Sim/Não
	aAdd(aRetRateio, cMensagem)     // Mensagem de aviso/erro quando a operação foi cancelada
Return aRetRateio


//-------------------------------------------------------------------
/*/{Protheus.doc} GFERatCon
Gera o Rateio por Contrato

@param  lBatch  	Se é geração Batch
@param  nNrCont   	Número do Contrato

@sample
	GFERatCon(.F., "001")

@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFERatCon(lBatch, nNrCont)
 	Local lRet := .T.	// Retorno da função
	Local aRet			// Retorno do rateio [1] Sucesso?, [2] Mensagem de erro
	Local aAreaGW2 := GW2->( GetArea() )

	Private lSaveLogC := .T.
	Private cArquivoLog
	Private cLogCont := ""	// Log de contabilização
	Private oProcessC := Nil
	
	GFEInitLog("Contrato_" + AllTrim(nNrCont))

	GFERatLog(STR0070) //"Contabilização por Contrato com Autônomo"
	GFERatLog(STR0053 + " : " + nNrCont) //"Número : "
	GFERatLog(STR0048 + if(lBatch,STR0049,STR0050)) //"Forma de execução: " ### "Batch" ### "On-line"

	dbSelectArea("GW2")
	dbSetOrder(1)

	If dbSeek(xFilial("GW2")+nNrCont)
		aRet := GFERateio(lBatch, "3")
		lRet := aRet[1]
	Else
		lRet :=  .F.
    Endif

	RestArea(aAreaGW2)
	GFESaveLog(.T.)
Return lRet


//-------------------------------------------------------------------

/*/{Protheus.doc} GFERateio
Gerar Rateio Contábil.
Função interna, não deve ser executada. Chamada pelas funções RateioCalc, RateioDoctoFrete ou RateioContrato
Derivada da procedure "gerarRateioContabil" em botr297.p

@param  lBatch  	Se é execução batch
@param  cTpDocto  Tipo do Documento. 1: Cálculo Frete, 2: Documento de Frete, 3: Contrato, 4:Estimativa/Provisão

Retorna um array de duas posições:
	[1] Sucesso ?
	[2] Mensagem de erro

@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//gerarRateioContabil
//-------------------------------------------------------------------
Function GFERateio(lBatch, cTpDocto)
	Local cFil			/* Filial */
	Local cCdEsp	   := "" // Espécie
	Local cIdFederal   := ""	/* Emissor do Documento de Frete */
	Local nNrDoc		/* Número do Documento */
	Local cSerie		/* Série do Documento */
	Local dDtEmiss		/* Data de Emissão */
	Local dDtContab	    /* Data de Contabilização */
	Local nTipoCalc		/* Tipo do Cálculo */

	Local nVlrFrete		:= 0
	Local nVlrICMS		:= 0
	Local nVlrPIS		:= 0
	Local nVlrCOFINS	:= 0
	Local nVlrPedagio	:= 0

	Local nVlrIbsEst	:= 0
	Local nVlrIbsMun	:= 0
	Local nVlrCBS		:= 0

	Local nVlInssTerc   := 0
    Local nVlInssEmp 	:= 0
    Local nVlSestSenat	:= 0
    Local nVlrIRRF		:= 0
    Local nVlrISS       := 0
    Local aArrayPto
    Local aArrayBkp

	Local retTotais[25] 	/*	{retTotais[1]  = Total Peso
							    retTotais[2]  = Peso Cubado
							    retTotais[3]  = Total Valor
							    retTotais[4]  = Total Volume
						    	retTotais[5]  = Total Unidade
						    	retTotais[6]  = Número de Itens
						    	
						    	retTotais[7]  = Total Peso       | Pis e Cofins
							    retTotais[8]  = Peso Cubado		 | Pis e Cofins	
							    retTotais[9]  = Total Valor 	 | Pis e Cofins
							    retTotais[10]  = Total Volume 	 | Pis e Cofins
						    	retTotais[11]  = Total Unidade 	 | Pis e Cofins
						    	retTotais[12]  = Número de Itens | Pis e Cofins
						    	
						    	retTotais[13]  = Valor do Frete}
						    	retTotais[14]  = Valor ICMS
						    	retTotais[15]  = Valor PIS
						    	retTotais[16] = Valor Cofins
						    	retTotais[17] = Valor INSS Autonomo
						    	retTotais[18] = Valor INSS Empresa
						    	retTotais[19] = Valor Sest Senat
						    	retTotais[20] = Valor IRRF
						    	retTotais[21] = Valor ISS
						    	retTotais[22] = Valor Pedágio
						    	retTotais[23] = Valor IBS Estadual
						    	retTotais[24] = Valor IBS Municipal
						    	retTotais[25] = Valor CBS
							*/
	
	Local lCusto := .F.
	Local nI,nY,nZ
	Local aVlrFrete := {}
	Local aVlrPedagio := {}
	Local cAliVlFrete
	Local cQuery
	Local lRatClass := ( AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) $ "1S" .Or. AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) == ".T." )
	Local lRatDCFrt := lRatClass .And. GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	Local cCdclfr := ""
	Local nTipoServ := ""
	Local lLotProv := .F.
	Local cBanco	:= TCGetDB()

	Private aRetRateio[2]
    Private cTransp
    Private nCountGW1 := 0

    aRetRateio[1]	:= .T.
    aRetRateio[2]	:= ""

	If Type("cAliDcCarg") == "U" .Or. Select(cAliDcCarg) == 0
		XFUNCTAB() //Criação da tabela temporária
		lApaga := .T.
	Else		
		GFEDelTbData(cAliDcCarg) //Deleção da tabela temporária		
		lApaga := .F.
	EndIf
	
	SetProcess("Buscando documentos de carga (1/3)", 0)

	Do Case
		/* Calculo - GWF */
		Case cTpDocto == "1" .OR. cTpDocto == "4"

			cFil 	    := GWF->GWF_FILIAL
			cIdFederal	:= GWF->GWF_TRANSP
			nNrDoc		:= GWF->GWF_NRCALC
			cTransp     := Posicione("GU3",1,xFilial("GU3")+GWF->GWF_TRANSP,"GU3_AUTON")
			cSerie		:= Space(5)
			If GFXCP12117("GWF_CDTPSE") == .T.
				nTipoServ := GWF->GWF_CDTPSE
			EndIf
			
			//Verifica se o cálculo já está em um lote de provisão.
			GXD->(dbSetOrder(02))
			If GXD->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
				While !(GXD->(EoF())) .And. GXD->GXD_FILIAL == GWF->GWF_FILIAL .And. GXD->GXD_NRCALC == GWF->GWF_NRCALC
					If GXE->(dbSeek(GXD->(GXD_FILIAL+GXD_CODLOT))) .And. GXE->GXE_SIT != "6"
						lLotProv := .T.
					EndIf

					GXD->(dbSkip())
				EndDo
			EndIf

			GFERatLog(STR0073, .T.) //"Data para provisão: Criação do Cálculo de Frete"
			dDtEmiss := GWF->GWF_DTCRIA

			dDtContab 	:= GWF->GWF_DTCRIA
			nTipoCalc  := GWF->GWF_TPCALC

			GFERatLog(STR0074, .T.) //"1. Obtendo valores"

			dbSelectArea("GWI")
			dbSetOrder(1)
			dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC)

			nVlrFrete 	  := 0
			nVlrPedagio   := 0

			GFERatLog(Space(3) + STR0075, .T.) //"Buscando Componentes do Cálculo"

			While !Eof() .AND. GWI->GWI_FILIAL == GWF->GWF_FILIAL .AND. GWI->GWI_NRCALC == GWF->GWF_NRCALC
				dbSelectArea("GV2")
				dbSetOrder(1)
				dbSeek(xFilial("GV2")+GWI->GWI_CDCOMP)

				GFERatLog(Space(3) + "> " + GWI->GWI_CDCOMP + " : " + cValToChar(GWI->GWI_VLFRET))

				/* Valor Total do Frete */
				If GWI->GWI_TOTFRE == "1"

					If lRatClass
						cCdclfr := GWI->GWI_CDCLFR
						If Empty(GWI->GWI_CDCLFR)
							lRatClass := .F.
						EndIf
					EndIf

					nI := aScan(aVlrFrete,{|x| x[1] == cCdclfr})

					If nI == 0
						aAdd(aVlrFrete,{cCdclfr,0})
						nI := Len(aVlrFrete)
					EndIf

					aVlrFrete[nI,2] += GWI->GWI_VLFRET
					nVlrFrete += GWI->GWI_VLFRET
				EndIf

				/* Pedágio */
				If GV2->GV2_CATVAL == "4"
					
					If lRatClass
						cCdclfr := GWI->GWI_CDCLFR
						If Empty(GWI->GWI_CDCLFR)
							lRatClass := .F.
						EndIf
					EndIf

					nI := aScan(aVlrPedagio,{|x| x[1] == cCdclfr})

					If nI == 0
						aAdd(aVlrPedagio,{cCdclfr,0})
						nI := Len(aVlrPedagio)
					EndIf

					aVlrPedagio[nI,2] += GWI->GWI_VLFRET
					nVlrPedagio += GWI->GWI_VLFRET
				EndIf

				GWI->(DbSkip())
			EndDo
			
			For nI := 1 To Len(aVlrFrete)
				aVlrFrete[nI,2] +=  ( aVlrFrete[nI,2] / nVlrFrete ) * GWF->GWF_VLAJUS 
			Next nI

            nVlrFrete  += GWF->GWF_VLAJUS 
			nVlrICMS   := GWF->GWF_VLICMS
			nVlrISS    := GWF->GWF_VLISS
			nVlrPIS    := GWF->GWF_VLPIS
			nVlrCOFINS := GWF->GWF_VLCOFI

			nVlrIbsEst := Iif(GFXCP2510("GWF_VLRIBS") .And. Alltrim(GWF->GWF_IMPOST) $ "1;3", GWF->GWF_VLRIBS, 0)
			nVlrIbsMun := Iif(GFXCP2510("GWF_VLRIBS") .And. Alltrim(GWF->GWF_IMPOST) $ "2;3", GWF->GWF_VLRIBS, 0)
			nVlrCBS	   := Iif(GFXCP2510("GWF_VLRCBS"), GWF->GWF_VLRCBS, 0)

			GFERatLog(Space(3) + STR0076, .T.) //"Buscando Documento de Carga do Cálculo"
			dbSelectArea("GWH")
			dbSetOrder(1)
			dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC)
			While !Eof() .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
				nCountGW1++

				GFERatLog(Space(3) + ;
				          "> " + STR0077 + ": " + ALLTRIM(GWH->GWH_CDTPDC) + ; //"Tipo Doc:"
				          ", " + STR0046 + ": " + ALLTRIM(GWH->GWH_EMISDC) + ; //"Emissor:"
				          ", " + STR0047 + ": " + Transform(GWH->GWH_SERDC, "!!!")  + ; //"Serie:"
				          ", " + STR0053 + ": " + ALLTRIM(GWH->GWH_NRDC))      //"Número:"

				RecLock((cAliDcCarg),.T.)
				(cAliDcCarg)->FILIAL := GWH->GWH_FILIAL
				(cAliDcCarg)->CDTPDC := GWH->GWH_CDTPDC
				(cAliDcCarg)->EMISDC := GWH->GWH_EMISDC
				(cAliDcCarg)->SERDC  := GWH->GWH_SERDC
				(cAliDcCarg)->CDESP  := ""
				(cAliDcCarg)->NRDC   := GWH->GWH_NRDC
				MsUnLock(cAliDcCarg)
				dbSelectArea("GWH")
                dbSkip()
			EndDo

		/* Docto Frete  */
		Case cTpDocto == "2"
    		cFil   		:= GW3->GW3_FILIAL
    		cCdEsp		:= GW3->GW3_CDESP
    		cIdFederal	:= GW3->GW3_EMISDF
    		nNrDoc 		:= GW3->GW3_NRDF
    		cSerie      := GW3->GW3_SERDF
    		dDtEmiss    := GW3->GW3_DTEMIS
    		If GFXCP12117("GW3_CDTPSE") == .T.
    			nTipoServ := GW3->GW3_CDTPSE
    		EndIf
    		If lRatDCFrt
	    		cQuery := "SELECT GWI_CDCLFR, SUM(GWI_VLFRET) GWI_VLFRET FROM " + RetSqlName("GWI") + " GWI, " + RetSqlName("GWF") + " GWF " +;
	    										"WHERE GWI.D_E_L_E_T_ = ' ' AND GWF.D_E_L_E_T_ = ' ' AND GWI_FILIAL = '" + xFilial("GWI") + "'" +;
	    										" AND GWI_NRCALC = GWF_NRCALC AND GWI_TOTFRE = '1'"
	    		cQuery += "    AND GWF_CDESP  = '" + GW3->GW3_CDESP  + "'"
				cQuery += "    AND GWF_EMISDF = '" + GW3->GW3_EMISDF + "'"
				cQuery += "    AND GWF_SERDF  = '" + GW3->GW3_SERDF  + "'"
				cQuery += "    AND GWF_NRDF   = '" + GW3->GW3_NRDF   + "'"
				cQuery += "    AND GWF_DTEMDF = '" + DtoS(GW3->GW3_DTEMIS) + "'"
				cQuery += "    GROUP BY GWI_CDCLFR "
	    		cAliVlFrete := MpSysOpenQuery(ChangeQuery(cQuery),,{{"GWI_VLFRET","N",TamSx3("GWI_VLFRET")[1],TamSx3("GWI_VLFRET")[2]}})
				nVlrFrete := 0
	
				While !(cAliVlFrete)->(Eof())
					aAdd(aVlrFrete,{(cAliVlFrete)->GWI_CDCLFR,(cAliVlFrete)->GWI_VLFRET})
					nVlrFrete += (cAliVlFrete)->GWI_VLFRET
					If Empty((cAliVlFrete)->GWI_CDCLFR)
						lRatClass := .F.
					EndIf
					(cAliVlFrete)->(dbSkip())
				EndDo
				(cAliVlFrete)->(dbCloseArea())
				
				If Len(aVlrFrete) == 0 //Não há calculo/classificação relacionada
					aAdd(aVlrFrete,{"",GW3->GW3_VLDF})
					lRatClass := .F.
				Else
					// Rateio do valor baseado nas classificações dos componentes
					For nI := 1 To Len(aVlrFrete)
						aVlrFrete[nI,2] := (aVlrFrete[nI,2] / nVlrFrete) * GW3->GW3_VLDF
					Next nI
				EndIf	
	    		
	    		cQuery := "SELECT GWI_CDCLFR, SUM(GWI_VLFRET) GWI_VLFRET FROM " + RetSqlName("GWI") + " GWI, " + RetSqlName("GWF") + " GWF, " + RetSqlName("GV2") + " GV2 " +;
	    										"WHERE GWI.D_E_L_E_T_ = ' ' AND GWF.D_E_L_E_T_ = ' ' AND GV2.D_E_L_E_T_ = ' '" +;
	    										" AND GWI_FILIAL = '" + xFilial("GWI") + "' AND GWF_FILIAL = '" + xFilial("GWF") + "' AND GV2_FILIAL = '" + xFilial("GV2") + "'" +;
	    										" AND GWI_NRCALC = GWF_NRCALC AND GWI_CDCOMP = GV2_CDCOMP AND GV2_CATVAL = '4' "
	    		cQuery += "    AND GWF_CDESP  = '" + GW3->GW3_CDESP  + "'"
				cQuery += "    AND GWF_EMISDF = '" + GW3->GW3_EMISDF + "'"
				cQuery += "    AND GWF_SERDF  = '" + GW3->GW3_SERDF  + "'"
				cQuery += "    AND GWF_NRDF   = '" + GW3->GW3_NRDF   + "'"
				cQuery += "    AND GWF_DTEMDF = '" + DtoS(GW3->GW3_DTEMIS) + "'"
				cQuery += "    GROUP BY GWI_CDCLFR "
	    		cAliVlFrete := MpSysOpenQuery(ChangeQuery(cQuery),,{{"GWI_VLFRET","N",TamSx3("GWI_VLFRET")[1],TamSx3("GWI_VLFRET")[2]}})
				
				nVlrPedagio := 0
	
				While !(cAliVlFrete)->(Eof())
					aAdd(aVlrPedagio,{(cAliVlFrete)->GWI_CDCLFR,(cAliVlFrete)->GWI_VLFRET})
					nVlrPedagio += (cAliVlFrete)->GWI_VLFRET
					If Empty((cAliVlFrete)->GWI_CDCLFR)
						lRatClass := .F.
					EndIf
					(cAliVlFrete)->(dbSkip())
				EndDo
				(cAliVlFrete)->(dbCloseArea())
				
				If aVlrFrete[1,1] == "" // Não existe cálculo
					aAdd(aVlrPedagio,{"",GW3->GW3_PEDAG})
				Else
					If Len(aVlrPedagio) == 0
						nY := Len(aVlrFrete) // Rateia o pedágio entre as classificações por quantidade
						For nI := 1 To nY
							aAdd(aVlrPedagio,{aVlrFrete[nI,1], GW3->GW3_PEDAG / nY }) // Rateia o pedagio pela quantidade
						Next nI
					Else
						// Rateio do valor baseado nas classificações dos componentes
						For nI := 1 To Len(aVlrPedagio)
							aVlrPedagio[nI,2] := (aVlrPedagio[nI,2] / nVlrPedagio) * GW3->GW3_PEDAG
						Next nI
					EndIf
				EndIf
			Else
				aAdd(aVlrFrete,{"",GW3->GW3_VLDF})
				aAdd(aVlrPedagio,{"",GW3->GW3_PEDAG})
				lRatClass := .F.
			EndIf
			nVlrFrete   := GW3->GW3_VLDF
			nVlrPedagio := GW3->GW3_PEDAG
    	
    		nTipoCalc   := GW3->GW3_TPDF
  			nVlrPIS     := GW3->GW3_VLPIS
            nVlrCOFINS  := GW3->GW3_VLCOF
			nVlrCBS 	:= Iif(GFXCP2510("GW3_VLCBS"), GW3->GW3_VLCBS, 0)

            If Posicione("GVT",1,xFilial("GVT")+cCdEsp,"GVT_TPIMP") == "1" // ICMS
	            nVlrICMS 	:= GW3->GW3_VLIMP
	            nVlrISS  	:= 0
				nVlrIbsEst	:= Iif(GFXCP2510("GW3_VLIBS"), GW3->GW3_VLIBS, 0)
				nVlrIbsMun 	:= 0
	    	Else
	            nVlrICMS 	:= 0
	            nVlrISS  	:= GW3->GW3_VLIMP
				nVlrIbsEst	:= 0 
				nVlrIbsMun 	:= Iif(GFXCP2510("GW3_VLIBS"), GW3->GW3_VLIBS, 0)
	     	EndIf

            GFERatLog(Space(3) + STR0078, .T.) //"Buscando Documento de Carga do Documento de Frete"

			dbSelectArea("GW4") /*Acessa Tabela Documento de Carga por Documento de Frete*/
    		dbSetOrder(1)
    		dbSeek(GW3->GW3_FILIAL+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
    		While !Eof() .AND. GW3->GW3_FILIAL == GW4->GW4_FILIAL ;
						 .AND. GW3->GW3_EMISDF == GW4->GW4_EMISDF ;
						 .AND. GW3->GW3_CDESP == GW4->GW4_CDESP ;
						 .AND. GW3->GW3_SERDF == GW4->GW4_SERDF ;
						 .AND. GW3->GW3_NRDF == GW4->GW4_NRDF ;
						 .AND. GW3->GW3_DTEMIS == GW4->GW4_DTEMIS
    			
    			nCountGW1++

				GFERatLog(Space(3) + ;
						  "> " + STR0077 + ": " + ALLTRIM(GW4->GW4_TPDC) + ;   //"Tipo Doc:"
						  ", " + STR0046 + ": " + ALLTRIM(GW4->GW4_EMISDC) + ; //"Emissor:"
						  ", " + STR0047 + ": " + Transform(GW4->GW4_SERDC,"!!!")  + ; //"Serie:"
						  ", " + STR0053 + ": " + ALLTRIM(GW4->GW4_NRDC))      //"Número:"

				If !lCusto
					lCusto := (Posicione("GV5", 1, xFilial("GV5") + GW4->GW4_TPDC, "GV5_FRCTB") == "2")
				EndIf

            	RecLock((cAliDcCarg),.T.)
                (cAliDcCarg)->FILIAL := GW4->GW4_FILIAL
                (cAliDcCarg)->CDTPDC := GW4->GW4_TPDC
                (cAliDcCarg)->EMISDC := GW4->GW4_EMISDC
                (cAliDcCarg)->SERDC  := GW4->GW4_SERDC
				(cAliDcCarg)->CDESP  := GW4->GW4_CDESP
                (cAliDcCarg)->NRDC   := GW4->GW4_NRDC
				MsUnLock(cAliDcCarg)

                dbSelectArea("GW4")
                dbSkip()
    		EndDo
   			

		/* Contrato  */
		Case cTpDocto == "3"
			cFil         := GW2->GW2_FILIAL
			cIdFederal	 := GW2->GW2_CDPROP
	  		nNrDoc 		 := GW2->GW2_NRCONT
	        dDtEmiss     := GW2->GW2_DTCRIA
	        If lRatClass
		        cQuery := "SELECT GWI_CDCLFR, SUM(GWI_VLFRET) GWI_VLFRET"
		        cQuery += " FROM " + RetSqlName("GWI") + " GWI, " + RetSqlName("GWF") + " GWF"
		        cQuery += " WHERE GWI.D_E_L_E_T_ = ' ' AND GWF.D_E_L_E_T_ = ' '"
		        cQuery += " AND GWF_FILIAL = '" + GW2->GW2_FILIAL + "'"
	    		cQuery += " AND GWF_NRCONT = '" + GW2->GW2_NRCONT  + "'"
		        cQuery += " AND GWI_FILIAL = GWF_FILIAL"
		        cQuery += " AND GWI_NRCALC = GWF_NRCALC"
		        cQuery += " AND GWI_TOTFRE = '1'"
				cQuery += " GROUP BY GWI_CDCLFR "
	    		cAliVlFrete := MpSysOpenQuery(ChangeQuery(cQuery),,{{"GWI_VLFRET","N",TamSx3("GWI_VLFRET")[1],TamSx3("GWI_VLFRET")[2]}})
				nVlrFrete := 0
	
				While !(cAliVlFrete)->(Eof())
					aAdd(aVlrFrete,{(cAliVlFrete)->GWI_CDCLFR,(cAliVlFrete)->GWI_VLFRET})
					nVlrFrete += (cAliVlFrete)->GWI_VLFRET
					If Empty((cAliVlFrete)->GWI_CDCLFR)
						lRatClass := .F.
					EndIf
					(cAliVlFrete)->(dbSkip())
				EndDo
				(cAliVlFrete)->(dbCloseArea())
				
				If Len(aVlrFrete) == 0 //Não há calculo/classificação relacionada
					aAdd(aVlrFrete,{"",GW2->GW2_VLFRET + GW2->GW2_VLADIC})
					lRatClass := .F.
				Else
					// Rateio do valor baseado nas classificações dos componentes
					For nI := 1 To Len(aVlrFrete)
						aVlrFrete[nI,2] := (aVlrFrete[nI,2] / nVlrFrete) * (GW2->GW2_VLFRET + GW2->GW2_VLADIC)
					Next nI
				EndIf	
		    Else
				aAdd(aVlrFrete,{"",GW2->GW2_VLFRET + GW2->GW2_VLADIC})
			EndIf
			nVlrFrete    := GW2->GW2_VLFRET + GW2->GW2_VLADIC
	        
	        nVlInssTerc  := GW2->GW2_VLINSS
	        nVlInssEmp   := GW2->GW2_VLINEM
            nVlSestSenat := GW2->GW2_VLSEST
            nVlrIRRF     := GW2->GW2_VLIRRF
            nVlrISS      := GW2->GW2_VLISS
            cTransp      := "2"

			GFERatLog(Space(3) + STR0079, .T.) //"Buscando Documento de Carga relacionado ao Contrato com Autonomo"

			dbSelectArea("GWF")  /*Acessa Tabela de Calculo de Frete*/
			dbSetOrder(2)
			dbSeek(xFilial("GWF")+GW2->GW2_NRCONT)
			While !Eof() .And. xFilial("GWF") == GWF->GWF_FILIAL .And. GWF->GWF_NRCONT == GW2->GW2_NRCONT
				dbSelectArea("GWH")
				dbSetOrder(1)
				dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC)
				While !Eof() .And. GWF->GWF_FILIAL == GWH->GWH_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
					dbSelectArea("GW1")
					dbSetOrder(1)
					If dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
						
						nCountGW1++
						
  						GFERatLog(Space(3) + ;
						  		  "> " + STR0077 + ": " + ALLTRIM(GW1->GW1_CDTPDC) + ; //"Tipo Doc:"
								  ", " + STR0046 + ": " + ALLTRIM(GW1->GW1_EMISDC) + ; //"Emissor:"
								  ", " + STR0047 + ": " + Transform(GW1->GW1_SERDC,"!!!")  + ; //"Serie:"
								  ", " + STR0053 + ": " + ALLTRIM(GW1->GW1_NRDC))      //"Número:"

						If !lCusto
							lCusto := (Posicione("GV5", 1, xFilial("GV5") + GW1->GW1_CDTPDC, "GV5_FRCTB") == "2")
						EndIf
						
						dbSelectArea(cAliDcCarg)
						dbSetOrder(1)
						If !dbSeek(GW1->GW1_FILIAL + GW1->GW1_EMISDC + GW1->GW1_CDTPDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
	      					RecLock((cAliDcCarg),.T.)
				       		(cAliDcCarg)->FILIAL := GW1->GW1_FILIAL
				       		(cAliDcCarg)->CDTPDC := GW1->GW1_CDTPDC
				        	(cAliDcCarg)->EMISDC := GW1->GW1_EMISDC
				        	(cAliDcCarg)->SERDC  := GW1->GW1_SERDC
				        	(cAliDcCarg)->CDESP  := ""
				        	(cAliDcCarg)->NRDC   := GW1->GW1_NRDC
				        	MsUnLock(cAliDcCarg)
				        EndIf
	        		Endif
	        		dbSelectArea("GWH")
	        		dbSkip()
	        	EndDo
				dbselectArea("GWF")
				dbSkip()
			EndDo


		Otherwise
			Help( ,, 'HELP',, STR0006 + AllTrim(cTpDocto), 1, 0) //"Tipo de Documento inválido "
	EndCase

	/* Relação dos valores do vetor retTotais
	retTotais[1] = Total Peso
	retTotais[2] = Peso Cubado
	retTotais[3] = Total Valor
	retTotais[4] = Total Volume
	retTotais[5] = Total Unidade
	retTotais[6] = Número de Itens
	
	retTotais[7]  = Total Peso       | Pis e Cofins
    retTotais[8]  = Peso Cubado		 | Pis e Cofins	
    retTotais[9]  = Total Valor 	 | Pis e Cofins
    retTotais[10]  = Total Volume 	 | Pis e Cofins
	retTotais[11]  = Total Unidade 	 | Pis e Cofins
	retTotais[12]  = Número de Itens | Pis e Cofins
	
	retTotais[13] = Valor do Frete
	retTotais[14] = Valor ICMS
	retTotais[15] = Valor PIS
	retTotais[16] = Valor Cofins
	retTotais[17] = Valor INSS Autonomo
	retTotais[18] = Valor INSS Empresa
	retTotais[19] = Valor Sest Senat
	retTotais[20] = Valor IRRF
	retTotais[21] = Valor ISS
	retTotais[22] = nVlrPedagio
	retTotais[23] = Valor IBS Estadual
	retTotais[24] = Valor IBS Municipal
	retTotais[25] = Valor CBS
	*/

	If lRatClass .And. Len(aVlrFrete) == 1
		lRatClass := .F.
	EndIf

	retTotais  := GFECaToRa(cAliDcCarg,lRatClass) // Retorna valores de ID 1 a 12
	// Ponto de Entrada NESTLE
	If  ExistBlock("GFEXFC01")
		aArrayPto := Array(22)
		aArrayPto[1]  := 0
		aArrayPto[2]  := 0
		aArrayPto[3]  := 0
		aArrayPto[4]  := 0
		aArrayPto[5]  := 0
		aArrayPto[6]  := 0
		aArrayPto[7]  := 0
		aArrayPto[8]  := 0
		aArrayPto[9]  := 0
		aArrayPto[10] := 0
		aArrayPto[11] := 0
		aArrayPto[12] := 0
		For nI := 1 To Len(retTotais)
			aArrayPto[1]  += retTotais[nI,2,1] 
			aArrayPto[2]  += retTotais[nI,2,2] 
			aArrayPto[3]  += retTotais[nI,2,3] 
			aArrayPto[4]  += retTotais[nI,2,4] 
			aArrayPto[5]  += retTotais[nI,2,5] 
			aArrayPto[6]  += retTotais[nI,2,6] 
			aArrayPto[7]  += retTotais[nI,2,7] 
			aArrayPto[8]  += retTotais[nI,2,8] 
			aArrayPto[9]  += retTotais[nI,2,9] 
			aArrayPto[10] += retTotais[nI,2,10]
			aArrayPto[11] += retTotais[nI,2,11]
			aArrayPto[12] += retTotais[nI,2,12]
		Next nI
		aArrayBkp := aClone(aArrayPto)
		aArrayPto :=  ExecBlock("GFEXFC01",.F.,.F.,{cAliDcCarg, cTpDocto, aArrayPto})
		//Atualizando retorno
		For nI := 1 To Len(retTotais)
			retTotais[nI,2,1]  := ( aArrayPto[1]  / aArrayBkp[1] ) * retTotais[nI,2,1] 
			retTotais[nI,2,2]  := ( aArrayPto[2]  / aArrayBkp[2] ) * retTotais[nI,2,2] 
			retTotais[nI,2,3]  := ( aArrayPto[3]  / aArrayBkp[3] ) * retTotais[nI,2,3] 
			retTotais[nI,2,4]  := ( aArrayPto[4]  / aArrayBkp[4] ) * retTotais[nI,2,4] 
			retTotais[nI,2,5]  := ( aArrayPto[5]  / aArrayBkp[5] ) * retTotais[nI,2,5] 
			retTotais[nI,2,6]  := ( aArrayPto[6]  / aArrayBkp[6] ) * retTotais[nI,2,6] 
			retTotais[nI,2,7]  := ( aArrayPto[7]  / aArrayBkp[7] ) * retTotais[nI,2,7] 
			retTotais[nI,2,8]  := ( aArrayPto[8]  / aArrayBkp[8] ) * retTotais[nI,2,8] 
			retTotais[nI,2,9]  := ( aArrayPto[9]  / aArrayBkp[9] ) * retTotais[nI,2,9] 
			retTotais[nI,2,10] := ( aArrayPto[10] / aArrayBkp[10]) * retTotais[nI,2,10]
			retTotais[nI,2,11] := ( aArrayPto[11] / aArrayBkp[11]) * retTotais[nI,2,11]
			retTotais[nI,2,12] := ( aArrayPto[12] / aArrayBkp[12]) * retTotais[nI,2,12]
		Next nI
	EndIf

	If !lRatClass
		For nI := 1 To Len(aVlrFrete)
			aVlrFrete[nI,1] := ""
		Next nI
		For nI := 1 To Len(aVlrPedagio)
			aVlrPedagio[nI,1] := ""
		Next nI
	EndIf
	
	For nI := 1 To Len(aVlrFrete)
		
		nY := aScan(retTotais,{|x|x[1] == aVlrFrete[nI,1]})
		If nY == 0 //Todos os itens a classificação estão com rateio == 'n'
			nZ := Len(retTotais)
			For nY := 1 To nZ
				retTotais[nY,2,13] += aVlrFrete[nI,2] / nZ
				retTotais[nY,2,14] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrICMS     ) / nZ
				retTotais[nY,2,15] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrPIS      ) / nZ
				retTotais[nY,2,16] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrCOFINS   ) / nZ
				retTotais[nY,2,17] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlInssTerc  ) / nZ
				retTotais[nY,2,18] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlInssEmp   ) / nZ
				retTotais[nY,2,19] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlSestSenat ) / nZ
				retTotais[nY,2,20] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIRRF     ) / nZ
				retTotais[nY,2,21] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrISS      ) / nZ

				retTotais[nY,2,23] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIbsEst   ) / nZ
				retTotais[nY,2,24] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIbsMun   ) / nZ
				retTotais[nY,2,25] += ( ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrCBS      ) / nZ
			Next nY
		Else
			retTotais[nY,2,13] += aVlrFrete[nI,2]
			retTotais[nY,2,14] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrICMS
			retTotais[nY,2,15] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrPIS
			retTotais[nY,2,16] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrCOFINS
			retTotais[nY,2,17] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlInssTerc
			retTotais[nY,2,18] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlInssEmp
			retTotais[nY,2,19] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlSestSenat
			retTotais[nY,2,20] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIRRF
			retTotais[nY,2,21] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrISS

			retTotais[nY,2,23] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIbsEst
			retTotais[nY,2,24] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrIbsMun
			retTotais[nY,2,25] += ( aVlrFrete[nI,2] / nVlrFrete ) * nVlrCBS
		EndIf
		
	Next nI
	
	For nI := 1 To Len(aVlrPedagio)
		
		nY := aScan(retTotais,{|x|x[1] == aVlrPedagio[nI,1]})
		If nY == 0 //Todos os itens a classificação estão com rateio == 'n'
			nZ := Len(retTotais)
			For nY := 1 To nZ
				retTotais[nY,2,22] += aVlrPedagio[nI,2] / nZ	
			Next nY
		Else
			retTotais[nY,2,22] += aVlrPedagio[nI,2]
		EndIf
		
	Next nI
	
	aVlrFrete := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} // Somatória das quantidades
	
	For nI := 1 To Len(retTotais)
		aVlrFrete[1]  += retTotais[nI,2,1]
		aVlrFrete[2]  += retTotais[nI,2,2]
		aVlrFrete[3]  += retTotais[nI,2,3]
		aVlrFrete[4]  += retTotais[nI,2,4]
		aVlrFrete[5]  += retTotais[nI,2,5]
		aVlrFrete[6]  += retTotais[nI,2,6]
		aVlrFrete[7]  += retTotais[nI,2,7]
		aVlrFrete[8]  += retTotais[nI,2,8] 
		aVlrFrete[9]  += retTotais[nI,2,9] 
		aVlrFrete[10] += retTotais[nI,2,10]
		aVlrFrete[11] += retTotais[nI,2,11]
		aVlrFrete[12] += retTotais[nI,2,12]
		aVlrFrete[13] += retTotais[nI,2,13]
		aVlrFrete[14] += retTotais[nI,2,14]
		aVlrFrete[15] += retTotais[nI,2,15]
		aVlrFrete[16] += retTotais[nI,2,16]
		aVlrFrete[17] += retTotais[nI,2,17]
		aVlrFrete[18] += retTotais[nI,2,18]
		aVlrFrete[19] += retTotais[nI,2,19]
		aVlrFrete[20] += retTotais[nI,2,20]
		aVlrFrete[21] += retTotais[nI,2,21]
		aVlrFrete[22] += retTotais[nI,2,22]
		aVlrFrete[23] += retTotais[nI,2,23]
		aVlrFrete[24] += retTotais[nI,2,24]
		aVlrFrete[25] += retTotais[nI,2,25]
	Next nI
	
	GFERatLog(Space(3) + STR0080, .T.) //"Totais obtidos:"
	GFERatLog(Space(3) + "> " + STR0081 + ALLTRIM(STR(aVlrFrete[1]))) //"Peso Real.....: "
	GFERatLog(Space(3) + "> " + STR0082 + ALLTRIM(STR(aVlrFrete[2]))) //"Peso Cubado...: "
	GFERatLog(Space(3) + "> " + STR0083 + ALLTRIM(STR(aVlrFrete[3]))) //"Valor Merc....: "
	GFERatLog(Space(3) + "> " + STR0084 + ALLTRIM(STR(aVlrFrete[4]))) //"Volume........: "
	GFERatLog(Space(3) + "> " + STR0085 + ALLTRIM(STR(aVlrFrete[5]))) //"Qtde Itens....: "
	GFERatLog(Space(3) + "> " + STR0086 + ALLTRIM(STR(aVlrFrete[6]))) //"Núm. de Itens.: "
	GFERatLog(Space(3) + "> " + STR0087 + ALLTRIM(STR(nVlrFrete)))    //"Frete.........: "
	GFERatLog(Space(3) + "> " + STR0088 + ALLTRIM(STR(nVlrICMS)))     //"ICMS..........: "
	GFERatLog(Space(3) + "> " + STR0089 + ALLTRIM(STR(nVlrPIS)))      //"PIS...........: "
	GFERatLog(Space(3) + "> " + STR0090 + ALLTRIM(STR(nVlrCOFINS)))   //"COFINS........: "
	GFERatLog(Space(3) + "> " + STR0091 + ALLTRIM(STR(nVlInssTerc)))  //"INSS Autonomo.: "
	GFERatLog(Space(3) + "> " + STR0092 + ALLTRIM(STR(nVlInssEmp)))   //"INSS Empresa..: "
	GFERatLog(Space(3) + "> " + STR0093 + ALLTRIM(STR(nVlSestSenat))) //"Sest/Senat....: "
	GFERatLog(Space(3) + "> " + STR0094 + ALLTRIM(STR(nVlrIRRF)))     //"IRRF..........: "
	GFERatLog(Space(3) + "> " + STR0095 + ALLTRIM(STR(nVlrISS)))      //"ISS...........: "

	GFERatLog(Space(3) + "> " + "IBS Estadual..: " + ALLTRIM(STR(aVlrFrete[23])))
	GFERatLog(Space(3) + "> " + "IBS Municipal.: " + ALLTRIM(STR(aVlrFrete[24])))
	GFERatLog(Space(3) + "> " + "CBS...........: " + ALLTRIM(STR(aVlrFrete[25])))


	// Ajusta os espaços das variáveis
	cCdEsp		:= PADR(cCdEsp, 5)
	cIdFederal  := PADR(cIdFederal, TamSX3("GW3_EMISDF")[1])
	cSerie		:= PADR(cSerie, 5)
	nNrDoc		:= PADR(nNrDoc, 16)
	
	// Elimina rateios antigos para este documento
	GFEEliAnt(cTpDocto, cCdEsp, cIdFederal, cSerie, nNrDoc)
	
	If aVlrFrete[13] > 0
		// Geração do rateio
		GFEGerRat(cTpDocto, cAliDcCarg, cFil, cIdFederal, nNrDoc, cSerie, dDtEmiss, nTipoCalc, retTotais, lBatch, lCusto, aVlrFrete, nTipoServ)
	EndIf

	//Ponto de Entrada TUNI49
	If  ExistBlock("GFEXFC04")
		ExecBlock("GFEXFC04",.F.,.F.,{})
	EndIf

	/* MV_TPGERA = 1: Online, 2: Batch */
	If SuperGetMv("MV_TPGERA",,"1") == "2" .AND. !lBatch

		GFERatLog(CRLF + (aRetRateio[2] := "Sistema parametrizado para contabilizar via Batch (MV_TPGERA = 2) mas a rotina foi executada para rodar Online, apenas os rateios contábeis serão gerados."))

	ElseIf SuperGetMV("MV_GFEAJDF",,"1") == "2" .And. lLotProv
		
		GFERatLog(CRLF + (aRetRateio[2] := "Movimentos contábeis não serão regerados pois o cálculo já está em lote de provisão."))
	
	Else

		//gera o Movimento contábil do Cálculo
		If ((GUF->GUF_USO $ "1;3") .Or. cTpDocto $ "2;3")
			// Geração dos movimentos contábeis
			GFEGerMvCt(cTpDocto, cCdEsp, cIdFederal, cSerie, nNrDoc, dDtEmiss, cAliDcCarg, lBatch, lCusto, cFil)
		EndIf

	EndIf

	// Eliminação da tabela temporária
	If lApaga
		If cBanco == "OPENEDGE"
			GFEDelTab(cAliDcCarg)
		Else
			DelTabTemp()
		EndIf
	EndIf

Return aRetRateio

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEEliAnt
Elimina Rateios Antigos

@param  cTpDocto  	Tipo do documento. 1: Cálculo Frete, 2: Documento de Frete, 3: Contrato, 4: Estimativa/Provisão
@param	cIdFederal	Id Federal (Emissor do documento)
@param  cCdEsp   	Espécie do Documento
@param  cSerie   	Série do Documento
@param  nNrDoc   	Número do Documento

@author Israel A Possoli
@since 02/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEEliAnt(cTpDocto, cCdEsp, cIdFederal, cSerie, nNrDoc)
	Local cQuery
	Local s_CRIRAT    := SuperGetMv("MV_CRIRAT",,"1")
	Local aDadosAgro  := {}
	Local cCGCCliente := ""
	Local aCriaRAt    := {}
	Local lMV_AGRORI  := SuperGetMv("MV_AGRORI",.F.,.T.) 
	Local lMV_SIGAAGR := SuperGetMv("MV_SIGAAGR",.F.,.T.)
	
	GFERatLog(STR0096, .T.) //"2. Eliminando rateios antigos"
	GFERatLog(Space(3) + "> Filial: " + xFilial("GWM") + ", Tipo Docto: " + cTpDocto + ", Espécie: " + cCdEsp + ", Emissor: " + cIdFederal  + ", Série: " +  cSerie + ", Número: " + nNrDoc, .T.)
	
	If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
		If FindFunction("AGRGFE003") .And. cTpDocto == "2"
			GWM->( dbSetOrder(1) )
			If GWM->( dbSeek(xFilial("GWM") + AllTrim(cTpDocto) + PadR(cCdEsp,5) + PadR(cIdFederal, TamSX3("GW3_EMISDF")[1]) + PadR(cSerie,5) + PadR(nNrDoc, 16) ))
				While !Eof().AND.;
							GWM->GWM_FILIAL == xFilial("GWM").AND.;
							GWM->GWM_TPDOC  == "2".AND.;
							GWM->GWM_CDESP  == cCdEsp .AND.;
							GWM->GWM_CDTRP  == cIdFederal .AND.;
							GWM->GWM_SERDOC == cSerie .AND.;
							GWM->GWM_NRDOC  == nNrDoc
						
					aCriaRAt := GFEGetRatVal(s_CRIRAT)
			
					nVlICMS 	:= aCriaRAt[1]
					nVlPis 		:= aCriaRAt[2]
					nVlCofi 	:= aCriaRAt[3]
					nValorFrt 	:= aCriaRAt[4]			
					nVlIBS 		:= aCriaRAt[5]
					nVlCBS 		:= aCriaRAt[6]
			
					GW1->( dbSetOrder(1) )
					If GW1->( dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC))
						cCGCCliente := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_IDFED")
					EndIf
			
					aAdd(aDadosAgro,{GWM->GWM_FILIAL,;
							  	 	GWM->GWM_TPDOC,;
								 	GWM->GWM_EMISDC,;
								 	GWM->GWM_SERDC,;
								 	GWM->GWM_NRDC,;
								 	cCGCCliente,;
								 	nVlICMS,;
								 	nVlPis,;
								 	nVlCofi,;
								 	nValorFrt,;
								 	"U" /*UPDATE*/ })
					dbSkip()				 
				EndDo
			EndIf
		EndIf
	EndIf		

	cQuery := "DELETE FROM " + RetSqlName('GWM')
	cQuery += " WHERE GWM_FILIAL = '"+xFilial('GWM')+"'"
	cQuery +=   " AND GWM_TPDOC  = '"+cTpDocto+"'"
	cQuery +=   " AND GWM_CDESP  = '"+cCdEsp+"'"
	cQuery +=   " AND GWM_CDTRP  = '"+cIdFederal+"'"
	cQuery +=   " AND GWM_SERDOC = '"+cSerie+"'"
	cQuery +=   " AND GWM_NRDOC  = '"+nNrDoc+"'"

	If TCSQLExec(cQuery) < 0
		GFERatLog(Space(3) + "Erro ao tentar eliminar os rateios antigos!")
		GFEConout("ERROR","Erro ao tentar eliminar os rateios antigos: " + CRLF + TcSQLError())
	EndIf
	
	If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
		If FindFunction("AGRGFE003") .And. !Empty(aDadosAgro)
			AGRGFE003(aDadosAgro)
		EndIf
	EndIf

	GFESaveLog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFECaToRa
Calcula Totais Rateio.
Função interna, não deve ser executada. Derivada da procedure "calculaTotaisRateio" em botr297.p

@param  Tab  	Tabela com os documentos selecionados


@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFECaToRa(Tab,lRatClass)
	Local aAvalores
	Local aRetorno := {}
	Local nX
	Local cCdclfr := ""

	dbSelectArea(Tab)
	dbSetOrder(1)
	dbGoTop()

	While !(Tab)->(Eof())
		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek(xFilial("GW1")+(Tab)->CDTPDC+(Tab)->EMISDC+(Tab)->SERDC+(Tab)->NRDC)
			dbSelectArea("GW8")
			dbSetOrder(1)
			dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
			While !GW8->(Eof()) .And. xFilial("GW8") == GW8->GW8_FILIAL .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
				GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

				If GW8->GW8_RATEIO != "1" 
					GW8->( dbSkip() )
					Loop
				EndIf
				
				If lRatClass
					cCdclfr := GW8->GW8_CDCLFR
				EndIf

				nX := aScan(aRetorno,{|x| x[1] == cCdclfr})
				If nX == 0
					aAvalores := aAdd(aRetorno,{cCdclfr, Array(25)})[2]
					aAvalores[1]  := 0
					aAvalores[2]  := 0
					aAvalores[3]  := 0
					aAvalores[4]  := 0
					aAvalores[5]  := 0
					aAvalores[6]  := 0
					aAvalores[7]  := 0
					aAvalores[8]  := 0
					aAvalores[9]  := 0
					aAvalores[10] := 0
					aAvalores[11] := 0
					aAvalores[12] := 0
					aAvalores[13] := 0
					aAvalores[14] := 0
					aAvalores[15] := 0
					aAvalores[16] := 0
					aAvalores[17] := 0
					aAvalores[18] := 0
					aAvalores[19] := 0
					aAvalores[20] := 0
					aAvalores[21] := 0
					aAvalores[22] := 0
					aAvalores[23] := 0
					aAvalores[24] := 0
					aAvalores[25] := 0
				Else
					aAvalores := aRetorno[nX,2]
				EndIf

				aAvalores[1] += GW8->GW8_PESOR
				aAvalores[2] += GW8->GW8_PESOC
				aAvalores[3] += GW8->GW8_VALOR
				aAvalores[4] += GW8->GW8_VOLUME
				aAvalores[5] += GW8->GW8_QTDE
				aAvalores[6]++
				
				If GW8->GW8_TRIBP == "1"
					aAvalores[7]  += GW8->GW8_PESOR
					aAvalores[8]  += GW8->GW8_PESOC
					aAvalores[9]  += GW8->GW8_VALOR
					aAvalores[10] += GW8->GW8_VOLUME
					aAvalores[11] += GW8->GW8_QTDE
					aAvalores[12]++
				EndIf

				GW8->( dbSkip() )
			EndDo
		EndIf
		
		GFESaveLog()

		(Tab)->(DbSkip())
	EndDo
	
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEGerRat
Função principal para a geração de rateios.
Função interna, não deve ser executada. Chamada pela função GFERatCon (Gerar Rateio Contábil)
Derivada da procedure "gerarRateioNF" em botr297.p

@param  cTpDocto  	Tipo do Documento. 1: Cálculo Frete, 2: Documento de Frete, 3: Contrato, 4:Estimativa/Provisão
@param  Tab  		Documentos selecionados de acordo com o cTpDocto
@param	cFil		Filial
@param	cIdFederal	Id Federal
@param	nNrDoc		Número do Documento
@param	cSerie		Série
@param	dDtEmiss	Data de Emissão
@param	nTipoCalc	Tipo Cálculo

@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//gerarRateioNF
//-------------------------------------------------------------------
Function GFEGerRat(cTpDocto, Tab, cFil, cIdFederal, nNrDoc, cSerie, dDtEmiss, nTipoCalc, retTotais, lBatch, lCusto, aVlrFrete, nTipoServ)
	Local GWMTmp := {} // RECNO dos Registros criados na GWM
	Local nI
	Local aGrupo[7]
	Local cGrupos

	Local cCntaFrtPg // Conta Frete Pagar
	Local cCCusFrtPg // Centro de Custo da Conta Frete Pagar

	Local nTDesp      	:= {0, 0, 0, 0} // deTotalDespesa
	Local nTICMS      	:= {0, 0, 0, 0} // deTotalICMS
	Local nTPIS       	:= {0, 0, 0, 0} // deTotalPIS
	Local nTCOFINS    	:= {0, 0, 0, 0} // deTotalCOFINS
	Local nTINSSAut   	:= {0, 0, 0, 0} // deTotalINSS
	Local nTINSSEmp   	:= {0, 0, 0, 0} // deTotalINSSTerc
	Local nTSESSEN    	:= {0, 0, 0, 0} // deTotalSESTSENAT - SEST SENAT
	Local nTIRRF      	:= {0, 0, 0, 0} // deTotalIRRF
	Local nTISS       	:= {0, 0, 0, 0} // deTotalISS
	Local nTPedagio   	:= {0, 0, 0, 0} // deTotalPedagio
	Local nTPntPc     	:= 0            // deTotalPontosPerc

	Local nTIBS      	:= {0, 0, 0, 0} // deTotalIBS
	Local nTIBSM      	:= {0, 0, 0, 0} // deTotalIBSMun
	Local nTCBS      	:= {0, 0, 0, 0} // deTotalCBS

	Local nPcMaior	  	:= 0 /* Armazena o Perc. Maior do Valor do Frete */
	Local nPcMaiorPC  	:= 0 /* Armazena o Perc. Maior de PIS/COFINS */
	Local recPcMaior  	:= 0 /* Armazena o RecNo do Perc. Maior */
	Local recPcPisCo  	:= 0 /* Armazena o REcNo do Perc. Maior, usado no PIS e CONFINS */
	
	Local dtDtEmiGWM  	:= dDtEmiss
	Local cContaFrt   	:= ""
	Local cCentroFrt  	:= ""

	Local lSemCta     	:= .F.
	Local cDCSemCta   	:= ""
	Local cDCAnt      	:= ""
	Local nContRat    	:= 0
	Local cFilDoc
	Local lNovoRateio

	Local nCdtpdc
	Local lXGFECTCC		:= ExistBlock("XGFECTCC")

	Local cFormCredICMS := GetNewPar("MV_CRDPAR", "1")
	Local cMV_TPGRP1 	:= SuperGetMv("MV_TPGRP1",,"0")
	Local cMV_TPGRP2 	:= SuperGetMv("MV_TPGRP2",,"0")
	Local cMV_TPGRP3 	:= SuperGetMv("MV_TPGRP3",,"0")
	Local cMV_TPGRP4 	:= SuperGetMv("MV_TPGRP4",,"0")
	Local cMV_TPGRP5 	:= SuperGetMv("MV_TPGRP5",,"0")
	Local cMV_TPGRP6 	:= SuperGetMv("MV_TPGRP6",,"0")
	Local cMV_TPGRP7 	:= SuperGetMv("MV_TPGRP7",,"0")
	Local cCTPROV_Exist := GFEVerCmpo({"GUF_CTPROV"})
	Local cAcGrRat 		:= SuperGetMv("MV_ACGRRAT",.F.,"1")
	Local aRatClFr
	Local lRatClass 	:= ( Len(retTotais) > 1 )
	Local s_GFEXFC02 	:= ExistBlock("GFEXFC02")
	Local s_GFEXFC03 	:= ExistBlock("GFEXFC03")
	Local s_CRIRAT   	:= SuperGetMv("MV_CRIRAT",,"1")
	Local aDadosAgro 	:= {}	
	Local nValorFrt 	:= 0
	Local cCGCCliente 	:= ""
	Local lMV_AGRORI  	:= SuperGetMv("MV_AGRORI",.F.,.T.) 
	Local lMV_SIGAAGR 	:= SuperGetMv("MV_SIGAAGR",.F.,.T.)
	Local aDadosCT 		:= {}
	Local aListEmitRaiz := {}
	Local nPos			:= 0

	Private cNrCt    := ""
	
	If Empty(cAcGrRat)
		cAcGrRat := "1"
	EndIf
	

	If cTpDocto $ "1;4" .And. !Empty(GWF->GWF_FILIAL)
		cFilDoc := GWF->GWF_FILIAL
	ElseIf cTpDocto == "2" .And. !Empty(GW3->GW3_FILIAL)
		cFilDoc := GW3->GW3_FILIAL
	ElseIf cTpDocto == "3" .And. !Empty(GW2->GW2_FILIAL)
		cFilDoc := GW2->GW2_FILIAL
	Else
		cFilDoc := cFilAnt
	EndIf

	GFERatLog(STR0104, .T.) //"3. Gerar Rateio"
	// GFERatLog(Space(3) + "> " + AllTrim(GFEFldInfo("GWM_TPDOC",cTpDocto,2)), .T.)
	// GFERatLog(Space(3) + "> " + STR0053 + ": " + nNrDoc + " - " + AllTrim(GFEFldInfo("GWF_TPCALC",nTipoCalc,2))) //"Número:"
	
	If cTpDocto == "1"
		GFERatLog(Space(3) + "> Tipo do cálculo: " + AllTrim(GFEFldInfo("GWF_TPCALC",nTipoCalc,2)))
	ElseIf cTpDocto == "2"
		GFERatLog(Space(3) + "> Tipo do Documento de Frete: " + AllTrim(GFEFldInfo("GW3_TPDF",nTipoCalc,2)))
	EndIf
	
	//Ponto de Entrada Britania
	If ExistBlock("XGFERATE")
		cRet := ExecBlock("XGFERATE",.f.,.f.,{cTpDocto, cFil, cIdFederal, cSerie, nNrDoc, dDtEmiss})
	EndIf
	//Fim Ponto de Entrada Britania
	
	GFERatLog(Space(3) + STR0108, .T.) //"Parâmetros dos tipos dos grupos:"
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP1): " + cMV_TPGRP1 + " - " + GFEContLab(1))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP2): " + cMV_TPGRP2 + " - " + GFEContLab(2))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP3): " + cMV_TPGRP3 + " - " + GFEContLab(3))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP4): " + cMV_TPGRP4 + " - " + GFEContLab(4))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP5): " + cMV_TPGRP5 + " - " + GFEContLab(5))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP6): " + cMV_TPGRP6 + " - " + GFEContLab(6))
	GFERatLog(Space(7) + "> Grupo 1 (MV_TPGRP7): " + cMV_TPGRP7 + " - " + GFEContLab(7))
	
	SetProcess("Gerando rateio (2/3)", nCountGW1)
	
	dbSelectArea(Tab)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		dbSelectArea("GW1")	// Documento de Carga
		dbSetOrder(1)

		If dbSeek(xFilial("GW1")+(Tab)->CDTPDC+(Tab)->EMISDC+(Tab)->SERDC+(Tab)->NRDC)
			IncProcess()
			
			GFERatLog(Replicate("=", 100), .T.)
			GFERatLog(Space(3) + STR0105, .T.) //"Processando Documento de Carga:"
			GFERatLog(Space(3) + "> " + STR0077 + ": " + ALLTRIM(GW1->GW1_CDTPDC) + ", " + STR0046 + ": " + ALLTRIM(GW1->GW1_EMISDC) + ", " + STR0047 + ": " + Transform(GW1->GW1_SERDC,"!!!") + ", " + STR0053 + ": " + ALLTRIM(GW1->GW1_NRDC)) //Tipo Doc: ### Emissor: ### "Série:" ### "Número:"
			GFERatLog(Space(3) + "----------------------------------------------------------------")

			nCdtpdc := GW1->GW1_CDTPDC
						
			cNrCt := ''	
			
			If GFXCP12127("GVW_NRCT")		
				If cTpDocto == '1'
					GWG->(dbSetOrder(1))						
					If GWG->(dbSeek(xFilial("GWG")+Padr(nNrDoc,TamSx3("GWF_NRCALC")[1])))			
						GVW->(dbSetOrder(1))
						GVW->(dbSeek(xFilial("GVW") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG))
						While !Eof() .And. xFilial("GVW") + GVW->GVW_CDEMIT + GVW->GVW_NRTAB + GVW->GVW_NRNEG == xFilial("GVW") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG		
						
							cNrCt := GVW->GVW_NRCT

							GVW->(DbSkip())
						EndDo								
					EndIf

					aListEmitRaiz 	:= {}
					nPos			:= 0

					If Empty(cNrCt)
						GVA->(dbSetOrder(1))
						IF GVA->(dbSeek(xFilial("GVA") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB)) .And. GVA->GVA_TPTAB == '2' // Tabela Vínculo
							aListEmitRaiz := StrTokArr(GFEGetEmRz(GWG->GWG_CDEMIT),",")
							For nPos := 1 to Len(aListEmitRaiz)
								aListEmitRaiz[nPos] := AllTrim(StrTran(aListEmitRaiz[nPos],"'",""))
							Next nPos
							
							If aScan(aListEmitRaiz, AllTrim(GVA->GVA_EMIVIN)) > 0
								GVW->(dbSetOrder(1))
								If GVW->(dbSeek(xFilial("GVW") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GWG->GWG_NRNEG))
									cNrCt := GVW->GVW_NRCT	
										
									GVW->(DbSkip())
								EndIf
							EndIf															
						EndIf
					EndIf
				ElseIf cTpDocto == '2'
					GWH->(dbSetOrder(2))
					GWH->(dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
					While !Eof() .And. xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC == GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC
						GWF->(dbSetOrder(1))	
						If GWF->(dbSeek(xFilial("GWF")+GWH->GWH_NRCALC))
							IF nTipoCalc == GWF->GWF_TPCALC
								GWG->(dbSetOrder(1))	
								If GWG->(dbSeek(xFilial("GWG")+GWF->GWF_NRCALC))	
									GVW->(dbSetOrder(1))
									GVW->(dbSeek(xFilial("GVW") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG))
									While !Eof() .And. xFilial("GVW") + GVW->GVW_CDEMIT + GVW->GVW_NRTAB + GVW->GVW_NRNEG == xFilial("GVW") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG									
									
										cNrCt := GVW->GVW_NRCT	
									
										GVW->(DbSkip())
									EndDo													
								EndIf	
							EndIf			
						EndIf

						If Empty(cNrCt)
							GVA->(dbSetOrder(1))
							IF GVA->(dbSeek(xFilial("GVA") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB)) .And. GVA->GVA_TPTAB == '2' // Tabela Vínculo
								aListEmitRaiz := StrTokArr(GFEGetEmRz(GWG->GWG_CDEMIT),",")
								For nPos := 1 to Len(aListEmitRaiz)
									aListEmitRaiz[nPos] := AllTrim(StrTran(aListEmitRaiz[nPos],"'",""))
								Next nPos
								
								If aScan(aListEmitRaiz, AllTrim(GVA->GVA_EMIVIN)) > 0
									GVW->(dbSetOrder(1))
									If GVW->(dbSeek(xFilial("GVW") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GWG->GWG_NRNEG))
										cNrCt := GVW->GVW_NRCT	
											
										GVW->(DbSkip())
									EndIf
								EndIf															
							EndIf
						EndIf

						GWH->(DbSkip())
				    EndDo				
				EndIf
			EndIf
			
			dbSelectArea("GW8")	// Item do documento de carga
			dbSetOrder(1)
			dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
			While !Eof() .AND. xFilial("GW8") == GW8->GW8_FILIAL .AND. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
				GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC
				GFERatLog(Space(3) + "3.1 Item: " + ALLTRIM(GW8->GW8_ITEM) + ", Seq: " + GW8->GW8_SEQ, .T.)  // "3.1 Processando Item: "

				cContaFrt := "" //GUF->GUF_CTFRET
				cCentroFrt := "" //GUF->GUF_CCFRET
				
				If GW8->GW8_RATEIO != "1"
					GW8->( dbSkip() )
					Loop
				EndIf
				
				If  s_GFEXFC02
					lRet :=  ExecBlock("GFEXFC02",.F.,.F.,{cTpDocto})
					if !lRet
						GW8->( dbSkip() )
						Loop
					EndIf					
				EndIf					

				/** Busca código dos grupos conforme os parâmetros MV_TPGRP1 a MV_TPGRP7
				Cada parâmetro deverá conter o código de que valor deverá buscar:
				1 - Filial
				2 - Tipo Operação
				3 - Item do Documento de Carga
				4 - Região Comercial do Destinatário
				5 - Grupo de Cliente do Destinatário
				6 - Tipo Doc Carga
				7 - Classificação de Frete
				8 - Tipo de Cálculo
				9 -  Informação genérica do item do documento de carga (GW8_INFO1)
				10 - Informação genérica do item do documento de carga (GW8_INFO2)
				11 - Informação genérica do item do documento de carga (GW8_INFO3)
				12 - Informação genérica do item do documento de carga (GW8_INFO4)
				13 - Informação genérica do item do documento de carga (GW8_INFO5)
				14 - Representante Do Documento de Carga
				15 - Unidade de Negócio do item do documento de carga
				16 - CFOP do item do documento de carga
				17 - Tipo de Serviço
				18 - Grupo de Transportador
				19 - Série Doc Carga
				*/

				aGrupo[1] := GFEVlrGru(cMV_TPGRP1, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[2] := GFEVlrGru(cMV_TPGRP2, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[3] := GFEVlrGru(cMV_TPGRP3, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[4] := GFEVlrGru(cMV_TPGRP4, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[5] := GFEVlrGru(cMV_TPGRP5, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[6] := GFEVlrGru(cMV_TPGRP6, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
				aGrupo[7] := GFEVlrGru(cMV_TPGRP7, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)

				GFERatLog(Space(7) + STR0109, .T.) //"Valores do Documento de Carga conforme o grupo:"
				GFERatLog(Space(7) + "> " + STR0110 + " 1 : " + cValToChar(aGrupo[1])) //"Grupo"
				If !Empty(aGrupo[2])
					GFERatLog(Space(7) + "> " + STR0110 + " 2 : " + cValToChar(aGrupo[2])) //"Grupo"
				EndIf
				If !Empty(aGrupo[3])
					GFERatLog(Space(7) + "> " + STR0110 + " 3 : " + cValToChar(aGrupo[3])) //"Grupo"
				EndIf
				If !Empty(aGrupo[4])
					GFERatLog(Space(7) + "> " + STR0110 + " 4 : " + cValToChar(aGrupo[4])) //"Grupo"
				EndIf
				If !Empty(aGrupo[5])
					GFERatLog(Space(7) + "> " + STR0110 + " 5 : " + cValToChar(aGrupo[5])) //"Grupo"
				EndIf
				If !Empty(aGrupo[6])
					GFERatLog(Space(7) + "> " + STR0110 + " 6 : " + cValToChar(aGrupo[6])) //"Grupo"
				EndIf
				If !Empty(aGrupo[7])
					GFERatLog(Space(7) + "> " + STR0110 + " 7 : " + cValToChar(aGrupo[7])) //"Grupo"
				EndIf

				/* Ajusta os valores dos grupos para realizar a busca na GWM */
				cGrupos := PadR(aGrupo[1], 20) + PadR(aGrupo[2], 20) + PadR(aGrupo[3], 20) + PadR(aGrupo[4], 20) + PadR(aGrupo[5], 20) + PadR(aGrupo[6], 20) + PadR(aGrupo[7], 20)

    			GFERatLog(Space(3) + STR0111, .T.) //"3.2 Criação do Rateio"
    			// GFERatLog(Space(7) + AllTrim(GFEFldInfo("GWM_TPDOC", cTpDocto, 2)) + " => " + STR0052 + ": " + AllTrim((Tab)->CDESP) + ", " + STR0112 + ": " + AllTrim(cIdFederal) + ", " + STR0047 + ": " + AllTrim(cSerie) + ", " + STR0053 + ": " + AllTrim(nNrDoc) + ", " + STR0062 + ": " + cValToChar(dDtEmiss), .T.) //"Espécie:" ### "Transp:" ### "Série:" ### "Número:" ### "Dt Emissão:"
    			// GFERatLog(Space(7) + STR0113 + AllTrim(GW1->GW1_CDTPDC) + ", " + STR0046 + ": " + AllTrim(GW1->GW1_EMISDC) + ", " + STR0047 + ": " + AllTrim(GW1->GW1_SERDC) + ", " + STR0053 + ": " + AllTrim(GW1->GW1_NRDC)) //"Documento de Carga => Tipo: " ### "Emissor:" ### "Série:" ### "Número:"
    			// GFERatLog(Space(7) + STR0114 + ": [" + cGrupos + "]", .T.) //"Valores para pesquisa dos grupos"
    			
				dbSelectArea("GWM")
				GWM->( dbSetOrder(1) )
				If !GWM->( dbSeek(xFilial("GWM") + AllTrim(cTpDocto) + PadR((Tab)->CDESP,5) + PadR(cIdFederal, TamSX3("GW3_EMISDF")[1]) + ;
								 PadR(cSerie,5) + PadR(nNrDoc, 16) + DToS(dtDtEmiGWM) + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + ;
								 GW1->GW1_NRDC + GW8->GW8_SEQ) )

					// Caso haja pelo menos um documento de carga de 'custo', todas contas serão provenientes da GUS.
					If !lCusto

						rRecNo := GFEObGrCo(aGrupo)

						If rRecNo != 0
							dbSelectArea("GUF")
							GUF->( dbGoTo(rRecNo) )
							GFERatLog(Space(7) + STR0115,.T.) //"Contas do grupo selecionado:"
				    		GFERatLog(Space(7) + "> Conta Cofins.........: " + GUF->GUF_CTCOFI + "  Centro Custo: " + ALLTRIM(GUF->GUF_CCCOFI))
				    		GFERatLog(Space(7) + "> Conta ICMS...........: " + GUF->GUF_CTICMS + "  Centro Custo: " + ALLTRIM(GUF->GUF_CCICMS))
				    		GFERatLog(Space(7) + "> Conta PIS............: " + GUF->GUF_CTPIS  + "  Centro Custo: " + ALLTRIM(GUF->GUF_CCPIS))
				    		GFERatLog(Space(7) + "> Conta INSS Emp.......: " + GUF->GUF_CTINEM + "  Centro Custo: " + ALLTRIM(GUF->GUF_CCINEM))
				    		GFERatLog(Space(7) + "> Conta Frete..........: " + GUF->GUF_CTFRET + "  Centro Custo: " + ALLTRIM(GUF->GUF_CCFRET)) 

							cContaFrt  := GUF->GUF_CTFRET
							cCentroFrt := GUF->GUF_CCFRET
							
							If cCTPROV_Exist
								If cTpDocto $ "1;4" .And. !Empty(GUF->GUF_CTPROV)
									cContaFrt  := GUF->GUF_CTPROV
									cCentroFrt := GUF->GUF_CCPROV
								EndIf
							EndIf

							If GUF->GUF_USO == "2" .And. cTpDocto $ "4" /* Somente Realização E Cálculo */

								GFERatLog(Space(7) + STR0121) //"Grupo Contábil é somente Realização, tipo de Documento é Cálculo e o método é Online. Desconsiderando."
							   	GW8->( dbSkip() )
							   	Loop

							EndIf

						Else

							lSemCta := .T.
							GFERatLog(Space(7) + STR0122) //"Nenhum grupo encontrado para o Documento de Carga. Cancelando Operação."

						EndIf

					Else

						dbSelectArea("GUS")
						GUS->( dbSetOrder(1) )
						If GUS->( dbSeek(xFilial("GUS") + cFilDoc) )

							cContaFrt := GUS->GUS_CTFRET
							cCentroFrt := GUS->GUS_CCFRET

							If Empty(cContaFrt)

								lSemCta := .T.
								GFERatLog(Space(7) + "A Conta por Filial para Documentos de Carga de custo está em branco. Cancelando operação.") //""

							EndIf

						Else

							lSemCta := .T.
							GFERatLog(Space(7) + "Nenhum cadastro de Conta por Filial foi encontrado. Cancelando operação.") //""

						EndIf

					EndIf

					If lSemCta

						If cDCAnt != GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC

							cDCAnt := GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC

							If Empty(cDCSemCta)
								cDCSemCta := CRLF + CRLF
							EndIf

							cDCSemCta += "- Rateio " + StrZero(++nContRat, 4) + CRLF
							cDCSemCta += "    Filial: " + GW1->GW1_FILIAL + CRLF
							cDCSemCta += "    Numero: " + GW1->GW1_NRDC + CRLF
							cDCSemCta += "    Serie : " + Transform(GW1->GW1_SERDC,"!!!") + CRLF
							If !lCusto
								cDCSemCta += GFEXFUNCDG(aGrupo)
							EndIf
							cDCSemCta += CRLF + CRLF

						EndIf

					EndIf

					//Ponto de Entrada Britania
					If lXGFECTCC
						cRet := ExecBlock("XGFECTCC",.f.,.f.,{cTpDocto, cFil, cIdFederal, cSerie, nNrDoc, dDtEmiss})
					   	If ValType(cRet) == 'A'
					    	cContaFrt  := cRet[1]
							cCentroFrt := cRet[2]
						endIf
					EndIf
					//Fim Ponto de Entrada Britania

					dbSelectArea("GWM")
					RecLock("GWM", .T.)

						GWM->GWM_FILIAL := cFil
						GWM->GWM_TPDOC	:= cTpDocto
						GWM->GWM_CDESP	:= (Tab)->CDESP
						GWM->GWM_CDTRP	:= cIdFederal
						GWM->GWM_SERDOC := cSerie
						GWM->GWM_NRDOC	:= nNrDoc 	     // Número do Documento
						GWM->GWM_NRDC  	:= GW1->GW1_NRDC // Número do Documento de Carga
						GWM->GWM_SERDC   := GW1->GW1_SERDC
						GWM->GWM_SDOCDC  := GW1->GW1_SDOC						
						GWM->GWM_EMISDC  := GW1->GW1_EMISDC
						GWM->GWM_CDTPDC  := GW1->GW1_CDTPDC
						GWM->GWM_DTEMDC := GW1->GW1_DTEMIS   // Data do Documento de carga
						GWM->GWM_SEQGW8 := GW8->GW8_SEQ
						GWM->GWM_ITEM   := GW8->GW8_ITEM
						GWM->GWM_UNINEG := GW8->GW8_UNINEG
						GWM->GWM_GRPCTB	:= cGrupos

						If aGrupo[1] != "*"; GWM->GWM_GRP1 := aGrupo[1]; EndIf
						If aGrupo[2] != "*"; GWM->GWM_GRP2 := aGrupo[2]; EndIf
						If aGrupo[3] != "*"; GWM->GWM_GRP3 := aGrupo[3]; EndIf
						If aGrupo[4] != "*"; GWM->GWM_GRP4 := aGrupo[4]; EndIf
						If aGrupo[5] != "*"; GWM->GWM_GRP5 := aGrupo[5]; EndIf
						If aGrupo[6] != "*"; GWM->GWM_GRP6 := aGrupo[6]; EndIf
						If aGrupo[7] != "*"; GWM->GWM_GRP7 := aGrupo[7]; EndIf

						If !Empty(dDtEmiss)
							GWM->GWM_DTEMIS := dDtEmiss
						Else
							GWM->GWM_DTEMIS := GW1->GW1_DTEMIS
						EndIf

						If cTpDocto == "4"
							GWM->GWM_CTFRET	:= GUF->GUF_CTPROV
							GWM->GWM_CCFRET	:= GUF->GUF_CCPROV
						Else
							GWM->GWM_CTFRET	:= cContaFrt //GUF->GUF_CTFRET
							GWM->GWM_CCFRET	:= cCentroFrt //GUF->GUF_CCFRET
						EndIf

						If cTpDocto == "3"
							GWM->GWM_CTINEM	:= GUF->GUF_CTINEM
							GWM->GWM_CCINEM	:= GUF->GUF_CCINEM
						Endif

						/* Cálculo ou Documento de Frete */
			       		If (cTpDocto $ "1;2;4") .And. cTransp <> "1"
			       			// Contas Contábeis
							GWM->GWM_CTICMS	:= GUF->GUF_CTICMS
							GWM->GWM_CTPIS	:= GUF->GUF_CTPIS
							GWM->GWM_CTCOFI	:= GUF->GUF_CTCOFI

							// Centro de Custo
							GWM->GWM_CCICMS	:= GUF->GUF_CCICMS
							GWM->GWM_CCPIS	:= GUF->GUF_CCPIS
							GWM->GWM_CCCOFI	:= GUF->GUF_CCCOFI
						Endif

						dtDtEmiGWM := GWM->GWM_DTEMIS

						//"Rateio criado."

					MsUnLock("GWM")
					
					lNovoRateio := .T.

				Else

					lNovoRateio := .F.

				EndIf

				GFERatLog(Space(3) + STR0125, .T.) //"3.3 Atualização dos valores do Rateio"
				dbSelectArea("GWM")
				GWM->( dbSetOrder(1) )
				If GWM->( dbSeek(xFilial("GWM") + AllTrim(cTpDocto) + PadR((Tab)->CDESP,5) + PadR(cIdFederal, TamSX3("GW3_EMISDF")[1]) + ;
								 PadR(cSerie,5) + PadR(nNrDoc, 16) + DToS(dtDtEmiGWM) + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + ;
								 GW1->GW1_NRDC + GW8->GW8_SEQ) )

					If lNovoRateio
						AAdd(GWMTmp, GWM->( Recno() ))
					Else
						GFERatLog(Space(3) + "- Já existe um Rateio criado, somando os valores ao Rateio Existente.")
					EndIf

					/* Cálculo ou Documento de Frete */
					If lRatClass
						aRatClFr := retTotais[aScan(retTotais,{|x| x[1] == GW8->GW8_CDCLFR})][2]
					Else
						aRatClFr := retTotais[1][2]
					EndIf
					
					If cTpDocto $ "1;2;4"
						RecLock("GWM", .F.)

							//RATEIO POR PESO
							If aVlrFrete[1] != 0
								If aVlrFrete[1] >= aVlrFrete[2]
									
									GWM->GWM_VLFRET := NoRound(aRatClFr[13] * ( GW8->GW8_PESOR / aRatClFr[1] ), 2)
									
									If cTransp <> "1"
										GWM->GWM_VLICMS := Round(aRatClFr[14] * GW8->GW8_PESOR / aRatClFr[1], 2)
										GWM->GWM_VLISS  := Round(aRatClFr[21] * GW8->GW8_PESOR / aRatClFr[1], 2)
										If GW8->GW8_TRIBP == "1"
											GWM->GWM_VLPIS	:= NoRound(aRatClFr[15] * GW8->GW8_PESOR / aRatClFr[7], 2)
											GWM->GWM_VLCOFI	:= NoRound(aRatClFr[16] * GW8->GW8_PESOR / aRatClFr[7], 2)
										Else
											GWM->GWM_VLPIS	:= 0
											GWM->GWM_VLCOFI	:= 0
										EndIf

										If GFXCP2510('GWM_VLIBS')	// Estadual
											GWM->GWM_VLIBS := Round(aRatClFr[23] * GW8->GW8_PESOR / aRatClFr[1], 2)
										EndIf
										If GFXCP2510('GWM_VLIBM')	// Municipal
											GWM->GWM_VLIBM := Round(aRatClFr[24] * GW8->GW8_PESOR / aRatClFr[1], 2)
										EndIf
										If GFXCP2510('GWM_VLCBS')
											GWM->GWM_VLCBS := Round(aRatClFr[25] * GW8->GW8_PESOR / aRatClFr[1], 2)
										EndIf

										GWM->GWM_PEDAG	:= Round(aRatClFr[22] * GW8->GW8_PESOR / aRatClFr[1], 2)
									EndIf
									
									GFERatLog(Space(7) + "Peso       => Peso Real..: " + PadL(cValToChar(GW8->GW8_PESOR), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRET), 15) + " (" + cValToChar(GW8->GW8_PESOR / aRatClFr[1] * 100) + " %)")
									
								Else
									If GW8->GW8_PESOC != 0
										GWM->GWM_VLFRET := NoRound(aRatClFr[13] * GW8->GW8_PESOC / aRatClFr[2], 2)
										If cTransp <> "1"
											GWM->GWM_VLICMS := Round(aRatClFr[14] * GW8->GW8_PESOC / aRatClFr[2], 2)
											GWM->GWM_VLISS  := Round(aRatClFr[21] * GW8->GW8_PESOC / aRatClFr[2], 2)
											If GW8->GW8_TRIBP == "1"
												GWM->GWM_VLPIS	:= NoRound(aRatClFr[15] * GW8->GW8_PESOC / aRatClFr[8], 2)
												GWM->GWM_VLCOFI	:= NoRound(aRatClFr[16] * GW8->GW8_PESOC / aRatClFr[8], 2)
											Else
												GWM->GWM_VLPIS	:= 0
												GWM->GWM_VLCOFI	:= 0
											EndIf	
											GWM->GWM_PEDAG	:= Round(aRatClFr[22] * GW8->GW8_PESOR / aRatClFr[2], 2)

											If GFXCP2510('GWM_VLIBS')	// Estadual
												GWM->GWM_VLIBS := Round(aRatClFr[23] * GW8->GW8_PESOC / aRatClFr[2], 2)
											EndIf
											If GFXCP2510('GWM_VLIBM')	// Municipal
												GWM->GWM_VLIBM := Round(aRatClFr[24] * GW8->GW8_PESOC / aRatClFr[2], 2)
											EndIf
											If GFXCP2510('GWM_VLCBS')
												GWM->GWM_VLCBS := Round(aRatClFr[25] * GW8->GW8_PESOC / aRatClFr[2], 2)
											EndIf
										EndIf
	
										GFERatLog(Space(7) + "Peso       => Peso Cubado: " + PadL(cValToChar(GW8->GW8_PESOC), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRET), 15) + " (" + cValToChar(GW8->GW8_PESOC / aRatClFr[2] * 100) + " %)")
									Else
										GWM->GWM_VLICMS := 0
										GWM->GWM_VLISS  := 0
										GWM->GWM_VLFRET := 0
										If GFXCP2510('GWM_VLIBS')	// Estadual
											GWM->GWM_VLIBS := 0
										EndIf
										If GFXCP2510('GWM_VLIBM')	// Municipal
											GWM->GWM_VLIBM := 0
										EndIf
										If GFXCP2510('GWM_VLCBS')
											GWM->GWM_VLCBS := 0
										EndIf
										GFERatLog(Space(7) + "Peso       => ** Peso Cubado está zerado. Valor de frete para este item ficará zerado.")
									EndIf
								EndIf
							Else

								GWM->GWM_VLFRET := NoRound(aRatClFr[13] / aRatClFr[6], 2)
								If cTransp <> "1"
									GWM->GWM_VLICMS := Round(aRatClFr[14] / aRatClFr[6], 2)
									GWM->GWM_VLISS  := Round(aRatClFr[21] / aRatClFr[6], 2)
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS	:= NoRound(aRatClFr[15] / aRatClFr[12], 2)
										GWM->GWM_VLCOFI := NoRound(aRatClFr[16] / aRatClFr[12], 2)
									Else
										GWM->GWM_VLPIS	:= 0
										GWM->GWM_VLCOFI	:= 0
									EndIf
									GWM->GWM_PEDAG  := Round(aRatClFr[22] / aRatClFr[6], 2)

									If GFXCP2510('GWM_VLIBS')	// Estadual
										GWM->GWM_VLIBS := 0
									EndIf
									If GFXCP2510('GWM_VLIBM')	// Municipal
										GWM->GWM_VLIBM := 0
									EndIf
									If GFXCP2510('GWM_VLCBS')
										GWM->GWM_VLCBS := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Peso       => ** Peso zerado, usando o número de itens como critério de rateio")
							    GFERatLog(Space(7) + "Peso       => Número total de itens: " + PadL(cValToChar(aRatClFr[6]), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRET), 15) + " (" + cValToChar(1 / aRatClFr[6] * 100) + " %)")

							EndIf

							//RATEIO POR VALOR
							If aVlrFrete[3] != 0

								GWM->GWM_VLFRE1 := NoRound(aRatClFr[13] * GW8->GW8_VALOR / aRatClFr[3], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM1 := Round(aRatClFr[14]  * GW8->GW8_VALOR / aRatClFr[3], 2)
									GWM->GWM_VLISS1 := Round(aRatClFr[21] * GW8->GW8_VALOR / aRatClFr[3], 2)
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS1	:= NoRound(aRatClFr[15]  * GW8->GW8_VALOR / aRatClFr[9], 2)
										GWM->GWM_VLCOF1	:= NoRound(aRatClFr[16] * GW8->GW8_VALOR / aRatClFr[9], 2)
									Else
										GWM->GWM_VLPIS1	:= 0
										GWM->GWM_VLCOF1	:= 0
									EndIf		
									GWM->GWM_PEDAG1	:= Round(aRatClFr[22] * GW8->GW8_VALOR / aRatClFr[3], 2)

									If GFXCP2510('GWM_VLIBS1')	// Estadual
										GWM->GWM_VLIBS1 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM1')	// Municipal
										GWM->GWM_VLIBM1 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS1')
										GWM->GWM_VLCBS1 := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Valor      => Valor item.: " + PadL(cValToChar(GW8->GW8_VALOR), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE1), 15) + " (" + cValToChar(GW8->GW8_VALOR / aRatClFr[3] * 100) + " %) [GWM_VLFRE1]")
							Else

								GWM->GWM_VLFRE1 := NoRound(aRatClFr[13] / aRatClFr[6], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM1 := Round(aRatClFr[14]  / aRatClFr[6], 2)
									GWM->GWM_VLISS1 := Round(aRatClFr[21] / aRatClFr[6], 2)
									
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS1	:= NoRound(aRatClFr[15]  / aRatClFr[12], 2)
										GWM->GWM_VLCOF1 := NoRound(aRatClFr[16] / aRatClFr[12], 2)
									Else
										GWM->GWM_VLPIS1	:= 0
										GWM->GWM_VLCOF1	:= 0
									EndIf
									
									GWM->GWM_PEDAG1 := Round(aRatClFr[22] / aRatClFr[6], 2)

									If GFXCP2510('GWM_VLIBS1')	// Estadual
										GWM->GWM_VLIBS1 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM1')	// Municipal
										GWM->GWM_VLIBM1 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS1')
										GWM->GWM_VLCBS1 := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Valor      => ** Peso zerado, usando o número de itens como critério de rateio")
							    GFERatLog(Space(7) + "Valor      => Número de itens: " + PadL(cValToChar(aRatClFr[6]), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE1), 15) + " (" + cValToChar(1 / aRatClFr[6] * 100) + " %) [GWM_VLFRE1]")

							EndIf

							//RATEIO POR VOLUME
							If aVlrFrete[4] != 0

								GWM->GWM_VLFRE3 := NoRound(aRatClFr[13]  * GW8->GW8_VOLUME / aRatClFr[4], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM3 := Round(aRatClFr[14]  * GW8->GW8_VOLUME / aRatClFr[4], 2)
									GWM->GWM_VLISS3 := Round(aRatClFr[21] * GW8->GW8_VOLUME / aRatClFr[4], 2)
									
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS3	:= NoRound(aRatClFr[15]  * GW8->GW8_VOLUME / aRatClFr[10], 2)
										GWM->GWM_VLCOF3	:= NoRound(aRatClFr[16] * GW8->GW8_VOLUME / aRatClFr[10], 2)
									Else
										GWM->GWM_VLPIS3	:= 0
										GWM->GWM_VLCOF3	:= 0
									EndIf
										
									GWM->GWM_PEDAG3	:= Round(aRatClFr[22] * GW8->GW8_VOLUME / aRatClFr[4], 2)

									If GFXCP2510('GWM_VLIBS3')	// Estadual
										GWM->GWM_VLIBS3 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM3')	// Municipal
										GWM->GWM_VLIBM3 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS3')
										GWM->GWM_VLCBS3 := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Volume     => Volume item: " + PadL(cValToChar(GW8->GW8_VOLUME), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE3), 15) + " (" + cValToChar(GW8->GW8_VOLUME / aRatClFr[4] * 100) + " %) [GWM_VLFRE3]")

							Else

								GWM->GWM_VLFRE3 := NoRound(aRatClFr[13] / aRatClFr[6], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM3 := Round(aRatClFr[14]  / aRatClFr[6], 2)
									GWM->GWM_VLISS3 := Round(aRatClFr[21] / aRatClFr[6], 2)
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS3	:= NoRound(aRatClFr[15]  / aRatClFr[12], 2)
										GWM->GWM_VLCOF3 := NoRound(aRatClFr[16] / aRatClFr[12], 2)
									Else
										GWM->GWM_VLPIS3	:= 0
										GWM->GWM_VLCOF3 := 0
									EndIf	
									GWM->GWM_PEDAG3 := Round(aRatClFr[22] / aRatClFr[6], 2)

									If GFXCP2510('GWM_VLIBS3')	// Estadual
										GWM->GWM_VLIBS3 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM3')	// Municipal
										GWM->GWM_VLIBM3 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS3')
										GWM->GWM_VLCBS3 := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Volume     => ** Peso zerado, usando o número de itens como critério de rateio")
							    GFERatLog(Space(7) + "Volume     => Número de itens: " + PadL(cValToChar(aRatClFr[6]), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE1), 15) + " (" + cValToChar(1 / aRatClFr[6] * 100) + " %) [GWM_VLFRE1]")

							EndIf

							//RATEIO POR QUANTIDADE
							If aVlrFrete[5] != 0

								GWM->GWM_VLFRE2 := NoRound(aRatClFr[13]  * GW8->GW8_QTDE / aRatClFr[5], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM2 := Round(aRatClFr[14]  * GW8->GW8_QTDE / aRatClFr[5], 2)
									GWM->GWM_VLISS2 := Round(aRatClFr[21] * GW8->GW8_QTDE / aRatClFr[5], 2)
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS2	:= NoRound(aRatClFr[15]  * GW8->GW8_QTDE / aRatClFr[11], 2)
										GWM->GWM_VLCOF2	:= NoRound(aRatClFr[16] * GW8->GW8_QTDE / aRatClFr[11], 2)
									Else
										GWM->GWM_VLPIS2	:= 0
										GWM->GWM_VLCOF2	:= 0
									EndIf	
									GWM->GWM_PEDAG2	:= Round(aRatClFr[22] * GW8->GW8_QTDE / aRatClFr[5], 2)

									If GFXCP2510('GWM_VLIBS2')	// Estadual
										GWM->GWM_VLIBS2 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM2')	// Municipal
										GWM->GWM_VLIBM2 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS2')
										GWM->GWM_VLCBS2 := 0
									EndIf
								EndIf

								GFERatLog(Space(7) + "Quantidade => Qtde item..: " + PadL(cValToChar(GW8->GW8_QTDE), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE2), 15) + " (" + cValToChar(GW8->GW8_QTDE / aRatClFr[5] * 100) + " %) [GWM_VLFRE2]")

							Else

								GWM->GWM_VLFRE2 := NoRound(aRatClFr[13] / aRatClFr[6], 2)
								If cTransp <> "1"
									GWM->GWM_VLICM2 := Round(aRatClFr[14]  / aRatClFr[6], 2)
									GWM->GWM_VLISS2 := Round(aRatClFr[21] / aRatClFr[6], 2)
									If GW8->GW8_TRIBP == "1"
										GWM->GWM_VLPIS2	:= NoRound(aRatClFr[15]  / aRatClFr[12], 2)
										GWM->GWM_VLCOF2 := NoRound(aRatClFr[16] / aRatClFr[12], 2)
									Else
										GWM->GWM_VLPIS2	:= 0
										GWM->GWM_VLCOF2	:= 0
									EndIf
									GWM->GWM_PEDAG2 := Round(aRatClFr[22] / aRatClFr[6], 2)

									If GFXCP2510('GWM_VLIBS2')	// Estadual
										GWM->GWM_VLIBS2 := 0
									EndIf
									If GFXCP2510('GWM_VLIBM2')	// Municipal
										GWM->GWM_VLIBM2 := 0
									EndIf
									If GFXCP2510('GWM_VLCBS2')
										GWM->GWM_VLCBS2 := 0
									EndIf
								EndIf
								
							    GFERatLog(Space(7) + "Quantidade => ** Peso zerado, usando o número de itens como critério de rateio")
							    GFERatLog(Space(7) + "Quantidade => Número de itens: " + PadL(cValToChar(aRatClFr[6]), 15) + ", Valor Rateado: " + PadL(cValToChar(GWM->GWM_VLFRE1), 15) + " (" + cValToChar(1 / aRatClFr[6] * 100) + " %) [GWM_VLFRE1]")
								
							EndIf
							
			    		// Ponto de Entrada NESTLE
						// alterar os totais
						If  s_GFEXFC03
							lRet :=  ExecBlock("GFEXFC03",.F.,.F.,{cTpDocto, retTotais})
						EndIf								
						GWM->( MsUnlock() )

						GFERatLog(Space(7) + "> " + STR0134 + cValToChar(GWM->GWM_VLICMS)) //"Valor ICMS...........: "
						GFERatLog(Space(7) + "> " + STR0135 + cValToChar(GWM->GWM_VLPIS )) //"Valor PIS............: "
						GFERatLog(Space(7) + "> " + STR0136 + cValToChar(GWM->GWM_VLCOFI)) //"Valor COFINS.........: "
						If GFXCP2510('GWM_VLIBS')	// Estadual
							GFERatLog(Space(7) + "> Valor IBS Estadual...: " + cValToChar(GWM->GWM_VLIBS))
						EndIf
						If GFXCP2510('GWM_VLIBM')	// Municipal
							GFERatLog(Space(7) + "> Valor IBS Municipal..: " + cValToChar(GWM->GWM_VLIBM))
						EndIf
						If GFXCP2510('GWM_VLCBS')
							GFERatLog(Space(7) + "> Valor CBS............: " + cValToChar(GWM->GWM_VLCBS))
						EndIf

					ElseIf cTpDocto == "3" //CONTRATO

						RecLock("GWM", .F.)

							//RATEIO POR PESO
							If aVlrFrete[1] != 0
								If aVlrFrete[1] >= aVlrFrete[2]
									/* retTotais[1] = Total Peso */
									GWM->GWM_VLFRET := Round(aRatClFr[13] * GW8->GW8_PESOR / aRatClFr[1], 2)
									GWM->GWM_VLINAU := Round(aRatClFr[17] * GW8->GW8_PESOR / aRatClFr[1], 2)
									GWM->GWM_VLINEM := Round(aRatClFr[18] * GW8->GW8_PESOR / aRatClFr[1], 2)
									GWM->GWM_VLSEST	:= Round(aRatClFr[19] * GW8->GW8_PESOR / aRatClFr[1], 2)
									GWM->GWM_VLIRRF	:= Round(aRatClFr[20] * GW8->GW8_PESOR / aRatClFr[1], 2)
									GWM->GWM_VLISS	:= Round(aRatClFr[21] * GW8->GW8_PESOR / aRatClFr[1], 2)
									If GFXCP2510('GWM_VLIBM')	// IBS Municipal
										GWM->GWM_VLIBM := 0
									EndIf

									GFERatLog(Space(7) + STR0126, .T.) //"Atualizando valores do rateio pelo Peso Real."
									GFERatLog(Space(7) + STR0127 + cValToChar(GW8->GW8_PESOR / aRatClFr[1] * 100) + " %") //"Percentual de rateio: "

								Else
									GWM->GWM_VLFRET := Round(aRatClFr[13] * GW8->GW8_PESOC / aRatClFr[2], 2)
									GWM->GWM_VLINAU := Round(aRatClFr[17] * GW8->GW8_PESOC / aRatClFr[2], 2)
									GWM->GWM_VLINEM := Round(aRatClFr[18] * GW8->GW8_PESOC / aRatClFr[2], 2)
									GWM->GWM_VLSEST	:= Round(aRatClFr[19] * GW8->GW8_PESOC / aRatClFr[2], 2)
									GWM->GWM_VLIRRF	:= Round(aRatClFr[20] * GW8->GW8_PESOC / aRatClFr[2], 2)
									GWM->GWM_VLISS	:= Round(aRatClFr[21] * GW8->GW8_PESOC / aRatClFr[2], 2)
									If GFXCP2510('GWM_VLIBM')	// IBS Municipal
										GWM->GWM_VLIBM := 0
									EndIf

									GFERatLog(Space(7) + STR0128, .T.) //"Atualizando valores do rateio pelo " ### "Peso " ### "Cubado."
									GFERatLog(Space(7) + STR0127 + cValToChar(GW8->GW8_PESOC / aRatClFr[2] * 100) + " %") //"Percentual de rateio: "

								EndIf
							Else
								GWM->GWM_VLFRET := Round(aRatClFr[13] / aRatClFr[6], 2)
								GWM->GWM_VLINAU := Round(aRatClFr[17] / aRatClFr[6], 2)
								GWM->GWM_VLINEM := Round(aRatClFr[18] / aRatClFr[6], 2)
								GWM->GWM_VLSEST := Round(aRatClFr[19] / aRatClFr[6], 2)
								GWM->GWM_VLIRRF := Round(aRatClFr[20] / aRatClFr[6], 2)
								GWM->GWM_VLISS  := Round(aRatClFr[21] / aRatClFr[6], 2)
								If GFXCP2510('GWM_VLIBM')	// IBS Municipal
									GWM->GWM_VLIBM := 0
								EndIf

								GFERatLog(Space(7) + "Total do peso é 0(zero)." + STR0129, .T.) //"Atualizando valores do rateio pelo " ### "Número de Itens."
							    GFERatLog(Space(7) + STR0127 + cValToChar(1 / aRatClFr[6] * 100) + " %") //"Percentual de rateio: "

							EndIf

							//RATEIO POR VALOR
							If aVlrFrete[3] != 0
								GWM->GWM_VLFRE1 := Round(aRatClFr[13] * GW8->GW8_VALOR / aRatClFr[3], 2)
								GWM->GWM_VLINA1 := Round(aRatClFr[17] * GW8->GW8_VALOR / aRatClFr[3], 2)
								GWM->GWM_VLINE1	:= Round(aRatClFr[18] * GW8->GW8_VALOR / aRatClFr[3], 2)
								GWM->GWM_VLSES1	:= Round(aRatClFr[19] * GW8->GW8_VALOR / aRatClFr[3], 2)
								GWM->GWM_VLIRR1	:= Round(aRatClFr[20] * GW8->GW8_VALOR / aRatClFr[3], 2)
								GWM->GWM_VLISS1	:= Round(aRatClFr[21] * GW8->GW8_VALOR / aRatClFr[3], 2)
								If GFXCP2510('GWM_VLIBM1')	// IBS Municipal
									GWM->GWM_VLIBM1 := 0
								EndIf

								GFERatLog(Space(7) + STR0130) //"Atualizando valores do rateio pelo " ### "Valor."
								GFERatLog(Space(7) + STR0127 + cValToChar(GW8->GW8_VALOR / aRatClFr[3] * 100) + " %") //"Percentual de rateio: "

							Else
								GWM->GWM_VLFRE1 := Round(aRatClFr[13] / aRatClFr[6], 2)
								GWM->GWM_VLINA1 := Round(aRatClFr[17] / aRatClFr[6], 2)
								GWM->GWM_VLINE1 := Round(aRatClFr[18] / aRatClFr[6], 2)
								GWM->GWM_VLSES1 := Round(aRatClFr[19] / aRatClFr[6], 2)
								GWM->GWM_VLIRR1 := Round(aRatClFr[20] / aRatClFr[6], 2)
								GWM->GWM_VLISS1 := Round(aRatClFr[21] / aRatClFr[6], 2)
								If GFXCP2510('GWM_VLIBM')	// IBS Municipal
									GWM->GWM_VLIBM := 0
								EndIf

								GFERatLog(Space(7) + "Total do valor é 0(zero)." + STR0129, .T.) //"Atualizando valores do rateio pelo " ### "Número de Itens."
							    GFERatLog(Space(7) + STR0127 + cValToChar(1 / aRatClFr[6] * 100) + " %") //"Percentual de rateio: "

							EndIf

							//RATEIO POR VOLUME
							If aVlrFrete[4] != 0
								GWM->GWM_VLFRE3 := Round(aRatClFr[13] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								GWM->GWM_VLINA3 := Round(aRatClFr[17] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								GWM->GWM_VLINE3	:= Round(aRatClFr[18] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								GWM->GWM_VLSES3	:= Round(aRatClFr[19] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								GWM->GWM_VLIRR3	:= Round(aRatClFr[20] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								GWM->GWM_VLISS3	:= Round(aRatClFr[21] * GW8->GW8_VOLUME / aRatClFr[4], 2)
								If GFXCP2510('GWM_VLIBM3')	// IBS Municipal
									GWM->GWM_VLIBM3 := 0
								EndIf

								GFERatLog(Space(7) + STR0131) //"Atualizando valores do rateio pelo " ### "Volume."
								GFERatLog(Space(7) + STR0127 + cValToChar(GW8->GW8_VOLUME / aRatClFr[4] * 100) + " %") //"Percentual de rateio: "

							Else
								GWM->GWM_VLFRE3 := Round(aRatClFr[13] / aRatClFr[6], 2)
								GWM->GWM_VLINA3 := Round(aRatClFr[17] / aRatClFr[6], 2)
								GWM->GWM_VLINE3 := Round(aRatClFr[18] / aRatClFr[6], 2)
								GWM->GWM_VLSES3 := Round(aRatClFr[19] / aRatClFr[6], 2)
								GWM->GWM_VLIRR3 := Round(aRatClFr[20] / aRatClFr[6], 2)
								GWM->GWM_VLISS3 := Round(aRatClFr[21] / aRatClFr[6], 2)
								If GFXCP2510('GWM_VLIBM3')	// IBS Municipal
									GWM->GWM_VLIBM3 := 0
								EndIf

								GFERatLog(Space(7) + "Total do volume é 0(zero)." + STR0129, .T.) //"Atualizando valores do rateio pelo " ### "Número de Itens."
							    GFERatLog(Space(7) + STR0127 + cValToChar(1 / aRatClFr[6] * 100) + " %") //"Percentual de rateio: "

							EndIf

							//RATEIO POR QUANTIDADE
							If aVlrFrete[5] != 0
								GWM->GWM_VLFRE2 := Round(aRatClFr[13] * GW8->GW8_QTDE / aRatClFr[5], 2)
								GWM->GWM_VLINA2 := Round(aRatClFr[17] * GW8->GW8_QTDE / aRatClFr[5], 2)
								GWM->GWM_VLINE2	:= Round(aRatClFr[18] * GW8->GW8_QTDE / aRatClFr[5], 2)
								GWM->GWM_VLSES2 := Round(aRatClFr[19] * GW8->GW8_QTDE / aRatClFr[5], 2)
								GWM->GWM_VLIRR2 := Round(aRatClFr[20] * GW8->GW8_QTDE / aRatClFr[5], 2)
								GWM->GWM_VLISS2	:= Round(aRatClFr[21] * GW8->GW8_QTDE / aRatClFr[5], 2)
								If GFXCP2510('GWM_VLIBM2')	// IBS Municipal
									GWM->GWM_VLIBM2 := 0
								EndIf

								GFERatLog(Space(7) + STR0132) //"Atualizando valores do rateio pela " ### "Quantidade."
								GFERatLog(Space(7) + STR0127 + cValToChar(GW8->GW8_QTDE / aRatClFr[5] * 100) + " %") //"Percentual de rateio: "

							Else
								GWM->GWM_VLFRE2 := Round(aRatClFr[13]  / aRatClFr[6], 2)
								GWM->GWM_VLINA2 := Round(aRatClFr[17] / aRatClFr[6], 2)
								GWM->GWM_VLINE2 := Round(aRatClFr[18] / aRatClFr[6], 2)
								GWM->GWM_VLSES2 := Round(aRatClFr[19] / aRatClFr[6], 2)
								GWM->GWM_VLIRR2 := Round(aRatClFr[20] / aRatClFr[6], 2)
								GWM->GWM_VLISS2 := Round(aRatClFr[21] / aRatClFr[6], 2)
								If GFXCP2510('GWM_VLIBM2')	// IBS Municipal
									GWM->GWM_VLIBM2 := 0
								EndIf

								GFERatLog(Space(7) + "Total da quantidade é 0(zero)." + STR0129, .T.) //"Atualizando valores do rateio pelo " ### "Número de Itens."
							    GFERatLog(Space(7) + STR0127 + cValToChar(1 / aRatClFr[6] * 100) + " %") //"Percentual de rateio: "

							EndIf

							dbSelectArea("GUS")
							dbSetOrder(1)
							If dbSeek(xFilial("GUS") + GWM->GWM_FILIAL)
								cCntaFrtPg := GUS->GUS_CTFRET
								cCCusFrtPg := GUS->GUS_CCFRET
							Else
								cCntaFrtPg := ""
								cCCusFrtPg := ""
							EndIf

							// Contas Contábeis
							GWM->GWM_CTINAU := cCntaFrtPg
							GWM->GWM_CTSEST := cCntaFrtPg
							GWM->GWM_CTIRRF := cCntaFrtPg
							GWM->GWM_CTISS  := cCntaFrtPg

							// Centro de Custo
							GWM->GWM_CCINAU := cCCusFrtPg
							GWM->GWM_CCSEST := cCCusFrtPg
							GWM->GWM_CCIRRF := cCCusFrtPg
							GWM->GWM_CCISS  := cCCusFrtPg

						GWM->( MsUnLock() )

					EndIf

					GFERatLog(Space(3) + "----------------------------------------------------------------")

				EndIf
				
				If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
					If FindFunction("AGRGFE003") .And. GWM->GWM_TPDOC == "2"
				
						aCriaRAt := GFEGetRatVal(s_CRIRAT)
			
						nVlICMS := aCriaRAt[1]
						nVlPis := aCriaRAt[2]
						nVlCofi := aCriaRAt[3]
						nValorFrt := aCriaRAt[4]					
					
						If (nPos := AScan(aDadosAgro, {|x| x[1] == GWM->GWM_FILIAL;
                              							.And. x[2] == GWM->GWM_TPDOC;
							  							.And. x[3] == GWM->GWM_EMISDC;
							  							.And. x[4] == GWM->GWM_SERDC;
							  							.And. x[5] == GWM->GWM_NRDC}) ) != 0
							aDadosAgro[nPos][7] += nVlICMS
							aDadosAgro[nPos][8] += nVlPis
							aDadosAgro[nPos][9] += nVlCofi
							aDadosAgro[nPos][10] += nValorFrt
							aDadosAgro[nPos][11] += "C" /*Create*/
						
						Else
							GW1->( dbSetOrder(1) )
							If GW1->( dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC))
								cCGCCliente := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_IDFED")
							EndIf
					
							aAdd(aDadosAgro,{GWM->GWM_FILIAL,;
											GWM->GWM_TPDOC,;
											GWM->GWM_EMISDC,;
											GWM->GWM_SERDC,;
											GWM->GWM_NRDC,;
											cCGCCliente,;
											nVlICMS,;
											nVlPis,;
											nVlCofi,;
											nValorFrt,;
											"C" /*Create*/ })
						EndIf
					
					EndIf
				Endif

				// Contrato de Frete
				IF !Empty(cNrCt)

					If s_CRIRAT == "1" 
						nValorFrt := GWM->GWM_VLFRET
					ElseIf s_CRIRAT == "2"
						nValorFrt := GWM->GWM_VLFRE1
					ElseIf s_CRIRAT == "3"
						nValorFrt := GWM->GWM_VLFRE3
					ElseIf s_CRIRAT == "4"
						nValorFrt := GWM->GWM_VLFRE2
					EndIf				

					If (nPos := AScan(aDadosCT, {|x| x[1] == GWM->GWM_FILIAL;
                              						.And. x[2] == GWM->GWM_TPDOC;
							  						.And. x[3] == GWM->GWM_CDESP;
							  						.And. x[4] == GWM->GWM_CDTRP;
							  						.And. x[5] == GWM->GWM_SERDOC;
							  						.And. x[6] == GWM->GWM_NRDOC;
							  						.And. x[7] == GWM->GWM_DTEMIS;							  						
							  						.And. x[8] == cNrCt}) ) != 0

						aDadosCT[nPos][9] += nValorFrt
					Else
						aAdd(aDadosCT,{GWM->GWM_FILIAL,;
										GWM->GWM_TPDOC,;
										GWM->GWM_CDESP,;
										GWM->GWM_CDTRP,;
										GWM->GWM_SERDOC,;										
										GWM->GWM_NRDOC,;
										GWM->GWM_DTEMIS,;
										cNrCt,;										
										nValorFrt})
					EndIf
				
				endif 					

				GW8->( dbSkip() )
	    	EndDo	// Item do documento de carga
	   	EndIf
	   	dbSelectArea(Tab)
	   	dbSkip()
	EndDo
	
	If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
		If FindFunction("AGRGFE003") .And. !Empty(aDadosAgro)
			AGRGFE003(aDadosAgro)
		EndIf
	EndIf
		
	IF !Empty(cNrCt)
		GFEXCTFR(aDadosCT)
	endif
	

	If !Empty(cDCSemCta)
		If lCusto
			cDCSemCta := "Não foi encontrado cadastro de contas por filial, ou a conta Transitória de Fornecedor não foi informada." + CRLF + CRLF + ;
						 "Solução: Verifique se há cadastro de conta para a filial do documento e se a conta Transitória de Fornecedor foi preenchida." + ;
						 cDCSemCta
		Else
			cDCSemCta := "Não foi possível encontrar uma conta para rateio que atendesse aos grupos contábeis." + CRLF + CRLF + ;
						 "Solução: Verifique se há uma conta para rateio cadastrada compatível com os valores dos Documentos de Carga e Itens do Documento." + ;
						 cDCSemCta
		EndIf
		
		aRetRateio[2] := cDCSemCta
		
		If !IsBlind() .And. (SuperGetMv("MV_TPGERA",,"1") == "1" .OR. (SuperGetMv("MV_TPGERA",,"1") == "2" .AND. lBatch)) .And. cAcGrRat == "1" 

			DEFINE MSDIALOG oDlg TITLE "Rateios sem Conta Contábil" From 0,0 To 18,70 OF oMainWnd
				@ 4, 006 SAY {"Cálculo: ", "Documento de Frete: ", "Contrato: ", "Estimativa:"}[Val(cTpDocto)] + nNrDoc SIZE 130,7 PIXEL OF oDlg

			    oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cDCSemCta:=u,cDCSemCta)},;
			                           oDlg,265,105,,,,,,.T.,,,,,,.T.)

				oButtonOK   := tButton():New(125,5,'OK',oDlg,{|| oDlg:End()},25,10,,,,.T.)
			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	EndIf

    GFERatLog(STR0137, .T.) //"4. Atualização dos percentuais"

    For nI := 1 to Len(GWMTmp)
    	dbSelectArea("GWM")
		dbGoTo(GWMTmp[nI])

		RecLock("GWM", .F.)
			GWM->GWM_PCRAT := Round(GFEGetRatVal(s_CRIRAT)[4] * 100 / aVlrFrete[13], 2)
			GFERatLog(Space(3) + "> Seq: " + GWM->GWM_SEQGW8 + ", Percentual de Rateio: " + cValToChar(GWM->GWM_PCRAT))
			
			nTPntPc	+= GWM->GWM_PCRAT

			//Totaliza Peso
			nTDesp[1]	 += GWM->GWM_VLFRET
			nTICMS[1]	 += GWM->GWM_VLICMS
			nTPIS[1]     += GWM->GWM_VLPIS
			nTCOFINS[1]  += GWM->GWM_VLCOFI
			nTINSSAut[1] += GWM->GWM_VLINAU /* INSS Autonomo */
			nTINSSEmp[1] += GWM->GWM_VLINEM /* INSS Empresa  */
			nTSESSEN[1]  += GWM->GWM_VLSEST /* SEST / SENAT */
			nTIRRF[1]	 += GWM->GWM_VLIRRF /* IRRF */
			nTISS[1]     += GWM->GWM_VLISS  /* ISS*/
			nTPedagio[1] += GWM->GWM_PEDAG  /* Pedágio */
			nTIBS[1] 	 += Iif(GFXCP2510('GWM_VLIBS'), GWM->GWM_VLIBS, 0) 	// IBS Estadual
			nTIBSM[1] 	 += Iif(GFXCP2510('GWM_VLIBM'), GWM->GWM_VLIBM, 0)	// IBS Municipal
			nTCBS[1] 	 += Iif(GFXCP2510('GWM_VLCBS'), GWM->GWM_VLCBS, 0)  // CBS

			//Totaliza Valor
			nTDesp[2]	 += GWM->GWM_VLFRE1
			nTICMS[2]	 += GWM->GWM_VLICM1
			nTPIS[2]     += GWM->GWM_VLPIS1
			nTCOFINS[2]  += GWM->GWM_VLCOF1
			nTINSSAut[2] += GWM->GWM_VLINA1 /* INSS Autonomo */
			nTINSSEmp[2] += GWM->GWM_VLINE1 /* INSS Empresa  */
			nTSESSEN[2]  += GWM->GWM_VLSES1 /* SEST / SENAT */
			nTIRRF[2]	 += GWM->GWM_VLIRR1 /* IRRF */
			nTISS[2]     += GWM->GWM_VLISS1  /* ISS*/
			nTPedagio[2] += GWM->GWM_PEDAG1  /* Pedágio */
			nTIBS[2] 	 += Iif(GFXCP2510('GWM_VLIBS1'), GWM->GWM_VLIBS1, 0) 	// IBS Estadual
			nTIBSM[2] 	 += Iif(GFXCP2510('GWM_VLIBM1'), GWM->GWM_VLIBM1, 0)	// IBS Municipal
			nTCBS[2] 	 += Iif(GFXCP2510('GWM_VLCBS1'), GWM->GWM_VLCBS1, 0)  	// CBS

			//Totaliza Quantidade
			nTDesp[3]	 += GWM->GWM_VLFRE2
			nTICMS[3]	 += GWM->GWM_VLICM2
			nTPIS[3]     += GWM->GWM_VLPIS2
			nTCOFINS[3]  += GWM->GWM_VLCOF2
			nTINSSAut[3] += GWM->GWM_VLINA2 /* INSS Autonomo */
			nTINSSEmp[3] += GWM->GWM_VLINE2 /* INSS Empresa  */
			nTSESSEN[3]  += GWM->GWM_VLSES2 /* SEST / SENAT */
			nTIRRF[3]	 += GWM->GWM_VLIRR2 /* IRRF */
			nTISS[3]     += GWM->GWM_VLISS2 /* ISS*/
			nTPedagio[3] += GWM->GWM_PEDAG2  /* Pedágio */
			nTIBS[3] 	 += Iif(GFXCP2510('GWM_VLIBS2'), GWM->GWM_VLIBS2, 0) 	// IBS Estadual
			nTIBSM[3] 	 += Iif(GFXCP2510('GWM_VLIBM2'), GWM->GWM_VLIBM2, 0)	// IBS Municipal
			nTCBS[3] 	 += Iif(GFXCP2510('GWM_VLCBS2'), GWM->GWM_VLCBS2, 0)  	// CBS

			//Totaliza Volume
			nTDesp[4]	 += GWM->GWM_VLFRE3
			nTICMS[4]	 += GWM->GWM_VLICM3
			nTPIS[4]     += GWM->GWM_VLPIS3
			nTCOFINS[4]  += GWM->GWM_VLCOF3
			nTINSSAut[4] += GWM->GWM_VLINA3 /* INSS Autonomo */
			nTINSSEmp[4] += GWM->GWM_VLINE3 /* INSS Empresa  */
			nTSESSEN[4]  += GWM->GWM_VLSES3 /* SEST / SENAT */
			nTIRRF[4]	 += GWM->GWM_VLIRR3 /* IRRF */
			nTISS[4]     += GWM->GWM_VLISS3 /* ISS*/
			nTPedagio[4] += GWM->GWM_PEDAG3  /* Pedágio */
			nTIBS[4] 	 += Iif(GFXCP2510('GWM_VLIBS3'), GWM->GWM_VLIBS3, 0) 	// IBS Estadual
			nTIBSM[4] 	 += Iif(GFXCP2510('GWM_VLIBM3'), GWM->GWM_VLIBM3, 0)	// IBS Municipal
			nTCBS[4] 	 += Iif(GFXCP2510('GWM_VLCBS3'), GWM->GWM_VLCBS3, 0)  	// CBS

			If GWM->GWM_PCRAT >= nPcMaior
				nPcMaior   := GWM->GWM_PCRAT
				recPcMaior := GWM->(Recno())
			EndIf

			dbSelectArea("GW8")
			dbSetOrder(2)
			If GW8->(dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC+GWM->GWM_SEQGW8))
				If GWM->GWM_PCRAT >= nPcMaiorPC .AND. GW8->GW8_TRIBP == "1"
					//Verifica se o último registro tributa PIS e COFINS
					nPcMaiorPC := GWM->GWM_PCRAT
					recPcPisCo := GWM->(Recno())
				EndIf
			EndIF
			
		GWM->( MsUnlock() )
    Next nI
    
    GFERatLog("5. Arredondamento e tratamento de valor residual", .T.)
    GFERatLog("    > Rateio escolhido:")
    GFERatLog("    > Valor de Frete: RecNo: " + cValToChar(recPcMaior))
    GFERatLog("    > PIS/COF        : RecNo: " + cValToChar(recPcPisCo))
    
	/* Ajustar arredondamento dos valores e do percentual de ICMS, PIS e COFINS */
	If recPcPisCo != 0
		dbSelectArea("GWM")
		dbGoTo(recPcPisCo)
		
		GFERatLog(Space(3) + "Arredondamentos ICMS, PIS e COFINS")
		GFERatLog(Space(3) + "> GWM | Item: " + GWM->GWM_ITEM + ", Seq: " + GWM->GWM_SEQGW8 + ", RecNo: " + cValToChar(recPcPisCo))

		RecLock("GWM", .F.)		
		//---Impostos
		If cTpDocto $ "1;2;4"
			If cTransp <> "1"
				//---PIS

				// Peso
				If nTPIS[1] != aVlrFrete[15]
					GFERatLog(Space(5) + "> PIS Peso | Calculado: " + cValToChar(nTPIS[1]) + ", Total: " + cValToChar(aVlrFrete[15]))
					GWM->GWM_VLPIS := GWM->GWM_VLPIS - (nTPIS[1] - aVlrFrete[15])
				EndIf
	
				// Valor
				If nTPIS[2] != aVlrFrete[15]
					GFERatLog(Space(5) + "> PIS Valor | Calculado: " + cValToChar(nTPIS[2]) + ", Total: " + cValToChar(aVlrFrete[15]))
					GWM->GWM_VLPIS1 := GWM->GWM_VLPIS1 - (nTPIS[2] - aVlrFrete[15])
				EndIf
	
				// Quantidade
				If nTPIS[3] != aVlrFrete[15]
					GFERatLog(Space(5) + "> PIS Qtde | Calculado: " + cValToChar(nTPIS[3]) + ", Total: " + cValToChar(aVlrFrete[15]))
					GWM->GWM_VLPIS2 := GWM->GWM_VLPIS2 - (nTPIS[3] - aVlrFrete[15])
				EndIf
	
				// Volume
				If nTPIS[4] != aVlrFrete[15]
					GFERatLog(Space(5) + "> PIS Volume | Calculado: " + cValToChar(nTPIS[4]) + ", Total: " + cValToChar(aVlrFrete[15]))
					GWM->GWM_VLPIS3 := GWM->GWM_VLPIS3 - (nTPIS[4] - aVlrFrete[15])
				EndIf
	
				//---COFINS
	
				// Peso
				If nTCOFINS[1] != aVlrFrete[16]
					GFERatLog(Space(5) + "> COFINS Peso | Calculado: " + cValToChar(nTCOFINS[1]) + ", Total: " + cValToChar(aVlrFrete[16]))
					GWM->GWM_VLCOFI := GWM->GWM_VLCOFI - (nTCOFINS[1] - aVlrFrete[16])
				EndIf
	
				// Valor
				If nTCOFINS[2] != aVlrFrete[16]
					GFERatLog(Space(5) + "> COFINS Valor | Calculado: " + cValToChar(nTCOFINS[2]) + ", Total: " + cValToChar(aVlrFrete[16]))
					GWM->GWM_VLCOF1 := GWM->GWM_VLCOF1 - (nTCOFINS[2] - aVlrFrete[16])
				EndIf
	
				// 	Quantidade
				If nTCOFINS[3] != aVlrFrete[16]
					GFERatLog(Space(5) + "> COFINS Qtde | Calculado: " + cValToChar(nTCOFINS[3]) + ", Total: " + cValToChar(aVlrFrete[16]))
					GWM->GWM_VLCOF2 := GWM->GWM_VLCOF2 - (nTCOFINS[3] - aVlrFrete[16])
				EndIf
	
				// Volume
				If nTCOFINS[4] != aVlrFrete[16]
					GFERatLog(Space(5) + "> COFINS Volume | Calculado: " + cValToChar(nTCOFINS[4]) + ", Total: " + cValToChar(aVlrFrete[16]))
					GWM->GWM_VLCOF3 := GWM->GWM_VLCOF3 - (nTCOFINS[4] - aVlrFrete[16])
				EndIf
	
			EndIf
		EndIf
		GWM->( MsUnlock() )
	EndIf
	
	If recPcMaior != 0
		dbSelectArea("GWM")
		dbGoTo(recPcMaior)
		
		GFERatLog(Space(3) + "Arredondamentos Valor do Frete")
		GFERatLog(Space(3) + "> GWM | Item: " + GWM->GWM_ITEM + ", Seq: " + GWM->GWM_SEQGW8 + ", RecNo: " + cValToChar(recPcMaior))
		

		RecLock("GWM", .F.)
			//---Valor do Frete

			// Peso
			If nTDesp[1] != aVlrFrete[13]
				GFERatLog(Space(5) + "> FRETE Peso | Calculado: " + cValToChar(nTDesp[1]) + ", Total: " + cValToChar(aVlrFrete[13]))
				GWM->GWM_VLFRET := GWM_VLFRET - (nTDesp[1] - aVlrFrete[13])
			EndIf

			// Valor
			If nTDesp[2] != aVlrFrete[13]
				GFERatLog(Space(5) + "> FRETE Valor | Calculado: " + cValToChar(nTDesp[2]) + ", Total: " + cValToChar(aVlrFrete[13]))
				GWM->GWM_VLFRE1 := GWM_VLFRE1 - (nTDesp[2] - aVlrFrete[13])
			EndIf

			// Quantidade
			If nTDesp[3] != aVlrFrete[13]
				GFERatLog(Space(5) + "> FRETE Qtde | Calculado: " + cValToChar(nTDesp[3]) + ", Total: " + cValToChar(aVlrFrete[13]))
				GWM->GWM_VLFRE2 := GWM_VLFRE2 - (nTDesp[3] - aVlrFrete[13])
			EndIf

			// Volume
			If nTDesp[4] != aVlrFrete[13]
				GFERatLog(Space(5) + "> FRETE Qtde | Calculado: " + cValToChar(nTDesp[4]) + ", Total: " + cValToChar(aVlrFrete[13]))
				GWM->GWM_VLFRE3 := GWM_VLFRE3 - (nTDesp[4] - aVlrFrete[13])
			EndIf

			//---Percentual de rateio

			If nTPntPc != 100
				GFERatLog(Space(5) + "> FRETE % | Calculado: " + cValToChar(nTPntPc) + "%  (Arredondado para 100%)")
				GWM->GWM_PCRAT := GWM_PCRAT - (nTPntPc - 100)
			EndIf

			//---Impostos

			//---ISS

			// Peso
			If nTISS[1] != aVlrFrete[21]
				GFERatLog(Space(5) + "> ISS Peso | Calculado: " + cValToChar(nTISS[1]) + ", Total: " + cValToChar(aVlrFrete[21]))
				GWM->GWM_VLISS := GWM->GWM_VLISS - (nTISS[1] - aVlrFrete[21])
			EndIf

			// Valor
			If nTISS[2] != aVlrFrete[21]
				GFERatLog(Space(5) + "> ISS Valor | Calculado: " + cValToChar(nTISS[2]) + ", Total: " + cValToChar(aVlrFrete[21]))
				GWM->GWM_VLISS1 := GWM->GWM_VLISS1 - (nTISS[2] - aVlrFrete[21])
			EndIf

			// Quantidade
			If nTISS[3] != aVlrFrete[21]
				GFERatLog(Space(5) + "> ISS Qtde | Calculado: " + cValToChar(nTISS[3]) + ", Total: " + cValToChar(aVlrFrete[21]))
				GWM->GWM_VLISS2 := GWM->GWM_VLISS2 - (nTISS[3] - aVlrFrete[21])
			EndIf

			// Volume
			If nTISS[4] != aVlrFrete[21]
				GFERatLog(Space(5) + "> ISS Volume | Calculado: " + cValToChar(nTISS[4]) + ", Total: " + cValToChar(aVlrFrete[21]))
				GWM->GWM_VLISS3 := GWM->GWM_VLISS3 - (nTISS[4] - aVlrFrete[21])
			EndIf

			If cTpDocto $ "1;2;4"

				If cTransp <> "1"

					//---ICMS

					// Peso
					If nTICMS[1] != aVlrFrete[14]
						GFERatLog(Space(5) + "> ICMS Peso | Calculado: " + cValToChar(nTICMS[1]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLICMS := GWM->GWM_VLICMS - (nTICMS[1] - aVlrFrete[14])
					EndIf

					// Valor
					If nTICMS[2] != aVlrFrete[14]
						GFERatLog(Space(5) + "> ICMS Valor | Calculado: " + cValToChar(nTICMS[2]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLICM1 := GWM->GWM_VLICM1 - (nTICMS[2] - aVlrFrete[14])
					EndIf

					// Quantidade
					If nTICMS[3] != aVlrFrete[14]
						GFERatLog(Space(5) + "> ICMS Qtde | Calculado: " + cValToChar(nTICMS[3]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLICM2 := GWM->GWM_VLICM2 - (nTICMS[3] - aVlrFrete[14])
					EndIf

					// Volume
					If nTICMS[4] != aVlrFrete[14]
						GFERatLog(Space(5) + "> ICMS Volume | Calculado: " + cValToChar(nTICMS[4]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLICM3 := GWM->GWM_VLICM3 - (nTICMS[4] - aVlrFrete[14])
					EndIf


					//---IBS
					// Peso
					If GFXCP2510('GWM_VLIBS') .And. nTIBS[1] != aVlrFrete[14]
						GFERatLog(Space(5) + "> IBS Peso | Calculado: " + cValToChar(nTIBS[1]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLIBS := GWM->GWM_VLIBS - (nTIBS[1] - aVlrFrete[14])
					EndIf

					// Valor
					If GFXCP2510('GWM_VLIBS1') .And. nTIBS[2] != aVlrFrete[14]
						GFERatLog(Space(5) + "> IBS Valor | Calculado: " + cValToChar(nTIBS[2]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLIBS1 := GWM->GWM_VLIBS1 - (nTIBS[2] - aVlrFrete[14])
					EndIf

					// Quantidade
					If GFXCP2510('GWM_VLIBS2') .And. nTIBS[3] != aVlrFrete[14]
						GFERatLog(Space(5) + "> IBS Qtde | Calculado: " + cValToChar(nTIBS[3]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLIBS2 := GWM->GWM_VLIBS2 - (nTIBS[3] - aVlrFrete[14])
					EndIf

					// Volume
					If GFXCP2510('GWM_VLIBS3') .And. nTIBS[4] != aVlrFrete[14]
						GFERatLog(Space(5) + "> IBS Volume | Calculado: " + cValToChar(nTIBS[4]) + ", Total: " + cValToChar(aVlrFrete[14]))
						GWM->GWM_VLIBS3 := GWM->GWM_VLIBS3 - (nTIBS[4] - aVlrFrete[14])
					EndIf

				EndIf

			ElseIf cTpDocto == "3"

				//---INSS Autonomo

				// Peso
				If nTInssAut[1] != aVlrFrete[17]
					GFERatLog(Space(5) + "> INSS Autonomo Peso | Calculado: " + cValToChar(nTINSSAut[1]) + ", Total: " + cValToChar(aVlrFrete[17]))
					GWM->GWM_VLINAU := GWM->GWM_VLINAU - (nTINSSAut[1] - aVlrFrete[17])
				EndIf

				// Valor
				If nTInssAut[2] != aVlrFrete[17]
					GFERatLog(Space(5) + "> INSS Autonomo Valor | Calculado: " + cValToChar(nTINSSAut[2]) + ", Total: " + cValToChar(aVlrFrete[17]))
					GWM->GWM_VLINA1 := GWM->GWM_VLINA1 - (nTINSSAut[2] - aVlrFrete[17])
				EndIf

				// Quantidade
				If nTInssAut[3] != aVlrFrete[17]
					GFERatLog(Space(5) + "> INSS Autonomo Qtde | Calculado: " + cValToChar(nTINSSAut[3]) + ", Total: " + cValToChar(aVlrFrete[17]))
					GWM->GWM_VLINA2 := GWM->GWM_VLINA2 - (nTINSSAut[3] - aVlrFrete[17])
				EndIf

				// Volume
				If nTInssAut[4] != aVlrFrete[17]
					GFERatLog(Space(5) + "> INSS Autonomo Volume | Calculado: " + cValToChar(nTINSSAut[4]) + ", Total: " + cValToChar(aVlrFrete[17]))
					GWM->GWM_VLINA3 := GWM->GWM_VLINA3 - (nTINSSAut[4] - aVlrFrete[17])
				EndIf

				//---INSS Embarcador

				// Peso
				If nTInssEmp[1] != aVlrFrete[18]
					GFERatLog(Space(5) + "> INSS Embarcador Peso | Calculado: " + cValToChar(nTINSSEmp[1]) + ", Total: " + cValToChar(aVlrFrete[18]))
					GWM->GWM_VLINEM := GWM->GWM_VLINEM - (nTINSSEmp[1] - aVlrFrete[18])
				EndIf

				// Valor
				If nTInssEmp[2] != aVlrFrete[18]
					GFERatLog(Space(5) + "> INSS Embarcador Valor | Calculado: " + cValToChar(nTINSSEmp[2]) + ", Total: " + cValToChar(aVlrFrete[18]))
					GWM->GWM_VLINE1 := GWM->GWM_VLINE1 - (nTINSSEmp[2] - aVlrFrete[18])
				EndIf

				// Quantidade
				If nTInssEmp[3] != aVlrFrete[18]
					GFERatLog(Space(5) + "> INSS Embarcador Qtde | Calculado: " + cValToChar(nTINSSEmp[3]) + ", Total: " + cValToChar(aVlrFrete[18]))
					GWM->GWM_VLINE2 := GWM->GWM_VLINE2 - (nTINSSEmp[3] - aVlrFrete[18])
				EndIf

				// Volume
				If nTInssEmp[4] != aVlrFrete[18]
					GFERatLog(Space(5) + "> INSS Embarcador Volume | Calculado: " + cValToChar(nTINSSEmp[4]) + ", Total: " + cValToChar(aVlrFrete[18]))
					GWM->GWM_VLINE3 := GWM->GWM_VLINE3 - (nTINSSEmp[4] - aVlrFrete[18])
				EndIf

				//---SEST/SENAT

				// Peso
				If nTSESSEN[1] != aVlrFrete[19]
					GFERatLog(Space(5) + "> SEST/SENAT Peso | Calculado: " + cValToChar(nTSESSEN[1]) + ", Total: " + cValToChar(aVlrFrete[19]))
					GWM->GWM_VLSEST := GWM->GWM_VLSEST - (nTSESSEN[1] - aVlrFrete[19])
				EndIf

				// Valor
				If nTSESSEN[2] != aVlrFrete[19]
					GFERatLog(Space(5) + "> SEST/SENAT Valor | Calculado: " + cValToChar(nTSESSEN[2]) + ", Total: " + cValToChar(aVlrFrete[19]))
					GWM->GWM_VLSES1 := GWM->GWM_VLSES1 - (nTSESSEN[2] - aVlrFrete[19])
				EndIf

				// Quantidade
				If nTSESSEN[3] != aVlrFrete[19]
					GFERatLog(Space(5) + "> SEST/SENAT Qtde | Calculado: " + cValToChar(nTSESSEN[3]) + ", Total: " + cValToChar(aVlrFrete[19]))
					GWM->GWM_VLSES2 := GWM->GWM_VLSES2 - (nTSESSEN[3] - aVlrFrete[19])
				EndIf

				// Volume
				If nTSESSEN[4] != aVlrFrete[19]
					GFERatLog(Space(5) + "> SEST/SENAT Volume | Calculado: " + cValToChar(nTSESSEN[4]) + ", Total: " + cValToChar(aVlrFrete[19]))
					GWM->GWM_VLSES3 := GWM->GWM_VLSES3 - (nTSESSEN[4] - aVlrFrete[19])
				EndIf

				//---IRRF

				// Peso
				If nTIRRF[1] != aVlrFrete[20]
					GFERatLog(Space(5) + "> SEST/SENAT Peso | Calculado: " + cValToChar(nTIRRF[1]) + ", Total: " + cValToChar(aVlrFrete[20]))
					GWM->GWM_VLIRRF := GWM->GWM_VLIRRF - (nTIRRF[1] - aVlrFrete[20])
				EndIf

				// Valor
				If nTIRRF[2] != aVlrFrete[20]
					GFERatLog(Space(5) + "> SEST/SENAT Valor | Calculado: " + cValToChar(nTIRRF[2]) + ", Total: " + cValToChar(aVlrFrete[20]))
					GWM->GWM_VLIRR1 := GWM->GWM_VLIRR1 - (nTIRRF[2] - aVlrFrete[20])
				EndIf

				// Quantidade
				If nTIRRF[3] != aVlrFrete[20]
					GFERatLog(Space(5) + "> SEST/SENAT Qtde | Calculado: " + cValToChar(nTIRRF[3]) + ", Total: " + cValToChar(aVlrFrete[20]))
					GWM->GWM_VLIRR2 := GWM->GWM_VLIRR2 - (nTIRRF[3] - aVlrFrete[20])
				EndIf

				// Volume
				If nTIRRF[4] != aVlrFrete[20]
					GFERatLog(Space(5) + "> SEST/SENAT Volume | Calculado: " + cValToChar(nTIRRF[4]) + ", Total: " + cValToChar(aVlrFrete[20]))
					GWM->GWM_VLIRR3 := GWM->GWM_VLIRR3 - (nTIRRF[4] - aVlrFrete[20])
				EndIf

			EndIf

			//---Pedágio
			// Peso
			If nTPedagio[1] != aVlrFrete[22]
				GFERatLog(Space(5) + "> PEDAGIO Peso | Calculado: " + cValToChar(nTPedagio[1]) + ", Total: " + cValToChar(aVlrFrete[22]))
				GWM->GWM_PEDAG -= (nTPedagio[1] - aVlrFrete[22])
			EndIf

			// Valor
			If nTPedagio[2] != aVlrFrete[22]
				GFERatLog(Space(5) + "> PEDAGIO Valor | Calculado: " + cValToChar(nTPedagio[2]) + ", Total: " + cValToChar(aVlrFrete[22]))
				GWM->GWM_PEDAG1 -= (nTPedagio[2] - aVlrFrete[22])
			EndIf

			// Quantidade
			If nTPedagio[3] != aVlrFrete[22]
				GFERatLog(Space(5) + "> PEDAGIO Qtde | Calculado: " + cValToChar(nTPedagio[3]) + ", Total: " + cValToChar(aVlrFrete[22]))
				GWM->GWM_PEDAG2 -= (nTPedagio[3] - aVlrFrete[22])
			EndIf

			// Volume
			If nTPedagio[4] != aVlrFrete[22]
				GFERatLog(Space(5) + "> PEDAGIO Qtde | Calculado: " + cValToChar(nTPedagio[4]) + ", Total: " + cValToChar(aVlrFrete[22]))
				GWM->GWM_PEDAG3 -= (nTPedagio[4] - aVlrFrete[22])
			EndIf

		GWM->( MsUnlock() )

	EndIf
	
	For nI := 1 to Len(GWMTmp)
    	
		dbselectarea("GWM")
		dbGoTo(GWMTmp[nI])
		
		//Posicionar GW8 para ver se o Item credita ICMS.
		GW8->( dbSetOrder(2) )
		GW8->( dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDTPDC+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC+GWM->GWM_SEQGW8 ))
		
		If cFormCredICMS == "2" .And. GW8->GW8_CRDICM == "2"
			Reclock("GWM", .F.)
				GWM->GWM_VLICMS := 0
				GWM->GWM_VLICM1 := 0
				GWM->GWM_VLICM2 := 0
				GWM->GWM_VLICM3 := 0
			GWM->( MsUnlock() )
			GFERatLog(Space(7) + "Quantidade => Valor ICMS: Rateio zerado devido ao crédito parcial de ICMS.", .T.) // Auxílio referente ao crédito parcial de ICMS
		EndIf
		
	Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEGerMvCt
Geração dos movimentos contábeis

@param cTpDocto	Tipo do Documento a ser contabilizado
@param cCdEsp	Espécie
@param cCdEmit  Emitente
@param cSerie	Série
@param cNrDoc   Número do Documento
@param dDtEmis	Data de Emissão
@param cAliasTab Alias da Tabela temporária
@param lBatch	Modo Batch?
@param lCusto	Utiliza centro de custo?


@retorno Sucesso/falha contabilização


@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEGerMvCt(cTpDocto, cCdEsp, cCdEmit, cSerie, cNrDoc, dDtEmis, cAliasTab, lBatch, lCusto, cFil)
	Local cRecno := 0, iCont := 0
	Local lRet   := .T.
	Private nSeq100 := -1

	Private nSeq300 := -1
	Private nSeq301 := -1
	Private nSeq302 := -1
	Private nSeq303 := -1

	Private nSeq310 := -1
	Private nSeq311 := -1
	Private nSeq312 := -1
	Private nSeq313 := -1		
	
	
	SetProcess("Gerando movimentos contábeis (3/3)", nCountGW1)
	
	GFERatLog(STR0140, .T.) //"6. Geração dos Movimentos contábeis"

	GFERatLog(Space(3) + "6.1 " + STR0141,.T.) //"Eliminando movimentos existentes"
	
	// Eliminar os movimentos contábeis existentes para o documento
	
	
	dbSelectArea("GWA")
	dbSetOrder(1)
	If dbSeek(cFil+cTpDocto+cCdEsp+cCdEmit+cSerie+cNrDoc+DTOS(dDtEmis))
		While !Eof() .AND.;
			GWA->GWA_FILIAL       == cFil .AND.;
			GWA->GWA_TPDOC        == cTpDocto .AND.;
			GWA->GWA_CDESP        == cCdEsp   .AND.;
			GWA->GWA_CDEMIT       == cCdEmit  .AND.;
			GWA->GWA_SERIE        == cSerie   .AND.;
			GWA->GWA_NRDOC        == cNrDoc   .AND.;
			DTOS(GWA->GWA_DTEMIS) == DTOS(dDtEmis)

			RecLock("GWA",.F.)
				dbDelete()
			MsUnLock()

			iCont++

			GWA->( dbSkip() )
		EndDo

		GFERatLog(Space(6) + STR0142 + cValToChar(iCont) + STR0143) //"Foram eliminados " ### " movimentos."
	EndIf
	
	
	GFERatLog(Space(3) + "6.2 Gerando movimentos contábeis", .T.)
	
	dbSelectArea(cAliasTab)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek((cAliasTab)->FILIAL+(cAliasTab)->CDTPDC+(cAliasTab)->EMISDC+(cAliasTab)->SERDC+(cAliasTab)->NRDC)
			IncProcess()
		
			dbSelectArea("GWM")
			dbSetOrder(1)
			If dbSeek(GW1->GW1_FILIAL + cTpDocto + cCdEsp + cCdEmit + cSerie + cNrDoc + DTOS(dDtEmis) + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
				While !GWM->(Eof()) 			   		  .AND. ;
					   GWM->GWM_FILIAL == GW1->GW1_FILIAL .AND. ;   
					   GWM->GWM_TPDOC  == cTpDocto        .AND. ; 
					   GWM->GWM_CDESP  == cCdEsp          .AND. ; 
					   GWM->GWM_CDTRP  == cCdEmit         .AND. ; 
					   GWM->GWM_SERDOC == cSerie          .AND. ; 
					   GWM->GWM_NRDOC  == cNrDoc          .AND. ; 
					   GWM->GWM_DTEMIS == dDtEmis         .AND. ; 
					   GWM->GWM_CDTPDC == GW1->GW1_CDTPDC .AND. ; 
					   GWM->GWM_EMISDC == GW1->GW1_EMISDC .AND. ; 
					   GWM->GWM_SERDC  == GW1->GW1_SERDC  .AND. ; 
					   GWM->GWM_NRDC   == GW1->GW1_NRDC					

					If Empty(GWM->GWM_CTFRET)
						GFERatLog(Space(6) + "** Não há Conta Contábil informada no Rateio do Item " + AllTrim(GWM->GWM_SEQGW8) + ;
								  " - " + AllTrim(GWM->GWM_ITEM) + " do Documento de Carga de número " + AllTrim(GWM->GWM_NRDC) + ;
								  " pertencente ao " + {"Cálculo ", "Documento de Frete", "Contrato", "Estimativa:"}[Val(cTpDocto)] + ;
								  cNrDoc + ". O Rateio será desconsiderado na geração dos Movimentos Contábeis." + CRLF)
					 	aRetRateio[1] := .F.
						aRetRateio[2] := "Não há Conta Contábil informada para o item (seq/item): '" + AllTrim(GWM->GWM_SEQGW8) + "/" + AllTrim(GWM->GWM_ITEM) + "' do Documento de Carga (filial/serie/nr): '" + AllTrim(GWM->GWM_FILIAL) + "/" + Transform(GWM->GWM_SERDC,"!!!") + "/" + AllTrim(GWM->GWM_NRDC) + "'"
						GWM->( dbSkip() )
						Loop
					EndIf
	
					If GWM->GWM_TPDOC == cTpDocto
						If GWM->GWM_NRDOC == PadR(cNrDoc,16)
							
							cRecno := GWM->(Recno())
							If cTpDocto $ "1;4" // Calculo de Frete
								GFEA94GMC(cTpDocto, cRecno, "2", lBatch, lCusto)
							ElseIf cTpDocto == "2" // Documento de Frete
							    dbSelectArea("GW4")
							    dbSetOrder(2)
							    If dbSeek(GWM->GWM_FILIAL+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC+GWM->GWM_CDTPDC)
						    		dbSelectArea("GW3")
						    		dbSetOrder(1)
									If dbSeek(GWM->GWM_FILIAL+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS))
										If GWM->GWM_TPDOC == "2"
											GFEA94GMC("2", cRecno, "2", lBatch, lCusto)
										Endif
									Endif
							    EndIf
							Elseif cTpDocto == "3" // Contrato com Autonomo
								GFEA94GMC("3", cRecno, "2", lBatch, lCusto)
						    Endif
						    
						Else
							GFERatLog(Space(6) + "** Rateio não encontrado com o Número de Documento: " + PadR(cNrDoc,16))
							lRet := .F.
						 	aRetRateio[1] := .F.
							aRetRateio[2] := "Rateio não encontrado. Série: " + cSerie + ", Documento: " + PadR(cNrDoc,16) + ". Rateio Doc: " + GWM->GWM_NRDOC
						Endif
					Endif
					
					dbSelectArea("GWM")
					dbSkip()
				EndDo
			 Else
			 	//Chamado TTEQB1 - Caso a chamada seja chamada do programa de contabilização, a falta de rateio para um documento
			 	//Não impede a geração da contabilização.
			 	If !IsInCallStack("GFEA095")
			 		GFERatLog(Space(6) + "** Rateio não encontrado na base de dados. Tipo Doc: " + cValToChar(GW1->GW1_CDTPDC) + ", Emissor: " + cValToChar(GW1->GW1_EMISDC) + ", Série: " + cValToChar(Transform(GW1->GW1_SERDC,"!!!")) + ", Nr Doc: " + cValToChar(GW1->GW1_NRDC))
					lRet := .F.
					aRetRateio[1] := .F.
					aRetRateio[2] := "Não foi possível realizar rateio do Documento de Carga. Tipo Doc: [" + cValToChar(GW1->GW1_CDTPDC) + "], Emissor: [" + cValToChar(GW1->GW1_EMISDC) + "], Série: [" + cValToChar(Transform(GW1->GW1_SERDC,"!!!")) + "], Nr Doc: [" + cValToChar(GW1->GW1_NRDC) + "]" + CRLF + CRLF
					aRetRateio[2] += "Verifique se o Documento de Carga possui itens e se os itens geram rateio contábil, e se o Cálculo de Frete possui valor ou rateio." 
			 	EndIf
			 Endif
		Else
			lRet := .F.
			aRetRateio[1] := .F.
			aRetRateio[2] := "Documento de carga não existe. Filial: " + xFilial("GW1") + ", Tipo Doc: " + (cAliasTab)->CDTPDC + ", Emissor: " + (cAliasTab)->EMISDC + ", Série:" + Transform((cAliasTab)->SERDC,"!!!") + ", Número: " + (cAliasTab)->NRDC
		EndIf

		dbSelectArea(cAliasTab)
		dbSkip()
	EndDo

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEObGrCo
Retorna os Grupos Das Contas e retorna o RecNo da tabela GUF

@param  aGrupos  	Array com os grupos

@author Israel A Possoli
@since 07/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEObGrCo(aGrupos)
	Local lGrupoEncontrado := .F.
	Local aArea := getArea()
	Local rRecNo := 0			// RecNo da GUF
	Local aGUF	:= {}           // Registros encontrado na GUF conforme aGrupos
								// Matriz multidimensional, primeiro índice são os registros encontrados, segundo índice são os campos
								// Campos:
								//		1-7: Grupos
								//		8: Quantidade de campos equivalentes
								//
	Local nCount, nCount2

	Local xGrupo1 := aGrupos[1]
	Local xGrupo2 := aGrupos[2]
	Local xGrupo3 := aGrupos[3]
	Local xGrupo4 := aGrupos[4]
	Local xGrupo5 := aGrupos[5]
	Local xGrupo6 := aGrupos[6]
	Local xGrupo7 := aGrupos[7]

	GFERatLog(Space(7) + STR0145, .T.) //"Grupos de contas contábeis encontrados:"

	cAliasQry := GetNextAlias()

	// Cria a query para buscar todos os grupos contábeis que se encaixam (aGrupos)
	cQuery := " SELECT * FROM " + RetSQLName("GUF")
	cQuery += " WHERE (GUF_GRP1 = '*' OR GUF_GRP1 = '" + xGrupo1 + "')"
	cQuery += " AND   (GUF_GRP2 = '*' OR GUF_GRP2 = '" + xGrupo2 + "')"
    cQuery += " AND   (GUF_GRP3 = '*' OR GUF_GRP3 = '" + xGrupo3 + "')"
	cQuery += " AND   (GUF_GRP4 = '*' OR GUF_GRP4 = '" + xGrupo4 + "') "
	cQuery += " AND   (GUF_GRP5 = '*' OR GUF_GRP5 = '" + xGrupo5 + "') "
	cQuery += " AND   (GUF_GRP6 = '*' OR GUF_GRP6 = '" + xGrupo6 + "') "
	cQuery += " AND   (GUF_GRP7 = '*' OR GUF_GRP7 = '" + xGrupo7 + "') "
	cQuery += " AND   (GUF_USO <> '3')"
	cQuery += " AND   (D_E_L_E_T_ = ' ')"
	Query := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	// Armazena no array aGUF os registros encontrados
	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()
		GFERatLog( Space(7)    + ;
		           "> GRP1: "  + ALLTRIM((cAliasQry)->GUF_GRP1) + ;
		           ", GRP2: "  + ALLTRIM((cAliasQry)->GUF_GRP2) + ;
		           ", GRP3: "  + ALLTRIM((cAliasQry)->GUF_GRP3) + ;
		           ", GRP4: "  + ALLTRIM((cAliasQry)->GUF_GRP4) + ;
			       ", GRP5: "  + ALLTRIM((cAliasQry)->GUF_GRP5) + ;
			       ", GRP6: "  + ALLTRIM((cAliasQry)->GUF_GRP6) + ;
			       ", GRP7: "  + ALLTRIM((cAliasQry)->GUF_GRP7) + ;
			       ", RecNo: " + ALLTRIM(STR((cAliasQry)->R_E_C_N_O_)))

		AAdd(aGUF, Array(9))
		aGUF[Len(aGUF),1] := (cAliasQry)->GUF_GRP1
		aGUF[Len(aGUF),2] := (cAliasQry)->GUF_GRP2
		aGUF[Len(aGUF),3] := (cAliasQry)->GUF_GRP3
		aGUF[Len(aGUF),4] := (cAliasQry)->GUF_GRP4
		aGUF[Len(aGUF),5] := (cAliasQry)->GUF_GRP5
		aGUF[Len(aGUF),6] := (cAliasQry)->GUF_GRP6
		aGUF[Len(aGUF),7] := (cAliasQry)->GUF_GRP7
		aGUF[Len(aGUF),8] := 0
		aGUF[Len(aGUF),9] := (cAliasQry)->R_E_C_N_O_

		// Soma quantos campos equivalentes (tirando os *) foram encontrados
		If ALLTRIM(aGUF[Len(aGUF),1]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),2]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),3]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),4]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),5]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),6]) != "*"; aGUF[Len(aGUF),8]++; EndIf
		If ALLTRIM(aGUF[Len(aGUF),7]) != "*"; aGUF[Len(aGUF),8]++; EndIf

		lGrupoEncontrado := .T.

		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo
	(cAliasQry)->(dbCloseArea())

	If Len(aGUF) == 0 .OR. lGrupoEncontrado == .F.
		GFERatLog(Space(7) + STR0146) //"Nenhum grupo encontrado."
		Return 0
	EndIf

	// Organiza a matriz do mais equivalente ao menor
	For nCount := 1 To Len(aGUF) - 1
		For nCount2 := nCount + 1 To Len(aGUF)
			If aGUF[nCount2,8] > aGUF[nCount,8]
				aGUFTmp       := aGUF[nCount]
				aGUF[nCount]  := aGUF[nCount2]
				aGUF[nCount2] := aGUFTmp
			EndIf
		Next nCount2
	Next nCount

	GFERatLog(Space(7) + STR0147 + ALLTRIM(STR(aGUF[1,9]))) //"Grupo selecionado (RecNo): "

	rRecNo := aGUF[1,9]

	restArea(aArea)
Return rRecNo


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEVlrGru
Retorna o valor correspondente conforme o Grupo. Função interna, não deve ser executada. Chamada pela função GFEGerRat
Derivada da função "fnCampoGrupo" em botr297.p

@param  aGrupos  	Array com os grupos


@author Israel A Possoli
@since 27/01/10
@version 1.0
/*/
// fnCampoGrupo*/
//-------------------------------------------------------------------
Function GFEVlrGru(cTpGrupo, cTpDocto, nTipoCalc, nCdtpdc, nTipoServ, cIdFederal)
	Local cRet := Space(20)
	Default nTipoServ := ""
	
	If AllTrim(cTpGrupo) == ""
		Return Space(20)
	EndIf

	Do Case
		Case cTpGrupo == "1" /* Filial */

			cRet := GW1->GW1_FILIAL

		Case cTpGrupo == "2" /* Tipo Operação */

			cRet := "0"

			dbSelectArea("GWN") /* Romaneio */
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM) )
				cRet := GWN->GWN_CDTPOP
			EndIf

		Case cTpGrupo == "3" /* Item do Documento de Carga */

			cRet := GW8->GW8_ITEM

		Case cTpGrupo == "4" /* Região Comercial do destinatário */

			cRet := GW1->GW1_REGCOM

		Case cTpGrupo == "5" /* Grupo de Cliente do destinatário */

			//Verifica se o tipo da nota é de entrada e então envia o Grupo de Cliente do Remetente.
			dbSelectArea("GV5")
			dbSetOrder(1)
			If dbSeek(xFilial("GV5") + PadR(Alltrim(nCdtpdc),TamSX3("GV5_CDTPDC")[1]))
				If GV5->GV5_SENTID == "1"
					dbSelectArea("GU3")
					GU3->( dbSetOrder(1) )
					If GU3->( dbSeek(xFilial("GU3") + GW1->GW1_CDREM) )
						cRet := GU3->GU3_CDGREM
					EndIf
				Else
					dbSelectArea("GU3")
					GU3->( dbSetOrder(1) )
					If GU3->( dbSeek(xFilial("GU3") + GW1->GW1_CDDEST) )
						cRet := GU3->GU3_CDGREM
					EndIf
				EndIf
			EndIf

		Case cTpGrupo == "6" /* Tipo de Documento de Carga */

			cRet := GW8->GW8_CDTPDC

		Case cTpGrupo == "7" /* Classificação de Frete */

			dbSelectArea("GWN") /* Romaneio */
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM) ) .And. !Empty(GWN->GWN_CDCLFR)
				cRet := GWN->GWN_CDCLFR
			Else
				cRet := GW8->GW8_CDCLFR
			EndIf

		Case cTpGrupo == "8" /* Tipo de Cálculo */

			If cTpDocto $ "1;2;4"
				cRet := nTipoCalc
			EndIf

		Case cTpGrupo == "9" /* Informação genérica do item do documento de carga */

			cRet := GW8->GW8_INFO1

		Case cTpGrupo == "10" /* Informação genérica do item do documento de carga */

			cRet := GW8->GW8_INFO2

		Case cTpGrupo == "11" /* Informação genérica do item do documento de carga */

			cRet := GW8->GW8_INFO3

		Case cTpGrupo == "12" /* Informação genérica do item do documento de carga */

			cRet := GW8->GW8_INFO4

		Case cTpGrupo == "13" /* Informação genérica do item do documento de carga */

			cRet := GW8->GW8_INFO5

		Case cTpGrupo == "14" // Representante

			cRet := GW1->GW1_REPRES
			
		Case cTpGrupo == "15" // Unidade de Negócio

			cRet := GW8->GW8_UNINEG
			
		Case cTpGrupo == "16" // 16=CFOP Item Doc Carga

			cRet := GW8->GW8_CFOP

		Case cTpGrupo == "17" // 17=Tipo Serviço

			cRet := nTipoServ
		
		Case cTpGrupo == "18" // 18=Grupo de Transportador
			
			GU3->( dbSetOrder(1) )
			If GU3->( dbSeek(xFilial('GU3') + cIdFederal))
				cRet := GU3->GU3_CDGREM
			EndIf
			
		Case cTpGrupo == "19" /* Série Documento de Carga */

			cRet := GW1->GW1_SERDC
					
	EndCase
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA94GMC

Funcao de Geração de movimentos contabeis

nTpOper  - Tipo de operação
cRecno   - Recno do registro
pElimina - Elimina ou nao o registro por default Nao

Exemplo:

GFEA094GMC(1,1,2)

@author Jorge Matos Valcanaia
@since 26/01/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA94GMC(nTpDocto, cRecno, pElimina, lBatch, lCusto)

	Local cCodEstab
	local cIDFederal
	Local cNrDoc
	Local cSerie
	Local cDtEmis
	Local nTpDoc
	Local nOper
	Local cCtCred := " "
	Local cCtDeb := " "
	Local cICMS := " "
	Local cICMSCC := " "
	Local cCtaFilRet[2]
	Local nVlImp := 0
	Local lAtuRat
	Local dDtCalc
  	Local cTpProvis := SuperGetMv("MV_PROVCON",.F.,"4")
  	Local lIntDocF  := (SuperGetMv('MV_DSCTB',, '1') == "2" .And. SuperGetMv('MV_ERPGFE',, '1') == "1")  .OR. SuperGetMv('MV_ERPGFE',, '1') == "4" //Logix
	Local lRetPE := .T.
	Local cDescIcms 		:= 0
	Local lDocCompImp 	:= .F.
	Local s_CRIRAT   := SuperGetMv("MV_CRIRAT",,"1")
	/*aRatVal = Array com os valores dos Rateios (GWM) de acordo com o critério
	              1     2      3          4
  	 aRatVal := {ICMS, PIS, COFINS, Valor do Frete}*/
	Local aRatVal := GFEGetRatVal(s_CRIRAT)

//	lAtuRat := GFERatAtu()
	lAtuRat := .T.

	GFERatLog(Space(3) + "6.3 " + STR0148 + " --------------------------------", .T.) //"6.1 Geração do Movimento"

    Do Case
		/* Calculo - GWF */
		Case nTpDocto == "1" .OR. nTpDocto == "4"
			GFERatLog(Space(9) + STR0149) //"Para Cálculo de Frete"

			dbSelectArea("GWF")
			dbSetOrder(1)
			dbSeek(GWM->GWM_FILIAL + GWM->GWM_NRDOC)
			
			// Ponto de entrada que permite optar pela não geração dos
			// movimentos contábeis por transportador (Britania)
			If ExistBlock("GFEXFC06")
				lRetPE := ExecBlock("GFEXFC06",.F.,.F.)
				If !lRetPE
					Return NIL
				EndIf
			EndIf

			dDtCalc := GWF->GWF_DTCRIA
			// MV_PROVCON 1=Valor do frete integrar;2=Valor Frete menos os impostos, quando recuperáveis;3=Valor Frete menos os impostos
			If cTpProvis $ '1;2;3' 
				
				//Caso cTpProvis "3=Despesa menos Impostos" soma o valor do imposto mesmo que não recuperável, respeitado a regra de custo
				If (GWF->GWF_CRDICM == "1" .Or. Empty(GWF->GWF_CRDICM) .Or. cTpProvis == "3") .And. aRatVal[_ICMS] > 0 .And. !lCusto
					nVlImp += aRatVal[_ICMS]
				EndIf
				
				//Caso cTpProvis "3=Despesa menos Impostos" soma o valor do imposto mesmo que não recuperável, respeitado a regra de custo
				If !lCusto .And. (GWF->GWF_CRDPC == "1" .Or. Empty(GWF->GWF_CRDPC) .Or. cTpProvis == "3")
	
					If aRatVal[_PIS] > 0
						nVlImp += aRatVal[_PIS]
					EndIf
	
					If aRatVal[_COFINS] > 0
						nVlImp += aRatVal[_COFINS]
					EndIf
	
				EndIf
			Else // Padrão 4=Valor Frete menos os impostos, criando os registros contábeis de impostos
				If (GWF->GWF_CRDICM == "1" .Or. Empty(GWF->GWF_CRDICM)) .And. aRatVal[_ICMS] > 0 .And. !lCusto

				GFERatLog(Space(6) + "# ICMS", .T.) // "6.4 Criando movimento para ICMS"
				GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTICMS) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCICMS)+ ", " + STR0153 + ": " + cvalToChar(aRatVal[_ICMS])) //"Conta:" ### "Valor:"

				dbSelectArea("GWA")
				dbSetOrder(1)

				// ---------------------------------------
				// Criação/Atualização do Movimento
				// ---------------------------------------
				cCtaFilRet := CtaFilial(IIf(Empty(GWF->GWF_FILIAL), cFilAnt, GWF->GWF_FILIAL),"301")
				cICMS      := PadR(cCtaFilRet[1], TamSX3("GWA_CTADEB")[1])
				cICMSCC    := PadR(cCtaFilRet[2], TamSX3("GWA_CCDEB")[1])

				If Empty(cICMS)
					GFERatLog(Space(6) + "** Conta por filial de imposto de ICMS de provisão está em branco. Operação cancelada!", .T.)
					aRetRateio[1] := .F.
					aRetRateio[2] := "A Conta por Filial de imposto de ICMS de provisão está em branco, e há movimentação para ICMS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."

					If (!lBatch)
						Help( ,, 'HELP',, "A Conta por Filial de imposto de ICMS de provisão está em branco, e há movimentação para ICMS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //
					EndIf
					GFESaveLog()
					Return .F.
				EndIf

				nVlImp += aRatVal[_ICMS]

				dbSelectArea("GWA")
				dbSetOrder(6)
				If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PADR("301", 10)+GWM->GWM_CTICMS+GWM->GWM_CCICMS+cICMS+cICMSCC+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
					RecLock("GWA",.F.)
					GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_ICMS]
					MsUnlock("GWA")
				Else
					nSeq := ProxSeq("301")
					nSeq++
					RecLock("GWA", .T.)
						GWA->GWA_FILIAL := GWM->GWM_FILIAL
						GWA->GWA_TPDOC  := GWM->GWM_TPDOC
						GWA->GWA_CDTRAN := "301" // Provisão ICMS
						GWA->GWA_CDESP  := GWM->GWM_CDESP
						GWA->GWA_CDEMIT := GWM->GWM_CDTRP
						GWA->GWA_SERIE  := GWM->GWM_SERDOC
						GWA->GWA_NRDOC  := GWM->GWM_NRDOC
						GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
						GWA->GWA_DTMOV  := If(Empty(dDtCalc), dDATABASE, dDtCalc) // Utiliza a mesma data do cálculo, pois se for de estimativa é utilizada a data de emissão do documento de carga
						GWA->GWA_CTACRE := GWM->GWM_CTICMS
						GWA->GWA_CCCRE  := GWM->GWM_CCICMS    // Centro de Custo
						GWA->GWA_CTADEB := cICMS
						GWA->GWA_CCDEB  := cICMSCC       // Centro de Custo
						GWA->GWA_VLMOV  := aRatVal[_ICMS]
						GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
						If GWM->GWM_TPDOC $ "1;4"
							GWA->GWA_TPMOV  := "2"
						Else
							GWA->GWA_TPMOV  := "1"
						EndIf
						If lAtuRat
							GWA->GWA_UNINEG := GWM->GWM_UNINEG
						EndIf
						GWA->GWA_SITCTB := "1"
					MsUnLock("GWA")

					GFERatLog(Space(9) + STR0155) //"Movimento criado:"
					GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
					" => " + STR0052 + ": " + AllTrim(GWA->GWA_CDESP)     +; //"Espécie:"
					", " + STR0046 + ": " + AllTrim(GWA->GWA_CDEMIT)    +; //"Emissor:"
					", " + STR0047 + ": " + AllTrim(GWA->GWA_SERIE)     +; //"Série:"
					", " + STR0156 + ": " + AllTrim(GWA->GWA_NRDOC)     +; //"Nr Doc:"
					", " + STR0054 + ": " + cValToChar(GWA->GWA_DTEMIS) +; //"Dt Emis:"
					", " + STR0157 + ": " + AllTrim(GWA->GWA_CDTRAN)    +; //"Transação:"
					", " + STR0158 + ": " + AllTrim(GWA->GWA_CTACRE)    +; //"Cta Crédito:"
					", C. Custo Cred  : " + AllTrim(GWA->GWA_CCCRE)     +;
						", " + STR0159 + ": " + AllTrim(GWA->GWA_CTADEB)    +;  //"Cta Débito:"
					", C. Custo Deb   : " + AllTrim(GWA->GWA_CCDEB))
					
					GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
				EndIf
			EndIf

			If !lCusto .And. (GWF->GWF_CRDPC == "1" .Or. Empty(GWF->GWF_CRDPC))

				If aRatVal[_PIS] > 0

		            GFERatLog(Space(6) + "# PIS", .T.) //"6.5 Criando movimento para PIS"
					GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTPIS) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCPIS) + ", " + STR0153 + ": " + cvalToChar(aRatVal[_PIS])) //"Conta:" ### "Valor:"

					// ---------------------------------------
					// Criação/Atualização do Movimento
					// ---------------------------------------
					dbSelectArea("GWA")
					dbSetOrder(1)
					cCtaFilRet	:= CtaFilial(IIf(Empty(GWF->GWF_FILIAL), cFilAnt, GWF->GWF_FILIAL),"302")
					cCtDeb		:= PadR(cCtaFilRet[1], TamSX3("GWM_CTPIS")[1])
					cCCustoDeb	:= PadR(cCtaFilRet[2], TamSX3("GWM_CCPIS")[1])

					If Empty(cCtDeb)
						GFERatLog(Space(6) + "** Conta por filial de imposto de PIS de provisão está em branco. Operação cancelada!", .T.)
						GFESaveLog()

						aRetRateio[1] := .F.
						aRetRateio[2] := "A Conta por filial de imposto de PIS de provisão está em branco, e há movimentação para PIS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC, "!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."

						If (!lBatch)
							Help( ,, 'HELP',, "A Conta por filial de imposto de PIS de provisão está em branco, e há movimentação para PIS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC, "!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //""
						EndIf

						GFESaveLog()
						Return .F.
					EndIf

					nVlImp += aRatVal[_PIS]

					dbSelectArea("GWA")
					dbSetOrder(6)
					If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PADR("302", 10)+GWM->GWM_CTPIS+GWM->GWM_CCPIS+cCtDeb+cCCustoDeb+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
					     RecLock("GWA",.F.)
						     GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_PIS]
					     MsUnLock("GWA")
					Else
						nSeq := ProxSeq("302")
						nSeq++
						RecLock("GWA", .T.)
							GWA->GWA_FILIAL := GWM->GWM_FILIAL
							GWA->GWA_TPDOC  := GWM->GWM_TPDOC
							GWA->GWA_CDTRAN := "302" // Provisão de PIS
							GWA->GWA_CDESP  := GWM->GWM_CDESP
							GWA->GWA_CDEMIT := GWM->GWM_CDTRP
							GWA->GWA_SERIE  := GWM->GWM_SERDOC
							GWA->GWA_NRDOC  := GWM->GWM_NRDOC
							GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
							GWA->GWA_DTMOV  := If(Empty(dDtCalc), dDATABASE, dDtCalc)// Utiliza a mesma data do cálculo, pois se for de estimativa é utilizada a data de emissão do documento de carga
							GWA->GWA_CTACRE := GWM->GWM_CTPIS
							GWA->GWA_CCCRE  := GWM->GWM_CCPIS // Centro de Custo
							GWA->GWA_CTADEB := cCtDeb
							GWA->GWA_CCDEB  := cCCustoDeb // Centro de Custo
							GWA->GWA_VLMOV  := aRatVal[_PIS]
							GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
							If GWM->GWM_TPDOC $ "1;4"
								GWA->GWA_TPMOV  := "2"
							Else
								GWA->GWA_TPMOV  := "1"
							EndIf
							If lAtuRat
								GWA->GWA_UNINEG := GWM->GWM_UNINEG
							EndIf
							GWA->GWA_SITCTB := "1"
						MsUnLock("GWA")
					EndIf
				EndIf

				If aRatVal[_COFINS] > 0

				    GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTCOFI) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCCOFI) + ", " + STR0153 + ": " + cValToChar(aRatVal[_COFINS])) //"Conta:" ### "Valor:"

					// ---------------------------------------
					// Criação/Atualização do Movimento
					// ---------------------------------------
		   			dbSelectArea("GWA")
					dbSetOrder(1)

					cCtaFilRet := CtaFilial(IIf(Empty(GWF->GWF_FILIAL), cFilAnt, GWF->GWF_FILIAL),"303")
					cCtDeb	   := PadR(cCtaFilRet[1], TamSX3("GWM_CTCOFI")[1])
					cCCustoDeb := PadR(cCtaFilRet[2], TamSX3("GWM_CCCOFI")[1])

					If Empty(cCtDeb)
						GFERatLog(Space(6) + "** Conta por filial de imposto de COFINS de provisão está em branco. Operação cancelada!", .T.)
						GFESaveLog()

						aRetRateio[1] := .F.
						aRetRateio[2] := "A Conta por filial de imposto de COFINS de provisão está em branco, e há movimentação para COFINS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."

						If (!lBatch)
							Help( ,, 'HELP',, "A Conta por filial de imposto de COFINS de provisão está em branco, e há movimentação para COFINS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //""
						EndIf
						
						GFESaveLog()
						Return .F.
					EndIf

					nVlImp += aRatVal[_COFINS]

					dbSelectArea("GWA")
					dbSetOrder(6)
					If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PADR("303", 10)+GWM->GWM_CTCOFI+GWM->GWM_CCCOFI+cCtDeb+cCCustoDeb+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
					     RecLock("GWA",.F.)
						     GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_COFINS]
					     MsUnLock("GWA")
					Else
						nSeq := ProxSeq("303")
						nSeq++
						RecLock("GWA", .T.)
							GWA->GWA_FILIAL := GWM->GWM_FILIAL
							GWA->GWA_TPDOC  := GWM->GWM_TPDOC
							GWA->GWA_CDTRAN := "303" // Contabilizacao de COFINS
							GWA->GWA_CDESP  := GWM->GWM_CDESP
							GWA->GWA_CDEMIT := GWM->GWM_CDTRP
							GWA->GWA_SERIE  := GWM->GWM_SERDOC
							GWA->GWA_NRDOC  := GWM->GWM_NRDOC
							GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
							GWA->GWA_DTMOV  := If(Empty(dDtCalc), dDATABASE, dDtCalc) // Utiliza a mesma data do cálculo, pois se for de estimativa é utilizada a data de emissão do documento de carga
							GWA->GWA_CTACRE := GWM->GWM_CTCOFI
							GWA->GWA_CCCRE  := GWM->GWM_CCCOFI	// Centro de Custo
							GWA->GWA_CTADEB := cCtDeb
							GWA->GWA_CCDEB  := cCCustoDeb     	// Centro de Custo
							GWA->GWA_VLMOV  := aRatVal[_COFINS]
							GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
							If GWM->GWM_TPDOC $ "1;4"
								GWA->GWA_TPMOV  := "2"
							Else
								GWA->GWA_TPMOV  := "1"
							EndIf
							If lAtuRat
								GWA->GWA_UNINEG := GWM->GWM_UNINEG
							EndIf
							GWA->GWA_SITCTB := "1"
						MsUnLock("GWA")

		   				GFERatLog(Space(9) + STR0155) //"Movimento criado:"
					    GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
					    	          " => " + STR0052 + ": " + AllTrim(GWA->GWA_CDESP)     	+; 	//"Espécie:"
		  			    	          ", " + STR0046 + ": "   + AllTrim(GWA->GWA_CDEMIT)    	+; 	//"Emissor:"
		   			    	          ", " + STR0047 + ": "   + AllTrim(GWA->GWA_SERIE)     	+; 	//"Série:"
					    	          ", " + STR0156 + ": "   + AllTrim(GWA->GWA_NRDOC)    	+; 	//"Nr Doc:"
					    	          ", " + STR0054 + ": "   + cValToChar(GWA->GWA_DTEMIS)	+; 	//"Dt Emis:"
					    	          ", " + STR0157 + ": "   + AllTrim(GWA->GWA_CDTRAN)    		+; 	//"Transação:"
					    	          ", " + STR0158 + ":"    + AllTrim(GWA->GWA_CTACRE)    		+; 	//"Cta Crédito:"
					    	          ", C. Custo Cred  : "   + AllTrim(GWA->GWA_CCCRE)     		+;
					    	          ", " + STR0159 + ": "   + AllTrim(GWA->GWA_CTADEB)			+;	//"Cta Débito:"
					    	          ", C. Custo Deb   : "   + AllTrim(GWA->GWA_CCDEB))

					    GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
					EndIf

				EndIf

			EndIf
		EndIf
			

			GFERatLog(Space(6) + "# Valor do Frete",.T.) //"6.7 Criando movimento para Frete"
		    GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTFRET) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCFRET) + ", " + STR0153 + ": " + cValToChar(aRatVal[_VLFRET]))	//"Conta:" ### "Valor:"

			// ---------------------------------------
			// Criação/Atualização do Movimento
			// ---------------------------------------
			dbSelectArea("GWA")
			dbSetOrder(1)

			cCtaFilRet  := CtaFilial(IIf(Empty(GWF->GWF_FILIAL), cFilAnt, GWF->GWF_FILIAL),"300")
			cCtCred		:= PadR(cCtaFilRet[1], TamSX3("GWM_CTFRET")[1])
			cCCustoCred	:= PadR(cCtaFilRet[2], TamSX3("GWM_CCFRET")[1])

			// ---------------------------------------
			// Criação/Atualização do Movimento
			// ---------------------------------------
			dbSelectArea("GWA")
			dbSetOrder(6)
			If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PADR("300", 10)+cCtCred+cCCustoCred+GWM->GWM_CTFRET+GWM->GWM_CCFRET+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
			    RecLock("GWA",.F.)
			    	
			    If cTpProvis $ "2;3;4" .Or. Empty(cTpProvis)
			    	// Liquido  (Valor do frete - (ICMS) - (PIS/COFINS)), é avaliado se o imposto é recuperável quando cTpProvis Diferente de 3 
			    	GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_VLFRET] - nVlImp
			    ElseIf cTpProvis=="1"
			    	// Valor do Frete (integral)
				   GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_VLFRET]
				EndIf
			    MsUnLock("GWA")
			    GFERatLog(Space(9) + "> " + STR0154 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Movimento já criado, atualizando valor:"
			Else
				nSeq := ProxSeq("300")
				nSeq++
				RecLock("GWA", .T.)
					GWA->GWA_FILIAL := GWM->GWM_FILIAL
					GWA->GWA_TPDOC  := GWM->GWM_TPDOC
					GWA->GWA_CDTRAN := "300" // Contabilizacao de Frete
					GWA->GWA_CDESP  := GWM->GWM_CDESP
					GWA->GWA_CDEMIT := GWM->GWM_CDTRP
					GWA->GWA_SERIE  := GWM->GWM_SERDOC		
					GWA->GWA_NRDOC  := GWM->GWM_NRDOC
					GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
					GWA->GWA_DTMOV  := If(Empty(dDtCalc), dDATABASE, dDtCalc) // Utiliza a mesma data do cálculo, pois se for de estimativa é utilizada a data de emissão do documento de carga
					GWA->GWA_CTACRE := cCtCred
					GWA->GWA_CCCRE  := cCCustoCred			// Centro de Custo
					GWA->GWA_CTADEB := GWM->GWM_CTFRET
					GWA->GWA_CCDEB  := GWM->GWM_CCFRET		// Centro de Custo
					If cTpProvis $ "2;3;4" .Or. Empty(cTpProvis) // Liquido  (Valor do frete - (ICMS) - (PIS/COFINS)), é avaliado se o imposto é recuperável quando cTpProvis Diferente de 3
						GWA->GWA_VLMOV  := aRatVal[_VLFRET] - nVlImp
					ElseIf cTpProvis=="1" // Valor do Frete (integral)
						GWA->GWA_VLMOV  := aRatVal[_VLFRET]
					EndIf
					GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
					If GWM->GWM_TPDOC $ "1;4"
						GWA->GWA_TPMOV  := "2"
					Else
					GWA->GWA_TPMOV  := "1"
					EndIf
					If lAtuRat
						GWA->GWA_UNINEG := GWM->GWM_UNINEG
					EndIf
					GWA->GWA_SITCTB := "1"
				MsUnLock("GWA")

	   			GFERatLog(Space(9) + STR0155) //"Movimento criado:"
				GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
				    	      " => " + STR0052 + ": " + AllTrim(GWA->GWA_CDESP)   +; 	//"Espécie:"
	  			    	      ", " + STR0046 + ": " + AllTrim(GWA->GWA_CDEMIT)    +; 	//"Emissor:"
	   			    	      ", " + STR0047 + ": " + AllTrim(GWA->GWA_SERIE)     +; 	//"Série:"
				    	      ", " + STR0156 + ": " + AllTrim(GWA->GWA_NRDOC)     +; 	//"Nr Doc:"
				    	      ", " + STR0054 + ": " + cValToChar(GWA->GWA_DTEMIS) +; 	//"Dt Emis:"
				    	      ", " + STR0157 + ": " + AllTrim(GWA->GWA_CDTRAN)    +; 	//"Transação:"
				    	      ", " + STR0158 + ": " + AllTrim(GWA->GWA_CTACRE)    +; 	//"Cta Crédito:"
				    	      ", C. Custo Cred  : " + AllTrim(GWA->GWA_CCCRE)     +;
				    	      ", " + STR0159 + ": " + AllTrim(GWA->GWA_CTADEB)    +;	//"Cta Débito:"
				    	      ", C. Custo Deb   : " + AllTrim(GWA->GWA_CCDEB))

				GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
			Endif

		/*Documento de Frete*/
		Case nTpDocto == "2"
			// GFERatLog(Space(9) + STR0168) //"Para Documento de Frete"

			cCodEstab  := GW3->GW3_FILIAL
			cIDFederal := GW3->GW3_EMISDF
			cNrDoc     := GW3->GW3_NRDF
			cSerie     := GW3->GW3_SERDF
			cDtEmis    := GW3->GW3_DTEMIS
			nTpDoc     := 1 /* Documento de Frete */
			nOper      := 1 /* Pré-cálculo */
			
			//Atribui valor referência utilizado na integração quando integrado com o Datasul
			If SuperGetMv('MV_ERPGFE',, '1') == "1" 
				RecLock("GW3",.F.)
				If lCusto
					GW3->GW3_ACINT := "2"  //Nota de rateio
				ElseIf lIntDocF
					GW3->GW3_ACINT := "1"  //Nota de compra	
				Else
					GW3->GW3_ACINT := "0" //Documento Fiscal
				EndIf
				MsUnlock("GW3")
			EndIf
				
			If GW3->GW3_CRDICM == "1" .And. !lCusto .And. !lIntDocF

				GFERatLog(Space(6) + "# ICMS", .T.) //"6.4 Criando movimento para ICMS"
				GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTICMS) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCICMS) + ", " + STR0153 + ": " + cvalToChar(aRatVal[_VLFRET])) //"Conta:" ### "Valor:"

				If aRatVal[_ICMS] > 0

					// ---------------------------------------
					// Criação/Atualização do Movimento
					// ---------------------------------------
					dbSelectArea("GWA")
					dbSetOrder(1)

					cCtaFilRet  := CtaFilial(IIf(Empty(GW3->GW3_FILIAL), cFilAnt, GW3->GW3_FILIAL),"311")
					cContaICMS  := PadR(cCtaFilRet[1],TamSX3("GWM_CTICMS")[1])
					cCCustoICMS := PadR(cCtaFilRet[2],TamSX3("GWM_CCICMS")[1])
					
					If Empty(cContaICMS)
						GFERatLog(Space(6) + "** Conta por filial de imposto de ICMS de realização está em branco. Operação cancelada!", .T.)
						GFESaveLog()
						aRetRateio[1] := .F.
						aRetRateio[2] := "A Conta por filial de imposto de ICMS de realização está em branco, e há movimentação para ICMS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."

						If (!lBatch)
							Help( ,, 'HELP',, "A Conta por filial de imposto de ICMS de realização está em branco, e há movimentação para ICMS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //""
						EndIf

						GFESaveLog()
						Return .F.
					EndIf

					nVlImp += aRatVal[_ICMS]

					dbSelectArea("GWA")
					dbSetOrder(6)
					If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR("311",10)+GWM->GWM_CTICMS+GWM->GWM_CCICMS+cContaICMS+cCCustoICMS+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
						RecLock("GWA",.F.)
						GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_ICMS]
						MsUnLock("GWA")
					Else
						nSeq := ProxSeq("311")
						nSeq++
						RecLock("GWA", .T.)
							GWA->GWA_FILIAL := GWM->GWM_FILIAL
							GWA->GWA_TPDOC  := GWM->GWM_TPDOC
							GWA->GWA_CDTRAN := "311" // Contabilizacao de ICMS
							GWA->GWA_CDESP  := GWM->GWM_CDESP
							GWA->GWA_CDEMIT := GWM->GWM_CDTRP
							GWA->GWA_SERIE  := GWM->GWM_SERDOC
							GWA->GWA_NRDOC  := GWM->GWM_NRDOC
							GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
							GWA->GWA_DTMOV  := dDATABASE
							GWA->GWA_CTACRE := GWM->GWM_CTICMS
							GWA->GWA_CCCRE  := GWM->GWM_CCICMS       // Centro de Custo
							GWA->GWA_CTADEB := cContaICMS
							GWA->GWA_CCDEB  := cCCustoICMS   // Centro de Custo
							GWA->GWA_VLMOV  := aRatVal[_ICMS]
							GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
							If GWM->GWM_TPDOC $ "1;4"
								GWA->GWA_TPMOV  := "2"
							Else
								GWA->GWA_TPMOV  := "1"
							EndIf
							If lAtuRat
								GWA->GWA_UNINEG := GWM->GWM_UNINEG
							EndIf
							GWA->GWA_SITCTB := "1"
						MsUnLock("GWA")
	
						GFERatLog(Space(9) + STR0155) //"Movimento criado:"
						GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
                         " => " + STR0052 + ": "  + AllTrim(GWA->GWA_CDESP)      +; //"Espécie:"
                         ", " + STR0046 + ": "    + AllTrim(GWA->GWA_CDEMIT)     +; //"Emissor:"
                         ", " + STR0047 + ": "      + AllTrim(GWA->GWA_SERIE)    +; //"Série:"
                         ", " + STR0156 + ": "     + AllTrim(GWA->GWA_NRDOC)     +; //"Nr Doc:"
                         ", " + STR0054 + ": "    + cValToChar(GWA->GWA_DTEMIS)  +; //"Dt Emis:"
                         ", " + STR0157 + ": "  + AllTrim(GWA->GWA_CDTRAN)       +; //"Transação:"
                         ", " + STR0158 + ":" + AllTrim(GWA->GWA_CTACRE)         +; //"Cta Crédito:"
                         ", C. Custo Cred  : " + AllTrim(GWA->GWA_CCCRE)         +;
                         ", " + STR0159 + ": " + AllTrim(GWA->GWA_CTADEB)        +; //"Cta Débito:"
                         ", C. Custo Deb   : " + AllTrim(GWA->GWA_CCDEB))
	
							GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
					EndIf
				Else
					GFERatLog(Space(9) + "** Valor zerado. Movimento não foi criado.")
				EndIf
			EndIf

			If GW3->GW3_CRDPC == "1" .And. !lCusto .And. !lIntDocF

				GFERatLog(Space(6) + "# PIS", .T.) //"6.5 Criando movimento para PIS"
				GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTPIS) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCPIS) + ", " + STR0153 + ": " + cvalToChar(aRatVal[_PIS])) //"Conta:" ### "Valor:"

				If aRatVal[_PIS] > 0

					// ---------------------------------------
					// Criação/Atualização do Movimento
					// ---------------------------------------
					dbSelectArea("GWA")
					dbSetOrder(1)
	
					cCtaFilRet  := CtaFilial(IIf(Empty(GW3->GW3_FILIAL), cFilAnt, GW3->GW3_FILIAL),"312")
					cCtPis      := PadR(cCtaFilRet[1],TamSX3("GWM_CTPIS")[1])   // cCtCred
					cCCustoPis  := PadR(cCtaFilRet[2],TamSX3("GWM_CCPIS")[1])   // cCCustoCred
					
					If Empty(cCtPis)
						GFERatLog(Space(6) + "** Conta por filial de imposto de PIS de realização está em branco. Operação cancelada!", .T.)
						GFESaveLog()
						aRetRateio[1] := .F.
						aRetRateio[2] := "A Conta por filial de imposto de PIS de realização está em branco, e há movimentação para PIS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."
	
						If (!lBatch)
							Help( ,, 'HELP',, "A Conta por filial de imposto de PIS de realização está em branco, e há movimentação para PIS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //""
						EndIf
						
						GFESaveLog()
						Return .F.
					EndIf
	
					nVlImp += aRatVal[_PIS] // BUSCAR PELO CRITÉRIO DE RATEIO******************
					
					dbSelectArea("GWA")
					dbSetOrder(6)
					If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR("312",10)+GWM->GWM_CTPIS+GWM->GWM_CCPIS+cCtPis+cCCustoPis+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
						RecLock("GWA",.F.)
						GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_PIS]
						MsUnLock("GWA")
					Else
						nSeq := ProxSeq("312")
						nSeq++
						RecLock("GWA", .T.)
							GWA->GWA_FILIAL := GWM->GWM_FILIAL
							GWA->GWA_TPDOC  := GWM->GWM_TPDOC
							GWA->GWA_CDTRAN := "312" //Contabilizacao de PIS
							GWA->GWA_CDESP  := GWM->GWM_CDESP
							GWA->GWA_CDEMIT := GWM->GWM_CDTRP
							GWA->GWA_SERIE  := GWM->GWM_SERDOC
							GWA->GWA_NRDOC  := GWM->GWM_NRDOC
							GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
							GWA->GWA_DTMOV  := dDATABASE
							GWA->GWA_CTACRE := GWM->GWM_CTPIS
							GWA->GWA_CCCRE  := GWM->GWM_CCPIS  // Centro de Custo
							GWA->GWA_CTADEB := cCtPis
							GWA->GWA_CCDEB  := cCCustoPis      // Centro de Custo
							GWA->GWA_VLMOV  := aRatVal[_PIS]
							GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
							If GWM->GWM_TPDOC $ "1;4"
								GWA->GWA_TPMOV  := "2"
							Else
								GWA->GWA_TPMOV  := "1"
							EndIf
							If lAtuRat
								GWA->GWA_UNINEG := GWM->GWM_UNINEG
							EndIf
							GWA->GWA_SITCTB := "1"
						MsUnlock("GWA")
	
						GFERatLog(Space(9) + STR0155) //"Movimento criado:"
						GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
                         " => " + STR0052 + ": "  + AllTrim(GWA->GWA_CDESP)     +; //"Espécie:"
                         ", " + STR0046 + ": "   + AllTrim(GWA->GWA_CDEMIT)    +;   //"Emissor:"
                         ", " + STR0047 + ": "   + AllTrim(GWA->GWA_SERIE)     +;   //"Série:"
                         ", " + STR0156 + ": "   + AllTrim(GWA->GWA_NRDOC)     +;   //"Nr Doc:"
                         ", " + STR0054 + ": "   + cValToChar(GWA->GWA_DTEMIS) +;   //"Dt Emis:"
                         ", " + STR0157 + ": "   + AllTrim(GWA->GWA_CDTRAN)    +;   //"Transação:"
                         ", " + STR0158 + ":"    + AllTrim(GWA->GWA_CTACRE)    +;   //"Cta Crédito:"
                         ", C. Custo Cred  : "   + AllTrim(GWA->GWA_CCCRE)     +;
                         ", " + STR0159 + ": "   + AllTrim(GWA->GWA_CTADEB)    +;   //"Cta Débito:"
                         ", C. Custo Deb   : "   + AllTrim(GWA->GWA_CCDEB))

						GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
					EndIf
				Else
					GFERatLog(Space(9) + "** Valor zerado. Movimento não foi criado.")
				EndIf

				GFERatLog(Space(6) +  "# COFINS", .T.)
				GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTCOFI) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCCOFI) + ", " + STR0153 + ": " + cValToChar(aRatVal[_COFINS])) //"Conta:" ### "Valor:"

				If aRatVal[_COFINS] > 0

					// ---------------------------------------
					// Criação/Atualização do Movimento
					// ---------------------------------------
					DbSelectArea("GWA")
					dbSetOrder(1)
	
					cCtaFilRet  := CtaFilial(IIf(Empty(GW3->GW3_FILIAL), cFilAnt, GW3->GW3_FILIAL),"313")
					cCtCofi     := PadR(cCtaFilRet[1], TamSX3("GWM_CTCOFI")[1])
					cCustoCofi  := PadR(cCtaFilRet[2], TamSX3("GWM_CCCOFI")[1])
	
					If Empty(cCtCofi)
						GFERatLog(Space(6) + "** Conta por filial de imposto de COFINS de realização está em branco. Operação cancelada!", .T.)
						GFESaveLog()
						aRetRateio[1] := .F.
						aRetRateio[2] := "A Conta por filial de imposto de COFINS de realização está em branco, e há movimentação para COFINS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada."
	
						If (!lBatch)
							Help( ,, 'HELP',, "A Conta por filial de imposto de COFINS de realização está em branco, e há movimentação para COFINS para o rateio do Documento de Carga de Emissor: " + AllTrim(GWM->GWM_EMISDC) + ", Tipo: " + AllTrim(GWM->GWM_CDTPDC) + ", Série: " + Transform(GWM->GWM_SERDC,"!!!") + ", Número: " + AllTrim(GWM->GWM_NRDC) + ". Geração de Movimentos Contábeis cancelada.", 1, 0) //""
						EndIf
	
						GFESaveLog()
						Return .F.
					EndIf

					nVlImp += aRatVal[_COFINS]
	
					dbSelectArea("GWA")
					dbSetOrder(6)
					If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR("313",10)+GWM->GWM_CTCOFI+GWM->GWM_CCCOFI+cCtCofi+cCustoCofi+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
						RecLock("GWA",.F.)
						GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_COFINS]
						MsUnLock("GWA")
					Else
						nSeq := ProxSeq("313")
						nSeq++
						RecLock("GWA", .T.)
							GWA->GWA_FILIAL := GWM->GWM_FILIAL
							GWA->GWA_TPDOC  := GWM->GWM_TPDOC
							GWA->GWA_CDTRAN := "313" // Contabilizacao de COFINS
							GWA->GWA_CDESP  := GWM->GWM_CDESP
							GWA->GWA_CDEMIT := GWM->GWM_CDTRP
							GWA->GWA_SERIE  := GWM->GWM_SERDOC
							GWA->GWA_NRDOC  := GWM->GWM_NRDOC
							GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
							GWA->GWA_DTMOV  := dDATABASE
							GWA->GWA_CTACRE := GWM->GWM_CTCOFI
							GWA->GWA_CCCRE  := GWM->GWM_CCCOFI      // Centro de Custo
							GWA->GWA_CTADEB := cCtCofi
							GWA->GWA_CCDEB  := cCustoCofi        // Centro de Custo
							GWA->GWA_VLMOV  := aRatVal[_COFINS]
							GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
							If GWM->GWM_TPDOC $ "1;4"
								GWA->GWA_TPMOV  := "2"
							Else
								GWA->GWA_TPMOV  := "1"
							EndIf
							If lAtuRat
								GWA->GWA_UNINEG := GWM->GWM_UNINEG
							EndIf
							GWA->GWA_SITCTB := "1"
						MsUnLock("GWA")
	
						GFERatLog(Space(9) + STR0155) //"Movimento criado:"
						GFERatLog(Space(9) + "> "  + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) +;
                         " => " + STR0052 + ": " + AllTrim(GWA->GWA_CDESP)     +; //"Espécie:"
                         ", " + STR0046 + ": " + AllTrim(GWA->GWA_CDEMIT)    +; //"Emissor:"
                         ", " + STR0047 + ": " + AllTrim(GWA->GWA_SERIE)     +; //"Série:"
                         ", " + STR0156 + ": " + AllTrim(GWA->GWA_NRDOC)     +; //"Nr Doc:"
                         ", " + STR0054 + ": " + cValToChar(GWA->GWA_DTEMIS) +; //"Dt Emis:"
                         ", " + STR0157 + ": " + AllTrim(GWA->GWA_CDTRAN)    +; //"Transação:"
                         ", " + STR0158 + ": " + AllTrim(GWA->GWA_CTACRE)    +; //"Cta Crédito:"
                         ", C. Custo Cred  : " + AllTrim(GWA->GWA_CCCRE)     +;
                         ", " + STR0159 + ": " + AllTrim(GWA->GWA_CTADEB)    +;  //"Cta Débito:"
                         ", C. Custo Deb   : " + AllTrim(GWA->GWA_CCDEB))
	
						GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //"Valor:"
					EndIf
				Else 
					GFERatLog(Space(9) + "** Valor zerado. Movimento não foi criado.")
				EndIf
			EndIf

			GFERatLog(Space(6) + "# Valor do Frete", .T.)
			GFERatLog(Space(9) + "> " + STR0152 + ": " + cValToChar(GWM->GWM_CTFRET) + ", Centro de Custo: " + cValToChar(GWM->GWM_CCFRET) + ", " + STR0153 + ": " + cValToChar(aRatVal[_VLFRET])) // "Conta:" ### "Valor:"

			If aRatVal[_VLFRET] > 0

				// ---------------------------------------
				// Criação/Atualização do Movimento
				// ---------------------------------------
				dbSelectArea("GWA")
				dbSetOrder(1)
				cCtaFilRet  := CtaFilial(IIf(Empty(GW3->GW3_FILIAL), cFilAnt, GW3->GW3_FILIAL),"310")
				cCtCred     := PadR(cCtaFilRet[1], TamSX3("GWM_CTFRET")[1])
				cCustoCred  := PadR(cCtaFilRet[2], TamSX3("GWM_CCFRET")[1])
	
				GW3->(dbSetOrder(1))
				 If GW3->(dbSeek(GWA->GWA_FILIAL+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)))				 
				 	If GW3->GW3_TPDF == "3"
						lDocCompImp := .T.
					EndIf
				EndIf
					
				dbSelectArea("GWA")
				dbSetOrder(6)
				If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR("310",10)+cCtCred+cCustoCred+GWM->GWM_CTFRET+GWM->GWM_CCFRET+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
					GFERatLog(Space(9) + "> Atualizando movimento já criado. Seq: " +  cValToChar(GWA->GWA_SEQ) + ".  Valor atual: " + cValToChar(GWA->GWA_VLMOV) + ", Valor do Movimento: " + cValToChar(aRatVal[_VLFRET]) + ", Valor do Imposto a ser deduzido: " + cValToChar(nVlImp)) //Movimento já criado, valor atual:
					RecLock("GWA",.F.)
						If (aRatVal[_VLFRET] - nVlImp) <= 0 .And. lDocCompImp 	
							cDescIcms 		 := (aRatVal[_VLFRET] - nVlImp)
							GWA->GWA_VLMOV := 0
						Else
							GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_VLFRET] - nVlImp
						EndIf
					MsUnLock("GWA")
	
					GFERatLog(Space(9) + "> Valor final: " + cValToChar(GWA->GWA_VLMOV))
				Else
					nSeq := ProxSeq("310")
					nSeq++
					RecLock("GWA", .T.)
						GWA->GWA_FILIAL := GWM->GWM_FILIAL
						GWA->GWA_TPDOC  := GWM->GWM_TPDOC
						GWA->GWA_CDTRAN := "310" // Contabilizacao de Frete
						GWA->GWA_CDESP  := GWM->GWM_CDESP
						GWA->GWA_CDEMIT := GWM->GWM_CDTRP
						GWA->GWA_SERIE  := GWM->GWM_SERDOC
						GWA->GWA_NRDOC  := GWM->GWM_NRDOC
						GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
						GWA->GWA_DTMOV  := dDATABASE
						GWA->GWA_CTACRE := cCtCred
						GWA->GWA_CCCRE  := cCustoCred       // Centro de Custo
						GWA->GWA_CTADEB := GWM->GWM_CTFRET
						GWA->GWA_CCDEB  := GWM->GWM_CCFRET      // Centro de Custo
						If (aRatVal[_VLFRET] - nVlImp) <= 0 .And. lDocCompImp 	
							cDescIcms 		 := (aRatVal[_VLFRET] - nVlImp)
							GWA->GWA_VLMOV := 0
						Else
							GWA->GWA_VLMOV := (aRatVal[_VLFRET] - nVlImp)
						EndIf
						GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
						If GWM->GWM_TPDOC $ "1;4"
							GWA->GWA_TPMOV  := "2"
						Else
							GWA->GWA_TPMOV  := "1"
						EndIf
						If lAtuRat
							GWA->GWA_UNINEG := GWM->GWM_UNINEG
						EndIf
						GWA->GWA_SITCTB := "1"
					MsUnLock("GWA")
				
					//Inicio Ponto de Entrada Procomp
					If ExistBlock("GFEXFC05")
						ExecBlock("GFEXFC05",.F.,.F.,{GWM->GWM_FILIAL, GWM->GWM_CDESP, GWM->GWM_CDTRP, GWM->GWM_NRDOC, GWM->GWM_SERDOC, GWM->GWM_DTEMIS, GWM->GWM_TPDOC}) 
					EndIf
					//Inicio Ponto de Entrada Procomp	
					
					GFERatLog(Space(9) + STR0155) //"Movimento criado:"
					GFERatLog(Space(9) + "> " + AllTrim(GFEFldInfo("GWA_TPDOC", GWA->GWA_TPDOC, 2)) + ", Seq: "  + cValToChar(GWA->GWA_SEQ) + ;
                     " => " + STR0052 + ": " + AllTrim(GWA->GWA_CDESP)     +; //"Espécie:"
                     ", " + STR0046 + ": " + AllTrim(GWA->GWA_CDEMIT)    +; //"Emissor:"
                     ", " + STR0047 + ": " + AllTrim(GWA->GWA_SERIE)     +; //"Série:"
                     ", " + STR0156 + ": " + AllTrim(GWA->GWA_NRDOC)     +; //"Nr Doc:"
                     ", " + STR0054 + ": " + cValToChar(GWA->GWA_DTEMIS) +; //"Dt Emis:"
                     ", " + STR0157 + ": " + AllTrim(GWA->GWA_CDTRAN)    +; //"Transação:"
                     ", " + STR0158 + ": " + AllTrim(GWA->GWA_CTACRE)    +; //"Cta Crédito:"
                     ", C. Custo Cred  : " + AllTrim(GWA->GWA_CCCRE)     +;
                     ", " + STR0159 + ": " + AllTrim(GWA->GWA_CTADEB)    +;  //"Cta Débito:"
                     ", C. Custo Deb   : " + AllTrim(GWA->GWA_CCDEB))

					GFERatLog(Space(9) + "> " + STR0153 + ": " + cValToChar(GWA->GWA_VLMOV)) //Valor:
				EndIf
			Else
				GFERatLog(Space(9) + "** Valor zerado. Movimento não foi criado.")
			EndIf
			

			If lDocCompImp .And. cDescIcms > 0  
				dbSelectArea("GWA")
				dbSetOrder(6)
				If dbSeek(xFilial("GWA")+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR("311",10)+GWM->GWM_CTICMS+GWM->GWM_CCICMS+cContaICMS+cCCustoICMS+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
					RecLock("GWA",.F.)
						GWA->GWA_VLMOV  := GWA->GWA_VLMOV + cDescIcms
					MsUnlock("GWA")
				EndIf
			EndIf

		/*Contrato*/
		Case nTpDocto == "3"
			cCodEstab      := GW2->GW2_FILIAL
	        cIDFederal     := ""
	        cNrDoc         := GW2->GW2_NRCONT
	        cSerie         := "1"
	        cDtEmis        := GW2->GW2_DTIMPR
			nTpDoc         := 3 /* Contrato */
	        iDoctoOrigem   := 3 /* Movto Contrato */
	        nOper          := 2 /* Contabilização */

			dbSelectArea("GWA")
			dbSetOrder(1)
			If !Empty(GWM->GWM_CTFRET) .And. aRatVal[_VLFRET] > 0

				cCtaFilRet := CtaFilial(IIf(Empty(GW2->GW2_FILIAL), cFilAnt, GW2->GW2_FILIAL),"100")
				cCtCred	   := PadR(cCtaFilRet[1], TamSX3("GWM_CTFRET")[1])
				cCustoCred := PadR(cCtaFilRet[2], TamSX3("GWM_CCFRET")[1])

				dbSelectArea("GWA")
				dbSetOrder(6)
				If dbSeek(GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+"100       "+cCtCred+cCustoCred+GWM->GWM_CTFRET+GWM->GWM_CCFRET+"1"+IIf(lAtuRat, GWM->GWM_UNINEG, ""))
				     RecLock("GWA",.F.)
					     GWA->GWA_VLMOV := GWA->GWA_VLMOV + aRatVal[_VLFRET]
				     MsUnLock("GWA")
				Else
					nSeq := ProxSeq("100")
					nSeq++
					RecLock("GWA", .T.)
						GWA->GWA_FILIAL := GWM->GWM_FILIAL
						GWA->GWA_TPDOC  := GWM->GWM_TPDOC
						GWA->GWA_CDTRAN := "100" // Emissao contrato com terceiro
						GWA->GWA_CDESP  := GWM->GWM_CDESP
						GWA->GWA_CDEMIT := GWM->GWM_CDTRP
						GWA->GWA_SERIE  := GWM->GWM_SERDOC
						GWA->GWA_NRDOC  := GWM->GWM_NRDOC
						GWA->GWA_DTEMIS := GWM->GWM_DTEMIS
						GWA->GWA_DTMOV  := DDATABASE
						GWA->GWA_CTACRE := cCtCred
						GWA->GWA_CCCRE  := cCustoCred		// Centro de Custo
						GWA->GWA_CTADEB := GWM->GWM_CTFRET
						GWA->GWA_CCDEB  := GWM->GWM_CCFRET		// Centro de Custo
						GWA->GWA_VLMOV  := aRatVal[_VLFRET]
						GWA->GWA_SEQ    := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
						If GWM->GWM_TPDOC $ "1;4"
							GWA->GWA_TPMOV  := "2"
						Else
							GWA->GWA_TPMOV  := "1"
						EndIf
						If lAtuRat
							GWA->GWA_UNINEG := GWM->GWM_UNINEG
						EndIf
						GWA->GWA_SITCTB := "1"
					MsUnLock("GWA")
				EndIf
			EndIf
		EndCase

	GFESaveLog()
	
Return NIL

//----------------Função para retornar as variáveis de acordo com Critério de Rateio

Function GFEGetRatVal(cCriRat)
	Local aRet := Array(6)
	
	aFill(aRet, 0)

	If Empty(cCriRat)
		cCriRat := "1"
	EndIf

//	If cCriRat == "1" .Or. !GFERatAtu()
	If cCriRat == "1" 
		aRet[1] := GWM->GWM_VLICMS
		aRet[2] := GWM->GWM_VLPIS
		aRet[3] := GWM->GWM_VLCOFI
		aRet[4] := GWM->GWM_VLFRET
		aRet[5] := Iif(GFXCP2510('GWM_VLIBS'), GWM->GWM_VLIBS, 0)
		aRet[6] := Iif(GFXCP2510('GWM_VLCBS'), GWM->GWM_VLCBS, 0)
	ElseIf cCriRat == "2"
		aRet[1] := GWM->GWM_VLICM1
		aRet[2] := GWM->GWM_VLPIS1
		aRet[3] := GWM->GWM_VLCOF1
		aRet[4] := GWM->GWM_VLFRE1
		aRet[5] := Iif(GFXCP2510('GWM_VLIBS1'), GWM->GWM_VLIBS1, 0)
		aRet[6] := Iif(GFXCP2510('GWM_VLCBS1'), GWM->GWM_VLCBS1, 0)
	ElseIf cCriRat == "3"
		aRet[1] := GWM->GWM_VLICM3
		aRet[2] := GWM->GWM_VLPIS3
		aRet[3] := GWM->GWM_VLCOF3
		aRet[4] := GWM->GWM_VLFRE3
		aRet[5] := Iif(GFXCP2510('GWM_VLIBS3'), GWM->GWM_VLIBS3, 0)
		aRet[6] := Iif(GFXCP2510('GWM_VLCBS3'), GWM->GWM_VLCBS3, 0)
	ElseIf cCriRat == "4"
		aRet[1] := GWM->GWM_VLICM2
		aRet[2] := GWM->GWM_VLPIS2
		aRet[3] := GWM->GWM_VLCOF2
		aRet[4] := GWM->GWM_VLFRE2
		aRet[5] := Iif(GFXCP2510('GWM_VLIBS2'), GWM->GWM_VLIBS2, 0)
		aRet[6] := Iif(GFXCP2510('GWM_VLCBS2'), GWM->GWM_VLCBS2, 0)
	EndIf
	
Return aRet

// Retorna a conta correspondente e o centro de custo relacionado a filial e transacao informadas
Static Function CtaFilial(cCdFilial,cNrTrans)
	Local cCtaFilial := ""
	Local cCCustoFil := ""

	dbSelectArea("GUS")
	dbSetOrder(1)
	If dbSeek(xFilial("GUS") + cCdFilial)

		Do Case
			// Conta Provisão
			Case cNrTrans == "300"
				cCtaFilial := GUS->GUS_CTPROV
				cCCustoFil := GUS->GUS_CCCTPR

			// Conta ICMS
			Case cNrTrans == "301"
				cCtaFilial := GUS->GUS_CTTRIC
				cCCustoFil := GUS->GUS_CCTRIC

			// Conta PIS
			Case cNrTrans == "302"
				cCtaFilial := GUS->GUS_CTTRPI
				cCCustoFil := GUS->GUS_CCTRPI

			// Conta COFINS
			Case cNrTrans == "303"
				cCtaFilial := GUS->GUS_CTTRCO
				cCCustoFil := GUS->GUS_CCTRCO

			// Conta Frete
			Case cNrTrans == "310"
				cCtaFilial := GUS->GUS_CTFRET
				cCCustoFil := GUS->GUS_CCFRET

			// Conta ICMS
			Case cNrTrans == "311"
				cCtaFilial := GUS->GUS_CTICMS
				cCCustoFil := GUS->GUS_CCICMS

			// Conta PIS
			Case cNrTrans == "312"
				cCtaFilial := GUS->GUS_CTPIS
				cCCustoFil := GUS->GUS_CCPIS

			// Conta COFINS
			Case cNrTrans == "313"
				cCtaFilial := GUS->GUS_CTCOFI
				cCCustoFil := GUS->GUS_CCCOFI

			// Conta Frete
			Case cNrTrans == "100"
				cCtaFilial := GUS->GUS_CTFRET
				cCCustoFil := GUS->GUS_CCFRET

			//Case cNrTrans == "101"
			//Case cNrTrans == "102"
			//Case cNrTrans == "118"
			//Case cNrTrans == "126"
			//Case cNrTrans == "127"
	//		Otherwise cCtaFilial := ""
		EndCase
	Else
		GFERatLog(Space(7) + STR0173 + cValToChar(cCdFilial)) //"Não foi encontrada Conta Contábil para a Filial "
		GFERatLog(Space(7) + "Criando Movimentos com Conta Contábil em branco")
	Endif

Return {cCtaFilial,cCCustoFil}

// Retorna a proxima sequencia do movimento contábil para uma transação
Static Function ProxSeq(cNrTrans)
	Local nSeq := 0
	
	If cNrTrans == "100"
		nSeq := nSeq100
	ElseIf cNrTrans == "300"
		nSeq := nSeq300
	ElseIf cNrTrans == "301"
		nSeq := nSeq301
	ElseIf cNrTrans == "302"
		nSeq := nSeq302
	ElseIf cNrTrans == "303"
		nSeq := nSeq303
	ElseIf cNrTrans == "310"
		nSeq := nSeq310
	ElseIf cNrTrans == "311"
		nSeq := nSeq311
	ElseIf cNrTrans == "312"
		nSeq := nSeq312
	ElseIf cNrTrans == "313"
		nSeq := nSeq313
	Else
		nSeq := -1
	EndIf
	
	If nSeq == -1
		dbSelectArea("GWA")
		dbSetOrder(1)
		dbSeek(xFilial("GWA")+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS)+PadR(cNrTrans,10))
		While !Eof() .And. GWA->GWA_FILIAL          == GWM->GWM_FILIAL .And.;
				GWA->GWA_TPDOC           == GWM->GWM_TPDOC  .And.;
				Alltrim(GWA->GWA_CDTRAN) == cNrTrans        .And.;
				GWA->GWA_CDESP           == GWM->GWM_CDESP  .And.;
				GWA->GWA_CDEMIT          == GWM->GWM_CDTRP  .And.;
				GWA->GWA_SERIE           == GWM->GWM_SERDOC .And.;
				GWA->GWA_NRDOC           == GWM->GWM_NRDOC  .And.;
				GWA->GWA_DTEMIS          == GWM->GWM_DTEMIS
				nSeq++
			dbSelectArea("GWA")
	
			GWA->( dbSkip() )
		EndDo
		
		If nSeq == -1
			nSeq := 0
		EndIf
	Else
		nSeq++
	EndIf
	
	If cNrTrans == "100"
		nSeq100 := nSeq
	ElseIf cNrTrans == "300"
		nSeq300 := nSeq
	ElseIf cNrTrans == "301"
		nSeq301 := nSeq
	ElseIf cNrTrans == "302"
		nSeq302 := nSeq
	ElseIf cNrTrans == "303"
		nSeq303 := nSeq
	ElseIf cNrTrans == "310"
		nSeq310 := nSeq
	ElseIf cNrTrans == "311"
		nSeq311 := nSeq
	ElseIf cNrTrans == "312"
		nSeq312 := nSeq
	ElseIf cNrTrans == "313"
		nSeq313 := nSeq
	EndIf
	
Return nSeq

/*---------------------------------------------------------
Função temporária para verificar se o usuário
tem os campos para realizar o rateio por todos os campos.
---------------------------------------------------------*/
//Function GFERatAtu()
	//Função temporária removida 03/10/2013
//Return .F.

/*---------------------------------------------------------
Função para retornar as informações dos grupos contábeis
---------------------------------------------------------*/
Static Function GFEXFUNCDG(aGrupo)

	Local aGrpCtb := {" Filial", " Tipo Operação", "Item", " Reg Comecial", " Grupo Emitente", " Tipo Doc Carga", ;
					  " Classificação Frete", " Tipo de Frete", " Info Contábil 1", " Info Contábil 2", " Info Contábil 3", ;
					  " Info Contábil 4", " Info Contábil 5", " Representante", "Unidade de Negócio", "CFOP Item Doc Carga", "Tipo de Serviço", ;
					  " Grupo de Transportador","Série Doc Carga"}
	Local aPar := { SuperGetMv("MV_TPGRP1",,"0"), ;
				    SuperGetMv("MV_TPGRP2",,"0"), ;
				    SuperGetMv("MV_TPGRP3",,"0"), ;
				    SuperGetMv("MV_TPGRP4",,"0"), ;
				    SuperGetMv("MV_TPGRP5",,"0"), ;
				    SuperGetMv("MV_TPGRP6",,"0"), ;
				    SuperGetMv("MV_TPGRP7",,"0") }	
	Local nGrp
	Local cDescGrp := ""
	
	For nGrp := 1 To Len(aGrupo)

		If !Empty(aPar[nGrp]) .And. aPar[nGrp] != "0"

			If !Empty(cDescGrp)
				cDescGrp += ","
			Else
				cDescGrp += "    Grupos Contábeis: " + CRLF + "      "
			EndIf

			cDescGrp += aGrpCtb[Val(aPar[nGrp])] + ": " + IIf(Empty(aGrupo[nGrp]), "VAZIO", AllTrim(aGrupo[nGrp]))

		EndIf

	Next nGrp

Return cDescGrp

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNCTAB
Criação da tabela temporária.

@author Elynton Fellipe Bazzo
@since  26/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNCTAB()
	Local cBanco	:= TCGetDB()
	
	aDcCarga := {{"FILIAL" ,"C",TAMSX3("GW1_FILIAL")[1],0},;
				 {"CDTPDC" ,"C",05,0},;
				 {"EMISDC" ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
				 {"SERDC"  ,"C",TAMSX3("GW1_SERDC")[1],0},;
				 {"CDESP"  ,"C",05,0},;
				 {"NRDC"   ,"C",16,0}}
		
	If cBanco == "OPENEDGE"
		cAlidc := GFECriaTab({aDCCarga, {"EMISDC+CDTPDC+SERDC+NRDC"}}) 
	Else
		cAlidc := CriTabTemp({aDCCarga, {"FILIAL+EMISDC+CDTPDC+SERDC+NRDC"}})
	EndIf
	
	_SetOwnerPrvt("cAliDcCarg",cAlidc)
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNCDTAB
Deleção da tabela temporária.

@author Elynton Fellipe Bazzo
@since  26/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNCDTAB()
	GFEDelTab(cAliDcCarg)
Return


Function GFEXCTFR(aDadosCT)

	Local ni := 0
	
	For ni := 1 to len(aDadosCT)
		
		if !empty(aDadosCT[ni][8])
		
			GXT->( dbSetOrder(1) )	
			If GXT->(dbSeek(xFilial("GXT")+PADR(aDadosCT[ni][8], TamSX3("GXT_NRCT")[1])))
			
				IF aDadosCT[ni][2] == '1' // Cálculo
										
					GXY->( dbSetOrder(1) )	
					If !GXY->(dbSeek(xFilial("GXY")+PADR(aDadosCT[ni][8], TamSX3("GXT_NRCT")[1])+PADR(aDadosCT[ni][1], TamSX3("GWF_FILIAL")[1])+PADR(aDadosCT[ni][6], TamSX3("GWF_NRCALC")[1])))
						RecLock("GXY", .T.)				
							GXY->GXY_FILIAL := xFilial("GXY")
							GXY->GXY_NRCT   := PADR(aDadosCT[ni][8], TamSX3("GXT_NRCT")[1])
							GXY->GXY_FILCA  := PADR(aDadosCT[ni][1], TamSX3("GWF_FILIAL")[1])
							GXY->GXY_NRCALC := PADR(aDadosCT[ni][6], TamSX3("GWF_NRCALC")[1])							
						
					Else
						RecLock("GXY", .F.)
									
					Endif
					
					GXY->GXY_VLPREV += aDadosCT[ni][9]
					MsUnLock("GXY")
						
					RecLock("GXT", .F.)	
						GXT->GXT_VLPREV += aDadosCT[ni][9]
					MsUnLock("GXT")
		
				elseif aDadosCT[ni][2] == '2' // Docto Frete
					
					GXZ->( dbSetOrder(1) )	
					If !GXZ->(dbSeek(xFilial("GXZ")+PADR(aDadosCT[ni][8], TamSX3("GXT_NRCT")[1])+PADR(aDadosCT[ni][1], TamSX3("GW3_FILIAL")[1])+PADR(aDadosCT[ni][3], TamSX3("GW3_CDESP")[1])+PADR(aDadosCT[ni][4], TamSX3("GW3_EMISDF")[1])+PADR(aDadosCT[ni][5], TamSX3("GW3_SERDF")[1])+PADR(aDadosCT[ni][6], TamSX3("GW3_NRDF")[1])))
						RecLock("GXZ", .T.)				
							GXZ->GXZ_FILIAL := xFilial("GXZ")
							GXZ->GXZ_NRCT   := PADR(aDadosCT[ni][8], TamSX3("GXT_NRCT")[1])
							GXZ->GXZ_FILDF  := PADR(aDadosCT[ni][1], TamSX3("GW3_FILIAL")[1])
							GXZ->GXZ_CDESP  := PADR(aDadosCT[ni][3], TamSX3("GW3_CDESP")[1]) 
							GXZ->GXZ_EMISDF := PADR(aDadosCT[ni][4], TamSX3("GW3_EMISDF")[1])
							GXZ->GXZ_SERDF  := PADR(aDadosCT[ni][5], TamSX3("GW3_SERDF")[1]) 
							GXZ->GXZ_NRDF   := PADR(aDadosCT[ni][6], TamSX3("GW3_NRDF")[1])
							GXZ->GXZ_DTEMIS := aDadosCT[ni][7]  
							GXZ->GXZ_VLREAL := aDadosCT[ni][9]
						GXZ->(MsUnLock())	

						RecLock("GXT", .F.)	
							GXT->GXT_VLREAL += aDadosCT[ni][9]
						GXT->(MsUnLock())

						// Verifica se o cálculo relacionado está no contrato e elimina do valor previsto
						GW4->(dbSetOrder(1))
						GW4->(dbSeek(PADR(aDadosCT[ni][1], TamSX3("GW3_FILIAL")[1])+PADR(aDadosCT[ni][4], TamSX3("GW3_EMISDF")[1])+PADR(aDadosCT[ni][3], TamSX3("GW3_CDESP")[1])+PADR(aDadosCT[ni][5], TamSX3("GW3_SERDF")[1])+PADR(aDadosCT[ni][6], TamSX3("GW3_NRDF")[1])))		
						While !GW4->(Eof()) .And. GW4->(GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF) == PADR(aDadosCT[ni][1], TamSX3("GW3_FILIAL")[1])+PADR(aDadosCT[ni][4], TamSX3("GW3_EMISDF")[1])+PADR(aDadosCT[ni][3], TamSX3("GW3_CDESP")[1])+PADR(aDadosCT[ni][5], TamSX3("GW3_SERDF")[1])+PADR(aDadosCT[ni][6], TamSX3("GW3_NRDF")[1])
							
							GW1->( dbSetOrder(1) )
							If GW1->( dbSeek(xFilial("GW4") + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )						
								
								GWH->( dbSetOrder(2) )
								If GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
								
									GWF->( dbSetOrder(1) )	
									If GWF->(dbSeek(xFilial("GWF")+GWF->GWF_NRCALC))								
																		
										IF GWF->GWF_TPCALC == GW3->GW3_TPDF
									
											GXY->( dbSetOrder(2) )	
											If GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
											
												// Somente se o cálculo estiver no mesmo contrato
												if GXY->GXY_NRCT == cNrCt
											
													IF GXY->GXY_VLPREV > 0
													
														GXT->( dbSetOrder(1) )	
														If GXT->(dbSeek(GXY->GXY_FILIAL+GXY->GXY_NRCT))
															RecLock("GXT", .F.)
																GXT->GXT_VLPREV := GXT->GXT_VLPREV - GXY->GXY_VLPREV
															MsUnLock("GXT")
														ElseIf GXT->(dbSeek(xFilial("GXT") + GXY->GXY_NRCT))
															RecLock("GXT", .F.)
																GXT->GXT_VLPREV := GXT->GXT_VLPREV - GXY->GXY_VLPREV
															MsUnLock("GXT")
														ENDIF									
													ENDIF
												ENDIF
											Endif	
										Endif																	
									Endif												
								EndIf																									
							EndIf								
						
							dbSelectArea("GW4")
							GW4->(dbSkip())				
						EndDo
					EndIf						
				EndIf			
			ENDIF		
		endif
	Next
Return
