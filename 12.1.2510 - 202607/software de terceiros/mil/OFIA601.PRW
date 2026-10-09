#INCLUDE "Protheus.ch"
#INCLUDE "OFIA601.ch"

Static cOFIA601 := 'OFIA601' // Rotina
Static cBKPFil  := cFilAnt

/*/{Protheus.doc} OFIA601
    Cancelamento de pedido de compas - Processamento de arquivos CANCBO    
    @type Function
    @author Emanuel Furtado
    @since 08/12/2025	
/*/
Function OFIA601(aParam)
	Local cPergunta := "OFIA601"
	local cAliasDB := 'VEI'
	Local lContinua

	Private cExtensao := '.DAT'
	Private lSchedule := FWGetRunSchedule()

	Default aParam   := { }

	lContinua := lSchedule
	if ! lContinua .and. ! Pergunte(cPergunta, .T., STR0002) //STR0002 #Cancelamento de Pedido
		return .t.
	endif

	If OA601001F_TudoOk()
		Processa({|| OA601002F_ProcessaCancelamento(cAliasDB) }, STR0006+" CANCBO...") //STR0006 #Processando arquivos
	EndIf

Return .T.

/*/{Protheus.doc} OA601003F_Valid
    Valida os parâmetros da tela (chamado pelo X1_VALID de cada pergunta)    
    @author Emanuel Furtado
    @since 08/12/2025
/*/
Function OA601003F_Valid()
	Local lRet      := .T.
	Local cDirBusca := nOR(GETF_RETDIRECTORY,GETF_ONLYSERVER)
	Local cVar      := ReadVar()
	Local cDirSel   := ""
	Local aGrupos   := {}
	Local nI        := 0
	default cExtensao := '.DAT'
	default lSchedule := FWGetRunSchedule() 

	Do Case
		// MV_PAR01 - Diretório CANCBO (Obrigatório)
	Case cVar == 'MV_PAR01'
		If Empty(MV_PAR01)
			cDirSel := cGetFile( STR0005+' | *'+cExtensao, "",,,, cDirBusca, .T., .T.) //STR0005 #Diretorio

			If !Empty(cDirSel)
				If ExistDir(cDirSel)
					MV_PAR01 := cDirSel
				Else
					FMX_HELP("OA601ERR001",STR0008) //STR0008 #Diretorio nao informado!
					lRet := .F.
				EndIf
			Else
				
				FMX_HELP("OA601ERR002",STR0014+" "+STR0007) //STR0014 #Campo obrigatorio! //STR0007 #Diretorio informado nao existe! 
				
				lRet := .F.
			EndIf
		Else
			If !ExistDir(MV_PAR01)				
				FMX_HELP("OA601ERR003",STR0008) //STR0008 #Diretorio não informado!

				lRet := .F.
			EndIf
		EndIf

		// MV_PAR02 - Grupos (Obrigatório)
	Case cVar == 'MV_PAR02'
		If !Empty(MV_PAR02)
			aGrupos := StrTokArr(AllTrim( transform(MV_PAR02,'@R !!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/') ), "/")

			For nI := 1 To Len(aGrupos)
				aGrupos[nI] := AllTrim(aGrupos[nI])

				If !Empty(aGrupos[nI]) .And. !ExistCpo('SBM', aGrupos[nI])
					FMX_HELP("OA601ERR004",STR0012 + aGrupos[nI]) //STR0012 #Grupo de produto não identificado no sistema! 
					lRet := .F.
					Exit
				EndIf
			Next nI
		Else			
			FMX_HELP("OA601ERR005",STR0014+" "+STR0015) //STR0014 #Campo obrigatorio! //STR0015 #Informe pelo menos um grupo.

			lRet := .F.
		EndIf

		// MV_PAR03 - Ação após Processamento
	Case cVar == 'MV_PAR03'
		If MV_PAR03 != 2
			MV_PAR04 := Space(150)
		EndIf

		// MV_PAR04 - Diretório Destino
	Case cVar == 'MV_PAR04'
		If MV_PAR03 == 2
			If Empty(MV_PAR04)
				cDirSel := cGetFile(STR0005,'',,"",.T.,cDirBusca,.T.,.T.) //STR0005 #Diretorio
				If !Empty(cDirSel)
					If ExistDir(cDirSel)
						MV_PAR04 := cDirSel
					Else
						
						FMX_HELP("OA601ERR006",STR0008) //STR0008 #Diretorio nao informado!

						lRet := .F.
					EndIf
				Else										
					FMX_HELP("OA601ERR007",STR0011) //STR0011 #Informe o diretorio de destino para mover os arquivos!
					lRet := .F.
				EndIf
			Else
				If !ExistDir(MV_PAR04)
					FMX_HELP("OA601ERR008",STR0008) //STR0008 #Diretorio nao informado!
					lRet := .F.
				EndIf
			EndIf
		Else
			MV_PAR04 := Space(150)
		EndIf
	EndCase

