#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFXINTEG.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"        


// ---------------------------------------------------------------------------------------------------------------
#DEFINE	cStsReady	"'1'"	// Registros em prontos para ser processados.
#DEFINE	cStsProc	"2"		// Registros em Processamento (ja identificados/separados pela Slice).
#DEFINE	cStsFinal	"3"		// Registros em Ja processados / Finalizados.
// ---------------------------------------------------------------------------------------------------------------

#DEFINE 	nS1000		001
#DEFINE 	nS1005		002
#DEFINE 	nS1010		003
#DEFINE 	nS1020		004
#DEFINE 	nS1030		005
#DEFINE 	nS1040		006
#DEFINE 	nS1050		007
#DEFINE 	nS1060		008
#DEFINE 	nS1070		009
#DEFINE 	nS1080		010
#DEFINE 	nS1100		011
#DEFINE 	nS1200		012
#DEFINE 	nS1202		013
#DEFINE 	nS1300		014
#DEFINE 	nS1310		015
#DEFINE 	nS1320		016
#DEFINE 	nS1330		017
#DEFINE 	nS1340		018
#DEFINE 	nS1250		019
#DEFINE 	nS1360		020
#DEFINE 	nS1370		021
#DEFINE 	nS1380		022
#DEFINE 	nS1390		023
#DEFINE 	nS1299		024
#DEFINE 	nS1400		025
#DEFINE 	nS1800		026
#DEFINE 	nS2190		027
#DEFINE 	nS2200		028
#DEFINE 	nS2206		029
#DEFINE 	nS2220		030
#DEFINE 	nS2230		031
#DEFINE 	nS2250		032
#DEFINE 	nS2210		033
#DEFINE 	nS2280		034
#DEFINE 	nS2300		035
#DEFINE 	nS2320		036
#DEFINE 	nS2325		037
#DEFINE 	nS2330		038
#DEFINE 	nS2340		039
#DEFINE 	nS2345		040
#DEFINE 	nS2240		041
#DEFINE 	nS2365		042
#DEFINE 	nS2400		043
#DEFINE 	nS2405		044
#DEFINE 	nS2420		045
#DEFINE 	nS2440		046
#DEFINE 	nS2600		047
#DEFINE 	nS2620		048
#DEFINE 	nS2399		049
#DEFINE 	nS2800		050
#DEFINE 	nS2298		051
#DEFINE 	nS3000		052
#DEFINE 	nS1280		053
#DEFINE 	nS4000		054
#DEFINE		nS1220		055
#DEFINE		nS1298		056
#DEFINE		nS2299		057
#DEFINE		nS1260		058
#DEFINE		nS1270		059
#DEFINE		nS1210		060
#DEFINE		nS2205		061
#DEFINE		nS2306		062
#DEFINE		nS2241		063
#DEFINE		nS1035		064
#DEFINE 	nS1207		065
#DEFINE 	nS5012		066
#DEFINE 	nS5001		067
#DEFINE 	nS5002		068
#DEFINE 	nS5011		069
#DEFINE 	nS1295		070
#DEFINE 	nS2260		071
#DEFINE 	nS5003		072
#DEFINE 	nS5013		073
#DEFINE     nS2245      074
#DEFINE 	nS2221		075
#DEFINE 	nS2231		076
#DEFINE 	nS2410		077
#DEFINE 	nS2416		078
#DEFINE 	nS2418		079
#DEFINE 	nS2420		080
#DEFINE 	nS2500		081
#DEFINE 	nS2501		082
#DEFINE 	nS3500		083
#DEFINE 	nS5501		084
#DEFINE 	nS2555		085
#DEFINE 	nS5503		086

Static lTAFCodRub		:= FindFunction("TAFCodRub")
Static __aModelCache	:= Nil
Static __aSM0			:= FWLoadSM0()
Static lLaySimplif		:= TafLayESoc()
Static __cFilC1E		:= Nil
Static __oPrepared		:= Nil
Static __nTamFilC1E		:= Nil
Static __nTamCR9Fil		:= Nil
Static __lCR9 			:= Nil
Static __lEspM          := Nil
Static __nSizeFil       := Nil

//-------------------------------------------------------------------
/*
Fonte que contempla todas as funcoes genericas de integracao e
geracao do arquivo XML.

@author Demetrio Fontes De Los Rios / Rodrigo Aguilar / Felipe C. Seolin
@since 26/09/2013
@version 1.0
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFGetStru
Funcao retorna a estrutura das tabelas

********************************************** IMPORTANTE **************************************************
Sempre que a estrutura das tabelas forem alteradas, a data da variável estática cDtTabTAFSD no fonte TAFINIT
deverá receber a data de alteração.
************************************************************************************************************

@Param:
cTabStru - Tabela

@Return:
aRet - Array contendo estrutura da tabela e indice

@Author Demetrio Fontes De Los Rios / Felipe C. Seolin
@Since 07/10/2013
@Version 1.0

/*/
//-------------------------------------------------------------------
Function xTAFGetStru( cTabStru )

	Local aEstru		:=	{}
	Local aInd			:=	{}
	Local aRet			:=	{}

	Default cTabStru	:=	"TAFST2"

	//Estrutura das tabelas compartilhadas
	If cTabStru $ "TAFST1|TAFST2"

		//Estrutura campos tabela
		aAdd( aEstru, { "TAFFIL"     ,	"C",	040,	0 }  )
		aAdd( aEstru, { "TAFCODMSG"  ,	"C",	001,	0 }  )
		aAdd( aEstru, { "TAFSEQ"     ,	"C",	003,	0 }  )
		aAdd( aEstru, { "TAFTPREG"   ,	"C",	010,	0 }  )
		aAdd( aEstru, { "TAFKEY"     ,	"C",	100,	0 }  )
		aAdd( aEstru, { "TAFMSG"     ,	"M",	010,	0 }  )
		aAdd( aEstru, { "TAFSTATUS"  ,	"C",	001,	0 }  )
		aAdd( aEstru, { "TAFIDTHRD"  ,	"C",	010,	0 }  )
		aAdd( aEstru, { "TAFTICKET"  ,	"C",	036,	0 }  )
		aAdd( aEstru, { "TAFDATA"    ,	"D",	008,	0 }  )
		aAdd( aEstru, { "TAFHORA"    ,	"C",	008,	0 }  )
		aAdd( aEstru, { "TAFFILTRAN" ,	"C",	040,	0 }  )
		aAdd( aEstru, { "TAFOWNER"   ,	"C",	040,	0 }  )

		If alltrim( cTabStru ) == 'TAFST2'
			aAdd( aEstru, { "TAFPRIORIT"  ,	"C",	001,	0 }  )
			aAdd( aEstru, { "TAFSTQUEUE"  ,	"C",	001,	0 }  )
			aAdd( aEstru, { "TAFREGPRED"  ,	"C",	100,	0 }  )
			aAdd( aEstru, { "TAFCOMP"	  ,	"C",	100,	0 }  )
			aAdd( aEstru, { "TAFUSER"	  ,	"C",	100,	0 }  )
		EndIf

		//Índice - Unique
		aAdd( aInd,  { "TAFFIL"   , "TAFCODMSG", "TAFSEQ"  , "TAFKEY"	} )
		aAdd( aInd,  { "TAFSTATUS", "TAFIDTHRD", "TAFKEY"  , "TAFSEQ"	} )
		aAdd( aInd,  { "TAFSTATUS", "TAFCODMSG", "TAFKEY"  , "TAFSEQ"	} )

		//indice 4
		If alltrim( cTabStru ) == 'TAFST1'
			aAdd( aInd,  { "TAFSTATUS", "TAFIDTHRD", "TAFTPREG", "TAFTICKET", "TAFKEY", "TAFSEQ" } )
		Else
			aAdd( aInd,  { "TAFSTATUS", "TAFIDTHRD", "TAFPRIORIT" , "TAFTPREG", "TAFTICKET", "TAFKEY", "TAFSEQ" } )
		EndIf

		aAdd( aInd,  { "TAFTICKET", "TAFKEY" } )

		//indice 6
		If alltrim( cTabStru ) == 'TAFST1'
			aAdd( aInd,  { "TAFFIL"	  , "TAFSTATUS", "TAFCODMSG","TAFTICKET", "TAFKEY", "TAFSEQ" } )
		Else
			aAdd( aInd,  { "TAFFIL"	  , "TAFSTATUS", "TAFCODMSG", "TAFPRIORIT" , "TAFTICKET", "TAFKEY", "TAFSEQ" } )
		EndIf

		//Somente realiza a criação do indice abaixo para a tabela TAFST2
		If alltrim( cTabStru ) == 'TAFST2'
			aAdd( aInd,  { "TAFIDTHRD", "TAFCODMSG", "TAFSTATUS", "TAFFIL", "TAFDATA", "TAFHORA", "TAFTICKET", "TAFKEY", "TAFSEQ" } )
		EndIf

	ElseIf cTabStru $ "TAFXERP"

		//Campos
		aAdd( aEstru, { "TAFDATA"  ,	"D",	008,	0 }  )
		aAdd( aEstru, { "TAFHORA"  ,	"C",	008,	0 }  )
		aAdd( aEstru, { "TAFKEY"   ,	"C",	100,	0 }  )
		aAdd( aEstru, { "TAFTICKET",	"C",	036,	0 }  )
		aAdd( aEstru, { "TAFALIAS" ,	"C",	003,	0 }  )
		aAdd( aEstru, { "TAFRECNO" ,	"N",	020,	0 }  )
		aAdd( aEstru, { "TAFSTATUS",	"C",	001,	0 }  )
		aAdd( aEstru, { "TAFCODERR",	"C",	006,	0 }  )
		aAdd( aEstru, { "TAFERR"   ,	"M",	010,	0 }  )

		//Índices
		aAdd( aInd, { "TAFTICKET", "TAFKEY" } )
		aAdd( aInd, { "TAFKEY" } )
		aAdd( aInd, { "TAFALIAS", "TAFRECNO" } )

		//Estruturas das tabelas de geração das obrigações acessórias
	ElseIf cTabStru $ "TAFECF|TAFSPED"

		//Estrutura Campos Tabela
		aAdd( aEstru, { "FILIAL"  , "C", 100, 0 } )

		If cTabStru == "TAFSPED"
			aAdd( aEstru, { "CHAVE"  , "C", 200, 0 } )
		EndIf

		aAdd( aEstru, { "PERINI"  , "D", 008, 0 } )
		aAdd( aEstru, { "PERFIN"  , "D", 008, 0 } )
		aAdd( aEstru, { "BLOCO"   , "C", 001, 0 } )
		aAdd( aEstru, { "REGSEQ"  , "C", 010, 0 } )
		aAdd( aEstru, { "REGISTRO", "C", 004, 0 } )
		aAdd( aEstru, { "LINREG"  , "M", 300, 0 } )

		//Indice - Unique
		If cTabStru == "TAFSPED"
			aAdd( aInd, { "FILIAL", "CHAVE", "PERINI", "PERFIN", "BLOCO", "REGSEQ", "REGISTRO" } )
		Else
			aAdd( aInd, { "FILIAL", "PERINI", "PERFIN", "BLOCO", "REGSEQ" } )
		EndIf

		//Estrutura da tabela de controle das obrigações acessórias
	ElseIf cTabStru $ "TAFGERCTL"

		//Estrutura Campos Tabela
		aAdd( aEstru, { "EMPRESA"  , "C", 010, 0 } )
		aAdd( aEstru, { "FILIAL"   , "C", 100, 0 } )
		aAdd( aEstru, { "PERINI"   , "D", 008, 0 } )
		aAdd( aEstru, { "PERFIN"   , "D", 008, 0 } )
		aAdd( aEstru, { "OBRIGACAO", "C", 001, 0 } )
		aAdd( aEstru, { "BLOCO"    , "C", 001, 0 } )
		aAdd( aEstru, { "STATUS"   , "C", 001, 0 } )

		//Indice - Unique
		aAdd( aInd, { "EMPRESA", "FILIAL", "PERINI", "PERFIN", "OBRIGACAO", "BLOCO" } )

	EndIf

	//Retorno sempre sera array de 2 posicoes
	//onde a primeira e' a estrutura da tabela e segunda os indices.
	aRet := { aEstru, aInd }

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFCriaTB
Funcao de criacao de tabelas nos bancos

@Param:
nOpc      	- Parametro Inutilizado
aTopInfo 	- Informações da Conexão para criação das tabelas
cTAB		- Nome da Tabela
cAlias   	- Nome do Alias onde sera realizada a conexão
cDriver  	- Driver de Conexao
aEstru		- Campos da Tabela a ser criada
aInd		- Indices da tabela a ser criada
cTopBuild	- Versão do TopConnect
cBancoDB	- Em qual banco sera realizada a conexão
lTAFDTS 	- Indica se o controle de criacao da TAFST1 é realizado pelo ERP
lJob		- Indica se o processamento é realizado via Job


@Return:
lRet - Indica se foi possivel realizar a criação da tabela no banco de dados

@Author Demetrio Fontes De Los Rios / Felipe C. Seolin
@Since 07/10/2013
@Version 1.0

/*/
//-------------------------------------------------------------------
Function xTAFCriaTB( nOpc, aTopInfo, cTAB, cAlias, cDriver, aEstru, aInd, cTopBuild, cBancoDB, lTAFDTS, lJob, aErros, nHdlTaf )

	Local cError		:=	""
	Local lRet			:=	.F.
	Local lCriaTab		:=	.T.

	Default nHdlTaf		:=	0
	Default aTopInfo	:=	FwGetTopInfo()
	Default cTAB		:= ""
	Default cAlias		:= ""
	Default aErros 		:= {}

	//Criada validação nos parâmetros para evitar error logs
	If !Empty(cTAB) .And. !Empty(cAlias)
		//Atualiza as informações no Top
		TcRefresh( cTAB )

		//Conecta no Banco onde a tabela deverá ser criada
		If cTAB == 'TAFST1' .and. !xTafSmtERP()
			lRet := FConectTAF( aTopInfo[05], aTopInfo[4], aTopInfo[03], .f., @nHdlTaf)
		Else
			lRet := .T.
		EndIf

		If lRet

			//Verifica se o usuário possui a tabela no banco de dados
			If MSFile( RetArq( __CRDD, cTAB, .T. ),, __CRDD )

				lCriaTab := .F.

			EndIf

			//Verifica se deve relizar a criação da tabela
			If lCriaTab

				//Tenta realizar a criação da tabela caso a mesma não exista
				lRet := FAtuTabSD( cTAB, @cError )

			EndIf

			//Caso a tabela ja esteja criada sem problemas na conexão e criação
			If lRet

				//Realiza a abertura da tabela para uso
				lRet := FOpnTabTAf( cTAB, cAlias )

				//Caso ocorra erro neste momento significa que a tabela do banco esta em desacordo com a estrutura da tabela no fonte
				If !lRet
					aAdd( aErros,{ '', 0, '1', '', '', 'Ambiente Desatualizado, Execute a Wizard de Configuração através do Menu Miscelanea para atualizar o ambiente e liberar a utilização desta funcionalidade', '', '', '' } )
					TAFXLogMSG( 'Ambiente Desatualizado, Execute a Wizard de Configuração através do Menu Miscelanea para atualizar o ambiente e liberar a utilização desta funcionalidade' )

				EndIf

			Else
				aAdd( aErros,{ '', 0, '1', '', '', 'Ocorreu o seguinte problema na conexão/criação da tabela ' + cTAB + ' -> ' + cError, '', '', '' } )
				TAFXLogMSG( 'Ocorreu o seguinte problema na conexão/criação da tabela ' + cTAB + ' -> ' + cError )

			EndIf

		Else
			aAdd( aErros,{ '', 0, '1', '', '', 'Não foi possível conectar no banco de dados para criação da tabela de controle da integração', '', '', '' } )
			TAFXLogMSG( 'Não foi possível conectar no banco de dados para criação da tabela de controle da integração' )

		EndIf

	Else
		aAdd( aErros,{ '', 0, '1', '', '', 'Ocorreu um erro com os parâmetros recebidos, entre em contato com a TOTVS', '', '', '' } )
		TAFXLogMSG( 'Ocorreu um erro com os parâmetros recebidos, entre em contato com a TOTVS' )
	EndIf
Return ( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} xTafVerSD

Rotina para comparar a estrutura da shared table no banco de dados com
o esperado pela xTAFGetStru, verificando se precisa ser atualizada.

@Param		cTAB	->	Nome da tabela

@Return	lRet	->	Indica se a estrutura da tabela está igual

@Author	Felipe C. Seolin
@Since		15/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function xTafVerSD( cTab )

	Local nI			:=	0
	Local nJ			:=	0
	Local nPos			:=	0
	Local aStructAtu	:=	{}
	Local aStructNew	:=	{}
	Local lRet			:=	.T.

	Use &( cTab ) Alias &( cTab ) EXCLUSIVE NEW Via __CRDD

	If !NetErr()
		aStructAtu := ( cTab )->( DBStruct() )
		aStructNew := xTAFGetStru( cTab )

		For nI := 1 to Len( aStructNew[1] )
			If ( nPos := aScan( aStructAtu, { |x| AllTrim( x[1] ) == AllTrim( aStructNew[1,nI,1] ) } ) ) > 0
				For nJ := 1 to Len( aStructNew[1,nI] )
					If aStructNew[1,nI,nJ] <> aStructAtu[nPos,nJ]
						lRet := .F.
					EndIf
				Next nJ
			Else
				lRet := .F.
			EndIf

			If !lRet
				Exit
			EndIf

		Next nI

		( cTab )->( DBCloseArea() )
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafCabXml
Funcao retorna o cabecalho generico de cada XML
Deve estar posicionado no registro desejado

@Param:
cXmlLayout	- Xml especifico do Layout                      (obrigatorio)
cAlias		- Alias para buscar informacoes do cabecalho    (obrigatorio)
cLayout		- Layout sem o "S-" / Exemplo: S-1010 -> "1010" (fundamental)
cTagReg    	- Nome da Tag do Registro                       (fundamental)
aMensal    	- Informacoes exclusivas de Eventos Mensais:
                1 - Indicativo de periodo de apuracao
                2 - Periodo de apuracao
                3 - Data da Apuração
cSeq	   	- Numero sequencial implementado para distinguir os registro enviados
			 	na mesma data/hora
cRegistrador - Grupo ideRegistrador dos eventos SST 

@Return:
cXml - Estrutura final do Xml

@author Demetrio Fontes De Los Rios / Felipe C. Seolin
@since 09/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xTafCabXml(cXmlLayout as character, cAlias as character, cLayout as character, cTagReg as character,;
			aMensal as array, cSeq as character, cRegistrador as character, lSimplif as logical, cVerSchema as character)

	Local aSM0Area       	as array
	Local aEvtTafRt      	as array
	Local cFilBkp        	as character
	Local cTipo          	as character
	Local cXml           	as character
	Local cIdeEvento     	as character
	Local cId            	as character
	Local cCGC           	as character
	Local cTpInscr       	as character
	Local cIdNtJur       	as character
	Local cNatJur        	as character
	Local cVerProc       	as character
	Local cNameSpace     	as character
	Local cTpAmb         	as character
	Local cTagInicio     	as character
	Local cIdAnt         	as character
	Local cCGCPr         	as character
	Local cEventos       	as character
	Local cPathURLES     	as character
	Local lOrgPub        	as logical
	Local lPrdRural      	as logical

	Default aMensal			:= {}
	Default cXmlLayout		:= ""
	Default cAlias			:= ""
	Default cSeq         	:= ""
	Default cRegistrador 	:= ""
	Default cLayout      	:= "1000"
	Default cTagReg      	:= "InfoEmpregador"
	Default cVerSchema		:= GetMv("MV_TAFVLES")
	Default lSimplif  		:= IIf(FindFunction("TAFIsSimpl"), TAFIsSimpl(cVerSchema), .F.)

	aSM0Area    := SM0->(GetArea())
	cFilBkp     := cFilAnt
	cTipo       := ""
	cXml        := ""
	cIdeEvento	:= ""
	cId         := ""
	cCGC        := ""
	cTpInscr    := ""
	cIdNtJur    := ""
	cNatJur     := ""
	lOrgPub     := .F.
	cVerProc    := "1.0"
	cNameSpace	:= ""
	cTpAmb    	:= ""
	cTagInicio	:= ""
	aEvtTafRt 	:= {}
	cIdAnt    	:= ""
	cCGCPr    	:= ""
	cEventos  	:= ""
	cPathURLES	:= ""
	lPrdRural 	:= .F.

	If Empty(cVerSchema)
		cVerSchema		:= SuperGetMv("MV_TAFVLES", .F., "S_01_00_00")
	EndIf

	If Upper(AllTrim(FWModeAccess(cAlias,1)+FWModeAccess(cAlias,2)+FWModeAccess(cAlias,3))) == "EEE" .And. AllTrim((cAlias)->&(cAlias+"_FILIAL")) <> AllTrim(SM0->M0_CODFIL)
		
		cFilAnt	:= (cAlias)->&(cAlias+"_FILIAL")
		SM0->(DbSetOrder(1))
		SM0->(MsSeek(cEmpAnt+cFilAnt))

	EndIf

	cCGC     := AllTrim(SM0->M0_CGC)
	cTpInscr := IIf(Len(cCgc) == 14,"1","2")
	cSeq     := StrTran( cSeq, "*", "" )

	If Empty(cSeq) .Or. Len(cSeq) < 5

		//Concateno com 3 caracteres na grandeza de milisegundo, mais um número aleatorio de dois caracteres.
		cSeq		:= SubStr( StrTran( cValToChar( Seconds() ), ".","" ) , Len(StrTran( cValToChar( Seconds() ), ".","" )) - 2) + cValToChar( Randomize(10, 100))

		If Len(cSeq) < 5
			cSeq := StrZero(Val(cSeq),5)
		EndIf

		Sleep( 5 )

	EndIf

	cPathURLES	:= SuperGetMv( 'MV_TAFPSES', .F., "http://www.esocial.gov.br/schema/evt/" )
	cTpAmb		:= SuperGetMv( 'MV_TAFAMBE', .F., "2"                                     )

	// Tratamento para simplificação do e-Social
	If lSimplif
		cNameSpace := cPathURLES + "evt" + cTagReg + "/v_" + cVerSchema
	Else
		cNameSpace := cPathURLES + "evt" + cTagReg + "/v" + cVerSchema
	EndIf

	cTagInicio	:= "<eSocial xmlns='" + cNameSpace + "'>"

	If Alltrim(cAlias) != "C1E"
		cIdNtJur := Posicione("C1E",3,xFilial("C1E")+PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] )+"1","C1E_NATJUR")
	Else
		cIdNtJur := C1E->C1E_NATJUR
	EndIf

	cNatJur := Posicione("C8P",1,xFilial("C8P")+cIdNtJur,"C8P_CODIGO")

	If !Empty(cNatJur)

		If !lSimplif
			lOrgPub := cNatJur $ "1015|1040|1074|1163|"
		Else
			lOrgPub := cNatJur $ "1015|1040|1074|1163|1341|"
		EndIf

	EndIf

	//Novo Tratamento para se caso o emissor for Produtor Rural, deve registrar o CPF p/ envio do S-1000
	If (TAFColumnPos( "C1E_NRCPF" ) .And. TAFColumnPos( "C1E_PRDRUR" ))

		If Alltrim(cAlias) != "C1E"
			lPrdRural := (AllTrim(Posicione("C1E",3,xFilial("C1E")+PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] )+"1","C1E_PRDRUR")) == "1")
		Else
			lPrdRural := C1E->C1E_PRDRUR == "1"
		EndIf

		If lPrdRural

			If Alltrim(cAlias) != "C1E"
				cCGCPr := Posicione("C1E",3,xFilial("C1E")+PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] )+"1","C1E_NRCPF")
			Else
				cCGCPr := C1E->C1E_NRCPF
			EndIf

			If !EMPTY(cCGCPr)
				cCGC 		:= AllTrim(cCGCPr)
				cTpInscr	:= IIf(Len(cCgc) == 14,"1","2")
			EndIf

		EndIf

	EndIf

	If Len(cCGC) == 11 .Or. SM0->M0_TPINSC == 3 //Cpf
		cId := "ID" + cTpInscr + PadR(cCGC ,14 ,"0" ) + DTOS(date()) + StrTran(Time(),":","") + cSeq
	Else //Mantem o mesmo padrao
		cId := "ID" + cTpInscr + IIf(cTpInscr == "2",cCGC,IIf(lOrgPub,cCGC,PADR(Substr(cCGC,1,8),14,"0"))) + DTOS(date()) + StrTran(Time(),":","") + cSeq
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

	aEvtTafRt := TAFRotinas("S-"+cLayout,4,.F.,2)

	If aEvtTafRt[12] == "C"
		cTipo := "TABELA"
	ElseIf aEvtTafRt[12] == "M"
		cTipo := "MENSAL"
	ElseIf aEvtTafRt[12] == "E" .OR. aEvtTafRt[12] == "I"
		cTipo := "EVENTO"
	ElseIf	aEvtTafRt[12] == "T"
		cTipo := "TOTALIZADORES"
	EndIf

	If cTipo $ "EVENTO|MENSAL"

		If lSimplif

			cEventos :=  "1295|1298|1299|3000|3500|2555"

		Else

			cEventos :=  "2190|1295|1298|1299|3000"

		EndIf

		If (cAlias)->( &(cAlias + "_EVENTO") ) $ "I|F"

			If !(cLayout $ cEventos)
				cIdeEvento += xTafTag("indRetif","1")
			EndIf

		Else

			If !(cLayout $ cEventos)
				cIdeEvento += xTafTag( "indRetif" ,"2" )
				cIdeEvento += xTafTag( "nrRecibo" , ( cAlias )->( &( cAlias + "_PROTPN" ) ) )
			EndIf

		EndIf

		If cTipo == "MENSAL" .OR. ( cTipo == "EVENTO" .AND. cLayout	== "1295" )

			If (Len( aMensal ) == 2 .OR. Len( aMensal ) == 3) .AND. cLayout != "1270"

				If lSimplif .AND. cLayout == "1260" 
					cIdeEvento += xTafTag( "perApur"	 , aMensal[ 2 ] )
				Else
					cIdeEvento += xTafTag( "indApuracao" , aMensal[ 1 ] )
					cIdeEvento += xTafTag( "perApur"	 , aMensal[ 2 ] )
				EndIf

			ElseIf Len( aMensal ) == 2 .AND. (!lSimplif .AND. cLayout == "1270")

				cIdeEvento += xTafTag( "indApuracao" , aMensal[ 1 ] )
				cIdeEvento += xTafTag( "perApur"	 , aMensal[ 2 ] )

			ElseIf lSimplif .AND. cLayout == "1210" 

				cIdeEvento += xTafTag( "perApur"	 , aMensal[ 1 ] )

			Else

				cIdeEvento += xTafTag( "perApur"	 , aMensal[ 2 ] )

			EndIf

		EndIf

	ElseIf cTipo  $ "TOTALIZADORES"

		If cLayout == "5001"

			cIdeEvento += xTafTag( "nrRecArqBase"	, aMensal[1],, .T. )
			cIdeEvento += xTafTag( "indApuracao"	, aMensal[2] )
			cIdeEvento += xTafTag( "perApur"		, aMensal[3] )

		ElseIf cLayout == "5002"

			cIdeEvento += xTafTag( "nrRecArqBase"	, aMensal[1],, .T. )
			cIdeEvento += xTafTag( "perApur"		, aMensal[2] )

		ElseIf cLayout == "5003"

			cIdeEvento += xTafTag( "nrRecArqBase"	, aMensal[1],, .T. )
			
			If lSimplif
				cIdeEvento += xTafTag( "indApuracao"	, aMensal[2] )
				cIdeEvento += xTafTag( "perApur"		, aMensal[3] )
			Else
				cIdeEvento += xTafTag( "perApur"		, aMensal[2] )
			EndIf

		ElseIf cLayout == "5011"

			cIdeEvento += xTafTag( "indApuracao"	, aMensal[1] )
			cIdeEvento += xTafTag( "perApur"		, aMensal[2] )

		ElseIf cLayout == "5012"

			cIdeEvento += xTafTag( "perApur"		, aMensal[1] )

		ElseIf cLayout == "5013"

			If lSimplif
				cIdeEvento += xTafTag( "indApuracao"	, aMensal[1] )
				cIdeEvento += xTafTag( "perApur"		, aMensal[2] )
			Else
				cIdeEvento += xTafTag( "perApur"		, aMensal[1] )
			EndIf

		ElseIf cLayout == "5501"

			cIdeEvento += xTafTag( "nrRecArqBase"	, aMensal[1],, .T. )

		EndIf

	EndIf

	cXml += cTagInicio
	cXml += 	"<evt" + cTagReg + " Id='" + cId + "'>"
	cXml += 		"<ideEvento>"
	cXml += 				cIdeEvento

	If lSimplif .AND. cLayout $ "2299|2399|1260|1270|1280|1298|1299|1200|1210" // Tratamento para simplificação do e-Social
	
		If TAFColumnPos(cAlias+"_TPGUIA") .AND. !Empty((cAlias)->&(cAlias+"_TPGUIA"))
			cXml += xTafTag("indGuia",(cAlias)->&(cAlias+"_TPGUIA"))
		EndIf

	EndIf

	If !(cLayout $ "5001|5002|5003|5011|5012|5013|5501")

		cXml +=				xTafTag("tpAmb",cTpAmb)
		cXml +=				xTafTag("procEmi","1")
		cXml +=				xTafTag("verProc",cVerProc)

	EndIf

	cXml +=			"</ideEvento>"

	If !Empty(cRegistrador)
		cXml +=	cRegistrador
	EndIf

	cXml +=			"<ideEmpregador>"
	cXml +=				xTafTag("tpInsc",cTpInscr)

	If lSimplIf

		If (cTpInscr == "1" .And. !lOrgPub) .Or. (cTpInscr == "1" .And. cNatJur $ "1104|1139|1252|1317|")  
			cXml +=	xTafTag("nrInsc",Substr(cCGC,1,8))
		ElseIf cTpInscr == "1" .And. lOrgPub
			cXml +=	xTafTag("nrInsc",AllTrim(Substr(cCGC,1,14)))
		Else
			cXml +=	xTafTag("nrInsc",AllTrim(cCGC))
		EndIf

	Else

		cXml +=	xTafTag("nrInsc",IIf (cTpInscr == "1",IIf(lOrgPub,cCGC,Substr(cCGC,1,8)),cCGC))

	EndIf

	If cLayout $ "2500"

		If TAFColumnPos(cAlias+"_TPINSC") .AND. !Empty((cAlias)->&(cAlias+"_TPINSC"))

			If TafLayESoc("S_01_03_00") .And. TAFColumnPos(cAlias+"_DTADMR")

				xTAFTagGroup( "ideResp";
						, {{ "tpInsc", (cAlias)->&(cAlias + "_TPINSC"),, .F. };
						,  { "nrInsc", (cAlias)->&(cAlias + "_NRINSC"),, .F. };
						,  { "dtAdmRespDir", (cAlias)->&(cAlias + "_DTADMR"),, .T. };
						,  { "matRespDir", (cAlias)->&(cAlias + "_MATRDI"),, .T. }};
						, @cXml )
			Else

				xTAFTagGroup( "ideResp";
							, {{ "tpInsc", (cAlias)->&(cAlias + "_TPINSC"),, .F. };
							,  { "nrInsc", (cAlias)->&(cAlias + "_NRINSC"),, .F. }};
							, @cXml )

			EndIf

		EndIf
		
	EndIf

	cXml +=			"</ideEmpregador>"
	cXml +=			cXmlLayout
	cXml += 	"</evt" + cTagReg + ">"
	cXml += "</eSocial>"

	cFilAnt := cFilBkp
	RestArea(aSM0Area)

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafTag
Facilitador para montar Tag de XML

@Param:
cTag		- Tag a ser enviada        (obrigatorio)
xConteudo	- Conteudo referente a Tag (obrigatorio)
cPicture	- Mascara para conteudos numericos com decimais
lHide		- Indica se a Tag nao deve ser enviada caso Conteudo esteja vazio
lEsocial	- Indica se deve ser formatado os campos númerico conforme o Esocial
lGeraZero	- Força a geração de uma tag numérica com valor 0 (zero)
lAtributo	- .T. = Atributo
			- .F. = Elemento

@Return:
cRet - Estrutura Xml da Tag

@author Felipe C. Seolin
@since 19/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xTafTag( cTag, xConteudo, cPicture, lHide, lEsocial,lGeraZero, lAtributo, lReinf )

	Local cRet := ""
	Local __lEspM := SuperGetMV("MV_TAFESPM",,.T.,)

	Default cPicture := ""
	Default lHide    := .F.
	Default lEsocial := .T.
	Default lReinf   := .F.
	Default lGeraZero := .F.
	Default lAtributo := .F.

	If ValType(xConteudo) == "C"

		If cTag == "matricula"
			If __lEspM
				xConteudo := AllTrim(xConteudo)
			Else
				xConteudo := RTrim(xConteudo)
			EndIf
		Else
			xConteudo := AllTrim(xConteudo)
		EndIf

		//Retira caracteres especiais/reservados descritos no manual do desenvolvedor e-Social.
		If FindFunction("TafNorStrES")
			xConteudo := TafNorStrES(xConteudo)
		EndIf

	ElseIf ValType(xConteudo) == "N"

		If xConteudo == 0 .And. !lGeraZero
			xConteudo := "" //Quando um campo numérico for vazio o mesmo não deve ser gerado caso lHide == .T.
		Else

			If lEsocial
				cPicture  := Strtran(cPicture, ",", "")
				xConteudo := Strtran(cValToChar( AllTrim( Transform( xConteudo , cPicture ) ) ) , ",", ".")
			
			elseif lReinf
				xConteudo := Strtran(cValToChar( AllTrim( Transform( xConteudo , cPicture ) ) ) , ".", "")

			Else
				xConteudo := cValToChar( AllTrim( Transform( xConteudo , cPicture ) ) )
				
			EndIf
		EndIf

	ElseIf ValType(xConteudo) == "D"
		xConteudo := IIf( Empty(xConteudo), "", SubStr(DToS(xConteudo),1,4) + "-" + SubStr(DToS(xConteudo),5,2) + "-" + SubStr(DToS(xConteudo),7,2) )
	EndIf

	If lAtributo .And. (!Empty(xConteudo) .or. !lHide)
		cRet := " " + cTag + '="'+ xConteudo + '"'
	ElseIf !Empty(xConteudo) .or. !lHide
		cRet := "<" + cTag + ">" + xConteudo + "</" + cTag + ">"
	EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafGerXml
Funcao para criar arquivo XML

@Param	cXml	-	Xml especifico do Layout, a ser gravado como arquivo
		cLayout	-	Layout sem o "S-" / Exemplo: S-1010 -> "1010"
		cPath	-	Caminho para extração dos arquivos definido previamente
					pelo usuario ou atraves do sistema
		lLote	-	Indica se o processo esta sendo gerado para um lote de
					arquivos XML, pois neste caso deve acrescentar ao nome
do arquivo um ID, visto que pode ser gerado mais de um arquivo
					por segundo.
		lRetMsg	-	Define se exibe um Aviso ao termino da geração ou retorna
			  		o mesmo.
		nSeq	-	Sequencial de geração, quando é gerado os Xmls em lote
			  		é necessário para evitar duplicidade dos arquivos gerados
			  		no mesmo segundo.
		cFile	-
		cSigla	-	Sigla da Obrigação Fiscal para nomenclatura do arquivo.

@Return:

@author Felipe C. Seolin
@since 20/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xTafGerXml( cXml as Character, cLayout as Character, cPath as Character, lLote as Logical, lRetMsg as Logical, nSeq as Numeric, cFile as Character,;
					 cSigla as Character, cFil as Character, lXmlErp as Logical, aArquivos as Array )

	Local aArea      as Array
	Local cFileXml   as Character
	Local cMsg       as Character
	Local cStartPath as Character
	Local nHandle    as Numeric

	Default cXml      := ""
	Default cLayout   := ""
	Default cFil      := ""
	Default cPath     := ""
	Default lLote     := .F.
	Default lRetMsg   := .T.
	Default nSeq      := 0
	Default cFile     := ""
	Default cSigla    := "S-"
	Default lXmlErp   := .F.
	Default aArquivos := {}

	aArea      := GetArea()
	cFileXml   := ""
	cMsg       := ""
	cStartPath := GetSrvProfString( "StartPath", "\system\" )
	nHandle    := 0

	//Tratamento para Linux onde a barra eh invertida
	If GetRemoteType() == 2

		If !Empty( cStartPath ) .and. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "/" )
			cStartPath +=	"/"
		EndIf

	Else

		If !Empty(cStartPath) .and. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "\" )
			cStartPath +=	"\"
		EndIf

	EndIf

	//se o parâmetro nSeq estiver preenchido significa que o sequencial do arquivo está sendo controlado manualmente na chamada da função
	If nSeq > 0 .And. Empty(cFil)

		cFile    := AllTrim(StrTran(AllTrim(cEmpAnt)," ","") + "_" + AllTrim(cFilAnt) + "_" + cSigla + cLayout + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","")) + StrZero(nSeq,8) + ".xml"

	ElseIf nSeq > 0 .And. !Empty(cFil)

		cFile    := AllTrim(StrTran(AllTrim(cEmpAnt)," ","") + "_" + AllTrim(cFil) + "_" + cSigla + cLayout + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","")) + StrZero(nSeq,8) + ".xml"

	ElseIf lXmlErp

		cFile    := AllTrim(StrTran(AllTrim(cEmpAnt)," ","") + "_" + AllTrim(cFilAnt) + "_" + cSigla + cLayout + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","")) + StrZero(nSeq,8) + "_erp_.xml"
	
	//se a chamada desta função não controlar o nSeq e estiver gerando em lote acrescento um id unico por arquivo no nome, pois serao gerados varios por segundo
	ElseIf !lLote

		cFile    := AllTrim(StrTran(AllTrim(cEmpAnt)," ","") + "_" + AllTrim(cFilAnt) + "_" + cSigla + cLayout + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","")) + ".xml"

	Else
		cFile    := AllTrim(StrTran(AllTrim(cEmpAnt)," ","") + "_" + AllTrim(cFilAnt) + "_" + cSigla + cLayout + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","")) + "_" + fwuuid( "TAF_XML" ) + ".xml"

	EndIf

	If Empty( cPath )

		If ! (GetRemoteType() ==  5) .and. !isBlind()
			cStartPath	:= cGetFile( "Diretório" + "|*.*" , "Procurar" , 0, , .T. , GETF_LOCALHARD + GETF_RETDIRECTORY , .T. ) 
		EndIf

		cFileXml := cStartPath + cFile

	Else

		cStartPath := cPath
		cFileXml := cPath + cFile

	EndIf

	If !Empty(cStartPath)

		nHandle := MsFCreate(cFileXml)

		If nHandle < 0

			If Empty(cMsg)
				Aviso(STR0001,STR0002 + cFile + "." + STR0003 + cValToChar( FError() ),{STR0004},3) //"Geração de Arquivo Xml" ### "não foi possível criar o arquivo: " ### "Erro: " ### "Ok"
			Else
				cMsg := STR0002 + cFile + "." + STR0003 + cValToChar( FError())
			EndIf

		Else

			WrtStrTxt( nHandle, cXml )

			FClose( nHandle )

			If ( getRemoteType() == REMOTE_HTML )

				If !lLote
					nHandle := CpyS2TW( cStartPath + cFile , .T. )
					
					cMsg := STR0002 + cStartPath + cFile //"Não foi possível criar o arquivo: "

					If (nHandle == 0)
						cMsg := STR0013 + cFile //"Download concluído com sucesso do arquivo: "
					EndIf

					MsgAlert(cMsg)
					cMsg := ""
					Ferase(cStartPath + Lower(cFile))

				Else

					aAdd(aArquivos, cStartPath + Lower(cFile))

				EndIf

			Else

				//Se estiver gerando em lote ou esperando retorno, não devo alertar
				If lLote .or. !lRetMsg
					cMsg := STR0005 + cFile + " " + STR0006 + cPath + "."
				Else
					Aviso( STR0001, STR0005 + cFile + " " + STR0006 + cStartPath + ".", { STR0004 }, 3 ) //##"Geração de Arquivo Xml" ##"Arquivo: " ##"gerado com sucesso no Diretório: " ##"Ok"
				EndIf
				
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return( cMsg )

//-------------------------------------------------------------------
/*{Protheus.doc} FTafVldOpe

Valida se a operacao desejada pode ser realizada e retorna os campos
obrigatorios de controle da tabela ( Filial, Id, Versao Anterior )

@parametros:
cAlias    	- Alias a ser gravado
nInd      	- Indice de busca da chave unica na tabela
nOpc 	   	- Operacao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv    	- Filial de Origem do ERP, se informado sera consultada a filial de referencia
do TAF na tabela C1E
aIncons	- Array para gravacao das inconsistencias
cId		   	- No caso de se tratar de uma alteracao que ja foi previamente transmitida ao RET
             retorno o ID do REG anterior para gravacao do novo evento
cVerAnt	- No caso de se tratar de uma alteracao que ja foi previamente transmitida ao RET
             retorno a versao anterior do registro para gravacao no novo evento.
aChave    	- Chave de busca do registro na tabela
cProtocolo	- Numero do protocolo de historico do registro
oModel		- Objeto a ser criado para manutenir as informacoes
cNomModel	- Nome do Model
cCmpsNoUpd	- Campos que nao devem ser alterados no caso de Exclusao jah transmitida
nIndIDVer	- Indice para busca do registro anterior. Deve ser o indice da tabela contemplando ID + VERSAO
lRuleEvCad	- Indica se o registro se refere aos eventos cadastrais
aNewData	- Conteudo da tag novaValidade para operacoes da alteracao de eventos cadastrais
cMatTrab	- Matrícula do funcionário, quando não for evento de funcionário ignorar esse parâmetro.
nRecnoReg 	- Recno do evento (Usado em posicionamentos de registros predecessores)

@Retorno:
lValido - Indica se a operacao desejada pode ser realizada
		  ou nao

@author Rodrigo Aguilar
@since 23/09/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function FTafVldOpe( cAlias as Character, nInd as Numeric, nOpc as Numeric, cFilEv as Character, aIncons as Array, aChave as Array, oModel as Object,;
					 cNomModel as Character, cCmpsNoUpd as Character, nIndIDVer as Numeric, lRuleEvCad as Logical, aNewData as Array, cMatTrab as Character,;
					 nRecnoReg as Numeric, lTermAfas as Logical, cCmpsRemSimp as Character )

	Local aCpyCmps   as Array
	Local aDatas     as Array
	Local cChave     as Character
	Local cEvento    as Character
	Local cFilBkp    as Character
	Local cFilTAF    as Character
	Local cId        as Character
	Local cProtocolo as Character
	Local cVerAnt    as Character
	Local lRegTrans  as Logical
	Local lValido    as Logical
	Local nlI        as Numeric
	Local nOpcOri    as Numeric

	Default aChave       := {}
	Default cCmpsNoUpd   := ""
	Default cCmpsRemSimp := ""
	Default cMatTrab     := ""
	Default cNomModel    := ""
	Default lRuleEvCad   := .F.
	Default lTermAfas    := .F.
	Default nInd         := 1
	Default nIndIDVer    := 1 // Por default para as novas tabelas do eSocial, sempre sera o indice 1
	Default nRecnoReg    := 0

	aCpyCmps   := {}
	aDatas     := Array( 02 )
	cChave     := ""
	cEvento    := ""
	cFilBkp    := cFilAnt
	cFilTAF    := ""
	cId        := ""
	cProtocolo := ""
	cVerAnt    := ""
	lRegTrans  := .F.
	lValido    := .T.
	nlI        := 0
	nOpcOri    := 0

	//No bloco abaixo busco a filial de destino das informacoes de
	//importacao
	If !Empty( cFilEv )

		cFilTAF := FTafGetFil( cFilEv, @aIncons, cAlias, .T. )

		//Caso eu encontre a filial de destino da importacao alimento
		//a variavel cFilAnt
		If  !Empty(cFilTAF)

			//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			// Caso a tabela (cAlias) esteja compartilhada em algum nivel, a funcao FTafGetFil não traz a informação completa da filial, prejudicando a atribuicao do cFilAnt.
			// Identificada a situação, chama-se novamente a funcao FTafGetFil sem passar o parâmetro de cAlias, para a rotina consultar a C1E
			//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			If Len(AllTrim(cFilAnt)) <> Len(AllTrim(cFilTAF))
				cFilTAF := FTafGetFil( cFilEv, @aIncons, , .T. )
			EndIf

			If  !Empty(cFilTAF)
				cFilAnt := cFilTAF
			EndIf

		EndIf

		//----------------------------------------------------------------------
		//|Funcao para verificar o status atual do registro a ser manutenido,  |
		//|retornando o codigo da operacao que sera realizada na sequencia     |
		//|Opcoes de retorno do nOpc:										   |
		//|															           |
		//|4 - Alterar, registro nao transmitido						 	   |
		//|5 - Excluir, registro nao transmitido	     					   |
		//|6 - Alterar, registro ja transmitido  							   |
		//|7 - Excluir, registro ja transmitido								   |
		//|9 - Contem Inconsistencias                           			   |
		//----------------------------------------------------------------------
		nOpc := TAFRegStat( nOpc, cAlias, aChave, nInd, @cId, @cVerAnt, @aIncons, @cProtocolo, @lRegTrans, @cEvento, nIndIDVer, @cChave, @oModel, @aDatas, lRuleEvCad, aNewData, cMatTrab, cNomModel, nRecnoReg, lTermAfas )

		//Caso a operacao seja valida
		If nOpc <> 8 .and. nOpc <> 9

			//lValido := !Empty( cFilTAF )

			nOpcOri := nOpc

			//Caso tenha encontrado a filial de Destino das informacoes
			If lValido

				If lRegTrans

					//Seto registro corrente como Inativo
					FAltRegAnt( cAlias, "2" )
					nOpc := 3
				EndIf

				If !cNomModel $ "TAFA425|TAFA521"
					//Funcao para criacao do Model de integracao de acordo com a operacao a ser realizada
					FCModelInt( cAlias, cNomModel, @oModel, nOpc, cId,lRegTrans )
				EndIF

				//Tratamento de data de vigencia para registros cadastrais ( S-1010 / S-1080 )
				If lRuleEvCad
					If lRegTrans
						xAltDates( cAlias, @oModel, nOpcOri, aDatas, aNewData, lRegTrans )
					Else
						xAltDates( cAlias, @oModel, nOpc, aDatas, aNewData, lRegTrans )
					EndIf
				EndIf

				If nOpcOri == 7
					nOpc := nOpcOri
				EndIf

				//Quando se tratar de uma alteracao/Exclusao eu mantenho algumas informacoes do registro anterior
				If lRegTrans
					oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_ID", cId )
					oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERANT", cVerAnt )
					If TAFColumnPos( cAlias + "_PROTPN" )
						oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_PROTPN", cProtocolo )
					EndIf
				EndIf

				//Quando se tratar de uma inclusao nao deve alterar o Evento
				If !Empty( cEvento )
					oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_EVENTO", cEvento )
				EndIf

				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5 .and. !cNomModel $ "TAFA425|TAFA521"

					//Quando não é um novo registro não se deve alterar a versão.
					oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_FILIAL", xFilial( cAlias ) )
					If nOpc == 3 .Or. nOpc == 7
						oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERSAO", xFunGetVer() )
					EndIf

					//Caso se trate de uma exclusao apenas as datas iniciais e finais
					//sao declaradas no aRules, sendo assim preciso gravar as demais
					//informacoes que estao em memoria do registro atual, replicando as
					//mesmas para o novo registro criado
					If nOpc == 7
					
						DbSelectArea( cAlias )
						aCpyCmps := DbStruct()

						For nlI := 1 To Len( aCpyCmps )
							If !( aCpyCmps[ nlI, 01 ] $  cCmpsNoUpd  ) .And. !( aCpyCmps[ nlI, 01 ] $ cCmpsRemSimp )
								oModel:LoadValue( "MODEL_" + cAlias , aCpyCmps[ nlI, 01 ], (cAlias)->&( aCpyCmps[ nlI, 01 ] ) )
							EndIf
						Next

						If cNomModel == "TAFA050"

							oModel:LoadValue( "MODEL_C1E", "C1E_FILTAF", C1E->C1E_FILTAF )
							oModel:LoadValue( "MODEL_C1E", "C1E_CODFIL", C1E->C1E_CODFIL )

						ElseIf cNomModel == "TAFA051"

							oModel:LoadValue( "MODEL_C1G", "C1G_ESOCIA", "1" )
							oModel:LoadValue( "MODEL_C1G", "C1G_FILIAL", C1G->C1G_FILIAL )

						EndIf

						If TAFColumnPos( cAlias + "_XMLID" )
							oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_XMLID",'')
						EndIf

						//Limpa o campo referente ao protocolo
						If TAFColumnPos( cAlias + "_PROTUL" )
							oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_PROTUL", ' ' )
						EndIf
					EndIf
				EndIf

				nOpc := nOpcOri

				If nOpc == 4 .Or. nOpc == 6
					nOpc := 4
				ElseIf nOpc == 5 .or. nOpc == 7
					nOpc := 5
				EndIf
				
			EndIf
		Else
			lValido := .F. 
		EndIf
	Else
		Aadd( aIncons, "Não foi informada a Filial de referência do ERP para importação das informações no TAF." )
	EndIf

	aSize( aCpyCmps, 0 )
	aCpyCmps   := Nil
	//VOLTA BACKUP DA VARIAVEL CFILANT
	cFilAnt	:= cFilBkp

Return ( lValido )

//-------------------------------------------------------------------
/*/{Protheus.doc} FTafGetVal

