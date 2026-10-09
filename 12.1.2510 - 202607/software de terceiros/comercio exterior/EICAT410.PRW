#Include "Totvs.Ch"
#Include "EICAT410.Ch"
#Include "Average.CH"

#define ATT_COMPOSTO "COMPOSTO"

/*
Programa   : EICAT410
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function EICAT410( cAliasParam, nRecParam, nOpcParam, lExecAuto)
Local lRet      := .F.
Local cMsgRet   := ""
Local cSolucao	:= ""
Local cUrl      := ""
local lPergunte := ExistPerg()
local lProc     := .F.
local lCancelou := .F.

default lExecAuto := isBlind()

lProc := lExecAuto .or. if( lPergunte, Pergunte("EICAT410"), MsgYesNo(STR0002,STR0001) )  //"Esta opção ira realizar o download e integração para o sistema do cadastro de atributos do Portal Unico. Deseja prosseguir?"###"Atenção"
If lProc
	cUrl := AVgetUrl(.T., lExecAuto, @lCancelou, "EIC", .T.)
	If !lCancelou
		If !empty(cUrl)
			lRet := ProcArquiv(@cMsgRet, cUrl, lExecAuto, @cSolucao)
			If lRet
				MsgInfo(STR0003,STR0001) //"Integração de atributos realizada com sucesso!"###"Atenção"
			Else
				EasyHelp(STR0004+CHR(13)+CHR(10)+cMsgRet,STR0001,cSolucao) //"Falha na integração de atributos."###"Atenção"
			EndIf
		EndIf	
	EndIf
EndIf

Return

/*
Programa   : ProcArquiv
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Parâmetros : cMsgRet - Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ProcArquiv(cMsgRet, cUrl, lExecAuto, cSolucao)
Local lRet       := .T.
Local aArquivos  := {}
Local cDirComex  := "\comex"
Local cCaminho   := cDirComex+"\atributos\"
Local oProgress  := nil
local cTimeStamp := ""
local cNCMs      := ""
local nQtdTotNcm := 0
local lCposTime  := EKG->(ColumnPos("EKG_TSTAMP")) > 0 .and. EKH->(ColumnPos("EKH_TSTAMP")) > 0
local nQtdDom    := 0

default cMsgRet    := ""
default cUrl       := ""
default lExecAuto  := isBlind()

//Verifica estrutura de pastas
lRet := ExisteComex(cDirComex,cCaminho,@cMsgRet)

If lRet
	LimpaPasta(cCaminho) //aqui

	//JAVASCRIPT - Download, ordenação e quebra do arquivo json
	MsAguarde({|| lRet := TrataArqs(@cMsgRet, cCaminho, cUrl, @cNCMs, @nQtdTotNcm, @nQtdDom, lExecAuto, @cSolucao)},STR0005,STR0006) //"Integração de Atributos"###"Aguarde...") //aqui
	If lRet
		aArquivos := getJsonFiles(cCaminho)
		If !Empty(aArquivos)
			cTimeStamp := FWTimeStamp(1) // aaaammddhhmmss
			// quando os campos não existir realiza o bloqueio de tudo antes de ser importado os arquivos
			if !lCposTime
				AtuBloqAtt('EKG',cNCMs,cTimeStamp,lCposTime)
				AtuBloqAtt('EKH',cNCMs,cTimeStamp,lCposTime)
			else
				AtuStamp('EKG')
				AtuStamp('EKH')
			endif
			if !lExecAuto
				oProgress := EasyProgress():New(.F.)
				oProgress:SetProcess({|| lRet := MontaThread(aArquivos,oProgress, @cMsgRet, nQtdTotNcm, nQtdDom, cTimeStamp, cCaminho), STR0007 }) //'Iniciando integração...'
				oProgress:Init()
			endif
			if( !lExecAuto, nil , (lRet := MontaThread(aArquivos,oProgress, @cMsgRet, nQtdTotNcm, nQtdDom, cTimeStamp, cCaminho)) )
			LimpaPasta(cCaminho)
			// quando os campos existem realiza o bloqueio somente as NCMs que foram informadas
			if lRet .and. lCposTime
				AtuBloqAtt('EKG',cNCMs,cTimeStamp,lCposTime)
				AtuBloqAtt('EKH',cNCMs,cTimeStamp,lCposTime)
			endif
		Else
			cMsgRet := STR0008 //"Não foi encontrado nenhum arquivo para integração."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
Programa   : MontaThread
Objetivo   : Thread Pai, onde será feito o controle das Threads filhas que serão responsáveis pela integração
Parâmetros : aArquivos 	- Array com os arquivos Json que serão integrados
				 oProgress 	- Objeto de barra de progresso
				 cMsgRet		- Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function MontaThread(aArquivos, oProgress, cMsgRet, nQtdTotNcm, nQtdDom, cTimeStamp, cCaminho)
local cIdThread  := "AT410JOBS"+AllTrim(Str(ThreadId()))
Local nTotThread := 4 //Foi definida a utilização de 4 Threads
Local nMaxThread := 0 //Maximo de arquivos a serem processados por cada Thread
Local nTot       := 0
Local nThread	 := 0
Local aProc		 := {}
Local nCtrJob    := 0
Local lRet       := .T.
Local lRetFilha  := .F.
Local cError     := ""
Local nFilha     := 0

default aArquivos  := {}
default cMsgRet    := ""
default nQtdTotNcm := 0
default nQtdDom    := 0
default cTimeStamp := ""
default cCaminho   := ""

Begin Sequence

if oProgress <> nil 
	oProgress:SetRegua(nQtdTotNcm+nQtdDom)
endif

nMaxThread := int(Len(aArquivos)/nTotThread)
nTot := 1
nThread := 0
aProc := {}
Do While nTot <= Len(aArquivos)
	aAdd(aProc,aArquivos[nTot])
	if nTot == Len(aArquivos) .OR. (nMaxThread == Len(aProc) .And. nThread+1 < nTotThread)
		nThread++
		StartJob("AT410JOBS",GetEnvServer(),.F., aProc, cEmpAnt, cFilAnt, cIdThread, nThread, cTimeStamp, cCaminho)
		//AT410JOBS(aProc, cEmpAnt, cFilAnt, "AT410JOBS"+AllTrim(Str(ThreadId())), nThread, cTimeStamp, cCaminho)
		FwFreeArray(aProc)
		aProc := {}
	ENdif
	nTot++
EndDo

//Recebe uma reposta a cada registro processado para incrementar o Progress
While !killapp() .and. nQtdTotNcm > 0 .and. (nQtdTotNcm + nQtdDom) != nCtrJob
	nFilha := 0
	lRetFilha := IpcWaitEx(cIdThread, 100, @nFilha, @cError)
	If lRetFilha
		If Empty(cError)
			nCtrJob++
			if oProgress <> nil 
				oProgress:IncRegua()
			endif
		Else
			cMsgRet := cError
			lRet := .F.
			Break
		EndIf
	EndIf
End

//Grava data e hora de atualização
If lRet
	PutMv("MV_EIC0071", FWTimeStamp(2))
EndIf

End Sequence

Return lRet

/*
Programa   : AT410JOBS
Objetivo   : Threads filhas respinsáveis por processar os arquivos json e gravar no protheus
Parâmetros : cID 			- Código que identifica a Thread em execução
				 aArquivos	- Array que contém os arquivos a serem processados pela Thread
				 cEmp			- Código da empresa para abertura do ambiente
				 cFil			- Código da filial para abertura do ambiente
				 cIdPai		- Código que identifica a Thread Pai
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function AT410JOBS(aArquivos, cEmp, cFil, cIdPai, nFilha, cTimeStamp, cCaminho)
local lRet       := .T.
local bErroBlock := nil
local lOpenAmb   := .F.
local lCondTe    := .F.
local lCpoTime   := .F.
local EKGFilial  := ""
local EKHFilial  := ""
local nArq       := 0
local cFile      := ""
local cConteudo  := ""
local oJson      := nil
local cError     := ""
local aListaNcm  := {}
local nNcm       := 0
local cAtributo  := ""
local oAtributo  := nil
local cNcm       := ""
local aNcmAtrib  := {}
local nAtributos := 0
local oNcmDados  := nil
local nTamCod    := 0
local nTamCodTe  := 0
local nTamCodDom := 0
local nTamCodNCM := 0
local aListaDom  := {}
local nDom       := 0

default aArquivos  := {}
default cEmp       := ""
default cFil       := ""
default cIdPai     := ""
default nFilha	    := 0
default cTimeStamp := ""
default cCaminho   := ""

bErroBlock := ErrorBlock({|oError| cError := STR0009 + " - " + alltrim(oError:Description),  FWLogMsg( "INFO",,"EICAT410_"+cValToChar(ThreadId()),,,, alltrim(oError:Description)) , mybreak() }) // "Houve uma falha ao ler o arquivo JSON"

RpcSetType(3)
lOpenAmb := RpcSetEnv(cEmp,cFil)

Begin Sequence

EKG->(dbSetOrder(1))//EKG_FILIAL, EKG_NCM, EKG_COD_I
EKH->(dbSetOrder(1))//EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
lCondTe := EKG->(ColumnPos("EKG_CONDTE")) > 0
lCpoTime := EKG->(ColumnPos("EKG_TSTAMP")) > 0 .and. EKH->(ColumnPos("EKH_TSTAMP")) > 0
EKGFilial := xFilial('EKG')
EKHFilial := xFilial('EKH')

nTamCod := AVSX3("EKG_COD_I",AV_TAMANHO)
nTamCodTe := if( lCondTe, AVSX3("EKG_CONDTE",AV_TAMANHO), 0)
nTamCodDom := AVSX3('EKH_CODDOM',AV_TAMANHO)
nTamCodNCM := AVSX3("EKG_NCM",AV_TAMANHO)

For nArq := 1 To Len(aArquivos)

	cFile := aArquivos[nArq]

	if(ExistFunc("FWMonitorMsg"),FWMonitorMsg( STR0018 + ": " + cFile) ,nil) // "Processando o arquivo"

	cConteudo := EasyMemoRead(cFile)

	oJson := JsonObject():New()
	if empty(cConteudo) .or. !ValType(oJson:FromJson( cConteudo )) == "U"
		cError := STR0009
		mybreak()
	EndIf

	//BEGIN TRANSACTION

	if 'file_atributos_' == substr( strtran(cFile, cCaminho, "") , 1, len("file_atributos_"))

		aListaNcm := oJson:GetJsonObject("listaNcm")
		for nNcm := 1 To Len(aListaNcm)
			
			cAtributo := ''
			oAtributo := aListaNcm[nNcm]
			cNcm := PadR(StrTran(oAtributo:getJsonText('codigoNcm'),'.',''),nTamCodNCM)
			aNcmAtrib := oAtributo:getJsonObject('listaAtributos')

			nAtributos := 1
			while nAtributos <= Len(aNcmAtrib)
				oNcmDados := aNcmAtrib[nAtributos]
				cAtributo := oNcmDados:GetJsonText('codigo')
					gravaEKG(nFilha, oNcmDados, cNcm, cAtributo, , EKGFilial, EKHFilial, lCondTe, lCpoTime, cTimeStamp, nTamCod, nTamCodTe, nTamCodDom)
				nAtributos++
				FwFreeObj(oNcmDados)
			end

			FwFreeObj(oAtributo)
			JobResp(cIdPai, nFilha, cError) //Informa Thread pai que o registro foi processado
		next

	elseif 'file_dominios_' == substr( strtran(cFile, cCaminho, "") , 1, len("file_dominios_"))

		aListaDom := oJson:GetJsonObject("detalhesAtributos")
		cNcm := PadR("", nTamCodNCM)
		for nDom := 1 to len(aListaDom)
			oAtributo := aListaDom[nDom]
			cAtributo := PadR(oAtributo:getJsonText('codigo'),nTamCod)

			gravaEKH(oAtributo:GetJsonObject('dominio'), EKHFilial, cNcm, cAtributo, nTamCodDom, lCpoTime, cTimeStamp)

			FwFreeObj(oAtributo)
			JobResp(cIdPai, nFilha, cError) //Informa Thread pai que o registro foi processado
		next

	endif

	//END TRANSACTION

	cConteudo := ""
	FwFreeArray(aListaNcm)
	FwFreeObj(oJson)
next

End Sequence

ErrorBlock(bErroBlock)

if !empty(cError)
	JobResp(cIdPai, nFilha, cError)
endif

if lOpenAmb
	RpcClearEnv()
endif

Return lRet

static function mybreak()
break; return

/*
Programa   : JobResp
Objetivo   : Funções que fazem a comunicação com a Thread Pai
Parâmetros : cID		- Código da Thread
				 nRet 	- Informa a quantidade de NCMs a serem processadas para informar a barra de progresso
				 cError	- Informa erro para a Thread Pai
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function JobResp(cID, nFilha, cError)
While !killapp() .And. !IPCGo(cID, nFilha, cError)
    Sleep(100)
End
Return .T.

/*
Programa   : gravaEKG
Objetivo   : Gravar a tabela EKG o registro principal e o registro condicionante
Parâmetros : lInsere - .t. insere um registro, .f. altera
			 oNcmDados - objeto com os dados a serem inseridos ou alterados
			 cNcm - ncm a ser inserido			 
			 cAtributo -  indica o atributo principal
             cAtrCondte - indica o atributo condionante
Retorno    : lRet - sempre retorna .t.
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function gravaEKG(nFilha, oNcmDados, cNcm, cAtributo, cAtrCondte, cFilEKG, cFilEKH, lCondTe, lCpoTime, cTimeStamp, nTamCod, nTamCodTe, nTamCodDom, cCondicao)
local lInsere    := .F.
Local lRet       := .T.
Local xOrgao     := nil
//Local xDominio   := nil
Local xObjetivos := nil
Local xComposto  := nil
local cMultVal   := ""
Local cCodObj    := ""
Local cOrgao     := ""
Local nObj       := 0
Local nOrg       := 0
Local nComp      := 0
Local cForma     := ""
Local oAttComp   := nil
Local cAtribComp := ""
local xCondicion := nil
local oAttCond   := nil
local cAtribCond := ""
local cUpdate    := ""

default cNcm       := ""
default cAtributo  := ""
default cAtrCondte := ""
default cFilEKG    := xFilial('EKG')
default cFilEKH    := xFilial('EKH')
default lCondTe    := EKG->(ColumnPos("EKG_CONDTE")) > 0
default lCpoTime   := EKG->(ColumnPos("EKG_TSTAMP")) > 0 .and. EKH->(ColumnPos("EKH_TSTAMP")) > 0
default cTimeStamp := ""
default nTamCod    := AVSX3("EKG_COD_I",AV_TAMANHO)
default nTamCodTe  := if( lCondTe, AVSX3("EKG_CONDTE",AV_TAMANHO), 0)
default nTamCodDom := AVSX3('EKH_CODDOM',AV_TAMANHO)
default cCondicao  := ""

	cAtributo := PADR(cAtributo,nTamCod)
	lInsere := !EKG->(dbSeek(cFilEKG + cNcm + cAtributo + iif(lCondTe,PADR(cAtrCondte,nTamCodTe),'')  ))

	xOrgao		:= oNcmDados:getJsonObject('orgaos')
	///xDominio	:= oNcmDados:getJsonObject('dominio')
	xObjetivos	:= oNcmDados:getJsonObject('objetivos')
	cMultVal    := if(oNcmDados:getJsonText('multivalorado')=="true", cSim, cNao)

	RecLock('EKG',lInsere)

	EKG->EKG_FILIAL := cFilEKG
	EKG->EKG_NCM	:= cNcm
	EKG->EKG_COD_I	:= cAtributo
	if lCondTe
		EKG->EKG_MULTVA := cMultVal
	EndIf   
	EKG->EKG_NOME	:= GetJsonCpo(oNcmDados,'nomeApresentacao') //DecodeUTF8(oNcmDados:GetJsonText('nomeApresentacao'))

	//Objetivos
	cCodObj := ''
	if xObjetivos != nil
		For nObj := 1 To Len(xObjetivos)
			cCodObj += GetJsonCpo(xObjetivos[nObj],'codigo')//xObjetivos[nObj]:GetJsonText('codigo')
			If nObj < Len(xObjetivos)
				cCodObj += ';'
			EndIf
		Next
		FwFreeArray(xObjetivos)
	EndIf
	EKG->EKG_CODOBJ:= cCodObj
	EKG->EKG_ORIENT:= GetJsonCpo(oNcmDados,'orientacaoPreenchimento')//DecodeUTF8(oNcmDados:GetJsonText('orientacaoPreenchimento'))
	cForma := GetJsonCpo(oNcmDados,'formaPreenchimentoAtributo')
	cForma := if( empty(cForma), GetJsonCpo(oNcmDados,'formaPreenchimento'), cForma )//DecodeUTF8(oNcmDados:GetJsonText('formaPreenchimento'))
	EKG->EKG_FORMA	:= cForma
	EKG->EKG_MODALI := GetModalidade(oNcmDados:GetJsonText('modalidade'))
	EKG->EKG_OBRIGA := IIF(Lower(oNcmDados:GetJsonText('obrigatorio'))=='true','1','2')
	EKG->EKG_INIVIG := SToD(StrTran(oNcmDados:GetJsonText('dataInicioVigencia'),'-',''))
	EKG->EKG_FIMVIG := if( !empty(oNcmDados:GetJsonText('dataFimVigencia')), SToD(StrTran(oNcmDados:GetJsonText('dataFimVigencia'),'-','')), CToD("  /  /    "))

	//Orgao
	cOrgao := ''
	if xOrgao != nil
		For nOrg := 1 To Len(xOrgao)
			cOrgao += xOrgao[nOrg]
			If nOrg < Len(xOrgao)
				cOrgao += ';'
			EndIf
		Next
		FwFreeArray(xOrgao)
	EndIf	
	EKG->EKG_ORGAO := cOrgao
			
	EKG->EKG_TAMAXI := if(oNcmDados:GetJsonText('tamanhoMaximo')=='null',0,Val(oNcmDados:GetJsonText('tamanhoMaximo')))
	EKG->EKG_DECATR := if(oNcmDados:GetJsonText('casasDecimais')=='null',0,Val(oNcmDados:GetJsonText('casasDecimais')))
	EKG->EKG_INFADC := GetJsonCpo(oNcmDados,'informacaoAdicional') //DecodeUTF8(oNcmDados:GetJsonText('informacaoAdicional'))
	EKG->EKG_BRIDAT := GetJsonCpo(oNcmDados,'brid') //DecodeUTF8(oNcmDados:GetJsonText('brid'))
	EKG->EKG_MSBLQL := "2" //Não Bloqueado

	if lCondTe .and. !empty(cAtrCondte)
		EKG->EKG_CONDTE := cAtrCondte 
		EKG->EKG_CONDIC := cCondicao
	EndIf

	if lCpoTime
		EKG->EKG_TSTAMP := cTimeStamp
	endif
	EKG->(MsUnlock())

	if lCpoTime .and. EKH->(dbSeek(xFilial("EKH") + EKG->EKG_NCM + EKG->EKG_COD_I))
		cUpdate := " UPDATE  " + RetSqlName("EKH") + " "
		cUpdate += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "
		cUpdate += " WHERE  EKH_FILIAL = '" + xFilial("EKH") + "' "
		cUpdate += " AND D_E_L_E_T_ = ' ' AND EKH_TSTAMP < '" + cTimeStamp + "' "
		cUpdate += " AND EKH_NCM = '" + EKG->EKG_NCM + "' AND EKH_COD_I = '" + EKG->EKG_COD_I + "' "
		if( TcSQLExec(cUpdate) < 0 , UserException("Erro update EKH - " + TCSQLError()) , TcRefresh(RetSQLName("EKH")) )
	endif

	//Dominios
	// If ValType(xDominio) != "U"
	// 	gravaEKH(xDominio, cFilEKH, cNcm, cAtributo, nTamCodDom, lCpoTime, cTimeStamp)
	// 	FwFreeArray(xDominio)
	// EndIf 

	// Tratamento para gravar atributos condicionados
	if oNcmDados:getJsonObject('atributoCondicionante') <> nil .and. oNcmDados:GetJsonText('atributoCondicionante') == "true" 
		xCondicion := oNcmDados:getJsonObject('condicionados')
		if xCondicion != nil .and. valtype(xCondicion) == "A"
			for nComp := 1 to len(xCondicion)

				oAttCond := xCondicion[nComp]
				cCondicao := oAttCond:GetJsonText('condicao')

				if oAttCond:getJsonObject('atributo') <> nil
					cAtribCond := oAttCond:getJsonObject('atributo'):GetJsonText('codigo')
					if !empty(cAtribCond) .and. !alltrim(cCondicao) == 'null'
						gravaEKG(nFilha, oAttCond:getJsonObject('atributo'), cNcm, cAtribCond, cAtributo, cFilEKG, cFilEKH, lCondTe, lCpoTime, cTimeStamp, nTamCod, nTamCodTe, nTamCodDom, cCondicao)
					endif
				endif
				FwFreeObj(oAttCond)

			next
			FwFreeArray(xCondicion)
		endif
	endif

	//TRATAMENTO PARA ATRIBUTOS COMPOSTOS - "formaPreenchimento" : "COMPOSTO"
	If cForma == ATT_COMPOSTO
		xComposto := oNcmDados:getJsonObject('listaSubatributos') //Lista de Sub-Atributos de um Atributo Composto
		if xComposto != nil
			For nComp := 1 To Len(xComposto)
				oAttComp	:= xComposto[nComp]
				cAtribComp	:= oAttComp:GetJsonText('codigo')
				gravaEKG(nFilha, oAttComp, cNcm, cAtribComp, cAtributo, cFilEKG, cFilEKH, lCondTe, lCpoTime, cTimeStamp, nTamCod, nTamCodTe, nTamCodDom)
				FwFreeObj(oAttComp)
			Next
			FwFreeArray(xComposto)
		EndIf
	EndIf

return lRet

/*
Programa   : gravaEKH
Objetivo   : Gravar a tabela EKH 
Parâmetros :
Retorno    : 
Autor      : 
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function gravaEKH(xDominio, cFilEKH, cNcm, cAtributo, nTamCodDom, lCpoTime, cTimeStamp)
	local lInsere    := .F.
	local oDominio   := nil
	local nDom       := 0
	local cCodDom    := ""
	local aCodDom    := {}
	local cDescricao := ""

	default cFilEKH    := xFilial('EKH')
	default cNcm       := ""
	default cAtributo  := ""
	default nTamCodDom := AVSX3('EKH_CODDOM',AV_TAMANHO) 
	default lCpoTime   := EKG->(ColumnPos("EKG_TSTAMP")) > 0 .and. EKH->(ColumnPos("EKH_TSTAMP")) > 0
	default cTimeStamp := ""

	lNaoExist := EKH->(!dbSeek(cFilEKH + cNcm + cAtributo))

	For nDom := 1 To Len(xDominio)
		oDominio := xDominio[nDom]
		cCodDom := PADR(oDominio:GetJsonText('codigo'),nTamCodDom)
		cDescricao := alltrim(GetJsonCpo(oDominio,'descricao'))
		lInsere := (lNaoExist .and. aScan(aCodDom, {|X| X == cCodDom}) == 0) .or. EKH->(!dbSeek(cFilEKH + cNcm + cAtributo + cCodDom))
		RecLock("EKH",lInsere)
		if lInsere
			EKH->EKH_FILIAL := cFilEKH
			EKH->EKH_NCM 	:= cNcm
			EKH->EKH_COD_I	:= cAtributo
			EKH->EKH_CODDOM := cCodDom
		endif
		if lInsere .or. !(alltrim(EKH->EKH_DESCRE) == cDescricao)
			EKH->EKH_DESCRE := cDescricao
		endif
		EKH->EKH_MSBLQL := "2" //Liberado
		if lCpoTime
			EKH->EKH_TSTAMP := cTimeStamp
		endif
		EKH->(MsUnlock())
		aAdd( aCodDom , cCodDom )
		FwFreeObj(oDominio)
	Next

	FwFreeArray(aCodDom)
return

/*
Programa   : GetJsonCpo
Objetivo   : Retornar uma Tag do Json
Parâmetros : oObj		- Objeto Json
				 cTag 	- Tag da informação a ser obtida
Retorno    : cInfo - Informação a ser gravada no campo
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetJsonCpo(oObj,cTag)
Local cRet
Local cInfo
local cInfDecode

cInfo := oObj:GetJsonText(cTag)
If Alltrim(cInfo) == 'null' .Or. Empty(cInfo)
	cRet := " "
Else
	cInfDecode := DecodeUTF8(cInfo)
	cRet := if( cInfDecode == nil, cInfo, cInfDecode)
EndIf
Return cRet

/*
Programa   : getJsonFiles
Objetivo   : Verifica na pasta os arquivos json que serão integrados
Parâmetros : cDir 		- Pasta onde deve conter os arquivos json no servidor
Retorno    : aFiles - Retorna os arquivos json encontrados no caminho especificado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function getJsonFiles(cDir)
Local i, aDir, aFiles := {}

aDir := Directory(cDir+"/*.json")
For i := 1 To Len(aDir)
	If aDir[i][1] <> "." .AND. aDir[i][1] <> ".."
		aDir[i][1] := lower(aDir[i][1])
		If At(".json",aDir[i][1]) > 0
			aAdd(aFiles,cDir+aDir[i][1])
		EndIf
	EndIf
Next i

Return aSort(aFiles)

/*
Programa   : UnzipJson
Objetivo   : Desconpacta um arquivo .Zip
Parâmetros : cCaminho	- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha ao descompactar o arquivo .Zip
Retorno    : lRet - Retorna se descompactou com sucesso ou não
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function UnzipJson(cCaminho,cMsgRet)
Local lRet := .T.
Local nRetZip
Local cArquivo
Local i:=0
Local aArquivos := Directory(cCaminho + '*.zip')

for i:=1 to len(aArquivos)
	cArquivo := lower(cCaminho+aArquivos[i][1])
	nRetZip := FUnZip(cArquivo,cCaminho)
	If nRetZip != 0
		cMsgRet := STR0011 + ' ' + cArquivo //"Falha ao descompactar o arquivo."
		lRet := .F.
		exit
	EndIf
next

Return lRet

/*
Programa   : TrataArqs
Objetivo   : Baixa arquivo pelo javascript e descompacta o retorno pro protheus processar
Parâmetros : cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
				 cCaminho	- Pasta onde deve conter os arquivos json no servidor
Retorno    : lRet - Retorna se tudo foi efetuado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function TrataArqs(cMsgRet,cCaminho,cUrl,cNCMs,nQtdTotNcm,nQtdDom,lExecAuto, cSolucao)
Local lRet := .T.

default lExecAuto := isBlind()

if( !lExecAuto, MsProcTxt(STR0013), nil ) //"Iniciando o download do arquivo de atributos... "
lRet := BaixaJson(@cMsgRet,cCaminho,cUrl, @cNCMs, @nQtdTotNcm, @nQtdDom, lExecAuto, @cSolucao)
If lRet
	//Extrai os arquivos compactados
	if( !lExecAuto, MsProcTxt(STR0014), nil )//"Descompactando arquivos baixados... "
	lRet := UnzipJson(cCaminho,@cMsgRet)
EndIf

Return lRet

/*
Programa   : ExisteComex
Objetivo   : Verifica a estrutuda de pastas necessárias para o correto funcionamento da rotina
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cDir			- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
Retorno    : lRet - Retorna se a estrutura de pastas esntão corretas
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ExisteComex(cDirComex,cDir,cMsgRet)
Local lRet := .T.
Begin Sequence
//Verifica se exsite a pasta comex dentro da Protheus_data
If !ExistDir(cDirComex)
	If MakeDir(cDirComex) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf

If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf
End Sequence
Return lRet

/*
Programa   : GetModalidade
Objetivo   : Recebe a modalidade enviada pelo Json e retorna o código a ser gravado na tabela
Parâmetros : cModalidade - Nome da Modalidade
Retorno    : cRet - Retorna o código da modalidade (1=Importação; 2=Exportação; 3=Ambos)
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetModalidade(cModalidade)
Local cRet := '3'

if !empty(cModalidade)
	If 'EXPORT' $ upper(cModalidade)
		cRet := '2'
	ElseIf 'IMPORT' $ upper(cModalidade)
		cRet := '1'
	EndIf
endif
Return cRet

/*
Programa   : EasyMemoRead
Objetivo   : Faz a leitura do arquivo do disco para a memória
Parâmetros : cFile - Arquivo a ser lido
Retorno    : cText - Retorna o conteúdo do arquivo no formato texto
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function EasyMemoRead(cFile)
Local cText    := ""
Local nHdl     := FOpen(cFile,64)
local nTamanho := 0

If nHDL >= 0
	nTamanho := Fseek(nHdl,0,2)
	FSeek(nHdl,0)
    FRead(nHdl,@cText,nTamanho)
    FClose(nHdl)
EndIf
 
Return cText

/*
Programa   : LimpaPasta
Objetivo   : Exclui todos os arquivos da pasta informada
Parâmetros : cCaminho - Caminho que devem ser excluídos os arquivos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function LimpaPasta(cCaminho)
AEval(Directory(cCaminho+"\*.*"), { |aFile| FErase(cCaminho+"\"+aFile[1]) })
Return

/*

/*
Programa   : AtuBloqAtt
Objetivo   : Realizar um update bloqueando os registros que não foram processados pelo arquivo
Parâmetros : cTab - Tabela que terá os rgistros bloqueados
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function AtuBloqAtt(cTab, cNCMs, cTimeStamp, lCpos)
Local cQuery    := ""
local aNCMS     := {}
local nNCMs     := 0
local cUpdate   := ""
local cNCMUpd   := ""
local lErro     := .F.
local nLimite   := 0
local nIniNcm   := 0
local nFimNcm   := 0
local nTotNcm   := 0
local cAliasQry := ""
local aFilInfos := {} 
local oQuery    := nil
local nFil      := 0
local aAtribDom := {}

default cNCMs      := ""
default cTimeStamp := ""
default lCpos      := (cTab)->(ColumnPos(cTab + "_TSTAMP")) > 0

cQuery := " UPDATE  " + RetSqlName(cTab) + " "
cQuery += " SET " + cTab + "_MSBLQL = '1' "
cQuery += " WHERE  " + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
cQuery += " AND " + cTab + "_MSBLQL = '2' AND D_E_L_E_T_ = ' ' "

if lCpos .and. !empty(cNCMs)

	aNCMS := StrTokArr( StrTran( StrTran( cNCMs, ".", "" ), '"', "'"),",")
	nTotNcm := len(aNCMS)
	nIniNcm := 1
	nLimite := 500
	nFimNcm := nLimite

	while !lErro .and. nTotNcm > 0

		cNCMUpd := ""
		nFimNcm := if( nTotNcm < nLimite , len(aNCMS), nFimNcm )

		for nNCMS := nIniNcm to nFimNcm
			cNCMUpd += aNCMS[nNCMS] + ","
		next
		nTotNcm -= nLimite
		nFimNcm += nLimite
		nIniNcm += nLimite
		cNCMUpd := substr(cNCMUpd,1,len(cNCMUpd)-1)
		
		cUpdate := cQuery
		cUpdate += " AND " + cTab + "_NCM IN ( " + cNCMUpd + " ) AND " + cTab + "_TSTAMP < '" + cTimeStamp + "' "

		lErro := !lErro .and. TcSQLExec(cUpdate) < 0
		if( lErro , UserException("Erro update - " + TCSQLError()) , TcRefresh(RetSQLName(cTab)) )

	end

	if cTab == "EKH" .and. EKH->(dbSeek(xFilial(cTab) + PadR("", len(EKH->EKH_NCM))))
		cAliasQry := getNextAlias()

		cQuery := " SELECT EKH_COD_I "
		cQuery += " FROM " + RetSqlName("EKH") + " EKH "
		cQuery += " WHERE EKH.D_E_L_E_T_ = ' ' AND EKH.EKH_MSBLQL = '2' AND EKH_NCM = ' ' "

		aFilInfos := {} 
		aAdd( aFilInfos , xFilial("EKH"))
		cQuery += " AND EKH.EKH_FILIAL = ? "

		aAdd( aFilInfos , cTimeStamp)
		cQuery += " AND EKH.EKH_TSTAMP = ? "

		cQuery += " GROUP BY EKH_COD_I "

		oQuery := FWPreparedStatement():New(cQuery)
		for nFil := 1 to len(aFilInfos)
			oQuery:SetString(nFil,aFilInfos[nFil])
		next
		cQuery := oQuery:GetFixQuery()

		MPSysOpenQuery(cQuery, cAliasQry)

		(cAliasQry)->(dbGoTop())
		while (cAliasQry)->(!eof())
			aAdd( aAtribDom, "'" + (cAliasQry)->EKH_COD_I + "'")
			(cAliasQry)->(dbSkip())
		end
		(cAliasQry)->(dbCloseArea())
		fwFreeObj(oQuery)

		nTotNcm := len(aAtribDom)
		nIniNcm := 1
		nLimite := 500
		nFimNcm := nLimite
		cQuery := " UPDATE  " + RetSqlName(cTab) + " "
		cQuery += " SET " + cTab + "_MSBLQL = '1' "

		cQuery += " WHERE  " + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
		cQuery += " AND " + cTab + "_MSBLQL = '2' AND D_E_L_E_T_ = ' ' AND EKH_NCM = ' ' "
		while !lErro .and. nTotNcm > 0

			cNCMUpd := ""
			nFimNcm := if( nTotNcm < nLimite , len(aAtribDom), nFimNcm )

			for nNCMS := nIniNcm to nFimNcm
				cNCMUpd += aAtribDom[nNCMS] + ","
			next
			nTotNcm -= nLimite
			nFimNcm += nLimite
			nIniNcm += nLimite
			cNCMUpd := substr(cNCMUpd,1,len(cNCMUpd)-1)
			
			cUpdate := cQuery
			cUpdate += " AND " + cTab + "_COD_I IN ( " + cNCMUpd + " ) AND " + cTab + "_TSTAMP < '" + cTimeStamp + "' "

			lErro := !lErro .and. TcSQLExec(cUpdate) < 0
			if( lErro , UserException("Erro update - " + TCSQLError()) , TcRefresh(RetSQLName(cTab)) )

		end


	endif

endif

if( !lCpos .and. empty(cNCMs) .and. !empty(cQuery) .and. TcSQLExec(cQuery) < 0 , UserException("TCSQLError() " + TCSQLError()), TcRefresh(RetSQLName(cTab)) )

Return

/*
Programa   : BaixaJson
Objetivo   : Efetuar o acesso ao portal unico, baixar o arquivo json, organizar e efetuar a quebra em arquivos menores. Será gerado um .zip destes arquivos para o Protheus Processar.
Parâmetros : -
Retorno    : -
Autor      : AAF - Alessandro Alves Ferreira
Data/Hora  : 04/05/2020
Obs.       :
*/
Static Function BaixaJson(cMsgRet, cCaminho, cUrl, cNCMs, nQtdTotNcm, nQtdDom, lExecAuto, cSolucao)
local cScript    := ""
Local oJS        := nil
Local cLib       := ""
Local lRet 	     := .T.
Local cFetch     := ""
Local cUrlApi    := cUrl + '/cadatributos/api'
Local cUrlDwn    := cUrlApi + '/atributo-ncm/download/json'
Local cUrlRedir  := cUrlDwn + '?perfil=PUBLICO'
local nTotProc   := 0
local nQtdTot    := 0
local lErroGrave := .F.
local lStart     := .F.

