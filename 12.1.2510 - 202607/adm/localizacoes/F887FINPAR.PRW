#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINPAR
Clase responsable por el evento de reglas de negocio de 
localización de Paraguay

@type 		Class
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Class F887FINPAR From FwModelEvent

	Method New() CONSTRUCTOR
	Method VldActivate()

	Method InTTS()

	Method FINUPDSE()

	Method GridLinePreVld()

	Method isNotaFiscalAutorizada()


EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Method New() Class F887FINPAR

Return Nil

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Method VldActivate(oModel) Class F887FINPAR
	Local cCredMed	:=  GetSESTipos({|| ES_RCOPGER == "1"},"1")
	Local cCredInm	:= 	GetSESTipos({|| ES_RCOPGER == "2"},"1")
	Local lRet		:= .T.

	self:GetEvent("F887FIN"):cCredMed := IIf(Empty(cCredMed),"CH |CC |CD ",cCredMed)
	self:GetEvent("F887FIN"):cCredInm := IIf(Empty(cCredInm),"TF |EF ",cCredInm)
	self:GetEvent("F887FIN"):lDocTran := .T.
	self:GetEvent("F887FIN"):lProcede := .F.
	self:GetEvent("F887FIN"):lTasa := .F.
	self:GetEvent("F887FIN"):lSituaca := .T.

Return lRet

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.
@return 	NIL, NIL, NIL

@author 	alan.lunardi
@version	12.1.2410
@since		08/11/2025
/*/
Method InTTS(oModel, cModelId) Class F887FINPAR
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	EndIf

Return Nil

/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5
@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@author 	alan.lunardi
@version	12.1.2510
@since		08/11/2025
/*/
Method FINUPDSE(oModel) Class F887FINPAR
	Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
	Local nX			:= 0

	FOR nX := 1 TO oModelSE1:Length()
		if oModelSE1:GetValue("RECNO",nX) <> 0 .And. oModelSE1:GetValue("CHECK",nX) == .T.
			//Si la naturaleza del valor es un valor anticipado, ED_OPERADT = 1 genera el valor de tipo "RA" en función del valor anticipado.
			IF X3Usado("ED_OPERADT")
				IF GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oModelSE1:GetValue("E1_NATUREZ",nX),1,"") == "1"
					//PER/MEX/PAR
					FI998NFRA(oModelSE1:GetValue("BAIXAR",nX),nX,oModel)
				ENDIF
			ENDIF
		endif

	NEXT
Return Nil


/*/{Protheus.doc} GridLinePreVld
Metodo responsabe por ejecutar pre validaciones del campo.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param      nLine       ,numerico   ,Número de línea procesada.
@param 		cAction 	,caracter	,Identificador de la acción realizada (CANSETVALUE/SETVALUE).
@param 		cId     	,caracter	,Identificador del campo ejecutado.
@param 		xValue  	,       	,Valor recibido del campo.
@param      xCurrentValue,          , 
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	Alan Lunardi
@version	12.1.2410 / Superior
@since		08/11/2025/2024
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class F887FINPAR
	Local lRet		:= .T.
	Local cDocs		:= SubStr(MVRECANT,1,3)

	If cModelID == "SE1_DETAIL"
		If cAction == "SETVALUE"
			If cId == "CHECK"
				If xValue
					If X3Usado("ED_OPERADT")
						if GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oSubModel:getvalue('E1_NATUREZ'),1,"") == "1"
							if oSubModel:GetValue('E1_TIPO') $ cDocs
								lRet := .F.
								Help(NIL, NIL, STR0017, NIL, STR0271, 1, 0) //No se puede descargar un título del tipo RA de origen Anticipo, solamente a través del vínculo con la Factura de Venta.
							else
								lRet := self:isNotaFiscalAutorizada(oSubModel, nLine)
								if !lRet
									Help(NIL, NIL, STR0017, NIL, STR0266, 1, 0) //'La baja solo podrá realizarse cuando la factura de Antecipo esté autorizada.'
								endif
							endif
						endif
					Endif
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} isNotaFiscalAutorizada
	(La validación es condicional y depende de la configuración del campo de usuario "ED_OPERADT". 
	Si el parámetro obtenido a través de GetAdvFVal para la naturaleza de la operación (E1_NATUREZ) es "1", 
	se procede a llamar a la función `checkSF2` para realizar la 
	verificación efectiva sobre los datos de la factura.
    
    En caso de que la validación no sea necesaria (según el parámetro), 
	el método retornará .T. por defecto.)
	@author alan.lunardi
	@since 24/09/2025
	@version version
	@param oSubModel, Objeto, Objeto del submodelo que contiene los datos del título a ser validado (por ejemplo, aCols).
    @param nLine, Numérico, Opcional. Número de la línea del submodelo que se está procesando. Si no se informa, asume el valor 1.
	@return lRet, Lógico, Devuelve .T. (verdadero) si la nota fiscal se considera autorizada o si la validación no aplica. 
	Devuelve .F. (falso) si la nota fiscal no está autorizada, según el resultado de la función `checkSF2`.
/*/
Method isNotaFiscalAutorizada(oSubModel, nLine) Class F887FINPAR
	Local lRet		:= .T.

	Default nLine 	:= 1
	Default oSubModel := NIL

	lRet := checkSF2(oSubModel:GetValue("E1_CLIENTE", nLine), oSubModel:GetValue("E1_LOJA", nLine),;
		oSubModel:GetValue("E1_NUM", nLine), ;
		oSubModel:GetValue("E1_PREFIXO", nLine), oSubModel:GetValue("E1_FILIAL", nLine ))

