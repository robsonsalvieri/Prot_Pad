#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM944.CH"
#Include "FILEIO.ch"

Static aStrVerb
Static aStrRAFil
Static aStrRAMat
Static aStrBco
Static aStrDBco
Static aStrNRCon
Static aStrCPF
Static aStrMatEso
Static aStrNomeFu
Static aStrVlrPa
Static aStrDocum
Static cDocTDN
Static cQuebra
Static lTemRUO
Static cDataBase
Static lNewSX1

/*/{Protheus.doc} GPEM944
Tela de Importação do arquivo de empréstimos do Programa Crédito do Trabalhador.
@since	16/04/2025
@autor	martins.marcio
@version P12
/*/
Function GPEM944()
	Local aArea			:= GetArea()
	Local aAdvSize		:= {}
	Local aColsMark		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords	:= {}
	Local aObjSize		:= {}
	Local bImport		:= {|| GPM944Proc(@cArqImp, .F.) }
	Local bFiltRejei	:= {|| fFiltStat("3"),	oMark:Refresh(.T.)}
	Local bFiltAlert	:= {|| fFiltStat("2"),	oMark:Refresh(.T.)}
	Local bFiltSuces	:= {|| fFiltStat("1"),	oMark:Refresh(.T.)}
	Local bFiltNaImp	:= {|| fFiltStat("0"),	oMark:Refresh(.T.)}
	Local bLimpaFilt	:= {|| fFiltStat(), 	oMark:Refresh(.T.)}
	Local bPergunte		:= {|| Pergunte(cPerg,.T.)}
	Local cFilAux		:= cFilAnt
	Local aCombo		:= { "1-Sim", "2-Não" }
	Local cArqImp		:= Space( 100 )
	Local cIdCab		:= ""
	Local cIdGrid		:= ""
	Local oFont
	Local oGroup
	Local oPanelDown
	Local oPanelUp
	Local oTela
	Local oButton1
	Local oButton2
	Local oButton3
	Local oCombo2

	DEFAULT cDocTDN		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=939231539"
	DEFAULT aStrVerb	:= FWSX3Util():GetFieldStruct( "RV_COD" )
	DEFAULT aStrRAFil	:= FWSX3Util():GetFieldStruct( "RA_FILIAL" )
	DEFAULT aStrRAMat	:= FWSX3Util():GetFieldStruct( "RA_MAT" )
	DEFAULT aStrBco		:= FWSX3Util():GetFieldStruct( "A6_COD" )
	DEFAULT aStrDBco	:= FWSX3Util():GetFieldStruct( "A6_NOME" )
	DEFAULT aStrNRCon	:= FWSX3Util():GetFieldStruct( "RK_NRCONTR" )
	DEFAULT aStrCPF		:= FWSX3Util():GetFieldStruct( "RA_CIC" )
	DEFAULT aStrMatEso	:= FWSX3Util():GetFieldStruct( "RA_CODUNIC" )
	DEFAULT aStrNomeFu	:= FWSX3Util():GetFieldStruct( "RA_NOME" )
	DEFAULT aStrVlrPa	:= FWSX3Util():GetFieldStruct( "RK_VALORPA" )
	DEFAULT aStrDocum	:= FWSX3Util():GetFieldStruct( "RK_DOCUMEN" )
	DEFAULT cQuebra		:= Chr(13) + Chr(10)
	DEFAULT cDataBase	:= TcGetDB()
	DEFAULT lNewSX1		:= FWSX1Util():ExistPergunte("GPM944A")

	Private cAtualiza	:= ("1-"+OemToAnsi(STR0071))	// "1-Sim"
	Private aColumns	:= {}
	Private cX1Compet	:= Space( 6 )
	Private cPerg		:= IIf(lNewSX1, "GPM944A", "GPM944")
	Private cTipoImp	:= "" //J-Json, C-CSV
	Private cAliasMark	:= "TABAUX"
	Private oMark		:= Nil
	Private oDlgMark	:= Nil
	Private oTmpTable	:= Nil

	If FWSX1Util():ExistPergunte(cPerg)
		If !Pergunte(cPerg, .T.) // "Parâmetros"
			Return Nil
		EndIf
	Else
		cMsgErro	:= OemToAnsi(STR0002) //"O sistema não possui a atualização que cria o Grupo de Perguntas GPM944."
		msg944Doc(OemToAnsi(STR0003), cMsgErro, cDocTDN, "SX1", .F.) //"Grupo de Perguntas não encontrado."
		Return Nil
	EndIf

	// Cria a estrutura da tabela temporária que será utilizada no FWMarkBrowse.
	fCriaTab()

	aColsMark := fHeadrGrid()

	aAdvSize	:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	Define MsDialog oDlgMark FROM aAdvSize[7], 0 To aAdvSize[6], aAdvSize[5] Title OemToAnsi(STR0001) Pixel  //"Crédito do Trabalhador"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgMark )
	cIdCab	  := oTela:CreateHorizontalBox( 22 )
	cIdGrid   := oTela:CreateHorizontalBox( 78 )

	oTela:Activate( oDlgMark, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdCab )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

	DEFINE FONT oFont NAME "Arial" SIZE 0,-15
	@ 3 , 3	GROUP oGroup TO (aObjSize[1,1]*0.5)+45, aObjSize[1,4] LABEL OemToAnsi(STR0004) OF oPanelUp PIXEL	// "Configuração"
	oGroup:oFont:=oFont
	oPanelUp:SetFont( oFont )

		@ (aObjSize[1,1]*0.4)+4, aObjSize[1,2]+1 	SAY   OemToAnsi(STR0006) SIZE 135,010 OF oPanelUp PIXEL // "Atualiza empréstimos já importados anteriormente?"
		@ (aObjSize[1,1]*0.4)+2, aObjSize[1,2]+140	MSCOMBOBOX oCombo2 VAR cAtualiza ITEMS aCombo SIZE 035,011 OF oPanelUp PIXEL

	@ (aObjSize[1,1]*0.4)+17, aObjSize[1,2]+1 	BUTTON oButton1 PROMPT OemToAnsi(STR0007) SIZE 100, 012 OF oPanelUp PIXEL ACTION ( fSelecArq(@cArqImp))// "Selecionar Arquivo"
	@ (aObjSize[1,1]*0.4)+17, aObjSize[1,2]+103 	MSGET cArqImp  PICTURE "@!" SIZE 170,007 OF oPanelUp PIXEL

	@ (aObjSize[1,1]*0.4)+33, aObjSize[1,2]+1 	BUTTON oButton2 PROMPT OemToAnsi(STR0008) SIZE 100, 012 OF oPanelUp PIXEL ACTION ( GPM944Proc(@cArqImp, .T.))// "Importar"
	@ (aObjSize[1,1]*0.4)+33, aObjSize[1,2]+103	BUTTON oButton3 PROMPT OemToAnsi(STR0076) SIZE 100, 012 OF oPanelUp PIXEL ACTION ( oDlgMark:End() )// "Fechar"

	oMark := FWMarkBrowse():New()

	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)

	// Indica o container onde sera criado o browse
	oMark:SetOwner(oPanelDown)

	// Define o campo que sera utilizado para a marcação
	oMark:SetValid({||.T.})
	oMark:AddButton(OemToAnsi(STR0075), bImport,,,, .F., 2 )	// 	"Gravar"
	oMark:AddButton(OemToAnsi(STR0009), bPergunte,,,, .F., 2 ) //	"Parâmetros"
	If !(cDataBase == "ORACLE")
		oMark:AddButton(OemToAnsi(STR0010), bFiltRejei,,,, .F., 2 ) //	"Ver somente rejeitados"
		oMark:AddButton(OemToAnsi(STR0011),	bFiltAlert,,,, .F., 2 ) //	"Ver somente registros com alerta."
		oMark:AddButton(OemToAnsi(STR0012),	bFiltSuces,,,, .F., 2 ) //	"Ver somente registros com sucesso."
		oMark:AddButton(OemToAnsi(STR0013), bFiltNaImp,,,, .F., 2 ) //	"Ver somente não processados."
		oMark:AddButton(OemToAnsi(STR0014),	bLimpaFilt,,,, .F., 2 ) //	"Limpa filtros"
	EndIf
	oMark:SetMenuDef("GPEM944")

	oMark:AddLegend( "LEFT(TAB_STATUS,1) == '0'",	"BLUE"	, OemToAnsi(STR0015) )	// "Não Processado"
	oMark:AddLegend( "LEFT(TAB_STATUS,1) == '1'",	"GREEN"	, OemToAnsi(STR0016) )	// "Sucesso"
	oMark:AddLegend( "LEFT(TAB_STATUS,1) == '2'", 	"YELLOW", OemToAnsi(STR0017) )	// "Alerta informativo"
	oMark:AddLegend( "LEFT(TAB_STATUS,1) == '3'", 	"RED" 	, OemToAnsi(STR0018) )	// "Rejeitado"

	oMark:Activate()

	ACTIVATE MSDIALOG oDlgMark CENTERED

	oTmpTable:Delete()
	oTmpTable := Nil

	// Retorna a filial para a que estava logada antes da execução da rotina
	cFilAnt := cFilAux
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Menu Funcional - declarado apenas para validações internas.
@since	16/04/2025
@autor	martins.marcio
@version P12
/*/
Static Function MenuDef()
Return {}

/*/{Protheus.doc} fCriaTab
Cria tabela temporaria para uso no FWMarkBrowse.
@author martins.marcio
@since 16/04/2025
@version 1.0
/*/
Static Function fCriaTab()
	Local lRet			:= .T.

	aAdd( aColumns, { "TAB_FILIAL"		,"C", aStrRAFil[3], 00})
	aAdd( aColumns, { "TAB_FUNCIO"		,"C", aStrRAMat[3], 00})
	aAdd( aColumns, { "TAB_CPF"			,"C", aStrCPF[3], 00})
	aAdd( aColumns, { "TAB_OBS"			,"C", 120, 00})
	aAdd( aColumns, { "TAB_BANCO"		,"C", aStrBco[3], 00})
	aAdd( aColumns, { "TAB_DBANCO"		,"C", 20, 00})
	aAdd( aColumns, { "TAB_NCONTR"		,"C", aStrNRCon[3], 00})
	aAdd( aColumns, { "TAB_COMPET"		,"C", 07, 00})
	aAdd( aColumns, { "TAB_MATESO"		,"C", aStrMatEso[3],00 })
	aAdd( aColumns, { "TAB_NFUNCI"		,"C", aStrNomeFu[3], 00})
	aAdd( aColumns, { "TAB_VALORP"		,"N", aStrVlrPa[3], aStrVlrPa[4]})
	aAdd( aColumns, { "TAB_STATUS"		,"C", 22, 00}) //"0-Não Processado"; "1-Sucesso"; "2-Alerta informativo"; "3-Rejeitado"

	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "IND", { "TAB_FILIAL", "TAB_FUNCIO","TAB_COMPET","TAB_CPF", "TAB_MATESO"} )
	oTmpTable:Create()

	DbSelectArea(cAliasMark)
	SET FILTER TO

Return lRet

/*/{Protheus.doc} fHeadrGrid
Monta dados dos campos da tabela temporaria.
@since	16/04/2025
@autor	martins.marcio
@version P12
/*/
Static Function fHeadrGrid()
	Local aArea		:= GetArea()
	Local aColsAux 	:= {}
	Local aColsSX3	:= {}
	Local aStruct	:= {}
	Local aDados	:= {{||(cAliasMark)->TAB_FILIAL},{||(cAliasMark)->TAB_FUNCIO},{||(cAliasMark)->TAB_CPF},{||(cAliasMark)->TAB_OBS},{||(cAliasMark)->TAB_BANCO},{||(cAliasMark)->TAB_DBANCO},{||(cAliasMark)->TAB_NCONTR}, {||(cAliasMark)->TAB_COMPET},{||(cAliasMark)->TAB_MATESO},{||(cAliasMark)->TAB_NFUNCI},{||(cAliasMark)->TAB_VALORP},{||(cAliasMark)->TAB_STATUS}}
	Local nX		:= 0
	Local cTitulo	:= ""
	Local cMascara	:= ""
	Local cConteudo	:= ""

	DbSelectArea("SX3")
	DbSetOrder(2)

	For nX := 1 to Len(aColumns)
		cMascara := ""
		aStruct := FWSX3Util():GetFieldStruct( aColumns[nX][1] )
		Do Case
			Case aColumns[nX][1] == "TAB_FILIAL"
				cTitulo := OemToAnsi(STR0019)	// "Filial"
			Case aColumns[nX][1] == "TAB_FUNCIO"
				cTitulo := OemToAnsi(STR0020)	// "Funcionário"
			Case aColumns[nX][1] == "TAB_BANCO"
				cTitulo := OemToAnsi(STR0021)	// "Banco"
			Case aColumns[nX][1] == "TAB_DBANCO"
				cTitulo := OemToAnsi(STR0022)	// "Nome do Banco"
			Case aColumns[nX][1] == "TAB_NCONTR"
				cTitulo := OemToAnsi(STR0023)	// "Número do Contrato"
			Case aColumns[nX][1] == "TAB_COMPET"
				cTitulo := OemToAnsi(STR0024) 	// "Competência"
				cMascara := "@R 99/9999"
			Case aColumns[nX][1] == "TAB_CPF"
				cTitulo := OemToAnsi(STR0025) 	// "CPF"
				cMascara := aStrCPF[5]
			Case aColumns[nX][1] == "TAB_MATESO"
				cTitulo := OemToAnsi(STR0026)	// "Matrícula do Esocial"
			Case aColumns[nX][1] == "TAB_NFUNCI"
				cTitulo := OemToAnsi(STR0027)	// "Nome do Funcionário"
			Case aColumns[nX][1] == "TAB_VALORP"
				cTitulo := OemToAnsi(STR0030) // "Valor da Parcela"
				cMascara := aStrVlrPa[5]
			Case aColumns[nX][1] == "TAB_STATUS"
				cTitulo := OemToAnsi(STR0028)	// "Status"
			Case aColumns[nX][1] == "TAB_OBS"
				cTitulo := OemToAnsi(STR0029)	// "Observação"

		End Case

		cConteudo := aDados[nX]
		aColsSX3 := {cTitulo, cConteudo, aColumns[nX][2] /*Tipo*/, cMascara /*Picture*/,1,aColumns[nX][3] /*Tamanho*/, aColumns[nX][4]/*Decimal*/,.F.,,,,,,,,1}
		aAdd(aColsAux,aColsSX3)
		aColsSX3 := {}
	Next nX

	RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} GPM944Proc
