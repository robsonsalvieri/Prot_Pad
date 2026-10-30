#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA611.CH"

Static lSimpl0102  := TAFLayESoc("S_01_02_00", .T., .T.)
Static lSimpl0103  := TAFLayESoc("S_01_03_00", .T., .T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA611
@type			function
@description	Informacoes de Tributos Decorrentes de Processo Trabalhista
@author			Rodrigo Nicolino
@since			11/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA611()

	Private oBrowse	:=	FWMBrowse():New()

	If TAFAlsInDic( "V7K" )

		oBrowse:SetDescription(STR0001) //"Informações Consolidadas de Tributos Decorrentes de Processo Trabalhista" 
		oBrowse:SetAlias( "V7K" )
		oBrowse:SetMenuDef( "TAFA611" )

		oBrowse:SetFilterDefault( "V7K_ATIVO == '1'" )

		oBrowse:Activate()

	Else

		cMessage := "Ambiente desatualizado com a versão do programa existente no repositório de dados." //"
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += "Execute a atualização do dicionário do Layout 1.1 do eSocial por meio do compatibilizador UPDDISTR." //"
		Aviso( "Dicionário Incompatível", cMessage, { "Encerrar" }, 2 ) //## ##
		
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Funcao generica MVC do menu.
@author			Rodrigo Nicolino
@since			11/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as Array
	Local aRotina as Array

	aFuncao := {}
	aRotina := {}

	aAdd( aFuncao, { "", "TAF611Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V7K', 'S-5501', 'evtTribProcTrab', 'TAF611Xml' , , oBrowse )", "5" } )

	aRotina := xFunMnuTAF( "TAFA611",, aFuncao )

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Funcao generica MVC do modelo.
@author			Rodrigo Nicolino
@since			11/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel   as Object
	Local oStruV7K as Object
	Local oStruV7L as Object
	Local oStruV7O as Object
	Local oStruV7P as Object

    oModel   := MPFormModel():New("TAFA611", , , { |oModel| SaveModel( oModel ) })
	oStruV7K := FWFormStruct( 1, "V7K")
	oStruV7L := FWFormStruct( 1, "V7L")
	oStruV7O := FWFormStruct( 1, "V7O")
	oStruV7P := FWFormStruct( 1, "V7P")

	//Variavel Private utilizada para controle do modelo na operacao de integracao via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV7K:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf

	oModel:AddFields( "MODEL_V7K", /*cOwner*/, oStruV7K )

    //Identificação do período e da base de cálculo dos tributos referentes ao processo trabalhista.
    oModel:AddGrid( "MODEL_V7L", "MODEL_V7K", oStruV7L )
    oModel:GetModel( "MODEL_V7L" ):SetUniqueLine( { "V7L_PERREF" } )
	oModel:GetModel('MODEL_V7L'):SetMaxLine(999)
	oModel:SetRelation( "MODEL_V7L", { { "V7L_FILIAL", "xFilial('V7K')" }, { "V7L_ID", "V7K_ID" }, { "V7L_VERSAO", "V7K_VERSAO" } }, V7L->(IndexKey(1)) )

    oModel:AddGrid( "MODEL_V7O", "MODEL_V7L", oStruV7O )
    oModel:GetModel( "MODEL_V7O" ):SetOptional( .T. )
    oModel:GetModel( "MODEL_V7O" ):SetUniqueLine( { "V7O_TPCR", "V7O_VRCR" } )
	oModel:GetModel('MODEL_V7O'):SetMaxLine(99)
	oModel:SetRelation( "MODEL_V7O", { { "V7O_FILIAL", "xFilial('V7O')" }, { "V7O_ID", "V7K_ID" }, { "V7O_VERSAO", "V7K_VERSAO" }, { "V7O_PERREF", "V7L_PERREF" } }, V7O->(IndexKey(1)) )

    oModel:AddGrid( "MODEL_V7P", "MODEL_V7K", oStruV7P )
    oModel:GetModel( "MODEL_V7P" ):SetOptional( .T. )
    oModel:GetModel( "MODEL_V7P" ):SetUniqueLine( {"V7P_TPCR","V7P_VRCR"} )
	oModel:GetModel('MODEL_V7P'):SetMaxLine(99)
	oModel:SetRelation( "MODEL_V7P", { { "V7P_FILIAL", "xFilial('V7K')" }, { "V7P_ID", "V7K_ID" }, { "V7P_VERSAO", "V7K_VERSAO" } }, V7P->(IndexKey(1)) )

	oModel:GetModel( "MODEL_V7K" ):SetPrimaryKey( {"V7K_NRPROC", "V7K_PERAPU"} )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Funcao generica MVC da view.
@author			Rodrigo Nicolino
@since			11/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local cCmpsV7K  as Character
	Local cCmpsV7L  as Character
	Local cCmpsV7O  as Character
	Local cCmpsV7P  as Character
	Local oModel    as Object
	Local oStruV7K  as Object
	Local oStruV7L  as Object
	Local oStruV7O  as Object
	Local oStruV7P  as Object
	Local oView     as Object

    cCmpsV7K  := "V7K_NRRECI|V7K_NRPROC|V7K_PERAPU|"
	cCmpsV7L  := "V7L_PERREF|"
	cCmpsV7O  := "V7O_TPCR|V7O_TPCRD|V7O_VRCR|"
	cCmpsV7P  := "V7P_TPCR|V7P_TPCRD|V7P_VRCR|"
	oModel    := FWLoadModel( "TAFA611" )
    oStruV7K  := FWFormStruct( 2, "V7K", { |x| AllTrim( x ) + "|" $ cCmpsV7K  } )
 	oStruV7L  := FWFormStruct( 2, "V7L", { |x| AllTrim( x ) + "|" $ cCmpsV7L  } )
	oStruV7O  := FWFormStruct( 2, "V7O", { |x| AllTrim( x ) + "|" $ cCmpsV7O  } )
	oStruV7P  := FWFormStruct( 2, "V7P", { |x| AllTrim( x ) + "|" $ cCmpsV7P  } )
	oView     := FWFormView():New()

	oView:SetModel( oModel )

	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_V7K", oStruV7K, "MODEL_V7K" )
	oView:EnableTitleView( "VIEW_V7K", STR0002 ) //"Identificação do processo"

    oView:AddGrid( "VIEW_V7L", oStruV7L, "MODEL_V7L" )
    oView:EnableTitleView( "VIEW_V7L", STR0003 ) //"Identificação do período e da base de cálculo dos tributos referentes ao processo trabalhista.

    oView:AddGrid( "VIEW_V7O", oStruV7O, "MODEL_V7O" )
    oView:EnableTitleView( "VIEW_V7O", STR0004 ) //"Informações das contribuições sociais referentes ao processo trabalhista"

    oView:AddGrid( "VIEW_V7P", oStruV7P, "MODEL_V7P" )
    oView:EnableTitleView( "VIEW_V7P", STR0005 ) //Informações de IRRF referentes ao processo trabalhista

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "BOX_SUPERIOR", 100 ) 
	oView:CreateFolder( "FOLDER_SUPERIOR", "BOX_SUPERIOR" )

	oView:AddSheet( "FOLDER_SUPERIOR", "ABA_PROCES", STR0006 ) //"Tributos Decorrentes de Processo Trabalhista"

	oView:CreateHorizontalBox( "V7K"              , 020,,, "FOLDER_SUPERIOR", "ABA_PROCES" )
	oView:CreateHorizontalBox( "BOX_INTERMEDIARIO", 080,,, "FOLDER_SUPERIOR", "ABA_PROCES" )

	oView:CreateFolder( "FOLDER_PROCESSO","BOX_INTERMEDIARIO" )
	
    oView:AddSheet( "FOLDER_PROCESSO", "ABA_TRIB", STR0007 ) //"Tributos Por Período"
	oView:AddSheet( "FOLDER_PROCESSO", "ABA_IRRF", STR0008 ) //"Imposto de Renda"

	oView:CreateHorizontalBox( "V7L", 050,,, "FOLDER_PROCESSO", "ABA_TRIB" )
	oView:CreateHorizontalBox( "V7O", 050,,, "FOLDER_PROCESSO", "ABA_TRIB" )
	oView:CreateHorizontalBox( "V7P", 100,,, "FOLDER_PROCESSO", "ABA_IRRF" )
	
	oView:SetOwnerView( "VIEW_V7K", "V7K" )
	oView:SetOwnerView( "VIEW_V7L", "V7L" )
	oView:SetOwnerView( "VIEW_V7O", "V7O" )
	oView:SetOwnerView( "VIEW_V7P", "V7P" )

	xFunRmFStr( @oStruV7K ,"V7K" )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Funcao de gravacao dos dados, executada na confirmacao do modelo.
@author			Rodrigo Nicolino
@since			11/07/2023
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel as Object)

	Local nOperation as Numeric

	nOperation	:=	oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_DELETE

			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

			FwFormCommit( oModel )

		EndIf

	End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF611Grv

Funcao de gravacao para atender o registro S-5501

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Rodrigo Nicolino
@since 11/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF611Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character, cPredeces as Character,;
 					nTafRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID as Character,;
					cEvtOri as Character, lMigrador as Logical, lDepGPE as Logical, cKey as Character, cMatrC9V as Character, lLaySmpTot as Logical,;
					lExclCMJ as Logical, oTransf as Object )

	Local aChave     as Array
	Local aIncons    as Array
	Local aRules     as Array
	Local cCabec     as Character
	Local cCmpsNoUpd as Character
	Local cIdTpValor as Character
	Local cInconMsg  as Character
	Local cPeriodo   as Character
	Local cPerRef    as Character
	Local cString    as Character
	Local cTpValor   as Character
	Local cV7LPath   as Character
	Local cV7OPath   as Character
	Local cV7PPath   as Character
	Local lRet       as Logical
	Local nI         as Numeric
	Local nIndChv    as Numeric
	Local nlA        as Numeric
	Local nSeqErrGrv as Numeric
	Local nV7L       as Numeric
	Local nV7O       as Numeric
	Local nV7P       as Numeric
	Local oModel     as Object
	Local uChkDupl   as Variant

	Private lVldModel as Logical //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados    as Object

	Default cLayout   := ""
	Default nOpc      := 1
	Default cFilEv    := ""
	Default oXML      := Nil

	aChave     := {}
	aIncons    := {}
	aRules     := {}
	cCabec     := "/eSocial/evtTribProcTrab/"
	cCmpsNoUpd := "|V7K_FILIAL|V7K_ID|V7K_VERSAO|V7K_ATIVO|V7K_VERANT|V7K_EVENTO|V7K_STATUS|"
	cIdTpValor := ""
	cInconMsg  := ""
	cPeriodo   := ""
	cPerRef    := ""
	cString    := ""
	cTpValor   := ""
	cV7LPath   := ""
	cV7OPath   := ""
	cV7PPath   := ""
	lRet       := .F.
	lVldModel  := .T.
	nI         := 0
	nIndChv    := 2
	nlA        := 0
	nSeqErrGrv := 0
	nV7L       := 0
	nV7O       := 0
	nV7P       := 0
	oDados     := oXML
	oModel     := Nil

	Aadd( aChave, { "C", "V7K_NRPROC", FTafGetVal( cCabec + "ideProc/nrProcTrab" , "C", .F., @aIncons, .F. ), .T. } )

	cPeriodo  := FTafGetVal(  cCabec + "ideProc/perApur", "C", .F., @aIncons, .F. )

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "V7K_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
	Else
		Aadd( aChave, {"C", "V7K_PERAPU", cPeriodo  , .T.} )
	EndIf

	nIndChv := 2
	
	Begin Transaction

		If FTafVldOpe( 'V7K', nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA611', cCmpsNoUpd )

			aRules := TAF611Rul()

			oModel:LoadValue( "MODEL_V7K", "V7K_FILIAL", V7K->V7K_FILIAL )

			For nI := 1 to Len( aRules )
				oModel:LoadValue( "MODEL_V7K", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
			Next nI

			TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7K', 'V7K_LOGOPE' , '1', '' )

			nV7L := 1
			cV7LPath := cCabec + "ideProc/infoTributos[" + AllTrim(Str(nV7L)) + "]"

			While oDados:XPathHasNode(cV7LPath)

				oModel:GetModel( "MODEL_V7L" ):lValid := .T.

				If nV7L > 1
					oModel:GetModel( "MODEL_V7L" ):AddLine()
				EndIf

				cPerRef := FTafGetVal( cV7LPath + "/perRef" , "C", .F.,, .T. )

				If At("-", cPerRef) > 0
					oModel:LoadValue( "MODEL_V7L", "V7L_PERREF", StrTran(cPerRef, "-", "" ) )
				Else
					oModel:LoadValue( "MODEL_V7L", "V7L_PERREF", cPerRef, "-", "" ) 
				EndIf

				nV7O := 1
				cV7OPath := cV7LPath + "/infoCRContrib[" + AllTrim(Str(nV7O)) + "]"

				While oDados:XPathHasNode(cV7OPath)

					oModel:GetModel( "MODEL_V7O" ):lValid := .T.

					If nV7O > 1
						oModel:GetModel( "MODEL_V7O" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V7O", "V7O_TPCR", FGetIdInt( "tpCR", "",  cV7OPath + "/tpCR",,,, @cInconMsg, @nSeqErrGrv,,,,,,,,, "S-5501" ) )
					oModel:LoadValue( "MODEL_V7O", "V7O_VRCR", FTafGetVal( cV7OPath + "/vrCR" , "N", .F., @aIncons, .T. )                                 )

					nV7O++
					cV7OPath := cV7LPath + "/infoCRContrib[" + AllTrim(Str(nV7O)) + "]"
			
				EndDo

				nV7L++
				cV7LPath := cCabec + "ideProc/infoTributos[" + AllTrim(Str(nV7L)) + "]"

			EndDo

			nV7P++
			cV7PPath := cCabec + "ideProc/infoCRIRRF[" + AllTrim(Str(nV7P)) + "]"

			While oDados:XPathHasNode(cV7PPath)

				oModel:GetModel( "MODEL_V7P" ):lValid := .T.

				If nV7P > 1
					oModel:GetModel( "MODEL_V7P" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_V7P", "V7P_TPCR", FGetIdInt( "tpCR", "",  cV7PPath + "/tpCR",,,, @cInconMsg, @nSeqErrGrv,,,,,,,,, "S-5501" ) )
				oModel:LoadValue( "MODEL_V7P", "V7P_VRCR", FTafGetVal( cV7PPath + "/vrCR" , "N", .F., @aIncons, .T. )                                 )

				nV7P++
				cV7PPath := cCabec + "ideProc/infoCRIRRF[" + AllTrim(Str(nV7P)) + "]"
		
			EndDo

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetiva a operacao desejada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInconMsg) .And. Empty(aIncons)

			uChkDupl := TafFormCommit( oModel, .T. )

			If uChkDupl[1]

				Aadd(aIncons, "ERRO19" + "|" + uChkDupl[2] + "|" + uChkDupl[3])
				cString += "- Totalizador aIncons ERRO19 - " + CRLF
				TAFConOut( "- totalizador aIncons ERRO19 -" )

				For nlA := 1 To Len( aIncons )

					If len( aIncons[nlA] ) >= 1
						cString += "- Totalizador aIncons  - " + aIncons[nlA] + CRLF
						TAFConOut( "- totalizador aIncons - " + aIncons[nlA] + " - " )
					EndIf

				Next nlA

			Else

				lRet := .T.

			EndIf

		Else

			Aadd(aIncons, cInconMsg)
			TAFConOut()
			DisarmTransaction()

		EndIf

		If !Empty(cString)

			MakeDir( GetSrvProfString( "rootpath", "" ) + "\profile\" )
			MemoWrite( GetSrvProfString( "rootpath", "" ) + "\profile\" + "logtot-" + StrTran( DtoC( Date() ), "/", "" ) + "-" + StrTran( Time(), ":", "" ) + ".txt", cString )

		EndIf

	End Transaction

	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF611Rul

Regras para gravacao dos Imposto de Renda Retido na Fonte S-5002 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Rodrigo Nicolino
@since 11/07/2023
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF611Rul()

	Local aRull    as Arrays
	Local cCabec   as Character
	Local cPeriodo as Character

	aRull    := {}
	cCabec   := "/eSocial/evtTribProcTrab/"
	cPeriodo := FTafGetVal( cCabec + "ideProc/perApur", "C", .F.,, .F. )

	aAdd( aRull, {"V7K_NRRECI", FTafGetVal(cCabec + "ideEvento/nrRecArqBase", "C", .F.,, .T. ), "C", .T.} )

	If At("-", cPeriodo) > 0
		aAdd( aRull, {"V7K_PERAPU", StrTran(cPeriodo, "-", "" ), "C", .T.} )
	Else
		aAdd( aRull, {"V7K_PERAPU", cPeriodo					, "C", .T.} )
	EndIf

	aAdd( aRull, {"V7K_NRPROC",  FTafGetVal(cCabec + "ideProc/nrProcTrab", "C", .F.,, .T. ), "C", .T. } )

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF611Xml

Funcao de gravacao para atender o registro S-5501

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Rodrigo Nicolino
@since 11/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF611Xml( cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical )

	Local aMensal    as Arary
	Local cCRContrib as Character
	Local cCRIRRF    as Character
	Local cIdeProc   as Character
	Local cInfoMor   as Character
	Local cInstPen   as Character
	Local cLayout    as Character
	Local cReg       as Character
	Local cTributos  as Character
	Local cXml       as Character
	Local lXmlVLd    as Logical

	Default cAlias  := "V7K"
	Default lJob	:=.F.

	aMensal    := {}
	cCRContrib := ""
	cCRIRRF    := ""
	cIdeProc   := ""
	cInfoMor   := ""
	cInstPen   := ""
	cLayout    := "5501"
	cReg       := "TribProcTrab"
	cTributos  := ""
	cXml       := ""
	lXmlVLd    := TafXmlVLD( 'TAF611XML' )

	DBSelectArea( "V7K" )
	V7K->( DBSetOrder( 2 ) )

	If lXmlVLd

		AADD( aMensal, V7K->V7K_NRRECI )
		AADD( aMensal, substr(V7K->V7K_PERAPU, 1, 4) + '-' + substr(V7K->V7K_PERAPU, 5, 2) )

		V7L->(DbSetOrder(1))
		V7L->(MsSeek(xFilial("V7L") + V7K->V7K_ID + V7K->V7K_VERSAO ))

		While !EoF() .And. V7L->V7L_ID + V7L->V7L_VERSAO == V7K->V7K_ID + V7K->V7K_VERSAO

			V7O->(DbSetOrder(1))
			V7O->(MsSeek(xFilial("V7O") + V7L->V7L_ID + V7L->V7L_VERSAO + V7L->V7L_PERREF))

			While !EoF() .And. V7O->V7O_ID + V7O->V7O_VERSAO + V7O->V7O_PERREF == V7L->V7L_ID + V7L->V7L_VERSAO + V7L->V7L_PERREF

				xTafTagGroup( "infoCRContrib";
							, {{"tpCR"	, POSICIONE("V9T", 1, xFilial("V9T") + V7O->V7O_TPCR, "V9T_CODIGO"),,.F.};
							,  {"vrCR" 	, V7O->V7O_VRCR	,,.F.}};
							, @cCRContrib;
							, ;
							, .F.;
							, .T.)

				V7O->(DBSkip())

			EndDo

			xTafTagGroup( "infoTributos";
						, {{"perRef", substr(V7L->V7L_PERREF, 1, 4) + '-' + substr(V7L->V7L_PERREF, 5, 2),, .F.}};
						, @cTributos;
						, {{ "infoCRContrib", cCRContrib, 0 }};
						, Iif( lSimpl0102 .Or. lSimpl0103, .F., .T. );
						, .T.)

			V7L->(DBSkip())

		EndDo

		V7P->(DbSetOrder(1))
		V7P->(MsSeek(xFilial("V7P") + V7K->V7K_ID + V7K->V7K_VERSAO ))

		While !EoF() .And. V7P->V7P_ID + V7P->V7P_VERSAO == V7K->V7K_ID + V7K->V7K_VERSAO

			xTafTagGroup( "infoCRIRRF";
						, {{"tpCR"	, POSICIONE("V9T", 1, xFilial("V9T") + V7P->V7P_TPCR, "V9T_CODIGO"),,.F.};
						,  {"vrCR"   , V7P->V7P_VRCR	,,.F.}};
						, @cCRIRRF;
						, ;
						, .F.;
						, .T.)

			V7P->(DBSkip())

		EndDo

		xTafTagGroup( "ideProc";
					, {{"nrProcTrab", V7K->V7K_NRPROC	                                                 ,, .F.};
					,  {"perApur"   , substr(V7K->V7K_PERAPU, 1, 4) + '-' + substr(V7K->V7K_PERAPU, 5, 2),, .F.}};
					, @cIdeProc;
					, {{"infoTributos", cTributos, 0 };
					,  {"infoCRIRRF"  , cCRIRRF  , 0 }};
					, .T.;
					, .T.)

		cXml := cIdeProc

		//Estrutura do cabeçalho
		cXml := xTafCabXml( cXml, "V7K", cLayout, cReg, aMensal )

	EndIf

	//Executa a gravação do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return cXml
