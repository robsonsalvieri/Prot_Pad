#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIIMPORTSALE.CH"

#DEFINE CTXTSEL "[SELECIONADO] - "

Static oButton 			:= Nil	//Objeto do button
Static oOrcList			:= Nil 	//ListBox Seleção de Orçamento
Static aOptionSales		:= {}	//Armazena opções de irçamento buscadas
Static aViewOptionsSales:= {} 	//Armazena opções de pagamento para apresentação e seleção na view
Static oSay3			:= Nil	//Label da importacao
Static aGetOrc			:= {}	//Grava o orcamento que esta sendo importado
Static oSayVend			:= Nil	//Objecto para exibir o vendedor do Orçamento
Static oSayCli			:= Nil	//Objecto para exibir o código do cliente do Orçamento
Static lCheck			:= .F.	//VAriável para controlar se um Orçamento foi marcado/desmarcado
Static lIsImpDes 		:= .F.  //Indica se contem importação de orçamento. 

//-------------------------------------------------------------------
/*/{Protheus.doc} STIImportSale
Interface Importação de Orçamento

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIImportSale()
Local cMsg		:= ""
Local lVPProd 	:= SuperGetMv("MV_LJVPPRO",,.F.) //Permite vender Vale Presente e produtos na mesma venda 
Local lContinua := .T.

//Tratativa para LGPD
If ExistFunc("LjPDAcesso")
	lContinua := LjPDAcesso({"L1_NOMCLI","L1_CGCCLI"}) //Verifica se o usuário pode acessar uma determinada rotina devido a regra de proteção de dados.
EndIf

If lContinua

	lContinua := !STBExistVP() .OR. lVPProd

	If lContinua
		
		lContinua := STBISMultSales() //Valida se esta liberado para importar orcamento

		//Valida se esta liberado para importar orcamento
		If lContinua
			STIExchangePanel( { || STIPanImportSale(@cMsg) } )
			STIChangeCssBtn('oBtnOrc')
			
			If !Empty(cMsg)
				STFMessage("STIImportSale", "STOP", cMsg)
				STFShowMessage("STIImportSale")
				LjGrvLog("Importa_Orcamento:STIImportSale", cMsg)
			EndIf	
		Else
			STFMessage("STIImportSale", "STOP", STR0008 ) // "Só é possivel importar um orçamento por venda"
			STFShowMessage("STIImportSale")	
			LjGrvLog("Importa_Orcamento:STIImportSale", STR0008)	//"Só é possivel importar um orçamento por venda"
		EndIf
	Else
		STFMessage(ProcName(0),"STOP",STR0015) //"A venda do vale presente deve ser feita separada."
		STFShowMessage(ProcName(0))
		LjGrvLog("Importa_Orcamento:STIImportSale", STR0015)	//"A venda do vale presente deve ser feita separada."
	EndIf
	
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanImportSale
Contexto Importação de Orçamento

@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  oPanGetImportSale	Painel Importação de Orçamento 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanImportSale(cMsg)

Local oPanGetImportSale	:= Nil			
Local oGet1				:= Nil								// Get Principal
Local oGet2				:= Nil								// Get Adicional
Local cGet1				:= ""								// Variável do get de busca principal
Local cGet2				:= ""								// Variável do Get de busca adicional
Local cField1			:= ""								// Campo de busca utilizado
Local cField2			:= ""								// Campo de busca adicional
Local oPanelMVC	 		:= STIGetPanel() 					// Painel principal
Local aField1			:= {}								// Armazena informaçõe do campo de busca de orçamento
Local aField2			:= {}								// Armazena informaçõe do campo adicional de busca de orçamento
Local nGetHeiPerc		:= 90								// Percentual da Altura do Get de Busca

Default cMsg := ""

/* Panel Get do Produto */
oPanGetImportSale := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight/2))
oPanGetImportSale:SetCSS( POSCSS (GetClassName(oPanGetImportSale), CSS_PANEL_CONTEXT )) 

oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetImportSale,,,,,,.T.,,,,) //"Vendas > Orçamento"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 


/* Campo de busca principal*/
cField1 := AllTrim(SuperGetMv("MV_LJORCAM ",,""))	// Campo de busca principal

If Empty(cField1)  
	cField1 := IIF(STFGetCfg("lPafEcf") .OR. STFGetCfg("lPAFNFCE"),"L1_NUMORC","A1_CGC")