default cNCMs      := "" 
default nQtdTotNcm := 0
default nQtdDom    := 0
default lExecAuto  := .F.

	GetRemoteType( @cLib )
	cFetch  := if( "HTML" $ cLib , "advplFetch" , "fetch" )

	if ExistPerg()
		cNCMs := getNCMs()
		if empty(cNCMs)
			lRet := .F.
			cMsgRet := STR0017 // "Não foram encontados dados que atendam às parametrizações configuradas."
			cSolucao:= STR0028 //"Verifique se a NCM informada existe no Cadastro de N.C.M. ou se já foi utilizada no Cadastro de Produtos."
		endif
	endif

	if lRet
		oJS := EasyJS():New()
		oJS:cUrl := cUrlApi
		oJS:setTimeOut(30)
		oJS:AddLib( TEGetJSZip() )
		lRet := oJS:Activate(.T.)	
		if lRet
			oJS:setTimeOut(0)
			oJS:Accumulate(.F.)
			cScript := getScript( cFetch, cUrlRedir, cNCMs, ("HTML" $ cLib) )
			oJS:runJS( cScript, {|x| lRet := BufferResp(x, @cMsgRet, cCaminho, @nQtdTot, @nTotProc, @nQtdTotNcm, @nQtdDom, @lStart, lErroGrave, lExecAuto) }, {|e| lRet := .F., lErroGrave := .T., cMsgRet := STR0016 + CHR(10) + CHR(10) + e} ) //"Falha no download do arquivo no portal único: "
			oJS:Wait({|| lErroGrave .or. (nQtdTot > 0 .and. nTotProc == nQtdTot) .or. (lStart .and. nQtdTotNcm == 0) }) 
			lRet := empty(cMsgRet)
		endif
		oJS:Destroy()
		FwFreeObj(oJS)
	endif

