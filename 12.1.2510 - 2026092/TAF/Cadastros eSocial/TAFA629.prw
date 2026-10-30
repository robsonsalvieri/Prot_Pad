#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA629.CH"
#INCLUDE "TOPCONN.CH"

Static __cPicVrMen  := Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA629
@type			function
@description	Solicitação de Consolidação das Informações de 
                Tributos Decorrentes de Processo Trabalhista - S-2555.
@author		    Daniele Sakamoto
@since			04/09/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA629()
	
	Private oBrw 		as object
	Private cEvtPosic 	as Character		
	
	oBrw		:= FWmBrowse():New()
	cEvtPosic 	:= ""

	If TAFAtualizado( .T. ,'TAFA629' )
		TafNewBrowse( "S-2555",,,, STR0001, , 2, 2 )
	EndIf
	
	oBrw:SetCacheView( .F. )

Return  

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author		Daniele Sakamoto
@since			04/09/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao
	Local aRotina

	aFuncao := {}
	aRotina := {}

	If !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES") .AND. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF629View('T8I',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF629Inc('T8I',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('T8I', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA629"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA629' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA629", "T8I", .F. ) // Menu dos extemporâneos
		EndIf

	EndIf

	
Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author		    Daniele Sakamoto
@since			04/09/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT8I	as object
	Local oModel	as object

	oStruT8I	:=	FWFormStruct( 1, "T8I" )
	oModel	:=	MpFormModel():New("TAFA629",,,{|oModel| SaveModel(oModel)})

	//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT8I:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf

	oModel:AddFields('MODEL_T8I', /*cOwner*/, oStruT8I)
	oModel:GetModel( 'MODEL_T8I' ):SetPrimaryKey( { 'T8I_FILIAL' , 'T8I_PERAPU','T8I_ATIVO' } )
    // OBRIGATORIEDADE DE CAMPOS 
	oStruT8I:SetProperty( 'T8I_NRPROC', MODEL_FIELD_OBRIGAT , .T. )
    oStruT8I:SetProperty( 'T8I_PERAPU', MODEL_FIELD_OBRIGAT , .T. )



    //Remoç?o do GetSX8Num quando se tratar da Exclus?o de um Evento Transmitido.
	//Necessário para n?o incrementar ID que n?o será utilizado.
	If Type( "INCLUI" ) <> "U"  .AND. !INCLUI
		oStruT8I:SetProperty( "T8I_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndiF

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author		    Daniele Cristina
@since			04/09/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	as object
	Local oStruT8Ia	as object
    Local oStruT8Ib	as object
    Local oStruT8Ic	as object
	Local oView		as object
	Local cCmpFil	as Character

	oModel		:=	FWLoadModel( "TAFA629" )
	oStruT8Ia	:=	Nil
    oStruT8cb	:=	Nil
    oStruT8Ib	:=	Nil
	oView		:= FWFormView():New()
	cCmpFil		:=	""

	oView:SetModel( oModel ) 

	//Principal
	cCmpFil := "T8I_NRPROC|T8I_PERAPU|"
	oStruT8Ia := FWFormStruct( 2, "T8I", { |x| AllTrim( x ) + "|" $ cCmpFil } )

    //Campo do Numero do Recibo"
	cCmpFil := "T8I_PROTUL|"
	oStruT8Ib := FWFormStruct( 2, "T8I", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	TafAjustRecibo(oStruT8Ib,"T8I")

	cCmpFil := "T8I_DINSIS|T8I_DTRANS|T8I_HTRANS|T8I_DTRECP|T8I_HRRECP|"
	oStruT8Ic := FWFormStruct( 2, "T8I", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	
	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/

	oView:AddField( "VIEW_T8Ia", oStruT8Ia, "MODEL_T8I" )

	oView:AddField( "VIEW_T8Ib", oStruT8Ib, "MODEL_T8I" )
	oView:EnableTitleView( 'VIEW_T8Ib',  TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	
	oView:AddField( "VIEW_T8Ic", oStruT8Ic, "MODEL_T8I" )
	oView:EnableTitleView( 'VIEW_T8Ic',  TafNmFolder("recibo",2) )
	
   
	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )

	oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0002 ) 
	oView:CreateHorizontalBox( "T8Ia", 100,,, "FOLDER_PRINCIPAL", "ABA01" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", TafNmFolder("recibo",1) ) 
	oView:CreateHorizontalBox( "T8Ib", 20,,, "FOLDER_PRINCIPAL", "ABA02" )
	oView:CreateHorizontalBox( "T8Ic", 80,,, "FOLDER_PRINCIPAL", "ABA02" )

	oView:SetOwnerView( "VIEW_T8Ia" , "T8Ia" )
	oView:SetOwnerView( "VIEW_T8Ib", "T8Ib" )
	oView:SetOwnerView( "VIEW_T8Ic", "T8Ic" )
	
Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author		    Daniele Sakamoto
@since			04/09/2024
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
	Local cLayout		as character
	Local nOperation	as numeric
	Local nlI   	    as numeric
	Local lRetorno	    as logical
	Local aGrava    	as array
	Local oModelT8I  	as object

    cVerAnt   	:= ""
	cProtocolo	:= ""
	cVersao   	:= ""
	cChvRegAnt	:= ""
	cEvento		:= ""
	cLayout		:= Iif( FindFunction('getVerLayout'), getVerLayout(), SuperGetMV("MV_TAFVLES"))
	nOperation	:= oModel:GetOperation()
	nlI   	    := 0
	lRetorno	:= .T.
	aGrava    	:= {}
	oModelT8I  	:= Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

            TafAjustID( "T8I", oModel)

			oModel:LoadValue( "MODEL_T8I", "T8I_VERSAO", xFunGetVer() )
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T8I', 'T8I_LOGOPE' , '2', '' )
			
			oModel:LoadValue( "MODEL_T8I", "T8I_LAYOUT", cLayout)
			
            oModel:LoadValue( "MODEL_T8I", "T8I_EVENTO", "I" )
            oModel:LoadValue( "MODEL_T8I", "T8I_ATIVO", "1" )	

            FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T8I->( DbSetOrder( 2 ) )
			If T8I->( MsSeek( xFilial( 'T8I' ) + T8I->T8I_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³ 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T8I->T8I_STATUS $ ( "4" )		
					oModel:SetErrorMessage(, , , , , STR0003, , , )//"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno := .F.
				Else
					//Alteração Sem Transmissão
					cLogOpeAnt := T8I->T8I_LOGOPE
					
				Endif
				
				If lRetorno			
					
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T8I', 'T8I_LOGOPE' , '' , cLogOpeAnt )

					FwFormCommit( oModel )
					TAFAltStat( "T8I", " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			If T8I->T8I_STATUS == "4"
				oModel:SetErrorMessage(, , , , , xValStrEr("000783"), , , ) //"Registro não pode ser excluído, pois o evento já se encontra base do RET"  
				lRetorno := .F.
			Else

				TAFAltStat( 'T8I', "" )
				FwFormCommit( oModel )

			Endif

		EndIf

	End Transaction

Return(lRetorno)
 
//---------------------------------------------------------------------
/*/{Protheus.doc} TAF629Grv
@type			function
@description	Função de integração dos dados para o evento S-2555.
@author		    Daniele Sakamoto
@since			04/09/2024
@version		1.0
@param			cLayout	-	Nome do Layout que está sendo importado
@param			nOpc	-	Operação a ser executada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv	-	Filial do ERP para onde as informações devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return		    lRet	-	Variável que indica se a importação foi realizada
@return		    aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF629Grv( cLayout as character, nOpc as Numeric, cFilEv as character, oXML as object, cOwner as character, cFilTran as character, cPredeces as character,; 
                        nTafRecno as numeric, cComplem as character, cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character,;
                        lMigrador as logical, lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXml as character, cAliEvtOri as character,;
                        nRecEvtOri as numeric, cFilPrev as character )

    Local cCmpsNoUpd	as character
    Local oModel		as object
    Local cCabec		as character
    Local cInconMsg		as character
    Local cNrProc       as character
    Local cPeriodo      as character
    Local cCodEvent		as character
    Local cLogOpeAnt	as character
	Local cLayEve		as character
    Local cLayNmSpac    as character 
    Local nI			as numeric
    Local nSeqErrGrv	as numeric
    Local aIncons		as array
    Local aChave		as array
	Local aRules		as array
    Local lRet			as logical

        
    Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
    Private oDados		:=	{}

    Default cLayout		:=	""
    Default nOpc		:=	1
    Default cFilEv		:=	""
    Default oXML		:=	Nil
    Default cOwner		:= ""
    Default cFilTran	:= ""
    Default cPredeces	:= ""
    Default cComplem	:= ""
    Default cXmlID		:=	""
    Default cGrpTran	:= ""
    Default cEmpOriGrp	:= ""
    Default cFilOriGrp	:= ""
    Default nTafRecno	:= 0
    Default cEvtOri     := ""
    Default lMigrador   := .F.
    Default lDepGPE     := .F.
    Default cKey        := ""
    Default cMatrC9V    := ""
    Default lLaySmpTot  := .F.
    Default lExclCMJ    := .F.
    Default oTransf     := Nil
    Default cXml        := ""
    Default cAliEvtOri  := ""
    Default nRecEvtOri  := 0
    Default cFilPrev    := ""

    cCmpsNoUpd	:= "|T8I_FILIAL|T8I_ID|T8I_VERSAO|T8I_ATIVO|T8I_EVENTO|T8I_PROTPN|T8I_STATUS|V3B_PROTUL|"
    oModel		:=	Nil
    cCabec		:=	"/eSocial/evtConsolidContProc/"
    cInconMsg	:=	""
    String		:=	""
    cNrProc     :=  ""
    cPeriodo    :=  ""
    cCodEvent	:=  ""
	cLayEve		:= Iif( FindFunction('getVerLayout'), getVerLayout(), SuperGetMV("MV_TAFVLES"))
    cLayNmSpac  := ""
    nI			:=	0
    nSeqErrGrv	:=	0
    aChave		:=	{}
    aIncons		:=	{}
	aRules		:=  {}
    lRet		:=	.F.
    cLogOpeAnt	:=  ""

    oDados := oXML
    lVldModel := .T.

	cNrProc   := FTafGetVal(  cCabec + "ideProc/nrProcTrab", "C", .F., @aIncons, .F. )
	cPeriodo  := FTafGetVal(  cCabec + "ideProc/perApurPgto", "C", .F., @aIncons, .F. )
	
	If !TafColumnPos("T8I_NRPROC")
		Aadd(aIncons, STR0006)//"Para realizar a integração do evento S-2555 por favor atualizar o Dicionario de dados com o pacote de simplificação da versão 1.3 do layout do eSocial"
		lRet := .F.
	Else
		cCodEvent	:=  Posicione( "T8I", 2, xFilial( "T8I" ) + "S-" + cLayout, "T8I->T8I_ID" )
		Aadd( aChave, {"C", "T8I_NRPROC", cNrProc,.T.} )

		If At("-", cPeriodo) > 0
			cPeriodo := StrTran(cPeriodo, "-", "" )
			Aadd( aChave, {"C", "T8I_PERAPU", cPeriodo,.T.} )
		Else
			Aadd( aChave, {"C", "T8I_PERAPU", cPeriodo,.T.} )
		EndIf
			
		//Função para validar se a operação desejada pode ser realizada
		T8I->( DbSetOrder( 4 ) )
		
		Begin Transaction	
			//Funcao para validar se a operacao desejada pode ser realizada
			If FTAFVldOpe( "T8I", 4, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA629", cCmpsNoUpd )

				cLogOpeAnt := T8I->T8I_LOGOPE

				//Carrego array com os campos De/Para de gravação das informações
				aRules := TAF629Rul(cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cNrProc)

				//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
				If nOpc <> 5

					oModel:LoadValue( "MODEL_T8I", "T8I_FILIAL", T8I->T8I_FILIAL )			
					oModel:LoadValue( "MODEL_T8I", "T8I_XMLID", cXmlID )
					oModel:LoadValue( "MODEL_T8I", "T8I_PERAPU", cPeriodo )

					oModel:LoadValue( "MODEL_T8I", "T8I_LAYOUT", cLayEve)
					oModel:LoadValue( "MODEL_T8I", "T8I_TAFKEY", cKey )

					//Laço no aRules para gravar as informações
					For nI := 1 to Len( aRules )
						oModel:LoadValue( "MODEL_T8I", aRules[nI,01], FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
					Next nI

					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T8I', 'T8I_LOGOPE' , '1', '' )
					EndIf

				EndIf		

				If Empty(cInconMsg)
					If TafFormCommit( oModel )
						Aadd(aIncons, "ERRO19")
					Else
						lRet := .T.
					EndIf
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

	EndIf

Return( { lRet, aIncons } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF629Rul
@type			function
@description	Regras para gravação das informações do Evento S-2555 do eSocial

@param cNrProc - Número do Processo

@author		    Daniele Sakamoto
@since			05/09/2024
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF629Rul(cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner,cNrProc)

	Local cCabec		as character
	Local cRecusa		as character
	Local aRull			as array
	Local aInfComp		as array
	Local aIncons		as array

	Default cTagOper	:= ""
	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""

	cCabec		:=	"/eSocial/evtConsolidContProc/"
	cRecusa		:= ""
	aRull		:= {}
	aInfComp	:= {}
	aIncons		:= {}

	aAdd( aRull, { "T8I_NRPROC"	, cCabec + "ideProc/nrProcTrab"			    , "C", .F. } )
    aAdd( aRull, { "T8I_PERAPU"	, cCabec + "ideProc/perApurPgto"			, "C", .F. } )


Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF629Xml
@type			function
@description	Função de geração do XML para o Evento S-2555.
@author			Daniele Sakamoto
@since			04/09/2024
@version		1.0

@param
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return			cXml	-	Estrutura do XML do Layout S-2555
/*/
//---------------------------------------------------------------------
Function TAF629Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml		as character
	Local cLayout	as character
	Local cReg		as character
	Local cCodCat	as character
	Local cIdCateg	as character
	Local aMensal	as array
	Local lXmlVLd	as logical

	Default cAlias	:=	"T8I"
	Default cSeqXml := ""

	cXml    	:=	""
	cLayout		:=	"2555"
	aMensal		:=	{}
	cReg		:= "ConsolidContProc"
	cCodCat		:= ""
	cIdCateg	:= ""
	lXmlVLd		:= TafXmlVLD('TAF629XML')

	DBSelectArea( "T8I" )
	T8I->( DBSetOrder( 4 ) )

	If lXmlVLd                                                                                                                             
																																	
		If __cPicVrMen == Nil
		    __cPicPerRef := PesqPict( "T8I", "T8I_PERAPU", 7 )
	    EndIf

            If T8I->( MsSeek( xFilial("T8I") + T8I->T8I_NRPROC + T8I_PERAPU +"1" ) )

                cXml := "<ideProc>"	 

                    cXml    +=      xTafTag( "nrProcTrab"   , T8I->T8I_NRPROC,, .F.)
                    cXml    +=      xTafTag( "perApurPgto"  , Transform( T8I->T8I_PERAPU, __cPicPerRef) ,, .F.)		
                
                cXml += "</ideProc>"

            EndIf    	
		

		//Estrutura do cabeçalho
		cXml := xTafCabXml(cXml,"T8I",cLayout,cReg,aMensal,cSeqXml)

		//Executa a gravação do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	Endif

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF629View
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Daniele Sakamoto
@since   10/02/2025
@version 1
/*/
//-------------------------------------------------------------------
Function TAF629View( cAlias as character, nRecno as numeric )

	Local oNewView	as Object
	Local oExecView	as Object
	Local aArea 	as Array
	
	oNewView	:= ViewDef()
	aArea 		:= GetArea()
	oExecView	:= Nil

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
/*/{Protheus.doc} TAF629Inc
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Daniele Sakamoto
@since   10/02/2025
@version 1
/*/
//-------------------------------------------------------------------
Function TAF629Inc( cAlias as character, nRecno as numeric )

	Local aArea     as Array
	Local oExecView as Object
	Local oNewView  as Object
	
	aArea     := GetArea()
	oExecView := Nil
	oNewView  := ViewDef()

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

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3500)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno

@Return .T.

@Author Daniele Sakamoto
@Since 10/02/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local oModelT8I  := Nil
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nI         := 0
	Local aGrava     := {}

	Default oModel   := Nil
	Default nRecno   := 1
	Default lRotExc  := .F.

	oModelT8I	:= oModel:GetModel("MODEL_T8I") 

	dbSelectArea("T8I")
	("T8I")->( DBGoTo( nRecno ) )

	Begin Transaction	
		
		oModelT8I := oModel:GetModel( 'MODEL_T8I' )  
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelT8I:GetValue( "T8I_VERSAO" )				
		cProtocolo	:= oModelT8I:GetValue( "T8I_PROTUL" )
		cEvento		:= oModelT8I:GetValue( "T8I_EVENTO" )   
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas    ³
		//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
		//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
		//³consideradas agora.					                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len( oModelT8I:aDataModel[ 1 ] )
			Aadd( aGrava, { oModelT8I:aDataModel[ 1, nI, 1 ], oModelT8I:aDataModel[ 1, nI, 2 ] } )
		Next nI 
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³ 
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'T8I', '2' ) 
							
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
		For nI := 1 To Len( aGrava )	
			oModel:LoadValue( 'MODEL_T8I', aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
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
		oModel:LoadValue( 'MODEL_T8I', 'T8I_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_T8I', 'T8I_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_T8I', 'T8I_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_T8I', 'T8I_PROTUL', "" )
		
		oModel:LoadValue( 'MODEL_T8I', 'T8I_EVENTO', "E" )
		oModel:LoadValue( 'MODEL_T8I', 'T8I_ATIVO', "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'T8I',"6" )
					
	End Transaction       

Return .T.
