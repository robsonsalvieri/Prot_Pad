#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999DIFCAM
	Clase responsable por el evento de reglas de negocio de diferencia de cambio en orden de pago
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999DIFCAM From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method InTTS()

	Method F999GRVMDL()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999DIFCAM
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@param 		oModel - objeto	  - Modelo de datos.
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999DIFCAM
Local lRet			:= .T.

Return lRet

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
Method InTTS(oModel, cModelId) Class F999DIFCAM
Local nOperation	:= oModel:GetOperation()
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		self:F999GRVMDL(oModel)
	ENDIF

Return Nil

/*/{Protheus.doc} F999GRVMDL
Metodo responsable por realizar las actualizaciones de las tablas por el modelo FINA999
@type 		Method
@param 		oModel - objeto - Modelo de datos FINA999
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		13/11/2025 
/*/
Method F999GRVMDL(oModel) Class F999DIFCAM
Local oModelSE2 	:= oModel:GetModel('SE2_DETAIL')
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX 			:= 0
Local nLine 		:= 0
Local cJCotiz		:= oModelEOP:GetValue("COTIZ")
Local oJCotiz 		:= JsonObject():New()
Local nMoedaCor		:= Val(Subs(SuperGetMv("MV_MDCFIN",.F.,""), 1, 2))
Local lExecDifC		:= !Empty(SuperGetMv("MV_MOEDA" + Alltrim(Str(nMoedaCor)),.F.,""))
Local aAreaSE2		:= {}
Local lPerDifCam    := .F.
Local aArea			:= {}
Local lTemMon 		:= nMoedaCor > 0
Local lExecAut		:= .F.
Local cMoeda		:= ""
Local cFilActual	:= ""
Local lGeraDCam		:= SuperGetMv("MV_DIFCAMP",.F.,"N") == "S"
Local nMoedaTit		:= 0

	oJCotiz:FromJson(cJCotiz)

	lGeraDCam := lGeraDCam .And. oJCotiz['TipoCotiz'] == 1

	lPerDifCam := lGeraDCam .And. lTemMon .And. !oModelEOP:GetValue("PA")

	If lPerDifCam
		Pergunte("FIN84A",.F.)
		SetMVValue("FIN84A","MV_PAR01",0)
		SetMVValue("FIN84A","MV_PAR07",2)
		SetMVValue("FIN84A","MV_PAR08",1)
	EndIf

	For nX := 1 To oModelFJR:Length()
		nLine := 0
		oModelFJR:GoLine(nX)

		If oModelFJR:GetValue("MARK") <> 1
			Loop
		EndIf

		//Posicionamiento en cada título financiero para generación de diferencia de cambio
		If !Empty(oModelFJR:GetValue("FJR_ORDPAG")) .And. oModelSE2:SeekLine({{"E2_ORDPAGO", oModelFJR:GetValue("FJR_ORDPAG")}}, .F., .T.) 
			nLine := oModelSE2:GetLine()
			While nLine <= oModelSE2:Length() .And. oModelFJR:GetValue("FJR_ORDPAG") == oModelSE2:GetValue("E2_ORDPAGO")

				DbSelectArea("SE2")
				aAreaSE2 :=	SE2->(GetArea())

				#IFDEF TOP
					SE2->(DbClearFilter())
				#ENDIF

				If oModelSE2:GetValue("RECNO") > 0 .And. lPerDifCam
					SE2->(MsGoTo(oModelSE2:GetValue("RECNO")))
					If SE2->E2_CONVERT <> 'N' .And. SE2->E2_NUM == oModelSE2:GetValue("E2_NUM")
						lExecAut := .F.
						aArea := GetArea()
						If !Empty(nMoedaCor) .And. lExecDifC .And. SE2->E2_MOEDA <> nMoedaCor
							SetMVValue("FIN84A","MV_PAR11",nMoedaCor)
							cMoeda 	  := oModelSE2:GetValue("E2_MOEDA")
							nMoedaTit := oModelMOE:GetValue("TASA", cMoeda)
							If SE2->E2_TXMOEDA != nMoedaTit
								cFilActual  := cFilAnt
								cFilAnt 	:= SE2->E2_FILORIG
								FA084GDif(.F.,,,.T.)
								cFilAnt 	:= cFilActual		
								lExecAut 	:= .T.				
							EndIf
						EndIf
						RestArea(aArea)

						If lExecAut
							Begin Transaction
								RecLock('SE2',.F.)
								SE2->E2_DTDIFCA := dDataBase
								SE2->(MsUnLock())
							End Transaction
						EndIf
					EndIf
				EndIf

				RestArea(aAreaSE2)

				nLine++
				If nLine <= oModelSE2:Length()
					oModelSE2:GoLine(nLine)
				EndIf
			EndDo
		EndIf
	Next

Return Nil