EndIf

aField1 := STDISSearchField(cField1)

/* Campo de busca adicional*/
If !STFGetCfg("lPafEcf") .OR. SuperGetMv("MV_LJORCAA ",,"") <> ""

	cField2 := AllTrim(SuperGetMv("MV_LJORCAA ",,"L1_NUM")) // Campo de busca adicional
	aField2 := STDISSearchField(cField2)

EndIf

If Len(aField1) > 0

	/* Primeiro Get */
	oSay3 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||aField1[1]},oPanGetImportSale,,,,,,.T.,,,LARG_SAY,)
	oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL )) 
	
	cGet1 := Space(aField1[5])
	
	oGet1 := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGet1:=u,cGet1)}, oPanGetImportSale,nGetHeiPerc,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGet1")
	oGet1:SetCSS( POSCSS (GetClassName(oGet1), CSS_GET_FOCAL ))
	
    oGet1:bLostFocus    := {|| Iif(ValType(oButton)== "O",oButton:SetFocus(),Nil) } //Tratamento para não perder o foco do Buscar Orçamento 
	
    oGet1:SetFocus()
    
    If GetFocus() <> oGet1:HWND
       oGet1:SetFocus()
    Endif    

	If Len(aField2) > 0
	
		/* Get Parâmetro */
		oSay2 := TSay():New(POSVERT_LABEL2,POSHOR_1,{||aField2[1]},oPanGetImportSale,,,,,,.T.,,,LARG_SAY,)
		oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 
		
		cGet2	:= Space(aField2[5])
	
		oGet2	:= TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,cGet2:=u,cGet2)}, oPanGetImportSale,nGetHeiPerc,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGet2")
		oGet2:SetCSS( POSCSS (GetClassName(oGet2), CSS_GET_FOCAL )) 
			
		/* Sem When*/
        oGet1:bLostFocus        := {|| IIf( oPanGetImportSale:LVISIBLE .AND. !Empty(cGet1) , ;
        													( ;
        														IIf( oPanGetImportSale:LVISIBLE .AND. !Empty(cGet2) , ;
        																			Eval( {|| cGet2 := Space(Len(cGet2)) , ;
                                    															STFMessage("STIImportSale", "STOP", STR0009) , ; //"Só é possivel buscar por 1 campo preenchido"
                                    															STFShowMessage("STIImportSale") } ) ;
                                    											, ),;
                                    						 	oButton:SetFocus() ;
                                    						) ;
                                    					 	,IIf( oPanGetImportSale:LVISIBLE .AND. Empty(cGet2), ;
                                    											oGet2:SetFocus(),;
                                    		 									) ) }
        oGet2:bLostFocus    := {|| IIf( !Empty(cGet2) , ;
        												( ;
        													IIf(  !Empty(cGet1) , ;
        																		Eval( {|| cGet1 := Space(Len(cGet1)) , ;
                                    														STFMessage("STIImportSale", "STOP", STR0009) , ; //"Só é possivel buscar por 1 campo preenchido"
                                    														STFShowMessage("STIImportSale") } ) ;
                                    										, ) ;
                                    						,oButton:SetFocus()   ;
                                    					);
			                                    		, IIf( Empty(cGet1), ;
			                                    						oGet1:SetFocus(),;
			                                    		 				) ) }
	
	EndIf   
	
	oButton := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0002,oPanGetImportSale,{ || STIISSearch( oPanGetImportSale, oPanelMVC , cField1, cGet1 , cField2 , cGet2 ) }, ;  //"Buscar Orçamento"
									LARGBTN,ALTURABTN,,,,.T.)
	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 									
																																			
Else
	cMsg := STR0011 //"Erro na configuração de busca. Verificar parâmetro MV_LJORCAM."
	
EndIf

Return oPanGetImportSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSearch
Busca de Orçamento

@param   cGet2
@param   oPanGetImportSale
@param   oPanelMVC
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSearch( oPanGetImportSale, oPanelMVC , cField1, cGet1 , cField2 , cGet2 )

Local aAux				:= {}							// Armazena retorno função temporariamente
Local lUserSelect		:= .F.		   					// Indica se orçamento deve ser selecionado
Local nLisHorPerc		:= 0.039						// Pencentual de Posição Horizontal do ListBox
Local nLisHeiPerc		:= 0.27							// Percentual de Altura do ListBox
Local aListOrc			:= {}							// Lista de orcamentos
Local cTextLabel		:= "Codigo Orc.   - Cliente" + Space(43) + "  -   Valor"// Label para exibicao do listbox //"Codigo Orc.   -   Cliente  -   Valor"
Local nListCheck		:= 0							//Posição do Orçamento selecionado
Local nList 			:= 0							//Variável de controle

STFCleanInterfaceMessage()

If Empty(cGet1) .AND. Empty(cGet2)
	
	STFMessage("STIImportSale", "STOP", STR0010 ) //"Campo de busca deve ser preenchido"
	STFShowMessage("STIImportSale")	
	LjGrvLog("Importa_Orcamento:STIImportSale",STR0010)	//"Campo de busca deve ser preenchido"
	
Else
	 
	/* Chamada Busca de opções de orçamento */
	If !Empty(cGet1)
		MsgRun(STR0016,'Aguarde.....',{||aAux := STWISSearchOptions( cField1 , cGet1 )})	 //"Buscando Orcamentos"
	Else
		MsgRun(STR0016,'Aguarde.....',{||aAux := STWISSearchOptions( cField2 , cGet2 )})	 //"Buscando Orcamentos"					
	EndIf
	
	lUserSelect 	:= aAux[1]
	aOptionSales	:= aAux[2]
	
	/*
	Removido validação para importar orçamento direto quando era realizado
	busca através do número do orçamento. Sistema esta apresentando erro ao 
	importar um orçamento filho (venda com retira posterior) gerado na retaguarda.
	*/

	/* Formata o array para exibicao do listbox */
	
	aListOrc := STIISFormOrc(aOptionSales)
			
	/* Alimenta o array aViewOptionsSales */
	STIISSetViewOptions( aOptionSales )
			
	If STFGetCfg("lPafEcf") .OR. STFGetCfg("lPAFNFCE")
	
		If SuperGetMv("MV_LJPRVEN",,.T.)
			cTextLabel := STR0012 // "Pré-Venda   /   Cliente   /   Valor"
		Else
			cTextLabel := STR0013 // "DAV   /   Cliente   /   Valor"
		EndIf
			
	EndIf

	oSay3:SetText( cTextLabel )

	oSay3:CtrlRefresh()

	/* Cria listbox com os orcamentos para selecionar */

	oOrcList := TListBox():New( POSVERT_GET1,POSHOR_1,{|u|if(Pcount()>0,nList:=u,nList)},aListOrc,;
	( oPanelMVC:nWidth/2  - (2*nLisHorPerc*oPanelMVC:nWidth/2)),oPanelMVC:nHeight/2 * nLisHeiPerc,;
	nil,oPanGetImportSale,/*[ bValid ]*/, Nil , Nil,.T., Nil, ;
	{|| STIMarkImport(@nListCheck), lCheck:=.T.},,Nil, Nil,/* [ bWhen ]*/, Nil, Nil, Nil,Nil, /*[ bRClicked ]*/ )

	If !STFGetCfg("lPafEcf") .AND. !STFGetCfg("lPafNFCE")
		oSayVend := TSay():New(POSVERT_GET1+70 ,POSHOR_1,{||"Vendedor   : " },oPanGetImportSale,,,,,,.T.,,,300,) 
		oSayVend:SetCSS( POSCSS (GetClassName(oSayVend), CSS_BREADCUMB ))
		oSayCli := TSay():New(POSVERT_GET1+80 ,POSHOR_1,{||"Cód.Cliente: " },oPanGetImportSale,,,,,,.T.,,,300,) 
		oSayCli:SetCSS( POSCSS (GetClassName(oSayCli), CSS_BREADCUMB ))

		If nList > 0 .AND. nListCheck > 0
			oOrcList:bChange:= {|| iIF(!lCheck, STIExibeInf(aOptionSales[nList]), (lCheck:=.F.,oOrcList:Select(nListCheck))) }
		EndIf
	Endif 	

	oOrcList:SetCSS( POSCSS (GetClassName(oOrcList), CSS_LISTBOX )) 
	oOrcList:SetFocus()
			
	oBtn := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0005,oPanGetImportSale,{ || MsgRun(STR0017,'Aguarde.....', {||STIFinishImp()}), Iif(ExistFunc("STIMataObj"), STIMataObj(oPanGetImportSale), Nil) }, ; //"Importar" //"Importanto Orcamento Selecionado"
											LARGBTN,ALTURABTN,,,,.T.)
	oBtn:SetCSS( POSCSS( GetClassName(oBtn), CSS_BTN_FOCAL ) )

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSetSales
Seta Orçamentos a importar

