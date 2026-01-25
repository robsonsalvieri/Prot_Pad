#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'
#INCLUDE "FWLIBVERSION.CH"

/*/{Protheus.doc} F887FIN
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/01/2021
/*/
Class F887FIN From FwModelEvent 

	//Fecha de referencia
    DATA dDataRef 
    
    DATA cCredMed As Character
    
    DATA cCredInm As Character
    
    DATA cTiposAdm As Character
    
    DATA cDocCred As Character
    
    DATA lChaveSE1 As logical
    
    DATA lDelRA	As logical
    
    DATA lDelEAI As logical
    
    DATA lBDGA As logical
	
	DATA lBInteg As logical
	
	DATA nRecnoSAQ	As numeric
	
	DATA lCredInm As logical

	DATA lProcede As logical

	DATA lRecSus As logical

	DATA lPostal As Logical

	DATA lTasa 	As Logical
	
	DATA lDocTran As logical
	
	DATA lValidITF As logical
	
	DATA lRoundVal	As logical
	
	DATA lSerRec As logical

	DATA lRecMVC As logical
	
	DATA nSaveSX8 As numeric

	DATA lVlCorre 	As Logical

	DATA lTipodoc As Logical

	DATA lVldVcto As Logical

	DATA lSituaca As Logical

	DATA lCFDI As Logical

	DATA lCompen As Logical

	DATA lActTipo As Logical

	DATA nRecnoSEY As Numeric

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
	Method ModelPosVld()
 
	Method BeforeTTS()
	
	Method InTTS()
	
	Method AfterTTS()
	
	Method FINUPDSEL()
	
	Method FINUPDSE()
	
	Method FINUPDSE1()
	
	Method FINGrvSE5()
	
	Method FINCREDMED()
	
	Method FINUPDSEA()
	
	Method FINCOB()
	
	Method FINCOM()
	
	Method FINGERNCC()
	
	Method F887DEL()

	Method F887CAN()
	
	Method F887CkPG()
	
	Method GridLinePosVld()

	Method GridLinePreVld()

	Method FieldPreVld()

	Method ValidTitle()
 
	Method Destroy()

	Method DeActivate()

	Method ImpEnvRec()

	Method GridPosVld()

	Method F887EDTCH()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/04/2017 
/*/
Method New() Class F887FIN
	
Return Nil

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method VldActivate(oModel) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.
	
	self:dDataRef	:= dDatabase

	self:lProcede	:= .T.

	self:lRecSus	:= .F.
	
	self:cCredMed	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")
	self:cCredMed	:= IIf(Empty(self:cCredMed),GetSESNew("CH|CC","3") ,self:cCredMed)
	
	self:cCredInm	:= GetSESTipos({|| ES_RCOPGER == "2"},"1")
	self:cCredInm	:= IIf(Empty(self:cCredInm),"TF /EF /CC /CD ",self:cCredInm)
	
	self:cTiposAdm 	:= GetSAETipos()
	
	self:cDocCred	:= ""
	
	self:lChaveSE1	:= .T.
	
	self:lDelRA		:= .F.
	
	self:lDelEAI	:= .F.
	
	self:lCredInm	:= .F.
	
	self:lDocTran 	:= .F.
	
	self:lValidITF	:= .F.
	
	self:lRoundVal 	:= .F.

	self:lPostal	:= .F.

	self:nRecnoSEY	:= 0 
	
	self:lSerRec	:= SuperGetMV('MV_SERREC')

	self:lRecMVC	:= SuperGetMV('MV_RECMVC')
	
	self:nSaveSX8	:= GetSX8Len()
	
	self:lTasa 		:= .T.

	self:lVlCorre 	:= .F. //Desactiva la Corrección monetaria 

	self:lTipodoc	:= .T.

	self:lVldVcto 	:= .T.

	self:lSituaca	:= .F.

	self:lCFDI		:= .F.

	self:lCompen 	:= .F.

	self:lActTipo	:= .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method Destroy() Class F887FIN

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
@since		05/05/2021 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cModelID) Class F887FIN
Local lValid 		:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelFJT		:= oModel:GetModel("FJT_MASTER")
Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
Local oModelSE1		:= oModel:GetModel("SE1_DETAIL")
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local aArea			:= {}
Local a998ok		:= {}
Local cRecProv		:= ""
Local cCobrador		:= ""
Local cSerie		:= ""
Local cTipo			:= ""
Local nLine			:= 0
Local nSelLine		:= 0
Local nSe1Line		:= 0
Local nLineSEL		:= 0
Local nLineSE1		:= 0
Local aCaixaFin		:= xCxFina()
Local cBlockBco		:= ""		
Local cRecibo		:= ""
Local cBanco		:= ""
Local cAgencia		:= ""
Local cNumcon		:= ""
Local cText			:= ""
Local cSaldo		:= ""
Local nAux 			:= 1
Local aAreaSE 		:= {}
Local lDescMoe		:= .F.
Local lView			:= .F.
Local lIsBlind		:= IsBlind()
Local oView			:= FwViewActive()
Local lCheckNum		:= .T.
Local lActNum		:= .F.
Local nFJTTamNum	:= Getsx3Cache( "FJT_RECIBO", 'X3_TAMANHO' )
Local lRaGener      := SuperGetMv("MV_RAGENER",.F.,.F.)
local cFJTFil	:= ""

	If nOperation == MODEL_OPERATION_INSERT
		cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
		cRecProv	:= oModelFJT:GetValue("FJT_RECPRV")
		cCobrador	:= oModelFJT:GetValue("FJT_COBRAD")
		cSerie 		:= oModelFJT:GetValue("FJT_SERIE")	
		lValnumr	:= oModelFJT:GetValue("VLDNUMREC")
		self:cDocCred := oModelFJT:GetValue("DOCUMEN")
		self:dDataRef := oModelFJT:GetValue("FJT_EMISSA")

		If lValid .and. Empty(oModelFJT:getValue("FJT_RECIBO"))
			Help( ,, STR0017 ,, STR0030 ,1, 0 )//"Aviso" //"Indique el número de Recibo "
			lValid:= .F. 
		EndIf
		If lValid .and. Empty(oModelFJT:getValue("FJT_CLIENT"))
			Help( " " , 1 , "NUMCLI" ,,, 2 , 0 )
			lValid:= .F.
		endIf
		If lValid .and. Empty(oModelFJT:getValue("FJT_LOJA"))
			Help( " " , 1 , "NUMCLI" ,,, 2 , 0 )
			lValid:= .F.
		endIF
		If lValid .and. !(dtMovFin(self:dDataRef,,"2") )      // Verificar data do recibo com o parametro MV_DATAFIN
			lValid:= .F. 
		EndIf           
		If lValid .and. Empty(self:dDataRef)
			Help( ,,STR0017 ,, STR0031 ,1, 0 )//"Aviso" //"Fecha de emision invalida."
			lValid := .F.
		EndIf

		IF ExistBlock("F998NROK")
			a998ok := ExecBlock("F998NROK",.F.,.F.,{oModel})

			IF !VAZIO(a998ok) .AND. a998ok[1][1] == .F.
				Help(,,"F998NROK","F998NROK",a998ok[1][2], 1, 0, NIL, NIL, NIL, NIL, NIL, {a998ok[1][3]})
				lValid:=.F.
				Return lValid
			ENDIF
		EndIf

		If lValid .And. !Empty(oModelFJT:getValue("FJT_COBRAD"))
			aArea:=GetArea()       
			DbSelectArea("SAQ")
			DbSetOrder(1)
			If dbSeek(xFilial("SAQ")+oModelFJT:getValue("FJT_COBRAD")) 
				ctipo:= SAQ->AQ_TIPOREC // TIPO recibo
				If cTipo<> "3"
					lValid := self:FINCOB(cTipo, cCobrador, cRecProv, cSerie, cRecibo)
				EndIf
		   EndIf	
		   RestArea(aArea)
		EndIf
		
		lDescMoe := oModelMOE:HasField("DESCMOEDA")
		lView := ValType(oView) == "O"
		For nLine := 1 To oModelMOE:Length()
			If lValid .and. oModelMOE:GetValue("SALDO",nLine) < 0 .and. !FwIsInCallStack("getsaveReceiptDetailService")
				cText := STR0032 + Iif(lDescMoe .and. !Empty(oModelMOE:GetValue("DESCMOEDA",nLine)), AllTrim(oModelMOE:GetValue("DESCMOEDA",nLine)), STR0019 + " " + oModelMOE:GetValue("MOEDA",nLine)) + STR0175
				Help( ,,STR0017 ,, cText, 1, 0) //Aviso //Saldo en Moneda # insuficiente para efectuar la baja.
				lValid := .F.
			EndIf
			If lValid .and. oModelMOE:GetValue("SALDO",nLine) > 0 .and. oModelFJT:getValue("GERANCC") <> "S" .AND. ALLTRIM(oModelSEL:GetValue("EL_TIPO")) != 'CO'
				If (lView .Or. lIsBlind) .and. (!self:lCFDI .Or. lRaGener) .and. !FwIsInCallStack("getsaveReceiptDetailService")
					cSaldo += Iif(!Empty(cSaldo), ", ", "") + AllTrim(Str(oModelMOE:GetValue("SALDO",nLine))) + " " + Iif(lDescMoe, AllTrim(oModelMOE:GetValue("DESCMOEDA",nLine)), "")
					Loop
				EndIf
				Help( ,,STR0017 ,, STR0075, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0076}) //Aviso // Existe saldo pendiente. Corrija el saldo o seleccione generar un documento por el saldo.
				lValid := .F.
			EndIf
		Next nLine
	
		nSelLine := oModelSEL:GetLine()
		
		For nLine := 1 To oModelSEL:Length()
			oModelSEL:GoLine(nLine)
			If oModelSEL:IsDeleted() .Or. !oModelSEL:IsUpdated()
				loop
			Endif
			Iif(lValid, lValid := oModelSEL:GetValue("EL_DTVCTO",nLine)>=oModelSEL:GetValue("EL_EMISSAO",nLine),)
			
		
			If lValid
				If oModelSEL:GetValue("EL_TIPODOC",nLine) $ self:cCredInm .and. oModelSEL:GetValue("EL_DTVCTO",nLine) <> oModelFJT:GetValue("FJT_EMISSA")
					Help(" ",1,"BLOQDTVENC")
					lValid := .F.
				EndIf
			EndIf	

			IF lValid
				cBanco		:= oModelSEL:GetValue("EL_BANCO",nLine)
				cAgencia	:= oModelSEL:GetValue("EL_AGENCIA",nLine)
				cNumcon		:= oModelSEL:GetValue("EL_CONTA",nLine)

				SA6->(DbSetOrder(1)) //A6_FILIA+A6_CODE+A6_AGENCIA+A6_NUMCON
				IF SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cNumcon))
					nMoneda := SA6->A6_MOEDA
					FOR nAux := 1 to oModelMOE:Length()
						IF oModelMOE:GetValue("MOEDA",nAux) == CVALTOCHAR(nMoneda) .AND. oModelMOE:GetValue("TASA",nAux) == 0
								Help( ,, STR0017 ,,STR0081 ,1, 0 )   // "Aviso" // "Error en la tasa del banco, verifique la tasa."
							lValid := .F.
						ENDIF
					NEXT
				ENDIF
			ENDIF
			nLineSEL += 1
		Next nLine
		
		oModelSEL:GoLine(nSelLine)

		If lValid  .and.(lView .Or. lIsBlind) .and. !Empty(cSaldo)
			If nLineSEL == 0
				Help( ,, STR0017 ,,STR0230,1, 0 )//"Aviso" //"¡Para compensaciones sin cobro de títulos, el saldo de la operación debe ser cero!"
				lValid := .F.
			EndIF
			If (oModelFJT:getValue("GERANCC") == "A") .Or. (!lIsBlind .and. MsgYesNo( STR0177 + STR0178 + cSaldo +  STR0179))
				oModelFJT:LoadValue("GERANCC", "S")
			Else
				Help( ,,STR0017 ,, STR0075, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0076}) //Aviso // Existe saldo pendiente. Corrija el saldo o seleccione generar un documento por el saldo.
				lValid := .F.
			EndIf
		EndIf
		
		nSe1Line := oModelSE1:GetLine()
		For nLine := 1 To oModelSE1:Length()
			If oModelSE1:IsDeleted(nLine) .Or. oModelSE1:GetValue("BAIXAR", nLine) <= 0
				loop
			EndIf
			nLineSE1 += 1
		Next nLine
		oModelSE1:GoLine(nSe1Line)

		If lValid .and. nLineSEL == 0 .and. nLineSE1 == 0 .and. !FwIsInCallStack("getsaveReceiptDetailService")
			Help( ,, "VACIO" ,"VACIO",STR0176 ,1, 0 ) // "El recibo no puede grabarse vacío"
			lValid := .F.
		EndIf
		If lValid .and. oModelFJT:HasField("TIMBRAR") .and. oModelFJT:GetValue('TIMBRAR') .and. nLineSE1 == 0 
			Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T.)
			If VAZIO(MV_PAR07)
				Help( ,, STR0017 ,,STR0223,1, 0 )// Este es un Recibo Anticipado (RA) y no puede ser timbrado 
				lValid := .F.
			EndIf
		EndIf

		If lValid  .AND. lValnumr
			DbSelectArea("FJT")
			FJT->(DbSetorder(1)) ////FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
			cFJTFil:= xFilial("FJT")
			While lCheckNum
				If FJT->(MsSeek(cFJTFil+cSerie+cRecibo))
					If self:lSerRec .and. self:lRecMVC
						cRecibo := StrZero(Val(cRecibo)+1,nFJTTamNum)	//Aumenta la numeración del recibo.
						lActNum := .T.
					Else
						Help( ,, "FJTNUMEXIS" ,"FJTNUMEXIS",STR0026 ,1, 0 ) // "El Número del Recibo ya Existe "
						lValid := .F.
						lCheckNum := .F.
					EndIf
				Else
					lCheckNum := .F.
				EndIf
			EndDo
			If self:lRecMVC .and. lActNum
				oModelFJT:SetValue("FJT_RECIBO", cRecibo)
				Iif(!lIsBlind, MsgInfo(StrTran(STR0203, "#recibo#", cRecibo), STR0026),) // "El Número del Recibo ya Existe " "Se cambia la numeración del recibo para: #recibo# "				 
			EndIf
		EndIf		
	ELSEIF nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .AND. oModel:getValue('FJT_MASTER', "EDITCH") == .F. )

		aAreaSE := GetArea()
		For nLine := 1 to oModelSEL:Length()
			oModelSEL:GoLine(nLine)
			If oModelSEL:GetValue("EL_PREFIXO") == "REC" .And. oModelSEL:GetValue("EL_TIPODOC") <> "TB"
				DbSelectArea("SE1")
				SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->(MsSeek(xFilial("SE1")+;
					PadR(oModelSEL:GetValue("EL_CLIORIG"),GetSx3Cache("E1_CLIENTE","X3_TAMANHO"))+;
					PadR(oModelSEL:GetValue("EL_LOJORIG"),GetSx3Cache("E1_LOJA","X3_TAMANHO"))+;
					PadR(oModelSEL:GetValue("EL_PREFIXO"),GetSx3Cache("E1_PREFIXO","X3_TAMANHO"))+;
					PadR(oModelSEL:GetValue("EL_NUMERO"),GetSx3Cache("E1_NUM","X3_TAMANHO"))+;
					PadR(oModelSEL:GetValue("EL_PARCELA"),GetSx3Cache("E1_PARCELA","X3_TAMANHO"))+;
					PadR(oModelSEL:GetValue("EL_TIPO"),GetSx3Cache("E1_TIPO","X3_TAMANHO"))))
					If SE1->E1_VALOR <> SE1->E1_SALDO
						Help( ,, STR0017 ,,STR0154,1, 0 )//"Aviso" //"Este recibo por anticipo no puede ser Borrado/Anulado, ya se compenso con otros títulos"
						lValid := .F.
					EndIf
				EndIf
			EndIf

			//Se verifica que el recibo de cobro no posea movimientos bancarios ya conciliados
			If VldConcFK5(oModelSEL:GetValue("EL_PREFIXO"),;
			oModelSEL:GetValue("EL_NUMERO"),;
			oModelSEL:GetValue("EL_PARCELA"),;
			oModelSEL:GetValue("EL_TIPO"),;
			oModelSEL:GetValue("EL_CLIENTE"),;
			oModelSEL:GetValue("EL_LOJA"))
				Help( ,, STR0017 ,,STR0224+oModelSEL:GetValue("EL_RECIBO")+STR0225,1, 0 )//"Aviso" //"El recibo: contiene registros conciliados y no se permite la anulacion o borrado."
				lValid := .F.
				Exit
			EndIf

		Next nLine
		RestArea(aAreaSE)
	EndIf
	
	If Empty(self:cDocCred)
		self:cDocCred	:= IIf(Empty(self:cDocCred) .Or. !(self:cDocCredocCred$MV_CRNEG+"|"+MVRECANT), "NCC", self:cDocCred)
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE
		IF oModel:getValue('FJT_MASTER', "EDITCH")
			lValid := self:F887EDTCH(oModel)
		EndIf
	EndIf

Return lValid

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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887FIN
Local lRet		As Logical
Local cError	As Character
Local cBlockBco As Character
Local nOperation := oSubModel:GetOperation() As Numeric
local nI := 1
Local lBcoVacio As Logical
Local lBchVacio As Logical
Local aArea As Array
Local lFJN As Logical

lRet	:= .T.  
cError	:= ""
lBcoVacio := cModelID == 'SEL_DETAIL' .And. Empty(oSubModel:GetValue("EL_BANCO",nLine) + oSubModel:GetValue("EL_AGENCIA",nLine) + oSubModel:GetValue("EL_CONTA",nLine))
lBchVacio := cModelID == 'SEL_DETAIL' .And. Empty(oSubModel:GetValue("EL_BCOCHQ",nLine) + oSubModel:GetValue("EL_AGECHQ",nLine) + oSubModel:GetValue("EL_CTACHQ",nLine))
aArea     := GetArea() 

	IF cModelID == 'SEL_DETAIL' .AND. (nOperation != MODEL_OPERATION_UPDATE) .AND. (!oSubModel:GetValue("EL_TIPODOC",nLine)$"TB|RA")
		cBlockBco	:= ""	
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		If (AllTrim(oSubModel:GetValue(IIF(self:lCredInm, "EL_TIPO", "EL_TIPODOC"),nLine)) $ self:cCredMed+"/"+self:cCredInm .And. AllTrim(oSubModel:GetValue("EL_TIPODOC",nLine)) != "DC") .Or. !lBcoVacio
			If lBcoVacio .OR. !SA6->(MSSEEK(xFilial("SA6")+oSubModel:GetValue("EL_BANCO",nLine)+oSubModel:GetValue("EL_AGENCIA",nLine)+oSubModel:GetValue("EL_CONTA",nLine)))
				cError := "EL_BANCO ==> " + STR0085 +":"+ STR0086  //Fue imposible encontrar los dados del banco para deposito, Regrese y confirme los dados del banco para deposito 
				Help( ,, "BANCO" ,"EL_BANCO",cError ,nLine, 0 )
				lRet	:=	.F.
			EndIf
		EndIf
		SA6->(dbCloseArea())

		If lRet .And. !lBchVacio
			lFJN := Alltrim(GetSx3Cache("EL_BCOCHQ","X3_F3")) == "FJNCON"
		    IF lFJN
				DbSelectArea("FJN")
				FJN->(DbSetOrder(1))//FJN_FILIAL+FJN_COD+FJN_AGENCI 
				If !FJN->(MsSeek(xFilial("FJN")+oSubModel:GetValue("EL_BCOCHQ",nLine)+oSubModel:GetValue("EL_AGECHQ",nLine)))
					lRet :=	.F.
				EndIf
				FJN->(DbCloseArea())
			Else
				DbSelectArea("SA6")
				SA6->(DbSetOrder(1))// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				If !SA6->(MSSEEK(xFilial("SA6")+oSubModel:GetValue("EL_BCOCHQ",nLine)+oSubModel:GetValue("EL_AGECHQ",nLine)+oSubModel:GetValue("EL_CTACHQ",nLine)))
					lRet :=	.F.
				EndIf
				SA6->(dbCloseArea())
			EndIf

			If !lRet
				cError := "EL_BCOCHQ ==> " + STR0135 +":"+ STR0136  //Fue imposible encontrar los dados del banco cheque, Regrese y confirme los dados del banco cheque
				Help( ,, "BANCO CHEQUE" ,"EL_BCOCHQ",cError ,nLine, 0 )
			EndIf
		EndIf
		If lRet
			cBlockBco := GetAdvFVal("SA6","A6_BLOCKED",xFilial("SA6")+PadR(oSubModel:GetValue("EL_BANCO",nLine),GetSx3Cache("A6_COD","X3_TAMANHO"))+PadR(oSubModel:GetValue("EL_AGENCIA",nLine),GetSx3Cache("A6_AGENCIA","X3_TAMANHO"))+PadR(oSubModel:GetValue("EL_CONTA",nLine),GetSx3Cache("A6_NUMCON","X3_TAMANHO")),1,"")
			If cBlockBco == "1"
				Help(" ",1,"CCBLOCKED")
				lRet :=	.F.
			EndIf
		EndIf
		If lRet .And. self:lCredInm .And. Subs(oSubModel:GetValue("EL_TIPODOC",nLine),1,2) == "DC" //Pagaré
			If !Empty(oSubModel:GetValue("EL_BANCO",nLine)) .And. !(oSubModel:GetValue("EL_BANCO",nLine) $ (GetNewPar("MV_CARTEIR","") + "/" + Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
				Help( " ", 1, "FA840BCO")//"Banco inválido para Pagaré"				
				lRet := .F.
			EndIf
		EndIf
		If lRet .And.Subs(oSubModel:GetValue("EL_TIPODOC",nLine),1,2) $ "CC|CD" .AND. self:lTipodoc //Tarjeta de credito
			If VAZIO(oSubModel:GetValue("EL_ADMIN",nLine))
				cError := "EL_ADMIN ==> " + STR0121 //"No es posible efectuar la baja de los títulos porque no existe una administradora financiera de tarjeta de Crédito / Debito registrada"
				Help( ,, "ADMINISTRADORA" ,"EL_ADMIN",cError ,nLine, 0 )
				lRet	:=	.F.
			ENDIF
		EndIf
		If lRet .And. VAZIO(oSubModel:GetValue("EL_DTVCTO",nLine))  .AND. self:lVldVcto
				cError := "EL_DTVCTO ==> " + STR0127
				Help( ,, STR0128 ,"EL_DTVCTO",cError ,nLine, 0 )
				lRet	:=	.F.
		EndIf
		If lRet
			SE1->(DbSetOrder(1))
			If SE1->(MSSeek(xFilial("SE1")+oSubModel:GetValue("EL_PREFIXO",nLine)+oSubModel:GetValue("EL_NUMERO",nLine)+oSubModel:GetValue("EL_PARCELA",nLine)+Padr(oSubModel:GetValue("EL_TIPODOC",nLine),GetSx3Cache("E1_TIPO","X3_TAMANHO"))))
				Help( " ", 1, "DOCUEXIST",,STR0073+STR0074,1,0)//"El documento de la forma de pago ya existe en otro recibo:" + "Verifique los datos: 'Tipo de valor, Prefijo, Número o Cuota'"
				lRet := .F.
			EndIf
		EndIf
		If lRet
			For nI := 1 to oSubModel:Length()
				IF oSubModel:IsDeleted(nI)
					loop
				EndIf
				If nI != nLine 
					IF oSubModel:GetValue("EL_TIPODOC",nI)+oSubModel:GetValue("EL_PREFIXO",nI)+oSubModel:GetValue("EL_NUMERO",nI)+oSubModel:GetValue("EL_PARCELA",nI)==oSubModel:GetValue("EL_TIPODOC",nLine)+oSubModel:GetValue("EL_PREFIXO",nLine)+oSubModel:GetValue("EL_NUMERO",nLine)+oSubModel:GetValue("EL_PARCELA",nLine)
						Help( " ", 1, "DOCUEXIST",,STR0153 +STR0074,1,0)//""Este Registro ya se incluyó." + "Verifique los datos: 'Tipo de valor, Prefijo, Número o Cuota'"
						lRet := .F.
					Endif
				Endif
			Next nI
		Endif
	ElseIf cModelID == 'SE1_DETAIL' .AND. (nOperation == MODEL_OPERATION_INSERT) 
		If oSubModel:GetValue("CHECK", nLine) .and. oSubModel:GetValue("BAIXAR", nLine) == 0
			Help( " ", 1, "COBRO",,STR0164,1,0) //'Total a cobrar no informado'
			lRet := .F.
		EndIf
		If lRet
			If (oSubModel:HasField("SALDOPE") .and. oSubModel:GetValue("SALDOPE",nLine) < 0) .Or. (oSubModel:GetValue("E1_SALDO",nLine) < Round(oSubModel:GetValue("BAIXAR",nLine), GetSx3Cache("E1_SALDO","X3_DECIMAL")))
				Help( " ", 1, "COBRO",,STR0163,1,0)// 'Valor cobrado no puede ser mayor que saldo pendiente'
				lRet := .F.
			EndIf
		EndIf
		If lRet .and. oSubModel:GetValue("CHECK", nLine) .and. Empty(oSubModel:GetValue("E1_MOTIVO",nLine))
			Help( " ", 1, "MOTIVO",,STR0167,1,0)// 'Motivo de baja no informado'
			lRet := .F.
		EndIf
		If lRet .and. oSubModel:GetValue("BAIXAR", nLine) > 0 .and. Empty(oSubModel:GetValue("E1_MOEDA",nLine))
			Help( " ", 1, "MONEDA",,STR0199,1,0)// 'Moneda del título no informada'
			lRet := .F.
		EndIf
	EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.2.27 / Superior
@since		12/04/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSEL(oModel)
	ElseIf nOperation == MODEL_OPERATION_DELETE 
			self:F887DEL()
	EndIf     	

Return

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/04/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	ELSEIF nOperation == MODEL_OPERATION_UPDATE 
		Begin Transaction
		IF !oModel:getValue('FJT_MASTER', "EDITCH")
			self:F887CAN()
		ENDIF	
		End Transaction
	ENDIF

Return Nil


/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio genericas 
después de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		24/05/2021 
/*/
Method AfterTTS(oModel, cModelId) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local nTamRec		:= GetSx3Cache("EL_RECIBO","X3_TAMANHO")
Local cSubRutina:= ""
Local cRecSx5 		:= "" 

	If nOperation == MODEL_OPERATION_INSERT
		If !self:lSerRec
			If __lSX8
				While ( GetSX8Len() > self:nSaveSx8 )
					ConfirmSX8()
				End
			Endif
		Else
			cRecSx5 := StrZero((Val(cRecibo)+1),nTamRec)
			FwPutSX5(, "RN", cSerie, cRecSx5, cRecSx5, cRecSx5, cRecSx5)
		EndIf
		IF ExistBlock("F998NRG2")
			ExecBlock('F998NRG2',.F.,.F.,{oModel})	
		ENDIF
		self:ImpEnvRec(oModel)	
	EndIf
	IF nOperation == MODEL_OPERATION_DELETE 
		SEL->(DbSetOrder(8))
		If !(SEL->(MSSeek(xFilial("SEL")+cSerie+cRecibo)))
			If VldLibMet()	//Valida la fecha de la LIB para utilizacion en Telemetria
				// Metrica de control Recibos Borrados exitosamente.
				cSubRutina := "RECIBO_BORR_FINA998_"+Upper(cPaisloc)
				FwCustomMetrics():setSumMetric(cSubRutina, "financiero-protheus_cantidad-de-anulados-recibo-de-cobro-por-pais-total", 1, /*dDatabase*/, /*nLapTime*/, "FINA887")
			EndIf
		EndIf
	EndIf


