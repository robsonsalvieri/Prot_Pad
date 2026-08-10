#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA447B.CH"
#INCLUDE "FWLIBVERSION.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA447B ³ Autor ³ Guadalupe Santacruz       ³ Data ³ 30/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera Facturas en Compras y Movtos a Almacen                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATA447B()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³            Motivo da Alteracao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gsantacruz  ³ 061216 ³          ³Se modifican los nombre de los PE         ³±±
±±³ Marco A    ³29/09/17³TSSERMI01-³Se realiza replica para V12.1.17, de la   ³±±
±±³            ³        ³151       ³funcionalidad de Pedimentos de Importacion³±±
±±³            ³        ³          ³para el Pais Mexico.                      ³±±
±±³ M.Camargo  ³23/03/18³DMINA-2335³Se modifica GENFACTENT para guardar los   ³±±
±±³            ³        ³          ³campos rse_uuid,rse_fectim y rse_rutdo a  ³±±
±±³            ³        ³          ³sf1. sE AGREGA m477cpyfile                ³±±
±±³ Marco A    ³04/07/18³DMANSIST-6³Se modifican mensajes de validacion, mos- ³±±
±±³            ³        ³          ³trados cuando no se informan impuestos en ³±±
±±³            ³        ³          ³items.                                    ³±±
±±³ Marco A    ³17/07/18³DMANSISTE-³Se agrega validacion para el uso correcto,³±±
±±³            ³        ³27        ³de la TES, al crear un Pedimento. Se agre-³±±
±±³            ³        ³          ³ga funcion M447VLDTes().                  ³±±
±±³ gSantacruz ³17/09/18³DMINA-3952³Al crear la factura de gastos, busca la   ³±±
±±³            ³        ³          ³mercancia solo por el codigo de producto  ³±±
±±³ Marco A    ³04/07/19³DMINA-6916³Se agrega la grabacion del campo D1_PEDIM,³±±
±±³            ³        ³          ³para las Facturas de Extraccion.          ³±±
±±³ gSantacruz ³02/09/19³DMINA-7382³Evitar que los items con imp. ceros sean  ³±±
±±³            ³        ³          ³generados como items de las fact. de gtos.³±±
±±³ gSantacruz ³30/09/19³DMINA-7570³Se agrega PE M447BIPE                     ³±±
±±³Eduardo Prz ³25/02/20³DMINA-8323³En la genracion de documentos, se agrega  ³±±
±±³            ³        ³          ³bifurcacion para cuando no se tiene IVA   ³±± 
±±³            ³        ³          ³diferente de tipo cero var. nPosIvaNCero  ³±±
±±³José Glez   ³10/03/20³DMINA-8493³Se elimina Validacion de se tiene el mismo³±±
±±³            ³        ³          ³almacen de entrada y salida para          ³±± 
±±³            ³        ³          ³el producto.                              ³±± 
±±³José Glez   ³24/04/20³DMINA-8825³Se Agrega el IVA de los impuestos que son ³±±
±±³            ³        ³          ³nivel pedimento y que aplican IVA y una   ³±±
±±³            ³        ³          ³Validación para No generar Documentos de  ³±±
±±³            ³        ³          ³Mov. internos si los importes esta en 0   ³±±
±±³José Glez   ³23/12/20³DMINA     ³Se Agrega tratamiento en la función       ³±±
±±³            ³        ³    -10738³EliFacturas para los campos de tipo MEMO  ³±±
±±³ Marco A.   ³16/07/21³ DMINA-   ³Se agrega la función M447VldCon() para    ³±±
±±³            ³        ³     12747³validar si la condición de pago tiene baja³±±
±±³            ³        ³          ³automatica y permitir el borrado de docu- ³±±
±±³            ³        ³          ³mentos.                                   ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA447B(nOpcion)

	Local lOk			:= .F.
	Local lCreado		:= .F.
	Local cSemaforo		:= ''
	Local nArchivo		:= 0

	Public _PaCalcIva	:=	{}

	Private cLisDep	:= GetMV("MV_MXDEPFI") //Lista de codigos de Claves de pedimento, que ingresan a Deposito fiscal
	Private cLisExt	:= GetMV("MV_MXEXTRA") //Lista de codigos de Claves de pedimento, que son para extracción de Deposito Fiscal
	Private cLisRec	:= GetMV("MV_MXRECTI") //Lista de codigos de Claves de pedimento, que son para Rectificaciones
	Private cTESmovI	:= GetMV("MV_MXTESMI")//Codigo de Tipo de  movimiento interno, generados para la factura de impuestos y los incrementables

	Private nTipoAcc	:= nOpcion

	Private lPermNegat		:= GetMV('MV_ESTNEG') == 'S'
	Private lMX01Ext			:= .F.
	Private lMX01Dep			:= .F.
	Private lMX01Rec			:= .F.
	Private lMSHelpAuto		:= .F. //Variable para las rutina automatica
	Private lAutoErrNoFile	:= .T. //Variable para las rutina automatica

	Private aLogErro	:= {}
	Private aStatus		:= {'', '', ''}
	Private aProvMT447B	:= {}
	Private aItemsPedi	:= {}
	Private lAutoTeste	:= IsBlind()
	Private nNumDocGen	:= 0 //Variable utilizada para almacenar numero de facturas generadas

	cDocTipo := '' //Se usa en la funcion de la generacion de la factura de impuestos

	If !FreeForUse("RSC",xFilial("RSC")+RSC->RSC_NUMPED)   //Verifica que no este siendo usado por otro usuario
		Return
	Endif

	If AllTrim(RSC->RSC_CVEPED) $ cLisExt  //Verifica si se trata de una extraccion
		lMX01Ext := .T.
	EndIf
	If AllTrim(RSC->RSC_CVEPED) $ cLisDep  //Verifica si se trata de un pedimento que va a deposito fiscal
		lMX01Dep := .T.
	EndIf

	If AllTrim(RSC->RSC_CVEPED) $ cLisRec  //Verifica si se trata de un pedimento de rectificacion
		lMX01Rec := .T.
	EndIf

	If !MT447BVLDDATOS()
		_PaCalcIva := Nil
		Return
	EndIf

	cSemaforo := AllTrim( GetSrvProfString("Startpath",""))+"GenPedimento.txt"
	if !lAutoTeste
		If File(cSemaforo)  //Si el archivo ya existe
			If !MsgYesNo(STR0001) //"La rutina esta siendo utilizada por otro usuario y si la contabilidad esta On-Line, puede demorar varios minutos. ¿Desea continuar?"
				lCreado := .F.
				Return
			Else
				lCreado := .T.
			EndIf
		Else
			nArchivo := MSfCreate(cSemaforo,0)
			FWrite(nArchivo,STR0002) //"En uso la rutina de Generacion o eliminacion de Documentos de la opcion de Pedimentos"
			fClose(nArchivo)
			lCreado := .T.
		EndIf
	endif

	DBSelectArea("SB1")
	DBSelectArea("SB2")
	DBSelectArea("SD3")
	DBSelectArea("SF1")
	DBSelectArea("SD1")

	If nTipoAcc == 3 //incluir facturas
		Processa({||lOk := ProcFacturas()},OemToAnsi(STR0003),STR0004,.T.)  //OemToAnsi("Procesando facturas de Mercancia y Gastos...  "),"Espere ..."
		If lOk
			Aviso("",STR0005+RSC->RSC_facimp+" "+RSC->RSC_serimp+STR0006,{STR0007},1) //"Factura(s) generada(s) con exito. Se genero tambien la factura "+RSC->RSC_facimp+" "+RSC->RSC_serimp+" por los impuestos del pedimento.",{"Ok"}
		EndIf
	Else //Eliminar facturas
		Processa({||lOk := EliFacturas()},OemToAnsi(STR0008),STR0004,.T.) //OemToAnsi("Cancelando...  "),"Espere ..."
		If lOk
			Aviso("",STR0009,{STR0007},1) //"Factura borradas  con exito.",{"Ok"}
		EndIf
	EndIf

	_PaCalcIva := Nil

	If lCreado
		FErase(cSemaforo)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT447BVLDDATOS  ºAutor  ³Gpe Santacruz       ºFecha ³  12/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida los datos antes de comenzar la generacion de documentos.  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ MT447BVLDDATOS()                                                 º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ Nenhum                                                           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ Importaciones -Mexico-                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447BVLDDATOS()

	Local lRet 	:= .T.

	Local cPedOri	:= ''
	Local cF		:= GetMV("MV_MXSECFI") //Consecutivo de facturas para Impuestos
	Local cC		:= Getmv("MV_MXCPFI") //Codigo de condicion de pago
	Local cT		:= Getmv("MV_MXTESIM") //Codigo de TES para la factura de impuestos de importacion "208"
	Local cfilse2	:= ''

	LocaL nRegTmp := 0
	Local lAutomato := isBlind()
	
	If Empty(cF)
		msgAlert(STR0010) //"El parametro MV_MXSECFI esta vacio, debe contener el consecutivo de la Factura de Impuestos de Importación"
		lRet := .F.
	EndIf

	If Empty(cC)
		msgAlert(STR0011) //"El parametro MV_MXCPFI esta vacio, debe contener el codigo de condición de pago que llevará la Factura de Impuestos de Importación"
		lRet := .F.
	Else
		SE4->(DBSetOrder(1))
		If !SE4->(DBSeek(xFilial("SE4")+AllTrim(cC)))
			MSGALERT(STR0012) //"El condigo de Condición de Pago  contenida en el parametro MV_MXCPFI, no existe en el catalogo!, Verifique..."
			lRet := .F.
		EndIf
	EndIf

	If Empty(cT)
		msgAlert(STR0013) //"El parametro MV_MXTESIM esta vacio, debe contener el codigo de TES que llevará la Factura de Impuestos de Importación"
		lRet := .F.
	Else
		SF4->(DBSetOrder(1))
		If !SF4->(DBSeek(xFilial("SF4")+AllTrim(cT)))
			MSGALERT(STR0014) //"El condigo de TES contenido en el parametro MV_MXTESIM, no existe en el catalogo de TES!, Verifique..."
			lRet := .F.
		EndIf
	EndIf


	If Empty(cTESmovI)
		msgAlert(STR0015) //"El codigo de tipo de  movimiento interno no esta especificado, revise el parametro MV_MXTESMI"
		lRet := .F.
	Else
		If val(cTESmovI) >= 500
			msgAlert(STR0016) //"El codigo de tipo de  movimiento interno, para generar movimiento internos debe ser  de entrada, revise el parametro MV_MXTESMI"
			lRet := .F.
		Else
			SF5->(DBSetOrder(1))
			If !SF5->(DBSeek(xFilial("SF5")+AllTrim(CTESMOVI)))
				MSGALERT(STR0017) //"El codigo de tipo de  movimiento interno contenido en el parametro MV_MXTESMI, no existe en el catalogo de Tipos de Movimiento!, Verifique..."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If nTipoAcc == 3 //incluir
		If RSC->RSC_STATUS == '2'
			MsgAlert(STR0018) //"Este pedimento ya generó toda la documentación correspondiente!! Seleccione otro."
			lRet := .F.
		EndIf

		If RSC->RSC_STATUS == '1'
			MsgAlert(STR0019) //"Este pedimento ya generó algunos documentos, primero Eliminelos y vuelva a intentar."
			lRet := .F.
		EndIf

		If lMX01Ext
			cPedOri := RSC->RSC_PEDORI
			nRegTmp := RSC->(RECNO())
			RSC->(DBSetOrder(1))
			If RSC->(DBSeek(xFilial("RSC")+cPedOri))
				If RSC->RSC_STATUS <> '2'
					MsgAlert(STR0020) //"El pedimento origen no ha generado documentos..."
					lRet := .F.
				EndIf
			EndIf
			RSC->(DBGoTo(nRegTmp))
		EndIf

		DBSelectArea("RSI")
		RSI->(DBSetOrder(1))
		If !RSI->(DBSeek(xFilial("RSI")+RSC->RSC_NUMPED))
			MsgAlert(STR0021) //"No hay calculo de costos en el pedimento seleccionado"
			lRet := .F.
		EndIF

		DBSelectArea("DB9")
		DB9->(DBSetOrder(1))
		If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
			If Empty(DB9->DB9_PROV)
				MsgAlert(STR0022) //"No hay codigo de proveedor asociado al Agente aduanal!"
				lRet := .F.
			EndIf
		EndIf

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida que todos  los items de Mercancia tengas impuestos registrados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		RSE->(DBSetOrder(1))
		RSF->(DBSetOrder(1))
		RSG->(DBSetOrder(1))

		If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED))
			Do While !RSE->(Eof()) .And. xFilial("RSE")+RSC->RSC_NUMPED == RSE->RSE_FILIAL+RSE->RSE_NUMPED

				If !RSF->(DBSeek(xFilial("RSF")+RSC->RSC_NUMPED+RSE->RSE_ITEM))
					MsgAlert(STR0023)  //"Existen facturas sin registro de partidas!"
					lRet := .F.
					Exit
				Else
					If RSE->RSE_tipo == '1'
						Do While !RSF->(Eof()) .And. xFilial("RSF")+RSC->RSC_NUMPED+RSE->RSE_ITEM==RSF->RSF_FILIAL+RSF->RSF_NUMPED+RSF->RSF_ITEDOC
							RSG->(DBGoTop())
							If !RSG->(DBSeek(xFilial("RSG")+RSC->RSC_NUMPED+RSE->RSE_FACT+RSE->RSE_SERIE+RSE->RSE_PROV+RSE->RSE_TDA+RSF->RSF_ITEM))
								MsgInfo(STR0076) //"Hay facturas sin registro de Impuestos de Importación. Informe los Impuestos e intente nuevamente."
								lRet := .F.
								Exit
							Else
								If Empty(RSG->RSG_FRACAR)
									MsgInfo(STR0077) //"Hay Ítems de mercancía sin Fracción Arancelaria. Informe la Fracción Arancelaría e intente nuevamente."
									lRet := .F.
									Exit
								EndIf
							EndIf
							RSF->(DBSkip())
						EndDo
					EndIf
				EndIf

				//Valida que los productos de una extraccin de factura, exista en las facturas previamente registrada por la opcion de facturas de entrada
				If AllTrim(RSE->RSE_EXTFAC) == 'EF'
					SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					RSF->(DBSeek(xFilial("RSF")+RSC->RSC_NUMPED+RSE->RSE_ITEM))
					Do While !RSF->(Eof()) .And. RSC->RSC_NUMPED+RSE->RSE_ITEM ==RSF->RSF_NUMPED+RSF->RSF_ITEDOC
						If !SD1->(DBSeek(SD1->(xFilial("SD1")+RSE->RSE_FACT+RSE->RSE_SERIE+RSE->RSE_PROV+RSE->RSE_TDA+RSF->RSF_PRODUC	)))
							MSGALERT(STR0026+RSE->RSE_FACT+" "+RSE->RSE_SERIE+STR0027) //"Verifique los productos de la factura de extraccion "+RSE->RSE_FACT+" "+RSE->RSE_SERIE+", existan en la factura registrada en compras!."
							lRet :=.F.
							Exit
						Else
							aAdd(aItemsPedi, {SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM})
						EndIf
						RSF->(DBSkip())
					EndDo
				EndIf

				If !lRet
					Exit
				EndIf
				RSE->(DBSkip())
			EndDo
		EndIf

		If lRet
			If !lAutomato
				If !MsgYesNo(STR0028)  //"Generar las facturas de entrada y afectar los costos?"
					Return
				EndIf
			EndIf
		EndIf

	Else //Borrar
		If Empty(RSC->RSC_STATUS)
			MsgInfo(STR0029) //"Pedimento abierto, no necesita hacer uso de esta opción.."
			Return
		EndIf
		If lMX01Dep //Si es un pedimento a deposito fiscal y es eliminar documentos
			cPedOri	:= RSC->RSC_NUMPED
			nRegTmp	:= RSC->(RECNO())
			RSC->(DBSetOrder(2))
			If RSC->(DBSeek(xFilial("RSC")+cPedOri))
				Do While !RSC->(Eof()) .And.   AllTrim(cPedOri) == AllTrim(RSC->RSC_PEDORI) .And. xFilial("RSC")==RSC->RSC_filial
					If RSC->RSC_STATUS == '2'
						MsgAlert(STR0030) //"El pedimento seleccionado, tiene extracciones con documentacion generada..."
						lRet := .F.
						Exit
					EndIf
					RSC->(DBSkip())
				EndDo
			EndIf
			RSC->(DBSetOrder(1))
			RSC->(DBGoTo(nRegTmp))
		EndIf

		//Verifica que no tengan pagos las facturas
		If !lMX01Ext
			cfilse2 := xFilial("SE2")
			SE2->(DBSetOrder(6))
			RSE->(DBSetOrder(1))
			If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED))
				Do While !RSE->(Eof()) .And.   AllTrim(	RSC->RSC_NUMPED)==AllTrim(RSE->RSE_NUMPED)  .And. xFilial("RSE")==RSE->RSE_filial
					If Empty(RSE->RSE_extfac)
						If SE2->(DBSeek(cfilse2+RSE->RSE_prov+RSE->RSE_tda+RSE->RSE_serie+RSE->RSE_fact))
							Do While !SE2->(Eof()) .And. SE2->e2_filial+SE2->e2_fornece+SE2->e2_loja+SE2->e2_prefixo+SE2->e2_num==cfilse2+RSE->RSE_prov+RSE->RSE_tda+RSE->RSE_serie+RSE->RSE_fact
								If !Empty(SE2->e2_baixa) .And. !M447VldCon(SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO) //Valida que el título no haya sido generado con baja automática
									lRet := .F.
									MsgAlert(STR0031) //"Existen algunas facturas con pagos y no se permitira eliminar los documentos!"
									Exit
								EndIf
								SE2->(DBSkip())
							EndDo
						EndIf
					EndIf
					If !lRet
						Exit
					EndIf
					RSE->(DBSkip())
				EndDo
			EndIf
			//Verifica que la factura de impuestos no tenga pagos
			If lRet
				cProv	:= ''
				cTda	:= ''
				DB9->(DBSetOrder(1))
				If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
					cProv	:= DB9->DB9_PROV
					cTda	:= DB9->DB9_TDA
				EndIf
				If SE2->(DBSeek(cfilse2+cProv+cTda+RSC->RSC_SERIMP+RSC->RSC_facIMP))
					Do While !SE2->(Eof()) .And. SE2->e2_filial+SE2->e2_fornece+SE2->e2_loja+SE2->e2_prefixo+SE2->e2_num==cfilse2+cProv+cTda+RSC->RSC_SERIMP+RSC->RSC_facIMP
						If !Empty(SE2->e2_baixa) .And. !M447VldCon(SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO) //Valida que el título no haya sido generado con baja automática
							lRet := .F.
							MsgAlert(STR0032) //"La factura de impuestos tiene pagos y no se permitira eliminar los documentos!"
							Exit
						EndIf
						SE2->(DBSkip())
					EndDo

				EndIf
			EndIf
		EndIf
		
		/*
		* Valida que los productos de una extraccin de factura, 
		* existan en las facturas previamente registrada por la 
		* opcion de facturas de entrada; si existen se almacena en aItemsPedi.
		*/
		RSE->(DBSetOrder(1)) //RSE_FILIAL+RSE_NUMPED+RSE_FACT+RSE_SERIE+RSE_PROV+RSE_TDA
		If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED))
			While !RSE->(Eof()) .And. xFilial("RSE")+RSC->RSC_NUMPED == RSE->RSE_FILIAL+RSE->RSE_NUMPED
				If AllTrim(RSE->RSE_EXTFAC) == 'EF' //Valida que sean Extracciones de Factura
					SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					RSF->(DBSeek(xFilial("RSF")+RSC->RSC_NUMPED+RSE->RSE_ITEM))
					While !RSF->(Eof()) .And. RSC->RSC_NUMPED+RSE->RSE_ITEM == RSF->RSF_NUMPED+RSF->RSF_ITEDOC
						If SD1->(DBSeek(SD1->(xFilial("SD1")+RSE->RSE_FACT+RSE->RSE_SERIE+RSE->RSE_PROV+RSE->RSE_TDA+RSF->RSF_PRODUC)))
							aAdd(aItemsPedi, {SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM})
						EndIf
						RSF->(DBSkip())
					EndDo
				EndIf
				RSE->(DBSkip())
			EndDo
		EndIf
		
		If lRet
			If MsgYesNo(STR0033) //"¿Eliminar las facturas generadas por el pedimento?"
				Return .T.
			Else
				Return .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcFacturas    ºAutor  ³Gpe Santacruz       ºFecha ³  12/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida los datos antes de comenzar la generacion de documentos.  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ ProcFacturas()                                                   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ Nenhum                                                           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ Importaciones -Mexico-                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcFacturas()

	Local lGenero		:= .F.
	Local lBan			:= .F.
	Local lBien			:= .T.
	Local lGenFac		:= .F.

	Local cFilSF1		:= ""
	Local cAliasRSE		:= ""
	Local cTipo2		:= ''
	Local cStatus		:= ''
	Local nCont			:= 0
	Local cIdMetMedA	:= "compras-protheus_cantidad-de-facturas-generadas-por-pedimento_average"
	Local cSubRutMet	:= "media-facturas-generadas-por-pedimento"

	Private aRecsSF1	:= {}

	DBSelectArea("RSE")
	DBSelectArea("RSF")
	DBSelectArea("SF4")
	DBSelectArea("SD1")
	DBSelectArea("SF1")

	CFILSF1 := xFilial("SF1")

	If RSC->RSC_STATUS == '1'
		aStatus[1]:= 'OK'
	EndIf

	If lMX01Rec //Si es una retificacion
		If MATA447C()
			If Len(aLogErro) ==0
				Reclock("RSC",.F.)
				RSC->RSC_STATUS:= "2"
				RSC->(MSUNLOCK())
			EndIf
		EndIf
	Else
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Selecciona las facturas y sus items, del pedimento seleccionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		M447BSELECT(@cAliasRSE)
		COUNT To nMax
		ProcRegua (nMax)
		(cAliasRSE)->(DBGoTop())
		nCont := 0
		Do While !(cAliasRSE)->(Eof())
			cFac := (cAliasRSE)->RSE_FACT
			cSer := (cAliasRSE)->RSE_Serie

			cTipo2:= IIf((cAliasRSE)-> RSE_TIPO $ "1" , "N" , "C" )

			If SF1->(dbSeek(CFILSF1+(cAliasRSE)->RSE_FACT + (cAliasRSE)->RSE_Serie + (cAliasRSE)->RSE_PROV + (cAliasRSE)->RSE_TDA+cTipo2, .F.))
				If nTipoAcc == 3

					Aviso("", STR0034 + (cAliasRSE)->RSE_FACT + (cAliasRSE)->RSE_Serie + STR0035 + (cAliasRSE)->RSE_PROV + (cAliasRSE)->RSE_TDA + STR0036, {STR0007}) //"Factura duplicada","La factura "," del Proveedor :"," ya existe y no puede ser generado ","ok"
					cFilTMP := (cAliasRSE)->RSE_FILIAL
					cIteDoc := (cAliasRSE)->RSF_ITEDOC
					cTipTmp := (cAliasRSE)->RSE_TIPO
					Do While !(cAliasRSE)->(Eof()) .And. CFILTMP==(cAliasRSE)->RSE_FILIAL .And. cIteDoc==(cAliasRSE)->RSF_ITEDOC .And. cTipTmp==(cAliasRSE)->RSE_TIPO
						IncProc()
						(cAliasRSE)->(DBSkip())
					EndDo
					lBien := .T.
					Loop
				EndIf
			Else
				If nTipoAcc == 5
					cFilTMP := (cAliasRSE)->RSE_FILIAL
					cIteDoc := (cAliasRSE)->RSF_ITEDOC
					cTipTmp := (cAliasRSE)->RSE_TIPO
					Do While !(cAliasRSE)->(Eof()) .And. CFILTMP == (cAliasRSE)->RSE_FILIAL .And. cIteDoc == (cAliasRSE)->RSF_ITEDOC .And. cTipTmp == (cAliasRSE)->RSE_TIPO
						IncProc()
						(cAliasRSE)->(DBSkip())
					EndDo
					Loop
				EndIf
			EndIf

			lGenFac := GenFacEnt(cAliasRSE)
		
			If lBien .And. !lGenFac
				lBien := .F.
			EndIf

		EndDo

		(cAliasRSE)->(DBCloseArea())

		If lBien //Si todas las facturas de Mercancia y Gastos bien procesadas
			lBan := .T.
			ProcRegua(3)
			If !lMX01Ext
				MT447BGENMOVINT("I",.T.) //1ero lo borra
				lBan := MT447BGENMOVINT("I",.F.) //Genera moviminto interno de los incrementables
			EndIf

			If lBan
				IncProc()
				If !GenFacPed() //Genera la factura de entrada de impuestos
					lBan := .F.
				Else
					lBan := .T.
					IncProc()
					If !MT447BTRASPASO(.F.)  //Hace traspasos, para las extracciones por pedimento o por extraccion de factura
						lBan := .F.
					Else
						IncProc()
						lBan := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If (lBan, cStatus := '2', cStatus := '1')
			Reclock("RSC",.F.)
			RSC->RSC_STATUS := cStatus
			RSC->(MSUNLOCK())
		EndIf

		If Len(aLogErro) > 0
			If MsgYesNo(STR0037) //"Errores encotrados, ¿Quiere verificar el LOG?"
				ImprimeLog()
			EndIf
		Else
			/*
			* Se valida que si no hubo generacion de Facturas de Entrada,
			* se realice la actualizacion del campo D1_PEDIM para
			* Facturas de Extraccion contenidas en el Pedimento.
			*/
			If !lGenFac
				MT447BActI(RSC->RSC_NUMPED, nTipoAcc)
			EndIf
			If lBien
				If VldLibMet()
					cSubRutMet += IIf(lAutoTeste, "_auto", "")
					FWCustomMetrics():setAverageMetric(cSubRutMet, cIdMetMedA, nNumDocGen, /*dDateSend*/, /*nLapTime*/, "MATA447B")
				EndIf
				MsgInfo(STR0038) //"Proceso finalizado sin Errores!
			EndIf
			
		EndIf