Controla todo o processo de importação.
@author martins.marcio
@since 16/04/2025
@version 1.0
/*/
Function GPM944Proc(cArqImp, lSimula)
	Local cMsgErro	:= ""
	Local lRet		:= .T.
	Local lAtualiza	:= IIf(LEFT(cAtualiza,1) == "1", .T., .F.)
	Local cMsgNoYes	:= ""
	Local nQtdArq	:= 0

	DEFAULT cArqImp		:= ""
	DEFAULT lSimula		:= .T.
	DEFAULT cDocTDN		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=939231539"
	DEFAULT aStrVerb	:= FWSX3Util():GetFieldStruct( "RV_COD" )
	DEFAULT aStrRAFil	:= FWSX3Util():GetFieldStruct( "RA_FILIAL" )
	DEFAULT aStrRAMat	:= FWSX3Util():GetFieldStruct( "RA_MAT" )
	DEFAULT aStrBco		:= FWSX3Util():GetFieldStruct( "A6_COD" )
	DEFAULT aStrDBco	:= FWSX3Util():GetFieldStruct( "A6_NOME" )
	DEFAULT aStrNRCon	:= FWSX3Util():GetFieldStruct( "RK_NRCONTR" )
	DEFAULT aStrCPF		:= FWSX3Util():GetFieldStruct( "RA_CIC" )
	DEFAULT aStrMatEso	:= FWSX3Util():GetFieldStruct( "RA_CODUNIC" )
	DEFAULT aStrNomeFu	:= FWSX3Util():GetFieldStruct( "RA_NOME" )
	DEFAULT aStrVlrPa	:= FWSX3Util():GetFieldStruct( "RK_VALORPA" )
	DEFAULT aStrDocum	:= FWSX3Util():GetFieldStruct( "RK_DOCUMEN" )
	DEFAULT cQuebra		:= Chr(13) + Chr(10)
	DEFAULT lTemRUO		:= ChkFile("RUO") //Verifica se a tabela existe

	Private oJson		:= Nil
	Private	aQtdReg	:= { 0, 0, 0, 0 } // { "0-Não Processado", "1-Sucesso", "2-Alerta informativo", "3-Rejeitado" }
	Private cJsnVers := ""

	If lRet .And. Empty(cArqImp)
		cMsgErro	:= OemToAnsi(STR0031) //"Nenhum arquivo foi selecionado."
		lRet		:= .F.
	EndIf

	If lRet .And. !lSimula .And. !IsBlind()
		cMsgNoYes := OemToAnsi(STR0032) + cQuebra + cQuebra //"Deseja confirmar a importação do arquivo de empréstimos?"
		cMsgNoYes += OemToAnsi(STR0033) //"Após confirmar NÃO SERÁ POSSÍVEL DESFAZER."
		If !MsgNoYes(cMsgNoYes, OemToAnsi(STR0034)) //"Atenção"
			cMsgErro	:= OemToAnsi(STR0035) //"Importação cancelada pelo usuário."
			lRet		:= .F.
		EndIf
	EndIf

	If lRet .And. !(lTemRUO) .And. !IsBlind()
		cMsgNoYes := OemToAnsi(STR0036) + cQuebra + cQuebra //"O histórico não poderá ser registrado porque a tabela de Histórico de Importação de Empréstimos(RUO) ainda não existe."
		cMsgNoYes += OemToAnsi(STR0037) + cQuebra + cQuebra //"A expedição contínua em breve contará com a atualização do dicionário, que criará a tabela."
		cMsgNoYes += OemToAnsi(STR0038) + cQuebra //"A data prevista para a liberação da atualização e outros detalhes estão disponíveis na documentação do TDN:"
		cMsgNoYes += cDocTDN + cQuebra + cQuebra
		cMsgNoYes += OemToAnsi(STR0039) //"Deseja continuar e gravar apenas na tabela de Valores Futuros(SRK)?"
		If !MsgNoYes(cMsgNoYes, OemToAnsi(STR0034)) //"Atenção"
			cMsgErro	:= OemToAnsi(STR0035) //"Importação cancelada pelo usuário."
			lRet		:= .F.
		EndIf
	EndIf

	If lRet
		MakeAdvplExpr(cPerg) //Transforma parametros Range em expressao (intervalo)
		cX1Compet	:= IIf(lNewSX1, AllTrim(MV_PAR02), AllTrim(MV_PAR03))

		lRet := f944LerArq(@oJson, @cMsgErro, @cArqImp)
		If lRet
			lRet := f944IniGrv(@oJson, @cMsgErro, lSimula, lAtualiza, ,MV_PAR01)
		EndIf
	EndIf

	If !lRet .And. !Empty(cMsgErro)
		Help( ,, OemToAnsi(STR0034),, OemToAnsi(cMsgErro), 1, 0) //"Atenção"
	Else
		If !lSimula .And. !IsBlind()
			nQtdArq	:= Len(oJson)
			cMsgNoYes := OemToAnsi(STR0064) + cQuebra + cQuebra //"Importação concluída com sucesso! "
			cMsgNoYes += OemToAnsi(STR0065) + "[" + cValToChar(nQtdArq) +"]" + cQuebra //"Total de empréstimos no arquivo: [" ## "]"
			cMsgNoYes += "[" + cValToChar(aQtdReg[2]) + "] "+ OemToAnsi(STR0066) + cQuebra //["##"] empréstimos foram gravados.
			If aQtdReg[3] > 0
				cMsgNoYes +=OemToAnsi(STR0068)+"[" + cValToChar(aQtdReg[3]) + "] "+ OemToAnsi(STR0067) + cQuebra //"Destes, [" ## "] foram gravados com alertas informativos."
			EndIf
			If aQtdReg[4] > 0
				cMsgNoYes += "[" + cValToChar(aQtdReg[4]) + "] "+ OemToAnsi(STR0069) + cQuebra + cQuebra //"[##] não puderam ser importados."
			EndIf
			cMsgNoYes += OemToAnsi(STR0070) //"Os detalhes podem ser verificados abaixo na coluna de observações."
			APMSGINFO(cMsgNoYes)
		EndIf
	EndIf

Return Nil


/*/{Protheus.doc} f944LerArq
Realiza a leitura do arquivo de empréstimos e converte para JSON.
@author martins.marcio
@since 15/04/2025
@version 1.0
/*/
Static Function f944LerArq(oJson, cMsgErro, cArqImp)
	Local lRet := .T.
	Local xConteudo	:= ""

	cTipoImp	:= ""
	oJson		:= Nil
	cArqImp		:= Lower(AllTrim(cArqImp))
	If !Empty(cArqImp)
		If File(cArqImp)
			//Obtém a extensão do arquivo que está sendo importado
			cTipoImp := SubStr(cArqImp, RAt(".", cArqImp) + 1)
			If !(cTipoImp $ "json|csv|xls|xlsx")
				cMsgErro	:= OemToAnsi(STR0043) //"Formato do arquivo inválido."
				lRet		:= .F.
			ElseIf cTipoImp == "xls" .or. cTipoImp == "xlsx"
				cMsgErro	:= OemToAnsi(STR0041) //"O programa atualmente não suporta a importação nesse formato. "
				lRet		:= .F.
			EndIf

			If lRet
				// Lê o conteúdo do arquivo
				lRet := fGetText(cArqImp, @xConteudo)
			EndIf

			If lRet
				Do Case
					Case cTipoImp == "json"
						oJson	:= JsonObject():New()
						If !(oJson:FromJSON(DecodeUTF8(xConteudo)) == Nil .And. Len(oJson) > 0)
							cMsgErro	:= OemToAnsi(STR0040) //"Estrutura do arquivo JSON inválida."
							lRet		:= .F.
						EndIf
					Case cTipoImp == "csv"
						oJson := fCSVToJson(cArqImp)
				End Case
			EndIf
		Else
			cMsgErro	:= OemToAnsi(STR0044) //"Arquivo não encontrado."
			lRet		:= .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} fCSVToJson
Converte o arquivo CSV lido para JSON.
@author martins.marcio
@since 16/04/2025
@version 1.0
/*/
Static Function fCSVToJson(cFileCsv)

	Local aCposCsv	:= {}
	Local cLinha	:= ""
	Local aJsnList	:= {}
	Local nHandle	:= 0
	Local oSubGrupo := Nil
	Private aHeaderCSV := {}

	oJson    := JsonObject():New()
	nHandle  := FT_FUse(cFileCsv)
	If (nHandle <> -1)
		FT_FGoTop()
		cLinha := FT_FREADLN() // Lê a primeira linha do arquivo onde estão os cabeçalhos
		aHeaderCSV := StrTokArr2(cLinha,";",.T.)
		FT_FSKIP()
		While !FT_FEOF()
			cLinha		:= FT_FREADLN()
			aCposCsv	:= StrTokArr2(cLinha,";",.T.) // Divide os campos do CSV por vírgula

			// Cria um JsonObject para cada linha do CSV
			oJsonItem	:= JsonObject():New()
			oSubGrupo	:= JsonObject():New()
			oSubGrupo['codigo']                    := Val(AllTrim(getInfoCsv( "ifConcessora.codigo", aCposCsv)))
			oSubGrupo['descricao']                 := getInfoCsv( "ifConcessora.descricao", aCposCsv)
			oJsonItem['ifConcessora']              := oSubGrupo
			oJsonItem['contrato']                  := getInfoCsv( "contrato", aCposCsv)
			oJsonItem['cpf']                       := AllTrim(getInfoCsv( "cpf", aCposCsv))
			oJsonItem['matricula']                 := getInfoCsv( "matricula", aCposCsv)
			oSubGrupo                              := JsonObject():New()
			oSubGrupo['codigo']                    := Val(getInfoCsv( "inscricaoEmpregador.codigo", aCposCsv))
			oJsonItem['inscricaoEmpregador']       := oSubGrupo
			oJsonItem['numeroInscricaoEmpregador'] := AllTrim(getInfoCsv( "numeroInscricaoEmpregador", aCposCsv))
			oJsonItem['nomeTrabalhador']           := getInfoCsv( "nomeTrabalhador", aCposCsv)
			oJsonItem['dataInicioContrato']        := getInfoCsv( "dataInicioContrato", aCposCsv)
			oJsonItem['dataFimContrato']           := getInfoCsv( "dataFimContrato", aCposCsv)
			oJsonItem['competenciaInicioDesconto'] := getInfoCsv( "competenciaInicioDesconto", aCposCsv)
			oJsonItem['competenciaFimDesconto']    := getInfoCsv( "competenciaFimDesconto", aCposCsv)
			oJsonItem['totalParcelas']             := Val(getInfoCsv( "totalParcelas", aCposCsv))
			oJsonItem['valorParcela']              := Val(getInfoCsv( "valorParcela", aCposCsv))
			oJsonItem['valorEmprestimo']           := Val(getInfoCsv( "valorEmprestimo", aCposCsv))
			oJsonItem['valorLiberado']             := Val(getInfoCsv( "valorLiberado", aCposCsv))
			If !Empty(getInfoCsv( "qtdPagamentos", aCposCsv))
				oJsonItem['qtdPagamentos'] := Val(getInfoCsv( "qtdPagamentos", aCposCsv))
			EndIf
			If !Empty(getInfoCsv( "qtdEscrituracoes", aCposCsv))
				oJsonItem['qtdEscrituracoes'] := Val(getInfoCsv( "qtdEscrituracoes", aCposCsv))
			EndIf
			oSubGrupo                         := JsonObject():New()
			oSubGrupo['codigo']               := Val(getInfoCsv( "categoriaTrabalhador.codigo", aCposCsv))
			oJsonItem['categoriaTrabalhador'] := oSubGrupo
			oJsonItem['competencia']          := getInfoCsv( "competencia", aCposCsv)
			oSubGrupo                         := JsonObject():New()
			If !Empty(getInfoCsv( "inscricaoEstabelecimento.codigo", aCposCsv))
				oSubGrupo['codigo'] := Val(getInfoCsv( "inscricaoEstabelecimento.codigo", aCposCsv))
			EndIf
			oJsonItem['inscricaoEstabelecimento'] := oSubGrupo

			If !Empty(getInfoCsv( "numeroInscricaoEstabelecimento", aCposCsv))
				oJsonItem['numeroInscricaoEstabelecimento'] := AllTrim(getInfoCsv( "numeroInscricaoEstabelecimento", aCposCsv))
			EndIf

			aAdd(aJsnList, oJsonItem)
			FT_FSKIP()
		EndDo
		FT_FUSE() // Fecha o Arquivo
		oJson:Set( aJsnList ) //Insere o array na raiz do documento.
	Endif