@param   aAllSales	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSetSales( aAllSales )

Default aAllSales	:= {}

ParamType 0 Var aAllSales As Array Default {}

aSetSale := aAllSales

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISFormOrc
Formata os orcamentos para apresentaçao na tela 

@param   aOrcs
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISFormOrc( aOrcs )

Local aListOrc 		:= {}					//Retorno dos orcamentos
Local nI			:= 0 					//Variavel de loop
Local nJ			:= 0					//Variavel Loop
Local nZ			:= 0					//Contador
Local cOrc			:= ""					//String a ser apresentada no LisBox
Local aFieldsAdd	:= STIISFieldsAdd()		//Campos a serem apresentados na interface
Local aFieldsInt	:= STIISParamFields(.F.)//Campos a apresentar na interface
Local aFieldValue	:= {}					//Corresponcia campo valor entre interface e o resultado da busca
Local nPos			:= 0
Local oCesta 		:= STDGPBModel()
Local cNumOrc		:= ""
Local aPEOrcs		:= {}

For nZ := 1 To Len(aFieldsInt)
	
	Do Case
	
		Case aFieldsInt[nZ] == "L1_NUM"
			 AADD( aFieldValue , { "L1_NUM" , 1 } )
		Case aFieldsInt[nZ] == "L1_NUMORC"
			AADD( aFieldValue , { "L1_NUMORC" , 2 } )
		Case aFieldsInt[nZ] == "A1_NOME"
			AADD( aFieldValue , { "A1_NOME" , 3 } )
		OtherWise
			AADD( aFieldValue , { aFieldsInt[nZ] , AScan( aFieldsAdd , { |x| x == aFieldsInt[nZ] } ) + 3 } ) // Adiciona 3 pq os 3 primeiros são padrão:= NUM,NUMOR,NOME
				
	EndCase	
	
Next nZ

// Busca se ja foi importado ja algum orçamento, caso sim elimina do array
If STDPBLength("SL2") > 0
	oCesta := oCesta:GetModel("SL2DETAIL")
	For nZ := 1 To STDPBLength("SL2")
		oCesta:GoLine(nZ)
		If !oCesta:IsDeleted()
			cNumOrc := STDGPBasket( "SL2" , "L2_NUMORIG" , nZ )
			nPos := Ascan( aOrcs,{ |x| Alltrim(x[1]) == Alltrim(cNumOrc) } )
			If nPos > 0 
				ADel(aOrcs,nPos)
				ASize(aOrcs,len(aOrcs)-1)
			EndIf
		EndIf
	Next nZ
EndIf

If ExistBlock("STORDIIMPORT")//Ordena os orçamentos a serem importados.
	aPEOrcs := ExecBlock("STORDIIMPORT",.F.,.F.,{aOrcs})
	If ValType(aPEOrcs) == "A"
		aOrcs := aClone(aPEOrcs)	
	EndIf
Endif

For nI := 1 To Len(aOrcs)
	
	cOrc := ""

	For nJ := 1 To Len(aFieldsInt)
	
		nPos := AScan( aFieldValue , { |x| x[1] == aFieldsInt[nJ] } )
			
		If aFieldsInt[nJ] == "L1_VLRTOT"
			cOrc := cOrc + "R$ " //Colocar simbolo moeda	
			cOrc := cOrc + PADL(AllTrim(Str(Val(STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]])),16,2)), 10)
		ElseIf aFieldsInt[nJ] == "A1_NOME"
			cOrc := cOrc + padr(AllTrim(STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]]) ), 50)
		Else 
			cOrc := cOrc + STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]])			
		EndIf						

		If nJ == Len(aFieldsInt)
		
			AADD( aOptionSales[nI] , cOrc )
			AADD( aListOrc , cOrc )
		Else
		
			cOrc := cOrc + ' - '
						
		EndIf
		
	Next nJ

Next nI
				
Return aListOrc


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSetViewOptions
Seta opçoes de orçamento para carregar no modelo depois de ativo

@param   aOptionSales	Opções de orçamento buscados da retaguarda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSetViewOptions( aOptionSales )

