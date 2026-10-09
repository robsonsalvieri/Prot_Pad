#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999PGO
	Clase responsable por el evento de reglas de negocio referente al proceso formas de pago
	@type 		Class
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@since		29/07/2025
/*/
Class F999PGO From FwModelEvent 

	DATA lPag1	    As Logical

	DATA lChEQU	    As Logical

	DATA lElt	    As Logical

	DATA lCBU	    As Logical

	DATA lTalao	    As Logical

	DATA lBxE2	    As Logical

	DATA cLog	    As Character

	DATA cMsj	    As Character

	DATA lA850NUM	As Logical

	DATA lA850PRECH	As Logical

	DATA lF850GRA	As Logical

	DATA lA850PAG	As Logical

	DATA cLibCheq	As Character

	DATA nMVCusto	As Character

	DATA oModBxE2   As Object

	DATA oFKABxE2   As Object

	DATA oFK2BxE2   As Object

	DATA oModBxE1   As Object

	DATA oFKABxE1   As Object

	DATA oFK1BxE1   As Object

	DATA oModMovBco As Object

	DATA oFKAMovBco As Object

	DATA oFK5MovBco As Object

	Method New() CONSTRUCTOR

	Method VldActivate()

	Method InTTS()

	Method AfterTTS()

	Method F999GRVMDL()

	Method F999GRVTB()

	Method F999GRVPGO()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@since		29/07/2025
/*/
Method New() Class F999PGO
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@param 		oModel - objeto	  - Modelo de datos.
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999PGO
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()

	self:lPag1		:= .F.

	self:lChEQU		:= .F.

	self:lElt		:= .F.

	self:lCBU		:= .F.

	self:lTalao		:= .F.

	self:lBxE2		:= .F.

	If nOperation == MODEL_OPERATION_INSERT

		self:lA850NUM	:= ExistBlock("A850NUM")

		self:lA850PRECH	:= ExistBlock("A850PRECH")

		self:lF850GRA	:= ExistBlock("F850GRA")

		self:lA850PAG	:= ExistBlock("A850PAG")

		self:cLibCheq	:= SuperGetMV("MV_LIBCHEQ", .F., "")

		self:nMVCusto	:= Val(SuperGetMV("MV_MCUSTO", .F., ""))

	EndIf
	
Return lRet

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	- Modelo de dados.
@param 		cModelId - caracter	- Identificador do sub-modelo.
@author 	Jose.Gonzalez
@version	12.1.2410 / Superior
@since		13/11/2025 
/*/
Method InTTS(oModel, cModelId) Class F999PGO
Local nOperation	:= oModel:GetOperation()
Local oModelEOP  	:= oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		Begin Transaction
			self:cLog := ""
			If !self:F999GRVMDL(oModel)
				DisarmTransaction()
				oModelEOP:SetValue("HASERROR", .T.)
			EndIf
		End Transaction
	EndIf

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
Method AfterTTS(oModel) Class F999PGO
Local nOperation := oModel:GetOperation()
Local lVldRet    := Type("lF999Ret") == "L"
Local oModelEOP  := oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT 
		If !Empty(self:cLog) .And. !Empty(self:cMsj)
			Help(,,self:cMsj,,self:cLog, 1, 0)
			If lVldRet
				lF999Ret := .F.
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} F999GRVMDL
Metodo responsable por realizar las actualizaciones de las tablas por el modelo FINA999
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	Jose.Gonzalez
@version	12.1.2410 / Superior
@since		13/11/2025 
/*/
Method F999GRVMDL(oModel) Class F999PGO
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelPAG 	:= oModel:GetModel('PAG_DETAIL')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local oModel3RO		:= oModel:GetModel('3RO_DETAIL')
Local lRet			:= .T.
Local nX 			:= 0
Local nLine 		:= 0
Local aFormasPgto   := Fin025Tipo() 
Local nPosPgto		:= 0

	self:oModBxE2 := FWLoadModel("FINM020")
	self:oFKABxE2 := self:oModBxE2:GetModel("FKADETAIL")
	self:oFK2BxE2 := self:oModBxE2:GetModel("FK2DETAIL")

	self:oModBxE1 := FWLoadModel("FINM010")
	self:oFKABxE1 := self:oModBxE1:GetModel("FKADETAIL")
	self:oFK1BxE1 := self:oModBxE1:GetModel("FK1DETAIL")

	self:oModMovBco := FWLoadModel("FINM030")
	self:oFKAMovBco := self:oModMovBco:GetModel("FKADETAIL")
	self:oFK5MovBco := self:oModMovBco:GetModel("FK5DETAIL")

	For nX := 1 To oModelFJR:Length()
		nLine := 0
		oModelFJR:GoLine(nX)

		If oModelFJR:GetValue("MARK") <> 1
			Loop
		EndIf

		//Grabado de Documentos propios
		If !Empty(oModelFJR:GetValue("FJR_ORDPAG")) .And. oModelPAG:SeekLine({{"EK_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG")}}, .F., .T.) 
			nLine := oModelPAG:GetLine()
			While nLine <= oModelPAG:Length() .And. oModelFJR:GetValue("FJR_ORDPAG") == oModelPAG:GetValue("EK_ORDPAGO");
				.And. !Empty(oModelPAG:GetValue("EK_TIPO"))

				nPosPgto := Ascan(aFormasPgto, {|pgto| AllTrim(pgto[1]) == ALLTRIM(oModelPAG:GetValue("EK_TIPO"))})
				If nPosPgto > 0 
					If aFormasPgto[nPosPgto,4] == "1"   	 // Débito Mediato
						lRet := self:F999GRVPGO(2, aFormasPgto[nPosPgto,1], aFormasPgto[nPosPgto,2],, oModel)
					ElseIf aFormasPgto[nPosPgto,4] == "2"    // Débito Inmediato	
						lRet := self:F999GRVPGO(3, aFormasPgto[nPosPgto,1],, aFormasPgto[nPosPgto,2], oModel)	
					EndIF

					If oModelEOP:GetValue("CPGTOELT") <> "1" .Or. oModelEOP:GetValue("PA")  
						If oModelFJR:GetValue("NMOERET") <> 1 .And. oModelEOP:GetValue("PA")  
							F999ActSal(oModelSOP, oModelFJR:GetValue("FJR_ORDPAG"), 1, oModelPAG:GetValue("EK_VALOR"))
						Else 
							F999ActSal(oModelSOP, oModelFJR:GetValue("FJR_ORDPAG"), Val(oModelPAG:GetValue("EK_MOEDA")), oModelPAG:GetValue("EK_VALOR"))
						EndIf	
					EndIf
				EndIf

				nLine++
				If nLine <= oModelPAG:Length()
					oModelPAG:GoLine(nLine)
				EndIf
			EndDo
		EndIf

		//Grabado de Documentos de terceros
		If !Empty(oModelFJR:GetValue("FJR_ORDPAG")) .And. oModel3RO:SeekLine({{"E1_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG")}}, .F., .T.) 
			nLine := oModel3RO:GetLine()
			While nLine <= oModel3RO:Length() .And. oModelFJR:GetValue("FJR_ORDPAG") == oModel3RO:GetValue("E1_ORDPAGO")

				lRet := self:F999GRVPGO(4,,,, oModel)

				F999ActSal(oModelSOP, oModelFJR:GetValue("FJR_ORDPAG"), oModel3RO:GetValue("E1_MOEDA"), oModel3RO:GetValue("E1_SALDO"))

				nLine++
				If nLine <= oModel3RO:Length()
					oModel3RO:GoLine(nLine)
				EndIf
			EndDo
		EndIf
	Next