Return oJson

/*/{Protheus.doc} f944IniGrv
Faz as validações preliminares e Prepara o Json para gravação e exibição do resultado.
@author  martins.marcio
@since	16/04/2025
@version P12
/*/
Function f944IniGrv(oJson, cMsgErro, lSimula, lAtualiza, oResponse, cFiltFil)

	Local nI         := 0
	Local lRet       := .T.
	Local lContinua  := .T.
	Local aChvSRA    := {}
	Local cObserv    := ""
	Local cCompeten  := ""
	Local lFolAbert  := .F.
	Local cMatEsoc   := ""
	Local cCpfTrab   := ""
	Local cCatEsoc   := ""
	Local cCnpjEstab := ""
	Local aRespItems := {}
	Local oRespItem  := Nil

	DEFAULT cDocTDN		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=939231539"
	DEFAULT aStrVerb	:= FWSX3Util():GetFieldStruct( "RV_COD" )
	DEFAULT aStrRAFil	:= FWSX3Util():GetFieldStruct( "RA_FILIAL" )
	DEFAULT aStrRAMat	:= FWSX3Util():GetFieldStruct( "RA_MAT" )
	DEFAULT aStrBco		:= FWSX3Util():GetFieldStruct( "A6_COD" )
	DEFAULT aStrDBco	:= FWSX3Util():GetFieldStruct( "A6_NOME" )
	DEFAULT aStrNRCon	:= FWSX3Util():GetFieldStruct( "RK_NRCONTR" )
	DEFAULT aStrCPF		:= FWSX3Util():GetFieldStruct( "RA_CIC" )
	DEFAULT aStrMatEso	:= FWSX3Util():GetFieldStruct( "RA_CODUNIC" )
	DEFAULT aStrNomeFu	:= FWSX3Util():GetFieldStruct( "RA_NOME" )
	DEFAULT aStrVlrPa	:= FWSX3Util():GetFieldStruct( "RK_VALORPA" )
	DEFAULT aStrDocum	:= FWSX3Util():GetFieldStruct( "RK_DOCUMEN" )
	DEFAULT cQuebra		:= Chr(13) + Chr(10)
	DEFAULT lTemRUO		:= ChkFile("RUO")
	DEFAULT lNewSX1		:= FWSX1Util():ExistPergunte("GPM944A")

	Default oJson     := Nil
	Default cMsgErro  := ""
	Default lSimula   := .F.
	Default lAtualiza := .T.
	Default oResponse := Nil
	DEFAULT cFiltFil  := ""

	Private aPdEConsig	:= {}
	Private lAPIREST := IsInCallStack("GRAVACREDITOTRABALHADOR")

	If !(lAPIREST)
		oTmpTable:Zap() //Limpa todos os registros da tabela temporária.
		DbSelectArea(cAliasMark)
	EndIf

	oResponse := JsonObject():New()
	oResponse["items"] := {}

	If oJson <> Nil .And. Len(oJson) > 0
		For nI := 1 to Len(oJson)
			aChvSRA := {}
			cObserv := ""
			lContinua := .T.
			oRespItem := JsonObject():New()
			oRespItem['_index']		:= oJson[nI]['_index']
			oRespItem['_status']	:= IIf(lAPIREST, "0", ("0-" + OemToAnsi(STR0015))) //Inicia o status como 0-Não Processado
			If Empty(cJsnVers)
				cJsnVers := IIf(oJson[nI]:HasProperty('ifConcessora'), "1.4", "1.0")
			EndIf
			//Tratamento para campos que o tipo pode ser numérico ou string. Converte tudo para string no tamanho correto.
			If cJsnVers >= "1.4"
				oJson[nI]['ifConcessora']['codigo'] := IIf(ValType(oJson[nI]['ifConcessora']['codigo']) == "N", STRZERO(oJson[nI]['ifConcessora']['codigo'], aStrBco[3]), PADL(AllTrim(oJson[nI]['ifConcessora']['codigo']), aStrBco[3], "0"))
			Else
				oJson[nI]['ifConcessora.codigo'] := IIf(ValType(oJson[nI]['ifConcessora.codigo']) == "N", STRZERO(oJson[nI]['ifConcessora.codigo'], aStrBco[3]), PADL(AllTrim(oJson[nI]['ifConcessora.codigo']), aStrBco[3], "0"))
			EndIf
			oJson[nI]['cpf'] := IIf(ValType(oJson[nI]['cpf']) == "N", STRZERO(oJson[nI]['cpf'], 11), PADL(AllTrim(oJson[nI]['cpf']), 11, "0"))
			oJson[nI]['numeroInscricaoEmpregador'] := IIf(ValType(oJson[nI]['numeroInscricaoEmpregador']) == "N", STRZERO(oJson[nI]['numeroInscricaoEmpregador'], 14), PADL(AllTrim(oJson[nI]['numeroInscricaoEmpregador']), 14, "0"))
			oJson[nI]['numeroInscricaoEstabelecimento']	:= IIf(ValType(oJson[nI]['numeroInscricaoEstabelecimento']) == "N", STRZERO(oJson[nI]['numeroInscricaoEstabelecimento'], 14), PADL(AllTrim(oJson[nI]['numeroInscricaoEstabelecimento']), 14, "0"))

			If lContinua
				// Obtem informações da tabela de Funcionário
				cMatEsoc	:= oJson[nI]['matricula']
				cCpfTrab	:= oJson[nI]['cpf']
				If cJsnVers >= "1.4"
					cCatEsoc	:= STRZERO(oJson[nI]['categoriaTrabalhador']['codigo'],3)
				Else
					cCatEsoc	:= STRZERO(oJson[nI]['categoriaTrabalhador.codigo'],3)
				EndIf
				cCnpjEstab	:= oJson[nI]['numeroInscricaoEstabelecimento']
				lContinua	:= fGetRAMat(@aChvSRA, cMatEsoc, cCpfTrab, cCatEsoc, cCnpjEstab, @cObserv, cFiltFil)
			EndIf

			If lContinua
				oRespItem['_emp'] := cEmpAnt
				oRespItem['_fil'] := aChvSRA[1,1]
				oRespItem['_fun'] := aChvSRA[1,2]
				oJson[nI]['_sra.recno'] := aChvSRA[1,4]

				SRA->(DBGoTo(oJson[nI]['_sra.recno']))
			Else
				oRespItem['_fil']	:= "N/D"
				oRespItem['_fun']	:= "N/D"
				oRespItem['_status'] := "3" //"3-Rejeitado"
			EndIf

			// Valida a competência do empréstimo
			cCompeten	:= perToAnoM(oJson[nI]['competencia'])
			If !(lAPIREST)
				If lContinua .And. !Empty(cX1Compet) .And. perToAnoM(cX1Compet) <> cCompeten
					lContinua	:= .F.
					cObserv		:= OemToAnsi(STR0045) //"A competência do arquivo não é igual a competência do parâmetro."
				EndIf
			EndIf

			If lContinua
				If fGetFolmes(xFilial( "RCH", SRA->RA_FILIAL)) == cCompeten
					lFolAbert := .T.
				Else
					cObserv		:= OemToAnsi(STR0046) + oJson[nI]['competencia'] + OemToAnsi(STR0047)//"A competência " ###### " não está aberta. Não será possível gravar o empréstimo na tabela de Valores Futuros(SRK)."
					If !(lTemRUO)
						lContinua := .F.
					EndIf
				EndIf
			EndIf

			If lContinua
				oJson[nI]['contrato'] := StrTran(StrTran(oJson[nI]['contrato'], '"', ''), "'", "") //remove caracteres invalidos do numero contrato
				lContinua := f944GrvTud(oJson[nI], @cObserv, lSimula, lAtualiza, cCompeten, lFolAbert)
			EndIf

			If !Empty(cObserv)
				oRespItem['_status'] := IIf(lAPIREST, IIf(lContinua, "2", "3"), IIf(lContinua, ("2-"+OemToAnsi(STR0017)), ("3-"+OemToAnsi(STR0018))) )// "2-Alerta informativo"; "3-Rejeitado")
			Else
				If !lSimula
					oRespItem['_status'] := IIf(lAPIREST, "1", ("1-"+ OemToAnsi(STR0016))) // "1-Sucesso"
				EndIf
			EndIf
			oRespItem['_obs']	:= cObserv

			If !(lAPIREST)
				Do Case
					Case Left(oRespItem['_status'], 1) == "1" // "1-Sucesso"
						aQtdReg[2] += 1
					Case Left(oRespItem['_status'], 1) == "2" // "2-Alerta informativo"
						aQtdReg[2] += 1
						aQtdReg[3] += 1
					Case Left(oRespItem['_status'], 1) == "3" // "3-Rejeitado"
						aQtdReg[4] += 1
				End Case

				//Registra o log do item atual na tabela temporária.
				fGrvLog(oJson[nI], oRespItem)
			EndIf

			aAdd(aRespItems, oRespItem)
		Next nI

	EndIf

	If lAPIREST
		oResponse["items"] := aRespItems
	Else
		DbSelectArea(cAliasMark)
		If !(cDataBase == "ORACLE")
			SET FILTER TO
		EndIf
		oMark:GoTop(.T.)
		oMark:Refresh()
	EndIf