Return Nil

/*/{Protheus.doc} FINUPDSEL
Metodo responsable por realizar el tratamiento de la tabla SEL

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados SEL.
@param 		nLin	 ,numerico	,linea procesada del modelo SEL.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSEL(oModel, nLin) Class F887FIN
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelFAC 	:= oModel:GetModel('FAC_DETAIL')
Local oModelCOM     := oModel:GetModel('COM_DETAIL')

Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local cNatureza		:= oModelFJT:GetValue('FJT_NATURE')
Local cRecProv		:= ALLTRIM(oModelFJT:GetValue("FJT_RECPRV"))
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local cLojOri		:= oModelFJT:GetValue("FJT_LOJA")
Local cCobrador		:= oModelFJT:GetValue("FJT_COBRAD")
Local nValMoe1		:= 0
Local nTaxa			:= 1
Local nX			:= 0
Local nI			:= 0
Local nSelLine		:= 0
Local lFactor	 	:= SEL->(ColumnPos("EL_FACTOR")) > 0
Local lGencdf		:= SEL->(ColumnPos("EL_GENCFD")) > 0
Local cSerSus       := ""
Local cRecSus       := ""
Local nDocum		:= 0
Local nValBaixa     := 0
Local cMonedaB		:= ""
Local nQtMoedas		:= Moedfin()
Local nValMoe		:= 0
Local cMoneda       := ""
Local nMoneda		:= 0
Local nTasa 		:= 0
Local lRecMvc 		:= SuperGetMv("MV_RECMVC",.F.,.F.)
Local nValue		:= 0

	For nX := 1 To oModelSEL:Length()
		oModelSEL:GoLine(nX)
		IF oModelSEL:GetValue("EL_VALOR") == 0 //Funciona para eliminar las lineas insertadas de manera nativa a la tabla SEL (Formas de pago) , en donde se valida que el valor sea igual a cero.
			oModelSEL:DeleteLine()
		ENDIF
	Next nX

	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0 .and. oModelSE1:GetValue("BAIXAR", nX) > 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			If self:lRecSus
				cSerSus:= oModelSEL:GetValue("EL_SERSUS",1)
				cRecSus:= oModelSEL:GetValue("EL_RECSUS",1)
			Endif
			If oModelSEL:Length() > 1 .Or. (oModelSEL:Length() == 1 .and. !Empty(oModelSEL:GetValue("EL_NUMERO")) .and. !Empty(oModelSEL:GetValue("EL_TIPO"))) .Or. oModelSEL:IsDeleted()
				oModelSEL:LVALID := .T.				
				oModelSEL:AddLine()
			EndIf

			If lRecMvc
				nValBaixa := 0
				cMoneda	:= Str(oModelSE1:GetValue("E1_MOEDA",nX),IIf(oModelSE1:GetValue("E1_MOEDA",nX) <= 9,1,2))
				nMoneda := Val(cMoneda)
				nTasa := F887GtTaxM(oModel, cMoneda)

				For nI := 1 To nQtMoedas
					cMonedaB := Str(nI,IIf(nI <= 9,1,2))
					If oModelSE1:HasField("BAIXAR" + cMonedaB)
						nValMoe := oModelSE1:GetValue("BAIXAR" + cMonedaB,nX)
						If nValMoe > 0
							If cMoneda == cMonedaB
								nValBaixa += nValMoe
							Else
								nTasaB	:= F887GtTaxM(oModel, cMonedaB)
								nValBaixa += xMoeda(nValMoe, nI, nMoneda, dDataBase, 10, nTasaB, nTasa)
							EndIf
						EndIf
					EndIf
				Next nI
			EndIf

			oModelSEL:loadValue("EL_FILIAL"	, xFilial("SEL"))
			oModelSEL:loadValue("EL_TIPODOC", "TB")
			oModelSEL:loadValue("EL_PREFIXO", SE1->E1_PREFIXO)
			oModelSEL:loadValue("EL_NUMERO"	, SE1->E1_NUM)
			oModelSEL:loadValue("EL_PARCELA", SE1->E1_PARCELA)
			oModelSEL:loadValue("EL_TIPO"	, SE1->E1_TIPO)
			oModelSEL:loadValue("EL_BCOCHQ"	, SE1->E1_BCOCHQ)
			oModelSEL:loadValue("EL_AGECHQ"	, SE1->E1_AGECHQ)
			oModelSEL:loadValue("EL_CTACHQ"	, SE1->E1_CTACHQ)
			oModelSEL:loadValue("EL_EMISSAO", SE1->E1_EMISSAO)
			oModelSEL:loadValue("EL_DTDIGIT", dDataBase)
			oModelSEL:loadValue("EL_DTVCTO"	, SE1->E1_VENCREA)
			oModelSEL:loadValue("EL_NATUREZ", SE1->E1_NATUREZ)
			oModelSEL:loadValue("EL_MOEDA"	, STRZERO(SE1->E1_MOEDA,2))			
			oModelSEL:loadValue("EL_DESCONT", oModelSE1:GetValue("E1_DESCONT", nX))
			oModelSEL:loadValue("EL_MULTA"	, oModelSE1:GetValue("E1_MULTA", nX))
			oModelSEL:loadValue("EL_JUROS"	, oModelSE1:GetValue("E1_JUROS", nX))
			oModelSEL:loadValue("EL_VALOR" 	, IIF(lRecMvc, nValBaixa, oModelSE1:GetValue("BAIXAR", nX) - oModelSE1:GetValue("E1_DESCONT", nX) + oModelSE1:GetValue("E1_JUROS", nX) + oModelSE1:GetValue("E1_MULTA", nX)))
			oModelSEL:loadValue("EL_CLIENTE", cCliOri)
			oModelSEL:loadValue("EL_LOJA"	, cLojOri)
			oModelSEL:loadValue("EL_VERSAO"	, "00")
			oModelSEL:loadValue("EL_CLIORIG", SE1->E1_CLIENTE)
			oModelSEL:loadValue("EL_LOJORIG", SE1->E1_LOJA)

			IF lFactor
				If lRecMvc .And. oModelCOM <> Nil
					nValue := 0
					For nI := 1 To oModelCOM:Length()
						oModelCOM:GoLine(nI)
						If !oModelCOM:IsDeleted() .And. Alltrim(oModelCOM:GetValue("LLAVE")) == Alltrim(SE1->E1_NUM+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_PARCELA)
							nValue += oModelCOM:GetValue("VALUE")
						EndIf
					Next
					If nValue > 0
						oModelFAC:SetValue("FACTOR", "1") 
						oModelSEL:loadValue("EL_FACTOR", "1")
						oModelSEL:loadValue("EL_COMPEN", nValue)
					EndIf
				Else
					oModelSEL:loadValue("EL_FACTOR", oModelFAC:GetValue("FACTOR"))
					oModelSEL:loadValue("EL_COMPEN", oModelFAC:GetValue("VALUE"))
				EndIf
			EndIf

			IF lGencdf
				IF lRecMvc
					oModelSEL:loadValue("EL_GENCFD",IIF(self:GetEvent("F887FIN"):lCompen,"N",""))	
				ELSE
					oModelSEL:loadValue("EL_GENCFD",  oModelSE1:GetValue("GENCFD", nX))
				ENDIF
			ENDIF
			If self:lRecSus
				oModelSEL:loadValue("EL_SERSUS", cSerSus)
				oModelSEL:loadValue("EL_RECSUS", cRecSus)
			Endif
			nDocum++
		EndIf
	Next nX
	
	
	nSelLine := oModelSEL:GetLine()
	
	//Actualización de tasas y datos
	For nX := 1 To oModelSEL:Length()
	
		oModelSEL:GoLine(nX)
		// Gravar Taxa
		FINGRVTAX(oModelMOE, @oModelSEL)
			
		nTaxa 	 := oModelMOE:GetValue("TASA", Val(oModelSEL:GetValue('EL_MOEDA')))
		nValMoe1 := Round( oModelSEL:GetValue('EL_VALOR') * nTaxa, MsDecimais(1) )
		oModelSEL:loadValue("EL_VLMOED1", nValMoe1)
		
		
		If oModelSEL:GetValue("EL_TIPODOC",nX) <> "TB" 
			oModelSEL:loadValue("EL_NATUREZ", ALLTRIM(cNatureza)) 
			//Reemplazo del cliente por la caja financiera cuando es un documento tipo CD
			IF ALLTRIM(oModelSEL:GetValue("EL_TIPODOC",nX)) $ 'CC|CD' .AND. !Empty(oModelSEL:GetValue("EL_ADMIN",nX))
				oModelSEL:loadValue("EL_CLIENTE", getClienteSAE(oModelSEL:GetValue("EL_ADMIN",nX)))
			ELSE
				oModelSEL:loadValue("EL_CLIENTE", cCliOri)
			ENDIF
			oModelSEL:loadValue("EL_LOJA"	, cLojOri)
			oModelSEL:loadValue("EL_CLIORIG", cCliOri)
			oModelSEL:loadValue("EL_LOJORIG", cLojOri)
			IF lGencdf .And. nDocum == 0 
				oModelSEL:loadValue("EL_GENCFD", 'N')
			ENDIF
		EndIf
		oModelSEL:loadValue("EL_SERIE"	, cSerie)
		oModelSEL:loadValue("EL_RECIBO"	, cRecibo)
		oModelSEL:loadValue("EL_COBRAD"	, cCobrador)
		oModelSEL:loadValue("EL_RECPROV", cRecProv)
		
		
	Next nX
	oModelSEL:GoLine(nSelLine)

Return Nil

/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/05/2021 
/*/
Method FINUPDSE(oModel) Class F887FIN
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
//SE1
Local cSerie		:= oModelFJT:GetValue('FJT_SERIE')
Local cRecibo		:= oModelFJT:GetValue('FJT_RECIBO')
Local cNatureza		:= oModelFJT:GetValue('FJT_NATURE')
Local cRecProv		:= oModelFJT:GetValue("FJT_RECPRV")
Local cCliOri 		:= oModelFJT:GetValue('FJT_CLIENT')
Local cLojOri		:= oModelFJT:GetValue("FJT_LOJA")
Local cCobrador		:= oModelFJT:GetValue("FJT_COBRAD")
Local cGeraNCC		:= oModelFJT:GetValue("GERANCC")
Local cDiario 		:= ""
Local cTpCred		:= ""
Local cTpDoc		:= ""
Local cTipo			:= ""
Local aRecnoITF  	:= {}

