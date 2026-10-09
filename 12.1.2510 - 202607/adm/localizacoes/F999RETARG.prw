#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'
#include 'fwlibversion.ch'

Static _lMetric	:= Nil
Static aImpSE2  := {}

/*/{Protheus.doc} F999RETARG
	Clase responsable por el evento de reglas de negocio de retención de Argentina
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999RETARG From FwModelEvent 

	DATA cFincTal As Character

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
	Method ModelPosVld()

	Method BeforeTTS()

	Method InTTS()

	Method AfterTTS()

	Method F999UPDRET()

	Method F999GRVRET()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999RETARG
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@param 		oModel - objeto	  - Modelo de datos.
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999RETARG
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT

		Pergunte("FIN850P", .F., /*cTitle*/, .F., /*oDlg*/, .T.)

		self:cFincTal := SuperGetMv("MV_FINCTAL",.F.,"1")

	EndIf

Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.
@type 		Method
@param 		oModel - objeto	  - Modelo de dados de Clientes.
@param 		cID	   - caracter - Identificador do sub-modelo.
@author 	carlos.espinoza	
@version	12.2.2310 / Superior
@since		09/01/2026 
/*/
Method BeforeTTS(oModel, cModelId) Class F999RETARG
Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:F999UPDRET(oModel)
	EndIf     	

Return

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	- Modelo de dados.
@param 		cModelId - caracter	- Identificador do sub-modelo.
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		05/02/2026 
/*/
Method InTTS(oModel, cModelId) Class F999RETARG
Local nOperation	:= oModel:GetOperation()
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		self:F999GRVRET(oModel)
	EndIf

Return Nil

/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio de retenciones 
después de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	 - Modelo de dados de Clientes.
@param 		cModelId - caracter	 - Identificador do sub-modelo.
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/04/2026 
/*/
Method AfterTTS(oModel, cModelId) Class F999RETARG
Local nOperation	:= oModel:GetOperation()
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local nX			:= 0
Local aArea			:= {}
Local lF850Ret		:= ExistBlock("F850RET")
Local oJImp 		:= JsonObject():New()
Local cTamPref		:= ""
Local cTamParc		:= ""
Local nTamNum		:= 0
Local cNumCrt		:= ""

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")

		If Type("aTitImp") == "A"
			aTitImp := ACLONE(aImpSE2)
		EndIf

		aImpSE2 := {}

		If lF850Ret
			oJImp['I'] := {"IV-","IVA"}
			oJImp['B'] := {"IB-","IB"}
			oJImp['S'] := {"SU-","SUSS"}
			oJImp['L'] := {"SL-","SIL"}
			oJImp['M'] := {"SI-","SIS"}
			oJImp['G'] := {"GN-","GAN"}
			cTamPref   := PadR("", GetSx3Cache("EK_PREFIXO", "X3_TAMANHO"))
			cTamParc   := PadR("", GetSx3Cache("EK_PARCELA", "X3_TAMANHO"))
			nTamNum    := GetSx3Cache("EK_NUM", "X3_TAMANHO")

			aArea := GetArea()
			For nX := 1 To oModelSFE:Length()
				oModelSFE:GoLine(nX)
				DbSelectArea("SFE")
				SFE->(DbSetOrder(9)) //FE_FILIAL+FE_NROCERT+FE_TIPO
				SFE->(MsSeek(xFilial("SFE")+oModelSFE:GetValue("FE_NROCERT")+oModelSFE:GetValue("FE_TIPO")))
				While !SFE->(EOF()) .And. SFE->FE_FILIAL == oModelSFE:GetValue("FE_FILIAL"); 
									.And. SFE->FE_NROCERT == oModelSFE:GetValue("FE_NROCERT");
									.And. SFE->FE_TIPO == oModelSFE:GetValue("FE_TIPO")

					If SFE->FE_ORDPAGO == oModelSFE:GetValue("FE_ORDPAGO")
						cNumCrt := StrZero(Val(oModelSFE:GetValue("FE_NROCERT")),nTamNum)
						DbSelectArea("SEK")
						SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
						If SEK->(MsSeek(xFilial("SEK")+oModelSFE:GetValue("FE_ORDPAGO")+"RG"+cTamPref+cNumCrt+cTamParc+oJImp[SFE->FE_TIPO][1]))
							ExecBLock("F850RET",.F.,.F.,oJImp[SFE->FE_TIPO][2])
							Exit
						EndIf
					EndIf
					SFE->(DbSkip())
				EndDo
			Next
			RestArea(aArea)
		EndIf

	EndIf

	FreeObj(oJImp)

Return Nil

/*/{Protheus.doc} ModelPosVld
	Método responsable por ejecutar las validaçioes de las reglas de negocio
	genéricas del cadastro antes de la grabación del formulario.
	Si retorna falso, no permite grabar.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
	@param 		
		oModel	 ,objeto	,Modelo de dados.
		cModelID ,caracter	,Identificador do sub-modelo.
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Method ModelPosVld(oModel,cModelID) Class F999RETARG
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local oModelEOP		:= oModel:GetModel("EOP_MASTER") As Object
Local oModelFJR		:= oModel:GetModel("FJR_MASTER") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet
			For nX := 1 To oModelFJR:Length()
				If lRet .And. !VldRetIVA(oModelFJR:GetValue("IVA",nX),oModelEOP:GetValue("PA"))
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldRetIVA
	Función que valida la retención de IVA
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		02/09/2025
	@param 		
		nTotalIVA  - numérico  - Total de Retención de IVA
		lPA  	   - lógico    - Moneda de la orden de pago
	@return
		lRet - lógico - indica si puede o no utilizar el título financiero
/*/
Function VldRetIVA(nTotalIVA, lPA)
Local lRet := .T.

Default nTotalIVA 	:= 0
Default lPA			:= .F.

	If !lPA .And. nTotalIVA < 0
		//No se permite retención de IVA negativo
		Help(" ",1,"A085RETIVA")
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} F999UPDRET
Metodo responsable por realizar las actualizaciones en el modelo de retenciones
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		16/01/2025 
/*/
Method F999UPDRET(oModel) Class F999RETARG
Local nTamNum	:= GetSx3Cache("EK_NUM","X3_TAMANHO")
Local nTamMoe	:= GetSx3Cache("EK_MOEDA","X3_TAMANHO")
Local cFilSFE	:= xFilial("SFE")
Local cFilSEK	:= xFilial("SEK")
Local oModelEOP := oModel:GetModel("EOP_MASTER")
Local cJCotiz	:= oModelEOP:GetValue("COTIZ")
Local oJCotiz 	:= JsonObject():New()

Default oModel := Nil

	aImpSE2 := {}

	oJCotiz:FromJson(cJCotiz)

	UPDRETIVA(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)

	UPDRETIB(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz, self:cFincTal)

	UPDRETSUSS(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)

	UPDRETSLI(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)

	UPDRETISI(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)

	UPDRETGAN(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)

Return Nil

/*/{Protheus.doc} F999GRVRET
Metodo responsable por realizar las operaciones de grabado relacionadas al proceso de retenciones
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		05/02/2025 
/*/
Method F999GRVRET(oModel) Class F999RETARG
Local cAgente    := SuperGetMv("MV_AGENTE",.F.,"")
Local lTitRet    := SuperGetMv("MV_TITRET",.F.,.F.)
Local lReSaIV	 := SuperGetMv("MV_RETIVA",.F.,"N") == "S" .And. SuperGetMv("MV_RETSUSS",.F.,"N") == "S"

Default oModel := Nil

	GRVRETIVA(oModel, cAgente, lTitRet, lReSaIV, self:cFincTal)

	GRVRETIB(oModel, lTitRet, self:cFincTal)

	GRVRETSUSS(oModel, lTitRet, lReSaIV, self:cFincTal)

	GRVRETSLI(oModel, lTitRet, self:cFincTal)

	GRVRETISI(oModel, lTitRet, self:cFincTal)

	GRVRETGAN(oModel, lTitRet, self:cFincTal)

Return Nil