Return lRet

/*/{Protheus.doc} OA601001F_TudoOk
    Validação final após confirmação da tela (opcional)    
    @author Emanuel Furtado
    @since 08/12/2025
/*/
Static Function OA601001F_TudoOk()
	Local lRet := .T.

	If Empty(MV_PAR01)
		FMX_HELP("OA601ERR009",STR0007) //STR0007 #Diretorio informado nao existe!

		lRet := .F.
	EndIf

	If lRet .And. Empty(MV_PAR02)
		FMX_HELP("OA601ERR010",STR0013) //STR0013 #Grupo de produto nao informado!
		lRet := .F.
	EndIf

	If lRet .And. MV_PAR03 == 2 .And. Empty(MV_PAR04)
			FMX_HELP("OA601ERR011",STR0009) //STR0009 #Diretorio de destino nao informado! 
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} OA601002F_ProcessaCancelamento
    Processa os arquivos CANCBO conforme parâmetros    
    @author Emanuel Furtado
    @since 08/12/2025
/*/
Static Function OA601002F_ProcessaCancelamento(cAliasDB)
	Local cDirOrigem  := AllTrim(MV_PAR01)
	Local cGrupos     := AllTrim(Transform(MV_PAR02, "@R !!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/"))
	Local nAcao       := MV_PAR03
	Local cDirDestino := AllTrim(MV_PAR04)
	Local aArquivos   := {}
	Local nI          := 0
	Local nLinhasCanceladas := 0
	Local nTotalCancelados := 0
	Local nRet := 0
	Local cStatusLog := ''
	Local nPosMsgOk := 0
	Local nPosMsgErr := 0
	Local lTemSucesso := .T.
	Local lTemErro := .T.
	Local lSucesso := .T.
	Local cMsgArq := ""
	Local cArqOrigem := ''
	Local cArqDestino := '' 

	Private cMsgErrArq := ''
	Private cMsgErrLin := ''
	Private cMsgOkArq := ''
	Private cMsgOkLin := ''
	Private aMsg := {}
	Private aMsgAux := {}

	Default cAliasDB := 'VEI'

	aLogPergunte := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04}

	DbSelectArea(cAliasDB)

	aArquivos := Directory(cDirOrigem + "*" + cExtensao)

	If Len(aArquivos) == 0
			FMX_HELP("OA601ERR012",STR0010 + " ( " + cExtensao + " )") //STR0010 #Nenhum arquivo encontrado no diretorio informado!
		Return .F.
	EndIf

	OA601007F_LogOperacao(STR0042, STR0006 + ' ' + STR0001) //STR0042 #Inicio //STR0006 #Processando arquivos //STR0001 #SCRM Scania

	//Ex: Inicio: 05/12/2025 10:55:12 | Empresa: 99 | Filial: 01 | Usuário: 000000 | Processando: MANUAL (Menu) 50
	OA601007F_LogOperacao(STR0016,; //#STR0016 "Processando"
	STR0042 + ': ' + DToC(dDataBase) + ' ' + Time() + ' | ' +; //#STR0042 "Inicio"
	STR0046 + ': ' + cEmpAnt + ' | ' +; //#STR0046 "Empresa"
	STR0047 + ': ' + cFilAnt + ' | ' +; //#STR0047 "Filial"
	STR0048 + ': ' + __cUserId + ' | ' +; //#STR0048 "Usuário"
	STR0016 + ': ' + Iif(lSchedule, STR0049, STR0050)) //#STR0016 "Processando" //#STR0049 "AUTOMATICO (Schedule)" //#STR0050 "MANUAL (Menu)"

	ProcRegua(Len(aArquivos))

	For nI := 1 To Len(aArquivos)
		IncProc(STR0016 + ': ' + aArquivos[nI][1]) //STR0016 #Processando

		nLinhasCanceladas := OA601004F_LerArquivo(cDirOrigem + aArquivos[nI][1], cGrupos)

		If nLinhasCanceladas > 0
			nTotalCancelados++
			lSucesso := .F.
			cMsgArq := ""

			Do Case
			Case nAcao == 1  // "NENHUMNA_ACAO"
				lSucesso := .T.
				cStatusLog := STR0056  //STR0056 "NENHUMA AÇÃO"
				cMsgArq := STR0057+''+cDirOrigem + aArquivos[nI][1] //STR0057 "Nenhuma ação foi executada sobre o arquivo."
			Case nAcao == 2  // Mover Arquivo
				cStatusLog := STR0034  //STR0034 'MOVER_ARQUIVO'

				If !Empty(cDirDestino)
					cArqOrigem := cDirOrigem + aArquivos[nI][1]
					cArqDestino := cDirDestino + aArquivos[nI][1]
					
					Copy File &(cArqOrigem) to &(cArqDestino)
					If File(cArqDestino)
						nRet := FErase(cArqOrigem)

						If nRet >= 0
							lSucesso := .T.
							cMsgArq := STR0032 + ' ' + cArqDestino //#STR0032 "Arquivo enviado para pasta de destino ! "
						Else
							cMsgArq := STR0031 + ' ' + cArqOrigem + ' >>> ' + cArqDestino //#STR0031 "Houve um problema ao tentar copiar/deletar arquivo! Favor conferir."

						EndIf
					Else
						cMsgArq := STR0031 + ' ' + cArqOrigem + ' >>> ' + cArqDestino //#STR0031 "Houve um problema ao tentar copiar/deletar arquivo! Favor conferir."
					EndIf
				EndIf

			Case nAcao == 3  // Apagar Arquivo
				cStatusLog := STR0035  //#STR0035 'APAGAR_ARQUIVO'
				nRet := FErase(cDirOrigem + aArquivos[nI][1])

				If nRet >= 0
					lSucesso := .T.
					cMsgArq := STR0033 + ' ' + cDirOrigem + aArquivos[nI][1] //#STR0033 "Arquivo deletado ! "
				Else
					cMsgArq := STR0031 + ' ' + cDirOrigem + aArquivos[nI][1] //#STR0031 "Houve um problema ao tentar copiar/deletar arquivo! Favor conferir."
				EndIf
			EndCase

			aMsgAux := {} //statuslog do nada a fazer... ou passa ou cria...
			aAdd(aMsgAux, Iif(lSucesso, replace(STR0020,':',''), replace(STR0030,':',''))) //#STR0020 "Sucesso" //#STR0030 "Erro"
			aAdd(aMsgAux, {replace(cStatusLog,':',''), replace(cMsgArq,':','')})
			aAdd(aMsg, aMsgAux)
		EndIf
	Next nI

	nPosMsgOk := aScan(aMsg, {|x| ValType(x[1]) == "C" .and. AllTrim(x[1]) == AllTrim(replace(STR0020,':',''))}) //#STR0020 "Sucesso" 
	nPosMsgErr := aScan(aMsg, {|x| ValType(x[1]) == "C" .and. AllTrim(x[1]) == AllTrim(replace(STR0030,':',''))}) //#STR0030 "Erro"

	lTemSucesso := (nPosMsgOk > 0)
	lTemErro := (nPosMsgErr > 0)

	Do Case
	Case lTemSucesso .and. !lTemErro
		If !lSchedule
			FWAlertSuccess(STR0017, "OA601OK") //#STR0017 "Processamento concluído!"
		Endif
		cStatusLog := STR0018+' '+STR0020 //#STR0018 "Arquivos processados:" //#STR0020 "Sucesso"
	Case lTemErro .and. !lTemSucesso
		FMX_HELP("OA601ERR013",STR0017 + ' ' + STR0044 + ' ' + STR0045) //#STR0017 "Processamento concluído!" #STR0044 "Problemas encontrados." #STR0045 "Verifique os logs de processamento!"
		cStatusLog := STR0030+ ' ' + STR0044 + ' ' + STR0045 //#STR0030 "Erro" #STR0044 "Problemas encontrados." #STR0045 "Verifique os logs de processamento!"
	Case lTemSucesso .and. lTemErro
		FMX_HELP("OA601ERR014",STR0017 + ' ' + STR0044 + ' ' + STR0045) //#STR0017 "Processamento concluído!" #STR0044 "Problemas encontrados." #STR0045 "Verifique os logs de processamento!"
		cStatusLog := STR0019+ ': ' + STR0044 + ' ' + STR0045 //#STR0019 "Atenção" #STR0044 "Problemas encontrados." #STR0045 "Verifique os logs de processamento!"
	EndCase

	OA601007F_LogOperacao(STR0016, cStatusLog, aMsg, , aLogPergunte) //STR0016 //Processando
	OA601007F_LogOperacao(STR0043, STR0017, ,.T.) //STR0017 //processamento concluido //STR0043 //Fim

Return .T.

/*/{Protheus.doc} OA601004F_LerArquivo
    Lê e processa arquivo CANCBO DAT    
    @author Emanuel Furtado
    @since 12/12/2025
