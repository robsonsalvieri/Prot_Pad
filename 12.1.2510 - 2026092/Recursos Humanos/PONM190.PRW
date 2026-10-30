#Include "TOTVS.CH"
#Include "TBICONN.CH"
#Include "PONM190.CH"

Function PONM190()
	// Declaração das variáveis locais
	Local aRetTAE		:= {}
	Local cFile			:= ""
	Local cPathFile		:= ""
	Local cEvtAut		:= ""
	Local cPathTmp		:= "spool\"
	Local cFilFunc		:= ""
	Local cMatFunc		:= ""
	Local cCodeBar		:= ""
	Local nTamRAMAT		:= TamSx3("RA_MAT")[1]
	Local dPerIni		:= sToD(" / / ")
	Local dPerFim		:= sToD(" / / ")
	Local lRet			:= .F.
	Local lHrsValori	:= .F.
	Local oSmartView	:= Nil
	Local oSign			:= Nil
	Local oJPrint		:= JsonObject():New()

	cFilFunc	:= If (Empty(MV_PAR01), "", MV_PAR01)
	cMatFunc	:= If (Empty(MV_PAR02), "", MV_PAR02)
	dPerIni		:= If (Empty(MV_PAR03), sToD(" / / "), MV_PAR03)
	dPerFim		:= If (Empty(MV_PAR04), sToD(" / / "), MV_PAR04)
	lHrsValori	:= If (Empty(MV_PAR05), .F., If (MV_PAR05 == 1, .T., .F.))
	cEvtAut		:= If (Empty(MV_PAR06), "0", Str(MV_PAR06))

	cCodeBar := cEmpAnt + cFilFunc + Padl(AllTrim(cMatFunc), nTamRAMAT, "0") + DtoS(dPerIni) + DtoS(dPerFim) + DtoS(dDataBase) + StrTran(Time(),":","") + "BH"
	
	If Empty(cFilFunc) .Or. Empty(cMatFunc)
		FwLogMsg("WARN", NIL, "PONM190", NIL, NIL, NIL, STR0001) // "Filial ou matrícula não informados para geração do relatório."
		Return lRet
	EndIf

	// Valida a autenticação com o TAE
	oSign := PONXTAE():New("PONR190", .T.)
	
    If (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
		FreeObj(oSign)
		FreeObj(oJPrint)
		FwLogMsg("WARN", NIL, "PONM190", NIL, NIL, NIL, STR0002) // "Não foi possível se autenticar com o TAE (TOTVS Assinatura Eletrônica)."
		Return lRet
	EndIf

	// Inicialização das variáveis
	cFile		:= "PON_" + AllTrim(cFilFunc) + "_" + AllTrim(cMatFunc) + "_" + AnoMes(dPerIni) + AnoMes(dPerFim) + "_BH"
	cPathFile	:= cPathTmp + cFile + ".pdf"
	oSmartView	:= totvs.framework.smartview.callSmartView():new("rh.sv.pon.ponr190", "report")	
		
	oSmartView:setParam("filial1",		cFilFunc)
	oSmartView:setParam("filial2",		cFilFunc)
	oSmartView:setParam("cc1",			"")
	oSmartView:setParam("cc2",			Replicate("Z", GetSX3Cache("RA_CC", "X3_TAMANHO")))
	oSmartView:setParam("turno1",		"")
	oSmartView:setParam("turno2",		Replicate("Z", GetSX3Cache("RA_TNOTRAB", "X3_TAMANHO")))
	oSmartView:setParam("mat1",			cMatFunc)
	oSmartView:setParam("mat2",			cMatFunc)
	oSmartView:setParam("per1",			totvs.framework.treports.date.stringToTimeStamp(dToS(dPerIni)))
	oSmartView:setParam("per2",			totvs.framework.treports.date.stringToTimeStamp(dToS(dPerFim)))
	oSmartView:setParam("sitfunc",		{})
	oSmartView:setParam("catfunc",		{})
	oSmartView:setParam("hrsvalori",	lHrsValori)
	oSmartView:setParam("evtaut",		cEvtAut)
	oSmartView:setParam("integTae",		.F.)

	// Define como sem interface
	oSmartView:setNoInterface(.T.)

	// Força a definição dos parâmetros
	oSmartView:setForceParams(.T.)

	// Define o tipo de impressão, 1 = Arquivo | 2 = E-mail
	oSmartView:setPrintType(1) 

	// Preenche e define as informações de impressão
	oJPrint["name"]			:= cFile
	oJPrint["path"]			:= cPathTmp
	oJPrint["extension"]	:= "pdf"
	oSmartView:setPrintInfo(oJPrint)

	If (oSmartView:executeSmartView())
		// Se o arquivo foi criado, envia para o TAE e deleta o arquivo local
		If (File(cPathFile))
			DbSelectArea("SRA")
    		DbSetOrder(1)

			If DbSeek(cFilFunc + cMatFunc)
				aRetTAE := oSign:sendEsp(cPathFile, cFile + ".pdf", cFilFunc, cMatFunc, dPerIni, dPerFim, cCodeBar, .T., SRA->RA_DEPTO)
				Conout(FWNoAccent(OemToAnsi("Integração Extrato Banco de Horas TAE")))

				If !Empty(aRetTAE[1])
					Conout(FWNoAccent(OemToAnsi(aRetTAE[1,1])))
				EndIf
				
				If !Empty(aRetTAE[2])
					Conout(FWNoAccent(OemToAnsi(aRetTAE[2,1])))
				EndIf
			EndIf

			fErase(cPathFile)
			lRet := .T.
		EndIf
	EndIf
	
	// Libera os objetos da memória
	FwFreeObj(oSign)
	FwFreeObj(oJPrint)
	oSmartView:Destroy()
Return lRet

Static Function SchedDef()
// Declaração das variáveis locais
Local aParam := {}

// Montagem da estrutura do array de retorno
aParam := {;
	"P"			,; // 01 - Tipo R para relatorio P para processo
	"PONM190"	,; // 02 - Pergunte do relatorio, caso nao use passar ParamDef
	""			,; // 03 - Alias
	{}			,; // 04 - Array de ordens
	""			,; // 05 - Titulo
	""			,; // 06 - Nome do relatório (parametro 1 do metodo new da classe TReport)
	.F.			,; // 07 - Indica se permite que o agendamento pode ser cadastrado como sempre ativo
	.F.			,; // 08 - Indica que o agendamento pode definir filiais de execução.
}
Return aParam
