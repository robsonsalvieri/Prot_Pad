#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887COL
Fonte de cobros diversos (Paraguay)
@author 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Function FINA887PAR()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oStruSFE 		:= FWFormStruct( 1, 'SFE' )
Local oEvtRetPAR	:= F887RETPAR():New()
Local oEvtTit		:= F887FINPAR():New()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local oStruSEL		:= oModelSEL:oFormModelStruct
Local oStruSE1 		:= oModel:GetModel( 'SE1_DETAIL' ):oFormModelStruct
Local aAux			:= ""

	oStruSFE:AddField(AllTrim(FwX3Titulo("E1_TIPO"))	, AllTrim(FwX3Titulo("E1_TIPO"))	, 'TIPODOC'	, GetSx3Cache("E1_TIPO","X3_TIPO")		, GetSx3Cache("E1_TIPO","X3_TAMANHO")		, GetSx3Cache("E1_TIPO","X3_DECIMAL"))
	oStruSFE:AddField(AllTrim(FwX3Titulo("EL_NUMERO"))	, AllTrim(FwX3Titulo("EL_NUMERO"))	, 'ELNUMERO', GetSx3Cache("EL_NUMERO","X3_TIPO")	, GetSx3Cache("EL_NUMERO","X3_TAMANHO")		, GetSx3Cache("EL_NUMERO","X3_DECIMAL"))
	oStruSFE:AddField(AllTrim(FwX3Titulo("EL_PREFIXO"))	, AllTrim(FwX3Titulo("EL_PREFIXO"))	, 'ELPREFIX', GetSx3Cache("EL_PREFIXO","X3_TIPO")	, GetSx3Cache("EL_PREFIXO","X3_TAMANHO")	, GetSx3Cache("EL_PREFIXO","X3_DECIMAL"))
	oStruSFE:SetProperty( '*', 	MODEL_FIELD_OBRIGAT, .F.)

	aAux := CreateTrigger('FE_VALBASE','FE_RETENC', 'F887CerVal("FE_VALBASE")',"001")
    oStruSFE:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

 	aAux := CreateTrigger('FE_ALIQ','FE_RETENC', 'F887CerVal("FE_ALIQ")',"001")
    oStruSFE:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	aAux := CreateTrigger('FE_RETENC','FE_ALIQ', 'F887CerVal("FE_RETENC")',"001")
    oStruSFE:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	
	oModel:AddGrid( 'SFEGRID', 'FJT_MASTER' , oStruSFE, , , ,  ,  )

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel( 'SFEGRID' ):SetOptional(.T.)

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SFEGRID'):SetOnlyQuery(.T.)

	oModel:InstallEvent("F887FINPAR", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887RETPAR",/*cOwner*/,oEvtRetPAR)

	//Creación de triggers
	aAux := CreateTrigger('EL_DOCTO','EL_SDOCTO', 'docsReten(FwFldGet("EL_DOCTO"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_DOCTO','EL_DOCTO', 'docsReten(FwFldGet("EL_DOCTO"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	//When
	oStruSEL:SetProperty( 'EL_VALIMP1'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNRET() } ) 
	oStruSEL:SetProperty( 'EL_ALQIMP1'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNRET() } ) 
	oStruSEL:SetProperty( 'EL_DOCTO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNDOC() } ) 
	oStruSEL:SetProperty( 'EL_SDOCTO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887WHNDOC() } ) 

	//Modificamos estrcutura de campos ya existentes en diccionario
	oStruSEL:SetProperty( 'EL_DOCTO'	,	MODEL_FIELD_TAMANHO , oStruSEL:GetProperty("EL_SDOCTO",MODEL_FIELD_TAMANHO)+oStruSEL:GetProperty("EL_DOCTO",MODEL_FIELD_TAMANHO)+oStruSE1:GetProperty("E1_PARCELA",MODEL_FIELD_TAMANHO)+2) //Se adiciona un +2 al tamaño del campo EL_DOCTO para considerar los guiones que manda el front al servicio
	oStruSEL:SetProperty( 'EL_DOCTO'	, 	MODEL_FIELD_VALID  , {|oModelGrid| .T. } ) 

Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización Paraguay
@return		oView objeto del View
@author 	raul.medina
@since 		10/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)
Local nPos		:= 0

	oView:AddUserButton(STR0204,"CARGA",{|oView| F887CerPar(oView)},,K_CTRL_Q,{MODEL_OPERATION_INSERT}) ////"Certificados [Ctrl + Q]"

	nPos := aScan( oView:aViewAction, {|x| x[1] == "DELETELINE"} )
	If nPos > 0
		oView:aViewAction[nPos][2] := { |oView| F887DelPAR(oView, .T., .F.) }
	Endif
	
	nPos := aScan( oView:aViewAction, {|x| x[1] == "UNDELETELINE"} )
	If nPos > 0
		oView:aViewAction[nPos][2] := { |oView| F887DelPAR(oView, .F., .T.) }
	Endif

	nPos := aScan( oView:aFieldAction, {|x| x[1] == "CHECK"} )
	If nPos > 0
		oView:aFieldAction[nPos][2] := { |oView| F887ChkPAR(oView:GetModel()) }
	Endif

	oView:GetViewObj("VIEW_SEL")[3]:oStructView:RemoveField( "EL_TIPO" )
	
Return oView


/*/{Protheus.doc} F887WHNRET
Metodo que retorna una variable boleana que indica si se habilita o no el campo EL_VALIMP1 y EL_ALIQ
@type function
@version  1
@author luis.aboytes
@since 11/2/2023
/*/
Static Function F887WHNRET()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		:= .F.

	IF AllTrim(cTipoDoc) $ 'RI|RR'
		lRet := .T.
	ELSE
		oModelSEL:LoadValue('EL_VALIMP1'	,0)
		oModelSEL:LoadValue('EL_ALQIMP1'	,0)
	ENDIF
Return lRet

/*/{Protheus.doc} F887WHNDOC
Metodo que habilita los campos serie EL_SDOCTO y documento EL_DOCTO cuando es tipo retención 
@type function
@version  1
@author luis.aboytes
@since 7/3/2023
/*/
Static Function F887WHNDOC()
	Local oModel 	:= FWModelActive()
	Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
	Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
	Local lRet		:= .F.

	IF AllTrim(cTipoDoc) $ 'RI|RR'
		lRet := .T.
	ELSE
		oModelSEL:LoadValue('EL_SDOCTO'	,"")
		oModelSEL:LoadValue('EL_DOCTO'	,"")
	ENDIF
Return lRet

/*/{Protheus.doc} F887CerPar
Función utilizada para mostrar una ventana para captura de certificados.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oViewPai - - vista activa para ser procesado
@Return 
/*/
Function F887CerPar(oViewPai)
Local cCampSFE		:= {"FE_NFISCAL", "FE_SERIE", "FE_PARCELA", "FE_CFO", "FE_VALBASE", "FE_ALIQ", "FE_RETENC", "FE_NROCERT", "FE_TIPO"}
Local oView			:= Nil
Local oModel		:= Nil
Local oStruSFE		:= Nil
Local oExecView		:= FWViewExec():New()
Local jsonSFE
Local cTitulo		:= ""
Local cReten		:= ""
Local cNumero		:= ""
Local cPrefix		:= ""
Local nValor		:= ""
Local aSaveLines 	:= {}

Default oViewPai	:= FwViewActive()

	oModel := oViewPai:GetModel()

	If !(oViewPai:GetCurrentSelect()[1] == "VIEW_SEL")
		Return
	Else
		oModelSEL := oModel:GetModel("SEL_DETAIL")
		If !(AllTrim(oModelSEL:GetValue("EL_TIPODOC")) $ "RI|RR") .Or. Empty(oModelSEL:GetValue("EL_NUMERO")) .Or. oModelSEL:IsDeleted()
			Return
		EndIf
	EndIf

	aSaveLines := FWSaveRows(oModel)

	cNumero := oModelSEL:GetValue("EL_NUMERO")
	cPrefix := oModelSEL:GetValue("EL_PREFIXO")
	nValor := oModelSEL:GetValue("EL_VALOR")
	
	cTitulo := oModelSEL:GetValue("EL_TIPODOC") + " " + cPrefix + "-" + cNumero + " " + AllTrim(Transform(nValor, GetSx3Cache("EL_VALOR", "X3_PICTURE")))
	cReten := Substr(oModelSEL:GetValue("EL_TIPODOC"),2,1)
	
	jsonSFE	:= JsonCpos(cCampSFE)
	oStruSFE := FWFormStruct( 2, 'SFE', { |cCampo| jsonSFE:HasProperty(AllTrim(cCampo)) }, .F.)

	oStruSFE:AddField('TIPODOC'	, '4',  AllTrim(FwX3Titulo("E1_TIPO"))	, AllTrim(FwX3Titulo("E1_TIPO"))	, NIL, 'GET', GetSx3Cache("E1_TIPO", "X3_PICTURE")		, , , .F.)

	oStruSFE:AddField('ELNUMERO', '11',  AllTrim(FwX3Titulo("EL_NUMERO"))	, AllTrim(FwX3Titulo("EL_NUMERO"))	, NIL, 'GET', GetSx3Cache("EL_NUMERO", "X3_PICTURE") , , , .F.)
	oStruSFE:AddField('ELPREFIX', '12',  AllTrim(FwX3Titulo("EL_PREFIXO"))	, AllTrim(FwX3Titulo("EL_PREFIXO"))	, NIL, 'GET', GetSx3Cache("EL_PREFIXO", "X3_PICTURE"), , , .F.)
	
	oStruSFE:SetProperty('FE_NFISCAL'	, MVC_VIEW_CANCHANGE	, .F.)
	oStruSFE:SetProperty('FE_SERIE'		, MVC_VIEW_CANCHANGE	, .F.)
	oStruSFE:SetProperty('FE_PARCELA'	, MVC_VIEW_CANCHANGE	, .F.)
	oStruSFE:SetProperty('FE_TIPO'		, MVC_VIEW_CANCHANGE	, .F.)

	oStruSFE:SetProperty('FE_NFISCAL'	, MVC_VIEW_ORDEM	, "01")
	oStruSFE:SetProperty('FE_SERIE'		, MVC_VIEW_ORDEM	, "02")
	oStruSFE:SetProperty('FE_PARCELA'	, MVC_VIEW_ORDEM	, "03")
	oStruSFE:SetProperty('TIPODOC'		, MVC_VIEW_ORDEM	, "04")
	oStruSFE:SetProperty('FE_VALBASE'	, MVC_VIEW_ORDEM	, "05")
	oStruSFE:SetProperty('FE_ALIQ'		, MVC_VIEW_ORDEM	, "06")
	oStruSFE:SetProperty('FE_RETENC'	, MVC_VIEW_ORDEM	, "07")
	oStruSFE:SetProperty('FE_CFO'		, MVC_VIEW_ORDEM	, "08")
	oStruSFE:SetProperty('FE_NROCERT'	, MVC_VIEW_ORDEM	, "09")
	oStruSFE:SetProperty('FE_TIPO'		, MVC_VIEW_ORDEM	, "10")
	oStruSFE:SetProperty('ELNUMERO'		, MVC_VIEW_ORDEM	, "11")
	oStruSFE:SetProperty('ELPREFIX'		, MVC_VIEW_ORDEM	, "12")

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddGrid('VIEW_SFE', oStruSFE, 'SFEGRID')
	oView:CreateHorizontalBox( 'BOXFORM_CER', 100)
	oView:SetOwnerView('VIEW_SFE','BOXFORM_CER')

	oView:SetAfterViewActivate({|oView| F887CarRet(oView:GetModel(), cReten, cNumero, cPrefix), F887FilCer(oView, cReten, cNumero, cPrefix), oView:Refresh()})
	oView:EnableTitleView('VIEW_SFE' , cTitulo )

	oView:SetViewProperty("VIEW_SFE","ENABLENEWGRID")
    oView:SetViewProperty("VIEW_SFE","GRIDFILTER",{.T.})
    oView:SetViewProperty("VIEW_SFE","GRIDSEEK",{.T.})

	//Retenciones con la View activa.
	If oModel != Nil .And. oModel:isActive()
		oExecView:setView(oView)
		oExecView:setTitle(STR0205) //"Certificados de Retención"
		oExecView:setOperation(oViewPai:GetOperation())
		oExecView:setReduction(50)
		oExecView:SetCloseOnOk({|| F887ValCer(oView:GetModel(), cReten, cNumero, cPrefix, nValor)})
		oExecView:openView(.F.)
		If oView:IsActive()
			oView:DeActivate()
		EndIf
	EndIf

	//Se retiran los bloqueos de inserción de línea y borrado.
	oModel:GetModel("SFEGRID"):SetNoInsertLine(.F.)
	oModel:GetModel("SFEGRID"):SetNoDeleteLine(.F.)

	FwClearHlp()
	FWRestRows( aSaveLines, oModel )

Return

/*/{Protheus.doc} F887FilCer
Función utilizada para realizar la carga de 
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cRet - caracter - Tipo de retención.
	cNumero - caracter - Número de documento de la retención (Forma de pago).
	cPrefix - caracter - Prefijo de la retención (Forma de pago).
@Return 
/*/
Static Function F887FilCer(oView, cRet, cNumero, cPrefix)
Local oViewSFE 	:= Nil
Local cFilterT	:= ""
Local cFilterN	:= ""
Local cFilterP	:= ""
Local aFilterT 	:= {}
Local aFilterN 	:= {}
Local aFilterP	:= {}

Default oView	:= FwViewActive()
Default cRet	:= ""
Default cELNUM		:= ""
Default cELPREFIX	:= ""

	oViewSFE	:= oView:GetViewObj('VIEW_SFE')[3]
	cFilterT		:= "FE_TIPO = '" + cRet + "'"
	aFilterT 	:= { 	{"FE_TIPO", "FIELD", "Certificado", cFilterT, cFilterT},;
						{"=","OPERATOR","","",""},;
						{"001","EXPRESSION","","","",.T.} }

	cFilterN		:= "ELNUMERO = '" + cNumero + "'"
	aFilterN 	:= { 	{"ELNUMERO", "FIELD", "Numero", cFilterN, cFilterN},;
						{"=","OPERATOR","","",""},;
						{"001","EXPRESSION","","","",.T.} }

	cFilterP		:= "ELPREFIX = '" + cPrefix + "'"
	aFilterP 	:= { 	{"ELPREFIX", "FIELD", "Prefijo", cFilterP, cFilterP},;
						{"=","OPERATOR","","",""},;
						{"001","EXPRESSION","","","",.T.} }

	oViewSFE:oBrowse:CleanFilter()
	oViewSFE:oBrowse:CleanExFilter()
	oViewSFE:oBrowse:DeleteFilter("Ret")
	oViewSFE:oBrowse:DeleteFilter("Num")
	oViewSFE:oBrowse:DeleteFilter("Pre")
	oViewSFE:oBrowse:AddFilter(	STR0206, cFilterT ,.T.,.T., , , aFilterT, "Ret" ) //"Retención"
	oViewSFE:oBrowse:AddFilter(	STR0207, cFilterN ,.T.,.T., , , aFilterN, "Num" ) //"Número"
	oViewSFE:oBrowse:AddFilter(	STR0208, cFilterP ,.T.,.T., , , aFilterP, "Pre" ) //"Prefijo"
	oViewSFE:oBrowse:ExecuteFilter(.T.)

	oView:Refresh()
Return

/*/{Protheus.doc} F887CarRet
Función utilizada para realizar la carga de certificados
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cReten - caracter - Tipo de retención.
	cELNUM - caracter - Número de documento de la retención (Forma de pago).
	cELPREFIX - caracter - Prefijo de la retención (Forma de pago).
@Return 
/*/
Function F887CarRet(oModel, cReten, cELNUM, cELPREFIX)
Local nX		:= 0
Local oModelSE1
Local oModelSFE

Default oModel		:= FWModelActive()
Default cReten		:= ""
Default cELNUM		:= ""
Default cELPREFIX	:= ""

	oModelSE1 := oModel:GetModel("SE1_DETAIL")
	oModelSFE := oModel:GetModel("SFEGRID")

	//Se agregan las líneas de certificados para los títulos seleccionados.
	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("CHECK", nX)
			F887AddCer(oModelSFE, oModelSE1:GetValue("E1_NUM", nX), oModelSE1:GetValue("E1_PREFIXO", nX), oModelSE1:GetValue("E1_PARCELA", nX), oModelSE1:GetValue("E1_TIPO", nX), cReten, cELNUM, cELPREFIX)
		EndIf
	Next nX

	//Se bloquea la inserción y borrado de líneas.
	oModelSFE:SetNoInsertLine(.T.)
	oModelSFE:SetNoDeleteLine(.T.)

Return

/*/{Protheus.doc} F887AddCer
Función utilizada para crear una pantalla de selección de otros títulos.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModelSFE - - submodelo las retenciones SFE.
	cNFiscal - caracter - Número del título.
	cSerie - caracter - Serie del título.
	cParcela - caracter - Couta del título.
	cTipoDoc - caracter - Tipo de documento del título.
	cReten - caracter - Tipo de retención.
	cELNUM - caracter - Número de documento de la retención (Forma de pago).
	cELPREFIX - caracter - Prefijo de la retención (Forma de pago).
@Return 
/*/
Function F887AddCer(oModelSFE, cNFiscal, cSerie, cParcela, cTipoDoc, cReten, cELNUM, cELPREFIX)
Local aSeek		:= {}

Default cNFiscal	:= ""
Default cSerie		:= ""
Default cParcela	:= ""
Default cTipoDoc	:= ""
Default cReten		:= ""
Default cELNUM		:= ""
Default cELPREFIX	:= ""

	aAdd(aSeek, {"FE_NFISCAL"	, cNFiscal})
	aAdd(aSeek, {"FE_SERIE"		, cSerie})
	aAdd(aSeek, {"FE_PARCELA"	, cParcela})
	aAdd(aSeek, {"TIPODOC"		, cTipoDoc})
	aAdd(aSeek, {"ELNUMERO"		, cELNUM})
	aAdd(aSeek, {"ELPREFIX"		, cELPREFIX})	
	aAdd(aSeek, {"FE_TIPO"		, cReten})
	
	//Se realiza la busqueda del título dentro del model de retenciones, 
	//si no existe línea para la retención seleccionada se agrega una línea nueva.
	If !oModelSFE:SeekLine(aSeek, .F., .F.)
		If oModelSFE:Length()>1 .Or. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			oModelSFE:AddLine()
		EndIf
		oModelSFE:LoadValue("FE_NFISCAL", cNFiscal)
		oModelSFE:LoadValue("FE_SERIE"	, cSerie)
		oModelSFE:LoadValue("FE_PARCELA", cParcela)
		oModelSFE:LoadValue("TIPODOC"	, cTipoDoc)
		oModelSFE:LoadValue("ELNUMERO"	, cELNUM)
		oModelSFE:LoadValue("ELPREFIX"	, cELPREFIX)
		oModelSFE:LoadValue("FE_TIPO"	, cReten)
	EndIf

Return

/*/{Protheus.doc} F887ValCer
Función utilizada para crear una pantalla de selección de otros títulos.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cReten - caracter - Tipo de retención.
	cELNUM - caracter - Número de documento de la retención (Forma de pago).
	cELPREFIX - caracter - Prefijo de la retención (Forma de pago).
	nValor - numerico - Valor de la retención.
@Return 
/*/
Function F887ValCer(oModel, cReten, cELNUM, cELPREFIX, nValor)
Local nX		:= 0
Local SumCer	:= 0
Local lRet		:= .T.
Local oModelSFE

Default oModel		:= FWModelActive()
Default cReten		:= ""
Default cELNUM		:= ""
Default cELPREFIX	:= ""
Default nValor		:= 0

	oModelSFE := oModel:GetModel("SFEGRID")

	//Sumatoria de valores del certificado para la retención en procesamiento.
	For nX := 1 To oModelSFE:Length()
		If !oModelSFE:IsDeleted(nX) .and. oModelSFE:GetValue("FE_TIPO", nX) == cReten .and. oModelSFE:GetValue("ELNUMERO", nX) == cELNUM .and. oModelSFE:GetValue("ELPREFIX", nX) == cELPREFIX
			SumCer += oModelSFE:GetValue("FE_RETENC", nX)
		EndIf
	Next nX

	//Se valida que no se superen los montos de la retención.
	If SumCer <> 0 
		If SumCer < nValor
			Help( " ", 1, "CERT",, STR0209 + cReten + " "  + cELPREFIX + "-" + cELNUM + ".",1,0) //"El valor de los certificado es menor al valor de la retención."
			lRet := .F.
		ElseIf SumCer > nValor
			Help( " ", 1, "CERT",, STR0210 + cReten + " "  + cELPREFIX + "-" + cELNUM + ".",1,0) //"El valor de los certificado es menor al valor de la retención."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F887DelPAR
Función utilizada para realizar los certificados 
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oView - - vista activa para ser procesado
	lDelete - logico - Indica si la línea está siendo borrada.
	lUnDelete - logico - Indica si la línea está siendo desmarcada de borrada.
@Return 
/*/
Static Function F887DelPAR(oView, lDelete, lUnDelete)
Local aSelect	:= {}

Default oView		:= FwViewActive()
Default lDelete		:= .F.
Default lUnDelete	:= .F.

	aSelect := oView:GetCurrentSelect()

	//Borrado de los certificados al borrar una línea de retenciones.
	If (aSelect[1] == "VIEW_SEL")
		F887ELDlCr(oView:GetModel(), lDelete, lUnDelete, .F.)
	EndIf

	//Actualización de saldos.
	F887ActSal(oView:GetModel())

Return

/*/{Protheus.doc} F887ELDlCr
Función utilizada para realizar el borrado de certificados.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	lDelete - logico - Indica si la línea está siendo borrada.
	lUnDelete - logico - Indica si la línea está siendo desmarcada de borrada.
	lAltNum - logico - Indica si la acción es la modificación de la numeración.
@Return 
/*/
Function F887ELDlCr(oModel, lDelete, lUnDelete, lAltNum)
Local nX		:= 0
Local nLine		:= 0
Local cRet		:= ""
Local cNumero	:= ""
Local cPrefix	:= ""
Local oModelSEL
Local oModelSFE

Default oModel		:= FWModelActive()
Default lDelete		:= .F.
Default lUnDelete	:= .F.
Default lAltNum		:= .F.

	oModelSEL := oModel:GetModel("SEL_DETAIL")
	oModelSFE := oModel:GetModel("SFEGRID")

	cRet := AllTrim(oModelSEL:GetValue("EL_TIPODOC"))
	cNumero := oModelSEL:GetValue("EL_NUMERO")
	cPrefix := oModelSEL:GetValue("EL_PREFIXO")
	//Se verifica que la línea que está siendo borrada sea una retención, o sea una modificación del número.
	If cRet == "RR" .Or. cRet == "RI" .and. ((lDelete .and. oModelSEL:IsDeleted()) .Or. (lUnDelete .and. !oModelSEL:IsDeleted()) .Or. lAltNum) 
		cRet := Substr(cRet, 2, 1)
		nLine := oModelSFE:GetLine()
		For nX := 1 To oModelSFE:Length()
			//Se buscan líneas de certificados para la retención en proceso.
			If oModelSFE:GetValue("FE_TIPO", nX) == cRet .and. oModelSFE:GetValue("ELNUMERO", nX) == cNumero .and. oModelSFE:GetValue("ELPREFIX", nX) == cPrefix
				oModelSFE:GoLine(nX)
				If (lDelete .and. !oModelSFE:IsDeleted(nX)) .Or. lAltNum //Si es un borrado de línea o alteración de numeración marca como borradas las líneas.
					oModelSFE:DeleteLine()
				ElseIf lUnDelete .and. oModelSFE:IsDeleted(nX) //Si se desmarca el borrado de una retención y hay líneas marcadas como borradas se recuperan borrando los valores.
					oModelSFE:UnDeleteLine()
					oModelSFE:LoadValue("FE_VALBASE", 0)
					oModelSFE:LoadValue("FE_ALIQ", 0)
					oModelSFE:LoadValue("FE_RETENC", 0)
					oModelSFE:LoadValue("FE_CFO", "")
					oModelSFE:LoadValue("FE_NROCERT", "")
				EndIf
			EndIf
		Next
		oModelSFE:GoLine(nLine)
	EndIf

Return

/*/{Protheus.doc} F887ChkPAR
Función utilizada para las acciones de campo del campo CHECK en Paraguay
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - modelo activo para ser procesado
@Return 
/*/
Function F887ChkPAR(oModel)
Local nX		:= 0
Local aSeek		:= {}
Local aRet		:= {"I", "R"} //Tipos de retenciones.
Local lSeek		:= .F.	
Local oModelSE1
Local oModelSFE

Default oModel		:= FWModelActive()

	oModelSE1 := oModel:GetModel("SE1_DETAIL")

	If !oModelSE1:GetValue("CHECK")
		oModelSFE := oModel:GetModel("SFEGRID")

		aAdd(aSeek, {"FE_NFISCAL"	, oModelSE1:GetValue("E1_NUM")})
		aAdd(aSeek, {"FE_SERIE"		, oModelSE1:GetValue("E1_PREFIXO")})
		aAdd(aSeek, {"FE_PARCELA"	, oModelSE1:GetValue("E1_PARCELA")})
		aAdd(aSeek, {"TIPODOC"		, oModelSE1:GetValue("E1_TIPO")})
		aAdd(aSeek, {"FE_TIPO"		, ""})

		For nX := 1 To Len(aRet)
			aSeek[5][2] := aRet[nX]
			lSeek := .T.
			//Se realiza una busqueda de certificados para el título que está siendo desmarcado, si se encuentran son borradas.
			While lSeek
				If oModelSFE:SeekLine(aSeek, .F., .T.)
					oModelSFE:LoadValue("FE_VALBASE", 0)
					oModelSFE:LoadValue("FE_ALIQ", 0)
					oModelSFE:LoadValue("FE_RETENC", 0)
					oModelSFE:LoadValue("FE_CFO", "")
					oModelSFE:LoadValue("FE_NROCERT", "")
					oModelSFE:LoadValue("FE_TIPO", "")
					oModelSFE:DeleteLine()
				Else
					lSeek := .F.
				EndIf
			EndDo
		Next
		oModelSFE:GoLine(1)
	EndIf

	//Actualización de saldos.
	F887ActSal(oModel)

Return

/*/{Protheus.doc} F887CerVal
Función utilizada para los disparadores de los certificados de retención.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    cCampo - String - Nombre del campo que fue editado
@Return 
/*/
Function F887CerVal(cCampo)
Local nVal		:= 0

Default cCampo	:= ""

	//Disparadores para los valores de retenciones.
	If cCampo == "FE_VALBASE" .Or. cCampo == "FE_ALIQ"
		nVal := Round(FwFldGet("FE_VALBASE") * (FwFldGet("FE_ALIQ")/100), MsDecimais(1))
	ElseIf cCampo == "FE_RETENC"
		nVal := Round(((FwFldGet("FE_RETENC")/ FwFldGet("FE_VALBASE")) * 100), MsDecimais(1))
	EndIf

Return nVal

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
