#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999FIN
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999FIN From FwModelEvent 
    
    DATA lCposAdic As Logical

    DATA lPrCCR    As Logical

    DATA lUsaFlag  As Logical

    DATA lReIvSU   As Logical

    DATA lBaretIS  As Logical

	DATA lA085ATIT As Logical
	
	DATA lFlagCTB  As Logical

	DATA cLog 	   As Character

	DATA oModBxE2  As Object

	DATA oFKABxE2  As Object

	DATA oFK2BxE2  As Object

	DATA oFK6BxE2  As Object

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method BeforeTTS()

	Method InTTS()

	Method AfterTTS()

	Method F999UPDMDL()

	Method F999GRVMDL()

	Method F999GRVTB()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999FIN
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@param 		oModel - objeto	  - Modelo de datos.
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999FIN
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()

	self:lPrCCR 	:= .F.

	self:lCposAdic 	:= .F.

	self:lReIvSU    := .F.

	self:lBaretIS   := .F.

	If nOperation == MODEL_OPERATION_INSERT

		self:lA085ATIT  := ExistBlock("A085ATIT")

		self:lFlagCTB   := Type("aFlgCTB") == "A"

		self:lUsaFlag	:= SuperGetMV("MV_CTBFLAG", .T., .F.)

		Pergunte("FIN850P", .F., /*cTitle*/, .F., /*oDlg*/, .T.)

	EndIf

Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.
@type 		Method
@param 		oModel - objeto	  - Modelo de datos.
@author 	carlos.espinoza	
@version	12.2.2310 / Superior
@since		09/01/2026 
/*/
Method BeforeTTS(oModel) Class F999FIN
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:F999UPDMDL(oModel)
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
@since		13/11/2025 
/*/
Method InTTS(oModel, cModelId) Class F999FIN
Local nOperation	:= oModel:GetOperation()
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		Begin Transaction
			self:cLog := ""
			If !self:F999GRVMDL(oModel)
				DisarmTransaction()
				oModelEOP:SetValue("HASERROR", .T.)
			EndIf
		End Transaction
	ENDIF

Return Nil