/*/
Static Function OA601004F_LerArquivo(cArquivo, cGrupos)
	Local nHandle   := 0
	Local cLinha    := ""
	Local aLinhas   := {}
	Local nI        := 0
	Local nProc      := 0

	nHandle := FT_FUse(cArquivo)

	If nHandle == -1
			FMX_HELP("OA601ERR015",STR0021 + cArquivo) //STR0021 #Erro ao abrir arquivo: 
		Return .F.
	EndIf

	FT_FGoTop()

	While !FT_FEOF()
		cLinha := FT_FReadLn()
		If !Empty(AllTrim(cLinha))
			AAdd(aLinhas, AllTrim(cLinha))
		EndIf
		FT_FSKIP()
	Enddo

	FT_FUSE()

	For nI := 1 To Len(aLinhas)
		If OA601005F_ProcessarE03(aLinhas[nI], cGrupos)
			nProc++
		EndIf
	Next nI
	OA601011K_RestauraFilial()
Return nProc

/*/{Protheus.doc} OA601005F_ProcessarE03
    Processa linha E03 do arquivo CANCBO    
    @author Emanuel Furtado
    @since 12/12/2025
/*/
Static Function OA601005F_ProcessarE03(cLinha, cGrupos)
	Local aCampos     := {}
	Local cSegmento   := ""
	Local cPedFabrica := ""
	Local cProduto    := ""
	Local nQtdCancel  := 0
	Local cSC7Num     := ""
	Local lRet        := .T.
	Local aGruposVal  := StrTokArr(cGrupos, "/")
	Local nI          := 0
	Local lGrupoOk    := .F.
	local cCodMarca   := OC540009K_CodMarcaVEI()
	local cPedAno     := getNewPar("MV_PEDANO","N")
	local aMsgAux	  :={}
	local cLinhaAux   := ''
	local cFilCancBO  := xFilial('SC7')

	cCodMarca := PADR(cCodMarca,TamSX3("VEI_CODMAR")[1])
	aCampos := StrTokArr(cLinha, ",")

	If Len(aCampos) > 0
		For nI := 1 To Len(aCampos)
			aCampos[nI] := StrTran(aCampos[nI], '"', '')
		Next nI

		cSegmento := aCampos[1]   // Campo 1
	endif

	if cSegmento != "E03"
		Return .F.
	EndIf

	if cSegmento == "E03" .and. Len(aCampos) < 10
		cLinhaAux := replace(cLinha,'"','')
		cLinhaAux := replace(cLinhaAux,',','|')
		cLinhaAux := replace(cLinhaAux,':',' ')
		cMsgErrLin := replace(STR0022,':','') + " - " + alltrim(cLinhaAux) //#STR0022 "Linha inválida no arquivo"

		aMsgAux:={}
		aadd(aMsgAux,replace(STR0030,':','')) //#STR0030 "Erro"
		aadd(aMsgAux,{replace(STR0036,':',''),cMsgErrLin}) //STR0036 "ERRO FORMATO"

		aadd(aMsg, aMsgAux)
		Return .F.
	EndIf

	cFilCancBO 	:= OA542019N_DeParaFilialPorConcess(aCampos[2])
	OA601010K_SetaFilialProcessamento(cFilCancBO)
	cProduto    := aCampos[4]   // Campo 4 - Código da peça
	nQtdCancel  := Val(aCampos[10]) // Campo 10 - Quantidade cancelar

	if cPedAno == "S"
		cPedFabrica := alltrim(aCampos[3]) + "/" + right(DtoC(date()),2)
	else
		cPedFabrica := alltrim(aCampos[3])
	endif

	// Busca pedido SC7 na VEI (num.PC x num.Fabrica)
	VEI->(DbSetOrder(2)) // VEI_FILIAL+VEI_CODMAR+VEI_PEDFAB
	If !VEI->(DbSeek(xFilial("VEI") + cCodMarca + cPedFabrica))
		cLinhaAux := replace(cLinha,'"','')
		cLinhaAux := replace(cLinhaAux,',','|')
		cLinhaAux := replace(cLinhaAux,':',' ')

		cMsgErrLin := replace(STR0024,':','') +' - '+ alltrim(cLinhaAux) //#STR0024 "Pedido fábrica não encontrado: "
		aMsgAux:={}
		aadd(aMsgAux,replace(STR0030,':','')) //#STR0030 "Erro"
		aadd(aMsgAux,{replace(STR0036,':',''),cMsgErrLin}) //STR0036 "ERRO FORMATO"

		aadd(aMsg, aMsgAux)

		Return .F.
	EndIf

	cSC7Num := VEI->VEI_NUM

	For nI := 1 To Len(aGruposVal)
		if ! empty( aGruposVal[nI] )
			cProdutoCompleto := PADR(aGruposVal[nI],TamSX3("BM_GRUPO")[1]) + AllTrim(cProduto)

			SB1->(DbSetOrder(7)) // B1_FILIAL + B1_GRUPO + B1_CODITE
			If SB1->(DbSeek(xFilial("SB1") + cProdutoCompleto))
				lGrupoOk := .T.
				cProduto := SB1->B1_COD
				Exit
			EndIf
		EndIf
	Next nI

	If !lGrupoOk
		cMsgErrLin := replace(STR0025,':','') + " ( " + cGrupos + " ) "+cProduto //#STR0025 "Produto não encontrado: "
		aMsgAux:={}
		aadd(aMsgAux,replace(STR0030,':','')) //#STR0030 "Erro"
		aadd(aMsgAux,{replace(STR0038,':',''),cMsgErrLin}) //#STR0038 "ERRO PRODUTO"

		aadd(aMsg, aMsgAux)

		Return .F.
	EndIf

	lRet := OA601006F_EliminarResiduo(cSC7Num, cProduto, nQtdCancel)
Return lRet

/*/{Protheus.doc} OA601006F_EliminarResiduo
    Elimina resíduo do pedido de compra    
    @author Emanuel Furtado
    @since 12/12/2025
