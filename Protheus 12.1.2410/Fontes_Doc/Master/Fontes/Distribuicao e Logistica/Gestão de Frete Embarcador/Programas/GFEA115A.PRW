#INCLUDE "GFEA115A.ch"
#INCLUDE "TOTVS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115IMP
EDI - Importação de Conhecimentos

GXG - Espelho da GW3
GXH - Espelho da GW4

@author Israel A. Possoli
@since 27/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static __nTamNrDC := TamSX3("GW1_NRDC" )[1]
Static __nTamSrDC := TamSx3(SerieNfId("GW1",3,"GW1_SERDC"))[1]
Static __lCpoSr   := TamSX3("GW1_SERDC")[1] == 14
Static __lCpoSDoc := Len(TamSX3("GW4_SDOCDC")) > 0
Static __cAtivo   := "1"	// Emitente com Situação Ativo

Function GFEA115IMP()
	Private tTabCTRC			// Tabela temporária do conhecimento
	Private tTabNF				// Tabela temporárias das notas fiscais
	Private aCamposCTRC 	:= {}	// Campos da tabela intermediária de CTRC
	Private aCamposNF 	:= {}	// Campos da tabela intermediária de NF
	Private lVerPerg	:= .T.
	Private oProcess := Nil
	
	If IsBlind()
		CriaTab()
		Importacao()
		
		GFEDelTab(tTabCTRC)
		GFEDelTab(tTabNF)
		
		If !Empty(MV_PAR06) .or. MV_PAR06 != "" 
			If MV_PAR06 == 2
				GFEA115PRO()
			EndIf
		EndIf
	Else
		lVerPerg := .T.

		// Início Ponto de Entrada Procomp
	 	If ExistBlock("GFEXPERG")
		    lVerPerg := ExecBlock("GFEXPERG",.f.,.f.,{})
	 	EndIf
		// Fim Ponto de Entrada Procomp
	
		If Pergunte("GFEA115",lVerPerg) .Or. !lVerPerg
			CriaTab()		
			oProcess  := MsNewProcess():New( { || Importacao() }, "Importando arquivos" )
			oProcess:Activate()	
			FreeObj(oProcess) 
			GFEDelTab(tTabCTRC)
			GFEDelTab(tTabNF)
			
			If !Empty(MV_PAR06) .or. MV_PAR06 != "" 
				If MV_PAR06 == 2
					GFEA115PRO()
				EndIf
			EndIf
		Else
			Return .F.
		Endif
	
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115PRO
Processamento dos Conhecimentos Importados

@author Israel A. Possoli
@since 03/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA115PRO(cOrigem)

Default cOrigem := '1'

If IsBlind() //Chamada via Schedule
	Processamento(cOrigem)
Else
	Processa({|| Processamento(cOrigem)},"Processando Conhecimentos", "")
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTab
Criação das tabelas temporárias

@author Israel A. Possoli
@since 10/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab()

	aCamposCTRC := {{"GXG_FILIAL", "C", TamSX3("GW3_FILIAL")[1]	, 0},;
					{"GXG_NRIMP" , "C", 16	, 0},;
					{"GXG_ACAO"  , "C", 1	, 0},;
					{"GXG_EDISIT", "C", 1	, 0},;
					{"GXG_EDINRL", "N", 5	, 0},;
					{"GXG_EDILIN", "M", 10	, 0},;
	 				{"GXG_EDIARQ", "C", 200	, 0},;
					{"GXG_EDIMSG", "M", 10	, 0},;
					{"GXG_CDESP" , "C", 5	, 0},;
					{"GXG_FILDOC", "C", TamSX3("GW3_FILIAL")[1], 0},;
					{"GXG_EMISDF", "C", 14	, 0},;
					{"GXG_SERDF" , "C", TamSx3("GXG_SERDF")[1], 0},;
					{"GXG_NRDF"  , "C", 16	, 0},;
					{"GXG_DTEMIS", "D", 8	, 0},;
					{"GXG_CDREM" , "C", 14	, 0},;
					{"GXG_CDDEST", "C", 14	, 0},;
					{"GXG_TPDF"  , "C", 1	, 0},;
					{"GXG_DTENT" , "D", 8	, 0},;
					{"GXG_CDCONS", "C", 14	, 0},;
					{"GXG_CFOP"  , "C", 4	, 0},;
					{"GXG_PCIMP" , "N", 5	, 2},;
					{"GXG_TRBIMP", "C", 1	, 0},;
					{"GXG_PESOC" , "N", 13	, 5},;
					{"GXG_PESOR" , "N", 13	, 5},;
					{"GXG_FRPESO", "N", 16	, 5},;
					{"GXG_FRVAL" , "N", 13	, 5},;
					{"GXG_VLIMP" , "N", 12	, 2},;
					{"GXG_PEDAG" , "N", 12	, 2},;
					{"GXG_TAXAS" , "N", 12	, 2},;
					{"GXG_VLDF"  , "N", 12	, 2},;
					{"GXG_BASIMP", "N", 12	, 2},;
					{"GXG_ORISER", "C", 5	, 0},;
					{"GXG_ORINR" , "C", 16	, 0},;
					{"GXG_CTE"	 , "C", 44	, 0},;
					{"GXG_TPCTE" , "C", 1	, 0},;
					{"GXG_IMPRET", "N", 9	, 2},;
					{"GXG_PCRET" , "N", 6	, 2},;
					{"GXG_SUBTRB", "C", 1	, 0},;
					{"GXG_TPIMP" , "C", 1	, 0};
				   }
					If GFXCP12117("GXG_CDTPSE")
						aADD(aCamposCTRC,{"GXG_CDTPSE", "C", TamSx3("GXG_CDTPSE")[1], 0})
					EndIf
					
	// Início Ponto de Entrada Procomp
 	If ExistBlock("GFEA1156")   
	    aCamposCTRC := ExecBlock("GFEA1156",.f.,.f.,{aCamposCTRC})
 	EndIf
	// Fim Ponto de Entrada Procomp					

	tTabCTRC := GFECriaTab({aCamposCTRC,{"GXG_FILIAL+GXG_NRIMP"}})

	aCamposNF := {{"GXH_FILIAL", "C", TamSX3("GW3_FILIAL")[1],  0},;
				 {"GXH_NRIMP"  , "C", 16, 0},;
				 {"GXH_SEQ"    , "C", 5,  0},;
				 {"GXH_FILDC"  , "C", TamSX3("GW1_FILIAL")[1], 0},;
				 {"GXH_EMISDC" , "C", 14, 0},;
				 {"GXH_SERDC"  , "C", TamSx3("GXH_SERDC")[1],  0},;
				 {"GXH_NRDC"   , "C", TamSX3("GW1_NRDC")[1], 0},;
				 {"GXH_TPDC"   , "C", 5,  0},;
				 {"GXH_CNPJEM" , "C", 14,  0};
				 }

	tTabNF := GFECriaTab({aCamposNF,{"GXH_FILIAL+GXH_NRIMP+GXH_SEQ"}})
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Importacao
EDI - Importação de Documento de Frete
Uso interno

