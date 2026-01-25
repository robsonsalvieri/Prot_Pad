#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH' 
#INCLUDE "FWLIBVERSION.CH"

PUBLISH MODEL REST NAME FINA887

Static __lMetric  := FwLibVersion() >= "20210517"

/*/{Protheus.doc} FINA887
Fonte de cobros diversos (Padrão)
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/
 
Function FINA887()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	
	
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FJT')
oBrowse:SetDescription(STR0097)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0087 ACTION 'VIEWDEF.FINA887' OPERATION 1 ACCESS 0		// 'Buscar'
	ADD OPTION aRotina TITLE STR0088 ACTION 'VIEWDEF.FINA887' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0089 ACTION 'VIEWDEF.FINA887' OPERATION 3 ACCESS 0 	// 'Incluir'
	ADD OPTION aRotina TITLE STR0090 ACTION 'VIEWDEF.FINA887' OPERATION 4 ACCESS 0 	// 'Alterar'
	ADD OPTION aRotina TITLE STR0091 ACTION 'VIEWDEF.FINA887' OPERATION 6 ACCESS 0	// 'Imprimir'
	ADD OPTION aRotina TITLE STR0092 ACTION 'VIEWDEF.FINA887' OPERATION 7 ACCESS 0 	// 'Enviar'

	ADD OPTION aRotina TITLE STR0093 ACTION 'VIEWDEF.FINA887' OPERATION 8 ACCESS 0 //"Anular"
	ADD OPTION aRotina TITLE STR0094 ACTION 'VIEWDEF.FINA887' OPERATION 9 ACCESS 0 //"Borrar"
	IF cPaisloc == "MEX" 
		ADD OPTION aRotina TITLE STR0095 ACTION 'VIEWDEF.FINA887' OPERATION 10 ACCESS 0 //"Generar CFDI"
	ENDIF
	IF cPaisloc == "ARG" 
		ADD OPTION aRotina TITLE STR0096 ACTION 'VIEWDEF.FINA887' OPERATION 11 ACCESS 0 //"Modificar"
	ENDIF
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function ModelDef()
Local cCampSE1		:= "E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_SALDO,E1_DESCONT,E1_MULTA,E1_JUROS,E1_MOEDA,E1_CANCEL,E1_NATUREZ,E1_MOTIVO,E1_EMISSAO,E1_VENCTO,E1_VALOR,E1_ORIGEM,E1_FILORIG,E1_XPERDES"
Local oStruFJT		:= FWFormStruct(1, 'FJT', , .F.)
Local oStruSEL		:= FWFormStruct(1, 'SEL', , .F.)
Local oStruSE1 		:= FWFormStruct(1, 'SE1', { | cCampo | AllTrim( cCampo ) $ cCampSE1 .or. (GetSx3Cache(cCampo, "X3_CONTEXT") == "V" .and. GetSx3Cache(cCampo, "X3_PROPRI") == "U")  }, .F.)
Local oStruMOE		:= FWFormModelStruct():New()
Local oStruGEN		:= FWFormModelStruct():New()
Local oStruADM		:= FWFormModelStruct():New()
Local oStruFAC		:= FWFormModelStruct():New()

Local oModel		:= Nil 
Local oEvtTit		:= F887FIN():New()
Local oEvtCtb		:= F887CTB():New()
Local nPosTpDoc		:= 0
local lFpadvpl 		:= SuperGetMv("MV_FPADVPL",.F.,.F.)
local lRecmvc 		:= SuperGetMv("MV_RECMVC",.F.,.F.)
Local nQtMoedas		:= Moedfin()
Local nX			:= 0
Local cMoeda		:= ""
Local cDescMoed		:= ""
Local cOrdTig		:= ""
Local cCent			:= ""
Local lPgoAutr		:= SuperGetMv("MV_PGOAUTR",.F.,.F.)
Local aCampos		:= {}
Local nLenDesMoe 	:= F887LnDesM()

	
	oStruFJT:AddField("GERANCC","GERANCC","GERANCC",'C',1) 
	oStruFJT:AddField("DOCUMEN","DOCUMEN","DOCUMEN",'C',3) //Para generar saldo - Para México y Perú no es considerado el contenido informado.
	oStruFJT:AddField("ASIENTO","ASIENTO","ASIENTO",'N',1) //Muestra Asientos.
	oStruFJT:AddField("AGRUPA" ,"AGRUPA" ,"AGRUPA" ,'N',1) //Agrupa Asientos.
	oStruFJT:AddField("ONLINE" ,"ONLINE" ,"ONLINE" ,'N',1) //Agrupa Asientos.
	oStruFJT:AddField("RAGENER" ,"RAGENER" ,"RAGENER" ,'L',1) //Para controlar la generación de RA
	oStruFJT:AddField("IMPRIMIR","IMPRIMIR","IMPRIMIR","L",1)//Indica si se realiza la impresión
	oStruFJT:AddField("EMAIL","EMAIL","EMAIL","L",1) //Indica si se realiza el envio del recibo
	oStruFJT:AddField("VLDNUMREC" ,"VLDNUMREC" ,"VLDNUMREC" ,'L',1) //Campo para saber si valida el numero de recibo (Falso para el grid de formas de pago )
	oStruFJT:AddField("TIMBRAR","TIMBRAR","TIMBRAR","L",1) //Indica si se realiza el envio del recibo
	oStruFJT:AddField("DATECOMP","DATECOMP","DATECOMP",'D',10) 
	oStruFJT:AddField("EDITCH" ,"EDITCH" ,"EDITCH" ,'L',1) //Para controlar la edición del cheque
	//Uso para Perú, sólo en sus eventos.
	oStruFJT:AddField("EMITCOM","EMITCOM","EMITCOM",'N',1)  //Emite comprobante
	oStruFJT:AddField("RUTCOM" ,"RUTCOM" ,"RUTCOM" ,'C',12) //Nombre rutina comprobante

	aAux := CreateTrigger('FJT_LOJA','FJT_COBRAD', 'ExecBlock("F998NRDCOB",.F.,.F.,{FwFldGet("FJT_CLIENT"),FwFldGet("FJT_LOJA")})','999','ExistBlock("F998NRDCOB")')
    oStruFJT:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	//Campos virtuales para busqueda de Bancos
	oStruSEL:AddField(STR0107,STR0108,"EL_BANCOS",'C', GetSx3Cache("EL_BANCO","X3_TAMANHO")+GetSx3Cache("EL_AGENCIA","X3_TAMANHO")+GetSx3Cache("EL_CONTA","X3_TAMANHO")+2) //STR0107  "Busc. Bancos"  STR0108 "Buscador de Bancos"
   
    aAux := CreateTrigger('EL_BANCOS','EL_AGENCIA', 'BancosRec(FwFldGet("EL_BANCOS"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_BANCOS','EL_CONTA', 'BancosRec(FwFldGet("EL_BANCOS"),"3")',"003")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

 	aAux := CreateTrigger('EL_BANCOS','EL_BANCO', 'BancosRec(FwFldGet("EL_BANCOS"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
	oStruSEL:AddField(STR0109,STR0110,"EL_BCOCHQS",'C',GetSx3Cache("EL_BCOCHQ","X3_TAMANHO")+GetSx3Cache("EL_AGECHQ","X3_TAMANHO")+GetSx3Cache("EL_CTACHQ","X3_TAMANHO")+2) //STR0109 "Busc. Bco Ch"  STR0110 "Buscador de Bancos Cheque"
    aAux := CreateTrigger('EL_BCOCHQS','EL_BCOCHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_BCOCHQS','EL_AGECHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
	aAux := CreateTrigger('EL_BCOCHQS','EL_CTACHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"3")',"003")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
	oStruSE1:AddField("CHECK"		,"CHECK"					,"CHECK"		,"L",1)
	oStruSE1:AddField("BAIXAR       ","BAIXAR                   ","BAIXAR"	    ,'N',16,2,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	oStruSE1:AddField("COBRAR       ","COBRAR                   ","COBRAR"	    ,'N',16,2,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	oStruSE1:AddField("SALDOPE      ","SALDOPE                  ","SALDOPE"	    ,'N',16,2,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	oStruSE1:AddField("RECNO        ","RECNO                    ","RECNO"	    ,'N',32 ,0,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)

	//Disparadores SE1
	cOrdTig := "001"
	aAux := CreateTrigger('CHECK','E1_DESCONT', 'E1CHECKDES()',cOrdTig)
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','E1_JUROS', 'E1CHECKINT()',cOrdTig)
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','COBRAR', 'E1CHECKBX()',cOrdTig)
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','E1_MOTIVO', '"NOR"',cOrdTig, 'FwFldGet("CHECK")')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','E1_MOTIVO', '',cOrdTig, '!FwFldGet("CHECK")')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','E1_MULTA', '0',cOrdTig, '!FwFldGet("CHECK")')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	cOrdTig := Soma1(cOrdTig)
	aAux := CreateTrigger('CHECK','SALDOPE', '0',cOrdTig, '!FwFldGet("CHECK")')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	For nX := 1 To nQtMoedas
		cMoeda := Str(nX,IIf(nX <= 9,1,2))
		cDescMoed := SuperGetMv("MV_MOEDA" + cMoeda, .F., "")
		If !Empty(cDescMoed)
			cCent := "MV_CENT" + Iif(nX>1, cMoeda, "")
			oStruSE1:AddField(cDescMoed, "Baja en " + cDescMoed, "BAIXAR"+cMoeda, 'N', 16, SuperGetMV(cCent, .F., 2), FWBuildFeature( STRUCT_FEATURE_VALID, 'Positivo()'), /*FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK")')*/, {}, .F., , .F., .F., .T., )
			
			aAux := CreateTrigger("BAIXAR"+cMoeda,'COBRAR', 'E1BXMOE()',"001", 'FwFldGet("CHECK")')
    		oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

			cOrdTig := Soma1(cOrdTig)
			aAux := CreateTrigger('CHECK',"BAIXAR"+cMoeda, 'FwFldGet("COBRAR")',cOrdTig, '' + cMoeda + ' == FwFldGet("E1_MOEDA") ')
    		oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

			cOrdTig := Soma1(cOrdTig)
			aAux := CreateTrigger('CHECK',"BAIXAR"+cMoeda, '0',cOrdTig, '!FwFldGet("CHECK")')
    		oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

			If lPgoAutr
				aAux := CreateTrigger('E1_DESCONT',"BAIXAR"+cMoeda, '0', , '' + cMoeda + ' != FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
				aAux := CreateTrigger('E1_DESCONT',"BAIXAR"+cMoeda, 'E1CHECKBX()', , '' + cMoeda + ' == FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
				aAux := CreateTrigger('E1_JUROS',"BAIXAR"+cMoeda, '0', , '' + cMoeda + ' != FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
				aAux := CreateTrigger('E1_JUROS',"BAIXAR"+cMoeda, 'E1CHECKBX()', , '' + cMoeda + ' == FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
				aAux := CreateTrigger('E1_MULTA',"BAIXAR"+cMoeda, '0', , '' + cMoeda + ' != FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
				aAux := CreateTrigger('E1_MULTA',"BAIXAR"+cMoeda, 'E1CHECKBX()', , '' + cMoeda + ' == FwFldGet("E1_MOEDA") ')
				oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

			EndIf
		EndIf
	Next
	
	
	aAux := CreateTrigger('E1_DESCONT','SALDOPE', 'E1SALDOPE()','001')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	aAux := CreateTrigger('E1_JUROS','SALDOPE', 'E1SALDOPE()','001')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	aAux := CreateTrigger('E1_MULTA','SALDOPE', 'E1SALDOPE()','001')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	
	aAux := CreateTrigger('COBRAR','SALDOPE', 'E1SALDOPE()','001')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	aAux := CreateTrigger('COBRAR','BAIXAR', 'E1BAIXAR()','002')
    oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	aAux := CreateTrigger('E1_DESCONT'	,'BAIXAR', 'E1BAIXAR()','003')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	aAux := CreateTrigger('E1_JUROS'	,'BAIXAR', 'E1BAIXAR()','003')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
	aAux := CreateTrigger('E1_MULTA'	,'BAIXAR', 'E1BAIXAR()','003')
	oStruSE1:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

	If lRecmvc .and. ExistBLock("F998NRMCOL")
		aCampos := ExecBLock("F998NRMCOL",.F.,.F.)
		For nX := 1 To Len(aCampos)
			If GetSx3Cache(aCampos[nX][1], "X3_CAMPO") <> NIL
				oStruSE1:AddField(aCampos[nX][2], aCampos[nX][2], aCampos[nX][1], GetSx3Cache(aCampos[nX][1], "X3_TIPO"), GetSx3Cache(aCampos[nX][1], "X3_TAMANHO"), GetSx3Cache(aCampos[nX][1], "X3_DECIMAL"),{||.T.},{||.T.},{},.F.,,.F.,.F.,.F.,)
			EndIf
		Next
	EndIf
	
	//Tabla de saldos y monedas
	oStruMOE:AddTable('' , { '' } , "SALDOMOEDA", {|| ''})
	oStruMOE:AddField('Moneda' 	, 'Moneda'	, 'MOEDA' 	, 'C' , 1)
	oStruMOE:AddField('Moneda' 	, 'Desc. Moneda', 'DESCMOEDA' , 'C' , nLenDesMoe)
	oStruMOE:AddField('Tasa' 	, 'Tasa' 	, 'TASA' 	, 'N' , 10, 4)
	oStruMOE:AddField('Recibido', 'Recibido', 'RECIBIDO', 'N' , 14, 2)
	oStruMOE:AddField('Saldo'	, 'Saldo'	, 'SALDO' 	, 'N' , 14, 2)

	//Tabla de datos generales
	oStruGEN:AddTable('' , { '' } , "GENERALES", {|| ''})
	oStruGEN:AddField('HourSave' 	, 'HourSave'	, 'HOURSAVERECEIPT' 	, 'C' , 8)

	//Tabla de administradoras financieras
	oStruADM:AddTable('', { '' }, "CAJAFINANCIERA",{|| ''})
	oStruADM:AddField('Codigo'		,'Codigo'		,'CODE'			,'C' ,6)
	oStruADM:AddField('Descripcion'	,'Descripcion'	,'DESCRIPTION'	,'C',30)

	//Tabla de factoraje
	oStruFAC:AddTable('', { '' }, "FACTORAJE",{|| ''})
	oStruFAC:AddField('Valor'		,'Valor'		,'VALUE'		,'N' ,16,2)
	oStruFAC:AddField('Valor'		,'Valor'		,'FACTOR'		,'C' ,1)

	oModel := MPFormModel():New( 'FINA887',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	
	oModel:addFields('FJT_MASTER',,oStruFJT)
	
	oModel:addGrid('SEL_DETAIL','FJT_MASTER',oStruSEL,,)

	oModel:AddGrid('SE1_DETAIL','FJT_MASTER',oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	oModel:addGrid('MOE_DETAIL','FJT_MASTER',oStruMOE,,)

	oModel:addGrid('GEN_DETAIL','FJT_MASTER',oStruGEN,,)

	oModel:addGrid('ADM_DETAIL','FJT_MASTER',oStruADM,,)

	oModel:addGrid('FAC_DETAIL','FJT_MASTER',oStruFAC,,)
	
	oModel:SetRelation('SEL_DETAIL', { { 'EL_FILIAL', 'FWxFilial("SEL")' }, { 'EL_SERIE', 'FJT_SERIE' }, { 'EL_RECIBO', 'FJT_RECIBO' } }, SEL->(IndexKey(1)) )
	
	oModel:SetRelation( 'SE1_DETAIL', { { 'E1_FILIAL', 'xFilial( "SE1" )' }, { 'E1_CLIENTE', 'FJT_CLIENT' }, { 'E1_LOJA', 'FJT_LOJA' },  { 'E1_RECIBO', 'FJT_RECIBO'} }, SE1->( IndexKey( 1 ) ) )

	//Inicializadores a campos
	If !lFpadvpl .And. !lRecmvc
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "TB" })
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_ENDOSSA'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TERCEIR'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_PREREC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_RECIBO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_EMISSAO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_DTVCTO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	ElseIf lRecmvc .And. Empty(GetSx3Cache("EL_TIPO","X3_RELACAO"))
		oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_INIT,	{|oModelGrid| MVCHEQUE })
	EndIF
	oStruSEL:SetProperty( 'EL_DTDIGIT', MODEL_FIELD_INIT, {|| dDataBase })

	//Retirada de validaciones con variables privadas	
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Pertence("|TB|CH") .Or. ' + GetSx3Cache("EL_TIPODOC","X3_VALID") ))
	oStruSEL:SetProperty( 'EL_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJA(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_LOJORIG'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJORI(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887VALTP(oModelGrid,.F.) } ) //FA840VALTP
	oStruSEL:SetProperty( 'EL_BANCO'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887BCO("EL_BANCO", .F.) } )
	oStruSEL:SetProperty( 'EL_BCOCHQ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887BCO("EL_BCOCHQ", .F.) } )
	oStruSEL:SetProperty( 'EL_MOEDA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887MOE(oModelGrid) } )
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887DIACTB(oModelGrid) } ) // Valida parametro SEGOFI
	oStruSE1:SetProperty( 'E1_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa840Bco
	oStruSE1:SetProperty( 'E1_CLIENTE'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE,,,,.F.) .and. fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE+M->E1_LOJA) .And. Fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_MOEDA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa040moed().and.fa040Irf().And.FA040VALOR()                                                                                                                                                                                          
	oStruSE1:SetProperty( 'E1_NATUREZ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_NUM'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PARCELA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PREFIXO'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_DESCONT'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Positivo()') ) // 
	oStruSE1:SetProperty( 'E1_JUROS'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Positivo()') ) // 
	oStruSE1:SetProperty( 'E1_MULTA'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Positivo()') ) // 
	oStruSE1:SetProperty( 'CHECK'		, 	MODEL_FIELD_VALID,	{|oModelGrid| F887CHECKTAX(oModelGrid) }  )

	//Asignación de WHEN a campos
	oStruSEL:SetProperty( 'EL_PREFIXO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //A840WHEN
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")

	//oStruSE1:SetProperty( 'CHECK'		, 	MODEL_FIELD_INIT ,	FWBuildFeature( STRUCT_FEATURE_INIPAD  , '.T.') )
 
	nPosTpDoc := aScan(oStruSEL:aFields, {|x| x[3] == "EL_TIPODOC"})
	If nPosTpDoc > 0
		AADD(oStruSEL:aFields[nPosTpDoc][MODEL_FIELD_VALUES], "TB=TB" )
	EndIf
	
	//limpiado de disparadores
	//oStruSEL:aTriggers := {}

	oStruSE1:SetProperty( '*' 			, 	MODEL_FIELD_OBRIGAT, .F.)

	oStruSEL:SetProperty( 'EL_FILIAL'	, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSEL:SetProperty( 'EL_RECIBO'	, 	MODEL_FIELD_OBRIGAT, .F.) 
	oStruSEL:SetProperty( 'EL_CLIORIG'	, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSEL:SetProperty( 'EL_LOJORIG'	, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSEL:SetProperty( 'EL_NATUREZ'	, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSEL:SetProperty( 'EL_COBRAD'	, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSEL:SetProperty( 'EL_PREREC'	, 	MODEL_FIELD_OBRIGAT, .F.)
	
	//Se retira inicializador, ya que cada vez que se consulta el model detona el inicializador
	If !lRecmvc .Or. !IsInCallStack("VIEWDEF")
		oStruFJT:SetProperty(  'FJT_RECIBO'	, MODEL_FIELD_INIT,	{|| "" })
	EndIf
	oStruFJT:SetProperty(  'FJT_VERSAO' , MODEL_FIELD_INIT, {|| '00' })
	oStruFJT:SetProperty(  'FJT_VERATU' , MODEL_FIELD_INIT, {|| '1' })
	oStruFJT:SetProperty(  'ASIENTO' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'AGRUPA' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'ONLINE' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'RAGENER' 	, MODEL_FIELD_INIT, {|| SuperGetMv("MV_RAGENER",.F.,.T.) })
	oStruFJT:SetProperty(  'IMPRIMIR' 	, MODEL_FIELD_INIT, {|| .F. })
	oStruFJT:SetProperty(  'EMAIL' 		, MODEL_FIELD_INIT, {|| .F. })
	oStruFJT:SetProperty(  'VLDNUMREC' 	, MODEL_FIELD_INIT, {|| .T. })
	oStruFJT:SetProperty(  'TIMBRAR' 	, MODEL_FIELD_INIT, {|| .F. })
	oStruFJT:SetProperty(  'EDITCH' 	, MODEL_FIELD_INIT, {|| .F. })
	
	IF ('EXISTCPO("SA1")'$UPPER(ALLTRIM(GetSx3Cache("FJT_CLIENT","X3_VALID"))+ALLTRIM(GetSx3Cache("FJT_CLIENT","X3_VLDUSER"))) .OR. ("EXISTCPO('SA1')"$UPPER(ALLTRIM(GetSx3Cache("FJT_CLIENT","X3_VALID"))+ALLTRIM(GetSx3Cache("FJT_CLIENT","X3_VLDUSER")))))
		oStruFJT:SetProperty(  'FJT_CLIENT'	, MODEL_FIELD_VALID,{|| F887CLIENT()})
	ENDIF
	oStruFJT:SetProperty( 'FJT_DTDIGI', MODEL_FIELD_INIT, {|| dDataBase })

	IF GetRpoRelease() <= "12.1.2310"
		oStruFJT:SetProperty(  'FJT_NOME' 	, MODEL_FIELD_TAMANHO, GetSx3Cache("A1_NOME","X3_TAMANHO"))
	ENDIF
	
	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel( 'SEL_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'SE1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'MOE_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'GEN_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'ADM_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'FAC_DETAIL' ):SetOptional(.T.)

	//Define que el submodelo permitirá la edición de datos.

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SE1_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('MOE_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('GEN_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('ADM_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('FAC_DETAIL'):SetOnlyQuery(.T.)

	oModel:GetModel("SE1_DETAIL"):SetMaxLine(9999)

	oModel:SetPrimaryKey({'FJT_RECIBO','FJT_SERIE'})
	
	//Evento de actualizaciones financieras
	oModel:InstallEvent("F887FIN"	,/*cOwner*/,oEvtTit)
	 //Evento de lanzamientos contables
	oModel:InstallEvent("F887CTB"	,/*cOwner*/,oEvtCtb)	

	//Descripciones - Se quedan comentadas para no generar errores sin la view en uso.
	//oModel:SetDescription(STR0098)
	//oModel:GetModel('FJT_MASTER'):SetDescription(STR0099)
	//oModel:GetModel('SE1_DETAIL'):SetDescription(STR0100)
	//oModel:GetModel('SEL_DETAIL'):SetDescription(STR0101)
	
Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización padrón
@return		oView objeto del View
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/
Static Function ViewDef()
Local cCampSE1	:= {"E1_CLIENTE", "E1_LOJA", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_EMISSAO", "E1_VENCTO", "E1_NATUREZ", "E1_VALOR", "E1_SALDO", "E1_MOEDA","E1_DESCONT", "E1_JUROS", "E1_MULTA", "E1_MOTIVO", "E1_FILIAL", "E1_XPERDES"}
Local cCampSEL	:= {"EL_FILIAL", "EL_SERIE", "EL_RECIBO", "EL_DTDIGIT", "EL_CANCEL", "EL_PREREC", "EL_CLIENTE", "EL_LOJA", "EL_VLMOED1", "EL_COBRAD", "EL_RECPROV", "EL_CLIORIG", "EL_LOJORIG", "EL_TIPAGRO", "EL_RETGAN", "EL_SERSUS", "EL_RECSUS", "EL_FACTOR", "EL_HORA"}
Local cCampFJT	:= {"FJT_CANCEL", "FJT_FILIAL", "FJT_SDOC", "FJT_VALBX", "FJT_VALDOC", "FJT_VALRA", "FJT_VERATU", "FJT_VERSAO", "FJT_VLRRET", "FJT_DTDIGI"}
Local jsonSE1	:= JsonCpos(cCampSE1)
Local jsonSEL	:= JsonCpos(cCampSEL)
Local jsonFJT	:= JsonCpos(cCampFJT)
Local oStruFJT	:= FWFormStruct( 2, 'FJT', { |cCampo| !(jsonFJT:HasProperty(AllTrim(cCampo)))	}, .T.)
Local oStruSEL	:= FWFormStruct( 2, 'SEL', { |cCampo| !(jsonSEL:HasProperty(AllTrim(cCampo))) 	}, .T.)
Local oStruSE1 	:= FWFormStruct( 2, 'SE1', { |cCampo| jsonSE1:HasProperty(AllTrim(cCampo)) .or. (GetSx3Cache(cCampo, "X3_CONTEXT") == "V" .and. GetSx3Cache(cCampo, "X3_PROPRI") == "U") 	}, .F.)
Local oModel	:= FWLoadModel('FINA887')
Local oStruMOE	:= FWFormViewStruct():New()
Local oView		:= FWFormView():New()
Local nQtMoedas	:= Moedfin()
Local nX		:= 0
Local nCent		:= 0
Local cMoeda	:= ""
Local cDescMoed	:= ""
Local cOrden	:= ""
Local cCent		:= ""
Local cPicMoe	:= ""
Local lPgoAutr	:= SuperGetMv("MV_PGOAUTR",.F.,.F.)
Local aCampos	:= {}

	SetFunName("FINA887")
	
	//Tabla de saldos y monedas
	oStruMOE:AddField('DESCMOEDA', '1', STR0103	, STR0103	, NIL, 'GET', , , , .F.)
	oStruMOE:AddField('TASA' 	, '2',  STR0104	, STR0104	, NIL, 'GET', "@E 99,999.9999", , , .F.)
	oStruMOE:AddField('RECIBIDO', '3',  STR0105 , STR0105	, NIL, 'GET', "@E 99,999,999,999.99", , , .F.)
	oStruMOE:AddField('SALDO' 	, '4',  STR0106	, STR0106	, NIL, 'GET', "@E 99,999,999,999.99", , , .F.)

	oStruSE1:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

	oStruSE1:AddField('CHECK'	, '1',  ''	, '', NIL, 'CHECK')
	
	cOrden := Soma1(oStruSE1:GetProperty("E1_MOEDA", MVC_VIEW_ORDEM))
	//Campo para mostrar el valor de la baja
    oStruSE1:AddField("SALDOPE", cOrden, STR0165, STR0165, Nil, "G", "@E 9,999,999,999,999.99", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Saldo Pendiente'
	cOrden := Soma1(oStruSE1:GetProperty("E1_MOEDA", MVC_VIEW_ORDEM))
	oStruSE1:AddField("COBRAR", cOrden, STR0162, STR0162, Nil, "G", "@E 9,999,999,999,999.99", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Cobrar'
	//joe
		oStruSE1:AddField("BAIXAR", cOrden, "BAIXAR", "BAIXAR", Nil, "G", "@E 9,999,999,999,999.99", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Saldo Pendiente'
	//joe
	If ExistBLock("F998NRMCOL")
		aCampos := ExecBLock("F998NRMCOL",.F.,.F.)
		For nX := 1 To Len(aCampos)
			If GetSx3Cache(aCampos[nX][1], "X3_CAMPO") <> NIL
				oStruSE1:AddField(aCampos[nX][1], Soma1(cOrden), aCampos[nX][2], aCampos[nX][2], Nil, "G", GetSx3Cache(aCampos[nX][1], "X3_PICTURE"), NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL)
			EndIf
		Next
	EndIf

	//Campos
	For nX := 1 To nQtMoedas
		cMoeda := Str(nX,IIf(nX <= 9,1,2))
		cDescMoed := SuperGetMv("MV_MOEDA" + cMoeda, .F., "")
		If !Empty(cDescMoed)
			cCent := "MV_CENT" + Iif(nX>1, cMoeda, "")
			nCent := SuperGetMV(cCent, .F., 2)
			cPicMoe := F887DinPic(16, nCent)
			oStruSE1:AddField("BAIXAR"+cMoeda, Soma1(cOrden), cDescMoed, STR0156 + cDescMoed, Nil, "G", cPicMoe, NIL, "", .T., NIL, NIL, NIL, NIL, NIL, .T., NIL) //STR0156
			oView:SetFieldAction( "BAIXAR"+cMoeda,	{ |oView| F887ActSal(oView:GetModel()) } )
			cOrden := oStruSE1:GetProperty("BAIXAR"+cMoeda, MVC_VIEW_ORDEM)
			If oModel:GetModel("SE1_DETAIL"):HasField("BAIXAR"+cMoeda)
				oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( "BAIXAR"+cMoeda	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK")') )
			EndIf
		EndIf
	Next

	oStruSE1:SetProperty("CHECK", MVC_VIEW_ORDEM, "01")
	cOrden := oStruSE1:GetProperty("CHECK", MVC_VIEW_ORDEM)
	oStruSE1:SetProperty("E1_FILIAL", MVC_VIEW_ORDEM, Soma1(cOrden))

	oStruSE1:SetProperty('CHECK', MVC_VIEW_CANCHANGE, .T.)
	If oStruSE1:HasField("E1_MOTIVO")
		oStruSE1:SetProperty('E1_MOTIVO', MVC_VIEW_CANCHANGE, .T.)
		oStruSE1:SetProperty('E1_MOTIVO',MVC_VIEW_COMBOBOX, F887E1MOT())
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_MOTIVO'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK")') )
	EndIf
	If oStruSE1:HasField("E1_DESCONT")
		oStruSE1:SetProperty('E1_DESCONT', MVC_VIEW_CANCHANGE, .T.)
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_DESCONT'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) == "NF" .and. AllTrim(FwFldGet("E1_MOTIVO")) == "NOR"') )
	EndIf
	If oStruSE1:HasField("E1_JUROS")
		oStruSE1:SetProperty('E1_JUROS', MVC_VIEW_CANCHANGE, .T.)
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_JUROS'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) == "NF" .and. AllTrim(FwFldGet("E1_MOTIVO")) == "NOR"') )
	EndIf
	If oStruSE1:HasField("E1_MULTA")
		oStruSE1:SetProperty('E1_MULTA', MVC_VIEW_CANCHANGE, .T.)
		oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( 'E1_MULTA'	, 	MODEL_FIELD_WHEN ,	FWBuildFeature( STRUCT_FEATURE_WHEN , 'FwFldGet("CHECK") .and. AllTrim(FwFldGet("E1_TIPO")) == "NF" .and. AllTrim(FwFldGet("E1_MOTIVO")) == "NOR"') )
	EndIf
	If oStruSE1:HasField("E1_XPERDES")
		oStruSE1:SetProperty('E1_XPERDES', MVC_VIEW_CANCHANGE, .T.)
	EndIf

	//Si existen los campos , seran definidos como campos de tipo visual
	If oStruSEL:HasField("EL_SDOCTO") .AND. oStruSEL:HasField("EL_PARDOC")
		oStruSEL:SetProperty('EL_SDOCTO', MVC_VIEW_CANCHANGE, .F.)
		oStruSEL:SetProperty('EL_PARDOC', MVC_VIEW_CANCHANGE, .F.)	
	ENDIF

	If lPgoAutr
		oView:SetFieldAction( "E1_DESCONT",	{ |oView| F887ActSal(oView:GetModel()) } )
		oView:SetFieldAction( "E1_JUROS",	{ |oView| F887ActSal(oView:GetModel()) } )
		oView:SetFieldAction( "E1_MULTA",	{ |oView| F887ActSal(oView:GetModel()) } )
	EndIf
	oView:SetFieldAction( "EL_VALOR",	{ |oView| F887ActSal(oView:GetModel()) } )
	oView:SetFieldAction( "EL_MOEDA",	{ |oView| F887ActSal(oView:GetModel()) } )

	oStruFJT:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFJT:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')

	oStruFJT:aFolders := {}
	oStruFJT:aGroups := {}
	
	oView:SetModel(oModel)

	//Define que a tela sera um formulario continuo
	oView:SetContinuousForm(.T.)

	oView:AddField('VIEW_FJT' , oStruFJT, 'FJT_MASTER' )
	oView:AddGrid('VIEW_SEL'  , oStruSEL, 'SEL_DETAIL')
	oView:AddGrid('VIEW_SE1'  , oStruSE1, 'SE1_DETAIL')
	oView:AddGrid('VIEW_MOE'  , oStruMOE, 'MOE_DETAIL')
	
	/*Totales en encabezado*/
	/*oView:CreateHorizontalBox( 'TOP', 30)
	oView:CreateVerticalBox( 'CIMA', 55, 'TOP')
	oView:CreateVerticalBox( 'RODAPE', 45, 'TOP')
	oView:CreateHorizontalBox( 'MIDDLE' , 70)
	oView:CreateFolder("FOLDER","MIDDLE")
	oView:AddSheet( 'FOLDER', 'SHEET_SE1', "Títulos" )
	oView:AddSheet( 'FOLDER', 'SHEET_SEL', "Formas de pago" )
	oView:CreateHorizontalBox( 'MEDIO', 100, , , 'FOLDER', 'SHEET_SE1')
	oView:CreateHorizontalBox( 'BAIXO', 100, , , 'FOLDER', 'SHEET_SEL')*/

	oView:CreateHorizontalBox( 'CIMA', 25)
	oView:CreateHorizontalBox( 'MIDDLE', 50)
	oView:CreateFolder("FOLDER","MIDDLE")
	oView:AddSheet( 'FOLDER', 'SHEET_SE1', STR0100 )
	oView:AddSheet( 'FOLDER', 'SHEET_SEL', STR0101 )
	oView:CreateHorizontalBox( 'MEDIO', 100, , , 'FOLDER', 'SHEET_SE1')
	oView:CreateHorizontalBox( 'BAIXO', 100, , , 'FOLDER', 'SHEET_SEL')
	oView:CreateHorizontalBox( 'RODAPE', 25)

	//Número de líneas en grids.
	oView:SetViewProperty('VIEW_SE1', 'SETGRIDLINES', {12}) //Títulos
	oView:SetViewProperty('VIEW_SEL', 'SETGRIDLINES', {12}) //Formas de pago
	oView:SetViewProperty('VIEW_MOE', 'SETGRIDLINES', {4}) //Monedas
	
	oView:SetOwnerView('VIEW_FJT', 'CIMA')
	oView:SetOwnerView('VIEW_SE1', 'MEDIO')
	oView:SetOwnerView('VIEW_SEL', 'BAIXO')
	oView:SetOwnerView('VIEW_MOE', 'RODAPE')

	//Habilitando título
	oView:EnableTitleView('VIEW_FJT',STR0099)
	oView:EnableTitleView('VIEW_SE1',STR0100)
	oView:EnableTitleView('VIEW_SEL',STR0101)
	oView:EnableTitleView('VIEW_MOE',STR0102)
	oView:SetDescription(OemtoAnsi(STR0099)) //Recibo

	//Filtros de busqueda para el grid de títulos.
    oView:SetViewProperty("VIEW_SE1","ENABLENEWGRID")
    oView:SetViewProperty("VIEW_SE1","GRIDFILTER",{.T.})
    oView:SetViewProperty("VIEW_SE1","GRIDSEEK",{.T.})

	//Filtros de busqueda para el grid de formas de pago.
	oView:SetViewProperty("VIEW_SEL","ENABLENEWGRID")
    oView:SetViewProperty("VIEW_SEL","GRIDFILTER",{.T.})
    oView:SetViewProperty("VIEW_SEL","GRIDSEEK",{.T.})

	//Al hacer doble click en un campo de la vista VIEW_SE1
	oView:SetViewProperty("VIEW_SE1","GRIDDOUBLECLICK",{{|oView,cFieldName,nLineGrid| BlockSE1(oView,cFieldName,nLineGrid)}}) 

	//Bloqueos de edición en la vista.
	oView:SetNoInsertLine("VIEW_MOE")
	oView:SetNoDeleteLine("VIEW_MOE")

	oView:SetNoInsertLine("VIEW_SE1")
	oView:SetNoDeleteLine("VIEW_SE1")

	//Inicializaores de vista.
	oView:SetAfterViewActivate({|oView| F887InView(oView:GetModel(), , .T.)})

	//Acciones de la vista.
	oView:SetViewAction( 'DELETELINE', { |oView| F887ActSal(oView:GetModel()) } )
	oView:SetViewAction( 'UNDELETELINE', { |oView| F887ActSal(oView:GetModel()) } )
	oView:SetViewAction( 'BUTTONCANCEL', { |oView| DBUnlockAll() } )
	
	//Acciones de campos
	oView:SetFieldAction( 'FJT_CLIENT', { |oView| DBUnlockAll(), F887InView(oView:GetModel(), .T., .F.)} )
	oView:SetFieldAction( 'FJT_LOJA', 	{ |oView| DBUnlockAll(), F887InView(oView:GetModel(), .T., .F.)} )
	oView:SetFieldAction( 'CHECK', 		{ |oView| F887ActSal(oView:GetModel()) } )
	If oView:GetModel("SEL_DETAIL"):HasField("EL_VALBASE")
		oView:SetFieldAction( "EL_VALBASE",	{ |oView| F887ActSal(oView:GetModel()) } )
	EndIf
	If oView:GetModel("SEL_DETAIL"):HasField("EL_ALIQ")
		oView:SetFieldAction( "EL_ALIQ",	{ |oView| F887ActSal(oView:GetModel()) } )
	EndIf
	If oView:GetModel("SE1_DETAIL"):HasField("E1_XPERDES")
		oView:SetFieldAction( "E1_XPERDES",	{ |oView| F887ActSal(oView:GetModel()) } )
	EndIf

	//Botones.
	oView:AddUserButton(STR0166, "CARGA", 	{ |oView| F887EditTx(oView:GetModel()) },,VK_F2,{MODEL_OPERATION_INSERT}) //'Tasa cambio [F2]'
	oView:AddUserButton(STR0157, "CARGA",	{ |oView| SetParams(.T., oView:GetModel("FJT_MASTER"),oView) },,VK_F4,{MODEL_OPERATION_INSERT}) //'Parámetros [F4]'
	oView:AddUserButton(STR0158, "CARGA",	{ |oView| FWMsgRun( , {||F887GetTit(oView:GetModel(), .F.)}, STR0159, STR0159) },,VK_F8,{MODEL_OPERATION_INSERT}) //'Extraer títulos [F8]'
	oView:AddUserButton(STR0161, "CARGA",	{ |oView| FWMsgRun( , {||F887SetMark(oView:GetModel())}, STR0184, STR0185) },,K_CTRL_J,{MODEL_OPERATION_INSERT}) //'Marcar todos [Ctrl + J]'
	oView:AddUserButton(STR0174, "CARGA", 	{ |oView| F887EditTx(oView:GetModel(), .T.) },,K_CTRL_K,{MODEL_OPERATION_INSERT}) //'Saldos [Ctrl + K]'
	oView:AddUserButton(STR0186, "CARGA", 	{ |oView| F887SelOtT(oView:GetModel()) },,K_CTRL_M,{MODEL_OPERATION_INSERT}) //"Incluir Otros Títulos [CTRL + M]"
	oView:AddUserButton(STR0191, "CARGA", 	{ |oView| F887CalMoe(oView:GetModel(), oView:GetCurrentSelect()) },,K_CTRL_I,{MODEL_OPERATION_INSERT}) //"Convertir [CTRL + I]"
	
	oView:SetAfterOkButton({|oView| F887MET()})
	
	//-- Punto de entrada para alterar la view
	If ExistBlock("F887View")
		ExecBlock("F887View",.F.,.F.,{@oView})
	EndIf

Return oView

/*/{Protheus.doc} F887LOJA
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJA(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIENTE")
Local cLoja		:= oModelSEL:GetValue("EL_LOJA")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet 


/*/{Protheus.doc} F887CHECKTAX
Validacion para no poder seleccionar un titulo si no esta informada la tasa de su moneda
@type function
@version  1
@author luis.aboytes
@since 18/9/2025
/*/
Static Function F887CHECKTAX(oModel)
Local oModel 	:= FWModelActive()
Local oModelSE1 := oModel:GetModel('SE1_DETAIL' )
Local oModelMOE := oModel:GetModel('MOE_DETAIL')
Local lValid		:= .T.
Local nNum		:= 0

	For nNum := 1 To oModelSE1:Length()
		IF oModelSE1:GetValue("CHECK",nNum) .AND. oModelSE1:GetValue("E1_MOEDA",nNum) > 1
			IF oModelMOE:GetValue("TASA",oModelSE1:GetValue("E1_MOEDA",nNum)) == 0
				oModel:SetErrorMessage('SE1_DETAIL', '' , 'SE1_DETAIL' , '' , STR0017, '', STR0199) //STR0017 Aviso - STR0199 Moneda del título no informada
				lValid := .F.
			EndIF
		ENDIF
	Next nNum

Return lValid


/*/{Protheus.doc} BlockSE1
Función para bloquear titulos del GRID del SE1	
@type function
@version  1
@author luis.aboytes
@since 23/9/2025
/*/
Static Function BlockSE1(oView,cFieldName,nLineGrid,lLockAll)
Local nRecno := 0 	As Numeric
Local lRet	 := .T.	As Logical
Local lLock	 := .T. As Logical
Local aError := {}  As Array
Local oModel := FWModelActive()

Default oView 		:= FWModelActive()
Default cFieldName 	:= ''
Default nLineGrid	:= 0
Default lLockAll 	:= .F.

	IF cFieldName == 'CHECK'
		nRecno := oView:GetModel('SE1_DETAIL'):GetValue('RECNO',nLineGrid)
		lLock  := SE1->(MsRLock(nRecno)) //Bloquear registro
		IF	!lLock 
			IF !lLockAll
				Help(,,STR0017,,STR0246,1, 0 ) // Aviso - "No es posible seleccionar el título debido a que está siendo usado en otra sesión."
			ELSE
				oModel:SetErrorMessage('SE1_DETAIL', '' , 'SE1_DETAIL' , '' , STR0017, '', STR0265) //STR0017 Aviso - STR0265 "No es posible seleccionar el título o los titulos debido a que está siendo usado en otra sesión o la moneda no ha sido informada."  
			ENDIF
			Return !lRet
		ELSE
			IF oView:GetModel('SE1_DETAIL'):GetValue('CHECK',nLineGrid)
				lRet:=oView:GetModel('SE1_DETAIL'):SetValue("CHECK", .F.)
				SE1->(MsRUnlock(nRecno))
			ELSE
				lRet:=oView:GetModel('SE1_DETAIL'):SetValue("CHECK", .T.)
				IF !lRet
					aError := oModel:GetErrorMessages()
					SE1->(MsRUnlock(nRecno))
					IF !lLockAll
						Help(,,aError[4],,aError[6]+" - "+aError[7],1, 0 )
					Else
						oModel:SetErrorMessage('SE1_DETAIL', '' , 'SE1_DETAIL' , '' , STR0017, '', aError[7]) //STR0017 Aviso
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF
RETURN lRet 


/*/{Protheus.doc} F887CLIENT
La validación del campo FJT_CLIENT verifica que el cliente ingresado en el campo exista esto sin tener en cuenta la tienda y si el 
cliente esta bloqueado (A1_MSBLQL) ya que al utilizar ExistCpo("SA1") no verifica si esta o no bloqueado.
@type function
@version  1
@author luis.aboytes
@since 13/9/2024
/*/
Function F887CLIENT()
Local oModel 	:= FWModelActive()
Local oModelFJT := oModel:GetModel('FJT_MASTER')
Local lRet		:= .F.
Local aArea		:= {}
Local cCliente	:= oModelFJT:GetValue('FJT_CLIENT')

	aArea := SA1->(GetArea())
	DbSelectArea("SA1") //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSetOrder(1)) 
	If SA1->(MsSeek(xFilial("SA1")+cCliente))  
		lRet := .T.
	ENDIF
	SA1->(DbCloseArea())
	RestArea(aArea)		

Return	lRet

/*/{Protheus.doc} F887LOJORI
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJORI(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIORIG")
Local cLoja		:= oModelSEL:GetValue("EL_LOJORIG")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet


/*/{Protheus.doc} FA887VALTP
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Function FA887VALTP(oModel, lValid)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local aArea		:= {}
Local cConteudo	:= ""
Local aCheque	:= {}
Local lUsaCmc7	:= SuperGetMv("MV_CMC7FIN") == "S"
Local lFpadvpl 	:= SuperGetMv("MV_FPADVPL",.F.,.F.)
	
IF lValid
	If AliasInDic("FJS")
		cConteudo	:= oModelSEL:GetValue("EL_TIPO")
		aArea := FJS->(GetArea())
		DbSelectArea("FJS")
		FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
		If FJS->(DbSeek(xFilial("FJS")+PadR(cConteudo,GetSx3Cache("FJS_TIPO","X3_TAMANHO"))))  
			If !((ALLTRIM(FJS->FJS_BLOQ) == "2") .and. (ALLTRIM(FJS->FJS_CARTE) $ "1|3")) 
				lRet := .F.
				Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"
			EndIf
		Else
			lRet := .F.
			Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"	
		EndIf
		If lRet .and. lUsaCmc7 .and. FJS->FJS_TIPOIN $ "CH " .and. lFpadvpl
			aCheque := FinCmc7Tc()
			If Len(aCheque) > 0
				FINEntBc(aCheque[1],aCheque[2],aCheque[3])
				oModelSEL:loadValue("EL_BCOCHQ",aCheque[1]) 
				oModelSEL:SetValue("EL_AGECHQ",aCheque[2]) 
				oModelSEL:SetValue("EL_POSTAL",aCheque[3]) 
				oModelSEL:SetValue("EL_NUMERO",aCheque[4]) 
				oModelSEL:SetValue("EL_CTACHQ",aCheque[5])
			Endif
		EndIf 
		If lRet
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_ENDOSSA"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_ENDOSSA","2")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TERCEIR"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_TERCEIR","1")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TRANSIT"}) > 0
				oModelSEL:SetValue("EL_TRANSIT",FJS->FJS_TRANS)
			EndIf
		EndIf
		FJS->(RestArea(aArea))
	EndIf

ENDIF

Return lRet

/*/{Protheus.doc} F887BCO
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
			lNoValid - Indica si debe realizar la validación (Uso para Argentina en banco cheque)
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/

Function F887BCO(cCampo, lNoValid)
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local lRet := .T.
Local xConten := oModelSEL:GetValue(cCampo)
	
Default lNoValid := .F.
	
	If lNoValid
		If Empty( xConten )                                                                                                   
			oModelSEL:LoadValue('EL_AGECHQ'		,"")
			oModelSEL:LoadValue('EL_POSTAL'		,"")	
		EndIf
	Else
		If Empty( xConten ) 
			oModelSEL:LoadValue('EL_AGENCIA'	,"")
			oModelSEL:LoadValue('EL_CONTA'		,"")	
		EndIf
	EndIf 

Return( lRet )

/*/{Protheus.doc} F887AWHEN
Validaciones correspondientes a campos

@type 		Method


@author 	raul.medina
@version	12.1.27 / Superior
@since		23/05/2021 
/*/
Function F887aWhen(cCampo)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local cCredInm	:= GetSESTipos({|| ES_RCOPGER == "2"},"1")
Local cCredMed	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")

	cCredInm	:= IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	cCredMed	:=	IIf(Empty(cCredMed),GetSESNew("CH|CC|CO","3") ,cCredMed)
	
If cCampo == "TPCRED"
	IF!(cTipoDoc $ cCredMed) .Or. (cTipoDoc == "CHF")
		If cTipoDoc $ cCredInm
			//Inmediato
			oModelSEL:LoadValue("EL_TPCRED","1")
		Else
			If cTipoDoc == "CHF"
				//Acreditación
				oModelSEL:LoadValue("EL_TPCRED","3")
			ELSE
				//Fiscal
				IF Alltrim(cTipoDoc) <> "DC"
					oModelSEL:LoadValue("EL_TPCRED","4")
				ENDIF
			EndIf
		EndIf
	ENDIF
EndIf

Return lRet

/*/{Protheus.doc} F887MOE
Validaciones de moneda (EL_MOEDA) al agregar una forma de pago
@type function
@version  1
@author luis.aboytes
@since 1/11/2022
/*/
Function F887MOE(oModel)
	Local oModel 		:= FWModelActive()
	Local lValid 		:= .T. 	As Logical 
	Local nLine			:= 0 	As Numeric
	Local aMoedas		:= {}	As Array
	local nMoeda 		:= 0
	Local nline2		:= 0
	Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
	Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')

    For nLine := 1 To oModelMOE:Length()
        AADD(aMoedas,{oModelMOE:GetValue('MOEDA',nLine), oModelMOE:GetValue('TASA',nLine)})
	Next nLine	
	 
	For nline2 := 1 To oModelSEL:Length()
		IF lValid
			nMoeda := AScan(aMoedas,{|x|x[1] == ALLTRIM(oModelSEL:GetValue('EL_MOEDA',nline2))})
			IF nMoeda == 0 .OR. !(aMoedas[nMoeda][2] > 0) 
			oModel:SetErrorMessage('SEL_DETAIL', '' , 'MOE_DETAIL' , '' , STR0050, '', STR0016) //Informe todas las tasas de las monedas que se utilizaron en los documentos.			
			lValid := .F.
			EndIF
		EndIf
	Next nline2
    
Return lValid

/*/{Protheus.doc} F887DIACTB
Función para validación del uso del campo Codigo Diario. 
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	Luis Gerardo Cabrera Mata
@version	12.1.27 / Superior
@since 		08/12/2022
/*/
Static Function F887DIACTB(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCodDia	:= oModelSEL:GetValue("EL_DIACTB")
Local cSegOfi   := SuperGetMv("MV_SEGOFI",.T.,0)

	IF ( cSegOfi$("5|8")  ) .Or. (cSegOfi == "7" .And. cPaisloc == "PER" ) 
		oModelSEL:LoadValue("EL_DIACTB",cCodDia)
	End
		
Return lRet

/*/{Protheus.doc} CreateTrigger
función para la creación de triggers generica
@param		cdom 	- Indica el campo dominio
@param		ccontr 	- Indica el campo Contradominio
@param		cregla 	- Indica la relga del disparador
@param		cseq  	- Indica la secuencia
@return		
@author 	José González
@version	12.1.2210 / Superior
@since 		02/02/2023
/*/
Function CreateTrigger(cdom,ccontr,cregla,cseq,cCondicao)
Local aAux :=  {}
default cdom := ""
default ccontr := ""
default cregla := ""
default cseq := ""
default cCondicao := ""

aAux := FwStruTrigger(;
	cdom ,; // Campo Dominio
	ccontr ,; // Campo de Contradominio
	cregla,; // Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"" ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	"" ,; // Chave de busca da tabela a ser posicionada
	cCondicao ,; // cCondicao para execucao do gatilho
	cseq ) // Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux




Function GetValReTR(oModelGrid)
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local cCampo := Alltrim(ReadVar())
Local lRet := .T.
	IF Alltrim(oModelSEL:getvalue("EL_TIPO")) $ "RB|RI|RG|RS|RM"
		If "M->EL_VALOR" $ cCampo 
			If ( oModelSEL:getvalue("EL_VALBASE")> 0 )
				oModelSEL:setvalue("EL_ALIQ",( oModelSEL:getvalue("EL_VALOR")/ oModelSEL:getvalue("EL_VALBASE") ) * 100)
			ElseIf oModelSEL:getvalue("EL_ALIQ") > 0
				oModelSEL:setvalue("EL_VALBASE", (oModelSEL:getvalue("EL_VALOR") / oModelSEL:getvalue("EL_ALIQ") ) * 100)
			EndIf 	
		ElseIf "M->EL_VALBASE" $ cCampo
			If ( oModelSEL:getvalue("EL_VALOR") > 0 )
				oModelSEL:setvalue("EL_ALIQ",( oModelSEL:getvalue("EL_VALOR") / oModelSEL:getvalue("EL_VALBASE")  ) * 100)
			ElseIF ( oModelSEL:getvalue("EL_ALIQ") > 0 )
				oModelSEL:setvalue("EL_VALOR",  ( oModelSEL:getvalue("EL_VALBASE")  * oModelSEL:getvalue("EL_ALIQ")  )	/ 100	)
			EndIf
		ElseIf "M->EL_ALIQ" $ cCampo
			If ( oModelSEL:getvalue("EL_VALBASE") > 0 )
				oModelSEL:setvalue("EL_VALOR", ( oModelSEL:getvalue("EL_VALBASE") * oModelSEL:getvalue("EL_ALIQ")   )	/ 100	)
			ElseIf( oModelSEL:getvalue("EL_VALOR") > 0 )
				oModelSEL:setvalue("EL_VALBASE",( oModelSEL:getvalue("EL_VALOR") / oModelSEL:getvalue("EL_ALIQ") ) * 100	)
			EndIf	
		EndIf
	EndIf


Return lRet

/*/{Protheus.doc} JsonCpos
Función utilizada para crear objetos json son la información recibida en un array.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    aStrings - array - array con la información con la cual será creado el objeto json.
@Return 
	oJson - json - objeto json creado apartir de la información de aStrings.
/*/
Static Function JsonCpos(aStrings)
Local nX		:= 0
Local oJson

Default aStrings    := {}

    oJson := JsonObject():new()

    For nX := 1 To Len(aStrings)
        oJson[aStrings[nX]] := aStrings[nX]
    Next

Return oJson

/*/{Protheus.doc} F887InView
Función utilizada para inicializar el model de formas de pago SEL, crea una línea en blanco considerando inicializadores.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oView - - vista activa.
	lPayform - logico - indica si las formas de pago son inicializadas.
	lSetParams - logico - indica los valores de las preguntas son inicializador en el model.
	lTitForm - Logico - Reiniciar la sección de titulos
@Return 
/*/
Function F887InView(oModel, lPayform, lSetParams, lTitForm )
Local	lvalid		:= IIF(SEL->(ColumnPos("EL_IDENTEE")) > 0,VAZIO(MV_PAR07),.T.)
Default oModel 		:= FWModelActive()
Default lPayform	:= .F.
Default lSetParams	:= .F.
Default lTitForm	:= .T.

	If lSetParams
		SetParams(.F., oModel:GetModel("FJT_MASTER"),oModel)
	EndIf

	If lTitForm
		IniSE1View(oModel:GetModel("SE1_DETAIL"))
		F887RefVw("VIEW_SE1")
	EndIf

	If lPayform .AND. lvalid  //(Mexico) Si hay una compensación, no se actualizara la tabla de cobros.
		IniSELView(oModel:GetModel("SEL_DETAIL"))
		F887RefVw("VIEW_SEL")
	EndIf

	//Inicializador de tasas x moneda.
	oModel:GetModel("MOE_DETAIL"):SetNoInsertLine(.F.)

	IniMOEView(oModel:GetModel("MOE_DETAIL"))
	F887RefVw("VIEW_MOE")

	oModel:GetModel("MOE_DETAIL"):SetNoInsertLine()

Return

/*/{Protheus.doc} IniSELView
Función utilizada para inicializar el model de formas de pago SEL, crea una línea en blanco considerando inicializadores.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModelSEL - - model de la tabla de formas de pago SEL.
@Return 
/*/
Static Function IniSELView(oModelSEL)

	oModelSEL:ClearData(.T., .T.)

Return

/*/{Protheus.doc} IniSE1View
Función utilizada para inicializar el model de títulos SE1, crear una línea en blanco que no contempla inicializadores de campos..
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModelSE1 - - model de la tabla de títulos SE1.
@Return 
/*/
Function IniSE1View(oModelSE1)

	oModelSE1:ClearData(.F., .T.)
	oModelSE1:SetValue("CHECK", .F.)	//Check	

Return

/*/{Protheus.doc} IniMOEView
Función utilizada para inicializar los valores de de las tasas y nombres de las monedas configuradas.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModelFJT - - model de la tabla de monedas/tasas.
@Return 
/*/
Function IniMOEView(oModelMoe)
Local nX		:= 0
Local nQtMoedas	:= Moedfin()
Local cMoeda	:= ""
Local cDescMoed	:= ""

	For nX := 1 To nQtMoedas
		cMoeda := Str(nX,IIf(nX <= 9,1,2))
		cDescMoed := AllTrim(SuperGetMv("MV_MOEDA" + cMoeda, .F., ""))
		If !Empty(cDescMoed)
			If	!(oModelMoe:SeekLine({{"MOEDA", cMoeda}, {"DESCMOEDA", cDescMoed}}, .F., .T.))
				If oModelMoe:Length() < nX
					oModelMoe:AddLine()
				EndIf
				oModelMoe:SetValue("MOEDA"       , cMoeda)	//Moneda
				oModelMoe:SetValue("DESCMOEDA"   , cDescMoed)	//Descripción Moneda
				oModelMoe:SetValue("TASA"        , RecMoeda(dDataBase,cMoeda)) //Tasa  de la moneda
			EndIf
			oModelMoe:SetValue("RECIBIDO"    , 0 ) // Monto total que suman las formas de pago.
			oModelMoe:SetValue("SALDO"       , 0 ) // Saldo que queda por cobrar entre los títulos x cobrar y las formas de pago.
		EndIf
	Next

	oModelMoe:GoLine(1)

Return

/*/{Protheus.doc} SetParams
Función utilizada asigar al model los valores del grupo de preguntas FIN998.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
	lShow - logico - indica si las preguntas deben ser mostradas. 
    oModelFJT - - model de la tabla de encabezado FJT.
@Return 
/*/
Static Function SetParams(lShow, oModelFJT,oModel)
Local aPergAux	:= {}
Local xValPar
Default oModel 	:= FWModelActive()

Default lShow	:= .F.

	Pergunte("FIN998", lShow, /*cTitle*/, .F., /*oDlg*/, .T., @aPergAux)
	oModelFJT:SetValue("ASIENTO", MV_PAR01) 
	oModelFJT:SetValue("AGRUPA", MV_PAR02)
	oModelFJT:SetValue("ONLINE", MV_PAR03)
	xValPar := Iif(Len(aPergAux) >= 13, MV_PAR08,MV_PAR04)
	xValPar := Iif(Empty(xValPar) .Or. ValType(xValPar) <> "N", 1, xValPar)
	xValPar := Iif( ExistBLock("F998MVPAR8"),xValPar:=ExecBLock("F998MVPAR8",.F.,.F.),xValPar)
	xValPar := Iif(xValPar == 2, "RA", "NCC") //Documento para anticipos
	oModelFJT:SetValue("DOCUMEN", xValPar)
	xValPar := Iif(Len(aPergAux) >= 13, MV_PAR12,Iif(Len(aPergAux) >= 8, MV_PAR08, 2))
	xValPar := Iif(Empty(xValPar) .Or. ValType(xValPar) <> "N", .F., xValPar == 1)
	oModelFJT:SetValue("IMPRIMIR", xValPar)//Indica si se realiza la impresión
	xValPar := Iif(Len(aPergAux) >= 13, MV_PAR13,Iif(Len(aPergAux) >= 9, MV_PAR09, 2))
	xValPar := Iif(Empty(xValPar) .Or. ValType(xValPar) <> "N", .F., xValPar == 1)
	oModelFJT:SetValue("EMAIL", xValPar) //Indica si se realiza el envio del recibo

	GetMPar998("mv_par14", aPergAux, @xValPar)
	If !Empty(xValPar)
		oModelFJT:SetValue("TIMBRAR", xValPar == 1)
	EndIf

Return

/*/{Protheus.doc} GetMPar998
Función para obtener el valor de los parámetros del grupo de preguntas FIN998 tomando en cuenta su posición
@author 	carlos.espinoza
@since 		10/2024
@version	12.1.2210 / Superior
Parametros
	cMvPar - Caracter - nombre del parámetro en el campo X1_VAR01 que se desea obtener. 
    aPergAux - Array - Arreglo del grupo de preguntas de la tabla SX1.
	xValPar - Variable de resultado con el valor de la pregunta específica.
@Return 
/*/
Function GetMPar998(cMvPar, aPergAux, xValPar)
	Local nPos       := 0
	Default cMvPar   := ""
	Default aPergAux := {}
	Default xValPar  := Nil

	xValPar := Nil
	nPos    := Ascan(aPergAux,{|x| Lower(Alltrim(x[14])) == cMvPar })
    
	If nPos > 0
		xValPar := &("MV_PAR"+IIF(nPos<10,"0","") + Alltrim(STR(nPos)))
	EndIf

Return 

/*/{Protheus.doc} F887GetTit
Función utilizada para obtener los títulos por medio del botón extraer títulos.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - modelo activo
	lMark - logico - Indica si los títulos deben de ser marcados
@Return 
/*/
Function F887GetTit(oModel, lMark)
Local oJson
Local oFinTitSer
Local oJBoby
Local oJParamReq
Local oModelFJT
Local oModelSE1
Local aPergAux	:= {}
Local xValPar

Default oModel		:= FWModelActive()
Default lMark		:= .F.

	oModelFJT := oModel:GetModel("FJT_MASTER")

	If !Empty(oModelFJT:GetValue("FJT_RECIBO")) .and. !Empty(oModelFJT:GetValue("FJT_EMISSA")) .and. !Empty(oModelFJT:GetValue("FJT_CLIENT")) .and. !Empty(oModelFJT:GetValue("FJT_LOJA"))

		oModelSE1 := oModel:GetModel("SE1_DETAIL")
		If  oModelSE1:SeekLine({{"CHECK", .T.}}, .F., .F.) 
			If !MsgYesNo(STR0202) //'Existen títulos marcados, será eliminada la información. ¿Desea continuar?'
				DBUnlockAll()
				Return 
			EndIf
		EndIf

		oJParamReq := JsonObject():new()
		oJParamReq['customer'] := ""
		oJParamReq['unit'] := ""
		oJParamReq['origBranch'] := ""

		oJBoby := JsonObject():new()
		oJBoby['filial'] := xFilial("SE1")
		oJBoby['form'] := JsonObject():new()
		oJBoby['form']['serie'] := oModelFJT:GetValue("FJT_SERIE")
		oJBoby['form']['recibo'] := oModelFJT:GetValue("FJT_RECIBO")
		oJBoby['form']['emissa'] := DTOS(oModelFJT:GetValue("FJT_EMISSA"))
		oJBoby['form']['nature'] := oModelFJT:GetValue("FJT_NATURE")
		oJBoby['form']['client'] := oModelFJT:GetValue("FJT_CLIENT")
		oJBoby['form']['loja'] := oModelFJT:GetValue("FJT_LOJA")
		oJBoby['form']['nome'] := oModelFJT:GetValue("FJT_NOME")
		oJBoby['form']['cobrad'] := oModelFJT:GetValue("FJT_COBRAD")
		oJBoby['form']['recprv'] := oModelFJT:GetValue("FJT_RECPRV")
		oJBoby['dateSystem'] := DTOS(dDataBase)
		oJBoby['params'] := JsonObject():new()
		Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T., @aPergAux)
		xValPar := Iif(Len(aPergAux) == 9, MV_PAR07,MV_PAR11)
		oJBoby['params']['mv_par11'] :=	Iif(Empty(xValPar) .Or. ValType(xValPar) <> "N", 2, xValPar)

		oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
		oJson := oFinTitSer:financialTitlesClientService("SE1", oJParamReq, JsonObject():new(), oJBoby)

		oModel:GetModel("SE1_DETAIL"):SetNoInsertLine(.F.)
		F887SetTit(oModel:GetModel("SE1_DETAIL"), oJson['response']['items'], lMark)
		oModel:GetModel("SE1_DETAIL"):SetNoInsertLine(!lMark)
		F887ActSal(oModel)
	EndIf

Return

/*/{Protheus.doc} F887SetTit
Función utilizada para agregar los títulos recibidos al model para ser mostrados.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModelSE1 - - model de la tabla de encabezado SE1.
	aTitles -  array - arreglo con los títulos que deben de ser agreados al model para mostrarse en la view.
	lMark - logico - Indica si los títulos deben de ser marcados
@Return 
/*/
Static Function F887SetTit(oModelSE1, aTitles, lMark, lOtTi)
Local nX		:= 0
Local nY		:= 0
Local aCampos	:= {}
Local lCheck	:= .T.
Local lFactor	:= SEL->(ColumnPos("EL_FACTOR")) > 0

Default aTitles		:= {}
Default lMark		:= .F.
Default lOtTi		:= .F.

	If lOtTi .And. lFactor
		Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T.)
	EndIf
	
	If !lOtTi
		oModelSE1:ClearData(.F., .T.)
	EndIf
 
	For nX := 1 To Len(aTitles)
		If oModelSE1:Length() < nX .Or. (lOtTi .and. !Empty(oModelSE1:GetValue("E1_NUM")))
			oModelSE1:AddLine()
		EndIf
		oModelSE1:LoadValue("E1_CLIENTE"	, aTitles[nX]['client'])
		oModelSE1:LoadValue("E1_LOJA"		, aTitles[nX]['unit'])
		oModelSE1:LoadValue("E1_PREFIXO"	, aTitles[nX]['prefix'])
		oModelSE1:LoadValue("E1_NUM"		, aTitles[nX]['billnumber'])
		oModelSE1:LoadValue("E1_PARCELA"	, aTitles[nX]['installment'])
		oModelSE1:LoadValue("E1_TIPO"		, aTitles[nX]['type'])
		oModelSE1:LoadValue("E1_EMISSAO"	, STOD(aTitles[nX]['issuedt']))
		oModelSE1:LoadValue("E1_VENCTO"		, STOD(aTitles[nX]['actualduedt']))
		oModelSE1:LoadValue("E1_NATUREZ" 	, aTitles[nX]['class'])
		oModelSE1:LoadValue("E1_VALOR"		, aTitles[nX]['billvalue'])
		oModelSE1:LoadValue("E1_SALDO"		, aTitles[nX]['balance'])
		oModelSE1:LoadValue("E1_MOEDA"		, aTitles[nX]['currency'])
		oModelSE1:LoadValue("E1_DESCONT"	, aTitles[nX]['discount'])
		oModelSE1:LoadValue("E1_JUROS"		, aTitles[nX]['interest'])
		oModelSE1:LoadValue("E1_MULTA"		, aTitles[nX]['fine'])
		oModelSE1:LoadValue("E1_FILIAL"		, aTitles[nX]['branch'])
		oModelSE1:LoadValue("E1_ORIGEM"		, aTitles[nX]['origin'])
		oModelSE1:LoadValue("E1_FILORIG"	, aTitles[nX]['originbranch'])
		oModelSE1:LoadValue("RECNO"			, aTitles[nX]['recno'])
		If ExistBLock("F998NRMCOL")
			aCampos := ExecBLock("F998NRMCOL",.F.,.F.)
			For nY := 1 To Len(aCampos)
				If oModelSE1:HasField(aCampos[nY][1])
					oModelSE1:LoadValue(aCampos[nY][1], aTitles[nX][lower(aCampos[nY][1])])
				EndIf
			Next
		EndIf
		If lOtTi .and. lMark
			If MV_PAR06 == 1 .And. lFactor
				lCheck := F887Comp(oModelSE1)
				oModelSE1:SetValue("CHECK"			, lCheck)
			Else
				oModelSE1:SetValue("CHECK"			, lMark)
			EndIf
		Else
			oModelSE1:LoadValue("CHECK"			, lMark)
		EndIf
	Next

	If !lOtTi
		oModelSE1:GoLine(1)
	EndIf

Return

/*/{Protheus.doc} E1CHECKBX
Función utilizada para el disparador que asigna el valor a cobrar.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	nBaja - numerico - valor a ser mostrado en el campo a cobrar
/*/
Function E1CHECKBX()
Local nBaja		:= 0

	If FwFldGet("CHECK")
		nBaja := FwFldGet("E1_SALDO") - FwFldGet("E1_DESCONT") + FwFldGet("E1_JUROS") +FwFldGet("E1_MULTA")
	EndIf

Return nBaja

/*/{Protheus.doc} E1BAIXAR
Función utilizada para el disparador que asigna el valor de baja.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	nBaja - numerico - valor a ser mostrado en el campo de baja
/*/
Function E1BAIXAR()
Local nBaja		:= 0

	If FwFldGet("CHECK")
		nBaja := FwFldGet("COBRAR") + FwFldGet("E1_DESCONT") - FwFldGet("E1_JUROS") - FwFldGet("E1_MULTA") 
	EndIf

Return nBaja

/*/{Protheus.doc} E1CHECKDES
Función utilizada para el disparador que asigna el valor de descuento del titulo.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	nDesc - numerico - valor a ser mostrado en el campo de descuento
/*/
Function E1CHECKDES()
Local nDesc		:= 0
Local oFinTitSer
Local aArea		:= {}
	
	If FwFldGet("RECNO") > 0
		aArea := SE1->(GetArea())
		SE1->(MsGoto(FwFldGet("RECNO")))
		oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
		nDesc := oFinTitSer:descFin("SE1", FwFldGet("FJT_EMISSA"), FwFldGet("E1_SALDO"), FwFldGet("E1_MOEDA"))
		SE1->(RestArea(aArea))
	EndIf

Return nDesc

/*/{Protheus.doc} E1CHECKINT
Función utilizada para el disparador que asigna el valor de los intereses del titulo.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	ninteres - numerico - valor a ser mostrado en el campo de intereses
/*/
Function E1CHECKINT()
Local ninteres		:= 0
Local oFinTitSer
Local aArea		:= {}
	
	If FwFldGet("RECNO") > 0
		aArea := SE1->(GetArea())
		SE1->(MsGoto(FwFldGet("RECNO")))
		oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
		ninteres := oFinTitSer:jurosFin(Max(FwFldGet("E1_MOEDA"),1), FwFldGet("FJT_EMISSA"))
		SE1->(RestArea(aArea))
	EndIf

Return ninteres

/*/{Protheus.doc} E1SALDOPE
Función utilizada para el disparador que asigna el valor del saldo pendiente del titulo.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	ninteres - numerico - valor a ser mostrado en el campo de saldo pendiente
/*/
Function E1SALDOPE()
Local nSaldoPe	:= 0
	
	If FwFldGet("CHECK")
		nSaldoPe := (FwFldGet("E1_SALDO") - FwFldGet("E1_DESCONT") + FwFldGet("E1_JUROS") +FwFldGet("E1_MULTA")) - FwFldGet("COBRAR")
	EndIf

Return nSaldoPe

/*/{Protheus.doc} E1BXMOE
Función utilizada para recalcuar el campo a cobrar cuando se modifica el monto de una moneda.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	nValor - numerico - valor a ser mostrado en el campo a cobrar
/*/
Function E1BXMOE()
Local nTasa		:= 0
Local nTasaB	:= 0
Local nMoneda	:= 1
Local cMoneda	:= "1"
Local cMonedaB	:= ""
Local nValMoe	:= ""
Local nValor	:= 0
Local nX		:= 0
Local nQtMoedas	:= Moedfin()
Local oModel	:= FWModelActive()
Local oModelSE1

	oModelSE1 := oModel:GetModel("SE1_DETAIL")
	cMoneda	:= Str(FwFldGet("E1_MOEDA"),IIf(FwFldGet("E1_MOEDA") <= 9,1,2))
	nMoneda := Val(cMoneda)
	nTasa := F887GtTaxM(oModel, cMoneda)

	For nX := 1 To nQtMoedas
		cMonedaB := Str(nX,IIf(nX <= 9,1,2))
		If oModelSE1:HasField("BAIXAR" + cMonedaB)
			nValMoe := FwFldGet("BAIXAR" + cMonedaB)
			If nValMoe > 0
				If cMoneda == cMonedaB
					nValor += nValMoe
				Else
					nTasaB	:= F887GtTaxM(oModel, cMonedaB)
					nValor += Round(xMoeda(nValMoe, nX, nMoneda, dDataBase, MsDecimais(nMoneda)+1, nTasaB, nTasa),MsDecimais(nMoneda))
				EndIf
			EndIf
		EndIf
	Next

Return nValor

/*/{Protheus.doc} F887SetMark
Función utilizada para marcar los títulos de la SE1.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
@Return 
/*/
Function F887SetMark(oModel)
Local oModelSE1
Local aError	:= 0
Local nX		:= 0
Local nLine		:= 0
Local lCheck	:= .F.
Local lError	:= .F.
Local lFactor	:= SEL->(ColumnPos("EL_FACTOR")) > 0

Default oModel	:= FWModelActive()

	Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T.)

	oModelSE1 := oModel:GetModel("SE1_DETAIL")

	nLine := oModelSE1:GetLine()

	For nX := 1 To oModelSE1:Length()
		oModelSE1:GoLine(nX)
		lCheck := BlockSE1(/*oView*/,"CHECK",nX,.T.)

		IF !lCheck .AND. VAZIO(aError)
			aError := oModel:GetErrorMessages()
			Help(,,STR0017,,aError[7],1, 0 ) //STR0017 - Atención
		ENDIF 

		If lCheck .And. MV_PAR06 == 1 .And. lFactor
			lCheck := F887Comp(oModelSE1)
			If !lCheck
				oModelSE1:SetValue("CHECK", lCheck)
			EndIf 
		EndIf
	Next

	oModelSE1:GoLine(nLine)

	F887ActSal(oModel)

Return .T.

/*/{Protheus.doc} F887ActSal
Función utilizada para realizar el calculo de los saldos de acuerdo a los títulos marcados y asignar a las monedas.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
@Return 
/*/
Function F887ActSal(oModel)
Local oModelSE1
Local oModelSEL
Local oModelMoe
Local oJson
Local oFinTitSer
Local oJBoby
Local oRason
Local oMoeda
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nVal		:= 0
Local nMoneda	:= 0
Local nLine		:= 0
Local cMotivo	:= ""
Local cMoneda	:= ""
Local cDescMoed	:= ""
Local aReceived	:= {}
Local aTitles	:= {}
Local aMonedas	:= {}
Local aRason	:= reasonsBx(2)

Default oModel	:= FWModelActive()

	oModelSE1 := oModel:GetModel("SE1_DETAIL")
	oModelSEL := oModel:GetModel("SEL_DETAIL")
	oModelMoe := oModel:GetModel("MOE_DETAIL")

	//Creación del json de motivos de baja para enviar el número correcto al servicio de calculo de totales.
	oRason := JsonObject():new()
	For nX := 1 To Len(aRason)
		oRason[aRason[nX]] := Str(nX,IIf(nX <= 9,1,2))
	Next
	
	//Cración del json de las monedas consiguradas.
	oMoeda := JsonObject():new()
	For nX := 1 To oModelMoe:Length()
		AADD(aReceived,JsonObject():new())
		nPos := Len(aReceived)
		cMoneda := oModelMoe:GetValue("MOEDA", nX)
		cDescMoed := AllTrim(oModelMoe:GetValue("DESCMOEDA", nX))
		If Empty(cDescMoed)
			nLine := oModelMoe:GetLine()
			oModelMoe:GoLine(nX)
			cDescMoed := AllTrim(SuperGetMv("MV_MOEDA" + cMoneda, .F., ""))
			oModelMoe:LoadValue("DESCMOEDA", cDescMoed)
			oModelMoe:GoLine(nLine)
		EndIf
		aReceived[nPos]['moneda'] := cDescMoed
		aReceived[nPos]['quantity'] := 0
		aAdd(aMonedas, {cMoneda, cDescMoed})
		oMoeda[cMoneda] := JsonObject():new()
		oMoeda[cMoneda]["DESC"] := cDescMoed
		oMoeda[cMoneda]["POS"] := nPos
	Next

	//Obtención de montos recibidos
	For nX := 1 To oModelSEL:Length()
		If !oModelSEL:IsDeleted(nX)
			cMoneda := AllTrim(oModelSEL:GetValue("EL_MOEDA", nX))
			If oModelSEL:GetValue("EL_VALOR", nX) > 0 .and. oMoeda:HasProperty(cMoneda)
				nPos := oMoeda[cMoneda]["POS"]
				aReceived[nPos]['quantity'] += oModelSEL:GetValue("EL_VALOR", nX)
			EndIf
		EndIf
	Next

	//Creación del json con los títulos marcados.
	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("CHECK", nX) .Or. oModelSE1:GetValue("BAIXAR", nX) > 0
			AADD(aTitles, JsonObject():new())
			nPos := Len(aTitles)
			nVal := 0
			For nY := 1 To Len(aMonedas)
				aTitles[nPos][aMonedas[nY,2]] := oModelSE1:GetValue("BAIXAR" + aMonedas[nY,1], nX)
				nVal += oModelSE1:GetValue("BAIXAR" + aMonedas[nY,1], nX) //Usado para verificar si hubo valor en alguna moneda.
			Next
			If nVal == 0 //Usado para execautos que solo se informa el valor en el campo BAIXAR.
				nMoneda := oModelSE1:GetValue("E1_MOEDA", nX)
				If oMoeda:HasProperty(AllTrim(Str(nMoneda)))
					cMoneda := oMoeda[AllTrim(Str(nMoneda))]["DESC"]
					aTitles[nPos][cMoneda] := oModelSE1:GetValue("BAIXAR", nX)
				EndIf
			EndIf
			cMotivo := AllTrim(oModelSE1:GetValue("E1_MOTIVO", nX))
			aTitles[nPos]['type'] := AllTrim(oModelSE1:GetValue("E1_TIPO", nX))
			aTitles[nPos]['reasonBx'] := Iif(oRason:HasProperty(cMotivo), oRason[cMotivo], "")
		EndIf
	Next
	F887RefVw("VIEW_SE1")

	//Actualización de recibido en el model de monedas.
	For nX := 1 To Len(aReceived)
		F887ActMoe(oModel, 'RECIBIDO', aReceived[nX]['quantity'], {{"DESCMOEDA", aReceived[nX]['moneda']}})
	Next

	oJBoby := JsonObject():new()
	oJBoby['received'] := aReceived
	oJBoby['titles'] := aTitles

	//Consulta del serivicio de totales.
	oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
	oJson := oFinTitSer:totalsTitlesFinancialService(oJBoby)

	//Actualización de los saldos en el model de monedas.
	For nX := 1 To Len(oJson['response'])
		F887ActMoe(oModel, 'SALDO', oJson['response'][nX]['value'], {{"DESCMOEDA", oJson['response'][nX]['coin']}})
	Next

Return

/*/{Protheus.doc} F887ActMoe
Función utilizada para asignar los valores en el modelo de monedas.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cCampo - caracter - nombre del campo a ser actualizado.
	nValor - numerico - valor a ser asignado
	aSeek - array - array con la información para posicionar en la moneda correcta Ejemplo: {{campo, valor}} 
@Return 
/*/
Function F887ActMoe(oModel, cCampo, nValor, aSeek )
Local nLine		:= 0
Local oModelMoe

Default oModel		:= FWModelActive()
Default cCampo		:= ""
Default nValor		:= 0
Default aSeek		:= {{"MOEDA", "1"}}

	oModelMoe := oModel:GetModel("MOE_DETAIL")

	nLine := oModelMoe:GetLine()

	If oModelMoe:SeekLine(aSeek, .F., .T.)
		oModelMoe:SetValue(cCampo, nValor)
		oModelMoe:GoLine(nLine)
		F887RefVw("VIEW_MOE")
	EndIf

Return

/*/{Protheus.doc} F887GtTaxM
Función utilizada para retornar la tasa de la moneda buscada.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cMoneda - caracter - moneda de la cual se busca la tasa
@Return 
	nTasa - numerico - valor de la tasa de la moneda.
/*/
Function F887GtTaxM(oModel, cMoneda)
Local oModelMoe
Local nTasa		:= 1
Local nLine		:= 0

Default oModel		:= FWModelActive()
Default cMoneda		:= "1"

	oModelMoe := oModel:GetModel("MOE_DETAIL")
	nLine := oModelMoe:GetLine()
	If oModelMoe:SeekLine({{"MOEDA", cMoneda}}, .F., .T.)
		nTasa := oModelMoe:GetValue('TASA')
		oModelMoe:GoLine(nLine)
	EndIf

Return nTasa

/*/{Protheus.doc} F887E1MOT
Función utilizada para retornar un array con los motivos de baja para la view.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	aCombo - array - arreglo con los motivos de baja
/*/
Static Function F887E1MOT()
Local nX		:= 0
Local aCombo	:= {}
Local aReasonL	:= reasonsBx(1)
Local aReason	:= reasonsBx(2)

	For nX := 1 To Len(aReason)
		aAdd(aCombo, aReason[nX] + "=" + aReasonL[nX])	
	Next

Return aCombo

/*/{Protheus.doc} F887RefVw
Función utilizada para 
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
	cIdView - caracter - nombre de la parte de la view a ser actualizada.
@Return 
/*/
Function F887RefVw(cIdView)
Local oView		:= FwViewActive()

Default cIdView	:= ""

	If ValType(oView) == "O"
		If !Empty(cIdView)
			oView:Refresh(cIdView)
		Else
			oView:Refresh()
		EndIf
	EndIf

Return

/*/{Protheus.doc} F887GtMoTx
Función utilizada para obtener las tasas de la moneda.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	lMonUno - logico - Considera moneda 1, .T. la considera, .F. no la conidera.
@Return 
	aTxMoedas - array - valor de la tasa de la moneda.
/*/
Function F887GtMoTx(oModel, lMonUno)
Local nX		:= 0
Local aTxMoedas	:= {}
Local oModelMoe

Default oModel	:= FWModelActive()
Default lMonUno	:= .F.

	oModelMoe := oModel:GetModel("MOE_DETAIL")

	For nX := 1 To oModelMoe:Length()
		If !(AllTrim(oModelMoe:GetValue("MOEDA", nX)) == "1" .and. !lMonUno)
			aAdd(aTxMoedas, {AllTrim(oModelMoe:GetValue("DESCMOEDA", nX)), oModelMoe:GetValue("TASA", nX), oModelMoe:GetValue("MOEDA", nX), oModelMoe:GetValue("RECIBIDO", nX), oModelMoe:GetValue("SALDO", nX)})
		EndIf
	Next

Return aTxMoedas

/*/{Protheus.doc} F887StMoTx
Función utilizada para retornar la tasa de la moneda buscada.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	aItems - array - valor de la tasa de la moneda {"MONEDA", 0}.
@Return 
/*/
Function F887StMoTx(oModel, aItems)
Local nX		:= 0

Default oModel	:= FWModelActive()
Default aItems	:= {}

	//Actualización de los saldos en el model de onedas.
	For nX := 1 To Len(aItems)
		F887ActMoe(oModel, 'TASA', aItems[nX][2], {{"DESCMOEDA", aItems[nX][1]}})
	Next

Return

/*/{Protheus.doc} F887EditTx
Función utilizada para crear una pantalla para editar las tasas
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
@Return 
/*/
Function F887EditTx(oModel, lSaldos)
Local oDlg		:= Nil
Local oFwBrowse	:= Nil
Local oPanel	:= Nil
Local aColumns	:= {}
Local aItems	:={}
Local nX		:= 0
Local nLenDesMoe:= F887LnDesM()

Default oModel	:= FWModelActive()
Default lSaldos	:= .F.

	oDlg := FwDialogModal():New()
	oDlg:SetBackground(.F.)
    oDlg:SetTitle(Iif(lSaldos, STR0172, STR0173))
    oDlg:SetEscClose(.T.)
    oDlg:setSize(150, Iif(lSaldos, 350,200 ))
    oDlg:EnableFormBar(.T.)
	oDlg:CreateDialog()
	oPanel := oDlg:getPanelMain()
	oDlg:CreateFormBar()

 
    oFwBrowse := FWBrowse():New(oPanel)
    oFwBrowse:SetDataArrayoBrowse()  //Define utilização de array
 
    aItems := F887GtMoTx(oModel, lSaldos)      //Carregar os itens que irão compor o conteudo do grid
    oFwBrowse:SetArray(aItems) 		  //Indica o array utilizado para apresentação dos dados no Browse.
 
	//Columnas
	aAdd(aColumns, {STR0103, {|oBrw| aItems[oBrw:At(), 1] }, "C", "@!", 1, nLenDesMoe, 0, .F., {|| }, .F., Nil, "CMONEDA", {|| AlwaysTrue()}, .F., .T., {}, "CMONEDA"}) //Moneda
	aAdd(aColumns, {STR0104, {|oBrw| aItems[oBrw:At(), 2] }, "N", "@E 99,999.9999", 2, 10, 4, !lSaldos, {|| Positivo()}, .F., , "NTASA", {|| AlwaysTrue()}, .F., .T., , "NTASA"}) //Tasa
	If lSaldos
		aAdd(aColumns, {STR0105, {|oBrw| aItems[oBrw:At(), 4] }, "N", "@E 99,999,999,999.99", 2, 14, 2, .F., {|| }, .F., , "NREC", {|| AlwaysTrue()}, .F., .T., , "NREC"}) //Recibido
		aAdd(aColumns, {STR0106, {|oBrw| aItems[oBrw:At(), 5] }, "N", "@E 99,999,999,999.99", 2, 14, 2, .F., {|| }, .F., , "NSAL", {|| AlwaysTrue()}, .F., .T., , "NSAL"}) //Saldos
	EndIf

    //Cria as colunas do array
    For nX := 1 To Len(aColumns )
        oFwBrowse:AddColumn( aColumns[nX] )
    Next

	oFwBrowse:SetPreEditCell({|| F887ChkMoe(oModel, aItems[oFwBrowse:nAt,3])})
	oFwBrowse:SetEditCell(!lSaldos, {|| F887StTxBw(aItems, oFwBrowse:nAt, Upper(Readvar()), &(Readvar()))})
 
    oFwBrowse:SetOwner(oPanel)
    oFwBrowse:SetDescription( STR0168 ) //"Editar Tasas"
	oFwBrowse:DisableConfig(.t.)
	oFwBrowse:DisableReport(.t.)
    oFwBrowse:Activate()

	oDlg:AddOkButton({|| Iif(!lSaldos,F887StMoTx(oModel, aItems),), oDlg:DeActivate()}, STR0169) //"Confirmar"
	oDlg:AddCloseButton({|| oDlg:DeActivate()}, STR0170) //"Anular"
 
    oDlg:Activate()
 
Return

/*/{Protheus.doc} F887StTxBw
Función utilizada para verificar si existen titulos seleccionados en la moneda que se intenta cambiar la tasa
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    aItems - array - arreglo con la información de las monedas
	nLinea - numerico - numero de linea que es verificada
	cCampo - caracter - nombre del campo que está siendo editado.
	nValor - numerico - valor que está siendo modificado
@Return 
/*/
Static Function F887StTxBw(aItems, nLinea, cCampo, nValor)
Local lRet		:= .T.

Default aItems	:= {{"", 1, 1}}
Default nLinea	:= 1
Default cCampo	:= "NTASA"
Default nValor	:= 1

	If cCampo == "NTASA"
		aItems[nLinea,2] := Iif(nValor <= 0, aItems[nLinea,2], nValor)
	EndIf

Return lRet

/*/{Protheus.doc} F887ChkMoe
Función utilizada para verificar si existen titulos seleccionados en la moneda que se intenta cambiar la tasa
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	cMoneda - caracter - Moneda que será verificada.
@Return 
/*/
Static Function F887ChkMoe(oModel, cMoneda)
Local lRet		:= .T.
Local nX		:= 0

Local oModelSE1

Default oModel	:= FWModelActive()
Default cMoneda	:= "1"

	oModelSE1 := oModel:GetModel("SE1_DETAIL")

	//Creación del json con los títulos marcados.
	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("CHECK", nX)
			If oModelSE1:GetValue("BAIXAR" + cMoneda, nX) > 0
				lRet := .F.
				Help( " ", 1, "TASA",,STR0171,1,0)// 'Esta tasa no puede cambiarse pues se efectuaron movimientos utilizando esta moneda'
			EndIf
		EndIf
	Next

Return lRet

/*/{Protheus.doc} F887GtJson
Función utilizada para crear un json con la información del recibo, títulos y formas de pago.
@author 	raul.medina
@since 		08/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
@Return 
	oJson - Json - json con la información del recibo, títulos y formas de pago.
/*/
Function F887GtJson(oModel)
Local oJson
Local oModelFJT
Local oModelSE1
Local oModelSEL
Local oModelMOE
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local aTitulos	:= {}
Local aMonedas	:= {}
Local aFormPago	:= {}
Local aFormsPago:= {}
Local aFields	:= {}
Local aSELFields:= {}
Local aPergAux	:= {}
Local lPerg		:= .F.
Local xValPar

Default oModel		:= FWModelActive()

	oModelFJT := oModel:GetModel("FJT_MASTER")
	oModelSE1 := oModel:GetModel("SE1_DETAIL")
	oModelSEL := oModel:GetModel("SEL_DETAIL")
	oModelMOE := oModel:GetModel("MOE_DETAIL")

	oJson := JsonObject():new()
	oJson['encabezado'] := JsonObject():new()
	oJson['titulos'] := {}
	oJson['monedas'] := {}
	oJson['validations'] := JsonObject():new()
	oJson['formasPago'] := {}
	oJson['params'] := JsonObject():new()
	oJson['generateCfdi'] := .F.
	oJson['generatePdf'] := .F.
	oJson['factoraje'] := .F.
	oJson['dateSystem'] := DTOS(dDataBase)

	//Encabezado
	oJson['encabezado']['serie'] := oModelFJT:GetValue("FJT_SERIE")
	oJson['encabezado']['recibo'] := oModelFJT:GetValue("FJT_RECIBO")
	oJson['encabezado']['emissa'] := DTOS(oModelFJT:GetValue("FJT_EMISSA"))
	oJson['encabezado']['nature'] := oModelFJT:GetValue("FJT_NATURE")
	oJson['encabezado']['client'] := oModelFJT:GetValue("FJT_CLIENT")
	oJson['encabezado']['loja'] := oModelFJT:GetValue("FJT_LOJA")
	oJson['encabezado']['nome'] := oModelFJT:GetValue("FJT_NOME")
	oJson['encabezado']['cobrad'] := oModelFJT:GetValue("FJT_COBRAD")
	oJson['encabezado']['recprv'] := oModelFJT:GetValue("FJT_RECPRV")
	oJson['encabezado']['fechaEmission'] := DTOS(dDataBase)

	//Validations
	oJson['validations']['success'] := ""
	oJson['validations']['requestRA'] := ""
	oJson['validations']['message'] := ""
	oJson['validations']['difference'] := ""
	oJson['validations']['responseRA'] := ""

	//Titulos
	For nX := 1 To oModelSE1:Length()
		If !oModelSE1:IsDeleted(nX) .and. oModelSE1:GetValue("BAIXAR" , nX) > 0
			AADD(aTitulos,JsonObject():new())
			nPos := Len(aTitulos)
			
			aTitulos[nPos]['branch'] := oModelSE1:GetValue("E1_FILIAL" , nX)
			aTitulos[nPos]['billnumber'] := oModelSE1:GetValue("E1_NUM" , nX)
			aTitulos[nPos]['type'] := oModelSE1:GetValue("E1_TIPO" , nX)
			aTitulos[nPos]['actualduedt'] := DTOS(oModelSE1:GetValue("E1_VENCTO" , nX))
			aTitulos[nPos]['currency'] := oModelSE1:GetValue("E1_MOEDA" , nX)
			aTitulos[nPos]['unit'] := oModelSE1:GetValue("E1_LOJA" , nX)
			aTitulos[nPos]['installment'] := oModelSE1:GetValue("E1_PARCELA" , nX)
			aTitulos[nPos]['billvalue'] := oModelSE1:GetValue("E1_VALOR" , nX)
			aTitulos[nPos]['customer'] := oModelSE1:GetValue("E1_CLIENTE" , nX)
			aTitulos[nPos]['class'] := oModelSE1:GetValue("E1_NATUREZ" , nX)
			aTitulos[nPos]['balance'] := oModelSE1:GetValue("E1_SALDO" , nX)
			aTitulos[nPos]['prefix'] := oModelSE1:GetValue("E1_PREFIXO" , nX)
			aTitulos[nPos]['issuedt'] := DTOS(oModelSE1:GetValue("E1_EMISSAO" , nX))
			aTitulos[nPos]['discuont'] := oModelSE1:GetValue("E1_DESCONT" , nX)
			aTitulos[nPos]['interest'] := oModelSE1:GetValue("E1_JUROS" , nX)
			aTitulos[nPos]['fine'] := oModelSE1:GetValue("E1_MULTA" , nX)
			aTitulos[nPos]['origin'] := oModelSE1:GetValue("E1_ORIGEM" , nX)
			aTitulos[nPos]['client'] := oModelSE1:GetValue("E1_CLIENTE" , nX)
			aTitulos[nPos]['originbranch'] := oModelSE1:GetValue("E1_FILORIG" , nX)
			aTitulos[nPos]['recno'] := oModelSE1:GetValue("RECNO" , nX)
			aTitulos[nPos]['cobrar'] := Iif(oModelSE1:HasField("COBRAR"), oModelSE1:GetValue("COBRAR" , nX), oModelSE1:GetValue("BAIXAR" , nX))
			aTitulos[nPos]['$selected'] := .T.
		EndIf
	Next

	//Monedas
	For nX := 1 To oModelMoe:Length()
		If !oModelMoe:IsDeleted(nX)
			AADD(aMonedas,JsonObject():new())
			nPos := Len(aMonedas)
			aMonedas[nPos]['coin'] := AllTrim(oModelMoe:GetValue("DESCMOEDA", nX))
			aMonedas[nPos]['tasa'] := oModelMoe:GetValue("TASA", nX)
			aMonedas[nPos]['received'] := oModelMoe:GetValue("RECIBIDO", nX)
			aMonedas[nPos]['balance'] := oModelMoe:GetValue("SALDO", nX)
			aMonedas[nPos]['type'] := AllTrim(oModelMoe:GetValue("DESCMOEDA", nX))
			aMonedas[nPos]['moneda'] := oModelMoe:GetValue("MOEDA", nX)
		EndIf
	Next

	//Formas de Pago
	aFields := oModelSEL:GetStruct():GetFields()
	For nX := 1 To Len(aFields)
		aAdd(aSELFields, {aFields[nX][3], lower(STRTRAN(aFields[nX][3], "EL_", "")), aFields[nX][4]})
	Next

	For nX := 1 To oModelSEL:Length()
		If !oModelSEL:IsDeleted(nX) .and. oModelSEL:IsUpdated(nX)
			aFormPago := {}
			For nY := 1 To Len(aSELFields)
				AADD(aFormPago,JsonObject():new())
				nPos := Len(aFormPago)
				aFormPago[nPos]['property'] := aSELFields[nY][2]
				If aSELFields[nY][3] == "C"
					aFormPago[nPos]['value'] := AllTrim(oModelSEL:GetValue(aSELFields[nY][1], nX))
				ElseIf aSELFields[nY][3] == "D"
					aFormPago[nPos]['value'] := oModelSEL:GetValue(aSELFields[nY][1], nX)
					aFormPago[nPos]['value'] := StrZero(Year(aFormPago[nPos]['value']),4) + "-" + StrZero(Month(aFormPago[nPos]['value']),2)  + "-" + StrZero(Day(aFormPago[nPos]['value']),2)
				Else
					aFormPago[nPos]['value'] := oModelSEL:GetValue(aSELFields[nY][1], nX)
				EndIf
			Next
			AADD(aFormsPago,aClone(aFormPago))
		EndIf
	Next

	//Params
	Pergunte("FIN998", .F., /*cTitle*/, .F., /*oDlg*/, .T., @aPergAux)
	lPerg := cPaisLoc == "MEX"
	oJson['params']['mv_par01'] := MV_PAR01
	oJson['params']['mv_par02'] := MV_PAR02
	oJson['params']['mv_par03'] := MV_PAR03
	oJson['params']['mv_par04'] := Iif(lPerg, MV_PAR04, "")
	oJson['params']['mv_par05'] := Iif(lPerg, MV_PAR05, "")
	oJson['params']['mv_par06'] := Iif(lPerg, MV_PAR06, "")
	oJson['params']['mv_par07'] := Iif(lPerg, MV_PAR07, "")
	oJson['params']['mv_par08'] := Iif(lPerg, MV_PAR08, MV_PAR04)
	oJson['params']['mv_par09'] := Iif(lPerg, MV_PAR09, MV_PAR05)
	oJson['params']['mv_par10'] := Iif(lPerg, MV_PAR10, MV_PAR06)
	oJson['params']['mv_par11'] := Iif(lPerg, MV_PAR11, MV_PAR07)

    GetMPar998("mv_par14", aPergAux, @xValPar)
	oJson['generateCfdi'] := Iif(lPerg .and. !Empty(xValPar), xValPar == 1, .F.)

	oJson['titulos'] := aClone(aTitulos)
	oJson['monedas'] := aClone(aMonedas)
	oJson['formasPago'] := aClone(aFormsPago)

Return oJson

/*/{Protheus.doc} F887SelOtT
Función utilizada para consumir el servicio de otros títulos.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
	lView - - indica si está siendo usada por la view.
	lMark - - indica si los títulos van a ser agregados como marcados al recibo. Regresa el parametro por retorno.
@Return 
	aItems - array - arreglo con la información de los títulos (Cada array es un objeto json)
/*/
Function F887GtOtTi(oModel, lView, lMark)
Local nX			:= 0
Local cLojas		:= ""
Local aLojas		:= {}
Local aItems		:= {}
Local oJson
Local oFinTitSer
Local oJBody
Local oJParamReq
Local oJQryRqPar
Local oModelFJT

Default oModel		:= FWModelActive()
Default lView		:= .F.
Default lMark		:= .F.

	oModelFJT := oModel:GetModel("FJT_MASTER")

	If !Empty(oModelFJT:GetValue("FJT_RECIBO")) .and. !Empty(oModelFJT:GetValue("FJT_EMISSA")) .and. !Empty(oModelFJT:GetValue("FJT_CLIENT")) .and. !Empty(oModelFJT:GetValue("FJT_LOJA"))

		If Pergunte("FIN998OTTI", lView, /*cTitle*/, .F., /*oDlg*/, .T.)

			If ExistBLock("F998VLOTTI")
				If !ExecBLock("F998VLOTTI",.F.,.F.)
					Return aItems
				EndIf
			EndIf
			
			lMark := MV_PAR09 == 1

			oJParamReq := JsonObject():new()
			oJQryRqPar := JsonObject():new()
			oJQryRqPar ['page'] := '1'
			oJQryRqPar ['pagesize'] := '100000'

			oJBody  := JsonObject():new()
			oJBody ['form'] := JsonObject():new()
			oJBody ['form']['branch'] := MV_PAR01       
			oJBody ['form']['client'] := {MV_PAR02}
			oJBody ['form']['code'] := {JsonObject():new()}
			oJBody ['form']['code'][1]['client'] := MV_PAR02
			oJBody ['form']['store'] := {}

			cLojas := AllTrim(MV_PAR03)
			aLojas := StrTokArr(cLojas, ",;")
			For nX := 1 To Len(aLojas)
				If !Empty(aLojas[nX])
					AADD(oJBody ['form']['store'], aLojas[nX])
				EndIf
			Next

			oJBody['form']['prefix'] := AllTrim(MV_PAR04)
			oJBody['form']['ofNumber']  = MV_PAR05
			oJBody['form']['toNumber']  = MV_PAR06
			oJBody['form']['minDate']  = StrZero(Year(MV_PAR07),4) + "-" + StrZero(Month(MV_PAR07),2)  + "-" + StrZero(Day(MV_PAR07),2) 
			oJBody['form']['maxDate']  = StrZero(Year(MV_PAR08),4) + "-" + StrZero(Month(MV_PAR08),2)  + "-" + StrZero(Day(MV_PAR08),2)
			oJBody['form']['ofDate']  = DTOS(MV_PAR07)
			oJBody['form']['toDate']  = DTOS(MV_PAR08)
			oJBody['form']['allChecked'] := lMark

			oJBody ['formHeader'] := JsonObject():new()
			oJBody ['formHeader']['filial'] := xFilial("FJT")       
			oJBody ['formHeader']['code'] := oModelFJT:GetValue("FJT_CLIENT")
			oJBody ['formHeader']['store'] := oModelFJT:GetValue("FJT_LOJA")
			oJBody ['formHeader']['dateSelected'] := StrZero(Year(oModelFJT:GetValue("FJT_EMISSA")),4) + "-" + StrZero(Month(oModelFJT:GetValue("FJT_EMISSA")),2)  + "-" + StrZero(Day(oModelFJT:GetValue("FJT_EMISSA")),2)
			oJBody ['formHeader']['dateSystem'] := DTOS(dDataBase)
			oJBody ['formHeader']['clientLength'] := Getsx3Cache("FJT_CLIENT", "X3_TAMANHO")

			oFinTitSer := tr.financialTitles.FinancialTitlesService():New()
			oJson := oFinTitSer:financialTitlesOthersService(oJBody, oJParamReq, oJQryRqPar)

			If oJson:HasProperty("response") .and. oJson["response"]:HasProperty("items")
				For nX := 1 To Len(oJson["response"]["items"])
					oJson["response"]["items"][nX]['check'] := .F.
				Next
				aItems := oJson["response"]["items"]
			EndIf

		EndIf
	EndIf

Return aItems

/*/{Protheus.doc} F887SelOtT
Función utilizada para crear una pantalla de selección de otros títulos.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - model activo para ser procesado
@Return 
/*/
Function F887SelOtT(oModel)
Local oDlg		:= Nil
Local oFwBrowse	:= Nil
Local oPanel	:= Nil
Local aColumns	:= {}
Local aItems	:= {}
Local aItmsAux	:= {}
Local aCampos	:= {}
Local aPesq		:= {}
Local aButtons	:= {}
Local nX		:= 0
Local cTitulo	:= ""
Local cTipo		:= ""
Local cPicture	:= ""
Local nTam		:= 0
Local nDec		:= 0
Local lMark		:= .F.
Local bMark

Default oModel	:= FWModelActive()

	aItems := F887GtOtTi(oModel, .T., @lMark)

	If Len(aItems) == 0
		Return
	EndIf

	oModel:GetModel("SE1_DETAIL"):SetNoInsertLine(.F.)

	oDlg := FwDialogModal():New()
    oDlg:SetTitle(STR0188) //"Agregar otros títulos"
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

	//Columnas
	aCampos := F887GtJsCp()
	For nX := 1 To Len(aCampos)
		cTitulo	:= AllTrim(FwX3Titulo(aCampos[nX][1]))
		cTipo	:= GetSx3Cache(aCampos[nX][1], "X3_TIPO")
		cPicture:= AllTrim(GetSx3Cache(aCampos[nX][1], "X3_PICTURE"))
		nTam	:= GetSx3Cache(aCampos[nX][1], "X3_TAMANHO")
		nDec	:= GetSx3Cache(aCampos[nX][1], "X3_DECIMAL")
		aAdd(aColumns, {cTitulo, &( "{ |oBrw| aItems[oBrw:At()]['" + aCampos[nX][2] + "'] }" ), cTipo, cPicture, 1, nTam, nDec, .F., {|| }, .F., Nil, "__ReadVar", {|| AlwaysTrue()}, .F., .T., {}, aCampos[nX][2]})	
		If cTipo == "D"
			aColumns[Len(aColumns)][2] := &( "{ |oBrw| STOD(aItems[oBrw:At()]['" + aCampos[nX][2] + "']) }" )
		EndIf
		If cTipo == "C"
			Aadd( aPesq , {	cTitulo, { { aCampos[nX][2], cTipo, nTam, nDec, cTitulo, cPicture}}, Len(aPesq) + 1})
		EndIf
    Next

    //Cria as colunas do array
    For nX := 1 To Len(aColumns )
        oFwBrowse:AddColumn( aColumns[nX] )
    Next
	//oFwBrowse:SetSeek( {|a,b,c,d,e| F887SkOtTi(a,b,c,d,e)} , aPesq )
    oFwBrowse:SetFilterDefault()
	oFwBrowse:SetOwner(oPanel)
    oFwBrowse:SetDescription( STR0189 ) //"Títutlos a cobrar o compensar"
	oFwBrowse:DisableConfig(.T.)
	oFwBrowse:DisableReport(.T.)
    oFwBrowse:Activate()

	oDlg:AddOkButton({|| F887AdOtTi(oModel, aItems, lMark), oDlg:DeActivate()}, STR0169) //"Confirmar"
	oDlg:AddCloseButton({|| oDlg:DeActivate()}, STR0170) //"Anular"

	aAdd(aButtons, {"", STR0190, {|| aItmsAux := F887GtOtTi(oModel, .T., @lMark), aItems := Iif(Len(aItmsAux) > 0,aItmsAux,aItems), oFwBrowse:SetArray(aItems) ,oFwBrowse:Refresh()}, , , .T., .F.}) //"Parámetros"
	oDlg:addButtons(aButtons)
	
    oDlg:Activate()

	oModel:GetModel("SE1_DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SE1_DETAIL"):GoLine(1)
 
Return

/*/{Protheus.doc} F887GtJsCp
Función utilizada para obtener los campos relación json/diccionario.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	aCampos - array - {{Campo , propiedad},{....}
/*/
Function F887GtJsCp()
Local aCampos	:= {}

	aAdd(aCampos, {"E1_FILIAL"	, "branch"})
	aAdd(aCampos, {"E1_NUM"		, "billnumber"})
	aAdd(aCampos, {"E1_TIPO"	, "type"})
	aAdd(aCampos, {"E1_VENCTO"	, "actualduedt"})
	aAdd(aCampos, {"E1_MOEDA"	, "currency"})
	aAdd(aCampos, {"E1_LOJA"	, "unit"})
	aAdd(aCampos, {"E1_PARCELA"	, "installment"})
	aAdd(aCampos, {"E1_VALOR"	, "billvalue"})
	aAdd(aCampos, {"E1_CLIENTE"	, "client"})
	aAdd(aCampos, {"E1_NATUREZ"	, "class"})
	aAdd(aCampos, {"E1_SALDO"	, "balance"})
	aAdd(aCampos, {"E1_PREFIXO"	, "prefix"})
	aAdd(aCampos, {"E1_EMISSAO"	, "issuedt"})
	aAdd(aCampos, {"E1_DESCONT"	, "discount"})
	aAdd(aCampos, {"E1_JUROS"	, "interest"})
	aAdd(aCampos, {"E1_MULTA"	, "fine"})
	aAdd(aCampos, {"E1_ORIGEM"	, "origin"})

Return aCampos

/*/{Protheus.doc} F887AdOtTi
Función utilizada para insertar los items marcados al grid.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
	oModel - - model activo para ser procesado
	aItems - array - arreglo con la información del título a ser agregada al gird.
	lMark - logico - indica si se marcan los títulos en el recibo.
@Return 
/*/
Function F887AdOtTi(oModel, aItems, lMark)
Local nX		:= 0
Local lRefresh	:= .F.
Local cPrefixo	:= ""
Local cNum		:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local nTamPre	:= GetSx3Cache("E1_PREFIXO", "X3_TAMANHO")
Local nTamNum	:= GetSx3Cache("E1_NUM", "X3_TAMANHO")
Local nTamParc	:= GetSx3Cache("E1_PARCELA", "X3_TAMANHO")
Local nTamTipo	:= GetSx3Cache("E1_TIPO", "X3_TAMANHO")
Local nTamCli	:= GetSx3Cache("E1_CLIENTE", "X3_TAMANHO")
Local nTamLoja	:= GetSx3Cache("E1_LOJA", "X3_TAMANHO")
Local oModelSE1

Default oModel	:= FWModelActive()
Default aItems	:= {}
Default lMark	:= .F.

	oModelSE1 := oModel:GetModel("SE1_DETAIL")
	For nX := 1 to Len(aItems)
		If aItems[nX]:HasProperty("check") .and. aItems[nX]["check"]
			cPrefixo:= PadR(aItems[nX]["prefix"], nTamPre)
			cNum	:= PadR(aItems[nX]["billnumber"], nTamNum)
			cParcela:= PadR(aItems[nX]["installment"], nTamParc)
			cTipo	:= PadR(aItems[nX]["type"], nTamTipo)
			cCliente:= PadR(aItems[nX]["client"], nTamCli)
			cLoja	:= PadR(aItems[nX]["unit"], nTamLoja)
			If !oModelSE1:SeekLine({{"E1_PREFIXO", cPrefixo}, {"E1_NUM", cNum}, {"E1_PARCELA", cParcela}, {"E1_TIPO", cTipo}, {"E1_CLIENTE", cCliente}, {"E1_LOJA", cLoja}}, .F., .F.)
				F887SetTit(oModelSE1, {aItems[nX]}, lMark, .T.)
				lRefresh := .T.
			EndIf
		EndIf
	Next
	If lRefresh
		If lMark
			F887ActSal(oModel)
		EndIf
		F887RefVw("VIEW_SE1")
	EndIf

Return

/*/{Protheus.doc} F887CalMoe
Función utilizada para calcular el valor de una moneda a partir del saldo pendiente y las tasas de cambio.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
	oModel - - model activo para ser procesado
	aSelect - - información del campo en el que está posicionado {"VIEW", "CAMPO"}
@Return 
/*/
Function F887CalMoe(oModel, aSelect)
Local cView		:= ""
Local cCampo	:= ""
Local cMonedaO	:= ""
Local cMonedaD	:= ""
Local nMonedaO	:= 0
Local nMonedaD	:= 0
Local nTasaO	:= 0
Local nTasaD	:= 0
Local nValor	:= 0
Local nDecD		:= 0
Local nFocus	:= GetFocus()
Local oModelSE1	

Default oModel	:= FWModelActive()
Default aSelect	:= {"", ""}

	cView := aSelect[1]
	If cView == "VIEW_SE1"
		cCampo := aSelect[2]
		If "BAIXAR" $ cCampo .and. !("BAIXAR" == cCampo)
			oModelSE1 := oModel:GetModel("SE1_DETAIL")
			If oModelSE1:GetValue("CHECK") .and. oModelSE1:GetValue("SALDOPE") > 0 .and. oModelSE1:GetValue(cCampo) == 0
				//Moneda destino
				cMonedaD := STRTRAN(cCampo, "BAIXAR", "")
				nMonedaD := Val(cMonedaD)
				nTasaD := F887GtTaxM( , cMonedaD)
				nDecD := MsDecimais(nMonedaD)
				//Moneda origen del título.
				nMonedaO := oModelSE1:GetValue("E1_MOEDA")
				cMonedaO := Str(nMonedaO,IIf(nMonedaO <= 9,1,2))
				nTasaO := F887GtTaxM( , cMonedaO)

				nValor := Round(xMoeda(oModelSE1:GetValue("SALDOPE"), nMonedaO, nMonedaD, dDataBase, nDecD+1, nTasaO, nTasaD),nDecD)

				If nValor > 0
					oModelSE1:SetValue(cCampo, nValor)
					F887ActSal(oModel)
				EndIf
			EndIf
		EndIf
	EndIf
	SetFocus(nFocus)

Return

/*/{Protheus.doc} F887SelLoj
Función utilizadaseleccionar y validar tiendas de un cliente.
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
Parametros
	cCliente - caracter -codigo de cliente.
	cLojas - caracter - string separado por ; o , de las lojas.
	cVarMV - caracter - MV_MVPAR03
@Return 
/*/
Function F887SelLoj(cCliente, cLojas, cVarMV)
Local cMvPar	:= ""
Local cMvParDef	:= ""
Local cTitulo	:= "Tiendas"
Local cLojaRet	:= ""
Local aLojas	:= {}
Local aArea		:= {}
Local nTamLoj	:= GetSx3Cache("A1_LOJA", "X3_TAMANHO")
Local nTamCod	:= GetSx3Cache("A1_COD", "X3_TAMANHO")
Local nLoj		:= 0
Local nX		:= 0
Local nLenStr	:= 0
Local lRet		:= .T.

Default cCliente := ""
Default cLojas := ""
Default cVarMV := ""

	aArea := SA1->(GetArea())
	DbSelectArea("SA1") //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSetOrder(1))
	If !Empty(cLojas)
		aLojas := StrTokArr(cLojas, ",;")
		For nX := 1 To Len(aLojas)
			If !ExistCpo("SA1",Padr(cCliente,nTamCod)+aLojas[nX])
				lRet := .F.
			EndIf
		Next
	Else
		If !Empty(cCliente)
			cMvParDef := ""
			If SA1->(MsSeek(xFilial("SA1")+cCliente))  
				While SA1->A1_COD == cCliente
					aAdd(aLojas,SA1->A1_LOJA)
					cMvParDef += SA1->A1_LOJA
					nLoj++
					SA1->(DbSkip())
				EndDo
			EndIf
			f_Opcoes(@cMvPar,cTitulo,aLojas,cMvParDef,,,.F.,nTamLoj,nLoj,.T.,,,,,,,)  // Chama funcao Adm_Opcoes
			If !Empty(cVarMV) .and. !Empty(cMvPar)
				cMvPar := AllTrim(cMvPar)
				nLenStr := Len(cMvPar)
				nX := 1
				While nX < nLenStr
					cLojaRet += Iif(!Empty(cLojaRet), ";", "") + Substr(cMvPar, nX, nTamLoj)
					nX += nTamLoj
				EndDo
				&cVarMV = cLojaRet
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} F887DinPic
Función utilizada para generar un picture dinamico.
@author 	raul.medina
@since 		10/2024
@version	12.1.2210 / Superior
Parametros
	nInt - numerico - numero de enteros del picture.
	nDec - numerico - numero de decimales del picture.
@Return 
	cPicture - caracter - picture generado.
/*/
Static Function F887DinPic(nInt, nDec)
Local cPicture 	:= ""
Local nTam		:= 0
Local nRep		:= 0

Default nInt	:= 16
Default nDec	:= 2

	nTam := nInt - Iif(nDec > 0, nDec+1, 0)
	
	While nTam > 0
		nRep := Iif(nTam > 3, 3, nTam)
		nTam -= nRep
		cPicture := Iif(nTam > 0, ",", "") + Replicate("9", nRep) + cPicture
	EndDo
	
	If nDec > 0
		cPicture += "." + Replicate("9", nDec)
	EndIf

	cPicture := "@E " + cPicture

Return cPicture

/*/{Protheus.doc} F887LnDesM
Función utilizada para obtener el tamaño del nombre de las monedas.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
@Return 
	nLen - numerico -tamaño del nombre de la moneda más larga.
/*/
Static Function F887LnDesM()
Local nQtMoedas		:= Moedfin()
Local nX			:= 0
Local nLen			:= 20
Local nLenAux		:= 0
Local cMoeda		:= ""

	For nX := 1 To nQtMoedas
		cMoeda := Str(nX,IIf(nX <= 9,1,2))
		nLenAux := Len(AllTrim(SuperGetMv("MV_MOEDA" + cMoeda, .F., "")))
		If nLen < nLenAux
			nLen := nLenAux
		EndIf
	Next

Return nLen

/*/{Protheus.doc} F887MET
Función para metrica
@return		lRet 
@author 	Jose.Gonzalez
@version	12.1.2210 / Superior
@since 		18/03/2025
/*/
Function F887MET()
If __lMetric 
	FWMetrics():addMetrics("FINA887_Totvs_Recibo", {{"financeiro-protheus_cantidad-de-recibos-en-mvc", 1 }} ) 
	FWLsPutAsyncInfo("LS006", RetCodUsr(), '05', "FINA887AC")
EndIf
Return	.T.