/*/
Static Function OA601006F_EliminarResiduo(cSC7Num, cProduto, nQtdCancel)
	Local cMsgVld := ""
	Local lRet    := .F.
	Local lAchou  := .F.

	SC7->(DbSetOrder(1)) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	SC7->(DbSeek(xFilial("SC7") + cSC7Num))

	While !SC7->(Eof()) .And. SC7->C7_NUM == cSC7Num
		If AllTrim(SC7->C7_PRODUTO) == AllTrim(cProduto)
			lAchou := .T.
			cMsgVld := ""

			lRet := OA601008F_ElimRes(@cMsgVld,;                    // Mensagem retorno
			100,;                         // Percentual 100%
			SC7->C7_EMISSAO,;            // Data emissão DE
			SC7->C7_NUM,;                // Pedido DE
			SC7->C7_PRODUTO,;            // Produto DE
			1,;                          // Tipo: Pedido Compra
			SC7->C7_FORNECE,;            // Fornecedor DE
			2,;                          // Elimina SC com OP: NÃO
			'')                        // Posição item

			If lRet
				cMsgOkLin := STR0028 + " | (SC7) " + SC7->C7_NUM + " / " + SC7->C7_ITEM + " - " + SC7->C7_PRODUTO //#STR0028 "Eliminação de resíduo realizada com sucesso"
				cMsgOkLin := replace(cMsgOkLin,':','')
				aMsgAux:={}
				aadd(aMsgAux,replace(STR0020,':','')) //#STR0020 "Sucesso"
				aadd(aMsgAux,{STR0039,cMsgOkLin}) //#STR0039 "SUCESSO ELIMINACAO"

				aadd(aMsg, aMsgAux)
			Else
				cMsgErrLin := STR0029 + cMsgVld + " | (SC7) " + SC7->C7_NUM + " / " + SC7->C7_ITEM //#STR0029 "Erro na eliminação de resíduo: "
				cMsgErrLin := replace(cMsgErrLin,':','')
				aMsgAux:={}
				aadd(aMsgAux,replace(STR0030,':','')) //#STR0030 "Erro"
				aadd(aMsgAux,{STR0040,cMsgErrLin}) //#STR0040 "ERRO ELIMINACAO"

				aadd(aMsg, aMsgAux)
			EndIf

			Exit
		EndIf
		SC7->(DbSkip())
	End

	If !lAchou
		cMsgErrLin := STR0027 + cProduto + " - " + cSC7Num //#STR0027 "Produto não encontrado no pedido: "
		cMsgErrLin := replace(cMsgErrLin,':',' ')
		aMsgAux:={}
		aadd(aMsgAux,replace(STR0030,':','')) //#STR0030 "Erro"
		aadd(aMsgAux,{replace(STR0041,':',''),cMsgErrLin}) //#STR0041 "ERRO SC7"

		aadd(aMsg, aMsgAux)

		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} OA601008F_ElimRes
   Realiza a eliminação de resíduo no pedido de compras
   @author Emanuel Furtado
   @since 05/08/2024
   /*/