Local nPosSEL		:= 0
Local nSelLine		:= 0


Local cIDProc		:= FINFKSID('FKA','FKA_IDPROC')
Local oEventFin 	:= self:GetEvent("F887FIN")

	SA1->(msSeek( xFilial("SA1") +cCliOri+ cLojOri)) //Posicionamiento para rutinas externas
	
	For nX := 1 To oModelSEL:Length()
		cTpCred	:= oModelSEL:GetValue("EL_TPCRED",nX)
		cTipo	:= oModelSEL:GetValue("EL_TIPO",nX)
		cTpDoc	:= oModelSEL:GetValue("EL_TIPODOC",nX)
		cDiario	:= oModelSEL:GetValue("EL_DIACTB",nX)

		If (!self:lProcede .And. cTpDoc == "TB" .And. Alltrim(cTipo) $ "CC|CD") .Or. (cTpCred $ "1|2" .AND. cTpDoc == "TB") .Or. oModelSEL:IsDeleted(nX)
			Loop
		EndIf
		
		If Iif(self:lDocTran, cTipo $ self:cCredMed .and. oModelSEL:GetValue("EL_TRANSIT",nX) == "2", AllTrim(cTpDoc) $ self:cCredMed)
			self:FINCREDMED(oModelSEL, oModelMOE, nX, cSerie, cRecibo, cTpCred, self:cCredInm, .T., self:lCredInm, .T. , self:lProcede)
			self:FINUPDSEA(oModelSEL, nX)
			If !(cTpCred $ "1|2")
				AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue("TASA",SE1->E1_MOEDA),SE1->E1_EMISSAO)
			EndIf
		EndIf
		
		If Iif(self:lDocTran, cTipo $ self:cCredInm .and. oModelSEL:GetValue("EL_TRANSIT",nX) == "2", cTpCred $ "1|2" .or. AllTrim(cTpDoc) $ self:cCredInm) 
				If !self:FINGrvSE5(2,cTpCred,cNatureza,cRecibo,cSerie,cDiario,,cIDProc,oModelFJT,oModelSEL,oModelSE1,oModelMOE, .T.,nX, .F., self:lVlCorre) 
					DisarmTransaction()
				Return .F.
			EndIf
			
			If FinProcITF( SE5->(Recno()),1,,,,,cNatureza ) .AND. self:F887CkPG(3,self:lValidITF,oModelSEL:GetValue("EL_BANCO",nX))
				FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,,,cNatureza,@aRecnoITF)
			EndIf
		EndIf
		
		If !Empty(cCobrador)
			self:FINCOM(oModelSEL,nX)
		EndIf	 
	Next nX

	For nX := 1 To oModelSE1:Length()   
		If oModelSE1:GetValue("RECNO",nX) <> 0 .and. oModelSE1:GetValue("BAIXAR", nX) > 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			RecLock("SE1",.F.)
				SE1->E1_BAIXA 	:=	self:dDataRef
				SE1->E1_MOTIVO	:=	oModelSE1:GetValue("E1_MOTIVO", nX)
				SE1->E1_MOVIMEN	:=	self:dDataRef 
				SE1->E1_SALDO	:=	SE1->E1_SALDO - oModelSE1:GetValue("BAIXAR", nX)
				SE1->E1_DESCONT	:=	oModelSE1:GetValue("E1_DESCONT", nX)
				SE1->E1_MULTA	:= 	oModelSE1:GetValue("E1_MULTA", nX)
				SE1->E1_JUROS	:= 	oModelSE1:GetValue("E1_JUROS", nX)
				SE1->E1_VALLIQ	:=	oModelSE1:GetValue("BAIXAR", nX) - oModelSE1:GetValue("E1_DESCONT", nX) + oModelSE1:GetValue("E1_JUROS", nX) + oModelSE1:GetValue("E1_MULTA", nX) 
				SE1->E1_SERREC  :=	cSerie
				SE1->E1_RECIBO	:=	cRecibo
				SE1->E1_DTACRED	:=	self:dDataRef
				SE1->E1_STATUS	:= 	IF(SE1->E1_SALDO<=0,"B","A")
				If SE1->(ColumnPos("E1_XPERDES")) .and. SuperGetMv("MV_RECMVC",.F.,.F.)
					SE1->E1_XPERDES	:=	oModelSE1:GetValue("E1_XPERDES", nX)
				EndIf
				If ExistBlock('F998GSE1')
					ExecBLock('F998GSE1',.F.,.F.)
				Endif
			MsUnlock()
			If !self:FINGrvSE5(1,,,cRecibo,cSerie,,,cIDProc,oModelFJT,oModelSEL,oModelSE1,oModelMOE, .T., nX, .F., self:lVlCorre)
				DisarmTransaction()
				Return .F.
			EndIf
		EndIf
	Next nX
	
	If cGeraNCC == "S"
		self:FINGERNCC(cRecibo, cSerie, cCliOri, cLojOri, cCobrador, cRecProv, cCliOri, cLojOri, oEventFin:cDocCred, cNatureza, self:lRoundVal, .F. ,oModelSEL, oModelMOE)
	EndIf
	
	IF self:nRecnoSEY>0
		SEY->(dbGoto(self:nRecnoSEY))
		RecLock("SEY")
		SEY->EY_RECPEND:=SEY->EY_RECPEND -1
		IF SEY->EY_RECPEND<=0
  			SEY->EY_STATUS:="2"
 		ENDIF
		SEY->(MsUnlock())
	ENDIF

Return Nil


/*/{Protheus.doc} FINUPDSE1
Metodo responsable por realizar el tratamiento de la tabla SE!

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados SEL.
@param 		cSerie	 ,caracter	,serie del recibo
@param 		cRecibo	 ,caracter	,numero de recibo
@param 		nLine	 ,numerico	,linea procesada del modelo SE1.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSE1(oModelSE1, cSerie, cRecibo, nLine) Class F887FIN

		SE1->E1_BAIXA 	:=	self:dDataRef
		SE1->E1_MOTIVO	:=	oModelSE1:GetValue("E1_MOTBX",nX)
		SE1->E1_MOVIMEN	:=	self:dDataRef 
		SE1->E1_SALDO	:=	SE1->E1_SALDO - oModelSE1:GetValue("BAIXAR",nLine)
		SE1->E1_DESCONT	:=	oModelSE1:GetValue("E1_DESCONT",nLine)
		SE1->E1_MULTA	:= 	oModelSE1:GetValue("E1_MULTA",	nLine)
		SE1->E1_JUROS	:= 	oModelSE1:GetValue("E1_JUROS",	nLine)
		SE1->E1_VALLIQ	:=	oModelSE1:GetValue("BAIXAR",nLine) - oModelSE1:GetValue("E1_DESCONT",nLine) + oModelSE1:GetValue("E1_JUROS",	nLine) + oModelSE1:GetValue("E1_MULTA",	nLine) 
		SE1->E1_SERREC  :=	cSerie
		SE1->E1_RECIBO	:=	cRecibo
		SE1->E1_DTACRED	:=	self:dDataRef
		SE1->E1_STATUS	:= 	IF(SE1->E1_SALDO<=0,"B","A")

Return Nil

/*/{Protheus.doc} FINCREDMED
Metodo responsable por realizar el tratamiento para documentos
de credito med

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.
@param 		nPosLine 	,numerico	,linea procesada del modelo SEL.
@param 		cSerie	 	,caracter	,serie del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cTipoCred	,caracter	,tipo de credito
@param 		cCredInm	,caracter	,documentos de credito inmediato
@param 		lCred		,logico		,indica si realiza tratamiento para credito med
@param 		lCredIm		,logico 	,indica si realiza tratamiento para credito inmediato
@param 		lMsUnLock	,logico 	,indica si se realiza el msunlook

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/

Method FINCREDMED(oModelSEL, oModelMOE, nPosLine, cSerie, cRecibo, cTipoCred, cCredInm, lCred, lCredIm ,lMsUnLock,lProcede) Class F887FIN

Local nDias		:= 0
Local dBase
Local aFeriados := {}

Default cSerie 		:= ""
Default cRecibo 	:= ""
Default cTipoCred 	:= ""
Default cCredInm 	:= ""
Default lCred		:= .T.
Default lCredIm		:= .F.
Default lMsUnLock	:= .T.

	SE1->(DbSetOrder(2)) // 
	If SE1->(DbSeek(xFilial("SE1")+oModelSEL:GetValue("EL_CLIENTE",nPosLine)+oModelSEL:GetValue("EL_LOJA",nPosLine)+oModelSEL:GetValue("EL_PREFIXO",nPosLine)+oModelSEL:GetValue("EL_NUMERO",nPosLine)+;
		oModelSEL:GetValue("EL_PARCELA",nPosLine)+oModelSEL:GetValue("EL_TIPODOC",nPosLine)))
		RecLock("SE1",.F.)
	Else
		RecLock("SE1",.T.)
	Endif
	
	SE1->E1_FILIAL := xFilial("SE1")
	SE1->E1_FILORIG:= cFilant
	SE1->E1_SERREC := oModelSEL:GetValue("EL_SERIE",nPosLine)
	SE1->E1_RECIBO := oModelSEL:GetValue("EL_RECIBO",nPosLine)
	SE1->E1_PREFIXO:= oModelSEL:GetValue("EL_PREFIXO",nPosLine)
	SE1->E1_NUM    := oModelSEL:GetValue("EL_NUMERO",nPosLine)
	SE1->E1_PARCELA:= oModelSEL:GetValue("EL_PARCELA",nPosLine)
	SE1->E1_TIPO   := oModelSEL:GetValue("EL_TIPODOC",nPosLine)          // ALTERADO oModelSEL:GetValue("",nPosLine)EL_TIPODOC (conteudo do FJS_TIPOIN  
	SE1->E1_PORTADO:= oModelSEL:GetValue("EL_BANCO",nPosLine)
	SE1->E1_AGEDEP := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
	SE1->E1_CONTA  := oModelSEL:GetValue("EL_CONTA",nPosLine)
	SE1->E1_BCOCHQ := oModelSEL:GetValue("EL_BCOCHQ",nPosLine)
	SE1->E1_AGECHQ := oModelSEL:GetValue("EL_AGECHQ",nPosLine)
	SE1->E1_CTACHQ := oModelSEL:GetValue("EL_CTACHQ",nPosLine)
	SE1->E1_EMISSAO:= oModelSEL:GetValue("EL_EMISSAO",nPosLine)   //dDataRef
	SE1->E1_EMIS1  := CtoD("")
	SE1->E1_VENCREA:= DATAVALIDA(oModelSEL:GetValue("EL_DTVCTO",nPosLine))
	SE1->E1_VENCTO := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
	SE1->E1_VENCORI:= oModelSEL:GetValue("EL_DTVCTO",nPosLine)
	SE1->E1_NATUREZ:= oModelSEL:GetValue("EL_NATUREZ",nPosLine)
	SE1->E1_MOEDA  := Val(oModelSEL:GetValue("EL_MOEDA",nPosLine))
	SE1->E1_CLIENTE:= oModelSEL:GetValue("EL_CLIENTE",nPosLine)
	SE1->E1_LOJA   := oModelSEL:GetValue("EL_LOJA",nPosLine)
	SE1->E1_VALOR  := oModelSEL:GetValue("EL_VALOR",nPosLine)
	SE1->E1_SALDO  := oModelSEL:GetValue("EL_VALOR",nPosLine)
	IF(self:lPostal)
		SE1->E1_POSTAL := oModelSEL:GetValue("EL_POSTAL",nPosLine)
	ENDIF
	
	SE1->E1_VLCRUZ := oModelSEL:GetValue("EL_VALOR",nPosLine)*oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	SE1->E1_NOMCLI := GetAdvFVal("SA1","A1_NREDUZ",xFilial("SA1")+PadR(oModelSEL:GetValue("EL_CLIENTE",nPosLine),GetSx3Cache("A1_COD","X3_TAMANHO"))+PadR(oModelSEL:GetValue("EL_LOJA",nPosLine),GetSx3Cache("A1_LOJA","X3_TAMANHO")),1,"")
	SE1->E1_EMIS1  := dDataBase
	SE1->E1_TXMOEDA:= oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	If lCred .and. (cTipoCred $ "1|2" .Or. ( lCredIm .and. oModelSEL:GetValue("EL_TIPO",nPosLine) $ cCredInm))  .and. lProcede //Cheques vindos de credito imediato devem entrar como baixados
		SE1->E1_BAIXA		:=If(cTipoCred == "1",dDatabase,DataValida(oModelSEL:GetValue("EL_DTVCTO",nPosLine)))
		SE1->E1_LA			:='S'
		SE1->E1_MOTIVO  	:=""
		SE1->E1_MOVIMEN     :=SE1->E1_BAIXA
		SE1->E1_SALDO       :=0
		SE1->E1_DESCONT     :=0
		SE1->E1_MULTA       :=0
		SE1->E1_JUROS       :=0
		SE1->E1_VALLIQ      := oModelSEL:GetValue("EL_VALOR",nPosLine)
		SE1->E1_SERREC      := cSerie
		SE1->E1_RECIBO      := cRecibo
		SE1->E1_DTACRED     := SE1->E1_BAIXA
	EndIf
	
	//+--------------------------------------------------------------------------------+
	//¦Si no se ingreso el banco o se ingreso en una caja, SITUACA es 0 (en cartera)   ¦
	//+--------------------------------------------------------------------------------+
	If (Empty(oModelSEL:GetValue("EL_BANCO",nPosLine)).And.Empty(oModelSEL:GetValue("EL_CONTA",nPosLine)).And.Empty(oModelSEL:GetValue("EL_AGENCIA",nPosLine))).Or.;
		(oModelSEL:GetValue("EL_BANCO",nPosLine) $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),GetSx3Cache("A6_COD","X3_TAMANHO"))))
		SE1->E1_SITUACA:= "0"
	ElseIf oModelSEL:GetValue("EL_BANCO",nPosLine) $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),GetSx3Cache("A6_COD","X3_TAMANHO")))
		SE1->E1_SITUACA:= "0"
	elseif  self:lSituaca 
		SE1->E1_SITUACA:= "0" 
	Else
		SE1->E1_SITUACA:= "1" //840 - 0; 087a - 1
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo para o tempo de Clearing, o tempo de Clearing esta³
	//³sendo calculado somente com dias uteis corridos.          ³
	//³Se o Tempo for de mais de uma semana, coloco uma data de  ³
	//³aqui a dez anos assim tem que ser acreditado manualmente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If cTipoCred == "1"
		SE1->E1_DTACRED:=dDatabase
	ElseIf cTipoCred == "2"
		SE1->E1_DTACRED:=DataValida(oModelSEL:GetValue("EL_DTVCTO",nPosLine))
	ElseIf cTipoCred == "3"
		nDias:=Val(oModelSEL:GetValue("EL_ACREBAN",nPosLine))
		dBase:=  SE1->E1_VENCREA
		If nDias > 5
			dBase += 3650
		Else
			aFeriados:=RetFeriados()
			While nDias > 0
				dBase++
				If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
					nDias--
				EndIf
			EndDo
		Endif
		SE1->E1_DTACRED:= dBase
	EndIf
	
	SE1->E1_ORIGEM := "FINA887"
	
	SE1->E1_VLCRUZ := oModelSEL:GetValue("EL_VLMOED1",nPosLine)
	SE1->E1_LA     := "S"
	SE1->E1_STATUS := IF(SE1->E1_SALDO<=0,"B","A")
	SE1->E1_MOVIMEN:= SE1->E1_DTACRED
		      
	MsUnLock()
	FKCOMMIT()

