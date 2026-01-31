#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STIDISCOUNTTOTAL.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"

static lAtivMotor	:= ExistFunc("PshAtivMTP") .AND. PshAtivMTP()

//-------------------------------------------------------------------
/*/{Protheus.doc} STIDiscountTotal
Abertura da Interface de Desconto na Venda

@param   nenhum	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  NIL
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIDiscountTotal()
Local lCRdesItTt 	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. SuperGetMV("MV_LJCRDPT",,"0") == "1" .AND. FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.LjCallCalcRegDescProdTotal", .T.)	// Verifica se o calculo do desconto por item esta sendo feito no final da venda
Local lDesligaRD	:= .F. 															// Desabilita a Regra de Desconto do Varejo

If FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu", .T.)
	lDesligaRD := totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu("TOTVSPDV", STDGPBasket('SL1','L1_NUM'), STDGPBasket('SL1','L1_CLIENTE'), STDGPBasket('SL1','L1_LOJA'))
EndIf

If !lAtivMotor
	/* Abre o Panel */
	If (!lCRdesItTt .Or. lDesligaRD) .AND. STBValScreenDisc()
		If STBTaxRet( Nil ,"NF_DESCTOT") == 0
			STIExchangePanel( { || STIPanDiscTotal() } )
			STIChangeCssBtn('oBtnDesc')
		Else 
			//STR0011#"O desconto aplicado anteriormente sera cancelado, deseja continuar?"
			//STR0012#"OK"
			//STR0013#"Cancelar"
			STIExchangePanel( { || STFYesNo(STR0011,STR0012,STR0013,{||STIClearDisc(.T.),STIChangeCssBtn('oBtnDesc'),STIExchangePanel( { || STIPanDiscTotal() } )},{||STIRegItemInterface()},.T.) })
		EndIf
	ElseIf !lDesligaRD .And. lCRdesItTt
		STFMessage("STFMTPRO","POPUP", STR0017) // "N„o È possÌvel aplicar desconto manual, pois a funcionalidade de aplicaÁ„o de Regra de Descontos na finalizaÁ„o de venda est· ativa. Par‚metro MV_LJCRDPT."
		STFShowMessage("STFMTPRO")	
	EndIf
Else
	STFMessage("STFMTPRO","STOP", STR0016 )//"N„o È PossÌvel Aplicar Desconto Manual, o Motor de PromoÁıes est· ativado"
	STFShowMessage("STFMTPRO")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanDiscTotal
Contexto desconto no Total da Venda

@param   nenhum	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  NIL
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanDiscTotal()
Local oPanGetDiscount	:= Nil
Local oGetValue			:= Nil
Local nGetValue			:= STBTaxRet( Nil ,"NF_DESCTOT")
Local oGetPerc			:= Nil
Local oTotal	   		:= STFGetTot() 					// Totalizador 
Local nGetPerc			:= STBDiscConvert( STBTaxRet( Nil ,"NF_DESCTOT") , 'V' , oTotal:GetValue( "L1_VALBRUT"	) )[2] 
Local oReasons			:= Nil				// ListBox de Motivo de Desconto
Local oButton			:= Nil				// Botao Confirmar Desconto na Venda
Local oPanelMVC	   		:= STIGetPanel() 		//Painel padrao para abertura de PDV 
Local aReasons			:= {}				// Armazena Motivos de Desconto cadastrados
Local nTab1				:= 0				// Largura de Tabula√ß√£o
Local nTabPerc			:= 0.015			// Percentual de tabula√ß√£o
Local nGetnWidth		:= 0				// Largura dos Gets
Local nGetnHeight		:= 0				// Altura dos Gets
Local nOuWidth			:= 0				// Largura do Say "OU"
Local nOuPerc			:= 0.08				// Percentual da largura do Say "OU"
Local aOuPosition		:= Array(2)			// Posi√ß√£o exata largura e altura do Say "OU" em rela√ß√£o ao espa√ßo dispon√≠vel para ele
Local nOuPercTop		:= 0.3				// Percentual do come√ßo Top da palavra do Say "OU" em rela√ß√£o √† altura dispon√≠vel do espa√ßo dele
Local nOuPercBotton		:= 0.3				// Percentual do come√ßo da palavra do Say "OU" em rela√ß√£o √† Largura dispon√≠vel do espa√ßo dele
Local nRsnPercHeigth	:= 0.15				// Percentual da Altura do ListBox Motivo de Desconto
Local nRsnHeigth		:= 0				// Altura do ListBox Motivo de Desconto
Local nPerc2			:= 0.15
Local nDescImp			:= 0
Local oModelMaster		:= STFGetTot()		// Model da SL1


