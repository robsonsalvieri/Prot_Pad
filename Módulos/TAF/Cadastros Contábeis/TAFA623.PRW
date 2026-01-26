#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA623.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA623
Cadastro MVC
Registro X370 - Informações Sobre as Transações Controladas
Registro X371 - Informações Sobre Ajustes Compensatórios
Registro X375 - Informações Relacionadas aos Métodos

@author Rafael de Paula Leme
@since 07/03/2024
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA623()

Local oBrw := FWmBrowse():New()

If TAFAlsInDic('V17')
	oBrw:SetDescription(STR0053) //"Info Sobre as Transações Controladas"
	oBrw:SetAlias('V17')
	oBrw:SetMenuDef('TAFA623')
	V17->(DBSetOrder(1))
	oBrw:Activate()
Else
	Aviso(STR0054, TafAmbInvMsg(), { STR0055 }, 3) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael de Paula Leme
@since 07/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao 	as array
Local aRotina 	as array
LOCAL nPos	  	as numeric

aFuncao := {}
aRotina := {}
nPos	:=	0

Aadd( aFuncao, { "" , "Taf623Vld" , "2" } )
aRotina := xFunMnuTAF('TAFA623',,aFuncao)

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == 'Visualizar' } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF623Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == 'Incluir' } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF623Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == 'Alterar' } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF623Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == 'Excluir' } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF623Pre( 'Excluir' )"
EndIf

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf623Pre
Funcao que valida pré condição para inclusão, alteração, visualização e exclusão do cadastro
@author Carlos Pister
@since 09/04/2024
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf623Pre( cOper, cRotina )

	Local nOperation	as numeric	
	Local aButtons		as array
	Local lOk			as logical
	Local lRet			as logical

	Private cIdMetodo	as character

	Default cRotina		:=	"TAFA623"

	nOperation		:=	MODEL_OPERATION_VIEW
	aButtons		:=	{}
	lOk				:=	.F.
	lRet			:=	.T.
	cIdMetodo		:= ""

	If Upper( cOper ) == Upper( "Visualizar" )
		nOperation := MODEL_OPERATION_VIEW
	ElseIf Upper( cOper ) == Upper( "Incluir" )
		nOperation := MODEL_OPERATION_INSERT
	ElseIf Upper( cOper ) == Upper( "Alterar" )
		nOperation := MODEL_OPERATION_UPDATE
	ElseIf Upper( cOper ) == Upper( "Excluir" )
		nOperation := MODEL_OPERATION_DELETE
	EndIf

	If nOperation == MODEL_OPERATION_INSERT

		aAdd( aButtons, { 1, .T., { |x| lOk := .T., x:oWnd:End() } } )
		aAdd( aButtons, { 2, .T., { |x| x:oWnd:End() } } )

		If PergTAF( cRotina, STR0067, { STR0068 }, aButtons, { || .T. },,, .F. ) .and. lOk //##"Tipo de Método" ##"Tipo de Método das Informações Relacionadas" 
			DBSelectArea( "CH6" )
			CH6->( DBSetOrder( 4 ) )
			If CH6->( MsSeek( xFilial( "CH6" ) + MV_PAR01 ) ) 
				cIdMetodo := MV_PAR01
				FWExecView( cOper, cRotina, nOperation )
			Else
				MsgInfo( STR0110 )//"Método não informado ou não disponível no Layout da ECF" 
				Taf623Pre( cOper, cRotina )
			Endif
		Else
			cIdMetodo := "CANCEL"
			MsgInfo( STR0069 ) //"É necessário informar o Tipo de Método para definição das informações a serem exibidas no cadastro."
		EndIf
	Else
		cIdMetodo := V17->V17_METODO
		FWExecView( cOper, cRotina, nOperation )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael de Paula Leme
@since 07/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV17	as object
Local oStruV18	as object
Local oModel	as object
Local lAutomato as logical 

lAutomato := IsBlind()

