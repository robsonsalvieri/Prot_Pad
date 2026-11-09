#Include 'Protheus.ch'   
#INCLUDE "STIPARCPAY.CH"

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIParcPay

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIParcPay()
Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function ModelDef()

Local oStruMst 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela
Local oStruDtl 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela
Local oModel 		:= Nil 						//Utilizada para carregar o model

oModel := MPFormModel():New('STIParcPay')
oModel:SetDescription(STR0001) //"Parcelas"

oStruMst:AddTable("SL1",{"L1_FILIAL"},STR0001) //"Parcelas"

oStruMst := STIStruMod(oStruMst, "Mst")
oModel:AddFields( 'ABMASTER', Nil, oStruMst)
oModel:GetModel ( 'ABMASTER' ):SetDescription(STR0001) //"Parcelas"
oModel:SetPrimaryKey({})

//Grid com as parcelas
oStruDtl := STIStruMod(oStruDtl, "Dtl")
oModel:AddGrid('ABDETAIL','ABMASTER',oStruDtl, Nil, Nil, Nil, Nil, Nil)
oModel:SetRelation( 'ABDETAIL', { { 'L1_FILIAL', 'xFilial( "MEX" )' } } , MEX->(IndexKey(1)) )
oModel:GetModel( 'ABDETAIL' ):SetDescription(STR0001)  //"Parcelas"
oModel:GetModel( 'ABDETAIL' ):SetOptional(.T.)

Return oModel


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ViewDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function ViewDef()

Local oModel 		:= FWLoadModel( 'STIParcPay' )	//Modelo de Dados baseado no ModelDef do fonte informado
Local oView 		:= FWFormView():New() 			//Criacao da view
Local oStruMst	:= FWFormViewStruct():New()		//Cria a estrutura dos campos que irao compor a view
Local oStruGrd	:= FWFormViewStruct():New()		//Cria a estrutura dos campos que irao compor a view

oView:SetModel(oModel)
oView:CreateHorizontalBox("MST1",90)
oView:CreateHorizontalBox("MST3",10)

//Totais
oStruMst := STIStruVie(oStruMst,'Mst')
oView:AddField( 'VIEWMST' , oStruMst, 'ABMASTER' ) 
oView:SetOwnerView("VIEWMST","MST3")
oView:EnableTitleView("VIEWMST",STR0002) //"Totais"

//Grid das parcelas
oStruGrd := STIStruVie(oStruGrd,'Dtl')
oView:AddGrid( 'VIEWDTL' , oStruGrd, 'ABDETAIL' ) 
oView:SetOwnerView("VIEWDTL","MST1")
oView:EnableTitleView("VIEWDTL",STR0003) //"Pagamentos"
oView:SetOnlyView("VIEWDTL")

//Inclui as informacoes no Grid
oView:SetAfterViewActivate( { |oView| STIUpdTot(oView) } )

Return oView

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStru, cType)

Default oStru 	:= Nil

If cType == 'Mst'

	oStru:AddField(	STR0004		,; //[01] Titulo do campo
						STR0004		,; //[02] Desc do campo
						"L1_FILIAL"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						8				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0005	,; //[01] Titulo do campo //"Total Parcelas"
						STR0005	,; //[02] Desc do campo //"Total Parcelas"
						"L1_TOTPAR"		,; //[03] Id do Field
						"N"					,; //[04] Tipo do campo
						10					,; //[05] Tamanho do campo
						0					,; //[06] Decimal do campo
						Nil					,; //[07] Code-block de validacao do campo
						Nil					,; //[08] Code-block de validacao When do campo
						Nil					,; //[09] Lista de valores permitido do campo
						Nil					,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil					,; //[11] Code-block de inicializacao do campo
						Nil					,; //[12] Indica se trata-se de um campo chave
						Nil					,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.					)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0006		,; //[01] Titulo do campo
						STR0006		,; //[02] Desc do campo
						"L1_TROCO"		,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						16				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0007	,; //[01] Titulo do campo
						STR0007	,; //[02] Desc do campo
						"L1_TOTVEN"	,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						16				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual

Else

	oStru:AddField(	STR0008		,; //[01] Titulo do campo
						STR0008		,; //[02] Desc do campo
						"L1_DATE"	,; //[03] Id do Field
						"D"			,; //[04] Tipo do campo
						8			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual
	
	
	oStru:AddField(	STR0009	,; //[01] Titulo do campo
						STR0009	,; //[02] Desc do campo
						"L1_FORMA"	,; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						5			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual
				
				
	oStru:AddField(	STR0010	,; //[01] Titulo do campo
						STR0010	,; //[02] Desc do campo //"Valor Pago"
						"L1_VLPG"		,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						16				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual
	
	oStru:AddField(	STR0001		,; //[01] Titulo do campo
						STR0001		,; //[02] Desc do campo //	"Parcelas"
						"L1_PARC"		,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						5				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual
						
EndIf		
											
Return oStru

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruVie(oStru,cType)

Default oStru	:= Nil

If cType == 'Dtl'

	oStru:AddField( 	"L1_DATE"	,; //[01] CIDFIELD - ID DO FIELD
						"01"		,; //[02] CORDEM - ORDEM DO CAMPO
						STR0008		,; //[03] CTITULO - TITULO DO CAMPO
						STR0008		,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}			,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"D"			,; //[06] CTYPE - TIPO
						""			,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil			,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""			,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.			,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil			,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil			,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil			,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil			,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil			,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.			,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil			)  //[17] CPICTVAR - PICTURE VARIAVEL
				
	oStru:AddField( 	"L1_FORMA"		,; //[01] CIDFIELD - ID DO FIELD
						"02"			,; //[02] CORDEM - ORDEM DO CAMPO
						STR0009			,; //[03] CTITULO - TITULO DO CAMPO
						STR0009			,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}				,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"C"				,; //[06] CTYPE - TIPO
						"@!"			,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil				,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""				,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.				,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil				,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil				,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil				,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil				,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.				,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil				)  //[17] CPICTVAR - PICTURE VARIAVEL
						
	oStru:AddField( 	"L1_VLPG"		,; //[01] CIDFIELD - ID DO FIELD
						"03"			,; //[02] CORDEM - ORDEM DO CAMPO
						STR0010			,; //[03] CTITULO - TITULO DO CAMPO
						STR0010			,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}				,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"				,; //[06] CTYPE - TIPO
						""				,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil				,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""				,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.				,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil				,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil				,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil				,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil				,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.				,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil				)  //[17] CPICTVAR - PICTURE VARIAVEL
	
	oStru:AddField( 	"L1_PARC"		,; //[01] CIDFIELD - ID DO FIELD
						"04"			,; //[02] CORDEM - ORDEM DO CAMPO
						STR0001		,; //[03] CTITULO - TITULO DO CAMPO
						STR0001		,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}				,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"C"				,; //[06] CTYPE - TIPO
						"@!"			,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil				,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""				,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.				,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil				,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil				,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil				,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil				,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.				,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil				)  //[17] CPICTVAR - PICTURE VARIAVEL

Else 

	oStru:AddField( 	"L1_TOTVEN"		,; //[01] CIDFIELD - ID DO FIELD
						"05"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0007		,; //[03] CTITULO - TITULO DO CAMPO
						STR0007		,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"@E 999,999.99"	,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.F.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL
	
	oStru:AddField( 	"L1_TOTPAR"		,; //[01] CIDFIELD - ID DO FIELD
						"06"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0005				,; //[03] CTITULO - TITULO DO CAMPO
						STR0005         	,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"@E 99999"			,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.F.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL

	oStru:AddField( 	"L1_TROCO"			,; //[01] CIDFIELD - ID DO FIELD
						"07"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0006 			,; //[03] CTITULO - TITULO DO CAMPO
						STR0006 			,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"@E 999,999.99"	,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.F.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.T.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL

EndIf
				
Return oStru

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIUpdGrid(dDate, cFormPgto, nValPg, cParcels)

Local oMdl 	:= FwModelActive()					//Recupera o model ativo
Local oMdlGrd	:= oMdl:GetModel("ABDETAIL")		//Seta o model do grid
Local oMdlMst	:= oMdl:GetModel("ABMASTER")		//Seta o model do master
Local cFilL4	:= STDGPBasket("SL1","L1_FILIAL")	//ToDo: Provisorio
Local cNumL4	:= STDGPBasket("SL1","L1_NUM")		//ToDo: Provisorio

oMdlMst:LoadValue( "L1_FILIAL"	, xFilial('MEX') )

oMdlGrd:LoadValue( "L1_DATE"	, dDate		)
oMdlGrd:LoadValue( "L1_FORMA"	, cFormPgto	)	
oMdlGrd:LoadValue( "L1_VLPG"	, nValPg 		)	
oMdlGrd:LoadValue( "L1_PARC"	, cParcels		)

/* ToDo: Provisorio */
STDSPBasket("SL4", "L4_FILIAL"	,cFilL4)
STDSPBasket("SL4", "L4_NUM"		,cNumL4)
STDSPBasket("SL4", "L4_DATA"	,dDate)
STDSPBasket("SL4", "L4_VALOR"	,nValPg)
STDSPBasket("SL4", "L4_FORMA"	,cFormPgto)

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIConfGrv()

/* ToDo: Provisorio */
STWFinishSale()

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	14/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIUpdTot(oView)

Local oMdl 	:= FwModelActive()					//Recupera o model ativo
Local oMdlMst	:= oMdl:GetModel("ABMASTER")		//Seta o model do master

oMdlMst:LoadValue( "L1_TOTVEN"	, STDGPBasket("SL1","L1_VLRTOT") )
oView:Refresh()

Return