@author Israel A. Possoli
@since 12/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importacao()
	Local aDirImpor   	:= {}		// Array com os arquivos do diretorio
	Local nError				// Erro ocorrido
	Local nCountFiles 	:= 0  	// Contador dos arquivos do diretorio
	Local lArquivoValido
	Local cLayoutVer  	:= "" 	// Versão do Layout 3 ou 5
	Local cFormatDt
	Local cFormatTm
	Local cNewNomeArq		:= ""
	Local cDiretorio		:= AllTrim(MV_PAR03)
	Local cDirOk			:= AllTrim(MV_PAR04)
	Local cDirErro		:= AllTrim(MV_PAR05)
	Local s_ESPDF1   := SuperGetMv("MV_ESPDF1",,"")
	Local s_ESPDF2   := SuperGetMv("MV_ESPDF2",,"")
	Local s_ESPDF3_2 := SuperGetMv("MV_ESPDF3",,"")	
	Local cBuffer	:= ""
	Private lTranspVld	:= .F.
	Private lCNPJTra 		:= .T.
	Private GFEResult 	:= GFEViewProc():New()
	Private cNomeArq
	Private nNRIMP		:= 0
	Private nCountImpor 	:= 0  	// Contador de arquivos importados
	Private cMsgPreVal	:= ""	// Armazena as mensagens de pré-validações para o Campo Observação (Importação)
	Private GFELog115   	:= GFELog():New("EDI_Conemb_Importacao", "EDI Conemb - Importação", IIF(!Empty(SuperGetMV('MV_GFEEDIL',,'1')),SuperGetMV('MV_GFEEDIL',,'1') , NIL) )
	Private GFEFile     	:= GFEXFILE():New()


	GFELog115:Add("Parâmetros")
	GFELog115:Add(Replicate("-", 20))
	GFELog115:Add("Transportador De..: " + MV_PAR01)
	GFELog115:Add("Transportador Até.: " + MV_PAR02)
	GFELog115:Add("Dir. Importação...: " + cDiretorio)
	GFELog115:Add("Dir. Backup OK....: " + cDirOk)
	GFELog115:Add("Dir. Backup Erros.: " + cDirErro)
	GFELog115:NewLine()

	GFELog115:Add("Espécie CTR.......: " + If(!Empty(s_ESPDF1), s_ESPDF1, " < Parâmetro em branco >" ))
	GFELog115:Add("Espécie NFST......: " + If(!Empty(s_ESPDF2), s_ESPDF2, " < Parâmetro em branco >" ))
	GFELog115:Add("Espécie CTR CT-e..: " + If(!Empty(s_ESPDF3_2), s_ESPDF3_2, " < Parâmetro em branco >" ))

	// Validação do diretório de importação
	If Empty(cDiretorio)
		GFELog115:Add("** " + "Diretório de importação deve ser informado.")
		GFELog115:EndLog()
		MsgAlert("Diretório de importação deve ser informado.", "Aviso")
		Return
	EndIf

	aDirImpor := DIRECTORY(cDiretorio + "\*.TXT" )

	nError := FError()

	// Verifica se existe arquivos no diretório informado
	If Len(aDirImpor) == 0
		GFELog115:Add("** " + "Nenhum arquivo encontrado no diretório " + cDiretorio)
		GFELog115:EndLog()
		MsgAlert("Nenhum arquivo encontrado no diretório " + cDiretorio, STR0005)
		Return
	EndIf

	// Data e Hora
	cFormatDt := stuff(DTOC(Date()), 3, 1, '')
	cFormatDt := stuff(cFormatDt, 5, 1, '')

	cFormatTm := stuff(Time(), 3, 1, '')
	cFormatTm := stuff(cFormatTm, 5, 1, '')

	GFELog115:NewLine()
	GFELog115:Add("- Início da importação")
	GFELog115:NewLine()
	GFELog115:Save()

	If !IsBlind()
		oProcess:setRegua1(Len(aDirImpor))
	EndIf

	For nCountFiles := 1 To Len(aDirImpor)
		lArquivoValido := .T.
		cNomeArq  	:= aDirImpor[nCountFiles][1]
		If !IsBlind()
			oProcess:incRegua1("Processando arquivo " + AllTrim(Str(nCountFiles)) + " de " + AllTrim(Str(Len(aDirImpor))) )
		EndIf

		GFELog115:Add(Replicate("-", 80))
		GFELog115:Add("[" + ALLTRIM(STR(nCountFiles)) + "] Arquivo: " + cNomeArq)

		GFEFile:Clear()
		GFEFile:Open(cDiretorio + "\" + cNomeArq)

		If !GFEFile:FEof()
			cBuffer := GFEFile:Line() // Carrega a linha atual
		EndIf
		//Se o Arquivo estiver em branco retornará uma mensagem em tela e no log e continuará a importação
		If Empty(cBuffer)
			GFELog115:Add("  ** Arquivo em branco.")
			GFELog115:Add("  ** Linha: " + cBuffer)
			GFEResult:AddErro("Arquivo: " + cNomeArq + "' em branco.")
			lArquivoValido := .F.
		EndIf

		// Verifica se é um arquivo válido. Identificador '000'.
		If SubStr(cBuffer, 01, 03) != "000"
			GFELog115:Add("  ** Arquivo inválido. Não foi possível encontrar o Registro '000' - Cabeçalho de Intercâmbio.")
			GFELog115:Add("  ** Linha: " + cBuffer)
			GFEResult:AddErro("Arquivo: " + cNomeArq + "' inválido.")
			GFELog115:NewLine()
			GFELog115:Save()
			lArquivoValido := .F.
		EndIf

		// Validação da versão do Layout
		If lArquivoValido
			GFEFile:FNext()
			cBuffer := GFEFile:Line()

			// Identifica a versão Layout do arquivo
			cLayoutVer := SubStr(cBuffer, 01, 03)

			// Valida a versão do layout do arquivo
			If (cLayoutVer != "320" .AND. cLayoutVer != "520") .OR. Empty(cLayoutVer)
				GFELog115:Add("** " + "Arquivo '" + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.", 1)
				GFELog115:Save()
				GFEResult:AddErro("Arquivo: " + cNomeArq + "' com formato inválido ou layout incompatível com o sistema.")
				lArquivoValido := .F.
			EndIf

		EndIf

		// Leitura do Arquivo
		If lArquivoValido
			If cLayoutVer == "320"
				LayoutPro3()
			EndIf

			If cLayoutVer == "520"
				GFEA115B()
			EndIf

			// Gravação para na tabela intermediária
			GerarGXG()
		EndIf

		//Valida faixa do fornecedor
		If cLayoutVer == "320"
			If lTranspVld
				lArquivoValido := .F.
				GFELog115:Add( cNomeArq +" :Conhecimento fora da faixa informada.")
				GFEResult:AddErro("Arquivo: " + cNomeArq + "' conhecimento fora da faixa informada.")
			Endif
		EndIf

		//Transportador não encontrado
		If !(lCNPJTra)
			lArquivoValido := .F.
		Endif
		cNewNomeArq := cFormatDt + "_" + cFormatTm + "_" + cNomeArq

		If lArquivoValido .AND. nCountImpor > 0
			If (FRename(cDiretorio + "\" + cNomeArq, cDirOk + "\" + cNewNomeArq) == -1)
				GFELog115:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirOk + "\" + cNewNomeArq, "Aviso")
			EndIf

			GFEResult:Add("Arquivo: " + cNomeArq + "' importado.")
			GFEResult:Add("")
		Else
			GFEResult:AddErro("Arquivo '" + cNomeArq + "' não importado!")
			GFEResult:AddErro("")

			If (FRename(cDiretorio + "\" + cNomeArq, cDirErro + "\" + cNewNomeArq) == -1)
				GFELog115:Add("** " + "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq)
				MsgAlert(             "Erro ao mover arquivo '" + cDiretorio + "\" + cNomeArq  + "' para o diretório " + cDirErro + "\" + cNewNomeArq, "Aviso")
			EndIf
		EndIf
	Next

	If nCountImpor == 0
		GFELog115:NewLine()
		GFELog115:Add("Nenhum conhecimento foi importado.")

		GFEResult:Add("Nenhum conhecimento foi importado." + CHR(13) + CHR(10) + ;
					  "- Verifique a faixa de transportador. " + CHR(13) + CHR(10) +  ;
					  "- Verifique se o arquivo EDI foi exportado corretamente pela transportadora.")
		GFEResult:SetWarningIcon()
	EndIf

	GFELog115:EndLog()
	
	If !Empty(MV_PAR06) .or. MV_PAR06 != "" 
		If MV_PAR06 == 1
			IF lVerPerg
				GFEResult:Show("Importação de arquivos", "Arquivos", "Erros", "Ocorreram erros na importação de um ou mais arquivos. Clique no botão 'Erros' para mais detalhes.")
			EndIf
		EndIf
	Else
		IF lVerPerg
			GFEResult:Show("Importação de arquivos", "Arquivos", "Erros", "Ocorreram erros na importação de um ou mais arquivos. Clique no botão 'Erros' para mais detalhes.")
		EndIf
	EndIf
	// Inicializa variáveis e objetos
	GFELog115 := Nil
	GFEResult := Nil
	GFEFile   := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarGXG
Geração da tabela intermediária GXG e GXH

@author Israel A Possoli
@since 13/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarGXG()
Local cNRIMP     := ""
Local cMarca     := Iif(IsBlind(), "", oBrowse115:Mark())
Local nI         := 0
Local nGXG_NRIMP := TamSx3("GXG_NRIMP")[1]

	dbSelectArea((tTabCTRC))
	dbGoTop()

	// Conhecimentos
	Do While (tTabCTRC)->(!Eof())
		cNRIMP := SubStr(FWUUIDV4(),1,nGXG_NRIMP)

		RecLock("GXG", .T.)
			GXG->GXG_FILIAL := xFilial("GXG")
			GXG->GXG_NRIMP  := cNRIMP
			GXG->GXG_MARKBR := cMarca
			GXG->GXG_USUIMP := cUserName
			GXG->GXG_DTIMP  := DDATABASE
			GXG->GXG_ORIGEM := "1"
			GXG->GXG_ALTER  := "2"

			// Grava todos os campos, com execção do GXG_FILIAL e GXG_NRIMP
			For nI := 3 To Len(aCamposCTRC)
				&("GXG->" + aCamposCTRC[nI][1] + " := (tTabCTRC)->" + aCamposCTRC[nI][1])
			Next nI
		GXG->(MsUnlock())

		// Notas Fiscais
		dbSelectArea((tTabNF))
		dbSeek((tTabCTRC)->GXG_FILIAL + (tTabCTRC)->GXG_NRIMP)
		Do While (tTabNF)->(!Eof()) .And.;
			(tTabNF)->GXH_FILIAL = (tTabCTRC)->GXG_FILIAL .And.;
			(tTabNF)->GXH_NRIMP = (tTabCTRC)->GXG_NRIMP

			RecLock("GXH", .T.)
				GXH->GXH_FILIAL := xFilial("GXH")
				GXH->GXH_NRIMP	:= cNRIMP
				For nI := 3 To Len(aCamposNF)
					&("GXH->" + aCamposNF[nI][1] + " := (tTabNF)->" + aCamposNF[nI][1])
				Next nI
			GHX->(MsUnlock())

			(tTabNF)->(dbSkip())
		EndDo
		(tTabCTRC)->(dbSkip())
	EndDo

	dbSelectArea((tTabCTRC))
	Zap

	dbSelectArea((tTabNF))
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
	Local nContLinhas		:= 0  	// Contador de Linhas do arquivo
	Local nCountCTRCArq		:= 0
	Local lImpISS			:= .F.
	Local lSelecao			:= .T.
	Local cIdCont			:= ""	// Identificador da continuidade/repetição dos dados do conhecimento (mais de 40 Notas Fiscais). U ou Branco=Único; C=Continuidade
	Local nVlDF				:= 0
	Local nPedag			:= 0
	Local aIcms 			:= {}
	Local nContNF			:= 0	// Contador de notas fiscais
	Local lFlag				:= .T.
	Local cFilialCTRC		:= ""
	Local cFilialDC			:= ""
	Local cEmissorDc		:= ""
	Local cNumeroNF			:= ""  	// Numero da Nota Fiscal do arquivo
	Local cNumeroDc			:= ""  	// Número do Documento de Carga encontrado na base de dados
	Local cSerieNF			:= ""	// Série da Nota Fiscal do arquivo
	Local cSerieDC			:= ""	// Série do Documento de Carga encontrado na base de dados
	Local nPlus				:= 0
	Local cNextBuff			:= ""
	Local cBuffer			:= ""
	Local cBuffer329		:= ""
	Local cMsgPreVal 		:= ""
	Local nI				:= 0
	Local lDestFilial		:= .F.
	Local lBuscaDC			:= .F.
	Local cCFOP				:= ""	// CFOP quando não vem no arquivo
	Local cUFRemetente		:= ""
	Local cUFDestinatario	:= ""
	Local cCNPJTransp 		:= ""  
	Local cCNPJEmbarc 		:= ""  
	Local cCNPJDest 		:= ""  
	Local cUFDestP 			:= "" 
	Local cCODTransp 		:= "" // Códigos de emitentes encontrados
	Local cCODEmbarc    	:= "" // Códigos de emitentes encontrados
	Local aAreaGU3
	Local aGXG 				:= Array(12)
	Local cTpDc				:= ""
	Local cTPDf         	:= ""
	Local lTodosDC      	:= .T. //Indica que encontrou todos os documentos de carga vinculados
	Local cModoGXG       	:= ''
	Local aGXH 				:= {}
	Local cNRConhec 		:= ""
	Local cRedesp  			:= .F.
	Local cNormPag 			:= .F.
	Local nContSeq			:= 0
	Local nx 				:= 0
	local aDados 			:= {}
	Local nISX5 			:= 0
	Local s_GFEA1151 		:= ExistBlock("GFEA1151")
	Local s_GFEA1153 		:= ExistBlock("GFEA1153")
	Local s_GFEA1154 		:= ExistBlock("GFEA1154")
	Local s_GFEA1158 		:= ExistBlock("GFEA1158")	
	Local s_ESPDF1   		:= SuperGetMv("MV_ESPDF1",,"")
	Local s_ESPDF2   		:= SuperGetMv("MV_ESPDF2",,"")
	Local s_ESPDF3   		:= SuperGetMv("MV_ESPDF3",,"")
	Local s_ESPDF3_2 		:= SuperGetMv("MV_ESPDF3",,"")
	Local oDocTrecho 		:= JsonObject():new()
	Local cOrigem 	 		:= ""
	Local aPesqDoc 			:= Array(6)
	Local nTotalLinhas 		:= 0
	Local cQuery 			:= ""
	Local cVLCNPJ   		:= SuperGetMV('MV_VLCNPJ',,'1')
	Local nPCIMP    		:= 0
	Local cAliGU7			:= ""
	Local nVlDif			:= 0
	Local cApuIss 	 		:= ""
	Local cCidTransp 		:= ""
	Local cCidOri    		:= ""
	Local cCidDest   		:= ""
		
	cModoGXG 	:= FWModeAccess("GXG",1)

	GFELog115:Add("Versão EDI: 3.1")
	GFELog115:NewLine()
	GFELog115:AddDebug("Processando arquivo... Horário: " + Time())

	If !GFEFile:FEof()
		If !IsBlind()
			nTotalLinhas := GFEFile:nQtdeLin
			oProcess:setRegua2(nTotalLinhas)
		EndIf
	EndIf

	While !GFEFile:FEof()
		nContLinhas++
		lImpISS := .F.
		cBuffer := GFEFile:Line()

		If !IsBlind()
			oProcess:incRegua2( "Processando linha " + AllTrim(Str(nContLinhas)) + " de " + AllTrim(Str(nTotalLinhas)) )
		EndIf

		// Documento de carga que possuir trecho pago referente ao Emitente
		oDocTrecho['ACHOU_DOC'] 	:= .F.	
		oDocTrecho['GW1_FILIAL']	:= ""
		oDocTrecho['GW1_EMISDC'] 	:= ""
		oDocTrecho['GW1_SERDC'] 	:= ""
		oDocTrecho['GW1_NRDC'] 		:= ""
		oDocTrecho['GW1_CDTPDC'] 	:= ""
		oDocTrecho['GW1_CDREM'] 	:= ""
		oDocTrecho['GW1_CDDEST'] 	:= ""
		oDocTrecho['GW1_ENTNRC'] 	:= ""
		oDocTrecho['GW1_USO'] 		:= ""
		oDocTrecho['GW1_ICMSDC'] 	:= ""
		oDocTrecho['GW1_NRROM'] 	:= ""

		// Faixa Transportador
		If SubStr(cBuffer, 01, 03) == "321"
			cCNPJTransp := SubStr(cBuffer, 04, 14)
		EndIf
		
		If SubStr(cBuffer, 01, 03) != "322" .Or. !lSelecao
			GFEFile:FNext()
			Loop
		EndIf

		aGXH := {}
		aSize(aGXH, 0)

		cMsgPreVal  := ""

		//Verifica a existencia de dados complementares do conhecimento embarcado - Inicio
		GFEFile:FNext()
		If !GFEFile:FEof()
			cBuffer329 := GFEFile:Line()
		EndIf

		// Verifica se é um complemento
		If SubStr(cBuffer329, 01, 03) != "329"
			GFEFile:FPrior()
			cBuffer329 := ""
		EndIf
		//Verifica a existencia de dados complementares do conhecimento embarcado - Fim

		// Identificador de continuidade do conhecimento (mais de 40 Notas Fiscais)
		cIdCont := SubStr(cBuffer, 675, 1)
		
		cNRConhec := AllTrim(SubStr(cBuffer, 19, 12)) // Número do Conhecimento 			
		cCNPJEmbarc := SubStr(cBuffer, 219, 14) // Emissor da nota fiscal
		cCNPJEmiss  := SubStr(cBuffer, 205, 14) // Emissor do conhecimento

		GFELog115:Add(Replicate("-", 40))

		GFELog115:Add("- Conhecimento:")
		GFELog115:Add("> Número Conhec: " + cNRConhec, 1)			
		GFELog115:Add("> CNPJ Embarcad: " + cCNPJEmbarc, 1)
		GFELog115:Add("> CNPJ Emissor.: " + cCNPJEmiss, 1)
		GFELog115:Add("# BUSCANDO DADOS BASE", 1)

		/* Busca a Filial do Conhecimento */
		//Se for exclusivo, deve-se usar a filial escolhida em tela
		If cModoGXG == "E"
			cFilialCTRC := cFilAnt
			GFELog115:AddDebug("# Filial em modo Exclusivo. Filial " + cFilAnt, 1)
		Else
			cFilialCTRC := ""
		EndIf

		//
		// Verifica se o CNPJ da Embarcadora é uma Filial
		// Busca primeira nota do EDI
		// A partir dessa nota que são encontradas todas as outras informações relacionadas ao conhecimento importado:
		// UF DEST, UF REM, REM, DEST, COD de Embarcador, Transportador, etc
		//
		
		iCnpjEmb := val(cCNPJEmbarc)
		cCnpjT := cvaltochar(iCnpjEmb)	
		
		For nx := Len(cCnpjT) To 11
			cCnpjT := PadL(cCnpjT, nx, "0")
		Next nx			
		
		GU3->( dbSetOrder(11) )
		If !GU3->( dbSeek(xFilial("GU3") + cCNPJEmbarc) )
					
			// verifica se é pessoa física
			GU3->( dbSetOrder(11) )
			If GU3->( dbSeek(xFilial("GU3") + cCnpjT) )
				cCNPJEmbarc := cCnpjT
			EndIf
		EndIf
		
		//---------------------------------------------------------------------------
		// Percorre os Emitentes com o CNPJ informado, e busca os Documentos deles
		//---------------------------------------------------------------------------
		GFELog115:AddDebug("# Buscando Emitentes", 1)
		BeginSql Alias 'QryGU3'
			SELECT GU3.GU3_CDEMIT, GU3.GU3_SIT, GU3_EMFIL, GU3_TRANSP, GU3_FORN, GU3.R_E_C_N_O_ AS RECNOGU3
			FROM %table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_IDFED = %exp:AllTrim(cCNPJEmbarc)%
			AND GU3.%NotDel%
			ORDER BY GU3.GU3_IDFED, GU3.GU3_FILIAL, GU3.GU3_SIT
		EndSql

		cQuery := GetLastQuery()[2]
		GFELog115:AddDebug("SQL de pesquisa dos Emitentes: " + cQuery, 1)

		QryGU3->( dbGotop() )
		If QryGU3->( Eof() )	
			cMsgPreVal += "- "  + "Não existe emitente cadastrado com o CNPJ " + cCNPJEmbarc + CRLF
			GFELog115:Add("** " + "Não existe emitente cadastrado com o CNPJ " + cCNPJEmbarc, 1)
		Else
			cSerieNF        := PadR(ALLTRIM(SubStr(cBuffer, 233, 03)), __nTamSrDC)
			lBuscaDC        := .F.
			lSelecao		:= .F.
			lDestFilial     := .F.
			cUFRemetente    := ""
			cUFDestinatario := ""

			GFELog115:AddDebug("# Um ou mais emitente(s) encontrado(s). Processando somente os Ativos... Horário: " + Time(), 1)

			While !QryGU3->( Eof() ) .And. !lBuscaDC

				GU3->(dbSetOrder(1))
				GU3->(dbGoTo( QryGU3->RECNOGU3 ))

				If QryGU3->(GU3_SIT) != __cAtivo
					Exit
				EndIf				

				GFELog115:AddDebug("# Processando Emitente --> Código: " + QryGU3->(GU3_CDEMIT), 1)
				
				//---------------------------------------------------------------------------
				// Regra para buscar o número da nota fiscal no GFE:
				// Inicia a busca a partir do número sem zeros à esquerda e enquanto
				// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
				//---------------------------------------------------------------------------
				aPesqDoc[1] := QryGU3->(GU3_CDEMIT)
				aPesqDoc[2] := cSerieNF
				aPesqDoc[3] := cFilialCTRC
				aPesqDoc[4] := ""
				aPesqDoc[5] := {}
				aPesqDoc[6] := cCNPJTransp

				cNumeroNF := GFEZapZero(AllTrim(SubStr(cBuffer, 236, 08)))	

				For nI := Len(cNumeroNF) To __nTamNrDC
					cNumeroNF := PadL(cNumeroNF, nI, "0")		
					AAdd(aPesqDoc[5], cNumeroNF)
				Next

				GFELog115:AddDebug("# Pesquisando os Documentos de Carga do Emitente... ", 1)
				FindDocTrechoPago(aPesqDoc, @oDocTrecho)

				ASize(aPesqDoc[5], 0)

				If oDocTrecho['ACHOU_DOC']

					lBuscaDC := .T.
					GFELog115:Add("# Documento de Carga encontrado: Emissor [" +  GU3->GU3_CDEMIT + "] Série [" + AllTrim(oDocTrecho['GW1_SERDC']) + "] Número [" + AllTrim(oDocTrecho['GW1_NRDC']) + "]", 1)

					cCODEmbarc 	:= GU3->GU3_CDEMIT
					cEmissorDC	:= GU3->GU3_CDEMIT
					cFilialCTRC := oDocTrecho['GW1_FILIAL']  

					aAdd(aGXH, {oDocTrecho['GW1_FILIAL'],;
								1,;
								oDocTrecho['GW1_EMISDC'], ;
								oDocTrecho['GW1_SERDC'],;
								oDocTrecho['GW1_NRDC'],;
								oDocTrecho['GW1_CDTPDC'],;
								""; //chave nf-e
								})

					GFELog115:Add("> Cod Embarcad.: " + cCODEmbarc, 1)

					// Remetente e destinatário do conhecimento
					aGXG[07] := oDocTrecho['GW1_CDREM']  //GXG_CDREM
					aGXG[08] := oDocTrecho['GW1_CDDEST'] //GXG_CDDEST
					
					aAreaGU3 := GU3->( GetArea() )					

					GFELog115:AddDebug("# Pesquisando o Remetente... ", 1)
					GU3->( dbSetOrder(1) )
					If GU3->( dbSeek(xFilial("GU3") + oDocTrecho['GW1_CDREM']) )
						cUFRemetente := POSICIONE("GU7",1,xFilial("GU7")+GU3->GU3_NRCID, "GU7_CDUF")
					Else
						cMsgPreVal += "- "  + "Não foi encontrado o Emitente (Remetente):  " + oDocTrecho['GW1_CDREM']  + CRLF
						GFELog115:Add("** " + "Não foi encontrado o Emitente (Remetente):  " + oDocTrecho['GW1_CDREM'], 1)
					EndIf
					
					GFELog115:AddDebug("# Pesquisando o Destinatário... ", 1)
					If GU3->( dbSeek(xFilial("GU3") + oDocTrecho['GW1_CDDEST']) )
						If !Empty(oDocTrecho['GW1_ENTNRC'])
							cUFDestinatario := POSICIONE("GU7",1,xFilial("GU7")+oDocTrecho['GW1_ENTNRC'], "GU7_CDUF")
						Else
							cUFDestinatario := POSICIONE("GU7",1,xFilial("GU7")+GU3->GU3_NRCID, "GU7_CDUF")
						EndIf
					
						cCNPJDest := GU3->GU3_IDFED
						cUFDestP := POSICIONE("GU7",1,xFilial("GU7")+GU3->GU3_NRCID, "GU7_CDUF")

						If GU3->GU3_EMFIL == "1" // Se não for filial é Nota Fiscal de compra e o emissor é um fornecedor
							lDestFilial := .T.
						EndIf
					Else
						GFELog115:Add("** Não foi possível encontrar o Emitente (Destinatário): " + oDocTrecho['GW1_CDDEST'], 1)
					EndIf
					
					RestArea(aAreaGU3)

				EndIf
				
				GFELog115:AddDebug("# Fim do processamento do Emitente com código " + QryGU3->(GU3_CDEMIT), 1)

				QryGU3->(dbSkip())
			EndDo

			GFELog115:AddDebug("# Fim do processamento dos Emitentes... Horário: " + Time(), 1)

			// Ponto de Entrada Procomp
			If s_GFEA1151
				lBuscaDC := ExecBlock("GFEA1151",.f.,.f.,{})
			EndIf

			// Se não encontrar o documento msg de alerta
			If !lBuscaDC
				If Empty(cFilialCTRC)
					cMsgPreVal += "- "  + "Não foi encontrado o Documento de Carga com trecho pago e transportador informado. CNPJ Emissor: " + cCNPJEmbarc + ", Série: " + cSerieNF + ", Nr: " +  SubStr(cBuffer, 236, 08) + CRLF
					GFELog115:Add("** Não foi encontrado o Documento de Carga com trecho pago e transportador informado. CNPJ Emissor: " + cCNPJEmbarc + ", Série: " + cSerieNF + ", Nr: " + SubStr(cBuffer, 236, 08), 1)
				Else
					cMsgPreVal += "- "  + "Não foi encontrado o Documento de Carga com trecho pago e transportador informado. Filial: " + cFilialCTRC + ", CNPJ Emissor: " + cCNPJEmbarc + ", Série: " + cSerieNF + ", Nr: " +  SubStr(cBuffer, 236, 08) + CRLF
					GFELog115:Add("** Não foi encontrado o Documento de Carga com trecho pago e transportador informado. Filial: " + cFilialCTRC + ", CNPJ Emissor: " + cCNPJEmbarc + ", Série: " + cSerieNF + ", Nr: " + SubStr(cBuffer, 236, 08), 1)
				EndIf
			EndIf

		EndIf	// Fim - QryGU3

		QryGU3->( dbCloseArea( ) )

		GFELog115:AddDebug("Buscando Código do Emissor...", 1)
		aGXG[03] := A118EMIT("1",cCNPJEmiss,{})

		If !Empty(aGXG[03])
			GFELog115:Add("> COD Emissor.: " + aGXG[03], 1)
		Else
			GFELog115:Add("** COD Emissor.: não foi encontrado emissor válido com o CNPJ " + cCNPJEmiss, 1)
		EndIf

		GFELog115:AddDebug("Buscando Código do Transportador...", 1)
		cCODTransp	:= A118EMIT("1",cCNPJTransp,{})

		GFELog115:Add("> CNPJ Transportador: " + cCNPJTransp)

		If !Empty(cCodTransp)
			GFELog115:Add("> COD Transportador: " + cCodTransp)
			lCNPJTra := .T.
			If MV_PAR01 <= cCODTransp .And. MV_PAR02 >= cCODTransp
				lSelecao := .T.
				lTranspVld := .F.
				nCountCTRCArq++
			Else
				lSelecao := .F.
				GFELog115:Add("** Transportador fora da faixa. Desconsiderando conhecimento.", 1)
				lTranspVld :=.T.
				Loop
			EndIf
		Else
			GFELog115:Add("** Não foi encontrado cadastro de transportador válido com CNPJ "+cCNPJTransp+" ou documento de carga não possui trecho pago para o transportador. Desconsiderando conhecimento.", 1)
			GFEResult:AddErro("Arquivo: " + cNomeArq + "** Não foi encontrado cadastro de transportador válido com CNPJ "+cCNPJTransp+" ou documento de carga não possui trecho pago para o transportador. Desconsiderando conhecimento.")
			lCNPJTra := .F.
			lSelecao := .F.
			Loop
		EndIf

		GFELog115:AddDebug("Buscando a Filial...", 1)
		
		If Empty(cFilialCTRC)
			
			GFELog115:AddDebug("Buscando a Filial pelo CNPJ do Embarcador...", 1)
			cFilialCTRC := GFEA115BF(cCNPJEmbarc, .F.)
			If !Empty(cFilialCTRC)
				GFELog115:Add("> Filial.......: CNPJ do Embarcador", 1)
				GFELog115:Add("> CNPJ Filial..: " + cCNPJEmbarc, 1)
			EndIf

			GFELog115:AddDebug("Buscando a Filial pelo CNPJ do Emissor...", 1)
			If Empty(cFilialCTRC)
				cFilialCTRC := GFEA115BF(cCNPJEmiss, .T.)
				If !Empty(cFilialCTRC)
					GFELog115:Add("> Filial.......: CNPJ do Emissor", 1)
					GFELog115:Add("> CNPJ Filial..: " + cCNPJEmiss, 1)
				EndIf
			EndIf
		EndIf

		// Início Ponto de Entrada Procomp
		If s_GFEA1154  
			aRet := ExecBlock("GFEA1154",.f.,.f.,{cFilialCTRC,cCNPJEmiss,cCNPJEmbarc,cCNPJDest,cUFRemetente,cUFDestP,aGXH,aGXG[07],cBuffer })
			cFilialCTRC := aRet[1]
			aGXG[07] := aRet[2]
		EndIf
		// Fim Ponto de Entrada Procomp

		GFELog115:Add("> Filial.......: " + cFilialCTRC, 1)
		GFELog115:Add("> Série........: " + SubStr(cBuffer, 14, 05), 1)
		GFELog115:Add("> Número.......: " + SubStr(cBuffer, 19, 12), 1)
		GFELog115:Save()

		If Empty(cFilialCTRC)
			cMsgPreVal +=    "- " + "Não foi possível identificar a Filial. Motivo: CNPJ do Embarcador/Emissor não é filial ou o Destinatário da Nota Fiscal não é Filial." + CRLF
			GFELog115:Add("** " + "Não foi possível identificar a Filial. Motivo: CNPJ do Embarcador/Emissor não é filial ou o Destinatário da Nota Fiscal não é Filial.", 1)
		EndIf

		nCountImpor++
		nNRIMP++

		//----------------------------------------------------------
		// Grava na tabela temporária GXG (EDI - Documento de Frete)  
		//----------------------------------------------------------
		RecLock((tTabCTRC), .T.)
		(tTabCTRC)->GXG_FILIAL	:= xFilial("GXG")
		(tTabCTRC)->GXG_NRIMP   := cValToChar(nNRIMP)

		(tTabCTRC)->GXG_ORINR  	:= AllTrim(SubStr(cBuffer329, 54, 12))
		(tTabCTRC)->GXG_ORISER 	:= AllTrim(SubStr(cBuffer329, 49, 05))
		(tTabCTRC)->GXG_EDILIN 	:= cBuffer
		(tTabCTRC)->GXG_EDIARQ 	:= cNomeArq
		(tTabCTRC)->GXG_EDINRL 	:= nContLinhas
		(tTabCTRC)->GXG_EDISIT 	:= "1"

		(tTabCTRC)->GXG_FILDOC	:= cFilialCTRC
		(tTabCTRC)->GXG_SERDF	:= AllTrim(SubStr(cBuffer, 14, 05))
		(tTabCTRC)->GXG_NRDF    := AllTrim(SubStr(cBuffer, 19, 12))
		(tTabCTRC)->GXG_DTEMIS  := StoD(SubStr(SubStr(cBuffer, 31, 08), 5, 4)+SubStr(SubStr(cBuffer, 31, 08), 3, 2) + SubStr(SubStr(cBuffer, 31, 08), 1, 2))

		(tTabCTRC)->GXG_PESOR   := Val(Transform(SubStr(cBuffer, 40, 7), '@R 99999.99'))
		(tTabCTRC)->GXG_VLDF    := nVlDF := Val(Transform(SubStr(cBuffer, 47, 15), '@R 9999999999999.99'))
		(tTabCTRC)->GXG_ACAO    := Iif(!Empty(SubStr(cBuffer, 673, 1)),SubStr(cBuffer, 673, 1),'I')

		(tTabCTRC)->GXG_FRPESO  := Val(Transform(SubStr(cBuffer, 96 , 15), '@R 9999999999999.99'))
		(tTabCTRC)->GXG_FRVAL   := Val(Transform(SubStr(cBuffer, 111, 15), '@R 9999999999999.99'))

		(tTabCTRC)->GXG_TAXAS   := Val(SubStr(cBuffer, 126, 15)) + Val(SubStr(cBuffer, 141, 15)) + Val(SubStr(cBuffer, 156, 15)) + Val(SubStr(cBuffer, 186, 15))
		(tTabCTRC)->GXG_TAXAS	:= ((tTabCTRC)->GXG_TAXAS / 100)

		(tTabCTRC)->GXG_PEDAG   := nPedag := Val(Transform(SubStr(cBuffer, 171, 15), '@R 9999999999999.99'))

		(tTabCTRC)->GXG_EMISDF  := aGXG[03]

		// Busca emitente - Chave CT-e
		dbSelectArea("GU3")
		dbSetOrder(1)
		If !Empty((tTabCTRC)->GXG_EMISDF)
			If dbSeek(xFilial("GU3") + (tTabCTRC)->GXG_EMISDF)
				// Chave CTe
				If !Empty(GU3->GU3_EDICTE) .AND. GU3->GU3_EDICTE > 0
					(tTabCTRC)->GXG_CTE    := AllTrim(SubStr(cBuffer, GU3->GU3_EDICTE, 44))
					GFELog115:Add("# Chave CTe definido no cadastro de emitente na posição: " + cValToChar(GU3->GU3_EDICTE), 1)
				Else
					(tTabCTRC)->GXG_CTE    := AllTrim(SubStr(cBuffer, 675, 44))
					GFELog115:Add("# Posição da Chave CTe não definido no cadastro de emitente. Usando posição padrão: 675" , 1)
				EndIf
			EndIf
		EndIf
		
		// Tipo Ct- e
		If !empty((tTabCTRC)->GXG_CTE)
			(tTabCTRC)->GXG_TPCTE := '0'
		Else
			(tTabCTRC)->GXG_TPCTE := ' '
		EndIf
		If !Empty(cCFOP)
			(tTabCTRC)->GXG_CFOP := cCFOP
		EndIf

		(tTabCTRC)->GXG_DTENT  := DDATABASE
		(tTabCTRC)->GXG_CDCONS := " "

		(tTabCTRC)->GXG_CDREM  := aGXG[07]
		(tTabCTRC)->GXG_CDDEST := aGXG[08]

		GFELog115:Add("> Série........: " + (tTabCTRC)->GXG_SERDF, 1)
		GFELog115:Add("> Número.......: " + (tTabCTRC)->GXG_NRDF, 1)
		GFELog115:Add("> Data Emissão.: " + DTOC((tTabCTRC)->GXG_DTEMIS), 1)
		GFELog115:Add("> CFOP.........: " + (tTabCTRC)->GXG_CFOP, 1)

		GFELog115:Save()

		If SubStr(cBuffer, 62, 15) > "000000000000000"
			(tTabCTRC)->GXG_BASIMP := Val(Transform(SubStr(cBuffer, 62, 15), '@R 9999999999999.99'))
		EndIf

		If SubStr(cBuffer, 77, 04) > "0000"
			(tTabCTRC)->GXG_PCIMP := Val(Transform(SubStr(cBuffer, 77,  04), '@R 99.99'))
		EndIf

		If SubStr(cBuffer, 81, 15) > "000000000000000"
			If (Val(SubStr(cBuffer, 81, 15)) + Val(SubStr(cBuffer329, 24, 15))) > 9 //Para valores menores que 0,10 deve-se utilizar outra lógica
				(tTabCTRC)->GXG_VLIMP := Val(Transform(AllTrim(Str(Val(SubStr(cBuffer, 81, 15)) + Val(SubStr(cBuffer329, 24, 15)))) , '@R ' + Replicate('9', Len(AllTrim(Str(Val(SubStr(cBuffer, 81, 15)) + Val(SubStr(cBuffer329, 24, 15))))) - 2) + '.99'))
			Else
				(tTabCTRC)->GXG_VLIMP := Val(Transform(AllTrim(Str(Val(SubStr(cBuffer, 81, 15)) + Val(SubStr(cBuffer329, 24, 15)))) , '@R 0.09'))
			EndIf
			(tTabCTRC)->GXG_TPIMP := "1"
		EndIf

		//If lBuscaDC
		//------------------------ DISCLAIMER!!! ------------------------//
		//---------- Manutenções efetuadas nesse bloco devem ------------//
		//----- ser replicadas para a função ReprocessDoctoCarga() ------//
		//--- para correto funcionamento da importação e processamento --//
		//-------------------- de EDI Conemb e CT-e. --------------------//
		//----------- Alteração efetuada no chamado TQWOHG --------------//
		//---------------------------------------------------------------//

		//Atribuir ao campo GW3_CDESP o parâmetro MV_ESPDF1 quando o campo VALOR DO ICMS (registro 322)
		//for maior que zero ou o parâmetro MV_ESPDF2 quando o campos VALOR TOTAL DO ISS (registro 329) for maior que zero.
		//Antiga verificação do ElseIf : AllTrim(Transform(Val(SubStr(cBuffer,81,15)) , '@R 9999999999999,99'))
		//Quando o campo GXG_CTE vir preenchido (ou o CONEMB é um Conhecimento Eletronico)
		//Deve ser atribuido o paramêtro MV_ESPDF3
		// Chave CT-e

		If oDocTrecho['ACHOU_DOC']
			GFELog115:AddDebug("# Iniciando processamento de Substituição Tributária e ICMS. Horário: " + Time(), 1)
			
			dbSelectArea("GW1")
			GW1->(dbSetOrder(1))
			GW1->( dbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_CDTPDC'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC']) )
			If  GW1->GW1_ORIGEM == '3' // ORIGEM IGUAL 3-SIGATMS
				GWU->(dbSetOrder(1))
				GWU->( dbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_CDTPDC'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC']) )
				cOrigem :=  GWU->GWU_NRCIDO
				cDestin :=  GWU->GWU_NRCIDD
			Else
				cOrigem := Posicione("GU3", 1, xFilial("GU3") + oDocTrecho['GW1_CDREM'], "GU3_NRCID")

				If !Empty(oDocTrecho['GW1_ENTNRC'])
					cDestin := oDocTrecho['GW1_ENTNRC']
				Else
					cDestin := Posicione("GU3", 1, xFilial("GU3") + oDocTrecho['GW1_CDDEST'], "GU3_NRCID")
				EndIf
			EndIf
			
			If !Empty((tTabCTRC)->GXG_CTE) .And. !Empty(s_ESPDF3)
				If (SubStr(cBuffer329,24,15) > "000000000000000" .And. SubStr(cBuffer329, 1, 3) == "329") .or. (cOrigem == cDestin)
					(tTabCTRC)->GXG_CDESP := s_ESPDF2
					(tTabCTRC)->GXG_TPIMP := "2"
					lImpISS := .T.
				Else
					(tTabCTRC)->GXG_CDESP := s_ESPDF3_2
				EndIf
			ElseIf (SubStr(cBuffer329,24,15) > "000000000000000" .And. SubStr(cBuffer329, 1, 3) == "329") .or. (!Empty(cOrigem) .And. (cOrigem == cDestin))
				(tTabCTRC)->GXG_CDESP := s_ESPDF2
				(tTabCTRC)->GXG_TPIMP := "2"
				lImpISS := .T.
			Else
				(tTabCTRC)->GXG_CDESP := s_ESPDF1
			EndIf

			If Empty(cOrigem)
				(tTabCTRC)->GXG_TPIMP := "3"
			endif
			
			(tTabCTRC)->GXG_SUBTRB := SubStr(cBuffer, 201, 01)

			nStart4 := Seconds() 
			If (tTabCTRC)->GXG_SUBTRB == '1' .And. !(lImpISS)   // Substituição Tributária e ICMS

				dbSelectArea("GW8")  //Itens do Documento de Carga
				GW8->( dbSetOrder(1) )
				If GW8->( dbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_CDTPDC'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC']) )
			
					cOrigem := Posicione("GU3", 1, xFilial("GU3") + oDocTrecho['GW1_CDREM'], "GU3_NRCID")
					cDestin := Posicione("GU3", 1, xFilial("GU3") + oDocTrecho['GW1_CDDEST'], "GU3_NRCID")
			
					//Substituição tributária
					aIcms := GFEFnIcms((tTabCTRC)->GXG_EMISDF, oDocTrecho['GW1_CDREM'], oDocTrecho['GW1_CDDEST'], cOrigem, cDestin, oDocTrecho['GW1_USO'], GW8->GW8_TPITEM, GW8->GW8_CDCLFR, oDocTrecho['GW1_ICMSDC'], Posicione("GWN", 1, oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_NRROM'], "GWN_CDTPOP"))
			
					If (tTabCTRC)->GXG_PCIMP == 0
						(tTabCTRC)->GXG_PCIMP := aIcms[1]
					EndIf

					If (tTabCTRC)->GXG_BASIMP == 0 //Base de cálculo
			
						//Buscar base de ICMS
						dbSelectArea("GWH")
						GWH->( dbSetOrder(2) )
						If GWH->( dbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_CDTPDC'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC']) )
			
							dbSelectArea("GWG")
							GWG->( dbSetOrder(1) )
							If GWG->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) )
			
								dbSelectArea("GUY")
								GUY->( dbSetOrder(1) )
								If GUY->( dbSeek(GWG->GWG_FILIAL + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG) )
			
									While !GUY->( Eof() ) .And. GUY->GUY_FILIAL + GUY->GUY_CDEMIT + GUY->GUY_NRTAB + GUY->GUY_NRNEG == xFilial("GUY") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG
			
										dbSelectArea("GV2")
										GV2->( dbSetOrder(1) )
										If GV2->( dbSeek(xFilial("GV2") + GUY->GUY_CDCOMP) )
			
											If GV2->GV2_CATVAL == "4"
												If GUY->GUY_BASIMP == "1"
													(tTabCTRC)->GXG_BASIMP := nVlDF - nPedag
												Else
													(tTabCTRC)->GXG_BASIMP := nVlDF
												EndIf
			
												Exit
											EndIf
			
										EndIf
			
										dbSelectArea("GUY")
										GUY->( dbSkip() )
									EndDo
								EndIf
							EndIf
						EndIf
			
						If (tTabCTRC)->GXG_BASIMP == 0
							(tTabCTRC)->GXG_BASIMP := nVlDF
						EndIf
			
						(tTabCTRC)->GXG_BASIMP := (tTabCTRC)->GXG_BASIMP * (1 - (aIcms[3] / 100))
			
					EndIf
			
					If (tTabCTRC)->GXG_VLIMP == 0
						(tTabCTRC)->GXG_VLIMP := (tTabCTRC)->GXG_BASIMP * (tTabCTRC)->GXG_PCIMP / 100
					EndIf
			
					// Presumido
					If aIcms[2] == "7"
						(tTabCTRC)->GXG_IMPRET := (tTabCTRC)->GXG_VLIMP * (1 - (aIcms[4] / 100))
						(tTabCTRC)->GXG_PCRET  := aIcms[4]
			
					// Subs-tributária
					ElseIf aIcms[2] == "3"
						(tTabCTRC)->GXG_IMPRET := (tTabCTRC)->GXG_VLIMP
						(tTabCTRC)->GXG_PCRET  := 0
					EndIf
				EndIf
			EndIf
			GFELog115:AddDebug("# Processamento da Substituição Tributária e ICMS concluída. Horário: " + Time(), 1)
		
		EndIf	// Fim - ACHOU_DOC
				

		//ISS  -  Quando utilizado o registro 329 - opcional
		If SubStr(cBuffer329,24,15) > "000000000000000" .And. SubStr(cBuffer329, 1, 3) == "329"
			(tTabCTRC)->GXG_BASIMP := (tTabCTRC)->GXG_VLDF
			(tTabCTRC)->GXG_VLIMP  := Val(Transform(SubStr(cBuffer329, 24, 15), '@R 9999999999999.99'))
		
			nPCIMP := Round(((tTabCTRC)->GXG_VLIMP / (tTabCTRC)->GXG_BASIMP) * 100, 2)

			cAliGU7 := GetNextAlias()

			BeginSQL Alias cAliGU7
				SELECT GU7.GU7_PCISS
				FROM %Table:GU7% GU7
				WHERE GU7.GU7_FILIAL = %xFilial:GU7%
				AND GU7.GU7_NRCID = %Exp:cOrigem%
				AND GU7.%NotDel%
			EndSQL

			nVlDif := 0

			If (cAliGU7)->(!EoF()) .And. (cAliGU7)->GU7_PCISS > 0
				nVlDif := nPCIMP - (cAliGU7)->GU7_PCISS
				
				If nVlDif <= 0.05 .And. nVlDif >= - 0.05
					nPCIMP := (cAliGU7)->GU7_PCISS
				EndIf
			EndIf

			(cAliGU7)->(dbCloseArea())

			If Len(cValToChar(nPCIMP)) <= TamSx3("GXG_PCIMP")[1]
				(tTabCTRC)->GXG_PCIMP  := nPCIMP
			Else
				cMsgPreVal += "- "  + "O valor da aliquota do imposto informado no arquivo de importação, difere dos valores possíveis para importação do registro." + CRLF
				GFELog115:AddDebug("** " + "O valor da aliquota do imposto informado no arquivo de importação, difere dos valores possíveis para importação do registro.",1)
			EndIf

			(tTabCTRC)->GXG_TRBIMP := '1'
			(tTabCTRC)->GXG_TPIMP  := "2"
		ElseIf Alltrim((tTabCTRC)->GXG_CDESP) == 'NFST' .And. SubStr(cBuffer329, 1, 3) != "329"
			(tTabCTRC)->GXG_BASIMP := (tTabCTRC)->GXG_VLDF
			(tTabCTRC)->GXG_VLIMP  := Val(Transform(SubStr(cBuffer, 81, 15), '@R 9999999999999.99'))

			nPCIMP := Round(((tTabCTRC)->GXG_VLIMP / (tTabCTRC)->GXG_BASIMP) * 100, 2)

			cAliGU7 := GetNextAlias()

			BeginSQL Alias cAliGU7
				SELECT GU7.GU7_PCISS
				FROM %Table:GU7% GU7
				WHERE GU7.GU7_FILIAL = %xFilial:GU7%
				AND GU7.GU7_NRCID = %Exp:cOrigem%
				AND GU7.%NotDel%
			EndSQL

			nVlDif := 0

			If (cAliGU7)->(!EoF()) .And. (cAliGU7)->GU7_PCISS > 0
				nVlDif := nPCIMP - (cAliGU7)->GU7_PCISS
				
				If nVlDif == 0.01 .Or. nVlDif == - 0.01
					nPCIMP := (cAliGU7)->GU7_PCISS
				EndIf
			EndIf

			(cAliGU7)->(dbCloseArea())

			If Len(cValToChar(nPCIMP)) <= TamSx3("GXG_PCIMP")[1]
				(tTabCTRC)->GXG_PCIMP  := nPCIMP
			Else
				cMsgPreVal += "- "  + "O valor da aliquota do imposto informado no arquivo de importação, difere dos valores possíveis para importação do registro." + CRLF
				GFELog115:AddDebug("** " + "O valor da aliquota do imposto informado no arquivo de importação, difere dos valores possíveis para importação do registro.",1)
			EndIf
		EndIf

		dbSelectArea("GU3")
		dbSetOrder(1)
		If dbSeek(xfilial("GU3")+ AllTrim((tTabCTRC)->GXG_EMISDF))
			//ISS
			If lImpISS

				cCidTransp  := GU3->GU3_NRCID
				cCidOri     := GWU->GWU_NRCIDO
				cCidDest    := GWU->GWU_NRCIDD

				//Verificação do campo GU3_APISSO - Apuração ISS Outro Município/
				IF GFXCP1212410("GU3_APISSO") .AND. cCidTransp != cCidOri .AND. cCidTransp != cCidDest
					cApuIss := GU3->GU3_APISSO
				ELSE
					cApuIss := GU3->GU3_APUISS
				ENDIF

				If cApuIss == "2" .or. (tTabCTRC)->GXG_SUBTRB == '1'  //Substituicao Tributaria
					(tTabCTRC)->GXG_TRBIMP 	:= "3"
					(tTabCTRC)->GXG_VLIMP := (tTabCTRC)->GXG_BASIMP * (tTabCTRC)->GXG_PCIMP / 100
					(tTabCTRC)->GXG_IMPRET := (tTabCTRC)->GXG_VLIMP
					(tTabCTRC)->GXG_PCRET  := 0
				ElseIf cApuIss == "1"   //Normal
					If (tTabCTRC)->GXG_BASIMP > 0
						(tTabCTRC)->GXG_TRBIMP := "6"
					Else
						(tTabCTRC)->GXG_TRBIMP := '2'
					Endif
				Endif
				
			//ICMS
			Else
				If (tTabCTRC)->GXG_VLIMP > 0
					If GU3->GU3_APUICM == "1"
						(tTabCTRC)->GXG_TRBIMP := "1"
					ElseIf GU3->GU3_APUICM == "2"
						(tTabCTRC)->GXG_TRBIMP := "3"
					ElseIf GU3->GU3_APUICM == "3"
						(tTabCTRC)->GXG_TRBIMP := "4"
					ElseIf GU3->GU3_APUICM == "4"
						(tTabCTRC)->GXG_TRBIMP := "7"
					Endif
				ElseIf (tTabCTRC)->GXG_BASIMP > 0 
					(tTabCTRC)->GXG_TRBIMP := '6'
				ElseIf (tTabCTRC)->GXG_BASIMP == 0 .AND. GU3->GU3_TPTRIB == "2"  //Simples Nacional	
						(tTabCTRC)->GXG_TRBIMP := '6'
						(tTabCTRC)->GXG_BASIMP := nVlDF
				Else
					(tTabCTRC)->GXG_TRBIMP := '2'
				EndIf
			EndIf
		Endif

		// Início Ponto de Entrada Procomp
		If s_GFEA1153   
			tTabCTRC := ExecBlock("GFEA1153",.f.,.f.,{tTabCTRC, cBuffer, cBuffer329 })
		EndIf
		// Fim Ponto de Entrada Procomp

		//EndIf //Se não encontrar o documento, não atribui a espécie.

		cTPDf := Iif(!Empty(SubStr(cBuffer, 674, 01)),SubStr(cBuffer, 674, 01),'N')

		GFELog115:Add("> Tipo CTRC....: " + cTpDf, 1)

		If cTpDf $ "N,E,S,T, " //N = Normal, E = Normal de Entrada, S = Normal de Sai, T = Normal de transf interna

			(tTabCTRC)->GXG_TPDF := "1"

			If oDocTrecho['ACHOU_DOC']
				GFELog115:AddDebug("# Verificando Redespacho... ", 1)
			
				GWU->( DbSetOrder(1) )
				GWU->( DbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_CDTPDC'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC']) )
				While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == oDocTrecho['GW1_FILIAL'] .And. GWU->GWU_CDTPDC == oDocTrecho['GW1_CDTPDC'] .And. ;
						GWU->GWU_EMISDC == oDocTrecho['GW1_EMISDC'] .And. GWU->GWU_SERDC == oDocTrecho['GW1_SERDC'] .And. ;
						GWU->GWU_NRDC == oDocTrecho['GW1_NRDC']

					If (AllTrim(GWU->GWU_CDTRP) == AllTrim((tTabCTRC)->GXG_EMISDF) ) .Or. ;
					   (cVLCNPJ == '2' .And. SubStr(Posicione("GU3",1,xFilial("GU3") + GWU->GWU_CDTRP, "GU3_IDFED"),1,8) == SubStr(Posicione("GU3",1,xFilial("GU3") + (tTabCTRC)->GXG_EMISDF, "GU3_IDFED"),1,8) )
					
						nContSeq ++    //Indicar mais de um trecho com mesmo transp
						If GWU->GWU_SEQ != "01"
							cRedesp := .T.
						EndIf
						if GWU->GWU_SEQ == "01" .And. GWU->GWU_PAGAR == '1'
							cNormPag := .T.
						Endif
					EndIf
					GWU->( DbSkip() )
				EndDo
				
				If nContSeq == 1  //existe apenas 1 trecho com o transportador
					if cRedesp
						(tTabCTRC)->GXG_TPDF := "6" // Redespacho
					EndIf
				Else  //mais de um trecho com mesmo transp
					If !cNormPag   
						(tTabCTRC)->GXG_TPDF := "6" // Redespacho	
					Else
						//Busca se já existe doc frete para o trecho normal. Se sim, está recebendo o redespacho. Se não, mantém normal.
						GW4->( dbSetOrder(2) )
						If GW4->( dbSeek(oDocTrecho['GW1_FILIAL'] + oDocTrecho['GW1_EMISDC'] + oDocTrecho['GW1_SERDC'] + oDocTrecho['GW1_NRDC'] + oDocTrecho['GW1_CDTPDC'])) 
							While !GW4->(Eof()) .And.; 
							oDocTrecho['GW1_FILIAL'] == GW4->(GW4_FILIAL) .And.; 
							oDocTrecho['GW1_EMISDC'] == GW4->(GW4_EMISDC) .And.; 
							oDocTrecho['GW1_SERDC'] == GW4->(GW4_SERDC) .And.; 
							oDocTrecho['GW1_NRDC'] == GW4->(GW4_NRDC) .And.; 
							oDocTrecho['GW1_CDTPDC'] == GW4->(GW4_TPDC)
						
								GW3->(dbSetOrder(1))
								If GW3->(dbSeek(GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS))))
									While !GW3->(Eof()) .And. GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)) == GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS))
										If Gw3->GW3_TPDF == "1"
											(tTabCTRC)->GXG_TPDF := "6" // Redespacho
										EndIf
										GW3->(dbSkip())
									EndDo
								EndIf
								GW4->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf

				GFELog115:AddDebug("# Verificação do Redespacho concluída. ", 1)
			EndIf	// Fim - ACHOU_DOC
		
		ElseIf cTpDf $ "R" // R = Conhecimento de reentrega
			(tTabCTRC)->GXG_TPDF := "4"
		ElseIf cTpDf $ "D,O" //D = Conhecimento de devolução
			(tTabCTRC)->GXG_TPDF := "5"
		ElseIf cTpDf $ "C,W,X,Y,Z" //C=Complementar, W=Complementar de Retorno, X=Complementar de Entrada, Y=Complementar de Saída, Z=Complementar de Transf. Interna
			If (tTabCTRC)->GXG_VLDF != 0
				(tTabCTRC)->GXG_TPDF := "2"
			Else
				(tTabCTRC)->GXG_TPDF := "3"
			EndIf
		EndIf		// Fim - cTpDf $ "N,E,S,T, "
		
		If GFXCP12117("GXG_CDTPSE")
			If Alltrim(cTpDf) $ "M;P" // Caso não exista a tabela GU no SX5 inicializa ja com o tipo 7
				(tTabCTRC)->GXG_TPDF := "7"
			EndIf

			aDados:= FWGetSX5("GU")
			For nISX5 := 1 To Len(aDados)
				If Alltrim(aDados[nISX5][3]) == Alltrim(cTpDf) // Só deverá encontrar o registro se cTpDf = "M" ou "P"
					(tTabCTRC)->GXG_TPDF := "7"
					(tTabCTRC)->GXG_CDTPSE  := aDados[nISX5][4]
					Exit
				EndIf
			Next nISX5
		EndIf
		GFELog115:Add("> Tp Doc. Frete: " + (tTabCTRC)->GXG_TPDF, 1)
		
		If s_GFEA1158
			ExecBlock("GFEA1158",.f.,.f.,{(tTabCTRC),cBuffer})
		EndIf
		MsUnLock((tTabCTRC))

		//-------------------------------------------------------
		// Fim gravação tabela temporária GXG (EDI - Documento de Frete)
		//-------------------------------------------------------

		nContNF := 0
		lFlag := .T.

		//-------------------------------------------------------
		// NOTAS COMPONENTES DO CONHECIMENTO
		// ATÉ 40 OCORRÊNCIAS DE DADOS DE NOTAS
		//-------------------------------------------------------

		GFELog115:Add("- Buscando Notas Relacionadas")
		GFELog115:Save()

		If cModoGXG == "E"
			cFilialCTRC := cFilAnt
			GFELog115:AddDebug("# Filial em modo Exclusivo. Filial " + cFilAnt, 1)
		Else
			cFilialCTRC := ""
		EndIf
					
		While nContNF < 40 .And. lFlag
			
			cNumeroNF := SubStr(cBuffer, 236 + (nContNF * 11), 08)
			cSerieNF  := SubStr(cBuffer, 233 + (nContNF * 11), 03)
			cFilialDC := PadR(AllTrim(cFilialCTRC), TamSX3("GW1_FILIAL")[1])
			cSerieDC  := PadR(cSerieNF, __nTamSrDC)

			GFELog115:Add("# " + ALLTRIM(STR(nContNF + 1)) + " " + Replicate("-", 20), 1)
			GFELog115:Add("> Série   NF: " + cSerieNF,  2)
			GFELog115:Add("> Número  NF: " + cNumeroNF, 2)

			If cNumeroNF != Replicate(" ", 8) .And. cNumeroNF != Replicate("0", 8)
				
				oDocTrecho['ACHOU_DOC'] := .F.

				// Remove os zeros à esquerda do número da NF
				cNumeroNF := GFEZapZero(AllTrim(cNumeroNF))
				//--------------------------------------------------------------------------
				// Regra para buscar o número da nota fiscal no GFE:
				// Inicia a busca a partir do número sem zeros à esquerda e enquanto
				// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
				//--------------------------------------------------------------------------
				aPesqDoc[1] := cEmissorDc
				aPesqDoc[2] := cSerieDC
				aPesqDoc[3] := cFilialCTRC
				aPesqDoc[4] := ""
				aPesqDoc[5] := {}
				aPesqDoc[6] := cCNPJTransp

				For nI := Len(cNumeroNF) To __nTamNrDC
					cNumeroDC := PadL(cNumeroNF, nI, "0")
					AAdd(aPesqDoc[5], cNumeroDC )
				Next

				GFELog115:AddDebug("# Pesquisando os Documentos de Carga do Emitente... ", 1)
				FindDocTrechoPago(aPesqDoc, @oDocTrecho)

				ASize(aPesqDoc[5], 0)

				If oDocTrecho['ACHOU_DOC']
					cTpDc      := oDocTrecho['GW1_CDTPDC']
					cFilialDC  := oDocTrecho['GW1_FILIAL']
					cSerieDC   := oDocTrecho['GW1_SERDC']
					cNumeroDc  := oDocTrecho['GW1_NRDC']
					cEmissorDc := oDocTrecho['GW1_EMISDC']
				EndIf

				GFELog115:Add("> Filial  DC: " + cFilialDC	, 2)
				GFELog115:Add("> Tipo    DC: " + cTpDc 		, 2)
				GFELog115:Add("> Série   DC: " + cSerieDC   	, 2)
				GFELog115:Add("> Número  DC: " + Iif(oDocTrecho['ACHOU_DOC'], cNumeroDc, cNumeroNF), 2)
				GFELog115:Add("> Emissor DC: " + cEmissorDc 	, 2)

				RecLock((tTabNF), .T.)
				(tTabNF)->GXH_FILIAL := (tTabCTRC)->GXG_FILIAL
				(tTabNF)->GXH_NRIMP  := ALLTRIM(STR(nNRIMP))
				(tTabNF)->GXH_SERDC  := cSerieDC
				(tTabNF)->GXH_NRDC 	 := cNumeroDc
				(tTabNF)->GXH_EMISDC := cEmissorDc
				(tTabNF)->GXH_SEQ 	 := PADL(Alltrim(Transform((nContNF + 1 + nPlus), '@R 99999')),5,"0")
				(tTabNF)->GXH_FILDC	 := cFilialDC
				(tTabNF)->GXH_TPDC   := cTpDc
				(tTabNF)->GXH_CNPJEM := cCNPJEmbarc
				
				// Verifica se a nota já existe e busca o Tipo de Documento de Carga
				dbSelectArea("GW1")
				GW1->( dbSetOrder(1) )
				If GW1->(dbSeek(cFilialDC + cTpDc + cEmissorDc + oDocTrecho['GW1_SERDC'] + cNumeroDc))

					GFELog115:Add("> Tipo DC....: " + (tTabNF)->GXH_TPDC, 2)
					GFELog115:Add("> Emissor....: " + (tTabNF)->GXH_EMISDC, 2)
					GFELog115:Add("> RecNo......: " + cValToChar(GW1->( RecNo() )) , 2)

					If cEmissorDc != oDocTrecho['GW1_EMISDC']
						GFELog115:Add("** " + "Emissor do documento de carga diferente do emissor do arquivo.", 2)
						cMsgPreVal += "- " + "Emissor do documento de carga diferente do emissor do arquivo." + CRLF
					EndIf
				Else
					lTodosDC := .F.
					// Início Ponto de Entrada Procomp
					If s_GFEA1151   
						lTodosDC := ExecBlock("GFEA1151",.f.,.f.,{})
					EndIf
					// Fim Ponto de Entrada Procomp
					If !lTodosDC
						cMsgPreVal += "- Documento de Carga não encontrado. Filial: " + cFilialDC + ", Ser: " + cSerieDC + ", Nr: "+ cNumeroDc + CRLF
						GFELog115:Add("** Documento de Carga não encontrado.", 1)
					EndIf
				EndIf
				MsUnLock((tTabNF))

			Else /* If cNumeroNF == "        "	.Or. cNumeroNF == "00000000" */
				GFELog115:Add("** Número da Nota Fiscal em branco ou zerado.", 2)
				lFlag := .F.
			EndIf

			nContNF := nContNF + 1

			If nContNF == 40 .And. cIdCont == "C"
				GFEFile:FNext()
				cNextBuff := GFEFile:Line()

				If SubStr(cNextBuff, 1, 235) == SubStr(cBuffer, 1, 235)
					cIdCont  := SubStr(cNextBuff, 675, 1)
					nPlus   += nContNF
					nContNF   := 0
					cBuffer := cNextBuff
				Else
					GFEFile:FPrior()
				EndIf
			EndIf

			GFELog115:Save()
		EndDo
		
		GFELog115:AddDebug("# Pesquisa de Notas Relacionadas concluída... Horário: " + Time(), 1)

		//Se não for possível encontrar algum dos documentos de carga
		//deve limpar o código da espécie, pois só assim será possível
		//reprocessar a importação
		If !lTodosDC
			RecLock((tTabCTRC))
			(tTabCTRC)->GXG_CDESP := ""
			(tTabCTRC)->(MsUnlock())
			lTodosDC := .T.
		EndIf

		//-------------------------------------------------------
		// Notas relacionadas - Fim
		//-------------------------------------------------------

		PreValGXG(cMsgPreVal)

	   	GFEFile:FNext()
	   	lSelecao := .T.
	EndDo	// Fim do processamento do arquivo

	aSize(aGXG, 0)
	aSize(aPesqDoc, 0)
	FreeObj(oDocTrecho)

	GFELog115:NewLine()
	GFELog115:AddDebug("Fim do processamento do arquivo. Horário: " + Time())

	GFELog115:NewLine()
	GFELog115:Add("Total de conhecimentos deste arquivo " + cValToChar(nCountCTRCArq) )
