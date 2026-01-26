#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "FISA084.CH"

#Define SAliasHead  4
//---------------------------------------------------------------------
/*/{Protheus.doc} FISA084

Edicao de impostos dos documentos fiscais por impostos totalizados.
Obs: Nao utilizado para o Brasil.

@Param oList - Objeto com os impostos previamente calculados pelo
               documento fiscal

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
/*/
³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                        ³
|Ivan Gomez  |30/08/17|DMICNS-46 |Actualiza el valor en la pestaña de Títulos |
|Roberto Glez|14/12/17|DMICNS-651|Se llama funcion de actualización de pestana|
|            |        |          |de impuestos, Argentina.                    |
|Alf. Medrano|16/01/19|DMINA-5662|Se modifica fun FRateio() para cálculo impu-|
|            |        |          |-estos. En fun MaFisRet se asigna número de |
|            |        |          |ítem obtenido del campo TRB2_ITEM           |
|ARodriguez  |01/03/19|DMINA-6076|FCommit() no recalcular valores de impuestos|
|            |        |          |que no se hayan modificado. ARG             |
/*/
//---------------------------------------------------------------------
Function FISA084( oList, lExResh )

Local nI  := 0
Local lOk := .F.
Local lIncNFE  := .F.

Private oImpostos := oList
Private aAllTES   := {}
Private aAllImp   := {}
Private aItem     := aClone( aCols )
Private nPOSItem  := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_ITEM" } )
Private nPOSCod   := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_COD" } )
Private nPOSQuant := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_QUANT" } )
Private nPOSVUnit := IIf( aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VUNIT" } ) > 0, aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VUNIT" } ), aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_PRCVEN" } ) )
Private nPOSTotal := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_TOTAL" } )
Private nPOSTES   := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_TES" } )
Private lConPad   := .F.

Default lExResh	:= .T.

IF Type( "lMetImpEdi" ) <> "U"
	lMetImpEdi:=.T. // Bandera edicion de impuestos para metrica 
ENDIF
FIniAlias()

For nI := 1 to Len( aItem )
	If !aItem[nI][Len(aItem[nI])] .and. !Empty( aItem[nI,nPOSTES] )
		aAdd( aAllTES, aItem[nI,nPOSTES] )
	EndIf
Next nI

aAllImp := FGetImp( aAllTES )

If !ChkAliqImp(aAllImp, aItem)
	Return .F.
EndIf

If  cPaisLoc == "ARG" .And. Valtype("INCLUI") <> "U"
	lIncNFE := INCLUI
Endif

lOk := FwExecView( STR0001, "FISA084", MODEL_OPERATION_UPDATE, , { || .T. } ) == 0 //"Edição de Impostos"

If  cPaisLoc == "ARG" .And. Valtype("INCLUI") <> "U"
	INCLUI := lIncNFE
Endif

If lOk
	Help( ,, "Help", , STR0002, 1, 0 ) //"Edição de impostos concluída."
	FwClearHlp()	//Limpa último help executado
EndIf
If lExResh
	If aCfgNf[SAliasHead] == "SF1"
		LocXVal("F1_DOC")
	Else
		LocXVal("F2_DOC")
	EndIf
EndIf

Return(lOk)

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Estrutura do modelo MVC.

@Return oModel - Objeto do modelo MVC

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MpFormModel():New( "FISA084", { |oModel| FVldModel( oModel ) },, { |oModel| FCommit( oModel ) } )
Local oStruTRB  := FStrModel( "TRB" , "Documento Fiscal" )
Local oStruTRB1 := FStrModel( "TRB1", "Impostos do Documento Fiscal" )
Local oStruTRB2 := FStrModel( "TRB2", "Itens do Documento Fiscal" )
Local bLoadTRB  := { || FLoadField() }
Local bLoadTRB1 := { || FLoadGrid1() }
Local bLoadTRB2 := { |oGrid| FLoadGrid2( oGrid ) }
Local bVldTRB1  := { |oGrid, nLine, cAction, cIDField, xValue, xCurrentValue| FVldGrid1( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue ) }
Local bVldTRB2  := { |oGrid, nLine, cAction, cIDField, xValue, xCurrentValue| FVldGrid2( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue ) }

oModel:AddFields( "MODEL_TRB",, oStruTRB,,, bLoadTRB )
oModel:GetModel( "MODEL_TRB" ):SetOnlyView()

oModel:AddGrid( "MODEL_TRB1", "MODEL_TRB", oStruTRB1, bVldTRB1,,,, bLoadTRB1 )
oModel:GetModel( "MODEL_TRB1" ):SetOptional( .T. )
oModel:GetModel( "MODEL_TRB1" ):SetUniqueLine( { "TRB1_IMPOSTO" } )

oModel:AddGrid( "MODEL_TRB2", "MODEL_TRB1", oStruTRB2, bVldTRB2,,,, bLoadTRB2 )
oModel:GetModel( "MODEL_TRB2" ):SetNoInsertLine()
oModel:GetModel( "MODEL_TRB2" ):SetNoDeleteLine()
oModel:GetModel( "MODEL_TRB2" ):SetOptional( .T. )
oModel:GetModel( "MODEL_TRB2" ):SetUniqueLine( { "TRB2_ITEM" } )

oModel:SetRelation( "MODEL_TRB1", { { "TRB1_DOC", "TRB_DOC"  }, { "TRB1_SERIE", "TRB_SERIE"  } }, "1" )
oModel:SetRelation( "MODEL_TRB2", { { "TRB2_DOC", "TRB1_DOC" }, { "TRB2_SERIE", "TRB1_SERIE" }, { "TRB2_IMPOSTO", "TRB1_IMPOSTO" } }, "1" )

oModel:GetModel( "MODEL_TRB" ):SetPrimaryKey( { "TRB_DOC", "TRB_SERIE" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} FStrModel

Cria a tabela de acordo com a estrutura do modelo MVC.

@Param cAlias     - Alias da tabela
       cDescricao - Descricao da tabela

@Return oStruct - Objeto com a estrutura da tabela para o modelo MVC

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FStrModel( cAlias, cDescricao )

Local oStruct := FwFormModelStruct():New()
Local aStruct := FGetStruct( cAlias )
Local bWhen   := Nil
Local bRelac  := Nil
Local nI      := 0
Local nPos    := 0
Local cUnico  := ""
Local lExit   := .F.

Default cDescricao := ""

If Empty( aStruct )
	lExit := .T.
EndIf

If !lExit

	nPos := aScan( aStruct[2], { |x| AllTrim( x[2] ) == "UNQ" .or. AllTrim( x[2] ) == "PK" } )

	If nPos > 0
		cUnico := aStruct[2,nPos,3]
	EndIf

	//-------------------------------------------------------------------
	// Tabela
	// [01] Alias da tabela
	// [02] Array com os campos que correspondem a primary key
	// [03] Descricao da tabela
	//-------------------------------------------------------------------
	oStruct:AddTable( cAlias, StrToKArr( cUnico, "+" ), cDescricao )

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	For nI := 1 to Len( aStruct[2] )

		oStruct:AddIndex( aStruct[2,nI,1],;	//[01] Ordem do indice
		                  aStruct[2,nI,2],;		//[02] ID
		                  aStruct[2,nI,3],;		//[03] Chave do indice
		                  aStruct[2,nI,4],;		//[04] Descricao do indice
		                  "",;					//[05] Expressao de lookUp dos campos de indice
		                  "",;					//[06] Nickname do indice
		                  .T. )					//[07] Indica se o indice pode ser utilizado pela interface
	
	Next nX

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aStruct[1] )

		bWhen  := FwBuildFeature( STRUCT_FEATURE_WHEN  , aStruct[1,nI,10] )
		bRelac := FwBuildFeature( STRUCT_FEATURE_INIPAD, aStruct[1,nI,9] )

		oStruct:AddField( aStruct[1,nI,1],;					//[01] Titulo do campo
		                  "",;									//[02] ToolTip do campo
		                  aStruct[1,nI,2],;						//[03] Campo
		                  aStruct[1,nI,6],;						//[04] Tipo do campo
		                  aStruct[1,nI,4],;						//[05] Tamanho do campo
		                  aStruct[1,nI,5],;						//[06] Decimal do campo
		                  Nil,;									//[07] Code-block de validacao do campo
		                  bWhen,;								//[08] Code-block de validacao When do campo
		                  StrToKArr( aStruct[1,nI,8], ";" ),;	//[09] Lista de valores permitido do campo
		                  .F.,;									//[10] Indica se o campo tem preenchimento obrigatorio
		                  bRelac,;								//[11] Code-block de inicializacao do campo
		                  .F.,;									//[12] Indica se trata-se de um campo chave
		                  .F.,;									//[13] Indica se o campo pode receber valor em uma operacao de update
		                  .F. )									//[14] Indica se o campo eh virtual
	Next nI

EndIf

Return( oStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Estrutura da interface MVC.

@Return oView - Objeto da interface MVC

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oView     := FwFormView():New()
Local oModel    := FwLoadModel( "FISA084" )
Local oStruTRB  := FStrView( "TRB" )
Local oStruTRB1 := FStrView( "TRB1" )
Local oStruTRB2 := FStrView( "TRB2" )

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
							Esrutura da View
-------------------------------------------------------------------------------------*/
oView:AddField( "VIEW_TRB", oStruTRB, "MODEL_TRB" )

