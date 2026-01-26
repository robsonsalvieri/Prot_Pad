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
	Local aVetNome := {}

	Local nH       := 0
	Local nI       := 0
	Local nJ       := 0

	Local oDTFConfig := OFJDDTFConfig():New()
	Local oDPM       := DMS_DPM():New()
	Local aFilis     := oDPM:GetFiliais()

	Local cBkpFil    := cFilAnt
	Local cDealler   := ""

	For nH := 1 to len(aFilis)

		cFilAnt  := aFilis[nH][1]
		cDealler := Alltrim(aFilis[nH][2])

		oDTFConfig:GetConfig()

		aAdd(aVetDir,{"DLR2JD_*.JDQUOTE",oDTFConfig:getDirOrigemCotacao_Maquina(),oDTFConfig:getCotacao_Maquina()}) 	//OFINJD21
		aAdd(aVetDir,{"DLR2JD_*.DAT",oDTFConfig:getDirOrigemPMMANAGE(),oDTFConfig:getPMMANAGE()}) 						//OFINJD09
		aAdd(aVetDir,{"DLR2JD_DPMEXT*.DPM",oDTFConfig:getDirOrigemDPMEXT(),oDTFConfig:getDPMEXT()}) 					//OFINJD06
		aAdd(aVetDir,{"DLR2JD_DPMEXT*.DPMBRA",oDTFConfig:getDirOrigemDPMEXT(),oDTFConfig:getDPMEXT()}) 					//OFINJD06
		aAdd(aVetDir,{"*.BRCMDAT",oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),oDTFConfig:get_UP_Incentivo_Maquina()}) //VEIVM200
		aAdd(aVetDir,{"*.BRSLDAT",oDTFConfig:getDirOrigemUP_Incentivo_Maquina(),oDTFConfig:get_UP_Incentivo_Maquina()}) //VEIVM200
		aAdd(aVetDir,{"DLR2JD_*.DAT",oDTFConfig:getDirOrigemParts_Locator(),oDTFConfig:getParts_Locator()}) 			//OFINJD03
		aAdd(aVetDir,{"DLR2JD_*.DAT",oDTFConfig:getDirOrigemParts_Surplus_Returns(),oDTFConfig:getParts_Surplus_Returns()})	//OFINJD05
		aAdd(aVetDir,{"DLR2JD_*.DAT",oDTFConfig:getDirOrigemSMManage(),oDTFConfig:getSMManage()}) 						//OFINJD23
		aAdd(aVetDir,{"*.*",oDTFConfig:getDirOrigemDFA(),oDTFConfig:getDFA()})											//OFIXA052
		aAdd(aVetDir,{"DLR2JD_ELIPS_Hist_*.XML",oDTFConfig:getDirOrigemELIPS(),oDTFConfig:getELIPS()}) 					//OFIA160
		aAdd(aVetDir,{"DLR2JD_ELIPS_Delta_*.XML",oDTFConfig:getDirOrigemELIPS(),oDTFConfig:getELIPS()}) 				//OFIA160

		For nI := 1 to Len(aVetDir)

			If !Empty(aVetDir[nI,2])
				aVetNome := Directory(LoWer(alltrim(aVetDir[nI,2]))+aVetDir[nI,1], "S",,.F.) //Localiza o arquivo na origem
				For nJ := 1 to Len(aVetNome)
					__CopyFile(aVetDir[nI,2]+aVetNome[nJ,1], aVetDir[nI,3] + cDealler + "\" + aVetNome[nJ,1],,,.F.)// Copia da origem para o destino
					FErase(aVetDir[nI,2]+aVetNome[nJ,1],,.F.)// Deleta o arquivo na origem
				Next
			EndIf

		Next

	Next

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