Return

//-------------------------------------------------------------------
// Esta função deverá ser descontinuada. Originalmente foi desenvolvida
// para executar o mesmo trabalho que a função padrão do framework
// PADL já realiza. Mantida apenas por compatibilidade, visto que é
// utilizada por outros programas.
//-------------------------------------------------------------------
Function GFEFrNrDC(cDc, nFrmt)
Local cNrFrmt := AllTrim(cDc)

	If nFrmt > Len(cNrFrmt)

		cNrFrmt := PadL(cNrFrmt, nFrmt, "0")

	EndIf

	cNrFrmt := PadR(cNrFrmt, __nTamNrDC)

Return cNrFrmt

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115BF()

Busca o Codigo da Filial atraves do CGC da filial

@author Felipe Rafael Mendes
@since 18/06/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA115BF(cCGC, lFil, cFilDoc)
	Local cCodFilial  := "  "
	Local aArea		  := GetArea()
	Local aAreaSM0 	  := SM0->( GetArea() )
	Local cEmpresa 	  := FWGrpCompany()
	Local lCompTab    := FWModeAccess("GXG",1) == "E" .AND. FWModeAccess("GXH",1) == "E"
	Local lFilial     := FWCodFil() == cFilDoc
	Local lTotvsColab := IsInCallStack("SCHEDCOMCOL")
	Default lFil	  := .T.
	Default cFilDoc	  := ''

	dbSelectArea("SM0")
	SM0->( dbGoTop() )

	While !SM0->( Eof() )

		If AllTrim(cCGC) == AllTrim(SM0->M0_CGC) .And. AllTrim(cEmpresa) == AllTrim(SM0->M0_CODIGO)
			/*Se lFilDoc não for passado como parâmetro, retorna o primeiro código de empresa com o 
			  CNPJ informado.
			  Se for informado, deve haver SM0 com mesmo CNPJ e código de filial.
			  Essa situação serve para empresas que possuem mais de uma filial com o mesmo CNPJ,
			  e há consistência de filiais entre documentos (de carga e de frete)*/
			If Empty(cFilDoc)
				cCodFilial := FWCodFil()
				Exit
			Else
				If (lCompTab .AND. lFilial) .OR. (!lCompTab .AND. !lFilial) .Or. (lTotvsColab .And. (aGXG[38] != nil .And. cFilDoc != aGXG[38]))
					cCodFilial := cFilDoc
				Else
					cCodFilial := FWCodFil()
				EndIf
			EndIf
		EndIf

		SM0->( dbSkip() )
	EndDo

	RestArea( aAreaSM0 )
	RestArea( aArea )
	If lFil
		If Empty(cCodFilial)
			cCodFilial := FWCodFil()
		EndIf
	EndIf
