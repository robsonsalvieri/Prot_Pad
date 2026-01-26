#INCLUDE "GFEA116A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cGXI_NRFAT := TamSx3("GXI_NRFAT")[1]
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116IMP
EDI - Importação de Fatura de Frete


GXI - Espelho da GW6
GXJ - Espelho da GW3

@author Israel A. Possoli
@since 17/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA116IMP()
	Private tTabFAT				// Tabela temporária da Fatura
	Private tTabCTRC			// Tabela temporárias dos Conhecimentos vinculados na fatura
	Private aCamposFAT := {}	// Campos da tabela intermediária de Fatura
	Private aCamposCTRC := {}	// Campos da tabela intermediária de Conhecimentos
	Private oProcess := Nil
	Private lVerPerg := .T.

	If IsBlind()
		
		CriaTab()
	
		Importacao()

		GFEDelTab(tTabFAT)
		GFEDelTab(tTabCTRC)
	
	Else
		// Início Ponto de Entrada Procomp
	 	If ExistBlock("GFEXPERG")   
		    lVerPerg := ExecBlock("GFEXPERG",.f.,.f.,{})
	 	EndIf
		// Fim Ponto de Entrada Procomp
			
		If Pergunte("GFEA116",lVerPerg) .Or. !lVerPerg
			CriaTab()
	
			oProcess := MsNewProcess():New({|| Importacao()}, "EDI - Importação DocCob", "Importando arquivos")
			oProcess:Activate()
	
			GFEDelTab(tTabFAT)
			GFEDelTab(tTabCTRC)
			If !Empty(MV_PAR08) .or. MV_PAR08 != ""
				If MV_PAR08 == 2
					GFEA116PRO()
				EndIf
			EndIf
		Else
			Return .F.
		EndIf
	EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116PRO
Processamento das Ocorrências importadas

GXI - Fatura
GXJ - Doc de Frete

@author Israel A. Possoli
@since 03/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA116PRO()
	If IsBlind()
		Processamento()
	Else
		Processa({|| Processamento()},"Processando registros", "")
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTab
Criação das tabelas temporárias

@author Israel A. Possoli
@since 14/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab()

	aCamposFAT := { {"GXI_FILIAL", "C", TamSx3("GXI_FILIAL")[1],  0},;
					{"GXI_NRIMP" , "C", 16, 0},;
					{"GXI_EDINRL", "N", 5,  0},;
					{"GXI_EDILIN", "M", 999, 0},;
					{"GXI_EDIARQ", "C", 200, 0},;
					{"GXI_EDISIT", "C", 1,  0},;
					{"GXI_EDIMSG", "M", 10, 0},;
					{"GXI_FILFAT", "C", TamSx3("GXI_FILIAL")[1], 0},;
					{"GXI_EMIFAT", "C", 14, 0},;
					{"GXI_SERFAT", "C", 5,  0},;
					{"GXI_NRFAT" , "C", 16, 0},;
					{"GXI_DTEMIS", "D", 8,  0},;
					{"GXI_VLFATU", "N", 12, 2},;
					{"GXI_VLDESC", "N", 12, 2},;
					{"GXI_VLICMS", "N", 12, 2},;
					{"GXI_VLJURO", "N", 12, 2},;
					{"GXI_IMPRET", "N", 9,  2},;
					{"GXI_ISSRET", "N", 9,  2},;
					{"GXI_DTVENC", "D", 8,  0};
					}
	
	dbSelectArea("GXI")
	aAdd(aCamposFAT,{"GXI_ACAO", "C", 1,  0})
					
	tTabFAT := GFECriaTab({aCamposFAT,{"GXI_FILIAL+GXI_NRIMP"}})

	aCamposCTRC := {{"GXJ_FILIAL", "C",	TamSx3("GXI_FILIAL")[1],  0},;
					{"GXJ_NRIMP" , "C",	16, 0},;
					{"GXJ_SEQ"   , "C",	5,  0},;
					{"GXJ_FILDF" , "C",	TamSx3("GXI_FILIAL")[1],  0},;
					{"GXJ_SERDF" , "C",	5,  0},;
					{"GXJ_NRDF"  , "C",	16, 0},;
					{"GXJ_CDESP" , "C",	5,  0},;
					{"GXJ_EMISDF", "C",	14, 0},;
					{"GXJ_DTEMIS", "D",	8,  0};
					}
	tTabCTRC := GFECriaTab({aCamposCTRC,{"GXJ_FILIAL+GXJ_NRIMP"}})

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Importacao

EDI - Importação da Fatura de Frete

