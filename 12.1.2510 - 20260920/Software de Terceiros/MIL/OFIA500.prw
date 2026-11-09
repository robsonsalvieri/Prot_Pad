#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#INCLUDE "OFIA500.CH"

/*/{Protheus.doc} OFIA500
	Tela de configuração do DTF JD

	@author Jose Luis Silveira Filho
	@since  17/08/2021
/*/
Function OFIA500()
	Local bProcess

	Private lSchedule := FWGetRunSchedule()

	DbSelectArea("VO1")

	bProcess := { |oSelf| OA5000051_Processa(oSelf) }

	If lSchedule
		OA5000051_Processa()
	Else
		oTProces := tNewProcess():New(;
		/* 01 */				"OFIA500",;
		/* 02 */				STR0001,; //"Transferência automática de arquivos Local Origem x DTF"
		/* 03 */				bProcess,;
		/* 04 */				STR0002,; //"Rotina de processamento automático para mover arquivos gerados fora das pastas do DTF para as pastas de transmissão de arquivos DTF"
		/* 05 */				"" ,;
		/* 06 */				/*aInfoCustom*/ ,;
		/* 07 */				.t. /* lPanelAux */ ,;
		/* 08 */				 /* nSizePanelAux */ ,;
		/* 09 */				/* cDescriAux */ ,;
		/* 10 */				.t. /* lViewExecute */ ,;
		/* 11 */				.t. /* lOneMeter */ )
	EndIf

Return