Return Nil

/*/{Protheus.doc} FINUPDSEA
Metodo responsable por realizar el tratamiento de la tabla SEA

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		nPosLine 	,numerico	,linea procesada del modelo SE1.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSEA(oModelSEL, nPosLine) Class F887FIN


	If SE1->E1_SITUACA=="1"
		SEA->(DbSetOrder(1))
		If SEA->(DbSeek(xFilial("SEA")+oModelSEL:GetValue("EL_PREFIXO",nPosLine)+oModelSEL:GetValue("EL_NUMERO",nPosLine)+oModelSEL:GetValue("EL_PARCELA",nPosLine)))
			RecLock("SEA",.F.)
			SEA->EA_DATABOR := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
			SEA->EA_PORTADO := oModelSEL:GetValue("EL_BANCO",nPosLine)
			SEA->EA_AGEDEP  := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
			SEA->EA_NUMCON  := oModelSEL:GetValue("EL_CONTA",nPosLine)
			SEA->EA_TIPO    := oModelSEL:GetValue("EL_TIPODOC",nPosLine)
			SEA->EA_CART    := "R"
			SEA->EA_SITUACA := "1"
			SEA->EA_FILORIG := SE1->E1_FILIAL
			SEA->(MsUnlock())
			FKCOMMIT()
		Else
			If ! Empty(oModelSEL:GetValue("EL_BANCO",nPosLine))
				RecLock("SEA",.T.)
				SEA->EA_FILIAL  := xFilial("SEA")
				SEA->EA_DATABOR := oModelSEL:GetValue("EL_DTVCTO",nPosLine)
				SEA->EA_PORTADO := oModelSEL:GetValue("EL_BANCO",nPosLine)
				SEA->EA_AGEDEP  := oModelSEL:GetValue("EL_AGENCIA",nPosLine)
				SEA->EA_NUMCON  := oModelSEL:GetValue("EL_CONTA",nPosLine)
				SEA->EA_NUM     := oModelSEL:GetValue("EL_NUMERO",nPosLine)
				SEA->EA_PARCELA := oModelSEL:GetValue("EL_PARCELA",nPosLine)
				SEA->EA_PREFIXO := oModelSEL:GetValue("EL_PREFIXO",nPosLine)
				SEA->EA_TIPO    := oModelSEL:GetValue("EL_TIPODOC",nPosLine)
				SEA->EA_CART    := "R"
				SEA->EA_SITUACA := "1"
				SEA->EA_FILORIG := SE1->E1_FILIAL
				SEA->(MsUnlock())
				FKCOMMIT()
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} FINGRVTAX
Metodo responsable por realizar el tratamiento de informar las tasas.

@type 		Method

@param 		oModelMOE	,objeto		,Modelo de dados de monedas y saldos.
@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		lTab	 	,logico 	,indica si actualiza tabla o modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Function FINGRVTAX(oModelMOE, oModelSEL, lTab)
Local nTx		:= 0
Local nMoeda	:= 0
Local cCpoMoe	:= ""
Local cCpoSEL	:= ""

Default lTab	:= .F.

	For nTx	:= 1 To oModelMOE:Length()
		cCpoMoe	:= oModelMOE:GetValue('MOEDA',nTx)
		nMoeda	:= Val(cCpoMoe)
		cCpoSEL	:= "EL_TXMOE"+StrZero(nMoeda,2)
		If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == cCpoSEL})
			If lTab
				SEL->&(cCpoSEL) := oModelMOE:GetValue('TASA',nTx)
			Else
				oModelSEL:loadValue(cCpoSEL, oModelMOE:GetValue('TASA',nTx))
			EndIf
		EndIf
	Next nTx

Return Nil

/*/{Protheus.doc} FINGERNCC
Metodo responsable por realizar el tratamiento de documentos 
por credito (RA, NCC)


@type 		Method

@param 		cSerie	 	,caracter	,serie del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cCliente 	,caracter	,cliente del recibo
@param 		cLoja	 	,caracter	,loja del cliente
@param 		cCobrador 	,caracter	,cobrador usado en el recibo
@param 		cRecProv 	,caracter	,recibo provisional
@param 		cCliOri 	,caracter	,cliente del recibo
@param 		cLojOri	 	,caracter	,loja del cliente
@param 		cDocCred	,caracter	,documento usado para el credito
@param 		cNatureza	,caracter	,naturaliza usada en el recibo
@param 		lRoundVal	,logico		,indica si realiza tratamiento de redondeo.
@param 		lValImp		,logico 	,indica si usa impuestos para el valor del titulo
@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.

@author 	raul.medina
@version	12.1.27 / Superior
@since		21/04/2021 
/*/
Method FINGERNCC(cRecibo, cSerie, cCliente, cLoja, cCobrador, cRecProv, cCliOri, cLojOri, cDocCred, cNatureza, lRoundVal, lValImp ,oModelSEL, oModelMOE) Class F887FIN
Local cParc		:= " "
Local nValMoed	:= 0
Local cNomCli	:= GetAdvFVal("SA1","A1_NREDUZ",xFilial("SA1")+PadR(cCliente,GetSx3Cache("A1_COD","X3_TAMANHO"))+PadR(cLoja,GetSx3Cache("A1_LOJA","X3_TAMANHO")),1,"")
Local cA1NAtureza	:= ""
Default lValImp		:= .F.
Default lRoundVal	:= .F.

	
	While SE1->(DbSeek(xFilial("SE1")+"REC"+Padr(cRecibo,GetSx3Cache("E1_NUM","X3_TAMANHO")," ")+Padr(cParc,GetSx3Cache("E1_PARCELA","X3_TAMANHO")," ")+cDocCred))
		cParc:=Soma1(cParc)
	Enddo
	DbSelectArea("SA1")
	SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))  // Posiciona SA1
	cA1Natureza := SA1->A1_NATUREZ
	SA1->(dbCloseArea())
		
	For nValMoed := 1 To oModelMOE:Length()
		If !lValImp
			nVlrTit	:= oModelMOE:GetValue("SALDO", nValMoed)
		EndIf
		
		If nVlrTit > 0
			RecLock("SEL",.T.)
				SEL->EL_FILIAL		:= xFilial("SEL")
				SEL->EL_TIPODOC 	:= "RA"
				SEL->EL_PREFIXO  	:= "REC"
				SEL->EL_NUMERO   	:= cRecibo
				SEL->EL_PARCELA  	:= cParc
				SEL->EL_TIPO   	 	:= cDocCred
				SEL->EL_EMISSAO  	:= self:dDataRef
				SEL->EL_DTDIGIT		:= dDataBase
				SEL->EL_DTVCTO   	:= self:dDataRef
				IF Empty(cNatureza)
					SEL->EL_NATUREZ  	:= Iif( Empty(cA1Natureza), &(GetMv("MV_1DUPNAT")) , cA1Natureza )
				ELSE 
					SEL->EL_NATUREZ  	:= cNatureza
				ENDIF   
				SEL->EL_MOEDA    	:= StrZero(nValMoed,2)//Aqui representa qual e a moeda
				SEL->EL_VLMOED1  	:= Round( nVlrTit*oModelMOE:GetValue("TASA", nValMoed), MsDecimais(1))
				SEL->EL_VALOR    	:= nVlrTit
				SEL->EL_CLIENTE  	:= cCliente
				SEL->EL_LOJA	 	:= cLoja
				SEL->EL_SERIE 	 	:= cSerie
				SEL->EL_RECIBO 	 	:= cRecibo
				SEL->EL_COBRAD		:= cCobrador
				SEL->EL_RECPROV		:= cRecProv
				SEL->EL_CLIORIG		:= cCliOri
				SEL->EL_LOJORIG		:= cLojOri
				SEL->EL_VERSAO		:= "00"
				
				FINGRVTAX(oModelMOE, @oModelSEL,.T.)
	
			SEL->(MsUnlock())
			
			RecLock("SE1",.T.)
				SE1->E1_FILIAL   	:= xFILIAL("SE1")
				SE1->E1_FILORIG     := cFilant
				SE1->E1_PREFIXO  	:= "REC"
				SE1->E1_NUM			:= cRecibo
				SE1->E1_PARCELA		:= cParc
				SE1->E1_TIPO     	:= cDocCred  // correto grava o tipo do SX1 
				SE1->E1_EMISSAO  	:= self:dDataRef
				SE1->E1_EMIS1    	:= dDataBase
				SE1->E1_VENCTO  	:= self:dDataRef
				SE1->E1_VENCREA 	:= DataValida(self:dDataRef)
				SE1->E1_NATUREZ  	:= SEL->EL_NATUREZ
				SE1->E1_MOEDA   	:= nValMoed
				If lRoundVal
					SE1->E1_VLCRUZ	:= Round( nVlrTit * oModelMOE:GetValue("TASA", nValMoed), MsDecimais(1) )
				Else
					SE1->E1_VLCRUZ	:= nVlrTit*oModelMOE:GetValue("TASA", nValMoed)
				Endif
				SE1->E1_VALOR   	:= nVlrTit
				SE1->E1_SALDO   	:= nVlrTit
				SE1->E1_CLIENTE 	:= cCliente
				SE1->E1_LOJA    	:= cLoja
				SE1->E1_SERREC      := cSerie
				SE1->E1_RECIBO  	:= cRecibo
				SE1->E1_NOMCLI   	:= cNomCli
				SE1->E1_SITUACA  	:= "0"
				SE1->E1_ORIGEM   	:= "FINA887"
				SE1->E1_LA       	:= "S"
				SE1->E1_STATUS   	:= "A"
				SE1->E1_TXMOEDA		:= oModelMOE:GetValue("TASA", nValMoed)
			SE1->(MsUnlock())
			
			AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue("TASA",SE1->E1_MOEDA),SE1->E1_EMISSAO)
			cParc := Soma1(cParc)//Atualiza a proxima parcela
		EndIf
	Next nValMoed

Return

/*/{Protheus.doc} FINCOM
Metodo responsable por realizar el tratamiento 

@type 		Method

@param 		oModelSEL	,objeto		,Modelo de dados SEL.
@param 		nPosLine 	,numerico	,linea procesada del modelo SEL.

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINCOM(oModelSEL, nPosLine) Class F887FIN

