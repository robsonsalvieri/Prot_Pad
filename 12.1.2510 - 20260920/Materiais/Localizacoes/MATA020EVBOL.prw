#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVBOL
Eventos del MVC para BOLIVIA, cualquier regla que se aplique solamente para BOLIVIA 
debe ser creada aquí, Si es una regla general, debe estar en MATA020EVDEF.

Todas las validaciones de modelo, línea, pre y post, así como todas las interacciones con la grabación, 
están definidas en esta clase

Importante: Use solamente la función Help para mostrar mensajes al usuario, ya que solo el help 
es tratado por el MVC.

Documentación sobre eventos del MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
CLASS MATA020EVBOL From FWModelEvent

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe MATA020EVBOL.
Solamente hereda el comportamiento estandar de FWModelEvent.

@type metodo
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
METHOD New() CLASS MATA020EVBOL
Return

/*/{Protheus.doc} ModelPosVld
Ejecuta la validación del modelo antes de realizar la grabación de los datos
Si devuelve falso, no permite grabar.

@type metodo
 
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVBOL
	Local lValid := .T.
	Local nOpc

	nOpc := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_INSERT
		lValid  := A020ValB(oModel)
	EndIf

Return lValid

/*/{Protheus.doc} A020ValB
Valida la duplicidad de NIT (A2_CGC) en el registro de proveedores para Bolivia.

En Bolivia, las empresas pueden tener Casa Matriz y sucursales con el mismo NIT, siempre que
compartan el mismo código de proveedor (A2_COD). El comportamiento al detectar
un NIT duplicado en proveedores distintos es controlado por el parámetro MV_NITVLD:
  1 - Permite automáticamente (sin mensaje) - Predeterminado
  2 - No permite, bloquea el registro
  3 - Advertencia, el usuario decide si desea continuar

@type  Function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
@param oModel, Objeto , eventos do MVC
@return lRet, lógico, .T. si la grabación puede continuar
/*/
Function A020ValB(oModel)
	Local lRet     := .T.
	Local lFound   := .F.
	Local cCodForn := ""
	Local cLojForn := ""
	Local aArea    := GetArea()
	Local cParam   := SuperGetMV("MV_NITVLD", .F., "1")
	Local oView    := FwViewActive()

	Default oModel := FWModelActive()

	If cParam != '1'
		DbSelectArea("SA2")
		DbSetOrder(3)
		If !Empty(M->A2_CGC) .And. MsSeek(xFilial("SA2")+M->A2_CGC)
			While !Eof() .And. xFilial("SA2")+M->A2_CGC == SA2->A2_FILIAL+SA2->A2_CGC .And. !lFound
				If M->A2_COD == SA2->A2_COD
					DbSkip()
					Loop
				EndIf
				lFound   := .T.
				cCodForn := SA2->A2_COD
				cLojForn := SA2->A2_LOJA
			End
		EndIf

		If lFound
			Do Case
			Case cParam == '3'
				If ValType(oView) == "O"
					lRet := MsgYesNo(STR0116 + " " + cCodForn +" "+ STR0045+": " + cLojForn +". "+STR0117, "A020ValB")
					if !lRet
						oModel:SetErrorMessage (,,,,STR0118,STR0119,STR0120)
					endif
				EndIf
			Otherwise
				Help(" ",1,"A020ValB", ,STR0121,1,0,,,,,,)
				lRet := .F.
			EndCase
		EndIf

	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)

Return(lRet)