oView:AddGrid( "VIEW_TRB1", oStruTRB1, "MODEL_TRB1" )
oView:EnableTitleView( "VIEW_TRB1", STR0003 ) //"Impostos"

oView:AddGrid( "VIEW_TRB2", oStruTRB2, "MODEL_TRB2" )
oView:EnableTitleView( "VIEW_TRB2", STR0004 ) //"Itens do Imposto: "

/*-----------------------------------------------------------------------------------
							Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Edição de Impostos"

oView:CreateHorizontalBox( "TRB" , 10, , , "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "TRB1", 45, , , "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "TRB2", 45, , , "FOLDER_PRINCIPAL", "ABA01" )

/*-----------------------------------------------------------------------------------
						Amarracao para exibicao das informacoes
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( "VIEW_TRB" , "TRB" )
oView:SetOwnerView( "VIEW_TRB1", "TRB1" )
oView:SetOwnerView( "VIEW_TRB2", "TRB2" )

/*-----------------------------------------------------------------------------------
							Remover campos da interface
-------------------------------------------------------------------------------------*/
oStruTRB1:RemoveField( "TRB1_DOC" )
oStruTRB1:RemoveField( "TRB1_SERIE" )
oStruTRB1:RemoveField( "TRB1_BASIMP2" )
oStruTRB1:RemoveField( "TRB1_PUTSYS" )

oStruTRB2:RemoveField( "TRB2_DOC" )
oStruTRB2:RemoveField( "TRB2_SERIE" )
oStruTRB2:RemoveField( "TRB2_IMPOSTO" )

/*-----------------------------------------------------------------------------------
							Manipulacoes na interface
-------------------------------------------------------------------------------------*/
//Metodo utilizado para marcar os itens deletados apos o Activate da tela, mas antes de apresenta-la ao usuario
oView:SetAfterViewActivate( { || FLoadDel( oModel ) } )

//Metodo utilizado para trocar o titulo da Grid Inferior ao navegar nos itens do Grid Superior
oView:SetViewProperty( "VIEW_TRB1", "CHANGELINE", { { || FChgLine( oView, oModel ) } } )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} FStrView

Cria a tabela de acordo com a estrutura da interface MVC.

@Param cAlias - Alias da tabela

@Return oStruct - Objeto com a estrutura da tabela para a interface MVC

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FStrView( cAlias )

Local oStruct := FwFormViewStruct():New()
Local aStruct := FGetStruct( cAlias )
Local nI      := 0
Local cGSC    := ""
Local lExit   := .F.

If Empty( aStruct )
	lExit := .T.
EndIf

If !lExit
	For nI := 1 to Len( aStruct[1] )

		cGSC := Iif( !Empty( aStruct[1,nI,8] ), Iif( aStruct[1,nI,6] == "L", "CHECK", "GET" ), "COMBO" )

		oStruct:AddField( aStruct[1,nI,2],;					//[01] Campo
		                  StrZero( nI, 2 ),;					//[02] Ordem
		                  aStruct[1,nI,1],;						//[03] Titulo
		                  aStruct[1,nI,1],;						//[04] Descricao
		                  aStruct[1,nI,12],;					//[05] Help
		                  cGSC,;								//[06] Tipo do campo Combo, Get ou Check
		                  aStruct[1,nI,3],;						//[07] Picture
		                  Nil,;									//[08] PictVar
		                  aStruct[1,nI,7],;						//[09] F3
		                  aStruct[1,nI,11],;					//[10] Editavel
		                  NIL,;									//[11] Folder
		                  NIL,;									//[12] Group
		                  StrToKArr( aStruct[1,nI,8], ";" ),;	//[13] Lista Combo
		                  0,;									//[14] Tam Max Combo
		                  NIL,;									//[15] Inic. Browse
		                  .F. )									//[16] Virtual
	Next nI
EndIf

Return( oStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetStruct

Definicao da estrutura do dicionario.

@Param cAlias - Alias da tabela

@Return aStruct - Array com a estrutura dos dicionarios:
                  [1] - Estrutura dos campos
                  [2] - Estrutura dos indices

@Author Felipe C. Seolin
@Since 10/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetStruct( cAlias )

Local aTRBCmp  := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SF1", "F1_EMISSAO" } }
Local aTRB1Cmp := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SFC", "FC_IMPOSTO" }, { "SD1", "D1_BASIMP1" }, { "SD1", "D1_BASIMP2" }, { "SD1", "D1_ALQIMP1" }, { "SD1", "D1_VALIMP1" }, { "SFC", "FC_BASE" } }
Local aTRB2Cmp := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SFC", "FC_IMPOSTO" }, { "SD1", "D1_ITEM" }, { "SD1", "D1_COD" }, { "SD1", "D1_QUANT" }, { "SD1", "D1_VUNIT" }, { "SD1", "D1_TOTAL" }, { "SD1", "D1_TES" } }
Local aStruct  := {}
Local aFields  := {}
Local aIndex   := {}
Local aHelp    := {}

Local nI       := 0
Local nPos     := 0

Local cCmp     := ""
Local cTitle   := ""
Local cF3      := ""
Local cWhen    := ""

Local lEdit    := .T.

If cAlias == "TRB"

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRBCmp )

		cTitle := AllTrim( TitSX3( aTRBCmp[nI,2] )[1] )

		cCmp := cCmp := cAlias + AllTrim( SubStr( aTRBCmp[nI,2], At( "_", aTRBCmp[nI,2] ) ) )

		If cCmp == "TRB_DOC"
			aHelp := { STR0007 } //"Documento fiscal utilizado para a edição dos impostos." 
		ElseIf cCmp == "TRB_SERIE"
			aHelp := { STR0008 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB_EMISSAO"
			aHelp := { STR0009 } //"Data de emissão do documento fiscal utilizado para a edição dos impostos."
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;														//[02] Campo
		                  PesqPict( aTRBCmp[nI,1], aTRBCmp[nI,2] ),;					//[03] Picture
		                  TamSX3( aTRBCmp[nI,2] )[1] + TamSX3( aTRBCmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRBCmp[nI,2] )[2],;									//[05] Decimal do campo
		                  TamSX3( aTRBCmp[nI,2] )[3],;									//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}

	Next nI

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;										//[01] Ordem do indice
	                 "UNQ",;								//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;										//[01] Ordem do indice
	                 "1",;									//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] } )	//[04] Descricao do indice

ElseIf cAlias == "TRB1"

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRB1Cmp )

		If ( nPos := At( "1", TitSX3( aTRB1Cmp[nI,2] )[1] ) - 1 ) > 0
			cTitle := AllTrim( SubStr( TitSX3( aTRB1Cmp[nI,2] )[1], 1, nPos ) )
		Else
			cTitle := AllTrim( TitSX3( aTRB1Cmp[nI,2] )[1] )
		EndIf

		cCmp := cAlias + StrTran( AllTrim( SubStr( aTRB1Cmp[nI,2], At( "_", aTRB1Cmp[nI,2] ) ) ), "1", "" )

		If cCmp == "TRB1_DOC"
			aHelp := { STR0007 } //"Documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB1_SERIE"
			aHelp := { STR0008 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB1_IMPOSTO"
			aHelp := { STR0010 } //"Código identificador do imposto."
			cF3   := "SFBFIL"
			cWhen := "FwFldGet('TRB1_PUTSYS') == '2'"
		ElseIf cCmp == "TRB1_BASIMP"
			aHelp := { STR0011 } //"Valor de base de cálculo do imposto."
			cWhen := "FwFldGet('TRB1_PUTSYS') == '2'"
		ElseIf cCmp == "TRB1_BASIMP2"
			aHelp := { STR0012 } //"Valor original de base de cálculo do imposto."
		ElseIf cCmp == "TRB1_ALQIMP"
			aHelp := { STR0013 } //"Valor percentual de alíquota do imposto."
		ElseIf cCmp == "TRB1_VALIMP"
			aHelp := { STR0014 } //"Valor do imposto."
		ElseIf cCmp == "TRB1_BASE"
			aHelp := { STR0015 } //"Valor adicional de percentual de redução de base de cálculo do imposto."
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;				  										//[02] Campo
		                  PesqPict( aTRB1Cmp[nI,1], aTRB1Cmp[nI,2] ),;					//[03] Picture
		                  TamSX3( aTRB1Cmp[nI,2] )[1] + TamSX3( aTRB1Cmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRB1Cmp[nI,2] )[2],;								//[05] Decimal do campo
		                  TamSX3( aTRB1Cmp[nI,2] )[3],;								//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}
		cF3   := ""
		cWhen := ""

	Next nI

	aHelp := { STR0016 } //"Identifica se o imposto foi previamente calculado no documento fiscal."

	aAdd( aFields, { "Imp. Sistema",;	//[01] Titulo do campo
	                  "TRB1_PUTSYS",;	//[02] Campo
	                  "@!",;			//[03] Picture
	                  1,;				//[04] Tamanho do campo
	                  0,;				//[05] Decimal do campo
	                  "C",;				//[06] Tipo do campo
	                  "",;				//[07] F3
	                  "1=Sim;2=Não",;	//[08] Lista de Combo
	                  "2",;				//[09] Inicializacao do Campo
	                  cWhen,;			//[10] When
	                  lEdit,;			//[11] Editavel
	                  aHelp } )			//[12] Help

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;																//[01] Ordem do indice
	                 "UNQ",;														//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2],;		//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;																//[01] Ordem do indice
	                 "1",;															//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2],;		//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 2,;					//[01] Ordem do indice
	                 "2",;				//[02] ID
	                 aFields[3,2],;		//[03] Chave do indice
	                 aFields[3,1] } )	//[04] Descricao do indice