Local aCpoSEX	:= {}
	
	SAQ->(Recno())
	//SE MUDAR ALGUMA POSICAO DO ARRAY ABAIXO, PRECISA CORRIGIR TB NOS FONTES FINA016/FINA87A/FINA088.
	AADD(aCpoSEX, oModelSEL:GetValue("EL_COBRAD",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_SERIE",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_RECIBO",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_DTDIGIT",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_CLIORIG",nPosLine))
	AADD(aCpoSEX, oModelSEL:GetValue("EL_LOJORIG",nPosLine) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_VALOR",nPosLine)  )
	AADD(aCpoSEX, SAQ->AQ_COMIS)
	AADD(aCpoSEX, Val( oModelSEL:GetValue("EL_MOEDA",nPosLine)))
	AADD(aCpoSEX, (oModelSEL:GetValue("EL_VALOR",nPosLine) ) * (SAQ->AQ_COMIS/100) )
	AADD(aCpoSEX, oModelSEL:GetValue("EL_TIPODOC",nPosLine) )	
	AADD(aCpoSEX, oModelSEL:GetValue("EL_NUMERO",nPosLine))
	
	Fa016Calc(aCpoSEX)	

Return Nil

/*/{Protheus.doc} FINCOB
Metodo responsable por realizar el tratamiento para documentos
de credito med

@type 		Method

@param 		cTipo	 	,caracter	,tipo
@param 		cCobrador	,caracter	,cobrador
@param 		cRecProv 	,caracter	,numero de recibo provisional
@param 		cSerie	 	,caracter	,serie del recibo

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINCOB(cTipo, cCobrador, cRecProv, cSerie, cRecibo) Class F887FIN
Local aArea		:= GetArea()       
Local lRet		:= .F.
Local lValSer 	:= .F.
Local cRecComp	:= ""

Default cCobrador := ""
	
	lValSer := SuperGetMv('MV_SERREC') // Usando serie nos recibos 
	
	If !Empty(cCobrador)
		DbSelectArea("SAQ")
		DbSetOrder(1)
		If dbSeek(xFilial("SAQ")+cCobrador) 
			self:nRecnoSAQ := Recno()
			If SAQ->AQ_TIPOREC=="3" .or. cTipo <> SAQ->AQ_TIPOREC .or. cTipo= "3"
				lRet:=.T.
			Else
				cRecComp	:= Iif(SAQ->AQ_TIPOREC =="1",cRecibo,cRecProv)
				cTipo 	:= SAQ->AQ_TIPOREC // Valida Tipo do Recibo do Cobrador  
				DbSelectArea("SEY")
				DbSetOrder(1)
				If dbSeek(xFilial("SEY")+cCobrador)      
					//So validar a serie quando é um recibo definitivo, provisorio nao tem serie
					While !EOF() .and. cCobrador == SEY->EY_COBRAD 	
						If SEY->EY_STATUS<>"2" .and. cTipo == SEY->EY_TIPOREC .and. cRecComp  >= SEY->EY_RECINI .and. cRecComp <= SEY->EY_RECFIN
							IF (lValSer .And. cTipo == '1' .AND. cSerie== SEY->EY_SERIE)
								lRet:=.T.
							ENDIF
							IF (!lValSer .And. cTipo == '1' .AND. Empty(SEY->EY_SERIE))
								lRet:=.T.
							EndIF
							IF lRet
								self:nRecnoSEY := SEY->(Recno())
								Exit
							ENDIF
						EndIf
						DbSkip()
					EndDo
				EndIf
				If !lRet
					HELP(" ",1,"A087NUMV")
				EndIf
			EndIf
		Else
			Help(" ",1,"RECNO")
		EndIf
	Else	
		lRet:=.T.
	EndIf	
	RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} FINGrvSE5
Metodo responsable por realizar la grabación de las tablas SE5 y Fk's'
de credito med

@type 		Method

@param 		nTipo		,numeri		,tipo
@param 		cTpCred 	,caracter	,tipo de credito
@param 		cNatureza 	,caracter	,naturaleza del recibo
@param 		cRecibo	 	,caracter	,numero de recibo
@param 		cSerie	 	,caracter	,serie del recibo
@param 		cDiarioSE5	,caracter	,
@param 		cMotBxSE5	,caracter	,motivo de baja
@param 		cIDProc		,caracter	,id de proceso
@param 		oModelFJT	,objeto		,Modelo de dados FJT.
@param 		oModelSEL 	,objeto		,Modelo de dados SEL.
@param 		oModelSE1	,objeto		,Modelo de dados SE1.
@param 		oModelMOE 	,objeto		,Modelo de dados de monedas y saldos.
@param 		lAlt		,logico 	,indica si realiza historico de cobranza
@param 		nPosLin		,logico 	,linea procesada
@param 		lCheque		,logico 	,indica si realiza tratamiento para cheques (ARG)
@param 		lCorrMon	,logico 	,indica si realiza tratamiento para correcion monetaria

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINGrvSE5(nTipo, cTpCred, cNatureza, cRecibo, cSerie, cDiarioSE5, cMotBxSE5, cIDProc, oModelFJT, oModelSEL, oModelSE1, oModelMOE, lAlt, nPosLin, lCheque, lCorrMon) Class F887FIN
Local lAdiantamento	:= .F.
Local nTxMoeda 		:= 0   
Local nMoedaF	 	:= 1
Local lGrvMov 		:= .T.
Local oModMovBco	:= Nil
Local oFK5MovBco	:= Nil
Local oFKAMovBco	:= Nil
Local oModelMov		:= FWLoadModel("FINM030") //Model de Mov. Bco.
Local oSubFKA		:= Nil	//RELACIONAMENTO
Local oSubFK5		:= Nil //MOVTO BANCARIO
Local oSubFK6     	:= Nil //MOVTO acessoorios
Local cFilSE5		:= FWxFilial("SE5")
Local cCamposE5		:= ""
Local cIdFK5		:= ""
Local cLog			:= ""
Local nTamHist    	:= GetSx3Cache("FK5_HISTOR","X3_TAMANHO")
Local cHistMov    	:= ""   
Local lRet			:= .T. //Validação do Modelo
Local aAlt 			:= {}
Local cFilFK6		:= FWxFilial("FK6")
Local cIdFK2		:= ''
Local cChaveCH 		:= ""
Local cMoeda		:= ""

Local lExistFKD	:= ExistFunc("FAtuFKDBx")

Local nTaxa			:= 1
Local aBaixas		:= {}

Local nTxCor		:= 0
Local nValOrig		:= 0
Local nValAtu		:= 0

Local aDiario 		:= {}
Local nX			:= 0
//Private aBaixas		:= {}
If Type('aLinMoed') == "U"
	Private aLinMoed	:= {}
EndIf

Default nTipo		:= ""
Default cTpCred		:= ""
Default cNatureza	:= ""
Default cRecibo 	:= ""
Default cSerie		:= ""
Default cDiarioSE5	:= ""
Default cMotBxSE5	:= "NOR"
Default cIDProc		:= ""
Default oModelFJT	:= Nil
Default oModelSEL	:= Nil
Default oModelSE1	:= Nil
Default oModelMOE	:= Nil
Default lAlt		:= .F.
Default lCheque		:= .F.
Default lCorrMon	:= .F.

If Len(aLinMoed) == 0
	For nX := 1 To oModelMOE:Length()
		aAdd(aLinMoed, {oModelMOE:GetValue("MOEDA", nX), oModelMOE:GetValue("TASA", nX), oModelMOE:GetValue("RECIBIDO", nX), oModelMOE:GetValue("SALDO", nX)})
	Next
EndIf

If nTipo==1

	lAdiantamento := .F.
	
	nTaxa := oModelMOE:GetValue("TASA",SE1->E1_MOEDA)
	
	nDescont	  := SE1->E1_DESCONT * nTaxa
	nJuros		  := SE1->E1_JUROS   * nTaxa
	nMulta		  := SE1->E1_MULTA   * nTaxa
	nValRec		  := SE1->E1_VALLIQ  * nTaxa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Taxa da moeda: calcula segundo valores do titulo SE1         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTxMoeda := Round( SE1->E1_VLCRUZ/SE1->E1_VALOR , GetSx3Cache("M2_MOEDA"+AllTrim(STR(SE1->E1_MOEDA)),"X3_DECIMAL") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A correcao monetaria nao deve ser gravada pois os pagamentos sao feitos em bloco,    ³
	//³e nao temos como saber se o titulo foi pago com a mesma moeda (neste caso nao existe ³
	//³correcao monetaria) ou com outra moeda diferente.                                    ³
	//³A correcao eh tratada nos relatorios.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCM			:=	0
	nValToler	:=	0
	cLoteFin	:= GetSx8Num("SE5", "E5_LOTE", "E5_LOTE" + cEmpAnt)
	If lAdiantamento
		cBanco		:= SE1->E1_PORTADO
		cAgencia	:= SE1->E1_AGEDEP
		cConta		:= SE1->E1_CONTA
	Else
		cBanco		:= ""
		cAgencia	:= ""
		cConta		:= ""
	Endif
	nValEstrang	:= SE1->E1_VALLIQ
	dBaixa  	:= SE1->E1_DTACRED
	cMotBx		:= IF(Empty(SE1->E1_MOTIVO),"NOR",SE1->E1_MOTIVO)
	cHist070	:= STR0046 + cRecibo + "-" + cSerie //"Valor recebido por Recibo "
	nMoedaF:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGETMV("MV_MCUSTO")))
	nTotAbat := 0
	
	//Atualiza saldo dos valores acessórios (FKD)
	If lExistFKD
		FAtuFKDBx(.F.)
	EndIf	
	
	FA070Mov(.T.,.T.,lAdiantamento,SE1->E1_DTACRED,@aBaixas,,,nTaxa,,,,,cIDProc)
	ConfirmSX8()
	AtuSalDup(IIf(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT,"+","-"),SE1->(E1_VALLIQ+E1_DESCONT-E1_JUROS-E1_MULTA),SE1->E1_MOEDA,SE1->E1_TIPO,oModelMOE:GetValue('TASA', nMoedaF),dDataBase)
	dbSelectArea("SE1")
	nSalvRec	:= SE1->(RecNo())
	cNum	  	:= SE1->E1_NUM
	cPrefixo	:= SE1->E1_PREFIXO
	cParcela	:= SE1->E1_PARCELA
	cCliente	:= SE1->E1_CLIENTE
	cLoja     	:= SE1->E1_LOJA
	cTipo   	:= ""
	If SuperGETMV("MV_TPCOMIS") == "O"
		aBaixas:={}
		If UsaSeqCor()
			AAdd(aDiario,{"SE5",SE5->(Recno()),cDiarioSE5,"E5_NODIA","E5_DIACTB"})
  		EndIf
		AAdd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno()),,SE1->E1_VEND1})
		Pergunte("AFI440",.F.)
		Fa440CalcB(aBaixas,.F.,.F.,"FINA887",,,,.T.,SE1->(Recno()))
	Endif
	
	If lAlt

		///numbor			
		aAlt := {}
	    aadd( aAlt,{ STR0044 ,'','','',STR0045  + Alltrim(Transform(nValEstrang,PesqPict("SE5","E5_VALOR"))) })//"Baja vía recibo" //"Se realizó una baja por el valor de "
		///chamada da Função que cria o Histórico de Cobrança
		FinaCONC(aAlt)	
	EndIf

ElseIf nTipo==2
	
	If lGrvMov
		SE5->(DbSetOrder(3))//	E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)
		IF !(SE5->(DbSeek(xFilial("SE5")+oModelSEL:GetValue("EL_BANCO", nPosLin)+oModelSEL:GetValue("EL_AGENCIA", nPosLin)+oModelSEL:GetValue("EL_CONTA", nPosLin)+;
			oModelSEL:GetValue("EL_PREFIXO", nPosLin)+oModelSEL:GetValue("EL_NUMERO", nPosLin)+oModelSEL:GetValue("EL_PARCELA", nPosLin)+oModelSEL:GetValue("EL_TIPODOC", nPosLin)+ DTOS(oModelSEL:GetValue("EL_DTVCTO",nPosLin)))))
			oModelMov:SetOperation( MODEL_OPERATION_INSERT )
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "IDPROC", cIDProc )
			oModelMov:SetValue( "MASTER", "NOVOPROC", .F. ) //Informa que a inclusão não será feita com um novo número de processo
			
		Else
			Return
		Endif
		
		oSubFK5	:= oModelMov:GetModel("FK5DETAIL")
		oSubFK6    := oModelMov:GetModel("FK6DETAIL")
		oSubFKA	:= oModelMov:GetModel("FKADETAIL")
	
		//Reposiciono o banco informado no Recibo
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial()+oModelSEL:GetValue("EL_BANCO", nPosLin)+oModelSEL:GetValue("EL_AGENCIA",nPosLin)+oModelSEL:GetValue("EL_CONTA", nPosLin)))
		
		//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		cCamposE5 += " { "
		cCamposE5 += " {'E5_FILIAL'		,'" + cFilSE5 + "'}"
		cCamposE5 += ",{'E5_PREFIXO'	,'" + oModelSEL:GetValue("EL_PREFIXO", nPosLin) +"'}"
		cCamposE5 += ",{'E5_NUMERO'		,'" + oModelSEL:GetValue("EL_NUMERO", nPosLin) + "'}"
		cCamposE5 += ",{'E5_PARCELA'	,'" + oModelSEL:GetValue("EL_PARCELA", nPosLin) + "'}"
		cCamposE5 += ",{'E5_CLIFOR'		,'" + oModelSEL:GetValue("EL_CLIENTE", nPosLin) + "'}"
		cCamposE5 += ",{'E5_LOJA'		,'" + oModelSEL:GetValue("EL_LOJA", nPosLin) + "'}"
		cCamposE5 += ",{'E5_BENEF'		,'" + SA1->A1_NREDUZ + "'}"
		cCamposE5 += ",{'E5_TIPO'		,'" + oModelSEL:GetValue("EL_TIPODOC", nPosLin) + "'}"
		cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_SERREC'		,'" + oModelFJT:GetValue("FJT_SERIE") + "'}"
		cCamposE5 += ",{'E5_VENCTO'		, STOD('" + DTOS(oModelSEL:GetValue("EL_DTVCTO", nPosLin)) + "')}"
		If !oSubFKA:IsEmpty()
			oSubFKA:AddLine()
		EndIf
		cIdFK5 := FWUUIDV4()
		oSubFKA:SetValue( "FKA_IDORIG"  , cIdFK5 )
		oSubFKA:SetValue( "FKA_TABORI" 	, 'FK5' ) //Todo o recibo precisa do mesmo número de processo
		
		cHistMov := Left( STR0046 + oModelFJT:GetValue("FJT_RECIBO") + "-" + oModelFJT:GetValue("FJT_SERIE") , nTamHist )	//"Valor cobrado por recibo "
		oSubFK5:SetValue( "FK5_RECPAG"	, "R" )
		oSubFK5:SetValue( "FK5_HISTOR"	, cHistMov ) //"Valor recebido por Recibo "
		oSubFK5:SetValue( "FK5_DATA"	, oModelFJT:GetValue("FJT_EMISSA") ) 
		oSubFK5:SetValue( "FK5_DTDISP"	, IIf(cTpCred=="1",self:dDataRef,oModelSEL:GetValue("EL_DTVCTO", nPosLin)) )	// 1-Imediato  2-Vencimento
		oSubFK5:SetValue( "FK5_TPDOC"	, "VL" )
		oSubFK5:SetValue( "FK5_VLMOE2"	, oModelSEL:GetValue("EL_VALOR",nPosLin) )
		oSubFK5:SetValue( "FK5_ORDREC"	, oModelFJT:GetValue("FJT_RECIBO") )
		oSubFK5:SetValue( "FK5_MOEDA"	, StrZero( SA6->A6_MOEDA, 2) )
		cMoeda := oModelSEL:GetValue("EL_MOEDA", nPosLin)
		oSubFK5:SetValue( "FK5_VALOR"	, xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),Max(SA6->A6_MOEDA,1),,,oModelMOE:GetValue("TASA", Val(cMoeda)),oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)) ) )
		oSubFK5:SetValue( "FK5_BANCO"	, oModelSEL:GetValue("EL_BANCO", nPosLin) )
		oSubFK5:SetValue( "FK5_AGENCI"	, oModelSEL:GetValue("EL_AGENCIA", nPosLin) )
		oSubFK5:SetValue( "FK5_CONTA"	, oModelSEL:GetValue("EL_CONTA", nPosLin) )
		oSubFK5:SetValue( "FK5_SEQ"		, PadL("1",GetSx3Cache("E5_SEQ","X3_TAMANHO"),"0") )
		oSubFK5:SetValue( "FK5_LA"		, "S" )
		oSubFK5:SetValue( "FK5_NATURE"	, cNatureza )	
		oSubFK5:SetValue( "FK5_TXMOED"	, oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)) )
		oSubFK5:SetValue( "FK5_ORIGEM"	, "FINA887" )
		oSubFK5:SetValue( "FK5_FILORI"	, cFilAnt )

		If lCorrMon .And. ALLTRIM(cMoeda) <> "1"
			nTxCor:= Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO, SE1->E1_MOEDA))
			nValOrig:= xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),1,,,nTxCor)
			nValAtu:= xMoeda(oModelSEL:GetValue("EL_VALOR", nPosLin),Val(cMoeda),1,,,oModelMOE:GetValue("TASA", Val(cMoeda)),oModelMOE:GetValue("TASA", Max(SA6->A6_MOEDA,1)))

			cCamposE5 += ",{'E5_VLCORRE'," + CVALTOCHAR(nValAtu - nValOrig) + "}"
			If nValAtu - nValOrig != 0
				/*
				 * Adicionando valores acessórios (Correção Monetária)
				 */
				cIdFK2		:= FWUUIDV4()
				If !oSubFK6:IsEmpty()
					oSubFK6:AddLine()
				EndIf
				oSubFK6:SetValue( 'FK6_FILIAL'	, cFilFK6 )
				oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )
				oSubFK6:SetValue( 'FK6_TABORI'	, 'SE2' )
				oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
				oSubFK6:SetValue( 'FK6_VALCAL'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_VALMOV'	, nValAtu - nValOrig  )
				oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
				oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK2 )
				oSubFK6:SetValue( 'FK6_GRVSE5'	, .F.)
			Endif
		EndIf
		
		cCamposE5 += " } "

		//Informo os campos que devem ser gravados somente na SE5
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
		
		//Se for movimento de cheque, vincula o cheque no processo 	
		If lCheque .and. oModelSEL:GetValue("EL_TIPODOC", nPosLin) == "CH" 
			aAreaSEF := GetArea()
			//Verifica se o  possui ID se não ele cria
			dbSelectArea( "SEF" )
			dbSetOrder( 1 )

			If msSeek( xFilial("SEF") + oModelSEL:GetValue("EL_BCOCHQ", nPosLin) + oModelSEL:GetValue("EL_AGECHQ", nPosLin) + oModelSEL:GetValue("EL_CTACHQ", nPosLin) + oModelSEL:GetValue("EL_NUMERO", nPosLin) )
				If Empty( SEF->EF_IDSEF )
					cChaveCH := FWUUIDV4()             
					Reclock( "SEF", .F. )
					SEF->EF_IDSEF	:= cChaveCH
					SEF->( msUnlock() )
				Else
					cChaveCH := SEF->EF_IDSEF
				Endif

				oFKAMovBco:AddLine()
				oFKAMovBco:SetValue( "FKA_IDORIG", cChaveCH )
				oFKAMovBco:SetValue( "FKA_TABORI", "SEF" )
			Endif

			RestArea( aAreaSEF )
		Endif
		
		
		If oModelMov:VldData()
			oModelMov:CommitData()
			
			If UsaSeqCor()
				AAdd(aDiario,{"SE5",SE5->(Recno()),oModelSEL:GetValue("EL_DIACTB", nPosLin),"E5_NODIA","E5_DIACTB"})
			EndIf
			
		
			nValToler	:= 0
			cBanco		:= oModelSEL:GetValue("EL_BANCO", nPosLin)
			cAgencia	:= oModelSEL:GetValue("EL_AGENCIA", nPosLin)
			cConta		:= oModelSEL:GetValue("EL_CONTA", nPosLin)
			cLoteFin	:= ""
			
			nValEstrang	:= SE1->E1_VALLIQ
			
			If oModelSEL:GetValue("EL_TPCRED", nPosLin) == "1"
				dBaixa := dDataBase
			Else
				dBaixa := oModelSEL:GetValue("EL_DTVCTO", nPosLin)
			Endif	
					
			cHist070:=STR0046+cRecibo+"-"+cSerie //"Valor recebido por Recibo "
			
			IF !EMPTY(cBanco).And. MovBcoBx(cMotBxSE5, .T.) .and. !lAdiantamento 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar Saldo Banc rio	        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AtuSalBco(cBanco,cAgencia,cConta,dBaixa,SE5->E5_VALOR,"+")
			EndIf
				
		Else
			lRet := .F.
			cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
			Help( ,,"MF887GSE5",,cLog, 1, 0 ) 
			lRet := .F.
			lMsErroAuto := .T.
		Endif
		oModelMov:DeActivate()		
	EndIf		