Default aOptionSales		:= {}

ParamType 0 Var aOptionSales As Array Default {}

aViewOptionsSales := aOptionSales

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISAfterSelected
Seta opçoes de orçamento para carregar no modelo depois de ativo

@param   aOptionSales	Opções de orçamento buscados da retaguarda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISAfterSelected()

Local lRet				:= .T.							// Retorno função
Local nI				:= 0							// Variavel de loop
Local aSelectedSales	:= {}
Local lContinua 		:= .T.
Local lCFRetPos	 		:= .F. 							// Indica se faz somente a impressao do Cupom Fiscal devido ser uma finalizacao de venda com itens de "RETIRA POSTERIOR"
Local nPosImpOrc		:= 0							// Linha do orçamento na qual esta posicionado
Local aImported			:= {}
Local nDescVend			:= 0                            // Desconto no total da venda
Local aSL1				:= {}

If Len(aViewOptionsSales) > 0

	nPosImpOrc := oOrcList:GetPos() //Posição atual

	if GetCliHTML()
		oOrcList:GoTop()
	Endif

	For nI := 1 To Len(aViewOptionsSales)
		oOrcList:Select(nI) //Posiciona na linha
		If CTXTSEL $ oOrcList:GetSelText()
			aAdd(aSelectedSales, {aViewOptionsSales[oOrcList:GetPos(),1], aViewOptionsSales[oOrcList:GetPos(),2],;
									aViewOptionsSales[oOrcList:GetPos(),3], aViewOptionsSales[oOrcList:GetPos(),4],;
									aViewOptionsSales[oOrcList:GetPos(),5]}) // Armazena opções de orçamento selecionadas
		EndIf
	Next
	
	If Len(aSelectedSales) == 0
		oOrcList:Select(nPosImpOrc) //Posiciona na linha em que estava posicionado
		aSelectedSales	:= {{	aViewOptionsSales[oOrcList:GetPos(),1], aViewOptionsSales[oOrcList:GetPos(),2],;
									aViewOptionsSales[oOrcList:GetPos(),3], aViewOptionsSales[oOrcList:GetPos(),4],;
									aViewOptionsSales[oOrcList:GetPos(),5]	}}	// Armazena opções de orçamento selecionadas
	EndIf
	
EndIf							

/* Validações */
If Len(aSelectedSales) == 0
	
	lRet := .F.
	STFMessage("STIImportSale", "STOP", STR0006 ) //"Nenhum orçamento foi selecionado"
	STFShowMessage("STIImportSale")	
	LjGrvLog("Importa_Orcamento:STIISAfterSelected",STR0006)	//"Nenhum orçamento foi selecionado"
	
EndIf

