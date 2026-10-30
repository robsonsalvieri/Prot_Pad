#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887RETARG
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Argentina

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021
/*/
Class F887RETARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method UPDSFE()

	Method GridLinePosVld()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method New() Class F887RETARG
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method VldActivate(oModel) Class F887RETARG
Local lRet			:= .T.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method Destroy() Class F887RETARG

Return Nil

/*/{Protheus.doc} GridLinePosVld
Metodo responsable de hacer una post-validacion al modelo

@type 		Method

@param 		oModel	,objeto	, modelo de datos
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		13/05/2021 
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887RETARG
Local lRet 			:= .T.
Local cTpDoc		:= ""
local oModel        := FWModelActive() 
Local nOperation	:= oModel:GetOperation()
Local aFieldSEL		:= oModel:GetModel("SEL_DETAIL"):GetStruct():GetFields()
Local oModelFJT		:= oModel:GetModel("FJT_MASTER")
Local cCliente		:= ""
Local cLoja			:= ""
Local cCgc			:= ""
Local nTamCod		:= GetSx3Cache("A1_COD","X3_TAMANHO")
Local nTamLoja		:= GetSx3Cache("A1_LOJA","X3_TAMANHO")
Local cError := ""
	IF (cModelID == 'SEL_DETAIL') .AND. (nOperation != MODEL_OPERATION_UPDATE) .AND. (!oSubModel:GetValue("EL_TIPODOC",nLine)$"TB|RA")
		cCliente 	:= oModelFJT:GetValue('FJT_CLIENT')
		cLoja 		:= oModelFJT:GetValue("FJT_LOJA")
	
			cTpDoc := oSubModel:GetValue("EL_TIPODOC",nLine)
			If !(cTpDoc $"RI|RB|RG|RM|RS")
				If !Empty(Alltrim(oSubModel:GetValue("EL_PROVIN",nLine))) 
					cError := "EL_PROVIN ==> " + STR0050+" "+ STR0123  //Error  En la forma de pago se informó la provincia no es necesaria.
					Help( ,, "STR0050" ,"EL_PROVIN",cError ,nLine, 0 )
					lRet := .F.
				EndIf
				If lRet .AND. !Empty(Alltrim(oSubModel:GetValue("EL_CFO",nLine)))  
					cError := "EL_CFO ==> " + STR0050+" "+STR0124 //Error  En la forma de pago se informó eL código fiscal no es necesario.
					Help( ,, "STR0050" ,"EL_CFO",cError ,nLine, 0 )
					lRet := .F.	
				EndIf
				If lRet .AND. !Empty(oSubModel:GetValue("EL_VALBASE",nLine))  
					cError := "EL_VALBASE ==> " + STR0050+" "+STR0125 //Error  En la forma de pago se informó el Valor base, no es necesario.
					Help( ,, "STR0050" ,"EL_VALBASE",cError ,nLine, 0 )
					lRet := .F.	
				EndIf
				If lRet .AND. !Empty(oSubModel:GetValue("EL_ALIQ",nLine))
					cError := "EL_ALIQ ==> " + STR0050+" "+STR0126  //Error  En la forma de pago se informó la alicuota, no es necesario.
					Help( ,, "STR0050" ,"EL_ALIQ",cError ,nLine, 0 )
					lRet := .F.	
				EndIf
			EndIf
			If cTpDoc $ ("RB|RI|RG|RS|RM")
				If oSubModel:GetValue("EL_VALOR",nLine) > 0 .And. oSubModel:GetValue("EL_VALBASE",nLine) == 0 
					cError := "EL_VALBASE ==> " + STR0050+" "+STR0063 +" "+STR0064 //Error Base de la retención no informada. Informar base de la retención.
					Help( ,, "STR0050" ,"EL_VALBASE",cError ,nLine, 0 )
					lRet := .F.
				ElseIf oSubModel:GetValue("EL_VALOR",nLine) > 0 .And. oSubModel:GetValue("EL_ALIQ",nLine) == 0
					cError := "EL_ALIQ ==> " + STR0050+" "+STR0061 +" "+STR0062 //Error Alicuota de la retención no informada. Informar alicuota de la retención.
					Help( ,, "STR0050" ,"EL_ALIQ",cError ,nLine, 0 )
					lRet := .F.
				EndIf
				If cTpDoc == "RB" .And. lRet
					
					If lRet .AND. Empty(Alltrim(oSubModel:GetValue("EL_CFO",nLine))) 
						cError := "EL_CFO ==> " + STR0050+" "+STR0053 +" "+STR0054 //Error Código fiscal vacio. Informar el código fiscal.
						Help( ,, "STR0050" ,"EL_CFO",cError ,nLine, 0 )
						lRet := .F.	
					EndIf
					If lRet .AND. Empty(Alltrim(oSubModel:GetValue("EL_PROVIN",nLine))) 
						cError := "EL_PROVIN ==> " + STR0050+" "+ STR0122  //Error En la forma de pago tipo retencion, debe informar la provincia.
						Help( ,, "STR0050" ,"EL_PROVIN",cError ,nLine, 0 )
						lRet := .F.
					EndIf
				ElseIf cTpDoc == "RI" .And. lRet
					If Empty(Alltrim(oSubModel:GetValue("EL_CFO",nLine))) 
						cError := "EL_CFO ==> " + STR0050+" "+STR0053 +" "+STR0054 //Error Código fiscal vacio. Informar el código fiscal.
						Help( ,, "STR0050" ,"EL_CFO",cError ,nLine, 0 )
						lRet := .F.	
					EndIf
				ElseIf cTpDoc == "RG" .And. lRet
					If Empty(Alltrim(oSubModel:GetValue("EL_CFO",nLine))) 
						cError := "EL_CFO ==> " + STR0050+" "+STR0053 +" "+STR0054 //Error Código fiscal vacio. Informar el código fiscal.
						Help( ,, "STR0050" ,"EL_CFO",cError ,nLine, 0 )
						lRet := .F.	
					EndIf
					If lRet .AND. aScanx(aFieldSEL,{|x|x[3] == ALLTRIM("EL_AGREGAN")}) > 0  .AND. Empty(Alltrim(oSubModel:GetValue("EL_AGREGAN",nLine))) 
						cError := "EL_AGREGAN ==> " + STR0050+" "+STR0055 +" "+STR0056 // Error-Act. para Ret. de Ganancias vacio. - Informar Act. para Ret. de Ganancias.
						Help( ,, "STR0050","EL_AGREGAN",cError,nLine, 0 )
						lRet := .F.	
					ELSEIF lRet .AND. aScanx(aFieldSEL,{|x|x[3] == ALLTRIM("EL_AGREGAN")}) == 0 
						Help( ,, "STR0050","EL_AGREGAN",/*STR0129*/"Configure el campo Act. para retención de IG (EL_AGREGAN) en el módulo configurador para poder continuar con el proceso",nLine, 0 )//Configure el campo Act. para retención de IG (EL_AGREGAN) en el módulo configurador para poder continuar con el proceso
						lRet := .F.	
					ENDIF
				ElseIf cTpDoc == "RS" .And. lRet
					If lRet .AND. aScanx(aFieldSEL,{|x|x[3] == ALLTRIM("EL_CONCSUS")}) > 0  .AND. Empty(Alltrim(oSubModel:GetValue("EL_CONCSUS",nLine))) 
						cError := "EL_CONCSUS ==> " + STR0050+" "+STR0057 +" "+STR0058 // Error - Concepto SUSS vacio. - Informar concepto SUSS.
						Help( ,, "STR0050","EL_CONCSUS",cError,nLine, 0 )  
						lRet := .F.	
					ELSEIF lRet .AND. aScanx(aFieldSEL,{|x|x[3] == ALLTRIM("EL_CONCSUS")}) == 0 
						Help( ,, "STR0050","EL_CONCSUS",/*STR0130*/"Configure el campo Concepto de SUSS (EL_CONCSUS) en el módulo configurador para poder continuar con el proceso",nLine, 0 )//Configure el campo Concepto de SUSS (EL_CONCSUS) en el módulo configurador para poder continuar con el proceso
						lRet := .F.	
					ENDIF
					IF lRet .AND.Empty(Alltrim(oSubModel:GetValue("EL_SIRESEG",nLine)))
						Help( ,, STR0050,,STR0067+" "+STR0068,1, 0 )  // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
						lRet := .F.
					ENDIF
					If lRet .AND. Len(Alltrim(oSubModel:GetValue("EL_SIRECER",nLine))) < 25
						Help( ,, STR0050,,STR0065+" "+STR0066,1, 0 ) // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
						lRet := .F.
					Else 
						cCgc := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+PadR(cCliente,nTamCod)+PadR(cLoja,nTamLoja),1,"")
						If lRet .and. !(AllTrim(cCgc) $ Alltrim(oSubModel:GetValue("EL_SIRECER",nLine)))
							Help( ,, STR0050,,STR0065+" "+STR0066,1, 0 )  // Error - Código de seguridad del SIRE no valido. - Informe un código de seguridad del SIRE valido.
							lRet := .F.
						EndIf
					EndIf
				ElseIf cTpDoc == "RM" .And. lRet
					If Empty(Alltrim(oSubModel:GetValue("EL_CFO",nLine))) 
						cError := "EL_CFO ==> " + STR0050+" "+STR0053 +" "+STR0054 //Error Código fiscal vacio. Informar el código fiscal.
						Help( ,, "STR0050" ,"EL_CFO",cError ,nLine, 0 )
						lRet := .F.
					EndIf
					If lRet .AND. Empty(Alltrim(oSubModel:GetValue("EL_PROVIN",nLine))) 
						cError := "EL_PROVIN ==> " + STR0050+" "+ STR0122  //Error En la forma de pago tipo retencion, debe informar la provincia.
						Help( ,, "STR0050" ,"EL_PROVIN",cError ,nLine, 0 )
						lRet := .F. 
					EndIf
					If lRet .AND. SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
						If Empty(Alltrim(oSubModel:GetValue("EL_RET_MUN",nLine))) 
							Help( ,, STR0050,,STR0059+" "+STR0060,1, 0 ) //Error - Cod. Ret. municipal vacio. Informar Cod. ret. municipal.
							lRet := .F.
						EndIf
					ENDIF
				EndIf
			EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887RETARG

Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887RETARG
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSFE(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDSFE
Metodo responsable por ejecutar reglas de negocio de Retenciones 
para la localización de Argentina

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/05/2021 
/*/
Method UPDSFE(oModel) Class F887RETARG
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local nX			:= 0

	SE1->(DbSetorder(1))
	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) $ "RS|RL|RB|RI|RG|RM" .and. oModelSEL:GetValue("EL_TRANSIT",nX)  == "2"
			//Valor retención mayor a 0
			If oModelSEL:GetValue("EL_VALOR",nX) > 0 .Or.;
				(SE1->(MsSeek(xFilial("SE1") + oModelSEL:GetValue("EL_PROVIN",nX) + oModelSEL:GetValue("EL_CFO",nX) + STR(oModelSEL:GetValue("EL_VALBASE",nX)) + STR(oModelSEL:GetValue("EL_ALIQ",nX)) )))
				RecLock("SFE",.T.)
					FE_FILIAL   := xFilial('SFE')   
					FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO",nX) //Verificar para RI
					FE_CLIENTE  := oModelSEL:GetValue("EL_CLIENTE",nX)
					FE_LOJCLI 	:= oModelSEL:GetValue("EL_LOJA",nX)
					FE_EST 		:= oModelSEL:GetValue("EL_PROVIN",nX)
					FE_CFO	 	:= oModelSEL:GetValue("EL_CFO",nX)
					FE_VALBASE 	:= oModelSEL:GetValue("EL_VALBASE",nX)
					FE_ALIQ		:= oModelSEL:GetValue("EL_ALIQ",nX)
					FE_RETENC 	:= oModelSEL:GetValue("EL_VALOR",nX)
					FE_RECIBO   := oModelSEL:GetValue("EL_RECIBO",nX)
					FE_NROCERT	:= oModelSEL:GetValue("EL_NUMERO",nX)
					FE_SERIE 	:= oModelSEL:GetValue("EL_SERIE",nX) 
					If oModelSEL:GetValue("EL_TIPODOC",nX) == "RB"
						FE_TIPO   	:= "B"
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RM"
						FE_TIPO   	:= "M"
						FE_RET_MUN	:= oModelSEL:GetValue("EL_RET_MUN",nX)
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) $ "RI|RS"
						IF oModelSEL:GetValue("EL_TIPODOC",nX) = 'RI'
							FE_TIPO   	:= "I"
						EndIf
						IF oModelSEL:GetValue("EL_TIPODOC",nX) = 'RS'
							FE_TIPO   	:= "S"
							FE_CONCEPT	:= oModelSEL:GetValue("EL_CONCSUS",nX)
						EndIf
						If SFE->(ColumnPos("FE_SIRECER")) > 0
							FE_SIRECER := oModelSEL:GetValue("EL_SIRECER",nX)
						EndIf
						If SFE->(ColumnPos("FE_SIRESEG")) > 0
							FE_SIRESEG := oModelSEL:GetValue("EL_SIRESEG",nX)
						EndIf
					ElseIf oModelSEL:GetValue("EL_TIPODOC",nX) == "RG"
						FE_TIPO   	:= "G"
						FE_CONCEPT 	:= oModelSEL:GetValue("EL_AGREGAN",nX)
					EndIf 
				MsUnlock()
			EndIf
		EndIf
	Next nX

Return Nil