Verifica se a TAG do XML foi informada, se sim, retorna o conteudo
da mesma para gravacao ja convertido de acordo com o tipo desejado

@Param:
uInfoObjto		- Informacao do arquivo XML a ser retornada
cTipoCmp		- Tipo esperado pela chamada da funcao
lInfoConv		- Indica se a informacao ja esta pronta para grvacao, ou seja,
			 	  se .T. basta gravar a informacao da variavel uInfoObjto sem
			 	  macroexecutar o XML
aIncons		- Array com as inconsistencias encontradas
lInfoObrig		- Indica se o Noh eh obrigatoria na importacao
cNomeNo		- Nome do Noh que deve ser informado, esta informacao servira para
			 	  compor o Help do Campo
cNomCmp		- Nome do campo que esta sendo executado, tratamento para que quando a
			 	  informacao enviada seja Vazia mantenho o valor corrente do campo.

lFormatNum		- Indica se deve formatar o numero do padrao brasileiro (ex.: 1.900,00)
			 	  para o padrao americano se separador de milhar (ex.: 1900.00)

@Return
cRet 	   - Informacao a ser gravada

@author Rodrigo Aguilar
@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FTafGetVal( uInfoObjto as Variante, cTipoCmp as Character, lInfoConv as Logical, aIncons as Array, lInfoObrig as Logical, cNomeNo as Character,;
					 cNomCmp as Character, lFormatNum as Logical, lEmpty as Logical, lAtributo as Logical, cTag as Character )

	Local cArrObjto as Character
	Local uRet      as Variant

	Default cTipoCmp   := "C"
	Default lInfoConv  := .F.
	Default lInfoObrig := .F.
	Default cNomeNo    := ""
	Default cNomCmp    := ""
	Default lFormatNum := .T.
	Default lEmpty     := .F.
	Default lAtributo  := .F.

	cArrObjto := ""
	uRet      := ""

	If __lEspM == Nil
		__lEspM     := SuperGetMV("MV_TAFESPM",,.T.,)
	EndIf

	If !lInfoConv

		If !lAtributo .And. oDados:XPathHasNode( uInfoObjto )

			If  "/matricula" $ uInfoObjto

				If __lEspM
					uRet := AllTrim( oDados:XPathGetNodeValue( uInfoObjto ) )
				Else
					uRet := RTrim( oDados:XPathGetNodeValue( uInfoObjto ) )
				EndIf

			Else

				uRet := AllTrim( oDados:XPathGetNodeValue( uInfoObjto ) )

			EndIf

			// Transforma a data que vem do XML no formato AAAA-MM-DD para Char DD/MM/AAAA
			If cTipoCmp == "D"
				uRet := TAFGetData( uRet, "DDMMAAAA", "/" )
			EndIf

		// Ajuste efetuado para contemplar a verificação de varios pagamentos no XML S-1200 na Integracao.
		ElseIf uInfoObjto == "/eSocial/evtRemun/dmDev/codCateg" .And. ValType(oDados:XPathGetAttArray( "/eSocial/evtRemun/dmDev" )) == "A"

			//Retorna a primeira posição da ARRAY, pois nao existe varias categorias.
			cArrObjto	:=  "/eSocial/evtRemun/dmDev[1]/codCateg"
			uRet := Alltrim( oDados:XPathGetNodeValue( cArrObjto ) )

		ElseIf lAtributo .And. oDados:XPathHasAtt( uInfoObjto )

			uRet := oDados:xPathGetAtt( uInfoObjto, cTag )

			// Transforma a data que vem do XML no formato AAAA-MM-DD para Char DD/MM/AAAA
			If cTipoCmp == "D"
				uRet := TAFGetData( uRet, "DDMMAAAA", "/" )
			EndIf

		ElseIf lInfoObrig

			Aadd( aIncons, " O Nó " + uInfoObjto + " não foi preenchido e é uma informação " +;
				" obrigatória para a importação" )

		EndIf

	Else

		uRet := uInfoObjto

	EndIf

	If lLaySimplif .And. (cTipoCmp == "C" .AND. Valtype(uInfoObjto) == "C")

		If "/nrInsc" $ uInfoObjto
			uRet := alltrim(SUBSTR(uRet, 1,14))
		EndIf

	EndIf

	//Caso seja enviada uma informacao vazia nao se deve apagar
	//a informacao corrente da tabela
	If !Empty( uRet )

		//Tratamento para que o retorno esteja de acordo com o esperado
		//pela chamada da funcao
		If Valtype( uRet ) <> cTipoCmp

			If cTipoCmp == "D"

				uRet := CToD( uRet )

			ElseIf cTipoCmp == "N"

				If lFormatNum .AND. At(',',uRet) > 0

					uRet := Val( StrTran( StrTran( uRet, ".", "" ), ",", "." ) )

				Else

					uRet := Val( uRet )

				EndIf

			EndIf

		EndIf

		lEmpty := .F.

	Else

		If cTipoCmp == "D"

			uRet := StoD("")

		ElseIf cTipoCmp == "N"

			uRet := 0

		EndIf

		lEmpty := .T.

	EndIf

