#Include 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"     
#INCLUDE "STIPAYFINANCIAL.CH"
#INCLUDE "STPOS.CH"

Static aAdmFin  	:= {}
Static nTamValor   	:= PesqPict("SL4","L4_VALOR")
Static nTamParcela 	:= PesqPict("SL1","L1_PARCELA")
Static nTamAdmCod  	:= TamSx3("AE_COD")[1]
Static nTamAdminis	:= TamSx3("L4_ADMINIS")[1] //Tamanho do campo L4_ADMINIS
Static nTamNumCart	:= TamSx3("L4_NUMCART")[1] //Tamanho do campo L4_NUMCART
Static cGetCard 	:= Space(16)        //Nro Cartao
Static aInfoImport	:= {}					//Array dos dados originais da importaÁ„o para o tipo FI
Static lAltImpFi	:= .F.				// Indica se foi alterado as informaÁıes do orÁamento importado FI

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPayFinancial

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPayFinancial(oPnlAdconal, cTpForm)
Local oLblData 		:= Nil              //Objeto de Label Data
Local oGetData 		:= Nil              //Objeto de Get Data
Local cGetData		:= dDataBase        //DataBase

Local oLblValor		:= Nil              //Objeto de Label Valor
Local oGetValor		:= Nil              //Objeto de Get Valor
Local cGetVal		:= STBCalcSald("1")	//Saldo restante do pagamento

Local oLblParcels	:= Nil              //Objeto de Label Parcelas
Local oGetParcels	:= Nil              //Objeto de Get Parcelas
Local cGetParc	 	:= 1                //Parcela 

Local oLblAdmFin 	:= Nil              //Objeto de Label Adm Financeira
Local oGetAdmFin 	:= Nil              //Objeto de Get Adm Financeira
Local cGetAdmFin	:= ""

Local oBtnOk		:= Nil               //Objeto do botao Ok
Local oBtnCa		:= Nil               //Objeto do botao Cancelar

Local oLblCard	:= Nil              //Objeto de Label Nro Cartao
Local oGetCard	:= Nil              //Objeto de Get Nro Cartao

Local lReadOnly	:= FindFunction("STIGetPayRO") .AND. STIGetPayRO()	//indica se os campos de pagamento est„o como Somente Leitura (permiss„o Alterar Parcelas do caixa)
Local aEditField:= {} //Array para controle de ediÁ„o dos campos que poderao ser editados pelo usuario nesta tela de forma de pagamento "FINANCIADO".

Default cTpForm := ""

//Campos que poder„o ser edit·veis ou n„o na tela
//            		Nome do campo	, Valor Inicial do Campo	, Permite Editar (.T.=Sim, .F.=Nao)
aAdd( aEditField, {	STR0001			, cGetData					, !lReadOnly} ) //Campo "Data"
aAdd( aEditField, {	STR0002			, cGetVal					, !lReadOnly} ) //Campo "Valor"
aAdd( aEditField, {	STR0003			, cGetParc					, !lReadOnly} ) //Campo "Parcelas"

//Ponto de Entrada que controla os campos que poderao ser editados nesta tela de forma de pagamento "FINANCIADO".
//Este P.E. tambem permite definir o valor inicial do campo quando carregada a tela. 
If ExistBlock("STIFINAN")
	aEditField	:= ExecBlock("STIFINAN",.F.,.F.,aEditField)
	//Atribui ‡s variaveis o valor inicial dos campos
	cGetData 	:= aEditField[1][2]
	cGetVal		:= aEditField[2][2]
	cGetParc	:= aEditField[3][2]
EndIf

 /* Label e Get: Data */
oLblData := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,, ,,,,.T.,,,,8) //'Data'
oGetData := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetData:=u,cGetData)},oPnlAdconal,LARG_GET_DATE,ALTURAGET,,,,,,,,.T.,,,,,,,!aEditField[1][3])

