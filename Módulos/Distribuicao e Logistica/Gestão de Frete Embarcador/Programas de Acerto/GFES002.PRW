#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

static aValAnt := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002 

Função que lê os dados do txt e permite ao usuario fazer uma leitura e ate importação dos mesmos

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GFES002()
	Local oDlg      := Nil
	Local cSenhaImp := Space(16)

	Private lAbriuSM0 := .F.

	// Abertura de ambiente só pode ser executada se o programa não for acessado pelo GFE/Protheus
	If Select("SM0") <= 0
		OpenSM0()

		dbSelectArea( "SM0" )
		dbGoTop()

		RpcSetType( 3 )
		RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
		lClearEnv := .T.
		lAbriuSM0 := .T.
	EndIf

	DEFINE MSDIALOG oDlg TITLE 'Digite a Senha' From 10,0 To 15,50 OF oMainWnd

	@05,05 MSGET oGet VAR cSenhaImp SIZE 190,12 OF oDlg WHEN .T. PICTURE "@!" PIXEL PASSWORD

	oButtonOK   := tButton():New(25,5,'OK',oDlg,{|| Iif(GFESSenha(cSenhaImp) == .T.,oDlg:End(),nil)},25,10,,,,.T.)
	oButtonCanc := tButton():New(25,35,'Cancelar',oDlg,{||(oDlg:End())},25,10,,,,.T.)

	ACTIVATE MSDIALOG oDlg

Return .T.

//---------------------------------------------------------------------

Function GFESSenha(cSenhaImp)
	If AllTrim(Upper(cSenhaImp)) == AllTrim(Upper(SuperGetMV("MV_SENHA",.F.,"ATENDIMENTOTOTVS")))
		GFES0021()
	Else
		MsgStop("Senha incorreta!")
		Return .F.
	EndIf
Return .T.

//-----------------------------------------------------------------
Function GFES0021()
	Local cValAnt := ""
	Local cArqLog := ""

	//Define a tela
	Define MsDialog oDlgPrin Title "Informe o diretorio do(s) arquivo(s) ..." FROM 200,200 TO 270,770 PIXEL

	//Painel dos botões
	oPanel := tPanel():New(23,0,,oDlgPrin,,,,,RGB( 215, 215, 215 ),300,14,.F.,.F.)

	//Diretorio de exportação
	@ 09 , 10  Say "Arquivo:"  COLOR CLR_BLACK Pixel of oDlgPrin SIZE 40,8
	@ 07 , 35  Get   oGet     Var cArqLog SIZE 200,7 Pixel OF oDlgPrin
	oButtonOK :=tButton():New( 07 , 238 ,"Browse",oDlgPrin,{|| cValAnt := ArquivoDir() , If(!Empty(cValAnt), cArqLog := cValAnt, "")},25,10,,,,.T.) //"Browser" ### "Diretórios"
	oGet:bChange   := {||}

	@ 02 , 170 BUTTON "Ok"       SIZE 50,10 Pixel OF oPanel ACTION Processa( {|| IIf(GFES002A(aValAnt) == .T. , oDlgTab:End() , Nil ) }, "Aguarde...", "Lendo arquivo(s) informado(s)",.F.)
	@ 02 , 230 BUTTON "Cancelar" SIZE 50,10 Pixel OF oPanel ACTION oDlgPrin:End()


	ACTIVATE MSDIALOG oDlgPrin CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002A

Função que monta a tela

@ Param - aValAnt -> Diretorio do log

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES002A(aValAnt)
	Local oDlg                                      // Janela Principal
	Local aSize        := MsAdvSize()               // Dimensionamento/Posicionamento
	Local windowHeight := (aSize[6] - aSize[7]) / 2 // Altura da janela
	Local nI

	// Definição dos Gris
	Private oGetTab // GetDados da tabela de Frete
	Private oGetChv // GetDados da tabela de Negociação
	Private oGetDds // GetDados da tabela de Rotas

	// Definição das temp-tables
	Private  aHeadTab := {} // Header da temp-table de Tabela
	Private  aHeadChv := {} // Header da temp-table da Chave
	Private  aHeadDds := {} // Header da temp-table de

	// aCols das temp-tables
	Private aColsTab  := {} // Cols da temp-table de Negociação
	Private aColsChv  := {} // Cols da temp-table de Negociação
	Private aColsDds  := {} // Cols da temp-table de Rotas

	Private aIndex    := {}
	Private cTexto    := ""
	Private lClear    := .F.

	If Empty(aValAnt)
		Alert("Nenhum arquivo foi informado!!!")
		Return .F.
	EndIf

	For nI := 1 To Len(aValAnt)

		cValAnt := aValAnt[nI][1]

		//Importação de parâmetros
		If At("PAR",cValAnt) > 0
			GFES002B(cValAnt)
			Return
		EndIf

		aHeadTab  := DefTab()    // Definição da Temp-table Tabela de Frete
		aHeadChv  := DefTabChv() // Definição da Temp-table Negociação
		aHeadDds  := DefTabDds() // Definição da Temp-table Rotas

		Define MsDialog oDlg Title "" From aSize[7],00 To aSize[6],aSize[5] Pixel

		//Cria os painéis
		oPanelTop := tPanel():New(0,0,"",oDlg,,,,,,00,70)
		oPanelTop:align:= CONTROL_ALIGN_TOP

		//Painel principal
		oPanelMain := tPanel():New(0,0,"",oDlg,,,,,,00,30)
		oPanelMain:align:= CONTROL_ALIGN_ALLCLIENT

		//Painel das tabelas
		oPanelTab := tPanel():New(0,0,"",oPanelMain,,,,,,00, (windowHeight / 4) + 10)
		oPanelTab:align:= CONTROL_ALIGN_TOP

		//Painel da chave das tabelas
		oPanelCha := tPanel():New(0,0,"",oPanelMain,,,,,,00, 00)
		oPanelCha:align:= CONTROL_ALIGN_ALLCLIENT

		//Painel dos dados da tabela
		oPanelDados := tPanel():New(0,0,"",oPanelMain,,,,,,00, (windowHeight / 4) + 40,)
		oPanelDados:align:= CONTROL_ALIGN_BOTTOM

		// Grid Tabela de Fretes
		oGetTab := MsNewGetDados():New( 005, 005, 120, 265,,,,,,,,,,, oPanelTab  , aHeadTab , )
		oGetTab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetTab:oBrowse:bSeekChange := { || LoadTabChv() }
		oGetTab:oBrowse:bDrawSelect   := { || LoadTabChv() }

		// Grid Negociação
		oGetChv := MsNewGetDados():New( 005, 005, 120, 265,,,,,,,,,,, oPanelCha  , aHeadChv , )
		oGetChv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetChv:oBrowse:bSeekChange   := { || LoadTabDds() }
		oGetChv:oBrowse:bDrawSelect   := { || LoadTabDds() }

		// Grid Rotas
		oGetDds := MsNewGetDados():New( 005, 005, 120, 265,,,,,,,,,,, oPanelDados, aHeadDds , )
		oGetDds:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		LoadTab(cValAnt)
		oGetTab:Refresh()

	Next nI
	// Usando o New
	oTMultiget1 := TMultiget():New(01,01,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oPanelTop,290,67,,,,,,.T.,,,,,,.T.,,,,,)

	oPanel := tGroup():New( 04  , 300 , 45 , 400 , "Importar dados para base local?" , oPanelTop ,, CLR_BLACK , .T. )
	@ 15 , 325 BUTTON "Importar" SIZE 50,10 Pixel OF oPanelTop ACTION Importar(aColsTab)

	//Checkbox que indica se os dados da base serão apagados antes da importação
	@ 30 , 305 CHECKBOX oCheckBox VAR lClear PROMPT "Limpar base antes da importação" SIZE 90, 010 OF oPanelTop PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTab

Função que carrega os dados da tabela no log