Return cCodFilial

/* ======================================================================================================================= */

//-------------------------------------------------------------------
/*/{Protheus.doc} Processamento
Rotina para processar os conhecimentos importados.
Uso Interno

@author Felipe Rafael Mendes
@since 17/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processamento(cOrigem)
	Local lRet
	Local lRetGW4 			:= .F.
	Local nCount 			:= 0
	Local nTotal 			:= 0
	Local lProc  			:= .F.
	Local lOk    			:= .F.
	Local oModelGW4         := Nil
	Local nCountDC			:= 0
	Local lDCUsoCons		:= .F.
	Local cCredPC
	Local aAreaGW1 			:= GW1->( GetArea() )
	LoCAL aRet              := {}
	Local cLogOption		:= SuperGetMV('MV_GFEEDIL',,'1')
	Local cFilTemp 			:= cFilAnt
	Local nCountZerosNF 	:= 0
	Local lNrDf				:= .F.
	Local cNumeroNF     	:= ""  	// Numero da Nota Fiscal do arquivo
	Local cNRDF				:= ""
	Local lMsgErr 			:= .F.
	Local cCont				:= 0
	Local cContDel 			:= 0
	Local cNum 				:= ""
	Local cSer 				:= ""
	Local cEmi 				:= ""
	Local lSchedule			:= IsBlind()
	Local cNumDFRed 		:= ""
	Local cGXGPro 			:= GetNextAlias()
	Local cLock 			:= ''
	Local cLockTime
	Local aDcChave 			:= {}
	Local nPosDcEsc 		:= 0
	Local nX				:= 0
	Local aErroLinha 		:= {}
	Local lPriErro
	Local cMsgErro			:= ''
	Local lValDC 			:= .F.
	Local cFilAtu 			:= cFilAnt
	Local s_GFEA1151 		:= ExistBlock("GFEA1151")
	Local s_GFEA1154 		:= ExistBlock("GFEA1154")
	Local s_GFEA1155 		:= ExistBlock("GFEA1155")
	Local s_GFEA1157 		:= ExistBlock("GFEA1157")
	Local s_GFEA1159 		:= ExistBlock("GFEA1159")	
	Local s_GFE11501		:= ExistBlock("GFE11501")
	Local s_GFECRIC  		:= SuperGetMv("MV_GFECRIC", .F., "1", GXG->GXG_FILDOC)
	Local cEDImsg			:= ""
	Local c115ALock			:= ""
	Local lFilExc    		:= "E" $ FWModeAccess("GXG",1) + FWModeAccess("GXG",2) + FWModeAccess("GXG",3)
	Local cLstFil    		:= ""
	Local nIbs				:= 0
	Local nCbs				:= 0 
	
	// Início Ponto de Entrada Procomp
 	If s_GFEA1151   
	    lValDC := ExecBlock("GFEA1151",.f.,.f.,{})
 	EndIf
	// Fim Ponto de Entrada Procomp	
	
	Private GFELog115		:= GFELog():New("EDI_Conemb_Processamento", "EDI Conemb - Processamento", cLogOption)
	Private lRetMsg 		:= .F.
	Private lRetRedes		:= .F.
	Private nContMsg		:= 0

	Default cOrigem 		:= "1"
	
	GFEA517SVW(.F.) // Para que não exiba a tela de seleção

	If !lSchedule
		ProcRegua(0)
	EndIf

	cQuery := "SELECT GXG.GXG_NRIMP, R_E_C_N_O_ FROM " + RetSQLName("GXG") + " GXG "
	cQuery += " WHERE "
	If lSchedule // Se estiver sendo executado por Schedule, verifica se é diferente de processado com sucesso
		If lFilExc .And. FwIsInCallStack("GFEA118SCH")
			cQuery += " GXG.GXG_FILIAL = '" + FwxFilial("GXG") + "' AND "
		EndIf

		cQuery += " GXG.GXG_EDISIT != '4'"
	Else // se for manual, somente os diferente de 4 e marcados para serem processados.
		
		//-- se houver algum nível de compartilhamento, valida filiais válidas (por alias)
		If lFilExc
			oFilUser:= GFEFilialPermissaoUsuario():New()
        	oFilUser:MontaFilUsr()
        	cLstFil := oFilUser:getFilSQLIn("GXG")
        	oFilUser:Destroy(oFilUser)

			cQuery += " GXG.GXG_FILIAL IN (" + cLstFil + ") AND "
		//-- se não houver algum nível de compartilhamento filial em branco
		Else
			cQuery += " GXG.GXG_FILIAL = '" + FwxFilial("GXG") + "' AND "
		EndIf
		cQuery += " (GXG.GXG_EDISIT != '4' AND GXG.GXG_MARKBR = '" + oBrowse115:Mark() + "' )"
	EndIf
	cQuery += " AND GXG.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGXGPro, .F., .T.)

	dbSelectArea(cGXGPro)
	(cGXGPro)->(dbGoTop())

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	oModel    := FWLoadModel("GFEA065")
	oModelGW4 := oModel:getModel("GFEA065_GW4")

	While !(cGXGPro)->( Eof() )
		c115ALock := "GFEA115A_" + cValToChar((cGXGPro)->GXG_NRIMP)

    	If LockByName(c115ALock, .F., .F.)
      		GXG->(DBGoTo((cGXGPro)->R_E_C_N_O_) )
			
		    RecLock("GXG",.F.)
				GXG->GXG_EDIMSG := ""
			MsUnLock("GXG")
	
			// CHAVE DE TRAVA DO DOCUMENTO DE FRETE,
			cLock := 'GFE_DOCFRETE_' +	AllTrim(GXG->GXG_FILDOC) + ;
										AllTrim(GXG->GXG_CDESP)  + ;
										ALLTRIM(GXG->GXG_EMISDF) + ;
										ALLTRIM(GXG->GXG_SERDF)  + ;
										ALLTRIM(GXG->GXG_NRDF)   + ;
										ALLTRIM(DTOS(GXG->GXG_DTEMIS))
	
			ClearGlbValue('GFE_DOCFRETE_*', 20) //Limpa todas as variáveis criadas por esta rotina que foram acessadas pela última vez há mais de 20s.
	
			cLockTime := GetGlbValue(cLock)
			If Vazio(cLockTime) .Or. Val(GFENow(.T.,,'','','')) - Val(cLockTime) > 10000
				PutGlbValue(cLock, GFENow(.T.,,'','',''))
				GFELog115:Add(GFENOW(.F.,,,':','.') + ' - Criação de variável de controle de processamento. Chave:' + cLock + '.')
			Else
				//2 de 2 pontos desta função em que o log é encerrado e retorna sem continuar até o fim da função.
				GFELog115:Add(GFENOW(.F.,,,':','.') + ' - Chave ' + cLock + ' em processamento por outro usuário.')
				GFELog115:Save()
				
				UnLockByName(c115ALock, .F., .F.)
				(cGXGPro)->( dbSkip() )
				Loop
			EndIf
	
			lProc := .T.
			lDCUsoCons := .F.
			lRet := .T.
			nTotal++
	
			GFELog115:Add("[" + cValToChar(nTotal) + "] Processando registro: " + cValToChar(GXG->GXG_NRIMP))
			GFELog115:Add("> Filial.: " + GXG->GXG_FILDOC, 1)
			GFELog115:Add("> Espécie: " + GXG->GXG_CDESP, 1)
			GFELog115:Add("> Emissor: " + GXG->GXG_EMISDF, 1)
			GFELog115:Add("> Série..: " + GXG->GXG_SERDF, 1)
			GFELog115:Add("> Número.: " + GXG->GXG_NRDF, 1)
			GFELog115:Add("> Dt.Emis: " + DTOS(GXG->GXG_DTEMIS), 1)
			GFELog115:Save()
	
			/*
			4) GFEA115A; na função de processamento os registros com GXG_EDISIT = 5 não poderão ser processados. 
			*/
			If GXG->GXG_EDISIT == '5'
				GFELog115:Add("** " + "Registros com a situação '5' (Erro Impeditivo) não podem ser processados.", 1)
				GFELog115:Save()
				
				If !('Erro Impeditivo' $ GXG->GXG_EDIMSG)
					RecLock("GXG",.F.)
						GXG->GXG_EDIMSG := GXG->GXG_EDIMSG + "- " + "Registros com a situação '5' (Erro Impeditivo) não podem ser processados."
					MsUnLock("GXG")
				EndIf
				
				UnLockByName(c115ALock, .F., .F.)
				(cGXGPro)->( dbSkip() )
				Loop
			EndIf
	
			If GXG->GXG_ACAO != "E"
				If !(Len(alltrim(str(GXG->GXG_FRPESO))) < (TamSX3("GW3_FRPESO")[1]))
					RecLock("GXG",.F.)
						GXG->GXG_EDIMSG := "** Valor do campo Frete Peso do arquivo incompativel com o tamanho Frete Peso do Documento de Frete"
						GXG->GXG_EDISIT := '3'
					GXG->(MsUnlock())
					
					GFELog115:Add("** Valor do campo Frete Peso do arquivo incompativel com o tamanho Frete Peso do Documento de Frete", 2)
					GFELog115:Save()
						
					UnLockByName(c115ALock, .F., .F.)
					(cGXGPro)->( dbSkip() )
					Loop
				EndIf
				
				// Verifica se o conhecimento já está cadastrado
				dbSelectArea("GW3")
				dbSetOrder(1)
				If dbSeek(PadR(GXG->GXG_FILDOC, TamSX3("GW3_FILIAL")[1]) + ;
						  PadR(GXG->GXG_CDESP,  TamSX3("GW3_CDESP")[1])  + ;
						  PadR(GXG->GXG_EMISDF, TamSX3("GW3_EMISDF")[1]) + ;
	  					  PadR(GXG->GXG_SERDF,  TamSX3("GW3_SERDF")[1])  + ;
						  PadR(GXG->GXG_NRDF,   TamSX3("GW3_NRDF")[1])   + ;
						  DTOS(GXG->GXG_DTEMIS))
					
					If GXG->GXG_ORIGEM != "2" .Or. ( Empty(GXG->GXG_ORINR) .And. Empty(GXG->GXG_ORISER))
						GFELog115:Add("** " + "Conhecimento já cadastrado.", 1)
						GFELog115:Save()
						
						RecLock("GXG",.F.)
				        	GXG->GXG_EDIMSG := "- " + "Conhecimento já cadastrado."
							GXG->GXG_EDISIT := '3'
						GXG->(MsUnlock())
					Else
						GFELog115:Add("** " + "Não é possível importar documento de frete substituto " +;
											  "pois o documento de frete substituído ainda existe na base. " +;
											  "Filial Docto: " + AllTrim(GXG->GXG_FILDOC) +;
											  " Especie Docto: " + AllTrim(GXG->GXG_CDESP) +;
											  " Emis Docto: " + AllTrim(GXG->GXG_EMISDF) +;
											  " Serie Docto: " + AllTrim(GXG->GXG_SERDF) +;
											  " Nr Docto: X." + AllTrim(GXG->GXG_NRDF), 1)
						GFELog115:Save()
	
			        	RecLock("GXG",.F.)
				        	GXG->GXG_EDIMSG := "- " + "Não é possível importar documento de frete substituto " +;
												  "pois o documento de frete substituído ainda existe na base. " +;
												  "Filial Docto: " + AllTrim(GXG->GXG_FILDOC) +;
												  " Especie Docto: " + AllTrim(GXG->GXG_CDESP) +;
												  " Emis Docto: " + AllTrim(GXG->GXG_EMISDF) +;
												  " Serie Docto: " + AllTrim(GXG->GXG_SERDF) +;
												  " Nr Docto: X." + AllTrim(GXG->GXG_NRDF)
				            GXG->GXG_EDISIT := '3'
				        GXG->(MsUnlock())
					EndIf
					//MsUnLock("GXG")
			    	dbSelectArea('GXG')
			    	
			    	UnLockByName(c115ALock, .F., .F.)
			    	(cGXGPro)->( dbSkip() )
					Loop
				EndIf
			EndIf
			
			If s_GFE11501
				aRet := ExecBlock("GFE11501",.F.,.F.,)
				If ValType(aRet) == "A" .and. !Empty(aRet) 
					If aRet[1]
						GFELog115:Add(aRet[2], 1)
						RecLock("GXG",.F.)
						GXG->GXG_EDIMSG := aRet[2]
						GXG->GXG_EDISIT := '3'
						MsUnLock("GXG")	
							
						UnLockByName(c115ALock, .F., .F.)
						(cGXGPro)->( dbSkip() )
						Loop		
					EndIf								
				EndIf
			EndIf

			// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
			If GXG->GXG_ACAO == "E"
				dbSelectArea("GVT")
				aGVTStruct := GVT->( dbStruct() )
	
			 	//Número do Documento de Frete
			 	cNRDF := GXG->GXG_NRDF
	
				If AScan(aGVTStruct, {|x| x[1] == "GVT_FORMNM"}) != 0
	
					dbSelectArea("GVT")
					GVT->( dbSetOrder(1) )
					If GVT->( dbSeek(xFilial("GVT") + GXG->GXG_CDESP) )
	
						If GVT->GVT_ZEROS == "2"
							cNRDF := GFEZapZero(AllTrim(GXG->GXG_NRDF))
						ElseIf GVT->GVT_ZEROS == "3"
							cNRDF := PadL(AllTrim(GFEZapZero(GXG->GXG_NRDF)), IIf(GVT->GVT_QTALG == 0, TamSX3("GW3_NRDF")[1], GVT->GVT_QTALG), "0")
						EndIf
	
						If Len(AllTrim(cNRDF)) > GVT->GVT_QTALG .And. GVT->GVT_QTALG != 0
							GFELog115:Add("** " + "A quantidade de caracteres no Número do Documento de Frete ultrapassa o delimitado no cadastro da Espécie.", 1)
							GFELog115:Save()
							dbSelectArea('GXG')
							
							UnLockByName(c115ALock, .F., .F.)
				    		(cGXGPro)->( dbSkip() )
							Loop
						EndIf
	
						If GVT->GVT_FORMNM == "1" .And. !GFEVldFor1(AllTrim(cNRDF), "IsDigit")
							GFELog115:Add("** " + "O Número do Documento de Frete deve possuir apenas algarismos conforme parametrizado no cadastro da Espécie.", 1)
							GFELog115:Save()
							dbSelectArea('GXG')
							
							UnLockByName(c115ALock, .F., .F.)
				    		(cGXGPro)->( dbSkip() )
							Loop
						ElseIf GVT->GVT_FORMNM == "2" .And. !GFEVldFor1(AllTrim(cNRDF), "LetterOrNum")
							GFELog115:Add("** " + "O Número do Documento de Frete deve possuir apenas algarismos ou letras conforme parametrizado no cadastro da Espécie.", 1)
							GFELog115:Save()
				    		dbSelectArea('GXG')
				    		
				    		UnLockByName(c115ALock, .F., .F.)
				    		(cGXGPro)->( dbSkip() )
							Loop
						EndIf
					Else
						cEsp := GXG->GXG_CDESP
						GFELog115:Add("** " + cEsp + "- Espécie não encontrada para o documento.", 1)
						GFELog115:Save()
				    	dbSelectArea('GXG')
				    	
				    	UnLockByName(c115ALock, .F., .F.)
				    	(cGXGPro)->( dbSkip() )
						Loop
	
					EndIf
	
					dbSelectArea("GW3")
					dbSetOrder(1)
					If dbSeek(PadR(GXG->GXG_FILDOC, TamSX3("GW3_FILIAL")[1]) + ;
							  PadR(GXG->GXG_CDESP,  TamSX3("GW3_CDESP")[1])  + ;
							  PadR(GXG->GXG_EMISDF, TamSX3("GW3_EMISDF")[1]) + ;
							  PadR(GXG->GXG_SERDF,  TamSX3("GW3_SERDF")[1])  + ;
							  PadR(cNRDF,           TamSX3("GW3_NRDF")[1])   + ;
							  DTOS(GXG->GXG_DTEMIS))
						GFELog115:Add("** Documento de Frete" + PadR(cNRDF,TamSX3("GW3_NRDF")[1]) + " - Encontrado para exclusão.", 1)
					Else
						GFELog115:Add("** Documento de Frete" + PadR(cNRDF,TamSX3("GW3_NRDF")[1]) + " - Não encontrado para exclusão.", 1)
						RecLock("GXG",.F.)
				  		GXG->GXG_EDIMSG := STR0006 //"Não foi encontrado o Documento de Frete para ser excluído."
				        GXG->GXG_EDISIT := '3'
						MsUnLock("GXG")
						
						UnLockByName(c115ALock, .F., .F.)
						(cGXGPro)->( dbSkip() )
						Loop
					EndIf
	
				EndIf
	
				// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
				GFELog115:Add("> Exclusão")
				oModel:SetOperation( 5 )
			Else
				oModel:SetOperation( 3 )
			EndIf
	
			// Antes de atribuirmos os valores dos campos temos que ativar o modelo
			DbSelectArea('GXH')
			GXH->( dbSetOrder(1) )
			GXH->( dbSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP) )
			If !empty(GXH->GXH_FILDC) .And. GXH->GXH_FILDC == GXG->GXG_FILDOC 
				cFilAnt := GXH->GXH_FILDC
				RecLock("GXG",.F.)
					GXG->GXG_FILDOC := cFilAnt
				MsUnLock("GXG")
			Else
				cFilAnt := GXG->GXG_FILDOC
			Endif
			oModel:Activate()
	
			If GXG->GXG_ACAO != "E"
	
				//Quando a rotina é chamada via Schedule não se sabe se a origem
				//é EDI ou CT-e, por isso deve verificar a GXG_ORIGEM
				If !lSchedule .And. GXG->GXG_ORIGEM == '2'
					cOrigem := '3'
				EndIf
	
				GXH->( dbSetOrder(1) )
				GXH->( dbSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP) )
				If Empty(GXH->GXH_TPDC)
					ReprocessDoctoCarga(GXG->GXG_FILIAL, GXG->GXG_NRIMP)
				EndIf
	
				// Carrega os dados do documento de frete no model
				oModel:SetValue("GFEA065_GW3",'GW3_CDESP'  ,ALLTRIM(GXG->GXG_CDESP ) )
				IF !oModel:SetValue("GFEA065_GW3",'GW3_EMISDF' ,ALLTRIM(GXG->GXG_EMISDF) )
	
					cMsgErro := GU3Valid(GXG->GXG_EMISDF, 'Campo GXG_EMISDF: ')
					RecLock("GXG",.F.)
					GFELog115:NewLine()
					GFELog115:Add( cMsgErro )
		
		           	GXG->GXG_EDIMSG := cMsgErro
		           	GXG->GXG_EDISIT := '3'
					MsUnLock("GXG")
		
					lRet := .F.
				EndIf

				oModel:SetValue("GFEA065_GW3",'GW3_SERDF'  ,ALLTRIM(GXG->GXG_SERDF) )
				oModel:SetValue("GFEA065_GW3",'GW3_NRDF'   ,ALLTRIM(GXG->GXG_NRDF)  )
				oModel:SetValue("GFEA065_GW3",'GW3_DTEMIS' ,GXG->GXG_DTEMIS )
				oModel:SetValue("GFEA065_GW3",'GW3_DTENT ' ,DDATABASE   )
				IF !oModel:SetValue("GFEA065_GW3",'GW3_CDREM'  ,ALLTRIM(GXG->GXG_CDREM))
					cMsgErro := GU3Valid(GXG->GXG_CDREM, 'Campo GXG_CDREM: ')
					RecLock("GXG",.F.)
					GFELog115:NewLine()
					GFELog115:Add( cMsgErro )
		
		           	GXG->GXG_EDIMSG := cMsgErro
		           	GXG->GXG_EDISIT := '3'
					MsUnLock("GXG")
		
					lRet := .F.
				EndIf

				If !oModel:SetValue("GFEA065_GW3",'GW3_CDDEST' ,ALLTRIM(GXG->GXG_CDDEST) )
					cMsgErro := GU3Valid(GXG->GXG_CDDEST, 'Campo GXG_CDDEST: ')
					RecLock("GXG",.F.)
					GFELog115:NewLine()
					GFELog115:Add( cMsgErro )
		
		           	GXG->GXG_EDIMSG := cMsgErro
		           	GXG->GXG_EDISIT := '3'
					MsUnLock("GXG")
		
					lRet := .F.
				EndIf

				oModel:SetValue("GFEA065_GW3",'GW3_TPDF'   ,ALLTRIM(GXG->GXG_TPDF) )
				oModel:SetValue("GFEA065_GW3",'GW3_PESOR'  ,GXG->GXG_PESOR  )
				oModel:SetValue("GFEA065_GW3",'GW3_PESOC'  ,GXG->GXG_PESOC  )
				oModel:SetValue("GFEA065_GW3",'GW3_FRPESO' ,GXG->GXG_FRPESO )
				oModel:SetValue("GFEA065_GW3",'GW3_FRVAL'  ,GXG->GXG_FRVAL  )
				oModel:SetValue("GFEA065_GW3",'GW3_TAXAS'  ,GXG->GXG_TAXAS  )
				oModel:SetValue("GFEA065_GW3",'GW3_PEDAG'  ,GXG->GXG_PEDAG  )
				oModel:SetValue("GFEA065_GW3",'GW3_VLDF'   ,GXG->GXG_VLDF   )
				oModel:SetValue("GFEA065_GW3",'GW3_CFOP'   ,GXG->GXG_CFOP)
				oModel:SetValue("GFEA065_GW3",'GW3_ORIGEM' ,cOrigem)
				oModel:SetValue("GFEA065_GW3",'GW3_QTDCS'  ,GXG->GXG_QTDCS)
				oModel:SetValue("GFEA065_GW3",'GW3_VOLUM'  ,GXG->GXG_VOLUM)
				oModel:SetValue("GFEA065_GW3",'GW3_VLCARG' ,GXG->GXG_VLCARG)
				oModel:SetValue("GFEA065_GW3",'GW3_QTVOL'  ,GXG->GXG_QTVOL)
				If GXG->GXG_TPDF == '7' .And. GFXCP12117("GXG_CDTPSE")
					oModel:SetValue("GFEA065_GW3",'GW3_CDTPSE' ,GXG->GXG_CDTPSE )
				EndIf
	
				If GXG->GXG_TPDF != '3' .And. Abs(GXG->GXG_BASIMP - GXG->GXG_VLDF) > GXG->GXG_PEDAG .And. GXG->GXG_TRBIMP == "1"
					oModel:LoadValue("GFEA065_GW3",'GW3_TRBIMP',"5")
				Else
					oModel:LoadValue("GFEA065_GW3",'GW3_TRBIMP',GXG->GXG_TRBIMP )
				EndIf

				If GXG->GXG_PEDAG > 0 .And. GXG->GXG_VLDF == GXG->GXG_BASIMP                    				
					oModel:LoadValue("GFEA065_GW3",'GW3_ICMPDG',"1")   //Pedágio está na base do ICMS
				ElseIf GXG->GXG_PEDAG > 0 .And. Abs(GXG->GXG_BASIMP - GXG->GXG_VLDF) >= GXG->GXG_PEDAG  //Pedágio NÃO está na base do ICMS
					oModel:LoadValue("GFEA065_GW3",'GW3_ICMPDG',"2")
				EndIf
	
				oModel:LoadValue("GFEA065_GW3",'GW3_PCIMP' ,GXG->GXG_PCIMP  )
				oModel:LoadValue("GFEA065_GW3",'GW3_BASIMP',GXG->GXG_BASIMP )
				oModel:LoadValue("GFEA065_GW3",'GW3_VLIMP' ,GXG->GXG_VLIMP )
	
				oModel:LoadValue("GFEA065_GW3",'GW3_IMPRET',GXG->GXG_IMPRET )
				oModel:LoadValue("GFEA065_GW3",'GW3_PCRET',GXG->GXG_PCRET )
	
				oModel:SetValue("GFEA065_GW3",'GW3_ORINR' ,ALLTRIM(GXG->GXG_ORINR ) )
				oModel:SetValue("GFEA065_GW3",'GW3_ORISER',ALLTRIM(GXG->GXG_ORISER) )
				oModel:LoadValue("GFEA065_GW3",'GW3_CTE'  ,AllTrim(GXG->GXG_CTE) )
				oModel:SetValue("GFEA065_GW3",'GW3_OBS' ,ALLTRIM(GXG->GXG_OBS ) )

				If GFXCP12137('GXG_FILTOM') .And. GFXCP12137('GW3_FILTOM')
					oModel:SetValue("GFEA065_GW3",'GW3_FILTOM', ALLTRIM(GXG->GXG_FILTOM))
				EndIf

				If GFXCP12131("GXG_MUNINI")
					oModel:SetValue("GFEA065_GW3",'GW3_MUNINI' ,ALLTRIM(GXG->GXG_MUNINI) )
					oModel:SetValue("GFEA065_GW3",'GW3_UFINI' ,ALLTRIM(GXG->GXG_UFINI) )
					oModel:SetValue("GFEA065_GW3",'GW3_MUNFIM' ,ALLTRIM(GXG->GXG_MUNFIM) )
					oModel:SetValue("GFEA065_GW3",'GW3_UFFIM' ,ALLTRIM(GXG->GXG_UFFIM) )
				EndIf

				If GFXCP2510("GXG_XMLTRB")
					oModel:SetValue("GFEA065_GW3",'GW3_XMLTRB' ,ALLTRIM(GXG->GXG_XMLTRB) )
				EndIf

				If GFXCP2510("GW3_BASIBS")
					aImp := GFEImpXML(AllTrim(GXG->GXG_XMLTRB))

					nIbs := aScan(aImp, {|x| x[1] == "IBSUF"})
					If nIbs == 0
						nIbs := aScan(aImp, {|x| x[1] == "IBSMUN"})
					EndIf

					nCbs := aScan(aImp, {|x| x[1] == "CBS"})

					If nIbs > 0
						oModel:SetValue("GFEA065_GW3",'GW3_BASIBS', aImp[nIbs][3])
						oModel:SetValue("GFEA065_GW3",'GW3_PCIBS', aImp[nIbs][4])
						oModel:SetValue("GFEA065_GW3",'GW3_VLIBS', aImp[nIbs][5])
					EndIf

					If nCbs > 0
						oModel:SetValue("GFEA065_GW3",'GW3_BASCBS', aImp[nCbs][3])
						oModel:SetValue("GFEA065_GW3",'GW3_PCCBS', aImp[nCbs][4])
						oModel:SetValue("GFEA065_GW3",'GW3_VLCBS', aImp[nCbs][5])
					EndIf
				EndIf

				If Empty(GXG->GXG_CTE)
					oModel:LoadValue("GFEA065_GW3",'GW3_TPCTE'   , " ")
				ElseIf !Empty(GXG->GXG_CTE) .and. (GXG->GXG_TPCTE)<> '0'
					oModel:LoadValue("GFEA065_GW3",'GW3_TPCTE'   ,AllTrim(GXG->GXG_TPCTE) )
				Else
					oModel:LoadValue("GFEA065_GW3",'GW3_TPCTE'   , "0")
				EndIf

				If GFXCP2510('GXG_CTESUB') .And. !Empty(GXG->GXG_CTESUB)
					oModel:LoadValue("GFEA065_GW3",'GW3_CTESUB'  ,AllTrim(GXG->GXG_CTESUB) )
				EndIf
				// Início Ponto de Entrada Procomp
			 	If s_GFEA1157 
				    ExecBlock("GFEA1157",.f.,.f.,{oModel})
			 	EndIf
				// Fim Ponto de Entrada Procomp
	
				nCountDC := 0
				GFELog115:Add("  - Documentos de Cargas")

				GXH->( dbSetOrder(1) )
				GXH->( msSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP) )
				aErroLinha := {}
				While !GXH->(Eof()) .AND. ;
				       GXH->GXH_FILIAL == GXG->GXG_FILIAL .AND. ;
					   GXH->GXH_NRIMP  == GXG->GXG_NRIMP
	
					If GXH->GXH_FILDC != GXG->GXG_FILDOC
						RecLock("GXG",.F.)
						GFELog115:NewLine()
						GFELog115:Add("** " + " Filiais Diferentes entre Documento de Carga: " + GXH->GXH_FILDC + " e Documento de Frete:  " + GXG->GXG_FILDOC, 1)
				        GXG->GXG_EDIMSG := "** Filiais Diferentes entre Documento de Carga: " + GXH->GXH_FILDC + " e Documento de Frete:  " + GXG->GXG_FILDOC
				        GXG->GXG_EDISIT := '3'
						MsUnLock("GXG")
	
						lRet := .F.
						Exit
					EndIf
	

					nCountDC++
	
					GFELog115:Add(" #" + cValToChar(nCountDC) + " - Filial: " + GXH->GXH_FILDC + ", Emissor: " + GXH->GXH_EMISDC + ", Série: " + GXH->GXH_SERDC + ", Número: " + GXH->GXH_NRDC + ", Tipo DC: " + GXH->GXH_TPDC, 2)
	
					If nCountDC > 1
						oModelGW4:addLine()
					EndIf
	
					If !lDCUsoCons
						dbSelectArea("GW1")
						GW1->( dbSetOrder(If(__lCpoSr,15,1)) ) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
						If GW1->( dbSeek(GXH->GXH_FILDC + GXH->GXH_TPDC + GXH->GXH_EMISDC + PadR(GXH->GXH_SERDC,__nTamSrDC) + GXH->GXH_NRDC) )
							If __lCpoSr // Quando novo conceito de chave única, utiliza o último documento de carga
								While GW1->(!Eof()) .And. ;
								  	GW1->GW1_FILIAL == GXH->GXH_FILDC .And. ;
								  	GW1->GW1_CDTPDC == GXH->GXH_TPDC .And. ;
								  	GW1->GW1_EMISDC == GXH->GXH_EMISDC .And. ;
								  	GW1->GW1_SERDC == PadR(GXH->GXH_SERDC,__nTamSrDC) .And. ;
								  	GW1->GW1_NRDC == GXH->GXH_NRDC
									GW1->(dbSkip())
								EndDo
	
								GW1->(dbSkip(-1))
							EndIf
	
							If GW1->GW1_USO == "2"
								GFELog115:Add("# Uso e Consumo", 2)
								lDCUsoCons := .T.
							EndIf
						EndIf
					EndIf
	
						// Se o campo emissor estiver em branco, procura um documento de carga com a filial, serie e número
					If Empty(GXH->GXH_EMISDC)
						GFELog115:Add("** Emissor em branco", 2)
					EndIf
	
					If Empty(GXH->GXH_TPDC)
						GFELog115:Add("** Tipo de Documento de Carga em branco", 2)
					EndIf
	
					// Valida se o documento de carga existe
					//Considera documentos com ou sem zeros a esquerda
					nCountZerosNF := 0
					lNrDf := .F.
					dbSelectArea("GW1")
					dbSetOrder(If(__lCpoSr,15,1))
					While nCountZerosNF <= 6
						cNumeroNF := Replicate("0",nCountZerosNF) + GXH->GXH_NRDC
						If GW1->(dbSeek(GXH->GXH_FILDC + GXH->GXH_TPDC + GXH->GXH_EMISDC + PadR(GXH->GXH_SERDC,__nTamSrDC) + AllTrim(cNumeroNF)))
							lNrDf := .T.
							Exit
						EndIf
						nCountZerosNF++
					EndDo
	
	        		// Início Ponto de Entrada Procomp
				 	If s_GFEA1155   
						lNrDf := ExecBlock("GFEA1155",.f.,.f.,{lNrDf})
						If lNrDf 
							cNumeroNF := GXH->GXH_NRDC					    	
						EndIf
				 	EndIf
					// Fim Ponto de Entrada Procomp
				 	
				 	if !lNrDf // Não encontrou a NF
				 	
				 	    IF lValDC  //Não realiza validação do DF sem NF 
				 	    	oModelGW4:deleteLine()
				 		Else
							nCountDC--
							GFELog115:Add("** Documento de Carga não existe. Filial: " + GXH->GXH_FILDC + ", Tipo: " + GXH->GXH_TPDC + ", Emissor: " + GXH->GXH_EMISDC + ", Serie: " + GXH->GXH_SERDC + ", Nr: " + GXH->GXH_NRDC, 2)
							cNumeroNF := GXH->GXH_NRDC // evita o estouro de tamanho devido aos zeros do for			 		
				 		ENDIF
				 	EndIf			 				 					
					
					If lNrDf .or. !lValDC
						// Carrega os dados do documento de carga relacionado ao documetno de frete
						oModelGW4:SetValue('GW4_FILIAL', GXH->GXH_FILDC)
						oModelGW4:SetValue('GW4_EMISDF', GXG->GXG_EMISDF)
						oModelGW4:SetValue('GW4_CDESP ', GXG->GXG_CDESP )
						oModelGW4:SetValue('GW4_SERDF' , GXG->GXG_SERDF )
						oModelGW4:SetValue('GW4_NRDF'  , GXG->GXG_NRDF  )
						oModelGW4:SetValue('GW4_DTEMIS', GXG->GXG_DTEMIS)
								
						If __lCpoSr
							
							aDcChave := GFEA517SDC(PadR(cNumeroNF,Len(GW1->GW1_NRDC)), GXH->GXH_TPDC, GXH->GXH_EMISDC, GXH->GXH_SERDC)
							
							If Len(aDcChave) == 0
							
								oModelGW4:SetValue('GW4_EMISDC', GXH->GXH_EMISDC)
								If TamSX3("GW4_SERDC")[1] >= TamSX3("GXH_SERDC")[1]	// Verifica tamanhos para nao ocorrer erro ???
									oModelGW4:SetValue('GW4_SERDC' , GXH->GXH_SERDC )
								Else
									MsgInfo( "** O campo Série da tabela 'Doc. Carga dos Doc. Frete' está com o tamanho diferente do campo Série da tabela 'EDI - Doc. Carga do Doc. Frete'" )
								EndIf
								oModelGW4:SetValue('GW4_NRDC'  , Alltrim(cNumeroNF ))
								oModelGW4:SetValue('GW4_TPDC'  , GXH->GXH_TPDC  )
								
								If !oModelGW4:VldLineData()
									lRet := .F.
									aAdd(aErroLinha,oModel:GetErrorMessage())
									lRetGW4 := .T.
									Exit
								EndIf
								
							Else
								nPosDcEsc := 0
								
								oModelGW4:SetValue('GW4_TPDC'  , aDcChave[1,6])
								oModelGW4:SetValue('GW4_EMISDC', aDcChave[1,2])
								oModelGW4:SetValue('GW4_SERDC' , aDcChave[1,4] )
								oModelGW4:SetValue('GW4_NRDC'  , aDcChave[1,5] )
								
								If __lCpoSDoc
									oModelGW4:SetValue('GW4_SDOCDC', Transform(aDcChave[1,4], "!!!") )
								EndIf
								
								if !oModelGW4:VldLineData() == .T.
									lRet := .F.
									aAdd(aErroLinha,oModel:GetErrorMessage())
									lRetGW4 := .T.
									Exit
								EndIf			
							EndIf
						Else
							oModelGW4:SetValue('GW4_EMISDC', GXH->GXH_EMISDC)
							If TamSX3("GW4_SERDC")[1] >= TamSX3("GXH_SERDC")[1]	// Verifica tamanhos para nao ocorrer erro ???
								oModelGW4:SetValue('GW4_SERDC' , GXH->GXH_SERDC )
							Else
								MsgInfo( "** O campo Série da tabela 'Doc. Carga dos Doc. Frete' está com o tamanho diferente do campo Série da tabela 'EDI - Doc. Carga do Doc. Frete'" )
							EndIf
							oModelGW4:SetValue('GW4_NRDC'  , Alltrim(cNumeroNF ))
							oModelGW4:SetValue('GW4_TPDC'  , GXH->GXH_TPDC  )
							
							If !oModelGW4:VldLineData()
								lRet := .F.
								aAdd(aErroLinha,oModel:GetErrorMessage())
								lRetGW4 := .T.
								Exit
							EndIf
							
						EndIf				
					
					EndIf

					DbSelectArea('GXH')
					GXH->( dbSkip() )
			    EndDo
	
			    If !lRet .And. !lRetGW4
			    	(cGXGPro)->( dbSkip() )
			    	oModel:DeActivate()
			    	Loop
			    EndIf
	
			    If nCountDC == 0
			    	GFELog115:Add("** Nenhuma Nota Fiscal importada encontrada para este Documento de Frete. Filial: " + GXG->GXG_FILDOC + ", Seq. Import:" + GXG->GXG_NRIMP, 2)
			    EndIf
	
				GFELog115:Save()
	
				IF GXG->GXG_TPIMP == "1"
					// Crédito ICMS
					GFELog115:Add("# Verificando crédito ICMS.", 2)
					GFELog115:Add("> Parâmetro MV_GFECRIC: " + If(!Empty(GetNewPar("MV_GFECRIC", "1", cFilAnt)), GetNewPar("MV_GFECRIC", "1", cFilAnt), " < Parâmetro em branco >" ), 2)
					GFELog115:Add("> Tipo de tributação..: " + oModel:GetValue("GFEA065_GW3", "GW3_TRBIMP"), 2)
					GFELog115:Add("> Uso e Consumo.......: " + If(lDCUsoCons, "Sim", "Não"), 2)
					If s_GFECRIC == "2"	// Sem direito a crédito
						IF (!Empty(GXG->GXG_BASIMP))
							GFELog115:Add("- Tipo de tributação alterada para Outros (pelo parâmetro MV_GFECRIC)", 2)
							oModel:LoadValue("GFEA065_GW3", "GW3_TRBIMP", "6")	// Só muda para a tributação para Outros, se não tiver base de imposto.
							Endif
							EndIf
	
						If !lDCUsoCons .And. oModel:GetValue("GFEA065_GW3", "GW3_TRBIMP") $ "1;3;4;5;7"
							oModel:LoadValue("GFEA065_GW3", "GW3_CRDICM", "1")
							GFELog115:Add("- Com direito a crédito ICMS.", 2)
						Else
							oModel:LoadValue("GFEA065_GW3", "GW3_CRDICM", "2")
							GFELog115:Add("- Sem direito a crédito ICMS.", 2)
						EndIf
				Else
					GFELog115:Add("# Imposto ISS, não verifica Credito ICMS.",2)
				EndIf
	
				GFELog115:Save()
	
				// Crédito PIS/COFINS
				GFELog115:Add("# Verificando crédito PIC/COFINS.", 2)
				GFELog115:Add("- Parâmetro MV_GFEPC..: " + If(!Empty(GetNewPar("MV_GFEPC", "1", cFilAnt)), GetNewPar("MV_GFEPC", "1", cFilAnt), " < Parâmetro em branco >" ), 2)
				cCredPC := GetNewPar("MV_GFEPC", "1", cFilAnt)
				If Empty(cCredPC)
					cCredPC := "1"
				EndIf
				GFELog115:Add("- " + If(cCredPC == "1", "com", "sem") + " direito a crédito PIS/COFINS." , 2)
	
				If cCredPC == "1" .And. !lDCUsoCons .And. (!Posicione("GU3", 1, xFilial("GU3") + oModel:GetValue("GFEA065_GW3", "GW3_CDREM"), "GU3->GU3_EMFIL") == "1" .Or. ;
			 	   !Posicione("GU3", 1, xFilial("GU3") + oModel:GetValue("GFEA065_GW3", "GW3_CDDEST"), "GU3->GU3_EMFIL") == "1")
					oModel:LoadValue("GFEA065_GW3", "GW3_CRDPC", "1")
				Else
					oModel:LoadValue("GFEA065_GW3", "GW3_CRDPC", "2")
				EndIf
			Else
				lRet := .T.
			EndIf
	
			// INI - Verifica tamanhos para nao ocorrer erro ???
			If TamSX3("GW4_SERDC")[1] != TamSX3("GXH_SERDC")[1]
	
				RecLock("GXG",.F.)
				GFELog115:NewLine()
				GFELog115:Add( "** O campo Série da tabela 'Doc. Carga dos Doc. Frete' está com o tamanho diferente do campo Série da tabela 'EDI - Doc. Carga do Doc. Frete'" )
	
	           	GXG->GXG_EDIMSG := GXG->GXG_EDIMSG + "** O campo Série da tabela 'Doc. Carga dos Doc. Frete' está com o tamanho diferente do campo Série da tabela 'EDI - Doc. Carga do Doc. Frete'"
				GXG->GXG_EDISIT := '3'
	
				MsUnLock("GXG")
	
				lRet := .F.
			EndIf
			// FIM - Verifica tamanhos para nao ocorrer erro ???
	
			// Existem um delay entre a gravação dos dados no Banco de Dados e a consulta se o registro existe.
			// para ter um tempo para o proximo registro realizar consulta, é gravado o tempo novamente para que o proximo registro localize o registro
			// alterado no banco de dados.
			PutGlbValue(cLock, GFENow(.T.,,'','','')) // Atualiza o tempo para que o proximo processo aguarde
	
			If lRet
				lRet := oModel:VldData()
			EndIf

			If (lRet) // Validou o modelo para exclusão
	
				If GXG->GXG_ACAO == "E"

					dbSelectArea('GXH')
					GXH->( dbSetOrder(1) )
					GXH->( dbSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP) )
	
					cCont:= 0
					cContDel := 0
					// Valida se existem diferenças de documentos
					// do registro intermediário para o documento de frete eliminado
					While !Eof() .And. GXG->GXG_FILIAL + GXG->GXG_NRIMP == GXH->GXH_FILIAL + GXH->GXH_NRIMP
						cCont:= cCont +1
	
						GW4->( dbSetOrder( If(__lCpoSr,3,1) ) )
						If GW4->( dbSeek(GXG->GXG_FILDOC;
							+PadR(GXG->GXG_EMISDF, TamSx3("GW4_EMISDF")[1]);
							+PadR(GXG->GXG_CDESP, TamSx3("GW4_CDESP")[1]);
							+PadR(GXG->GXG_SERDF,TamSX3("GW4_SERDF")[1]);
							+PadR(cNRDF,TamSx3("GW4_NRDF")[1]);
							+DTOS(GXG->GXG_DTEMIS);
							+PadR(GXH->GXH_EMISDC, TamSx3("GW4_EMISDC")[1]);
							+PadR(GXH->GXH_SERDC,__nTamSrDC);
							+PadR(GXH->GXH_NRDC,TamSx3("GW4_NRDC")[1]);
							+PadR(GXH->GXH_TPDC,TamSx3("GW4_TPDC")[1])) )
	
							cContDel := cContDel + 1
						Else
							cNum := GXH->GXH_NRDC
							cSer := GXH->GXH_SERDC
							cEmi := GXH->GXH_EMISDC
							Exit
						EndIf
						DbSelectArea('GXH')
						GXH->( dbSkip() )
					EndDo
	
				    If cContDel == cCont .And. cCont > 0
						dbSelectArea('GW3')
						GW3->( dbSetOrder(1) )
	
						If GW3->( dbSeek(GXG->GXG_FILDOC;
							+PadR(GXG->GXG_CDESP,TamSx3("GW3_CDESP")[1]);
							+PadR(GXG->GXG_EMISDF, TamSx3("GW3_EMISDF")[1]);
							+PadR(GXG->GXG_SERDF,TamSX3("GW3_SERDF")[1]);
							+PadR(cNRDF,TamSx3("GW3_NRDF")[1]);
							+DTOS(GXG->GXG_DTEMIS)) )
							lOk := .T.
							oModel:CommitData()
						EndIf
					Else
					    lMsgErr := .T.
					EndIf

					// PE para permitir o processamento de XMLs referente a cancelamentos de CT-es que não possuam Doc. Carga vinculado
					If s_GFEA1159
						aRet := ExecBlock("GFEA1159",.f.,.f.,{lOk,lMsgErr})
						If ValType(aRet) == "A" .And. !Empty(aRet)
							lOk 	:= aRet[1]
							lMsgErr := aRet[2]
						EndIf
					EndIf
		
				ElseIf GXG->GXG_ACAO $ "IC"
	
					// Início Ponto de Entrada Procomp
					If s_GFEA1154
						cFilAtu := cFilAnt
						cFilAnt := GXG->GXG_FILDOC
					EndIF
					// Fim Ponto de Entrada Procomp

					If GXG->GXG_EDISIT <> "4"
						oModel:CommitData()
					EndIf
	
					// Início Ponto de Entrada Procomp
					If s_GFEA1154
						cFilAnt = cFilAtu
					EndIf
					// Fim Ponto de Entrada Procomp
	
					lOk := .T.
				EndIf
				
				//Validou os registros intermediários
				If lOk
					nCount++
					RecLock("GXG",.F.)
			       	GXG->GXG_EDIMSG := ""
			        GXG->GXG_EDISIT := '4'
			       	If lRetMsg
			       	GXG->GXG_EDIMSG := "Documento de Carga possui ocorrência!"
			       	EndIf
					MsUnLock("GXG")
				Else
					RecLock("GXG",.F.)
					If lMsgErr
				  		// STR0006 //"Não foi encontrado o Documento de Frete para ser excluído."
				       GXG->GXG_EDISIT := '3'
			           GXG->GXG_EDIMSG := STR0006 + "   Erro no Documento de Carga -  Série: " + cSer +" Número: "+cNum+" Emissor: "+ cEmi
			        EndIf
					MsUnLock("GXG")
				EndIf
			Else
	
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
				dbSelectArea('GXH')
				GXH->( dbSetOrder(1) )
				If(GXH->( dbSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP) ))
					cEmi  		:= PadR(GXH->GXH_EMISDC, TamSx3("GW4_EMISDC")[1])
					cSer  		:= PadR(GXH->GXH_SERDC, TamSx3("GW4_SERDC")[1])
					cNum  		:= PadR(GXH->GXH_NRDC, TamSx3("GW4_NRDC")[1])
					cNumDFRed 	:= ""
					GW4->(dbSetOrder(2))
					GW4->(dbSeek(GXH->GXH_FILDC;
				 			+ PadR(cEmi, TamSx3("GW4_EMISDC")[1]);
				 			+ PadR(cSer, TamSx3("GW4_SERDC")[1]);
				 			+ PadR(cNum, TamSx3("GW4_NRDC")[1])))
					While !GW4->(Eof()) .And. GXH->GXH_FILDC + cEmi + cSer + cNum == ;
										GW4->GW4_FILIAL + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC
						dbSelectArea("GW3")
						dbSetOrder(1)
						If(dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF))
							cNumDFRed := GW3->GW3_NRDF
						EndIf
						GW4->(dbSkip())
					EndDo
				EndIf
	
				// Recupera as mensagens de erro
				aErro := oModel:GetErrorMessage()
	
			  RecLock("GXG",.F.)
				  For nX := 1 To Len(aErroLinha)
		
					  If !empty(cEDImsg)
						   GXG->GXG_EDIMSG := cEDImsg
					  Else
						   GFELog115:NewLine()
						   GFELog115:Add("** " + "Erro na inclusão do registro. Campo: " + aErro[4] + ". Motivo: " + aErro[6], 1)
						   lPriErro := .T.
						   If (!Empty( aErroLinha[nX][4]) .Or. !Empty( aErroLinha[nX][6] )) 
							    If lPriErro 
								     lPriErro := .F.
								     GXG->GXG_EDIMSG := "Ocorreu um ou mais erros na inclusão de documentos: " + CRLF
							    EndIf
							    GXG->GXG_EDIMSG :=  "Campo: " + aErroLinha[nX][4] + '. Motivo: ' + aErroLinha[nX][6] + CRLF  + CRLF + GXG->GXG_EDIMSG + CRLF
						   EndIf
					  EndIf
				
				  Next nX		
														
			    If !Empty( aErro[6] )
					If aErro[4] == "GW3_CDESP" .And. Empty(GXG->GXG_CDESP) // Verifica se o campo especie esta preenchido e trata as mensagens
						aErro[4] := "GXG_CDESP"
						aErro[6] := "O campo Especie (GXG_CDESP) não foi preenchido"
						aErro[7] := "Verifique se o parametro (MV_ESPDF3) esta preenchido ou informe manualmente a Especie de Documento no registro importado. "
					EndIf 
				     GXG->GXG_EDIMSG :=   GXG->GXG_EDIMSG + CRLF + "Campo: " + aErro[4] + '. Motivo: ' + aErro[6] + CRLF + CRLF + 'Solução: ' + aErro[7] + CRLF 
			    EndIf
			
			    If lRetRedes
				     GXG->GXG_EDIMSG := "O Documento de Carga " + AllTrim(cNum) + " já está vinculado em outro Documento de Frete (" + AllTrim(cNumDFRed) + ") para este emissor." + CRLF + GXG->GXG_EDIMSG + CRLF
			    EndIf
			    GXG->GXG_EDISIT := '3'
					
			  GXG->(MsUnlock())
			EndIf
			
			If s_GFEA1154
				cFilAnt = cFilAtu
			EndIf		
	
			oModel:DeActivate()
	
			GFELog115:NewLine()
			GFELog115:Add(Replicate(".", 120))
			GFELog115:NewLine()
			GFELog115:Save()
	
			// Existem um delay entre a gravação dos dados no Banco de Dados e a consulta se o registro existe.
			// para ter um tempo para o proximo registro realizar consulta, é gravado o tempo novamente para que o proximo registro localize o registro
			// alterado no banco de dados.
			PutGlbValue(cLock, GFENow(.T.,,'','','')) // Atualiza o tempo para que o proximo processo aguarde
		
			UnLockByName(c115ALock, .F., .F.) 
		EndIf

	    dbSelectArea('GXG')
	    (cGXGPro)->( dbSkip() )
	EndDo

	RestArea(aAreaGW1)
	(cGXGPro)->( dbCloseArea() )

	If nCount == 0 .And. lProc
		GFELog115:Add("Nenhum Registros processados com sucesso.")
		GFELog115:Add("Total de registros processados: " + cValToChar(nTotal))
		If !lSchedule
			MessageBox ("Nenhum registro processado com sucesso. Total de registros processados: " + cValToChar(nTotal) + CRLF + "Verifique o campo 'Mensagens' dos registros para a descrição dos erros ocorridos.", "Processamento", 48)
		EndIf
	ElseIf nCount == 0 .And. !lProc
		GFELog115:Add("** " + STR0009)
		If !lSchedule .and. !(SuperGetMV('MV_IMPPRO',,'1') == '2')
			MessageBox (STR0009, "Processamento", 48) 	// "Não há registros para processar."
		EndIf
	ElseIf nCount > 0 .And. lProc
		GFELog115:Add(STR0007)
		GFELog115:Add(STR0010 + AllTrim(Str(nCount)) + STR0011 + AllTrim(Str(nTotal)))
		If !lSchedule
			MsgInfo(STR0007 + CRLF + STR0010 + AllTrim(Str(nCount)) + STR0011 + AllTrim(Str(nTotal)) + "." + CRLF + ; //"Processo concluído. " ### "Processado(s) " ### " fatura(s) do total de "
						If(nCount != nTotal, "Verifique o campo 'Mensagens' dos registros para a descrição dos erros ocorridos.","") + CRLF + ;
						If(nContMsg != 0, "Documento(s) processados com sucesso, mas a integração com o fiscal não foi executada, pois não há fatura de frete relacionado ao(s) documento(s) de frete para definir a data de transação. Verificar o parâmetro 'Data de Transação do Documento Fiscal' na aba 'Integrações Datasul'.","") ;
						,"")//"Processo concluído. " ### "Processada(s) " ### " ocorrências(s) do total de "
		EndIf
	EndIf
	oModel    := Nil
	oModelGW4 := Nil
	cFilAnt := cFilTemp

	GFELog115:EndLog()
	GFEA517SVW(.T.)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115Msg
