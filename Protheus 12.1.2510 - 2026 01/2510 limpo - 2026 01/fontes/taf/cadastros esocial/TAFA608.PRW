#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA608.CH"

Static __cPicBcFGTS := Nil
Static __cPicFgtsSg := Nil
Static __cPicVlApi  := Nil
Static __cPicVlaVsp := Nil
Static __cPicVlBase := Nil
Static __cPicVlInde := Nil
Static __cPicVlVerb := Nil
Static __cPicVrCP   := Nil
Static __cPicVrFGTS := Nil
Static __cPicVrFGui := Nil
Static __cPicVrMen  := Nil
Static __cPicVrPrev := Nil
Static __cPicVrSal  := Nil
Static __cPicBcProt := Nil
Static __cPicBcSefi := Nil
Static __cPicBcDeCa := Nil
Static __cPicVrAlim := Nil
Static lSimpl12     := TafLayESoc("S_01_02_00",.T., .T.)
Static lSimpl0103 	:= TAFLayESoc("S_01_03_00",.T., .T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA608
Cadastro de Processo Trabalhista

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA608()

	Private oBrw 		as object		
	Private cEvtPosic	as character
	
	oBrw := FWmBrowse():New()
	
	If TafAtualizado(, "TAFA608")
		TafNewBrowse( "S-2500", , , , STR0001, , 2, 4)
	EndIf

	oBrw:SetCacheView( .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array
	
	aFuncao := {}
	aRotina := {}

	If !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES") .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF608View('V9U',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF608Inc('V9U',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('V9U', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA608"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF608Xml" 						, "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'V9U' )" 			, "10"} )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'V9U', 'TAFA608' )" 	, "3" } ) //Chamo a Browse do Histórico
		Aadd( aFuncao, { "" , "StaticCall(TAFA608,PreXmlLote)" 	, "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA608' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA608", "V9U", .F. ) // Menu dos extemporâneos
		EndIf

	EndIf	
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV9U  as object 
	Local oStruV9V  as object 
	Local oStruV9W  as object 
	Local oStruV9Y  as object 
	Local oStruV9X  as object 
	Local oStruV9Z  as object 
	Local oStruV7A  as object 
	Local oStruV7B  as object 
	Local oStruV7H  as object 
	Local oStruV7I  as object 
	Local oStruV7Q  as object
	Local oStruT8F  as object  
	Local oModel    as object 

	oStruV9U := FWFormStruct( 1, 'V9U' )
	
	If  !lSimpl12 .Or. !lSimpl0103 
		oStruV9V := FWFormStruct( 1, 'V9V' )
	EndIf

	oStruV9W := FWFormStruct( 1, 'V9W' )
	oStruV9Y := FWFormStruct( 1, 'V9Y' )
	oStruV9X := FWFormStruct( 1, 'V9X' )
	oStruV9Z := FWFormStruct( 1, 'V9Z' )
	oStruV7A := FWFormStruct( 1, 'V7A' )
	oStruV7B := FWFormStruct( 1, 'V7B' )
	oStruV7H := FWFormStruct( 1, 'V7H' )
	oStruV7I := FWFormStruct( 1, 'V7I' )

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
		oStruV7Q := FWFormStruct( 1, 'V7Q' )
	EndIf

	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
		oStruT8F := FWFormStruct( 1, 'T8F' )
	EndIf
	
	oModel   := MPFormModel():New('TAFA608',, { |oModel| ValidModel( oModel ) }, {|oModel| SaveModel(oModel)} )

	oModel:AddFields('MODEL_V9U',, oStruV9U)

	If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")
		oModel:GetModel('MODEL_V9U'):SetPrimaryKey({'V9U_NRPROC', 'V9U_CPFTRA', 'V9U_IDESEQ'})
	Else
		oModel:GetModel('MODEL_V9U'):SetPrimaryKey({'V9U_NRPROC', 'V9U_CPFTRA'})   
	EndIf                                                                                                                                                                                                              

	If  !lSimpl12 .Or. !lSimpl0103
		oModel:AddGrid('MODEL_V9V', 'MODEL_V9U', oStruV9V)
		oModel:GetModel('MODEL_V9V'):SetOptional(.T.)
		oModel:GetModel('MODEL_V9V'):SetMaxLine(99)
		oModel:GetModel('MODEL_V9V'):SetUniqueLine({"V9V_CPFDEP"})
	EndIf

	oModel:AddGrid('MODEL_V9W', 'MODEL_V9U', oStruV9W)
	oModel:GetModel('MODEL_V9W'):SetOptional(.F.)
	oModel:GetModel('MODEL_V9W'):SetMaxLine(99)	
	oModel:GetModel('MODEL_V9W'):SetUniqueLine({"V9W_MATRIC", "V9W_CODCAT", "V9W_DTINIC"})

	oModel:AddGrid('MODEL_V9X', 'MODEL_V9W', oStruV9X)
	oModel:GetModel('MODEL_V9X'):SetOptional(.T.)
	oModel:GetModel('MODEL_V9X'):SetMaxLine(1)	
	
	oModel:AddGrid('MODEL_V9Y', 'MODEL_V9X', oStruV9Y)
	oModel:GetModel('MODEL_V9Y'):SetOptional(.T.)
	oModel:GetModel('MODEL_V9Y'):SetMaxLine(99)	
	oModel:GetModel('MODEL_V9Y'):SetUniqueLine({"V9Y_DTREMU"})

	oModel:AddGrid('MODEL_V9Z', 'MODEL_V9X', oStruV9Z)
	oModel:GetModel('MODEL_V9Z'):SetOptional(.T.)
	oModel:GetModel('MODEL_V9Z'):SetMaxLine(99)
	oModel:GetModel('MODEL_V9Z'):SetUniqueLine({"V9Z_IDOBS"})

	oModel:AddGrid('MODEL_V7A', 'MODEL_V9W', oStruV7A)
	oModel:GetModel('MODEL_V7A'):SetOptional(.T.)
	oModel:GetModel('MODEL_V7A'):SetMaxLine(99)
	oModel:GetModel('MODEL_V7A'):SetUniqueLine({"V7A_DTMUDC"})

	oModel:AddGrid('MODEL_V7B', 'MODEL_V9W', oStruV7B)
	oModel:GetModel('MODEL_V7B'):SetOptional(.T.)
	oModel:GetModel('MODEL_V7B'):SetMaxLine(99)
	oModel:GetModel('MODEL_V7B'):SetUniqueLine({"V7B_MATUNI","V7B_NEWCAT","V7B_DTTSV"})

	oModel:AddGrid('MODEL_V7H', 'MODEL_V9W', oStruV7H)
	oModel:GetModel('MODEL_V7H'):SetOptional(.T.)
	oModel:GetModel('MODEL_V7H'):SetMaxLine(1)
	
	oModel:AddGrid('MODEL_V7I', 'MODEL_V9W', oStruV7I)
	oModel:GetModel('MODEL_V7I'):SetOptional(.T.)
	oModel:GetModel('MODEL_V7I'):SetMaxLine(999)
	oModel:GetModel('MODEL_V7I'):SetUniqueLine({"V7I_PERREF"})

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")

		oModel:AddGrid('MODEL_V7Q', 'MODEL_V9W', oStruV7Q)
		oModel:GetModel('MODEL_V7Q'):SetOptional(.T.)
		oModel:GetModel('MODEL_V7Q'):SetMaxLine(9)
		oModel:GetModel('MODEL_V7Q'):SetUniqueLine({"V7Q_ANOBAS"})
		
	EndIf

	
	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")

		oModel:AddGrid('MODEL_T8F', 'MODEL_V9W', oStruT8F)
		oModel:GetModel('MODEL_T8F'):SetOptional(.T.)
		oModel:GetModel('MODEL_T8F'):SetMaxLine(31)
		oModel:GetModel('MODEL_T8F'):SetUniqueLine({"T8F_DIATRA"})
		
	EndIf

	If  !lSimpl12 .Or. !lSimpl0103
		oModel:SetRelation('MODEL_V9V', {{'V9V_FILIAL' , 'xFilial( "V9V" )'}, {'V9V_ID' , 'V9U_ID'}, {'V9V_VERSAO' , 'V9U_VERSAO'}, {'V9V_NRPROC' , 'V9U_NRPROC'}, {'V9V_CPFTRA' , 'V9U_CPFTRA'}}, V9V->(IndexKey(1)))
	EndIf

	oModel:SetRelation('MODEL_V9W', {{'V9W_FILIAL' , 'xFilial( "V9W" )'}, {'V9W_ID' , 'V9U_ID'}, {'V9W_VERSAO' , 'V9U_VERSAO'}, {'V9W_NRPROC' , 'V9U_NRPROC'}, {'V9W_CPFTRA' , 'V9U_CPFTRA'}}, V9W->(IndexKey(1)))
	oModel:SetRelation('MODEL_V9X', {{'V9X_FILIAL' , 'xFilial( "V9X" )'}, {'V9X_ID' , 'V9U_ID'}, {'V9X_VERSAO' , 'V9U_VERSAO'}, {'V9X_NRPROC' , 'V9U_NRPROC'}, {'V9X_CPFTRA' , 'V9U_CPFTRA'}, {'V9X_MATRIC' , 'V9W_MATRIC'}, {'V9X_CODCAT' , 'V9W_CODCAT'}, {'V9X_DTINIC' , 'V9W_DTINIC'}}, V9X->(IndexKey(1)))
	oModel:SetRelation('MODEL_V9Y', {{'V9Y_FILIAL' , 'xFilial( "V9Y" )'}, {'V9Y_ID' , 'V9U_ID'}, {'V9Y_VERSAO' , 'V9U_VERSAO'}, {'V9Y_NRPROC' , 'V9U_NRPROC'}, {'V9Y_CPFTRA' , 'V9U_CPFTRA'}, {'V9Y_MATRIC' , 'V9W_MATRIC'}, {'V9Y_CODCAT' , 'V9W_CODCAT'}, {'V9Y_DTINIC' , 'V9W_DTINIC'}}, V9Y->(IndexKey(1)))
	oModel:SetRelation('MODEL_V9Z', {{'V9Z_FILIAL' , 'xFilial( "V9Z" )'}, {'V9Z_ID' , 'V9U_ID'}, {'V9Z_VERSAO' , 'V9U_VERSAO'}, {'V9Z_NRPROC' , 'V9U_NRPROC'}, {'V9Z_CPFTRA' , 'V9U_CPFTRA'}, {'V9Z_MATRIC' , 'V9W_MATRIC'}, {'V9Z_CODCAT' , 'V9W_CODCAT'}, {'V9Z_DTINIC' , 'V9W_DTINIC'}}, V9Z->(IndexKey(1)))
	oModel:SetRelation('MODEL_V7A', {{'V7A_FILIAL' , 'xFilial( "V7A" )'}, {'V7A_ID' , 'V9U_ID'}, {'V7A_VERSAO' , 'V9U_VERSAO'}, {'V7A_NRPROC' , 'V9U_NRPROC'}, {'V7A_CPFTRA' , 'V9U_CPFTRA'}, {'V7A_MATRIC' , 'V9W_MATRIC'}, {'V7A_CODCAT' , 'V9W_CODCAT'}, {'V7A_DTINIC' , 'V9W_DTINIC'}}, V7A->(IndexKey(1)))
	oModel:SetRelation('MODEL_V7B', {{'V7B_FILIAL' , 'xFilial( "V7B" )'}, {'V7B_ID' , 'V9U_ID'}, {'V7B_VERSAO' , 'V9U_VERSAO'}, {'V7B_NRPROC' , 'V9U_NRPROC'}, {'V7B_CPFTRA' , 'V9U_CPFTRA'}, {'V7B_MATRIC' , 'V9W_MATRIC'}, {'V7B_CODCAT' , 'V9W_CODCAT'}, {'V7B_DTINIC' , 'V9W_DTINIC'}}, V7B->(IndexKey(1)))
	oModel:SetRelation('MODEL_V7H', {{'V7H_FILIAL' , 'xFilial( "V7H" )'}, {'V7H_ID' , 'V9U_ID'}, {'V7H_VERSAO' , 'V9U_VERSAO'}, {'V7H_NRPROC' , 'V9U_NRPROC'}, {'V7H_CPFTRA' , 'V9U_CPFTRA'}, {'V7H_MATRIC' , 'V9W_MATRIC'}, {'V7H_CODCAT' , 'V9W_CODCAT'}, {'V7H_DTINIC' , 'V9W_DTINIC'}}, V7H->(IndexKey(1)))
	oModel:SetRelation('MODEL_V7I', {{'V7I_FILIAL' , 'xFilial( "V7I" )'}, {'V7I_ID' , 'V9U_ID'}, {'V7I_VERSAO' , 'V9U_VERSAO'}, {'V7I_NRPROC' , 'V9U_NRPROC'}, {'V7I_CPFTRA' , 'V9U_CPFTRA'}, {'V7I_MATRIC' , 'V9W_MATRIC'}, {'V7I_CODCAT' , 'V9W_CODCAT'}, {'V7I_DTINIC' , 'V9W_DTINIC'}, {'V7I_TPINSC' , 'V7H_TPINSC'}, {'V7I_NRINSC' , 'V7H_NRINSC'}}, V7I->(IndexKey(1)))
	
	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
		oModel:SetRelation('MODEL_V7Q', {{'V7Q_FILIAL' , 'xFilial( "V7Q" )'}, {'V7Q_ID' , 'V9U_ID'}, {'V7Q_VERSAO' , 'V9U_VERSAO'}, {'V7Q_NRPROC' , 'V9U_NRPROC'}, {'V7Q_CPFTRA' , 'V9U_CPFTRA'}, {'V7Q_MATRIC' , 'V9W_MATRIC'}, {'V7Q_CODCAT' , 'V9W_CODCAT'}, {'V7Q_DTINIC' , 'V9W_DTINIC'}, {'V7Q_TPINSC' , 'V7H_TPINSC'}, {'V7Q_NRINSC' , 'V7H_NRINSC'}}, V7Q->(IndexKey(1)))
	EndIf

	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
		oModel:SetRelation('MODEL_T8F', {{'T8F_FILIAL' , 'xFilial( "T8F" )'}, {'T8F_ID' , 'V9U_ID'}, {'T8F_VERSAO' , 'V9U_VERSAO'}, {'T8F_NRPROC' , 'V9U_NRPROC'}, {'T8F_CPFTRA' , 'V9U_CPFTRA'}, {'T8F_MATRIC' , 'V9W_MATRIC'}, {'T8F_CODCAT' , 'V9W_CODCAT'}, {'T8F_DTINIC' , 'V9W_DTINIC'}, {'T8F_TPINSC' , 'V7H_TPINSC'}, {'T8F_NRINSC' , 'V7H_NRINSC'}}, T8F->(IndexKey(1)))
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Type( "INCLUI" ) <> "U"  .AND. !INCLUI
		oStruV9U:SetProperty( "V9U_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     as object  
	Local oStruV9Ua	 as object  
	Local oStruV9Ub  as object  
	Local oStruV9Uc  as object  
	Local oStruV9Ud  as object  
	Local oStruV9Ue  as object  
	Local oStruV9V   as object  
	Local oStruV9W   as object  
	Local oStruV9Y   as object  
	Local oStruV9X   as object  
	Local oStruV9Z   as object  
	Local oStruV7A 	 as object  
	Local oStruV7B   as object  
	Local oStruV7H   as object  
	Local oStruV7I   as object  
	Local oStruV7Q   as object 
	Local oStruT8F   as object
	Local oView      as object  
	Local cCmpFil    as character
	Local lCallInc	 as logical
	Local lTrab	 	 as logical

	oModel     	:= FWLoadModel( 'TAFA608' )
	oStruV9Ua	:= Nil
	oStruV9Ub  	:= Nil
	oStruV9Uc  	:= Nil
	oStruV9Ud  	:= Nil
	oStruV9Ue  	:= Nil
	oStruV9V   	:= Iif( (!lSimpl12 .Or. !lSimpl0103) ,  FWFormStruct( 2, 'V9V' ), Nil)
	oStruV9W   	:= Nil
	oStruV9Y   	:= FWFormStruct( 2, 'V9Y' )
	oStruV9X   	:= FWFormStruct( 2, 'V9X' )
	oStruV9Z   	:= FWFormStruct( 2, 'V9Z' )
	oStruV7A 	:= FWFormStruct( 2, 'V7A' )
	oStruV7B   	:= FWFormStruct( 2, 'V7B' )
	oStruV7H	:= Nil
	oStruV7I   	:= Nil
	oStruV7Q   	:= Iif(  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS"), FWFormStruct( 2, 'V7Q' ), Nil)
	oStruT8F   	:= Iif(  lSimpl0103 .And. TafColumnPos("T8F_DIATRA"), FWFormStruct( 2, 'T8F' ), Nil)
	oView      	:= FWFormView():New()
	cCmpFil    	:= ""
	lCallInc	:= .F. 
	lTrab	 	:= .F.

	oView:SetModel( oModel )
	oView:SetContinuousForm()

	If FWIsInCallStack( "TAF608Inc" )
		lCallInc 	:= .T.
		lTrab		:= MsgYesNo( STR0022, STR0023) // "O Processo Trabalhista a ser incluído é de um trabalhador cadastrado no sistema?"
	EndIf

	If lSimpl0103 .And. TafColumnPos("V9U_DTADMR")
		cCmpFil := 'V9U_ID|V9U_TPINSC|V9U_NRINSC|V9U_DTADMR|V9U_MATRDI|
	Else
		cCmpFil := 'V9U_ID|V9U_TPINSC|V9U_NRINSC|
	EndIf	

	oStruV9Ua := FwFormStruct( 2, 'V9U', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := 'V9U_ORIGEM|V9U_NRPROC|V9U_OBSERV|V9U_DTSENT|V9U_UFVARA|V9U_DCODUF|V9U_CODMUN|V9U_DCODMU|V9U_IDVARA|V9U_DTCCP|V9U_TPCCP|V9U_CNPJCP|'
	oStruV9Ub := FwFormStruct( 2, 'V9U', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Informações do trabalhador
	If (lCallInc .AND. lTrab) .OR. (!lCallInc .AND. !Empty(V9U->V9U_TRABAL))

		If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")
			cCmpFil := 'V9U_TRABAL|V9U_CPFTRA|V9U_NMTRAB|V9U_DTNASC|V9U_IDESEQ|'
		Else
			cCmpFil := 'V9U_TRABAL|V9U_CPFTRA|V9U_NMTRAB|V9U_DTNASC|'
		EndIf	

	Else
		If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")
			cCmpFil := 'V9U_CPFTRA|V9U_NMTRAB|V9U_DTNASC|V9U_IDESEQ|'
		Else
			cCmpFil := 'V9U_CPFTRA|V9U_NMTRAB|V9U_DTNASC|'
		EndIf	
	EndIf
	
	oStruV9Uc := FwFormStruct( 2, 'V9U', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder Número de protocolo
	cCmpFil := 'V9U_PROTUL|
	oStruV9Ud := FwFormStruct( 2, 'V9U', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := 'V9U_DINSIS|V9U_DTRANS|V9U_HTRANS|V9U_DTRECP|V9U_HRRECP|'
	oStruV9Ue := FwFormStruct( 2, 'V9U', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	
	If lSimpl12 .Or. lSimpl0103

		cCmpFil := 'V7H_COMPIN|V7H_COMPFI|V7H_INDREP|V7H_INDESD|V7H_INDABO|V7H_TPINSC|V7H_NRINSC|'		
		oStruV7H := FwFormStruct( 2, 'V7H', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil := 'V7I_VRMEN|V7I_VRCP|V7I_GRAUEX|V7I_CATMUD|V7I_VRPREV|V7I_TPINSC|V7I_NRINSC|V7I_BCPROT|V7I_BCSEFI|V7I_BCDECA|V7I_PERREF|V7I_CODCAT|'
		oStruV7I := FwFormStruct( 2, 'V7I', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil := 'V9W_TPCONT|V9W_INDCON|V9W_DTADMO|V9W_INDREI|V9W_INDCAT|V9W_INDNAT|V9W_INDMDE|V9W_MATRIC|V9W_CODCAT|V9W_DTINIC|'
		oStruV9W := FwFormStruct( 2, 'V9W', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil := 'V9X_CODCBO|V9X_DCODCB|V9X_NATATV|V9X_TPREGT|V9X_TPREGP|V9X_DTADM|V9X_TMPPAR|V9X_TPCDUR|V9X_DTTERM|V9X_CLAASS|V9X_OBJDET|V9X_TPINSC|V9X_NRINSC|V9X_MATANT|V9X_DTTRAN|V9X_DTDESL|V9X_MTVDES|V9X_DTFPRO|V9X_DTFIM|V9X_PENSAL|V9X_PERCAL|V9X_VRALIM|V9X_DTTERM|V9X_MTDTSV|'
		oStruV9X := FwFormStruct( 2, 'V9X', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil := 'V7Q_ANOBAS|'
		oStruV7Q := FwFormStruct( 2, 'V7Q', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		If lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
			cCmpFil := 'T8F_DIATRA|T8F_HRSTRA|'
			oStruT8F := FwFormStruct( 2, 'T8F', {|x| AllTrim( x ) + "|" $ cCmpFil } )
		EndIf	

	Else
		oStruV7H   	:= FWFormStruct( 2, 'V7H' )
		oStruV7I   	:= FWFormStruct( 2, 'V7I' )
		oStruV9W   	:= FWFormStruct( 2, 'V9W' )
	EndIf

	If (lCallInc .AND. lTrab) .OR. (!lCallInc .AND. !Empty(V9U->V9U_TRABAL))
		oStruV9Uc:SetProperty( "V9U_CPFTRA"	, MVC_VIEW_CANCHANGE, .F.  )
		oStruV9Uc:SetProperty( "V9U_NMTRAB"	, MVC_VIEW_CANCHANGE, .F.  )
		oStruV9Uc:SetProperty( "V9U_DTNASC"	, MVC_VIEW_CANCHANGE, .F.  )	

	EndIf

	If Type( "ALTERA" ) <> "U" .And. (ALTERA .And. (V9U->V9U_EVENTO == 'A' .Or. V9U->V9U_STATUS == '4'))		
		oStruV9Ub:SetProperty( "V9U_NRPROC"	, MVC_VIEW_CANCHANGE, .F.  )
		If !Empty(V9U->V9U_TRABAL)
			oStruV9Uc:SetProperty( "V9U_TRABAL"	, MVC_VIEW_CANCHANGE, .F.  )
		EndIf
	EndIf

	// Ordenando os campos
	oStruV9Ub:SetProperty( "V9U_ORIGEM", MVC_VIEW_ORDEM, "01" )
	oStruV9Ub:SetProperty( "V9U_NRPROC", MVC_VIEW_ORDEM, "02" )	
	oStruV9Ub:SetProperty( "V9U_DTSENT", MVC_VIEW_ORDEM, "03" )
	oStruV9Ub:SetProperty( "V9U_UFVARA", MVC_VIEW_ORDEM, "04" )
	oStruV9Ub:SetProperty( "V9U_DCODUF", MVC_VIEW_ORDEM, "05" )
	oStruV9Ub:SetProperty( "V9U_CODMUN", MVC_VIEW_ORDEM, "06" )
	oStruV9Ub:SetProperty( "V9U_DCODMU", MVC_VIEW_ORDEM, "07" )
	oStruV9Ub:SetProperty( "V9U_IDVARA", MVC_VIEW_ORDEM, "08" )
	oStruV9Ub:SetProperty( "V9U_DTCCP" , MVC_VIEW_ORDEM, "09" )
	oStruV9Ub:SetProperty( "V9U_TPCCP" , MVC_VIEW_ORDEM, "10" )
	oStruV9Ub:SetProperty( "V9U_CNPJCP", MVC_VIEW_ORDEM, "11" )
	oStruV9Ub:SetProperty( "V9U_OBSERV", MVC_VIEW_ORDEM, "12" )

	// Titulos dos Grupos
	oView:AddField( 'VIEW_V9Ua', oStruV9Ua, 'MODEL_V9U' )
	oView:EnableTitleView( 'VIEW_V9Ua', STR0021 ) //"Identificação do contribuinte responsável"

	oView:AddField( 'VIEW_V9Ub', oStruV9Ub, 'MODEL_V9U' )
	oView:EnableTitleView( 'VIEW_V9Ub', STR0014 ) //"Informações do processo judicial"

	oView:AddField( 'VIEW_V9Uc', oStruV9Uc, 'MODEL_V9U' )
	oView:EnableTitleView( 'VIEW_V9Uc', STR0003 ) //"Informações do trabalhador"

	oView:AddField( 'VIEW_V9Ud', oStruV9Ud, 'MODEL_V9U' )
	oView:EnableTitleView( 'VIEW_V9Ud', TafNmFolder("recibo",1) )

	oView:AddField( 'VIEW_V9Ue', oStruV9Ue, 'MODEL_V9U' )
	oView:EnableTitleView( 'VIEW_V9Ue', TafNmFolder("recibo",2) )

	If  !lSimpl12 .Or. !lSimpl0103
		oView:AddGrid( 'VIEW_V9V', oStruV9V, 'MODEL_V9V' )
		oView:EnableTitleView( 'VIEW_V9V', STR0004 )    //"Informações dos dependentes"
	EndIf

	oView:AddGrid( 'VIEW_V9W', oStruV9W, 'MODEL_V9W' )
	oView:EnableTitleView( 'VIEW_V9W', STR0005 )    //"Informações do contrato de trabalho"

	oView:AddGrid( 'VIEW_V9X', oStruV9X, 'MODEL_V9X' )
	oView:EnableTitleView( 'VIEW_V9X', STR0007 )    //"Informações complementares do contrato de trabalho"

	oView:AddGrid( 'VIEW_V9Y', oStruV9Y, 'MODEL_V9Y' )
	oView:EnableTitleView( 'VIEW_V9Y', STR0006 )    //"Informações da remuneração e periodicidade de pagamento"

	oView:AddGrid( 'VIEW_V9Z', oStruV9Z, 'MODEL_V9Z' )
	oView:EnableTitleView( 'VIEW_V9Z', STR0008 )    //"Observações do contrato de trabalho"

	oView:AddGrid( 'VIEW_V7A', oStruV7A, 'MODEL_V7A' )
	oView:EnableTitleView( 'VIEW_V7A', STR0009 )    //"Informação do novo código de categoria e/ou da nova natureza da atividade"

	oView:AddGrid( 'VIEW_V7B', oStruV7B, 'MODEL_V7B' )
	oView:EnableTitleView( 'VIEW_V7B', STR0010 )    //"Informações dos vínculos/contratos incorporados"

	oView:AddGrid( 'VIEW_V7H', oStruV7H, 'MODEL_V7H' )
	oView:EnableTitleView( 'VIEW_V7H', STR0027 )    //"Informações dos períodos e valores "

	oView:AddGrid( 'VIEW_V7I', oStruV7I, 'MODEL_V7I' )
	oView:EnableTitleView( 'VIEW_V7I', STR0012 )    //"Identificação do período ao qual se referem as bases de cálculo"

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
		oView:AddGrid( 'VIEW_V7Q', oStruV7Q, 'MODEL_V7Q' )
		oView:EnableTitleView( 'VIEW_V7Q', STR0026 )    //"Identificação do(s) ano(s)-base em que houve indenização substitutiva de abono salarial."
	EndIf

	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
		oView:AddGrid( 'VIEW_T8F', oStruT8F, 'MODEL_T8F' )
		oView:EnableTitleView( 'VIEW_T8F', STR0028 )    //"Informações relativas ao trabalho intermitente"
	EndIf
	
	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0002 )   //"Informações do Processos"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0003 )   //"Informações do trabalhador"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0013 )   //"Informações de Controle eSocial"

	oView:CreateHorizontalBox( 'FIELDSV9Ua',   25,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'FIELDSV9Ub',   25,,, 'FOLDER_SUPERIOR', 'ABA01' )

	oView:CreateHorizontalBox( 'FIELDSV9Uc',   25,,, 'FOLDER_SUPERIOR', 'ABA02' )
	oView:CreateHorizontalBox( 'PAINEL_TRAB', 50,,, 'FOLDER_SUPERIOR', 'ABA02' )

	oView:CreateHorizontalBox( 'FIELDSV9Ud',   50,,, 'FOLDER_SUPERIOR', 'ABA03' )
	oView:CreateHorizontalBox( 'FIELDSV9Ue',   50,,, 'FOLDER_SUPERIOR', 'ABA03' )

	oView:CreateFolder( 'FOLDER_TRAB', 'PAINEL_TRAB' )
	
	If !lSimpl12 .Or. !lSimpl0103
		oView:AddSheet( 'FOLDER_TRAB', 'ABA01', STR0004 )   //"Informações dos dependentes"
		oView:CreateHorizontalBox( 'FIELDSV9V',   50,,, 'FOLDER_TRAB', 'ABA01' )
	EndIf	

	oView:AddSheet( 'FOLDER_TRAB', 'ABA02', STR0005 )   //"Informações do contrato de trabalho"

	oView:CreateHorizontalBox( 'FIELDSV9W',   25,,, 'FOLDER_TRAB', 'ABA02' )
	oView:CreateHorizontalBox( 'PAINEL_INFO', 25,,, 'FOLDER_TRAB', 'ABA02' )

	oView:CreateFolder( 'FOLDER_INFO', 'PAINEL_INFO' )

	oView:AddSheet( 'FOLDER_INFO', 'ABA01', STR0015 )   //"Informações complementares do contrato de trabalho"
	oView:AddSheet( 'FOLDER_INFO', 'ABA02', STR0016 )   //"Informação do novo código de categoria"
	oView:AddSheet( 'FOLDER_INFO', 'ABA03', STR0017 )   //Informações dos vínculos/contratos incorporados
	oView:AddSheet( 'FOLDER_INFO', 'ABA04', STR0018 )   //"Identificação do estabelecimento"

	oView:CreateHorizontalBox( 'FIELDSV9X',   20,,, 'FOLDER_INFO', 'ABA01' )
	oView:CreateHorizontalBox( 'PAINEL_COMPL', 80,,, 'FOLDER_INFO', 'ABA01' )

	oView:CreateFolder( 'FOLDER_COMPL', 'PAINEL_COMPL' )

	oView:AddSheet( 'FOLDER_COMPL', 'ABA01', STR0019 )   //"Remuneracao"
	oView:AddSheet( 'FOLDER_COMPL', 'ABA02', STR0020 )   //"Observacoes"
	
	oView:CreateHorizontalBox( 'FIELDSV9Y',   100,,, 'FOLDER_COMPL', 'ABA01' )
	oView:CreateHorizontalBox( 'FIELDSV9Z',   100,,, 'FOLDER_COMPL', 'ABA02' )	

	oView:CreateHorizontalBox( 'FIELDSV7A',   50,,, 'FOLDER_INFO', 'ABA02' )
	oView:CreateHorizontalBox( 'FIELDSV7B',   50,,, 'FOLDER_INFO', 'ABA03' )
	oView:CreateHorizontalBox( 'FIELDSV7H',   20,,, 'FOLDER_INFO', 'ABA04' )
	oView:CreateHorizontalBox( 'FIELDSV7I',   40,,, 'FOLDER_INFO', 'ABA04' )

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
		oView:CreateHorizontalBox( 'FIELDSV7Q',   20,,, 'FOLDER_INFO', 'ABA04' )
	EndIf

	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
		oView:CreateHorizontalBox( 'FIELDST8F',   20,,, 'FOLDER_INFO', 'ABA04' )
	EndIf	

	oView:SetOwnerView( 'VIEW_V9Ua' , 'FIELDSV9Ua')
	oView:SetOwnerView( 'VIEW_V9Ub' , 'FIELDSV9Ub')
	oView:SetOwnerView( 'VIEW_V9Uc' , 'FIELDSV9Uc')
	oView:SetOwnerView( 'VIEW_V9Ud' , 'FIELDSV9Ud')
	oView:SetOwnerView( 'VIEW_V9Ue' , 'FIELDSV9Ue')

	If  !lSimpl12 .Or. !lSimpl0103
		oView:SetOwnerView( 'VIEW_V9V' 	, 'FIELDSV9V' )
	EndIf	
	
	oView:SetOwnerView( 'VIEW_V9W' 	, 'FIELDSV9W' )
	oView:SetOwnerView( 'VIEW_V9Y' 	, 'FIELDSV9Y' )
	oView:SetOwnerView( 'VIEW_V9X' 	, 'FIELDSV9X' )
	oView:SetOwnerView( 'VIEW_V9Z' 	, 'FIELDSV9Z' )
	oView:SetOwnerView( 'VIEW_V7A' 	, 'FIELDSV7A' )
	oView:SetOwnerView( 'VIEW_V7B' 	, 'FIELDSV7B' )
	oView:SetOwnerView( 'VIEW_V7H' 	, 'FIELDSV7H' )
	oView:SetOwnerView( 'VIEW_V7I' 	, 'FIELDSV7I' )

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")	
		oView:SetOwnerView( 'VIEW_V7Q' 	, 'FIELDSV7Q' )
	EndIf

	If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")	
		oView:SetOwnerView( 'VIEW_T8F' 	, 'FIELDST8F' )
	EndIf	

	oStruV9Z:RemoveField( "V9Z_IDOBS")

	If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
		oStruV9Z:RemoveField("V9Z_IDOBS" )
	EndIf

	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidModel
Funcao de validação do Model
@author Karyna Martins / Silas Gomes
@since 24/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local oModelV9U  as object
	Local nOperation as numeric
	Local aAreaV9U   as array
	Local lRet       as logical

	Default oModel   := Nil

	oModelV9U   := oModel:GetModel( "MODEL_V9U" )
	nOperation  := oModel:GetOperation()
	aAreaV9U  	:= V9U->( GetArea() )
	lRet      	:= .T.

	If nOperation == MODEL_OPERATION_INSERT

		V9U->( DbSetOrder(6) )

		If V9U->( DbSeek( xFilial("V9U") + oModelV9U:GetValue( "V9U_NRPROC" ) + oModelV9U:GetValue( "V9U_CPFTRA" ) + "1" + IIf(lSimpl0103 .And. TafColumnPos("V9U_IDESEQ"), oModelV9U:GetValue( "V9U_IDESEQ" ), "")))
			oModel:SetErrorMessage(, , , , , STR0024, STR0025 , , )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaV9U )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel as object )

	Local cLogOpeAnt as character
	Local cVerAnt    as character
	Local cProtocolo as character
	Local cEvento    as character
	Local cLayout    as character
	Local cLayEve    as character
	Local nOperation as numeric
	Local nI		 as numeric
	Local nV9V		 as numeric
	Local nV9W		 as numeric
	Local nV9X		 as numeric
	Local nV9Y		 as numeric
	Local nV9Z		 as numeric
	Local nV7A		 as numeric
	Local nV7B		 as numeric
	Local nV7H		 as numeric
	Local nV7I		 as numeric
	Local nV7Q		 as numeric
	Local nT8F		 as numeric
	Local nV9VAdd	 as numeric
	Local nV7QAdd    as numeric
	Local aGravaV9U  as array
	Local aGravaV9V  as array
	Local aGravaV9W  as array
	Local aGravaV9X  as array
	Local aGravaV9Y  as array
	Local aGravaV9Z  as array
	Local aGravaV7A  as array
	Local aGravaV7B  as array
	Local aGravaV7H  as array
	Local aGravaV7I  as array
	Local aGravaV7Q  as array
	Local aGravaT8F  as array
	Local oModelV9U  as object
	Local oModelV9V  as object
	Local oModelV9W  as object
	Local oModelV9X  as object
	Local oModelV9Y  as object
	Local oModelV9Z  as object
	Local oModelV7A  as object
	Local oModelV7B  as object
	Local oModelV7H  as object
	Local oModelV7I  as object
	Local oModelV7Q  as object
	Local oModelT8F  as object

	Local lRetorno   as logical

	cLogOpeAnt 	:= ""
	cVerAnt    	:= ""
	cProtocolo 	:= ""
	cEvento    	:= ""
	cLayout		:= ""
	cLayEve		:= Iif( FindFunction('getVerLayout'), getVerLayout(), SuperGetMV("MV_TAFVLES"))
	nOperation 	:= oModel:GetOperation()
	nI			:= 0
	nV9V		:= 0
	nV9W		:= 0
	nV9X		:= 0
	nV9Y		:= 0
	nV9Z		:= 0
	nV7A		:= 0
	nV7B		:= 0
	nV7H		:= 0
	nV7I		:= 0
	nV7Q		:= 0
	nT8F		:= 0
	nV9VAdd		:= 0
	nV7QAdd		:= 0
	nT8FAdd		:= 0
	aGravaV9U 	:= {}
	aGravaV9V 	:= {}
	aGravaV9W 	:= {}
	aGravaV9X 	:= {}
	aGravaV9Y 	:= {}
	aGravaV9Z 	:= {}
	aGravaV7A 	:= {}
	aGravaV7B 	:= {}
	aGravaV7H 	:= {}
	aGravaV7I 	:= {}
	aGravaV7Q 	:= {}
	aGravaT8F 	:= {}
	oModelV9U  	:= oModel:GetModel( "MODEL_V9U")
	oModelV9V  	:= Iif(  !lSimpl12 , oModel:GetModel( "MODEL_V9V"), Nil)
	oModelV9W  	:= oModel:GetModel( "MODEL_V9W")
	oModelV9X  	:= Nil
	oModelV9Y  	:= Nil
	oModelV9Z  	:= Nil
	oModelV7A  	:= Nil
	oModelV7B  	:= Nil
	oModelV7H  	:= Nil
	oModelV7I  	:= Nil
	oModelV7Q  	:= Nil
	oModelT8F  	:= Nil
	lRetorno 	:= .T.

	Begin Transaction 

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "V9U", oModel)

			oModel:LoadValue( 'MODEL_V9U', 'V9U_VERSAO', xFunGetVer() 						)
			oModel:LoadValue( 'MODEL_V9U', 'V9U_NOMEVE', "S2500"		 					)
			oModel:LoadValue( 'MODEL_V9U', 'V9U_NMTRAB', Substr(FWFldGet("V9U_NMTRAB"),1,70) 	)

			oModel:LoadValue( "MODEL_V9U", "V9U_LAYOUT", cLayEve )
			
			If Findfunction("TAFAltMan")
				TAFAltMan( 3, 'Save', oModel, 'MODEL_V9U', 'V9U_LOGOPE', '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V9U->( DbSetOrder( 4 ) )
			If V9U->( MsSeek( xFilial( 'V9U' ) + V9U->V9U_ID + '1' ) )

				If V9U->V9U_STATUS $ '4'

					cLogOpeAnt := oModelV9U:GetValue( "V9U_LOGOPE" )
					
					cVerAnt 	:= oModelV9U:GetValue( "V9U_VERSAO" )
					cProtocolo	:= oModelV9U:GetValue( "V9U_PROTUL" )
					cEvento		:= oModelV9U:GetValue( "V9U_EVENTO" )
					cLayout		:= oModelV9U:GetValue( "V9U_LAYOUT" )

					For nI := 1 To Len( oModelV9U:aDataModel[ 1 ])
						Aadd( aGravaV9U, { oModelV9U:aDataModel[1, nI, 1], oModelV9U:aDataModel[1, nI, 2] } )
					Next

					If  !lSimpl12 .Or. !lSimpl0103
						V9V->( DBSetOrder(1) )
						If V9V->( MsSeek(xFilial('V9V') + V9U->(V9U_ID + V9U_VERSAO + V9U_NRPROC + V9U_CPFTRA) ) )
							For nV9V := 1 To oModel:GetModel("MODEL_V9V"):Length()
								oModel:GetModel("MODEL_V9V"):GoLine(nV9V)

								If !oModel:GetModel("MODEL_V9V"):IsEmpty() .And. !oModel:GetModel("MODEL_V9V"):IsDeleted()
									Aadd(aGravaV9V, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
														oModelV9V:GetValue("V9V_CPFDEP"),;
														oModelV9V:GetValue("V9V_TPDEP" ),;
														oModelV9V:GetValue("V9V_DSCDEP")})
								EndIf
							Next nV9V
						EndIf
					EndIf

            	    V9W->( DBSetOrder(1) )
					If V9W->( MsSeek(xFilial('V9W') + V9U->(V9U_ID + V9U_VERSAO + V9U_NRPROC + V9U_CPFTRA) ) )
						oModelV9X  := oModel:GetModel( "MODEL_V9X")
						oModelV9Y  := oModel:GetModel( "MODEL_V9Y")
						oModelV9Z  := oModel:GetModel( "MODEL_V9Z")
						oModelV7A  := oModel:GetModel( "MODEL_V7A")
						oModelV7B  := oModel:GetModel( "MODEL_V7B")
						oModelV7H  := oModel:GetModel( "MODEL_V7H")
						oModelV7I  := oModel:GetModel( "MODEL_V7I")
						If  (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS")
							oModelV7Q  := oModel:GetModel( "MODEL_V7Q")
						EndIf

						If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
							oModelT8F  := oModel:GetModel( "MODEL_T8F")
						EndIf

						For nV9W := 1 To oModel:GetModel("MODEL_V9W"):Length()
							oModel:GetModel("MODEL_V9W"):GoLine(nV9W)

							If !oModel:GetModel("MODEL_V9W"):IsEmpty() .And. !oModel:GetModel("MODEL_V9W"):IsDeleted()
								
								If !lSimpl12 .Or. !lSimpl0103
									Aadd(aGravaV9W, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
														oModelV9W:GetValue("V9W_MATRIC"),;
														oModelV9W:GetValue("V9W_CODCAT"),;
														oModelV9W:GetValue("V9W_DTINIC"),;
														oModelV9W:GetValue("V9W_TPCONT"),;
														oModelV9W:GetValue("V9W_INDCON"),;
														oModelV9W:GetValue("V9W_DTADMO"),;
														oModelV9W:GetValue("V9W_INDREI"),;
														oModelV9W:GetValue("V9W_INDCAT"),;
														oModelV9W:GetValue("V9W_INDNAT"),;
														oModelV9W:GetValue("V9W_INDMDE"),;
														oModelV9W:GetValue("V9W_INDUNI")})
								Else
									Aadd(aGravaV9W, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
														oModelV9W:GetValue("V9W_MATRIC"),;
														oModelV9W:GetValue("V9W_CODCAT"),;
														oModelV9W:GetValue("V9W_DTINIC"),;
														oModelV9W:GetValue("V9W_TPCONT"),;
														oModelV9W:GetValue("V9W_INDCON"),;
														oModelV9W:GetValue("V9W_DTADMO"),;
														oModelV9W:GetValue("V9W_INDREI"),;
														oModelV9W:GetValue("V9W_INDCAT"),;
														oModelV9W:GetValue("V9W_INDNAT"),;
														oModelV9W:GetValue("V9W_INDMDE")})
								EndIf
													
								For nV9X := 1 To oModel:GetModel("MODEL_V9X"):Length()
									oModel:GetModel("MODEL_V9X"):GoLine(nV9X)

									If !oModel:GetModel("MODEL_V9X"):IsEmpty() .And. !oModel:GetModel("MODEL_V9X"):IsDeleted()

										If lSimpl12 .Or. lSimpl0103
											Aadd(aGravaV9X, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																oModelV9X:GetValue("V9X_CODCBO"),;
																oModelV9X:GetValue("V9X_NATATV"),;
																oModelV9X:GetValue("V9X_TPREGT"),;
																oModelV9X:GetValue("V9X_TPREGP"),;
																oModelV9X:GetValue("V9X_DTADM"),;
																oModelV9X:GetValue("V9X_TMPPAR"),;
																oModelV9X:GetValue("V9X_TPCDUR"),;
																oModelV9X:GetValue("V9X_DTTERM"),;
																oModelV9X:GetValue("V9X_CLAASS"),;
																oModelV9X:GetValue("V9X_OBJDET"),;
																oModelV9X:GetValue("V9X_TPINSC"),;
																oModelV9X:GetValue("V9X_NRINSC"),;
																oModelV9X:GetValue("V9X_MATANT"),;
																oModelV9X:GetValue("V9X_DTTRAN"),;
																oModelV9X:GetValue("V9X_DTDESL"),;
																oModelV9X:GetValue("V9X_MTVDES"),;
																oModelV9X:GetValue("V9X_DTFPRO"),;
																oModelV9X:GetValue("V9X_DTFIM"),;
																oModelV9X:GetValue("V9X_MTDTSV"),;
																oModelV9X:GetValue("V9X_PENSAL"),;
																oModelV9X:GetValue("V9X_PERCAL"),;
																oModelV9X:GetValue("V9X_VRALIM")})
										Else
											Aadd(aGravaV9X, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																oModelV9X:GetValue("V9X_CODCBO"),;
																oModelV9X:GetValue("V9X_NATATV"),;
																oModelV9X:GetValue("V9X_TPREGT"),;
																oModelV9X:GetValue("V9X_TPREGP"),;
																oModelV9X:GetValue("V9X_DTADM"),;
																oModelV9X:GetValue("V9X_TMPPAR"),;
																oModelV9X:GetValue("V9X_TPCDUR"),;
																oModelV9X:GetValue("V9X_DTTERM"),;
																oModelV9X:GetValue("V9X_CLAASS"),;
																oModelV9X:GetValue("V9X_OBJDET"),;
																oModelV9X:GetValue("V9X_TPINSC"),;
																oModelV9X:GetValue("V9X_NRINSC"),;
																oModelV9X:GetValue("V9X_MATANT"),;
																oModelV9X:GetValue("V9X_DTTRAN"),;
																oModelV9X:GetValue("V9X_DTDESL"),;
																oModelV9X:GetValue("V9X_MTVDES"),;
																oModelV9X:GetValue("V9X_DTFPRO"),;
																oModelV9X:GetValue("V9X_DTFIM"),;
																oModelV9X:GetValue("V9X_MTDTSV")})
										EndIf

											For nV9Y := 1 To oModel:GetModel("MODEL_V9Y"):Length()
												oModel:GetModel("MODEL_V9Y"):GoLine(nV9Y)

												If !oModel:GetModel("MODEL_V9Y"):IsEmpty() .And. !oModel:GetModel("MODEL_V9Y"):IsDeleted()
													Aadd(aGravaV9Y, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																		oModelV9Y:GetValue("V9Y_DTREMU"),;
																		oModelV9Y:GetValue("V9Y_VRSAL"),;
																		oModelV9Y:GetValue("V9Y_UNDSAL"),;
																		oModelV9Y:GetValue("V9Y_DSCSAL")})
												EndIf
											Next nV9Y

											For nV9Z := 1 To oModel:GetModel("MODEL_V9Z"):Length()
												oModel:GetModel("MODEL_V9Z"):GoLine(nV9Z)

												If !oModel:GetModel("MODEL_V9Z"):IsEmpty() .And. !oModel:GetModel("MODEL_V9Z"):IsDeleted()
													Aadd(aGravaV9Z, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																		oModelV9Z:GetValue("V9Z_OBS"),;
																		oModelV9Z:GetValue("V9Z_IDOBS")})
												EndIf
											Next nV9Z
										EndIf
									Next nV9X

									For nV7A := 1 To oModel:GetModel("MODEL_V7A"):Length()
										oModel:GetModel("MODEL_V7A"):GoLine(nV7A)

										If !oModel:GetModel("MODEL_V7A"):IsEmpty() .And. !oModel:GetModel("MODEL_V7A"):IsDeleted()
											Aadd(aGravaV7A, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																oModelV7A:GetValue("V7A_NEWCAT"),;
																oModelV7A:GetValue("V7A_NATATV"),;
																oModelV7A:GetValue("V7A_DTMUDC")})
										EndIf
									Next nV7A

									For nV7B := 1 To oModel:GetModel("MODEL_V7B"):Length()
										oModel:GetModel("MODEL_V7B"):GoLine(nV7B)

										If !oModel:GetModel("MODEL_V7B"):IsEmpty() .And. !oModel:GetModel("MODEL_V7B"):IsDeleted()
											Aadd(aGravaV7B, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																oModelV7B:GetValue("V7B_MATUNI"),;
																oModelV7B:GetValue("V7B_NEWCAT"),;
																oModelV7B:GetValue("V7B_DTTSV")})
										EndIf
									Next nV7B

									For nV7H := 1 To oModel:GetModel("MODEL_V7H"):Length()
										oModel:GetModel("MODEL_V7H"):GoLine(nV7H)

										If !oModel:GetModel("MODEL_V7H"):IsEmpty() .And. !oModel:GetModel("MODEL_V7H"):IsDeleted()
											
											If !lSimpl12 
												Aadd(aGravaV7H, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																	oModelV7H:GetValue("V7H_TPINSC"),;
																	oModelV7H:GetValue("V7H_NRINSC"),;
																	oModelV7H:GetValue("V7H_COMPIN"),;
																	oModelV7H:GetValue("V7H_COMPFI"),;
																	oModelV7H:GetValue("V7H_REPPRO"),;
																	oModelV7H:GetValue("V7H_VLVERB"),;
																	oModelV7H:GetValue("V7H_VLAVSP"),;
																	oModelV7H:GetValue("V7H_VRAPI"),;
																	oModelV7H:GetValue("V7H_VLINDE"),;
																	oModelV7H:GetValue("V7H_VLBASE"),;
																	oModelV7H:GetValue("V7H_PAGDIR")})
											Else
												Aadd(aGravaV7H, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
																	oModelV7H:GetValue("V7H_TPINSC"),;
																	oModelV7H:GetValue("V7H_NRINSC"),;
																	oModelV7H:GetValue("V7H_COMPIN"),;
																	oModelV7H:GetValue("V7H_COMPFI"),;
																	oModelV7H:GetValue("V7H_INDREP"),;
																	oModelV7H:GetValue("V7H_INDESD"),;
																	oModelV7H:GetValue("V7H_INDABO")})
											EndIf
										EndIf
									Next nV7H

								For nV7I := 1 To oModel:GetModel("MODEL_V7I"):Length()
									oModel:GetModel("MODEL_V7I"):GoLine(nV7I)
									If !oModel:GetModel("MODEL_V7I"):IsEmpty() .And. !oModel:GetModel("MODEL_V7I"):IsDeleted()

										If !lSimpl12 
											Aadd(aGravaV7I, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
																oModelV7I:GetValue("V7I_PERREF"),;
																oModelV7I:GetValue("V7I_VRMEN"),;
																oModelV7I:GetValue("V7I_VRCP"),;
																oModelV7I:GetValue("V7I_VRFGTS"),;
																oModelV7I:GetValue("V7I_BCFGTS"),;
																oModelV7I:GetValue("V7I_GRAUEX"),;
																oModelV7I:GetValue("V7I_VRFGUI"),;
																oModelV7I:GetValue("V7I_FGTSGU"),;
																oModelV7I:GetValue("V7I_PAGDIR"),;
																oModelV7I:GetValue("V7I_CATMUD"),;
																oModelV7I:GetValue("V7I_VRPREV")})
										Else
											Aadd(aGravaV7I, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
																oModelV7I:GetValue("V7I_PERREF"),;
																oModelV7I:GetValue("V7I_VRMEN"),;
																oModelV7I:GetValue("V7I_VRCP"),;
																oModelV7I:GetValue("V7I_GRAUEX"),;
																oModelV7I:GetValue("V7I_CATMUD"),;
																oModelV7I:GetValue("V7I_VRPREV"),;
																oModelV7I:GetValue("V7I_BCPROT"),;
																oModelV7I:GetValue("V7I_BCSEFI"),;
																oModelV7I:GetValue("V7I_BCSEFI")})
										EndIf	
									EndIF
								Next nV7I

								If lSimpl12 .Or. lSimpl0103
									For nV7Q := 1 To oModel:GetModel("MODEL_V7Q"):Length()
										oModel:GetModel("MODEL_V7Q"):GoLine(nV7Q)

										If !oModel:GetModel("MODEL_V7Q"):IsEmpty() .And. !oModel:GetModel("MODEL_V7Q"):IsDeleted()
											Aadd(aGravaV7Q, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
																oModelV7Q:GetValue("V7Q_ANOBAS")})
																
										EndIF
									Next nV7Q
								EndIf

								If lSimpl0103.And. TafColumnPos("T8F_DIATRA")
									For nT8F := 1 To oModel:GetModel("MODEL_T8F"):Length()
										oModel:GetModel("MODEL_T8F"):GoLine(nT8F)

										If !oModel:GetModel("MODEL_T8F"):IsEmpty() .And. !oModel:GetModel("MODEL_T8F"):IsDeleted()
											Aadd(aGravaT8F, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
																oModelT8F:GetValue("T8F_DIATRA"),;
																oModelT8F:GetValue("T8F_HRSTRA")})
																
										EndIF
									Next nT8F
								EndIf	
							EndIf
						Next nV9W
					EndIf

					FAltRegAnt( 'V9U', '2' )

					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()	

					For nI := 1 to Len( aGravaV9U )
            	        oModel:LoadValue( "MODEL_V9U", aGravaV9U[ nI, 1 ], aGravaV9U[ nI, 2 ] )
            	    Next nI			

            	    TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V9U', 'V9U_LOGOPE' , '' , cLogOpeAnt )
            	    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()	
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

					oModel:LoadValue( 'MODEL_V9U', 'V9U_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_V9U', 'V9U_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_V9U', 'V9U_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_V9U', 'V9U_PROTUL', "" )
					oModel:LoadValue( 'MODEL_V9U', 'V9U_LAYOUT', cLayout )

					If !lSimpl12
						nV9VAdd := 1
						For nV9V := 1 To Len(aGravaV9V)
							oModel:GetModel("MODEL_V9V"):lValid := .T.

							If nV9VAdd > 1 
								oModel:GetModel("MODEL_V9V"):AddLine()
							EndIf

							oModel:LoadValue("MODEL_V9V", "V9V_CPFDEP", aGravaV9V[nV9V][2])
							oModel:LoadValue("MODEL_V9V", "V9V_TPDEP", 	aGravaV9V[nV9V][3])
							oModel:LoadValue("MODEL_V9V", "V9V_DSCDEP", aGravaV9V[nV9V][4])					

							nV9VAdd++
						Next
					EndIf

					nV9WAdd := 1
					For nV9W := 1 To Len(aGravaV9W)
						oModel:GetModel("MODEL_V9W"):lValid := .T.

						If nV9WAdd > 1 
							oModel:GetModel("MODEL_V9W"):AddLine()
						EndIf

						If !lSimpl12 
							oModel:LoadValue("MODEL_V9W", "V9W_MATRIC", aGravaV9W[nV9W][2])
							oModel:LoadValue("MODEL_V9W", "V9W_CODCAT", aGravaV9W[nV9W][3])
							oModel:LoadValue("MODEL_V9W", "V9W_DTINIC", aGravaV9W[nV9W][4])
							oModel:LoadValue("MODEL_V9W", "V9W_TPCONT", aGravaV9W[nV9W][5])
							oModel:LoadValue("MODEL_V9W", "V9W_INDCON", aGravaV9W[nV9W][6])
							oModel:LoadValue("MODEL_V9W", "V9W_DTADMO", aGravaV9W[nV9W][7])
							oModel:LoadValue("MODEL_V9W", "V9W_INDREI", aGravaV9W[nV9W][8])
							oModel:LoadValue("MODEL_V9W", "V9W_INDCAT", aGravaV9W[nV9W][9])
							oModel:LoadValue("MODEL_V9W", "V9W_INDNAT", aGravaV9W[nV9W][10])
							oModel:LoadValue("MODEL_V9W", "V9W_INDMDE", aGravaV9W[nV9W][11])
							oModel:LoadValue("MODEL_V9W", "V9W_INDUNI", aGravaV9W[nV9W][12])
						Else
							oModel:LoadValue("MODEL_V9W", "V9W_MATRIC", aGravaV9W[nV9W][2])
							oModel:LoadValue("MODEL_V9W", "V9W_CODCAT", aGravaV9W[nV9W][3])
							oModel:LoadValue("MODEL_V9W", "V9W_DTINIC", aGravaV9W[nV9W][4])
							oModel:LoadValue("MODEL_V9W", "V9W_TPCONT", aGravaV9W[nV9W][5])
							oModel:LoadValue("MODEL_V9W", "V9W_INDCON", aGravaV9W[nV9W][6])
							oModel:LoadValue("MODEL_V9W", "V9W_DTADMO", aGravaV9W[nV9W][7])
							oModel:LoadValue("MODEL_V9W", "V9W_INDREI", aGravaV9W[nV9W][8])
							oModel:LoadValue("MODEL_V9W", "V9W_INDCAT", aGravaV9W[nV9W][9])
							oModel:LoadValue("MODEL_V9W", "V9W_INDNAT", aGravaV9W[nV9W][10])
							oModel:LoadValue("MODEL_V9W", "V9W_INDMDE", aGravaV9W[nV9W][11])
						EndIf
						
						For nV9X := 1 To Len(aGravaV9X)

							If aGravaV9X[nV9X][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

								oModel:GetModel("MODEL_V9X"):lValid := .T.						

								If !lSimpl12  
									oModel:LoadValue("MODEL_V9X", "V9X_CODCBO", aGravaV9X[nV9X][2])
									oModel:LoadValue("MODEL_V9X", "V9X_NATATV", aGravaV9X[nV9X][3])
									oModel:LoadValue("MODEL_V9X", "V9X_TPREGT", aGravaV9X[nV9X][4])
									oModel:LoadValue("MODEL_V9X", "V9X_TPREGP", aGravaV9X[nV9X][5])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTADM", 	aGravaV9X[nV9X][6])		
									oModel:LoadValue("MODEL_V9X", "V9X_TMPPAR", aGravaV9X[nV9X][7])		
									oModel:LoadValue("MODEL_V9X", "V9X_TPCDUR", aGravaV9X[nV9X][8])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTTERM", aGravaV9X[nV9X][9])		
									oModel:LoadValue("MODEL_V9X", "V9X_CLAASS", aGravaV9X[nV9X][10])		
									oModel:LoadValue("MODEL_V9X", "V9X_OBJDET", aGravaV9X[nV9X][11])		
									oModel:LoadValue("MODEL_V9X", "V9X_TPINSC", aGravaV9X[nV9X][12])		
									oModel:LoadValue("MODEL_V9X", "V9X_NRINSC", aGravaV9X[nV9X][13])		
									oModel:LoadValue("MODEL_V9X", "V9X_MATANT", aGravaV9X[nV9X][14])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTTRAN", aGravaV9X[nV9X][15])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTDESL", aGravaV9X[nV9X][16])		
									oModel:LoadValue("MODEL_V9X", "V9X_MTVDES", aGravaV9X[nV9X][17])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTFPRO", aGravaV9X[nV9X][18])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTFIM", 	aGravaV9X[nV9X][19])		
									oModel:LoadValue("MODEL_V9X", "V9X_MTDTSV", aGravaV9X[nV9X][20])
								Else
									oModel:LoadValue("MODEL_V9X", "V9X_CODCBO", aGravaV9X[nV9X][2])
									oModel:LoadValue("MODEL_V9X", "V9X_NATATV", aGravaV9X[nV9X][3])
									oModel:LoadValue("MODEL_V9X", "V9X_TPREGT", aGravaV9X[nV9X][4])
									oModel:LoadValue("MODEL_V9X", "V9X_TPREGP", aGravaV9X[nV9X][5])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTADM", 	aGravaV9X[nV9X][6])		
									oModel:LoadValue("MODEL_V9X", "V9X_TMPPAR", aGravaV9X[nV9X][7])		
									oModel:LoadValue("MODEL_V9X", "V9X_TPCDUR", aGravaV9X[nV9X][8])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTTERM", aGravaV9X[nV9X][9])		
									oModel:LoadValue("MODEL_V9X", "V9X_CLAASS", aGravaV9X[nV9X][10])		
									oModel:LoadValue("MODEL_V9X", "V9X_OBJDET", aGravaV9X[nV9X][11])		
									oModel:LoadValue("MODEL_V9X", "V9X_TPINSC", aGravaV9X[nV9X][12])		
									oModel:LoadValue("MODEL_V9X", "V9X_NRINSC", aGravaV9X[nV9X][13])		
									oModel:LoadValue("MODEL_V9X", "V9X_MATANT", aGravaV9X[nV9X][14])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTTRAN", aGravaV9X[nV9X][15])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTDESL", aGravaV9X[nV9X][16])		
									oModel:LoadValue("MODEL_V9X", "V9X_MTVDES", aGravaV9X[nV9X][17])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTFPRO", aGravaV9X[nV9X][18])		
									oModel:LoadValue("MODEL_V9X", "V9X_DTFIM", 	aGravaV9X[nV9X][19])		
									oModel:LoadValue("MODEL_V9X", "V9X_MTDTSV", aGravaV9X[nV9X][20])
									oModel:LoadValue("MODEL_V9X", "V9X_PENSAL", aGravaV9X[nV9X][21])
									oModel:LoadValue("MODEL_V9X", "V9X_PERCAL", aGravaV9X[nV9X][22])
									oModel:LoadValue("MODEL_V9X", "V9X_VRALIM", aGravaV9X[nV9X][23])
								EndIf

								nV9YAdd := 1
								For nV9Y := 1 To Len(aGravaV9Y)

									If aGravaV9Y[nV9Y][1] == aGravaV9X[nV9X][1]

										oModel:GetModel("MODEL_V9Y"):lValid := .T.

										If nV9YAdd > 1
											oModel:GetModel("MODEL_V9Y"):AddLine()
										EndIf

										oModel:LoadValue("MODEL_V9Y", "V9Y_DTREMU", aGravaV9Y[nV9Y][2])		
										oModel:LoadValue("MODEL_V9Y", "V9Y_VRSAL", aGravaV9Y[nV9Y][3])		
										oModel:LoadValue("MODEL_V9Y", "V9Y_UNDSAL", aGravaV9Y[nV9Y][4])		
										oModel:LoadValue("MODEL_V9Y", "V9Y_DSCSAL", aGravaV9Y[nV9Y][5])

										nV9YAdd++

									EndIF
								Next 

								nV9ZAdd := 1
								For nV9Z := 1 To Len(aGravaV9Z)

									If aGravaV9Z[nV9Z][1] == aGravaV9X[nV9X][1]

										oModel:GetModel("MODEL_V9Z"):lValid := .T.

										If nV9ZAdd > 1
											oModel:GetModel("MODEL_V9Z"):AddLine()
										EndIf

										oModel:LoadValue("MODEL_V9Z", "V9Z_OBS", aGravaV9Z[nV9Z][2])
										oModel:LoadValue("MODEL_V9Z", "V9Z_IDOBS", aGravaV9Z[nV9Z][3])

										nV9ZAdd++

									EndIf
								Next
							EndIf
						Next

						nV7AAdd := 1
						For nV7A := 1 To Len(aGravaV7A)

							If aGravaV7A[nV7A][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

								oModel:GetModel("MODEL_V7A"):lValid := .T.

								If nV7AAdd > 1
									oModel:GetModel("MODEL_V7A"):AddLine()
								EndIf

								oModel:LoadValue("MODEL_V7A", "V7A_NEWCAT", aGravaV7A[nV7A][2])
								oModel:LoadValue("MODEL_V7A", "V7A_NATATV", aGravaV7A[nV7A][3])
								oModel:LoadValue("MODEL_V7A", "V7A_DTMUDC", aGravaV7A[nV7A][4])

								nV7AAdd++

							EndIf
						Next

						nV7BAdd := 1
						For nV7B := 1 To Len(aGravaV7B)

							If aGravaV7B[nV7B][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

								oModel:GetModel("MODEL_V7B"):lValid := .T.

								If nV7BAdd > 1
									oModel:GetModel("MODEL_V7B"):AddLine()
								EndIf

								oModel:LoadValue("MODEL_V7B", "V7B_MATUNI", aGravaV7B[nV7B][2])
								oModel:LoadValue("MODEL_V7B", "V7B_NEWCAT", aGravaV7B[nV7B][3])
								oModel:LoadValue("MODEL_V7B", "V7B_DTTSV", aGravaV7B[nV7B][4])

								nV7BAdd++
							
							EndIF
						Next

						nV7HAdd := 1
						For nV7H := 1 To Len(aGravaV7H)

							If aGravaV7H[nV7H][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

								oModel:GetModel("MODEL_V7H"):lValid := .T.

								If !lSimpl12   
									oModel:LoadValue("MODEL_V7H", "V7H_TPINSC", aGravaV7H[nV7H][2])
									oModel:LoadValue("MODEL_V7H", "V7H_NRINSC", aGravaV7H[nV7H][3])
									oModel:LoadValue("MODEL_V7H", "V7H_COMPIN", aGravaV7H[nV7H][4])
									oModel:LoadValue("MODEL_V7H", "V7H_COMPFI", aGravaV7H[nV7H][5])
									oModel:LoadValue("MODEL_V7H", "V7H_REPPRO", aGravaV7H[nV7H][6])								
									oModel:LoadValue("MODEL_V7H", "V7H_VLVERB", aGravaV7H[nV7H][7])
									oModel:LoadValue("MODEL_V7H", "V7H_VLAVSP", aGravaV7H[nV7H][8])
									oModel:LoadValue("MODEL_V7H", "V7H_VRAPI" , aGravaV7H[nV7H][9])
									oModel:LoadValue("MODEL_V7H", "V7H_VLINDE", aGravaV7H[nV7H][10])
									oModel:LoadValue("MODEL_V7H", "V7H_VLBASE", aGravaV7H[nV7H][11])
									oModel:LoadValue("MODEL_V7H", "V7H_PAGDIR", aGravaV7H[nV7H][12])
								Else
									oModel:LoadValue("MODEL_V7H", "V7H_TPINSC", aGravaV7H[nV7H][2])
									oModel:LoadValue("MODEL_V7H", "V7H_NRINSC", aGravaV7H[nV7H][3])
									oModel:LoadValue("MODEL_V7H", "V7H_COMPIN", aGravaV7H[nV7H][4])
									oModel:LoadValue("MODEL_V7H", "V7H_COMPFI", aGravaV7H[nV7H][5])
									oModel:LoadValue("MODEL_V7H", "V7H_INDREP", aGravaV7H[nV7H][6])
									oModel:LoadValue("MODEL_V7H", "V7H_INDESD", aGravaV7H[nV7H][7])
									oModel:LoadValue("MODEL_V7H", "V7H_INDABO", aGravaV7H[nV7H][8])
								EndIf

								nV7IAdd := 1
								For nV7I := 1 To Len(aGravaV7I)

									If aGravaV7I[nV7I][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

										oModel:GetModel("MODEL_V7I"):lValid := .T.

										If nV7IAdd > 1
											oModel:GetModel("MODEL_V7I"):AddLine()
										EndIf

										If !lSimpl12 
											oModel:LoadValue("MODEL_V7I", "V7I_PERREF", aGravaV7I[nV7I][2])
											oModel:LoadValue("MODEL_V7I", "V7I_VRMEN", 	aGravaV7I[nV7I][3])
											oModel:LoadValue("MODEL_V7I", "V7I_VRCP", 	aGravaV7I[nV7I][4])
											oModel:LoadValue("MODEL_V7I", "V7I_VRFGTS", aGravaV7I[nV7I][5])
											oModel:LoadValue("MODEL_V7I", "V7I_BCFGTS", aGravaV7I[nV7I][6])
											oModel:LoadValue("MODEL_V7I", "V7I_GRAUEX", aGravaV7I[nV7I][7])
											oModel:LoadValue("MODEL_V7I", "V7I_VRFGUI", aGravaV7I[nV7I][8])
											oModel:LoadValue("MODEL_V7I", "V7I_FGTSGU", aGravaV7I[nV7I][9])
											oModel:LoadValue("MODEL_V7I", "V7I_PAGDIR", aGravaV7I[nV7I][10])
											oModel:LoadValue("MODEL_V7I", "V7I_CATMUD", aGravaV7I[nV7I][11])
											oModel:LoadValue("MODEL_V7I", "V7I_VRPREV", aGravaV7I[nV7I][12])
										Else
											oModel:LoadValue("MODEL_V7I", "V7I_PERREF", aGravaV7I[nV7I][2])
											oModel:LoadValue("MODEL_V7I", "V7I_VRMEN", 	aGravaV7I[nV7I][3])
											oModel:LoadValue("MODEL_V7I", "V7I_VRCP", 	aGravaV7I[nV7I][4])
											oModel:LoadValue("MODEL_V7I", "V7I_GRAUEX", aGravaV7I[nV7I][5])
											oModel:LoadValue("MODEL_V7I", "V7I_CATMUD", aGravaV7I[nV7I][6])
											oModel:LoadValue("MODEL_V7I", "V7I_VRPREV", aGravaV7I[nV7I][7])
											oModel:LoadValue("MODEL_V7I", "V7I_BCPROT", aGravaV7I[nV7I][8])
											oModel:LoadValue("MODEL_V7I", "V7I_BCSEFI", aGravaV7I[nV7I][9])
											oModel:LoadValue("MODEL_V7I", "V7I_BCDECA", aGravaV7I[nV7I][10])
										EndIf
										
										nV7IAdd++
									
									EndIf

								Next

								If lSimpl12 .Or. lSimpl0103
									nV7QAdd := 1
									For nV7Q := 1 To Len(aGravaV7Q)

										If aGravaV7Q[nV7Q][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

											oModel:GetModel("MODEL_V7Q"):lValid := .T.

											If nV7QAdd > 1
												oModel:GetModel("MODEL_V7Q"):AddLine()
											EndIf

											oModel:LoadValue("MODEL_V7Q", "V7Q_ANOBAS", aGravaV7Q[nV7Q][2])
											
											nV7QAdd++	

										EndIf
									Next
								EndIf	

								If lSimpl0103 .AND. TAFColumnPos("T8F_DIATRA")

									nT8FAdd := 1
									For nT8F := 1 To Len(aGravaT8F)

										If aGravaT8F[nT8F][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

											oModel:GetModel("MODEL_T8F"):lValid := .T.

											If nT8FAdd > 1
												oModel:GetModel("MODEL_T8F"):AddLine()
											EndIf

											oModel:LoadValue("MODEL_T8F", "T8F_DIATRA", aGravaT8F[nT8F][2])
											oModel:LoadValue("MODEL_T8F", "T8F_HRSTRA", aGravaT8F[nT8F][3])
											
											nT8FAdd++	

										EndIf
									Next
									
								EndIf	

								nV7HAdd++
							
							EndIf

						Next

						nV9WAdd++
					Next

					oModel:LoadValue( "MODEL_V9U", "V9U_EVENTO", "A" )						

					FwFormCommit( oModel )
					TAFAltStat( 'V9U', " " )
				
				Else
					cLogOpeAnt := V9U->V9U_LOGOPE				

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V9U', 'V9U_LOGOPE' , '' , cLogOpeAnt )
					
					oModel:LoadValue( "MODEL_V9U", "V9U_LAYOUT", cLayEve )
					
					FwFormCommit( oModel )
					TAFAltStat( 'V9U', " " )
				EndIf
			EndIf		
		
		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V9U', "" )
			FwFormCommit( oModel )

			If V9U->V9U_EVENTO == "A" .Or. V9U->V9U_EVENTO == "E"
				TAFRastro( 'V9U', 1, V9U->(V9U_ID + V9U_VERANT), .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
		EndIf

	End Transaction

Return ( lRetorno )			

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF608Inc
Monta a View dinâmica
@author  Silas/Karyna
@since   18/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF608Inc( cAlias as character, nRecno as numeric)

	Local aArea 	as array 
	Local oExecView	as object 
	Local oNewView	as object
	Local nOpc		as numeric

	aArea 		:= GetArea()
	oExecView	:= Nil
	oNewView	:= ViewDef()
	nOpc		:= 3

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( nOpc )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return nOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF608View
Monta a View dinâmica
@author  Silas/Karyna
@since   18/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF608View( cAlias as character, nRecno as numeric )

	Local aArea 	as array
	Local oExecView	as object
	Local oNewView	as object
	Local nOpc		as numeric

	aArea 		:= GetArea()
	oExecView	:= Nil
	oNewView	:= ViewDef()
	nOpc		:= 1

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( nOpc )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return nOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3500)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel as object, nRecno as numeric, lRotExc as logical )

	Local aDataModel as array
	Local aGravaV7A  as array
	Local aGravaV7B  as array
	Local aGravaV7H  as array
	Local aGravaV7I  as array
	Local aGravaV7Q  as array
	Local aGravaV9U  as array
	Local aGravaV9V  as array
	Local aGravaV9W  as array
	Local aGravaV9X  as array
	Local aGravaV9Y  as array
	Local aGravaV9Z  as array
	Local aGravaT8F  as array
	Local cEvento    as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local nI         as numeric
	Local nV7A       as numeric
	Local nV7B       as numeric
	Local nV7H       as numeric
	Local nV7I       as numeric
	Local nV7Q       as numeric
	Local nV7QAdd    as numeric
	Local nV9U       as numeric
	Local nV9V       as numeric
	Local nV9W       as numeric
	Local nV9X       as numeric
	Local nV9Y       as numeric
	Local nV9Z       as numeric
	Local nT8F       as numeric
	Local nT8FAdd    as numeric
	LocaL oModelV7A  as object
	LocaL oModelV7B  as object
	LocaL oModelV7H  as object
	LocaL oModelV7I  as object
	LocaL oModelV7Q  as object
	LocaL oModelV9U  as object
	LocaL oModelV9V  as object
	LocaL oModelV9W  as object
	LocaL oModelV9X  as object
	LocaL oModelV9Y  as object
	LocaL oModelV9Z  as object
	LocaL oModelT8F  as object

	aDataModel := {}
	aGravaV7A  := {}
	aGravaV7B  := {}
	aGravaV7H  := {}
	aGravaV7I  := {}
	aGravaV7Q  := {}
	aGravaV9U  := {}
	aGravaV9V  := {}
	aGravaV9W  := {}
	aGravaV9X  := {}
	aGravaV9Y  := {}
	aGravaV9Z  := {}
	aGravaT8F  := {}
	cEvento    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	nI         := 0
	nV7A       := 0
	nV7B       := 0
	nV7H       := 0
	nV7I       := 0
	nV7Q       := 0
	nV7QAdd    := 0
	nV9U       := 0
	nV9V       := 0
	nV9W       := 0
	nV9X       := 0
	nV9Y       := 0
	nV9Z       := 0
	nT8F       := 0
	nT8FAdd    := 0
	oModelV7A  := Nil
	oModelV7B  := Nil
	oModelV7H  := Nil
	oModelV7I  := Nil
	oModelV7Q  := Iif( (lSimpl12 .Or. lSimpl0103) .And. TafColumnPos("V7Q_ANOBAS"), oModel:GetModel( "MODEL_V7Q"), Nil)
	oModelV9U  := Nil
	oModelV9V  := Nil
	oModelV9W  := Nil
	oModelV9X  := Nil
	oModelV9Y  := Nil
	oModelV9Z  := Nil
	oModelT8F  := Iif( lSimpl0103 .And. TafColumnPos("T8F_DIATRA"), oModel:GetModel( "MODEL_T8F"), Nil)

	Begin Transaction

		("V9U")->( DBGoTo( nRecno ) )

		oModelV9U	:= oModel:GetModel( 'MODEL_V9U' )

		If !lSimpl12 
			oModelV9V	:= oModel:GetModel( 'MODEL_V9V' )
		EndIf

		oModelV9W	:= oModel:GetModel( 'MODEL_V9W' )

		cVerAnt 	:= oModelV9U:GetValue( "V9U_VERSAO" )
		cProtocolo	:= oModelV9U:GetValue( "V9U_PROTUL" )
		cEvento		:= oModelV9U:GetValue( "V9U_EVENTO" )

		For nI := 1 To Len( oModelV9U:aDataModel[1] )
			aAdd( aGravaV9U, { oModelV9U:aDataModel[1, nI, 1], oModelV9U:aDataModel[1, nI, 2] } )
		Next nI

		If !lSimpl12 
			V9V->( DBSetOrder(1) )
			If V9V->( MsSeek(xFilial('V9V') + V9U->(V9U_ID + V9U_VERSAO) ) )
				For nV9V := 1 To oModel:GetModel("MODEL_V9V"):Length()
					oModel:GetModel("MODEL_V9V"):GoLine(nV9V)

					If !oModel:GetModel("MODEL_V9V"):IsEmpty() .And. !oModel:GetModel("MODEL_V9V"):IsDeleted()
						Aadd(aGravaV9V, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
											oModelV9V:GetValue("V9V_CPFDEP"),;
											oModelV9V:GetValue("V9V_TPDEP" ),;
											oModelV9V:GetValue("V9V_DSCDEP")})
					EndIf
				Next nV9V
			EndIf
		EndIf

		V9W->( DbSetOrder(1) )
		If V9W->( MsSeek(xFilial('V9W') + V9U->(V9U_ID + V9U_VERSAO) ) )
			oModelV9X  := oModel:GetModel('MODEL_V9X')
			oModelV9Y  := oModel:GetModel('MODEL_V9Y')
			oModelV9Z  := oModel:GetModel('MODEL_V9Z')
			oModelV7A  := oModel:GetModel('MODEL_V7A')
			oModelV7B  := oModel:GetModel('MODEL_V7B')
			oModelV7H  := oModel:GetModel('MODEL_V7H')
			oModelV7I  := oModel:GetModel('MODEL_V7I')

			For nV9W := 1 To oModel:GetModel('MODEL_V9W'):Length()
				oModel:GetModel('MODEL_V9W'):GoLine(nV9W)

				If !oModel:GetModel("MODEL_V9W"):IsEmpty() .And. !oModel:GetModel("MODEL_V9W"):IsDeleted()

					If !lSimpl12 
						Aadd(aGravaV9W, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
											oModelV9W:GetValue("V9W_MATRIC"),;
											oModelV9W:GetValue("V9W_CODCAT"),;
											oModelV9W:GetValue("V9W_DTINIC"),;
											oModelV9W:GetValue("V9W_TPCONT"),;
											oModelV9W:GetValue("V9W_INDCON"),;
											oModelV9W:GetValue("V9W_DTADMO"),;
											oModelV9W:GetValue("V9W_INDREI"),;
											oModelV9W:GetValue("V9W_INDCAT"),;
											oModelV9W:GetValue("V9W_INDNAT"),;
											oModelV9W:GetValue("V9W_INDMDE"),;
											oModelV9W:GetValue("V9W_INDUNI")})
					Else
						Aadd(aGravaV9W, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA"),;
											oModelV9W:GetValue("V9W_MATRIC"),;
											oModelV9W:GetValue("V9W_CODCAT"),;
											oModelV9W:GetValue("V9W_DTINIC"),;
											oModelV9W:GetValue("V9W_TPCONT"),;
											oModelV9W:GetValue("V9W_INDCON"),;
											oModelV9W:GetValue("V9W_DTADMO"),;
											oModelV9W:GetValue("V9W_INDREI"),;
											oModelV9W:GetValue("V9W_INDCAT"),;
											oModelV9W:GetValue("V9W_INDNAT"),;
											oModelV9W:GetValue("V9W_INDMDE")})
					EndIf

					For nV9X := 1 To oModel:GetModel('MODEL_V9X'):Length()

						oModel:GetModel('MODEL_V9X'):GoLine(nV9X)

						If !oModel:GetModel("MODEL_V9X"):IsEmpty() .And. !oModel:GetModel("MODEL_V9X"):IsDeleted()

							If !lSimpl12 
								Aadd(aGravaV9X, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
													oModelV9X:GetValue("V9X_CODCBO"),;
													oModelV9X:GetValue("V9X_NATATV"),;
													oModelV9X:GetValue("V9X_TPREGT"),;
													oModelV9X:GetValue("V9X_TPREGP"),;
													oModelV9X:GetValue("V9X_DTADM" ),;
													oModelV9X:GetValue("V9X_TMPPAR"),;
													oModelV9X:GetValue("V9X_TPCDUR"),;
													oModelV9X:GetValue("V9X_DTTERM"),;
													oModelV9X:GetValue("V9X_CLAASS"),;
													oModelV9X:GetValue("V9X_OBJDET"),;
													oModelV9X:GetValue("V9X_TPINSC"),;
													oModelV9X:GetValue("V9X_NRINSC"),;
													oModelV9X:GetValue("V9X_MATANT"),;
													oModelV9X:GetValue("V9X_DTTRAN"),;
													oModelV9X:GetValue("V9X_DTDESL"),;
													oModelV9X:GetValue("V9X_MTVDES"),;
													oModelV9X:GetValue("V9X_DTFPRO"),;
													oModelV9X:GetValue("V9X_DTFIM" ),;
													oModelV9X:GetValue("V9X_MTDTSV")})
							Else
								Aadd(aGravaV9X, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
													oModelV9X:GetValue("V9X_CODCBO"),;
													oModelV9X:GetValue("V9X_NATATV"),;
													oModelV9X:GetValue("V9X_TPREGT"),;
													oModelV9X:GetValue("V9X_TPREGP"),;
													oModelV9X:GetValue("V9X_DTADM" ),;
													oModelV9X:GetValue("V9X_TMPPAR"),;
													oModelV9X:GetValue("V9X_TPCDUR"),;
													oModelV9X:GetValue("V9X_DTTERM"),;
													oModelV9X:GetValue("V9X_CLAASS"),;
													oModelV9X:GetValue("V9X_OBJDET"),;
													oModelV9X:GetValue("V9X_TPINSC"),;
													oModelV9X:GetValue("V9X_NRINSC"),;
													oModelV9X:GetValue("V9X_MATANT"),;
													oModelV9X:GetValue("V9X_DTTRAN"),;
													oModelV9X:GetValue("V9X_DTDESL"),;
													oModelV9X:GetValue("V9X_MTVDES"),;
													oModelV9X:GetValue("V9X_DTFPRO"),;
													oModelV9X:GetValue("V9X_DTFIM" ),;
													oModelV9X:GetValue("V9X_MTDTSV"),;
													oModelV9X:GetValue("V9X_PENSAL"),;
													oModelV9X:GetValue("V9X_PERCAL"),;
													oModelV9X:GetValue("V9X_VRALIM")})
							EndIf

							For nV9Y := 1 To oModel:GetModel("MODEL_V9Y"):Length()
								oModel:GetModel("MODEL_V9Y"):GoLine(nV9Y)

								If !oModel:GetModel("MODEL_V9Y"):IsEmpty() .And. !oModel:GetModel("MODEL_V9Y"):IsDeleted()
									Aadd(aGravaV9Y, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
														oModelV9Y:GetValue("V9Y_DTREMU"),;
														oModelV9Y:GetValue("V9Y_VRSAL" ),;
														oModelV9Y:GetValue("V9Y_UNDSAL"),;
														oModelV9Y:GetValue("V9Y_DSCSAL")})
								EndIf
							Next nV9Y

							For nV9Z := 1 To oModel:GetModel("MODEL_V9Z"):Length()
								oModel:GetModel("MODEL_V9Z"):GoLine(nV9Z)

								If !oModel:GetModel("MODEL_V9Z"):IsEmpty() .And. !oModel:GetModel("MODEL_V9Z"):IsDeleted()
									Aadd(aGravaV9Z, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
														oModelV9Z:GetValue("V9Z_OBS"  ),;
														oModelV9Z:GetValue("V9Z_IDOBS")})
								EndIf
							Next nV9Z

						EndIf
					Next nV9X

					For nV7A := 1 To oModel:GetModel("MODEL_V7A"):Length()
						oModel:GetModel("MODEL_V7A"):GoLine(nV7A)

						If !oModel:GetModel("MODEL_V7A"):IsEmpty() .And. !oModel:GetModel("MODEL_V7A"):IsDeleted()
							Aadd(aGravaV7A, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
												oModelV7A:GetValue("V7A_NEWCAT"),;
												oModelV7A:GetValue("V7A_NATATV"),;
												oModelV7A:GetValue("V7A_DTMUDC")})
						EndIf
					Next nV7A

					For nV7B := 1 To oModel:GetModel("MODEL_V7B"):Length()
						oModel:GetModel("MODEL_V7B"):GoLine(nV7B)

						If !oModel:GetModel("MODEL_V7B"):IsEmpty() .And. !oModel:GetModel("MODEL_V7B"):IsDeleted()
							Aadd(aGravaV7B, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
												oModelV7B:GetValue("V7B_MATUNI"),;
												oModelV7B:GetValue("V7B_NEWCAT"),;
												oModelV7B:GetValue("V7B_DTTSV" )})
						EndIf
					Next nV7B

					For nV7H := 1 To oModel:GetModel("MODEL_V7H"):Length()

						oModel:GetModel("MODEL_V7H"):GoLine(nV7H)

						If !oModel:GetModel("MODEL_V7H"):IsEmpty() .And. !oModel:GetModel("MODEL_V7H"):IsDeleted()
							
							If !lSimpl12

								Aadd(aGravaV7H, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
													oModelV7H:GetValue("V7H_TPINSC"),;
													oModelV7H:GetValue("V7H_NRINSC"),;
													oModelV7H:GetValue("V7H_COMPIN"),;
													oModelV7H:GetValue("V7H_COMPFI"),;
													oModelV7H:GetValue("V7H_REPPRO"),;
													oModelV7H:GetValue("V7H_VLVERB"),;
													oModelV7H:GetValue("V7H_VLAVSP"),;
													oModelV7H:GetValue("V7H_VRAPI" ),;
													oModelV7H:GetValue("V7H_VLINDE"),;
													oModelV7H:GetValue("V7H_VLBASE"),;
													oModelV7H:GetValue("V7H_PAGDIR")})

							Else

								Aadd(aGravaV7H, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")),;
													oModelV7H:GetValue("V7H_TPINSC"),;
													oModelV7H:GetValue("V7H_NRINSC"),;
													oModelV7H:GetValue("V7H_COMPIN"),;
													oModelV7H:GetValue("V7H_COMPFI"),;
													oModelV7H:GetValue("V7H_INDREP"),;
													oModelV7H:GetValue("V7H_INDESD"),;
													oModelV7H:GetValue("V7H_INDABO")})

								For nV7Q := 1 To oModel:GetModel("MODEL_V7Q"):Length()

									oModel:GetModel("MODEL_V7Q"):GoLine(nV7Q)

									If !oModel:GetModel("MODEL_V7Q"):IsEmpty() .And. !oModel:GetModel("MODEL_V7Q"):IsDeleted()

										Aadd(aGravaV7Q, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC") ,;
															oModelV7Q:GetValue("V7Q_ANOBAS")})

									EndIf

								Next nV7Q

							EndIf

						EndIf

					Next nV7H

					For nV7I := 1 To oModel:GetModel("MODEL_V7I"):Length()

						oModel:GetModel("MODEL_V7I"):GoLine(nV7I)

						If !oModel:GetModel("MODEL_V7I"):IsEmpty() .And. !oModel:GetModel("MODEL_V7I"):IsDeleted()
							
							If !lSimpl12 
								Aadd(aGravaV7I, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
													oModelV7I:GetValue("V7I_PERREF"),;
													oModelV7I:GetValue("V7I_VRMEN" ),;
													oModelV7I:GetValue("V7I_VRCP"  ),;
													oModelV7I:GetValue("V7I_VRFGTS"),;
													oModelV7I:GetValue("V7I_BCFGTS"),;
													oModelV7I:GetValue("V7I_GRAUEX"),;
													oModelV7I:GetValue("V7I_VRFGUI"),;
													oModelV7I:GetValue("V7I_FGTSGU"),;
													oModelV7I:GetValue("V7I_PAGDIR"),;
													oModelV7I:GetValue("V7I_CATMUD"),;
													oModelV7I:GetValue("V7I_VRPREV"),;
													oModelV7I:GetValue("V7I_BCPROT"),;
													oModelV7I:GetValue("V7I_BCSEFI"),;
													oModelV7I:GetValue("V7I_BCDECA")})
							Else
								Aadd(aGravaV7I, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC"),;
													oModelV7I:GetValue("V7I_PERREF"),;
													oModelV7I:GetValue("V7I_VRMEN" ),;
													oModelV7I:GetValue("V7I_VRCP"  ),;
													oModelV7I:GetValue("V7I_GRAUEX"),;
													oModelV7I:GetValue("V7I_CATMUD"),;
													oModelV7I:GetValue("V7I_VRPREV"),;
													oModelV7I:GetValue("V7I_BCPROT"),;
													oModelV7I:GetValue("V7I_BCSEFI"),;
													oModelV7I:GetValue("V7I_BCDECA")})	

								If lSimpl0103 .And. TafColumnPos("T8F_DIATRA")

									For nT8F:= 1 To oModel:GetModel("MODEL_T8F"):Length()

										oModel:GetModel("MODEL_T8F"):GoLine(nT8F)

										If !oModel:GetModel("MODEL_T8F"):IsEmpty() .And. !oModel:GetModel("MODEL_T8F"):IsDeleted()

											Aadd(aGravaT8F, {	oModelV9U:GetValue("V9U_NRPROC") + oModelV9U:GetValue("V9U_CPFTRA") + oModelV9W:GetValue("V9W_MATRIC") + oModelV9W:GetValue("V9W_CODCAT") + DTOS(oModelV9W:GetValue("V9W_DTINIC")) + oModelV7H:GetValue("V7H_TPINSC") + oModelV7H:GetValue("V7H_NRINSC") ,;
																oModelT8F:GetValue("T8F_DIATRA"),;
																oModelT8F:GetValue("T8F_HRSTRA")})

										EndIf

									Next nT8F	
								EndIf					
													
							EndIf
						EndIF
					Next nV7I
				EndIf
			Next nV9W
		EndIf

		FAltRegAnt( 'V9U', '2' )

		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		For nI := 1 To Len( aGravaV9U )
			oModel:LoadValue( 'MODEL_V9U', aGravaV9U[nI, 1], aGravaV9U[nI, 2] )
		Next

		cVersao := xFunGetVer()	

		If !lSimpl12 
			nV9VAdd := 1
			For nV9V := 1 To Len(aGravaV9V)
				oModel:GetModel("MODEL_V9V"):lValid := .T.

				If nV9VAdd > 1 
					oModel:GetModel("MODEL_V9V"):AddLine()
				EndIf

				oModel:LoadValue("MODEL_V9V", "V9V_CPFDEP", aGravaV9V[nV9V][2])
				oModel:LoadValue("MODEL_V9V", "V9V_TPDEP", 	aGravaV9V[nV9V][3])
				oModel:LoadValue("MODEL_V9V", "V9V_DSCDEP", aGravaV9V[nV9V][4])			

				nV9VAdd++
			Next
		EndIf

		nV9WAdd := 1
		For nV9W := 1 To Len(aGravaV9W)
		
			oModel:GetModel("MODEL_V9W"):lValid := .T.

			If nV9WAdd > 1 
				oModel:GetModel("MODEL_V9W"):AddLine()
			EndIf

			If !lSimpl12 
				oModel:LoadValue("MODEL_V9W", "V9W_MATRIC", aGravaV9W[nV9W][2])
				oModel:LoadValue("MODEL_V9W", "V9W_CODCAT", aGravaV9W[nV9W][3])
				oModel:LoadValue("MODEL_V9W", "V9W_DTINIC", aGravaV9W[nV9W][4])
				oModel:LoadValue("MODEL_V9W", "V9W_TPCONT", aGravaV9W[nV9W][5])
				oModel:LoadValue("MODEL_V9W", "V9W_INDCON", aGravaV9W[nV9W][6])
				oModel:LoadValue("MODEL_V9W", "V9W_DTADMO", aGravaV9W[nV9W][7])
				oModel:LoadValue("MODEL_V9W", "V9W_INDREI", aGravaV9W[nV9W][8])
				oModel:LoadValue("MODEL_V9W", "V9W_INDCAT", aGravaV9W[nV9W][9])
				oModel:LoadValue("MODEL_V9W", "V9W_INDNAT", aGravaV9W[nV9W][10])
				oModel:LoadValue("MODEL_V9W", "V9W_INDMDE", aGravaV9W[nV9W][11])
				oModel:LoadValue("MODEL_V9W", "V9W_INDUNI", aGravaV9W[nV9W][12])
			Else
				oModel:LoadValue("MODEL_V9W", "V9W_MATRIC", aGravaV9W[nV9W][2])
				oModel:LoadValue("MODEL_V9W", "V9W_CODCAT", aGravaV9W[nV9W][3])
				oModel:LoadValue("MODEL_V9W", "V9W_DTINIC", aGravaV9W[nV9W][4])
				oModel:LoadValue("MODEL_V9W", "V9W_TPCONT", aGravaV9W[nV9W][5])
				oModel:LoadValue("MODEL_V9W", "V9W_INDCON", aGravaV9W[nV9W][6])
				oModel:LoadValue("MODEL_V9W", "V9W_DTADMO", aGravaV9W[nV9W][7])
				oModel:LoadValue("MODEL_V9W", "V9W_INDREI", aGravaV9W[nV9W][8])
				oModel:LoadValue("MODEL_V9W", "V9W_INDCAT", aGravaV9W[nV9W][9])
				oModel:LoadValue("MODEL_V9W", "V9W_INDNAT", aGravaV9W[nV9W][10])
				oModel:LoadValue("MODEL_V9W", "V9W_INDMDE", aGravaV9W[nV9W][11])
			EndIf

			For nV9X := 1 To Len(aGravaV9X)

				If aGravaV9X[nV9X][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

					oModel:GetModel("MODEL_V9X"):lValid := .T.						

					oModel:LoadValue("MODEL_V9X", "V9X_CODCBO", aGravaV9X[nV9X][2])
					oModel:LoadValue("MODEL_V9X", "V9X_NATATV", aGravaV9X[nV9X][3])
					oModel:LoadValue("MODEL_V9X", "V9X_TPREGT", aGravaV9X[nV9X][4])
					oModel:LoadValue("MODEL_V9X", "V9X_TPREGP", aGravaV9X[nV9X][5])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTADM", 	aGravaV9X[nV9X][6])		
					oModel:LoadValue("MODEL_V9X", "V9X_TMPPAR", aGravaV9X[nV9X][7])		
					oModel:LoadValue("MODEL_V9X", "V9X_TPCDUR", aGravaV9X[nV9X][8])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTTERM", aGravaV9X[nV9X][9])		
					oModel:LoadValue("MODEL_V9X", "V9X_CLAASS", aGravaV9X[nV9X][10])		
					oModel:LoadValue("MODEL_V9X", "V9X_OBJDET", aGravaV9X[nV9X][11])		
					oModel:LoadValue("MODEL_V9X", "V9X_TPINSC", aGravaV9X[nV9X][12])		
					oModel:LoadValue("MODEL_V9X", "V9X_NRINSC", aGravaV9X[nV9X][13])		
					oModel:LoadValue("MODEL_V9X", "V9X_MATANT", aGravaV9X[nV9X][14])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTTRAN", aGravaV9X[nV9X][15])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTDESL", aGravaV9X[nV9X][16])		
					oModel:LoadValue("MODEL_V9X", "V9X_MTVDES", aGravaV9X[nV9X][17])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTFPRO", aGravaV9X[nV9X][18])		
					oModel:LoadValue("MODEL_V9X", "V9X_DTFIM", 	aGravaV9X[nV9X][19])		
					oModel:LoadValue("MODEL_V9X", "V9X_MTDTSV", aGravaV9X[nV9X][20])

					nV9YAdd := 1
					For nV9Y := 1 To Len(aGravaV9Y)

						If aGravaV9Y[nV9Y][1] == aGravaV9X[nV9X][1]

							oModel:GetModel("MODEL_V9Y"):lValid := .T.

							If nV9YAdd > 1
								oModel:GetModel("MODEL_V9Y"):AddLine()
							EndIf

							oModel:LoadValue("MODEL_V9Y", "V9Y_DTREMU", aGravaV9Y[nV9Y][2])		
							oModel:LoadValue("MODEL_V9Y", "V9Y_VRSAL" , aGravaV9Y[nV9Y][3])		
							oModel:LoadValue("MODEL_V9Y", "V9Y_UNDSAL", aGravaV9Y[nV9Y][4])		
							oModel:LoadValue("MODEL_V9Y", "V9Y_DSCSAL", aGravaV9Y[nV9Y][5])

							nV9YAdd++
						EndIF
					Next 

					nV9ZAdd := 1
					For nV9Z := 1 To Len(aGravaV9Z)

						If aGravaV9Z[nV9Z][1] == aGravaV9X[nV9X][1]
							oModel:GetModel("MODEL_V9Z"):lValid := .T.

							If nV9ZAdd > 1
								oModel:GetModel("MODEL_V9Z"):AddLine()
							EndIf

							oModel:LoadValue("MODEL_V9Z", "V9Z_OBS"  , aGravaV9Z[nV9Z][2])
							oModel:LoadValue("MODEL_V9Z", "V9Z_IDOBS", aGravaV9Z[nV9Z][3])

							nV9ZAdd++
						EndIf
					Next
				EndIf
			Next

			nV7AAdd := 1
			For nV7A := 1 To Len(aGravaV7A)

				If aGravaV7A[nV7A][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

					oModel:GetModel("MODEL_V7A"):lValid := .T.

					If nV7AAdd > 1
						oModel:GetModel("MODEL_V7A"):AddLine()
					EndIf

					oModel:LoadValue("MODEL_V7A", "V7A_NEWCAT", aGravaV7A[nV7A][2])
					oModel:LoadValue("MODEL_V7A", "V7A_NATATV", aGravaV7A[nV7A][3])
					oModel:LoadValue("MODEL_V7A", "V7A_DTMUDC", aGravaV7A[nV7A][4])

					nV7AAdd++
				EndIf
			Next

			nV7BAdd := 1
			For nV7B := 1 To Len(aGravaV7B)

				If aGravaV7B[nV7B][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

					oModel:GetModel("MODEL_V7B"):lValid := .T.

					If nV7BAdd > 1
						oModel:GetModel("MODEL_V7B"):AddLine()
					EndIf

					oModel:LoadValue("MODEL_V7B", "V7B_MATUNI", aGravaV7B[nV7B][2])
					oModel:LoadValue("MODEL_V7B", "V7B_NEWCAT", aGravaV7B[nV7B][3])
					oModel:LoadValue("MODEL_V7B", "V7B_DTTSV", aGravaV7B[nV7B][4])

					nV7BAdd++								
				EndIF
			Next

			nV7HAdd := 1
			For nV7H := 1 To Len(aGravaV7H)

				If aGravaV7H[nV7H][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4])

					oModel:GetModel("MODEL_V7H"):lValid := .T.

					If !lSimpl12 					
						oModel:LoadValue("MODEL_V7H", "V7H_TPINSC", aGravaV7H[nV7H][2])
						oModel:LoadValue("MODEL_V7H", "V7H_NRINSC", aGravaV7H[nV7H][3])
						oModel:LoadValue("MODEL_V7H", "V7H_COMPIN", aGravaV7H[nV7H][4])
						oModel:LoadValue("MODEL_V7H", "V7H_COMPFI", aGravaV7H[nV7H][5])
						oModel:LoadValue("MODEL_V7H", "V7H_REPPRO", aGravaV7H[nV7H][6])
						oModel:LoadValue("MODEL_V7H", "V7H_VLVERB", aGravaV7H[nV7H][7])
						oModel:LoadValue("MODEL_V7H", "V7H_VLAVSP", aGravaV7H[nV7H][8])
						oModel:LoadValue("MODEL_V7H", "V7H_VRAPI" , aGravaV7H[nV7H][9])
						oModel:LoadValue("MODEL_V7H", "V7H_VLINDE", aGravaV7H[nV7H][10])
						oModel:LoadValue("MODEL_V7H", "V7H_VLBASE", aGravaV7H[nV7H][11])
						oModel:LoadValue("MODEL_V7H", "V7H_PAGDIR", aGravaV7H[nV7H][12])
					Else
						oModel:LoadValue("MODEL_V7H", "V7H_TPINSC", aGravaV7H[nV7H][2])
						oModel:LoadValue("MODEL_V7H", "V7H_NRINSC", aGravaV7H[nV7H][3])
						oModel:LoadValue("MODEL_V7H", "V7H_COMPIN", aGravaV7H[nV7H][4])
						oModel:LoadValue("MODEL_V7H", "V7H_COMPFI", aGravaV7H[nV7H][5])
						oModel:LoadValue("MODEL_V7H", "V7H_INDREP", aGravaV7H[nV7H][6])
						oModel:LoadValue("MODEL_V7H", "V7H_INDESD", aGravaV7H[nV7H][7])
						oModel:LoadValue("MODEL_V7H", "V7H_INDABO", aGravaV7H[nV7H][8])
					EndIf

					If lSimpl12	
						nV7QAdd := 1
						For nV7Q := 1 To Len(aGravaV7Q)

							If aGravaV7Q[nV7Q][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

								oModel:GetModel("MODEL_V7Q"):lValid := .T.

								If nV7QAdd > 1
									oModel:GetModel("MODEL_V7Q"):AddLine()
								EndIf

								oModel:LoadValue("MODEL_V7Q", "V7Q_ANOBAS", aGravaV7Q[nV7Q][2])
								
								nV7QAdd++	

							EndIf
						Next
					EndIf

					nV7IAdd := 1
					For nV7I := 1 To Len(aGravaV7I)

						If aGravaV7I[nV7I][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

							oModel:GetModel("MODEL_V7I"):lValid := .T.

							If nV7IAdd > 1
								oModel:GetModel("MODEL_V7I"):AddLine()
							EndIf

							If !lSimpl12
								oModel:LoadValue("MODEL_V7I", "V7I_PERREF", aGravaV7I[nV7I][2])
								oModel:LoadValue("MODEL_V7I", "V7I_VRMEN", 	aGravaV7I[nV7I][3])
								oModel:LoadValue("MODEL_V7I", "V7I_VRCP", 	aGravaV7I[nV7I][4])
								oModel:LoadValue("MODEL_V7I", "V7I_VRFGTS", aGravaV7I[nV7I][5])
								oModel:LoadValue("MODEL_V7I", "V7I_BCFGTS", aGravaV7I[nV7I][6])
								oModel:LoadValue("MODEL_V7I", "V7I_GRAUEX", aGravaV7I[nV7I][7])
								oModel:LoadValue("MODEL_V7I", "V7I_VRFGUI", aGravaV7I[nV7I][8])
								oModel:LoadValue("MODEL_V7I", "V7I_FGTSGU", aGravaV7I[nV7I][9])
								oModel:LoadValue("MODEL_V7I", "V7I_PAGDIR", aGravaV7I[nV7I][10])
								oModel:LoadValue("MODEL_V7I", "V7I_CATMUD", aGravaV7I[nV7I][11])
								oModel:LoadValue("MODEL_V7I", "V7I_VRPREV", aGravaV7I[nV7I][12])
							Else
								oModel:LoadValue("MODEL_V7I", "V7I_PERREF", aGravaV7I[nV7I][2])
								oModel:LoadValue("MODEL_V7I", "V7I_VRMEN", 	aGravaV7I[nV7I][3])
								oModel:LoadValue("MODEL_V7I", "V7I_VRCP", 	aGravaV7I[nV7I][4])
								oModel:LoadValue("MODEL_V7I", "V7I_GRAUEX", aGravaV7I[nV7I][5])
								oModel:LoadValue("MODEL_V7I", "V7I_CATMUD", aGravaV7I[nV7I][6])
								oModel:LoadValue("MODEL_V7I", "V7I_VRPREV", aGravaV7I[nV7I][7])
								oModel:LoadValue("MODEL_V7I", "V7I_BCPROT", aGravaV7I[nV7I][8])
								oModel:LoadValue("MODEL_V7I", "V7I_BCSEFI", aGravaV7I[nV7I][9])
								oModel:LoadValue("MODEL_V7I", "V7I_BCDECA", aGravaV7I[nV7I][10])

							EndIf	

							If lSimpl0103 .And. TafColumnPos("T8F_DIATRA")	
								nT8FAdd := 1
								For nT8F := 1 To Len(aGravaT8F)

									If aGravaT8F[nT8F][1] == aGravaV9W[nV9W][1] + aGravaV9W[nV9W][2] + aGravaV9W[nV9W][3] + DTOS(aGravaV9W[nV9W][4]) + aGravaV7H[nV7H][2] + aGravaV7H[nV7H][3]

										oModel:GetModel("MODEL_T8F"):lValid := .T.

										If nT8FAdd > 1
											oModel:GetModel("MODEL_T8F"):AddLine()
										EndIf

										oModel:LoadValue("MODEL_T8F", "T8F_DIATRA", aGravaT8F[nT8F][2])
										oModel:LoadValue("MODEL_T8F", "T8F_HRSTRA", aGravaT8F[nT8F][3])
										
										nT8FAdd++	

									EndIf
								Next
							EndIf

							nV7IAdd++
						EndIf
						
					Next

					nV7HAdd++							
				EndIf

			Next										

			nV9WAdd++
		Next

		oModel:LoadValue( 'MODEL_V9U', 'V9U_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_V9U', 'V9U_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_V9U', 'V9U_PROTPN', cProtocolo)
		oModel:LoadValue( 'MODEL_V9U', 'V9U_PROTUL', "")
		oModel:LoadValue( 'MODEL_V9U', 'V9U_EVENTO', "E")
		oModel:LoadValue( 'MODEL_V9U', 'V9U_ATIVO' , "1")

		FwFormCommit(oModel)		
		TAFAltStat("V9U", "6")

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGatProc
Funcao que gatilha os campos da tela

@Return .T.

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafGatProc()

	Local oModel 	as object 
	Local cIdTrb 	as character 
	Local cEvento 	as character 
	Local cNome		as character
	Local nJ		as numeric 
	Local nV9VAdd	as numeric

	oModel 	:= FWModelActive()
	cIdTrb 	:= oModel:GetValue('MODEL_V9U','V9U_TRABAL')
	cEvento := IIF(!Empty(cIdTrb), GatMatV9U(), "")
	nJ		:= 0
	nV9VAdd := 1

	C9V->(DbSetOrder(2))
	
	oModel:SetValue('MODEL_V9U','V9U_ORIEVE', cEvento)

	// Deleta as linhas do grid para gatilhar itens de outro trabalhador
	If !lSimpl12 
		If !oModel:GetModel( 'MODEL_V9V' ):IsEmpty()

			For nJ := 1 to oModel:GetModel( 'MODEL_V9V' ):Length()
				oModel:GetModel( 'MODEL_V9V' ):GoLine(nJ)
				oModel:GetModel( "MODEL_V9V" ):DeleteLine()						
			Next nJ

		EndIf
	EndIf

	If !oModel:GetModel( 'MODEL_V9W' ):IsEmpty()		
		oModel:SetValue('MODEL_V9W','V9W_MATRIC', "")
		oModel:SetValue('MODEL_V9W','V9W_CODCAT', "")
		oModel:SetValue('MODEL_V9W','V9W_DTINIC', "")
	EndIf

	If !oModel:GetModel( 'MODEL_V9X' ):IsEmpty()		
		oModel:SetValue('MODEL_V9X','V9X_CODCBO', "")
		oModel:SetValue('MODEL_V9X','V9X_NATATV', "")
		oModel:SetValue('MODEL_V9X','V9X_TPREGT', "")	
		oModel:SetValue('MODEL_V9X','V9X_TPREGP', "")	
		oModel:SetValue('MODEL_V9X','V9X_TMPPAR', "")	
		oModel:SetValue('MODEL_V9X','V9X_TPCDUR', "")	
		oModel:SetValue('MODEL_V9X','V9X_DTADM' , "")
		oModel:SetValue('MODEL_V9X','V9X_DTFIM' , "")
	EndIf

	If !oModel:GetModel( 'MODEL_V9Y' ):IsEmpty()		
		oModel:SetValue('MODEL_V9Y','V9Y_UNDSAL', "")
		oModel:SetValue('MODEL_V9Y','V9Y_VRSAL' , "")
		oModel:SetValue('MODEL_V9Y','V9Y_DSCSAL', "")
	EndIf

	// Carrega os trabalhadores
	If C9V->(DbSeek(xFilial("C9V") + cIdTrb + "1"))
			
		cNome := TAFNmTrab(xFilial("V9U"), cIdTrb, cEvento)
	
		oModel:SetValue('MODEL_V9U','V9U_CPFTRA', C9V->C9V_CPF			)
		oModel:SetValue('MODEL_V9U','V9U_NMTRAB', Substr( cNome, 1, 70 ))
		oModel:SetValue('MODEL_V9U','V9U_DTNASC', C9V->C9V_DTNASC		)	
		
		If !Empty(C9V->C9V_MATRIC)
			//oModel:SetValue('MODEL_V9U','V9U_MATRDI', C9V->C9V_MATRIC)
			oModel:SetValue('MODEL_V9W','V9W_MATRIC', C9V->C9V_MATRIC)
		Else
			//oModel:SetValue('MODEL_V9U','V9U_MATRDI', C9V->C9V_MATTSV)
			oModel:SetValue('MODEL_V9W','V9W_MATRIC', C9V->C9V_MATTSV)
		EndIf

		// Carrega os dependentes
		If !lSimpl12
			C9Y->(DbSetOrder(1))
			T2F->(DbSetOrder(2))
			If C9Y->(DbSeek(xFilial("C9Y") + C9V->(C9V_ID + C9V_VERSAO)))

				nV9VAdd := oModel:GetModel( 'MODEL_V9V' ):Length()

				While C9Y->(!Eof()) .And. (Alltrim(xFilial("C9Y") + C9Y->(C9Y_ID + C9Y_VERSAO))) == (Alltrim(xFilial("C9V") + C9V->(C9V_ID + C9V_VERSAO))) 
					
					If nV9VAdd > 1
						oModel:GetModel("MODEL_V9V"):AddLine()							
					EndIf

					oModel:SetValue('MODEL_V9V','V9V_TPDEP' ,C9Y->C9Y_TPDEP)
					oModel:SetValue('MODEL_V9V','V9V_CPFDEP',C9Y->C9Y_CPFDEP)
									
					C9Y->(DbSkip())
					nV9VAdd++

				EndDo

			ElseIf T2F->(DbSeek(xFilial("T2F") + C9V->(C9V_ID + C9V_VERSAO)))
				
				nV9VAdd := oModel:GetModel( 'MODEL_V9V' ):Length()

				While T2F->(!Eof()) .And. (Alltrim(xFilial("T2F") + T2F->(T2F_ID + T2F_VERSAO))) == (Alltrim(xFilial("C9V") + C9V->(C9V_ID + C9V_VERSAO))) 
					
					If nV9VAdd > 1
						oModel:GetModel("MODEL_V9V"):AddLine()				
					EndIf

					oModel:SetValue('MODEL_V9V','V9V_TPDEP' ,T2F->T2F_TPDEP)
					oModel:SetValue('MODEL_V9V','V9V_CPFDEP',T2F->T2F_CPFDEP)

					T2F->(DbSkip())
					nV9VAdd++

				EndDo
			EndIf
		EndIf

		// Informações do contrato		
		If cEvento == 'S2200'

			CUP->(DbSetOrder(1))
			If CUP->(DbSeek(xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO)))

				oModel:SetValue('MODEL_V9W','V9W_CODCAT', CUP->(CUP_CODCAT))								
				oModel:SetValue('MODEL_V9X','V9X_CODCBO', CUP->(CUP_CBOCAR))
				oModel:SetValue('MODEL_V9X','V9X_NATATV', CUP->(CUP_NATATV))
				oModel:SetValue('MODEL_V9X','V9X_TPREGT', CUP->(CUP_TPREGT))	
				oModel:SetValue('MODEL_V9X','V9X_TPREGP', CUP->(CUP_TPREGP))	
				oModel:SetValue('MODEL_V9X','V9X_TMPPAR', CUP->(CUP_TMPARC))	
				oModel:SetValue('MODEL_V9X','V9X_TPCDUR', CUP->(CUP_TPCONT))	
				oModel:SetValue('MODEL_V9X','V9X_DTADM' , CUP->(CUP_DTADMI))
				oModel:SetValue('MODEL_V9X','V9X_DTFIM' , CUP->(CUP_DTTERM))
				oModel:SetValue('MODEL_V9Y','V9Y_UNDSAL', CUP->(CUP_UNSLFX))
				oModel:SetValue('MODEL_V9Y','V9Y_VRSAL' , CUP->(CUP_VLSLFX))
				oModel:SetValue('MODEL_V9Y','V9Y_DSCSAL', CUP->(CUP_DSCSAL))

			EndIf

		ElseIf cEvento == 'S2300'

			CUU->(DbSetOrder(1))
			If CUU->(DbSeek(xFilial("CUU") + C9V->(C9V_ID + C9V_VERSAO)))
										
				oModel:SetValue('MODEL_V9W','V9W_CODCAT', C9V->(C9V_CATCI))
				oModel:SetValue('MODEL_V9W','V9W_DTINIC', C9V->(C9V_DTINIV))
				oModel:SetValue('MODEL_V9X','V9X_CODCBO', CUU->(CUU_CBOCAR))
				oModel:SetValue('MODEL_V9X','V9X_NATATV', CUU->(CUU_NATATV))
				oModel:SetValue('MODEL_V9X','V9X_TPREGT', CUU->(CUU_TPREGT))	
				oModel:SetValue('MODEL_V9X','V9X_TPREGP', CUU->(CUU_TPREGP))	
				oModel:SetValue('MODEL_V9X','V9X_DTFIM' , CUU->(CUU_DTTERM))
				oModel:SetValue('MODEL_V9Y','V9Y_UNDSAL', CUU->(CUU_UNSLCI))
				oModel:SetValue('MODEL_V9Y','V9Y_VRSAL' , CUU->(CUU_VLSLCI))
				oModel:SetValue('MODEL_V9Y','V9Y_DSCSAL', CUU->(CUU_DSCSAL))				
			
			EndIf
		EndIf
	EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF608Xml

Funcao de geracao do XML para atender o registro S-2500
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias		-	Alias da tabela
nRecno		-	Recno do registro corrente
nOpc		-	Operação a ser realizada
lJob		-	Informa se foi chamado por job
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-2500

@author Silas/Karyna
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF608Xml( cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical,; 
					lRemEmp as Logical, cSeqXml as Character, lInfoRPT as Logical )

	Local cXml      	as Character
	Local cLayout   	as Character
	Local cReg      	as Character
	Local cEsocial 	 	as Character
	Local cFilBkp   	as Character	
	Local cDurac		as Character 
	Local cObserv		as Character
	Local cSucVinc		as Character
	Local cInfoDes		as Character
	Local cInfoVinc		as Character
	Local cInfoTerm		as Character
	Local cRemun		as Character
	Local cVerSchema	as Character
	Local lXmlVLd   	as Logical

	Default cAlias   := ""
	Default nRecno   := 0
	Default nOpc     := 1
	Default lJob     := .F.
	Default lInfoRPT := .F.

	cXml        := ""
	cLayout     := "2500"
	cReg        := "ProcTrab"
	cEsocial    := SuperGetMV("MV_TAFVLES")
	cFilBkp     := cFilAnt	
	cDurac		:= ""
	cObserv		:= ""
	cSucVinc	:= ""
	cInfoDes	:= ""
	cInfoVinc	:= ""
	cInfoTerm	:= ""
	cRemun		:= ""
	cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"S_01_00_00")
	aAreaV9U    := {}
	lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF608XML' ),.T.)

	If lXmlVld		

		If IsInCallStack("TafNewBrowse") .And. ( V9U->V9U_FILIAL <> cFilAnt ).AND.!Empty(V9U->V9U_FILIAL)
			cFilAnt := V9U->V9U_FILIAL
		EndIf	

		V9U->( DbSetOrder(2) )
		If V9U->( MsSeek( xFilial("V9U") + V9U->V9U_ID + V9U->V9U_VERSAO + V9U->V9U_NRPROC ) )

			cXml += "<infoProcesso>"
			cXml += 	xTafTag( "origem", V9U->V9U_ORIGEM,, .F. )
			cXml += 	xTafTag( "nrProcTrab", AllTrim(V9U->V9U_NRPROC),, .F. )
			cXml += 	xTafTag( "obsProcTrab", V9U->V9U_OBSERV,, .T. )
			cXml +=		"<dadosCompl>"
							xTAFTagGroup( "infoProcJud";
										, {{ "dtSent", V9U->V9U_DTSENT,, .F. };
										,  { "ufVara", Posicione("C09", 3, xFilial("C09") + V9U->V9U_UFVARA, "C09_UF"),, .F. };										
										,  { "codMunic", Posicione( "C09", 3, xFilial("C09") + V9U->V9U_UFVARA, "C09_CODIGO" ) + Posicione( "C07", 3, xFilial("C07") + V9U->V9U_CODMUN, "C07_CODIGO" ),, .F. };
										,  { "idVara", V9U->V9U_IDVARA,, .F. }};				
										,  @cXml,, .F. )

							xTAFTagGroup( "infoCCP";
										, {{ "dtCCP", V9U->V9U_DTCCP,, .F. };
										,  { "tpCCP", V9U->V9U_TPCCP,, .F. };
										,  { "cnpjCCP", V9U->V9U_CNPJCP,, .T. }};				
										,  @cXml,, .F. )
						
			cXml +=		"</dadosCompl>"
			cXml += "</infoProcesso>"
			cXml += "<ideTrab>"

			cXml +=		xTafTag( "cpfTrab", V9U->V9U_CPFTRA,, .F. )
			cXml +=		xTafTag( "nmTrab", AllTrim(V9U->V9U_NMTRAB),, .T. )
			cXml +=		xTafTag( "dtNascto", V9U->V9U_DTNASC,, .T. )

			If cVerSchema $ "S_01_03_00" .And. TafColumnPos("V9U_IDESEQ")
				cXml +=		xTafTag( "ideSeqTrab", V9U->V9U_IDESEQ,, .T. )
			EndIf	

			If !cVerSchema $ "S_01_02_00|S_01_03_00"
				V9V->( DbSetOrder(1) )
				If V9V->( MsSeek( xFilial("V9V") + V9U->V9U_ID + V9U->V9U_VERSAO + V9U->V9U_NRPROC + V9U->V9U_CPFTRA ) )
					While V9V->( !Eof() ) .And. V9V->( V9V_FILIAL + V9V_ID + V9V_VERSAO + V9V_NRPROC + V9V_CPFTRA ) == xFilial("V9V") + V9U->( V9U_ID + V9U_VERSAO + V9U_NRPROC + V9U_CPFTRA )
						xTAFTagGroup( "dependente";
									, {{ "cpfDep", V9V->V9V_CPFDEP,, .F. };
									,  { "tpDep" , Posicione("CMI", 1, xFilial("CMI") + AllTrim(V9V->V9V_TPDEP), "CMI_CODIGO"), .F. };
									,  { "descDep", V9V->V9V_DSCDEP,, .T. }};				
									,  @cXml,, .F. )
						
						V9V->( DbSkip() )
					EndDo
				EndIf
			EndIf

			V9W->( DbSetOrder(1) )
			If V9W->( MsSeek( xFilial("V9W") + V9U->V9U_ID + V9U->V9U_VERSAO + V9U->V9U_NRPROC + V9U->V9U_CPFTRA ) )
				While V9W->( !Eof() ) .And. V9W->( V9W_FILIAL + V9W_ID + V9W_VERSAO + V9W_NRPROC + V9W_CPFTRA ) == xFilial("V9W") + V9U->( V9U_ID + V9U_VERSAO + V9U_NRPROC + V9U_CPFTRA )
												
					cXml += "<infoContr>"
					cXml += 	xTafTag( "tpContr", V9W->V9W_TPCONT,, .F. )
					cXml += 	xTafTag( "indContr", xFunTrcSN(V9W->V9W_INDCON, 1),, .F. )								
					cXml += 	xTafTag( "dtAdmOrig", V9W->V9W_DTADMO,, .T. )					
					cXml += 	xTafTag( "indReint", xFunTrcSN(V9W->V9W_INDREI, 1),, .T. )
					cXml += 	xTafTag( "indCateg", xFunTrcSN(V9W->V9W_INDCAT, 1),, .F. )
					cXml += 	xTafTag( "indNatAtiv", xFunTrcSN(V9W->V9W_INDNAT, 1),, .F. )
					cXml += 	xTafTag( "indMotDeslig", xFunTrcSN(V9W->V9W_INDMDE, 1),, .F. )

					If !cVerSchema $ "S_01_02_00|S_01_03_00"
						cXml += 	xTafTag( "indUnic", xFunTrcSN(V9W->V9W_INDUNI, 1),, .T. )
					EndIf

					cXml += 	xTafTag( "matricula", AllTrim(V9W->V9W_MATRIC),, .T. )
					cXml += 	xTafTag( "codCateg", Posicione( "C87", 1, xFilial("C87") + V9W->V9W_CODCAT, "C87_CODIGO" ),, .T. )
					cXml += 	xTafTag( "dtInicio", V9W->V9W_DTINIC,, .T. )

					V9X->( DbSetOrder(1) )
					If V9X->( MsSeek( xFilial("V9X") + V9W->V9W_ID + V9W->V9W_VERSAO + V9W->V9W_NRPROC + V9W->V9W_CPFTRA + V9W->V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) ) )

						V9Y->( DbSetOrder(1) )
						If V9Y->( MsSeek( xFilial("V9Y") + V9X->V9X_ID + V9X->V9X_VERSAO + V9X->V9X_NRPROC + V9X->V9X_CPFTRA + V9X->V9X_MATRIC + V9X->V9X_CODCAT + DTOS(V9X->V9X_DTINIC) ) )
							If __cPicVrSal == Nil
								__cPicVrSal := PesqPict( "V9Y", "V9Y_VRSAL" )
							EndIf
						
							While V9Y->( !EoF() ) .And. V9Y->( V9Y_FILIAL + V9Y_ID + V9Y_VERSAO + V9Y_NRPROC + V9Y_CPFTRA + V9Y_MATRIC + V9Y_CODCAT + DTOS(V9Y_DTINIC) ) == xFilial("V9X") +  V9X->( V9X_ID + V9X_VERSAO + V9X_NRPROC + V9X_CPFTRA + V9X_MATRIC + V9X->V9X_CODCAT + DTOS(V9X->V9X_DTINIC) )

								xTAFTagGroup( "remuneracao";
											, {{ "dtRemun"   , V9Y->V9Y_DTREMU,            , .F.      };											
											,  { "vrSalFx"   , V9Y->V9Y_VRSAL , __cPicVrSal, .F.,,.T. };
											,  { "undSalFixo", V9Y->V9Y_UNDSAL,            , .F.      };
											,  { "dscSalVar" , V9Y->V9Y_DSCSAL,            , .T.      }};				
											, @cRemun;
											,;
											, .F. )
							
								V9Y->( DbSkip() )
							EndDo
						EndIf
						
						xTAFTagGroup( "duracao";
									, {{ "tpContr", V9X->V9X_TPCDUR,, .F. };
									,  { "dtTerm", V9X->V9X_DTTERM,, .T. };
									,  { "clauAssec", xFunTrcSN(V9X->V9X_CLAASS, 1),, .T. };
									,  { "objDet", V9X->V9X_OBJDET,, .T. }};				
									,  @cDurac,, .F. )

						V9Z->( DbSetOrder(1) )
						If V9Z->( MsSeek( xFilial("V9Z") + V9X->V9X_ID + V9X->V9X_VERSAO + V9X->V9X_NRPROC + V9X->V9X_CPFTRA + V9X->V9X_MATRIC + V9X->V9X_CODCAT + DTOS(V9X->V9X_DTINIC) ) )
							While V9Z->( !EoF() ) .And. V9Z->( V9Z_FILIAL + V9Z_ID + V9Z_VERSAO + V9Z_NRPROC + V9Z_CPFTRA + V9Z_MATRIC + V9Z_CODCAT + DTOS(V9Z_DTINIC) ) == xFilial("V9X") + V9X->( V9X_ID + V9X_VERSAO + V9X_NRPROC + V9X_CPFTRA + V9X_MATRIC + V9X->V9X_CODCAT + DTOS(V9X->V9X_DTINIC) )

								xTAFTagGroup( "observacoes";
											, {{ "observacao", V9Z->V9Z_OBS,, .F. }};						
											, @cObserv,, .F. )
						
								V9Z->( DbSkip() )
							EndDo
						EndIf

						xTAFTagGroup( "sucessaoVinc";
									, {{ "tpInsc", V9X->V9X_TPINSC,, .F. };
									,  { "nrInsc", V9X->V9X_NRINSC,, .F. };
									,  { "matricAnt", V9X->V9X_MATANT,, .T. };
									,  { "dtTransf", V9X->V9X_DTTRAN,, .F. }};				
									, @cSucVinc,, .F. )
						
				
						If !cVerSchema $ "S_01_02_00|S_01_03_00"
							xTAFTagGroup( "infoDeslig";
										, {{ "dtDeslig", V9X->V9X_DTDESL,, .F. };
										,  { "mtvDeslig", Posicione("C8O",1,xFilial("C8O") + V9X->V9X_MTVDES,"C8O_CODIGO"),, .F. };
										,  { "dtProjFimAPI", V9X->V9X_DTFPRO,, .T. }};										
										,  @cInfoDes,, .T. )
						Else

							If __cPicVrAlim == Nil
								__cPicVrAlim := PesqPict("V9X", "V9X_VRALIM")
							EndIf

							xTAFTagGroup( "infoDeslig";
										, {{ "dtDeslig"     , V9X->V9X_DTDESL, , .F. };
										,  { "mtvDeslig"	, Posicione("C8O", 1,xFilial("C8O") + V9X->V9X_MTVDES,"C8O_CODIGO"),, .F. };
										,  { "dtProjFimAPI" , V9X->V9X_DTFPRO, , .T. };
										,  { "pensAlim"		, V9X->V9X_PENSAL, , .T. };
										,  { "percAliment"	, V9X->V9X_PERCAL, , .T. };
										,  { "vrAlim"		, V9X->V9X_VRALIM, __cPicVrAlim, .T. }};										
										,  @cInfoDes,, .T. )
						EndIf

						xTAFTagGroup( "infoVinc";
									, {{ "tpRegTrab", V9X->V9X_TPREGT,, .F. };
									,  { "tpRegPrev", V9X->V9X_TPREGP,, .F. };
									,  { "dtAdm"	, V9X->V9X_DTADM ,, .F. };
									,  { "tmpParc"	, V9X->V9X_TMPPAR,, .T. }};				
									,  @cInfoVinc;
									, { { "duracao" 		, cDurac	 , 0 } ;
									, { "observacoes"		, cObserv	 , 0 } ;
									, { "sucessaoVinc"		, cSucVinc	 , 0 } ;
									, { "infoDeslig"		, cInfoDes	 , 0 } },, .F.)
							

						xTAFTagGroup( "infoTerm";
									, {{ "dtTerm", V9X->V9X_DTFIM,, .F. };
									,  { "mtvDesligTSV", V9X->V9X_MTDTSV,, .T. }};
									, @cInfoTerm,, .F.)
						
						xTAFTagGroup( "infoCompl";
									, {{ "codCBO", Posicione("C8Z",1,xFilial("C8Z") + V9X->V9X_CODCBO, "C8Z_CODIGO"),, .T. };
									,  { "natAtividade", V9X->V9X_NATATV,, .T. }};
									, @cXml;
									, { { "remuneracao"	, cRemun	 , 0 };
									, { "infoVinc"		, cInfoVinc	 , 0 };
									, { "infoTerm"		, cInfoTerm	 , 0 } },, .F.)										
						
					EndIf

					cDurac    := ""
					cObserv   := ""
					cSucVinc  := ""
					cInfoDes  := ""
					cRemun    := ""
					cInfoVinc := ""
					cInfoTerm := ""
					
					V7A->( DbSetOrder(1) )
					If V7A->( MsSeek( xFilial("V7A") + V9W->V9W_ID + V9W->V9W_VERSAO + V9W->V9W_NRPROC + V9W->V9W_CPFTRA + V9W->V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) ) )
						While V7A->( !EoF() ) .And. V7A->( V7A_FILIAL + V7A_ID + V7A_VERSAO + V7A_NRPROC + V7A_CPFTRA + V7A_MATRIC + V7A_CODCAT + DTOS(V7A_DTINIC) ) == xFilial("V9W") + V9W->( V9W_ID + V9W_VERSAO + V9W_NRPROC + V9W_CPFTRA + V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) )
														
							xTAFTagGroup( "mudCategAtiv";
										, {{ "codCateg", Posicione( "C87", 1, xFilial("C87") + V7A->V7A_NEWCAT, "C87_CODIGO" ),, .F. };
										,  { "natAtividade", V7A->V7A_NATATV,, .T. };
										,  { "dtMudCategAtiv", V7A->V7A_DTMUDC,, .F. }};
										,  @cXml,, .F. )

							V7A->( DbSkip() )
						EndDo
					EndIf

					V7B->( DbSetOrder(1) )
					If V7B->( MsSeek( xFilial("V7B") + V9W->V9W_ID + V9W->V9W_VERSAO + V9W->V9W_NRPROC + V9W->V9W_CPFTRA + V9W->V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) ) )
						While V7B->( !EoF() ) .And. V7B->( V7B_FILIAL + V7B_ID + V7B_VERSAO + V7B_NRPROC + V7B_CPFTRA + V7B_MATRIC + V7B_CODCAT + DTOS(V7B_DTINIC) ) == xFilial("V9W") + V9W->( V9W_ID + V9W_VERSAO + V9W_NRPROC + V9W_CPFTRA + V9W_MATRIC + V9W_CODCAT + DTOS(V9W_DTINIC) )

							xTAFTagGroup( "unicContr";
										, {{ "matUnic", V7B->V7B_MATUNI,, .T. };
										,  { "codCateg", Posicione( "C87", 1, xFilial("C87") + V7B->V7B_NEWCAT, "C87_CODIGO" ),, .T. };
										,  { "dtInicio", V7B->V7B_DTTSV,, .T. }};
										,  @cXml,, .F. )

							V7B->( DbSkip() )
						EndDo
					EndIf

					V7H->( DbSetOrder(1) )
					If V7H->( MsSeek( xFilial("V7H") + V9W->V9W_ID + V9W->V9W_VERSAO + V9W->V9W_NRPROC + V9W->V9W_CPFTRA + V9W->V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) ) )
						
						If !cVerSchema $ "S_01_02_00|S_01_03_00"
							If __cPicVlVerb == Nil
								__cPicVlVerb := PesqPict( "V7H", "V7H_VLVERB" )
								__cPicVlaVsp := PesqPict( "V7H", "V7H_VLAVSP" )
								__cPicVlApi	 := PesqPict( "V7H", "V7H_VRAPI"  )
								__cPicVlInde := PesqPict( "V7H", "V7H_VLINDE" )
								__cPicVlBase := PesqPict( "V7H", "V7H_VLBASE" )
							EndIf
						EndIf
						
						While V7H->( !EoF() ) .And. V7H->( V7H_FILIAL + V7H_ID + V7H_VERSAO + V7H_NRPROC + V7H_CPFTRA + V7H_MATRIC + V7H_CODCAT + DTOS(V7H_DTINIC) ) == xFilial("V9W") + V9W->( V9W_ID + V9W_VERSAO + V9W_NRPROC + V9W_CPFTRA + V9W_MATRIC + V9W->V9W_CODCAT + DTOS(V9W->V9W_DTINIC) )
							
							If !cVerSchema $ "S_01_02_00|S_01_03_00"
								cXml += 	"<ideEstab>"
								cXml += 		xTafTag("tpInsc", V7H->V7H_TPINSC,, .F.)
								cXml += 		xTafTag("nrInsc", V7H->V7H_NRINSC,, .F.)
								cXml += 		"<infoVlr>"
								cXml += 			xTafTag("compIni"        , substr(V7H->V7H_COMPIN, 1, 4) + '-' +  substr(V7H->V7H_COMPIN, 5, 2),             , .F.     )
								cXml += 			xTafTag("compFim"        , substr(V7H->V7H_COMPFI, 1, 4) + '-' +  substr(V7H->V7H_COMPFI, 5, 2),             , .F.	   )
								cXml += 			xTafTag("repercProc"     , V7H->V7H_REPPRO                                                     ,             , .F.     )
								cXml += 			xTafTag("vrRemun"        , V7H->V7H_VLVERB                                                     , __cPicVlVerb, .F.,,.T.)
								cXml += 			xTafTag("vrAPI"          , V7H->V7H_VLAVSP                                                     , __cPicVlaVsp, .F.,,.T.)
								cXml += 			xTafTag("vr13API"        , V7H->V7H_VRAPI                                                      , __cPicVlApi , .F.,,.T.)
								cXml += 			xTafTag("vrInden"        , V7H->V7H_VLINDE                                                     , __cPicVlInde, .F.,,.T.)
								cXml += 			xTafTag("vrBaseIndenFGTS", V7H->V7H_VLBASE                                                     , __cPicVlBase, .T.     )
								cXml += 			xTafTag("pagDiretoResc"  , xFunTrcSN(V7H->V7H_PAGDIR, 1)                                       ,             , .T.     )
							Else
								cXml += 	"<ideEstab>"
								cXml += 		xTafTag("tpInsc", V7H->V7H_TPINSC,, .F.)
								cXml += 		xTafTag("nrInsc", V7H->V7H_NRINSC,, .F.)
								cXml += 		"<infoVlr>"
								cXml += 			xTafTag("compIni"        , substr(V7H->V7H_COMPIN, 1, 4) + '-' +  substr(V7H->V7H_COMPIN, 5, 2),             , .F.     )
								cXml += 			xTafTag("compFim"        , substr(V7H->V7H_COMPFI, 1, 4) + '-' +  substr(V7H->V7H_COMPFI, 5, 2),             , .F.	   )
								cXml += 			xTafTag("indReperc"      , V7H->V7H_INDREP                                                     , 			 , .T.,,.T.)
								cXml += 			xTafTag("indenSD"        , V7H->V7H_INDESD                                                     , 			 , .T.     )
								cXml += 			xTafTag("indenAbono"     , V7H->V7H_INDABO                                                     ,             , .T.	   )
							EndIf


							If cVerSchema $ "S_01_02_00|S_01_03_00"
								If !Empty(V7Q->V7Q_ANOBAS)
									V7Q->( DbSetOrder(1) )
									If V7Q->( MsSeek( xFilial("V7H") + V7H->V7H_ID + V7H->V7H_VERSAO + V7H->V7H_NRPROC + V7H->V7H_CPFTRA + V7H->V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) ) )

										While V7Q->( !EoF() ) .And. V7Q->( V7Q_FILIAL + V7Q_ID + V7Q_VERSAO + V7Q_NRPROC + V7Q_CPFTRA + V7Q_MATRIC + V7Q_CODCAT + DTOS(V7Q_DTINIC) ) == xFilial("V7H") + V7H->( V7H_ID + V7H_VERSAO + V7H_NRPROC + V7H_CPFTRA + V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) )

											cXml += 			"<abono>"				
											cXml += 				xTafTag("anoBase", V7Q->V7Q_ANOBAS ,,,,.F.)						
											cXml += 			"</abono>"

											V7Q->( DbSkip() )								
										EndDo
									EndIf
								EndIf
							EndIf

							V7I->( DbSetOrder(1 ) )
							If V7I->( MsSeek( xFilial("V7I") + V7H->V7H_ID + V7H->V7H_VERSAO + V7H->V7H_NRPROC + V7H->V7H_CPFTRA + V7H->V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) ) )
								
								
								If __cPicVrMen == Nil
									If !cVerSchema $ "S_01_02_00|S_01_03_00"
										__cPicVrMen  := PesqPict( "V7I", "V7I_VRMEN"  )
										__cPicVrCP 	 := PesqPict( "V7I", "V7I_VRCP"   )
										__cPicVrFGTS := PesqPict( "V7I", "V7I_VRFGTS" )
										__cPicBcFGTS := PesqPict( "V7I", "V7I_BCFGTS" )
										__cPicVrFGui := PesqPict( "V7I", "V7I_VRFGUI" )
										__cPicFgtsSg := PesqPict( "V7I", "V7I_FGTSGU" )
										__cPicVrPrev := PesqPict( "V7I", "V7I_VRPREV" )
									Else
										__cPicVrMen  := PesqPict( "V7I", "V7I_VRMEN"  )
										__cPicVrCP 	 := PesqPict( "V7I", "V7I_VRCP"   )
										__cPicVrPrev := PesqPict( "V7I", "V7I_VRPREV" )	
										__cPicBcProt := PesqPict( "V7I", "V7I_BCPROT" )	
										__cPicBcSefi := PesqPict( "V7I", "V7I_BCSEFI" )	
										__cPicBcDeCa := PesqPict( "V7I", "V7I_BCDECA" )
									EndIf
								EndIf
								
								While V7I->( !EoF() ) .And. V7I->( V7I_FILIAL + V7I_ID + V7I_VERSAO + V7I_NRPROC + V7I_CPFTRA + V7I_MATRIC + V7I_CODCAT + DTOS(V7I_DTINIC) ) == xFilial("V7H") + V7H->( V7H_ID + V7H_VERSAO + V7H_NRPROC + V7H_CPFTRA + V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) )

									cXml += 			"<idePeriodo>"				
									cXml += 				xTafTag("perRef", substr(V7I->V7I_PERREF, 1, 4) + '-' +  substr(V7I->V7I_PERREF, 5, 2),, .T.)
									
									If cVerSchema $ "S_01_02_00|S_01_03_00" 
										cXml += 				"<baseCalculo>"
										cXml += 					xTafTag("vrBcCpMensal", V7I->V7I_VRMEN , __cPicVrMen , .F.,,.T.)
										cXml += 					xTafTag("vrBcCp13"    , V7I->V7I_VRCP  , __cPicVrCP  , .T.,,.T.)
										xTAFTagGroup( "infoAgNocivo";
																			, {{ "grauExp", Posicione("C88", 1, xFilial("C88") + V7I->V7I_GRAUEX, "C88_CODIGO"),, .F. }};
																			,  @cXml,, .F. )
									
										cXml += 				"</baseCalculo>"
									Else
										cXml += 				"<baseCalculo>"
										cXml += 					xTafTag("vrBcCpMensal", V7I->V7I_VRMEN , __cPicVrMen , .F.,,.T.)
										cXml += 					xTafTag("vrBcCp13"    , V7I->V7I_VRCP  , __cPicVrCP  , .F.,,.T.)
										cXml += 					xTafTag("vrBcFgts"    , V7I->V7I_VRFGTS, __cPicVrFGTS, .F.,,.T.)
										cXml += 					xTafTag("vrBcFgts13"  , V7I->V7I_BCFGTS, __cPicBcFGTS, .F.,,.T.)
										xTAFTagGroup( "infoAgNocivo";
																			, {{ "grauExp", Posicione("C88", 1, xFilial("C88") + V7I->V7I_GRAUEX, "C88_CODIGO"),, .F. }};
																			,  @cXml,, .F. )
									
										cXml += 				"</baseCalculo>"	
									EndIf

																
															If !cVerSchema $ "S_01_02_00|S_01_03_00"
																xTAFTagGroup( "infoFGTS";
																				, {{ "vrBcFgtsGuia"  , V7I->V7I_VRFGUI              , __cPicVrFGui, .F. ,,.T.};
																				,  { "vrBcFgts13Guia", V7I->V7I_FGTSGU              , __cPicFgtsSg, .F. ,,.T.};
																				,  { "pagDireto"     , xFunTrcSN(V7I->V7I_PAGDIR, 1),             , .F.      }};
																				,  @cXml,, .F. )
															Else	
																xTAFTagGroup( "infoFGTS";
																					, {{ "vrBcFGTSProcTrab", V7I->V7I_BCPROT            , __cPicBcProt, .F. ,,.T.};
																					,  { "vrBcFGTSSefip"   , V7I->V7I_BCSEFI            , __cPicBcSefi, .T. ,,   };
																					,  { "vrBcFGTSDecAnt"  , V7I->V7I_BCDECA            , __cPicBcDeCa, .T. ,,   }};
																					,  @cXml,, .F. )	
															EndIf
															
															xTAFTagGroup( "baseMudCateg";
																			, {{ "codCateg", Posicione( "C87", 1, xFilial("C87") + V7I->V7I_CATMUD, "C87_CODIGO" ),, .F. };
																			, { "vrBcCPrev", V7I->V7I_VRPREV, __cPicVrPrev, .F. ,,.T.}};
																			,  @cXml,, .F. )

									If cVerSchema $ "S_01_03_00" .AND. TafColumnPos("T8F_DIATRA") 
										 
										T8F->( DbSetOrder(1) )
										If T8F->( MsSeek( xFilial("V7H") + V7H->V7H_ID + V7H->V7H_VERSAO + V7H->V7H_NRPROC + V7H->V7H_CPFTRA + V7H->V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) ) )

											While T8F->( !EoF() ) .And. T8F->( T8F_FILIAL + T8F_ID + T8F_VERSAO + T8F_NRPROC + T8F_CPFTRA + T8F_MATRIC + T8F_CODCAT + DTOS(T8F_DTINIC) ) == xFilial("V7H") + V7H->( V7H_ID + V7H_VERSAO + V7H_NRPROC + V7H_CPFTRA + V7H_MATRIC + V7H->V7H_CODCAT + DTOS(V7H->V7H_DTINIC) )

												cXml += 			"<infoInterm>"				
												cXml += 				xTafTag("dia", T8F->T8F_DIATRA ,,.T.,,.F.,.F.)	
												cXml += 				xTafTag("hrsTrab", T8F->T8F_HRSTRA ,,.F.,,.F.,.F.)											
												cXml += 			"</infoInterm>"

												T8F->( DbSkip() )								
											EndDo
										EndIf
										
									EndIf																			
									
									cXml += 			"</idePeriodo>"

									V7I->( DbSkip() )								
								EndDo
							EndIf

							cXml += 		"</infoVlr>"
							cXml += 	"</ideEstab>"
							
							V7H->( DbSkip() )
						EndDo
					EndIf

					cXml += "</infoContr>"

					V9W->( DbSkip() )
				EndDo
			EndIf

			cXml += "</ideTrab>"

			cXml := xTafCabXml( cXml, "V9U", cLayout, cReg,,,,, cEsocial )		
		
		EndIf

		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf		

		cFilAnt := cFilBkp

	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF608Grv
