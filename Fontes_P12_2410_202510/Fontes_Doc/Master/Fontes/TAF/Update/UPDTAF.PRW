#include 'protheus.ch'
#include 'updtaf.ch' 

//-----------------------------------------------------------------------
/*/{Protheus.doc} updtaf
Rotina de atualização de dicionário de dados do TAF.

@param cOrigem -> indica a origem da chamada do UPDTAF.
					0 - Programa Inicial - smartclient
					1 - TAF_Atualizador

@author		Luccas Curcio
@since		29/11/2016
@version	1.0
/*/
//----------------------------------------------------------------------
main function updtaf( cOrigem )

	local aEmpresas := {}

	default cOrigem := '0'

	if ( lOpen := updOpenSM0( @aEmpresas , .T. ) ) // verifica se encontrou empresa/filial
		If Len(aEmpresas) > 0
			rpcSetType( 3 )
			//rpcSetEnv( SM0->M0_CODIGO , SM0->M0_CODFIL ,,, "TAF" ) // trecho comentado pois existem casos que o primeiro registro está deletado e não possui tabelas criadas, gerando error log.
			rpcSetEnv( aEmpresas[1][2] , aEmpresas[1][3]  ,,, "TAF" )// se encontrou empresa/filial, loga na primeira empresa encontrada.
			if ( cOrigem == '1' ) .or. ( checkEnvUpddistr( ) )
				RpcClearEnv()
				upddistr()
			else
				procUpdTAF( aEmpresas )
			endif
		EndIf
	endif

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} procUpdTAF
Função principal que executa atualização de dicionário de dados do TAF depois
que o UPDDISTR já foi concluído.

