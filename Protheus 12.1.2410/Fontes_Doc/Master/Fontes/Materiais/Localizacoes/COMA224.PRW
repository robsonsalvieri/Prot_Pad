#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'COMA224.CH'

/*/{Protheus.doc} COMA224
Browse para el documento de Nota de crédito de entradas
@author 	raul.medina
@since 		03/2024
@version	12.1.2210 / Superior
/*/

Function COMA224()
Local oBrowse	:= Nil

	If !(cPaisLoc $ "ARG|COL|MEX|PAR|PER|EQU|CHI")
		SetFunName("MATA466N")
    	Mata466n()
	Else
		If FindFunction("MxChkPE")
			MxChkPE("COMA224")
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

	For nX :=1 To Len(aCores)
        oBrowse:addLegend(aCores[nX][1],aCores[nX][2])
    Next nX
    oBrowse:SetFilterDefault( "F1_TIPODOC $ '08'" )

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
Local lC224Mnu := ExistBlock("COMA224MNU")
	
	ADD OPTION aRotInc TITLE STR0001    ACTION 'LxViewNCE("NCI", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Nota Crédito Interna'

    ADD OPTION aRotina TITLE STR0002	ACTION aRotInc				OPERATION MODEL_OPERATION_INSERT	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0003 	ACTION 'LxViewNCE("", 1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004	ACTION 'LxViewNCE("", 5)' 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0007	ACTION 'LxViewNCE("", 6)' 	OPERATION 6						    ACCESS 0 // 'Anular'
	ADD OPTION aRotina TITLE STR0005	ACTION 'CTBC662' 			OPERATION 2    						ACCESS 0 // 'Tracker Contábil'
	ADD OPTION aRotina TITLE STR0006	ACTION 'LxLegendIn()' 		OPERATION 2    						ACCESS 0 // 'Leyenda'
	
	If lC224Mnu
		aRotAux := ExecBlock("COMA224MNU",.F.,.F.,{aRotina})
		If (ValType(aRotAux) == "A")
			aRotina := aClone(aRotAux)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} LxViewNCE
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    cType - caracter - tipo de documento.
    nOperation - numerico - operación a ser realizada.
@Return 
/*/
Function LxViewNCE(cType, nOperation)
Local cOperation := OemToAnsi(STR0003) //'Visualizar'

Default nOperation	:= 3
Default cType 		:= ""

	If Empty(cType)
		If SF1->F1_TIPODOC == "08"
			cType := "NCI"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0002) //'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0004) //'Excluir'
	ElseIf nOperation == 6
		cOperation := OemToAnsi(STR0007) //'Anular'
	EndIf

	If cType == "NCI"
		aCfgNf  := MontaCfgNf(08,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX08",nOperation,,{|| .T.}) 
	EndIf

Return

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de notas de crédito de entrada.
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
Local oNotaCreIn		:= Nil // "Nota Crédito Interna"

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oNotaCreIn := FWDSView():New()
	oNotaCreIn:SetName(STR0001)// "Nota Crédito Interna"
	oNotaCreIn:SetID("NotaCreIn")
	oNotaCreIn:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oNotaCreIn:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oNotaCreIn:SetPublic( .T. )
	oNotaCreIn:AddFilter(STR0001, "F1_TIPO == 'C' .AND. F1_TIPODOC == '08'") // "Nota Crédito Interna"
	oTableAtt:AddView(oNotaCreIn)

Return (oTableAtt)