/* oSay2 */
Local nPosLb2Hoz		:= oPanelMVC:nWidth/2 * 0.039 //Posicao: Horizontal

/* oSay3 */
Local nPosLb3Hoz		:= oPanelMVC:nWidth/2 * 0.406 //Posicao: Horizontal

/* oSay4 */
Local nPosLb4Alt		:= (oPanelMVC:nHeight/2 * 0.02) * 8.85 //Posicao: Altura
Local nPosLb4Hoz		:= oPanelMVC:nWidth/2 * 0.320 //Posicao: Horizontal

/* oSay6 */
Local nPosLb6Alt		:= (oPanelMVC:nHeight/2 * 0.02) * 12 //Posicao: Altura

/* oGetValue */
Local nPosGetHoz		:= oPanelMVC:nWidth/2 * 0.039
Local nTamGetHoz		:= (oPanelMVC:nWidth/2)/2 * 0.49 

/* oGetPerc */
Local nPosPerHoz		:= oPanelMVC:nWidth/2 * 0.40

/* ListBox */
Local nLisHorPerc		:= 0.039	// Pencentual de Posi√ß√£o Horizontal do ListBox
Local nLisHeiPerc		:= 0.19	// Percentual de Altura do ListBox

Local oSay5				:= Nil
Local oSay6				:= Nil

/* Panel Desconto na Venda */
oPanGetDiscount := TPanel():New(00,00,"",oPanelMVC,,,,,,(oPanelMVC:nWidth/2),(oPanelMVC:nHeight/2))
oPanGetDiscount:SetCSS( POSCSS (GetClassName(oPanGetDiscount), CSS_PANEL_CONTEXT )) 

nTab1 		:= oPanGetDiscount:nWidth/2 * nTabPerc
nOuWidth	:= oPanGetDiscount:nWidth/2 * nOuPerc
nGetnWidth	:= ( ( oPanGetDiscount:nWidth/2  - (2*( nTab1 * 2)) - nOuWidth ) / 2)
nGetnHeight	:= 10

/* Calcula Posi√ß√£o exata do Say "OU" em rela√ß√£o ao espa√ßo dispon√≠vel para ele */                  
// Altura
aOuPosition[1] := ( (oPanGetDiscount:nHeight/2 * nPerc2) + ( nGetnHeight * nOuPercTop ) )
// Largura
aOuPosition[2] := ( (nTab1 * 2 + nGetnWidth) + nOuWidth * nOuPercBotton )

/* Objetos */
oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetDiscount,,,,,,.T.,,,,) //"Vendas > Desconto na Venda"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

oSay2 := TSay():New(POSVERT_LABEL1,nPosLb2Hoz,{||STR0002},oPanGetDiscount,,,,,,.T.,,,,) //"Valor(R$)"
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 

oSay3 := TSay():New(POSVERT_LABEL1,nPosLb3Hoz,{||STR0003},oPanGetDiscount,,,,,,.T.,,,,) //"Porcentagem(%)"
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL )) 

oSay4 := TSay():New(nPosLb4Alt,nPosLb4Hoz,{||STR0004},oPanGetDiscount,,,,,,.T.,,,,) //"ou"
oSay4:SetCSS( POSCSS (GetClassName(oSay4), CSS_LABEL_FOCAL ))