oStruV17 :=	FWFormStruct(1, 'V17')
oStruV18 :=	FWFormStruct(1, 'V18')
oModel   :=	MPFormModel():New("TAFA623",, {|oModel| ValidModel(oModel)}, {|oModel| SaveModel(oModel)})

//Inicializa o código do método
oStruV17:SetProperty( "V17_METODO", MODEL_FIELD_INIT, { |oModel| cIdMetodo } )

oStruV17:SetProperty( "V17_METODO", MODEL_FIELD_WHEN, { || .F. .or. lAutomato} )

//Registro X370 - Informações Sobre as Transações Controladas
oModel:AddFields('MODEL_V17', /*cOwner*/, oStruV17)
oModel:GetModel('MODEL_V17'):SetPrimaryKey({'V17_IDIDEN', 'V17_TPTRAN'})

//Registro X371 - Informações Sobre Ajustes Compensatórios
oModel:AddGrid('MODEL_V18', 'MODEL_V17', oStruV18)
oModel:GetModel('MODEL_V18'):SetUniqueLine({'V18_IDCTA', 'V18_CODCUS'})
oModel:GetModel('MODEL_V18'):SetOptional(.T.)

oModel:SetRelation("MODEL_V18",{ {"V18_FILIAL","xFilial('V18')"}, {"V18_ID","V17_ID"} },V18->( IndexKey(1)))

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael de Paula Leme
@since 07/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel('TAFA623')
Local oStruV17 	:= 	FWFormStruct(2, 'V17')
Local oStruV18 	:= 	FWFormStruct(2, 'V18')
Local oView		:=  FWFormView():New()

oView:SetModel(oModel)

cIdMetodo	:=	Iif( Type( "cIdMetodo" ) == "U", "", cIdMetodo )

oView:AddField('VIEW_V17', oStruV17, 'MODEL_V17')

oView:AddGrid('VIEW_V18', oStruV18, 'MODEL_V18')

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox('FIELDSV17'  , 65)          
oView:CreateHorizontalBox('FOLDERGERAL', 35)

oView:CreateFolder('FOLDER1', 'FOLDERGERAL')

oView:AddSheet('FOLDER1', 'ABA01', STR0057) //Informações Sobre Ajustes Compensatórios
oView:CreateHorizontalBox('GRIDV18', 100,,, 'FOLDER1', 'ABA01')

//Descrição dos campos
oStruV17:SetProperty('V17_NMPTES', MVC_VIEW_TITULO ,STR0070 )//'Nome da Parte Testada'
oStruV17:SetProperty('V17_PPTTES', MVC_VIEW_TITULO ,STR0071 )//'País da Parte Testada'
oStruV17:SetProperty('V17_DPPTTE', MVC_VIEW_TITULO ,STR0109 )//'Descrição do País da Parte Testada'
If cIdMetodo == 'PRL'
	oStruV17:SetProperty('V17_EMBRRL', MVC_VIEW_TITULO ,STR0072 )//'Empresa no Brasil - Receita Líquida'
	oStruV17:SetProperty('V17_EMBRLB', MVC_VIEW_TITULO ,STR0073 )//'Empresa no Brasil - Lucro Bruto'
	oStruV17:SetProperty('V17_EMBRMB', MVC_VIEW_TITULO ,STR0074 )//'Empresa no Brasil - Margem Bruta'
	oStruV17:SetProperty('V17_EMEXRL', MVC_VIEW_TITULO ,STR0075 )//'Empresa no Exterior - Receita Líquida'
	oStruV17:SetProperty('V17_EMEXLB', MVC_VIEW_TITULO ,STR0076 )//'Empresa Exterior - Lucro Bruto'
	oStruV17:SetProperty('V17_EMEXMB', MVC_VIEW_TITULO ,STR0077 )//'Empresa Exterior - Margem Bruta'
ElseIf cIdMetodo == 'MCL'
	oStruV17:SetProperty('V17_EMBRRL', MVC_VIEW_TITULO ,STR0097 )//'Empresa Brasil - Custos (diretos e indiretos)'
	oStruV17:SetProperty('V17_EMBRLB', MVC_VIEW_TITULO ,STR0098 )//'Empresa Brasil - Lucro Bruto'
	oStruV17:SetProperty('V17_EMBRMB', MVC_VIEW_TITULO ,STR0099 )//'Empresa Brasil - Margem Bruta'
	oStruV17:SetProperty('V17_EMEXRL', MVC_VIEW_TITULO ,STR0100 )//'Empresa Exterior Custos (diretos e indiretos)'
	oStruV17:SetProperty('V17_EMEXLB', MVC_VIEW_TITULO ,STR0101 )//'Empresa Exterior Lucro Bruto'
	oStruV17:SetProperty('V17_EMEXMB', MVC_VIEW_TITULO ,STR0102 )//'Empresa Exterior Margem Bruta'
ElseIf cIdMetodo == 'MLT'
	oStruV17:SetProperty('V17_EMBRRL', MVC_VIEW_TITULO ,STR0103 )//'Empresa no Brasil - Lucro Operacional'
	oStruV17:SetProperty('V17_EMBRLB', MVC_VIEW_TITULO ,STR0104 )//'Empresa no Brasil - Valor Indicador'
	oStruV17:SetProperty('V17_EMBRMB', MVC_VIEW_TITULO ,STR0105 )//'Empresa no Brasil - Margem Líquida'
	oStruV17:SetProperty('V17_EMEXRL', MVC_VIEW_TITULO ,STR0106 )//'Empresa no Exterior - Lucro Operacional'
	oStruV17:SetProperty('V17_EMEXLB', MVC_VIEW_TITULO ,STR0107 )//'Empresa Exterior Valor Indicador'
	oStruV17:SetProperty('V17_EMEXMB', MVC_VIEW_TITULO ,STR0108 )//'Empresa Exterior Margem Líquida'
EndIf
oStruV17:SetProperty('V17_TIPOCP', MVC_VIEW_TITULO ,STR0078 )//'Tipo de Comparável?'
oStruV17:SetProperty('V17_COMPAR', MVC_VIEW_TITULO ,STR0079 )//'Comparável?'
oStruV17:SetProperty('V17_AJRCPS', MVC_VIEW_TITULO ,STR0080 )//'Ajuste Risco - País?'
oStruV17:SetProperty('V17_ECMBMA', MVC_VIEW_TITULO ,STR0081 )//'Empresa Comparável - Margem Bruta Mínima'
oStruV17:SetProperty('V17_ECMBMX', MVC_VIEW_TITULO ,STR0082 )//'Empresa Comparável - Margem Bruta Máxima'
oStruV17:SetProperty('V17_INDREN', MVC_VIEW_TITULO ,STR0083 )//'Indicador de Rentabilidade'
oStruV17:SetProperty('V17_DIVRES', MVC_VIEW_TITULO ,STR0084 )//'Divisão de Resultados?'
oStruV17:SetProperty('V17_CRFTRT', MVC_VIEW_TITULO ,STR0085 )//'Critérios ou Fatores de Rateio'
oStruV17:SetProperty('V17_RESULT', MVC_VIEW_TITULO ,STR0086 )//'Resultado'
oStruV17:SetProperty('V17_COMDYT', MVC_VIEW_TITULO ,STR0087 )//'Commodity'
oStruV17:SetProperty('V17_TPCOMD', MVC_VIEW_TITULO ,STR0088 )//'Tipo de Commodity'
oStruV17:SetProperty('V17_TPCOMP', MVC_VIEW_TITULO ,STR0089 )//'Tipo de Comparável?'
oStruV17:SetProperty('V17_PRCOTA', MVC_VIEW_TITULO ,STR0090 )//'Usou Preço de Cotação?'
oStruV17:SetProperty('V17_FTCOTA', MVC_VIEW_TITULO ,STR0091 )//'Fonte da Cotação'
oStruV17:SetProperty('V17_PRCCTA', MVC_VIEW_TITULO ,STR0092 )//'Preço da Cotação'
oStruV17:SetProperty('V17_DTINIC', MVC_VIEW_TITULO ,STR0093 )//'Data Inicial - Precificação da Transação'
oStruV17:SetProperty('V17_DTFINA', MVC_VIEW_TITULO ,STR0094 )//'Data Final - Precificação da Transação'
oStruV17:SetProperty('V17_PRTRAN', MVC_VIEW_TITULO ,STR0095 )//'Preço da Transação Controlada'
oStruV17:SetProperty('V17_PRCOMP', MVC_VIEW_TITULO ,STR0096 )//'Preço do Comparável'

