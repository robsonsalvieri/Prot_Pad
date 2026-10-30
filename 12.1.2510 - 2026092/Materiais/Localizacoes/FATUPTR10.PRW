#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'FATUPTR10.CH'

PUBLISH MODEL REST NAME FATUPTR10
/*/{Protheus.doc} FATUPTR10
Browse para el documento de Facturas de salida y guias de despacho
@author 	adrian perez
@since 		08/2026
@version	12.1.2210 / Superior
/*/

Function FATUPTR10()

Local oBrowse := FWMBrowse():New()
Local aCores    		 := {}
Local nX				 := 0
Local oTableAtt			 := Nil
Local nIndex             := 1
Local lOrderAsc          := .T.
Local lSmartBro			 := .F.
Local cAux				 :=""
Local lOk 				:=.F.

Local	nMV_PAR01:=3  // Status del documento	
Local	nMV_PAR02:=3  // Datos do Transportes      
Local	nMV_PAR03:=3  //Tipo de Documento    

	if fValDicc()
		lOk:=Pergunte("TRANSUPD10",.T.)
	 	IF lOk
			nMV_PAR01:=MV_PAR01  // Status del documento	
			nMV_PAR02:=MV_PAR02  // Datos do Transportes  
			nMV_PAR03:=MV_PAR03  //Tipo de Documento    
		

			lSmartBro:=hasSmartX()
			oBrowse:SetAlias('SF2')
			oBrowse:SetDescription( STR0016) // STR0016 Actualizar Datos de Transporte

			AAdd(aCores,{  fFiltros(.F.,2,2,3)	, 'BR_VERDE'    ,STR0001})	 	// STR0001  Documento completo  ( todos los campos están completos pero el documento no fue transmitido ) No transmitido(2) con campos llenados(2)
			AAdd(aCores,{  fFiltros(.F.,2,1,3)	, 'BR_VERMELHO' ,STR0002})	    // STR0002 Información pendiente  (alguno de los datos debe estar en blanco)  No transmitido(2) con campos Pendiente(1)-
			AAdd(aCores,{  fFiltros(.F.,1,3,3)	, 'BR_CINZA'	,STR0003})	 	//STR0003 Documento transmitido(1) (documento ha sido transmitido y aceptado por el gobierno).
		
			For nX :=1 To Len(aCores) 
				
				oBrowse:addLegend(aCores[nX][1],aCores[nX][2],aCores[nX][3])
				
			Next nX

			If lSmartBro
				cAux:="@"+fFiltros(lSmartBro,nMV_PAR01,nMV_PAR02,nMV_PAR03) 
				oBrowse:setSmartX(nIndex,lOrderAsc)
				oBrowse:AddFilterSmartX(cAux)
			Else
				oBrowse:SetFilterDefault( fFiltros(lSmartBro,nMV_PAR01,nMV_PAR02,nMV_PAR03) ) 
			EndIF

			oBrowse:SetAttach(.T.)
			oTableAtt := TableAttDef()


			If oTableAtt <> Nil
				oBrowse:SetViewsDefault( oTableAtt:aViews )
			EndIf

			oBrowse:Activate()
		EndIF
	EndIF
Return Nil


/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	adrian.perez
@since 		08/2026
@version	12.1.2410 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}


	ADD OPTION aRotina TITLE STR0004		ACTION 'viewTrp(1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0  // STR0004 'Visualizar'
	ADD OPTION aRotina TITLE STR0005 	    ACTION 'viewTrp(4)'		OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0  // STR0005 modificar

	
	
Return aRotina

/*/{Protheus.doc} viewTrp
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior
@param     nOperation  numerico  operación a ser realizada.
@Return 
/*/

Function viewTrp( nOperation)
Local cOperation := OemToAnsi(STR0004) // STR0004 'Visualizar'

Default nOperation	:= 3

	If nOperation == MODEL_OPERATION_UPDATE
		cOperation := OemToAnsi(STR0005) // STR0005 MODIFICAR
	EndIf

	
	FwExecView(cOperation,"VIEWDEF.FATUPTR10",nOperation,,{|| .T.})
	