Return lRet

/*/{Protheus.doc} checkSF2
    Esta función verifica el estado de una Factura de Venta en la tabla SF2 (Cabecera de Facturas de Venta).
    
    Ejecuta una consulta SQL para buscar el valor del campo `F2_FLFTEX` (Flag Estado NF) basado en los parámetros del documento proporcionados.
    
    La función devuelve verdadero (`.T.`) específicamente cuando el estado encontrado para la factura es igual a '6'. Para cualquier otro valor, o si el registro no se encuentra, la función devolverá falso (`.F.`). El estado '6' generalmente indica una condición específica de procesamiento o autorización de la factura en el flujo de la empresa.
    
    @type  Static Function
    @author alan.lunardi
    @since 24/09/2025
    @version 1.0
    @param cClient, Carácter, Código del cliente de la factura.
    @param cLoja, Carácter, Código de la tienda del cliente.
    @param cNum, Carácter, Número del documento (factura).
    @param cSerie, Carácter, Serie del documento (factura).
    @param cFilOri, Carácter, Sucursal de origen del documento a consultar.
    @return lRet, Lógico, Devuelve `.T.` si el campo `F2_FLFTEX` de la factura es igual a '6'. En caso contrario, 
	o si la factura no se encuentra, devuelve `.F.`.
    @example
    // Ejemplo de llamada para verificar si una factura posee el estado '6'
    If checkSF2("000001", "01", "000123", "NF", "UN", "0101")
      // La factura tiene el estado '6'
      MsgInfo("Factura con estado válido.")
    Else
      // La factura no tiene el estado '6' o no fue encontrada
      MsgInfo("Factura pendiente o no encontrada.")
    EndIf
    
    @see isNotaFiscalAutorizada
/*/
Static Function checkSF2(cClient, cLoja,cNum,cSerie,cFilOri)
	Local cQuery 		:= "" As Character
	Local oExec			:= NIL As Object
	Local lRet			:= .F. As Logical
	Local cStatus		:= "" As Character

	Default cClient		:= ""
	Default cLoja		:= ""
	Default cNum		:= ""
	Default cFilOri		:= ""
	Default cSerie		:= ""

	cQuery := "SELECT F2_FLFTEX FROM " + RetSqlName("SF2") + " SF2"
	cQuery += " WHERE F2_FILIAL = ?"
	cQuery += " AND F2_CLIENTE = ?"
	cQuery += " AND F2_LOJA = ?"
	cQuery += " AND F2_DOC = ?"
	cQuery += " AND F2_SERIE = ?"
	cQuery += " AND D_E_L_E_T_ = ?"

	cQuery := ChangeQuery(cQuery)

	oExec := FwExecStatement():New(cQuery)
	oExec:SetString(1,cFilOri)
	oExec:SetString(2,cClient)
	oExec:SetString(3,cLoja)
	oExec:SetString(4,cNum)
	oExec:SetString(5,cSerie)
	oExec:SetString(6,' ')

	cStatus := oExec:ExecScalar("F2_FLFTEX")

	if cStatus == '6'
		lRet := .T.
	endif

	oExec:Destroy()
	oExec := nil

Return lRet
