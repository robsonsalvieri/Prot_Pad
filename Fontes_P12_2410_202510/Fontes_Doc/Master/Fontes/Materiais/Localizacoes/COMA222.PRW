#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'COMA222.CH'

/*/{Protheus.doc} COMA222
Browse para el documento de Facturas de Entrada
@author 	raul.medina
@since 		03/2024
@version	12.1.2210 / Superior
/*/

Function COMA222()
Local oBrowse	:= Nil

	If !(cPaisLoc $ "ARG|COL|MEX|PAR|PER|EQU|CHI")
		SetFunName("MATA101N")
    	Mata101n()
	Else
		If FindFunction("MxChkPE")
			MxChkPE("COMA222")
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
Local oBrowse := FWMBrowse():New()
Local aCores    := {}
Local nX		:= 0
Local oTableAtt	:= Nil
Local lConffis	:= SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
Local lIntegracao	:= SuperGetMV("MV_EASY",.F.,"N")=="S"    //Integracao SIGAEIC

    oBrowse:SetAlias('SF1')
	If lIntegracao
		AAdd(aCores,{'Empty(F1_STATUS) .AND. !Empty(F1_TIPO_NF)','BR_VERDE'})				// NF Importacao (nao classificada)
		AAdd(aCores,{'F1_STATUS=="A" .AND. !Empty(F1_TIPO_NF)','BR_PRETO'})	    			// NF Importacao (classificada)
	Endif
	If lConffis
		AAdd(aCores,{  '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .And. F1_TIPO	==	"N"	.AND. F1_TIPODOC	==	"10"   '	, 'DISABLE'})	 // NF Normal
		AAdd(aCores,{  '!(F1_STATCON $ "1|4") .AND. !EMPTY(F1_STATCON)'															, 'BR_VIOLETA'}) // NF Bloq. para Conferencia
	Else
		AAdd(aCores,{  'F1_TIPO	==	"N"	.AND. F1_TIPODOC	==	"10"   '	, 'DISABLE'})		// NF Normal
	EndIf
	AAdd(aCores,{  'F1_TIPO	==	"B"	.AND. F1_TIPODOC	<>	"63"   '		, 'BR_CINZA'})		// NF Beneficiamento
	AAdd(aCores,{  'F1_TIPO	==	"C"	.AND. F1_TIPODOC	$	"13/14"'		, 'BR_LARANJA'})	// Desp.Importacao
	AAdd(aCores,{ 	'F1_TIPO	==	"A" 	.AND. F1_TIPODOC	==	"20"'	, 'BR_BRANCO'})	 // Adiantamento

    For nX :=1 To Len(aCores)
        oBrowse:addLegend(aCores[nX][1],aCores[nX][2])
    Next nX
    oBrowse:SetFilterDefault( "F1_TIPODOC $ '10/12/13/14'" )

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
Local lC222Mnu := ExistBlock("COMA222MNU")
	
	ADD OPTION aRotInc TITLE STR0006    ACTION 'LxViewNFe("N", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Fact.Normal'
	ADD OPTION aRotInc TITLE STR0011	ACTION 'LxViewNFe("G", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Gastos Imp.'
	ADD OPTION aRotInc TITLE STR0012    ACTION 'LxViewNFe("T", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Conoc. Transp.'

    ADD OPTION aRotina TITLE STR0002	ACTION aRotInc				OPERATION MODEL_OPERATION_INSERT	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0003 	ACTION 'LxViewNFe("", 1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004	ACTION 'LxViewNFe("", 5)' 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0009	ACTION 'CTBC662' 			OPERATION 2    						ACCESS 0 // 'Tracker Contábil'
	ADD OPTION aRotina TITLE STR0010	ACTION 'LxLegendIn()' 		OPERATION 2    						ACCESS 0 // 'Leyenda'
	
	If lC222Mnu
		aRotAux := ExecBlock("COMA222MNU",.F.,.F.,{aRotina})
		If (ValType(aRotAux) == "A")
			aRotina := aClone(aRotAux)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} LxViewNFe
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    cType - caracter - tipo de documento.
    nOperation - numerico - operación a ser realizada.
@Return 
/*/
Function LxViewNFe(cType, nOperation)
Local cOperation := OemToAnsi(STR0003) // 'Visualizar'

Default nOperation	:= 3
Default cType 		:= ""

	If Empty(cType)
		If SF1->F1_TIPODOC == "10"
			If SF1->(Columnpos("F1_AUTOFAC"))>0 .and. SF1->F1_AUTOFAC == "1"
				cType := "AF"
			Else
				cType := "N"
			EndIf
		ElseIf SF1->F1_TIPODOC == "13"
			cType := "G"
		ElseIf SF1->F1_TIPODOC == "14"
			cType := "T"
		ElseIf SF1->F1_TIPODOC == "20"
			cType := "A"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0002) // 'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0004) // 'Excluir'
	EndIf

	If cType == "N"
		aCfgNf  := MontaCfgNf(10,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX10",nOperation,,{|| .T.}) 
	ElseIf cType == "G"
		aCfgNf  := MontaCfgNf(13,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX13",nOperation,,{|| .T.}) 
	ElseIf cType == "T"
		aCfgNf  := MontaCfgNf(14,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX14",nOperation,,{|| .T.})
	ElseIf cType == "A"
		aCfgNf  := MontaCfgNf(20,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX20",nOperation,,{|| .T.})
	ElseIf cType == "S"
		aCfgNf  := MontaCfgNf(10,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX10SOP",nOperation,,{|| .T.}) 
	ElseIf cType == "AF"
		aCfgNf  := MontaCfgNf(10,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX10AUT",nOperation,,{|| .T.}) 
	EndIf

Return

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de Facturas de entrada.
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
Local oFacNormal		:= Nil // "Fact. Normal"
Local oFacBenef			:= Nil // "Fact. Benef."
Local oFacGasImp		:= Nil // "Gastos Imp./Flete"

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oFacNormal := FWDSView():New()
	oFacNormal:SetName(STR0006)// "Fact. Normal"
	oFacNormal:SetID("FacNormal")
	oFacNormal:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oFacNormal:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oFacNormal:SetPublic( .T. )
	oFacNormal:AddFilter(STR0006, "F1_TIPO == 'N' .AND. F1_TIPODOC == '10'") // "Fact. Normal"
	oTableAtt:AddView(oFacNormal)

	oFacBenef := FWDSView():New()
	oFacBenef:SetName(STR0007)// "Fact. Benef."
	oFacBenef:SetID("FacBenef")
	oFacBenef:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oFacBenef:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oFacBenef:SetPublic( .T. )
	oFacBenef:AddFilter(STR0007, "F1_TIPO == 'B' .AND. F1_TIPODOC == '12'") // "Remitos Benef."
	oTableAtt:AddView(oFacBenef)

	oFacGasImp := FWDSView():New()
	oFacGasImp:SetName(STR0008)// "Gastos Imp./Flete"
	oFacGasImp:SetID("FacGasImp")
	oFacGasImp:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oFacGasImp:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oFacGasImp:SetPublic( .T. )
	oFacGasImp:AddFilter(STR0008, "F1_TIPO == 'C' .AND. F1_TIPODOC $ '13/14'") // "Gastos Imp./Flete"
	oTableAtt:AddView(oFacGasImp)

Return (oTableAtt)