Return lRet 

static function getScript(cFetch, cUrlRedir, cNCMs, lHtml)
	local cScript := ""
	local cHtml   := ""

	default lHtml := .F.

	cHtml := if( lHtml, " 1 == 1 ", " 1 != 1 ")

	begincontent var cScript

      let retornoError = null;
      let bufferNcm = [];
      let contArq = 0; // quantidade de arquivo json
      let QtdTotal = 0; // quantidade total de NCM
      let nSeqArq = 0; // sequencial de arquivos
      let nSeqArqDom = 0;
      let lDetailAtrib = false;
      let lista_dominios = [];

      async function processZip(zip) {

			retAdvplChunk({ log_trade_easy: '%Exp:STR0021%' }); // "Processando o arquivo zip"

         let fileNames = Object.keys(zip.files);
         let chunkSize = 100 * 1024 * 1024;
         let jsonFiles = fileNames.filter(fileName => fileName.endsWith('.json'));
         let aNcms = [ %Exp:cNCMs% ];
         let oAtributos = null;

         for (let fileName of jsonFiles) {
      
            let arrayBuffer = await zip.file(fileName).async('arraybuffer');
            let totalChunks = Math.ceil(arrayBuffer.byteLength / chunkSize);
            let aJsonNcms = [];
            let aJsonDetailAtrib = [];

            for (let i = 0; i < totalChunks; i++) {
      
               let start = i * chunkSize;
               let end = Math.min(start + chunkSize, arrayBuffer.byteLength);
               let chunk = arrayBuffer.slice(start, end);
               let chunkString = new TextDecoder('utf-8').decode(chunk);

               let jsonListNCM = processChunkListaNCM(chunkString, i);
               let jsonDetAtrib = processChunkDetAtrib(chunkString);

               if (totalChunks > 1) {
						retAdvplChunk({ log_trade_easy: '%Exp:STR0022%' + ' (' + (i + 1) + ')' }); // "Processando particoes do arquivo zip"
					}

               if (typeof jsonListNCM === 'string' && jsonListNCM.trim() !== '') {                  
                  aJsonNcms.push(jsonListNCM);
               }

               if (typeof jsonDetAtrib === 'string' && jsonDetAtrib.trim() !== '') {
                  aJsonDetailAtrib.push(jsonDetAtrib);
               }

               chunkString = null;
               jsonListNCM = null;
               jsonDetAtrib = null;
            }

            arrayBuffer = null;
            if( lDetailAtrib && aJsonDetailAtrib.length > 0 ) {
               oAtributos = JSON.parse(aJsonDetailAtrib.join(''));
            }

            if ( aJsonNcms.length > 0 ) {
               await createZipNCM(aJsonNcms.join(''), aNcms, oAtributos)
            }
            oAtributos = null;

         }
         return
      }
      
      function processChunkListaNCM(chunkString, contChunk) {
         let stringResult = '';
         let stringFinal = '';
         let index = chunkString.lastIndexOf('codigoNcm');

         if (index > 0 || bufferNcm.length > 0) {
  
            // caso tenha buffer da String anterior 
            if (bufferNcm.length > 0) {
               // armazena na string result o conteúdo do buffer da string (bufferNcm)
               stringResult += bufferNcm.join('');
               bufferNcm = [];

               // caso tenha buffer da string (bufferNcm) o conteúdo 'detalhesAtributos', já sei que no pedaço de string (chunkString) não terá mais propriedade codigoNcm
               index = stringResult.indexOf('detalhesAtributos');
               if (index > 0) {
                  lDetailAtrib = true;
                  stringResult = stringResult.substring(0, index).replace(/,\n.*$/, "") + '}';
                  return stringResult;
               }
            }
         
            // retira a propriedade versão do pedaço de string (chunkString)
            if (contChunk == 0 && chunkString.indexOf('versao') > 0) {
               index = chunkString.indexOf('codigoNcm');
               chunkString = '{ "listaNcm": [{' + chunkString.substring(index - 1)
            }
        
            // caso no pedaço de string (chunkString) tenha a propriedade 'detalhesAtributos' 
            index = chunkString.indexOf('detalhesAtributos');
            if (index > 0) {
               // não preciso armazenar mais o buffer da string (bufferNcm) e retorno a string result até a última propriedade codigoNcm
               stringResult += chunkString.substring(0, index).replace(/,\n.*$/, "") + '}';
               lDetailAtrib = true;

            } else {
               // caso não tenha a propriedade 'detalhesAtributos' no pedaço de string (chunkString)
               // busca a última propriedade codigoNcm
               index = chunkString.lastIndexOf('codigoNcm');

               if ( index > 0 && index != chunkString.indexOf('codigoNcm')) {
                  // caso tenha a propriedade codigoNcm no pedaço de string (chunkString), quebra a string (chunkString) até a última propriedade codigoNcm                 
                  stringResult += chunkString.substring(0, index - 9) + ','; //']}';
                  stringFinal = '{' + chunkString.substring(index - 1, chunkString.length);
                  bufferNcm.push(stringFinal);

               } else {
                  // Caso não tenha nenhuma propriedade codigoNcm no pedaço de string (chunkString), armazena no buffer da string (bufferNcm)
                  bufferNcm.push(stringResult + chunkString);
                  stringResult = '';

               }   
            }

         }
         return stringResult
      }

      function processChunkDetAtrib(chunkString) {
         let stringResult = '';
         let index = chunkString.indexOf('detalhesAtributos');

         if (index > 0) {
            stringResult = '{"' + chunkString.substring(index, chunkString.length);
         } else {
            if (lDetailAtrib) {
               stringResult = chunkString;
            }
         }

         return stringResult
      }

      function createZipNCM(jsonString, aNcms, oAtributos) {
         return new Promise((resolve, reject) => {
				let obj = JSON.parse(jsonString)

				// Filtra as NCMs presentes em aNcms
				if (aNcms.length > 0) {
					obj.listaNcm = obj.listaNcm.filter(a => aNcms.includes(a.codigoNcm))
				}
		
				// Filtrar a listaNcm com listaAtributos preenchidas
				//obj.listaNcm = obj.listaNcm.filter(item => item.listaAtributos.length > 0);
		
				// Ordenar listaNcm por codigoNcm
				obj.listaNcm.sort((a, b) => a.codigoNcm.localeCompare(b.codigoNcm));
		
				QtdTotal += obj.listaNcm.length;

				if (obj.listaNcm.length > 0) {

					obj.listaNcm = obj.listaNcm.map(ncm => {
						ncm.listaAtributos = ncm.listaAtributos.map(codigo => {
							let detail = oAtributos.detalhesAtributos.find(detalhe => detalhe.codigo === codigo.codigo);
							if (detail) {
								let detailAtrib = {...detail};
								if (detailAtrib.dominio && detailAtrib.dominio.length > 0 )  {
									addDomininios(detailAtrib, codigo.codigo)
								}
								delete detailAtrib.dominio;

								if( detailAtrib.listaSubatributos.length > 0 ){
									processaSubAtrib(detailAtrib.listaSubatributos);
								}

								if( detailAtrib.condicionados.length > 0 ){
									processaCondicionados(detailAtrib.condicionados);
								}

								return {...codigo, ...detailAtrib};
							}
							return codigo;
						});
						return ncm;
					})

					if (lista_dominios.length > 0 ) {
						retAdvplChunk({ quantidade_dominios: lista_dominios.length });
						createZipDomininios()
					}

					let nQtdNcms = 10;
					let nro_arquivos = Math.trunc(obj.listaNcm.length / nQtdNcms) + (obj.listaNcm.length / nQtdNcms == Math.trunc(obj.listaNcm.length / nQtdNcms) ? 0 : 1);
					let partes = Array.from(Array(nro_arquivos).keys());
		
					partes.forEach((n) => {
						contArq++;
						let zip_result = new JSZip();
						let particaoName = "file_atributos_" + (("00000").substring((contArq).toString().length) + (contArq))
						zip_result.file(particaoName + ".json", JSON.stringify({ listaNcm: obj.listaNcm.slice(n * nQtdNcms, Math.min((n + 1) * nQtdNcms, obj.listaNcm.length)) }));
						zip_result.generateAsync({ type: "base64", compression: "DEFLATE" })
						.then((fileZip) => {
							nSeqArq++;
							resolve( retAdvplChunk({ zipname: nSeqArq.toString() , zipfile: fileZip }) );
						})
						.catch((error) => {
							reject( retAdvplError('%Exp:STR0027%' + ':', error.message) ); // "Erro ao criar o arquivo ZIP" ;
						})
						zip_result = null;
					})

				} else {
					resolve();
				}
		
				obj = null;
         });
      }
      
      function addDomininios(detailAtrib, codigo) {
         if (!lista_dominios.some(dom => dom.codigo === codigo)) {
            if (detailAtrib.dominio.length > 0) {
                  lista_dominios.push({
                     codigo: codigo,
                     dominio: detailAtrib.dominio 
               });
            }
         }
      }

      function processaSubAtrib(objeto, codigo) {

         if (Array.isArray(objeto)) {
            objeto.forEach(item => processaSubAtrib(item, item.codigo));
         } else if (typeof objeto === 'object' && objeto !== null) {
            if (objeto.hasOwnProperty('dominio')) {
               addDomininios(objeto, codigo) 
               delete objeto.dominio;
            }

            if (objeto.hasOwnProperty('listaSubatributos') && objeto.listaSubatributos.length > 0) {
               processaSubAtrib(objeto.listaSubatributos);
            }

            if (objeto.hasOwnProperty('condicionados') && objeto.condicionados.length > 0) {
               processaCondicionados(objeto.condicionados);
            }
         }

      }

      function processaCondicionados(objeto, codigo) {

         if (Array.isArray(objeto) && objeto.length > 0) {
            objeto.forEach(item => processaCondicionados(item.atributo, item.atributo.codigo));
         } else if (typeof objeto === 'object' && objeto !== null) {
            if (objeto.hasOwnProperty('dominio')) {
               addDomininios(objeto, codigo) 
               delete objeto.dominio;
            }

            if (objeto.hasOwnProperty('condicionados')  && objeto.condicionados.length > 0) {
               processaCondicionados(objeto.condicionados);
            }

            if (objeto.hasOwnProperty('listaSubatributos') && objeto.listaSubatributos.length > 0) {
               processaSubAtrib(objeto.listaSubatributos);
            }
         }

      }

      function createZipDomininios() {
         return new Promise((resolve, reject) => {
            let nQtdDominios = 1000;
            let nro_arquivos = Math.trunc(lista_dominios.length / nQtdDominios) + (lista_dominios.length / nQtdDominios == Math.trunc(lista_dominios.length / nQtdDominios) ? 0 : 1);
            let partes = Array.from(Array(nro_arquivos).keys());

            partes.forEach((n) => {
               contArq++;
               let zip_result = new JSZip();
               let particaoName = "file_dominios_" + (("00000").substring((contArq).toString().length) + (contArq))
               zip_result.file(particaoName + ".json", JSON.stringify({ detalhesAtributos: lista_dominios.slice(n * nQtdDominios, Math.min((n + 1) * nQtdDominios, lista_dominios.length )) }));
               zip_result.generateAsync({ type: "base64", compression: "DEFLATE" })
               .then((fileZip) => {
                  nSeqArqDom++;
                  resolve(retAdvplChunk({ zipname: 'file_dominios_'+nSeqArqDom.toString() , zipfile: fileZip }));
               })
               .catch((error) => {
                  reject(retAdvplError('%Exp:STR0027%' + ':', error)); // "Erro ao criar o arquivo ZIP" ;
               })
               zip_result = null;
            })
         });
      }

		%Exp:cFetch%('%Exp:cUrlRedir%')
			.then(function (response) {
				retAdvplChunk({ log_trade_easy: '%Exp:STR0026%' }); // "Baixando o arquivo"

				if (%Exp:cHtml%)
					return response.blob();
				else
					if (!response.ok) {
						retornoError = response.status + ' / ' + response.statusText;
						return response.json();
					}
					return response.arrayBuffer();
				endif
			})
			.then(function (data) {
				if( typeof retornoError === 'string') {
               throw new Error( '%Exp:STR0024% ' + ': [' + retornoError + '] - ' + data.message) ; // Erro ao fazer a solicitação da API do cadastro de Atributos
            }
				retAdvplChunk({ log_trade_easy: '%Exp:STR0019%' }); // "Baixou o arquivo zip"
				let zip = new JSZip();
				return zip.loadAsync(data);
			})
			.then(function (zip) {
				retAdvplChunk({ log_trade_easy: '%Exp:STR0020%' }); // "Descompactou o arquivo zip"
				processZip(zip)
					.then(() => {
						retAdvplChunk({ quantidade_arquivos: contArq });
						retAdvplChunk({ quantidade_total_ncm: QtdTotal });
					})
					.catch((error) => {
						retAdvplError(error);
					});
				return
			})
			.catch((error) => {
				retAdvplError(error);
			});

	endcontent

