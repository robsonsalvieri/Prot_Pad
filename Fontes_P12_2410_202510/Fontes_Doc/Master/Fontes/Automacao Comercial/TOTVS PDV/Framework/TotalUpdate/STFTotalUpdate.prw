#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static oNewModel	:= Nil			//Objeto para instanciar o model
Static aField 		:= STFFields()	//Preenche o array com os campos do model 
Static oStructSL1	:= Nil
Static oModelMaster := NIL 			//model Master
Static nL1ValMer    := 0
Static nL1VlrTot    := 0
Static nL1Des       := 0
Static nL1DesNF     := 0
Static nL1VlrLiq    := 0
Static nL1ValBru    := 0
Static nL1Juros     := 0
Static nL1Bonif		:= 0   

//-------------------------------------------------------------------
/*/{Protheus.doc} STDTotUpd
Funcao responsavel em atualizar os valores contidos no model

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFTotUpd()

If !( Len( aField ) > 0 )
	aField 		:= STFFields()
EndIF

oNewModel := STFEstrTot()
oNewModel:SetOperation( 3 )
oNewModel:SetDescription("TOTAIS")
oNewModel:SetPrimaryKey({"L1_NUM"})
oNewModel:Activate()
					
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGetTot
Funcao responsavel em chamar a criacao do master e grid

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	oModel - Retorna o model com toda a estrutura criada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFEstrTot()

Local oModel 		:= Nil	// Model
Local oMasterStr	:= Nil
	
//Monta estrutura de tabela de cabecario	
oMasterStr := STFMstStr()

//Instacia Objeto
oModel	:= 	MPFormModel():New( 'SL1', /*bPreValidacao*/, /*bPosValidacao*/,/*{ |oMdl| xFRT80MVCGR( oMdl ) }*/, /*bCancel*/ )

oModel:AddFields( "MasterStr", /*cOwner*/,  oMasterStr ) 
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} STFMstStr
Criando a estrutura do master

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	oStruct - Retorna a estrutura   	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFMstStr()

Local nI		:= 0								// Variavel de loop												
Local aArea	 	:= Nil
Local cX2Unico  := "L1_FILIAL+L1_NUM" //X2_UNICO da tabela SL1

If ValType(oStructSL1) = 'O'
	oStructSL1:Deactivate()
	oStructSL1:Activate()