Funcao de gravacao para atender o registro S-2500 (Cadastro de Processo Trabalhista)

@parametros:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML   -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 

@author José Riquelmo/Silas Gomes
@since 25/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF608Grv( cLayout as character, nOpc as numeric, cFilEv as character, oXML as object, cOwner as character,;
					cFilTran as character, cPredeces as character, nTafRecno as numeric, cComplem as character,;
					cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character,;
					cEvtOri as character, lMigrador as logical, lDepGPE as logical, cKey as character,;
					cMatrC9V as Character, lLaySmpTot as Logical, lExclCMJ as Logical, oTransf as Object, cXml as Character)

	Local aChave     as array
	Local aIncons    as array
	Local aRules     as array
	Local cCabec     as character
	Local cCmpsNoUpd as character
	Local cInconMsg  as character
	Local cLogOpeAnt as character
    Local cCodEvent  as character
	Local cV9VPath   as character
	Local cV9WPath   as character
	Local cV9XPath   as character
	Local cV9YPath   as character
	Local cV9ZPath   as character
	Local cV7APath   as character
	Local cV7BPath   as character
	Local cV7HPath   as character
	Local cV7IPath   as character
	Local cV7QPath   as character
	Local cT8FPath   as character
	Local cIndRetif	 as character
	Local cLayNmSpac as character
	Local cSequen	 as character
	Local lRet       as logical
	Local nI         as numeric
	Local n3         as numeric
	Local nV9V       as numeric
	Local nV9W       as numeric
	Local nV9X       as numeric
	Local nV9Y       as numeric
	Local nV9Z       as numeric
	Local nV7A       as numeric
	Local nV7B       as numeric
	Local nV7H       as numeric
	Local nV7I       as numeric
	Local nV7Q       as numeric
	Local nT8F       as numeric
	Local nIndChv    as numeric
	Local nSeqErrGrv as numeric

	Local oModel     as object

	Private oDados   as object

	Default cEmpOriGrp := ""
	Default cEvtOri    := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cKey       := ""
	Default cLayout    := "2500"
	Default cOwner     := ""
	Default cXml       := ""
	Default cXmlID     := ""
	Default cMatrC9V   := ""
	Default lDepGPE    := .F.
	Default lMigrador  := .F.
	Default nOpc       := 1
	Default oTransf    := Nil
	Default oXML       := Nil

	aChave             := {}
	aIncons            := {}
	aRules             := {}

	cCabec             := "/eSocial/evtProcTrab"
	cCmpsNoUpd         := "|V9U_FILIAL|V9U_ID|V9U_VERSAO|V9U_NOMEVE|V9U_VERANT|V9U_PROTUL|V9U_PROTPN|V9U_EVENTO|V9U_STATUS|V9U_ATIVO|"
	cInconMsg          := ""
	cLogOpeAnt         := ''
	cCodEvent          := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	cIndRetif		   := ""
	cV9VPath           := ""
	cV9WPath           := ""
	cV9XPath           := ""
	cV9YPath           := ""
	cV9ZPath           := ""
	cV7APath           := ""
	cV7BPath           := ""
	cV7HPath           := ""
	cV7IPath           := ""
	cV7QPath           := ""
	cT8FPath           := ""
	cLayNmSpac		   := ""
	cSequen			   := ""

	lRet               := .F.
	
	nI                 := 0
	n3                 := 0
	nV9V               := 0
	nV9W               := 0				
	nV9X               := 0
	nV9Y               := 0
	nV9Z               := 0
	nV7A               := 0
	nV7B               := 0
	nV7H               := 0
	nV7I               := 0
	nV7Q               := 0
	nT8F               := 0
	nIndChv            := 6
	nSeqErrGrv         := 0

	oModel             := Nil
	oDados             := oXML

	//Chave do Registro
	cNrProc   := FTafGetVal(  cCabec + "/infoProcesso/nrProcTrab", "C", .F., @aIncons, .F. )
	cCpf      := FTafGetVal(  cCabec + "/ideTrab/cpfTrab", "C", .F., @aIncons, .F. )
	cIndRetif := FTafGetVal(  cCabec + "/ideEvento/indRetif"        , "C", .F., @aIncons, .F.)

	If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")
		cSequen	  := FTafGetVal(  cCabec + "/ideTrab/ideSeqTrab", "C", .F., @aIncons, .F. )
	EndIf	

	Aadd( aChave, {"C", "V9U_NRPROC", cNrProc, .T.} )
	Aadd( aChave, {"C", "V9U_CPFTRA", cCpf   , .T.} )
	Aadd( aChave, {"C", "V9U_ATIVO"	, '1'	 , .T.} )

	If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")
		Aadd( aChave, {"C", "V9U_IDESEQ", cSequen, .T.} )
	EndIf
	

	V9U->( DbSetOrder(nIndChv) )

	If V9U->( MsSeek( xFilial("V9U") + Padr( cNrProc, TamSx3( "V9U_NRPROC" )[1])  + Padr( cCpf, TamSx3( "V9U_CPFTRA" )[1]) + '1' + IIf(lSimpl0103 .And. TafColumnPos("V9U_IDESEQ"), Padr( cSequen, TamSx3( "V9U_IDESEQ" )[1]), "" )))
		If !V9U->V9U_STATUS $ ( '2|6' ) .And. (cIndRetif == '2' .Or. cOwner == 'GPE')
			nOpc := 4
		EndIf
	EndIf

	Begin Transaction	

		cLayNmSpac := TafNameEspace(cXML)
		
		If FTafVldOpe( "V9U", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA608", cCmpsNoUpd )

			cLogOpeAnt := V9U->V9U_LOGOPE

			oModel:LoadValue( "MODEL_V9U", "V9U_NOMEVE", "S2500" )
			
			aRules := TAF608Rul(@cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			If nOpc <> 5

				oModel:LoadValue( "MODEL_V9U", "V9U_FILIAL", V9U->V9U_FILIAL )
				oModel:LoadValue( "MODEL_V9U", "V9U_XMLID", cXmlID )

				oModel:LoadValue( "MODEL_V9U", "V9U_LAYOUT", cLayNmSpac )
				

				//Rodo o aRules para gravar as informacoes
				For nI := 1 to Len( aRules )
					oModel:LoadValue("MODEL_V9U", aRules[ nI, 01 ],  aRules[nI,2])
				Next nI

				If nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V9U', 'V9U_LOGOPE' , '1', '' )
				ElseIf nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V9U', 'V9U_LOGOPE' , '', cLogOpeAnt )
				EndIf
				
				If !lSimpl12 
					nV9V := 1
					cV9VPath := cCabec + "/ideTrab/dependente[" + Alltrim(Str(nV9V)) + "]"

					If nOpc == 4
						For n3 := 1 To oModel:GetModel( "MODEL_V9V" ):Length()
							oModel:GetModel( "MODEL_V9V" ):GoLine(n3)
							oModel:GetModel( "MODEL_V9V" ):DeleteLine()
						Next n3
					EndIf

					While oDados:XPathHasNode(cV9VPath)

						oModel:GetModel( "MODEL_V9V" ):lValid := .T.

						If nOpc == 4 .Or. nV9V > 1
							oModel:GetModel( "MODEL_V9V" ):AddLine()
						EndIf

						If oDados:XPathHasNode(cV9VPath + "/cpfDep")
							oModel:LoadValue( "MODEL_V9V", "V9V_CPFDEP", FTafGetVal( cV9VPath + "/cpfDep", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9VPath + "/tpDep")
							oModel:LoadValue( "MODEL_V9V", "V9V_TPDEP", FGetIdInt( "tpDep", "", cV9VPath + "/tpDep",,,, @cInconMsg, @nSeqErrGrv ) )																	
						EndIf

						If oDados:XPathHasNode(cV9VPath + "/descDep")
							oModel:LoadValue( "MODEL_V9V", "V9V_DSCDEP", FTafGetVal( cV9VPath + "/descDep", "C", .F., @aIncons, .F. ) )
						EndIf

						nV9V++
						cV9VPath := cCabec + "/ideTrab/dependente[" + Alltrim(Str(nV9V)) + "]"
					EndDo
				EndIf

				nV9W := 1
				cV9WPath := cCabec + "/ideTrab/infoContr[" + Alltrim(Str(nV9W)) + "]"

				If nOpc == 4 
					For n3 := 1 To oModel:GetModel( "MODEL_V9W" ):Length()
						oModel:GetModel( "MODEL_V9W" ):GoLine(n3)
						oModel:GetModel( "MODEL_V9W" ):DeleteLine()
					Next n3
				EndIf

				While oDados:XPathHasNode(cV9WPath)

					oModel:GetModel( "MODEL_V9W" ):lValid := .T.

					If nOpc == 4 .Or. nV9W > 1
						oModel:GetModel( "MODEL_V9W" ):AddLine()
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/tpContr")
						oModel:LoadValue( "MODEL_V9W", "V9W_TPCONT", FTafGetVal( cV9WPath + "/tpContr", "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/indContr")
						oModel:LoadValue( "MODEL_V9W", "V9W_INDCON", xFunTrcSN(FTafGetVal( cV9WPath + "/indContr", "C", .F., @aIncons, .F. ), 2) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/dtAdmOrig")
						oModel:LoadValue( "MODEL_V9W", "V9W_DTADMO", FTafGetVal( cV9WPath + "/dtAdmOrig", "D", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/indReint")
						oModel:LoadValue( "MODEL_V9W", "V9W_INDREI", xFunTrcSN(FTafGetVal( cV9WPath + "/indReint", "C", .F., @aIncons, .F. ), 2) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/indCateg")
						oModel:LoadValue( "MODEL_V9W", "V9W_INDCAT", xFunTrcSN(FTafGetVal( cV9WPath + "/indCateg", "C", .F., @aIncons, .F. ), 2) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/indNatAtiv")
						oModel:LoadValue( "MODEL_V9W", "V9W_INDNAT", xFunTrcSN(FTafGetVal( cV9WPath + "/indNatAtiv", "C", .F., @aIncons, .F. ), 2) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/indMotDeslig")
						oModel:LoadValue( "MODEL_V9W", "V9W_INDMDE", xFunTrcSN(FTafGetVal( cV9WPath + "/indMotDeslig", "C", .F., @aIncons, .F. ), 2) )
					EndIf

					If !lSimpl12 
						If oDados:XPathHasNode(cV9WPath + "/indUnic")
							oModel:LoadValue( "MODEL_V9W", "V9W_INDUNI", xFunTrcSN(FTafGetVal( cV9WPath + "/indUnic", "C", .F., @aIncons, .F. ), 2) )
						EndIf
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/matricula")
						oModel:LoadValue( "MODEL_V9W", "V9W_MATRIC", FTafGetVal( cV9WPath + "/matricula", "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/codCateg")
						oModel:LoadValue( "MODEL_V9W", "V9W_CODCAT", FGetIdInt( "codCateg", "", cV9WPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
					EndIf

					If oDados:XPathHasNode(cV9WPath + "/dtInicio")
						oModel:LoadValue( "MODEL_V9W", "V9W_DTINIC", FTafGetVal( cV9WPath + "/dtInicio", "D", .F., @aIncons, .F. ) )
					EndIf					
					
					cV9XPath := cV9WPath + "/infoCompl"

					If nOpc == 4 
						For n3 := 1 To oModel:GetModel( "MODEL_V9X" ):length()
							oModel:GetModel( "MODEL_V9X" ):GoLine(n3)							
						Next n3
					EndIf
					
					If oDados:XPathHasNode(cV9XPath)

						oModel:GetModel( "MODEL_V9X" ):lValid := .T.						

						If oDados:XPathHasNode(cV9XPath + "/codCBO")
							oModel:LoadValue( "MODEL_V9X", "V9X_CODCBO", FGetIdInt( "codCBO", "", cV9XPath + "/codCBO",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/natAtividade")
							oModel:LoadValue( "MODEL_V9X", "V9X_NATATV", FTafGetVal( cV9XPath + "/natAtividade", "C", .F., @aIncons, .F. ) )
						EndIf

						nV9Y := 1						
						cV9YPath := cV9XPath + "/remuneracao[" + Alltrim(Str(nV9Y)) + "]"

						If nOpc == 4
							For n3 := 1 To oModel:GetModel( "MODEL_V9Y" ):Length()
								oModel:GetModel( "MODEL_V9Y" ):GoLine(n3)
								oModel:GetModel( "MODEL_V9Y" ):DeleteLine()
							Next n3
						EndIf

						While oDados:XPathHasNode(cV9YPath)

							oModel:GetModel( "MODEL_V9Y" ):lValid:= .T.

							If nOpc == 4 .Or. nV9Y > 1
								oModel:GetModel( "MODEL_V9Y" ):AddLine()
							EndIf

							If oDados:XPathHasNode(cV9YPath + "/dtRemun")
								oModel:LoadValue( "MODEL_V9Y", "V9Y_DTREMU", FTafGetVal( cV9YPath + "/dtRemun", "D", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cV9YPath + "/vrSalFx")
								oModel:LoadValue( "MODEL_V9Y", "V9Y_VRSAL", FTafGetVal( cV9YPath + "/vrSalFx", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cV9YPath + "/undSalFixo")
								oModel:LoadValue( "MODEL_V9Y", "V9Y_UNDSAL", FTafGetVal( cV9YPath + "/undSalFixo", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cV9YPath + "/dscSalVar")
								oModel:LoadValue( "MODEL_V9Y", "V9Y_DSCSAL", FTafGetVal( cV9YPath + "/dscSalVar", "C", .F., @aIncons, .F. ) )
							EndIf

							nV9Y++
							cV9YPath := cV9XPath + "/remuneracao[" + Alltrim(Str(nV9Y)) + "]"
						EndDo

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/tpRegTrab")
							oModel:LoadValue( "MODEL_V9X", "V9X_TPREGT", FTafGetVal( cV9XPath + "/infoVinc/tpRegTrab", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/tpRegPrev")
							oModel:LoadValue( "MODEL_V9X", "V9X_TPREGP", FTafGetVal( cV9XPath + "/infoVinc/tpRegPrev", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/dtAdm")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTADM", FTafGetVal( cV9XPath + "/infoVinc/dtAdm", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/tmpParc")
							oModel:LoadValue( "MODEL_V9X", "V9X_TMPPAR", FTafGetVal( cV9XPath + "/infoVinc/tmpParc", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/duracao/tpContr")
							oModel:LoadValue( "MODEL_V9X", "V9X_TPCDUR", FTafGetVal( cV9XPath + "/infoVinc/duracao/tpContr", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/duracao/dtTerm")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTTERM", FTafGetVal( cV9XPath + "/infoVinc/duracao/dtTerm", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/duracao/clauAssec")
							oModel:LoadValue( "MODEL_V9X", "V9X_CLAASS", xFunTrcSN(FTafGetVal( cV9XPath + "/infoVinc/duracao/clauAssec", "C", .F., @aIncons, .F. ), 2) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/duracao/objDet")
							oModel:LoadValue( "MODEL_V9X", "V9X_OBJDET", FTafGetVal( cV9XPath + "/infoVinc/duracao/objDet", "C", .F., @aIncons, .F. ) )
						EndIf

						nV9Z := 1						
						cV9ZPath := cV9XPath + "/infoVinc/observacoes[" + Alltrim(Str(nV9Z)) + "]"

						If nOpc == 4 
							For n3 := 1 To oModel:GetModel( "MODEL_V9Z" ):Length()
								oModel:GetModel( "MODEL_V9Z" ):GoLine(n3)
								oModel:GetModel( "MODEL_V9Z" ):DeleteLine()
							Next n3
						EndIf

						While oDados:XPathHasNode(cV9ZPath)

							oModel:GetModel( "MODEL_V9Z" ):lValid:= .T.

							If nOpc == 4 .Or. nV9Z > 1
								oModel:GetModel( "MODEL_V9Z" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV9ZPath + "/observacao" )
								oModel:LoadValue( "MODEL_V9Z", "V9Z_OBS", FTafGetVal( cV9ZPath + "/observacao"	, "C", .F., @aIncons, .F. ) )
							EndIf

							nV9Z++
							cV9ZPath := cV9XPath + "/infoVinc/observacoes[" + Alltrim(Str(nV9Z)) + "]"
						EndDo

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/sucessaoVinc/tpInsc")
							oModel:LoadValue( "MODEL_V9X", "V9X_TPINSC", FTafGetVal( cV9XPath + "/infoVinc/sucessaoVinc/tpInsc", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/sucessaoVinc/nrInsc")
							oModel:LoadValue( "MODEL_V9X", "V9X_NRINSC", FTafGetVal( cV9XPath + "/infoVinc/sucessaoVinc/nrInsc", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/sucessaoVinc/matricAnt")
							oModel:LoadValue( "MODEL_V9X", "V9X_MATANT", FTafGetVal( cV9XPath + "/infoVinc/sucessaoVinc/matricAnt", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/sucessaoVinc/dtTransf")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTTRAN", FTafGetVal( cV9XPath + "/infoVinc/sucessaoVinc/dtTransf", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/dtDeslig")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTDESL", FTafGetVal( cV9XPath + "/infoVinc/infoDeslig/dtDeslig", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/mtvDeslig")
							oModel:LoadValue( "MODEL_V9X", "V9X_MTVDES", FGetIdInt( "mtvDeslig", "", cV9XPath + "/infoVinc/infoDeslig/mtvDeslig",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/dtProjFimAPI")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTFPRO", FTafGetVal( cV9XPath + "/infoVinc/infoDeslig/dtProjFimAPI", "D", .F., @aIncons, .F. ) )
						EndIf

						If  lSimpl12 .Or. lSimpl0103

							If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/pensAlim")
								oModel:LoadValue( "MODEL_V9X", "V9X_PENSAL", FTafGetVal( cV9XPath + "/infoVinc/infoDeslig/pensAlim", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/percAliment")
								oModel:LoadValue( "MODEL_V9X", "V9X_PERCAL", FTafGetVal( cV9XPath + "/infoVinc/infoDeslig/percAliment", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cV9XPath + "/infoVinc/infoDeslig/vrAlim")
								oModel:LoadValue( "MODEL_V9X", "V9X_VRALIM", FTafGetVal( cV9XPath + "/infoVinc/infoDeslig/vrAlim", "N", .F., @aIncons, .F. ) )
							EndIf

						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoTerm/dtTerm")
							oModel:LoadValue( "MODEL_V9X", "V9X_DTFIM", FTafGetVal( cV9XPath + "/infoTerm/dtTerm", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV9XPath + "/infoTerm/mtvDesligTSV")
							oModel:LoadValue( "MODEL_V9X", "V9X_MTDTSV", FTafGetVal( cV9XPath + "/infoTerm/mtvDesligTSV", "C", .F., @aIncons, .F. ) )
						EndIf						

					EndIf

					nV7A := 1					
					cV7APath := cV9WPath + "/mudCategAtiv[" + AllTrim(Str(nV7A)) + "]"

					If nOpc == 4
						For n3 := 1 To oModel:GetModel( "MODEL_V7A" ):Length()
							oModel:GetModel( "MODEL_V7A" ):GoLine(n3)
							oModel:GetModel( "MODEL_V7A" ):DeleteLine()
						Next n3
					EndIF

					While oDados:XPathHasNode(cV7APath)

						oModel:GetModel( "MODEL_V7A" ):lValid := .T.

						If nOpc == 4 .Or. nV7A > 1
							oModel:GetModel( "MODEL_V7A" ):AddLine()
						EndIf

						If oDados:XPathHasNode(cV7APath + "/codCateg")
							oModel:LoadValue( "MODEL_V7A", "V7A_NEWCAT", FGetIdInt( "codCateg", "", cV7APath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:XPathHasNode(cV7APath + "/natAtividade")
							oModel:LoadValue( "MODEL_V7A", "V7A_NATATV", FTafGetVal( cV7APath + "/natAtividade", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV7APath + "/dtMudCategAtiv")
							oModel:LoadValue( "MODEL_V7A", "V7A_DTMUDC", FTafGetVal( cV7APath + "/dtMudCategAtiv", "D", .F., @aIncons, .F. ) )
						EndIf

						nV7A++
						cV7APath := cV9WPath + "/mudCategAtiv[" + AllTrim(Str(nV7A)) + "]"

					EndDo

					nV7B := 1					
					cV7BPath := cV9WPath + "/unicContr[" + AllTrim(Str(nV7B)) + "]"

					If nOpc == 4
						For n3 := 1 To oModel:GetModel( "MODEL_V7B" ):Length()
							oModel:GetModel( "MODEL_V7B" ):GoLine(n3)
							oModel:GetModel( "MODEL_V7B" ):DeleteLine()
						Next n3
					EndIF

					While oDados:XPathHasNode(cV7BPath)

						oModel:GetModel( "MODEL_V7B" ):lValid := .T.

						If nOpc == 4 .Or. nV7B > 1
							oModel:GetModel( "MODEL_V7B" ):AddLine()
						EndIf

						If oDados:XPathHasNode(cV7BPath + "/matUnic")
							oModel:LoadValue( "MODEL_V7B", "V7B_MATUNI", FTafGetVal( cV7BPath + "/matUnic", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(cV7BPath + "/codCateg")
							oModel:LoadValue( "MODEL_V7B", "V7B_NEWCAT", FGetIdInt( "codCateg", "", cV7BPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:XPathHasNode(cV7BPath + "/dtInicio")
							oModel:LoadValue( "MODEL_V7B", "V7B_DTTSV", FTafGetVal( cV7BPath + "/dtInicio", "D", .F., @aIncons, .F. ) )
						EndIf

						nV7B++
						cV7BPath := cV9WPath + "/unicContr[" + AllTrim(Str(nV7B)) + "]"
					EndDo
			
					cV7HPath := cV9WPath + "/ideEstab"

					If nOpc == 4
						For n3 := 1 To oModel:GetModel( "MODEL_V7H" ):Length()
							oModel:GetModel( "MODEL_V7H" ):GoLine(n3)							
						Next n3
					EndIF
					
					If oDados:XPathHasNode(cV7HPath)

						oModel:GetModel( "MODEL_V7H" ):lValid := .T.												

						If oDados:XPathHasNode(	cV7HPath + "/tpInsc" )
							oModel:LoadValue( "MODEL_V7H", "V7H_TPINSC", FTafGetVal( cV7HPath + "/tpInsc"	, "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cV7HPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_V7H", "V7H_NRINSC", FTafGetVal( cV7HPath + "/nrInsc"	, "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cV7HPath + "/infoVlr/compIni" )
							If At("-", FTafGetVal( cV7HPath + "/infoVlr/compIni", "C", .F., @aIncons, .F. )) > 0
								oModel:LoadValue( "MODEL_V7H", "V7H_COMPIN", StrTran( FTafGetVal( cV7HPath + "/infoVlr/compIni", "C", .F., @aIncons, .F. ), "-", "" ) )	
							Else
								oModel:LoadValue( "MODEL_V7H", "V7H_COMPIN", FTafGetVal( cV7HPath + "/infoVlr/compIni", "C", .F., @aIncons, .F. ) )
							EndIf											
						EndIf

						If oDados:XPathHasNode(	cV7HPath + "/infoVlr/compFim" )
							If At("-", FTafGetVal( cV7HPath + "/infoVlr/compFim", "C", .F., @aIncons, .F. )) > 0
								oModel:LoadValue( "MODEL_V7H", "V7H_COMPFI", StrTran( FTafGetVal( cV7HPath + "/infoVlr/compFim", "C", .F., @aIncons, .F. ), "-", "" ) )	
							Else
								oModel:LoadValue( "MODEL_V7H", "V7H_COMPFI", FTafGetVal( cV7HPath + "/infoVlr/compFim", "C", .F., @aIncons, .F. ) )
							EndIf					
						EndIf

						If lSimpl12 .Or. lSimpl0103

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/indReperc" )
								oModel:LoadValue( "MODEL_V7H", "V7H_INDREP", FTafGetVal( cV7HPath + "/infoVlr/indReperc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/indenSD" )
								oModel:LoadValue( "MODEL_V7H", "V7H_INDESD", FTafGetVal( cV7HPath + "/infoVlr/indenSD"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/indenAbono" )
								oModel:LoadValue( "MODEL_V7H", "V7H_INDABO", FTafGetVal( cV7HPath + "/infoVlr/indenAbono"	, "C", .F., @aIncons, .F. ) )
							EndIf

						EndIf
						
						If !lSimpl12 
							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/repercProc" )
								oModel:LoadValue( "MODEL_V7H", "V7H_REPPRO", FTafGetVal( cV7HPath + "/infoVlr/repercProc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/vrRemun" )
								oModel:LoadValue( "MODEL_V7H", "V7H_VLVERB", FTafGetVal( cV7HPath + "/infoVlr/vrRemun"	, "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/vrAPI" )
								oModel:LoadValue( "MODEL_V7H", "V7H_VLAVSP", FTafGetVal( cV7HPath + "/infoVlr/vrAPI"	, "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/vr13API" )
								oModel:LoadValue( "MODEL_V7H", "V7H_VRAPI", FTafGetVal( cV7HPath + "/infoVlr/vr13API"	, "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/vrInden" )
								oModel:LoadValue( "MODEL_V7H", "V7H_VLINDE", FTafGetVal( cV7HPath + "/infoVlr/vrInden"	, "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/vrBaseIndenFGTS" )
								oModel:LoadValue( "MODEL_V7H", "V7H_VLBASE", FTafGetVal( cV7HPath + "/infoVlr/vrBaseIndenFGTS"	, "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7HPath + "/infoVlr/pagDiretoResc" )
								oModel:LoadValue( "MODEL_V7H", "V7H_PAGDIR", xFunTrcSN(FTafGetVal( cV7HPath + "/infoVlr/pagDiretoResc", "C", .F., @aIncons, .F. ), 2) )
							EndIf
						EndIf

						If  lSimpl12 .Or. lSimpl0103
							nV7Q := 1						
							cV7QPath := cV9WPath + "/ideEstab/infoVlr/abono[" + AllTrim(Str(nV7Q)) + "]""

							If nOpc == 4 
								For n3 := 1 to oModel:GetModel( "MODEL_V7Q" ):Length()
									oModel:GetModel( "MODEL_V7Q" ):GoLine(n3)
									oModel:GetModel( "MODEL_V7Q" ):DeleteLine()
								Next n3
							EndIf

							While oDados:XPathHasNode(cV7QPath)

								oModel:GetModel( "MODEL_V7Q" ):lValid := .T.

								If nOpc == 4 .Or. nV7Q > 1
									oModel:GetModel( "MODEL_V7Q" ):AddLine()
								EndIf

								If oDados:XPathHasNode(	cV7QPath + "/anoBase" )
									oModel:LoadValue( "MODEL_V7Q", "V7Q_ANOBAS", FTafGetVal( cV7QPath + "/anoBase"	, "C", .F., @aIncons, .F. ) )
								EndIf

								nV7Q++
								cV7QPath := cV9WPath + "/ideEstab/infoVlr/abono[" + AllTrim(Str(nV7Q)) + "]""
							EndDo
						EndIf

						nV7I := 1						
						cV7IPath := cV9WPath + "/ideEstab/infoVlr/idePeriodo[" + AllTrim(Str(nV7I)) + "]""

						If nOpc == 4 
							For n3 := 1 to oModel:GetModel( "MODEL_V7I" ):Length()
								oModel:GetModel( "MODEL_V7I" ):GoLine(n3)
								oModel:GetModel( "MODEL_V7I" ):DeleteLine()
							Next n3
						EndIf

						While oDados:XPathHasNode(cV7IPath)

							oModel:GetModel( "MODEL_V7I" ):lValid := .T.

							If nOpc == 4 .Or. nV7I > 1
								oModel:GetModel( "MODEL_V7I" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/perRef" )
								If At("-", FTafGetVal( cV7IPath + "/perRef", "C", .F., @aIncons, .F. )) > 0
									oModel:LoadValue( "MODEL_V7I", "V7I_PERREF", StrTran( FTafGetVal( cV7IPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" ) )	
								Else
									oModel:LoadValue( "MODEL_V7I", "V7I_PERREF", FTafGetVal( cV7IPath + "/perRef", "C", .F., @aIncons, .F. ) )
								EndIf								
							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/baseCalculo/vrBcCpMensal" )
								oModel:LoadValue( "MODEL_V7I", "V7I_VRMEN", FTafGetVal( cV7IPath + "/baseCalculo/vrBcCpMensal", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/baseCalculo/vrBcCp13" )
								oModel:LoadValue( "MODEL_V7I", "V7I_VRCP", FTafGetVal( cV7IPath + "/baseCalculo/vrBcCp13", "N", .F., @aIncons, .F. ) )
							EndIf

							If !lSimpl12
								If oDados:XPathHasNode(	cV7IPath + "/baseCalculo/vrBcFgts" )
									oModel:LoadValue( "MODEL_V7I", "V7I_VRFGTS", FTafGetVal( cV7IPath + "/baseCalculo/vrBcFgts", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV7IPath + "/baseCalculo/vrBcFgts13" )
									oModel:LoadValue( "MODEL_V7I", "V7I_BCFGTS", FTafGetVal( cV7IPath + "/baseCalculo/vrBcFgts13", "N", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/baseCalculo/infoAgNocivo/grauExp" )
								oModel:LoadValue( "MODEL_V7I", "V7I_GRAUEX", FGetIdInt( "grauExp", "", cV7IPath + "/baseCalculo/infoAgNocivo/grauExp",,,, @cInconMsg, @nSeqErrGrv ) )																			
							EndIf

							If !lSimpl12 
								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/vrBcFgtsGuia" )
									oModel:LoadValue( "MODEL_V7I", "V7I_VRFGUI", FTafGetVal( cV7IPath + "/infoFGTS/vrBcFgtsGuia", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/vrBcFgts13Guia" )
									oModel:LoadValue( "MODEL_V7I", "V7I_FGTSGU", FTafGetVal( cV7IPath + "/infoFGTS/vrBcFgts13Guia", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/pagDireto" )
									oModel:LoadValue( "MODEL_V7I", "V7I_PAGDIR", xFunTrcSN(FTafGetVal( cV7IPath + "/infoFGTS/pagDireto", "C", .F., @aIncons, .F. ), 2) )
								EndIf
							EndIf

							If  lSimpl12 .Or. lSimpl0103

								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/vrBcFGTSProcTrab" )
									oModel:LoadValue( "MODEL_V7I", "V7I_BCPROT", FTafGetVal( cV7IPath + "/infoFGTS/vrBcFGTSProcTrab", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/vrBcFGTSSefip" )
									oModel:LoadValue( "MODEL_V7I", "V7I_BCSEFI", FTafGetVal( cV7IPath + "/infoFGTS/vrBcFGTSSefip", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV7IPath + "/infoFGTS/vrBcFGTSDecAnt" )
									oModel:LoadValue( "MODEL_V7I", "V7I_BCDECA", FTafGetVal( cV7IPath + "/infoFGTS/vrBcFGTSDecAnt", "N", .F., @aIncons, .F. ) )
								EndIf

							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/baseMudCateg/codCateg" )
								oModel:LoadValue( "MODEL_V7I", "V7I_CATMUD", FGetIdInt( "codCateg", "", cV7IPath + "/baseMudCateg/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:XPathHasNode(	cV7IPath + "/baseMudCateg/vrBcCPrev" )
								oModel:LoadValue( "MODEL_V7I", "V7I_VRPREV", FTafGetVal( cV7IPath + "/baseMudCateg/vrBcCPrev", "N", .F., @aIncons, .F. ) )
							EndIf

							If  lSimpl0103 .And. TafColumnPos("T8F_DIATRA")
								nT8F := 1						
								cT8FPath := cV9WPath + "/ideEstab/infoVlr/idePeriodo/infoInterm[" + AllTrim(Str(nT8F)) + "]""

								If nOpc == 4 
									For n3 := 1 to oModel:GetModel( "MODEL_T8F" ):Length()
										oModel:GetModel( "MODEL_T8F" ):GoLine(n3)
										oModel:GetModel( "MODEL_T8F" ):DeleteLine()
									Next n3
								EndIf

								While oDados:XPathHasNode(cT8FPath)

									oModel:GetModel( "MODEL_T8F" ):lValid := .T.

									If nOpc == 4 .Or. nT8F > 1
										oModel:GetModel( "MODEL_T8F" ):AddLine()
									EndIf

									If oDados:XPathHasNode(	cT8FPath + "/dia" )
										oModel:LoadValue( "MODEL_T8F", "T8F_DIATRA", FTafGetVal( cT8FPath + "/dia"	, "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(	cT8FPath + "/hrsTrab" )
										oModel:LoadValue( "MODEL_T8F", "T8F_HRSTRA", FTafGetVal( cT8FPath + "/hrsTrab"	, "C", .F., @aIncons, .F. ) )
									EndIf

									nT8F++
									cT8FPath := cV9WPath + "/ideEstab/infoVlr/idePeriodo/infoInterm[" + AllTrim(Str(nT8F)) + "]""
								EndDo
							EndIf	

							nV7I++
							cV7IPath := cV9WPath + "/ideEstab/infoVlr/idePeriodo[" + AllTrim(Str(nV7I)) + "]""
						EndDo

					EndIf

					nV9W++
					cV9WPath := cCabec + "/ideTrab/infoContr[" + Alltrim(Str(nV9W)) + "]"
				EndDo

			EndIf

			If Empty(cInconMsg) .And. Empty(aIncons)
				aChkDupl := TafFormCommit( oModel, .T. )

				If aChkDupl[1]
					Aadd(aIncons, "ERRO19" + "|" + aChkDupl[2] + "|" + aChkDupl[3])
				Else
					lRet := .T.
				EndIf				
							
			Else
				Aadd(aIncons, cInconMsg)
				DisarmTransaction()
			EndIf

			oModel:DeActivate()

			TafClearModel(oModel)
						
		EndIf		

	End Transaction

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF608Rul
Regras para gravacao das informacoes do registro S-2500 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes


@author José Riquelmo/Silas Gomes
@since 25/10/2022
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF608Rul( cInconMsg as character, nSeqErrGrv as numeric, cCodEvent as character, cOwner as character )

	Local aRull     as array
	Local cCabec    as character
	Local cCpf      as character
	Local cMatric   as character
	Local cIdTrabal as character

	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	aRull              := {}
	cCabec             := "/eSocial/evtProcTrab"
	cCpf               := ""
	cMatric            := ""
	cIdTrabal          := ""
	
	cCpf      := FTafGetVal(  cCabec + "/ideTrab/cpfTrab", "C", .F. )
	cMatric   := FTafGetVal(  cCabec + "/ideTrab/infoContr/matricula", "C", .F. )

	C9V->( DbSetOrder(12) )
	If C9V->( MsSeek( xFilial("C9V") + cCpf + Padr(cMatric, TamSx3("C9V_MATRIC")[1]) + '1' ))
		cIdTrabal := C9V->C9V_ID
		Aadd( aRull, { "V9U_TRABAL", cIdTrabal } )
		Aadd( aRull, { "V9U_ORIEVE", "S2200" } )
	Else
		C9V->( DbSetOrder(20) )
		If C9V->( MsSeek( xFilial("C9V") + cCpf + Padr(cMatric, TamSx3("C9V_MATTSV")[1]) + "S2300" + '1' ))
			cIdTrabal := C9V->C9V_ID
			Aadd( aRull, { "V9U_TRABAL", cIdTrabal } )
			Aadd( aRull, { "V9U_ORIEVE", "S2300" } )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideEmpregador/ideResp/tpInsc"))
		Aadd( aRull, { "V9U_TPINSC", FTafGetVal( cCabec + "/ideEmpregador/ideResp/tpInsc", "C", .F. )} ) 	
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideEmpregador/ideResp/nrInsc"))
		Aadd( aRull, { "V9U_NRINSC", FTafGetVal( cCabec + "/ideEmpregador/ideResp/nrInsc", "C", .F. )} ) 	
	EndIf

	If lSimpl0103 .And. TafColumnPos("V9U_DTADMR")

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideEmpregador/ideResp/dtAdmRespDir"))
			Aadd( aRull, { "V9U_DTADMR", FTafGetVal( cCabec + "/ideEmpregador/ideResp/dtAdmRespDir", "D", .F. )} ) 	
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideEmpregador/ideResp/matRespDir"))
			Aadd( aRull, { "V9U_MATRDI", FTafGetVal( cCabec + "/ideEmpregador/ideResp/matRespDir", "C", .F. )} ) 	
		EndIf

	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoProcesso/origem"))
		Aadd( aRull, {"V9U_ORIGEM", FTafGetVal( cCabec + "/infoProcesso/origem", "C", .F. )} ) 
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoProcesso/nrProcTrab"))
		Aadd( aRull, {"V9U_NRPROC", FTafGetVal( cCabec + "/infoProcesso/nrProcTrab", "C", .F. )} ) 
	EndIf		

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/obsProcTrab"))
		Aadd( aRull, {"V9U_OBSERV", FTafGetVal( cCabec + "/infoProcesso/obsProcTrab", "C", .F. )} )		
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoProcJud/dtSent"))
		Aadd( aRull, {"V9U_DTSENT", FTafGetVal( cCabec + "/infoProcesso/dadosCompl/infoProcJud/dtSent", "D", .F. )})		
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoProcJud/ufVara"))
		Aadd( aRull, {"V9U_UFVARA", FGetIdInt( "ufVara","", cCabec + "/infoProcesso/dadosCompl/infoProcJud/ufVara",,,,@cInconMsg, @nSeqErrGrv )})		
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoProcJud/codMunic"))
		Aadd( aRull, {"V9U_CODMUN", FGetIdInt( "codMunic", "ufVara", cCabec + "/infoProcesso/dadosCompl/infoProcJud/ufVara", cCabec + "/infoProcesso/dadosCompl/infoProcJud/codMunic",,,@cInconMsg, @nSeqErrGrv )})
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoProcJud/idVara"))
		Aadd( aRull, {"V9U_IDVARA", FTafGetVal(cCabec + "/infoProcesso/dadosCompl/infoProcJud/idVara", "C", .F. )} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoCCP/dtCCP"))
		Aadd( aRull, {"V9U_DTCCP", FTafGetVal(cCabec + "/infoProcesso/dadosCompl/infoCCP/dtCCP", "D", .F. )} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoCCP/tpCCP"))
		Aadd( aRull, {"V9U_TPCCP", FTafGetVal(cCabec + "/infoProcesso/dadosCompl/infoCCP/tpCCP", "C", .F. )} )
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/infoProcesso/dadosCompl/infoCCP/cnpjCCP"))
		Aadd( aRull, {"V9U_CNPJCP", FTafGetVal(cCabec + "/infoProcesso/dadosCompl/infoCCP/cnpjCCP", "C", .F. )} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideTrab/cpfTrab"))
		Aadd( aRull, {"V9U_CPFTRA", FTafGetVal(cCabec + "/ideTrab/cpfTrab", "C", .F. )} )
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideTrab/nmTrab"))
		Aadd( aRull, {"V9U_NMTRAB", SubStr( FTafGetVal( cCabec + "/ideTrab/nmTrab", "C", .F. ), 1, 70 ) } )
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideTrab/dtNascto"))
		Aadd( aRull, {"V9U_DTNASC", FTafGetVal(cCabec + "/ideTrab/dtNascto", "D", .F. )} )
	EndIf

	If lSimpl0103 .And. TafColumnPos("V9U_IDESEQ")

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideTrab/ideSeqTrab"))
			Aadd( aRull, {"V9U_IDESEQ", FTafGetVal(cCabec + "/ideTrab/ideSeqTrab", "C", .F. )} )
		EndIf

	EndIf

Return ( aRull )
