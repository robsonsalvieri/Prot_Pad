#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 

Static aRecSaldo		:= {}		//Array que armazenara o saldo inserido no cartao fidelidade
Static lLjcFid		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()//Indica se a recarga de cartao fidelidade esta ativa


//-------------------------------------------------------------------
/*/{Protheus.doc} STBShopCard
STBShopCard
@author Varejo
@version P11.8
@since   	15/02/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBShopCard()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
MVC - Camada de modelo de dados
@author Varejo
@version P11.8
@since   	15/02/2013
@return  	ExpO1 = oModel
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruMBP := STBModelStruct()		//	Estrutura MBP
Local oModel   := MPFormModel():New('STBSHOPCARD',/*bPreValid*/,/*bPosValid*/,/*Commit*/) // Model

oModel:AddFields('MBPDETAIL',Nil, oStruMBP )
oModel:SetDescription( "Recarga de cartão fidelidade" )//"Recarga de cartão fidelidade"
oModel:GetModel("MBPDETAIL"):SetDescription("Recarga de cartão fidelidade")
oModel:SetPrimaryKey({"MBP_FILIAL+MBP_NUMCAR+MBP_ITEM"})

Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBModelStruct
Monta a estrutura do model
 	
@author Varejo
@version P11.8
@since   	15/02/2013
@return  	oStruct - Retorno da estrutura
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBModelStruct()

Local oStruct := FWFormModelStruct():New()		//	Struct

oStruct:AddField(	"Num Cartão"         				,     ; // [01] Titulo do campo
	             	"Numero do Cartão"         	,     ; // [02] Desc do campo
	              	"MBP_NUMCAR"       				,     ; // [03] Id do Field
	              	"C"              				,     ; // [04] Tipo do campo
                  TamSx3("MBP_NUMCAR")[1]  		,     ; // [05] Tamanho do campo
                  0               					,     ; // [06] Decimal do campo
                  Nil									,     ; // [07] Code-block de validacao do campo 
                  Nil              				,     ; // [08] Code-block de validacao When do campo
                  Nil              				,     ; // [09] Lista de valores permitido do campo
                  .T.             					,     ; // [10] Indica se o campo tem preenchimento obrigatorio
                  Nil									,     ; // [11] Code-block de inicializacao do campo
                  NIL             					,     ; // [12] Indica se trata-se de um campo chave
                  NIL            					,     ; // [13] Indica se o campo pode receber valor em uma operacao de update.
                  .F.             					)       // [14] Indica se o campo e virtual 
                  
oStruct:AddField(	"Val.Recarga"         				,     ; // [01] Titulo do campo
	             	"Valor da Recarga"         	,     ; // [02] Desc do campo
	              	"MBP_VALOR"       				,     ; // [03] Id do Field
	              	"N"              				,     ; // [04] Tipo do campo
                  TamSx3("MBP_VALOR")[1]  			,     ; // [05] Tamanho do campo
                  2               					,     ; // [06] Decimal do campo
                  Nil 								,     ; // [07] Code-block de validacao do campo 
                  Nil              				,     ; // [08] Code-block de validacao When do campo
                  Nil              				,     ; // [09] Lista de valores permitido do campo
                  .T.             					,     ; // [10] Indica se o campo tem preenchimento obrigatorio
                  Nil									,     ; // [11] Code-block de inicializacao do campo
                  NIL             					,     ; // [12] Indica se trata-se de um campo chave
                  NIL            					,     ; // [13] Indica se o campo pode receber valor em uma operacao de update.
                  .F.             					)       // [14] Indica se o campo e virtual                   
                   
oStruct:AddField(	"Valid.Saldo"         				,     ; // [01] Titulo do campo
	             	"Validade do Saldo"         	,     ; // [02] Desc do campo
	              	"MBP_DTVAL"       				,     ; // [03] Id do Field
	              	"D"              				,     ; // [04] Tipo do campo
                  TamSx3("MBP_DTVAL")[1]  			,     ; // [05] Tamanho do campo
                  0               					,     ; // [06] Decimal do campo
                  Nil									,     ; // [07] Code-block de validacao do campo 
                  Nil              				,     ; // [08] Code-block de validacao When do campo
                  Nil              				,     ; // [09] Lista de valores permitido do campo
                  .T.             					,     ; // [10] Indica se o campo tem preenchimento obrigatorio
	               Nil									,     ; // [11] Code-block de inicializacao do campo
                  NIL             					,     ; // [12] Indica se trata-se de um campo chave
                  NIL            					,     ; // [13] Indica se o campo pode receber valor em uma operacao de update.
                  .F.             					)       // [14] Indica se o campo e virtual                                                     

