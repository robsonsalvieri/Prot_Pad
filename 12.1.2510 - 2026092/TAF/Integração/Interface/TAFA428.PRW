#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TAFA428.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TratError
Monta a interface para execução dos processos do TAF de forma manual

@Author Rodrigo Aguilar 
@Since 02/03/2016
/*/
//-------------------------------------------------------------------
Function TAFA428()

Local aSizeWindow := MsAdvSize()

Local nLinIni   := aSizeWindow[7] //Definindo a Linha Inicial da tela inicial que será criada
Local nLinFin   := aSizeWindow[6] //Definindo a Linha  Final da tela inicial que será criada
Local nColIni   := aSizeWindow[2] //Definindo a Coluna Inicial da tela inicial que será criada
Local nColFin   := aSizeWindow[5] //Definindo a Coluna Final da tela inicial que será criada  

Local cMvTAFTDB		:= Padr( GetNewPar( 'MV_TAFTDB', '' ), 100 )	//Parametro MV_TAFTDB - TAF TOP DATABASE DO ERP
Local cMvTAFTALI	:= Padr( Getmv( 'MV_TAFTALI' ), 100 ) 			//Parametro MV_TAFTALI- TAF TOP ALIAS DO ERP
Local nMvTAFPort	:= GetNewPar( 'MV_TAFPORT' , 0 )				//Parametro MV_TAFPORT- PORTA DO DBACCESS - DEFAULT PORTA CORRENTE

Local lMvTafTop	:= GetNewPar( 'MV_TAFCTOP', .F. ) 
Local aTopInfo	:= FWGetTopInfo()

Local cMvTafPort := Padr( iif( nMvTAFPort == 0, Alltrim( Str( aTopInfo[03] ) ), Alltrim( Str( nMvTAFPort ) ) ), 100 )

Local oDlg, oLayer, oTitulo, oIntegra, oValida, oDefinicao  := Nil

Local aParOri 	:= { , cMvTAFTALI, cMvTAFTDB, , , cMvTAFPort } //Valores originais conforme os parâmetros do dicionário
Local aPar    	:= { , cMvTAFTALI, cMvTAFTDB, , , cMvTAFPort } //Valores informados pelo usuário em tela
Local oCmbAmb 	:= Nil

Local oChk01 := Nil
Local oChk02 := Nil
Local oChk03 := Nil
Local oChk04 := Nil
Local oChk05 := Nil

//variaveis para carregar 1°acesso de tela
Local lChk01 := .F.
Local lChk02 := .F.
Local lChk03 := .T.
Local lChk04 := .F.
Local lChkSE := .F. //SE == Selecione Eventos
Local lChk05 := .F.
Local nEscop := 1
Local aProcSel 	:= { lChk01, lChk02, lChk03, lChk04, nEscop, lChk05}

Local lVldBaseTAF := GetNewPar("MV_TAFPRI3", .F.)

Private cCadastro	:=	STR0001	//'Rotina de Integração e validação de dados'
Private _lIniMt 	:= .F.
Private _lNoCloseTH := .T.

FLoadProf( @aProcSel )

//As Opções De Limpeza Da TafSt1 e de Transferencia Da TafSt1 p/ TafSt2 iniciam Desmarcadas devido Esocial
lChk01 := .F. 
lChk02 := .F.

//Carrega as opções
lChk03 := aProcSel[3] 		//processamento tafst2
lChk04 := aProcSel[4]
lChk05 := aProcSel[6]	//validação

If lVldBaseTAF
    lChk04 := .F.
EndIf

if Len(aProcSel) >= 5 .And. ValType(aProcSel[5]) == 'N'
	nEscop := aProcSel[5] 	//escopo
endif

//Criando a Dialog Principal da rotina
oDlg := MsDialog():New( nLinIni, nColIni, nLinFin, nColFin,STR0001,,,,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.,,,,.F. ) //'Rotina de Integração e validação de dados'
oDlg:lMaximized	:=	.T.

//Criação de Layers para divisão da tela
oLayer := FWLayer():New()
oLayer:Init( oDlg, .F. )

//Quando o parâmetro estiver como .T. devo montar o Layer referente aos parâmetros para que o usuário informe
//os dados necessários manualmente
if lMvTafTop
	oLayer:AddLine( 'TITULO' 	, 15 ) 
	oLayer:AddLine( 'DEFINICOES', 15 )
	oLayer:AddLine( 'PARAMETRO' , 25 )
	oLayer:AddLine( 'INTEGRA'	, 25 )
	oLayer:AddLine( 'VALIDA'	, 20 )
else
	oLayer:AddLine( 'TITULO' 	, 20 ) 
	oLayer:AddLine( 'DEFINICOES', 20 )
	oLayer:AddLine( 'INTEGRA'	, 25 )
	oLayer:AddLine( 'VALIDA'	, 25 )
endif

if lMvTafTop
	oLayer:AddCollumn( 'BOX_PARAMETRO'	, 100	,, 'PARAMETRO' )
	oLayer:AddWindow ( 'BOX_PARAMETRO', 'PANEL00', STR0002, 100, .F.,,, 'PARAMETRO' ) //'Parâmetros de Integração( Caso não sejam informados serão assumidos os valores informados no dicionário de dados )'
endif

oLayer:AddCollumn( 'BOX_INTEG'	, 100	,, 'INTEGRA' )
oLayer:AddWindow ( 'BOX_INTEG', 'PANEL00', STR0003, 100, .F.,,, 'INTEGRA' ) //'Processos referentes a Integração do ERP com o TAF'

oLayer:AddCollumn( 'BOX_VALIDA'	, 100	,, 'VALIDA' )
oLayer:AddWindow ( 'BOX_VALIDA', 'PANEL00', STR0004, 100, .F.,,, 'VALIDA' ) //'Processos internos do TAF'

oLayer:AddCollumn( 'BOX_DEFINICOES', 100	,, 'DEFINICOES' )
oLayer:AddWindow ( 'BOX_DEFINICOES', 'PANEL00', STR0005, 100, .F.,,, 'DEFINICOES' ) //'Definições/Termos Técnicos'

oLayer:AddCollumn( 'BOX_TITULO', 100	,, 'TITULO' )
oLayer:AddWindow ( 'BOX_TITULO', 'PANEL00', STR0006, 100, .F.,,, 'TITULO' ) //'Qual o objetivo dessa rotina ?'

if lMvTafTop
	oParametro := oLayer:GetWinPanel ( 'BOX_PARAMETRO' , 'PANEL00', 'PARAMETRO' )
	oPParametro := TPanel():New(00,00,"",oParametro,,.F.,.F.,,,0,0,.F.,.F.) 
	oPParametro:Align := CONTROL_ALIGN_ALLCLIENT
endif

oTitulo  := oLayer:GetWinPanel ( 'BOX_TITULO' , 'PANEL00', 'TITULO' )
oPTitulo := TPanel():New(00,00,"",oTitulo,,.F.,.F.,,,0,0,.F.,.F.) 
oPTitulo:Align := CONTROL_ALIGN_ALLCLIENT
	
oIntegra  := oLayer:GetWinPanel ( 'BOX_INTEG' , 'PANEL00', 'INTEGRA' )
oPIntegra := TPanel():New(00,00,"",oIntegra,,.F.,.F.,,,0,0,.F.,.F.) 
oPIntegra:Align := CONTROL_ALIGN_ALLCLIENT

oValida    := oLayer:GetWinPanel ( 'BOX_VALIDA', 'PANEL00', 'VALIDA' )
oPValida   := TPanel():New(00,00,"",oValida,,.F.,.F.,,,0,0,.F.,.F.) 
oPValida:Align := CONTROL_ALIGN_ALLCLIENT

oDefinicao  := oLayer:GetWinPanel ( 'BOX_DEFINICOES' , 'PANEL00', 'DEFINICOES' )
oPDefinicao := TPanel():New(00,00,"",oDefinicao,,.F.,.F.,,,0,0,.F.,.F.) 
oPDefinicao:Align := CONTROL_ALIGN_ALLCLIENT

//Seção Titulo
FNewTSay( oPTitulo, 10,005, oPTitulo:NCLIENTWIDTH * 0.49, 030, 6 )

//Seção Parametros
if lMvTafTop
	FNewTSay( oPParametro, 10, 010, 100, 030, 7 )
	FNewTGet( oPParametro, @aPar[2], 20, 010, 50, 5, "@!" )
	FNewTSay( oPParametro, 35, 10, 125, 030, 10 )
	
	FNewTSay( oPParametro, 10, 150, 100, 030, 8 )
	FNewTGet( oPParametro, @aPar[3], 20, 150, 50, 5, "@!" )
	FNewTSay( oPParametro, 35, 150, 125, 030, 11 )
	
	FNewTSay( oPParametro, 10, 290, 100, 030, 9 )
	FNewTGet( oPParametro, @aPar[6], 20, 290, 50, 5, "@!" )
	FNewTSay( oPParametro, 35, 290, 125, 030, 12 )
endif

//Seção Integrações

	oChk01 := TCheckBox():New(10,010,STR0007, bSetGet(@lChk01),oPIntegra,100,250,,,,,,,.T.,,, )
	FNewTSay( oPIntegra, 25, 005, 125, 030, 2 )
	
	oChk02 := TCheckBox():New(10,160,STR0008, bSetGet(@lChk02),oPIntegra,200,250,,,,,,,.T.,,, )
	FNewTSay( oPIntegra, 25, 160, 125, 030, 3 )

	/*-----------------------------------------------------------------------------------------------------
	|caso exista registro pendentes de processamento na TAFST1 habilita check de limpeza e transferencia  |
	-----------------------------------------------------------------------------------------------------*/
	If !isTAFInCloud()
		if ChkTAFST1()
			oChk01:enable()
			oChk02:enable()
		/*----------------------------------------------------------------------------------------------------------
		|caso nao exista registro pendentes de processamento na TAFST1 e exista estrutura da SFT no banco	 	   |
		|desabilita transferencia da ST1 pois eh considerado modulo e nao habilita check de limpeza e transferencia|
		----------------------------------------------------------------------------------------------------------*/
		elseif TemRegSFT()
			oChk01:disable()
			oChk02:disable()
		Endif
	EndIf 

	oChk03 := TCheckBox():New(10,310,STR0009, bSetGet(@lChk03),oPIntegra,200,250,,,,,,,.T.,,, )
	FNewTSay( oPIntegra, 25, 310, 125, 030, 4 )

	oCmbAmb := TComboBox():New(010,460,{|u|if(PCount()>0,nEscop:=u,nEscop)},;
	{"","Fiscal/Contabil","eSocial"},80,015,oPIntegra,,{||nEscop := oCmbAmb:nAt, Iif(oCmbAmb:nAt == 3, oChkSE:Enable(), oChkSE:Disable() )};
	,,,,.T.,,,,,,,,,'nEscop',"Tipo de dado (Escopo)",1,,CLR_RED)

	oChkSE := TCheckBox():New(10,560,STR0066, bSetGet(@lChkSE),oPIntegra,200,250,,,,,,,.T.,,, )
	FNewTSay( oPIntegra, 25, 560, 100, 030, 16 )
	
	