Else
	oStructSL1 := FWFormModelStruct():New() 	// Estrutura

	aArea := GetArea()	// Guarda area
	//Carrega informacoes da Tabela
	SX2->( DbSetOrder( 1 ) )
	SX2->( DbSeek( "SL1" ) )

	If ExistFunc('FWX2Unico') 
		cX2Unico := FWX2Unico("SL1") 
	EndIf

	oStructSL1:AddTable( 							;
				FWX2CHAVE()                				, 	;	// [01] Alias da tabela
				StrTokArr( cX2Unico, '+' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
				FWX2Nome("SL1") )                 					// [03] Descrição da tabela

	RestArea(aArea)

	oStructSL1:AddField( "NUM"  			 	,	; 	// [01] Titulo do campo
	                     "NUM"  			 	,	; 	// [02] Desc do campo
	                     "L1_NUM"  	 			,	; 	// [03] Id do Field
	                     "N"              		,	; 	// [04] Tipo do campo
	                     16					   	,	; 	// [05] Tamanho do campo
	                     2                		, 	; 	// [06] Decimal do campo
	                     Nil             		,	; 	// [07] Code-block de validação do campo
	                     Nil               	,	; 	// [08] Code-block de validação When do campo
	                     Nil 					, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 					, 	; 	// [10] Indica se o campo tem preenchimento obrigatório
	                     Nil              		, 	; 	// [11] Code-block de inicializacao do campo
	                     Nil             		, 	; 	// [12] Indica se trata-se de um campo chave
	                     Nil              		,  	; 	// [13] Indica se o campo pode receber valor em uma operação de update.
	               		)             			  	// [14] Indica se o campo é virtual 

	For nI := 1 To Len(aField)

	  	oStructSL1:AddField(						 ;
	                     aField[nI][1]   	,; 	// [01] Titulo do campo
	                     aField[nI][1]  	,; 	// [02] ToolTip do campo
	                     aField[nI][2]   	,; 	// [03] Id do Field
	                     aField[nI][3]   	,; 	// [04] Tipo do campo
	                     aField[nI][4]   	,; 	// [05] Tamanho do campo
	                     aField[nI][5]   	,; 	// [06] Decimal do campo
	                     Nil             	,; 	// [07] Code-block de validação do campo
	                     Nil            	,; 	// [08] Code-block de validação When do campo
	                     Nil              	,; 	// [09] Lista de valores permitido do campo
	                     Nil 				,; 	// [10] Indica se o campo tem preenchimento obrigatório
	                     Nil             	,; 	// [11] Code-block de inicializacao do campo
	                     Nil             	,; 	// [12] Indica se trata-se de um campo chave
	                     Nil            	,; 	// [13] Indica se o campo pode receber valor em uma operação de update.
	                     Nil             	)  	// [14] Indica se o campo é virtual

	Next nI
EndIf

Return oStructSL1


//-------------------------------------------------------------------
/*/{Protheus.doc} STFFields
Retorna o array com os campos a serem add no model

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	aFils - Retorna os campos que estarao composto no model	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFFields()

Local nX	  := 0
Local aFils := {	{"TOTAL"		, "L1_VLRTOT"	, Nil, Nil, Nil, "NF_TOTAL"		},;	//01
				  	{"DESCONTO"		, "L1_DESCONT"	, Nil, Nil, Nil, "NF_DESCTOT"	},;	//02 - Totalizador de descontos no total (Ex. CTRL + B)
				 	{"VL. LIQUIDO"	, "L1_VLRLIQ"	, Nil, Nil, Nil, ""				},;	//03
				 	{"VL. BRUTO"	, "L1_VALBRUT"	, Nil, Nil, Nil, ""				},;	//04
				 	{"VL. MERCAD"	, "L1_VALMERC"	, Nil, Nil, Nil, "NF_VALMERC"	},;	//05
				 	{"VL. DESC NF"	, "L1_DESCNF"	, Nil, Nil, Nil, ""				},;	//06
				 	{"ENTRADA"		, "L1_ENTRADA"	, Nil, Nil, Nil, ""				},;	//07
				 	{"JUROS"		, "L1_JUROS"	, Nil, Nil, Nil, ""				},;	//08
				 	{"VL. ICM"		, "L1_VALICM"	, Nil, Nil, Nil, "NF_VALICM"	},;	//09
				 	{"VL. IPI"		, "L1_VALIPI"	, Nil, Nil, Nil, "NF_VALIPI"	},;	//10
				 	{"VL. ISS"		, "L1_VALISS"	, Nil, Nil, Nil, "NF_VALISS"	},;	//11
				 	{"CREDITO"		, "L1_CREDITO"	, Nil, Nil, Nil, ""				},;	//12
				 	{"FRETE"		, "L1_FRETE"	, Nil, Nil, Nil, ""				},;	//13
				 	{"SEGURO"		, "L1_SEGURO"	, Nil, Nil, Nil, ""				},;	//14
				 	{"DESPESA"		, "L1_DESPESA"	, Nil, Nil, Nil, ""				},;	//15
				 	{"PESO LIQUID"	, "L1_PLIQUI"	, Nil, Nil, Nil, ""				},;	//16
				 	{"PESO BRUTO"	, "L1_PBRUTO"	, Nil, Nil, Nil, ""				},;	//17
				 	{"VOLUME"		, "L1_VOLUME"	, Nil, Nil, Nil, ""				},;	//18
				 	{"TROCO"		, "L1_TROCO1"	, Nil, Nil, Nil, ""				},;	//19
				 	{"BR ICMS"		, "L1_BRICMS"	, Nil, Nil, Nil, "NF_VALICM"	},;	//20
				 	{"ABTO PCC"		, "L1_ABTOPCC"	, Nil, Nil, Nil, ""				},;	//21
				 	{"VL. PIS"		, "L1_VALPIS"	, Nil, Nil, Nil, "NF_VALPIS"	},;	//22
				 	{"VL COFI"		, "L1_VALCOFI"	, Nil, Nil, Nil, "NF_VALCOF"	},;	//23
				 	{"VA. CSLL"		, "L1_VALCSLL"	, Nil, Nil, Nil, "NF_VALCSL"	},;	//24
				 	{"ACRESCIMO"	, "L1_ACRSFIN"	, "N", 14, 2   , "NF_ACRESCI"	},;	//25 - É referenciado do L4 apenas para o tamanho do campo por nao existir no L1. RONDON - referenciei direto pq o campo nao existe no ambiente colombia. Ver atusx, acho que criei por upd
					{"TOT NFISCAL"	, "L1_NOTFISCAL", "N", 14, 2   , ""				},;	//26 - Totalizador Não-Fiscal
					{"VL. JUROS"	, "L1_VLRJUR"	, "N", 16, 2   , ""				},;	//27 - Valor dos juros
					{"TOT DESC. IT"	, "L1_DESCIT"	, "N", 16, 2   , "NF_DESCONTO"	},;	//28 - Totalizador de descontos nos itens
					{"DESC. NF."	, "L1_DESCFIN"	, "N", 16, 2   , ""				},; //29 - Valor do Desconto Financeiro 
					{"BONIF."		, "L1_BONIF"	, "N", 16, 2   , ""				},; //30 - Bonificação 
					{"TOT NFIS RPS.", "L1_NOTFISRPS", "N", 16, 2   , ""				},; //31 - Totalizador Não-Fiscal de Serviços (RPS)
					{"Arm.Des.Total", "L1_ARMDESC"  , "N", 16, 2  , ""				}}  //32 - Total de Desconto aplicado na Venda para regra de desconto do varejo. 

                    								
dbSelectArea("SX3")
dbSetOrder(2)

//Preenche as colunas Tipo, Tamanho e Decimal do array aFils
For nX := 1 To Len(aFils)
	If SX3->(DbSeek(aFils[nX][2]))
		aFils[nX][3] := SX3->X3_TIPO		
		aFils[nX][4] := SX3->X3_TAMANHO
		aFils[nX][5] := SX3->X3_DECIMAL			
	EndIf	  		  
Next

Return aFils


//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetTot
Retorna o objeto do model com todos os totais definidos

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	oTotal	 - Objeto de total
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFGetTot()

If ValType( oModelMaster ) <> "O" .AND. ValType( oNewModel ) == "O"
	oModelMaster := oNewModel:GetModel("MasterStr")
EndIf

Return oModelMaster


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetTot
Add valor as colunas que não foram alimentadas pela rotina da MatxFis

@param   	cField - Campo a ser alimentado com o novo valor
@param   	nValue - Valor a ser add ao novo campo
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSetTot( cField , nValue )

Default cField := ""
Default nValue := 0

ParamType 0 Var 	cField 	As Character	Default 	""
ParamType 1 Var 	nValue 		As Numeric	Default 	0

If oModelMaster = NIL
	oModelMaster := oNewModel:GetModel("MasterStr")
EndIf

oModelMaster:SetValue(cField, nValue)
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFRefTot
Atualiza os valores de totais da MatxFis

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	Nil	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFRefTot(nDescTot)
Local nX := 0 //Variavel de loop

Default nDescTot := 0 

If oModelMaster = NIL .OR. ValType( oModelMaster ) <> "O"
	oModelMaster := oNewModel:GetModel("MasterStr")
EndIf
 
For nX := 1 To Len(aField)
	If aField[nX][6] <> ""
		oModelMaster:SetValue(aField[nX][2], STBTaxRet( Nil, aField[nX][6] ))		
	EndIf	
Next nX

/*/
	Atualiza os totais
/*/
STBValues(nDescTot)
	      
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFTotRestart
Reinicia o Totalizador

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return	Nil	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFTotRestart()

oNewModel:DeActivate()
oNewModel:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSaleTotal
Retorna o Total da venda
@param   cFieldTot	- Campo do total - Opcional
@author  Varejo
@version P11.8
@since   29/03/2012
@return nTotSale Retorna o total da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSaleTotal( cFieldTot )

Local nTotSale 		:= 0  					// Retorna total da venda
Local oTotal 		:= STFGetTot()		// Recebe o Objeto totalizador

Default cFieldTot := "L1_VLRTOT"		// Campo do total

If !Empty(cFieldTot)
	nTotSale := oTotal:GetValue( cFieldTot )
EndIf	

Return nTotSale

//-------------------------------------------------------------------
/*/{Protheus.doc} STFBkpTot
Guarda os valores antes da seleção da forma de pagamento
@param
@author  Varejo
@version P12
@since   17/04/2017
@return nTotSale Retorna o total da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFBkpTot()

Local oTotal        := STFGetTot()      // Recebe o Objeto totalizador

nL1ValMer   := oTotal:GetValue( "L1_VALMERC"   )
nL1VlrTot   := oTotal:GetValue( "L1_VLRTOT"    )
nL1Des      := oTotal:GetValue( "L1_DESCONT"   )
nL1DesNF    := oTotal:GetValue( "L1_DESCNF"    )
nL1VlrLiq   := oTotal:GetValue( "L1_VLRLIQ"    )
nL1ValBru   := oTotal:GetValue( "L1_VALBRUT"   )
nL1Juros    := oTotal:GetValue( "L1_JUROS"     )
nL1Bonif	:= oTotal:GetValue( "L1_BONIF"     )   

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STFRestVlr
Restaura os valores antes da seleção da forma de pagamento
@param
@author  Varejo
@version P12
@since   17/04/2017
@return nTotSale Retorna o total da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFRestVlr()

/*/
    Atualiza totalizador
/*/
STFSetTot( "L1_VLRLIQ"  , nL1VlrLiq )
STFSetTot( "L1_VALBRUT" , nL1ValBru )
STFSetTot( "L1_DESCONT" , nL1Des    )
STFSetTot( "L1_VLRTOT"  , nL1VlrTot ) // Adiciona no VLRTOT por ultimo para nao duplicar
STFSetTot( "L1_BONIF"	, nL1Bonif  )

/*/
    Porcentagem de Desconto no Total
/*/
STFSetTot( "L1_DESCNF"  , STBDiscConvert(nL1Des, "V", nL1ValBru )[2] )

/*/
    Atualiza Cesta
/*/
STDSPBasket(    "SL1"   ,   "L1_VALMERC"    ,   nL1ValMer   )
STDSPBasket(    "SL1"   ,   "L1_VLRTOT"     ,   nL1VlrTot   )                                                                              
STDSPBasket(    "SL1"   ,   "L1_DESCONT"    ,   nL1Des      )
STDSPBasket(    "SL1"   ,   "L1_DESCNF"     ,   nL1DesNF    )
STDSPBasket(    "SL1"   ,   "L1_VLRLIQ"     ,   nL1VlrLiq   )
STDSPBasket(    "SL1"   ,   "L1_VALBRUT"    ,   nL1ValBru   )
STDSPBasket(    "SL1"   ,   "L1_JUROS"      ,   nL1Juros    )
STDSPBasket(    "SL1"   ,   "L1_BONIF"      ,   nL1Bonif    )

If ExistFunc("STIAtuRoda")
	STIAtuRoda()// Função presente no fonte STIPosMain
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STFTotRelease
Libera os objetos de totais da venda
@param
@author  Varejo
@version P12
@since   26/07/2017
@return 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFTotRelease()

If ValType(oNewModel) == "O"
	oNewModel	:= FreeObj(oNewModel)		//Objeto para instanciar o model
EndIf
aField 		:= {}	//Preenche o array com os campos do model 

If ValType(oStructSL1) == "O"
	oStructSL1	:= FreeObj(oStructSL1)
EndIf
If ValType(oModelMaster) == "O"
	oModelMaster := FreeObj(oModelMaster)  			//model Master
EndIf
nL1ValMer	:= 0
nL1VlrTot	:= 0
nL1Des		:= 0
nL1DesNF	:= 0
nL1VlrLiq	:= 0
nL1ValBru	:= 0
nL1Juros	:= 0
nL1Bonif	:= 0   

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFTotalServ
Retorna o Total de Servicos da venda
@author  alessandrosantos
@version P11.8
@since   21/08/2017
@return nTotServ Retorna o total de servicos da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFTotalServ()

Local nTotServ := 0  // Retorna total de servicos da venda
Local nX	   := 0

For nX := 1 To STDPBLength("SL2")
	If !STDPBIsDeleted("SL2", nX) .And. LjIsTesISS(STDGPBasket("SL2", "L2_PRODUTO", nX), STDGPBasket("SL2", "L2_TES", nX)) 			
		nTotServ += STBTaxRet(nX, "IT_TOTAL")		
	EndIf
Next nX

Return nTotServ