oLblData:SetCSS( POSCSS (GetClassName(oLblData), CSS_LABEL_FOCAL ))
oGetData:SetCSS( POSCSS (GetClassName(oGetData), CSS_GET_FOCAL ))

 /* Label e Get: Valor */
oLblValor := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL2, {||STR0002}, oPnlAdconal,, ,,,,.T.,,,,8) //'Valor'
oGetValor := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,LARG_GET_VALOR,ALTURAGET,nTamValor,,,,,,,.T.,,,,,,,!aEditField[2][3])
oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL ))
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_FOCAL )) 

If (cTpForm <> 'CO')
	/* Label e Get: Parcelas */
	If cTpForm <> "DC"
		oLblParcels := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0003}, oPnlAdconal,, ,,,,.T.,,,,8) //'Parcelas'
		oGetParcels := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetParc:=u,cGetParc)},oPnlAdconal,50,ALTURAGET,nTamParcela,,,,,,,.T.,,,,,,,!aEditField[3][3])
		oLblParcels:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
		oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL ))
	EndIf
Else
	/* Label e Get: Num Cartao */
	oLblCard := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0023}, oPnlAdconal,, ,,,,.T.,,,,8) //"Nro. Cartao"
	oGetCard := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetCard:=u,cGetCard)},oPnlAdconal,100,ALTURAGET,"@E 9999999999999999",,,,,,,.T.)
	oLblCard:SetCSS( POSCSS (GetClassName(oLblCard), CSS_LABEL_FOCAL )) 
	oGetCard:SetCSS( POSCSS (GetClassName(oGetCard), CSS_GET_FOCAL ))
EndIf

If !Empty(cTpForm)
	aAdmFin := STDAdmFinan(cTpForm)
EndIf

/* Label e Get: Administradora Financeira */
oLblAdmFin := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL2, {||STR0004}, oPnlAdconal,, ,,,,.T.,,,,8) //'Adm.Financeira'
oGetAdmFin := TComboBox():New(POSVERT_PAYGET2, POSHOR_PAYCOL2, {|u| If(PCount()>0,cGetAdmFin:=u,cGetAdmFin)}, aAdmFin, 100, ALTURAGET, oPnlAdconal, Nil ,  {|oGetAdmFin| STIChgDtFinancial(oGetAdmFin,@oGetData,@cGetData) } , /* bValid*/, /* nClrBack*/, /* nClrText*/, .T./* lPixel*/,  , Nil, Nil, /* bWhen*/, Nil, Nil, Nil, Nil, cGetAdmFin, /* cLabelText*/ ,/* nLabelPos*/,  , /*nLabelColor*/  )
oLblAdmFin:SetCSS( POSCSS (GetClassName(oLblAdmFin), CSS_LABEL_FOCAL )) 
oGetAdmFin:SetCSS( POSCSS (GetClassName(oGetAdmFin), CSS_GET_NORMAL )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0005,oPnlAdconal,{|| STIFiConfPay(oGetData, oGetValor, oGetParcels, oGetAdmFin,oPnlAdconal,oGetCard,cTpForm)},LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento' 

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0006,oPnlAdconal,{|| Iif( ExistFunc("STBCancPay"), IIF(STBCancPay(),STIPayCancel(oPnlAdconal) ,Nil),STIPayCancel(oPnlAdconal)) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL ))
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

oGetData:SetFocus()

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function ModelDef()

Local oStruMst 	:= FWFormModelStruct():New() 	//Variavel para criar a estrutura da tabela
Local oModel 		:= Nil 						//Utilizada para carregar o model

oModel := MPFormModel():New('STIPayFinancial')
oModel:SetDescription(STR0022) //"Pagamento Dinheiro"

oStruMst:AddTable("SL4",{"L4_FILIAL"},STR0007) //"Pagamento"

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'FINANCIALMASTER', Nil, oStruMst)
oModel:GetModel ( 'FINANCIALMASTER' ):SetDescription(STR0008) //"Selecionar Pagamento"

Return oModel


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ViewDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function ViewDef()

Local oModel 		:= FWLoadModel( 'STIPayFinancial' )	//Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMst 	:= FWFormViewStruct():New()		//Cria a estrutura dos campos que irao compor a view

oView := Nil
oView := FWFormView():New()

oView:SetModel(oModel)
oView:CreateHorizontalBox("MST",100)

//Field para pagamento financiado
oStruMst := STIStruVie(oStruMst)
oView:AddField("ViewFinancial", oStruMst, "FINANCIALMASTER" )
oView:SetOwnerView("ViewFinancial","MST")
oView:EnableTitleView("ViewFinancial",STR0009) //"Pagamento Financiado"

Return oView


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStruMst)

Default oStruMst 	:= Nil

oStruMst:AddField(	STR0010		,; //[01] Titulo do campo
						STR0010		,; //[02] Desc do campo
						"L4_FILIAL"	,; //[03] Id do Field
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
						.F.				)  //[14] Indica se o campo e virtual


oStruMst:AddField(	STR0002		,; //[01] Titulo do campo
						STR0002		,; //[02] Desc do campo
						"L4_VALOR"	,; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						16			,; //[05] Tamanho do campo
						2			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual
						
oStruMst:AddField(	STR0014	,; //[01] Titulo do campo
						STR0014	,; //[02] Desc do campo
						"L4_DATA",; //[03] Id do Field
						"D"			,; //[04] Tipo do campo
						8			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,"dDataBase" )			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual			
						
oStruMst:AddField(	STR0012	,; //[01] Titulo do campo
						STR0012	,; //[02] Desc do campo
						"L4_PARCELA",; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						2			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,"1" )			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual		
						
oStruMst:AddField(	STR0013	,; //[01] Titulo do campo
						STR0013	,; //[02] Desc do campo
						"L4_ADMINIS",; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						nTamAdminis,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual							
																					
oStruMst:AddField(	STR0023	,; //[01] Titulo do campo
						STR0023	,; //[02] Desc do campo
						"L4_NUMCART"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						nTamNumCart	,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual

oStruMst:AddField(	STR0024	,; //[01] Titulo do campo
						STR0024	,; //[02] Desc do campo
						"L4_CODCRM"	,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						16				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual
																					
	If ExistBlock("STISTRUMOD")
		oStruMst := ExecBlock("STISTRUMOD",.F.,.F., {oStruMst})
	Endif

Return oStruMst


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruVie(oStruMst)

Default oStruMst	:= Nil

oStruMst:AddField(	"L4_ADMINIS"		,; //[01] CIDFIELD - ID DO FIELD
						"01"				,; //[02] CORDEM - ORDEM DO CAMPO
						"Adm. Financeira"	,; //[03] CTITULO - TITULO DO CAMPO
						"Administradora Financeira"	,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"C"					,; //[06] CTYPE - TIPO
						"@!"				,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						aAdmFin				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL

oStruMst:AddField( 	"L4_VALOR"			,; //[01] CIDFIELD - ID DO FIELD
						"02"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0002			,; //[03] CTITULO - TITULO DO CAMPO
						STR0002			,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"@E 999,999.99"	,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL
						
oStruMst:AddField(	"L4_DATA"			,; //[01] CIDFIELD - ID DO FIELD
						"03"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0014	,; //[03] CTITULO - TITULO DO CAMPO
						STR0014	,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"D"					,; //[06] CTYPE - TIPO
						""					,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL		
						
oStruMst:AddField(	"L4_PARCELA"			,; //[01] CIDFIELD - ID DO FIELD
						"04"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0012	,; //[03] CTITULO - TITULO DO CAMPO
						STR0012	,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"99"				,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL																														

						
If ExistBlock("STISTRUVIE")
	oStruMst := ExecBlock("STISTRUVIE",.F.,.F., {oStruMst})
Endif

Return oStruMst

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIFiConfPay
Funcao responsavel por confirmar o pagamento em dinheiro 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIFiConfPay(oGetData, oGetValor, oGetParcels, oGetAdmFin,oPnlAdconal,oGetCard,cTpForm)
Local lRet		:= .T.
Local oMdl 		:= FwLoadModel("STIPayFinancial")				//Recupera o model ativo
Local aRetRms := {} //Retorno da integracao de crm da rms 
Local lRMS := SuperGetMv('MV_LJRMS',,.F.) .AND. FindFunction('STFCrmRms') //CRM da Rms 

Default oGetCard := Nil
Default cTpForm	 := ""

oMdl := oMdl:GetModel("FINANCIALMASTER")	

oMdl:DeActivate()
oMdl:Activate()

oMdl:LoadValue("L4_FILIAL", xFilial("MEX"))
oMdl:LoadValue("L4_DATA", oGetData:cText)
oMdl:LoadValue("L4_VALOR", oGetValor:cText)
oMdl:LoadValue("L4_PARCELA", IIF(ValType(oGetParcels)=='O',oGetParcels:cText,1)) 
oMdl:LoadValue("L4_ADMINIS", Iif(oGetAdmFin:nAt > 0,SubStr(oGetAdmFin:aItems[oGetAdmFin:nAt],1,nTamAdminis),lRet := .F.))		

if !lRet
	STFMessage(ProcName(),"STOP",STR0020)//"Nao ha adm. financeira do tipo 'FI' cadastrada"                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	STFShowMessage(ProcName())
EndIf

If cTpForm == "CO" 
	oMdl:LoadValue("L4_NUMCART", cGetCard)
Else
	oMdl:LoadValue("L4_NUMCART", "")
EndIf

If oMdl:GetValue("L4_VALOR") <= 0
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0015) //"O valor deve ser maior que zero"
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. ExistFunc("STIPermTrc") .AND. (oMdl:GetValue("L4_VALOR") + STIGetTotal()) > STDGPBasket("SL1", "L1_VLRTOT") .AND. !STIPermTrc(cTpForm)
	lRet := .F. 
Endif  

If lRet .AND. oMdl:GetValue("L4_DATA") < dDataBase
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0016+CRLF+STR0017)// "A data de pagamento deve "ser maior ou igual a data atual" 
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. oMdl:GetValue("L4_PARCELA") < 1
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0018) //"N∫ de parcelas n„o pode ser zero"
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. Empty(oMdl:GetValue("L4_ADMINIS"))
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0019) //"N∫ de parcelas n„o pode ser zero"
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. lRMS 
	aRetRms := STFCrmRms(AllTrim(cTpAdmin),oGetValor:cText,cGetCard)
	If aRetRms[1]
		lRet := .T.
		If Len(aRetRms) > 0
			oMdl:LoadValue("L4_CODCRM", aRetRms[3])
		EndIf		
	Else
		lRet := .F.
		If ValType(aRetRms[2]) == 'N'		
			Alert(STR0025 + ' ' + AllTrim(Str(aRetRms[2],12,2))) //"O saldo disponivel para compras È R$"
		EndIf
		STIPayCancel()		
		oPnlAdconal:Hide()
	EndIf
EndIf

If lRet 
	If Len(aInfoImport) > 0
		If oMdl:GetValue("L4_VALOR") <> aInfoImport[1] .Or. oMdl:GetValue("L4_PARCELA") <> aInfoImport[2] .Or. oMdl:GetValue("L4_DATA") <> aInfoImport[3]
			lAltImpFi := .T.		
		EndIf
	Endif
	STIAddPay(cTpForm, oMdl, oMdl:GetValue("L4_PARCELA"),.F.)
	oPnlAdconal:Hide()
	STIEnblPaymentOptions()
EndIf
	
Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIFiConfPay
Depois de pesquisar as administradoras, seta para a statica aAdmFin

@param   	aAdms
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetAdm(aAdms)
aAdmFin := aAdms
Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STIFinOrc
Na importacao de orcamentos, carrega informacoes de financiamento.
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	19/11/2014
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIFinOrc(oPnlAdconal, nValue, nParc, cTypeFin, dDateParc)

Local oLblData 	:= Nil              	//Objeto de Label Data
Local oGetData 	:= Nil              	//Objeto de Get Data
Local cGetData	:= dDataBase        	//Recebe valor de oGetData

Local oLblValor	:= Nil              	//Objeto de Label Valor
Local oGetValor	:= Nil              	//Objeto de Get Valor
Local cGetVal		:= STBCalcSald("1") 	//Apresenta o saldo restante do pagamento e recebe valor de oGetValor 

Local oLblParcels	:= Nil              	//Objeto de Label Parcelas
Local oGetParcels	:= Nil             	//Objeto de Get Parcelas
Local cGetParc	:= 1            	  	//Recebe valor de oGetParcels

Local oBtnOk		:= Nil              	//Objeto do botao Ok
Local oBtnCa		:= Nil              	//Objeto do botao Cancelar 

Local oLblAdmFin	:= Nil					//Objeto de Label Adm Financeira
Local oCboAdmFin	:= Nil					//Objeto de Combo Adm Financiera
Local cCboAdmFin	:= ""					//Recebe valor da Adm Financiera

Local aAdmFin		:= {}					//Array onde carrega as administradoras financeiras
Local lReadOnly		:= FindFunction("STIGetPayRO") .AND. STIGetPayRO()	//indica se os campos de pagamento est„o como Somente Leitura (permiss„o Alterar Parcelas do caixa)
Local aEditField	:= {} //Array para controle de ediÁ„o dos campos que poderao ser editados pelo usuario nesta tela de forma de pagamento "FINANCIADO".

Default oPnlAdconal := Nil
Default nValue 		:= 0
Default nParc		:= 0
Default cTypeFin	:= ""
Default dDateParc	:= CtoD("  /  /  ")

//Valor
If nValue > 0
	cGetVal := nValue
EndIf

//Parcelas
If nParc > 0
	cGetParc := nParc
EndIf

//Data da Parcela
If !Empty(dDateParc)
	cGetData := dDateParc
EndIf

aInfoImport := {nValue, nParc, dDateParc,cTypeFin}

//Busca Adm. Financeira		
aAdmFin := STDAdmFinan(cTypeFin)

//Campos que poder„o ser edit·veis ou n„o na tela
//            		Nome do campo	, Valor Inicial do Campo	, Permite Editar (.T.=Sim, .F.=Nao)
aAdd( aEditField, {	STR0001			, cGetData					, !lReadOnly} ) //Campo "Data"
aAdd( aEditField, {	STR0002			, cGetVal					, !lReadOnly} ) //Campo "Valor"
aAdd( aEditField, {	STR0003			, cGetParc					, !lReadOnly} ) //Campo "Parcelas"

//Ponto de Entrada que controla os campos que poderao ser editados nesta tela de forma de pagamento "FINANCIADO".
//Este P.E. tambem permite definir o valor inicial do campo quando carregada a tela. 
If ExistBlock("STIFINAN")
	aEditField	:= ExecBlock("STIFINAN",.F.,.F.,aEditField)
	//Atribui ‡s variaveis o valor inicial dos campos
	cGetData 	:= aEditField[1][2]
	cGetVal		:= aEditField[2][2]
	cGetParc	:= aEditField[3][2]
EndIf

/* Label e Get: Data */
oLblData := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,, ,,,,.T.,,,,8) //'Data'
oGetData := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetData:=u,cGetData)},oPnlAdconal,LARG_GET_DATE,ALTURAGET,,,,,,,,.T.,,,,,,,!aEditField[1][3])
oLblData:SetCSS( POSCSS (GetClassName(oLblData), CSS_LABEL_FOCAL ))
oGetData:SetCSS( POSCSS (GetClassName(oGetData), CSS_GET_FOCAL ))

 /* Label e Get: Valor */
oLblValor := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL2, {||STR0002}, oPnlAdconal,, ,,,,.T.,,,,8)
oGetValor := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,LARG_GET_VALOR,ALTURAGET,"@E 99,999,999.99",,,,,,,.T.,,,,,,,!aEditField[2][3])
oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_NORMAL )) 

If cTypeFin <> "DC"
	/* Label e Get: Parcelas */
	oLblParcels := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0003}, oPnlAdconal,, ,,,,.T.,,,,8)
	oGetParcels := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetParc:=u,cGetParc)},oPnlAdconal,50,ALTURAGET,"@E 9999",,,,,,,.T.,,,,,,,!aEditField[3][3])
	oLblParcels:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
	oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_NORMAL )) 
EndIf
/* Label e Get: Administradora Financeira */
oLblAdmFin := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL2, {||STR0004}, oPnlAdconal,, ,,,,.T.,,,,8) //'Adm.Financeira'
oCboAdmFin := TComboBox():New(POSVERT_PAYGET2, POSHOR_PAYCOL2, {|u| If(PCount()>0,cCboAdmFin:=u,cCboAdmFin)}, aAdmFin, 100, ALTURAGET, oPnlAdconal, Nil , /* bChange */, /* bValid*/, /* nClrBack*/, /* nClrText*/, .T./* lPixel*/,  , Nil, Nil, /* bWhen*/, Nil, Nil, Nil, Nil, cCboAdmFin, /* cLabelText*/ ,/* nLabelPos*/,  , /*nLabelColor*/  )	
oLblAdmFin:SetCSS( POSCSS (GetClassName(oLblAdmFin), CSS_LABEL_FOCAL )) 
oCboAdmFin:SetCSS( POSCSS (GetClassName(oCboAdmFin), CSS_GET_FOCAL )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0005,oPnlAdconal,{|| STIFiConfPay(oGetData, oGetValor, oGetParcels, oCboAdmFin, oPnlAdconal, Nil, cTypeFin) },LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento' 

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0006,oPnlAdconal,{|| Iif( ExistFunc("STBCancPay"), IIF(STBCancPay(),STIPayCancel() ,Nil),STIPayCancel()) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

oGetData:SetFocus()

Return Nil

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIChgDtFinancial
Funcao responsavel por alterar a data de validade da parcela do financiado 

@param   	
@author  	Vendas & CRM
@version 	P11
@since   	29/04/2015
@return  	.T.
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIChgDtFinancial(oAdmFin,oGetData,cGetData)
Local cCodAdm	:= ""
Local dData	:= dDataBase

If oAdmFin:nAt <> 1 .And. FindFunction("STDVencAdmFin")
	cCodAdm := SubStr(oAdmFin:aItems[oAdmFin:nAt], 1, nTamAdmCod)
	dData	 := STDVencAdmFin(cCodAdm,dData)
EndIf

If !Empty(dData)
	cGetData := dData
	oGetData:cText(dData)
	oGetData:Refresh()
EndIf

Return .T.

/*/{Protheus.doc} STIGFiAltImp
	Retorna se os dados do orÁamento importado foi alterado tipo FI
	@type  Function
	@author bruno.inoue
	@since 26/09/2017
	@version 12.1.17
	@param 
	@return lAltImpFi
/*/
Function STIGFiAltImp()
Return lAltImpFi

/*/{Protheus.doc} STISFiAltImp
	Seta valor para variavel de alteraÁ„o do orÁamento do tipo FI 
	@type  Function
	@author bruno.inoue
	@since 26/09/2017
	@version 12.1.17
	@param 
	@return 
/*/
Function STISFiAltImp(lValue)
Default lValue := .F.
lAltImpFi := lValue
Return 