/* Realizar importação */
If lRet
	
	/* Get dos orçamentos a partir das opções selecionadas */
	aImported := STWISImpAllSelected( aSelectedSales , "S" )
	lContinua := aImported[1]
	
	IF lContinua .AND. len (aImported[5])>0 //Existe orçamento com erro e sem erro.
		STFMessage("STIImportSale", "YESNO", aImported[3]) //"Confirma a impressão do cupom fiscal?"
		lContinua := STFShowMessage("STIImportSale")
	ElseIf !lContinua
		LjGrvLog("Importa_Orcamento:STIISAfterSelected","aImported  : ", aImported)
	EndIf

	LjGrvLog("Importa_Orcamento:STIISAfterSelected","lContinua  : ", lContinua)
	
	If lContinua
		/* Verifica se é finalizacao de venda de orcamento somente com itens de "RETIRA POSTERIOR", para imprimir o Cupom  Fiscal e Finalizar. */
		lCFRetPos := STBISRetPos(aImported[4][1][1])
		
		If lCFRetPos 
			STFMessage("STIImportSale", "YESNO", STR0014) //"Confirma a impressão do cupom fiscal?"
			lContinua := STFShowMessage("STIImportSale")
		EndIf
	EndIf
	
	If lContinua		// Continua?
	
		If lCFRetPos
			
			
			STIAltTipo(aImported[4][1][1]) 
			

			LjGrvLog("Importa_Orcamento:STIISAfterSelected", "Chama a importação de Orçamento filho com apenas itens de Retira Posterior")
			//Chama a importação de Orçamento filho com apenas itens de Retira Posterior" (Imprime o Cupom direto e finaliza)
			STBISFinPos(aImported[4][1])

		Else
			
			/* Guarda o orcamento que esta sendo importado  */
			aGetOrc := aImported[4]
			aSL1 	:= aGetOrc[1][1] 	
			//Verifico se tem permissão para alterar a forma de pagamento
			If STFGetCfg("lChangePay", .F.) 
				If MsgYesNo(STR0019,STR0020) //Deseja alterar as formas de pagamento?/Atenção
					STIChangePay(@aGetOrc[1][3])
				EndIf
			EndIf
			
			/* Cadastra cliente na base local caso não exista */
			STBCadCli(aGetOrc)

			/* Chamar Importação direto */
			STWISRegSale( aImported[4] ) // aAllSales
			
			/* Atualiza interface */
			STIGridCupRefresh()
			
			/* Pagamento */
			//Nao utilizar nesse ponto o comando STICallPayment. Motivo: Utilizando o comando STWBtFimVnd o fluxo padrao para solicitar o CPF será respeitado  
			STWBtFimVnd()	//Rotina com tratamento padrao para finalizar a venda
			
			/*Localizamos se tem desconto na venda se tiver mantemos o que foi negociado*/
			nDescVend	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_DESCONT"} )][2]
			Iif(nDescVend > 0,lIsImpDes := .T.,lIsImpDes)
			
			STIISSetViewOptions() // Zera statica	

		EndIf						 
	Else		
		If ExistFunc("STWGetMsg") .AND. !Empty(STWGetMsg())
			STFMessage("STIImportSale", "POPUP", STWGetMsg() )
			LjGrvLog("Importa_Orcamento:STIISAfterSelected", STWGetMsg())
		Else
			STFMessage("STIImportSale", "ALERT", STR0007 ) //"Não foi possível importar o orçamento"
			LjGrvLog("Importa_Orcamento:STIISAfterSelected",STR0007)	//"Não foi possível importar o orçamento"
		EndIf

		STFShowMessage("STIImportSale")	
		lRet := .F.		

	EndIf	
		
EndIf



Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISFieldsAdd
Retorna campos adicionais que foram configurados a aparecer na view

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aFieldsAdd	Campos adicionais configurados a aparecer na view
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISFieldsAdd()

Local aFieldsAdd	:= {}						// Retorno função
Local aConfFields	:= STIISParamFields(.T.)	// Armazena todos os campos configurados para aparecer na interface
Local nI			:= 0						// Contador

For nI := 1 To Len(aConfFields)
	
	If !( aConfFields[nI] $ "L1_NUM|L1_NUMORC|A1_NOME" )
	
		AADD( aFieldsAdd , aConfFields[nI] )
		
	EndIf
	
Next nI

Return(aFieldsAdd)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFinishImp
Chama a rotina para pesquisar os orcamentos

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFinishImp()

If !STFGetCfg("lPafEcf") .AND. !STFGetCfg("lPafNFCE")
	oSayCli:lVisible:= .F.
	oSayVend:lVisible:= .F.
Endif 

STIISAfterSelected()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetOrc
Retorna o orcamento importado

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetOrc()
Return aGetOrc


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISConvertToStr
Converte valor passado para caractere

@param   xValeu 			Valor a ser convertido
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISConvertToStr( xValue )

Do Case
	Case Valtype(xValue) == "N"
		cRet := AllTrim(Str(xValue))
	Case Valtype(xValue) == "C"
		cRet := xValue
	Case Valtype(xValue) == "D"
		cRet := DTOC(xValue)
	Case Valtype(xValue) == "L"
		If xValue
			cRet := "T"
		Else
			cRet := "F"
		EndIf
	Otherwise
		cRet := xValue
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Retorna campos que vao aparecer na interface

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRetFields		Campos aparecer interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISParamFields(lBusca)
Local lNotPAF 		:= !STFGetCfg("lPafEcf") .AND. !STFGetCfg("lPafNFCE")
Local cParam		:= Iif(lBusca,"L1_NUM/A1_NOME/L1_VLRTOT/L1_DESCONT/L1_JUROS" + IIF(SL1->(ColumnPos("L1_VLRJUR")) > 0 , "/L1_VLRJUR", "" )+ Iif(lNotPAF, "/L1_VEND/L1_CLIENTE" , "" ), "L1_NUM/A1_NOME/L1_VLRTOT")//CAMPOS PARA A BUSCA E PARA A INTERFACE
Local aRetFields	:= STRTOKARR ( cParam , "/" )		// Retorno Função