oGetValue := TGet():New(POSVERT_GET1,nPosGetHoz,{|u| If(PCount()>0,nGetValue:=u,nGetValue)}, oPanGetDiscount,nTamGetHoz,,"@E 999,999.99",,,,,,,.T.,,,,,,,,,,"nGetValue",,,,,.T.)
oGetValue:SetCSS( POSCSS (GetClassName(oGetValue), CSS_GET_FOCAL ))   
                       
oGetPerc := TGet():New(POSVERT_GET1,nPosPerHoz,{|u| If(PCount()>0,nGetPerc:=u,nGetPerc)}, oPanGetDiscount,nTamGetHoz,,"@E 999,999.99",,,,,,,.T.,,,,,,,,,,"nGetPerc",,,,,.T.)   	                                
oGetPerc:SetCSS( POSCSS (GetClassName(oGetPerc), CSS_GET_FOCAL )) 

oGetValue:bLostFocus := {|| Iif(GetFocus() <> oGetPerc:HWND,oGetPerc:SetFocus(),Nil)  }
                
/* Se Utiliza Motivo de desconto */
If STDRsnDesc()

	aReasons	:= STIReasons()                                                  	
	
	oSay5 := TSay():New(POSVERT_GET2, POSHOR_1,{||STR0005},oPanGetDiscount,,,,,,.T.,,,,) //"Motivo de Desconto"
	oSay5:SetCSS( POSCSS (GetClassName(oSay5), CSS_LABEL_FOCAL )) 
	
	nRsnHeigth := oPanGetDiscount:nHeight/2 * nRsnPercHeigth

	oReasons := TListBox():Create(oPanGetDiscount, oPanelMVC:nHeight/4.673, oPanelMVC:nWidth/2 * nLisHorPerc,;
	 		Nil, aReasons, ( oPanGetDiscount:nWidth/2  - (2*nLisHorPerc*oPanGetDiscount:nWidth/2) ),oPanGetDiscount:nHeight/2 * nLisHeiPerc,,,,,.T.)
	oReasons:SetCSS( POSCSS (GetClassName(oReasons), CSS_LISTBOX )) 
	
	oSay5:lvisiblecontrol:=.F.
	oReasons:lvisiblecontrol:=.F.
	
EndIf

If FindFunction("STBGetDscImp") .And. STBIsImpOrc()
	STIDescImp( @nDescImp)
	oSay6 := TSay():New(nPosLb6Alt,nPosGetHoz,{||STR0015+Transform(nDescImp,"@E 999,999.99")},oPanGetDiscount,,,,,,.T.,,,,) //"Desconto da importaÁ„o: R$ "
	oSay6:SetCSS( POSCSS (GetClassName(oSay6), CSS_LABEL_FOCAL ))
EndIf

If oModelMaster:HasField("L1_ARMDESC") .And. oModelMaster:GetValue("L1_ARMDESC") > 0
	oModelMaster:SetValue("L1_ARMDESC", 0) // Atualizamos o campo sempre que inicio a rotina onde tenha desconto no total.
EndIf

oButton := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0006,oPanGetDiscount, ;   //"Confirmar Desconto"
							{ || STISetReason(oReasons),IIF(STITotDiscVal(nGetValue,nGetPerc,oReasons), STIRegItemInterface(),)},LARGBTN,ALTURABTN,,,,.T.)	  
				
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

oBtnCa := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0009,oPanGetDiscount,{||STIRegItemInterface()}, ; //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_NORMAL ))

oGetValue:bChange   := { || IIf( nGetValue >= 0	, nGetPerc   := STBDiscConvert( nGetValue       , "V"  )[2] , )} // Se valor maior que zero seta o foco no percentual e atualiza objeto
oGetPerc:bChange    := { || IIf( nGetPerc >= 0	, nGetValue    := STBDiscConvert( nGetPerc       , "P"  )[1] , )} // Se percentual de desconto for maior que zero seta o foco no valor e atuliza objeto

If oReasons <> Nil 
	oGetValue:bLostFocus := {|| STIFocusReason(oReasons, oSay5, nGetPerc, nGetValue) }
	oGetPerc:bLostFocus := {|| STIFocusReason(oReasons, oSay5, nGetPerc, nGetValue) }