Return lRet

/*/{Protheus.doc} F999GRVPGO
Función encargada de grabar las formas de pago y los documentos de terceros de la orden de pago
@author  José González
@since   20/04/2026
@version 1.0
@param	
		nPagar   - numérico - Tipo de Pago
		cModPago - caracter - Modo de Pago
		cDebMed  - caracter - Debito mediato
		cDebInm  - caracter - Debito inmediato
		oModel   - objeto   - Modelo FINA999
@return 
/*/
Method F999GRVPGO(nPagar, cModPago, cDebMed, cDebInm, oModel) Class F999PGO
Local cSeqFRF	:= ""
Local nMoedaBco	:= 1
Local nSize		:= 0
Local nValorTit	:= 0
Local lChMed	:= .F.
Local lChInMed	:= .F.
Local lFindITF	:= .T.
Local lRet		:= .T.
Local cFiltroSe2:= ""
Local nSeqSXE	:= 0
Local cCposSE5	:= ""
Local cIDDoc	:= ""
Local cChaveTit	:= ""
Local cIDSEF	:= ""
Local cRedNome  := ""
Local oModelSE2 := oModel:GetModel('SE2_DETAIL')
Local oModelEOP := oModel:GetModel('EOP_MASTER')
Local oModelFJR := oModel:GetModel('FJR_MASTER')
Local oModelMOE := oModel:GetModel('MOE_DETAIL')
Local oModelTTB := oModel:GetModel('TTB_DETAIL')
Local oModelPAG := oModel:GetModel('PAG_DETAIL') 
Local oModel3RO := oModel:GetModel('3RO_DETAIL') 
Local cBanco	:= oModelPAG:GetValue("EK_BANCO")
Local cAgencia	:= oModelPAG:GetValue("EK_AGENCIA")
Local cConta	:= oModelPAG:GetValue("EK_CONTA")
Local cNumChq  	:= oModelPAG:GetValue("EK_NUM")
Local cParcela 	:= oModelPAG:GetValue("EK_PARCELA")
Local dDtVcto	:= oModelPAG:GetValue("EK_VENCTO")
Local nTotal 	:= oModelPAG:GetValue("EK_VALOR")
Local dDtEmis 	:= oModelPAG:GetValue("EK_EMISSAO")
Local cTalao 	:= oModelPAG:GetValue("EK_TALAO")
Local cPrefixo 	:= oModelPAG:GetValue("EK_PREFIXO")
Local nMoeda 	:= Val(oModelPAG:GetValue("EK_MOEDA"))
Local cFornece 	:= oModelFJR:GetValue("FJR_FORNEC")
Local cLoja 	:= oModelFJR:GetValue("FJR_LOJA")
Local cNome		:= oModelFJR:GetValue("NOMBRE")
Local cIDProc 	:= oModelFJR:GetValue("CIDPROC")
Local cLiquid	:= oModelFJR:GetValue("CLIQUID")
Local cOrdPago 	:= oModelFJR:GetValue("FJR_ORDPAG")
Local cNatureza	:= oModelFJR:GetValue("FJR_NATURE")
Local lCBU 		:= oModelFJR:GetValue("CBU")
Local nValMOrig := oModelFJR:GetValue("VALORIG")
local nTxPromed := oModelFJR:GetValue("NTXPROM")  	
local aTxProm   := {}
Local cOpcElt 	:= oModelEOP:GetValue("CPGTOELT") 
Local lPa		:= oModelEOP:GetValue("PA")
Local cJCotiz	:= oModelEOP:GetValue("COTIZ")
Local oJTxProm	:= JsonObject():New()
Local oJCotiz 	:= JsonObject():New()
Local nRecEQU	:= 0
Local nRegSE1	:= oModel3RO:GetValue('RECSE1')
Local aAreaSE2  := {}
Local aAreaSA6	:= {}
Local cCampo	:= ""
Local aError	:= {}