Return lGenero

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GenFacEnt       ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera facturas de enetrada con la Rutina automatica             º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ ProcFacturas(cExp1)                                              º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ cExp1.- Alias del archivo fuente                                 º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ MATA447B                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenFacEnt(cAliasRSE)

	Local lRet		:= .F.
	Local lGrabo	:= .T.

	Local aCabs		:= {}
	Local aItens	:= {}

	Local cAlmacen	:= ''
	Local cTipo		:= IIf((cAliasRSE)->RSE_TIPO=="1","N","C")
	Local cFilRSE	:= xFilial("RSE")
	Local cFilRSF	:= xFilial("RSF")
	Local cFilRSN	:= xFilial("RSN")
	Local cFilSD1	:= xFilial("SD1")
	Local cFilRSM	:= xFilial("RSM")
	Local cFilRSC	:= xFilial("RSC")
	Local cTipGas	:= ''
	Local cTip13	:= '13'
	Local cTip14	:= '14'
	Local cTipSD1	:= ''
	Local cUUID		:= ''
	Local cRutDoc	:= ""
	Local aMasCabs	:= {}
	Local aMasItems	:= {}

	Local nValDesp	:= 0
	Local nj		:= 0
	Local nx		:= 0

	Local dFecTim	:= CTOD("  /  /  ")

	Local lM447Bfga := ExistBlock("M447BFGA")

	DBSelectArea("SC7")
	DBSelectArea("SD1")
	DBSelectArea("SF1")
	DBSelectArea("RSM")
	DBSetOrder(1)

	DBSelectArea("RSN")
	DBSetOrder(1)

	aAdd(aCabs, {"F1_FILIAL " , xFilial('SF1')  ,  Nil})
	aAdd(aCabs, {"F1_TIPO"    , cTipo           ,  Nil})
	aAdd(aCabs, {"F1_FORMUL"  , "N"             ,  Nil})
	aAdd(aCabs, {"F1_DOC"     , (cAliasRSE)->RSE_FACT   ,  Nil})
	aAdd(aCabs, {"F1_SERIE"   , (cAliasRSE)->RSE_Serie  ,  Nil})
	aAdd(aCabs, {"F1_EMISSAO" , (cAliasRSE)->RSE_EMISIO ,  Nil})
	aAdd(aCabs, {"F1_FORNECE" , (cAliasRSE)->RSE_PROV   ,  Nil})
	aAdd(aCabs, {"F1_LOJA"    , (cAliasRSE)->RSE_TDA    ,  Nil})
	aAdd(aCabs, {"F1_ESPECIE" , "NF"            ,  Nil})
	aAdd(aCabs, {"F1_COND"    , (cAliasRSE)->RSE_CONPGO   ,  Nil})
	aAdd(aCabs, {"F1_NATUREZA", "", Nil})

	aAdd(aCabs, {"F1_MOEDA"   , (cAliasRSE)->RSE_MONED,  Nil})
	aAdd(aCabs, {"F1_TXMOEDA" , (cAliasRSE)->RSE_TASA*(cAliasRSE)->RSE_TC ,  Nil})
	aAdd(aCabs, {"F1_DTDIGIT" , dDataBase       ,  Nil})

	aAdd(aCabs, {"F1_DESCONT" , (cAliasRSE)->RSE_DESCto ,  Nil})
	aAdd(aCabs, {"F1_PESOL"   , (cAliasRSE)->RSE_PESOL  ,  Nil})

	If (cAliasRSE)->(FieldPos("RSE_UUID")) > 0
		
		cRutDoc  := POSICIONE("RSE",1,XFILIAL("RSE")+(cAliasRSE)->RSE_NUMPED+(cAliasRSE)->RSE_FACT+(cAliasRSE)->RSE_SERIE+(cAliasRSE)->RSE_PROV+(cAliasRSE)->RSE_TDA,"RSE_RUTDOC")
		
		aAdd(aCabs, {"F1_UUID"    , (cAliasRSE)->RSE_UUID         ,  Nil})
		aAdd(aCabs, {"F1_FECTIMB" , STOD((cAliasRSE)->RSE_FECTIMB),  Nil})
		aAdd(aCabs, {"F1_RUTDOC"  ,cRutDoc       ,  Nil})

		cUUID    := (cAliasRSE)->RSE_UUID
		dFecTim  := STOD((cAliasRSE)->RSE_FECTIMB)
	Endif

	//Permite agregar mas campos que van de la RSE y SF1
	If (ExistBlock("M447BSF1"))
		aMasCabs := ExecBlock("M447BSF1",.F.,.F.,{cAliasRSE})
		For nj := 1 To Len(aMasCabs)
			aAdd(aCabs,{})
			aCabs[Len(aCabs)] := aMasCabs[nj]
		Next
	EndIf

	cFac	:= (cAliasRSE)->RSE_FACT
	cSer	:= (cAliasRSE)->RSE_Serie
	cPrv	:= (cAliasRSE)->RSE_PROV
	cTda	:= (cAliasRSE)->RSE_TDA

	cFilTMP	:= (cAliasRSE)->RSE_FILIAL
	cIteDoc	:= (cAliasRSE)->RSE_ITEM
	cTipTmp	:= (cAliasRSE)->RSE_TIPO

	If (cAliasRSE)->RSF_TIPO == '1' //Factura de  Mercancia
		aAdd(aCabs, {"F1_TIPODOC" , "10" ,  Nil})
		
		Do While !(cAliasRSE)->(Eof()) .And. CFILTMP == (cAliasRSE)->RSE_FILIAL .And. cIteDoc==(cAliasRSE)->RSF_ITEDOC .And. cTipTmp==(cAliasRSE)->RSF_TIPO

			cCF := IIF(!Empty((cAliasRSE)->F4_CF),(cAliasRSE)->F4_CF,"")
			
			aAdd(aItens, {})
			aAdd(aItens[Len(aItens)] , {"D1_FILIAL"  , xFilial("SD1")  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_DOC"     , cFac          , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_SERIE"   , cSer       , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_FORNECE" , (cAliasRSE)->RSE_PROV , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_LOJA"    , (cAliasRSE)->RSE_TDA   , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_EMISSAO" , (cAliasRSE)->RSE_EMISIO , Nil})
			AAdd(aItens[Len(aItens)] , {"D1_DTDIGIT" , dDataBase       , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_ESPECIE" , "NF"            , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_TIPODOC" , "10"            , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_TIPO"    , "N"             , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_FORMUL"  , "N"             , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_PESO"    , (cAliasRSE)->RSE_PESOL  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_ITEM"    , (cAliasRSE)->RSF_ITEM   , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_COD"     , (cAliasRSE)->RSF_PRODUC , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_UM"      , (cAliasRSE)->RSF_UM     , Nil})

			If !Empty((cAliasRSE)->RSF_PEDIDO)
				aAdd(aItens[Len(aItens)] , {"D1_PEDIDO"  , (cAliasRSE)->RSF_PEDIDO , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_ITEMPC"  , (cAliasRSE)->RSF_ITEMPC , Nil})
			EndIf
			aAdd(aItens[Len(aItens)] , {"D1_QUANT"   , (cAliasRSE)->RSF_CANT  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_VUNIT"   , (cAliasRSE)->RSF_PRECIO  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_TOTAL"   , (cAliasRSE)->RSF_TOTAL    , Nil}) //

			aAdd(aItens[Len(aItens)] , {"D1_LOCAL"   , (cAliasRSE)->RSF_ALMACE  , Nil})
			If !Empty((cAliasRSE)->RSF_PEDIDO)
				aAdd(aItens[Len(aItens)] , {"D1_PEDIDO"  , (cAliasRSE)->RSF_PEDIDO , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_ITEMPC"  , (cAliasRSE)->RSF_ITEMPC , Nil})
			EndIf
			aAdd(aItens[Len(aItens)] , {"D1_TES"     , (cAliasRSE)->RSF_TES    , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_CF"      , cCF             , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_CC"      , (cAliasRSE)->RSF_CC     , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_CONTA"   , (cAliasRSE)->RSF_CONTA  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_ITEMCTA" , (cAliasRSE)->RSF_ITCTA  , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_CLVL"    , (cAliasRSE)->RSF_CLVL   , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_VALDESC" , (cAliasRSE)->RSF_VLDESC , Nil})
			aAdd(aItens[Len(aItens)] , {"D1_PEDIM"   , RSC->RSC_NUMPED, Nil})

			//Permite agregar mas campos que van de la RSF y SF1
			If (ExistBlock("M447BSD1"))
				aMasItems := ExecBlock("M447BSD1",.F.,.F.,{cAliasRSE})
				For nj := 1 To Len(aMasItems)
					aAdd(aItens[Len(aItens)] , aMasItems[nj])
				Next
			EndIf

			IncProc(STR0039+cFac+cSer) //"Procesando factura "

			DBSelectArea((cAliasRSE))
			(cAliasRSE)->(DBSkip())
		EndDo
	Else //Factura de gastos
		IncProc(STR0039+cFac+cSer) //"Procesando factura "
		cCF			:= ''
		nValDesp	:= 0
		cTesDesp	:= ''
		dFecEmis	:= (cAliasRSE)->RSE_EMISIO
		cTesDesp	:= (cAliasRSE)->RSF_TES
		cCF			:= (cAliasRSE)->F4_CF
		cTipGas	:= ''

		If lM447Bfga //Si existe el PE M447BFGA se obtienen los campos extra y se almacenan en el array aMasItems
			aMasItems := ExecBlock("M447BFGA",.F.,.F.,{cAliasRSE})
		EndIf

		Do While !(cAliasRSE)->(Eof()) .And. CFILTMP == (cAliasRSE)->RSE_FILIAL .And. cIteDoc == (cAliasRSE)->RSF_ITEDOC //010313 .And. cTipTmp==(cAliasRSE)->RSE_TIPO puede haber varios tipos, solo en el caso de gastos
			cTipGas := (cAliasRSE)->RSF_TIPO
			(cAliasRSE)->(DBSkip())
		EndDo

		If cTipGas $ "2/5"
			aAdd(aCabs, {"F1_TIPODOC" , "14" ,  Nil})
			cTipSD1 := cTip14
		Else
			aAdd(aCabs, {"F1_TIPODOC" , "13" ,  Nil})
			cTipSD1 := cTip13
		EndIf

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Genera los items de la factura de gastos de acuerdo a los productos que estan siendo costeados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		SD1->(DBSetOrder(1))
		RSN->(DBGoTop())

		If RSN->(DBSeek(CFILRSN+RSC->RSC_NUMPED+cFac+cSer+cPrv+cTda))
			CITEM := StrZero(0,TamSX3('D1_ITEM')[1])
			Do While !RSN->(Eof()) .And. RSN->RSN_FILIAL+RSN->RSN_NUMPED+RSN->RSN_FACT+RSN->RSN_SERIE+RSN->RSN_PROV+RSN->RSN_TDA==CFILRSC+RSC->RSC_NUMPED+cFac+cSer+cPrv+cTda
			
				//If SD1->(DBSeek(CFILSD1+RSN->RSN_FACORI+RSN->RSN_SERORI+RSN->RSN_PROORI+RSN->RSN_TDAORI+RSN->RSN_PROD +RSN->RSN_ITEM))
				If SD1->(DBSeek(CFILSD1+RSN->RSN_FACORI+RSN->RSN_SERORI+RSN->RSN_PROORI+RSN->RSN_TDAORI+RSN->RSN_PROD )) 
				    if RSN->RSN_GASTOS	>= .01 //Si viene en ceros no lo considera

						aAdd(aItens, {})
						cItem := soma1(cItem)
	
						aAdd(aItens[Len(aItens)] , {"D1_FILIAL"  , xFilial("SD1")	, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_DOC"     , cFac          	, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_SERIE"   , cSer       		, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_ITEM"    , CITEM   			, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_FORNECE" , cPrv 				, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_LOJA"    , cTda   			, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_EMISSAO" , dFecEmis			, Nil})
						AAdd(aItens[Len(aItens)] , {"D1_DTDIGIT" , dDataBase		, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_ESPECIE" , "NF"				, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_TIPODOC" , cTipSD1			, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_TIPO"    , "C"				, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_FORMUL"  , "N"				, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_PESO"    , SD1->D1_PESO		, Nil})
	
						aAdd(aItens[Len(aItens)] , {"D1_COD"     , RSN->RSN_PROD	, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_UM"      , SD1->D1_UM		, Nil})
						aAdd(aItens[Len(aItens)] , {"D1_VUNIT"   , RSN->RSN_GASTOS	, Nil})  //sin impuesto
						aAdd(aItens[Len(aItens)] , {"D1_TOTAL"   , RSN->RSN_GASTOS	, Nil}) //sin impuesto
	
						cAlmacen := ''
						If lMX01Ext
							If RSM->(DBSeek(CFILRSM+RSC->RSC_NUMPED+RSN->RSN_FACORI+RSN->RSN_SERORI+RSN->RSN_PROORI+RSN->RSN_TDAORI+RSN->RSN_ITEM+RSN->RSN_PROD ))
								cAlmacen := RSM->RSM_ALMACE
							EndIf
							aAdd(aProvMT447B,{RSN->RSN_FACORI,RSN->RSN_SERORI,RSN->RSN_PROORI,RSN->RSN_TDAORI,RSN->RSN_ITEM} )    //se usa en la rutina automatica
						Else
							If RSE->(DBSeek(cFilRSE+RSC->RSC_NUMPED+RSN->RSN_FACORI+RSN->RSN_SERORI+RSN->RSN_PROORI+RSN->RSN_TDAORI))
								If RSE->RSE_EXTFAC == 'EF'
									If RSF->(DBSeek(cFilRSF+RSC->RSC_NUMPED+RSE->RSE_ITEM+RSN->RSN_ITEM))
										cAlmacen := RSF->RSF_ALMACE
									EndIf
								Else
									cAlmacen := SD1->D1_LOCAL
								EndIf
								aAdd(aProvMT447B,{RSN->RSN_FACORI,RSN->RSN_SERORI,RSN->RSN_PROORI,RSN->RSN_TDAORI,RSN->RSN_ITEM} )    //se usa en la rutina automatica
							Else
								Aviso("","Factura :"+RSN->RSN_FACORI+RSN->RSN_SERORI+RSN->RSN_PROORI+RSN->RSN_TDAORI+ " No encontrada en RSE" ,{STR0007}) //"Factura duplicada","La factura "," del Proveedor :"," ya existe y no puede ser generado ","ok"
							EndIf
						EndIf
						aAdd(aItens[Len(aItens)] , {"D1_LOCAL"   , cAlmacen  , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_NFORI"   , RSN->RSN_FACORI     , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_SERIORI" , RSN->RSN_SERORI  , Nil})
						
				
						aAdd(aItens[Len(aItens)] , {"D1_ITEMORI" , SD1->D1_ITEM    , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_NUMCQ"   , SD1->D1_NUMCQ   , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_CC"      , SD1->D1_CC      , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_CONTA"   , SD1->D1_CONTA   , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_ITEMCTA" , SD1->D1_ITEMCTA , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_CLVL"    , SD1->D1_CLVL    , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_TES"     , RSN->RSN_TES                , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_CF"      , cCF                     , Nil})
						aAdd(aItens[Len(aItens)] , {"D1_PEDIM"   , RSC->RSC_NUMPED, Nil})

						//Permite agregar mas campos que van de la RSF a SD1 para Factura de Gastos
						If len(aMasItems) > 0
							For nj := 1 To Len(aMasItems)
								aAdd(aItens[Len(aItens)] , aMasItems[nj])
							Next
						EndIf
					endif
				Else
					aAdd(aLogErro, {STR0040+RSN->RSN_FACORI+" "+RSN->RSN_SERORI+STR0041}) //"No encontro la factura de Mercancia ",", la factura de gastos puede tener inconsistencias o no se generó!"
				EndIf
				RSN->(DBSkip())
			EndDo
		EndIf
	EndIf

	If  (Len(aCabs) > 0 .And. Len(aItens) > 0)
		BeginTran()
		lMSErroAuto	:= .F.
		MaFisEnd()
		cDocTipo := 'FE' //Factura de entrada

		MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,nTipoAcc)

		If lMSErroAuto
			DisarmTransaction()
			aAdd(aLogErro, {STR0042 + AllTrim(cfac) + " " + cSer + STR0043}) //"Rutina automatica, al generar la Factura "+AllTrim(cfac)+" "+cSer+" encontro los errores : "
			aAutoErro := GETAUTOGRLOG()

			For nx := 1 To Len(aAutoErro)
				aAdd(aLogErro, {aAutoErro[nx]})
			Next
		Else
			lGrabo := .F.
			SF1->(DBSetOrder(1))
			If SF1->(DBSeek(xFilial("SF1")+cFac+cSer+cPrv+cTda)) //ASEGURA QUE REALMENTE HAYA GRABADO  LA FACTURA
				lGrabo := .T.	
			EndIf
			If lGrabo
				// Debe copiar el archivo al servidor en la carptea MV_XMLPRO
				// y guardar esa ruta no la ruta de dónde se tomó el xml
				
				M447CPYFILE(@cRutDoc)
				
				RSE->(DBSetOrder(1))
				If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED+cFac+cSer+cPrv+cTda))
					RecLock("RSE", .F.)
					RSE->RSE_OK:= "S" //IIf (nTipoAcc==3,"S"," ") //Marca la factura como generada en compras
					RSE->(MsUnlock())
				    //Por fallas de actualizacion en la Locxnf es necesario agregar este codigo, cuando sea reparado se puede eliminar
				    //PALIATIVO
					If RSE->(FieldPos("RSE_UUID")) > 0
						Reclock("SF1",.F.)
							SF1->F1_UUID    := cUUID
							SF1->F1_FECTIMB	:= dFecTim
							SF1->F1_RUTDOC  := cRutDoc
						SF1->(MSUNLOCK())
					Endif

					//Debido a fallas de actualización en la Locxnf se agrega este código (solo aplica para los campos de encabezado del PE M447BFGA)
					If Len(aMasCabs) > 0
						Reclock("SF1",.F.)
						For nj := 1 To Len(aMasCabs)
							If SF1->(ColumnPos(AllTrim(aMasCabs[nj][1]))) > 0
								SF1->(FieldPut(ColumnPos(Alltrim(aMasCabs[nj][1])), aMasCabs[nj][2]))
							EndIf
						Next
						SF1->(MSUNLOCK())
					EndIf
				
					//Actualiza el saldo  de la OC con respecto al pedimento
					ActSaldoOC(cFac,cSer,cPrv,cTda)
					
					//Permite afectar mas tablas despues de grabar en SF1, si fuera necesario
					//El puntero esta en RSE y sf1 respectivamente
					If (ExistBlock("M447BF1A"))
						ExecBlock("M447BF1A",.F.,.F.,{"SF1","RSE"})
					EndIf
					
					MT447BActI(RSC->RSC_NUMPED, nTipoAcc)					
				EndIf
				nNumDocGen++ //Variable utilizada para Métrica Average que controla numero de documentos generados.
				lRet:= .T.
			EndIf
			EndTran()
		EndIf
		MsUnlockAll()
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GenFacPed       ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera facturas de Impuestos                                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ ProcFacturas()                                                   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ Niguno                                                           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ MATA447B                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenFacPed()

	Local lRet:= .T.

	Local aCabs		:= {}
	Local aItens	:= {}
	Local aIVAS		:= {}
	Local _aCalcIva	:= {}

	Local cnumfac	:= ''
	Local cFacAnt	:= GetMV("MV_MXSECFI") //Consecutivo de facturas para Impuestos
	Local cSer   	:= ''
	Local cTda   	:= ''
	Local cProv  	:= ''
	Local cFilRSL	:= xFilial("RSL")
	Local cFilRSA	:= xFilial("RSA")
	Local cFilSB1	:= xFilial("SB1")
	Local cCodPgo	:= GetMV("MV_MXCPFI") //Codigo de condicion de pago
	Local cTES   	:= GetMV("MV_MXTESIM") //Codigo de TES para la factura de impuestos de importacion "208"
	Local cCF    	:= ''
	Local cItem  	:= StrZero(0,TamSX3('D1_ITEM')[1]) //Inicia numero de item de la factura
	Local aMasCabs	:= {}

	Local nIvaPed		:= 0
	Local nPosIvaCero	:= 0
	Local nPosIvaNCero	:= 0
	Local nx,nj			:= 0
	Local nIVAItem 		:= 0

	If lMX01Dep //si es pedimento que va deposidot fiscal no genera este tipo de factura
		Return .T.
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica, si ya hay facturas generadas de impuestos, la busca y elimina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	MT447BELIFACPED("N")
	IncProc(STR0044) //"Inicia generación de factura de impuestos "

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida que exista la TES para la factura de impuestos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	DBSelectArea("SF4")
	SF4->(DBSetOrder(1))
	If !SF4->(DBSeek(xFilial("SF4")+CTES))
		aAdd(aLogErro, {STR0045})    //"No existe TES para factura de impuestos verifique el parametro MV_MXTESIM"
		lRet:= .F.
	Else
		cCF := SF4->F4_CF
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida que el codigo de agente aduanal existe en el catalogo de proveedores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cProv	:= ''
	cTda	:= ''
	DB9->(DBSetOrder(1))
	If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
		cProv	:= DB9->DB9_PROV
		cTda	:= DB9->DB9_TDA
	Else
		aAdd(aLogErro, {STR0046+RSC->RSC_AGENTE+" "+STR0047}) //"El codigo de agente "+RSC->RSC_AGENTE+" "+"Tiene codigo de proveedor invalido"
		lRet := .F.
	EndIf

	If !lRet
		Return lRet
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Extrae consecutivo de factura de impuestos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cnumfac := SOMA1(AllTrim(cFacAnt),10)

	PutMV("MV_MXSECFI",AllTrim(cnumfac))

	aAdd(aCabs, {"F1_FILIAL " , xFilial('SF1'), Nil})
	aAdd(aCabs, {"F1_TIPO"    , "N"           , Nil})
	aAdd(aCabs, {"F1_FORMUL"  , "N"           , Nil})
	aAdd(aCabs, {"F1_DOC"     , cnumfac       , Nil})
	aAdd(aCabs, {"F1_SERIE"   ,""             , Nil})
	aAdd(aCabs, {"F1_EMISSAO" , RSC->RSC_FCHPGO,Nil})
	aAdd(aCabs, {"F1_FORNECE" , cProv 			,Nil})
	aAdd(aCabs, {"F1_LOJA"    , cTda   			,Nil})
	aAdd(aCabs, {"F1_ESPECIE" , "NF"            ,Nil})
	aAdd(aCabs, {"F1_COND"    , cCodPgo   		,Nil})
	aAdd(aCabs, {"F1_NATUREZA", "",  Nil})
	aAdd(aCabs, {"F1_TIPODOC" , "10"            ,Nil})
	aAdd(aCabs, {"F1_MOEDA"   , 1  				,Nil})
	aAdd(aCabs, {"F1_TXMOEDA" , 1.00 			,Nil})
	aAdd(aCabs, {"F1_DTDIGIT" , dDataBase       ,Nil})
	
	//Permite agregar mas campos que van de la RSE y SF1
	If (ExistBlock("M447BIPE"))
		aMasCabs:={}
		aMasCabs := ExecBlock("M447BIPE",.F.,.F.)
		For nj := 1 To Len(aMasCabs)
			aAdd(aCabs,{})
			aCabs[Len(aCabs)] := aMasCabs[nj]
		Next
	EndIf

	RSA->(DBSetOrder(1))
	SB1->(DBSetOrder(1))
	RSL->(DBSetOrder(1))
	nCanIte := 0

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pasa todos los Imppuestos agrupados del pedimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If RSL->(DBSeek(cFilRSL+RSC->RSC_NUMPED))

		Do While !RSL->(Eof()) .And. cFilRSL+RSC->RSC_NUMPED==RSL->RSL_FILIAL+RSL->RSL_NUMPED
			If Empty(RSL->RSL_CODIMP) .Or. RSL->RSL_IMPORT==0 //El unico registro que no tiene codigo de impuesto es el IVA
				If  Empty(RSL->RSL_CODIMP) .And. RSL->RSL_IMPORT<>0
					nIvaPed:=RSL->RSL_IMPORT
				EndIf
			Else
				cCodPrd	:= ''
				cUm			:= ''
				cAlm		:= ''

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
				//³Extrae como producto, el codigo del impuesto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
				*/
				If RSA->(DBSeek(CFILRSA+RSL->RSL_CODIMP))
					cCodPrd := RSA->RSA_CODPRD
					If SB1->(DBSeek(CFILSB1+cCodPrd))
						cUm		:= SB1->B1_UM
						cAlm	:= SB1->B1_LOCPAD
						aAdd(_aCalcIva,{cCodPrd,0,0,0})
					Else
						aAdd(aLogErro, {STR0048+cCodPrd}) //"No existe el codigo de producto "
					EndIf
				Else
					aAdd(aLogErro, {STR0049+RSL->RSL_CODIMP}) //"No existe el codigo de impuesto "
				EndIf

				aAdd(aItens, {})
				cItem := soma1(cItem)
				aAdd(aItens[Len(aItens)] , {"D1_FILIAL"  , xFilial("SD1"), Nil})
				aAdd(aItens[Len(aItens)] , {"D1_DOC"     , cnumfac       , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_SERIE"   , cSer   , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_FORNECE" , cProv  , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_LOJA"    , cTda   , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_EMISSAO" , RSC->RSC_FCHPGO , Nil})
				AAdd(aItens[Len(aItens)] , {"D1_DTDIGIT" , dDataBase       , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_ESPECIE" , "NF"            , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_TIPODOC" , "10"            , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_TIPO"    , "N"             , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_FORMUL"  , "N"             , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_ITEM"    , cItem   , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_COD"     , cCodPrd , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_UM"      , cUm     , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_QUANT"   , 1       , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_VUNIT"   , RSL->RSL_IMPORT, Nil})
				aAdd(aItens[Len(aItens)] , {"D1_TOTAL"   , RSL->RSL_IMPORT, Nil})
				aAdd(aItens[Len(aItens)] , {"D1_LOCAL"   , cAlm   , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_TES"     , cTes    , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_PEDIM"   , RSC->RSC_NUMPED, Nil})
				aAdd(aItens[Len(aItens)] , {"D1_CF"      , cCF    , Nil})
				aAdd(aItens[Len(aItens)] , {"D1_CIFPROR" , 0, Nil})

				nCanIte++
				IncProc(STR0050+cnumfac+cSer) //"Generando Factura "
			EndIf
			RSL->(DBSkip())
		EndDo

		//Proorates el total del costos CIF entre las partidas generadas (solo las que llevna iva)
		aBasPro := M447BCOSTOCIF()

		For NX := 1 To Len(aITens)
			aItens[nx,Len(aitens[nx]),2]:=ABasPro[2] //guarda el valor de costo CIF ya prorrateado a cad partida
		Next
	EndIf

	If  (Len(aCabs) > 0 .And. Len(aItens)>0)
		//Calculo del iva para la factura
			
		If RSB->(FieldPos("RSB_IVA")) <> 0
		
			aIVAS 			:= ExtBasesIVA()
			nPosIvaCero	:= aScan(aIVAS, {|x| x[1] == 0})
			nPosIvaNCero	:= aScan(aIVAS, {|x| x[1] <> 0})
			nIVAItem := 0
			For nx := 1 To Len(_aCalcIva)
				If nPosIvaNCero <> 0
					_aCalcIva[nx,2]	:= aIVAS[nPosIvaNCero,3]/ (Len(_aCalcIva))
					_aCalcIva[nx,3]	:= aIVAS[nPosIvaNCero,2]/ (Len(_aCalcIva))
					nIVAItem+=_aCalcIva[nx,2]
				EndIf
				If nPosIvaCero<>0
					_aCalcIva[nx,4] := aIVAS[nPosIvaCero,2]/ (Len(_aCalcIva))
				EndIf
			Next
			//Agregar el iva de los impuestos que son a nivel pedimento y que aplican iva
			nIvaPed := nIvaPed - nIVAItem
			nIvaPed := nIvaPed / Len(_aCalcIva)
			
			For nx := 1 To Len(_aCalcIva)
				_aCalcIva[nx,2]	+= nIvaPed
				_aCalcIva[nx,3] := _aCalcIva[nx,2]/(RSC->RSC_IVA / 100)
			Next
		Else
			For nx := 1 To Len(_aCalcIva)
				_aCalcIva[nx,2] := nIvaPed/(Len(_aCalcIva))
				_aCalcIva[nx,3] := _aCalcIva[nx,2]/(RSC->RSC_IVA/100	)
			Next
		EndIf
		_PaCalcIva := _aCalcIva

		BeginTran()

		lMSErroAuto	:= .F. //Variable usada en el MSExecAuto
		MaFisEnd()
		cDocTipo := 'FE' //Factura de entrada

		MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,nTipoAcc)
		If lMSErroAuto
			DisarmTransaction()
			aAdd(aLogErro, {STR0051+AllTrim(cnumfac)+" "+cSer+STR0052}) //"Rutina automatica, al generar la Factura de Impuestos "," encontro los errores : "
			aAutoErro := GETAUTOGRLOG()
			For nx := 1 To Len(aAutoErro)
				aAdd(aLogErro, {aAutoErro[nx]})
			Next
			lRet := .F.
		Else
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Genera movimiento interno³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			Private RSC_FACIMP := cNumFac // para utilizar en generación de póliza contable de movimientos internos de la factura de impuestos de importación
			Private RSC_SERIMP := cSer

			If MT447BGENMOVINT('',.F.)
				reclock("RSC",.F.)
				RSC->RSC_FACIMP := cnumfac
				RSC->RSC_SERIMP := cSer
				RSC->(MSUNLOCK())
			EndIf

			nNumDocGen++ //Variable utilizada para Métrica Average que controla numero de documentos generados.

			EndTran()
		EndIf
		MsUnlockAll()
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M447BGerLog³Autor ³GSantacruz             ³ Data ³23/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera LOG de errores                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones - México                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447BGerLog(lEnd)

	Local cLogFile   := 'PEDIMENTO.LOG'
	Local cString    := ''
	Local cDoc       := AllTrim(RetTitle('RSE_FACT'))
	Local cSerie     := AllTrim(RetTitle('RSE_SERIE'))
	Local nLogHdl    := 0
	Local nX         := 0

	DEFAULT lEnd       := .F.

	If File(cLogFile)
		fErase(cLogFile)
	EndIf

	nLogHdl := MSfCreate(cLogFile, 0)

	If nLogHdl > 0
		cString := Replicate('-', 80) + Chr(13) + Chr(10)
		fWrite(nLogHdl,cString,Len(cString))
		cString := SubStr(cUsuario,7,6) + ', ' + Time() + ', ' + DtoC(Date()) + Chr(13) + Chr(10)
		fWrite(nLogHdl,cString,Len(cString))

		cString := STR0053 + Chr(13) + Chr(10)  // "Facturas que no se generaron : "
		fWrite(nLogHdl,cString,Len(cString))
		If Len(aLogErro) > 0
			cString :=  PadR(cDoc, TamSX3('RSE_FACT')[1])+ '|' + PadR(cSerie, TamSX3('RSE_SERIE')[1]) + Chr(13) + Chr(10)
			fWrite(nLogHdl,cString,Len(cString))
			For nX := 1 To Len(aLogErro)
				cString := aLogErro[nX,1] + '|' + aLogErro[nX,2] + Chr(13) + Chr(10)
				fWrite(nLogHdl,cString,Len(cString))
			Next nX
		EndIf
		fClose(nLogHdl)
	Else
		Help(" ",1,"A143NOTLOG") // "Nao foi possivel realizar a gravacao do LOG de erro referente ao(s) item(ns) do Processo de Importação."
	EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M447BLog  ³Autor  ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica o log dos Itens da Nota Fiscal nao gerados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447BLog()

	Local cDoc       := AllTrim(RetTitle('RSE_FACT'))
	Local cSerie     := AllTrim(RetTitle('RSE_SERIE'))
	Local cVarq      := ''
	Local nAt        := 0
	Local oDlg
	Local oQual

	If Len(aLogErro) > 0
		DEFINE MSDIALOG oDlg TITLE STR0054 From 130,70 To 350,410 OF oMainWnd PIXEL //"Uno o mas items no fueron generados"
		@ 10,13 TO 90,172 LABEL '' OF oDlg  PIXEL
		@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER cDoc, cSerie SIZE 150,62 NOSCROLL OF oDlg PIXEL
		oQual:SetArray(aLogErro)
		oQual:bLine := { || {aLogErro[oQual:nAt,1],aLogErro[oQual:nAt,2]}}
		DEFINE SBUTTON FROM 95,90 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg
	EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447BSELECT     ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecciona por tipo,  las facturas del pedimento                 º±±
±±º          ³                                                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M447BSELECT(cExp1,cExp2)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Nombre del alias que regresara                           ³±±
±±³          ³ cExp2.- Lista de tipos de facturas:                              ³±±
±±³          ³         1 Factura de Mercancis                                   ³±±
±±³          ³         2 Factura de Gastos Nacionales                           ³±±
±±³          ³         3 Factura de Gastos Extranjeros                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ MATA447B                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447BSELECT(cAliasRSE)

	Local cQryCond	:= ""
	Local cQryTipo	:= ''
	Local cQry			:= ""

	cAliasRSE	:= CriaTrab(Nil,.F.)
	cQryCond	:= "Select RSE.*, "

	cQryCond	+= "RSF.*, "
	cQryCond	+= " F4_CF "
	cQryCond	+= " from "+RetSqlName("RSE") +" RSE, "
	cQryCond	+= RetSqlName("RSF") +" RSF  LEFT JOIN "+ RetSqlName("SF4")+" SF4 ON RSF_TES = F4_CODIGO AND F4_FILIAL= '"+xFilial("SF4")+"' "
	
	cQryCond+= " AND SF4.D_E_L_E_T_  = ' ' "

	cQryCond	+= " WHERE RSE_NUMPED = RSF_NUMPED AND RSE_ITEM = RSF_ITEDOC "
	cQryCond	+= " AND RSE_FILIAL = '" + xFilial("RSE") + "' AND RSF_FILIAL = '"+xFilial("RSF")+"' "
	cQryCond	+= " AND RSE_NUMPED = '"+RSC->RSC_NUMPED+"' "
	cQryCond	+= " AND RSE_OK <> 'S' "

	cQryCond	+= " AND RSE.D_E_L_E_T_  = ' ' "
	cQryCond	+= " AND RSF.D_E_L_E_T_  = ' ' "

	cQry	:= cQryCond + cQryTipo + "   ORDER BY RSE_FILIAL,RSE_TIPO,RSE_FACT,RSE_SERIE,RSE_PROV,RSE_TDA,RSF_TIPO"
	cQry	:= ChangeQuery(cQry)
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQry), cAliasRSE, .T., .T. )
	TCSetField(cAliasRSE, "RSE_EMISIO", "D")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447BIVA        ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de impuestos para la factura del pedimento,              º±±
±±º          ³ Debe estar contenida como formula en el catalogo de impuestos    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447IVA		                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Impuestos Variables - Importaciones - Mexico                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447IVA(cCalculo,nItem,aInfo)

	Local xRet		:= 0
	Local aItem, lXFis, cImp, nOrdSFC, nRegSFC
	Local nBase	:= 0, nAliq := 0, lALIQ := .F., lIsento := .F., cFil, cAux
	Local cDbf		:= alias(), nOrd := IndexOrd()
	Local cImpIncid,nE,nI

	Local ii         := 0
	Local cProcName  := UPPER(AllTrim(ProcName(ii)))
	Local cPrd
	Local nValUnit
	Local cVld			:="RSF_TES"
	Local nPosp		:=	0

	DBSelectArea("SFF")     // verificando as excecoes fiscais
	DBSetOrder(3)

	cFil := xFilial()

	If FunName()=="MATA447"

		While !Empty(cProcName)
			If  cVld  $cProcName
				Exit
			Else
				ii++
				cProcName := UPPER(AllTrim(ProcName(ii)))
			Endif
		End

		If cDocTipo == 'CR' //NOTA DE CRFEDITO
			cPrd		:= aCols[N,GdFieldPos("D2_COD",aHeader)]
			nValUnit	:= aCols[N,GdFieldPos("D2_PRCVEN",aHeader)]
		Else
			cPrd		:= aCols[N,GdFieldPos("D1_COD",aHeader)]
			nValUnit	:= aCols[N,GdFieldPos("D1_VUNIT",aHeader)]
		EndIf

		lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
		If !lXfis
			aItem		:= ParamIxb[1]
			xRet		:= ParamIxb[2]
			cImp		:= xRet[1]
			cImpIncid	:= xRet[10]
		Else
			cImp		:= aInfo[1]
			SB1->(DbGoto(MaFisRet(nItem,"IT_RECNOSB1")))
			xRet		:= 0
			cImpIncid	:= ""
		Endif

		If DBSeek(cFil+cImp)
			while FF_IMPOSTO == cImp .And. FF_FILIAL == cFil .And. !lAliq
				cAux := Alltrim(FF_GRUPO)
				If cAux != ""
					lAliq := (cAux == AllTrim(SB1->B1_GRUPO))
				EndIf
				cAux := AllTrim(FF_ATIVIDA)
				If cAux != ""
					lAliq := (cAux == AllTrim(SA1->A1_ATIVIDA))
				EndIf
				If lAliq
					If !(lIsento := (FF_TIPO=="S"))
						nAliq := FF_ALIQ
					EndIf
				EndIf
				DBSkip()
			EndDo
		EndIf
		If !lIsento
			If !lAliq .And. If(!lXFis,.T.,cCalculo=="A")
				dbselectar("SFB")    // busca a aliquota padrao
				If DBSeek(xFilial()+cImp)
					nAliq:=SFB->FB_ALIQ
				EndIf
			EndIf
			If !lXFis
				nBase := aItem[3] + aItem[4] + aItem[5]  //valor total + frete + outros impostos
				//Tira os descontos se For pelo liquido .Bruno
				If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18]) == "N"
					nBase -= xRet[18]
				Endif
				//+---------------------------------------------------------------+
				//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
				//+---------------------------------------------------------Lucas-+
				nI := At(cImpIncid,";" )
				nI := If(nI == 0,Len(AllTrim(cImpIncid))+1,nI)
				While nI>1
					nE := AScan(aItem[6],{|x| x[1] == Left(cImpIncid,nI-1)})
					If nE > 0
						nBase += aItem[6,nE,4]
					End
					cImpIncid	:= Stuff(cImpIncid,1,nI,"")
					nI			:= At(cImpIncid,";")
					nI			:= If(nI == 0,Len(AllTrim(cImpIncid))+1,nI)
				Enddo
			Else
				dbselectar("SFB")    // busca a aliquota padrao
				If DBSeek(xFilial()+cImp)
					nAliq := SFB->FB_ALIQ
				EndIf

				If cCalculo == "B"
					nBase		:= MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					//Tira os descontos se For pelo liquido
					nOrdSFC	:= (SFC->(IndexOrd()))
					nRegSFC	:= (SFC->(Recno()))
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
						cImpIncid := Alltrim(SFC->FC_INCIMP)
						If SFC->FC_LIQUIDO == "S"
							nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						Endif
					Endif
					SFC->(DbSetOrder(nOrdSFC))
					SFC->(DbGoto(nRegSFC))
					//+---------------------------------------------------------------+
					//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
					//+---------------------------------------------------------------+
					If !Empty(cImpIncid)
						aImpRef:=MaFisRet(nItem,"IT_DESCIV")
						aImpVal:=MaFisRet(nItem,"IT_VALIMP")
						For nI:=1 To Len(aImpRef)
							If !Empty(aImpRef[nI])
								If Trim(aImpRef[nI][1])$cImpIncid
									nBase+=aImpVal[nI]
								Endif
							Endif
						Next
					Endif
				Endif
			Endif
		EndIf

		If !lXFis
			xRet[02]	:= nAliq
			xRet[03]	:= nBase
			xRet[04]	:= (nAliq * nBase) / 100
		Else
			Do Case
			Case cCalculo == "B"  //saca la base
				nPosP := aScan(_PaCalcIva, {|x| AllTrim(x[1]) == AllTrim(cPrd)})
				If nposp == 0
					xRet := 0
				Else
					If naliq == 0
						xRet := _PaCalcIva[nPosP,4] //base de iva cero
					Else
						xRet := _PaCalcIva[nPosP,3]
					EndIf
				EndIf

			Case cCalculo == "A" // saca la tasa
				If naliq == 0
					xRet := 0
				Else
					xRet := RSC->RSC_IVA
				EndIf
			Case cCalculo == "V"    //saca el impuesto
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])

				nPosP:=aScan(_PaCalcIva, {|x| AllTrim(x[1])==AllTrim(cPrd)})
				If nposp == 0
					xRet := 0
				Else
					If naliq == 0
						xRet := 0
					Else
						xRet := _PaCalcIva[nPosP,2]
					EndIf
				EndIf
			EndCase
		Endif

	EndIf

	DBSelectArea(cDbf)
	DBSetOrder(nOrd)

Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447BCOSTOCIF    ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Saca el total del Costo CIF, asi como el numero de items de      º±±
±±º          ³ impuestos, que si aplicaron IVA                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447BCOSTOCIF	                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExp1.- Arreglo con el total de costo CIF                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Factura de impuestos del pedimento - Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M447BCOSTOCIF(lDonde)

	Local cFilRSL	:= xFilial("RSL")
	Local aCIF		:= {0,0,0}
	Local cFilRSJ	:= xFilial("RSJ")
	Local nImpIva	:= 0
	Local nImpBase	:= 0
	Local nBase		:= 0
	Local nCanIte	:= 0

	Default lDonde := .F.

	//Verifica el numero de partidas que llevara la factura
	RSJ->(DBSetOrder(1))
	If RSJ->(DBSeek(cFilRSJ+RSC->RSC_NUMPED))
		nBase:=RSJ->RSJ_VALADU
	EndIf

	If lMX01Rec //SI ES PEDIMENTO DE RECTIFICACION
		If RSJ->(DBSeek(cFilRSJ+RSC->RSC_PEDORI))
			nBase-=RSJ->RSJ_VALADU
			nBase:=abs(nBase)
		EndIf
	EndIf

	RSA->(DBSetOrder(1))
	RSL->(DBSetOrder(1))

	If RSL->(DBSeek(cFilRSL+RSC->RSC_NUMPED))
		Do While !RSL->(Eof()) .And. cFilRSL+RSC->RSC_NUMPED==RSL->RSL_FILIAL+RSL->RSL_NUMPED
			If !Empty(RSL->RSL_CODIMP) .And.  RSL->RSL_IMPORT>0
				nCanIte++
				If RSA->(DBSeek(cFilRSL+RSL->RSL_CODIMP))
					If RSA->RSA_APLIVA=='1'
						nImpBase+=RSL->RSL_IMPORT
					EndIf
				EndIf
			Else
				nImpIva:=RSL->RSL_IMPORT
			EndIf
			RSL->(DBSkip())
		EndDo
	EndIf

	aCif[1] := nBase/nCanIte
	aCif[2] := nBase+nImpBase //total de la base
	aCif[3] := nCanIte

Return aCif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447BExtBase    ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Saca la base para IVA de cada impuesto                           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447BExtBase(cExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Codigo de producto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExp1.- [1] Base   [2]  Impuesto  [3] Porcentaje                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ M447BIVA                            - Importaciones - Mexico     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M447BExtBase()

	Local AValor	:= {0,0,0}
	Local aVal		:= {}

	aVal := M447BCOSTOCIF(0)
	aValor[1] := aVal[1]
	aValor[3] := aVal[2]
	aValor[2] := aVal[3]

Return aValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EliFacturas     ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina las facturas                                             º±±
±±º          ³ Elimina 1ero las facturas de Gastos (tipo C)                     º±±
±±º          ³ y al final las de mercancia  e impuestos (tipo N)                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  EliFacturas ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                    - Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EliFacturas()

	Local lRet		:= .F.

	Local aCabs		:= {}
	Local aItens	:=	{}

	Local cnumfac	:= ''
	Local cSer		:=''
	Local cPrv		:= ''
	Local cTda		:= ''
	Local cFilSF1	:= xFilial("SF1")
	Local cFilSD1	:= xFilial("SD1")
	Local cFilRSE	:= xFilial("RSE")
	Local cAliasSF1	:= ''
	Local cStatus	:= ''
	Local lDelFact	:= .F.
	Local lBan		:= .F.

	Local nNumFacs	:= 0
	Local nCont		:= 0
	Local nMax		:= 0
	Local nx		:= 0

	Local aSX3      := {}
	Local _i        := 0

	If lMX01Rec //Si es una retificacion
		MT447CABORRA()// En MATA447C
		If Len(aLogErro) ==0
			Reclock("RSC",.F.)
			RSC->RSC_STATUS:= ""
			RSC->(MSUNLOCK())
		EndIf
	Else

		DBSelectArea("SC7")
		DBSelectArea("SF1")
		DBSelectArea("SD1")
		DBSelectArea("RSE")

		cAliasSF1:=CriaTrab(Nil,.F.)

		cQryCond:= "Select "
		cQryCond+= " SD1.*,SF1.*, RSE.* "
		cQryCond+= " from "+RetSqlName("SF1") +" SF1, "+RetSqlName("SD1") +" SD1,  "+RetSqlName("RSE") +" RSE "
		cQryCond+=" WHERE F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND  F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND "
		cQryCond+="      F1_DOC=RSE_FACT AND F1_SERIE=RSE_SERIE AND  F1_FORNECE=RSE_PROV AND F1_LOJA=RSE_TDA AND "

		cQryCond+=" RSE_NUMPED='"+RSC->RSC_NUMPED+"' AND RSE_EXTFAC='  ' "

		cQryCond+=" AND F1_FILIAL='"+cFilSF1+"' AND D1_FILIAL='"+cFilSD1+"'  AND RSE_FILIAL='"+cFilRSE+"' "

		cQryCond+= " AND SF1.D_E_L_E_T_  = ' ' "
		cQryCond+= " AND SD1.D_E_L_E_T_  = ' ' "
		cQryCond+= " AND RSE.D_E_L_E_T_  = ' ' "

		cQry := cQryCond+"   ORDER BY F1_TIPO,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA"
		cQry := ChangeQuery(cQry)
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQry), cAliasSF1, .T., .T. )
		COUNT To nMax
		ProcRegua (nMax)
		(cAliasSF1)->(DBGoTop())
		nCont:=0
		If !(cAliasSF1)->(Eof())
			TCSetField(cAliasSF1,"F1_EMISSAO","D")
			TCSetField(cAliasSF1,"F1_DTDIGIT","D")
			TCSetField(cAliasSF1,"F1_FECTIMB","D")
			
			aSX3 := FWSX3Util():GetAllFields("SD1", .T.)
			for _i := 1 to len(aSX3)
				If GetSx3Cache(aSX3[_i], "X3_TIPO") == 'D'
					TCSetField(cAliasSF1,aSX3[_i],"D")
				EndIf
			next _i

			Do While !(cAliasSF1)->(Eof())
				aCabs:={}
				aItens:={}

				cnumfac:= (cAliasSF1)->F1_DOC
				cSer   := (cAliasSF1)->F1_SERIE
				cPrv:=(cAliasSF1)->F1_FORNECE
				cTda:=(cAliasSF1)->F1_LOJA

				aSX3 := FWSX3Util():GetAllFields("SF1", .T.)
				for _i := 1 to len(aSX3)
					If GetSx3Cache(aSX3[_i], "X3_CONTEXT") <> 'V' .And. GetSx3Cache(aSX3[_i], "X3_TIPO") <> 'M'
						aAdd(aCabs , {aSX3[_i]  ,&((cAliasSF1)+"->"+aSX3[_i]), Nil})
					EndIf
				next _i


				nNumFacs++
				Do While !(cAliasSF1)->(Eof()) .And. cFilSD1+cnumfac+cSer+cPrv+cTda==(cAliasSF1)->D1_FILIAL+(cAliasSF1)->D1_DOC+(cAliasSF1)->D1_SERIE+(cAliasSF1)->D1_FORNECE+(cAliasSF1)->D1_LOJA
					aAdd(aItens, {})

					aSX3 := FWSX3Util():GetAllFields("SD1", .T.)
					for _i := 1 to len(aSX3)
				    	If GetSx3Cache(aSX3[_i], "X3_CONTEXT") <> 'V' .And. GetSx3Cache(aSX3[_i], "X3_TIPO") <> 'M'
							aAdd(aItens[Len(aItens)] , {aSX3[_i]  ,&((cAliasSF1)+"->"+aSX3[_i]), Nil})
						EndIf
					next _i
					
					IncProc(STR0055+cnumfac+cSer) 	//"Eliminando Factura "
					(cAliasSF1)->(DBSkip())
				EndDo

				If (Len(aCabs)>0 .And. Len(aItens)>0)
					BeginTran()

						lMSErroAuto := .F.
						MaFisEnd()
						cDocTipo:='FE' //Factura de entrada
						MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,5)
						If lMSErroAuto

							DisarmTransaction()

							aAdd(aLogErro, { STR0056+AllTrim(cnumfac)+" "+cSer+ STR0057}) //"Rutina automatica, al Eliminar la Factura "+AllTrim(cnumfac)+" "+cSer+" encontro los errores : "
							aAutoErro := GETAUTOGRLOG()
							For nx:=1 To Len(aAutoErro)
								aAdd(aLogErro, {aAutoErro[nx]})
							Next
						Else
							SF1->(DBSetOrder(1))
							If !SF1->(DBSeek(xFilial("SF1")+cnumfac+cSer+cPrv+cTda)) //asegura que si borro, entonces marca
								nCont++
								RSE->(DBSetOrder(1))
								If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED+cnumfac+cSer+cPrv+cTda))
									RecLock("RSE", .F.)
									RSE->RSE_OK:= " "
									RSE->(MsUnlock())
								EndIf
									//Actualiza el saldo  de la OC con respecto al pedimento
								ActSaldoOC(cnumfac,cSer,cPrv,cTda)
							
								MT447BActI(RSC->RSC_NUMPED, nTipoAcc)
								
								lDelFact := .T.
							Else
								aAdd(aLogErro, {cnumfac+" "+cSer+"-"+STR0058}) //"No elimino por completo las facturas, verifique si alguna de ellas ya tiene pagos,!"
							EndIf
						EndTran()
					EndIf
					MsUnlockAll()
				EndIf
			EndDo
		EndIf
		(cAliasSF1)->(DBCloseArea())

		If nCont == nNumFacs //Si Borro las facturas de Mercancia y Gastos
			ProcRegua (3)
			lBan:= .T.
			If !lMX01Ext
				lBan:= MT447BGENMOVINT("I",.T.) //Borra el movto de incementables
			EndIf
			If lBan
				incproc()
				If !MT447BELIFACPED("N") //Borra factura de  de impuestos
					lBan:= .F.
				Else
					incproc()
					lBan:= .T.
					If !MT447BTRASPASO(.T.)  //Borra
						lBan:= .F.
					Else
						incproc()
						lBan:= .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If (lBan,cStatus:='',cStatus:='1')
			Reclock("RSC",.F.)
			RSC->RSC_STATUS:=cStatus
			RSC->(MSUNLOCK())
		EndIf

		If Len(aLogErro)>0
			If MsgYesNo(STR0059) //"Errores encotrados, ¿Quiere verificar el LOG?"
				ImprimeLog()
			EndIf
		Else
			/*
			* Se valida que si no hubo borrado de Facturas de Entrada, 
			* se realice la actualizacion del campo D1_PEDIM para
			* Facturas de Extraccion contenidas en el Pedimento.
			*/
			If !lDelFact 
				MT447BActI(RSC->RSC_NUMPED, nTipoAcc)
			EndIf
			MsgInfo(STR0060) //"Proceso finalizado sin Errores!"
		EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT447BELIFACPED ºAutor  ³Gpe Santacruz       ºFecha ³  23/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina las factura de impuestos                                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  EliFacPed()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                    - Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT447BELIFACPED(ctipo)

	Local lRet			:= .T.
	Local aCabs			:= {}
	Local aItens		:= {}
	Local cnumfac		:= ''
	Local cPrv			:= ''
	Local cTda			:= ''
	Local cFilSF1		:= xFilial("SF1")
	Local cFilSD1		:= xFilial("SD1")
	Local nx			:= 0
	Local aFieldsSF1	:= FWSX3Util():GetAllFields("SF1", .F.)
	Local aFieldsSD1	:= FWSX3Util():GetAllFields("SD1", .F.)
	Local nIteracion	:= 0

	DBSelectArea("SF1")
	DBSelectArea("SD1")
	DBSelectArea("RSE")

	cnumfac	:= RSC->RSC_FACIMP+RSC->RSC_SERIMP
	cPrv	:= ''
	cTda	:= ''

	DB9->(DBSetOrder(1))
	If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
		cPrv := DB9->DB9_PROV
		cTda := DB9->DB9_TDA
	EndIf

	ProcRegua (1)
	SF1->(DBSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(DBSeek(cFilSF1+RSC->RSC_FACIMP+RSC->RSC_SERIMP+cPrv+cTda+ctipo))
		IncProc(STR0055+RSC->RSC_FACIMP+RSC->RSC_SERIMP) //"Eliminando Factura "

		For nIteracion := 1 To Len(aFieldsSF1)
			aAdd(aCabs, {aFieldsSF1[nIteracion], &("SF1->"+aFieldsSF1[nIteracion]), Nil})
		Next nIteracion

		SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(DBSeek(CFILSD1+RSC->RSC_FACIMP+RSC->RSC_SERIMP))
		Do While !SD1->(Eof()) .And. cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA==SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If SD1->D1_TIPO==CTIPO
				aAdd(aItens, {})
				For nIteracion := 1 To Len(aFieldsSD1)
					aAdd(aItens[Len(aItens)], {aFieldsSD1[nIteracion], &("SD1->"+aFieldsSD1[nIteracion]), Nil})
				Next nIteracion
			EndIf
			SD1->(DBSkip())
		EndDo
		If  (Len(aCabs)>0 .And. Len(aItens)>0)
			BeginTran()
				lMSErroAuto := .F.
				MaFisEnd()
				DocTipo := 'FE' //Factura de entrada
				MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,5)

				If lMSErroAuto .Or.  SF1->(DBSeek(cFilSF1+RSC->RSC_FACIMP+RSC->RSC_SERIMP+cPrv+cTda+ctipo))
					aAdd(aLogErro, {STR0061+AllTrim(RSC->RSC_FACIMP)+" "+RSC->RSC_SERIMP+STR0062 })	//"Rutina automatica, al Eliminar la Factura de Impuestos "," encontro los errores : "
					aAutoErro := GETAUTOGRLOG()
					For nx:=1 To Len(aAutoErro)
						aAdd(aLogErro, {aAutoErro[nx]})
					Next
					DisarmTransaction()
					lRet:= .F.
				Else
					If MT447BGENMOVINT('',.T.) //borra movimiento interno, de la factura d eimpuestos
						reclock("RSC",.F.)
						RSC->RSC_FACIMP:=""
						RSC->RSC_SERIMP :=""
						RSC->RSC_TIPDOC :=""
						RSC->(MSUNLOCK())
						lRet:= .T.
					EndIf
				EndTran()
			EndIf
			MsUnlockAll()
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT447BTRASPASO  ºAutor  ³Gpe Santacruz       ºFecha ³  30/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera traspasos entre almacenes                                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT447BTRASPASO()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT447BTRASPASO(lBorra)

	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSB2	:= SB2->(GetArea())
	Local aAreaSD3	:= SD3->(GetArea())
	Local aRecno		:= {}
	Local aCm			:= {}
	Local aSd3			:= {}

	Local lRet			:= .T.

	Local cAliasTRA	:= CriaTrab(Nil,.F.)
	Local cQry			:= ''
	Local cfilSD3		:= xFilial("SD3")
	Local cfilRSF		:= xFilial("RSF")
	Local cFilSB2		:= xFilial("SB2")
	Local CFILRSE		:= xFilial("RSE")
	Local CFILRSM		:= xFilial("RSM")

	Local nx			:= 0
	Local nMax			:= 0
	Local nCntFor		:= 0
	Local nCntFor2	:= 0
	Local nTamDoc		:= 0

	Local cNumSeq		:= ""
	Local cDocNew		:= ''
	Local cDocSt		:= GetMV("MV_MXSECMI") //Consecutivo de documentos de movtos internos

	Private cDocumento := '' //para usarlo en la validacion del A240DOC

	If !lBorra
		If lMX01Dep
			Return .T.
		EndIf

		IncProc(STR0064) //"Generando traspaso entre almacenes.. "
		If Empty(cDocSt)
			msgAlert(STR0063) //"El parametro MV_MXSECMI esta vacio, debe contener el consecutivo de Dcocumentos de movimientos internos!"
			aAdd(aLogErro, {STR0063}) //"El parametro MV_MXSECMI esta vacio, debe contener el consecutivo de Dcocumentos de movimientos internos!"
			lRet:= .F.
		EndIf
		cDocSt:=VldA447BDoc(cDocSt) //valida que no exista el documento

		//Extraccion por pedimento
		If lMX01Ext
			cQry:= "SELECT RSM_PEDORI, RSM_FACT,RSM_SERIE,RSM_PROV,RSM_TDA,RSM_ITEM,RSM_UM cUM1, RSM_ALMACE cAlmEnt,RSF_ALMACE cAlmSal, RSM_CANT nCant1,RSM_UM2 cUm2,b1_desc cDesc,"
			cQry+= " RSM_PRODUC cProduc, B1_GRUPO,B1_TIPO, RSM.R_E_C_N_O_ NREG FROM "+RetSqlName("RSM") +" RSM,"+RetSqlName("RSF")+" RSF ,"+RetSqlName("SB1")+" SB1 "
			cQry+= " WHERE RSF_NUMPED='"+RSC->RSC_PEDORI+"' AND RSM_NUMPED='"+RSC->RSC_NUMPED+"' AND "
			cQry+= " RSF_ITEM=RSM_ITEM AND RSF_ITEDOC=RSM_ITEDOC  AND "
			cQry+= " B1_COD= RSM_PRODUC AND "
			cQry+= " RSM_FILIAL= '"+xFilial("RSM")+"'  AND RSF_FILIAL= '"+xFilial("RSF")+"' AND B1_FILIAL= '"+xFilial("SB1")+"' AND "
			cQry+= " RSM_OKT =' ' "

			cQry+= " AND RSM.D_E_L_E_T_  = ' '  AND RSF.D_E_L_E_T_  = ' ' AND SB1.D_E_L_E_T_  = ' '"
		Else
			//Extracciones por Factura
			RSF->(DBSetOrder(1))
			cQry:= "SELECT D1_LOCAL cAlmSal, RSE_FACT,RSE_SERIE,RSE_PROV,RSE_TDA,RSE_ITEM,RSF_UM cUM1, RSF_ALMACE cAlmEnt,RSF_CANT nCant1,RSF_UM2 cUm2,b1_desc cDesc,"
			cQry+= "RSF_PRODUC cProduc,  B1_GRUPO,B1_TIPO,RSF_ITEM, RSE.R_E_C_N_O_ NREG FROM "
			cQry+=RetSqlName("RSF") +" RSF,"+RetSqlName("RSE")+" RSE ,"+RetSqlName("SB1")+" SB1 ,"+RetSqlName("SD1")+" SD1 "
			cQry+= " WHERE   RSF_ITEDOC=RSE_ITEM AND  B1_COD= RSF_PRODUC AND "
			cQry+= " RSF_NUMPED ='"+RSC->RSC_NUMPED +"' AND  "
			cQry+= " RSE_NUMPED = RSF_NUMPED  AND  "
			cQry+= " RSF_FILIAL= '"+CFILRSF+"'  AND RSE_FILIAL= '"+xFilial("RSE")+"' AND B1_FILIAL= '"+xFilial("SB1")+"' AND D1_FILIAL= '"+xFilial("SD1")+"' AND "
			cQry+= " RSF_ALMACE <>'' AND  "
			cQry+= " RSE_OKT =' ' AND RSE_EXTFAC='EF' AND "
			cQry+= " RSE_FACT= D1_DOC  AND RSE_SERIE=D1_SERIE AND RSE_PROV=D1_FORNECE AND RSE_TDA=D1_LOJA AND RSF_PRODUC=D1_COD AND RSF_ITEM = D1_ITEM"

			cQry+= " AND RSF.D_E_L_E_T_  = ' '  AND RSE.D_E_L_E_T_  = ' ' AND SB1.D_E_L_E_T_  = ' ' AND SD1.D_E_L_E_T_    = ' '"
		EndIf

		cQry := ChangeQuery(cQry)
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQry), cAliasTRA, .T., .T. )
		COUNT To nMax
		ProcRegua (nMax)
		(cAliasTRA)->(DBGoTop())

		If !(cAliasTRA)->(Eof())
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³/Valida que haya saldo en todas las partidas a mover de lo contrario no mueve ninguna³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			If !lPermNegat
				SB2->(DbSetOrder(1))
				Do While !(cAliasTRA)->(Eof())
					If !( (cAliasTRA)->cAlmSal == (cAliasTRA)->cAlmEnt )
						DBSelectArea("SB2")
						If SB2->(DbSeek(xFilial("SB2")+(cAliasTRA)->cProduc+(cAliasTRA)->cAlmSal))
							If SaldoSB2() < (cAliasTRA)->nCant1
								aAdd(aLogErro, {"El saldo en el almacen "+(cAliasTRA)->cAlmSal +" para el  producto "+(cAliasTRA)->cProduc+" es insuficiente "})
								(cAliasTRA)->(DBCloseArea())
								Return .F.
							EndIf
						Endif
					Endif
					(cAliasTRA)->(DBSkip())
				EndDo
			EndIf
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Genera el traspaso³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			(cAliasTRA)->(DBGoTop())
			Do While !(cAliasTRA)->(Eof())

				If !( (cAliasTRA)->cAlmSal == (cAliasTRA)->cAlmEnt )
					cNumSeq  := ProxNum()
					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Movimimiento almacen Origen³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek(cFilSB2+(cAliasTRA)->cProduc+(cAliasTRA)->cAlmSal))
						CriaSB2((cAliasTRA)->cProduc,(cAliasTRA)->cAlmSal)
					EndIf

					aCM := PegaCMAtu((cAliasTRA)->cProduc,(cAliasTRA)->cAlmSal)
					RecLock("SD3",.T.)
					SD3->D3_FILIAL  := xFilial("SD3")
					SD3->D3_COD     := (cAliasTRA)->cProduc
					SD3->D3_QUANT   := (cAliasTRA)->nCant1
					SD3->D3_CF      := "RE4"
					SD3->D3_CHAVE   := "E0"
					SD3->D3_LOCAL   := (cAliasTRA)->cAlmSal
					SD3->D3_DOC     := cDocSt
					SD3->D3_EMISSAO := dDatabase
					SD3->D3_UM      := (cAliasTRA)->CUM1
					SD3->D3_GRUPO   := (cAliasTRA)->B1_GRUPO
					SD3->D3_TIPO    := (cAliasTRA)->B1_TIPO
					SD3->D3_NUMSEQ  := cNumSeq
					SD3->D3_QTSEGUM := ConvUm((cAliasTRA)->cProduc,(cAliasTRA)->nCant1,0,2)
					SD3->D3_SEGUM   := (cAliasTRA)->cUm2
					SD3->D3_TM      := "999"
					SD3->D3_NUMPED  :=RSC->RSC_NUMPED
					SD3->D3_TIPODOC :="TR"

					//Permite agregar mas campos
					If (ExistBlock("M447BTS"))
						ExecBlock("M447BTS",.F.,.F.,{cAliasTRA})
					EndIf

					aCusto := GravaCusD3(aCM)
					B2AtuComD3(aCusto)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Genera movimiento destino                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DBSelectArea("SB2")
					DBSetOrder(1)
					If ( !MsSeek(xFilial("SB2")+SB1->B1_COD+(cAliasTRA)->cAlmEnt) )
						CriaSB2( SB1->B1_COD,(cAliasTRA)->cAlmEnt )
					EndIf

					RecLock("SD3",.T.)
					SD3->D3_FILIAL  := xFilial("SD3")
					SD3->D3_COD     := (cAliasTRA)->cProduc
					SD3->D3_QUANT   := (cAliasTRA)->nCant1
					SD3->D3_CF      := "DE4"
					SD3->D3_CHAVE   := "E9"
					SD3->D3_LOCAL   := (cAliasTRA)->cAlmEnt
					SD3->D3_DOC     := cDocSt
					SD3->D3_EMISSAO := dDatabase
					SD3->D3_UM      := (cAliasTRA)->CUM1
					SD3->D3_GRUPO   := (cAliasTRA)->B1_GRUPO
					SD3->D3_TIPO    := (cAliasTRA)->B1_TIPO
					SD3->D3_NUMSEQ  := cNumSeq
					SD3->D3_QTSEGUM := ConvUm((cAliasTRA)->cProduc,(cAliasTRA)->nCant1,0,2)
					SD3->D3_SEGUM   := (cAliasTRA)->cUm2
					SD3->D3_TM      := "499"
					SD3->D3_NUMPED  :=RSC->RSC_NUMPED
					SD3->D3_TIPODOC :="TR"

					//Permite agregar mas campos
					If (ExistBlock("M447BTE"))
						ExecBlock("M447BTE",.F.,.F.,{cAliasTRA})
					EndIf

					aCusto := GravaCusD3(aCM)
					B2AtuComD3(aCusto)

				Endif

				IncProc(STR0064) //"Generando traspaso entre almacenes ... "
				aAdd(aRecno,(cAliasTRA)->nreg) //registros a marcar
				(cAliasTRA)->(DBSkip())
			EndDo

			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Marca que se realizo traspaso³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			If lMX01Ext
				For nx:=1 To Len(aRecno)
					RSM->(DBGoTo(aRecno[nx]))
					If !RSM->(Eof())
						Reclock("RSM",.F.)
						RSM->RSM_OKT:='S'
						RSM->(MSUNLOCK())
					EndIf
				Next
			Else
				For nx:=1 To Len(aRecno)
					RSE->(DBGoTo(aRecno[nx]))
					If !RSE->(Eof())
						Reclock("RSE",.F.)
						RSE->RSE_OKT:='S'
						RSE->(MSUNLOCK())
					EndIf
				Next
			EndIf

			DBSelectArea("SD3")
			SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))

			If SD3->(DBSeek(xFilial("SD3")+RSC->RSC_NUMPED+"TR"+" "))
				reclock("RSC",.F.)
				RSC->RSC_DOCTRA:=SD3->D3_DOC
				RSC->(MSUNLOCK())
			EndIf

			// PE para aplicación contable
			If ExistBlock("M447BD3T")
				// Parámetros:
				// [1] No documentos traspaso
				ExecBlock("M447BD3T",.F.,.F.,{cDocSt})
			Endif

			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Extrae consecutivo de doctos internos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			nTamDoc:=TamSX3('D3_DOC')[1]
			cDocNew:=SOMA1(AllTrim(cDocSt),nTamDoc)

			PutMV("MV_MXSECMI",AllTrim(cDocNew))

		EndIf
		(cAliasTRA)->(DBCloseArea())

	Else
		IncProc(STR0066+RSC->RSC_DOCTRA) //"Eliminando traspaso... "

		DBSelectArea("SD3")
		SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
		Do While .T.
			If SD3->(DBSeek(CFILSD3+RSC->RSC_NUMPED+"TR"+" "))
				aAdd(aSd3,{})
				For nCntFor := 1 To SD3->(FCount())
					aAdd(aSD3[Len(aSD3)],SD3->(FieldGet(nCntFor)))
				Next nCntFor
				RecLock("SD3",.F.)
				SD3->D3_ESTORNO := "S"
				SD3->(MSUNLOCK())
			Else
				Exit
			EndIf
		EndDo
		For nCntFor := 1 To Len(aSd3)
			RecLock("SD3",.T.)
			For nCntFor2 := 1 To Len(aSd3[nCntFor])
				SD3->(FieldPut(nCntFor2,aSd3[nCntFor][nCntFor2]))
			Next nCntFor2
			If !lMX01Rec
				aCm   := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)//Obtiene el costo de SB2
			EndIf
			If ( SD3->D3_CF == "DE4" )
				SD3->D3_CF     := "RE4"
				SD3->D3_CHAVE  := "E0"
				SD3->D3_TM     := "999"
			Else
				SD3->D3_CF     := "DE4"
				SD3->D3_CHAVE  := "E9"
				SD3->D3_TM     := "499"
			EndIf
			SD3->D3_ESTORNO:= "S"
			SD3->D3_EMISSAO:= dDataBase
			SD3->D3_DTLANC := CtoD("")	// <ARL> 06/02/2013 Para identificar movs y elaborar póliza contable de la reversión
			SD3->(msUnlock())
			If !lMX01Rec
				aCusto := GravaCusD3(aCm)
			Else //Si es Pedimento de Rectificacion
				aCusto := PegaCusD3() //obtiene los costos de la SD3
			EndIf
			B2AtuComD3(aCusto)
		Next nCntFor

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desmarca el traspaso³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		If lMX01Ext
			RSM->(DBSetOrder(1))
			If RSM->(DBSeek(CFILRSM+RSC->RSC_NUMPED))
				Do While !RSM->(Eof()) .And. CFILRSM==RSM->RSM_FILIAL .And. RSM->RSM_NUMPED==RSC->RSC_NUMPED
					Reclock("RSM",.F.)
					RSM->RSM_OKT:=''
					RSM->(MSUNLOCK())
					RSM->(DBSkip())
				EndDo
			EndIf
		Else
			RSE->(DBSetOrder(1))
			If RSE->(DBSeek(CFILRSE+RSC->RSC_NUMPED))
				Do While !RSE->(Eof()) .And. CFILRSE==RSE->RSE_FILIAL .And. RSE->RSE_NUMPED==RSC->RSC_NUMPED
					If RSE->RSE_EXTFAC=='EF'
						Reclock("RSE",.F.)
						RSE->RSE_OKT:=''
						RSE->(MSUNLOCK())
					EndIf
					RSE->(DBSkip())
				EndDo
			EndIf
		EndIf

		// PE para aplicación contable
		If ExistBlock("M447BD3R")
			// Parámetros:
			// [1] No documentos traspaso
			ExecBlock("M447BD3R",.F.,.F.,{RSC->RSC_DOCTRA})
		Endif

		RecLock("RSC",.F.)
		RSC->RSC_DOCTRA:=''
		RSC->(MSUNLOCK())
	EndIf

	RestArea(aArea)
	RestArea(aAreaSB1)
	RestArea(aAreaSB2)
	RestArea(aAreaSD3)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT447BGENMOVINT ºAutor  ³Gpe Santacruz       ºFecha ³  14/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera movimientos internos con los valorea de impuestos o incre-º±±