Return oStruct


//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
MVC - Camada de visualização de dados
@author Varejo
@version P11.8
@since   	15/02/2013
@return  	oView = View
@obs     
@sample
/*/
//-------------------------------------------------------------------


Static Function ViewDef()

Local oStruMBP 		:= STIViewStruct()				//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado	
Local oModel   		:= FWLoadModel( 'STBSHOPCARD' )	//Model	
Local oView     		:= Nil    						//View	

// Cria o objeto de View
oView := FWFormView():New()
oView:SetModel( oModel )

//Adiciona no View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_MBPDETAIL', oStruMBP, 'MBPDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_MBPDETAIL'	, 'SUPERIOR' )
oView:EnableTitleView	('VIEW_MBPDETAIL'	,"Dados da Recarga") //"Dados da Recarga"

Return oView 


//-------------------------------------------------------------------
/*{Protheus.doc} STIStruView
Monta a estrutura do model
@param   	oStruMst - Parametro que recebe a estrutura dos campos do model
@param   	cType - Verifica se a estrutura 'e do model master ou grid   	
@author Varejo
@version P11.8
@since   	30/03/2012
@return  	oStruMst - Retorno da estrutura
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIViewStruct()

Local oStruct 	:= FWFormViewStruct():New()		//	Struct

oStruct:AddField(  "MBP_NUMCAR"                  		,     ; // [01] cIdField            ID do Field
                   "1"                          	,     ; // [02] cOrdem              Ordem do campo
                   "Num Cartão"              		,     ; // [03] cTitulo             Título do campo
                   "Numero do Cartão"              	,     ; // [04] cDescric            Descrição completa do campo
                   NIL                         	,     ; // [05] aHelp                  Array com o help dos campos
                   "C"                          	,     ; // [06] cType               Tipo
                   PesqPict("MBP","MBP_NUMCAR")		,     ; // [07] cPicture            Picture do Campo
                   Nil                       		,     ; // [08] bPictVar           Bloco de Picture var
                   Nil                        		,     ; // [09] cLookup             Chave para ser usado no Looup
                   .T.                         	,     ; // [10] lCanChange            Lógico dizendo se o campo pode ser alterado
                   Nil                         	,     ; // [11] cFolder             Id da folder onde o Field está
                   NIL                          	,     ; // [12] cGroup              Id do Group onde o field está
                   NIL                           	,     ; // [13] aCaomboValues Array com os valores do combo
                   NIL                           	,     ; // [14] nMaxLenCombo      Tamanho máximo da maior opção do combo
                   NIL                           	,     ; // [15] cIniBrow            Inicializador do Browse
                   NIL                           	,     ; // [16] lVirtual            Indica se o campo é Virtual
                   NIL                           	,     ; // [17] cPictVar            Picture Variável
                   NIL                                 ) // [18] lInsertLine      Indica pulo de linha após o campo 
                   
oStruct:AddField(  "MBP_VALOR"                  		,     ; // [01] cIdField            ID do Field
                   "2"                          	,     ; // [02] cOrdem              Ordem do campo
                   "Val.Recarga"              		,     ; // [03] cTitulo             Título do campo
                   "Valor da Recarga"              	,     ; // [04] cDescric            Descrição completa do campo
                   NIL                         	,     ; // [05] aHelp                  Array com o help dos campos
                   "N"                          	,     ; // [06] cType               Tipo
                   PesqPict("MBP","MBP_VALOR")			,     ; // [07] cPicture            Picture do Campo
                   Nil                       		,     ; // [08] bPictVar           Bloco de Picture var
                   Nil                        		,     ; // [09] cLookup             Chave para ser usado no Looup
                   .T.                         	,     ; // [10] lCanChange            Lógico dizendo se o campo pode ser alterado
                   Nil                         	,     ; // [11] cFolder             Id da folder onde o Field está
                   NIL                          	,     ; // [12] cGroup              Id do Group onde o field está
                   NIL                           	,     ; // [13] aCaomboValues Array com os valores do combo
                   NIL                           	,     ; // [14] nMaxLenCombo      Tamanho máximo da maior opção do combo
                   NIL                           	,     ; // [15] cIniBrow            Inicializador do Browse
                   NIL                           	,     ; // [16] lVirtual            Indica se o campo é Virtual
                   NIL                           	,     ; // [17] cPictVar            Picture Variável
                   NIL                                 ) // [18] lInsertLine      Indica pulo de linha após o campo                    

oStruct:AddField(  "MBP_DTVAL"                  		,     ; // [01] cIdField            ID do Field
                   "3"                          	,     ; // [02] cOrdem              Ordem do campo
                   "Valid.Saldo"              		,     ; // [03] cTitulo             Título do campo
                   "Validade do Saldo"              ,     ; // [04] cDescric            Descrição completa do campo
                   NIL                         	,     ; // [05] aHelp                  Array com o help dos campos
                   "D"                          	,     ; // [06] cType               Tipo
                   PesqPict("MBP","MBP_DTVAL")			,     ; // [07] cPicture            Picture do Campo
                   Nil                       		,     ; // [08] bPictVar           Bloco de Picture var
                   Nil                        		,     ; // [09] cLookup             Chave para ser usado no Looup
                   .T.                         	,     ; // [10] lCanChange            Lógico dizendo se o campo pode ser alterado
                   Nil                         	,     ; // [11] cFolder             Id da folder onde o Field está
                   NIL                          	,     ; // [12] cGroup              Id do Group onde o field está
                   NIL                           	,     ; // [13] aCaomboValues Array com os valores do combo
                   NIL                           	,     ; // [14] nMaxLenCombo      Tamanho máximo da maior opção do combo
                   NIL                           	,     ; // [15] cIniBrow            Inicializador do Browse
                   NIL                           	,     ; // [16] lVirtual            Indica se o campo é Virtual
                   NIL                           	,     ; // [17] cPictVar            Picture Variável
                   NIL                                 ) // [18] lInsertLine      Indica pulo de linha após o campo 
       
Return oStruct                           


//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldShopCard
Chama funcao da retaguarda responsavel pela validacao do ShopCard.
@param   cNumCartao		Codigo do cartao Shop Card
@param   dDtValid		Data de validade 
@param   nValor		Valor
@author  Varejo
@version P11.8
@return lRet 		- Retorna True caso o cartao seja valido e falso caso nao seja.
@since   09/10/2012
@obs     
/*/
//-------------------------------------------------------------------
Function STBVldShopCard( cNumCartao , dDtValid , nValor)