return cScript

static function BufferResp(cRetJson, cErros, cCaminho, nQtdTot, nTotProc, nQtdTotNcm, nQtdDom, lStart, lErroGrave, lExecAuto)
	local lRet       := .T.
	local jObj
	local xRetJson

	default cRetJson    := ""
	default cErros      := ""
	default cCaminho    := ""
	default nQtdTot     := 0
	default nQtdTotNcm  := 0
	default nQtdDom     := 0
	default lErroGrave  := .F.
	default lExecAuto   := .F.

	if '"log_trade_easy"' $ cRetJson 
		FWLogMsg( "INFO",,"EICAT410_"+cValToChar(ThreadId()),,,,FWTimeStamp(5) + " - " + cRetJson )
		if( !lExecAuto, MsProcTxt( alltrim( StrTran( StrTran( StrTran( StrTran(cRetJson,'"log_trade_easy":', ""), "}", ""), "{", ""), '"', "") ) + "..."), nil )

	elseif '"quantidade_arquivos"' $ cRetJson .or. '"quantidade_total_ncm"'  $ cRetJson .or. '"quantidade_dominios"'  $ cRetJson
		FWLogMsg( "INFO",,"EICAT410_"+cValToChar(ThreadId()),,,,FWTimeStamp(5) + " - " + cRetJson )
		jObj := JsonObject():New()
		xRetJson := jObj:FromJson(cRetJson)
		if valtype(xRetJson) == "U"
			if '"quantidade_arquivos"' $ cRetJson
				nQtdTot := val(jObj:GetJsonText("quantidade_arquivos"))
			elseif '"quantidade_dominios"' $ cRetJson
				nQtdDom := val(jObj:GetJsonText("quantidade_dominios"))
			else
				lStart := .T.
				nQtdTotNcm := val(jObj:GetJsonText("quantidade_total_ncm"))
				if nQtdTotNcm == 0
					cErros := STR0025 // "As NCMs não foram localizadas no arquivo de atributos."
				endif

			endif
		endif
		FwFreeObj(jObj)
	elseif !empty(cRetJson)
		nTotProc += 1
		gravaAtributos(cRetJson,cCaminho)	
	endif

	lRet := if( lErroGrave, .F., lRet)