/*/{Protheus.doc} UPDRETIVA
Función que se encarga de actualizar las retenciones de IVA en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		16/01/2026 
/*/
Static Function UPDRETIVA(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local nTxMoeda		:= 1
Local aTxEmis		:= {}

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil

	//Adiciona las retenciones acumuladas de IVA para crear los certificados de retención
	If Type("aRetIvAcm[3]") == "A"
		For nX := 1 to Len(aRetIvAcm[3])
			If aRetIvAcm[3][nX][6] != 0
				If !Empty(oModelSFE:GetValue("FE_NFISCAL"))
					oModelSFE:AddLine()
				EndIf
				oModelSFE:LoadValue("FE_NFISCAL", aRetIvAcm[3][nX][1])
				oModelSFE:LoadValue("FE_SERIE"	, aRetIvAcm[3][nX][2])
				oModelSFE:LoadValue("FE_VALBASE", aRetIvAcm[3][nX][3])
				oModelSFE:LoadValue("FE_VALIMP"	, aRetIvAcm[3][nX][4])
				oModelSFE:LoadValue("FE_PORCRET", aRetIvAcm[3][nX][5])
				oModelSFE:LoadValue("FE_RETENC" , aRetIvAcm[3][nX][6])
				oModelSFE:LoadValue("FE_CFO"	, IIF(!Empty(aRetIvAcm[3][nX][11]),aRetIvAcm[3][nX][11],aRetIvAcm[3][nX][9]))
				oModelSFE:LoadValue("FE_ALIQ"	, aRetIvAcm[3][nX][10])
				oModelSFE:LoadValue("FE_TIPO"	, "I")
				oModelSFE:LoadValue("FE_FORNECE", oModelFJR:GetValue("FJR_FORNEC"))
				oModelSFE:LoadValue("FE_LOJA"	, oModelFJR:GetValue("FJR_LOJA"))
				oModelSFE:LoadValue("FE_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG"))
			EndIf
		Next
	EndIf

	For nX := 1 To oModelSFE:Length()
		lSeekSE2 := .F.
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "I" .And. oModelSFE:GetValue("FE_RETENC") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

			cNroCert  := F999GetCert("IVA  ", oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")+"IVA")
			oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
			oModelSFE:LoadValue("FE_NROCERT", cNroCert)
			oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
			oModelSFE:LoadValue("FE_PARCELA", IIF(lSeekSE2, oModelSE2:GetValue("E2_PARCELA"), ""))
			oModelSFE:LoadValue("FE_NUMOPER", oModelFJR:GetValue("NUMOP"))
			oModelSFE:LoadValue("FE_TPCALR"	, "A")
			oModelSFE:LoadValue("FE_SDOC"	, oModelSFE:GetValue("FE_SERIE"))

			If oJCotiz['lCpoCotiz'] .And. lSeekSE2
				F999TxSFE(oModelSE2:GetValue("E2_TXMOEDA"), oJCotiz, oModelSFE)
			EndIf

			If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
				oModelTTB:AddLine()
			EndIf

			oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
			oModelTTB:LoadValue("EK_TIPODOC", "RG")
			oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
			oModelTTB:LoadValue("EK_TIPO"	, "IV-")
			oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
			oModelTTB:LoadValue("EK_VLMOED1", oModelSFE:GetValue("FE_RETENC")) 
			oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
			oModelTTB:LoadValue("EK_SALDO"	, oModelTTB:GetValue("EK_VALOR"))
			oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
			oModelTTB:LoadValue("EK_FORNECE", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJA"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_MOEDA"	, StrZero(oModelFJR:GetValue("NMOERET"),nTamMoe))
			oModelTTB:LoadValue("EK_ORDPAGO", oModelSFE:GetValue("FE_ORDPAGO"))
			oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
			oModelTTB:LoadValue("EK_NUMOPER", oModelFJR:GetValue("NUMOP"))
			oModelTTB:LoadValue("EK_FORNEPG", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJAPG"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
			oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
			If oModelTTB:HasField("EK_CCR")
				oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
			EndIf

			If lSeekSE2
				oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
				nTxMoeda := oModelMOE:GetValue("TASA")
				If oJCotiz['lCpoCotiz']
					nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
					aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
				EndIf
				F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
			EndIf
		EndIf
	Next

Return Nil

/*/{Protheus.doc} UPDRETIB
Función que se encarga de actualizar las retenciones de Ingresos Brutos en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
		cFincTal - caracter   - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		10/02/2026 
/*/
Static Function UPDRETIB(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local nSFEValImp 	:= 0
Local nSFERetenc 	:= 0
Local nSFEValBas 	:= 0
Local nTasaRet		:= 1
Local nTxMoeda		:= 1
Local aTxEmis		:= {}
Local oRetIb		:= JsonObject():New()
Local lPgAdi		:= IsInCallStack("F850PgAdi")

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil
Default cFincTal	:= ""

	For nX := 1 To oModelSFE:Length()
		lSeekSE2 := .F.
		oModelSFE:GoLine(nX)
		If !oModelSFE:GetValue("NOCALC") .And. oModelSFE:GetValue("FE_TIPO") == "B" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

			If oModelSFE:GetValue("FE_RETENC") != 0
				cNroCert :=	F850GetCert("IB "+oModelSFE:GetValue("FE_EST"),oModelFJR:GetValue("FJR_FORNEC")+oModelFJR:GetValue("FJR_LOJA")+"IB "+oModelSFE:GetValue("FE_EST"))
			Else
				cNroCert := "NORET"
			EndIf

			nSFEValBas := oModelSFE:GetValue("FE_VALBASE")
			If AllTrim(oModelSFE:GetValue("FE_TPCALR")) == "I"
				nSFEValImp := oModelSFE:GetValue("FE_RETENC")
				nSFERetenc := nSFEValImp
			Else
				nSFEValImp := IIF(oModelSFE:GetValue("ESRETADC"),(oModelSFE:GetValue("FE_RETENC")*oModelSFE:GetValue("ALIQRET"))/oModelSFE:GetValue("FE_ALIQ"),oModelSFE:GetValue("FE_RETENC"))
				nSFERetenc := nSFEValImp
			EndIf
			
			nTasaRet := oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))
			If oModelEOP:GetValue("PA") .And. !(lPgAdi .And. oModelFJR:GetValue("NMOERET") <> 1 .And. cFincTal <> "2")
				If cFincTal == "2" .And. oModelFJR:GetValue("NMOERET") <> 1  
					nSFEValBas 	:= Round(xMoeda(nSFEValBas,1,1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFEValImp 	:= Round(xMoeda(nSFEValImp,1,oModelFJR:GetValue("NMOERET"),,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFERetenc  := Round(xMoeda(nSFERetenc,1,oModelFJR:GetValue("NMOERET"),,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
				Else
					nSFEValBas 	:= Round(xMoeda(nSFEValBas,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFEValImp 	:= Round(xMoeda(nSFEValImp,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFERetenc  := Round(xMoeda(nSFERetenc,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
				EndIf
			EndIf

			oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
			oModelSFE:LoadValue("FE_NROCERT", cNroCert)
			oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
			oModelSFE:LoadValue("FE_FORNECE", oModelFJR:GetValue("FJR_FORNEC"))
			oModelSFE:LoadValue("FE_LOJA"	, oModelFJR:GetValue("FJR_LOJA"))
			oModelSFE:LoadValue("FE_PARCELA", IIF(lSeekSE2, oModelSE2:GetValue("E2_PARCELA"), ""))
			oModelSFE:LoadValue("FE_VALBASE", nSFEValBas)
			oModelSFE:LoadValue("FE_ALIQ"	, IIF(oModelSFE:GetValue("ESRETADC"),oModelSFE:GetValue("FE_ALIQ")-oModelSFE:GetValue("ALIQADC"),oModelSFE:GetValue("FE_ALIQ")))
			oModelSFE:LoadValue("FE_SDOC"	, oModelSFE:GetValue("FE_SERIE"))
			
			If cFincTal == "2" .And. oModelFJR:GetValue("NMOERET") <> 1 .And. oModelEOP:GetValue("PA")  
				oModelSFE:LoadValue("FE_VALIMP", Round(xMoeda(nSFEValImp,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET"))))
				oModelSFE:LoadValue("FE_RETENC", Round(xMoeda(nSFERetenc,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET"))))
			Else
				oModelSFE:LoadValue("FE_VALIMP", nSFEValImp)
				oModelSFE:LoadValue("FE_RETENC", nSFERetenc)
			EndIf	

			If oJCotiz['lCpoCotiz'] .And. lSeekSE2
				F999TxSFE(oModelSE2:GetValue("E2_TXMOEDA"), oJCotiz, oModelSFE)
			EndIf

			If oModelSFE:GetValue("ESRETADC")  //Generar Retencion Adicional
				oRetIb := JsonObject():New()
				oRetIb['ordpago'] := oModelSFE:GetValue("FE_ORDPAGO")
				oRetIb['parcela'] := oModelSFE:GetValue("FE_PARCELA")
				oRetIb['nfiscal'] := oModelSFE:GetValue("FE_NFISCAL")
				oRetIb['serie']   := oModelSFE:GetValue("FE_SERIE")
				oRetIb['est']     := oModelSFE:GetValue("FE_EST")
				oRetIb['cfo']     := oModelSFE:GetValue("CFORA")
				oRetIb['concept'] := oModelSFE:GetValue("FE_CONCEPT")
				oRetIb['deduc']   := oModelSFE:GetValue("FE_DEDUC")
				oRetIb['porcret'] := oModelSFE:GetValue("FE_PORCRET")
				oRetIb['txcotiz'] := oModelSFE:GetValue("FE_TXCOTIZ")
				oRetIb['aliq']    := oModelSFE:GetValue("FE_ALIQ")
				oRetIb['aliqadc'] := oModelSFE:GetValue("ALIQADC")
				oRetIb['retadc']  := oModelSFE:GetValue("ESRETADC")

				nSFEValBas := oModelSFE:GetValue("FE_VALBASE")
				nSFEValImp := IIF(oModelSFE:GetValue("ESRETADC"),(oModelSFE:GetValue("FE_RETENC")*oModelSFE:GetValue("ALIQADC"))/oModelSFE:GetValue("FE_ALIQ"),oModelSFE:GetValue("FE_RETENC"))
				nSFERetenc := nSFEValImp
				
				If oModelEOP:GetValue("PA")  
					nSFEValBas	:=	Round(xMoeda(nSFEValBas,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFEValImp	:=	Round(xMoeda(nSFEValImp,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
					nSFERetenc	:=	Round(xMoeda(nSFERetenc,oModelFJR:GetValue("NMOERET"),1,,3,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET")))
				EndIf

				If !Empty(oModelSFE:GetValue("FE_ORDPAGO"))
					oModelSFE:AddLine()
				EndIf
				
				oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
				oModelSFE:LoadValue("FE_NROCERT", cNroCert)
				oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
				oModelSFE:LoadValue("FE_FORNECE", oModelFJR:GetValue("FJR_FORNEC"))
				oModelSFE:LoadValue("FE_LOJA"	, oModelFJR:GetValue("FJR_LOJA"))
				oModelSFE:LoadValue("FE_TIPO"	, "B")
				oModelSFE:LoadValue("FE_ORDPAGO", oRetIb['ordpago'])
				oModelSFE:LoadValue("FE_PARCELA", oRetIb['parcela'])
				oModelSFE:LoadValue("FE_NFISCAL", oRetIb['nfiscal'])
				oModelSFE:LoadValue("FE_SERIE"  , oRetIb['serie'])
				oModelSFE:LoadValue("FE_VALBASE", nSFEValBas)
				oModelSFE:LoadValue("FE_ALIQ"	, Round(xMoeda(IIF(oRetIb['retadc'],oRetIb['aliqadc'],oRetIb['aliq']),oModelFJR:GetValue("NMOERET"),1,,3,,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET"))))
				oModelSFE:LoadValue("FE_VALIMP" , nSFEValImp)
				oModelSFE:LoadValue("FE_RETENC" , nSFERetenc)
				oModelSFE:LoadValue("FE_EST"    , oRetIb['est'])
				oModelSFE:LoadValue("FE_CFO"    , oRetIb['cfo'])
				oModelSFE:LoadValue("FE_CONCEPT", oRetIb['concept'])
				oModelSFE:LoadValue("FE_DEDUC"  , oRetIb['deduc'])
				oModelSFE:LoadValue("FE_PORCRET", oRetIb['porcret'])
				oModelSFE:LoadValue("FE_TXCOTIZ", oRetIb['txcotiz'])
				oModelSFE:LoadValue("NOCALC"	, .T.)
			EndIf  

			If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
				oModelTTB:AddLine()
			EndIf

			oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
			oModelTTB:LoadValue("EK_TIPODOC", "RG")
			oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
			oModelTTB:LoadValue("EK_TIPO"	, "IB-")
			oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
			oModelTTB:LoadValue("EK_VLMOED1", nSFEValImp) 
			oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(nSFEValImp,1,oModelFJR:GetValue("NMOERET"),,3,,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET"))))
			oModelTTB:LoadValue("EK_SALDO"	, Round(xMoeda(nSFEValImp,1,oModelFJR:GetValue("NMOERET"),,3,,nTasaRet),MsDecimais(oModelFJR:GetValue("NMOERET"))))
			oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
			oModelTTB:LoadValue("EK_FORNECE", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJA"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_MOEDA"	, StrZero(IIF(oModelEOP:GetValue("PA") .And. cFincTal <> "2", 1, oModelFJR:GetValue("NMOERET")), nTamMoe))
			oModelTTB:LoadValue("EK_ORDPAGO", oModelSFE:GetValue("FE_ORDPAGO"))
			oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
			oModelTTB:LoadValue("EK_EST"	, oModelSFE:GetValue("FE_EST"))
			oModelTTB:LoadValue("EK_FORNEPG", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJAPG"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
			oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
			If oModelTTB:HasField("EK_CCR") .And. !oModelEOP:GetValue("PA")
				oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
			EndIf

			If lSeekSE2
				oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
				nTxMoeda := oModelMOE:GetValue("TASA")
				If oJCotiz['lCpoCotiz']
					nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
					aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
				EndIf
				F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
			EndIf
		EndIf
	Next

	FreeObj(oRetIb)

Return Nil

/*/{Protheus.doc} UPDRETSUSS
Función que se encarga de actualizar las retenciones de SUSS en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/02/2026 
/*/
Static Function UPDRETSUSS(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local nS			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local aRatSUSS		:= {}
Local oRetSuss		:= JsonObject():New()
Local nTxMoeda		:= 1
Local aTxEmis		:= {}
Local cFornece      := ""
Local cLoja			:= ""

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil

	For nX := 1 To oModelSFE:Length()
		lSeekSE2 := .F.
		oModelSFE:GoLine(nX)
		If !oModelSFE:GetValue("NOCALC") .And. oModelSFE:GetValue("FE_TIPO") == "S" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

			cFornece := IIF(lSeekSE2, oModelSE2:GetValue("E2_FORNECE"), oModelFJR:GetValue("FJR_FORNEC"))
			cLoja	 := IIF(lSeekSE2, oModelSE2:GetValue("E2_LOJA"), oModelFJR:GetValue("FJR_LOJA"))

			aRatSUSS := F999RatSus(cFornece,cLoja)

			oRetSuss := JsonObject():New()
			oRetSuss['ordpago'] := oModelSFE:GetValue("FE_ORDPAGO")
			oRetSuss['parcela'] := oModelSFE:GetValue("FE_PARCELA")
			oRetSuss['nfiscal'] := oModelSFE:GetValue("FE_NFISCAL")
			oRetSuss['serie']   := oModelSFE:GetValue("FE_SERIE")
			oRetSuss['valbase'] := oModelSFE:GetValue("FE_VALBASE")
			oRetSuss['valimp']  := oModelSFE:GetValue("FE_VALIMP")
			oRetSuss['concept'] := oModelSFE:GetValue("FE_CONCEPT")
			oRetSuss['porcret'] := oModelSFE:GetValue("FE_PORCRET")
			oRetSuss['retenc']  := oModelSFE:GetValue("FE_RETENC")
			oRetSuss['aliq']    := oModelSFE:GetValue("FE_ALIQ")
			oRetSuss['fornece'] := cFornece
			oRetSuss['loja']    := cLoja

			For nS := 1 To Len(aRatSUSS)
				If oModelSFE:GetValue("FE_RETENC") != 0
					If aRatSUSS[nS][4] == .T.
						cNroCert :=	F999GetCert("US   ",aRatSUSS[nS][1]+aRatSUSS[nS][2]+"US "+oModelSFE:GetValue("FE_CONCEPT"))
					Else
						cNroCert :=	F999GetCert("SU   ",aRatSUSS[nS][1]+aRatSUSS[nS][2]+"SU "+oModelSFE:GetValue("FE_CONCEPT"))
					EndIf
				Else
					cNroCert := "NORET"
				EndIf

				If nS > 1
					oModelSFE:AddLine()
				EndIf

				oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
				oModelSFE:LoadValue("FE_NROCERT", cNroCert)
				oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
				oModelSFE:LoadValue("FE_FORNECE", aRatSUSS[nS][1])
				oModelSFE:LoadValue("FE_LOJA"	, aRatSUSS[nS][2])
				oModelSFE:LoadValue("FE_TIPO"	, IIF(aRatSUSS[nS][4] == .T., "U", "S"))
				oModelSFE:LoadValue("FE_ORDPAGO", oRetSuss['ordpago'])
				oModelSFE:LoadValue("FE_PARCELA", IIF(lSeekSE2, oModelSE2:GetValue("E2_PARCELA"), ""))
				oModelSFE:LoadValue("FE_NFISCAL", oRetSuss['nfiscal'])
				oModelSFE:LoadValue("FE_SERIE"	, oRetSuss['serie'])
				oModelSFE:LoadValue("FE_SDOC"	, oRetSuss['serie'])
				oModelSFE:LoadValue("FE_NUMOPER", oModelFJR:GetValue("NUMOP"))
				oModelSFE:LoadValue("FE_TPCALR"	, "A")
				oModelSFE:LoadValue("FE_VALBASE", oRetSuss['valbase'] * aRatSUSS[nS][3])
				oModelSFE:LoadValue("FE_VALIMP"	, oRetSuss['valimp'] * aRatSUSS[nS][3])
				oModelSFE:LoadValue("FE_PORCRET", oRetSuss['porcret'])
				oModelSFE:LoadValue("FE_RETENC"	, oRetSuss['retenc'] * aRatSUSS[nS][3])
				oModelSFE:LoadValue("FE_FORCOND", oRetSuss['fornece'])
				oModelSFE:LoadValue("FE_LOJCOND", oRetSuss['loja'])
				oModelSFE:LoadValue("FE_ALIQ"	, oRetSuss['aliq'])
				oModelSFE:LoadValue("FE_CONCEPT", oRetSuss['concept'])
				oModelSFE:LoadValue("NOCALC"	, .T.)

				If oJCotiz['lCpoCotiz'] .And. lSeekSE2
					F999TxSFE(oModelSE2:GetValue("E2_TXMOEDA"), oJCotiz, oModelSFE)
				EndIf

				If oModelSFE:GetValue("FE_RETENC") != 0
					If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
						oModelTTB:AddLine()
					EndIf

					oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
					oModelTTB:LoadValue("EK_TIPODOC", "RG")
					oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
					oModelTTB:LoadValue("EK_TIPO"	, IIF(aRatSUSS[nS][4] == .T., "SS-", "SU-"))
					oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
					oModelTTB:LoadValue("EK_VLMOED1", oRetSuss['retenc'] * aRatSUSS[nS][3]) 
					oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(oRetSuss['retenc'] * aRatSUSS[nS][3],1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
					oModelTTB:LoadValue("EK_SALDO"	, oModelTTB:GetValue("EK_VALOR"))
					oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
					oModelTTB:LoadValue("EK_FORNECE", aRatSUSS[nS][1])
					oModelTTB:LoadValue("EK_LOJA"	, aRatSUSS[nS][2])
					oModelTTB:LoadValue("EK_MOEDA"	, StrZero(oModelFJR:GetValue("NMOERET"),nTamMoe))
					oModelTTB:LoadValue("EK_ORDPAGO", oRetSuss['ordpago'])
					oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
					oModelTTB:LoadValue("EK_NUMOPER", oModelFJR:GetValue("NUMOP"))
					oModelTTB:LoadValue("EK_FORNEPG", oRetSuss['fornece'])
					oModelTTB:LoadValue("EK_LOJAPG"	, oRetSuss['loja'])
					oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
					oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
					oModelTTB:LoadValue("EK_NROCERT", cNroCert)
					If oModelTTB:HasField("EK_CCR")
						oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
					EndIf

					If lSeekSE2
						oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
						nTxMoeda := oModelMOE:GetValue("TASA")
						If oJCotiz['lCpoCotiz']
							nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
							aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
						EndIf
						F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
					EndIf
				EndIf
			Next
		EndIf
	Next
	
	FreeObj(oRetSuss)

Return Nil

/*/{Protheus.doc} UPDRETSLI
Función que se encarga de actualizar las retenciones de SLI en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		10/03/2026 
/*/
Static Function UPDRETSLI(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local nTxMoeda		:= 1
Local aTxEmis		:= {}
Local cFornece      := ""
Local cLoja			:= ""
Local cParcela 		:= ""

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil

	For nX := 1 To oModelSFE:Length()
		lSeekSE2 := .F.
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "L" .And. oModelSFE:GetValue("FE_RETENC") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

			cFornece  := IIF(lSeekSE2, oModelSE2:GetValue("E2_FORNECE"), oModelFJR:GetValue("FJR_FORNEC"))
			cLoja	  := IIF(lSeekSE2, oModelSE2:GetValue("E2_LOJA"), oModelFJR:GetValue("FJR_LOJA"))
			cParcela  := IIF(lSeekSE2, oModelSE2:GetValue("E2_PARCELA"), "")

			cNroCert  := F999GetCert("SI   ", oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")+"SI ")
			oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
			oModelSFE:LoadValue("FE_NROCERT", cNroCert)
			oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
			oModelSFE:LoadValue("FE_FORNECE", cFornece)
			oModelSFE:LoadValue("FE_LOJA"	, cLoja)
			oModelSFE:LoadValue("FE_PARCELA", cParcela)
			oModelSFE:LoadValue("FE_SDOC"	, oModelSFE:GetValue("FE_SERIE"))

			If oJCotiz['lCpoCotiz'] .And. lSeekSE2
				F999TxSFE(oModelSE2:GetValue("E2_TXMOEDA"), oJCotiz, oModelSFE)
			EndIf

			If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
				oModelTTB:AddLine()
			EndIf

			oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
			oModelTTB:LoadValue("EK_TIPODOC", "RG")
			oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
			oModelTTB:LoadValue("EK_TIPO"	, "SL-")
			oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
			oModelTTB:LoadValue("EK_VLMOED1", oModelSFE:GetValue("FE_RETENC")) 
			oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
			oModelTTB:LoadValue("EK_SALDO"	, oModelTTB:GetValue("EK_VALOR"))
			oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
			oModelTTB:LoadValue("EK_FORNECE", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJA"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_MOEDA"	, StrZero(oModelFJR:GetValue("NMOERET"),nTamMoe))
			oModelTTB:LoadValue("EK_ORDPAGO", oModelSFE:GetValue("FE_ORDPAGO"))
			oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
			oModelTTB:LoadValue("EK_FORNEPG", oModelSFE:GetValue("FE_FORNECE"))
			oModelTTB:LoadValue("EK_LOJAPG"	, oModelSFE:GetValue("FE_LOJA"))
			oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
			oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
			If oModelTTB:HasField("EK_CCR")
				oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
			EndIf

			If lSeekSE2
				oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
				nTxMoeda := oModelMOE:GetValue("TASA")
				If oJCotiz['lCpoCotiz']
					nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
					aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
				EndIf
				F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
			EndIf
		EndIf
	Next

Return Nil

/*/{Protheus.doc} UPDRETISI
Función que se encarga de actualizar las retenciones de ISI en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		10/03/2026 
/*/
Static Function UPDRETISI(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local nY			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local nTxMoeda		:= 1
Local aTxEmis		:= {}
Local cFornece      := ""
Local cLoja			:= ""
Local cParcela 		:= ""
Local aGetSx5		:= {}
Local aAreaSA2		:= {}
Local cNomMun		:= ""
Local cEstMun		:= ""
Local cFilSE2		:= cFilAnt

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil

	If !oModelEOP:GetValue("PA") 
		For nX := 1 To oModelSFE:Length()
			lSeekSE2 := .F.
			oModelSFE:GoLine(nX)
			If oModelSFE:GetValue("FE_TIPO") == "M" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
				lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
				oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

				cFornece  := IIF(lSeekSE2, oModelSE2:GetValue("E2_FORNECE"), oModelFJR:GetValue("FJR_FORNEC"))
				cLoja	  := IIF(lSeekSE2, oModelSE2:GetValue("E2_LOJA"), oModelFJR:GetValue("FJR_LOJA"))
				cParcela  := IIF(lSeekSE2, oModelSE2:GetValue("E2_PARCELA"), "")

				If oModelSFE:GetValue("FE_RETENC") != 0
					cNroCert :=	F999GetCert("SIS ", cFornece+cLoja+"SIS ")
				Else
					cNroCert := "NORET"
				EndIf

				If lSeekSE2
					SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
					cFilSE2 := SE2->E2_FILORIG
				EndIf

				//Obtiene el código de la provincia correspondiente al código del municipio que se dió de alta
				aAreaSA2 := SA2->(GetArea())
				SA2->(DbSelectArea("SA2"))
				SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
				SA2->(MsSeek(xFilial("SA2", cFilSE2)+cFornece+cLoja))

				aGetSx5 := FwGetSX5("S1", SA2->A2_RET_MUN)
				IF Len(aGetSx5) > 0
					cNomMun := aGetSx5[1][4]
					aGetSx5 := FwGetSX5("12")

					For nY := 1 To Len(aGetSx5)
						If aGetSx5[nY][4] $ cNomMun
							cEstMun := Alltrim(aGetSx5[nY][3])
						EndIf
					Next
				EndIf

				oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
				oModelSFE:LoadValue("FE_NROCERT", cNroCert)
				oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
				oModelSFE:LoadValue("FE_FORNECE", cFornece)
				oModelSFE:LoadValue("FE_LOJA"	, cLoja)
				oModelSFE:LoadValue("FE_PARCELA", cParcela)
				oModelSFE:LoadValue("FE_SDOC"	, oModelSFE:GetValue("FE_SERIE"))
				oModelSFE:LoadValue("FE_TPCALR"	, "A")

				If !Empty(cEstMun)
					oModelSFE:LoadValue("FE_EST", cEstMun)
				EndIf

				If oJCotiz['lCpoCotiz'] .And. lSeekSE2
					F999TxSFE(oModelSE2:GetValue("E2_TXMOEDA"), oJCotiz, oModelSFE)
				EndIf

				If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
					oModelTTB:AddLine()
				EndIf

				oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
				oModelTTB:LoadValue("EK_TIPODOC", "RG")
				oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
				oModelTTB:LoadValue("EK_TIPO"	, "SI-")
				oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
				oModelTTB:LoadValue("EK_VLMOED1", oModelSFE:GetValue("FE_RETENC")) 
				oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
				oModelTTB:LoadValue("EK_SALDO"	, oModelTTB:GetValue("EK_VALOR"))
				oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
				oModelTTB:LoadValue("EK_FORNECE", oModelSFE:GetValue("FE_FORNECE"))
				oModelTTB:LoadValue("EK_LOJA"	, oModelSFE:GetValue("FE_LOJA"))
				oModelTTB:LoadValue("EK_MOEDA"	, StrZero(oModelFJR:GetValue("NMOERET"),nTamMoe))
				oModelTTB:LoadValue("EK_ORDPAGO", oModelSFE:GetValue("FE_ORDPAGO"))
				oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
				oModelTTB:LoadValue("EK_FORNEPG", oModelSFE:GetValue("FE_FORNECE"))
				oModelTTB:LoadValue("EK_LOJAPG"	, oModelSFE:GetValue("FE_LOJA"))
				oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
				oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
				If oModelTTB:HasField("EK_CCR")
					oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
				EndIf

				If lSeekSE2
					oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
					nTxMoeda := oModelMOE:GetValue("TASA")
					If oJCotiz['lCpoCotiz']
						nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
						aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
					EndIf
					F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
				EndIf

				RestArea(aAreaSA2)
			EndIf
		Next
	EndIf

Return Nil

/*/{Protheus.doc} UPDRETGAN
Función que se encarga de actualizar las retenciones de Ganancias en el modelo
@type 		Method
@param 		
		oModel   - objeto     - Modelo FINA999
		nTamNum  - numérico   - Tamaño del campo EK_NUM
		nTamMoe  - numérico   - Tamaño del campo EK_MOEDA
		cFilSFE  - caracter   - xFilial() de la tabla SFE
		cFilSEK  - caracter   - xFilial() de la tabla SEK
		oJCotiz  - objeto     - Objeto que contiene información de la cotización origen
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		24/03/2026 
/*/
Static Function UPDRETGAN(oModel, nTamNum, nTamMoe, cFilSFE, cFilSEK, oJCotiz)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local nX 			:= 1
Local lSeekSE2		:= .F.
Local cNroCert		:= ""
Local cFornece      := ""
Local cLoja			:= ""
Local aTxProm 		:= {}
Local oJTxProm		:= JsonObject():New()

Default oModel 		:= Nil
Default nTamNum 	:= 0
Default nTamMoe 	:= 0
Default cFilSFE 	:= ""
Default cFilSEK 	:= ""
Default oJCotiz     := Nil

	For nX := 1 To oModelSFE:Length()
		lSeekSE2 := .F.
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "G" .And. oModelSFE:GetValue("FE_VALBASE") != 0
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.) 

			cFornece  := oModelFJR:GetValue("FJR_FORNEC")
			cLoja	  := oModelFJR:GetValue("FJR_LOJA")

			If oModelSFE:GetValue("FE_RETENC") <> 0 .Or. oModelSFE:GetValue("RGANNC") == .T.
				cNroCert :=	F999GetCert("GANAN", cFornece+cLoja+"GANAN", .F.)
			Else
				cNroCert :=	"NORET"
			EndIf

			oModelSFE:LoadValue("FE_FILIAL" , cFilSFE)
			oModelSFE:LoadValue("FE_NROCERT", cNroCert)
			oModelSFE:LoadValue("FE_EMISSAO", dDataBase)
			oModelSFE:LoadValue("FE_FORNECE", cFornece)
			oModelSFE:LoadValue("FE_LOJA"	, cLoja)
			oModelSFE:LoadValue("FE_TPCALR"	, "A")
			If oJCotiz['lCpoCotiz']
				F999TxSFE(oModelFJR:GetValue("NTXPROM"), oJCotiz, oModelSFE)
			EndIf

			If cNroCert <> "NORET"
				If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
					oModelTTB:AddLine()
				EndIf
				oModelTTB:LoadValue("EK_FILIAL" , cFilSEK)
				oModelTTB:LoadValue("EK_TIPODOC", "RG")
				oModelTTB:LoadValue("EK_NUM"	, StrZero(VAL(cNroCert),nTamNum))
				oModelTTB:LoadValue("EK_TIPO"	, "GN-")
				oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
				oModelTTB:LoadValue("EK_VLMOED1", oModelSFE:GetValue("FE_RETENC")) 
				oModelTTB:LoadValue("EK_VALOR"	, Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
				oModelTTB:LoadValue("EK_SALDO"	, oModelTTB:GetValue("EK_VALOR"))
				oModelTTB:LoadValue("EK_VENCTO"	, dDataBase)
				oModelTTB:LoadValue("EK_FORNECE", cFornece)
				oModelTTB:LoadValue("EK_LOJA"	, cLoja)
				oModelTTB:LoadValue("EK_MOEDA"	, StrZero(oModelFJR:GetValue("NMOERET"),nTamMoe))
				oModelTTB:LoadValue("EK_ORDPAGO", oModelSFE:GetValue("FE_ORDPAGO"))
				oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
				oModelTTB:LoadValue("EK_FORNEPG", cFornece)
				oModelTTB:LoadValue("EK_LOJAPG"	, cLoja)
				oModelTTB:LoadValue("EK_PGCBU"	, oModelFJR:GetValue("CBU"))
				oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))
				If oModelTTB:HasField("EK_CCR")
					oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
				EndIf
				
				oJTxProm:FromJson(oModelFJR:GetValue("ATXPROM"))
				aTxProm := oJTxProm['txprom']
				F999GrvTx(oJCotiz['MonedaCotiz'], oModelFJR:GetValue("NTXPROM"), aTxProm, oJCotiz, oModelMOE, oModelTTB)
			EndIf
		EndIf
	Next

Return Nil

/*/{Protheus.doc} GRVRETIVA
Función que se encarga del proceso de afectación de tablas por el proceso de retención de IVA
@type 		Method
@param 		
		oModel     - objeto   - Modelo FINA999
		cAgente    - caracter - Valor del parámetro MV_AGENTE
		lTitRet    - lógico   - Valor del parámetro MV_TITRET
		lReSaIV    - lógico   - Valor de los parámetros MV_RETIVA y MV_RETSUSS
		cFincTal   - caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		16/01/2026 
/*/
Static Function GRVRETIVA(oModel, cAgente, lTitRet, lReSaIV, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nX 			:= 1
Local nContIva 		:= 0
Local aAreaSF1 		:= SF1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local cChave1		:= ""
Local nValRet       := 0
Local cSE2Cert		:= ""
Local lSeekSE2		:= .F.
Local cFilSE2		:= cFilAnt

Default oModel 	    := Nil
Default cAgente  	:= ""
Default lTitRet  	:= .F.
Default lReSaIV  	:= .F.
Default cFincTal  	:= ""

	For nX := 1 To oModelSFE:Length()
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "I" .And. oModelSFE:GetValue("FE_RETENC") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			If lSeekSE2
				SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
				cFilSE2 := SE2->E2_FILORIG
			EndIf

			METRET999("IVA")
			cChave1  := oModelSFE:GetValue("FE_CFO")
			nPos := AScan(aCert, {|x| x[1] == oModelSFE:GetValue("FE_NROCERT") .And. x[2] == "I" .And. x[3] == cChave1})
			If nPos == 0
				AAdd(aCert, {oModelSFE:GetValue("FE_NROCERT"), "I", cChave1})
			EndIf

			//Graba el número da la Orden de Pago en el documento para IVA acumulado
			If Subs(cAgente,2,1) == "S" .And. lReSaIV
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(MsSeek(xFilial("SF1", cFilSE2)+oModelSFE:GetValue("FE_NFISCAL")+oModelSFE:GetValue("FE_SERIE")+oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")))
					RecLock("SF1",.F.)
					If Empty(SF1->F1_RETIVA)
						SF1->F1_RETIVA := oModelSFE:GetValue("RETTOT")
						SF1->F1_SALIVA := oModelSFE:GetValue("RETTOT")
					EndIf
					SF1->F1_SALIVA -= IIF(oModelSFE:GetValue("FE_RETENC") < 0, oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					SF1->(MsUnLock())
				EndIf
				DbSelectArea("SF2")
				SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If SF2->(MsSeek(xFilial("SF2", cFilSE2)+oModelSFE:GetValue("FE_NFISCAL")+oModelSFE:GetValue("FE_SERIE")+oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")))
					RecLock("SF2",.F.)
					If Empty(SF2->F2_RETIVA)
						SF2->F2_RETIVA := oModelSFE:GetValue("RETTOT")
						SF2->F2_SALIVA := oModelSFE:GetValue("RETTOT")
					EndIf
					SF2->F2_SALIVA -= IIF(oModelSFE:GetValue("FE_RETENC") < 0, oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					SF2->(MsUnLock())
				EndIf
			EndIf

			//Suma de retención por título financiero
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
			nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))
			If Empty(cSE2Cert) .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
				cSE2Cert := oModelSFE:GetValue("FE_NFISCAL")
			EndIf

			If oModelEOP:GetValue("CPGTOELT") <> "1"
				F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
			EndIf
		EndIf
	Next

	For nX := 1 To oModelSE2:Length()
		oModelSE2:GoLine(nX)
		SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
		cFilSE2 := SE2->E2_FILORIG
		If Subs(cAgente,2,1) == "N"
			DbSelectArea("SF1")
			SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SF1->(MsSeek(xFilial("SF1", cFilSE2)+oModelSE2:GetValue("E2_NUM")+oModelSE2:GetValue("E2_PREFIXO")+oModelSE2:GetValue("E2_FORNECE")+oModelSE2:GetValue("E2_LOJA")))
				RecLock("SF1",.F.)
				If Empty(SF1->F1_ORDPAGO)
					SF1->F1_ORDPAGO := oModelSE2:GetValue("E2_ORDPAGO")
				EndIf
				SF1->(MsUnLock())
			EndIf
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(MsSeek(xFilial("SF2", cFilSE2)+oModelSE2:GetValue("E2_NUM")+oModelSE2:GetValue("E2_PREFIXO")+oModelSE2:GetValue("E2_FORNECE")+oModelSE2:GetValue("E2_LOJA")))
				RecLock("SF2",.F.)
				If Empty(SF2->F2_ORDPAGO)
					SF2->F2_ORDPAGO := oModelSE2:GetValue("E2_ORDPAGO")
				EndIf
				SF2->(MsUnLock())
			EndIf
		EndIf
	Next

	//Graba retención de IVA en la Orden de Pago
	If lTitRet .And. nValRet > 0
		F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "IVA", cSE2Cert, nValRet, cFincTal)
	EndIf

	//Graba el número de la Orden de Pago en las notas que generan IVA acumulado
	If Type("aRetIvAcm[2]") == "A"
		For nX := 1 to Len(aRetIvAcm[2])
			If aRetIVAcm[2][nX][3]
				nContIva++
			Else
				Loop
			EndIf

			If Len(aRetIVAcm) > 0
				If Len(aRetIVAcm[3][nContIva]) > 0
					If aRetIVAcm[2][nX][2] == "SF1"
						DbSelectArea("SF1")
						SF1->(DbGoTo(aRetIVAcm[2][nX][1]))
						RecLock("SF1",.F.)
						If Alltrim(SF1->F1_ORDPAGO) == ""
							SF1->F1_ORDPAGO := cOrdPago
						EndIf
						SF1->(MsUnLock())
					Else
						DbSelectArea("SF2")
						SF2->(DbGoTo(aRetIVAcm[2][nX][1]))
						RecLock("SF2",.F.)
						If Alltrim(SF2->F2_ORDPAGO) == ""
							SF2->F2_ORDPAGO := cOrdPago
						EndIf
						SF2->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Next
		nContIva := 0
	EndIf
	
	RestArea(aAreaSF1)
	RestArea(aAreaSF2)
	aRetIVAcm := Array(3) //Se inicializa el arreglo de retenciones de IVA acumulado

Return Nil

/*/{Protheus.doc} GRVRETIB
Función que se encarga del proceso de afectación de tablas por el proceso de retención de Ingresos Brutos
@type 		Method
@param 		
		oModel     -  objeto   - Modelo FINA999
		lTitRet    -  lógico   - Valor del parámetro MV_TITRET
		cFincTal   -  caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		10/02/2026 
/*/
Static Function GRVRETIB(oModel, lTitRet, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nPos			:= 0
Local nX			:= 0
Local nValRet       := 0
Local cSE2Cert		:= ""

Default oModel 		:= Nil
Default lTitRet 	:= .F.
Default cFincTal 	:= ""

	For nX := 1 To oModelSFE:Length()
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "B" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			METRET999("IBR-"+oModelSFE:GetValue("FE_EST"))
			nPos := AScan(aCert,{|x| x[1] == oModelSFE:GetValue("FE_NROCERT") .And. x[2] == "B"})
			If nPos == 0
				AAdd(aCert,{oModelSFE:GetValue("FE_NROCERT"),"B",oModelSFE:GetValue("FE_EST")})
			EndIf

			oModelTTB:SeekLine({{"EK_NUM", oModelSFE:GetValue("FE_NROCERT")}}, .F., .T.)

			//Suma de retención por título financiero
			If !Empty(oModelSFE:GetValue("ESRETADC")) .And. !Empty(oModelSFE:GetValue("CFORA"))
				oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
				nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))
				If Empty(cSE2Cert) .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
					cSE2Cert := oModelSFE:GetValue("FE_NFISCAL")
				EndIf
			EndIf

			If oModelEOP:GetValue("CPGTOELT") <> "1"
				If oModelEOP:GetValue("PA") .And. oModelFJR:GetValue("NMOERET") <> 1 .And. cFincTal == "2"
					F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelTTB:GetValue("EK_VLMOED1"))
				ElseIf oModelEOP:GetValue("PA") .And. oModelFJR:GetValue("NMOERET") <> 1 .And. cFincTal <> "2"
					F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, Round(xMoeda(oModelTTB:GetValue("EK_VLMOED1"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET"))))
				Else
					F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
				EndIf	
			EndIf
		EndIf
	Next

	//Graba retención de IB de la Orden de Pago
	If lTitRet .And. nValRet > 0
		F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "IIB", cSE2Cert, nValRet, cFincTal)
	EndIf

Return Nil

/*/{Protheus.doc} GRVRETSUSS
Función que se encarga del proceso de afectación de tablas por el proceso de retención de IVA
@type 		Method
@param 		
		oModel     - objeto   - Modelo FINA999
		lTitRet    - lógico   - Valor del parámetro MV_TITRET
		lReSaIV    - lógico   - Valor de los parámetros MV_RETIVA y MV_RETSUSS
		cFincTal   - caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/02/2026 
/*/
Static Function GRVRETSUSS(oModel, lTitRet, lReSaIV, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nX 			:= 1
Local aAreaSF1 		:= SF1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local lReSaSus		:= SuperGetMv("MV_RETSUSS",.F.,"N") == "S" 
Local nVlmpSuss		:= 0
Local nValRet       := 0
Local cSE2Cert		:= ""
Local lSeekSE2		:= .F.
Local cFilSE2		:= cFilAnt

Default oModel 		:= Nil
Default lTitRet 	:= .F.
Default lReSaIV 	:= .F.
Default cFincTal 	:= ""

	For nX := 1 To oModelSFE:Length()
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "S" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			lSeekSE2 := oModelSE2:SeekLine({{"E2_NUM", oModelSFE:GetValue("FE_NFISCAL")}}, .F., .T.) 
			If lSeekSE2
				SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
				cFilSE2 := SE2->E2_FILORIG
			EndIf

			METRET999("SUSS")
			nPos := AScan(aCert, {|x| x[1] == oModelSFE:GetValue("FE_NROCERT") .And. x[2] == "S"})
			If nPos == 0
				AAdd(aCert, {oModelSFE:GetValue("FE_NROCERT"), "S", Alltrim(oModelSFE:GetValue("FE_CONCEPT"))+oModelSFE:GetValue("TPOBRA")})
			EndIf

			nVlmpSuss := IIF(lReSaSus, oModelSFE:GetValue("FE_VALIMP"),0)
			
			If lReSaIV						
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(MsSeek(xFilial("SF1", cFilSE2)+oModelSFE:GetValue("FE_NFISCAL")+oModelSFE:GetValue("FE_SERIE")+oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")))
					RecLock("SF1",.F.)
					If Empty(SF1->F1_RETSUSS)
						SF1->F1_RETSUSS := nVlmpSuss
					Else
						SF1->F1_RETSUSS += nVlmpSuss
					EndIf 
					If Empty(SF1->F1_SALSUSS)
						SF1->F1_SALSUSS := SF1->F1_RETSUSS - IIF(oModelSFE:GetValue("FE_RETENC") < 0,oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					Else
						SF1->F1_SALSUSS -= IIF(oModelSFE:GetValue("FE_RETENC") < 0,oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					EndIf 
					SF1->(MsUnLock())
				EndIf

				DbSelectArea("SF2")
				SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO
				If SF2->(MsSeek(xFilial("SF2", cFilSE2)+oModelSFE:GetValue("FE_NFISCAL")+oModelSFE:GetValue("FE_SERIE")+oModelSFE:GetValue("FE_FORNECE")+oModelSFE:GetValue("FE_LOJA")))
					RecLock("SF2",.F.)
					If Empty(SF2->F2_RETSUSS)
						SF2->F2_RETSUSS := nVlmpSuss
					Else
						SF2->F2_RETSUSS += nVlmpSuss
					EndIf 
					If Empty(SF2->F2_SALSUSS)
						SF2->F2_SALSUSS := SF2->F2_RETSUSS - IIF(oModelSFE:GetValue("FE_RETENC") < 0,oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					Else
						SF2->F2_SALSUSS -= IIF(oModelSFE:GetValue("FE_RETENC") < 0,oModelSFE:GetValue("FE_RETENC") * -1, oModelSFE:GetValue("FE_RETENC"))
					EndIf 
					SF2->(MsUnLock())
				EndIf
			EndIf

			//Suma de retención por título financiero
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
			nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))
			If Empty(cSE2Cert) .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
				cSE2Cert := oModelSFE:GetValue("FE_NFISCAL")
			EndIf

			If oModelEOP:GetValue("CPGTOELT") <> "1"
				F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
			EndIf
		EndIf
	Next

	//Graba retención de SUSS en la Orden de Pago
	If lTitRet .And. nValRet > 0
		F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "SUS", cSE2Cert, nValRet, cFincTal)
	EndIf

	RestArea(aAreaSF1)
	RestArea(aAreaSF2)

Return Nil

/*/{Protheus.doc} GRVRETSLI
Función que se encarga del proceso de afectación de tablas por el proceso de retención de SLI
@type 		Method
@param 		
		oModel     - objeto   - Modelo FINA999
		lTitRet    - lógico   - Valor del parámetro MV_TITRET
		cFincTal   - caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/02/2026 
/*/
Static Function GRVRETSLI(oModel, lTitRet, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nX 			:= 1
Local nValRet       := 0
Local cSE2Cert		:= ""

Default oModel 		:= Nil
Default lTitRet 	:= .F.
Default cFincTal 	:= ""

	For nX := 1 To oModelSFE:Length()
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "L" .And. oModelSFE:GetValue("FE_RETENC") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
			METRET999("SLI")

			//Suma de retención por título financiero
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
			nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))
			If Empty(cSE2Cert) .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
				cSE2Cert := oModelSFE:GetValue("FE_NFISCAL")
			EndIf

			If oModelEOP:GetValue("CPGTOELT") <> "1"
				F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
			EndIf
		EndIf
	Next

	//Graba retención de SLI en la Orden de Pago
	If lTitRet .And. nValRet > 0
		F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "SLI", cSE2Cert, nValRet, cFincTal)
	EndIf

Return Nil

/*/{Protheus.doc} GRVRETISI
Función que se encarga del proceso de afectación de tablas por el proceso de retención de ISI
@type 		Method
@param 		
		oModel     - objeto   - Modelo FINA999
		lTitRet    - lógico   - Valor del parámetro MV_TITRET
		cFincTal   - caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/02/2026 
/*/
Static Function GRVRETISI(oModel, lTitRet, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nX 			:= 1
Local nPos			:= 0
Local nValRet       := 0
Local cSE2Cert		:= ""

Default oModel 		:= Nil
Default lTitRet 	:= .F.
Default cFincTal 	:= ""

	If !oModelEOP:GetValue("PA")
		For nX := 1 To oModelSFE:Length()
			oModelSFE:GoLine(nX)
			If oModelSFE:GetValue("FE_TIPO") == "M" .And. oModelSFE:GetValue("FE_VALBASE") != 0 .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
				METRET999("ISI"+oModelSFE:GetValue("FE_EST"))
				nPos := AScan(aCert, {|x| x[1] == oModelSFE:GetValue("FE_NROCERT") .And. x[2] == "M"})
				If nPos == 0
					AAdd(aCert, {oModelSFE:GetValue("FE_NROCERT"), "M", "",;
					{{oModelSFE:GetValue("FE_ALIQ"),oModelSFE:GetValue("IMPUESTO"),oModelSFE:GetValue("FE_RETENC"),oModelSFE:GetValue("CFORA")}}})
				EndIf    

				//Suma de retención por título financiero
				oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
				nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))
				If Empty(cSE2Cert) .And. !Empty(oModelSFE:GetValue("FE_NFISCAL"))
					cSE2Cert := oModelSFE:GetValue("FE_NFISCAL")
				EndIf

				If oModelEOP:GetValue("CPGTOELT") <> "1"
					F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
				EndIf
			EndIf
		Next

		//Graba retención de ISI en la Orden de Pago
		If lTitRet .And. nValRet > 0
			F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "M", cSE2Cert, nValRet, cFincTal)
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} GRVRETGAN
Función que se encarga del proceso de afectación de tablas por el proceso de retención de Ganancias
@type 		Method
@param 		
		oModel     - objeto   - Modelo FINA999
		lTitRet    - lógico   - Valor del parámetro MV_TITRET
		cFincTal   - caracter - Valor del parámetro MV_FINCTAL
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		24/03/2026 
/*/
Static Function GRVRETGAN(oModel, lTitRet, cFincTal)
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelSFE 	:= oModel:GetModel('SFE_DETAIL')
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local nX 			:= 1
Local nValRet       := 0

Default oModel 		:= Nil
Default lTitRet 	:= .F.
Default cFincTal 	:= ""

	For nX := 1 To oModelSFE:Length()
		oModelSFE:GoLine(nX)
		If oModelSFE:GetValue("FE_TIPO") == "G" .And. oModelSFE:GetValue("FE_VALBASE") != 0
			METRET999("GAN")

			If Alltrim(oModelSFE:GetValue("FE_NROCERT")) <> "NORET"
				AAdd(aCert, {oModelSFE:GetValue("FE_NROCERT"), "G"})
			EndIf

			//Suma de retención por título financiero
			oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSFE:GetValue("FE_ORDPAGO")}}, .F., .T.)
			nValRet += Round(xMoeda(oModelSFE:GetValue("FE_RETENC"),1,oModelFJR:GetValue("NMOERET"),,3,,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(oModelFJR:GetValue("NMOERET")))

			If oModelEOP:GetValue("CPGTOELT") <> "1"
				F999ActSal(oModelSOP, oModelSFE:GetValue("FE_ORDPAGO"), 1, oModelSFE:GetValue("FE_RETENC"))
			EndIf
		EndIf
	Next

	//Graba retención de Ganancias en la Orden de Pago
	If lTitRet .And. nValRet > 0
		F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, "GAN",, nValRet, cFincTal)
	EndIf

Return Nil

/*/{Protheus.doc} F999GetCert
Función que se encarga de obtener el certificado de una retención
@type 		Method
@param 		
		cImposto - caracter - Impuesto
		cChave   - caracter - Clave para localización del impuesto
		lReUsa   - lógico   - Indica si reutiliza el certificado
@return
		cNroCert - caracter - Número de certificado para la retención
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		16/01/2026 
/*/
Function F999GetCert(cImposto, cChave, lReUsa)
Local cNroCert	 :=	""
Local nNroCert	 :=	0
Local nPosCert	 :=	0
Local nTamCpoCer := GetSx3Cache("FE_NROCERT","X3_TAMANHO")
Local aGetSx5	 := {}
Local cMvCert    := SuperGetMv("MV_CERT" + Alltrim(Substr(cImposto, 1, 3)),.F.,"")

Default cImposto :=	""
Default cChave	 :=	""
Default lReUsa	 :=	.T.

	If lReUsa
		nPosCert :=	AScan(aCerts,{|x| X[1] == cChave })
	EndIf

	If nPosCert > 0
		Return aCerts[nPosCert][2]
	EndIf

	If !Empty(cMvCert)
	 	nNroCert := Val(cMvCert)
		cNroCert := StrZero(nNroCert,nTamCpoCer)
		PUTMV("MV_CERT" + Alltrim(Substr(cImposto, 1, 3)), Soma1(cNroCert))
	Else 	
		aGetSx5 := FwGetSX5("99", cImposto)
		IF Len(aGetSx5) == 0
			cNroCert := StrZero(1,nTamCpoCer)
		Else
			cNroCert := StrZero(Val(aGetSx5[1][4])+1,nTamCpoCer)
		EndIf
		FwPutSX5("", "99", cImposto, cNroCert, cNroCert, cNroCert, cNroCert)
	EndIf

AAdd(aCerts,{cChave,cNroCert})

Return cNroCert

/*/{Protheus.doc} LibMetF999
Función que valida fecha de la LIB para ser utilizada en Telemetria
@type 		Method
@param 		
@return
		_lMetric - lógico - Si la LIB puede ser utilizada para Telemetria
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		19/01/2026 
/*/
Static Function LibMetF999()

If _lMetric == Nil 
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric

/*/{Protheus.doc} LibMetF999
Función que envía métrica de retención de orden de pago
@type 		Method
@param 		
		cTipoRet - caracter - Tipo de retencion generada
@return
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		19/01/2026 
/*/
Static Function METRET999(cTipoRet)
Local cIdMetric     := ""
Local cSubRutina    := ""

Default cTipoRet := ""

	If LibMetF999() 
		cIdMetric   := "financeiro-protheus_quantida-de-retencoes-ordpago_total"
		cSubRutina  := "fina850-retenciones-"+cTipoRet
		If IsBlind()
			cSubRutina  += "-auto"
		EndIf
		FwCustomMetrics():setSumMetric(cSubRutina, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/, "FINA850")
	EndIf
	
Return Nil

/*/{Protheus.doc} F999RatSus
Función que retorna el prorrateo configurado en el proveedor
@type 		Method
@param 		
		cFornece - caracter - Código de Proveedor
		cLoja    - caracter - Tienda del Proveedor
@return
		aRateio  - arreglo  - Prorrateos configurados en el Proveedor
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		19/01/2026 
/*/
Function F999RatSus(cFornece, cLoja)
Local aAreaSA2 := SA2->(GetArea())
Local aRateio  := {}
Local lLey1784 := .F.
Local cCodCond := ""

Default cFornece := ""
Default cLoja	 := ""

DbSelectArea("SA2")
SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja)) 

If SA2->(ColumnPos("A2_PROVEMP")) > 0  .And. SA2->A2_PROVEMP == 1
	lLey1784 := .T.
EndIf

If SA2->A2_CONDO == "1"
	cCodCond := SA2->A2_CODCOND
	SA2->(MsSeek(xFilial("SA2")+cCodCond))
	//Se registra prorrateo para cada condomino
	While !SA2->(EOF()) .And. xFilial("SA2") == SA2->A2_FILIAL .And. cCodCond == SA2->A2_CODCOND
		If SA2->A2_CONDO == "2"
		   AAdd(aRateio, {SA2->A2_COD, SA2->A2_LOJA, SA2->A2_PERCCON/100, lLey1784})
		EndIf
		SA2->(DbSkip())
	Enddo
EndIf

If Len(aRateio) == 0 //Caso no sea encontrado condomino
	AAdd(aRateio, {cFornece, cLoja, 1, lLey1784})
EndIf

RestArea(aAreaSA2)

Return aRateio

/*/{Protheus.doc} F999ImpSE2
	Función que actualiza la variable aImpSE2 con las retenciones que serán grabadas en la tabla SE2
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		19/05/2026
	@param 		
		oModelSE2 - objeto   - Modelo de datos de la tabla de Cuentas Por Pagar
		oModelFJR - objeto   - Modelo de datos de la tabla de Detalle de Orden de Pago
		oModelEOP - objeto   - Modelo de datos de la tabla de Encabezado de Orden de Pago
		cImp      - caracter - Impuesto
		cSE2Cert  - caracter - Número de certificado
		nValRet   - numérico - Valor de retención
		cFincTal  - caracter - Valor del parámetro MV_FINCTAL
	@return
/*/
Function F999ImpSE2(oModelSE2, oModelFJR, oModelEOP, cImp, cSE2Cert, nValRet, cFincTal)
Local nPosImp 		:= 0
Local cCodApro 		:= ""

Default oModelSE2 	:= Nil
Default oModelFJR 	:= Nil
Default oModelEOP 	:= Nil
Default cImp 		:= ""
Default cSE2Cert 	:= ""
Default nValRet 	:= 0
Default cFincTal 	:= ""

	nPosImp := AScan(aImpSE2, {|x| x[10] == cImp })
	If nPosImp > 0
		aImpSE2[nPosImp][7] += nValRet
	Else
		If !Empty(cSE2Cert)
			oModelSE2:SeekLine({{"E2_NUM", cSE2Cert}}, .F., .T.) 
		Else
			oModelSE2:GoLine(1)
		EndIf

		If cImp $ "GAN|IVA" .And. oModelFJR:GetValue("NMOERET") <> 1 .And. cFincTal == "2" .And. oModelEOP:GetValue("PA") 
			cCodApro := FA050Aprov(1)
		EndIf

		If Empty(cCodApro) .And. oModelSE2:HasField("E2_CODAPRO")
			cCodApro := oModelSE2:GetValue("E2_CODAPRO")
		EndIf

		AAdd(aImpSE2, {oModelSE2:GetValue("E2_PREFIXO"), oModelSE2:GetValue("E2_NUM"), oModelSE2:GetValue("E2_PARCELA"), oModelSE2:GetValue("E2_TIPO"), oModelSE2:GetValue("E2_FORNECE"), oModelSE2:GetValue("E2_LOJA"), nValRet, oModelSE2:GetValue("E2_ORDPAGO"), dDataBase, cImp, 1,,, cCodApro})
	EndIf
	
Return Nil