Default nPagar   := 0
Default cModPago := ""
Default cDebMed  := ""
Default cDebInm	 := ""
Default oModel   := Nil

oJCotiz:FromJson(cJCotiz)
oJTxProm:FromJson(oModelFJR:GetValue("ATXPROM"))
aTxProm := oJTxProm['txprom']

If nPagar == 4
	nRecEQU := oModel3RO:GetValue('RECSEF')
Else
	nRecEQU := oModelPAG:GetValue('RECSEF')
EndIf

If !Empty(cBanco)
	SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	SA6->(MsSeek(xFilial()+cBanco+cAgencia+cConta))
	nMoedaBco := IIF(SA6->A6_MOEDAP > 0, SA6->A6_MOEDAP, SA6->A6_MOEDA)
	nMoedaBco := Max(nMoedaBco, 1)
Endif

SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
If  SA2->(MsSeek(xFilial()+cFornece+cLoja))
	cRedNome := SA2->A2_NREDUZ
Endif

aAreaSE2  := SE2->(GetArea())

/*Pegar a numero que vou usar para numerar os documentos gerados.*/
If (nPagar == 2 .Or. nPagar == 3) .And. (Empty(cNumChq) .Or. Substr(cNumChq,1,1) == '*')
	If self:lA850NUM
		cNumChq	:= ExecBlock("A850NUM",.F.,.F.,{nPagar,cFornece,cLoja,dDtVcto})
		If self:lA850PRECH
			cFiltroSE2 := SE2->(DbFilter())  //Guarda el filtro para que pueda ser consultado todo el SE2 no RDMAKE
	 		SE2->(dbClearFilter())
			cPrefixo := ExecBlock("A850PRECH", .F., .F., {cNumChq, cFornece, cLoja, cBanco, cAgencia, cConta})
			DbSelectArea("SE2")
			SE2->(DbSetFilter({|| (&("{||" + cFiltroSE2 + "}"))}, cFiltroSE2)) //Restaura el filtro original
		EndIF
	Else
		aAreaSA6  := SA6->(GetArea())
		DbSelectArea("SA6")                                                                                                                                                                              
		cCampo := "A6_NUM"+Iif(nPagar == 2,cDebMed,cDebInm)
		If SA6->(ColumnPos(cCampo)) > 0
			nSize	:=	Len(Alltrim(&cCampo.))
			nSize	:=	If(nSize == 0, GetSx3Cache("E2_NUM","X3_TAMANHO"),nSize) 
			cNumChq	:=	&cCampo
			Reclock("SA6",.F.)
			&cCampo	:= StrZero(Val(&cCampo.)+1, nSize)
			SA6->(MsUnLock())
		Else
			cNumChq	:= cOrdPago
		Endif
		RestArea(aAreaSA6)
	Endif
Endif

