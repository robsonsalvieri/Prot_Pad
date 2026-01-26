#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TAFXMLFUNCTIONS.CH"


#DEFINE POS_KEY 	1,1
#DEFINE POS_EVENTO  1,2
#DEFINE POS_NODE	1,3
#DEFINE POS_PROPRI  1,4
#DEFINE POS_ACTION  1,5
#DEFINE POS_ATIVO   1,6
#DEFINE POS_DEFAULT 1,7

Static lFindClass  := FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools
Static lLaySimplif := TafLayESoc()
Static _TmFilTAF   := GetSX3Cache("C1E_FILTAF","X3_TAMANHO")
//-----------------------------------------------------------------------------
/*/{Protheus.doc} TAFXmlLote
Função utilizada para geração em lote dos XML's, conforme layout enviado como parâmetro.
A função fornece uma interface para seleção de status ( filtro de registros ) e
diretório que devem ser entraídos os XML's.

@param	cAliasTb		->	Alias do Evento no TAF
		cLayout			->	Layout
		cRegNode		->	Nó principal do XML para validação de estrutura ( não impede a geração dos arquivos )
		cFunctionXML	->	Função que gera o XML do Evento -> TAF???Xml()
		nEscopo			->	Escopo de agrupamento do Evento no TAFRotinas
		oBrowse			-> Objeto de browse
		

@return nil

@author Luccas Brandino Curcio
@since 21/03/2016
@version 1.0


/*/
//---------------------------------------------------------------------------
Function TAFXmlLote( cAliasTb, cLayout, cRegNode, cFunctionXML, nEscopo, oBrowse )

	Local aAreaAlias    := (cAliasTb)->(GetArea())
	Local oDialog		:= Nil
	Local aMark			:= { .T., .T., .T., .T., .T., .T., .T., .T., .T., .F., .F. } //11
	Local aEventos		:= {}
	Local lNotEvtTab	:= .F.
	Local nTopSlct		:= GetNewPar( "MV_TAFQPRC", 0 )
	Local nTamDlg		:= 0
	Local nLineProc1	:= 0
	Local nLineProc2	:= 0
	Local nRecno        := 0
	Local lContinua     := .T.
	Local lFilPer 		:= .F.

	Default nEscopo		:=	2 //eSocial
	Default oBrowse		:= Nil

	nRecno := (cAliasTb)->(Recno())

	aEventos    := TAFRotinas(  ,, .T., nEscopo )
	lNotEvtTab  := aScan( aEventos, { |x| x[12] == "C" .and. x[4] == cLayout } ) == 0

	if nEscopo == 5 //.Or. nEscopo == 2 //reinf ou esocial, mensal, contem campo _PERAPU
		if aScan( aEventos, { |x|  x[4] == cLayout .And. x[12] == "M" .And. "_PERAPU" $ x[6]  } ) > 0
			lFilPer := .T.
		endif
	endif
	
	nTamDlg     := Iif( lNotEvtTab, 680, 580 )
	nLineProc1  := Iif( lNotEvtTab, 230, 170 )
	nLineProc2  := Iif( lNotEvtTab, 240, 180 )

	if lFilPer
		nTamDlg += 100 //50 filial + 50 periodo
	endif

	If XMLLOTEVLD()
		//verifica se a função de geração do XML existe no repositório
		if findFunction( cFunctionXML )

			If !(FunName() $ "TAFA422|TAFA423|TAFA425|TAFA426|TAFA520|TAFA521")

				//em relação ao comprimento da dialog, utilizo a variavel nTamDlg pois quando se tratar de eventos de tabela nao
				//deve fornecer as opções de exclusão ( S-3000 / R-9000 ) na seleção de status ( Mark 6 e Mark 7 ), então a dimensão da
				//tela se torna dinâmica.
				oDialog := MsDialog():New( 30, 30, nTamDlg, 550,STR0001,,,,,,,,,.T.,,,,.F. )	//"XML em Lote"

				oPainel := TPanel():New(00,00,"",oDialog,,.F.,.F.,,,0,0,.T.,.F.)
				oPainel:Align := CONTROL_ALIGN_ALLCLIENT

				TSay():New( 05, 05, {|| STR0002 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Selecione quais status serão considerados na geração do lote de arquivos XML:"

				TCheckBox():New( 20, 05, STR0003 , bSetGet(@aMark[1]), oPainel, 100, 50,, ,,,,,,.T.,,, )	//Válidos
				TSay():New( 30, 05, {|| "<font size='3' color='#778899'>" + STR0004 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros validados na base do TAF ( ainda não enviados ao RET )"

				TCheckBox():New( 50, 05, STR0012 , bSetGet(@aMark[2]), oPainel, 100, 50,, ,,,,,,.T.,,, )	//"Inválidos"
				TSay():New( 60, 05, {|| "<font size='3' color='#778899'>" + STR0005 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros inválidos na base do TAF ( ainda não enviados ao RET )"

				TCheckBox():New( 80, 05, STR0013 , bSetGet(@aMark[3]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Aguardando retorno"
				TSay():New( 90, 05, {|| "<font size='3' color='#778899'>" + STR0006 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros enviados ao RET e aguardando retorno"

				TCheckBox():New( 110, 05, STR0014 , bSetGet(@aMark[4]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Rejeitados - RET"
				TSay():New( 120, 05, {|| "<font size='3' color='#778899'>" + STR0007 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros enviados ao RET mas que foram rejeitados"

				TCheckBox():New( 140, 05, STR0015 , bSetGet(@aMark[5]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Válidos - RET"
				TSay():New( 150, 05, {|| "<font size='3' color='#778899'>" + STR0008 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros enviados e aprovados pelo RET"

				//Não deve fornecer as opções de exclusão ( S-3000 / R-9000 ) na seleção de status ( Mark 6 e Mark 7 ) quando eventos de tabela
				if lNotEvtTab
					TCheckBox():New( 170, 05, STR0016 , bSetGet(@aMark[6]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Aguardando Exclusão"
					TSay():New( 180, 05, {|| "<font size='3' color='#778899'>" + STR0009 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros em que foi enviada solicitação de exclusão ( evento S-3000 ) ao RET"

					TCheckBox():New( 200, 05, STR0017 , bSetGet(@aMark[7]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Exclusão Confirmada"
					TSay():New( 210, 05, {|| "<font size='3' color='#778899'>" + STR0010 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros já excluídos na base do RET"
				endif

				//em relação a visualização do status não processados, utilizo as variaveis nLineProc1 e nLineProc2 pois quando
				//se tratar de eventos de tabela nao deve fornecer as opções de exclusão ( S-3000 / R-9000 ) na seleção de status
				//( Mark 6 e Mark 7 )
				TCheckBox():New( nLineProc1   , 05, STR0018 , bSetGet(@aMark[8]), oPainel, 100, 50,, ,,,,,,.T.,,, )	//"Não processados"
				TSay():New( nLineProc2        , 05, {|| "<font size='3' color='#778899'>" + STR0011 },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Registros que não foram submetidos a validação e/ou transmissão"

				If !(cLayout $ "S-2205|S-2206|S-2306")
					nLineProc1+=30
					nLineProc2+=30
					TCheckBox():New( nLineProc1, 05, "Aplicar filtros do Browse?" , bSetGet(@aMark[9]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Aplicar filtros do Browse?"
					TSay():New( nLineProc2, 05, {|| "<font size='3' color='#778899'>" + "Gerar somente para os registros exibidos no browse" },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Gerar somente para os registros exibidos no browse"					
				Else
					aMark[9] := .F.
				EndIf

				if lFilPer
					nLineProc1+=30
					nLineProc2+=30
					TCheckBox():New( nLineProc1, 05, "Aplicar filtros da filial?" , bSetGet(@aMark[10]), oPainel, 100, 50,,,,,,,,.T.,,, )	//"Aplicar filtros da filial?"
					TSay():New( nLineProc2, 05, {|| "<font size='3' color='#778899'>" + "Gerar para o intervalo de filiais informadas na próxima interface ( apenas eventos periódicos )" },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Gerar para o intervalo de filiais que serão informadas na próxima interface ( apenas eventos periódicos )"

					nLineProc1+=30
					nLineProc2+=30
					TCheckBox():New( nLineProc1, 05, "Aplicar filtros do Período?" , bSetGet(@aMark[11]), oPainel, 100, 100,,,,,,,,.T.,,, )	//"Aplicar filtro do Período?"
					TSay():New( nLineProc2, 05, {|| "<font size='3' color='#778899'>" + "Gerar para o intervalo de períodos informados na próxima interface ( apenas eventos periódicos )" },oPainel ,,,,,,.T.,,,,,,,,,,.T.)	//"Gerar para o intervalo de períodos que serão informados na próxima interface ( apenas eventos periódicos )"
				Else
					aMark[10] := .F.
					aMark[11] := .F.
				endif

				Activate MsDialog oDialog ON INIT ENCHOICEBAR( oDialog, { || oDialog:End(), RunProcXML( cAliasTb, cLayout, cRegNode, cFunctionXML, nTopSlct, aMark, nEscopo, oBrowse, lNotEvtTab ) }, { || oDialog:End() },, ) Centered
			Else

				aFiltBrw := oBrowse:FWFilter():GetFilter()

				If Len(aFiltBrw) > 0 
					If Len(aFiltBrw) == 1
						If MsgNoYes(STR0035,STR0034) //"Deseja gerar o XML em lote apenas com o filtro de Programa?"#"Atenção"
							lContinua := .T.
						Else
							lContinua := .F.
						EndIf
					EndIf

					If lContinua
						RunProcXML( cAliasTb, cLayout, cRegNode, cFunctionXML, nTopSlct, aMark, nEscopo, oBrowse, lNotEvtTab )
					EndIf
				EndIf

			EndIf
		endif

		RestArea(aAreaAlias)

		If nRecno > 0
			(cAliasTb)->(DbGoto(nRecno))
		EndIf
	EndIf
return
//-------------------------------------------------------------------
/*/{Protheus.doc} XMLLOTEVLD
Verifica se contem dados senssíveis e também verifica se o usuario tem acesso aos dados, se sim o log
é auditado. se não a tela(Ex: Historico) é bloqueada.
@author  José Riquelmo Gomes da Silva
@since   14/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XMLLOTEVLD()

	Local aArea		:= GetArea()
	Local aHistAlt 	:= {}
	Local lRet		:= .T.

	aHistAlt := TAFRotinas()

	If Len(aHistAlt) > 0

		nPosTaf	:= aScan(aHistAlt,{|x| x[1] == FunName()})

		If nPostaf > 0

			If  Len(aHistAlt[nPosTaf]) > 16 .And. aHistAlt[nPosTaf][17]  // verifica se contem dados senssíveis

				If ( lRet := IIf(FindFunction("PROTDATA"),ProtData(),.T.)  )
					IIf (FindFunction('FwPDLogUser'),FwPDLogUser('TAFXMLLOTE'),.T.) //Grava
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} TafXmlVLD
Verifica se contem dados senssíveis e também verifica se o usuario tem acesso aos dados, se sim o log
é auditado. se não a tela (Ex: Historico) ou a geração de XML é bloqueada.
@author  José Riquelmo Gomes da Silva
@since   14/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafXmlVLD(cFunctionXML)

	Local aArea		:= GetArea()
	Local aHistAlt 	:= {}
	Local lRet		:= .T.

	Default cFunctionXML := ''

	aHistAlt := TAFRotinas()

	If Len(aHistAlt) > 0

		nPosTaf	:= aScan(aHistAlt,{|x| x[1] == FunName() })

		If nPosTaf > 0

			If  Len(aHistAlt[nPosTaf]) > 16 .And. aHistAlt[nPosTaf][17]  // verifica se contem dados senssíveis

				If ( lRet	:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)  ) //Verifica se o Usuario tem permissão a dados sensíveis
					IIf (FindFunction('FwPDLogUser'),FwPDLogUser(cFunctionXML),.T.) //Grava o LOG /Audita.
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
//---------------------------------------------------------------------------
/*/{Protheus.doc} RunProcXml
Função responsável por validar o diretório de destino e status selecionados
para geração do XML.
Executa a função responsável pela extração do XML.

@param	cAliasTb  		->	Alias do Evento no TAF
		cLayout			->	Layout
		cRegNode		->	Nó principal do XML para validação de estrutura ( não impede
			      			a geração dos arquivos )
		cFunctionXML	->	Função que gera o XML do evento -> TAF???Xml()
		nTopSlct		->	Quantidade máxima de registros no retorno da query
		aMark			->	Status selecionados na tela
		nEscopo			->	Escopo de agrupamento do Evento no TAFRotinas
		oBrowse			-> Objeto de browse

@return nil

@author Luccas Brandino Curcio
@since 21/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function RunProcXml( cAliasTb, cLayout, cRegNode, cFunctionXML, nTopSlct, aMark, nEscopo, oBrowse, lNotEvtTab )

	local	aStatusMark	:= aClone( aMark )//guardo o conteudo selecionado, pois a funcao cGetFile despociona o conteudo do array conforme foco na tela
	local	lMark01		:= aMark[ 1 ]
	local	lMark02		:= aMark[ 2 ]
	local	lMark03		:= aMark[ 3 ]
	local	lMark04		:= aMark[ 4 ]
	local	lMark05		:= aMark[ 5 ]
	local	lMark06		:= aMark[ 6 ]
	local	lMark07		:= aMark[ 7 ]
	local	lMark08		:= aMark[ 8 ]
	Local   lMark09     := aMark[ 9 ]  //Filtro Browse
	Local   lMark10     := aMark[ 10 ] //Filiais
	Local   lMark11     := aMark[ 11 ] //Periodo
	local	cPath		:= ""
	local	cStatus		:= convStatMark( lMark01 , lMark02 , lMark03 , lMark04 , lMark05 , lMark06 , lMark07 , lMark08, lNotEvtTab )
	local	cBarra      :=  Iif ( IsSrvUnix() , "/" , "\" )

	if ( getRemoteType() == REMOTE_HTML )

		If !ExistDir( cBarra + "xmlexport" )
			MakeDir( cBarra + "xmlexport" )
		EndIf

		cPath := cBarra + "xmlexport" + cBarra

	Else

		cPath := cGetFile( "Diretório" + "|*.*" , "Procurar" , 0, , .T. , GETF_LOCALHARD + GETF_RETDIRECTORY , .T. )

	endif


	if empty( cPath )
		TAFAviso( STR0001 , STR0019 , { STR0021 } )	//"Xml em Lote" ### "Selecione um diretório de destino" ### "Ok"

	elseif aScan( aStatusMark , {|x| x } ) == 0
		TAFAviso( STR0001 , STR0020 , { STR0021 } )	//"Xml em Lote" ### "Selecione ao menos um status" ### "Ok"

	else
		MsgRun( STR0022 + cLayout, STR0023, { || ProcXML( cAliasTb, cLayout, cRegNode, cFunctionXML, nTopSlct, cPath, cStatus, .T., nEscopo, oBrowse, lMark09, lMark10, lMark11 ) } ) //"Processando os arquivos XML do Evento: " ### "Aguarde..."

	endif

return

//---------------------------------------------------------------------------
/*/{Protheus.doc} convStatMark
Função responsável por converter os status selecionados na tela para filtro de geração
do XML na string esperada pela query

@param	lMark01	->	Indica se a opção 1 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark02	->	Indica se a opção 2 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark03	->	Indica se a opção 3 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark04	->	Indica se a opção 4 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark05	->	Indica se a opção 5 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark06	->	Indica se a opção 6 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark07	->	Indica se a opção 7 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )
		lMark08	->	Indica se a opção 8 foi selecionada ( .T. foi selecionada, .F. não foi selecionada )

@return cStatus	->	String no formato esperado pela query, com os status selecionados

@author Luccas Brandino Curcio
@since 21/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------------
static function convStatMark( lMark01 , lMark02 , lMark03 , lMark04 , lMark05 , lMark06 , lMark07 , lMark08, lNotEvtTab )

	Local	cStatus :=	""

	If lMark01
		cStatus	+=	" '0',"
	EndIf

	If lMark02
		cStatus	+=	" '1',"
	EndIf

	If lMark03
		cStatus	+=	" '2',"
	EndIf

	If lMark04
		cStatus	+=	" '3',"
	EndIf

	If lMark05
		cStatus	+=	" '4',"
	EndIf
	
	If lNotEvtTab

		If lMark06
			cStatus	+=	" '6',"
		EndIf

		If lMark07
			cStatus	+=	" '7',"
		EndIf

	EndIf

	If lMark08
		cStatus	+=	" ' ',"
	EndIf

	cStatus	:=	subStr( cStatus , 1 , len( cStatus ) - 1 )

return cStatus

//---------------------------------------------------------------------------
/*/{Protheus.doc} ProcXML
Função responsável por validar o diretório de destino e status selecionados
para geração do XML.
Executa a função responsável pela extração do XML.

@param	cAliasTb  		->	Alias do Evento no TAF
		cLayout			->	Layout
		cRegNode		->	Nó principal do XML para validação de estrutura ( não impede
			      			a geração dos arquivos )
		cFunctionXML	->	Função que gera o XML do evento -> TAF???Xml()
		nTopSlct		->	Quantidade máxima de registros no retorno da query
		cPath			->	Diretório de destino dos arquivos
		cStatus			->	Status que devem ser filtrados ( precisa estar no formato esperado
		       				pelo banco de dados - exemplo:"' ' , '1' , '2'"
		lLote			->	Indica processamento de XML em lote
		nEscopo			->	Escopo de agrupamento do Evento no TAFRotinas
		oBrowse			-> Objeto de browse
		lFilBrw			-> Considera filtro configurado na browse
		lFilLote		->  Considera filtro atraves da interface geracao em lote
		lPerLote		->  Considera Periodo atraves da interface geracao em lote
@return nil

@author Luccas Brandino Curcio
@since 21/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function ProcXML( cAliasTb as Character, cLayout as Character, cRegNode as Character, cFunctionXML as Character, nTopSlct as Numeric, cPath as Character,;
						 cStatus as Character, lLote as Logical, nEscopo as Numeric, oBrowse as Object, lFilBrw as Logical, lFilLote as Logical, lPerLote as Logical )

	Local aArquivos as Array
	Local aFilPer   as Array
	Local aFiltros  as Array
	Local aXmls     as Array
	Local cBanco    as Character
	Local cFil      as Character
	Local cFilLote  as Character
	Local cFilPerg  as Character
	Local cId       as Character
	Local cMsgProc  as Character
	Local cPerLote  as Character
	Local cQry      as Character
	Local cQryFil   as Character
	Local cSigla    as Character
	Local cXml      as Character
	Local lGeraXML  as Logical
	Local lXmlLote  as Logical
	Local nByteXML  as Numeric
	Local nQtdRegs  as Numeric
	Local nSeq      as Numeric
	Local nX        as Numeric
	Local oXML      as Object
	
	Default nTopSlct := 999999
	Default cStatus  := ""
	Default oBrowse  := Nil
	Default lFilBrw  := .F.
	Default lFilLote := .F.
	Default lPerLote := .F.

	aArquivos := {}
	aFilPer   := {}
	aFiltros  := {}
	aXmls     := {}
	cBanco    := Upper( AllTrim( TCGetDB() ) )
	cFil      := ""
	cFilLote  := ""
	cFilPerg  := ""
	cId       := ""
	cMsgProc  := ""
	cPerLote  := ""
	cQry      := ""
	cQryFil   := ""
	cSigla    := Iif( nEscopo == 5, "R-", "S-" )
	cXml      := ""
	lGeraXML  := .F.
	lXmlLote  := .F.
	nByteXML  := 0
	nQtdRegs  := 0
	nSeq      := 0
	nX        := 0
	oXML      := Nil

	If TAFAlsInDic( cAliasTb )

		If !lFilLote

			If MsgYesNo("Deseja gerar os XMLs para todas as filiais ?", "Gerar para todas as filiais")
				lXmlLote := .T.
			EndIf

		EndIf

		If lFilLote .Or. lPerLote
			PgtFilPer( cAliasTb, lFilLote, lPerLote, @aFilPer )
		EndIf

		// Aplica o filtro aplicado ao browse para geração do XML em lote
		If lFilBrw .And. ValType(oBrowse) == "O" .And. ValType(oBrowse:FWFilter()) == "O"

			aFiltros :=  oBrowse:FWFilter():GetFilter() //pega filtro ou exibe browser para informar o filtro

			For nX := 1 To Len(aFiltros)
				
				If aFiltros[nX][6]

					If aFiltros[nX][1] == "Filtro com pergunta"
						cFilPerg := aFiltros[nX][2]
					EndIf

				EndIf

				If !Empty(aFiltros[nX,3])
					cQryFil +=  " AND (" + aFiltros[nX,3] + ") "
				ElseIf !Empty(oBrowse:CESPFILTER)
					cQryFil := ""
					cQryFil  += " AND " + oBrowse:CESPFILTER 
				EndIf
			
			Next nX

		EndIf

		// Aplica o filtro informado na interface filtro xml em lote, importante somente estara populado se estiver no escopo correto, mensal e possuir o campo perapu
		If len(aFilPer) > 0

			If lPerLote
				cPerLote := " AND " + cAliasTb + "_PERAPU >= '"  + aFilPer[1][1] + "' " //periodo de
				cPerLote += " AND " + cAliasTb + "_PERAPU <= '"  + aFilPer[1][2] + "' " //periodo ate
			EndIf

			If lFilLote
				cFilLote := " AND " + cAliasTb + "_FILIAL >= '" + Alltrim(aFilPer[1][3]) + "' " //filial de
				cFilLote += " AND " + cAliasTb + "_FILIAL <= '" + Alltrim(aFilPer[1][4]) + "' " //filial ate
			EndIf

		EndIf

		cQry := TAFQryXMLeSocial( cBanco, nTopSlct, cAliasTb, AllTrim(cStatus),,,,, cLayout,,,, nEscopo,,,, lXmlLote,,,,,cQryFil, cFilLote, cPerLote )

		If !Empty(cQry)
			cQry := ChangeQuery(cQry)
			TcQuery cQry New Alias "TabsTaf"
		EndIf

		Count to nQtdRegs

		//processo a geracao dos arquivos apenas se houver retorno da consulta
		If nQtdRegs > 0

			TabsTaf->(DbGoTop())
			DbSelectArea(cAliasTb)
			DbSetOrder(1)

			while TabsTaf->(!Eof())

				( cAliasTb )->( dbGoTo( TabsTaf->RECTAB ) )

				DbSelectArea(cAliasTb)

				If Empty(cFilPerg) .OR. (!Empty(cFilPerg) .AND. &(cFilPerg))

					lGeraXML := .T.

					If lGeraXML

						nSeq++

						If findFunction( cFunctionXML )

							cXml := &cFunctionXML.( cAliasTb , TabsTaf->RECTAB , , .T. )
							oXML := tXmlManager():New()
							oXML:Parse( encodeUtf8( FTrocaPath( cXml, "eSocial" ) ) )

							If oXml:XPathHasNode( oXML:cPath + "/" + cRegNode )
								cId := strTran( cLayout , "-" , "" ) + TabsTaf->ID + TabsTaf->VERSAO  //oXML:XPathGetAtt(oXML:cPath+"/"+cRegNode ,"Id" )
								aAdd( aXmls , { cXml , cId , TabsTaf->RECTAB } )
								nByteXML += Len( cXML )
							EndIf

						Else

							cMsgProc	:=	STR0024 + cFunctionXML	//"Função para geração de XML não encontrada no repositório: "
							exit

						EndIf

						cFil := TabsTaf->FILIAL
						xTafGerXml( cXml, SubStr( cLayout, 3, 4 ), cPath, lLote,        , nSeq,      , cSigla, cFil,        , aArquivos ) //teste
						aXmls 	 := {}
						nByteXML := 0

					EndIf

				EndIf

				TabsTaf->( dbSkip() )

			Enddo

			If (getRemoteType() == REMOTE_HTML)
				cMsgProc := TAFSmartXML(cPath, aArquivos, cLayout)
			ElseIf !lLote
				cMsgProc	:=	STR0027	//"Processamento finalizado com sucesso."
			EndIf

		Else
			cMsgProc	:=	STR0026	//"Não foram encontrados registros na base de dados."
		EndIf

		TabsTaf->( dbCloseArea() )

	EndIf

	MsgInfo( cMsgProc , STR0028 )	//"Processo Finalizado"

return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFQryXMLeSocial
Função que retorna a query que será utilizada na geração dos arquivos XML ou na
consulta a ser realizada no TSS.

@param	cBancoDB	->	Banco de dados do ambiente
		nTopSlct	->	Qantidade maxima de registros a ser retornada na consulta
		cAliasTb	->	Tabela a ser consultada (nao necessário caso aEventos esteja sendo informado)
		cStatus		->	Status que devem ser filtrados ( precisa estar no formato esperado pelo banco de dados - exemplo:"' ' , '1' , '2'"
		aEventos	-> 	(Opcional) - Array de retorno do TAFRotinas contendo 1 ou mais (Caso enviado, anula o parâmetro cAliasTb)
		aIDsTrb		-> 	OBSOLETO
		cRecNos		->	OBSOLETO
		cMsgProc	->	(Opcional) - Mensagem de processamento
		cLayout		->	Layout do evento
		aFiliais 	->	Array de Filiais
		lAllEventos 	->	Determina se deve ser considerado todos os eventos na consulta por que não houve
					seleção de eventos no browse de eventos periodicos/nao periodicos.
		lJob 		->	Identifica se a rotina está sendo executada via Job.
		nEscopo		->	Escopo de agrupamento do Evento no TAFRotinas
		lCommit 	->	Indica se será comitado na tabela
		lProtul  	->	Indica que será realizado a pesquisa somente dos títulos com número de protocolo (Recibo) em branco.
@return

@author Luccas Brandino Curcio
@since 21/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFQryXMLeSocial( cBancoDB as Character, nTopSlct as Numeric, cAliasTb as Character, cStatus as Character, aEventos as Array, aIDsTrb as Array, cRecNos as Character,;
						   cMsgProc as Character, cLayout as Character, aFiliais as Array, lAllEventos as Logical, lJob as Logical, nEscopo as Numeric, lCommit as Logical,;
						   lProtul as Logical, oTabFilSel as Object, lXmlLote as Logical, cPeriod as Character, cEventos as Character, lApi as Logical, aMotiveCode as Array,;
						   cQueryBc as Character, cFilLote as Character, cPerLote as Character, dDataIni as Date, dDataFim as Date )

	Local cAuxFil     as Character
	Local cCmpTrab    as Character
	Local cCodCM6     as Character
	Local cMaxRegs    as Character
	Local cMotiveCode as Character
	Local cQry        as Character
	Local cTipoEvt    as Character
	Local lMultSts    as Logical
	Local lOrdDesc    as Logical
	Local lOrdena     as Logical
	Local lProthRem   as Logical
	Local lTotal      as Logical
	Local nX          as Numeric

	Default	cBancoDB	:= "" //tcGetDb()
	Default	nTopSlct	:= 0
	Default aEventos 	:= {}
	Default cStatus		:= ""
	Default	lMultSts 	:= .F.
	Default cLayout		:= ""
	Default aFiliais	:= {}
	Default lAllEventos	:= .F.
	Default lJob		:= IsBlind()
	Default nEscopo		:= 2
	Default lCommit		:= .T.
	Default lProtul		:= .F.
	Default oTabFilSel	:= Nil
	Default cRecNos		:= ""
	Default lXmlLote	:= .F.
	Default lApi        := .F.
	Default cEventos	:= ""
	Default aMotiveCode	:= {}
	Default cQueryBc	:= ""
	Default cFilLote    := ""
	Default cPerLote    := ""
	Default dDataIni	:= StoD("")
	Default dDataFim	:= StoD("")

	cAuxFil     := ""
	cCmpTrab    := ""
	cCodCM6     := ""
	cMaxRegs    := ""
	cMotiveCode := ""
	cQry        := ""
	cTipoEvt    := ""
	lMultSts    := IIf(AT(",",cStatus) > 0,.T.,.F.)
	lOrdDesc    := .F.
	lOrdena     := IsInCallStack("TAFPROC4TSS")
	lProthRem   := .F.
	lTotal      := .F.
	nX          := 0

	If lJob

		If Len(aEventos) == 0
			aEventos := TAFRotinas( ,, .T., nEscopo )
		EndIf

		If !IsInCallStack("TAFPROC5TSS") .And. !IsInCallStack("TAFDEMAND") .And. !Empty(cEventos)
			fRetEvtBlq(@aEventos, cEventos)//RETIRADA DOS EVENTOS VIA JOB QUE NÃO ESTÃO CADASTRADOS TAFA441 - GRUPO DE EVENTOS
		EndIf

	Else

		If Empty( aEventos )

			If ( "R-" $ cLayout ) .or. ( ( cLayout == "S-1202" ) .and. cAliasTb == "C91" ) .or. ( cAliasTb == "C9V" ) .or. ( cAliasTb == "V73" )  //Se for C9V( Trabalhador ) deve buscar pelo Layout do Evento
				aAdd( aEventos, TAFRotinas( cLayout, 4, .F., nEscopo ) )
			Else
				aAdd( aEventos, TAFRotinas( cAliasTb, 3, .F., nEscopo ) )
			EndIf

		EndIf

	EndIf

	If ProcName(18) $ "TAFA422|TAFA423|TAFA425|TAFA426|TAFA520|TAFA521"
		lTotal := .T.
	EndIf

	If FunName() $ "TAFA422|TAFA423|TAFA425|TAFA426|TAFA520|TAFA521"
		lProthRem := .T.
	EndIf

	//nao utilizo o comando TOP quando o banco de dados for INFORMIX, ORACLE, DB2 ou POSTGRES
	cMaxRegs	:=	 iif( !( cBancoDB $ ( "INFORMIX|ORACLE|DB2|POSTGRES|OPENEDGE" ) ) , "TOP " + allTrim( str( nTopSlct ) ) , "" )

	If !Empty(cStatus)
		ajustaStatus(@cStatus,lMultSts)
	EndIf

	getMotiveId(aMotiveCode,@cMotiveCode)

	For nX := 1 To Len(aEventos)

		If !Empty(aEventos[nX][4])

			cFunction 	:= aEventos[nX][8]
			cAliasTb 	:= aEventos[nX][3]
			cLayout		:= aEventos[nX][4]
			cRegNode 	:= aEventos[nX][9]
			cCmpTrab	:= aEventos[nX][11]
			cTipoEvt 	:= aEventos[nX][12]

			If lJob
				xTAFMsgJob( cMsgProc + cAliasTb )
			ElseIf !Empty(cMsgProc)
				IncProc( cMsgProc + cAliasTb )
			EndIf

			If TAFAlsInDic(cAliasTb) .And. !Empty(cLayout)  .And. (lProthRem .OR. !( cLayout $ "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|TAUTO|S-5503" ))

				If !Empty(cQry)
					cQry += " UNION ALL "
				EndIf

				//formato a query de acordo com a tabela enviada como parametro e o status desejado
				//todas as tabelas do eSocial possuem o campo _VERSAO, por este motivo esta no select
				If nTopSlct > 0
					cQry += " SELECT " 	+ cMaxRegs 	+ " " + cAliasTb	+ "_FILIAL FILIAL "
				Else
					cQry += " SELECT "  + cAliasTb	+ "_FILIAL FILIAL "
				EndIf

				cQry += ", " 		+ cAliasTb 	+                     "_ID ID "
				cQry += ", '" 		+ cAliasTb 	+ 					  "' ALIASEVT "
				cQry += ", '" 		+ cFunction + 					  "' FUNCXML "
				cQry += ", '" 		+ cLayout   + 					  "' LAYOUT "
				cQry += ", " 		+ cAliasTb 	+ 					  "_VERSAO VERSAO "
				cQry += ", '" 		+ cRegNode 	+ 					  "' REGNODE "
				cQry += ", R_E_C_N_O_ RECTAB "

				If lOrdena

					//Insiro a data nos eventos que devem ser ordenados para realizar a transmissão
					If cAliasTb == "CM6"

						cQry += " ,CASE "
						cQry += " WHEN CM6_EVENTO = 'F' "
						cQry += " THEN CM6_DTFAFA "
						cQry += " ELSE CM6_DTAFAS END DATAEVT "

					ElseIf cAliasTb == "CMJ"

						lOrdDesc := .T.

						cCodCM6  := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" )

						cQry     += " ,CASE "
						cQry     += " WHEN CMJ_TPEVEN = '" + cCodCM6 + "' "
						cQry     += " THEN (SELECT CASE "
						cQry     += " 		WHEN CM6_XMLREC = 'TERM' "
						cQry     += " 		THEN CM6_DTFAFA "
						cQry     += " 		ELSE CM6_DTAFAS END DATAEVT "
						cQry     += "		FROM  " + RetSqlName("CM6") + " CM6 "
						cQry     += "       WHERE CM6.CM6_FILIAL = CMJ_FILIAL "
						cQry     += " 		AND   CM6.R_E_C_N_O_ = CMJ_REGREF) "

						If cBancoDB $ "POSTGRES"
							cQry += " ELSE  CAST(' ' AS CHAR) END DATAEVT"
						Else
							cQry += " ELSE  ' ' END DATAEVT"
						EndIf

					Else

						If cBancoDB $ "POSTGRES"
							cQry += " , CAST(' ' AS CHAR) DATAEVT "
						Else
							cQry += " , ' ' DATAEVT "
						EndIf

					EndIf

				EndIf

				cQry += " FROM " + RetSqlName((cAliasTb))
				cQry += " WHERE D_E_L_E_T_ = ' ' "

				If !( cLayout $ "S-5003|S-5013|S-5503" )

					If lMultSts

						cQry += " AND " + cAliasTb + "_STATUS IN (" + cStatus +  ") "

					Else

						If !Empty(cStatus)
							cQry += " AND " + cAliasTb + "_STATUS = " + IIf( AT("'",cStatus) == 0, "'"+cStatus+"'", cStatus )
						EndIf

					EndIf
					
					If aEventos[nX][12] == "E"

						If Empty(cRecNos) .And. !Empty(aEventos[nX][6])

							If lApi .Or. aEventos[nX][4] $ "S-2299|S-2399"

								If !Empty(dDataIni) .OR. !Empty(dDataFim)
									cQry += " AND " + aEventos[nX][6] + " BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "
								ElseIf !Empty(cPeriod) .AND. (Empty(dDataIni) .OR. Empty(dDataFim))
									cQry += " AND " + aEventos[nX][6] + " BETWEEN '" + cPeriod + "01" + "' AND '" + cPeriod + "31" + "' "
								EndIf

							EndIf

						ElseIf aEventos[nX][4] $ "S-2230"

							If !Empty(dDataIni) .OR. !Empty(dDataFim)
								cQry += " AND (( CM6_DTAFAS BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' )"
								cQry += " OR  (CM6_DTFAFA BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' )) "
							EndIf

						EndIf

					Else 

						If (!Empty(cPeriod) .AND. !Empty(aEventos[nX][6]) .AND. lApi .AND. Empty(cRecNos)) .OR. (!Empty(cPeriod) .AND. !Empty(aEventos[nX][6]) .AND. !lApi)
							cQry += " AND (" + aEventos[nX][6] + " = '" + cPeriod + "' OR " + aEventos[nX][6] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "') "
						EndIf

					EndIf

				EndIf

				// Filtra somente os campos com numero de recibo EsocialEventsem branco. Necessario para atualizar o numero do recibo via job
				If lProtul .and. !( cLayout $ "S-5003|S-5013" )
					cQry += " AND " + cAliasTb + "_PROTUL = '' "
				EndIf

				If cLayout == "S-2230" .And. TafColumnPos( "CM6_STASEC" )
					cQry += " AND ( CM6_ATIVO = '1' OR CM6_STASEC = 'E' OR ( CM6_ATIVO = '2' AND CM6_STATUS NOT IN ('4','7') AND CM6_PROTUL = ' ' ) ) "
				ElseIf TafColumnPos( cAliasTb + "_STASEC" )
					cQry += " AND (" + cAliasTb + "_ATIVO = '1' OR " +cAliasTb + "_STASEC = 'E' ) "
				Else
					cQry += " AND " + cAliasTb + "_ATIVO = '1' "
				EndIf

				//Os Eventos de tabela não usam o S-3000 por isso eu considero o Status E
				If cTipoEvt != "C" .and. !( cLayout $ "S-5003|S-5013|S-5503" )
					cQry += " AND " + cAliasTb + "_STATUS <> 'E' "
				EndIf

				//Verifico se a Filial deve gerar o registro S-1000 caso a rotina esteja sendo
				//executada por um job
				If lJob .And. lCommit .And. cLayout == "S-1000"

					If FWGetRunSchedule()
						cQry += " AND " + cAliasTb	+ "_FILTAF = '" + AllTrim(mv_par01) + "' "
					EndIf

				EndIf

				If cAliasTb $ "C9V|C91|V73"
					cQry += " AND " + cAliasTb + "_NOMEVE = '" +  StrTran(cLayout,"-","") +"' "
				EndIf

				If !Empty( cQueryBc )
					cQry += cQueryBc
				EndIf

				If !Empty( cFilLote )
					cQry += cFilLote
				Else

					If !lXmlLote

						If Len(aFiliais) > 0

							If cAliasTb == "C1E"
								cQry += " AND " + cAliasTb + "_FILTAF IN ( "
							Else
								cQry += " AND " + cAliasTb + "_FILIAL IN ( "
							EndIf

							cAuxFil := TafMonPFil(cAliasTb,@oTabFilSel,aFiliais)

							cQry += cAuxFil
							cQry += " ) "
							cAuxFil := ""

						Else

							If cAliasTb == "C1E" .And. lCommit
								cQry += " AND " + cAliasTb	+ "_FILTAF = '" + cFilAnt + "' "
							Else
								cQry += " AND " + cAliasTb	+ "_FILIAL = '" + xFilial(cAliasTb) + "' "
							EndIf

						EndIf

					EndIf

				EndIf

				If !Empty( cPerLote )
					cQry += cPerLote
				EndIf

				If !Empty(AllTrim(cRecNos))
					cQry += " AND R_E_C_N_O_ IN (" + cRecNos +") "
				EndIf

				If lJob .And. cLayout == "S-2230"  .And. !Empty(cMotiveCode)
					cQry += " AND CM6_MOTVAF IN " + formatIn(cMotiveCode, "|")
				EndIf

				If nTopSlct > 0 .And. cBancoDB $ "ORACLE"
					cQry += " AND ROWNUM <= " + AllTrim(Str(nTopSlct))
				EndIf

			Else

				If !AliasInDic(cAliasTb)
					xTAFMsgJob( "Alias " + cAliasTb + " não encontrado no dicionário.")
				ElseIf Empty(cLayout)
					xTAFMsgJob( "Layout não encontrado para o fonte " + cFunction)
				EndIf

			EndIf

		EndIf

	Next nX

	If !Empty(cQry)

		If lOrdena

			cQry += " ORDER BY "
			cQry += " DATAEVT "

			If !lOrdDesc
				cQry += " ,RECTAB "
			EndIf

		EndIf

		If lOrdDesc
			cQry += " DESC, RECTAB DESC "
		EndIf

		If nTopSlct > 0

			If cBancoDB $ "POSTGRES"
				cQry += " LIMIT " + AllTrim(Str(nTopSlct)) + " "
			ElseIf cBancoDB $ "DB2"
				cQry += " FETCH FIRST "+ AllTrim(Str(nTopSlct)) + " ROWS ONLY "
			Endif

		EndIf

	EndIf

Return cQry

//---------------------------------------------------------------------------
/*/{Protheus.doc} ajustaStatus
Normaliza o Status

@param cStatus - Status de Transmissão
@param lMultSts - Identifica se o parametro cStatus está atribuido com um
range de status.

@author Evandro dos Santos Oliveira
@since 12/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function ajustaStatus(cStatus,lMultSts)

	Default cStatus := ""

	If lMultSts

		If At('"',cStatus) > 0
			cStatus := StrTran(cStatus,'"',"'")
		EndIf
	Else
		If cStatus <> "' '"
			cStatus := cValToChar(cStatus)

			If At(",",cStatus) == 0 .And. (At("'",cStatus) > 0 .Or. At('"',cStatus) > 0)
				cStatus := StrTran(cStatus,"'","")
				cStatus := StrTran(cStatus,'"','')
			EndIf
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFQryMonTSS
Função que retorna a query que será utilizada na geração dos arquivos XML ou na
consulta a ser realizada no TSS quando a chamada é realizada a partir do TAFMONTES.

@param	cBancoDB	->	Banco de dados do ambiente
		nTopSlct	->	Qantidade maxima de registros a ser retornada na consulta
		cAliasTb	->	Tabela a ser consultada (nao necessário caso aEvtsESoc esteja sendo informado)
		cStatus	->	Status que devem ser filtrados ( precisa estar no formato esperado
		       			pelo banco de dados - exemplo:"' ' , '1' , '2'"

		aEvtsESoc	-> 	(Opcional) - Array de retorno do TAFRotinas contendo 1 ou mais eventos do e-Social
						(Caso enviado, anula o parâmetro cAliasTb)
		aIDsTrb	-> 	(Opcional) - Array com Ids de trabalhadores  caso o evento(s) seja(m) trabalhista
		cRecNos    	->	(Opcional) - Filtra os registro pelo RecNo do Evento, pode ser utilizado um range
		de recnos. ex: "1,5,40,60"
		cMsgProc	->	(Opcional) - Mensagem de processamento
		cLayoutESocial -> Layout do evento
		aFiliais 	-> Array de Filiais
		lAllEventos -> Determina se deve ser considerado todos os eventos na consulta por que não houve
					   seleção de eventos no browse de eventos periodicos/nao periodicos.
		dDataIni	-> Data Inicial dos eventos
		dDataFim	-> Data Fim dos dos evevntos
		lMV			-> Indica se o evento possui múltiplos vínculos
@return

@author Evandro dos Santos Oliveira
@since 25/08/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
function TAFQryMonTSS( cBancoDB as Character, nTopSlct as Numeric, cAliasTb as Character, cStatus as Character, aEvtsESoc as Array, aIDsTrb as Array,;
						cRecNos as Character, cMsgProc as Character, cLayoutESocial as Character, aFiliais as Array, lAllEventos as Logical,;
						dDataIni as Date, dDataFim as Date, lMV as Logical, oTabFilSel as Object, lReavPen as Logical )

	Local aEventReav     as Array
	Local cAuxFil        as Character
	Local cAuxTrab       as Character
	Local cCmpTrab       as Character
	Local cCodCM6        as Character
	Local cIndApu        as Character
	Local cIniEsoc       as Character
	Local cMaxRegs       as Character
	Local cQry           as Character
	Local cQry2          as Character
	Local cVerSchema     as Character
	Local lEventoMarcado as Logical
	Local lEvtTrb        as Character
	Local lMultSts       as Logical
	Local lOrdDesc       as Logical
	Local lOrdena        as Logical
	Local lT3P           as Logical
	Local lVirgula       as Logical
	Local nEventos       as Numeric
	Local nI             as Numeric
	Local nX             as Numeric
	Local nY             as Numeric
	Local nZ             as Numeric

	Default cBancoDB       := "" //tcGetDb()
	Default nTopSlct       := 0
	Default aEvtsESoc      := {}
	Default aIDsTrb        := {}
	Default cStatus        := ""
	Default lMultSts       := .F.
	Default cLayoutESocial := ""
	Default aFiliais       := {}
	Default lAllEventos    := .T.
	Default dDataIni       := dDataBase
	Default dDataFim       := dDataBase
	Default lMV            := .F.
	Default oTabFilSel     := Nil
	Default lReavPen       := .F.

	aEventReav     := {}
	cAuxFil        := ""
	cAuxTrab       := ""
	cCmpTrab       := ""
	cCodCM6        := ""
	cIndApu        := ""
	cIniEsoc       := SuperGetMv( 'MV_TAFINIE' ,.F.," ")
	cMaxRegs       := ""
	cQry           := ""
	cQry2          := ""
	cVerSchema     := SuperGetMv( 'MV_TAFVLES' ,.F.,"02_03_00")
	lEventoMarcado := .F.
	lEvtTrb        := ""
	lMultSts       := .F.
	lOrdDesc       := .F.
	lOrdena        := IsInCallStack("TAFPROC4TSS")
	lT3P           := .F.
	lVirgula       := .F.
	nEventos       := 0
	nI             := 0
	nX             := 0
	nY             := 0
	nZ             := 0

	// Saída contorno para erro em binário
	If !lMV .And. FWIsInCallStack( "TAFMONMV" )
		lMV := .T.
	EndIf

	If lReavPen .AND. !FwIsInCallStack('TAFMONMV')
		aEventReav := EventReava()
	EndIf

	//Verifica se o Evento foi Selecionado //Realizar Refatoração desta função
	For nX := 1 To Len(aEventosParm)

		If aEventosParm[nX][2]

			For nI := 1 To Len(aEventosParm[nX][1])

				nPos := aScan(aEvtsESoc,{|x|x[4] == aEventosParm[nX][1][nI][2] })
				If nPos > 0
					aEventosParm[nX][1][nI][12] := .T.
				Else
					aEventosParm[nX][1][nI][12] := .F.
				EndIf

			Next nI

		EndIf

	Next nX

	lMultSts 	:= IIf(AT(",",cStatus) > 0,.T.,.F.)
	lEvtTrb 	:= IIf(Len(aIDsTrb) > 0,.T.,.F.)

	//nao utilizo o comando TOP quando o banco de dados for INFORMIX, ORACLE, DB2 ou POSTGRES
	cMaxRegs	:=	 iif( !( cBancoDB $ ( "INFORMIX|ORACLE|DB2|POSTGRES|OPENEDGE" ) ) , "TOP " + allTrim( str( nTopSlct ) ) , "" )


	/*Obs:
		O Array aEventosParm é uma variavel private declarada no fonte TAFMONTES, consequentemente essa função
		só pode ser executada a partir do Monitor e-Social.
	*/
	For nI := 1 To Len(aEventosParm)

		nEventos := Len(aEventosParm[nI][1])

		If nEventos > 0 .And. aEventosParm[nI][2] //Só considero os tipos de eventos selecionados na tela de filtro

			For nX := 1 To nEventos

				lEventoMarcado	:= aEventosParm[nI][1][nX][12] .Or. lAllEventos //Determina se o evento foi marcado no browse
				cLayout			:= aEventosParm[nI][1][nX][02] 					//Descrição do Evento

				If lEventoMarcado .And.  !( cLayout $ "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|S-5503" )

					If lReavPen .AND. !FwIsInCallStack('TAFMONMV') .AND. ASCAN(aEventReav,aEventosParm[nI][1][nX][02]) == 0
						Loop
					EndIf

					cAliasTb 		:= aEventosParm[nI][1][nX][01] //Alias referente ao evento
					cFunction 		:= aEventosParm[nI][1][nX][04] //Função de geração do XML
					cRegNode 		:= aEventosParm[nI][1][nX][05] //Tag de Identificação do Evento
					cCmpTrab		:= aEventosParm[nI][1][nX][06] //Nome do campo relativo ao Id do Trabalhador

					If cAliasTb == 'V9U' .and. ProcName(3) == 'WS068EXEC'
						cCmpData := 'V9U_DTRECP'
					Else 
						cCmpData  		:= aEventosParm[nI][1][nX][07] //Campo que determina o periodo ou data do evento
					EndIf 
					cTipoEvt  		:= aEventosParm[nI][1][nX][08] //Tipo do Evento

					//Se o evento for relacionado ao trabalhador a variavel cCmpTrab deve existir
					If AliasInDic(cAliasTb) .And. !Empty(cLayout) .And. IIf(lEvtTrb,!Empty(cCmpTrab),.T.)

						If !Empty(cQry)
							cQry += " UNION ALL "
						EndIf

						//formato a query de acordo com a tabela enviada como parametro e o status desejado
						//todas as tabelas do eSocial possuem o campo _VERSAO, por este motivo esta no select

						If nTopSlct > 0
							cQry += " SELECT " 	+ cMaxRegs + " "
						Else
							cQry += " SELECT "
						EndIf

						If cAliasTb == "C1E"
							cQry +=  cAliasTb	+"_FILTAF	FILIAL "
						Else
							cQry +=  cAliasTb	+"_FILIAL	FILIAL "
						EndIf

						cQry += " , " 		+ cAliasTb 	+ "_ID							ID "
						cQry += " ,'" 		+ cAliasTb 	+ "' 							ALIASEVT "
						cQry += " ,'" 		+ cFunction + "' 							FUNCXML "
						cQry += " ,'" 		+ cLayout   + "' 							LAYOUT "
						cQry += " , " 		+ cAliasTb 	+ "_VERSAO						VERSAO "
						cQry += " , '" 		+ cRegNode 	+ "' 							REGNODE "
						cQry += " , " 		+ cAliasTb	+ ".R_E_C_N_O_ 					RECTAB "

						If lOrdena

							//Insiro a data nos eventos que devem ser ordenados para realizar a transmissão
							If cAliasTb == "CM6"

								cQry += " ,CASE "
								cQry += " WHEN CM6_EVENTO = 'F' "
								cQry += " THEN CM6_DTFAFA "
								cQry += " ELSE CM6_DTAFAS END DATAEVT "

							ElseIf cAliasTb == "CMJ"

								lOrdDesc := .T.

								cCodCM6  := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" )

								cQry     += " ,CASE "
								cQry     += " WHEN CMJ_TPEVEN = '" + cCodCM6 + "' "
								cQry     += " THEN (SELECT CASE "
								cQry     += " 		WHEN CM6_XMLREC = 'TERM' "
								cQry     += " 		THEN CM6_DTFAFA "
								cQry     += " 		ELSE CM6_DTAFAS END DATAEVT "
								cQry     += "		FROM  " + RetSqlName("CM6") + " CM6 "
								cQry     += "       WHERE CM6.CM6_FILIAL = CMJ_FILIAL "
								cQry     += " 		AND   CM6.R_E_C_N_O_ = CMJ_REGREF) "

								If cBancoDB $ "POSTGRES"
									cQry += " ELSE  CAST(' ' AS CHAR) END DATAEVT"
								Else
									cQry += " ELSE  ' ' END DATAEVT"
								EndIf

							Else

								If cBancoDB $ "POSTGRES"
									cQry += " , CAST(' ' AS CHAR) DATAEVT "
								Else
									cQry += " , ' ' DATAEVT "
								EndIf

							EndIf

						EndIf

						cQry += " FROM " 	+ RetSqlName((cAliasTb))  + " " + cAliasTb

						If cLayout == "S-2200"

							cQry += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
							cQry += " AND C9V_ID = CUP_ID "
							cQry += " AND C9V_VERSAO = CUP_VERSAO "
							cQry += " AND CUP.D_E_L_E_T_ <> '*' "
							cQry += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,,,cTipoEvt)

						EndIf

						If !( cLayout $ "S-5003|S-5013|S-5503" )

							If lMultSts
								cQry += " WHERE " + cAliasTb	+ "_STATUS IN (" + cStatus +  ")"
							Else
								cQry += " WHERE " + cAliasTb	+ "_STATUS = " + IIf( AT("'",cStatus) == 0, "'"+cStatus+"'", cStatus )
							EndIf

						EndIf

						If cLayout = "S-2300"
							cQry +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
						EndIf

						If cLayout == "S-2230"
							cQry += " AND ( CM6_ATIVO = '1' OR CM6_STASEC = 'E' OR ( CM6_ATIVO = '2' AND CM6_STATUS NOT IN ('4','7') AND CM6_PROTUL = ' ' ) )"
						ElseIf TafColumnPos( cAliasTb + "_STASEC" )
							cQry += " AND (" + cAliasTb + "_ATIVO = '1' OR " +cAliasTb + "_STASEC = 'E' )"
						Else
							cQry += " AND " + cAliasTb + "_ATIVO = '1' "
						EndIf

						//Os Eventos de tabela não usam o S-3000 por isso eu considero os Excluidos
						If cTipoEvt != "C" .and. !( cLayout $ "S-5003|S-5013|S-5503" )
							cQry += " AND " + cAliasTb + "_STATUS <> 'E'
						EndIf

						If cAliasTb $ "C9V|C91|"
							cQry += " AND " + cAliasTb + "_NOMEVE = '" +  StrTran(cLayout,"-","") +"'"
						EndIf

						If  cTipoEvt == "M" .OR. cAliasTb == "CMJ"
							
							If lLaySimplif
							
								cIndApu := Space(GetSx3Cache(cAliasTb + "_INDAPU", "X3_TAMANHO"))
							
							EndIf

							cQry += " AND ( "

							If !lLaySimplif

								cQry += " (" + cAliasTb + "_INDAPU = '1' "

							Else

								cQry += " ((" + cAliasTb + "_INDAPU = '1' "
								cQry += " OR " + cAliasTb + "_INDAPU = '" + cIndApu + "') "

							EndIf

							cQry += " AND " + cAliasTb + "_PERAPU >= '" + AnoMes(dDataIni) + "'"
							cQry += " AND " + cAliasTb + "_PERAPU <= '" + AnoMes(dDataFim) + "')"

							If !lLaySimplif

								cQry += " OR (" + cAliasTb + "_INDAPU = '2' "

							Else

								cQry += " OR ((" + cAliasTb + "_INDAPU = '2' "
								cQry += " OR " + cAliasTb + "_INDAPU = '" + cIndApu + "') "

							EndIf

							cQry += " AND " + cAliasTb +  "_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')"
							cQry += " OR (" + cAliasTb + "_INDAPU = '" + cIndApu + "' "
							cQry += " AND " + cCmpData + " = ' ' AND '" + cAliasTb + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
							cQry += ")"

						ElseIf cTipoEvt == "M" .And. !Empty(AllTrim(cCmpData)) 

							cQry += " AND " + cCmpData + " >= '" + DtoS(dDataIni) + "'"
							cQry += " AND " + cCmpData + " <= '" + DtoS(dDataFim) + "'"

						EndIf

						If  cTipoEvt == "E" .And. !Empty(AllTrim(cCmpData)) .And. cAliasTb != "CMJ" .And. cLayout <> "S-2501"

							cQry += " AND " + cCmpData + " >= '" + DtoS(dDataIni) + "'"
							cQry += " AND " + cCmpData + " <= '" + DtoS(dDataFim) + "'"

						ElseIf cLayout == "S-2501"

							cQry += " AND " + cAliasTb + "_PERAPU >= '" + AnoMes(dDataIni) + "'"
							cQry += " AND " + cAliasTb + "_PERAPU <= '" + AnoMes(dDataFim) + "'"

						EndIf
						
						If cLayout $ "S-1200|S-1210|S-1295|S-1299|S-2299|S-2399|S-2501|"

							If IsInCallStack("consultaTotalizador")

								If TAFColumnPos(cAliasTb+"_GRVTOT") .And. "4" $ cStatus
									cQry += " AND " + cAliasTb+"_GRVTOT = 'F' "
								EndIf

							EndIF

						EndIf

						// --> Eventos com múltiplos vínculos não possuem um trabalhador informado.
						// --> Por isso verifica se o CPF está preenchido diretamente no evento.
						If cLayout == "S-1200" .Or. cLayout == "S-1210"

							If  lMV

								Do Case
									Case cLayout == "S-1200"
										cQry += " AND C91_MV = '1' " //OR C91_CPF <> '' "//AND C91_TRABAL = '' "
									Case cLayout == "S-1210"
										cQry += " AND T3P_CPF <> '' AND T3P_BENEFI = '' "
										lT3P = .T.
								EndCase

							Else

								Do Case
									Case cLayout == "S-1200"
										cQry += " AND C91_TRABAL <> '' "
									Case cLayout == "S-1210"
										cQry += " AND T3P_BENEFI <> '' "
									EndCase

							EndIf

						EndIf

						If cAliasTb ==  "CM6"

							cQry+= "AND (( "
							cQry+= TafMonPAfast(cVerSchema)
							cQry+= " ) "

						EndIf

						If !Empty(cCmpTrab) .And. lEvtTrb .And. Len(aIDsTrb) > 0

							For nY := 1 to Len( aIDsTrb )

								If nY == 1
									cQry += "  AND ( "
								Else
									cQry += " OR "
								EndIf

								cQry += " ( " + cAliasTb + "_FILIAL = '" + aIDsTrb[nY][1] + "' "

								If lMV

									If lT3P
										cQry += " AND T3P_ID IN ( "
									Else
										cQry += " AND C91_ID IN ( "
									EndIf

								Else

									cQry += " AND " + cCmpTrab + " IN ("

								EndIf

								lVirgula := .F.

								For nZ := 1 to Len( aIDsTrb[nY][2] )

									Iif( lVirgula, cAuxTrab += ",", )
									cAuxTrab += "'" + aIDsTrb[nY][2][nZ] + "'"
									lVirgula := .T.

								Next nZ

								cQry += cAuxTrab
								cQry += " ) ) "
								cAuxTrab := ""

							Next nY

							cQry += " ) "

						Else

							If Len(aFiliais) > 0

								//para C1E devo olhar para o campo _FILTAF ao invés de _FILIAL
								If cAliasTb == "C1E"
									cQry += " AND " + cAliasTb + "_FILTAF IN ( "
								Else
									cQry += " AND " + cAliasTb + "_FILIAL IN ( "
								EndIf

								cAuxFil := TafMonPFil(cAliasTb,@oTabFilSel,aFiliais)

								cQry += cAuxFil
								cQry += " ) "
								cAuxFil := ""

							Else

								If cAliasTb == "C1E"
									cQry += " AND " + cAliasTb	+ "_FILTAF = '" + xFilial((cAliasTb)) + "'"
								Else
									cQry += " AND " + cAliasTb	+ "_FILIAL = '" + xFilial((cAliasTb)) + "'"
								EndIf

							EndIf

						EndIf

						If cAliasTb ==  "CM6"
							cQry += ")"
						EndIf

						If !Empty(AllTrim(cRecNos))
							cQry += " AND " + cAliasTb + ".R_E_C_N_O_ IN (" + cRecNos +")"
						EndIf

						If cLayout == "S-2230"
							cQry += " AND ( CM6_ATIVO = '1' OR CM6_STASEC = 'E' OR ( CM6_ATIVO = '2' AND CM6_STATUS NOT IN ('4','7') AND CM6_PROTUL = ' ' ) )"
						ElseIf TafColumnPos( cAliasTb + "_STASEC" )
							cQry += " AND (" + cAliasTb + "_ATIVO = '1' OR " +cAliasTb + "_STASEC = 'E' )"
						Else
							cQry += " AND " + cAliasTb + "_ATIVO = '1' "
						EndIf

						//Os Eventos de tabela não usam o S-3000 por isso eu considero os Excluidos
						If cTipoEvt != "C" .and. !( cLayout $ "S-5003|S-5013|S-5503" )
							cQry += " AND " + cAliasTb + "_STATUS <> 'E'
						EndIf

						//Só pego o registro da Matriz
						If cAliasTb == "C1E"
							cQry += " AND C1E_MATRIZ = 'T' "
						EndIf

						If lReavPen .AND. !FwIsInCallStack('TAFMONMV')
							cQry += ReavPen(cLayout,cAliasTb)
						EndIf

						cQry += " AND " + cAliasTb + ".D_E_L_E_T_ <> '*' "

						If nTopSlct > 0 .And. cBancoDB $ "ORACLE"
							cQry += " AND ROWNUM <= " + AllTrim(Str(nTopSlct))
						EndIf

					Else

						If !AliasInDic(cAliasTb)
							xTAFMsgJob( "Alias " + cAliasTb + " não encontrado no dicionário.")
						ElseIf Empty(cLayout)
							xTAFMsgJob( "Layout não encontrado para o fonte " + cFunction)
						EndIf

					EndIf

				EndIf

			Next nX

		EndIf

	Next nI

	If !Empty(cQry)

		cQry2 := " SELECT FILIAL,ID,ALIASEVT,FUNCXML,LAYOUT,VERSAO,REGNODE,RECTAB"

		If lOrdena
			cQry2 += " ,DATAEVT "
		EndIf

		cQry2 += " FROM ( " + cQry + " ) TAF "
		cQry := cQry2

		If lOrdena

			cQry += " ORDER BY "

			cQry += " DATAEVT "

			If !lOrdDesc
				cQry += " ,RECTAB "
			EndIf

		EndIf

		If lOrdDesc
			cQry += " DESC, RECTAB DESC "
		EndIf

		If nTopSlct > 0

			If cBancoDB $ "POSTGRES"
				cQry += " LIMIT " + AllTrim(Str(nTopSlct)) + " "
			ElseIf cBancoDB $ "DB2"
				cQry += " FETCH FIRST "+ AllTrim(Str(nTopSlct)) + " ROWS ONLY "
			EndIf

		EndIf

	EndIf

return cQry

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFDePara
Função que retorna os arrays contendo o de para de tag x campos no eSocial

@param cEvento - Nome do evento a ser retornado o conteúdo

@return aRet -Array com as informações do(s) evento(s)

@author Fabio V Santana
@since 19/07/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDePara(cEvento)

	Local aRet 		:= {}
	Local cLocTDom	:= IIf(!lLaySimplif, "localTrabDom", "localTempDom")
	Local nPos 		:= 0

	Default cEvento := ""

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1000'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/idePeriodo/iniValid','C1E_DTINI','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/idePeriodo/fimValid','C1E_DTFIN','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/nmRazao','C1E_NOME','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/classTrib','C1E_CLAFIS','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/natJurid','C1E_NATJUR','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indCoop','C1E_INCOOP','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indConstr','C1E_INCONS','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indDesFolha','C1E_DESFOL','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indOpcCP','C1E_INDCP','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indPorte','C1E_PORTE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indOptRegEletron','C1E_REGELT','C1E'})

		If TAFNT0421(lLaySimplif) .And. TafColumnPos("C1E_DTTRSO")
			aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dtTrans11096','C1E_DTTRSO','C1E'})
		EndIf

		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indEntEd','C1E_ENTEDU','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indEtt','C1E_INDETT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/nrRegEtt','C1E_NRETT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/ideMinLei','C1E_SIGMIN','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/nrCertif','C1E_NRCERT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/dtEmisCertif','C1E_DTEMCE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/dtVencCertif','C1E_DTVCCE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/nrProtRenov','C1E_NRPRRE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/dtProtRenov','C1E_DTPRRE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/dtDou','C1E_DTDOU','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/dadosIsencao/pagDou','C1E_PAGDOU','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/nmCtt','C1E_NOMCNT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/cpfCtt','C1E_CPFCNT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/foneDDDFixo','C1E_DDDFON','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/foneFixo','C1E_FONCNT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/foneDDDCel','C1E_DDDCEL','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/foneCel','C1E_CELCNT','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/contato/email','C1E_EMAIL','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/nrSiafi','Não Localizado','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEFR/ideEFR','C1E_EFR','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEFR/cnpjEFR','C1E_CPNJER','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/nmEnte','C1E_NMENTE','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/uf','C1E_UF','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/codMunic','C1E_CODMUN','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/indRPPS','C1E_RPPS','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/subteto','C1E_SUBTET','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOP/infoEnte/vrSubteto','C1E_VLRSUB','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoOrgInternacional/indAcordoIsenMulta','C1E_ISEMUL','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/softwareHouse/cnpjSoftHouse','CRM_CNPJ','CRM'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/softwareHouse/nmRazao','CRM_NOME','CRM'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/softwareHouse/nmCont','CRM_CONTAT','CRM'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/softwareHouse/telefone','CRM_DDD','CRM'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/softwareHouse/email','CRM_MAIL','CRM'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoComplementares/situacaoPJ/indSitPJ','C1E_SITESP','C1E'})
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/infoComplementares/situacaoPF/indSitPF','C1E_SITPF','C1E'})

		//Inclusão S-1.1
		aAdd( aRet[nPos] ,{'S-1000','evtInfoEmpregador','/eSocial/evtInfoEmpregador/infoEmpregador/inclusao/infoCadastro/indTribFolhaPisCofins','C1E_PISCOF','C1E'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1005'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/ideEstab/tpInsc','C92_TPINSC','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/ideEstab/nrInsc','C92_NRINSC','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/ideEstab/iniValid','C92_DTINI','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/ideEstab/fimValid','C92_DTFIN','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/cnaePrep','C92_CNAE','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/aliqRat','C92_ALQRAT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/fap','C92_FAP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/aliqRatAjust','C92_AJURAT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudRat/tpProc','C92_PRORAT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudRat/nrProc','C92_PRORAT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudRat/codSusp','C92_CODSUR','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudFap/tpProc','C92_PROFAP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudFap/nrProc','C92_PROFAP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/aliqGilrat/procAdmJudFap/codSusp','C92_CODSUF','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoCaepf/tpCaepf','C92_TPCAEP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoObra/indSubstPatrObra','C92_SUBPAT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/regPt','C92_REGPT','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoApr/contApr','C92_CONTAP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoApr/nrProcJud','C92_PROCAP','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoApr/contEntEd','C92_CTENTE','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoApr/infoEntEduc/nrInsc','T0Z_CNPJEE','T0Z'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoPCD/contPCD','C92_CONPCD','C92'})
		aAdd( aRet[nPos] ,{'S-1005','evtTabEstab','/eSocial/evtTabEstab/infoEstab/inclusao/dadosEstab/infoTrab/infoPCD/nrProcJud','C92_PROCPD','C92'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1010'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/ideRubrica/codRubr','C8R_CODRUB','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/ideRubrica/ideTabRubr','C8R_IDTBRU','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/ideRubrica/iniValid','C8R_DTINI','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/ideRubrica/fimValid','C8R_DTFIN','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/dscRubr','C8R_DESRUB','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/natRubr','C8R_NATRUB','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/tpRubr','C8R_INDTRB','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/codIncCP','C8R_CINTPS','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/codIncIRRF','C8R_CINTIR','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/codIncFGTS','C8R_CINTFG','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/codIncSIND','C8R_CINTSL','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/repDSR','C8R_REPDSR','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/rep13','C8R_REPDTE','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/repFerias','C8R_REPFER','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/repAviso','C8R_REPREC','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/observacao','C8R_OBS','C8R'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoCP/tpProc','C1G_TPPROC','C1G'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoCP/nrProc','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoCP/extDecisao','T5N_EXTDEC','T5N'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoCP/codSusp','T5N_IDSUSP','T5N'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoIRRF/nrProc','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoIRRF/codSusp','T5N_IDSUSP','T5N'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoFGTS/nrProc','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoFGTS/codSusp','T5N_IDSUSP','T5N'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoSIND/nrProc','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1010','evtTabRubrica','/eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/ideProcessoSIND/codSusp','T5N_IDSUSP','T5N'})


	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1020'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/ideLotacao/codLotacao','C99_CODIGO','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/ideLotacao/iniValid','C99_DTINI','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/ideLotacao/fimValid','C99_DTFIN','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/tpLotacao','C99_TPLOT','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/tpInsc','C99_TPINES','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/nrInsc','C99_NRINES','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/fpas','C99->C99_FPAS','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/codTercs','C99_CODTER','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/codTercsSusp','C99_TERSUS','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/infoProcJudTerceiros/procJudTerceiro/codTerc','T03_FPAS','T03'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/infoProcJudTerceiros/procJudTerceiro/nrProcJud','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/fpasLotacao/infoProcJudTerceiros/procJudTerceiro/codSusp','T03_IDSUSP','T03'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/infoEmprParcial/tpInscContrat','C99_TPINCT','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/infoEmprParcial/nrInscContrat','C99_NRINCT','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/infoEmprParcial/tpInscProp','C99_TPINPR','C99'})
		aAdd( aRet[nPos] ,{'S-1020','evtTabLotacao','/eSocial/evtTabLotacao/infoLotacao/inclusao/dadosLotacao/infoEmprParcial/nrInscProp','C99_NRINPR','C99'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1030'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/ideCargo/codCargo','C8V_CODIGO','C8V'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/ideCargo/iniValid','C8V_DTINI','C8V'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/ideCargo/fimValid','C8V_DTFIN','C8V'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/nmCargo','C8V_DESCRI','C8V'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/codCBO','C8V_CODCBO','C8V'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/acumCargo','T10_ACUMCG','T10'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/contagemEsp','T10_CONESP','T10'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/dedicExcl','T10_DEDEXC','T10'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/leiCargo/nrLei','T11_NRLEI','T11'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/leiCargo/dtLei','T11_DTLEI','T11'})
		aAdd( aRet[nPos] ,{'S-1030','evtTabCargo','/eSocial/evtTabCargo/infoCargo/inclusao/dadosCargo/cargoPublico/leiCargo/sitCargo','T11_SITCGO','T11'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1035'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/ideCarreira/codCarreira','T5K_CODIGO','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/ideCarreira/iniValid','T5K_DTINI','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/ideCarreira/fimValid','T5K_DTFIN','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/dadosCarreira/dscCarreira','T5K_DESCRI','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/dadosCarreira/leiCarr','T5K_LEICAR','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/dadosCarreira/dtLeiCarr','T5K_DTLEI','T5K'})
		aAdd( aRet[nPos] ,{'S-1035','evtTabCarreira','/eSocial/evtTabCarreira/infoCarreira/inclusao/dadosCarreira/sitCarr','T5K_SITCAR','T5K'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1040'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1040','evtTabFuncao','/eSocial/evtTabFuncao/infoFuncao/inclusao/ideFuncao/codFuncao','C8X_CODIGO','C8X'})
		aAdd( aRet[nPos] ,{'S-1040','evtTabFuncao','/eSocial/evtTabFuncao/infoFuncao/inclusao/ideFuncao/iniValid','C8X_DTINI','C8X'})
		aAdd( aRet[nPos] ,{'S-1040','evtTabFuncao','/eSocial/evtTabFuncao/infoFuncao/inclusao/ideFuncao/fimValid','C8X_DTFIN','C8X'})
		aAdd( aRet[nPos] ,{'S-1040','evtTabFuncao','/eSocial/evtTabFuncao/infoFuncao/inclusao/dadosFuncao/dscFuncao','C8X_DESCRI','C8X'})
		aAdd( aRet[nPos] ,{'S-1040','evtTabFuncao','/eSocial/evtTabFuncao/infoFuncao/inclusao/dadosFuncao/codCBO','C8X_CODCBO','C8X'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1050'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/ideHorContratual/codHorContrat','C90_CODIGO','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/ideHorContratual/iniValid','C90_DTINI','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/ideHorContratual/fimValid','C90_DTFIN','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/hrEntr','C90_HRENT','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/hrSaida','C90_HRSAI','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/durJornada','C90_DURJOR','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/perHorFlexivel','C90_PERFLH','C90'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/horarioIntervalo/tpInterv','CRL_TPINTE','CRL'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/horarioIntervalo/durInterv','CRL_DURINT','CRL'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/horarioIntervalo/iniInterv','CRL_INIINT','CRL'})
		aAdd( aRet[nPos] ,{'S-1050','evtTabHorTur','/eSocial/evtTabHorTur/infoHorContratual/inclusao/dadosHorContratual/horarioIntervalo/termInterv','CRL_FIMINT','CRL'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1060'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/ideAmbiente/codAmb','T04_CODIGO','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/ideAmbiente/iniValid','T04_DTINI','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/ideAmbiente/fimValid','T04_DTFIN','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/dadosAmbiente/dscAmb','T04_DESCRI','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/dadosAmbiente/localAmb','T04_LOCAMB','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/dadosAmbiente/tpInsc','T04_TPINSC','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/dadosAmbiente/nrInsc','T04_NRINSC','T04'})
		aAdd( aRet[nPos] ,{'S-1060','evtTabAmbiente','/eSocial/evtTabAmbiente/infoAmbiente/inclusao/dadosAmbiente/fatorRisco/codFatRis','T09_FATRIS','T09'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1070'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/ideProcesso/tpProc','C1G_TPPROC','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/ideProcesso/nrProc','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/ideProcesso/iniValid','C1G_DTINI','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/ideProcesso/fimValid','C1G_DTFIN','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/indAutoria','C1G_INDAUT','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/indMatProc','C1G_INDMAT','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/dadosProcJud/ufVara','C1G_UFVARA','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/dadosProcJud/codMunic','C1G_CODMUN','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/dadosProcJud/idVara','C1G_VARA','C1G'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/infoSusp/codSusp','T5L_CODSUS','T5L'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/infoSusp/indSusp','T5L_INDDEC','T5L'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/infoSusp/dtDecisao','T5L_DTDEC','T5L'})
		aAdd( aRet[nPos] ,{'S-1070','evtTabProcesso','/eSocial/evtTabProcesso/infoProcesso/inclusao/dadosProc/infoSusp/indDeposito','T5L_INDDEP','T5L'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1080'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/ideOperPortuario/cnpjOpPortuario','C8W_CNPJOP','C8W'})
		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/ideOperPortuario/iniValid','C8W_DTINI','C8W'})
		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/ideOperPortuario/fimValid','C8W_DTFIN','C8W'})
		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/dadosOperPortuario/aliqRat','C8W_ALQRAT','C8W'})
		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/dadosOperPortuario/fap','C8W_FAP','C8W'})
		aAdd( aRet[nPos] ,{'S-1080','evtTabOperPort','/eSocial/evtTabOperPort/infoOperPortuario/inclusao/dadosOperPortuario/aliqRatAjust','C8W_ALQAJU','C8W'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1200'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoMV/indMV','C91_INDMVI','C91'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr/tpInsc','T6W_TPINSC','T6W'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr/nrInsc','T6W_NRINSC','T6W'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr/codCateg','T6W_CODCAT','T6W'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr/vlrRemunOE','T6W_VLREMU','T6W'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab','C9V_NOME','C9V'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/dtNascto','C9V_DTNASC','C9V'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/codCBO','C91_CODCBO','C91'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/natAtividade','C91_NATATV','C91'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/qtdDiasTrab','C91_QTDTRB','C91'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt','',''})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt','',''})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtTransf','',''})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao','',''})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/procJudTrab/tpTrib','CRN_TPTRIB','CRN'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/procJudTrab/nrProcJud','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/ideTrabalhador/procJudTrab/codSusp','CRN_IDSUSP','CRN'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/ideDmDev','T14_IDEDMD','T14'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/codCateg','T14_CODCAT','T14'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/tpInsc','C9K_ESTABE','C9K'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/nrInsc','C9K_ESTABE','C9K'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/codLotacao','C9K_LOTACA','C9K'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/qtdDiasAv','C9K_QTDDIA','C9K'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/matricula','C9L_TRABAL','C9L'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/indSimples','C9L_INDCON','C9L'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/codRubr','C9M_CODRUB','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/ideTabRubr','C8R_IDTBRU','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/qtdRubr','C9M_QTDRUB','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/fatorRubr','C9M_FATORR','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/vrUnit','C9M_VLRUNT','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/itensRemun/vrRubr','C9M_VLRRUB','C9M'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/cnpjOper','T6Y_CNPJOP','T6Y'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/regANS','T6Y_REGANS','T6Y'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/vrPgTit','T6Y_VLPGTI','T6Y'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/detPlano/tpDep','','T6Z'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/detPlano/cpfDep','T6Z_CPFDEP','T6Z'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/detPlano/nmDep','T6Z_NOMDEP','T6Z'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/detPlano/dtNascto','T6Z_DTNDEP','T6Z'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoSaudeColet/detOper/detPlano/vlrPgDep','T6Z_VPGDEP','T6Z'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/infoAgNocivo/grauExp','C9L_GRAEXP','C9L'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/dtAcConv','C9N_DTACOR','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/tpAcConv','C9N_TPACOR','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/compAcConv','','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/dtEfAcConv','C9N_DTEFAC','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/dsc','C9N_DSC','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/remunSuc','','C9N'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/perRef','C9O_PERREF','C9O'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/tpInsc','C9P_ESTABE','C9P'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/nrInsc','C9P_ESTABE','C9P'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/codLotacao','C9P_LOTACA','C9P'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/matricula','C9Q_TRABAL','C9Q'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/indSimples','C9Q_INDCON','C9Q'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/codRubr','C9R_CODRUB','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/ideTabRubr','C8R_IDTBRU','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/qtdRubr','C9R_QTDRUB','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/fatorRubr','C9R_FATORR','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/vrUnit','C9R_VLRUNT','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/itensRemun/vrRubr','C9R_VLRRUB','C9R'})
		aAdd( aRet[nPos] ,{'S-1200','evtRemun','/eSocial/evtRemun/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/remunPerAnt/infoAgNocivo/grauExp','C9Q_GRAEXP','C9Q'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1202'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/qtdDepFP','C9Y_DEPIRF','C9Y'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/procJudTrab/tpTrib','CRN_TPTRIB','CRN'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/procJudTrab/nrProcJud','C1G_NUMPRO','C1G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/ideTrabalhador/procJudTrab/codSusp','CRN_IDSUSP','CRN'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/ideDmDev','T14_IDEDMD','T14'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/tpInsc','T6C_ESTABE','T6C'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/nrInsc','T6C_ESTABE','T6C'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/matricula','T6D_IDTRAB','T6D'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/codCateg','T6D_CODCAT','T6D'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/codCateg','T6E_IDRUBR','T6E'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/itensRemun/ideTabRubr','C8R_IDTBRU','C8R'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/itensRemun/qtdRubr','T6E_QTDRUB','T6E'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/itensRemun/fatorRubr','T6E_FATORR','T6E'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/itensRemun/vrUnit','T6E_VLRUNT','T6E'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/itensRemun/vrRubr','T6E_VLRRUB','T6E'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/cnpjOper','T6F_CNPJOP','T6F'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/regANS','T6F_REGANS','T6F'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/vrPgTit','T6F_VLPGTI','T6F'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/detPlano/tpDep','','T6G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/detPlano/cpfDep','T6G_CPFDEP','T6G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/detPlano/nmDep','T6G_NOMDEP','T6G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/detPlano/dtNascto','T6G_DTNDEP','T6G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerApur/ideEstab/remunPerApur/infoSaudeColet/detOper/detPlano/vlrPgDep','T6G_VPGDEP','T6G'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/dtLei','T61_DTLEI','T61'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/nrLei','T61_NUMLEI','T61'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/dtEf','T61_DTEFET','T61'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/perRef','T6H_PERREF','T6H'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/tpInsc','T6I_ESTABE','T6I'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/nrInsc','T6I_ESTABE','T6I'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/matricula','T6J_IDTRAB','T6J'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/codCateg','T6J_CODCAT','T6J'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/codRubr','T6K_IDRUBR','T6K'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/ideTabRubr','C8R_IDTBRU','C8R'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/qtdRubr','T6K_QTDRUB','T6K'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/fatorRubr','T6K_FATORR','T6K'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/vrUnit','T6K_VLRUNT','T6K'})
		aAdd( aRet[nPos] ,{'S-1202','evtRmnRPPS','/eSocial/evtRmnRPPS/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstab/remunPerAnt/itensRemun/vrRubr','T6K_VLRRUB','T6K'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1207'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T62_CPF','T62'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T5T_TPBENE','T5T'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T5T_NUMBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T63_DEMPAG','T63'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T6O_IDRUBR','T6O'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','C8R_IDTBRU','C8R'})
		aAdd( aRet[nPos] ,{'S-1207','evtBenPrRP','/eSocial/evtBenPrRP','T6O_VLRRUB','T6O'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1210'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/cpfBenef','T3P_BENEFI','T3P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/deps/vrDedDep','T3P_VLDEDB','T3P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/dtPgto','T3Q_DTPGTO','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/tpPgto','T3Q_TPPGTO','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/indResBr','T3Q_INDRES','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/perRef','T3R_PERREF','T3R'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/ideDmDev','T3R_IDEDMD','T3R'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/indPgtoTt','T3R_INDPGT','T3R'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/vrLiq','T3R_VLRLIQ','T3R'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/nrRecArq','T3R_NRARQ','T3R'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/codRubr','LE2_IDRUBR','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/ideTabRubr','LE2_IDRUBR','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/qtdRubr','LE2_QTDRUB','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/fatorRubr','LE2_FATRUB','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/vrUnit','LE2_VLRUNI','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/vrRubr','LE2_VLRRUB','LE2'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/penAlim/cpfBenef','LE3_CPFBEN','LE3'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/penAlim/dtNasctoBenef','LE3_DTNSBE','LE3'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/penAlim/nmBenefic','LE3_NMBEN','LE3'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/retPgtoTot/penAlim/vlrPensao','LE3_VLRPEN','LE3'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/codRubr','LE4_IDRUBR','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/ideTabRubr','LE4_IDRUBR','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/qtdRubr','LE4_QTDRUB','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/fatorRubr','LE4_FATRUB','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/vrUnit','LE4_VLRUNI','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFl/infoPgtoParc/vrRubr','LE4_VLRRUB','LE4'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/perRef','T6P_PERREF','T6P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/ideDmDev','T6P_IDEDMD','T6P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/indPgtoTt','T6P_INDPGT','T6P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/vrLiq','T6P_VLRLIQ','T6P'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/codRubr','T6Q_IDRUBR','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/ideTabRubr','T6Q_IDRUBR','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/qtdRubr','T6Q_QTDRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/fatorRubr','T6Q_FATRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/vrUnit','T6Q_VLRUNI','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/retPgtoTot/vrRubr','T6Q_VLRRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/codRubr','T6Q_IDRUBR','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/ideTabRubr','T6Q_IDRUBR','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/qtdRubr','T6Q_QTDRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/fatorRubr','T6Q_FATRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/vrUnit','T6Q_VLRUNI','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoBenPr/infoPgtoParc/vrRubr','T6Q_VLRRUB','T6Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/codCateg','T5U_IDCATE','T5U'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/dtIniGoz','T5U_DTINIG','T5U'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/qtDias','T5U_QTDIAS','T5U'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/vrLiq','T5U_VLRLIQ','T5U'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/codRubr','T5Y_IDRUBR','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/ideTabRubr','T5Y_IDRUBR','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/qtdRubr','T5Y_QTDRUB','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/fatorRubr','T5Y_FATRUB','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/vrUnit','T5Y_VLRUNI','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/vrRubr','T5Y_VLRRUB','T5Y'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/penAlim/cpfBenef','T5Z_CPFBEN','T5Z'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/penAlim/dtNasctoBenef','T5Z_DTNSBE','T5Z'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/penAlim/nmBenefic','T5Z_NMBEN','T5Z'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoFer/detRubrFer/penAlim/vlrPensao','T5Z_VLRPEN','T5Z'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoAnt/codCateg','T5V_IDCATE','T5V'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoAnt/infoPgtoAnt/tpBcIRRF','T5X_IDTPIR','T5X'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/detPgtoAnt/infoPgtoAnt/vrBcIRRF','T5X_VLRBCI','T5X'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/idePais/codPais','T3Q_IDPAIS','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/idePais/indNIF','T3Q_INDNIF','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/idePais/nifBenef','T3Q_NIFBEN','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/dscLograd','T3Q_DLOUGR','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/nrLograd','T3Q_NUMLOG','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/complem','T3Q_COMPLE','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/bairro','T3Q_BAIRRO','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/nmCid','T3Q_CIDADE','T3Q'})
		aAdd( aRet[nPos] ,{'S-1210','evtPgtos','/eSocial/evtPgtos/ideBenef/infoPgto/idePgtoExt/endExt/codPostal','T3Q_CEP','T3Q'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1250'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpInscAdq','CMS_TPINSC','CMS'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/nrInscAdq','CMS_INSCES','CMS'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/indAquis','CMT_INDAQU','CMT'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/vlrTotAquis','CMT_VLAQUI','CMT'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/tpInscProd','CMU_TPINSC','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nrInscProd','CMU_INSCPR','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/vlrBruto','CMU_VLBRUT','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/vrCPDescPR','CMU_VLCONT','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/vrRatDescPR','CMU_VLGILR','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/vrSenarDesc','CMU_VLSENA','CMU'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/serie','CMV_SERIE','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/nrDocto','CMV_NUMDOC','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/dtEmisNF','CMV_DTEMIS','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/vlrBruto','CMV_VLBRUT','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/vrCPDescPR','CMV_VLCONT','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/vrRatDescPR','CMV_VLGILR','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/nfs/vrSenarDesc','CMV_VLSENA','CMV'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/infoProcJud/nrProcJud','T1Z_IDPROC','T1Z'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/infoProcJud/codSusp','T1Z_IDSUSP','T1Z'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/infoProcJud/vrCPNRet','T1Z_VLRPRV','T1Z'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/infoProcJud/vrRatNRet','T1Z_VLRRAT','T1Z'})
		aAdd( aRet[nPos] ,{'S-1250','evtAqProd','/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpAquis/ideProdutor/infoProcJud/vrSenarNRet','T1Z_VLRSEN','T1Z'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1260'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/nrInscEstabRural','T1M_IDESTA','T1M'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/indComerc','T1N_INDCOM','T1N'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/vrTotCom','T1N_VLRTOT','T1N'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/tpInsc','T1O_TPINSA','T1O'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nrInsc','T1O_NRINSA','T1O'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/vrComerc','T1O_VLRCOM','T1O'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/serie','T6B_SERIE','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/nrDocto','T6B_NUMDOC','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/dtEmisNF','T6B_DTEMIS','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/vlrBruto','T6B_VLBRUT','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/vrCPDescPR','T6B_VLCONT','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/vrRatDescPR','T6B_VLGILR','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs/vrSenarDesc','T6B_VLSENA','T6B'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/tpProc','T1P_IDPROC','T1P'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/nrProc','T1P_IDPROC','T1P'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/codSusp','T1P_IDSUSP','T1P'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/vrCPSusp','T1P_VLRPRV','T1P'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/vrRatSusp','T1P_VLRRAT','T1P'})
		aAdd( aRet[nPos] ,{'S-1260','evtComProd','/eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud/vrSenarSusp','T1P_VLRSEN','T1P'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1270'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/tpInsc','T1Y_ESTABE','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/nrInsc','T1Y_ESTABE','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/codLotacao','T1Y_LOTACA','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcCp00','T1Y_VLBCCP','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcCp15','T1Y_VBCP15','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcCp20','T1Y_VBCP20','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcCp25','T1Y_VBCP25','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcCp13','T1Y_VBCP13','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrBcFgts','T1Y_VLBCFG','T1Y'})
		aAdd( aRet[nPos] ,{'S-1270','evtContratAvNP','/eSocial/evtContratAvNP/remunAvNP/vrDescCP','T1Y_VLRDES','T1Y'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1280'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1280','evtInfoComplPer','/eSocial/evtInfoComplPer/infoSubstPatr/indSubstPatr','T3V_INDPAT','T3V'})
		aAdd( aRet[nPos] ,{'S-1280','evtInfoComplPer','/eSocial/evtInfoComplPer/infoSubstPatr/percRedContrib','T3V_PRCONT','T3V'})
		aAdd( aRet[nPos] ,{'S-1280','evtInfoComplPer','/eSocial/evtInfoComplPer/infoSubstPatrOpPort/cnpjOpPortuario','T3X_IDCNPJ','T3X'})
		aAdd( aRet[nPos] ,{'S-1280','evtInfoComplPer','/eSocial/evtInfoComplPer/infoAtivConcom/fatorMes','T3V_FATMES','T3V'})
		aAdd( aRet[nPos] ,{'S-1280','evtInfoComplPer','/eSocial/evtInfoComplPer/infoAtivConcom/fator13','T3V_FAT13','T3V'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1295'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1295','evtTotConting','/eSocial/evtTotConting/ideRespInf/nmResp','',''})
		aAdd( aRet[nPos] ,{'S-1295','evtTotConting','/eSocial/evtTotConting/ideRespInf/cpfResp','',''})
		aAdd( aRet[nPos] ,{'S-1295','evtTotConting','/eSocial/evtTotConting/ideRespInf/telefone','',''})
		aAdd( aRet[nPos] ,{'S-1295','evtTotConting','/eSocial/evtTotConting/ideRespInf/email','',''})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1299'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/ideRespInf/nmResp','C2J_NOME','C2J'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/ideRespInf/cpfResp','C2J_CPF','C2J'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/ideRespInf/telefone','C2J_DDD','C2J'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/ideRespInf/email','C2J_EMAIL','C2J'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtRemun','CUO_REMUN','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtPgtos','CUO_PAGDIV','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtAqProd','CUO_AQPROD','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtComProd','CUO_COMPRD','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtContratAvNP','CUO_COAVNP','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/evtInfoComplPer','CUO_COMPER','CUO'})
		aAdd( aRet[nPos] ,{'S-1299','evtFechaEvPer','/eSocial/evtFechaEvPer/infoFech/compSemMovto','CUO_COSMVT','CUO'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S1300'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-1300','evtContrSindPatr','/eSocial/evtContrSindPatr/contribSind/cnpjSindic','T2L_CNPJSD','T2L'})
		aAdd( aRet[nPos] ,{'S-1300','evtContrSindPatr','/eSocial/evtContrSindPatr/contribSind/tpContribSind','T2L_TPCONT','T2L'})
		aAdd( aRet[nPos] ,{'S-1300','evtContrSindPatr','/eSocial/evtContrSindPatr/contribSind/vlrContribSind','T2L_VLRCS','T2L'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2190'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-2190',	'evtAdmPrelim', '/eSocial/evtAdmPrelim/infoRegPrelim/cpfTrab'	, 'T3A_CPF'	, 'T3A' } )
		aAdd( aRet[nPos] , {'S-2190',	'evtAdmPrelim', '/eSocial/evtAdmPrelim/infoRegPrelim/dtNascto'	, 'T3A_DTNASC', 'T3A' } )
		aAdd( aRet[nPos] , {'S-2190',	'evtAdmPrelim', '/eSocial/evtAdmPrelim/infoRegPrelim/dtAdm'		, 'T3A_DTADMI', 'T3A' } )

	EndIf

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2200'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/cpfTrab','C9V_CPF','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nisTrab','C9V_NIS','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nmTrab','C9V_NOME','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/sexo','C9V_SEXO','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/racaCor','C9V_RCCOR','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/estCiv','C9V_ESTCIV','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/grauInstr','C9V_GRINST','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/indPriEmpr','C9V_PRIEMP','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nmSoc','C9V_NOMSOC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/dtNascto','C9V_DTNASC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/codMunic','C9V_CODMUN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/uf','C9V_CODUF','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/paisNascto','C9V_CODPAI','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/paisNac','C9V_PAINAC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/nmMae','C9V_NOMMAE','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/nascimento/nmPai','C9V_NOMPAI','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CTPS/nrCtps','C9V_NRCTPS','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CTPS/serieCtps','C9V_SERCTP','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CTPS/ufCtps','C9V_UFCTPS','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RIC/nrRic','C9V_NRRIC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RIC/orgaoEmissor','C9V_OREMRI','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RIC/dtExped','C9V_DTEXRI','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RG/nrRg','C9V_NRRG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RG/orgaoEmissor','C9V_OREMRG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RG/dtExped','C9V_DTEMRG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RNE/nrRne','C9V_NRRNE','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RNE/orgaoEmissor','C9V_OREMRN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/RNE/dtExped','C9V_DTEMRN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/OC/nrOc','C9V_NUMOC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/OC/orgaoEmissor','C9V_OREMOC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/OC/dtExped','C9V_DTEXOC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/OC/dtValid','C9V_DTVLOC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/nrRegCnh','C9V_NRCNH','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/dtExped','C9V_DTEXCN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/ufCnh','C9V_UFCNH','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/dtValid','C9V_DTVLCN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/dtPriHab','C9V_DTPCNH','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/documentos/CNH/categoriaCnh','C9V_CATCNH','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/tpLograd','C9V_TPLOGR','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/dscLograd','C9V_LOGRAD','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/nrLograd','C9V_NRLOG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/complemento','C9V_COMLOG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/bairro','C9V_BAIRRO','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/cep','C9V_CEP','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/codMunic','C9V_MUN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/endereco/brasil/uf','C9V_MUN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/trabEstrangeiro/dtChegada','C9V_DTCHEG','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/trabEstrangeiro/classTrabEstrang','C9V_CCTRAE','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/trabEstrangeiro/casadoBr','C9V_CASBRA','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/trabEstrangeiro/filhosBr','C9V_FILBRA','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/defFisica','C9V_DEFFIS','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/defVisual','C9V_DEFVIS','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/defAuditiva','C9V_DEFAUD','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/defMental','C9V_DEFMEN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/defIntelectual','C9V_DEFINT','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/reabReadap','C9V_REABIL','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/infoCota','C9V_INFCOT','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/infoDeficiencia/observacao','C9V_OBSDEF','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/tpDep','C9Y_TPDEP','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/nmDep','C9Y_NOMDEP','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/dtNascto','C9Y_DTNASC','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/cpfDep','C9Y_CPFDEP','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/depIRRF','C9Y_DEPIRF','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/depSF','C9Y_DEPSFA','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/dependente/incTrab','C9Y_INCTRB','C9Y'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/aposentadoria/trabAposent','C9V_APOSEN','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/contato/fonePrinc','C9V_FONPRC','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/contato/foneAlternat','C9V_FONALT','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/contato/emailPrinc','C9V_EMAILP','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/trabalhador/contato/emailAlternat','C9V_EMAILA','C9V'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/matricula','CUP_MATRIC','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/tpRegTrab','CUP_TPREGT','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/tpRegPrev','CUP_TPREGP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/nrRecInfPrelim','CUP_RECEVT','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/cadIni','Criar','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/dtAdm','CUP_DTADMI','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/tpAdmissao','CUP_TPADMI','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/indAdmissao','CUP_INDADM','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/tpRegJor','CUP_TPREGJ','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/natAtividade','CUP_NATATV','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/dtBase','CUP_DATAB','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/cnpjSindCategProf','CUP_CNPJCP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/FGTS/opcFGTS','CUP_FGTSOP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/FGTS/dtOpcFGTS','CUP_DTFGTS','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/hipLeg','CUP_MOTCON','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/justContr','CUP_JUSHIP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/tpInclContr','CUP_TPINCL','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/tpInsc','CUP_TPINST','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/nrInsc','CUP_NRINST','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/ideEstabVinc/tpInsc','CUP_TPINST','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/ideEstabVinc/nrInsc','CUP_NRINST','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido/cpfTrabSubst','T3L_CPF','T3L'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/aprend/tpInsc','CUP_TPINAP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/aprend/nrInsc','CUP_NRINAP','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/codCargo','CUP_CODCGO','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/codFuncao','CUP_CODFUN','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/codCateg','CUP_CODCAT','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/codCarreira','CUP_CODCAR','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/dtIngrCarr','CUP_DTINGC','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/remuneracao/vrSalFx','CUP_VLSLFX','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/remuneracao/undSalFixo','CUP_UNSLFX','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/remuneracao/dscSalVar','CUP_DESSVR','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/duracao/tpContr','CUP_TPCONT','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/duracao/dtTerm','CUP_DTTERM','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/duracao/clauAssec','Criar','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/localTrabGeral/tpInsc','CUP_TPINSC','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/localTrabGeral/nrInsc','CUP_NRINSC','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/localTrabGeral/descComp','CUP_DESLOT','CUP'} )

		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/tpLograd','CUP_TPLOGD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/dscLograd','CUP_DELOGD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/nrLograd','CUP_NRLOGD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/complemento','CUP_COMLGD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/bairro','CUP_BAIRTD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/cep','CUP_CEPLTD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/codMunic','CUP_CMUNTD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/localTrabalho/'+ cLocTDom +'/uf','CUP_UFTRBD','CUP'} )
				
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/qtdHrsSem','CUP_QTDHJS','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/tpJornada','CUP_TPJORN','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/dscTpJorn','CUP_DTPJOR','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/tmpParc','CUP_TMPARC','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/horario/dia','CUP_CODDIA','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/horContratual/horario/codHorContrat','CUP_CODHOR','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/filiacaoSindical/cnpjSindTrab','T80_CNPJSD','T80'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/alvaraJudicial/nrProcJud','CUP_ALVJUD','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/infoContrato/observacoes/observacao','T90_OBSERV','T90'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/sucessaoVinc/cnpjEmpregAnt','CUP_CNPJEA','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/sucessaoVinc/matricAnt','CUP_MATANT','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/sucessaoVinc/dtIniVinculo','CUP_DTINVI','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/sucessaoVinc/observacao','CUP_OBSVIN','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/afastamento/dtIniAfast','CUP_DTINIA','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/afastamento/codMotAfast','CUP_MOTVAF','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/desligamento/dtDeslig','CUP_DTDESL','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/transfDom/cpfSubstituido','CUP_CPFSUB','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/transfDom/matricAnt','CUP_MATRAN','CUP'} )
		aAdd( aRet[nPos] , {'S-2200', 'evtAdmissao', '/eSocial/evtAdmissao/vinculo/transfDom/dtTransf','CUP_DTTRAN','CUP'} )
	EndIf

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S2205'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/ideTrabalhador/cpfTrab', 'T1U_CPF', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dtAlteracao', 'T1U_DTALT', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/nisTrab', 'T1U_NIS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/nmTrab', 'T1U_NOME', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/sexo', 'T1U_SEXO', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/racaCor', 'T1U_RCCOR', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/estCiv', 'T1U_ESTCIV', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/grauInstr', 'T1U_GRINST', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/nmSoc', 'T1U_NOMSOC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CTPS/nrCtps', 'T1U_NRCTPS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CTPS/serieCtps', 'T1U_SERCTP', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CTPS/ufCtps', 'T1U_UFCTPS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RIC/nrRic', 'T1U_NRRIC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RIC/orgaoEmissor', 'T1U_OREMRI', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RIC/dtExped', 'T1U_DTEXRI', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RG/nrRg', 'T1U_NRRG', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RG/orgaoEmissor', 'T1U_OREMRG', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RG/dtExped', 'T1U_DTEMRG', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RNE/nrRne', 'T1U_NRRNE', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RNE/orgaoEmissor', 'T1U_OREMRN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/RNE/dtExped', 'T1U_DTEMRN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/OC/nrOc', 'T1U_NUMOC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/OC/orgaoEmissor', 'T1U_OREMOC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/OC/dtExped', 'T1U_DTEXOC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/OC/dtValid', 'T1U_DTVLOC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/nrRegCnh', 'T1U_NRCNH', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/dtExped', 'T1U_DTEXCN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/ufCnh', 'T1U_UFCTPS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/dtValid', 'T1U_DTVLCN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/dtPriHab', 'T1U_DTPCNH', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/documentos/CNH/categoriaCnh', 'T1U_CATCNH', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/tpLograd', 'T1U_TPLOGR', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/dscLograd', 'T1U_LOGRAD', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/nrLograd', 'T1U_NRLOG ', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/complemento', 'T1U_COMLOG', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/bairro', 'T1U_BAIRRO', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/cep', 'T1U_CEP', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/codMunic', 'T1U_MUN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/endereco/brasil/uf', 'T1U_MUN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/trabEstrangeiro/dtChegada', 'T1U_DTCHEG', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/trabEstrangeiro/classTrabEstrang', 'T1U_CCTRAE', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/trabEstrangeiro/casadoBr', 'T1U_CASBRA', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/trabEstrangeiro/filhosBr', 'T1U_FILBRA', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/defFisica', 'T1U_DEFFIS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/defVisual', 'T1U_DEFVIS', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/defAuditiva', 'T1U_DEFAUD', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/defMental', 'T1U_DEFMEN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/defIntelectual', 'T1U_DEFINT', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/reabReadap', 'T1U_REABIL', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/infoCota', 'T1U_INFCOT', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/infoDeficiencia/observacao', 'T1U_OBSDEF', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/tpDep', 'T3T_TPDEP', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/nmDep', 'T3T_NOMDEP', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/dtNascto', 'T3T_DTNASC', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/cpfDep', 'T3T_CPFDEP', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/depIRRF', 'T3T_DEPIRF', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/depSF', 'T3T_DEPSFA', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/dependente/incTrab', 'T3T_INCTRB', 'T3T'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/aposentadoria/trabAposent', 'T1U_APOSEN', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/contato/fonePrinc', 'T1U_FONPRC', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/contato/foneAlternat', 'T1U_FONALT', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/contato/emailPrinc', 'T1U_EMAILP', 'T1U'})
		aAdd( aRet[nPos] , {'S-2205',	'evtAltCadastral',	'/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/contato/emailAlternat', 'T1U_EMAILA', 'T1U'})

	EndIf

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2206'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/ideVinculo/cpfTrab','_CPF','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/ideVinculo/nisTrab','_NIS','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/ideVinculo/matricula','_MATRIC','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/dtAlteracao','_DTALT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/dtEf','_DTEF','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/dscAlt','_DESALT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/vinculo/tpRegTrab','_TPREGT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/vinculo/tpRegPrev','_TPREGP','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/tpRegJor','_TPREGJ','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/natAtividade','_NATATV','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/dtBase','_DATAB','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/cnpjSindCategProf','_CNPJCP','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/trabTemp/justProrr','_JUSTPR','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/aprend/tpInsc','','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoCeletista/aprend/nrInsc','','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoRegimeTrab/infoEstatutario/tpPlanRP','T1V_TPLASM','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/codCargo','T1V_CODCGO','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/codFuncao','T1V_CODFUN','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/codCateg','T1V_CODCAT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/codCarreira','T1V_CODCAR','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/dtIngrCarr','T1V_DTINGC','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/remuneracao/vrSalFx','T1V_VLSLFX','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/remuneracao/undSalFixo','T1V_UNSLFX','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/remuneracao/dscSalVar','T1V_DESSVR','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/duracao/tpContr','T1V_TPCONT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/duracao/dtTerm','T1V_DTTERM','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/localTrabGeral/tpInsc','T1V_TPINSC','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/localTrabGeral/nrInsc','T1V_NRINSC','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/localTrabGeral/descComp','T1V_DESLOT','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/tpLograd','T1V_TPLOGD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/dscLograd','T1V_DELOGD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/nrLograd','T1V_NRLOGD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/complemento','T1V_COMLGD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/bairro','T1V_BAIRTD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/cep','T1V_CEPLTD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/codMunic','T1V_CMUNTD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/localTrabalho/'+ cLocTDom +'/uf','T1V_UFTRBD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/qtdHrsSem','T1V_QTDHJS','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/tpJornada','T1V_TPJORN','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/dscTpJorn','T1V_DTPJOR','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/tmpParc','T1V_TMPARC','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/horario/dia','T1V_CODDIA','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/horContratual/horario/codHorContrat','T1V_CODHOR','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/filiacaoSindical/cnpjSindTrab','T79_CNPJSD','T79'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/alvaraJudicial/nrProcJud','T1V_ALVJUD','T1V'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/observacoes/observacao','T91_OBSERV','T91'})
		aAdd( aRet[nPos] ,{'S-2206','evtAltContratual','/eSocial/evtAltContratual/altContratual/infoContrato/servPubl/mtvAlter','T1V_MTVALT','T1V'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2210'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/ideTrabalhador/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/ideTrabalhador/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/dtAcid','CM0_DTACID','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/tpAcid','CM0_TPACID','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/hrAcid','CM0_HRACID','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/hrsTrabAntesAcid','CM0_HRTRAB','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/tpCat','CM0_TPCAT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/indCatObito','CM0_INDOBI','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/dtObito','CM0_DTOBIT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/indComunPolicia','CM0_COMPOL','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/codSitGeradora','CM0_CODSIT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/iniciatCAT','CM0_INICAT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/observacao','CM0_OBSCAT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/tpLocal','CM0_TPLOC','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/dscLocal','CM0_DESLOC','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/dscLograd','CM0_DESLOG','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/nrLograd','CM0_NRLOG','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/codMunic','CM0_CODMUN','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/uf','CM0_UF','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/cnpjLocalAcid','CM0_CNPJLO','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/pais','CM0_CODPAI','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/localAcidente/codPostal','CM0_CODPOS','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/parteAtingida/codParteAting','CM1_CODPAR','CM1'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/parteAtingida/lateralidade','CM1_LATERA','CM1'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/agenteCausador/codAgntCausador','CM2_CODAGE','CM2'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/codCNES','CM0_CODCNE','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/dtAtendimento','CM0_DTATEN','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/hrAtendimento','CM0_HRATEN','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/indInternacao','CM0_INDINT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/durTrat','CM0_DURTRA','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/indAfast','CM0_INDAFA','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/dscLesao','CM0_NATLES','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/dscCompLesao','CM0_DESLES','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/diagProvavel','CM0_DIAPRO ','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/codCID','CM0_CODCID','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/observacao','CM0_OBSERV','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/emitente/nmEmit','CM7_NOME','CM7'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/emitente/ideOC','CM7_IDEOC','CM7'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/emitente/nrOc','CM7_NRIOC','CM7'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/atestado/emitente/ufOC','CM7_NRIUF','CM7'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/catOrigem/dtCatOrig','CM0_DTCAT','CM0'})
		aAdd( aRet[nPos] ,{'S-2210','evtCAT','/eSocial/evtCAT/cat/catOrigem/nrCatOrig','CM0_NRCAT','CM0'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2220'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/dtAso','C8B_DTASO','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/tpAso','C8B_TPASO','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/resAso','C8B_RESULT','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/dtExm','C9W_DTEXAM','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/procRealizado','C9W_CODPRO','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/obsProc','C9W_OBS','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/interprExm','C9W_INTERP','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/ordExame','C9W_ORDEXA','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/dtIniMonit','C9W_DTINMO','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/dtFimMonit','C9W_DTFIMO','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/indResult','C9W_INDRES ','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/respMonit/nisResp','C9W_NISRES','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/respMonit/nrConsClasse','C9W_CRMRES','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/exame/respMonit/ufConsClasse','C9W_CRMUF','C9W'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/codCNES','C8B_CODCNE','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/frmCtt','C8B_CONTAT','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/email','C8B_EMAIL','C8B'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/medico/nmMed','CM7_NOME','CM7'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/medico/crm/nrCRM','CM7_NRIOC','CM7'})
		aAdd( aRet[nPos] ,{'S-2220','evtMonit','/eSocial/evtMonit/aso/ideServSaude/medico/crm/ufCRM','CM7_NRIUF','CM7'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2230'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/ideVinculo/codCateg','',''})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/dtIniAfast','CM6_DTAFAS','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/codMotAfast','CM6_MOTVAF','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoMesmoMtv','CM6_INFMTV','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/tpAcidTransito','CM6_TPACID','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/observacao','CM6_OBSERV','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/codCID','CM6_CODCID','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/qtdDiasAfast','CM6_DIASAF','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/emitente/nmEmit','CM7_NOME','CM7'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/emitente/ideOC','CM7_IDEOC','CM7'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/emitente/nrOc','CM7_NRIOC','CM7'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado/emitente/ufOC','CM7_NRIUF','CM7'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoCessao/cnpjCess','CM6_CNPJCE','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoCessao/infOnus','CM6_INFOCE','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoMandSind/cnpjSind','CM6_CNPJSD','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoMandSind/infOnusRemun','CM6_INFOSD','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/infoRetif/origRetif','',''})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/infoRetif/tpProc','',''})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/infoRetif/nrProc','',''})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/fimAfastamento/dtTermAfast','CM6_DTFAFA','CM6'})
		aAdd( aRet[nPos] ,{'S-2230','evtAfastTemp','/eSocial/evtAfastTemp/infoAfastamento/fimAfastamento/codMotAfast','CM6_MOTVAF','CM6'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2240'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/dtIniCondicao','CM9_DTINI','CM9'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/codAmb','T0Q_CODAMB','T0Q'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/infoAtiv/dscAtivDes','T0Q_DATIVD','T0Q'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/codFatRis','CMA_CODFAT','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/intConc','CMA_INTCON','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/tecMedicao','CMA_TECMED','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/utilizEPC','LEA_UTZEPC','LEA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/utilizEPI','LEA_UTZEPI','LEA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epc/dscEpc','LEB_DESEPC','LEB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epc/eficEpc','LEB_EFIEPC','LEB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/caEPI','CMB_CAEPI','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/eficEpi','CMB_EFIEPI','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/medProtecao','CMB_MEDPRT','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/condFuncto','CMB_CNDFUN','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/przValid','CMB_PRZVLD','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/periodicTroca','CMB_PERTRC','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/iniExpRisco/infoAmb/fatRisco/epcEpi/epi/higienizacao','CMB_HIGIEN','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/dtAltCondicao','CM9_DTALT','CM9'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/codAmb','T0Q_CODAMB','T0Q'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/infoAtiv/dscAtivDes','T0Q_DATIVD','T0Q'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/codFatRis','CMA_CODFAT','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/intConc','CMA_INTCON','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/tecMedicao','CMA_TECMED','CMA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/utilizEPC','LEA_UTZEPC','LEA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/utilizEPI','LEA_UTZEPI','LEA'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epc/dscEpc','LEB_DESEPC','LEB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epc/eficEpc','LEB_EFIEPC','LEB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/caEPI','CMB_CAEPI','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/eficEpi','CMB_EFIEPI','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/medProtecao','CMB_MEDPRT','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/condFuncto','CMB_CNDFUN','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/przValid','CMB_PRZVLD','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/periodicTroca','CMB_PERTRC','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/altExpRisco/infoAmb/fatRisco/epcEpi/epi/higienizacao','CMB_HIGIEN','CMB'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/fimExpRisco/dtFimCondicao','CM9_DTALT','CM9'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/fimExpRisco/infoAmb/codAmb','T0Q_CODAMB','T0Q'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/respReg/dtIni','T3S_DTINI','T3S'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/respReg/dtFim','T3S_DTFIM','T3S'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/respReg/nisResp','T3S_NISRES','T3S'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/respReg/nrOc','T3S_NROC','T3S'})
		aAdd( aRet[nPos] ,{'S-2240','evtExpRisco','/eSocial/evtExpRisco/infoExpRisco/respReg/ufOC','T3S_UFOC','T3S'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2241'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/iniInsalPeric/dtIniCondicao','T3B_DTINI','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/iniInsalPeric/infoAmb/codAmb','T3C_IDAMB','T3C'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/iniInsalPeric/infoAmb/fatRisco/codFatRis','T3D_IDFATR','T3D'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/altInsalPeric/dtAltCondicao','T3B_DTALT','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/altInsalPeric/infoamb/codAmb','T3C_IDAMB','T3C'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/altInsalPeric/infoamb/fatRisco/codFatRis','T3D_IDFATR','T3D'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/fimInsalPeric/dtFimCondicao','T3B_DTFIN','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/insalPeric/fimInsalPeric/infoAmb/codAmb','T3C_IDAMB','T3C'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/iniAposentEsp/dtIniCondicao','T3B_DTINI','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/iniAposentEsp/infoAmb/codAmb','T3C_IDAMB','T3C'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/iniAposentEsp/infoAmb/fatRisco/codFatRis','T3D_IDFATR','T3D'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/altAposentEsp/dtAltCondicao','T3B_DTALT','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/altAposentEsp/infoamb/codAmb','T3C_IDAMB','T3C'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/altAposentEsp/infoamb/fatRisco/codFatRis','T3D_IDFATR','T3D'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/fimAposentEsp/dtFimCondicao','T3B_DTFIN','T3B'})
		aAdd( aRet[nPos] ,{'S-2241','evtInsApo','/eSocial/evtInsApo/aposentEsp/fimAposentEsp/infoAmb/codAmb','T3C_IDAMB','T3C'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2245'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/ideVinculo/codCateg','C87_CODIGO','C87'})

		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/codTreiCap','V3C_CODCAT','V3C'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/obsTreiCap','V3C_OBSTCA','V3C'})

		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/infoComplem/dtTreiCap','V3C_DTTCAP','V3C'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/infoComplem/durTreiCap','V3C_DUTCAP','V3C'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/infoComplem/modTreiCap','V3C_MODTCA','V3C'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/infoComplem/tpTreiCap','V3C_TPTCAP','V3C'})

		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/cpfProf','V3G_CPF','V3G'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/nmProf','V3G_NOME','V3G'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/tpProf','V3G_TPPROF','V3G'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/formProf','V3G_FORMPR','V3G'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/codCBO','V3G_CODCBO','V3G'})
		aAdd( aRet[nPos] ,{'S-2245','evtTreiCap','/eSocial/evtTreiCap/treiCap/ideProfResp/nacProf','V3G_NACPRO','V3G'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2250'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/infoAvPrevio/detAvPrevio/dtAvPrv','CM8_DTAVIS','CM8'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/infoAvPrevio/detAvPrevio/dtPrevDeslig','CM8_DTAFAS','CM8'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/infoAvPrevio/detAvPrevio/tpAvPrevio','CM8_TPAVIS','CM8'})
		aAdd( aRet[nPos] ,{'S-2250','evtAvPrevio','/eSocial/evtAvPrevio/infoAvPrevio/detAvPrevio/observacao','CM8_OBSERV','CM8'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2298'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/tpReint','CMF_TPREIN','CMF'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/nrProcJud','CMF_NRPROC','CMF'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/nrLeiAnistia','CMF_NRLEIJ','CMF'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/dtEfetRetorno','CMF_DTRET','CMF'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/dtEfeito','CMF_DTEFEI','CMF'})
		aAdd( aRet[nPos] ,{'S-2298','evtReintegr','/eSocial/evtReintegr/infoReintegr/indPagtoJuizo','CMF_INDPGJ','CMF'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2299'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/mtvDeslig','CMD_MOTDES','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/dtDeslig','CMD_DTDESL','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/indPagtoAPI','CMD_INDPAG','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/dtProjFimAPI','CMD_TERAPI','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/pensAlim','CMD_PENALI','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/percAliment','CMD_PERALI','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/vrAlim','CMD_VLPALI','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/nrCertObito','CMD_NRATES','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/nrProcTrab','CMD_NRPROC','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/indCumprParc','CMD_INDCUM','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/observacao','CMD_OBSERV','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/sucessaoVinc/cnpjSucessora','CMD_CNPJSU','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/ideDmDev','T06_IDEDMD','T06'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/tpInsc','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/nrInsc','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/codLotacao','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/detVerbas/codRubr','T05_CODRUB','T05'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/detVerbas/ideTabRubr','T05_CODRUB','T05'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/detVerbas/qtdRubr','T05_QTDRUB','T05'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/detVerbas/vrUnit','T05_VLRUNI','T05'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/detVerbas/vrRubr','T05_VLRRUB','T05'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/cnpjOper','T15_CNPJOP','T15'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/regANS','T15_REGANS','T15'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/vrPgTit','T15_VLPGTI','T15'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/detPlano/tpDep','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/detPlano/cpfDep','T16_CPFDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/detPlano/nmDep','T16_NOMDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/detPlano/dtNascto','T16_DTNDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSaudeColet/detOper/detPlano/vlrPgDep','T16_VPGDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoAgNocivo/grauExp','T3G_GRAUEX','T3G'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerApur/ideEstabLot/infoSimples/indSimples','T3G_INDCSU','T3G'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/dtAcConv','T5I_DTACCO','T5I'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/tpAcConv','T5I_TPACCO','T5I'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/compAcConv','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/dtEfAcConv','T5I_DTEFAC','T5I'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/dsc','T5I_DSC','T5I'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/perRef','',''})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/tpInsc','T3G_ESTABE','T3G'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/nrInsc','T3G_ESTABE','T3G'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/codLotacao','T3G_LOTTRB','T3G'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/codRubr','T5S_CODRUB','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/ideTabRubr','T5S_CODRUB','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/qtdRubr','T5S_QTDRUB','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/fatorRubr','T5S_FATRUB','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/vrUnit','T5S_VLRUNI','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/detVerbas/vrRubr','T5S_VLRRUB','T5S'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/infoAgNocivo/grauExp','T5Q_GRAUEX','T5Q'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev/infoPerAnt/ideADC/idePeriodo/ideEstabLot/infoSimples/indSimples','T5Q_INDCSU','T5Q'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/procJudTrab/tpTrib','T3H_TPTRIB','T3H'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/procJudTrab/nrProcJud','T3H_IDPROC','T3H'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/procJudTrab/codSusp','T3H_IDSUSP','T3H'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/infoMV/indMV','CMD_INDMV','CMD'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/infoMV/remunOutrEmpr/tpInsc','C9J_TPINSC','C9J'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/infoMV/remunOutrEmpr/nrInsc','C9J_NRINSC','C9J'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/infoMV/remunOutrEmpr/codCateg','C9J_CODCAT','C9J'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/verbasResc/infoMV/remunOutrEmpr/vlrRemunOE','C9J_VLREMU','C9J'})
		aAdd( aRet[nPos] ,{'S-2299','evtDeslig','/eSocial/evtDeslig/infoDeslig/quarentena/dtFimQuar','CMD_DTQUA','CMD'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2300'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nmTrab','C9V_NOME','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/sexo','C9V_SEXO','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/racaCor','C9V_RCCOR','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/estCiv','C9V_ESTCIV','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/grauInstr','C9V_GRINST','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nmSoc','C9V_NOMSOC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/dtNascto','C9V_DTNASC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/codMunic','C9V_CODMUN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/uf','C9V_CODUF','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/paisNascto','C9V_CODPAI','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/paisNac','C9V_PAINAC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/nmMae','C9V_NOMMAE','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/nascimento/nmPai','C9V_NOMPAI','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CTPS/nrCtps','C9V_NRCTPS','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CTPS/serieCtps','C9V_SERCTP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CTPS/ufCtps','C9V_UFCTPS','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RIC/nrRic','C9V_NRRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RIC/orgaoEmissor','C9V_OREMRI','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RIC/dtExped','C9V_DTEXRI','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RG/nrRg','C9V_NRRG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RG/orgaoEmissor','C9V_OREMRG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RG/dtExped','C9V_DTEMRG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RNE/nrRne','C9V_NRRNE','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RNE/orgaoEmissor','C9V_OREMRN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/RNE/dtExped','C9V_DTEMRN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/OC/nrOc','C9V_NUMOC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/OC/orgaoEmissor','C9V_OREMOC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/OC/dtExped','C9V_DTEXOC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/OC/dtValid','C9V_DTVLOC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/nrRegCnh','C9V_NRCNH','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/dtExped','C9V_DTEXCN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/ufCnh','C9V_UFCNH','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/dtValid','C9V_DTVLCN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/dtPriHab','C9V_DTPCNH','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/documentos/CNH/categoriaCnh','C9V_CATCNH','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/tpLograd','C9V_TPLOGR','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/dscLograd','C9V_LOGRAD','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/nrLograd','C9V_NRLOG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/complemento','C9V_COMLOG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/bairro','C9V_BAIRRO','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/cep','C9V_CEP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/codMunic','C9V_MUN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/endereco/brasil/uf','C9V_MUN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/trabEstrangeiro/dtChegada','C9V_DTCHEG','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/trabEstrangeiro/classTrabEstrang','C9V_CCTRAE','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/trabEstrangeiro/casadoBr','C9V_CASBRA','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/trabEstrangeiro/filhosBr','C9V_FILBRA','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/defFisica','C9V_DEFFIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/defVisual','C9V_DEFVIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/defAuditiva','C9V_DEFAUD','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/defMental','C9V_DEFMEN','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/defIntelectual','C9V_DEFINT','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/reabReadap','C9V_REABIL','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/infoDeficiencia/observacao','C9V_OBSDEF','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/tpDep','C9V_TPDEP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/nmDep','C9V_NOMDEP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/dtNascto','C9V_DTNASC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/cpfDep','C9V_CPFDEP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/depIRRF','C9V_DEPIRF','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/depSF','C9V_DEPSFA','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/dependente/incTrab','C9V_INCTRB','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/contato/fonePrinc','C9V_FONPRC','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/contato/foneAlternat','C9V_FONALT','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/contato/emailPrinc','C9V_EMAILP','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/trabalhador/contato/emailAlternat','C9V_EMAILA','C9V'})
		//aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/codCateg','CUU_CATAV','CUU'})
		//aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/dtInicio','CUU_DTINCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/codCateg','C9V_CATCI','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/dtInicio','C9V_DTINIV','C9V'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/natAtividade','CUU_NATATV','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/cargoFuncao/codCargo','CUU_CARCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/cargoFuncao/codFuncao','CUU_FUNCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/remuneracao/vrSalFx','CUU_VLSLCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/remuneracao/undSalFixo','CUU_UNSLCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/remuneracao/dscSalVar','CUU_DSVRCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/fgts/opcFGTS','CUU_OPFGCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/fgts/dtOpcFGTS','CUU_DTFGCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoDirigenteSindical/categOrig','CUU_CATDS','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoDirigenteSindical/cnpjOrigem','CUU_CNPJDS','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoDirigenteSindical/dtAdmOrig','CUU_DTADDS','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoDirigenteSindical/matricOrig','CUU_MATODS','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/categOrig','CUU_CATSP','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/cnpjCednt','CUU_CNPJTC','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/matricCed','CUU_MATRCE','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/dtAdmCed','CUU_DTADTC','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/tpRegTrab','CUU','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/tpRegPrev','CUU','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoTrabCedido/infOnus','CUU_ONUSCE','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/natEstagio','CUU_NATEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/nivEstagio','CUU_NIVEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/areaAtuacao','CUU_AREAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/nrApol','CUU_NRAPES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/vlrBolsa','CUU_VLBLES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/dtPrevTerm','CUU_DTTEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/cnpjInstEnsino','CUU_CNPEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/nmRazao','CUU_NOMEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/dscLograd','CUU_LOGEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/nrLograd','CUU_NLGEES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/bairro','CUU_BAREES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/cep','CUU_CEPES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/codMunic','CUU_MUNES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/instEnsino/uf','CUU_UFES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/cnpjAgntInteg','CUU_CNPAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/nmRazao','CUU_NOMAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/dscLograd','CUU_LOGAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/nrLograd','CUU_NLGAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/bairro','CUU_BARAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/cep','CUU_CEPAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/codMunic','CUU_MUNAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/ageIntegracao/uf','CUU_UFAES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/supervisorEstagio/cpfSupervisor','CUU_CPFCES','CUU'})
		aAdd( aRet[nPos] ,{'S-2300','evtTSVInicio','/eSocial/evtTSVInicio/infoTSVInicio/infoComplementares/infoEstagiario/supervisorEstagio/nmSuperv','CUU_NOMCES','CUU'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2306'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/ideTrabSemVinculo/cpfTrab','T0F_CPF','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/ideTrabSemVinculo/nisTrab','T0F_NIS','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/ideTrabSemVinculo/codCateg','T0F_CATAV','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/dtAlteracao','T0F_DTALT','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/natAtividade','T0F_NATATV','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/cargoFuncao/codCargo','T0F_CARCI','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/cargoFuncao/codFuncao','T0F_FUNCI','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/remuneracao/vrSalFx','T0F_VLSLCI','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/remuneracao/undSalFixo','T0F_UNSLCI','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/remuneracao/dscSalVar','T0F_DSVRCI','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/natEstagio','T0F_NATEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/nivEstagio','T0F_NIVEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/areaAtuacao','T0F_AREAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/nrApol','T0F_NRAPES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/vlrBolsa','T0F_VLBLES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/dtPrevTerm','T0F_DTTEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/cnpjInstEnsino','T0F_CNPEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/nmRazao','T0F_NOMEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/dscLograd','T0F_LOGEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/nrLograd','T0F_NLGEES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/bairro','T0F_BAREES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/cep','T0F_CEPES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/codMunic','T0F_MUNES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/instEnsino/uf','T0F_UFES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/cnpjAgntInteg','T0F_CNPAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/nmRazao','T0F_NOMAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/dscLograd','T0F_LOGAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/nrLograd','T0F_NLGAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/bairro','T0F_BARAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/cep','T0F_CEPAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/codMunic','T0F_MUNAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/ageIntegracao/uf','T0F_UFAES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/supervisorEstagio/cpfSupervisor','T0F_CPFCES','T0F'})
		aAdd( aRet[nPos] ,{'S-2306','evtTSVAltContr','/eSocial/evtTSVAltContr/infoTSVAlteracao/infoComplementares/infoEstagiario/supervisorEstagio/nmSuperv','T0F_NOMCES','T0F'})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2399'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/ideTrabSemVinculo/nisTrab','C9V_NIS','C9V'})
		//aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg','CUU_CATCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg','C9V_CATCI','CUU'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/dtTerm','CUU_MOTDES','CUU'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/mtvDesligTSV','T3I_IDEDMD','T3I'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideDmDev','T3J_ESTABE','T3J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/tpInsc','T3J_ESTABE','T3J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/nrInsc','T3J_LOTTRB','T3J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/codLotacao','CMK_CODRUB','CMK'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/codRubr','',''})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/ideTabRubr','CMK_QTDRUB','CMK'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/qtdRubr','CMK_FATORR','CMK'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/fatorRubr','CMK_VLRUNI','CMK'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/vrUnit','CMK_VLRRUB','CMK'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/detVerbas/vrRubr','T15_CNPJOP','T15'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/cnpjOper','T15_REGANS','T15'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/regANS','T15_VLPGTI','T15'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/vrPgTit','',''})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/detPlano/tpDep','T16_CPFDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/detPlano/cpfDep','T16_NOMDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/detPlano/nmDep','T16_DTNDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/detPlano/dtNascto','T16_VPGDEP','T16'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSaudeColet/detOper/detPlano/vlrPgDep','T3J_GRAUEX','T3J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoAgNocivo/grauExp','T3J_INDCSU','T3J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev/ideEstabLot/infoSimples/indSimples','T3H_TPTRIB','T3H'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/procJudTrab/tpTrib','T3H_IDPROC','T3H'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/procJudTrab/nrProcJud','T3H_IDSUSP','T3H'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/procJudTrab/codSusp','CUU_INDMVI','CUU'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/infoMV/indMV','C9J_TPINSC','C9J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/infoMV/remunOutrEmpr/tpInsc','C9J_NRINSC','C9J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/infoMV/remunOutrEmpr/nrInsc','C9J_CODCAT','C9J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/infoMV/remunOutrEmpr/codCateg','C9J_VLREMU','C9J'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/infoMV/remunOutrEmpr/vlrRemunOE','CUU_DTQUA','CUU'})
		aAdd( aRet[nPos] ,{'S-2399','evtTSVTermino','/eSocial/evtTSVTermino/infoTSVTermino/quarentena/dtFimQuar','',''})

	EndIF

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2400'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/cpfBenef','T5T_CPF','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/nmBenefic','T5T_NOME','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/cpfBenef','T5T_CPF','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/nmBenefic','T5T_NOME','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/dtNascto','T5T_DTNASC','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/codMunic','T5T_CODMUN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/uf','T5T_CODUF','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/paisNascto','T5T_CODPAI','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/paisNac','T5T_PAINAC','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/nmMae','T5T_NOMMAE','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/dadosNasc/nmPai','T5T_NOMPAI','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/tpLograd','T5T_TPLOGR','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/dscLograd','T5T_LOGRAD','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/nrLograd','T5T_NRLOG','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/complemento','T5T_COMLOG','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/bairro','T5T_BAIRRO','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/cep','T5T_CEP','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/codMunic','T5T_MUN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/ideBenef/dadosBenef/endereco/brasil/uf','T5T_UF','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/tpPlanRP','T5T_TPPLRP','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/tpBenef','T5T_TPBENE','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/nrBenefic','T5T_NUMBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/dtIniBenef','T5T_DTINIB','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/vrBenef','T5T_VLRBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/infoPenMorte/idQuota','T5T_IDQUOT','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/iniBeneficio/infoPenMorte/cpfInst','T5T_CPFINS','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/tpBenef','T5T_TPBENE','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/nrBenefic','T5T_NUMBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/dtIniBenef','T5T_DTINIB','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/vrBenef','T5T_VLRBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/infoPenMorte/idQuota','T5T_IDQUOT','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/altBeneficio/infoPenMorte/cpfInst','T5T_CPFINS','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/fimBeneficio/tpBenef','T5T_TPBENE','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/fimBeneficio/nrBenefic','T5T_NUMBEN','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/fimBeneficio/dtFimBenef','T5T_DTINIB','T5T'})
		aAdd( aRet[nPos] ,{'S-2400','evtCdBenPrRP','/eSocial/evtCdBenPrRP/infoBeneficio/fimBeneficio/mtvFim','T5T_MTVFIM','T5T'})

	EndIF

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S3000'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/tpEvento','CMJ_TPEVEN','CMJ'} )
		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/nrRecEvt','CMJ_NRRECI','CMJ'} )
		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/ideTrabalhador/cpfTrab','CMJ_CPF','CMJ'} )
		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/ideTrabalhador/nisTrab','CMJ_NIS','CMJ'} )
		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/ideFolhaPagto/indApuracao','CMJ_INDAPU','CMJ'} )
		aAdd( aRet[nPos] , {'S-3000', 'evtExclusao', '/eSocial/evtExclusao/infoExclusao/ideFolhaPagto/perApur','CMJ_PERAPU','CMJ'} )

	EndIf

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S5001'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/ideTrabalhador/cpfTrab','T2M_CPFTRB','T2M'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/ideTrabalhador/procJudTrab/nrProcJud','T2N_IDPROC','T2N'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/ideTrabalhador/procJudTrab/codSusp','T2N_IDSUSP','T2N'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCpCalc/tpCR','T2O_IDCODR','T2O'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCpCalc/vrCpSeg','T2O_VRCPSE','T2O'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCpCalc/vrDescSeg','T2O_VRDESC','T2O'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/tpInsc','T2P_ESTABE','T2P'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/nrInsc','T2P_ESTABE','T2P'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/codLotacao','T2P_LOTACA','T2P'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/matricula','T2Q_MATRIC','T2Q'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/codCateg','T2Q_CODCAT','T2Q'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/indSimples','T2Q_INDCON','T2Q'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/infoBaseCS/ind13','T2R_INDDEC','T2R'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/infoBaseCS/tpValor','T2R_TPVLR','T2R'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/infoBaseCS/valor','T2R_VALOR','T2R'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/calcTerc/tpCR','T2S_IDCODR','T2S'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/calcTerc/vrCsSegTerc','T2S_VLRCON','T2S'} )
		aAdd( aRet[nPos] , {'S-5001', 'evtBasesTrab', '/eSocial/evtBasesTrab/infoCp/ideEstabLot/infoCategIncid/calcTerc/vrDescTerc','T2S_VLRDES','T2S'} )

	EndIF

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S5002'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtBasesTrab/ideTrabalhador/cpfTrab','T2M_CPFTRB','T2M'} )
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoDep/vrDedDep','T2G_CPFTRA','T2G'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/codCateg','T2H_CODCAT','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/indResBr','T2H_INDRES','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/basesIrrf/tpValor','T2I_CTPVAL','T2I'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/basesIrrf/valor','T2I_VLIRRF','T2I'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/irrf/tpCR','T2J_CTPCR','T2J'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/irrf/vrIrrfDesc','T2J_VLDESC','T2J'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/idePais/codPais','T2H_IDPAIS','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/idePais/indNIF','T2H_INDNIF','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/idePais/nifBenef','T2H_NIFBEN','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/dscLograd','T2H_DLOUGR','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/nrLograd','T2H_NUMLOG','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/complem','T2H_COMPLE','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/bairro','T2H_BAIRRO','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/nmCid','T2H_CIDADE','T2H'})
		aAdd( aRet[nPos] , {'S-5002', 'evtIrrfBenef', '/eSocial/evtIrrfBenef/infoIrrf/idePgtoExt/endExt/codPostal','T2H_CEP','T2H'})

	EndIf

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S5011'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/nrRecArqBase','T2V_IDARQB', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/indExistInfo','T2V_INDEXI', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoCPSeg/vrDescCP','T2V_VRDESC', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoCPSeg/vrCpSeg','T2V_VRCPSE', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/classTrib','T2V_IDCLAS', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/indCoop','T2V_INDCOO', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/indConstr','T2V_INDCON', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/indSubstPatr','T2V_INDPAT', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/percRedContrib','T2V_PERCON', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/infoAtConc/fatorMes','T2V_FATMES', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoContrib/infoPJ/infoAtConc/fator13','T2V_FATDEC', 'T2V'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/tpInsc','T2X_TPINSE', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/nrInsc','T2X_NRINSE', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoEstab/cnaePrep','T2X_CNAEPR', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoEstab/aliqRat','T2X_ALIRAT', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoEstab/fap','T2X_FAP',     'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoEstab/aliqRatAjust','T2X_ALIAJU', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoEstab/infoComplObra/indSubstPatrObra','T2X_INDPAT', 'T2X'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/codLotacao','T2Y_LOTTRB', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/fpas','T2Y_FPAS', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/codTercs','T2Y_FPAS', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/codTercsSusp','T2Y_TERSUS', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoTercSusp/codTerc','T0E_CODTER', 'T0E'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoEmprParcial/tpInscContrat','T2Y_TPINCO', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoEmprParcial/nrInscContrat','T2Y_NRINCO', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoEmprParcial/tpInscProp','T2Y_TPINPR', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoEmprParcial/nrInscProp','T2Y_NRINPR', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/dadosOpPort/cnpjOpPortuario','T2Y_CNPJOP', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/dadosOpPort/aliqRat','T2Y_ALIRAT', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/dadosOpPort/fap','T2Y_FAP', 	   'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/dadosOpPort/aliqRatAjust','T2Y_ALRATF', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/indIncid','T2Z_INDINC', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/codCateg','T2Z_CODCAT', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrBcCp00','T2Z_VLBCCP', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrBcCp15','T2Z_VLBCAQ', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrBcCp20','T2Z_VLBCAV', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrBcCp25','T2Z_VLBCVC', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSuspBcCp00','T2Z_VLSUBC', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSuspBcCp15','T2Z_VLSUBQ', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSuspBcCp20','T2Z_VLSUBV', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSuspBcCp25','T2Z_VLSUVC', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrDescSest','T2Z_VLDESE', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrCalcSest','T2Z_VLCASE', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrDescSenat','T2Z_VLDESN', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrCalcSenat','T2Z_VLCASN', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSalFam','T2Z_VLSAFA', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp/vrSalMat','T2Z_VLSAMA', 'T2Z'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcCp00','T2Y_VRBCCP', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcCp15','T2Y_VRBCCQ', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcCp20','T2Y_VRBCCV', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcCp25','T2Y_VRBCVQ', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcCp13','T2Y_VRBCCT', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrBcFgts','T2Y_VRBCFG', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort/vrDescCP','T2Y_VRDESC', 'T2Y'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoSubstPatrOpPort/cnpjOpPortuario','T0A_CNPJOP', 'T0A'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/indAquis','T70_INDAQU', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vlrAquis','T70_VLAQUI', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrCPDescPR','T70_VLCPPR', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrCPNRet','T70_VLCPRE', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrRatNRet','T70_VLRATN', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrSenarNRet','T70_VLSENR', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrCPCalcPR','T70_VLCPCA', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrRatDescPR','T70_VLRAPR', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrRatCalcPR','T70_VLRACA', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrSenarDesc','T70_VLSEDE', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesAquis/vrSenarCalc','T70_VLSECA', 'T70'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesComerc/indComerc','T0B_INDCOM', 'T0B'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesComerc/vrBcComPR','T0B_VLBCCO', 'T0B'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesComerc/vrCPSusp','T0B_VLCPSU', 'T0B'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesComerc/vrRatSusp','T0B_VLRASU', 'T0B'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/basesComerc/vrSenarSusp','T0B_VLSESU', 'T0B'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoCREstab/tpCR','T0C_IDCODR', 'T0C'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoCREstab/vrCR','T0C_VLCOCR', 'T0C'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/ideEstab/infoCREstab/vrSuspCR','T0C_VLSUCR', 'T0C'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoCRContrib/tpCR','T0D_IDCODR', 'T0D'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoCRContrib/vrCR','T0D_VRCOCR', 'T0D'})
		aAdd( aRet[nPos] , {'S-5011', 'evtCS', '/eSocial/evtCS/infoCS/infoCRContrib/vrCRSusp','T0D_VRCRSU', 'T0D'})

	EndIf

	If Empty(AllTrim(cEvento)) .Or. cEvento == 'S5012'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] , {'S-5012', 'evtIrrf', '/eSocial/evtIrrf/infoIRRF/nrRecArqBase','T0G_NRARQB', 'T0G'})
		aAdd( aRet[nPos] , {'S-5012', 'evtIrrf', '/eSocial/evtIrrf/infoIRRF/indExistInfo','T0G_INDEXI', 'T0G'})
		aAdd( aRet[nPos] , {'S-5012', 'evtIrrf', '/eSocial/evtIrrf/infoIRRF/infoCRContrib/tpCR','T0H_IDCODR', 'T0H'})
		aAdd( aRet[nPos] , {'S-5012', 'evtIrrf', '/eSocial/evtIrrf/infoIRRF/infoCRContrib/vrCR','T0H_VRCOCR', 'T0H'})

	EndIf

	If Empty(AllTrim(cEvento)) .or. cEvento == 'S2260'

		aAdd(aRet, {})
		nPos	:=	Len(aRet)

		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/ideVinculo/cpfTrab','C9V_CPF','C9V'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/ideVinculo/nisTrab','C9V_NIS','C9V'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/ideVinculo/matricula','C9V_MATRIC','C9V'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/codConv','T87_CONVOC','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/dtInicio','T87_DTINIP','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/dtFim','T87_DTFIMP','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/jornada/codHorContrat','T87_CODHOR','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/jornada/dscJornada','T87_DTPJOR','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/indLocal','T87_LOCTRB','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/tpLograd','T87_TPLOGR','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/dscLograd','T87_LOGRAD','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/nrLograd','T87_NRLOG','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/complem','T87_COMLOG','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/bairro','T87_BAIRRO','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/cep','T87_CEP','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/codMunic','T87_MUN','T87'})
		aAdd( aRet[nPos] ,{'S-2260','evtConvInterm','/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf','T87_UF','T87'})

	EndIF

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafNorStrES

Altera caracteres descritos no manual do desenvolvedor e-Social para
o formato especificado no mesmo.

@Author	Evandro dos Santos Oliveira Teixeira
@Since	28/11/2017
@Version 1.0

@param cString  -> String a ser convertida
@param nConvert -> Modo de Conversão
				   1 - Converte
				   2 - Desconverte

@return cAlter -> String Convertida
/*/
//---------------------------------------------------------------------
Function TafNorStrES(cString as character, nConvert as numeric)
	
	Local aMapChar		as array
	Local cAlter		as character
	Local nChar 		as numeric
	Local nConv 		as numeric

	Default cString		:= ""
	Default nConvert 	:= 1

	aMapChar	:= {}
	cAlter		:= cString
	nChar		:= 1
	nConv		:= 2

	If nConvert == 1
		AAdd(aMapChar, {"&", "&amp;"}) // Deve ser executado primeiro na opção 1
	EndIf
		
	AAdd(aMapChar, {">", "&gt;"		})
	AAdd(aMapChar, {"<", "&lt;"		})
	AAdd(aMapChar, {'"', "&quot;"	})
	AAdd(aMapChar, {"'", "&apos;"	})
	
	If nConvert == 2
		AAdd(aMapChar, {"'", "#39;"	}) // Só deve ser executado na opção 2
		AAdd(aMapChar, {"&", "&amp;"}) // Deve ser executado por último na opção 2
	
		nChar := 2
		nConv := 1
	EndIf

	AEval(aMapChar, {|x| cAlter := StrTran(cAlter, x[nChar], x[nConv])})

Return cAlter

//---------------------------------------------------------------------
/*/{Protheus.doc} TafXNode

Função que contempla a estrutura de decisão para a relação Owner/Tag/Action.

@Author	Roberto Souza
@Since	19/12/2017
@Version 1.0

@param oDados     	-> Objeto xml do evento
@param cCodEvent	-> Codigo do evento
@param cOwner		-> Dono da Tag

	-Parametros da função encapsulada XPathHasNode()
@param cNode	-> Caminho completo do node
@param cNode2	-> Caminho completo do node (Informado na Tabelas de Grid)

@return lret	    -> Valida a inclusão/exclusao
/*/
//---------------------------------------------------------------------
Function TafXNode( oDados, cCodEvent, cOwner, cNode, cNode2 )

	Local lRet 		:= .F.

	Default cOwner	:= ''
	Default cNode 	:= ''
	Default cNode2  	:= ''

	//Caso a tabela não exista, ou se não encontrar o registro a ser gravado, considero o comportamento padrão.
	If ! ( Type( "oHMControl" ) == "U" )

		// Tratamento para verificar se trata a tag
		// Verifica se foi mandada a TAG
		lTag := oDados:XPathHasNode( cNode )

		//Caso não seja informado o segundo parâmetro de nó, eu recebo o primeiro
		If Empty(cNode2)
			cNode2 := cNode
		EndIf

		// Verifica as regras
		If ExistNodeRule( cOwner, cNode2, lTag, cCodEvent )
			lRet := .T.
		EndIf

	// Se não está ativo, verifica com a regra do legado
	Else
		lRet := oDados:XPathHasNode( cNode )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ExistNodeRule

Função que verifica a existencia de regras para tags.

@Author	Roberto Souza
@Since	19/12/2017
@Version 1.0

@param cOwner		-> Parametros da função encapsulada XPathHasNode()
@param cNode	    -> Dono da Tag
@param lTag		-> Status de enviada a tag ou nao
@param cCodEvent	-> Codigo do evento
@param cNode2     -> TAG sem a numeração da linha no xml

@return lret	    -> String Convertida
/*/
//---------------------------------------------------------------------
Static Function ExistNodeRule( cOwner, cNode, lTag, cCodEvent )

	Local lRet		:= .F.
	Local aVal		:= {}
	Local cKeyHMT93	:= ""
	Local cKeyHMT94	:= ""

	cNode 		:= AllTrim(Upper(cNode))
	cKeyHMT93 	:= AllTrim( cCodEvent )
	cKeyHMT94 	:= AllTrim( cCodEvent )+AllTrim( cNode )


	If HMGet( oHMControl, cKeyHMT94, @aVal )

		If aVal[POS_ATIVO] == "1"

			If AllTrim( aVal[POS_PROPRI] ) == AllTrim( cOwner )	.Or. Empty(AllTrim(aVal[POS_PROPRI] ))
				If aVal[POS_ACTION] == '1'
					lRet := .T.
				EndIf
			Else
				lRet := .F.
			EndIf

		Else
			lRet := .T.
		EndIf

	ElseIf	HMGet( oHMControl, cKeyHMT93, @aVal )

		If aVal[POS_ATIVO] == "1"

			If aVal[POS_DEFAULT] == '1'
				lRet := .T.
			ElseIf lTag
				lRet := .T.
			EndIf

		Else
			lRet := .T.
		EndIf

	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXmlReinf
@type			function
@description	Função que retorna o XML com o cabeçalho para cada evento do Reinf. Deve estar posicionado no registro desejado.
@author			Felipe C. Seolin
@since			23/01/2018
@version		1.0
@param			cXMLLayout	-	XML específico do Layout
@param			cAlias		-	Alias para buscar informações do cabeçalho
@param			cLayout		-	Layout sem o "R-" / Exemplo: R-2010 -> "2010"
@param			cTagReg		-	Nome da tag do evento
@param			xPeriodo	-	Período de Apuração / Data da Apuração
@param			cSeq		-	Número sequencial implementado para distinguir os registro enviados na mesma data/hora
@return			cXml 		- 	Estrutura final do XML
/*/
//---------------------------------------------------------------------
Function TAFXmlReinf( cXMLLayout, cAlias, cLayout, cTagReg, xPeriodo, cSeq, cTagName, lRemContri)

	Local cTipo			:= ""
	Local cXml			:= ""
	Local cIdeEvento	:= ""
	Local cCGC			:= AllTrim( SM0->M0_CGC )
	Local cTpInscr		:= Iif( Len( cCGC ) == 14, "1", "2" )
	Local cIdNtJur		:= Posicione( "C1E", 3, xFilial( "C1E" ) + Padr( Alltrim(SM0->M0_CODFIL) , _TmFilTAF, " " ) + "1", "C1E_NATJUR" )
	Local cNatJur		:= Posicione( "C8P", 1, xFilial( "C8P" ) + cIdNtJur, "C8P_CODIGO" )
	Local lOrgPub		:= !empty( cNatJur ) .and. ( cNatJur == "1015"  .or. cNatJur == "1040"  .or. cNatJur == "1074"  .or. cNatJur == "1163" .or. cNatJur == "1341" )
	Local cId			:= "ID" + cTpInscr + Iif( cTpInscr == "2", PadR( SubStr( cCGC, 1, 11 ), 14, "0" ), Iif( lOrgPub, cCGC, PadR( SubStr( cCGC, 1, 8 ), 14, "0" ) ) ) + DToS( Date() ) + StrTran( Time(), ":", "" )
	Local cVerProc		:= ""
	Local cTpAmb		:= SuperGetMv( "MV_TAFAMBR", .F., "2" )
	Local cPathURL		:= "http://www.reinf.esocial.gov.br/schemas/"
	Local cVerSchema	:= SuperGetMv( "MV_TAFVLRE", .F., "1_03_00" )
	Local cNameSpace	:= ""
	Local cTagInicio	:= ""
	Local cNumFinal		:= ""
	Local nQtdRand		:= 0
	Local nX			:= 1
	Local aEvento		:= TAFRotinas( "R-" + cLayout, 4, .F., 5 )

	Default cSeq		:=	""
	Default cTagName	:=	cTagReg
	Default lRemContri	:= .F.

	cVerProc	:= Iif (lRemContri, "RemoverContribuinte", "1.0")
	cNameSpace	:= cPathURL + "evt" + cTagName + "/v" + cVerSchema
	cTagInicio	:= '<Reinf xmlns="' + cNameSpace + '">'

	//Se o sequencial passado mais o id for = 36, então não precisar gerar um randomico
	If Len(cSeq + cId) == 36
		cId += cSeq
	EndIf

	//Se o tamanho do id for menor que 36 então gera um randomico novo para compor o tamanho do id
	If Len(cId) < 36
		nQtdRand := 36 - Len(cId)

		For nX := 1 to nQtdRand
			cNumFinal += "9"
		Next nX

		cId	 += StrZero( Randomize( 1, Val(cNumFinal) ), nQtdRand )
	EndIf

	//-------- Tratamento para utilizar sempre o mesmo ID no envio e gera
	If TAFColumnPos( cAlias+"_XMLID" )
		cIdAnt := (cAlias)->&(cAlias+"_XMLID")
		If Empty( cIdAnt )
			RecLock( cAlias , .F.)
			(cAlias)->&(cAlias+"_XMLID") := cId
			MsUnlock()
		Else
			cId := AllTrim( cIdAnt )
		EndIf
	EndIf

	If aEvento[12] == "C"
		cTipo := "TABELA"
	ElseIf aEvento[12] == "M"
		cTipo := "MENSAL"
	ElseIf aEvento[12] == "E"
		cTipo := "EVENTO"
	ElseIf aEvento[12] == "T"
		cTipo := "TOTALIZADORES"
	EndIf

	If cTipo $ "MENSAL"

		If ( cAlias )->( &( cAlias + "_EVENTO" ) ) $ "I"
			cIdeEvento += xTafTag( "indRetif", "1" )
		Else
			cIdeEvento += xTafTag( "indRetif", "2" )
			cIdeEvento += xTafTag( "nrRecibo", AllTrim(( cAlias )->( &( cAlias + "_PROTPN" ))) )

		EndIf

		cIdeEvento += xTafTag( "perApur", xPeriodo )

	ElseIf cTipo $ "EVENTO"

		If cLayout $ "2098|2099|4099"
			cIdeEvento += xTafTag( "perApur", xPeriodo )
		Else
			If !( cLayout $ "9000|2098|2099|4099" )
				If ( cAlias )->( &( cAlias + "_EVENTO" ) ) $ "I"
					cIdeEvento += xTafTag( "indRetif", "1" )
				Else
					cIdeEvento += xTafTag( "indRetif", "2" )
					cIdeEvento += xTafTag( "nrRecibo", Alltrim(( cAlias )->( &( cAlias + "_PROTPN" ))) )

				EndIf

				cIdeEvento += xTafTag( "dtApuracao", xPeriodo )
			EndIf
		EndIf

	ElseIf cTipo $ "TOTALIZADORES"

		cIdeEvento += xTafTag( "perApur", xPeriodo )

	EndIf

	cXml += cTagInicio
	cXml += 	"<evt" + cTagReg + " id='" + cId + "'>"
	cXml += 		"<ideEvento>"
	cXml += 			cIdeEvento

	If !( cTipo  $ "TOTALIZADORES" )
		cXml += 		xTafTag( "tpAmb", cTpAmb )
		cXml += 		xTafTag( "procEmi", "1" )
		cXml += 		xTafTag( "verProc", cVerProc )
	EndIf

	cXml += 		"</ideEvento>"

	cXml += 		"<ideContri>"
	cXml += 			xTafTag( "tpInsc", cTpInscr )
	cXml += 			xTafTag( "nrInsc", Iif( cTpInscr == "1", Iif( lOrgPub, cCGC, SubStr( cCGC, 1, 8 ) ), cCGC ) )

	If cLayout $ "2030|2040|3010"
		cXml += 		cXMLLayout
		cXml += 	"</ideContri>"
	Else
		cXml += 	"</ideContri>"
		cXml += 	cXMLLayout
	EndIf

	cXml += 	"</evt" + cTagReg + ">"
	cXml += "</Reinf>"

Return( cXml )

/*/{Protheus.doc} ReavPen
//Função para retornar os IDS que estão no browse para serem reavaliados.
@author osmar.junior
@since 09/10/2018
@version 1.0
@return ${return}, ${Retorna string que será utilizada como filtro da query principal}
@param cLayout, characters, Layout a ser avaliado (S-3000,S-1200)
@param cAliasTb, characters, Nome da tabela que representa o evento
@type function
/*/
Static Function ReavPen(cLayout,cAliasTb)

	Local cQry 	:= ''
	Local cTabMbr	:= ''
	Local cIds		:= ''
	local cWhere	:= ''

	If cLayout $ "S-3000"

		cTabMbr := oMBrowse:oData:oTempDB:GetRealName()

		cQry := " SELECT ID FROM " + cTabMbr + " WHERE EVENTO = '" + cLayout + "'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),'ArqCount', .F., .T. )
		If ArqCount->(!Eof())
			While ArqCount->(!Eof())
				cIds += "'" +ArqCount->ID + "',"
				ArqCount->( dbSkip() )
			EndDo
			cWhere := " AND "+cAliasTb+"_ID IN (" + SUBSTR(cIds,1,LEN(cIds)-1) + ")"
		EndIf

		ArqCount->(dbCloseArea())

	EndIf

Return cWhere

/*/{Protheus.doc} EventReava
//TODO Descrição auto-gerada.
@author osmar.junior
@since 10/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function EventReava()

	Local aEventReav	:= {}
	Local cQry 	:= ''
	Local cTabMbr	:= ''

	cTabMbr := oMBrowse:oData:oTempDB:GetRealName()

	cQry := " SELECT DISTINCT EVENTO FROM " + cTabMbr
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),'ArqTempAux', .F., .T. )

	If ArqTempAux->(!Eof())

		While ArqTempAux->(!Eof())

			AADD(aEventReav, ArqTempAux->EVENTO)
			ArqTempAux->( dbSkip() )

		EndDo

	EndIf

	ArqTempAux->(dbCloseArea())

Return aEventReav

//---------------------------------------------------------------------
/*/{Protheus.doc} XmlErpxTaf

Exibe o XML enviado do ERP junto com o XML gerado pelo TAF.

@Param	cAlias - Alias da tabela posicionada no Browse
@Param	cFunGerXml - Função que gera o XML do TAF.
@Param	cLayout - Layout do evento.

@Author	Eduardo Sukeda
@Since		03/07/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function XmlErpxTaf(cAlias, cFunGerXml, cLayout, cFilReg)

	Local oModal		:= Nil
	Local aButtons 		:= {}
	Local cXmlTaf 		:= FwCutOff(&(cFunGerXml + "(,,,.T.)"))
	Local cXmlErp 		:= FwCutOff(GetXmlSt2(cAlias, (cAlias)->(Recno()), cFilReg  ))
	Local lWebApp		:= Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5,.F.)
	Local lRemote		:= getRemoteType() == REMOTE_HTML
	Local cSize			:= IIF(lRemote .Or. lWebApp,'2','5')
	Local cTitleErp		:= '<font size="' + cSize + '" color="#0c9abe"><b>Xml ERP</b></font>'
	Local cTitleTaf		:= '<font size="' + cSize + '" color="#0c9abe"><b>Xml TAF</b></font>'
	Local aArea			:= (cAlias)->(GetArea())

	Default cAlias 		:= ""
	Default cFunGerXml 	:= ""
	Default cLayout 	:= ""

	If findFunction(cFunGerXml)

		If !Empty(cXmlErp)

			aAdd(aButtons,{'', STR0029,{||xTafGerXml(cXmlErp, StrTran(cLayout, "S-", ""),,,,,,,,.T.)}, STR0029,0,.T.,.T.}) //"Gerar Xml ERP"
			aAdd(aButtons,{'', STR0030,{||&(cFunGerXml + "( )") 				 				    }, STR0030,0,.T.,.T.}) //"Gerar Xml TAF"

			oModal := FWDialogModal():New()
			oModal:SetTitle( STR0033 ) //"Xml ERP x TAF"
			oModal:SetFreeArea( 500, 200 )
			oModal:SetEscClose( .T. )
			oModal:SetBackground( .T. )
			oModal:CreateDialog()
			oModal:AddCloseButton()
			oModal:AddButtons(aButtons)

			TMultiGet():New( 010, 020, { || xIdentXML(cXmlErp) }, oModal:GetPanelMain(), 220, 170,, .T. ,,,, .T.,,,,,, .T.,,,,, .T., cTitleErp, 1 )
			TMultiGet():New( 010, 260, { || xIdentXML(cXmlTaf) }, oModal:GetPanelMain(), 220, 170,, .T. ,,,, .T.,,,,,, .T.,,,,, .T., cTitleTaf, 1 )

			oModal:Activate()

		Else

			MsgInfo(STR0031, STR0032) //"Não foram encontrados registros enviados de seu ERP !", "Registros não encontrados"

		EndIf

		RestArea(aArea)

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetXmlSt2

Exibe o XML enviado do ERP junto com o XML gerado pelo TAF.

@Param 	cAlias - Alias da tabela do Browse
@Param	nRecno - Recno posicionado no Browse
@Param  cFilReg- Filial do registro inserido (Referencia do campo Filial - _FILIAL)

@Author	Eduardo Sukeda
@Since		03/07/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GetXmlSt2(cAlias as Character, nRecno as Numeric, cFilReg as Character)

	Local cSelect 		as character
	Local cFrom   		as character 
	Local cWhere  		as character 
	Local cMsg			as character
	Local cTable		as character
	LocaL cFilTAF       as character
	Local cAliasQry 	as character
	Local cAliasST2		as character
	Local aAreaST2		as Array

	cSelect 		:= ""
	cFrom   		:= ""
	cWhere  		:= ""
	cMsg			:= ""
	cTable		    := "TAFST2"
	cFilTAF         := ""
	cAliasQry 	    := GetNextAlias()
	cAliasST2		:= GetNextAlias()
	aAreaST2		:= {}

	Default cAlias 	:= ""
	Default cFilReg := ""
	Default nRecno 	:= 0
	
	C1E->( DBSetOrder( 3 ) )
	If C1E->( DbSeek( PadR( "", TamSX3("C1E_FILIAL")[1] ) + PadR( cFilReg, TamSX3("C1E_FILTAF")[1] ) + "1" ) )
		cFilTAF := C1E->C1E_CODFIL
	EndIf

	cSelect := "ST2.R_E_C_N_O_ "
	cFrom   := "TAFST2 ST2 "
	cFrom   += "INNER JOIN "
	cFrom   += "   TAFXERP XERP  "
	cFrom   += "   ON XERP.TAFKEY = ST2.TAFKEY  "
	cFrom   += "   AND XERP.TAFTICKET = ST2.TAFTICKET  "
	cFrom   += "    AND XERP.D_E_L_E_T_ = ' '  "
	cFrom   += "    AND XERP.TAFRECNO = '" + AllTrim(Str(nRecno)) + "'  "
	cFrom   += "    AND XERP.TAFALIAS = '" + cAlias + "'  "
	cWhere  += " ST2.D_E_L_E_T_ = ' ' "
	cWhere  += " AND ST2.TAFFIL = '" + cFilTAF + "'  "
	cWhere  += " ORDER BY XERP.R_E_C_N_O_ DESC "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"
	cWhere  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	EndSql

	If ( cAliasQry ) -> (!Eof()) .And. ( cAliasQry )->(R_E_C_N_O_) > 0

		If FOpnTabTAf( cTable, cAliasST2 )

			aAreaST2 :=	( cAliasST2 )->( GetArea() )
			(cAliasST2)->(DbGoTo(( cAliasQry )->(R_E_C_N_O_)))
			cMsg := AllTrim((cAliasST2)->TAFMSG)

		EndIf

		( cAliasST2 )->( DbCloseArea() )

	EndIf

	( cAliasQry )->( DbCloseArea() )

	If Len(aAreaST2) > 0

		RestArea( aAreaST2 )
		TAFEncArr( @aAreaST2 )

	EndIf

Return cMsg

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFSmartLote

Função para gerar XML a partir do SMARTERP/WEBAPP.
Sendo feito o download em arquivo ".ZIP" quando Gerar em LOTE

@Param 	cPath - Alias da tabela do Browse
@Param	aArquivos - array com nome dos arquivos a serem compactados 

@Author	Márcio Pereira dos Santos
@Since		29/08/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFSmartXML(cPath, aArquivos, cLayout,lAutomato)

	Local cFileZip	:= ""
	Local nHandle 	:= 0
	Local nx 		:= 0
	Local cMsgProc  := ""

	Default cPath 	  := ""
	Default aArquivos := {}
	Default cLayout	  := ""
	Default lAutomato := .f.

	If Len(aArquivos ) > 1

		//Processo para gerar XML em LOTE a partir do SMARTERP/WEBAPP.
		cFileZip := cPath+lower(cLayout)+"_"+DToS(Date())+"_"+SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+".zip"

		// Gera arquivo ZIP
		nHandle :=  FZip(cFileZip,aArquivos,cPath)

		If nHandle == 0 .or. lAutomato

			nHandle := iif(lAutomato,-1,CpyS2TW(cFileZip , .T. ))

			If (nHandle == 0)
				MsgAlert("Download concluído com sucesso.")
			Else
				TAFConOut("Falha na copia " + str(nHandle), 2, .T., "XMLFUN" )
			EndIf

			// Apaga arquivos
			For nx := 1 to Len(aArquivos)

				If File(aArquivos[nx])
					FERASE(aArquivos[nx])
				EndIf

			Next nx

			If File(cFileZip)
				FERASE(cFileZip)
			EndIf

			cMsgProc	:=	STR0027	//"Processamento finalizado com sucesso."

		Else
			MsgStop("Não foi possível criar o arquivo zip.")
		EndIf

	Elseif Len(aArquivos ) > 0

		nHandle := iif(lAutomato,-1,CpyS2TW( aArquivos[1] , .T. ))

		If (nHandle == 0)
			MsgAlert("Download concluído com sucesso.")
		Else
			TAFConOut("Falha na copia " + str(nHandle), 2, .T., "XMLFUN" )
		EndIf

		Ferase(aArquivos[1])

	EndIf

Return cMsgProc

//-------------------------------------------------------------------
/*/{Protheus.doc} TafXmlTss
Tela para gerar XML RET

@author  José Riquelmo
@since   13/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAfxmltss(cAlias,nRecno)

	Local cTeste		:= "Gerar XML de Retorno ?"
	Local cTpXml		:= "Selecione o  tipo do XML"
	Local aItems		:= {"1-XML TAF","2-XML RET"}
	Local lCloseDlg		:= .F.
	Local lOK 			:= .F.

	Define MsDialog oDlg From 0 ,0 To 235,300 Pixel Title OemToAnsi(cTeste)

	oFont1 := TFont():New("Tahoma",,-12,.T.)

	oPanel := TPanel():New(70,80,'<br><br><br><br><br><br><br><br><br><br> &nbsp;&nbsp; 1- XML gerado pelo TAF<br>'+;
							' &nbsp;&nbsp; 2- XML retornado pelo Governo';
							,oDlg,,.F.,.F.,,CLR_WHITE,70,80,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oTSay2 	:= TSay():New(20,42,{||cTpXml},oPanel,,oFont1,,,,.T.,CLR_BLUE,,150,020,,,,,,.T.) //"Escolha"

	oCombo:= aItems[2] //XMLS
	oCombo := TComboBox():New(65,35,{|u|if(PCount()>0,oCombo:=u,oCombo)},;
		aItems,85,45,oDlg,,{||},,,,.T.,,,,,,,,,'oCombo')

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()};
		,{||oDlg:End(),lCloseDlg := .F.,lCloseDlg := .T.,oDlg:End()};
		,,,,,.F.,.F.,.F.,.T.,.F.))

Return  {lOk,oCombo}

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxmlRet
Função responsável pela geração do XML de Retorno.
@author  José Riquelmo Gomes da Silva
@since   19/03/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxmlRet(cFunctionXML,cLayout,cAlias)

	Local aXmls         := {}
	Local aRet          := {}
	Local cXml			:= ""
	Local aGerXml		:= {}
	Local aArea 		:= GetArea()

	Default cFunctionXML := ""
	Default cLayout		 := ""
	Default cAlias	     := ""

	cLayoutForm  :=  StrTran(cLayout,"S-","",,)

	DbSelectArea(cAlias)

	If !Empty((cAlias)->&(cAlias+"_ID"))

		aGerXml := IIF(FindFunction('TAfxmltss'),TAfxmltss(),{})

		If Len(aGerXml) > 0

			lGerXml := aGerXml[1]
			cOpcXML := aGerXml[2]

			If lGerXml .AND. cOpcXML == "1-XML TAF"

				If cFunctionXML == "TAF050XML"
					&(cFunctionXML + "('C1E')")
				Else
					&(cFunctionXML + "()")
				EndIf

			ElseIf lGerXml .AND. cOpcXML == "2-XML RET"

				cTSSKey := "S" + cLayoutForm + AllTrim( (cAlias)->&(cAlias+"_ID") ) + AllTrim( (cAlias)->&(cAlias+"_VERSAO") )
				aAdd( aXmls, cTSSKey )
				aRet := TAFGETXMLTSS(aXmls)

				If len(aRet) > 0

					cXml := aRet[1][4]

					If !Empty(cXml)
						xTafGerXml( cXml, cLayoutForm )
					Else
						MsgInfo("Verifique se o evento está transmitido.","XML não encontrado.")
					EndIf

				EndIf

			EndIf

		EndIf

	Else

		MsgInfo('Apenas a operação de incluir registros<br> pode ser feita em um arquivo vazio.','Arquivo Vazio')

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} fRetEvtBlq
Rotina que retira os eventos esocial que não estão cadastrados no 
@type function
@version 
@author eduardo.vicnete
@since 20/05/2020
@param aEventos, array, eventos X rotinas
@return return_type, não retorna nenhuma informação, apenas tratamento no aEventos por referências
/*/
Static Function fRetEvtBlq(aEventos,cEventos)

	Local nRetEvt   := 1

	Default aEventos    := {}

	While nRetEvt <= Len(aEventos)

		If ( !ALLTRIM(aEventos[nRetEvt][4]) $ cEventos )

			aDel(aEventos , nRetEvt)
			aSize(aEventos,Len(aEventos)-1)

		Else

			nRetEvt++

		EndIf

	EndDo

Return NIL

/*/{Protheus.doc} getMotiveId
Rotina que retorna os Ids dos códigos de motivo de afastamento
@type function
@version 
@author almeida.veronica
@since 13/11/2020
@param aMotiveCode, array, codigo dos motivos de afastamento
@param cMotiveCode, string, id dos motivos de afastamento

/*/
Static Function getMotiveId(aMotiveCode,cMotiveCode)

	Local cAlias	:= getNextAlias()
	Local cCod		:= ""
	Local nX		:= 0

	cMotiveCode	:= ""

	If Len(aMotiveCode) > 0

		For nX := 1 To Len(aMotiveCode)
			cCod += iIF(nX > 1,'|','') + aMotiveCode[nX]
		Next nX

		cCod := formatIn(cCod, "|")
		cCod := "% " + cCod + " %"

		BeginSql alias cAlias
			SELECT C8N_ID
			FROM %table:C8N% C8N
			WHERE 	C8N_CODIGO IN %Exp:cCod%
				AND C8N.%NotDel% 
		EndSql

		If (cAlias)->(!EOF())

			While (cAlias)->(!EOF())

				cMotiveCode += 	iif(Empty(cMotiveCode),'','|') + (cAlias)->C8N_ID

				(cAlias)->(DbSkip())

			EndDo

		EndIf

	EndIf

Return

//------------------------------------------------------------------------------------
/*/{Protheus.doc} PgtFilPer
Interface com filtro genérico nos MVCs de Eventos Periódicos, 
para facilitar a extração do xml em lote.

@param cTab     nome tabela
@param lFilLote Filtra as filiais
@param lPerLote Filtra o período
@param aFilPer  Filtro Inicial e Final da Filial e do Periodo

@author Denis Souza
@since 19/02/2021
/*/
//------------------------------------------------------------------------------------
Static Function PgtFilPer( cTab, lFilLote, lPerLote, aFilPer )

	Local oBtnOk    := Nil
	Local oBtnCan   := Nil
	Local oSayPer   := Nil
	Local oSayFlDe  := Nil
	Local oSayFlAt  := Nil
	Local oGetPer   := Nil
	Local oGetFlDe  := Nil
	Local oGetFlAt  := Nil
	Local cPerIni   := space(6)
	Local cPerFim   := space(6)
	Local cFilDe    := space(len(xFilial(cTab)))
	Local cFilAte   := space(len(xFilial(cTab)))
	Local nColor 	:= 16777215
	Local nColIni   := 07
	Local nColFim   := 100
	Local nLin 	    := 15
	Local nLinBtn   := 100

	Static oDlg     := Nil

	Default aFilPer  := {}
	Default lPerLote := .F.

	DEFINE MSDIALOG oDlg TITLE "Filtro através da Geração em Lote" FROM 000, 000  TO 250, 500 COLORS 0, nColor PIXEL Style DS_MODALFRAME

	oPainel := TPanel():New(00,00,"",oDlg,,.F.,.F.,,,0,0,.T.,.F.)
	oPainel:Align := CONTROL_ALIGN_ALLCLIENT

	@nLinBtn, 150 BUTTON oBtnCan PROMPT "Cancelar" SIZE 040, 015 OF oDlg PIXEL ACTION {||alert("Filtro através da Geração em Lote cancelado." + CRLF + "Serão considerados as demais opções, selecionadas na tela anterior."),oDlg:End()}
	@nLinBtn, 200 BUTTON oBtnOk PROMPT "Confirmar" SIZE 040, 015 OF oDlg PIXEL ;
	ACTION {|| If( lFilLote .And. ( Empty(cFilDe) .Or. Empty(cFilAte) ) .Or. ( lPerLote .And. (Empty(cPerIni) .Or. Empty(cPerFim)) ) , (alert('Informe todos os filtros disponíveis.'),.F.),( aadd(aFilPer,{cPerIni,cPerFim,cFilDe,cFilAte}), oDlg:End() ) ) }

	If lFilLote

		@nLin, nColIni SAY oSayFlDe PROMPT "A partir da Filial" SIZE 045, 025 OF oDlg COLORS 0, nColor PIXEL
		@nLin, nColFim MSGET oGetFlDe VAR cFilDe SIZE 60, 10 OF oDlg COLORS 0, nColor F3 "XM0" PIXEL VALID {||If(!Empty(cFilDe) .And. !FWFilExist(cEmpAnt,cFilDe),(alert('Informe uma filial válida.'),.F.),.T.)}
		nLin+=20
		@nLin, nColIni SAY oSayFlAt PROMPT "Até a Filial" SIZE 045, 025 OF oDlg COLORS 0, nColor PIXEL
		@nLin, nColFim MSGET oGetFlAt VAR cFilAte SIZE 60, 10 OF oDlg COLORS 0, nColor F3 "XM0" PIXEL VALID {||If(!Empty(cFilAte) .And. !FWFilExist(cEmpAnt,cFilAte),(alert('Informe uma filial válida.'),.F.),.T.)}
	
	EndIf

	If lPerLote

		If lFilLote
			nLin+=20
		EndIf

		@nLin, nColIni SAY oSayPer PROMPT "A partir do Período" + CRLF +  "(mm-aaaa)" SIZE 050, 020 OF oDlg COLORS 0, nColor PIXEL
		@nLin, nColFim MSGET oGetPer VAR cPerIni SIZE 40, 10 OF oDlg PICTURE "@R 99-9999" COLORS 0, nColor PIXEL VALID {||If(!Empty(cPerIni) .And. Len(Alltrim(cPerIni))<>6,(alert('Informe um período válido.'),.F.),.T.)}
		nLin+=20
		@nLin, nColIni SAY oSayPer PROMPT "Até o Período" + CRLF + "(mm-aaaa)" SIZE 050, 020 OF oDlg COLORS 0, nColor PIXEL
		@nLin, nColFim MSGET oGetPer VAR cPerFim SIZE 40, 10 OF oDlg PICTURE "@R 99-9999" COLORS 0, nColor PIXEL VALID {||If(!Empty(cPerFim) .And. Len(Alltrim(cPerFim))<>6,(alert('Informe um período válido.'),.F.),.T.)}

	EndIf

	oDlg:lEscClose := .F.
	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
