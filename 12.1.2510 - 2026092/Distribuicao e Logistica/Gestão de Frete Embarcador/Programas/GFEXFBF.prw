#INCLUDE "GFEXFUNB.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"  
 
// Constantes usadas na função AddToLog()
#DEFINE _LOG_BEGIN 1
#DEFINE _LOG_END   2

//---------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} GFEXFBF
//TODO Função principal para fonte ser listado nos fontes do TDS
@author André Luis W
@since 02/04/18
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFBF()
	/* **********************************
		AS VARIAVEIS UTILIZADAS NESTE FONTE DEVE SER 
		DECLARADAS COMO PRIVATE NO FONTE CHAMADOR
	   ********************************** */
return


CLASS GFEXFBFLog FROM LongNameClass
    
	DATA cNow
	DATA cAgrFrt
	DATA cArqLog
	DATA cDRTLOG
	DATA cTexto
	DATA nPosicao
	DATA lTime
	DATA cTxtLog
	DATA lSaveLog
	DATA sGFEEDIL
	DATA cInfoLine
	
	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()
	
	METHOD NovoLog()
	METHOD NovoLogInP()
	METHOD AddToLog()
	METHOD SaveLog()
	
	METHOD setNow(cNow)
	METHOD setAgrFrt(cAgrFrt)
	METHOD setArqLog(cArqLog)
	METHOD setDRTLOG(cDRTLOG)
	METHOD setTexto(cTexto)
	METHOD setPosicao(nPosicao)
	METHOD setTime(lTime)
	METHOD setSaveLog(lSaveLog)
	METHOD setIniTxtLog(cTxtLog)
	METHOD setFimTxtLog(cTxtLog)
	METHOD setGFEEDIL(sGFEEDIL)
	METHOD setInfoLine(cInfoLine)

	METHOD getNow()
	METHOD getAgrFrt()
	METHOD getArqLog()
	METHOD getDRTLOG()
	METHOD getTexto()
	METHOD getPosicao()
	METHOD getTime()
	METHOD getSaveLog()
	METHOD getTxtLog()
	METHOD getGFEEDIL()
	METHOD getInfoLine()
	
ENDCLASS

METHOD New() Class GFEXFBFLog
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEXFBFLog
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEXFBFLog
	Self:setNow(GFENOW())
	Self:setAgrFrt("")
	Self:setArqLog("")
	Self:setDRTLOG(SuperGetMv('MV_DRTLOG',.F.,""))
	Self:cTxtLog	:= ""
	Self:setGFEEDIL(SuperGetMv("MV_GFEEDIL",.F.,"1"))
Return

METHOD NovoLog() Class GFEXFBFLog
	Local cPath		:= ""
	Local cDRTLOG	:= Self:getDRTLOG()

	If !Self:getSaveLog()
		Return "---"
	EndIf

	If !Empty(cDRTLOG)

		If SubStr(cDRTLOG, Len(cDRTLOG), 1) != '/' .AND. SubStr(cDRTLOG, Len(cDRTLOG), 1) != '\'
			cDRTLOG += "\"
		EndIf

		cDRTLOG += STR0328		// "CalculoFrete"
	Else
		cDRTLOG := STR0328		// "CalculoFrete"
	EndIf

	If !Empty(Self:getAgrFrt()) .AND. IsInCallStack("GFEA050") // Cálculo do romaneio, adiciona o número do romaneio no nome do arquivo.
		cPath := cDRTLOG + "_" + Self:getAgrFrt() + "_"
	Else
		cPath := cDRTLOG + "_"
	EndIf

	cPath += AllTrim(FWGrpCompany()) + AllTrim(FWCodFil()) + "_" + Self:getNow() + ".LOG"
	Self:setArqLog(cPath)
Return

/*/{Protheus.doc} NovoLogInP
Log de integrações com o ERP Protheus
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cProg, characters, descricao
@type function
/*/
METHOD NovoLogInP(cProg) Class GFEXFBFLog
	Local cPath		:= ""
	Local cDRTLOG	:= Self:getDRTLOG()

	If !Self:getSaveLog()
		Return "---"
	EndIf

	If !Empty(cDRTLOG)

		If SubStr(cDRTLOG, Len(cDRTLOG), 1) != '/' .AND. SubStr(cDRTLOG, Len(cDRTLOG), 1) != '\'
			cDRTLOG += "\"
		EndIf
	Else
		cDRTLOG := ""
	EndIf
	
	If cProg = "MATA116"
		cDRTLOG += "integr_mata116"
	ElseIf cProg = "MATA140"
		cDRTLOG += "integr_mata140"
	ElseIf cProg = "MATA103"
		cDRTLOG += "integr_mata103"
	ElseIf cProg = "FINA050"
		cDRTLOG += "integr_fina050"
	EndIf		
		
	If !Empty(Self:getAgrFrt())
		cPath := cDRTLOG + "_" + trim(Self:getAgrFrt()) + "_"
	Else
		cPath := cDRTLOG + "_"
	EndIf

	cPath += AllTrim(FWGrpCompany()) + AllTrim(FWCodFil()) + "_" + Self:getNow() + ".LOG"
	Self:setArqLog(cPath)
Return