static function OA601008F_ElimRes(cMsgVld, nPerc, dEmissao, cPedido, cProduto, nTipoPC, cForn, nEliSCOP, cPosicao)
	local lRet := .T.
	local aPergunte := {}
	local aErroAuto := {}
	local nLen := 0
	local nI := 0

	default cMsgVld    := ""
	default nPerc      := 100 // mv_par01 - Percentual Maximo
	default dEmissao   := ctod("") // mv_par02 e mv_par03 - Data de Emissao de / Data de Emissao ate
	default cPedido    := "" // mv_par04 e mv_par05 - Solic/Pedido de / Solic/Pedido ate
	default cProduto   := "" // mv_par06 e mv_par07 - Produto de / Produto ate
	default nTipoPC    := 1 // mv_par08 - Elimina Residuo por (1 - Pedido Compra, 2 - Aut. de Entrega, 3 - Pedido/Aut.Ent, 4 - Contr.Parceria e 5 - Solic.Compras)
	default cForn      := "" // mv_par09 e mv_par10 - Fornecedor de / Fornecedor ate
	default dDtIni     := ctod("01/01/2000") // mv_par11 - Data de Entrega de
	default dDtFim     := ctod("31/12/2200") // mv_par12 - Data de Entrega ate
	default nEliSCOP   := 2  // mv_par13 - Elimina SC com OP (1 - Sim, 2 - Não)
	default cPosicao   := "" // mv_par14 e mv_par15 - A partir do Item / Até o Item

	// variável de controle interno da rotina automática que informa se houve erro durante o processamento.
	private lMsErroAuto := .F.
	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	private lMsHelpAuto := .T.
	// força a gravação das informações de erro em array para manipulação da gravação.
	private lAutoErrNoFile := .T.

	aPergunte := {}
	Pergunte("MTA235",.F.,,,,, @aPergunte)

	mv_par01 := nPerc
	mv_par02 := dEmissao
	mv_par03 := dEmissao
	mv_par04 := cPedido
	mv_par05 := cPedido
	mv_par06 := cProduto
	mv_par07 := cProduto
	mv_par08 := nTipoPC
	mv_par09 := cForn
	mv_par10 := cForn
	mv_par11 := dDtIni
	mv_par12 := dDtFim
	mv_par13 := nEliSCOP
	mv_par14 := alltrim(cPosicao)
	mv_par15 := iif(!empty(cPosicao),alltrim(cPosicao),"ZZZZZZ")
	
	SetMVValue("MTA235","mv_par01", nPerc)
	SetMVValue("MTA235","mv_par02", dEmissao)
	SetMVValue("MTA235","mv_par04", cPedido)
	SetMVValue("MTA235","mv_par05", cPedido)
	SetMVValue("MTA235","mv_par06", cProduto)
	SetMVValue("MTA235","mv_par07", cProduto)
	SetMVValue("MTA235","mv_par08", nTipoPC)
	SetMVValue("MTA235","mv_par09", cForn)
	SetMVValue("MTA235","mv_par10", cForn)
	SetMVValue("MTA235","mv_par11", dDtIni)
	SetMVValue("MTA235","mv_par12", dDtFim)
	SetMVValue("MTA235","mv_par13", nEliSCOP)
	SetMVValue("MTA235","mv_par14", alltrim(cPosicao))
	SetMVValue("MTA235","mv_par15", iif(!empty(cPosicao),alltrim(cPosicao),"ZZZZZZ"))

	MsExecAuto({|x| lRet := MATA235(x)}, .T. )

	lRet := !lMsErroAuto
	if lMsErroAuto
		aErroAuto := GetAutoGRLog()
		nLen := Len(aErroAuto)
		for nI := 1 to nLen
			cMsgVld += aErroAuto[nI] + CRLF
		next
	endif