Return ( uRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FTafGetFil

Funcao para retornar a filial para onde as informacoes de integracao serao
importadas

@param
	cSeekFil  - CNPJ ou Filial a ser verificada a existencia
	aIncons   - Array contendo as inconsistencias encontradas
	cAliasTAF - Alias que esta em processamento. Parametro utilizado
			    para indetificar as tabelas que estão compartilhadas
			    no sistema.

@return
	cFilTAF - Filial de Referencia do TAF

@obs Luccas ( 31/03/2016 ): Devido a mudança em relação ao compartilhamento das tabelas
do TAF ( inicialmente todas eram exclusivas, mas o cliente pode optar por ter tabelas
compartilhadas, por exemplo Plano de Contas, Centro de Custo, Itens, etc. ), as rotinas
de geração das obrigações e integração tiveram que ser alteradas ( em algumas situações ) para a
utilização da função xFilial ao invés da variável cFilSel.
Em relação as integrações, essa alteração foi feita na função FTAFGetFil().

@author Rodrigo Aguilar
@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FTafGetFil( cSeekFil, aIncons , cAliasTAF, lEsocial )

	Local aArea			:= GetArea()
	Local cFilTAF		:=	""	
	Local cNextAlias	:= GetNextAlias()
	Local cPadrSeek		:= ""
	Local nQtdRegs		:= 0
	Local lAddIncon		:= .F.

	Default	aIncons		:=	{}
	Default	cAliasTAF	:=	""
	Default lEsocial	:= .F.

	if __lCR9 == Nil
		__lCR9 := GetNewPar( "MV_TAFCFGE", .F. )
	endif

	If __cFilC1E == Nil .or. !Empty(Alltrim(__cFilC1E))
		__cFilC1E := xFilial("C1E")
	EndIf

	If __nTamFilC1E == Nil
		__nTamFilC1E := TamSX3("C1E_CODFIL")[1]
	EndIf
	
	If __nTamCR9Fil == Nil
		__nTamCR9Fil := TamSX3( "CR9_CODFIL" )[1] 
	EndIf
	
	if __nSizeFil == Nil 
		__nSizeFil := FWSizeFilial() 
	endif

	cPadrSeek		:= PadR( cSeekFil, __nTamCR9Fil)

	//Caso a tabela seja compartilhada no nivel de filial, devo utilizar o xFilial ao invés do
	//conteudo cadastro no Complemento de Empresa.
	If !Empty( cAliasTAF ) .And. FWModeAccess( cAliasTAF ) == "C"
		cFilTAF	:=	xFilial( cAliasTAF )
	Else

		// Validação para verificar se existe C1E ( De/Para ) para
		// a filial em que as informações serão importadas
		If C1E->( IndexOrd() ) <> 7
			C1E->( DBSetOrder( 7 ) )
		EndIf

		If __lCR9 .And. lESocial

			If !VerDuplC1E()

				If Select(cNextAlias) > 0
					(cNextAlias)->( dbCloseArea() )
				EndIf

				BeginSQL Alias cNextAlias
				SELECT C1E_FILTAF
				FROM %table:CR9% CR9
				INNER JOIN %table:C1E% C1E
				ON C1E_FILIAL = CR9_FILIAL AND C1E_ID = CR9_ID
				WHERE CR9_CODFIL = %exp:cPadrSeek%
				AND   CR9_ATIVO = '1'
				AND	  C1E_ATIVO = '1'
				AND	  CR9.%notdel%
				AND   C1E.%notdel%
				EndSQL

				(cNextAlias)->(dbEval({ || nQtdRegs++ }))

				If nQtdRegs > 1
					aAdd( aIncons,	STR0011 + STR0012 )
					lAddIncon := .T.
				Else

					(cNextAlias)->( dbGoTop() )

					// Verifica se encontrou a CR9, se não encontrou, busca na C1E
					If (cNextAlias)->( !Eof() )
						cFilTAF := (cNextAlias)->C1E_FILTAF
					Else

						If C1E->( MsSeek( __cFilC1E + PadR( cSeekFil, __nTamFilC1E ) + "1" ) )
							cFilTAF := C1E->C1E_FILTAF
						EndIf

					EndIf
				EndIf

				(cNextAlias)->( dbCloseArea() )
			Else
				aAdd( aIncons,	STR0011 + STR0012 )
				lAddIncon := .T.
			EndIf

		Else

			If C1E->( MsSeek( __cFilC1E + PadR( cSeekFil, __nTamFilC1E ) + "1" ) )
				cFilTAF := C1E->C1E_FILTAF
			Else
				//Tratamento para que quando a informação de filial de importação
				//esteja na tabela CR9 ela seja utilizada na integração

				BeginSQL Alias cNextAlias
				SELECT C1E_FILTAF
				FROM %table:CR9% CR9
				INNER JOIN %table:C1E% C1E
				ON C1E_FILIAL = CR9_FILIAL AND C1E_ID = CR9_ID
				WHERE CR9_CODFIL = %exp:cPadrSeek%
				AND   CR9_ATIVO = '1'
				AND	  C1E_ATIVO = '1'
				AND	  CR9.%notdel%
				AND   C1E.%notdel%
				EndSQL

				(cNextAlias)->(dbEval({ || nQtdRegs++ }))

				If nQtdRegs > 1
					aAdd( aIncons,	STR0011 + STR0012 )
					lAddIncon := .T.
				Else
					(cNextAlias)->( dbGoTop() )

					// Verifica se encontrou a CR9, se não encontrou, gera log
					If (cNextAlias)->( !Eof() )
						cFilTAF := (cNextAlias)->C1E_FILTAF
					EndIf	
				EndIf

				(cNextAlias)->(DbCloseArea())

			EndIf
		EndIf
	EndIf

	//Só valido o retorno diferente de vazio caso a tabela seja exclusiva, do contrario o retorno pode ser "  "
	If Empty( cFilTAF ) .And. FWModeAccess( cAliasTAF ) == "E" .And. !lAddIncon
		//"Não foi encontrada a filial de referência do TAF para a importação das informações."
		//"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		aAdd( aIncons,	STR0007 + STR0008 )
	EndIf

	If !Empty( cFilTAF )
		cFilTAF := PadR( cFilTAF, __nSizeFil )
	EndIf
	RestArea(aArea)

Return( cFilTAF )

//-------------------------------------------------------------------
/*{Protheus.doc} TAFCodFilErp

Funcao responsavel por retornar os codigos de filial do ERP relacionados em uma empresa
cadastrada no TAF. Exemplo de cenario:

	|--	Empresa 01 --- C1E: Filial 01 --- De/para com ERP: 0101, 0102
	|			   --- C1E: Filial 02 --- De/para com ERP: 0103, 0104
TAF	|
	|
	|--	Empresa 02 --- C1E: Filial 01 --- De/para com ERP: 0201, 0202
				   --- C1E: Filial 02 --- De/para com ERP: 0203, 0204

O objetivo da funcao eh retornar o codigo das filiais do ERP relacionadas a empresa, neste caso
o retorno da funcao sera um array contendo: { "0101" , "0102" , "0103" , "0104" }

@Return aCodFil -> Array contendo todos os codigos de filial

@author Luccas Curcio
@since 26/05/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFCodFilErp()

	Local cSql 		:= ""
	Local aCodFil 	:= {}
	Local cFils 	:= GetNextAlias()
	Local aAreaC1E 	:= {}
	Local lExstC1E	:= .F.

	If __cFilC1E == Nil .or. !Empty(Alltrim(__cFilC1E))
		__cFilC1E := xFilial("C1E")
	EndIf

	If __nTamFilC1E == Nil
		__nTamFilC1E := TamSX3("C1E_CODFIL")[1]
	EndIf

	If __oPrepared == nil
		cSql := " SELECT C1E.C1E_CODFIL, CR9.CR9_CODFIL, C1E.C1E_FILTAF, C1E.C1E_NOME FROM " + RetSqlName("C1E") + " C1E "
		cSql += " LEFT JOIN " + RetSqlName("CR9") + " CR9 "
		cSql += " ON C1E.C1E_ID = CR9.CR9_ID AND C1E.C1E_VERSAO = CR9.CR9_VERSAO AND CR9.CR9_ATIVO = '1' AND C1E.C1E_CODFIL <> CR9.CR9_CODFIL AND CR9.D_E_L_E_T_ = ' ' "
		
		cSql += " WHERE C1E.C1E_FILTAF = ? "
		cSql += " AND C1E.C1E_ATIVO = '1' "
		cSql += " AND C1E.D_E_L_E_T_ = ' ' "

		cSql := ChangeQuery(cSql)
		__oPrepared:=FWPreparedStatement():New(cSql)
	Endif

	__oPrepared:SetString(1,cFilAnt)
	cSql := __oPrepared:GetFixQuery()

	cFils := MpSysOpenQuery(cSql,cFils,)

	If !Empty((cFils)->C1E_CODFIL)

		aAdd(aCodFil,AllTrim((cFils)->C1E_CODFIL))
		aAreaC1E 	:= C1E->(GetArea())
		
		C1E->( DbSetOrder(7) ) //C1E_FILIAL+C1E_CODFIL+C1E_ATIVO
		If (C1E->( DbSeek( __cFilC1E + PadR((cFils)->CR9_CODFIL, __nTamFilC1E ) + "1" ) ))
			lExstC1E := .T.
		EndIf

		If !Empty((cFils)->CR9_CODFIL) .and. !lExstC1E

			While (cFils)->(!Eof())
				aAdd(aCodFil,AllTrim((cFils)->CR9_CODFIL))
				(cFils)->(dbSkip())
			EndDo
		EndIf
		
		RestArea(aAreaC1E)
		
	EndIf

	(cFils)->(dbCloseArea())

Return aCodFil 

//-------------------------------------------------------------------
/*{Protheus.doc} FCModelInt

Funcao responsavel por carregar o Model da(s) tabela(s) a serem
populadas no momento da integracao

@Param
cAlias     - Alias da Tabela
cFonte 	   - Nome do Fonte referente ao Model
oModel     - Objeto Model a ser manipulado ( Deve ser criado na funcao Raiz )
nOperation - Operacao a ser realizada ( 3 - Inclusao, 4 - Alteracao, 5 - Exclusao )
cId		   - Id do modelo 
lRegTrans  - Informa se o Registro já foi transmitido.

@author Rodrigo Aguilar
@since 24/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FCModelInt( cAlias as Character, cFonte as Character, oModel as Object, nOperation as Numeric, cId as Character, lRegTrans as Logical )

	Local cIdAux    as Character
	Local lChangeId as Logical

	Default lRegTrans := .F.

	cIdAux    := ""
	lChangeId := .F.

	oModel := TAFLoadModel( cFonte, nOperation )

	If nOperation == 3 .and. !lRegTrans

		If !(cFonte $ "|TAFA275|TAFA276|TAFA277|TAFA261|") //Não é necessário verificar duplicidade de ID para os Eventos S-2205, S-2206, S-2230, S-2306.

			oModel:GetModel( "MODEL_" + cAlias )
			cIdAux 	:= oModel:GetValue( "MODEL_" + cAlias, cAlias + "_ID" )

			//Percorre o laço enquanto não encontrar o próximo numero disponivel no license.
			While !TAFCheckID(cIdAux,cAlias)

				If (cFonte $ "|TAFA250|TAFA407|TAFA477|")

					cIdAux := FWuuId(AllTrim(Str(ThreadID()))+FWTimeStamp(4)+StrTran(AllTrim(Str(Seconds())),".",""))

				Else

					TAFConout("Id " + cIdAux + " ja existente na tabela " + cAlias + " . Será realizado uma nova requisicao de numeração. ",3,.T.,"INTEG")

					&(cAlias)->(ConfirmSX8())
					cIdAux := GetSx8Num(cAlias,cAlias+"_ID")

				EndIf

				lChangeId := .T.

			EndDo

			If lChangeId
				oModel:LoadValue("MODEL_" + cAlias, cAlias + "_ID",cIdAux )
			EndIf

		EndIf

	EndIf

Return (.T.)

//-------------------------------------------------------------------
/*{Protheus.doc} TAFCheckID

Verifica se o Id já existe na Filial.

@param cId	  - Id a ser verificado
@param cAlias - Alias correspondente ao ID

@return lDuplicId - Se Falso, Indica que o ID já existe na base, neste caso é necessário abortar a
operação.

@author Evandro dos Santos O. Teixeira
@since 01/05/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFCheckID(cId,cAlias)

	Local lDuplicId := .F.
	Local cSql      := ""

	Default cId     := ""

	cSql := " SELECT Count(*) NIDS FROM " + RetSqlName(cAlias) 
	cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'"
	cSql += " AND " + cAlias + "_ID = '" + AllTrim(cId) + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	TcQuery cSql New Alias 'duplicId'

	If duplicId->NIDS > 0
		lDuplicId := .T. 
	EndIf

	duplicId->(dbCloseArea())

Return (!lDuplicId)

//-------------------------------------------------------------------
/*{Protheus.doc} FGetIdInt

Funcao responsavel por retornar os IDs para gravacao nas tabelas do TAF
durante a integracao

@Param
cFieldLay1   - Primeiro nome do campo do Layout do E-Social a que se
               refere a informacao
cFieldLay2   - Segundo nome do campo do Layout do E-Social a que se
			   refere a informacao
cInfo1       - Informacao referente ao primeiro campo informado
cInfo2       - Informazao referente ao segundo campo informado
lIdChave     - Indica se os valores indicados sao TAGs ou valores ja para
               execucao do Seek ( .T. = Tag ,  .F. = Valor )
aInfComp     - Array com os campos a mais da chave que devem ser
               incluidos na tabela auxiliar
cInconMsg 	 - Contem todas as inconsitencias encontradas
nSeqErrGrv	 - Número que indica a Sequencia do erro encontrado
lAtributo	 - Indica se o conteúdo a ser pesquisado é um elemento ou atributo
nPosChave	 - Posição inicial do trabalhador na chave enviada na tag nrRecEvt (S-3000) 

@Return
cId - Id do registro a ser gravado

@author Rodrigo Aguilar
@since 25/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGetIdInt(cFieldLay1 as character, cFieldLay2 as character, cInfo1 as character, cInfo2 as character, lIdChave as logical,; 
			aInfComp as array, cInconMsg as character, nSeqErrGrv as numeric, cFieldLay3 as character, cInfo3 as character,;
			lEmpty as logical, cFieldLay4 as character, cInfo4 as character, cPeriodo as character, lAtributo as logical,;
			nPosChave as numeric, cEvento as character)

	Local aIncons		as array
	Local aGrvInfo		as array
	Local cId      		as character
	Local cAlias		as character
	Local cCmpTab1 		as character
	Local cCmpTab2 		as character
	Local cAtivo   		as character
	Local cFonte   		as character
	Local cNmTag		as character
	Local cNmTag2		as character
	Local cValorTag		as character
	Local cValorTag2	as character
	Local cIdTpBen		as character
	Local cIdAux		as character
	Local cVersao		as character
	Local cIdProc		as character
	Local cMsgType		as character
	Local cNomEv		as character
	Local cCodCat		as character
	Local cCodCatInt	as character
	Local cXMLCodCat	as character
	Local cChvCPFMAT	as character
	Local cEventBen     as character
	Local dDtIni		as date
	Local dDtVld		as date
	Local dDtC99		as date
	Local dDtC92		as date
	Local lTauto		as logical
	Local lFindFunc		as logical
	Local nRecC92       as numeric
	Local nRecC99       as numeric
	Local nTamChave		as numeric
	Local nTamCPF		as numeric
	Local nOrder   		as numeric

	Default aInfComp   	:= {}
	Default cFieldLay1 	:= ""
	Default cFieldLay2 	:= ""
	Default cFieldLay3 	:= ""
	Default cFieldLay4	:= ""
	Default cInfo1     	:= ""
	Default cInfo2     	:= ""
	Default cInfo3     	:= ""
	Default cInfo4		:= ""
	Default cInconMsg  	:= ""
	Default cEvento		:= ""
	Default cPeriodo	:= SubString(DToS(dDatabase), 1, 6)
	Default lEmpty		:= .F.
	Default lAtributo	:= .F.
	Default lIdChave   	:= .T.
	Default nSeqErrGrv 	:= 0
	Default nPosChave	:= 0

	aIncons		:= {}
	aGrvInfo	:= {}
	cId			:= ""
	cAlias		:= ""
	cCmpTab1 	:= ""
	cCmpTab2 	:= ""
	cAtivo   	:= ""
	cFonte   	:= ""
	cNmTag		:= ""
	cNmTag2		:= ""
	cValorTag	:= ""
	cValorTag2	:= ""
	cIdTpBen	:= ""
	cIdAux		:= ""
	cVersao		:= ""
	cIdProc		:= ""
	cMsgType	:= ""
	cNomEv		:= ""
	cCodCat		:= ""
	cCodCatInt  := ""
	cXMLCodCat	:= ""
	cChvCPFMAT	:= ""
	cEventBen	:= "S2400"
	dDtIni		:= CToD("")
	dDtVld		:= CToD("")
	dDtC99		:= CToD("")
	dDtC92		:= CToD("")
	lTauto		:= .F.
	lFindFunc	:= .F.
	nRecC92		:= 0
	nRecC99		:= 0
	nTamChave	:= 0
	nTamCPF		:= 0
	nOrder		:= 2

	//Regra para os cenarios onde o obejto nao existe ( Integracao Protheus ) e/ou quando
	//a chave de busca forem IDs, nestes casos nao deve ser realizado o tratamento
	//do xPathGetNodeValue()
	lIdChave := IIf( lIdChave, IIf( Type( 'oDados' ) == 'U', .F., .T. ), .F. )

	//Busco os valores contidos nas TAG´s do XML
	If lIdChave

		If lAtributo .And. !Empty( cInfo1 )

			If oDados:XPathHasAtt( cInfo1 )
				cInfo1 := oDados:xPathGetAtt( cInfo1, cFieldLay1 ) 
			Else
				cInfo1 := ""
			EndIf

		EndIf

		If !Empty( cInfo1 ) .And. !lAtributo

			If oDados:XPathHasNode( cInfo1 )
				cInfo1 := oDados:XPathGetNodeValue( cInfo1 )
			Else
				cInfo1 := ""
			EndIf

		EndIf

		If lAtributo .And. !Empty( cInfo2 ) .And. Empty( cInfo1 )

			If oDados:XPathHasAtt( cInfo2 )
				cInfo2 := oDados:xPathGetAtt( cInfo2, cFieldLay2 ) 
			Else
				cInfo2 := ""
			EndIf

		EndIf

		If !Empty( cInfo2 ) .And. !lAtributo

			If oDados:XPathHasNode( cInfo2 )
				cInfo2 := oDados:XPathGetNodeValue( cInfo2 )
			Else
				cInfo2 := ""
			EndIf

		EndIf

		If !Empty( cInfo3 ) .And. oDados:XPathHasNode( cInfo3 )
			
			cInfo3 := oDados:XPathGetNodeValue( cInfo3 )
			cCodCatInt := cInfo3
			cInfo3 := Posicione( "C87", 2, xFilial("C87") + cInfo3, "C87_ID" )			
			
		EndIf

	EndIf

	//Verifico se a TAG enviada foi em branco
	If Empty(cInfo1) .AND. Empty(cInfo2) .AND. Empty(cInfo3)
		lEmpty := .T.
	Else
		lEmpty := .F.
	EndIf

	//Verifico se existem valores a serem processados
	If !Empty( cInfo1 ) .Or. !Empty( cInfo2 )

		//Afastamento Temporario CM6
		If cFieldLay1 == "cpfTrab" .and. cFieldLay2 == "codMotivoAnterior"

			cAlias   := "CM6"
			cCmpTab1 := "CM6_FUNC"
			cCmpTab2 := "CM6_MOTVAF"
			cAtivo   := "1"

		//Rubricas ( Tabela C8R )
		ElseIf cFieldLay1 == "codRubr" .and. cFieldLay2 == "ideTabRubr"

			cAlias   := "C8R"
			cCmpTab1 := "C8R_CODRUB"
			cCmpTab2 := "C8R_IDTBRU"
			cFonte   := "TAFA232"
			nOrder   := 6

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Rubricas ( Tabela C8R )
		ElseIf cFieldLay1 == "codRubr"

			cAlias   := "C8R"
			cCmpTab1 := "C8R_CODRUB"
			cFonte   := "TAFA232"
			nOrder   := 3

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Estabilidade Inicial CM5
		ElseIf cFieldLay1 == "IniEst"

			cAlias   := "CM5"
			cCmpTab1 := "CM5_TRABAL"
			cCmpTab2 := "CM5_CODEST"
			cAtivo   := "1"
			nOrder := 3

		//Beneficiario C9Z
		ElseIf cFieldLay1 == "cpfBeneficiario"

			cAlias   := "C9Z"
			cCmpTab1 := "C9Z_ID"
			cCmpTab2 := "C9Z_CPF"
			nOrder 	 := 3

		//Processo referenciado E-Social ( Tabela C1G )
		ElseIf (cFieldLay1 $ "tpProc|nrProc" .And. cFieldLay2 $ "nrProc|tpProc")

			cAlias   	:= "C1G"
			cCmpTab1	:= "C1G_TPPROC"
			cCmpTab2 	:= "C1G_NUMPRO"
			cFonte   	:= "TAFA051"
			If Alltrim(cInfo1) == "1"
				cInfo1 := "2"
			ElseIf Alltrim(cInfo1) == "2"
				cInfo1 := "1"
			Else
				cInfo1 := cInfo1
			EndIf
			cValorTag	:= cInfo2
			nOrder   	:= 9

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"
			cMsgType := 'chvComposta'

		//Processo referenciado E-Social ( Tabela C1G ) - Processo Judicial
		ElseIf (Empty(cFieldLay1) .Or. cFieldLay1 $ "ideProcessoIRRF|ideProcessoFGTS|ideProcessoSIND") .AND. (cFieldLay2 == "nrProcJud" .OR. cFieldLay2 == "nrProc")

			cAlias   := "C1G"
			cCmpTab1 := "C1G_TPPROC"
			cCmpTab2 := "C1G_NUMPRO"
			cFonte   := "TAFA051"

			If cFieldLay2 == "nrProcJud"
				cInfo1 := "1"
			EndIf

			cValorTag := cInfo2
			nOrder := 9

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Estabelecimento	( Tabela C92 )
		ElseIf cFieldLay1 $ "tpInsc|nrInsc" .And. cFieldLay2 $ "nrInsc|tpInsc"

			cAlias   := "C92"
			cCmpTab1 := "C92_TPINSC"
			cCmpTab2 := "C92_NRINSC"
			cValorTag := cInfo1
			cValorTag2 := cInfo2
			nOrder := 6

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"
			cMsgType := 'chvComposta'

		//Classificacao Tributaria ( Tabela C8D )
		ElseIf cFieldLay1 == "classTrib"

			cAlias   := "C8D"
			cCmpTab1 := "C8D_CODIGO"

		//Agente Químico ( Tabela CUA )
		ElseIf cFieldLay1 == "codAgenteQuimico"

			cAlias   := "CUA"
			cCmpTab1 := "CUA_CODIGO"

		//Material Biológico ( Tabela CUM )
		ElseIf cFieldLay1 == "codAnalise"

			cAlias   := "CUM"
			cCmpTab1 := "CUM_CODIGO"

		//Código Agente ( Tabela C98 )
		ElseIf cFieldLay1 == "codAgente"

			cAlias   := "C98"
			cCmpTab1 := "C98_CODIGO"

		//Tipo de Despesa ( Tabela CUV )
		ElseIf cFieldLay1 == "tpDespesa"

			cAlias   := "CUV"
			cCmpTab1 := "CUV_CODIGO"

		//Código Motivo Estabilidade (Tabela CUR)
		ElseIf cFieldLay1 == "codMotivoEstabilidade"

			cAlias   := "CUR"
			cCmpTab1 := "CUR_CODIGO"

		//Trabalhador ( Tabela C9V )
		ElseIf cFieldLay1 == "cpfTrab" .And. (Empty(cFieldLay2) .And. cFieldLay2 != "matricula") .And. cFieldLay3 != "codCateg"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_CPF"
			nOrder   := 4
			cAtivo := "1"
			cFonte   := 'TAFA473'

		//Trabalhador ( Tabela T0W )
		ElseIf cFieldLay1 == "cnpjOper"

			cAlias   := "T0W"
			cCmpTab1 := "T0W_CNPJOP"

		//Bancos ( Tabela C1V )
		ElseIf cFieldLay1 == "banco"

			cAlias   := "C1V"
			cCmpTab1 := "C1V_CODIGO"
			nOrder   := 1

		//Categoria de Trabalhador ( Tabela C87 )
		ElseIf cFieldLay1 $ "catTrabalhador|codCateg|categOrigem|categOrig"

			cAlias := "C87"
			cCmpTab1 := "C87_CODIGO"

			//Tabela de Carreiras Públicas ( Tabela T5K )
		ElseIf cFieldLay1 $ "codCarreira"

			cAlias		:= "T5K"
			cCmpTab1 	:= "T5K_CODIGO"
			cFonte   	:= "TAFA467"
			nOrder   	:= 4

		//Cargos ( Tabela C8V )
		ElseIf cFieldLay1 == "codCargo"

			cAlias   := "C8V"
			cCmpTab1 := "C8V_CODIGO"
			cFonte   := "TAFA235"
			nOrder	  := 5

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Funcoes ( Tabela C8X )
		ElseIf cFieldLay1 == "codFuncao"

			cAlias   := "C8X"
			cCmpTab1 := "C8X_CODIGO"
			cFonte   := "TAFA236"
			nOrder   := 4

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Código da Receita ( Tabela C6R )
		ElseIf cFieldLay1 $ "tpCR|CRMen|CRDia"

			If !cEvento $ "S-5501"

				cAlias   := "C6R"
				cCmpTab1 := "C6R_CODIGO"
				nOrder   := 1

			Else

				cAlias   := "V9T"
				cCmpTab1 := "V9T_CODIGO"
				nOrder   := 2
				
			EndIf

		//Funcoes ( Tabela C8X )
		ElseIf cFieldLay1 $ "rendTrib|retIR|dedIR|isenIR|demJud|nRetIrProc"

			cAlias   := "C8U"
			cCmpTab1 := "C8U_CODIGO"
			cFonte   := "TAFA234"

		//Tabela de Lotacoes ( Tabela C99 )
		ElseIf cFieldLay1 == "codLotacao"

			cAlias   := "C99"
			cCmpTab1 := "C99_CODIGO"
			nOrder   := 5
			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Horarios/Turnos de Trabalho ( Tabela C90 )
		ElseIf cFieldLay1 $ "codHorContrat|codJornadaSegSexta|codJornadaSab|codJornadaSeg|codJornadaTer|codJornadaQua|codJornadaQui|codJornadaSex|codJornadaSab|codJornadaDom|codJornada"

			cAlias   := "C90"
			cCmpTab1 := "C90_CODIGO"
			nOrder   := 4
			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Atestado de Saude Ocupacional ( Tabela C8B )
		ElseIf cFieldLay1 == "dtAsoAdm"

			cAlias   := "C8B"
			cCmpTab1 := "C8B_FUNC"
			cCmpTab2 := "C8B_DTASO"
			cFonte   := "TAFA258"

		//Tipo de Dependente ( Tabela CMI )
		ElseIf cFieldLay1 == "tpDep"

			cAlias   := "CMI"
			cCmpTab1 := "CMI_CODIGO"

		//Mot deslig.Diretor sem Vinculo ( Tabela CML )
		ElseIf cFieldLay1 == "mtvDesligTSV"

			cAlias   := "CML"
			cCmpTab1 := "CML_CODIGO"

		//Motivos de Desligamento ( Tabela C8O )
		ElseIf cFieldLay1 == "mtvDeslig"

			cAlias   := "C8O"
			cCmpTab1 := "C8O_CODIGO"

		//Grau Exposicao Agentes Nocivos ( Tabela C88 )
		ElseIf cFieldLay1 == "grauExp"

			cAlias   := "C88"
			cCmpTab1 := "C88_CODIGO"

		//Tipo de Contribuicao ( Tabela C8H )
		ElseIf cFieldLay1 == "tpContrib"

			cAlias := "C8H"
			cCmpTab1 := "C8H_CODIGO"

		//Municipios ( Tabela C07 )
		ElseIf cFieldLay1 $ "ufVara|uf|codMunic" .And. cFieldLay2 $ "codMunic|uf|ufVara"
			
			cAlias   := "C07"
			cCmpTab1 := "C07_UF"
			cCmpTab2 := "C07_CODIGO"
			nOrder   := 1
			cValorTag := cInfo2

			//No caso de busca de municipio tenho que antes buscar a UF a qual
			//o Municipio pertence, pois ela faz parte da chave unica da tabela
			If !Empty(cInfo2)
				cInfo1 := XFUNUFID( cInfo1 )
			EndIf

			//De acordo com o Layout do E-Social o cliente deve informar
			//o codigo do Municipio com o codigo da Unidade da Federacao
			//precedendo a informacao, sendo assim, preciso tratar a informacao
			//antes de efetuar o Seek
			If Len( cInfo2 ) > 5
				cInfo2 := Substr( cInfo2, 3, 5 )
			EndIf

		//Unidades da Federacao ( Tabela C09 )
		ElseIf cFieldLay1 $ "uf|ufCtps|ufCnh|ufVara|ufCRM"

			cAlias   := "C09"
			cCmpTab1 := "C09_UF"
			nOrder   := 1

		//Indicativo de Comercialização: ( Tabela T1T )
		ElseIf cFieldLay1 $ "indComerc"

			cAlias   := "T1T"
			cCmpTab1 := "T1T_CODIGO"

		//Países Bco Central/SISCOMEX ( Tabela C08 )
		ElseIf cFieldLay1 $ "paisNascto|paisNacionalidade|paisResidencia|codPais|paisResidExt"

			cAlias   := "C08"
			cCmpTab1 := "C08_PAISSX"
			nOrder   := 4

		//Codigo Brasileiro de Ocupacao ( Tabela C8Z )
		ElseIf cFieldLay1 $ "codCBO|CBOCargo|CBOFuncao"

			cAlias   := "C8Z"
			cCmpTab1 := "C8Z_CODIGO"

		//Cod.Aliq.FPAS/Terceiros ( Tabela C8A )
		ElseIf cFieldLay1 == "fpas" .and. cFieldLay2 == "codTerceiros"

			cAlias     := "C8A"
			cCmpTab1   := "C8A_CDFPAS"
			cCmpTab2   := "C8A_CODTER"
			cValorTag2 := cInfo2
			cMsgType   := 'chvComposta'

		//Tipo de Logradouro   ( Tabela C06 )
		ElseIf cFieldLay1 $ "tpLogradouro|tpLograd"

			cAlias := "C06"
			cCmpTab1 := "C06_CESOCI"
			nOrder   := 4

		//Tipo de Lotação   ( Tabela C8F )
		ElseIf cFieldLay1 == "tpLotacao"

			cAlias := "C8F"
			cCmpTab1 := "C8F_CODIGO"
			nOrder := 2

		//Cadastro de Varas   ( Tabela C9A )
		ElseIf cFieldLay1 == "idVara" .and. cFieldLay2 == "codMunic"

			cAlias := "C9A"
			cCmpTab1 := "C9A_CODIGO"
			cCmpTab2 := "C9A_CODMUN"
			cFonte   := "TAFA251"
			nOrder := 4

			cInfo2 := Posicione("C07",5,xFilial("C07") + Substr( cInfo2, 3, 5 ),"C07_ID")

		//Cadastro de Varas   ( Tabela C9A )
		ElseIf cFieldLay1 == "idVara" .and. cFieldLay2 == "ufVara"

			cAlias := "C9A"
			cCmpTab1 := "C9A_CODIGO"
			cCmpTab2 := "C9A_UF"
			cFonte   := "TAFA251"
			nOrder := 2

			If Len(cInfo2) < 6
				cInfo2 := Posicione("C09",1,xFilial("C09") + cInfo2,"C09_ID")
			EndIf

		//Indicativo de Decisão( Tabela C8S )
		ElseIf cFieldLay1 == "indSusp"

			cAlias := "C8S"
			cCmpTab1 := "C8S_CODIGO"

		//Tipo de valor que influi na apuração da contribuição devida( Tabela C8U )
		ElseIf cFieldLay1 == "tpValor"

			cAlias := "C8U"
			cCmpTab1 := "C8U_CODIGO"
			nOrder := 2

		//Tipo de valor que influi na apuração da contribuição devida( Tabela T2T )
		ElseIf cFieldLay2 == "tpValor"

			cAlias 		:= "T2T"
			cCmpTab1 	:= "T2T_CODIGO"
			nOrder 		:= 1

		//Tipo de valor que influi na apuração da contribuição devida( Tabela V5L )
		ElseIf cFieldLay2 == "tpValorV5L"

			cAlias 		:= "V5L"
			cCmpTab1 	:= "V5L_CODIGO"
			nOrder 		:= 1

		//Natureza da Rubrica ( Tabela C89 )
		ElseIf cFieldLay1 == "natRubr"

			cAlias := "C89"
			cCmpTab1 := "C89_CODIGO"

		//Incidenc. Trib. Prev. Soc. ( Tabela C8T )
		ElseIf cFieldLay1 == "codIncCP"

			cAlias := "C8T"
			cCmpTab1 := "C8T_CODIGO"

		//Incidenc. Trib. IRRF. ( Tabela C8U )
		ElseIf cFieldLay1 == "codIncIRRF"

			cAlias := "C8U"
			cCmpTab1 := "C8U_CODIGO"

		//Parte Atingida ( Tabela C8I )
		ElseIf cFieldLay1 == "codParteAting"

			cAlias := "C8I"
			cCmpTab1 := "C8I_CODIGO"

		//Agente causador ( Tabela C8J )
		ElseIf cFieldLay1 == "codAgntCausador"

			cAlias := "C8J"
			cCmpTab1 := "C8J_CODIGO"

		//Profissional Saude( Tabela CM7 )
		ElseIf cFieldLay1 == "nrOC"	.OR. cFieldLay1 == "nrCRM"

			cAlias := "CM7"
			cCmpTab1 := "CM7_CODIGO"
			nOrder   := 2 //4
			cFonte   := "TAFA262"

		//Situacao Geradora ( Tabela C8J )
		ElseIf cFieldLay1 == "codSitGeradora"

			cAlias := "C8L"
			cCmpTab1 := "C8L_CODIGO"

		//Motivo Acidente
		ElseIf cFieldLay1 == "codMotAfastamento" .OR. cFieldLay1 == "codMotAfast"

			cAlias := "C8N"
			cCmpTab1 := "C8N_CODIGO"

		//Nome do medico( Tabela CM7 )
		ElseIf cFieldLay1 == "nomeMedico"

			cAlias := "CM7"
			cCmpTab1 := "CM7_NOME"
			nOrder   := 3

		//Grau de Instrucao ( Tabela CMH )
		ElseIf cFieldLay1 == "grauInstrucao" .or. cFieldLay1 == "grauInstr"

			cAlias   := "CMH"
			cCmpTab1 := "CMH_CODIGO"

		//Tipo de Arq. da ESocial ( Tabela C8E )
		ElseIf cFieldLay1 == "tpEvento"

			cAlias   := "C8E"
			cCmpTab1 := "C8E_CODIGO"
			nOrder   := 2

		//Motivo Acidente C8N
		ElseIf cFieldLay1 == "codCID"

			cAlias := "CMM"
			cCmpTab1 := "CMM_CODIGO"
			nOrder   := 2

			cInfo1 := Alltrim(cInfo1)

			If Len(cInfo1) == 4
				cInfo1 := Substr(cInfo1,1,3)+ "." + Substr(cInfo1,4,4)
			EndIf

		//Tabela de Estabelecimentos ( Tabela C92 )
		ElseIf cFieldLay1 == "tpEstabelecimento"

			cAlias   := "C92"
			cCmpTab1 := "C92_TPINSC"
			cCmpTab2 := "C92_NRINSC"
			cFonte   := "TAFA253"

			nOrder := 6

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		//Tipo servico E-Social ( Tabela C8C )
		ElseIf cFieldLay1 == "tpServico"

			cAlias   := "C8C"
			cCmpTab1 := "C8C_CODIGO"
			cFonte   := "TAFA217"

		//Aviso Previo( Tabela CM8 )
		ElseIf cFieldLay1 == "dtCancAvisoPrevio"

			cAlias   := "CM8"
			cCmpTab1 := "CM8_TRABAL"
			nOrder   := 3
			cAtivo   := "1"

		//Responsavel Informacao ( Tabela C9F )
		ElseIf cFieldLay1 == "cpfResponsavel"

			cAlias   := "C9F"
			cCmpTab1 := "C9F_CPF"
			nOrder   := 2
			cFonte   := "TAFA254"

		//Natureza Jurídica Contribuinte ( Tabela C8P )
		ElseIf cFieldLay1 == "natJuridica"

			cAlias 	 := "C8P"
			cCmpTab1 := "C8P_CODIGO"
			nOrder   := 2

		//Tipo Condição Dif. Trabalho ( Tabela CUN )
		ElseIf cFieldLay1 == "tpCondicao"

			cAlias 	 := "CUN"
			cCmpTab1 := "CUN_CODIGO"
			nOrder   := 2

		//Tipo Isenção ( Tabela CMY )
		ElseIf cFieldLay1 == "tpIsencao"

			cAlias 	 := "CMY"
			cCmpTab1 := "CMY_CODIGO"
			nOrder := 2

		//Tipo Rendimento ( Tabela CUC )
		ElseIf cFieldLay1 == "tpRendimento"

			cAlias 	 := "CUC"
			cCmpTab1 := "CUC_CODIGO"
			nOrder := 2

		//Tipo Tributação ( Tabela CUD )
		ElseIf cFieldLay1 == "formaTributacao"

			cAlias 	 := "CUD"
			cCmpTab1 := "CUD_CODIGO"
			nOrder := 2

		//Codigo Pais ( Tabela C08 )
		ElseIf cFieldLay1 == "paisResidencia|pais"

			cAlias 	 := "C08"
			cCmpTab1 := "C08_CODIGO"

		//Cod. Redimento ( Tabela CUF )
		ElseIf cFieldLay1 == "codRendimento"

			cAlias 	 := "CUF"
			cCmpTab1 := "CUF_CODIGO"
			nOrder := 2

		//Relação fonte pagadora ( Tabela CUB )
		ElseIf cFieldLay1 == "relFontePagadora"

			cAlias 	 := "CUB"
			cCmpTab1 := "CUB_CODIGO"
			nOrder   := 2

		//Tipo de Dependente ( Tabela CMI )
		ElseIf cFieldLay1 == "relDependencia"

			cAlias   := "CMI"
			cCmpTab1 := "CMI_CODIGO"
			nOrder   := 2

		//Processo E-Social ( Tabela CMW )
		ElseIf (cFieldLay1 == "tpInscAdvogado" .And. cFieldLay2 == "nrInscAdvogado")

			cAlias   := "CMW"
			cCmpTab1 := "CMW_TPINSC"
			cCmpTab2 := "CMW_NRINSC"
			cFonte   := "TAFA285"
			nOrder   := 4

		//Matrícula ( Tabela C9V )
		ElseIf (cFieldLay1 == "matricula")

			cAlias   := "C9V"
			cCmpTab1 := "C9V_MATRIC"
			nOrder   := 11

		//Municipios ( Tabela C07 )
		ElseIf cFieldLay1 == "codMun"

			cAlias   := "C07"
			cCmpTab1 := "C07_CODIGO"
			nOrder   := 5

		//Código Terceiros ( Tabela C8A )
		ElseIf cFieldLay1 == "codTerc"

			cAlias   := "C8A"
			cCmpTab1 := "C8A_CODTER"
			nOrder   := 4

		//Processo E-Social ( Tabela T13 )
		ElseIf cFieldLay1 == "classTrabEstrang"

			cAlias   := "T13"
			cCmpTab1 := "T13_CODIGO"
			nOrder   := 2


		// Identificador de Rubrica
		ElseIf cFieldLay1 == "ideTabRubr"

			cAlias	 := "T3M"
			cCmpTab1 := "T3M_CODERP"
			nOrder	 := 2
			cFonte	 := "TAFA406"

		//Processo E-Social ( Tabela C1G )
		ElseIf (cFieldLay1 == "nrProcJ")

			cAlias   := "C1G"
			cCmpTab1 := "C1G_NUMPRO"
			nOrder   := 6
			cFonte   := "TAFA051"

		//Demonstrativos Pagamentos Rescisão ( Tabela T06 )
		ElseIf cFieldLay1 == "ideRecPgto"

			cAlias   := "T06"
			cCmpTab1 := "T06_RECPAG"

		//Demonstrativos Pagamentos Rescisão ( Tabela T06 )
		ElseIf cFieldLay1 == "vlrPgto"

			cAlias   := "T06"
			cCmpTab1 := "T06_VLRPAG"

		//Ident.Estabelecimento/Lotação ( Tabela T3G )
		ElseIf cFieldLay1 == "indSimples"

			cAlias   := "T3G"
			cCmpTab1 := "T3G_INDCSU"

		//Processos Relacionados (Tabela T3H)
		ElseIf cFieldLay1 == "indSimples"

			cAlias   := "T3H"
			cCmpTab1 := "T3H_INDCSU"

		//Retificação Aviso Prévio (S-2250)
		ElseIf cFieldLay1 == "cpfTrab/Recibo" .and. cFieldLay2 == "matricula/Recibo" .and. cFieldLay3 == "nrRecibo"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_PROTUL"
			nOrder   := 8
			cAtivo	 := "1"

		//Trabalhador ( Tabela C9V )
		ElseIf cFieldLay1 == "cpfTrab/Recibo"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_CPF"
			cCmpTab2 := "C9V_MATRIC"

			nOrder   := 12
			cAtivo	  := "1"

		//Cadastro de Profissional de Saúde (Tabela CM7)
		ElseIf cFieldLay1 == "nrIOC"

			cAlias   := "CM7"
			cCmpTab1 := "CM7_NRIOC"
			cFonte   := "TAFA262"
			nOrder	 := 4

		//Descrição da Natureza Lesão(Tabela C8M)
		ElseIf cFieldLay1 == "dscLesao"

			cAlias   := "C8M"
			cCmpTab1 := "C8M_CODIGO"
			nOrder	 := 2

		//Cadastro de Ambiente de Trabalho(Tabela T04)
		ElseIf cFieldLay1 == "codAmb"

			cAlias   := "T04"
			cCmpTab1 := "T04_CODIGO"
			nOrder	 := 2

		//Cadastro de Operadores Portuários(C8W)
		ElseIf cFieldLay1 == "cnpjOpPortuario"

			cAlias   := "C8W"
			cCmpTab1 := "C8W_CNPJOP"
			nOrder	 := 4

		//Cadastro de Contabilistas(C2J)
		ElseIf cFieldLay1 == "cpfResp"

			cAlias   := "C2J"
			cCmpTab1 := "C2J_CPF"
			nOrder	 := 3
			cFonte	 := 'TAFA052'

		ElseIf cFieldLay1 == "nrInscAdq"

			cAlias   := "C92"
			cCmpTab1 := "C92_TPINSC"
			cCmpTab2 := "C92_NRINSC"
			cInfo1	  := "3"

			nOrder := 6

			//Caso seja uma tabela do Layout do E-Social, ou seja, passivel de
			//transmissao ao RET devo buscar apenas os registros validos
			cAtivo   := "1"

		ElseIf cFieldLay1 == "codFatRis" .OR. cFieldLay2 == "codFatRis"

			cAlias   := "T3E"
			cCmpTab1 := "T3E_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "tpAcid"

			cAlias   := "LE5"
			cCmpTab1 := "LE5_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "indMatProc"

			cAlias   := "LE7"
			cCmpTab1 := "LE7_CODIGO"
			nOrder	  := 1

		ElseIf cFieldLay1 == "tpBenef" .And. cFieldLay2 == "nrBenefic"

			cAlias   := "T5T"
			cCmpTab2 := "T5T_NUMBEN"
			nOrder	  := 5
			cAtivo	  := "1"

		ElseIf cFieldLay1 == "tpBenef"

			cAlias   := "T5G"
			cCmpTab1 := "T5G_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "mtvFim"

			cAlias   := "T5H"
			cCmpTab1 := "T5H_CODIGO"
			nOrder	  := 2

		//Info. iden. registrador da CAT(T0I)
		ElseIf cFieldLay1 == "tpRegistrador"

			cAlias   := "T0I"
			cCmpTab1 := "T0I_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "codSusp"

			cAlias   := "T5L"
			nOrder	  := 1

		ElseIf cFieldLay1 == "tpBcIRRF"

			cAlias   := "C8U"
			cCmpTab1 := "C8U_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "cpfBenef" .And. cEvento $ "S-1207|S-1210|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420"

			cAlias   := "V73"
			cCmpTab1 := "V73_CPFBEN"
			nOrder   := 3
			cAtivo   := "1"
		
		ElseIf cFieldLay1 == "cpfBenef"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_CPF"
			nOrder   := 3
			cAtivo   := "1"

		ElseIf cFieldLay1 == "codConv"

			cAlias := "T87"
			cCmpTab1 := "T87_TRABAL"
			cCmpTab2 := "T87_CONVOC"
			cAtivo := "1"
			nOrder := 2
			cValorTag := cInfo2

		ElseIf cFieldLay1 == "tpValorE"

			cAlias := "V26"
			cCmpTab1 := "V26_CODIGO"
			nOrder := 2

		ElseIf cFieldLay1 == "tpDpsE"

			cAlias := "V27"
			cCmpTab1 := "V27_CODIGO"
			nOrder := 2

		ElseIf cFieldLay1 == "cpfTrab"  .And. cFieldLay2 == "matricula" .And. cFieldLay3 == "codCateg"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_CPF"
			cCmpTab2 := "C9V_MATRIC"
			nOrder   := 12
			cAtivo 	 := "1"

		ElseIf cFieldLay1 == "cpfTrab"  .And. cFieldLay2 == "matricula" .And. cFieldLay3 != "codCateg"

			cAlias   := "C9V"
			cCmpTab1 := "C9V_CPF"
			cAtivo   := "1"
			cFonte   := 'TAFA473'

			// Tratamento para a simplificação do e-Social
			If lLaySimplif .AND. cEvento $ "S-2399"
				cCmpTab2 := "C9V_MATTSV"
				nOrder   := 20
			Else
				cCmpTab2 := "C9V_MATRIC"
				nOrder   := 10
			EndIf

		ElseIf cFieldLay1 == "cpfTrab" .And.  cFieldLay3 == "codCateg"

			cAlias     := "C9V"
			cCmpTab1   := "C9V_CPF"
			cCmpTab2   := "C9V_CATCI"
			nOrder     := 18
			cAtivo     := "1"
			cFonte     := "TAFA473"
			cMsgType   := 'chvComposta'
			cValorTag2 := cCodCatInt

		ElseIf cFieldLay1 == "codAtiv"

			cAlias   := "V2L"
			cCmpTab1 := "V2L_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "unMed"

			cAlias   := "V3F"
			cCmpTab1 := "V3F_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "codTreiCap"

			cAlias   := "V2M"
			cCmpTab1 := "V2M_CODIGO"
			nOrder   := 2

		ElseIf cFieldLay1 == "nrInscEstabRural"

			cAlias   := "C92"
			cCmpTab1 := "C92_NRINSC"
			nOrder   := 8

		ElseIf cFieldLay1 == "procRealizado"

			cAlias   := "V2K"
			cCmpTab1 := "V2K_CODIGO"
			nOrder	  := 2

		ElseIf cFieldLay1 == "codAgNoc" 

			cAlias   := "V5Y"
			cCmpTab1 := "V5Y_CODIGO"
			nOrder	  := 2
			
		ElseIf cFieldLay1 == "tpBeneficio" 

			cAlias   := "V5Z"
			cCmpTab1 := "V5Z_CODIGO"
			nOrder   := 2

		ElseIf cFieldLay1 == "mtvTermino"

			cAlias   := "T5H"
			cCmpTab1 := "T5H_CODIGO"
			nOrder   := 2

		ElseIf cFieldLay1 == "frmTribut"

			cAlias   := "V9H"
			cCmpTab1 := "V9H_CODIGO"
			nOrder   := 2		

		EndIf

		//Verifica a existência da tabela e indice
		If TafIndexInDic(cAlias, nOrder, .T.)

			DbSelectArea( cAlias )
			(cAlias)->( DbSetOrder( nOrder ) )

			If cAlias == "C8R" .And. lTAFCodRub

				dbSelectArea("C8R")
				If Empty(cCmpTab2)
					cCmpTab2 := "C8R_IDTBRU"
				EndIf
				C8R->(dbGoTo(TAFCodRub(Padr( cInfo1, TamSx3(cCmpTab1)[1]), /*DTINI*/cPeriodo, /*DTFIN*/"", /*ATIVO*/"1",/*TABELA*/Padr( cInfo2, TamSx3(cCmpTab2)[1]))))
				cId := C8R->C8R_ID

			ElseIf (cFieldLay1 == "cpfTrab" .And. cFieldLay2 == "matricula" .And. cFieldLay3 == "codCateg")

				If (cAlias)->(MsSeek(xFilial(cAlias)+Padr(cInfo1,TamSx3(cCmpTab1)[1])+Padr(cInfo2,TamSx3(cCmpTab2)[1]) + cAtivo ))

					While Padr(cInfo1,TamSx3(cCmpTab1)[1]) == (cAlias)->&(cAlias+"_CPF") .And. Padr(cInfo2,TamSx3(cCmpTab2)[1]) == (cAlias)->&(cAlias+"_MATRIC")  .And. cAtivo == "1"

						If AllTrim(cInfo3) == AllTrim((cAlias)->&(cAlias+"_CATCI"))

							cId := (cAlias)->&(cAlias+"_ID")
							Exit

						EndIf

						(cAlias)->(dbSkip())

					EndDo
				EndIf

				//Para o Funcionario,
				//devemos procurar nos 2 eventos
				//S2200
				//S2300

			ElseIf ((cFieldLay1 == "cpfTrab" .And. cFieldLay2 == "matricula");
					.Or. (cFieldLay1 == "cpfTrab" .And. Empty(AllTrim(cFieldLay2)));
					.Or. (Empty(Alltrim(cFieldLay1)) .And. cFieldLay2 == "matricula"))

				If Empty(aInfComp) 

					If cFieldLay2 != "matricula" .And. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + "S2200" + cAtivo ) ) .OR.;
							(cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + "S2300" + cAtivo ) )

						cId := (cAlias)->&( cAlias + "_ID" )	

					EndIf

				EndIf				

				If Empty(cId)
				
					If cFieldLay3 == "codCateg" .And. Empty(aInfComp)

						If !Empty(cInfo3) .And. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+ Padr( cInfo3, TamSx3(cCmpTab2)[1] ) + cAtivo  ) )
							cId := (cAlias)->&( cAlias + "_ID" )
						ElseIf (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + "TAUTO" + cAtivo ) )
							cId := (cAlias)->&( cAlias + "_ID" )
						EndIf

					ElseIf cFieldLay3 != "codCateg" .And. !Empty(cCmpTab2) .And. Empty(aInfComp)

						If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + "S2200" + cAtivo ) ) .OR.;
								( lLaySimplif .AND. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + "S2300" + cAtivo ) ) ) .OR.;
							( lLaySimplif .AND. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo ) ) )

							cId := (cAlias)->&( cAlias + "_ID" )

						ElseIf (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + "TAUTO" + cAtivo ) )

							cId := (cAlias)->&( cAlias + "_ID" )

						EndIf

					Else

						lFindFunc := ((cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+ "S2200" + cAtivo ) );
							.Or. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] )+ "S2300" + cAtivo ) ))

						cIdAux := (cAlias)->&( cAlias + "_ID" )

						If lFindFunc

							If cAlias == "C9V"
								cNomEv 	:= (cAlias)->&( cAlias + "_NOMEVE" )
								cCodCat := POSICIONE("C87",1, xFilial("C87")+(cAlias)->&( cAlias + "_CATCI" ),"C87_CODIGO")
							EndIf

						EndIf

					EndIf

					If Empty(aInfComp) .And. lFindFunc

						cId := (cAlias)->&( cAlias + "_ID" )

					ElseIf !Empty(aInfComp) .And. (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + "TAUTO" + cAtivo ) )

						cId := (cAlias)->&( cAlias + "_ID" )
						// Atualiza a C9V com os dados do autonomo
						aGrvInfo := {{ "C9V_CPF", cInfo1 }}
						FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp,, 4)

						//Esse caso é especifico para aglutinação de folhas em que 1 dos vinculos do trabalhador contem o InfoComplem (autonomo RPA)
						//Nesses casos não posso criar um TAUTO na C9V e devo utilizar o Id do celetista para a aglutinação.

					ElseIf lFindFunc .And. !Empty(aInfComp)

						//validar categoria se for igual id é do idaux, caso contrário cria TAUTO
						If cNomEv == "S2300"

							T92->(DbSetOrder(3))

							If T92->(MsSeek(xFilial("T92") + cIdAux + "1")) .And. T92->T92_STATUS $ "4|6"

								cId := ""

							Else

								cXMLCodCat := fTafGetVal("/eSocial/evtRemun/dmDev/codCateg", "C", .F., @aIncons, .F.)
								
								If cCodCat == cXMLCodCat
									cId := cIdAux
								Else
									cId := ""
								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			//Utilizado para retificacao aviso previo S-2250
			ElseIf (cFieldLay1 == "cpfTrab/Recibo" .And. cFieldLay2 == "matricula/Recibo" .And. cFieldLay3 == "nrRecibo" )

				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + cAtivo ) )
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			//Para eventos que utilizam o campo recibo como chave.
			ElseIf (cFieldLay1 == "cpfTrab/Recibo" .And. cFieldLay2 == "matricula/Recibo")

				nTamCPF := GetSx3Cache("C9V_CPF","X3_TAMANHO")
				nTamChave := GetSx3Cache("C9V_MATRIC","X3_TAMANHO") + nTamCPF
				cChvCPFMAT := Substr(cInfo2,nPosChave,nTamChave) // Chave CPF + Matricula
				nPosChave += nTamChave

				If len(cInfo2) >= nTamChave

					//Neste ponto eh necessario extrair o CPF e a Matricula da chave, a rotina considera
					//que o cpf+matricula serao sempre os primeiros campos da chave.
					If (cAlias)->( MsSeek( xFilial( cAlias ) + cChvCPFMAT + cAtivo ) )
						cId := (cAlias)->&( cAlias + "_ID" )
					EndIf

				ElseIf (len(AllTrim(cInfo1)) == nTamCPF .And. len(AllTrim(cChvCPFMAT)) == nTamCPF) .Or. (empty(cInfo2) .And. !empty(cInfo1))
					
					(cAlias)->(dbSetOrder(3))

					If (cAlias)->( MsSeek( xFilial( cAlias ) + cInfo1 + cAtivo ) )
						cId := (cAlias)->&( cAlias + "_ID" )
					EndIf

					(cAlias)->( DbSetOrder( nOrder ) )

				EndIf

			ElseIf cFieldLay1 == "codSusp"

				dbSelectArea("C1G")
				C1G->(dbSetOrder(8))

				If C1G->(MSSeek(xFilial("C1G")+cInfo2+"1"))

					cNumPro := C1G->C1G_NUMPRO

					//Ordena peo num. do processo
					C1G->(dbSetOrder(1))
					C1G->(MSSeek(xFilial("C1G")+cNumPro))

					//Itera a tabela para pesquisar o código da suspensão
					While C1G->(!Eof()) .AND. AllTrim(cNumPro) == AllTrim(C1G->C1G_NUMPRO)

						//Valida se o registro está ativo e se faz parte do contexto do e-social
						If C1G->C1G_ATIVO == '1' .AND. C1G->C1G_ESOCIA == '1'

							dDtIni := STOD(Substr(C1G->C1G_DTINI,3,4)+ Substr(C1G->C1G_DTINI,1,2)+"01")

							If !Empty(cInfo3)
								dDtVld := STOD(Substr(cInfo3,3,4)+ Substr(cInfo3,1,2)+"01")
							Else
								dDtVld := STOD(Substr(StrTran(cPeriodo,'-'),1,4)+ Substr(StrTran(cPeriodo,'-'),5,2)+"01")
							EndIf

							//Verifica se a data da rubrica esta dentro do período do processo
							If (dDtVld >= dDtIni)
								cVersao := C1G->C1G_VERSAO
								cIdProc := C1G->C1G_ID
							EndIf

						EndIf

						C1G->(dbSkip())

					EndDo

					If !Empty(cVersao)

						If (cAlias)->( MsSeek( xFilial(cAlias) + cIdProc + cVersao + cInfo1  ) )
							cId := cIdProc + cVersao + T5L->T5L_CODSUS
						EndIf

					EndIf

				EndIf

				cVersao := Posicione("C1G",8,xFilial("C1G")+cInfo2+"1","C1G_VERSAO")

				//Garanto que o código de suspensão existe
				If (cAlias)->( MsSeek( xFilial(cAlias) + cInfo2 + cVersao + cInfo1  ) )
					cId := cInfo2 + cVersao + T5L->T5L_CODSUS
				EndIf

			ElseIf cFieldLay1 == "tpBenef" .And. cFieldLay2 == "nrBenefic"

				cIdTpBen := Posicione("T5G",2,xFilial("T5G") + cInfo1, "T5G_ID")

				If (cAlias)->( MsSeek( xFilial( cAlias ) + cIdTpBen + Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo ) )
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			//Verifico se o Seek eh chave composta
			ElseIf !Empty( cCmpTab1 ) .And. !Empty( cCmpTab2 )

				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo ) )
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

				//-- Tratamento para pegar sempre a última data da C92
				If cAlias == "C92" .AND. cFieldLay1 == "tpInsc"

					If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo ) )

						dDtIni := StoD(Substr(C92->C92_DTINI,3,4) + Substr(C92->C92_DTINI,1,2) + "01" )
						cId     := (cAlias)->&( cAlias + "_ID" )
						nRecC92 := (cAlias)->(Recno())

						While (cAlias)->(!Eof()) .AND. AllTrim( XFilial( "C92") + C92->C92_TPINSC + C92->C92_NRINSC + C92->C92_ATIVO) == AllTrim((cAlias)->&( cAlias + "_FILIAL" ) + Padr( cInfo1, TamSx3(cCmpTab1)[1] ) + Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo) //--C92_FILIAL+C92_TPINSC+C92_NRINSC+C92_ATIVO

							dDtC92 := StoD(Substr(C92->C92_DTINI,3,4) + Substr(C92->C92_DTINI,1,2) + "01" )

							If dDtIni < dDtC92
								cId := (cAlias)->&( cAlias + "_ID" )
								nRecC92 := (cAlias)->(Recno())
							EndIf

							(cAlias)->(dbSkip())

						EndDo

						If (cAlias)->(Eof())
							(cAlias)->(DbGoTo(nRecC92))
						EndIf

					EndIf

				EndIf

				//Tratamento para nrProcJud
				If Empty(cId) .and. cFieldLay2 $ 'nrProcJud|nrProc'

					If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( '1', TamSx3(cCmpTab1)[1] ) + Padr( cInfo2, TamSx3(cCmpTab2)[1] ) + cAtivo ) )
						cId := (cAlias)->&( cAlias + "_ID" )
					EndIf

				EndIf

			ElseIf cAlias == "T2T"

				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo2, TamSx3(cCmpTab1)[1])))
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			ElseIf cAlias == "V5L"

				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo2, TamSx3(cCmpTab1)[1])))
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			ElseIf cAlias == "C92" .And. cFieldLay1 == "nrInscEstabRural"
				
				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1]) + "1"))
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			ElseIf cAlias == "V73" 

				If (cAlias)->( MsSeek(xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1]) + cEventBen + cAtivo )) 
					cId := (cAlias)->&( cAlias + "_ID" )
				EndIf

			Else

				If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1]) + cAtivo ) )

					cId := (cAlias)->&( cAlias + "_ID" )

				EndIf

				//-- Tratamento para pegar sempre a última data da C92
				If cAlias == "C99" .AND. cFieldLay1 == "codLotacao"

					If (cAlias)->( MsSeek( xFilial( cAlias ) + Padr( cInfo1, TamSx3(cCmpTab1)[1]) + cAtivo ) )

						dDtIni  := StoD(Substr(C99->C99_DTINI,3,4) + Substr(C99->C99_DTINI,1,2) + "01" )
						cId     := (cAlias)->&( cAlias + "_ID" )
						nRecC99 := (cAlias)->(Recno())

						While (cAlias)->(!Eof()) .AND. AllTrim( XFilial( "C99") +Padr( C99->C99_CODIGO, TamSx3(cCmpTab1)[1]) + C99->C99_ATIVO) == AllTrim((cAlias)->&( cAlias + "_FILIAL" ) + Padr( cInfo1, TamSx3(cCmpTab1)[1]) + cAtivo)

							dDtC99 := StoD(Substr(C99->C99_DTINI,3,4) + Substr(C99->C99_DTINI,1,2) + "01" )

							If dDtIni < dDtC99
								cId := (cAlias)->&( cAlias + "_ID" )
								nRecC99 := (cAlias)->(Recno())
							EndIf

							(cAlias)->(dbSkip())

						EndDo

						If (cAlias)->(Eof())
							(cAlias)->(DbGoTo(nRecC99))
						EndIf

					EndIf

				EndIf

			EndIf

			//Pega os nomes das Tags
			If cMsgType == 'chvComposta'

				cNmTag := cFieldLay1

				If !Empty(cFieldLay2)
					cNmTag2 := cFieldLay2
				ElseIf !Empty(cFieldLay3)
					cNmTag2 	:= cFieldLay3					
				EndIf

			ElseIf !Empty(cFieldLay1)

				cNmTag := cFieldLay1

			ElseIf !Empty(cFieldLay2)

				cNmTag := cFieldLay2

			EndIf

			If Empty( cId ) .And. cAlias == "C1G"

				If cFieldLay1 == "nrProcJ"
					aGrvInfo := { { "C1G_NUMPRO", cInfo1 }, { "C1G_TPPROC", "1"    }, { "C1G_ESOCIA", "1" } }
				Else
					aGrvInfo := { { "C1G_TPPROC", cInfo1 }, { "C1G_NUMPRO", cInfo2 }, { "C1G_ESOCIA", "1" } }
				EndIf

				cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp)

			EndIf

			//Caso nao tenha encontrado o ID com a chave informada deve-se realizar
			//a inclusao do registro na tabela de referencia para que seja gerado um ID
			//e assim atribuido a tabela principal, caso nao exista o tratamento para
			//o alias encontrado sera gravado no campo o codigo 'ERR' + o codigo enviado
			If cAlias == "CM7"

				If Empty( cId ) .And. (!Empty(cInfo1) .Or. !Empty(cInfo2))

					aGrvInfo := {{ "CM7_CODIGO", cInfo1 }, { "CM7_NRIOC", cInfo1 }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp)

				ElseIf !Empty( cId ) .And. (!Empty(cInfo1) .Or. !Empty(cInfo2))

					aGrvInfo := {{ "CM7_CODIGO", cInfo1 }, { "CM7_NRIOC", cInfo1 }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp,, 4)

				EndIf

			EndIf

			If Empty( cId )  .And. (!Empty(cInfo1) .Or. !Empty(cInfo2))

				If cAlias == "C9F"

					aGrvInfo := {{ "C9F_CPF", cInfo1 }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo,aInfComp )

				ElseIf cAlias == "C9A"

					aGrvInfo := {{ "C9A_CODIGO", cInfo1 }, { "C9A_CODMUN", cInfo2 } }
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo,aInfComp )

				ElseIf cAlias == "C8B"

					aGrvInfo := {{ "C8B_FUNC", cInfo1 }, { "C8B_DTASO", SToD( cInfo2 ) }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp )

				ElseIf cAlias == "T3M"

					aGrvInfo := {{ "T3M_CODERP", cInfo1 }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp )

				ElseIf cAlias == "C9V" .and. len( aInfComp ) > 0 //somente cadastrar trabalhador autonomo

					aGrvInfo := {{ "C9V_CPF", cInfo1 }}

					If cEvento $ "S-1202"
						cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp, .T. )						
					Else
						cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp )
					EndIf

				ElseIf cAlias == "C2J" .and. len( aInfComp ) > 0 //cadastro de contabilista: eh necessario pois nao existe evento de contabilista no eSocial

					aGrvInfo := {{ "C2J_CPF", cInfo1 }}
					cId := FGrvTabAux( cFonte, cAlias, aGrvInfo, aInfComp )

				ElseIf cAlias == "C9V" .And. cFieldLay4 == "perApu" .And. ( cInfo4 == "2018-05" .Or. cInfo4 == "2018-11"  )

					aGrvInfo	:= {{"C9V_CPF", cInfo1 },{"C9V_NOME", "AUTONOMO S/ S-1200 - " + Alltrim(cInfo1) }}
					cId 		:= FGrvTabAux( "TAFA473","C9V", aGrvInfo, aInfComp , .T. )

				Else

					If Empty( cValorTag )
						cValorTag := cInfo1
					EndIf

					//Gera mensagem de erro
					TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., cNmTag, cValorTag,cMsgType,,cNmTag2,cValorTag2 )

				EndIf

			Else

				//Tratamento para registros integrados pela Fila de Processamento.
				//Quando um registro é enviado ao TAF com o flag de Fila - campo TAFSTQUEUE = 'F' - além de verificar se a chave estrangeira existe na base de dados
				//é necessário verificar o status do registro da FK, pois dependendo do status (se for <>'4') o registro será rejeitado ou retornado para a fila
				//até que o status esteja = '4'.
				If Type( "cStatQueue" ) <> "U" .and. cStatQueue == 'F'

					//Variável de controle para processar registro c/ Trabalhador Autonomo.
					//Impedir o bloqueio do registro na importação com Fila de Processamento ativa.
					If TAFColumnPos(cAlias + "_NOMEVE")

						If (cAlias)->&( cAlias + "_NOMEVE" ) == 'TAUTO'
							lTauto := .T.
						EndIf

					EndIf

					//registro de processamento em fila - cStatQueue é variável Private na TAFProc2()
					//a variável cAtivo == '1' identifica um registro do TAF que gera um evento para o eSocial. Esta regra não se aplica a registro de autocontidas.
					If cAtivo == '1' .and. (cAlias)->&( cAlias + "_STATUS" ) <> '4' .and. !lTauto
						TAFMsgIncons( @cInconMsg , @nSeqErrGrv , , , .T. , cNmTag , cValorTag , 'queue' , (cAlias)->&( cAlias + "_STATUS" ) )
						cId := ''
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	//Zerando os arrays e os objetos utilizados no processamento
	aSize( aGrvInfo, 0 )
	aGrvInfo := Nil

	aSize( aInfComp, 0 )
	aInfComp := Nil

