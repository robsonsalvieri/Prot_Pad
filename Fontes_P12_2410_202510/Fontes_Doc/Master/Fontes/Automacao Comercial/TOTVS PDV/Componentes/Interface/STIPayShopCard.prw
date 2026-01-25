#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIPAYSHOPCARD.CH"

Static lShopCard := .F.							
Static cPicValor   := PesqPict("SL4","L4_VALOR")
Static cPicParcela := PesqPict("SL1","L1_PARCELA")
Static nTamNumCart := TamSX3("L4_NUMCART")[1]


//-------------------------------------------------------------------
/*{Protheus.doc} STIShopCard
Retorna True caso o shop card esteja sendo utilizado na venda e reinicia variavel estatica.

@author  Vendas & CRM
@version P11.80
@since   11/03/2013
@return  lRet			- 	Retorna True caso o ShopCard tenha sido utilizado na venda.
*/
//-------------------------------------------------------------------

Function STIShopCard()
Local lRet := .F.

If lShopCard
	lShopCard 	:= .F.
	lRet		:= .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/* {Protheus.doc} STIShopCardPayment
Chama a tela responsavel pela utilizacao do ShopCard como forma de pagamento.

@author  Vendas & CRM
@version P11.80
@since   08/03/2013
@return  lRet			- 	Retorna True caso o ShopCard tenha saldo disponivel para a venda.
*/
//-------------------------------------------------------------------
Function STIPayShopCard(oPnlAdconal)

Local oLblData 		:= Nil               //Objeto de Label Data
Local oGetData 		:= Nil               //Objeto de Get Data
Local cGetData		:= dDataBase         //Recebe valor de oGetData

Local oLblValor		:= Nil               //Objeto de Label Valor
Local oGetValor		:= Nil               //Objeto de Get Valor
Local cGetVal		:= STBCalcSald("1")	 //Apresenta o saldo restante do pagamento e recebe valor de oGetValor 

Local oLblParcels	:= Nil               //Objeto de Label Parcelas
Local oGetParcels	:= Nil               //Objeto de Get Parcelas
Local cGetParc	 	:= 1                 //Recebe valor de oGetParcels 

Local oLblNumCar 	:= Nil               //Objeto de Label Numero do Cartao
Local oGetNumCar 	:= Nil               //Objeto de Get Numero do Cartao
Local cGetNumCar	:= Space(nTamNumCart)//Recebe valor de oGetNumCar

Local oBtnOk		:= Nil               //Objeto do botao Ok
Local oBtnCa		:= Nil               //Objeto do botao Cancelar


 /* Label e Get: Data */
oLblData := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,, ,,,,.T.,,,,8) //'Data'
oGetData := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetData:=u,cGetData)},oPnlAdconal,LARG_GET_DATE,ALTURAGET,,,,,,,,.T.)
oLblData:SetCSS( POSCSS (GetClassName(oLblData), CSS_LABEL_FOCAL )) 
oGetData:SetCSS( POSCSS (GetClassName(oGetData), CSS_GET_FOCAL )) 

 /* Label e Get: Valor */
oLblValor := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL2, {||STR0002}, oPnlAdconal,, ,,,,.T.,,,,8) //'Valor'
oGetValor := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,LARG_GET_VALOR,ALTURAGET,cPicValor,,,,,,,.T.)
oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_FOCAL )) 

/* Label e Get: Parcelas */
oLblParcels := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0003}, oPnlAdconal,, ,,,,.T.,,,,8) //'Parcelas'
oGetParcels := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetParc:=u,cGetParc)},oPnlAdconal,40,ALTURAGET,cPicParcela,,,,,,,.T.)
oLblParcels:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL )) 

 /* Label e Get: Numero Cartao */