±±º          ³ mentables.                                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  GenMovInt  ()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 = Tipo de Movimiento    I - Incrementable                   ³±±
±±³          ³                            ' ' - Mov de Fact Impuestos           ³±±
±±³          ³lExp1 = .T. Borra el movimiento, .F. Genera el movimiento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³   Pedimentos - Mexico                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MT447BGENMOVINT(cTipo,lBorra)

	Local lRet			:= .T.
	Local aCab			:= {}
	Local aItem			:= {}
	Local cfilRSI		:= xFilial("RSI")
	Local cfilRSM		:= xFilial("RSM")
	Local cfilRSE		:= xFilial("RSE")
	Local cfilRSF		:= xFilial("RSF")
	Local cfilSD3		:= xFilial("SD3")
	Local cFilSB2		:= xFilial("SB2")
	Local cAlmacen		:= ''
	Local aSd3			:= {}
	Local nCntFor		:= 0
	Local nCntFor2		:= 0
	Local cTipoDoc		:= ''
	Local cDocSt		:= GetMV("MV_MXSECMI") //Consecutivo de documentos de movtos internos
	Local cDocNew		:= ''
	Local nTamDoc		:= 0
	Local nj			:= 0
	Local nx			:= 0
	Local nFactConv 	:= 1
	Local nMoedFact 	:= 2

	Default cTipo		:= ''

	if !(cTipo $ "A1,A2")
		if (empty(cTipo),cTipoDoc:='FP',cTipoDoc:='IN') //FP=Movimiento interno de factura de impuestos  IN=Movimiento interno de incrementables
	ELSE
		CTIPODOC:=CTIPO
	ENDIF

	RSE->(DBSetOrder(1)) // RSE_FILIAL+RSE_NUMPED+RSE_FACT+RSE_SERIE+RSE_PROV+RSE_TDA
	RSF->(DBSetOrder(1)) // RSF_FILIAL+RSF_NUMPED+RSF_ITEDOC+RSF_ITEM
	RSI->(DBSetOrder(1)) // RSI_FILIAL+RSI_NUMPED+RSI_FACT+RSI_SERIE+RSI_PROV+RSI_TDA+RSI_ITEM+RSI_PROD
	RSM->(DBSetOrder(1)) // RSM_FILIAL+RSM_NUMPED+RSM_FACT+RSM_SERIE+RSM_PROV+RSM_TDA+RSM_ITEM+RSM_PRODUC
	SB2->(DBSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If !lBorra
		If Empty(cDocSt)
			aAdd(aLogErro, {STR0063}) //"El parametro MV_MXSECMI esta vacio, debe contener el consecutivo de Dcocumentos de movimientos internos!"
			lRet := .F.
		EndIf
		IncProc(STR0067+cDocSt) //"Generando movimiento interno ... "
		SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
		If sd3->(DBSeek(xFilial("SD3")+RSC->RSC_NUMPED+CTIPODOC+" "))
			Do While !sd3->(Eof()) .And. cfilsd3==sd3->d3_filial .And. sd3->d3_NUMPED+SD3->D3_TIPODOC+SD3->D3_ESTORNO==RSC->RSC_NUMPED+CTIPODOC+' '
				If Empty(sd3->d3_estorno)
					MsgAlert(STR0068+SD3->D3_DOC+STR0069) //"Existe un movimiento de traspaso con el numero de documento :",", eliminelo y vuelva a intentar.."
					aAdd(aLogErro, {STR0068+SD3->D3_DOC+STR0069})
					Return .F.
				EndIf
				sd3->(DBSkip())
			EndDo
		EndIf

		aCab := {	{"D3_DOC"		, cDocSt		, Nil},;
					{"D3_TM"		, cTESmovI		, Nil},;
					{"D3_CC"    	, ""			, Nil},;
					{"D3_EMISSAO"	, dDataBase	, Nil}}

		RSI->(DBGoTop())
		If RSI->(DBSeek(CFILRSI+RSC->RSC_NUMPED))

			Do While !RSI->(Eof()) .And. CFILRSI+RSI->RSI_NUMPED==RSC->RSC_FILIAL+RSC->RSC_NUMPED
				If ( !Empty(cTipo) .And. RSI->RSI_INCREM == 0 ) .OR. ( RSI->RSI_IMPUES == 0 )  // RSI->RSI_IMPUES == 0  Validación para No generar Documentos de Movimientos internos si los importes esta en ceros
					RSI->(DBSkip())
					loop
				EndIf
				aAdd(aItem, {})
				aAdd(aItem[Len(aItem)],{"D3_FILIAL"  , CFILSD3  , Nil})
				aAdd(aItem[Len(aItem)],{"D3_COD"		,RSI->RSI_PROD ,Nil})
				cUm := ''

				SB1->(DBSetOrder(1))
				If SB1->(DBSeek(xFilial("SB1")+RSI->RSI_PROD))
					cUm:=SB1->B1_UM
				EndIf

				aAdd(aItem[Len(aItem)],{"D3_UM"		,cUm ,Nil})
				aAdd(aItem[Len(aItem)],{"D3_QUANT"	,0   ,Nil})
				If RSE->(DBSeek(cfilRSE+RSC->RSC_NUMPED+RSI->RSI_FACT+RSI->RSI_SERIE+RSI->RSI_PROV+RSI->RSI_TDA))
					nFactConv := RSE->RSE_TC
					nMoedFact := RSE->RSE_MONED
				Else
					nFactConv := 1
					nMoedFact := 2
				EndIf

				If Empty(cTipo)
					aAdd(aItem[Len(aItem)],{"D3_CUSTO1",		RSI->RSI_IMPUES 			   ,Nil} )
					If nMoedFact != 1
						aAdd(aItem[Len(aItem)],{"D3_CUSTO"+Alltrim(STR(nMoedFact)),(RSI->RSI_IMPUES/(RSC->RSC_TC*nFactConv))		   ,Nil} )
					EndIf
				Else
					aAdd(aItem[Len(aItem)],{"D3_CUSTO1",		RSI->RSI_INCREM 			   ,Nil} )
					If nMoedFact != 1
						aAdd(aItem[Len(aItem)],{"D3_CUSTO"+Alltrim(STR(nMoedFact)),		(RSI->RSI_INCREM/(RSC->RSC_TC*nFactConv)) 			   ,Nil} )
					EndIf
				EndIf

				aAdd(aItem[Len(aItem)],{"D3_NUMPED",		RSC->RSC_NUMPED 			   ,Nil} )
				aAdd(aItem[Len(aItem)],{"D3_TIPODOC",	cTipoDoc			   ,Nil} )

				cAlmacen := ''
				If lMX01Ext
					If RSM->(DBSeek(CFILRSM+RSC->RSC_NUMPED+RSI->RSI_FACT+RSI->RSI_SERIE+RSI->RSI_PROV+RSI->RSI_TDA+RSI->RSI_ITEM+RSI->RSI_PROD ))
						cAlmacen:=RSM->RSM_ALMACE
					EndIf
				Else
					If RSE->(DBSeek(cfilRSE+RSC->RSC_NUMPED+RSI->RSI_FACT+RSI->RSI_SERIE+RSI->RSI_PROV+RSI->RSI_TDA))
						If RSF->(DBSeek(cfilRSF+RSC->RSC_NUMPED+RSE->RSE_ITEM+RSI->RSI_ITEM))
							cAlmacen:=RSF->RSF_ALMACE
						EndIf
					EndIf
				EndIf
				aAdd(aItem[Len(aItem)],{"D3_LOCAL",	cAlmacen			   ,Nil} )

				//Permite agregar mas campos al SD3
				If (ExistBlock("M447BD3I"))
					aMasItem := ExecBlock("M447BD3I",.F.,.F.)
					For nj:=1 To Len(aMasItem)
						aAdd(aItem[Len(aItem)],aMasItem[nj] )
					Next
				EndIf
				If !Empty(cAlmacen)
					If !SB2->(DbSeek(CFILSB2+RSI->RSI_PROD+cAlmacen))
						CriaSB2(RSI->RSI_PROD,cAlmacen)
					EndIf
				EndIf
				RSI->(DBSkip())
			EndDo
			If Len(aItem)>0
				BeginTran()
					lMSErroAuto := .F.
					MSExecAuto({|x,y| MATA241(x,y)},aCab,aItem,3)
					If  lMsErroAuto
						DisarmTransaction()
						aAdd(aLogErro, {STR0070+cTipoDoc+STR0071}) //"Rutina automatica, al Generar el Mvoto. Interno tipo  "," encontro los errores : "
						aAutoErro := GETAUTOGRLOG()
						For nx:=1 To Len(aAutoErro)
							aAdd(aLogErro, {aAutoErro[nx]})
						Next
						lRet:= .F.
					Else
						If CTIPO=='I'
							DBSelectArea("SD3")
							SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
							If SD3->(DBSeek(xFilial("SD3")+RSC->RSC_NUMPED+CTIPODOC+" "))

								reclock("RSC",.F.)
								RSC->RSC_DOCINC:=SD3->D3_DOC
								RSC->(MSUNLOCK())
							EndIf
						EndIf
				EndTran()
				   EndIf
				   MsUnlockAll()
				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Extrae consecutivo de doctos internos     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				nTamDoc	:= TamSX3('D3_DOC')[1]
				cDocNew	:= SOMA1(AllTrim(cDocSt),nTamDoc)
				PutMV("MV_MXSECMI",AllTrim(cDocNew))
			EndIf
		EndIf
	Else
		DBSelectArea("SD3")
		SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
		IncProc(STR0072+RSC->RSC_DOCINC) //"Eliminando movimiento internos ... "
		Do While .T.
			If SD3->(DBSeek(CFILSD3+RSC->RSC_NUMPED+CTIPODOC+" "))
				aAdd(aSd3,{})
				For nCntFor := 1 To SD3->(FCount())
					aAdd(aSD3[Len(aSD3)],SD3->(FieldGet(nCntFor)))
				Next nCntFor
				RecLock("SD3",.F.)
				SD3->D3_ESTORNO := "S"
				SD3->(MSUNLOCK())
			Else
				Exit
			EndIf
		EndDo
		For nCntFor := 1 To Len(aSd3)
			RecLock("SD3",.T.)
			For nCntFor2 := 1 To Len(aSd3[nCntFor])
				SD3->(FieldPut(nCntFor2,aSd3[nCntFor][nCntFor2]))
			Next nCntFor2
			SD3->D3_CF     := "RE6"
			SD3->D3_TM     := "999"
			SD3->D3_ESTORNO:= "S"
			SD3->D3_EMISSAO:= dDataBase
			SD3->D3_DTLANC := CtoD("")
			aCusto := PegaCusD3()
			B2AtuComD3(aCusto)
		Next nCntFor
		// PE para aplicación contable de reversión del movimiento interno del prorrateo de los impuestos aduanales
		If cTipoDoc == "FP" .And. ExistBlock("M447BSD3B")
			// Parámetros:
			// [1] No pedimento
			// [2] Tipo documento
			ExecBlock("M447BD3B",.F.,.F.,{RSC->RSC_NUMPED, cTipoDoc})
		Endif
		If cTipo == 'I'
			reclock("RSC",.F.)
			RSC->RSC_DOCINC := ''
			RSC->(MSUNLOCK())
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeLog  ³ Autor ³GSANTACRUZ          ³ Data ³ 11/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ejecuta rutina para Visualizar/Imprimir log del proceso.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³      													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImprimeLog()

	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0073+RSC->RSC_numped +STR0074+RSC->RSC_cveped  //"LOG  de Generacion de Documentos del pedimento : "," Tipo :"
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= {}
	Local aLog		:= {}

	For nx := 1 To Len(ALOGERRO)
		aAdd(aLog,aLogErro[nx,1])
	Next

	aNewLog	:= aClone(aLog)
	nTamLog	:= Len( aLog)
	aLog		:= {}

	If !Empty( aNewLog )
		aAdd( aLog , aClone( aNewLog ) )
	Endif

	/*
	1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
	2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
	3 -	cPerg		//Pergunte a Ser Listado
	4 -	lShowLog	//Se Havera "Display" de Tela
	5 -	cLogName	//Nome Alternativo do Log
	6 -	cTitulo		//Titulo Alternativo do Log
	7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
	8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
	9 -	aRet		//Array com a Mesma Estrutura do aReturn
	10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	aAdd(aLogTitle,"                                                    ")
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0075) //"Generando Log del Pedimento..."

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldA447BDoc³ Autor ³ gSantacruz           ³ Data ³ 31/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o documento da movimentacao interna                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldA447BDoc(cNumDoc)

	Local lFirstNum:=.T.
	Local cDoc:= cNumDoc
	Local nRecSD3    := SD3->(Recno())
	Local nOrdSD3    := SD3->(IndexOrd())
	Local lValidaDoc :=GetNewPar("MV_VLDDOC","N") == "S"

	If lValidaDoc

		DBSelectArea("SD3")
		DBSetOrder(2)
		If dbSeek(xFilial()+cDoc)
			Do While !Eof() .And. D3_FILIAL+D3_DOC == xFilial()+cDoc .And. lRet
				If D3_ESTORNO # "S"
					If lFirstNum
						cNumDoc 	:= NextNumero("SD3",2,"D3_DOC",.T.)
						cNumDoc 	:= A261RetINV(cNumDoc)
						lFirstNum 	:= .F.
					Else
						cNumDoc := Soma1(cDocumento)
					EndIf
				EndIf
				DBSkip()
			EndDo
		EndIf
		SD3->(DBGoTo(nRecSD3))
		SD3->(DBSetOrder(nOrdSD3))
	EndIf
	cDoc:= cNumDoc

Return cDoc

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ExtBasesIVA³ Autor ³ gSantacruz           ³ Data ³ 31/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExtBasesIVA()

	
	Local cFilRSG	:= ''
	Local cFilRSH	:= ''
	Local nPsIvas	:= 0
	Local aIvas	:= {}

	cFilRSG := xFilial("RSG")
	RSG->(DBSetOrder(1))
	If RSG->(DBSeek(cFilRSG+RSC->RSC_NUMPED))
		Do While !RSG->(Eof()) .And. cFilRSG+RSC->RSC_NUMPED ==  RSG->RSG_FILIAL+RSG->RSG_NUMPED
			nPsIvas := aScan(aIVAS, {|x| x[1] == RSG->RSG_PORIVA})
			If nPsIvas == 0
				aAdd(aIVAS,{RSG->RSG_PORIVA,RSG->RSG_VALADU,RSG->RSG_IMPIVA} )
			Else
				aIVAS[nPsIvas,2] += RSG->RSG_VALADU
				aIVAS[nPsIvas,3] += RSG->RSG_IMPIVA
			EndIf
			RSG->(DBSkip())
		EndDo
	EndIf
	cFilRSH := xFilial("RSH")
	RSH->(DBSetOrder(1))
	If RSH->(DBSeek(cFilRSH+RSC->RSC_NUMPED))
		Do While !RSH->(Eof()) .And. cFilRSH+RSC->RSC_NUMPED ==  RSH->RSH_FILIAL+RSH->RSH_NUMPED
			nPsIvas := aScan(aIVAS, {|x| x[1] == RSH->RSH_PORIVA})
			If nPsIvas == 0
				aAdd(aIVAS,{RSH->RSH_PORIVA,RSH->RSH_IMPPAG,RSH->RSH_IMPIVA}  )
			Else
				aIVAS[nPsIvas,2] += RSH->RSH_IMPPAG
				aIVAS[nPsIvas,3] += RSH->RSH_IMPIVA
			EndIf
			RSH->(DBSkip())
		EndDo
	EndIf

Return aIvas

/*/{Protheus.doc} M447CPYFILE
Función para copiar el XML de las facturas al Servidor y retorna la ruta que será 
guardada en el campo F1_RUTDOC pasada como parámetro de referencia
@type FUNCTION
@author mayra.camargo
@since 22/03/2018
@version 1.0
/*/
Static Function M447CPYFILE(cRutaXml)
	Local _aArea	:= GetArea()
	Local cFName    := ""
	Local cXMLPro := SuperGetMV("MV_XMLPRO",.F.,"")
	Local cPathSrv:= ""
	
	If  !Empty(cRutaXml)		
		cFName   := ALLTRIM(Substr(cRutaXml,rat("\",cRutaXml) + 1))   //Obtener solo el nombre del archivo  (xxx.XML)
		cPathSrv := cXMLPro+"\"+cFName
		If  !File(cPathSrv)
			If !(__CopyFile(cRutaXml, cPathSrv))
				Return .F.
			Endif
		Endif
		// sE ELIMINA EXTENSIÓN DEL archivo
		cFName   := ALLTRIM(Substr(cFName,1,rat(".",cFName) - 1))
		cPathSrv := cXMLPro+"\"+cFName
		cRutaXML := cPathSrv
	EndIf
	RestArea(_aArea)
Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M447VLDTes  ³ Autor ³  Marco Augusto     ³ Data ³ 17/07/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Tes ingresada en los items de un Pedimento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Tipo de Entrada.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447VLDTes(cTes)

	Local lRet		:= .T.
	Local cTesMI	:= SuperGetMV("MV_MXTESIM", .F., "")
	
	Default cTes	:= ""
	
	If cTes == AllTrim(cTesMI)
		Help(" ", 1, "M447TESOK") //"El Tipo de Entrada informada, está configurada en el parámetro MV_MXTESIM para el cálculo de Impuestos de Importación, por lo que no puede ser utilizada en la pestaña Ítems."
		lRet := .F.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT447BActI  ³ Autor ³  Marco Augusto     ³ Data ³ 03/07/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Actualiza D1_PEDIM para Facturas de Extracción contenidas  ³±±
±±³          ³ en el Pedimento.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Numero de Pedimento.                                ³±±
±±³Parametros³ ExpN1: Numero de Operacion 3-Incluir / 5-Eliminar.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447BActI(cNumPed, nNumOpe)

	Local nIter		:= 0
	Local aAreaTrb	:= GetArea()
	
	Default cNumPed	:= ""
	Default nNumOpe	:= 0
	
	DBSelectArea("SD1")
	DBSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	
	/*
	* aItemsPedi[1] = D1_FILIAL
	* aItemsPedi[2] = D1_DOC
	* aItemsPedi[3] = D1_SERIE
	* aItemsPedi[4] = D1_FORNECE
	* aItemsPedi[5] = D1_LOJA
	* aItemsPedi[6] = D1_COD
	* aItemsPedi[7] = D1_ITEM
	*/
	
	For nIter := 1 To Len(aItemsPedi)
		If SD1->(DBSeek(aItemsPedi[nIter][1]+aItemsPedi[nIter][2]+aItemsPedi[nIter][3]+aItemsPedi[nIter][4]+aItemsPedi[nIter][5]+aItemsPedi[nIter][6]+aItemsPedi[nIter][7]))
			RecLock("SD1", .F.)
			If nTipoAcc == 3
				SD1->D1_PEDIM := cNumPed
			Else
				SD1->D1_PEDIM := ""
			EndIf
			SD1->(MsUnlock())
		EndIf
	Next nIter
	
	RestArea(aAreaTrb)
	
Return

/*/{Protheus.doc} ActSaldoOC
Actualiza el saldo de la orden de compra con respecto al pedimento
@type function
@author guadalupe.santacruz
@since 05/04/2020
@version 1.0
@param cFac, carácter, (Folio de la factura)
@param cSer, carácter, (Serie de la factura)
@param cPrv, carácter, (Código del proveedor de la factura)
@param cTda, carácter, (Código de la tienda de la factura)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function	ActSaldoOC(cFac,cSer,cPrv,cTda)
	SC7->(DBSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	IF nTipoAcc == 3				
		SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		IF SD1->(DBSeek(xFilial("SD1")+cFac+cSer+cPrv+cTda))
		   DO WHILE !SD1->(EOF()) .AND. xFilial("SD1")+cFac+cSer+cPrv+cTda==SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		   		If !EMPTY(SD1->D1_PEDIDO)
		   			If SC7->(dbSeek(xFilial("SC7")+SD1->D1_PEDIDO+sd1->D1_ITEMPC))
						RecLock("SC7",.F.)
						SC7->C7_QTDACLA -= SD1->D1_QUANT
						SC7->(MsUnLock())
					EndIf
				ENDIF
				SD1->(DBSKIP())
			ENDDO	
		ENDIF
	ELSE
	RSE->(DBSetOrder(1)) //RSE_FILIAL+RSE_NUMPED+RSE_FACT+RSE_SERIE+RSE_PROV+RSE_TDA
	If RSE->(DBSeek(xFilial("RSE")+RSC->RSC_NUMPED+cfac+cSer+cPrv+cTda))
		RSF->(DBSetOrder(1)) //RSF_FILIAL+RSF_NUMPED+RSF_ITEDOC+RSF_ITEM
		IF RSF->(DBSeek(xFilial("RSF")+RSC->RSC_NUMPED+RSE->rse_item))
		   DO WHILE !RSF->(EOF()) .AND. xFilial("RSF")+RSC->RSC_NUMPED+RSE->rse_item== RSF->RSF_FILIAL+RSF->RSF_NUMPED+RSF->RSF_ITEDOC
		   		If !EMPTY(RSF->RSF_PEDIDO)
		   			If SC7->(dbSeek(xFilial("SC7")+RSF->RSF_PEDIDO+RSF->RSF_ITEMPC))
						RecLock("SC7",.F.)
							SC7->C7_QTDACLA += RSF->RSF_CANT
						SC7->(MsUnLock())
					EndIf
				ENDIF
				RSF->(DBSKIP())
			ENDDO	
			ENDIF
		ENDIF
	ENDIF
Return

/*/{Protheus.doc} M447VldCon
Funcion utilizada para determinar si el titulo tiene baja automática.

@type Static Function
@author Marco Augusto González Rivera
@since 12/07/2021
@version 1.0
@param cNumDoc, carácter, Folio del documento
@param cSerie, carácter, Serie del documento
@param cProv, carácter, Código del Proveedor
@param cTienda, carácter, Código de la tienda del Proveedor
@param cEspecie, carácter, Especie del documento
@return lRet, lógico, .T. si el título tiene baja automática
@example M447VldCon(cNumDoc, cSerie, cProv, cTienda, cEspecie)
/*/
Static function	M447VldCon(cNumDoc, cSerie, cProv, cTienda, cEspecie)
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cTRBSF1	:= GetNextAlias()
	Local cTRBSE4	:= GetNextAlias()

	BeginSql Alias cTRBSF1
		SELECT F1_COND
		FROM %table:SF1% SF1
		WHERE SF1.F1_FILIAL = %xFilial:SF1% 
		AND SF1.F1_DOC = %Exp:cNumDoc%
		AND SF1.F1_SERIE = %Exp:cSerie%
		AND SF1.F1_FORNECE = %Exp:cProv%
		AND SF1.F1_LOJA = %Exp:cTienda%
		AND SF1.F1_ESPECIE = %Exp:cEspecie%
		AND SF1.%notDel%
	EndSql

	If !Empty((cTRBSF1)->F1_COND)
		BeginSql Alias cTRBSE4
			SELECT E4_BXTITAV
			FROM %table:SE4% SE4
			WHERE SE4.E4_FILIAL = %xFilial:SE4% 
			AND SE4.E4_CODIGO = %Exp:(cTRBSF1)->F1_COND%
			AND SE4.%notDel%
		EndSql
		If (cTRBSE4)->E4_BXTITAV == "1"
			lRet := .T.
		EndIf
		(cTRBSE4)->(DBCloseArea())
	EndIf

	(cTRBSF1)->(DBCloseArea())
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} VldLibMet
	Función utilizada para validar si el ambiente tiene la libreria para
	utilización de Metrícas Protheus.

	@type Static Function
	@author marco.rivera
	@since 05/10/2021
	@version 1.0
	@return lRet, Lógico, Retorna .T. si la LIB puede ser utilizada para Telemetria.
	@example
	VldLibMet()
	/*/
Static Function VldLibMet()
	Local lRet	:= .F.

	lRet := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lRet