Endif

oGetValue:SetFocus()

If GetFocus() <> oGetValue:HWND
    oGetValue:SetFocus()    
Endif 

Return oPanGetDiscount

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFocusReason
Confima√ß√£o desconto no total

@param   oReasons		Objeto ListBox de Get de Motivo de Desconto 
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFocusReason(oReasons, oSay5, nGetPerc, nGetValue)

Default oReasons	:= Nil
Default oSay5		:= Nil
   
If nGetPerc <= 0 .OR. nGetValue <= 0 
	oReasons:lvisiblecontrol:=.F.
	oSay5:lvisiblecontrol:=.F.
else
	oReasons:lvisiblecontrol:=.T.
	oSay5:lvisiblecontrol:=.T.
	oReasons:GoTop()
	oReasons:SetFocus()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STITotDiscVal
Confima√ß√£o desconto no total


@param nGetValue, numerico
@param nGetPerc , numerico
@param oReasons , objeto 
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  lRet, logico
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STITotDiscVal( nGetValue , nGetPerc , oReasons)
Local lRet				:= .T.							// Retorna se efetuou o desconto
Local lFinServ			:= SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Local nDiscOrcV			:= 0							// Valor de desconto no orÁamento (Caso exista)
Local nDiscOrcP 		:= 0							// Pencental de desconto no orÁamento (Caso exista)
Local aDescOrc			:= {0,0}						// Array com InformaÁıes sobre desconto no orÁamento, sendo ele; valor total e percentual total.
Local oModelMaster		:= STFGetTot()					// Model da SL1

Default nGetValue	:= 0						// Valor do Desconto
Default nGetPerc	:= 0						// Percentual do Desconto
Default oReasons	:= Nil						// Objeto do motivo de desconto

If oModelMaster:HasField("L1_ARMDESC") .And. nGetValue >= 0 
	oModelMaster:SetValue("L1_ARMDESC", nGetValue) // Atualizamos o campo sempre que confirmado o desconto no total. 
EndIf

If FindFunction("STBGetDscImp")
	//-----------------------------------------------
	//|Valida desconto proveniente da importacao	|
	//|mando atualizar pois se eu tiver um limite	|
	//|no desconto ( permissao†) o desconto 		|
	//|da importacao deve ser considerado			|
	//-----------------------------------------------
	STIDescImp( NIL , @nDiscOrcV, @nDiscOrcP)
	aDescOrc	:= {nDiscOrcV,nDiscOrcP}
EndIf

If nGetValue <= 0 .AND. nGetPerc <= 0
	
	If nGetValue < 0 .OR. nGetPerc < 0
		
		STFMessage(ProcName(),"STOP",STR0010) //"Desconto Invalido."
		STFShowMessage(ProcName())
		lRet := .F.		
	Else
		STIClearDisc()
	EndIf	

Else
	
	//Validacao Servicos Financeiros
	If lFinServ
		lRet := STWDescServ()
	EndIf

	If lRet
		/* Se Utiliza Motivo de desconto */
		If STDRsnDesc()
			If Empty( STIGetReason() )				
				lRet := .F.
				STFMessage("STITotalDiscount","STOP",STR0008) //"obrigatorio selecionar o Motivo de Desconto"
				STFShowMessage("STITotalDiscount")
			EndIf
		EndIf
	EndIf
	
	If lRet
	
		Do Case
			
			Case nGetPerc > 0 .AND. nGetValue <= 0
				lRet := STWTotDisc( nGetPerc , "P" , "US",,aDescOrc )
			Case nGetValue > 0
				lRet := STWTotDisc( nGetValue , "V" , "US",,aDescOrc )
			Otherwise
				lRet := STWTotDisc( 0 , "V" , "US" )
			
		EndCase
				
		/* Atualiza Interface */
		If lRet
		
			STIGridCupRefresh()		
			
		EndIf
		
	EndIf

EndIf
		
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIClearDisc
Zera o desconto aplicado