@ Param - cValAnt -> Diretorio do log

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTab(cValAnt)
	Local cTab
	Local cCampo
	Local cTipo
	Local cValor
	Local cTitulo
	Local cDEscricao
	Local cChave

	If File(cValAnt)
		//Define o diretorio do arquivo
		cTexto := "Diretório do arquivo: " + cValAnt + CRLF + CRLF

		// Abre o arquivo
		nHandle := FT_FUse( cValAnt )
		If nHandle = -1		// Se houver erro de abertura abandona processamento
			Return
		EndIf

		// Posiciona na primeria linha
		FT_FGoTop()

		ProcRegua( FT_FLastRec() )

		//Percorre todo o arquivo
		While !FT_FEOF()
			IncProc()

			cLine  := FT_FReadLn() // Retorna a linha corrente
			cTab   := SubStr( cLine , 1 , 3 )

			If "=" $ cLine .Or. "°" $ cLine
				cTexto += cLine + CRLF
			Endif

			//Se não existir a tabela cria no array
			If aScan( aColsTab , {|x| x[1] == cTab } ) == 0 .And. cTab != "---" .And. cTab != "===" .And. !( "°" $ cTab )
				SX2->(DbSetOrder(1))
				If SX2->(dbSeek(cTab))
					AAdd(aColsTab,Array(Len(aHeadTab)+2))
					aColsTab[Len(aColsTab),1] := cTab
					aColsTab[Len(aColsTab),2] := X2Nome()
					aColsTab[Len(aColsTab),Len(aHeadTab)+2] :=.F.
				EndIf
			EndIf

			If "CHAVIN" $ cLine
				aadd(aIndex , { cLine } )
				cChave := SubStr( cLine , 17 , 450 )
				If aScan( aColsChv , {|x| x[2] == SubStr( cLine , 17 , 450 ) } ) == 0
					AAdd(aColsChv,Array(Len(aHeadChv)+2))
					aColsChv[Len(aColsChv),1] := cTab
					aColsChv[Len(aColsChv),2] := cChave
					aColsChv[Len(aColsChv),Len(aHeadChv)+2]:=.F.
				Endif
			Else
				cCampo := SubStr( cLine , 1  , 10  )
				cTipo  := SubStr( cLine , 14 , 1   )
				cValor := SubStr( cLine , 17 , 300 )

				AAdd(aColsDds,Array(Len(aHeadDds)+2))
				aColsDds[Len(aColsDds),1] := cCampo

				dbSelectArea("SX3")
				dbSetOrder(2)
				If dbSeek( cCampo )
					cTitulo    := X3Titulo()
					cDEscricao := X3Descric()
				EndIf

				aColsDds[Len(aColsDds),2] := cTitulo
				aColsDds[Len(aColsDds),3] := cDEscricao
				aColsDds[Len(aColsDds),4] := cTipo
				aColsDds[Len(aColsDds),5] := cValor
				aColsDds[Len(aColsDds),6] := cChave
				aColsDds[Len(aColsDds),Len(aHeadDds)+2]:=.F.
			Endif

			// Pula para próxima linha
			FT_FSKIP()
		EndDo

		// Fecha o Arquivo
		FT_FUSE()
	EndIf

	If Len(aColsTab) > 0
		// Atualiza os dados da grid de Tabela de Frete
		oGetTab:SetArray(aColsTab, .T.)
		oGetTab:oBrowse:GoTop()

		// Limpa os dados da grid de Negociação
		oGetChv:SetArray({}, .T.)
		LoadTabChv()
	Else
		oGetTab:SetArray({}, .T.)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTabChv

Carrega os dados da tabela que contem a chave primaria dos registros do visualizador do log

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTabChv()
	Local cTabela := GDFieldGet( 'TABELA', oGetTab:nAt,, oGetTab:aHeader, oGetTab:aCols )
	Local aCols  := {}
	Local nCount := 0

	For nCount := 1 To Len(aColsChv)
		If aColsChv[nCount,1] == cTabela
			AAdd(aCols,Array(Len(aHeadChv)+2))
			aCols[Len(aCols),1]   := aColsChv[nCount,1]
			aCols[Len(aCols),2]   := aColsChv[nCount,2]
			aCols[Len(aCols),Len(aHeadChv)+2]:=.F.
		EndIf
	Next nCount

	// Atualiza os dados da grid de Tabela de Frete
	oGetChv:SetArray(aCols, .T.)
	oGetChv:oBrowse:Refresh()

	//Limpa os dados das grids Rotas, Faixas e Componentes
	oGetDds:SetArray({}, .T.)
	oGetDds:oBrowse:Refresh()

	If Len(aCols) > 0
		LoadTabDds()
	EndIf
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTabDds

Carrega todos os dados da tabela que esta no log

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTabDds()
	Local nCount  := 0
	Local aCols   := {}
	Local cTabela := GDFieldGet( "TABCHA", oGetChv:nAt,, oGetChv:aHeader, oGetChv:aCols )
	Local cChave  := GDFieldGet( "CHAVIN", oGetChv:nAt,, oGetChv:aHeader, oGetChv:aCols )

	// Mostra na grid as Rotas relacionados a negociação selecionada
	For nCount := 1 To Len(aColsDds)
		If cTabela $ aColsDds[nCount,1] .And. cChave $ aColsDds[nCount,6]
			If aScan( aCols , {|x| x[1] == aColsDds[nCount,1] .And. x[6] == cChave } ) == 0
				AAdd(aCols,Array(Len(aHeadDds)+2))
				aCols[Len(aCols),1]  := aColsDds[nCount,1]
				aCols[Len(aCols),2]  := aColsDds[nCount,2]
				aCols[Len(aCols),3]  := aColsDds[nCount,3]
				aCols[Len(aCols),4]  := aColsDds[nCount,4]
				aCols[Len(aCols),5]  := aColsDds[nCount,5]
				aCols[Len(aCols),6]  := cChave
				aCols[Len(aCols),Len(aHeadDds)+2]:=.F.
			EndIf
		EndIf
	Next nCount

	// Atualiza os dados da grid de Rotas
	oGetDds:SetArray(aCols, .T.)
	oGetDds:oBrowse:Refresh()

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DefTab

Definição do Grid das tabelas

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefTab()
	Local aHeadTab := {}

	AddTabHead( @aHeadTab, "Tabela"   , "TABELA", "C", 10, 0, "@!")
	AddTabHead( @aHeadTab, "Descrição", "DSTABE", "C", 50, 0, "@!")

Return aHeadTab

//-------------------------------------------------------------------
/*/{Protheus.doc} DefTabChv

Definição do Grid das chaves

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefTabChv()
	Local aHead    := {}

	AddTabHead( @aHead , "Tabela" , "TABCHA" , "C" , 10  , 0 , "@!" )
	AddTabHead( @aHead , "Chave"  , "CHAVIN" , "C" , 450 , 0 , "@!" )

Return aHead

//-------------------------------------------------------------------
/*/{Protheus.doc} DefTabDds

Definição do Grid dos dados

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefTabDds()
	Local aHead    := {}

	AddTabHead( @aHead , "Campo"     , "CAMPO"  , "C" , 15  , 0 , "@!" )
	AddTabHead( @aHead , "Titulo"    , "TITULO" , "C" , 20  , 0 , "@!" )
	AddTabHead( @aHead , "Descrição" , "DESC"   , "C" , 50  , 0 , "@!" )
	AddTabHead( @aHead , "Tipo"      , "TIPO"   , "C" , 06  , 0 , "@!" )
	AddTabHead( @aHead , "Valor"     , "VALOR"  , "C" , 450 , 0 , "@!" )

Return aHead

//-------------------------------------------------------------------
/*/{Protheus.doc} AddTabHead

Função auxiliar para incluir o Header (Definição) da temp-table

@author Israel A. Possoli
@since 17/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddTabHead(aHead, Titulo, Nome, TipoDado, Tamanho, Decimal, Mascara,cValid)
	Default cValid := ""

	aAdd( aHead, { Titulo  , ;    // 01 - Titulo
	Nome    , ;    // 02 - Campo
	Mascara , ;    // 03 - Picture
	Tamanho , ;    // 04 - Tamanho
	Decimal , ;    // 05 - Decimal
	cValid  , ;    // 06 - Valid
	''      , ;    // 07 - Usado
	TipoDado, ;    // 08 - Tipo
	''      , ;    // 09 - F3
	'R'     , ;    // 10 - Contexto
	''      , ;    // 11 - ComboBox
	''      , ;    // 12 - Relacao
	'.T.'   , ;    // 13 - Alterar
	''      , ;    // 14 - Visual
	''      } )    // 15 - Valid Usuario

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ArquivoDir

Mostra uma tela para procura do arquivo

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function ArquivoDir()
	Local cDirectory := ""
	Local aArquivos  := {}
	Local nArq       := 0
	Local lSelecao
	Local cValAnt    := ""

	Private aParamFile := Array(1)

	// Exibe a estrutura de diretório e permite a seleção dos arquivos que serão processados
	cDirectory := ALLTRIM(cGetFile("","Selecione o diretório do(s) arquivo(s) ...", 0,'', .T., GETF_MULTISELECT + GETF_LOCALHARD + GETF_RETDIRECTORY ,.T.))

	If !Empty(cDirectory)
		aArquivos := Directory(cDirectory+"*.txt")

		If Len(aArquivos) > 0
			aArquivos := MarkFile(aArquivos,cDirectory,@lSelecao)

			For nArq := 1 To Len(aArquivos)
				
				If aArquivos[nArq][1] == .T. //Grava somente os arquvios que foram marcados
					AADD(aValAnt,{Upper(aArquivos[nArq][3] + aArquivos[nArq][2])})
					cValAnt := aValAnt[1][1]
				EndIf
			Next nArq
		EndIf
	Else
		Alert("Nenhum arquivo foi selecionado!!!")
	EndIf

Return cValAnt

//-------------------------------------------------------------------
/*/{Protheus.doc} MARKFILE