METHOD AddToLog() Class GFEXFBFLog
	Local nLimit	:= 1000000
	Local lTime		:= Self:getTime()
	Local nPosicao	:= Self:getPosicao()
	Local cTexto 	:= Self:getTexto() 

	If !Self:getSaveLog()
		Return
	EndIf
	
	// Para não criar uma nova opção no LOG de cálculo de frete
	// foi utilizado o parametro do LOG de EDI
	// Quando for "3=Modo Debug","4=Modo Console, será gerado a Data, hora e segundos de processamento
	// Utilizar somente em caso de análise de performance do cálculo de frete.
	if Self:getGFEEDIL() $ "3;4" 
		cTexto := StrTran(cTexto,CRLF,CRLF + GFENOW(,, " ",,,.F.) + "|")
	EndIf
	
		
	If nPosicao == _LOG_BEGIN // inicio do log (1)
		Self:setIniTxtLog(cTexto)
	Else	// final do log (2)
		Self:setFimTxtLog(cTexto)
	EndIf

	If len(Self:getTxtLog()) > nLimit
		Self:setFimTxtLog(CRLF + STR0545 + cValToChar(nLimit) + STR0546 + CRLF) //"**** Limite de "###" bytes atingido. Gravando em arquivo. ****"
		Self:SaveLog()
	EndIf
Return

METHOD SaveLog() Class GFEXFBFLog
	Local nHandle	:= 0
	Local cLock		:= ""
	Local cInfoLine	:= Self:getInfoLine()

	If Self:getSaveLog()

		cInfoLine := If(!Empty(cInfoLine),cInfoLine+CRLF,"") //Retira o último ponto e vírgula e adiciona uma quebra de linha
		
		cLock := "GFEXFUNB" + Self:getArqLog()
		
		If LockByName(cLock, .F., .F.)
			If !File(Self:getArqLog())  // Arquivo não existe
				// Cria o arquivo de log
				nHandle := FCreate(Self:getArqLog(),FC_NORMAL)
				If nHandle <= 0
					GFEConout("ERROR","[GFEXFUNB] Não foi possivel gerar o arquivo de LOG. Diretório informado no Parâmetros do módulo está inválido, este diretório deve ser na instalação do Protheus.")
					Return Nil
				EndIf
				FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
			Else	// Arquivo existe
				nHandle := FOpen(Self:getArqLog(),FO_READWRITE)
				If nHandle = 0
					GFEConout("ERROR","[GFEXFUNB] Não foi possivel gerar o arquivo de LOG. Diretório informado no Parâmetros do módulo está inválido, este diretório deve ser na instalação do Protheus.")
					Return Nil
				EndIf
				FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
			EndIf
	
			FWrite(nHandle,cInfoLine + Self:getTxtLog(),len(cInfoLine + Self:getTxtLog())) // Grava o conteudo da variavel no arquivo de log
	
			cInfoLine := "" //Apaga seu conteúdo pois é necessário imprimí-la apenas uma vez
			
			Self:setInfoLine("")
	
			FClose(nHandle) // Fecha o arquivo de log
			
			UnLockByName(cLock, .F., .F.)
			ClearGlbValue('GFEXFUNB*', 10)			
		EndIf
	EndIf

	Self:cTxtLog := ""

Return


//-----------------------------------
//Setters
//-----------------------------------

METHOD setNow(cNow) CLASS GFEXFBFLog
   Self:cNow := cNow
Return

METHOD setAgrFrt(cAgrFrt) CLASS GFEXFBFLog
   Self:cAgrFrt := cAgrFrt
Return

METHOD setArqLog(cArqLog) CLASS GFEXFBFLog
   Self:cArqLog := cArqLog
Return

METHOD setDRTLOG(cDRTLOG) CLASS GFEXFBFLog
   Self:cDRTLOG := cDRTLOG
Return

METHOD setTexto(cTexto) CLASS GFEXFBFLog
   Self:cTexto := cTexto
   Self:AddToLog()
Return

METHOD setPosicao(nPosicao) CLASS GFEXFBFLog
   Self:nPosicao := nPosicao
Return

METHOD setTime(lTime) CLASS GFEXFBFLog
   Self:lTime := lTime
Return

METHOD setSaveLog(lSaveLog) CLASS GFEXFBFLog
   Self:lSaveLog := lSaveLog
Return

METHOD setIniTxtLog(cTxtLog) CLASS GFEXFBFLog
   Self:cTxtLog := cTxtLog + Self:cTxtLog
Return

METHOD setFimTxtLog(cTxtLog) CLASS GFEXFBFLog
   Self:cTxtLog := Self:cTxtLog + cTxtLog
Return

METHOD setGFEEDIL(sGFEEDIL) CLASS GFEXFBFLog
   Self:sGFEEDIL := sGFEEDIL
Return

METHOD setInfoLine(cInfoLine) CLASS GFEXFBFLog
   Self:cInfoLine := cInfoLine
Return
//-----------------------------------
//Getters
//-----------------------------------

METHOD getNow() CLASS GFEXFBFLog
Return Self:cNow

METHOD getAgrFrt() CLASS GFEXFBFLog
Return Self:cAgrFrt

METHOD getArqLog() CLASS GFEXFBFLog
Return Self:cArqLog

METHOD getDRTLOG() CLASS GFEXFBFLog
Return Self:cDRTLOG

METHOD getTexto() CLASS GFEXFBFLog
Return Self:cTexto

METHOD getPosicao() CLASS GFEXFBFLog
Return Self:nPosicao

METHOD getTime() CLASS GFEXFBFLog
Return Self:lTime

METHOD getSaveLog() CLASS GFEXFBFLog
Return Self:lSaveLog

METHOD getTxtLog() CLASS GFEXFBFLog
Return Self:cTxtLog

METHOD getGFEEDIL() CLASS GFEXFBFLog
Return Self:sGFEEDIL

METHOD getInfoLine() CLASS GFEXFBFLog
Return Self:cInfoLine