@param		aEmpresas	-	Array contendo as empresas que serão processadas

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function procUpdTAF( aEmpresas )

	local	cTxtIntro	as	character
	local	lMarcaItem	as	logical
	local	aListUpd	as	array
	local	aColSize	as	array
	local	aTitulos	as	array
	local	oNo			as	object
	local	oOk			as	object
	local	oBtn1		as	object
	local	oBtn2		as	object
	local	oBtn3		as	object
	local	oBtn4		as	object
	local	oBtn5		as	object
	local	oDlgUpd	as	object
	local	oListUpd	as	object
	private aUpdTask	as	array

	cTxtIntro	:=	''
	aColSize	:=	{ 3 , 30 , 195 , 40 , 15 }
	aTitulos	:=	{' ', 'Release', STR0113 , STR0106 , "Id." }
	oNo			:=	loadBitMap( getResources() , "LBNO" )
	oOk			:=	loadBitMap( getResources() , "LBOK" )
	lMarcaItem	:=	.T.
	aUpdTask	:= {}

	//Ignora os registros deletados no sigamat.emp
	SET DELETED ON

	cTxtIntro := "<table width='100%' border=0.5>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'><size='+3'>"
	cTxtIntro += "Esta rotina tem o objetivo de atualizar o metadados do ambiente conforme os itens selecionados abaixo." + "</font></td>"
	cTxtIntro += "<td></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'><color='#FF0000' size='+3'><br>"+ "As atualizações somente poderão ser realizadas em modo" +"<b>"+ STR0003 +"</b><br>"
	cTxtIntro += STR0004
	cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
	cTxtIntro += "</font></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "</table>

	//-- Obtem a lista de Updates disponiveis para execucao:
	aListUpd := getUpdateList()

	cMsgTitle := 'Update - TOTVS Automação Fiscal'

	DEFINE MSDIALOG oDlgUpd;
	TITLE cMsgTitle;
	FROM 00,00 TO 500,700 PIXEL

	tSay():new( 002 , 005 , {|| cTxtIntro } , oDlgUpd ,,,,,, .T. ,,, 340 , 200 ,,,, .T. ,, .T. )

	oListUpd := tWBrowse():new(	40 , 07 , 335 , 162 , , aTitulos , aColSize , oDlgUpd ,,,,,,,,,,,,, "ARRAY" , .T. )
	oListUpd:bLDblClick := {|| aListUpd[ oListUpd:nAt , 1 ] := !aListUpd[ oListUpd:nAt , 1 ] , oListUpd:Refresh() }
	oListUpd:SetArray( aListUpd )
	oListUpd:bLine := {|| { if( aListUpd[ oListUpd:nAt , 1 ] , oOk , oNo ) ,;
								aListUpd[ oListUpd:nAT , 2 ] ,;
								aListUpd[ oListUpd:nAT , 3 ] ,;
								aListUpd[ oListUpd:nAT , 4 ] ,;
								aListUpd[ oListUpd:nAT , 5 ] } }

	oBtn1 := tButton():new( 210,005, STR0006 , oDlgUpd,; //Marca/Desmarca Pendentes
					{|| aEval(aListUpd,{|aElem| aElem[1] := If(aElem[4] == STR0016 , lMarcaItem, .F.)}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; //Pendente
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn2 := tButton():new( 210,140, STR0007 , oDlgUpd,; //Marca/Desmarca Todos
					{|| aEval(aListUpd,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },;
					075,015,,/*oFonte*/,,.T.,,,,,,)


	oBtn3 := tButton():new( 210,270, STR0008 , oDlgUpd,; //Selecionar Empresas
					{|| aEmpresas := TAFSelSM0( @aEmpresas ) },;
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn4 := tButton():new( 230,005, STR0009 , oDlgUpd,; //'Processar...'
					{|| RpcClearEnv(), MsgRun(STR0011, STR0189 ,{||TAFProcUpd( aListUpd, aEmpresas , @aUpdTask )}), oDlgUpd:End() },; //Aguarde o termino do Processamento ## "TOTVS Automação Fiscal"
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn5 := tButton():new( 230,140, STR0010 , oDlgUpd,; //Cancelar
					{|| __quit()},;
					075,015,,/*oFonte*/,,.T.,,,,,,)

	//Altera o estilo dos botões
	oBtn1:SetCss("color:black }")
	oBtn2:SetCss("color:black }")
	oBtn3:SetCss("color:black }")
	oBtn4:SetCss("color:black }")
	oBtn5:SetCss("color:black }")

	activate MSDIALOG oDlgUpd centered

	If !Empty(aUpdTask)
		showLog( aUpdTask )
	EndIf

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} getUpdateList
Função que carrega as opções de atualização que devem ser apresentadas ao usuário.

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
Static Function getUpdateList()

	Local aList	as array
	aList := {}

	AAdd(aList, {.F., "P12133"	, "Atualização - Dicionário de dados TAF - Release 12.1.033"	, vldUpd("P12133")	, "033" })
	AAdd(aList, {.F., "P1212210", "Atualização - Dicionário de dados TAF - Release 12.1.2210"	, vldUpd("P1212210"), "2210"})
	AAdd(aList, {.F., "P1212310", "Atualização - Dicionário de dados TAF - Release 12.1.2310"	, vldUpd("P1212310"), "2310"})
	AAdd(aList, {.F., "P1212410", "Atualização - Dicionário de dados TAF - Release 12.1.2410"	, vldUpd("P1212410"), "2410"})

Return aList

//-----------------------------------------------------------------------
/*/{Protheus.doc} updOpenSM0
Função que verifica se o ambiente pode ser aberto e carrega as empresas se solicitado
através do parâmetro lLoadEmp

@param		aEmpresas	-	Array contendo as empresas que serão carregadas. Só tem efeito se lLoadEmp = .t.
@param		lLoadEmp	-	Se .t. carrega as empresas e retorna no primeiro parâmetro aEmpresas ( default .f. )

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function updOpenSM0( aEmpresas , lLoadEmp )

	local	lOpen	as	logical
	local	nLoop	as	numeric
	local	nVezes	as	numeric

	default	aEmpresas	:=	{}
	default	lLoadEmp	:=	.F.

	lOpen	:=	.F.
	nLoop	:=	0
	nVezes	:=	20

	for nLoop := 1 To nVezes

		OpenSm0()

		If !empty( select( "SM0" ) )
			lOpen := .T.
			exit
		endif

		sleep( 500 )

	next nLoop

	if !( lOpen )
		msgAlert( STR0013 ) //"Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"

	else

		if lLoadEmp
			//-- Obtem as Empresas para processamento...
			SM0->( dbGotop() )
			while !( SM0->( eof() ) )
				if aScan( aEmpresas, { |x| x[ 2 ] == M0_CODIGO } ) == 0 .And. !Deleted()//--So adiciona no array se a empresa for diferente
					aAdd( aEmpresas , {	.T. ,;
										M0_CODIGO,;
										M0_CODFIL,;
										M0_FILIAL,;
										recno() } )
				endif

				SM0->( dbSkip() )
			EndDo

			SM0->( dbGoTop() )
		endif
	endif

return( lOpen )

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFSelSM0
Exibe janela para escolha das empresas que devem ser processadas

@author Evandro dos Santos Oliveira
@since 	 01.07.2015
@version 1.0

@param	 aEmpresas	Array que sera carregada as empresas

@return aEmpresas	Array com as informacoes das empresas.
/*/
//----------------------------------------------------------------------
Static Function TAFSelSM0( aEmpresas )

	local	oDlgSM0		as	object
	local	oListBox	as	object
	local	oOk			as	object
	local	oNo			as	object
	local	aHList		as	array
	local	lMarcaItem	as	logical

	default	aEmpresas	:=	{}

	oDlgSM0		:=	nil
	oListBox	:=	nil
	oOk			:=	LoadBitMap(GetResources(),"LBOK")
	oNo			:=	LoadBitMap(GetResources(),"LBNO")
	aHList		:=	{}
	lMarcaItem	:=	.T.

	DEFINE MSDIALOG oDlgSM0 TITLE STR0115 From 9,0 To 30,52

	AAdd( aHList, ' ')
	AAdd( aHList, STR0017 )//Empresa
	AAdd( aHList, STR0018 )//Filial
	AAdd( aHList, STR0019 )//Nome
	AAdd( aHList, STR0020 ) //Id.

	oListBox := TWBrowse():new(005,005,155,145,,aHList,,oDlgSM0,,,,,,,,,,,,, "ARRAY", .T. )
	oListBox:SetArray( aEmpresas )
	oListBox:bLine := {|| {	If(aEmpresas[oListBox:nAT,1], oOk, oNo),;
							aEmpresas[oListBox:nAT,2],;
							aEmpresas[oListBox:nAT,3],;
							aEmpresas[oListBox:nAT,4],;
							aEmpresas[oListBox:nAT,5]}}

	oListBox:bLDblClick := {|| aEmpresas[oListBox:nAt,1] := !aEmpresas[oListBox:nAt,1], oListBox:Refresh()}

	DEFINE SBUTTON FROM    4,170 TYPE 1 ACTION (oDlgSM0:End())   ENABLE OF oDlgSM0
	DEFINE SBUTTON FROM 18.5,170 TYPE 11 ACTION (Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem,,oListBox:Refresh()) ONSTOP STR0021 ENABLE OF oDlgSM0 //Marca/Desmarca

	activate MSDIALOG oDlgSM0 centered

Return( aEmpresas )

//-----------------------------------------------------------------------
/*/{Protheus.doc} checkEnvUpddistr
Função que analisa o ambiente e apresenta tela ao usuário caso seja necessário atualizar
o ambiente do TAF com a execução do UPDDISTR.

@return		lExecDistr	-	se .t. o UPDDISTR precisa ser executado para atualização do TAF.

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function checkEnvUpddistr()

	local	lExecDistr	as	logical
	local	lExecSegr1	as	logical
	local	lExecSegr2	as	logical
	local	cTitle		as	character
	local	cText		as	character
	local	nTamWindow	as	numeric
	local	nLin		as	numeric
	local	nCol		as	numeric
	local	oDlgMsg		as	object
	local	oFont		as	object
	local	bReadMore	:=	{|| ShellExecute( "open" , "http://tdn.totvs.com/pages/viewpage.action?pageId=198935223" , "" , "" , 1 ) }

	lExecSegr1	:=	.F.
	lExecSegr2	:=	.F.
	lExecDistr	:=	.F.
	oFont		:= TFont():new('Arial',,-12,.T.)
	nLin		:=	420
	nCol		:=	720
	nTamWindow	:=	3

	cTitle		:=	"UPDDISTR"

	cText		:=	"Este update é responsável pela atualização de metadados do <b>TOTVS Automação Fiscal.</b><br><br>"
	cText		+=	"O sistema identificou a necessidade de execução do compatibilizador <b>UPDDISTR</b> devido componentes "
	cText		+=	"do dicionário de dados não localizados no ambiente.<br><br>"
	cText		+=	"Ao clicar em 'Continuar' você será direcionado a esta rotina de atualização e <b>será necessário realizar nova execução do UPDTAF "
	cText		+=	"após o término do processamento do UPDDISTR</b> para finalizar o processo de atualização do TAF.<br><br>"
	cText		+=	"Clique em 'Saiba Mais' e entenda o procedimento de atualização completo do TOTVS Automação Fiscal.<br><br>"
	cText		+=	"Observações sobre a análise do ambiente:<br>"

	cText		+=	" -> Necessário aplicar a Parte 1 da Atualização de dicionário de dados do TAF? "
	if !tafAlsInDic("CHA")
		lExecSegr1 := .T.
		cText		+=	"<b>Sim</b><br>"
	else
		lExecSegr1 := .F.
		cText		+=	"<b>Não</b><br>"
	endif

	cText += " -> Necessário aplicar a Parte 2 da Atualização de dicionário de dados do TAF? "
	If	( !TafAlsInDic( "LEF" ) .or. !TafAlsInDic( "LEY" ) ) .or.;//Release 12.1.14
		( AllTrim( Posicione( "SX3", 2, "C0R_CODDA", "X3_VISUAL" ) ) <> "V" .or. AllTrim( Posicione( "SX3", 2, "C0R_DCODRE", "X3_RELACAO" ) ) <> "TAF027Init()" ) .or.; //Release 12.1.16
		( X3Uso( Posicione( "SX3", 2, "C8R_REPDSR", "X3_USADO" ))  == .T. .and. !TAFColumnPos( "C9G_VLNRET" ) /*Reinf 1.3*/ ) //Release 12.1.17

		lExecSegr2 := .T.
		cText += "<b>Sim</b><br>"
	Else
		lExecSegr2 := .F.
		cText += "<b>Não</b><br>"
	EndIf

	if lExecSegr1 .or. lExecSegr2

		oDlgMsg := MsDialog():new( 0, 0, nLin, nCol, "",,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )

		oLayer := FWLayer():new()
		oLayer:Init( oDlgMsg, .F. )
		oLayer:AddLine( "LINE01", 100 )
		oLayer:AddCollumn( "BOX01", 100,, "LINE01" )
		oLayer:AddWindow( "BOX01", "PANEL01", 'IMPORTANTE...', 100, .F.,,, "LINE01" )

		oSay	:=	TSay():new(10,10,{|| cText },oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),,oFont,,,,.T.,,,340,nLin,,,,,,.T.)
		oSay:lWordWrap = .T.

		tButton():new( 140, 40,  "Saiba Mais"	,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), bReadMore 								, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )
		tButton():new( 140, 140, "Continuar"	,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), {|| oDlgMsg:end() , lExecDistr := .T. }	, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )
		tButton():new( 140, 240, "Cancelar"		,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), {|| __quit() }							, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )

		activate MSDIALOG oDlgMsg centered

	endif