Return lRet

/*/{Protheus.doc} fGetRAMat
Função para obter a matrícula do funcionário na tabela SRA.
@author  martins.marcio
@since   17/04/2025
@version V 1.0
/*/
Static Function fGetRAMat(aChvSRA, cMatEsoc, cCpfTrab, cCatEsoc, cCnpjEstab, cObserv, cFiltSRA)

	Local aArea		:= GetArea()
	Local cObsAux	:= ""
	Local lRet		:= .F.
	Local aVincAux	:= {}
	Local nI		:= 0
	Local cCNPJFil	:= ""

	Default aChvSRA		:= {}
	Default cMatEsoc	:= ""
	Default cCpfTrab	:= ""
	Default cCatEsoc	:= ""
	Default cCnpjEstab	:= ""
	Default cObserv		:= ""
	Default cFiltSRA	:= ""

	DbSelectArea("SRA")
	//Busca a partir do CPF do trabalhador e valida a matricula do eSocial caso esteja preenchida
	If !Empty(cCpfTrab)
		SRA->(DbSetOrder(20)) //RA_CIC+RA_FILIAL+RA_MAT
		If SRA->(DbSeek(AllTrim(cCpfTrab)))
			While !SRA->(Eof()) .And. AllTrim(SRA->RA_CIC) == AllTrim(cCpfTrab)
				If SRA->RA_SITFOLH <> "D" .And. (Empty(cMatEsoc) .Or. UPPER(AllTrim(SRA->RA_CODUNIC)) == UPPER(AllTrim(cMatEsoc)))
					If Empty(cFiltSRA) .Or. &(cFiltSRA)
						aAdd(aChvSRA, {SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CATEFD, SRA->(Recno())})
					EndIf
				EndIf
				SRA->(DbSkip())
			EndDo
		EndIf
	EndIf

	//Verifica se o funcionário foi encontrado na tabela SRA
	If Len(aChvSRA) == 1
		lRet := .T.
	ElseIf Len(aChvSRA) > 1

		aEval(aChvSRA, { |x| IIf(x[3] == cCatEsoc, aAdd(aVincAux, x), Nil) }) //Filtra os vínculos pela categoria do eSocial
		aChvSRA := aVincAux
		If Len(aChvSRA) == 1
			lRet := .T.
		ElseIf Len(aChvSRA) > 1
			aVincAux := {}
			For nI := 1 to Len(aChvSRA)
				cCNPJFil := FWSM0Util():GetSM0Data( cEmpAnt , aChvSRA[nI][1] , { "M0_CGC" } )[1][2]
				If AllTrim(cCNPJFil) == cCnpjEstab // Filtra os vínculos pela CNPJ da Filial recebida no arquivo
					aAdd(aVincAux, aChvSRA[nI])
				EndIf
			Next nI
			aChvSRA := aVincAux
			If Len(aChvSRA) == 1
				lRet := .T.
			EndIf
		EndIf
	EndIf

	If !lRet
		If Empty(aChvSRA)
			cObserv := IIf(Empty(cFiltSRA),OemToAnsi(STR0048), OemToAnsi(STR0049)) //"O funcionário não foi encontrado." "O funcionário não foi encontrado nas filiais informadas."
		Else
			aEval(aChvSRA, { |x| cObsAux += IIf(!Empty(cObsAux), ",", "") + "[" + AllTrim(x[1]) + "-" + AllTrim(x[2]) + "]" })
			cObserv := OemToAnsi(STR0050) + cObsAux //"O funcionário possui mais de um vínculo: "
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fGetVerba
Obtém a verba de eConsignado a ser utilizada no lançamento.
Precisa estar posicionado no funcionario pois considera a filial na validação da verba.
@author martins.marcio
@since 24/04/2025
@version 1.0
/*/
Static Function fGetVerba(cContrato, cVerba, aVerbasOK, cObserv, cCompetRUO)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cChvSRV   := ""
	Local cMsgVerba := ""

	DEFAULT cContrato := ""
	DEFAULT cVerba    := ""
	DEFAULT cObserv   := ""
	DEFAULT aVerbasOK := {}
	DEFAULT cCompetRUO := ""

	If lNewSX1
		cVerba	:= getPdEcons(SRA->RA_FILIAL, SRA->RA_MAT, cContrato, @aPdEConsig, @cObserv, cCompetRUO)
	Else
		cVerba	:= LEFT(AllTrim(MV_PAR02), aStrVerb[3])
	EndIf

	If !Empty(cVerba)
		//Verifica a configuração da verba na tabela SRV
		cChvSRV		:= xFilial("SRV", SRA->RA_FILIAL) + cVerba
		If aScan( aVerbasOK , { |x| x == cChvSRV } ) == 0 // Se a chave já foi validada, NÃO verifica novamente
			DbSelectArea("SRV")
			SRV->(dbSetOrder(1)) //RV_FILIAL+RV_COD
			If SRV->(DbSeek(cChvSRV))
				If SRV->RV_TIPOCOD <> "2"
					cMsgVerba := OemToAnsi(STR0051) //"O Tipo deve ser '2-Desconto'."
					lRet := .F.
				EndIf
				If SRV->RV_NATUREZ <> "9253"
					cMsgVerba += OemToAnsi(STR0052) //"A Natureza deve ser '9253'."
					lRet := .F.
				EndIf
				If SRV->RV_INCFGTS <> "31"
					cMsgVerba += OemToAnsi(STR0053) //"A Incidência FGTS deve ser '31'."
					lRet := .F.
				EndIf
			EndIf
			If !Empty(cMsgVerba)
				cObserv += OemToAnsi(STR0080) +"'" + cVerba +"'. "+ cMsgVerba //"Verba inválida: "
			Else
				aAdd(aVerbasOK, cChvSRV)
			EndIf
		EndIf
	Else
		cObserv := IIf(Empty(cObserv), OemToAnsi(STR0079), cObserv) // "A verba não foi informada."
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} f944GrvTud
Realiza as últimas validações e gerencia a gravação do empréstimo/histórico.
@author martins.marcio
@since 24/04/2025
@version 1.0
/*/
Static Function f944GrvTud(oJsnItem, cObserv, lSimula, lAtualiza, cCompeten, lFolAbert)

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local cChvSRK    := ""
	Local lAchouSRK  := .F.
	Local lAchouRUO  := .F.
	Local cContrato  := PADR(AllTrim(oJsnItem['contrato']), aStrNRCon[3])
	Local cCodBco    := IIf(cJsnVers >= "1.4", oJsnItem['ifConcessora']['codigo'], oJsnItem['ifConcessora.codigo'])
	Local cNumID     := ""
	Local cDocumen   := ""
	Local lIntSRK    := .F.
	Local cCompetRUO := fJToD(oJsnItem['competencia'], "C")
	Local aVerbasOK  := {}
	Local cVerba     := ""

	DEFAULT oJsnItem	:= Nil
	DEFAULT cObserv		:= ""
	DEFAULT lSimula		:= .F.
	DEFAULT lAtualiza	:= .F.
	DEFAULT cCompeten	:= perToAnoM(oJsnItem['competencia'])

	DbSelectArea( "SRA" )
	SRA->(DBGoTo(oJsnItem['_sra.recno']))
	If ! (SRA->(Eof()))
		cChvSRK	:= SRA->RA_FILIAL + SRA->RA_MAT + cContrato

		DbSelectArea( "SRK" )
		SRK->(dbSetOrder(7)) //RK_FILIAL+RK_MAT+RK_NRCONTR+RK_PD
		If SRK->( Dbseek( cChvSRK ) )
			lAchouSRK := .T.
			If lAtualiza
				cObserv := IIf(lSimula, OemToAnsi(STR0054), OemToAnsi(STR0055)) //"Empréstimo já existe e será atualizado." "Empréstimo já existe e foi atualizado."
			Else
				cObserv := OemToAnsi(STR0056) //"Empréstimo já existe e NÃO SERÁ ATUALIZADO conforme config."
				lRet	:= .F.
			EndIf

			If !SRKDuplPd(SRA->RA_FILIAL, SRA->RA_MAT, cContrato, cCompeten, SRK->RK_PD, SRK->(Recno()))
				cVerba	:= SRK->RK_PD
			Else
				lRet := fGetVerba( cContrato, @cVerba, @aVerbasOK, @cObserv, cCompetRUO)
			EndIf

		Else
			lRet := fGetVerba( cContrato, @cVerba, @aVerbasOK, @cObserv, cCompetRUO)
		EndIf

		If lRet .And. !(lSimula)
			oJsnItem['_verba'] := cVerba
			If lAchouSRK
				cDocumen	:= SRK->RK_DOCUMEN
				cNumID		:= "SRK" + SRA->RA_FILIAL + SRA->RA_MAT + oJsnItem['_verba'] + SRK->RK_DOCUMEN
			Else
				cDocumen	:= IIf(FindFunction("NextDocSRK"), NextDocSRK(SRA->RA_FILIAL, SRA->RA_MAT), STRZERO(1, aStrDocum[3]))
				cNumID		:= "SRK" + SRA->RA_FILIAL + SRA->RA_MAT + oJsnItem['_verba'] + cDocumen
			EndIf

			//Gravação do empréstimo na tabela de Valores Futuros(SRK)
			If lFolAbert
				lIntSRK := fGrvSRK(oJsnItem, lAchouSRK, cDocumen, cNumID, cCodBco, cCompeten, @cObserv)
			EndIf

			//Gravação do histórico (RUO)
			If lTemRUO
				cChvRUO := SRA->RA_FILIAL + SRA->RA_MAT + cContrato + cCompetRUO
				DbSelectArea( "RUO" )
				DbSetOrder(1)//RUO_FILIAL+RUO_MAT+RUO_NRCONT+RUO_COMPET+RUO_PD+RUO_BCOCON
				If RUO->(DbSeek(cChvRUO))
					lAchouRUO := .T.
					If lAtualiza
						If Empty(cObserv)
							cObserv := IIf(lSimula, OemToAnsi(STR0058), OemToAnsi(STR0059)) //"Histórico já existe e será atualizado." "Histórico já existe e foi atualizado."
						EndIf
					Else
						cObserv := OemToAnsi(STR0060) //"Histórico já existe e NÃO SERÁ ATUALIZADO conforme a configuração atual."
						lRet	:= .F.
					EndIf
				EndIf

				If lRet .And. !(lSimula)
					lRet := fGrvRUO(oJsnItem, lAchouRUO, cContrato, cCompetRUO, cCodBco, cNumID, lIntSRK, @cObserv, lFolAbert)
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fGrvSRK
Função responsável pela gravação do empréstimo na tabela SRK.
@author martins.marcio
@since 25/04/2025
@version 1.0
/*/
Static Function fGrvSRK(oJsnItem, lAchouSRK, cDocumen, cNumID, cCodBco, cCompeten, cObserv)

	Local lRet := .F.

	Default oJsnItem	:= Nil
	Default lAchouSRK	:= .F.
	Default cDocumen	:= ""
	Default cNumID		:= ""
	Default cCodBco		:= ""
	Default cCompeten	:= ""
	Default cObserv		:= ""

	Begin Transaction
		//Gravação da SRK
		If lAchouSRK
			Reclock( "SRK", .F. )
		Else
			Reclock( "SRK", .T. )
			SRK->RK_FILIAL	:= SRA->RA_FILIAL
			SRK->RK_MAT		:= SRA->RA_MAT
			SRK->RK_DOCUMEN	:= cDocumen
			SRK->RK_NUMID	:= cNumID
			SRK->RK_NRCONTR	:= oJsnItem['contrato']
		EndIf
		SRK->RK_PD      := oJsnItem['_verba']
		SRK->RK_CC      := SRA->RA_CC
		SRK->RK_PROCES  := SRA->RA_PROCES
		SRK->RK_POSTO   := SRA->RA_POSTO
		SRK->RK_ITEM    := SRA->RA_ITEM
		SRK->RK_CLVL    := SRA->RA_CLVL
		SRK->RK_BCOCONS := cCodBco
		SRK->RK_PERINI  := perToAnoM(oJsnItem['competenciaInicioDesconto'])  //AAAAMM
		SRK->RK_PARCELA := oJsnItem['totalParcelas']
		SRK->RK_VALORPA := oJsnItem['valorParcela']
		SRK->RK_VALORTO := oJsnItem['valorEmprestimo']
		If !Empty(oJsnItem['qtdPagamentos'])
			SRK->RK_PARCPAG		:= oJsnItem['qtdPagamentos']
		EndIf
		SRK->RK_EMPCONS		:= "1" //1=Sim;2=Não
		// SRK->RK_OBSECON		:= "" //Observação do Emprestimo - Memo
		SRK->RK_CONSFGT		:= "1" //Emp.Consig c/ Garant.FGTS? 1=Sim;2=Não
		SRK->RK_STATUS		:= "2" //1=Solicitado;2=Ativo;3=Pago;4=Suspenso;5=Descontinuado
		SRK->RK_VLSALDO		:= (oJsnItem['valorEmprestimo'] - SRK->RK_VLRPAGO)
		SRK->RK_TIPO		:= "G"
		SRK->RK_NUMPAGO		:= "01"
		SRK->RK_DTVENC		:= FirstDay(STOD(cCompeten + "01")) //Ultimo dia do mes da competencia
		SRK->RK_DTMOVI		:= dDataBase
		SRK->RK_DTREF		:= dDataBase
		SRK->(MsUnlock())
		lRet := .T.
	End Transaction

Return lRet

/*/{Protheus.doc} fGrvRUO
Função responsável pela gravação do histórico na tabela RUO.
@author martins.marcio
@since 28/04/2025
@version 1.0
/*/
Static Function fGrvRUO(oJsnItem, lAchouRUO, cContrato, cCompetRUO, cCodBco, cNumID, lIntSRK, cObserv, lFolAbert)

	Local lRet		:= .F.

	DEFAULT oJsnItem	:= Nil
	DEFAULT lAchouRUO	:= .F.
	DEFAULT cContrato	:= ""
	DEFAULT cCompetRUO	:= ""
	DEFAULT cCodBco		:= ""
	DEFAULT cNumID		:= ""
	DEFAULT lIntSRK		:= .F.
	DEFAULT cObserv		:= ""
	DEFAULT lFolAbert	:= .F.

	Begin Transaction
		//Grava no histórico (com o RK_DOCUMEN se tiver)
		If lAchouRUO
			Reclock( "RUO", .F. )
		Else
			Reclock( "RUO", .T. )
			RUO->RUO_FILIAL	:= SRA->RA_FILIAL
			RUO->RUO_MAT	:= SRA->RA_MAT
			RUO->RUO_NRCONT	:= cContrato
			RUO->RUO_COMPET	:= cCompetRUO
			RUO->RUO_BCOCON	:= cCodBco
			RUO->RUO_DTINIC	:= CTOD(oJsnItem['dataInicioContrato'])
		EndIf
		RUO->RUO_PD			:= oJsnItem['_verba']
		RUO->RUO_DTFIMC		:= CTOD(oJsnItem['dataFimContrato'])
		RUO->RUO_INIDES		:= fJToD(oJsnItem['competenciaInicioDesconto'], "C")
		RUO->RUO_FIMDES		:= fJToD(oJsnItem['competenciaFimDesconto'], "C")
		RUO->RUO_PARCEL		:= oJsnItem['totalParcelas']
		RUO->RUO_VLPARC		:= oJsnItem['valorParcela']
		RUO->RUO_VLTOT		:= oJsnItem['valorEmprestimo']
		If !Empty(oJsnItem['qtdPagamentos'])
			RUO->RUO_PARPAG		:= oJsnItem['qtdPagamentos']
		EndIf
		If !Empty(oJsnItem['qtdEscrituracoes'])
			RUO->RUO_QTESCR		:= oJsnItem['qtdEscrituracoes']
		EndIf
		RUO->RUO_CATEFD		:= IIf(cJsnVers >= "1.4", STRZERO(oJsnItem['categoriaTrabalhador']['codigo'], 3) , STRZERO(oJsnItem['categoriaTrabalhador.codigo'], 3))
		RUO->RUO_NUMID		:= cNumID
		RUO->RUO_DTREF		:= dDataBase
		RUO->RUO_INTEGR		:= IIf(lIntSRK, "1", "2") //1=Sim;2=Não
		If !Empty(cObserv) //MEMO
			MsMm("RUO_OBSERV", /*nTam*/, /*nLin*/, cObserv, 1, /*nTabSize*/, /*lWrap*/, "RUO", RUO->RUO_OBSERV, "RDY", /*cCpochave*/ , /*cRealAlias*/, .F.)
			RecLock("RUO", .F.) // Garante o lock após o MSMM
		EndIf
		RUO->(MsUnlock())

		If !(lFolAbert)
			cObserv += OemToAnsi(STR0061) //"O emprestimo foi gravado somente no Histórico(RUO)."
		EndIf

		lRet := .T.

	End Transaction

