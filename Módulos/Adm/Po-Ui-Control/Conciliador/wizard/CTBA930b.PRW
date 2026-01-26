#Include "CTBA930B.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"
#Include "FileIO.ch"

/*{Protheus.doc} CriaUUID
Cria os campos _MSUID para uso no conciliador contábil
Os campos devem ser criados a partir da configuração 
feita na tabela QLB

@author: TOTVS
@since 06/08/2021   
@version 1.0
*/
Function CTBA930b(cPassWiz) 
Local aSM0		:= {}
Local aHeader	:= {}
Local aCols 	:= {}
Local lWizFinal := .F.
local cMens		:=	STR0001 + CRLF +; //"Essa rotina exportará um arquivo SDF para atualização do dicionários de dados."
					STR0002 + CRLF +; //"Serão criados campos de ID para uso na rotina de conciliação."
					STR0003 //"Os campos serão criados com base nas tabelas cadastradas na tabela: QLB - Chaves."
Local lVldDic   := .F.
Local cEmpAux := ""
Local cFilAux := ""
local lRet    := .T.

Private oWizard
Private lContinua  := .T.
Private lCriouSDF  := .F.
Private cListTab   := ""

DEFAULT cPassWiz := ""

RptStatus({|| lVldDic := C930IniDad(aHeader,aCols,aSM0) },STR0005, STR0004) //"Preparando os dados para o wizard..." //"Aguarde..."

If lVldDic

	cEmpAux := cEmpAnt
	cFilAux := cFilAnt
	
	//Painel 1 - Tela inicial do Wizard
	oWizard := APWizard():New(STR0006/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0007/*<chMsg>*/, ""/*<cTitle>*/, ;  //"Exportação do arquivo SDF para criação dos campos _MSUID"
	cMens, ;
	{||.T.} /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	//Painel 2 - Definição das Novas Entidades
	oWizard:NewPanel(STR0006/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0007/*<chMsg>*/,; //"Exportação do arquivo SDF para criação dos campos _MSUID"
	{||.T.}/*<bBack>*/,;
	{|| VldTabQLB(aCols)} /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| C930GDQLB(aHeader,aCols,aSM0)}/*<bExecute>*/) //Montagem da tela


	//Painel 3 - Acompanhamento do Processo
	oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Processamento..."
	STR0007/*<chMsg>*/,; //"Exportação do arquivo SDF para criação dos campos _MSUID"
	{||.F.} /*<bBack>*/,;
	{||.F.}/*<bNext>*/ ,;
	{||(lWizFinal := .T., .T.)}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| WizGerSDF(aCols)}/*<bExecute>*/)

	oWizard:Activate( .T./*<.lCenter.>*/,;
	{||.T.}/*<bValid>*/,;
	{||.T.}/*<bInit>*/,;
	{||.T.}/*<bWhen>*/)

	If lCriouSDF .And. lWizFinal		
		If MsgYesNo(STR0009+CRLF+STR0010,STR0011 ) //"Será necessário acesso exclusivo ao sistema." //"Deseja executar o UPDDISTR agora?" //"Atenção"
			RpcClearEnv()
			//UPDDISTR()		
			JobUpdDistr(cEmpAux,{cPassWiz})			
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*{Protheus.doc} VldTabQLB
Valida se pode avançar para a próxima tela

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function VldTabQLB(aCols)
Local aArea := GetArea()
Local lRet	:= .T.
Local cPath	 := GetSystemLoadDir()
Local cLocFiles := GetSrvProfString("StartSysInDB","undefined")

If GetRPORelease() < "12.1.2210"
	If ExistDir(cPath+"cfglog") .And. cLocFiles == "undefined"
		C930MsgBox(STR0029) //"Para prosseguir renomeie a pasta cfglog, localizado dentro da pasta protheus_data."
		lRet := .F.
	EndIf
EndIf

If lRet
	If Len(aCols) > 0
		If FILE(cPath+'sdfbra.txt') 
			lRet := MsgYesNo(STR0013+CRLF+STR0012 ,STR0011) //"Deseja sobrescrever?" //"Atenção" //"Já existe um arquivo SDF na pasta systemload."
			If lRet
				FERASE(cPath+'sdfbra.txt')
				FERASE(cPath+'manifest_update.txt')
			EndIf
		EndIf
	Else
		C930MsgBox(STR0014)  //"Não foram encontrados registros na tabela QLB."
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*{Protheus.doc} WizCriaSDF
Cria o SDF para inclusão dos capos MSUID