@author Felipe Rafael Mendes
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importacao()
	Local aDirImpor   := {}		// Array com os arquivos do diretorio
	Local nCountFiles := 0  	// Contador dos arquivos do diretorio
	Local cLayoutVer  := "" 	// Versão do Layout 3 ou 5
	Local cFormatDt
	Local cFormatTm
	Local cNewNomeArq	:= ""
	Local cDiretorio	:= AllTrim(MV_PAR04)
	Local cDirOk		:= AllTrim(MV_PAR05)
	Local cDirErro		:= AllTrim(MV_PAR06)
	Local bCtrlFluxo	:= Nil
	Local lArquivoValido
	Local cBuffer		:= ""
	Private lArquivoImportado
	Private cFilialFat
	Private cTransIni
	Private cTransFim
	Private cNomeArq
	Private nNRIMP		:= 0
	Private nCountImpor := 0  	// Contador de arquivos importados
	Private cMsgPreVal	:= ""	// Armazena as mensagens de pré-validações para o Campo Observação (Importação)
	Private GFELog116 	:= GFELog():New("EDI_Doccob_Importacao", "EDI Faturas/Doccob - Importação", SuperGetMV('MV_GFEEDIL',,'1'))
	Private GFEResult := GFEViewProc():New()
	Private GFEFile     := GFEXFILE():New()

	cTransIni	:= MV_PAR01
	cTransFim	:= MV_PAR02
	cFilialFat 	:= MV_PAR03

	GFELog116:Add("Parâmetros" + CRLF + Replicate("-", 20))
	GFELog116:Add("Transportador De.: " + cTransIni)
	GFELog116:Add("Transportador Até: " + cTransFim)
	GFELog116:Add("Filial Fatura....: " + cFilialFat)
	GFELog116:Add("Dir. Importação..: "  + cDiretorio)
	GFELog116:Add("Dir. Backup OK...: "  + cDirOk)
	GFELog116:Add("Dir. Backup Erros: "  + cDirErro)
	GFELog116:NewLine()

	If Empty(cFilialFat)
		cFilialFat := xFilial("GW6")
		GFELog116:Add("** Filial da fatura em branco. Filial atual atribuída: " + cFilialFat)
	EndIf

	// Validação do diretório de importação
	If Empty(cDiretorio)
		GFELog116:Add("** " + "Diretório de importação deve ser informado.")
		GFELog116:EndLog()
		MsgAlert("Diretório de importação deve ser informado.", "Aviso")
		Return
	EndIf

	aDirImpor := DIRECTORY(cDiretorio + "\*.TXT" )

	// Verifica se existe arquivos no diretório informado
	If Len(aDirImpor) == 0
		GFELog116:Add("** " + "Nenhum arquivo encontrado no diretório " + cDiretorio)
		GFELog116:EndLog()
		MsgAlert("Nenhum arquivo encontrado no diretório " + cDiretorio, "Aviso")
		Return
	Endif

	// Data e Hora
	cFormatDt := stuff(DTOC(date()),3,1,'')
	cFormatDt := stuff(cFormatDt,5,1,'')

	cFormatTm := stuff(Time(),3,1,'')
	cFormatTm := stuff(cFormatTm,5,1,'')

	GFELog116:Add("- Início da importação")
	GFELog116:NewLine()
	GFELog116:Save()

	If oProcess != Nil
		oProcess:SetRegua1(Len(aDirImpor) * 2)
	EndIf

	For nCountFiles := 1 To Len(aDirImpor)
		lArquivoValido 	  := .T.
		lArquivoImportado := .T.

		cNomeArq := aDirImpor[nCountFiles][1]

		If oProcess != Nil
			oProcess:IncRegua1(cNomeArq)
		EndIf

		GFELog116:Add(Replicate("-", 80))
		GFELog116:Add("[" + ALLTRIM(STR(nCountFiles)) + "] Arquivo: " + cNomeArq)

		If oProcess != Nil
			oProcess:SetRegua2(100)
			oProcess:IncRegua2("Carregando arquivo")
			bCtrlFluxo 	  := "oProcess:IncMeter(oProcess:oMeter2, Round(nPosFile * 100 / nLenghtFile, 0))"
		EndIf

		GFEFile:Clear()
		GFEFile:Open(cDiretorio + "\" + cNomeArq, bCtrlFluxo)

		If oProcess != Nil
			oProcess:IncRegua1()
			oProcess:IncRegua2("Validando layout")
			oProcess:SetRegua2(GFEFile:nQtdeLin)
		EndIf
		
		If !GFEFile:FEof()
			cBuffer := FwNoAccent(GFEFile:Line())
			GFELog116:AddDebug("# LINHA ARQUIVO: " + cBuffer)
		EndIf

		//Se o Arquivo estiver em branco retornará uma mensagem em telae e no log e continuará a importação
		If Empty(cBuffer)
			GFELog116:Add("  ** Arquivo em branco.")
			GFELog116:Add("  ** Linha: " + cBuffer)
			GFEResult:AddErro("Arquivo: " + cNomeArq + "' em branco.")
			lArquivoValido := .F.
		EndIf

		// Verifica se é um arquivo válido. Identificador '000'.
		If SubStr(cBuffer,01,03) != "000"
			GFELog116:Add("  ** Arquivo inválido. Não foi possível encontrar o Registro '000' - Cabeçalho de Intercâmbio.")
			GFELog116:Add("  ** Linha: " + cBuffer)
			GFEResult:AddErro("Arquivo: " + cNomeArq + "' inválido.")
			GFELog116:NewLine()
			GFELog116:Save()
			lArquivoValido := .F.
		EndIf

		// Validação da versão do Layout
		If lArquivoValido
			GFEFile:FNext()
			cBuffer := FwNoAccent(GFEFile:Line())

			// Identifica a versão Layout do arquivo
			cLayoutVer := SubStr(cBuffer, 01, 03)

			// Valida a versão do layout do arquivo
			If (cLayoutVer != "350" .AND. cLayoutVer != "550") .OR. Empty(cLayoutVer)
				GFELog116:Add("** " + "Arquivo '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.", 1)
				GFELog116:Save()
				GFEResult:AddErro("Arquivo: " + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.")
				lArquivoValido := .F.
			EndIf
		EndIf

		// Leitura do Arquivo e Gravação do Arquivo
		If lArquivoValido
			IncProc()
			If cLayoutVer == "350"
				LayoutPro3()
			ElseIf cLayoutVer == "550"
				GFEA116B()
			Else
				lArquivoValido := .F.
			EndIf

			// Gravação para na tabela intermediária
			GerarGXI()
		EndIf

		// Transferência do arqivos para os diretórios de Ok e NOk
		cNewNomeArq := cFormatDt + "_" + cFormatTm + "_" + cNomeArq
		 If lArquivoValido .And. lArquivoImportado //se chegar ao fim do arquivo sem erros
			If (FRename(cDiretorio + "\" + cNomeArq, cDirOk + "\" + cNewNomeArq) == -1)
				GFELog116:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq, "Aviso")
			EndIf
		Else
			If (FRename(cDiretorio + "\" + cNomeArq, cDirErro + "\" + cNewNomeArq) == -1)
				GFELog116:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq, "Aviso")
			EndIf
		EndIf

		If lArquivoValido .AND. lArquivoImportado
			GFEResult:Add("ARQUIVO IMPORTADO.")
		Else
			GFEResult:Add("ARQUIVO NÃO IMPORTADO.")
		Endif
	Next

	If nCountImpor == 0
		GFELog116:Add("Nenhuma fatura foi importada para a faixa informada.")
	EndIf

	GFELog116:EndLog()
	
	If !Empty(MV_PAR08) .or. MV_PAR08 != ""
		If MV_PAR08 == 1 
			If lVerPerg
				GFEResult:Show("Importação de arquivos", "Arquivos", "Erros", "Ocorreram erros na importação")			
			EndIf
		EndIf
	Else
		IF lVerPerg
			GFEResult:Show("Importação de arquivos", "Arquivos", "Erros", "Ocorreram erros na importação")
		Endif
	EndIf
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarGXI
Geração da tabela intermediária GXI e GXJ

@author Israel A Possoli
@since 15/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarGXI()
	Local nI
	Local cNRIMP

	dbSelectArea((tTabFAT))
	dbGoTop()

	// Conhecimentos
	While !(tTabFAT)->(EOF())
		cNRIMP := GETSXENUM("GXI", "GXI_NRIMP")

		RecLock("GXI", .T.)
			GXI->GXI_FILIAL := xFilial("GXI")
			GXI->GXI_NRIMP  := cNRIMP
			GXI->GXI_MARKBR := Iif(IsBlind(), "", oBrowse116:Mark())
			GXI->GXI_USUIMP := cUserName
			GXI->GXI_DTIMP  := DDATABASE
			GXI->GXI_ALTER  := "2"

			// Grava todos os campos, com execção do GXG_FILIAL e GXG_NRIMP
			For nI := 3 To Len(aCamposFAT)
				&("GXI->" + aCamposFAT[nI][1] + " := (tTabFAT)->" + aCamposFAT[nI][1])
			Next
		MsUnlock("GXI")

		ConfirmSX8()

		// Notas Fiscais
		dbSelectArea((tTabCTRC))
		dbSeek((tTabFAT)->GXI_FILIAL + (tTabFAT)->GXI_NRIMP)
		While !(tTabCTRC)->(EOF()) .AND. ;
      		   (tTabCTRC)->GXJ_FILIAL = (tTabFAT)->GXI_FILIAL .AND. (tTabCTRC)->GXJ_NRIMP = (tTabFAT)->GXI_NRIMP

			RecLock("GXJ", .T.)
				GXJ->GXJ_FILIAL := xFilial("GXJ")
				GXJ->GXJ_NRIMP	:= cNRIMP
				For nI := 3 To Len(aCamposCTRC)
					&("GXJ->" + aCamposCTRC[nI][1] + " := (tTabCTRC)->" + aCamposCTRC[nI][1])
				Next
			MsUnlock("GXJ")

			(tTabCTRC)->(dbSkip())
		EndDO
		(tTabFAT)->(dbSkip())
	EndDo

	dbSelectArea((tTabFAT))
	Zap

	dbSelectArea((tTabCTRC))
	Zap

Return Nil

/*
	- Utilizada na função LayoutPro3
	- Busca o doc. de frete pela e série e número.
	- Os valores de série e número são modificados ao longo da função LayoutPro3, até que se enquadre em uma das parametrizações.
*/
Static Function PosValGW3(cSerie, cNumero, cCNPJ)
	Local lRet := .F.
	Local cEmisDF := ""
	
	dbSelectArea("GU3")
	GU3->( dbSetOrder(11) )
	If GU3->(dbSeek(xFilial("GU3") + cCNPJ))	
		While GU3->(!Eof()) .And. GU3_FILIAL = xFilial("GU3") .And. Alltrim(GU3->GU3_IDFED) == AllTrim(cCNPJ)	
	  		cEmisDf := (GU3->GU3_CDEMIT)
	  		If GU3->GU3_FORN == "1"
	      		Exit   
	  		Endif	  
	  		GU3->(dbSkip())	
    	EndDo
	EndIf 
	
	dbSelectArea("GW3")
	GW3->(dbSetOrder(12))
	If GW3->(dbSeek(cEmisDf+cSerie+cNumero))
		While GW3->(!Eof()) .And. GW3->GW3_SERDF == PadR(cSerie,TamSX3("GW3_SERDF")[1])  .And. GW3->GW3_NRDF == PadR(cNumero, TamSX3("GW3_NRDF")[1])
			If AllTrim(Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_IDFED")) == AllTrim(cCNPJ) .Or. ; 
		       AllTrim(Posicione("GU3",1,xFilial("GU3")+Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_CDEMFT"),"GU3_IDFED")) == AllTrim(cCNPJ)
				lRet := .T.
				Exit
			EndIf
			
			GW3->(dbSkip())	
		EndDo
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LayoutPro3
EDI - Importação de Documento de Frete

@author Felipe Rafael Mendes
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LayoutPro3()
	Local cBuffer		:= ""
	Local nContDF		:= 1
	Local nContLinhas	:= 0        // Contador de Linhas do arquivo
	Local nCountFatArq	:= 0		// Contador de Faturas por arquivo
	Local lDocFind		:= .F.
	Local nI			:= 0
	Local nJ			:= 0
	Local cCdTrp		:= ""
	Local cCGCTrp		:= ""
	Local cNrDf			:= ""
	Local nQtNumDF		:= 0
	Local rTabFAT[2]				// Chave da tabela temporária tTabFAT, FILIAL + NRIMP
	// Documento de Frete relacionado a Fatura
	/* 	[1] Filial
		[2] Sequência
		[3] Série
		[4] Número
		[5] Código Emitente
		[6] Espécie
		[7] Data de Emissão
		[8] CGC Emissor
		[9] Cod. Emit. Transp. Fatur
		[10] CNPJ Transp. Fatur
	*/
	Local aDocFrete[11]
	Local aEmitFatura	:= {}
	Local nContPrev		:= 0
	Local cSerDFBase	:= ""
	Local cNrDFBase		:= ""
	Local cEmitFatura	:= ""
	Local cAcao
	Local lResultCabecalho := .T.
	Local s_ESPDF2   	:= SuperGetMv("MV_ESPDF2",,"")
	Local s_ESPDF1   	:= SuperGetMv("MV_ESPDF1",,"")
	Local cMsgRet  		:= ""
	Local dDtEmiDF      := Nil
	Local cCodEmisLin   := ""
	Local dDtVenc       := Nil
	Local dDtRetorno    := Nil
	Local s_GFE116A2    := ExistBlock("GFE116A2")
	Local cEmitGW3	    := ""
	Local cEmitFT		:= ""

	If oProcess != Nil
		oProcess:SetRegua2(GFEFile:nQtdeLin)
	EndIf

	GFEResult:Add(Replicate('-', 50) + CHR(13) + CHR(10) + UPPER(cNomeArq) + CHR(13) + CHR(10) + Replicate('-', 50), 0)

	// Fixar a variavel 
	If IsBlind()
		cFilialFat := xFilial("GXI")
	EndIf

	//faça enquanto não chega o fim do arquivo
	nContLinhas := 0
	nCountFatArq := 0
	rTabFAT[1] := ""
	rTabFAT[2] := ""
	While !GFEFile:FEof()
		If oProcess != Nil
			oProcess:IncRegua2()
		EndIf

		nContLinhas++

		cBuffer := FwNoAccent(GFEFile:Line())
		GFELog116:AddDebug("# LINHA ARQUIVO: " + cBuffer)

		//comparar com a faixa de seleção
		If SubStr(cBuffer,01,03) == "351"
			lResultCabecalho := .T.
			rTabFAT[1] := ""
			rTabFAT[2] := ""
			cCGCTrp	:= AllTrim(SubStr(cBuffer,04,14))
			
			//Posiciona o arquivo para frente, podendo enxergar o primeiro Documento de Frete
			While SubStr(cBuffer,01,03) != "353"
				GFEFile:FNext()
				If !GFEFile:FEof()
					cBuffer := FwNoAccent(GFEFile:Line())
					nContPrev++
				Else
					GFELog116:Add("  ** Não foi possível encontrar o Registro '353' - Conhecimentos em Cobrança.")
					GFEResult:Add("Não foi possível encontrar o Registro '353' - Conhecimentos em Cobrança.")
					GFEResult:SetWarningIcon()
					lArquivoImportado := .F.
					Return
				EndIf
			EndDo
			
			cSerDFBase := PadR(AllTrim(SubStr(cBuffer,14,05)), TamSX3("GW3_SERDF")[1])	// Série DF
			cNrDFBase := PadR(AllTrim(SubStr(cBuffer,19,12)), TamSX3("GW3_NRDF")[1])		// Nùmero DF
			
			GFELog116:Add("# Selecionando primeiro Documento de Frete relacionado: Série [" + cSerDFBase + "] Número [" + cNrDFBase + "]" , 1)
			
			//Busca o Emitente relacionado ao Documento de Frete
			lDocFind := PosValGW3(cSerDFBase, cNrDFBase, cCGCTRP)
						
			// Caso não tenha encontrado pela série+numero, tenta manipular a formatação do número
			If !lDocFind
				
				// Precisa BUSCAR um documento de frete, alterando o número conforme configurações.
				nQtNumDF := Posicione("GVT",1,xFilial("GVT")+s_ESPDF1,"GVT_QTALG") // Espécie ICMS
				If nQtNumDF > 0 				
					GFELog116:AddDebug("** Documento de Frete base não encontrado. Buscando pela espécie: [" + s_ESPDF1 + "]. Numeração: " + AllTrim(Str(nQtNumDF)), 2)
					cNrDFBase := PadL(AllTrim(GFEZapZero(cNrDFBase)), nQtNumDF, "0")
					lDocFind := PosValGW3(cSerDFBase, cNrDFBase, cCGCTRP)
				EndIf
				
				If !lDocFind
					nQtNumDF := Posicione("GVT",1,xFilial("GVT")+s_ESPDF1,"GVT_QTALG") // Espécie ISS
					If nQtNumDF > 0 				
						GFELog116:AddDebug("** Documento de Frete base não encontrado. Buscando pela espécie: [" + s_ESPDF2 + "]. Numeração: " + AllTrim(Str(nQtNumDF)), 2)
						cNrDFBase := PadL(AllTrim(GFEZapZero(cNrDFBase)), nQtNumDF, "0")
						lDocFind := PosValGW3(cSerDFBase, cNrDFBase, cCGCTRP)
					EndIf
					
					If !lDocFind
						cNrDf 	:= AllTrim(GFEZapZero(cNrDFBase))
						
						GFELog116:AddDebug("** Documento de Frete base não encontrado. Preenchendo com zeros a esquerda. Número: [" + cNrDf + "]", 2)
						
						For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
							cNrDFBase := PadL(cNrDf, nI, "0")
							
							lDocFind := PosValGW3(cSerDFBase, cNrDFBase, cCGCTRP)
							If lDocFind
								Exit
							EndIf
						Next
						
					EndIf
				EndIf
			EndIf
			
			// Se encontrar um DF base
			If lDocFind
				GFELog116:Add("** Documento de Frete encontrado. Série: "+GW3->GW3_SERDF+" Número: " + GW3->GW3_NRDF + " Emissor: " + GW3->GW3_EMISDF , 1)
				
				cCdTrp 	 	:= GW3->GW3_EMISDF
				cEmitFatura	:= GW3->GW3_EMISDF
				
				If AllTrim(Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_IDFED")) != AllTrim(cCGCTRP)
					cEmitFatura := Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_CDEMFT")
				EndIf
				
				GFELog116:Add("> Emissor DF: " + cCdTrp , 1)
				GFELog116:Add("> Emissor FT: " + cEmitFatura , 1)
			EndIf
			
			If Empty(cEmitFatura)
				dbSelectArea("GW3")   // Quando emissor da fatura é diferente do emissor doc frete
				GW3->(dbSetOrder(9)) // Busca o emissor do doc frete para encontrar o Nº do emissor de faturamento
				cNrDFBase := cNrDf  
				For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
					cNrDFBase := PadL(cNrDf, nI, "0")
					If GW3->(dbSeek(xFilial("GW3") + cSerDFBase +cNrDFBase))
						cEmitGW3 := GW3->GW3_EMISDF
						If !Empty(cEmitGW3) 
							GU3->(dbSetOrder(1))
							If GU3->(dbSeek(xFilial("GU3") + cEmitGW3))
								cEmitFT := GU3->GU3_CDEMFT
							EndIf
						EndIf
					EndIf		
				Next

			   dbSelectArea("GU3")
				GU3->( dbSetOrder(11) )
				If GU3->(dbSeek(xFilial("GU3") + cCGCTRP))	
					While GU3->(!Eof()) .And. GU3_FILIAL = xFilial("GU3") .And. Alltrim(GU3->GU3_IDFED) == AllTrim(cCGCTRP)	
	  					cCdTrp := (GU3->GU3_CDEMIT)
	  					cEmitFatura := (GU3->GU3_CDEMIT)
						If !Empty(cEmitGW3) .And. cCdTrp = cEmitFT
							cEmitFatura := cEmitFT
						EndIF 
	  					If GU3->GU3_FORN == "1"
	      					GU3->(dbSkip())	
							Loop 
	  					Endif	  
	  					GU3->(dbSkip())	
    				EndDo
				EndIf 
			EndIf
			
			//Retorna para a posição original do arquivo
			For nI := 1 To nContPrev
				GFEFile:FPrior()
			Next nI
			cBuffer := FwNoAccent(GFEFile:Line())

			If cEmitFatura >= cTransIni .And. cEmitFatura <= cTransFim
				nCountFatArq++
			Else
				GFELog116:Add("** Transportador fora da faixa.")
				GFEResult:Add("Transportador '" + cEmitFatura + "'fora da faixa informada.")
				GFEResult:SetWarningIcon()
				lArquivoImportado := .F.
				Return
			EndIf

			GFELog116:NewLine()
			If nCountFatArq > 1
				GFELog116:Add(Replicate(".", 50))
				GFELog116:NewLine()
			EndIf
			GFELog116:Add("CGC Transportador...: " + cCGCTrp)
			GFELog116:Add("Código Transportador: " + cCdTrp)

			If Empty(cCdTrp)
				GFELog116:Add("** " + "Emitente não encontrado com CNPJ/CPF: " + cCGCTrp)
			EndIf
		EndIf

		If SubStr(cBuffer,01,03) == "352"
			cAcao := SubStr(cBuffer,167,01)
			If (cAcao == "I" .OR. Empty(cAcao))
				cMsgPreVal := ""
				nCountImpor++
				nNRIMP++

				dDtVenc := StoD(SubStr(SubStr(cBuffer,36,08),5,4) + SubStr(SubStr(cBuffer,36,08),3,2) + SubStr(SubStr(cBuffer,36,08),1,2))
				
				If s_GFE116A2
					dDtRetorno := ExecBlock("GFE116A2",.F.,.F.,{cFilialFat,cEmitFatura,AllTrim(SubStr(cBuffer,15,03)),FormatNrFat(AllTrim(SubStr(cBuffer,18,10))),StoD(SubStr(SubStr(cBuffer,28,08),5,4) + SubStr(SubStr(cBuffer,28,08),3,2) + SubStr(SubStr(cBuffer,28,08),1,2))})
					If Valtype(dDtRetorno) = "D"
						dDtVenc := dDtRetorno
					EndIf
				EndIf				

				RecLock(tTabFAT, .T.)
					(tTabFAT)->GXI_FILIAL  := xFilial("GXI")
					(tTabFAT)->GXI_NRIMP   := ALLTRIM(STR(nNRIMP))

					(tTabFAT)->GXI_FILFAT  := cFilialFat
					(tTabFAT)->GXI_EMIFAT  := cEmitFatura
					(tTabFAT)->GXI_SERFAT  := AllTrim(SubStr(cBuffer,15,03))
					(tTabFAT)->GXI_NRFAT   := FormatNrFat(AllTrim(SubStr(cBuffer,18,10)))
					(tTabFAT)->GXI_DTEMIS  := StoD(SubStr(SubStr(cBuffer,28,08),5,4) + SubStr(SubStr(cBuffer,28,08),3,2) + SubStr(SubStr(cBuffer,28,08),1,2))
					(tTabFAT)->GXI_DTVENC  := dDtVenc
					(tTabFAT)->GXI_VLFATU  := Val(Transform(SubStr(cBuffer,44,15),  '@R 9999999999999.99'))
					(tTabFAT)->GXI_VLICMS  := Val(Transform(SubStr(cBuffer,62,15),  '@R 9999999999999.99'))
					(tTabFAT)->GXI_VLJURO  := Val(Transform(SubStr(cBuffer,77 ,15), '@R 9999999999999.99'))
					(tTabFAT)->GXI_VLDESC  := Val(Transform(SubStr(cBuffer,100,15), '@R 9999999999999.99'))

					(tTabFAT)->GXI_EDISIT := '1'
					(tTabFAT)->GXI_EDILIN := cBuffer
					(tTabFAT)->GXI_EDIARQ := cNomeArq
					(tTabFAT)->GXI_EDINRL := nContLinhas
					(tTabFAT)->GXI_ACAO := SubStr(cBuffer,167,1)

				MsUnLock(tTabFAT)
	
				// Armazena a chave do registro que está sendo criado
				rTabFAT[1]           := (tTabFAT)->GXI_FILIAL
				rTabFAT[2]           := (tTabFAT)->GXI_NRIMP
	
				GFELog116:NewLine()
				GFELog116:Add("Fatura")
				GFELog116:Add("> Filial........: " + (tTabFAT)->GXI_FILFAT, 1)
				GFELog116:Add("> Emitente......: " + (tTabFAT)->GXI_EMIFAT, 1)
				GFELog116:Add("> Série.........: " + (tTabFAT)->GXI_SERFAT, 1)
				GFELog116:Add("> Número........: " + (tTabFAT)->GXI_NRFAT , 1)
				GFELog116:Add("> Data Emissão..: " + DTOS((tTabFAT)->GXI_DTEMIS) , 1)
				GFELog116:Add("> Data Vencto...: " + DTOS((tTabFAT)->GXI_DTVENC) , 1)
				GFELog116:Add("> Valor.........: " + ALLTRIM(STR((tTabFAT)->GXI_VLFATU)) , 1)
	
				// Pré-Validações -------------------------
				If Empty((tTabFAT)->GXI_EMIFAT)
					cMsgPreVal += "- "  + "Emissor não encontrado com CNPJ/CPF: " + cCGCTrp + CRLF
				EndIf
	
				If Empty((tTabFAT)->GXI_NRFAT)
					cMsgPreVal += "- "  + "Número da fatura não encontrado." + CRLF
				EndIf

				GFELog116:Save()
	
				nContDF := 0
			Else
				GFEResult:Add("Ação do registro 352 inválida: " + cAcao + ". Verifique o arquivo EDI.")
				GFEResult:SetWarningIcon()
				lArquivoImportado := .F.
			EndIf 

		EndIf

	   	//Documentos relacionadas - Inicio
		If SubStr(cBuffer,01,03) == "353"
			nContDF++

			aDocFrete[2] := PadL(Alltrim(Transform(nContDF, '@R 99999')),5,"0")	// Sequência
			aDocFrete[3] := PadR(AllTrim(SubStr(cBuffer,14,05)), TamSX3("GW3_SERDF")[1])	// Série DF
			aDocFrete[4] := PadR(AllTrim(SubStr(cBuffer,19,12)), TamSX3("GW3_NRDF")[1])		// Nùmero DF
			aDocFrete[8] := AllTrim(cCGCTrp)			   									// CGC Emissor
			
			GFELog116:Add("Documento de Frete", 1)
			GFELog116:Add("> Seq........: " + aDocFrete[2] , 2)
			GFELog116:Add("> Série......: " + aDocFrete[3] , 2)
			GFELog116:Add("> Número.....: " + aDocFrete[4] , 2)
			GFELog116:Save()
			
			// Código Emitente conforme o CNPJ indicado na linha em processamento
			cCodEmisLin := ""
			dbSelectArea("GU3")
			dbSetOrder(11)
			If dbSeek(xFilial("GU3") + cCGCTrp)
				If !Empty(cEmitGW3) 
					If dbSeek(xFilial("GU3") + AllTrim(SubStr(cBuffer,82,14)))
						While GU3->(!Eof()) .And. GU3_FILIAL = xFilial("GU3") .And. Alltrim(GU3->GU3_IDFED) == AllTrim(SubStr(cBuffer,82,14))	// Se tiver mais de um emitente com o mesmo CNPJ percorre todos até encontrar o emitente do doc frete 
							If GU3->GU3_CDEMIT == cEmitGW3
								cCodEmisLin := GU3->GU3_CDEMFT
								Exit
							EndIf 
							GU3->(dbSkip())
						EndDo
					EndIf
				Else 
					cCodEmisLin := GU3->GU3_CDEMIT
				EndIf
			EndIf
		
			// Código Emitente -> aDocFrete[5]
			aDocFrete[5] := ""
			dbSelectArea("GU3")
			GU3->( dbSetOrder(1) )
			If GU3->( dbSeek(xFilial("GU3") + cCdTrp ))
				aDocFrete[5] := GU3->GU3_CDEMIT
				GFELog116:Add("> Emissor....: " + aDocFrete[5] + "(" + cCdTrp + ")", 2)
			Else
				cMsgPreVal += "- " + "Emissor do Doc.Frete não encontrado com CNPJ/CPF: " + cCdTrp + CRLF
				GFELog116:Add("** Emissor não encontrado com CNPJ/CGC: " + cCdTrp, 2)
			EndIf

			// Filial -> aDocFrete[1]
			// Documento de Frete pelo Emissor, Série e Número
			aDocFrete[1] := ""
			lDocFind := .F.
			cNrDf := AllTrim(SubStr(cBuffer,19,12))
			aDocFrete[4] := PadR(cNrDf, 16)
			GFELog116:AddDebug("- Buscando Documento de Frete. Emissor: [" + aDocFrete[5] + "], Serie: [" + aDocFrete[3] + "], Numero: [" + aDocFrete[4] + "]", 2)

			dbSelectArea("GW3")
			dbSetOrder(10) // GW3_FILIAL + GW3_EMISDF + GW3_SERDF + GW3_NRDF
			If dbSeek(cFilialFat + aDocFrete[5] + aDocFrete[3] + aDocFrete[4])
				If ( cFilialFat == GW3->GW3_FILIAL .And.;			// dbSeek realiza uma busca parcial no Número do Documento
					aDocFrete[5] == GW3->GW3_EMISDF .And.;			// Por isso é necessário conferir a exatidão
					aDocFrete[3] == GW3->GW3_SERDF .And.;			// Ex.: 0004758 <> 00047583
					aDocFrete[4] == AllTrim(GW3->GW3_NRDF) )
				
					dDtEmiDF := GW3->GW3_DTEMIS
					GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "] [Encontrado]", 3)
					lDocFind := .T.
				EndIf
			EndIf
				
			If !lDocFind
				// Busca a primeira espécie do tipo conhecimento
				nQtNumDF := 8
				dbSelectArea("GVT")
				dbSetOrder(1)
				While !GVT->(EoF())
					If GVT->GVT_CDESP == s_ESPDF1
						nQtNumDF := GVT->GVT_QTALG
						Exit
					EndIf
					GVT->(dbSkip())
				EndDo
				
				GFELog116:AddDebug("** Documento de Frete não encontrado. Buscando pela espécie: [" + s_ESPDF1 + "]. Numeração: " + AllTrim(Str(nQtNumDF)), 2)
				
				aDocFrete[4] := PadL(AllTrim(GFEZapZero(cNrDf)), nQtNumDF, "0")		//Remove zeros à esquerda de acordo com o tamanho na Espécie (GVT)
				
				dbSelectArea("GW3")
				dbSetOrder(10) // GW3_FILIAL + GW3_EMISDF + GW3_SERDF + GW3_NRDF
				If dbSeek(cFilialFat + aDocFrete[5] + aDocFrete[3] + aDocFrete[4])	

					If ( cFilialFat == GW3->GW3_FILIAL .And.;			// dbSeek realiza uma busca parcial no Número do Documento
						aDocFrete[5] == GW3->GW3_EMISDF .And.;			// Por isso é necessário conferir a exatidão
						aDocFrete[3] == GW3->GW3_SERDF .And.;			// Ex.: 0004758 <> 00047583
						aDocFrete[4] == AllTrim(GW3->GW3_NRDF) ) 

						dDtEmiDF := GW3->GW3_DTEMIS
						GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "] [Encontrado]", 3)
						lDocFind := .T.
					EndIf
				EndIf

				If !lDocFind					
					
					cNrDf := AllTrim(GFEZapZero(cNrDf))		// Remove todos os zeros à esquerda
					nI := 16					
					GFELog116:AddDebug("** Documento de Frete não encontrado. Preenchendo com zeros a esquerda. Número: [" + cNrDf + "]", 2)
					
					For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
						aDocFrete[4] := PadL(cNrDf, nI, "0")	// Acrescenta um zero à esquerda
						
						dbSelectArea("GW3")
						dbSetOrder(10) // GW3_FILIAL + GW3_EMISDF + GW3_SERDF + GW3_NRDF
						If dbSeek(cFilialFat + aDocFrete[5] + aDocFrete[3] + aDocFrete[4])						
							
							If ( cFilialFat == GW3->GW3_FILIAL .And.;			// dbSeek realiza uma busca parcial no Número do Documento
								aDocFrete[5] == GW3->GW3_EMISDF .And.;			// Por isso é necessário conferir a exatidão
								aDocFrete[3] == GW3->GW3_SERDF .And.;			// Ex.: 0004758 <> 00047583
								aDocFrete[4] == AllTrim(GW3->GW3_NRDF) )
							
								dDtEmiDF := GW3->GW3_DTEMIS
								GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "] [Encontrado]", 3)
								lDocFind := .T.
								Exit
							Else
								GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "]", 3)
							EndIf
						ElseIf GFEVldSIX("GW3", "G")
							GW3->(dbSetOrder(16)) // GW3_FILTOM + GW3_EMISDF + GW3_SERDF + GW3_NRDF
							If GW3->(dbSeek(cFilialFat + aDocFrete[5] + aDocFrete[3] + aDocFrete[4]))
								If (cFilialFat == GW3->GW3_FILTOM .And. aDocFrete[5] == GW3->GW3_EMISDF;
									.And. aDocFrete[3] == GW3->GW3_SERDF .And. aDocFrete[4] == AllTrim(GW3->GW3_NRDF) )

									dDtEmiDF := GW3->GW3_DTEMIS
									GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "] [Encontrado]", 3)
									lDocFind := .T.
									Exit
								EndIf
							Else
								GFELog116:AddDebug("- Número: [" + aDocFrete[4] + "]", 3)
							EndIf
						EndIf						
					Next

				EndIf
				
				If !lDocFind
					GFELog116:Add("** Erro ao buscar Documento de Frete. Emissor: [" + aDocFrete[5] + "], Serie: [" + aDocFrete[3] + "], Numero: [" + aDocFrete[4] + "]", 2)
				EndIf
			EndIf
			
			/* ******************************************************************************************************
			   Busca Documentos de Frete quando o Transportador de Embarque é diferente do que Fatura - GU3_CDEMFT 
			   ****************************************************************************************************** */
			If !lDocFind
				aDocFrete[4] := AllTrim(GFEZapZero(aDocFrete[4]))	// Remove todos os zeros à esquerda
				GFELog116:Add("- Buscando Documento de Frete com Emissor de Embarque diferente do Faturamento. Transportador Faturamento: " + aDocFrete[5], 2)
				
				aEmitFatura := {}
				
				dbSelectArea("GU3")
				dbSetOrder(1)
				dbSeek(xFilial("GU3") + cEmitGW3)
				While !GU3->(Eof()) .AND. GU3->GU3_CDEMFT == aDocFrete[5]
					GFELog116:AddDebug("- Emissor: [" +  GU3->GU3_CDEMIT + "], Transp. Fat.: [" + GU3->GU3_CDEMFT + "]", 3)
					AAdd(aEmitFatura, {GU3->GU3_CDEMIT, GU3->GU3_CDEMFT })
					GU3->(dbSkip())
				EndDo
				
				cNrDf := AllTrim(GFEZapZero(aDocFrete[4]))	// Remove todos os zeros à esquerda
					
				For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
					aDocFrete[4] := PadL(cNrDf, nI, "0")	// Acrescenta um zero à esquerda
					GFELog116:AddDebug("- Documento número [" + aDocFrete[4] + "]", 4)
					
					For nJ := 1 To Len(aEmitFatura)
						dbSelectArea("GW3")
						dbSetOrder(10) // GW3_FILIAL + GW3_EMISDF + GW3_SERDF + GW3_NRDF
						If dbSeek(cFilialFat + aEmitFatura[nJ][1] + aDocFrete[3] + aDocFrete[4])
							
							If ( cFilialFat == GW3->GW3_FILIAL .And.;			// dbSeek realiza uma busca parcial no Número do Documento
								aEmitFatura[nJ][1] == GW3->GW3_EMISDF .And.;		// Por isso é necessário conferir a exatidão
								aDocFrete[3] == GW3->GW3_SERDF .And.;			// Ex.: 0004758 <> 00047583
								aDocFrete[4] == AllTrim(GW3->GW3_NRDF) .And.;
								Alltrim(aEmitFatura[nJ][2]) == Alltrim(cCodEmisLin) ) 

								dDtEmiDF := GW3->GW3_DTEMIS
								GFELog116:AddDebug("- Documento encontrado. Filial: [" + GW3->GW3_FILIAL + "], Série: [" + GW3->GW3_SERDF + "], Número: [" + GW3->GW3_NRDF + "], Número do Arquivo: [" + aDocFrete[4] + "], Emissor: [" +  GW3->GW3_EMISDF + "]", 3)
								aDocFrete[1] := GW3->GW3_FILIAL
								aDocFrete[4] := GW3->GW3_NRDF
								aDocFrete[5] := GW3->GW3_EMISDF
								
								lDocFind := .T.
								Exit
							EndIf
							
						EndIf
					Next

					If lDocFind
						Exit
					EndIf						
				Next
				
				If lDocFind
					GFELog116:Add("> Emissor....: " + AllTrim(aDocFrete[5]) + " [Transportador de Embarque]" , 2)
				Else
					GFELog116:Add("** Erro ao buscar Documento de Frete com o transportador de embarque." , 2)
				EndIf				

			EndIf
			
			GFELog116:AddDebug("- Fim da busca do Documento.", 2)

			If lDocFind
				// Verifica se o Documento não existe em outra filial
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GW3.GW3_FILIAL AS GW3FILIAL
						 , GW3.GW3_EMISDF AS GW3EMISDF
					     , GW3.GW3_SERDF AS GW3SERDF
						 , GW3_NRDF AS GW3NRDF
						 , GW3_DTEMIS AS GW3DTEMIS
					FROM %Table:GW3% GW3
					WHERE GW3.GW3_FILIAL <> %xFilial:GW3%
					AND GW3.GW3_EMISDF = %Exp:aDocFrete[5]%
					AND GW3.GW3_SERDF = %Exp:aDocFrete[3]%
					AND GW3_NRDF = %Exp:aDocFrete[4]%
					AND GW3.%NotDel%
				EndSql
				While (cAliasQry)->(!Eof())
					If (cAliasQry)->GW3DTEMIS > DtoS(dDtEmiDF)
						cMsgRet := "** Documento de Frete existente em outra filial." + CRLF +;
									"Filial: " + Alltrim((cAliasQry)->GW3FILIAL) + CRLF +;
									"Emissor: " + Alltrim((cAliasQry)->GW3EMISDF) + CRLF +;
									"Nr. Df/Serie: " + Alltrim((cAliasQry)->GW3NRDF) + "/" + Alltrim((cAliasQry)->GW3SERDF) + CRLF +;
									"Data Emissão: " + dtoc(stod((cAliasQry)->GW3DTEMIS))

						GFELog116:Add( cMsgRet, 2)

						RecLock((tTabFAT), .F.)
						(tTabFAT)->GXI_EDIMSG := (tTabFAT)->GXI_EDIMSG + CRLF + cMsgRet
						(tTabFAT)->GXI_EDISIT := '2'
						MsUnlock()

						Exit
					EndIf

					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())


				GFELog116:AddDebug("- Documento encontrado. Chave GW3 " + ;
					"[GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF, GW3_DTEMIS]: " + ; 
					GW3->GW3_FILIAL + ", " + ;
					GW3->GW3_CDESP + ", " + ;
					GW3->GW3_EMISDF + ", " + ;
					GW3->GW3_SERDF + ", " + ;
					GW3->GW3_NRDF + ", " + ;
					DToS(GW3->GW3_DTEMIS), 2)

				aDocFrete[1] := GW3->GW3_FILIAL
				aDocFrete[6] := GW3->GW3_CDESP
				aDocFrete[7] := GW3->GW3_DTEMIS
				aDocFrete[11] := GW3->GW3_FILTOM

				RecLock(tTabFAT, .F.)

				(tTabFAT)->GXI_VLFATU += GW3->GW3_IMPRET

				If Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '1'
					(tTabFAT)->GXI_IMPRET += GW3->GW3_IMPRET
				ElseIf Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '2'
					(tTabFAT)->GXI_ISSRET += GW3->GW3_IMPRET
				EndIf

				MsUnlock()

				GFELog116:Add("> Filial.....: " + aDocFrete[1], 2)
				GFELog116:Add("> Emitente...: " + aDocFrete[5], 2)
				GFELog116:Add("> Espécie....: " + aDocFrete[6], 2)
				GFELog116:Add("> Dt Emiss...: " + cValToChar(aDocFrete[7]), 2)
				GFELog116:Save()

			Else
				aDocFrete[4] := AllTrim(GFEZapZero(aDocFrete[4]))
				
				GFELog116:Add("** Documento de Frete inexistente. Emissor:  " + aDocFrete[5] + ", Série: " + aDocFrete[3] + ", Nr: " + aDocFrete[4], 2)
				cMsgPreVal += "- " + "Doc.Frete inexistente. Emissor: " + ALLTRIM(aDocFrete[5]) + ", " + ;
																		 "Série: "  + ALLTRIM(aDocFrete[3]) + ", " + ;
															 			 "Número: " + ALLTRIM(aDocFrete[4]) + CRLF

			EndIf

			// Validação da espécie
			If Empty(aDocFrete[6])
				GFELog116:Add("** Espécie não encontrada, usando valor do parâmetro MV_ESPDF1. Valor: " + s_ESPDF1, 2)
				aDocFrete[6] := s_ESPDF1
			EndIf

			If lDocFind .And. aDocFrete[1] != cFilialFat .And. aDocFrete[11] != cFilialFat
				GFELog116:Add("** Filial da fatura "+AllTrim((tTabFAT)->GXI_NRFAT)+" é diferente da filial do documento de frete número/série "+AllTrim(aDocFrete[4])+"/"+AllTrim(aDocFrete[3])+".", 2)
				cMsgPreVal += "- Filial da fatura "+AllTrim((tTabFAT)->GXI_NRFAT)+" é diferente da filial do documento de frete número/série "+AllTrim(aDocFrete[4])+"/"+AllTrim(aDocFrete[3])+"." + CRLF
			EndIf

			RecLock(tTabCTRC, .T.)
				(tTabCTRC)->GXJ_FILIAL := xFilial("GXJ")
				(tTabCTRC)->GXJ_NRIMP  := AllTrim(STR(nNRIMP))
				(tTabCTRC)->GXJ_FILDF  := aDocFrete[1]
				(tTabCTRC)->GXJ_SEQ    := aDocFrete[2]
				(tTabCTRC)->GXJ_SERDF  := aDocFrete[3]
				(tTabCTRC)->GXJ_NRDF   := aDocFrete[4]
				(tTabCTRC)->GXJ_EMISDF := aDocFrete[5]
				(tTabCTRC)->GXJ_CDESP  := aDocFrete[6]
				(tTabCTRC)->GXJ_DTEMIS := aDocFrete[7]
			MsUnLock(tTabCTRC)

		EndIf

		// Grava as mensagens da pré-validações
   		If !Empty(cMsgPreVal)
   			GFELog116:Add("- Ocorreram erros de validação.")
   			If !Empty(rTabFAT[2])
	   			dbSelectArea((tTabFAT))
	   			dbSetOrder(1)
	   			If dbSeek(rTabFAT[1] + rTabFAT[2])
		   			RecLock((tTabFAT), .F.)
		   			(tTabFAT)->GXI_EDIMSG := (tTabFAT)->GXI_EDIMSG + cMsgPreVal
		   			(tTabFAT)->GXI_EDISIT := '2'
		   			MsUnlock()
		   			
		   			If lResultCabecalho
							GFEResult:AddErro("> Filial: " + (tTabFAT)->GXI_FILFAT + ", Série: " + (tTabFAT)->GXI_SERFAT + ", Fatura: " + (tTabFAT)->GXI_NRFAT)
							lResultCabecalho := .F.
						EndIf
		   			
		   			cMsgPreVal := ""
		   		EndIf
		   	Else
		   		GFELog116:Add("** Chave da fatura em branco.")
		   		GFELog116:Save()
		   		GFELog116:Add("> Filial.: " + rTabFAT[1], 1)
		   		GFELog116:Add("> Seq Imp: " + rTabFAT[2], 1)
		   	EndIf
   		EndIf

	   	GFEFile:FNext()

		GFELog116:Save()
	EndDo

	GFELog116:NewLine()
	GFELog116:Add("Total de faturas deste arquivo " + cValToChar(nCountFatArq) )

Return


//-------------------------------------------------------------------

Static Function GFEZapZero(cStr)

	Local nI
	Local nPos := 2

	If SubStr(cStr, 1, 1) != "0"
		Return cStr
	EndIf

	For nI := 2 To Len(cStr)

		If SubStr(cStr, nI, 1) == "0"
			nPos++
		Else
			Exit
		EndIf

	Next

Return SubStr(cStr, nPos)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116Pro
Rotina para processar os dados importados.

@author Felipe Rafael Mendes
@since 17/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processamento()
	Local lRet      := .T.
	Local lProc     := .F.
	Local nCount    := 0
	Local nTotal    := 0
	Local nDfFat    := 0
	Local cDfFat    := ""
	Local nGW3RecNo := 0
	Local lBuscaDF  := .F.
	Local lProcess  := .T.
	Local nContDF   := 0
	Local aPrefat   := {}
	Local nI        := 1
	Local cMsgErr   := ""

	Local nCont     := 0 
	Local nContDel  := 0
	Local cNum      := ""
	Local cSer      := ""
	Local cEmi      := ""
	Local lMsgErr   := .F.
	Local nTamEmDf  := TamSx3("GXJ_EMISDF")[1]
	Local lGFE116A1 := ExistBlock("GFE116A1")
	Local lSchedDef := IsBlind()
	Local s_GFEA1601 := ExistBlock("GFEA1601") 

	Private GFELog116 := GFELog():New("EDI_Doccob_Processamento", "EDI Faturas/Doccob - Processamento", SuperGetMV('MV_GFEEDIL',,'1'))

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte COMP022_MVC
	// que é a rotina de manutenção de musicas
	oModel := FWLoadModel("GFEA070")

	GFELog116:Add("- Processando faturas")
	GFELog116:NewLine()

	DbSelectArea('GXI')
	GXI->( DbSetOrder(01) )
	GXI->( DBGoTop() )
	While !GXI->(Eof())

		lProcess := .T.
		nContDF  := 0
		cMsgErr  := ""

		lSchedule := .F.
		
		// Início Ponto de Entrada Procomp
	 	If s_GFEA1601   
		    lSchedule := ExecBlock("GFEA1601",.f.,.f.,{})
	 	EndIf
		// Fim Ponto de Entrada Procomp
		
		If !lSchedDef	
			If (!lSchedule .And. !oBrowse116:IsMark(oBrowse116:Mark())) .OR. GXI->GXI_EDISIT == '4'
				GXI->( dbSkip() )
				Loop
			EndIf
		Else
			If GXI->GXI_EDISIT == '4'
				GXI->( dbSkip() )
				Loop
			EndIf
		EndIf
		aGVTStruct := GVT->( dbStruct() )
		nTotal++

		GFELog116:Add("# " + cValToChar(nTotal) + " - (" + ALLTRIM(GXI->GXI_NRIMP) + ")")
		GFELog116:Add("> Filial..: " + GXI->GXI_FILFAT, 2)
		GFELog116:Add("> Emissor.: " + GXI->GXI_EMIFAT, 2)
		GFELog116:Add("> Série...: " + GXI->GXI_SERFAT, 2)
		GFELog116:Add("> Número..: " + GXI->GXI_NRFAT, 2)

	   	lProc := .T.

		DbSelectArea("GW6")
		GW6->( dbSetOrder(1) )

		If GW6->( dbSeek(GXI->GXI_FILFAT+PadR(GXI->GXI_EMIFAT, TamSx3("GXI_EMIFAT")[1])+PadR(GXI->GXI_SERFAT,5)+PadR(GXI->GXI_NRFAT,16)) )
			If GXI->GXI_ACAO != "E" // Campo de ação não existe ou não é exclusão
				RecLock("GXI",.F.)
			    	GFELog116:Add("** " + STR0008, 1)
			    	GXI->GXI_EDIMSG := STR0008 //"Erro de chave duplicada. A fatura já existe."
			     	GXI->GXI_EDISIT := '3'
				MsUnLock("GXI")
	
				DbSelectArea('GXI')
			   	GXI->( DbSkip() )
				Loop
			EndIf
		ElseIf GXI->GXI_ACAO == "E"
			RecLock("GXI",.F.)
		    	GFELog116:Add("** " + "A fatura não foi localizada para exclusão.", 1)
		    	GXI->GXI_EDIMSG := "A fatura não foi localizada para exclusão."
		     	GXI->GXI_EDISIT := '3'
			MsUnLock("GXI")

			DbSelectArea('GXI')
		   	GXI->( DbSkip() )			
			Loop
		EndIf
		
		// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
		If GXI->GXI_ACAO == "E"
			oModel:SetOperation( 5 )
		Else
			oModel:SetOperation( 3 )
		EndIf

		// Antes de atribuirmos os valores dos campos temos que ativar o modelo
		cFilAnt := GXI->GXI_FILFAT
		oModel:Activate()
		
		DbSelectArea('GXJ')
		GXJ->( DbSetOrder(1) )
		GXJ->( dbSeek(GXI->GXI_FILIAL + GXI->GXI_NRIMP) )
		While !EOF() .And. GXI->GXI_FILIAL + GXI->GXI_NRIMP == GXJ_FILIAL + GXJ->GXJ_NRIMP
			lBuscaDF := .F.
			nContDF++
			
			nGW3RecNo := BuscaGW3(GXJ->GXJ_FILDF, GXJ->GXJ_CDESP, GXJ->GXJ_EMISDF, GXJ->GXJ_SERDF, GXJ->GXJ_NRDF, GXJ->GXJ_DTEMIS)
			
			If nGW3RecNo > 0
				dbSelectArea("GW3")
				dbGoTo(nGW3RecNo)
				lBuscaDF := .T.
			EndIf

			If lBuscaDF
				If GXJ->GXJ_FILDF != GXI->GXI_FILFAT .And. (Empty(GW3->GW3_FILTOM) .Or. GXI->GXI_FILFAT != GW3->GW3_FILTOM)
					GFELog116:Add("** Filial da fatura "+AllTrim(GXI->GXI_NRFAT)+" é diferente da filial do documento de frete número/série "+AllTrim(GXJ->GXJ_NRDF)+"/"+AllTrim(GXJ->GXJ_SERDF)+".", 2)
					cMsgErr += "- Filial da fatura "+AllTrim(GXI->GXI_NRFAT)+" é diferente da filial do documento de frete número/série "+AllTrim(GXJ->GXJ_NRDF)+"/"+AllTrim(GXJ->GXJ_SERDF)+"." + CRLF + CRLF
					lProcess := .F.
				EndIf
			Else
				GFELog116:Add("** Documento de frete não encontrado. Filial: " + AllTrim(GXJ->GXJ_FILDF) + ", Esp: " + AllTrim(GXJ->GXJ_CDESP) + ", Emissor: " + AllTrim(GXJ->GXJ_EMISDF) + ", Nr: " + AllTrim(GXJ->GXJ_NRDF), 3)
				cMsgErr += "- Documento de frete não encontrado. Filial: " + AllTrim(GXJ->GXJ_FILDF) + ", Esp: " + AllTrim(GXJ->GXJ_CDESP) + ", Emissor: " + AllTrim(GXJ->GXJ_EMISDF) + ", Nr: " + AllTrim(GXJ->GXJ_NRDF) + CRLF + CRLF
				lProcess := .F.
			EndIf

			If GXI->GXI_ACAO == "E"
				If lBuscaDF .And. GW6->(GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+DTOS(GW6_DTEMIS)) != GW3->(GW3_FILFAT+GW3_EMIFAT+GW3_SERFAT+GW3_NRFAT+DTOS(GW3_DTEMFA))
					GFELog116:Add("** A Fatura do Documento de Frete " + AllTrim(GW3->GW3_NRDF) + ", difere da excluída." +  CRLF + "A fatura dos Documentos de Frete do arquivo devem coincidir com o registro excluído.")
					cMsgErr += "- A Fatura do Documento de Frete " + AllTrim(GW3->GW3_NRDF) + ", difere da excluída." +  CRLF + "A fatura dos Documentos de Frete do arquivo devem coincidir com o registro excluído." + CRLF
					lProcess := .F.
				EndIf 
			ElseIf !Empty(GW3->GW3_NRFAT)
				GFELog116:Add("** Documento de Frete " + AllTrim(GW3->GW3_NRDF) + ", já vinculado a fatura:  " + AllTrim(GW3->GW3_NRFAT))
				cMsgErr += "- Documento de Frete " + AllTrim(GW3->GW3_NRDF) + ", já vinculado a fatura:  " + AllTrim(GW3->GW3_NRFAT) +  CRLF
				lProcess := .F.
			EndIf
			
			If GXI->GXI_DTEMIS > GXI->GXI_DTVENC
				GFELog116:Add("** " + STR0002 + "GW6_DTVENC" + STR0003 + " O campo Data Venc (GW6_DTVENC) da fatura, deve ser maior ou igual a data de emissão: " + DTOC(GXI->GXI_DTEMIS)) //"Ocorreu um erro no campo: "###". Motivo: "
				cMsgErr += "- "     + STR0002 + "GW6_DTVENC" + STR0003 + " O campo Data Venc (GW6_DTVENC) da fatura, deve ser maior ou igual a data de emissão: " + DTOC(GXI->GXI_DTEMIS) +  CRLF
				lProcess := .F.
			EndIf

			// Permite realizar validações complementares referentes
			// aos documentos de frete relacionados à fatura (Vicunha)
			If lGFE116A1
				lRetPE := ExecBlock("GFE116A1",.F.,.F.,{nContDF})
				If ValType(lRetPE) == 'L'
					lProcess := lRetPE
				EndIf
			EndIf
			
			DBSelectArea('GXJ')
			GXJ->( DbSkip() )
		EndDo

		lMsgErr := .F.
		lRet := .T.
		If nContDF > 0 .And. lProcess .And. !(GXI->GXI_ACAO == "E")
			//Atribui valor atravez do SetValue
			oModel:SetValue("GFEA070_GW6", 'GW6_FILIAL', AllTrim(GXI->GXI_FILFAT))
			oModel:SetValue("GFEA070_GW6", 'GW6_EMIFAT', AllTrim(GXI->GXI_EMIFAT))
			oModel:SetValue("GFEA070_GW6", 'GW6_SERFAT', AllTrim(GXI->GXI_SERFAT))
			oModel:SetValue("GFEA070_GW6", 'GW6_NRFAT' , AllTrim(GXI->GXI_NRFAT))
			oModel:SetValue("GFEA070_GW6", 'GW6_DTEMIS', GXI->GXI_DTEMIS)
			oModel:SetValue("GFEA070_GW6", 'GW6_DTVENC', GXI->GXI_DTVENC)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLFATU', GXI->GXI_VLFATU)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLICMS', GXI->GXI_VLICMS)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLJURO', GXI->GXI_VLJURO)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLDESC', GXI->GXI_VLDESC)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLICRE', GXI->GXI_IMPRET)
			oModel:SetValue("GFEA070_GW6", 'GW6_VLISRE', GXI->GXI_ISSRET)
			oModel:SetValue("GFEA070_GW6", 'GW6_ORIGEM', "1")

			If ( lRet := oModel:VldData() )
				oModel:CommitData()
				nCount++
				RecLock("GXI",.F.)
		           GXI->GXI_EDIMSG := ""
		           GXI->GXI_EDISIT := '4'
				MsUnLock("GXI")

				// Realiza o vínculo do Documento de Frete na Fatura criada
				GFELog116:Add("- Vinculando documentos de frete", 2)
				DbSelectArea('GXJ')
				GXJ->( DbSetOrder(1) )
				GXJ->( dbSeek(GXI->GXI_FILIAL + GXI->GXI_NRIMP) )
				While !GXJ->(EOF()) .And. GXI->GXI_FILIAL + GXI->GXI_NRIMP == GXJ_FILIAL + GXJ->GXJ_NRIMP

					BuscaGW3(GXJ->GXJ_FILDF, GXJ->GXJ_CDESP, GXJ->GXJ_EMISDF, GXJ->GXJ_SERDF, GXJ->GXJ_NRDF, GXJ->GXJ_DTEMIS)
					If Empty(GXJ->GXJ_FILDF)
						RecLock("GXJ", .F.)
							GXJ->GXJ_FILDF    := GW3->GW3_FILIAL
						//	GXJ->GXJ_NRDF 	  := GW3->GW3_NRDF
							GXJ->GXJ_DTEMIS   := GW3->GW3_DTEMIS
						MsUnLock("GXJ")
					Endif				
					//Número do Documento de Frete na Fatura criada
					/*
					DbSelectArea('GW3')
					GW3->( DbSetOrder(1) )
					GW3->( dbClearFilter() )
					cNrDf := GXJ->GXJ_NRDF
					
					If !GW3->( DbSeek(GXJ->GXJ_FILDF+GXJ->GXJ_CDESP+PadR(AllTrim(GXJ->GXJ_EMISDF),nTamEmDf)+GXJ->GXJ_SERDF+cNrDf) )
						cNrDf := PadR(AllTrim(Str(Val(GXJ->GXJ_NRDF))),16)
						If !GW3->( DbSeek(GXJ->GXJ_FILDF+GXJ->GXJ_CDESP+PadR(AllTrim(GXJ->GXJ_EMISDF),nTamEmDf)+GXJ->GXJ_SERDF+cNrDf) )
							cNrDf := PadR(AllTrim(StrZero(Val(GXJ->GXJ_NRDF),6)),16)
							GW3->( DbSeek(GXJ->GXJ_FILDF+GXJ->GXJ_CDESP+PadR(AllTrim(GXJ->GXJ_EMISDF), nTamEmDf)+GXJ->GXJ_SERDF+cNrDf) )
						EndIf
					EndIf
					*/

					/*
					While !GW3->(Eof()) .And. GW3->GW3_FILIAL = GXJ->GXJ_FILDF .AND. ;
									   GW3->GW3_CDESP  = GXJ->GXJ_CDESP .AND. ;
									   GW3->GW3_SERDF  = GXJ->GXJ_SERDF .AND. ;
										GW3->GW3_EMISDF = PadR(AllTrim(GXJ->GXJ_EMISDF), TamSx3("GXJ_EMISDF")[1]) .AND. ;
										GW3->GW3_NRDF   = cNrDf */
						

						GFELog116:Add("- Documento de frete.", 3)
						GFELog116:Add("> Filial.: " + GW3->GW3_FILIAL, 3)
						GFELog116:Add("> Filial.: " + GW3->GW3_FILIAL, 3)
						GFELog116:Add("> Especie: " + GW3->GW3_CDESP , 3)
						GFELog116:Add("> Série..: " + GW3->GW3_SERDF , 3)
						GFELog116:Add("> Emissor: " + GW3->GW3_EMISDF, 3)
						GFELog116:Add("> Número.: " + GW3->GW3_NRDF  , 3)
						GFELog116:Add("---------", 3)


						RecLock("GW3",.F.)
						GW3->GW3_FILFAT := ALLTRIM(GXI->GXI_FILFAT)
						GW3->GW3_EMIFAT := ALLTRIM(GXI->GXI_EMIFAT)
						GW3->GW3_SERFAT := ALLTRIM(GXI->GXI_SERFAT)
						GW3->GW3_NRFAT  := ALLTRIM(GXI->GXI_NRFAT)
						GW3->GW3_DTEMFA := GXI->GXI_DTEMIS
						MsUnLock("GW3")

					/* EndDo */

					DBSelectArea('GXJ')
					GXJ->( DbSkip() )
				EndDo

				GFELog116:Save()

				// Realiza o vínculo das pré-faturas na fatura com base nos conhecimentos vinculados
				GFELog116:Add("- Vinculando pré-faturas", 2)
				aPrefat := GFEVINCPFC(GXI->GXI_FILFAT, GXI->GXI_EMIFAT, GXI->GXI_SERFAT, GXI->GXI_NRFAT, GXI->GXI_DTEMIS, GFELog116)
				For nI := 1 To Len(aPrefat)
					GFELog116:Add("> Filial.: " + aPrefat[nI, 1], 3)
					GFELog116:Add("> Número.: " + aPrefat[nI, 2], 3)
				Next

				GFELog116:Add("- Conferindo fatura.", 2)
				GFELog116:Save()
				dbSelectArea("GW6")
				GW6->( dbSetOrder(1) )
				If GW6->( dbSeek(GXI->GXI_FILFAT + GXI->GXI_EMIFAT + GXI->GXI_SERFAT + GXI->GXI_NRFAT + DToS(GXI->GXI_DTEMIS)) )
					// Realizar a conferência da fatura somente se houver pelo menos um Documento de Frete Vinculado.
					If GFXCP12118("GW6_DINDEN")
						lRetDesc := GFEA070IND()				
					EndIf
					dbSelectArea("GW3")
					GW3->( dbSetOrder(8) )
					If GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
						GFEA071RA(.T.)
					Else
						GFELog116:Add("** Não há documento de frete vinculado.", 2)
					EndIf
				EndIf

			EndIf

		ElseIf lProcess .And. GXI->GXI_ACAO == "E" // Validações de efetivação da exclusão
				DbSelectArea('GXJ')
				GXJ->( DbSetOrder(1) )
				GXJ->( dbSeek(GXI->GXI_FILIAL + GXI->GXI_NRIMP) )

				nCont:= 0 
				nContDel := 0
				nDfFat := 0
				cDfFat := ""
				DbSelectArea('GW3')
				GW3->( DbSetOrder(8) )
				
				GW3->(dbSeek(GXI->GXI_FILFAT + GXI->GXI_EMIFAT + GXI->GXI_SERFAT + GXI->GXI_NRFAT + dtos(GXI->GXI_DTEMIS)))
				While !GW3->(Eof()) .And. GW3->GW3_FILFAT == GXI->GXI_FILFAT;
						      		.And. GW3->GW3_EMIFAT == GXI->GXI_EMIFAT;
									.And. GW3->GW3_SERFAT == GXI->GXI_SERFAT;
									.And. GW3->GW3_NRFAT  == GXI->GXI_NRFAT ;
									.And. GW3->GW3_DTEMFA == GXI->GXI_DTEMIS
					nDfFat++
					If !Empty(cDfFat)
						cDfFat += ","
					EndIf
					cDfFat += AllTrim(GW3->GW3_NRDF)
					GW3->(dbSkip())
				EndDo
				
				
				// Valida se existem diferenças de documentos
				// do registro intermediário para o documento de frete eliminado
				While GXJ->(!Eof()) .And. GXI->GXI_FILIAL + GXI->GXI_NRIMP == GXJ->GXJ_FILIAL + GXJ->GXJ_NRIMP	
					nCont:= nCont +1
					GW3->( dbSetOrder(1) )
					If GW3->( DbSeek(GXJ->GXJ_FILDF+GXJ->GXJ_CDESP+PadR(AllTrim(GXJ->GXJ_EMISDF),nTamEmDf)+GXJ->GXJ_SERDF+GXJ->GXJ_NRDF	) )						
						nContDel := nContDel + 1
					else 
						cNum := GXJ->GXJ_NRDF
						cSer := GXJ->GXJ_SERDF
						cEmi := GXJ->GXJ_EMISDF
						Exit
					EndIf
					GXJ->( dbSkip() )
				EndDo     
			    
			    If  nContDel == nCont .And. nDfFat == nCont .And. nCont > 0                                                                     
					dbSelectArea("GW6")
					GW6->( dbSetOrder(1) )
					If GW6->( dbSeek(GXI->GXI_FILFAT + GXI->GXI_EMIFAT + GXI->GXI_SERFAT + GXI->GXI_NRFAT + DToS(GXI->GXI_DTEMIS)) )
						lMsgErr := .F.
						If ( lRet := oModel:VldData() )
							oModel:CommitData()
							nCount++
							RecLock("GXI",.F.)
								GXI->GXI_EDIMSG := ""
								GXI->GXI_EDISIT := '4'
							MsUnLock("GXI")
						EndIf
					EndIf
				Else 
				    lMsgErr := .T.
				EndIf
		ElseIf !lProcess .And. !Empty(cMsgErr)
			RecLock("GXI",.F.)
			GXI->GXI_EDIMSG := cMsgErr
			GXI->GXI_EDISIT := '3'
			GXI->(MsUnLock())
		EndIf

		If !lRet
			// A estrutura do vetor aErro com erro é:
			//  [1] Id do formulário de origem
			//  [2] Id do campo de origem
			//  [3] Id do formulário de erro
			//  [4] Id do campo de erro
			//  [5] Id do erro
			//  [6] mensagem do erro
			//  [7] mensagem da solução
			//  [8] Valor atribuido
			//  [9] Valor anterior
			aErro := oModel:GetErrorMessage()
			GFELog116:Add("** " + STR0002 + aErro[4] + STR0003 + aErro[6])
			RecLock("GXI",.F.)
	           GXI->GXI_EDIMSG := STR0002 + aErro[4] + STR0003 + aErro[6] + CRLF //"Ocorreu um erro no campo: "###". Motivo: "
	           GXI->GXI_EDISIT := '3'
			MsUnLock("GXI")
		ElseIf lMsgErr
			RecLock("GXG",.F.)
			GXI->GXI_EDISIT := '3'
			If nCont != nContDel
				GXI->GXI_EDIMSG := "Não foi localizado do documento de frete " + AllTrim(cNum) + "/" + AllTrim(cSer) + " para desvinculo com a fatura " + AllTrim(GXI->GXI_NRFAT) + "/" + AllTrim(GXI->GXI_SERFAT) + " ."
				GFELog116:Add("** Não foi localizado do documento de frete " + AllTrim(cNum) + "/" + AllTrim(cSer) + " para desvinculo com a fatura " + AllTrim(GXI->GXI_NRFAT) + "/" + AllTrim(GXI->GXI_SERFAT) + " .")
			ElseIf nDfFat != nCont
				GXI->GXI_EDIMSG := "Os documentos de frete " + cDfFat + " pertencem a fatura " + AllTrim(GXI->GXI_NRFAT) + "/" + AllTrim(GXI->GXI_SERFAT) + ", porém nem todos estão presentes no registro processado." + CRLF + "É necessário que todos os documentos de frete da fatura estejam vinculados ao registro de exclusão."
				GFELog116:Add("Os documentos de frete " + cDfFat + " pertencem a fatura " + AllTrim(GXI->GXI_NRFAT) + "/" + AllTrim(GXI->GXI_SERFAT) + ", porém nem todos estão presentes no registro processado." + CRLF + "É necessário que todos os documentos de frete da fatura estejam vinculados ao registro de exclusão.")
			EndIf
			GXI->(MsUnlock())
		EndIf
		
		oModel:DeActivate()

		GFELog116:NewLine()
		GFELog116:Save()
	    DbSelectArea('GXI')
	    GXI->( DbSkip() )
	EndDo

	GFELog116:NewLine()

	If nCount == 0 .And. lProc
		GFELog116:Add(STR0010)
		GFELog116:Add("Total de registros processados: " + cValToChar(nTotal))
		If !lSchedDef
			MessageBox ("Nenhum registro processado com sucesso. Total de registros processados: " + cValToChar(nTotal) + CRLF + "Verifique o campo 'Mensagens' dos registros para a descrição dos erros ocorridos.", "Processamento", 48)
		EndIf
	ElseIf nCount == 0 .And. !lProc
		GFELog116:Add("** " + STR0011)
		If !lSchedDef
			MessageBox (STR0011, "Processamento", 48)	// "Não há registros para processar."
		EndIf
	ElseIf nCount > 0 .And. lProc
		GFELog116:Add(STR0009)
		GFELog116:Add(STR0012 + AllTrim(Str(nCount)) + STR0013 + AllTrim(Str(nTotal)))
		If !lSchedDef
			MsgInfo(STR0009 + CRLF + STR0012 + AllTrim(Str(nCount)) + STR0013 + AllTrim(Str(nTotal)) + "." + CRLF + ; //"Processo concluído. " ### "Processado(s) " ### " documento(s) de frete do total de "
				If(nCount != nTotal, "Verifique o campo 'Mensagens' dos registros para a descrição dos erros ocorridos.","") ;
				,"") //"Processo concluído. " ### "Processada(s) " ### " ocorrências(s) do total de "
		EndIf
	EndIf

	GFELog116:EndLog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatNrFat
Formata a numeração da fatura, retirando espaços e zeros a esquerda

@author Israel A. Possoli
@since 18/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FormatNrFat(cStr)
  	Local nI
  	Local nPos := 2

	// Se não possui zeros à esquerda
	If SubStr(cStr, 1, 1) != "0"
		Return cStr
	EndIf

	// Se é para deixar os zeros à esquerda
	If MV_PAR07 == 1
		// Se a string for maior que o tamanho do campo preciso remover os zeros para os valores à direita não serem cortados.
		While Len(cStr) > cGXI_NRFAT .And. SubStr(cStr, 1, 1) == "0"
			cStr := Right( cStr, Len(cStr)-1 )
			Loop
		EndDO
		Return cStr
	EndIf	

	// Se não é para deixar os zeros à esquerda
	For nI := 2 To Len(cStr)
		If SubStr(cStr, nI, 1) == "0"
			nPos++
		Else
			Exit
		EndIf
	Next

Return SubStr(cStr, nPos)

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaGW3
Busca um Documento de Frete e posiciona no registro encontrado.

@return Número do registro encontrado
@since 04/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaGW3(cGW3_FILIAL, cGW3_CDESP, cGW3_EMISDF, cGW3_SERDF, cGW3_NRDF, dDTEMIS)
	Local cNrDf := cGW3_NRDF
	Local nI				:= 0	
	cGW3_EMISDF := PadR(AllTrim(cGW3_EMISDF),TamSx3("GXJ_EMISDF")[1])

	dbSelectArea("GW3")
	GW3->(dbSetOrder(1))	//GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF, GW3_DTEMIS
	GW3->(dbClearFilter())
	
	//-- Busca pela Chave Primária (mais seguro)
	GFELog116:AddDebug("** Buscando Documento de Frete pela chave primária.", 2)

	If GW3->( DbSeek(cGW3_FILIAL + cGW3_CDESP + cGW3_EMISDF + cGW3_SERDF + cNrDf + DToS(dDTEMIS)) )
		GFELog116:AddDebug("- Número: [" + cNrDf + "] [Encontrado]", 3)
		Return (GW3->(RecNo()))
	Else 		
		
		//-- Preenche com zeros a esquerda
		cNrDf := AllTrim(GFEZapZero(cNrDf))
		nI := 16
		GFELog116:AddDebug("** Documento de Frete não encontrado. Preenchendo com zeros a esquerda. Número: [" + cNrDf + "]", 2)
		
		For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
			cNrDf := PadL(cNrDf, nI, "0")
			dbSelectArea("GW3")
			dbSetOrder(1)  // GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF, GW3_DTEMIS
			If GW3->( DbSeek(cGW3_FILIAL + cGW3_CDESP + cGW3_EMISDF + cGW3_SERDF + cNrDf + DToS(dDTEMIS)) )
				
				If ( cGW3_FILIAL == GW3->GW3_FILIAL .And.;						
					cGW3_CDESP == GW3->GW3_CDESP .And.;
					cGW3_EMISDF == GW3->GW3_EMISDF .And.;
					cGW3_SERDF == GW3->GW3_SERDF .And.;
					cNrDf == AllTrim(GW3->GW3_NRDF) .And.;
					DToS(dDTEMIS) == GW3->GW3_DTEMIS )

					GFELog116:AddDebug("- Número: [" + cNrDf + "] [Encontrado]", 3)
					Return (GW3->(RecNo()))
					Exit
				EndIf
			Else
				GFELog116:AddDebug("- Número: [" + cNrDf + "]", 3)
			EndIf
		Next

		//-- Busca pela chave primária sem considerar a Data de Emissão
		GFELog116:AddDebug("** Documento de Frete não encontrado. Desconsiderando Data de Emissão.", 2)

		If GW3->( DbSeek(cGW3_FILIAL + cGW3_CDESP + cGW3_EMISDF + cGW3_SERDF + cGW3_NRDF) )
			GFELog116:AddDebug("- Número: [" + cGW3_NRDF + "] [Encontrado]", 3)
			Return (GW3->(RecNo()))
		Else

			//-- Preenche com zeros a esquerda
			cNrDf := AllTrim(GFEZapZero(cNrDf))
			nI := 16
			GFELog116:AddDebug("** Preenchendo com zeros a esquerda. Número: [" + cNrDf + "]", 2)
			
			For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
				cNrDf := PadL(cNrDf, nI, "0")
				dbSelectArea("GW3")
				dbSetOrder(1)  // GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF, GW3_DTEMIS
				If GW3->( DbSeek(cGW3_FILIAL + cGW3_CDESP + cGW3_EMISDF + cGW3_SERDF + cNrDf) )
					
					If ( cGW3_FILIAL == GW3->GW3_FILIAL .And.;						
					    cGW3_CDESP == GW3->GW3_CDESP .And.;
					    cGW3_EMISDF == GW3->GW3_EMISDF .And.;
					    cGW3_SERDF == GW3->GW3_SERDF .And.;
					    cNrDf == AllTrim(GW3->GW3_NRDF) )

						GFELog116:AddDebug("- Número: [" + cNrDf + "] [Encontrado]", 3)
						Return (GW3->(RecNo()))
						Exit
					EndIf
				Else
					GFELog116:AddDebug("- Número: [" + cNrDf + "]", 3)
				EndIf
			Next

		EndIf

	EndIf

	// -- Busca pelo Emissor, Série, Número (menos restritivo)
	GFELog116:AddDebug("** Documento de Frete não encontrado. Buscando pelo Emissor, Série e Número.", 2)

	dbSelectArea("GW3")
	dbSetOrder(10)	// GW3_FILIAL, GW3_EMISDF, GW3_SERDF, GW3_NRDF
	If dbSeek(	cGW3_FILIAL + cGW3_EMISDF + cGW3_SERDF + cGW3_NRDF)
		GFELog116:AddDebug("- Número: [" + cGW3_NRDF + "] [Encontrado]", 3)
		Return (GW3->(RecNo()))
	Else
		
		//-- Preenche com zeros a esquerda
		cNrDf := AllTrim(GFEZapZero(cNrDf))
		nI := 16
		GFELog116:AddDebug("** Documento de Frete não encontrado. Preenchendo com zeros a esquerda. Número: [" + cNrDf + "]", 2)
		
		For nI := Len(cNrDf) To TamSX3("GW3_NRDF")[1]
			cNrDf := PadL(cNrDf, nI, "0")
			
			dbSelectArea("GW3")
			dbSetOrder(10) // GW3_FILIAL + GW3_EMISDF + GW3_SERDF + GW3_NRDF
			If dbSeek(cGW3_FILIAL + cGW3_EMISDF + cGW3_SERDF + cNrDf)
				
				If ( cGW3_FILIAL == GW3->GW3_FILIAL .And.;						
					cGW3_EMISDF == GW3->GW3_EMISDF .And.;
					cGW3_SERDF == GW3->GW3_SERDF .And.;
					cNrDf == AllTrim(GW3->GW3_NRDF) )				

					GFELog116:AddDebug("- Número: [" + cNrDf + "] [Encontrado]", 3)
					Return (GW3->(RecNo()))
					Exit
				EndIf
			Else
				GFELog116:AddDebug("- Número: [" + cNrDf + "]", 3)
			EndIf
		Next

	EndIf
	
Return (0)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEVldSIX
Função responsavel por validar a existencia de indice em tabela de sistema.

@version 1.0
@author Matheus de Souza
@since 11/06/2024
/*/
//-------------------------------------------------------------------
Static Function GFEVldSIX(cTab, cOrdem)
	Local lRet := .F.

	SIX->(dbSetOrder(1))
	If SIX->(dbSeek(cTab+cOrdem))
		lRet := .T.
	EndIf

	//Pesquisa por ordem
	//FWSIXUtil():ExistIndex( "GW3" , "16" )

Return lRet