//Gravar os debitos inmediatos (Transferencias, Cash, Cartao de debito, etc)
If 	nPagar == 3 .And. nTotal > 0 .And. !(AllTrim(cDebInm) $ MVCHEQUE) .And. cOpcElt <> "1"
	self:oModMovBco:SetOperation(MODEL_OPERATION_INSERT)
	self:oModMovBco:Activate()
	self:oModMovBco:SetValue("MASTER","E5_GRV",.T.)
	self:oModMovBco:SetValue("MASTER","IDPROC",cIDProc)

	cCposSE5 := "{"
	cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
	cCposSE5 += "{'E5_VENCTO',dDataBase},"
	cCposSE5 += "{'E5_TIPO','" + cDebInm + "'},"
	cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
	cCposSE5 += "{'E5_PREFIXO',''},"
	cCposSE5 += "{'E5_NUMERO','" + cNumChq + "'},"
	cCposSE5 += "{'E5_PARCELA','" + cParcela + "'},"
	cCposSE5 += "{'E5_CLIFOR','" + cFornece + "'},"
	cCposSE5 += "{'E5_LOJA','"  + cLoja + "'},"
	cCposSE5 += "{'E5_BENEF','" + Iif(!Empty(cNome),cNome,cRedNome)  + "'},"
	cCposSE5 += "{'E5_MOTBX','NOR'}"
	cCposSE5 += "}"

	self:oModMovBco:SetValue("MASTER","E5_CAMPOS",cCposSE5)
	self:oFKAMovBco:SetValue("FKA_IDORIG"	,FWUUIDV4())
	self:oFKAMovBco:SetValue("FKA_TABORI"	,"FK5")

	self:oFK5MovBco:SetValue("FK5_VALOR"	,Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(nMoedaBco)))
	self:oFK5MovBco:SetValue("FK5_RECPAG"	,"P")
	self:oFK5MovBco:SetValue("FK5_HISTOR"	,STR0066+ ' ' + cOrdPago) //"Ord. pago "
	self:oFK5MovBco:SetValue("FK5_DATA"		,dDataBase)
	self:oFK5MovBco:SetValue("FK5_NATURE"	,cNatureza)
	self:oFK5MovBco:SetValue("FK5_TPDOC"	,"VL")
	//Gravar a moeda2 em moeda 1 para facilitar a contabilizacao
	self:oFK5MovBco:SetValue("FK5_VLMOE2"	,Round(xMoeda(nTotal,nMoeda,1,,5,oModelMOE:GetValue('TASA',nMoeda),),MsDecimais(1)))
	self:oFK5MovBco:SetValue("FK5_ORDREC"	,cOrdPago)
	self:oFK5MovBco:SetValue("FK5_BANCO"	,cBanco)
	self:oFK5MovBco:SetValue("FK5_AGENCI"	,cAgencia)
	self:oFK5MovBco:SetValue("FK5_CONTA"	,cConta)
	If self:lChEQU
		self:oFK5MovBco:SetValue("FK5_NUMCH",cNumChq)
	EndIf
	self:oFK5MovBco:SetValue("FK5_MOEDA"	,StrZero(nMoedaBco,2))
	self:oFK5MovBco:SetValue("FK5_DTDISP"	,dDtVcto)
	self:oFK5MovBco:SetValue("FK5_LA"		,"S")
	self:oFK5MovBco:SetValue("FK5_FILORI"	,SubString(cFilAnt,1,len(FK5->FK5_FILIAL)))
	self:oFK5MovBco:SetValue("FK5_ORIGEM"	,"FINA850")
	self:oFK5MovBco:SetValue("FK5_TXMOED"	,oModelMOE:GetValue('TASA',nMoedaBco))

	If self:oModMovBco:VldData()
		self:oModMovBco:CommitData()
		AtuSalBco(FK5->FK5_BANCO,FK5->FK5_AGENCIA,FK5->FK5_CONTA,dDtVcto,FK5->FK5_VALOR,"-")
	Else
		aError := self:oModMovBco:GetErrorMessage()
		If Len(aError) >= 6
			self:cLog := cValToChar(aError[4]) + ' - '
			self:cLog += cValToChar(aError[5]) + ' - '
			self:cLog += cValToChar(aError[6])
			self:cMsj := "ORDPAG_DBIM"
		EndIf
		lRet := .F.
	Endif
	self:oModMovBco:DeActivate()