@author: TOTVS
@since 06/08/2021  
@version 1.0
*/
Static Function WizGerSDF(aCols)
Local oX31
Local oPanel := oWizard:oMPanel[oWizard:nPanel]
Local oFont  := TFont():New(,,-14,,, )
Local nI     := 0
Local cCposOk:= ""
Local lContinua := .F. // Se todos os campos já foram incluídos não prossegue
Local lMsgErro  := .F.
Local lRetDif:= .F.
// Alterado função conforme sugestão do Sandro (Frame)
Local cBarra := If(issrvunix(), "/", "\")
Local cPath	 := GetSystemLoadDir()
Local cSNome := ""
Local cFileTxt := ""
Local nTamanho := If(AllTrim(Upper(TCGetDB())) == "ORACLE", 32, 36)
local tmp 	   := getTempPath()
local targetDir:= ""

If FindClass("MPX31Field")

	oX31 := MPX31Field():New(STR0015) //"Inclusao de Campos MSUID"

	If MethIsMemberOf( oX31, 'CreateUUID')

		For nI := 1 to Len(aCols)
			
			If aCols[nI,6]=="Ok"
				Loop
			EndIf

			If !aCols[nI,3] $ cCposOk				
				cCposOk += aCols[nI,3]+"|"
				cSNome := AllTrim(aCols[nI,3])	

				If !ExistDir(cPath+"cfglog")
					MakeDir(cPath+"cfglog")
				EndIf			

				oX31:SetAlias(aCols[nI,2])
				oX31:CreateUUID(SubStr(cSNome, Len(cSNome)))
				oX31:SetSize(nTamanho)
				
				If oX31:VldData()
					oX31:CommitData()
					lContinua := .T.
				Else	
					oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Falha na criação do dicionário diferencial"
					C930MsgBox(STR0017+aCols[nI,3]) //"Erro na criação do campo: "
					lContinua := .F. //Se der erro em algum item não prossigo
					lMsgErro := .T.
					Exit
				EndIf
			EndIf
		Next
		
		If lContinua	
			cCodPrj:=oX31:oPrjResult:cCodProj
			// Cria arquivo texto para verficar se usuário tem permissão na pasta
			cFileTxt := cPath+"conciliador.txt"
			nHandle := MsFCreate(cFileTxt)

			If nHandle < 0
				// Verifica se tem permissão na pasta
				If cValToChar( FError() ) == "13"
					C930MsgBox(STR0024) // "Sem permissão de acesso ao diretório, verifique!"
					oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Falha na criação do dicionário diferencial"
					lContinua := .F. //Se der erro em algum item não prossigo
				EndIf
			Else
				lRetDif := FWGnFlByTp(cCodPrj,cPath) // Crio o arquivo diferencial
				If !lRetDif		
					FWAtuStatus("1", cCodPrj)
					If MsgYesNo(STR0030+CRLF+STR0031,STR0011 ) //"Falha na criação do dicionário diferencial" //"Deseja selecionar uma pasta deferente para salvar o arquivo?" //"Atenção"
						targetDir := tFileDialog( "All Text files (*.txt) ",STR0032,, tmp, .F., GETF_RETDIRECTORY) //"Seleção de Arquivos"
						lRetDif := FWGnFlByTp(cCodPrj,targetDir+cBarra) // Crio o arquivo diferencial
						lContinua := .F. //Se der erro em algum item não prossigo
					EndIf
					If !lRetDif
						oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,220,25) //"Falha na criação do dicionário diferencial"
						lContinua := .F. //Se der erro em algum item não prossigo
					Else
						oSay1:= TSay():New(020,010,{||STR0033},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,220,25) //"Arquivo gerado com sucesso, copie o arquivo para dentro da pasta systemload e rode o UPDDISTR para criação dos campos"
						C930MsgBox(STR0033) //"Arquivo gerado com sucesso, copie o arquivo para dentro da pasta systemload e rode o UPDDISTR para criação dos campos"
					EndIf
				EndIf
			End

			FClose(nHandle)
			// Apago o arquivo
			If File(cFileTxt)				
				FERASE(cFileTxt)
			EndIf

			If lContinua .And. File(cPath+"sdfbra.txt")
				oSay1:= TSay():New(020,010,{||STR0018},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Arquivo SDF exportado com sucesso para a pasta systemload."
				lCriouSDF := .T.
			EndIf
		ElseIf !lMsgErro
			C930MsgBox(STR0019) //"Não existem campos para exportação."
		EndIf

		FreeObj(oX31)
		oX31 := Nil
	Else
		C930MsgBox(STR0020) //"Classe necessária não encontrada. Atualize a versão da LIB."
	EndIf
EndIf

If lContinua
	C930MsgBox(STR0021) //"Processo de atualização finalizado"
EndIf
Return

/*/{Protheus.doc} JobUpdDistr
    Prepara o ambiente para execução do UPDDISTR via JOB e faz a chamada
    @type  Static Function
    @author Gianluca Moreira
    @since 17/02/2023
/*/
Static Function JobUpdDistr(cGrupo, aSenha)
    Local lRet := .T.

    lRet := ClrResult() //Limpa results.json
    If lRet
        lRet := BkpConfig() //Faz backup das configs se existirem
    EndIf
    If lRet
        lRet := JsonUpd(cGrupo, aSenha) //Cria novo arquivo de configs
    EndIf
    If lRet
        LoadingScreen({|| StartJob("UPDDISTR", GetEnvserver(), .T.) }, 'UPDDISTR', STR0034) //"Em Execução... Aguarde..."
        lRet := ChkResult() //Verifica se executou
    EndIf
    If lRet
        lRet := RestConfig() //Restaura backup das configs e apaga o arquivo gerado pelo wizard
    EndIf
    
Return

/*/{Protheus.doc} ClrResult
	Limpa o arquivo JSON de resultados
	@type  Static Function
	@author Gianluca Moreira
	@since 17/02/2023
/*/
Static Function ClrResult()
	Local cFile := 'result.json'
	Local cPath := "\systemload\"
	Local oFile := FWFileWriter():New(cPath+cFile, .T.)
    Local cMsg  := ""
    Local lRet  := .T.

	If oFile:Exists()
		oFile:Erase()
        lRet := !oFile:Exists()
        If !lRet
            cMsg := STR0035 //"Ocorreu um erro ao apagar o arquivo result.json - "
            cMsg += CRLF
            cMsg += cValToChar(oFile:Error():Message)
            FWAlertError(cMsg)
        EndIf
		oFile:Close()
	EndIf

Return lRet

/*/{Protheus.doc} BkpConfig
    Faz backup do upddistr_param.json
    https://tdn.totvs.com/display/LMPING/UPDDISTR+executed+via+Job
    @type  Static Function
    @author Gianluca Moreira
    @since 17/02/2023
/*/
Static Function BkpConfig()
    Local cFile   := 'upddistr_param.json'
	Local cPath   := "\systemload\"
    Local oFile   := FWFileWriter():New(cPath+cFile, .T.)
    Local lRet    := .T.
    Local nResult := 0

    If oFile:Exists()
        oFile:Close()
        nResult := FRename(cPath+cFile, cPath+cFile+'.bkp',,.F.)
        lRet := nResult == 0        
    EndIf

Return lRet

/*/{Protheus.doc} JsonUpd
	Cria o json de configuração do UPDDISTR conforme documentação
	https://tdn.totvs.com/display/LMPING/UPDDISTR+executed+via+Job
	@type  Static Function
	@author Gianluca Moreira
	@since 17/02/2023
/*/
Static Function JsonUpd(cGrupo, aSenha)
	Local cFile := 'upddistr_param.json'
	Local cPath := "\systemload\"
	Local oFile := FWFileWriter():New(cPath+cFile, .T.)
	Local jJson := JsonObject():New()    

	jJson['password']       := RTrim(aSenha[1])
	jJson['simulacao']      := .F.
	jJson['localizacao']    := cPaisLoc
	jJson['sixexclusive']   := .T.
	jJson['empresas']       := {cGrupo}
	jJson['logprocess']     := .F.
	jJson['logatualizacao'] := .T.
	jJson['logwarning']     := .F.
	jJson['loginclusao']    := .F.
	jJson['logcritical']    := .T.
	jJson['updstop']        := .F.
	jJson['oktoall']        := .T.
	jJson['deletebkp']      := .F.
	jJson['keeplog']        := .F.

	If !oFile:Exists()
		oFile:Create()
		oFile:Close()
	EndIf
	If oFile:Open(FO_WRITE)
		oFile:Clear()
		oFile:Write(jJson:ToJson())
		oFile:Close()	
	EndIf
	
Return .T.

/*/{Protheus.doc} ChkResult
	Verifica o resultado da execução do UPDDISTR
	@type  Static Function
	@author Gianluca Moreira
	@since 17/02/2023
/*/
Static Function ChkResult()
	Local cFile := 'result.json'
	Local cPath := "\systemload\"
	Local oFile := FWFileReader():New(cPath+cFile, .T.)
	Local jJson := JsonObject():New()
	Local cRes  := ''

    If oFile:Exists()
		If oFile:Open()
			cRes := oFile:GetLine()
			If jJson:FromJson(cRes) == Nil
				If jJson['result'] == 'success'
					FWAlertInfo(STR0039) //"O UPDDISTR Executou corretamente."           
				EndIf        
			EndIf	
		EndIf
		oFile:Close()
	EndIf

Return .T.

/*/{Protheus.doc} RestConfig
    Restaura as configurações originais do JOB UPDDISTR
    @type  Static Function
    @author Gianluca Moreira
    @since 17/02/2023
/*/
Static Function RestConfig()
    Local cFile   := 'upddistr_param.json'
	Local cPath   := "\systemload\"
    Local oFile   := FWFileWriter():New(cPath+cFile, .T.)
    Local lRet    := .T.
    
    If oFile:Exists()
        oFile:Erase()
        oFile:Close()
        FWFreeObj(oFile)
    EndIf

    oFile := FWFileWriter():New(cPath+cFile+'.bkp', .T.)

Return lRet

/*/{Protheus.doc} LoadingScreen
    Monta tela de progresso para os processamentos do wizard
    @type  Static Function
    @author Gianluca Moreira
    @since 06/03/2023
/*/
Static __oText := Nil
Static Function LoadingScreen(bAction, cTitle, cMsg)
    Local oDlg

    DEFINE MSDIALOG oDlg FROM 12,35 TO 19.5, 75 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS

	@ 10, 20  SAY __oText VAR OemToAnsi(cMsg) SIZE 130, 10 PIXEL OF oDlg FONT oDlg:oFont
    oDlg:bStart = { || Eval( bAction ), oDlg:End() }

    ACTIVATE DIALOG oDlg CENTERED
Return