return lRet

/*
Programa   : gravaAtributos
Objetivo   : Pega o array com os vários arquivos zip e grava o arquivo físico
Parâmetros : -cAtributos: contém a string em base64 do arqivo zip
             -cCaminho  : caminho onde será gravado o arquivo
Retorno    : -
Autor      : Maurício Frison
Data/Hora  : 12/12/2022
Obs.       :
*/
static function gravaAtributos(cAtributos,cCaminho)
	local h        := 0
	local cFile    := ""
	local jObj     := nil
	local xRetJson := ""

	jObj := JsonObject():New()
	xRetJson := jObj:FromJson(cAtributos)
	If valtype(xRetJson) == "U"
		cFile := jObj:GetJsonText("zipname")
		h := fcreate(cCaminho + 'atributos_'+alltrim(cFile)+'.zip')
		fwrite(h,Decode64(jObj:GetJsonText("zipfile")))
		fclose(h)
	endif
	fwFreeObj(jObj)

return

/*/{Protheus.doc} ExistPerg
	Função para verificar se a pergunta EICAT410 existe

	@type  Static Function
	@author bruno kubagawa
	@since 29/06/2023
	@version 1.0
	@param cPerg, caractere, código do pergunte, padrão EICAT410
	@return lRet, lógico, .T. caso exista a pergunta e .F. caso não exista a pergunta
/*/
static function ExistPerg(cPerg)
	local lRet       := .F.
	local oFWSX1     := nil
	local aPergunte  := {}

	default cPerg := "EICAT410"

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPerg)
	oFWSX1:SearchGroup()
	aPergunte := oFWSX1:GetGroup(cPerg)
	lRet:= len(aPergunte) > 0 .and. len(aPergunte[2]) > 0
	aSize(aPergunte,0)
	oFWSX1:Destroy()
	FreeObj(oFWSX1)