return ( lExecDistr )

//-----------------------------------------------------------------------
/*/{Protheus.doc} vldUpd
Função que verifica se determinado Update já foi aplicado.

@param		cUpdate	-	Identificação da atualização que deve ser verificada

@return		cInfo	-	Retornar "Executado" ou "Pendente"

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
Static Function vldUpd(cUpdate as character)

	Local aRelacao 	as array
	Local cInfo		as character
	Local lAchou 	as logical
	Local oSX6		as object
	Local oJson		as object
	Local nI		as numeric

	Default	cUpdate := ""
	
	aRelacao	:= {}
	cInfo		:= "Pendente"
	lAchou 		:= .F.

	If cUpdate == "P12133"

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SXA", 1, "T62", "XA_ALIAS" ) ) == 'T62' )
		EndIf

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SX3", 2, "CM0_DCODSI", "X3_RELACAO" ) ) != 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")' )
		EndIf

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOMEV", "X3_RELACAO" ) ) != 'IiF(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")' )													
		EndIf			

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOME  ", "X3_RELACAO" ) ) != 'IIF(!INCLUI .AND. !EMPTY(T3P->T3P_BENEFI),TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210"),"")' )													
		EndIf

		If !lAchou
			lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_RELACAO")) != 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'												
		EndIf

		If !lAchou
			lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_INIBRW")) != 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'												
		EndIf

		If !lAchou
			lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITULO")) != "Pag. Per Apu"
		EndIf

		If !lAchou
			lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCRIC")) != "Info. Pagto. Per. Apur."
		EndIf

		If !lAchou
			lAchou := AllTrim(Posicione("SX3", 2, "T2G_CPFTRA", "X3_TITULO")) != "CPF Trab."
		EndIf

		If !lAchou
			lAchou := AllTrim(Posicione("SX3", 2, "T2G_CPFBEN", "X3_TITULO")) != "CPF Ben."
		EndIf

		If !lAchou
			lAchou := Alltrim(Posicione("SX3", 2, "CM6_DFUNC", "X3_INIBRW")) != 'Posicione("C9V",1,xFilial("C9V",CM6->CM6_FILIAL)+CM6->CM6_FUNC,"C9V_NOME")'												
		EndIf

		If !lAchou 
			lAchou := ( Alltrim( Posicione( "SX7", 1, PadR("CM9_FUNC",10) + "002","X7_SEQUENC"))) != ""
		EndIf

		If !lAchou
			cInfo := "Executado"
		EndIf

	EndIf

	If cUpdate == "P1212210"

		If !lAchou
			lAchou := AllTrim(Posicione("SX3", 2, "V4K_VLREAJ", "X3_TITULO")) != "Vlr Bruto"
		EndIf

		If !lAchou
			//Protejo com a verificação do tamanho do campo, se foi alterado para comportar o retorno de 36 caracteres da função FWUUID(). Tamanho anterior: 15
			If FWSX3Util():GetFieldStruct( 'C20_CHVNF' )[3] >= 36
				lAchou := AllTrim(Posicione("SX3", 2, "C20_CHVNF", "X3_RELACAO")) != 'FWUUID("C20")'
			EndIf	
		EndIf

		If !lAchou
			cInfo := "Executado"
		EndIf

	EndIf

	If cUpdate == "P1212310"

		cInfo := "Executado"

	Endif

	If cUpdate == "P1212410"
		If !lAchou
			oSX6 := FWDescSX6():New()
			oSX6:SetFilter( { "MV_TAFISCH" } )
			oJson = oSX6:Execute()

			For nI := 1 to Len( oJson )
				If oJson[nI]["type"] == "L"
					lAchou := .T.
					Exit
				EndIf
			Next nI
		EndIf

		If !lAchou
			cInfo := "Executado"
		EndIf
	EndIf

Return cInfo

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFProcUpd
Função que processa as atualizações, chamando as funções já alteradas do
RUP_TAF.

@param		aListUpd	-	Lista de atualizações que devem ser executadas
@param		aEmpresas	-	Empresas que devem ser processadas
@param		aUpdTask	-	Array que contém um resumo das atualizações, para ser visualizado
							pelo usuário na função showLog()
@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function TAFProcUpd( aListUpd, aEmpresas , aUpdTask )

	local	nUpd		as	numeric
	local	nEmpresa	as	numeric
	Local   lDicInDB 	as  logical

	default aListUpd	:=	{}
	default aEmpresas	:=	{}
	default aUpdTask	:=	{}

	nUpd		:=	0
	nEmpresa	:=	0
	lDicInDB    := MPDicInDB()

	setTopMemoMega()

	for nEmpresa := 1 To Len( aEmpresas )

		if ( aEmpresas[ nEmpresa , 1 ] ) .and. ( lOpen := updOpenSM0( , .F.) )

			SM0->( dbGoTo( aEmpresas[ nEmpresa , 5 ] ) )
			rpcSetType( 3 )
			rpcSetEnv( SM0->M0_CODIGO , SM0->M0_CODFIL ,,, "TAF" )

			for nUpd := 1 to len( aListUpd )
				if aListUpd[ nUpd , 1 ]
					FAtuTafSX3( Nil, Nil, lDicInDB, .T., aListUpd[ nUpd , 5 ], @aUpdTask )
					FAtuTafSX6( Nil, Nil, lDicInDB, .T., aListUpd[ nUpd , 5 ], @aUpdTask )
					FAtuTafSX7( Nil, Nil, lDicInDB, .T., aListUpd[ nUpd , 5 ], @aUpdTask )
					FAtuTafSXA( Nil, Nil, lDicInDB, .T., aListUpd[ nUpd , 5 ], @aUpdTask )

					If Len(aUpdTask) == 0
						aAdd( aUpdTask , { cEmpAnt , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente"  } )
					EndIf

				endif
			next nUpd

		endif

		rpcClearEnv()

	next nEmpresa

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} showLog
Função que mostra um resumo das atualizações ao usuário

@param		aUpdTask	-	Array que contém um resumo das atualizações

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function showLog( aUpdTask )

	local	oDlgMsg		as	object
	local	nLin		as	numeric
	local	nCol		as	numeric
	local	nx			as	numeric
	local	aColSize	as	array

	default aUpdTask	:=	{}

	nLin			:=	420
	nCol			:=	720
	nx := 1
	aColSize	:=	{ 30 , 20 , 50 , 50 , 190 }
	cTxtIntro := "<table width='100%' border=0.5>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'>< size='+1'>"
	cTxtIntro += "Resumo de atualizações realizadas pelo Compatibilizador." + "</font></td>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'>< size='+1'><br>"+ "Verifique abaixo a lista de atualizações realizadas nas empresas selecionadas.<br>"
	cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
	cTxtIntro += "</font></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "</table>

	DEFINE MSDIALOG oDlgMsg TITLE "Update - TOTVS Automação Fiscal" FROM 00,00 TO 500,700 PIXEL

	TSay():new(005,005,{|| cTxtIntro },oDlgMsg,,,,,,.T.,,,340,200,,,,.T.,,.T.)

	oListUpd := TWBrowse():new(	40,07,335,162,,{ 'Empresa','Arq..','Chave','Campo(Dic.)','Conteúdo após atualização'},aColSize,oDlgMsg,,,,,,,,,,,,,"ARRAY",.T.,,,,.T.)

	oListUpd:SetArray( aUpdTask )
	oListUpd:bLine := {|| { aUpdTask[oListUpd:nAT,1],aUpdTask[oListUpd:nAT,2],aUpdTask[oListUpd:nAT,3],aUpdTask[oListUpd:nAT,4],aUpdTask[oListUpd:nAT,5] } }

	oBtn1 := tButton():new( 210,005, "Finalizar" , oDlgMsg,{|| __quit() },075,015,,,,.T.,,,,,,)

	oBtn1:SetCss("color:black }")

	activate MSDIALOG oDlgMsg centered

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} setTopMemoMega
Função que atualiza a chave topmemomega no appserver.ini

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function setTopMemoMega()

	if ( getSrvProfString( 'TOPMEMOMEGA' , '0' ) ) == '0'
		writeSrvProfString( 'TOPMEMOMEGA' , '1' )
	endif

return