/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio de retenciones 
después de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	 - Modelo de datos.
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		03/06/2026 
/*/
Method AfterTTS(oModel) Class F999FIN
Local nOperation := oModel:GetOperation()
Local lVldRet    := Type("lF999Ret") == "L"
Local oModelEOP  := oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT
		If !Empty(self:cLog)
			Help(,,"ORDPAG",,self:cLog, 1, 0)
			If lVldRet
				lF999Ret := .F.
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} F999UPDMDL
Metodo responsable por realizar las actualizaciones en el modelo FINA999 antes de la transacción
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		13/11/2025 
/*/
Method F999UPDMDL(oModel) Class F999FIN
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local nX 			:= 0
Local nLine 		:= 0
Local cSeq 			:= ""
Local cJCotiz		:= oModelEOP:GetValue("COTIZ")
Local oJCotiz 		:= JsonObject():New()
Local nTxMoeda		:= 1
Local aTxEmis		:= {}

	oJCotiz:FromJson(cJCotiz)

	For nX := 1 To oModelFJR:Length()
		nLine := 0
		oModelFJR:GoLine(nX)

		If oModelFJR:GetValue("MARK") <> 1
			Loop
		EndIf

		//Grabado de Títulos de Baja en la tabla SEK
		If !Empty(oModelFJR:GetValue("FJR_ORDPAG")) .And. oModelSE2:SeekLine({{"E2_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG")}}, .F., .T.) 
			nLine := oModelSE2:GetLine()
			While nLine <= oModelSE2:Length() .And. oModelFJR:GetValue("FJR_ORDPAG") == oModelSE2:GetValue("E2_ORDPAGO");
				.And. !(oModelSE2:GetValue("E2_TIPO") $ MVABATIM) .And. oModelSE2:GetValue("E2_PAGAR") > 0
				cSeq := FaNxtSeqBx("SE2")

				If !Empty(oModelTTB:GetValue("EK_ORDPAGO"))
					oModelTTB:AddLine()
				EndIf

				oModelTTB:LoadValue("EK_TIPODOC", "TB")
				oModelTTB:LoadValue("EK_FILIAL" , xFilial("SEK"))
				oModelTTB:LoadValue("EK_VALORIG", oModelSE2:GetValue("E2_VALOR"))
				oModelTTB:LoadValue("EK_EMISSAO", dDataBase)
				oModelTTB:LoadValue("EK_PREFIXO", oModelSE2:GetValue("E2_PREFIXO"))
				oModelTTB:LoadValue("EK_NUM"	, oModelSE2:GetValue("E2_NUM"))
				oModelTTB:LoadValue("EK_PARCELA", oModelSE2:GetValue("E2_PARCELA"))
				oModelTTB:LoadValue("EK_TIPO"	, oModelSE2:GetValue("E2_TIPO"))
				oModelTTB:LoadValue("EK_FORNECE", oModelSE2:GetValue("E2_FORNECE"))
				oModelTTB:LoadValue("EK_LOJA"	, oModelSE2:GetValue("E2_LOJA"))
				oModelTTB:LoadValue("EK_MOEDA"	, Alltrim(Str(oModelSE2:GetValue("E2_MOEDA"))))
				oModelTTB:LoadValue("EK_SALDO"	, oModelSE2:GetValue("E2_PAGAR"))
				oModelTTB:LoadValue("EK_VALOR"	, Abs(oModelSE2:GetValue("E2_PAGAR")))
				oModelTTB:LoadValue("EK_VENCTO"	, oModelSE2:GetValue("E2_VENCTO"))
				oModelTTB:LoadValue("EK_JUROS"	, oModelSE2:GetValue("E2_JUROS"))
				oModelTTB:LoadValue("EK_DESCONT", oModelSE2:GetValue("E2_DESCONT"))
				oModelTTB:LoadValue("EK_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG"))
				oModelTTB:LoadValue("EK_SEQ"	, cSeq)
				oModelTTB:LoadValue("EK_DTDIGIT", dDataBase)
				oModelTTB:LoadValue("EK_FORNEPG", oModelFJR:GetValue("FJR_FORNEC"))
				oModelTTB:LoadValue("EK_LOJAPG"	, oModelFJR:GetValue("FJR_LOJA"))
				oModelTTB:LoadValue("EK_NATUREZ", oModelFJR:GetValue("FJR_NATURE"))

				If self:lCposAdic
					oModelTTB:LoadValue("EK_PGCBU", oModelFJR:GetValue("CBU"))
					oModelTTB:LoadValue("EK_MULTA", oModelSE2:GetValue("E2_MULTA"))
					If oModelEOP:GetValue("CPGTOELT") <> "1"
						oModelTTB:LoadValue("EK_EFTVAL", "1") //Movimento Efetivado
					Else
						oModelTTB:LoadValue("EK_EFTVAL", "2") //Movimento Pendente
					EndIf
					If oModelTTB:HasField("EK_CCR")
						oModelTTB:LoadValue("EK_CCR", IIF(oModelEOP:GetValue("PROCCCR"),MV_PAR15,""))
					Endif
				EndIF

				oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
				nTxMoeda := oModelMOE:GetValue("TASA")
				If oJCotiz['lCpoCotiz']
					nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
					aTxEmis  := F999fTxMoe(oModelSE2:GetValue("E2_EMISSAO"), oModelMOE, @oJCotiz)
				EndIf
				F999GrvTx(oModelSE2:GetValue("E2_MOEDA"), nTxMoeda, aTxEmis, oJCotiz, oModelMOE, oModelTTB)
				oModelTTB:LoadValue("EK_VLMOED1", Round(xMoeda(Abs(oModelSE2:GetValue("E2_PAGAR")),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
				
				nLine++
				If nLine <= oModelSE2:Length()
					oModelSE2:GoLine(nLine)
				EndIf
			EndDo
		EndIf
	Next

	oModelSE2:GoLine(1)
	oModelTTB:GoLine(1)

Return Nil

/*/{Protheus.doc} F999GRVMDL
Metodo responsable por realizar las actualizaciones de las tablas por el modelo FINA999
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		13/11/2025 
/*/
Method F999GRVMDL(oModel) Class F999FIN
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local oModelTTB 	:= oModel:GetModel('TTB_DETAIL')
Local lRet			:= .T.
Local nX 			:= 0
Local nLine 		:= 0
Local cJCotiz		:= oModelEOP:GetValue("COTIZ")
Local oJCotiz 		:= JsonObject():New()
Local cCtaCte 		:= ""
Local nTamCodCC		:= GetSx3Cache("FVS_CODCC","X3_TAMANHO")
Local aArea 		:= {}

	self:oModBxE2 := FWLoadModel("FINM020")
	self:oFKABxE2 := self:oModBxE2:GetModel("FKADETAIL")
	self:oFK2BxE2 := self:oModBxE2:GetModel("FK2DETAIL")
	self:oFK6BxE2 := self:oModBxE2:GetModel("FK6DETAIL")

	oJCotiz:FromJson(cJCotiz)

	For nX := 1 To oModelFJR:Length()
		nLine := 0
		oModelFJR:GoLine(nX)

		If oModelFJR:GetValue("MARK") <> 1
			Loop
		EndIf

		//Grabado de Títulos de Baja en la tabla SEK
		If !Empty(oModelFJR:GetValue("FJR_ORDPAG")) .And. oModelSE2:SeekLine({{"E2_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG")}}, .F., .T.) 
			nLine := oModelSE2:GetLine()
			While nLine <= oModelSE2:Length() .And. oModelFJR:GetValue("FJR_ORDPAG") == oModelSE2:GetValue("E2_ORDPAGO");
				.And. !(oModelSE2:GetValue("E2_TIPO") $ MVABATIM) .And. oModelSE2:GetValue("E2_PAGAR") > 0

				If !self:F999GRVTB(oModelSE2, oModelFJR, oModelEOP, oModelMOE, oModelSOP, oModelTTB:GetValue("EK_SEQ", nLine), oModelFJR:GetValue("CLIQUID"), oJCotiz)
					lRet := .F.
					Return lRet
				EndIf

				If self:lPrCCR .And. oModelEOP:GetValue("PROCCCR")
					aArea := FVS->(GetArea())
					cCtaCte := Padr(MV_PAR15, nTamCodCC)
					DbSelectArea("FVS")
					FVS->(DbSetOrder(1)) //FVS_FILIAL+FVS_CODCC+FVS_TIPO+FVS_CODIGO+FVS_LOJA
					If FVS->(MsSeek(xFilial('FVS')+cCtaCte))
						RecLock("FVS", .F.)
							FVS->FVS_OP := oModelFJR:GetValue("FJR_ORDPAG")
						FVS->(MsUnlock())
					EndIf
					RestArea(aArea)
				EndIf

				nLine++
				If nLine <= oModelSE2:Length()
					oModelSE2:GoLine(nLine)
				EndIf
			EndDo
		EndIf
	Next

Return lRet

/*/{Protheus.doc} F999GRVTB
	Función que realiza el grabado en las tablas FKS
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		27/11/2025
	@param 		
		oModelSE2 - objeto   - Modelo títulos financieros
		oModelFJR - objeto   - Modelo detalle de ordenes de pago
		oModelEOP - objeto   - Modelo encabezado de ordenes de pago
		oModelMOE - objeto   - Modelo de monedas
		oModelSOP - objeto   - Modelo de saldos por orden de pago
		cSeq 	  - caracter - Sencuencia SE2
		cLiquid   - caracter - MV_NUMLIQ
		oJCotiz   - objeto   - Cotización original
	@return
		lRet - lógico - indica si el grabado fue satisfactorio
/*/
Method F999GRVTB(oModelSE2, oModelFJR, oModelEOP, oModelMOE, oModelSOP, cSeq, cLiquid, oJCotiz) Class F999FIN
Local cChaveTit     := ""
Local cIdDoc		:= ""
Local cQuery		:= ""
Local cCposSE5		:= ""
Local cOrdPgo       := oModelFJR:GetValue("FJR_ORDPAG")
Local lRet 			:= .T.
Local nTxMoeda		:= 0
Local cIDFK2 		:= ""
Local oExec         := Nil
Local nRecFK2		:= 0
Local aAreaSE2		:= {}
Local aError		:= {}

Default oModelSE2	:= Nil
Default oModelFJR	:= Nil
Default oModelEOP	:= Nil
Default oModelMOE	:= Nil
Default oModelSOP	:= Nil
Default cSeq		:= ""
Default cLiquid		:= ""
Default oJCotiz		:= JsonObject():New()

	self:oModBxE2:SetOperation(MODEL_OPERATION_INSERT)
	self:oModBxE2:Activate()
	self:oModBxE2:SetValue("MASTER","E5_GRV",.T.)
	self:oModBxE2:SetValue("MASTER","IDPROC",oModelFJR:GetValue("CIDPROC"))
	cIDFK2 	:= FWUUIDV4()

	If oModelEOP:GetValue("CPGTOELT") <> "1"
		aAreaSE2 := SE2->(GetArea())
		SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
		
		oModelMOE:GoLine(oModelSE2:GetValue("E2_MOEDA"))
		nTxMoeda := oModelMOE:GetValue("TASA")
		If oJCotiz['lCpoCotiz']
			nTxMoeda := F999TxMon(oModelSE2:GetValue("E2_MOEDA"), oModelSE2:GetValue("E2_TXMOEDA"), nTxMoeda, oJCotiz)
		EndIf

		cCposSE5 += "{"
		cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
		cCposSE5 += "{'E5_PREFIXO','" + oModelSE2:GetValue("E2_PREFIXO") + "'},"
		cCposSE5 += "{'E5_NUMERO','" + oModelSE2:GetValue("E2_NUM") + "'},"
		cCposSE5 += "{'E5_PARCELA','" + oModelSE2:GetValue("E2_PARCELA") + "'},"
		cCposSE5 += "{'E5_CLIFOR','" + oModelSE2:GetValue("E2_FORNECE") + "'},"
		cCposSE5 += "{'E5_LOJA','"  + oModelSE2:GetValue("E2_LOJA") + "'},"
		cCposSE5 += "{'E5_BENEF','" + oModelSE2:GetValue("E2_NOMFOR") + "'},"
		cCposSE5 += "{'E5_DOCUMEN','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_TIPO','" + oModelSE2:GetValue("E2_TIPO") + "'},"
		cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
		cCposSE5 += "{'E5_VLDESCO'," + AllTrim(Str(oModelSE2:GetValue("E2_DESCONT"))) + "},"
		cCposSE5 += "{'E5_VLMULTA'," + AllTrim(Str(oModelSE2:GetValue("E2_MULTA"))) + "},"
		cCposSE5 += "{'E5_VLJUROS'," + Alltrim(Str(oModelSE2:GetValue("E2_JUROS"))) + "}"
		cCposSE5 += "}"

		cChaveTit := xFilial("SE2") + "|"
		cChaveTit += oModelSE2:GetValue("E2_PREFIXO") + "|"
		cChaveTit += oModelSE2:GetValue("E2_NUM") + "|"
		cChaveTit += oModelSE2:GetValue("E2_PARCELA") + "|"
		cChaveTit += oModelSE2:GetValue("E2_TIPO") + "|"
		cChaveTit += oModelSE2:GetValue("E2_FORNECE") + "|"
		cChaveTit += oModelSE2:GetValue("E2_LOJA")

		cIdDoc := FINGRVFK7("SE2", cChaveTit)

		self:oFKABxE2:SetValue("FKA_IDORIG",cIDFK2)
		self:oFKABxE2:SetValue("FKA_TABORI","FK2")

		self:oFK2BxE2:SetValue("FK2_DATA", dDataBase)
		self:oFK2BxE2:SetValue("FK2_NATURE",oModelSE2:GetValue("E2_NATUREZ"))
		self:oFK2BxE2:SetValue("FK2_VENCTO",SE2->E2_VENCREA)
		self:oFK2BxE2:SetValue("FK2_RECPAG","P")
		self:oFK2BxE2:SetValue("FK2_TPDOC","BA")
		self:oFK2BxE2:SetValue("FK2_MOEDA",StrZero(oModelSE2:GetValue("E2_MOEDA"),2))
		self:oFK2BxE2:SetValue("FK2_VALOR",Abs(oModelSE2:GetValue("E2_PAGAR")))
		If oModelSE2:GetValue("E2_MOEDA") == 1
			self:oFK2BxE2:SetValue("FK2_VLMOE2",oModelSE2:GetValue("E2_PAGAR"))
		Else
			self:oFK2BxE2:SetValue("FK2_VLMOE2",Abs(Round(xMoeda(oModelSE2:GetValue("E2_PAGAR"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1))))
		Endif
		self:oFK2BxE2:SetValue("FK2_HISTOR",STR0074) //"BJ.TÍT.P/ORD.PAGO"
		self:oFK2BxE2:SetValue("FK2_MOTBX","NOR")
		self:oFK2BxE2:SetValue("FK2_FILORI",SE2->E2_FILORIG)
		self:oFK2BxE2:SetValue("FK2_TXMOED",nTxMoeda)
		self:oFK2BxE2:SetValue("FK2_CCUSTO",SE2->E2_CCUSTO)
		self:oFK2BxE2:SetValue("FK2_ORIGEM","FINA850")
		self:oFK2BxE2:SetValue("FK2_SEQ",cSeq)
		self:oFK2BxE2:SetValue("FK2_IDDOC",cIdDoc)
		self:oFK2BxE2:SetValue("FK2_ORDREC",cOrdPgo)
		self:oFK2BxE2:SetValue("FK2_DOC",cOrdPgo)
		If !self:lUsaFlag
			self:oFK2BxE2:SetValue("FK2_LA", "S")
		EndIf
		RestArea(aAreaSE2)
	EndIf

	If oModelSE2:GetValue("E2_JUROS") > 0 .And. oModelEOP:GetValue("CPGTOELT") <> "1"  // existem juros
		If !Empty(cCposSE5)
			cCposSE5 += "|"
		Endif
		cCposSE5 += "{"
		cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
		cCposSE5 += "{'E5_DATA',dDataBase},"
		cCposSE5 += "{'E5_NATUREZ','" + oModelSE2:GetValue("E2_NATUREZ") + "'},"
		cCposSE5 += "{'E5_PREFIXO','" + oModelSE2:GetValue("E2_PREFIXO") + "'},"
		cCposSE5 += "{'E5_NUMERO','" + oModelSE2:GetValue("E2_NUM") + "'},"
		cCposSE5 += "{'E5_TIPO','" + oModelSE2:GetValue("E2_TIPO") + "'},"
		cCposSE5 += "{'E5_PARCELA','" + oModelSE2:GetValue("E2_PARCELA") + "'},"
		cCposSE5 += "{'E5_CLIFOR','" + oModelSE2:GetValue("E2_FORNECE") + "'},"
		cCposSE5 += "{'E5_LOJA','"  + oModelSE2:GetValue("E2_LOJA") + "'},"
		cCposSE5 += "{'E5_BENEF','" + oModelSE2:GetValue("E2_NOMFOR") + "'},"
		cCposSE5 += "{'E5_DOCUMEN','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_ORDREC','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
		cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(oModelSE2:GetValue("E2_JUROS"))) + "},"
		cCposSE5 += "{'E5_MOEDA','" + StrZero(oModelSE2:GetValue("E2_MOEDA"),2) + "'},"
		cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(nTxMoeda)) + "},"
		cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
		If !self:lUsaFlag
			cCposSE5 += "{'E5_LA','S'},"
		EndIF
		cCposSE5 += "{'E5_MOTBX','NOR'}"
		cCposSE5 += "}"





		self:oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
		self:oFK6BxE2:SetValue("FK6_TABORI","FK2")
		self:oFK6BxE2:SetValue("FK6_RECPAG","P")
		self:oFK6BxE2:SetValue("FK6_HISTOR",STR0075) //STR0075 - "Interes pago sobre titulo"
		self:oFK6BxE2:SetValue("FK6_TPDOC","JR")
		self:oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(oModelSE2:GetValue("E2_JUROS"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
		self:oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(oModelSE2:GetValue("E2_JUROS"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
	EndIf

	If oModelSE2:GetValue("E2_MULTA") > 0 .And. oModelEOP:GetValue("CPGTOELT") <> "1" //Existe Multa
		If !Empty(cCposSE5)
			cCposSE5 += "|"
		Endif
		cCposSE5 += "{"
		cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
		cCposSE5 += "{'E5_DATA',dDataBase},"
		cCposSE5 += "{'E5_NATUREZ','" + oModelSE2:GetValue("E2_NATUREZ") + "'},"
		cCposSE5 += "{'E5_PREFIXO','" + oModelSE2:GetValue("E2_PREFIXO") + "'},"
		cCposSE5 += "{'E5_NUMERO','" + oModelSE2:GetValue("E2_NUM") + "'},"
		cCposSE5 += "{'E5_TIPO','" + oModelSE2:GetValue("E2_TIPO") + "'},"
		cCposSE5 += "{'E5_PARCELA','" + oModelSE2:GetValue("E2_PARCELA") + "'},"
		cCposSE5 += "{'E5_CLIFOR','" + oModelSE2:GetValue("E2_FORNECE") + "'},"
		cCposSE5 += "{'E5_LOJA','"  + oModelSE2:GetValue("E2_LOJA") + "'},"
		cCposSE5 += "{'E5_BENEF','" + oModelSE2:GetValue("E2_NOMFOR") + "'},"
		cCposSE5 += "{'E5_DOCUMEN','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_ORDREC','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
		cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(oModelSE2:GetValue("E2_MULTA"))) + "},"
		cCposSE5 += "{'E5_MOEDA','" + StrZero(oModelSE2:GetValue("E2_MOEDA"),2) + "'},"
		cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(nTxMoeda)) + "},"
		cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
		If !self:lUsaFlag
			cCposSE5 += "{'E5_LA','S'},"
		EndIF
		cCposSE5 += "{'E5_MOTBX','NOR'}"
		cCposSE5 += "}"

		If !self:oFK6BxE2:IsEmpty()
			self:oFK6BxE2:AddLine()
		Endif

		self:oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
		self:oFK6BxE2:SetValue("FK6_TABORI","FK2")
		self:oFK6BxE2:SetValue("FK6_RECPAG","P")
		self:oFK6BxE2:SetValue("FK6_HISTOR",STR0076) //"Multa sobre Pago de Titulo"
		self:oFK6BxE2:SetValue("FK6_TPDOC","MT")
		self:oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(oModelSE2:GetValue("E2_MULTA"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
		self:oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(oModelSE2:GetValue("E2_MULTA"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
	Endif

	If oModelSE2:GetValue("E2_DESCONT") > 0  .And. oModelEOP:GetValue("CPGTOELT") <> "1" // existem descontos
		If !Empty(cCposSE5)
			cCposSE5 += "|"
		Endif
		cCposSE5 += "{"
		cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
		cCposSE5 += "{'E5_DATA',dDataBase},"
		cCposSE5 += "{'E5_NATUREZ','" + oModelSE2:GetValue("E2_NATUREZ") + "'},"
		cCposSE5 += "{'E5_PREFIXO','" + oModelSE2:GetValue("E2_PREFIXO") + "'},"
		cCposSE5 += "{'E5_NUMERO','" + oModelSE2:GetValue("E2_NUM") + "'},"
		cCposSE5 += "{'E5_TIPO','" + oModelSE2:GetValue("E2_TIPO") + "'},"
		cCposSE5 += "{'E5_PARCELA','" + oModelSE2:GetValue("E2_PARCELA") + "'},"
		cCposSE5 += "{'E5_CLIFOR','" + oModelSE2:GetValue("E2_FORNECE") + "'},"
		cCposSE5 += "{'E5_LOJA','"  + oModelSE2:GetValue("E2_LOJA") + "'},"
		cCposSE5 += "{'E5_BENEF','" + oModelSE2:GetValue("E2_NOMFOR") + "'},"
		cCposSE5 += "{'E5_DOCUMEN','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_ORDREC','" + cOrdPgo + "'},"
		cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
		cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(oModelSE2:GetValue("E2_DESCONT"))) + "},"
		cCposSE5 += "{'E5_MOEDA','" + StrZero(oModelSE2:GetValue("E2_MOEDA"),2) + "'},"
		cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(nTxMoeda)) + "},"
		cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
		If !self:lUsaFlag
			cCposSE5 += "{'E5_LA','S'},"
		EndIF
		cCposSE5 += "{'E5_MOTBX','NOR'}"
		cCposSE5 += "}"

		If !self:oFK6BxE2:IsEmpty()
			self:oFK6BxE2:AddLine()
		Endif

		self:oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
		self:oFK6BxE2:SetValue("FK6_TABORI","FK2")
		self:oFK6BxE2:SetValue("FK6_RECPAG","P")
		self:oFK6BxE2:SetValue("FK6_HISTOR",STR0077) // STR0077 - "Descuento sobre pago de titulo"
		self:oFK6BxE2:SetValue("FK6_TPDOC","DC")
		self:oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(oModelSE2:GetValue("E2_DESCONT"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
		self:oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(oModelSE2:GetValue("E2_DESCONT"),oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
	EndIf

	self:oModBxE2:SetValue("MASTER","E5_CAMPOS",cCposSE5)
	If self:oModBxE2:VldData()
		self:oModBxE2:CommitData()
		cQuery := " SELECT R_E_C_N_O_ FROM " + RetSQLName("FK2")
		cQuery += " WHERE FK2_IDFK2 = ? "
		cQuery += " AND D_E_L_E_T_ = ? "
		cQuery := ChangeQuery(cQuery)
		oExec := FwExecStatement():New(cQuery)
		oExec:SetString(1,cIDFK2)
		oExec:SetString(2,' ')

		nRecFK2 := oExec:ExecScalar('R_E_C_N_O_')
		If nRecFK2 > 0
			FK2->(DbGoTo(nRecFK2))			
			
			If self:lUsaFlag .And. self:lFlagCTB // Armazena em aFlgCTB para atualizar no modulo Contabil
				aAdd(aFlgCTB, {"FK2_LA", "S", "FK2", FK2->(Recno()), 0, 0, 0})
			Endif
			
			If oModelSE2:GetValue("E2_TIPO") $ MV_CPNEG+"/"+MVPAGANT
				If oJCotiz['lCpoCotiz'] .And. oJCotiz['TipoCotiz'] == 2 .And. oModelSE2:GetValue("E2_MOEDA") > 1
					F999ActSal(oModelSOP, cOrdPgo, 1, Round(xMoeda(FK2->FK2_VALOR, oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)))
				Else
					F999ActSal(oModelSOP, cOrdPgo, oModelSE2:GetValue("E2_MOEDA"), FK2->FK2_VALOR)
				EndIf
				If self:lReIvSU .and. oModelSE2:GetValue("E2_TIPO") $ MVPAGANT
					self:lBaretIS := .T.	
				Endif 
			Else
				If oJCotiz['lCpoCotiz'] .And. oJCotiz['TipoCotiz'] == 2 .And. oModelSE2:GetValue("E2_MOEDA") > 1
					F999ActSal(oModelSOP, cOrdPgo, 1, Round(xMoeda(FK2->FK2_VALOR, oModelSE2:GetValue("E2_MOEDA"),1,,5,nTxMoeda),MsDecimais(1)), .T.)
				Else
					F999ActSal(oModelSOP, cOrdPgo, oModelSE2:GetValue("E2_MOEDA"), FK2->FK2_VALOR, .T.)
				EndIf
			Endif
		EndIf

		oExec:Destroy()
		oExec := Nil 

		If self:lA085ATIT
			ExecBLock("A085ATIT",.F.,.F.)
		Endif

		PcoDetLan("000313","01","FINF850")
	Else
		aError := self:oModBxE2:GetErrorMessage()
		If Len(aError) >= 6
			self:cLog := cValToChar(aError[4]) + ' - '
			self:cLog += cValToChar(aError[5]) + ' - '
			self:cLog += cValToChar(aError[6])
		EndIf
		lRet := .F.
	Endif

	self:oModBxE2:DeActivate()

Return lRet
