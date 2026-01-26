#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWLIBVERSION.CH'
#include 'LOCXEQU.CH'

#Define SnTipo      1
#Define SAliasHead  4
#Define ScEspecie   8

#DEFINE IT_DELETED		 22     //Flag de controle para itens deletados
#DEFINE IT_ALIQIMP		 29	    //Array contendo as Aliquotas de Impostos Variaveis
#DEFINE IT_VALIMP		 30     //Array contendo os valores de Impostos Agentina/Chile/Etc.

/*/{Protheus.doc} LxCposEqu
Funcion utilizada para agregar campos al encabezado de
Notas Fiscales para el país Ecuador.
@type Function
@author luis.enriquez
@since 17/05/2021
@version 1.1
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param aCfgNf, Character, Arreglo con configuraciones de Nota Fiscal
@example LxCposEqu(aCposNF, cFunName, aCfgNf)
@return aCposNF, Array, Campos para el Encabezado de Notas Fiscales.
@see (links_or_references)
/*/
Function LxCposEqu(aCposNF, cFunName, aCfgNf)
	Local aSX3    := {}
	Local cTipDoc := StrZero(aCfgNf[SnTipo],2)
	Local cWhen   := ""
	
    If aCfgNf[SAliasHead] == "SF1"
		If cTipDoc $ "04|10|09"
			//Establecimiento
			If SF1->(ColumnPos( "F1_ESTABL" )) > 0
				aSX3 := LxSX3Equ("F1_ESTABL")				
				AAdd(aCposNF,{FWX3Titulo("F1_ESTABL"),"F1_ESTABL",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Punto de Emisión
			If SF1->(ColumnPos( "F1_PTOEMIS" )) > 0
				aSX3 := LxSX3Equ("F1_PTOEMIS")
				AAdd(aCposNF,{FWX3Titulo("F1_PTOEMIS"),"F1_PTOEMIS",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			If cTipDoc == "10"
				//Tipo de Comprobante
				If SF1->(ColumnPos( "F1_TIPOPE" )) > 0
					aSX3 := LxSX3Equ("F1_TIPOPE")
					AAdd(aCposNF,{FWX3Titulo("F1_TIPOPE"),"F1_TIPOPE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
				EndIf

				//Código de Sustento
				If SF1->(ColumnPos( "F1_CODCTR" )) > 0
					aSX3 := LxSX3Equ("F1_CODCTR")
					AAdd(aCposNF,{FWX3Titulo("F1_CODCTR"),"F1_CODCTR",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
				EndIf
			EndIf
		Elseif cTipDoc $ "51"
			//Establecimiento
			If SF1->(ColumnPos( "F1_ESTABL" )) > 0
				aSX3 := LxSX3Equ("F1_ESTABL")				
				AAdd(aCposNF,{FWX3Titulo("F1_ESTABL"),"F1_ESTABL",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8],".F."})
			EndIf
			//Punto de Emisión
			If SF1->(ColumnPos( "F1_PTOEMIS" )) > 0
				aSX3 := LxSX3Equ("F1_PTOEMIS")
				AAdd(aCposNF,{FWX3Titulo("F1_PTOEMIS"),"F1_PTOEMIS",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8],".F."})
			EndIf
			//Serie Documento Sustento - Guía de Remisión
			If SF1->(ColumnPos("F1_SERMAN")) > 0
				aSX3 := LxSX3Equ("F1_SERMAN")
				AAdd(aCposNF,{FWX3Titulo("F1_SERMAN"),"F1_SERMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Documento Sustento - Guía de Remisión
			If SF1->(ColumnPos("F1_DOCMAN")) > 0
				aSX3 := LxSX3Equ("F1_DOCMAN") 
				AAdd(aCposNF,{FWX3Titulo("F1_DOCMAN"),"F1_DOCMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Vehículo del traslado - Guía de Remisión
			If SF1->(ColumnPos("F1_VEICUL1")) > 0
				aSX3 := LxSX3Equ("F1_VEICUL1")
				AAdd(aCposNF,{FWX3Titulo("F1_VEICUL1"),"F1_VEICUL1",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Fecha de inicio de traslado - Guía de Remisión
			If SF1->(ColumnPos("F1_FECDSE")) > 0
			aSX3 := LxSX3Equ("F1_FECDSE")
				AAdd(aCposNF,{FWX3Titulo("F1_FECDSE"),"F1_FECDSE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Fecha Entrega/Fin - Guía de Remisión
			If SF1->(ColumnPos("F1_FECANTF")) > 0
				aSX3 := LxSX3Equ("F1_FECANTF")
				AAdd(aCposNF,{FWX3Titulo("F1_FECANTF"),"F1_FECANTF",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Transportadora - Guía de Remisión
			If SF1->(ColumnPos("F1_TRANSP")) > 0
				aSX3 := LxSX3Equ("F1_TRANSP")
				AAdd(aCposNF,{FWX3Titulo("F1_TRANSP"),"F1_TRANSP",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Motivo de Traslado - Guía de Remisión
			If SF1->(ColumnPos("F1_OBS")) > 0
				aSX3 := LxSX3Equ("F1_OBS")
				AAdd(aCposNF,{FWX3Titulo("F1_OBS"),"F1_OBS",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Ruta Traslado - Guía de Remisión
			If SF1->(ColumnPos("F1_RUTDOC")) > 0
				aSX3 := LxSX3Equ("F1_RUTDOC") 
				AAdd(aCposNF,{FWX3Titulo("F1_RUTDOC"),"F1_RUTDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
		EndIf
	ElseIf aCfgNf[SAliasHead] == "SF2"
		If cTipDoc$"01|03|05|07|09|10|11|12|13|14|02"
			//Número de autorización
			If !(cTipDoc$"02") .And. SF2->(ColumnPos( "F2_NUMAUT" )) > 0
				aSX3 := LxSX3Equ("F2_NUMAUT")
				AAdd(aCposNF,{FWX3Titulo("F2_NUMAUT"),"F2_NUMAUT",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
			EndIf
			
			If cTipDoc $ "01|02|07"
				cWhen := IIf(cTipDoc $ "02|07", ".T.", ".F.")
				//Punto de Emisión
				If SF2->(ColumnPos( "F2_PTOEMIS" )) > 0
					aSX3 := LxSX3Equ("F2_PTOEMIS")
					AAdd(aCposNF,{FWX3Titulo("F2_PTOEMIS"),"F2_PTOEMIS",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8], cWhen})
				EndIf

				//Establecimiento
				If SF2->(ColumnPos( "F2_ESTABL" )) > 0
					aSX3 := LxSX3Equ("F2_ESTABL")
					AAdd(aCposNF,{FWX3Titulo("F2_ESTABL"),"F2_ESTABL",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8], cWhen})
				EndIf
			EndIf

			If cTipDoc $ "01"
				//Indica si es una Liquidación de Compra
				If SF2->(ColumnPos( "F2_TPVENT" )) > 0 .And. StrZero(aCfgNf[SnTipo],2) == "01"
					aSX3 := LxSX3Equ("F2_TPVENT")
					AAdd(aCposNF,{FWX3Titulo("F2_TPVENT"),"F2_TPVENT",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf

				//Tipo de Comprobante
				If SF2->(ColumnPos( "F2_TIPOPE" )) > 0
					aSX3 := LxSX3Equ("F2_TIPOPE")
					AAdd(aCposNF,{FWX3Titulo("F2_TIPOPE"),"F2_TIPOPE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf

				//Código del Sustento
				If SF2->(ColumnPos( "F2_CODCTR " )) > 0
					aSX3 := LxSX3Equ("F2_CODCTR ")
					AAdd(aCposNF,{FWX3Titulo("F2_CODCTR "),"F2_CODCTR ",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf

				//Tipo de Reembolso
				If SF2->(ColumnPos( "F2_TPDOC" )) > 0
					aSX3 := LxSX3Equ("F2_TPDOC")
					AAdd(aCposNF,{FWX3Titulo("F2_TPDOC"),"F2_TPDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf

				//Exportaciones
				If SF2->(ColumnPos( "F2_TPACTIV" )) > 0
					aSX3 := LxSX3Equ("F2_TPACTIV")//Exportación Si/No
					AAdd(aCposNF,{FWX3Titulo("F2_TPACTIV"),"F2_TPACTIV",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_REGIME" )) > 0
					aSX3 := LxSX3Equ("F2_REGIME")//Tipo Exportación
					AAdd(aCposNF,{FWX3Titulo("F2_REGIME"),"F2_REGIME",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_MUNDESC" )) > 0
					aSX3 := LxSX3Equ("F2_MUNDESC")
					AAdd(aCposNF,{FWX3Titulo("F2_MUNDESC"),"F2_MUNDESC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_CMUNDE" )) > 0
					aSX3 := LxSX3Equ("F2_CMUNDE")
					AAdd(aCposNF,{FWX3Titulo("F2_CMUNDE"),"F2_CMUNDE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_DOCMAN" )) > 0
					aSX3 := LxSX3Equ("F2_DOCMAN")
					AAdd(aCposNF,{FWX3Titulo("F2_DOCMAN"),"F2_DOCMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_LTRAN" )) > 0
					aSX3 := LxSX3Equ("F2_LTRAN")
					AAdd(aCposNF,{FWX3Titulo("F2_LTRAN"),"F2_LTRAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_TPRENTA" )) > 0
					aSX3 := LxSX3Equ("F2_TPRENTA")//Tipo Ingreso Exterior
					AAdd(aCposNF,{FWX3Titulo("F2_TPRENTA"),"F2_TPRENTA",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_EXPCONF" )) > 0
					aSX3 := LxSX3Equ("F2_EXPCONF")//Ingreso Exterior Gravado
					AAdd(aCposNF,{FWX3Titulo("F2_EXPCONF"),"F2_EXPCONF",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_VALIMPD" )) > 0
					aSX3 := LxSX3Equ("F2_VALIMPD")//Valor IMpuesto Renta
					AAdd(aCposNF,{FWX3Titulo("F2_VALIMPD"),"F2_VALIMPD",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_TCOMP" )) > 0 
					aSX3 := LxSX3Equ("F2_TCOMP")//Tipo COmprobante
					AAdd(aCposNF,{FWX3Titulo("F2_TCOMP"),"F2_TCOMP",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				If SF2->(ColumnPos( "F2_FECHSE" )) > 0	
					aSX3 := LxSX3Equ("F2_FECHSE")//Fecha Registro Contable
					AAdd(aCposNF,{FWX3Titulo("F2_FECHSE"),"F2_FECHSE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
			EndIf
		ElseIf cTipDoc $ "50|54|61"
				//Punto de Emisión
				If SF2->(ColumnPos( "F2_PTOEMIS" )) > 0
					aSX3 := LxSX3Equ("F2_PTOEMIS")
					AAdd(aCposNF,{FWX3Titulo("F2_PTOEMIS"),"F2_PTOEMIS",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8], ".F."})
				EndIf
				//Establecimiento
				If SF2->(ColumnPos( "F2_ESTABL" )) > 0
					aSX3 := LxSX3Equ("F2_ESTABL")
					AAdd(aCposNF,{FWX3Titulo("F2_ESTABL"),"F2_ESTABL",aSX3[1]   ,aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8], ".F."})
				EndIf
				//Serie Documento Sustento - Guía de Remisión
				If SF2->(ColumnPos("F2_SERMAN")) > 0
					aSX3 := LxSX3Equ("F2_SERMAN")
					AAdd(aCposNF,{FWX3Titulo("F2_SERMAN"),"F2_SERMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Documento Sustento - Guía de Remisión
				If SF2->(ColumnPos("F2_NFAGREG")) > 0
					aSX3 := LxSX3Equ("F2_NFAGREG") 
					AAdd(aCposNF,{FWX3Titulo("F2_NFAGREG"),"F2_NFAGREG",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Vehículo del traslado - Guía de Remisión
				If SF2->(ColumnPos("F2_VEICULO")) > 0
					aSX3 := LxSX3Equ("F2_VEICULO")
					AAdd(aCposNF,{FWX3Titulo("F2_VEICULO"),"F2_VEICULO",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Fecha de inicio de traslado - Guía de Remisión
				If SF2->(ColumnPos("F2_FECDSE")) > 0
					aSX3 := LxSX3Equ("F2_FECDSE")
					AAdd(aCposNF,{FWX3Titulo("F2_FECDSE"),"F2_FECDSE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Fecha Entrega/Fin - Guía de Remisión
				If SF2->(ColumnPos("F2_FECANTF")) > 0
					aSX3 := LxSX3Equ("F2_FECANTF")
					AAdd(aCposNF,{FWX3Titulo("F2_FECANTF"),"F2_FECANTF",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Transportadora - Guía de Remisión
				If SF2->(ColumnPos("F2_TRANSP")) > 0
					aSX3 := LxSX3Equ("F2_TRANSP")
					AAdd(aCposNF,{FWX3Titulo("F2_TRANSP"),"F2_TRANSP",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Motivo de Traslado - Guía de Remisión
				If SF2->(ColumnPos("F2_OBS")) > 0
					aSX3 := LxSX3Equ("F2_OBS")
					AAdd(aCposNF,{FWX3Titulo("F2_OBS"),"F2_OBS",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
				//Ruta Traslado - Guía de Remisión
				If SF2->(ColumnPos("F2_RUTDOC")) > 0
					aSX3 := LxSX3Equ("F2_RUTDOC") 
					AAdd(aCposNF,{FWX3Titulo("F2_RUTDOC"),"F2_RUTDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
				EndIf
		EndIf
	EndIf
Return aCposNF

/*/{Protheus.doc} LxSX3Equ
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author luis.enriquez
@since 17/05/2021
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Static Function LxSX3Equ(cCampo)
	Local aSX3Cpos := {}
	
	Default cCampo := "" 
	
	If !Empty(cCampo)
		aSX3Cpos := {GetSX3Cache(cCampo,"X3_PICTURE"), ; //1
		GetSX3Cache(cCampo,"X3_TAMANHO"), ; //2
		GetSX3Cache(cCampo,"X3_DECIMAL"), ; //3
		GetSX3Cache(cCampo,"X3_VALID"), ;   //4
		GetSX3Cache(cCampo,"X3_USADO"), ;   //5
		GetSX3Cache(cCampo,"X3_TIPO"), ;    //6
		GetSX3Cache(cCampo,"X3_CONTEXT"), ; //7
		GetSX3Cache(cCampo,"X3_F3")}        //8
	EndIf
Return aSX3Cpos

/*/{Protheus.doc} LxMetReem
Metríca para verificar la cantidad de Carta Porte registrados en un mes.
@type
@author Alfredo.Medrano
@since 21/09/2021
@version 1.0
@example
LxMetReem()
@see (links_or_references)
/*/
Function LxMetReem(cRotina)
	Local cIdMetric	  := ""
	Local cSubRoutine := ""
	Local lMetVal     := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Local cAutomato   := IIf(GetRemoteType() == 5 .OR. IsBlind(), "_auto", "") //Si es ejecución automática con TIR agrega identificador

	If lMetVal
		cSubRoutine :=  "Factura_Reembolso" + cAutomato
		cIdMetric	:= "faturamento-protheus_cantidad-reembolsos-registrados-por-empresa_total"
		FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, 1, /*dDate*/, /*nLapTime*/,cRotina)
	EndIf

Return Nil

/*/{Protheus.doc} LxEquNFExp
Valida que los campos para generacion de documentos de tipo exportación hayan sido informados
de manera correcta.
@type function
@author oscar.lopez
@since 07/11/2021
@version 1.0
@example
LxEquNFExp()
/*/
Function LxEquNFExp()
	Local lRet	:= .T.
	Local lAuto	:= IsBlind()

	If !lAuto
	  	If SF2->(ColumnPos( "F2_TPACTIV" )) > 0 .And. M->F2_TPACTIV == 'S'
		  	If SF2->(ColumnPos( "F2_REGIME" )) > 0
				If Empty(M->F2_REGIME)
					Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_REGIME")) + " (F2_REGIME)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
					lRet := .F.
				Else
					If M->F2_REGIME == '03'
						If lRet .And. SF2->(ColumnPos( "F2_TPRENTA" )) > 0 .And. Empty(M->F2_TPRENTA)
							Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_TPRENTA")) + " (F2_TPRENTA)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
							lRet := .F.
						EndIf
					ElseIf M->F2_REGIME == '01'
						If lRet .And. SF2->(ColumnPos( "F2_MUNDESC" )) > 0 .And. Empty(M->F2_MUNDESC)
							Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_MUNDESC")) + " (F2_MUNDESC)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
							lRet := .F.
						EndIf
						If lRet .And. SF2->(ColumnPos( "F2_CMUNDE" )) > 0 .And. Empty(M->F2_CMUNDE)
							Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_CMUNDE")) + " (F2_CMUNDE)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
							lRet := .F.
						EndIf
						If lRet .And. SF2->(ColumnPos( "F2_DOCMAN" )) > 0 .And. Empty(M->F2_DOCMAN)
							Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_DOCMAN")) + " (F2_DOCMAN)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
							lRet := .F.
						EndIf
						If lRet .And. SF2->(ColumnPos( "F2_LTRAN" )) > 0 .And. Empty(M->F2_LTRAN)
							Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_LTRAN")) + " (F2_LTRAN)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
			If lRet .And. SF2->(ColumnPos( "F2_TCOMP" )) > 0 .And. Empty(M->F2_TCOMP)
				Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_TCOMP")) + " (F2_TCOMP)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
				lRet := .F.
			EndIf
			If lRet .And. SF2->(ColumnPos( "F2_FECHSE" )) > 0 .And. Empty(M->F2_FECHSE)
				Aviso(STR0001, STR0002 + Alltrim(FWX3Titulo("F2_FECHSE")) + " (F2_FECHSE)" + STR0003, {STR0004}) //"Aviso" ## "El campo" ## " debe ser informado." ## "OK"
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LxEquCExp
Vacia los campos de exportación si se actualizan los campos F2/C5_TPACTIV, F2/C5_REGIME o F2/C5_EXPCONF.
@type function
@author oscar.lopez
@since 07/11/2021
@version 1.0
@param cCpoVal, caracter, Indica si se esta modificando un campo en captura de Factura de Venta o Pedido de Venta.
@return True
@example
LxEquCExp(cCpoVal)
/*/
Function LxEquCExp(cCpoVal)
	If cCpoVal == 'SF2'
		If M->F2_TPACTIV == 'N'
			M->F2_REGIME	:= Space(TamSX3('F2_REGIME')[1])
			M->F2_TCOMP		:= Space(TamSX3('F2_TCOMP')[1])
		EndIf
		If M->F2_REGIME <> '03'
			M->F2_TPRENTA	:= Space(TamSX3('F2_TPRENTA')[1])
			M->F2_EXPCONF	:= 'N'
			M->F2_FECHSE	:= CToD(" / / ")
		EndIf
		If M->F2_REGIME <> '01'
			M->F2_MUNDESC	:= Space(TamSX3('F2_MUNDESC')[1])
			M->F2_CMUNDE	:= Space(TamSX3('F2_CMUNDE')[1])
			M->F2_DOCMAN	:= Space(TamSX3('F2_DOCMAN')[1])
			M->F2_LTRAN		:= Space(TamSX3('F2_LTRAN')[1])
		EndIf
		If M->F2_EXPCONF == 'N'
			M->F2_VALIMPD	:= 0
		EndIf
	ElseIf cCpoVal == 'SC5'
		If M->C5_TPACTIV == 'N'
			M->C5_REGIME	:= Space(TamSX3('C5_REGIME')[1])
			M->C5_TCOMP		:= Space(TamSX3('C5_TCOMP')[1])
		EndIf
		If M->C5_REGIME <> '03'
			M->C5_TPRENTA	:= Space(TamSX3('C5_TPRENTA')[1])
			M->C5_EXPCONF	:= 'N'
			M->C5_FECHSE	:= CToD(" / / ")
		EndIf
		If M->C5_REGIME <> '01'
			M->C5_MUNDESC	:= Space(TamSX3('C5_MUNDESC')[1])
			M->C5_CMUNDE	:= Space(TamSX3('C5_CMUNDE')[1])
			M->C5_DOCMAN	:= Space(TamSX3('C5_DOCMAN')[1])
			M->C5_LTRAN		:= Space(TamSX3('C5_LTRAN')[1])
		EndIf
		If M->C5_EXPCONF == 'N'
			M->C5_VALIMPD	:= 0
		EndIf
	EndIf
Return .T.


/*/{Protheus.doc} LxGrvNfEqu
	Graba información especifica en notas fiscales del país Equador.
	La función es llamada en GravaNfGeral (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 09/09/2022
	@param 	lInclui: .T. en la inclusión de un documento.
			aCfgNF: array con la configuración para los documentos fiscales.
			nNFTipo: Tipo de documento fiscal.
			cDoctoId: Documento de identificación (A1_CGC).
			cNomeCli: Nombre del cliente.
			aLlaveOrg: Array con información de las llaves.
			cFunname: Nombre de rutina.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxGrvNfEqu(lInclui, aCfgNF, nNFTipo, cDoctoId, cNomeCli, aLlaveOrg, cFunname)
Local cLvroRetC  := SuperGetMV("MV_LVRORIC",,"") //Número de libro para ret. de IVA al 0% (Ecuador)
Local cCliPad    := GetMv("MV_CLIPAD")
Local lCpoTpDoc  := SF2->(FieldPos("F2_TPDOC")) > 0
Local aDadSFE    := {}
Local lRet       := .T.
Local lGenCert	 := SuperGetMv("MV_CERCER",,"S") == "N"  //Genera certificado de Retención al 0% 
Local nBasIVA	 := 0
Local nRetIVA	 := 0

Default lInclui   := .F.
Default aCfgNF    := {}
Default nNFTipo   := 0
Default cDoctoId  := ""
Default cNomeCli  := ""
Default aLlaveOrg := {}
Default cFunname  := Funname()

	If lInclui .And. aCfgNF[SAliasHead] == "SF1" .And. !("NC" $ SF1->F1_ESPECIE)
		
		nBasIVA:=SF1->F1_BASIMP2 + SF1->F1_BASIMP3 + SF1->F1_BASIMP4 +IIf(!Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4"), SF1->&("F1_BASIMP" + AllTrim(cLvroRetC)), 0)
		nRetIVA:=SF1->F1_VALIMP2 + SF1->F1_VALIMP3 + SF1->F1_VALIMP4 +IIf(!Empty(cLvroRetC) .And. !(AllTrim(cLvroRetC) $ "2|3|4"), SF1->&("F1_VALIMP" + AllTrim(cLvroRetC)), 0)

			If  ((nRetIVA > 0  .or. (nBasIVA > 0 .And. nRetIVA == 0 .And.!lGenCert))  .OR. (SF1->F1_VALIMP6 > 0 .Or. (SF1->F1_VALIMP6 == 0 .And.!lGenCert)));
				.And. !(AllTrim(Str(nNFTipo)) $ "60|61|64|54|07")
				Aadd(aDadSFE,{.F.,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_DOC,SF1->F1_SERIE})
				FGrvCrt(1,aDadSFE)
			EndIf
		
	EndIf

	If lInclui .And. aCfgNF[SAliasHead] == "SF2" .And. Alltrim(SF2->F2_ESPECIE) == "NF" .And. SF2->F2_TPVENT == "1"
		If (SF2->F2_BASIMP2 + SF2->F2_BASIMP3 + SF2->F2_BASIMP4) > 0
			Aadd(aDadSFE,{.F.,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_DOC,SF2->F2_SERIE})
			FGrvCrt(2,aDadSFE)
		EndIf
	EndIf

	If aCfgNF[SAliasHead] == "SF2" .And. nNFTipo == 17
		SF2->(RecLock("SF2",.F.))
		SF2->F2_RG 		:= cDoctoId
		SF2->F2_NOMCLI	:= cNomeCli
		SF2->(MsUnlock())
		//Atualiza o DI do Cliente
		If SF2->F2_CLIENTE <> cCliPad
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA ))
			SA1->(RecLock("SA1",.F.))
			SA1->A1_CGC := cDoctoId
			SA1->(MsUnlock())
		EndIf
	EndIf

	If  lRet .and. cFunname == "MATA467N" .and. aCfgNF[SAliasHead] == "SF2" .and. Alltrim(SF2->F2_ESPECIE) =="NF" .and. FindFunction("MAT488AQ0") .and. lCpoTpDoc
		lRet := MAT488AQ0() //Guarda los reembolsos en tabla AQ0 y cancela  la Cuenta por cobrar(SE1) y genera una cuenta por pagar(SE2)
	EndIf

Return lRet

/*/{Protheus.doc} LxGrvCabEq
	La funcion es llamada en GravaCabNF (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 09/09/2022
	@param 	cAlias: Alias de tabla (SF1/SF2)
			cFormCrbo: Forma de cobro.
	@return Nil
	/*/
Function LxGrvCabEq(cAlias, cFormCrbo)
Local lCpoModtra  := SF2->(ColumnPos("F2_MODTRAD")) > 0 

Default cAlias    := ""
Default cFormCrbo := ""

	If cAlias=="SF2"
		If lCpoModtra .And. !Empty(cFormCrbo)
			SF2->F2_MODTRAD := cFormCrbo 
		Endif
	EndIf

Return Nil

/*/{Protheus.doc} NfTudOkEqu
	La función es llamada en NfTudOk (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 09/09/2022
	@version version
	@param 	nNFTipo: Tipo de documento fiscal.
			cAliasC: Alias de tabla (SF1/SF2).
			cAliasCF: Alias de tabla (SA1/SA2).
			cFormCrbo: Forma de cobro.
			cNomeCli: Nombre del cliente.
			cDoctoId: Documento de identificación (A1_CGC).
			aCItens: Items de NF (aCols).
			aCpItens: Campos de ítems (aHeader).
			aCfgNf: Array con la configuración del documento.
			aLlaveOrg: Array con información de las llaves.
			cFunname: Nombre de la rutina.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function NfTudOkEqu(nNFTipo, cAliasC, cAliasCF, cFormCrbo, cNomeCli, cDoctoId, aCItens, aCpItens, aCfgNf, aLlaveOrg, cFunname)
Local lCpoModTra := SF2->(FieldPos("F2_MODTRAD")) > 0
Local nLimVenta  := GetMv("MV_EQUBVCF",,0)
Local lRet       := .T.
Local nX         := 0
Local nTotVenta  := 0
Local nPosTotal  := 0
Local oDlgVenta  := Nil

Default nNFTipo   := 0
Default cAliasC   := ""
Default cAliasCF  := ""
Default cFormCrbo := ""
Default cNomeCli  := ""
Default cDoctoId  := ""
Default aCItens   := {}
Default aCpItens  := {}
Default aCfgNf    := {}
Default aLlaveOrg := {}
Default cFunname  := Funname()

	nPosTotal  := aScan(aCpItens,{|x| AllTrim(x)=="D2_TOTAL"})

	//Verifica que exista informacion en la forma de cobro para Ecuador
	If lRet .And. cAliasC == "SF2" .And. AllTrim(aCfgNf[ScEspecie]) $ "NF"
		If lCpoModTra .and. Empty(cFormCrbo)
			Aviso(STR0005,STR0006+ALLTRIM(FWX3Titulo("F2_MODTRAD")),{STR0007}) //"¡ATENCIÓN!"//"Complete el campo del encabezado: "//"OK"						
			lRet	:=	.F.
		EndIf
	Endif

	If lRet .And. nNFTipo == 17 .And. cAliasCF == "SA1"
		For nX := 1 to Len(aCItens)
			//Verifica se a linha nao esta deletada
			If aCitens[nX][Len(aCitens[nX])]
				Loop
			EndIf
			nTotVenta += aCItens[nx][nPosTotal]
		Next nX
		
		If nTotVenta > nLimVenta .Or. MsgYesNo( STR0008 ) // "Deseja identificar o consumidor?"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+M->F2_CLIENTE+M->F2_LOJA ))
			cNomeCli := SA1->A1_NOME
			cDoctoId := SA1->A1_CGC
			oDlgVenta := TDialog():New(000,000,130,400,OemToAnsi(STR0009),,,,,,,,oMainWnd,.T.) // "Dados do consumidor - Nota de Venta"
				TGroup():New(005,003,oDlgVenta:nClientHeight/2-35,oDlgVenta:nClientWidth/2-8,STR0010,oDlgVenta,,,.T.,.F. ) // "Informe o nome do consumidor e o número do RUC"
					TSay():New(018,007,{||STR0011 },oDlgVenta,,,.F.,.F.,.F.,.T.,,,oDlgVenta:nClientWidth/2-10,008) // " Nome do consumidor: "
					@ 018,075 MSGET oGetNomeCli VAR cNomeCli Size oDlgVenta:nClientWidth/2-8-85,008 When M->F2_CLIENTE $ GetMv("MV_CLIPAD",,'') Pixel Of oDlgVenta

					TSay():New(030,007,{||STR0012},oDlgVenta,,,.F.,.F.,.F.,.T.,,,oDlgVenta:nClientWidth/2-10,008) // " RUC do consumidor: "
					TGet():New(030,075,bSetGet(cDoctoId),oDlgVenta,oDlgVenta:nClientWidth/2-8-85,008,'',{|| If(FindFunction("ChkDocEQU"),ChkDocEQU(cDoctoId, .T.),.T.) },,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
				TButton():New(050,003,OemToAnsi("&Ok"),oDlgVenta,{|| oDlgVenta:End()},040,012,,,,.T.,,,,{|| })
			oDlgVenta:Activate(,,,.T.)

			If Empty(cNomeCli) .Or. Empty(cDoctoId)
				lRet := .F.
			EndIf
			If lRet
				// Se existir o validador do RUC, entra se ele for invalido, se não, entra pra validar o DOC
				lRet := DvRucEqu(cDoctoId)
				If !lRet
					If FindFunction("ChkDocEQU")
						lRet := ChkDocEQU(cDoctoId,.F.)
					EndIf
				EndIf
			EndIf
			If !lRet
				MsgAlert(STR0013 + AllTrim(Transform(nLimVenta,"@E 999,999,999.99")) + STR0014 ) // "Para Notas de Venta com valor a partir de " " é obrigatório informar o nome e documento de identificação do cliente."
			EndIf
		EndIf
	EndIf

	If cFunname == "MATA467N" .and. aCfgNf[SAliasHead] =="SF2" .and. Alltrim(M->F2_ESPECIE) == "NF"
		If lRet .and. FindFunction("MAT488VLD") .and. FindFunction("LxVlRemEq") .And. LxVlRemEq(.T.) 
			lRet := MAT488VLD(MaFisRet(,'NF_TOTAL'), M->F2_TPDOC, M->F2_TPVENT, M->F2_TIPOPE, M->F2_NATUREZ,aLlaveOrg) // Valida información necesaria antes de guardar la Factura 
		EndIf
		If lRet .And. FindFunction("LxEquNFExp")
			lRet := LxEquNFExp()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LxLOkEqu
	La función es llamada en NfLinOk (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 19/09/2022
	@param 	aCfgNF: Array con la configuración del documento.
			aDadosI: datos referentes a los campos de elementos NF
			cTipDoc: Tipo de documento fiscal. 
			nLinha: Número de linea.
			nPosRemito: Posición del campo REMITO
			nPosItemRem: Posición del campo ITEMREM
			nPosSerRem: Posición del campo SERIREM
			nPosCliFor: Posición del campo FORNECE/CLIENTE
			nPosLoja: Posición del campo LOJA
			nPosCod: Posición del campo COD
			nPosEspecie: Posición del campo ESPECIE
			nPosNFOri: Posición del campo NFORI
			nPosItmOri: Posición del campo ITEMORI
			nPosQuant: Posición del campo QUANT
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxLOkEqu(aCfgNF, aDadosI, cTipDoc, nLinha, nPosRemito, nPosItemRem, nPosSerRem, nPosCliFor, nPosLoja, nPosCod, nPosEspecie, nPosNFOri, nPosItmOri, nPosQuant)
Local cFilSD2	  := xFilial("SD2")
Local aAuxI	      := {}
Local lRet        := .T.
Local nZ          := 0
Local nQuantAux   := 0

Default aCfgNF  := {}
Default aDadosI := {}
Default cTipDoc := ""
Default nLinha  := 0
Default nPosRemito  := 0
Default nPosItemRem := 0
Default nPosSerRem  := 0
Default nPosCliFor  := 0
Default nPosLoja    := 0
Default nPosCod     := 0
Default nPosEspecie := 0
Default nPosNFOri   := 0
Default nPosItmOri  := 0
Default nPosQuant   := 0
	
	aAuxI := IIf(!Empty(aDadosI),aClone(aDadosI),{})

	//³Validacao para NCP amarrada a Remito de Devol.
	If lRet .AND. aCfgNF[SnTipo] == 7 .And. cTipDoc == "D" .And. nPosRemito*nPosItemRem*nPosSerRem > 0 .And. !Empty(aDadosI[nLinha][nPosRemito])
		//Posiciona Nota de Origem
		SD2->(DBSetOrder(3))
		If nPosCliFor>0 .And. nPosLoja>0 .And. nPosCod>0 .And. ;
			SD2->(MsSeek(cFilSD2+aDadosI[nLinha][nPosRemito]+aDadosI[nLinha][nPosSerRem]+aDadosI[nLinha][nPosCliFor]+aDadosI[nLinha][nPosLoja]+aDadosI[nLinha][nPosCod]+aDadosI[nLinha][nPosItemRem]))
			//³Soma qtde total
			For nZ := 1 to Len(aAuxI)
				If 	aAuxI[nZ][nPosCod]     		== SD2->D2_COD	 .And. ;
					aAuxI[nZ][nPosRemito]		== SD2->D2_DOC	 .And. ;
					aAuxI[nZ][nPosSerRem] 		== SD2->D2_SERIE .And. ;
					aAuxI[nZ][nPosItemRem] 		== SD2->D2_ITEM  .And. ;
					!aAuxI[nZ][Len(aAuxI[nZ])]
					nQuantAux += aAuxI[nZ][nPosQuant]
				EndIf
			Next
			If lRet .And. nQuantAux > (SD2->D2_QUANT - SD2->D2_QTDEFAT)
				//Avisa caso a soma da qtde informada ultrapassar a qtde. disponivel do remito original
				Help(" ",1,"A466NQTDIS")
				lRet := .F.
			EndIf
			//Validacao para os dados do Remito quando o cPaisLoc for do tipo Equador
			If lRet .And. aDadosI[nLinha][nPosEspecie] $ "NCP" .And. (Empty(aDadosI[nLinha][nPosRemito]) .Or. Empty(aDadosI[nLinha][nPosItemRem]))
				Aviso(STR0005,STR0015,{STR0007})
   				lRet := .F.
			EndIf
		EndIf
	ElseIf lRet .And. (nPosEspecie*nPosNFOri*nPosItmOri > 0) .And. aDadosI[nLinha][nPosEspecie] $ "NCP|NDP|NCI|NDI" .And. (Empty(aDadosI[nLinha][nPosNFOri]) .Or. Empty(aDadosI[nLinha][nPosItmOri]))
	   //Validacao para os dados Originais da Nota quando o cPaisLoc for do tipo Equador
		Aviso(STR0005,STR0016,{STR0007})
   		lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} LxDelNfEqu
	La función es llamada en LocxDelNF (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 19/09/2022
	@param 	aCfgNf: Array con la configuración del documento.
			cAlias: Alias de tabla (SF1/SF2).
			lDeleta: .T. para eliminar el documento fiscal.
			cFunname: Nombre de rutina.
	@return lRet
	/*/
Function LxDelNfEqu(aCfgNf, cAlias, lDeleta, cFunname)
Local aDadSfe    := {}
Local lRet       := .T.
Local lCpoTpDoc  := SF2->(FieldPos("F2_TPDOC")) > 0

Default aCfgNf   := {}
Default cAlias   := ""
Default lDeleta  := .F.
Default cFunname := Funname()

	If lDeleta
		aDadSFE := {}
		If cAlias == "SF1" .And. !Alltrim(SF1->F1_ESPECIE)$"NDE/NCC"
			aAdd(aDadSFE,{"",0,"",0,0,0,SF1->F1_DOC,SF1->F1_SERIE,"E",SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_ESPECIE,"",SF1->F1_NATUREZ})
		ElseIf cAlias == "SF2" .And. Alltrim(SF2->F2_ESPECIE)$"NDI/NCP/NF"
			aAdd(aDadSFE,{"",0,"",0,0,0,SF2->F2_DOC,SF2->F2_SERIE,"S",SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ESPECIE,"",SF2->F2_NATUREZ})
		Endif
		lRet := FGrvSFE("5",aDadSfe)
	Endif

	If lRet .And. cFunname == "MATA467N" .And. aCfgNf[SAliasHead]=="SF2" .and. AllTrim(SF2->F2_ESPECIE) =="NF" .And. FindFunction("MAT488DEL") .And. lCpoTpDoc
		lRet := MAT488DEL()//Elimina los reembolsos en tabla AQ0 y da de baja la cuenta por pagar(SE2)
	EndIf

Return lRet

/*/{Protheus.doc} LxNatEqu
	La función es llamada en LxA103Dupl (LOCXNF2.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 20/09/2022
	@param 	aCols: Array con ítems de NF.
			lPParc: .T. Documento genera varias cuotas.
			cNatureza: Código de la naturaleza.
			cOperNf: Valor de NF_OPERNF.
			nValor: Valor del título financiero.
			nTotDup: Valor total del título financiero.
			N: Número de ítem del documento fiscal.
			*** Las siguientes variables se pasan por referencia: @lPParc, @cNatureza, @nValor, @nTotDup ***
	@return Nil
	/*/
Function LxNatEqu(aCols, lPParc, cNatureza, cOperNf, nValor, nTotDup, N)
Default aCols     := {}
Default lPParc    := .F.
Default cNatureza := ""
Default cOperNf   := ""
Default nValor    := 0
Default nTotDup   := 0
Default N         := 1

	If cOperNf == "S"
		If Type("M->F2_NATUREZ")#"U"
			cNatureza := M->F2_NATUREZ
		ElseIf !Empty(SF2->F2_NATUREZ)
			cNatureza := SF2->F2_NATUREZ
		Else
			cNatureza := SA1->A1_NATUREZ
		Endif
	Endif

	lPParc := Posicione("SED",1,xFilial("SED")+cNatureza,"ED_RATRET") == "1"
	If lPParc
		nValor  := xValDupEqu(aCols, nValor, N)
		nTotDup := xValDupEqu(aCols, nTotDup, N)
	Endif

Return Nil

/*/{Protheus.doc} xValDupEqu
	La función es llamada en ValDuplic (LOCXNF2.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 20/09/2022
	@param 	aCols: Array con ítems de NF.
			nValor: Valor del título financiero.
			N: Número de ítem de documento fiscal.
	@return nAuxValor: Valor del título financiero.
	/*/
Function xValDupEqu(aCols, nValor, N)
Local nValRetImp := 0
Local nAuxValor  := 0

Default aCols  := {}
Default nValor := 0
Default N      := 0

	IIf(n > Len(aCols), n := Len(aCols), n := n)
	nAuxValor := nValor

	dbSelectArea("SFC")
	dbSetOrder(2)
	If SFC->(MsSeek(xFilial("SFC") + MaFisRet(N,"IT_TES") + "RIR")) //Retenção RIR

		DbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(MsSeek(xFilial("SFB")+AvKey(SFC->FC_IMPOSTO,"FB_CODIGO")))
			nValRetImp := MaFisRet(,"NF_VALIV"+SFB->FB_CPOLVRO)
		Endif

		If SFC->FC_INCDUPL == '1'
			nAuxValor := nAuxValor - nValRetImp
		ElseIf SFC->FC_INCDUPL == '2'
			nAuxValor := nAuxValor + nValRetImp
		EndIf
	Endif
Return nAuxValor

/*/{Protheus.doc} LxVlRemEq
	La funcion valida si la Factura es un reembolso
	@type  Function
	@author Verónica Flores 
	@since 16/01/2023
	@param 	lValida Logico Verifica si la validación es antes o despues del guardado.
	@return lRet Logico Si es un reembolso o una Factura Normal
	/*/
Function LxVlRemEq(lValida)

Local lCpoTpVen  := SF2->(ColumnPos("F2_TPVENT")) > 0
Local lCpoTpOpe  := SF2->(ColumnPos("F2_TIPOPE")) > 0
Local lCpoTpDoc  := SF2->(ColumnPos("F2_TPDOC")) > 0
Local lRet 		 := .F.

Default lValida := .T.

	If lCpoTpDoc .And. lCpoTpVen .And. lCpoTpOpe
		If lValida 
			lRet := IIf(M->F2_TPDOC == "01" .And. M->F2_TPVENT == "1".And. AllTrim(M->F2_TIPOPE) == "41",.T.,.F.)
		Else
			lRet := IIf(SF2->F2_TPDOC == "01" .And. SF2->F2_TPVENT == "1".And. AllTrim(SF2->F2_TIPOPE) == "41",.T.,.F.)
		EndIf
	EndIF

Return lRet

/*/{Protheus.doc} LxCertEQU
	Funcion que valida si la Factura de Entrada o la Factura de salida de tipo liquidación de compras
	cuenta con un certificado de retención vigente.
	@type  Function
	@author Oswaldo Diego 
	@since 16/05/2024
	@param 	cFornece Caracter Proveedor informado en la factura (SF1->F1_FORNECE).
	@param 	cLoja    Caracter Tienda informada en la factura (SF1->F1_LOJA).
	@param 	cPrefixo Caracter Prefijo informado en la factura (SF1->F1_PREFIXO).
	@param 	cSerie   Caracter Serie informada en la factura (SF1->F1_SERIE).
	@param 	cDoc     Caracter Número de documento informado en la factura (SF1->F1_DOC).
	@return lCert    Lógico Si la factura de entrada cuenta con un Certificado de Retención vigente.
	/*/
Function LxCertEQU(cFornece, cLoja, cPrefixo, cSerie, cDoc)
	Local cAliasQry	 := GetNextAlias()
	Local aArea      := GetArea()
	Local cPref      := ""
	Local lCert      := .F.
	Default cFornece := ""
	Default cLoja    := ""
	Default cPrefixo := ""
	Default cSerie   := ""
	Default cDoc     := ""

	If !Empty(GetMV("MV_2DUPREF"))
		cPref := &(GetMV("MV_2DUPREF"))
	EndIf

	If Empty(cPrefixo)
		cPref := IIf(Empty(cPref),Criavar("SF1->F1_PREFIXO"),cPref)
	Else
		cPref := cPrefixo
	Endif

	BeginSQL Alias cAliasQry
		SELECT COUNT(1) CER
		FROM %Table:SE2% SE2
		WHERE SE2.E2_FILIAL  = %xfilial:SE2%  AND
		      SE2.E2_FORNECE = %Exp:cFornece% AND
			  SE2.E2_LOJA    = %Exp:cLoja%    AND
			  SE2.E2_PREFIXO = %Exp:cPref%    AND
			  SE2.E2_NUM     = %Exp:cDoc%     AND
			  SE2.E2_TIPO    IN ('IR-','IV-') AND
			  SE2.%NotDel%
		EndSQL
	
	(cAliasQry)->(DBGOTOP())

	lCert := (cAliasQry)->CER > 0

	(cAliasQry)->( dbCloseArea() )

	RestArea(aArea)

	If ExistBlock("VLCEREQU")
		lCert := ExecBlock("VLCEREQU",.F.,.F.,{lCert,cFornece, cLoja, cPrefixo, cSerie, cDoc})
	Endif

	If lCert
		MsgAlert(STR0017)
	EndIF

Return lCert

/*/{Protheus.doc} LxCXPEqu
	Función realiza la grabación las cuentas por pagar(SE2) de retenciones 
	de la liquidación de compras.
	@type  Function
	@author eduardo.manriquez
	@since 09/09/2024
	@param 	aDadosTit : Array con los datos de las cuentas por cobrar(SE1) de retenciones
						de la liquidación de compras.
	@return lOk       : booleano, si se realiza registro de CXP - .T.
	/*/
Function LxCXPEqu(aDadosTit)
	LOCAL aArea	:= {}
	LOCAL nX := 1
	Local lOk := .T.
	Local cOrigen := Funname()
	Local aAbatimento := {}
	Default aDadosTit := {}

	aArea:=GetArea()

	For nX := 1 to Len(aDadosTit)

		aAbatimento := {}
		AADD(aAbatimento , {"E2_PREFIXO", 	aDadosTit[nX][1], NIL})
		AADD(aAbatimento , {"E2_NUM"    , 	aDadosTit[nX][2], NIL})
		AADD(aAbatimento , {"E2_PARCELA",	aDadosTit[nX][3], NIL})
		AADD(aAbatimento , {"E2_TIPO"   , 	aDadosTit[nX][4], NIL})
		AADD(aAbatimento , {"E2_FORNECE", 	aDadosTit[nX][6], NIL})	
		AADD(aAbatimento , {"E2_LOJA"   , 	aDadosTit[nX][7], NIL})
		AADD(aAbatimento , {"E2_MOEDA"  , 	aDadosTit[nX][12], NIL})
		AADD(aAbatimento , {"E2_VALOR"  , 	aDadosTit[nX][8], NIL})
		AADD(aAbatimento , {"E2_VLCRUZ" , 	aDadosTit[nX][8], NIL})
		AADD(aAbatimento , {"E2_NATUREZ", 	aDadosTit[nX][5], NIL})
		AADD(aAbatimento , {"E2_EMISSAO", 	aDadosTit[nX][11], NIL})
		AADD(aAbatimento , {"E2_VENCTO" , 	aDadosTit[nX][09], NIL})
		AADD(aAbatimento , {"E2_VENCREA", 	aDadosTit[nX][09], NIL})
		AADD(aAbatimento , {"E2_VENCORI", 	aDadosTit[nX][09], NIL})
		AADD(aAbatimento , {"E2_EMIS1"  , 	dDataBase        , NIL})
		AADD(aAbatimento , {"E2_HIST"	, 	aDadosTit[nX][11], NIL})		
		AADD(aAbatimento , {"E2_ORIGEM"	, 	cOrigen          , NIL})

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA050(x, y)}, aAbatimento, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
			Exit
		EndIf

	Next nX

	RestArea(aArea)
Return lOk 


/*/{Protheus.doc} LxLiqCom
	Función retorna si el documento que genero certificado de retención
	es una liquidación de compras(SF2->F2_TPVENT igual a "1").
	@type  Function
	@author eduardo.manriquez
	@since 09/09/2024
	@param 	cFilSF2  Caracter Filial tabla SF2.
	@param 	cCliente Caracter Cliente del documento.
	@param 	cLoja    Caracter Tienda del cliente.
	@param 	cDoc     Caracter Número de documento.
	@param 	cSerie   Caracter Serie del documento.
	@param 	cEsp     Caracter Especie del documento.
	@return lLiqCom : boolean 
					  Si campo SF2->F2_TPVENT del documento del certificado igual a "1" - .T.
					  Si campo SF2->F2_TPVENT del documento del certificado <> a "1" - .F.
	/*/
Function LxLiqCom(cFilSF2,cCliente,cLoja,cNFiscal,cSerie,cEsp)
	Local lLiqCom := .F.
	Local cAliasQry	 := GetNextAlias()
	Local aArea      := GetArea()
	Default cCliente := ""
	Default cLoja    := ""
	Default cNFiscal := ""
	Default cSerie   := ""
	Default cEsp     := ""
	Default cFilSF2  := ""

	
	BeginSQL Alias cAliasQry
		SELECT COUNT(1) NLIQ
		FROM %Table:SF2% SF2
		WHERE SF2.F2_FILIAL    = %Exp:cFilSF2%  AND
		      SF2.F2_CLIENTE   = %Exp:cCliente% AND
			  SF2.F2_LOJA      = %Exp:cLoja%    AND
			  SF2.F2_DOC       = %Exp:cNFiscal% AND
			  SF2.F2_SERIE     = %Exp:cSerie%   AND
			  SF2.F2_ESPECIE   = %Exp:cEsp%   AND
			  SF2.F2_TPVENT = '1' AND
			  SF2.%NotDel%
	EndSQL

	(cAliasQry)->(DBGOTOP())

	lLiqCom := (cAliasQry)->NLIQ > 0

	(cAliasQry)->( dbCloseArea() )

	RestArea(aArea)

Return lLiqCom

/*/{Protheus.doc} LxDatRet
	Función que retorna los datos de las cuentas por cobrar(SE1) de retenciones 
	de la liquidación de compras.
	@type  Function
	@author eduardo.manriquez
	@since 09/09/2024
	@param 	NA
	@return aDadosRet : Array con los datos de las cuentas por cobrar(SE1) de retenciones
						de la liquidación de compras.
	/*/
Function LxDatRet()
	Local aDadosRet := {}
	Local cCodProvS := ""
	Local cLojaS    := ""
	Local cLlave    := ""
	Local cFilSE1   := xFilial("SE1")

	If SF2->F2_TPVENT=="1"
		SE1->( dbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		cLlave:= ( cFilSE1 + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC)
		If FindFunction("ObtProvCli")
			ObtProvCli(@cCodProvS, @cLojaS,SF2->F2_CLIENTE,SF2->F2_LOJA )
		Endif

		If SE1->(MSSeek(cLlave) )

			Do While SE1->(!EOF()) .Or. (SE1->E1_FILIAL == cFilSE1 .And. SE1->E1_CLIENTE == SF2->FE_CLIENTE .And.;
					 SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC)

				If SE1->E1_TIPO $ "IV-|IR-"
					If Empty(SE1->E1_BAIXA)
						aadd(aDadosRet,{SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, cCodProvS,;
						cLojaS, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO,  SE1->E1_MOEDA,SE1->E1_ORIGEM })
					EndIf
				EndIf
				SE1->(dbSkip())
			EndDo
		Endif		 
	Endif

Return aDadosRet


/*/{Protheus.doc} fPagados
    Funcion que valida cuanto se ha pagado por cuota( si existe registro en la SE2) de IR- o IV-
    @type  Function
    @author adrian.perez 
    @since 05/02/2025
	@param  cParcela,Carácter, cuota o titulo
	@param  cNum, numérico, numero de documento
	@param  cPrefixo ,Carácter , prefijo documento
	@param  cFornec ,Carácter , proveedor
	@param  cLoja ,Carácter , tienda
	@param  cTipos ,Carácter , tipos  de acuerdo a MVIVABT y MVIRABT
    @return  nSumaPag,numérico, saldo pagado por cuota
    /*/
function fPagados(cParcela,cNum,cPrefixo,cFornec,cLoja,cTipos)

Local nSumaPag:=0
Local cTmp:=""

DEFAULT cParcela:=""
DEFAULT cNum:=""
DEFAULT cPrefixo:=""
DEFAULT cFornec:=""
DEFAULT cLoja:=""
DEFAULT cTipos:=""

			cTmp:= getNextAlias()
				BEGINSQL ALIAS cTmp
				SELECT SUM(E2_SALDO) SUMA
				FROM %Table:SE2% SE2
				
				WHERE SE2.E2_FILIAL = %xfilial:SE2% 
					AND SE2.E2_NUM=%EXP:cNum%
					AND SE2.E2_PREFIXO=%EXP:cPrefixo%
					AND SE2.E2_FORNECE=%EXP:cFornec%
					AND SE2.E2_LOJA=%EXP:cLoja%
					AND SE2.E2_TIPO IN (%EXP:cTipos%)
					AND SE2.E2_PARCELA= (%EXP:cParcela%)
					AND SE2.%notDel%
				ENDSQL
				(cTmp)->(dbGoTop())
	
					While (!(cTmp)->(EOF()))
					
						nSumaPag:=((cTmp)->SUMA)
					
						(cTmp)->(DBSKIP())
					EndDo
				(cTmp)->(dbCloseArea())	

return nSumaPag

/*/{Protheus.doc} fPagar
    Funcion que valida cuanto se va a pagar por cuota
    @type  Function
    @author adrian.perez 
    @since 05/02/2025
	@param  aTitulos,array, información de las cuotas
	@param  cNum, numérico, numero de documento
    @param  cTipoRet ,Carácter , tipo de titutlo (IR- o IV-)
    @param  nValAbat, numérico, valor a pagar del impuesto (registro en la SE2 de IR- o IV-)
    @param  cTipoDoc ,Carácter , tipo de documento
	@param  cPrefixo ,Carácter , prefijo documento
	@param  cFornec ,Carácter , proveedor
	@param  cLoja ,Carácter , tienda
	@param  cTipos ,Carácter , tipos  de acuerdo a MVIVABT y MVIRABT
    @return arreglo, arreglo que contien saldo a pagar y parcela.
    /*/
function fPagar(aTitulos,cNum,cTipoRet,nValAbat,cTipoDoc,cPrefixo,cFornec,cLoja,cTipos)
Local nMntUsado:=0
Local nX:=0
Local nAPagar:=0
Local cParcela:=""

DEFAULT aTitulos:={}
DEFAULT cNum:=""
DEFAULT cTipoRet:=""
DEFAULT nValAbat:=0
DEFAULT cTipoDoc:=""
DEFAULT cPrefixo:=""
DEFAULT cFornec:=""
DEFAULT cLoja:=""
DEFAULT cTipos:=""

		For nX := 1 To Len(aTitulos)
			nMntUsado:=fPagados(aTitulos[nX][3],cNum,cPrefixo,cFornec,cLoja,cTipos)
			IF aTitulos[nX][1]!=nMntUsado
				nSobraTit:=aTitulos[nX][1]-nMntUsado

				IF nMntUsado>0 .AND. (nSobraTit<=nValAbat)
					nAPagar:=nSobraTit
				ELSE
					
					IF(nValAbat<=aTitulos[nX][1])
						nAPagar:=nValAbat
					ELSE
						nAPagar:=aTitulos[nX][1]
					ENDIF
				ENDIF
				
				cParcela:=aTitulos[nX][3]
				EXIT
			ENDIF
		Next
return {nAPagar,cParcela}


/*/{Protheus.doc} fCheSal
    Funcion que valida el saldo restante a pagar de IR- o IV-
    @type  Function
    @author adrian.perez 
    @since 05/02/2025
    @param  nSaldo ,numérico, saldo restante de IR- o IV-
    @param  aAuxCp, arreglo, datos de pago a aplicar por cuota (monto, cuota)
    @param  aVlrCp,array, contiene datos de del saldo a informar en SE2
    @param  nCont, numérico, numero de item del arreglo aVlrCp
    @param  cTipoTit ,Carácter , tipo de titutlo 
	@param  cNum ,Carácter , numero de documento
	@param  cPrefixo ,Carácter , prefijo documento
	@param  cFornec ,Carácter , proveedor
	@param  cLoja ,Carácter , tienda
	@param  cTipos ,Carácter , tipos  de acuerdo a MVIVABT y MVIRABT
	@param  aTitulos, arreglo, cuotas del documento
	@param  lOk, boleano, retorno de la función fGerAbatCP indicando s hubo gravado o no
    @return lOk
    /*/


function fCheSal(nSaldo,aAuxCp,aVlrCp,nCont,cTipoTit,cNum,cPrefixo,cFornec,cLoja,cTipos,aTitulos,lOk)

DEFAULT nSaldo:=0
DEFAULT aAuxCp:={}
DEFAULT aVlrCp:={}
DEFAULT nCont:=0
DEFAULT cTipoTit:=""
DEFAULT cNum:=""
DEFAULT cPrefixo:=""
DEFAULT cFornec:=""
DEFAULT cLoja:=""
DEFAULT cTipos:=""
DEFAULT aTitulos:={}
DEFAULT lOk:=.F.

	
	Do While ( nSaldo>0)
			
		lOk:=fGerAbatCP(aVlrCp[nCont][2], aVlrCp[nCont][1],aAuxCp[2],cTipoTit, aVlrCp[nCont][3], aVlrCp[nCont][4],aAuxCp[1] ,aVlrCp[nCont][6]) 
		
		IF !lOk
			EXIT
		Endif
		nSaldo:=nSaldo -aAuxCp[1]
		aAuxCp:=fPagar(aTitulos,cNum,aVlrCp[nCont][6],nSaldo,cTipoTit,cPrefixo,cFornec,cLoja,cTipos)
	
		fCheSal(@nSaldo,aAuxCp,aVlrCp,nCont,cTipoTit,cNum,cPrefixo,cFornec,cLoja,cTipos,aTitulos,lOk)
	Enddo


return lOk


/*/{Protheus.doc} RatImpItem
	Ajustar valores decimales de impuestos. Función usada en MaFisImpIV (MatxFis).
	@type  Function
	@author luis.samaniego
	@since 11/02/2025
	@param aNfItem, Array, Items de documento fiscal
	nValorIV, Numeric, Valor de impuesto cálculado por total.
	nVlrRateado, Numeric, Total de impuesto obtenido después de aplicar el factor.
	nDecimais, Numeric, Número de decimales.
	nAliquota, Numeric, Alícuota de impuesto
	nNumCpo, Numeric, Número de campo de libro fiscal
	/*/
Function RatImpItem(aNfItem, nValorIV, nVlrRateado, nDecimais, nAliquota, nNumCpo)
Local nPosItem := 0
Local nValDif  := 0
Local nValDif1 := 0
Local nCent    := 0

Default aNfItem     := {}
Default nValorIV    := 0
Default nVlrRateado := 0
Default nDecimais   := 0
Default nAliquota   := 0
Default nNumCpo     := 0

	If cPaisLoc  $ "EQU|COL" .And. Len(aNfItem) > 0
		nValDif := (nValorIV-nVlrRateado)
		nValDif1 := IIf(nValDif < 0, (nValDif * -1), nValDif)
		nCent := 1/(10 ** nDecimais)
		If nValDif1 >= nCent
			While nValDif <> 0
				For nPosItem := 1 to Len(aNfItem)
					If !aNfItem[nPosItem][IT_DELETED]
						If aNFItem[nPosItem][IT_ALIQIMP][nNumCpo] == nAliquota
							If nValDif > 0
								aNfItem[nPosItem][IT_VALIMP][nNumCpo] += nCent
								nValDif -= nCent
								MaFisVTot(nPosItem)
								If nValDif < nCent
									nValDif := 0
									Exit
								EndIf
							Else
								aNfItem[nPosItem][IT_VALIMP][nNumCpo] -= nCent
								nValDif += nCent
								MaFisVTot(nPosItem)
								If (nValDif * -1) < nCent
									nValDif := 0
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				Next
			Enddo
		EndIf
	EndIf
	
Return