//Grupo de campos
oStruV17:AddGroup ( 'GRP_DOCUMENTO', STR0056 , '' , 2 ) //"Informações Sobre as Transações Controladas"
oStruV17:AddGroup ( 'GRP_X375', STR0066 , '' , 2 ) //"Informações Relacionadas ao Método"
//CABEÇALHO
oStruV17:SetProperty( 'V17_PERIOD'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_IDENT'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_NOME'    , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_TPTRAN'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_PAIS'    , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_DPAIS'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_CODNCM'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_DESNCM'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_TPDEMA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_DBSDI'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_VLTRAN'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_INDAJU'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_VLESPO'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_VLCOMP'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_TPAJUS'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_METODO'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_DMETOD'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_COMINT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_SINERG'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_INDTRA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_INDDAD'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruV17:SetProperty( 'V17_INDSIM'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )

If cIdMetodo $ 'PRL|MCL|MLT'
	oStruV17:SetProperty( 'V17_NMPTES'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_PPTTES'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_DPPTTE'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMBRRL'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMBRLB'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMBRMB'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMEXRL'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMEXLB'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_EMEXMB'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_TIPOCP'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_COMPAR'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_AJRCPS'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_ECMBMA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_ECMBMX'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	If cIdMetodo == 'MLT'
		oStruV17:SetProperty( 'V17_INDREN'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
		oStruV17:SetProperty( "V17_INDREN", MVC_VIEW_ORDEM, "27" )
		oStruV17:SetProperty( "V17_NMPTES", MVC_VIEW_ORDEM, "28" )
		oStruV17:SetProperty( "V17_PPTTES", MVC_VIEW_ORDEM, "29" )
		oStruV17:SetProperty( "V17_DPPTTE", MVC_VIEW_ORDEM, "30" )
		oStruV17:SetProperty( "V17_EMBRRL", MVC_VIEW_ORDEM, "31" )
		oStruV17:SetProperty( "V17_EMBRLB", MVC_VIEW_ORDEM, "32" )
		oStruV17:SetProperty( "V17_EMBRMB", MVC_VIEW_ORDEM, "33" )
		oStruV17:SetProperty( "V17_EMEXRL", MVC_VIEW_ORDEM, "34" )
		oStruV17:SetProperty( "V17_EMEXLB", MVC_VIEW_ORDEM, "35" )
		oStruV17:SetProperty( "V17_EMEXMB", MVC_VIEW_ORDEM, "36" )
		oStruV17:SetProperty( "V17_TIPOCP", MVC_VIEW_ORDEM, "37" )
		oStruV17:SetProperty( "V17_COMPAR", MVC_VIEW_ORDEM, "38" )
		oStruV17:SetProperty( "V17_AJRCPS", MVC_VIEW_ORDEM, "39" )
		oStruV17:SetProperty( "V17_ECMBMA", MVC_VIEW_ORDEM, "40" )
		oStruV17:SetProperty( "V17_ECMBMX", MVC_VIEW_ORDEM, "41" )
	Else
		oStruV17:SetProperty( "V17_NMPTES", MVC_VIEW_ORDEM, "27" )
		oStruV17:SetProperty( "V17_PPTTES", MVC_VIEW_ORDEM, "28" )
		oStruV17:SetProperty( "V17_DPPTTE", MVC_VIEW_ORDEM, "29" )
		oStruV17:SetProperty( "V17_EMBRRL", MVC_VIEW_ORDEM, "30" )
		oStruV17:SetProperty( "V17_EMBRLB", MVC_VIEW_ORDEM, "31" )
		oStruV17:SetProperty( "V17_EMBRMB", MVC_VIEW_ORDEM, "32" )
		oStruV17:SetProperty( "V17_EMEXRL", MVC_VIEW_ORDEM, "33" )
		oStruV17:SetProperty( "V17_EMEXLB", MVC_VIEW_ORDEM, "34" )
		oStruV17:SetProperty( "V17_EMEXMB", MVC_VIEW_ORDEM, "35" )
		oStruV17:SetProperty( "V17_TIPOCP", MVC_VIEW_ORDEM, "36" )
		oStruV17:SetProperty( "V17_COMPAR", MVC_VIEW_ORDEM, "37" )
		oStruV17:SetProperty( "V17_AJRCPS", MVC_VIEW_ORDEM, "38" )
		oStruV17:SetProperty( "V17_ECMBMA", MVC_VIEW_ORDEM, "39" )
		oStruV17:SetProperty( "V17_ECMBMX", MVC_VIEW_ORDEM, "40" )
	EndIf
ElseIf cIdMetodo == 'MDL'
	oStruV17:SetProperty( 'V17_DIVRES'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_CRFTRT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_RESULT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
ElseIf cIdMetodo == 'PIC'
	oStruV17:SetProperty( 'V17_COMDYT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_TPCOMD'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_TPCOMP'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_PRCOTA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_FTCOTA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_PRCCTA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_DTINIC'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_DTFINA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_PRTRAN'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
	oStruV17:SetProperty( 'V17_PRCOMP'  , MVC_VIEW_GROUP_NUMBER , 'GRP_X375' )
EndIf

If cIdMetodo $ 'MDL|PIC|PRL|MCL|MLT|OUT'
	If cIdMetodo $ 'MDL|PIC|OUT'
		If cIdMetodo $ 'PIC|OUT'
			oStruV17:RemoveField( 'V17_DIVRES' )
			oStruV17:RemoveField( 'V17_CRFTRT' )
			oStruV17:RemoveField( 'V17_RESULT' )
		EndIf
		oStruV17:RemoveField( 'V17_NMPTES' )
		oStruV17:RemoveField( 'V17_PPTTES' )
		oStruV17:RemoveField( "V17_DPPTTE" )
		oStruV17:RemoveField( 'V17_EMBRRL' )
		oStruV17:RemoveField( 'V17_EMBRLB' )
		oStruV17:RemoveField( 'V17_EMBRMB' )
		oStruV17:RemoveField( 'V17_EMEXRL' )
		oStruV17:RemoveField( 'V17_EMEXLB' )
		oStruV17:RemoveField( 'V17_EMEXMB' )
		oStruV17:RemoveField( 'V17_TIPOCP' )
		oStruV17:RemoveField( 'V17_COMPAR' )
		oStruV17:RemoveField( 'V17_AJRCPS' )
		oStruV17:RemoveField( 'V17_ECMBMA' )
		oStruV17:RemoveField( 'V17_ECMBMX' )
		oStruV17:RemoveField( 'V17_INDREN' )
	EndIf
	If cIdMetodo $ 'PRL|MCL|MLT|MDL|OUT'
		if cIdMetodo $ 'PRL|MCL|OUT'
			oStruV17:RemoveField( 'V17_INDREN' )
		EndIf
		if !(cIdMetodo $ 'MDL')
			oStruV17:RemoveField( 'V17_DIVRES' )
			oStruV17:RemoveField( 'V17_CRFTRT' )
			oStruV17:RemoveField( 'V17_RESULT' )
		EndIf
		oStruV17:RemoveField( 'V17_COMDYT' )
		oStruV17:RemoveField( 'V17_TPCOMD' )
		oStruV17:RemoveField( 'V17_TPCOMP' )
		oStruV17:RemoveField( 'V17_PRCOTA' )
		oStruV17:RemoveField( 'V17_FTCOTA' )
		oStruV17:RemoveField( 'V17_PRCCTA' )
		oStruV17:RemoveField( 'V17_DTINIC' )
		oStruV17:RemoveField( 'V17_DTFINA' )
		oStruV17:RemoveField( 'V17_PRTRAN' )
		oStruV17:RemoveField( 'V17_PRCOMP' )
	EndIf
EndIf

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView('VIEW_V17', 'FIELDSV17')
oView:SetOwnerView('VIEW_V18', 'GRIDV18')

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruV17:RemoveField('V17_ID')
oStruV17:RemoveField('V17_IDIDEN')
oStruV18:RemoveField('V18_IDCTA')

Return oView

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} V17TpTrans
Retorna string para combobox
Alias: V17 - REGISTRO X370: INFORMAÇÕES SOBRE AS TRANSAÇÕES CONTROLADAS
Campo: 03  - TIPO_TRANSAÇÃO

@author Rafael de Paula Leme
@since 06/03/2024
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function V17TpTrans()
	
	Local cCombo as character

	cCombo := "01=" + STR0001 + ";" //01 - Exportações de Bens
	cCombo += "02=" + STR0002 + ";" //02 - Importações de Bens
	cCombo += "03=" + STR0003 + ";" //03 - Exportações de Serviços
	cCombo += "04=" + STR0004 + ";" //04 - Importações de Serviços
	cCombo += "05=" + STR0005 + ";" //05 - Exportações de Direitos
	cCombo += "06=" + STR0006 + ";" //06 - Importações de Direitos
	cCombo += "07=" + STR0007 + ";" //07 - Operações Financeiras - Receitas Auferidas
	cCombo += "08=" + STR0008 + ";" //08 - Operações Financeiras - Despesas incorridas
	cCombo += "09=" + STR0009 + ";" //09 - Transações com Intangíveis - Receitas Auferidas
	cCombo += "10=" + STR0010 + ";" //10 - Transações com Intangíveis - Despesas Incorridas
	cCombo += "11=" + STR0011       //11 - Contratos de Compartilhamento de Custos

Return cCombo

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} V17TpDemais
Retorna string para combobox
Alias: V17 - REGISTRO X370: INFORMAÇÕES SOBRE AS TRANSAÇÕES CONTROLADAS
Campo: 07  - TIPO_DEMAIS

@author Rafael de Paula Leme
@since 06/03/2024
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function V17TpDemais()

	Local cCombo as character

	cCombo := "101=" + STR0012 + ";" //101 - Compras - Serviço
	cCombo += "102=" + STR0013 + ";" //102 - Manufatura ou produção - Serviço
	cCombo += "103=" + STR0014 + ";" //103 - Vendas, marketing ou distribuição - Serviço
	cCombo += "104=" + STR0015 + ";" //104 - Serviços administrativos e contábeis - Serviço
	cCombo += "105=" + STR0016 + ";" //105 - Serviços financeiros - Serviço
	cCombo += "106=" + STR0017 + ";" //106 - Seguro - Serviço
	cCombo += "107=" + STR0018 + ";" //107 - Gestão de ações e outros instrumentos de capital - Serviço
	cCombo += "108=" + STR0019 + ";" //108 - Tecnologia da informação - Serviço
	cCombo += "109=" + STR0020 + ";" //109 - Serviços jurídicos - Serviço
	cCombo += "110=" + STR0021 + ";" //110 - Consultoria estratégica - Serviço
	cCombo += "111=" + STR0022 + ";" //111 - Recursos humanos - Serviço
	cCombo += "112=" + STR0023 + ";" //112 - Pesquisa e desenvolvimento - Serviço
	cCombo += "113=" + STR0024 + ";" //113 - Gestão de propriedade intelectual - Serviço
	cCombo += "199=" + STR0025 + ";" //199 - Outros tipos de serviços - Serviço
	cCombo += "201=" + STR0026 + ";" //201 - Aluguel de Plataforma /Afretamento - Direito
	cCombo += "202=" + STR0027 + ";" //202 - Aluguel de equipamentos - Direito
	cCombo += "299=" + STR0028 + ";" //299 - Outros - Direito
	cCombo += "301=" + STR0029 + ";" //301 - Empréstimo - Financeiro
	cCombo += "302=" + STR0030 + ";" //302 - Leasing - Financeiro
	cCombo += "303=" + STR0031 + ";" //303 - Arrendamento mercantil - Financeiro
	cCombo += "304=" + STR0032 + ";" //304 - Garantia - Financeiro
	cCombo += "399=" + STR0033 + ";" //399 - Outro tipo de operações financeiras - Financeiro
	cCombo += "401=" + STR0034 + ";" //401 - Patente - Intangível
	cCombo += "402=" + STR0035 + ";" //402 - Marca registrada - Intangível
	cCombo += "403=" + STR0036 + ";" //403 - Direitos autorais - Intangível
	cCombo += "404=" + STR0037 + ";" //404 - Know-how - Intangível
	cCombo += "405=" + STR0038 + ";" //405 - Licença - Intangível
	cCombo += "406=" + STR0039 + ";" //406 - Franquia - Intangível
	cCombo += "499=" + STR0040 + ";" //499 - Outro tipo de transações com Intangíveis - Intangível
	cCombo += "501=" + STR0041 + ";" //501 - Lista de tipo de serviços ou atividades - Composição de Custos
	cCombo += "502=" + STR0042 + ";" //502 - Pesquisa e desenvolvimento - Composição de Custos
	cCombo += "503=" + STR0043 + ";" //503 - Gestão de propriedade intelectual - Composição de Custos
	cCombo += "504=" + STR0044 + ";" //504 - Compras - Composição de Custos
	cCombo += "505=" + STR0045 + ";" //505 - Manufatura ou produção - Composição de Custos
	cCombo += "506=" + STR0046 + ";" //506 - Vendas, marketing ou distribuição - Composição de Custos
	cCombo += "507=" + STR0047 + ";" //507 - Serviços administrativos ou de gestão - Composição de Custos
	cCombo += "508=" + STR0048 + ";" //508 - Serviços financeiros - Composição de Custos
	cCombo += "509=" + STR0049 + ";" //509 - Seguro - Composição de Custos
	cCombo += "510=" + STR0050 + ";" //510 - Gestão de ações e outros inst. de capital - Composição de Custos
	cCombo += "511=" + STR0051 + ";" //511 - Serviços de TI - Composição de Custos
	cCombo += "599=" + STR0052       //599 - Outros Contratos de compartilhamento de custos - Composição de Custos

Return cCombo

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} V17TDemais
Validação campo V17_TPDEMA
Alias: V17 - REGISTRO X370: INFORMAÇÕES SOBRE AS TRANSAÇÕES CONTROLADAS
Campo: 07  - TIPO_DEMAIS

@author Rafael de Paula Leme
@since 06/03/2024
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function V17TDemais(cCombo)
	
	Local lRet as logical

	lRet := .F.

	If cCombo $ "   |101|102|103|104|105|106|107|108|109|110|111|112|113|199|201|202|299|301|302|303|304|399|401|402|403|404|405|406|499|501|502|503|504|505|506|507|508|509|510|511|599"
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Validação dos dados, executado no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados
@Return		lRet	- Indica se todas as condições foram respeitadas

@Author		Rafael Paula Leme
@Since		11/03/2024
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel(oModel)

	Local oModelV17		as object
	Local oModelV18		as object
	Local nOperation	as numeric
	Local nI            as numeric
	Local aAreaV17		as array
	Local aAreaV18		as array
	Local lRet			as logical

	oModelV17	:=	oModel:GetModel("MODEL_V17")
	oModelV18	:=	oModel:GetModel("MODEL_V18")
	
	nOperation	:=	oModel:GetOperation()
	nI          :=  0
	aAreaV17	:=	V17->(GetArea())
	aAreaV18	:=	V18->(GetArea())
	
	lRet		:=	.T.

	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

		lRet := TafVlV17() //Proteção para não permitir chave duplicada
		
		If lRet .and. AllTrim(oModelV17:GetValue("V17_METODO")) == "OUT"
			If AllTrim(oModelV17:GetValue("V17_DMETOD")) == ""
				lRet := .F.
				If !IsBlind()
					Help(,, "HELP",, STR0059, 1, 0) //"Obrigatório o preenchimento do campo 'Desc. Met.' quando 'Método' igual a 'OUT' (Outro)"
				EndIf
			EndIf
		EndIf
		
		If lRet .and. oModelV17:GetValue("V17_VLCOMP") > 0
			For nI := 1 to oModelV18:Length()
				oModelV18:GoLine(nI)

				If AllTrim(oModelV18:GetValue("V18_IDCTA", nI)) == "" .or.;
					oModelV18:GetValue("V18_VALOR", nI ) = 0 .or.;
					AllTrim(oModelV18:GetValue("V18_INDVAL", nI )) == ""

					lRet := .F.
					If !IsBlind()
						Help(,, "HELP",, STR0060, 1, 0,,,,,, {STR0061}) //"Obrigatório o preenchimento das Informações Sobre Ajustes Compensatórios quando 'Valor Compensatório' maior que zero." 
					EndIf											//"Preencher os campos obrigatórios: Cód Cta Ctb, Valor e Ind. Valor"
				EndIf                                               
			Next nI
		EndIf

		oModelV18:GoLine(1)

	EndIf

	RestArea(aAreaV17)
	RestArea(aAreaV18)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Rafael de Paula Leme
@since 11/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "V17", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf623Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Rafael de Paula Leme
@since 12/03/2024
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf623Vld( cAlias as char, nRecno as numeric, nOpc as numeric, lJob as logical )

Local aLogErro := {}  as array
Local cStatus  := ""  as character
Local lValida  := .F. as logical

lValida := ( V17->V17_STATUS $ ( " |1" ) )

nRecno := V17->( Recno() )

If lValida
	If Empty( V17->V17_PERIOD )
		aAdd( aLogErro, { "V17_PERIOD", "000001", "V17", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf
	If Empty( V17->V17_IDIDEN )
		aAdd( aLogErro, { "V17_IDENT", "000001", "V17", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf
	//Atualiza o Status do Registro
	//1 = Registro Inválido
	//0 = Registro Válido
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "V17", cStatus )
endif

//Não apresenta o alerta quando utiliza o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVlV17
Validacao de campo para proteger erro de chave duplicada

@param  
@return lRet
@author  Rafael Leme
@since   15/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafVlV17()

Local lRet 	   := .T.
Local alGetV17 := V17->( GetArea() )


dbSelectArea("V17")
V17->(dbSetOrder(2)) //V17_FILIAL+V17_IDIDEN+V17_TPTRAN

//Tratamento protecao chave duplicada
If V17->( DbSeek( xFilial("V17") + FwFldGet( "V17_IDIDEN" ) + FwFldGet( "V17_TPTRAN" ) ) )
	If V17->V17_ID <> FwFldGet("V17_ID")
		lRet := .F.
		If !IsBlind()
			Help("",1,"Help","Help",STR0064, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0065})//"O conteúdo preenchido forma uma chave já cadastrada."#"Informe outro contéudo."
		EndIf
	Endif
Endif

RestArea( alGetV17 )

Return lRet