Local oModel			:= FwModelActive()	// Model	
Local lRet				:= .T.					//	Retorno
Local lRetComm 			:= {}					//	Retorno comunicacao
Local aParam 			:= {cNumCartao}		//	array de parametros
Local uResult			:= Nil					//	Resultado generico

Default cNumCartao 		:= ""
Default dDtValid 		:= Ctod("")
Default nValor		 	:= 0

ParamType 0 Var 	cNumCartao 		As Character	Default 	""
ParamType 1 Var 	dDtValid			As Date		Default 	CtoD("  /  /  ")
ParamType 2 Var 	nValor 			As Numeric		Default 	0

If Empty(cNumCartao)
	lRet := .F.
	STFMessage(ProcName(),"STOP","Código do cartão não preenchido.")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. dDtValid < dDataBase
	lRet := .F.
	STFMessage(ProcName(),"STOP","A data de validade do saldo deve ser maior ou igual a data atual.")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. nValor <= 0
	lRet := .F.
	STFMessage(ProcName(),"STOP","O valor da recarga deve ser maior que zero.")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet
	If !STBRemoteExecute("Ca280Cart" ,aParam, NIL,.F.	,@uResult	)
	
		// Tratamento do erro de conexao
		STFMessage(ProcName(), "ALERT", "Por falta de comunicação, não será possivel prosseguir com a operação.")
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())	
	Else
		lRetComm := uResult
		uResult := Nil
		lRet := lRetComm
		
		If !lRet
			STFMessage(ProcName(),"STOP","Cartão inválido.")
			STFShowMessage(ProcName())	
			STFCleanMessage(ProcName())	
		EndIf
	EndIf 	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBAvalShopCard
Funcao que avalia se o produto informado é um produto de recarga ShopCard valido.
@param   cItemCode		Codigo do item
@author  Varejo
@version P11.8
@since   09/10/2012
@obs     
@return lRet 		- Retorna True caso o cartao seja valido e falso caso nao seja.
/*/
//-------------------------------------------------------------------
Function STBAvalShopCard( cItemCode )

Local lRet			:= .F.									// Retorno		
Local cProdFid		:= SuperGetMv("MV_LJPFID")			// Parametro com o codigo do produto tipo recarga de cartao fidelidade	
Local aProdFid		:= StrToKarr(cProdFid , "/")  	// Array com os produtos do parametro MV_LJPFID
Local nPosProd		:= 0									// Posicao do produto no array informado durante a venda
Local oServer			:= Nil									// Objeto de comunicacao

Default cItemCode := ""

ParamType 0 Var 	cItemCode 		As Character	Default 	""

If lLjcFid
	
	/* 
	Busco a posicao do produto no array aProdFid, que eh montado a partir do conteudo do parametro MV_LJPFID.
	Se nao existir, significa que o produto nao eh um produto de recarga de cartao fidelidade.
	*/
	nPosProd := Ascan(aProdFid,{|x| AllTrim(x)  == AllTrim(cItemCode)})
	
	If nPosProd > 0
		lRet := .T.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldSCPayment
Funcao responsavel por validar o ShopCard a ser utilizado como forma de pagamento. É avaliado se o cartao é valido e;
se ele tem saldo superior ao valor da compra.
@param   cNumCart		Codigo do ShopCard.
@param   nValorPgto   Valor pagamento
@param   dDataPag 		data pagamento	
@param   nParcelas		numero de parcelas
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - Validou saldo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldSCPayment( cNumCart , nValorPgto , dDataPag , nParcelas )

Local aParam			:= {}		//	Array de parametros
Local lRet 			:= .T.		//	Retorno
Local lRetComm		:= .T.		//	Retorno comunicacao
Local nRetComm		:= 0		//	numero retorno comunicacao
Local uResult			:= Nil		//	Resultado generico 

Default cNumCart 	:= ""
Default nValorPgto 	:= 0
Default dDataPag   	:= Ctod("")
Default nParcelas  	:= 0

ParamType 0 Var 	cNumCart 		As Character	Default 	""
ParamType 1 Var 	nValorPgto 		As Numeric		Default 	0
ParamType 2 Var 	dDataPag		As Date			Default 	CtoD("  /  /  ")
ParamType 3 Var 	nParcelas 		As Numeric		Default 	0

If nValorPgto <= 0 
	lRet := .F.
	STFMessage(ProcName(),"STOP","O valor deve ser maior que zero")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. dDataPag < dDataBase
	lRet := .F.
	STFMessage(ProcName(),"STOP","A data de pagamento deve"+CRLF+"ser maior ou igual a data atual")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet .AND. nParcelas < 1
	lRet := .F.
	STFMessage(ProcName(),"STOP","Deve haver ao menos 1 parcela")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

If lRet 
	If Empty(cNumCart)
		lRet := .F.
		STFMessage(ProcName(),"STOP","Informe o numero do cartao!")
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())
	Else		
		aParam := {cNumCart}
		
		
		/*
		 Verifico se o cartao eh valido
		*/
		
		If !STBRemoteExecute("Ca280Cart" ,aParam, NIL,.F.	,@uResult	)
		
			// Tratamento do erro de conexao
			STFMessage(ProcName(), "ALERT", "Por falta de comunicação, não será possivel prosseguir com a operação.")
			STFShowMessage(ProcName())
			STFCleanMessage(ProcName())
			lRet := .F.
		Else
			lRetComm := uResult
			uResult	  := Nil
			
			If !lRetComm
				lRet := .F.
				STFMessage(ProcName(), "ALERT", "O cartao informado nao existe")
				STFShowMessage(ProcName())	
				STFCleanMessage(ProcName())
			Else
				aParam := {cNumCart}
				
				/*  
		 		 Verifico se o cartao tem saldo suficiente para a venda
				*/
			
				If !STBRemoteExecute("Ca280Calc" ,aParam, NIL,.F.	,@uResult	)
				
					// Tratamento do erro de conexao
					STFMessage(ProcName(), "ALERT", "Por falta de comunicação, não será possivel prosseguir com a operação.")
					STFShowMessage(ProcName())	
					STFCleanMessage(ProcName())
					lRet := .F.
				Else
					nRetComm := uResult
					uResult	  := Nil
					
					If ValType(nRetComm) == "N"
						If nValorPgto > nRetComm
							lRet := .F.					
							STFMessage(ProcName(), "ALERT", "Saldo indisponivel"+CRLF+"Este cartão possui R$"+ cvaltochar(nRetComm) +" de saldo")
							STFShowMessage(ProcName())	
							STFCleanMessage(ProcName())
						EndIf
					Else
						lRet := .F.					
						STFMessage(ProcName(), "ALERT", "Falha na obtencao do saldo do cartao")
						STFShowMessage(ProcName())	
						STFCleanMessage(ProcName())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet
