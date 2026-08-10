#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA528.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA528
@type			function
@description	Exame Toxicológico do Motorista Profissional - S-2221.
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA528()
	
	Local cLayout as character

	Private cNomEve	:= "S2221"
	Private oBrw	:= FWMBrowse():New()

	If TafColumnPos("V3B_NMMED")
	
		cLayout  := SuperGetMv('MV_TAFVLES', .F.)

		If  TafAtualizado()
			TafNewBrowse( "S-2221",,,, STR0001, , 2, 2 )
		EndIf
	
		oBrw:SetCacheView( .F. )

	Else 
		cMessage := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += STR0012 //"Para a utilização deste evento é necessário a atualização do dicionário relativo a NT 04/2024 do e-Social por meio do compatibilizador UPDDISTR"
		Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
	EndIf 

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("C91_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES");
	 .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF528View('V3B',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF528Inc('V3B',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('V3B', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA528"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF528Xml" 						, "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'V3B' )" 			, "10"} )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'V3B', 'TAFA528' )" 	, "3" } ) //Chamo a Browse do Histórico
		Aadd( aFuncao, { "" , "StaticCall(TAFA528,PreXmlLote)" 	, "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA528' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA528", "V3B", .F. ) // Menu dos extemporâneos
		Else
			aRotina	:=	xFunMnuTAF( "TAFA528" , , aFuncao)
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV3B	as object
	Local oModel	as object

	oStruV3B	:=	FWFormStruct( 1, "V3B" )
	oModel	:=	MpFormModel():New("TAFA528",,,{|oModel| SaveModel(oModel)})

	//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV3B:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf

	oStruV3B:SetProperty( "V3B_FUNC"  , MODEL_FIELD_NOUPD   , .T. )

	oModel:AddFields('MODEL_V3B', /*cOwner*/, oStruV3B)
	oModel:GetModel('MODEL_V3B'):SetPrimaryKey({'V3B_FILIAL', 'V3B_FUNC', 'V3B_DTEXAM'})

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	as object
	Local oStruV3Ba	as object
	Local oStruV3Bb	as object
	Local oStruV3Bc	as object
	Local oStruV3Bd	as object
	Local oStruV3Be	as object
	Local oView		as object
	Local cCmpFil	as character

	oModel		:=	FWLoadModel( "TAFA528" )
	oStruV3Ba	:=	Nil
	oStruV3Bb	:=	Nil
	oStruV3Bc	:=	Nil
	oStruV3Bd	:=  Nil
	oStruV3Be	:=  Nil
	oView		:= FWFormView():New()
	cCmpFil		:=	""

	oView:SetModel( oModel ) 

	//Principal
	cCmpFil := "V3B_ID|"
	oStruV3Ba := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V3B_FUNC|V3B_DFUNC|V3B_CPF|V3B_MATRIC|"
	oStruV3Bb := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	
    //Campos do Grupo Toxicologico
    cCmpFil := "V3B_DTEXAM|V3B_CNPJLA|V3B_CODSEX|"
    If TafColumnPos("V3B_NMMED")
        cCmpFil += "V3B_NMMED|V3B_NRCRM|V3B_UFCRM|V3B_DESCUF|"
    EndIf 
    oStruV3Bc := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campo do Numero do Recibo"
	cCmpFil := "V3B_PROTUL|"
	oStruV3Bd := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	TafAjustRecibo(oStruV3Bd,"V3B")

	cCmpFil := "V3B_DINSIS|V3B_DTRANS|V3B_HTRANS|V3B_DTRECP|V3B_HRRECP|"
	oStruV3Be := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	
	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/

	oView:AddField( "VIEW_V3Ba", oStruV3Ba, "MODEL_V3B" )

	oView:AddField( "VIEW_V3Bb", oStruV3Bb, "MODEL_V3B" )
	oView:EnableTitleView( "VIEW_V3Bb", STR0007 ) //"Vinculo"

	oView:AddField( "VIEW_V3Bc", oStruV3Bc, "MODEL_V3B" )
	oView:EnableTitleView( "VIEW_V3Bc", STR0008 ) //"Toxicologico"

	oView:AddField( "VIEW_V3Bd", oStruV3Bd, "MODEL_V3B" )
	oView:EnableTitleView( 'VIEW_V3Bd',  TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	
	oView:AddField( "VIEW_V3Be", oStruV3Be, "MODEL_V3B" )
	oView:EnableTitleView( 'VIEW_V3Be',  TafNmFolder("recibo",2) )
	
	/*--------------------------------------------------------------------------------------------
								Ordem na Tela e Insere uma linha
	---------------------------------------------------------------------------------------------*/
	oStruV3Bb:SetProperty( "V3B_FUNC" 	, MVC_VIEW_ORDEM	, "01"	)
	oStruV3Bb:SetProperty( "V3B_DFUNC"	, MVC_VIEW_ORDEM	, "02"	)
	oStruV3Bb:SetProperty( "V3B_CPF" 	, MVC_VIEW_ORDEM	, "03"	)
	oStruV3Bb:SetProperty( "V3B_MATRIC" , MVC_VIEW_ORDEM	, "04"	)

	oStruV3Bc:SetProperty( "V3B_DTEXAM" 	, MVC_VIEW_ORDEM	, "01"	)
	oStruV3Bc:SetProperty( "V3B_CNPJLA" 	, MVC_VIEW_ORDEM	, "02"	)
	oStruV3Bc:SetProperty( "V3B_CODSEX" 	, MVC_VIEW_ORDEM	, "03"	)

    If TafColumnPos("V3B_NMMED")
        oStruV3Bc:SetProperty( "V3B_NMMED" 	    , MVC_VIEW_ORDEM	, "04"	)
        oStruV3Bc:SetProperty( "V3B_NRCRM" 	    , MVC_VIEW_ORDEM	, "05"	)
        oStruV3Bc:SetProperty( "V3B_UFCRM"      , MVC_VIEW_ORDEM	, "06"	)
        oStruV3Bc:SetProperty( "V3B_DESCUF"     , MVC_VIEW_ORDEM	, "07"	)
	    oStruV3Bc:SetProperty( "V3B_NRCRM" 	    , MVC_VIEW_INSERTLINE, .T.)
    EndIf 
    
	oStruV3Bc:SetProperty( "V3B_CODSEX" 	, MVC_VIEW_INSERTLINE, .T.)
   
	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )

	oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Exame Toxicológico do Motorista Profissional"
	oView:CreateHorizontalBox( "V3Ba", 15,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bb", 35,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bc", 50,,, "FOLDER_PRINCIPAL", "ABA01" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", TafNmFolder("recibo",1) ) //"Exame Toxicológico do Motorista Profissional"
	oView:CreateHorizontalBox( "V3Bd", 20,,, "FOLDER_PRINCIPAL", "ABA02" )
	oView:CreateHorizontalBox( "V3Be", 80,,, "FOLDER_PRINCIPAL", "ABA02" )

	oView:SetOwnerView( "VIEW_V3Ba", "V3Ba" )
	oView:SetOwnerView( "VIEW_V3Bb", "V3Bb" )
	oView:SetOwnerView( "VIEW_V3Bc", "V3Bc" )
	oView:SetOwnerView( "VIEW_V3Bd", "V3Bd" )
	oView:SetOwnerView( "VIEW_V3Be", "V3Be" )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt   	as character
	Local cProtocolo	as character
	Local cVersao   	as character
	Local cChvRegAnt	as character
	Local cEvento		as character
	Local nOperation	as numeric
	Local nlI   	    as numeric
	Local lRetorno	    as logical
	Local aGrava    	as array
	Local oModelV3B  	as object

    cVerAnt   	:= ""
	cProtocolo	:= ""
	cVersao   	:= ""
	cChvRegAnt	:= ""
	cEvento		:= ""
	nOperation	:= oModel:GetOperation()
	nlI   	    := 0
	lRetorno	:= .T.
	aGrava    	:= {}
	oModelV3B  	:= Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V3B", "V3B_VERSAO", xFunGetVer() )
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '2', '' )
			
			If TafColumnPos("V3B_LAYOUT")
				oModel:LoadValue( "MODEL_V3B", "V3B_LAYOUT", SuperGetMv('MV_TAFVLES', .F.))
			EndIf

            FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			V3B->( DbSetOrder( 3 ) )
			If V3B->( MsSeek( xFilial( 'V3B' ) + M->V3B_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido com sucesso    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				oModelV3B := oModel:GetModel( 'MODEL_V3B' )

				If TafColumnPos("V3B_LAYOUT")
					oModel:LoadValue( "MODEL_V3B", "V3B_LAYOUT", SuperGetMv('MV_TAFVLES', .F.))
				EndIf

				If V3B->V3B_STATUS ==  "4"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    	:= oModelV3B:GetValue( "V3B_VERSAO" )
					cProtocolo 	:= oModelV3B:GetValue( "V3B_PROTUL" )
					cEvento		:= oModelV3B:GetValue( "V3B_EVENTO" )
					cLogOpeAnt  := oModelV3B:GetValue( "V3B_LOGOPE" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 to Len( oModelV3B:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelV3B:aDataModel[ 1, nlI, 1 ], oModelV3B:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'V3B', '2' )	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( 'MODEL_V3B', 'V3B_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTUL', "" )  

					oModel:LoadValue( "MODEL_V3B", "V3B_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "V3B"
					oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					
					FwFormCommit( oModel )
					TAFAltStat( 'V3B', " " )

				ElseIf	V3B->V3B_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.
				Else
		
					cLogOpeAnt := V3B->V3B_LOGOPE
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					FwFormCommit( oModel )
					TAFAltStat( 'V3B', " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := V3B->(V3B_ID + V3B_VERANT)

			If !Empty( V3B->V3B_VERANT )
				
				TAFAltStat( 'V3B', " " )
				FwFormCommit( oModel )
				
				If V3B->V3B_EVENTO == "A" .Or. V3B->V3B_EVENTO == "E"
					TAFRastro( 'V3B', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf

			Else

				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )

			EndIf

		EndIf

	End Transaction

Return(lRetorno)
 
//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Grv
@type			function
@description	Função de integração dos dados para o evento S-2221.
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
@param			cLayout	-	Nome do Layout que está sendo importado
@param			nOpc	-	Operação a ser executada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv	-	Filial do ERP para onde as informações devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return		    lRet	-	Variável que indica se a importação foi realizada
@return		    aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF528Grv( cLayout as character, nOpc as Numeric, cFilEv as character, oXML as object, cOwner as character, cFilTran as character, cPredeces as character,; 
                    nTafRecno as numeric, cComplem as character, cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character,;
					lMigrador as logical, lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXml as character, cAliEvtOri as character,;
					nRecEvtOri as numeric, cFilPrev as character )

	Local aChave     as array
	Local aIncons    as array
	Local aRules     as array
	Local cCabec     as character
	Local cCmpsNoUpd as character
	Local cCodEvent  as character
	Local cCpf       as character
	Local cIdTrab    as character
	Local cInconMsg  as character
	Local cLogOpeAnt as character
	Local cMatricula as character
	Local cPeriodo   as character
	Local cRecibo    as character
	Local dDtExam    as date
	Local lRet       as logical
	Local nI         as numeric
	Local nSeqErrGrv as numeric
	Local oModel     as object
	
	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := {}

	Default cAliEvtOri := ""
	Default cComplem   := ""
	Default cEmpOriGrp := ""
    Default cEvtOri    := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilPrev   := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cKey       := ""
	Default cLayout    := ""
	Default cMatrC9V   := ""
	Default cOwner     := ""
	Default cPredeces  := ""
	Default cXml       := ""
	Default cXmlID     := ""
	Default lDepGPE    := .F.
	Default lExclCMJ   := .F.
	Default lLaySmpTot := .F.
    Default lMigrador  := .F.
	Default nOpc       := 1
	Default nRecEvtOri := 0
	Default nTafRecno  := 0
	Default oTransf    := Nil
	Default oXML       := Nil

	aChave     := {}
	aIncons    := {}
	aRules     := {}
	cCabec     := "/eSocial/evtToxic/"
	cCmpsNoUpd := "|V3B_FILIAL|V3B_ID|V3B_VERSAO|V3B_CPF|V3B_NIS|V3B_MATRIC|V3B_CODCAT|V3B_DTEXAM|V3B_CNPJLA|V3B_CODSEX|V3B_CODMED|V3B_ATIVO|V3B_INDREC|V3B_EVENTO|V3B_PROTPN|V3B_DCODME|V3B_PROTUL|"
	cCodEvent  := Posicione( "V3B", 2, xFilial( "V3B" ) + "S-" + cLayout, "V3B->V3B_ID" )
	cCpf       := ""
	cIdTrab    := ""
	cInconMsg  := ""
	cLogOpeAnt := ""
	cMatricula := ""
	cPeriodo   := ""
	cRecibo    := ""
	dDtExam    := Ctod("")
	lRet       := .F.
	nI         := 0
	nSeqErrGrv := 0
    oModel     := Nil
	String     := ""

	oDados := oXML

	If !TafColumnPos("V3B_NMMED")

		cString := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0012 //"Para a utilização deste evento é necessário a atualização do dicionário relativo a NT 04/2024 do e-Social por meio do compatibilizador UPDDISTR"

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )

	EndIf

	Begin Transaction

		cRecibo    := FTAFGetVal( cCabec + "ideEvento/nrRecibo"  ,"C", .F., @aIncons, .F. )
		cCpf       := FTAFGetVal( cCabec + "ideVinculo/cpfTrab"  ,"C", .F., @aIncons, .F. )
		cMatricula := FTAFGetVal( cCabec + "ideVinculo/matricula","C", .F., @aIncons, .F. )
		dDtExam    := FTAFGetVal( cCabec + "toxicologico/dtExame","D", .F.,         , .F. )
		cPeriodo   := SubStr(DtoS(dDtExam),1,4) + SubStr(DtoS(dDtExam),5,2)
		cIdTrab    := TAFGetIdFunc( cCpf, cPeriodo, dDtExam, "cpfTrab", cCabec + "ideVinculo/cpfTrab", , cMatricula, , , "matricula" , cCabec + "ideVinculo/matricula" )
		
		aAdd( aChave, { "C", "V3B_FUNC"		, cIdTrab , .T. } )
		aAdd( aChave, { "D", "V3B_DTEXAM"	, dDtExam , .T. } )
		
		//Função para validar se a operação desejada pode ser realizada
		If FTAFVldOpe( "V3B", 5, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA528", cCmpsNoUpd )

			cLogOpeAnt := V3B->V3B_LOGOPE

			//Carrego array com os campos De/Para de gravação das informações
			aRules := TAF528Rul(cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cIdTrab)

			//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V3B", "V3B_FILIAL", V3B->V3B_FILIAL )			
				oModel:LoadValue( "MODEL_V3B", "V3B_XMLID", cXmlID )

				If TafColumnPos("V3B_LAYOUT")
					oModel:LoadValue( "MODEL_V3B", "V3B_LAYOUT", IIf(SuperGetMv('MV_TAFVLES', .F.) $ "02_05_00|S_01_02_00", SuperGetMv('MV_TAFVLES', .F.), "" ))
					oModel:LoadValue( "MODEL_V3B", "V3B_TAFKEY", cKey )
				EndIf

				//Laço no aRules para gravar as informações
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_V3B", aRules[nI,01], FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
				Next nI

				If nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '1', '' )
				Elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '', cLogOpeAnt )
				EndIf

			EndIf		

			If Empty(cInconMsg)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else
				Aadd(aIncons, cInconMsg)
			EndIf
			
			oModel:DeActivate()

		EndIf

	End Transaction

	//Zerando os arrays e os objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return( { lRet, aIncons } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Rul
@type			function
@description	Regras para gravação das informações do Evento S-2221 do eSocial

@param cIdTrab - Id do Trabalhador

@author		    Karyna Martins
@since			21/01/2019
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF528Rul(cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner,cIdTrab)

	Local cCabec		as character
	Local cRecusa		as character
    Local cIdUF         as character
	Local aRull			as array
	Local aInfComp		as array
	Local aIncons		as array

	Default cTagOper	:= ""
	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""

	cCabec		:=	"/eSocial/evtToxic/"
	cRecusa		:= ""
	aRull		:= {}
	aInfComp	:= {}
	aIncons		:= {}

	aAdd( aRull, { "V3B_FUNC"	, cIdTrab								, "C", .T. } )
	aAdd( aRull, { "V3B_CPF"	, cCabec + "ideVinculo/cpfTrab"			, "C", .F. } )

	aAdd( aRull, { "V3B_MATRIC"	, cCabec + "ideVinculo/matricula"		, "C", .F. } )

	aAdd( aRull, { "V3B_DTEXAM"	, cCabec + "toxicologico/dtExame"		, "D", .F. } )
	aAdd( aRull, { "V3B_CNPJLA"	, cCabec + "toxicologico/cnpjLab"		, "C", .F. } )
	aAdd( aRull, { "V3B_CODSEX"	, cCabec + "toxicologico/codSeqExame"	, "C", .F. } )

    If TafColumnPos("V3B_NMMED")
        aAdd( aRull, { "V3B_NMMED"	, cCabec + "toxicologico/nmMed"	        , "C", .F. } )
        aAdd( aRull, { "V3B_NRCRM"	, cCabec + "toxicologico/nrCRM"	        , "C", .F. } )

        If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/toxicologico/ufCRM"))
            cIdUF := FGetIdInt( "uf", "", cCabec + "/toxicologico/ufCRM",,,,@cInconMsg, @nSeqErrGrv)
            aAdd( aRull, { "V3B_IDUFCR"	, cIdUF								, "C", .T. } )
        EndIf
    EndIf 

Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF528Xml
@type			function
@description	Função de geração do XML para o Evento S-2221.
@author			Karyna Martins
@since			21/01/2019
@version		1.0

@param
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return			cXml	-	Estrutura do XML do Layout S-2221
/*/
//---------------------------------------------------------------------
Function TAF528Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml		as character
	Local cLayout	as character
	Local cReg		as character
	Local aMensal	as array
	Local lXmlVLd	as logical

	Default cAlias	:=	"V3B"
	Default cSeqXml := ""

	cXml    	:=	""
	cLayout		:=	"2221"
	aMensal		:=	{}
	cReg		:= "Toxic"
	lXmlVLd		:= TafXmlVLD('TAF528XML')

	DBSelectArea( "V3B" )
	V3B->( DBSetOrder( 1 ) )
	C9V->( DBSetOrder( 2 ) )
	T3A->( DBSetOrder( 1 ) )

	If lXmlVLd                                                                                                                             
																																	
		If C9V->( MsSeek( xFilial("C9V") + V3B->V3B_FUNC + "1" ) )	.Or. T3A->( MsSeek ( xFilial("T3A") + V3B->V3B_FUNC ) )

			cXml := "<ideVinculo>"
			If 	V3B->V3B_FUNC == C9V->C9V_ID	
				cXml += 	xTafTag( "cpfTrab"	, C9V->C9V_CPF	,,.F.)
			Else
				cXml += 	xTafTag( "cpfTrab"	, T3A->T3A_CPF	,,.F.)
			EndIf		

			If 	V3B->V3B_FUNC == C9V->C9V_ID	
				cXml += 	xTafTag( "matricula"	, C9V->C9V_MATRIC	,,.F.	)
			Else
				cXml += 	xTafTag( "matricula"	, T3A->T3A_MATRIC	,,.F.	)
			EndIf		
			
			cXml += "</ideVinculo>"	
		EndIf

		cXml += "<toxicologico>"

			cXml += 	xTafTag( "dtExame"		, V3B->V3B_DTEXAM 	,,.F.)
			cXml += 	xTafTag( "cnpjLab"		, V3B->V3B_CNPJLA	,,.F.)
			cXml += 	xTafTag( "codSeqExame"	, V3B->V3B_CODSEX	,,.F.)
			
            If TafColumnPos("V3B_NMMED")
                cXml +=	xTafTag("nmMed"		, V3B->V3B_NMMED	,,.F.) 
                cXml += xTafTag("nrCRM"		, V3B->V3B_NRCRM	,,.T.)  
                cXml +=	xTafTag("ufCRM"		, Posicione("C09", 3, xFilial("C09") + V3B->V3B_IDUFCR, "C09_UF")	,,.T.)
            EndIf 
	
		cXml += "</toxicologico>"

		//Estrutura do cabeçalho
		cXml := xTafCabXml(cXml,"V3B",cLayout,cReg,aMensal,cSeqXml)

		//Executa a gravação do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	Endif

Return( cXml )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF528Trg
@type			function
@description	Gatilho para o campo 
@author		    Karyna Martins
@since			21/01/2019
@version		1.0
@return		    cRet	-	Indica o código de categoria
/*/
//---------------------------------------------------------------------
Function TAF528Trg()

	Local cRet := ""

	C9V->( DbSetOrder( 2 ) )
	T3A->( DbSetOrder( 1 ) )
	If C9V->( MsSeek ( xFilial("C9V") + M->V3B_FUNC + "1") )

		cRet := Posicione("CUP",1,xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO), "CUP_CODCAT")

	ElseIf T3A->( MsSeek ( xFilial("T3A") + M->V3B_FUNC ) )

		cRet := T3A->T3A_CODCAT	
	EndIf

Return cRet

//---------------------------------------------------------------------
//---------------------------------------------------------------------
Static Function TAF528Func(cCabec)

	Local cCPF 	:= ""
	Local cMatric	:= ""
	Local cNomeEv	:= ""
	Local cId 		:= ""

	cCPF 		:=	FTAFGetVal( cCabec + "ideVinculo/cpfTrab"		, "C", .F.,, .F. )
	cMatric 	:=	FTAFGetVal( cCabec + "ideVinculo/matricula"	, "C", .F.,, .F. )

	// Se possui matrícula, procura um trabalhador com vínculo(S2200); se não, 
	//	procura um S2300
	cNomeEv := IIF(Empty(cMatric),"S2300","S2200")

	cId := Posicione("C9V",4,xFilial("C9V")+ cCPF  + cNomeEv + "1","C9V_ID") //C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO

Return cId

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author denis.oliveira
@since 29/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlI        := 0
	Local nlY        := 0
	Local aGrava     := {}
	Local oModelV3B  := Nil

	Default oModel   := Nil
	Default nRecno   := 0
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("V3B")->( DBGoTo( nRecno ) )

		oModelV3B	:= oModel:GetModel( 'MODEL_V3B' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelV3B:GetValue( "V3B_VERSAO" )
		cProtocolo	:= oModelV3B:GetValue( "V3B_PROTUL" )
		cEvento	    := oModelV3B:GetValue( "V3B_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelV3B:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelV3B:aDataModel[ nlI, nlY, 1 ], oModelV3B:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'V3B', '2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu preciso setar a operacao do model³
		//³como Inclusao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu realizo a inclusao do novo registro ja³
		//³contemplando as informacoes alteradas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V3B", "V3B_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V3B", "V3B_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V3B', 'V3B' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'V3B',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250View
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF528View( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 1 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 1 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Inc
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF528Inc( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 3 )