return lRet

/*/{Protheus.doc} OA601007F_LogOperacao
    Registra log das operações    
    @author Emanuel Furtado
    @since 12/12/2025
/*/
Static Function OA601007F_LogOperacao(cTipo, cDados, aMsgExtra, lHoraFim, aParamAux)
	Local oLogger := DMS_Logger():New()
	local cRotina := 'OFIA601'
	local aData := {}

	Local jLog  As JSon
	Local jItem As JSon
	Local nX := 0
	local cJson := ''

	default aMsgExtra := ''
	default lHoraFim := .f.
	default aParamAux := {}

	if len(aMsgExtra) > 0
		jLog := JSonObject():New()
		jLog[STR0051] := {} //#STR0051 //geral
		jLog[STR0052] := {} //#STR0052 //parametros
		jLog[STR0053] := {} //#STR0053 //mensagem

		// Captura os parâmetros da pergunta usados pelo usuário
		jItem := JSonObject():New()
		if Len( aParamAux ) > 0
			For nX := 1 To Len( aParamAux )
				jItem['MV_PAR'+strZero(nX)] := Alltrim(cValToChar( aParamAux[nX] ))
			Next nX		
		endif

		aAdd( jLog[STR0052] , jItem ) //#STR0052 //parametros

		// Obtém os dados gerais do Sistema
		jItem := JSonObject():New()
		jItem[upper(STR0046)] := cEmpAnt //#STR0046 "Empresa"
		jItem[upper(STR0047)] := cFilAnt //#STR0047 "Filial"
		jItem[upper(STR0048)] := cUserName //#STR0048 "Usuário"
		jItem[upper(STR0016)] := IIf( lSchedule , STR0049,STR0050) //#STR0016 "Processando" #STR0049 "AUTOÁTICO (Schedule)" #STR0050 "MANUAL (Menu)"

		aAdd( jLog[STR0051] , jItem ) //#STR0051 //geral

		aAdd( jLog[STR0053], OA601009F_MontaJsonDeMensagensProcessadas(aMsgExtra) ) //#STR0053 //mensagem

		cJson := FGX_JSONform( jLog:toJson(), .T., nil, .F. )

		freeObj( jLog )
	endif

	// Tenta usar DMS_LOGGER se disponível, senão usa ConOut
	If !empty(oLogger)
		aadd(aData, {"VQL_AGROUP", cRotina})
		aadd(aData, {"VQL_TIPO", cTipo})
		aadd(aData, {"VQL_DADOS", cDados})
		if !empty(cJson)
			aadd(aData, {"VQL_MSGLOG", cJson})
		endif
		if lHoraFim
			aadd(aData, {"VQL_HORAF", VAL(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ))})
			aadd(aData, {"VQL_DATAF", dDataBase})
		endif

		oLogger:LogToTable(aData)
	EndIf