//Gravar os debitos mediatos (Cheques, Letras, Etc), e os cheques de deb. inmediato.
ElseIf nPagar <> 4
	If nPagar == 2 .And. Trim(cDebMed) == Trim(MVCHEQUE)
		lChMed := .T.
	EndIf
	If nPagar == 3 .And. Trim(cDebInm) == Trim(MVCHEQUE)
		lChInMed := .T.
	EndIf
	If (lChMed .Or. lChInMed) .And. nTotal > 0
		SEF->(DbGoTo(nRecEQU))
		If SEF->(Recno()) == nRecEQU
			cPrefixo := SEF->EF_PREFIXO
			RecLock("SEF",.F.)
			SEF->EF_VALOR   := Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(nMoedaBco))
			//Grava o numero do cheque somente se for pagamento diferenciado
			SEF->EF_BENEF	:= cNome
			SEF->EF_VENCTO	:= dDtVcto 	
			SEF->EF_DATA	:= dDtEmis
			SEF->EF_HIST 	:= STR0066 + cOrdPago //"Ord. pago "
			SEF->EF_LIBER 	:= If(nPagar == 1,self:cLibCheq,"S")
			SEF->EF_FORNECE	:= cFornece
			SEF->EF_LOJA	:= cLoja
			SEF->EF_LA     	:= "S"
			SEF->EF_SEQUENC	:= PadL("1",GetSx3Cache("EF_SEQUENC","X3_TAMANHO"),"0") 
			SEF->EF_PARCELA	:= cParcela

			If lChInMed 
				SEF->EF_STATUS	:= "04"
				SEF->EF_REFTIP	:= "LP"
			Else
				SEF->EF_STATUS	:= "02"
			EndIf

			SEF->EF_ORDPAGO	:= cOrdPago
			SEF->EF_IDSEF	:= FWUUIDV4()

			
			SEF->EF_TITULO  := cOrdPago
			SEF->EF_TIPO    := Trim(MVCHEQUE)
			SEF->EF_ORIGEM 	:= "FINA850"
			SEF->EF_FILCHQ	:= cFilAnt

			SEF->(MsUnlock())

			cSeqFRF := GetSx8Num("FRF","FRF_SEQ")

		    RecLock("FRF",.T.)
		    FRF->FRF_FILIAL		:= xFilial("FRF")
		    FRF->FRF_BANCO		:= SEF->EF_BANCO
		    FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
		    FRF->FRF_CONTA		:= SEF->EF_CONTA
		    FRF->FRF_NUM		:= SEF->EF_NUM
		    FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
		    FRF->FRF_CART		:= "P"
		    FRF->FRF_DATPAG		:= dDataBase
		    FRF->FRF_MOTIVO		:= "99"
		    FRF->FRF_DESCRI		:= STR0067 //"CHEQUE VINCULADO A PAGO"
		    FRF->FRF_SEQ		:= cSeqFRF
		    FRF->FRF_FORNEC		:= cFornece
		    FRF->FRF_LOJA		:= cLoja
		    FRF->FRF_NUMDOC		:= cOrdPago
		    FRF->(MsUnLock())

			//Confirma a numeração do historico
			ConfirmSX8()

			//Se for cheque que gera movimento bancário, gera o histórico de liquidação
			If lChInMed .And. cOpcElt <> "1"
				cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			    RecLock("FRF",.T.)
			    FRF->FRF_FILIAL		:= xFilial("FRF")
			    FRF->FRF_BANCO		:= SEF->EF_BANCO
			    FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
			    FRF->FRF_CONTA		:= SEF->EF_CONTA
			    FRF->FRF_NUM		:= SEF->EF_NUM
			    FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
			    FRF->FRF_CART		:= "P"
			    FRF->FRF_DATPAG		:= dDataBase
			    FRF->FRF_MOTIVO		:= "10"
			    FRF->FRF_DESCRI		:= STR0068 //"CHEQUE COMPENSADO"
			    FRF->FRF_SEQ		:= cSeqFRF
			    FRF->FRF_FORNEC		:= cFornece
			    FRF->FRF_LOJA		:= cLoja
			    FRF->FRF_NUMDOC		:= cOrdPago
			    FRF->(MsUnLock())

				ConfirmSX8()
			EndIf
		Endif
	Endif

	If (nPagar == 2 .Or. lChInMed) .And. nTotal > 0 .And. cOpcElt <> "1"  // debito mediato (CH)
		DbSelectArea("SE2")
		// GERAR SE2
		RecLock("SE2",.T.)
		SE2->E2_FILIAL		:= xFilial("SE2")
		SE2->E2_FILORIG  	:= cFilAnt
		SE2->E2_NUMLIQ		:= cLiquid
		If SEF->(Recno()) == nRecEQU
			SE2->E2_NUMBCO	:= cNumChq
			SE2->E2_PREFIXO	:= SEF->EF_PREFIXO
			cPrefixo 		:= SEF->EF_PREFIXO
		Endif
		SE2->E2_NUM   		:= cNumChq
		SE2->E2_PREFIXO 	:= cPrefixo
		SE2->E2_TIPO 		:= Iif(lChInMed,cDebInm,cDebMed)
		SE2->E2_NATUREZ 	:= cNatureza
		SE2->E2_FORNECE		:= cFornece
		SE2->E2_LOJA  		:= cLoja
		SE2->E2_NOMFOR 		:= Iif(!Empty(cNome),cNome,cRedNome)  
		SE2->E2_EMISSAO		:= dDtEmis
		SE2->E2_EMIS1 		:= dDtEmis
		SE2->E2_VENCTO		:= dDtVcto
		SE2->E2_VENCREA		:= DataValida(dDtVcto,.T.)
		nValorTit			:= Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(nMoedaBco))
		SE2->E2_VALOR   	:= nValorTit
		SE2->E2_VENCORI		:= DataValida(dDtVcto,.T.)
		SE2->E2_PARCELA 	:= cParcela
		If lBaixaChq .Or. lChInMed
			SE2->E2_VALLIQ  := nValorTit
			SE2->E2_SALDO   := 0
			SE2->E2_BAIXA   := dDataBase
			SE2->E2_MOVIMEN := dDataBase
			SE2->E2_BCOPAG  := cBanco
		Else
			SE2->E2_SALDO   := nValorTit
		Endif
		SE2->E2_VLCRUZ 		:= Round(xMoeda(nTotal,nMoedaBco,1,,5,oModelMOE:GetValue('TASA',nMoeda)),MsDecimais(1))
		SE2->E2_MOEDA   	:= nMoedaBco
		SE2->E2_SITUACA  	:= "0"
		SE2->E2_PORTADO  	:= cBanco
		SE2->E2_BCOCHQ   	:= cBanco
		SE2->E2_AGECHQ   	:= cAgencia
		SE2->E2_CTACHQ   	:= cConta
		SE2->E2_ORDPAGO  	:= cOrdPago
		SE2->E2_ORIGEM 		:= "FINA850"
		SE2->E2_LA       	:= "S"
		SE2->E2_TXMOEDA 	:= oModelMOE:GetValue('TASA',Max(nMoedaBco,1))//GRAVA A TAXA DA MOEDA DO PA
		SE2->E2_DATALIB		:= dDtEmis
		If !Empty(cPrefixo)
			SE2->E2_PREFIXO := cPrefixo
		EndIf
		SE2->(MsUnlock())
		FKCommit()

		If (lBaixaChq .And. !(self:lBxE2)) .Or. lChInMed
			self:oModBxE2:SetOperation(MODEL_OPERATION_INSERT)
			self:oModBxE2:Activate()
			self:oModBxE2:SetValue("MASTER","E5_GRV",.T.)
			self:oModBxE2:SetValue("MASTER","IDPROC",cIDProc)

			cCposSE5 := "{"
			cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
			cCposSE5 += "{'E5_TIPO','" + If(lChInMed,cDebInm,cDebMed) + "'},"
			cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
			cCposSE5 += "{'E5_PREFIXO','" + cPrefixo + "'},"
			cCposSE5 += "{'E5_NUMERO','" + cNumChq + "'},"
			cCposSE5 += "{'E5_PARCELA','" + cParcela + "'},"
			cCposSE5 += "{'E5_CLIFOR','" + cFornece + "'},"
			cCposSE5 += "{'E5_LOJA','"  + cLoja + "'},"
			cCposSE5 += "{'E5_BENEF','" + Iif(!Empty(cNome),cNome,cRedNome) + "'},"
			cCposSE5 += "{'E5_BANCO','" + cBanco + "'},"
			cCposSE5 += "{'E5_AGENCIA','" + cAgencia + "'},"
			cCposSE5 += "{'E5_CONTA','" + cConta + "'},"
			cCposSE5 += "{'E5_DTDISPO',Ctod('" + Dtoc(dDtVcto) + "')}"
			cCposSE5 += "}"

			cChaveTit := xFilial("SE2") + "|"
			cChaveTit += cPrefixo + "|"
			cChaveTit += cNumChq + "|"
			cChaveTit += cParcela + "|"
			cChaveTit += Iif(lChInMed,cDebInm,cDebMed) + "|"
			cChaveTit += cFornece + "|"
			cChaveTit += cLoja
			cIdDoc := FINGRVFK7("SE2", cChaveTit)

			self:oModBxE2:SetValue("MASTER","E5_CAMPOS",cCposSE5)
			self:oFKABxE2:SetValue("FKA_IDORIG"	,FWUUIDV4())
			self:oFKABxE2:SetValue("FKA_TABORI"	,"FK2")

			self:oFK2BxE2:SetValue("FK2_VALOR"	,Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(nMoedaBco)))
			self:oFK2BxE2:SetValue("FK2_RECPAG"	,"P")
			self:oFK2BxE2:SetValue("FK2_HISTOR"	,STR0069)		// "DEBITO CC"
			self:oFK2BxE2:SetValue("FK2_DATA"	,dDataBase)
			self:oFK2BxE2:SetValue("FK2_TPDOC"	,"VL")
			//Gravar a moeda2 em moeda 1 para facilitar a contabilizacao
			If lPa
				self:oFK2BxE2:SetValue("FK2_VLMOE2",Round(xMoeda(nTotal,nMoeda,1,,5,oModelMOE:GetValue('TASA',nMoeda)),5))
			Else
				self:oFK2BxE2:SetValue("FK2_VLMOE2",nValMOrig)
		  	EndIf
			self:oFK2BxE2:SetValue("FK2_SEQ"	,PadL("1",GetSx3Cache("E5_SEQ","X3_TAMANHO"),"0")) 
			self:oFK2BxE2:SetValue("FK2_MOEDA"	,StrZero(nMoedaBco,2))
			self:oFK2BxE2:SetValue("FK2_NATURE"	,cNatureza)
			self:oFK2BxE2:SetValue("FK2_TXMOED"	,oModelMOE:GetValue('TASA',nMoedaBco))
			self:oFK2BxE2:SetValue("FK2_MOTBX"	,If(lChInMed,"NOR","DEB"))
			self:oFK2BxE2:SetValue("FK2_FILORI"	,cFilAnt)
			self:oFK2BxE2:SetValue("FK2_IDDOC"	,cIdDoc)
			self:oFK2BxE2:SetValue("FK2_ORIGEM"	,"FINA850")

			If self:oModBxE2:VldData()
				self:oModBxE2:CommitData()
				AtuSalBco(FK5->FK5_BANCO,FK5->FK5_AGENCIA,FK5->FK5_CONTA,dDtVcto,FK5->FK5_VALOR,"-")
			Else
				aError := self:oModBxE2:GetErrorMessage()
				If Len(aError) >= 6
					self:cLog := cValToChar(aError[4]) + ' - '
					self:cLog += cValToChar(aError[5]) + ' - '
					self:cLog += cValToChar(aError[6])
					self:cMsj := "ORDPAG_DBMEBXCH"
				EndIf
				lRet := .F.
			Endif
			self:oModBxE2:DeActivate()
		Else
			Reclock("SA2",.F.)
			SA2->A2_SALDUP	:= SA2->A2_SALDUP  + Round(xMoeda(nValorTit,nMoedaBco,1,,5,oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(1))
			SA2->A2_SALDUPM	:= SA2->A2_SALDUPM + Round(xMoeda(nValorTit,nMoedaBco,self:nMVCusto,,5,oModelMOE:GetValue('TASA',nMoedaBco),oModelMOE:GetValue('TASA',self:nMVCusto)),MsDecimais(self:nMVCusto))
			SA2->(MsUnlock())
		EndIf
	EndIf
Else
	//Baixar cheques de terceiros aplicados no pagamento
	/*atualiza o controle de cheques recebidos*/
	If !Empty(nRecEQU)
		SEF->(DbGoTo(nRecEQU))
		If SEF->(Recno()) == nRecEQU
			RecLock("SEF",.F.)
			SEF->EF_ORDPAGO	:= cOrdPago
			SEF->EF_STATUS	:= "09"
			SEF->EF_FILCHQ	:= cFilAnt
			SEF->(MsUnLock())
			/*Registra el movimento en el archivo de historicos*/
			cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			RecLock("FRF",.T.)
			FRF->FRF_FILIAL	:= xFilial("FRF")
			FRF->FRF_BANCO	:= SEF->EF_BANCO
			FRF->FRF_AGENCI	:= SEF->EF_AGENCIA
			FRF->FRF_CONTA	:= SEF->EF_CONTA
			FRF->FRF_NUM	:= SEF->EF_NUM
			FRF->FRF_PREFIX	:= SEF->EF_PREFIXO
			FRF->FRF_CART	:= "P"
			FRF->FRF_DATPAG	:= dDataBase
			FRF->FRF_MOTIVO	:= "99"
			FRF->FRF_DESCRI	:= STR0067 //"CHEQUE VINCULADO A PAGO"
			FRF->FRF_SEQ	:= cSeqFRF
			FRF->FRF_FORNEC	:= cFornece
			FRF->FRF_LOJA	:= cLoja
			FRF->FRF_NUMDOC	:= cOrdPago
			FRF->(MsUnLock())
			ConfirmSX8()
		Endif
	Endif

	If nRegSE1 # nil
		SE1->(MsGoto(nRegSE1))
		If !SE1->(Eof())
			self:oModBxE1:SetOperation(MODEL_OPERATION_INSERT)
			self:oModBxE1:Activate()
			self:oModBxE1:SetValue("MASTER","E5_GRV",.T.)
			self:oModBxE1:SetValue("MASTER","IDPROC",cIDProc)
			cCposSE5 := "{"
			cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
			cCposSE5 += "{'E5_PREFIXO','" + SE1->E1_PREFIXO + "'},"
			cCposSE5 += "{'E5_NUMERO','" + SE1->E1_NUM + "'},"
			cCposSE5 += "{'E5_BCOCHQ','" + SE1->E1_BCOCHQ + "'},"
			cCposSE5 += "{'E5_AGECHQ','" + SE1->E1_AGECHQ + "'},"
			cCposSE5 += "{'E5_CTACHQ','" + SE1->E1_CTACHQ + "'},"
			cCposSE5 += "{'E5_PARCELA','" + SE1->E1_PARCELA + "'},"
			cCposSE5 += "{'E5_CLIFOR','" + SE1->E1_CLIENTE + "'},"
			cCposSE5 += "{'E5_LOJA','" + SE1->E1_LOJA + "'},"
			cCposSE5 += "{'E5_BENEF','" + cFornece+cLoja + "'},"
			cCposSE5 += "{'E5_TIPO','" + SE1->E1_TIPO + "'},"
			cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'}"
			cCposSE5 += "}"

			cChaveTit := xFilial("SE1") + "|"
			cChaveTit += SE1->E1_PREFIXO + "|"
			cChaveTit += SE1->E1_NUM + "|"
			cChaveTit += SE1->E1_PARCELA + "|"
			cChaveTit += SE1->E1_TIPO + "|"
			cChaveTit += SE1->E1_CLIENTE + "|"
			cChaveTit += SE1->E1_LOJA
			cIdDoc := FINGRVFK7("SE1", cChaveTit)

			self:oModBxE1:SetValue("MASTER","E5_CAMPOS",cCposSE5)
			cIDSEF := FWUUIDV4()
			self:oFKABxE1:SetValue("FKA_IDORIG"	,cIDSEF)
			self:oFKABxE1:SetValue("FKA_TABORI"	,"FK1")

			self:oFK1BxE1:SetValue("FK1_RECPAG"	,"R")
			self:oFK1BxE1:SetValue("FK1_HISTOR"	,STR0078+cOrdPago) //"Entregado OP "
			self:oFK1BxE1:SetValue("FK1_DATA"	,SE1->E1_EMISSAO)
			self:oFK1BxE1:SetValue("FK1_NATURE"	,SE1->E1_NATUREZ)
			self:oFK1BxE1:SetValue("FK1_VENCTO"	,SE1->E1_VENCTO)
			self:oFK1BxE1:SetValue("FK1_TPDOC"	,"BA")
			self:oFK1BxE1:SetValue("FK1_MOTBX"	,"LIQ")
			self:oFK1BxE1:SetValue("FK1_VLMOE2"	,SE1->E1_VALOR)
			self:oFK1BxE1:SetValue("FK1_SEQ"	,PadL("1",GetSx3Cache("E5_SEQ","X3_TAMANHO"),"0")) 
			self:oFK1BxE1:SetValue("FK1_DOC"	,cOrdPago)
			self:oFK1BxE1:SetValue("FK1_ORDREC"	,cOrdPago)
			self:oFK1BxE1:SetValue("FK1_MOEDA"	,StrZero(SE1->E1_MOEDA,2))
			self:oFK1BxE1:SetValue("FK1_VALOR"	,SE1->E1_VLCRUZ)
			self:oFK1BxE1:SetValue("FK1_IDDOC"	,cIdDoc)
			self:oFK1BxE1:SetValue("FK1_FILORI"	,SE1->E1_FILORIG)
			self:oFK1BxE1:SetValue("FK1_ORIGEM"	,"FINA850")
			self:oFK1BxE1:SetValue("FK1_LA"		,"S")

			If self:oModBxE1:VldData()
				self:oModBxE1:CommitData()
				RecLock("SEK",.T.)
				SEK->EK_FILIAL   := xFilial("SEK")
				SEK->EK_TIPODOC  := "CT" //CHEQUE Tercero
				SEK->EK_PREFIXO  := SE1->E1_PREFIXO
				SEK->EK_NUM      := SE1->E1_NUM
				SEK->EK_PARCELA  := SE1->E1_PARCELA
				SEK->EK_TIPO     := SE1->E1_TIPO
				SEK->EK_VALOR    := SE1->E1_VALOR
				SEK->EK_SALDO    := SE1->E1_SALDO
				SEK->EK_MOEDA    := AllTrim( Str(SE1->E1_MOEDA))
				SEK->EK_BANCO    := SE1->E1_BCOCHQ
				SEK->EK_AGENCIA  := SE1->E1_AGECHQ
				SEK->EK_CONTA    := SE1->E1_CTACHQ
				SEK->EK_ENTRCLI  := SE1->E1_CLIENTE
				SEK->EK_LOJCLI   := SE1->E1_LOJA
				SEK->EK_EMISSAO  := SE1->E1_EMISSAO
				SEK->EK_VENCTO   := SE1->E1_VENCTO
				SEK->EK_VLMOED1  := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1, dDataBase,5,oModelMOE:GetValue('TASA',SE1->E1_MOEDA)),MsDecimais(1))
				SEK->EK_ORDPAGO  := cOrdPago
				SEK->EK_DTDIGIT  := dDataBase
				SEK->EK_FORNECE  := cFornece
				SEK->EK_LOJA     := cLoja
				SEK->EK_FORNEPG  := cFornece
				SEK->EK_LOJAPG   := cLoja
				If self:lCBU
					SEK->EK_PGCBU := lCBU
				EndIf
				F999GrvTx(oJCotiz['MonedaCotiz'], nTxPromed, aTxProm, oJCotiz, oModelMOE,, .T.) 
				SEK->(MsUnlock())
				
			Else
				aError := self:oModBxE1:GetErrorMessage()
				If Len(aError) >= 6
					self:cLog := cValToChar(aError[4]) + ' - '
					self:cLog += cValToChar(aError[5]) + ' - '
					self:cLog += cValToChar(aError[6])
					self:cMsj := "ORDPAG_DBDT"
				EndIf
				lRet := .F.
			Endif
			self:oModBxE1:DeActivate()
		EndIf
	EndIf
