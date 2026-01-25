#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA521.CH"
#INCLUDE "TOPCONN.CH"
 
Static lLaySimplif := taflayEsoc("S_01_00_00")
Static __aPicCache  := Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA521
@type			function
@description	Informações do FGTS Consolidadas por Contribuinte - S-5013.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA521()

	Local cMessage	:=	""
	Private oBrowse	:=	FWMBrowse():New()

	If TAFAlsInDic( "V2Z" )

		oBrowse:SetDescription( STR0001 ) //"Informações do FGTS Consolidadas por Contribuinte"
		oBrowse:SetAlias( "V2Z" )
		oBrowse:SetMenuDef( "TAFA521" )

		oBrowse:SetFilterDefault( "V2Z_ATIVO == '1'" )

		oBrowse:Activate()

	Else

		cMessage := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
		Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
		
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:=	{}
	Local aFuncao	:=	{}

	aAdd( aFuncao, { "", "TAF521Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V2Z', 'S-5013', 'evtFGTS', 'TAF521Xml' , , oBrowse )", "5" } )

	//Variável Private utilizada para controle do menu na chamada da View na operação de Histórico de Alterações
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA521" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA521",, aFuncao )
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV6N	:=	Nil
	Local oStruV6O	:=	Nil
	Local oStruV2Z	:=	FWFormStruct( 1, "V2Z" )
	Local oStruV20	:=	FWFormStruct( 1, "V20" )
	Local oStruV21	:=	FWFormStruct( 1, "V21" )
	Local oStruV22	:=	FWFormStruct( 1, "V22" )
	Local oStruV23	:=	FWFormStruct( 1, "V23" )
	Local oStruV24	:=	FWFormStruct( 1, "V24" )
	Local oStruV25	:=	FWFormStruct( 1, "V25" )
	Local oModel	:=	MPFormModel():New( "TAFA521",,, { |oModel| SaveModel( oModel ) } )

	//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If !lLaySimplif

		oStruV2Z:RemoveField( "V2Z_INDAPU" )
		oStruV20:RemoveField( "V20_INDINC" )
		oStruV20:RemoveField( "V20_VRFGTS" )
		oStruV22:RemoveField( "V22_INDINE" )
		oStruV22:RemoveField( "V22_VRFGTE" )
		oStruV22:RemoveField( "V20_DLOT"   )
		oStruV22:RemoveField( "V20_DTPLOT" )
		oStruV22:RemoveField( "V21_DLOT"   )
		oStruV22:RemoveField( "V21_DTPLOT" )
		oStruV22:RemoveField( "V22_DLOT"   )
		oStruV22:RemoveField( "V22_DTPLOT" )
		
	Else

		oStruV6N :=	FWFormStruct( 1, "V6N" )
		oStruV6O :=	FWFormStruct( 1, "V6O" )

	EndIf

	If lVldModel

		oStruV2Z:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV20:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV21:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV22:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV23:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV24:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV25:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )

		If lLaySimplif

			oStruV6N:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
			oStruV6O:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )

		EndIf

	EndIf

	If TAFColumnPos("V6O_DLOT") .And. lLaySimplif

		oStruV6O:SetProperty( "V6O_CODLOT" , MODEL_FIELD_OBRIGAT , .F. )
		oStruV6O:SetProperty( "V6O_TPLOT"  , MODEL_FIELD_OBRIGAT , .F. )
		oStruV20:SetProperty( "V20_IDTPVL" , MODEL_FIELD_OBRIGAT , .F. )
		oStruV22:SetProperty( "V22_IDTPVL" , MODEL_FIELD_OBRIGAT , .F. )
		oStruV23:SetProperty( "V23_IDTPDP" , MODEL_FIELD_OBRIGAT , .F. )
		oStruV25:SetProperty( "V25_IDTPDP" , MODEL_FIELD_OBRIGAT , .F. )

		oStruV6O:SetProperty( "V6O_DLOT"   , MODEL_FIELD_OBRIGAT , .T. )
		oStruV6O:SetProperty( "V6O_DTPLOT" , MODEL_FIELD_OBRIGAT , .T. )
		oStruV20:SetProperty( "V20_DTPVL"  , MODEL_FIELD_OBRIGAT , .T. )
		oStruV22:SetProperty( "V22_DTPVL"  , MODEL_FIELD_OBRIGAT , .T. )
		oStruV23:SetProperty( "V23_DTPDP"  , MODEL_FIELD_OBRIGAT , .T. )
		oStruV25:SetProperty( "V25_DTPDP"  , MODEL_FIELD_OBRIGAT , .T. )

	EndIf

	oModel:AddFields( "MODEL_V2Z", /*cOwner*/, oStruV2Z )

	If lLaySimplif

		//Identificação do estabelecimento
		oModel:AddGrid( "MODEL_V6N", "MODEL_V2Z", oStruV6N )
		oModel:GetModel( "MODEL_V6N" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6N" ):SetUniqueLine( { "V6N_TPINSC", "V6N_NRINSC" } )

		If !TAFColumnPos("V6O_DLOT")

			//Identificação da lotação tributária
			oModel:AddGrid( "MODEL_V6O", "MODEL_V6N", oStruV6O )
			oModel:GetModel( "MODEL_V6O" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V6O" ):SetUniqueLine( {  "V6O_CODLOT", "V6O_TPLOT", "V6O_TPINSC", "V6O_NRINSC" } )
			oModel:GetModel( "MODEL_V6O"):SetMaxLine(9999)

			//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V20", "MODEL_V6O", oStruV20 )
			oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_IDTPVL", "V20_INDINC" } )
			oModel:GetModel( "MODEL_V20" ):SetMaxLine( 99 )

			//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V21", "MODEL_V6O", oStruV21 )
			oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF", "V21_TPCONV" } )
			oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

			//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
			oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_IDTPVL", "V22_INDINE" } )
			oModel:GetModel( "MODEL_V22" ):SetMaxLine( 99 )
			
		Else

			//Identificação da lotação tributária
			oModel:AddGrid( "MODEL_V6O", "MODEL_V6N", oStruV6O )
			oModel:GetModel( "MODEL_V6O" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V6O" ):SetUniqueLine( {  "V6O_DLOT", "V6O_DTPLOT", "V6O_TPINSC", "V6O_NRINSC" } )
			oModel:GetModel( "MODEL_V6O"):SetMaxLine(9999)

			//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V20", "MODEL_V6O", oStruV20 )
			oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_DTPVL", "V20_INDINC" } )
			oModel:GetModel( "MODEL_V20" ):SetMaxLine( 99 )

			//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V21", "MODEL_V6O", oStruV21 )
			oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF", "V21_TPCONV" } )
			oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

			//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
			oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_DTPVL", "V22_INDINE" } )
			oModel:GetModel( "MODEL_V22" ):SetMaxLine( 99 )

		EndIf
			
	Else

		If !TAFColumnPos("V6O_DLOT")

			//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V20", "MODEL_V2Z", oStruV20 )
			oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_IDTPVL" } )
			oModel:GetModel( "MODEL_V20" ):SetMaxLine( 21 )

			//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V21", "MODEL_V2Z", oStruV21 )
			oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF" } )
			oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

			//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
			oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_IDTPVL" } )
			oModel:GetModel( "MODEL_V22" ):SetMaxLine( 11 )

			//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V23", "MODEL_V2Z", oStruV23 )
			oModel:GetModel( "MODEL_V23" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V23" ):SetUniqueLine( { "V23_IDTPDP" } )
			oModel:GetModel( "MODEL_V23" ):SetMaxLine( 20 )

			//Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V24", "MODEL_V2Z", oStruV24 )
			oModel:GetModel( "MODEL_V24" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V24" ):SetUniqueLine( { "V24_PERREF" } )
			oModel:GetModel( "MODEL_V24" ):SetMaxLine( 180 )

			//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
			oModel:AddGrid( "MODEL_V25", "MODEL_V24", oStruV25 )
			oModel:GetModel( "MODEL_V25" ):SetUniqueLine( { "V25_IDTPDP" } )
			oModel:GetModel( "MODEL_V25" ):SetMaxLine( 10 )

		Else 

			//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V20", "MODEL_V2Z", oStruV20 )
			oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_DTPVL" } )
			oModel:GetModel( "MODEL_V20" ):SetMaxLine( 21 )

			//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V21", "MODEL_V2Z", oStruV21 )
			oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF" } )
			oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

			//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
			oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_DTPVL" } )
			oModel:GetModel( "MODEL_V22" ):SetMaxLine( 11 )

			//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
			oModel:AddGrid( "MODEL_V23", "MODEL_V2Z", oStruV23 )
			oModel:GetModel( "MODEL_V23" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V23" ):SetUniqueLine( { "V23_DTPDP" } )
			oModel:GetModel( "MODEL_V23" ):SetMaxLine( 20 )

			//Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
			oModel:AddGrid( "MODEL_V24", "MODEL_V2Z", oStruV24 )
			oModel:GetModel( "MODEL_V24" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V24" ):SetUniqueLine( { "V24_PERREF" } )
			oModel:GetModel( "MODEL_V24" ):SetMaxLine( 180 )

			//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
			oModel:AddGrid( "MODEL_V25", "MODEL_V24", oStruV25 )
			oModel:GetModel( "MODEL_V25" ):SetUniqueLine( { "V25_DTPDP" } )
			oModel:GetModel( "MODEL_V25" ):SetMaxLine( 10 )

		EndIf

	EndIf                                             
                 
	If lLaySimplif

		oModel:SetRelation("MODEL_V6N", {{"V6N_FILIAL", "xFilial('V6N')"}, {"V6N_ID", "V2Z_ID"}, {"V6N_VERSAO", "V2Z_VERSAO"}}, V6N->(IndexKey(1)))
		oModel:SetRelation("MODEL_V6O", {{"V6O_FILIAL", "xFilial('V6O')"}, {"V6O_ID", "V2Z_ID"}, {"V6O_VERSAO", "V2Z_VERSAO"}, {"V6O_ESTTP", "V6N_TPINSC"}, {"V6O_ESTNRI", "V6N_NRINSC"}}, V6O->(IndexKey(2)))

		If TAFColumnPos("V6O_DLOT") .And. FWSIXUtil():ExistIndex("V20", "4")

			oModel:SetRelation("MODEL_V20", {{"V20_FILIAL", "xFilial('V20')"}, {"V20_ID", "V2Z_ID"}, {"V20_VERSAO", "V2Z_VERSAO"}, {"V20_ESTTP", "V6N_TPINSC"}, {"V20_ESTNRI", "V6N_NRINSC"}, {"V20_CODLOT", "V6O_CODLOT"}, {"V20_TPLOT", "V6O_TPLOT"}, {"V20_TPINSC", "V6O_TPINSC"}, {"V20_NRINSC", "V6O_NRINSC"}, {"V20_DLOT", "V6O_DLOT"}, {"V20_DTPLOT", "V6O_DTPLOT"}}, V20->(IndexKey(4)))
			oModel:SetRelation("MODEL_V21", {{"V21_FILIAL", "xFilial('V21')"}, {"V21_ID", "V2Z_ID"}, {"V21_VERSAO", "V2Z_VERSAO"}, {"V21_ESTTP", "V6N_TPINSC"}, {"V21_ESTNRI", "V6N_NRINSC"}, {"V21_CODLOT", "V6O_CODLOT"}, {"V21_TPLOT", "V6O_TPLOT"}, {"V21_TPINSC", "V6O_TPINSC"}, {"V21_NRINSC", "V6O_NRINSC"}, {"V21_DLOT", "V6O_DLOT"}, {"V21_DTPLOT", "V6O_DTPLOT"}}, V21->(IndexKey(4)))
			oModel:SetRelation("MODEL_V22", {{"V22_FILIAL", "xFilial('V22')"}, {"V22_ID", "V2Z_ID"}, {"V22_VERSAO", "V2Z_VERSAO"}, {"V22_ESTTP", "V6N_TPINSC"}, {"V22_ESTNRI", "V6N_NRINSC"}, {"V22_CODLOT", "V6O_CODLOT"}, {"V22_TPLOT", "V6O_TPLOT"}, {"V22_TPINSC", "V6O_TPINSC"}, {"V22_NRINSC", "V6O_NRINSC"}, {"V22_DLOT", "V6O_DLOT"}, {"V22_DTPLOT", "V6O_DTPLOT"}, {"V22_PERREF", "V21_PERREF"}, {"V22_TPCONV", "V21_TPCONV"}}, V22->(IndexKey(4)))
		
		Else

			oModel:SetRelation("MODEL_V20", {{"V20_FILIAL", "xFilial('V20')"}, {"V20_ID", "V2Z_ID"}, {"V20_VERSAO", "V2Z_VERSAO"}, {"V20_ESTTP", "V6N_TPINSC"}, {"V20_ESTNRI", "V6N_NRINSC"}, {"V20_CODLOT", "V6O_CODLOT"}, {"V20_TPLOT", "V6O_TPLOT"}, {"V20_TPINSC", "V6O_TPINSC"}, {"V20_NRINSC", "V6O_NRINSC"}}, V20->(IndexKey(3)))
			oModel:SetRelation("MODEL_V21", {{"V21_FILIAL", "xFilial('V21')"}, {"V21_ID", "V2Z_ID"}, {"V21_VERSAO", "V2Z_VERSAO"}, {"V21_ESTTP", "V6N_TPINSC"}, {"V21_ESTNRI", "V6N_NRINSC"}, {"V21_CODLOT", "V6O_CODLOT"}, {"V21_TPLOT", "V6O_TPLOT"}, {"V21_TPINSC", "V6O_TPINSC"}, {"V21_NRINSC", "V6O_NRINSC"}}, V21->( IndexKey(3)))
			oModel:SetRelation("MODEL_V22", {{"V22_FILIAL", "xFilial('V22')"}, {"V22_ID", "V2Z_ID"}, {"V22_VERSAO", "V2Z_VERSAO"}, {"V22_ESTTP", "V6N_TPINSC"}, {"V22_ESTNRI", "V6N_NRINSC"}, {"V22_CODLOT", "V6O_CODLOT"}, {"V22_TPLOT", "V6O_TPLOT"}, {"V22_TPINSC", "V6O_TPINSC"}, {"V22_NRINSC", "V6O_NRINSC"}, {"V22_PERREF", "V21_PERREF"}, {"V22_TPCONV", "V21_TPCONV"}}, V22->(IndexKey(3)))
		
		EndIf

	Else

		oModel:SetRelation( "MODEL_V20", { { "V20_FILIAL", "xFilial( 'V20' )" }, { "V20_ID", "V2Z_ID" }, { "V20_VERSAO", "V2Z_VERSAO" } }, V20->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V21", { { "V21_FILIAL", "xFilial( 'V21' )" }, { "V21_ID", "V2Z_ID" }, { "V21_VERSAO", "V2Z_VERSAO" } }, V21->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V22", { { "V22_FILIAL", "xFilial( 'V22' )" }, { "V22_ID", "V2Z_ID" }, { "V22_VERSAO", "V2Z_VERSAO" }, { "V22_PERREF", "V21_PERREF" } }, V22->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V23", { { "V23_FILIAL", "xFilial( 'V23' )" }, { "V23_ID", "V2Z_ID" }, { "V23_VERSAO", "V2Z_VERSAO" } }, V23->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V24", { { "V24_FILIAL", "xFilial( 'V24' )" }, { "V24_ID", "V2Z_ID" }, { "V24_VERSAO", "V2Z_VERSAO" } }, V24->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V25", { { "V25_FILIAL", "xFilial( 'V25' )" }, { "V25_ID", "V2Z_ID" }, { "V25_VERSAO", "V2Z_VERSAO" }, { "V25_PERREF", "V24_PERREF" } }, V25->( IndexKey( 1 ) ) )

	EndIf

	oModel:GetModel( "MODEL_V2Z" ):SetPrimaryKey( { "V2Z_PERAPU" } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFil   as Character
	Local cV20      as Character
	Local cV21      as Character
	Local cV22      as Character
	Local cV23      as Character
	Local cV25      as Character
	Local cV6O      as Character
	Local oModel    as Object
	Local oStruV20  as Object
	Local oStruV21  as Object
	Local oStruV22  as Object
	Local oStruV23  as Object
	Local oStruV24  as Object
	Local oStruV25  as Object
	Local oStruV2Za as Object
	Local oStruV2Zb as Object
	Local oStruV6N  as Object
	Local oStruV6O  as Object
	Local oView     as Object

	If !lLaySimplif .Or. (lLaySimplif .And. !TAFColumnPos("V6O_DLOT"))

		cV6O := "V6O_CODLOT|V6O_TPLOT|V6O_TPINSC|V6O_NRINSC|"
		cV20 := "V20_IDTPVL|V20_DIDTPV|V20_VLFGTS|"
		cV21 := "V21_PERREF|V21_TPCONV|"
		cV22 := "V22_IDTPVL|V22_DIDTPV|V22_VLFGTS|V22_TPCONV|"

		If !TAFColumnPos("V23_DTPDP")

			cV23 := "V23_IDTPDP|V23_DIDTPD|V23_VLFGTS|"
			cV25 := "V25_IDTPDP|V25_DIDTPD|V25_VLFGTS|" 

		Else

			cV23 := "V23_IDTPDP|V23_DTPDP|V23_DIDTPD|V23_VLFGTS|"
			cV25 := "V25_IDTPDP|V25_DTPDP|V25_DIDTPD|V25_VLFGTS|" 

		EndIf

	Else

		cV6O := "V6O_CODLOT|V6O_DLOT|V6O_TPLOT|V6O_DTPLOT|V6O_TPINSC|V6O_NRINSC|"
		cV20 := "V20_IDTPVL|V20_DTPVL|V20_DIDTPV|V20_INDINC|V20_VLFGTS|V20_VRFGTS|"
		cV21 := "V21_PERREF|V21_TPCONV|"
		cV22 := "V22_IDTPVL|V22_DTPVL|V22_DIDTPV|V22_INDINE|V22_VLFGTS|V22_VRFGTE|"

	EndIf

	cCmpFil   := ""
	oModel    := FWLoadModel( "TAFA521" )
	oStruV20  := FWFormStruct( 2, "V20",{|x| AllTrim( x ) + "|" $ cV20 } )
	oStruV21  := FWFormStruct( 2, "V21",{|x| AllTrim( x ) + "|" $ cV21 } )
	oStruV22  := FWFormStruct( 2, "V22",{|x| AllTrim( x ) + "|" $ cV22 } )
	oStruV23  := Iif( !lLaySimplif, FWFormStruct( 2, "V23",{|x| AllTrim( x ) + "|" $ cV23 } ), Nil)
	oStruV24  := FWFormStruct( 2, "V24" )
	oStruV25  := Iif( !lLaySimplif, FWFormStruct( 2, "V25",{|x| AllTrim( x ) + "|" $ cV25 } ), Nil)
	oStruV2Za := Nil
	oStruV2Zb := Nil
	oStruV6N  := Iif( lLaySimplif, FWFormStruct( 2, "V6N" ), Nil)
	oStruV6O  := Iif( lLaySimplif, FwFormStruct( 2, "V6O",{|x| AllTrim( x ) + "|" $ cV6O } ), Nil)
	oView     := FWFormView():New()

	oView:SetModel( oModel )

	If lLaySimplif

		oView:SetContinuousForm(.T.)

	EndIf

	/*--------------------------------------------------------------------------------------------
							Ordenação dos Campos de Acordo com o Layout
	---------------------------------------------------------------------------------------------*/
	If lLaySimplif .And. TAFColumnPos("V6O_DLOT")

		oStruV6O:SetProperty( "V6O_CODLOT"	, MVC_VIEW_ORDEM    , "01" )
		oStruV6O:SetProperty( "V6O_DLOT"	, MVC_VIEW_ORDEM    , "02" )
		oStruV6O:SetProperty( "V6O_TPLOT"	, MVC_VIEW_ORDEM    , "03" )
		oStruV6O:SetProperty( "V6O_DTPLOT"	, MVC_VIEW_ORDEM    , "04" ) 
		oStruV6O:SetProperty( "V6O_TPINSC"	, MVC_VIEW_ORDEM    , "05" )
		oStruV6O:SetProperty( "V6O_NRINSC"	, MVC_VIEW_ORDEM    , "06" )

		oStruV20:SetProperty( "V20_IDTPVL"	, MVC_VIEW_ORDEM    , "01" )
		oStruV20:SetProperty( "V20_DTPVL"	, MVC_VIEW_ORDEM    , "02" )
		oStruV20:SetProperty( "V20_DIDTPV"	, MVC_VIEW_ORDEM    , "03" )
		oStruV20:SetProperty( "V20_INDINC"	, MVC_VIEW_ORDEM    , "04" ) 
		oStruV20:SetProperty( "V20_VLFGTS"	, MVC_VIEW_ORDEM    , "05" )
		oStruV20:SetProperty( "V20_VRFGTS"	, MVC_VIEW_ORDEM    , "06" )

		oStruV22:SetProperty( "V22_IDTPVL"	, MVC_VIEW_ORDEM    , "01" )
		oStruV22:SetProperty( "V22_DTPVL"	, MVC_VIEW_ORDEM    , "02" )
		oStruV22:SetProperty( "V22_DIDTPV"	, MVC_VIEW_ORDEM    , "03" )
		oStruV22:SetProperty( "V22_INDINE"	, MVC_VIEW_ORDEM    , "04" ) 
		oStruV22:SetProperty( "V22_VLFGTS"	, MVC_VIEW_ORDEM    , "05" )
		oStruV22:SetProperty( "V22_VRFGTE"	, MVC_VIEW_ORDEM    , "06" )
		
	EndIf

	//Campos do Grupo Identificação do Evento de Retorno
	cCmpFil := "V2Z_ID|" + Iif( lLaySimplif, "V2Z_INDAPU|V2Z_PERAPU|", "V2Z_PERAPU|" )
	oStruV2Za := FWFormStruct( 2, "V2Z", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do Grupo Informações Relativas ao FGTS
	cCmpFil := "V2Z_NRRECI|V2Z_EXFGTS|"
	oStruV2Zb := FWFormStruct( 2, "V2Z", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_V2Za", oStruV2Za, "MODEL_V2Z" )
	oView:EnableTitleView( "VIEW_V2Za", STR0007 ) //"Identificação do Evento de Retorno"

	oView:AddField( "VIEW_V2Zb", oStruV2Zb, "MODEL_V2Z" )
	oView:EnableTitleView( "VIEW_V2Zb", STR0008 ) //"Informações Relativas ao FGTS"

	If lLaySimplif

		oView:AddGrid( "VIEW_V6N", oStruV6N, "MODEL_V6N" )
		oView:EnableTitleView( "VIEW_V6N", STR0021 ) //"Identificação do estabelecimento ou obra de construção civil

		oView:AddGrid( "VIEW_V6O", oStruV6O, "MODEL_V6O" )
		oView:EnableTitleView( "VIEW_V6O", STR0022 ) //"Identificação da lotação tributária

		oView:AddGrid( "VIEW_V20", oStruV20, "MODEL_V20" )

		oView:AddGrid( "VIEW_V21", oStruV21, "MODEL_V21" )

		oView:AddGrid( "VIEW_V22", oStruV22, "MODEL_V22" )
		oView:EnableTitleView( "VIEW_V22", STR0009 ) //Informações consolidadas das bases de cálculo e valores do FGTS de períodos anteriores

	Else // Tratamento Simplificado 1.0

		oView:AddGrid( "VIEW_V20", oStruV20, "MODEL_V20" )

		oView:AddGrid( "VIEW_V21", oStruV21, "MODEL_V21" )

		oView:AddGrid( "VIEW_V22", oStruV22, "MODEL_V22" )
		oView:EnableTitleView( "VIEW_V22", STR0009 ) //Informações consolidadas das bases de cálculo e valores do FGTS de períodos anteriores

		oView:AddGrid( "VIEW_V23", oStruV23, "MODEL_V23" )

		oView:AddGrid( "VIEW_V24", oStruV24, "MODEL_V24" )

		oView:AddGrid( "VIEW_V25", oStruV25, "MODEL_V25" )
		oView:EnableTitleView( "VIEW_V25", STR0010 ) //"Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores"

	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 20 )
	oView:CreateHorizontalBox( "PAINEL_INTERMEDIARIO", 20 )

	oView:CreateHorizontalBox( "PAINEL_INFERIOR", 60 )
	oView:CreateFolder( "FOLDER_INFERIOR", "PAINEL_INFERIOR" )

	If lLaySimplif
	
		oView:AddSheet( "FOLDER_INFERIOR", "ABA01", STR0008 ) //Informações relativas ao FGTS

		oView:CreateHorizontalBox( "V6N", 20,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateHorizontalBox( "V6O", 20,,, "FOLDER_INFERIOR", "ABA01" )
		
		oView:CreateHorizontalBox( "PAINEL_INFO_BASE_FGTS", 20,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateFolder( "FOLDER_INFO_BASE_FGTS", "PAINEL_INFO_BASE_FGTS" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA01", STR0019 ) //"Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração"

		oView:CreateHorizontalBox( "V20", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA02", STR0020 ) //"Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V21", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V22", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )

	Else

		oView:AddSheet( "FOLDER_INFERIOR", "ABA01", STR0011 ) //"Informações Relativas a Base de Cálculo de FGTS"

		oView:CreateHorizontalBox( "PAINEL_INFO_BASE_FGTS", 100,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateFolder( "FOLDER_INFO_BASE_FGTS", "PAINEL_INFO_BASE_FGTS" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA01", STR0012 ) //"Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração"

		oView:CreateHorizontalBox( "V20", 100,,, "FOLDER_INFO_BASE_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA02", STR0012 ) //"Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V21", 50,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V22", 50,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )

		oView:AddSheet( "FOLDER_INFERIOR", "ABA02", STR0014 ) //"Informações Relativas a Valores de FGTS"

		oView:CreateHorizontalBox( "PAINEL_INFO_VALOR_FGTS", 100,,, "FOLDER_INFERIOR", "ABA02" )
		oView:CreateFolder( "FOLDER_INFO_VALOR_FGTS", "PAINEL_INFO_VALOR_FGTS" )

		oView:AddSheet( "FOLDER_INFO_VALOR_FGTS", "ABA01", STR0015 ) //"Cálculo Consolidado dos Valores de FGTS a serem Depositados do Período de Apuração"

		oView:CreateHorizontalBox( "V23", 100,,, "FOLDER_INFO_VALOR_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_VALOR_FGTS", "ABA02", STR0016 ) //"Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V24", 50,,, "FOLDER_INFO_VALOR_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V25", 50,,, "FOLDER_INFO_VALOR_FGTS", "ABA02" )

	EndIf

	oView:SetOwnerView( "VIEW_V2Za", "PAINEL_SUPERIOR" )
	oView:SetOwnerView( "VIEW_V2Zb", "PAINEL_INTERMEDIARIO" )

	If lLaySimplif	

		oView:SetOwnerView( "VIEW_V6N", "V6N" )
		oView:SetOwnerView( "VIEW_V6O", "V6O" )
		oView:SetOwnerView( "VIEW_V20", "V20" )
		oView:SetOwnerView( "VIEW_V21", "V21" )
		oView:SetOwnerView( "VIEW_V22", "V22" )

	Else 

		oView:SetOwnerView( "VIEW_V20", "V20" )
		oView:SetOwnerView( "VIEW_V21", "V21" )
		oView:SetOwnerView( "VIEW_V22", "V22" )
		oView:SetOwnerView( "VIEW_V23", "V23" )
		oView:SetOwnerView( "VIEW_V24", "V24" )
		oView:SetOwnerView( "VIEW_V25", "V25" )

	EndIf

	oStruV2Za:RemoveField( "V2Z_ID" )

	If !lLaySimplif

		oStruV2Za:RemoveField( "V2Z_INDAPU" )
		oStruV20:RemoveField( "V20_INDINC" )
		oStruV20:RemoveField( "V20_VRFGTS" )
		oStruV22:RemoveField( "V22_INDINE" )
		oStruV22:RemoveField( "V22_VRFGTE" )
		oStruV22:RemoveField( "V20_DLOT"   )
		oStruV22:RemoveField( "V20_DTPLOT" )
		oStruV22:RemoveField( "V21_DLOT"   )
		oStruV22:RemoveField( "V21_DTPLOT" )
		oStruV22:RemoveField( "V22_DLOT"   )
		oStruV22:RemoveField( "V22_DTPLOT" )
		
	EndIf

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	:=	oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V2Z", "V2Z_VERSAO", xFunGetVer() )

			FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			TAFAltStat( "V2Z", " " )

			FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_DELETE

			FWFormCommit( oModel )

		EndIf

	End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Grv
@type			function
@description	Função de integração dos dados para o evento S-5013.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@param			cLayout	-	Nome do Layout que está sendo importado
@param			nOpc	-	Operação a ser executada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv	-	Filial do ERP para onde as informações devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return			lRet	-	Variável que indica se a importação foi realizada
@return			aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF521Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,;
					cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character,;
					cGrpTran as Character, cEmpEnv as Character, cFilEnv as Character, cXmlID as Character,;
					cEvtOri as Character, lMigrador as Logical, lDepGPE as Logical, cKey as Character,; 
					cMatrC9V as Character, lLaySmpTot as Logical )

	Local aChave     as array
	Local aIncons    as array
	Local aRules     as array
	Local aV20       as array
	Local aV20value  as array
	Local aV21       as array
	Local aV21value  as array
	Local aV22       as array
	Local aV22value  as array
	Local aV23       as array
	Local aV23value  as array
	Local aV24       as array
	Local aV24value  as array
	Local aV25       as array
	Local aV25value  as array
	Local aV2Z       as array
	Local aV2Zvalue  as array
	Local aV6N       as array
	Local aV6Nvalue  as array
	Local aV6O       as array
	Local aV6Ovalue  as array
	Local cCabec     as character
	Local cCmpsNoUpd as character
	Local cFilBkp    as character
	Local cFilGrv    as character
	Local cInconMsg  as character
	Local cPerRef    as character
	Local cRecibo    as character
	Local cString    as character
	Local cDslot     as character
	Local dDtLegado  as date
	Local dDtParam   as date
	Local lCanV20    as logical
	Local lCanV21    as logical
	Local lCanV22    as logical
	Local lCanV23    as logical
	Local lCanV24    as logical
	Local lCanV25    as logical
	Local lCanV2Z    as logical
    Local lCanV6N    as logical
	Local lCanV6O    as logical
	Local lRet       as logical
	Local nI         as numeric
	Local nSeqErrGrv as numeric
	Local oBulkV20   as object
	Local oBulkV21   as object
	Local oBulkV22   as object
	Local oBulkV23   as object
	Local oBulkV24   as object
	Local oBulkV25   as object
	Local oBulkV2Z   as object
	Local oBulkV6N   as object
	Local oBulkV6O   as object
	Local oModel     as object

	Private lVldModel	as logical
	Private oDados		as object

	Default cComplem  := ""
	Default cEmpEnv   := ""
	Default cEvtOri   := ""
	Default cFilEnv   := ""
	Default cFilEv    := ""
	Default cFilTran  := ""
	Default cGrpTran  := ""
	Default cKey      := ""
	Default cLayout   := ""
	Default cMatrC9V  := ""
	Default cOwner    := ""
	Default cPredeces := ""
	Default cXmlID    := ""
	Default lDepGPE   := .F.
	Default lMigrador := .F.
	Default nOpc      := 1
	Default nTafRecno := 0
	Default oXML      := Nil

	aChave     := {}
	aIncons    := {}
	aRules     := {}
	aV20       := {}
	aV20value  := {}
	aV21       := {}
	aV21value  := {}
	aV22       := {}
	aV22value  := {}
	aV23       := {}
	aV23value  := {}
	aV24       := {}
	aV24value  := {}
	aV25       := {}
	aV25value  := {}
	aV2Z       := {}
	aV2Zvalue  := {}
	aV6N       := {}
	aV6Nvalue  := {}
	aV6O       := {}
	aV6Ovalue  := {}
	cCabec     := "/eSocial/evtFGTS/"
	cCmpsNoUpd := "|V2Z_FILIAL|V2Z_ID|V2Z_VERSAO|V2Z_ATIVO|"
	cFilBkp    := ""
	cFilGrv    := ""
	cInconMsg  := ""
	cPerRef    := ""
	cRecibo    := ""
	cString    := ""
	cDslot     := ""
	dDtLegado  := SToD( "" )
	dDtParam   := GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) )
	lCanV20    := .F.
	lCanV21    := .F.
	lCanV22    := .F.
	lCanV23    := .F.
	lCanV24    := .F.
	lCanV25    := .F.
	lCanV2Z    := .F.
    lCanV6N    := .F.
	lCanV6O    := .F.
	lRet       := .F.
	lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	nI         := 0
	nSeqErrGrv := 0
	oBulkV20   := Nil
	oBulkV21   := Nil
	oBulkV22   := Nil
	oBulkV23   := Nil
	oBulkV24   := Nil
	oBulkV25   := Nil
	oBulkV2Z   := Nil
	oBulkV6N   := Nil
	oBulkV6O   := Nil
	oDados     := {}
	oModel     := Nil

	If Type("lLaySmpTot") <> "L"
		lLaySmpTot	:= taflayEsoc("S_01_00_00")
	EndIf

	oDados := oXML

	If !TAFAlsInDic( "V2Z" )

		cString := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )

	EndIf

	Begin Transaction

		cRecibo := FTAFGetVal( cCabec + "infoFGTS/nrRecArqBase", "C", .F.,, .T. )

		If SearchRec( cRecibo, @cFilGrv, @dDtLegado )
			cFilBkp := cFilAnt
			cFilAnt := cFilGrv
		EndIf

		cPeriodo := AllTrim(StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,, .T. ), "-", "" ))

		If Len(cPeriodo) == 6 // Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
			cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
		EndIf

		aAdd( aChave, { "C", "V2Z_PERAPU", cPeriodo, .T. } )

		//Função para validar se a operação desejada pode ser realizada
		If FTAFVldOpe( "V2Z", 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA521", cCmpsNoUpd )

			//Carrego array com os campos De/Para de gravação das informações
			aRules := TAF521Rul()

			//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
			If nOpc <> 5

				aV2Zvalue := {}

				AADD( aV2Zvalue, xFilial("T2V") ) /*"V2Z_FILIAL"*/
				AAdd( aV2Z, {"V2Z_FILIAL"})

				AADD( aV2Zvalue, TAFGeraID("TAF") ) /*"V2Z_ID"*/
				AAdd( aV2Z, {"V2Z_ID"})

				AADD( aV2Zvalue, xFunGetVer() ) /*"V2Z_VERSAO"*/
				AAdd( aV2Z, {"V2Z_VERSAO"})

				AADD( aV2Zvalue, "1" ) /*"V2Z_VERSAO"*/
				AAdd( aV2Z, {"V2Z_ATIVO"})

				AADD( aV2Zvalue, cFilAnt ) /*"V2Z_FILGRV"*/
				AADD( aV2Z, {"V2Z_FILGRV"})

				If nOpc == 3
					AADD( aV2Zvalue, dDtParam ) /*"V2Z_SITPAR"*/
					AADD( aV2Z, {"V2Z_SITPAR"})
				EndIf

				//Laço no aRules para gravar as informações
				For nI := 1 to Len( aRules )
					AADD( aV2Zvalue, FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
					AADD( aV2Z, { aRules[nI,01] }) 
				Next nI

				If !lCanV2Z
					lCanV2Z := FwBulk():CanBulk()
					oBulkV2Z := FwBulk():New(RetSQLName("V2Z"))
					oBulkV2Z:SetFields(aV2Z)
				EndIf
						
				oBulkV2Z:AddData(aV2Zvalue)
				TAFCONOUT("V2Z" + oBulkV2Z:GetError())

				If lLaySmpTot

					/*----------------------------------------
					V6N - Identificação do estabelecimento ou obra de construção civil. 
					------------------------------------------*/
					nV6N := 1
					cV6NPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]"

					While oDados:xPathHasNode( cV6NPath )

						aV6Nvalue := {}

						AADD( aV6Nvalue, aV2Zvalue[1] ) /*"V6N_FILIAL"*/
						AAdd( aV6N, {"V6N_FILIAL"})

						AADD( aV6Nvalue, aV2Zvalue[2] ) /*"V6N_ID"*/
						AAdd( aV6N, {"V6N_ID"})

						AADD( aV6Nvalue, aV2Zvalue[3] ) /*"V6N_VERSAO"*/
						AAdd( aV6N, {"V6N_VERSAO"})

						If oDados:xPathHasNode( cV6NPath + "/tpInsc" )
							AADD(aV6Nvalue, FTAFGetVal( cV6NPath + "/tpInsc", "C", .F., @aIncons, .F. ) ) /*"V6N_TPINSC"*/
							AADD( aV6N, {"V6N_TPINSC"})
						EndIf

						If oDados:xPathHasNode( cV6NPath + "/nrInsc" )
							AADD( aV6Nvalue, FTAFGetVal( cV6NPath + "/nrInsc", "C", .F., @aIncons, .F. ) ) /*"V6N_NRINSC"*/
							AADD( aV6N, {"V6N_NRINSC"})
						EndIf

						If !lCanV6N

							lCanV6N := FwBulk():CanBulk()
							oBulkV6N := FwBulk():New(RetSQLName("V6N"))
							oBulkV6N:SetFields(aV6N)

						EndIf

						oBulkV6N:AddData(aV6Nvalue)
						TAFCONOUT("V6N" + oBulkV6N:GetError())

						/*----------------------------------------
						V6O - Identificação do estabelecimento ou obra de construção civil. 
						------------------------------------------*/
						nV6O := 1
						cV6OPath := cV6NPath + "/ideLotacao[" + cValToChar( nV6O ) + "]"
						
						While oDados:xPathHasNode( cV6OPath )

							aV6Ovalue := {}

							AADD( aV6Ovalue, aV2Zvalue[1] ) /*"V6O_FILIAL"*/
							AAdd( aV6O, {"V6O_FILIAL"})

							AADD( aV6Ovalue, aV2Zvalue[2] ) /*"V6O_ID"*/
							AAdd( aV6O, {"V6O_ID"})

							AADD( aV6Ovalue, aV2Zvalue[3] ) /*"V6O_VERSAO"*/
							AAdd( aV6O, {"V6O_VERSAO"})

							AADD( aV6Ovalue, aV6Nvalue[4] ) /*"V6O_ESTTP"*/
							AAdd( aV6O, {"V6O_ESTTP"})

							AADD( aV6Ovalue, aV6Nvalue[5] ) /*"V6O_ESTNRI"*/
							AAdd( aV6O, {"V6O_ESTNRI"})

							If oDados:xPathHasNode( cV6OPath + "/codLotacao" )
							    
								If TAFColumnPos("V6O_DLOT")

									AADD( aV6Ovalue, FTAFGetVal( cV6OPath + "/codLotacao", "C", .F., @aIncons, .F. ))  /*"V6O_DLOT"*/
									AAdd( aV6O, {"V6O_DLOT"})

								Else
									cCodLot := FGetIDInt( "codLotacao", "", cV6OPath + "/codLotacao",,,, @cInconMsg, @nSeqErrGrv )
									
									If Empty(cCodLot)
										AADD( aV6Ovalue,  substr(getSx8Num("V6O","V6O_ID"), 31) )  /*"V6O_CODLOT"*/
									Else
										AADD( aV6Ovalue, FGetIDInt( "codLotacao", "", cV6OPath + "/codLotacao",,,, @cInconMsg, @nSeqErrGrv ))
									EndIf

									AAdd( aV6O, {"V6O_CODLOT"})

								EndIf

							EndIf

							If oDados:xPathHasNode( cV6OPath + "/tpLotacao" )

								If TAFColumnPos("V6O_DTPLOT")

									AADD( aV6Ovalue, FTAFGetVal( cV6OPath + "/tpLotacao", "C", .F., @aIncons ) ) /*"V6O_DTPLOT"*/
									AAdd( aV6O, {"V6O_DTPLOT"})

								Else

									AADD( aV6Ovalue, FGetIDInt( "tpLotacao", "", cV6OPath + "/tpLotacao",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V6O_TPLOT"*/
									AAdd( aV6O, {"V6O_TPLOT"})

								EndIf

							EndIf

							If oDados:xPathHasNode( cV6OPath + "/tpInsc" )
								AADD( aV6Ovalue, FTAFGetVal( cV6OPath + "/tpInsc", "C", .F., @aIncons, .F. ) ) /*"V6O_TPINSC"*/
							Else
								AADD( aV6Ovalue, "" ) /*"V6O_TPINSC"*/
							EndIf

							AAdd( aV6O, {"V6O_TPINSC"})

							If oDados:xPathHasNode( cV6OPath + "/nrInsc" )
								AADD( aV6Ovalue, FTAFGetVal( cV6OPath + "/nrInsc", "C", .F., @aIncons, .F. ) ) /*"V6O_NRINSC"*/
							Else
								AADD( aV6Ovalue, "" ) /*"V6O_NRINSC"*/
							EndIf
							
							AAdd( aV6O, {"V6O_NRINSC"})
							
							If !lCanV6O

								lCanV6O := FwBulk():CanBulk()
								oBulkV6O := FwBulk():New(RetSQLName("V6O"))
								oBulkV6O:SetFields(aV6O)

							EndIf

							oBulkV6O:AddData(aV6Ovalue)
							TAFCONOUT("V6O" + oBulkV6O:GetError())

							/*----------------------------------------
							V20 - Informações referentes a bases de cálculo e valores do FGTS no estabelecimento/lotação.
							------------------------------------------*/
							nV20 := 1
							cV20Path := cV6OPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

							While oDados:xPathHasNode( cV20Path )
		
								aV20value := {}

								AADD( aV20value, aV2Zvalue[1] ) /*"V20_FILIAL"*/
								AAdd( aV20, {"V20_FILIAL"})

								AADD( aV20value, aV2Zvalue[2] ) /*"V20_ID"*/
								AAdd( aV20, {"V20_ID"})

								AADD( aV20value, aV2Zvalue[3] ) /*"V20_VERSAO"*/
								AAdd( aV20, {"V20_VERSAO"})

								AADD( aV20value, aV6Nvalue[4] ) /*"V20_ESTTP"*/
								AAdd( aV20, {"V20_ESTTP"})

								AADD( aV20value, aV6Nvalue[5] ) /*"V20_ESTNRI"*/
								AAdd( aV20, {"V20_ESTNRI"})

								If TAFColumnPos("V20_DLOT")

									AADD( aV20value, aV6Ovalue[6] ) /*"V2O_DLOT"*/
									AAdd( aV20, {"V20_DLOT"})
					
									AADD( aV20value, aV6Ovalue[7] ) /*"V20_DTPLOT"*/
									AAdd( aV20, {"V20_DTPLOT"})

								Else

									AADD( aV20value, aV6Ovalue[6] ) /*"V2O_CODDLOT"*/
									AAdd( aV20, {"V20_CODLOT"})
					
									AADD( aV20value, aV6Ovalue[7] ) /*"V20_TPLOT"*/
									AAdd( aV20, {"V20_TPLOT"})

								EndIf	

								AADD( aV20value, aV6Ovalue[8] ) /*"V2O_TPINSC"*/
								AAdd( aV20, {"V20_TPINSC"})

								AADD( aV20value, aV6Ovalue[9] ) /*"V2O_NRINSC"*/
								AAdd( aV20, {"V20_NRINSC"})

								If oDados:xPathHasNode( cV20Path + "/tpValor" ) 

									If TAFColumnPos("V20_DTPVL")

										AADD( aV20value, FTAFGetVal( cV20Path + "/tpValor", "C", .F., @aIncons, .F. ) ) /*"V20_DTPVL"*/
										AAdd( aV20, {"V20_DTPVL"})
									
									Else

										AADD( aV20value, FGetIDInt( "tpValorE", , cV20Path + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V20_IDTPVL"*/
										AAdd( aV20, {"V20_IDTPVL"})

									EndIf

								EndIf

								If oDados:xPathHasNode( cV20Path + "/indIncid" )
									AADD( aV20value, FTAFGetVal( cV20Path + "/indIncid", "C", .F., @aIncons, .F. ) ) /*"V20_INDINC"*/
								Else
									AADD( aV20value, "" ) /*"V20_INDINC"*/
								EndIf

								AAdd( aV20, {"V20_INDINC"})

								If oDados:xPathHasNode( cV20Path + "/baseFGTS" )
									AADD( aV20value, FTAFGetVal( cV20Path + "/baseFGTS", "N", .F., @aIncons, .F. ) ) /*"V20_VLFGTS"*/
								Else
									AADD( aV20value, "" ) /*"V20_VLFGTS"*/
								EndIf

								AAdd( aV20, {"V20_VLFGTS"})
					
								If oDados:xPathHasNode( cV20Path + "/vrFGTS" )
									AADD( aV20value, FTAFGetVal( cV20Path + "/vrFGTS", "N", .F., @aIncons, .F. ) ) /*"V20_VRFGTS"*/
								Else
									AADD( aV20value, "" ) /*"V20_VRFGTS"*/
								EndIf

								AAdd( aV20, {"V20_VRFGTS"})
								
								If !lCanV20

									lCanV20 := FwBulk():CanBulk()
									oBulkV20 := FwBulk():New(RetSQLName("V20"))
									oBulkV20:SetFields(aV20)

								EndIf

								oBulkV20:AddData(aV20value)
								TAFCONOUT("V20" + oBulkV20:GetError())

								nV20 ++
								cV20Path := cV6OPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"
								
							EndDo	

							/*----------------------------------------
							V21 - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
							------------------------------------------*/
							nV21 := 1
							cV21Path := cV6OPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

							While oDados:xPathHasNode( cV21Path )

								aV21value := {}

								AADD( aV21value, aV2Zvalue[1] ) /*"V21_FILIAL"*/
								AAdd( aV21, {"V21_FILIAL"})

								AADD( aV21value, aV2Zvalue[2] ) /*"V21_ID"*/
								AAdd( aV21, {"V21_ID"})

								AADD( aV21value, aV2Zvalue[3] ) /*"V21_VERSAO"*/
								AAdd( aV21, {"V21_VERSAO"})

								AADD( aV21value, aV6Nvalue[4] ) /*"V21_ESTTP"*/
								AAdd( aV21, {"V21_ESTTP"})

								AADD( aV21value, aV6Nvalue[5] ) /*"V21_ESTNRI"*/
								AAdd( aV21, {"V21_ESTNRI"})

								If TAFColumnPos("V21_DLOT")

									AADD( aV21value, aV6Ovalue[6] ) /*"V21_DLOT"*/
									AAdd( aV21, {"V21_DLOT"})	

									AADD( aV21value, aV6Ovalue[7] ) /*"V21_DTPDLOT"*/
									AAdd( aV21, {"V21_DTPLOT"})

								Else

									AADD( aV21value, aV6Ovalue[6] ) /*"V21_CODLOT"*/
									AAdd( aV21, {"V21_CODDLOT"})	

									AADD( aV21value, aV6Ovalue[7] ) /*"V21_TPDLOT"*/
									AAdd( aV21, {"V21_TPLOT"})

								EndIf	

								AADD( aV21value, aV6Ovalue[8] ) /*"V21_TPINSC"*/
								AAdd( aV21, {"V21_TPINSC"})

								AADD( aV21value, aV6Ovalue[9] ) /*"V21_NRINSC"*/
								AAdd( aV21, {"V21_NRINSC"})

								If oDados:xPathHasNode( cV21Path + "/perRef" )

									cPerRef := StrTran( FTAFGetVal( cV21Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
									cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
									AADD( aV21value, cPerRef ) /*"V21_PERREF"*/
									AAdd( aV21, {"V21_PERREF"})

								EndIf

								If oDados:xPathHasNode( cV21Path + "/tpAcConv" )
									AADD( aV21value, FTAFGetVal( cV21Path + "/tpAcConv", "C", .F., @aIncons, .F. ) ) /*"V21_TPCONV"*/
									AAdd( aV21, {"V21_TPCONV"})
								EndIf

								If !lCanV21

									lCanV21 := FwBulk():CanBulk()
									oBulkV21 := FwBulk():New(RetSQLName("V21"))
									oBulkV21:SetFields(aV21)

								EndIf

								oBulkV21:AddData(aV21value)
								TAFCONOUT("V21" + oBulkV21:GetError())

								/*----------------------------------------
								V22 - Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
								------------------------------------------*/
								nV22 := 1
								cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

								While oDados:xPathHasNode( cV22Path )

									aV22value := {}

									AADD( aV22value, aV2Zvalue[1] ) /*"V22_FILIAL"*/
									AAdd( aV22, {"V22_FILIAL"})

									AADD( aV22value, aV2Zvalue[2] ) /*"V22_ID"*/
									AAdd( aV22, {"V22_ID"})

									AADD( aV22value, aV2Zvalue[3] ) /*"V22_VERSAO"*/
									AAdd( aV22, {"V22_VERSAO"})

									AADD( aV22value, aV6Nvalue[4] ) /*"V22_ESTTP"*/
									AAdd( aV22, {"V22_ESTTP"})

									AADD( aV22value, aV6Nvalue[5] ) /*"V22_ESTNRI"*/
									AAdd( aV22, {"V22_ESTNRI"})

									If TAFColumnPos("V22_DLOT")

										AADD( aV22value, aV6Ovalue[6] ) /*"V22_DLOT"*/
										AAdd( aV22, {"V22_DLOT"})

										cDslot += aV6Ovalue[6]

										AADD( aV22value, aV6Ovalue[7] ) /*"V22_DTPDLOT"*/
										AAdd( aV22, {"V22_DTPLOT"})

										cDslot += aV6Ovalue[7]

									Else 

										AADD( aV22value, aV6Ovalue[6] ) /*"V22_CODDLOT"*/
										AAdd( aV22, {"V22_CODDLOT"})

										AADD( aV22value, aV6Ovalue[7] ) /*"V22_TPDLOT"*/
										AAdd( aV22, {"V22_TPLOT"})

									EndIf	

									AADD( aV22value, aV6Ovalue[8] ) /*"V22_TPINSC"*/
									AAdd( aV22, {"V22_TPINSC"})

									AADD( aV22value, aV6Ovalue[9] ) /*"V22_NRINSC"*/
									AAdd( aV22, {"V22_NRINSC"})
									
									If oDados:xPathHasNode( cV22Path + "/tpValorE" )

										If TafColumnPos("V22_DTPVL")

											AADD( aV22value, FTAFGetVal( cV22Path + "/tpValorE", "C", .F., @aIncons, .F. ) ) /*"V22_DTPVL"*/
											AAdd( aV22, {"V22_DTPVL"})
											cDslot += FTAFGetVal( cV22Path + "/tpValorE", "C", .F., @aIncons, .F. )
										Else

											AADD( aV22value, FGetIDInt( "tpValorE", , cV22Path + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V22_IDTPVL"*/
											AAdd( aV22, {"V22_IDTPVL"})

										EndIf

									EndIf

									If TafColumnPos("V22_DTPVL")
										AADD( aV22value, cDslot ) /*"V22_DTPVL"*/
										AAdd( aV22, {"V22_DSLOT"})
									Endif

									If oDados:xPathHasNode( cV22Path + "/indIncidE" )
										AADD( aV22value, FTAFGetVal( cV22Path + "/indIncidE", "C", .F., @aIncons, .F. ) ) /*"V22_INDINE"*/
										AAdd( aV22, {"V22_INDINE"})
									EndIf

									If oDados:xPathHasNode( cV22Path + "/baseFGTSE" )
										AADD( aV22value, FTAFGetVal( cV22Path + "/baseFGTSE", "N", .F., @aIncons, .F. ) ) /*"V22_VLFGTS"*/
										AAdd( aV22, {"V22_VLFGTS"})
									EndIf

									If oDados:xPathHasNode( cV22Path + "/vrFGTSE" )
										AADD( aV22value, FTAFGetVal( cV22Path + "/vrFGTSE", "N", .F., @aIncons, .F. ) ) /*"V22_VRFGTE"*/
										AAdd( aV22, {"V22_VRFGTE"})
									EndIf

									AADD( aV22value, aV21value[10] ) /*"V22_PERREF"*/
									AAdd( aV22, {"V22_PERREF"})

									AADD( aV22value, aV21value[11] ) /*"V22_TPCONV"*/
									AAdd( aV22, {"V22_TPCONV"})

									If !lCanV22

										lCanV22 := FwBulk():CanBulk()
										oBulkV22 := FwBulk():New(RetSQLName("V22"))
										oBulkV22:SetFields(aV22)

									EndIf

									oBulkV22:AddData(aV22value)
									TAFCONOUT("V22" + oBulkV22:GetError())

									nV22 ++
									cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

								EndDo

								nV21 ++
								cV21Path := cV6OPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"
								
							EndDo

							nV6O ++
							cV6OPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]/ideLotacao[" + cValToChar( nV6O ) + "]"

						EndDo

						nV6N ++
						cV6NPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]"

					EndDo

				Else

					/*----------------------------------------
					V20 - Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
					------------------------------------------*/
					nV20 := 1
					cV20Path := cCabec + "infoFGTS/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

					While oDados:xPathHasNode( cV20Path )

						aV20value := {}

						AADD( aV20value, aV2Zvalue[1] ) /*"V20_FILIAL"*/
						AAdd( aV20, {"V20_FILIAL"})

						AADD( aV20value, aV2Zvalue[2] ) /*"V20_ID"*/
						AAdd( aV20, {"V20_ID"})

						AADD( aV20value, aV2Zvalue[3] ) /*"V20_VERSAO"*/
						AAdd( aV20, {"V20_VERSAO"})

						If oDados:xPathHasNode( cV20Path + "/tpValor" ) 

							If TAFColumnPos("V20_DTPVL")

								AADD( aV20value, FTAFGetVal( cV20Path + "/tpValor", "C", .F., @aIncons, .F. ) ) /*"V20_DTPVL"*/
								AAdd( aV20, {"V20_DTPVL"})
							
							Else

								AADD( aV20value, FGetIDInt( "tpValorE", , cV20Path + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V20_IDTPVL"*/
								AAdd( aV20, {"V20_IDTPVL"})

							EndIf

						EndIf

						If oDados:xPathHasNode( cV20Path + "/baseFGTS" )
							AADD( aV20value /*"V20_VLFGTS"*/, FTAFGetVal( cV20Path + "/baseFGTS", "N", .F., @aIncons, .F. ) )
							AAdd( aV20, {"V20_VLFGTS"})
						EndIf

						If !lCanV20
							lCanV20 := FwBulk():CanBulk()
							oBulkV20 := FwBulk():New(RetSQLName("V20"))
							oBulkV20:SetFields(aV20)
						EndIf
						
						oBulkV20:AddData(aV20value)
						TAFCONOUT("V20" + oBulkV20:GetError())

						nV20 ++
						cV20Path := cCabec + "infoFGTS/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

					EndDo

					/*----------------------------------------
					V21 - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
					------------------------------------------*/
					nV21 := 1
					cV21Path := cCabec + "infoFGTS/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

					While oDados:xPathHasNode( cV21Path )

						aV21value := {}

						AADD( aV21value, aV2Zvalue[1] ) /*"V21_FILIAL"*/
						AAdd( aV21, {"V21_FILIAL"})

						AADD( aV21value, aV2Zvalue[2] ) /*"V21_ID"*/
						AAdd( aV21, {"V21_ID"})

						AADD( aV21value, aV2Zvalue[3] ) /*"V21_VERSAO"*/
						AAdd( aV21, {"V21_VERSAO"})

						If oDados:xPathHasNode( cV21Path + "/perRef" )

							cPerRef := StrTran( FTAFGetVal( cV21Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
							cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
							AADD( aV21value /*"V21_PERREF"*/, cPerRef )
							AAdd( aV21, {"V21_PERREF"})

						EndIf

						If !lCanV21

							lCanV21 := FwBulk():CanBulk()
							oBulkV21 := FwBulk():New(RetSQLName("V21"))
							oBulkV21:SetFields(aV21)

						EndIf

						oBulkV21:AddData(aV21value)
						TAFCONOUT("V21" + oBulkV21:GetError())
						
						/*----------------------------------------
						V22 - Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
						------------------------------------------*/
						nV22 := 1
						cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

						While oDados:xPathHasNode( cV22Path )

							aV22value := {}

							AADD( aV22value, aV2Zvalue[1] ) /*"V22_FILIAL"*/
							AAdd( aV22, {"V22_FILIAL"})

							AADD( aV22value, aV2Zvalue[2] ) /*"V22_ID"*/
							AAdd( aV22, {"V22_ID"})

							AADD( aV22value, aV2Zvalue[3] ) /*"V22_VERSAO"*/
							AAdd( aV22, {"V22_VERSAO"})

							If oDados:xPathHasNode( cV22Path + "/tpValorE" )

								If TafColumnPos("V22_DTPVL")

									AADD( aV22value, FTAFGetVal( cV22Path + "/tpValorE", "C", .F., @aIncons, .F. ) ) /*"V22_DTPVL"*/
									AAdd( aV22, {"V22_DTPVL"})

								Else

									AADD( aV22value, FGetIDInt( "tpValorE", , cV22Path + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V22_IDTPVL"*/
									AAdd( aV22, {"V22_IDTPVL"})

								EndIf

							EndIf

							If oDados:xPathHasNode( cV22Path + "/baseFGTSE" )
								AADD( aV22value /*"V22_VLFGTS"*/, FTAFGetVal( cV22Path + "/baseFGTSE", "N", .F., @aIncons, .F. ) )
								AAdd( aV22, {"V22_VLFGTS"})
							EndIf

							AADD( aV22value, aV21value[4] ) /*"V22_PERREF"*/
							AAdd( aV22, {"V22_PERREF"})

							If !lCanV22

								lCanV22 := FwBulk():CanBulk()
								oBulkV22 := FwBulk():New(RetSQLName("V22"))
								oBulkV22:SetFields(aV22)

							EndIf

							oBulkV22:AddData(aV22value)
							TAFCONOUT("V22" + oBulkV22:GetError())

							nV22 ++
							cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

						EndDo

						nV21 ++
						cV21Path := cCabec + "infoFGTS/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

					EndDo

					/*----------------------------------------
					V23 - Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
					------------------------------------------*/
					nV23 := 1
					cV23Path := cCabec + "/infoFGTS/infoDpsFGTS/dpsPerApur[" + cValToChar( nV23 ) + "]"

					While oDados:xPathHasNode( cV23Path )

						aV23value := {}

						AADD( aV23value, aV2Zvalue[1] ) /*"V23_FILIAL"*/
						AAdd( aV23, {"V23_FILIAL"})

						AADD( aV23value, aV2Zvalue[2] ) /*"V23_ID"*/
						AAdd( aV23, {"V23_ID"})

						AADD( aV23value, aV2Zvalue[3] ) /*"V23_VERSAO"*/
						AAdd( aV23, {"V23_VERSAO"})

						If oDados:xPathHasNode( cV23Path + "/tpDps" )

							If TafColumnPos("V23_DTPDP")

								AADD( aV23value, FTAFGetVal( cV23Path + "/tpDps", "N", .F., @aIncons, .F. ) ) /*"V23_DTPDP"*/
								AAdd( aV23, {"V23_DTPDP"})

							Else

								AADD( aV23value, FGetIDInt( "tpDpsE", "", cV23Path + "/tpDps",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V23_IDTPDP"*/
								AAdd( aV23, {"V23_IDTPDP"})

							EndIf

						EndIf

						If oDados:xPathHasNode( cV23Path + "/vrFGTS" )
							AADD( aV23value /*"V23_VLFGTS"*/, FTAFGetVal( cV23Path + "/vrFGTS", "N", .F., @aIncons, .F. ) )
							AAdd( aV23, {"V23_VLFGTS"})
						EndIf

						If !lCanV23

							lCanV23 := FwBulk():CanBulk()
							oBulkV23 := FwBulk():New(RetSQLName("V23"))
							oBulkV23:SetFields(aV23)

						EndIf

						oBulkV23:AddData(aV23value)
						TAFCONOUT("V23" + oBulkV23:GetError())

						nV23 ++
						cV23Path := cCabec + "/infoFGTS/infoDpsFGTS/dpsPerApur[" + cValToChar( nV23 ) + "]"

					EndDo

					/*----------------------------------------
					V24 - Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
					------------------------------------------*/
					nV24 := 1
					cV24Path := cCabec + "infoFGTS/infoDpsFGTS/infoDpsPerAntE[" + cValToChar( nV24 ) + "]"

					While oDados:xPathHasNode( cV24Path )

						aV24value := {}

						AADD( aV24value, aV2Zvalue[1] ) /*"V24_FILIAL"*/
						AAdd( aV24, {"V24_FILIAL"})

						AADD( aV24value, aV2Zvalue[2] ) /*"V24_ID"*/
						AAdd( aV24, {"V24_ID"})

						AADD( aV24value, aV2Zvalue[3] ) /*"V24_VERSAO"*/
						AAdd( aV24, {"V24_VERSAO"})

						If oDados:xPathHasNode( cV24Path + "/perRef" )

							cPerRef := StrTran( FTAFGetVal( cV24Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
							cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
							AADD( aV24value /*"V24_PERREF"*/, cPerRef )
							AAdd( aV24, {"V24_PERREF"})

						EndIf

						If !lCanV24

							lCanV24 := FwBulk():CanBulk()
							oBulkV24 := FwBulk():New(RetSQLName("V24"))
							oBulkV24:SetFields(aV24)

						EndIf

						oBulkV24:AddData(aV24value)
						TAFCONOUT("V24" + oBulkV24:GetError())
						
						/*----------------------------------------
						V25 - Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
						------------------------------------------*/
						nV25 := 1
						cV25Path := cV24Path + "/dpsPerAntE[" + cValToChar( nV25 ) + "]"

						While oDados:xPathHasNode( cV25Path )

							aV25value := {}

							AADD( aV25value, aV2Zvalue[1] ) /*"V25_FILIAL"*/
							AAdd( aV25, {"V25_FILIAL"})

							AADD( aV25value, aV2Zvalue[2] ) /*"V25_ID"*/
							AAdd( aV25, {"V25_ID"})

							AADD( aV25value, aV2Zvalue[3] ) /*"V25_VERSAO"*/
							AAdd( aV25, {"V25_VERSAO"})

							If oDados:xPathHasNode( cV25Path + "/tpDpsE" )

								If TafColumnPos("V25_DTPDP")

									AADD( aV25value /*"V25_DTPDP"*/, FTAFGetVal( cV24Path + "/tpDpsE", "C", .F., @aIncons, .F. ) )
									AAdd( aV25, {"V25_DTPDP"})

								Else

									AADD( aV25value, FGetIDInt( "tpDpsE", "", cV25Path + "/tpDpsE",,,, @cInconMsg, @nSeqErrGrv ) ) /*"V25_IDTPDP"*/
									AAdd( aV25, {"V25_IDTPDP"})

								EndIf

							EndIf

							If oDados:xPathHasNode( cV25Path + "/vrFGTSE" )
								AADD( aV25value /*"V25_VLFGTS"*/, FTAFGetVal( cV25Path + "/vrFGTSE", "N", .F., @aIncons, .F. ) )
								AAdd( aV25, {"V25_VLFGTS"})
							EndIf

							AADD( aV25value, aV24value[4] ) /*"V24_PERREF"*/
							AAdd( aV25, {"V25_PERREF"})

							nV25 ++
							cV25Path := cV24Path + "/dpsPerAntE[" + cValToChar( nV25 ) + "]"
							
							If !lCanV25

								lCanV25 := FwBulk():CanBulk()
								oBulkV25 := FwBulk():New(RetSQLName("V25"))
								oBulkV25:SetFields(aV25)

							EndIf

							oBulkV25:AddData(aV25value)
							TAFCONOUT("V25" + oBulkV25:GetError())

						EndDo

						nV24 ++
						cV24Path := cCabec + "infoFGTS/infoDpsFGTS/infoDpsPerAntE[" + cValToChar( nV24 ) + "]"

					EndDo

				EndIf

			EndIf	

		EndIf

	    If lCanV2Z

			oBulkV2Z:Flush()
			oBulkV2Z:Close()
			oBulkV2Z:Destroy()
			oBulkV2Z := nil

		EndIf

		If lCanV6N

			oBulkV6N:Flush()
			oBulkV6N:Close()
			oBulkV6N:Destroy()
			oBulkV6N := nil

		EndIf
		
		If lCanV6O

			oBulkV6O:Flush()
			oBulkV6O:Close()
			oBulkV6O:Destroy()
			oBulkV6O := nil

		EndIf
		
		If lCanV20

			oBulkV20:Flush()
			oBulkV20:Close()
			oBulkV20:Destroy()
			oBulkV20 := nil

		EndIf

		If lCanV21

			oBulkV21:Flush()
			oBulkV21:Close()
			oBulkV21:Destroy()
			oBulkV21 := nil

		EndIf

		If lCanV22

			oBulkV22:Flush()
			oBulkV22:Close()
			oBulkV22:Destroy()
			oBulkV22 := nil

		EndIf

		If lCanV23

			oBulkV23:Flush()
			oBulkV23:Close()
			oBulkV23:Destroy()
			oBulkV23 := nil

		EndIf

		If lCanV24

			oBulkV24:Flush()
			oBulkV24:Close()
			oBulkV24:Destroy()
			oBulkV24 := nil

		EndIf

		If lCanV25

			oBulkV25:Flush()
			oBulkV25:Close()
			oBulkV25:Destroy()
			oBulkV25 := nil

		EndIf

		lRet := .T.
			
		If !( Empty( cFilBkp ) )
			cFilAnt := cFilBkp
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
/*/{Protheus.doc} TAF521Rul
@type			function
@description	Regras para gravação das informações do Evento S-5013 do eSocial
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF521Rul()

	Local aRull		:= {}
	Local aIncons	:= {}
	Local cCabec	:= "/eSocial/evtFGTS/"
	Local cPeriodo	:= AllTrim(StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,@aIncons, .T. ), "-", "" ))

	If Len(cPeriodo) == 6 // Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
		cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
	EndIf

	If lLaySimplif
		aAdd( aRull, { "V2Z_INDAPU", FTAFGetVal( cCabec + "ideEvento/indApuracao"	, "C", .F.,@aIncons, .T. ), "C", .T. } )
	EndIf

	aAdd( aRull, { "V2Z_PERAPU", cPeriodo																  , "C", .T. } )
	aAdd( aRull, { "V2Z_NRRECI", FTAFGetVal( cCabec + "infoFGTS/nrRecArqBase"	, "C", .F.,@aIncons, .T. ), "C", .T. } )
	aAdd( aRull, { "V2Z_EXFGTS", FTAFGetVal( cCabec + "infoFGTS/indExistInfo"	, "C", .F.,@aIncons, .T. ), "C", .T. } )

Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Xml
@type			function
@description	Função de geração do XML para o Evento S-5013.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@return			cXml	-	Estrutura do XML do Layout S-5013
/*/
//---------------------------------------------------------------------
Function TAF521Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical)

	Local aMensal    as array
	Local cCodLot    as character
	Local cLayout    as character
	Local cReg       as character
	Local cTpDep     as character
	Local cTpLot     as character
	Local cTpValor   as character
	Local cXmIdeLot  as character
	Local cXml       as character
	Local cXmlBsAntE as character
	Local cXmlBsApur as character
	Local cXmlIfBsAn as character
	Local cXmlIfBsFG as character
	Local lSeekV20   as logical
	Local lSeekV21   as logical
	Local lSeekV23   as logical
	Local lSeekV24   as logical
	Local nIndex     as numeric
	Local nIndexV6O  as numeric

	Default cAlias   	:= "V2Z"
	Default lJob   		:= .F.
	Default nRecno   	:= 0
	Default nOpc   		:= 0
	
	aMensal    := {}
	cCodLot    := ""
	cLayout    := "5013"
	cReg       := "FGTS"
	cTpDep     := ""
	cTpLot     := ""
	cTpValor   := ""
	cXmIdeLot  := ""
	cXml       := ""
	cXmlBsAntE := ""
	cXmlBsApur := ""
	cXmlIfBsAn := ""
	cXmlIfBsFG := ""
	lSeekV20   := .F.
	lSeekV21   := .F.
	lSeekV23   := .F.
	lSeekV24   := .F.
	nIndex     := 0
	nIndexV6O  := 0

	If __aPicCache == Nil
        __aPicCache := {}
    EndIf

	cXml 		+= "<infoFGTS>"
	cXml 		+= xTafTag("nrRecArqBase", V2Z->V2Z_NRRECI,, .F.)
	cXml 		+= xTafTag("indExistInfo", V2Z->V2Z_EXFGTS,, .F.)

	If lLaySimplif

		V6N->(DBSetOrder(1))

		If V6N->(MsSeek(xFilial("V6N") + V2Z->(V2Z_ID + V2Z_VERSAO)))

			If  TAFColumnPos("V20_DLOT") .And. FWSIXUtil():ExistIndex("V20", "4")

				cV6O 		:= "V6O_ID + V6O_VERSAO + V6O_ESTTP + V6O_ESTNRI + V6O_CODLOT + V6O_TPLOT + V6O_TPINSC + V6O_NRINSC + V6O_DLOT + V6O_DTPLOT"
				cV20 		:= "V20_ID + V20_VERSAO + V20_ESTTP + V20_ESTNRI + V20_CODLOT + V20_TPLOT + V20_TPINSC + V20_NRINSC + V20_DLOT + V20_DTPLOT"
				cV21 		:= "V21_ID + V21_VERSAO + V21_ESTTP + V21_ESTNRI + V21_CODLOT + V21_TPLOT + V21_TPINSC + V21_NRINSC + V21_DLOT + V21_DTPLOT" 
				cV22 		:= "V22_ID + V22_VERSAO + V22_ESTTP + V22_ESTNRI + V22_CODLOT + V22_TPLOT + V22_TPINSC + V22_NRINSC + V22_DLOT + V22_DTPLOT + V22_PERREF + V22_TPCONV"
				nIndex 		:= 4
				nIndexV6O	:= 2

			Else

				cV6O 		:= "V6O_ID + V6O_VERSAO + V6O_ESTTP + V6O_ESTNRI + V6O_CODLOT + V6O_TPLOT + V6O_TPINSC + V6O_NRINSC"
				cV20 		:= "V20_ID + V20_VERSAO + V20_ESTTP + V20_ESTNRI + V20_CODLOT + V20_TPLOT + V20_TPINSC + V20_NRINSC"
				cV21 		:= "V21_ID + V21_VERSAO + V21_ESTTP + V21_ESTNRI + V21_CODLOT + V21_TPLOT + V21_TPINSC + V21_NRINSC" 
				cV22 		:= "V22_ID + V22_VERSAO + V22_ESTTP + V22_ESTNRI + V22_CODLOT + V22_TPLOT + V22_TPINSC + V22_NRINSC + V22_PERREF + V22_TPCONV"
				nIndex 		:= 3
				nIndexV6O	:= 2

			EndIf

			V6O->(DBSetOrder(nIndexV6O))
			V20->(DBSetOrder(nIndex))
			V21->(DBSetOrder(nIndex))
			V22->(DBSetOrder(nIndex))

			While !V6N->(EOF()) .And. V6N->(V6N_FILIAL + V6N_ID + V6N_VERSAO) == xFilial("V6N") + V2Z->(V2Z_ID + V2Z_VERSAO)  

				cXmIdeLot := ""
				
				If V6O->(MsSeek(xFilial("V6O") + V6N->(V6N_ID + V6N_VERSAO + V6N_TPINSC + V6N_NRINSC)))

					While !V6O->(EOF()) .And. V6O->(V6O_FILIAL + V6O_ID + V6O_VERSAO + V6O_ESTTP + V6O_ESTNRI) == xFilial("V6O") + V6N->(V6N_ID + V6N_VERSAO + V6N_TPINSC + V6N_NRINSC)   

						cXmlBsApur 	:= ""
						cXmlIfBsAn	:= ""
						cXmlIfBsFG	:= ""
						
						If V20->(MsSeek(xFilial("V20") + V6O->(&(cV6O))))

							While !V20->(EOF()) .And. V20->(V20_FILIAL + &(cV20)) == xFilial("V20") + V6O->(&(cV6O))  

								cTpValor :=   IIf(TafColumnPos("V20_DTPVL") .And. !Empty(V20->V20_DTPVL), V20->V20_DTPVL, Posicione("V26", 1, xFilial("V26") + V20->V20_IDTPVL, "V26_CODIGO"))

								xTafTagGroup( "basePerApur"																																								;
											, {{"tpValor"	, cTpValor		 , 								   , .F.};
											,  {"indIncid"	, V20->V20_INDINC, 								   , .F.};
											,  {"baseFGTS"	, V20->V20_VLFGTS, getPicCache("V20","V20_VLFGTS"), .F.};
											,  {"vrFGTS"	, V20->V20_VRFGTS, getPicCache("V20","V20_VRFGTS"), .T.}};
											, @cXmlBsApur)

								cTpValor := ""

								V20->(DBSkip())

							EndDo

						EndIf                                                                                     

						If V21->(MsSeek(xFilial("V21") + V6O->(&(cV6O))))

							While !V21->(EOF()) .And. V21->(V21_FILIAL + &(cV21)) == xFilial("V21") + V6O->(&(cV6O))     

								cXmlBsAntE := ""
								
								If V22->(MsSeek(xFilial("V22") + V21->(&(cV21) + V21_PERREF + V21_TPCONV)))             

									While !V22->(EOF()) .And. V22->(V22_FILIAL + &(cV22)) == xFilial("V22") + V21->(&(cV21) + V21_PERREF + V21_TPCONV)  

										cTpValor := Iif(TafColumnPos("V22_DTPVL") .And. !Empty(V22->V22_DTPVL), V22->V22_DTPVL, Posicione("V26", 1, xFilial("V26") + V22->V22_IDTPVL, "V26_CODIGO"))

										cXmlBsAntE += "<basePerAntE>"
										cXmlBsAntE += xTafTag("tpValorE"	, cTpValor		 ,									, .F.)
										cXmlBsAntE += xTafTag("indIncidE"	, V22->V22_INDINE,									, .F.)
										cXmlBsAntE += xTafTag("baseFGTSE"	, V22->V22_VLFGTS, getPicCache("V22","V22_VLFGTS")	, .F.)
										cXmlBsAntE += xTafTag("vrFGTSE"		, V22->V22_VRFGTE, getPicCache("V22","V22_VRFGTE")	, .T.)	
										cXmlBsAntE += "</basePerAntE>"

										V22->(DBSkip())

										cTpValor := ""

									EndDo

								EndIf	

								xTafTagGroup( "infoBasePerAntE"																				;
											, {{"perRef"	, SubStr(V21->V21_PERREF, 3, 4) + "-" + SubStr(V21->V21_PERREF, 1, 2)	,, .F.}	;
											,  {"tpAcConv"	, V21->V21_TPCONV														,, .F.}}; 
											, @cXmlIfBsAn																					;
											, {{"basePerAntE", cXmlBsAntE, 1}}																;
											, .F.;
											, .F.)

								V21->(DBSkip())

							EndDo

						EndIf

						xTafTagGroup( "infoBaseFGTS",							  ; 
									, @cXmlIfBsFG								  ;
									, {{ "basePerApur"		, cXmlBsApur	, 0 } ;
									,  { "infoBasePerAntE"	, cXmlIfBsAn	, 0 }};
									, .F.;
									, .T.)

						cCodLot := Iif( TafColumnPos("V6O_DLOT")  .And. !Empty(V6O->V6O_DLOT)  , V6O->V6O_DLOT  , Posicione("C99", 1, xFilial("C99") + V6O->V6O_CODLOT, "C99_CODIGO"))
						cTpLot  := Iif( TafColumnPos("V6O_DTPLOT").And. !Empty(V6O->V6O_DTPLOT), V6O->V6O_DTPLOT, Posicione("C8F", 1, xFilial("C8F") + V6O->V6O_TPLOT , "C8F_CODIGO"))

						cXmIdeLot += "<ideLotacao>"
						cXmIdeLot += xTafTag("codLotacao"	, cCodLot		 ,, .F.)
						cXmIdeLot += xTafTag("tpLotacao"	, cTpLot		 ,, .F.)
						cXmIdeLot += xTafTag("tpInsc"		, V6O->V6O_TPINSC,, .T.)
						cXmIdeLot += xTafTag("nrInsc"		, V6O->V6O_NRINSC,, .T.)				
						cXmIdeLot += cXmlIfBsFG
						cXmIdeLot += "</ideLotacao>"

						V6O->(DBSkip())

					EndDo

				EndIf

				xTafTagGroup( "ideEstab"						 ;
							, {{"tpInsc", V6N->V6N_TPINSC,, .F.} ;
							,  {"nrInsc", V6N->V6N_NRINSC,, .F.}};
							, @cXml								 ;
							, {{"ideLotacao", cXmIdeLot, 1}})	

				V6N->(DBSkip())

			EndDo

			V6O->(DBCloseArea())
			V20->(DBCloseArea())
			V21->(DBCloseArea())
			V22->(DBCloseArea())

		EndIf

		V6N->(DBCloseArea())

	Else

		V20->(DBSetOrder(1))
		V21->(DBSetOrder(1))
		V22->(DBSetOrder(1))
		V23->(DBSetOrder(1))
		V24->(DBSetOrder(1))
		V25->(DBSetOrder(1))

		lSeekV20 := V20->( MsSeek( xFilial( "V20" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )
		lSeekV21 := V21->( MsSeek( xFilial( "V21" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )

		If lSeekV20 .or. lSeekV21

			cXml += "<infoBaseFGTS>"

			If lSeeKV20

				While V20->( !Eof() ) .and. V20->( V20_FILIAL + V20_ID + V20_VERSAO ) == xFilial( "V20" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cTpValor := IIf(TafColumnPos("V20_DTPVL") .And. !Empty(V20->V20_DTPVL), V20->V20_DTPVL, Posicione("V26", 1, xFilial("V26") + V20->V20_IDTPVL, "V26_CODIGO"))

					cXml += "<basePerApur>"
					cXml += 	xTafTag( "tpValor" , cTpValor, 										 , .F. )
					cXml += 	xTafTag( "baseFGTS", V20->V20_VLFGTS, getPicCache("V20","V20_VLFGTS"), .F. )
					cXml += "</basePerApur>"

					cTpValor := ""

					V20->( DBSkip() )

				EndDo

			EndIf

			If lSeeKV21

				While V21->( !Eof() ) .and. V21->( V21_FILIAL + V21_ID + V21_VERSAO ) == xFilial( "V21" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<infoBasePerAntE>"
					cXml += 	xTafTag( "perRef"	, SubStr( V21->V21_PERREF, 3, 4 ) + "-" + SubStr( V21->V21_PERREF, 1, 2 ) )

					If TafColumnPos("V21_TPCONV")
						cXml += 	xTafTag( "tpAcConv"	, V21->V21_TPCONV	 													  )
					EndIf

					If V22->( MsSeek( xFilial( "V22" ) + V21->( V21_ID + V21_VERSAO + V21_PERREF ) ) )

						While V22->( !Eof() ) .and. V22->( V22_FILIAL + V22_ID + V22_VERSAO + V22_PERREF ) == xFilial( "V22" ) + V21->( V21_ID + V21_VERSAO + V21_PERREF )

							cTpValor := If(TafColumnPos("V22_DTPVL") .And. !Empty(V22->V22_DTPVL), V22->V22_DTPVL, Posicione("V26", 1, xFilial("V26") + V22->V22_IDTPVL, "V26_CODIGO"))

							cXml += "<basePerAntE>"
							cXml += 	xTafTag( "tpValorE" , cTpValor		 ,								  , .F. )
							cXml += 	xTafTag( "baseFGTSE", V22->V22_VLFGTS, getPicCache("V22","V22_VLFGTS"), .F. )
							cXml += "</basePerAntE>"

							cTpValor := ""

							V22->( DBSkip() )

						EndDo

					EndIf

					cXml += "</infoBasePerAntE>"

					V21->( DBSkip() )

				EndDo

			EndIf

			cXml += "</infoBaseFGTS>"

		EndIf

		lSeekV23 := V23->( MsSeek( xFilial( "V23" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )
		lSeekV24 := V24->( MsSeek( xFilial( "V24" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )

		If ( lSeekV23 .or. lSeekV24 )

			cXml += "<infoDpsFGTS>"

			If lSeeKV23

				While V23->( !Eof() ) .and. V23->( V23_FILIAL + V23_ID + V23_VERSAO ) == xFilial( "V23" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cTpDep := Iif(TafColumnPos("V23_DTPDP") .And. !Empty(V23->V23_DTPDP), V23->V23_DTPDP, Posicione( "V27", 1, xFilial( "V27" ) + V23->V23_IDTPDP, "V27_CODIGO" ))

					cXml += "<dpsPerApur>"
					cXml += 	xTafTag( "tpDps" , cTpDep ,											, .F. )
					cXml += 	xTafTag( "vrFGTS", V23->V23_VLFGTS, getPicCache("V23","V23_VLFGTS"), .F. )
					cXml += "</dpsPerApur>"

					cTpDep := ""

					V23->( DBSkip() )

				EndDo

			EndIf

			If lSeekV24

				While V24->( !Eof() ) .and. V24->( V24_FILIAL + V24_ID + V24_VERSAO ) == xFilial( "V24" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<infoDpsPerAntE>"
					cXml += 	xTafTag( "perRef"	, SubStr( V24->V24_PERREF, 3, 4 ) + "-" + SubStr( V24->V24_PERREF, 1, 2 ) )

					If TafColumnPos("V24_TPCONV	")
						cXml += 	xTafTag( "tpAcConv"	, V24->V24_TPCONV	 													  )
					EndIf

					If V25->( MsSeek( xFilial( "V25" ) + V24->( V24_ID + V24_VERSAO + V24_PERREF ) ) )

						While V25->( !Eof() ) .and. V25->( V25_FILIAL + V25_ID + V25_VERSAO + V25_PERREF ) == xFilial( "V25" ) + V24->( V24_ID + V24_VERSAO + V24_PERREF )

							cTpDep := Iif(TafColumnPos("V25_DTPDP") .And. !Empty(V25->V25_DTPDP), V25->V25_DTPDP, Posicione( "V27", 1, xFilial( "V27" ) + V25->V25_IDTPDP, "V27_CODIGO" ))

							cXml += "<dpsPerAntE>"
							cXml += 	xTafTag( "tpDpsE" , cTpDep,											, .F. )
							cXml += 	xTafTag( "vrFGTSE", V25->V25_VLFGTS, getPicCache("V25","V25_VLFGTS"), .F. )
							cXml += "</dpsPerAntE>"

							V25->( DBSkip() )

						EndDo

					EndIf

					cXml += "</infoDpsPerAntE>"

					V24->( DBSkip() )

				EndDo

			EndIf

			cXml += "</infoDpsFGTS>"

		EndIf

		V20->(DBCloseArea())
		V21->(DBCloseArea())
		V22->(DBCloseArea())
		V23->(DBCloseArea())
		V24->(DBCloseArea())
		V25->(DBCloseArea())
	EndIf

	cXml += "</infoFGTS>"

	If lLaySimplif

		If V2Z->V2Z_INDAPU == "1"

			aAdd(aMensal, V2Z->V2Z_INDAPU)
			aAdd(aMensal, Substr(V2Z->V2Z_PERAPU, 3, 4) + "-" + Substr(V2Z->V2Z_PERAPU, 1, 2))

		ElseIf V2Z->V2Z_INDAPU == "2"

			aAdd(aMensal, V2Z->V2Z_INDAPU)
			aAdd(aMensal, Alltrim(V2Z->V2Z_PERAPU))

		Else

			aAdd(aMensal, "")

			If Len(AllTrim(V2Z->V2Z_PERAPU)) == 6
				aAdd( aMensal, SubStr( V2Z->V2Z_PERAPU, 3, 4 ) + "-" + SubStr( V2Z->V2Z_PERAPU, 1, 2 ) )
			Else
				aAdd( aMensal, V2Z->V2Z_PERAPU )
			EndIf

		EndIf

	Else

		If Len(AllTrim(V2Z->V2Z_PERAPU)) == 6
			aAdd( aMensal, SubStr( V2Z->V2Z_PERAPU, 3, 4 ) + "-" + SubStr( V2Z->V2Z_PERAPU, 1, 2 ) )
		Else
			aAdd( aMensal, V2Z->V2Z_PERAPU )
		EndIf

	EndIf

	cXml := xTafCabXml(cXml, "V2Z", cLayout, cReg, aMensal,,, lLaySimplif)

	If !lJob
		xTafGerXml(cXml, cLayout)
	EndIf

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} SearchRec
@type			function
@description	Verifica a existência do Evento S-5013 a partir do Recibo.
@author			Ricardo Lovrenovic
@since			08/01/2018
@version		1.0
@param			cRecibo		-	Recibo do evento original
@param			cFilGrv		-	Filial da localização do Recibo ( Referência )
@param			dDtLegado	-	Data do parâmetro MV_TOTEXDT ( Referência )
@return			lRet		-	Indica se existe Evento S-5013 para o Recibo indicado
/*/
//---------------------------------------------------------------------
Static Function SearchRec( cRecibo, cFilGrv, dDtLegado )

	Local cAliasQry	:=	GetNextAlias()
	Local cQuery	:=	""
	Local lRet		:=	.F.

	cQuery := " SELECT V2Z.V2Z_FILGRV, V2Z.V2Z_SITPAR "
	cQuery += " FROM " + RetSqlName( "V2Z" ) + " V2Z "
	cQuery += " WHERE V2Z.V2Z_NRRECI = '" + cRecibo + "' "
	cQuery += " AND V2Z.V2Z_ATIVO = '1' "
	cQuery += " AND V2Z.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )

		cFilGrv := ( cAliasQry )->V2Z_FILGRV
		dDtLegado := SToD( ( cAliasQry )->V2Z_SITPAR )
		lRet := .T.

	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Rela
@type			function
@description	Função para preencher os campos virtuais V20_DIDTPV|V22_DIDTPV|V23_DIDTPD|V25_DIDTPD
@author			rodrigo.nicolino
@since			02/05/2024
@version		1.0
@return			cRet	-	Retorna a descrição do código utilizado que 
							se encontra na tabela V26
/*/
//---------------------------------------------------------------------
Function TAF521Rela(cCampo as character)

	Local cRet as character

	Default cCampo  := ""

	cRet    := ""

	If !INCLUI

		If cCampo == "V20_DIDTPV"

			If !TafColumnPos("V20_DTPVL") .And. !Empty(V20->V20_IDTPVL)

				cRet := Posicione( "V26", 1, xFilial("V26") + V20->V20_IDTPVL, "V26_CODIGO + ' - ' + V26_DESCRI" )

			ElseIf TafColumnPos("V20_DTPVL") .And. !Empty(V20->V20_DTPVL)

				cRet := Posicione( "V26", 2, xFilial("V26") + V20->V20_DTPVL, "V26_DESCRI" )

			Else

				cRet := ""

			EndIf

		ElseIf cCampo == "V22_DIDTPV"

			If !TafColumnPos("V22_DTPVL") .And. !Empty(V22->V22_IDTPVL)

				cRet := Posicione( "V26", 1, xFilial("V26") + V22->V22_IDTPVL, "V26_CODIGO + ' - ' + V26_DESCRI" )

			ElseIf TafColumnPos("V22_DTPVL") .And. !Empty(V22->V22_DTPVL)

				cRet := Posicione( "V26", 2, xFilial("V26") + V22->V22_DTPVL, "V26_DESCRI" )

			Else

				cRet := ""

			EndIf

		ElseIf cCampo == "V23_DIDTPD"

			If !TafColumnPos("V23_DTPDP") .And. !Empty(V23->V23_IDTPDP)

				cRet := Posicione( "V26", 1, xFilial("V26") + V23->V23_IDTPDP, "V27_CODIGO + ' - ' + V27_DESCRI" )

			ElseIf TafColumnPos("V23_DTPDP") .And. !Empty(V23->V23_DTPDP )

				cRet := Posicione( "V27", 2, xFilial("V27") + V23->V23_DTPDP , "V27_DESCRI" )

			Else

				cRet := ""

			EndIf

		ElseIf cCampo == "V25_DIDTPD"

			If !TafColumnPos("V25_DTPDP") .And. !Empty(V25->V25_IDTPDP)

				cRet := Posicione( "V27", 1, xFilial("V27") + V25->V25_IDTPDP, "V27_CODIGO + ' - ' + V27_DESCRI" )

			ElseIf TafColumnPos("V25_DTPDP") .And. !Empty(V25->V25_DTPDP)

				cRet := Posicione( "V27", 2, xFilial("V27") + V25->V25_DTPDP, "V27_DESCRI" )

			Else

				cRet := ""

			EndIf

		EndIf

	EndIf

 Return cRet