//Seção Validação
	oChk04 := TCheckBox():New(10,010,STR0010, bSetGet(@lChk04),oPValida,100,250,,,,,,,.T.,,, )
	FNewTSay( oPValida, 25, 010, oPValida:NCLIENTWIDTH * 0.49, 030, 5 )
	
	oChk05 := TCheckBox():New(40,449,STR0072, bSetGet(@lChk05),oPIntegra,200,250,,,,,,,.T.,,, )
	FNewTSay( oPIntegra, 25, 160, 125, 030, 3 )

    If lVldBaseTAF .And. !FWIsAdmin( __cUserID )
        oChk04:Disable()
    EndIf

//Seção Definição
	FNewTSay( oPDefinicao, 10, 005, oPDefinicao:NCLIENTWIDTH * 0.49, 030, 13 )
	FNewTSay( oPDefinicao, 25, 005, oPDefinicao:NCLIENTWIDTH * 0.49, 030, 14 )

Activate MsDialog oDlg ON INIT ENCHOICEBAR(oDlg, {|| iif(FConfirma( aPar, aParOri, aTopInfo,oDlg, lChk01, lChk02, lChk03, lChk04, nEscop, lChkSE, lChk05),;
												 	 FClear428( @aProcSel, @oChk01, @oChk02, @oChk03, @oChk04, @lChk01, @lChk02, @lChk03, @lChk04, @nEscop ),) },{|| oDlg:End() },,) Centered

Return (nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} FNewTGet
Função padrão para montagem dos TGets da interface

@Param oObjeto   - Objeto onde será vinculado o CheckBox
		cVar      - Variável que receberá o valor informado em tela pelo usuário
		nRow      - Número da linha onde será criado o objeto
		nCol      - Número da coluna onde será criado o objeto  
		nLarg     - Largura do Objeto
		nAlt      - Altura do Objeto
		cPict     - Mascara a ser utilizada
		
		
@Author Rodrigo Aguilar 
@Since 02/03/2016
/*/
//-------------------------------------------------------------------
Static Function FNewTGet( oObjeto, cVar, nRow, nCol, nLarg, nAlt, cPict )

TGet():New( nRow,nCol,{|u| if(PCount()>0,cVar:=u,cVar)},oObjeto,nLarg,nAlt,cPict,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVar,,,, )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FNewTSay
Função padrão para montagem dos TSays da interface

@Param oObjeto   - Objeto onde será vinculado o CheckBox
		nRow      - Número da linha onde será criado o objeto
		nCol      - Número da coluna onde será criado o objeto  
		nLarg     - Largura do Objeto
		nAlt      - Altura do Objeto
		nOpc      - Número da mensagem a ser exibida
		
		
@Author Rodrigo Aguilar 
@Since 02/03/2016
/*/
//-------------------------------------------------------------------
Static Function FNewTSay( oObjeto, nRow, nCol, nLarg, nAlt, nOpc )

Local cMsg 		:= ''
Local lHTML		:= FWCSSTools():GetInterfaceCSSType() == 5
Local cTamFonte	:= IIF(lHTML,'2.4','3')

if nopc == 1

	cMsg := '<font size="5" color="#191970">'
	cMsg += STR0011								 //'Selecione os processos que devem ser executados'

elseif nOpc == 2

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0012 //'Este processamento exclui da tabela TAFST1 todos os registro que já '
	cMsg += STR0013 //'foram integrados com o TAF'

elseif nOpc == 3 

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0014 //'Este processamento realiza a transferência dos registros não integrados '
	cMsg += STR0015 //'da tabela TAFST1 ( ERP ) para a tabela TAFST2( TAF )'

elseif nOpc == 4

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0016 //'Este processamento realiza a transferência dos registros não integrados '
	cMsg += STR0017 //'da tabela TAFST2 para as tabelas de negócio do TAF'

elseif nOpc == 5

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0018 //'Este processamento realiza a validação de todos os registros que existem '
	cMsg += STR0019//'na base do TAF, após o processamento o usuário deve analisar o gerenciador '
	cMsg += STR0020//'de integração para corrigir as possíveis inconsistências encontradas'

elseif nOpc == 6

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0021 //'Esta rotina tem como objetivo permitir a execução manual dos processos internos(Jobs) do TAF, quando selecionado mais de um processamento o sistema realizará o '
	cMsg += STR0022//'controle garantindo a correta ordem de execução. '
	cMsg += STR0023 //'A Totvs recomenda aos clientes a configuração dos processos abaixo para execução automática através da rotina de Schedule disponível '
	cMsg += STR0024 //'no configurador.'

elseif nOpc == 7

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += '<b>Parâmetro MV_TAFTALI:</b>'
	
elseif nOpc == 8

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += '<b>Parâmetro MV_TAFTDB:</b>'
	
elseif nOpc == 9
	
	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += '<b>Parâmetro MV_TAFPORT:</b>'

elseif nOpc == 10
	
	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0025 //'Informe qual o nome definido para a conexão com a tabela TAFST1 no TopConnect '
	
elseif nOpc == 11

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0026 //'Informe qual o banco onde foi criada a tabela TAFST1 '
	
elseif nOpc == 12	

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0027 //'Informe o número da porta utiliza pelo TopConnect para conexão com a tabela TAFST1 '

elseif nOpc == 13	

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0028 //'** TAFST1 trata-se de uma tabela de integração criada pelo TAF na base de dados do sistema '
	cMsg += STR0029 //'origem, sendo populada por ele conforme layout de integração; todas as informações contidas '
	cMsg += STR0030 //'nesta tabela serão integradas para o TAF '

elseif nOpc == 14	

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0031 //'** TAFST2 trata-se de uma tabela de integração criada na base de dados do TAF, sua função '
	cMsg += STR0032 //'é garantir que todas as mensagens geradas na tabela TAFST1 sejam processadas e integradas '
	cMsg += STR0033 //'com o TAF '

elseif nOpc == 16	

	cMsg := '<font size="' + cTamFonte +'" color="#778899">'
	cMsg += STR0065 //"Esta opção tem por objetivo selecionar os eventos para o processamento que serão integrados "
	cMsg += STR0017 //'da tabela TAFST2 para as tabelas de negócio do TAF'
	
					
endif

TSay():New( nRow, nCol, {|| cMsg },oObjeto ,,,,,,.T.,,,nLarg,nAlt,,,,,,.T.)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FConfirma
Função que realizada a validação da operação solicitada pelo usuário

@Param aProcSel - Processos selecionados pelo usuário para processamento 
		aPar  - Parametros informados pelo usuário
		aParOri - Parametros recuperados do dicionário de dados
		aTopInfo - Array com os dados do Top
		lChkBox0 //lChkBox0 => ST1 p/ ST2
		lChkBox1 //lChkBox1 => Limpeza de Base
		lChkBox2 //lChkBox2 => ST2 p/ TAF
		lChkBox3 //lChkBox3 => Validação				