Return .T.

/*/{Protheus.doc} OA601009F_MontaJsonDeMensagensProcessadas
    Monta json interno com mensagens do processamento das requisições de cancelamento  
    @author Emanuel Furtado
    @since 08/01/2025
/*/
Static Function OA601009F_MontaJsonDeMensagensProcessadas(aMsgProc)
	Local jJson := JSonObject():New()
	Local jAuxJson := nil
	Local nX := 0
	Local cStatus := ''
	Local aLinhas := {}
	local cJson := ''
	local cCodLinha := ''
	local cMsgLinha := ''

	Default aMsgProc := {}

	For nX := 1 To Len(aMsgProc)
		cStatus := aMsgProc[nX][1]
		aLinhas := aClone(aMsgProc[nX][2])

		cCodLinha := replace(aLinhas[1],':','')
		cCodLinha := replace(cCodLinha,'!','')
		cCodLinha := alltrim(replace(cCodLinha,'.',''))

		cMsgLinha := replace(aLinhas[2],':','-')
		cMsgLinha := alltrim(replace(cMsgLinha,',','|'))

		replace(cStatus,':','')
		replace(cStatus,':','')
		replace(cStatus,':','')
		replace(cStatus,':','')

		if !empty(cCodLinha)
			cStatus := replace(cStatus,':','')

			If !jJson:HasProperty(cStatus)
				jJson[cStatus] := {}
			EndIf

			jAuxJson := JSonObject():New()

			jAuxJson[STR0054] := cCodLinha //#STR0054 "codigo"
			jAuxJson[STR0055] := cMsgLinha //#STR0055 "status"

			aAdd(jJson[cStatus], jAuxJson)
			freeObj( jAuxJson )
		endif
	Next nX

	cJson := FGX_JSONform( jJson:toJson(), .T., nil, .F. )

	freeObj( jJson )

Return cJson


/*/{Protheus.doc} SchedDef/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		cOFIA601,;
		"",;
		"",;
		"" ;
		}
Return aParam

/*/{Protheus.doc} OA601010K_SetaFilialProcessamento
   Função para trocar a filial durante o processamento,
   visto que o arquivo pode ser referente a distintas filiais
   @type  Static Function
   @author Lucas Oliveira
   @since 17/01/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function OA601010K_SetaFilialProcessamento(cFilialCANCBO)

   Default cFilialCANCBO := ""

   If !Empty(cFilialCANCBO) .and. cFilialCANCBO <> cFilAnt
      cFilAnt := cFilialCANCBO
   EndIf

Return .T.

/*/{Protheus.doc} OA601011K_RestauraFilial
   Funcao para restarurar a variavel cFilAnt
   com base na filial original acessada 
   @type  Static Function
   @author Lucas Oliveira
   @since 17/01/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function OA601011K_RestauraFilial()
   cFilAnt := cBKPFil
Return .T.