If STFGetCfg("lPafEcf") .OR. STFGetCfg("lPafNFCE")
	If AScan( aRetFields , { |x| x == "L1_NUM" } ) > 0
		aRetFields[AScan( aRetFields , { |x| x == "L1_NUM" } )] := "L1_NUMORC"
	EndIf
Else
	If AScan( aRetFields , { |x| x == "L1_NUMORC" } ) > 0
		aRetFields[AScan( aRetFields , { |x| x == "L1_NUMORC" } )] := "L1_NUM"
	EndIf
EndIf

Return aRetFields

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Função para limpar variavel estatica

@param   
@author  Varejo
@version P11.8
@since   20/01/2016
@return  .T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIClrVar()

If Len(aGetOrc) > 0
	aGetOrc := {}
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMarkImport
Função marcar seleção de multi orçamentos

@param   
@author  Varejo
@version P11.8
@since   20/01/2016
@return  .T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIMarkImport(nListCheck)
Local cTxtList	:= ""
Local nMax		:= 0

If !SuperGetMv( "MV_LJMLTOR" , NIl , .T. ) //Valida se esta liberado para importar orcamento
	STFMessage(ProcName(), "ALERT", STR0018 ) //"Seleção de multiplos orçamentos desabilitada(MV_LJMLTOR)"
	STFShowMessage(ProcName())	
	LjGrvLog("Importa_Orcamento:STIMarkImport", STR0018)		//"Seleção de multiplos orçamentos desabilitada(MV_LJMLTOR)"
Else
	If oOrcList <> Nil
		cTxtList := oOrcList:GetSelText()
		If CTXTSEL $ cTxtList //retira a seleção.
			nMax := RAt(CTXTSEL,cTxtList)
			oOrcList:Modify( SubStr(cTxtList, nMax+lEN(CTXTSEL)), oOrcList:GetPos() )
		Else //coloca a selação
			oOrcList:Modify( CTXTSEL + AllTrim(cTxtList) , oOrcList:GetPos() )
		EndIf
		nListCheck:=oOrcList:GetPos()
	EndIf 
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIExibeInf'
Função para exibir código e nome do vendedor e codigo do cliente do orçamento selecionado

@param   aList, array, informação do orçamento selecionado
@author  Varejo
@version P12
@since   07/02/2024
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function STIExibeInf(aLista)
Local lExistFunc:= ExistFunc("STDNomeVen")

Iif(Len(aLista) >= 8, oSayVend:SetText( "Vendedor   : "+ aLista[8] + iif(lExistFunc, STDNomeVen(aLista[8]),"")) , nil ) 
Iif(Len(aLista) >= 9, oSayCli:SetText( "Cód.Cliente: " + aLista[9]), nil ) 

Return

/*/{Protheus.doc} STIGetImp
Função para retornar se tem desconto no total da venda na importação de orçamento .
@author  Jeferson Mondeki
@since   27/12/2024
@version P12
@return  lIsImpDes, logico, variavel que contém o conteúdo .T. se tem desconto .F. não tem desconto.
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STIGetImp()
Return lIsImpDes

/*/{Protheus.doc} STISetImp
Função para retornar o valor padrão da variavel lIsImpDes.
@param lResetImp, logico, seta um default para a variavel
@author  Jeferson Mondeki
@since   27/12/2024
@version P12
@return  Nil 
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STISetImp(lResetImp)
Default lResetImp := .F.
lIsImpDes := lResetImp
Return

/*/{Protheus.doc} STIAltTipo
Quando se tratar da importação de um orçamento com retira posterior, precisamos 
ajustar o L1_TIPO para V, para que não gerar financeiro novamente na retaguarda. 
@type  		Function
@param 		aSL1		, Array , Array com os dados da SL1
@author 	Jeferson Mondeki
@since 		01/04/2025
@return 	Nil	 
@version 	12
/*/
Static Function STIAltTipo(aSL1)

Local nPos := Iif(Len(aSL1) > 0, AScan( aSL1 , { |x| x[1] == "L1_TIPO" } ), 0) // Posição do campo L1_TIPO

If nPos > 0
	aSL1[nPos][2] := "V"
EndIf	

Return Nil