Return lRet

/*/{Protheus.doc} fSelecArq
Função responsável por abrir a tela de seleção do arquivo.
@author martins.marcio
@since 15/04/2025
@version 1.0
/*/
Static Function fSelecArq(cArqImp)

	Local cMascArq	:= ".JSON|*.json|CSV|*.csv|*.*|*.*"
	Default cArqImp	:= ""

	cArqImp		:= PADR(cGetFile(cMascArq, OemToAnsi(STR0073),,,,GETF_LOCALHARD+GETF_NETWORKDRIVE), 100) //"Selecione o arquivo que deseja importar."

Return Nil

/*/{Protheus.doc} fGrvLog
Registra os logs do item atual na tabela temporária
@author  martins.marcio
@since	16/04/2025
@version P12
/*/
Static Function fGrvLog(oJsonItem, oRespItem)

	Local lRet := .F.

	If RecLock(cAliasMark,.T.)
		(cAliasMark)->TAB_BANCO 	:= IIf(cJsnVers >= "1.4", oJsonItem['ifConcessora']['codigo'], oJsonItem['ifConcessora.codigo'])
		(cAliasMark)->TAB_DBANCO	:= IIf(cJsnVers >= "1.4", oJsonItem['ifConcessora']['descricao'],oJsonItem['ifConcessora.descricao'])
		(cAliasMark)->TAB_NCONTR	:= oJsonItem['contrato']
		(cAliasMark)->TAB_COMPET	:= StrTran(oJsonItem['competencia'], "/","")
		(cAliasMark)->TAB_CPF		:= oJsonItem['cpf']
		(cAliasMark)->TAB_MATESO	:= oJsonItem['matricula']
		(cAliasMark)->TAB_NFUNCI	:= oJsonItem['nomeTrabalhador']
		(cAliasMark)->TAB_VALORP	:= oJsonItem['valorParcela']
		(cAliasMark)->TAB_FILIAL 	:= IIf(!Empty(oRespItem['_fil']),	oRespItem['_fil'], Replicate("*", aStrRAFil[3]))
		(cAliasMark)->TAB_FUNCIO 	:= IIf(!Empty(oRespItem['_fun']), 	oRespItem['_fun'],	Replicate("*", aStrRAMat[3]))
		(cAliasMark)->TAB_STATUS	:= oRespItem['_status']
		(cAliasMark)->TAB_OBS		:= oRespItem['_obs']
		(cAliasMark)->(MsUnLock())
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} perToAnoM
Inverte o periodo de MM/AAAA o formato AAAAMM utilizado nas tabelas do Protheus.
@author martins.marcio
@since 25/04/2025
@version 1.0
/*/
Static Function perToAnoM(cPeriodo)
	Local cPerRet := StrTran(cPeriodo, "/", "")
	cPerRet := Substr(cPerRet, 3, 4) + SubsTr(cPerRet, 1, 2)
Return cPerRet

/*/{Protheus.doc} getInfoCsv
Retorna o conteúdo de um campo no arquivo CSV
@author martins.marcio
@since 16/04/2025
@version 1.0
/*/
Static Function getInfoCsv(cCampo, aCposCsv)
	Local cVlrRet := ""
	Local nPosCpo := aScan( aHeaderCSV , { |x| x == cCampo } )

	If nPosCpo > 0
		cVlrRet := aCposCsv[nPosCpo]
	EndIf
Return cVlrRet

/*/{Protheus.doc} fFiltStat
Filtra os registros com base no status recebido em cStatus
@since	16/04/2025
@autor	martins.marcio
@version P12
/*/
Static Function fFiltStat(cStatus)

	Default cStatus := ""

	DbSelectArea(cAliasMark)
	If !Empty(cStatus)
		SET FILTER TO LEFT(TAB_STATUS,1) == cStatus
	Else
		SET FILTER TO
	EndIf

	oMark:GoTop(.T.)
	oMark:Refresh()

Return .T.

/*/{Protheus.doc} fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   19/04/2025
@version V 1.0
/*/
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := StrTran( cDateJson, "-", "" )
	dRet := StrTran( dRet, 		"/", "" )
	If cDtType == "D"
		// dRet := STOD( cDateJson )
	EndIf

Return dRet

/*/{Protheus.doc} msg944Doc
Apresenta a mensagem com link clicável da documentação do TDN.
@author  martins.marcio
@since   30/04/2025
@version V 1.0
/*/
Static Function msg944Doc(cTitulo, cMsgErro, cLinkDoc, cIdMsg, lOmiteMsg)

	Local lChkMsg		:= .F.
	Local oProfile 		:= FWProfile():New()
	Local oButton1
	Local oDlg
	Local oGroup1
	Local oPanel1
	Local oSay1
	Local oSay2

	Default cTitulo		:= OemToAnsi(STR0001) //Crédito do Trabalhador
	Default cMsgErro	:= ""
	Default cLinkDoc	:= ""
	Default cIdMsg		:= "1"
	Default lOmiteMsg	:= .T.

	oProfile:SetUser( RetCodUsr() )
	oProfile:SetProgram( "GPEM944" )
	oProfile:SetTask( "MSG_GPM944" + cIdMsg )

	oProfile:Load()

	lChkMsg := (oProfile:GetStringProfile() == "")

	If lChkMsg
		If !Empty(cLinkDoc)
			cMsgErro	+= cQuebra + cQuebra + OemToAnsi(STR0062) //"Para mais informações, acesse a documentação no link abaixo."
		EndIf

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

			@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
			@ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0034) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
			@ 017, 017 SAY oSay1 PROMPT cMsgErro SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL
			@ 063, 012 SAY oSay2 PROMPT cDocTDN SIZE 190, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
			@ 070, 200 BUTTON oButton1 PROMPT OemToAnsi(STR0074) SIZE 037, 012 OF oPanel1 PIXEL //"OK"

			oSay2:bLClicked := {|| ShellExecute("open", cDocTDN, "", "", 1) }

			oButton1:bLClicked := {|| oDlg:End() }

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

Return

/*/{Protheus.doc} fGetText
Obtem o conteúdo do arquivo selecionado.
@author martins.marcio
@since 05/05/2025
@version 1.0
/*/
Static Function fGetText(cArqImp, cTxtRet)
	Local nHandle		:= 0
	Local nLidos		:= 0
	Local nTamArq		:= 0
	Local lRet			:= .F.
	Local xBuffer		:= ""
	Local nTamLin		:= 65500 //65535 é o tamanho máximo de leitura com a função MemoRead()

	Default cArqImp := ""

	If !Empty(cArqImp)
		nHandle := FOPEN(cArqImp, FO_READ)

		If !(Ferror() # 0 .Or. nHandle < 0)

			FSEEK(nHandle, 0, 0)
			nTamArq := FSEEK(nHandle, 0, 2)
			If nTamArq < nTamLin
				cTxtRet := MemoRead(cArqImp)
			Else
				//Tratamento para arquivos muito grandes
				FSEEK(nHandle,0,0)

				While nLidos < nTamArq
					xBuffer := Space(nTamLin)
					FREAD(nHandle, @xBuffer, nTamLin)
					cTxtRet += AllTrim(xBuffer)
					nLidos += Len(xBuffer)
				EndDo
			EndIf
			lRet := .T.
		EndIf
		FCLOSE(nHandle)
	EndIf

Return lRet

/*/{Protheus.doc} getPdEcons
Obtem a verba de eConsignado.
@author martins.marcio
@since 12/06/2025
@version 1.0
/*/
Function getPdEcons(cRAFilial, cRAMat, cContrato, aPdEConsig, cObserv, cCompetRUO)

	Local aArea     := GetArea()
	Local aPdSeq    := {}
	Local nPosInfo  := 0
	Local nX        := 0
	Local nZ        := 1
	Local cPdRet    := ""
	Local cChvSRK   := ""
	Local aTabS154  := {}
	Local cFilBkp   := cFilant
	Local cJaUsadas := ""
	Local nQtdPd   := 0

	DEFAULT cRAFilial  := ""
	DEFAULT cRAMat     := ""
	DEFAULT cContrato  := ""
	DEFAULT aPdEConsig := {}
	DEFAULT cObserv    := ""
	DEFAULT cCompetRUO  := ""

	If !Empty(aPdEConsig)
		nPosInfo := aScan( aPdEConsig , { |x| x[len(x)] == cRAFilial } )
	EndIf

	// Se ainda não carregou a lista de verbas para a filial corrente, obtem a configuração e adiciona no array aPdEConsig
	If nPosInfo == 0
		aTabS154 := {}

		cFilant  := cRAFilial
		fRetTab( @aTabS154/*aTab_Fol*/, "S154"/*cCodTab*/,/*npoSind*/,/*npoExpre*/,/*dDataRef*/,/*cSindica*/, .F./*lTabFull*/, /*cFilPar*/, .T. /*lRecarga*/)
		cFilant := cFilBkp

		If !Empty(aTabS154)
			nQtdPd := Min(20, Len(aTabS154)-4)
			aPdSeq := Array(nQtdPd)
			For nZ := 1 To Len(aPdSeq)
				aPdSeq[nZ] := aTabS154[nZ+4]
			Next nZ
			aAdd(aPdSeq, cRAFilial)
			aAdd(aPdEConsig, aPdSeq)
		EndIf
	Else
		aPdSeq := aPdEConsig[nPosInfo]
	EndIf

	If !Empty(aPdSeq)
		// Percorre o aPdSeq e seleciona uma verba que ainda não foi utilizada
		DbSelectArea("SRK")
		SRK->(dbSetOrder(4)) //RK_FILIAL+RK_MAT+RK_PD+RK_PERINI+RK_NUMPAGO
		For nX := 1 to (Len(aPdSeq)-1)
			If !Empty(cPdRet) .Or. Empty(aPdSeq[nX])
				EXIT //ABANDONA se já encontrou uma verba ou não há mais verbas para avaliar
			EndIf
			If aPdSeq[nX] $ cJaUsadas
				LOOP //Se a verba já foi avaliada e sabemos que ela não pode ser usada para esse funcionário, pula para a próxima
			EndIf

			cChvSRK	:= SRA->RA_FILIAL + SRA->RA_MAT + aPdSeq[nX]
			If !SRK->( Dbseek( cChvSRK ) )
				If !ExistPdRUO(cRAFilial, cRAMat, cContrato, cCompetRUO, aPdSeq[nX])
					cPdRet  := aPdSeq[nX]
					cObserv := ""
					EXIT
				Else
					cPdRet    := ""
					cJaUsadas += "|" + aPdSeq[nX]
					cObserv   := OemToAnsi(STR0057) + aPdSeq[nX] + "."  //"Já existe empréstimo lançado com a verba " + ### + "."
					cObserv   += OemToAnsi(STR0077)                     //" Cadastre uma nova verba para o eConsignado e informe na tabela S154."
				EndIf
			Else
				While !SRK->(Eof()) .And. SRK->RK_FILIAL + SRK->RK_MAT + SRK->RK_PD == AllTrim(cChvSRK)
					If (AllTrim(SRK->RK_NRCONTR) == AllTrim(cContrato) .Or. AllTrim(SRK->RK_STATUS) == "5") .And. ;
						!ExistPdRUO(cRAFilial, cRAMat, cContrato, cCompetRUO, aPdSeq[nX])
						cPdRet  := aPdSeq[nX]
						SRK->(DbSkip())
						LOOP
					Else
						cPdRet    := ""
						cJaUsadas += "|" + aPdSeq[nX]
						cObserv   := OemToAnsi(STR0057) + aPdSeq[nX] + "."  //"Já existe empréstimo lançado com a verba " + ### + "."
						cObserv   += OemToAnsi(STR0077)                     //" Cadastre uma nova verba para o eConsignado e informe na tabela S154."
					EndIf
					SRK->(DbSkip())
				EndDo
			EndIf
		Next nX
	EndIf

	If Empty(cPdRet) .And. Empty(cObserv)
		cObserv := OemToAnsi(STR0078) //"Acesse a Manutenção de Tabelas e informe as verbas do eConsignado na tabela S154."
	EndIf

	RestArea(aArea)