Endif

Return lRet

/*/{Protheus.doc} F887DEL
Metodo responsable por realizar la llamada de la rutina fina088 para realizar el proceso de borrado.

@type 		Method

@author 	raul.medina
@version	12.1.27 / Superior
@since		05/05/2021 
/*/
Method F887DEL() Class F887FIN
Local lRet			:= .T.
Local nX			:= 0
Local oModel 		:= FWModelActivate()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
Local cSerie		:= oModelFJT:GetValue("FJT_SERIE")
Local aResponse		:= {} As Array
Local jData			:= JsonObject():New()
Local aCab			:= {}

	SetFunName("FINA887") 
	Pergunte("FIN088",.F.)
	SetMVValue("FIN088","MV_PAR01", 2)			//Filtra Canceladas - 1 = Si / 2 = No
	SetMVValue("FIN088","MV_PAR02", cRecibo)	//De Recibo 
	SetMVValue("FIN088","MV_PAR03", cRecibo)	//A Recibo
	SetMVValue("FIN088","MV_PAR06", 0)			//Moeda - 1
	SetMVValue("FIN088","MV_PAR07", cSerie)		//Serie de Recibo
	jData['origin']	:= "FINA998"

	If oModelSEL:Length() > 0
		aAdd(aCab, {"EL_FILIAL" , oModelSEL:GetValue("EL_FILIAL")	, Nil})
		aAdd(aCab, {"EL_RECIBO" , oModelSEL:GetValue("EL_RECIBO")	, Nil})
		aAdd(aCab, {"EL_CLIORIG", oModelSEL:GetValue("EL_CLIORIG")	, Nil})
		aAdd(aCab, {"EL_LOJORIG", oModelSEL:GetValue("EL_LOJORIG")	, Nil})
		aAdd(aCab, {"EL_TIPO" 	, oModelSEL:GetValue("EL_TIPO")		, Nil})
		aAdd(aCab, {"EL_TIPODOC", oModelSEL:GetValue("EL_TIPODOC")	, Nil})
		aAdd(aCab, {"EL_PREFIXO", oModelSEL:GetValue("EL_PREFIXO")	, Nil})
		aAdd(aCab, {"EL_NUMERO" , oModelSEL:GetValue("EL_NUMERO")	, Nil})
		aAdd(aCab, {"EL_PARCELA", oModelSEL:GetValue("EL_PARCELA")	, Nil})
		aAdd(aCab, {"EL_VALOR" 	, oModelSEL:GetValue("EL_VALOR")	, Nil})
		aAdd(aCab, {"EL_MOEDA" 	, oModelSEL:GetValue("EL_MOEDA")	, Nil})
	
		MSExecAuto({|v,w,x,y,z| FINA088(v,w,x,y,z)},1,.T.,aCab,@aResponse,jData)
		
	EndIf

Return lRet

/*/{Protheus.doc} F887CAN
Metodo responsable por realizar la llamada de la rutina fina088 para realizar el proceso de Cancelación.
	
	Esta función se ejecutara ModelPosVld hasta no pasar la funcionalidad de la fina088 al modelo
	Las validaciones se ejecuten en ModelPosVld y el grabado de datos de la FJT y SEL serán en el InTTS

@type 		Method

@author 	Jose.Gonzalez
@version	12.1.33 / Superior
@since		15/07/2022 
/*/
Method F887CAN() Class F887FIN
Local lRet			:= .F.
Local nX			:= 0
Local oModel 		:= FWModelActivate()
Local oModel846		
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelGEN		:= oModel:GetModel('GEN_DETAIL')
Local cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
Local cSerie		:= oModelFJT:GetValue("FJT_SERIE")
Local cVers			:= oModelFJT:GetValue("FJT_VERSAO")
Local aCab			:= {}
local jData		:= JsonObject():New()
local aResponse := {}
local cError := ""
Local aError := {}
Local cSaltoLin		:= Chr(10)+ Chr(13)
Local cSubRutina:= ""

IF cPaisLoc <> "ARG"
	SetFunName("FINA887") 
	jData['origin']	:= "FINA998"
	If oModelGEN:HasField("MOTCAN")
		jData['motCanc'] := oModelGEN:GetValue("MOTCAN") 
	EndIf	
	jData['mv_par01']	:= If( oModelFJT:GetValue("ASIENTO")  ==1,.T.,.F.) 
	jData['mv_par02']	:= If( oModelFJT:GetValue("AGRUPA")  == 1,.T.,.F.) 	
	Pergunte("FIN088",.F.)
	
	MV_PAR01 := 2
	MV_PAR02 := cRecibo
	MV_PAR03 := cRecibo
	MV_PAR06 := 1
	MV_PAR07 := cSerie
	
	If oModelSEL:Length() >  0
		aAdd(aCab, {"EL_FILIAL" , oModelSEL:GetValue("EL_FILIAL")	, Nil})
		aAdd(aCab, {"EL_RECIBO" , oModelSEL:GetValue("EL_RECIBO")	, Nil})
		aAdd(aCab, {"EL_CLIORIG", oModelSEL:GetValue("EL_CLIORIG")	, Nil})
		aAdd(aCab, {"EL_LOJORIG", oModelSEL:GetValue("EL_LOJORIG")	, Nil})
		aAdd(aCab, {"EL_TIPO" 	, oModelSEL:GetValue("EL_TIPO")		, Nil})
		aAdd(aCab, {"EL_TIPODOC", oModelSEL:GetValue("EL_TIPODOC")	, Nil})
		aAdd(aCab, {"EL_PREFIXO", oModelSEL:GetValue("EL_PREFIXO")	, Nil})
		aAdd(aCab, {"EL_NUMERO" , oModelSEL:GetValue("EL_NUMERO")	, Nil})
		aAdd(aCab, {"EL_PARCELA", oModelSEL:GetValue("EL_PARCELA")	, Nil})
		aAdd(aCab, {"EL_VALOR" 	, oModelSEL:GetValue("EL_VALOR")	, Nil})
		aAdd(aCab, {"EL_MOEDA" 	, oModelSEL:GetValue("EL_MOEDA")	, Nil})
			
		MSExecAuto({|v,w,x,y,z| FINA088(v,w,x,y,z)},3,.T.,aCab,@aResponse,jData)

		For nX := 1 To  LEN(aResponse)
			If aResponse[nX][1] = .T. .and. aScanx(aResponse,{|x|x[1] == .F.}) == 0
				lRet := .T.
					FJT->FJT_CANCEL:="1"
				If VldLibMet()	//Valida la fecha de la LIB para utilizacion en Telemetria
					// Metrica de control documentos Anulados exitosamente.
					cSubRutina := "RECIBO_ANUL_FINA998_"+Upper(cPaisloc)
					FwCustomMetrics():setSumMetric(cSubRutina, "financiero-protheus_cantidad-de-anulados-recibo-de-cobro-por-pais-total", 1, /*dDatabase*/, /*nLapTime*/, "FINA887")
				EndIf
			ElseIf aResponse[nX][1] = .F.
				cError += aResponse[nX][3]+" "+ aResponse[nX][4] + cSaltoLin
				lRet := .F. 
			EndIf
		Next 
		IF !lRet
			oModel:SetErrorMessage('FJT_MASTER', '' , 'FJT_MASTER' , '' ,'Error' , cError, cError)
			DisarmTransaction()
		ENDIF
	EndIf
Else
	SetFunName("FINA887") 
	DbSelectArea('FJT')
	FJT->(DbSetorder(1)) //FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
	If FJT->(MSSeek( xFilial("FJT") +cSerie+cRecibo+cVers))
		oModel846 := FwLoadModel("FINA846")
		oModel846:SetOperation( MODEL_OPERATION_DELETE )
		MV_PAR01 := oModelFJT:GetValue("ASIENTO") 
		MV_PAR02 := oModelFJT:GetValue("AGRUPA")
		MV_PAR03 := oModelFJT:GetValue("ONLINE")

		//-- Activación del modelo de datos
		oModel846:Activate()
		//-- Grabación de los datos
		If 	oModel846:VldData()
		 	IF oModel846:CommitData() 
				lRet := .T.
				If VldLibMet()	//Valida la fecha de la LIB para utilizacion en Telemetria
								// Metrica de control documentos Anulados exitosamente.
					cSubRutina := "RECIBO_ANUL_FINA998_"+Upper(cPaisloc)
					FwCustomMetrics():setSumMetric(cSubRutina, "financiero-protheus_cantidad-de-anulados-recibo-de-cobro-por-pais-total", 1, /*dDatabase*/, /*nLapTime*/, "FINA887")
				EndIf
			ELSE
				cError	:= oModel846:GetErrorMessage()[6] + " " + oModel846:GetErrorMessage()[7]
				oModel:SetErrorMessage('FJT_MASTER', '' , 'FJT_MASTER' , '' ,NIL,cError,cError)
				DisarmTransaction()
				lRet := .F.
			ENDIF		
		Else
			aError := oModel846:GetErrorMessage()
			oModel:SetErrorMessage('FJT_MASTER', '' , 'FJT_MASTER' , '' ,aError[6] , aError[6], aError[6])
			lRet := .F. 
		EndIf 
			
		oModel846:DeActivate()
	Endif
	FJT->(DbCloseArea())
ENDIF

Return lRet

/*/{Protheus.doc} F887CkPG
Metodo responsable por realizar validaciones para Perú
@type 		Method

@param 		nOpc		,numeri		,opción
@param 		lValida 	,caracter	,indica si se realiza la validación, sólo se activa en la rutina F887FINPER
@param 		cBanco	 	,caracter	,banco a ser usado en las validaciones
@param 		nPagar	 	,caracter	,pagar

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/05/2021 
/*/
Method F887CkPG(nOpc,lValida,cBanco,nPagar) Class F887FIN
Local lRet := .T.

Default nPagar 	:= 0

