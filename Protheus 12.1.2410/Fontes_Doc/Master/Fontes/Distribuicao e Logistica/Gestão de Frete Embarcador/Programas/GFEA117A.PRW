#INCLUDE "GFEA117A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA117A 
EDI - Importação de Ocorrências

GXL - Espelho da GW3

@author Israel A. Possoli 
@since 27/06/12
@version 1.0
/*/
//-------------------------------------------------------------------

Static __nTamNrDC  := TamSX3("GW1_NRDC")[1]
Static __nTamSrDC  := TamSX3(SerieNfId("GW1",3,"GW1_SERDC"))[1]
Static __lNewKey   := TamSX3("GW1_SERDC")[1] == 14
Static s_VLCNPJ    := SuperGetMV('MV_VLCNPJ',,'1')
Static s_GFEA1172  := ExistBlock("GFEA1172")
Static s_CDTIPOE   := SuperGetMv("MV_CDTIPOE",.F.,Space(TamSx3("GU4_CDTIPO")[1]))
Static s_CDTIPOE_2 := SuperGetMv("MV_CDTIPOE",.F.,Space(TamSx3("GU4_CDMOT")[1]))
Static s_REGOCO    := SuperGetMv("MV_REGOCO",.F.,"1")
Static s_GFEA1171  := ExistBlock("GFEA1171")
Static s_GFEA0513  := ExistBlock( "GFEA0513" )
Static s_TMS2GFE   := SuperGetMv("MV_TMS2GFE",.F.,.F.)
Static s_GFEA1173  := ExistBlock("GFEA1173")

Function GFEA117IMP()
	Private tTabOCO				// Tabela temporária do conhecimento
	Private aCamposOCO := {}	// Campos da tabela intermediária de CTRC
	Private oProcess := Nil
	lVerPerg := .T.
	
		If IsBlind()
			CriaTab()
			Importacao()
			GFEDelTab(tTabOCO)
		Else
			// Início Ponto de Entrada Procomp
			If ExistBlock("GFEXPERG")   
				lVerPerg := ExecBlock("GFEXPERG",.f.,.f.,{})
			EndIf
			// Fim Ponto de Entrada Procomp
			If Pergunte("GFEA117",lVerPerg) .Or. !lVerPerg
				CriaTab()
				
				oProcess := MsNewProcess():New({|| Importacao()}, "EDI - Importação Ocorren", "Importando arquivos")
				oProcess:Activate()
				
				GFEDelTab(tTabOCO)
			Else
				Return .F.
			EndIf
		EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA117PRO
Processamento das Ocorrências importadas

GWD - Ocorrências
GWL - Doc Cargas X Ocorrências

@author Israel A. Possoli
@since 03/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA117PRO()

	If IsBlind()
		Processamento() //Chamada via Schedule
	Else
		Processa({|| Processamento()},"Processando registros", "Processando registros...",.F.)
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTab
Criação das tabelas temporárias

@author Israel A. Possoli
@since 11/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab()
	aCamposOCO := { {"GXL_FILIAL", "C", TamSx3("GWD_FILIAL")[1], 0},;
					{"GXL_NRIMP" , "C", 16, 0},;
					{"GXL_FILOCO", "C", Len(cFilAnt), 0},;
					{"GXL_CDTRP" , "C", 14, 0},;
					{"GXL_DTOCOR", "D", 8 , 0},;
					{"GXL_HROCOR", "C", TamSx3("GWD_HROCOR")[1] , 0},;
					{"GXL_FILDC" , "C", Len(cFilAnt), 0},;
					{"GXL_EMISDC", "C", TamSx3("GXL_EMISDC")[1], 0},;
					{"GXL_SERDC" , "C", TamSx3("GXL_SERDC")[1] , 0},;
					{"GXL_NRDC"  , "C", 16, 0},;
					{"GXL_CODOCO", "C", 2 , 0},;
					{"GXL_OBS"   , "C", TamSx3("GXL_OBS")[1], 0},;
					{"GXL_EDISIT", "C", 1,  0},;
					{"GXL_EDIMSG", "M", 10, 0},;
					{"GXL_EDINRL", "N", 5 , 0},;
					{"GXL_EDILIN", "M", 999, 0},;
					{"GXL_EDIARQ", "C", 200, 0},;
					{"GXL_CODOBS", "N", 2 , 0},;
					{"GXL_CDTIPO", "C", TamSx3("GU4_CDTIPO")[1] , 0},;
					{"GXL_CDMOT", "C", TamSx3("GU4_CDMOT")[1] , 0}}

	tTabOCO := GFECriaTab({aCamposOCO,{"GXL_FILIAL+GXL_NRIMP"}})
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Importacao
EDI - Importação de Ocorrências

@author Israel A. Possoli
@since 14/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importacao()
Local aDirImpor   := {} // Array com os arquivos do diretorio
Local nCountFiles := 0  // Contador dos arquivos do diretorio
Local cLayoutVer  := "" // Versão do Layout 3 ou 5
Local cFormatDt   := Nil
Local cFormatTm   := Nil
Local cNewNomeArq := ""
Local cDiretorio  := AllTrim(MV_PAR04)
Local cDirOk      := AllTrim(MV_PAR05)
Local cDirErro    := AllTrim(MV_PAR06)
Local bCtrlFluxo  := Nil
Local lNovoLayout := .F.
Local cBuffer     := ""

Private cFilialOcor    := ""
Private cNomeArq       := ""
Private nNRIMP         := 0
Private nCountImpor    := 0  // Contador de arquivos importados
Private cMsgPreVal     := "" // Armazena as mensagens de pré-validações para o Campo Observação (Importação)
Private GFELog117      := GFELog():New("EDI_Ocorrencias_Importacao", "EDI Ocorrências - Importação", SuperGetMV('MV_GFEEDIL',,'1'))
Private GFEFile        := GFEXFILE():New()
Private GFEResult      := GFEViewProc():New()
Private lImpOK         := .F.
Private lImpErr        := .F.
Private lArquivoValido := .F.
 
	cFilialOcor := MV_PAR03

	If Empty(cFilialOcor)
		Help( ,, 'HELP',, "É necessário informar a filial onde as ocorrências serão criadas.", 1, 0)
		Return .F.
	EndIf
	GFELog117:ShowParameters("GFEA117")

	// Validação do diretório de importação
	If Empty(cDiretorio)
		GFELog117:Add("** " + "Diretório de importação deve ser informado.")
		GFELog117:EndLog()
		MsgAlert("Diretório de importação deve ser informado.", "Aviso")
		Return
	EndIf

	aDirImpor := DIRECTORY(cDiretorio + "\*.TXT" )

	// Verifica se existe arquivos no diretório informado
	If Len(aDirImpor) == 0
		GFELog117:Add("** " + "Nenhum arquivo encontrado no diretório " + cDiretorio)
		GFELog117:EndLog()
		MsgAlert("Nenhum arquivo encontrado no diretório " + cDiretorio, "Aviso")
		Return
	EndIf

	// Data e Hora
	cFormatDt := stuff(DTOC(date()),3,1,'')
	cFormatDt := stuff(cFormatDt,5,1,'')

	cFormatTm := stuff(Time(),3,1,'')
	cFormatTm := stuff(cFormatTm,5,1,'')

	GFELog117:Add("- Início da importação")
	GFELog117:NewLine()
	GFELog117:Save()
	
	If oProcess != Nil
		oProcess:SetRegua1(Len(aDirImpor) * 2)
	EndIf
	//ProcRegua(Len(aDirImpor))

	For	nCountFiles := 1 To Len(aDirImpor)
		lImpOK         := .F.
		lImpErr        := .F.
		lArquivoValido := .T.
	
		cNomeArq := aDirImpor[nCountFiles][1]
		
		If oProcess != Nil
			oProcess:IncRegua1(cNomeArq)
		EndIf

		GFELog117:Add(Replicate("-", 80))
		GFELog117:Add("[" + ALLTRIM(STR(nCountFiles)) + "] Arquivo: " + cNomeArq)

		If oProcess != Nil
			oProcess:SetRegua2(100)
			oProcess:IncRegua2("Carregando arquivo")
			bCtrlFluxo := "oProcess:IncMeter(oProcess:oMeter2, Round(nPosFile * 100 / nLenghtFile, 0))"
		EndIf
		
		GFEFile:Clear()
		If !GFEFile:Open(cDiretorio + "\" + cNomeArq, bCtrlFluxo)
			GFELog117:Add("  ** "+GFEFile:GetError())
			GFELog117:Add("  ** Linha: " + cBuffer)
			GFEResult:AddErro(GFEFile:GetError())
			lArquivoValido := .F.
		EndIf
		If oProcess != Nil
			oProcess:IncRegua1()
			oProcess:IncRegua2("Validando layout")
			oProcess:SetRegua2(GFEFile:nQtdeLin)
		EndIf
		If lArquivoValido
			If !GFEFile:FEof()
				cBuffer := GFEFile:Line()
			EndIf
			
			//Se o Arquivo estiver em branco retornará uma mensagem em tela e no log e continuará a importação
			If Empty(cBuffer)
					GFELog117:Add("  ** Arquivo em branco.")
					GFELog117:Add("  ** Linha: " + cBuffer)
					GFEResult:AddErro("Arquivo: '" + cNomeArq + "' em branco.")
					lArquivoValido := .F.
			EndIf
			
			If SubStr(cBuffer, 1, 8) == "TOTVSOCT"
				GFEA117C()
				lNovoLayout := .T.
			EndIf

			// Verifica se é um arquivo válido. Identificador '000'.
			If SubStr(cBuffer,01,03) != "000" .And. !lNovoLayout
				GFELog117:Add("  ** Arquivo inválido. Não foi possível encontrar o Registro '000' - Cabeçalho de Intercâmbio.")
				GFELog117:Add("  ** Linha: " + cBuffer)
				GFEResult:AddErro("Arquivo: '" + cNomeArq + "' inválido.")
				GFELog117:NewLine()
				GFELog117:Save()
				lArquivoValido := .F.
			EndIf

			// Validação da versão do Layout
			If lArquivoValido .And. !lNovoLayout
				GFEFile:FNext()
				cBuffer := GFEFile:Line()

				// Identifica a versão Layout do arquivo
				cLayoutVer := SubStr(cBuffer, 01, 03)

				// Valida a versão do layout do arquivo
				If (cLayoutVer != "340" .AND. cLayoutVer != "540") .OR. Empty(cLayoutVer)
					GFELog117:Add("** " + "Arquivo '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.", 1)
					GFELog117:Save()
									
					GFEResult:AddErro(Replicate('-', 50) + CHR(13) + CHR(10) + ;
									UPPER(cNomeArq) + CHR(13) + CHR(10) 	 + ;
									Replicate('-', 50) + CHR(13) + CHR(10) + ;
									"Arquivo: '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema." + CHR(13) + CHR(10))
					lArquivoValido := .F.
				EndIf
			EndIf

			// Leitura do Arquivo e Gravação do Arquivo
			If lArquivoValido .And. !lNovoLayout
				If cLayoutVer == "340"
					GFELog117:Add("Versão EDI: 3.1")
					GFELog117:NewLine()
					LayoutPro3()
				ElseIf cLayoutVer == "540"
					GFELog117:Add("Versão EDI: 5.0")
					GFELog117:NewLine()
					GFEA117B()
				EndIf

				// Gravação para na tabela intermediária
				GerarGXL()
				
				If s_GFEA1172
					ExecBlock("GFEA1172",.F.,.F.,Nil)
				EndIf
			EndIf
		EndIf
		// Transferência do arqivos para os diretórios de Ok e NOk
		cNewNomeArq := cFormatDt + "_" + cFormatTm + "_" + cNomeArq
		If lArquivoValido //se chegar ao fim do arquivo sem erros
			If (FRename(cDiretorio + "\" + cNomeArq, cDirOk + "\" + cNewNomeArq) == -1)
				GFELog117:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq, "Aviso")
			EndIf

			If lImpErr
				GFEResult:Add("ARQUIVO IMPORTADO COM ERROS.")
			Else
				GFEResult:Add("ARQUIVO IMPORTADO.")
			EndIf
		Else
			If (FRename(cDiretorio + "\" + cNomeArq, cDirErro + "\" + cNewNomeArq) == -1)
				GFELog117:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq, "Aviso")
			EndIf

			GFEResult:Add("ARQUIVO NÃO IMPORTADO.")
		EndIf
		GFEResult:Add(" ")
	Next

	If nCountImpor == 0
		GFELog117:Add("Nenhuma ocorrência foi importada para a faixa informada.")
	EndIf
	
	GFEResult:Show("Importação de arquivos", "Arquivos", "Erros", "Ocorreram erros na importação de um ou mais arquivos. Clique no botão 'Erros' para mais detalhes.")
		
	GFELog117:EndLog()
	

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarGXL
Geração da tabela intermediária GXL

@author Israel A Possoli
@since 13/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarGXL()
	Local nI
	Local cNRIMP

	dbSelectArea((tTabOCO))
	dbGoTop()

	// Conhecimentos
	While !(tTabOCO)->(EOF())
		cNRIMP := GETSXENUM("GXL", "GXL_NRIMP")

		RecLock("GXL", .T.)
			GXL->GXL_FILIAL := xFilial("GXL")
			GXL->GXL_NRIMP  := cNRIMP
			GXL->GXL_MARKBR := Iif(IsBlind(), "", oBrowse117:Mark())
			GXL->GXL_USUIMP := cUserName
			GXL->GXL_DTIMP  := Date()
			GXL->GXL_ALTER  := "2"

			// Grava todos os campos, com execção do GXG_FILIAL e GXG_NRIMP
			For nI := 3 To Len(aCamposOCO)
				&("GXL->" + aCamposOCO[nI][1] + " := (tTabOCO)->" + aCamposOCO[nI][1])
			Next
		GXL->(MSUnlock())

		ConfirmSX8()

		(tTabOCO)->(dbSkip())
	EndDo

	dbSelectArea((tTabOCO))
	Zap

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} LayoutPro3
EDI - Importação de Documento de Frete

@author Felipe Rafael Mendes
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LayoutPro3()
	Local nContLinhas := 0 // Contador de Linhas do arquivo
	Local lFindGW1    := .F.
	Local lSelecao    := .T.
	Local cCGCTrp     := ""
	Local cCdTrp      := ""
	Local cCdEmis     := ""
	Local cFilDc      := ""
	Local cFilDcGW1   := ""
	Local cBuffer     := ""
	Local lCdTipo     := s_REGOCO == "2"
	Local nI          := 0
	Local nICont      := 0
	Local cNumeroNF   := ""
	Local cNumeroAux  := ""
	Local cSerDCBase  := ""
	Local cNrDCBase   := ""
	Local cCgcEmis    := ""
	Local aGW1        := {}
	local lEncDoc     := .F.
	Local lOcorrencia := .T.
	Local nCountDC    := 0 // Contador do tamanho do número do DC
	Local cAliasGU3   := Nil
	Local cAliasQry   := Nil
	Local aDcChave    := {}
	Local dDataOcor   := Nil
	Local cHrOcor     := ""
	Local aVldOcor    := {}
	Local aVldDtEmis  := {}
	Local cCdOco      := ""
	Local cCdTipo     := ""
	Local cCdMot      := ""
	Local cCdObs      := 0
	Local nGU4_CDMOT  := TamSx3("GU4_CDMOT")[1]
	Local nGU4_CDTIPO := TamSx3("GU4_CDTIPO")[1]
	
	
	If oProcess != Nil
		oProcess:SetRegua2(GFEFile:nQtdeLin)
	EndIf
	
	GFEResult:Add(Replicate('-', 50) + CHR(13) + CHR(10) + UPPER(cNomeArq) + CHR(13) + CHR(10) + Replicate('-', 50), 0)
	
	Do While !GFEFile:FEof()
		If oProcess != Nil
			oProcess:IncRegua2()
		EndIf

		nContLinhas++

		cBuffer := GFEFile:Line()
		If SubStr(cBuffer,01,03) == "343"
			// pula para a proxima linha 342 ou 341.
			GFEFile:FNext()
			If !GFEFile:FEof()
				cBuffer := GFEFile:Line()
			EndIf
		EndIf
  
		lOcorrencia := .T.
		cCdOco      := ""
		cCdObs      := 0
		cCdTipo     := ""
		cCdMot      := ""

		// Verificação da faixa do Transportador
		If SubStr(cBuffer,01,03) == "341" 
			cCGCTrp	:= AllTrim(SubStr(cBuffer,04,14))
			GFELog117:Add("# BUSCANDO DADOS BASE", 1)

			//Lê a linha seguinte, buscando o primeiro Doc. Carga. Valida a existência de registro 342.
			GFEFile:FNext()
			If !GFEFile:FEof()
				cBuffer := GFEFile:Line()
			EndIf
			
			If SubStr(cBuffer,01,03) != "342"
				lArquivoValido := .F.

				GFELog117:Add("** " + "Arquivo '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.", 1)
				GFELog117:Add("*** " + "O segmento 342 é item obrigatório e não foi possível encontrá-lo no arquivo.", 1)
				GFELog117:Save()

				GFEResult:AddErro(Replicate('-', 50) + CHR(13) + CHR(10) + ;
									UPPER(cNomeArq) + CHR(13) + CHR(10) 	 + ;
									Replicate('-', 50) + CHR(13) + CHR(10) + ;
									"Arquivo: '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema." + CHR(13) + CHR(10) +;
									"O segmento 342 é item obrigatório e não foi possível encontrá-lo no arquivo.")
				Return
			Endif
		EndIf

		If SubStr(cBuffer, 01, 03) == "342"

			//Lê os dados do documento de carga para determinar o transportador (342)
			cFilDcGW1  := ""
			cCdTrp     := ""
			cCdEmis    := ""
			cCgcEmis   := AllTrim(SubStr(cBuffer,04,14))
			cSerDCBase := PadR(AllTrim(SubStr(cBuffer,18,03)), __nTamSrDC) // Serie DC
			cNrDCBase  := AllTrim(SubStr(cBuffer,21,08)) // Numero DC
			cNumeroAux := cNrDCBase
			cNrDCBase  := GFEZapZero(cNrDCBase)
			cNumeroNF  := "" // Inicializa o número do documento
			
			lFindGW1   := .F.

			// Determina o transportador para cada documento de carga, pois pode haver o gerador do 
			// arquivo pode ter cnpj diferente do transportador
			cAliasGU3 := GetNextAlias()
			BeginSql Alias cAliasGU3
				SELECT GU3.GU3_CDEMIT
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3%
				AND GU3.GU3_IDFED = %Exp:cCgcEmis%
				AND GU3.%NotDel%
				ORDER BY GU3.GU3_SIT
			EndSql
			Do While (cAliasGU3)->(!Eof()) .And. cCgcEmis != PadR('',14,'0') .And.  !lFindGW1
				cCdEmis := (cAliasGU3)->GU3_CDEMIT
			
				GW1->(dbSelectArea("GW1"))
				GW1->(dbSetOrder( If(__lNewKey,19,13) )) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
				cCdTrp := ""
				
				// Regra para buscar o número da nota fiscal no GFE:
				// Inicia a busca a partir do número sem zeros à esquerda e enquanto
				// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
				nICont := Len(cNrDCBase)
				For nI := nICont To __nTamNrDC
					cNumeroNF := GFEGetNrDc(cNrDCBase, nI)
					//Busca o Emitente relacionado ao Documento de Carga
					aDcChave := {}
					If __lNewKey // Chave única							
						aDcChave := GFEA517SDC(PadR(cNumeroNF,Len(GW1->GW1_NRDC)), "", (cAliasGU3)->GU3_CDEMIT, cSerDCBase,"")
					EndIf
					
					If Len(aDcChave) > 0
						GW1->(dbGoTo(aDcChave[1,8]))
					EndIf
					
					If Len(aDcChave) > 0 .Or. GW1->(dbSeek((cAliasGU3)->GU3_CDEMIT+cSerDCBase+PadR(cNumeroNF,Len(GW1->GW1_NRDC)))) .Or. GF117AGXP((cAliasGU3)->GU3_CDEMIT,cSerDCBase,PadR(cNumeroNF,Len(GW1->GW1_NRDC)))
						GFELog117:Add("# Determinando o código do transportador pelo Doc Carga : Emissor [" + (cAliasGU3)->GU3_CDEMIT + "] Série [" + cSerDCBase + "] Número [" + cNrDCBase + "] ou pelo CNPJ do transportador [" + cCGCTrp + "]", 1)

						aGW1 := {}

						aAdd(aGW1,{GW1->GW1_FILIAL,;
									1,;
									GW1->GW1_EMISDC,;
									GW1->GW1_SERDC,;
									GW1->GW1_NRDC,;
									GW1->GW1_CDTPDC,;
									""}) //chave nf-e

						cFilDcGW1 := GW1->GW1_FILIAL	
						cCdTrp := A118EMIT("1",cCGCTrp,aGW1)
						GFELog117:Add("- Transportador encontrado: " + cCdTrp, 1)
						lFindGW1 := .T.
						Exit
					EndIf
				Next nI
				(cAliasGU3)->(dbSkip())
			EndDo
			(cAliasGU3)->(dbCloseArea())
			
			// Atribui o número do documento da importação quando não existe o CGC cadastrado
			If Empty(cNumeroNF)
				cNumeroNF  := cNumeroAux
			EndIf
			GFELog117:Add("  CNPJ do Transportador no arquivo: " + AllTrim(cCGCTrp))

			// Log e pré-validação do Emitente
			If Empty(MV_PAR01) .And. Empty(MV_PAR02)
				lSelecao := .T.
			ElseIf !Empty(cCdTrp) .And. cCdTrp >= MV_PAR01 .And. cCdTrp <= MV_PAR02
				lSelecao := .T.
			ElseIf Empty(cCdTrp)
				GFELog117:Add("** Documento de Carga " + cNrDCBase + " não encontrado com transportador com CNPJ/CPF: " + cCGCTrp + ".")
				GFEResult:Add("Documento de Carga " + cNrDCBase + " não encontrado com transportador com CNPJ/CPF: " + cCGCTrp + ".")
				GFEResult:SetWarningIcon()
			Else 
				GFELog117:Add("** Transportador '" + cCdTrp + "' fora da faixa informada.")
				GFEResult:Add("Transportador '" + cCdTrp + "' fora da faixa informada.")
				GFEResult:SetWarningIcon()
				lArquivoValido := .F.
				lSelecao := .F.
			EndIf

			If lSelecao	
				// Código do emissor do Documento de Carga
				If Empty(cCdEmis)
					GFELog117:Add("** " + "Emitente inativo ou não encontrado com CNPJ/CPF: " + cCgcEmis, 1)
				EndIf
		
				// Filial do Documento de Carga com base no Emissor do CNPJ/CPF da Nota
				GFELog117:Add("# Buscando a filial do documento de carga pelo emissor: " + cCgcEmis, 1)
				cFilDc := ""
				SM0->( dbGoTop() )
				Do While SM0->(!Eof())
					If SM0->M0_CGC == ALLTRIM(SubStr(cBuffer, 04, 14))
						cFilDc := SM0->M0_CODFIL
						GFELog117:Add("- Filial encontrada: " + cFilDc, 1)
						Exit
					EndIf
					dbSelectArea("SM0")
					SM0->( dbSkip() )
				EndDo
				If Empty(cFilDc)
					GFELog117:Add("** " + "Filial não encontrada para a empresa de CNPJ:" + cCgcEmis, 1)
					If !Empty(cFilDcGW1)
						cFilDc := cFilDcGW1
					Else
						cFilDc := cFilialOcor
					EndIf
				EndIf

				GFELog117:Add("Documento de Carga: ", 1)
				GFELog117:Add("> CNPJ Emissor.: " + cCgcEmis, 2)
				GFELog117:Add("> Filial.......: " + cFilDc, 2)
				GFELog117:Add("> Emissor......: " + cCdEmis, 2)
				GFELog117:Add("> Série........: " + cSerDCBase, 2)
				GFELog117:Add("> Número.......: " + cNumeroNF, 2) //Grava o número do documento e não o enviado no EDI, pois pode haver zeros à esquerda
				GFELog117:Save()

				lImpOK := .T.
				cMsgPreVal := ""
				nCountImpor++
				nNRIMP++
				
				//Realiza a validação da data chamado TVWY22
				dDataOcor := StoD(SubStr(SubStr(cBuffer,31,08),5,4)+SubStr(SubStr(cBuffer,31,08),3,2)+SubStr(SubStr(cBuffer,31,08),1,2))
				cHrOcor := SubStr(cBuffer,39,4)
				cHrOcor := SubStr(cHrOcor,1,2) + ":" + SubStr(cHrOcor,3,2)
				
				aVldOcor := GFEVLDDTHR("00:00", DtoS(dDataOcor),,,"da ocorrência")
				
				If !aVldOcor[1]
					GFELog117:Add("- " + aVldOcor[2], 1)
					GFELog117:Save()
					cMsgPreVal += "- "  + aVldOcor[2] + CRLF
				EndIf

				cCdOco  := SubStr(cBuffer,29,02)       
				cCdObs  := Val(SubStr(cBuffer,43,2))  
				cCdMot := cCdOco                      //o que vem no EDI é o motivo da Entrega
				
				If !Empty(s_CDTIPOE) .And. lCdTipo .And. cCdObs == 3   //Se gera Ocorrencia para Entrega e É uma Entrega
					//Tipo da Ocorrencia definida no parametro
					cCdTipo := s_CDTIPOE					

					// Verifica se o tipo de ocorrência está cadastrado e ativo
					// Caso não encontre tenta buscar com o preenchimento de zeros
					// Encotrando atribui o tipo e motivo
					For nI := 1 To 2
						If nI == 2
							cCdTipo := StrZero(Val(cCdTipo),nGU4_CDTIPO)
						EndIf
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT GU5.GU5_CDTIPO
								, GU6.GU6_CDMOT
							FROM %Table:GU4% GU4
							LEFT JOIN %Table:GU5% GU5
							ON GU5.GU5_FILIAL = %xFilial:GU5%
							AND GU5.GU5_CDTIPO = GU4.GU4_CDTIPO
							AND GU5.%NotDel%
							LEFT JOIN %Table:GU6% GU6
							ON GU6.GU6_FILIAL = %xFilial:GU6%
							AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
							AND GU6.GU6_SIT = '1'
							AND GU6.%NotDel%
							WHERE GU4.GU4_FILIAL = %xFilial:GU4%
							AND GU4.GU4_CDTIPO = %Exp:cCdTipo%
							AND GU5.GU5_SIT = '1'
							AND GU4.%NotDel%
						EndSql
						If (cAliasQry)->(!Eof())
							cCdTipo := (cAliasQry)->GU5_CDTIPO
							cCdMot  := (cAliasQry)->GU6_CDMOT
							lOcorrencia := .T.			
						Else
							lOcorrencia := .F.
						EndIf
						(cAliasQry)->(dbCloseArea())

						If lOcorrencia
							Exit // Encotrou a ocorrência e sairá do laço
						EndIf
					Next nI

				Else   // ELSE busca a relação TipoxMotivo pelo MOTIVO
					// Verifica se o tipo de ocorrência está cadastrado e ativo
					// Caso não encontre tenta buscar com o preenchimento de zeros
					// Encotrando atribui o tipo e motivo
					cCdMot := cValToChar( Val(cCdMot) )
					For nI := 1 To nGU4_CDMOT
						If nI > 1
							cCdMot := Iif(nGU4_CDMOT > Len(cCdMot), "0" + cCdMot, cCdMot)
						EndIf
						
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT GU5.GU5_CDTIPO,
									GU6.GU6_CDMOT
							FROM %Table:GU4% GU4
							LEFT JOIN %Table:GU5% GU5
							ON GU5.GU5_FILIAL = %xFilial:GU5%
							AND GU5.GU5_CDTIPO = GU4.GU4_CDTIPO
							AND GU5.%NotDel%
							LEFT JOIN %Table:GU6% GU6
							ON GU6.GU6_FILIAL = %xFilial:GU6%
							AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
							AND GU6.GU6_SIT = '1'
							AND GU6.%NotDel%
							WHERE GU4.GU4_FILIAL = %xFilial:GU4%
							AND GU4.GU4_CDMOT = %Exp:cCdMot%
							AND GU5.GU5_SIT = '1'
							AND GU4.%NotDel%
						EndSql
						If (cAliasQry)->(!Eof())
							cCdTipo := (cAliasQry)->GU5_CDTIPO
							cCdMot  := (cAliasQry)->GU6_CDMOT
							lOcorrencia := .T.								
						Else
							lOcorrencia := .F.
							GFELog117:Add("** Não foi encontrado o tipo de ocorrencia para a motivo indicado no arquivo: " + cCdMot, 1)
						EndIf
						(cAliasQry)->(dbCloseArea())
						// Encotrou a ocorrência e sairá do laço
						If lOcorrencia
							Exit
						EndIf
					Next nI
			    EndIf

				RecLock((tTabOCO),.T.)
					(tTabOCO)->GXL_FILIAL := xFilial("GXL")
					(tTabOCO)->GXL_FILOCO := cFilDc
					(tTabOCO)->GXL_CDTRP  := cCdTrp
					(tTabOCO)->GXL_NRIMP  := ALLTRIM(STR(nNRIMP))
					(tTabOCO)->GXL_FILDC  := cFilDc
					(tTabOCO)->GXL_EMISDC := cCdEmis
					(tTabOCO)->GXL_SERDC  := cSerDCBase
					(tTabOCO)->GXL_NRDC   := cNumeroNF
					(tTabOCO)->GXL_CODOCO := cCdOco
					(tTabOCO)->GXL_CODOBS := cCdObs
					(tTabOCO)->GXL_CDTIPO := cCdTipo
					(tTabOCO)->GXL_CDMOT  := cCdMot
					(tTabOCO)->GXL_DTOCOR := dDataOcor
					(tTabOCO)->GXL_HROCOR := cHrOcor 
					(tTabOCO)->GXL_OBS    := SubStr(cBuffer,45,70)
					(tTabOCO)->GXL_EDILIN := cBuffer
					(tTabOCO)->GXL_EDIARQ := cNomeArq
					(tTabOCO)->GXL_EDINRL := nContLinhas
					(tTabOCO)->GXL_EDISIT := '1'

					// --------------------------------------------------------- //
					// -----------------Pré-Validações ------------------------- //
					// --------------------------------------------------------- //
					GW1->(dbSelectArea("GW1"))
					GW1->(dbSetOrder( If(__lNewKey,19,13) )) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
					
					aDcChave := {}
					If __lNewKey // Chave única
						aDcChave := GFEA517SDC((tTabOCO)->GXL_NRDC, "", (tTabOCO)->GXL_EMISDC, PadR((tTabOCO)->GXL_SERDC,__nTamSrDC),"")
					EndIf	
						
					If Len(aDcChave) > 0
						GW1->(dbGoTo(aDcChave[1,8]))
					EndIf
					
					If Len(aDcChave) > 0 .Or. (GW1->(dbSeek((tTabOCO)->GXL_EMISDC + PadR((tTabOCO)->GXL_SERDC,__nTamSrDC) + (tTabOCO)->GXL_NRDC))) .Or. GF117AGXP((tTabOCO)->GXL_EMISDC,PadR((tTabOCO)->GXL_SERDC,__nTamSrDC),(tTabOCO)->GXL_NRDC)
						lEncDoc := .T.
					Else
						GFELog117:Add("** Documento de Carga não encontrado.", 1)
						GFELog117:Add("- Tentativa de busca do número com zeros à esquerda.", 1)
						lEncDoc := .F.
						cNrDC   := AllTrim((tTabOCO)->GXL_NRDC)
						// Regra para buscar o número da nota fiscal no GFE:
						// Inicia a busca a partir do número sem zeros à esquerda e enquanto
						// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
						nICont := Len(cNrDC)
						For nCountDC := nICont To __nTamNrDC
							cNrDC := GFEGetNrDc((tTabOCO)->GXL_NRDC, nCountDC)
							If !Empty(cNrDC)
								dbSelectArea("GW1")
								GW1->( dbSetOrder(If(__lNewKey,19,13)) ) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
							
								aDcChave := {}
								If __lNewKey // Chave única
									aDcChave := GFEA517SDC(PadR(cNrDC,Len(GW1->GW1_NRDC)), "", (tTabOCO)->GXL_EMISDC, PadR((tTabOCO)->GXL_SERDC,__nTamSrDC),"")
								EndIf

								If Len(aDcChave) > 0
									GW1->(dbGoTo(aDcChave[1,8]))
								EndIf
								
								If Len(aDcChave) > 0 .Or. GW1->(dbSeek((tTabOCO)->GXL_EMISDC + PadR((tTabOCO)->GXL_SERDC, __nTamSrDC) + cNrDC)) .Or. GF117AGXP((tTabOCO)->GXL_EMISDC,PadR((tTabOCO)->GXL_SERDC,__nTamSrDC),cNrDC)
									lEncDoc := .T.
									GFELog117:Add("> Número.: " + cNrDC + "[Encontrado]", 1)
									Exit
								Else
									GFELog117:Add("> Número.: " + cNrDC, 1)
								EndIf
							EndIf
						Next
					EndIf
				
					If !lEncDoc
						cMsgPreVal +="- "  + "Doc Carga base não encontrado: Emissor [" + cCdEmis + "] Série [" + SubStr(cBuffer,18,03) + "] Número [" +  SubStr(cBuffer,21,08) + "]" + CRLF
					Else
						aVldDtEmis := GFEVLDDTHR("00:00", DToS(GW1->GW1_DTEMIS), cHrOcor, DtoS(dDataOcor), "de emissão do DC", "da ocorrência")
						If !aVldDtEmis[1]
							GFELog117:Add("- Documento " + Alltrim(GW1->GW1_NRDC) + "/" + Alltrim(GW1->GW1_SERDC) + ": " + aVldDtEmis[2], 1)
							GFELog117:Save()
							cMsgPreVal += "- Documento " + Alltrim(GW1->GW1_NRDC) + "/" + Alltrim(GW1->GW1_SERDC) + ": " + aVldDtEmis[2] + CRLF
						EndIf
					EndIf

					If !lOcorrencia
						cMsgPreVal +="- "  + "Código da Ocorrência não encontrado: "+(tTabOCO)->GXL_CODOCO + CRLF
					EndIf 

					If Empty((tTabOCO)->GXL_CDTRP)
						If !Empty(cCGCTrp)
							cMsgPreVal += "- " + "Transportador não encontrado. CNPJ/CPF: " + cCGCTrp + CRLF
						Else
							cMsgPreVal += "- " + "Dados do transportador não informados no registro 341." + CRLF
						EndIf
					EndIf

					If Empty((tTabOCO)->GXL_FILDC)
						cMsgPreVal += "- "  + "Filial da Nota não encontrada. CNPJ/CPF:" + SubStr(cBuffer,04,14) + CRLF
					EndIf

					If Empty((tTabOCO)->GXL_EMISDC)
						cMsgPreVal += "- "  + "Emissor da nota inativo ou não encontrado. CNPJ/CPF: " + SubStr(cBuffer,04,14) + CRLF
					EndIf

					If !Empty(cMsgPreVal)
							(tTabOCO)->GXL_EDIMSG := cMsgPreVal
							(tTabOCO)->GXL_EDISIT := '2'
							lImpErr := .T.
					EndIf

				(tTabOCO)->(MsUnLock())
			EndIf
		EndIf

		GFEFile:FNext()

		GFELog117:NewLine()
		GFELog117:Save()
	EndDo
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Processamento
Rotina para processar as ocorrências importadas.

@author Felipe Rafael Mendes
@since 17/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processamento()
Local lRet       := .T.
Local lProc      := .F.
Local oModel     := Nil
Local oModelGWD  := Nil
Local oModelGWL  := Nil
Local aArea      := GetArea()
Local aAreaSM0   := SM0->( GetArea() )
Local nCount     := 0
Local nTotal     := 0
Local cTpDc      := ""
Local cDsOcor    := ""
Local cDsTipo    := ""
Local cTipo      := ""
Local cDtOcor    := ""
Local cHrOcor    := ""
Local cFilOco    := ""
Local cCdMot     := ""
Local cNrDC      := ""
Local aNrRoms    := {}
Local lBuscaDC   := .F.
Local nTrechoRec := 0 // RecNo do Trecho de entrega
Local nCountTrEn := 0 // Total de trechos pagos
Local nPosTrecho := 0 // Posição do trecho a ser entregue em relação aos trechos do Documento de Carga
Local nCountDC   := 0 // Contador do tamanho do número do DC
Local nICont     := 0
Local cMarcaBrw  := ''
Local cDocTrp    := "" // chave documento transporte
Local aAreaGWL   := {}
Local aAreaGXL   := {}
Local cChaveGXL  := ""
Local cFilGXL    := ""
Local aDocTrp    := {}
Local nDocTrp    := 0
Local nGXL       := 0
Local lSchedule  := IsBlind()
Local cQuery     := ''
Local cFilAtu    := cFilAnt
Local lCpoSr     := GFXCP12117("GW1_SDOC")
Local aDcChave   := {}
Local cTrecho    := .F.
Local nContSeq   := 0
Local cAliasAux  := Nil
Local cAliasGWU  := Nil
Local cAliasGU3  := Nil
Local cAliasGU4  := Nil
Local cAliasGU5  := Nil
Local cAliasGU6  := Nil
Local cErroAux   := ""
Local nQtdVol    := 0
Local lIntTMS    := .F.
Local lTipEntrega := .F.

	Private GFELog117 := GFELog():New("EDI_Ocorrencias_Processamento", "EDI Ocorrências - Processamento", SuperGetMV('MV_GFEEDIL',,'1'))

	If lSchedule
		//Se a rotina está sendo executada via Schedule, busca uma marca
		//e a utiliza no controle do processamento
		cMarcaBrw := GetMark()

		cQuery := "UPDATE " + RetSqlName('GXL')
		cQuery +=  " SET GXL_MARKBR = '"+cMarcaBrw+"'"
		cQuery += " WHERE GXL_EDISIT = '1'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		If (TCSQLExec(cQuery) < 0)
			//Em caso de erro na execução de update
			GFELog117:NewLine()
			GFELog117:Add(Replicate("-", 60))
			GFELog117:Add("Erro ao tentar executar o update de marcação na execução do processamento")
			GFELog117:Add("TCSQLError() " + TCSQLError())
			GFELog117:NewLine()
			GFELog117:EndLog()
			Return
		EndIf
	Else
		ProcRegua(0)
		cMarcaBrw := oBrowse117:Mark()
	EndIf

	DbSelectArea('GXL')
	GXL->( DbSetOrder( 6 ) )
	GXL->(dbSeek(cMarcaBrw))

	Do While !GXL->( Eof() ) .And. GXL->GXL_MARKBR == cMarcaBrw

		cFilAnt := GXL->GXL_FILOCO
		cNrDC := ""
		If !lSchedule
			IncProc()
		EndIf

		// Verifica se o registro está selecionado
		If GXL->GXL_EDISIT == "4" .Or. (!lSchedule .And. !oBrowse117:IsMark(cMarcaBrw))
			GXL->( dbSkip() )
			Loop
		EndIf
		
		If s_GFEA1173
			lRet := ExecBlock("GFEA1173",.f.,.f.)
			if lRet
				GXL->( dbSkip() )
				Loop
			endif
		EndIf

		nTotal++

		lProc := .T.

		GFELog117:NewLine()
		GFELog117:Add(Replicate("-", 60))
		GFELog117:Add("Sequência Importação: " + GXL->GXL_NRIMP)
		GFELog117:NewLine()
		GFELog117:Add("- Buscando Documento de Carga.")
		GFELog117:Add("> Filial.: " + GXL->GXL_FILDC, 1)
		GFELog117:Add("> Emissor: " + GXL->GXL_EMISDC, 1)
		GFELog117:Add("> Série..: " + GXL->GXL_SERDC, 1)
		GFELog117:Add("> Número.: " + GXL->GXL_NRDC, 1)
		

		GW1->(dbSetOrder( If(__lNewKey,19,13) ))
		
		aDcChave := {}
		If __lNewKey // Chave única
				aDcChave := GFEA517SDC(GXL->GXL_NRDC, "", GXL->GXL_EMISDC, PadR(GXL->GXL_SERDC,__nTamSrDC),"")
			EndIf
			
		If Len(aDcChave) > 0
			GW1->(dbGoTo(aDcChave[1,8]))
		EndIf
		
		If Len(aDcChave) > 0 .Or. GW1->(dbSeek(GXL->GXL_EMISDC + PadR(GXL->GXL_SERDC,__nTamSrDC) + GXL->GXL_NRDC)) .Or. GF117AGXP(GXL->GXL_EMISDC,PadR(GXL->GXL_SERDC,__nTamSrDC),GXL->GXL_NRDC)
			cNrDC := GXL->GXL_NRDC
		Else

			GFELog117:Add("** Documento de Carga não encontrado.", 1)
			GFELog117:Add("- Tentativa de busca do número com zeros à esquerda.", 1)
			lBuscaDC := .F.
			cNrDC    := AllTrim(GXL->GXL_NRDC)
			// Regra para buscar o número da nota fiscal no GFE:
			// Inicia a busca a partir do número sem zeros à esquerda e enquanto
			// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
			nICont := Len(cNrDC)
			For nCountDC := nICont To __nTamNrDC
				cNrDC := GFEGetNrDc(GXL->GXL_NRDC, nCountDC) 
				If !Empty(cNrDC)
					dbSelectArea("GW1")
					GW1->(dbSetOrder( If(__lNewKey,19,13) ))
					
					aDcChave := {}
					If __lNewKey // Chave única
							aDcChave := GFEA517SDC(PadR(cNrDC,Len(GW1->GW1_NRDC)), "", GXL->GXL_EMISDC, PadR(GXL->GXL_SERDC,__nTamSrDC),"")
						EndIf
						
					If Len(aDcChave) > 0
						GW1->(dbGoTo(aDcChave[1,8]))
					EndIf
					
					If Len(aDcChave) > 0 .Or. GW1->(dbSeek(GXL->GXL_EMISDC + PadR(GXL->GXL_SERDC,__nTamSrDC) + cNrDC)) .Or. GF117AGXP(GXL->GXL_EMISDC,PadR(GXL->GXL_SERDC,__nTamSrDC),cNrDC)
						lBuscaDC := .T.
						GFELog117:Add("> Número.: " + cNrDC + "[Encontrado]", 1)
						Exit
					Else
						GFELog117:Add("> Número.: " + cNrDC, 1)
					EndIf
				EndIf
			Next

			If !lBuscaDC
				GFELog117:Add("** Não foi possível encontrar o número do Documento de Carga.", 1)
				GFELog117:Save()

				RecLock("GXL",.F.)
					GXL->GXL_EDIMSG := "- " + "Documento de carga inexistente. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC)
					GXL->GXL_EDISIT := "3"
				GXL->(MSUnlock())
				GXL->( dbSkip() )
				Loop
			EndIf
		EndIf

		GFELog117:Save()

		If !Empty(cNrDC)
			GFELog117:Add("> Tipo...: " + GW1->GW1_CDTPDC, 1)
			GFELog117:NewLine()

			cTpDc := AllTrim(GW1->GW1_CDTPDC)

			/* ---------------------------------------------------------------
				Ocorrência de Entrega
				Uma ocorrência (GWD) será sempre criada se MV_REGOCO == 2
				ou se GXL_CODOBS != 3
			--------------------------------------------------------------- */
			cAliasGU5 := GetNextAlias()

			BeginSQL Alias cAliasGU5
				SELECT GU5.R_E_C_N_O_ RECNOGU5
				FROM %Table:GU5% GU5
				WHERE GU5.GU5_FILIAL = %xFilial:GU5%
				AND GU5.GU5_CDTIPO = %Exp:GXL->GXL_CDTIPO%
				AND GU5.GU5_EVENTO = '4'
				AND GU5.%NotDel%	
			EndSQL

			If (cAliasGU5)->(!EoF())
				lTipEntrega := .T.
			Else
				lTipEntrega := .F.
			EndIf

			(cAliasGU5)->(dbCloseArea())

			If s_REGOCO != "2" .And. ((GXL->GXL_CODOBS == 3) .Or. (Empty(GXL->GXL_CODOBS) .And. lTipEntrega))
				nTrechoRec	:= 0
				nPosTrecho	:= 0
				nCountTrEn	:= 0
				cTrecho		:= .F.
				nContSeq	:= 0
				
				//Verificando se o Doc. Carga está embarcado 
				If GW1->GW1_SIT == "4" 

					GFELog117:Add("- Ocorrência de entrega. Buscando trecho com o transportador: " + GXL->GXL_CDTRP)

					// Busca os trechos do documento de carga para atribuir a data e hora de entrega e marcar o documento de carga como entrege
					// A Data e Hora de entrega serão atribuidos nos trechos que:
					// 		a) O transportador do arquivo (GXL->GXL_CDTRP) for igual ao do trecho
					// 		b) O Transportador de faturamento do transportador do arquivo for igual ao do trecho
					//  	c) Também é possível buscar pela raiz do CNPJ, desconsiderando a filial
					// O Documento de Carga será entregue quando?
					//      a) For o último trecho
					GFELog117:AddDebug("*****************************")
					GFELog117:AddDebug("Buscando trechos pagos")
					dbSelectArea("GWU")
					GWU->( dbSetOrder(1) )
					If GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
						While !GWU->( Eof() ) .And. ;
								GWU->GWU_FILIAL == GW1->GW1_FILIAL .And. ;
								GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. ;
								GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. ;
								GWU->GWU_SERDC  == GW1->GW1_SERDC  .And. ;
								GWU->GWU_NRDC   == GW1->GW1_NRDC
							
							// Caso um mesmo transportador atenda a mais de um trecho do documento
							If !Empty(GWU->GWU_DTENT)
								GWU->( dbSkip() )
								Loop
							EndIf
							
							// Soma os trechos que são de entregas ou não pagos
							If GWU->GWU_PAGAR == '1'
								nCountTrEn++
								GFELog117:AddDebug(" # " + cValToChar(nPosTrecho) + " - Seq: " + GWU->GWU_SEQ)
							EndIf

							If nTrechoRec == 0
								If AllTrim(GWU->GWU_CDTRP) == AllTrim(GXL->GXL_CDTRP) // CDEMFT
									nTrechoRec	:= GWU->( RecNo() )
									nPosTrecho	:= nCountTrEn
									GFELog117:AddDebug("    > Trecho para registro da entrega. RecNo: " + cValToChar(nTrechoRec))
									cTrecho		:= .T.
								Else
									cAliasGU3 := GetNextAlias()
									BeginSql Alias cAliasGU3
										SELECT GU3.GU3_CDEMFT,
												GU3.GU3_IDFED
										FROM %Table:GU3% GU3
										WHERE GU3.GU3_FILIAL = %xFilial:GU3%
										AND GU3.GU3_CDEMIT = %Exp:GXL->GXL_CDTRP%
										AND GU3.GU3_CDEMFT = %Exp:GWU->GWU_CDTRP%
										AND GU3.GU3_SIT = '1'
										AND GU3.%Notdel%
									EndSql
									If (cAliasGU3)->(!Eof())
										GFELog117:Add("> Transp. Faturam: " + (cAliasGU3)->GU3_CDEMFT, 1)
										nTrechoRec := GWU->( RecNo() )
										nPosTrecho := nCountTrEn
										GFELog117:AddDebug("    > Trecho para registro da entrega. RecNo: " + cValToChar(nTrechoRec))
									ElseIf s_VLCNPJ == "2"
										cAliasAux := GetNextAlias()
										BeginSql Alias cAliasAux
											SELECT GU3.GU3_IDFED
											FROM %Table:GU3% GU3
											WHERE GU3.GU3_FILIAL = %xFilial:GU3%
											AND GU3.GU3_CDEMIT = %Exp:GWU->GWU_CDTRP%
											AND GU3.GU3_SIT = '1'
											AND GU3.%Notdel%
										EndSql
										If (cAliasAux)->(!Eof()) .And. (SubStr((cAliasAux)->GU3_IDFED,1,8) == SubStr((cAliasGU3)->GU3_IDFED,1,8))
											GFELog117:Add("> Raiz CNPJ - Transportador: " + GXL->GXL_CDTRP, 1)
											nTrechoRec := GWU->( RecNo() )
											nPosTrecho := nCountTrEn
											GFELog117:AddDebug("    > Trecho para registro da entrega. RecNo: " + cValToChar(nTrechoRec))
										EndIf
										(cAliasAux)->(dbCloseArea())
									EndIf
									(cAliasGU3)->(dbCloseArea())
								EndIf
							EndIf

							dbSelectArea("GWU")
							GWU->( dbSkip() )
						EndDo
					EndIf
					GFELog117:AddDebug(" > Total de trechos pagos: " + cValToChar(nCountTrEn))
					GFELog117:AddDebug(" > Posição do trecho a ser entregue: " + cValToChar(nPosTrecho))

					GFELog117:AddDebug("*****************************")

					// Efetiva a alteração do trecho com a Data e Hora de entrega
					// Marca o Documento de Carga como entregue
					If nTrechoRec != 0
						dbSelectArea("GWU")
						dbGoTo(nTrechoRec)
						
						If !GWU->( EoF() )
							GFELog117:Add("> Seq. do Trecho.: " + GWU->GWU_SEQ, 1)
							GFELog117:Add("> Data de Entrega: " + cValToChar(GXL->GXL_DTOCOR), 1)
							GFELog117:Add("> Hora de Entrega: " + GXL->GXL_HROCOR, 1)

							If GXL->GXL_DTOCOR > Date()
								GFELog117:Add("A data de entrega da Ocorrência não pode ser maior que a data atual.")
								RecLock("GXL",.F.)
									GXL->GXL_EDIMSG := "A data de entrega da Ocorrência não pode ser maior que a data atual."
									GXL->GXL_EDISIT := "3"
							GXL->(MsUnLock())

								DbSelectArea("GXL")
								GXL->( dbSkip() )
								Loop
							Else
								//Verifica se a data a ocorrencia é inferior a data da emissão do Doc. Carga
								If GXL->GXL_DTOCOR < GW1->GW1_DTEMIS
									GFELog117:Add("Erro......: " + "A Data da ocorrencia é inferior a data da emissão do Doc. Carga!")
									RecLock("GXL",.F.)
										GXL->GXL_EDIMSG := "A Data da ocorrencia é inferior a data da emissão do Doc. Carga. 1)Verifique se a data informada está correta. 2)Verifique se o Doc. Carga selecionado está correto."
										GXL->GXL_EDISIT := "3"
									GXL->(MsUnLock())
									GXL->( dbSkip() )
									Loop
								EndIf

								If FindFunction("GFEA51ANT")
									If !GFEA51ANT(DToS(GXL->GXL_DTOCOR), Transform(StrTran(GXL->GXL_HROCOR,":",""),"@R 99:99"),@cErroAux)
										GFELog117:Add(cErroAux)
										RecLock("GXL",.F.)
											GXL->GXL_EDIMSG := cErroAux
											GXL->GXL_EDISIT := "3"
										GXL->(MsUnLock())
										GXL->( dbSkip() )
										Loop
									EndIf
								EndIf
							
								If cTrecho
									GWU->( DbSetOrder(1) )
									GWU->( DbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
									
									While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == GW1->GW1_FILIAL .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. ;
											GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. ;
											GWU->GWU_NRDC == GW1->GW1_NRDC
											
											If AllTrim(GWU->GWU_CDTRP) == AllTrim(GXL->GXL_CDTRP)
												nContSeq ++
											EndIf
											
										GWU->( DbSkip() )
									EndDo
									
									If nContSeq != 1
										GWU->( DbSetOrder(1) )
										If GWU->( DbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
											While !GWU->( Eof() )  .And. GWU->GWU_FILIAL == GW1->GW1_FILIAL .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. ;
												GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. ;
												GWU->GWU_NRDC == GW1->GW1_NRDC
												If empty(GWU->GWU_DTENT) 
													Exit
												Else
													GWU->( DbSkip() )
													nTrechoRec := GWU->( RecNo() )
													nPosTrecho := nCountTrEn
													
													RecLock("GWU",.F.)
														GWU->GWU_DTENT := GXL->GXL_DTOCOR
														GWU->GWU_HRENT := Transform(StrTran(GXL->GXL_HROCOR,":",""),"@R 99:99") 
												GWU->(MsUnlock())

												EndIf
												GWU->( DbSkip() )
											EndDo
										EndIf
									Else
										dbSelectArea("GWU")
										dbGoTo(nTrechoRec)
										If !GWU->( EoF() )
											RecLock("GWU",.F.)
												GWU->GWU_DTENT := GXL->GXL_DTOCOR
												GWU->GWU_HRENT := Transform(StrTran(GXL->GXL_HROCOR,":",""),"@R 99:99")
										GWU->(MSUnlock())
										EndIf
									EndIf

									// Verifica se há Documentos de Frete bloqueados relacionados e executa a rotina de auditoria de frete
									cMsgAudit := GFE051AUDIT(GWU->GWU_FILIAL, GWU->GWU_NRDC, .F.)
									If !Empty(cMsgAudit)
										GFELog117:Add("** Auditoria de Frete: " + cMsgAudit)
									EndIf
								EndIf
								
								// Altera o Documento de Carga para Entregue caso seja o último trecho
								If nPosTrecho == nCountTrEn
									GFELog117:Add("# Último trecho. Alterando situação para Entregue para o Documento de Carga", 1)
									
									GFELog117:Add("> Doc. Carga: " + cValToChar(GW1->GW1_NRDC), 1)
									GFELog117:Add("> Serie: " + cValToChar(GW1->GW1_SERDC), 1)
									GFELog117:Add("> Emis. doc: " + cValToChar(GW1->GW1_EMISDC), 1)
									
									RecLock("GW1",.F.)
										GW1->GW1_SIT := "5"
										//Armazena os romaneios afetados
										Aadd(aNrRoms, {GW1->GW1_FILIAL,GW1->GW1_NRROM})
										//Ponto de entrada Harley Davidson
										If s_GFEA1171
											ExecBlock("GFEA1171",.f.,.f.,nil)
										EndIf
										//Fim Ponto de entrada Harley Davidson
										GFELog117:Add("# Situação Alterada para 5-Entregue", 1)	
								GW1->(MSUnlock())
									GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.
								EndIf
								If empty(GWU->GWU_DTENT) 	
									// Atribui a Data e Hora de entrega para o trecho
									RecLock("GWU",.F.)
										GWU->GWU_DTENT := GXL->GXL_DTOCOR
										GWU->GWU_HRENT := Transform(StrTran(GXL->GXL_HROCOR,":",""),"@R 99:99")
									GWU->(MSUnlock())
								EndIf
								
								//Ponto de Entrada Vicunha
								If s_GFEA0513
									GFELog117:Add("# Executando Ponto de Entrada Vicunha - GFEA0513", 1)
									ExecBlock( "GFEA0513",.F.,.F.,{GXL->GXL_DTOCOR,GXL->GXL_HROCOR,2})
									GFELog117:Add("# Executa GFEA0513", 1)
								EndIf
								
								RecLock("GXL",.F.)
									If nPosTrecho == nCountTrEn
										GXL->GXL_EDIMSG := "Ocorrência de entrega para o último trecho, documento de carga marcado como entregue."
									Else
										GXL->GXL_EDIMSG := "Ocorrência de entrega."
									EndIf
									GXL->GXL_EDISIT := "4"
								GXL->(MsUnLock())
							EndIf
							
							nCount++
						Else
							GFELog117:Add("** Erro fatal ao encontrar trecho para entrega", 1)
						EndIf
					Else
						GFELog117:Add("** Trecho não encontrado com transportador " + GXL->GXL_CDTRP)
						GFELog117:Add("   > Filial: " + GW1->GW1_FILIAL + ", Tipo: " + GW1->GW1_CDTPDC + ", Emissor: " + GW1->GW1_EMISDC + ", Série: " + SerieNfId("GW1",2,"GW1_SERDC") + ", Nr: " + GW1->GW1_NRDC)
						
						RecLock("GXL",.F.)
							GXL->GXL_EDIMSG := "Não foi encontrado o trecho do documento de carga com o código do transportador: " + GXL->GXL_CDTRP
							GXL->GXL_EDISIT := "3"
						GXL->(MsUnLock())
					EndIf
					
					GFELog117:Save()
					
					dbSelectArea("GXL")
					GXL->( dbSkip() )
					Loop
				Else
					If GW1->GW1_SIT == "5"
						GFELog117:Add("** " + "Documento de carga já foi entregue. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC))
						RecLock("GXL",.F.)
							GXL->GXL_EDIMSG := "- " + "Documento de carga já foi entregue. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC)
							GXL->GXL_EDISIT := "3"
						GXL->(MSUnlock())
						GXL->( dbSkip() )
						Loop
					ElseIf GW1->GW1_SIT == "6"
						GFELog117:Add("** " + "Documento de carga possui devolução total. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC))
						RecLock("GXL",.F.)
							GXL->GXL_EDIMSG := "- " + "Documento de carga possui devolução total. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC)
							GXL->GXL_EDISIT := "3"
						GXL->(MSUnlock())
						GXL->( dbSkip() )
						Loop
					Else
						GFELog117:Add("** " + "Documento de carga deve estar com a situação 4=Embarcado. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC))
						RecLock("GXL",.F.)
							GXL->GXL_EDIMSG := "- " + "Documento de carga deve estar com a situação 4=Embarcado. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC)
							GXL->GXL_EDISIT := "3"
						GXL->(MSUnlock())
						GXL->( dbSkip() )
						Loop
					EndIf
				EndIf
			EndIf
		Else
			GFELog117:Add("** " + "Documento de carga inexistente. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC))

			RecLock("GXL",.F.)
				GXL->GXL_EDIMSG := "- " + "Documento de carga inexistente. Filial: " + ALLTRIM(GXL->GXL_FILDC) + ", Serie: " + ALLTRIM(GXL->GXL_SERDC) + ", Número: " + ALLTRIM(GXL->GXL_NRDC)
				GXL->GXL_EDISIT := "3"
			GXL->(MSUnlock())
			GXL->( dbSkip() )
			Loop
		EndIf

		GFELog117:Add("- Criando a ocorrência.")

		oModel    := FWLoadModel("GFEA032")
		oModelGWD := oModel:GetModel("GFEA032_GWD")
		oModelGWL := oModel:GetModel("GFEA032_GWL")
		oModel:SetOperation( 3 )
		
		oModel:Activate()
			
		//Atribui valor através do SetValue da tabela GWD
		//Atribui valor através do SetValue da tabela GWL
		oModelGWL:SetValue("GWL_FILIAL", AllTrim(GXL->GXL_FILOCO))
		oModelGWL:SetValue("GWL_FILDC" , AllTrim(GXL->GXL_FILDC))
		oModelGWL:SetValue("GWL_NRDC"  , AllTrim(cNrDC))
		oModelGWL:SetValue("GWL_EMITDC", AllTrim(GXL->GXL_EMISDC))
		oModelGWL:SetValue("GWL_SERDC" , AllTrim(GW1->GW1_SERDC))
		oModelGWL:SetValue("GWL_TPDC"  , cTpDc)
		
		cAliasGWU := GetNextAlias()
		BeginSql Alias cAliasGWU
			SELECT GWU.GWU_SEQ
			FROM %Table:GWU% GWU
			WHERE GWU.GWU_FILIAL = %Exp:GXL->GXL_FILDC%
			AND GWU.GWU_CDTPDC = %Exp:cTpDc%
			AND GWU.GWU_EMISDC = %Exp:AllTrim(GXL->GXL_EMISDC)%
			AND GWU.GWU_SERDC = %Exp:AllTrim(GW1->GW1_SERDC)%
			AND GWU.GWU_NRDC = %Exp:AllTrim(cNrDC)%
			AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(GXL->GXL_CDTRP)%)
			AND GWU.%NotDel%
			ORDER BY GWU.GWU_SEQ DESC
		EndSql
		If (cAliasGWU)->(!Eof())
			oModelGWL:SetValue("GWL_SEQ", (cAliasGWU)->(GWU_SEQ))
		EndIf
		(cAliasGWU)->(dbCloseArea())
		
		If lCpoSr
			oModelGWL:SetValue("GWL_SDOCDC", GW1->GW1_SDOC)
		EndIf
		
		oModelGWD:SetValue("GWD_CDTRP" , GXL->GXL_CDTRP)
		oModelGWD:SetValue("GWD_DTOCOR", GXL->GXL_DTOCOR)
		oModelGWD:SetValue("GWD_HROCOR", AllTrim(GXL->GXL_HROCOR))
		oModelGWD:SetValue("GWD_ORIGEM", "1") //Origem EDI

		nQtdVol := GW1->GW1_QTVOL
		If GFXCP12130("GWD_QTDVOL") .And. GFXCP12130("GXL_QTDVOL") .And. QtdComp(GXL->GXL_QTDVOL) > QtdComp(0)
			nQtdVol := GXL->GXL_QTDVOL
		EndIf
		oModelGWD:SetValue("GWD_QTDVOL", nQtdVol)

		If GFXCP12121("GWD_PESO")
			oModelGWD:SetValue("GWD_PESO", GXL->GXL_PESO)
		EndIf

		If GFXCP12121("GWD_CDREC")
			oModelGWD:SetValue("GWD_CDREC", GXL->GXL_CDREC)
		EndIf
		//---------------------------------------------------
		//Processo: Procurar primeira incidência na tabela de tp-motivo onde o código do motivo da GXL for igual..
		//Se sim: Atribuir o código do tipo para a tabela da tabela de tp-motivo para o campo CDTIPO da GWD
		//senao: Procurar na tabela de tipos o primeiro registro que o tipo da ocorrência seja igual a '1'
		//Adiciona o CDTIPO da tabela de tipo no CDTIPO da GWD
		//Depois procura o primeiro motivo pelo tipo, na tabela de tipo-motivo e adiciona no motivo da GWD.
		//o DS_SOLUCAO E DS_PROBLEMA são iguais a descrição!
		//---------------------------------------------------
		cTipo   := ""
		cCdMot  := ""
		cDsOcor := ""
		If !Empty(GXL->GXL_CDTIPO)
			cTipo := GXL->GXL_CDTIPO
			cAliasGU5 := GetNextAlias()
			BeginSql Alias cAliasGU5
				SELECT GU5.GU5_DESC
				FROM %Table:GU5% GU5
				WHERE GU5.GU5_FILIAL = %xFilial:GU5%
				AND GU5.GU5_CDTIPO = %Exp:cTipo%
				AND GU5.%NotDel%
			EndSql
			If (cAliasGU5)->(!Eof())
				cDsTipo := (cAliasGU5)->GU5_DESC
			EndIf
			(cAliasGU5)->(dbCloseArea())
		EndIf
		If !Empty(GXL->GXL_CDMOT)
			cCdMot := GXL->GXL_CDMOT
			cAliasGU6 := GetNextAlias()
			BeginSql Alias cAliasGU6
				SELECT GU6.GU6_DESC
				FROM %Table:GU6% GU6
				WHERE GU6.GU6_FILIAL = %xFilial:GU6%
				AND GU6.GU6_CDMOT = %Exp:cCdMot%
				AND GU6.%NotDel%
			EndSql
			If (cAliasGU6)->(!Eof())
				cDsOcor := (cAliasGU6)->GU6_DESC
			EndIf
			(cAliasGU6)->(dbCloseArea())
		EndIf
		
		If Empty(cTipo)
			cAliasGU4 := GetNextAlias()
			BeginSql Alias cAliasGU4
				SELECT GU4.GU4_CDTIPO
				FROM %Table:GU4% GU4
				WHERE GU4.GU4_FILIAL = %xFilial:GU4%
				AND (GU4.GU4_CDMOT = %Exp:GXL->GXL_CODOCO%
					OR GU4.GU4_CDMOT = %Exp:StrZero(Val(GXL->GXL_CODOCO),6)% )
				AND GU4.%NotDel%
			EndSql
			If (cAliasGU4)->(!Eof())
				cTipo := (cAliasGU4)->GU4_CDTIPO
			EndIf
			(cAliasGU4)->(dbCloseArea())
		EndIf
		/*--------------PROCESSO PRA PREENCHIMENTO DO CAMPO DSOCOR
		Processo: Se o campo da observação da tabel GXL for vazio:
		Senao: o campo DSOCOR recebe o campo da observação.
		Se for vazio: procurar primeira incidência na tabela de motivos de acordo com o código do motivo da GXL.
		Se achar: Atribuir a DSOCOR
		Senão achar: fazer um case com o status (observação) da GXL se for '1' DSOCOR = Devolução/recusa total,
		'2' DSOCOR = Devolução/recusa parcial, '3' DSOCOR = Aceite/entrega por acordo
		---------------------------------------------------*/
		If Empty(cCdMot)
			cCdMot    := StrZero(Val(GXL->GXL_CODOCO),6)
			cDsOcor   := ''
			cAliasGU6 := GetNextAlias()
			BeginSql Alias cAliasGU6
				SELECT GU6.GU6_DESC
				FROM %Table:GU6% GU6
				WHERE GU6.GU6_FILIAL = %xFilial:GU6%
				AND (GU6.GU6_CDMOT = %Exp:GXL->GXL_CODOCO%
					OR GU6.GU6_CDMOT = %Exp:StrZero(Val(GXL->GXL_CODOCO),6)% )
				AND GU6.%NotDel%
			EndSql
			If (cAliasGU6)->(!Eof())
				cCdMot  := GU6->GU6_CDMOT
				cDsOcor := GU6->GU6_DESC
			EndIf
			(cAliasGU6)->(dbCloseArea())
		EndIf
		If Empty(GXL->GXL_OBS)
			If Empty(cDsOcor)
				Do Case
					Case GXL->GXL_CODOBS == 1
						cDsOcor := STR0010 //"Devolução/recusa total"
					Case GXL->GXL_CODOBS == 2
						cDsOcor := STR0011 //"Devolução/recusa parcial"
					Case GXL->GXL_CODOBS == 3
						cDsOcor := STR0012 //"Aceite/entrega por acordo"
					Case GXL->GXL_CODOBS == 4
						cDsOcor := "Devolução/Recusa total com NF devolução emitida pelo destinatário"
					Case GXL->GXL_CODOBS == 5
						cDsOcor := "Devolução/Recusa parcial com NF devolução emitida pelo destinatário"
					OtherWise
						cDsOcor := cDsTipo
				Endcase
			EndIf
		Else
			cDsOcor := GXL->GXL_OBS
		EndIf

		GFELog117:Add("> Desc Ocorrência: " + cDsOcor, 1)
		GFELog117:Add("> Cod Tipo.......: " + cTipo, 1)
		GFELog117:Add("> Cod Motivo.....: " + cCdMot, 1)
		GFELog117:Save()

		oModelGWD:SetValue("GWD_DSOCOR",AllTrim(cDsOcor))
		oModelGWD:SetValue("GWD_DSPROB",AllTrim(cDsOcor))
		oModelGWD:SetValue("GWD_DSSOLU",AllTrim(cDsOcor))
		oModelGWD:SetValue("GWD_CDTIPO",AllTrim(cTipo))
		oModelGWD:SetValue("GWD_CDMOT" ,AllTrim(cCdMot))
		If GFXCP12130("GXL_PRESTS") .And. !Empty(Alltrim(GXL->GXL_PRESTS))
			oModelGWD:SetValue("GWD_PRESTS" ,GXL->GXL_PRESTS)
		EndIf
		If GFXCP12130("GXL_NMCONT")
			oModelGWD:SetValue("GWD_NMCONT" ,GXL->GXL_NMCONT)
		EndIf
		If GFXCP12130("GXL_VALIND") .And. GXL->GXL_VALIND > 0
			oModelGWD:SetValue("GWD_VALIND" ,GXL->GXL_VALIND)
		EndIf
		lIntTMS := .F.
		If !Empty(Alltrim(cTipo))
			cAliasGU5 := GetNextAlias()
			BeginSql Alias cAliasGU5
				SELECT GU5.GU5_EVENTO,
						GU5.GU5_TPCALC,
						GU5.GU5_INTTMS
				FROM %Table:GU5% GU5
				WHERE GU5.GU5_FILIAL = %xFilial:GU5%
				AND GU5.GU5_CDTIPO = %Exp:AllTrim(cTipo)%
				AND GU5.%NotDel%
			EndSql
			If (cAliasGU5)->(!Eof())
				// Atribuir o link de entrega
				If (cAliasGU5)->GU5_EVENTO == '4'
					If GFXCP12130("GWD_URLENT") .And. GFXCP12130("GXL_EVENTR")
						oModelGWD:SetValue("GWD_URLENT", Alltrim(GXL->GXL_EVENTR))
					EndIf
				EndIf
				// Atribui a quantidade de serviços
				If (cAliasGU5)->GU5_TPCALC == '3'
					nQtdServ := 1
					If GFXCP12130("GXL_QTPERN") .And. !Empty(GXL->GXL_QTPERN)
						nQtdServ := GXL->GXL_QTPERN
					EndIf
					oModelGWD:SetValue("GWD_QTPERN", nQtdServ)
				EndIf
				lIntTMS := ((cAliasGU5)->GU5_INTTMS == '2')
			EndIf
			(cAliasGU5)->(dbCloseArea())
		EndIf

		//Verifica se usa a integração tms
		If s_TMS2GFE .And. lIntTMS

			dbSelectArea("GXL")
			aAreaGXL := GXL->(GetArea())

			dbSelectArea("GWL")
			aAreaGWL := GWL->(GetArea())
			
			//dbSelectArea("GWE")
			GWE->(dbSetOrder(If(__lNewKey,,1))) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
			
			cFilGXL := GXL->GXL_FILDC
			cChaveGXL := PadR(cFilGXL,TamSx3("GWE_FILIAL")[1]);
							+PadR(cTpDc,TamSx3("GWE_CDTPDC")[1]);
							+PadR(GXL->GXL_EMISDC,TamSx3("GWE_EMISDC")[1]);
							+PadR(GXL->GXL_SERDC,__nTamSrDC);
							+PadR(cNrDC,TamSx3("GWE_NRDC")[1])
						
			If GWE->(dbSeek(cChaveGXL))
				cDocTrp := GWE->GWE_FILDT + GWE->GWE_NRDT + GWE->GWE_SERDT
				cTipo   := GXL->GXL_CDTIPO
				cDtOcor := GXL->GXL_DTOCOR
				cHrOcor := GXL->GXL_HROCOR
				cFilOco := GXL->GXL_FILOCO
				aDocTrp := {}
				nDocTrp := 0
				Do While !GWE->(Eof()) .And. GXL->GXL_FILDC + cDocTrp == GWE->GWE_FILIAL + GWE->GWE_FILDT + GWE->GWE_NRDT + GWE->GWE_SERDT
					
					GXL->(dbSetOrder(5))
					GWL->(dbSetOrder(2))
					nDocTrp++
					If Len(aDocTrp) +1 != nDocTrp // Se pelos testes abaixo um documento não foi adicionado, nao serão adicionado os relacionados na ocorrencia atual
						Exit
					EndIf
					//Busca por ocorrências relacionadas ou registros de importacao EDI relacionados
					//Só é possível adicionar na mesma ocorrencia se não existirem outras ocorrencias ou registros
					//com o mesmo tipo, data e hora
					If GXL->GXL_FILDC + GWE->GWE_CDTPDC + GWE->GWE_EMISDC + GWE->GWE_SERDC + GWE->GWE_NRDC != GXL->GXL_FILDC+PadR(cTpDc,TamSx3("GWE_CDTPDC")[1])+GXL->GXL_EMISDC+GXL->GXL_SERDC+PadR(cNrDC,TamSx3("GWE_NRDC")[1])
						If GWL->(dbSeek(GWE->(GWE_FILIAL+GWE_NRDC+GWE_FILIAL+GWE_EMISDC+GWE_SERDC/*+GWE_CDTPDC*/)))
							//dbSelectArea("GWD")
							GWD->(dbSetOrder(1))
							GWD->(dbSeek(GWL->(GWL_FILIAL + GWL_NROCO)))
							
							If cTipo != GWD->GWD_CDTIPO
								GWE->(dbSkip())
								Loop
							EndIf
							
							If cDtOcor != GWD->GWD_DTOCOR
								GWE->(dbSkip())
								Loop
							EndIf
							
							If cHrOcor != GWD->GWD_HROCOR
								GWE->(dbSkip())
								Loop
							EndIf
						EndIf
						nGXL := -1
						
						If GXL->(dbSeek(cFilGXL+GWE->GWE_FILIAL+GWE->GWE_EMISDC+PadR(SerieNfId("GWE",2,"GWE_SERDC"), TamSX3("GXL_SERDC")[1])+GWE->GWE_NRDC))
							GWE->(dbSkip())
							Loop
						EndIf
						
						RestArea(aAreaGWL)
						
						GW1->(dbSeek(GWE->GWE_FILIAL+GWE->GWE_CDTPDC+GWE->GWE_EMISDC+GWE->GWE_SERDC+GWE->GWE_NRDC))
						aAdd(aDocTrp,{AllTrim(cFilOco),;
										AllTrim(GWE->GWE_FILIAL),;
										AllTrim(GWE->GWE_NRDC),;
										AllTrim(GWE->GWE_EMISDC),;
										AllTrim(GWE->GWE_SERDC),;
										AllTrim(GWE->GWE_CDTPDC),;
										GW1->GW1_QTVOL,;
										If (lCpoSr, GW1->GW1_SDOC, "")})

					EndIf
					RestArea(aAreaGWL)
					RestArea(aAreaGXL)
					GWE->(dbSkip())
				EndDo
				
				// Adiciona os documentos de carga na ocorrencia
				If Len(aDocTrp) == nDocTrp
					For nDocTrp := 1 To Len(aDocTrp)
						If oModelGWL:Length() > 0
							oModelGWL:AddLine(.T.)
						EndIf
						oModelGWL:GoLine(oModelGWL:Length())
						oModelGWL:SetValue("GWL_FILIAL", aDocTrp[nDocTrp][1])
						oModelGWL:SetValue("GWL_FILDC" , aDocTrp[nDocTrp][2])
						oModelGWL:SetValue("GWL_NRDC"  , aDocTrp[nDocTrp][3])
						oModelGWL:SetValue("GWL_EMITDC", aDocTrp[nDocTrp][4])
						oModelGWL:SetValue("GWL_SERDC" , aDocTrp[nDocTrp][5])
						oModelGWL:SetValue("GWL_TPDC"  , aDocTrp[nDocTrp][6])
						
						cAliasGWU := GetNextAlias()
						BeginSql Alias cAliasGWU
							SELECT GWU.GWU_SEQ
							FROM %Table:GWU% GWU
							WHERE GWU.GWU_FILIAL = %Exp:aDocTrp[nDocTrp][2]%
							AND GWU.GWU_CDTPDC = %Exp:aDocTrp[nDocTrp][6]%
							AND GWU.GWU_EMISDC = %Exp:aDocTrp[nDocTrp][4]%
							AND GWU.GWU_SERDC = %Exp:aDocTrp[nDocTrp][5]%
							AND GWU.GWU_NRDC = %Exp:aDocTrp[nDocTrp][3]%
							AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(GXL->GXL_CDTRP)%)
							AND GWU.%NotDel%
							ORDER BY GWU.GWU_SEQ DESC
						EndSql
						If (cAliasGWU)->(!Eof())
							oModelGWL:SetValue("GWL_SEQ", (cAliasGWU)->(GWU_SEQ))
						EndIf
						(cAliasGWU)->(dbCloseArea())
						
						If lCpoSr
							oModelGWL:SetValue("GWL_SDOCDC",aDocTrp[nDocTrp][8])
						EndIf
						
						oModelGWD:SetValue("GWD_QTDVOL", aDocTrp[nDocTrp][7] + oModelGWD:GetValue("GWD_QTDVOL") )
						
						If !(lRet:= oModelGWL:VldLineData())
							ErroModel(oModel)
							Exit
						EndIf
					Next nDocTrp
				EndIf
				
			EndIf
			If (lRet := GravaModel(oModel))
				nCount++
			Else
				ErroModel(oModel)
			EndIf
			oModel:DeActivate()
			
		Else // sem integração tms 
			
			If (lRet := GravaModel(oModel))
				nCount++
			Else
				ErroModel(oModel)
			EndIf
			oModel:DeActivate()
		EndIf
		oModel:Destroy()
		GFELog117:Save()
		GXL->( dbSkip() )
	EndDo

	If Len(aNrRoms) > 0
		A117AtuSitRom(aNrRoms)
	EndIf

	cFilAnt := cFilAtu
	GFELog117:NewLine()

	If nCount == 0 .And. lProc
		GFELog117:Add("Nenhum registro processado com sucesso.")
		GFELog117:Add("Total de registros processados: " + cValToChar(nTotal))
		If !lSchedule
			MessageBox ("Nenhum registro processado com sucesso. Total de registros processados: " + cValToChar(nTotal) + CRLF + "Verifique o campo 'Mensagens' dos registros para a descrição dos erros ocorridos.", "Processamento", 48)
		EndIf
	ElseIf nCount == 0 .And. !lProc
		GFELog117:Add("** " + STR0015)
		If !lSchedule
			MessageBox (STR0015, "Processamento", 48)	// "Não há registros para processar."
		EndIf
	ElseIf nCount > 0 .And. lProc
		GFELog117:Add(STR0013)
		GFELog117:Add(STR0016 + AllTrim(Str(nCount)) + STR0017 + AllTrim(Str(nTotal)) + ".")
		If !lSchedule
			MsgInfo(STR0013 + CRLF + STR0016 + AllTrim(Str(nCount)) + STR0017 + AllTrim(Str(nTotal)) + "." + CRLF + ;
					If(nCount != nTotal, "Verifique o campo observação dos registros para a descrição dos erros ocorridos.","") ;
					,"") //"Processo concluído. " ### "Processada(s) " ### " ocorrências(s) do total de "
		EndIf
	EndIf

	GFELog117:EndLog()

	RestArea( aAreaSM0 )
	RestArea( aArea )
Return


Function A117AtuSitRom(aNrRoms)
	Local nI
	Local cNumRom 	:= "ZZZZZZZZ"
	Local bAtualiza 	:= .T.
	Local aAreaGW1 	:= GW1->(GetArea())
	
	
	For nI := 1 to len( aNrRoms )
		If cNumRom == aNrRoms[nI][2]
			loop
		EndIf

		dbSelectArea("GW1")
		GW1->( dbSetOrder(9) )
		GW1->( DbSeek(aNrRoms[nI][1]+aNrRoms[nI][2]) )
		While !Eof() .And. GW1->GW1_FILIAL == aNrRoms[nI][1];
						.And. GW1->GW1_NRROM == aNrRoms[nI][2]

			If GW1->GW1_SIT != "5" .And. GW1->GW1_SIT != "6"
				bAtualiza := .F.
				Exit
			EndIf

			GW1->( DbSkip() )
		EndDo

		If bAtualiza
			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			GWN->( dbSeek(aNrRoms[nI][1]+aNrRoms[nI][2]) )
			RecLock("GWN",.F.)
				GWN->GWN_SIT := "4"
			GWN->(MSUnlock())

		EndIf

		cNumRom := aNrRoms[nI][2]
		bAtualiza := .T.
	Next
	RestArea(aAreaGW1)
Return
//-------------------------------------
// When de dicionário. Usado no Pergunte. Campo Filial Ocorrência MV_PAR03
//-------------------------------------
Function GFEA117VLF(cFil)

	Local lRet := .F.
	Local aAreaSM0 := SM0->( GetArea() )

	dbSelectArea("SM0")
	SM0->( dbGoTop() )

	While !SM0->( Eof() )

		If !SM0->( Deleted() ) .And. AllTrim(cFil) == AllTrim(SM0->M0_CODFIL)
			lRet := .T.
			Exit
		EndIf

		dbSelectArea("SM0")
		SM0->( dbSkip() )
	EndDo

	RestArea(aAreaSM0)

	If !lRet
		Help( ,, 'HELP',, STR0004, 1, 0)
	EndIf

Return lRet

Static Function ErroModel(oModel)
	//  A estrutura do vetor aErro com erro é:
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

	GFELog117:Add(" ** " + STR0002+aErro[4]+STR0003+aErro[6])

	RecLock("GXL",.F.)
		GXL->GXL_EDIMSG := STR0002+aErro[4]+STR0003+aErro[6] //"Ocorreu um erro no campo: "###". Motivo: "
		GXL->GXL_EDISIT := "3"
	GXL->(MSUnlock())
	
Return

Static Function GravaModel(oModel)
	Local lRet := .F.
	
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
		RecLock("GXL",.F.)
			GXL->GXL_EDIMSG := ""
			GXL->GXL_EDISIT := "4"
		GXL->(MSUnlock())
	EndIf
Return lRet

Function GF117AGXP(cEmisDc,cSerDC,cNrDc)
	Local lAchou := .F.
	Local cAliasGXP
	If FindFunction("GF115GXPDC") == .F.
		Return lAchou
	EndIf
	cAliasGXP := GF115GXPDC(cEmisDC, cSerDC, cNrDc)
	If !(cAliasGXP)->(Eof()) .And. !Empty((cAliasGXP)->R_E_C_N_O_)
		GW1->(dbGoTo((cAliasGXP)->R_E_C_N_O_))
		lAchou := .T.
	EndIf
	(cAliasGXP)->(dbCloseArea())
Return lAchou