Return 

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de Facturas de entrada.
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior
@Return oTableAtt  Objeto  FWTableAtt objeto con la definición de las visiones de la rutina.
/*/
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visiones
Local oDespa		:= Nil 
Local oFact			:= Nil

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF2")

	oDespa := FWDSView():New()
	oDespa:SetName(STR0006)//STR0006 'Despachos'
	oDespa:SetID(STR0006)  //STR0006 'Despachos'
	oDespa:SetOrder(2) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE                                                                                                            
	oDespa:SetCollumns({"F2_FILIAL","F2_CLIENTE","F2_LOJA","F2_DOC","F2_SERIE","F2_EMISSAO","F2_ESPECIE","F2_TIPODOC","F2_TIPO"})
	oDespa:SetPublic( .T. )
	oDespa:AddFilter(STR0006, "F2_TIPO == 'N' .AND. F2_TIPODOC == '50'") //STR0006 'Despachos'
	oTableAtt:AddView(oDespa)


	oFact := FWDSView():New()
	oFact:SetName(STR0007)// "STR0007 Facturas"
	oFact:SetID(STR0007) // STR0007 "Facturas"
	oFact:SetOrder(2) // F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO                                                                                                            
	oFact:SetCollumns({"F2_FILIAL","F2_DOC","F2_SERIE","F2_FORNECE","F2_LOJA","F2_TIPO"})
	oFact:SetPublic( .T. )
	oFact:AddFilter(STR0007, "F2_TIPO == 'N' .AND. F2_TIPODOC == '01'") // STR0007 "Facturas"
	oTableAtt:AddView(oFact)


Return (oTableAtt)


/*/{Protheus.doc} fFiltros
La función fFiltros() construye dinámicamente un filtro para consultar documentos de ventas según:

Estado de transmisión .
Estado de los datos de transporte.
Tipo de documento.
Modo de ejecución (Browse estándar o SmartBrowse).

@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior

@param	lSmartBro	Lógico	.F.	Indica si el filtro será construido para SmartBrowse (.T.) o Browse estándar (.F.).
@param	nPre1		Numérico	3	Estado del documento cuando no se utiliza Pergunte.
@param	nPre2		Numérico	3	Estado de los datos de transporte cuando no se utiliza Pergunte.
@param	nPre3		Numérico	3	Tipo de documento cuando no se utiliza Pergunte.