ElseIf cAlias == "TRB2"

	aHelp := { STR0017 } //"Indica se o item será utilizado para o cálculo do imposto."

	aAdd( aFields, { "",;			//[01] Titulo do campo
	                  "TRB2_OK",;	//[02] Campo
	                  "",;			//[03] Picture
	                  1,;			//[04] Tamanho do campo
	                  0,;			//[05] Decimal do campo
	                  "L",;			//[06] Tipo do campo
	                  "",;			//[07] F3
	                  "",;			//[08] Lista de Combo
	                  "",;			//[09] Inicializacao do Campo
	                  cWhen,;		//[10] When
	                  lEdit,;		//[11] Editavel
	                  aHelp } )		//[12] Help

	lEdit := .F.

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRB2Cmp )

		cTitle := AllTrim( TitSX3( aTRB2Cmp[nI,2] )[1] )

		cCmp := cAlias + StrTran( AllTrim( SubStr( aTRB2Cmp[nI,2], At( "_", aTRB2Cmp[nI,2] ) ) ), "1", "" )

		If cCmp == "TRB2_DOC"
			aHelp := { STR0007 } //"Documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB2_SERIE"
			aHelp := { STR0008 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB2_IMPOSTO"
			aHelp := { STR0010 } //"Código identificador do imposto."
		ElseIf cCmp == "TRB2_ITEM"
			aHelp := { STR0018 } //"Item do documento fiscal."
		ElseIf cCmp == "TRB2_COD"
			aHelp := { STR0019 } //"Código identificador do produto."
			cF3 := "SB1"
		ElseIf cCmp == "TRB2_QUANT"
			aHelp := { STR0020 } //"Quantidade do produto."
		ElseIf cCmp == "TRB2_VUNIT"
			aHelp := { STR0021 } //"Valor unitário do produto."
		ElseIf cCmp == "TRB2_TOTAL"
			aHelp := { STR0022 } //"Valor total do produto."
		ElseIf cCmp == "TRB2_TES"
			aHelp := { STR0023 } //"Tipo de Entrada/Saída para o produto."
			cF3 := "SF4"
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;														//[02] Campo
		                  PesqPict( aTRB2Cmp[nI,1], aTRB2Cmp[nI,2] ),;			  		//[03] Picture
		                  TamSX3( aTRB2Cmp[nI,2] )[1] + TamSX3( aTRB2Cmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRB2Cmp[nI,2] )[2],;								//[05] Decimal do campo
		                  TamSX3( aTRB2Cmp[nI,2] )[3],;								//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}
		cF3   := ""

	Next nI

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;																					//[01] Ordem do indice
	                 "UNQ",;																			//[02] ID
	                 aFields[2,2] + "+" + aFields[3,2] + "+" + aFields[4,2] + "+" + aFields[5,2],;	//[03] Chave do indice
	                 aFields[2,1] + "+" + aFields[3,1] + "+" + aFields[4,1] + "+" + aFields[4,1]} )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;																					//[01] Ordem do indice
	                 "1",;																				//[02] ID
	                 aFields[2,2] + "+" + aFields[3,2] + "+" + aFields[4,2] + "+" + aFields[5,2],;	//[03] Chave do indice
	                 aFields[2,1] + "+" + aFields[3,1] + "+" + aFields[4,1] + "+" + aFields[5,2]} )	//[04] Descricao do indice

	aAdd( aIndex, { 2,;					//[01] Ordem do indice
	                 "2",;				//[02] ID
	                 aFields[5,2],;		//[03] Chave do indice
	                 aFields[5,1] } )	//[04] Descricao do indice

EndIf

aAdd( aStruct, aFields )
aAdd( aStruct, aIndex )

Return( aStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadField

Carrega informacoes na Field.

@Return aLoad - Array com os conteudos da Field

@Author Felipe C. Seolin
@Since 14/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadField()

Local aLoad  := {}
Local nRecno := 1

aAdd( aLoad, { cNFIscal, cSerie, dDEmissao } )
aAdd( aLoad, nRecno )

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadGrid1

Carrega informacoes na Grid Superior, que contem os impostos.

@Return aLoad - Array com os conteudos da Grid Superior, de Impostos

@Author Felipe C. Seolin
@Since 14/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadGrid1()

Local aImp       := {}
Local aLoad      := {}
Local nRecno     := 1
Local nBasImp    := 0
Local nAlqImp    := 0
Local nValImp    := 0
Local nPos       := 0
Local nI         := 0
Local nJ         := 0
Local cLvrFiscal := ""

For nI := 1 to Len( aAllImp )
	If ( nPos := aScan( oImpostos:aArray, { |x| AllTrim( x[1] ) == AllTrim( aAllImp[nI,1] ) } ) ) > 0

		cLvrFiscal := FGetLFis( aAllImp[nI,1] )

		nAlqImp := 0
		nBasImp := oImpostos:aArray[nPos,3]
		
		For nJ := 1 to Len( aItem )
			aImp := FGetImp( { aItem[nJ,nPOSTES] } )
			If aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( aAllImp[nI,1] ) } ) > 0 
				nAlqImp := MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal )
				If nAlqImp > 0
					Exit
				EndIf
			EndIf
		Next nJ

		nValImp := oImpostos:aArray[nPos,4]

		aAdd( aLoad, { nRecno, { cNFIscal, cSerie, aAllImp[nI,1], nBasImp, nBasImp, nAlqImp, nValImp, 0, "1" } } )
		nRecno ++
	EndIf
Next nI

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadGrid2

Carrega informacoes na Grid Inferior, que contem os itens.

@Param oGrid - Objeto de modelo da Grid Inferior, de Itens

@Return aLoad - Array com os conteudos da Grid Inferior, de Itens

