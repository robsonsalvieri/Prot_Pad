#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002B
Função de importação de parâmetros do módulo GFE a partir de arquivo .txt

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFES002B(cArquivo)
	Local aHeader := {}

	Private oBrowse
	Private cAliasPar

	CriaTab(aHeader)

	If CarregaDados(cArquivo,cAliasPar)
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasPar)
		oBrowse:SetFields(aHeader)
		oBrowse:SetFieldMark("MARK")
		oBrowse:SetCustomMarkRec({|| GFES002MRK(.F.)})
		oBrowse:SetAllMark({|| GFES002MRK(.T.)})
		oBrowse:SetMenuDef("GFES002B")
		oBrowse:SetDescription("Parâmetros do Sistema")
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:AddLegend("(cAliasPar)->CONTARQ==(cAliasPar)->CONTLOC","GREEN","Conteúdo Igual")
		oBrowse:AddLegend("(cAliasPar)->CONTARQ!=(cAliasPar)->CONTLOC","RED"  ,"Conteúdo Divergente")
		oBrowse:Activate()
	EndIf

Return

//-------------------------------------------------------------------
// Função MenuDef
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Importar" ACTION "StaticCall(GFES002B,GFES002IMP)" OPERATION 3  ACCESS 0 //Monitor

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTab
Função que cria a estrutura da tabela temporária utilizada para
apresentação dos dados

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab(aHeader)
	Local aStruct    := {}
	Local nTamFilial := Len(xFilial("SX6"))

	aHeader := {{"Filial"          ,"(cAliasPar)->FIL"    ,"C",nTamFilial,0,"@!"},;
				{"Parâmetro"       ,"(cAliasPar)->VAR"    ,"C",10        ,0,"@!"},;
				{"Tipo"            ,"(cAliasPar)->TIPO"   ,"C",1         ,0,"@!"},;
				{"Descrição"       ,"(cAliasPar)->DESCRIC","C",150       ,0,"@X"},;
				{"Conteúdo Arquivo","(cAliasPar)->CONTARQ","C",300       ,0,"@X"},;
				{"Conteúdo Local"  ,"(cAliasPar)->CONTLOC","C",300       ,0,"@X"}}

	aStruct := {{"MARK"   ,"C",2         ,0},;
				{"FIL"    ,"C",nTamFilial,0},;
				{"VAR"    ,"C",10        ,0},;
				{"TIPO"   ,"C",1         ,0},;
				{"DESCRIC","C",150       ,0},;
				{"CONTARQ","C",300       ,0},;
				{"CONTLOC","C",300       ,0}}

	cAliasPar := GFECriaTab({aStruct,{"VAR"}})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados
Lê o arquivo e carrega os dados na tabela temporária

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaDados(cArquivo,cAliasPar)
	Local nHandle    := 0
	Local nInc       := 0
	Local cLine      := ""
	Local cFil       := ""
	Local cParametro := ""
	Local cTipo      := ""
	Local cDescricao := ""
	Local cContArq   := ""

	// Abre o arquivo
	nHandle := FT_FUse(cArquivo)

	// Se houver erro de abertura abandona processamento
	If nHandle < 0
		MsgStop("Erro na abertura do arquivo!","Carregamento dos Dados")
		Return .F.
	EndIf


	nInc := CpoFilArq()

	// Posiciona na primeria linha
	FT_FGoTop()

	ProcRegua(FT_FLastRec())

	//Percorre todo o arquivo
	While !FT_FEOF()

		IncProc()

		cLine  := FT_FReadLn() // Retorna a linha corrente

		If  ("FILIAL" $ cLine) .Or. ("=" $ cLine) .Or. ("°" $ cLine)
			FT_FSKIP()
			Loop
		EndIf

		cFil       := AllTrim(SubStr(cLine, 1        , nInc))
		cParametro := AllTrim(SubStr(cLine, nInc+4   , 10))
		cTipo 	   := AllTrim(SubStr(cLine, nInc+17  , 1))
		cDescricao := AllTrim(SubStr(cLine, nInc+24  , 101))
		cContArq   := AllTrim(SubStr(cLine, nInc+127 , 30))
		cContLoc   := S002RetPar(cParametro)

		// Grava dados na tabela temporária
		RecLock((cAliasPar),.T.)
			(cAliasPar)->FIL     := cFil // Deve importar de acordo com a filial corrente
			(cAliasPar)->VAR     := cParametro
			(cAliasPar)->TIPO    := cTipo
			(cAliasPar)->DESCRIC := cDescricao
			(cAliasPar)->CONTARQ := cContArq
			(cAliasPar)->CONTLOC := cContLoc
		(cAliasPar)->(MsUnlock())

		// Pula para próxima linha
		FT_FSKIP()

	EndDo

	// Fecha o arquivo
	FT_FUSE()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Importa os parâmetros marcados para o sistema

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES002IMP()

	Processa({|| Importacao()},"Importação de Parâmetros do Sistema","Aguarde...")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Importa os parâmetros marcados para o sistema

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importacao()
	Local lDiver   := .F.
	Local xConteud := Nil

	(cAliasPar)->(DbGoTop())
	ProcRegua((cAliasPar)->(LastRec()))

	While (cAliasPar)->(!Eof())
		xConteud := Nil

		//Incrementa régua de progressão
		IncProc()
		//Importa apenas os registros marcados e que não possuem divergencia
		If !Empty((cAliasPar)->MARK) 
			If (cAliasPar)->CONTARQ == (cAliasPar)->CONTLOC
				xConteud := (cAliasPar)->CONTARQ
				If Alltrim(FwNoAccent(xConteud)) == "Parametro em branco"
					xConteud := " "
				EndIf

				PutMv((cAliasPar)->VAR, xConteud, .F.)
			Else 
				lDiver := .T.
			EndIf
		EndIf
		(cAliasPar)->(DbSkip())
	EndDo

	If lDiver
		MsgStop("Existem registros com divergencia que não serão importados!")
	EndIf 
	MsgInfo("Importação finalizada!")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002MRK
Função de marcação dos registros

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES002MRK(lAllMark)
Local cMark := Iif(oBrowse:IsMark(oBrowse:Mark()),"  ",oBrowse:Mark())

	//Marca todos os registros
	If lAllMark
		(cAliasPar)->(DbGoTop())
		While (cAliasPar)->(!Eof())
			RecLock((cAliasPar),.F.)
			(cAliasPar)->MARK := cMark
			(cAliasPar)->(MsUnlock())
			(cAliasPar)->(DbSkip())
		EndDo
		(cAliasPar)->(DbGoTop())
		oBrowse:GoTop()
	//Marca apenas um registro
	Else
		RecLock((cAliasPar),.F.)
		(cAliasPar)->MARK := cMark
		(cAliasPar)->(MsUnlock())
	EndIf

	oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CpoFilArq
Descobre o tamanho do campo Filial no arquivo de importação

@author  Matheus de Souza
@since   21/12/2022
@obs     Para os casos em que os ambientes de exportação e importação
         possuírem tamanho de filial diferentes
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpoFilArq()
Local nRet := 0

	FT_FGoTop()

	//Percorre todo o arquivo
	While !FT_FEOF()

		cLine := FT_FReadLn() // Retorna a linha corrente

		If  ("FILIAL" $ cLine) .Or. ("=" $ cLine) .Or. ("°" $ cLine)
			FT_FSKIP()
			Loop
		Else
			nRet := (At("|",cLine) - 2)
			Exit
		EndIf

	EndDo

Return nRet