oLblNumCar := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL2, {||STR0004}, oPnlAdconal,, ,,,,.T.,,,,8) //'Num. Cart„o'
oGetNumCar := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetNumCar:=u,cGetNumCar)},oPnlAdconal,100,ALTURAGET,,,,,,,,.T.)
oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL )) 
oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0005,oPnlAdconal,{|| STISCConfPay(oGetData, oGetValor, oGetParcels, oGetNumCar,oPnlAdconal)},LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0006,oPnlAdconal,{|| STIPayCancel(oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL)) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO ))  

oGetData:SetFocus()

Return  

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author leandro.dourado
@since 08/03/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructSL4 := STIModelStruct()
Local oModel     := MPFormModel():New("STIPayShopCard",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

//-----------------------------------------
//Monta o modelo do formul·rio 
//-----------------------------------------
oModel:AddFields("SL4MASTER", Nil/*cOwner*/, oStructSL4 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetDescription( STR0007 )//"Pagamento com cart„o fidelidade"
oModel:GetModel("SL4MASTER"):SetDescription(STR0008) //"Cart„o Fidelidade"
oModel:SetPrimaryKey({"L4_FILIAL+L4_NUMCART+L4_ITEM"})

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author leandro.dourado
@since 08/03/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel("STIPayShopCard")
Local oStructSL4 := STIViewStruct()

//-----------------------------------------
//Monta o modelo da interface do formul·rio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
 
oView:AddField( "VIEW_SL4" , oStructSL4,"SL4MASTER" )

oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "VIEW_SL4" , "HEADER" )
oView:EnableTitleView	('VIEW_SL4'	,STR0007) //"Pagamento com Cart„o Fidelidade"
                
Return oView

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STBModelStruct
Monta a estrutura do model
 	
@author  	Vendas & CRM
@version 	P12
@since   	15/02/2013
@return  	oStruct - Retorno da estrutura
@obs     
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STIModelStruct()
Local oStruct := FWFormModelStruct():New()

oStruct:AddTable("SL4",{"L4_FILIAL"},"Pagamento")

oStruct:AddField(		"Filial"		,; //[01] Titulo do campo
						"Filial"		,; //[02] Desc do campo
						"L4_FILIAL"		,; //[03] Id do Field
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

oStruct:AddField(		"Valor"		,; //[01] Titulo do campo
						"Valor"		,; //[02] Desc do campo
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
						
oStruct:AddField(		"Data"		,; //[01] Titulo do campo
						"Data"		,; //[02] Desc do campo
						"L4_DATA"	,; //[03] Id do Field
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
						
oStruct:AddField(		"Num. Parcelas"	,; //[01] Titulo do campo
						"Num. Parcelas"	,; //[02] Desc do campo
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
						
oStruct:AddField(		"Numero do Cart„o"	,; //[01] Titulo do campo
						"Numero do Cart„o"	,; //[02] Desc do campo
						"L4_NUMCART",; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						20			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual	                                                    

Return oStruct

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruView
Monta a estrutura do model

@param   	oStruMst - Parametro que recebe a estrutura dos campos do model
@param   	cType - Verifica se a estrutura 'e do model master ou grid   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	oStruMst - Retorno da estrutura
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIViewStruct()
Local oStruct 	:= FWFormViewStruct():New()

oStruct:AddField(  	"L4_NUMCART"                 	,; // [01] cIdField            ID do Field
	                 	"1"                         	,; // [02] cOrdem              Ordem do campo
	                 	"Num Cart„o"              		,; // [03] cTitulo             TÌtulo do campo
	                 	"Numero do Cart„o"            	,; // [04] cDescric            DescriÁ„o completa do campo
	                 	NIL                         	,; // [05] aHelp                  Array com o help dos campos
	                 	"C"                         	,; // [06] cType               Tipo
	                 	PesqPict("SL4","L4_NUMCART")	,; // [07] cPicture            Picture do Campo
	                 	Nil                       	,; // [08] bPictVar           Bloco de Picture var
	                 	Nil                        	,; // [09] cLookup             Chave para ser usado no Looup
	                 	.T.                         	,; // [10] lCanChange            LÛgico dizendo se o campo pode ser alterado
	                	Nil                         	,; // [11] cFolder             Id da folder onde o Field est·
	                	NIL                         	,; // [12] cGroup              Id do Group onde o field est·
	               	NIL                         	,; // [13] aCaomboValues Array com os valores do combo
                   	NIL                         	,; // [14] nMaxLenCombo      Tamanho m·ximo da maior opÁ„o do combo
                   	NIL                       	,; // [15] cIniBrow            Inicializador do Browse
                   	NIL                        	,; // [16] lVirtual            Indica se o campo È Virtual
                   	NIL                       	,; // [17] cPictVar            Picture Vari·vel
                   	NIL                        	)  // [18] lInsertLine      Indica pulo de linha apÛs o campo 
                   
oStruct:AddField( 	"L4_VALOR"						,; //[01] CIDFIELD - ID DO FIELD
						"02"							,; //[02] CORDEM - ORDEM DO CAMPO
						"Valor"							,; //[03] CTITULO - TITULO DO CAMPO
						"Valor"							,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}								,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"								,; //[06] CTYPE - TIPO
						"@E 999,999.99"					,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil								,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""								,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.								,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil								,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil								,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil								,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil								,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil								,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.								,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil								)  //[17] CPICTVAR - PICTURE VARIAVEL
						
oStruct:AddField(		"L4_DATA"						,; //[01] CIDFIELD - ID DO FIELD
						"03"							,; //[02] CORDEM - ORDEM DO CAMPO
						"Data"							,; //[03] CTITULO - TITULO DO CAMPO
						"Data"							,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}								,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"D"								,; //[06] CTYPE - TIPO
						""								,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil								,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""								,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.								,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil								,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil								,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil								,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil								,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil								,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.								,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil								)  //[17] CPICTVAR - PICTURE VARIAVEL		
						
oStruct:AddField(		"L4_PARCELA"					,; //[01] CIDFIELD - ID DO FIELD
						"04"							,; //[02] CORDEM - ORDEM DO CAMPO
						"Num. Parcelas"					,; //[03] CTITULO - TITULO DO CAMPO
						"Num. Parcelas"					,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
						{}								,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"								,; //[06] CTYPE - TIPO
						"99"							,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil								,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""								,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.								,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil								,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil								,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil								,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil								,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil								,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.								,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil								)  //[17] CPICTVAR - PICTURE VARIAVEL
       
Return oStruct   

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruView
Monta a estrutura do model

@param   	oStruMst - Parametro que recebe a estrutura dos campos do model
@param   	cType - Verifica se a estrutura 'e do model master ou grid   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	oStruMst - Retorno da estrutura
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISCConfPay(oGetData, oGetValor, oGetParcels, oGetNumCar,oPnlAdconal)

Local oMdl 		:= FwLoadModel("STIPayShopCard")				//Recupera o model ativo
Local lRet 		:= .T.
Local cNumCart	:= AllTrim(oGetNumCar:cText)
Local nValor	:= oGetValor:cText
Local dDataPag	:= oGetData:cText   
Local nParcelas	:= oGetParcels:cText

oMdl := oMdl:GetModel("SL4MASTER")

oMdl:DeActivate()
oMdl:Activate()

oMdl:LoadValue("L4_FILIAL"	, xFilial("MEX"))
oMdl:LoadValue("L4_DATA"	, dDataPag)
oMdl:LoadValue("L4_VALOR"	, nValor)
oMdl:LoadValue("L4_PARCELA"	, nParcelas)
oMdl:LoadValue("L4_NUMCART"	, cNumCart)

lRet := STBVldSCPayment(cNumCart,nValor,dDataPag,nParcelas)

If lRet 
	STIAddPay("FID",oMdl,nParcelas,.F.) 
	lShopCard := .T.
	oPnlAdconal:Hide()
	STIEnblPaymentOptions()
EndIf

Return lRet