Grava Mensagem se o documento de Carga tiver uma ocorrencia

@author Ana Claudia da Silva
@since 06/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA115Msg(lMsgOco)
	Local lMsg := lMsgOco
	If lMsg
		lRetMsg := .T.
	EndIf
Return lRetMsg
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115Red
Grava Mensagem se o documento de Carga tiver um doc de frete

@author Ana Claudia da Silva
@since 06/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA115Red(lMsgRedes)
	Local lMsg := lMsgRedes
	If lMsg
		lRetRedes := .T.
	EndIf
Return lRetRedes
//-------------------------------------------------------------------
/*/{Protheus.doc} PreValGXG
Grava as Pré-validação do conhecimento importado

@author Israel A. Possoli
@since 28/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function PreValGXG(cMsgPreVal)
	Local cMsg := cMsgPreVal
	cMsgPreVal := ""

   	If !Empty(cMsg)
   		RecLock((tTabCTRC))
   		(tTabCTRC)->GXG_EDIMSG := cMsg
   		(tTabCTRC)->GXG_EDISIT := '2'
   		MsUnlock()
   	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEVldFor1

@author Ana Claudia da Silva
@since 07/04/14
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEVldFor1(cStr, cFun)

	Local nI

	For nI := 1 To Len(cStr)

		If &("!" + cFun + "('" + SubStr(cStr, nI) + "')")
			Return .F.
		EndIf

	Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ReprocessDoctoCarga

@author Hercilio Henning Neto
@since 10/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function ReprocessDoctoCarga(cFilImp, cNrImp)
	Local cNumeroNF   := ""
	Local cFilialDC   := ""
	Local cSerieDC    := ""
	Local cChaveNFE   := ""
	Local cEmissorDc  := ""
	Local nI          := 1
	Local lFlag       := .T.
	Local lDocCarga   := .F.
	Local cTpDc       := ""
	Local cCNPJEmbarc := ""
	Local lImpISS     := .F.
	Local aRetDocTrechoPago[3]
	Local lValDC := .F.
	Local s_ESPDF1   := SuperGetMv("MV_ESPDF1",,"")
	Local s_ESPDF2   := SuperGetMv("MV_ESPDF2",,"")
	Local s_ESPDF3   := SuperGetMv("MV_ESPDF3",,"")
	Local s_ESPDF3_2 := SuperGetMv("MV_ESPDF3",,"")
	Local cApuIss 	  := ""
	Local cCidTransp  := ""
	Local cCidOri     := ""
	Local cCidDest    := ""
	Local aAreaGWU    := GWU->(GetArea())
	
	// Início Ponto de Entrada Procomp
 	If ExistBlock("GFEA1151")   
	    lValDC := ExecBlock("GFEA1151",.f.,.f.,{})
 	EndIf
	// Fim Ponto de Entrada Procomp	

	//A tabela GXH já está posicionada.
	While !GXH->(Eof()) .AND. ;
			GXH->GXH_FILIAL == cFilImp .And. ;
			GXH->GXH_NRIMP  == cNrImp

		//Pega as informações do Model
		cFilialDC		:= GXH->GXH_FILDC
		cSerieDC  		:= GXH->GXH_SERDC
		cNumeroNF		:= GFEZapZero(AllTrim(GXH->GXH_NRDC))
		cChaveNFE 		:= GXH->GXH_DANFE
		cCNPJEmbarc 	:= GXH->GXH_CNPJEM
		cEmissorDc 	:= Posicione("GU3", 11, xFilial("GU3") + cCNPJEmbarc, "GU3_CDEMIT")
		lDocCarga := .F.

		If !Empty(cChaveNFE)
			//Tenta primeiramente encontrar pela chave da NF-e
			aRetDocTrechoPago := BuscaDocTrechoPago('', '', '', cFilialDC, cChaveNFE)
			If aRetDocTrechoPago[1]
				cTpDc   := GW1->GW1_CDTPDC
				cFilialDC := GW1->GW1_FILIAL
				lDocCarga := .T.
			EndIf
		Else
			If cNumeroNF != Replicate(" ", 8) .And. cNumeroNF != Replicate("0", 8)
				aRetDocTrechoPago := BuscaDocTrechoPago(cEmissorDc, Upper(cSerieDC), cNumeroNF, cFilialDC)
				If aRetDocTrechoPago[1]
					cTpDc   := GW1->GW1_CDTPDC
					cFilialDC := GW1->GW1_FILIAL
					lDocCarga := .T.
				Else
					// Regra para buscar o número da nota fiscal no GFE:
					// Inicia a busca a partir do número sem zeros à esquerda e enquanto
					// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
					For nI := Len(cNumeroNF) To __nTamNrDC
						cNumeroNF := PadL(cNumeroNF, nI, "0")
						aRetDocTrechoPago := BuscaDocTrechoPago(cEmissorDc, cSerieDC, cNumeroNF, cFilialDC)
						If aRetDocTrechoPago[1]
							cTpDc   := GW1->GW1_CDTPDC
							cFilialDC := GW1->GW1_FILIAL
							lDocCarga := .T.
							Exit
						EndIf
					Next nI
				EndIf
			Else	
				//Numero do documento de carga está em branco!!
				lFlag := .F.
			EndIf
		EndIf

		If lDocCarga
			//Atualiza os dados da GXH com o Documento de carga encontrado.
			RecLock("GXH", .F.)
				GXH->GXH_FILIAL := GXG->GXG_FILIAL
				GXH->GXH_NRIMP  := ALLTRIM(cNrImp)
				GXH->GXH_SERDC  := GW1->GW1_SERDC
				GXH->GXH_NRDC   := GW1->GW1_NRDC
				GXH->GXH_EMISDC := GW1->GW1_EMISDC
				GXH->GXH_FILDC  := GW1->GW1_FILIAL
				GXH->GXH_TPDC   := GW1->GW1_CDTPDC
			MsUnlock("GXH")

		EndIf

		GXH->( dbSkip() )
	EndDo

	dbSelectArea("GXH")
	GXH->( dbSetOrder(1) )
	GXH->( dbSeek(cFilImp+cNrImp) )

	dbSelectArea("GW1")
	GW1->( dbSetOrder( If(__lCpoSr,15,1) ) ) //Índice muda quando funcionalidade de chave única protheus estiver habilitada
	GW1->( dbSeek(GXH->GXH_FILDC+GXH->GXH_TPDC+GXH->GXH_EMISDC+GXH->GXH_SERDC+GXH->GXH_NRDC) )
	GW1->( dbSeek(GXH->GXH_FILDC + GXH->GXH_TPDC + GXH->GXH_EMISDC + PadR(GXH->GXH_SERDC,__nTamSrDC) + GXH->GXH_NRDC) )

	If __lCpoSr // Quando novo conceito de chave única, utiliza o último documento de carga
		While GW1->(!Eof()) .And. ;
			  GW1->GW1_FILIAL == GXH->GXH_FILDC .And. ;
			  GW1->GW1_CDTPDC == GXH->GXH_TPDC .And. ;
			  GW1->GW1_EMISDC == GXH->GXH_EMISDC .And. ;
			  GW1->GW1_SERDC == PadR(GXH->GXH_SERDC,__nTamSrDC) .And. ;
			  GW1->GW1_NRDC == GXH->GXH_NRDC
			GW1->(dbSkip())
		EndDo

		GW1->(dbSkip(-1))
	EndIf

	//Atualiza as informações da tabela GXG.
	dbSelectArea("GXG")
	GXG->( dbSetOrder(1) )
	If GXG->( dbSeek(cFilImp+cNrImp) )
		RecLock("GXG", .F.)
		
			If !lValDC
				GXG->GXG_CDREM := GW1->GW1_CDREM
				GXG->GXG_CDDEST := GW1->GW1_CDDEST
			endif
			If Empty(GXG->GXG_CDESP)

			//------------------------ DISCLAIMER!!! ------------------------//
			//---------- Manutenções efetuadas nesse bloco devem ------------//
			//--------- ser replicadas para a função LayoutPro3() -----------//
			//--- para correto funcionamento da importação e processamento --//
			//-------------------- de EDI Conemb e CT-e. --------------------//
			//----------- Alteração efetuada no chamado TQWOHG --------------//
			//---------------------------------------------------------------//

				//Atribuir ao campo GW3_CDESP o parâmetro MV_ESPDF1 quando o campo VALOR DO ICMS (registro 322)
			    //for maior que zero ou o parâmetro MV_ESPDF2 quando o campos VALOR TOTAL DO ISS (registro 329) for maior que zero.
			    //Antiga verificação do ElseIf : AllTrim(Transform(Val(SubStr(cBuffer,81,15)) , '@R 9999999999999,99'))
			    //Quando o campo GXG_CTE vir preenchido (ou o CONEMB é um Conhecimento Eletronico)
			   	//Deve ser atribuido o paramêtro MV_ESPDF3
				// Chave CT-e

				//Busca a origem e destino para verificar o código da espécie do documento.
				cOrigem := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NRCID")

				If !Empty(GW1->GW1_ENTNRC)
					cDestin := GW1->GW1_ENTNRC
				Else
					cDestin := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NRCID")
				EndIf

			   	If !Empty(GXG->GXG_CTE) .And. !Empty(s_ESPDF3)
			   		If (GXG->GXG_VLIMP > 0 .And. GXG->GXG_TPIMP == "2") .Or. (cOrigem == cDestin)
				   		GXG->GXG_CDESP := s_ESPDF2
						lImpISS := .T.
					Else
			   			GXG->GXG_CDESP := s_ESPDF3_2
			   		EndIf
			   	ElseIf (GXG->GXG_VLIMP > 0 .And. GXG->GXG_TPIMP == "2") .Or. (cOrigem == cDestin)
					GXG->GXG_CDESP := s_ESPDF2
					lImpISS := .T.
			   Else
					GXG->GXG_CDESP := s_ESPDF1
				EndIf

				If !lImpISS
					GXG->GXG_TPIMP  := "1"
				EndIf

				If lImpISS
					dbSelectArea("GU3")
					dbSetOrder(1)
					If dbSeek(xfilial("GU3")+ AllTrim(GXG->GXG_EMISDF))

						cCidTransp  := GU3->GU3_NRCID

						aAreaGWU := GWU->(GetArea())
						
						GWU->(dbSetOrder(1))
						GWU->(dbSeek(GXH->GXH_FILDC + GXH->GXH_TPDC + GXH->GXH_EMISDC + PadR(GXH->GXH_SERDC,__nTamSrDC) + GXH->GXH_NRDC))	

						cCidOri  := GWU->GWU_NRCIDO
						cCidDest := GWU->GWU_NRCIDD

						RestArea(aAreaGWU)

						/*Verificação do campo GU3_APISSO - Apuração ISS Outro Município*/
						IF  GFXCP1212410("GU3_APISSO") .AND. cCidTransp != cCidOri .AND. cCidTransp != cCidDest 
							cApuIss := GU3->GU3_APISSO
						ELSE
							cApuIss := GU3->GU3_APUISS
						ENDIF	

						If cApuIss == "2" .or. GXG->GXG_SUBTRB == '1'  //Substituicao Tributaria
							GXG->GXG_TRBIMP := "3"
							GXG->GXG_VLIMP  := GXG->GXG_BASIMP * GXG->GXG_PCIMP / 100
							GXG->GXG_IMPRET := GXG->GXG_VLIMP
							GXG->GXG_PCRET  := 0   					
						ElseIf cApuIss == "1"   //Normal
							If GXG->GXG_BASIMP > 0
								GXG->GXG_TRBIMP := "6"
							Endif			
						Endif	
					EndIf						
				Else
			    	dbSelectArea("GU3")
					dbSetOrder(1)
					If dbSeek(xfilial("GU3")+ AllTrim(GXG->GXG_EMISDF))
						If GXG->GXG_VLIMP > 0
							If GU3->GU3_APUICM == "1"
								GXG->GXG_TRBIMP := "1"
							ElseIf GU3->GU3_APUICM == "2"
								GXG->GXG_TRBIMP := "3"
							ElseIf GU3->GU3_APUICM == "3"
								GXG->GXG_TRBIMP := "4"
							ElseIf GU3->GU3_APUICM == "4"
								GXG->GXG_TRBIMP := "7"
							Endif
			    		ElseIf GXG->GXG_BASIMP > 0
					   	    GXG->GXG_TRBIMP := '6'
					   	Else
					   		GXG->GXG_TRBIMP := '2'
					   	EndIf
				    EndIf

					If GXG->GXG_SUBTRB == '1' .And. !(lImpISS)   // Substituição Tributária e ICMS

						dbSelectArea("GW8")  //Itens do Documento de Carga
						GW8->( dbSetOrder(1) )
						If GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )

							cOrigem := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NRCID")
							cDestin := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NRCID")

							//Substituição tributária
							aIcms := GFEFnIcms(GXG->GXG_EMISDF, GW1->GW1_CDREM, GW1->GW1_CDDEST, cOrigem, cDestin, GW1->GW1_USO, GW8->GW8_TPITEM, GW8->GW8_CDCLFR, GW1->GW1_ICMSDC, Posicione("GWN", 1, GW1->GW1_FILIAL + GW1->GW1_NRROM, "GWN_CDTPOP"))

							If GXG->GXG_PCIMP == 0
								GXG->GXG_PCIMP := aIcms[1]
							EndIf

							If GXG->GXG_BASIMP == 0 //Base de cálculo

								//Buscar base de ICMS
								dbSelectArea("GWH")
								GWH->( dbSetOrder(2) )
								If GWH->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )

									dbSelectArea("GWG")
									GWG->( dbSetOrder(1) )
									If GWG->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) )

										dbSelectArea("GUY")
										GUY->( dbSetOrder(1) )
										If GUY->( dbSeek(GWG->GWG_FILIAL + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG) )

											While !GUY->( Eof() ) .And. GUY->GUY_FILIAL + GUY->GUY_CDEMIT + GUY->GUY_NRTAB + GUY->GUY_NRNEG == xFilial("GUY") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG

												dbSelectArea("GV2")
												GV2->( dbSetOrder(1) )
												If GV2->( dbSeek(xFilial("GV2") + GUY->GUY_CDCOMP) )

											    	If GV2->GV2_CATVAL == "4"
											    		If GUY->GUY_BASIMP == "1"
											    			GXG->GXG_BASIMP := nVlDF - nPedag
											    		Else
											    			GXG->GXG_BASIMP := nVlDF
											    		EndIf

											    		Exit
											    	EndIf

											    EndIf

												dbSelectArea("GUY")
												GUY->( dbSkip() )

											EndDo

										EndIf

									EndIf

								EndIf

								If GXG->GXG_BASIMP == 0
									GXG->GXG_BASIMP := nVlDF
								EndIf

								GXG->GXG_BASIMP := GXG->GXG_BASIMP * (1 - (aIcms[3] / 100))

							EndIf

							If GXG->GXG_VLIMP == 0
								GXG->GXG_VLIMP := GXG->GXG_BASIMP * GXG->GXG_PCIMP / 100
							EndIf

							// Presumido
							If aIcms[2] == "7"
								GXG->GXG_IMPRET := GXG->GXG_VLIMP * (1 - (aIcms[4] / 100))
								GXG->GXG_PCRET  := aIcms[4]

							// Subs-tributária
							ElseIf aIcms[2] == "3"
								GXG->GXG_IMPRET := GXG->GXG_VLIMP
								GXG->GXG_PCRET  := 0

							EndIf

						EndIf

			    	EndIf

				EndIf


			EndIf

		MsUnlock("GXG")
	EndIf

Return
//-------------------------------------------------------------------

/*{Protheus.doc} PosVal115
Grava validação do processamento do documento

@author Ana Claudia da Silva
@since 30/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function PosVal115(lMsg)
	Local lMsg1 := lMsg


	If lMsg1
		nContMsg := nContMsg + 1
	Endif

Return

Function GF115GXPDC(cEmisDC, cSerDC, cNrDc, cFilDC, cDANFE)
	Local cInnerGXP := "GXP.D_E_L_E_T_ = ' '" 
	Local cAliasGXP := GetNextAlias()

	If !Empty(cFilDC)
		cInnerGXP += " AND GXP.GXP_FILORI = '" + cFilDC + "'" 
	EndIf

	If !Empty(cDANFE)
		cInnerGXP += " AND GXP_DANFE = '" + cDANFE + "'"
	Else
		cInnerGXP += " AND GXP_EMIORI = '" + cEmisDC + "'" 
		cInnerGXP += " AND GXP_DOCORI = '" + cNrDc + "'"
		If TamSX3("GW1_SERDC")[1] == 14 .And. Len(AllTrim(cSerDC)) <= 3
			cInnerGXP += " AND GXP_SDCORI = '" + cSerDC + "'"
		Else
			cInnerGXP += " AND GXP_SERORI = '" + cSerDC + "'"
		EndIf
	EndIf
	cInnerGXP := "%" + cInnerGXP + "%"
			
	BeginSql Alias cAliasGXP
		SELECT GW1_FILIAL, GW1.R_E_C_N_O_
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GXP% GXP
		ON GXP.GXP_FILIAL = GW1.GW1_FILIAL
		AND GXP.GXP_CDTPDC = GW1.GW1_CDTPDC
		AND GXP.GXP_EMISDC = GW1.GW1_EMISDC
		AND GXP.GXP_SERDC = GW1.GW1_SERDC
		AND GXP.GXP_NRDC = GW1.GW1_NRDC
		AND %Exp:cInnerGXP%
		WHERE GW1.%NotDel%
		ORDER BY GXP_SERDC DESC
	EndSql

Return cAliasGXP

//--------------------------------------------------------------------
/* BuscaDocTrechoPago
Busca o documento de carga que possuir trecho pago em todas filiais.
Reposiciona a GW1 no documento encontrado.

Parâmetros:
	cEmisDC, cSerDC, cNrDc e cFilDC (opcional)

Retorno:
	Array[2]:
		[1] Sucesso
		[2] Filial do documento de carga
*/
//--------------------------------------------------------------------
Function BuscaDocTrechoPago(cEmisDC, cSerDC, cNrDc, cFilDC, cDANFE)
	Local aRet[3]
	Local cAliasGW1 := GetNextAlias()
	Local cAliasGXP
	Local cQuery
	Local cWhere
	Local nCount
	Local lExisGXP	:= GFXTB12117("GXP")
	Local cCodTrp 	:= ""

	Default cFilDC 	:= ""
	Default cCNPJ  	:= ""

	If !Empty(cCnpj)
		cCodTrp := Alltrim(A118EMIT("1", cCNPJ, {}))
	EndIf

	/*Verificar se há somente um documento com a chave ou número informado. Se houver, este será utilizado.
	  Do contrário, faz a regra de buscar o documento com trecho pago e transportador informado. */

	//Cláusula comum aos 2 SQLs
	cWhere := " WHERE "
	If !Empty(cDANFE)
		cWhere += " GW1_DANFE = '" + cDANFE + "'"
	Else
		cWhere += " GW1_NRDC = '" + cNrDc + "'"
		cWhere += " AND GW1_EMISDC = '" + cEmisDC + "'" 
		If __lCpoSr
			cWhere += " AND GW1_SDOC = '" + cSerDC + "'"
		Else
			cWhere += " AND GW1_SERDC = '" + cSerDC + "'"
		EndIf
	EndIf

	If !Empty(cFilDC)
		cWhere += " AND GW1_FILIAL = '" + cFilDC + "'" 
	EndIf
	cWhere += " AND GW1.D_E_L_E_T_ = ' '"

	//Contagem de documentos de carga	
	cQuery := "SELECT COUNT(*) GW1_COUNT FROM " + RetSQLName("GW1") + " GW1" + cWhere

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)
	dbSelectArea(cAliasGW1)	
	nCount := (cAliasGW1)->GW1_COUNT 
	
	If nCount == 0
		
		If lExisGXP
			cAliasGXP := GF115GXPDC(cEmisDC, cSerDC, cNrDc, cFilDC, cDANFE)
		EndIf
		
		If !lExisGXP .Or. (cAliasGXP)->(Eof()) .Or. Empty((cAliasGXP)->R_E_C_N_O_)
			GFELog115:Add("# Busca documento com mesmo número não encontrou registro.",1)
	
			aRet[1] := .F.
			aRet[2] := ""
			aRet[3] := PadR(" ",Len(cSerDC))
			
		Else
			
			dbSelectArea("GW1")
			dbGoTo((cAliasGXP)->R_E_C_N_O_)		
	
			aRet[1] := .T.
			aRet[2] := (cAliasGXP)->GW1_FILIAL
			aRet[3] := GW1->GW1_SERDC
		EndIf	
		
		If lExisGXP
			(cAliasGXP)->(dbCloseArea())
		EndIf
		
		
	ElseIf nCount == 1		
		(cAliasGW1)->(DBCloseArea()) 
		cQuery := "SELECT GW1.GW1_FILIAL, GW1.R_E_C_N_O_"
		cQuery += " FROM " + RetSQLName("GW1") + " GW1"
		If !Empty(cCodTrp)
			cCodTrp := GFEGetEmRz(cCodTrp)

			cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU"
			cQuery += " ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
			cQuery += " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
			cQuery += " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
			cQuery += " AND GWU.GWU_SERDC = GW1.GW1_SERDC"
			cQuery += " AND GWU.GWU_NRDC = GW1.GW1_NRDC"
			cQuery += " AND GWU.GWU_CDTRP IN ('" + AllTrim(cCodTrp) + "')"
			cQuery += " AND GWU.D_E_L_E_T_ = ' '"	
		EndIf
		cQuery += cWhere

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)
		dbSelectArea(cAliasGW1)
		(cAliasGW1)->(dbGoTop())		

		GFELog115:Add("# Busca documento com mesmo número encontrou 1 registro. Filial: " + (cAliasGW1)->GW1_FILIAL,1)

		dbSelectArea("GW1")
		dbGoTo((cAliasGW1)->R_E_C_N_O_)		

		aRet[1] := .T.
		aRet[2] := (cAliasGW1)->GW1_FILIAL
		aRet[3] := GW1->GW1_SERDC
	Else	
		//Verificação da filial que possui o documento de carga com trecho pago e transportador informado.
		
		GFELog115:Add("# Busca documento com mesmo número encontrou mais de 1 registro.",1)
		
		(cAliasGW1)->(DBCloseArea()) 
		
		cQuery := "SELECT GW1_FILIAL, GW1.R_E_C_N_O_ "
		cQuery += " FROM " + RetSQLName("GW1") + " GW1, " + RetSQLName("GWU") + " GWU "
		cQuery += cWhere
		cQuery += " AND GWU_FILIAL = GW1_FILIAL"
		cQuery += " AND GWU_CDTPDC = GW1_CDTPDC"
		cQuery += " AND GWU_EMISDC = GW1_EMISDC"
		cQuery += " AND GWU_SERDC  = GW1_SERDC"
		cQuery += " AND GWU_NRDC   = GW1_NRDC"
		cQuery += " AND GWU_PAGAR  = '1'"
		cQuery += " AND GWU_CDTRP <> ' ' "
		cQuery += " AND GWU.D_E_L_E_T_ = ' ' ORDER BY GW1_DTEMIS DESC "
		cQuery := ChangeQuery(cQuery)
	
		GFELog115:Add("# Busca documento com trecho pago e transportador informado. SQL: [" + cQuery + "]",1)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)
		dbSelectArea(cAliasGW1)
		(cAliasGW1)->( dbGoTop() )
		If !(cAliasGW1)->(Eof())
			dbSelectArea("GW1")
			dbGoTo((cAliasGW1)->R_E_C_N_O_)

			GFELog115:Add("# Busca documento com trecho pago e transportador informado. Filial: " + (cAliasGW1)->GW1_FILIAL,1)

			aRet[1] := .T.
			aRet[2] := (cAliasGW1)->GW1_FILIAL
			aRet[3] := GW1->GW1_SERDC
		Else
			//Apesar de encontrar mais de um documento, pode ser que em ambas as filiais estejam com transportador em branco ou tipo de frete não pago.

			GFELog115:Add("# Busca documento com trecho pago e transportador informado não encontrou registro.",1)

			aRet[1] := .F.
			aRet[2] := ""
			aRet[3] := PadR(" ",Len(cSerDC))
		EndIf
	EndIf

	(cAliasGW1)->(DBCloseArea())

Return aRet

Static Function GU3Valid(cEmit, cMsgIni)
	Local cMsg := ''
	Local aAreaGU3 := GU3->(GetArea())
	GU3->(DbSetOrder(1))
	If GU3->(Dbseek(xFilial("GU3") + cEmit))
		IF GU3->GU3_SIT == "2"
			cMsg := cMsgIni + "O Emitente " + cEmit + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente." 
		Endif
	Else
		cMsg := cMsgIni + "O Emitente " + cEmit + " não foi encontrado."
	EndIf
	RestArea(aAreaGU3)
Return cMsg

/*/{Protheus.doc} FindDocTrechoPago
	Função similar à BuscaDocTrechoPago().
	Foi criada para ser mais performática, evitando o uso de milhares de SELECT dentro do While.

	Busca o documento de carga que possuir trecho pago em todas filiais.

	@type  Static Function
	@author André Eduardo Pérez Álvarez
	@since 08/05/019
	@version 12.12.25
	@param aChaves[ cEmisDC, cSerDC, cFilDC, cDANFE, aNrDc[n] ], @oDocJSON
	/*/
Static Function FindDocTrechoPago(aChaves, oDocJSON)
	
	Local cAliasGXP
	Local cAliasGW1	 := GetNextAlias()
	Local cQuery	 := ""
	Local cWhere	 := ""
	Local nCount	 := 0
	Local lExisGXP 	 := GFXTB12117("GXP")
	Local cEmisDC 	 := ""
	Local cSerDC  	 := ""
	Local cNrDc   	 := ""
	Local cFilDC  	 := ""
	Local cDANFE  	 := ""
	Local nX		 := 0
	Local aNrDc		 := {}
	Local cCodTrp	 := ""
	Local cVLCNPJ   :=  SuperGetMV('MV_VLCNPJ',,'1')

	/*Verificar se há somente um documento com a chave ou número informado. Se houver, este será utilizado.
	  Do contrário, faz a regra de buscar o documento com trecho pago e transportador informado. */

	cEmisDC  := aChaves[1]
	cSerDC   := aChaves[2]
	cFilDC   := aChaves[3]
	cDANFE   := aChaves[4]
	aNrDc 	 := aChaves[5]

	If Len(aChaves) == 6
		cCodTrp := Alltrim(A118EMIT("1", aChaves[6], {}))
	EndIf

	//------------------------------------------------------------------------------
	// Contagem de documentos de carga
	//------------------------------------------------------------------------------
	GFELog115:AddDebug("# Contagem de Documentos de Carga.", 1)	

	cQuery := "SELECT COUNT(*) GW1_COUNT"
	cQuery += " FROM " + RetSQLName("GW1") + " GW1"
	cQuery += " WHERE "
		
	If !Empty(cDANFE)
		cWhere += " GW1.GW1_DANFE = '" + cDANFE + "'"
	Else
		cWhere += " GW1.GW1_NRDC IN ( "
		
		For nX:= 1 to Len(aNrDc)
			cNrDc := aNrDc[nX]
			If nX >= 2
				cWhere += ", "
			EndIf			
			cWhere += "'" + cNrDc + "'"
		Next
		
		cWhere += " ) "			
		
		cWhere += " AND GW1.GW1_EMISDC = '" + cEmisDC + "'"

		If __lCpoSr
			cWhere += " AND GW1.GW1_SDOC = '" + cSerDC + "'"
		Else
			cWhere += " AND GW1.GW1_SERDC = '" + cSerDC + "'"
		EndIf
	EndIf			

	If !Empty(cFilDC)
		cWhere += " AND GW1.GW1_FILIAL = '" + cFilDC + "' " 
	EndIf
	cWhere += " AND GW1.D_E_L_E_T_ = ' ' "	
	
	cQuery += cWhere
	
	GFELog115:AddDebug("# SQL: " + cQuery, 1)	

	cAliasGW1 := MpSysOpenQuery(ChangeQuery(cQuery))
	nCount := (cAliasGW1)->GW1_COUNT 

	DO CASE
	CASE nCount == 0

		(cAliasGW1)->(DBCloseArea())

		GFELog115:AddDebug("# Nenhum documento encontrado. Buscando Documentos de Origem...", 1)

		If lExisGXP
			cQuery := ;
			" SELECT " + ;
				" GW1.GW1_FILIAL, " + ;
				" GW1.GW1_EMISDC, " + ;
				" GW1.GW1_SERDC, " + ;
				" GW1.GW1_NRDC, " + ;
				" GW1.GW1_CDTPDC, " + ;
				" GW1.GW1_CDREM, " + ;
				" GW1.GW1_CDDEST, " + ;
				" GW1.GW1_ENTNRC, " + ;
				" GW1.GW1_USO, " + ;
				" GW1.GW1_ICMSDC, " + ;
				" GW1.GW1_NRROM	 " + ;	
			" FROM " + RetSQLName("GW1") + " GW1 " + ;
			" INNER JOIN " + RetSQLName("GXP") + " GXP ON" + ;
				" GXP.GXP_FILIAL = GW1.GW1_FILIAL AND" + ;
				" GXP.GXP_CDTPDC = GW1.GW1_CDTPDC AND" + ;
				" GXP.GXP_EMISDC = GW1.GW1_EMISDC AND" + ;
				" GXP.GXP_SERDC  = GW1.GW1_SERDC  AND" + ;
				" GXP.GXP_NRDC   = GW1.GW1_NRDC   AND" + ;				
				" GXP.D_E_L_E_T_ = ' ' " + ;
			" WHERE " + ;
			cWhere + ;		
			" ORDER BY " + ;
				" GXP.GXP_SERDC DESC"
			
			GFELog115:AddDebug("# SQL: " + cQuery, 1)	

			cAliasGXP := MpSysOpenQuery(ChangeQuery(cQuery))

			If (cAliasGXP)->(Eof())
				GFELog115:Add("# Busca documento com mesmo número não encontrou registro. Emissor: " + Alltrim(cEmisDC), 1)	
				oDocJSON['ACHOU_DOC'] := .F.	
				oDocJSON['GW1_SERDC'] := PadR(" ",Len(cSerDC))			
			Else				
				oDocJSON['ACHOU_DOC']	:= .T.
				oDocJSON['GW1_FILIAL'] 	:= (cAliasGXP)->GW1_FILIAL
				oDocJSON['GW1_EMISDC'] 	:= (cAliasGXP)->GW1_EMISDC
				oDocJSON['GW1_SERDC'] 	:= (cAliasGXP)->GW1_SERDC
				oDocJSON['GW1_NRDC'] 	:= (cAliasGXP)->GW1_NRDC
				oDocJSON['GW1_CDTPDC'] 	:= (cAliasGXP)->GW1_CDTPDC
				oDocJSON['GW1_CDREM'] 	:= (cAliasGXP)->GW1_CDREM
				oDocJSON['GW1_CDDEST'] 	:= (cAliasGXP)->GW1_CDDEST
				oDocJSON['GW1_ENTNRC'] 	:= (cAliasGXP)->GW1_ENTNRC
				oDocJSON['GW1_USO'] 	:= (cAliasGXP)->GW1_USO
				oDocJSON['GW1_ICMSDC'] 	:= (cAliasGXP)->GW1_ICMSDC
				oDocJSON['GW1_NRROM'] 	:= (cAliasGXP)->GW1_NRROM			
			EndIf

			(cAliasGXP)->(dbCloseArea())
		Else
			GFELog115:Add("# Busca documento com mesmo número não encontrou registro.", 1)	
			oDocJSON['ACHOU_DOC'] := .F.
			oDocJSON['GW1_SERDC'] := PadR(" ",Len(cSerDC))			
		EndIf
				
		Return

	CASE nCount == 1		
		
		(cAliasGW1)->(DBCloseArea()) 

		GFELog115:AddDebug("# 1 documento encontrado. Busca documento com mesmo número...", 1)
		
		cQuery := "SELECT GW1.GW1_FILIAL"
		cQuery += ", GW1.GW1_EMISDC"
		cQuery += ", GW1.GW1_SERDC"
		cQuery += ", GW1.GW1_NRDC"
		cQuery += ", GW1.GW1_CDTPDC"
		cQuery += ", GW1.GW1_CDREM"
		cQuery += ", GW1.GW1_CDDEST"
		cQuery += ", GW1.GW1_ENTNRC"
		cQuery += ", GW1.GW1_USO"
		cQuery += ", GW1.GW1_ICMSDC"
		cQuery += ", GW1.GW1_NRROM"
		cQuery += " FROM " + RetSQLName("GW1") + " GW1"
		If !Empty(cCodTrp)
			cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU"
			cQuery += " ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
			cQuery += " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
			cQuery += " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
			cQuery += " AND GWU.GWU_SERDC = GW1.GW1_SERDC"
			cQuery += " AND GWU.GWU_NRDC = GW1.GW1_NRDC"
			IF cVLCNPJ == "2"
				cEmit := GFEGetEmRz(cCodTrp)
				If SubStr(AllTrim(cEmit),1,8) == SubStr(AllTrim(cCodTrp),1,8)
					cQuery += " AND GWU.GWU_CDTRP IN ('" + Alltrim(cEmit) + "')"
				ElseIf SubStr(AllTrim(cCodTrp),1,8) $ AllTrim(cEmit)	// Tratamento para a LSL Transportes devido a particularidade de mesma nota de mesmo emissor em filiais diferentes
					cQuery += " AND GWU.GWU_CDTRP IN ('" + Alltrim(cCodTrp) + "')"
				EndIf
			Else
				cQuery += " AND GWU.GWU_CDTRP = '" + cCodTrp + "'"
			EndIf
			cQuery += " AND GWU.D_E_L_E_T_ = ' '"	
		EndIf
		cQuery += " WHERE " + cWhere

		GFELog115:AddDebug("# SQL: " + cQuery, 1)	

		cAliasGW1 := MpSysOpenQuery(ChangeQuery(cQuery))
		If (cAliasGW1)->(!Eof())
			GFELog115:Add("# Busca documento com mesmo número encontrou 1 registro. Filial: " + (cAliasGW1)->GW1_FILIAL, 1)

			oDocJSON['ACHOU_DOC'] 	:= .T.
			oDocJSON['GW1_FILIAL'] 	:= (cAliasGW1)->GW1_FILIAL
			oDocJSON['GW1_EMISDC'] 	:= (cAliasGW1)->GW1_EMISDC
			oDocJSON['GW1_SERDC'] 	:= (cAliasGW1)->GW1_SERDC
			oDocJSON['GW1_NRDC'] 	:= (cAliasGW1)->GW1_NRDC
			oDocJSON['GW1_CDTPDC'] 	:= (cAliasGW1)->GW1_CDTPDC
			oDocJSON['GW1_CDREM'] 	:= (cAliasGW1)->GW1_CDREM
			oDocJSON['GW1_CDDEST'] 	:= (cAliasGW1)->GW1_CDDEST
			oDocJSON['GW1_ENTNRC'] 	:= (cAliasGW1)->GW1_ENTNRC
			oDocJSON['GW1_USO'] 	:= (cAliasGW1)->GW1_USO
			oDocJSON['GW1_ICMSDC'] 	:= (cAliasGW1)->GW1_ICMSDC
			oDocJSON['GW1_NRROM'] 	:= (cAliasGW1)->GW1_NRROM	
		EndIf

		(cAliasGW1)->(DBCloseArea())
		Return

	OTHERWISE
		
		(cAliasGW1)->(DBCloseArea()) 
		
		//Verificação da filial que possui o documento de carga com trecho pago e transportador informado.		
		GFELog115:Add("# Busca documento com mesmo número encontrou mais de 1 registro.",1)		
		
		cQuery := ;
		" SELECT " + ;
			" GW1.GW1_FILIAL, " + ;
			" GW1.GW1_EMISDC, " + ;
			" GW1.GW1_SERDC, " + ;
			" GW1.GW1_NRDC, " + ;
			" GW1.GW1_CDTPDC, " + ;
			" GW1.GW1_CDREM, " + ;
			" GW1.GW1_CDDEST, " + ;
			" GW1.GW1_ENTNRC, " + ;
			" GW1.GW1_USO, " + ;
			" GW1.GW1_ICMSDC, " + ;
			" GW1.GW1_NRROM	 " + ;
		" FROM " + RetSQLName("GW1") + " GW1 " + ;
		" INNER JOIN " + RetSQLName("GWU") + " GWU ON " + ;
			" GWU.GWU_FILIAL = GW1.GW1_FILIAL " + ;
			" AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC " + ;
			" AND GWU.GWU_EMISDC = GW1.GW1_EMISDC " + ;
			" AND GWU.GWU_SERDC  = GW1.GW1_SERDC " + ;
			" AND GWU.GWU_NRDC   = GW1.GW1_NRDC " + ;
			" AND GWU.GWU_PAGAR  = '1' "  + ;
			" AND GWU.GWU_CDTRP <> ' ' "  + ;
			" AND GWU.D_E_L_E_T_ = ' ' " + ;	
		" WHERE " + ;
			cWhere + ;
		" ORDER BY " + ;
			" GW1.GW1_DTEMIS DESC "
		
		ChangeQuery(cQuery)	
		GFELog115:Add("# Busca documento com trecho pago e transportador informado. SQL: [" + cQuery + "]", 1)

		cAliasGW1 := MpSysOpenQuery(cQuery)
		If !(cAliasGW1)->(Eof())

			GFELog115:Add("# Busca documento com trecho pago e transportador informado. Filial: " + (cAliasGW1)->GW1_FILIAL,1)
			
			oDocJSON['ACHOU_DOC'] 	:= .T.
			oDocJSON['GW1_FILIAL'] 	:= (cAliasGW1)->GW1_FILIAL
			oDocJSON['GW1_EMISDC'] 	:= (cAliasGW1)->GW1_EMISDC
			oDocJSON['GW1_SERDC'] 	:= (cAliasGW1)->GW1_SERDC
			oDocJSON['GW1_NRDC'] 	:= (cAliasGW1)->GW1_NRDC
			oDocJSON['GW1_CDTPDC'] 	:= (cAliasGW1)->GW1_CDTPDC
			oDocJSON['GW1_CDREM'] 	:= (cAliasGW1)->GW1_CDREM
			oDocJSON['GW1_CDDEST'] 	:= (cAliasGW1)->GW1_CDDEST
			oDocJSON['GW1_ENTNRC'] 	:= (cAliasGW1)->GW1_ENTNRC
			oDocJSON['GW1_USO'] 	:= (cAliasGW1)->GW1_USO
			oDocJSON['GW1_ICMSDC'] 	:= (cAliasGW1)->GW1_ICMSDC
			oDocJSON['GW1_NRROM'] 	:= (cAliasGW1)->GW1_NRROM	
		Else
			//Apesar de encontrar mais de um documento, pode ser que em ambas as filiais estejam com transportador em branco ou tipo de frete não pago.
			GFELog115:Add("# Busca documento com trecho pago e transportador informado não encontrou registro.",1)
			oDocJSON['ACHOU_DOC'] 	:= .F.
			oDocJSON['GW1_SERDC'] := PadR(" ",Len(cSerDC))			
		EndIf

		(cAliasGW1)->(DBCloseArea())
		Return

	ENDCASE		

Return