@Author Rodrigo Aguilar 
@Since 02/03/2016
/*/
//-------------------------------------------------------------------
Static Function FConfirma( aPar, aParOri, aTopInfo,oDlg, lChkBox1, lChkBox0, lChkBox2, lChkBox3, nObrig, lChkSE,lChkFil)

Local lOk		 := .T.
Local lChgTop	 := .T.
Local aLisFil 	 := {}
Local oProcess	 := Nil
Local cFillog    := FwCodFil()
local cFilName   := FWFilialName()
local cCodGrup    := FWGrpCompany()
Local cCgc		 := ""
Local cIsnc		 := ""
Local cIsncM     := ""

Private cFilEvent := ""

Default lChkBox0 := .F.
Default lChkBox1 := .F.
Default lChkBox2 := .F.
Default lChkBox3 := .F.
Default lChkFil  := .F.
Default lChkSE	 := .F.
Default nObrig 	 := 1

//Verifico se algum processo foi escolhido para processamento
if  lChkBox0 .Or. lChkBox1 .Or. lChkBox2 .Or. lChkBox3
	
	if lChkFil

		cCgc := Posicione("SM0",1,cCodGrup + cFillog ,"M0_CGC")
		cIsnc := Posicione("SM0",1,cCodGrup + cFillog ,"M0_INSC")
		cIsncM := Posicione("SM0",1,cCodGrup + cFillog ,"M0_INSCM")

		aAdd(aLisFil,{ .T.,;
						cFillog,;
						cFilName,;
						cCgc,;
						cIsnc,;
						cIsncM;
                		})
	Else
		aLisFil := MatFilCalc(.T.)
	EndIf

	lOk := !empty(aLisFil)

	If nObrig == 3 .And. lChkBox2 .And. lChkSE .And. lOk

		If lChkBox0 .Or. lChkBox1
			MsgAlert(STR0075) // "Para processamentos do e-Social não deve ser informado parâmetros da tabela TAFST1."
			lOk := .F.
		Else
			TAFSelEv(aLisFil, lChkBox0, lChkBox1, lChkBox2)
		EndIf
		
		If EMPTY(cFilEvent)
			MsgAlert( STR0038 ) 
			lOk := .F.
		EndIf
	EndIf

	if lOk
		if nObrig == 1
			MsgAlert( "Selecione um Tipo de dado para o processamento." )
			lOk := .F.
		Else
			
			//Ajusto valores 
			apar[2] := Alltrim( aPar[2] )  
			apar[3] := Alltrim( aPar[3] ) 
			apar[6] := val( aPar[6] )

			aparOri[2] := Alltrim( aparOri[2] )  
			aparOri[3] := Alltrim( aparOri[3] ) 
			aparOri[6] := val( aparOri[6] )
			
			//Se o usuário não mudou os parametros em tela não valido
			if apar[2] == aparOri[2] .And. apar[3] == aparOri[3] .And. apar[6] == aparOri[6]
				lChgTop := .F.
			endif
			
			if lChgTop
				//Faço a conexão com a tabela TAFST1 através dos valores informados em tela pelo usuário, se os valores apontam para o TopConnect/Banco local não preciso validar as informações
				MsgRun( STR0034, STR0035, { || lOk := FConectTAF( apar[2], apar[3], apar[6], .T., 0 , .T., aparOri ) } ) //'Validando parâmetros informados' ## 'Aguarde...'
			endif
					
			//Verifico se a conexçao acima foi bem realizada, caso contrário volto o TcLink para a conexão anterior
			if !lOk
				MsgAlert( STR0036	 ) //'Os parâmetros informados estão incorretos, favor revisá-los !'
				Return Nil
			endif

			If lOk
				FSalvProf( {lChkBox0 , lChkBox1 , lChkBox2 , lChkBox3, nObrig, lChkFil } )
				oDlg:End()
			EndIf

			oProcess := TAFProgress():New( { || FProcInt( @oProcess, lChkBox0, lChkBox1, lChkBox2, lChkBox3, aPar, aParOri,aLisFil,nObrig,lChkFil) }, STR0037,.T.,.T. ) //'Processando Integração'
			oProcess:Activate()

		EndIF
	else
		MsgAlert(STR0070) //#'O processamento foi cancelado com sucesso.'
	endif	
else
	MsgAlert( STR0038 ) //'Nenhum processo foi selecionado para processamento'
endif

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TafFisMT
Funcao para utilizar em schedule, com a finalidade de processar a integracao
de escopo Fiscal entre TAFST2 e o TAF em MultThread por Filial uma de cada vez.

@Param aParam:array
		aParam[1]:"T1"
		aParam[2]:"D MG 01 "
		aParam[3]:"000000"
		aParam[4]:"000003000001"

@Obs No Configurador colocamos apenas o nome dessa funcao TafFisMT.
	 Os parametros acima serao recebidos de forma automatica, 
	 ao informar um grupo de empresa no configurador\schedule.

@Author Wesley Pinheiro / Denis Souza
@Since 09/04/2020
/*/
Function TafFisMT( aParam )

Local aListFil := { }
Local cGrpJob  := ""
Local lOk      := .T.
Local cEscopo  := "1"
Local aPar     := {}
Local nFil	   := 0
Local nQtdFil  := 0
Local nQtGpEmp := 0
Local nGpEmp   := 0
Local nStart   := Seconds()
Local nStartFl := 0
Local nQtPend  := 0
Local aEmpSM0  := {}

Private _lIniMt 	:= .F.
Private _lNoCloseTH := .T.

/*------------------------------------------------
| Verifica grupos e empresas a serem processadas |
------------------------------------------------*/
TafGpEmp( aParam, @aEmpSM0 )
nQtGpEmp := Len( aEmpSM0 )

aEval(aEmpSM0,{|x|IIf(x[2],++nQtPend,)})
TafConOut( "***Qtd Grp\Emp Pendente(s): " + cvaltochar(nQtPend) + " Duracao: " + cValTochar( Seconds() - nStart ) + "s" )

/*--------------------
| Laco Grp \ Empresa |
--------------------*/
for nGpEmp := 1 to nQtGpEmp

	if aEmpSM0[nGpEmp][2] //empresa tem pendencia?

		//Para cada grupo ou empresa serao abertas o numero de quantidade de threads contidas no parametro MV_TAFQTTH
		_lIniMt 	:= .F.

		/*------------------------
		| Preparacao do ambiente |
		------------------------*/
		cGrpJob := aEmpSM0[nGpEmp][1]
		TafDbDriver( cGrpJob,.T.)

		/*------------------------------------
		| Filiais Pendentes de processamento |
		------------------------------------*/
		aListFil := getFil4Proc( cGrpJob )
		nQtdFil  := Len( aListFil )
		TafConOut('***Grp.Emp: ' + cGrpJob + " possui " + cvaltochar(nQtdFil) + " filiais pendentes de processamento." )

		/*-------------
		| Laco Filial |
		-------------*/
		for nFil := 1 to nQtdFil
			//Caso o grp ou empresa possua apenas 1 filial, no proximo grupo apos a primeira filial ser processada,
			//a mesma era encerrada, por isso inicio a variavel com .t. a cada execucao.
			_lNoCloseTH := .T.

			TAFConout( "------->#Inicio Processamento Filial: " + aListFil[nFil] + " Grupo: " + cGrpJob + " #Horario: " + time(),2,.T.,"INTEG" )
			nStartFl := Seconds()

			VerUltFil( nFil, nQtdFil )

			cFilAnt := aListFil[nFil]

			//Seta a primeira posição do array com o Job que será realizado
			aPar := { 2,,, cGrpJob, cFilAnt }

			TAFAInteg( aPar,,, @lOk, .F., , cEscopo )

			If !lOk			
				TafConOut( STR0045 ) //"Falha na integração dos dados..."				
			Else				
				TafConOut( STR0046 ) //"Integração de dados aos cadastros do TAF finalizada com sucesso..."
			EndIf

			TAFConout( "#Duracao Execucao filial: " + aListFil[nFil]  + " Grupo: " + cGrpJob + " #Tempo: " + cValTochar( Seconds() - nStartFl ) + " #Horario: " + time(),2,.T.,"INTEG" )
		Next nFil

		RpcClearEnv( )

		TAFConout( "#Duracao Operacao: " + cValTochar( Seconds() - nStart ) + " segundos " + " Grupo: " + cGrpJob + " #Horario: " + time(),2,.T.,"INTEG" )
	endif
next nQtGpEmp

aSize(aEmpSM0, 0 )
FwFreeArray( aEmpSM0 )
aEmpSM0 := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VerUltFil

@Param  nFil - Contador que controla em qual filial estou executando a verificação
		nQtdFil - Quantad filiais foram selecionadas para executar o processamento

@Obs:   Caso o contador seja o mesmo valor da quantidade de filiais selecionadas para o processamento,
		siginifica que estou processando a última filial, sendo assim, posso sinalizar o sistema que posso fechar o pool de threads
		@see TAFPROCMT.prw function TafProc2Mt()

@Author Wesley Pinheiro / Denis Souza
@Since 09/04/2020
/*/
Static Function VerUltFil( nFil, nQtdFil )

	If nFil == nQtdFil
		_lNoCloseTH := .F.
	Endif

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} getFil4Proc

Retorna as filiais que possuem registros a processar (job2) por grupo.

@return aFiliais - Array com as filiais (Codigo do ERP)

@author	Evandro dos Santos Oliveira Teixeira
Readaptado Wesley Pinheiro / Denis Souza

@since	09/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function getFil4Proc( cGrpJob )

    Local aFiliais := { }
    Local cSql     := ""
    Local cSql2    := ""
    Local cWhere   := ""
	Local cSubStr  := ""
	Local cSubStr2 := ""
	Local cBd      := TcGetDb( )
	Local cTamGrp  := AllTrim( Str( Len( cGrpJob ) ) )
	Local cAlias   := GetNextAlias()

	If cBd $ "ORACLE|POSTGRES|DB2"
    	cSubStr  := " AND SUBSTR(TAFST2.TAFFIL,1," + cTamGrp + ") = '" + cGrpJob + "' "
		cSubStr2 := " AND SUBSTR(C1E.C1E_CODFIL,1," + cTamGrp + ") = '" + cGrpJob + "' "
	ElseIf cBd $ "INFORMIX"
		cSubStr  := " AND TAFST2.TAFFIL[1," + cTamGrp + "] = '" + cGrpJob + "' "
		cSubStr2 := " AND C1E.C1E_CODFIL[1," + cTamGrp + "] = '" + cGrpJob + "' "
	Else //MSSQL,MYSQL,PROGRESS
		cSubStr  := " AND SUBSTRING(TAFST2.TAFFIL,1," + cTamGrp + ") = '" + cGrpJob + "' "
		cSubStr2 := " AND SUBSTRING(C1E.C1E_CODFIL,1," + cTamGrp + ") = '" + cGrpJob + "' "
	EndIf

    cWhere += " TAFST2.D_E_L_E_T_ = ' ' "
    cWhere += " AND TAFST2.TAFSTATUS = '1' "
    cWhere += " AND TAFST2.TAFIDTHRD = ' ' "

    cSql  := "%" + cWhere + cSubStr + "%"
    cSql2 := "%" + cWhere + cSubStr2 + "%"

	BeginSql alias cAlias
	
		SELECT C1E_FILTAF
			FROM TAFST2 TAFST2
		INNER JOIN %table:C1E% C1E
			ON C1E.C1E_CODFIL = TAFST2.TAFFIL
			AND C1E.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		WHERE %Exp:cSql%
		GROUP BY C1E_FILTAF

		UNION
	
		SELECT C1E_FILTAF
			FROM TAFST2 TAFST2
		INNER JOIN %table:CR9% CR9
			ON TAFST2.TAFFIL = CR9.CR9_CODFIL
			AND CR9.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		INNER JOIN %table:C1E% C1E
			ON C1E.C1E_ID = CR9.CR9_ID
			AND C1E.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		WHERE %Exp:cSql2%
		GROUP BY C1E_FILTAF
		ORDER BY 1 
	
	EndSql

	dbSelectArea(cAlias)
	( cAlias )->( DbGoTop( ) )
    ( cAlias )->( dbEval(  { || aAdd( aFiliais, C1E_FILTAF ) } ) )
    ( cAlias)->( dbCloseArea( ) )

Return aFiliais

//-------------------------------------------------------------------
/*/{Protheus.doc} FProcInt
Função que realizada a validação da operação solicitada pelo usuário

