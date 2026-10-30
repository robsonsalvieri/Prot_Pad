#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887ARG 
Fonte de cobros diversos (Argentina)
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Function FINA887ARG()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Menudef del modelo localizado de Argentina de la FINA887.
@return		aRotina arreglo del menú
@author 	raul.medina
@since 		25/01/2023
@version	12.1.33 / Superior
/*/
Static Function MenuDef()
Local aRotina := FWLoadMenuDef(SOURCEFATHER)
	
Return aRotina

/*/{Protheus.doc} ModelDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local oStruCH		:= FWFormModelStruct():New()
Local oStruSFE 		:= FWFormStruct( 1, 'SFE' )
Local oStruSEL		:= oModelSEL:oFormModelStruct
Local oEvtTit		:= F887FINARG():New()
Local oEvtChq		:= F887CHQ():New()
Local oEvtChqArg	:= F887CHQARG():New()
Local oEvtRetArg	:= F887RETARG():New()
Local oEvtDifCam	:= F887DIFCAM():New()
Local aFieldsSEL	:= oModel:GetModel('SEL_DETAIL'):oFormModelStruct:GetFields()
Local nval 			:= 0
local lFpadvpl 		:= SuperGetMv("MV_FPADVPL",.F.,.F.)
Local lRecMvc		:= SuperGetMv("MV_RECMVC",.F.,.F.)

	If !lFpadvpl .and. (Getsx3Cache( 'EL_VALBASE','X3_TITULO' )) == NIL .AND. (Getsx3Cache( 'EL_ALIQ','X3_TITULO' )) == NIL
		oStruSEL:AddField(GetSx3Cache("FE_VALBASE","X3_TITULO"), 	GetSx3Cache(  "FE_VALBASE","X3_DESCRIC"), 	"EL_VALBASE",	GetSx3Cache("FE_VALBASE","X3_TIPO"), GetSx3Cache("FE_VALBASE","X3_TAMANHO")	,	GetSx3Cache("FE_VALBASE","X3_DECIMAL"))
		oStruSEL:AddField(GetSx3Cache("FE_ALIQ","X3_TITULO"), 		GetSx3Cache("FE_ALIQ","X3_DESCRIC"), 		"EL_ALIQ",		GetSx3Cache("FE_ALIQ","X3_TIPO"), 	GetSx3Cache("FE_ALIQ","X3_TAMANHO")		,	GetSx3Cache("FE_ALIQ","X3_DECIMAL"))
	EndIf
	//Asignación de when
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")
	oStruSEL:SetProperty( 'EL_VALBASE'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNRET() } ) 
	oStruSEL:SetProperty( 'EL_ALIQ'		, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNRET() } ) 
	oStruSEL:SetProperty( 'EL_PROVIN'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNPRO() } )
	oStruSEL:SetProperty( 'EL_CFO'		, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNCFO() } )
	oStruSEL:SetProperty( 'EL_SIRECER'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNCER() } )
	oStruSEL:SetProperty( 'EL_SIRESEG'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNSEG() } )
	oStruSEL:SetProperty( 'EL_RET_MUN'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNMUN() } )

	IF aScanx(aFieldsSEL,{|x|x[3] == ALLTRIM("EL_CONCSUS")}) > 0 
		oStruSEL:SetProperty( 'EL_CONCSUS'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNSUS() } )
	ENDIF
	IF aScanx(aFieldsSEL,{|x|x[3] == ALLTRIM("EL_AGREGAN")}) > 0 
		oStruSEL:SetProperty( 'EL_AGREGAN'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNAGR() } )
	ENDIF

	//Validaciones
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887VALTP(oModelGrid,.T.) } )
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887TPDOC(oModelGrid) } )  
	oStruSEL:SetProperty( 'EL_BCOCHQ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887BCO("EL_BCOCHQ", .T.) } )
	If lFpadvpl .or. lRecMvc
		oStruSEL:SetProperty( 'EL_VALBASE'  , MODEL_FIELD_VALID , {|oModelGrid| GetValReTR(oModelGrid) } )
		oStruSEL:SetProperty( 'EL_ALIQ'   	, MODEL_FIELD_VALID , {|oModelGrid| GetValReTR(oModelGrid) } )
		oStruSEL:SetProperty( 'EL_VALOR'   	, MODEL_FIELD_VALID , {|oModelGrid| GetValReTR(oModelGrid) } )
		
		oStruSEL:SetProperty( 'EL_PREFIXO'	, MODEL_FIELD_WHEN ,	{|oModelGrid| F887PREFIX()  } ) //A840WHEN
	EndIF
	nval := AScan(oStruSEL:atriggers,{|x|Alltrim(x[1])=="EL_BCOCHQS" .and. Alltrim(x[2])=="EL_CTACHQ"})
	If nval > 0
		oStruSEL:atriggers[nval][2] := "EL_POSTAL"
	EndIf

	//Tabla para la edición de Cheques
	oStruCH:AddTable('', { '' }, "CHEQUES",{|| ''})
	oStruCH:AddField('CH_NUMERO'	,'CH_NUMERO'	,'CH_NUMERO'	, GetSx3Cache('EL_NUMERO'	,"X3_TIPO"),GetSx3Cache('EL_NUMERO'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_BCOCHQ'	,'CH_BCOCHQ'	,'CH_BCOCHQ'	, GetSx3Cache('EL_BCOCHQ'	,"X3_TIPO"),GetSx3Cache('EL_BCOCHQ'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_AGECHQ'	,'CH_AGECHQ'	,'CH_AGECHQ'	, GetSx3Cache('EL_AGECHQ'	,"X3_TIPO"),GetSx3Cache('EL_AGECHQ'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_CTACHQ'	,'CH_CTACHQ'	,'CH_CTACHQ'	, GetSx3Cache('EL_CTACHQ'	,"X3_TIPO"),GetSx3Cache('EL_CTACHQ'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_POSTAL'	,'CH_POSTAL'	,'CH_POSTAL'	, GetSx3Cache('EL_POSTAL'	,"X3_TIPO"),GetSx3Cache('EL_POSTAL'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_TERCEIR'	,'CH_TERCEIR'	,'CH_TERCEIR'	, GetSx3Cache('EL_TERCEIR'	,"X3_TIPO"),GetSx3Cache('EL_TERCEIR',"X3_TAMANHO")	)
	oStruCH:AddField('CH_ENDOSSA'	,'CH_ENDOSSA'	,'CH_ENDOSSA'	, GetSx3Cache('EL_ENDOSSA'	,"X3_TIPO"),GetSx3Cache('EL_ENDOSSA',"X3_TAMANHO")	)
	oStruCH:AddField('CH_CGC'		,'CH_CGC'		,'CH_CGC'		, GetSx3Cache('EL_CGC'		,"X3_TIPO"),GetSx3Cache('EL_CGC'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_EMISSAO'	,'CH_EMISSAO'	,'CH_EMISSAO'	, GetSx3Cache('EL_EMISSAO'	,"X3_TIPO"),GetSx3Cache('EL_EMISSAO',"X3_TAMANHO")	)
	oStruCH:AddField('CH_DTVCTO'	,'CH_DTVCTO'	,'CH_DTVCTO'	, GetSx3Cache('EL_DTVCTO'	,"X3_TIPO"),GetSx3Cache('EL_DTVCTO'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_SELDOC'	,'CH_SELDOC'	,'CH_SELDOC'	, GetSx3Cache('EL_SELDOC'	,"X3_TIPO"),GetSx3Cache('EL_SELDOC'	,"X3_TAMANHO")	)
	oStruCH:AddField('CH_NATURE'	,'CH_NATURE'	,'CH_NATURE'	, GetSx3Cache('FJT_NATURE'	,"X3_TIPO"),GetSx3Cache('FJT_NATURE',"X3_TAMANHO")	)

	oModel:addGrid('CH_DETAIL','FJT_MASTER'	,oStruCH	,	,	)
	oModel:AddGrid( 'SFEGRID', 'FJT_MASTER' , oStruSFE, , , ,  ,  )

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel( 'SFEGRID' ):SetOptional(.T.)
	oModel:GetModel( 'CH_DETAIL'):SetOptional(.T.)

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SFEGRID'):SetOnlyQuery(.T.)
	oModel:GetModel('CH_DETAIL'):SetOnlyQuery(.T.)

	oModel:InstallEvent("F887FINARG", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887CHQ"	,/*cOwner*/,oEvtChq)
	oModel:InstallEvent("F887CHQARG", "F887CHQ",oEvtChqArg)
	oModel:InstallEvent("F887RETARG",/*cOwner*/,oEvtRetArg)
	oModel:InstallEvent("F887DIFCAM",/*cOwner*/,oEvtDifCam)
	
Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización Argentina
@return		oView objeto del View
@author 	raul.medina
@since 		25/01/2023
@version	12.1.33 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)
Local oModel

	oModel := oView:GetModel()

	If oView:GetViewStruct("VIEW_SE1"):HasField("E1_DESCONT")
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_DESCONT'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) $ "NF|NDC"') )
	EndIf
	If oView:GetViewStruct("VIEW_SE1"):HasField("E1_JUROS")
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_JUROS'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) $ "NF|NDC"') )
	EndIf
	If oView:GetViewStruct("VIEW_SE1"):HasField("E1_MULTA")
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_MULTA'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) $ "NF|NDC"') )
	EndIf

	oView:AddUserButton(STR0216, "CARGA", {|oView| F887RetVw(oView)}, , K_CTRL_Q, {MODEL_OPERATION_INSERT}) //Retenciones [Ctrl + Q].
	oView:AddUserButton(STR0263, "CARGA",	{ || Set998NCC() },,K_CTRL_N,{MODEL_OPERATION_INSERT}) // STR0263 -N 'Doc. Fiscal NCC'
	
	IF SuperGetMv("MV_CMC7FIN") == "S"
		oView:SetFieldAction( "EL_TIPO",{ |oModel, cIDView, cField, xValue| LectorChe(oModel:GetModel(), cIDView, cField, xValue)})
	ENDIF
	
Return oView


/*/{Protheus.doc} LectorChe
Metodo que es llamado por el modelo cuando se edite el campo EL_TIPO de esta manera podra ejecutarse la lectora de cheques y setear los valores
@type function
@version 1
@author luis.aboytes
@since 9/7/2025
/*/
Static Function LectorChe(oModel, cIDView, cField, xValue)
Local oModelSEL 	:= oModel:GetModel("SEL_DETAIL")
Local nOperation 	:= oModel:GetOperation()
Local aCheque		:= {} As Array
Local oView			:= FwViewActive()

	IF nOperation == MODEL_OPERATION_INSERT 
		IF cIDView == "VIEW_SEL" .AND. cField == 'EL_TIPO' .AND. xValue == 'CH '
			aCheque := FinCmc7Tc()
			If Len(aCheque) > 0
				FINEntBc(aCheque[1],aCheque[2],aCheque[3])
				oModelSEL:LoadValue("EL_BCOCHQ",aCheque[1]) 
				oModelSEL:LoadValue("EL_AGECHQ",aCheque[2]) 
				oModelSEL:LoadValue("EL_POSTAL",aCheque[3]) 
				oModelSEL:LoadValue("EL_NUMERO",aCheque[4]) 
				oModelSEL:LoadValue("EL_CTACHQ",aCheque[5])
				oView:Refresh()
			Endif
		ENDIF
	ENDIF

Return

/*/{Protheus.doc} F887WHNRET
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_VALBASE y EL_ALIQ
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
STATIC Function F887WHNRET()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RB|RG|RI|RM|RS'
		lRet := .T.
	ELSE
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNPRO
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_PROVIN
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNPRO()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RB|RM|RI|RG|RS'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNCFO
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_CFO
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNCFO()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RB|RM|RI|RS|RG'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNAGR
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_AGREGAN
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNAGR()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local oStruSEL	:= oModelSEL:oFormModelStruct
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RG'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNMUN
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_RET_MUN
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNMUN()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RM'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNCER
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_SIRECER
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNCER()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RS|RI'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNSEG
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_SIRESEG
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNSEG()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RS|RI'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNSUS
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_CONCSUS
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Function F887WHNSUS()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		As Logical

	IF cTipoDoc $ 'RS'
		lRet := .T.
	ELSE 
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} blocAStr
Retorna parte del bloque de codigo
@type method
@version  1
@author raul.medina
@since 2/2/2023
@param bBloc, codeblock, bloque de codigo
/*/
Static Function blocAStr(bBloc As codeblock)
	Local cBloc     := ""   As Character
	Local cValid    := ""   As Character
	Local nInicio   := 0    As numeric
	Local nFin      := 0    As numeric
	Default bBloc 	:= {||}

    If ValType(bBloc) == "B"
        cBloc := GetCbSource(bBloc)
    EndIf

    If !Empty(cBloc)
        nInicio := At(":=(", cBloc) + 2
        nFin    := RAt("),FWCloseCpo", cBloc)
        If nInicio > 0 .and. nFin > 0
            cValid  := Substr(cBloc, nInicio + 1, (nFin - 1) - (nInicio))
        EndIf
        cValid := AllTrim(cValid)
    EndIf
Return cValid

/*/{Protheus.doc} FA887TPDOC
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	Jose.gonzalez
@version	12.1.2210 / Superior
@since 		29/02/2024
/*/
Function FA887TPDOC(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local aFieldsSEL:= oModelSEL:oFormModelStruct:GetFields()
	

	IF !(cTipoDoc $ 'RB|RG|RI|RM|RS')
		oModelSEL:LoadValue('EL_VALBASE'	,0)
		oModelSEL:LoadValue('EL_ALIQ'		,0)	
		oModelSEL:LoadValue('EL_CFO',"")
		oModelSEL:LoadValue('EL_PROVIN',"")
	ENDIF
	IF !(cTipoDoc $ 'RG') .And. aScanx(aFieldsSEL,{|x|x[3] == ALLTRIM("EL_AGREGAN")}) > 0 
		oModelSEL:LoadValue('EL_AGREGAN',"")
	EndIf
	IF !(cTipoDoc $ 'RS')
		If aScanx(aFieldsSEL,{|x|x[3] == ALLTRIM("EL_CONCSUS")}) > 0 
			oModelSEL:LoadValue('EL_CONCSUS',"")
		EndIf
		oModelSEL:LoadValue('EL_SIRESEG',"")
		oModelSEL:LoadValue('EL_SIRECER',"")
	ENDIF
	IF !(cTipoDoc $ 'RM')
		oModelSEL:LoadValue('EL_RET_MUN',"")
	ENDIF
	
Return lRet

/*/{Protheus.doc} F887PREFIX
Función para bloqueo del campo prefijo
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	Jose.gonzalez
@version	12.1.2210 / Superior
@since 		29/02/2024
/*/
Function F887PREFIX
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local aArea := {}
local cConteudo :=""

If AliasInDic("FJS")
	cConteudo	:= oModelSEL:GetValue("EL_TIPO")
	aArea := FJS->(GetArea())
	DbSelectArea("FJS")
	FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
		If FJS->(DbSeek(xFilial("FJS")+PadR(cConteudo,GetSx3Cache("FJS_TIPO","X3_TAMANHO"))))  
			If FJS->FJS_TIPOIN == "DC" //Pagaré
				lRet := .F.
			EndIf
		EndIf
	FJS->(RestArea(aArea))
EndIF

Return lRet

/*/{Protheus.doc} F887RetVw
Función utilizada para mostrar una ventana para captura de retenciones.
@author 	raul.medina
@since 		12/2024
@version	12.1.2210 / Superior
Parametros
    oViewPai - - vista activa para ser procesada
@Return 
/*/
Function F887RetVw(oViewPai)
Local cCampSEL		:= {"EL_TIPO", "EL_TIPODOC", "EL_PREFIXO", "EL_NUMERO", "EL_VALBASE", "EL_ALIQ", "EL_VALOR","EL_MOEDA", "EL_EMISSAO", "EL_RET_MUN", "EL_SIRECER", "EL_SIRESEG", "EL_CFO", "EL_PROVIN", "EL_AGREGAN", "EL_CONCSUS"}
Local oView			:= Nil
Local oModel		:= Nil
Local oStruRet		:= Nil
Local oExecView		:= FWViewExec():New()
Local jsonSEL
Local bIniTipo
Local bIniTpDoc

Default oViewPai	:= FwViewActive()

	oModel := oViewPai:GetModel()

	bIniTpDoc := oModel:GetModel("SEL_DETAIL"):GetStruct():GetProperty("EL_TIPODOC"	, MODEL_FIELD_INIT)
	bIniTipo := oModel:GetModel("SEL_DETAIL"):GetStruct():GetProperty("EL_TIPO"		, MODEL_FIELD_INIT)

	oModel:GetModel("SEL_DETAIL"):GetStruct():SetProperty("EL_TIPODOC"	, MODEL_FIELD_INIT	,	{|| "" })
	oModel:GetModel("SEL_DETAIL"):GetStruct():SetProperty("EL_TIPO"		, MODEL_FIELD_INIT	,	{|| "" })
	
	jsonSEL	:= JsonCpos(cCampSEL)
	oStruRet := FWFormStruct( 2, 'SEL', { |cCampo| jsonSEL:HasProperty(AllTrim(cCampo)) })

	oStruRet:SetProperty("EL_TIPODOC", MVC_VIEW_COMBOBOX, {STR0217, STR0218, STR0219, STR0220, STR0221} ) //"RI=Retención IVA", "RG=Retención Ganancias", "RB=Retención Ing.Brutos", "RS=SUSS", "RM=Retención Municipal"

	oStruRet:SetProperty("EL_TIPO", MVC_VIEW_COMBOBOX, {STR0217, STR0218, STR0219, STR0220, STR0221} ) //"RI=Retención IVA", "RG=Retención Ganancias", "RB=Retención Ing.Brutos", "RS=SUSS", "RM=Retención Municipal"

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddGrid('RET_SEL', oStruRet, 'SEL_DETAIL')
	oView:CreateHorizontalBox( 'BOXFORM_SEL', 100)
	oView:SetOwnerView('RET_SEL','BOXFORM_SEL')

	oView:EnableTitleView('RET_SEL' , STR0222 ) //"Retenciones"

	oView:SetAfterViewActivate({|oView| F887RetFil(oView)})

	//Filtros de busqueda para el grid de formas de pago.
	oView:SetViewProperty("RET_SEL","ENABLENEWGRID")
    oView:SetViewProperty("RET_SEL","GRIDFILTER",{.T.})
    oView:SetViewProperty("RET_SEL","GRIDSEEK",{.T.})

	//Retenciones con la View activa.
	If oModel != Nil .And. oModel:isActive()
		oExecView:setView(oView)
		oExecView:setTitle(STR0222) //"Retenciones"
		oExecView:setOperation(oViewPai:GetOperation())
		oExecView:setReduction(50)
		oExecView:SetCloseOnOk({|| .t.})
		oExecView:openView(.F.)
		If oView:IsActive()
			oView:DeActivate()
		EndIf

		F887ActSal(oModel)
	EndIf

	oModel:GetModel("SEL_DETAIL"):GetStruct():SetProperty("EL_TIPODOC"	, MODEL_FIELD_INIT	,	bIniTpDoc)
	oModel:GetModel("SEL_DETAIL"):GetStruct():SetProperty("EL_TIPO"		, MODEL_FIELD_INIT	,	bIniTipo)

Return

/*/{Protheus.doc} F887RetFil
Función utilizada para realizar la carga de retenciones
@author 	raul.medina
@since 		12/2024
@version	12.1.2210 / Superior
Parametros
    oView - - vista activa para ser procesada
@Return 
/*/
Static Function F887RetFil(oView)
Local oViewSEL 	:= Nil
Local cFilter	:= ""
Local cId		:= "Ret"
Local cRet		:= "RI|RB|RS|RG|RM|TB"
Local aFilter 	:= {}

Default oView	:= FwViewActive()

	oViewSEL	:= oView:GetViewObj('RET_SEL')[3]
	cFilter		:= "EL_TIPODOC $ '" + cRet + "'"
	aFilter 	:= { 	{"EL_TIPODOC", "FIELD", "Retención", cFilter, cFilter},;
						{"$","OPERATOR","","",""},;
						{"001","EXPRESSION","","","",.T.} }

	oViewSEL:oBrowse:CleanFilter()
	oViewSEL:oBrowse:CleanExFilter()
	oViewSEL:oBrowse:DeleteFilter(cId) 
	oViewSEL:oBrowse:AddFilter(	"Ret", cFilter ,.T.,.T., , , aFilter, cId )
	oViewSEL:oBrowse:ExecuteFilter(.t.)

	oView:Refresh()

Return

/*/{Protheus.doc} JsonCpos
Función utilizada para crear objetos json son la información recibida en un array.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    aStrings - array - array con la información con la cual será creado el objeto json.
@Return 
	oJson - json - objeto json creado apartir de la información de aStrings.
/*/
Static Function JsonCpos(aStrings)
Local nX		:= 0
Local oJson

Default aStrings    := {}

    oJson := JsonObject():new()

    For nX := 1 To Len(aStrings)
        oJson[aStrings[nX]] := aStrings[nX]
    Next

Return oJson

/*/{Protheus.doc} Set998NCC
Funcion que ejecuta el grupo de preguntas FIN998NCC o en su caso le avisa a cliente que necesita ser configurado
@type function
@version  1
@author luis.aboytes
@since 28/7/2025
/*/
Static Function Set998NCC()
Local lFIN998NCC 	:= FWSX1Util():ExistPergunte("FIN998NCC")

	IF lFIN998NCC
		Pergunte("FIN998NCC",.T.)
	ELSE
		Help(NIL, NIL, STR0017, NIL, STR0261, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0262}) // STR0261 - "El grupo de preguntas FIN998NCC no existe. Este grupo es necesario para configurar correctamente el punto de venta y el producto cuando se selecciona NCC en la pregunta ¿Documento a generar por DIF?, ya que interviene en la generación del documento fiscal correspondiente." STR0262 - "Por favor configure el grupo de preguntas FIN998NCC para acceder a esta opción."
	EndIF
Return Nil