Return( cId )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGrvTabAux

Funcao generica responsavl por gravar as informacoes das tabelas auxiliares
que pertencem ao XML que esta sendo importado

@param
cFonte   - Nome do fonte a que se refere a rotina para Load do Model
cAlias   - Alias da tabela que sera populada
aGrava   - Array com o nome do campo e a informacao que devera ser gravada
aInfComp - Informacoes a serem gravadas que nao fazem parte da chave do registro

@return
cId  -  Id Gerado para gravacao da informacao

@author Rodrigo Aguilar

@since 25/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGrvTabAux( cFonte, cAlias, aGrava, aInfComp, lVers, nOpc)

	Local cId    	:= ""
	Local oModel 	:= Nil
	Local nlI 		:= 0

	Default lVers	:= .F.
	Default nOpc	:= 3

	FCModelInt( cAlias, cFonte, @oModel, nOpc, cId )

	oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_FILIAL", xFilial( cAlias ) )
	If !(cAlias $ 'C9F|C9A|CM7|C9V|T3M|C2J')
		oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERSAO", xFunGetVer())
	EndIf

	If lVers .And. cAlias == "C9V"
		oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERSAO", xFunGetVer())
	EndIf

	For nlI := 1 To Len( aGrava )
		oModel:LoadValue( "MODEL_" + cAlias, aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
	Next

	If Len( aInfComp ) > 0

		If ( cAlias $ "C9F|C9A|CM7|T3M|C9V|C2J" )

			For nlI := 1 to Len( aInfComp )

				If cAlias == "C9V" .and. SubStr( aInfComp[nlI,1], 1, 3 ) == "CUP"
					oModel:LoadValue( "MODEL_" + SubStr( aInfComp[nlI,1], 1, 3 ), aInfComp[nlI,1], aInfComp[nlI,2] )
				Else
					oModel:LoadValue( "MODEL_" + cAlias, aInfComp[nlI,1], aInfComp[nlI,2] )
				EndIf

			Next nlI

		ElseIf cAlias == "C8B"

			For nlI := 1 to Len( aInfComp )
				oModel:LoadValue( "MODEL_" + SubStr( aInfComp[nlI,1], 1, 3 ), aInfComp[nlI,1], aInfComp[nlI,2] )
			Next nlI

		EndIf

	EndIf

	//Guardo o ID que foi gerado
	cId := oModel:GetValue( "MODEL_" + cAlias, cAlias + "_ID" )

	//Efetiva a operacao desejada
	FWFormCommit( oModel )

	//Atualiza Status de Trabalhador Sem S-2200 e S-2300
	If (cAlias == "C9V" .And. AllTrim(C9V->C9V_NOMEVE) == "TAUTO")

		RecLock("C9V", .F.)
		C9V->C9V_STATUS := "4"
		MsUnLock("C9V")

	EndIf

	If cAlias == "C1G"

		RecLock("C1G", .F.)
		C1G->C1G_STATUS := "4"
		C1G->C1G_LOGOPE := "A"
		C1G->(MsUnLock())

	EndIf

	//Zerando os arrays e os Objetos utilizados no processamento
	oModel:DeActivate()
	oModel     := Nil

Return ( cId )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAltRegAnt

Funcao que seta o registro alterado (anterior ) como Inativo, o registro
a ser alterado jah deve estar posicionado

@param
cAlias - Alias da tabela a ser alterada
cOper  - Seta o registro como Ativo/Inativo
lGravaDt - Informa se deve fechar a data do registro anterior (somente eventos de tabelas)
cDtOldFim - Data Fim do registro Anterior (somente eventos de tabelas)
cDtNewReg - Valor do campo Data Inicial do registro Novo depois do input no campo (somente eventos de tabelas)
cDtOldReg - Valor do campo Data Inicial do registro Novo antes do input no campo (somente eventos de tabelas)

@return
( Nil )

@author Rodrigo Aguilar

@since 25/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FAltRegAnt( cAlias as Character, cOper as Character, lGravaDt as Logical, cDtOldFim as Character, cDtNewReg as Character, cDtOldReg as Character, cFil as character )

	Local aAreaCM6  as Array
	Local aCR9 		as Array
	Local cAno      as Character
	Local cDtIni    as Character
	Local cDtIniAnt as Character
	Local cMes      as Character
	Local lRet      as Logical
	Local nX		as Numeric

	Default cDtNewReg := ""
	Default cDtOldFim := ""
	Default cDtOldReg := ""
	Default cOper     := "2"
	Default cFil      := ""
	Default lGravaDt  := .F.

	aAreaCM6  := {}
	aCR9 	  := {}
	cAno      := ""
	cDtIni    := ""
	cDtIniAnt := ""
	cMes      := ""
	lRet      := .F.
	nX		  := 0

	//Controle se o evento é extemporâneo
	lGoExtemp	:= IIf( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	If !lGoExtemp .Or. cAlias $ 'T1V|T1U|T0F|V73|V76|V77|V78'

		If RecLock( cAlias, .F. )

			(cAlias)->&( cAlias + "_ATIVO"  ) := cOper

			If cAlias == "C9V" .And. !Empty((cAlias)->&( cAlias + "_IDTRAN"))

				If cOper == "2"
					(cAlias)->&( cAlias + "_IDTRAN") := "|" + Alltrim((cAlias)->&( cAlias + "_IDTRAN"))
				ElseIf At("|",  Alltrim((cAlias)->&( cAlias + "_IDTRAN")), 1) > 0
					(cAlias)->&( cAlias + "_IDTRAN") := SubStr( Alltrim((cAlias)->&( cAlias + "_IDTRAN")), 2 )
				EndIf
				
			EndIf

			If lGravaDt

				If Empty(cDtOldFim)

					cDtIniAnt := Substr(cDtOldReg,3,4) + Substr(cDtOldReg,1,2)

					If Len(cDtNewReg) > 5
						cDtIni := Substr(cDtNewReg,3,4) + Substr(cDtNewReg,1,2)
					EndIf

					If cDtIni == cDtIniAnt

						(cAlias)->&( cAlias + "_DTFIN" ) :=  cDtNewReg

					ElseIf cDtIni > cDtIniAnt

						cMes := Substr(cDtNewReg,1,2)
						cAno := Substr(cDtNewReg,3,4)
						cMes := StrZero((Val(cMes)-1),2)
						//Quando mês for 00 será igual a 12 e diminui um ano

						If(cMes == '00')
							cMes := '12'
							cAno := StrZero((Val(cAno)-1),4)
						EndIf

						(cAlias)->&( cAlias + "_DTFIN"  ) := cMes+cAno

					EndIf

				EndIf

			EndIf

			(cAlias)->( MsUnlock() )

		EndIf

		//Se evento de afastamento (S-2230)
		If cAlias == "CM6"

			//Posiciono o registro para pegar a área
			aAreaCM6 := CM6->( GetArea() )

			CM6->( DBSetOrder( 3 ) )
			If  CM6->( MsSeek( xFilial( 'CM6' ) + CM6->CM6_ID + "1" ) ) .OR. CM6->( MsSeek( xFilial( 'CM6' , cFil ) + CM6->CM6_ID + "1" ) )
				RecLock( cAlias, .F. )

				(cAlias)->&( cAlias + "_ATIVO"  ) := cOper

				(cAlias)->( MsUnlock() )
			EndIf

			RestArea( aAreaCM6 )
			
		EndIf

		If cAlias == "C1E"

			aAreaC1E := C1E->( GetArea() )
            aAreaCR9 := CR9->( GetArea() )

            aCR9 := {}

            CR9->(DbSetOrder(4))
            CR9->(DbGoTop())

            If CR9->( MsSeek( C1E->( C1E_FILIAL + C1E_ID + C1E_VERSAO + '1') ) )

                While CR9->(CR9_FILIAL + CR9_ID + CR9_VERSAO + '1') == C1E->( C1E_FILIAL + C1E_ID + C1E_VERSAO + '1') 

                    Aadd(aCR9, CR9->( Recno() ))
                    CR9->( DbSkip() )

                EndDo

            EndIf

            For nX := 1 To Len(aCR9)

                CR9->( DBGoTo( aCR9[nX] ) )
				CR9->(RecLock( "CR9", .F. ))
				CR9->CR9_ATIVO := cOper
				CR9->( MsUnlock() )

            Next

            RestArea( aAreaC1E )
            RestArea( aAreaCR9 )

		EndIf
		
	EndIf

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRegStat

Funcao que identifica o tipo de operacao a ser realizada pela rotina de
integracao.

@param
nOpc       - Opcao de operacao a ser realizada ( 3 = Incluir, 4 = Alterar, 5 = Excluir )
cAlias     - Alias da tabela a ser validada
aChave     - Chave para o Seek
nInd       - Indice do Seek
cId        - ID do registro anterior
cVerAnt    - Versao do registro anterior
aIncons    - Array com as inconsistencias encontradas
cProtocolo - Numero do protocolo anterior
lRegTrans  - Indica se o registro jah foi transmitido ou nao
cEvento    - Evento a ser realizado
nIndIDVer  - Indice para busca do registro anterior. Deve ser o indice da tabela contemplando ID + VERSAO
cChave     - Chave informada para buscar a informacao
oModel     - Model que esta sendo manutenido
aDatas     - Data Inicial e Final do registro ( Atual e Anterior )
lRuleEvCad - Indica se a operacao eh referente a registros cadastrais ( S-1010 / S-1080 )
aNewData   - Conteudo da tag novaValidade para operacoes da alteracao de eventos cadastrais
cMatTrab	- Matrícula do funcionário, quando não for evento de funcionário ignorar esse parâmetro.
nRecnoReg - Recno do evento (Usado em posicionamentos de registros predecessores)

@return
nOpcRet  -  Opcao a ser realizada, sendo que:
			4 = Alterar, registro nao transmitido
			5 = Excluir, registro nao transmitido
			6 = Alterar, registro ja transmitido
			7 = Excluir, registro ja transmitido
			9 = Contem Inconsistencias

@author Rodrigo Aguilar

@since 25/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFRegStat( nOpc as Numeric, cAlias as Character, aChave as Array, nInd as Numeric, cId as Character, cVerAnt as Character, aIncons as Array, cProtocolo as Character,;
					 lRegTrans as Logical, cEvento as Character, nIndIDVer as Numeric, cChave as Character, oModel as Object, aDatas as Array, lRuleEvCad as Logical,;
					 aNewData as Array, cMatTrab as Character, cNomModel as Character, nRecnoReg as Numeric, lTermAfas as Logical )

	Local aTafRot    as Array
	Local cCmpInd    as Character
	Local cInfo      as Character
	Local cTags      as Character
	Local lFindCod   as Logical
	Local lFindReg   as Logical
	local lGerNewReg as Logical
	Local nlY        as Numeric
	Local nRecnoCM8  as Numeric
	Local oModelDel  as Object

	Default cChave    := ""
	Default cMatTrab  := ""
	Default cNomModel := ""
	Default lTermAfas := .F.
	Default nRecnoReg := 0

	aTafRot    := {}
	cCmpInd    := cAlias + "_FILIAL"
	cInfo      := ""
	cTags      := ""
	lFindCod   := .F.
	lFindReg   := .T.
	lGerNewReg := .F.
	nlY        := 0
	nRecnoCM8  := 0
	oModelDel  := Nil

	//Monta a chave para buscar as informacoes
	For nlY := 1 To Len( aChave )

		cInfo  := FTafGetVal(  aChave[ nlY, 3 ], aChave[ nlY, 1 ], aChave[ nlY, 4 ], @aIncons, .F., ,aChave[ nlY, 2 ] )

		If !Empty(Alltrim( aChave[ nlY, 3 ] ))
			cTags  += Alltrim( aChave[ nlY, 3 ] ) +  ", "
		EndIf

		If aChave[ nlY, 1 ] == "C"

			cChave += Padr( cInfo, Tamsx3( aChave[ nlY, 2 ])[1] )
			If lRuleEvCad
				lFindCod := .T.
			EndIf

		ElseIf aChave[ nlY, 1 ] == "D"

			cChave += DToS( cInfo )

		EndIf

		cCmpInd += IIf( !Empty( cCmpInd ), "+" + aChave[nlY,2], aChave[nlY,2] )

	Next

	//Regra para Eventos de Cadastro
	//- Caso nao tenha enviado o codigo, nao deve realizar acoes
	If lRuleEvCad .and. !lFindCod
		cChave := ""
	EndIf

	If !Empty( cChave )

		// Obtem as datas inicial e final do registro
		If lRuleEvCad
			aDatas := TafChvData(cAlias, aChave)
		EndIf

		DbSelectArea( cAlias )

		If cNomModel == "TAFA232" .And. lTAFCodRub

			nPerRub := aScan(aChave, { |x| AllTrim(x[2]) == "C8R_CODRUB"})

			nPerPos := aScan(aChave, { |x| AllTrim(x[2]) == "C8R_DTINI"})

			nPerTab := aScan(aChave, { |x| AllTrim(x[2]) == "C8R_IDTBRU"})

			//validação para alteração de rubrica via integração
			//para alteração por integração o recno é obtido pelo MsSeek
			//quando a busca é feita para outro objetivo é utilizada a função TAFCodRun
			If nOpc == 4 .Or. nOpc == 6

				(cAlias)->(DBSetOrder(9))

				cCodRub := PADR(aChave[nPerRub][3],TAMSX3("C8R_CODRUB")[1])
				cIdTbRub:= PADR(IIf(nPerTab > 0 , aChave[nPerTab][3], "" ),TAMSX3("C8R_IDTBRU")[1])
				cDtini  := IIf(nPerPos > 0 , aChave[nPerPos][3], "" )

				(cAlias)->( MsSeek( xFilial(cAlias) + cCodRub + cIdTbRub + cDtini + "1"))
				nRecno := (cAlias)->(Recno())

			ElseIf nOpc == 3

				nRecno := C8R->(dbGoTo(TAFCodRub(aChave[nPerRub][3],/*TABELA*/IIf(nPerTab > 0 , aChave[nPerTab][3], "" ), /*DTINI*/IIf(nPerPos > 0 , SubStr(aChave[nPerPos][3],3,4)+SubStr(aChave[nPerPos][3],1,2), "" ),;
				/*DTFIN*/"", /*ATIVO*/"1")))

			Else

				nRecno := C8R->(dbGoTo(TAFCodRub(aChave[nPerRub][3], /*DTINI*/IIf(nPerPos > 0 , SubStr(aChave[nPerPos][3],3,4)+SubStr(aChave[nPerPos][3],1,2), "" ),;
				/*DTFIN*/"", /*ATIVO*/"1", /*TABELA*/IIf(nPerTab > 0 , aChave[nPerTab][3], "" ))))

			EndIf

			lFindCod := aChave[nPerPos][3] == C8R->C8R_DTINI

		ElseIf cNomModel == "TAFA050"

			C1E->(dbSetOrder(7))
			If !( lFindCod := (cAlias)->( MsSeek( xFilial( cAlias ) + cChave + "1" ) ) )

				CR9->( DbSetOrder( 2 ) )
				If ( lFindCod := ( "CR9" )->( MsSeek( xFilial( "CR9" ) + AllTrim(cChave) ) ) )
					
					C1E->( DbSetOrder( 5 ) )
					lFindCod := ( "C1E" )->( MsSeek( xFilial( "C1E" ) + CR9->( CR9_ID + "1" ) ) )
				
				EndIf

			EndIf

		ElseIf cNomModel $ "TAFA257"

			//Se Recno maior que zero, registro foi encontrado
			If nRecnoReg > 0
				lFindCod := .T.
				(cAlias)->( DBGoTo( nRecnoReg ) )
			Else
				(cAlias)->( DbSetOrder( nInd ) )
				lFindCod := (cAlias)->( MsSeek( xFilial( cAlias ) + cChave + "1" ) )
			EndIf

			//Verifica se existe para a chave enviada um registro de exclusão com retorno do ret positivo(_STATUS = '7')
			//e desativa ele para realizar a integração desse novo registro
			If lFindCod

				aTafRot	:= TAFRotinas(cAlias,3,.F.,2)

				If aTafRot[12] $ "EM"

					If !aTafRot[4] $ ("S-1298|S-1299")

						If (cAlias)->&( cAlias + "_STATUS") == "7" .and. (cAlias)->&( cAlias + "_EVENTO")  == 'E'

							//Desativa o evento de exclusão com retorno positivo do ret
							FAltRegAnt( cAlias, '2' )

							//Seta a variável lFindCod como .F. pois o registro não pode ser mais encontrado como ativo
							lFindCod := .F.
							nOpc := 3

						EndIf

					EndIf

				EndIf

			EndIf

		ElseIf cNomModel == "TAFA477"

			lFindCod := .F.

		ElseIf cNomModel == "TAFA263"

			CM8->(DbSetOrder(nInd))
			If (CM8->(MsSeek(xFilial("CM8") + cChave + "1")))

				While (CM8->(!Eof()) .And. (CM8->CM8_FILIAL + CM8->CM8_TRABAL + CM8->CM8_ATIVO == xFilial("CM8") + cChave + "1"))

					nRecnoCM8 := CM8->(Recno())
					CM8->(DbSkip())

				Enddo

				CM8->(DbGoTo(nRecnoCM8))
				If !(Empty(nRecnoCM8))
					lFindCod := .T.
				EndIf

				If ((CM8->CM8_STATUS == "7") .And. (CM8->CM8_EVENTO == "E"))
					
					FAltRegAnt("CM8", "2")
					lFindCod := .F.

				EndIf

			EndIf

		Else

			(cAlias)->( DbSetOrder( nInd ) )
			lFindCod := (cAlias)->( MsSeek( xFilial( cAlias ) + cChave + "1" ) )

			If cNomModel == "TAFA587" .And. !lFindCod .And. nRecnoReg > 0
				
				lFindCod := .T.
				(cAlias)->( DBGoTo( nRecnoReg ) )

			EndIf

			//Verifica se existe para a chave enviada um registro de exclusão com retorno do ret positivo(_STATUS = '7')
			//e desativa ele para realizar a integração desse novo registro
			If lFindCod

				aTafRot	:= TAFRotinas(cAlias,3,.F.,2)

				If aTafRot[4] $ ( "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|S-5501|" )

					While ( cAlias )->( !Eof() ) .and. ( cAlias )->&( cCmpInd ) == xFilial( cAlias ) + cChave

						If  !aTafRot[4] $ "S-5011|S-5013"
							oModelDel := TAFLoadModel(aTafRot[1],MODEL_OPERATION_DELETE)
							FWFormCommit( oModelDel )
							oModelDel:DeActivate()
						Else
							If aTafRot[4] == "S-5011"
								TafDelTot("T2V", xFilial( cAlias ), (cAlias)->&( cAlias + "_ID"), (cAlias)->&( cAlias + "_VERSAO"),{"T2V","T2X","V79","T2Y","T2Z","T70","T0A","T0B","T0B","T0C","T0D","T0E"})
							Else
                            	TafDelTot("V2Z", xFilial( cAlias ),(cAlias)->&( cAlias + "_ID"), (cAlias)->&( cAlias + "_VERSAO"),{"V2Z","V20","V21","V22","V23","V24","V25"})
							EndIf
						EndIf

						( cAlias )->( DBSkip() )

					EndDo

					lFindCod := .F.

				EndIf

				If aTafRot[12] $ "EM"

					If !aTafRot[4] $ ("S-1298|S-1299")

						If (cAlias)->&( cAlias + "_STATUS") == "7" .and. (cAlias)->&( cAlias + "_EVENTO")  == 'E'

							//Desativa o evento de exclusão com retorno positivo do ret
							FAltRegAnt( cAlias, '2' )

							//Seta a variável lFindCod como .F. pois o registro não pode ser mais encontrado como ativo
							lFindCod := .F.

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

		If lFindCod

			//Caso seja um evento cadastral ( Possui Data Inicial e Final de Vigencia ), deve-se
			//verificar se a chave informada possui um periodo em aberto
			If lRuleEvCad
				lFindReg := TafVldPer( cAlias, cChave, aChave, aDatas )
			EndIf

			//Caso seja um evento referente ao vínculo, além de buscar o funcionário na C9V
			//é necessário procurar o vínculo na CUP, pois o mesmo funcionário pode ter vários vínculos.
			If !Empty(cMatTrab)

				("CUP")->(DBSetOrder(1))
				lFindReg := .F.

				While ( ((cAlias)->(!Eof())) .And. ((cAlias)->C9V_CPF == SubStr(cChave,1,11)) .And. (!(lFindReg)))

					lFindReg := ("CUP")->( MsSeek( xFilial("CUP") + (cAlias)->C9V_ID + (cAlias)->C9V_VERSAO + cMatTrab))

					If !lFindReg //Só dou o next se não encontrar, evitando disposicionar caso encontre.
						(cAlias)->(DBSkip())
					EndIf

				EndDo

				//Verifica se a matricula já existe para outro funcionário;
				TafExtMat(cChave, cMatTrab, @nOpc, @aIncons)

			EndIf

			If nOpc <> 9

				If lFindReg

					//S-5003|S-5013
					If cAlias $ "V2P|V2Z"

						nOpc := 4
						lRegTrans := .T.
						lGerNewReg := .T.
						cID := ( cAlias )->&( cAlias + "_ID" )
						cVerAnt := ( cAlias )->&( cAlias + "_VERSAO" )

					//Registro nao foi transmitido ao RET ainda
					ElseIf !( (cAlias)->&( cAlias + "_STATUS") ) $ ( "2|6|4|7" ) .AND. !lTermAfas

						//Inclusao
						If AllTrim((cAlias)->&( cAlias + "_EVENTO" )) == "I"

							If nOpc == 3

								If cNomModel == "TAFA050"
									nOpc := 4 //A operação será de alteração (Exclusivo para o evento S-1000)
								ElseIf cNomModel == "TAFA276"
									nOpc := 4 //A operação será de alteração (Exclusivo para o evento S-2206)
								ElseIf cNomModel $ "TAFA587|TAFA589|TAFA590|TAFA592|TAFA593|TAFA594|TAFA595|TAFA470|TAFA609"
									nOpc := 9 //A operação está em desacordo
								Else
									nOpc := 8 //Chave duplicada
								EndIf

								If nOpc == 4
									TAFAltStat( cAlias, " " )
								EndIf

							ElseIf nOpc == 4

								nOpc	:= 4	//Altera mantendo o Evento como "I"
								TAFAltStat( cAlias, " " )

							ElseIf nOpc == 5

								nOpc	:= 5	//Deleta o registro fisicamente

							EndIf

						//Alteracao
						ElseIf AllTrim((cAlias)->&( cAlias + "_EVENTO" )) == "A"

							If nOpc == 3

								cEvento := ""
								nOpc    := 9			//A operação não pode ser realizada

							ElseIf nOpc == 4

								cEvento := "A"
								nOpc    := 4			//Altera mantendo o Evento como "A"
								TAFAltStat( cAlias, " " )

							ElseIf nOpc == 5

								cChave := (cAlias)->&( cAlias + "_ID" + "+" + cAlias + "_VERANT" )
								TAFRastro( cAlias, nIndIDVer, cChave, .T. )	//Reabro o registro anterior
								nOpc := 5								//Excluo o registro fisicamente

							EndIf

						//Exclusao ou Finalização
						ElseIf AllTrim((cAlias)->&( cAlias + "_EVENTO" )) $ "E|F"

							If nOpc == 3

								nOpc    := 9				//A operação não pode ser realizada
								TAFAltStat( cAlias, " " )

							ElseIf nOpc == 4

								cEvento := "A"
								nOpc    := 4			    //Altera mentendo evento como "A"
								TAFAltStat( cAlias, " " )

							ElseIf nOpc == 5

								nOpc    := 9				//A operação não pode ser realizada

							EndIf

						EndIf

					ElseIf	(cAlias)->&( cAlias + "_STATUS") $( "2|6" )

						cEvento := ""
						nOpc    := 9  	   //A operação não pode ser realizada

					//Registro ja transmitido
					ElseIf (cAlias)->&( cAlias + "_STATUS") $ ( "4|7" ) .OR. lTermAfas

						lRegTrans  := .T.
						cId        := (cAlias)->&(cAlias + "_ID" )
						cVerAnt    := (cAlias)->&(cAlias + "_VERSAO" )
						cProtocolo := (cAlias)->&(cAlias + "_PROTUL" )

						//Inclusao
						If AllTrim((cAlias)->&( cAlias + "_EVENTO" )) == "I"

							If nOpc == 3

								cEvento := ""
								nOpc    := 9  	   //A operação não pode ser realizada

							ElseIf nOpc == 4

								lGerNewReg := .T.
								cEvento := "A"
								nOpc    := 4		   //Inclui novo registro com evento "A"

							ElseIf nOpc == 5

								cEvento := "E"
								lGerNewReg := .T.
								nOpc := 5           //Inclui novo registro com evento "E"

							EndIf

						//Alteracao
						ElseIf AllTrim((cAlias)->&( cAlias + "_EVENTO" )) == "A"

							If nOpc == 3

								cEvento := ""			//A operação não pode ser realizada
								nOpc    := 9

							ElseIf nOpc == 4

								lGerNewReg := .T.
								cEvento := "A"       //Inclui novo registro com Evento "A"

							ElseIf nOpc == 5

								lGerNewReg := .T.
								cEvento := "E"
								nOpc := 5				//Inclui novo registro com evento "E"

							EndIf

						//Exclusao ou Finalização
						ElseIf AllTrim((cAlias)->&( cAlias + "_EVENTO" )) == "E"

							If nOpc == 3

								cEvento := "I"
								nOpc    := 3				//Inclui novo registro com Evento "I"

							ElseIf nOpc == 4

								cEvento := ""
								nOpc    := 9			   //A operação não pode ser realizada

							ElseIf nOpc == 5

								cEvento := ""
								nOpc    := 9				//A operação não pode ser realizada

							EndIf

						EndIf

						//Quando se alterar ou inclui um registro já transmitido deve-se incluir um novo reg
						If lGerNewReg .and. nOpc == 4

							nOpc := 6

						//Exclusao direta
						ElseIf lGerNewReg .and. nOpc == 5

							nOpc := 7

						EndIf

					EndIf

				Else

					//Caso nao possua regisro em aberto para a chave informada deve ser realizada
					//a inclusao de um novo registro
					nOpc := 3

				EndIf

			EndIf

		Else

			If cNomModel == "TAFA050"

				If nOpc == 3 .Or.  nOpc == 4

					nOpc := 9
					Aadd (aIncons,"000002") //"Filial não cadastrada no Cadastro de Complemento de Empresa do TAF."

				EndIf

			ElseIf cNomModel == "TAFA276"

				If nOpc == 4 .Or. nOpc == 5

					If nOpc == 4

						If T1V->T1v_STATUS == "7" .And. T1V->T1v_EVENTO == "E"
							nOpc := 3
						EndIf

					EndIf

					If nOpc <> 3

						nOpc := 9
						Aadd (aIncons,"000007") //"A operação solicitada no XML está em desacordo com o cenário do registro na base do TAF"
					
					EndIf

				EndIf

			Else
				//Quando for realizada uma operação de Alteração e Exclusão de dados que não existam na base do TAF/
				//será retornado um erro no gerenciador de integração para o usuário
				If nOpc == 4 .Or. nOpc == 5

					nOpc := 9
					Aadd (aIncons,"000007") //"A operação solicitada no XML está em desacordo com o cenário do registro na base do TAF"

				EndIf

			EndIf

		EndIf

	Else

		If !Empty( cTags)
			
			Aadd( aIncons, "A(s) Tag(s) " + IIf( Empty( cTags), "<eSocial>", Substr( cTags, 1, Len( cTags ) - 2 ) ) + " são obrigatórias e não " +;
						"foram informadas" )
		Else

			Aadd( aIncons, "Um ou mais campos que compoem a chave e que são obrigatórios não foram informados." )

		EndIf

		nOpc := 9

	EndIf

Return ( nOpc )

//-------------------------------------------------------------------
/*{Protheus.doc} TAFRastro

Verifica o ultimo registro corrente antes do atual e seta o mesmo
como Ativo caso solciitado via parametro

@Param
cAlias	   - Alias da tabela a ser verificada
nIndice    - Indice de Busca
cChave     - Chave de busca da informacao
lInatRgAnt - Indica se deve setar o registro como Ativo

@Return
lRet - Indica se a referencia foi anterior foi encontrada

@author Rodrigo Aguilar
@since 07/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFRastro( cAlias as Character, nIndice as Numeric, cChave as Character, lInatRgAnt as Logical, lMens as Logical, oBrw as Object,;
					aAnalitico as Array, lInfoRPT as logical, cIndApu as Character, cFil as character )

	Local aArea       as Array
	Local aExprFilUsr as Array
	Local aFilter     as Array
	Local aRotinasTAF as Array
	Local cExprFilDef as Character
	Local lRet        as Logical
	Local nFilter     as Numeric
	Local oInfoRPT    as Object
	Local oReport     as Object

	Default aAnalitico := {}
	Default cAlias     := ""
	Default cChave     := ""
	Default cIndApu    := ""
	Default cFil       := ""
	Default lInatRgAnt := .F.
	Default lInfoRPT   := .F.
	Default lMens      := .F.
	Default nIndice    := 0
	Default oBrw       := Nil

	aArea       := {}
	aExprFilUsr := {}
	aFilter     := {}
	aRotinasTAF := Iif(lInfoRPT, TAFRotinas(TafSeekRot(cAlias), 1, .F., 2), {})
	cExprFilDef := ""
	lRet        := .F.
	nFilter     := 0
	oInfoRPT    := Nil
	oReport     := Iif(lInfoRPT, TAFSocialReport():New(), Nil)

	//Controle se o evento é extemporâneo
	lGoExtemp	:= IIf( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	If !lGoExtemp .Or. cAlias $ 'T1V|T1U|T0F|V76|V77|V78|V73' .Or. FwIsInCallStack("TAFPNFUNC")

		// Necessidade dessa implementação, pois o framework passou a considerar os filtros aplicados no browse
		// nas funções de posicionamento (dbseek e msseek)
		If FwIsInCallStack("TAFPNFUNC") .and. oBrowse <> Nil
			oBrw := oBrowse
		EndIf

		If oBrw <> Nil

        	aFilter := oBrw:FWFilter():GetFilter()

			For nFilter := 1 To Len(aFilter)
            
				If aFilter[nFilter][6]
                
                	//Filtro Default
					If aFilter[nFilter][5]
					
						If !Empty(cExprFilDef)
                        	cExprFilDef += " .And. "
						EndIf

                    	cExprFilDef += "(" + aFilter[nFilter][2] + ")"

					Else // Filtro de Usuário

						aAdd( aExprFilUsr, {aFilter[nFilter][1],; 
											aFilter[nFilter][2]} )

					EndIf

				EndIf

			Next nFilter

			oBrw:SetFilterDefault("")
			oBrw:CleanFilter()

		EndIf

		aArea := (cAlias)->( GetArea() )

		DbSelectArea( cAlias )
		(cAlias)->( DbSetOrder( nIndice ) )
		If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave ) ) .OR. (cAlias)->( MsSeek( xFilial( cAlias , cFil ) + cChave ) )

			If lInfoRPT 

				cEvento := aRotinasTAF[4]
				cTipo   := GetSx3Cache(aRotinasTAF[6], "X3_TIPO")
				cPerApu := IIf( cTipo == "D", SubStr( DToS( (cAlias)->( &( aRotinasTAF[6])) ), 1, 6 ), (cAlias)->( &( aRotinasTAF[6])) )
				cFunc   := (cAlias)->( &( aRotinasTAF[11]))
				cIndApu := IIf( aRotinasTAF[12] == "M" .And. lLaySimplif, (cAlias)->( &(cAlias + "_INDAPU")), "1" )

				aAltRPT := SaveAltRPT( cIndApu, cPerApu, cFunc, cAlias )

				InfoRPTObj( aAltRPT[1], aAltRPT[2], aAltRPT[3], aAltRPT[4], aAnalitico,, @oInfoRPT)
				oReport:UpSert(cEvento, "1", xFilial(cAlias), oInfoRPT, .F.)

				InfoRPTObj( aAltRPT[1], aAltRPT[2], aAltRPT[3], aAltRPT[4], aAnalitico,, @oInfoRPT)
				oReport:UpSert(cEvento, "2", xFilial(cAlias), oInfoRPT, .F.)

			EndIf

			lRet  := .T.

			If lInatRgAnt

				FAltRegAnt( cAlias, "1",,,,,cFil )

				If lMens
					//"Registro atual excluído com sucesso!"
					//##
					//"A versão anterior do cadastro foi restaurada."
					MsgInfo( STR0009 + Chr(13) + Chr(10) + STR0010 )
				EndIf

			EndIf

		EndIf

		RestArea( aArea )

	EndIf

	If oBrw <> Nil

    	// Reaplica o filtro Default
		If !Empty(cExprFilDef)
        	oBrw:SetFilterDefault(cExprFilDef)
		EndIf

    	// Reaplica o filtro de usuário
		If Len(aExprFilUsr) > 0

			For nFilter := 1 To Len(aExprFilUsr)
            	oBrw:AddFilter(aExprFilUsr[nFilter][1], aExprFilUsr[nFilter][2])
			Next nFilter

		EndIf

	EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*{Protheus.doc} TAFAltStat

Funcao que altera o campo referente ao Status de acordo com
a informacao enviada no parametro

@Param
cAlias	   - Alias da tabela a ser verificada
cConteud   - Conteudo a ser gravado no campo de Status da tabela

@Return
( Nil )

@author Rodrigo Aguilar
@since 07/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFAltStat( cAlias, cConteud )

	If RecLock( cAlias, .F. )
		(cAlias)->&( cAlias + "_STATUS" ) := cConteud
		(cAlias)->(MsUnlock())
	EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFMsgJob
Funcao padrao para Msg Jobs.

@param xMsg - Mensagem a ser executada no server/monitor - Pode ser 'C' ou 'A'
@param nOpc - Opcao de apresentacao da mensagem:
				1 - Via conout
				2 - Via Monitor
@param nServico	- Numero do Serviço executado (1 - E-SOCIAL, 2 - NFe)

@author Demetrio Fontes De Los Rios
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xTAFMsgJob(xMsg, nOpc, nServico)

	Local cMsg 	 		:= ""

	Default nOpc 		:= 1
	Default nServico 	:= 1
	Default xMsg 		:= "-"

	If ValType(xMsg) == "A"
		aEval(xMsg, {|x| cMsg += xMsg[x] + CRLF})
	Else
		cMsg := xMsg
	EndIf

	If nServico == 1
		cMsg := ("TAF_eSocial -> " + FunName() + ": " + DToS(dDataBase) + "-" + Time() + " -> " + cMsg)
	Else
		cMsg := ("TAF_NFe -> " + FunName() + ": " + DToS(dDataBase) + "-" + Time() + " -> " + cMsg)
	EndIf

	TAFConOut(cMsg)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFSlice

@param cAlias		-> Alias da tabela que será executado o SELECT/UPDATE
@param cTopSelec	-> Quantidade máxima de registros que será considerada na query ( comando TOP no SQL )
@param cIDThread	-> ID da Thread
@param cBancoDB		-> Nome do banco ( retorno do TCGetDb ). Mantido por compatibilidade.
@param lExecUpd		-> Flag que indica se deve ser executado o update ( .T. ) na tabela ou apenas o SELECT ( .F. )
@param cAliasTrb	-> Alias do arquivo que será executado o dbUseArea ( parâmetro de compatibilidade )
@param lVldCompl	-> Flag que indica se deve considerar a validação do de/para no
					   Complemento de Empresa ( para o Job 0 por exemplo não é necessário )
@param nHandleST1	-> Handle de acesso a tabela TAFST1 ( retorno do TCLink )
@param aCodFil		-> Array contendo as filiais relacionadas no Complemento de Empresa ( retorno da TAFCodFilERP )
@param cTicketXML   -> Ticket gerado para o XML que está sendo importado

@author Luccas Curcio

@since 22/11/2016
@version 2.0
/*/
//-------------------------------------------------------------------
Function xTAFSlice( cAlias , cTopSelec , cIDThread , cBancoDB , lExecUpd , cAliasTrb , lVldCompl , nHandleST1 , aCodFil, cTicketXML, cEscopo, cEventos )

	local cQuery
	local cBanco
	local cMvTAFTDB
	local cMvTAFTALI
	local cCodFil
	local aTopInfo
	local nMvTAFPort
	local nX

	default cTopSelec	:=	""
	default cAliasTrb  	:=	""
	default lExecUpd  	:=	.T.
	default lVldCompl  	:=	.T.
	default nHandleST1 	:=	0
	default cTicketXML	:= ""
	Default cEscopo     := ""

	Default cEventos	:= ""

	cQuery		:=	""
	cBanco		:=	upper( allTrim( tcGetDB() ) )
	aTopInfo	:=	{}
	cMvTAFTDB	:=	""
	cMvTAFTALI	:=	""
	cCodFil		:=	""
	nMvTAFPort	:=	0
	nX			:=	0

	//Quando se tratar de Slice na TAFST1, deve executar o acesso a tabela caso esteja em outro banco/dbaccess
	If cAlias == "TAFST1" .and. !xTafSmtERP()

		aTopInfo	:=	FwGetTopInfo()
		cMvTAFTDB	:=	GetNewPar( "MV_TAFTDB", aTopInfo[04] )		//Parametro MV_TAFTDB  - TOP DATABASE DO ERP
		cMvTAFTALI	:=	GetMV( "MV_TAFTALI" )						//Parametro MV_TAFTALI - TOP ALIAS DO ERP
		nMvTAFPort	:=	GetNewPar( "MV_TAFPORT", aTopInfo[03] )		//Parametro MV_TAFPORT - PORTA DO DBACCESS - DEFAULT PORTA CORRENTE

		//Tratamento para quando o MV_TAFPORT estiver 0 pegar o valor corrente da base de dados
		If nMvTAFPort == 0
			nMvTAFPort := aTopInfo[03]
		EndIf

		nHandleST1 := TcLink( cMvTAFTDB + "/" + cMvTAFTALI, aTopInfo[1], nMvTAFPort )

		If nHandleST1 < 0
			xTAFMsgJob( "Falha ao conectar com " + AllTrim( cMvTAFTDB ) + "/" + AllTrim( cMvTAFTALI ) + " em " + aTopInfo[1] )
		EndIf

		cBanco := AllTrim( cMvTAFTDB )

	EndIf

	//atribuo as filiais ( TAFFIL ) relacionadas a empresa que executou o Job a uma string
	//que sera utilizada na clausula WHERE
	For nX := 1 To len( aCodFil )
		cCodFil	+=	"'" + allTrim( aCodFil[ nX ] ) + "', "
	Next nX

	//retiro os dois ultimos caracteres ", "
	cCodFil	:=	subStr( cCodFil , 1 , len( cCodFil ) - 2 )

	If len( aCodFil ) == 0

		TAFXLogMSG( procName() +  " - Tabela C1E sem cadastro de filiais. " )

		//Tratamento para evitar erro na Clausula IN (SQL)
		cCodFil := iIf( empty( alltrim( cCodFil ) ) , "''" , cCodFil )

	EndIf

	If lExecUpd

		cQuery := fSliceQry( lExecUpd, cTopSelec, cAlias, cBanco, .T. , cCodFil, lVldCompl,, cTicketXML, cEscopo, cEventos )

		//Monta Update
		cUpdt := "UPDATE " + cAlias + " "
		cUpdt += "SET " + "TAFSTATUS = '2' "
		cUpdt += "  , " + "TAFIDTHRD = '" + cIdThread + "' "
		cUpdt += "WHERE " + "R_E_C_N_O_ IN ( " + cQuery + " ) "

		//Executa Update
		If TCSQLExec( cUpdt ) >= 0

			If InTransAction()
				xTAFMsgJob( "Update Realizado..." )
				TCSQLExec( "COMMIT" )
			EndIf

		Else

			xTAFMsgJob( "Erro... " + TCSQLError() + " -> " + cUpdt )

		EndIf

	Else

		cQuery := FSliceQry( lExecUpd, cTopSelec, cAlias, cBanco, .T. , cCodFil, lVldCompl )
		cQuery := ChangeQuery( cQuery )
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasTrb, .T., .F. )

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FSliceQry

Funcao utilizada para realizar as devidas consultas nas tabelas de integracao
verificando algumas particularidade de cada banco de dados

@param cTicketXML - Ticket gerado para o XML que está sendo importado


@author Felipe C. Seolin

@since 16/04/2015
@version 1.0

@Altered by

09/06/2015 - Luccas Curcio
	Alteracao para considerar as filiais da empresa correta
	no momento de separar os registros da TAFST1 ( TAFCodFilErp )

25/06/2015 - Paulo Santana
	Alteração para eliminar a validação da existencia do complemento
	de empresa na execução do job 0.

/*/
//-------------------------------------------------------------------
Function FSliceQry( lExecUpd, cTopSelec, cAlias, cBanco, lProc , cCodFil, lVldCompl, nTpProc, cTicketXML, cEscopo, cEventos )

	Local cQuery       := ""

	Default lVldCompl  := .T.
	Default nTpProc    := 1
	Default cTicketXML := ""
	Default cBanco     := ""
	Default cEventos   := ''

	cBanco := Upper(Alltrim(cBanco))

	//Monta Select
	If lExecUpd

		If Val(cTopSelec) == 0 .Or. (cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|" ))
			cQuery := "SELECT TAF2.R_E_C_N_O_ "
		Else
			cQuery := "SELECT TOP " + cTopSelec + " TAF2.R_E_C_N_O_ "
		EndIf

	Else

		cQuery += "SELECT TAFTPREG, TAFKEY, TAFSTATUS, TAFFIL "

	EndIf

	cQuery += "FROM " + cAlias + " TAF2 "

	If lExecUpd
		cQuery += "WHERE TAF2.TAFSTATUS " + IIf( lProc, "", "NOT" ) + " IN ( " + cStsReady + ", '8' ) " + IIf(!Empty(cEventos) .And. IsInCallStack("TAFDEMAND"), " AND TAF2.TAFTPREG IN " + FORMATIN(cEventos, "|") + " ", " " )
	Else
		cQuery += "WHERE ( TAF2.TAFSTATUS = '6' OR TAF2.TAFSTATUS = '7' OR TAF2.TAFSTATUS = '8' OR TAF2.TAFSTATUS = '9' ) "
	EndIf

	// Validação não sera efetuada na chamada do job 0
	If lVldCompl .and. !empty(cCodFil)
		cQuery += "AND TAF2.TAFFIL IN ( " + cCodFil + " ) " //Busca o Codigo 08 pois caso tenha sido cadastrado o complemento de empresa no TAF informacao pode ser integrada.
	EndIf

	If Empty(cEscopo)

		If nTpProc == 1
			cQuery += " AND TAF2.TAFCODMSG IN ( '1', '2', '3' ) "
		ElseIf nTpProc == 2
			cQuery += " AND TAF2.TAFCODMSG IN ('2') "
		EndIf

	Else

		If cEscopo  $  "1"
			cQuery += " AND TAF2.TAFCODMSG IN ( '1', '3' ) "
		ElseIf cEscopo $ "3"
			cQuery += " AND TAF2.TAFCODMSG IN ('2') "
		EndIf

	EndIf

	If IsInCallStack("TAFA428") .And. !IsBlind() .And. Type("cFilEvent") == "C" .And. !Empty(cFilEvent)
		cQuery +=  " AND TAF2.TAFTPREG IN (" + cFilEvent + ") "
	EndIf

	//--------------------------------------------------------------------------------------------
	// Tratamento para quando for o processo de importação XML, só considerar os dados carregados
	//--------------------------------------------------------------------------------------------
	If !Empty(cTicketXML)
		cQuery += " AND TAF2.TAFTICKET = '" + cTicketXML + "' "
	EndIf

	cQuery += "AND TAF2.D_E_L_E_T_ = ' ' "

	If !Empty(cTopSelec) .AND. Val(cTopSelec) > 0

		If cBanco == "ORACLE"
			cQuery += " AND ROWNUM <= " + cTopSelec
		ElseIf cBanco == "DB2"
			cQuery += "FETCH FIRST " + cTopSelec + " ROWS ONLY "
		ElseIf cBanco $ "POSTGRES"
			cQuery += " LIMIT " + cTopSelec + " "
		EndIf

	EndIf

Return(cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafSliceF
Funcao para selecionar os arquivos que serao integrados

@param

@author Daniel Magalhaes

@since 18/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xTafSliceF(cDirFile, cExtFile, nTopFiles, cIDThread, nFiles)

	Local aDirFile 		:= {}
	Local cDirProc 		:= ""
	Local cFilName 		:= ""
	Local nFileAdd 		:= 0
	Local nFor     		:= 0
	Local lRet     		:= .F.
	Local cBarra   		:= "\"
	Local lChangeCase 	:= .T.

	Default cDirFile 	:= GetMv("MV_DIMPTAF",,IIf(IsSrvUnix(),"/","\") +"xml")
	Default cExtFile 	:= "xml"
	Default cIDThread	:= AllTrim(Str(ThreadID()))
	Default nFiles 		:= 0

	If IsSrvUnix()
		cBarra := "/"
		lChangeCase := .F.
	EndIf

	//Verifica a presenca do caracter "\" no final do path
	cDirFile := AllTrim(cDirFile)
	cDirFile += IIf( Right(cDirFile,1) != cBarra, cBarra, "" )

	//Gera a lista de arquivos na pasta de origem
	aDirFile := Directory( cDirFile + "*." + cExtFile,,,lChangeCase)

	//Define o caminho da pasta de trabalho
	//por conta do S.O linux sempre criar os arquivos em caixa baixa.
	cDirProc := cDirFile + "tafainteg_"
	cDirProc += StrZero( Year( Date() ) ,4 ) + "-"
	cDirProc += StrZero( Month( Date() ) ,2 ) + "-"
	cDirProc += StrZero( Day( Date() ) ,2 ) + "_"
	cDirProc += StrTran( Time(), ":", "-" ) + "_"
	cDirProc += "tr" + AllTrim(cIDThread) + cBarra

	//Verifica a criacao da pasta de trabalho
	lRet     := ( MakeDir( cDirProc,Nil,.T. ) == 0 )

	//Inicia a separacao dos arquivos
	If lRet

		For nFor := 1 To Len(aDirFile)

			//Recupera o nome do arquivo
			cFilName := aDirFile[nFor][1]

			//Efetua a copia
			__CopyFile( cDirFile + cFilName, cDirProc + cFilName,,,lChangeCase)

			//Verifica se o arquivo foi gravado na pasta de trabalho
			If File( cDirProc + cFilName,,lChangeCase)

				nFileAdd++
				FErase( cDirFile + cFilName,,lChangeCase)
			EndIf

			If nFileAdd == nTopFiles
				Exit
			EndIf

		Next nFor

	Else

		MsgStop( "Não foi possível criar o diretório " + cDirProc + " . Erro: " + cValToChar( FError() ) )
	
	EndIf

	//Verifica se foram copiados arquivos para a pasta de trabalho
	If nFileAdd == 0

		//Se nao houver arquivos para processamento, remove a pasta de trabalho
		DirRemove( cDirProc )

		//Retorna branco, indicando que nao existe a pasta
		cDirProc := ""

	EndIf
		
	nFiles := nFileAdd

Return cDirProc

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFFunLay

Funcao
@param
@author Demetrio Fontes De Los Rios

@since 07/10/2013
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function xTAFFunLay(cLayout,nOpc,cTagEvt)

	Local cFunction := ""
	Local cLayValid := "1000|1005|1010|1020|1030|1035|1040|1050|1060|1070|1080" +;
		"1100|1200|1202|1207|1210|1220|1250|1260|1270|1280|1300|1310|1320|1330|1340|1360|1370|1380|1390|1299|1400|1800|1298|" +;	//Layouts mensais
	"2190|2200|2205|2206|2220|2230|2250|2210|2280|2298|2299|2399|2300|2306|2320|2325|2330|2340|2345|2241|2245|" +; 				   //Layouts Eventuais
	"2240|2365|2400|2405|2420|2440|2600|2620|2399|2800|2820|3000|4000|5001|5002|5003|5011|5012|5013|1295|2260|2221|2231|2410|2416|2418|2500|2501|3500|5501|2555|5503|"

	Local aFuncXLay := {{"TAF050Grv",""			, "TAF050Xml","C1E"} ,;		// 01 - 1000
						{"TAF253Grv",""			, "TAF253Xml","C92"} ,; 	// 02 - 1005
						{"TAF232Grv",""			, "TAF232Xml","C8R"} ,; 	// 03 - 1010
						{"TAF246Grv",""			, "TAF246Xml","C99"} ,; 	// 04 - 1020
						{"TAF235Grv","TAF235Vld", "TAF235Xml","C8V"} ,; 	// 05 - 1030
						{"TAF236Grv","TAF236Vld", "TAF236Xml","C8X"} ,; 	// 06 - 1040
						{"TAF238Grv","TAF238Vld", "TAF238Xml","C90"} ,; 	// 07 - 1050
						{"TAF389Grv","TAF389Vld", "TAF389Xml","T04"} ,; 	// 08 - 1060
						{"TAF051Grv","TAF051Vld", "TAF051Xml","C1G"} ,; 	// 09 - 1070
						{"TAF248Grv","TAF248Vld", "TAF248Xml","C8W"} ,; 	// 10 - 1080
						{"TAF249Grv","TAF249Vld", "TAF249Xml","C8Y"} ,; 	// 11 - 1100
						{"TAF250Grv","TAF250Vld", "TAF250Xml","C91"} ,; 	// 12 - 1200
						{"TAF413Grv","TAF413Vld", "TAF413Xml","C91"} ,; 	// 13 - 1202
						{"TAF412Grv","TAF412Vld", "TAF412Xml","T3Z"} ,; 	// 14 - 1300
						{"TAF271Grv","TAF271Vld", "TAF271Xml","CMN"} ,; 	// 15 - 1310
						{"TAF288Grv","TAF288Vld", "TAF288Xml","CMN"} ,; 	// 16 - 1320
						{"TAF289Grv","TAF289Vld", "TAF289Xml","CMN"} ,; 	// 17 - 1330
						{"TAF290Grv","TAF290Vld", "TAF290Xml","CMN"} ,; 	// 18 - 1340
						{"TAF272Grv","TAF272Vld", "TAF272Xml","CMR"} ,; 	// 19 - 1250
						{"TAF252Grv","TAF252Vld", "TAF252Xml","C8Q"} ,; 	// 20 - 1360
						{"TAF255Grv","TAF255Vld", "TAF255Xml","C9B"} ,; 	// 21 - 1370
						{"TAF239Grv","TAF239Vld", "TAF239Xml","CRR"} ,; 	// 22 - 1380
						{"TAF292Grv","TAF292Vld", "TAF292Xml","CRV"} ,; 	// 23 - 1390
						{"TAF303Grv","TAF303Vld", "TAF303Xml","CUO"} ,; 	// 24 - 1299
						{"TAF274Grv","TAF274Vld", "TAF274Xml","CMX"} ,; 	// 25 - 1400
						{"TAF298Grv","TAF298Vld", "TAF298Xml","CRS"} ,; 	// 26 - 1800
						{"TAF403Grv","TAF403Vld", "TAF403Xml","T3A"} ,; 	// 27 - 2190
						{"TAF278Grv","TAF278Vld", "TAF278Xml","C9V"} ,; 	// 28 - 2200
						{"TAF276Grv","TAF276Vld", "TAF276Xml","T1V"} ,; 	// 29 - 2206
						{"TAF258Grv","TAF258Vld", "TAF258Xml","C8B"} ,; 	// 30 - 2220
						{"TAF261Grv","TAF261Vld", "TAF261Xml","CM6"} ,; 	// 31 - 2230
						{"TAF263Grv","TAF263Vld", "TAF263Xml","CM8"} ,; 	// 32 - 2250
						{"TAF257Grv","TAF257Vld", "TAF257Xml","CM0"} ,; 	// 33 - 2210
						{"TAF258Grv","TAF258Vld", "TAF258Xml","C8B"} ,; 	// 34 - 2280
						{"TAF279Grv","TAF279Vld", "TAF279Xml","C9V"} ,; 	// 35 - 2300
						{"TAF261Grv","TAF261Vld", "TAF261Xml","CM6"} ,; 	// 36 - 2320
						{"TAF281Grv","TAF281Vld", "TAF281Xml","CRE"} ,; 	// 37 - 2325
						{"TAF291Grv","TAF291Vld", "TAF291Xml","CRF"} ,; 	// 38 - 2330
						{"TAF260Grv","TAF260Vld", "TAF260Xml","CM5"} ,; 	// 39 - 2340
						{"TAF287Grv","TAF287Vld", "TAF287Xml","CRH"} ,; 	// 40 - 2345
						{"TAF264Grv","TAF264Vld", "TAF264Xml","CM9"} ,; 	// 41 - 2240
						{"TAF282Grv","TAF282Vld", "TAF282Xml","CRI"} ,; 	// 42 - 2365
						{"TAF589Grv",""			, "TAF589Xml","V73"} ,;		// 43 - 2400
						{"TAF590Grv",""         , "TAF590Xml","V73"} ,; 	// 44 - 2405
						{"TAF595Grv",""         , "TAF595Xml","V78"} ,; 	// 45 - 2420
						{"TAF265Grv","TAF265Vld", "TAF265Xml","CMC"} ,; 	// 46 - 2440
						{"TAF279Grv","TAF279Vld", "TAF279Xml","C9V"} ,; 	// 47 - 2600
						{"TAF277Grv","TAF277Vld", "TAF277Xml","CRC"} ,; 	// 48 - 2620
						{"TAF280Grv","TAF280Vld", "TAF280Xml","T92"} ,; 	// 49 - 2399
						{"TAF266Grv","TAF266Vld", "TAF266Xml","CMD"} ,; 	// 50 - 2800
						{"TAF267Grv","TAF267Vld", "TAF267Xml","CMF"} ,; 	// 51 - 2298
						{"TAF269Grv","TAF269Vld", "TAF269Xml","CMJ"} ,; 	// 52 - 3000
						{"TAF410Grv","TAF410Vld", "TAF410Xml","T3V"} ,; 	// 53 - 1280
						{"TAF415Grv","TAF415Vld", "TAF415Xml","T1R"} ,; 	// 54 - 4000
						{"TAF411Grv","TAF411Vld", "TAF411Xml","T3W"} ,; 	// 55 - 1220
						{"TAF416Grv","TAF416Vld", "TAF416Xml","T1S"} ,;		// 56 - 1298
						{"TAF266Grv","TAF266Vld", "TAF266Xml","CMD"} ,; 	// 57 - 2299
						{"TAF414Grv","TAF414Vld", "TAF414Xml","T1M"} ,; 	// 58 - 1260
						{"TAF408Grv","TAF408Vld", "TAF408Xml","T2A"} ,;		// 59 - 1270
						{"TAF407Grv","TAF407Vld", "TAF407Xml","T3P"} ,;		// 60 - 1210
						{"TAF275Grv","TAF275Vld", "TAF275Xml","T1U"} ,;		// 61 - 2205
						{"TAF277Grv","TAF277Vld", "TAF277Xml","T0F"} ,; 	// 62 - 2306
						{"TAF404Grv","TAF404Vld", "TAF404Xml","T3B"} ,;		// 63 - 2241
						{"TAF467Grv","TAF467Vld", "TAF467Xml","T5K"} ,;		// 64 - 1035
						{"TAF470Grv","TAF470Vld", "TAF470Xml","T62"} ,; 	// 65 - 1207
						{"TAF426Grv",""         , "TAF426Xml","T0G"} ,;		// 66 - 5012
						{"TAF423Grv",""         , "TAF423Xml","T2M"} ,; 	// 67 - 5001
						{"TAF422Grv",""         , "TAF422Xml","T2G"} ,;		// 68 - 5002
						{"TAF425Grv",""         , "TAF425Xml","T2V"} ,;		// 69 - 5011
						{"TAF477Grv","TAF477Vld", "TAF477Xml","T72"} ,;		// 70 - 1295
						{"TAF484Grv","TAF484Vld", "TAF484Xml","T87"} ,;		// 71 - 2260
						{"TAF520Grv",""         , "TAF520Xml","V2P"} ,;		// 72 - 5003
						{"TAF521Grv",""         , "TAF521Xml","V2Z"} ,;		// 73 - 2241
						{"TAF529Grv","TAF529Vld", "TAF529Xml","V3C"} ,;		// 74 - 2245
						{"TAF528Grv",""         , "TAF528Xml","V3B"} ,; 	// 75 - 2221
						{"TAF587Grv",""         , "TAF587Xml","V72"} ,;		// 76 - 2231
						{"TAF592Grv",""         , "TAF592Xml","V75"} ,;		// 77 - 2410
						{"TAF593Grv",""         , "TAF593Xml","V76"} ,;		// 78 - 2416
						{"TAF594Grv",""         , "TAF594Xml","V77"} ,;		// 79 - 2418
						{"TAF595Grv",""         , "TAF595Xml","V78"} ,;		// 80 - 2420
						{"TAF608Grv",""         , "TAF608Xml","V9U"} ,;		// 81 - 2500		
						{"TAF609Grv",""         , "TAF609Xml","V7C"} ,;		// 82 - 2501
						{"TAF610Grv",""         , "TAF610Xml","V7J"} ,;		// 83 - 3500
						{"TAF611Grv",""         , "TAF611Xml","V7K"} ,;		// 84 - 5501
						{"TAF629Grv",""         , "TAF629Xml","T8I"} ,;		// 85 - 2555
						{"TAF630Grv",""         , "TAF630Xml","T8N"} }		// 86 - 5503
	Default nOpc := 1 	// Default opcao de integracao


	// Verifica se Layout é valido.
	If cLayout$cLayValid

		// Utilizando Case com posicoes fixas definidas para evitar aScan
		Do Case

			Case cLayout$"1000"
				cFunction 	:= aFuncXLay[nS1000,nOpc]
				cTagEvt		:= "/evtInfoEmpregador/infoEmpregador"
			Case cLayout$"1005"
				cFunction 	:= aFuncXLay[nS1005,nOpc]
				cTagEvt		:= "/evtTabEstab/infoEstab"
			Case cLayout$"1010"
				cFunction := aFuncXLay[nS1010,nOpc]
				cTagEvt		:= "/evtTabRubrica/infoRubrica"
			Case cLayout$"1020"
				cFunction := aFuncXLay[nS1020,nOpc]
				cTagEvt		:= "/evtTabLotacao/infoLotacao"
			Case cLayout$"1030"
				cFunction := aFuncXLay[nS1030,nOpc]
				cTagEvt		:= "/evtTabCargo/infoCargo"
			Case cLayout$"1035"
				cFunction := aFuncXLay[nS1035,nOpc]
				cTagEvt		:= "/evtTabCarreira/infoCarreira"
			Case cLayout$"1040"
				cFunction := aFuncXLay[nS1040,nOpc]
				cTagEvt		:= "/evtTabFuncao/infoFuncao"
			Case cLayout$"1050"
				cFunction := aFuncXLay[nS1050,nOpc]
				cTagEvt		:= "/evtTabHorTur/infoHorContratual"
			Case cLayout$"1060"
				cFunction := aFuncXLay[nS1060,nOpc]
				cTagEvt		:= "/evtTabAmbiente/infoAmbiente"
			Case cLayout$"1070"
				cFunction := aFuncXLay[nS1070,nOpc]
				cTagEvt		:= "/evtTabProcesso/infoProcesso"
			Case cLayout$"1080"
				cFunction := aFuncXLay[nS1080,nOpc]
				cTagEvt		:= "/evtTabOperPort/infoOperPortuario"
			Case cLayout$"1100"
				cFunction := aFuncXLay[nS1100,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1200"
				cFunction := aFuncXLay[nS1200,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1202"
				cFunction := aFuncXLay[nS1202,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1207"
				cFunction := aFuncXLay[nS1207,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1260"
				cFunction := aFuncXLay[nS1260,nOpc]
				cTagEvt		:= "/evtComProd/infoComProd"
			Case cLayout$"1270"
				cFunction := aFuncXLay[nS1270,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1300"
				cFunction := aFuncXLay[nS1300,nOpc]
				cTagEvt		:= "/evtContrSindPatr"
			Case cLayout$"1310"
				cFunction := aFuncXLay[nS1310,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1320"
				cFunction := aFuncXLay[nS1320,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1330"
				cFunction := aFuncXLay[nS1330,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1340"
				cFunction := aFuncXLay[nS1340,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1250"
				cFunction := aFuncXLay[nS1250,nOpc]
				cTagEvt		:= "/evtAqProd/infoAquisProd/ideEstabAdquir"
			Case cLayout$"1360"
				cFunction := aFuncXLay[nS1360,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1370"
				cFunction := aFuncXLay[nS1370,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1380"
				cFunction := aFuncXLay[nS1380,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1390"
				cFunction := aFuncXLay[nS1390,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1299"
				cFunction := aFuncXLay[nS1299,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1400"
				cFunction := aFuncXLay[nS1400,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1800"
				cFunction := aFuncXLay[nS1800,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2190"
				cFunction := aFuncXLay[nS2190,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2200"
				cFunction := aFuncXLay[nS2200,nOpc]
				cTagEvt		:= "/evtAdmissao"
			Case cLayout$"2205"
				cFunction := aFuncXLay[nS2205,nOpc]
				cTagEvt		:= "/evtAltCadastral"
			Case cLayout$"2206"
				cFunction := aFuncXLay[nS2206,nOpc]
				cTagEvt		:= "/evtAltContratual"
			Case cLayout$"2220"
				cFunction := aFuncXLay[nS2220,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2230"
				cFunction := aFuncXLay[nS2230,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2250"
				cFunction := aFuncXLay[nS2250,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2210"
				cFunction := aFuncXLay[nS2210,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2280"
				cFunction := aFuncXLay[nS2280,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2300"
				cFunction := aFuncXLay[nS2300,nOpc]
				cTagEvt		:= "/evtTSVInicio"
			Case cLayout$"2306"
				cFunction := aFuncXLay[nS2306,nOpc]
				cTagEvt		:= "/evtTSVAltContr"
			Case cLayout$"2320"
				cFunction := aFuncXLay[nS2320,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2325"
				cFunction := aFuncXLay[nS2325,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2330"
				cFunction := aFuncXLay[nS2330,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2340"
				cFunction := aFuncXLay[nS2340,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2345"
				cFunction := aFuncXLay[nS2345,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2240"
				cFunction := aFuncXLay[nS2240,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2365"
				cFunction := aFuncXLay[nS2365,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2400"
				cFunction := aFuncXLay[nS2400,nOpc]
				cTagEvt		:= "/evtCdBenefIn"
			Case cLayout$"2405"
				cFunction := aFuncXLay[nS2405,nOpc]
				cTagEvt		:= "/evtCdBenefAlt"
			Case cLayout$"2420"
				cFunction := aFuncXLay[nS2420,nOpc]
				cTagEvt		:= "/evtCdBenTerm"
			Case cLayout$"2440"
				cFunction := aFuncXLay[nS2440,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2600"
				cFunction := aFuncXLay[nS2600,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2620"
				cFunction := aFuncXLay[nS2620,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2399"
				cFunction := aFuncXLay[nS2399,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2299"
				cFunction := aFuncXLay[nS2299,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2298"
				cFunction := aFuncXLay[nS2298,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"3000"
				cFunction := aFuncXLay[nS3000,nOpc]
				cTagEvt		:= "/evtExclusao"
			Case cLayout$"1280"
				cFunction := aFuncXLay[nS1280,nOpc]
				cTagEvt		:= "/evtInfoComplPer"
			Case cLayout$"4000"
				cFunction := aFuncXLay[nS4000,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1220"
				cFunction := aFuncXLay[nS1220,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1298"
				cFunction := aFuncXLay[nS1298,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"1210"
				cFunction := aFuncXLay[nS1210,nOpc]
				cTagEvt		:= "/evtPgtos/ideBenef"
			Case cLayout$"2205"
				cFunction := aFuncXLay[nS2205,nOpc]
				cTagEvt		:= "/evtAltCadastral"
			Case cLayout$"2306"
				cFunction := aFuncXLay[nS2306,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"2241"
				cFunction 	:= aFuncXLay[nS2241,nOpc]
				cTagEvt		:= "/"
			Case cLayout$"5001"
				cFunction 	:= aFuncXLay[nS5001,nOpc]
				cTagEvt		:= "/evtBasesTrab"
			Case cLayout$"5002"
				cFunction 	:= aFuncXLay[nS5002,nOpc]
				cTagEvt		:= "/evtIrrfBenef"
			Case cLayout $ "5003"
				cFunction	:= aFuncXLay[nS5003,nOpc]
				cTagEvt		:= "/evtBasesFGTS"
			Case cLayout$"5011"
				cFunction 	:= aFuncXLay[nS5011,nOpc]
				cTagEvt		:= "/evtCS"
			Case cLayout$"5012"
				cFunction 	:= aFuncXLay[nS5012,nOpc]
				cTagEvt		:= "/evtIrrf"
			Case cLayout $ "5013"
				cFunction	:= aFuncXLay[nS5013,nOpc]
				cTagEvt		:= "/evtFGTS"
			Case cLayout$"1295"
				cFunction 	:= aFuncXLay[nS1295,nOpc]
				cTagEvt		:= "/evtTotConting"
			Case cLayout$"2260"
				cFunction 	:= aFuncXLay[nS2260,nOpc]
				cTagEvt		:= "/evtConvInterm"
			Case cLayout$"2245"
				cFunction 	:= aFuncXLay[nS2245,nOpc]
				cTagEvt		:= "/evtTreiCap"
			Case cLayout$"2221"
				cFunction 	:= aFuncXLay[nS2221,nOpc]
				cTagEvt		:= "/evtToxic"
			Case cLayout$"2231"
				cFunction 	:= aFuncXLay[nS2231,nOpc]
				cTagEvt		:= "/evtCessao"			
			Case cLayout$"2410"
				cFunction 	:= aFuncXLay[nS2410,nOpc]
				cTagEvt		:= "/evtCdBenIn"
			Case cLayout$"2416"
				cFunction 	:= aFuncXLay[nS2416,nOpc]
				cTagEvt		:= "/evtCdBenAlt"
			Case cLayout$"2418"
				cFunction 	:= aFuncXLay[nS2418,nOpc]
				cTagEvt		:= "/evtReativBen"
			Case cLayout$"2420"
				cFunction 	:= aFuncXLay[nS2420,nOpc]
				cTagEvt		:= "/evtCdBenTerm"
			Case cLayout$"2500"
				cFunction 	:= aFuncXLay[nS2500,nOpc]
				cTagEvt		:= "/evtProcTrab"
			Case cLayout$"2501"
				cFunction 	:= aFuncXLay[nS2501,nOpc]
				cTagEvt		:= "/evtContProc"
			Case cLayout$"3500"
				cFunction 	:= aFuncXLay[nS3500,nOpc]
				cTagEvt		:= "/evtExcProcTrab"
			Case cLayout$"5501"
				cFunction 	:= aFuncXLay[nS5501,nOpc]
				cTagEvt		:= "/evtTribProcTrab"
			Case cLayout$"2555"
				cFunction 	:= aFuncXLay[nS2555,nOpc]
				cTagEvt		:= "/evtConsolidContProc"
			Case cLayout$"5503"
				cFunction 	:= aFuncXLay[nS5503,nOpc]
				cTagEvt		:= "/evtFGTSProcTrab"	

		End Case

	EndIf

Return cFunction

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExisTag

Retorna o conteudo da TAG informada

@param
cTag - TAG a ser verificada

@author Rodrigo Aguilar

@since 16/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFExisTag( cTag )

	Local cRet := ""

	If !Empty( cTag )

		If oDados:XPathHasNode( cTag  )
			cRet := oDados:XPathGetNodeValue( cTag )
		EndIf

	EndIf

Return ( cRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafVldPer
Faz uma busca na tabela para posicionar o regisro no periodo
de acordo com as datas iniciais e finais informadas, caso a data seja
vazia eh adotada a database para o processamento

@param
cAlias - Alias da Tabela
cChave - Chave de Busca

aChave - Array com a chave dos registros
aDatas - Array com a data de vigencia do codigo

@author Rodrigo Aguilar

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafVldPer(cAlias, cChave, aChave, aDatas)

	Local cNameCmp	:= ''
	Local lRet		:= .F.
	Local nTamMax	:= 3
	Local aArea		:= (cAlias)->(GetArea())
	Local cDtIni	:= ""
	Local cDtFim	:= ""

	//Define o nome dos campos referentes aos codigos
	Do Case

		Case cAlias == 'C8R'
			cNameCmp := 'C8R_CODRUB'

		Case cAlias == 'C99'
			cNameCmp := 'C99_CODIGO'

		Case cAlias == 'C8V'
			cNameCmp := 'C8V_CODIGO'

		Case cAlias == 'C8X'
			cNameCmp := 'C8X_CODIGO'

		Case cAlias == 'C90'
			cNameCmp := 'C90_CODIGO'

		Case cAlias == 'C92'
			cNameCmp := 'C92_TPINSC + C92_NRINSC'
			nTamMax  := 4

		Case cAlias == 'C1G'
			cNameCmp := 'C1G_TPPROC + C1G_NUMPRO'
			nTamMax  := 4

		Case cAlias == 'C8W'
			cNameCmp := 'C8W_CNPJOP'

		Case cAlias == 'T04'
			cNameCmp := 'T04_CODIGO'

	End Case

	//Chave Completa ( Codigo + Data Inicial + Data Final )
	If Len(aChave) == nTamMax

		cNameCmp  += (" + " + cAlias + "_DTINI + " + cAlias + "_DTFIN ")

	//Chave composta por codigo + Data Inicial
	ElseIf Len(aChave) == (nTamMax - 1)

		cNameCmp  += (" + " + cAlias + "_DTINI ")

	EndIf

	While (cAlias)->( !Eof() ) .And.;
			cChave == (cAlias)->&( cNameCmp ) .And.;
			(cAlias)->&( cAlias + '_ATIVO' ) == '1'

		cDtIni := xFunDtPer((cAlias)->&(cAlias + '_DTINI'))
		cDtFim := xFunDtPer((cAlias)->&(cAlias + '_DTFIN'), .T.)

		//Verifica se existe periodo em aberto para a data inicial e final informadas
		If  cDtIni <= aDatas[1] .And. (Empty(cDtFim) .Or. cDtFim >= aDatas[1])

			lRet := .T.
			Exit

		EndIf

		(cAlias)->(DbSkip())

	EndDo

	//Caso nao encontre o periodo para a data inicial e final eu volto a Area para
	//que o regisro encontrado primeiramente no seek da funcao chamadora seja
	//alterado
	If !lRet
		RestArea(aArea)
		lRet := .T.
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafMemo
Funcao que converte os caracteres com acento de um MEMO
para a correta vizualizacao no XML

@parametros

cString - String a ser convertida

@author Fabio V. Santana
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xTafMemo(cString)

	Local cRet := ''
	Local nI , nT := len(cString)
	Local cChar

	For nI := 1 to nT

		cChar := substr(cString,nI,1)

		If ASC(cChar) < 32 .Or. ASC(cChar) > 127
			cRet += '&#x'+xTafToHex(cChar)+';'
		Else
			cRet += cChar
		EndIf

	Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafToHex
Funcao que converte o caractere HEXADECIMAL

@parametros
cString - String a ser convertida

@author Fabio V. Santana
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xTafToHex(cChar)

	Local hx := '0123456789ABCDEF'
	Local n1,n2,nI
	Local xRet := ''

	For nI := 1 to len(cChar)

		nS := asc(substr(cChar,nI,1))
		n1 := Int(nS/16)
		n2 := nS-(n1*16)

		xRet += substr(hx,n1+1,1) + substr(hx,n2+1,1)

	Next

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetData

Transforma a data no formato AAAA-MM-DD para o formato indicado no
 parametro cFormato

@param
cData - Data a ser transformada
cFormato - Formato no qual a data deve ser retornada
cSep - Indica o separador que deve ser utilizado no retorno

@author Anderson Costa

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFGetData( cData, cFormato, cSep )

	Local cRet := ""
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""

	Default cFormato := "DDMMAAAA"
	Default cSep := ""

	If !Empty( cData )

		cData := StrTran(cData,"-","") //Garante que a data que vem do XML nao possua separadores

		cDia := Substr(cData,7,2)
		cMes := Substr(cData,5,2)
		cAno := Substr(cData,1,4)

		If cFormato == "DDMMAAAA"
			cRet := cDia + AllTrim(cSep) + cMes + AllTrim(cSep) + cAno
		ElseIf cFormato == "AAAAMMDD"
			cRet := cAno + AllTrim(cSep) + cMes + AllTrim(cSep) + cDia
		EndIf

	EndIf

Return ( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xAltDates

Função para alterar as Datas Inicial e Final do registro corrente.


@param
cAlias    - Alias da Tabela
nOpc      - Opcao de Operacao escolhida pelo usuario
aDatas    - Array com a Data Inicial e Final do registro

aNewData  - Conteudo da tag novaValidade para operacoes da alteracao de eventos cadastrais
aChave    - Conteudo da chave enviada na integracao

@author Rodrigo Aguilar

@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xAltDates( cAlias, oModel, nOpc, aDatas, aNewData, lRegTrans )

	// Inclusão normal
	If nOpc == 3

		// --> Efetua os tratamentos de datas, caso seja recebido o valor vazio então converte para null para não gravar "000000".
		If Empty( DTOS(aDatas[1]) )
			aDatas[1] := Nil
		EndIf

		If Valtype(aDatas[2]) <> 'U' .And. Empty( DTOS(aDatas[2]) )
			aDatas[2] := Nil
		EndIf

		// Preenche a data inicial para o novo registro
		If Valtype(aDatas[1]) <> 'U'
			oModel:LoadValue('MODEL_' + cAlias, cAlias + '_DTINI', StrZero(Month(aDatas[1]), 2) + StrZero(Year(aDatas[1]), 4))
		EndIf

		// Preenche a data final para o novo registro
		If Valtype(aDatas[2]) <> 'U'
			oModel:LoadValue('MODEL_' + cAlias, cAlias + '_DTFIN', StrZero(Month(aDatas[2]), 2) + StrZero(Year(aDatas[2]), 4))
		EndIf

	// Alteração direta
	ElseIf nOpc == 4

		// --> Efetua os tratamentos de datas, caso seja recebido o valor vazio então converte para null para não gravar "000000".
		If Len(aNewData) > 0

			If Valtype(aNewData[1]) <> 'U' .And. Empty( aNewData[1] )
				aNewData[1] := Nil
			EndIf

			If Len( aNewData ) >= 2
				If Valtype(aNewData[2]) <> 'U' .And. Empty( aNewData[2] )
					aNewData[2] := Nil
				EndIf
			EndIf

		EndIf

		RecLock( cAlias, .F. )

		// Preenche a data inicial para o novo registro
		If Len(aNewData) > 0 .And. Valtype(aNewData[1]) <> 'U'
			(cAlias)->&(cAlias + '_DTINI') := aNewData[1]
		EndIf

		// Preenche a data final para o novo registro
		If Len(aNewData) > 1 .And. Valtype(aNewData[2]) <> 'U'
			(cAlias)->&(cAlias + '_DTFIN') := aNewData[2]
		EndIf

		(cAlias)->(MsUnlock())

	ElseIf lRegTrans
	
		// Alteração de registro transmitido
		If nOpc == 6

			// Se a data final do registro corrente está vazia,
			// preenche com o Mês/Ano anterior à data atual
			// Lógica abaixo foi desabilitada de acordo com layout do eSocial 2.2 //

			// --> Efetua os tratamentos de datas, caso seja recebido o valor vazio então converte para null para não gravar "000000".
			If Len( aNewData ) >= 1

				If ValType( aNewData[1] ) <> "U" .and. Empty( aNewData[1] )
					aNewData[1] := Nil
				EndIf

			EndIf

			If Len( aNewData ) >= 2

				If ValType( aNewData[2] ) <> "U" .and. Empty( aNewData[2] )
					aNewData[2] := Nil
				EndIf

			EndIf

			If aNewData[1] == Nil .And. !Empty(aDatas[1])
				aNewData[1] := StrZero(Month(aDatas[1]), 2) + StrZero(Year(aDatas[1]), 4)
			EndIf

			If aNewData[2] == Nil .And. !Empty(aDatas[2])
				aNewData[2] := StrZero(Month(aDatas[2]), 2) + StrZero(Year(aDatas[2]), 4)
			EndIf

			// Preenche a data inicial para o novo registro
			If Len( aNewData ) >= 1 .and. ValType( aNewData[1] ) <> "U"
				oModel:LoadValue('MODEL_' + cAlias, cAlias + '_DTINI', aNewData[1])
			EndIf

			// Preenche a data final para o novo registro
			If Len( aNewData ) >= 2 .and. ValType( aNewData[2] ) <> "U"
				oModel:LoadValue('MODEL_' + cAlias, cAlias + '_DTFIN', aNewData[2])
			EndIf

		// Exclusão de registro transmitido
		ElseIf nOpc == 7

			// Mantem as datas inicial e final originais no novo registro
			oModel:LoadValue( 'MODEL_' + cAlias, cAlias + '_DTINI', (cAlias)->&(cAlias + '_DTINI'))
			oModel:LoadValue( 'MODEL_' + cAlias, cAlias + '_DTFIN', (cAlias)->&(cAlias + '_DTFIN'))

		EndIf

	EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafSplit

Facilitador para dividir um conteudo de arquivo XML em tamanhos
definidos de acordo com a necessidade.

@Param:
cInfo - Caminho a ser buscado informacao no arquivo XML
aTam  - Array com conteudo numerico, informando o tamanho
        de cada campo. Exemplo de Tag de Telefone:
			* Utilizando o seguinte caracter '011987654321'
			* aTam = {3,12}
			* Retorno sera um Array tamanho 2 com '011' e '987654321'

@Return:
aRet - Array com a quantidade de campos definidos pela quantidade
       de informacoes contidas em aTam. Seu conteudo sera definido
       pela divisao da informacao repassada em cInfo pelos tamanhos
       informados em aTam

@author Felipe C. Seolin
@since 09/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xTafSplit( cInfo, aTam )

	Local aRet := {}
	Local nI   := 0
	Local nIni := 1

	Default cInfo := ""
	Default aTam  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco os valores contidos nas TAG´s do XML³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cInfo )

		If oDados:XPathHasNode( cInfo )
			cInfo := oDados:XPathGetNodeValue( cInfo )
		Else
			cInfo := ""
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se existem valores a serem processados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cInfo )

		For nI := 1 to Len( aTam )
			aAdd( aRet, SubStr( cInfo, nIni, aTam[nI] ) )
			nIni := aTam[nI] + 1
		Next nI

	Else

		For nI := 1 to Len( aTam )
			aAdd( aRet, "" )
		Next nI

	EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafExtMat

Facilitador para dividir um conteudo de arquivo XML em tamanhos
definidos de acordo com a necessidade.

@Param:
cChave: String com a chave do registro na C9V
cMatTrab: Matricula do funcionário
nOpc: Variável que armazena a opção que será utilizada para o model (recebe 9 se matricula já em uso)
aIncons: Array de inconsistencias;

@author Leandro Prado
@since 14/07/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TafExtMat( cChave, cMatTrab, nOpc, aIncons )

	Local aAreaCUP := ("CUP")->( GetArea() )
	Local aAreaC9V := ("C9V")->( GetArea() )

	("CUP")->(DBSetOrder(3))
	("CUP")->( MsSeek( xFilial("CUP") + cMatTrab))

	//Percorro toda a tabela CUP, onde são armazenadas informações sobre o vínculo.
	While ( ("CUP")->(!Eof()) .And. AllTrim(("CUP")->CUP_MATRICULA) == AllTrim(cMatTrab) .And. nOpc <> 9)

		("C9V")->(DBSetOrder(2)) //Filial + ID + Ativo
		If ("C9V")->( MsSeek( xFilial("C9V") + ("CUP")->CUP_ID + "1"))

			//Percorro a tabela C9V onde são armazenadas informações sobre o funcionário.
			While ( ("C9V")->(!Eof()) .And. ("C9V")->C9V_ID == ("CUP")->CUP_ID .And. nOpc <> 9)

				//Se o CPF for diferente do que está sendo cadastrado, alerta que já existe
				//e retorna o nOpc como 9;
					If ( ("C9V")->C9V_CPF <> SubStr(cChave,1,11) )

						Aadd ( aIncons,"Matricula já informada para o funcionário: ID:" +;
							("C9V")->C9V_ID + CRLF + "Nome: " + AllTrim(("C9V")->C9V_NOME) ;
							+ " ;CPF: " + ("C9V")->C9V_CPF + " ;Matricula: " + cMatTrab)
						nOpc := 9

				EndIf

				("C9V")->(DBSkip())

			EndDo

		EndIf

		("CUP")->(DBSkip())

	EndDo

	RestArea( aAreaC9V )
	RestArea( aAreaCUP )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafRetFun

Rotina para retornar todos os eventos referentes ao trabalhador com ou sem vínculo.
Onde a função recebe o CPF e retorna um array de cinco posições com nome do evento, status,
evento (inclusão ou retificação), código da categoria do funcionário e matricula (se for um
funcionário com vínculo).

@Param:
cCPF: CPF do trabalhador com ou sem vínculo.

@Return:
aRet: Array com cinco posições:
	{1,: Nome do evento do funcionário ( S - XXXX )
	 2,: Status do evento - 0 = Válido;1 = Inválido;2 = Transmitido;3 = Transmitido c/ inconsistência;
	 			    4 = Transmitido válido; 9 = Em Processamento
	 3,: Evento - I = Inclusão; A = Retificação
	 4,: código da categoria do funcionário (referente a Tabela 1 do eSocial)
	 5}: Matricula, se trabalhador com vínculo.

@author Leandro Prado
@since 22/07/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafRetFun( cCPF )

	Local aRet := {}
	Local aAreaCUP := ("CUP")->( GetArea() )
	Local aAreaCUU := ("CUU")->( GetArea() )
	Local aAreaC9V := ("C9V")->( GetArea() )
	Local cMatric := ""
	Local cCateg := ""

	("C9V")->(DBSetOrder(3))
	If ("C9V")->( MsSeek( xFilial("C9V") + cCPF + "1"))
	
		//Percorro toda a tabela C9V, onde são armazenadas informações sobre o funcionário com ou sem vínculo.
		While ( ("C9V")->(!Eof()) .And. AllTrim(("C9V")->C9V_CPF) == AllTrim(cCPF))

			If ("C9V")->C9V_ATIVO == "1" //Só retorna algo se for ativo;

				cMatric := ""
				cCateg  := ""

				("CUP")->(DBSetOrder(1)) //Filial + ID + Versao ( + Matricula )
				If ("CUP")->( MsSeek( xFilial("CUP") + ("C9V")->C9V_ID + ("C9V")->C9V_VERSAO))

					cMatric := ("CUP")->CUP_MATRIC
					cCateg := Posicione("C87",1,xFilial("C87") + ("CUP")->(CUP_CODCAT),"C87_CODIGO")

				Else

					//Se não encontrou a matricula, significa que é sem vínculo. Então busca a categoria na CUU.
					If !TAFColumnPos( "C9V_DTINIV" )

						("CUU")->(DBSetOrder(1)) //Filial + ID + Versao
						If ("CUU")->( MsSeek( xFilial("CUU") + ("C9V")->C9V_ID + ("C9V")->C9V_VERSAO))

							If !Empty(("CUU")->(CUU_CATAV))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATAV),"C87_CODIGO")
							ElseIf !Empty(("CUU")->(CUU_CATCI))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATCI),"C87_CODIGO")
							ElseIf !Empty(("CUU")->(CUU_CATSP))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATSP),"C87_CODIGO")
							ElseIf !Empty(("CUU")->(CUU_CATDS))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATDS),"C87_CODIGO")
							ElseIf !Empty(("CUU")->(CUU_CATODS))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATODS),"C87_CODIGO")
							ElseIf !Empty(("CUU")->(CUU_CATES))
								cCateg := Posicione("C87",1,xFilial("C87") + ("CUU")->(CUU_CATES),"C87_CODIGO")
							EndIf

						EndIf

					Else

						cCateg := C9V->C9V_CATCI

					EndIf

				EndIf

				//Adiciono ao array de retorno as informações sobre o funcionário
				aAdd(aRet, { C9V->C9V_NOMEVE, C9V->C9V_STATUS, C9V->C9V_EVENTO, cCateg, cMatric, C9V->C9V_ID, C9V->C9V_VERSAO }  )

			EndIf

			("C9V")->(DBSkip())

		EndDo

	EndIf

	RestArea( aAreaC9V )
	RestArea( aAreaCUU )
	RestArea( aAreaCUP )

Return aRet

// LIXO
Function FTAFVariaveis()

	PRIVATE  Z1_LAYOUT := 01
	PRIVATE  Z1_DESC   := 02
	PRIVATE  Z1_ADAPT   :=03
	PRIVATE  Z1_TABLE   :=04
	PRIVATE  Z1_DESTAB  :=05
	PRIVATE  Z1_ORDER   :=06
	PRIVATE  Z1_MVCOPT  :=07
	PRIVATE  Z1_MVCMET  :=08
	PRIVATE  Z1_CHANELS :=09

	PRIVATE  Z2_CHANEL  :=01
	PRIVATE  Z2_SUPER   :=02
	PRIVATE  Z3_RELAC   :=03
	PRIVATE  Z3_DESC    :=04
	PRIVATE  Z3_IDOUT   :=05
	PRIVATE  Z3_OCCURS := 06
	PRIVATE  Z3_FIELDS  :=07

	PRIVATE  Z4_SEQ     :=01
	PRIVATE  Z4_FIELD   :=02
	PRIVATE  Z4_DESC    :=03
	PRIVATE  Z4_TYPFLD :=04
	PRIVATE  Z4_SOURCE  :=05
	PRIVATE  Z4_EXEC   := 06

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFCmpUnq


@author Demetrio Fontes De Los Rios
@since 20/08/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xTAFCmpUnq( aCmpUnq , aAliasUnq , cCampo, nSixInd, aCpoObrig )

	Local nPos        := 0
	Local cChvUniq    := ""
	Local lRet        := .F.
	Local cExcecao    := ""
	Local lCache      := .f.

	Default nSixInd   := 0
	Default aCpoObrig := {}

	cExcecao	:=	"|C35_MODBC|C2F_CODSER|C35_CST|C2F_CST|CH5_CODCUS|CAD_CODCUS|CAF_CODCUS|CEQ_CODCUS|CHT_CODCUS|CET_CTACP|T19_CODPAR|C2T_CODAJU|C2T_CODAJ1"
	cExcecao	+=	"|C1F_VALIDA|C4U_SERIE|C3N_NRPROC|CHB_NUMARQ|LEH_NRPROC|LEH_DOCARR|LEQ_SUBSER|C5B_CODPAR|C23_NDRAW|C26_SUBSER"
	cExcecao	+=	"|C3A_DESPAC|C32_CCLASS|C2V_SUBSER|C2V_CODITE|C2U_NRPROC|C78_ALQICM|C2T_IDSUBI|CHB_CODCUS|C2T_IDTMOT|C5T_MODBC"
	cExcecao	+=	"|C2D_IDSUBI|C48_ALQQTD|C3K_IDTMOT|C4A_NUMDOC|CA9_DETBCC|CA9_CODCTA|C48_ALQQTD|C5G_CDPAR|C5G_SER|C5G_SUBSER|C5G_NUMDOC|T60_SUBSER|C2Z_NRPROC|C3K_IDSUBI|LEY_CODPAR|"
	cExcecao	+=  "|T86_CODPAR|T86_CODAJU|T86_SERDOC|T86_SUBSER|T86_CODITE|C7C_CTA|C7D_CTA|C20_CODPAR|C26_CODPAR|C28_PARCOL|C28_PARENT|C23_FABRIC|C24_PAREMI|C24_PARTOM"
	cExcecao	+=	"|C2B_CODPAR|C3F_CPARCO|C3F_CPARRE|C3G_CPARCO|C3A_CPARRE|C3A_CPARDE|C3A_CPARCO|C3A_CPAREN|C32_CODPAR|C37_CODPAR|C37_CODPRE|C38_CODPAR|T60_CODPAR|C38_INDREC"
	cExcecao	+=	"|C1M_CTDANT|CGQ_PERIOD|"

	// ********************** Campos que não devem ser utilizados na exceção **********************
	//
	// C25_IDENTI: Este campo era utilizado como exceção mas deixou de ser pois, apesar de não ser
	//	obrigatório, é o único campo da C25 ( com exceção dos outros campos que fazem relacionamento com o pai ).
	//	Por este motivo sempre deve ser informado pelo extrator do ERP.
	//
	// ********************** ************ ************ ************ ************ **********************

	Default aCmpUnq	:= {}
	Default aAliasUnq	:= ""
	Default cCampo	:= ""

	// Para nao fazer o's campo's exceção
	If !(cCampo$cExcecao)

		// Verifica se ja existe informação cacheada para a tabela a ser pesquisada.
		nPos := aScan( aCmpUnq ,{|x| x[1]==aAliasUnq }   )

		If nPos >0

			cChvUniq := aCmpUnq[nPos][2]

		Else

			If nSixInd == 0

				If !Empty(FWX2Nome(aAliasUnq))
					// Adiciona para array de cache da sessao
					cChvUniq := AllTrim(FWX2Unico(aAliasUnq))
					aAdd(aCmpUnq,{aAliasUnq,cChvUniq})
				EndIf

			ElseIf nSixInd > 0 

				//Se a tabela estiver em cache, procura o campo na posição [2] do array.
				lCache := len(aCpoObrig) > 0 .and. aScan(aCpoObrig[1], aAliasUnq) > 0

				If ( lCache .and. aScan(aCpoObrig[2], cCampo) > 0 ) .or. ( !lCache .and. X3Obrigat(cCampo) )
					cChvUniq := (aAliasUnq)->(IndexKey(nSixInd))
				EndIf	

			EndIf

		EndIf

	EndIf

	// Retorno, Trata se o campo faz parte da chave unica da tabela
	lRet := (cCampo$cChvUniq)

Return lRet

// ==================================================================================
// **********************************************************************************

// 							FUNCOES DE INTEGRAÇÃO ONLINE - SIGATAF

// **********************************************************************************
// ==================================================================================

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIntOnLn

Funcao de integracao onLine FisXTAF, chamada atraves do ERP

@param cLayInteg - Registro do layout TAF que sera integrado
@param nOpc - Operacao: Alteracao, Inclusao, Exclusao
@param cFil - Filial da integracao

@return lRet - Indica se a integracao foi realizada com sucesso

@author Alexandre Inacio Lemes

@since 15/03/2016

@version 3.0

/*/
//-------------------------------------------------------------------
Function TAFIntOnLn( cLayInteg , nOpc , cFil )

	Local aDadosST2   := {}
	Local aIncons     := {}
	Local aErrChav    := {}
	Local aErrIntr    := {}
	Local cSeparador  := "|"
	Local cLine       := ""
	Local cPessoa     := ""
	Local cEmpFil     := ""
	Local cTpPessoa   := ""
	Local cCGC        := ""
	Local cCPF        := ""
	Local cInscr      := ""
	Local cCodMun     := ""
	Local cSuframa    := ""
	Local cEndereco   := ""
	Local cUF         := ""
	Local cFax        := ""
	Local cCodPart    := ""
	Local cAIF_TAB    := ""
	Local cSec        := ""
	Local nOrder      := 0
	Local cChv        := ""
	Local cAliasAIF   := ""
	Local cNumCpo     := ""
	Local cCodIss     := ""
	Local cProdCDN    := ""
	Local aReturn     := {}
	Local aLayout     := {}
	Local aLayDel     := {}
	Local lRet        := .F.
	Local lIntegT005  := .F.
	Local lRepetChv   := .T.
	Local cTextErro   := ""
	Local ni          := 0

	Default cLayInteg := ""
	Default nOpc      := IIf(Altera,4,IIf(Inclui,3,IIf(Deleta,5,2)) )
	Default cFil      := cFilAnt

	cEmpFil := ( cEmpAnt + cFil ) //( FWCodEmp() + cFil )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processos Referenciados                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cLayInteg $ "T001AB"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cadastro de Veiculos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T001AC"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Documentos de Arrecadacao                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T001AE"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes Complementares                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T001AK"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Lancamento Fiscal do Documento                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T001AL"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cadastro de Contabilistas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T002"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Participante - Cliente / Fornecedor / Transportadora     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T003CLI|T003FOR|T003TRA"

		_cAlias := "A" + IIf("CLI"$cLayInteg,"1",IIf("FOR"$cLayInteg ,"2","4"))

		//--------------------------------------------------------------------------------
		// Coloca a frente C-para Cliente / F-para fornecedor / T-para Transportadora
		// conforme regra do extrator ExtFisxTAF
		cCodPart := SubStr(cLayInteg,5,1)
		// --------------------------------
		// Aplica o código
		cCodPart += AllTrim(&("M->"+_cAlias+"_COD"))

		If _cAlias <> "A4"
			cCodPart += AllTrim(&("M->"+_cAlias+"_LOJA"))
		EndIf

		// --------------------------------
		// Tipo de pessoa
		cPessoa := IIf("CLI"$cLayInteg,M->A1_PESSOA,IIf("FOR"$cLayInteg,M->A2_TIPO,""))

		// --------------------------------
		// Inscrição
		cInscr	:= AllTrim(IIf("CLI"$cLayInteg,M->A1_INSCR,IIf("FOR"$cLayInteg,M->A2_INSCR,M->A4_INSEST)))

		// --------------------------------
		// Tratamento CGC/CPF e Tipo de pessoa
		// Verificar qual o Tipo de Pessoa e CPF/CGC
		If (cLayInteg $ "T003CLI|T003FOR") .And. AllTrim(cPessoa) <> "X" //Se tipo X(Outros), deve verificar se eh CPF ou CNPJ

			If AllTrim(cPessoa) == "F"
				cCpf := &("M->"+_cAlias+"_CGC")	 // CPF
				cTpPessoa := "1"
			ElseIf AllTrim(cPessoa)== "J"
				cCgc := &("M->"+_cAlias+"_CGC")	// CGC
				cTpPessoa := "2"
			EndIf

		Else

			If Len(AllTrim(&("M->"+_cAlias+"_CGC"))) == 11
				cCpf := &("M->"+_cAlias+"_CGC") // CPF
				cTpPessoa := "1"
			ElseIf Len(AllTrim(&("M->"+_cAlias+"_CGC"))) == 14
				cCgc := &("M->"+_cAlias+"_CGC") // CGC
				cTpPessoa := "2"
			EndIf

		EndIf

		// --------------------------------
		// Endereco
		cEndereco := &("M->"+_cAlias+"_END")
		cUF 	  := &("M->"+_cAlias+"_EST")
		cFax	  := IIf("CLI"$cLayInteg,M->A1_FAX,IIf("FOR"$cLayInteg,M->A2_FAX,""))

		// --------------------------------
		// Cod. Municipio
		If cUF == "EX"
			cCodMun := "99999"
		Else
			cCodMun := &("M->"+_cAlias+"_COD_MUN")
		EndIf

		// --------------------------------
		// SUFRAMA
		cSuframa := IIf("CLI"$cLayInteg,M->A1_SUFRAMA,IIf("FOR"$cLayInteg ,"",M->A4_SUFRAMA))

		cLine := ""
		cLine :=  	cSeparador + Left(cLayInteg,4) 												+ cSeparador +;
			cCodPart																			+ cSeparador +;	// 02 - CODIGO
		&("M->"+_cAlias+"_NOME")																+ cSeparador +;	// 03 - NOME
		&("M->"+_cAlias+"_CODPAIS")																+ cSeparador +; // 04 - COD PAIS
		cCgc																					+ cSeparador +;	// 05 - CGC
		cCpf																					+ cSeparador +; // 06 - CPF
		cInscr																					+ cSeparador +;	// 07 - INSCR
		cCodMun									   											 	+ cSeparador +;	// 08 - CODMUN
		cSuframa																				+ cSeparador +;	// 09 - SUFRAMA
		""						 																+ cSeparador +;	// 10 - TP LOGRADOURO
		FisGetEnd( cEndereco, cUF )[1]			    											+ cSeparador +;	// 11 - ENDEREÇO
		IIf( !Empty( FisGetEnd( cEndereco, cUF )[2] ), FisGetEnd( cEndereco, cUF )[3], "SN" )	+ cSeparador +;	// 12 - NUMERO
		&("M->"+_cAlias+"_COMPLEM")				    											+ cSeparador +;	// 13 - COMPLEMENTO
		""																						+ cSeparador +;	// 14 - Tp Bairro
		&("M->"+_cAlias+"_BAIRRO")				    											+ cSeparador +;	// 15 - BAIRRO
		cUF																						+ cSeparador +;	// 16 - UF
		&("M->"+_cAlias+"_CEP")					   											 	+ cSeparador +;	// 17 - CEP
		&("M->"+_cAlias+"_DDD")					    											+ cSeparador +;	// 18 - DDD
		&("M->"+_cAlias+"_TEL")					    											+ cSeparador +;	// 19 - FONE
		&("M->"+_cAlias+"_DDD")					    											+ cSeparador +;	// 20 - DDD
		cFax 																					+ cSeparador +;	// 21 - FAX
		&("M->"+_cAlias+"_EMAIL")				    											+ cSeparador +;	// 22 - EMAIL
		dTos(dDataBase)							    											+ cSeparador +;	// 23 - DT INCLUSAO
		cTpPessoa																				+ cSeparador + CRLF// 24 - TPPESSOA

		// ------------------------------------------------------------------
		// Verifico se houve alteração junto AIF para geração do T007AA
		nOrder    := IIf(_cAlias $ ("A1|A2"),1,3)
		cAliasAIF := "S"+_cAlias
		cAIF_TAB  := PADR(cAliasAIF,TAMSX3("AIF_TABELA")[1])

		cChv := xFilial("AIF") + xFilial(cAliasAIF) + cAliasAIF
		cChv += &("M->"+_cAlias+"_COD")

		If Alltrim(_cAlias) <> "A4"
			cChv += &("M->"+_cAlias+"_LOJA")
		EndIf

		cLayInteg := SubSTR(cLayInteg,1,4)
		AIF->(dbSetOrder(nOrder))

		If AIF->(MsSeek(cChv))

			cSec := "01"
			// ----------------------------
			// T003AA
			cAliasDePa := IIf(_cAlias == "A4","SA4_AIF","SA1_AIF")

			While AIF->( !Eof() ) .And. lRepetChv

				cNumCpo:= FDeParaTAF(cAliasDePa, {AllTrim(AIF->AIF_CAMPO),AIF->AIF_CONTEU})

				If !Empty(cNumCpo)

					cSec := Soma1(cSec)
					cLine += cSeparador + cLayInteg + "AA"	+ cSeparador +;
						DtoS(AIF->AIF_DATA)                 + cSeparador +;
						AIF->AIF_HORA + ":" + cSec 			+ cSeparador +;
						cNumCpo								+ cSeparador +;
						AIF->AIF_CONTEU       				+ cSeparador +CRLF

				EndIf

				AIF->( DbSkip() )

				If !( (Alltrim(_cAlias) <> "A4" .AND. cChv == AIF->(AIF_FILIAL+AIF_FILTAB+AIF_TABELA+AIF_CODIGO+AIF_LOJA )) .OR. ;
						(Alltrim(_cAlias) == "A4" .And. cChv == AIF->(AIF_FILIAL+AIF_FILTAB+AIF_TABELA+AIF_TRANSP)) )
					lRepetChv := .F. //Mudou a chave de relacionamento com o registro pai
				EndIf

			EndDo

		EndIf

		aDadosST2 := FLine2Array(AllTrim(cLine),cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Unidade de Medidas                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T005"

		cLine := ""
		cLine :=  cSeparador + cLayInteg + cSeparador + ;
			FWFLDGET("AH_UNIMED") + cSeparador + ;
			FWFLDGET("AH_DESCPO") + cSeparador + CRLF

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Produto                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T007"

		//---------------------------------------------------------------------------------------
		//Obtendo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deverah
		//estar conforme LC 116/03
		//Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação
		//existe a possibilidade de ser n / n
		//---------------------------------------------------------------------------------------
		cCodIss  := SubStr ( M->B1_CODISS, 1, 5)
		cProdCDN := Alltrim( M->B1_COD )

		If CDN->( MsSeek( xFilial( "CDN" ) + PadR( cCodIss, 8) + cProdCDN ) )

			cCodIss := SubStr( CDN->CDN_CODLST, 1, 4 )

		ElseIf CDN->( MsSeek( xFilial( "CDN" ) + PadR( cCodIss, 8 ) ) )

			cCodIss := SubStr( CDN->CDN_CODLST, 1, 4 )

		Else

			cCodIss := ''

		EndIf

		cLine := ""
		cLine := cSeparador + cLayInteg 	+ cSeparador +;
			M->B1_COD 							+ cSeparador +;
			M->B1_DESC 						    + cSeparador +;
			M->B1_CODBAR 						+ cSeparador +;
			M->B1_UM 							+ cSeparador +;
			FDeParaTAF( "SB1", { M->B1_TIPO, M->B1_CODISS } ) + cSeparador +;
			M->B1_POSIPI 						+ cSeparador +;
			M->B1_EX_NCM 						+ cSeparador +;
			IIf(Empty(M->B1_CODISS),Left(M->B1_POSIPI,2),"00") + cSeparador +;
			cCodIss	 						+ cSeparador +;
			"" 									+ cSeparador +;
			""/*B5_TABINC*/ 					+ cSeparador +;
			""/*B5_CODGRU*/ 					+ cSeparador +;
			M->B1_ORIGEM 						+ cSeparador +;
			DToS( dDataBase )					+ cSeparador +;
			Val2Str( IIf(M->B1_PICM > 0,M->B1_PICM,SuperGetMV("MV_ICMPAD",,18)) , 6, 2 ) + cSeparador +;
			"" 									+ cSeparador +;
			Val2Str( M->B1_IPI, 5, 2 )		    + cSeparador +;
			"" 									+ cSeparador + CRLF

		dbSelectArea("C1J")
		C1J->(dbSetOrder(1))


		dbSelectArea("SAH")
		SAH->(dbSetOrder(1))

		// Verifico se a unidade de medida não esta no TAF
		// Se nao estiver aproveito para integrar também o Layout T005
		If AliasIndic("C1J") 	// Verifica se existe tabela C1J - Unidade de medida do TAF

			// Verifica se a unidade de medida do produto consta no TAF
			If (lIntegT005 := !(C1J->(MsSeek(xFilial("C1J")+M->B1_UM ))))

				// Se não existir, posiciona no cadastro de unidade de medida SAH
				// para integração
				lIntegT005 := SAH->(MsSeek( xFilial("SAH") + M->B1_UM ) )

			EndIf

		EndIf

		// ------------------------------------------------------------------
		// Verifico se houve alteração junto AIF para geração do T007AA
		AIF->(dbSetOrder(2))
		cAIF_TAB:= PADR("SB1",TAMSX3("AIF_TABELA")[1])
		If AIF->(MsSeek(xFilial("AIF") + xFilial("SB1") + cAIF_TAB + M->B1_COD))

			cSec := "01"
			// ----------------------------
			// T007AA

			While AIF->( !Eof() .And. xFilial("AIF")+cFilAnt+cAIF_TAB+M->B1_COD == AIF_FILIAL+AIF_FILTAB+AIF_TABELA+AIF_CODPRO)

				cNumCpo:= FDeParaTAF("SB1_AIF", {AllTrim(AIF->AIF_CAMPO),AIF->AIF_CONTEU})

				If !Empty(cNumCpo)

					cSec := Soma1(cSec)
					cLine += cSeparador + cLayInteg+"AA"+ cSeparador +;
						DtoS(AIF->AIF_DATA)                 + cSeparador +;
						cNumCpo								 + cSeparador +;
						AIF->AIF_CONTEU                     + cSeparador +;
						AIF->AIF_HORA + ":" + cSec          + cSeparador +CRLF

				EndIf

				AIF->( DbSkip() )

			EndDo

		EndIf

		// ---------------------------------------------------------------------
		// Transforma o cLine no aDadosST2 como o motor deseja receber
		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

		// -----------------------------------------------------
		// T005 - UNIDADE DE MEDIDA
		// -----------------------------------------------------
		If lIntegT005

			cLayInteg := "T005"

			cLine := ""
			cLine :=  cSeparador + cLayInteg + cSeparador + ;
				IIf(lIntegT005,SAH->AH_UNIMED, M->AH_UNIMED ) + cSeparador + ;
				IIf(lIntegT005,SAH->AH_DESCPO, M->AH_DESCPO ) + cSeparador + CRLF

			aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Natureza da Operacao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T009"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Conta Contabil                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T010"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Centro de Custo                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T011"

		aDadosST2 := FLine2Array(cLine,cLayInteg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Documento Fiscal                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cLayInteg $ "T013"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A integracao ON LINE NATIVA com Protheus e realizada por JOB startado na funcao ATUSF3()³
		//³do MATXFIS, A rotina abaixo somente realiza a EXCLUSAO das Notas Fiscais de terceiros   ³
		//³F1_FORMUL = "N" disparadas pelos programas MATA103.PRW, MATA116.PRW e MATA119.PRW.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5
		/*
		Chave do registro:
			02 - IND_OPER
			03 - TIPO_DOC
			04 - IND_EMIT
			05 - COD_PART
			06 - COD_SIT
			07 - SER
			08 - SUB
			09 - NUM_DOC
			10 - DT_DOC
			15 - COD_MOD
			19 - DT_E_S
		*/

			cLine	  :=	cSeparador + "T013"					+ cSeparador +;	// 01 - T013
			"0"							        + cSeparador +;	// 02 - IND_OPER - Fixo "0" - Entrada
			FDeParaTAF("SFT_TIPO",{SF1->F1_TIPO})+cSeparador+;	// 03 - TIPO_DOC -  Utiliza FDeParaTAF para converter o campo FT_TIPO para o codigo do TAF
			"1"							        + cSeparador +;	// 04 - IND_EMIT - Formulario Proprio = Nao
			"F"+SF1->F1_FORNECE+SF1->F1_LOJA	+ cSeparador +;	// 05 - COD_PART
			"00"								+ cSeparador +;	// 06 - COD_SIT
			SF1->F1_SERIE						+ cSeparador +;	// 07 - SER
			""									+ cSeparador +;	// 08 - SUB
			SF1->F1_DOC 						+ cSeparador +;	// 09 - NUM_DOC
			DToS( SF1->F1_EMISSAO )				+ cSeparador +;	// 10 - DT_DOC
			""									+ cSeparador +;	// 11 -
			""									+ cSeparador +;	// 12 -
			""									+ cSeparador +;	// 13 -
			""									+ cSeparador +;	// 14 -
			AModNot( SF1->F1_ESPECIE )			+ cSeparador +;	// 15 - COD_MOD
			""									+ cSeparador +;	// 16 -
			""									+ cSeparador +;	// 17 -
			""									+ cSeparador +;	// 18 -
			DToS( SF1->F1_DTDIGIT )				+ cSeparador +;	// 19 - DT_E_S
			""									+ cSeparador +;	// 20 -
			"" 									+ cSeparador +;	// 21 -
			""									+ cSeparador +;	// 22 -
			""									+ cSeparador +;	// 23 -
			""									+ cSeparador +;	// 24 -
			""									+ cSeparador +;	// 25 -
			""									+ cSeparador +;	// 26 -
			""									+ cSeparador +;	// 27 -
			""									+ cSeparador +;	// 28 -
			""									+ cSeparador +;	// 29 -
			""									+ cSeparador +;	// 30 -
			""									+ cSeparador +;	// 31 -
			""									+ cSeparador +;	// 32 -
			""									+ cSeparador +;	// 33 -
			""									+ cSeparador +;	// 34 -
			""									+ cSeparador +;	// 35 -
			""									+ cSeparador +;	// 37 -
			""									+ cSeparador +;	// 38 -
			""									+ cSeparador +;	// 39 -
			""									+ cSeparador +;	// 40 -
			""									+ cSeparador +;	// 41 -
			""									+ cSeparador +;	// 42 -
			""									+ cSeparador +;	// 43 -
			""									+ cSeparador +;	// 44 -
			""									+ cSeparador +;	// 45 -
			""									+ cSeparador +;	// 46 -
			""									+ cSeparador +;	// 47 -
			""									+ cSeparador +;	// 48 -
			""									+ cSeparador +;	// 49 -
			""									+ cSeparador +;	// 50 -
			""									+ cSeparador +;	// 51 -
			""									+ cSeparador +;	// 52 -
			""									+ cSeparador +;	// 53 -
			""									+ cSeparador +;	// 54 -
			""									+ cSeparador +;	// 55 -
			""									+ cSeparador +;	// 56 -
			""									+ cSeparador +;	// 57 -
			""									+ cSeparador +;	// 58 -
			""									+ cSeparador +;	// 59 -
			""									+ cSeparador + CRLF	// 60 -

			aDadosST2:= FLine2Array(cLine,cLayInteg,nOpc)

		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois de montar os registros do Layout TAF manualmente, eh feita a chamada da funcao TAFProcLine ( Motor de Integracao )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aReturn := FReadLayout( cLayInteg, .T. )

	aLayout := aReturn[1]
	aLaydel := aReturn[2]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois de montar os registros do Layout TAF manualmente, eh feita a chamada da funcao TAFProcLine ( Motor de Integracao )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TAFProcLine( .T. , "" , cEmpFil , aDadosST2 , /*aRecInt*/ , /*aRecErr*/ , @aErrChav , @aErrIntr , @aIncons , cLayInteg , , , ,aLayout , aLaydel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao e Alteracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4

		If !Empty( aErrChav ) .Or. !Empty( aErrIntr )
			TAFXLogMSG("Atenção! - Não foi possível incluir o "+cLayInteg+" no TAF - TOTVS Automação Fiscal")
		Else
			lRet := !Empty(aIncons)
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Exclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	ElseIf nOpc == 5

		If !Empty( aErrChav ) .or. !Empty( aErrIntr )
			TAFXLogMSG("Atenção! - Não foi possível excluir o "+cLayInteg+" no TAF - TOTVS Automação Fiscal")
		EndIf

	EndIf

	If len(aErrIntr) > 0

		For ni:= 1 to Len(aErrIntr)
			cTextErro += aErrIntr[1] + Chr(13) + Chr(10)
		Next

		Aviso("Integração TAF",cTextErro,{"Fechar"},3)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FLine2Array

Funcao Auxiliar que adequa a cLine e corta os dados para o array aDadosST2

@param cLine - Registro do layout TAF que sera integrado com todos os campos separados por pipe "|"
@param cChannel - Layout TOTVS
@param nOpc - Operacao: Alteracao, Inclusao, Exclusao

@return aDadosST2 -Array com os dados prontos para o Motor de Integracao TAFProcLine()

@author Alexandre Inacio Lemes

@since 15/03/2016

@version 2.0

/*/
//-------------------------------------------------------------------
Static Function FLine2Array(cLine,cChannel,nOpc)

	Local aDadosST2	:= {}
	Local nTagEnd	:= 0
	Local cRegistro	:= ""

	DEFAULT cLine 	:= ""
	DEFAULT cChannel:= ""
	DEFAULT nOpc    := 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de Exclusao do registro do Layout TAF eh necessario que a cLine³
	//³seja modificada inciando a linha com o LayOut T999. Mais detalhes favor³
	//³consultar no Layout TOTVS.                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5
		cLine	:= "T999" + cLine
		cChannel:= "T999"
	EndIf

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

		aAdd( aDadosST2, Str2Arr( cRegistro , "|" ) )

		//Aadd(aKeyDupl,{(cST2Alias)->TAFKEY, (cST2Alias)->TAFSEQ } )

		cSlice := Substr( cLine , nTagEnd + 3 , Len(cLine) )

		If Empty( cSlice )
			Exit
		EndIf

		cChannel := Substr( cSlice ,  1 ,  AT( "|" , cSlice ) - 1 )
		cLine := Substr( cSlice , 1 , Len(cSlice) )

		If AT( CHR(10) , cLine ) == 0

			cLine := cLine

			//Tratamento para que seja retirado o primeiro pipe da linha do registro, o mesmo não pode ser utilizado
			//senao ocorre erro no Str2Arr().
			If Substr(cLine,1,1) == "|"
				cLine := Substr(cLine,2,Len(cLine))
			EndIf

			aAdd( aDadosST2, Str2Arr( cLine  , "|" ) )

			//Aadd(aKeyDupl,{(cST2Alias)->TAFKEY, (cST2Alias)->TAFSEQ } )
			Exit

		EndIf

	EndDo

Return aDadosST2

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExstInt

Funcao que valida se o ERP possui integracao nativa com o TAF

@Param lESocial - Indica se a validação é chamada nativa do Protheus e-Social
@return lRet - Boleano que indica integracao com o TAF

@author Demetrio Fontes de Los Rios

@since

@version 1.0

/*/
//-------------------------------------------------------------------
// Verifica se o produto existe no ambiente chamado
Function TAFExstInt( lESocial )

	Local lRet :=  		FindFunction("TAFIntOnLn") .AND.;
		FindFunction("TAFProcLine") .AND.;
		AliasInDic("C1E") .AND.;
		cPaisLoc=="BRA"

	Default lESocial := .F.

	If lRet .and. !lESocial
		lRet := .f. //"S"$Upper(AllTrim(SuperGetMV("MV_INTTAF", .F., .F.))) // O recurso de integração ON-LINE (MV_INTTAF = S) foi descontinuado.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFXCHKKEY
Funcao que verifica se um model possui chave duplicada

@param    cModel - Model que deseja verificar se existe erros

@Return   lRet   - Retorna .T. quando não houver erros no model

@author Vitor Siqueira
@since 19/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFXCHKKEY(oModel)

	Local lRet 	:= .T.
	Local nCnt 	:=  2 //Começa apartir da posição 2 pois assim não pega o model pai
	Local cModel  := ''
	Local oStru	:= Nil

	While  nCnt <= Len(oModel:Adependency) .AND. lRet

		cModel := oModel:Adependency[nCnt][1] // Pega o model a ser criada a estrutura

		oStru := FWFormStruct( 1, Substr(cModel, 1, 3) )

		lVldModel := IIf( Type( "lVldModel" ) == "U", .F., lVldModel )

		oStru:SetProperty( "*", MODEL_FIELD_VALID  , {|| lVldModel }) // Remove a validação dos campos
		oStru:SetProperty( "*", MODEL_FIELD_OBRIGAT, {|| .F. }) 	  // Remove a obrigatoriedade dos campos

		If oModel:VldData(oModel:Adependency[nCnt][1],.T.)
			lRet := .T.
		Else
			lRet := .F.
		EndIf

		nCnt++

	EndDo

Return	lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRegEmp

Funcao de transforma os valores recebidos do ERP para valores válidos
do cadastro de Regime da Mepresa (T39 e filhos T36, T35 e T38)

@param	cCampo - Recebe o campo do layout que será transformado
        cValor - Recebe o valor que será transformado

@return lRet - Retorna o valor válido

@author Daniel Maniglia

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFRegEmp(cCampo,cValor)

	Local lRet

	If cCampo == 'T39_TIPREG' // Nome do campo do layout

		Do Case
			Case cValor == 'N' // Regime Normal
				lRet := '01'
			Case cValor == 'S' // Simples Nacional
				lRet := '08'
		End Case

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafExisEsc
Função que informa para o GPE se o TAF está configurado para integração com a base do cliente
e a versão do evento do eSocial no TAF

@param    cEvento - Evento que deve ser validado para indicar a qual versão existe no TAF

@Return   aRet   - [1] - Indica se o cliente possui integração com o TAF
					 [2] - Indica a versão do Layout do eSocial para o event enviado

@author Rodrigo Aguilar
@since 23/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafExisEsc( cEvento )

	Local lRet := TAFExstInt( .T. )
	Local aRet := Array(2)

	Default cEvento := ''

	aRet[1] := lRet

	If aRet[1]

		If cEvento == 'S1000'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1005'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1010'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1020'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1030'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1035'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1040'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1050'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1060'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1070'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1080'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1200'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1202'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1207'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1210'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1250'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1260'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1270'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1280'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1295'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1298'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1299'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S1300'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2190'
			aRet[2] := '2.4.02'
		ElseIf cEvento $ 'S2100|S2200'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2205'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2206'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2230'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2240'
			aRet[2] := '1.0'
		ElseIf cEvento == 'S2241'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2250'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2260'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2298'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2299'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2300'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2306'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2399'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S2400'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S3000'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S5001'
			aRet[2] := '2.4.02'
		ElseIf cEvento == "S5003"
			aRet[2] := "2.5"
		ElseIf cEvento == 'S5011'
			aRet[2] := '2.4.02'
		ElseIf cEvento == 'S5012'
			aRet[2] := '2.4.02'
		ElseIf cEvento == "S5013"
			aRet[2] := "2.5"
		ElseIf cEvento == "S2221"
			aRet[2] := "2.5"
		ElseIf cEvento == "S2245"
			aRet[2] := "2.5"
		ElseIf cEvento == "S2210"
			aRet[2] := '1.0'
		ElseIf cEvento == "S2220"
			aRet[2] := '1.0'
		EndIf

	Else

		aRet[2] := ''

	EndIf

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafChvData

Retorna as datas inicial e final a partir da chave do registro.

@param	cAlias - Alias da Tabela
		aChave - Array com a chave do registro

@return aDatas - Array com as datas inicial e final

@author Anderson Costa
@since 10/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafChvData(cAlias, aChave)

	Local nTamMax	:= 3
	Local aDatas	:= {nil,nil}

	Default cAlias 	:= ''
	Default aChave 	:= {}

	aDatas[1] := dDataBase	//Caso não tenha sido informada na chave, a data inicial será a data base

	//Esses registro possuem chave composta, por exemplo: TIPO + CODIGO.
	//Portanto o nTamMax deve ser incrementado
	If cAlias $ 'C92|C1G'
		nTamMax  := 4
	EndIf

	//Chave Completa ( Codigo + Data Inicial + Data Final )
	If Upper(Alltrim(cAlias)) == "C8R" .And. Len( aChave ) == 4 .And. nTamMax == 3

		aDatas[1] := xFunDtPer(aChave[ nTamMax - 1, 3 ])
		aDatas[2] := xFunDtPer(aChave[ nTamMax, 3 ], .T. , , cAlias)

	ElseIf Len( aChave ) == nTamMax

		aDatas[1] := xFunDtPer(aChave[ nTamMax - 1, 3 ])
		aDatas[2] := xFunDtPer(aChave[ nTamMax, 3 ], .T. , , cAlias)

	//Chave Parcial (Codigo + Data Inicial)
	ElseIf Len( aChave ) == (nTamMax - 1)

		aDatas[1] := xFunDtPer(aChave[ nTamMax - 1, 3 ])

	EndIf

Return (aDatas)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCheckReg

Funcao que verifica se um determinado registro existe no banco, caso contrario cadastra ele.
@param cAlias  -> Alias que deseja realizar a busca pelo produto
@param nIndice -> Indice que deseja realizar a busca
@param cChave -> Chave para realizar a busca

@author Vitor Henrique
@since 18/08/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafCheckReg(cAlias , nIndice, cChave)

	DbSelectArea(cAlias)
	(cAlias)->( DbSetOrder( nIndice ) )

	// Verifica se existe um determinado produto na tabela C1L
	If cAlias == 'C1L'

		//No caso da C1L ele ira realizar a busca pelo codigo do produto
		If !(cAlias)->( MsSeek( xFilial( "C1L" ) + cChave ) )

			If RecLock(cAlias,.T.)

				(cAlias)->C1L_FILIAL	:=	xFilial("C1L")
				(cAlias)->C1L_ID		:=	GETSX8NUM("C1L","C1L_ID")

				( cAlias )->(ConfirmSX8())

				(cAlias)->C1L_CODIGO	:=	cChave
				(cAlias)->C1L_DESCRI	:=	cChave
				MsUnlock()

			EndIf

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSeqReg
Esta função tem como objetivo buscar a próxima sequência do campo nas tabelas
 que utilizam controle interno com campo sequencial e que não permite a integração
 desse campo.

@Author Rafael Völtz
@since 28/06/2017
@version 1.0

@param cTable	 - Tabela que possui o campo sequencia.
        cIdWhere - Identificador do registro que busca-se sequenciar.

/*/
//-------------------------------------------------------------------
Function TAFSeqReg( cTable, cIdWhere )

	Local cAliasSeq  := GetNextAlias()
	Local cSelect    := ""
	Local cFrom      := ""
	Local cWhere     := ""
	Local nSeqReg    := 0
	Local cIsNull    := Iif(!("INFORMIX" $ Upper(AllTrim(TcGetDb()))), "COALESCE", "NVL")

	Default cTable   := ""
	Default cIdWhere := ""
                                                                                          
	If cTable == 'C2T'
		cSelect := "MAX(" + cTable + "_SEQREG)  SEQ"
	Else
		If "POSTGRES" $ Upper(AllTrim(TcGetDb()))
			cSelect := cIsNull + "(GREATEST(MAX(NULLIF(" + cTable + "_SEQREG, '    ')::INTEGER), 0), 0) AS SEQ "
		ElseIf "INFORMIX" $ Upper(AllTrim(TcGetDb()))
			cSelect := cIsNull + "(GREATEST(MAX(TO_NUMBER(NVL(TRIM(" + cTable + "_SEQREG), '0'))), 0), 0) AS SEQ "
		Else
			cSelect := cIsNull + "(MAX(CAST(RTRIM(" + cTable + "_SEQREG) AS INTEGER)), 0) SEQ "
		EndIf
	EndIf

	cFrom	:= RetSqlName( cTable )

	cWhere	:= cTable + "_FILIAL = '" + xFilial( cTable ) + "' AND "
	cWhere	+= cTable + "_ID     = '" + cIdWhere + "' AND "
	cWhere	+= "D_E_L_E_T_ = ' ' "

	cSelect	:= "%" + cSelect	+ "%"
	cFrom	:= "%" + cFrom		+ "%"
	cWhere	:= "%" + cWhere		+ "%"

	BeginSql Alias cAliasSeq

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	EndSql

	nSeqReg := (cAliasSeq)->SEQ

	IIf (nSeqReg == 0, nSeqReg := 1, nSeqReg++)

	(cAliasSeq)->(DbCloseArea())

Return nSeqReg

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExcPrd
Esta função tem como objetivo de excluir os produtos dentro do taf

@Author Graziella Souza
@since 09/02/2018
@version 1.0

@param cTable	 - Tabela que possui o campo sequencia.
        cIdWhere - Identificador do registro que busca-se sequenciar.

/*/
//-------------------------------------------------------------------
Function TAFExcPrd( cLayInteg , nOpc , cFil, cCodigo )

	Local cAliasPro	:= ""
	Local cSelect	:= ""
	Local cFrom		:= ""
	Local cWhere	:= ""
	Local cQuery	:= ""

	Default cLayInteg := ""

	If cLayInteg $ "T007"

		cAliasPro 	:= GetNextAlias()
		cSelect	:= " C30.C30_CODITE, C30.C30_CHVNF "
		cFrom   	:= RetSqlName("C30") + " C30 "
		cFrom   	+= " INNER JOIN "  + RetSqlName("C1L") + " C1L ON C1L.C1L_FILIAL = '" + xFilial("C1L") + "' "
		cFrom   	+= " AND C1L.C1L_ID = C30.C30_CODITE AND C1L.C1L_CODIGO = '" + cCodigo + "' "
		cWhere    	:= " C30.D_E_L_E_T_ <> '*' "

		cSelect	:= "%" + cSelect	+ "%"
		cFrom		:= "%" + cFrom	+ "%"
		cWhere		:= "%" + cWhere	+ "%"

		BeginSql Alias cAliasPro

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
		EndSql

		If ( cAliasPro )->( !Eof() )

			lRet := .F.
			MsgStop("Atenção! - Não foi possível excluir o "+cLayInteg+" no TAF - TOTVS Automação Fiscal, pois existem movimentos para o produto.")
		
		Else
			
			cQuery := "UPDATE "  + RetSqlName("C1L") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE C1L_FILIAL = '" + xFilial("C1L") + "' AND C1L_CODIGO = '" + cCodigo + "' AND D_E_L_E_T_ <> '*' "
			
			If TCSQLExec(cQuery) <0

				MsgStop( "TCSQLError() " + TCSQLError(), '' )
				lRet := .F.
				Return( Nil )

			Else

				TcSqlExec( "COMMIT" )
				lRet := .T.

			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TafLockInteg

Realiza o bloqueio do processamento do JOB2 quando o mesmo estiver
em execução na filial.

@param cUID	  	 - Identificador de secao das variaveis.
@param lLock 	 - Quando True pede o bloqueio da filial, False libera
a filial para uma proxima execução.
@param cUserLock - (referencia) Informa o usuário que está executando
o processamento quando é realizado um pedido de bloqueio e a rotina
está em execução.
@param cCodFils  - String com as filias do ERP a serem consideradas
no processo de recuperação de registros que ficaram sem processamento
porem estão com status 2 ou 3. Informar sempre que lFixST2 for igual
a True.
@param lFixST2 - Indica se deve ser realizado a verificação de integridade
da tabela TAFST2.
@param cMsgErro - (referencia) Mensagem de Erro

@return lRet - Informa se o Lock foi realizado ou retirado com sucesso.

@author Evandro dos Santos O. Teixeira
@since 14/10/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafLockInteg(cUID,lLock,cUserLock,cCodFils,lFixST2,cMsgErro,aInfoParam)

	Local cChvFilial      := ""
	Local lRet            := .T.
	Local nIdThread       := ThreadID()
	Local aLockThead      := {}
	Local nIsThreadInProc := 0
	Local nLock           := 0 //0-nenhum processo em execucao na filial -- 1-existe processo executando na filial.
	Local aMonitor        := {}
	Local nX              := 0
	Local lVersaoHomolg   := Val(GetVersao(.F.)) > 11 .And. AllTrim(GetRpoRelease()) >= "12.1.016"

	Default cCodFils      := ""
	Default lFixST2       := .T.
	Default aInfoParam    := {}

	cChvFilial :=  cUid + cEmpAnt + cFilAnt
	aMonitor := GetUserInfoArray()

	//É necessario verificar se o processo de integração multiThread não está sendo executada
	//Caso verdadeiro não pode ser permitido fazer a verificação da TAFST2 por esta função
	//Já que existe um processo de recuperação no TAF_CFGJOB
	If FindFunction("TAFMP2JobName") .And. lVersaoHomolg

		//Eh necessario verificar se nao ha um processamento em multiThread antes 
		//de realizar a verificação dos registros na TAFST2, no 
		cJobName := TAFMP2JobName()

		For nX := 1 To Len(aMonitor)

			If cJobName $ AllTrim(aMonitor[nX][1])

				nX := Len(aMonitor)+1

				lFixST2 := !CheckMTExec(cJobName,aMonitor)

				If !lFixST2
					TafConOut("Não sera realizado o acerto da tabela TAFST2 atraves desta rotina enquanto o job TAF_CFGJOB estiver em execução.")
				EndIf

			EndIf

		Next nX

	ElseIf lVersaoHomolg

		TafConOut("Fonte TAFMPROC2.PRW desatualizado, realize a atualização para a execução desta rotina via Schedule.")
		cMsgErro := "Fonte TAFMPROC2.PRW desatualizado, realize a atualização para a execução desta rotina."
		lRet := .F.

	EndIf

	cUserLock := cUserName

	If lRet

		If lLock

			If VarGetXD(cUID,cChvFilial,@nLock)

				If nLock == 0

					lRet := VarSetD(cUID,cChvFilial,1,{nIdThread,cUserName})

					If lFixST2 .And. lRet
						TAFFixSt2(cCodFils,aInfoParam)
					EndIf

				Else

					//Se a variavel retornar Lock para a Filial eh necessario verificar se a Thread que efetuou o 
					//bloqueio não caiu.
					If VarGetAD(cUID,cChvFilial,@aLockThead)

						//Verifica se a Thread que está realizando o bloqueio na filial ainda está em execução
						nIsThreadInProc := aScan(aMonitor,{|x|x[3] == aLockThead[1]})

						If nIsThreadInProc == 0

							//Se a Thread que realizou o bloqueio não estiver + no monitor, permito que a thread atual realize o bloqueio
							//e consequentemente execute o processo de integração.
							lRet := VarSetD(cUID,cChvFilial,1,{nIdThread,cUserName})
							If lFixST2 .And. lRet
								TAFFixSt2(cCodFils,aInfoParam)
							EndIf

						ElseIf !IsInCallStack("TAFA500")

							//Se realmente houver uma thread executando o processo retorno o usuário que está efetuando o bloqueio.
							cUserLock := aLockThead[2]
							lRet := .F.

							If Empty(cUserLock)
								cUserLock := "Schedule"
							EndIf

							cMsgErro := "Já existe um processo em execução nesta filial pelo usuário " + cUserLock + "." + CRLF
							cMsgErro += "Para o processo da integração 2 (TAFST2 x TAF) é necessário que não haja nenhum processamento da rotina sendo executado por outro usuário."
						
						EndIf

					EndIf

				EndIf

			Else

				//Se o metodo Get não encontrar um lock para a filial, realizo o bloqueio.
				//Na primeira execução da função após o inicio do serviço sempre vai cair nesta condição.
				lRet := VarSetD(cUID,cChvFilial,1,{nIdThread,cUserName})
				
				If lFixST2 .And. lRet
					TAFFixSt2(cCodFils,aInfoParam)
				EndIf

			EndIf

		Else

			//Retira o Lock do processamento para a filial em questão.
			nLock := 0
			lRet := VarSetD(cUID,cChvFilial,nLock,{})

		EndIf

	EndIf
	
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} TAFFixSt2

Verifica se há registros na tabela TAFST2 com status 2 ou 3 sem 
processamento e log na tabela TAFXERP.

Obs: Esta função deve ser utilzada em conjunto com a função TafLockInteg
pois deve-se garantir que não esteja ocorrendo processamento no momento
da recuperação dos registros com status 2 na tabela TAFST2.

@param cCodFils  - String com as filias do ERP a serem consideradas
no processo de recuperação de registros que ficaram sem processamento
porem estão com status 2 ou 3.

@param aInfoParam - Array com informações vindas de interface de ajuste
manual de registros {cDtDe,cDtAte,cTAFKEY,cTicket,cEvento}

@return cErroSQL - Eventuais erros no Update.

@author Evandro dos Santos O. Teixeira
@since 14/10/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFFixSt2(cCodFils,aInfoParam)

	Local cSql         := ""
	Local cErroSQL     := ""
	Local cAliasQry    := GetNextAlias()
	Local dDatProcess  := (dDatabase) - 10
	Local cDataSeek    := DtoS( GetNewPar("MV_DPROST2",dDatProcess) )
	
	//Variaveis de origem de inteface de ajuste manual
	Local cDtDe        := ""
	Local cDtAte       := ""
	Local cTafKey      := ""
	Local cTicket      := ""
	Local cEvento      := ""
	Local cSqlFilt     := ""

	Default cCodFils   := ""
	Default aInfoParam := {}

	//Caso a filial esteja em branco não executa a Query.
	If !Empty(cCodFils)
		
		If Len(aInfoParam)==0

			If Empty(cDataSeek)
				cDataSeek := DtoS(dDatProcess)
			EndIf

		Else

			cDataSeek:= ""
			cDtDe	:= aInfoParam[1]
			cDtAte	:= aInfoParam[2]
			cTafKey	:= aInfoParam[3]
			cTicket	:= aInfoParam[4]
			cEvento	:= aInfoParam[5]

		EndIf

		cSql := " SELECT COUNT(*) CONTAGEM "
		cSql += " FROM   TAFST2 ST2 "
		cSql += " WHERE  ST2.TAFFIL IN (" + cCodFils + ") "
		cSql += " AND    ST2.TAFSTATUS in ('2','3') "
		
		If Len(aInfoParam) >0
			
			If !Empty(cDtDe) .And. !Empty(cDtAte)
				cSqlFilt += " AND ST2.TAFDATA BETWEEN '"	+	cDtDe	+"' AND '"+	cDtAte	+"'"
			EndIf
			
			If !Empty(cTafKey)
				cSqlFilt += " AND ST2.TAFKEY = '"	+	cTafKey	+"'"
			EndIf
			
			If !Empty(cTicket)
				cSqlFilt += " AND ST2.TAFTICKET = '"+LOWER(cTicket)+"'"
			EndIf
		
			If !Empty(cEvento)
				cSqlFilt += " AND ( ST2.TAFTPREG = '"+cEvento+"' OR  ST2.TAFTPREG = '"+StrTran(cEvento,"S","S-")+"'  )"
			EndIf

		EndIf

		If Empty(cSqlFilt) .And. !Empty(cDataSeek)
			cSql += " AND ST2.TAFDATA >= '" + cDataSeek + "'" 
		EndIf

		cSql += cSqlFilt
		cSql += " AND ST2.D_E_L_E_T_ = '' "

		cSql := ChangeQuery(cSql)
		TCQuery cSql New Alias (cAliasQry)

		(cAliasQry)->(DbGoTop())

		If (cAliasQry)->CONTAGEM > 0

			cSql := " UPDATE TAFST2 "
			cSql += " SET TAFSTATUS = '3'"
			cSql += " WHERE R_E_C_N_O_ IN "
			cSql += " ( "
			cSql += " SELECT ST2.R_E_C_N_O_ "
			cSql += " FROM TAFXERP XERP "

			cSql += " INNER JOIN "
			cSql += " ( "
			cSql += " SELECT TAFKEY, TAFTICKET, R_E_C_N_O_ FROM TAFST2 
			cSql += " WHERE TAFFIL IN (" + cCodFils + ")"
			cSql += " AND TAFSTATUS in ('2','1') "

			
			If Empty(cSqlFilt) .And. !Empty(cDataSeek)
				cSql += " AND TAFDATA >= '" + cDataSeek + "'" 
			EndIf

			cSql += StrTran(cSqlFilt,"ST2.","")
			cSql += " AND D_E_L_E_T_ = ' ' "
			cSql += " ) ST2 "

			cSql += " ON  XERP.TAFKEY     = ST2.TAFKEY "
			cSql += " AND XERP.TAFTICKET  = ST2.TAFTICKET "
			cSql += " AND XERP.D_E_L_E_T_ = ' ' "
			cSql += " ) "
		
			If TCSQLExec(cSql) < 0

				cErroSQL := TCSQLError() 
				TafConOut(cErroSQL)

			Else

				//Se após a execução da query acima ainda existirem registros com status 2
				//altero os mesmo para 1, pois os registros acima já estavam na TAFXERP
				cSql := " UPDATE TAFST2 "
				cSql += " SET TAFSTATUS = '1', TAFIDTHRD = ' ' "
				cSql += " WHERE TAFSTATUS IN ('2','3') AND D_E_L_E_T_ = ' ' " 

				If Empty(cSqlFilt) .And. !Empty(cDataSeek)
					cSql += " AND TAFDATA >= '" + cDataSeek + "'" 
				EndIf

				cSql += StrTran(cSqlFilt,"ST2.","")
				
				cSql += " AND R_E_C_N_O_ IN "
				cSql += " ( "
				cSql += " 	SELECT ST2.R_E_C_N_O_ "
				cSql += " 	FROM TAFST2 ST2 "
				cSql += " 	WHERE TAFFIL IN (" + cCodFils + ") "
				cSql +=  	cSqlFilt				
				cSql += " 	AND NOT EXISTS "
				cSql += "   ("
        		cSql += "    	SELECT TAFKEY,TAFTICKET "
        		cSql += "    	FROM TAFXERP XERP"
        		cSql += "    	WHERE ST2.TAFKEY = XERP.TAFKEY"
        		cSql += "    	AND ST2.TAFTICKET = XERP.TAFTICKET"
        		cSql += "    	AND XERP.D_E_L_E_T_ = ' '   )"
				cSql += ")"

				If TCSQLExec(cSql) < 0
					cErroSQL := TCSQLError() 
					TafConOut(cErroSQL)
				EndIf

			EndIf

		EndIf
		(cAliasQry)->(DbCloseArea())

	EndIf

Return (cErroSQL) 

//-------------------------------------------------------------------
/*{Protheus.doc} checkMTExec

Verifica se há processamento na rotina de integração MultiThread

@param cJobName  - Nome do Semaforo utilizado pelo MT
@param aMonitor  - Retorno da função GetUserInfoArray()

@return lThreadsInUse - Informa se ainda existem Threads em uso

@author Evandro dos Santos O. Teixeira
@since 14/10/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function checkMTExec(cJobName,aMonitor)

	Local nQtdThread    := 0
	Local nTryWait 	    := 0
	Local nTimeOut 	    := 100
	Local lTimeOut	    := .F.
	Local lThreadsInUse := .T.

	cJobName := cJobName + "_" + cEmpAnt
	aEval( aMonitor,{|x| If(x[1] == cJobName, nQtdThread++,)})

	//Verifico se ainda existem threads em processamento
	While lThreadsInUse .And. !lTimeOut

		nThreadsInUse := aScan(aMonitor,{|x|x[10] > 0 .And. x[1] == cJobName})
		lThreadsInUse := nThreadsInUse > 0
		nTryWait++
		Sleep(200)
		lTimeOut := nTryWait == nTimeOut
		TafConOut("Verificando Threads do semáforo " + cJobName + " Tentativa: " + cValtoChar(nTryWait) + "/" + cValToChar(nTimeOut))

	EndDo

Return lThreadsInUse 


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLoadModel
Retorna o Modelo a ser utilizado. Essa função faz um cache no modelo
para que o mesmo não seja criado a cada execução.

@param cModel - Identificador do Modelo

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFLoadModel( cModel as Character, nOperation as Numeric )

	Local lCacheVazio as Logical
	Local nPosModel   as Numeric
	Local oModel      as Object

	Default nOperation := 3

	lCacheVazio := .F.
	nPosModel   := 0
	oModel      := Nil

	If __aModelCache == Nil
		lCacheVazio := .T.
		__aModelCache := {}
	EndIf

	If lCacheVazio

		oModel := FWLoadModel(cModel)
		aAdd(__aModelCache,{cModel,oModel})

		oModel:SetOperation(nOperation)
		oModel:Activate()

	Else

		nPosModel := aScan(__aModelCache,{|m|m[1] == cModel})

		If nPosModel > 0

			If __aModelCache[nPosModel][2] == Nil

				__aModelCache[nPosModel][2] := FWLoadModel(cModel)
			Else

				If __aModelCache[nPosModel][2]:IsActive()
					__aModelCache[nPosModel][2]:DeActivate()
				EndIf
			EndIf

			__aModelCache[nPosModel][2]:SetOperation(nOperation)
			__aModelCache[nPosModel][2]:Activate()

			oModel := __aModelCache[nPosModel][2]

		Else

			oModel := FWLoadModel(cModel)
			aAdd(__aModelCache,{cModel,oModel})

			oModel:SetOperation(nOperation)
			oModel:Activate()

		EndIf

	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} VerDuplC1E
Valida se existem registros duplicados na C1E
@author  Victor A. Barbosa
@since   08/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VerDuplC1E()

	Local cC1EAlias := "verDupl" //GetNextAlias()
	Local lRet		:= .F.

	If Select(cC1EAlias) > 0
		(cC1EAlias)->( dbCloseArea() )
	EndIf

	BeginSQL Alias cC1EAlias
	SELECT COUNT(C1E_CODFIL)
	FROM %table:C1E% C1E
	WHERE C1E_ATIVO = '1'
	AND   C1E.%notdel%
    AND   C1E_CODFIL <> '<NPI>'
	GROUP BY C1E_CODFIL
	HAVING COUNT(C1E_CODFIL) > 1
	EndSQL

	(cC1EAlias)->( dbGoTop() )

	If (cC1EAlias)->( !Eof() )
		lRet := .T.
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIdFunc
Retorna o ID, Evento e Versão do trabalhador conforme CPF e Matrícula

@param cCPF - CPF do trabalhador
@param cMat - Matrícula do trabalhador

@author Karyna Martins / Melkz Siqueira
@since 07/04/2021
@version 1.0		

@return aRet - ID, Evento e Versão do trabalhador
/*/
//-------------------------------------------------------------------
Function TAFIdFunc( cCPF as Character, cMat as Character, cInconMsg as Character, nSeqErrGrv as Numeric, l2190 as Logical )

	Local aPosic  as Array
	Local aRet    as Array
	Local cEvento as Character
	Local cFilTaf as Character
	Local cFunc   as Character
	Local cID     as Character
	Local cRet    as Character
	Local cVersao as Character
	Local lIsNG   as Logical
	Local nI      as Numeric
	Local nID     as Numeric
	Local nTamFil as Numeric
	Local nVersao as Numeric

	Default cCPF 		:= ""
	Default cMat 		:= ""
	Default cInconMsg 	:= ""
	Default nSeqErrGrv 	:= 0
	Default l2190		:= .F.

	aPosic  := {}
	aRet    := {}
	cEvento := ""
	cFilTaf := ""
	cFunc   := ""
	cID     := ""
	cRet    := ""
	cVersao := ""
	lIsNG   := .F.
	nI      := 0
	nID     := 0
	nTamFil := TamSx3("C9V_FILIAL")[1]
	nVersao := 0

	//Define se a integracao tem como origem o modulo MDT, nao considerei o GPE pq nao teve demanda deste modulo.
	//Essa funcao ja faz o cache
	lIsNG := SuperGetMv("MV_NG2ESOC",.F.,0) == "1" 

	If !l2190
	
		aAdd(aPosic, {"C9V", 10, "C9V_CPF", "C9V_MATRIC", "S2200", "1", "C9V_ID", "C9V_VERSAO" })

		If lLaySimplif
			aAdd(aPosic, {"C9V", 20, "C9V_CPF", "C9V_MATTSV", "S2300", "1", "C9V_ID", "C9V_VERSAO" })
		Else 
			aAdd(aPosic, {"C9V", 10, "C9V_CPF", "C9V_MATRIC", "S2300", "1", "C9V_ID", "C9V_VERSAO" })
		EndIf

		aAdd(aPosic, {"T3A", 5 , "T3A_CPF", "T3A_MATRIC", ""	 , "1", "T3A_ID", "T3A_VERSAO" }) //2190

	Else

		TafConOut("Validando retificação de um ID oriundo do S-2190")
		aAdd(aPosic, {"T3A", 5 , "T3A_CPF", "T3A_MATRIC", ""	 , "1", "T3A_ID", "T3A_VERSAO" }) //2190

	EndIf

	For nI := 1 To Len(aPosic)

		If Empty(cFunc)

			If lIsNG
				cFilTaf := FTafGetFil( cEmpAnt + Padr( xFilial(aPosic[nI][1]), nTamFil ),,aPosic[nI][1] )
			Else
				cFilTaf := xFilial(aPosic[nI][1])
			EndIf

			cRet	:= aPosic[nI][7] + "+" + aPosic[nI][8]

			cFunc 	:= Posicione(aPosic[nI][1], aPosic[nI][2], cFilTaf	+ ; 
						PadR(cCPF, GetSx3Cache(aPosic[nI][3], "X3_TAMANHO")) 			+ ;
						PadR(cMat, GetSx3Cache(aPosic[nI][4], "X3_TAMANHO")) 			+ ;
						aPosic[nI][5] + aPosic[nI][6], cRet)
			
			If !Empty(cFunc)

				nID		:= GetSx3Cache(aPosic[nI][7], "X3_TAMANHO")
				nVersao	:= GetSx3Cache(aPosic[nI][8], "X3_TAMANHO")

				cID		:= SubStr(cFunc, 1, nID)
				cEvento := Iif(Empty(aPosic[nI][5]), "S2190", aPosic[nI][5])
				cVersao	:= SubStr(cFunc, nID + 1, nVersao)
				
			EndIf

		Else 

			//A logica da rotina visa fazer a verificacao de existencia de uma determinada chave com base na ordem
			//dos itens incluidos no array, 1x que a chave foi encontrada o sistema deve abandonar o laco		
			Exit 

		EndIf

	Next

	aAdd(aRet, cID)
	aAdd(aRet, cEvento)
	aAdd(aRet, cVersao)

	If Empty(cID)

		//Gera mensagem de erro
		TAFMsgIncons(@cInconMsg, @nSeqErrGrv,,, .T., "CPF", cCPF, "chvComposta",, "Matricula", cMat)

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelScalar()

Limpa o objeto da query escalar criada para seleção de filiais
@author Karen
@since 07/06/2021
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TafDelScalar() 

	If __oPrepared <> Nil

		__oPrepared:Destroy()
		__oPrepared := Nil
		__cFilC1E := Nil
		
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelTot()

Deleta as tabelas para recriá-las novamente.
@author Alexandre Santos
@since 03/04/2024
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TafDelTot( cTable as Character, cfil as Character, cId as Character, cVersao as Character, aTableEve as array )

	Local cDel    as character
	Local nI      as numeric

	Default aTableEve := {}
	Default cTable    := ""
	Default cFil      := ""
	Default cId       := ""
	Default cVersao   := ""

	cDel := ""
	nI   := 0

	For nI := 1 to Len(aTableEve)

		cDel := " DELETE FROM " + RetSqlName( aTableEve[nI] ) + " "
		cDel += " WHERE " + aTableEve[nI] + "_FILIAL = '" + cfil + "' "
		cDel += "  AND " + aTableEve[nI] + "_ID = '" + cId + "' "
		cDel += "  AND " + aTableEve[nI] + "_VERSAO = '" + cVersao + "' "

		TCSQLExec( cDel )

		Tafconout("---deleção da tabela " + aTableEve[nI] + "----")

	Next nI

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} NilCache
Limpa variaveis static que impactam na execução do robo.

@author		Alexandre de liima santos 
@since		11/10/2024
@version	1.0
@Return		
@Obs: Função é exclusiva para limpeza de variaveis static do fonte que impactam na execução do robo.
/*/
//-------------------------------------------------------------------
Function NilCache()
	__aModelCache := Nil
Return