return lRet

/*/{Protheus.doc} getNCMs
	Função para verificar se a pergunta EICAT410 existe

	@type  Static Function
	@author bruno kubagawa
	@since 29/06/2023
	@version 1.0
	@param nenhum
	@return cRet, caractere, NCMs selecionadas a partir do pergunte EICAT410
/*/
static function getNCMs()
	local cRet       := ""
	local cProdNCM   := "" 
	local cNCMIni    := ""
	local cNCMFim    := ""
	local cQuery     := ""
	local aFilInfos  := {}
	local nFil       := 0
	local cInfNcm    := ""

	pergunte("EICAT410", .F.)
	cProdNCM := if( valtype(MV_PAR01) == "C", alltrim(MV_PAR01) , cValTochar(MV_PAR01))
	cNCMIni := MV_PAR02
	cNCMFim := MV_PAR03

	cAliasQry := getNextAlias()

	cQuery := " SELECT YD_TEC "
	cQuery += " FROM " + RetSqlName("SYD") + " SYD "
	if cProdNCM == "1"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
		cQuery += " SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_IMPORT = 'S' AND SB1.B1_POSIPI = SYD.YD_TEC "
	endif
	cQuery += " WHERE SYD.D_E_L_E_T_ = ' ' "

	aFilInfos := {} 
	aAdd( aFilInfos , xFilial("SYD"))
	cQuery += " AND SYD.YD_FILIAL = ? "

	if cNCMIni == cNCMFim
		aAdd( aFilInfos , cNCMFim)
		cQuery += " AND SYD.YD_TEC = ? "
	else
		aAdd( aFilInfos , cNCMIni)
		aAdd( aFilInfos , cNCMFim)
		cQuery += " AND SYD.YD_TEC BETWEEN ? AND ? "
	endif

	if cProdNCM == "1"
		cQuery += " GROUP BY SYD.YD_TEC "
	endif
	cQuery += " ORDER BY SYD.YD_TEC "

	oQuery := FWPreparedStatement():New(cQuery)
	for nFil := 1 to len(aFilInfos)
		oQuery:SetString(nFil,aFilInfos[nFil])
	next
	cQuery := oQuery:GetFixQuery()

	MPSysOpenQuery(cQuery, cAliasQry)

	(cAliasQry)->(dbGoTop())
	cRet := ""
	while (cAliasQry)->(!eof())
		cInfNcm := alltrim(Transform( (cAliasQry)->YD_TEC, "@R 9999.99.99")) 
		if !(cInfNcm $ cRet)
			cRet += '"' + cInfNcm + '",'
		endif
		(cAliasQry)->(dbSkip())
	end
	cRet := substr(cRet,1,len(cRet)-1)
	(cAliasQry)->(dbCloseArea())
	fwFreeObj(oQuery)

