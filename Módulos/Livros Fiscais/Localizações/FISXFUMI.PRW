#Include "FISXFUMI.ch"
#Include "protheus.ch"
#Include "rwmake.ch"

/*/{Protheus.doc} fTpOper
	Valores de combo en el campo Tipo Operac. (A2_TPOPER)
	@type  Function
	@author ARodriguez
	@since 01/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return cCombo, string, valores para combo box
	@example
	(examples)
	@see (links_or_references)
	/*/
Function fTpOper()
	Local cCombo := ""

	cCombo := STR0001	//	" =Proveedor Nacional;"
	cCombo += STR0002	//	"02=Enajenación de bienes;"
	cCombo += STR0003	//	"03=Prestación de Servicios Profesionales;"
	cCombo += STR0004	//	"06=Uso o goce temporal de bienes;"
	cCombo += STR0005	//	"08=Importación por transferencia virtual;"
	cCombo += STR0006	//	"85=Otros;"
	cCombo += STR0007	//	" =Proveedor Extranjero;"
	cCombo += STR0002	//	"02=Enajenación de bienes;"
	cCombo += STR0003	//	"03=Prestación de Servicios Profesionales;"
	cCombo += STR0008	//	"07=Importación de bienes o servicios;"
	cCombo += STR0009	//	" =Proveedor Global;"
	cCombo += STR0010	//	"87=Operaciones globales"

Return cCombo

/*/{Protheus.doc} fValTpOper
	Valida campo Tipo Operac. (A2_TPOPER) de acuerdo al campo Tipo Tercero (A2_TIPOTER)
	@type  Function
	@author ARodriguez
	@since 01/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function fValTpOper()
	Local lRet		:= .T.
	Local cTpoPer	:= ""

	If M->A2_TIPOTER == "04"
		cTpoPer := "02/03/06/08/85"
	ElseIf M->A2_TIPOTER == "05"
		cTpoPer := "02/03/07"
	ElseIf M->A2_TIPOTER == "15"
		cTpoPer := "87"
	EndIf

	If !(M->A2_TPOPER $ cTpoPer)
		Help(,,STR0011,,STR0012,1,0)	//	"Tipo Operac."##"Identifica el tipo de la operación con proveedores, de acuerdo con la clasificación fiscal, para declaraciones informativas."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} fVlTipoTer
    Validación de Tipo Tercero (A2_TIPOTER), asigna valor default a Tipo Operac. (A2_TPOPER)
    @type  Function
    @author Arodriguez
    @since 02/03/2025
    @version 12.1.2310
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function fVlTipoTer()
    Local lRet  := .T.

    If M->A2_TIPOTER == "04" .Or. M->A2_TIPOTER == "05"
        M->A2_TPOPER := "03"
    ElseIf M->A2_TIPOTER == "15"
        M->A2_TPOPER := "87"
    Else
        M->A2_TPOPER := Space( Len(M->A2_TPOPER) )
    EndIf

Return lRet
