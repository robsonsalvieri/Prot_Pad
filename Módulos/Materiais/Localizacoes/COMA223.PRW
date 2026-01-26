#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'COMA223.CH'

/*/{Protheus.doc} COMA223
Browse para el documento de Nota de débito de entradas
@author 	raul.medina
@since 		03/2024
@version	12.1.2210 / Superior
/*/

Function COMA223()
Local oBrowse	:= Nil

	If !(cPaisLoc $ "ARG|COL|MEX|PAR|PER|EQU|CHI")
		SetFunName("MATA466N")
    	Mata466n()
	Else
		If FindFunction("MxChkPE")
			MxChkPE("COMA223")
		EndIf

		oBrowse := BrowseDef()
		oBrowse:Activate()
	EndIf
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse		:= Nil
Local aCores    	:= {}
Local nX			:= 0
Local oTableAtt		:= Nil
Local lConffis		:= SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
Local lIntegracao	:= SuperGetMV("MV_EASY",.F.,"N")=="S"    //Integracao SIGAEIC

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('SF1')

	If lIntegracao
		AAdd(aCores,{'Empty(F1_STATUS) .AND. !Empty(F1_TIPO_NF)'																,'BR_VERDE'})		// NF Importacao (nao classificada)
		AAdd(aCores,{'F1_STATUS=="A" .AND. !Empty(F1_TIPO_NF)'																	,'BR_PRETO'})	    // NF Importacao (classificada)
	Endif
	If lConffis
		AAdd(aCores,{  '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .And. F1_TIPO	==	"C"	.AND. F1_TIPODOC	$	"08/09"'	, 'BR_PINK'})		// NF Compl. Preco
	Else
		AAdd(aCores,{  'F1_TIPO	==	"C"	.AND. F1_TIPODOC	$	"08/09"'														, 'BR_PINK'})		// NF Compl. Preco
	EndIf

	AAdd(aCores,{  '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .And. F1_TIPO	==	"C"	.AND. F1_TIPODOC	$	"08/09"'		, 'BR_PINK'})		// NF Compl. Preco
	AAdd(aCores,{  'F1_TIPO	==	"D"	.AND. F1_TIPODOC	$	"04/05"'    														, 'BR_AMARELO'})	// NF Devolucao														, 'BR_PRETO'})	    // Remito Transferencia
	AAdd(aCores,{  '!(F1_STATCON $ "1|4") .AND. !EMPTY(F1_STATCON)'																, 'BR_VIOLETA'})	// NF Bloq. para Conferencia

	For nX :=1 To Len(aCores)
        oBrowse:addLegend(aCores[nX][1],aCores[nX][2])
    Next nX
    oBrowse:SetFilterDefault( "F1_TIPODOC $ '09'" )

	oBrowse:SetAttach(.T.)

	oTableAtt := TableAttDef()

	//--------------------------------------------------------------------------------------
	//  Carga todas las visiones y graficos disponibles para actividades en la función TableAttDef
	//---------------------------------------------------------------------------------------
	If oTableAtt <> Nil
		oBrowse:SetViewsDefault( oTableAtt:aViews )
	EndIf

	SetKey(VK_F12,{||Pergunte("MTXRED",.T.)}) 

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
Local aRotInc := {}
Local aRotAux := {}
Local lC223Mnu := ExistBlock("COMA223MNU")
	
	ADD OPTION aRotInc TITLE STR0001    ACTION 'LxViewNDE("NDP", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Nota Débito Proveedor'

    ADD OPTION aRotina TITLE STR0002	ACTION aRotInc				OPERATION MODEL_OPERATION_INSERT	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0003 	ACTION 'LxViewNDE("", 1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004	ACTION 'LxViewNDE("", 5)' 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0005	ACTION 'CTBC662' 			OPERATION 2    						ACCESS 0 // 'Tracker Contábil'
	ADD OPTION aRotina TITLE STR0006	ACTION 'LxLegendIn()' 		OPERATION 2    						ACCESS 0 // 'Leyenda'
	
	If lC223Mnu
		aRotAux := ExecBlock("COMA223MNU",.F.,.F.,{aRotina})
		If (ValType(aRotAux) == "A")
			aRotina := aClone(aRotAux)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} LxViewNDE
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    cType - caracter - tipo de documento.
    nOperation - numerico - operación a ser realizada.
@Return 
/*/
Function LxViewNDE(cType, nOperation)
Local cOperation := OemToAnsi(STR0003) //'Visualizar'

Default nOperation	:= 3
Default cType 		:= ""

	If Empty(cType)
		If SF1->F1_TIPODOC == "09"
			cType := "NDP"
		ElseIf SF1->F1_TIPODOC == "23"
			cType := "NDPS"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0002) //'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0004) //'Excluir'
	EndIf

	If cType == "NDP"
		aCfgNf  := MontaCfgNf(09,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX09",nOperation,,{|| .T.}) 
	ElseIf cType == "NDPS"
		aCfgNf  := MontaCfgNf(23,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX23",nOperation,,{|| .T.}) 
	EndIf

Return

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de notas de débito de entrada.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    oTableAtt - FWTableAtt - objeto con la definición de las visiones de la rutina.
@Return 
/*/
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visiones
Local oNotaDebProv		:= Nil // "Nota Débito Proveedor"

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oNotaDebProv := FWDSView():New()
	oNotaDebProv:SetName(STR0001)// "Nota Débito Proveedor"
	oNotaDebProv:SetID("NotaDebProv")
	oNotaDebProv:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oNotaDebProv:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oNotaDebProv:SetPublic( .T. )
	oNotaDebProv:AddFilter(STR0001, "F1_TIPO == 'C' .AND. F1_TIPODOC == '09'") // "Nota Débito Proveedor"
	oTableAtt:AddView(oNotaDebProv)

Return (oTableAtt)
