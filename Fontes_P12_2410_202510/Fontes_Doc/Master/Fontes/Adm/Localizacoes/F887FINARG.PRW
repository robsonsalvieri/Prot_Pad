#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINARG
Clase responsable por el evento de reglas de negocio de 
localización de Argentina

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021
/*/
Class F887FINARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()

	Method ModelPosVld()
	
	Method BeforeTTS()
	
	Method InTTS()

	Method GridLinePosVld()

	Method FINUPDSEL()

	Method FINGERNCC()

	Method FINUPDSE()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method New() Class F887FINARG
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method VldActivate(oModel) Class F887FINARG
Local bFilt1 	:= {|| ((FJS->FJS_RCOP == "1") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
Local bFilt2 	:= {|| ((FJS->FJS_RCOP == "2") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))}
Local cChave	:= xFilial("FJS")
Local cAlias	:= "FJS"
Local cCampo	:= "FJS_TIPO" 
Local nOrder	:= 1  
Local cCredMed	:= ""
Local cCredInm	:= ""
Local lRet		:= .T.

	cCredMed := FinGetTipo(bFilt1,cAlias,cChave,cCampo,nOrder)
	cCredInm := FinGetTipo(bFilt2,cAlias,cChave,cCampo,nOrder)

	self:GetEvent("F887FIN"):cCredMed := IIf(Empty(cCredMed),GetSESNew("CH","3"),cCredMed)
	self:GetEvent("F887FIN"):cCredInm := IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	self:GetEvent("F887FIN"):lCredInm := .T.
	self:GetEvent("F887FIN"):lDocTran := .T.
	self:GetEvent("F887FIN"):lTipodoc := .F.
	self:GetEvent("F887FIN"):lProcede := .F.
	self:GetEvent("F887FIN"):lVldVcto := .F.
	self:GetEvent("F887FIN"):lPostal  := .T.
	self:GetEvent("F887FIN"):lSituaca := .T.
	self:GetEvent("F887FIN"):lActTipo := .F.	

Return lRet

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada

@author 	raul.medina	
@version	12.2.27 / Superior
@since		12/04/2021 
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887FINARG
Local lRet		As Logical
Local cError	As Character
Local dDtVcto 	As Date 
Local dDtEmiss 	As Date
Local aresp		As Array
Local aServMod  As Array
Local cModoPago As Character
Local nOperation := oSubModel:GetOperation() As Numeric

lRet	  	:= .T.  
aresp		:= {}	
aServMod	:= {}	
cError 		:= ""

	IF cModelID == 'SEL_DETAIL' .AND. (nOperation != MODEL_OPERATION_UPDATE) .AND. (!oSubModel:GetValue("EL_TIPODOC",nLine)$"TB|RA")
		IF AllTrim(oSubModel:GetValue("EL_TIPODOC",nLine)) $ "CH|CHD"
			IF Empty(oSubModel:GetValue("EL_BCOCHQ ",nLine))
				cError := STR0111 //El campo 'Banco Chequé debe ser llenado para la forma de pago tipo CH
				Help(,,"BANCO CHEQUE","EL_BCOCHQ",cError,nLine,0) 
				lRet	:=	.F.
			ENDIF

			DbSelectArea("FJN")
			FJN->(DbSetOrder(1))//FJN_FILIAL+FJN_COD+FJN_AGENCI                                                                  
			If !FJN->(MsSeek(xFilial("FJN")+oSubModel:GetValue("EL_BCOCHQ",nLine)+oSubModel:GetValue("EL_AGECHQ",nLine)))
				cError := "EL_BCOCHQ ==> " + STR0135 +":"+ STR0136  //Fue imposible encontrar los dados del banco cheque, Regrese y confirme los dados del banco cheque
				Help( ,, "BANCO CHEQUE" ,"EL_BCOCHQ",cError ,nLine, 0 )
				lRet	:=	.F.
			EndIf
			FJN->(DbCloseArea())
		ENDIF
		IF lRet .And.Subs(oSubModel:GetValue("EL_TIPO",nLine),1,2) $ "CC|CD"//Tarjeta de credito
			If VAZIO(oSubModel:GetValue("EL_ADMIN",nLine))
				cError := "EL_ADMIN ==> " + STR0121//"No es posible efectuar la baja de los títulos porque no existe una administradora financiera de tarjeta de Crédito / Debito registrada"
				Help( ,, "ADMINISTRADORA" ,"EL_ADMIN",cError ,nLine, 0 )
				lRet	:=	.F.
			ENDIF
		ENDIF
		IF lRet .And. oSubModel:GetValue("EL_TIPODOC",nLine) == "DC"//Documento
			If VAZIO(oSubModel:GetValue("EL_CGC",nLine))
				cError := "EL_CGC ==> " + STR0198  //"El campo ID contrib. es obligatorio"
				Help( ,, "EL_CGC" ,"EL_CGC",cError ,nLine, 0 )
				lRet	:=	.F.
			ENDIF
		ENDIF
		IF lRet
			dDtVcto := oSubModel:GetValue("EL_DTVCTO",nLine)	
			dDtEmiss := oSubModel:GetValue("EL_EMISSAO",nLine)	
			cModoPago := oSubModel:GetValue("EL_TIPO",nLine)	

			lRet := F840VldVct(dDtVcto,dDtEmiss,cModoPago,@aresp,aServMod)
			IIF(lRet==.F.,Help( ,, STR0050 ,"EL_DTVCTO","EL_DTVCTO ==> " + aresp[1] ,nLine, 0 ),"") // "Error"- "La fecha de vencimiento informada no es válida o no se acepta pra el Modo de pago utilizado."
		ENDIF
	EndIf

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method Destroy() Class F887FINARG

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsable por ejecutar las validaçioes de las reglas de negocio
genéricas del cadastro antes de la grabación del formulario.
Si retorna falso, no permite grabar.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelID ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		23/06/2021 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cModelID) Class F887FINARG
Local lValid 		:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
Local oMdlMOE		:= oModel:GetModel('MOE_DETAIL')
lOCAL oModelFJT		:= oModel:GetModel('FJT_MASTER')
Local cClient	:= oModelFJT:GetValue("FJT_CLIENT")
Local cLoja		:= oModelFJT:GetValue("FJT_LOJA")
Local nPosIni	:= 0 
Local lExistSFP	:= .F.
Local cCombo	:= ""
Local nLine			:= 0
Local nSelLine		:= 0	
Local nValor		:= 0
Local lFIN998NCC 	:= FWSX1Util():ExistPergunte("FIN998NCC")
Local cCondPag		:= SuperGetMV( "MV_CONDPAD")

	If nOperation == MODEL_OPERATION_INSERT	
		nSelLine := oModelSEL:GetLine()
		
		For nLine := 1 To oModelSEL:Length()
			oModelSEL:GoLine(nLine)
			If oModelSEL:IsDeleted() .Or. !oModelSEL:IsUpdated()
				loop
			Endif
			
			If lValid
				If AllTrim(oModelSEL:GetValue("EL_TIPODOC",nLine)) == "CH"  
					If Empty(oModelSEL:GetValue("EL_BCOCHQ",nLine))
						Help(NIL, NIL, "EL_BCOCHQ", NIL, STR0079, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080})
						lValid	:=	.F.
					EndIf
				Else 
					If !Empty(oModelSEL:GetValue("EL_BCOCHQ",nLine))
						Help(NIL, NIL, "EL_BCOCHQ", NIL, STR0077, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0078})
						lValid	:=	.F.
					EndIf
				EndIf
			EndIf
			
		Next nLine
		
		oModelSEL:GoLine(nSelLine)

		Pergunte("FIN998",.F.)

		nValor := oMdlMOE:getvalue('SALDO') 
		If MV_PAR04 == 1 .AND. nValor > 0 .AND. !lFIN998NCC
			Help( ,,STR0017 ,, STR0253, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0254}) //STR0017 - Atención, STR0253 -"Grupo de preguntas FIN998NCC inexistente", STR0254 - "Por favor configure el grupo de preguntas FIN998NCC para continuar o cambie el valor del parametro ¿Documento a generar por Dif ? a RA"
			lValid:=.F.
		ELSEIF MV_PAR04 == 1 .AND. nValor > 0 .AND. lFIN998NCC
			Pergunte("FIN998NCC",.F.)

			//Validamos la TES de salida del cliente seleccionado
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
			If SA1->(MsSeek(xFilial("SA1")+cClient+cLoja))
				// Datos de la TES
				DbSelectArea("SF4")
				SF4->(dbSetOrder(1))//F4_FILIAL+F4_CODIGO
				IF Empty(SA1->A1_TESD)
					Help('',1,'FA074015') 
					lValid:= .F.// Si el proveedor no tiene un TES configurado, no se debe generar ningún documento tributario.
				ENDIF
			ENDIF

			//Validamos el punto de venta
			IF lValid
				//Busca la posicion del tipo de documento (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
				nPosIni := At("NCC",Getsx3Cache("FP_ESPECIE","X3_CBOX"))
				cCombo := Substr(Getsx3Cache("FP_ESPECIE","X3_CBOX"),nPosIni-2,1)
				("SFP")->(DbSetOrder(9)) //FP_FILIAL+FP_PV
				IF ("SFP")->(MsSeek(xFilial("SFP")+MV_PAR01))
					While (SFP->(!EOF()))
						IF AllTrim(SFP->FP_ESPECIE) == AllTrim(cCombo) .AND. SFP->FP_ATIVO == "1"
							lExistSFP := .T.
						ENDIF
						SFP->( DBSkip() )
					ENDDO
				ENDIF
				IF !lExistSFP
					Help( ,,STR0017 ,, STR0255, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0256}) //STR0017 - Atención, STR0255 - No existe serie configurada para el tipo de titulo NCC en el control de formularios, STR0256 - Configure la serie en el control de formularios
					lValid := .F.
				ENDIF
			EndIF

			//Validamos la condición
			IF lValid 
				IF VAZIO(cCondPag)
					Help( ,,STR0017 ,, STR0257, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0258}) //STR0017 - Atención, STR0257 - Condición de pago vacia, STR0258 - Introduzca una condicion de pago (MV_CONDPAD)
						lValid := .F.
				ELSE
					SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
					If !SE4->(MsSeek(xFilial("SE4")+cCondPag))
						Help( ,,STR0017 ,, STR0259, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0260}) //STR0017 - Atención, STR0259 - Condición de pago inexistente, STR0260 - "Seleccione una condición de pago existente en el parametro MV_CONDPAD"
						lValid := .F.
					ENDIF
				ENDIF
			ENDIF

			IF lValid
				lValid:=FINGERNCC(oModel)
			ENDIF
		EndIf
	EndIf

Return lValid

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINARG
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSEL(oModel)
	EndIf 

Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		11/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINARG

Return Nil

/*/{Protheus.doc} F887FINARG::FINUPDSEL
Metodo responsable para la actualización de la tabla SEL para ARG
@type method
@version  1
@author luis.aboytes
@since 13/7/2022
@param oModel, object, Modelo de dados SEL.
@param nLin, numeric, Linea a editar
/*/
Method FINUPDSEL(oModel, nLin) Class F887FINARG
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelADM 	:= oModel:GetModel('ADM_DETAIL')
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local nX			:= 0
Local nSelLine		:= 0

	nSelLine := oModelSEL:GetLine()
	For nX := 1 To oModelSEL:Length()
		oModelSEL:GoLine(nX)
		If oModelSEL:GetValue("EL_TRANSIT",nX) == "2" 
			oModelSEL:SetValue("EL_DTENTRA", dDataBase)
		EndIf	
		//Administradora financiera , cambia EL_TIPO para ARG en vez dde EL_TIPODOC
		If oModelSEL:GetValue("EL_TIPO",nX) <> "TB" 
			//Reemplazo del cliente por la caja financiera cuando es un documento tipo CC
			IF ALLTRIM(oModelSEL:GetValue("EL_TIPODOC",nX)) $ 'CC|CD' .AND. !Empty(oModelSEL:GetValue("EL_ADMIN",nX))
				oModelSEL:loadValue("EL_CLIENTE", getClienteSAE(oModelSEL:GetValue("EL_ADMIN",nX)))
			ENDIF
		EndIf
	Next nX
	oModelSEL:GoLine(nSelLine)

Return Nil

/*/{Protheus.doc} FINGERNCC
FINGERNCC responsable por realizar el tratamiento de documentos NCC
@author 	luis.aboytes
@version	12.1.2310 / Superior
@since		25/07/2025
/*/
Static Function FINGERNCC(oModel)
Local oModelMOE := oModel:GetModel('MOE_DETAIL') //Objeto de monedas
Local oModelFJT := oModel:GetModel('FJT_MASTER') //Objeto encabezado
Local aCab 		:= {} 	//Datos del encabezado
Local aItem 	:= {} 	//Datos del item
Local aLinea 	:= {} 	//Matriz que guarda la matriz aItem (requerido por la rutina)
Local nValMoed	:= 0	//Valor de la moneda
Local cClient	:= oModelFJT:GetValue("FJT_CLIENT")
Local cLoja		:= oModelFJT:GetValue("FJT_LOJA")
Local cSerie	:= oModelFJT:GetValue("FJT_SERIE")
Local cNum		:= oModelFJT:GetValue("FJT_RECIBO")
Local cTipoDoc	:= oModelFJT:GetValue("DOCUMEN")
Local cCondPag	:= SuperGetMV( "MV_CONDPAD")
Local cRG1415	:= "" As Character
Local cProvent	:= "" As Character
Local cPrefixo	:= "" As Character
Local cLocxNFPV	:= "" As Character
Local nTipo 	:= 04 
Local cCodProd	:= "" As Character
Local cUndMed	:= "" As Character
Local cProduct	:= "" As Character
Local cDep		:= "" As Character
Local nTotDif	:= 0  As Numeric
Local cTES		:= "" As Character
Local cCf		:= "" As Character
Local lGera		:= .T. As Logical
Local lValid	:= .T. As Logical
Private lMsErroAuto := .F.    
Default oModel 	:= FWModelActive()


	Pergunte("FIN998NCC",.F.)
	cLocxNFPV := MV_PAR01
	cProduct  := MV_PAR02

	Pergunte("PVXARG",.F.)
	SetMVValue("PVXARG","MV_PAR01", cLocxNFPV)	

	For nValMoed := 1 To oModelMOE:Length()
		If oModelMOE:GetValue("SALDO", nValMoed) > 0
			cRG1415:= F074CODRG(cClient,cLoja,"",cSerie,cTipoDoc)
			cPrefixo  	:= F074VldPv(cTipoDoc,cLocxNFPV)[1] 
			nTotDif		:= oModelMOE:GetValue("SALDO", nValMoed) *-1

			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
			If SA1->(MsSeek(xFilial("SA1")+cClient+cLoja))
				cProvEnt := IIF(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)
				// Datos de la TES - la validacion esta en el metodo ModelPosVld
				DbSelectArea("SF4")
				SF4->(dbSetOrder(1))////F4_FILIAL+F4_CODIGO
				SF4->(MsSeek(xFilial('SF4')+SA1->A1_TESD))
				cTES:= SA1->A1_TESD
				cCf:= SF4->F4_CF

				//Datos del item - - la validacion esta en el diccionario
				DbSelectArea("SB1")  
				SB1->(dbSetOrder(1))//SB1_FILIAL+B1_COD
				SB1->(MsSeek(xFilial("SB1")+cProduct))
				cCodProd:=SB1->B1_COD
				cUndMed:=SB1->B1_UM
				cDep:=SB1->B1_LOCPAD

				If lGera
					// Documento Fiscal 
					aAdd(aCab, {"F1_FORNECE"		, cClient	 	 ,Nil}) 	//Código Cliente
					aAdd(aCab, {"F1_LOJA"			, cLoja			 ,Nil}) 	//Tienda Cliente
					aAdd(aCab, {"F1_SERIE"			, ALLTRIM(cPrefixo),Nil}) 	//Serie del documento
					aAdd(aCab, {"F1_DOC"			, cNum		     ,Nil}) 	//Número de documento		
					aAdd(aCab, {"F1_TIPO"			, "D"		     ,Nil}) 	//Tipo da nota (C=Credito / D=Debito)
				
					aAdd(aCab, {"F1_NATUREZ"		, ""		     ,Nil})	 	//Naturaleza (Financiero)
					aAdd(aCab, {"F1_ESPECIE"		, cTipoDoc		 ,Nil}) 	//Tipo de Documento 
					aAdd(aCab, {"F1_EMISSAO"		, dDatabase		 ,Nil}) 	//Fecha de Emisión
					aAdd(aCab, {"F1_DTDIGIT"		, dDatabase		 ,Nil}) 	//Fecha de Digitación	
					aAdd(aCab, {"F1_MOEDA"			, 1				 ,Nil}) 	//MonÙeda
					aAdd(aCab, {"F1_TXMOEDA"		, 1				 ,Nil}) 	//Tasa de moneda						
				
					aAdd(aCab, {"F1_TIPODOC"		, "04"			 ,Nil}) 	//Tipo de documento (utilizado en la función LOCXNF)								
					aAdd(aCab, {"F1_FORMUL"			, "S", 			 ,Nil}) 	//Indica si se utiliza un Formulario Propio para el documento
					aAdd(aCab, {"F1_COND"			, cCondPag		 ,Nil}) 	//Condición de pago												
									
					aAdd(aCab, {"F1_TPVENT"			, "S"			,Nil})  
					aAdd(aCab, {"F1_FECDSE"			, dDataBase		,Nil})
					aAdd(aCab, {"F1_FECHSE"			, dDatabase	    ,Nil})
					aAdd(aCab, {"F1_PV"				, cLocxNFPV	    ,Nil})	//Verificar origen por que manda 03 en la FINA074 y en totvs recibo 013
					aAdd(aCab, {"F1_RG1415"			, cRG1415		,Nil})
					aAdd(aCab, {"F1_PROVENT"		, cProvent		,Nil})	

					// Item 1
					aAdd(aItem, {"D1_COD"			, cCodProd				,Nil}) 	//Código de producto  PREGUNTA 11 
					aAdd(aItem, {"D1_UM"			, cUndMed				,Nil}) 	//Unidad de medida						
					aAdd(aItem, {"D1_QUANT"			, 1						,Nil}) 	//Cantidad
					aAdd(aItem, {"D1_VUNIT"			, Abs(nTotDif)			,Nil}) 	//Precio de Venta 
					aAdd(aItem, {"D1_TOTAL"			, Abs(nTotDif)			,Nil}) 	//Total
					aAdd(aItem, {"D1_TES"			, cTES					,Nil}) 	//TES						
					aAdd(aItem, {"D1_CF"			, cCf					,Nil}) 	//Código Fiscal (completar según TES)
					aAdd(aItem, {"D1_LOCAL"			, cDep					,Nil}) 	//Depósito		
					aAdd(aItem, {"D1_PROVENT"		, cProvent			 	,Nil})

					aAdd(aItem, {"D1_NFORI"			, cNum			,Nil})
					aAdd(aItem, {"D1_SERIORI"		, cSerie		,Nil})
				
					aAdd(aLinea, aItem)
					aItem:={} 
					Begin Transaction
						Processa({||msExecAuto({|u,v,w,x,y,z| MATA465N(u,v,w,x,y,z)}, aCab, aLinea, 3, Nil, Nil, nTipo)	},STR0264) //STR0264 - Grabando datos de NCC.	 
						If lMsErroAuto
							lValid := .F.
							MostraErro()
							DisarmTransaction()
						EndIf
					End Transaction
				ENDIF 
			ENDIF
		ENDIF
	Next nValMoed
Return lValid