@Return  		  cFiltro Carácter filtro usado
/*/

function fFiltros(lSmartBro,nPre1,nPre2,nPre3)

Local cFiltro:="" 
Local nMV_PAR01:=3
Local nMV_PAR02:=3
Local nMV_PAR03:=3

Local cSpaTRANS:=SPACE(GetSx3Cache("F2_TRANSP","X3_TAMANHO"))
Local cSpaRUCMO:=SPACE(GetSx3Cache("F2_RUCMOTO","X3_TAMANHO"))
Local cSpaNoRuc:=SPACE(GetSx3Cache("F2_NOMEMO","X3_TAMANHO"))
Local cSpaVEH1:=SPACE(GetSx3Cache("F2_VEICUL1","X3_TAMANHO"))
Local cSpaVEH2:=SPACE(GetSx3Cache("F2_VEICUL2","X3_TAMANHO"))
Local cSpaDTHOR:=SPACE(GetSx3Cache("F2_HORASAI","X3_TAMANHO"))
Local cSpATIPOPE:=SPACE(GetSx3Cache("F2_TIPOPE","X3_TAMANHO"))
Local cSpaFle:= SPACE(GetSx3Cache("F2_FLFTEX","X3_TAMANHO"))

Default lSmartBro:=.F.
Default nPre1:=3
Default nPre2:=3
Default nPre3:=3

nMV_PAR01:=nPre1  // Status del documento	Transmitido /NoTransmitido /Ambos
nMV_PAR02:=nPre2  // Datos do Transportes      Pendientes/Llenados/Ambos
nMV_PAR03:=nPre3  //Tipo de Documento    Factura/Guia Despacho 
	
	IF !lSmartBro


		if nMV_PAR01==1
			cFiltro:="  F2_FLFTEX=='6'"  //Transmitido
		elseIf nMV_PAR01==2
			cFiltro:=" (F2_FLFTEX =='"+cSpaFle+"' .OR. F2_FLFTEX =='0' )"  // NoTransmitido
		else 
			cFiltro:=" (F2_FLFTEX == '"+cSpaFle+"' .OR. (F2_FLFTEX =='0' .OR. F2_FLFTEX=='6')) " //Ambos
		EndIF


		if nMV_PAR02==1
			cFiltro+=" .AND. ((F2_TRANSP=='"+cSpaTRANS+"' ) .OR. (F2_RUCMOTO=='"+cSpaRUCMO+"' )  .OR. (F2_NOMEMO=='"+cSpaNoRuc+"' ) "  //PENDIENTES
			cFiltro+=" .OR. (F2_VEICUL1=='"+cSpaVEH1+"' ) .OR. (F2_VEICUL2=='"+cSpaVEH2+"' )  .OR. (EMPTY(F2_DTSAIDA))  " 
			cFiltro+=" .OR. (F2_HORASAI=='"+cSpaDTHOR+"' ) .OR. (EMPTY(F2_DTENTR) )  .OR. (F2_TIPOPE=='"+cSpATIPOPE+"' ) )" 
		
		elseIf nMV_PAR02==2
			cFiltro+=" .AND.( (F2_TRANSP!='"+cSpaTRANS+"' ) .AND. (F2_RUCMOTO !='"+cSpaRUCMO+"'  ) .AND. (F2_NOMEMO!='"+cSpaNoRuc+"' )  "  // llenados
			cFiltro+=" .AND. (F2_VEICUL1!='"+cSpaVEH1+"' )  .AND. (F2_VEICUL2!='"+cSpaVEH2+"' )  .AND. (!EMPTY(F2_DTSAIDA) ) " 
            cFiltro+=" .AND. (F2_HORASAI!='"+cSpaDTHOR+"' ) .AND. (!EMPTY(F2_DTENTR)  )  .AND. (F2_TIPOPE!='"+cSpATIPOPE+"' ) )" 
		else 
			cFiltro+=" .AND.( (F2_TRANSP!='"+cSpaTRANS+"' .OR. F2_TRANSP=='"+cSpaTRANS+"'   ) .OR. (F2_RUCMOTO =='"+cSpaRUCMO+"'  .OR. F2_RUCMOTO !='"+cSpaRUCMO+"'  ) .OR. (F2_NOMEMO!='"+cSpaNoRuc+"' .OR. F2_NOMEMO=='"+cSpaNoRuc+"'   )  " 	//Ambos
			cFiltro+=" .OR. (F2_VEICUL1!='"+cSpaVEH1+"' .OR. F2_VEICUL1=='"+cSpaVEH1+"'   ) .OR. (F2_VEICUL2 =='"+cSpaVEH2+"'  .OR. F2_VEICUL2 !='"+cSpaVEH2+"'  ) .OR. (!EMPTY(F2_DTSAIDA) .OR. EMPTY(F2_DTSAIDA)  )  "
			cFiltro+=" .OR. (F2_HORASAI!='"+cSpaDTHOR+"' .OR. F2_HORASAI=='"+cSpaDTHOR+"'   ) .OR. (EMPTY(F2_DTENTR)     .OR. !EMPTY(F2_DTENTR)  ) .OR. (F2_TIPOPE!='"+cSpATIPOPE+"' .OR. F2_TIPOPE=='"+cSpATIPOPE+"'   ))  "
		EndIF 


		cFiltro+=" .AND. F2_TIPO == 'N' "
		if nMV_PAR03==1
			cFiltro+=" .AND. F2_TIPODOC=='01' "  //Facturas
		elseIf nMV_PAR03==2
			cFiltro+=" .AND. F2_TIPODOC=='50' " //Guia Despacho
		else 
			cFiltro+=" .AND. (F2_TIPODOC == '50' .OR. F2_TIPODOC == '01')" //Ambos
		EndIF

	ELSE


		if nMV_PAR01==1
			cFiltro:="  F2_FLFTEX='6'"  //Transmitido
		elseIf nMV_PAR01==2
			cFiltro:="(F2_FLFTEX ='"+cSpaFle+"' OR F2_FLFTEX ='0' )"  // NoTransmitido
		else 
			cFiltro:="(F2_FLFTEX ='"+cSpaFle+"' OR (F2_FLFTEX ='0' OR F2_FLFTEX='6')) " //Ambos
		EndIF


	
	    if nMV_PAR02=1
            cFiltro+=" AND( (F2_TRANSP='"+cSpaTRANS+"' ) OR (F2_RUCMOTO='"+cSpaRUCMO+"' )  OR (F2_NOMEMO='"+cSpaNoRuc+"' ) "  //PENDIENTES
            cFiltro+=" OR (F2_VEICUL1='"+cSpaVEH1+"' ) OR (F2_VEICUL2='"+cSpaVEH2+"' )  OR (F2_DTSAIDA='' ) " 
            cFiltro+=" OR (F2_HORASAI='"+cSpaDTHOR+"' ) OR (F2_DTENTR='' )  OR (F2_TIPOPE='"+cSpATIPOPE+"' )) " 
		
			
        elseIf nMV_PAR02=2

            cFiltro+=" AND ((F2_TRANSP!='"+cSpaTRANS+"' ) AND (F2_RUCMOTO !='"+cSpaRUCMO+"'  ) AND (F2_NOMEMO!='"+cSpaNoRuc+"' ) "  // llenados
			cFiltro+=" AND (F2_VEICUL1!='"+cSpaVEH1+"' ) AND (F2_VEICUL2!='"+cSpaVEH2+"' )  AND (F2_DTSAIDA!='' ) " 
            cFiltro+=" AND (F2_HORASAI!='"+cSpaDTHOR+"' ) AND (F2_DTENTR!='' )  AND (F2_TIPOPE!='"+cSpATIPOPE+"' )) " 

        else 
       		cFiltro+=" AND ( (F2_TRANSP!='"+cSpaTRANS+"' OR F2_TRANSP='"+cSpaTRANS+"'   ) OR (F2_RUCMOTO ='"+cSpaRUCMO+"'  OR F2_RUCMOTO !='"+cSpaRUCMO+"'  ) OR (F2_NOMEMO!='"+cSpaNoRuc+"' OR F2_NOMEMO='"+cSpaNoRuc+"'   )  "     //Ambos
            cFiltro+=" OR (F2_VEICUL1!='"+cSpaVEH1+"' OR F2_VEICUL1='"+cSpaVEH1+"'   ) OR (F2_VEICUL2 ='"+cSpaVEH2+"'  OR F2_VEICUL2 !='"+cSpaVEH2+"'  ) OR (F2_DTSAIDA!='' OR F2_DTSAIDA=''   )  "
            cFiltro+=" OR (F2_HORASAI!='"+cSpaDTHOR+"' OR F2_HORASAI='"+cSpaDTHOR+"'   ) OR (F2_DTENTR =''  OR F2_DTENTR !=''  ) OR (F2_TIPOPE!='"+cSpATIPOPE+"' OR F2_TIPOPE='"+cSpATIPOPE+"'   ))  "

        EndIF


		cFiltro+=" AND F2_TIPO = 'N' "
		if nMV_PAR03==1
			cFiltro+=" AND F2_TIPODOC='01' "  //Facturas
		elseIf nMV_PAR03==2
			cFiltro+=" AND F2_TIPODOC='50' " //Guia Despacho
		else 
			cFiltro+=" AND (F2_TIPODOC = '50' OR F2_TIPODOC = '01')" //Ambos
		EndIF
	ENDIF



return cFiltro


/*/{Protheus.doc} fBoxTIPO
Construye y retorna una cadena con las opciones de tipo de operación para selección 
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior
@Return  cOpcBox Carácter lista de opciones a mostrar en el campo F2_TIPOPE
/*/


FUNCTION   fBoxTIPO()


 Local cOpcBox := ""

	cOpcBox +=(OemtoAnsi(	STR0008 ) ) 	//STR0008   1. Operación constituye venta 
	cOpcBox +=(OemtoAnsi(	STR0009	) ) 	//STR0009   2. Ventas por efectuar 
	cOpcBox +=(OemtoAnsi(	STR0010	) )		//STR0010   3. Consignaciones 
	cOpcBox +=(OemtoAnsi(	STR0011	) ) 	//STR0011   4. Entrega gratuita 
	cOpcBox +=(OemtoAnsi(	STR0012	) ) 	//STR0012   5. Traslados internos 
	cOpcBox +=(OemtoAnsi(	STR0013	) ) 	//STR0013   6. Otros traslados no venta 
	cOpcBox +=(OemtoAnsi(	STR0014	) ) 	//STR0014   7: Venta para exportación.
	cOpcBox +=(OemtoAnsi(   STR0015) ) 	    //STR0015    8. Traslado para exportación (No venta) 

return ( cOpcBox ) 






/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	adrian.perez
@return		oModel objeto del Modelo
@since 		08/2026
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local aCampCAB      := {"F2_CLIENTE", "F2_LOJA", "F2_SERIE", "F2_DOC","F2_EMISSAO","F2_ESPECIE","F2_MOEDA","F2_NATUREZ","F2_TXMOEDA","F2_REFMOED","F2_TRANSP","F2_RUCMOTO","F2_NOMEMO","F2_VEICUL1","F2_VEICUL2","F2_DTSAIDA","F2_HORASAI","F2_DTENTR","F2_TIPOPE","F2_FLFTEX"} 
Local oModel        := Nil	
Local oStruSF2      := NIL
Local  xAux			:= NIL


  	oStruSF2    := FWFormStruct(1, 'SF2', { | cCampo | FindString(AllTrim(cCampo), aCampCAB)},.F.)
	
	oStruSF2:AddField(	AllTrim(FWX3Titulo("A1_NOME")),;												// 	[01]  C   Titulo do campo
				 	 AllTrim(FWX3Titulo("A1_NOME")),;													// 	[02]  C   ToolTip do campo
				 	"cNome",;																			// 	[03]  C   Id do Field
				 	"C",;																				// 	[04]  C   Tipo do campo
				 	GetSX3Cache("A1_NOME", "X3_TAMANHO"),;												// 	[05]  N   Tamanho do campo
				 	0,;																					// 	[06]  N   Decimal do campo
				 	NIL,;																				// 	[07]  B   Code-block de validação do campo
				 	NIL,;																				// 	[08]  B   Code-block de validação When do campo
				 	NIL,;																				//	[09]  A   Lista de valores permitido do campo
				 	.F.,;																				//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| F1IniName(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPODOC)},;						//	[11]  B   Code-block de inicializacao do campo
				 	NIL,;																				//	[12]  L   Indica se trata-se de um campo chave
				 	.F.,;																				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.)
	oStruSF2:AddField(	AllTrim(FWX3Titulo("A4_NOME")),;												// 	[01]  C   Titulo do campo
				 	 AllTrim(FWX3Titulo("A4_NOME")),;													// 	[02]  C   ToolTip do campo
				 	"cNomeTr",;																			// 	[03]  C   Id do Field
				 	"C",;																				// 	[04]  C   Tipo do campo
				 	GetSX3Cache("A4_NOME", "X3_TAMANHO"),;												// 	[05]  N   Tamanho do campo
				 	0,;																					// 	[06]  N   Decimal do campo
				 	NIL,;																				// 	[07]  B   Code-block de validação do campo
				 	NIL,;																				// 	[08]  B   Code-block de validação When do campo
				 	NIL,;																				//	[09]  A   Lista de valores permitido do campo
				 	.F.,;																				//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| fDatos(SF2->F2_TRANSP,"A4_NOME")},;						//	[11]  B   Code-block de inicializacao do campo
				 	NIL,;																				//	[12]  L   Indica se trata-se de um campo chave
				 	.F.,;																				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.)
		oStruSF2:AddField(	AllTrim(FWX3Titulo("A4_CGC")),;												// 	[01]  C   Titulo do campo
				 	 AllTrim(FWX3Titulo("A4_CGC")),;													// 	[02]  C   ToolTip do campo
				 	"cRUT",;																			// 	[03]  C   Id do Field
				 	"C",;																				// 	[04]  C   Tipo do campo
				 	GetSX3Cache("A4_CGC", "X3_TAMANHO"),;												// 	[05]  N   Tamanho do campo
				 	0,;																					// 	[06]  N   Decimal do campo
				 	NIL,;																				// 	[07]  B   Code-block de validação do campo
					NIL,;																				// 	[08]  B   Code-block de validação When do campo
				 	NIL,;																				//	[09]  A   Lista de valores permitido do campo
				 	.F.,;																				//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| fDatos(SF2->F2_TRANSP,"A4_CGC")},;						//	[11]  B   Code-block de inicializacao do campo
				 	NIL,;																				//	[12]  L   Indica se trata-se de um campo chave
				 	.F.,;																				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.)

	xAux := FwStruTrigger('F2_TRANSP', 'cNomeTr', 'fDatos(FwFldGet("F2_TRANSP"),"A4_NOME")', .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])


	xAux := FwStruTrigger('F2_TRANSP', 'cRUT', 'fDatos(FwFldGet("F2_TRANSP"),"A4_CGC")', .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

    oModel 		:= MPFormModel():New( 'FATUPTR10',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
    oModel:addFields('SF2_MASTER',,oStruSF2)


	oModel:SetVldActivate({|oModel| PreValid(oModel)})



Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()


Local aCampCAB      := {"F2_CLIENTE", "F2_LOJA", "F2_SERIE", "F2_DOC","F2_EMISSAO","F2_ESPECIE","cNome"} 
Local aCampMO       :={"F2_TRANSP","F2_RUCMOTO","F2_NOMEMO","F2_VEICUL1","F2_VEICUL2","F2_DTSAIDA","F2_HORASAI","F2_DTENTR","F2_TIPOPE","cNomeTr","cRUT"}
Local oView         := Nil
Local oCab      := NIL
Local oEdit  := NIL

Local oModel := FWLoadModel('FATUPTR10')


    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:SetContinuousForm(.T.)

    oCab := FWFormStruct(2, 'SF2', { | cCampo | FindString(AllTrim(cCampo), aCampCAB)},.F.) 
    oEdit    := FWFormStruct(2, 'SF2', { | cCampo | FindString(AllTrim(cCampo), aCampMO)},.F.)
  
	oCab:AddField("cNome", "01", GetSX3Cache("A1_NOME", "X3_TITSPA"),"", Nil, "C")
	oEdit:AddField("cNomeTr", "01",GetSX3Cache("A4_NOME", "X3_TITSPA"),"", Nil, "C")
	oEdit:AddField("cRUT", "01",GetSX3Cache("A4_CGC", "X3_TITSPA"), "", Nil, "C")

    oView:AddField('oCab' , oCab, 'SF2_MASTER' )
    oView:AddField('oEdit'  ,oEdit, 'SF2_MASTER')
	
    oView:GetViewStruct("oCab"):SetProperty("F2_CLIENTE", MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oCab"):SetProperty("cNome", MVC_VIEW_CANCHANGE,.F.)
    oView:GetViewStruct("oCab"):SetProperty("F2_LOJA", MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oCab"):SetProperty("F2_SERIE", MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oCab"):SetProperty("F2_DOC", MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oCab"):SetProperty("F2_EMISSAO", MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oCab"):SetProperty("F2_ESPECIE", MVC_VIEW_CANCHANGE,.F.)


	oView:GetViewStruct("oCab"):SetProperty("F2_CLIENTE", MVC_VIEW_ORDEM,"01")
	oView:GetViewStruct("oCab"):SetProperty("cNome", MVC_VIEW_ORDEM,"02")
    oView:GetViewStruct("oCab"):SetProperty("F2_LOJA", MVC_VIEW_ORDEM,"03")
	oView:GetViewStruct("oCab"):SetProperty("F2_SERIE", MVC_VIEW_ORDEM,"04")
	oView:GetViewStruct("oCab"):SetProperty("F2_DOC", MVC_VIEW_ORDEM,"05")
	oView:GetViewStruct("oCab"):SetProperty("F2_EMISSAO", MVC_VIEW_ORDEM,"06")
	oView:GetViewStruct("oCab"):SetProperty("F2_ESPECIE", MVC_VIEW_ORDEM,"07")

	oView:GetViewStruct("oEdit"):SetProperty("cNomeTr",  MVC_VIEW_CANCHANGE,.F.)
	oView:GetViewStruct("oEdit"):SetProperty("cRUT",  MVC_VIEW_CANCHANGE,.F.)

	oView:GetViewStruct("oEdit"):SetProperty("F2_TRANSP", MVC_VIEW_ORDEM,"01")
	oView:GetViewStruct("oEdit"):SetProperty("cNomeTr", MVC_VIEW_ORDEM,"02")
	oView:GetViewStruct("oEdit"):SetProperty("cRUT", MVC_VIEW_ORDEM,"03")
    oView:GetViewStruct("oEdit"):SetProperty("F2_RUCMOTO", MVC_VIEW_ORDEM,"04")
	oView:GetViewStruct("oEdit"):SetProperty("F2_NOMEMO", MVC_VIEW_ORDEM,"05")
	oView:GetViewStruct("oEdit"):SetProperty("F2_VEICUL1", MVC_VIEW_ORDEM,"06")
	oView:GetViewStruct("oEdit"):SetProperty("F2_VEICUL2", MVC_VIEW_ORDEM,"07")
	oView:GetViewStruct("oEdit"):SetProperty("F2_TIPOPE", MVC_VIEW_ORDEM,"08")
	oView:GetViewStruct("oEdit"):SetProperty("F2_HORASAI", MVC_VIEW_ORDEM,"09")
	oView:GetViewStruct("oEdit"):SetProperty("F2_DTENTR", MVC_VIEW_ORDEM,"10")
	
	
	oView:EnableTitleView('oCab', STR0017 ) //STR0017 Datos documento
    oView:EnableTitleView('oEdit', STR0018) // STR0018 Datos transporte
        
    oView:CreateHorizontalBox( 'CIMA' , 35)
	oView:CreateHorizontalBox( 'MEDIO', 35)
	
    oView:SetOwnerView('oCab', 'CIMA')
    oView:SetOwnerView('oEdit', 'MEDIO')



Return oView

/*/{Protheus.doc} fDatos
Obtiene el valor de un campo específico de la tabla SA4 utilizando una clave compuesta por la filial y un dato proporcionado. La búsqueda se realiza mediante la función Posicione().
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior

@cDato	Caracter	Valor utilizado como parte de la clave de búsqueda en la tabla SA4. Si está vacío, no se realiza la consulta.
@cCampo	Caracter	Nombre del campo que se desea recuperar de la tabla SA4.

@return		cName   Caracter Dato del campo 


/*/

 FUNCTION fDatos(cDato,cCampo) 
Local cName     := ""
Local cTable    := "SA4"


Default cDato := ""
Default cCampo:=""


	IF !EMPTY(cDato) .AND. !EMPTY(cCampo) 

		cName := Posicione(cTable,1,FWxFilial(cTable)+cDato,cCampo)
		
	ENDIF
Return cName


/*/{Protheus.doc} PreValid
Función de prevalidación utilizada en el modelo MVC de Protheus. Su objetivo es impedir la modificación de un documento cuando el campo F2_FLFTEX de la tabla SF2 tiene el valor '6', indicando que el documento ya fue transmitido.
@author 	adrian.perez
@since 		08/2026
@version	12.1.2210 / Superior

@param		oModel   Objeto Instancia del modelo MVC que ejecuta la validación previa. En esta función no se utiliza directamente, pero se recibe para cumplir con la estructura estándar de las validaciones MVC
@return		lRet     Lógico (.T. / .F.)Retorna .T. cuando la operación puede continuar. Retorna .F. cuando el documento ya fue transmitido y no debe permitirse su modificación.