return cRet

/*/{Protheus.doc} AtuStamp
	Devido ao erro de comparação do campo _TSTAMP das tabelas EKG e EKH, houve a necessidade de gravar o campo no formato aaaammddhhmmss e não mais no formato dd/mm/aaaa hh:mm:ss.

	@type  Static Function
	@author user
	@since 17/12/2024
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function AtuStamp(cTable)
	local cAliasQry := ""
	local cQuery    := ""
	local aFilInfos := {}
	local oQuery    := nil
	local nFil      := 0
	local cBancoDb  := Upper(TCGetDb())
	local cFilStamp := ""
	local cCpTSTAMP := cTable + "_TSTAMP"
	local cUpdate   := ""

	cAliasQry := getNextAlias()

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery += " FROM " + RetSqlName(cTable) + " " + cTable + " "
	cQuery += " WHERE " + cCpTSTAMP + " LIKE '%/%' "

	aFilInfos := {} 
	aAdd( aFilInfos , xFilial(cTable))
	cQuery += " AND " + cTable + "." + cTable + "_FILIAL = ? "

	aAdd( aFilInfos , ' ' )
	cQuery += " AND " + cTable + ".D_E_L_E_T_ = ? "

	oQuery := FWPreparedStatement():New(cQuery)
	for nFil := 1 to len(aFilInfos)
		oQuery:SetString(nFil,aFilInfos[nFil])
	next
	cQuery := oQuery:GetFixQuery()
	fwFreeObj(oQuery)

	MPSysOpenQuery(cQuery, cAliasQry)

	(cAliasQry)->(dbGoTop())
	if (cAliasQry)->(!eof()) .and. (cAliasQry)->TOTAL > 0
		// aaaammddhhmmss
		cFilSTAMP := if( cBancoDb == "MSSQL",;
						"(SUBSTRING(" + cCpTSTAMP + ",7,4) + SUBSTRING(" + cCpTSTAMP + ",4,2) + SUBSTRING(" + cCpTSTAMP + ",1,2) + SUBSTRING(" + cCpTSTAMP + ",12,2) + SUBSTRING(" + cCpTSTAMP + ",15,2) + SUBSTRING(" + cCpTSTAMP + ",18,2))",;
						if( cBancoDb == "ORACLE",;
							"(SUBSTR(" + cCpTSTAMP + ",7,4) || SUBSTR(" + cCpTSTAMP + ",4,2) || SUBSTR(" + cCpTSTAMP + ",1,2) || SUBSTR(" + cCpTSTAMP + ",12,2) || SUBSTR(" + cCpTSTAMP + ",15,2) || SUBSTR(" + cCpTSTAMP + ",18,2))",;
							"(SUBSTRING(" + cCpTSTAMP + ",7,4) || SUBSTRING(" + cCpTSTAMP + ",4,2) || SUBSTRING(" + cCpTSTAMP + ",1,2) || SUBSTRING(" + cCpTSTAMP + ",12,2) || SUBSTRING(" + cCpTSTAMP + ",15,2) || SUBSTRING(" + cCpTSTAMP + ",18,2))"))
		cUpdate := " UPDATE  " + RetSqlName(cTable) + " "
		cUpdate += " SET " +  cCpTSTAMP + " = " + cFilSTAMP + " "
		cUpdate += " WHERE " + cCpTSTAMP + " LIKE '%/%' "
		cUpdate += " AND " + cTable + "_FILIAL = '" + xFilial(cTable) + "' "
		cUpdate += " AND D_E_L_E_T_ = ' ' "
		if( TcSQLExec(cUpdate) < 0 , UserException("Erro update " + cTable + " - " + TCSQLError()) , TcRefresh(RetSQLName(cTable)) )

	endif
	(cAliasQry)->(dbCloseArea())

return nil