Return cPdRet

/*/{Protheus.doc} ExistPdRUO
Verifica se a verba de eConsignado já foi utilizada para outro contrato na RUO
@author martins.marcio
@since 26/06/2025
@version 1.0
/*/
Static Function ExistPdRUO(cRAFilial, cRAMat, cContrato, cCompetRUO, cVerba)

	Local lRet := .F.
	Local cChvRUO := ""

	DEFAULT cRAFilial  := ""
	DEFAULT cRAMat     := ""
	DEFAULT cContrato  := ""
	DEFAULT cCompetRUO := ""
	DEFAULT cVerba     := ""

	DbSelectArea("RUO")
	RUO->(DbSetOrder(4))//RUO_FILIAL+RUO_MAT+RUO_PD
	cChvRUO := cRAFilial + cRAMat + cVerba //incluir RUO_COMPET nesse indice para melhorar a performance

	If RUO->(DbSeek(cChvRUO))
		While !RUO->(Eof()) .And. RUO->RUO_FILIAL + RUO->RUO_MAT + RUO->RUO_PD == AllTrim(cChvRUO)
			If RUO->RUO_COMPET == cCompetRUO .And. AllTrim(RUO->RUO_NRCONT) <> AllTrim(cContrato)
				lRet := .T.
				EXIT
			EndIf
			RUO->(DbSkip())
		EndDo
	EndIf