@Param oProcess - Barra de processamento
		aProcSel - Processos selecionados pelo usuário para processamento 
		aPar  - Parametros informados pelo usuário
		aParOri - Parametros recuperados do dicionário de dados
		nOpcEscopo - Opção do escopo da obrigação
				
@Author Rodrigo Aguilar 
@Since 02/03/2016
/*/
//-------------------------------------------------------------------
Static Function FProcInt( oProcess, lChkBox0, lChkBox1, lChkBox2, lChkBox3, aPar, aParOri, aLisFil, nOpcEscopo, lChkFil)

Local nI			:=	0
Local nRemain		:=	0
Local nFil			:=	0
Local nProgress1	:=	5
Local nProgress2	:=	7
Local lOk			:=	.T.
Local lMTeSocial	:=	.F.
Local lProtData		:= FindFunction("ProtData")
Local cEscopo 		:=  ""
Local nQtdFil		:=  0
Local nContFil		:=  0
Local cTimeStart 	:= Time()
Local cBanco 		:= Upper(AllTrim(TcGetDB()))
Local cUIdST2	  	:= 'UIdST2'
Local cUUID			:= ''
Local cUserLock		:= ''
Local cMsgErro		:= ''
Local cCodFil		:= ""
Local nStart 		:= Seconds()
Local nStartFl      := 0
Local nCntFil		:= 0
Local aCloneFil		:= {{}}

Private _lNoCloseTH := .T.

Default	aLisFil		:= {{.T., cFilAnt}}
Default lChkFil     := .F.

if lChkFil
	ACopy(aLisFil,aCloneFil)
endif

If TemReg( lChkBox0, lChkBox1, lChkBox2, @aLisFil, nOpcEscopo)

	If lChkBox1
		nProgress2 += 1
	EndIf

	If lChkBox3
		nProgress2 += 1
	EndIf

	lMTeSocial	:=	GetNewPar( "MV_TAFQTTH", 0 ) > 0 .Or. IPCCount(TAFMP2JobName() + "_" + cEmpAnt)

	cBkpFilAnt	:=	cFilAnt
	aEval(aLisFil,{|x|IIf(x[1],nQtdFil++,)})
	nCntFil 	:= 0

	for nFil := 1 to Len(aLisFil)

		nStartFl := Seconds()

		if aLisFil[nFil][1]

			VerUltFil( (++nCntFil), nQtdFil )

			TAFConout( "------------------------>Processando Filial: " + aLisFil[nFil][2] + " #Horario: " + Time(),2,.T.,"INTEG" )
			nStartFl := Seconds()

			cFilAnt := aLisFil[nFil][2]

			//Executa o Processo 0
			If lChkBox0
				//Seta a primeira posição do array com o Job que será realizado
				aPar[1] := 0

				oProcess:Set1Progress( nProgress1 )
				oProcess:Inc1Progress( STR0041 ) //"Preparando transferência de dados..."

				TAFAInteg( aPar,,, @lOk, .T., @oProcess )

				If !lOk
					nRemain := nProgress1 - oProcess:Ret1Progress() + 1

					For nI := 1 to nRemain
						oProcess:Inc1Progress( STR0042 ) //"Falha na transferência de dados da tabela TAFST1 para a tabela TAFST2..."
					Next nI
				Else

					oProcess:Inc1Progress( STR0043 ) //"Transferência de dados da tabela TAFST1 para a tabela TAFST2 finalizada..."

				EndIf
			Else
				oProcess:Set1Progress( nProgress1 )

				nRemain := nProgress1 - oProcess:Ret1Progress() + 1

				For nI := 1 to nRemain
					oProcess:Inc1Progress( STR0052 ) //"Etapa de transferência de dados da tabela TAFST1 para TAFST2 não necessária..."
					ProcessMessages() 
					Sleep(300) 
				Next nI

			EndIf

			//Executo o Processo 2
			If lChkBox2
				If lOk
					If nOpcEscopo == 3
						cEscopo := '3'
					Else
						//Seto 1 para fiscal e ECF hoje o Job 2 só faz uma tratativa diferente
						//para o e-Social (XML)
						cEscopo := '1'
					EndIf

					If cEscopo == "3" .And. !isTAFinCloud() .And. cBanco $ "MSSQL|MSSQL7|ORACLE|DB2|POSTGRES|MYSQL|" .and. lMTeSocial
						cUUID := cUIdST2
						//Cria Identificador de sessão para variavel de controle da TAFST2.
						If !VarSetUID(cUIdST2,.T.)
							cMsgErro := "Erro ao tentar criar o semaforo para integração. Reinicie o serviço do TAF, se o erro persistir entre em contato com o suporte Totvs."
							Aviso("Integração TAFST2 x TAF",cMsgErro,{"OK"},1)
						Else
							cCodFil := "'" + cFilAnt + "'"

							If !TafLockInteg(cUUID,.T.,@cUserLock,cCodFil,.T.,@cMsgErro)
								Aviso("Integração TAFST2 x TAF",cMsgErro,{"OK"},3)
							Else
								TafLockInteg(cUUID,.F.)

								nContFil++
								nRemain := nProgress2 - oProcess:Ret2Progress() + 1
								TafST2Manager(aLisFil,nContFil,nQtdFil,cTimeStart)
								For nI := 1 to nRemain
									oProcess:Inc2Progress("") 
								Next nI
								//TafLockInteg(cUUID,.F.)
							EndIf
						EndIf
					Else
						//Seta a primeira posição do array com o Job que será realizado
						aPar[1] := 2
						oProcess:Set2Progress( nProgress2 )
						oProcess:Inc2Progress( STR0044 ) //"Preparando integração de dados..."
						ProcessMessages() 
						Sleep(300) 

						TAFAInteg( aPar,,, @lOk, .T., @oProcess,cEscopo)

						If !lOk
							nRemain := nProgress2 - oProcess:Ret2Progress() + 1
							For nI := 1 to nRemain
								oProcess:Inc2Progress( STR0045 ) //"Falha na integração dos dados..."
							Next nI
						Else
							nRemain := nProgress2 - oProcess:Ret2Progress() + 1
							For nI := 1 to nRemain
								oProcess:Inc2Progress( STR0046 ) //"Integração de dados aos cadastros do TAF finalizada com sucesso..."
							Next nI
							ProcessMessages() 
							Sleep(300)
						EndIf
					EndIf
				Else
					oProcess:Set2Progress( nProgress2 )
					nRemain := nProgress2 - oProcess:Ret2Progress() + 1
					ProcessMessages() 
					Sleep(300) 
					For nI := 1 to nRemain
						oProcess:Inc2Progress( STR0053 ) //"Falha em etapa anterior..."
					Next nI
				EndIf
			Else
				oProcess:Set2Progress( nProgress2 )
				nRemain := nProgress2 - oProcess:Ret2Progress() + 1
				ProcessMessages() 
				Sleep(300) 
				For nI := 1 to nRemain
					oProcess:Inc2Progress( STR0054 ) //"Etapa de integração dos dados aos cadastros do TAF não necessária..."
					ProcessMessages() 
					Sleep(300) 
				Next nI
			EndIf

			//Executo o Processo 1
			If lChkBox1
				If lOk
					//Seta a primeira posição do array com o Job que será realizado
					aPar[1] := 1

					TAFAInteg( aPar,,, @lOk, .T., @oProcess )

					If !lOk
						oProcess:Inc2Progress( STR0047 ) //"Falha no processo de limpar a tabela TAFST1..."
					Else
						
						oProcess:Inc2Progress( STR0048 ) //"Processo de limpeza da tabela TAFST1 finalizado com sucesso..."
						
					EndIf
				Else
					nRemain := nProgress2 - oProcess:Ret2Progress() + 1

					For nI := 1 to nRemain
						oProcess:Inc2Progress( STR0053 ) //"Falha em etapa anterior..."
					Next nI
				EndIf
			EndIf

			//Executo o Processo 3
			If lChkBox3
				If lOk 
					aPar[1] := 3

					TAFAInteg( aPar,,, @lOk, .T., @oProcess )

					If !lOk
						oProcess:Inc2Progress( STR0049 ) //"Falha no processo de validação do TAF..."
					Else
						oProcess:Inc2Progress( STR0050 ) //"Processo de validação do TAF finalizado com sucesso..."
						nI++
						ProcessMessages() 
						Sleep(300) 
						
					EndIf
				Else
					nRemain := nProgress2 - oProcess:Ret2Progress() + 1

					For nI := 1 to nRemain + 1
						oProcess:Inc2Progress( STR0053 ) //"Falha em etapa anterior..."
						ProcessMessages() 
						Sleep(300) 
					Next nI
				EndIf
			EndIf
		endif

		TAFConout( "#Duracao Execucao filial " + aLisFil[nFil][2] + " #Tempo: " + cValTochar( Seconds() - nStartFl ) + " #Horario: " + time(),2,.T.,"INTEG" )
	next nFil

	TAFConout( "#Duracao da operacao: " + cValTochar( Seconds() - nStart ) + " #Horario: " + time(),2,.T.,"INTEG" )

	if  !empty(cBkpFilAnt) .and. cBkpFilAnt <> cFilAnt
		cFilAnt := cBkpFilAnt
	endif

	If lOk
		MsgInfo( STR0051 ) //"Todos os processamentos realizados foram finalizados com sucesso!"

		If ( lChkBox0 .or. lChkBox1 .or. lChkBox2 ) .and. lChkBox3
			If lProtData
				If ProtData(.F.)
					If Aviso( STR0055, STR0056, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Integração e Validação" ##"Processos finalizados, deseja visualizar o Gerenciador de Integração e Validação?" ##"Sim" ##"Não"
						TAFTicket()
					EndIf
				Else	
					MsgAlert(STR0068, STR0067)
				EndIf
			Else
				If Aviso( STR0055, STR0056, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Integração e Validação" ##"Processos finalizados, deseja visualizar o Gerenciador de Integração e Validação?" ##"Sim" ##"Não"
					TAFTicket()
				EndIf
			EndIf
		ElseIf ( lChkBox0 .or. lChkBox1 .or. lChkBox2 ) .and. !lChkBox3 
			If lProtData
				If ProtData(.F.)
					If Aviso( STR0057, STR0058, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Integração" ##"Processo finalizado, deseja visualizar o Gerenciador de Integração?" ##"Sim" ##"Não"
						TAFTicket( .T.,,, aCloneFil, lChkFil)						
					EndIf
				Else	
					MsgAlert(STR0068, STR0067)
				EndIf
			Else
				If Aviso( STR0057, STR0058, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Integração" ##"Processo finalizado, deseja visualizar o Gerenciador de Integração?" ##"Sim" ##"Não"
					TAFTicket( .T. )
				EndIf
			EndIf
		ElseIf ( !lChkBox0 .and. !lChkBox1 .and. !lChkBox2 ) .and. lChkBox3
			If lProtData
				If ProtData(.F.)
					If Aviso( STR0059, STR0060, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Validação" ##"Processo finalizado, deseja visualizar o Gerenciador de Validação?" ##"Sim" ##"Não"
						TAFTicket( ,.T. )
					EndIf
				Else
					MsgAlert(STR0068, STR0067)
				EndIf
			Else
				If Aviso( STR0059, STR0060, { STR0061, STR0062 }, 2 ) == 1 //##"Gerenciador de Validação" ##"Processo finalizado, deseja visualizar o Gerenciador de Validação?" ##"Sim" ##"Não"
					TAFTicket( ,.T. )
				EndIf
			EndIf
		EndIf
	Else
		MsgInfo( STR0063 ) //"Falha no processamento!"
	EndIf

	If FindFunction("TafDelScalar")
		TafDelScalar()
	EndIf

Else
	MsgInfo(STR0064)//"Não existem registros passíveis de processamento!"
EndIf

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} FSalvProf
Grava os Parâmentros em um arquivo de profile
@author evandro.oliveira
@since 18/05/2016
@version 1.0
@return ${boolean}, ${A função MemoWrite Retorna True ou False}
/*/
//--------------------------------------------------------------------
Static Function FSalvProf (aParams)

	Local  nX			as numeric
	Local  cWrite		as char
	Local  cBarra		as char
	Local  lRet			as logical	    
	Local  cUserName	as char
	Local  cNomeProf 	as char

	nX			:= 0
	cWrite		:= ""
	cBarra		:= If ( IsSrvUnix () , "/" , "\" )
	lRet		:= .F.	    
	cUserName	:= __cUserID
	cNomeProf 	:= ""

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf
		
	// --> Gera a string em formato JSON
	cWrite := FwJsonSerialize(aParams)
		
	cNomeProf	:=	FunName() + "_" + cUserName + "_" + cEmpAnt + "_" + cFilAnt
	
Return (MemoWrite ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" , cWrite ))

//--------------------------------------------------------------------
/*/{Protheus.doc} FLoadProf
Lê arquivo de profile e "alimenta" os parâmetros
@author evandro.oliveira
@since 18/05/2016
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function FLoadProf(aParams)

	Local nJ			as numeric
	Local cBarra 		as char
	Local cUserName		as char
	Local cNomeProf 	as char
	Local aParLoad		as array
	Local aAuxPar		as array
	Local lRetorno		as logical
	Local cJsonProf		as char
	Local aObjProf		as array
	Local cArquivo		as char
	Private cLinha		as char
	
	nJ			:=	0
	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	cUserName	:= __cUserID
	cNomeProf 	:= ""
	aParLoad	:= {}
	aAuxPar		:= {}
	lRetorno	:= .F.
	cJsonProf	:= ""
	aObjProf	:= Nil
	cLinha		:=	"" 
	cArquivo	:= ""

	cNomeProf	:=	FunName() + "_" + cUserName + "_" + cEmpAnt + "_" + cFilAnt
	cArquivo := cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" 

	If File (cArquivo)
	
		If FT_FUse (cArquivo ) <> -1
	
			FT_FGoTop ()
			While ( !FT_FEof () )
				cLinha := FT_FReadLn () 
				//aAdd(aParLoad,&(cLinha))
				cJsonProf += cLinha 
				FT_FSkip ()
			Enddo		
			If FT_FUse() != -1
				lRetorno := .T.
			EndIf
			
			// Deserializa a String JSON 
			If FwJsonDeserialize(cJsonProf, @aObjProf)
				If Len(aObjProf) == Len(aParams)
					For nJ := 1 To Len(aObjProf)
						aParams[nJ] := aObjProf[nJ]
					Next nJ
				Else
					lRetorno := .F.
				EndIf
			Else
				//Apago o arquivo quando não está de acordo para que na proxima execução
				//o sistema recrie corretamente evitando error.log.
				FErase(cArquivo,,.T.)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} FClear428
Função que realiza limpeza do objeto/conteudo do CheckBox,
necessário devido incompatibilidade com o LoboGuara.

@Param aProcSel - Opções Lidas no Profile

@Author Denis Souza
@Since 24/01/2019
/*/
//-------------------------------------------------------------------
static function FClear428( aProcSel, oChk01, oChk02, oChk03, oChk04, lChk01, lChk02, lChk03, lChk04, nEscop )
	aProcSel := Nil
	oChk01 	 := Nil
	oChk02 	 := Nil
	oChk03 	 := Nil
	oChk04 	 := Nil
	lChk01 	 := .F.	//limpeza tafst1
	lChk02 	 := .F.	//processamento tafst2
	lChk03 	 := .T.	//transferencia tafst1/tafst2
	lChk04 	 := .F.	//validacao
	nEscop 	 := 1	//selecionar escopo

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TemReg()
Verifica se existem registros para processar nas tabelas TAFST1 
e TAFST2.

nOpcEscopo - Escopo de integração (3 = Esocial)

@author Katielly Feitosa
@since 20/11/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function TemReg(lChkBox0, lChkBox1, lChkBox2, aLisFil, nOpcEscopo)

	Local aRetFilCR9 	as array
	Local aRetFils		as array
	Local cSelect 		as character 
	Local cFrom			as character
	Local cWhere 		as character
	Local cOrderBy		as character
	Local cTopRow		as character
	Local cRetFils  	as character
	Local lRet 			as logical	
	Local nX 			as numeric	
	Local cBanco 		as character

	aRetFilCR9 	:= {}
	aRetFils	:= {}
	cSelect 	:= ''
	cFrom		:= ''
	cWhere		:= ''
	cOrderBy	:= ''
	cTopRow		:= ''
	cRetFils	:= ''
	lRet		:= .F.

	Default lChkBox0 := .F.
	Default lChkBox1 := .F.
	Default lChkBox2 := .F.
	Default nOpcEscopo := 0

	/*
		A função temReg inicialmente validava se existia registros na TAFST1 e TAFST2, de acordo com os checkbox's selecionados:
		lChkBox0 => ST1 p/ ST2
		lChkBox1 => Limpeza de Base
		lChkBox2 => ST2 p/ TAF

		Porem para TAF segregado, foi necessário mudar a lógica e foi incluído a função ChkTAFST1. 
		Agora os checkbox's da TAFST1 ficam habilitados caso aja registros na ST1 ( ChkTAFST1 ).

		Portanto ao chegar aqui, a TAFST1 já foi verificada e analisada ( tanto segregado quanto módulo ).

		A única mudança, é que para a ST2, o array aLisFil é novamente construído, 
		considerando apenas as filiais que tenham registros pendentes. 

		EX: Filiais: 01, 02 e 03 marcadas pela função MatFilCalc, porém apenas a filial 02 ( ou CR9 desta filial ) tem registros a serem processados.
		o array aLisFil será construído apenas com a filial 02. 
		Dessa forma o TAFAINTEG será chamado somente para as filiais que tenham registros, evitando desperdício de processamento.

		Essa reconstrução do array aLisFil é feita apenas se o checkbox ST2 p/ TAF estiver selecionado sozinho.
		Porque da forma que o fonte foi estrturado, o array aLisFil é pecorrido e as operações são executadas na ordem para cada filial:

		1 - lChkBox0 => ST1 p/ ST2
		2 - lChkBox2 => ST2 p/ TAF
		3 - lChkBox1 => Limpeza de Base

		Se o aLisFil fosse reconstruído para todas as operações, alguma filial ST1 ou ST2 poderia ficar fora do array.


	*/
	If lChkBox2 .and. !( lChkBox0 .or. lChkBox1 )

		For nX := 1 to Len( aLisFil )

			If aLisFil[nx][1]

				AAdd(aRetFils, aLisFil[nX][2])

			EndIf

		Next nX

		cRetFils := TAFCacheFil("C1E", aRetFils, .T.)
	
		If !Empty(cRetFils)

			aRetFilCR9 := Taf428Cr9(cRetFils)
			
			AEval(aRetFilCR9, {|x| AAdd(aRetFils, x)})

			cRetFils := TAFCacheFil("C1E", aRetFils, .T., GetSX3Cache("C1E_CODFIL", "X3_TAMANHO"))

			If nOpcEscopo == 3 
				cBanco := Upper(AllTrim(TcGetDB()))
				retiraFila(cBanco) //DSERTAF1-29562
			EndIf 
			lRet := TemFil4Proc(cRetFils, @aLisFil)

		EndIf

	Else
		lRet := lChkBox0 .or. lChkBox1
	Endif

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} TAFSelEv
Função utilizada para seleção das rotinas a serem integredas da TAFST2 para o TAF

@Author		Márcio Santos
@Since		21/11/2019
@version 1.0

/*/
//---------------------------------------------------------------------------
Function TAFSelEv(aLisFil as array, lChkBox0 as logical, lChkBox1 as logical, lChkBox2 as logical)

	Local aRetFilCR9	as array
	Local aRetFils		as array
	Local aFilter		as array
	Local aColumns		as array
	Local oDialog		as object
	Local cQuery 		as character
	Local cRetFils		as character
	Local cBancoDB		as character
	
	Local nX			as numeric
	Local nY			as numeric
	Local bData			as boolean
	Local cAliasEv		as character	
	Local cAlias		as character
	Local lMarkAll		as logical
	Local oBrowse		as object

	Private aEventos	as array

	Default aLisFil 	:= {}
	Default lChkBox0	:= .F.
	Default lChkBox1	:= .F.
	Default lChkBox2	:= .F.

	aRetFilCR9	:= {}
	aRetFils	:= {}
	aFilter		:= {}
	aColumns	:= {}
	oDialog		:= Nil
	cQuery 		:= ""
	cRetFils	:= ""
	cBancoDB	:= TCGetDb()
	nX			:= 0
	nY			:= 0
	bData		:= {||}
	cAliasEv	:= GetNextAlias()	
	cAlias		:= GetNextAlias()
	lMarkAll	:= .F.
	oBrowse		:= Nil

    aEventos	:= {}

	If lChkBox2 .and. !( lChkBox0 .or. lChkBox1 )

		For nY := 1 to Len( aLisFil )

			If aLisFil[nY][1]

				AAdd(aRetFils, aLisFil[nY][2])

			EndIf

		Next nY

		cRetFils := TAFCacheFil("C1E", aRetFils, .T.)

		If !Empty(cRetFils)

			aRetFilCR9 := Taf428Cr9(cRetFils)

			AEval(aRetFilCR9, {|x| AAdd(aRetFils, x)})

			cRetFils := TAFCacheFil("C1E", aRetFils, .T., GetSX3Cache("C1E_CODFIL", "X3_TAMANHO"))

		EndIf
	
	EndIf

	If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
		cQuery += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK"
	Else
		cQuery += " SELECT DISTINCT '  ' MARK"
	EndIf

	cQuery += ", ST2.TAFTPREG, C8E.C8E_DESCRI  "
	cQuery += "FROM TAFST2 ST2,  " + RetSqlName( "C8E" ) + " C8E "
	cQuery += "WHERE ST2.TAFFIL IN ( SELECT FILIAIS.FILIAL FROM " + cRetFils + " FILIAIS ) "
	cQuery += "AND ST2.TAFSTATUS = '1' "
	cQuery += "AND ST2.TAFIDTHRD = '' "
	cQuery += "AND ST2.TAFTPREG = C8E.C8E_CODIGO "
	cQuery += "AND ST2.D_E_L_E_T_ = '' "
	cQuery += "AND C8E.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY ST2.TAFTPREG "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasEv, .F., .T.)

	If (cAliasEv)->(!Eof())

		aAdd( aEventos, { "TAFTPREG",	"C", 6,  	0,	"Evento"		, "@!" 	}	)
		aAdd( aEventos, { "C8E_DESCRI",	"C", 200,	0,	"Descrição"		, "@!" 	}	)

		For nX := 1 To Len( aEventos )
		
			aAdd( aColumns, FWBrwColumn():New() )
			bData := &( "{||" + aEventos[nX][1] + "}")


			aColumns[nX]:SetData( bData )
			aColumns[nX]:SetTitle( aEventos[nX][5] )
			aColumns[nX]:SetPicture( aEventos[nX][6] )
			aColumns[nX]:SetSize( aEventos[nX][3] )
			aColumns[nX]:SetDecimal( aEventos[nX][4] )

			aAdd( aFilter,{ aEventos[nX][1], aEventos[nX][5], aEventos[nX][2], aEventos[nX][3], 0, "" } )
			
		Next nX


		oDialog := MsDialog():New( 10, 30, 640, 640,STR0066,,,,,,,,,.T.,,,,.F. )
		// oDialog :=  TDialog():New( 10, 30, 600, 600,"Selecione os Eventos",,,,,,,,,.T.)

		// Cria uma coluna de marca/desmarca
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetQuery(cQuery)
		oBrowse:SetAlias( cAlias )
		oBrowse:SetFieldMark( "MARK" )
		oBrowse:SetAllMark( {|| MarkAll( oBrowse, @lMarkAll)} )
		oBrowse:SetColumns( aColumns )
		

		oBrowse:AddButton( "Confirmar"	, { || oDialog:End(), FilEvent(cAlias, lMarkAll) } )
		oBrowse:AddButton( "Cancelar"	, { || oDialog:End(),  } )

		// Ativação do Browse
		oBrowse:Activate(oDialog)
		
		// Ativação da janela
		// Activate MsDialog oDialog ON INIT ENCHOICEBAR( oDialog, { || oDialog:End(), FilEvent() }, { || oDialog:End() },, ) Centered
		ACTIVATE MSDIALOG oDialog CENTERED 
		// oDialog:Activate(,,,.F.,,,)

	Else

		MsgInfo(STR0073, STR0074)

	EndIf

Return 

//---------------------------------------------------------------------------
/*/{Protheus.doc} FilEvent
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

@Author		Márcio Santos
@Since		21/11/2019
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function FilEvent(cAlias, lMarkAll)

	Default cAlias := ""

	If !(EMPTY(cAlias))
		(cAlias)->(dbGoTop())

		While (cAlias)->(!Eof())
			If lMarkAll
				cFilEvent += " '" + Alltrim((cAlias)->TAFTPREG) + "',"
			ElseIf !EMPTY((cAlias)->MARK)
				cFilEvent += " '" + Alltrim((cAlias)->TAFTPREG) + "',"
			EndIf
			(cAlias)->( dbSkip() )
		EndDo
		
		cFilEvent	:=	subStr( cFilEvent , 1 , len( cFilEvent ) - 1 )
	EndIf

return 

//---------------------------------------------------------------------------
/*/{Protheus.doc} MarkAll

Inverte a indicação de seleção de todos registros da MarkBrowse.

@Param		aEventos -	Array com as informações	

@Return		Nil

@Author		Márcio Santos
@Since		21/11/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MarkAll( oBrowse, lMarkAll )

	If lMarkAll
		lMarkAll := .F.
	Else
		lMarkAll := .T.
	EndIf

	oBrowse:AllMark()
	oBrowse:Refresh()

Return 

//---------------------------------------------------------------------------
/*/{Protheus.doc} Taf428Cr9

Busca as filiais de outras filiais com base no C1E_CODFIL selecionado em tela.

@Param		cFilsPar - Filiais contidas em C1E no formato de C1E_CODFIL

@Return		Nil

@Author		Henrique Pereira, Katielly Rezende
@Since		29/11/2019
@Version	1.0
/*/
//---------------------------------------------------------------------

static Function Taf428Cr9(cFilsPar)

	Local aFilret		:= {}
	Local cSql 			:= ""
	Local cFils 		:= GetNextAlias()
	Local cVldFil		:= ""
	Local lIsOpenEdge	:= AllTrim(Upper(TcGetDb())) == "OPENEDGE"

	Default cFilsPar	:=	""

	If !Empty(cFilsPar)

		If lIsOpenEdge
		
			cSql := " SELECT C1E_FILIAL, C1E_CODFIL, C1E_ID, C1E_VERSAO, C1E_ATIVO FROM " + RetSqlName("C1E") + " C1E "
			cSql += " WHERE C1E.C1E_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFilsPar + " FILIAIS ) "
			cSql += " AND C1E.C1E_ATIVO = '1' "
			cSql += " AND C1E.C1E_CODFIL <> '<NPI>' "
			cSql += " AND C1E.D_E_L_E_T_ = ' ' "

			cSql := ChangeQuery (cSql)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cFils,.F.,.T.)

			CR9->(DbSetOrder(3)) //CR9_FILIAL+CR9_ID+CR9_ATIVO
			If (cFils)->(!Eof())
				While (cFils)->(!Eof())

					AAdd(aFilret, AllTrim((cFils)->C1E_CODFIL))

					If CR9->(DbSeek( (cFils)->(C1E_FILIAL + C1E_ID + C1E_ATIVO ) ) )
						While CR9->(CR9_FILIAL+CR9_ID+CR9_ATIVO) == (cFils)->(C1E_FILIAL + C1E_ID + C1E_ATIVO)
							
							AAdd(aFilret, AllTrim(CR9->CR9_CODFIL))

							CR9->(DbSkip())
						End					
					EndIf
					(cFils)->(DbSkip())
				End
			EndIf

		Else

			cSql := " SELECT C1E_CODFIL, CR9_CODFIL FROM " + RetSqlName("C1E") + " C1E "
			cSql += " LEFT JOIN " + RetSqlName("CR9") + " CR9 "
			cSql += " ON C1E.C1E_ID = CR9.CR9_ID AND C1E.C1E_VERSAO = CR9.CR9_VERSAO AND CR9.D_E_L_E_T_ = ' ' "
			cSql += " WHERE C1E.C1E_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFilsPar + " FILIAIS ) "  
			cSql += " AND C1E.C1E_ATIVO = '1' "
			cSql += " AND C1E.C1E_CODFIL != '<NPI>' "
			cSql += " AND C1E.D_E_L_E_T_ = ' ' "

			cSql := ChangeQuery(cSql)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cFils,.F.,.T.)

			If (cFils)->(!Eof())
				While (cFils)->(!Eof())

					If !( AllTrim( ( cFils )->C1E_CODFIL ) == cVldFil )
						
						AAdd(aFilret, AllTrim((cFils)->C1E_CODFIL))

						cVldFil := AllTrim( ( cFils )->C1E_CODFIL )
					EndIf

					if !Empty( (cFils)->CR9_CODFIL )

						AAdd(aFilret, AllTrim((cFils)->CR9_CODFIL))

					EndIf

					(cFils)->(dbSkip())
				End
			EndIf

			( cFils )->( dbCloseArea( ) )

		EndIf
	EndIf

Return aFilret

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ChkTAFST1()

Verifica a existencia da TAFST1 segregado ou nao e a pendencia de processamento
@author Denis Souza
@since 01/08/2020
@version 1.0
@return

/*/ 
//-----------------------------------------------------------------------------

Function ChkTAFST1()

Local cMVTafTali := GetNewPar( 'MV_TAFTALI', '' ) //P12125MNTDBEXP
Local cMVTafTDB  := GetNewPar( 'MV_TAFTDB' , '' ) //ex:MSSQL
Local nMVTafPort := GetNewPar( 'MV_TAFPORT', 0  ) //ex: 7892
Local aTopInfo	 := FwGetTopInfo() //secao de top no ini do TAF
Local nHdlLink 	 := 0
Local lTafModulo := .T.
Local lEncConn   := .F.
Local lRet       := .F.

if len(aTopInfo) >= 5 .And. aTopInfo[3] > 0 .And. !Empty( aTopInfo[5] ) //porta e alias
	if aTopInfo[3] <> nMVTafPort .Or. Alltrim(Upper(aTopInfo[5])) <> Alltrim(Upper( cMVTafTali ))
		lTafModulo := .F.
	endif
endif

if !lTafModulo //se nao for modulo conecta em outro bd para verificar ST1
	if FConectTAF( cMVTafTali, cMVTafTDB, nMVTafPort, lEncConn, @nHdlLink )
		//Caso ocorra exito na conexao consulto a situacao da TAFST1
		lRet := TemRegST1()
		If nHdlLink >= 0 //Encerra a Conexão após a consulta na tabela TAFST1
			TCUnlink( nHdlLink )
		EndIf
	else //caso ocorra falha na conexao com outro banco mantenho a opcao habilitada para nao impedir o processo
		lRet := .T.
	endif
else //caso seja modulo verifica diretamente
	lRet := TemRegST1()
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TemRegST1()

Verifica existencia de registro pendentes de transferencia na TAFST1

@author Denis Souza
@since 01/08/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function TemRegST1()

Local lRet 	   := .F. //"Não Localizou nenhum registro pendente"
Local cAlias   := GetNextAlias()
Local cTab	   := "TAFST1"
Local cBd  	   := Alltrim( Upper( TcGetDb( ) ) )
Local cSelect  := ""
Local cTopRow  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrderBy := ""
Local cIdEmpty := space(10)
Local cStatus  := '1'

if TCCanOpen( cTab )
	If cBd $ "ORACLE|DB2|POSTGRES|OPENEDGE|"
		cSelect := " R_E_C_N_O_ "
		If cBd $ "ORACLE|"
			cTopRow := " AND ROWNUM <= 1 "
		ElseIf cBd $ "POSTGRES|"
			cTopRow := " LIMIT 1 "
		Elseif  cBd $ "DB2|"
			cTopRow := " FETCH FIRST 1 ROWS ONLY "
		EndIf
	ElseIf cBd $ "INFORMIX|"
		cSelect := " FIRST 1 ST1.R_E_C_N_O_ "
	ElseIf cBd $ "MSSQL7|"
		cSelect := " TOP 1 R_E_C_N_O_ "
	EndIf

	cFrom 	 := cTab + " ST1 "
	cWhere 	 := " ST1.D_E_L_E_T_ = ' ' AND ST1.TAFSTATUS = '" + cStatus + "' AND ST1.TAFIDTHRD = '" + cIdEmpty + "' "
	cOrderBy := " ST1.R_E_C_N_O_ DESC "

	If !(cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
		cWhere  += cTopRow
	Elseif (cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
		cOrderBy += cTopRow
	EndIf

	cSelect  := "%" + cSelect  + "%"
	cFrom	 := "%" + cFrom	   + "%"
	cWhere	 := "%" + cWhere   + "%"
	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAlias
		SELECT 	 %Exp:cSelect%
		FROM	 %Exp:cFrom%
		WHERE 	 %Exp:cWhere%
		ORDER BY %Exp:cOrderBy%
	EndSql
endif

If Select(cAlias) > 0
    (cAlias)->(DbGoTop())

    If (cAlias)->(!Eof())
	    lRet := .t. //Localizou registros
    EndIf

    (cAlias)->(DbCloseArea())
EndIf

return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TemFil4Proc

Retorna as filiais que possuem registros a processar.

@param	cFils - String montada com filiais e CR9 que serão utilizadas na query
		aLisFil - Array que será recconstruído com as filiais a serem processadas
@return lTemReg - Indica se tem ou não registros pendentes de processamento na TAFST2

@author	Wesley Pinheiro 

@since	26/09/2020
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TemFil4Proc( cFils, aLisFil )

    Local cWhere   := ""
	Local cAlias   := GetNextAlias( )
	Local lTemReg  := .F.

	aLisFil := { }

    cWhere += " TAFST2.D_E_L_E_T_ = ' ' "
    cWhere += " AND TAFST2.TAFSTATUS = '1' "
    cWhere += " AND (TAFST2.TAFIDTHRD = ' ' "
	cWhere += " OR TAFST2.TAFSTQUEUE = 'F')"
	cWhere += " AND TAFFIL IN ( SELECT FILIAIS.FILIAL FROM " + cFils + " FILIAIS ) " 

    cWhere  := "%" + cWhere + "%"

	BeginSql alias cAlias
	
		SELECT C1E_FILTAF, TAFST2.TAFOWNER TAFOWNER
			FROM TAFST2 TAFST2
		INNER JOIN %table:C1E% C1E
			ON C1E.C1E_CODFIL = TAFST2.TAFFIL
			AND C1E.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		WHERE %Exp:cWhere%
		GROUP BY C1E_FILTAF, TAFST2.TAFOWNER

		UNION
	
		SELECT C1E_FILTAF, TAFST2.TAFOWNER TAFOWNER
			FROM TAFST2 TAFST2
		INNER JOIN %table:CR9% CR9
			ON TAFST2.TAFFIL = CR9.CR9_CODFIL
			AND CR9.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		INNER JOIN %table:C1E% C1E
			ON C1E.C1E_ID = CR9.CR9_ID
			AND C1E.D_E_L_E_T_ = TAFST2.D_E_L_E_T_
		WHERE %Exp:cWhere%
		GROUP BY C1E_FILTAF, TAFST2.TAFOWNER
		ORDER BY 1 
	
	EndSql

	dbSelectArea(cAlias)
    ( cAlias )->( dbEval(  { || aAdd( aLisFil, { .T., C1E_FILTAF } ) } ) )
    ( cAlias )->( dbCloseArea( ) )

	lTemReg := IIF( Len( aLisFil ) > 0, .T., .F. )

Return lTemReg

//----------------------------------------------------------------------------
/*/{protheus.doc} TafGpEmp 

Verifica Grupo \ Empresa e atualiza se possui pendencia de processamento

@author Denis souza
@since 05/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafGpEmp( aParam, aEmpSM0 )

Local nlA 		:= 0
Local nPos 		:= 0
Local nTmGpEmp 	:= 0
Local aGbGpEmp 	:= {}
Local aTafFil   := {}
Local lDemand   := .F.

Default aParam	:= {}
Default aEmpSM0	:= {}

if len( aParam ) > 0
	//Caso receba um parametro no job, ex: TAFFISMT(.T.) //A 1° posicao se refere sobre demanda
	//o intuito da sobredemanda eh processar todos os grupos e empresas com apenas um job cadastrado.

	if valtype( aParam[1] ) == "L" .And. aParam[1] //Sobre Demanda

		//variavel global para nao entrar toda vez na funcao abaixo, uma vez carregado os grupos\empresas em cache
		//ja eh o suficiente, nao sera sobrecarregado, mesmo se o job estivar no modo sempre ativo.
		GetGlbVars('aTafGrpEmp' , @aGbGpEmp )

		if len(aGbGpEmp) == 0 //primeira vez, a partir da segunda execucao nao sera mais necessario entrar aqui
			TafGrpXEmp(@aGbGpEmp)
			PutGlbVars( "aTafGrpEmp", aGbGpEmp )
		endif

		//Restaura CheckPoint com os status .F.
		aEmpSM0 := aclone( aGbGpEmp )

		//obtenho o grupo vindo do schedule, com parametro fica na segunda posicao
		cGrpJob := alltrim( aParam[2] )

		lDemand := .T.
	else
		//mantem fluxo normal sem pametro enviado na funcao dentro do job, ex: TAFFISMT()
		//aqui o funcionamento eh um agent por grupo + um cadastro do taffisxmt por grupo empresa
		cGrpJob := alltrim( aParam[1] ) //obtenho o grupo vindo do schedule, sem parametro fica na primeira posicao

		aadd( aEmpSM0 , {cGrpJob, .F.} )
	endif

	//Inicio o ambiente para nao ocorrer falha de DBUseArea - DB driver not initialized na funcao abaixo TafFilPend
	TafDBDriver(cGrpJob,.F.)

	//Obtem tamanho do grupo
	nTmGpEmp := len( cGrpJob )

	if lDemand //verifica todos os grupos \ empresas
		cGrpJob := ""
	endif

	//Verifica grupos pendentes de processamento, necessario algum ambiente preparado
	TafFilPend( @aTafFil, nTmGpEmp, cGrpJob )

	//apos verificacao encerro o ambiente
	RpcClearEnv( )

	//Atualiza status dos grupos que deverao ser processados
	for nlA := 1 to len( aTafFil )
		nPos := aScan( aEmpSM0 , {|x| AllTrim(x[1]) == aTafFil[nlA] } )
		if nPos > 0
			aEmpSM0[nPos][2] := .T. //habilita grupo para ser processado
		endif
	Next nlA
endif

//limpeza dos arrays devido servico sempre ativo e nao aumentar consumo de memoria
aSize(aTafFil ,0)
FwFreeArray(aTafFil)
aTafFil := Nil

aSize(aGbGpEmp ,0)
FwFreeArray(aGbGpEmp)
aGbGpEmp := Nil

Return Nil

//----------------------------------------------------------------------------
/*/{protheus.doc} TafGrpXEmp 
retorna array com os codigos das empresas ou grupos de empresas contidos na sm0

@author Denis Souza
@since 02/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafGrpXEmp(aEmpsRet)

	Local nX 		 := 0
	Local nAte		 := 0
	Local nPosEmp 	 := 0
	Local aLoadSM0	 := 0
	Local cGrpEmp    := ""
	Default aEmpsRet := {}

	OpenSm0(,.T.) //necessario abrir para o load funcionar
	aLoadSM0 := FWLoadSM0( .T. )

	nAte := len( aLoadSM0 )
	for nX := 1 to nAte
		nPosEmp := 0
		cGrpEmp := AllTrim(aLoadSM0[nX][1])
		If Len(aEmpsRet) > 0
			nPosEmp := aScan(aEmpsRet,{|x|AllTrim(x[1]) == cGrpEmp })
		EndIf
		//Verifico se a empresa não existe no array de retorno.
		If nPosEmp == 0
			aAdd(aEmpsRet,{cGrpEmp,.F.})
		EndIf
	next nX

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafFilPend 
Verifica se existe algum TAFFIL na TAFST2 pendente de processamento

@author Denis Souza
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafFilPend( aTafFil, nTmGpEmp, cGrpJob )

	Local cSelect    := " DISTINCT( TAFFIL ) TAFFIL "
	Local cFrom      := " TAFST2 "
	Local cWhere     := " TAFSTATUS = '1' AND TAFIDTHRD = ' ' AND D_E_L_E_T_ = ' ' "
	Local cGroupBy   := " TAFFIL "
	Local cOrderBy   := " TAFFIL "
	Local cAliasQry  := GetNextAlias()
	Local cGpEmp     := " "
	Local nPos		 := 0
	Local cBd        := TcGetDb( )

	Default aTafFil  := {}
	Default nTmGpEmp := 0
	Default cGrpJob  := ""

	if !empty( cGrpJob )
		If cBd $ "ORACLE|POSTGRES|DB2"
			cWhere += " AND SUBSTR(TAFFIL,1," + cValToChar(nTmGpEmp) + ") = '" + cGrpJob + "' "
		ElseIf cBd $ "INFORMIX"
			cWhere += " AND TAFFIL[1," + cValToChar(nTmGpEmp) + "] = '" + cGrpJob + "' "
		Else //MSSQL,MYSQL,PROGRESS
			cWhere += " AND SUBSTRING(TAFFIL,1," + cValToChar(nTmGpEmp) + ") = '" + cGrpJob + "' "
		EndIf
	endif

	cSelect	 := "%" + cSelect  + "%"
	cFrom	 := "%" + cFrom    + "%"
	cWhere	 := "%" + cWhere   + "%"
	cGroupBy := "%" + cGroupBy + "%"
	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%
		GROUP BY %Exp:cGroupBy%
		ORDER BY %Exp:cOrderBy%
	EndSql

	( cAliasQry )->( DbGoTop() )
	if ( cAliasQry )->(!EOF())
		while ( cAliasQry )->( !Eof() )
			cGpEmp := SubStr(Alltrim((cAliasQry)->TAFFIL),1,nTmGpEmp)
			nPos := aScan( aTafFil , {|x| x == cGpEmp } )
			if nPos == 0
				aadd(aTafFil,cGpEmp)
			endif
			( cAliasQry )->( DbSkip() )
		EndDo
	else
		TAFConOut("Nao foram encontrados registros para serem processados.")
	endif
	( cAliasQry )->( DBCloseArea() )

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafDbDriver
Inicializacao do ambiente no grupo correspondente ao processamento pendente,
para nao ocorrer falha de DBUseArea - DB driver not initialized

@author Denis Souza
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafDbDriver(cGrpJob,lConsole)

	Default cGrpJob := cEmpAnt
	Default lConsole := .F.

	iif(lConsole,TAFConout('***Preparando ambiente. Grupo: ' + cGrpJob,2,.T.,"INTEG" ),)
	RpcSetType(3)

	iif(lConsole,TAFConout('***Ambiente preparado. Grupo : ' + cGrpJob,2,.T.,"INTEG"),)
	RpcSetEnv(cGrpJob,,,,"TAF","TAFA428",,,,.T.,)

	//Apos a preparacao de ambiente nao se faz necessario atualizar a variavel cEmpAnt, somente posicionamento na SM0
	SM0->(dbSetorder(1)) //M0_CODIGO, M0_CODFIL, R_E_C_N_O_, D_E_L_E_T_
	SM0->(dbSeek(cGrpJob))
	iif(lConsole,TafConOut('***cEmpAnt: ' + cEmpAnt + ' FWGrpCompany: ' + FWGrpCompany() + ' M0_CODIGO: ' + SM0->M0_CODIGO),)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} retiraFila
Função para ajustes de registros do ERP DataSul com erro de predecessão e 
configurados como "Fila"

@param cBanco - Banco de dados do Ambiente 

@author Evandro dos Santos Oliveira
@since 06/05/2022
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function retiraFila(cBanco)

	Local cSql := ""
	Local cSqlAux := ""
	Local nRecno := 0
	Local lExecute := .F.
	
	Default cBanco := "" 

	//Verifica se o ERP é DATASUL selecionando 1 regitro da TAFST2
	If (cBanco $ ("MSSQL|MSSQL7|ORACLE|POSTGRES|" )) 

		If (cBanco $ ("MSSQL|MSSQL7" )) 
			cSql := "SELECT TOP 1 TAFOWNER "
		Else
			cSql := "SELECT TAFOWNER "
		EndIf

		cSql += "FROM TAFST2 "
		cSql += "WHERE "
		cSql += "TAFTPREG = 'S-2230' "
		cSql += "AND TAFOWNER = 'DATASUL' "
		cSql += "AND TAFSTQUEUE = 'F' "  
		cSql += "AND D_E_L_E_T_ = ' ' "		

		If cBanco == "ORACLE"
			cSql += "AND ROWNUM <= 1 " 
		ElseIf cBanco $ "POSTGRES"
			cSql += "LIMIT 1 " 
		EndIf 

		cSql := ChangeQuery(cSql)

		TcQuery cSql New Alias 'tafowner'

		If tafowner->(!Eof()) 
			lExecute := .T. 
		EndIf  

		tafowner->(dbCloseArea())
	Else 

		//Pego o TAFOWNER do registro integrado, em tese se o cliente não usar 2 ERPs este campo só terá 1 valor.
		cSql := " SELECT MAX(R_E_C_N_O_) RECNO FROM TAFST2"
		TcQuery cSql New Alias 'maxrecno'

		If !Empty(maxrecno->RECNO) 
			nRecno := maxrecno->RECNO
		EndIf  

		maxrecno->(dbCloseArea())

		cSql := " SELECT TAFOWNER FROM TAFST2 WHERE R_E_C_N_O_ = " + cValToChar(nRecno)
		TcQuery cSql New Alias 'tafowner'

		If tafowner->(!Eof()) .And. AllTrim(tafowner->TAFOWNER) == 'DATASUL'
			lExecute := .T. 
		EndIf  

		tafowner->(dbCloseArea())
	EndIf 

	If lExecute

		//*Sempre que um registro está em fila o mesmo está com STATUS 4
		//*Se existirem 2 registros na TAFXERP com status diferentes quer dizer
		//que o registro saiu da fila, isso por que os status possiveis para 
		//este caso é o 4 e um dos status a seguir 3,7 e 9.
		//*Se existir somente 1 registro com status 4 na TAFXERP quer dizer que 
		//o registro está sem fila, nesta situação retiro o registro do estado 
		//de fila voltando o status da TAFST2 para 1 e limpando o campo TAFSTQUEUE

		BEGIN TRANSACTION 

		cSql := " UPDATE TAFST2"  
		cSql += " SET TAFSTATUS = '3' , TAFSTQUEUE = 'X'"
		cSql += " WHERE R_E_C_N_O_ IN"
		cSql += " ("
		cSql += " SELECT RECNOST2"
		cSql += " FROM"
		cSql += " ("
		cSql += " SELECT ST2.R_E_C_N_O_ RECNOST2,"
		cSql += " XERP.TAFSTATUS XERPSTATUS"
		cSql += " FROM TAFST2 ST2"
		cSql += " INNER JOIN TAFXERP XERP ON ST2.TAFKEY = XERP.TAFKEY"
		cSql += " AND ST2.TAFTICKET = XERP.TAFTICKET"
		cSql += " WHERE"
		cSql += " ST2.TAFTPREG = 'S-2230'"
		cSql += " AND ST2.TAFOWNER = 'DATASUL'"
		cSql += " AND ST2.TAFSTQUEUE = 'F'"  
		cSql += " AND ST2.D_E_L_E_T_ = ' '"
		cSql += " AND XERP.D_E_L_E_T_ = ' '"
		cSql += " GROUP BY XERP.TAFSTATUS"
		cSql += " ,ST2.R_E_C_N_O_ 
		cSql += " ) FILA"
		cSql += " GROUP BY RECNOST2, XERPSTATUS"
		cSql += " HAVING COUNT(RECNOST2) = 1"
		cSql += " AND XERPSTATUS = '4'"
		cSql += " )"

		//cSql := ChangeQuery(cSql) --travando D-1 07/05/2022

		If TCSQLExec(cSql) >= 0
			//Rejeito os registros encontrados na TAFXERP, como podem existir
			//+ de um registro com o mesmo TAFKEY, rejeito todos.
			cSql := " UPDATE TAFXERP" 
			cSql += " SET TAFSTATUS = '9'"
			cSql += " WHERE TAFKEY IN("
			cSql += " SELECT TAFKEY"
			cSql += " FROM TAFST2" 
			cSql += " WHERE TAFTPREG = 'S-2230'"
			cSql += " AND TAFOWNER = 'DATASUL'"
			cSql += " AND TAFSTQUEUE = 'X'"
			cSql += " )"

			//Recuso a Fila na TAFST2 para ficar no padrão.
			cSqlAux := " UPDATE TAFST2" 
			cSqlAux += " SET TAFSTQUEUE = 'R'"
			cSqlAux += " WHERE TAFTPREG = 'S-2230'"
			cSqlAux += " AND TAFOWNER = 'DATASUL'"
			cSqlAux += " AND TAFSTQUEUE = 'X'"

			If TCSQLExec(cSql) >= 0 .And. TCSQLExec(cSqlAux) >= 0
				TafConOut("Realizado analise de registros em Fila")
			EndIf  
		EndIf 

		END TRANSACTION
	EndIf 

Return Nil 
