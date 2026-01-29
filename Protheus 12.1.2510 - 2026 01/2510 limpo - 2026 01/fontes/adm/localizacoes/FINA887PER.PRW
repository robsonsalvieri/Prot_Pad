#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887PER
Fonte de cobros diversos (Perú)
@author 	raul.medina
@since 		19/05/2021
@version	12.1.27 / Superior
/*/
Function FINA887PER()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		19/05/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local oStruSEL		:= oModelSEL:oFormModelStruct
Local oEvtTit		:= F887FINPER():New()
Local oEvtRetPer	:= F887RETPER():New()
Local lMvRecMvc		:= SuperGetMv("MV_RECMVC",.F.,.F.)
	
	//Validaciones
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'pertence(MVCHEQUE+"|EF|TF|RI|TB|CC") .and. F887VTpDoc()') ) //FA840VALTP
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //?

	//Cambio temporal, seran eliminados los disparadores cuando se deshabilite el nuevo recibo en PO UI 
	IF !lMvRecMvc
	//Creacion de triggers
	aAux := CreateTrigger('EL_DOCTO','EL_SDOCTO', 'docsReten(FwFldGet("EL_DOCTO"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_DOCTO','EL_DOCTO', 'docsReten(FwFldGet("EL_DOCTO"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	aAux := CreateTrigger('EL_DOCTO','EL_PARDOC', 'docsReten(FwFldGet("EL_DOCTO"),"3")',"003")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	ENDIF

	//Whens
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } )
	//Cambio temporal, seran eliminados los disparadores cuando se deshabilite el nuevo recibo en PO UI
	IF !lMvRecMvc
		oStruSEL:SetProperty( 'EL_SDOCTO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNDOC() } ) 
		oStruSEL:SetProperty( 'EL_DOCTO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNDOC() } ) 
		oStruSEL:SetProperty( 'EL_PARDOC'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNDOC() } ) 
		oStruSEL:SetProperty( 'EL_DOCTO'	, 	MODEL_FIELD_VALID  , {|oModelGrid| .T. } ) 
	ELSE
		oStruSEL:SetProperty( 'EL_DOCTO'	, 	MODEL_FIELD_VALID  , {|oModelGrid| F887DOCVLD() } ) 
	END
	oStruSEL:SetProperty( 'EL_SERRET'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNSER() } ) 

	//Modificamos estructura
	oStruSEL:SetProperty( 'EL_DOCTO'	,	MODEL_FIELD_TAMANHO , oStruSEL:GetProperty("EL_SDOCTO",MODEL_FIELD_TAMANHO)+oStruSEL:GetProperty("EL_DOCTO",MODEL_FIELD_TAMANHO)+oStruSEL:GetProperty("EL_PARDOC",MODEL_FIELD_TAMANHO)+2) //Se adiciona un +2 al tamaño del campo EL_DOCTO para considerar los guiones que manda el front al servicio
	
	//Modificamos estrcutura de campos ya existentes en diccionario
	oModel:InstallEvent("F887FINPER", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887RETPER",/*cOwner*/,oEvtRetPer)

Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización Perú
@return		oView objeto del View
@author 	raul.medina
@since 		12/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)
	
	oView:GetViewObj("VIEW_SEL")[3]:oStructView:RemoveField( "EL_TIPO" )
	
	oView:SetViewProperty("VIEW_SEL","GRIDDOUBLECLICK",{{|oModel,cFieldName,nLineGrid,nLineModel| F887PERDOC(oModel,cFieldName,nLineGrid,nLineModel)}}) //Click en cualquier campo de la vista de formas de pago

Return oView

/*/{Protheus.doc} F887PERDOC
Funcion que se ejecuta al dar doble click o un enter a un campo de las formas de pago
@type function
@version  1
@author luis.aboytes
@since 2/6/2025
/*/
Function F887PERDOC(oModel,cFieldName,nLineGrid,nLineModel)
Local lRet	  	:= .T. As Logical
Local lOk		:= .T.	 
Local cSelect  	:= ""  As Character 
Local aOptions 	:=  {} As Array
Local aAux		:=  {} As Array 	
Local aSepara	:= 	{} As Array 
Local nCont	   	:= 0 As Numeric
Local nX,Ny		:= 0 As Numeric
Local cNumero	:= "" As Character
Local cPrefix	:= "" As Character
Local cParcela	:= "" As Character
Local cLabel	:= "" As Character
Local cTemp		:= "" As Character
Local oMdlAct  	:= FWModelActive()

Default oModel 		:= Nil
Default cFieldName 	:= ""
Default nLineGrid 	:= 0
Default nLineModel 	:= 0

	IF !oModel:GetModel('SEL_DETAIL'):IsEmpty() .AND. oModel:GetModel('SEL_DETAIL'):GetOperation()== MODEL_OPERATION_INSERT .AND. cFieldName == "EL_DOCTO" .AND. oModel:GetModel('SEL_DETAIL'):GetValue('EL_TIPODOC',nLineGrid) == 'RI'  //Si se da doble click en el campo EL_DOCTO y el EL_TIPODOC es de tipo RI 
		FOR nCont:=1 to oMdlAct:GetModel('SE1_DETAIL'):length()
			lOk := .T.
			IF oMdlAct:GetModel('SE1_DETAIL'):GetValue('CHECK',nCont)
				cNumero  := oMdlAct:GetModel('SE1_DETAIL'):GetValue('E1_NUM',nCont)
				cParcela := oMdlAct:GetModel('SE1_DETAIL'):GetValue('E1_PARCELA',nCont)
				cPrefix  := oMdlAct:GetModel('SE1_DETAIL'):GetValue('E1_PREFIXO',nCont)
				cLabel	 := cPrefix+"-"+cNumero+"-"+cParcela
				AADD(aAux,cLabel) //Se agregan a AAux todos los titulos seleccionados por clientes del grid de titulos
			ENDIF
		Next nCont

		IF VAZIO(aAux)
			Return lRet
		ELSE
			FOR nX := 1 TO LEN(aAux)
				cLabel 	:= aAux[nX]
				lOk 	:= .T.
				FOR nY := 1 TO oModel:GetModel('SEL_DETAIL'):length()
					cTemp := oModel:GetModel('SEL_DETAIL'):GetValue('EL_SDOCTO',nY)+"-"+oModel:GetModel('SEL_DETAIL'):GetValue('EL_DOCTO',nY)+"-"+oModel:GetModel('SEL_DETAIL'):GetValue('EL_PARCELA',nY)
					IF ALLTRIM(REPLACE(cLabel," ","")) == ALLTRIM(REPLACE(cTemp," ","")) 
						lOk:=.F. //Si el titulo ya fue utilizado en una forma de pago de tipo RI anteriormente esta no sera agregada al array aOptions
					ENDIF
				NEXT nY
				IIf(lOk,AADD(aOptions,cLabel),)
			NEXT nX
			f_Opcoes(@cSelect,STR0232,aOptions,/*cOpcoes*/,/*nLin1*/,/*nCol1*/,.T.,1,1,.F.,/*lComboBox*/,/*cCampo*/,/*lNotOrdena*/,/*lNotPesq*/,/*lForceRetArr*/,/*cF3*/) //Funcion que ejecuta una ventana estandar para que el cliente pueda seleccionar una opcion de las enviadas por el array de aOptions.  STR0232- "Titulos Seleccionados"
			IF !VAZIO(cSelect)
				aSepara := separa(cSelect,"-")
				oModel:GetModel('SEL_DETAIL'):LoadValue('EL_SDOCTO',aSepara[1])
				oModel:GetModel('SEL_DETAIL'):LoadValue('EL_DOCTO',aSepara[2])
				oModel:GetModel('SEL_DETAIL'):LoadValue('EL_PARDOC',aSepara[3])
				oModel:Refresh() //Seteamos los valores en sus respectivos campos y refrescamos la pantalla.
			ENDIF
		EndIf
	ENDIF

Return lRet

/*/{Protheus.doc} F887VTpDoc
Validaciones correspondientes a las retenciones de IGV para Perú

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/05/2021 
/*/
Function F887VTpDoc()
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local cSerRet	:= oModelSEL:GetValue("EL_SERRET")
Local nTamSerR	:= GetSx3Cache("EL_SERRET","X3_TAMANHO")

	If cTipoDoc $ "RI" 
		If Empty(cSerRet)
			oModelSEL:SetValue("EL_SERRET",SuperGetMV("MV_CRSERIE", , Space( nTamSerR ) ))
		Endif
	Endif

Return lRet

/*/{Protheus.doc} F887WHNSER
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_SERRET
@type function
@version  1
@author luis.aboytes
@since 16/2/2023
/*/
Function F887WHNSER()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		:= .F.

	IF cTipoDoc $ 'RI'
		lRet := .T.
	ELSE
		oModelSEL:LoadValue('EL_SERRET',"")
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNSER
Metodo que habilita los campos serie EL_SDOCTO y documento EL_DOCTO cuando es tipo retención 
@type function
@version  1	
@author luis.aboytes
@since 6/3/2023
/*/
Static Function F887WHNDOC()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		:= .F.

	IF cTipoDoc $ 'RI'
		lRet := .T.
	ELSE
		oModelSEL:LoadValue('EL_SDOCTO'	,"")
		oModelSEL:LoadValue('EL_DOCTO'	,"")
		oModelSEL:LoadValue('EL_PARDOC' ,"")
	ENDIF

Return lRet

/*/{Protheus.doc} F887DOCVLD
Funcion definida para validar si el campo EL_DOCTO tiene un valor, de no tenerlo limpiara los campos EL_SDOCTO y EL_PARDOC
@type function
@version  1
@author luis.aboytes
@since 2/6/2025
/*/
Static Function F887DOCVLD()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cDocto	:= oModelSEL:GetValue("EL_DOCTO")
	Local lRet		:= .T.

	IF VAZIO(cDocto) 
		oModelSEL:LoadValue('EL_SDOCTO'	,"")
		oModelSEL:LoadValue('EL_DOCTO'	,"")
		oModelSEL:LoadValue('EL_PARDOC' ,"")
	ENDIF

Return lRet