Tela principal aonde é informado o diretorio com o arquivo de log

@ Param aArquivos  - Arquivos encontrados
@ Param cDiretorio - Diretorio dos arquivos
@ Param lSelecao   - Se foi selecionado um arquivo

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MARKFILE(aArquivos,cDiretorio,lSelecao)
	Local aChaveArq := {}
	Local cTitulo := "Arquivos para importação: "

	// Variáveis utilizadas na seleção de categorias
	Local oQual
	Local cVarQ
	// Carrega bitmaps
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")
	// Variáveis utilizadas para lista de filiais
	Local nx := 0

	//+--------------------------------------------------------------------+
	//| Carrega os arquivos do diretório no array da ListBox |
	//+--------------------------------------------------------------------+
	For nX := 1 To Len(aArquivos)
		//+--------------------------------------------------------------------+
		//| aChaveArq - Contem os arquivos que serão exibidos para seleção |
		//+--------------------------------------------------------------------+
		AADD(aChaveArq,{.F.,aArquivos[nX][1],cDiretorio})
	Next nX

	//+--------------------------------------------------------------------+
	//| Monta tela para seleção dos arquivos contidos no diretório |
	//+--------------------------------------------------------------------+
	DEFINE MSDIALOG oDlg TITLE cTitulo STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
	oDlg:lEscClose := .T.

	@ 20,20 LISTBOX oQual VAR cVarQ Fields HEADER "","Código","Descrição" SIZE 283,090 ON DBLCLICK (aChaveArq:=Troca(oQual:nAt,aChaveArq),oQual:Refresh()) NoScroll OF oDlg PIXEL
	oQual:SetArray(aChaveArq)
	oQual:bLine := { || {If(aChaveArq[oQual:nAt,1],oOk,oNo),aChaveArq[oQual:nAt,2],aChaveArq[oQual:nAt,3]}}

	DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION IIF(MarcaOk(aChaveArq),(lSelecao := .T., oDlg:End(),.T.),.F.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION (lSelecao := .F., oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

RETURN aChaveArq

//-------------------------------------------------------------------
/*/{Protheus.doc} Troca

@ Param nIt    - Posição no array
@ Param aArray - Array com os dados

Troca o check do registro

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC FUNCTION Troca(nIt,aArray)
	Local nI
	Local nReg := 1

	For nI := 1 to Len(aArray)
		IF aArray[nI,1]
			nReg ++
		Endif
	Next
	aArray[nIt,1] := !aArray[nIt,1]

Return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaOk

@ Param aArray - Array com os dados

Verifica se foi informado pelo menos 1 registro com check

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC FUNCTION MarcaOk(aArray)
	Local lRet:=.F.
	Local nx:=0

	// Checa marcações efetuadas
	For nx:=1 To Len(aArray)
		If aArray[nx,1]
			lRet:=.T.
		EndIf
	Next nx

	// Checa se existe algum item marcado na confirmação
	If !lRet
		HELP("SELFILE",1,"HELP","Erro!","Não existem itens marcados",1,0)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar

@ Param aColsTab - Array com os dados

Função que mostra a tela para ser selecionadas as tabelas para importação

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importar(aColsTab)
	Local aChaveArq := {}
	Local cTitulo := "Tabelas para importação: "
	// Variáveis utilizadas na seleção de categorias
	Local oQual
	Local cVarQ
	// Carrega bitmaps
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")
	// Variáveis utilizadas para lista de filiais
	Local nX      := 0
	Local nPos    := 0
	Local lChk    := .F.
	Local aAux    := {}
	Local aChvTbl := {}
	Local aFilSis := FWLoadSM0()

	Private aCodFil := {}

	//+--------------------------------------------------------------------------+
	//| Verifica e trata uso de documentos com multiplas filiais para importação |
	//+--------------------------------------------------------------------------+
	For nX := 1 to Len(aColsChv)
		aAux    := {}
		aChvTbl := StrTokArr(aColsChv[nX][2], "|")
		For nPos := 1 to Len(aChvTbl)
			aadd(aAux, StrTokArr(aChvTbl[nPos], ":"))
		Next nPos

		nPos := aScan(aAux, {|x| "_FILIAL" $ Alltrim(x[1]) })
		If nPos > 0
			If (!Empty(aAux[nPos][2]) .And. Alltrim(aAux[nPos][2]) != "xx") .And. aScan(aCodFil, {|x| Alltrim(x[1]) == Alltrim(aAux[nPos][2])}) == 0
				aadd(aCodFil, {Alltrim(aAux[nPos][2]), Space(TamSx3("GW1_FILIAL")[1])})
			EndIf
		EndIf
	Next nX

	If Len(aCodFil) > 1 .And. Len(aFilSis) < Len(aCodFil)
		MsgStop("Foi identificado no arquivo uso de multiplas filiais ["+cValToChar(Len(aCodFil))+"], porém o sistema possui ["+cValToChar(Len(aFilSis))+"] filial(s) cadastrada(s). Crie a quantidade de filiais necessária no sistema para ser possivel a importação desse arquivo.")
		Return aChaveArq
	ElseIf Len(aCodFil) > 1 .And. Len(aFilSis) >= Len(aCodFil) .And. MsgYesNo("Foi identificado no arquivo registros em tabela utilizando multiplas filiais. Deseja associar as filiais do arquivo com as filiais do sistema?")
		AssocFiliais()
		If aScan(aCodFil, {|x| Empty(x[2]) }) > 0
			MsgInfo("É necessário associar todas filiais do arquivo com as filiais do sistema. Importação cancelada!!!")
			Return aChaveArq
		EndIf
	ElseIf Len(aCodFil) > 1 .And. Len(aFilSis) >= Len(aCodFil)
		MsgInfo("Importação cancelada!!!")
		Return aChaveArq
	ElseIf Len(aCodFil) == 1 .And. Empty(aCodFil[1][2])
		aCodFil[1][2] := cFilant
	EndIf

	If lClear .And. MsgYesNo("Tem certeza que deseja limpar a base antes da importação? Esta ação irá apagar todas as informações do banco de dados.","Importação de Dados")
		ZeraTab()
	EndIf

	//+--------------------------------------------------------------------+
	//| Carrega os arquivos do diretório no array da ListBox |
	//+--------------------------------------------------------------------+
	For nX := 1 to Len(aColsTab)
		//+--------------------------------------------------------------------+
		//| aChaveArq - Contem os arquivos que serão exibidos para seleção |
		//+--------------------------------------------------------------------+
		AADD(aChaveArq,{.F.,aColsTab[nX][1],Upper(aColsTab[nX][2])})
	Next nX

	//+--------------------------------------------------------------------+
	//| Monta tela para seleção dos arquivos contidos no diretório |
	//+--------------------------------------------------------------------+
	DEFINE MSDIALOG oDlgTab TITLE cTitulo STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
	oDlgTab:lEscClose := .T.

	@ 05, 20 CheckBox oChkMar Var lChk Prompt "Marca Todos"   Message  Size 40, 007 Pixel Of oDlgTab on Click MarcaTodos( lChk, @aChaveArq, oQual )

	@ 20,20 LISTBOX oQual VAR cVarQ Fields HEADER "","Código","Descrição" SIZE 283,090 ON DBLCLICK (aChaveArq:=Troca(oQual:nAt,aChaveArq),oQual:Refresh()) NoScroll OF oDlgTab PIXEL
	oQual:SetArray(aChaveArq)
	oQual:bLine := { || {If(aChaveArq[oQual:nAt,1],oOk,oNo),aChaveArq[oQual:nAt,2],aChaveArq[oQual:nAt,3]}}

	DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION Processa( {|| IIf(GravaImpo( aChaveArq ) == .T. , oDlgTab:End() , Nil ) }, "Aguarde...", "Gravando dados na base local...",.F.) ENABLE OF oDlgTab
	DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION oDlgTab:End() ENABLE OF oDlgTab

	ACTIVATE MSDIALOG oDlgTab CENTERED

RETURN aChaveArq

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaImpo

@ Param aChaveArq - Array com os dados

Grava as tabelas selecionadas

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaImpo(aChaveArq)
	Local nI
	Local lVazio := .F.
	Local nCont  := 0
	Local lRet   := .T.
	Private lImp := .F.

	For nI := 1 to Len(aChaveArq)
		If aChaveArq[nI][1]
			nCont ++
		Endif
	Next nI

	ProcRegua( nCont )

	For nI := 1 to Len(aChaveArq)
		If aChaveArq[nI][1]
			Do Case
			Case "GW1" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs( aChaveArq[nI][2] )
			Case "GWM" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUE" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUF" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWA" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUS" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV5" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWL" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWD" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU6" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU4" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU5" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW4" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW3" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GVT" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU3" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW6" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWJ" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWB" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWH" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWF" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW8" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUB" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUR" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUT" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUQ" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWU" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWN" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUU" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU8" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW2" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW5" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWI" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWG" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV9" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV2" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUY" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUZ" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV4" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV7" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV3" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GVA" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GVB" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV6" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV1" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GV8" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU7" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GU9" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUL" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUC" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GUA" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GW7" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GWK" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GVR" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GXE" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GX0" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GXD" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			Case "GXF" $ aChaveArq[nI][2]
				IncProc()
				GravaTabs(aChaveArq[nI][2])
			EndCase
			lVazio := .T.
		Endif
	Next nI

	If !lVazio
		Alert("Nenhuma tabela foi selecionada!!!")
		lRet := .F.
	Else
		If lImp
			MsgInfo("A Importação do(s) arquivo(s) foi realizada com sucesso!!!")
			MSGALERT("Esta Rotina será finalizada após a importação", "Estamos em Manutenção" )
			Final()
		Else
			Alert( "Nenhuma tabela foi importada!!! " + CRLF + "Registros duplicados foram encontrados na base local")
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaTabs

@ Param cTabela - Nome da tabela

Grava as tabelas selecionadas

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaTabs( cTabela )
	Local nX
	Local aAux := Nil
	Private cCodTab := cTabela

	Do Case
	Case cTabela $ "GW1"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilDc  := RetConteudo(aAux, "GW1_FILIAL")
				cCdTpDc := RetConteudo(aAux, "GW1_CDTPDC")
				cEmiss  := RetConteudo(aAux, "GW1_EMISDC")
				cSerDc  := RetConteudo(aAux, "GW1_SERDC")
				cNrDoc  := RetConteudo(aAux, "GW1_NRDC")

				//Seta a tabela
				dbSelectArea( "GW1" )
				//Seta o indice utilizado
				GW1->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW1->( dbSeek( PadR(cFilDc , TamSx3("GW1_Filial")[1]) + PadR(cCdTpDc, TamSx3("GW1_CDTPDC")[1]) + PadR(cEmiss, TamSx3("GW1_EMISDC")[1]) + PadR(cSerDc, TamSx3("GW1_SERDC")[1]) + PadR(cNrDoc, TamSx3("GW1_NRDC")[1]) ) )
					RecLock( "GW1" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW1" , aColsChv[nX][2] )

					MsUnLock( "GW1" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWM"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilRat := RetConteudo(aAux, "GWM_FILIAL")
				cTpDoc  := RetConteudo(aAux, "GWM_TPDOC")
				cCdEsp  := RetConteudo(aAux, "GWM_CDESP")
				cCdtrp  := RetConteudo(aAux, "GWM_CDTRP")
				cSerDoc := RetConteudo(aAux, "GWM_SERDOC")
				cNrDoc  := RetConteudo(aAux, "GWM_NRDOC")
				dDtEmis := RetConteudo(aAux, "GWM_DTEMIS")
				cCdTpDc := RetConteudo(aAux, "GWM_CDTPDC")
				cEmisDc := RetConteudo(aAux, "GWM_EMISDC")
				cSerDc  := RetConteudo(aAux, "GWM_SERDC")
				cNrDc   := RetConteudo(aAux, "GWM_NRDC")
				cSeqGW8 := RetConteudo(aAux, "GWM_SEQGW8")
				cGrpCtb := RetConteudo(aAux, "GWM_GRPCTB")


				//Seta a tabela
				dbSelectArea("GWM")
				//Seta o indice utilizado
				GWM->( dbSetOrder(1) )
				//Posiciona no registro de acordo com os parametros
				If !GWM->( dbSeek( cFilRat + cTpDoc + cCdEsp + cCdtrp + cSerDoc + cNrDoc + dDtEmis + cCdTpDc + cEmisDc + cSerDc + cNrDc + cSeqGW8 ) )
					RecLock( "GWM" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWM" , aColsChv[nX][2] )

					MsUnLock( "GWM" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUE"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilCtb := RetConteudo(aAux, "GUE_FILIAL")
				cCtaCtb := RetConteudo(aAux, "GUE_CTACTB")

				//Seta a tabela
				dbSelectArea( "GUE" )
				//Seta o indice utilizado
				GUE->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUE->( dbSeek( cFilCtb + cCtaCtb ) )
					RecLock( "GUE" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUE" , aColsChv[nX][2] )

					MsUnLock( "GUE" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUF"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilCtb := RetConteudo(aAux, "GUF_FILIAL")
				cCtaCtb := RetConteudo(aAux, "GUF_GRP1")

				//Seta a tabela
				dbSelectArea( "GUF" )
				//Seta o indice utilizado
				GUF->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUF->( dbSeek( cFilCtb + cCtaCtb ) )
					RecLock( "GUF" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUF" , aColsChv[nX][2] )

					MsUnLock( "GUF" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWA"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilMov := RetConteudo(aAux, "GWA_FILIAL")
				cTpDoc  := RetConteudo(aAux, "GWA_TPDOC")
				cCdEsp  := RetConteudo(aAux, "GWA_CDESP")
				cCdEmit := RetConteudo(aAux, "GWA_CDEMIT")
				cSerie  := RetConteudo(aAux, "GWA_SERIE")
				cNrDoc  := RetConteudo(aAux, "GWA_NRDOC")
				dDtEmis := RetConteudo(aAux, "GWA_DTEMIS")
				cCdTran := RetConteudo(aAux, "GWA_CDTRAN")
				cSeq    := RetConteudo(aAux, "GWA_SEQ")

				//Seta a tabela
				dbSelectArea( "GWA" )
				//Seta o indice utilizado
				GWA->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWA->( dbSeek( cFilMov + cTpDoc + cCdEsp + cCdEmit + cSerie + cNrDoc + dDtEmis + cCdTran + cSeq ) )
					RecLock( "GWA" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWA" , aColsChv[nX][2] )

					MsUnLock( "GWA" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUS"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				cFil    := xFilial( cTabela )
				cFilCtb := xFilial( "GUE" )

				//Seta a tabela
				dbSelectArea( "GUS" )
				//Seta o indice utilizado
				GUS->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUS->( dbSeek( cFil + cFilCtb ) )
					RecLock( "GUS" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUS" , aColsChv[nX][2] )

					MsUnLock( "GUS" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV5"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV5_FILIAL")
				cCdTpDc := RetConteudo(aAux, "GV5_CDTPDC")

				//Seta a tabela
				dbSelectArea( "GV5" )
				//Seta o indice utilizado
				GV5->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV5->( dbSeek( cFil + cCdTpDc ) )
					RecLock( "GV5" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV5" , aColsChv[nX][2] )

					MsUnLock( "GV5" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWL"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWL_FILIAL")
				cNrOco  := RetConteudo(aAux, "GWL_NROCO")
				cFilDc  := cFil
				cEmitDc := RetConteudo(aAux, "GWL_EMITDC")
				cSerDc  := RetConteudo(aAux, "GWL_SERDC")
				cNrDc   := RetConteudo(aAux, "GWL_NRDC")

				//Seta a tabela
				dbSelectArea( "GWL" )
				//Seta o indice utilizado
				GWL->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWL->( dbSeek( cFil + cNrOco + cFilDc + cEmitDc + cSerDc + cNrDc ) )
					RecLock( "GWL" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWL" , aColsChv[nX][2] )

					MsUnLock( "GWL" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWD"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWD_FILIAL")
				cNrOco  := RetConteudo(aAux, "GWD_NROCO")

				//Seta a tabela
				dbSelectArea( "GWD" )
				//Seta o indice utilizado
				GWD->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWD->( dbSeek( cFil + cNrOco ) )
					RecLock( "GWD" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWD" , aColsChv[nX][2] )

					MsUnLock( "GWD" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU6"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU6_FILIAL")
				cCdMot  := RetConteudo(aAux, "GU6_CDMOT")

				//Seta a tabela
				dbSelectArea( "GU6" )
				//Seta o indice utilizado
				GU6->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU6->( dbSeek( cFil + cCdMot ) )
					RecLock( "GU6" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU6" , aColsChv[nX][2] )

					MsUnLock( "GU6" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU4"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU4_FILIAL")
				cCdMot  := RetConteudo(aAux, "GU4_CDMOT")
				cCdTipo := RetConteudo(aAux, "GU4_CDTIPO")

				//Seta a tabela
				dbSelectArea( "GU4" )
				//Seta o indice utilizado
				GU4->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU4->( dbSeek( cFil + cCdMot + cCdTipo ) )
					RecLock( "GU4" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU4" , aColsChv[nX][2] )

					MsUnLock( "GU4" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU5"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU5_FILIAL")
				cCdTipo := RetConteudo(aAux, "GU5_CDTIPO")

				//Seta a tabela
				dbSelectArea( "GU5" )
				//Seta o indice utilizado
				GU5->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU5->( dbSeek( cFil + cCdTipo ) )
					RecLock( "GU5" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU5" , aColsChv[nX][2] )

					MsUnLock( "GU5" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW4"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW4_FILIAL")
				cEmisDf := RetConteudo(aAux, "GW4_EMISDF")
				cCdEsp  := RetConteudo(aAux, "GW4_CDESP")
				cSerDf  := RetConteudo(aAux, "GW4_SERDF")
				cNrDf   := RetConteudo(aAux, "GW4_NRDF")
				cDtEmis := RetConteudo(aAux, "GW4_DTEMIS")
				cEmisDc := RetConteudo(aAux, "GW4_EMISDC")
				cSerDc  := RetConteudo(aAux, "GW4_SERDC")
				cNrDc   := RetConteudo(aAux, "GW4_NRDC")
				cTpDc   := RetConteudo(aAux, "GW4_TPDC")

				//Seta a tabela
				dbSelectArea( "GW4" )
				//Seta o indice utilizado
				GW4->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW4->( dbSeek( cFil + cEmisDf + cCdEsp + cSerDf + cNrDf + cDtEmis + cEmisDc + cSerDc + cNrDc + cTpDc ) )
					RecLock( "GW4" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW4" , aColsChv[nX][2] )

					MsUnLock( "GW4" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW3"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW3_FILIAL")
				cCdEsp  := RetConteudo(aAux, "GW3_CDESP")
				cEmisDf := RetConteudo(aAux, "GW3_EMISDF")
				cSerDf  := RetConteudo(aAux, "GW3_SERDF")
				cNrDf   := RetConteudo(aAux, "GW3_NRDF")
				dDtEmis := RetConteudo(aAux, "GW3_DTEMIS")

				//Seta a tabela
				dbSelectArea( "GW3" )
				//Seta o indice utilizado
				GW3->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW3->( dbSeek( cFil + cCdEsp + cEmisDf + cSerDf + cNrDf + dDtEmis ) )
					RecLock( "GW3" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW3" , aColsChv[nX][2] )

					MsUnLock( "GW3" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GVT"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil   := RetConteudo(aAux, "GVT_FILIAL")
				cCdEsp := RetConteudo(aAux, "GVT_CDESP")

				//Seta a tabela
				dbSelectArea( "GVT" )
				//Seta o indice utilizado
				GVT->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GVT->( dbSeek( cFil + cCdEsp ) )
					RecLock( "GVT" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GVT" , aColsChv[nX][2] )

					MsUnLock( "GVT" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU3"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU3_FILIAL")
				cCdEmit := RetConteudo(aAux, "GU3_CDEMIT")

				//Seta a tabela
				dbSelectArea( "GU3" )
				//Seta o indice utilizado
				GU3->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU3->( dbSeek( cFil + cCdEmit ) )
					RecLock( "GU3" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU3" , aColsChv[nX][2] )

					MsUnLock( "GU3" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW6"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW6_FILIAL")
				cEmiFat := RetConteudo(aAux, "GW6_EMIFAT")
				cSerFat := RetConteudo(aAux, "GW6_SERFAT")
				cNrFat  := RetConteudo(aAux, "GW6_NRFAT")

				//Seta a tabela
				dbSelectArea( "GW6" )
				//Seta o indice utilizado
				GW6->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW6->( dbSeek( cFil + cEmiFat + cSerFat + cNrFat ) )
					RecLock( "GW6" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW6" , aColsChv[nX][2] )

					MsUnLock( "GW6" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWJ"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil  := RetConteudo(aAux, "GWJ_FILIAL")
				cNrPf := RetConteudo(aAux, "GWJ_NRPF")

				//Seta a tabela
				dbSelectArea( "GWJ" )
				//Seta o indice utilizado
				GWJ->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWJ->( dbSeek( cFil + cNrPf ) ) .And. aScan(aColsDds, {|x| "GWJ_NRPF" $ Alltrim(x[1]) }) > 0
					RecLock( "GWJ" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWJ" , aColsChv[nX][2] )

					MsUnLock( "GWJ" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWB"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil   := RetConteudo(aAux, "GWB_FILIAL")
				cNrDoc := RetConteudo(aAux, "GWB_NRDC")

				//Seta a tabela
				dbSelectArea( "GWB" )
				//Seta o indice utilizado
				GWB->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWB->( dbSeek( cFil + cNrDoc ) )
					RecLock( "GWB" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWB" , aColsChv[nX][2] )

					MsUnLock( "GWB" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWH"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWH_FILIAL")
				cNrCalc := RetConteudo(aAux, "GWH_NRCALC")
				cCdTpDc := RetConteudo(aAux, "GWH_CDTPDC")
				cEmisDc := RetConteudo(aAux, "GWH_EMISDC")
				cSerDc  := RetConteudo(aAux, "GWH_SERDC")
				cNrDc   := RetConteudo(aAux, "GWH_NRDC")

				//Seta a tabela
				dbSelectArea( "GWH" )
				//Seta o indice utilizado
				GWH->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWH->( dbSeek( cFil + cNrCalc + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
					RecLock( "GWH" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWH" , aColsChv[nX][2] )

					MsUnLock( "GWH" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWF"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWF_FILIAL")
				cNrCalc := RetConteudo(aAux, "GWF_NRCALC")

				//Seta a tabela
				dbSelectArea( "GWF" )
				//Seta o indice utilizado
				GWF->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWF->( dbSeek( cFil + cNrCalc ) )
					RecLock( "GWF" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWF" , aColsChv[nX][2] )

					MsUnLock( "GWF" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW8"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW8_FILIAL")
				cCdTpDc := RetConteudo(aAux, "GW8_CDTPDC")
				cEmisDc := RetConteudo(aAux, "GW8_EMISDC")
				cSerDc  := RetConteudo(aAux, "GW8_SERDC")
				cNrDc   := RetConteudo(aAux, "GW8_NRDC")
				cItem   := RetConteudo(aAux, "GW8_ITEM")

				//Seta a tabela
				dbSelectArea( "GW8" )
				//Seta o indice utilizado
				GW8->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW8->( dbSeek( cFil + cCdTpDc + cEmisDc + cSerDc + cNrDc + cItem ) )
					RecLock( "GW8" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW8" , aColsChv[nX][2] )

					MsUnLock( "GW8" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUB"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUB_FILIAL")
				cCdClFr := RetConteudo(aAux, "GUB_CDCLFR")

				//Seta a tabela
				dbSelectArea( "GUB" )
				//Seta o indice utilizado
				GUB->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUB->( dbSeek( cFil + cCdClFr ) )
					RecLock( "GUB" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUB" , aColsChv[nX][2] )

					MsUnLock( "GUB" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUR"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUR_FILIAL")
				cNrCalc := RetConteudo(aAux, "GUR_UF")

				//Seta a tabela
				dbSelectArea( "GUR" )
				//Seta o indice utilizado
				GUR->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUR->( dbSeek( cFil + cNrCalc ) )
					RecLock( "GUR" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUR" , aColsChv[nX][2] )

					MsUnLock( "GUR" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUT"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUT_FILIAL")
				cNrCalc := RetConteudo(aAux, "GUT_UF")

				//Seta a tabela
				dbSelectArea( "GUT" )
				//Seta o indice utilizado
				GUT->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUT->( dbSeek( cFil + cNrCalc ) )
					RecLock( "GUT" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUT" , aColsChv[nX][2] )

					MsUnLock( "GUT" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUQ"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUQ_FILIAL")
				cNrCalc := RetConteudo(aAux, "GUQ_TPITEM")

				//Seta a tabela
				dbSelectArea( "GUQ" )
				//Seta o indice utilizado
				GUQ->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUQ->( dbSeek( cFil + cNrCalc ) )
					RecLock( "GUQ" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUQ" , aColsChv[nX][2] )

					MsUnLock( "GUQ" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWU"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWU_FILIAL")
				cCdTpDc := RetConteudo(aAux, "GWU_CDTPDC")
				cEmisDc := RetConteudo(aAux, "GWU_EMISDC")
				cSerDc  := RetConteudo(aAux, "GWU_SERDC")
				cNrDc   := RetConteudo(aAux, "GWU_NRDC")
				cSeq    := RetConteudo(aAux, "GWU_SEQ")

				//Seta a tabela
				dbSelectArea( "GWU" )
				//Seta o indice utilizado
				GWU->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWU->( dbSeek( cFil + cCdTpDc + cEmisDc + cSerDc + cNrDc + cSeq ) )
					RecLock( "GWU" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWU" , aColsChv[nX][2] )

					MsUnLock( "GWU" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWN"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil   := RetConteudo(aAux, "GWN_FILIAL")
				cNrRom := RetConteudo(aAux, "GWN_NRROM")

				//Seta a tabela
				dbSelectArea( "GWN" )
				//Seta o indice utilizado
				GWN->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWN->( dbSeek( cFil + cNrRom ) )
					RecLock( "GWN" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWN" , aColsChv[nX][2] )

					MsUnLock( "GWN" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUU"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil   := RetConteudo(aAux, "GUU_FILIAL")
				cCdMtr := RetConteudo(aAux, "GUU_CDMTR")

				//Seta a tabela
				dbSelectArea( "GUU" )
				//Seta o indice utilizado
				GUU->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUU->( dbSeek( cFil + cCdMtr ) )
					RecLock( "GUU" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUU" , aColsChv[nX][2] )

					MsUnLock( "GUU" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU8"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU8_FILIAL")
				cNrCalc := RetConteudo(aAux, "GU8_CDVEIC")

				//Seta a tabela
				dbSelectArea( "GU8" )
				//Seta o indice utilizado
				GU8->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU8->( dbSeek( cFil + cNrCalc ) )
					RecLock( "GU8" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU8" , aColsChv[nX][2] )

					MsUnLock( "GU8" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW2"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW2_FILIAL")
				cNrCont := RetConteudo(aAux, "GW2_NRCONT")

				//Seta a tabela
				dbSelectArea( "GW2" )
				//Seta o indice utilizado
				GW2->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW2->( dbSeek( cFil + cNrCont ) )
					RecLock( "GW2" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW2" , aColsChv[nX][2] )

					MsUnLock( "GW2" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GW5"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GW5_FILIAL")
				cNrCont := RetConteudo(aAux, "GW5_NRCONT")
				cCdVlAd := RetConteudo(aAux, "GW5_CDVLAD")

				//Seta a tabela
				dbSelectArea( "GW5" )
				//Seta o indice utilizado
				GW5->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GW5->( dbSeek( cFil + cNrCont + cCdVlAd ) )
					RecLock( "GW5" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW5" , aColsChv[nX][2] )

					MsUnLock( "GW5" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWI"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWI_FILIAL")
				cNrCalc := RetConteudo(aAux, "GWI_NRCALC")
				cCdClFr := RetConteudo(aAux, "GWI_CDCLFR")
				cCdTpOp := RetConteudo(aAux, "GWI_CDTPOP")
				cCdComp := RetConteudo(aAux, "GWI_CDCOMP")

				//Seta a tabela
				dbSelectArea( "GWI" )
				//Seta o indice utilizado
				GWI->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWI->( dbSeek( cFil + cNrCalc + cCdClFr + cCdTpOp + cCdComp ) )
					RecLock( "GWI" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWI" , aColsChv[nX][2] )

					MsUnLock( "GWI" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWG"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GWG_FILIAL")
				cNrCalc := RetConteudo(aAux, "GWG_NRCALC")
				cCdClFr := RetConteudo(aAux, "GWG_CDCLFR")
				cCdTpOp := RetConteudo(aAux, "GWG_CDTPOP")

				//Seta a tabela
				dbSelectArea( "GWG" )
				//Seta o indice utilizado
				GWG->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GWG->( dbSeek( cFil + cNrCalc + cCdClFr + cCdTpOp ) )
					RecLock( "GWG" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWG" , aColsChv[nX][2] )

					MsUnLock( "GWG" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV9"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV9_FILIAL")
				cCdEmit := RetConteudo(aAux, "GV9_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GV9_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GV9_NRNEG")

				//Seta a tabela
				dbSelectArea( "GV9" )
				//Seta o indice utilizado
				GV9->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV9->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg ) )
					RecLock( "GV9" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV9" , aColsChv[nX][2] )

					MsUnLock( "GV9" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV2"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV2_FILIAL")
				cCdComp := RetConteudo(aAux, "GV2_CDCOMP")

				//Seta a tabela
				dbSelectArea( "GV2" )
				//Seta o indice utilizado
				GV2->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV2->( dbSeek( cFil + cCdComp ) )
					RecLock( "GV2" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV2" , aColsChv[nX][2] )

					MsUnLock( "GV2" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUY"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUY_FILIAL")
				cCdEmit := RetConteudo(aAux, "GUY_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GUY_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GUY_NRNEG")
				cCdComp := RetConteudo(aAux, "GUY_CDCOMP")

				//Seta a tabela
				dbSelectArea( "GUY" )
				//Seta o indice utilizado
				GUY->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUY->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cCdComp ) )
					RecLock( "GUY" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUY" , aColsChv[nX][2] )

					MsUnLock( "GUY" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUZ"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUZ_FILIAL")
				cCdEmit := RetConteudo(aAux, "GUZ_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GUZ_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GUZ_NRNEG")
				cSeqFai := RetConteudo(aAux, "GUZ_SEQFAI")

				//Seta a tabela
				dbSelectArea( "GUZ" )
				//Seta o indice utilizado
				GUZ->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUZ->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cSeqFai ) )
					RecLock( "GUZ" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUZ" , aColsChv[nX][2] )

					MsUnLock( "GUZ" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV4"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV4_FILIAL")
				cCdTpOp := RetConteudo(aAux, "GV4_CDTPOP")

				//Seta a tabela
				dbSelectArea( "GV4" )
				//Seta o indice utilizado
				GV4->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV4->( dbSeek( cFil + cCdTpOp ) )
					RecLock( "GV4" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV4" , aColsChv[nX][2] )

					MsUnLock( "GV4" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV7"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV7_FILIAL")
				cCdEmit := RetConteudo(aAux, "GV7_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GV7_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GV7_NRNEG")
				cCdFxTv := RetConteudo(aAux, "GV7_CDFXTV")

				//Seta a tabela
				dbSelectArea( "GV7" )
				//Seta o indice utilizado
				GV7->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV7->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cCdFxTv ) )
					RecLock( "GV7" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV7" , aColsChv[nX][2] )

					MsUnLock( "GV7" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV3"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV3_FILIAL")
				cCdTpVc := RetConteudo(aAux, "GV3_CDTPVC")

				//Seta a tabela
				dbSelectArea( "GV3" )
				//Seta o indice utilizado
				GV3->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV3->( dbSeek( cFil + cCdTpVc ) )
					RecLock( "GV3" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV3" , aColsChv[nX][2] )

					MsUnLock( "GV3" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GVA"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GVA_FILIAL")
				cCdEmit := RetConteudo(aAux, "GVA_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GVA_NRTAB")

				//Seta a tabela
				dbSelectArea( "GVA" )
				//Seta o indice utilizado
				GVA->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GVA->( dbSeek( cFil + cCdEmit + cNrTab ) )
					RecLock( "GVA" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GVA" , aColsChv[nX][2] )

					MsUnLock( "GVA" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GVB"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GVB_FILIAL")
				cCdEmit := RetConteudo(aAux, "GVB_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GVB_NRTAB")
				cCdComp := RetConteudo(aAux, "GVB_CDCOMP")

				//Seta a tabela
				dbSelectArea( "GVB" )
				//Seta o indice utilizado
				GVB->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GVB->( dbSeek( cFil + cCdEmit + cNrTab + cCdComp ) )
					RecLock( "GVB" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GVB" , aColsChv[nX][2] )

					MsUnLock( "GVB" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV6"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV6_FILIAL")
				cCdEmit := RetConteudo(aAux, "GV6_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GV6_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GV6_NRNEG")
				cCdFxTv := RetConteudo(aAux, "GV6_CDFXTV")
				cNrRota := RetConteudo(aAux, "GV6_NRROTA")

				//Seta a tabela
				dbSelectArea( "GV6" )
				//Seta o indice utilizado
				GV6->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV6->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cCdFxTv + cNrRota ) )
					RecLock( "GV6" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV6" , aColsChv[nX][2] )

					MsUnLock( "GV6" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV1"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV1_FILIAL")
				cCdEmit := RetConteudo(aAux, "GV1_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GV1_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GV1_NRNEG")
				cCdFxTv := RetConteudo(aAux, "GV1_CDFXTV")
				cNrRota := RetConteudo(aAux, "GV1_NRROTA")
				cCdComp := RetConteudo(aAux, "GV1_CDCOMP")

				//Seta a tabela
				dbSelectArea( "GV1" )
				//Seta o indice utilizado
				GV1->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV1->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cCdFxTv + cNrRota + cCdComp ) )
					RecLock( "GV1" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV1" , aColsChv[nX][2] )

					MsUnLock( "GV1" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GV8"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GV8_FILIAL")
				cCdEmit := RetConteudo(aAux, "GV8_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GV8_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GV8_NRNEG")
				cNrRota := RetConteudo(aAux, "GV8_NRROTA")

				//Seta a tabela
				dbSelectArea( "GV8" )
				//Seta o indice utilizado
				GV8->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GV8->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cNrRota ) )
					RecLock( "GV8" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GV8" , aColsChv[nX][2] )

					MsUnLock( "GV8" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU7"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU7_FILIAL")
				cCdCida := RetConteudo(aAux, "GU7_NRCID")

				//Seta a tabela
				dbSelectArea( "GU7" )
				//Seta o indice utilizado
				GU7->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU7->( dbSeek( cFil + cCdCida ) )
					RecLock( "GU7" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU7" , aColsChv[nX][2] )

					MsUnLock( "GU7" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GU9"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GU9_FILIAL")
				cCdCida := RetConteudo(aAux, "GU9_NRREG")

				//Seta a tabela
				dbSelectArea( "GU9" )
				//Seta o indice utilizado
				GU9->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GU9->( dbSeek( cFil + cCdCida ) )
					RecLock( "GU9" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GU9" , aColsChv[nX][2] )

					MsUnLock( "GU9" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUL"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUL_FILIAL")
				cNrReg  := RetConteudo(aAux, "GUL_NRREG")
				cNrCep  := RetConteudo(aAux, "GUL_CEPINI")

				//Seta a tabela
				dbSelectArea( "GUL" )
				//Seta o indice utilizado
				GUL->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUL->( dbSeek( cFil + cNrReg + cNrCep ) )
					RecLock( "GUL" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUL" , aColsChv[nX][2] )

					MsUnLock( "GUL" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUC"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUC_FILIAL")
				cCdEmit := RetConteudo(aAux, "GUC_CDEMIT")
				cNrTab  := RetConteudo(aAux, "GUC_NRTAB")
				cNrNeg  := RetConteudo(aAux, "GUC_NRNEG")
				cCdFxTv := RetConteudo(aAux, "GUC_CDFXTV")
				cNrRota := RetConteudo(aAux, "GUC_NRROTA")
				cCdComp := RetConteudo(aAux, "GUC_CDCOMP")
				cEmiCom := RetConteudo(aAux, "GUC_EMICOM")

				//Seta a tabela
				dbSelectArea( "GUC" )
				//Seta o indice utilizado
				GUC->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUC->( dbSeek( cFil + cCdEmit + cNrTab + cNrNeg + cCdFxTv + cNrRota + cCdComp + cEmiCom ) )
					RecLock( "GUC" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUC" , aColsChv[nX][2] )

					MsUnLock( "GUC" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GUA"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil    := RetConteudo(aAux, "GUA_FILIAL")
				cNrReg  := RetConteudo(aAux, "GUA_NRREG")
				cNrCid  := RetConteudo(aAux, "GUA_NRCID")

				//Seta a tabela
				dbSelectArea( "GUA" )
				//Seta o indice utilizado
				GUA->( dbSetOrder(1) )
				//Posiciona no registro que foi digitado na tela
				If !GUA->( dbSeek( cFil + cNrReg + cNrCid ) )
					RecLock( "GUA" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GUA" , aColsChv[nX][2] )

					MsUnLock( "GUA" )
				EndIf
			EndIf
		Next nX
	Case cTabela $ "GW7"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilRat  := RetConteudo(aAux, "GW7_FILIAL")
				cEmiFat  := RetConteudo(aAux, "GW7_EMIFAT")
				cSerFat  := RetConteudo(aAux, "GW7_SERFAT")
				cNrFat   := RetConteudo(aAux, "GW7_NRFAT")
				dDtEmiss := RetConteudo(aAux, "GW7_DTEMIS")
				cSeq     := RetConteudo(aAux, "GW7_SEQ")

				//Seta a tabela
				dbSelectArea("GW7")
				//Seta o indice utilizado
				GW7->( dbSetOrder(1) )
				//Posiciona no registro de acordo com os parametros
				If !GW7->( dbSeek( cFilRat + cEmiFat + cSerFat + cNrFat + dDtEmiss + cSeq ) )
					RecLock( "GW7" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GW7" , aColsChv[nX][2] )

					MsUnLock( "GW7" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GWK"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFilRatPF := RetConteudo(aAux, "GWK_FILIAL")
				cNrPF     := RetConteudo(aAux, "GWK_NRPF")
				cSeq      := RetConteudo(aAux, "GWK_SEQ")

				//Seta a tabela
				dbSelectArea("GWK")
				//Seta o indice utilizado
				GWK->( dbSetOrder(1) )
				//Posiciona no registro de acordo com os parametros
				If !GWK->( dbSeek( cFilRatPF + cNrPF + cSeq  ) )
					RecLock( "GWK" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GWK" , aColsChv[nX][2] )

					MsUnLock( "GWK" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GVR"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil	:= RetConteudo(aAux, "GVR_FILIAL")
				cNrReg  := RetConteudo(aAux, "GVR_NRREG")

				GVR->(dbSelectArea("GVR"))
				GVR->(dbSetOrder(1))
				If !GVR->(dbSeek(cFil + cNrReg))
					RecLock( "GVR" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GVR" , aColsChv[nX][2] )

					MsUnLock( "GVR" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GXE"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil	:= RetConteudo(aAux, "GXE_FILIAL")
				cCodLot := RetConteudo(aAux, "GXE_CODLOT")

				GXE->(dbSelectArea("GXE"))
				GXE->(dbSetOrder(1))
				If !GXE->(dbSeek(cFil + cCodLot))
					RecLock( "GXE" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GXE" , aColsChv[nX][2] )

					MsUnLock( "GXE" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GX0"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil	:= RetConteudo(aAux, "GX0_FILIAL")
				cTpDc   := RetConteudo(aAux, "GX0_CDTPDC")
				cEmisDc := RetConteudo(aAux, "GX0_EMISDC")
				cSerDc  := RetConteudo(aAux, "GX0_SERDC")
				cNrDc   := RetConteudo(aAux, "GX0_NRDC")
				cDtEmis := RetConteudo(aAux, "GX0_DTEMIS")
				cSeq    := RetConteudo(aAux, "GX0_SEQ")
				cTpFret := RetConteudo(aAux, "GX0_TPFRET")

				GX0->(dbSetOrder(1))
				If !GX0->(dbSeek(cFil + cTpDc + cEmisDc + cSerDc + cNrDc + cDtEmis + cSeq + cTpFret))
					RecLock( "GX0" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GX0" , aColsChv[nX][2] )

					MsUnLock( "GX0" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GXD"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil	:= RetConteudo(aAux, "GXD_FILIAL")
				cCodLot := RetConteudo(aAux, "GXD_CODLOT")
				cFilCal := RetConteudo(aAux, "GXD_FILCAL")
				cNrCalc := RetConteudo(aAux, "GXD_NRCALC")

				GXD->(dbSetOrder(1))
				If !GXD->(dbSeek(cFil + cCodLot + cFilCal + cNrCalc))
					RecLock( "GXD" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GXD" , aColsChv[nX][2] )

					MsUnLock( "GXD" )
				Endif
			Endif
		Next nX
	Case cTabela $ "GXF"
		For nX := 1 to Len( aColsChv )
			If aColsChv[nX][1] $ cTabela
				aAux := StrTokArr(aColsChv[nX][2], "|")

				cFil	:= RetConteudo(aAux, "GXF_FILIAL")
				cCodLot := RetConteudo(aAux, "GXF_CODLOT")
				cSeq    := RetConteudo(aAux, "GXF_SEQ")
				cData   := RetConteudo(aAux, "GXF_DATA")
				cConta  := RetConteudo(aAux, "GXF_CONTA")

				GXF->(dbSetOrder(1))
				If !GXF->(dbSeek(cFil + cCodLot + cSeq))
					RecLock( "GXF" , .T. )
					lImp := .T.

					//Função para criar todos os dados na tabela
					GravaDados( "GXF" , aColsChv[nX][2] )

					MsUnLock( "GXF" )
				Endif
			Endif
		Next nX
	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos

@ Param lMarca - Diz se marca ou desmarca o registro
@ Param aVetor - Tabelas da tela
@ Param oLbx   - Bronwe para regresf

Seleciona todos os registros

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI

	oLbx:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDados

@ Param cAlias - Nome da tabela que esta sendo criada
@ Param cChave - Chave para não serem gravados registros em tabelas erradas

@author  Jorge Matos Valcanaia
@since   03/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaDados( cAlias , cChave )
	Local nY
	Local nPos := 0

	For nY := 1 to Len(aColsDds)
		If aColsDds[nY][6] == cChave
			Do Case
			Case aColsDds[nY][4] == "C"
				If "_FIL" $ aColsDds[nY][1]
					nPos := aScan(aCodFil, {|x| Alltrim(x[1]) == Alltrim(aColsDds[nY][5]) })
					If nPos > 0
						(cAlias)->&( aColsDds[nY][1] ) := aCodFil[nPos][2]
					Else
						(cAlias)->&( aColsDds[nY][1] ) := xFilial( cAlias )
					EndIf
				Else
					(cAlias)->&( aColsDds[nY][1] ) := Alltrim( aColsDds[nY][5] )
				Endif
			Case aColsDds[nY][4] == "N"
				(cAlias)->&( aColsDds[nY][1] ) := Val( Alltrim( aColsDds[nY][5] ) )
			Case aColsDds[nY][4] == "D"
				xAux := Alltrim( aColsDds[nY][5] )

				(cAlias)->&( aColsDds[nY][1] ) := Stod( xAux )
			EndCase
		Endif
	Next nY

Return

Static Function ZeraTab()

	Local nCont
	Local lErro    := .F.
	Local aTabelas := { "GU1", "GU2", "GU3", "GU4", "GU5", "GU6", "GU7", "GU8", "GU9",;
		"GUA", "GUB", "GUC", "GUD", "GUE", "GUF", "GUG", "GUH", "GUI",;
		"GUJ", "GUK", "GUL", "GUM", "GUP", "GUQ", "GUR", "GUS", "GUT",;
		"GUU", "GUV", "GUW", "GUX", "GUY", "GUZ", "GV0", "GV1", "GV2",;
		"GV3", "GV4", "GV5", "GV6", "GV7", "GV8", "GV9", "GVA", "GVB",;
		"GVC", "GVD", "GVE", "GVF", "GVG", "GVH", "GVI", "GVJ", "GVK",;
		"GVL", "GVM", "GVN", "GVO", "GVP", "GVT", "GW0", "GW1", "GW2",;
		"GW3", "GW4", "GW5", "GW6", "GW7", "GW8", "GW9", "GWA", "GWB",;
		"GWD", "GWF", "GWG", "GWH", "GWI", "GWJ", "GWK", "GWL", "GWM",;
		"GWN", "GWO", "GWU", "GWV", "GWW", "GWX", "GWY", "GWZ", "GX1",;
		"GX2", "GX3", "GX4", "GX5", "GX6", "GX7", "GX8", "GXA", "GXB",;
		"GXE", "GXF", "GXG", "GXH", "GXI", "GXJ", "GXL", "GVR", "GXE",;
		"GXD","GXF"}

	If GFXTB1212210("GX0") == .T.
		AAdd(aTabelas,"GX0")
	EndIf

	For nCont := 1 to len(aTabelas)
		cQuery := "DELETE FROM " + RetSqlName(aTabelas[nCont])
		If TCSQLExec(cQuery) < 0
			MsgStop("A exclusão dos registros da tabela " +  RetSqlName(aTabelas[nCont]) + " não pode ser efetuada por um erro desconhecido. Exclua os registros manualmente." )
			lErro := .T.
		EndIf
	Next nCont

	If !lErro
		MsgInfo("Todos os registros foram excluidos.")
	EndIf

Return

Static Function RetConteudo(aCont, cCpo)
	Local cRet := ""
	Local cAux := ""
	Local nPos := aScan(aCont, {|x| cCpo $ Alltrim(x) })
	Local aRet := Nil

	If nPos > 0
		aRet := StrTokArr(aCont[nPos], ":")
		If Len(aRet) > 1
			cAux := PadR(LTrim(aRet[2]), TamSx3(cCpo)[1])
			If "_FILIAL" $ cCpo
				nPos := aScan(aCodFil, {|x| Alltrim(x[1]) == Alltrim(cAux) })
				If nPos > 0
					cRet := aCodFil[nPos][2]
				Else
					cRet := xFilial(cCodTab)
				EndIf
			Else
				cRet := cAux
			EndIf
		Else
			cRet := PadR(" ", TamSx3(cCpo)[1])
		EndIf
	Else
		cRet := PadR(" ", TamSx3(cCpo)[1])
	EndIf
Return cRet

Static Function AssocFiliais()
	Local oDlg
	Local oFwLayer
	Local oPanGrid
	Local oSayModulo
	Local oSayTitulo
	Local oFontMod  := TFont():New("Tahoma", , -38)
	Local oFontSub  := TFont():New("Tahoma", , -20)
	Local oFontBtn  := TFont():New("Tahoma", , -14)

	Private oBrw01

	oDlg := MSDialog():New( 000,000,520,830,'Importação dados GFE',,,.F.,,,,,,.T.,,,.T. )
	oDlg:lMaximized := .F.

	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlg,.F.)

	//Adicionando 3 linhas, a de título, a superior e a do calendário
	oFWLayer:addLine("TIT", 10, .F.)
	oFWLayer:addLine("COR", 90, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("HEADERTEXT",   085, .T., "TIT")
	oFWLayer:addCollumn("BTNSAIR",      015, .T., "TIT")
	oFWLayer:addCollumn("COLGRID",      100, .T., "COR")

	//Criando os paineis
	oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TIT")
	oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TIT")
	oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "COR")

	//Títulos e SubTítulos
	oSayModulo := TSay():New(001, 003, {|| 'GFE'}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F.)
	oSayTitulo := TSay():New(007, 045, {|| 'Associação de Filiais'}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F.)

	//Criando os botões
	oBtnSair := TButton():New(004, 001, "Fechar", oPanSair, {|| oDlg:End()}, 50, 018, , oFontBtn, , .T.)

	//Cria a grid
	oBrw01 := TCBrowse():New( 040 , 015, 380, 140,,,,oPanGrid,,,,, ,,,,,,,.F.,,.T.,,.F.,,, )
	oBrw01:SetArray( aCodFil )
	oBrw01:bLDblClick := {|| setEditCell(oBrw01, aCodFil) }
	oBrw01:Align      := CONTROL_ALIGN_ALLCLIENT
	oBrw01:AddColumn( TCColumn():New('Arquivo', {|| aCodFil[oBrw01:nAt,01]}, "@!",,,"LEFT",060,.F.,.F.,,,,.F.,) )
	oBrw01:AddColumn( TCColumn():New('Sistema', {|| aCodFil[oBrw01:nAt,02]}, "@!",,,"LEFT",060,.F.,.F.,,,,.F.,) )

	oDlg:Activate(,,,.T.)
Return

Static Function setEditCell( oBrw01, aCodFil )
	If oBrw01:nColPos == 02
		lEditCelluDesenv( aCodFil, oBrw01, "@!" , oBrw01:nColPos, "SM0" )
	Endif
Return

Static Function lEditCelluDesenv(aCampos,oBrowse,cPict,nCol,cF3)
	Local oDlg      := Nil as object
	Local oRect     := tRect():New(0,0,0,0) as object
	Local oGet1     := Nil as object
	Local oBtn      := Nil as object
	Local oOwner    := oBrowse:oWnd as object
	Local nRow      := oBrowse:nAt as object
	Local cMacro    := "M->CELL"+StrZero(nRow,6) as character
	Local lCargo    := .F. as logical
	Local nLastKey  := 0 as numeric
	Local aDim      := {} as array

	Default cPict      := ''
	Default nCol       := oBrowse:nColPos

	oBrowse:GetCellRect(nCol,,oRect)   // a janela de edicao deve ficar
	aDim := {oRect:nTop, oRect:nLeft, oRect:nBottom, oRect:nRight}
	oDlg := MSDialog():New(0,0,0,0,'Janela sem borda',,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,.T.)
	oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	&cMacro := aCampos[nRow,nCol]

	oGet1 := TGet():New(0, 0, bSetGet(&(cMacro)), oDlg, 0, 0, cPict, , , , oOwner:oFont, , , .T.)
	oGet1:bValid    := {|| lCargo := Eval({|| .T.})}
	oGet1:cF3       := cF3
	oGet1:lReadOnly := .F.

	oGet1:Move(-2,-2, (aDim[4] - aDim[2]) - 12, aDim[3] - aDim[1] + 4)
	oBtn := TButton():New( 0, 0, 'ud', oDlg, , 0, 0, , , .F., .T., .F., , .F., , , .F.)
	oBtn:bGotFocus := {|| nLastKey := oDlg:nLastKey := VK_RETURN, oDlg:End(0)}
	oGet1:cReadVar := cMacro
	oDlg:bInit     := {|| oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])}
	oDlg:Activate()

	If lCargo
		aCampos[nRow,nCol] := &cMacro
		oBrowse:aArray[nRow,nCol] := &cMacro
		oBrowse:nAt := nRow
		SetFocus(oBrowse:hWnd)
		oBrowse:Refresh()
	EndIf
Return( nLastKey <> 0 )