/*/

Static Function PreValid(oModel)
Local lRet 			:= .T.
Local nOpera := oModel:GetOperation()


If SF2->F2_FLFTEX == '6' .AND. nOpera == MODEL_OPERATION_UPDATE
	Help( ,, 'HELP',, STR0003, 1, 0)      
	lRet := .F.
EndIf

Return (lRet)



/*/{Protheus.doc} fValDicc
    Función  para validar datos del diccionario para el SIRCIP
    @type  Function
    @author adrian.perez
    @since   08/2026
    @return lRet    booleano .T. indica no que existe errores , .F. indica que existe errores
    /*/  


Static function fValDicc()
Local lRet:=.T.

	if SF2->(ColumnPos("F2_TRANSP")) > 0 .AND.	 SF2->(ColumnPos("F2_RUCMOTO"))>0 ;
	    .AND. SF2->(ColumnPos("F2_NOMEMO"))>0     .AND. SF2->(ColumnPos("F2_VEICUL1") )>0 .AND.SF2->(ColumnPos("F2_VEICUL2") )>0 .AND.;
		SF2->(ColumnPos("F2_DTSAIDA"))>0   .AND. ;
		SF2->(ColumnPos("F2_HORASAI"))>0   .AND. ;
		SF2->(ColumnPos("F2_DTENTR"))>0  .AND. ;
		SF2->(ColumnPos("F2_TIPOPE"))>0 

			lRet:=.T.
	ELSE
		Help(STR0019,1,STR0019 , NIL,STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0021}) // STR0020 "Error diccionario "	//STR0021"'Verifique campos de las tablas SF2 para esta rutina'                " // STR0019 "Atención"  
		lRet:=.F.

	EndIF

return lRet