@param lLimpaDesc, LÛgico, Define se ira limpar os descontos da tela
@param nDescParc, NumÈrico, Valor do desconto que ser· retirado
@param lMantemTFC , LÛgico, Define se ira deixar o valor de desconto da fidelizaÁ„o L1_DESCFID
	
@author  Vendas & CRM
@version P12
@since   29/03/2012
/*/
//-------------------------------------------------------------------
Function STIClearDisc(lLimpaDesc,nDescParc,lMantemTFC) // -- nDescParc = Valor de desconto parcial 
Local lDesTot	:= STBCDPGDes()
Local nDescTot	:= IIf( lDesTot , STDGPBasket("SL1","L1_DESCTOT") , 0 )//Valida se concedeu desconto no total da venda
Local oRaas 	:= Nil
Local oFidelityC:= Nil
Local nValDFidel:= 0

Default lLimpaDesc 	:= .F.
Default nDescParc 	:= 0
Default lMantemTFC	:= .F.

LjGrvLog( Nil, " Inicio - Limpeza de desconto - STIClearDisc")
LjGrvLog( Nil, " Zerando as referencias de desconto")

If ExistFunc("LjxRaasInt") .And. LjxRaasInt()		
	oRaas := STBGetRaas()
	If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
		oFidelityC := oRaas:GetFidelityCore()
		If oFidelityC:ChoseToUse()
			nValDFidel := oFidelityC:GetBonus()
		EndIf 
	EndIf 
EndIf

If lDesTot
	STDSPBasket("SL1","L1_DESCTOT", Iif( nValDFidel > 0,  nValDFidel , 0 ) )
EndIf

STBTaxAlt( "NF_DESCTOT"	, Iif( nValDFidel > 0, nValDFidel , 0 ) )

// -- Limpo a Variavel cReasonSelected que esta presente no fonte STIReasonForDiscont
If ExistFunc("STICleReason")
	STICleReason()
EndIf 

LjGrvLog( Nil, " Limpeza dos Totais ")
STFRefTot( 0 )

If lLimpaDesc //Optei por limpar todos os descontos pela tela de desconto 

	If !lMantemTFC
		STDSPBasket("SL1","L1_DESCFID",0)
	EndIf 

	If nDescParc > 0 .AND. nDescParc < nDescTot
		nDescTot :=  nDescTot - nDescParc
	Else
		nDescTot := 0 
	EndIf 
EndIf

/* So permito recalcular o desconto caso tenha sido 
dado no total da venda, para que o mesmo seja mantido*/
If lDesTot .And. nDescTot > 0
	LjGrvLog( Nil, " Valor de desconto no total preenchido, portanto o desconto sera somado ", nDescTot)
	LjGrvLog( Nil, " Para zerar o desconto no total da venda: faca o lancamento de desconto no valor de zero ")
	STBTaxAlt( "NF_DESCTOT"	, nDescTot)	
	LjGrvLog( Nil, " Limpeza dos Totais ")
	STFRefTot(nDescTot)	
EndIf

If ExistFunc("STBSetDiscTotPDV") .AND. nDescTot == 0
	STBSetDiscTotPDV( .F. ) 
EndIf

LjGrvLog( Nil, " Fim - Limpeza de desconto - STIClearDisc")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIDescImp
Valida valores de descontos provenientes da importacao de orcamento

@param nDescImp, numerico
@param nGetValue, numerico
@param nGetPerc , numerico
@author  Varejo
@version P12
@since   27/01/2020
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Function STIDescImp( nDescImp, nGetValue, nGetPerc)
Local nPerImp	:= 0
Local oTotal	:= STFGetTot() 	//Totalizador

Default nDescImp := 0
Default nGetValue:= 0
Default nGetPerc := 0

nDescImp := STBGetDscImp()
nPerImp	 := STBDiscConvert( nDescImp , 'V' , oTotal:GetValue( "L1_VALBRUT") )[2]
nGetValue+= nDescImp
nGetPerc += nPerImp

Return .T.