@Author Felipe C. Seolin
@Since 14/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadGrid2( oGrid )

Local oGridOwner := oGrid:GetOwner()
Local aImp       := {}
Local aLoad      := {}
Local nLineOwner := oGridOwner:GetLine()
Local nRecno     := 1
Local nI         := 0
Local nBasImp    := 0
Local nAlqImp    := 0
Local nValImp    := 0
Local cImp       := oGridOwner:GetValue( "TRB1_IMPOSTO", nLineOwner )
Local cLvrFiscal := ""

For nI := 1 to Len( aItem )

	aImp := FGetImp( { aItem[nI,nPOSTES] } )

	If aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( cImp ) } ) > 0

		cLvrFiscal := FGetLFis( cImp )

		nBasImp := MaFisRet( nI, "IT_BASEIV" + cLvrFiscal )
		nAlqImp := MaFisRet( nI, "IT_ALIQIV" + cLvrFiscal )
		nValImp := MaFisRet( nI, "IT_VALIV" + cLvrFiscal )

		If !Empty( nBasImp + nAlqImp + nValImp )
			aAdd( aLoad, { nRecno, { .T.,;
			                          oGridOwner:GetValue( "TRB1_DOC", nLineOwner ),;
			                          oGridOwner:GetValue( "TRB1_SERIE", nLineOwner ),;
			                          oGridOwner:GetValue( "TRB1_IMPOSTO", nLineOwner ),;
			                          aItem[nI,nPOSItem],;
			                          aItem[nI,nPOSCod],;
			                          aItem[nI,nPOSQuant],;
			                          aItem[nI,nPOSVUnit],;
			                          aItem[nI,nPOSTotal],;
			                          aItem[nI,nPOSTES] } } )
			nRecno ++
		EndIf

	EndIf

Next nI

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetImp

Verifica os impostos possiveis de acordo com a amarracao com o TES.

@Param aTes - Array com os TES's

@Return aImp - Array contendo impostos, percentual de reducao de base
               e aliquota, montado de acordo com os TES's utilizados

@Author Felipe C. Seolin
@Since 18/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetImp( aTes )

Local aImp := {}
Local nI   := 0

For nI := 1 to Len( aTes )
	If SFC->( MsSeek( xFilial("SFC") + aTes[nI] ) )
		While SFC->( !Eof() ) .and. SFC->( FC_FILIAL + FC_TES ) == xFilial("SFC") + aTes[nI]
			If aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( SFC->FC_IMPOSTO ) } ) == 0
				If SFB->( MsSeek( xFilial("SFB") + SFC->FC_IMPOSTO ) )
					aAdd( aImp, { SFC->FC_IMPOSTO, SFC->FC_BASE, SFB->FB_ALIQ,SFC->FC_LIQUIDO, SFB->FB_CPOLVRO } )
				EndIf
			EndIf
			SFC->( DBSkip() )
		EndDo
	EndIf
Next nI

Return( aImp )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetLFis

Busca a posicao do Livro Fiscal do imposto utilizado.

@Param cImp - Imposto utilizado para busca do Livro Fiscal

@Return cLvrFiscal - Livro Fiscal referente ao imposto utilizado

@Author Felipe C. Seolin
@Since 18/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetLFis( cImp )

Local cLvrFiscal := ""

If SFB->( MsSeek( xFilial("SFB") + cImp ) )
	cLvrFiscal := SFB->FB_CPOLVRO
EndIf

Return( cLvrFiscal )

//---------------------------------------------------------------------
/*/{Protheus.doc} FVldGrid1

Validacao das informacoes do Grid Superior, que contem os impostos.

@Param oGrid         - Objeto de modelo da Grid Superior, de Impostos
       nLine         - Linha posicionada referente ao objeto oGrid
       cAction       - Acao tomada causadora da validacao
       cIDField      - Campo posicionado referente ao objeto oGrid
       xValue        - Valor inserido na acao
       xCurrentValue - Valor contido no atualmente no campo

@Return lRet - Informa se a acao foi validada

@Author Felipe C. Seolin
@Since 20/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FVldGrid1( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue )

Local aRmvWhen := {}
Local nBasImp  := 0
Local nAlqImp  := 0
Local nPos     := 0
Local lRet     := .T.
Local nTotCal  := 0
Local nTotCalA := 0
Local cImp	   := 0
Local cLvrFiscal := 0
Local nJ       := 0
Local nImposto := 0
Local aImp       := {}
If cAction == "SETVALUE"

	If cIDField == "TRB1_IMPOSTO"
		If ( nPos := aScan( aAllImp, { |x| AllTrim( x[1] ) == AllTrim( xValue ) } ) ) == 0
			lRet := .F.
			Help( ,, "HELP",, STR0005, 1, 0) //"O imposto selecionado não pode ser utilizado, pois não está contido na amarração com a TES."
		Else
			oGrid:SetValue( "TRB1_ALQIMP", 0 )
			oGrid:SetValue( "TRB1_VALIMP", 0 )
		EndIf

	ElseIf cIDField == "TRB1_BASIMP"
		nAlqImp := oGrid:GetValue( "TRB1_ALQIMP", nLine )
		oGrid:SetValue( "TRB1_VALIMP", xValue * ( nAlqImp / 100) )

	ElseIf cIDField == "TRB1_ALQIMP"
		nBasImp := oGrid:GetValue( "TRB1_BASIMP", nLine )
		cImp := oGrid:GetValue( "TRB1_IMPOSTO", nLine )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImp} )
	    cLvrFiscal := FGetLFis( cImp )
		If !Empty(cLvrFiscal)
			For nJ := 1 to Len( aItem )
				aImp := FGetImp( { aItem[nJ,nPOSTES] } )
				If !aItem[nJ,Len( aItem[nJ] )] .And. aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( cImp ) } ) > 0 .And. aItem[nJ][nPOSTotal] > 0 .And. MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal ) > 0 
					nAlqImp := MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal )
					Exit
				EndIf
			Next nJ
		EndIf
		nTotCal	:= nBasImp*(nAlqImp)/100
		nTotCalA := nBasImp*(xValue)/100
		IF cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. nImposto > 0 .and. SFB->FB_PERCALT <> 999999.99)
			If !(ABS(nTotCalA- nTotCal) <= (nTotCal * (SFB->FB_PERCALT/100)) ) .Or. !(ABS(nTotCalA - nTotCal) <= SFB->FB_VLRALT)
				oGrid:LoadValue("TRB1_ALQIMP",nAlqImp)
				oGrid:LoadValue("TRB1_VALIMP",nTotCal)
				Help(, , "HELP", , STR0026, 1, 0) //STR0026: "El valor modificado es superior al valor máximo permitido"
				lRet  := .F.
			ElseIf xValue > 100 .Or. xValue < 0
				Help(, , "HELP", , STR0025, 1, 0) //STR0025: "La alicuota debe estar entre 0 y 100."
				lRet := .F.
			Else
				oGrid:LoadValue( "TRB1_VALIMP", nBasImp * ( xValue / 100))
			EndIf
		ElseIf xValue > 100 .Or. xValue < 0
			Help(, , "HELP", , STR0025, 1, 0) //STR0025: "La alicuota debe estar entre 0 y 100."
			lRet := .F.
		Else
			oGrid:LoadValue( "TRB1_VALIMP", nBasImp * ( xValue / 100))
		EndIf

	ElseIf cIDField == "TRB1_BASE"
		nAlqImp := oGrid:GetValue( "TRB1_ALQIMP", nLine )
		nBasImp := oGrid:GetValue( "TRB1_BASIMP2", nLine )
		If !oGrid:CanSetValue( "TRB1_BASIMP" )
			aRmvWhen := FRmvWhen( oGrid, "TRB1_BASIMP" )
		EndIf

		oGrid:SetValue( "TRB1_BASIMP", nBasImp - ( nBasImp * ( xValue / 100) ) )
		oGrid:SetValue( "TRB1_VALIMP", nBasImp * ( nAlqImp / 100) )
			
		If !Empty( aRmvWhen )
			oGrid:oFormModelStruct:aFields[aRmvWhen[2],MODEL_FIELD_WHEN] := aRmvWhen[1]
		EndIf
		
	ElseIf cIDField == "TRB1_VALIMP"
		nBasImp := oGrid:GetValue( "TRB1_BASIMP", nLine )
	    cImp := oGrid:GetValue( "TRB1_IMPOSTO", nLine )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImp} )
	    cLvrFiscal := FGetLFis( cImp )
		If !Empty(cLvrFiscal)
			For nJ := 1 to Len( aItem )
				aImp := FGetImp( { aItem[nJ,nPOSTES] } )
				If !aItem[nJ,Len( aItem[nJ] )] .And. aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( cImp ) } ) > 0 .And. aItem[nJ][nPOSTotal] > 0 .and. MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal ) > 0
					nAlqImp := MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal )
					Exit
				EndIf
			Next nJ
		EndIf
		nTotCal	:= nBasImp*(nAlqImp)/100
		IF cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. nImposto > 0 .and. SFB->FB_PERCALT <> 999999.99)
			If !(ABS(xValue - nTotCal) <= (nTotCal * (SFB->FB_PERCALT/100)) ) .Or. !(ABS(xValue - nTotCal) <= SFB->FB_VLRALT)
				oGrid:LoadValue("TRB1_ALQIMP",nAlqImp)
				oGrid:LoadValue("TRB1_VALIMP",nTotCal)
				Help(, , "HELP", , STR0026, 1, 0)//STR0026:"El valor modificado es superior al valor máximo permitido"
				lRet := .F. 
				
			ElseIf xValue > nBasImp .Or. xValue < 0
				Help(, , "HELP", , STR0024, 1, 0) //STR0024: "El valor imponible debe estar entre 0 y la base imponible."
				lRet := .F. 
			Else
				oGrid:LoadValue("TRB1_ALQIMP", (xValue * 100) / nBasImp)
			EndIf 
		ElseIf xValue > nBasImp .Or. xValue < 0
			Help(, , "HELP", , STR0024, 1, 0) //STR0024: "El valor imponible debe estar entre 0 y la base imponible."
			lRet := .F. 
		Else
			oGrid:LoadValue("TRB1_ALQIMP", (xValue * 100) / nBasImp)
		EndIF
	EndIf

ElseIf cAction == "DELETE"

	If oGrid:GetValue( "TRB1_PUTSYS", nLine ) == "1"
		lRet := .F.
		Help( ,, "HELP",, STR0006, 1, 0) //"Impostos previamente calculados no documento não podem ser excluídos."
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FVldGrid2

Validacao das informacoes do Grid Inferior, que contem os itens.

@Param oGrid         - Objeto de modelo da Grid Inferior, de Itens
       nLine         - Linha posicionada referente ao objeto oGrid
       cAction       - Acao tomada causadora da validacao
       cIDField      - Campo posicionado referente ao objeto oGrid
       xValue        - Valor inserido na acao
       xCurrentValue - Valor contido no atualmente no campo

@Return lRet - Informa se a acao foi validada

@Author Felipe C. Seolin
@Since 26/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FVldGrid2( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue )

Local oGridOwner := Nil
Local aRmvWhen   := {}
Local nLineOwner := 0
Local nBasImp    := 0
Local nBasImp2   := 0
Local nBasOri    := 0
Local nRedBase   := 0
Local lRet       := .T.

If cAction == "SETVALUE"

	If cIDField == "TRB2_OK" .and. !(IsInCallStack("FLOADDEL"))
		oGridOwner := oGrid:GetOwner()
		nLineOwner := oGridOwner:GetLine()

		If cPaisLoc == "ARG"
			nBasImp2 := oGridOwner:GetValue( "TRB1_BASIMP", nLineOwner )
		Else
			nBasImp2 := oGridOwner:GetValue( "TRB1_BASIMP2", nLineOwner )
		EndIf
		nRedBase := oGridOwner:GetValue( "TRB1_BASE"   , nLineOwner )

		If !oGridOwner:CanSetValue( "TRB1_BASIMP" )
			aRmvWhen := FRmvWhen( oGridOwner, "TRB1_BASIMP")
		EndIf

		If xValue
			nBasOri := nBasImp2 + oGrid:GetValue( "TRB2_TOTAL", nLine )
			nBasImp := nBasOri
			IF cPaisLoc=='ARG'
				nBasImp:=fDescuent(oGridOwner:GetValue( "TRB1_IMPOSTO", nLineOwner ), nBasImp, oGrid:GetValue( "TRB2_TOTAL", nLine ), aCfgNf[SAliasHead])
			ENDIF
		Else
			nBasOri := nBasImp2 - oGrid:GetValue( "TRB2_TOTAL", nLine )
			nBasImp := nBasOri
		EndIf

		If !Empty( nRedBase )
			nBasImp := nBasOri - ( nBasOri * ( nRedBase / 100 ) )
		EndIf
	
		oGridOwner:LoadValue( "TRB1_BASIMP", nBasImp)
		oGridOwner:SetValue( "TRB1_BASIMP" , nBasImp) 
		oGridOwner:SetValue( "TRB1_BASIMP2", nBasOri )

		If !Empty( aRmvWhen )
			oGridOwner:oFormModelStruct:aFields[aRmvWhen[2],MODEL_FIELD_WHEN] := aRmvWhen[1]
		EndIf

	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FRmvWhen

Utilizado para remover o conteudo do When do campo para permitir que
seja inserido valores calculados automaticamente.

@Param oObj - Objeto onde se encontra o campo a ser manipulado
       cCmp - Campo a ser manipulado

@Return aRet - Array com o conteudo a ser reposto no objeto:
               [1] - Conteudo do When do campo manipulado
               [2] - Identificador do campo na estrutura do objeto

@Author Felipe C. Seolin
@Since 05/03/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FRmvWhen( oObj, cCmp )

Local aStruct  := {}
Local aRet     := {}
Local bWhen    := Nil
Local nIdField := 0

aStruct := oObj:oFormModelStruct:GetFields()
nIdField := aScan( aStruct, { |x| AllTrim( x[MODEL_FIELD_IDFIELD] ) == cCmp } )
bWhen := oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN]
oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN] := Nil

aRet := { bWhen, nIdField }

Return( aRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FVldModel

Validacao das informacoes do modelo MVC.

@Param oModel - Objeto do modelo MVC

@Return lRet - Informa se a acao foi validada

@Author Felipe C. Seolin
@Since 10/03/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FVldModel( oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local aRmvWhen   := {}
Local nPos       := 0
Local cImp       := ""
Local lExec      := .F.
Local lRet       := .T.

lConPad := Iif( Type( "lConPad" ) == "U", .F., lConPad )

If ReadVar() == "M->TRB1_IMPOSTO"
	If oModelTRB1:IsFieldUpdated( "TRB1_IMPOSTO" )
		If FwFldGet( "TRB1_IMPOSTO" ) <> oModelTRB1:GetValue( "TRB1_IMPOSTO", oModelTRB1:GetLine() )
			lExec := .T.
		EndIf
	Else
		If ( oModelTRB1:IsInserted() .and. !Empty( FwFldGet( "TRB1_IMPOSTO" ) ) )
			lExec := .T.
		EndIf
	EndIf
EndIf

If lExec .or. lConPad
	cImp := IIf( !lConPad, FwFldGet( "TRB1_IMPOSTO" ), SFB->FB_CODIGO )

	If ( nPos := aScan( aAllImp, { |x| AllTrim( x[1] ) == AllTrim( cImp ) } ) ) > 0

		If !oModelTRB1:CanSetValue( "TRB1_BASIMP" )
			aRmvWhen := FRmvWhen( oModelTRB1, "TRB1_BASIMP" )
		EndIf

		oModelTRB1:SetValue( "TRB1_BASIMP", 0 )
		If cPaisLoc == "ARG"
			oModelTRB1:LoadValue( "TRB1_IMPOSTO", cImp )
		EndIf

		If !Empty( aRmvWhen )
			oModelTRB1:oFormModelStruct:aFields[aRmvWhen[2],MODEL_FIELD_WHEN] := aRmvWhen[1]
		EndIf

		FFillGrid2( oModelTRB2, cImp )
		oModelTRB1:SetValue( "TRB1_BASIMP2", oModelTRB1:GetValue( "TRB1_BASIMP", oModelTRB1:GetLine() ) )
		oModelTRB1:SetValue( "TRB1_ALQIMP", aAllImp[nPos,3] )
		oModelTRB1:LoadValue( "TRB1_BASE", 0 )
	EndIf
EndIf

If lConPad
	lConPad := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FFillGrid2

Carrega informacoes no Grid Inferior, que contem os itens, apos a acao
de manipular o imposto no Grid Superior, que contem os impostos.

@Param oGrid - Objeto de modelo da Grid Inferior, de Itens
       cImp  - Imposto inserido causador da acao

@Author Felipe C. Seolin
@Since 25/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FFillGrid2( oGrid, cImp )

Local oGridOwner := oGrid:GetOwner()
Local aImp       := {}
Local nLineOwner := oGridOwner:GetLine()
Local nItem      := 0
Local nI         := 0

For nI := 1 to oGrid:Length()
	oGrid:GoLine( nI )
	oGrid:DeleteLine( .T., .T. )
Next nI

oGrid:UnDeleteLine()

For nI := 1 to Len( aItem )

	aImp := FGetImp( { aItem[nI,nPOSTES] } )

	If aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( cImp ) } ) > 0

		nItem ++

		If nItem > 1
			oGrid:AddLine( .T. )
		EndIf

		oGrid:SetValue( "TRB2_DOC"    , oGridOwner:GetValue( "TRB1_DOC"    , nLineOwner ) )//Ao inserir linha ainda nao existe
		oGrid:SetValue( "TRB2_SERIE"  , oGridOwner:GetValue( "TRB1_SERIE"  , nLineOwner ) )//Ao inserir linha ainda nao existe
		oGrid:SetValue( "TRB2_IMPOSTO", oGridOwner:GetValue( "TRB1_IMPOSTO", nLineOwner ) )//Ao inserir linha ainda nao existe
		oGrid:SetValue( "TRB2_ITEM"   , aItem[nI,nPOSItem] )
		oGrid:SetValue( "TRB2_COD"    , aItem[nI,nPOSCod] )
		oGrid:SetValue( "TRB2_QUANT"  , aItem[nI,nPOSQuant] )
		oGrid:SetValue( "TRB2_VUNIT"  , aItem[nI,nPOSVUnit] )
		oGrid:SetValue( "TRB2_TOTAL"  , aItem[nI,nPOSTotal] )
		oGrid:SetValue( "TRB2_TES"    , aItem[nI,nPOSTES] )

		//Ultimo a ser atualizado para que a Grid ja contenha valores no momento da Validacao do campo
		If aItem[nI,Len( aItem[nI] )]
			oGrid:DeleteLine( , .T. )
			oGrid:SetValue( "TRB2_OK", .F. )
		Else
			oGrid:SetValue( "TRB2_OK"     , .T. )
		EndIf

	EndIf

Next nI

oGrid:GoLine( 1 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FCommit

Realiza a manipulacao de informacoes na MatXFis.

@Param oModel - Objeto do modelo MVC

@Return lRet - Informa se a operacao foi realizada

@Author Felipe C. Seolin
@Since 06/03/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FCommit( oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local aBasRat    := {}
Local nI         := 0
Local nJ         := 0
Local nItem      := 0
Local nBasImp    := 0
Local nAlqImp    := 0
Local nValImp    := 0
Local cLvrFiscal := ""
Local lRet       := .T.
Local cImposto   := ""
Local nImposto   := 0
Local cDupTes    := ""
Local nValorI    :=0
Local nValor    :=0
Local nVlTotNf  := 0
Local nValimp1	:= 0
Local nPosImp    := 0
Local nValAcum	 := 0
Local nValAntImp:=0
Local nValAntTo:=0



For nI := 1 to oModelTRB1:Length()

	nValAcum := 0
	oModelTRB1:GoLine( nI )

	If !oModelTRB1:IsDeleted() .and. !Empty( oModelTRB1:GetValue( "TRB1_IMPOSTO", nI ) )

		cImposto := oModelTRB1:GetValue( "TRB1_IMPOSTO", nI )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImposto} )

		If nImposto > 0 .And. oModelTRB1:GetValue( "TRB1_BASIMP", nI ) == oImpostos:aArray[nImposto,3] .And. oModelTRB1:GetValue( "TRB1_VALIMP", nI ) == oImpostos:aArray[nImposto,4]
			// Impuesto pre-existente, mismos valores ==> No recalcular 
			Loop
		Endif

		cLvrFiscal := FGetLFis( oModelTRB1:GetValue( "TRB1_IMPOSTO", nI ) )
		If cPaisLoc $ "ARG|COL|MEX|PAR"
			nPosImp := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VALIMP"+cLvrFiscal } )
		EndIf
		IF nImposto > 0 .and. cPaisLoc == "ARG"
			aBasRat := FRateio( oModelTRB2, "IT_BASEIV" + cLvrFiscal, oImpostos:aArray[nImposto,3], IIf( oModelTRB1:GetValue( "TRB1_PUTSYS", nI ) == "2", .T., .F. ) )
		Else
			aBasRat := FRateio( oModelTRB2, "IT_BASEIV" + cLvrFiscal, oModelTRB1:GetValue( "TRB1_BASIMP", nI ), IIf( oModelTRB1:GetValue( "TRB1_PUTSYS", nI ) == "2", .T., .F. ) )
		EndIf
		For nJ := 1 to Len( aBasRat )
			IF cPaisLoc == "URU"
				cDupTes := Posicione("SF4",1,xFilial("SF4")+aItem[nJ,nPOSTES],"F4_DUPLIC")

				If(cDupTes $ ("S|N"))// se verifica configuracion de la TES
					nItem   := aScan( aItem, { |x| AllTrim( x[nPOSItem] ) == AllTrim( oModelTRB2:GetValue( "TRB2_ITEM", nJ ) ) } )
					DbSelectArea("SFC")
					SFC->(dbSetOrder(2))
					If SFC->(MsSeek(xFilial("SFC") + MaFisRet(nItem,"IT_TES") + cImposto))
				
						If aBasRat[nJ] > 0
							nBasImp := aBasRat[nJ]
							nAlqImp := IIf( nBasImp == 0, 0, oModelTRB1:GetValue( "TRB1_ALQIMP", nI ) )
							nValImp := oModelTRB1:GetValue( "TRB1_VALIMP", nI ) // valor editado
				
							If ( SFC->FC_INCDUPL $("1|2") .or. SFC->FC_INCNOTA $("1|2") )
								If !Empty(SFC->FC_INCDUPL) .And. cDupTes == "S" // titulo
									
									If SFC->FC_INCDUPL == '1'//suma
										nValor:= MaFisRet( ,"NF_BASEDUP" ) - MaFisRet(nItem, "IT_VALIV" + cLvrFiscal ) 
										MaFisAlt('NF_BASEDUP',(nValor + nValImp))
									ElseIf SFC->FC_INCDUPL == '2'//resta
										nValor:= MaFisRet( ,"NF_BASEDUP" ) + MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
										MaFisAlt('NF_BASEDUP',(nValor - nValImp))
									EndIf
								EndIf

								If !Empty(SFC->FC_INCNOTA)//factura
									
									If SFC->FC_INCNOTA == '1' //suma 
										nValorI:= MaFisRet(nItem,"IT_TOTAL" ) - MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
										MaFisAlt("IT_TOTAL",(nValorI + nValImp), nItem,,,,, .F. )
									ElseIf SFC->FC_INCNOTA == '2'//resta
										nValorI:= MaFisRet(nItem,"IT_TOTAL" ) + MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
										MaFisAlt("IT_TOTAL",(nValorI - nValImp), nItem,,,,, .F. )
									EndIf
								EndIf
							EndIf

							MaFisAlt( "IT_BASEIV" + cLvrFiscal, nBasImp, nItem,,,,, .F. )
							MaFisAlt( "IT_ALIQIV" + cLvrFiscal, nAlqImp, nItem,,,,, .F. )
							nValimp1:= Round(nBasImp* (nAlqImp/100),2)
							MaFisAlt( "IT_VALIV" + cLvrFiscal , nValimp1, nItem,,,,, .F. )

						EndIf
						SFC->(DbCloseArea())
					EndIf
				EndIf
			Else
				If aBasRat[nJ] > 0
					nItem   := aScan( aItem, { |x| AllTrim( x[nPOSItem] ) == AllTrim( oModelTRB2:GetValue( "TRB2_ITEM", nJ ) ) } )
					nBasImp := aBasRat[nJ]
					nAlqImp := IIf( nBasImp == 0, 0, Round(oModelTRB1:GetValue( "TRB1_ALQIMP", nI ),2) )
					nValImp := oModelTRB1:GetValue( "TRB1_VALIMP", nI )//valor nuevo impuesto
					nValAntImp:=MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )//valor anterior impuesto

					IF (nValImp!=MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )).OR. (nValImp!=oImpostos:aArray[nItem,4])
					
						nValAntTo:=MaFisRet(nItem,"IT_TOTAL" ) //valor anterior total
						nValorI:=getValAct(nValAntImp,nValAntTo,aItem[nItem,nPOSTES],"NO",oModelTRB1:GetValue( "TRB1_IMPOSTO", nI ),nBasImp)
						MaFisAlt("IT_TOTAL", nvalorI, nItem,,,,, .F. )

						nValAntTo:= MaFisRet( ,"NF_BASEDUP" ) //valor anterior titulo
						nValorI:=getValAct(nValAntImp,nValAntTo,aItem[nItem,nPOSTES],"DU",oModelTRB1:GetValue( "TRB1_IMPOSTO", nI ),nBasImp)

					ENDIF
						
					MaFisAlt( "IT_BASEIV" + cLvrFiscal, nBasImp, nItem,,,,, .F. )
					MaFisAlt( "IT_ALIQIV" + cLvrFiscal, nAlqImp, nItem,,,,, .F. )
					If nJ == Len(aBasRat) 
						nValimp1 := nValImp - nValAcum
					Else
						nValimp1 := Round(nBasImp* (nAlqImp/100),2)
						nValAcum += nValimp1
					EndIf
					MaFisAlt( "IT_VALIV" + cLvrFiscal , nValimp1, nItem,,,,, .F. )
					
					cDupTes := Posicione("SF4",1,xFilial("SF4")+aItem[nItem,nPOSTES],"F4_DUPLIC")

					If(cDupTes == "S" .and. !Empty(cDupTes))

						DbSelectArea("SFC")
						SFC->(dbSetOrder(2))
						If SFC->(MsSeek(xFilial("SFC") + MaFisRet(nItem,"IT_TES") + cImposto)) //FC_FILIAL+FC_TES+FC_IMPOSTO
							If !Empty(SFC->FC_INCDUPL)
							
							If SFC->FC_INCDUPL == '2' 								
									nValor:=MaFisRet( nItem,"IT_BASEDUP" ) - MaFisRet( nItem,"IT_VALIV" + cLvrFiscal ) + nValAntImp
									MaFisAlt("IT_BASEDUP", nValor, nItem,,,,, .F. )
								ElseIf SFC->FC_INCDUPL == '1'
										nValor:=MaFisRet( nItem,"IT_BASEDUP" ) + MaFisRet( nItem,"IT_VALIV" + cLvrFiscal ) - nValAntImp
										IF MaFisRet(nItem,"IT_BASEDUP" ) != nValor
											MaFisAlt("IT_BASEDUP", nValor, nItem,,,,, .F. )
										ENDIF
								EndIf
							EndIf
							If !Empty(SFC->FC_INCNOTA)
								If SFC->FC_INCNOTA == '2' 
									nvalorI:= MaFisRet(nItem,"IT_TOTAL" ) - MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
									MaFisAlt("IT_TOTAL", nvalorI, nItem,,,,, .F. )
								ElseIf SFC->FC_INCNOTA == '1'
									nvalorI:= MaFisRet(nItem,"IT_TOTAL" ) + MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
									MaFisAlt("IT_TOTAL", nvalorI, nItem,,,,, .F. )
								EndIf
							EndIf
						EndIf
						SFC->(DbCloseArea())
					Else
						If cPaisLoc == "ARG"
							DbSelectArea("SFC")
							SFC->(dbSetOrder(2))
							If SFC->(MsSeek(xFilial("SFC") + MaFisRet(nItem,"IT_TES") + cImposto)) //FC_FILIAL+FC_TES+FC_IMPOSTO
								If !Empty(SFC->FC_INCNOTA)
									If SFC->FC_INCNOTA == '2' 
										nvalorI:= MaFisRet(nItem,"IT_TOTAL" ) - MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
										MaFisAlt("IT_TOTAL", nvalorI, nItem,,,,, .F. )
									ElseIf SFC->FC_INCNOTA == '1'
										nvalorI:= MaFisRet(nItem,"IT_TOTAL" ) + MaFisRet(nItem, "IT_VALIV" + cLvrFiscal )
										MaFisAlt("IT_TOTAL", nvalorI, nItem,,,,, .F. )
									EndIf
								EndIf
							EndIf
							SFC->(DbCloseArea())
						Else
							nVlTotNf  := MaFisRet( ,"NF_TOTAL" ) 
							MaFisLoad("NF_TOTAL",nVlTotNf + nValImp)
						EndIf
					EndIf
				EndIf		
			EndIf
		Next nJ
		If cPaisLoc == "ARG"
			MaFisToCols(aHeader,aCols,,"MT100")
		EndIf
	EndIf
Next nI
Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FRateio

Calcula a base do imposto rateada de acordo com o valor da base do
imposto anterior.

@Param oGrid       - Objeto de modelo da Grid Inferior, de Itens
       cReferencia - Referencia do imposto na MatXFis
       nAtual      - Valor atual do total da base do imposto de referencia
       lIncManu    - Informa se o imposto do Grid Superior foi inserido
                     manualmente. Utilizado para saber se existe referencia
                     alimentada do imposto na MatXFis

@Return aBasRat - Array contendo os valores da base do imposto rateados de
                  acordo com a base anterior

@Author Felipe C. Seolin
@Since 07/03/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FRateio( oGrid, cReferencia, nAtual, lIncManu )

Local aBasRat  := {}
Local nTotAcum := 0
Local nAuxItem := 0
Local nVlrTot  := 0
Local nFator   := 0
Local nBasImp  := 0
Local nI       := 0
Local nNumTRB  := 0 
Local lAuxItem := .T.

For nI := 1 to oGrid:Length()
	If !oGrid:IsDeleted( nI )
		If lIncManu
			nVlrTot += oGrid:GetValue( "TRB2_TOTAL", nI )
		Else
			nNumTRB :=  val(oGrid:GetValue( "TRB2_ITEM", nI )) 
			nVlrTot += MaFisRet( nNumTRB, cReferencia )
		EndIf
	EndIf
Next nI

For nI := 1 to oGrid:Length()

	If !oGrid:IsDeleted( nI ) .and. oGrid:GetValue( "TRB2_OK", nI )

		If nAtual <> 0 .and. nAtual == nTotAcum .and. cPaisLoc == "BRA"
			Exit
		EndIf
		
		If lIncManu
			nFator := oGrid:GetValue( "TRB2_TOTAL", nI ) / nVlrTot
		Else
			nNumTRB :=  val(oGrid:GetValue( "TRB2_ITEM", nI )) 
			nFator := MaFisRet( nNumTRB, cReferencia ) / nVlrTot
		EndIf

		If lAuxItem
			nAuxItem := nI
			lAuxItem := .F.
		EndIf

		nBasImp := NoRound( nFator * nAtual, 2 )
		aAdd( aBasRat, nBasImp )
		nTotAcum += nBasImp
	Else
		aAdd( aBasRat, 0 )
	EndIf

Next nI

If !lAuxItem .and. nAtual <> nTotAcum
	aBasRat[nAuxItem] += nAtual - nTotAcum
EndIf

Return( aBasRat )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadDel

Manipulacoes executadas antes da apresentacao da tela.

@Param oModel - Objeto do modelo MVC

@author Felipe C. Seolin
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadDel( oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local nI         := 0
Local nJ         := 0
Local nPos       := 0

For nI := 1 to oModelTRB1:Length()
	oModelTRB1:GoLine( nI )

	For nJ := 1 to oModelTRB2:Length()
		If ( nPos := aScan( aItem, { |x| AllTrim( x[nPOSItem] ) == AllTrim( oModelTRB2:GetValue( "TRB2_ITEM", nJ ) ) } ) ) > 0
			If aItem[nPos,Len( aItem[nPos] )]
				oModelTRB2:GoLine( nJ )
				oModelTRB2:SetValue( "TRB2_OK", .F. )
				oModelTRB2:DeleteLine( , .T. )
			EndIf
		EndIf
	Next nJ

	oModelTRB2:GoLine( 1 )

Next nI

oModelTRB1:GoLine( 1 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FChgLine

Manipulacoes na troca de linha do Grid Superior.

@Param oView   - Objeto da interface MVC
       oModel  - Objeto do modelo MVC

@author Felipe C. Seolin
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FChgLine( oView, oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local cImp       := oModelTRB1:GetValue( "TRB1_IMPOSTO", oModelTRB1:GetLine() )

oView:EnableTitleView( "VIEW_TRB2", STR0004 + cImp ) //"Itens do Imposto: "
oView:aViews[3,3]:cTitle := STR0004 + cImp //"Itens do Imposto: "

oModelTRB2:GoLine( 1 )

oView:Refresh( "MODEL_TRB2" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FIniAlias

Inicializa Area de Trabalho utilizadas.

@Author Felipe C. Seolin
@Since 18/02/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FIniAlias()

DBSelectArea( "SFC" )
SFC->( DBSetOrder(1) )

DBSelectArea( "SFB" )
SFB->( DBSetOrder(1) )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} xFilter084

Filtro da consulta padrao SFBFIL para edicao de impostos totalizados.

@author Felipe C. Seolin
@since 12/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function xFilter084()

Local nI   := 0
Local cImp := ""

If Type( "lConPad" ) <> "U"
	lConPad := .T.
EndIf

For nI := 1 to Len( aAllImp )
	cImp += aAllImp[nI,1] + "|"
Next nI

cRet := "@#FB_CODIGO $ '" + cImp + "'@#"

Return( cRet )

/*/{Protheus.doc} fDescuent
    Verifica si la base imponible debe llevar descuento de acuerdo
    al campo FC_LIQUIDO DE LA TES
    @type  Function
    @author adrian.perez
    @since 19/05/2023
    @param cImp, carácter , Impuesto a verificar en el arreglo aAllImp que contine la TES
    @param nBasImp, numérico , Base del impuesto
    @param nLnTotal, numérico , Total de la línea   
    @return nBasImp, numérico, Base del impuesto con o sin descuento de acuerdo a la validación.
    /*/

Function fDescuent(cImp,nBasImp,nLnTotal,cAlias)

	Local nPosImp := 0
	Local cCal := ""
	Local nI := 0
	Local nAcuDes := 0
	Local nPosDes := 0
	Local nDES1 := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VALDESC" } )
	Local nDES2 := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_DESCON" } )
	Local aTes := {}
	Local cMvDescSai := SuperGetMV("MV_DESCSAI", .F., "2")
	Local cFunName := Funname()

	DEFAULT cImp := ""
	DEFAULT nBasImp := 0
	DEFAULT nLnTotal := 0
	Default cAlias := ""

	If cMvDescSai == "1" .And. cAlias == "SF2" .And. cFunName == "MATA466N"
		Return nBasImp
	EndIf

	If (nBasImp - nLnTotal) == 0
		If nDES1 > 0
			nPosDes := nDES1
		Else
			nPosDes := nDES2
		EndIf

		nPosImp := aScan( aAllImp, { |x| X[1] ==  cImp } )

		If (nPosImp * nPosDes) > 0
			cCal:= aAllImp[nPosImp,4]
			IF cCal == 'S'  
				For nI := 1 to Len( aItem )
					If !aItem[nI][Len(aItem[nI])]
						aTes:= FGetImp( { aItem[nI,nPOSTES] } )
						If Len(aTes) > 0
							nAcuDes += aItem[nI,nPosDes]
						EndIf
					EndIf
				Next nI
				nBasImp := nBasImp - nAcuDes
			EndIf
		EndIf
	EndIf
    
Return nBasImp

/*/{Protheus.doc} ChkAliqImp
    Verifica si existen alicuotas diferentes para un mismo impuesto.
    @type  Function
    @author raul.medina
    @since 07/2024
    @param aTesItems, array , array con la información de las TES de la factura 
	@param aItem, array , array con la información de los items de la factura
    @return lRet, logico, indica si es posible realizar la edición de impuestos.
    /*/
Static Function ChkAliqImp(aTesItems, aItem)
Local nX		:= 0
Local nY		:= 0
Local nAliqAux	:= 0
Local nAliqIt	:= 0
Local lRet		:= .T.
Local aImp	:= {}

Default aTesItems	:= {}
Default aItem		:= {}

	If MafisFound()
		For nX := 1 To Len(aTesItems)
			nAliqIt := 0
			nAliqAux := 0
			For nY := 1 To Len(aItem)
				If !aItem[nY][Len(aItem[nY])] .AND. MaFisFound("IT",nY)
					nAliqIt := MaFisRet(nY,"IT_ALIQIV" + aTesItems[nX][5])
					aImp := FGetImp( { aItem[nY,nPOSTES] } )
					If nAliqIt > 0 .and. aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( aTesItems[nX][1] ) } ) > 0
						If nAliqAux == 0
							nAliqAux := nAliqIt
						ElseIf nAliqAux > 0 .and. !(nAliqIt == nAliqAux)
							Help( ,, "CONFIMP", , STR0028 + aTesItems[nX][1], 1, 0 ) //"No es posible realizar la edición de impuestos, existen diferentes alícuotas para el impuesto "
							FwClearHlp()	//Limpia último help executado
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			Next
		Next
	EndIf
	ASize(aImp,0)
Return lRet


/*/{Protheus.doc} getDatosF4
    Se obtiene si fue suma o resta en títulos(duplicatas) o totales
    @type  Function
    @author adrian.perez
    @since 10/09/2024
   	@param cImposto, carácter, impuesto a buscar en la SFC
	@param cTES, carácter, código de TES
    @param cTipo, carácter, indica si busca títulos(duplicatas) o totales
    @return nSig,numérico,indica si es suma con 1 o resta con -1
    /*/
Function getDatosF4(cImposto,cTES,cTipo)

	LOCAL aAreaAnt := GETAREA()
	Local nSig:=1

	DEFAULT cImposto:=""
	DEFAULT cTES:=""
	DEFAULT cTipo:=""


		DbSelectArea("SFC")
		SFC->(dbSetOrder(2))
		If SFC->(MsSeek(xFilial("SFC") + cTES+ cImposto)) //FC_FILIAL+FC_TES+FC_IMPOSTO
			If !Empty(SFC->FC_INCNOTA) .AND. cTipo!="DU"
				If SFC->FC_INCNOTA == '2' 
					nSig:= nSig*-1
				EndIf
			EndIf

			If !Empty(SFC->FC_INCDUPL) .AND. cTipo=="DU"
								
				If SFC->FC_INCDUPL == '2' 

					nSig:= nSig*-1
				EndIf

			EndIf
			
		EndIf

		RESTAREA(aAreaAnt)
Return nSig


/*/{Protheus.doc} getValAct
    Se obtiene el valor actual de lots titulos o valores totals
    @type  Function
    @author adrian.perez
    @since 11/09/2024
	@param nValAntImp,numérico,valor anterior impuesto
    @param nValAntTo,numérico,valor anterior total de titulo o valor total
	@param cTES, carácter, código de TES
    @param cTipo, carácter, indica si busca títulos(duplicatas) o totales
	@param cImposto, carácter, impuesto a buscar en la SFC
	@param nBasImp,numérico,valor actualizado
    @return nValorI,numérico,valor actualizado
    /*/

Function getValAct(nValAntImp,nValAntTo,cTES,cTipo,cImposto,nBasImp)
	
	Local nSig:=1
    Local nValorI:=0

	DEFAULT nValAntImp:=0
	DEFAULT nValAntTo:=0
	DEFAULT cTES:=0
	DEFAULT cTipo:=0
	DEFAULT cImposto:=0
	DEFAULT nBasImp:=0

	nSig:= getDatosF4(cImposto,cTES,cTipo)
						 
	IF  (nSig==-1) .AND.( (nvalorI<nValAntTo) .OR. (nvalorI<nBasImp) )  //controla cuano se resta titulo resta
		nValorI:=  nValAntTo + nValAntImp
	Else
		nValorI:= nValAntTo - nValAntImp
	Endif

return nValorI