If lValida
	If nOpc == 0
		If cBanco $ (Left(SuperGetMV("MV_CXFIN"),GetSx3Cache("A6_COD","X3_TAMANHO"))+"/"+SuperGetMV("MV_CARTEIR")) .or. IsCaixaLoja(cBanco)
			If nPagar == 2
				lRet := .F.
			Endif
		Endif
	Elseif nOpc == 3
		If cBanco $ (Left(SuperGetMV("MV_CXFIN"),GetSx3Cache("A6_COD","X3_TAMANHO"))+"/"+SuperGetMV("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
			lRet := .F.
		Endif
	Endif
Endif

Return (lRet)

/*/{Protheus.doc} FI998NFRA
Si la naturaleza del valor es anticipo, ED_OPERADT=1 genera el valor tipo RA (E1_TIPODOC) en base al valor anticipo.
Esta rutina se basa en el proceso de generación de NCC 
@type method
@version  1
@author luis.aboytes
@since 28/3/2023
/*/
Function FI998NFRA(nValBaixa,nPosLine,oModel)
Local cDocRA		:= Substr(MVRECANT,1,3)
Local cParcSE1		:= CriaVar("E1_PARCELA",.T.)
Local aSaveArea		:= GetArea()
Local aSaveSE1		:= SE1->(GetArea())
Local aSaveSEL		:= SEL->(GetArea())
Local nValImps  	:= 0
Local nTamVlMoed	:= TamSX3("EL_VLMOED1")[2]
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')

Default nValBaixa	:= 0

If SE1->(!EOF())
	SE1->(MsGoto(oModelSE1:GetValue("RECNO",nPosLine)))
	RegToMemory("SE1",.F.) //Carga el titulo a memoria

	//Si el valor tipo RA ya existe (proceso de cancelación parcial) se incrementa el campo E1_PARCELA
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	While  SE1->(MSSEEK(XFilial("SE1")+oModelSE1:GetValue("E1_PREFIXO",nPosLine)+oModelSE1:GetValue("E1_NUM",nPosLine)+cParcSE1+cDocRA))
		cParcSE1 := Soma1(cParcSE1)
	SE1->(DbSkip())
	EndDo

	nValImps:= fVerifImp(oModelSE1:GetValue("E1_NUM",nPosLine), oModelSE1:GetValue("E1_PREFIXO",nPosLine),oModelSE1:GetValue("E1_TIPO",nPosLine),oModelSE1:GetValue("E1_CLIENTE",nPosLine),oModelSE1:GetValue("E1_LOJA",nPosLine))  // retorna el valor del Impuesto
	
	//Genera el nuevo título RA El concepto de creación es similar al generado en el NCC.
	RecLock("SE1",.T.)
	SE1->E1_FILIAL   	:= XFilial("SE1")
	SE1->E1_FILORIG   	:= cFilant
	SE1->E1_PREFIXO  	:= oModelSE1:GetValue("E1_PREFIXO",nPosLine)
	SE1->E1_NUM			:= oModelSE1:GetValue("E1_NUM",nPosLine)
	SE1->E1_PARCELA		:= cParcSE1
	SE1->E1_TIPO     	:= cDocRA
	SE1->E1_EMISSAO  	:= oModelFJT:GetValue("FJT_EMISSA")
	SE1->E1_EMIS1    	:= oModelFJT:GetValue("FJT_EMISSA")
	SE1->E1_VENCTO  	:= oModelFJT:GetValue("FJT_EMISSA")
	SE1->E1_VENCREA 	:= DataValida(oModelFJT:GetValue("FJT_EMISSA"))
	SE1->E1_NATUREZ  	:= oModelSE1:GetValue("E1_NATUREZ",nPosLine)
	SE1->E1_MOEDA   	:= M->E1_MOEDA
	SE1->E1_VLCRUZ		:= oModelSE1:GetValue("BAIXAR",nPosLine)*oModelMOE:GetValue("TASA",M->E1_MOEDA) 
	SE1->E1_VALOR   	:= nValBaixa
	SE1->E1_SALDO   	:= nValBaixa - nValImps //Resta el importe referente al IVA por compensación en la facturación
	SE1->E1_CLIENTE 	:= oModelSE1:GetValue("E1_CLIENTE",nPosLine)
	SE1->E1_LOJA    	:= oModelSE1:GetValue("E1_LOJA",nPosLine)
	SE1->E1_SERREC      := oModelFJT:GetValue("FJT_SERIE")
	SE1->E1_RECIBO  	:= oModelFJT:GetValue("FJT_RECIBO")
	SE1->E1_NOMCLI   	:= SA1->A1_NOME
	SE1->E1_SITUACA  	:= "0"
	SE1->E1_ORIGEM   	:= "FINA887"
	SE1->E1_LA       	:= "S"
	SE1->E1_STATUS   	:= "A"
	SE1->E1_TXMOEDA		:= M->E1_TXMOEDA
	SE1->(MsUnlock())

	//Genera el recibo de título RA generado anteriormente
	RecLock("SEL",.T.)
	SEL->EL_FILIAL   	:= XFilial("SEL")
	SEL->EL_TIPODOC  	:= "RA"
	SEL->EL_PREFIXO  	:= "REC"
	SEL->EL_NUMERO   	:= SE1->E1_NUM
	SEL->EL_PARCELA  	:= SE1->E1_PARCELA
	SEL->EL_TIPO   		:= cDocRA
	SEL->EL_EMISSAO  	:= oModelFJT:GetValue("FJT_EMISSA")
	SEL->EL_DTDIGIT  	:= dDatabase
	SEL->EL_DTVCTO   	:= oModelFJT:GetValue("FJT_EMISSA")
	SEL->EL_NATUREZ  	:= SE1->E1_NATUREZ
	SEL->EL_MOEDA    	:= StrZero(SE1->E1_MOEDA,2)
    SEL->EL_DESCONT  	:= SE1->E1_DESCONT
	SEL->EL_VLMOED1 	:= Round(nValBaixa * oModelMOE:GetValue("TASA",SE1->E1_MOEDA), MsDecimais(nTamVlMoed))
	SEL->EL_VALOR    	:= nValBaixa
	SEL->EL_CLIENTE 	:= oModelSE1:GetValue("E1_CLIENTE",nPosLine)
	SEL->EL_LOJA	 	:= oModelSE1:GetValue("E1_LOJA",nPosLine)
	SEL->EL_SERIE    	:= oModelFJT:GetValue("FJT_SERIE")
	SEL->EL_RECIBO 		:= oModelFJT:GetValue("FJT_RECIBO")
	SEL->EL_COBRAD		:= oModelFJT:GetValue("FJT_COBRAD")
	SEL->EL_RECPROV		:= oModelFJT:GetValue("FJT_RECPRV")
	SEL->EL_CLIORIG		:= oModelFJT:GetValue('FJT_CLIENT')
	SEL->EL_LOJORIG		:= oModelFJT:GetValue("FJT_LOJA")
	FINGRVTAX(oModelMOE, @oModelSEL,.T.)
	SEL->(MsUnlock())

EndIf

RestArea(aSaveSEL)
RestArea(aSaveSE1)
RestArea(aSaveArea)

Return Nil

/*/{Protheus.doc} fVerifImp
Obtiene el impuesto del Anticipo en cuentas por pagar
@type method
@version  1
@author luis.aboytes
@since 28/3/2023
/*/
Function fVerifImp(cNum,cPrefix,cTipo,cCliente,cLoja) 

	Local aArea			:= GetArea()
	Local cNumVali		:= ""
	Local nValor		:= 0
	Local cImpAdi		:= ""
	Local cTESD2		:= ""
	Local lAplImpAdi	:= SuperGetMV("MV_ADIAPLI",.F.,.T.)
	Local nSigno 		:= 1

	If lAplImpAdi
		DBSelectArea("SD2")
		SD2->(DBSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->(MSSEEK(xFilial("SD2")+cNum+cPrefix+cCliente+cLoja,.F.))
			cTESD2 := &("SD2->D2_TES")
		EndIf

		DbSelectArea("SFC")
		SFC->(DBSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
		If SFC->(MSSEEK(xFilial("SFC")+cTESD2))
			While SFC->(!EOF()) .And. SFC->FC_TES == cTESD2
				cImpAdi:= SFC->FC_IMPOSTO
				cNumVali := POSICIONE("SFB",1,xFilial("SFB")+PADR(cImpAdi,TamSx3("FB_CODIGO")[1]) ,"FB_CPOLVRO")
				nSigno := IIF(SFC->FC_INCDUPL == "2",-1,1)

				If !Empty(cNum) .and. !Empty(cNumVali)
					DBSelectArea("SF2")
					SF2->(DBSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
					If SF2->(MSSEEK(xFilial("SF2")+cCliente+cLoja+cNum+cPrefix))
						nValor += &("SF2->F2_VALIMP"+cNumVali) * nSigno
					EndIf
				EndIf
				SFC->(DbSkip())
			EndDo
        EndIf
	EndIF
	RestArea(aArea)

Return  nValor

/*/{Protheus.doc} VldLibMet
	Función utilizada para validar si el ambiente tiene la libreria para
	utilización de Metrícas Protheus.

	@type Static Function
	@author Jose.gonzalez
	@since 24/08/2023
	@version 1.0
	@example
	VldLibMet()
	/*/
Static Function VldLibMet()
	Local lRet	:= .F.

	lRet := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lRet


/*/{Protheus.doc} getClientSAE
Metodo que retorna el cliente origen registrado en la tabla SAE
@type function
@version  1
@author luis.aboytes
@since 15/3/2024n
/*/
Function getClienteSAE(cAeCod)
	Local cCliente	:= "" As Character
	Default cAeCod	:= ""

	DbSelectArea("SAE")
	SAE->(DbSetOrder(1))//FJN_FILIAL+FJN_COD+FJN_AGENCI                                                                  
	If SAE->(MsSeek(xFilial("SAE")+cAeCod))
		 cCliente := SAE->AE_CODCLI
	EndIf
	SAE->(DbCloseArea())
Return cCliente


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
@author 	raul.medina	
@version	12.1.2210 / Superior
@since		08/2024
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class F887FIN
Local lRet	:= .T.
Local oView	:= Nil 

	If cModelID == "SE1_DETAIL"
        If cAction == "SETVALUE"
            If cId == "CHECK"
				If !Empty(oSubModel:GetValue("E1_NUM"))
					lRet := self:ValidTitle(oSubModel, nLine, xValue)
				EndIf
			EndIf
		EndIf

		If cAction == "CANSETVALUE" .And. cId == "CHECK"
			If self:lCFDI .And. xCurrentValue == .T.
				oView := FwViewActive()
				Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T.)
				If ValType(oView) == "O" .And. MV_PAR06 == 1
					lRet := F887Comp(oSubModel)
					If !lRet
						oSubModel:SetValue("CHECK", lRet)
					EndIf 
				EndIf
			EndIf
		EndIf
	ElseIf cModelID == "SEL_DETAIL"
		If cAction == "SETVALUE"
			If cId == "EL_TIPODOC" .and. self:lActTipo
				oSubModel:LoadValue("EL_TIPO", xValue)
			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} F887Comp
Función utilizada para verificar si un título posee compensación/factoraje
@author 	carlos.espinoza
@since 		06/2025
@version	12.1.2210 / Superior
Parametros
	oSubModel - objeto - Submodelo activo para ser procesado
@Return 
	lRet - lógico - variable que retorna si las validaciones fueron satisfactorias o no
/*/
Function F887Comp(oSubModel)
Local oDlg		:= Nil
Local oFwBrowse	:= Nil
Local oPanel	:= Nil
Local aColumns	:= {}
Local aItems	:= {}
Local aCampos	:= {}
Local nX		:= 0
Local cTitulo	:= ""
Local cTipo		:= ""
Local cPicture	:= ""
Local nTam		:= 0
Local nDec		:= 0
Local bMark
Local lRet      := .T.

Default oSubModel := Nil

	aItems := F887GtComp(oSubModel)

	If !F887VlComp({},.F.)
		lRet := .F.
		Return lRet
	EndIf
	
	If Len(aItems) == 0 
		MsgInfo(STR0248, STR0244) //El título seleccionado no posee ninguna compensación por lo que no se puede seleccionar para un recibo de factoraje. - Recibo de Factoraje
		lRet := .F.
		Return lRet
	EndIf 

	MsgInfo(STR0245, STR0244) //Las compensaciones mostradas corresponden a la factura a la que se registra el pago. Marque la(s) compensacion(es) que debe(n) complementar el CFDI de REP. Si se selecciona más de un movimiento, se generará un solo nodo de Pago por el total de estas operaciones. - Recibo de Factoraje

	oDlg := FwDialogModal():New()
    oDlg:SetTitle(STR0239) //"Compensaciones"
    oDlg:SetEscClose(.T.)
    oDlg:enableAllClient()
    oDlg:EnableFormBar(.T.)
	oDlg:CreateDialog()
	oPanel := oDlg:getPanelMain()
	oDlg:CreateFormBar()

	bMark := { |oBrw| Iif(aItems[oBrw:At()]['check'], 'LBOK','LBNO')}
	bDblClic := { |oBrw| aItems[oBrw:At()]['check'] := !aItems[oBrw:At()]['check'], oBrw:Refresh() }
	bHeaderCli := { |oBrw| aEval(aItems, {|x| x['check'] := !x['check']}), oBrw:Refresh() }
 
    oFwBrowse := FWBrowse():New(oPanel)
    oFwBrowse:SetDataArrayoBrowse()  //Define utilização de array
    oFwBrowse:SetArray(aItems) 		  //Indica o array utilizado para apresentação dos dados no Browse.
	oFwBrowse:AddMarkColumns(bMark,bDblClic,bHeaderCli)

	aAdd(aCampos, {"E5_DATA"	, "data"})
	aAdd(aCampos, {"E5_MOEDA"	, "coin"})
	aAdd(aCampos, {"E5_VALOR"	, "value"})
	aAdd(aCampos, {"E5_IDENTEE"	, "compensation"})
	aAdd(aCampos, {"E5_BENEF"	, "beneficiary"})
	aAdd(aCampos, {"E5_PREFIXO"	, "prefix"})
	aAdd(aCampos, {"E5_NUMERO"	, "title"})
	aAdd(aCampos, {"E5_PARCELA"	, "parcela"})

	//Columnas
	For nX := 1 To Len(aCampos)
		cTitulo	:= AllTrim(FwX3Titulo(aCampos[nX][1]))
		cTipo	:= GetSx3Cache(aCampos[nX][1], "X3_TIPO")
		cPicture:= AllTrim(GetSx3Cache(aCampos[nX][1], "X3_PICTURE"))
		nTam	:= GetSx3Cache(aCampos[nX][1], "X3_TAMANHO")
		nDec	:= GetSx3Cache(aCampos[nX][1], "X3_DECIMAL")
		aAdd(aColumns, {cTitulo, &("{ |oBrw| aItems[oBrw:At()]['" + aCampos[nX][2] + "'] }"), cTipo, cPicture, 1, nTam, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .T., {}, aCampos[nX][2]})	
		If cTipo == "D"
			aColumns[Len(aColumns)][2] := &("{ |oBrw| STOD(aItems[oBrw:At()]['" + aCampos[nX][2] + "']) }")
		EndIf
    Next

    //Cria as colunas do array
    For nX := 1 To Len(aColumns)
        oFwBrowse:AddColumn(aColumns[nX])
    Next
    oFwBrowse:SetFilterDefault()
	oFwBrowse:SetOwner(oPanel)
    oFwBrowse:SetDescription(STR0239) //"Compensaciones"
	oFwBrowse:DisableConfig(.T.)
	oFwBrowse:DisableReport(.T.)
    oFwBrowse:Activate()

	oDlg:AddCloseButton({|| lRet := .F.,oDlg:DeActivate()}, STR0093) //"Anular"
	oDlg:AddOkButton({|| lRet := F887AdComp(aItems), oDlg:DeActivate()}, STR0169) //"Confirmar"	
    oDlg:Activate()

Return lRet

/*/{Protheus.doc} F887AdComp
Función utilizada para insertar los items marcados a los modelos.
@author 	carlos.espinoza
@since 		06/2025
@version	12.1.2210 / Superior
Parametros
	aItems - Array - arreglo con la información de las compensaciones del título
@Return 
	lRet - lógico - variable que retorna si se seleccionó o no una compensación
/*/
Function F887AdComp(aItems)
Local nX		:= 0
Local oModel    := FWModelActive()
Local oMdlCOM   := oModel:GetModel('COM_DETAIL')
Local lRet 		:= .T.

Default aItems	:= {}

	If !F887VlComp(aItems,.T.)
		lRet := .F.
	EndIf

	For nX := 1 to Len(aItems)
		If aItems[nX]['check'] .And. !oMdlCOM:SeekLine({{"RECNO", aItems[nX]['recno']}, {"NUM",  aItems[nX]['title']}}, .F., .F.)
			If oMdlCOM:GetValue("RECNO") > 0
				oMdlCOM:AddLine()
			EndIf
			oMdlCOM:SetValue('RECNO',aItems[nX]['recno']) 
			oMdlCOM:SetValue('VALUE',aItems[nX]['value']) 
			oMdlCOM:SetValue('LLAVE',aItems[nX]['key']) 
			oMdlCOM:SetValue('NUM'	,aItems[nX]['title']) 
		ElseIf !aItems[nX]['check'] .And. oMdlCOM:SeekLine({{"RECNO", aItems[nX]['recno']}, {"NUM",  aItems[nX]['title']}}, .F., .T.)
			oMdlCOM:DeleteLine()
		EndIf
	Next

Return lRet

/*/{Protheus.doc} F887VlComp
Función utilizada para verificar validar el proceso de factoraje
@author 	carlos.espinoza
@since 		06/2025
@version	12.1.2210 / Superior
Parametros
    aItems    - array   - cantidad de compensaciones seleccionadas
    lConfirm  - lógico  - Indicador si se dió clic al botón confirmar en la pantalla de compensaciones
@Return 
	lRet - lógico - variable que retorna si las validaciones fueron satisfactorias o no
/*/
Function F887VlComp(aItems, lConfirm)
Local lRet := .T.
Local nX   := 0
Local nLen := 0

Default lConfirm := .F.
Default aItems   := {}

	If !lConfirm
		If FWFLDGET("E1_CLIENTE") == FWFLDGET("FJT_CLIENT")
			MsgInfo(STR0240, STR0244) //Los titulos seleccionados deben de ser de un cliente diferente al del encabezado del recibo por el proceso de factoraje. - Recibo de Factoraje
			lRet := .F.
		EndIf
	Else
		For nX := 1 to Len(aItems)
			If aItems[nX]['check'] 
				nLen++
			EndIf
		Next
		If nLen > 0
			If nLen > 1
				If !MsgYesNo(STR0241) //Hay selección de más de una compensación. En el CFDI de REP, se generará un solo nodo Pago, del total, por operaciones de factoraje financiero.
					lRet := .F.
				EndIf
			Else
				If !MsgYesNo(STR0242)//¿Está de acuerdo en generar nodo Pago de la compensación en el CFDI de REP?
					lRet := .F.
				EndIf
			EndIf
		Else
			If !MsgYesNo(STR0243)//No hay selección de compensación. En el CFDI de REP, no se generará nodo Pago por operaciones de factoraje financiero.
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F887GtComp
Función utilizada para verificar si un título posee compensación/factoraje
@author 	carlos.espinoza
@since 		06/2025
@version	12.1.2210 / Superior
Parametros
	oSubModel - objeto - Submodelo activo para ser procesado
@Return 
	aItems - array - Arreglo con la información de las compensaciones
/*/
Function F887GtComp(oSubModel)
Local aItems 		:= {} 
Local nPos			:= 0
Local cAlias 		:= ""
Local cQuery 		:= ""
Local oExec         := Nil
Local oModel    	:= FWModelActive()
Local oMdlCOM   	:= oModel:GetModel('COM_DETAIL')

Default oSubModel := Nil

	cQuery := " SELECT SE5.E5_DATA, SE5.E5_MOEDA, SE5.E5_TXMOEDA, CMP.E5_VALOR, CMP.E5_VLMOED2, CMP.E5_IDENTEE, CMP.E5_BENEF, CMP.E5_PREFIXO, CMP.E5_NUMERO, CMP.E5_PARCELA, SE5.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
	cQuery += " INNER JOIN " + RetSqlName("SE5") +" CMP ON CMP.E5_FILIAL =  SE5.E5_FILIAL AND CMP.E5_TIPO = SE5.E5_TIPO AND CMP.E5_RECPAG = ? AND CMP.E5_TIPODOC = SE5.E5_TIPODOC AND CMP.E5_MOTBX =  SE5.E5_MOTBX AND CMP.E5_SITUACA = SE5.E5_SITUACA AND CMP.E5_ORIGEM = SE5.E5_ORIGEM AND CMP.E5_IDENTEE = SE5.E5_IDENTEE AND CMP.D_E_L_E_T_= ? "
	cQuery += " WHERE "
	cQuery += " SE5.E5_FILIAL = ? "
	cQuery += " AND SE5.E5_TIPO = ? "
	cQuery += " AND SE5.E5_RECPAG = ?"
	cQuery += " AND SE5.E5_TIPODOC = ? "
	cQuery += " AND SE5.E5_MOTBX = ? "
	cQuery += " AND SE5.E5_SITUACA = ? "
	cQuery += " AND SE5.E5_ORIGEM = ? "
	cQuery += " AND SE5.E5_CLIFOR = ? "
	cQuery += " AND SE5.E5_LOJA = ? "
	cQuery += " AND SE5.E5_PREFIXO = ? "
	cQuery += " AND SE5.E5_NUMERO = ? "
	cQuery += " AND SE5.E5_PARCELA = ? "
	cQuery += " AND SE5.E5_RECCMP = ? "
	cQuery += " AND SE5.D_E_L_E_T_= ? "

	cQuery += " ORDER BY SE5.E5_IDENTEE "

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)
	oExec:SetString(1,"P")
	oExec:SetString(2," ")
	oExec:SetString(3,xFilial("SE5"))
	oExec:SetString(4,oSubModel:GetValue("E1_TIPO"))
	oExec:SetString(5,"R")
	oExec:SetString(6,"BA")
	oExec:SetString(7,"CEC")
	oExec:SetString(8,"")
	oExec:SetString(9,"FINA450")
	oExec:SetString(10,oSubModel:GetValue("E1_CLIENTE"))
	oExec:SetString(11,oSubModel:GetValue("E1_LOJA"))
	oExec:SetString(12,oSubModel:GetValue("E1_PREFIXO"))
	oExec:SetString(13,oSubModel:GetValue("E1_NUM"))
	oExec:SetString(14,oSubModel:GetValue("E1_PARCELA"))
	oExec:SetString(15," ")
	oExec:SetString(16," ")
	cAlias := oExec:OpenAlias()

	WHILE (cAlias)->(!EOF())
		Aadd(aItems,JsonObject():new())
		nPos := Len(aItems)
		aItems[nPos]['data']		:= (cAlias)->E5_DATA
		aItems[nPos]['coin']		:= (cAlias)->E5_MOEDA
		aItems[nPos]['value']		:= (cAlias)->E5_VALOR
		aItems[nPos]['compensation']:= (cAlias)->E5_IDENTEE
		aItems[nPos]['beneficiary']	:= (cAlias)->E5_BENEF
		aItems[nPos]['prefix']		:= (cAlias)->E5_PREFIXO
		aItems[nPos]['title']		:= (cAlias)->E5_NUMERO
		aItems[nPos]['parcela']		:= (cAlias)->E5_PARCELA
		aItems[nPos]['recno']		:= (cAlias)->R_E_C_N_O_
		aItems[nPos]['check']		:= oMdlCOM:SeekLine({{"RECNO", aItems[nPos]['recno']},{"NUM", aItems[nPos]['title']}}, .F., .F.)
		aItems[nPos]['key']			:= oSubModel:GetValue("E1_NUM")+oSubModel:GetValue("E1_CLIENTE")+oSubModel:GetValue("E1_LOJA")+oSubModel:GetValue("E1_PREFIXO")+oSubModel:GetValue("E1_PARCELA")
		(cAlias)->(DbSkip())
	END

	(cAlias)->(DbCloseArea())

	oExec:Destroy()
	oExec := Nil 

Return aItems

/*/{Protheus.doc} FieldPreVld
Metodo responsabe por ejecutar pre validaciones del campo.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		cAction 	,caracter	,Identificador de la acción realizada (CANSETVALUE/SETVALUE).
@param 		cId     	,caracter	,Identificador del campo ejecutado.
@param 		xValue  	,       	,Valor recibido del campo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	carlos.espinoza	
@version	12.1.2210 / Superior
@since		11/2024
/*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class F887FIN

Local oView	:= Nil 

	If cModelID == "FJT_MASTER" .And. cAction == "SETVALUE" .And. cId == "FJT_EMISSA"
		oView := FwViewActive()
		If ValType(oView) == "O"
		    //STR0017 - "Aviso"
			//STR0215 - "Verifique que las fecha de emisión y vencimiento de las formas de pago que ya registró, sean correctas de acuerdo a este cambio."
			MsgInfo(STR0215, STR0017)
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} ValidTitle
Metodo responsable de informar los impuestosL
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados de tabla SE1.
@param 		nLine		,númerico	,Linea correspondiente a la tabla SE1.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		08/2024
/*/
Method ValidTitle(oSubModel, nLine, lCheck) Class F887FIN
Local lRet		:= .T.
Local aPergAux	:= {}
Local xValPar
Local oJson
Local oFinTitSer
Local oJBoby
Local oModelFJT
Local oModel	:= FWModelActive()

Default nLine 	:= 1
Default lCheck	:= .F.

	oModelFJT := oModel:GetModel("FJT_MASTER")

	oJBoby := JsonObject():new()
	oJBoby['receipt'] := JsonObject():new()
	oJBoby['receipt']['$selected'] := lCheck
	oJBoby['receipt']['branch'] := oSubModel:GetValue("E1_FILIAL" , nLine)
	oJBoby['receipt']['billnumber'] := oSubModel:GetValue("E1_NUM" , nLine)
	oJBoby['receipt']['type'] := oSubModel:GetValue("E1_TIPO" , nLine)
	oJBoby['receipt']['actualduedt'] := DTOS(oSubModel:GetValue("E1_VENCTO" , nLine))
	oJBoby['receipt']['currency'] := oSubModel:GetValue("E1_MOEDA" , nLine)
	oJBoby['receipt']['unit'] := oSubModel:GetValue("E1_LOJA" , nLine)
	oJBoby['receipt']['installment'] := oSubModel:GetValue("E1_PARCELA" , nLine)
	oJBoby['receipt']['billvalue'] := oSubModel:GetValue("E1_VALOR" , nLine)
	oJBoby['receipt']['class'] := oSubModel:GetValue("E1_NATUREZ" , nLine)
	oJBoby['receipt']['balance'] := oSubModel:GetValue("E1_SALDO" , nLine)
	oJBoby['receipt']['prefix'] := oSubModel:GetValue("E1_PREFIXO" , nLine)
	oJBoby['receipt']['issuedt'] := DTOS(oSubModel:GetValue("E1_EMISSAO" , nLine))
	oJBoby['receipt']['discuont'] := oSubModel:GetValue("E1_DESCONT" , nLine)
	oJBoby['receipt']['interest'] := oSubModel:GetValue("E1_JUROS" , nLine)
	oJBoby['receipt']['fine'] := oSubModel:GetValue("E1_MULTA" , nLine)
	oJBoby['receipt']['origin'] := oSubModel:GetValue("E1_ORIGEM" , nLine)
	oJBoby['receipt']['client'] := oSubModel:GetValue("E1_CLIENTE" , nLine)
	oJBoby['receipt']['originbranch'] := oSubModel:GetValue("E1_FILORIG" , nLine)
	oJBoby['receipt']['recno'] := oSubModel:GetValue("RECNO" , nLine)
	oJBoby['parameters'] := JsonObject():new()
	Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T., @aPergAux)
	xValPar := MV_PAR07
	oJBoby['parameters']['mv_par07'] :=	Iif(ValType(xValPar) <> "C", "", xValPar)
	oJBoby['dateSelected'] := DTOS(oModelFJT:GetValue("FJT_EMISSA"))

	oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
	oJson := oFinTitSer:validTitleLockService(oJBoby)

	lRet := oJson["success"]
	If !lRet
		Help(NIL, NIL, "LOCK", NIL, oJson["message"], 1, 0)
	EndIf 


Return lRet

/*/{Protheus.doc} DeActivate
Metodo responsable por realizar los desbloqueos al salir del model sin hacer un commit

@type 		Method
@param 		oModel   ,objeto	,objeto del model que está siendo procesado.
@Return     Nil     
@author 	raul.medina
@version	12.1.2210 / Superior
@since		08/2024
/*/
METHOD DeActivate(oModel) CLASS F887FIN

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
        //DBUnlockAll()
	EndIf

Return Nil

/*/{Protheus.doc} ImpEnvRec
Metodo responsable de realiza realizar el llamado de la función de impresión y envío de recibos.

@type 		Method
@param 		oModel   ,objeto	,objeto del model que está siendo procesado.
@Return     Nil     
@author 	raul.medina
@version	12.1.2210 / Superior
@since		09/2024
/*/
Method ImpEnvRec(oModel) CLASS F887FIN
Local oModelFJT
Local oJData
Local aResTmp
Local cTemp		:= ""
Local nX		:= ""
Local cGet1		:= Space(99)
Local cGet2		:= Space(99)
Local lImp		:= .F.

Default oModel	:= FWModelActive()

	oModelFJT 	:= oModel:GetModel('FJT_MASTER')

	If (oModelFJT:GetValue('IMPRIMIR') .Or. oModelFJT:GetValue('EMAIL') ) .and. (!self:lCFDI .Or. self:lCompen)

		If oModelFJT:GetValue('EMAIL')
			cGet1 := IIF(ExistBlock("F998DMAIL"),Execblock("F998DMAIL",.F.,.F.,{oModelFJT:GetValue('FJT_CLIENT'),oModelFJT:GetValue("FJT_LOJA")}),PADR(Posicione("SA1",1,xFilial("SA1") + oModelFJT:GetValue('FJT_CLIENT') + oModelFJT:GetValue("FJT_LOJA"),"A1_EMAIL"), 99))
			lImp := F887GtMail(@cGet1, @cGet2)
		EndIf

		oJData := JsonObject():new()
		oJData['origin'] = "FINA998"
		oJData['imppdf'] = oModelFJT:GetValue('IMPRIMIR')
		oJData['sendemail'] = lImp
		oJData['email'] = cGet1
		oJData['emailcc'] = cGet2
		oJData['serie'] = oModelFJT:GetValue('FJT_SERIE')
		oJData['recibo'] = oModelFJT:GetValue('FJT_RECIBO')
		oJData['cliente'] = oModelFJT:GetValue('FJT_CLIENT')
		oJData['filial'] = oModelFJT:GetValue("FJT_FILIAL")
		oJData['client'] = oModelFJT:GetValue('FJT_CLIENT')

		FISA815A(oModelFJT:GetValue('FJT_RECIBO'), oModelFJT:GetValue('FJT_SERIE'),,@aResTmp,.T.,oJData)

		If Len(aResTmp)
			For nX := 1 To  LEN(aResTmp)
				cTemp += aResTmp[nX][3] + Chr(13) + Chr(10)
			Next
			MsgInfo(cTemp, "Recibo " + oModelFJT:GetValue('FJT_RECIBO'))
		EndIf

	EndIf

Return Nil

/*/{Protheus.doc} F887GtMail
Función utilizada para generar un 
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
	cGet1 - caracter - variable utilizada para obtener el código de correo al cual será enviado el recibo.
	cGet2 - caracter - variable utilizada para obtener el código de correo al cual será enviado el recibo con copia.
@Return 
/*/
Function F887GtMail(cGet1, cGet2)
Local lRet		:= .F.
Local cMsg1		:= ""
Local cMsg2		:= ""
Local cMsg3		:= ""
Local cMsg4		:= ""
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oGet1
Local oGet2
Local oModal
Local oContainer

Default cGet1	:= Space(99)
Default cGet2	:= Space(99)

	oModal := FWDialogModal():New()
	oModal:SetCloseButton( .F. )
	oModal:SetEscClose( .F. )
	oModal:setTitle(STR0192) //"Enviar por email"
	oModal:setSize(140, 280)//establece la altura y el ancho de la ventana en píxeles
	oModal:createDialog()
	oModal:addOkButton({|| lRet := .T., oModal:DeActivate()}, STR0092, , {||!Empty(cGet1)}) //"Enviar"
	oModal:AddCloseButton({|| cGet1 := "", cGet2 := "",oModal:DeActivate()}, STR0193) //"Cancelar"
	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	cMsg1 := "<b>" + i18n(STR0194) + "</b>" + i18n(STR0195) //"<b>Email registrado</b> (Obligatorio)" 
	cMsg2 := i18n(STR0196) //"Para adicionar otros emial coloque después el ',' (mail@empresa.com, mail2@empresa.com)"
	cMsg3 := "<b>" + i18n(STR0197) + "</b>" //"campos de la Tabla FJT - Encabezado del Recibo."
	cMsg4 := i18n(STR0196) //"Para adicionar otros email coloque después el ',' (mail@empresa.com, mail2@empresa.com)"
	oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,260,10,,,,,,.T.)
	oGet1 := TGet():New( 20,10, { | u | If( PCount() == 0, cGet1, cGet1 := u ) },oContainer, ;
    260, 15, "!@", {|| }, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet1",,,,  )
	oSay2 := TSay():New( 40,10,{||cMsg2 },oContainer,,,,,,.T.,,,260,10,,,,,,.T.)

	oSay3 := TSay():New( 50,10,{||cMsg3 },oContainer,,,,,,.T.,,,260,10,,,,,,.T.)
	oGet2 := TGet():New( 60, 10, { | u | If( PCount() == 0, cGet2, cGet2 := u ) },oContainer, ;
    260, 15, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet2",,,,  )
	oSay4 := TSay():New( 80,10,{||cMsg4 },oContainer,,,,,,.T.,,,260,10,,,,,,.T.)
	
	oModal:Activate()

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas del grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		10/2024
/*/
Method GridPosVld(oSubModel, cModelID) Class F887FIN
Local lRet      := .T.
Local oModel
Local oView		:= FwViewActive()

	//Usado para el calculo de execautos.
    If cModelID == "MOE_DETAIL" .and. !(ValType(oView) == "O") .and. !FwIsInCallStack("getsaveReceiptDetailService")
    	oModel := FWModelActive()
		F887ActSal(oModel)
    EndIf

Return lRet


/*/{Protheus.doc} VldConcFK5
Metodo que valida si los movimientos bancarios fueron conciliados
@type 		Method
@param 		cPrefixo,caracter,EL_PREFIXO.
@param 		cNumero,caracter,EL_NUMERO.
@param 		cParcela,caracter,EL_PARCELA.
@param 		cTipo,caracter,EL_TIPO.
@param 		cClifor,caracter,EL_CLIENTE.
@param 		cLoja,caracter,EL_LOJA.
@Return     lConc,logico,retorna si el movimiento bancario está conciliado.
@author 	carlos.espinoza	
@version	12.2.2210 / Superior
@since		02/2025
/*/                                                                   
Function VldConcFK5(cPrefixo,cNumero,cParcela,cTipo,cClifor,cLoja) 

Local aArea	     := {}
Local lConc      := .F.

Default cPrefixo := ""
Default cNumero  := ""
Default cParcela := ""
Default cTipo    := ""
Default cClifor  := ""
Default cLoja    := ""

aArea := GetArea()
dbSelectArea("SE5")
SE5->(dbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
If SE5->(MsSeek(xFilial("SE5")+;
	PadR(cPrefixo,GetSx3Cache("E5_PREFIXO","X3_TAMANHO"))+;
	PadR(cNumero,GetSx3Cache("E5_NUMERO","X3_TAMANHO"))+;
	PadR(cParcela,GetSx3Cache("E5_PARCELA","X3_TAMANHO"))+;
	PadR(cTipo,GetSx3Cache("E5_TIPO","X3_TAMANHO"))+;
	PadR(cClifor,GetSx3Cache("E5_CLIFOR","X3_TAMANHO"))+;
	PadR(cLoja,GetSx3Cache("E5_LOJA","X3_TAMANHO"))))

	FK5->(dbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
	If FK5->(MsSeek(xFilial("FK5")+SE5->E5_IDORIG))
		If !Empty(FK5->FK5_DTCONC)
			lConc := .T.
		EndIf
	EndIf
	FK5->(DbCloseArea())
EndIf

SE5->(DbCloseArea())
RestArea(aArea)

Return lConc

/*/{Protheus.doc} MexPerValid
Funcion con validaciones que comparten los países de Peru y México
@version  1
@author luis.aboytes
@since 25/2/2025
/*/
Function MexPerValid()
	Local aArea		:= GetArea()
	Local aAreaSEL	:= SEL->(GetArea())
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local lValid 	:= .T. As Logical

	DbSelectArea("SEL")
	DbSetOrder(8) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO

	IF MsSeek(xFilial("SEL")+FJT->(FJT_SERIE+FJT_RECIBO)) 
		cQuery:= FnQryCan()  //Retorna el query con la informacion del recibo a cancelar
	ENDIF
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		lValid := .F.		 
		Help(NIL, NIL, "SEL_DETAIL", NIL, STR0226, 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"Hay titulo(s) de anticipo total o parcialmente compensado(s)."
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaSEL)
	RestArea(aArea)
Return lValid


/*/{Protheus.doc} F887EDTCH
Metodo responsable por realizar la llamada de la rutina fina088 para realizar el proceso de borrado.

@type 		Method

@author 	Jose Gonzalez
@version	12.1.2210 / Superior
@since		05/07/2025 
/*/
Method F887EDTCH(oModel) Class F887FIN
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelCH 		:= oModel:GetModel('CH_DETAIL')
Local cRecibo		:= oModelFJT:GetValue("FJT_RECIBO")
Local cSerie		:= oModelFJT:GetValue("FJT_SERIE")
Local aModif		:= {}
Local aresp 		:= {}
Local lDigita 	:= IIF( oModelFJT:getValue("ASIENTO")== 1, .T. , .F. )
Local lAglutina := IIF( oModelFJT:getValue("AGRUPA" )== 1, .T. , .F. )
Local lGeraLanc := IIF( oModelFJT:getValue("ONLINE" )== 1, .T. , .F. )
Local lIsOracle := Upper(TCGetDB()) == "ORACLE"
Local oJparams := JsonObject():New()
Local aJparams := {}
Local nLine:= 1 
local lRet := .T.
For nLine:= 1 To oModelCH:Length()
	Aadd(aJparams,JsonObject():new())
	oModelCH:GoLine(nLine)
	aJparams[nLine]["numero"	]:= oModelCH:GetValue('CH_NUMERO'	)
	aJparams[nLine]["bcochq"	]:= oModelCH:GetValue('CH_BCOCHQ'	)
	aJparams[nLine]["agechq"	]:= oModelCH:GetValue('CH_AGECHQ'	)
	aJparams[nLine]["ctachq"	]:= oModelCH:GetValue('CH_CTACHQ'	)
	aJparams[nLine]["postal"	]:= oModelCH:GetValue('CH_POSTAL'	)
	aJparams[nLine]["terceir"	]:= oModelCH:GetValue('CH_TERCEIR'	)
	aJparams[nLine]["endossa"	]:= oModelCH:GetValue('CH_ENDOSSA'	)
	aJparams[nLine]["cgc"		]:= oModelCH:GetValue('CH_CGC'		)	
	aJparams[nLine]["emissao"	]:= DTOS(oModelCH:GetValue('CH_EMISSAO'	))
	aJparams[nLine]["dtvcto"	]:= DTOS(oModelCH:GetValue('CH_DTVCTO'	))
	aJparams[nLine]["seldoc"	]:= oModelCH:GetValue('CH_SELDOC'	)	
Next
oJparams['values'] := aJparams
aadd(aModif,oJParams['values'])
aadd(aModif,oModel:getValue('CH_DETAIL', 'CH_NATURE', 1 ))
Fina841(cRecibo,IIF(VAZIO(cSerie) .And. lIsOracle,SPACE(1),cSerie),.T.,aModif,@aresp,lGeraLanc,lDigita,lAglutina)

If  len(aresp)>1  .And.  !aresp[2]
	Help( ,, STR0017 ,, aresp[1] ,1, 0 )//"Aviso" 
	lRet := .F.
EndIF
Return lRet