/*/
{Protheus.doc} OA5000051_Processa

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA5000051_Processa()
	Local aVetDir  := {}
	Local nH       := 1
	Local nX       := 1

	Local oDTFConfig := OFJDDTFConfig():New()
	Local oJdConfig  := OFJDConfig():New()
	Local oDPM       := OFJDRpmConfig():New()
	Local aFilis     := oDPM:GetFiliais()
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	Local oLogger    := DMS_Logger():New()
	Local cBkpFil    := cFilAnt
	Local cDealler   := ""

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()

		if len(aContas) == 0
			if isBlind()
				conout(STR0003) //"Nenhuma conta configurada, acesse OFIA512 para configurar contas para o RPM")
			else
				MsgStop(STR0003, STR0004) //"Atenção")
			endif
		endif

		for nX := 1 to len(aContas)
			conout("OFIA500 -> '" + aContas[nX] + "'")
			oDTFConfig := OFJDDTFConfig():New()
			oJdConfig  := OFJDConfig():New(/*nao usado*/,aContas[nX])
			oDTFConfig:GetConfig(aContas[nX])

			aAdd(aVetDir, {"DLR2JD_*.JDQUOTE",         oDTFConfig:getDirOrigemCotacao_Maquina(),       oDTFConfig:getCotacao_Maquina()})        // OFINJD21
			aAdd(aVetDir, {"*.BRCMDAT",                oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),  oDTFConfig:get_UP_Incentivo_Maquina()})  // VEIVM200
			aAdd(aVetDir, {"*.BRSLDAT",                oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),  oDTFConfig:get_UP_Incentivo_Maquina()})  // VEIVM200
			aAdd(aVetDir, {"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemParts_Locator(),         oDTFConfig:getParts_Locator()})          // OFINJD03
			aAdd(aVetDir, {"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemParts_Surplus_Returns(), oDTFConfig:getParts_Surplus_Returns()})  // OFINJD05
			aAdd(aVetDir, {"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemSMManage(),              oDTFConfig:getSMManage()})               // OFINJD23
			aAdd(aVetDir, {"*.*",                      oDTFConfig:getDirOrigemDFA(),                   oDTFConfig:getDFA()})                    // OFIXA052
			aAdd(aVetDir, {"DLR2JD_ELIPS_Hist_*.XML",  oDTFConfig:getDirOrigemELIPS(),                 oDTFConfig:getELIPS()})                  // OFIA160
			aAdd(aVetDir, {"DLR2JD_ELIPS_Delta_*.XML", oDTFConfig:getDirOrigemELIPS(),                 oDTFConfig:getELIPS()})                  // OFIA160
			aAdd(aVetDir, {"DLR2JD_*.DAT",             oJdConfig:CaminhoDosArquivos(),                 oDTFConfig:getPMMANAGE()})               // tratamento do combo a origem destes arquivos é sempre a mesma
			aAdd(aVetDir, {"DLR2JD_DPMEXT*.DPM",       oJdConfig:CaminhoDosArquivos(),                 oDTFConfig:getDPMEXT()})                 // tratamento do combo a origem destes arquivos é sempre a mesma
			aAdd(aVetDir, {"DLR2JD_DPMEXT*.DPMBRA",    oJdConfig:CaminhoDosArquivos(),                 oDTFConfig:getDPMEXT()})                 // tratamento do combo a origem destes arquivos é sempre a mesma

			OA5000064_FazMovimentacao(aVetDir, oJdConfig:GetAccount())
		next

	else

		For nH := 1 to len(aFilis)

			cFilAnt  := aFilis[nH][1]
			cDealler := Alltrim(aFilis[nH][2])

			oDTFConfig:GetConfig()

			aAdd(aVetDir,{"DLR2JD_*.JDQUOTE",         oDTFConfig:getDirOrigemCotacao_Maquina(),                 oDTFConfig:getCotacao_Maquina()})        //OFINJD21
			aAdd(aVetDir,{"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemPMMANAGE(),                        oDTFConfig:getPMMANAGE()})               //OFINJD09
			aAdd(aVetDir,{"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemPMMANAGE()+cDealler+"\pmm\",       oDTFConfig:getPMMANAGE()})               //OFINJD09
			aAdd(aVetDir,{"DLR2JD_DPMEXT*.DPM",       oDTFConfig:getDirOrigemDPMEXT(),                          oDTFConfig:getDPMEXT()})                 //OFINJD06
			aAdd(aVetDir,{"DLR2JD_DPMEXT*.DPMBRA",    oDTFConfig:getDirOrigemDPMEXT(),                          oDTFConfig:getDPMEXT()})                 //OFINJD06
			aAdd(aVetDir,{"DLR2JD_DPMEXT*.DPMBRA",    oDTFConfig:getDirOrigemDPMEXT()+cDealler+"\parts_data\",  oDTFConfig:getDPMEXT()})                 //OFINJD06
			aAdd(aVetDir,{"*.BRCMDAT",                oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),            oDTFConfig:get_UP_Incentivo_Maquina()})  //VEIVM200
			aAdd(aVetDir,{"*.BRSLDAT",                oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),            oDTFConfig:get_UP_Incentivo_Maquina()})  //VEIVM200
			aAdd(aVetDir,{"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemParts_Locator(),                   oDTFConfig:getParts_Locator()})          //OFINJD03
			aAdd(aVetDir,{"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemParts_Surplus_Returns(),           oDTFConfig:getParts_Surplus_Returns()})  //OFINJD05
			aAdd(aVetDir,{"DLR2JD_*.DAT",             oDTFConfig:getDirOrigemSMManage(),                        oDTFConfig:getSMManage()})               //OFINJD23
			aAdd(aVetDir,{"*.*",                      oDTFConfig:getDirOrigemDFA(),                             oDTFConfig:getDFA()})                    //OFIXA052
			aAdd(aVetDir,{"DLR2JD_ELIPS_Hist_*.XML",  oDTFConfig:getDirOrigemELIPS(),                           oDTFConfig:getELIPS()})                  //OFIA160
			aAdd(aVetDir,{"DLR2JD_ELIPS_Delta_*.XML", oDTFConfig:getDirOrigemELIPS(),                           oDTFConfig:getELIPS()})                  //OFIA160

			OA5000064_FazMovimentacao(aVetDir, cDealler)
		Next

	endif
	
	cFilAnt  := cBkpFil
Return

/*/
{Protheus.doc} OA5000052_LocalOrigem

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OA5000052_GravaDiretorioOrigem(cDirOrigem,cFonte)

	Local oDTFConfig      := OFJDDTFConfig():New()
	Local oCfgAtu

	oCfgAtu := oDTFConfig:GetConfig()
	Do Case
		Case cFonte == "OFINJD21" .and. Empty(oDTFConfig:getDirOrigemCotacao_Maquina())
			oCfgAtu[ "OCotacao_Maquina"]      := AllTrim(cDirOrigem)

		Case cFonte == "OFINJD06" .and. Empty(oDTFConfig:getDirOrigemDPMEXT())
			oCfgAtu[ "ODPMEXT"]              := AllTrim(cDirOrigem)

		Case cFonte == "OFINJD09" .and. Empty(oDTFConfig:getDirOrigemPMMANAGE())
			oCfgAtu[ "OPMMANAGE"]              := AllTrim(cDirOrigem)

		Case cFonte == "VEIVM200" .and. Empty(oDTFConfig:getDirOrigemUP_Incentivo_Maquina())
			oCfgAtu[ "OUP_Incentivo_Maquina"] := AllTrim(cDirOrigem)

		Case cFonte == "OFINJD03" .and. Empty(oDTFConfig:getDirOrigemParts_Locator())
			oCfgAtu[ "OParts_Locator"]        := AllTrim(cDirOrigem)

		Case cFonte == "OFINJD05" .and. Empty(oDTFConfig:getDirOrigemParts_Surplus_Returns())
			oCfgAtu[ "OParts_Surplus_Returns"] := AllTrim(cDirOrigem)

		Case cFonte == "OFINJD23" .and. Empty(oDTFConfig:getDirOrigemSMManage())
			oCfgAtu[ "OSMManage"]             := AllTrim(cDirOrigem)

		Case cFonte == "OFIA160" .and. Empty(oDTFConfig:getDirOrigemELIPS())
			oCfgAtu[ "OELIPS"]                := AllTrim(cDirOrigem)
	EndCase

	oDTFConfig:SaveConfig(oCfgAtu)

Return

/*/{Protheus.doc} OA5000064_FazMovimentacao

	@author Vinicius Gati
	@since 25/03/2019
	@version 1.0
	@type function
/*/
Function OA5000064_FazMovimentacao(aVetDir, cDealler)
	Local aArqsFound
	Local nJ := 1
	Local nI := 1
	Local oLogger := DMS_Logger():New()

	For nI := 1 to Len(aVetDir)
		cWildC    := aVetDir[nI, 1]
		cOriPath  := aVetDir[nI, 2]
		cDestPath := aVetDir[nI, 3]


		if Empty(cOriPath) .or. Empty(cDestPath)
			loop
		endif

		aArqsFound := Directory(LoWer(alltrim(cOriPath)) + cWildC, "S",,.F.) //Localiza o arquivo na origem
		conout("OFIA500 - " + STR0005 + LoWer(alltrim(cOriPath)) + cWildC) //Buscando arquivos em: "
		conout("OFIA500 - " + cValtoChar(len(aArqsFound)) + STR0006) // " arquivos encontrados. "

		For nJ := 1 to Len(aArqsFound)
			cNomArq := aArqsFound[nJ,1]

			if "\" + cDealler $ cDestPath // se o /201101 já esá no destino (isso é pra jogar na pasta com codigo do dealer)
				Fgx_MDirR(cDestPath) // criando path
				if !ExistDir(cDestPath)
					oLogger:SimpleLogToTable("OFIA500", "Não foi possivel criar o diretório: "+cDestPath + cDealler)
				EndIf
				__CopyFile(cOriPath + cNomArq, cDestPath + "\" + cNomArq,,,.F.)
				if File(cDestPath + "\" + cNomArq, 0, .F.)
					FErase(cOriPath + cNomArq,,.F.)// Deleta o arquivo na origem
				else
					oLogger:SimpleLogToTable("OFIA500", "Nao foi possivel copiar o arquivo no diretorio de destino. Movimentação cancelada." + CHR(13) + CHR(10) + cDestPath + "\" + cNomArq + CHR(13) + CHR(10) + cOriPath)
				endif
			else
				Fgx_MDirR(cDestPath + "\" + cDealler) // criando path
				if !ExistDir(cDestPath + "\" + cDealler)
					oLogger:SimpleLogToTable("OFIA500", "Não foi possivel criar o diretório: "+cDestPath + cDealler)
				EndIf
				__CopyFile(cOriPath + cNomArq, cDestPath + "\" + cDealler + "\" + cNomArq,,,.F.)
				if File(cDestPath + "\" + cDealler + "\" + cNomArq, 0, .F.) // se arquivo existe no destino
					FErase(cOriPath + cNomArq,,.F.)// Deleta o arquivo na origem
				else
					oLogger:SimpleLogToTable("OFIA500", "Nao foi possivel copiar o arquivo no diretorio de destino. Movimentação cancelada." + CHR(13) + CHR(10) + cDestPath + "\" + cDealler + "\" + cNomArq + CHR(13) + CHR(10) + cOriPath)
				endif
			endif
			
		Next
	Next
Return

/*/{Protheus.doc} SchedDef
	Funcao padrao scheduler

	@author Joao Victor Silva
	@since 01/12/2025
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFIA500",;
	"",;
	"",;
	"" ;
	}
Return aParam
