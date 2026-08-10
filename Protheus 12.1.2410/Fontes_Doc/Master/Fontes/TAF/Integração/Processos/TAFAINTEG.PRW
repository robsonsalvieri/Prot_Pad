#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "COLORS.CH"

#DEFINE TAMMAXXML 400000  //Tamanho Maximo do XML

// --------------------------------------------------------------------------------------------------------

//DEFINIÇÕES DE LAYOUT DO ARQUIVO LAYOUT.DEF
#DEFINE Z1_LAYOUT		01
#DEFINE Z1_DESC		02
#DEFINE Z1_ADAPT		03
#DEFINE Z1_TABLE		04
#DEFINE Z1_DESTAB		05
#DEFINE Z1_ORDER		06
#DEFINE Z1_MVCOPT		07 
#DEFINE Z1_MVCMET		08
#DEFINE Z1_CHANELS	09

#DEFINE Z2_CHANEL		01
#DEFINE Z2_SUPER		02
#DEFINE Z3_RELAC		03
#DEFINE Z3_DESC		04
#DEFINE Z3_IDOUT		05
#DEFINE Z3_OCCURS		06
#DEFINE Z3_ORDER		07
#DEFINE Z3_FIELDS		08

#DEFINE Z4_SEQ		01
#DEFINE Z4_FIELD		02
#DEFINE Z4_DESC		03
#DEFINE Z4_TYPFLD		04
#DEFINE Z4_SOURCE		05
#DEFINE Z4_EXEC		06

// --------------------------------------------------------------------------------------------------------
// DEFINICOES DE INTEGRCAO BANCO A BANCO
//#DEFINE 	nTopSlct		9999999
#DEFINE 	cST1TAB		    "TAFST1"	// Nome DEFINIDO da tabela compartilhada no dominio do ERP
#DEFINE 	cST2TAB		    "TAFST2"	// Nome DEFINIDO da tabela compartilhada no dominio do TAF
#DEFINE 	cTAFXERP		"TAFXERP"	// Nome DEFINIDO da tabela de controle de integrações ( TICKET )

// --------------------------------------------------------------------------------------------------------
// STATUS DE REGISTROS TAF - TABELAS TAFST1/TAFST2
#DEFINE	cStsReady		"1"			// Registros em prontos para ser processados
#DEFINE	cStsProc		"2"			// Registros em Processamento (ja identificados/separados pela Slice)
#DEFINE	cStsFinal		"3"			// Registros em Ja processados / Finalizados

// --------------------------------------------------------------------------------------------------------
// TIPOS DE REGISTROS  - TABELAS TAFST1/TAFST2
#DEFINE	cTAFCodTxt    "1"			// Codigo para mensagens de texto
#DEFINE	cTAFCodESoc   "2"			// Codigo para mensagens XML eSocial
#DEFINE	cTAFCodNFe		"3"			// Codigo para mensagens XML NFe

// --------------------------------------------------------------------------------------------------------
// SEMAFORO PARA CONTROLAR CARREGAMENTO DAS VARIAVEIS aLayOut e aLayDel
#DEFINE _NO_LOAD  0 // NAO CARREGADO
#DEFINE _LOADING  1 // CARREGANDO
#DEFINE _LOADED   2 // CARREGADO 

#DEFINE	 aTafFiscal {		{"","TAF026Vld", "","C0Q","T001AC",""},;
							{"","TAF027Vld", "","C0R","T001AE",""},;
			   				{"","TAF029Vld", "","C0T","T012",""},;
			            	{"","TAF031Vld", "","C0W","T001AD",""},;
			            	{"",""		   , "","C1E","T001",""},;
			            	{"","TAF051Vld", "","C1G","T001AB",""},;
			            	{"","TAF053Vld", "","C1H","T003",""},;
			            	{"","TAF055Vld", "","C1J","T005",""},;
			            	{"","TAF056Vld", "","C1K","T006",""},;
			            	{"","TAF057Vld", "","C1L","T007",""},;
			            	{"","TAF058Vld", "","C2L","T008",""},;
			            	{"","TAF059Vld", "","C1N","T009",""},;
			            	{"","TAF086Vld", "","C55","T070",""},;
			            	{"","TAF094Vld", "","C5A","T079",""},;
			            	{"","TAF095Vld", "","C5Q","T080",""},;
			            	{"","TAF061Vld", "","C1P","T011",""},;
			            	{"","TAF064Vld", "","C2N","T022",""},;
			            	{"","TAF067Vld", "","C3B","T030",""},;
			            	{"","TAF068Vld", "","C4I","T031",""},;
			            	{"","TAF069Vld", "","C4L","T032",""},;
			            	{"","TAF070Vld", "","C40","T033",""},;
			            	{"","TAF071Vld", "","C5I","T034",""},;
			            	{"","TAF072Vld", "","C4Q","T035",""},;
			            	{"","TAF073Vld", "","C4B","T036",""},;
			            	{"","TAF074Vld", "","C6M","T037",""},;
			            	{"","TAF075Vld", "","C4R","T050",""},;
			            	{"","TAF076Vld", "","C4E","T060",""},;
			            	{"","TAF077Vld", "","C5E","T061",""},;
			            	{"","TAF078Vld", "","C58","T062",""},;
			            	{"","TAF079Vld", "","C3Q","T001AK",""},;
			            	{"","TAF081Vld", "","C5F","T065",""},;
			            	{"","TAF082Vld", "","C4F","T066",""},;
			            	{"","TAF085Vld", "","C4N","T069",""},;
			            	{"","TAF087Vld", "","C5Z","T071",""},;
			            	{"","TAF088Vld", "","C4X","T072",""},;
			            	{"","TAF091Vld", "","C53","T075",""},;
			            	{"","TAF096Vld", "","C6N","T081",""},;
			            	{"","TAF097Vld", "","C5M","T082",""},;
			            	{"","TAF098Vld", "","C81","T083",""},;
			            	{"","TAF180Vld", "","C3R","T001AL",""},;
			            	{"","TAF187Vld", "","C6D","T001AJ",""},;
			            	{"","TAF063Vld", "","C2S","T020",""},;
			            	{"","TAF065Vld", "","C49","T023",""},;
			            	{"","TAF066Vld", "","C46","T024",""},;
			            	{"","TAF083Vld", "","C50","T067",""},;
			            	{"","TAF084Vld", "","C5J","T068",""},;
			            	{"","TAF092Vld", "","C5H","T076",""},;
			            	{"","TAF109Vld", "","C6Y","T001AG",""},;
			            	{"","TAF188Vld", "","C3J","T021",""},;
			            	{"","TAF200Vld", "","C7H","T900",""},;
			            	{"","TAF201Vld", "","C7I","T901",""},;
			            	{"","TAF202Vld", "","C7M","T902",""},;
			            	{"","TAF203Vld", "","C7P","T903",""},;
			            	{"","TAF204Vld", "","C7U","T904",""},;
			            	{"","TAF205Vld", "","C7Z","T905",""},;
			            	{"","TAF206Vld", "","C71","T906",""},;
			            	{"","TAF207Vld", "","C73","T907",""},;
			            	{"","TAF208Vld", "","C77","T908",""},;
			            	{"","TAF093Vld", "","C6F","T078",""},;
			            	{"","		  ", "","C20","T013",""},;
							{"","TAF397Vld", "","T18","T045",""},;
							{"","TAF398Vld", "","T30","T151",""},;
							{"","TAF399Vld", "","T32","T150",""},;
			            	{"","TAF400Vld", "","T39","T152",""},;
							{"","TAF456Vld", "","T56","T131",""},;
							{"","TAF450Vld", "","CWY","T052",""},;
							{"","TAF472Vld", "","T6L","T133",""},;
			            	{"","TAF446Vld", "","LEF","T051",""},;
			            	{"","TAF448Vld", "","LEM","T154",""},;
			            	{"","TAF452Vld", "","LEZ","T046",""},;
							{"",         "", "","T93","T200",""},;
							{"",         "", "","V3U","T158",""},;
							{"",         "", "","T9C","T157",""},;
							{"",         "", "","T9F","T156",""},;
							{"",         "", "","V3X","T159",""},;
							{"",         "", "","V4F","T160",""},;
							{"",         "", "","V3Z","T161",""},; 
							{"",         "", "","V4K","T162",""},;
							{"",         "", "","V4A","T163",""},; 
							{"",         "", "","V4B","T164",""}} 

#DEFINE	 aTafECF 	{ 	{"","TAF052Vld", "","C2J","T002",""},;
							{"","TAF060Vld", "","C1O","T010",""},;
							{"","TAF307Vld", "","CA2","T086",""},;
							{"","TAF311Vld", "","CAC","T087",""},;
			  				{"","TAF319Vld", "","CEA","T091",""},;
			  				{"","TAF321Vld", "","CEG","T092",""},;
			  				{"","TAF322Vld", "","CEN","T090",""},;
			  				{"","TAF323Vld", "","CEJ","T093",""},;
			  				{"","TAF324Vld", "","CEY","T094",""},;
			  				{"","TAF325Vld", "","CFK","T095",""},;
		          			{"","TAF329Vld", "","CFQ","T104",""},;
		          			{"","TAF330Vld", "","CFR","T089",""},;
		          			{"","TAF331Vld", "","CFS","T124",""},;
		          			{"","TAF332Vld", "","CFT","T096",""},;
		          			{"","TAF334Vld", "","CAY","T097",""},;
		   	       			{"","TAF335Vld", "","CFV","T098",""},;
		    	      		{"","TAF336Vld", "","CFY","T099",""},;
		       	   			{"","TAF337Vld", "","CG0","T100",""},;
		          			{"","TAF338Vld", "","CG2","T101",""},;
			          		{"","TAF339Vld", "","CG3","T102",""},;
			          		{"","TAF340Vld", "","CG5","T103",""},;
			          		{"","TAF341Vld", "","CGH","T105",""},;
				  			{"","TAF342Vld", "","CGI","T106",""},;
		       	   			{"","TAF343Vld", "","CGJ","T107",""},;
		          			{"","TAF344Vld", "","CGK","T109",""},;
		          			{"","TAF345Vld", "","CGL","T110",""},;
			          		{"","TAF346Vld", "","CGM","T111",""},;
				  			{"","TAF349Vld", "","CEM","T112",""},;
				  			{"","TAF350Vld", "","CEX","T108",""},;
		  		  			{"","TAF351Vld", "","CGO","T113",""},;
			  				{"","TAF352Vld", "","CGP","T114",""},;
		          			{"","TAF353Vld", "","CGQ","T115",""},;
			          		{"","TAF354Vld", "","CGR","T116",""},;
			          		{"","TAF355Vld", "","CGT","T117",""},;
			          		{"","TAF356Vld", "","CGU","T118",""},;
				  			{"","TAF357Vld", "","CGV","T119",""},;
		       	   			{"","TAF358Vld", "","CGW","T120",""},;
		          			{"","TAF359Vld", "","CGY","T121",""},;
		          			{"","TAF360Vld", "","CGZ","T122",""},;
			          		{"","TAF361Vld", "","CAP","T088",""},;
			          		{"","TAF367Vld", "","CH9","T123",""},;
			          		{"","TAF371Vld", "","CHC","T125",""},;
			          		{"","TAF372Vld", "","CHD","T127",""},;
				          	{"","TAF373Vld", "","CHF","T126",""},;
							{"","TAF394Vld", "","T29","T129",""},;
			          		{"","TAF429Vld", "","T0M","T130",""},;
			          		{"","TAF471Vld", "","T67","T132",""},;
							{"","TAF505Vld", "","V1Q","T134",""},;
							{"","TAF506Vld", "","V1R","T135",""},;
							{"","TAF507Vld", "","V1S","T136",""},;
							{"","TAF622Vld", "","V15","T137",""},;							
							{"","TAF623Vld", "","V17","T138",""},;							
							{"","TAF624Vld", "","V55","T139",""}}

STATIC __aTafSocial := Nil
STATIC aLayOut    	:= Nil
STATIC aLayDel    	:= Nil
STATIC lLoadCache 	:= .F.
STATIC cCmpSeqC2T 	:= ""
STATIC cCmpSeqC3K 	:= ""
STATIC cUIdST2	  	:= 'UIdST2'
STATIC nTopSlct	  	:= 9999999
STATIC lTafLock   	:= Findfunction( 'TafLock' )
STATIC lTafILck   	:= FindFunction( 'TafLockInteg' )
STATIC lTafPrtD   	:= FindFunction( 'ProtData' )
STATIC lTafMInc   	:= FindFunction( 'TAFMsgIncons' )
STATIC lTafX3	  	:= FindFunction( 'TafTmSx3' )
STATIC cXFilC1E   	:= Nil

//Tabelas filhas da C20 que possuem filial + chvnf em seus indices
//OBs.: Se forem incluidas novas tabelas nessa variavel, incluir também no fonte TafUpdLote.prw na variavel de mesmo nome.
STATIC cC20Child  	:= "C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3A|C3F|C3G|C3H|C3I|C6W|C9H|CW7|T9L|T9M|T9Q"

// Objeto PreparedStatemente da query de notas canceladas na C20
STATIC __oQryC20 	:= Nil
STATIC __aIndC20 	:= {"C20_FILIAL", "C20_CODMOD","C20_INDOPE","C20_TPDOC","C20_INDEMI","C20_CODPAR","C20_SERIE","C20_SUBSER","C20_NUMDOC","C20_DTDOC","C20_DTES"}
STATIC aCposR1000	:= Nil

Static cDirFiles	:= ""
Static nFilFiles	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAInteg

Rotina principal de integracoes do produto TAF. A partir dela sao envocadas as funcoes de integracao
banco a banco, validacao, integracao com TSS e etc.

Em sua estrutura principal compreende:

	TAFPROC0 (TAFPROC Zero)
	Busca as informações na ST1 no ERP e integra para a ST2 (TAF). Alterando o flag desses registros na ST1 (STATUS=2 - Integrados)

	TAFPROC1 (TAFPROC Um)
	Verifica os registros na  TAFST1 (STATUS=2) - Integrados para limpa-los (tornando ST1 volátil).

	TAFPROC2 (TAFPROC Dois)
	Realiza a integração da TAFST2 para as tabelas internas do TAF. Integra as informações mesmo com inconsistências alimentando o flag nas tabelas de registros.

	TAFPROC3 (TAFPROC Tres)
	Rotina que varre a base de dados procurando as inconsistências para apresenta-las no monitor de integrações

	TAFPROC6 (TAFPROC Seis)
	Processo responsavel por integrar os arquivos xml da pasta indicada para a tabela ST2.

	TAFPROC7 (TAFPROC Sete)
	Verifica o Status das Notas Fiscais Eletrônicas transmitidas para o SEFAZ

	TAFPROC8 (TAFPROC Oito)
	Processo responsavel ler os XMLs de notas fiscais autorizadas pelo Sefaz no TSS e gravar o registros na tabela ST2.

Como fonte apendice deve sempre acompanhar o fonte TAFXINTEG.PRW onde contem funcoes genericas por ela utilizada.

@param 	aPar - Parametros de Integracao onde:
		aPar[1] - Indicador do Job que sera realizado
		aPar[2] - Indica o TOP ALIAS
		aPar[3] - Indica o Database
		aPar[4] - Empresa
		aPar[5] - Filial
		aPar[6] - Indica a porta do TopConnect
		aPar[7]	- Escopo de processamento: 1-Fiscal, 2-ECF, 3-eSocial e 9-Todos

		nProcEsp	- Número da Integração
		cDirPEsp	- Diretório para Integração ( Job 6 via TAFA500 )
		lOk			- Verifica se não houve erros no Processo
		lERP		- Indica processamento por chamada externa ao TAF
		oProcess	- Objeto de régua de processamento
		c2Escopo	- Escopo de processamento da integração
		lMThr       - Tratamento para quando houver necessidade de forcar single thread para o processamento de poucos registros - utilizado na integração com SIGAFIS
		cTicketXML  - Ticket gerado para o XML que está sendo importado
		aFilArq		- Filiais enviadas no formato 2 .txt atraves do tafa500 que serao validadas no Proc3
		lProcInExec - Indica que o processo está em execução em outra thread.

@return NIL

@author Demetrio Fontes De Los Rios (Dema)
@since 30/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFAInteg( aPar, nProcEsp, cDirPEsp, lOk, lERP, oProcess, c2Escopo, lMThr, cOwner, cFilTran, cTicketXML, aFilArq, lProcInExec, lDelChild, lJob )

	Local aTabConf 		:= {} 					// Chama funcao de retorno da estrutura das tabelas compartilhadas
	Local cST1Alias		:= ""   				// Alias para tabela TAFST1
	Local cST2Alias		:= "" 					// Alias para tabela TAFST2
	Local cXERPAlias	:= "" 					// Alias para tabela TAFXERP
	Local aTABDados		:= {}  				// Array que contera estrutura das tabelas
	Local cSemaphore	:= ""
	Local cFunction		:= "TAFProc0"  		// Funcao a ser executada pela thread - Default=TAFPRoc0
	Local cIDThread		:= ""       			// Identificacao de Thread
	Local lTAFConn		:= .F.        		// Variavel de controle
	Local aErros		:= {}					// Variavel de controle
	Local nInteg		:= 0					// Tipo de Integracao
	Local cTCBuild		:= "TCGetBuild" 		// Nome da funcao para verificao da Build
	Local cTopBuild		:= ""					// Variavel com Versao do TopBuild
	Local cBancoDB		:= ""					// Identifica banco DB
	Local cMV_DIMPTAF	:= ""
	Local cDirXml		:= ""
	Local lVerEstruct	:= .T.
	Local nHdlTaf		:= 0
	Local nHandleST1	:= 0
	Local lProcEsp		:= .F.
	Local lExecJob6		:= .F.
	Local aCodFil		:= {}
	Local nCntFil		:= 0
	Local cMvTAFTDB		:= ""
	Local cMvTAFTALI	:= ""
	Local nMvTAFPort	:= 0
	Local lMultThread	:= .F.
	local lErrorThrd	:= .F.
	local oProcessMT	:= nil
	local nQtdThread	:= 0
	Local cEscopo		:= ''
	Local cMsgErro		:= ''
	Local cUserLock		:= ''
	Local cCodFils		:= ''
	Local nX			:= 0
	Local cUUID			:= ''
	Local cCodMtFil		:= ''
	Local aTopInfo		:= FWGetTopInfo()
	Local aTabInd       := {}
	Local aC20Child	 	:= StrTokArr( cC20Child , '|' )
	Local lIntGia	 	:= FwisInCallStack('TAFXGSP')
	Local aCpoObrig		:= {}
	Local nFiles		:= 0

	Default lOk			:= .T.
	Default aPar		:= {}
	Default aFilArq		:= {}
	Default nProcEsp	:= -1
	Default cDirPEsp	:= ""
	Default lERP		:= .F.
	Default oProcess	:= .F.
	Default c2Escopo	:= ''
	Default lMThr		:= .T.
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cTicketXML	:= ""
	Default lProcInExec := .F.
	Default lDelChild   := .T.
	Default lJob		:= ( Len( aPar ) > 0 ) .and. !lERP	//Quando a chamada for pelo lERP, indica que o processamento

	Private lEnd 		:= .F.      	// Variavel de controle
	Private cTAFST2     := ""

	aAdd(aTabInd,{"ALIAS", 01}) //Utilizado p/ Controle do Campo "_UNQINT" (integrações do Reinf)
	
	cEscopo	:=	c2Escopo
	If Empty( cEscopo )
		cEscopo	:=	Iif( Len( aPar ) >= 7 .And. aPar[7]<>Nil .And. !Empty( aPar[7] ), AllTrim(aPar[7]) , '9' )	//1-Fiscal, 2-ECF, 3-eSocial e 9-Todos
	EndIf
	TAFConout( 'TAFAInteg (ID: ' + AllTrim( Str( ThreadID() ) ) + ') -> Escopo [' + cEscopo + '] de processamento.',2,.F.,"INTEG")

	If lJob
		//Incluida condição, pois o schedule do TAFA500 é padrão, abre e fecha ambiente automaticamente.
		If !IsInCallStack("TAFA500")
			//Seta Empresa/Filial para não consumir servidor de licenças nos Jobs
			RPCSetType( 3 )
			RPCSetEnv( aPar[4], aPar[5],,,"TAF","TAFAINTEG" )
		EndIf
	Else
		//Quando a chamada é realizada pelo menu, é direcionado para a tela de integração, e a TAFAINTEG é chamada de lá para o processamento
		If AllTrim( FunName() ) == "TAFAINTEG" .and. !lERP
			TAFA428()
			Return()
		EndIf
	EndIf

	aCodFil		:=	TAFCodFilErp()
	// Tratamanto para passar as filiais para a função ForceMThread()
	For nX := 1 To Len(aCodFil)
		cCodMtFil	+=	"'" + AllTrim( aCodFil[nX] ) + "', "
	Next nX
	//retiro os dois ultimos caracteres ", "
	cCodMtFil	:=	SubStr( cCodMtFil , 1 , Len( cCodMtFil ) - 2 )

	cMvTAFTDB	:=	GetNewPar( "MV_TAFTDB", "" ) //Parâmetro MV_TAFTDB - TAF TOP DATABASE DO ERP
	cMvTAFTALI	:=	GetMV( "MV_TAFTALI" ) //Parâmetro MV_TAFTALI - TAF TOP ALIAS DO ERP
	nMvTAFPort	:=	GetNewPar( "MV_TAFPORT", 7890 ) //Parâmetro MV_TAFPORT - PORTA DO DBACCESS - DEFAULT PORTA CORRENTE
	cBancoDB 	:= Upper(AllTrim(TcGetDB())) //Banco de dados TAF

	//-------------------------------------------------------------------------
	// Tratamento para obter a porta, devido ambiente com DBAccess distribuido
	//-------------------------------------------------------------------------
	If nMvTAFPort == 0
		nMvTAFPort := aTopInfo[03]
	EndIf

	// --------------------------------------------
	// Pergunte do Processamento

	//Chamada pelo menu ou pela rotina de integração automática do SIGAFIS/SIGACTB com o TAF
	If lERP

		//Chamada pela rotina de integração automática do SIGAFIS ou SIGACTB
		If Len( aPar ) == 0
			nInteg := nProcEsp

		//Chamada manual pelo menu
		Else
			nInteg		:= aPar[1]
			cMvTAFTALI	:= aPar[2]
			cMvTAFTDB	:= aPar[3]
			nMvTAFPort	:= aPar[6]
		EndIf

	Else

		If nProcEsp > 0
			nInteg		:= nProcEsp
			lProcEsp	:= .T.
		Else
			nInteg := Iif( aPar[1] == 1, 0, aPar[1] )
		EndIf
	EndIf

	//Se a integração foi chamada na geração da GIA-SP, cria um cache de campos obrigatórios.
	if lIntGia; aCpoObrig := CposObrig(aClone(aC20Child)); endif

	cMV_DIMPTAF 	:= GetMv("MV_DIMPTAF",,"\xml\")
	aTabConf 		:= xTAFGetStru(cST2TAB) 	// Chama funcao de retorno da estrutura das tabelas compartilhadas
	lVerEstruct 	:= GetNewPar("MV_TAFESTR",.T.)
	If nInteg == 2

		//--------------------------------------------------------------------------------------------------
		//Quando o processamento for em MT todo o controle de carga do layout e processamento é realizado na
		//TAFPROCMT
		//--------------------------------------------------------------------------------------------------

		//----------------------------------------------------
		//Numero de Thread a serem utilizadas no processamento
		//----------------------------------------------------
		nQtdThread := GetNewPar( "MV_TAFQTTH", 0 )

		If nQtdThread <= 0
			lMultThread := .F.
		Else
			If lJob
				nQtdThread := ForceMThread( nQtdThread,cTicketXML,cCodMtFil)
			Else
				FWMsgRun( ,{ || nQtdThread := ForceMThread( nQtdThread,cTicketXML,cCodMtFil ) } , "Aguarde", "Verificando registros...") 
			EndIf

			// --> Validação para verificar se possui registros do e-Social.
			// --> Caso exista, então não habilita o processo de multi-thread, pois ainda não foi liberado para o e-Social.
			lMultThread := ( nQtdThread > 0 ) .And. !( FMultThrd(cBancoDB, aCodFil) )
			If lMultThread .And. !lMThr	//Tratamento para quando houver necessidade de forcar single thread para o processamento de poucos registros - utilizado na integração com SIGAFIS
				lMultThread	:=	.F.
			EndIf
		EndIf

		//Felipe C. Seolin
		//Adicionado verificação para o tamanho do array igual a 1, encontrado em casos onde é
		//necessário carregar apenas um layout específico. Nestas ocorrências, a função TAFLoadLay
		//é executada, zerando as variáveis estáticas do TAFAINTEG, aLayOut e aLayDel
		lLoadCache := Iif( ( ( aLayOut == Nil ) .and. ( aLayDel == Nil ) ) .or. Len( aLayOut ) == 1, .T., .F. )

		If  cEscopo <> '3'
			If lLoadCache
				If lJob
					xTAFMsgJob( "Carregando Layout TOTVS..." )
					TAFLoadLay()
				Else
					If lERP
						oProcess:Inc2Progress( "Carregando Layout TOTVS..." )
	                    oProcess:Inc1Progress()
						TAFLoadLay()
					Else
						MsgRun( "Carregando Layout TOTVS...", "Aguarde...", { || TAFLoadLay() } )
					EndIf
				EndIf
			Else
				If lERP .And. !lJob
					oProcess:Inc2Progress( "Layout TOTVS já carregado em memória..." )
	                oProcess:Inc1Progress()
				EndIf
			EndIf
		EndIf
		//---------------------------------------------------------------------------------------
		//Inicio o processamento em MultThread subindo as thread e carregando o layout TAF em
		//todas as threads abertas
		//---------------------------------------------------------------------------------------
		if lMultThread

			if !lJob
				MsgRun( "Preparando os ambientes para processamento MT...", "Aguarde...", { || lErrorThrd := TafStartMT( @cSemaphore, nInteg, lJob, aPar, cMvTAFTALI, cBancoDB, nMvTAFPort, nQtdThread ) } )
			else
				TAFConout( "Preparando os ambientes para processamento MT...",2,.F.,"INTEG" )
				lErrorThrd := TafStartMT( @cSemaphore, nInteg, lJob, aPar, cMvTAFTALI, cBancoDB, nMvTAFPort, nQtdThread )
			endif

			//-------------------------------------------------------------------------------
			//Caso ocorra algum erro na abertura das Threads não prossigo com o processamento
			//-------------------------------------------------------------------------------
			if lErrorThrd

				if lJob
					TAFConout( 'MT - Ocorreu um erro na abertura das threads, reinicie o processo...',3,.T.,"INTEG" )

				else
					msgalert( 'MT - Ocorreu um erro na abertura das threads, reinicie o processo...' )

				endif
			endif
		endif

	EndIf

	//----------------------------------------------------------------------------------------------
	//Caso o processamento seja em multi-Thread verifico se não ocorreu erro na abertura das threads
	//----------------------------------------------------------------------------------------------
	if !lMultThread .or. ( lMultThread .and. !lErrorThrd )

		// --------------------------------------------
		// Parametrizado quantidade de registros
		nTopSlct := GetNewPar("MV_TAFQPRC", 0 )

		//Chama funcao de retorno da estrutura das tabelas compartilhadas
		aTabConf 		:= xTAFGetStru(cST2TAB)

		// -----------------------------------------------------
		// Verificação da Build  para tratamento de campo CLOB
		If FindFunction(cTCBuild)
			cTopBuild := &cTCBuild.()
		EndIf

		xTAFMsgJob(Replicate("*",30))
		xTAFMsgJob("INICIANDO TAFAINTEG TAF X ESOCIAL")
		xTAFMsgJob(Replicate("*",30))
		cIdThread := StrZero( ThreadID(), 10 )

		Do Case

			// No caso das integracoes 0, 1, 2, 6 ou 8. Preciso realizar a conexao nas 2 pontas com TAFCONN()
			Case nInteg == 0 .Or. nInteg == 1 .Or. nInteg == 2 .Or. nInteg == 6 .Or. nInteg == 8

				//-------------------------------------------------
				//Caso não seja MT não preciso realizar as conexões
				//-------------------------------------------------
				if !lMultThread

					//-----------------------------------------------------------------------
					// Prepara informacoes das tabelas compartilhadas
					cST1Alias	:= GetNextAlias()
					cST2Alias	:= GetNextAlias()
					cXERPAlias	:= GetNextAlias()
					aTABDados	:= { { cST1TAB, cST1Alias }, { cST2TAB, cST2Alias }, { cTAFXERP, cXERPAlias } }

					cTAFST2  := cST2Alias

					//-----------------------------------------------------------------------
					// Verifica Conexoes/Tabela atraves da funcao TAFCONN()
					If lJob
						xTAFMsgJob( "Conectando as bases de dados..." )
						lTAFConn := TAFConn( 1, nInteg, aTABDados, aTabConf, @aErros, aPar, cTopBuild, cBancoDB, lJob, @nHdlTaf,  cMvTAFTALI, cMvTAFTDB, nMvTAFPort )
					Else
						If lERP
							If nInteg == 0
								oProcess:Inc1Progress( "Conectando as bases de dados..." )
	                            oProcess:Inc2Progress()
							ElseIf nInteg == 2
								oProcess:Inc2Progress( "Conectando as bases de dados..." )
	                            oProcess:Inc1Progress()
							EndIf
							lTAFConn := TAFConn( 1, nInteg, aTABDados, aTabConf, @aErros, aPar, cTopBuild, cBancoDB, lJob, @nHdlTaf,  cMvTAFTALI, cMvTAFTDB, nMvTAFPort )
						Else
							MsgRun( "Conectando as bases de dados...", "Aguarde...", { || lTAFConn := TAFConn( 1, nInteg, aTABDados, aTabConf, @aErros, aPar, cTopBuild, cBancoDB, lJob, @nHdlTaf,  cMvTAFTALI, cMvTAFTDB, nMvTAFPort ) } )
						EndIf
					EndIf

				endif

				//-----------------------------------------------------------
				//Caso tenha realizado a conexão ou seja processamento em MT
				//-----------------------------------------------------------
				If lTAFConn .or. lMultThread

					Do Case

						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// T A F I N T E G   0   -   Z E R O
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// Esta rotina tem como objtivo buscar as informações na ST1 no ERP e integrar para a ST2 (TAF).
						// Alterando o flag desses registros na ST1 (STATUS=3 - Integrados)
						// -----------------------------------------------------------------------
						Case nInteg == 0

							cSemaphore := AllTrim( Str( ThreadID() ) )

							if len( aCodFil ) > 0

								if !lJob .and. !lERP
									Aviso( "Complemento de Empresa" , TAFAlertJob( "JOB0_CODFIL" , { aCodFil } ) , { "Continuar" } , 3 )
								endif

								//---------------------------------------------------------------------
								//Fatio os registros que serao processados
								If lJob
									xTafSlice( cST1TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,, .T., nHandleST1, aCodFil )
								Else
									If lERP
										oProcess:Inc1Progress( "Selecionando registros para transferência..." )
	                                    oProcess:Inc2Progress()
	                                    ProcessMessages()
	                                    Sleep(300)
										xTafSlice( cST1TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,, .T.,, aCodFil )
									Else
										MsgRun( "Aguarde...", "Selecionando registros para transferência...", { || xTafSlice( cST1TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,, .T.,, aCodFil ) } )
									EndIf
								EndIf

								//---------------------------------------------------------------------
								//Processo integração
								If lJob
									TAFProc0( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, lERP )
								Else
									If lERP
										oProcess:Inc1Progress( "Transferindo dados ao TAF..." )
	                                    oProcess:Inc2Progress()
	                                    ProcessMessages()
	                                    Sleep(300)
										Processa( { |lEnd| TAFProc0( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, lERP ) }, "Processando...", "Transferindo dados ao TAF...", .F. )
									Else
										Processa( { |lEnd| TAFProc0( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, lERP ) }, "Processando...", "Transferindo dados ao TAF...", .F. )
									EndIf
								EndIf

							else

								if !lJob
									Aviso( "Complemento de Empresa" , TAFAlertJob( "JOB0_TAFA050" ) , { "Fechar" } , 3 )
								endif

							endif

							If nHandleST1 > 0
								If Select("C1E")
									C1E->(dbCloseArea())
								EndIf
								TcUnlink(nHandleST1)
							EndIf

						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// T A F I N T E G   1   -   U M
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// Esta rotina tem como objetivo apagar todos os registros já integrados no TAF
						// zzzzxczxcsadf3rfsdf32s  er32in nniwino32io34in 4in 4ni43in5noiwnit n
						// -----------------------------------------------------------------------
						Case nInteg == 1

							//Rotina de Limpeza = TAFST1
							//---------------------------------------------------------------------
							If !lJob
								MsgRun( "Excluindo registros integrados da tabela TAFST1...", "Aguarde...", { || TAFProc1( lJob ) } )
							Else
								TAFProc1( lJob )
							EndIf

						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// T A F I N T E G   2   -   D O I S
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// Esta rotina tem como objetivo
						// Para registros do escopo Layout TOTVS - TXT ( TAFTPREG = 1 ) Verifica-se a estrutura atraves da funcao TAFVerEstru()
						// -----------------------------------------------------------------------
						Case nInteg == 2

							//--------------------------------------------------------------------------
							//Para o processamento em MultiThread é obrigatória a validação de estrutura
							//--------------------------------------------------------------------------
							lVerEstruct 	:= GetNewPar("MV_TAFESTR",.T.)

							//-------------------------------
							//Processamento em Multithread
							//-------------------------------
							if lMultThread

								////---------------------------------------------------------------------------
								//Chama a função que realiza a validação de estrutura dos reistros em MT
								//-----------------------------------------------------------------------------
								If !lJob
									oProcessMT := TAFProgress():New( { |lEnd| TafProc2Mt( @oProcessMT, aCodFil, cSemaphore, nQtdThread, lJob, aLayout, aLaydel, lDelChild, aCpoObrig, cTicketXML ) }, 'Integração - MT' ,.F.,.F.)
									oProcessMT:Activate()
								else
									TafProc2Mt( @oProcessMT, aCodFil, cSemaphore, nQtdThread, lJob, aLayout, aLaydel, lDelChild, aCpoObrig, cTicketXML )
								endif
								Return

							//-----------------------------------------------------------------------
							//Processamento em MonoThread
							else

								cSemaphore := AllTrim( Str( ThreadID() ) )
								DBSelectArea( cST2Alias )

								//--------------------------------------------------------------------------------------------
								//Verifica Estrutura dos registros apenas se houver registros Layout TAF  a ser processado.
								//--------------------------------------------------------------------------------------------										//
								If lVerEstruct

									( cST2Alias )->( DBSetOrder( 6 ) )
									( cST2Alias )->( DBGoTop() )

									C1E->( DBSetOrder( 7 ) )

									For nCntFil := 1 to Len( aCodFil )
										If ( cST2Alias )->( MsSeek( aCodFil[nCntFil] + cStsReady + cTAFCodTxt ) ) .or. ( cST2Alias )->( MsSeek( aCodFil[nCntFil] + cStsProc + cTAFCodTxt ) ) .Or. ( cST2Alias )->( MsSeek( Padr( aCodFil[nCntFil] , Len(( cST2Alias )->TAFFIL))+ cStsReady + cTAFCodTxt ) )
											If lJob
												TAFVerEstru( @lEnd, cST2Alias, aLayout, lJob, cXERPAlias )
											Else
												If lERP
													oProcess:Inc2Progress( "Verificando estrutura dos registros..." )
	                                                oProcess:Inc1Progress()
													Processa( { |lEnd| TAFVerEstru( @lEnd, cST2Alias, aLayout, lJob, cXERPAlias, , , , , cEscopo ) }, "Processando...", "Verificando estrutura dos registros...", .F. )
												Else
													Processa( { |lEnd| TAFVerEstru( @lEnd, cST2Alias, aLayout, lJob, cXERPAlias, , , , , cEscopo ) }, "Processando...", "Verificando estrutura dos registros...", .F. )
												EndIf
											EndIf
										Else
											If lERP
												oProcess:Inc2Progress( "Não há registros para verificação de estrutura..." )
	                                            oProcess:Inc1Progress()
											EndIf
										EndIf
									Next nCntFil

									//Volta posicionamento Tabela
									( cST2Alias )->( DBSetOrder( 1 ) )
									( cST2Alias )->( DBGoTop() )
								EndIf

								cUUID := cUIdST2

								//Cria Identificador de sessão para variavel de controle da TAFST2.
								//If !VarIsUID(cUUID)
									//recuperaST2(cIdThread)
									If !VarSetUID(cUIdST2,.T.)
										cMsgErro := "Erro ao tentar criar o semaforo para integração. Reinicie o serviço do TAF, se o erro persistir entre em contato com o suporte Totvs."
										If lJob
											TafConOut(cMsgErro)
										Else
											Aviso("Integração TAFST2 x TAF",cMsgErro,{"OK"},1)
										EndIf

										lProcInExec := .T.
										Return Nil
									EndIF
								//EndIf

								If lTafILck

									For nX := 1 to Len(aCodFil)
										If nX > 1
											cCodFils +=	","
										EndIf
										cCodFils +=	"'" + AllTrim(aCodFil[nX]) + "'"
									Next nX

									If !TafLockInteg(cUUID,.T.,@cUserLock,cCodFils,,@cMsgErro)

										If lJob
											TafConOut(cMsgErro)
										Else
											Aviso("Integração TAFST2 x TAF",cMsgErro,{"OK"},3)
										EndIf

										lProcInExec := .T.
									EndIf


									If !lProcInExec

										//---------------------------------------------------------------------
										//Fatio os registros que serão processados
										If lJob
											xTafSlice( cST2TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,,,, aCodFil, cTicketXML, cEscopo )
										Else
											If lERP
												oProcess:Inc2Progress( "Selecionando registros para integração..." )
	                                            oProcess:Inc1Progress()
	                                            ProcessMessages()
	                                            Sleep(300)
												xTafSlice( cST2TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,,,, aCodFil, cTicketXML, cEscopo )
											Else
												MsgRun( "Selecionando registros para integração...", "Aguarde...", { || xTafSlice( cST2TAB, AllTrim( StrZero( nTopSlct, 10 ) ), cIDThread, cBancoDB,,,,, aCodFil, cTicketXML ) } )
											EndIf
										EndIf

										//---------------------------------------------------------------------
										//Processo integração
										If lJob
											TAFProc2( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, @aErros, cXERPAlias, @lOk, cTicketXML, @aTabInd, , , , cEscopo )
										Else
											If lERP
												oProcess:Inc2Progress( "Integrando registros aos cadastros do TAF..." )
	                                            oProcess:Inc1Progress()
	                                            ProcessMessages()
	                                            Sleep(300)
												Processa( { |lEnd| TAFProc2( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, @aErros, cXERPAlias, @lOk, cTicketXML, @aTabInd,/*13*/,lDelChild, aCpoObrig,cEscopo ) }, "Processando...", "Integrando registros aos cadastros do TAF...", .F.)
											Else
												Processa( { |lEnd| TAFProc2( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, @aErros, cXERPAlias, @lOk, cTicketXML, @aTabInd,/*13*/,lDelChild, aCpoObrig,cEscopo ) }, "Processando...", "Integrando registros aos cadastros do TAF...", .F.)
											EndIf
										EndIf

										//Chamada do monitor de integracao exibindo quais foram as inconsistencias encontradas
										If !lJob .and. !lProcEsp .and. !lERP
											If lTafPrtD
												If ProtData()
													If Aviso( "Monitor de Integração", "Integração finalizada, deseja visualizar o monitor de integração?", { "Sim", "Não" }, 2 ) == 1
														TAFTicket( .T. )
													EndIf
												EndIf
											Else
												If Aviso( "Monitor de Integração", "Integração finalizada, deseja visualizar o monitor de integração?", { "Sim", "Não" }, 2 ) == 1
													TAFTicket( .T. )
												EndIf
											EndIf
										EndIf

										If lTafILck
											TafLockInteg(cUUID,.F.)
										EndIf

									Endif

								Else

									cMsgErro := "Rotina TAFXINTEG.PRW desatualizada. Atualize seu ambiente para a execução desta rotina."

									If lJob
										TafConOut(cMsgErro)
									Else
										Aviso("Integração TAFST2 x TAF",cMsgErro,{"OK"},3)
									EndIf
								EndIf
							EndIf
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// T A F I N T E G   6   -   S E I S
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// Esta rotina tem como objetivo importar Arquivos XML de eSocial Atraves de um diretório (folder)
						// -----------------------------------------------------------------------
						Case nInteg == 6

							cMV_DIMPTAF  := GetMv("MV_DIMPTAF",,"\xml\")
							cFunction := "TafProc6"
							cMsg := xTAFMsgJob("["+cFunction+"][Inicio do Processamento ST]")

							If !lJob
								// Verifica se o usuário selecionou o diretório dos XML
								If lProcEsp
									cDirXML := cDirPEsp
									lExecJob6 := .T.
								Else
									lExecJob6 := TAFSetFldr(@cDirXML)
								EndIf

								If lExecJob6
									cDirXML := IIf( Empty( cDirXML ), cMV_DIMPTAF, cDirXML )
									cDirProc := xTafSliceF(cDirXML,"xml",nTopSlct,cIDThread)

									//Executa a integracao
									//TAFProc6( lJob, cDirProc, cIDThread, nInteg, aTabConf, aPar, lMsgJob, oProcess, aTAFConn )
									TAFProc6( lJob, cDirProc, cIDThread, nInteg, aTabConf, aPar, lTAFConn, cST2Alias, @lOk, cOwner, cFilTran, @cTicketXML )

									cMsg := xTAFMsgJob("["+cFunction+"][Final do Processamento ST]")
								Else
									Aviso("INTEGRAÇÃO","Processamento cancelado pelo usuário",{"OK"},1)
								EndIf
							Else

								cDirXML := IIf(Empty(cDirXML), cMV_DIMPTAF, cDirXML)
								
								If nFilFiles == 0

									cDirFiles	:= xTafSliceF(cDirXML, "xml", nTopSlct, cIDThread, @nFiles)
									nFilFiles	:= nFiles

								EndIf
								
								//Executa a integracao
								TAFProc6(lJob, cDirFiles, cIDThread, nInteg, aTabConf, aPar, lTAFConn, cST2Alias, @lOk, cOwner, cFilTran, @cTicketXML)

								cMsg := xTAFMsgJob("["+cFunction+"][Final do Processamento ST]")

							EndIf

						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// T A F I N T E G   8   -   O I T O
						// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
						// Esta rotina tem como objetivo
						// zzzzxczxcsadf3rfsdf32s  er32in nniwino32io34in 4in 4ni43in5noiwnit n
						// -----------------------------------------------------------------------
						Case nInteg == 8

							Begin Transaction

								// ---------------------------------------------------------------------
								// Processo integração
								//If !lJob
								//	Processa( {|lEnd|  TAFProc2(@lEnd,lJob,cST2Alias,cST1Alias,nTopSlct,aTabConf[01],cIDThread,@aErros) }, "Aguarde...","Executando rotina.", .T. )
								//Else
									TAFProc8( lJob, cIDThread, nInteg, aTabConf, aPar, .F./*lMsgJob*/, /*oProcess*/, /*aTAFConn*/, lTAFConn, cST2Alias )
								//EndIf

							End Transaction

					EndCase

					// -----------------------------------------------------
					// Encerra conexao - Fecha tabelas
					TAFConn(2,nInteg,aTABDados,,@aErros,aPar,cTopBuild,cBancoDB,lJob, @nHdlTaf,  cMvTAFTALI, cMvTAFTDB, nMvTAFPort)

				Else
					//Caso não consiga a conexão e já tenha criado conexão com a TAFST1, deve encerra-lá
					If nHdlTaf > 0
						TCUnlink( nHdlTaf )
						nHdlTaf := 0
					EndIf

					lOk := .F.
				EndIf


			// VALIDACAO
			Case nInteg == 3

				If !lJob
					Processa( {|| TAFProc3(lJob,nTopSlct,cIDThread,cEscopo,cTicketXML,aFilArq) }, "Aguarde...", "Executando rotina." )
				Else
					TAFProc3(lJob,nTopSlct,cIDThread,cEscopo,cTicketXML,aFilArq)
				EndIf

				If !lJob .and. !lProcEsp .and. !lERP
					If lTafPrtD
						If ProtData()
							If Aviso( "Monitor de Validação", "Validação finalizada, deseja visualizar o monitor de validação ?", { "Sim", "Não" }, 2 ) == 1
								TAFTicket( , .T. )
							EndIf
						EndIf
					Else
						If Aviso( "Monitor de Validação", "Validação finalizada, deseja visualizar o monitor de validação ?", { "Sim", "Não" }, 2 ) == 1
							TAFTicket( , .T. )
						EndIf
					EndIf
				EndIf

			// RET NOTAS TSS
			Case nInteg==7

				// Opcao indisponivel.
				If !lJob
					Processa( {||TAFProc7(@lEnd,lJob,cIDThread)}, "Aguarde...", "Executando rotina de Consulta no SEFAZ",  )
					If !lEnd
			   	   		MsgInfo("Nao há registro(s) de Nfe(s) para consulta no Sefaz")
					EndIf
				Else
					TAFProc7(@lEnd,lJob,cIDThread)
				EndIf

		End Case
	endif

	If lJob
		//Incluida condição, pois o schedule do TAFA500 é padrão, abre e fecha ambiente automaticamente.
		If !IsInCallStack("TAFA500")
			//Conout( "TAFAINTEG - RPCCLEARENV - ISINCALLSTACK  ------------------------------------------------------------------------------------------------------------" )
			RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TAFProc1
Realiza a exclusão dos registros já integrados da tabela TAFST1
@param

@return

@author Demetrio Fontes De Los Rios
@since 04/11/2013
@version 1.0
*/
//--------------------------------------------------------------------
Function TAFProc1( lJob )

Local cQryExec 	:= ""
Local lOk			:= .F.

cQryExec := " "
cQryExec += " DELETE FROM TAFST1"
cQryExec += " WHERE TAFSTATUS = '" + cStsFinal + "' "
lOk := TcSQLExec( cQryExec ) >= 0

If lOk
	TcSQLExec( 'COMMIT' )
Else
	If !lJob
		Alert(AllTrim(TCSQLError()))
	Else
		TAFConout(" *** TAFProc1  "  + TCSQLError(),2,.T.,"INTEG" )
	EndIf
Endif

Return lOk

//-------------------------------------------------------------------
/*{Protheus.doc} TAFProc3

@param lJob       - Informa se a Rotina está sendo executada via Job
@param nQtdReg    - Quantidade maxima de registros a serem executados
@param cIDThread  - Id da Thread
@param c2Escopo   - 1-Fiscal, 2-ECF, 3-eSocial e 9-Todos
@param cTicketXML - Ticket gerado para o XML que está sendo importado
@param aFlArqVd	  - Armazena as Filiais que serão validadas durante a importação (fiscal) via arquivo ".txt" com multi-filiais.

@return

@author Felipe C. Seolin
@since 04/11/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function TAFProc3(lJob,nQtdReg,cIDThread,cEscopo,cTicketXML,aFlArqVd)

Local cQuery		:= ""
Local cAliasQry		:= ""
Local cFunction		:= ""
Local cAlias		:= ""
Local nRecno		:= 0
Local nI			:= 0
Local nCount		:= 0
Local QtdRegProc	:= 0
Local nAte          := 0
Local nCont         := 0
Local aLogErro		:= {}
Local aGrava		:= {}
Local cAnd			:= ""
Local cEvento		:= ""
Local cTimeInteg	:= ""
Local cBkpFil       := ""
Local aTafSocial	:= {}

Default cTicketXML	:= ""
Default aFlArqVd    := {}

if len(aFlArqVd) > 1
	nAte := len(aFlArqVd)
	cBkpFil := cFilAnt
else
	nAte := 1
endif

for nCont := 1 to nAte

if nAte > 1
	cFilAnt := aFlArqVd[nCont]
endif

If lJob
	cTimeInteg := Time()
	TAFConout("* Verificando registros a serem validados -  TAFProc3  TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeInteg,2,.F.,"INTEG")
	TAFConout("* Escopo: " + cEscopo,2,.F.,"INTEG")
EndIf
//--------------------------
// *** e-Social - Inicio ***
//--------------------------
// Função que indica se o ambiente é válido para o eSocial 2.3
If cEscopo == "3" .Or. cEscopo == "9"

	aTafSocial := TAFRtEso()
	If TafAtualizado(.F.)
		If lJob
			xTAFMsgJob("Selecionando registros do e-Social para validação...")
		Else
			nCount := Len(aTafSocial)
			ProcRegua(nCount)
		EndIf

		cQuery := ""

		For nI := 1 to Len( aTafSocial )

			cEventoTot = SubStr(aTafSocial[nI,5],1,3)
			If cEventoTot <> "S-5"
				If !lJob
					IncProc("Selecionando registros do e-Social para validação...")
				EndIf

				cAlias    := aTafSocial[nI,4]

				If TAFAlsInDic( cAlias ) .And. TAFColumnPos( cAlias + "_STATUS" )

					cFunction := aTafSocial[nI,2]
					cEvento   := SubStr(aTafSocial[nI,5],3,4)

						If cAlias $ "C9V|C91|" .and. TAFColumnPos( cAlias + '_NOMEVE' )
							cAnd := "  AND " + cAlias + "_NOMEVE = 'S" + cEvento + "' "
					Else
						cAnd := ""
					EndIf

					If nI <> 1
						cQuery += "UNION ALL "
					EndIf
					cQuery += "SELECT '" + cAlias + "' TAFALIAS "
					cQuery += "          ," + cAlias + ".R_E_C_N_O_ REG "
					cQuery += "          ,'" + cFunction + "' VALIDA "
					cQuery += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
					cQuery += "WHERE " + cAlias + "_STATUS  = ' ' " //"_STATUS IN ('1','') "
					cQuery += "  AND " + cAlias + ".D_E_L_E_T_ = ' ' AND " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'"

					if cAlias == 'C1E'
						cQuery +=  " AND " + cAlias + "_FILTAF = '" + cFilAnt + "'"
					endif

						if TAFColumnPos( cAlias + '_EVENTO' )
							cQuery += "  AND " + cAlias + "_EVENTO <> 'E' "
						endif
						if TAFColumnPos( cAlias + '_ATIVO' )
							cQuery += "  AND " + cAlias + "_ATIVO = '1' "
						endif

						//----------------------------------------------------------------------------
						// Filtra para processar somente os dados dos XMLs que estão sendo importados
						//----------------------------------------------------------------------------
						If !Empty(cTicketXML)
							cQuery += " AND EXISTS(SELECT TAFKEY FROM TAFXERP WHERE TAFTICKET = '" + cTicketXML + "' AND  D_E_L_E_T_ = ' ' ) "
						EndIf

					cQuery += cAnd

				Endif
			EndIf

		Next nI

		cAliasQry := "JOB3"

//		cQuery := ChangeQuery(cQuery) - retirado devido erro na validação de dados por ter MUITAS SUB-SELEÇÕES
		TcQuery cQuery New Alias &cAliasQry

			COUNT to nCount
			(cAliasQry)->(DBGoTop())
			QtdRegProc += nCount

			If nCount > 0
				If lJob
					cTimeInteg := Time()
					TAFConout("* Inicio Integração TAFProc3  TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeInteg,2,.F.,"INTEG")
				EndIf
			EndIf

			If !lJob
				ProcRegua(nCount)
			EndIf

		While (cAliasQry)->(!Eof())


			cAlias		:= allTrim( ( cAliasQry )->TAFALIAS )
			nRecno		:= ( cAliasQry )->REG
			cFunction	:= ( cAliasQry )->VALIDA

			If lJob
				xTAFMsgJob( "Verificando Tabela: " + FWX2Nome( cAlias ) + " Registro: " + AllTrim(Str(nRecno)) )
			Else
				IncProc("Verificando Tabela: " + AllTrim( FWX2Nome( cAlias ) ) + " -  Registro: " + AllTrim(Str(nRecno)) )
			EndIf

			DBSelectArea(cAlias)
			( cAlias )->( DBGoTo( nRecno ) )

			//Garanto que estarei posicionado no registro que sera validado
			(cAlias)->( DbGoTo( nRecno ) )

			if !Empty(Alltrim( cFunction )) .and. findFunction( cFunction )
				aLogErro := &cFunction.(cAlias,nRecno,,.T.,,)
			endif

			(cAlias)->(DBCloseArea())

			For nI := 1 to Len(aLogErro)
				aAdd( aGrava, { aLogErro[nI,3], aLogErro[nI,4], "1", aLogErro[nI,2], xValStrEr(aLogErro[nI,2]), "", "3", aLogErro[nI,1], Iif( Len( aLogErro[nI] ) == 5, aLogErro[nI,5], "" ) } )
			Next nI

			(cAliasQry)->(DBSkip())
		EndDo

		(cAliasQry)->(DBCloseArea())
	EndIf //Finaliza condição de verificação TafAtualizado()
EndIf

//-----------------------
// *** e-Social - Fim ***
//-----------------------

//------------------------------
// *** Fiscal (EFD) - Inicio ***
//------------------------------
If cEscopo == "1" .Or. cEscopo == "9"
	If lJob
		xTAFMsgJob("Selecionando registros do Fiscal (EFD) para validação...")
	Else
		nCount := Len(aTafFiscal)
		ProcRegua(nCount)
	EndIf

	cQuery := ""

	For nI := 1 to Len( aTafFiscal )

		If !lJob
			IncProc("Selecionando registros do Fiscal (EFD) para validação...")
		EndIf

		cAlias    := aTafFiscal[nI,4]

		If TAFAlsInDic( cAlias ) .And. TAFColumnPos( cAlias + "_STATUS" )

			cFunction := aTafFiscal[nI,2]
			cEvento   := SubStr(aTafFiscal[nI,5],3,4)

			If nI <> 1
				cQuery += "UNION ALL "
			EndIf

			cQuery += "SELECT '" + cAlias + "' TAFALIAS "
			cQuery += "          ," + cAlias + ".R_E_C_N_O_ REG "
			cQuery += "          ,'" + cFunction + "' VALIDA "
			cQuery += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
				cQuery += "WHERE " + cAlias + "_STATUS  = ' ' " //"_STATUS IN ('1','') "
			cQuery += "  AND " + cAlias + ".D_E_L_E_T_ = '' AND " + cAlias + "_FILIAL = '" + xFilial()+ "'"

			if cAlias == 'C1E'
				cQuery +=  " AND " + cAlias + "_FILTAF = '" + cFilAnt + "'"
			endif

		Endif

	Next nI

	cAliasQry := "JOB3"

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry

	COUNT to nCount
	(cAliasQry)->(DBGoTop())
	QtdRegProc += nCount

	If !lJob
		ProcRegua(nCount)
	EndIf

	While (cAliasQry)->(!Eof())

		aLogErro 	:= {}
		cAlias		:= allTrim( ( cAliasQry )->TAFALIAS )
		nRecno		:= (cAliasQry)->REG
		cFunction	:= (cAliasQry)->VALIDA

		If lJob
			TAFConout( "Verificando Tabela: " + FWX2Nome( cAlias ) + " Registro: " + AllTrim(Str(nRecno)),2,.F.,"INTEG" )
		Else
			IncProc("Verificando Tabela: " + AllTrim( FWX2Nome( cAlias ) ) + " -  Registro: " + AllTrim(Str(nRecno)) )
		EndIf

		DBSelectArea(cAlias)
		( cAlias )->( DBGoTo( nRecno ) )

		//aLogErro := &cFunction.(cAlias,nRecno,,lJob)

		//Garanto que estarei posicionado no registro que sera validado
		(cAlias)->( DbGoTo( nRecno ) )
		if !Empty(Alltrim(cFunction)) .and. findFunction( cFunction )
			aLogErro := &cFunction.(cAlias,nRecno,,.T.,,cEscopo)
		endIf
		(cAlias)->(DBCloseArea())

		For nI := 1 to Len(aLogErro)
			aAdd( aGrava, { aLogErro[nI,3], aLogErro[nI,4], "1", aLogErro[nI,2], xValStrEr(aLogErro[nI,2]), "", "3", aLogErro[nI,1], Iif( Len( aLogErro[nI] ) == 5, aLogErro[nI,5], "" ) } )
		Next nI

		(cAliasQry)->(DBSkip())
	EndDo

	(cAliasQry)->(DBCloseArea())
EndIf

//---------------------------
// *** Fiscal (EFD) - Fim ***
//---------------------------

//--------------------------------
// *** Contabil (ECF) - Inicio ***
//--------------------------------
If cEscopo == "2" .Or. cEscopo == "9"
	If lJob
		xTAFMsgJob("Selecionando registros da ECF para validação...")
	Else
		nCount := Len(aTafECF)
		ProcRegua(nCount)
	EndIf

	cQuery := ""

	For nI := 1 to Len( aTafECF )

		If !lJob
			IncProc("Selecionando registros da ECF para validação...")
		EndIf

		cAlias    := aTafECF[nI,4]

		If TAFAlsInDic( cAlias ) .And. TAFColumnPos( cAlias + "_STATUS" )

			cFunction := aTafECF[nI,2]
			cEvento   := SubStr(aTafECF[nI,5],3,4)

			If nI <> 1
				cQuery += "UNION ALL "
			EndIf

			cQuery += "SELECT '" + cAlias + "' TAFALIAS "
			cQuery += "          ," + cAlias + ".R_E_C_N_O_ REG "
			cQuery += "          ,'" + cFunction + "' VALIDA "
			cQuery += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
				cQuery += "WHERE " + cAlias + "_STATUS  = ' ' " //"_STATUS IN ('1','') "
			cQuery += "  AND " + cAlias + ".D_E_L_E_T_ = '' AND " + cAlias + "_FILIAL = '" + xFilial() +"'"

		Endif

	Next nI

	cAliasQry := "JOB3"

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry

		COUNT to nCount
		(cAliasQry)->(DBGoTop())
		QtdRegProc += nCount

	If !lJob
		ProcRegua(nCount)
	EndIf

	While (cAliasQry)->(!Eof())

		cAlias		:= allTrim( ( cAliasQry )->TAFALIAS )
		nRecno		:= (cAliasQry)->REG
		cFunction	:= (cAliasQry)->VALIDA

		If lJob
			xTAFMsgJob( "Verificando Tabela: " + FWX2Nome( cAlias ) + " Registro: " + AllTrim(Str(nRecno)) )
		Else
			IncProc("Verificando Tabela: " + AllTrim( FWX2Nome( cAlias ) ) + " -  Registro: " + AllTrim(Str(nRecno)) )
		EndIf

		DBSelectArea(cAlias)
		( cAlias )->( DBGoTo( nRecno ) )

		//aLogErro := &cFunction.(cAlias,nRecno,,lJob)

		//Garanto que estarei posicionado no registro que sera validado
		(cAlias)->( DbGoTo( nRecno ) )

		aLogErro := &cFunction.(cAlias,nRecno,,.T.,,)

		(cAlias)->(DBCloseArea())

		For nI := 1 to Len(aLogErro)
			aAdd( aGrava, { aLogErro[nI,3], aLogErro[nI,4], "1", aLogErro[nI,2], xVldECFStr(aLogErro[nI,2]), "", "3", aLogErro[nI,1], Iif( Len( aLogErro[nI] ) == 5, aLogErro[nI,5], "" ) } )
		Next nI

		(cAliasQry)->(DBSkip())
	EndDo

	(cAliasQry)->(DBCloseArea())
EndIf
//-----------------------------
// *** Contabil (ECF) - Fim ***
//-----------------------------

If !Empty(aGrava)

	If lJob
		xTAFMsgJob("Gravando ocorrências de inconsistências...")
	Else
		IncProc("Gravando ocorrências de inconsistências...")
	EndIf

	Begin Transaction
		GravaCU0(1,aGrava,.T.,lJob)
	End Transaction
EndIf

aGrava := {}

next nCont

If lJob
	//xTAFMsgJob("Processo finalizado!")
	TAFConout("* Fim Integração TAFProc3 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + Time() + " - Tempo de processamento: " + ElapTime(cTimeInteg,Time())  + " - Quantidade de Registros: " + AllTrim(Str(QtdRegProc)),2,.F.,"INTEG")
Else
	IncProc("Processo finalizado!")
EndIf

//Retorna a Filial Corrente
if nAte > 1
	cFilAnt := cBkpFil
endif

aTafSocial := {}
aTafSocial := Nil 

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaCU0

Executa interface para manutenção de informações nos cadastros do TAF.

@Param		nOpc		-	Opção de manipulação de dados:
								1 - Inclusão
								2 - Alteração
								3 - Exclusão
			aDados		-	Array com as informações a serem manipuladas
			lMsg		-	Indica se exibe mensagem
			lJob		-	Indica se processo está sendo executado por job
			lErrEstrut	-	Indica erro de estrutura
			lPontual	-	Indica processo de validação pontual

@Return	Nil

@Author	Felipe C. Seolin
@Since		04/11/2013
@Version	1.0
/*/
//---------------------------------------------------------------------
Function GravaCU0( nOpc, aDados, lMsg, lJob, lErrEstrut, lPontual )

Local cLoop			:=	""
Local cAlias		:=	""
Local cID			:=	""
Local nRecno		:=	0
Local nI			:=	0
Local nCodSeq		:=	0
Local lLock			:=	Iif( nOpc == 1, .T., .F. )

Local cCadastro		:=	""
Local cDCODER		:=	''

Default lMsg			:=	.F.
Default lJob			:=	.F.
Default lErrEstrut	:=	.F.
Default lPontual		:=	.F.

Do Case

	Case nOpc == 1

		If lMsg
			If lJob
				xTAFMsgJob( "Inclusão de registros..." )
			Else
				IncProc( "Inclusão de registros..." )
				ProcRegua( Len( aDados ) )
			EndIf
		EndIf

		DBSelectArea( "CU0" )

		If !lPontual

			If CU0->( MsSeek(FWxFilial("CU0")) )

				While CU0->( !Eof() ) .And. CU0->CU0_FILIAL == FWxFilial("CU0")
					If FTafExisLock( "CU0", .F., .T. )
						CU0->( DBDelete() )
						CU0->( MsUnlock() )
					EndIf
					CU0->( DBSkip() )
				EndDo

			EndIf

		EndIf

		CU0->( DBSetOrder( 3 ) )

		For nI := 1 to Len( aDados )

			If cAlias <> aDados[nI,1] .or. nRecno <> aDados[nI,2] .or. lErrEstrut
				cID := GetSX8Num( "CU0", "CU0_ID" )
				CU0->( ConfirmSX8() )
				nCodSeq := 1
			Else
				nCodSeq ++
			EndIf

			If lMsg
				If lJob
					xTAFMsgJob( "Incluindo ocorrência: " + aDados[nI,4] + " da Tabela: " + FWX2Nome( aDados[nI,1] ) )
				Else
					IncProc( "Incluindo ocorrência: " + aDados[nI,4] + " da Tabela: " + FWX2Nome( aDados[nI,1] ) )
				EndIf
			EndIf

			DBSelectArea( "SX2" )
			SX2->( DBSetOrder( 1 ) )
			cCadastro := ""
			If !Empty( aDados[nI,9] )
				If SX2->( MsSeek( aDados[nI,9] ) )
					cCadastro := AllTrim( X2Nome() )
					If !"Cadastro de " $ cCadastro
						cCadastro := "Cadastro de " + cCadastro
					EndIf
				EndIf
			Else
				//No caso de erro na integração, não existe cadastro para visualização
				If !Empty( aDados[nI,1] )
					If SX2->( MsSeek( aDados[nI,1] ) )
						cCadastro := AllTrim( X2Nome() )
						If !"Cadastro de " $ cCadastro
							cCadastro := "Cadastro de " + cCadastro
						EndIf
					EndIf
				Else
					Loop //Pula registro. Não faz sentido incluir na CU0 algum registro que não tenha referência de cadastro a ser corrigido
					cCadastro := "Ocorreu um problema que impediu a importação da informação, clique em visualizar para mais detalhes"
				EndIf
			EndIf

			cDCODER	:=	cCadastro + " - "
			If Len( aDados[nI,8] ) > 3 .And. !Empty( aDados[nI,8] )
				cDCODER	+=	"Campo: " + AllTrim( TitSX3( aDados[nI,8] )[1] ) + " (" + AllTrim( aDados[nI,8] ) + ") - " + aDados[nI,5]
			Else
				cDCODER	+=	aDados[nI,5]
			EndIf

			If FTafExisLock( "CU0", lLock, .T. )
				CU0->CU0_FILIAL	:=	xFilial( "CU0" )
				CU0->CU0_ID		:=	cID
				CU0->CU0_CODSEQ	:=	StrZero( nCodSeq, 6 )
				CU0->CU0_DTOCOR	:=	dDataBase
				CU0->CU0_ALIAS	:=	aDados[nI,1]
				CU0->CU0_RECNO	:=	aDados[nI,2]
				CU0->CU0_STATUS	:=	aDados[nI,3]
				CU0->CU0_CODERR	:=	aDados[nI,4]
				CU0->CU0_DCODER	:=	cDCODER
				CU0->CU0_XML	:=	aDados[nI,6]
				CU0->CU0_PROC	:=	aDados[nI,7]
				CU0->CU0_CPOERR	:=	aDados[nI,8]
				CU0->( MsUnlock() )
			EndIf

			cAlias := aDados[nI,1]
			nRecno := aDados[nI,2]

		Next nI

	Case nOpc == 2

		For nI := 1 to Len( aDados )
			//Deselvolver o Seek
			If FTafExisLock( "CU0", lLock, .T. )
				CU0->CU0_DTOCOR	:=	dDataBase
				CU0->CU0_ALIAS	:=	aDados[nI,1]
				CU0->CU0_RECNO	:=	aDados[nI,2]
				CU0->CU0_STATUS	:=	aDados[nI,3]
				CU0->CU0_CODERR	:=	aDados[nI,4]
				CU0->CU0_DCODER	:=	Iif( Len( aDados[nI,8] ) > 3, "Campo " + AllTrim( TitSX3( aDados[nI,8] )[1] ) + " - " + aDados[nI,5], aDados[nI,5] )
				CU0->CU0_XML		:=	aDados[nI,6]
				CU0->CU0_PROC		:=	aDados[nI,7]
				CU0->CU0_CPOERR	:=	aDados[nI,8]
				CU0->( MsUnlock() )
			EndIf
		Next nI

	Case nOpc == 3

		If lMsg
			If lJob
				xTAFMsgJob( "Exclusão de registros..." )
			Else
				IncProc( "Exclusão de registros..." )
				ProcRegua( Len( aDados ) )
			EndIf
		EndIf

		CU0->( DBSetOrder( 3 ) )

		For nI := 1 to Len( aDados )

			If CU0->( MsSeek( xFilial( "CU0" ) + aDados[nI,1] + AllTrim( Str( aDados[nI,2] ) ) ) )

				If lMsg
					If lJob
						xTAFMsgJob( "Excluindo ocorrências da Tabela: " + FWX2Nome( aDados[nI,1] ) + " Recno: " + AllTrim( Str( aDados[nI,2] ) ) )
					Else
						IncProc( "Excluindo ocorrências da Tabela: " + FWX2Nome( aDados[nI,1] ) + " Recno: " + AllTrim( Str( aDados[nI,2] ) ) )
					EndIf
				EndIf

				cLoop := xFilial( "CU0" ) + aDados[nI,1] + AllTrim( Str( aDados[nI,2] ) )

				While CU0->( !Eof() ) .and. CU0->( CU0_FILIAL + CU0_ALIAS + AllTrim( Str( CU0_RECNO ) ) ) == cLoop
					If FTafExisLock( "CU0", lLock, .T. )
						CU0->( DBDelete() )
						CU0->( MsUnlock() )
					EndIf
					CU0->( DBSkip() )
				EndDo

			EndIf

		Next nI

EndCase

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} TAFProc0

@param

@return

@author Demetrio Fontes De Los Rios
@since 30/08/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function TAFProc0( lEnd, lJob, cST2Alias, cST1Alias, nQtdReg, aEstru, cIDThread, lERP )

Local cCampo		:=	""				//Campo
Local cCmpsNotGrv	:=	"TAFIDTHRD"	//Campos que as informacoes nao deverao ser gravadas.
Local cTicket		:=	TAFGTicket()
Local cDate		:=	DToS( Date() )
Local cTime		:=	Time()
Local nCont		:=	0				//Contador
Local nPos1		:=	0				//Posicao dos campos
Local nPos2		:=	0				//Posicao dos campos
Local nProcQtd	:=	0
Local aRecInt		:=	{}				//Array contendo Recno dos registros integrados
Local xConteudo	:=	""				//Conteudo a ser gravado
Local cCodMsg	:=	""

//Tratamento para funcionalidade via Job/Schedule
If !lJob .and. !lERP
	ProcRegua( nQtdReg )
EndIf

//Chave - Status 2 + Identificacao da Thread Responsavel
cChave := Padr( cStsProc, Len( (cST1Alias)->TAFSTATUS ) ) + Padr( cIdThread, Len( (cST1Alias)->TAFIDTHRD ) )

//Seta a Ordem 4 -> TAFSTATUS + TAFIDTHRD
( cST1Alias )->( DBSetOrder( 4 ) )

If ( cST1Alias )->( MsSeek( cChave ) )
	//Processa as informacoes
	While (cST1Alias)->(!EOF()) .AND. ( AllTrim((cST1Alias)->(TAFSTATUS+TAFIDTHRD))== Alltrim( cChave ) )

		cCodMsg	:=	( cST1Alias )->TAFCODMSG

		If FTafExisLock( cST2Alias, .T., .T. )

			For nCont := 1 to Len( aEstru )

				nPos1		:=	( cST1Alias )->( FieldPos( aEstru[nCont,1] ) )
				nPos2		:=	( cST2Alias )->( FieldPos( aEstru[nCont,1] ) )
				cCampo		:=	AllTrim( ( cST2Alias )->( FieldName( nPos2 ) ) )

				if cCampo $ "TAFSTATUS"
					xConteudo	:=	'1'
				elseif nPos1 > 0
					xConteudo	:=	( cST1Alias )->( FieldGet( nPos1 ) )
				else
					xConteudo	:=	''
				endif

				//Tratamento para quando o ultimo caracter informado na TAFST1 nao seja um Pipe(|)
				If cCampo == "TAFMSG"
					xConteudo := AllTrim( xConteudo )
					If !Empty(xConteudo)
						If Right( xConteudo, 1 ) <> "|" .And. cCodMsg == "1"
							xConteudo += "| "
						EndIf
					EndIf
				ElseIf cCampo == "TAFTICKET"
					If Empty( xConteudo )
						xConteudo := cTicket
					EndIf
				ElseIf cCampo == "TAFDATA"
					xConteudo := cDate
				ElseIf cCampo == "TAFHORA"
					xConteudo := cTime
				ElseIf cCampo == "TAFPRIORIT"
					xConteudo := '5' //O default de prioridade do registro é 5
				EndIf

				If !( cCampo $ cCmpsNotGrv )
					( cST2Alias )->( FieldPut( nPos2, xConteudo ) )
				EndIf

			Next nCont

			( cST2Alias )->( DBCommit(), MsUnLock() )

		EndIf

		aAdd( aRecInt, ( cST1Alias )->( Recno() ) )

		//Sai do processamento
		//If lEnd
		//	Alert( "Operação cancelada" )
		//	Exit
		//EndIf

		//Demetrio - 17/08/2014
		//Variavel para tratamento, evitando INCPROC para todo registro, apenas de 5 em 5. Melhor performance/custo INCPROC.
		nProcQtd += 1

		//Tratamento para funcionalidade via Job/Schedule
		If !lJob .and. !lERP .and. nProcQtd > 10
			IncProc( "Processando registro: " + AllTrim( ( cST1Alias )->TAFKEY ) )
			nProcQtd := 0
		EndIf

		( cST1Alias )->( DBSkip() )
	EndDo
EndIf

//Só chama se tiver registros a ser flegados
If Len( aRecInt ) > 0 .and. FTAFFlag( "TAFST1", aRecInt, cStsFinal )
	xTAFMsgJob( "Alteração do Status da TAFST1 realizado com sucesso!", 1 )
EndIf

If !lERP
	Aviso( "Integração TAF", "Processamento realizado com sucesso." , { "Ok" }, 3 )
EndIf

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} TAFProc2

@param cTicketXML - Ticket gerado para o XML que está sendo importado

@Return


@Author Demetrio Fontes De Los Rios
@Since 30/08/2013
@Version 1.0
*/

//-------------------------------------------------------------------
Function TAFProc2( lEnd, lJob, cST2Alias, cST1Alias, nQtdReg, aEstru, cIDThread, aErros, cXERPAlias, lOk, cTicketXML, aTabInd ,cEventos, lDelChild, aCpoObrig, cEscopo )

Local cChave		:=	""
Local cXml			:=	""
Local nCont			:=	0
Local cEvCad		:=	"1000|1010|1020|1030|1040|1050|1060|1070|1080"						//Layouts Cadastrais
Local cEvMen		:=	"1100|1200|1300|1310|1320|1330|1340|1350|1360|1370|1400|1800"		//Layouts Mensais
Local cEvEve		:=	"2200|2220|2240|2260|2280|2300|2320|2325|2330|2340|2345|" +;	//Layouts Eventuais
						"2360|2365|2400|2405|2420|2440|2600|2620|2680|2800|2820|2900|2221|2245|"		//Layouts Eventuais
Local nOpc			:=	3
Local oXML			:=	NIL
Local aRet 			:=	{}
Local aIncons		:=	{}
Local aRecInt		:=	{}
Local aRecErr		:=	{}
Local lInteg		:=	.F.

Local aDadosST2		:=	{}
Local aRelation		:=	{}
Local cTafKeySeq	:=	""

Local cTafKNInt		:=	""
Local aErrChav		:=	{}
Local aErrIntr		:=	{}


Local cChavDel		:=	""
Local cTabDel		:=	""
Local aAreaBkp		:=	""
Local cFather		:=	""
Local cChanel		:=	""
Local cMsgExcl		:=	""
Local nK

Local lFldQueue		:=	( cST2Alias )->( fieldPos( 'TAFSTQUEUE' ) ) > 0
Local lFldOwner		:=	( cST2Alias )->( fieldPos( 'TAFOWNER' ) ) > 0
Local lFldPrdcs		:=	( cST2Alias )->( fieldPos( 'TAFREGPRED' ) ) > 0
Local lFldTrans		:=	( cST2Alias )->( fieldPos( 'TAFFILTRAN' ) ) > 0
Local lFldCkey		:=	( cST2Alias )->( fieldPos( 'TAFKEY' ) ) > 0
Local lFldComp		:=	( cST2Alias )->( fieldPos( 'TAFCOMP' ) ) > 0
Local lExcFltUsr	:=	(((cST2Alias)->( FieldPos( 'TAFUSER') ) > 0) .And. IsInCallStack("TAFA500"))
Local aRecQueue		:=	{}
Local cTimeInteg	:=	""
Local cOwner		:=	""
Local cPredecs		:=	""
Local cKey			:=  ""
Local cFilTran		:=	""
Local cComplem		:= ""
Local cFsUser		:= ""

Private cIndOpe		:=	""	//Utilizada no modelo TAFA062E/S
Private cStatQueue	:=	"" 	//Utilizado na função FGetIdInt para identificar se o registro deve ser considerado na fila de integração
								//Poderá ser alterada para Local após incluir este parâmetro em todas as funções TAFXXXGrv()

Default lJob		:= .F.
Default lOk			:= .T.
Default cTicketXML	:= ""
Default aTabInd	    := {}
Default cEventos	:= ""
Default lDelChild   := .T.
Default aCpoObrig	:= {}
Default cEscopo     := ""  

If lExcFltUsr
	cFsUser	:= AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ))
EndIF

//Tratamento para funcionalidade via Job/Schedule
If !lJob
	ProcRegua( nQtdReg )
EndIf

If aLayOut != Nil .And. Len( aLayOut ) <= 0
	Aviso( "Atenção", "Não foi possível executar o processamento. Falha na criação da estrutura de integração.", { "Fechar" }, 3 )
	lOk := .F.
	Return()
EndIf 

//Seta a Ordem 2 -> TAFKEY
( cXERPAlias )->( DBSetOrder( 2 ) )

//Chave - Status 2 + Identificação da Thread Responsável
cChave := cStsProc + cIdThread
cTimeInteg := Time()
TAFConout("* Inicio Integração TAFProc2 Empresa - " + cEmpAnt +  " - Filial " + cFilAnt + " - TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeInteg,2,.F.,"INTEG")

dbSelectArea(cST2Alias)
(cST2Alias)->( DBSetOrder( 4 ) )

For nK := 1 To 12

	//A necessidade do Set Filter surgiu em decorrência das dependências entre cadastros do Layout TOTVS
	//A integração realiza a ordenção por Layout, ou seja, T001, T002, T003, T004...
	//Porém existem cadastros que dependem de informações de registros posteriores do Layout
	//Foram identificadas duas necessidades:
	//  - Integrar o T011 antes do T010, pois o cadastro de plano de contas exige um campo do centro de custo
	//  - Integrar o T010 antes do T008, pois o cadastro de bens/componentes do Ativo exige um campo do plano de contas
	//  - Integrar o T157 antes do T154 e T013, pois o cadastro de titulos e notas exige um campo do cadastro de obras
	//  - Integrar o T003 antes do T001AE, pois este cadastro utiliza um campo do cadastro de participantes
	//  - Integrar o T125 antes do T124 , pois o cadastro do lalur possui um ID Histórico Padronizado como precedente
	//  - Integrar o T159 antes do T154 , pois o cadastro de SCP é utilizado na fatura
	//  - Integrar o T161 antes do T160 , pois o cadastro de Advogado é utiizado no RRA
	//  - Integrar o T160 antes do T154 , pois o cadastro de RRA é utilizado na fatura
	//  - Integrar o T135 antes do T134 , pois o o cadastro do Responsavel e utilizado na Instituicao Financeira (T134AA)
	if nK == 1
		Set Filter To ( cST2Alias )->TAFTPREG = "T011"
	elseif nK == 2
		Set Filter To ( cST2Alias )->TAFTPREG = "T010"
	elseif nK == 3
		Set Filter To ( cST2Alias )->TAFTPREG = "T157"
	elseif nK == 4
		Set Filter To ( cST2Alias )->TAFTPREG = "T003"
	elseif nK == 5
		Set Filter To ( cST2Alias )->TAFTPREG = "T125"
	elseif nK == 6
		Set Filter To ( cST2Alias )->TAFTPREG = "T159"	
	elseif nK == 7
		Set Filter To ( cST2Alias )->TAFTPREG = "T161"
	elseif nK == 8
		Set Filter To ( cST2Alias )->TAFTPREG = "T160"
	elseif nK == 9
		Set Filter To ( cST2Alias )->TAFTPREG = "T135"
	elseif nK == 10
		Set Filter To ( cST2Alias )->TAFTPREG = "T134"
	 elseIf nK == 11 .and. lExcFltUsr
	 	Set Filter To ( cST2Alias )->TAFUSER = cFsUser
	endif

	//Para cada filtro acima eu zero o array de integrados
	aRecInt := {}

	If ( cST2Alias )->(MsSeek(cChave))

		TAFConout( "INICIOU TafProc2 --> " + Time() + " | ( cST2Alias )->TAFTPREG : " + ( cST2Alias )->TAFTPREG,2,.F.,"INTEG"  ) 

		SX3->( DBSetOrder( 2 ) )

		//Processa as informações
		While ( cST2Alias )->( !Eof() ) .and. ( AllTrim( ( cST2Alias )->( TAFSTATUS + TAFIDTHRD)) == cChave )

			//----------------------------------------------------------------------------
			// Filtra para processar somente os dados dos XMLs que estão sendo importados
			//----------------------------------------------------------------------------
			If (!Empty(cTicketXML) .And. (cST2Alias)->TAFTICKET != cTicketXML) .Or. (!Empty(cEventos) .And. IsInCallStack("TAFDEMAND") .And. !Alltrim((cST2Alias)->TAFTPREG) $ cEventos ) 
				( cST2Alias )->( DBSkip() )
				Loop
			EndIf

			cSeqErro	:=	"0000"
			cRegTAF	:=	AllTrim( ( cST2Alias )->TAFTPREG )
			aIncons	:=	{}
			aRet		:=	{}
			lInteg		:=	.F.

			Begin Transaction

				//Importação da TAFST2 quando o campo MEMO TAFTPREG estiver com o conteudo TXT.
				If ( cST2Alias )->TAFCODMSG == "1" .and. cEscopo $ "|1|2|9|" 

					//Quebra a string TXT contida no campo TAFMSG com todos os seus
					//canais filhos e alimenta o array aDadosST2 com todo o conteúdo.
					aDadosST2 := {}
					aRelation := {}

					cTafKeySeq := ( cST2Alias )->TAFKEY
					cFilRegInt := ( cST2Alias )->TAFFIL

					xTAFVldSeq( .F., cST2Alias, cTafKeySeq, @aDadosST2, @aRecInt, @aRecErr,, cXERPAlias )

					//--------------------------------------------------------------
					//Demetrio De Los Rios - 20/10/2014
					//Chama função que processa a linha passada como parâmetro
					// --------------------------------------------------------------
					TAFConout( "TAFProcLine(TXT) - TAFKEY -> " + AllTrim( cTafKeySeq ) + " - Time: " + Time() + "ThreadID: " + AllTrim( Str( ThreadID() ) ),2,.F.,"INTEG" )
					TAFProcLine(.F.,cST2Alias,cFilRegInt,@aDadosST2,@aRecInt,@aRecErr,@aErrChav,@aErrIntr,@aIncons,/*10*/,cXERPAlias,/*12*/,/*13*/,aLayout,aLaydel,@aTabInd,/*17*/,lDelChild, aCpoObrig)

				//-----------------------------
				//Verifico se o tipo eh XML
				ElseIf (cST2Alias)->TAFCODMSG == "2" .and. cEscopo $ "|3|9|"
					If TAFAtualizado(.F.)
						cStatQueue	:= Iif( lFldQueue , ( cST2Alias )->TAFSTQUEUE , '' )
						cOwner		:= Iif( lFldOwner , AllTrim(( cST2Alias )->TAFOWNER) , '' )
						cKey		:= Iif( lFldCkey  , ( cST2Alias )->TAFKEY , '' )
						cPredecs	:= Iif( lFldPrdcs , ( cST2Alias )->TAFREGPRED , '' )
						cFilTran	:= Iif( lFldTrans , ( cST2Alias )->TAFFILTRAN , '' )
						cComplem	:= Iif( lFldComp  , ( cST2Alias )->TAFCOMP , '' )

						TAFConout( "TafPrepInt(XML) - TAFKEY -> " + Alltrim( ( cST2Alias )->TAFKEY ) + " - Time: " + Time(),2,.F.,"INTEG" )
						aErros := TafPrepInt(	'',;
												(cST2Alias)->TAFFIL,;
												(cST2Alias)->TAFMSG,;
												(cST2Alias)->TAFKEY,;
												'3',;
												(cST2Alias)->TAFTPREG,;
												cXERPAlias,;
												(cST2Alias)->TAFTICKET,;
												@cStatQueue,;
												,;
												,;
												cOwner,;
												cFilTran,;
											  	cPredecs,;
												cComplem )

						//Caso não tenha ocorrido problema na integração do XML eu alimento o array abaixo para que
						//seja incluido o FLAG 3 na tabela TAFST2
						//if empty( aErros )

						// ||---> a validação acima foi comentada pois o status na TAFST2 deve ser atualizado para '3'
						//		  independente do resultado da integração ( sucesso ou rejeitada ).
						if empty( cStatQueue ) .or. cStatQueue == 'R'
							//Adicionado a cStatQueue no array
							aAdd( aRecInt, { (cST2Alias)->( Recno() ), ( cST2Alias )->TAFKEY,  cStatQueue} )
						else
							aAdd( aRecQueue, { (cST2Alias)->( Recno() ), ( cST2Alias )->TAFKEY } )
						endif
					Endif
				//-----------------------------
				//Verifico se o tipo de XML e TSS ( 3 )
				ElseIf ( cST2Alias )->TAFCODMSG == "3"

					//Substitui caracteres com acento para evitar erro ao ler o XML
					cXml := xTafMemo( AllTrim( ( cST2Alias )->TAFMSG ) )

					//Instancia objeto
					oXML := tXmlManager():New()

					//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
					If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
						cXml += ">"
					EndIf

					cXml := StrTran( cXml, ' xmlns="http://www.portalfiscal.inf.br/nfe"', "" )

					If !Empty( cXml ) .and. oXML:Parse( cXml )
						aRet		:=	TAFProc2NFE( oXML, ( cST2Alias )->TAFFIL, ( cST2Alias )->TAFKEY )
						lInteg		:=	aRet[01]
						aIncons	:=	aRet[02]
					Else
						//Erro
						aAdd( aIncons, oXML:Error() ) //oXML:Warning()
					EndIf
				Else
					TAFConout("* ERRO: Tipo de Integração não identificada na TAFProc2 -> Tipo Mensagem: " + ( cST2Alias )->TAFCODMSG + " - Escopo: " + cEscopo + " - Time: " + Time(),2,.T.,"INTEG")
				EndIf

			End Transaction

			//Tratamento para funcionalidade via Job/Schedule
			If !lJob
				IncProc( "Processando registro: " + AllTrim( ( cST2Alias )->TAFKEY ) )
			EndIf

			( cST2Alias )->( DBSkip() )
		EndDo
		//destroi o objeto após o uso
		If __oQryC20 <> nil
			__oQryC20:Destroy()
			__oQryC20 := nil
		EndIf

		If !Empty( cTafKNInt ) .and. !lJob
			Aviso( "Número máximo de inconsistências, TAFKEYs: ", cTafKNInt, { "Ok" }, 3 )
		EndIf

	EndIf

	//-----------------------------------
	//- Flag nos registros processados.
	//- Precisamos fazer isso neste segundo momento pois alteramos campos do índice
	If !lJob
		ProcRegua( Len( aRecInt ) )
	EndIf

	( cST2Alias )->( DBClearFilter() )

	For nCont := 1 to Len( aRecInt )
		( cST2Alias )->( DBGoTo( aRecInt[nCont,1] ) )

		If FTafExisLock( cST2Alias, .F., .T. )
			( cST2Alias )->TAFSTATUS := "3"

			//Tratamento para que o sistema marque o 'R' de forma correta.
			If Len(aRecInt[nCont]) >= 3

				if aRecInt[nCont,3] == 'R'
					( cST2Alias )->TAFSTQUEUE := "R"
				endif
			Else
				if cStatQueue == 'R'
					( cST2Alias )->TAFSTQUEUE := "R"
				endif
			EndIf

			( cST2Alias )->( DBCommit(), MsUnLock() )
		EndIf

		// Tratamento para funcionalidade via Job/Schedule
		If !lJob
			IncProc( "Atualizando registro: " + AllTrim( StrZero( ( cST2Alias )->( Recno() ), 6 ) ) )
		EndIf
	Next nCont

	//-----------------------------------
	//- Flag nos registros não processados e que serão retornados para a fila de integração.
	//- Precisamos fazer isso neste segundo momento pois alteramos campos do índice
	For nCont := 1 to Len( aRecQueue )
		( cST2Alias )->( DBGoTo( aRecQueue[nCont,1] ) )

		If FTafExisLock( cST2Alias, .F., .T. )
			( cST2Alias )->TAFSTATUS := "1"
			( cST2Alias )->TAFDATA := Date()
			( cST2Alias )->TAFHORA := Time()
			( cST2Alias )->( DBCommit(), MsUnLock() )
		EndIf

		// Tratamento para funcionalidade via Job/Schedule
		If !lJob
			IncProc( "Atualizando registro: " + AllTrim( StrZero( ( cST2Alias )->( Recno() ), 6 ) ) )
		EndIf
	Next nCont

Next nK

cTimeInteg := Time()
TAFConout("* Fim Integração TAFProc2 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + Time() + " - Tempo de processamento: " + ElapTime(cTimeInteg,Time())  + " - Quantidade de Registros: " + AllTrim(Str(Len(aRecInt))),2,.F.,"INTEG")

//Inconsistências agora são gravadas na TAFXERP
/*
//- Flag nos registros inconsistentes.
//- Precisamos fazer isso neste segundo momento pois alteramos campos do índice
If Len( aRecErr ) > 0
	FTAFFlag( cST2TAB, aRecErr, "8" )
EndIf

//Grava registros não encontrados para exclusão
If Len( aErrChav ) > 0
	FTAFFlag( cST2TAB, aErrChav, "7" )
EndIf

If Len ( aErrIntr ) > 0
	FTAFFlag( cST2TAB, aErrIntr, "6" )
EndIf
*/

//Limpa memória
oXML := Nil

Return()


//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc6
Processo responsavel por integrar os arquivos xml da pasta indicada para
a tabela ST2.

@param cTicketXML - Ticket gerado para o XML que está sendo importado

@return Nil

@author Daniel Magalhaes
@since 18/12/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFProc6( lJob, cDirProc, cIDThread, nInteg, aTabConf, aPar, lTAFConn, cST2Alias, lOk, cOwner, cFilTran, cTicketXML )

	Local aAreaC1E	 := {}
	Local aDirFile	 := {}
	Local aPieces	 := {}
	Local aFileXML	 := {}
	Local aRegsPred	 := {}
	Local aTafSocial := {}
	Local aStructST2 := (cST2Alias)->( DbStruct() )
	Local cFilName	 := ""
	Local cCodFil	 := ""
	Local cCodMsg	 := ""
	Local cSeq		 := ""
	Local cTpReg	 := ""
	Local cKey		 := ""
	Local cXML		 := ""
	Local cSeek		 := ""
	Local cFilAtu	 := ""
	Local nFor		 := 0
	Local nTamCpo	 := aStructST2[ aScan( aStructST2, { |x| x[1] == "TAFREGPRED" } ) ][3]
	Local cTicket	 := TAFGTicket()
	Local dDtTicket	 := Date()
	Local cHrTicket	 := Time()
	Local lFormato	 := .T.
	Local lFindFil	 := .T.
	Local lFldTrans	 := ( cST2Alias )->( fieldPos( 'TAFFILTRAN' ) ) > 0
	Local cComplST2	 := ""
	Local cUserInt 	 := AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" )) //usuário que integrou
	
	Default cDirProc 	:= ""
	Default lOk 		:= .T.
	
	Default lJob		:= .F.
	Default cIDThread	:= ""
	Default nInteg		:= ""
	Default aTabConf	:= {}
	Default aPar		:= {}
	Default lTAFConn	:= .F.
	Default cST2Alias	:= ""
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cTicketXML	:= ""
	
	//--------------------------------------------------------------------------------------------------------------------
	// Obtem o codigo do ticket por variavel de referencia para uso nos demais processos (TAFPROC2, TAFPROC3 e xTAFSlice)
	//--------------------------------------------------------------------------------------------------------------------
	cTicketXML := cTicket
	aTafSocial := TAFRtEso()
	
	//Verifica se a pasta de trabalho foi criada
	If Empty(cDirProc)
	
		If !lJob
			MsgStop("Não foram encontrados arquivos XML na pasta informada.")
		Else
			xTAFMsgJob("Não foram encontrados arquivos XML na pasta informada.")
		EndIf
		lOk := .F.
	
	Else
	
		If !lTAFConn
	
			If !lJob
				MsgStop("Não foi possível abrir as tabelas de integracao...")
			Else
				xTAFMsgJob("Não foi possível abrir as tabelas de integracao...")
			EndIf
			lOk := .F.
	
		Else
	
			aDirFile := Directory( cDirProc + "*.xml",,,!IsSrvUnix())
	
			xTAFMsgJob("Selecionando arquivos para processamento...")
	
			If lJob
	
				If !Empty(aPar)
	
					aAreaC1E := C1E->(GetArea())
	
					C1E->(DbSetOrder(3))
	
					If C1E->(MsSeek(xFilial("C1E") + PadR(aPar[5], GetSX3Cache("C1E_FILTAF", "X3_TAMANHO")) + "1"))
	
						cFilAtu := PadR(C1E->C1E_CODFIL, Len((cST2Alias)->TAFFIL))
	
					EndIf
	
					RestArea(aAreaC1E)
	
				EndIf
			
			EndIf
	
			For nFor := 1 To Len(aDirFile)
				lFormato := .T.
	
				cFilName := aDirFile[nFor][1]
	
				xTAFMsgJob( "Processando arquivo: " + cFilName )
	
				aPieces  := {}
	
				//Quebra o nome do arquivo, que deve ter o seguinte formato:
				//11_22222_S-3333;COMP_xxx.xml
				//Onde: 11     = Código da empresa (Ex.: T1)
				//      22222  = Filial (Ex.: DMG01)
				//      S-3333 = Evento eSocial (Ex.: S-1030)
				//		COMP   = Indica o conteúdo complementar a ser gravado no campo TAFCOMP na TAFST2
				//      xxx    = Conteúdo livre
				aPieces  := StrTokArr( StrTran(Upper(cFilName),".XML",""), "_")
	
				//Arquivo com o nome no formato incorreto
				If Len(aPieces) < 3
					Loop
				EndIf
	
				//1°Padrao Onde se Espera EEFF, EX: 9901
				cCodFil	 :=	PadR( aPieces[1],	Len((cST2Alias)->TAFFIL ) )
				cCodMsg  := PadR( "2",	Len((cST2Alias)->TAFCODMSG ) )
				cSeq	 := StrZero( 1,	Len((cST2Alias)->TAFSEQ ) )
	
				cTpReg	 := Upper( aPieces[2] )
				cTpReg	 := PadR( cTpReg, Len((cST2Alias)->TAFTPREG  ) )
	
				// --> Tratamento para informar o campo específico
				cTpReg := GetTpReg( cTpReg, @cComplST2 )
	
				//2°Padrao Onde se Espera EE_FF, EX: 99_01
				If aScan( aTafSocial, {|a| a[5] == AllTrim(cTpReg) }) == 0
					If (Len(aPieces) >= 3 .And. ValType(aPieces[3]) == "C" .And. ("S-" # Upper(aPieces[3])))
						If ValType(aPieces[1]) == "C" .And. ValType(aPieces[2]) == "C"
							cCodFil	 :=	PadR((aPieces[1]+aPieces[2]), Len((cST2Alias)->TAFFIL))
						EndIF
						cTpReg	 := Upper(aPieces[3])
						cTpReg	 := AllTrim(PadR(cTpReg, Len((cST2Alias)->TAFTPREG)))
						lFormato := .F.
	
						// --> Tratamento para informar o campo específico
						cTpReg := GetTpReg( cTpReg, @cComplST2 )
	
					EndIf
				Endif
	
				cKey    := AllTrim(cFilName)
	
				If aScan( aTafSocial, {|a| a[5] == AllTrim(cTpReg) }) == 0 .And. lFormato
					
					If !lJob
						MsgStop("O formato do campo Tipo de Registro deve utilizar a máscara S-NNNN, onde NNNN é o número do layout do e-Social. Tp Reg: " + cTpReg)
					Else
						xTAFMsgJob( "O formato do campo Tipo de Registro deve utilizar a máscara S-NNNN, onde NNNN é o número do layout do e-Social. Tp Reg: " + cTpReg )
					EndIf
					lOk := .F.
				
				ElseIf !lJob .OR. cFilAtu == cCodFil .OR. (lJob .And. !Empty(cCodFil))

					nFilFiles--

					//Monta a chave de pesquisa
					cSeek := cCodFil
					cSeek += cCodMsg
					cSeek += cSeq
					cSeek += cTpReg
					cSeek += cKey
	
					(cST2Alias)->( DbSetOrder(1) )
					If (cST2Alias)->( MsSeek(cSeek) )
	
						If !lJob
							MsgStop("A chave informada já foi registrada na base de dados do SIGATAF. Chave: " + cSeek)
						Else
							xTAFMsgJob( "A chave informada já foi registrada na base de dados do SIGATAF. Chave: " + cSeek )
						EndIf
						lOk := .F.
	
					Else
	
						lFindFil := .T.
	
						If lFindFil
	
							aFileXML := {}
							aFileXML := TAFReadFl(cDirProc + cFilName)
	
							If aFileXML[2]
	
								cXML := aFileXML[3]
	
								If Reclock(cST2Alias, .T.) //grava TAFSTS MPS1284
	
									(cST2Alias)->TAFFIL      := cCodFil
									(cST2Alias)->TAFCODMSG   := cCodMsg
									(cST2Alias)->TAFSEQ      := cSeq
									(cST2Alias)->TAFTPREG    := cTpReg
									(cST2Alias)->TAFKEY      := cKey
									(cST2Alias)->TAFMSG      := cXML
									(cST2Alias)->TAFSTATUS   := "1"
									(cST2Alias)->TAFTICKET   := cTicket
									(cST2Alias)->TAFDATA	 := dDtTicket
									(cST2Alias)->TAFHORA	 := cHrTicket
									(cST2Alias)->TAFOWNER    := cOwner
	
									If lFldTrans
										(cST2Alias)->TAFFILTRAN  := cFilTran
									EndIf
	
									if (cST2Alias)->( FieldPos( 'TAFPRIORIT') ) > 0
										(cST2Alias)->TAFPRIORIT	:=	'5'
									endif
	
									If (cST2Alias)->( FieldPos( 'TAFCOMP') ) > 0
										(cST2Alias)->TAFCOMP := cComplST2
									EndIf
	
									If (cST2Alias)->( FieldPos( 'TAFUSER') ) > 0
										(cST2Alias)->TAFUSER := cUserInt
									EndIf
	
									(cST2Alias)->( MsUnlock() )
	
									If cTpReg $ "S-2206|S-2205|S-2230|S-2231|S-2210"
										aAdd( aRegsPred, {	cCodFil,;
															cKey,;
															cTpReg,;
															cXML,;
															dDtTicket,;
															cHrTicket,;
															Space( nTamCpo ),;
															(cST2Alias)->( Recno() ) } )
									EndIf
	
									xTAFMsgJob( "XML incluído com sucesso." )
	
								Else
	
									If !lJob
										MsgStop("Erro na gravação do XML.")
									Else
										xTAFMsgJob( "Erro na gravação do XML." )
									EndIf
									lOk := .F.
	
								EndIf
	
							Else
	
								If !lJob
									MsgStop("Erro na leitura do arquivo.")
								Else
									xTAFMsgJob( "Erro na leitura do arquivo." )
								EndIf
								lOk := .F.
	
							EndIf
	
						EndIf
	
					EndIf
	
				EndIf
	
				cComplST2 := ""
	
			Next nFor
	
		EndIf
	
	EndIf
	
	xTAFMsgJob( "Processo finalizado." )
	If !lJob
	
		If Len( aRegsPred ) > 0
	
			If ApMsgYesNo( "Foram informados registros que podem possuir predecessores, deseja informar?" )
				TAFVincRegs( aRegsPred, cST2Alias )
			EndIf
	
		EndIf
	
		If !IsInCallStack("TAFA500")
			MsgInfo("Processo finalizado.")
		EndIf
	
	EndIf

	aTafSocial := {}
	aTafSocial := Nil 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConn

@param	nOpc  		-
		nInteg		-
		aTABDados	-
		aTabConf	-
		aErros      -
		aPar 		-
		lJob -      - Indica se processamento eh Job

@return lOk -

@author Demetrio Fontes De Los Rios
@since 30/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFConn(nOpc,nInteg,aTABDados,aTabConf,aErros, aPar,cTopBuild,cBancoDB,lJob,nHdlTaf,cMvTAFTALI,cMvTAFTDB,nMvTAFPort )

Local aTopInfo		:= FWGetTopInfo()
Local lRet 		:= .F.
Local lConn1		:= .F.
Local lConn2		:= .F.
Local aEstruST		:= {}
Local aIndST		:= {}
Local nCont	   	:= 0
Local lTAFDTS		:= GetNewPar("MV_TAFDTSL",.F.) 					// INDICA SE O AMBIENTE REALIZA INTEGRAÇÃO COM DATASUL.

Local aTAFXERP	:=	xTAFGetStru( aTABDados[03,01] )

Default aTabConf 	:= xTAFGetStru(aTABDados[01,01]) 				// Busca Estrutura/Configuracoes das tabelas
Default nHdlTaf  := 0
Default cMvTAFTDB	    := GetNewPar("MV_TAFTDB","") 					// Parametro MV_TAFTDB - TAF TOP DATABASE DO ERP
Default cMvTAFTALI	:= Getmv("MV_TAFTALI")				 			// Parametro MV_TAFTALI- TAF TOP ALIAS DO ERP
Default nMvTAFPort	:= GetNewPar("MV_TAFPORT",aTopInfo[03]) 		// Parametro MV_TAFPORT- PORTA DO DBACCESS - DEFAULT PORTA CORRENTE

aEstruST	:= aTabConf[01]
aIndST		:= aTabConf[02]

// Abrir tabelas, criar conexoes;
If nOpc==1

	// ------------------------------------------------
	// Msg Server
	xTAFMsgJob("Estabelecendo Conexão...") // "Estabelecendo Conexão..."

	// ------------------------------------------------
	// Base Local
	If Len( aTABDados ) > 1
		lConn2 :=	xTAFCriaTB( nOpc, aTopInfo, aTABDados[2,1], aTABDados[2,2], __CRDD, aEstruST, aIndST, cTopBuild, cBancoDB, .F., lJob, @aErros, @nHdlTaf ) .and.;
					xTAFCriaTB( nOpc, aTopInfo, aTABDados[3,1], aTABDados[3,2], __CRDD, aTAFXERP[1], aTAFXERP[2], cTopBuild, cBancoDB, .F., lJob, @aErros, @nHdlTaf )

		IF !lConn2
			Return (.F.)
		Endif

	EndIf

	// ------------------------------------------------
	// Base ERP
	If lConn2 .AND. (nInteg<=1) .AND. (!Empty(cMvTAFTDB) .Or. ( !Empty(ALLTRIM( Iif( !lJob, cMvTAFTDB, aPar[3] ))))) ;
								   	.AND. (!Empty(cMvTAFTALI) .Or. ( !Empty(ALLTRIM( Iif( !lJob, cMvTAFTALI, aPar[2])))))


		//Se o usuário preencher os campos da tela, ignoro os parâmetros MV_TAFTDB e MV_TAFTALI.
		aTopInfo[03] := Iif(nMvTAFPort==0,aTopInfo[03],nMvTAFPort)
		aTopInfo[04] := Iif( ALLTRIM( Iif( !lJob, cMvTAFTDB, aPar[3] )) == '', cMvTAFTDB, ALLTRIM(Iif( !lJob, cMvTAFTDB, aPar[3] )))
		aTopInfo[05] := Iif( ALLTRIM( Iif( !lJob, cMvTAFTALI, aPar[2] )) == '', cMvTAFTALI,ALLTRIM(Iif( !lJob, cMvTAFTALI, aPar[2] )))
		lConn1 := xTAFCriaTB(nOpc,aTopInfo,aTABDados[1,1],aTABDados[1,2],__CRDD,aEstruST,aIndST,cTopBuild,cBancoDB,lTAFDTS,lJob, @aErros, @nHdlTaf)
	EndIf

	// ------------------------------------------------
	// Msg Server
	If lConn2 .AND. Iif((nInteg<=1),lConn1,.T.)
		xTAFMsgJob("Conexão Estabelecida...") // "Conexão Estabelecida..."
		lRet := .T.
	Else
		aAdd(aErros,{ '', 0, '1', '', '', "***ERRO*** - Conexão não Estabelecida..."+CRLF+"Verifique os parâmetros MV_TAFTDB e MV_TAFTALI", '', '', '' })
		xTAFMsgJob("***ERRO*** - Conexão não Estabelecida...") // "Conexão Estabelecida..."
	EndIf

// Fechar tabelas
ElseIf nOpc==2

	xTAFMsgJob("Conexão encerrada...")
	For nCont:=1 to Len(aTabDados)
		If (Select(aTabDados[nCont,2])>0)
			(aTabDados[nCont,2])->(dbCloseArea())
			lRet := .T.
		EndIf
	Next nCont

	//Encerra a conexão com a tabela TAFST1 caso exista
	if nHdlTaf > 0
		TcUnlink( nHdlTaf )
		nHdlTaf := 0
	endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Demetrio Fontes De Los Rios (Dema)
@since  23/10/2013
@version 1.0

/*///----------------------------------------------------------------
//Static Function SchedDef()

//Local aParam  := {}

/*
aParam := { "P",;			//Tipo R para relatorio P para processo
            "TAFINTEG",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo
*/

//Conout( "ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***ScheDef***" )

//Return ( aParam )


//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc8
Processo responsavel ler os XMLs de notas fiscais autorizadas pelo Sefaz no TSS e gravar o registros na tabela ST2.

@return Nil

@author Daniel Magalhaes
@since 10/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFProc8( lJob, cIDThread, nInteg, aTabConf, aPar, lMsgJob, oProcess, aTAFConn, lTAFConn, cST2Alias )

Local aErros   := {}
Local aDirFile := {}
Local aPieces  := {}
Local aFileXML := {}
Local aTABDados:= {}
Local cFilName := ""
Local cFil     := ""
Local cCodMsg  := ""
Local cSeq     := ""
Local cTpReg   := ""
Local cKey     := ""
Local cXML     := ""
Local cSeek    := ""
Local cTAFFil  := ""
Local cTAFMsg  := cTAFCodNFe // "3"
Local cTAFReg  := "NFESBRA"
Local nFor     := 0
Local lTAFConn := .F.
//Local cST1Alias:= GetNextAlias()
//Local cST2Alias:= GetNextAlias()
Local loProcess:= (ValType(oProcess)=="O")
Local nST1Link
Local nST2Link

Local cIdEmpresa := "" //ID da Empresa no TSS
Local cURL       := PadR(GetNewPar("MV_TAFSURL","http://"),250)
Local aNotas     := {}

//aTABDados:= { { cST1TAB, cST1Alias }, { cST2TAB, cST2Alias } }

If lTAFConn //!(lTAFConn := TAFConn( 1, nInteg, aTAFConn, aTABDados, aTabConf, aErros, aPar, lJob, @nST1Link, @nST2Link, lMsgJob ))

	xTAFMsgJob("Não foi possível abrir as tabelas de integracao...")

Else

	IF (loProcess)
		oProcess:SetRegua1( Len(aDirFile) )
	EndIf

	xTAFMsgJob("Selecionando arquivos para processamento...")

	//Verifica o cadastro de Complemento de Estabelecimento
	C1E->( DbSetOrder(3) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
	If !C1E->( MsSeek( xFilial("C1E") + PadR(cFilAnt, TamSX3("C1E_FILTAF")[1] ) + "1" ) )

		xTAFMsgJob( "O código de filial informado ('" + cFilAnt + "') não está cadastrado na tabela de Complemento de Estabelecimento do SIGATAF." )

	Else

		//Tenta obter o Id Empresa no TSS
		cIdEmpresa := "000001"//RetIdEnti()

		cTAFFil    := C1E->C1E_CODFIL

		If !Empty(cIdEmpresa)

			oWSNFe:= WSNFeSBRA():New()
			oWSNFe:cUserToken        := "TOTVS"
			oWSNFe:cID_ENT           := cIdEmpresa
			oWSNFe:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
			oWSNFe:cIdInicial        := TAFNFEId(cTAFFil, cTAFReg, cST2Alias)
			oWSNFe:cIdFinal          := Replicate("Z",20)
			oWSNFe:nDiasparaExclusao := 0

			lOk:= oWSNFe:RetornaFaixa()

			oRetorno := oWSNFe:oWsRetornaFaixaResult //oWsRetornaFxResult

			If ValType(oRetorno:oWSNotas) == "O"
				aNotas := oRetorno:oWSNotas:oWSNfeS3
			EndIf

			For nFor := 1 To Len(aNotas)

				cTAFFil := PadR( cTAFFil, Len((cST2Alias)->TAFFIL   ) )
				cTAFMsg := PadR( cTAFMsg, Len((cST2Alias)->TAFCODMSG) )
				cSeq    := StrZero( 1, Len((cST2Alias)->TAFSEQ ) )
				cTAFReg := PadR( cTAFReg, Len((cST2Alias)->TAFTPREG ) )

				cIdNota := aNotas[nFor]:cId
				cIdNota := PadR( cIdNota, Len((cST2Alias)->TAFKEY   ) )

				//Monta a chave de pesquisa
				cSeek := cTAFFil
				cSeek += cTAFMsg
				cSeek += cSeq
				cSeek += cTAFReg
				cSeek += cIdNota

				(cST2Alias)->( DbSetOrder(1) )
				If (cST2Alias)->( MsSeek(cSeek) )


					xTAFMsgJob( "A chave informada já foi registrada na base de dados do SIGATAF. Chave: " + cSeek )

				Else


					If FTafExisLock(cST2Alias, .T., .T.)

						cProtNota    := aNotas[nFor]:oWSNfe:cProtocolo
						cXMLNota     := aNotas[nFor]:oWSNfe:cXML
						cXMLProtNota := aNotas[nFor]:oWSNfe:cXMLProt

						If ValType(aNotas[nFor]:oWSNfeCancelada) == "O"

							//cProtCanc    := aNotas[nFor]:oWSNfeCancelada:cProtocolo
							//cXMLCanc     := aNotas[nFor]:oWSNfeCancelada:cXML
							//cXMLProtCanc := aNotas[nFor]:oWSNfeCancelada:cXMLProt
							cProtNota    := aNotas[nFor]:oWSNfeCancelada:cProtocolo
							cXMLNota     := aNotas[nFor]:oWSNfeCancelada:cXML
							cXMLProtNota := aNotas[nFor]:oWSNfeCancelada:cXMLProt

						EndIf

						(cST2Alias)->TAFFIL    := cTAFFil
						(cST2Alias)->TAFCODMSG := cTAFMsg
						(cST2Alias)->TAFSEQ    := cSeq
						(cST2Alias)->TAFTPREG  := cTAFReg
						(cST2Alias)->TAFKEY    := cIdNota
						(cST2Alias)->TAFMSG    := cXMLNota
						(cST2Alias)->TAFSTATUS := "1"

						(cST2Alias)->( MsUnlock() )

						xTAFMsgJob( "XML incluído com sucesso. ID Nota: " + cIdNota )

					Else

						xTAFMsgJob( "Erro na gravação do XML. (ID Nota: " + cIdNota + ")" )

					EndIf

				EndIf

			Next nFor

		EndIf

	EndIf

	//TAFConn( 2, nInteg, aTAFConn, aTABDados, NIL, aErros, aPar, lJob, NIL, NIL, lMsgJob )

EndIf

xTAFMsgJob( "Processo finalizado." )
If !lJob

	//IF (loProcess)
	//	oProcess:SetRegua1( 1 )
	//	oProcess:IncRegua1( "Processo finalizado." )
	//EndIf

	MsgInfo("Processo finalizado.")
EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFNFEId
Pesquisa e retorna o proximo TAFKEY para chamada do Webservice de NFE do TSS

@return character, Proximo ID de NFE

@author Daniel Magalhaes
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFNFEId(cTAFFil, cTAFReg, cST2Alias)
Local aArea     := GetArea()
Local cNextID   := Space(20)
Local cQuery    := ""
Local cQryAlias := GetNextAlias()

Default cTAFFil := ""
Default cTAFReg := ""

If !Empty(cTAFFil) .And. !Empty(cTAFReg)

	cTAFFil := PadR( cTAFFil, Len((cST2Alias)->TAFFIL  ) )
	cTAFReg := PadR( cTAFReg, Len((cST2Alias)->TAFTPREG) )

	cQuery := " SELECT MAX(ST2.TAFKEY) MAXKEY" + CRLF
	cQuery += "   FROM TAFST2 ST2" + CRLF
	cQuery += "  WHERE ST2.TAFFIL     = '" + cTAFFil + "'" + CRLF
	cQuery += "    AND ST2.TAFCODMSG  = '3'" + CRLF
	cQuery += "    AND ST2.TAFTPREG   = '" + cTAFReg + "'" + CRLF
	cQuery += "    AND ST2.D_E_L_E_T_ = ' '" + CRLF

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cQryAlias, .T., .F. )

	If !(cQryAlias)->( Eof() )
		cNextID := Soma1( AllTrim((cQryAlias)->MAXKEY) )
	EndIf

	(cQryAlias)->( dbCloseArea() )

EndIf

RestArea(aArea)

Return cNextID

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc2NFE
Processa o XML das NF-e's e grava nas tabelas to TAF

@return array, aRet[1]: (T/F) Indica se integrou os dados.
               aRet[2]: (array) Inconsistencias encontradas.

@author Daniel Magalhaes
@since 22/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFProc2NFE( oXml, cFilEv, cNFKey )
Local aArea   := GetArea()
Local aDados  := {}
Local aIncons := {}
Local lRet    := .F.
Local cFilTAF := ""
Local cPathIn := "/NFe/infNFe"
Local cPathTp := "/NFe/infNFe/ide/tpNF"
Local cPathMd := "/NFe/infNFe/ide/mod"
Local cPathNF := ""

//Totalizadores
Local nC20_VLMERC := 0
Local nC20_VLDESC := 0
Local aTotTrib    := {}

Private oDados    := oXml
Private cIndOpe   := ""   //Utilizada no modelo TAFA062E/S
Private lVldModel := .T.

Default cFilEv := ""

cFilTAF := FTafGetFil( cFilEv, @aIncons )

If !Empty(cFilEv) .And. !Empty(cFilTAF)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso eu encontre a filial de destino da importacao alimento³
	//³a variavel cFilAnt                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := cFilTAF

	//Recupera a chave da NF-e
	If oDados:XPathHasNode( cPathIn )

		cC20_CHVELE := oDados:XPathGetAtt( cPathIn, "Id" )

	EndIf

	//Recupera o tipo de operacao da NF-e
	If oDados:XPathHasNode( cPathTp )

		cIndOpe := FTafGetVal( cPathTp , "C", .F., @aIncons, .T. ) //oDados:XPathGetNodeValue( cPathTp, "value" )

	EndIf

	//Recupera o modelo da nota
	If oDados:XPathHasNode( cPathMd )

		cC20_CODMOD := FTafGetVal( cPathMd, "C", .F., @aIncons, .T. )
		cC20_CODMOD := TAFGetId( cC20_CODMOD, "C01", aIncons )

		//Preenche o parametro MV_PAR01 para que o modelo seja carregado corretamente
		MV_PAR01 := cC20_CODMOD

	EndIf

	//Inicializa o Modelo TAFA062
	oModel := FWLoadModel( "TAFA062" )

	oModel:SetOperation( MODEL_OPERATION_INSERT )
	oModel:Activate()

	//Bloco B - Identifica‡Æo da Nota Fiscal eletr“nica (/NFe/infNFe/ide)
	cPathIde := "/NFe/infNFe/ide"
	If !oDados:XPathHasNode( cPathIde )

		Aadd( aIncons, "Nao foi possivel encontrar a tag obrigatoria: " + cPathIde )

	Else

		cC20_CHVNF  := cNFKey
		cC20_INDPAG := FTafGetVal( cPathIde + "/indPag" , "C", .F., @aIncons, .T. )
		cC20_SERIE  := FTafGetVal( cPathIde + "/serie"  , "C", .F., @aIncons, .T. )
		cC20_NUMDOC := FTafGetVal( cPathIde + "/nNF"    , "C", .F., @aIncons, .T. )
		cC20_DTDOC  := FTafGetVal( cPathIde + "/dEmi"   , "D", .F., @aIncons, .T. )

		cC20_DTES   := FTafGetVal( cPathIde + "/dSaiEnt", "D", .F., @aIncons, .F. )
		cC20_DTES   := IIf( Empty(cC20_DTES), cC20_DTDOC, cC20_DTES)

		cC20_HSAIEN := FTafGetVal( cPathIde + "/hSaiEnt", "C", .F., @aIncons, .F. )
		cC20_INDEMI := FTafGetVal( cPathIde + "/tpEmis" , "C", .F., @aIncons, .F. )

		cC20_TPDOC  := FTafGetVal( cPathIde + "/finNFe" , "N", .F., @aIncons, .F. )
		cC20_TPDOC  := StrZero( cC20_TPDOC, TamSX3("C20_TPDOC")[1] )

		//Pesquisa o codigo de finalidade do documento
		cC20_TPDOC  := TAFGetId( cC20_TPDOC, "C0U", aIncons )

		oModel:LoadValue( "MODEL_C20", "C20_CHVNF ", cC20_CHVNF  )
		oModel:LoadValue( "MODEL_C20", "C20_INDPAG", cC20_INDPAG )
		oModel:LoadValue( "MODEL_C20", "C20_CODMOD", cC20_CODMOD )
		oModel:LoadValue( "MODEL_C20", "C20_SERIE ", cC20_SERIE  )
		oModel:LoadValue( "MODEL_C20", "C20_NUMDOC", cC20_NUMDOC )
		oModel:LoadValue( "MODEL_C20", "C20_DTDOC ", cC20_DTDOC  )
		oModel:LoadValue( "MODEL_C20", "C20_DTES  ", cC20_DTES   )
		oModel:LoadValue( "MODEL_C20", "C20_HSAIEN", cC20_HSAIEN )
		oModel:LoadValue( "MODEL_C20", "C20_INDEMI", cC20_INDEMI )
		oModel:LoadValue( "MODEL_C20", "C20_TPDOC ", cC20_TPDOC  )
		oModel:LoadValue( "MODEL_C20", "C20_CHVELE", cC20_CHVELE )


		/*--X--

		Demais Campos
		-------------
		FTafGetVal( cPathIde + "/cUF"    , "C", .F., @aIncons, .F. )
		FTafGetVal( cPathIde + "/cNF"    , "C", .F., @aIncons, .F. )
		FTafGetVal( cPathIde + "/natOp"  , "C", .F., @aIncons, .F. )
		FTafGetVal( cPathIde + "/tpNF"   , "C", .F., @aIncons, .F. )
		FTafGetVal( cPathIde + "/cMunFG" , "C", .F., @aIncons, .F. )

		--X--*/

		nNfref := 1
		cPathNfref := cPathIde + "/Nfref[" + StrZero(nNfref,1) + "]"

		While oDados:XPathHasNode( cPathNfref )

			If oDados:XPathHasNode( cPathNfref+"/refNF" )

				/*--X--

				Campos
				------
				FTafGetVal( cPathNfref + "/refNF" + "/cUF"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNF" + "/AAMM" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNF" + "/CNPJ" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNF" + "/mod"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNF" + "/serie", "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNF" + "/nNF"  , "C", .F., @aIncons, .F. )

				--X--*/

			EndIf

			If oDados:XPathHasNode( cPathNfref+"/refNFP" )

				/*--X--

				Campos
				------
				FTafGetVal( cPathNfref + "/refNFP" + "/cUF"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/AAMM"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/CNPJ"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/CPF"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/IE"    , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/mod"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/serie" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/nNF"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refNFP" + "/refCTe", "C", .F., @aIncons, .F. )

				--X--*/

			EndIf

			If oDados:XPathHasNode( cPathNfref+"/refECF" )

				/*--X--

				Campos
				------
				FTafGetVal( cPathNfref + "/refECF" + "/mod"    , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/nECF"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/nCOO"   , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/tpImp"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/tpEmis" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/cDV"    , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/tpAmb"  , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/finNFe" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/procEmi", "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/verProc", "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/dhCont" , "C", .F., @aIncons, .F. )
				FTafGetVal( cPathNfref + "/refECF" + "/xJust"  , "C", .F., @aIncons, .F. )

				--X--*/

			EndIf

			nNfref++
			cPathNfref := cPathIde + "/Nfref[" + StrZero(nNfref,1) + "]"

		EndDo

		//Bloco C - Identifica‡Æo do Emitente da Nota Fiscal eletr“nica (/NFe/infNFe/emit)
		cPathEmit := "/NFe/infNFe/emit"
		If !oDados:XPathHasNode( cPathEmit )

			Aadd( aIncons, "Nao foi possivel encontrar a tag obrigatorioa: " + cPathEmit )

		Else

			/*--X--
			Campos
			------
			CNPJ
			CPF
			xNome
			xFant

			Campos Tag /NFe/infNFe/emit/enderEmit
			-------------------------------------
			xLgr
			nro
			xCpl
			xBairro
			cMun
			xMun
			UF
			CEP
			cPais
			xPais
			fone
			IE
			IEST
			IM
			CNAE
			CRT

			--X--*/

		EndIf //Fim Bloco C

		//Bloco D - Identifica‡Æo do Fisco Emitente da NF-e (/NFe/infNFe/avulsa - Uso do Fisco)
			/*--X--
			Campos
			------
			CNPJ
			xOrgao
			matr
			xAgente
			fone
			UF
			nDAR
			dEmi
			vDAR
			repEmi
			dPag

			--X--*/

		//Bloco E - Identifica‡Æo do Destinat rio da Nota Fiscal eletr“nica (/NFe/infNFe/dest)
		cPathDest := "/NFe/infNFe/dest"
		If !oDados:XPathHasNode( cPathDest )

			Aadd( aIncons, "Nao foi possivel encontrar a tag obrigatorioa: " + cPathDest )

		Else

			cCNPJDest := FTafGetVal( cPathDest + "/CNPJ" , "C", .F., @aIncons, .F. )
			cCPFDest  := FTafGetVal( cPathDest + "/CPF"  , "C", .F., @aIncons, .F. )

			//Pesquisa o codigo do destinatario
			If !Empty(cCNPJDest)

				cCodDest := TAFGetId( cCNPJDest, "C1H", aIncons, 3 )

			ElseIf !Empty(cCPFDest)

				cCodDest := TAFGetId( cCPFDest,  "C1H", aIncons, 3 )

			EndIf

			oModel:LoadValue( "MODEL_C20", "C20_CODPAR", cCodDest )
		EndIf


		//Bloco F - Identifica‡Æo do Local de Retirada (/NFe/infNFe/retirada)
			/*--X--
			Campos
			------
			CNPJ
			CPF
			xLgr
			nro
			xCpl
			xBairro
			cMun
			xMun
			UF

			--X--*/

		//Bloco G - Identifica‡Æo do Local de Entrega (/NFe/infNFe/entrega)
			/*--X--
			Campos
			------
			CNPJ
			CPF
			xLgr
			nro
			xCpl
			xBairro
			cMun
			xMun
			UF

			--X--*/

		//Bloco H - Detalhamento de Produtos e Servi‡os da NF-e (/NFe/infNFe/det[n])
		nDet := 1
		cPathDet := "/NFe/infNFe/det[" + StrZero(nDet,1) + "]"

		While oDados:XPathHasNode( cPathDet )

			//Inclui linha na grid do modelo
			If nDet > 1
				// Informa que a linha está válida para que seja incluída uma nova linha
				oModel:GetModel( "MODEL_C30" ):LVALID := .T.

				// Inclui uma linha a cada volta do laço
				oModel:GetModel( "MODEL_C30" ):AddLine()
			EndIf

			//Numero do item
			cNumItem := oDados:XPathGetAtt( cPathDet, "nItem" )
			cNumItem := StrZero( Val(cNumItem), TamSX3("C30_NUMITE")[1] )

			oModel:LoadValue( "MODEL_C30", "C30_NUMITE", cNumItem )

			//Bloco I - Produtos e Servi‡os da NF-e (/NFe/infNFe/det[n]/prod)

			//Id do produto/servico
			cIdProd := FTafGetVal( cPathDet + "/prod" + "/cProd" , "C", .F., @aIncons, .F. )
			cIdProd := TAFGetId( cIdProd, "C1L", aIncons )

			oModel:LoadValue( "MODEL_C30", "C30_CODITE", cIdProd )

			//Id do CFOP
			cIdCFOP := FTafGetVal( cPathDet + "/prod" + "/CFOP" , "C", .F., @aIncons, .F. )
			cIdCFOP := TAFGetId( cIdCFOP, "C0Y", aIncons )

			oModel:LoadValue( "MODEL_C30", "C30_CFOP", cIdCFOP )

			nC30_QUANT  := FTafGetVal( cPathDet + "/prod" + "/qCom"  , "N", .F., @aIncons, .F., Nil, Nil, .F. )
			nC30_VLRITE := FTafGetVal( cPathDet + "/prod" + "/vUnCom", "N", .F., @aIncons, .F., Nil, Nil, .F. )
			nC30_TOTAL  := FTafGetVal( cPathDet + "/prod" + "/vProd" , "N", .F., @aIncons, .F., Nil, Nil, .F. )
			nC30_VLDESC := FTafGetVal( cPathDet + "/prod" + "/vDesc" , "N", .F., @aIncons, .F., Nil, Nil, .F. )
			nC30_VLOUTR := FTafGetVal( cPathDet + "/prod" + "/vOutro", "N", .F., @aIncons, .F., Nil, Nil, .F. )

			oModel:LoadValue( "MODEL_C30", "C30_QUANT ", nC30_QUANT  )
			oModel:LoadValue( "MODEL_C30", "C30_VLRITE", nC30_VLRITE )
			oModel:LoadValue( "MODEL_C30", "C30_TOTAL ", nC30_TOTAL  )
			oModel:LoadValue( "MODEL_C30", "C30_VLDESC", nC30_VLDESC )
			oModel:LoadValue( "MODEL_C30", "C30_VLOUTR", nC30_VLOUTR )

			//Calcula o Valor das Mercadorias
			nC20_VLMERC += IIf( nC30_QUANT == 0, nC30_VLRITE, (nC30_QUANT * nC30_VLRITE) )
			nC20_VLDESC += nC30_VLDESC


			//tag DI
			nDI := 1
			cPathDI := cPathDet + "/prod/DI[" + StrZero(nDI,1) + "]"

			While oDados:XPathHasNode( cPathDI )

				//tag adi
				nAdi := 1
				cPathAdi := cPathDI + "/adi[" + StrZero(nAdi,1) + "]"

				While oDados:XPathHasNode( cPathAdi )

					//Inclui linha na grid do modelo
					If nAdi > 1
						// Informa que a linha está válida para que seja incluída uma nova linha
						oModel:GetModel( "MODEL_C23" ):LVALID := .T.

						// Inclui uma linha a cada volta do laço
						oModel:GetModel( "MODEL_C23" ):AddLine()
					EndIf

					//Campos tag DI
					oModel:LoadValue( "MODEL_C23", "C23_NUMDOC", FTafGetVal( cPathDI + "/nDI"        , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_DTREG ", FTafGetVal( cPathDI + "/dDI"        , "D", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_LOCADS", FTafGetVal( cPathDI + "/xLocDesemb" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_UFDESB", FTafGetVal( cPathDI + "/UFDesemb"   , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_DTDESB", FTafGetVal( cPathDI + "/dDesemb"    , "D", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_CODEXP", FTafGetVal( cPathDI + "/cExportador", "C", .F., @aIncons, .F. ) )

					//Campos tag adi
					oModel:LoadValue( "MODEL_C23", "C23_ADICAO", FTafGetVal( cPathAdi + "/nAdicao"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_SEQADI", FTafGetVal( cPathAdi + "/nSeqAdic"    , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_FABRIC", FTafGetVal( cPathAdi + "/cFabricante" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_VLDESC", FTafGetVal( cPathAdi + "/vDescDI"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_NUMPED", FTafGetVal( cPathAdi + "/xPed"        , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C23", "C23_ITPED ", FTafGetVal( cPathAdi + "/nItemPed"    , "C", .F., @aIncons, .F. ) )

					nAdi++
					cPathAdi := cPathDI + "/adi[" + StrZero(nAdi,1) + "]"

				EndDo //Fim tag adi

				nDI++
				cPathDI := cPathDet + "/prod/DI[" + StrZero(nDI,1) + "]"

			EndDo //Fim tag DI

			//Bloco J - Detalhamento Espec¡fico de Ve¡culos novos (/NFe/infNFe/det[n]/prod/veicProd)
			cPathVeicProd := cPathDet + "/veicProd"
			If oDados:XPathHasNode( cPathVeicProd )

				oModel:LoadValue( "MODEL_C34", "C34_INDVEI", FTafGetVal( cPathVeicProd + "/tpOp"         , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CHASSI", FTafGetVal( cPathVeicProd + "/chassi"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CODCOR", FTafGetVal( cPathVeicProd + "/cCor"         , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_DSCCOR", FTafGetVal( cPathVeicProd + "/xCor"         , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_POTENC", FTafGetVal( cPathVeicProd + "/pot"          , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CILIND", FTafGetVal( cPathVeicProd + "/cilin"        , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_PESOLI", FTafGetVal( cPathVeicProd + "/pesoL"        , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_PESOBR", FTafGetVal( cPathVeicProd + "/pesoB"        , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_SERIAL", FTafGetVal( cPathVeicProd + "/nSerie"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_TPCOMB", FTafGetVal( cPathVeicProd + "/tpComb"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_NMOTOR", FTafGetVal( cPathVeicProd + "/nMotor"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_TRACAO", FTafGetVal( cPathVeicProd + "/CMT"          , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_DISTEI", FTafGetVal( cPathVeicProd + "/dist"         , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_ANOMOD", FTafGetVal( cPathVeicProd + "/anoMod"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_ANOFAB", FTafGetVal( cPathVeicProd + "/anoFab"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_TPPINT", FTafGetVal( cPathVeicProd + "/tpPint"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_TPVEIC", FTafGetVal( cPathVeicProd + "/tpVeic"       , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_ESPVEI", FTafGetVal( cPathVeicProd + "/espVeic"      , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CONVIN", FTafGetVal( cPathVeicProd + "/VIN"          , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CONVEI", FTafGetVal( cPathVeicProd + "/condVeic"     , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CODMOD", FTafGetVal( cPathVeicProd + "/cMod"         , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_CORDE ", FTafGetVal( cPathVeicProd + "/cCorDENATRAN" , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_LOTAC ", FTafGetVal( cPathVeicProd + "/lota"         , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C34", "C34_RESTR ", FTafGetVal( cPathVeicProd + "/tpRest"       , "C", .F., @aIncons, .F. ) )

			EndIf

			//Bloco K - Detalhamento Espec¡fico de Medicamento e de mat‚rias-primas farmacˆuticas (/NFe/infNFe/det[n]/prod/med)
			cPathMed := cPathDet + "/med"
			If oDados:XPathHasNode( cPathMed )

				oModel:LoadValue( "MODEL_C31", "C31_LOTE  ", FTafGetVal( cPathMed + "/nLote"        , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C31", "C31_QUANT ", FTafGetVal( cPathMed + "/qLote"        , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C31", "C31_DTFAB ", FTafGetVal( cPathMed + "/dFab"         , "D", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C31", "C31_DTVAL ", FTafGetVal( cPathMed + "/dVal"         , "D", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C31", "C31_VLTBMX", FTafGetVal( cPathMed + "/vPMC"         , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

			EndIf

			//Bloco L - Detalhamento Espec¡fico de Armamentos (/NFe/infNFe/det[n]/prod/arma)
			cPathArma := cPathDet + "/arma"
			If oDados:XPathHasNode( cPathArma )

				oModel:LoadValue( "MODEL_C33", "C33_INDARM", FTafGetVal( cPathArma + "/tpArma" , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C33", "C33_NUMARM", FTafGetVal( cPathArma + "/nSerie" , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C33", "C33_NRCANO", FTafGetVal( cPathArma + "/nCano"  , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C33", "C33_DESCRI", FTafGetVal( cPathArma + "/descr"  , "C", .F., @aIncons, .F. ) )

			EndIf

			//Bloco L1 - Detalhamento Espec¡fico de Combust¡veis (/NFe/infNFe/det[n]/prod/comb)
			cPathComb := cPathDet + "/comb"
			If oDados:XPathHasNode( cPathComb )

				oModel:LoadValue( "MODEL_C36", "C36_CODIF ", FTafGetVal( cPathComb + "/CODIF"        , "C", .F., @aIncons, .F. ) )
				oModel:LoadValue( "MODEL_C36", "C36_QTAMB ", FTafGetVal( cPathComb + "/qTemp"        , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C36", "C36_UFCONS", FTafGetVal( cPathComb + "/UFCons"       , "C", .F., @aIncons, .F. ) )

				cPathCIDE := cPathComb + "/CIDE"
				If oDados:XPathHasNode( cPathCIDE )

					oModel:LoadValue( "MODEL_C36", "C36_BCCIDE", FTafGetVal( cPathArma + "/qBCprod"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
					oModel:LoadValue( "MODEL_C36", "C36_VALIQ ", FTafGetVal( cPathArma + "/vAliqProd" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
					oModel:LoadValue( "MODEL_C36", "C36_VCIDE ", FTafGetVal( cPathArma + "/vCIDE"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				EndIf

			EndIf

			//Bloco M - Tributos incidentes no Produto ou Servi‡o (/NFe/infNFe/det[n]/imposto)
			nCountTrib := 0

			//Bloco N - ICMS Normal e ST (/NFe/infNFe/det[n]/imposto/ICMS)
			//tag ICMS00
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS00"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBC"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMS" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMS" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )


				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS10
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS10"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS20
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS20"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBC", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBC"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMS" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMS" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS30
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS30"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf


				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS40
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS40"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MTICMS", FTafGetVal( cPathICMS + "/motDesICMS", "C", .F., @aIncons, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS41
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS41"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MTICMS", FTafGetVal( cPathICMS + "/motDesICMS", "C", .F., @aIncons, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS50
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS50"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MTICMS", FTafGetVal( cPathICMS + "/motDesICMS", "C", .F., @aIncons, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS51
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS51"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBC" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBC"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS60
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS60"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCSTRet"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSSTRet"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS70
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS70"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMS90
			cPathICMS := cPathDet + "/imposto/ICMS/ICMS90"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSPart
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSPart"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "02", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBC" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSST
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSST"
			If oDados:XPathHasNode( cPathICMS )

				//Campos
				oModel:LoadValue( "MODEL_C30", "C30_BSTORI", FTafGetVal( cPathICMS + "/vBCSTRet"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C30", "C30_VSTREP", FTafGetVal( cPathICMS + "/vICMSSTRet" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C30", "C30_BCRETQ", FTafGetVal( cPathICMS + "/vBCSTDest"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C30", "C30_VLRET ", FTafGetVal( cPathICMS + "/vICMSSTDest", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

			EndIf

			//tag ICMSSN101
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN101"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pCredSN"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vCredICMSSN" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSSN102
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN102"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBCST" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSSN201
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN201"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBCST" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSSN202
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN202"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBCST" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSSN500
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN500"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Campos
				oModel:LoadValue( "MODEL_C30", "C30_BSTORI", FTafGetVal( cPathICMS + "/vBCSTRet"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C30", "C30_VSTREP", FTafGetVal( cPathICMS + "/vICMSSTRet" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag ICMSSN900
			cPathICMS := cPathDet + "/imposto/ICMS/ICMSSN900"
			If oDados:XPathHasNode( cPathICMS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do Tributo
				cCodTri := TAFGetId( "04", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo da origem do produto
				cCodOrig := FTafGetVal( cPathICMS + "/orig" , "C", .F., @aIncons, .F. )
				cCodOrig := TAFGetId( cCodOrig, "C03", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_ORIGEM", cCodOrig )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathICMS + "/CSOSN" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C14", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Pesquisa o codigo do ModBC
				cCodModBC := FTafGetVal( cPathICMS + "/modBCST" , "C", .F., @aIncons, .F. )
				cCodModBC := TAFGetId( cCodModBC, "C04", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_MODBC ", cCodModBC )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_MVA   ", FTafGetVal( cPathICMS + "/pMVAST"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_REDBC ", FTafGetVal( cPathICMS + "/pRedBCST" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathICMS + "/pICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathICMS + "/vICMSST"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				oModel:LoadValue( "MODEL_C30", "C30_BSTORI", FTafGetVal( cPathICMS + "/vBCST"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco O - Imposto sobre Produtos Industrializados (/NFe/infNFe/det[n]/imposto/IPI)
			cPathIPI := cPathDet + "/imposto/IPI"
			If oDados:XPathHasNode( cPathIPI )

				//Codigo da Classe de Enquadramento do IPI
				cCodClEnq := FTafGetVal( cPathIPI + "/clEnq" , "C", .F., @aIncons, .F. )
				cCodClEnq := IIf( !Empty(cCodClEnq), TAFGetId( cCodClEnq, "C3T", aIncons ), cCodClEnq )
				oModel:LoadValue( "MODEL_C30", "C30_CLENQ ", cCodClEnq )

				//Codigo do Selo de Controle
				cCodSelo := FTafGetVal( cPathIPI + "/cSelo" , "C", .F., @aIncons, .F. )
				cCodSelo := IIf( !Empty(cCodSelo), TAFGetId( cCodSelo, "C3U", aIncons ), cCodSelo )
				oModel:LoadValue( "MODEL_C30", "C30_SELO  ", cCodSelo )

				oModel:LoadValue( "MODEL_C30", "C30_QTDSEL", FTafGetVal( cPathIPI + "/qSelo"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

			EndIf

			//tag IPITrib
			cPathIPI := cPathDet + "/imposto/IPI/IPITrib"
			If oDados:XPathHasNode( cPathIPI )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "05", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathIPI + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C15", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				//Campos
				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathIPI + "/qUnid"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VLRPAU", FTafGetVal( cPathIPI + "/vUnid"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathIPI + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathIPI + "/pIPI"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathIPI + "/vIPI"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag IPINT
			cPathIPI := cPathDet + "/imposto/IPI/IPINT"
			If oDados:XPathHasNode( cPathIPI )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "05", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathIPI + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C15", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco P - Imposto de Importa‡Æo (/NFe/infNFe/det[n]/imposto/II)
			cPathII := cPathDet + "/imposto/II"
			If oDados:XPathHasNode( cPathII )

				//--X--

			EndIf

			//Bloco Q - PIS (/NFe/infNFe/det[n]/imposto/PIS)
			//tag PISAliq
			cPathPIS := cPathDet + "/imposto/PISAliq"
			If oDados:XPathHasNode( cPathPIS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "06", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathPIS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathPIS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathPIS + "/pPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathPIS + "/vPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag PISQtde
			cPathPIS := cPathDet + "/imposto/PISQtde"
			If oDados:XPathHasNode( cPathPIS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "06", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathPIS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathPIS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathPIS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathPIS + "/vPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag PISNT
			cPathPIS := cPathDet + "/imposto/PISNT"
			If oDados:XPathHasNode( cPathPIS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "06", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathPIS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag PISOutr
			cPathPIS := cPathDet + "/imposto/PISOutr"
			If oDados:XPathHasNode( cPathPIS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "06", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathPIS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathPIS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathPIS + "/pPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathPIS + "/vPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathPIS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathPIS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco R - PIS ST (/NFe/infNFe/det[n]/imposto/PISST)
			cPathPIS := cPathDet + "/imposto/PISST"
			If oDados:XPathHasNode( cPathPIS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "08", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathPIS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathPIS + "/pPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathPIS + "/vPIS"     , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathPIS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathPIS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco S - COFINS (/NFe/infNFe/det[n]/imposto/COFINS)
			//tag COFINSAliq
			cPathCOFINS := cPathDet + "/imposto/COFINS/COFINSAliq"
			If oDados:XPathHasNode( cPathCOFINS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "07", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathCOFINS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathCOFINS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathCOFINS + "/pCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathCOFINS + "/vCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag COFINSQtde
			cPathCOFINS := cPathDet + "/imposto/COFINS/COFINSQtde"
			If oDados:XPathHasNode( cPathCOFINS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "07", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathCOFINS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathCOFINS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathCOFINS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathCOFINS + "/vCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag COFINSNT
			cPathCOFINS := cPathDet + "/imposto/COFINS/COFINSNT"
			If oDados:XPathHasNode( cPathCOFINS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "07", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathCOFINS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//tag COFINSOutr
			cPathCOFINS := cPathDet + "/imposto/COFINS/COFINSOutr"
			If oDados:XPathHasNode( cPathCOFINS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "07", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				//Pesquisa o codigo do CST
				cCodCST := FTafGetVal( cPathCOFINS + "/CST" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C17", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST   ", cCodCST )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathCOFINS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathCOFINS + "/pCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathCOFINS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathCOFINS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathCOFINS + "/vCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco T - COFINS ST (/NFe/infNFe/det[n]/imposto/COFINSST)
			cPathCOFINS := cPathDet + "/imposto/COFINSST"
			If oDados:XPathHasNode( cPathCOFINS )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "09", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathCOFINS + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathCOFINS + "/pCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_BASEQT", FTafGetVal( cPathCOFINS + "/qBCProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQRE", FTafGetVal( cPathCOFINS + "/vAliqProd", "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathCOFINS + "/vCOFINS"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco U - ISSQN (/NFe/infNFe/det[n]/imposto/ISSQN)
			cPathISSQN := cPathDet + "/imposto/ISSQN"
			If oDados:XPathHasNode( cPathISSQN )

				nCountTrib++

				//Inclui linha na grid do modelo
				If nCountTrib > 1
					// Informa que a linha está válida para que seja incluída uma nova linha
					oModel:GetModel( "MODEL_C35" ):LVALID := .T.

					// Inclui uma linha a cada volta do laço
					oModel:GetModel( "MODEL_C35" ):AddLine()
				EndIf

				//Codigo do tributo
				cCodTri := TAFGetId( "01", "C3S", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CODTRI", cCodTri )

				oModel:LoadValue( "MODEL_C35", "C35_BASE  ", FTafGetVal( cPathISSQN + "/vBC"      , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_ALIQ  ", FTafGetVal( cPathISSQN + "/vAliq"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C35", "C35_VALOR ", FTafGetVal( cPathISSQN + "/vISSQN"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

				//Pesquisa o codigo do Servico
				cCodServ := FTafGetVal( cPathISSQN + "/cListServ" , "C", .F., @aIncons, .F. )
				cCodServ := TAFGetId( cCodServ, "C0B", aIncons )
				oModel:LoadValue( "MODEL_C30", "C30_CODSER", cCodServ )

				//Pesquisa do Codigo de Tributacao
				cCodCST := FTafGetVal( cPathISSQN + "/cSitTrib" , "C", .F., @aIncons, .F. )
				cCodCST := TAFGetId( cCodCST, "C0H", aIncons )
				oModel:LoadValue( "MODEL_C35", "C35_CST", cCodCST )

				TAFTotTrib( oModel:GetModel("MODEL_C30"), oModel:GetModel("MODEL_C35"), aTotTrib )

			EndIf

			//Bloco V - Informa‡äes adicionais (/NFe/infNFe/det[n]/infAdProd)
			cPathInfAd := cPathDet + "/infAdProd"
			If oDados:XPathHasNode( cPathInfAd )

				//--x--

			EndIf

			nDet++
			cPathDet := cPathIde + "/NFe/infNFe/det[" + StrZero(nDet,1) + "]"

		EndDo //Fim Bloco H

		//Bloco W - Valores Totais da NF-e (/NFe/infNFe/total)
		cPathTotal := "/NFe/infNFe/total"
		If oDados:XPathHasNode( cPathTotal )

			oModel:LoadValue( "MODEL_C20", "C20_VLMERC", nC20_VLMERC )
			oModel:LoadValue( "MODEL_C20", "C20_VLDESC", nC20_VLDESC )


			If oDados:XPathHasNode( cPathTotal + "/ICMSTot" )
				oModel:LoadValue( "MODEL_C20", "C20_VLDOC ", FTafGetVal( cPathTotal + "/ICMSTot" + "/vProd"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C20", "C20_VLRFRT", FTafGetVal( cPathTotal + "/ICMSTot" + "/vFrete" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C20", "C20_VLRSEG", FTafGetVal( cPathTotal + "/ICMSTot" + "/vSeg"   , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				//oModel:LoadValue( "MODEL_C20", "C20_VLDESC", FTafGetVal( cPathTotal + "/ICMSTot" + "/vDesc"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C20", "C20_II    ", FTafGetVal( cPathTotal + "/ICMSTot" + "/vII"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C20", "C20_VLOUDE", FTafGetVal( cPathTotal + "/ICMSTot" + "/vOutro" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
				oModel:LoadValue( "MODEL_C20", "C20_VLDOC ", FTafGetVal( cPathTotal + "/ICMSTot" + "/vNF"    , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
			EndIf

			If oDados:XPathHasNode( cPathTotal + "/ISSQNtot" )
				//--X--
			EndIf

			If oDados:XPathHasNode( cPathTotal + "/retTrib" )
				//--X--
			EndIf

			TAFGrvTrib( oModel:GetModel("MODEL_C2F"), aTotTrib )

		EndIf

		//Bloco X - Informa‡äes do Transporte da NF-e (/NFe/infNFe/transp)
		cPathTransp := "/NFe/infNFe/transp"
		If oDados:XPathHasNode( cPathTransp )

			//Pesquisa o codigo da modalidade do frete
			cIndFrt := FTafGetVal( cPathTransp + "/modFrete" , "C", .F., @aIncons, .F. )
			cIndFrt := TAFGetId( cIndFrt, "C0X", aIncons )
			oModel:LoadValue( "MODEL_C20", "C20_INDFRT", cIndFrt )

		EndIf

		//tag vol
		cPathTransp := "/NFe/infNFe/transp/vol"
		If oDados:XPathHasNode( cPathTransp )

			oModel:LoadValue( "MODEL_C20", "C20_QTDVOL", FTafGetVal( cPathTransp + "/qVol"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_ESPVOL", FTafGetVal( cPathTransp + "/esp"   , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_MARCA ", FTafGetVal( cPathTransp + "/marca" , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_NUMVOL", FTafGetVal( cPathTransp + "/nVol"  , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_PESLIQ", FTafGetVal( cPathTransp + "/pesoL" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_PESBRT", FTafGetVal( cPathTransp + "/pesoB" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

		EndIf

		//tag lacres
		cPathTransp := "/NFe/infNFe/transp/vol/lacres"
		If oDados:XPathHasNode( cPathTransp )

			oModel:LoadValue( "MODEL_C20", "C20_LACRES", FTafGetVal( cPathTransp + "/nLacre"  , "C", .F., @aIncons, .F. ) )

		EndIf

		//Bloco Y - Dados da Cobran‡a (/NFe/infNFe/cobr)
		//taf fat
		cPathCobr := "/NFe/infNFe/cobr/fat"
		If oDados:XPathHasNode( cPathCobr )

			oModel:LoadValue( "MODEL_C29", "C29_NUMTIT", FTafGetVal( cPathCobr + "/nFat"  , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C29", "C29_VLRTOT", FTafGetVal( cPathCobr + "/vOrig" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
			oModel:LoadValue( "MODEL_C29", "C29_VLRDES", FTafGetVal( cPathCobr + "/vDesc" , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )
			oModel:LoadValue( "MODEL_C29", "C29_VLRLIQ", FTafGetVal( cPathCobr + "/vLiq"  , "N", .F., @aIncons, .F., Nil, Nil, .F. ) )

		EndIf

		//taf dup
		/*
		nDup := 1
		cPathDup := "/NFe/infNFe/cobr/dup[" + StrZero(nDup,1) + "]"
		While oDados:XPathHasNode( cPathDup )

			//Inclui linha na grid do modelo
			If nDup > 1
				// Informa que a linha está válida para que seja incluída uma nova linha
				oModel:GetModel( "MODEL_C29" ):LVALID := .T.

				// Inclui uma linha a cada volta do laço
				oModel:GetModel( "MODEL_C29" ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_C29", "C29_NUMTIT", FTafGetVal( cPathCobr + "/nFat"  , "C", .F., @aIncons, .F. ) )
			//oModel:LoadValue( "MODEL_C29", "C29_VENCTO", FTafGetVal( cPathCobr + "/dVenc" , "D", .F., @aIncons, .F. ) )
			//oModel:LoadValue( "MODEL_C29", "C29_VALOR ", FTafGetVal( cPathCobr + "/vDup"  , "N", .F., @aIncons, .F. ) )

			nDup++
			cPathDup := "/NFe/infNFe/cobr/dup[" + StrZero(nDup,1) + "]"

		EndDo
		*/

		//Bloco Z - Grupo de Informa‡äes Adicionais (/NFe/infNFe/infAdic)
		//taf obsCont
		nObsCont := 1
		cPathObs := "/NFe/infNFe/infAdic/obsCont[" + StrZero(nObsCont,1) + "]"
		While oDados:XPathHasNode( cPathObs )

			//Inclui linha na grid do modelo
			If nObsCont > 1
				// Informa que a linha está válida para que seja incluída uma nova linha
				oModel:GetModel( "MODEL_C21" ):LVALID := .T.

				// Inclui uma linha a cada volta do laço
				oModel:GetModel( "MODEL_C21" ):AddLine()
			EndIf

			//Pesquisa o codigo da informacao
			cCodInf := FTafGetVal( cPathObs + "/xCampo" , "C", .F., @aIncons, .F. )
			cCodInf := TAFGetId( cIndFrt, "C3Q", aIncons )
			oModel:LoadValue( "MODEL_C21", "C21_CODINF", cCodInf )

			nObsCont++
			cPathObs := "/NFe/infNFe/infAdic/obsCont[" + StrZero(nObsCont,1) + "]"

		EndDo

		//taf procRef
		nProcRef := 1
		cPathPrc := "/NFe/infNFe/infAdic/procRef[" + StrZero(nProcRef,1) + "]"
		While oDados:XPathHasNode( cPathPrc )

			//Inclui linha na grid do modelo
			If nProcRef > 1
				// Informa que a linha está válida para que seja incluída uma nova linha
				oModel:GetModel( "MODEL_C21" ):LVALID := .T.

				// Inclui uma linha a cada volta do laço
				oModel:GetModel( "MODEL_C21" ):AddLine()
			EndIf

			//Pesquisa o codigo da informacao
			cCodProc := FTafGetVal( cPathPrc + "/nProc" , "C", .F., @aIncons, .F. )
			cCodProc := TAFGetId( cCodProc, "C1G", aIncons )
			oModel:LoadValue( "MODEL_C6W", "C6W_NUMERO", cCodProc )

			nProcRef++
			cPathPrc := "/NFe/infNFe/infAdic/obsCont[" + StrZero(nProcRef,1) + "]"

		EndDo

		//Bloco ZA - Informa‡äes de Com‚rcio Exterior (/NFe/infNFe/exporta)

		//Bloco ZB - Informa‡äes de Compras (/NFe/infNFe/compra)
		cPathCompra := "/NFe/infNFe/compra"
		If oDados:XPathHasNode( cPathCompra )

			oModel:LoadValue( "MODEL_C20", "C20_NOTEMP", FTafGetVal( cPathCompra + "/xNEmp"  , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_PEDIDO", FTafGetVal( cPathCompra + "/xPed"   , "C", .F., @aIncons, .F. ) )
			oModel:LoadValue( "MODEL_C20", "C20_CONTRA", FTafGetVal( cPathCompra + "/xCont"  , "C", .F., @aIncons, .F. ) )

		EndIf

		//Bloco ZZ - Informa‡äes da Assinatura Digital (/NFe/infNFe/compra/Signature)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetiva a operacao desejada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		// Anderson Costa - 02/10/2014
		// Grava a NF mesmo com inconsistências pois
		// estas serão avaliadas após a validação (Job 3)

		//lRet := ( Len(aIncons) == 0 )

		//If lRet

			lRet := FWFormCommit( oModel )

			If !lRet

				TAFModelIncons( aIncons, oModel:GetModel():GetErrormessage() )

			EndIf
		//EndIf

		oModel:DeActivate()

	EndIf //Fim Bloco B

Else

	Aadd( aIncons, "Não foi informada a Filial de referência do ERP para importação das informações no TAF." )

EndIf

lVldModel := .F.

RestArea(aArea)

Return {lRet, aIncons}

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFGetId
Processa o XML das NF-e's e grava nas tabelas to TAF

@return array, aRet[1]: (T/F) Indica se integrou os dados.
               aRet[2]: (array) Inconsistencias encontradas.

@author Daniel Magalhaes
@since 22/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFGetId( cCodeValue, cAliasID, aIncons, nIndOrd, cCpoCod )
Local cCodeId := ""

Default cCodeValue := ""
Default cAliasID   := ""
Default nIndOrd    := 1
Default cCpoCod    := cAliasID + "_ID"

If !Empty(cCodeValue) .And. !Empty(cAliasID)

	cCodeId := Posicione( cAliasID, nIndOrd, xFilial(cAliasID) + cCodeValue, cCpoCod )

	If Empty(cCodeId)

		Aadd( aIncons, "Nao foi possivel identificar o ID para o codigo informado: " + cCodeValue + ". Alias: " + cAliasID + "." )
	EndIf
Else

	Aadd( aIncons, "O codigo ou o alias nao foram informados. Codigo: " + cCodeValue + ". Alias: " + cAliasID + "."  )
EndIf

Return cCodeId

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSetFldr

@return character, Pasta de trabalho para leitura dos arquivos XML

@author Daniel Oliveira de Magalhaes
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFSetFldr(cPath)

Local lReturn := .T.

cPath := ""
cPath := cGetFile( "", , 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY )

If Empty(cPath)
	lReturn := MsgNoYes(	"Você não selecionou nenhuma pasta para importação dos arquivos XML." + CRLF +;
					"Será utilizada a pasta configurada no parâmetro MV_DIMPTAF." + CRLF +;
					"Deseja continuar?" )
EndIf

Return lReturn


//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFReadFl
Le o arquivo e retorna seu conteudo, tratando o tamanho maximo da string do Protheus

@return array, [1] Tamanho do arquivo - [2] Status da leitura .T./.F. - [3] Conteudo do arquivo

@author Daniel Magalhaes
@since 19/12/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFReadFl( cFilePath )
Local nFileLen := 0
Local lStRead  := .T.
Local cContent := ""
Local cBuffer  := ""
Local nHdlFile := -1 //Handle para leitura do arquivo
Local nPosFile := 0
Local nByteLeft:= 0
Local nBlock   := 512
Local nMemoMega := Val( GetSrvProfString( "TOPMEMOMEGA", "" ))
Local nMaxStr   := If(nMemoMega > 0, nMemoMega * 1048575 , 1048575)  //tamanho maximo string do protheus, conforme TOPMEMOMEGA

If ( nHdlFile := FOpen( cFilePath, FO_READ+FO_DENYWRITE ) ) >= 0

	// Posiciona no fim do arquivo, retornando o tamanho do mesmo
	nFileLen := FSeek(nHdlFile, 0, FS_END)

	//Verifica o tamanho do arquivo
	If nFileLen > nMaxStr

		lStRead := .F.
	Else

		// Posiciona no inicio do arquivo
		nPosFile  := FSeek(nHdlFile, 0)
		nByteLeft := nFileLen

		//Percorre o arquivo ate o final
		While nByteLeft > 0

			nPosFile := FRead( nHdlFile, @cBuffer, nBlock )
			cContent += cBuffer

			nByteLeft -= nBlock
		EndDo
	EndIf

	// Fecha arquivo
	FClose(nHdlFile)
Else

	lStRead := .F.
EndIf

cContent := tafXMLDecode(cContent)
	
Return { nFileLen, lStRead, cContent }

//----------------------------------------------------------------------------
/*/{Protheus.doc} tafXMLDecode
Função criada para realizar o decode UTF8 de um XML, muitas vezes os xmls
não estão na codificação correta fazendo que a rotina DecodeUTF8 retorne Nil,
para evitar este tipo de situação esta rotina tenta identificar se o xml 
está de fato com Encode UTF8.

Obs. se o XML tiver indicando o encode no inicio do xml com a tag
<?xml version="1.0" encoding="UTF-8"?> é obrigatório que o arquivo de fato
esteja "encodado".

@param cXml - xml com codificação
@return cXmlEncoding - xml sem codificação

@author Evandro dos Santos O. Teixeira
@since 28/03/2020
@version 1.0
/*/
//---------------------------------------------------------------------------
Function tafXMLDecode(cXml)

	Local cStrEncoding 	:= ""
	Local cXmlEncoding 	:= ""
	
	Default cXml 		:= ""

	If "<?" $ SubStr(LTrim(cXml), 1, 15)
		cStrEncoding 	:= Upper(SubStr(cXml, 1, At("?>", cXml)))
		cXml 			:= RemoveUTF8(cXml) //Remove primeira tag do XML, neste caso será <?xml version="1.0" encoding="xxxxx"?>

		If "UTF-8" $ cStrEncoding .OR. "8859-1" $ cStrEncoding
			cXmlEncoding := TAFDecUTF8(cXml)
		EndIf 
	EndIf 

	If Empty(cXmlEncoding)
		cXmlEncoding := EncodeUTF8(cXml)

		//Se retornar vazio o XML já está em UTF8
		If Empty(cXmlEncoding)
			cXmlEncoding := TAFDecUTF8(cXml)

			//Se retornar vazio o XML está em um formato não esperado.
			If Empty(cXmlEncoding)
				cXmlEncoding := cXml

				TafConOut("Formato de XML não esperado")
				TafConOut(cXml)
			EndIf
		Else
			cXmlEncoding := TAFDecUTF8(cXml)
		EndIf
	EndIf 

Return cXmlEncoding

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFModelIncons
Adiciona no array de inconsistencias os erros do Model

@noreturn

@author Daniel Magalhaes
@since 06/04/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFModelIncons( aIncons, aModelError )
Default aIncons     := {}
Default aModelError := Array(5)

Aadd( aIncons, "Id do formulario de origem:" + ' [' + AllToChar( aModelError[1]  ) + ']' )
Aadd( aIncons, "Id do campo de origem:     " + ' [' + AllToChar( aModelError[2]  ) + ']' )
Aadd( aIncons, "Id do formulario de erro:  " + ' [' + AllToChar( aModelError[3]  ) + ']' )
Aadd( aIncons, "Id do campo de erro:       " + ' [' + AllToChar( aModelError[4]  ) + ']' )
Aadd( aIncons, "Id do erro:                " + ' [' + AllToChar( aModelError[5]  ) + ']' )

If Len(aModelError) >= 6

	Aadd( aIncons, "Mensagem do erro:          " + ' [' + AllToChar( aModelError[6]  ) + ']' )

EndIf

If Len(aModelError) >= 7

	Aadd( aIncons, "Mensagem da solucao:       " + ' [' + AllToChar( aModelError[7]  ) + ']' )

EndIf

If Len(aModelError) >= 8

	Aadd( aIncons, "Valor atribuido:           " + ' [' + AllToChar( aModelError[8]  ) + ']' )

EndIf

If Len(aModelError) >= 9

	Aadd( aIncons, "Valor anterior:            " + ' [' + AllToChar( aModelError[9]  ) + ']' )

EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFTotTrib
Adiciona no valores no array totalizador de tributos

@noreturn

@author Daniel Magalhaes
@since 06/04/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFTotTrib( oModelC30, oModelC35, aTotTrib )

//Auxiliares
Local nAtTot   := 0
Local aAux     := {}

//Chave do Array
Local cCodTri  := oModelC35:GetValue( "C35_CODTRI" )
Local cCodCST  := oModelC35:GetValue( "C35_CST   " )
Local cCodCFOP := oModelC30:GetValue( "C30_CFOP  " )
Local cCodSer  := oModelC30:GetValue( "C30_CODSER" )
Local nAliq    := oModelC35:GetValue( "C35_ALIQ  " )

//Valores
Local nC35_BASE   := oModelC35:GetValue( "C35_BASE  " )
Local nC35_VALOR  := oModelC35:GetValue( "C35_VALOR " )
Local nC35_BASEQT := oModelC35:GetValue( "C35_BASEQT" )
Local nC35_VLRPAU := oModelC35:GetValue( "C35_VLRPAU" )
Local nC35_BASENT := oModelC35:GetValue( "C35_BASENT" )
Local nC35_VLNT   := oModelC35:GetValue( "C35_VLNT  " )
Local nC35_VLISEN := oModelC35:GetValue( "C35_VLISEN" )
Local nC35_VLOUTR := oModelC35:GetValue( "C35_VLOUTR" )

//Posicao dos campos Chave
Local nPosCodTri  := 1 //C2F_CODTRI
Local nPosCodCST  := 2 //C2F_CST
Local nPosCodCFOP := 3 //C2F_CFOP
Local nPosCodSer  := 4 //C2F_CODSER
Local nPosAliq    := 5 //C2F_ALIQ

//Posicao dos campos de Valores
Local nPosBASE   := 06 //C2F_BASE
Local nPosVALOR  := 07 //C2F_VALOR
Local nPosBASEQT := 08 //C2F_BASEQT
Local nPosVLRPAU := 09 //C2F_VLRPAU
Local nPosBASENT := 10 //C2F_BASENT
Local nPosVLNT   := 11 //C2F_VLNT
Local nPosVLISEN := 12 //C2F_VLISEN
Local nPosVLOUTR := 13 //C2F_VLOUTR

//Verificacao para nao gravar chave em branco
Local lSemChave := Empty(cCodTri ) .and.;
				   Empty(cCodCST ) .and.;
				   Empty(cCodCFOP) .and.;
				   Empty(cCodSer ) .and.;
				   Empty(nAliq   )

If !lSemChave

	nAtTot := aScan( aTotTrib, { |arr| arr[nPosCodTri ] == cCodTri ;
								 .and. arr[nPosCodCST ] == cCodCST ;
								 .and. arr[nPosCodCFOP] == cCodCFOP;
								 .and. arr[nPosCodSer ] == cCodSer ;
								 .and. arr[nPosAliq   ] == nAliq   } )

	If nAtTot == 0
		aAdd( aAux, cCodTri  ) //C2F_CODTRI
		aAdd( aAux, cCodCST  ) //C2F_CST
		aAdd( aAux, cCodCFOP ) //C2F_CFOP
		aAdd( aAux, cCodSer  ) //C2F_CODSER
		aAdd( aAux, nAliq    ) //C2F_ALIQ

		aAdd( aAux, nC35_BASE   ) //C2F_BASE
		aAdd( aAux, nC35_VALOR  ) //C2F_VALOR
		aAdd( aAux, nC35_BASEQT ) //C2F_BASEQT
		aAdd( aAux, nC35_VLRPAU ) //C2F_VLRPAU
		aAdd( aAux, nC35_BASENT ) //C2F_BASENT
		aAdd( aAux, nC35_VLNT   ) //C2F_VLNT
		aAdd( aAux, nC35_VLISEN ) //C2F_VLISEN
		aAdd( aAux, nC35_VLOUTR ) //C2F_VLOUTR

		//Adiciona o novo tributo ao array principal
		aAdd( aTotTrib, aAux )

	Else

		//Recupero a posicao do tributo
		aAux := aClone( aTotTrib[nAtTot] )

		aAux[nPosBASE  ] += nC35_BASE
		aAux[nPosVALOR ] += nC35_VALOR
		aAux[nPosBASEQT] += nC35_BASEQT
		aAux[nPosVLRPAU] += nC35_VLRPAU
		aAux[nPosBASENT] += nC35_BASENT
		aAux[nPosVLNT  ] += nC35_VLNT
		aAux[nPosVLISEN] += nC35_VLISEN
		aAux[nPosVLOUTR] += nC35_VLOUTR

		//Atualizo o array principal dos totalizadores
		aTotTrib[nAtTot] := aClone(aAux)

	EndIf

EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFGrvTrib
Grava o modelo C2F com base no array totalizador de tributos

@noreturn

@author Daniel Magalhaes
@since 06/04/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFGrvTrib( oModelC2F, aTotTrib )

//Auxiliares
Local nAtTot := 0

//Posicao dos campos Chave
Local nPosCodTri  := 1 //C2F_CODTRI
Local nPosCodCST  := 2 //C2F_CST
Local nPosCodCFOP := 3 //C2F_CFOP
Local nPosCodSer  := 4 //C2F_CODSER
Local nPosAliq    := 5 //C2F_ALIQ

//Posicao dos campos de Valores
Local nPosBASE   := 06 //C2F_BASE
Local nPosVALOR  := 07 //C2F_VALOR
Local nPosBASEQT := 08 //C2F_BASEQT
Local nPosVLRPAU := 09 //C2F_VLRPAU
Local nPosBASENT := 10 //C2F_BASENT
Local nPosVLNT   := 11 //C2F_VLNT
Local nPosVLISEN := 12 //C2F_VLISEN
Local nPosVLOUTR := 13 //C2F_VLOUTR

//Grava os totalizadores
For nAtTot := 1 To Len(aTotTrib)

	//Inclui linha na grid do modelo
	If nAtTot > 1
		// Informa que a linha está válida para que seja incluída uma nova linha
		oModelC2F:LVALID := .T.

		// Inclui uma linha a cada volta do laço
		oModelC2F:AddLine()
	EndIf

	oModelC2F:LoadValue( "C2F_CODTRI", aTotTrib[nAtTot][nPosCodTri ] )
	oModelC2F:LoadValue( "C2F_CST   ", aTotTrib[nAtTot][nPosCodCST ] )
	oModelC2F:LoadValue( "C2F_CFOP  ", aTotTrib[nAtTot][nPosCodCFOP] )
	oModelC2F:LoadValue( "C2F_CODSER", aTotTrib[nAtTot][nPosCodSer ] )
	oModelC2F:LoadValue( "C2F_ALIQ  ", aTotTrib[nAtTot][nPosAliq   ] )
	oModelC2F:LoadValue( "C2F_BASE  ", aTotTrib[nAtTot][nPosBASE   ] )
	oModelC2F:LoadValue( "C2F_VALOR ", aTotTrib[nAtTot][nPosVALOR  ] )
	oModelC2F:LoadValue( "C2F_BASEQT", aTotTrib[nAtTot][nPosBASEQT ] )
	oModelC2F:LoadValue( "C2F_VLRPAU", aTotTrib[nAtTot][nPosVLRPAU ] )
	oModelC2F:LoadValue( "C2F_BASENT", aTotTrib[nAtTot][nPosBASENT ] )
	oModelC2F:LoadValue( "C2F_VLNT  ", aTotTrib[nAtTot][nPosVLNT   ] )
	oModelC2F:LoadValue( "C2F_VLISEN", aTotTrib[nAtTot][nPosVLISEN ] )
	oModelC2F:LoadValue( "C2F_VLOUTR", aTotTrib[nAtTot][nPosVLOUTR ] )

Next nAtTot

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFIntDefine
Funcao para ler os Defines necessarios para o Webservice TAFWSIMPORT

@param cDefName, character, Nome da Define a retornar

@return xRet, conteudo do define

@author Daniel Magalhaes
@since 06/04/2014
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFIntDefine( cDefName )
Local xRet := ""


Do Case
	Case cDefName == "cST1TAB"

		xRet := cST1TAB

	Case cDefName == "cST2TAB"

		xRet := cST2TAB

	Case cDefName == "aTafSocial"

		xRet := TAFRtEso()

EndCase

Return xRet

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFProc7
Rotina de monitoramento do Status das NFes

@author Evandro dos Santos Oliveira
@since 23/04/2014
@version 1.0

@param lEnd	    	- Flag para Controle de Execução
@param lJog    		- Define se a rotina está sendo executada por Job
@param cIDThread 	- Numero da Thread que a função está sendo executada

@return Nil
/*/
//------------------------------------------------------------------------
Function TAFProc7(lEnd,lJob,cIDThread)

	Local cAliasNF 	:= GetNextAlias()
	Local cURL     	:= PadR(GetNewPar("MV_TAFSURL","http://"),250)
	Local cIdEnt	:= TAFRIdEnt()
	Local cAuxRes 	:= ""
	Local cStat 	:= ""
	Local cMsgRet 	:= ""
	Local cId   	:= ""
	Local cXml 	    := ""
	Local cRecibo   := ""
	Local nX  	    := 0
	Local nTotReg   := 0
	Local aIds		:= {}
	Local aChvs		:= {}
	Local nPosChv	:= 0
    Local aLoteNfe  := {}
    Local cStatCan  := "151,152,218,220,240,358,420,650,651,652,686,690"
	Local cCodDen   := "110,301,205,302,303,304,305,306"
	Local lRetSefz	:= .F.

	BeginSql alias cAliasNF

	SELECT  C20.C20_SERIE   	AS SERIE
	       ,C20.C20_CHVNF		AS CHVNF
		   ,C20.C20_NUMDOC		AS NOTA
		   ,CU0.R_E_C_N_O_		AS CU0REC
	FROM %table:CU0% CU0
	INNER JOIN %table:C20% C20 ON CU0.CU0_CHVNF = C20.C20_CHVNF
	AND C20.%NotDel%
	AND C20.C20_FILIAL = %xFilial:C20%
	WHERE CU0.CU0_CHVNF <> %exp:''%
	AND CU0.%NotDel%
	AND CU0.CU0_FILIAL = %xFilial:CU0%
	AND CU0.CU0_STATUS = %exp:'2'%

	EndSql

	Count To nTotReg
	If nTotReg > 0
		(cAliasNF)->(dbGoTop())
	   	IIf(!lJob,ProcRegua(nTotReg),xTAFMsgJob(AllTrim(Str(nTotReg)) + " documento(s) a consultar",,2))

		While (cAliasNF)->(!Eof())
			aAdd(aIds,Substr(AllTrim((cAliasNF)->SERIE),1,3)+StrZero(Val((cAliasNF)->NOTA),9))
			/*+----------------------------------------------------------+
			  | Guardo as Chaves das NFs para uso posterior, divido      |
			  | em 2 Arrays para facilitar a leitura do código		     |
			  +----------------------------------------------------------+*/
			aAdd(aChvs,{Substr(AllTrim((cAliasNF)->SERIE),1,3)+StrZero(Val((cAliasNF)->NOTA),9);
					  ,(cAliasNF)->CHVNF;
					  ,(cAliasNF)->CU0REC})
			(cAliasNF)->(dbSkip())
		EndDo

		If Len(aIds) > 0
			aIds := aSort(aIds)

			oWs:= WsNFeSBra():New()
			oWs:cUserToken 	:= "TOTVS"
			oWs:cID_ENT    	:= cIdEnt
			oWS:_URL       	:= AllTrim(cURL)+"/NFeSBRA.apw"
			oWS:CIDINICIAL  	:= aIds[1]
			oWS:CIDFINAL    	:= aTail(aIds)
			oWS:CMODELO     	:= "55"
			oWS:MonitorFaixa()

			For nX := 1 To Len(oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE)
				If !lJob
					IncProc("Verificando Status da Nota " + oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:CID)
				Else
					xTAFMsgJob("Verificando Status da Nota " + oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:CID,,2)
				EndIf

				aLoteNfe := aTail(oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)

				cStat   	:= aLoteNfe:cCodRetNfe
				cMsgRet 	:= aLoteNfe:cMsgRetNfe
			    cId     	:= oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:CID
			    cRecibo 	:= AllTrim(Str(aLoteNfe:nReciboSefaz))

		    	//Metodo Retorna Notas
		    	oWs2:= WsNFeSBra():New()
				oWs2:cUserToken    		:= "TOTVS"
				oWs2:cID_ENT       		:= cIdEnt
				oWs2:_URL       			:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWs2:oWSNFEID          	:= NFESBRA_NFES2():New()
				oWs2:oWSNFEID:oWSNotas 	:= NFESBRA_ARRAYOFNFESID2():New()
				aAdd(oWS2:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
				Atail(oWS2:oWSNFEID:oWSNotas:oWSNFESID2):cID := cId
				oWs2:nDIASPARAEXCLUSAO 	:= 0
				oWs2:_URL          	  	:= AllTrim(cURL)+"/NFeSBRA.apw"

				If oWs2:RETORNANOTAS()
				 	If Len(oWs2:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
				   		cXml := oWs2:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
			   		EndIf
			   	EndIf
			  	/*+------------------------------------------------------------------------+
				  | Busco as Informações da Nota no array auxiliar através utilizando o ID |
				  +------------------------------------------------------------------------+*/
			   	nPosChv := aScan(aChvs,{|x|x[1] == aIds[nX]})
			   	If nPosChv > 0
			   		dbSelectArea("CU0")
					dbGoTo(aChvs[nPosChv][3])
				 	If AllTrim(CU0->CU0_CHVNF) == AllTrim(aChvs[nPosChv][2])
				 	    dbSelectArea("CU0")
					 	Begin Transaction
					 	FTafExisLock("CU0",.F., .T.)
					 	If cStat == "100" .And. (AllTrim(CU0->CU0_CODERR) <> cStat)
							CU0->CU0_STATUS 	:= "4"
							CU0->CU0_RECIBO 	:= cRecibo
							lRetSefz			:= .T.
						ElseIf cStat $ ("101,"+cStatCan)
							CU0->CU0_STATUS 	:= "5"
							lRetSefz			:= .T.
						ElseIf !Empty(AllTrim(cStat))
							CU0->CU0_STATUS 	:= "3"
							CU0->CU0_RECIBO 	:= cRecibo
							lRetSefz			:= .T.
						Else
							xTAFMsgJob("Wait ..." + cMsgRet,,2)
							lRetSefz 			:= .F.
						EndIf

						If lRetSefz
						 	CU0->CU0_DTOCOR 	:= dDatabase
							CU0->CU0_PROTOC 	:= oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:CPROTOCOLO
							CU0->CU0_DCODER 	:= cMsgRet
							CU0->CU0_CODERR 	:= cStat
							CU0->CU0_XML 		:= xIdentXML(cXml)
							CU0->CU0_PROC   	:= "6"
						EndIf
						CU0->(MsUnlock())

						dbSelectArea("C20")
						dbSetOrder(4)
						If MsSeek(xFilial("C20")+aChvs[nPosChv][2])
							FTafExisLock("C20",.F.,.T.)
							If CU0->CU0_STATUS == "5"
							  	C20->C20_DTCANC := dDataBase
							   	C20->C20_CODSIT := '000003
								C20->C20_PROTOC := oWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[nX]:CPROTOCOLO
						 	ElseIf cStat == "100"
						 	 	C20->C20_CHVELE := SubStr(TAFIdNfe(cXml,"Id"),4)
							EndIf
						EndIf
						End Transaction
						xTAFMsgJob("Id " + aChvs[nPosChv][2] + " - " + cMsgRet,,2)
					 	oWs2:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3 := {}
					EndIf
			 	Else
					xTAFMsgJob("Erro na gravação da ocorrência do registro " + aIds[nX])
				EndIf
			Next nX
			lEnd := .T.
		EndIf
	Else
		If lJob
	   		xTAFMsgJob("Nao ha registros para consulta",,2)
		EndIf
	  	lEnd := .F.
	EndIf

Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} TAFLoadLay()
@author Alexandre Inacio Lemes
@since 09/04/2014
@version 1.0
*/
//-------------------------------------------------------------------
Function TAFLoadLay( cLayInteg, lRetLayout )

Local aOrdDel		:=	{}
Local cLayOut		:=	""
Local cLine		:=	""
Local nPosZ4		:=	0
Local lNewLayOut	:=	.F.
Local aModel		:=	{}
Local oModel		:=	Nil
Local lFaz			:=	.T.
Local lLayUnic	:=	.F.
Local cFile		:=	""
Local aReturn    := {}
Local nSemafLay := _NO_LOAD // 0 - não carregado, 1 - Carregando, 2 - Carregado
Local aAuxLay   := { }
Local aAuxDel   := { }
Local oError := ErrorBlock( { |e| TafLayError( e ) } )

Default cLayInteg  := ""
Default lRetLayout := .F.


aLayOut := {}
aLayDel := {}

// -------------------------------------------------
// As variaveis globais abaixo sao utilizadas para 2 propositos:
// Semaforo para schedule MultThread e Clonagem dos arrays aLayout e aLayDel pelas variaveis globais.
// Objetivo: Garantir que o Layout é carregado apenas por uma única Thread X
// e as demais Threads clonam da variavel global que ja foi carregada pela Thread X.
// -------------------------------------------------
GetGlbVars( "NSEMAFLAY" , @nSemafLay )
GetGlbVars( "_ALAYOUT"  , @aAuxLay   )
GetGlbVars( "_ALAYDEL"  , @aAuxDel   )
//conout( "GetGlbVars TAFLOADLAY " + cValToChar( ThreadId( ) )  + " Tamanho aLayOut: " + cValToChar( Len( aAuxLay ) ) )
//conout( "GetGlbVars TAFLOADLAY " + cValToChar( ThreadId( ) )  + " Tamanho aLayDel: " + cValToChar( Len( aAuxDel ) ) )

//Semaforo Ainda Não Carregado
If nSemafLay == _NO_LOAD //0
	PutGlbVars( "NSEMAFLAY", _LOADING ) //1
	//conout( "###### Thread principal iniciando semaforo para carregar layout TAF --> " +  cValToChar( ThreadId( ) ) )

//Semaforo Em Carregamento
ElseIf nSemafLay == _LOADING //1
	While nSemafLay == _LOADING
		//conout( "###### Thread aguardando carregamento do layout TAF --> " +  cValToChar( ThreadId( ) ) )
		sleep( 1000 ) //recomendacao chamar em partes menores e mais vezes.
		sleep( 1000 )
		sleep( 1000 )
		sleep( 1000 )
		sleep( 1000 )
		GetGlbVars( "NSEMAFLAY", @nSemafLay )		
	EndDo
	//Alimento as Variaveis Auxiliares
	GetGlbVars( "_ALAYOUT" , @aAuxLay )
	GetGlbVars( "_ALAYDEL" , @aAuxDel )
	//conout( "Thread liberada para utilizar layout TAF --> " +  cValToChar( ThreadId( ) ) )
EndIf

If nSemafLay <> _LOADED //2

	//conout( "###### Thread principal carregando layout TAF --> " +  cValToChar( ThreadId( ) ) )
	cFile := TAFLayout( )

	If File( cFile )

		FT_FUSE( cFile )
		FT_FGotop()

		// -------------------------------------------------
		// Carregamento de layout Total
		// -------------------------------------------------
		While (!FT_FEof())

			cLine := AllTrim(Upper(FT_FREADLN()))

			// ----------------------------------------------------
			// Verifica se quero fazer a carga de um Layout unico
			// ----------------------------------------------------
			If !Empty(cLayInteg) .AND. !lLayUnic
				lFaz := .F.

				If !lFaz .AND. ( "["+cLayInteg $ cLine )
					lFaz := .T.
					lLayUnic := .T.
				EndIf

			// ------------------------------------------------
			// Verifica se é o fim da carga do Layout unico
			ElseIf lLayUnic .AND. "###"$cLine
				If Len(aOrdDel) > 0
					aSort( aOrdDel ,,, { |x,y| PadR(x[1],6) > PadR(y[1],6) } )
					aLayDel[Len(aLayDel)][Len(aLayDel[Len(aLayDel)])] := aOrdDel
				EndIf
				aOrdDel := {}
				Exit
			EndIf

			If lFaz
				If Substr(cLine,1,10) == "XZ1_LAYOUT"
					aadd(aLayOut,{Substr(cLine,12,8),"","","","","","",""})
					lNewLayOut:= .T.
					cLayOut := Substr(cLine,12,8)

					TAFConout( "[TAFLoadLay] - Carregando o Layout de Integracao->" + cLayOut + " Thread " + cValToChar( ThreadId( ) ),2,.F.,"INTEG" )

					if type('oModel') <> 'U'
						oModel:Destroy()
					endif

					oModel  := FWLoadModel( cLayOut )
					aModel  := oModel:GetDependency()

				ElseIf Substr(cLine,1,8) == "XZ1_DESC"
					aLayOut[Len(aLayOut)][Z1_DESC]  := Substr(cLine,10,50)
				ElseIf Substr(cLine,1,9) == "XZ1_ADAPT"
					aLayOut[Len(aLayOut)][Z1_ADAPT] := Substr(cLine,11,10)
				ElseIf Substr(cLine,1,9) == "XZ1_TABLE"
					aLayOut[Len(aLayOut)][Z1_TABLE] := Substr(cLine,11,3)
					&(aLayOut[Len(aLayOut)][Z1_TABLE])->( dbCloseArea() )
				ElseIf Substr(cLine,1,10) == "XZ1_DESTAB"
					aLayOut[Len(aLayOut)][Z1_DESTAB]:= Substr(cLine,12,40)
				ElseIf Substr(cLine,1,9) == "XZ1_ORDER"
					/*
						Retirado Substr(cLine,11,1) por causa do novo índice ( SIX ) criado pelo eSocial para o layout T001AB -> ordem 12
						@see TAFLayout.prw -> layout T001AB
					*/
					aLayOut[Len(aLayOut)][Z1_ORDER] := Substr(cLine,11)
				ElseIf Substr(cLine,1,10) == "XZ1_MVCOPT"
					aLayOut[Len(aLayOut)][Z1_MVCOPT]:= Substr(cLine,12,1)
				ElseIf Substr(cLine,1,10) == "XZ1_MVCMET"
					aLayOut[Len(aLayOut)][Z1_MVCMET]:= Substr(cLine,12,1)
				EndIf

				If Substr(cLine,1,10) == "XZ2_CHANEL"

					lT001 := .F.
					lRegFilho := .F.
					If Len( aLayOut[ Len(aLayout) ] ) == 8
						aadd(aLayOut[Len(aLayOut)],{ {"","","","","",""} } )

						//Tratamento para que quando se tratar do registro T001 seja criada a estrutura corretamente.
						If Len(aLayout) == 5 .and. aLayout[5][1]=="TAFA050"
							lT001 := .T.
						ElseIf Len(aLayout) == 6 .and. aLayout[6][1]=="TAFA050"
							lT001 := .T.
						EndIf
					Else
						lRegFilho := .T.
					EndIf

					If 	lT001 .Or. lRegFilho

						aadd(aLayOut[Len(aLayOut)][Z1_CHANELS], {"","","","","","",""} )

						If lNewLayOut
							aadd(aLayDel , {Substr(cLine,12,20) , {Substr(cLine,12,20) , "" } } )
							aadd(aOrdDel , {Substr(cLine,12,20) , "" } )
							lNewLayOut := .F.
						Else
							aadd(aOrdDel , { Substr(cLine,12,20) , ""} )
						EndIf

					EndIf

					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z2_CHANEL]:= Substr(cLine,12,20)

				ElseIf Substr(cLine,1,9) == "XZ2_SUPER"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z2_SUPER] := Substr(cLine,11,20)
				ElseIf Substr(cLine,1,10) == "XZ3_CHANEL"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z3_RELAC] := Substr(cLine,12,20)
				ElseIf Substr(cLine,1,8) == "XZ3_DESC"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z3_DESC]  := Substr(cLine,10,50)
				ElseIf Substr(cLine,1,9) == "XZ3_IDOUT"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z3_IDOUT] := Substr(cLine,11,15)

					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z3_RELAC] := GetRelac( aModel , Substr(cLine,11,15) , .F. )

					If Len(aLayOut[Len(aLayOut)][Z1_CHANELS]) > 1
						aOrdDel[Len(aOrdDel),2] := Substr(cLine,17,3)
					EndIf

					(Substr(cLine,17,3))->( dbCloseArea() )
				ElseIf Substr(cLine,1,10) == "XZ3_OCCURS"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut)][Z1_CHANELS])][Z3_OCCURS]:= Substr(cLine,12,1)
				ElseIf Substr( cLine, 1, 9 ) == "XZ3_ORDER"
					aLayOut[Len( aLayOut )][Z1_CHANELS][Len( aLayOut[Len( aLayOut )][Z1_CHANELS] )][Z3_ORDER] := SubStr( cLine, 11, 1 )
				EndIf

				If Substr(cLine,1,7) == "XZ4_SEQ"
					If Len( aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])]) == 7
						aadd( aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])] ,{ {"","","","","",""} } )
					Else
						aadd( aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS], {"","","","","",""} )
					EndIf

					nPosZ4 := Len(aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayout)][Z1_CHANELS])][Z3_FIELDS])

					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_SEQ]:= Substr(cLine,9,3)
				ElseIf Substr(cLine,1,9) == "XZ4_FIELD"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_FIELD]:= Substr(cLine,11,10)
				ElseIf Substr(cLine,1,8)  == "XZ4_DESC"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_DESC]:= Substr(cLine,10,50)
				ElseIf Substr(cLine,1,10) == "XZ4_TYPFLD"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_TYPFLD]:= Substr(cLine,12,1)
				ElseIf Substr(cLine,1,10) == "XZ4_SOURCE"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_SOURCE]:= Substr(cLine,12,40)
				ElseIf Substr(cLine,1,8)  == "XZ4_EXEC"
					aLayOut[Len(aLayOut)][Z1_CHANELS][Len(aLayOut[Len(aLayOut),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_EXEC]:= Substr(cLine,10,250)
				EndIf

			EndIf

			FT_FSKIP()

			cLine := AllTrim(FT_FREADLN())
			If Len(aOrdDel) > 0
				If ( Substr(cLine,1,10) == "XZ1_LAYOUT" .And. !Empty(cLayOut) .And.  cLayOut <> Substr(cLine,12,8) ) .Or. FT_FEof()
					aSort( aOrdDel ,,, { |x,y| PadR(x[1],6) > PadR(y[1],6) } )
					aLayDel[Len(aLayDel)][Len(aLayDel[Len(aLayDel)])] := aOrdDel
					aOrdDel := {}
				EndIf
			EndIf
		EndDo

		if type('oModel') <> 'U'
			oModel:Destroy()
		endif

		FT_FUse()

		If FErase( cFile ) < 0
			Aviso( "Atenção", "Falha para apagar o arquivo: " + cFile + "." + Chr( 13 ) + Chr( 10 ) + "Código do erro: " + AllTrim( Str( FError() ) ) + Chr( 13 ) + Chr( 10 ) + "Mais informações: http://tdn.totvs.com/display/tec/FError", { "Fechar" }, 3 )
		EndIf

		//Alimenta as variaveis globais com os arrays populados
		PutGlbVars( "_ALAYOUT"	, aLayout )
		PutGlbVars( "_ALAYDEL"	, aLayDel )
		
		//Apos Finalizacao do Carregamento
		PutGlbVars( "NSEMAFLAY"	, _LOADED ) //2
		//conout( "####### Thread principal terminou carregamento do layout TAF --> " +  cValToChar( ThreadId( ) ) )
	EndIf
	ErrorBlock( oError )
Else
	//conout( "####### Thread clonando layout TAF --> " + cValToChar( ThreadId( ) ) )
	aLayout := aClone( aAuxLay )
	aLayDel := aClone( aAuxDel )
EndIf

//Tratamento para quando a chamada deseja que o retorno da função sejam os arrays populados
if lRetLayout
	aReturn := { aLayout, aLaydel }
else
	aReturn := aLayout
endif

Return( aReturn )

//-------------------------------------------------------------------
/*{Protheus.doc} GetRelac()
Funcao recursiva de apoio a funcao TAFLoadLay buscar o relacionamento
do canal atraves do MODELO passado pela TAFLoadLay()

@param aModel, cModelo, lEnd
@return aRetorno = Relacionamento do Canal

@author Alexandre Inacio Lemes
@since 07/05/2014
@version 1.0
*/
//-------------------------------------------------------------------
Static Function GetRelac( aModel , cModelo , lEnd )

Local aRetorno := {}
Local n1       := 0

For n1 := 1 to Len(aModel)
   If aModel[n1][2] == cModelo
      aRetorno := aModel[n1][3]:GetRelation()[1]
	  lEnd := .T.
      Exit
   Else
	  If Len(aModel[n1][4])	> 0
       	aRetorno := GetRelac( aModel[n1][4] , cModelo , @lEnd )
		If lEnd
			Exit
		EndIf
      EndIf
   EndIf
Next n1

Return( aRetorno )

//-------------------------------------------------------------------
/*{Protheus.doc} FTAFFlag

Rotina com o objetivo de processar a alteracao de status de registros
nas tabelas compartilhadas TAFST1 e TAFST2.

@Param cAlias  - Alias a ser executado a troca de status (TAFST1 ou  TAFST2)
       aRecno  - Registros que devem ser processados a troca de status
       cStatus - Informacao a ser gravada no campo de status

@Return lOk - Informa se o processo foi executado com sucesso

@Author Felipe C. Seolin
@Since 23/05/2014
@Version 1.0
*/
//-------------------------------------------------------------------
Function FTAFFlag( cAlias, aRecno, cStatus )

Local cSql			:=	""
Local cRecno		:=	""
Local nI			:=	0
Local nLength		:=	0
Local aSql			:=	{}
Local lOk			:=	.F.

TAFConout( "Iniciou FTafFlag( : " + Time(),2,.F.,"INTEG" )

If !Empty( aRecno )

	//Felipe Seolin - 26/03/2015
	//Para alguns bancos existe tamanho máximo para a instrução update.
	//Limito em 500 caracteres o comando sql, evitando problemas com o banco de dados.
	For nI := 1 to Len( aRecno )

		cRecno += AllTrim( Str( aRecno[nI] ) ) + ", "
		nLength += Len( cRecno )

		If nLength > 500
			cRecno := SubStr( cRecno, 1, Len( cRecno ) - 2 )
			aAdd( aSql, cRecno )
			cRecno := ""
			nLength := 0
		EndIf
	Next nI

	If nLength > 0
		cRecno := SubStr( cRecno, 1, Len( cRecno ) - 2 )
		aAdd( aSql, cRecno )
		cRecno := ""
		nLength := 0
	EndIf

EndIf

For nI := 1 to Len( aSql )

	cSql := "UPDATE " + cAlias + " "
	cSql += "SET TAFSTATUS = '" + cStatus + "' "
	cSql += " WHERE R_E_C_N_O_ IN ( " + aSql[nI] + " ) "

	lOk := TcSQLExec( cSql ) >= 0 //Executa o update.

	//Se update com sucesso, realizo commit.
	If lOk
		If InTransAction()
			TCSQLExec( "COMMIT" )
		EndIf
	Else
		TAFConout( "",2,.T.,"INTEG" )
		TAFConout( "Query -> " + StrZero( Len( cSql ), 12 ),2,.T.,"INTEG" )
		TAFConout( "",2,.T.,"INTEG")
		TAFConout( "            NOT OK " + TCSQLError(),2,.T.,"INTEG" )
	EndIf
Next nI

TAFConout( "Terminou FTafFlag( : " + Time(),2,.F.,"INTEG")

Return( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVerEstru

Funcao

Funcao que verifica estrutura dos registros da TAFST2 antes de selecionar
os registros elegiveis a integracao. Esta funcionalidade atua apenas nos registros
do Layout TOTVS - TXT = TAFCODMSG = 1

@param
aLayout - Layout TOTVS carregado

@Alterações:
25/05/2016 - Rodrigo Aguilar
Para processamento em MT foram incluídos os seguintes parâmetros na função:
_cTafKey  -> Chave por TAFKEY utilizada na integração do JOB 2
aDadosST2 -> Array a ser populado na função com as informações da linha
aRecInt   -> Array a ser populado com os Recnos dos registros que foram processados
lTafErrorLog -> Variável de controle lógico que indica se ocorreu Error Log no processamento para controle
da Thread

@Return
lFindErr - Controle lógico que indica se ocorreu ou não erro na validação do registro ( Usado quando a validação
for unitária por linha da TAFST2 - MT )

@author Demetrio Fontes De Los Rios

@since 30/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFVerEstru( lEnd, cST2Alias, aLayout, lJob, cXERPAlias, _cTafKey, aDadosST2, aRecInt, lTafErrorLog, cCodEscopo )

Local _cKey		:=	""
Local cTafKeySeq	:=	""
Local cChanel		:=	""
Local cFathMsg	:=	""
Local nContCh		:=	0
Local nI			:=	0
Local nContRegs	:=	0
Local nProcQtd	:=	0
Local nChanel		:=	0
Local nFather		:=	0
Local nPosFields	:=	0
Local nQtdCmpos	:=	0
Local nMaxRef		:=	0
Local nLenDados	:=	0
Local aRecErro	:=	{}
Local aRecnoSt2	:=	{}
Local aDadosST2	:=	{}
Local lFindErr    := .F.
Local lT999		:=	.F.

local bTafError := nil

default _cTafKey     := ''
default aDadosST2    := {}
default aRecInt      := {}
default lTafErrorLog := .F.
Default cCodEscopo   := "1"

If cCodEscopo == "1"

    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    //Somente deve ser tratado o error log quando o processamento ocorrer em MT, caso contrário deve ser abortado o processamento apresentando o erro ao usuário
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    if !empty( _cTafKey )
        bTafError := ErrorBlock( { |Obj| FErrorTaf( Obj, @lTafErrorLog, 'TAFVerEstru' ) } ) //Tratamento para quando ocorre error log
    endif

    If lJob
        xTAFMsgJob( "Selecionando registros para validação..." )
    Else
        nContRegs := ( cST2Alias )->( RecCount() )
        ProcRegua( nContRegs )
    EndIf

    //ConOut( "INICIOU TAFVerEstru " + Time() )

    _cKey := ( cST2Alias )->( TAFFIL + TAFSTATUS + TAFCODMSG )

    While ( cST2Alias )->( !Eof() ) .and. iif( !empty( _cTafKey ) , _cTafKey == ( cST2Alias )->( TAFIDTHRD + TAFCODMSG + TAFSTATUS + TAFFIL + dToS(TAFDATA) + TAFHORA + TAFTICKET + TAFKEY ), _cKey == ( cST2Alias )->( TAFFIL + TAFSTATUS + TAFCODMSG ) )

        aDadosST2 	:= {}
        aRecnoSt2 	:= {}
        cTafKeySeq 	:= ( cST2Alias )->TAFKEY
        lT999		:=	.F.

        //------------------------------------------------
        //Verifica se a mensagem não esta em branco
        If Empty( AllTrim( ( cST2Alias )->TAFMSG ) )

            aAdd( aRecErro, ( cST2Alias )->( Recno() ) )
            TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000001" )

        Else

            //Funcao para alimentar o array aDadosST2 com as informacoes da Shared Table tratando
            //tambem os casos onde a informacao esta quebrada em mais de uma linha
            xTAFVldSeq( .T., cST2Alias, cTafKeySeq, @aDadosST2, @aRecInt,, @aRecnoSt2, cXERPAlias )
            //--------------------------------
            //Varre o registro
            For nContCh := 1 to Len( aDadosST2 )
                lT999 := (AllTrim( aDadosST2[nContCh,1] ) == "T999")

                //--------------------------------------------------------------
                //Verifica se eh o pai para definir posicionamento do mesmo
                cFathMsg := Iif ( lT999, AllTrim( aDadosST2[1,2] ), AllTrim( aDadosST2[1,1] ) )
                If nContCh == 1
                    nFather := aScan( aLayOut , { |x| AllTrim( SubStr( x[Z1_DESC], 1, At( "-", x[Z1_DESC] ) - 1 ) ) == cFathMsg } )
                EndIf

                //Se pai for valido
                If nFather > 0 .and. ( AllTrim( aDadosST2[1,1]) == AllTrim( ( cST2Alias )->TAFTPREG ) .or. AllTrim( ( cST2Alias )->TAFTPREG ) == "T999" )

                    if lT999
                        cChanel 	:=  cFathMsg := AllTrim( aDadosST2[nContCh,2] )
                        nFather  	:= 	aScan( aLayOut , { |x| AllTrim( SubStr( x[Z1_DESC], 1, At( "-", x[Z1_DESC] ) - 1 ) ) == cFathMsg } )
                        if nFather > 0
                            nChanel := aScan( aLayOut[nFather,Z1_CHANELS], { |x| AllTrim( x[Z2_CHANEL] ) == cChanel } )
                        else
                            nChanel := 0
                        endif
                    else
                        cChanel := AllTrim( aDadosST2[nContCh,1] )
                        nChanel := aScan( aLayOut[nFather,Z1_CHANELS], { |x| AllTrim( x[Z2_CHANEL] ) == cChanel } )
                    endif

                    //Se existir dois registros pais dentro do mesmo MEMO na TAFST2
                    If AllTrim( aDadosST2[nContCh,1] ) == AllTrim( aDadosST2[1,1] ) .and. nContCh > 1 .and. nFather > 0
                        If Len( aRecnoSt2 ) > 0
                            For nI := 1 to Len( aRecnoSt2 )
                                aAdd( aRecErro, aRecnoSt2[nI] )

                                TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000001" )
                            Next nI
                        EndIf
                        Exit
                    EndIf

                    //--------------------------------
                    //Verifica se Channel esta dentro da estrutura
                    If nChanel > 0

                        nPosFields := Len( aLayOut[nFather,Z1_CHANELS,nChanel] )
                        nQtdCmpos := Len( aLayOut[nFather,Z1_CHANELS,nChanel,nPosFields] )
                        nMaxRef := 0

                        //Essa validacao eh necessaria pois nao eh a quantidade de campos do Layout.def que define
                        //quantos campos devem ser enviados para o registro mas sim a maior referencia indicada no
                        //layout.def, o laco abaixo busca essa referencia.
                        For nI := 1 to Len( aLayOut[nFather,Z1_CHANELS,nChanel,nPosFields] )
                            If Val( aLayOut[nFather,Z1_CHANELS,nChanel,nPosFields,nI,5] ) > nMaxRef
                                nMaxRef := Val( aLayOut[nFather,Z1_CHANELS,nChanel,nPosFields,nI,5] )
                            EndIf
                        Next nI

                        nLenDados := Len( aDadosST2[nContCh] )

                        Iif( lT999, nQtdCmpos ++, ) //+ 1 se for regitro exclusão


                    Else //Registro invalido
                        If (!(lT999) .and. Len( aRecnoSt2 ) > 0)
                            For nI := 1 to Len( aRecnoSt2 )
                                aAdd( aRecErro, aRecnoSt2[nI] )

                                TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000001" )
                            Next nI
                        EndIf
                        if !(lT999)
                            Exit
                        endif
                    EndIf

                Else //Registro invalido
                    If Len( aRecnoSt2 ) > 0
                        For nI := 1 to Len( aRecnoSt2 )
                            aAdd( aRecErro, aRecnoSt2[nI] )

                            TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000001" )
                        Next nI
                    EndIf
                    Exit
                EndIf

            Next nContCh

        EndIf

        //Cancelamento do Registro
        If !lJob .and. lEnd
            Exit
        EndIf

        //Demetrio - 17/08/2014
        //Variavel para tratamento, evitando INCPROC para todo registro, apenas de 5 em 5. Melhor performance/custo INCPROC.
        nProcQtd += 1

        //Tratamento para funcionalidade via Job/Schedule
        If !lJob .and. nProcQtd > 2
            IncProc( "Processando registro: " + AllTrim( ( cST2Alias )->TAFKEY ) )
            nProcQtd := 0
        EndIf

        //-----------------------------------------------------------------------------------------------------
        //Caso seja uma chamada por MT não devo continuar no laço, os registros são validados de forma unitária
        //-----------------------------------------------------------------------------------------------------
        if !empty( _cTafKey )
            exit
        else
            ( cST2Alias )->( DBSkip() )
        endif
    EndDo

    //------------------------------------------------------
    //Realizar o Flag nos registros inconsistentes
    If Len( aRecErro ) > 0
        //---------------------------------------------------------
        //Caso seja chamada por MT não devo alterar o status para 9
        //---------------------------------------------------------
        if empty( _cTafKey )
            FTAFFlag( 'TAFST2', aRecErro, "9" )
        endif

        lFindErr := .T.
    EndIf

    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    //Somente deve ser tratado o error log quando o processamento ocorrer em MT, caso contrário deve ser abortado o processamento apresentando o erro ao usuário
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    if !empty( _cTafKey )
        ErrorBlock( bTafError )
    endif

EndIf

Return lFindErr

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFVldSeq
Esta funcao tem como objetivo fazer uma pre validacao das informacoes a serem
integradas para o TAF pelo motor de integracao, eh utilizada tanto no momento
da validacao da estrutura quando no momento da integracao das informacoes.

@param
cST2Alias  - Work Area da tabela TAFST2
cTafKeySeq - Chave do registro da TAFST2 que esta sendo processado
aDadosST2  - Array com as informacoes que devem ser processadas no retorno dessa funcao
aRecInt    - Array com os recnos dos registros que serao processados e integrados para o TAF
aRecErr    - Array com os recnos dos registros que possuem uma filial nao existete no cadastro de
			  complemento de empresa
aRecnoSt2 -

@Author Rodrigo Aguilar

@since 16/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function xTAFVldSeq( lVldEstrut, cST2Alias, cTafKeySeq, aDadosST2, aRecInt, aRecErr, aRecnoSt2, cXERPAlias )

Local cRegistro := ""
Local cChannel  := ""
Local cSlice	  := ""
Local cQuery    := ""
Local cLine	  := ""

Local cSeqReg := "000"

Local lInteg    := .T.

Local aFindFil  := {}
//Local aKeyDupl := {}

Local cAliasTrb := ""//GetNextAlias()

Local lQuery    := .F.

Local nTagEnd	  := 0
Local nQtdRegs  := 0

Default aRecInt    := {}
Default aRecErr    := {}
Default aRecnoSt2  := {}

//Busco a informacao do channel que sera processado
cChannel := AllTrim( (cST2Alias)->TAFTPREG )

//Gravo informacao da linha que sera processada
cLine    := Upper((cST2Alias)->TAFMSG)

//Verifico se existem quebras dentro do MEMO que sera processado
//Tratamento específico para T123, pois possue campo MEMO que pode ser
//alimentado com conteúdo que excede o limite permitido para o banco de dados
If AT( CHR(10) , cLine ) > 0 .or. AllTrim( ( cST2Alias )->TAFTPREG ) == "T123"

	/*Rodrigo Aguilar - lQuery apenas para um teste de performance, retirar esse trecho na compatibilizacao
	If lQuery
		cQuery := " SELECT  COUNT(*) SEQ FROM " + cST2TAB + " TAFST2 "
		cQuery += " WHERE TAFST2.TAFKEY = '" + cTafKeySeq + "' AND TAFST2.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery( cQuery )
		DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

		nQtdRegs := (cAliasTrb)->SEQ

		(cAliasTrb)->( DbCloseArea() )
	Else*/
		(cST2Alias)->( DbSkip() )

		//Caso se trate da mesma chave significa que o registro foi quebrado em
		//varias linhas na TAFST2
		If 	cTafKeySeq == (cST2Alias)->TAFKEY

			cAliasTrb	:=	GetNextAlias()

			//Conout( "EXECUTEI A QUERY DO SEQ > 1" )

			cQuery := " SELECT  COUNT(*) SEQ FROM " + cST2TAB + " TAFST2 "
			cQuery += " WHERE TAFST2.TAFKEY = '" + cTafKeySeq + "' AND TAFST2.D_E_L_E_T_ = '' "

			cQuery := ChangeQuery( cQuery )
			DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

			nQtdRegs := (cAliasTrb)->SEQ

			(cAliasTrb)->( DbCloseArea() )
		Else
			nQtdRegs  := 1
		EndIf
		(cST2Alias)->( DbSkip(-1) )
	//EndIf

	cSeqReg := "000"

	//Enquanto se tratar do mesmo registro, como no while da cAliasST2 utilizamos o indice 2 ( Key + Seq )
	//garanto que as informacoes estarao na ordem correta no momento da integracao
	While (cST2Alias)->( !Eof() ) .And. cTafKeySeq == (cST2Alias)->TAFKEY

		//Tratamento para que quando exista mais de um TAFKEY com o mesmo TAFSEQ nao ocorra
		//erro de chave duplicada 
		If Val(cSeqReg) == Val((cST2Alias)->TAFSEQ)
			Exit
		EndIf
		lInteg := .T.

		//Verifico se existe a filial de referencia na tabela de complemento de empresa, caso contrario
		//aborto o processamento
		If AllTrim( ( cST2Alias )->TAFTPREG ) <> "T001"
			FTafGetFil( ( cST2Alias )->TAFFIL, @aFindFil )

			//Caso retorne erro na validação do complemento de empresa o array estará vazio e assim
			//setamos a variável lInteg como .F., porém prosseguimos com o processamento para que
			//todos os registros referentes a esta mesma chave sejam setados com status '8'
			If !Empty( aFindFil )
				lInteg := .F.
				TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "8", "000002" )
			EndIf
		EndIf

		If lInteg
			cLine := Upper((cST2Alias)->TAFMSG)
			cLine := StrTran( cLine, ">", " " )

			//Tratamento específico para T123, pois possue campo MEMO que pode ser
			//alimentado com conteúdo que excede o limite permitido para o banco de dados
			If AllTrim( ( cST2Alias )->TAFTPREG ) == "T123"

				If SubStr( cLine, Len( cLine ) - 1, 2 ) == "| "
					cLine := SubStr( cLine, 1, Rat( "|", cLine ) - 1 )
				EndIf

				cRegistro += cLine

				aAdd( aRecInt, { ( cST2Alias )->( Recno() ), ( cST2Alias )->TAFKEY } )
			Else

				While .T.

					nTagEnd := AT( CHR(10) , cLine ) - 2

					If nTagEnd < 0
						cLine += CHR(10)
						nTagEnd := AT( CHR(10) , cLine ) - 2
					EndIf

					//Em alguns casos o nTagEnd esta retornando uma posicao antes do Pipe final ocasionando erro
					//na integracao, incluido esse tratamento para que nesses casos o Pipe final seja incluido
					If Right( Substr( cLine , 1 , nTagEnd ) , 1 ) <> "|"
						cRegistro :=  Substr( cLine , 1 , nTagEnd ) + "|"
					Else
						cRegistro :=  Substr( cLine , 1 , nTagEnd )
					EndIf

					//Tratamento para que seja retirado o primeiro pipe da linha do registro, o mesmo não pode ser utilizado
					//senao ocorre erro no Str2Arr().
					If Substr(cRegistro,1,1) == "|"
						cRegistro := Substr(cRegistro,2,nTagEnd+5)
					EndIf

					If !Empty(cRegistro)
						aAdd( aDadosST2, TafStr2Arr( cRegistro , "|" ) )
					EndIf

					//Aadd(aKeyDupl,{(cST2Alias)->TAFKEY, (cST2Alias)->TAFSEQ } )

					cSlice := SubStr( cLine, nTagEnd + 3, Len( cLine ) )

					If Empty( cSlice )
						Exit
					EndIf

					cChannel := SubStr( cSlice, 1, At( "|", cSlice ) - 1 )
					cLine := SubStr( cSlice, 1, Len( cSlice ) )

					If At( Chr( 10 ), cLine ) == 0
						cLine := cLine

						//Tratamento para que seja retirado o primeiro pipe da linha do registro, o mesmo
						//não pode ser utilizado, senão ocorre erro no Str2Arr().
						If Substr( cLine, 1, 1 ) == "|"
							cLine := SubStr( cLine, 2, Len( cLine ) )
						EndIf

						If !Empty(cLine)
							aAdd( aDadosST2, TafStr2Arr( cLine, "|" ) )
						EndIf
						//aAdd( aKeyDupl, { ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFSEQ } )

						Exit
					EndIf

				EndDo

				//Conout( " $$$$$$$$$$$$$$$$$$   "  + cLine )
				aAdd(aRecInt, { (cST2Alias)->(Recno()), (cST2Alias)->TAFKEY } )

			EndIf

		Else
			aAdd(aRecErr,(cST2Alias)->(Recno()))
		EndIf

		Aadd( aRecnoSt2, (cST2Alias)->(Recno()))

		cSeqReg := (cST2Alias)->TAFSEQ

		//Tratamento para que quando exista quebra de informacao na TAFST2 o array aDadosST2 seja
		//populado com todas as linhas e processado corretamente, o cST2Alias deve sempre estar posicionado
		//no ultimo registro com a mesma chave.
		If nQtdRegs <> 1
			(cST2Alias)->( DbSkip() )
		Else
			Exit
		EndIf
		nQtdRegs--
	EndDo
	//Tratamento para posicionar corretamente, quando houver dois tickets, com mesmo TAFKEY e mais de uma sequência.
	If (cTafKeySeq <> (cST2Alias)->TAFKEY)
		(cST2Alias)->( DbSkip(-1) )
	Endif

	//Tratamento específico para T123, pois possue campo MEMO que pode ser
	//alimentado com conteúdo que excede o limite permitido para o banco de dados
	If AllTrim( ( cST2Alias )->TAFTPREG ) == "T123"

		//Tratamento para que seja retirado o primeiro pipe da linha do registro, o mesmo
		//não pode ser utilizado senão ocorre erro no Str2Arr()
		If SubStr( cRegistro, 1, 1 ) == "|"
			cRegistro := SubStr( cRegistro, 2 )
		EndIf

		//Tratamento para que o Pipe final seja incluido
		If SubStr( cRegistro, Len( cRegistro ), 1 ) <> "|" .And. !Empty(cRegistro)
			cRegistro := cRegistro + "|"
		Else
			cRegistro := cRegistro
		EndIf

		If !Empty(cRegistro)
			aAdd( aDadosST2, TafStr2Arr( cRegistro, "|" ) )
		EndIf

	EndIf

Else

	//Verifico se existe a filial de referência na tabela de complemento de empresa, caso contrário
	//aborto o processamento
	If AllTrim( ( cST2Alias )->TAFKEY ) <> "T001"
		FTafGetFil( ( cST2Alias )->TAFFIL, @aFindFil )

		//Caso retorne erro na validação do complemento de empresa o array estará vazio e assim
		//setamos a variável lInteg como .F., porém prosseguimos com o processamento para que
		//todos os registros referentes a esta mesma chave sejam setados com status '8'
		If !Empty( aFindFil )
			lInteg := .F.
			TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "8", "000002" )
		EndIf
	EndIf

	If lInteg

		cRegistro :=  cLine

		//Tratamento para que seja retirado o primeiro pipe da linha do registro, o mesmo não pode ser utilizado
		//senao ocorre erro no Str2Arr().
		If Substr(cRegistro,1,1) == "|"
			cRegistro := Substr(cRegistro,2,Len(cRegistro))
		EndIf

		If 	!Empty(cRegistro)
			aAdd( aDadosST2, TafStr2Arr( cRegistro , "|" ) )
		EndIf

		aAdd(aRecInt, { (cST2Alias)->(Recno()), (cST2Alias)->TAFKEY } )
	Else
		aAdd(aRecErr,(cST2Alias)->(Recno()))
	EndIf

	Aadd( aRecnoSt2, (cST2Alias)->(Recno()))

EndIf

//If Len( aDadosST2 ) > 0 .And. !lVldEstrut
	//xTafVlCont( aDadosST2, aDadosST2[1][1], @aKeyDupl, @aRecInt, @aRecnoSt2 )
//EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafVlCont

@param


@Author Rodrigo Aguilar

@since 20/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function xTafVlCont( aDadosST2, cRegInt, aKeyDupl, aRecInt, aRecnoSt2 )

Local cChvDupl := ""
Local aItem    := Array(01)

local nPosDup := 0
Local nlI, nlY := 1
Local aRegDuplc := {}

For nlI := 1 To Len( aDadosST2 )

 	aItem[1]   := "|"
	For nlY := 1 To Len( aDadosST2[nlI] )
		aItem[1] += Alltrim(  aDadosST2[nlI][nlY] ) + "|"
	Next

	nPosDup := aScan( aRegDuplc, {|x| x[1] == aItem[1] } )

	If nPosDup > 0

		nPosDup := aRegDuplc[nPosDup][2]

		cChvDupl :=  "Informação Duplicada, Registro " + Alltrim( cRegInt ) + ":" + Chr(13)+Chr(10)
		cChvDupl +=  "TafKey: " + Alltrim( aKeyDupl[nPosDup][1] ) + Chr(13)+Chr(10)
		cChvDupl +=  "TafSeq: " + Alltrim( aKeyDupl[nPosDup][2] ) + Chr(13)+Chr(10)
		cChvDupl +=  "TafKey: " + Alltrim( aKeyDupl[nlI][1] ) + Chr(13)+Chr(10)
		cChvDupl +=  "TafSeq: " + Alltrim( aKeyDupl[nlI][2] ) + Chr(13)+Chr(10)
		cChvDupl +=  "Linha: " + aItem[1] + Chr(13)+Chr(10)
		cChvDupl +=  Replicate( "-", 100 )+ Chr(13)+Chr(10)
	Else
		Aadd( aRegDuplc, { aItem[1], nlI } )
	EndIf
Next

If !Empty( cChvDupl )
	Aviso("Chaves Duplicadas",cChvDupl,{"Ok"},3)

	For nlI := 1 To Len( aRecInt )
		aAdd(aRecnoSt2, aRecInt[nlI][1] )
	Next
	aRecInt := {}
EndIf

Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} FExcRegInt
Esta função tem como objetivo realizar a exclusão das informacoes no periodo que
esta sendo integrado, alguns registro do bloco F do Sped Contribuiçoes necessitam da
descrição complementar na chave e para naõ criar essa regra na integração sempre assumimos
que a informacao que o cliente esta enviando eh a mais atual, desconsideando as anterioes

@param
cAliasReg  - Alias da tabela
cFilChvUnq - Filial do registro para exclusao
aDadosST2 - Periodo a ser pesquisado para exclusao

@Author Rodrigo Aguilar

@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FExcRegInt( cAliasReg, cFilChvUnq, aDadosST2 )

(cAliasReg)->( DbSetOrder( 1 ) ) //FILIAL + PERIODO
cPeriod := aDadosST2[2]

If (cAliasReg)->( MsSeek( cFilChvUnq + cPeriod ) )
	While (cAliasReg)->( !Eof() ) .And. DTos( (cAliasReg)->&(cAliasReg+"_PERIOD") ) == cPeriod
		FTafExisLock( cAliasReg, .F., .T. )
			(cAliasReg)->( DbDelete() )
		(cAliasReg)->( MsUnlock() )

		(cAliasReg)->( DbSkip() )
	EndDo
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetInd

Esta funcao tem como objetivo criar o índice da tabela baseando-se no layout.def para distinguir
os campos que compõe a chave e normalizar o indice de acordo com os dados passados na integração (aDadosST2)

@param
nFather	 	- Indexador do registro PAI
nChanel	 	- Posição do canal no array aLayout
aDadosST2		- Dados enviados na tabela TAFST2
cFilRegInt  	- Filial do registro a ser integrado
nChlST2    	- Indexador do Array aDadosST2
aIncons		- Array dos registros com inconsitências
cCpoAlias		- Alias da tabela Pai
lNative
nMtd3Order		- Índice utilizado no Método 3 de Integração
aLayout        - Array aLayout quando processo é executado via MT

@return cKey	- Chave Normalizada

@Author Evandro dos Santos Oliveira
@Since 06/11/2014
@Version 1.0

@Obs	24/02/2016 - Felipe C. Seolin - Aplicação de condições para utilização do Método 3 de Integração
/*/
//-------------------------------------------------------------------
Function TAFGetInd( nFather, nChanel, aDadosST2, cFilRegInt, nChlST2, aIncons, cCpoAlias, lNative, nMtd3Order, aLayout, aTamSx3 )

Local cFldsIndex	:=	""
Local cKey			:=	""
Local cAuxKey		:=	""
Local aSource		:=	{}
Local aFldsIndex	:=	{}
Local nFoundCpo	    :=	0
Local nPosAux		:=	0
Local nSource		:=	0
Local nI			:=	0

Default nMtd3Order	:=	0
Default aTamSx3     := {}

//Retira o Identificador de Exclusão para não atrapalhar a identificação dos registros
If (AllTrim(aDadosST2[1][1]) == "T999")
	aDel(aDadosST2[1],1)
	aSize(aDadosST2[1],Len(aDadosST2[1])-1)
EndIf

dbSelectArea(cCpoAlias)

// -----------------------------------------------------------------
// Verificação se foi chamado pelo Método 3 de Integração
//
// A verificação é feita a partir da variável nMtd3Order, pois ela
// deve estar com valor 0 nos demais métodos. Se tratando do Método
// 3, deve ser considerado Índice recebido na variável nMtd3Order e
// os campos _FILIAL e _ID não devem fazer parte da chave
// -----------------------------------------------------------------
If nMtd3Order == 0
	
	DBSetOrder( Val( aLayOut[nFather][Z1_ORDER] ) )
	cFldsIndex := ( cCpoAlias )->( IndexKey() )
	
	//Foi retirado o campo da geração da chave para situação onde o TAF possui a nota com o campo C20_CODSIT diferente do que está sendo integrado
	If cCpoAlias = "C20" 
		If !Empty(aDadosST2[1][56]) //posição 56 - Data de cancelamento
			cFldsIndex := StrTran( cFldsIndex, "+C20_CODSIT" ) //desconsidero o campos de situação para dar o Seek						
		EndIf
	EndIf
	
	cFldsIndex := StrTran( cFldsIndex, "DTOS(", "" )
	cFldsIndex := StrTran( cFldsIndex, "STR(", "" )
	cFldsIndex := StrTran( cFldsIndex, ")", "" )
	aFldsIndex := TafStr2Arr( cFldsIndex, "+" )

	If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
		cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
	EndIf
	cKey := IIf( cCpoAlias == "C1E", cXFilC1E , FTafGetFil( cFilRegInt, @aIncons , cCpoAlias ) )
Else
	DBSetOrder( nMtd3Order )
	cFldsIndex := ( cCpoAlias )->( IndexKey( nMtd3Order ) )

	cFldsIndex := StrTran( cFldsIndex, "DTOS(", "" )
	cFldsIndex := StrTran( cFldsIndex, "STR(", "" )
	cFldsIndex := StrTran( cFldsIndex, ")", "" )

	cFldsIndex := StrTran( cFldsIndex, cCpoAlias + "_FILIAL+", "" )
	cFldsIndex := StrTran( cFldsIndex, cCpoAlias + "_ID+", "" )

	aFldsIndex := TafStr2Arr( cFldsIndex, "+" )
EndIf

For nI:= 1 To Len(aFldsIndex)

//Tratamento para retirar possiveis "virgulas" deixadas pela Função STR
aFldsIndex[nI] := IIf((nPosAux := AT(",",aFldsIndex[nI])) > 0,Substr(aFldsIndex[nI],1,nPosAux-1),aFldsIndex[nI])
nFoundCpo := aScan(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS],{|x| AllTrim(x[Z4_FIELD]) == AllTrim(aFldsIndex[nI])})
If nFoundCpo > 0
	//Tratamento para quando o campo existir no ambiente/layout do TAF mas não foi enviado na mensagem de integração
	//Para evitar a busca no array aDadosST2 em uma posição inexistente, neste caso considero que o conteúdo
	//enviado é branco
	If Len( aDadosST2[nChlST2] ) < nFoundCpo
		if lTafX3
			cKey += PadR( "" , TafTmSx3(alltrim(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD]),aTamSx3) )
		else
			cKey += PadR( "" , TamSX3( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1] )
		endif
	Else
		If AT(";" ,	aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) > 0
			If !Empty(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC])
				aSource := TafStr2Arr( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] , ";" )
				For nSource := 1 To Len(aSource)
					If nSource == 1
						xA := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 2
						xB := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 3
						xC := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 4
						xD := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 5
						xE := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 6
						xF := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 7
						xG := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 8
						xH := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 9
						xI := aDadosST2[nChlST2][Val(aSource[nSource])]
					ElseIf nSource == 10
						xJ := aDadosST2[nChlST2][Val(aSource[nSource])]
					EndIf
				Next nSource
				//Tratamento para que quando o campo seja numerico e faca parte da chave seja alterado o valor de
				//"," para "." para que o Seek nao falhe duplicando as informações.
				If aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
					cAuxKey := StrTran( &(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC]), ",", "." )
				Else
					cAuxKey := &(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC])
				EndIf
				if lTafX3
					cKey += PadR( cAuxKey, TafTmSx3(alltrim(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD]),aTamSx3) )
				else
					cKey += PadR( cAuxKey, ;
					TamSX3( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1] )
				endif
			Else
				//Tratamento para que quando o campo seja numerico e faca parte da chave seja alterado o valor de
				//"," para "." para que o Seek nao falhe duplicando as informações.
				If aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
					cAuxKey := StrTran( aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) ], ",", "." )
				Else
					cAuxKey := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) ]
				EndIf
				if lTafX3
					cKey += PadR( cAuxKey, TafTmSx3(alltrim(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD]),aTamSx3) )
				else
					cKey += PadR( cAuxKey  , ;
					TamSX3( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1] )
				endif
			EndIf
		Else
			If !Empty(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC])
				xA := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) ]
				//Tratamento para que quando o campo seja numerico e faca parte da chave seja alterado o valor de 
				//"," para "." para que o Seek nao falhe duplicando as informações.
				If aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
					cAuxKey := StrTran( &(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC]), ",", "." )
				Else
					cAuxKey := &(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_EXEC])
				EndIf
				if lTafX3
					cKey += PadR( cAuxKey, TafTmSx3(alltrim(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD]),aTamSx3) )
				else
					cKey += PadR( cAuxKey , ;
					TamSX3( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1] )
				endif
			Else
				//Tratamento para que quando o campo seja numerico e faca parte da chave seja alterado o valor de
				//"," para "." para que o Seek nao falhe duplicando as informações.
				If aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
					cAuxKey := StrTran( aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) ], ",", "." )
				Else
					cAuxKey := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_SOURCE]) ]
				EndIf
				if lTafX3
					cKey += PadR( cAuxKey, TafTmSx3(alltrim(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD]),aTamSx3) )
				else
					cKey += PadR( cAuxKey  , ;
					TamSX3( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1] )
				endif
			EndIf
		EndIf
	EndIf
Else
	/*
		O campo C1G_ESOCIA foi criado para identificar se o registro é do eSocial ou Reinf.
		Juntamente com o campo, foi criado o índice 12 ( SIX ) para auxiliar no seek de acordo com a obrigação.
		O campo não foi colocado no taflayout porque apenas o Taf Fiscal utiliza o layout para integração,
		logo não há necessidade dessa informação vim pela integração.
		Tratativas para que a lógica abaixo funcione realizadas em:
		- TAFlayout.prw ( XZ1_ORDER do layout T001AB )
		- TAFLoadLay() -> tratamento para XZ1_ORDER
	*/
	If ( aLayout[nFather][Z1_LAYOUT] == "TAFA051" ) .and. ( aFldsIndex[nI] == "C1G_ESOCIA" )
		if lTafX3
			cKey += padr( "", TafTmSx3(alltrim(aFldsIndex[nI]),aTamSx3) )
		else
			cKey += padr( "", TamSX3( aFldsIndex[nI] )[1] )
		endif
	EndIf
EndIf

Next nI

Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExpChv
Cria arquivo CSV com os indices das tabelas (PAI) do MILE

@Author Evandro dos Santos Oliveira

@since 06/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFExpChv()

Local cLayOut    	:= ""
Local cLine      	:= ""
Local cFldsIndex 	:= ""
Local cCpoAlias  	:= ""
Local cString    	:= ""

Local aLayFath   	:= {}
Local aFldsIndex 	:= {}
Local aNotExis   	:= {}
Local nPosAux		:= 0
Local nY			:= 0
Local nX			:= 0
aLayDel := {}

If File(GetSrvProfString("Startpath","")+"LAYOUT.DEF")

	FT_FUSE("LAYOUT.DEF")
	FT_FGotop()

	While (!FT_FEof())

		cLine := AllTrim(Upper(FT_FREADLN()))

		If Substr(cLine,1,10) == "XZ1_LAYOUT"
			aAdd(aLayFath,{Substr(cLine,12,8),"","","","","","",""})
			cLayOut := Substr(cLine,12,8)
			TAFConout( "***********" + 	cLayOut,2,.F.,"INTEG" )

 		ElseIf Substr(cLine,1,8) == "XZ1_DESC"
			aLayFath[Len(aLayFath)][Z1_DESC]  := Substr(cLine,10,50)
		ElseIf Substr(cLine,1,9) == "XZ1_ADAPT"
			aLayFath[Len(aLayFath)][Z1_ADAPT] := Substr(cLine,11,10)
		ElseIf Substr(cLine,1,9) == "XZ1_TABLE"
			aLayFath[Len(aLayFath)][Z1_TABLE] := Substr(cLine,11,3)
		ElseIf Substr(cLine,1,10) == "XZ1_DESTAB"
			aLayFath[Len(aLayFath)][Z1_DESTAB]:= Substr(cLine,12,40)
		ElseIf Substr(cLine,1,9) == "XZ1_ORDER"
			/*
				Retirado Substr(cLine,11,1) por causa do novo índice ( SIX ) criado pelo eSocial para o layout T001AB -> ordem 12
				@see TAFLayout.prw -> layout T001AB
			*/
			aLayFath[Len(aLayFath)][Z1_ORDER] := Substr(cLine,11)
		ElseIf Substr(cLine,1,10) == "XZ1_MVCOPT"
			aLayFath[Len(aLayFath)][Z1_MVCOPT]:= Substr(cLine,12,1)
		ElseIf Substr(cLine,1,10) == "XZ1_MVCMET"
			aLayFath[Len(aLayFath)][Z1_MVCMET]:= Substr(cLine,12,1)
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUse()

	For nX := 1 To Len(aLayFath)

		cCpoAlias := ""

		If AliasInDic(aLayFath[nX][Z1_TABLE])

			dbSelectArea(aLayFath[nX][Z1_TABLE]) //Z1_TABLE = 04
			dbSetOrder(Val(aLayFath[nX][Z1_ORDER]))
			cFldsIndex := (aLayFath[nX][Z1_TABLE])->(IndexKey())

			cFldsIndex := StrTran( cFldsIndex , "DTOS(" , "" )
			cFldsIndex := StrTran( cFldsIndex , "STR("  , "" )
			cFldsIndex := StrTran( cFldsIndex , ")"     , "" )
			aFldsIndex := TafStr2Arr( cFldsIndex , "+" )

			cString += "Layout: " + aLayFath[nX][Z1_DESC] + ";" + "Tabela: " + aLayFath[nX][Z1_TABLE] + CRLF

			For nY := 1 To Len(aFldsIndex)
				aFldsIndex[nY] := IIf((nPosAux := AT(",",aFldsIndex[nY])) > 0,Substr(aFldsIndex[nY],1,nPosAux-1),aFldsIndex[nY])
				cString +=  "Campo: " + aFldsIndex[nY] + ";" + "Descrição: " + GetSx3Cache(aFldsIndex[nY],"X3_DESCRIC") + CRLF
			Next nY

			cString += CRLF + CRLF

		Else
			aAdd(aNotExis,"Layout: " + aLayFath[nX][Z1_DESC] + ";"+ "Tabela: " + aLayFath[nX][Z1_TABLE])
		EndIf

	Next nX

EndIf

cString += Replicate("*",40) + CRLF
cString += "Tabelas/Layouts não encontrados" + CRLF + CRLF

For nX := 1 To Len(aNotExis)
	cString += aNotExis[nX]+ CRLF
Next nX

MemoWrite(GetSrvProfString("Startpath","") + "Layouts.csv", cString )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFProcLine
Funcao para encapsular as funcionalidados do processamento de uma linha TXT a ser processada.

Realiza as mesmas acoes dentro do proc2, processamento foi apenas isolado. Para que possamos chamar
diretamente de dentro dos livros fiscais ou de motor de integracao arquivo texto.

Basta passar a linha a ser processada para realizacao da integracao.


Possui atualmente três métodos de integração, sendo eles:
	1 - Alteração direta: Utilizado para os layouts que não possuem relacionamento de tabelas, ou seja,
		não possuem hierarquia entre entidades como pai e filho; pai, filho e neto, etc.
		Neste caso, quando uma informação estiver sendo reintegrada, os dados dos campos apenas serão
		alterados.
	2 - Excluir/Incluir: Utilizado para os layouts que possuem hierarquia entre entidades, com dois ou
		mais níveis como pai e filho; pai, filho e neto, etc.
		Neste caso, quando uma informação estiver sendo reintegrada, toda a hierarquia a partir do segundo
		nível terá todos os seus registros excluídos da base de dados e incluídos novamente. O registro "pai" ( primeiro
		nível ) terá os campos apenas alterados.
	3 - Exclusão Parcial / Inclusão: Utilizado para os layouts que possuem hierarquia entre entidades, com dois ou
		mais níveis como pai e filho; pai, filho e neto, etc.
		Este método consiste em excluir apenas os registros que façam parte de uma chave específica para uma tabela
		de segundo nível ( ou maior ), no caso de existência desta chave na base. O registro "pai" ( primeiro
		nível ) terá os campos apenas alterados.

@param lNative		= Define se a rotina foi chamada atraves de integração nativa ou não - Default .F. - Banco-a-banco
@param cST2Alias	= Alias - para modelo banco a banco
@param cFilRegInt	= Filial do registro a ser integrado
@param aDadosST2	= Array com dados a processar
@param aRecInt		= Array contendo os recnos integrados
@param aRecErr		= Array contendo os recnos com erros
@param aErrChav		= Array contendo registros onde a chave não foi encontrada na base de dados durante uma tentativa
				  	  de exclusão ( T999 )
@param aErrIntr		= Array contendo registros onde o layout enviado não foi encontrado no layout TOTVS durante uma tentativa
				  	  de exclusão ( T999 )
@param aIncons		= Array de inconsistencias
@param cLayInteg	= Layout que está sendo integrado, utilizado somente na integração nativa.
@param cXERPAlias	= Alias da tabela TAFXERP
		lTafErrorLog = Controle de error log para tratamento nas MTs
		aLayout    - Array ja populado com o layout de carga das informações
		aLaydel    - Array ja populado com o layout de exclusao das informações

@obs Luccas ( 31/03/2016 ): Devido a mudança em relação ao compartilhamento das tabelas
do TAF ( inicialmente todas eram exclusivas, mas o cliente pode optar por ter tabelas
compartilhadas, por exemplo Plano de Contas, Centro de Custo, Itens, etc. ), as rotinas
de geração das obrigações e integração tiveram que ser alteradas ( em algumas situações ) para a
utilização da função xFilial ao invés da variável cFilSel.
Em relação as integrações, essa alteração foi feita na função FTAFGetFil().

@author Demetrio Fontes De Los Rios

@since 20/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFProcLine(lNative,cST2Alias,cFilRegInt,aDadosST2,aRecInt,aRecErr,aErrChav,aErrIntr,aIncons,cLayInteg,cXERPAlias,lProcMt,lTafErrorLog,aLayout,aLaydel,aTabInd,aTamSx3,lDelChild, aCpoObrig)

Local nChlST2		 := 0 			// Variavel contador
Local nChanel   	 := 0			// Numero do Canal
Local nFoundCpo 	 := 0			// Verifica a existencia do campo
Local nFather		 := 0			// Variavel para identificar a posicao do registro pai no aLayout
Local nFldLayOut	 := 0			// Variavel de controle
Local nI 			 := 0 			// Variavel de controle
Local nX 			 := 0			// Variavel de controle
Local nSource		 := 0			// Variavel de controle
Local nDel 			 := 0 			// Variavel de controle

Local nLayDel   	 := 0			// Variavel de controle layout  a ser deletado
Local nPosCpo   	 := 0			// Variavel de controle do campo a ser integrado
Local nIndex		 := 0
Local nRecnoXERP	 := 0			// Recno do Registro Pai para gravação na tabela TAFXERP
Local lNewReg    	 := .F.			// Tratamento para registros especificos "|C4L|C6M|"
Local lRet 			 := .F. 		// Retorno - Variavel de retorno.
Local cExec      	 := ""			// Tratamento para registros especificos "|C4L|C6M|"
Local cIDFather  	 := ""			// Id do registro Pai
Local cVersao		 :=	""			// Versão do Registro Pai
Local cCpoAlias  	 := ""			// Alias da tabela a ser gravada
Local cCpoName   	 := ""			// Campo a ser gravado
Local cCpoType   	 := ""			// Tipo do dado
Local cFldsIndex 	 := ""			// Indice da tabela a ser gravada
Local cKey       	 := ""			// Chave do registro
Local cConteudo  	 := ""			// Informacao/conteudo após execução da macro.
Local cCHVorID   	 := ""			// Informações do campo Chave ou _ID
Local cFilialDel 	 := ""			// Filial da exclusao dos registros
Local cKeyDel    	 := ""			// Chave do registro à excluir
Local cAliasDel  	 := ""			// Alias do registro de exclusao
Local _cRegFil		 := ""			// Filial do registro a ser gravado - Retorno da TafFil()
Local cAuxKey     	 := ""			// Variavel de auxilio
Local cTabDel		 := ""
Local cChavDel		 := ""
Local cMsgExcl		 := ""
Local cFather		 := ""
Local cChanel		 := ""
Local cAliasXERP	 := ""			// Alias do Registro Pai para gravação na tabela TAFXERP
Local cOper			 := ""
Local cCodAlt        := ""			// Código para controlar registros "inalterados"
Local cAutSeq    	 := "000"		// Variavel de controle de sequencial
Local cSeqErro  	 := "0000"		// Variavel de contrle sequencial de codigos de erro
Local aRelation		 := {} 			// Relação entre os registros

Local aCmpUnq		 := {}			// Array que guarda as chaves unicas das tabelas filhas, sob-demanda.
Local aAreaBkp		 := {}
Local aAreaXERP		 := {}
Local lDel			 := .F.
Local lErroInt		 := .F.
Local lT999			 := .F.

//Variáveis para controle de erro na gravação no TafGrvDados
Local cErroGrv		 := ""
Local nSeqErrGrv	 := 0
Local lErroGrv		 := .F.

//Variáveis para controle do Método 3 de Integração
Local cAliasAnt		 :=	""
Local cChvAnt		 :=	""
Local nMtd3Order	 :=	0
local lLock 		 := .F.
local bTafError 	 := nil

//Variáveis para controle de tratamentos específicos da C1E/Reinf
Local aDelCRM		 := {}
Local lDelProcID	 := .F.
Local lDelCRM		 := .T.
Local lDelCUW		 := .T.
Local nLenST2Dad	 :=	0
Local cQuery		 := ""	
Local cTmpC20Al		 := ""	
Local lAchouCanc	 := .F.
Local nIniCpo		 := 1
Local nTamSXC20	 	 := 0

Default aDadosST2 	 := {} 			// Array com dados a processar
Default aRecInt		 := {} 			// Array contendo os recnos integrados
Default aRecErr		 := {} 			// Array contendo os recnos com erros
Default aErrChav     := {}
Default aErrIntr     := {}
Default aIncons      := {}
Default aTabInd		 := {}
Default lNative		 := .F. 		// Define o modelo de integração - .T. - Nativo Protheus / .F. - Banco-a-banco
Default lTafErrorLog := .F.
Default lProcMt      := .F.
Default lDelChild    := .T.
Default cST2Alias	 := ""			// Alias da tabela compartilhada
Default cFilRegInt	 := FWCodFil()	// Filial do registro a ser integrado
Default cLayInteg	 := ""			// Layout que está sendo integrado, utilizado somente na integração nativa.
Default aTamSx3      := {}
Default aCpoObrig	 := {}

Private cIndOpe      := ""   		// Utilizada no modelo TAFA062E/S

if lProcMt
	bTafError := ErrorBlock( { |Obj| FErrorTaf( Obj, @lTafErrorLog, 'TAFProcLine' ) } ) //Tratamento para quando ocorre error log
endif

//------------------------------------------------------------------------
//Varre todos os canais (Registros Pai e Filhos) obtidos acima no
//array aDadosST2 e sincroniza com o LayOut TOTVS contido no
//array aLayOut para a gravacao dos conteudos nas tabelas do TAF

nLenST2Dad	:= Len(aDadosST2)

For nChlST2 := 1 To nLenST2Dad

	lLock := .F.
	lAchouCanc	 := .F.
	lT999	:= (AllTrim( aDadosST2[nChlST2][1] ) == "T999")

	If nChlST2 == 1 // Define a posicao do registro Pai
		// Demetrio - Alterado para sempre considerar a primeira posição o Pai

		cFather := IIf (  lT999 ,AllTrim( aDadosST2[1][2]),AllTrim( aDadosST2[1][1] ))
		nFather := aScan( aLayOut , {|x| AllTrim( Substr( x[Z1_DESC] ,1 , AT( "-" , x[Z1_DESC] )-1 ) ) == cFather } )

		If nFather > 0
			cAliasXERP := aLayOut[nFather,Z1_TABLE]
		Endif
	EndIf

	//Devo prosseguir apenas se o layout do pai foi carregado corretamente
	If nFather > 0

		// Demetrio - Alterado para sempre considerar a primeira posição o Pai
		cChanel := IIf ( lT999 ,AllTrim( aDadosST2[nChlST2][2]),AllTrim( aDadosST2[nChlST2][1] ))
		nChanel := aScan( aLayOut[nFather][Z1_CHANELS] , {|x| AllTrim(x[Z2_CHANEL])== cChanel  } )

		If lT999

			if aLayout[nFather][Z1_LAYOUT] != "TAFA050"
				cTabDel  := aLayOut[nFather][Z1_TABLE]
				cChavDel := TAFGetInd( nFather , nChanel , aDadosST2 , cFilRegInt , nChlST2 , @aIncons , cTabDel , lNative, /*9*/ ,aLayout, aTamSx3 )
				aAreaBkp := GetArea()
				lLock := lDel := TAFDelRegs(/*1*/,/*2*/,@cMsgExcl, nFather, cChavDel,/*6*/, @aErrChav, @aErrIntr, lNative, cXERPAlias, aLayout,cST2Alias, lT999, aTamSx3 )
				RestArea(aAreaBkp)
				cOper := "1"
			else
				TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000001" )
			EndIf
			exit

		Else

			If Len(aLayOut[nFather][Z1_CHANELS][nChanel]) == 8 // Somente se Houver Campos no layout


				cCpoAlias  := Substr(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][1][Z4_FIELD],1,3)

				//----------------------------------------------------------------------------------------------------------------------------
				//Para os registros F130/F525/F150 do Sped Contribuições a chave exigida inclui campo de descricao ( Descricao Complementar)
				//como temos limitação no tamanho do indice para criacao, nestes registros sera realizada a exclusao dos eventos do periodo
				//e Re-Incluidos
				lNewReg := .F.
				If cCpoAlias $ ( "|C4L|C6M|" )

					//Garanto que apenas na primeira ocorrencia de cada registro realizo a exclusao das informacoes
					If  (  ( cCpoAlias == "C4L" .And. !( ( cCpoAlias + aDadosST2[nChlST2][2] ) $ cExec   ) ) .Or. ;
							( cCpoAlias == "C6M" .And. !( ( cCpoAlias + aDadosST2[nChlST2][2] ) $ cExec   ) ) )

						cExec += ( cCpoAlias + aDadosST2[nChlST2][2] )

						If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
							cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
						EndIf
						cFilChvUnq := IIf( cCpoAlias == "C1E" , cXFilC1E , FTafGetFil( cFilRegInt , @aIncons , cCpoAlias ) )
						FExcRegInt( cCpoAlias, cFilChvUnq, aDadosST2[nChlST2] )
					EndIf

					lNewReg := .T. //Seto esta variavel para .T. garantindo que o registro sera incluido sem tratamento do Seek de chave unica
				EndIf

				//Definicao do indice TAF correspondente ao Layout. E' necessario organizar o conteudo
				//do array aDadosST2 conforme o indice utilizado no registro Pai para iniciar o processo
				//de gravacao (dbSeeks para Inclusao, Alteracao e exclusao)
				If nChlST2 == 1
					cKey	:=	TAFGetInd( nFather , nChanel , aDadosST2 , cFilRegInt , nChlST2 , @aIncons , cCpoAlias,/*8*/,/*9*/, aLayout, aTamSx3 )
				EndIf

			EndIf

			// 1 - Na integração nativa não deve realizar o tratamento abaixo pois não utiliza-se o Ticket
			// 2 - Quando a chave existir no TAF, mesmo que o TAFKEY já foi integrado previamente, deve-se
			//     seguir o fluxo padrão de alteração, para não perder a referência do ID dos registros
			If !lNative .and. nChlST2 == 1
				If ( cXERPAlias )->( MsSeek( ( cST2Alias )->( TAFKEY ) ) )
			 		If !( ( cCpoAlias )->( MsSeek( cKey ) ) )
						lDel := TAFExcKey( cXERPAlias, AllTrim( ( cST2Alias )->( TAFTPREG ) ), aLayout, AllTrim( ( cST2Alias )->( TAFFIL ) ) )
					EndIf
				EndIf
			EndIf

			// --------------------------------------------------------------
			//³Inicio da rotina de gravacao do conteudo do array aDadosST2³
			//³nas tabelas do TAF.      Inclusao / Alteracao              ³

			If aLayOut[nFather][Z1_MVCOPT] == "2"

				Begin Transaction
					// --------------------------------------------------------------
					//³Modo de Gravacao - Alteracao Direta.³
					// --------------------------------------------------------------
					If aLayOut[nFather][Z1_MVCMET] == "1" .And. nChlST2 == 1

						If ( cCpoAlias )->( MsSeek( cKey ) ) .or. SeekAux( nFather, nChanel, aDadosST2, cFilRegInt, nChlST2, @aIncons, cCpoAlias, aLayout )

							cOper := "2" //Status 2 - Registro Alterado ( TAFXERP )
							lLock := FTafExisLock(cCpoAlias,.F.,.T.)
							if lLock
								//reset do status para casos de alteração e inclusão, só no caso de encontrar o registro acima
								(aLayOut[nFather][Z1_TABLE])->&(aLayOut[nFather][Z1_TABLE]+'_STATUS') :=''
								aAreaXERP := GetArea()
							else
								DisarmTransaction()
							endif

						Else

							cOper := "1" //Status 1 - Registro Incluído ( TAFXERP )
							//o GetSX8Num fica fora do Reclock pois estava desposicionando a tabela a ser gravada
							//cID := GetSX8Num( (cCpoAlias) , cCpoAlias+"_ID" )

							//					Geração do ID do registro. 					 //
							//No caso de algumas tabelas ele deve gerar o ID no novo formato //

							cCHVorID := IIf( aLayOut[nFather][Z1_TABLE] == "C20" , "_CHVNF" , "_ID" )

							If GetSx3Cache(cCpoAlias+cCHVorID,"X3_TAMANHO") == 36  .Or. GetSx3Cache(cCpoAlias+cCHVorID,"X3_GRPSXG") == "085"
								cID := TAFGeraID( "TAF" )
							Else
								If !aLayOut[nFather][Z1_TABLE] $ "T93|T94|"
									If cCpoAlias == "C20"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,4)
									Elseif cCpoAlias == "C0Q"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,4)
									ElseIf cCpoAlias == "C1P"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
									ElseIf cCpoAlias == "C3R"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
									ElseIf cCpoAlias == "C2S"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
									Elseif cCpoAlias == "C3J"
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
									Else
										cID := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID )
									Endif
								EndIf
							EndIf

							lLock := FTafExisLock(cCpoAlias,.T.,.T.)
							if lLock
								(cCpoAlias)->(ConfirmSX8())
								(cCpoAlias)->&(cCpoAlias+"_FILIAL"):= FTafGetFil( cFilRegInt , @aIncons , cCpoAlias )
								(cCpoAlias)->&(cCpoAlias+"_ID")    := cID
								aAreaXERP := GetArea()
							else
								DisarmTransaction()
							endif
						EndIf

					EndIf

					// --------------------------------------------------------------
					//³Modo de Gravacao - Excluir / Incluir³
					// --------------------------------------------------------------
					If aLayOut[nFather][Z1_MVCMET] == "2"     

						If nChlST2 == 1

							//dbSelectArea(cCpoAlias)
							//dbSetOrder(Val(aLayOut[nFather][Z1_ORDER]))

							/*A nota fiscal pode ser excluida do ERP, quando isso acontece o extrator fiscal gera um registro com o conteudo do campo C20_CODSIT diferente do que esta integrado no TAF.	||
							||Por este campo fazer parte da chave ( C20->DbSetOrder(1) ), a nota já existente no TAF não é alterada e é incluida uma nova nota cancelada.									||
							||Para evitar isso, foi feito o tratamento abaixo para que retira o campo C20_CODSIT da chave gerada para realizar o Seek, alterando assim a nota ja existente.					*/
							If cCpoAlias = "C20" 
								If !Empty(aDadosST2[1][56]) //posição 56 - Data de cancelamento
									cTmpC20Al := "ALIASC20TP"
									If __oQryC20 == nil
										cQuery := " SELECT "
										cQuery += " R_E_C_N_O_ RECNO "
										cQuery += " FROM " + RetSQLName("C20")
										cQuery += " WHERE "
										cQuery += " C20_FILIAL = ? AND " 
										cQuery += " C20_CODMOD = ? AND "
										cQuery += " C20_INDOPE = ? AND "
										cQuery += " C20_TPDOC = ? AND "
										cQuery += " C20_INDEMI = ? AND "
										cQuery += " C20_CODPAR = ? AND "
										cQuery += " C20_SERIE = ? AND "
										cQuery += " C20_SUBSER = ? AND "
										cQuery += " C20_NUMDOC = ? AND "
										cQuery += " C20_DTDOC = ? AND "
										cQuery += " C20_DTES = ? AND "
										cQuery += " D_E_L_E_T_ = ' ' "
										cQuery := ChangeQuery(cQuery)

										__oQryC20 := FWPreparedStatement():New(cQuery)
									EndIf
									
									nIniCpo := 1
									For nI := 1 to len(__aIndC20)
										nTamSXC20 := IIf( lTafX3, TafTmSx3(__aIndC20[nI], aTamSx3) , TamSX3(__aIndC20[nI])[1] )
										__oQryC20:SetString(nI,Substr(cKey,nIniCpo, nTamSXC20))
										nIniCpo += nTamSXC20
									Next nI 

									dbUseArea(.T., "TOPCONN", TCGenQry(, , __oQryC20:GetFixQuery()), cTmpC20Al, .F., .T.)
									If 	(cTmpC20Al)->( !Eof() ) 
										(cCpoAlias)->(DBGoTo( (cTmpC20Al)->RECNO) )
										lAchouCanc	 := .T.
									EndIf
									(cTmpC20Al)->( DBCloseArea() ) 
								EndIf
							EndIf

							If ( !lNewReg .and. Iif(!lAchouCanc, ( cCpoAlias )->( MsSeek( cKey ) ), .T.)) .or. SeekAux( nFather, nChanel, aDadosST2, cFilRegInt, nChlST2, @aIncons, cCpoAlias, aLayout )
								cOper := "2" //Status 2 - Registro Alterado ( TAFXERP )

								lLock := FTafExisLock(cCpoAlias,.F.,.T.)
								if lLock
									If cCpoAlias $ "C1E|C1G"
										If (cCpoAlias)->&(cCpoAlias + "_STATUS") $ " |0|1"
											(aLayOut[nFather][Z1_TABLE])->&(aLayOut[nFather][Z1_TABLE]+'_STATUS') :=''
										EndIf
									Else
										//reset do status para casos de alteração e inclusão, só no caso de encontrar o registro acima
										(aLayOut[nFather][Z1_TABLE])->&(aLayOut[nFather][Z1_TABLE]+'_STATUS') :=''
									EndIf

									cCHVorID := IIf( aLayOut[nFather][Z1_TABLE] == "C20" , "_CHVNF" , "_ID" )

									If cCpoAlias == "C1E"
										If aLayout[6][1]=="TAFA050"
											nLayDel := 6
										elseif aLayout[5][1]=="TAFA050"
											nLayDel := 5
										EndIf
										cVersao := C1E->C1E_VERSAO
									Else
										nLayDel := aScan( aLayDel, { |x| AllTrim( x[1] ) == AllTrim( aLayOut[nFather][Z1_CHANELS][nChanel][Z2_CHANEL] ) } )
									EndIf

									// Tratamento Especifico para NF - C20, pois ela difere do padrão _ID
									cIDFather := IIf( aLayOut[nFather][Z1_TABLE] == "C20" , (cCpoAlias)->C20_CHVNF , (cCpoAlias)->&(cCpoAlias+"_ID") )

									//Exceção para tabela CRM - Software House - só será excluída caso tenha sido enviada nesta integração
									If cCpoAlias == "C1E"
										lDelCRM := Iif(aScan( aDadosST2, {|x| AllTrim(x[1]) == "T001AN"}) > 0, .T., .F.)
										lDelCUW	:= Iif(aScan( aDadosST2, {|x| AllTrim(x[1]) == "T001AM"}) > 0, .T., .F.)
									EndIf

									// ----------------------------------------------------------------
									//³Exclui todos os registros das tabelas Filho para nova inclusao.³
									// ----------------------------------------------------------------
									TAFDelChild( nLayDel , cCpoAlias , cFilRegInt , cIDFather , cCHVorID , aIncons, /*7*/,/*8*/,/*9*/, aLayDel, lDelCRM, @aDelCRM, lDelCUW, lDelChild)

									aAreaXERP := GetArea()
								else
									DisarmTransaction()
								endif
							Else

								cOper := "1" //Status 1 - Registro Incluído ( TAFXERP )

								//Quando se tratar do registro T001 devo sempre assumir a filial como compartilhada.
								If cCpoAlias == "C1E"
									If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
										cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
									EndIf
									_cRegFil := cXFilC1E
								Else
									_cRegFil := FTafGetFil( cFilRegInt , @aIncons , cCpoAlias )
								EndIf

								//o GetSX8Num fica fora do Reclock pois estava desposicionando a tabela a ser gravada
								cCHVorID := IIf( aLayOut[nFather][Z1_TABLE] == "C20" , "_CHVNF" , "_ID" )

								//					Geração do ID do registro. 					 //
								//No caso de algumas tabelas ele deve gerar o ID no novo formato //
								If GetSx3Cache(cCpoAlias+cCHVorID,"X3_TAMANHO") == 36  .Or. GetSx3Cache(cCpoAlias+cCHVorID,"X3_GRPSXG") == "085"
									cIDFather := TAFGeraID("TAF")
								Else
									If !aLayOut[nFather][Z1_TABLE] $ "T93|T94|"
										If cCpoAlias == "C20"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,4)
										ElseIf cCpoAlias == "C1P"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
										ElseIf cCpoAlias == "C3R"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
										ElseIf cCpoAlias == "C2S"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
										Elseif cCpoAlias == "C0R"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,6)
										Elseif cCpoAlias == "C3J"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
										Else
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID )
										EndIf
									EndIf
								EndIf

								lLock := FTafExisLock(cCpoAlias,.T.,.T.)
								If lLock
									(cCpoAlias)->&(cCpoAlias+"_FILIAL"):= _cRegFil
									(cCpoAlias)->&(cCpoAlias+cCHVorID) := cIDFather

									(cCpoAlias)->(ConfirmSX8())

									aAreaXERP := GetArea()
								else
									DisarmTransaction()
								EndIf
							EndIf

						Else   // Se for filhos

							cCpoAlias := Substr(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][1][Z4_FIELD],1,3)

							//-----------------------------------------------------------------------------------------------------------------------------------------------------------
							// Chama DBCommit para garantir nada preso na tabela, no caso de processamento em MT não preciso garantir a gravação, a validação foi realizada um passo antes
							////---------------------------------------------------------------------------------------------------------------------------------------------------------
							if !lProcMt
								lErroInt := TAFCOMMIT(cCpoAlias)
							else
								( cCpoAlias )->( ( DBCommit(), MsUnLock() ) )
							endif

							lLock := FTafExisLock(cCpoAlias,.T.,.T.)
							if lLock
								If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
									cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
								EndIf								
								(cCpoAlias)->&(cCpoAlias+"_FILIAL"):= Iif( (nFather == 6 .And. aLayout[6][1]=="TAFA050") .OR. (nFather == 5 .And. aLayout[5][1]=="TAFA050"), cXFilC1E, FTafGetFil( cFilRegInt , @aIncons , cCpoAlias ))
								(cCpoAlias)->&(cCpoAlias+cCHVorID) := cIDFather

								//Exceção utilizada na integração de registros SCP para preenchimento automático dos campos _VERSAO e _ATIVO
								If Len( aLayOut[nFather,Z1_CHANELS] ) >= 4 .and. aLayOut[nFather,Z1_CHANELS,nChanel,Z2_CHANEL] $ "T001AA|T001AM"
									( cCpoAlias )->&( cCpoAlias + "_VERSAO" ) := cVersao
									( cCpoAlias )->&( cCpoAlias + "_ATIVO" ) := "1"
								EndIf

							else
								DisarmTransaction()
							endif

						EndIf

					EndIf

					// ----------------------------------------------------------
					// Método 3 de Integração - Exclusão Parcial / Inclusão
					//
					// Este método consiste em excluir apenas os registros que
					// façam parte de uma chave específica para uma tabela filha,
					// no caso de existência desta chave na base.
					// Apenas a lógica de integração para os filhos foi alterada
					// ----------------------------------------------------------
					If aLayOut[nFather][Z1_MVCMET] == "3"

						If nChlST2 == 1

							If !lNewReg .and. ( cCpoAlias )->( MsSeek( cKey ) )
								cOper := "2" //Status 2 - Registro Alterado ( TAFXERP )

								lLock := FTafExisLock( cCpoAlias, .F.,.T. )
								if lLock
									//reset do status para casos de alteração e inclusão, só no caso de encontrar o registro acima
									(aLayOut[nFather][Z1_TABLE])->&(aLayOut[nFather][Z1_TABLE]+'_STATUS') :=''

									cCHVorID := IIf( aLayOut[nFather][Z1_TABLE] == "C20", "_CHVNF", "_ID" )

									If cCpoAlias == "C1E"
										If aLayout[6][1]=="TAFA050"
											nLayDel := 6
										elseif aLayout[5][1]=="TAFA050"
											nLayDel := 5
										EndIf
									Else
										nLayDel := aScan( aLayDel, { |x| AllTrim( x[1] ) == AllTrim( aLayOut[nFather][Z1_CHANELS][nChanel][Z2_CHANEL] ) } )
									EndIf

									//Tratamento específico para NF - C20, pois ela difere do padrão _ID
									cIDFather := IIf( aLayOut[nFather][Z1_TABLE] == "C20", ( cCpoAlias )->C20_CHVNF, ( cCpoAlias )->&( cCpoAlias + "_ID" ) )

									aAreaXERP := GetArea()
								else
									DisarmTransaction()
								endif
							Else
								cOper := "1" //Status 1 - Registro Incluído ( TAFXERP )

								//Quando se tratar do registro T001 devo sempre assumir a filial como compartilhada
								If cCpoAlias == "C1E"
									If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
										cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
									EndIf
									_cRegFil := cXFilC1E
								Else
									_cRegFil := FTafGetFil( cFilRegInt, @aIncons , cCpoAlias )
								EndIf

								//O GetSX8Num fica fora do RecLock pois estava desposicionando a tabela a ser gravada
								cCHVorID := IIf( aLayOut[nFather][Z1_TABLE] == "C20", "_CHVNF", "_ID" )

								//Geração do ID do registro
								//No caso de algumas tabelas ele deve gerar o ID no novo formato
								If GetSx3Cache(cCpoAlias+cCHVorID,"X3_TAMANHO") == 36  .Or. GetSx3Cache(cCpoAlias+cCHVorID,"X3_GRPSXG") == "085"
									cIDFather := TAFGeraID( "TAF" )
								Else
									If !aLayOut[nFather][Z1_TABLE] $ "T93|T94|"
										If cCpoAlias == "C20"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,4)
										ElseIf cCpoAlias == "C1P"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
										ElseIf cCpoAlias == "C3R"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,3)
										ElseIf cCpoAlias == "C2S"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
										Elseif cCpoAlias == "C3J"
											cIDFather := GetSX8Num( (cCpoAlias) , cCpoAlias + cCHVorID,,2)
										Else
											cIDFather := GetSX8Num( ( cCpoAlias ), cCpoAlias + cCHVorID )
										EndIf
									EndIf
								EndIf

								lLock := FTafExisLock( cCpoAlias, .T., .T. )
								If  lLock
									( cCpoAlias )->&( cCpoAlias + "_FILIAL" ) := _cRegFil
									( cCpoAlias )->&( cCpoAlias + cCHVorID ) := cIDFather
									( cCpoAlias )->( ConfirmSX8() )

									aAreaXERP := GetArea()
								else
									DisarmTransaction()
								EndIf
							EndIf

						Else //Se for filhos

							// ----------------------------------------------------------------
							// Para o Método 3, em caso de alteração, deve-se verificar a
							// existência de informações da chave na tabela filho e excluí-las
							// ----------------------------------------------------------------
							If cOper == "2"

								nMtd3Order := Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_ORDER] )

								cTabDel := aLayOut[nFather][Z1_TABLE]

								// -------------------------------------------------------
								// Busca a chave de acordo com a chave do filho no Layout
								// -------------------------------------------------------
								cChavDel := TAFGetInd( nFather, nChanel, aDadosST2, cFilRegInt, nChlST2, @aIncons, cCpoAlias, lNative, nMtd3Order, aLayout, aTamSx3 )

								// -------------------------------------------------------------------------
								// Verifica se é outra tabela ou se é mesma tabela, mas com chave diferente
								// -------------------------------------------------------------------------
								If cAliasAnt <> cCpoAlias .or. ( cAliasAnt == cCpoAlias .and. cChavDel <> cChvAnt )
									// ------------------------------------------
									// Exclui os registros das tabelas filho que
									// fazem parte da chave para nova inclusão
									// ------------------------------------------
									TAFDelChild( nLayDel, cTabDel, cFilRegInt, cIDFather, cCHVorID, aIncons, nMtd3Order, cChavDel, cCpoAlias, aLaydel,/*11*/,/*12*/,/*13*/,lDelChild)
								EndIf

								nMtd3Order := 0
								cAliasAnt := cCpoAlias
								cChvAnt := cChavDel

							EndIf

							cCpoAlias := SubStr( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][1][Z4_FIELD], 1, 3 )

							//-----------------------------------------------------------------------------------------------------------------------------------------------------------
							// Chama DBCommit para garantir nada preso na tabela, no caso de processamento em MT não preciso garantir a gravação, a validação foi realizada um passo antes
							////---------------------------------------------------------------------------------------------------------------------------------------------------------
							if !lProcmt
								lErroInt := TAFCommit( cCpoAlias )
							else
								( cCpoAlias )->( ( DBCommit(), MsUnLock() ) )
							endif

							lLock := FTafExisLock( cCpoAlias, .T., .T. )
							if lLock
								If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
									cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
								EndIf
								( cCpoAlias )->&( cCpoAlias + "_FILIAL" ) := Iif( nFather ==6, cXFilC1E, FTafGetFil( cFilRegInt, @aIncons , cCpoAlias ) )
								( cCpoAlias )->&( cCpoAlias + cCHVorID ) := cIDFather
							else
								DisarmTransaction()
							endif
						EndIf

					EndIf

					if lLock 
						//Rotina de gravação do conteúdo nas tabelas correspondentes do TAF
						TafGrvDados( aLayout, nFather, nChanel, nFldLayOut, cCpoAlias, nChlST2, @cSeqErro, lNative, aRecInt, aDadosST2, @aRelation, @cAutSeq, @lErroGrv, @cErroGrv, @nSeqErrGrv, aDelCRM, @lDelProcID, @aTabInd, @cCodAlt, aCpoObrig )

						//-----------------------------------------------------------------------------------------------------------------------------------------------------------
						// Chama DBCommit para garantir nada preso na tabela, no caso de processamento em MT não preciso garantir a gravação, a validação foi realizada um passo antes
						//---------------------------------------------------------------------------------------------------------------------------------------------------------
						if !lProcmt
							lErroInt := TAFCommit( cCpoAlias )
						else
							if !lErroGrv
								( cCpoAlias )->( ( DBCommit(), MsUnLock() ) )
							else
								DisarmTransaction()   
							endif 
						endif
 
						//Caso ocorra erro na gravação de dados, exceto erro de 'chave duplicada', deve ser feito rollback das informações
						If lErroGrv .and. !lErroInt .and. !lProcmt  .and. nLenST2Dad == nChlST2 .and. lNative
							DisarmTransaction()
						EndIf
					endif 

				End Transaction

				if  lLock
					//Se ocorreu erro na TAFCommit, nem prossegue com a gravação das informações restantes
					If lErroInt
						TAFExcReg( ,, { { aDadosST2[1,1], aAreaXERP[1], aAreaXERP[3], "1" } }, aLayout, .T. )
						Exit
					EndIf

					if ( lProcmt .and. lErroGrv ) .or. !lLock
						Exit
					endif
				else
					Exit
				endif

			EndIf

		EndIf

		// Tratamento para efetuar controle e trava do registro apenas no modelo banco-a-banco.
		If !lNative
			dbSelectArea(cST2Alias)
		EndIf
	Endif
Next nChlST2

If lErroGrv .and. !lErroInt .and. !lProcmt .and. !lNative
	DisarmTransaction()
EndIf

//Quando se tratar de integração online não executar a regra abaixo
If !lNative
	If !Empty( cAliasXERP )

		If lDel
			cOper := "3"
			if !empty(cMsgExcl)
				cErroGrv := cMsgExcl
			endif
		EndIf

		If Len( aAreaXERP ) > 0
			RestArea( aAreaXERP )
		EndIf

		nRecnoXERP := ( cAliasXERP )->( Recno() )

		//Caso encontre erro na integração grava o ticket com mensagem de inconsistência.
		If lErroInt
			TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,cAliasXERP, nRecnoXERP, "9","000005" )
		ElseIf lErroGrv
			TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000009", cErroGrv )
		Elseif !lLock
			//if (!lDel .and. !empty(cMsgExcl) .and.  ('T999' $ cMsgExcl)) // se ocorreu erro de exclusão de registro via T999, não devo gravar aqui, pouis já foi gravado em TAFDELREGS
			if !lT999
				TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000021", cErroGrv ) //cErroGrv := cMsgExcl
			endif
		Else
			TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET, cAliasXERP, nRecnoXERP, cOper, , , cCodAlt, lDel ) 
		EndIf
	Elseif nFather <= 0
		TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET, , , "9" , "000006" )
	EndIf

Else
	If !Empty(cErroGrv)
		Aadd(aErrIntr,cErroGrv)
	Endif
Endif

//----------------------------------------------------------------------------------------------------------------------------------------------------------
//Somente deve ser tratado o error log quando o processamento ocorrer em MT, caso contrário deve ser abortado o processamento apresentando o erro ao usuário
//----------------------------------------------------------------------------------------------------------------------------------------------------------
if lProcMt
	ErrorBlock( bTafError )
endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDelChild
@Param	nMtd3Order - Índice utilizado no Método 3 de Integração
@Param	cMtd3Chave - Chave utilizado no Método 3 de Integração
@Param	cMtd3Alias - Tabela a ser considerada no Método 3 de Integração
		aLayDel    = Array aLaydel já populado - processamento MT
@Param	lDelCRM    - Indica se o registro na tabela CRM - Software House - deve ser ou não apagado pela função
@Param	aDelCRM    - Guarda os dados da tabela CRM deletados pela função para posterior comparação na função TAFGrvDados, para limpeza do campo C1E_PROCID
@Param	lDelCUW    - Indica se o registro na tabela CUW - Empresa SCP - deve ser ou não apagado pela função

@Author Luccas Curcio
@Since 13/03/2015
@Version 1.0

@Obs	24/02/2016 - Felipe C. Seolin - Aplicação de condições para utilização do Método 3 de Integração
/*/
//-------------------------------------------------------------------
Function TAFDelChild(nLayDel,cCpoAlias,cFilRegInt,cIDFather,cCHVorID,aIncons,nMtd3Order,cMtd3Chave,cMtd3Alias,aLayDel,lDelCRM,aDelCRM,lDelCUW,lDelChild)
Local nDel			:=	0
Local cAliasDel		:=	Nil
Local cFilialDel	:=	Nil
Local cKeyDel		:=	Nil
Local cIndex		:=	""
Local cScript       :=  ""
Local nOrderDel		:=	Nil

//Variáveis para controle de tratamentos específicos da C1E/Reinf
Local aDelCRMLin	:= {}
Local nCposCRM		:= 1
Local nLenCpoCRM	:= 0

Default nLayDel		:=	0
Default nMtd3Order	:=	0
Default cMtd3Chave	:=	""
Default cMtd3Alias	:=	""
Default lDelCRM		:= .T.
Default lDelCUW		:= .T.
Default lDelChild   := .T.

If nLayDel == 0
	TAFLoadLay()
EndIf

For nDel := 1 to Len( aLayDel[nLayDel][2] )
	If aLayDel[nLayDel][2][nDel][2] <> cCpoAlias
		//Exceção para tabela CRM - Software House - só será excluída caso tenha sido enviada nesta integração
		If (!lDelCRM .And. aLayDel[nLayDel][2][nDel][2] == "CRM") .or. (!lDelCUW .And. aLayDel[nLayDel][2][nDel][2] == "CUW")
			Loop
		EndIf
		// Verificação se foi chamado pelo Método 3 de Integração. A verificação é feita a partir da variável nMtd3Order, pois ela
		//deve estar com valor 0 nos demais métodos. Se tratando do Método 3, apenas os registros do Alias passado deve ser excluído.
		If nMtd3Order > 0 .and. aLayDel[nLayDel][2][nDel][2] <> cMtd3Alias
			Loop
		EndIf
		cAliasDel := AllTrim( aLayDel[nLayDel][2][nDel][2] )
		//Quando se tratar do registro T001 devo sempre assumir a filial como compartilhada
		If cCpoAlias == "C1E"
			If cXFilC1E == Nil .or. !Empty(Alltrim(cXFilC1E))
				cXFilC1E := xFilial("C1E") //Se for nulo carrega na primeira vez ou se nao for vazio, significa que eh exclusivo e deve ser sempre carregado.
			EndIf
			cFilialDel := cXFilC1E
		Else
			cFilialDel := FTafGetFil( cFilRegInt, @aIncons , cAliasDel )
		EndIf		
		// Para o Método 3, deve ser considerado Índice e Chave recebidos nas variáveis nMtd3Order e cMtdChave
		If nMtd3Order == 0
			cKeyDel := cFilialDel + cIDFather
			nOrderDel := 1
			If cAliasDel == "C6E" //O índice de busca por ID desta tabela é o 4
				nOrderDel := 4
			ElseIf cAliasDel $ ( "|C3R|C5Z|C3Q|C1J|" )
				nOrderDel := 3
			ElseIf cAliasDel $ ( "|C4J|V48|" )
				nOrderDel := 2
			EndIf
		Else
			nOrderDel := nMtd3Order
			cKeyDel := cFilialDel + cIDFather + cMtd3Chave
		EndIf

		//Se for processo gia sp completo no tafobrig (extrator + tafainteg) nao tem necessidade de fazer seek, apagar/alterar novamente.
		if lDelChild .Or. ( !lDelChild .And. !(cAliasDel $ cC20Child) )
			( cAliasDel )->( DBSetOrder( nOrderDel ) )
			If nMtd3Order == 0
				cIndex := ( cAliasDel )->( cAliasDel + "_FILIAL" ) + "+" + ( cAliasDel )->( cAliasDel + cCHVorID )
			Else
				cIndex := ( cAliasDel )->( IndexKey( nOrderDel ) )
			EndIf
			If ( cAliasDel )->( MsSeek( cKeyDel ) )
				//Mecanismo melhoria performance quando for alteracao de notas sequoia.
				if cAliasDel $ cC20Child //Tabelas filhas da C20 que possuem filial + chvnf em seus indices
					cScript  := "UPDATE " + RetSQLName(cAliasDel) + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "			
					cScript  += "WHERE " + cAliasDel + "_FILIAL = '" + cFilialDel + "' AND " + cAliasDel + "_CHVNF = '" + cIDFather + "' AND D_E_L_E_T_ = ' ' "
					lOk := TcSQLExec( cScript ) >= 0
					If(lOk,.T.,TAFConout( "...:" + AllTrim(TCSQLError()),2,.T.,"INTEG"))
				else
					While ( cAliasDel )->( !Eof() ) .and. ( cAliasDel )->( &( cIndex ) ) == cKeyDel
						If FTafExisLock( cAliasDel, .F.,.T. )
							//Se o layout deletado for da tabela CRM - Software House (filha da tabela C1E - Complemento de Empresa), 
							//será necessario guardar os dados da tabela CRM deletados pela função para posterior comparação na função
							//TAFGrvDados, para avaliação da necessidade de limpeza do campo C1E_PROCID
							If aLayDel[nLayDel][2][nDel][2] == "CRM"
								If aCposR1000 == Nil
									aCposR1000 := TafR1000Cpo()
								EndIf		
								nLenCpoCRM := Len(aCposR1000[2])
								For nCposCRM := 1 to nLenCpoCRM
									If Substring(aCposR1000[2][nCposCRM], 1, 3) == "CRM"
										aAdd(aDelCRMLin, {aCposR1000[2][nCposCRM], &(Substring(aCposR1000[2][nCposCRM], 1, 3) + "->" +  aCposR1000[2][nCposCRM])})
									EndIf
								Next nCposCRM
								aAdd(aDelCRM, aDelCRMLin)
								aDelCRMLin := {}
							EndIf							
							( cAliasDel )->( DBDelete() )
							(cAliasDel)->(MsUnlock())
							//Tratamento para limpar apuracao da CPRB, caso nao esteja transmitido e seja reimportado um arquivo com escopo alteracao\delecao
							TafAtuPrId( cCpoAlias, cAliasDel )
						EndIf
						( cAliasDel )->( DBSkip() )
					EndDo
				endif
			endif
		else
			//TafConout("Nao entrou no update ou laco do tafdelchild")
		endif
	EndIf
Next nDel

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDelRegs
Realiza exclusão com base no arquivo de integração do Layout TOTVS
*Utilizando a chave do registro PAI

@param
cTafMsg			- Registro contendo o arquivo para exclusão
				 *(Utilizado quando a função É chamada fora do TAFAINTEG)
cFilRegInt	 	- Filial para a Integração
				 *(Utilizado quando a função É chamada fora do TAFAINTEG)
cMsg		 	- Mensagem de retorno da exclusão
nFather  		- Indexador do Registro Pai
cChaveDel		- Chave da Exclusão
nRecSt2			- Numero do RecNo do registro
aErrChav		- Array com RecNo dos registros com problemas nas chaves
				  na Exclusão
aErrIntr		- Array com RecNo dos registros com problemas de Integridade
				  na Exclusão
aLayout    = Array aLayout já populado - processamento MT

@Author Evandro dos Santos Oliveira

@since 06/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFDelRegs(cTafMsg,cFilRegInt,cMsg,nFather,cChaveDel,nRecSt2,aErrChav,aErrIntr,lNative, cXERPAlias, aLayout, cST2Alias, lT999, aTamSx3 )

	Local lDel			:= .T.
	Local oModel 		:= ""
	Local cAlias		:= ""
	Local nOrder		:= 0
	Local cKey			:= ""
 	Local cLayout 	:= ""
	Local aErro		:= {}
	Local aInfST2 	:= {}
	Local nChanel 	:= 0
	Local nChlST2 	:= 0
	Local aIncons 	:= {}
	Local cCpoAlias 	:= ""
	Local cModelo		:= ""
	Local lLayOk		:= .T.
	Local lTafInteg	:= .F.
	Local lExcCommit	:=	.f.
	Local nlI := 0

	Private lVldModel := .T.

	Default cTafMsg	:= ""
	Default nFather	:= 1
	Default cFilRegInt	:= ""
	Default aErrChav	:= {}
	Default lNative	:=	.F.
	Default lT999	:=	.F.
	Default cST2Alias	:=	''
	Default aTamSx3 	:= {}

	lTafInteg := IIf (Empty(cTafMsg),.T.,.F.)

	If lTafInteg
		oModel := FWLoadModel(aLayOut[nFather][Z1_LAYOUT])
		cKey := cChaveDel
	Else
		/*+------------------------------------------------------------------------+
		  | As variáveis nChlST2, nFather são 1 por que o aInfST2 deve ser passado |
		  | como um array multidimensional  para a  função TAFGetInd e como o  meu |
		  | aInfST2 sempre terá somente 1 posição eu passo 1 nessas variaveis      |
		  +------------------------------------------------------------------------+*/
		nChlST2 := 1
		aInfST2 := TafStr2Arr(cTafMsg,"|")
		//Apago a primeira posicão por causa do primeiro PIPE
		If Empty(AllTrim(aInfST2[1]))
			aDel(aInfST2,1)
			aSize(aInfST2,Len(aInfST2)-1)
		EndIf
		TAFLoadLay(aInfST2[1])
		If Len(aLayOut) > 0
			nChanel := aScan( aLayOut[nFather][Z1_CHANELS] , {|x| AllTrim(x[Z2_CHANEL])== aInfST2[1] })
			oModel  	:= FWLoadModel(aLayOut[nFather][Z1_LAYOUT])
			cCpoAlias 	:= aLayOut[nFather][Z1_TABLE]
			cKey := TAFGetInd(nFather,nChanel,{aInfST2},cFilRegInt,nChlST2,aIncons,cCpoAlias,/*8*/,/*9*/, aLayout,aTamSx3)
		Else
			lLayOk := .F.
		EndIf
	EndIf

	If lLayOk
		cAlias := aLayOut[nFather][Z1_TABLE]
		nOrder := Val(aLayOut[nFather][Z1_ORDER])

		dbSelectArea(cAlias)
		dbSetOrder(nOrder)
		If (cAlias)->(MsSeek(cKey))

			oModel:SetOperation(5)
			oModel:Activate()

			cModelo := IIf( lTafInteg,oModel:cId,aLayout[nFather][Z1_CHANELS][nChanel][Z3_IDOUT])
			If lT999
				lExcCommit :=  oModel:VldData() // Valida integridade de dados, tabela chave estrangeira que possui vinculo com outra tabela Ex: T003 x T013. T003 só pode ser excluído se não houver nota com o determinado participante
            else
				lExcCommit := oModel:VldData(cModelo,.F.)	// exlcui sem validar integridade de dados.
			EndIf

			If lExcCommit // oModel:VldData(cModelo,.F.)
				If oModel:CommitData()//FWFormCommit()
					cMsg := "Registro excluido com Sucesso"
				Else
					cMsg := "Erro ao Executar o Commit"
				EndIf
			Else

				aErro := oModel:GetErrorMessage()
				cMsg  := AllTrim(aErro[6])

				//apenas retorno o status para a ST2 quando nao se tratar de integracao On Line
				if !lNative
					IIf( lTafInteg , aAdd(aErrIntr,nRecSt2) , )
					TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000004", iif(lT999,cMsg,nil))
				endif

				lDel := .F.

			EndIf

			oModel:DeActivate()

		Else

			//apenas retorno o status para a ST2 quando nao se tratar de integracao On Line
			if !lNative
				IIf( lTafInteg , aAdd(aErrChav,nRecSt2) , )
				if lT999
					cMsg := ("T999 - Exclusão - Chave não encontrada")
				else
					cMsg := ("Exclusão - Chave não encontrada")
				endif
				TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000003",cMsg )
			endif

			if lT999
				cMsg := ("T999 - Exclusão - Chave não encontrada")
			else
				cMsg := ("Exclusão - Chave não encontrada")
			endif

			lDel := .f. // para que não seja gerado mais 1 registro na TAFXERP
		EndIf

	Else
		//apenas retorno o status para a ST2 quando nao se tratar de integracao On Line
		if !lNative
			IIf( lTafInteg , aAdd(aErrChav,nRecSt2) , )
			TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000003" )
		endif
		if lT999
	   		cMsg := "T999 - Exclusão - Layout não encontrado"
		else
			cMsg := "Exclusão - Layout não encontrado"
		endif

	   	lDel := .F.
	EndIf

Return lDel

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGrvDados



@param
@param
@param
@param
@param
@param
@param
@param
@param
@param
@param

@Author Luccas Curcio

@since 13/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFGrvDados( aLayout, nFather, nChanel, nFldLayOut, cCpoAlias, nChlST2, cSeqErro, lNative, aRecInt, aDadosST2, aRelation, cAutSeq, lErroGrv, cErroGrv, nSeqErrGrv, aDelCRM, lDelProcID, aTabInd, cCodAlt, aCpoObrig )

Local cCpoName	 :=	""
Local cConteudo	 :=	""
Local cCpoType	 :=	""
Local cPosLay	 :=	""
Local xAll		 :=	""
Local cEnter	 :=	Chr( 13 ) + Chr( 10 )
Local nSource	 :=	0
Local nPosCpo	 :=	0
Local nPosLay	 :=	0
Local nI		 :=	0
Local nX		 :=	0
Local nSixInd	 :=	0
Local aSource	 :=	{}
Local aCmpUnq	 :=	{}
Local aMessage	 :=	{}
Local lSource	 :=	.F.
Local aAreaNG    := {}
Local cFldsIndex := ""

Local aAreaRf    := {}
Local nContA     := 1
Local nTamTab    := 0
Local nOrdUnq    := 0
Local nPosition  := 0
Local cUnqInt    := ""
Local cArmInf    := ""
Local nIndUnq    := 1
Local lProxInt   := .T.

//Variáveis para controle de tratamentos específicos da C1E/Reinf
Local aOldC1E		:= {}
Local nCposC1E		:= 0
Local nCposCRM		:= 0
Local nContCRM		:= 0
Local nContST2		:= 0
Local nLenCpoC1E 	:= 0
Local nLenDadST2	:= 0
Local nLnCNPJCRM 	:= 0
Local nPsCNPJCRM	:= 0

Default aTabInd    	:= {}
Default aDelCRM		:= {}
Default lDelProcID	:= .F.
Default cCodAlt     := "" 
Default aCpoObrig	:= {}

nTamTab := Len( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS] )

//Leiautes Utilizados no Reinf
//cCpoAlias $ ("C1E|C1G|C0R|C3Q|C3R|CRM|C1H|C1J|C1L|C1N|C1O|C1P|C20|C5M|LEM|T9C|V3U|V3X|V4F|V3Z|V4K|V4A|V4B")

if cCpoAlias == "LEM"
	nOrdUnq := aScan(aTabInd ,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(cCpoAlias))})
	if nOrdUnq > 0
		//Protecao caso aplique o pacote mas nao envie o pipe correspondente ao novo campo
		nPosition := Val(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][aTabInd[nOrdUnq][2]][Z4_SOURCE])
		if Len(aDadosST2[nChlST2]) >= nPosition
			//Protecao se nao houver conteudo
			cArmInf := aDadosST2[nChlST2][nPosition]
			if Valtype(cArmInf) == "C"
				cUnqInt := Upper(cArmInf)
			endif
		endif
	else
		For nContA := 1 To nTamTab
			if "_UNQINT" $ (aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nContA][2])
				aadd(aTabInd,{cCpoAlias,nContA})
				//Protecao caso aplique o pacote mas nao envie o pipe correspondente ao novo campo
				nPosition := Val(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nContA][Z4_SOURCE])
				if Len(aDadosST2[nChlST2]) >= nPosition
					cArmInf := aDadosST2[nChlST2][nPosition]
					//Protecao se nao houver conteudo
					if Valtype(cArmInf) == "C"
						cUnqInt := Upper(cArmInf)
						Exit
					endif
				endif
			EndIf
		next nContA
	endif

	if !empty(cUnqInt)
		aAreaRf := (cCpoAlias)->(GetArea())
		nIndUnq := RetOrder(cCpoAlias ,cCpoAlias + "_FILIAL" + "+" + cCpoAlias + "_UNQINT")
		(cCpoAlias)->(DbSetOrder(nIndUnq))	
		if (cCpoAlias)->(DbSeek(xFilial(cCpoAlias)+cUnqInt))
			lProxInt := .F.
			cCodAlt  := "6" //Registro Inalterado		
		else
			cCodAlt := ""
		endif
		RestArea(aAreaRf)
	endif
endif

if lProxInt
	
	// --------------------------------------------------------------------
	//³Rotina de Gravacao do conteudo nas tabelas correspondentes do TAF³
	// --------------------------------------------------------------------
	For nFldLayOut := 1 To nTamTab

		//Não realizo a gravação/alteração para o campo C1E_CODFIL, para evitar que o conteúdo de/para cadastrado na CR9 sobreponha o conteúdo do campo C1E_CODFIL
		If ( cCpoName := aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_FIELD] ) <> "C1E_CODFIL"

			//Variável que identifica se o campo do layout foi encontrado no array aDadosST2.
			//Utilizado para verificar se deve-se aplicar mensagens de erros de integração ( apenas em caso positivo )
			lSource := .F.

			If At( ";", aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) > 0

				If !Empty(aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC])

					aSource := TafStr2Arr( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE], ";" )

					For nX := 1 to Len( aSource )
						If Len( aDadosST2[nChlST2] ) >= Val( aSource[nX] )
							lSource := .T.
							Exit
						EndIf
					Next nX

					If lSource

						xA := "";xB := "";xC := "";xD := "";xE := ""
						xF := "";xG := "";xH := "";xI := "";xJ := ""

						aMessage := Array( Len( aSource ), 3 )

						For nSource := 1 to Len( aSource )

							aMessage[nSource,1] := AllTrim( Str( Val( aSource[nSource] ) ) )

							If ( nPosLay := aScan( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS], { |x| x[Z4_SOURCE] == aSource[nSource] } ) ) > 0
								aMessage[nSource,2] := aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nPosLay][Z4_FIELD]
							Else
								aMessage[nSource,2] := cCpoName
							EndIf

							//Tratamento para não ocorrer erro quando existir mais
							//campos no Layout do que nos dados enviados para integração
							If Len( aDadosST2[nChlST2] ) >= Val( aSource[nSource] )
								If nSource == 1
									xA := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 2
									xB := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 3
									xC := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 4
									xD := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 5
									xE := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 6
									xF := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 7
									xG := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 8
									xH := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 9
									xI := aDadosST2[nChlST2][Val( aSource[nSource] )]
								ElseIf nSource == 10
									xJ := aDadosST2[nChlST2][Val( aSource[nSource] )]
								EndIf

								aMessage[nSource,3] := aDadosST2[nChlST2][Val( aSource[nSource] )]
							EndIf

						Next nSource

						xAll :=	Iif( Type( "xA" ) <> "U" .and. !Empty( xA ), xA, "" ) +;
									Iif( Type( "xB" ) <> "U" .and. !Empty( xB ), xB, "" ) +;
									Iif( Type( "xC" ) <> "U" .and. !Empty( xC ), xC, "" ) +;
									Iif( Type( "xD" ) <> "U" .and. !Empty( xD ), xD, "" ) +;
									Iif( Type( "xE" ) <> "U" .and. !Empty( xE ), xE, "" ) +;
									Iif( Type( "xF" ) <> "U" .and. !Empty( xF ), xF, "" ) +;
									Iif( Type( "xG" ) <> "U" .and. !Empty( xG ), xG, "" ) +;
									Iif( Type( "xH" ) <> "U" .and. !Empty( xH ), xH, "" ) +;
									Iif( Type( "xI" ) <> "U" .and. !Empty( xI ), xI, "" ) +;
									Iif( Type( "xJ" ) <> "U" .and. !Empty( xJ ), xJ, "" )

						If !('#NAOGRAVAR#' $ UPPER(xAll))
							cConteudo := &( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] )
						Else
							Loop
						EndIf

						If AllTrim( cConteudo ) == "VAZIO"
							cConteudo := ""
						EndIf

						// tratamento específico para layout T164 Reinf 2.0 Bloco 40 							
						if Alltrim(cCpoAlias) == "V4B" .and. cCpoName == "V4B_CODDEP" .and. empty(cConteudo) .and. !empty(xA)
							cErroGrv += "Não existe um dependente código "+  xA + " (coluna 6) vinculado ao participanete " + xB + " (coluna 5) na base de dados."
							lErroGrv := .T.
							cSeqErro := Soma1( cSeqErro, 4 ) 
							cConteudo := "ER" + cSeqErro
						endif				
						
						//Novo modelo de integração consiste em barrar campos chave e obrigatórios em
						//branco e campos com consulta padrão que não são encontrados na base de dados
						If ( "XFUNCH2ID" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNSPCMIL" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNCD2ID" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNVLDMEM" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) );
							.and. !Empty( xAll ) .and. Empty( cConteudo ) .and. !Empty( xA )

							If lTafMInc
								TAFMsgIncons( @cErroGrv, @nSeqErrGrv, nChlST2, aMessage )

							Else
								If Len( cErroGrv ) <= TAMMAXXML
									If !Empty( cErroGrv )
										cErroGrv += cEnter + cEnter
									EndIf

									nSeqErrGrv += 1
									cErroGrv += "Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + cEnter

									For nI := 1 to Len( aMessage )
										If nI == 1
											cErroGrv += "O valor '" + AllTrim( aMessage[nI,3] ) + "'"
										Else
											cErroGrv += " somado ao valor '" + AllTrim( aMessage[nI,3] ) + "'"
										EndIf

										cErroGrv += " informado na coluna " + AllTrim( aMessage[nI,1] )
										cErroGrv += " para o campo " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( aMessage[nI,2] ) ) ), X3Descric() } ) ) + " ( " + AllTrim( aMessage[nI,2] ) + " )"
									Next nI

									cErroGrv += " não existe na base de dados."

								EndIf
							EndIf

							lErroGrv := .T.

							// ----------------------------------------------------------------------------------
							// 15/03/2016 - Felipe C. Seolin
							// Grava código "ERXXXX" para as situações onde a informação:
							// - Faz parte da chave
							// - O envio do registro é feito mas ele não existe na base de dados ou o envio do
							//   registro não é feito
							// Tem o objetivo de burlar o processo de 'chave duplicada' na integração para
							// tratar o erro da maneira correta.
							// Em outro processo a frente, este registro será barrado na gravação dos dados.
							// Não esquecer de passar o parâmetro aCmpUnq com @ para que as informações
							// sejam cacheadas.
							// ----------------------------------------------------------------------------------
							If xTAFCmpUnq( @aCmpUnq, cCpoAlias, cCpoName,,aCpoObrig )
								cSeqErro := Soma1( cSeqErro, 4 )
								cConteudo := "ER" + cSeqErro
							EndIf
						EndIf
					Else
						cConteudo := ""
					EndIf
				Else
					//Tratamento para não ocorrer erro quando existir mais
					//campos no Layout do que nos dados enviados para integração
					If Len( aDadosST2[nChlST2] ) >= Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] )
						lSource := .T.

						cConteudo := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE]) ]
						If UPPER(AllTrim(cConteudo)) == "#NAOGRAVAR#"
							aAreaNG := GetArea()
							dbSelectArea(cCpoAlias)
							DBSetOrder( Val( aLayOut[nFather][Z1_ORDER] ) )
							cFldsIndex := ( cCpoAlias )->( IndexKey() )
							RestArea(aAreaNG)

							If (cCpoName$cFldsIndex)
								If !Empty( cErroGrv )
									cErroGrv += cEnter + cEnter
								EndIf

								cPosLay := AllTrim( Str( Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ) )

								nSeqErrGrv += 1
								cErroGrv +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + " - Coluna: " + cPosLay + cEnter +;
												"Campo pertence a chave de negócio. Não é permitido utilizar a tag '#NAOGRAVAR#': " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( cCpoName ) ) ), X3Descric() } ) ) + " ( " + AllTrim( cCpoName ) + " )."

								lErroGrv := .T.
								cSeqErro := Soma1( cSeqErro, 4 )
								cConteudo := "ER" + cSeqErro
							Else
								Loop
							EndIf
						EndIf
					Else
						cConteudo := ""
					EndIf

				EndIf

			Else

				If !Empty( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] )

					//Tratamento para não ocorrer erro quando existir mais
					//campos no Layout do que nos dados enviados para integração
					If Len( aDadosST2[nChlST2] ) >= Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] )

						lSource := .T.

						aMessage := Array( 1, 3 )
						aMessage[1,1] := AllTrim( Str( Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ) )
						aMessage[1,2] := aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_FIELD]
						aMessage[1,3] := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ]

						xA := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ]

						If UPPER(xA) != "#NAOGRAVAR#"
							cConteudo := &( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] )
						Else
							Loop
						EndIf

						If AllTrim( cConteudo ) == "VAZIO"
							cConteudo := ""
						EndIf

						If (Alltrim(cCpoAlias) == "T5M" .Or. Alltrim(cCpoAlias) == "C30") .And. (cCpoName == "T5M_TPREPA" .Or. cCpoName == "C30_TPREPA") .And. Empty(cConteudo) .And. !Empty(xA)
						
							nSeqErrGrv += 1
							cErroGrv += "Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + cEnter
							
							If Len(xA) > 1
								cErroGrv += "Tamanho inválido para o tipo de repasse informado na coluna " + AllTrim( aMessage[1,1] ) + ". Verifique." + cEnter
							ElseIf !(xA $ ('1|2|3|4|5'))
								cErroGrv += "O tipo de repasse " + AllTrim( aMessage[1,3] ) + " informado na coluna " + AllTrim( aMessage[1,1] ) + " é inválido. Verifique." + cEnter
							EndIf

							lErroGrv  := .T.
							cSeqErro  := Soma1( cSeqErro, 4 ) 
							cConteudo := "ER" + cSeqErro
						EndIf

						//Novo modelo de integração consiste em barrar campos chave e obrigatórios em
						//branco e campos com consulta padrão que não são encontrados na base de dados
						If ( "XFUNCH2ID" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNSPCMIL" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNCD2ID" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) .or.;
							"XFUNVLDMEM" $ Upper( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_EXEC] ) );
							.and. !Empty( xA ) .and. Empty( cConteudo )

							If lTafMInc
								TAFMsgIncons( @cErroGrv, @nSeqErrGrv, nChlST2, aMessage )

							Else
								If Len( cErroGrv ) <= TAMMAXXML
									If !Empty( cErroGrv )
										cErroGrv += cEnter + cEnter
									EndIf

									nSeqErrGrv += 1
									cErroGrv += "Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + cEnter

									For nI := 1 to Len( aMessage )
										If nI == 1
											cErroGrv += "O valor '" + AllTrim( aMessage[nI,3] ) + "'"
										Else
											cErroGrv += " somado ao valor '" + AllTrim( aMessage[nI,3] ) + "'"
										EndIf

										cErroGrv += " informado na coluna " + AllTrim( aMessage[nI,1] )
										cErroGrv += " para o campo " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( aMessage[nI,2] ) ) ), X3Descric() } ) ) + " ( " + AllTrim( aMessage[nI,2] ) + " )"
									Next nI			

									cErroGrv += " não existe na base de dados."								
									
								EndIf
							EndIf

							lErroGrv := .T.

							// ----------------------------------------------------------------------------------
							// 15/03/2016 - Felipe C. Seolin
							// Grava código "ERXXXX" para as situações onde a informação:
							// - Faz parte da chave
							// - O envio do registro é feito mas ele não existe na base de dados ou o envio do
							//   registro não é feito
							// Tem o objetivo de burlar o processo de 'chave duplicada' na integração para
							// tratar o erro da maneira correta.
							// Em outro processo a frente, este registro será barrado na gravação dos dados.
							// Não esquecer de passar o parâmetro aCmpUnq com @ para que as informações
							// sejam cacheadas.
							// ----------------------------------------------------------------------------------
							If xTAFCmpUnq( @aCmpUnq, cCpoAlias, cCpoName,,aCpoObrig )
								cSeqErro := Soma1( cSeqErro, 4 )
								cConteudo := "ER" + cSeqErro
							EndIf
						Endif
					Else
						cConteudo := ""
					EndIf

				Else

					//Tratamento para não ocorrer erro quando existir mais
					//campos no Layout do que nos dados enviados para integração
					If Len( aDadosST2[nChlST2] ) >= Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] )
						lSource := .T.

						cConteudo := aDadosST2[nChlST2][ Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE]) ]
						If UPPER(AllTrim(cConteudo)) == "#NAOGRAVAR#"
							aAreaNG := GetArea()
							dbSelectArea(cCpoAlias)
							DBSetOrder( Val( aLayOut[nFather][Z1_ORDER] ) )
							cFldsIndex := ( cCpoAlias )->( IndexKey() )
							RestArea(aAreaNG)

							If (cCpoName$cFldsIndex)
								If !Empty( cErroGrv )
									cErroGrv += cEnter + cEnter
								EndIf

								cPosLay := AllTrim( Str( Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ) )

								nSeqErrGrv += 1
								cErroGrv +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + " - Coluna: " + cPosLay + cEnter +;
												"Campo pertence a chave de negócio. Não é permitido utilizar a tag '#NAOGRAVAR#': " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( cCpoName ) ) ), X3Descric() } ) ) + " ( " + AllTrim( cCpoName ) + " )."

								lErroGrv := .T.
								cSeqErro := Soma1( cSeqErro, 4 )
								cConteudo := "ER" + cSeqErro
							Else
								Loop
							EndIf
						EndIf
					Else
						cConteudo := ""
					EndIf
				EndIf

			EndIf

			cCpoName	:= aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_FIELD]
			cCpoType	:= aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_TYPFLD]
			nSixInd	:= Val(aLayOut[nFather][Z1_ORDER])

			//Novo modelo de integração consiste em barrar campos chave e obrigatórios em
			//branco e campos com consulta padrão que não são encontrados na base de dados
			If lSource .and. Empty( cConteudo ) .and. xTAFCmpUnq( @aCmpUnq, cCpoAlias, cCpoName, nSixInd, aCpoObrig )
				If Len( cErroGrv ) <= TAMMAXXML
					If !Empty( cErroGrv )
						cErroGrv += cEnter + cEnter
					EndIf

					cPosLay := AllTrim( Str( Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ) )

					nSeqErrGrv += 1
					cErroGrv +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + " - Coluna: " + cPosLay + cEnter +;
									"Campo obrigatório não informado: " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( cCpoName ) ) ), X3Descric() } ) ) + " ( " + AllTrim( cCpoName ) + " )."
				EndIf

				lErroGrv := .T.

				// ----------------------------------------------------------------------------------
				// 15/03/2016 - Felipe C. Seolin
				// Grava código "ERXXXX" para as situações onde a informação:
				// - Faz parte da chave
				// - O envio do registro é feito mas ele não existe na base de dados ou o envio do
				//   registro não é feito
				// Tem o objetivo de burlar o processo de 'chave duplicada' na integração para
				// tratar o erro da maneira correta.
				// Em outro processo a frente, este registro será barrado na gravação dos dados.
				// Não esquecer de passar o parâmetro aCmpUnq com @ para que as informações
				// sejam cacheadas.
				// ----------------------------------------------------------------------------------
				cSeqErro := Soma1( cSeqErro, 4 )
				cConteudo := "ER" + cSeqErro
			EndIf

			If lSource .And. cCpoType == "D" .And. !Empty(cConteudo) .And. Empty(StoD(cConteudo))
				If Len( cErroGrv ) <= TAMMAXXML
					If !Empty( cErroGrv )
						cErroGrv += cEnter + cEnter
					EndIf

					cPosLay := AllTrim( Str( Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nFldLayOut][Z4_SOURCE] ) ) )

					nSeqErrGrv += 1
					cErroGrv +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nChlST2 ) ) + " - Coluna: " + cPosLay + cEnter +;
									"Campo data com formato inválido: " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( cCpoName ) ) ), X3Descric() } ) ) + " ( " + AllTrim( cCpoName ) + " )."
				EndIf

				lErroGrv := .T.

				cSeqErro := Soma1( cSeqErro, 4 )
				cConteudo := "ER" + cSeqErro
			EndIf

			If nFldLayOut == 1

				If Alltrim(cCpoAlias) == "C6J"
					cAutSeq := Soma1( cAutSeq, 3 )
					C6J->C6J_ITEMNF := cAutSeq
				ElseIf Alltrim(cCpoAlias) == "C6K"
					C6K->C6K_ITEMNF := cAutSeq
				ElseIf Alltrim(cCpoAlias) == "C4G" .AND. TAFColumnPos('C4G_SEQUEN')
					cAutSeq := StrZero(Val(Soma1( cAutSeq )),15)
					C4G->C4G_SEQUEN := cAutSeq
				EndIf
			EndIf

			//Se o layout alterado for da tabela C1E - Complemento de Empresa, será necessario guardar os dados da tabela C1E antes da alteração para posterior comparação,
			//para avaliação da necessidade de limpeza do campo C1E_PROCID
			If Alltrim(cCpoAlias) == "C1E" .And. Len(aOldC1E) == 0
				If aCposR1000 == Nil
					aCposR1000 := TafR1000Cpo()
				EndIf
				nLenCpoC1E := Len(aCposR1000[2])
				For nCposC1E := 1 to nLenCpoC1E
					If Substring(aCposR1000[2][nCposC1E], 1, 3) == "C1E"
						aAdd(aOldC1E, {aCposR1000[2][nCposC1E], &(Substring(aCposR1000[2][nCposC1E], 1, 3) + "->" +  aCposR1000[2][nCposC1E])})
					EndIf
				Next nCposC1E
			EndIf

			If cCpoType == "C"
				(cCpoAlias)->&(cCpoName) := cConteudo
			ElseIf cCpoType == "M"
				(cCpoAlias)->&(cCpoName) := cConteudo
			ElseIf cCpoType == "N"
				cConteudo := Val( Alltrim(StrTran(cConteudo,",",".")) )
				(cCpoAlias)->&(cCpoName) := cConteudo
			ElseIf cCpoType == "D"
				cConteudo := StoD(cConteudo)
				(cCpoAlias)->&(cCpoName) := cConteudo
			ElseIf cCpoType == "L"
				cConteudo := Iif( Empty( cConteudo ) .or. cConteudo $ "|F|f|0|", .F., .T. )
				( cCpoAlias )->&( cCpoName ) := cConteudo
			ElseIf cCpoType == "S"
				(cCpoAlias)->&(cCpoName) := TAFGeraId("TAF")
			EndIf

			nPosCpo := aScan( aRelation , { |x| x[1] == cCpoName } )

			If nPosCpo > 0
				aRelation[nPosCpo][2] := cConteudo
			Else
				aadd( aRelation , { cCpoName , cConteudo } )
			EndIf

			If Len( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_RELAC] ) > 0

				For nX := 1 To Len( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_RELAC] )

					If Substr( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_RELAC][nX][1] ,4 ,7 ) <> "_FILIAL"

						cCpoName := aLayOut[nFather][Z1_CHANELS][nChanel][Z3_RELAC][nX][1]

						nPosCpo := aScan( aRelation , { |x| x[1] == aLayOut[nFather][Z1_CHANELS][nChanel][Z3_RELAC][nX][2] } )

						If nPosCpo > 0
							(cCpoAlias)->&(cCpoName) := aRelation[nPosCpo][2]
						EndIf
					EndIf
				Next nX

			EndIf

		EndIf

	Next nFldLayOut

	/* CONTROLE SEQUÊNCIA NUMERAÇÃO QUANDO CAMPO NÃO ESTÁ NO LAYOUT DE INTEGRAÇÃO - CONTROLE  DE DUPLICIDADE*/
	If Empty(cCmpSeqC2T) .Or. Empty(cCmpSeqC3K)
		IIf (TAFColumnPos( "C2T_SEQREG" ), cCmpSeqC2T := "S", "N")
		IIf (TAFColumnPos( "C3K_SEQREG" ), cCmpSeqC3K := "S", "N")
	EndIF

	If cCpoAlias == "C2T" .And. cCmpSeqC2T == "S"
		C2T->C2T_SEQREG := TAFSeqReg( "C2T", C2T->C2T_ID )

		nPosCpo := aScan( aRelation , { |x| x[1] == "C2T_SEQREG" } )

		If nPosCpo > 0
			aRelation[nPosCpo][2] :=  C2T->C2T_SEQREG
		Else
			aadd( aRelation , { "C2T_SEQREG" , C2T->C2T_SEQREG } )
		EndIf
	ElseIf cCpoAlias == "C3K" .And. cCmpSeqC3K == "S"
		C3K->C3K_SEQREG := AllTrim(cValToChar(TAFSeqReg( "C3K", C3K->C3K_ID )))

		nPosCpo := aScan( aRelation , { |x| x[1] == "C3K_SEQREG" } )

		If nPosCpo > 0
			aRelation[nPosCpo][2] :=  C3K->C3K_SEQREG
		Else
			aadd( aRelation , { "C3K_SEQREG" , C3K->C3K_SEQREG } )
		EndIf
	EndIf

	/* Controle Reinf - Gravação em granco do campo C20_PROCID */
	/*
	If cCpoAlias == "C20" .And. TAFColumnPos( "C20_PROCID" )
			C20->C20_PROCID := ' '
	EndIf

	If cCpoAlias == "LEM" .And. TAFColumnPos( "LEM_PROCID" )
			LEM->LEM_PROCID := ' '
	EndIf
	*/
	If TAFColumnPos( cCpoAlias+"_PROCID" ) .Or. TAFColumnPos( cCpoAlias+"_PRID40" ) .Or. (TAFColumnPos("C1E_PROCID") .And. Alltrim(cCpoAlias) == "CRM")
		//Se o alias avaliado for da tabela C1E, compara conteúdo armazenado da tabela C1E antes da alteração com o conteúdo atual; encontrada a primeira diferença, limpa-se campo C1E_PROCID
		If Alltrim(cCpoAlias) == "C1E"
			nLenCpoC1E := Len(aOldC1E)
			For nCposC1E := 1 to nLenCpoC1E
				If Alltrim(&(Substring(aOldC1E[nCposC1E][1], 1, 3) + "->" +  aOldC1E[nCposC1E][1])) <> Alltrim(aOldC1E[nCposC1E][2])
					lDelProcID := .T.
					RecLock( "C1E", .F. )
						C1E->C1E_PROCID := ""
					C1E->(MsUnLock())
					Exit
				EndIf
			Next nCposC1E

		//Como a tabela CRM pode ser enviada diversas vezes na integração, verifica se a análise de modificação já não foi realizada anteriormente através da variável lDelProcID
		//Caso não tenha sido realizada, primeiramente deve comparar a quantidade de registros enviados para o T001AN e comparar com a quantidade de linhas deletadas na tabela CRM pela função TafDelChild
		ElseIf Alltrim(cCpoAlias) == "CRM" .And. !lDelProcID
			nLenDadST2 := Len(aDadosST2)
			For nContST2 := 1 to nLenDadST2
				If aDadosST2[nContST2][1] == "T001AN"
					nContCRM++
				ElseIf Substr(aDadosST2[nContST2][1],1,4) <> "T001"
					Exit
				EndIf
			Next nContST2

			//Se não há diferença entre a quantidade de registros apagados da CRM e a quantidade de itens enviados para o registro T001AN na integração, devo verificar se o CNPJ da linha da CRM
			//gravada neste momento está contido no array de dados deletados da CRM.
			If Len(aDelCRM) == nContCRM
				nPsCNPJCRM	:= aScan(aDelCRM[1], {|x| AllTrim(x[1]) == "CRM_CNPJ"})
				nLnCNPJCRM 	:= aScan( aDelCRM, {|x| AllTrim(x[nPsCNPJCRM][2]) == Alltrim(CRM->CRM_CNPJ)})

				//Se for localizado, devo comparar se todos os outros campos da CRM estão iguais aos do item deletado anteriormente. Se qualquer diferença por identificada, o C1E_PROCID deve ser limpo e o processamento interrompido
				If nLnCNPJCRM > 0
					nTmCposCRM 	:= Len(aDelCRM[nLnCNPJCRM])
					For nCposCRM := 1 to nTmCposCRM
						If Alltrim(&(Substring(aDelCRM[nLnCNPJCRM][nCposCRM][1], 1, 3) + "->" +  aDelCRM[nLnCNPJCRM][nCposCRM][1])) <> Alltrim(aDelCRM[nLnCNPJCRM][nCposCRM][2])
							lDelProcID := .T.
							RecLock( "C1E", .F. )
								C1E->C1E_PROCID := ""
							C1E->(MsUnLock())
							Exit
						EndIf
					Next nX

				//Caso não esteja, isto significa que trata-se de um novo CNPJ e neste caso o C1E_PROCID deverá ser apagado.
				Else
					lDelProcID := .T.
					RecLock( "C1E", .F. )
						C1E->C1E_PROCID := ""
					C1E->(MsUnLock())
				EndIf

			//Se houver diferença nesta comparação, podemos assumir que o conteúdo foi modificado (houve deleção ou adição) e o campo C1E_PROCID deve ser limpo
			Else
				lDelProcID := .T.
				RecLock( "C1E", .F. )
					C1E->C1E_PROCID := ""
				C1E->(MsUnLock())
			EndIf

		//Para as demais tabelas que possuem o campo _PROCID, o campo deve ser limpo sem tratativas condicionais.
		ElseIf !(Alltrim(cCpoAlias) $ "CRM|C1E")
			/*---------------------------------------------------------------------------
			|Tratamento para limpar apuracao da CPRB, caso ainda nao esteja transmitido	|
			|e seja reimportado um arquivo com escopo alteracao\delecao					|
			---------------------------------------------------------------------------*/
			TafAtuPrId( cCpoAlias )

			RecLock( cCpoAlias , .F. )
				(cCpoAlias)->&(cCpoAlias+"_PROCID") := ""
				If TAFColumnPos( cCpoAlias+"_PRID40" )
					(cCpoAlias)->&(cCpoAlias+"_PRID40") := ""
				ENDIF
			(cCpoAlias)->(MsUnLock())
		EndIf
	EndIf

	If cCpoAlias == "C1G"
		C1G->C1G_ATIVO := "1"
	EndIf
endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRtFis
Retorna Array com as Informações das tabelas TAF-FISCAL

@Author Evandro dos Santos Oliveira

@since 03/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFRtFis()

Return( aTafFiscal )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRtFis
Retorna Array com as Informações das tabelas TAF-ECF

@Author Evandro dos Santos Oliveira

@since 03/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFRtECF()

Return( aTafECF )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRtEso
Retorna Array com as Informações das tabelas TAF-eSocial.

@Author Evandro dos Santos Oliveira

@return
__aTafSocial[1] - Função de gravação do XML
__aTafSocial[2] - Função de validação do XML
__aTafSocial[3] - Função de geração do XML
__aTafSocial[4] - Alias da tabela
__aTafSocial[5] - Nome do evento
__aTafSocial[6] - Tag principal identificadora do evento (ex: evtProcTrab )

Obs: Essa função foi modificada para retornar o array do e-Social a partir
de um cache

@since 16/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFRtEso()

	Local aRotinas as array

	If __aTafSocial == Nil
	 
		__aTafSocial := {}
		aRotinas := TAFRotinas(,,.T.,2)
		aEval(aRotinas,{|x| IIf(!Empty(x[9]),aAdd(__aTafSocial,{x[7],getFuncVld(x[7]),x[8],x[3],x[4],x[9]}),) }) 
	EndIf 

Return(__aTafSocial)

//-------------------------------------------------------------------
/*/{Protheus.doc} getFuncVld

Funcão auxiliar para retorno do nome da funcão de validação.
Obs. Essa funcao foi criada para não precisar criar uma nova posicao
no TAFROTINAS, as funcoes de validacão só exitem hoje por questoes
de compatibilidade.

@param	cStrAux - Nome da função de gravacao ou geracao do xml
contida no fonte tafrotinas

@return - Nome da função de validação

@author Evandro Oliveira

@since 30/11/2023

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getFuncVld(cStrAux)
Return IIf(Empty(cStrAux),'',Substr(cStrAux,1,6)) + 'Vld'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCommit

Executa o commit do processamento da linha e deve capturar possível
erro de chave duplicada na integração.

@param	cCpoAlias - Alias da Tabela que irá receber o Commit

@author Paulo Santana

@since 24/08/2015

@version 1.0

/*/
//-------------------------------------------------------------------
Function TafCommit( cCpoAlias )

Local lErroInt	:=	.F.
Local oError		:=	ErrorBlock( { |oError| TratError( oError, @lErroInt ) } )

Begin Sequence

	( cCpoAlias )->( ( DBCommit(), MsUnLock() ) )

Recover
	lErroInt := .T.
	DisarmTransaction()

End Sequence

oError := Nil

Return( lErroInt )

//-------------------------------------------------------------------
/*/{Protheus.doc} TratError

Efetua tratamento de error log da chave duplicada

@param	oError - Objeto carrega erro

@author Paulo Santana

@since 24/08/2015

@version 1.0

/*/
//-------------------------------------------------------------------
Function TratError( oError,lErroInt )

Local cErr  := oError:Description
Local cErro := ""
lErroInt 	 := .T.
cErro := cErr + chr(10) + chr(13)
TAFConout(cErro,3,.T.,"INTEG")

Return( NIL )



function TAFAlertJob( cTpMsg , aParametro )

local	cMsg	:=	''
local	cMsgAux	:=	''
local	nX		:=	0

if cTpMsg $ "JOB0_TAFA050"
	cMsg	:=	"Para execução deste processo é necessário que ao menos uma amarração de Complemento de Empresa "
	cMsg	+=	"seja cadastrada para o Grupo de Empresas logado."

elseif cTpMsg $ "JOB0_CODFIL"

	for nX := 1 to len( aParametro[1] )
		cMsgAux	+=	"'" + allTrim( aParametro[ 1 , nX ] ) + "', "
	next nX

	//retiro os dois ultimos caracteres ", "
	cMsgAux	:=	subStr( cMsgAux , 1 , len( cMsgAux ) - 2 )

	cMsg	:=	"A cópia dos dados da tabela TAFST1 para a tabela TAFST2 será feita para os registros com TAFFIL igual a: " + cMsgAux + "."

endif

return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} FIntegTaf

Função para realizar a integração online do Protheus ( Fiscal )

@param	cTpReg    - Tipo do layout
		cIdThread - Numero da thread gravada na tabela tafst2

@author Rodrigo Aguilar

@since 18/07/2015

@version 1.0

/*/
//-------------------------------------------------------------------
Function FIntegTaf( cTpReg, cIdThread )
Local aReturn := {}
Local aLayout := {}
Local aLaydel := {}

//Realiza a carga do layout TAF
aReturn := FReadLayout( cTpReg, .T. )

aLayout := aReturn[1]
aLaydel := aReturn[2]

//chamo a funão responsável por fazer a gravacao das informações
TafIntJob2( cTpReg , cIdThread, aLayout,  aLaydel )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FReadLayout

Função para realizar a integração online do Protheus ( Fiscal )

@param	cTpReg    - Tipo do layout
		lRetLayout - Indica se deve subir o layout na STATIC ou em arrays

@author Rodrigo Aguilar

@since 01/08/2016

@version 1.0

/*/
//-------------------------------------------------------------------
Function FReadLayout( cTpReg, lRetLayout )

local aReturn := {}

lLoadCache := Iif( ( ( aLayOut == Nil ) .and. ( aLayDel == Nil ) ) .or. Len( aLayOut ) == 1, .T., .F. )

//Faço a carga do layout taf
if lLoadCache
	aReturn := TAFLoadLay( cTpReg,lRetLayout )
else
	aReturn := { aLayout, aLayDel }
endif

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} FTafExisLock

Função temporária apenas para garantir que a função taflock esta compilada no repositório de dados

@param cAlias       - Alias a ser gravado/alterado
        lInclui      - .T. - Inclui/ .F. Altera/Exclui
        lSimpleLock  - Indica se deve realizar o simplelock antes do reclock

@author Rodrigo Aguilar

@since 16/11/2016

@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FTafExisLock( cAlias, lInclui, lSimpleLock )

local lLock := .F.

if lTafLock
	lLock := TafLock( cAlias, lInclui, lSimpleLock )
else
	lLock := .T.
	RecLock( cAlias, lInclui )
endif

Return lLock

//---------------------------------------------------------------------
/*/{Protheus.doc} SeekAux

Funcionalidade auxiliar para pesquisa de registro na base de dados de
maneira alternativa a convencional do layout de integração.

@Param	nFather		- Indexador do registro pai
		nChanel		- Posição do canal no array aLayout
		aDadosST2		- Dados enviados na tabela TAFST2
		cFilRegInt		- Filial do registro a ser integrado
		nChlST2		- Indexador do array aDadosST2
		aIncons		- Array dos registros com inconsistências
		cCpoAlias		- Alias da tabela pai
		aLayout		- Array com layouts de integração

@Return	lRet		- Indicador de integração método de alteração

@Author	Felipe C. Seolin
@Since		31/10/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function SeekAux( nFather, nChanel, aDadosST2, cFilRegInt, nChlST2, aIncons, cCpoAlias, aLayout )

Local cAux	:= ""
Local nPos	:= 0
Local lRet	:= .F.

If aDadosST2[1][1] == "T124"
	nPos := aScan( aLayout[nFather][Z1_CHANELS][nChanel][Z3_FIELDS], { |x| AllTrim( x[Z4_FIELD] ) == "CFS_INDLCT" } )

	If nPos > 0
		cAux := aDadosST2[nChlST2][Val( aLayOut[nFather][Z1_CHANELS][nChanel][Z3_FIELDS][nPos][Z4_SOURCE] )]

		If cAux == "3" //Carga Inicial
			CFS->( DBSetOrder( 3 ) )

			lRet := CFS->( MsSeek( FTafGetFil( cFilRegInt, @aIncons, cCpoAlias ) + cAux ) )
		EndIf
	EndIf
EndIf

Return( lRet )


/*/{Protheus.doc} FMultThrd
Valida se existe registros do e-Social pendentes à serem processados para desabilitar o processamento em multi-thread.
@author Victor Andrade
@since 26/06/2017
@version undefined
@type function
/*/
Static Function FMultThrd(cBanco, aCodFil)

Local lRet			:= .F.
Local cQuery		:= ""
Local cNextAlias	:= GetNextAlias()
Local nX			:= 0
Local aArea			:= GetArea()

Default cBanco := upper(alltrim(TcGetDB()))
Default aCodFil := TAFCodFilErp()

cCodFil		:= ""

For nX := 1 To Len(aCodFil)
	cCodFil	+=	"'" + AllTrim( aCodFil[nX] ) + "', "
Next nX

//retiro os dois ultimos caracteres ", "
cCodFil	:=	SubStr( cCodFil , 1 , Len( cCodFil ) - 2 )

cCodFil := iif( empty( alltrim( cCodFil ) ) , "''" , cCodFil )

lRet 	:= .F.
if FindFunction( "FSliceQry" )
	cQuery	:= FSliceQry(.T., "1", "TAFST2", cBanco, .T., cCodFil, .T., 2,"","","")
endif

TCQuery cQuery New Alias (cNextAlias)

(cNextAlias)->( DbGoTop() )

If !(cNextAlias)->( Eof() )
	lRet := .T.
EndIf

(cNextAlias)->(DbCloseArea())

RestArea(aArea)

Return(lRet)


Function tafIPCProc2(aPar)

	Local	nThreads		:=	10
	Local	nI				:=	0
	local 	oProcessMT    	:= 	nil
	Local 	aCodFil			:= 	{}
	Local	cSemaphore		:=	'TAFIPCPROC'
	Local	aThreads		:=	{}
	Local	aTopInfo		:= FWGetTopInfo()

	Default	aPar	:=	{'99','01'}

	RpcSetType(3)
	RpcSetEnv(aPar[1],aPar[2],,,"TAF","TAFAINTEG")

	cMvTAFTDB	:=	GetNewPar( "MV_TAFTDB", "" ) //Parâmetro MV_TAFTDB - TAF TOP DATABASE DO ERP
	cMvTAFTALI	:=	GetNewPar( "MV_TAFTALI",'' ) //Parâmetro MV_TAFTALI - TAF TOP ALIAS DO ERP
	nMvTAFPort	:=	GetNewPar( "MV_TAFPORT", 7890 ) //Parâmetro MV_TAFPORT - PORTA DO DBACCESS - DEFAULT PORTA CORRENTE
	aCodFil		:=	TAFCodFilErp()

	//-------------------------------------------------------------------------
	// Tratamento para obter a porta, devido ambiente com DBAccess distribuido
	//-------------------------------------------------------------------------
	If nMvTAFPort == 0
		nMvTAFPort := aTopInfo[03]
	EndIf


	For nI := 1 To nThreads
		TAFConout( 'Start Thread( '+StrZero(nI,3)+' ) --> ' + StrZero( ThreadID(), 10 ),2,.F.,"INTEG" )
		StartJob( 'TafCheckMT', GetEnvServer(), .F., cSemaphore, 'TafIntJob2', cEmpAnt, cFilAnt, StrZero( ThreadID(), 10 ), 2, .T., '', {}, cMvTAFTALI, cMvTAFTDB, nMvTAFPort )
	Next nI

	While !killapp()

		TAFConout( 'Filtrando ST2...',2,.F.,"INTEG" )
		aThreads	:=	{}
		TafQryMTThread( aCodFil, @aThreads )

		If Len( aThreads ) > 0
			TAFConout( 'Processing ' + StrZero(Len(aThreads),3) + ' Threads...',2,.F.,"INTEG" )
			TafProc2Mt( @oProcessMT, aCodFil, cSemaphore, nThreads ,.T., aLayout, aLaydel, aThreads )
		Else
			TAFConout( 'Aguardando IPC...',2,.F.,"INTEG" )
			Sleep( 5000 )
			TAFConout( 'Loop IPC...',2,.F.,"INTEG" )
		EndIf

	End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVincRegs
Apresenta tela para informar as TAFKeys dos registros predecessores
dos S-2200 e S-2230
@author  Victor A. Barbosa
@since   15/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFVincRegs( aRegs, cST2Alias )

Local oDlgVinc		:= Nil
Local oBrowse		:= Nil
Local oSize     	:= FWDefSize():New( .T. )
Local aCoors    	:= FWGetDialogSize( oMainWnd )
Local bValidEdit	:= { |lCancel| TAFPredEdit( aRegs, oBrowse ) }
Local bClickXML		:= {||}

oSize:AddObject( "DLG", 100, 100, .T., .T.)
oSize:SetWindowSize(aCoors)
oSize:lProp     := .T.
oSize:lLateral := .T.
oSize:Process()

DEFINE MSDIALOG oDlgVinc FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] Title "Vínculo de Predecessores" OF oMainWnd PIXEL

DEFINE FWBROWSE oBrowse DATA ARRAY EDITCELL bValidEdit ARRAY aRegs NO SEEK NO CONFIG NO REPORT Of oDlgVinc

bClickXML	:= { || FWMsgRun( ,{ || TAFViewXML( aRegs[ oBrowse:At() ] ) } , "Aguarde", "Verificando XML") }

ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 1 ] }	Title "Filial"	PICTURE   SIZE 10 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 2 ] }	Title "Key"		PICTURE   SIZE 25 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 3 ] }	Title "Evento"  	PICTURE   SIZE 10 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 4 ] }	Title "XML"  		DOUBLECLICK bClickXML PICTURE   SIZE 15 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 5 ] }	Title "Data"		PICTURE   SIZE 10 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 6 ] }	Title "Hora"		PICTURE   SIZE 10 Of oBrowse
ADD COLUMN oColumn DATA { || aRegs[ oBrowse:At(), 7 ] } Title "Predecessor" TYPE "C"  SIZE 10  EDIT READVAR "cPred" Of oBrowse

ACTIVATE FWBrowse oBrowse

oBrowse:SetArray( aRegs )

ACTIVATE MSDIALOG oDlgVinc ON INIT EnchoiceBar( oDlgVinc , {|| TAFGrvPred( aRegs, cST2Alias ), oDlgVinc:End() } , { || lRet := .F., oDlgVinc:End() },,) CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFViewXML
Apresenta o XML gravado na TAFST2 para o usuário
@author  Victor A. Barbosa
@since   15/02/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFViewXML( aInfoST2 )

Local cTempPath := GetTempPath(.T.)
Local cFile 	:= cTempPath + aInfoST2[2] + ".xml"
Local oDlgXML	:= TDialog():New( 150, 150, 500, 500,'',,,,,,,,,.T.)

// Se existir algum arquivo com o mesmo nome no temp da máquina, exclui, pois se o sistema oscilar a estação pode cair e não excluir o .xml
If File( cFile )
	FErase( cFile )
EndIf

// Cria o arquivo XML temporário para apresentação na tela
If MemoWrite( cFile, aInfoST2[4] )
	oXml := TXMLViewer():New(10, 10, oDlgXML , cFile, 150, 150, .T. )
	oXML:SetXML( cFile )
	oDlgXML:Activate()

	// Quando usuário fechar a tela, exclui o XML temporário
	FErase( cFile )

Else
	MsgAlert( "Erro ao tentar visualizar XML" )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPredEdit
Edição do campo de predecessão
@author  Victor A. Barbosa
@since   15/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFPredEdit( aRegs, oBrowse )

Local nPosCursor := oBrowse:At()

aRegs[ nPosCursor ][7] := &( ReadVar() )

oBrowse:SetArray( aRegs )
oBrowse:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGrvPred
Grava os TAFKEYs de predecessão nos devidos registros
@author  Victor A. Barbosa
@since   15/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFGrvPred( aRegs, cST2Alias )

Local aArea := GetArea()
Local nX	:= 0

For nX := 1 To Len( aRegs )

	(cST2Alias)->( DbGoTo( aRegs[nX][8] ) )

	Reclock(cST2Alias, .F.)
	(cST2Alias)->TAFREGPRED := aRegs[nX][7]
	(cST2Alias)->( MsUnlock() )

Next nX

RestArea( aArea )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ForceMThread
Força o processamento multithread se houver muita demanda de processamanto da TAFST2
@author  Roberto Souza
@since   08/06/2018
@version 1

@param cTicketXML - Ticket gerado para o XML que está sendo importado

/*/
//-------------------------------------------------------------------
Static Function ForceMThread( nQtdThread, cTicketXML, cFilmt )

	Local cAliasT2		:= GetNextAlias()
	Local nRegs			:= 0
	Local nQtdRes		:= 0
	Local nRegLimit		:= 4000
	Local cWhere		:= ""
	Default nQtdThread	:= GetNewPar( 'MV_TAFQTTH', 5 )
	Default cFilmt		:= ""
	Default cTicketXML  := ""

	//--------------------------------------------------------------------------------------------
	// Tratamento para quando for o processo de importação XML, só considerar os dados carregados
	//--------------------------------------------------------------------------------------------
	If !Empty(cTicketXML)
		cWhere	:= " AND TAFTICKET = '" + cTicketXML + "' "
	EndIf

	If !Empty(cFilmt)
		cWhere	+= " AND TAFFIL IN ( " +  cFilmt + " ) "
	EndIf

	cWhere	:= "%" + cWhere + "%"

	BeginSql ALIAS cAliasT2
		SELECT COUNT(*) TOTAL FROM TAFST2 ST2 WHERE ST2.%NOTDEL% AND TAFSTATUS ='1' %exp:cWhere%
	EndSql

	DbSelectArea( cAliasT2 )
	nRegs := (cAliasT2)->TOTAL


	If nRegs >= nRegLimit
		nQtdRes := Round( nRegs / nRegLimit , 0 )
		If nQtdThread < nQtdRes
			nQtdThread := Iif (nQtdThread > 1, nQtdThread, 5)
		EndIf
	EndIf

Return( nQtdThread )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpReg
Retorna o tipo de registro/campo complementar (via referência)
@author  Victor A. Barbosa
@since   17/08/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetTpReg(cTpReg, cComplST2 )

Default cTpReg 		:= ""
Default cComplST2	:= ""

If ";" $ cTpReg
	cComplST2	:= SubStr( cTpReg, At( ";", cTpReg ) + 1 )
	cTpReg		:= SubStr( cTpReg, 1, 6 )
EndIf

Return( cTpReg )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafLayError
Tratamento de erro para o carregamento do Layout TAF
@author  Wesley Pinheiro/Denis Naves 
@since   26/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function TafLayError( e )

    //local nSemafLay := 0

    //GetGlbVars( "NSEMAFLAY", @nSemafLay )
    //conout("##### TrataErro ##### Antes ##### nSemafLay: " + cvaltochar(nSemafLay) )

	//Caso ocorra algum erro retorna semaforo para nao carregado
	PutGlbVars( "NSEMAFLAY", _NO_LOAD )

    //GetGlbVars( "NSEMAFLAY", @nSemafLay )
    //conout("##### TrataErro ##### Depois ##### nSemafLay: " + cvaltochar(nSemafLay) )

	if IsBlind() //schedule encerra thread com erro
		KillApp( .T. )
	endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAtuPrId
Atualiza o ProcId nas tabelas espelho ( apuração reinf ), quando alterado
via cadastro MVC (SavelModel), ou reintegração de arquivos .Txt

Tratamento para limpar apuracao da CPRB, caso ainda nao esteja transmitido
e seja reimportado um arquivo com escopo alteracao\delecao

@author  Denis Naves / Carlos Silva
@since   09/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function TafAtuPrId( cCpoAlias, cAliasDel )

	Local cIdDel 	  := ""
	Local cQryExc     := ""
	Local cNmEspelho  := ""
	Local nPos        := 0
	Local nlI         := 0
	Local aLegEsp     := { { "C5M", "V0S" } , { "C1G", "T9V" }  }
	Local aIdDel      := {}

	Default cCpoAlias := ""
	Default cAliasDel := ""

	if (cCpoAlias == "C5M" .And. (Empty(cAliasDel) .Or. cAliasDel == "V48") ) .Or. ( cCpoAlias == "C1G" )

		if Empty( cAliasDel ) .Or. cCpoAlias == "C1G" //C1G não possui filhos com procid
			cAliasDel := cCpoAlias
		endif

		nPos := aScan( aLegEsp, {|x| x[1] == cCpoAlias } )

		if nPos > 0

			cNmEspelho := aLegEsp[nPos][2]

			cIdDel  := &(cAliasDel + "->" + cAliasDel + "_PROCID")

			cQryExc := "SELECT R_E_C_N_O_ FROM " + RetSqlName( cNmEspelho ) + " WHERE D_E_L_E_T_ = ' ' "
			cQryExc += "AND " + cNmEspelho + "_PROCID = '" + cIdDel + "' AND " + cNmEspelho + "_STATUS = ' ' AND " + cNmEspelho + "_ATIVO = '1' "

			aIdDel  := TafQryarr( cQryExc )
			For nlI := 1 To Len( aIdDel )
				TafEndGRV( cNmEspelho, (cNmEspelho + "_PROCID"), "", aIdDel[nlI][1] )
			Next nlI
		endif
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CposObrig
Cria chache de campos obrigatórios das tabelas filhas da C20

@author  Carlos Eduardo Silva
@since   27/07/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function CposObrig(aC20Child)
Local aRet 		:= Nil
Local i 		:= 0
Local j 		:= 0
Local aFields	:= {}

Aadd(aC20Child,'C20')
aRet := {aC20Child,{}}
for i := 1 to len(aC20Child)
	aFields := FWSX3Util():GetAllFields( aC20Child[i] , .t. )
	for j := 1 to len(aFields)	
		if x3Obrigat(aFields[j]) 
			aadd( aRet[2], alltrim(aFields[j]))
		endif
	next
next

return aRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} RemoveUTF8 
Retira a Identificação de codificação UTF8 do inicio do XML.
É realizado este tratamento para que os Xmls fiquem na TAFST2 iguais idependente
da tecnologia utilizada na integração.

@param cXml - Xml do Evento

@return cXmlRet - Xml Sem a Tag de Encode.

@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function RemoveUTF8(cXml)

	Local nStart 	:= 0
	Local cXmlRet 	:= ""

	nStart := AT(">",cXml) 
	cXmlRet := Substr(cXml,nStart+1,Len(cXml)-(nStart))
	cXmlRet := StrTran(cXmlRet,Chr(13),"")
	cXmlRet := StrTran(cXmlRet,Chr(10),"")
	
Return cXmlRet

/*-----------------------------------------------------------------------------
{Protheus.doc} TafStr2Arr 
Utiliza a função StrTokArr porém com tratamento de Alltrim
@param cString - String a ser processada
	   cDelim - Delimitador
	   lAllTrim- Tira espacos em brancos Default .T.

@return array - array de cada conteudo delimitada em uma posicao

@author Karen Honda
@since 03/08/2022
@version 1.0
/*/
//--------------------------------------------------------------------------- 

Function TafStr2Arr(cString, cDelim, lAllTrim)
Local aRet as Array
Local nI as numeric
Local nUltPos as numeric

Default cString := " "
Default cDelim := " "
Default lAlltrim := .T.

If lAlltrim
	cString := Alltrim(cString)
EndIf

aRet := {}
aRet := StrTokArr2( cString, cDelim,.T. )
nUltPos := Len(aRet)
If lAlltrim
	For nI := 1 to nUltPos
		aRet[nI] := Alltrim(aRet[nI])
	Next nI
EndIf	
If Empty(aRet[nUltPos])
	aDel( aRet , nUltPos )
	aSize( aRet , Len( aRet ) - 1 )
EndIf

Return aRet