Return lRet

/*/{Protheus.doc} SRKDuplPd
Verifica se a verba de eConsignado está duplicada em outro contrato na SRK
@author martins.marcio
@since 26/06/2025
@version 1.0
/*/
Static Function SRKDuplPd(cRAFilial, cRAMat, cContrato, cCompetSRK, cVerba, nRecSRK)

	Local aArea   := GetArea()
	Local cChvSRK := ""
	Local lRet    := .F.

	DEFAULT cRAFilial  := ""
	DEFAULT cRAMat     := ""
	DEFAULT cContrato  := ""
	DEFAULT cCompetSRK := ""
	DEFAULT cVerba     := ""
	DEFAULT nRecSRK    := 0

	DbSelectArea("SRK")
	SRK->(DbSetOrder(4)) //RK_FILIAL+RK_MAT+RK_PD+RK_PERINI+RK_NUMPAGO
	cChvSRK := cRAFilial + cRAMat + cVerba

	If SRK->(DbSeek(cChvSRK))
		While !SRK->(Eof()) .And. SRK->RK_FILIAL + SRK->RK_MAT + SRK->RK_PD == AllTrim(cChvSRK)
			If (SRK->(Recno()) < nRecSRK) .And. AllTrim(SRK->RK_NRCONTR) <> AllTrim(cContrato) .And. AllTrim(SRK->RK_STATUS) <> "5"
				lRet := .T.
				EXIT
			EndIf
			SRK->(DbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return lRet