EndIf

If lRet .And. nPagar <> 4
	//No puede ser grabado un documento con valor de 0
	If nTotal > 0
		RecLock("SEK",.T.)
		SEK->EK_FILIAL		:= xFilial("SEK")
		SEK->EK_TIPODOC		:= "CP"     //CHEQUE PROPIO
		SEK->EK_NUM			:= cNumChq
		SEK->EK_TIPO 		:= If(nPagar == 3, cDebInm, If(nPagar=2,cDebMed,"CA"))
		SEK->EK_FORNECE		:= cFornece
		SEK->EK_LOJA   		:= cLoja
		SEK->EK_EMISSAO		:= dDtEmis
		SEK->EK_VENCTO 		:= dDtVcto
		SEK->EK_VALOR  		:= Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(nMoedaBco))
		SEK->EK_VLMOED1		:= Round(xMoeda(nTotal,nMoeda,1,,5,oModelMOE:GetValue('TASA',nMoeda),oModelMOE:GetValue('TASA',nMoedaBco)),MsDecimais(1))
		SEK->EK_MOEDA 		:= AllTrim(Str(nMoedaBco))
		SEK->EK_BANCO 		:= cBanco
		SEK->EK_AGENCIA		:= cAgencia
		SEK->EK_CONTA 		:= cConta
		SEK->EK_ORDPAGO		:= cOrdPago
		SEK->EK_DTDIGIT		:= dDataBase
		SEK->EK_FORNEPG 	:= cFornece
		SEK->EK_LOJAPG  	:= cLoja
		SEK->EK_PARCELA 	:= cParcela
		SEK->EK_PREFIXO 	:= cPrefixo
		IF self:lTalao
			SEK->EK_TALAO	:= cTalao
		EndIF
		SEK->EK_NATUREZ 	:= cNatureza
		
		If self:lCBU
			SEK->EK_PGCBU 	:= lCBU
		EndIf

		If self:lElt		
			SEK->EK_PGTOELT := cOpcElt
			SEK->EK_MODPAGO := cModPago
		Endif

		If self:lA850PRECH
			SEK->EK_PREFIXO := cPrefixo
		EndIf
		
		F999GrvTx(oJCotiz['MonedaCotiz'], nTxPromed, aTxProm, oJCotiz, oModelMOE,, .T.) 
		SEK->(MsUnlock())

		IF self:lF850GRA
			ExecBlock("F850GRA",.f.,.f.)
		Endif

		If self:lElt		
			//Actualiza el encabezado de la orden de pago
			DbSelectArea("FJR")
			DbSetOrder(1) //FJR_FILIAL+FJR_ORDPAG
			If MsSeek(XFilial("FJR")+SEK->EK_ORDPAGO)
				RecLock("FJR",.F.)
				FJR->FJR_PGTELT := cOpcElt
				FJR->(MsUnlock())
			EndIf
		EndIf
	EndIf
EndIf

If self:lA850PAG
	ExecBlock("A850PAG",.F.,.F.)
Endif

RestArea(aAreaSE2)

Return(lRet)
