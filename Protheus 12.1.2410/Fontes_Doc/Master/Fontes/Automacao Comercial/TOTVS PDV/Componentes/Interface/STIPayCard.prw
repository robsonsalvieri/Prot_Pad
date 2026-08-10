#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"
#INCLUDE "STIPAYCARD.CH"
#INCLUDE "STPOS.CH"

Static lCard		:= .F.		//Informa se a venda teve transacao em cartao
Static oModel 		:= Nil 		//Model de forma de pagamento cartao	
Static cCboAdmFin	:= ''		//Administradora financeira			
Static lPAFECF		:= STBIsPAF() //Verifica se È PAF-ECF
Static lHomolPaf	:= STBHomolPaf() //HomologaÁ„o PAF-ECF
Static lContTef 	:= .F. 		//Se ira utilizar a contingencia de passar no POS
Static nCards		:= 1		// Contador para quando importar um orÁamento com pagamento em mais de um cart„o
Static aJurosAdm	:= {.F.,"",0,0}		// Indica se teve c·lculo de Juros de Adm Financeira 
										//aJurosAdm[1] -> Tem Juros | aJurosAdm[2] -> Codigo da Adm | aJurosAdm[3] -> Aliquota | aJurosAdm[4] -> Valor dos Juros

Static oLblData 	:= Nil              //Objeto de Label Data
Static oGetData 	:= Nil              //Objeto de Get Data
Static cGetData		:= ''        		//Recebe valor de oGetData
Static oLblValor	:= Nil              //Objeto de Label Valor
Static oGetValor	:= Nil              //Objeto de Get Valor
Static cGetVal		:= STBCalcSald("1") //Apresenta o saldo restante do pagamento e recebe valor de oGetValor 
Static oLblParcels	:= Nil              //Objeto de Label Parcelas
Static oGetParcels	:= Nil              //Objeto de Get Parcelas
Static nGetParc		:= 1                //Recebe valor de oGetParcels
Static oBtnOk		:= Nil              //Objeto do botao Ok
Static oBtnCa		:= Nil              //Objeto do botao Cancelar 
Static oLblAdmFin	:= Nil				//Objeto de Label Adm Financeira
Static oCboAdmFin	:= Nil				//Objeto de Combo Adm Financiera
Static oLblNSU		:= Nil				//Objeto de Label NSU 
Static oGetNSU		:= Nil				//Objeto de Get NSU
Static cGetNSU		:= Space(TAMSx3("L4_NSUTEF")[1])		//Vaiavel Get NSU
Static oLblAutoiz	:= Nil				//Objeto de Label AutorizaÁ„o 
Static oGetAutoriz	:= Nil				//Objeto de Get AutorizaÁ„o
Static cGetAutoriz	:= Space(TAMSx3("L4_AUTORIZ")[1])		//Vaiavel Get AutorizaÁ„o
Static oLblJurAdm	:= Nil				/// Objeto Label Juros Adm Fin
Static oGetJurAdm	:= Nil				/// Objeto Get Juros Adm Fin
Static nGetJurAdm	:= Val(Space(TamSX3("L1_JUROS")[1]))	//Vaiavel Get Juros Adm Fin
Static aAdmFin		:= {}				// Array onde carrega as administradoras financeiras
Static lMultNeg     := .F.              // Verifica se foi usando Multi NegociaÁ„o 	
Static cCardEntra	:= ""               // Tipo do cart„o para o pagamento de entrada (CD ou CC)

//-----------------------------------------------------------------------------
/*{Protheus.doc} STIPayCard

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	28/01/2013
@return  	
@obs     
@sample
/*/
//-----------------------------------------------------------------------------
Function STIPayCard(oPnlAdconal,cTypeCard,nValue, nParcels )

Local nVlJuroAdm 	:= 0
Local lMVLJJURCC	:= SuperGetMV( "MV_LJJURCC",,.F. ) // calcula juros da Adm financeira
Local bChange		:= {|| STBCalcTax(cCboAdmFin, nGetParc, cGetVal, @nVlJuroAdm), nGetJurAdm := nVlJuroAdm, oGetJurAdm:Refresh()}
Local lReadOnly		:= STIGetPayRO()	//indica se os campos de pagamento est„o como Somente Leitura (permiss„o Alterar Parcelas do caixa)
Local lRecebTitle 	:= STIGetRecTit()	//Indica se eh recebimento de titulos
Local lReadOnTEF 	:= IIF(ExistFunc("LjVincPgEl"),LjVincPgEl(),.F.) //Verifica se obriga a digitaÁ„o do NSU e o cÛdigo de autorizaÁ„o

Default nValue 		:= 0
Default nParcels	:= 1                //Recebe valor de oGetParcels

cGetVal		:= STBCalcSald("1")
cGetNSU		:= Space(TAMSx3("L4_NSUTEF")[1])
cGetAutoriz	:= Space(TAMSx3("L4_AUTORIZ")[1])


If nValue > 0
	cGetVal := nValue
EndIf

If nParcels > 0
	nGetParc := nParcels
Else
	nParcels := 1	
EndIf

If IsPDOrPix(cTypeCard)  .AND. lContTef
	STISetContTef(.F.)	
EndIf

If lMVLJJURCC .AND. lContTef .AND. cTypeCard $ "CC|CD"
	cGetVal:= cGetVal - nGetJurAdm 
	nVlJuroAdm := nGetJurAdm
EndIf

If lContTef .OR. ((!STWChkTef("CC") .AND. cTypeCard == "CC") .Or. (!STWChkTef("CD") .AND. cTypeCard == "CD"))  .OR. (!STWChkTef("PD") .AND. cTypeCard == "PD") .OR. (!STWChkTef("PX") .AND. cTypeCard == "PX")
	If cTypeCard == 'CC'
		If lRecebTitle //quando È recebimento de tÌtulo, o vencimento È calculado no LojXRec
			cGetData := dDataBase 
		else
			cGetData := dDataBase + IIF(ValType(SuperGetMV("MV_LJINTER",Nil,'')) <> 'N',30,SuperGetMV("MV_LJINTER"))
		Endif 
		aAdmFin := STDAdmFinan('CC')
	ElseIf cTypeCard == 'CD'
		cGetData := dDataBase
		aAdmFin := STDAdmFinan('CD')
	EndIf

Else
	If cTypeCard == 'CC'
		If lRecebTitle //quando È recebimento de tÌtulo, o vencimento È calculado no LojXRec
			cGetData := dDataBase 
		Else
			cGetData := dDataBase + IIF(ValType(SuperGetMV("MV_LJINTER",Nil,'')) <> 'N',30,SuperGetMV("MV_LJINTER"))
		Endif 
	ElseIf cTypeCard == 'CD' .OR. cTypeCard == 'PD' .OR. cTypeCard == 'PX'
		cGetData := dDataBase
	EndIf

	If lMVLJJURCC
		aAdmFin := STDAdmFinan(cTypeCard)
	EndIf 
EndIf

If lContTef .Or. nCards == 1

	If STIFMultNeg() //Caso Seja multi NegociaÁ„o n„o pode altear o valor da parcelas e as parcelas. 
		lReadOnly := .T.
		lMultNeg  := .T.
	ElseIf lMultNeg
		lReadOnly := STIGetPayRO()
		lMultNeg  := .F.
	EndIf

	If oLblData <> Nil
		STIClnVar(.F.)
	EndIf
	
	 /* Label e Get: Data */
	oLblData := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,, ,,,,.T.,,,,8)
	oGetData := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetData:=u,cGetData)},oPnlAdconal,LARG_GET_DATE,ALTURAGET-5,,,,,,,,.T.,,,{||.F.},,,,,,,,,,,,.T.)
	
	oLblData:SetCSS( POSCSS (GetClassName(oLblData), CSS_LABEL_FOCAL )) 
	oGetData:SetCSS( POSCSS (GetClassName(oGetData), CSS_GET_NORMAL )) 
	
	 /* Label e Get: Valor */
	oLblValor := TSay():New(POSVERT_PAYLABEL1, 123, {||STR0002}, oPnlAdconal,, ,,,,.T.,,,,8)
	oGetValor := TGet():New(POSVERT_PAYGET1-2, 123,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,LARG_GET_VALOR,ALTURAGET,"@E 99,999,999.99",;
	{|| IIF(STIVldAltVP(nValue, nParcels), (STBCalcTax(cCboAdmFin, nGetParc, cGetVal, @nVlJuroAdm), nGetJurAdm := nVlJuroAdm, oGetJurAdm:Refresh()),( oGetParcels:Refresh(), oGetValor:Refresh()))},;
	,,,,,.T.,,,,,,,lReadOnly,,,,,,,,,.T.)
																																		
	oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
	oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_NORMAL )) 	

	/* Label e Get: Parcelas */
	oLblParcels := TSay():New(POSVERT_PAYLABEL1, 204, {||STR0003}, oPnlAdconal,, ,,,,.T.,,,,8)
	oGetParcels := TGet():New(POSVERT_PAYGET1-2, 204,{|u| If(PCount()>0,nGetParc:=u,nGetParc)},oPnlAdconal,40,ALTURAGET,"@E 9999",;
	{|| IIF(STIVldAltVP(nValue, nParcels), (STBCalcTax(cCboAdmFin, nGetParc, cGetVal, @nVlJuroAdm), nGetJurAdm := nVlJuroAdm, oGetJurAdm:Refresh()),( oGetParcels:Refresh(), oGetValor:Refresh()))},;
	,,,,,.T.,,,,,,,lReadOnly,,,,,,,,.T.)
	
	oLblParcels:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
	oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_NORMAL )) 

	/* Juros Adm. Fin. */
	oLblJurAdm  := TSay():New(POSVERT_PAYLABEL3, POSHOR_PAYCOL1, {|| STR0025}, oPnlAdconal,, ,,,,.T.,,,,8) // "Juros Adm. Fin."
	oGetJurAdm := TGet():New(POSVERT_PAYGET3-3,POSHOR_PAYCOL1,{|u| nGetJurAdm := nVlJuroAdm },oPnlAdconal,60,ALTURAGET-2,"@E 99,999,999.99",,,,,,,.T.,,,,,,,.T.,,,,,,,,.T.)
	
	oLblJurAdm:SetCSS(  POSCSS (GetClassName(oLblJurAdm), CSS_LABEL_FOCAL )) 
	oGetJurAdm:SetCSS( POSCSS (GetClassName(oGetJurAdm), CSS_GET_NORMAL ))

	oLblJurAdm:Hide()
	oGetJurAdm:Hide()
 

	//so exibe combo da administradora se estiver cadastrada
	If Len(aAdmFin) > 0
	
		/* Label e Get: Administradora Financeira */
		oLblAdmFin := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0007}, oPnlAdconal,, ,,,,.T.,,,,8) //'Adm.Financeira'
		oCboAdmFin := TComboBox():New(	POSVERT_PAYGET2-2	,POSHOR_PAYCOL1, {|u| If(PCount()>0,cCboAdmFin:=u,cCboAdmFin)}	, aAdmFin		,;
										LARG_GET_DATE+40, 80			, oPnlAdconal									, Nil			,; 
										bChange	, /* bValid*/	, /* nClrBack*/									, /* nClrText*/	,;
										.T./* lPixel*/	,  				, Nil											, Nil			,;
										/* bWhen*/		, Nil			, Nil											, Nil			,; 
										Nil				, cCboAdmFin	, /* cLabelText*/ 								,/* nLabelPos*/	,;
										Nil				, /*nLabelColor*/ )
		oCboAdmFin:lEditable := .T.
		oCboAdmFin:lListOnly := .T.
		oLblAdmFin:SetCSS( POSCSS (GetClassName(oLblAdmFin), CSS_LABEL_FOCAL )) 
		oCboAdmFin:SetCSS( POSCSS (GetClassName(oCboAdmFin), CSS_GET_NORMAL )) 
		oCboAdmFin:SetItems(aAdmFin) 
		
		

	EndIf	

	If lMVLJJURCC .AND. cTypeCard $ "CC|CD" .AND. oLblJurAdm <> Nil
		oLblJurAdm:Show()
		oGetJurAdm:Show()
	Endif 

	If lContTef .OR. ((!STWChkTef("CC") .AND. cTypeCard == "CC") .Or. (!STWChkTef("CD") .AND. cTypeCard == "CD"))  .OR. (!STWChkTef("PD") .AND. cTypeCard == "PD") .OR. (!STWChkTef("PX") .AND. cTypeCard == "PX")

		If oLblAdmFin <> Nil
			oLblAdmFin:Show()
			oCboAdmFin:Show()
		Endif 
		/* NSU */ 
		oLblNSU := TSay():New(POSVERT_PAYLABEL2, 123 , {||STR0011}, oPnlAdconal,, ,,,,.T.,,,,8) // "NSU" 
		oGetNSU := TGet():New(POSVERT_PAYGET2-2, 123 ,{|u| If(PCount()>0,cGetNSU:=u,cGetNSU)},oPnlAdconal,80,ALTURAGET,"@! " + Replicate("N",Len(cGetNSU)),,,,,,,.T.,,,,,,,lReadOnTEF,,,,,,,,.T.)
		
		oLblNSU:SetCSS( POSCSS (GetClassName(oLblNSU), CSS_LABEL_FOCAL )) 
		oGetNSU:SetCSS( POSCSS (GetClassName(oGetNSU), CSS_GET_NORMAL )) 
		
		/* AutorizaÁ„o */
		oLblAutoiz  := TSay():New(POSVERT_PAYLABEL2, 204, {|| STR0012}, oPnlAdconal,, ,,,,.T.,,,,8) // "AutorizaÁ„o" 
		oGetAutoriz := TGet():New(POSVERT_PAYGET2-2, 204,{|u| If(PCount()>0,cGetAutoriz:=u,cGetAutoriz)},oPnlAdconal,40,ALTURAGET,"@! " + Replicate("N",Len(cGetAutoriz)),,,,,,,.T.,,,,,,,lReadOnTEF,,,,,,,,.T.)
		
		oLblAutoiz:SetCSS(  POSCSS (GetClassName(oLblAutoiz), CSS_LABEL_FOCAL )) 
		oGetAutoriz:SetCSS( POSCSS (GetClassName(oGetAutoriz), CSS_GET_NORMAL ))	
 
	EndIf
	
EndIf

Iif (cTypeCard == "CC",(oGetParcels:Show(),oLblParcels:Show()),(oGetParcels:Hide(),oLblParcels:Hide()))

If STBIsImpOrc() .AND.  (lContTef .Or. nCards > 1) .AND. Len(aAdmFin) > 0 .AND. oCboAdmFin <> NIL 
	oCboAdmFin:SetItems(aAdmFin)    
EndIf

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0004,oPnlAdconal,{|| iIf( !FindFunction("STBValFormPay") .Or. STBValFormPay(cTypeCard,cGetVal,nGetParc), STICCConfPay(oGetData, oGetValor, oGetParcels, oPnlAdconal, cTypeCard , lContTef , cGetNSU , cGetAutoriz, nGetParc), Nil) },LARGBTN,ALTURABTN,,,,.T.)
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 

If lContTef .Or. nCards == 1
	/* Button: Cancelar */
	oBtnCa := TButton():New(POSVERT_BTNPAY,00,STR0005,oPnlAdconal,{|| Iif(ExistFunc("STBCancPay"), iif(STBCancPay(), ( STIPayCancel(oPnlAdconal), STISetContTef(.F.), STIClnVar(.T.) ),NIL),( STIPayCancel(oPnlAdconal), STISetContTef(.F.), STIClnVar(.T.))) },LARGBTN,ALTURABTN,,,,.T.)
	oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO ))
EndIf

If lContTef .AND. Len(aAdmFin) = 0
	STIPayCancel(oPnlAdconal)
	STFMessage(ProcName(),"STOP",STR0024)  //"N„o foi encontrado Administradora para a Forma de Pagamento Informada."
	STFShowMessage(ProcName())
EndIf

oGetValor:SetFocus()

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	28/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function ModelCard()

Local oStruMst 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela

oModel := MPFormModel():New('STIPayCard')
oModel:SetDescription("Cartao")

oStruMst:AddTable("SL4",{"L4_FILIAL"},"Cartao")

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'CARDMASTER', Nil, oStruMst)

Return oModel

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod
Estrutura do Model

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	29/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStru)

Default oStru := Nil

oStru:AddField(	STR0006		,; //[01] Titulo do campo
					STR0006		,; //[02] Desc do campo
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
					.T.				)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0001		,; //[01] Titulo do campo
					STR0001		,; //[02] Desc do campo
					"L4_DATA"	,; //[03] Id do Field
					"D"			,; //[04] Tipo do campo
					8			,; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					FwBuildFeature( STRUCT_FEATURE_INIPAD,"dDataBase" ),; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0002	,; //[01] Titulo do campo
					STR0002	,; //[02] Desc do campo
					"L4_VALOR"	,; //[03] Id do Field
					"N"			,; //[04] Tipo do campo
					16			,; //[05] Tamanho do campo
					2			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0003	,; //[01] Titulo do campo
					STR0003	,; //[02] Desc do campo
					"L4_PARC"	,; //[03] Id do Field
					"N"			,; //[04] Tipo do campo
					10			,; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0008 ,; //[01] Titulo do campo   //'Adm.Finan'
					STR0008 ,; //[02] Desc do campo  	//'Adm.Finan'
					"L4_ADMINIS",; //[03] Id do Field
					"C"			,; //[04] Tipo do campo
					TamSx3('L4_ADMINIS')[1],; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual
					
oStru:AddField(		STR0011 	,; //[01] Titulo do campo   //"NSU"	
					STR0011 	,; //[02] Desc do campo  	//"NSU"
					"L4_NSUTEF"	,; //[03] Id do Field
					"C"			,; //[04] Tipo do campo
					TamSx3('L4_NSUTEF')[1],; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual
					
oStru:AddField(		STR0012 	,; //[01] Titulo do campo   //"AutorizaÁ„o" 
					STR0012 	,; //[02] Desc do campo  	//"AutorizaÁ„o"
					"L4_AUTORIZ",; //[03] Id do Field
					"C"			,; //[04] Tipo do campo
					TamSx3('L4_AUTORIZ')[1],; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual
					
oStru:AddField(		STR0020					,; //[01] Titulo do campo   //'ID Cart‰o' 
					STR0021 				,; //[02] Desc do campo  	//'Identific. Cart‰o'
					"L4_FORMAID"			,; //[03] Id do Field
					"C"						,; //[04] Tipo do campo
					TamSX3('L4_FORMAID')[1]	,; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(		STR0026 	,; //[01] Titulo do campo   //"Doc. TEF" 
					STR0026 	,; //[02] Desc do campo  	//"Doc. TEF"
					"L4_DOCTEF",;  //[03] Id do Field
					"C"			,; //[04] Tipo do campo
					TamSx3('L4_DOCTEF')[1],; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

If SL4->(ColumnPos("L4_ACRCART")) > 0
	oStru:AddField(		STR0027 	,; //[01] Titulo do campo   //"Acrs. Cart„o"
						STR0028 	,; //[02] Desc do campo  	//"AcrÈscimo Cart„o"
						"L4_ACRCART",;  //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						14			,; //[05] Tamanho do campo
						2			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.			)  //[14] Indica se o campo e virtual
EndIf

Return oStru

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STICCConfPay
Confirma o pagamento da transacao

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	29/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STICCConfPay(	oGetData	, 	oGetValor	, oGetParcels	, oPnlAdconal, ;
						cTypeCard 	,	lPContTef	, cGetNSU 		, cGetAutoriz, ;
						nParcel 	) 

Local oMdl 			:= Nil								//Recupera o model ativo
Local oTEF20		:= Nil								//Obj TEF
Local lRet			:= .T.								//Retorno da ValidaÁ„o
Local nTotPago	 	:= 0								//total Pago
Local nTotVenda 	:= 0								//total da Venda
Local lRecebTitle 	:= STIGetRecTit()					//Indica se eh recebimento de titulos
Local lValidaNSU	:= SuperGetMv( "MV_LJNSU",,.T. )	//NSU e AutorizaÁ„o obrigatÛrios para Cart„o de CrÈdito
Local aCallADM		:= {}								//Array com os dados de pagamento do orÁamento importado 
Local lConfPay		:= .T.								//Valida se o pagamento com TEF foi efetuado com sucesso
Local lLJRMBAC		:= SuperGetMV("MV_LJRMBAC",,.F.)  	//Habilita a integraÁ„o com RM 
Local lPromPgto		:= SuperGetMv("MV_LJRGDES",,.F.) .And. STBPromPgto(cTypeCard)  //Verifica se existe promocao para as formas de pagamento CC ou CD
Local nTotDA1		:= IIF(ExistFunc('STDGetDA1'),STDGetDA1(),0)			//Verifica se houve desconto no total atraves de uma regra de desconto
Local lFuncPromo	:= ExistFunc('STBVldDesc') .AND. ExistFunc('STBSetReg') //Verifica se existe as funcoes de promocao
Local lVldDigNSU 	:= !IIF(ExistFunc("LjVincPgEl"),LjVincPgEl(),.F.) //Verifica se obriga a digitaÁ„o do NSU e o cÛdigo de autorizaÁ„o
Local lIsPgtPOS     := !lVldDigNSU

Default lPContTef 	:= .F.
Default cGetNSU 	:= ""
Default cGetAutoriz := ""
Default nParcel 	:= IIF(ValType(oGetParcels) == 'O', Val(oGetParcels:cText) , 1)

If !Empty(cCardEntra) .AND. STIGetMult()
	cTypeCard  := cCardEntra
	cCardEntra := ""
EndIf

//Parcela tem que ser 1 - mesmo se for a vista
If nParcel < 1
	nParcel := 1
EndIf

ModelCard()
oMdl := oModel:GetModel("CARDMASTER")

oMdl:DeActivate()
oMdl:Activate()

oMdl:LoadValue("L4_FILIAL", xFilial("SL4"))

If lLJRMBAC .AND. !Empty(cCboAdmFin) .AND. cTypeCard == "CD" .AND. ExistFunc("STDGetDias")
	oMdl:LoadValue("L4_DATA", oGetData:cText + STDGetDias(SubStr(cCboAdmFin,1,TamSx3('L4_ADMINIS')[1])))
Else
	oMdl:LoadValue("L4_DATA", oGetData:cText)	
EndIf 

oMdl:LoadValue("L4_VALOR", oGetValor:cText + oGetJurAdm:cText)
If SL4->(ColumnPos("L4_ACRCART")) > 0
	oMdl:LoadValue("L4_ACRCART", oGetJurAdm:cText)
EndIf
oMdl:LoadValue("L4_PARC", nParcel)
oMdl:LoadValue("L4_ADMINIS", SubStr(cCboAdmFin,1,TamSx3('L4_ADMINIS')[1]))

If !Empty(cGetNSU)
	oMdl:LoadValue("L4_NSUTEF", cGetNSU)
	oMdl:LoadValue("L4_DOCTEF", cGetNSU)
EndIf
If !Empty(cGetAutoriz)
	oMdl:LoadValue("L4_AUTORIZ", cGetAutoriz)
EndIf

nTotPago  := STIGetTotal() + oGetValor:cText + oGetJurAdm:cText //Retorna o Total Pago
nTotVenda := STDGPBasket( "SL1" , "L1_VLRTOT" ) + oGetJurAdm:cText
/* 
	Verificar se o cliente deseja doar para o Instituto Arredondar	
*/
If cTypeCard $ "CC|CD"	//Ideal perguntar antes do TEF
	STBInsArredondar(AllTrim(cTypeCard))
EndIf

//Nao permite troco em cartao, em caso de homologacao de PAF, dever· ser realizado tratamento por meio de lHomolog
If !lRecebTitle .AND. nTotPago > nTotVenda
	If ((STWChkTef("CC") .Or. cTypeCard == "CC") .Or. (STWChkTef("CD") .Or. cTypeCard == "CD") .Or. (STWChkTef("PD") .Or. cTypeCard == "PD") .Or. (STWChkTef("PX") .Or. cTypeCard == "PX"))
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0009 )	// "Valor informado superior ao saldo a pagar. N„o È permitido troco em cart„o."
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())
	EndIf		
EndIf

//Valida a digitaÁ„o do NSU e cÛdigo de autorizaÁ„o
If lVldDigNSU
	If lValidaNSU .AND. (lPContTef .OR. (!STWChkTef("CC") .AND. cTypeCard $ "CC|CD")) .AND. (Empty(cGetNSU) .OR. Empty(cGetAutoriz))
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0022) //"Por favor, preencha o cÛdigo NSU e o cÛdigo de autorizaÁ„o!"
		STFShowMessage(ProcName())	
	EndIf
EndIf

If lRet .AND. lPromPgto .AND. lFuncPromo .AND. nTotDA1 > 0
	STBVldDesc('2',,oMdl:GetValue("L4_VALOR"))
	STBSetReg(.T.)
EndIf

If lRet

    STIBtnDeActivate()	

	If lHomolPaf
		STFCleanInterfaceMessage()
	EndIf
	
	
	oTEF20 := STBGetTEF()
	//Verifica se a transacao foi realizada com sucesso
	lConfPay := STWTypeTran(oMdl, oTEF20, cTypeCard, nParcel, lPContTef)

	If lIsPgtPOS .And. ExistFunc("LJBldVlRST") .And. cTypeCard $ "CC|CD"
		LJBldVlRST( !lConfPay )  
	EndIf 
	
	aCallADM := STIGetaCallADM() 
	aFormMultNeg := IIf(ExistFunc("STIGetFormMN"), STIGetFormMN(), {})

	If STBIsImpOrc() .And. Len(aCallADM) > 1 .And. (nCards < Len(aCallADM) .Or. !lConfPay) .And. (  aCallADM[nCards + IIF(lConfPay, 1, 0) ,5] $ "CC|CD" )     
        If lConfPay
            nCards += 1
        EndIf
		// Atualiza os valores do Painel para o proximo Cart„o
		STIPayCard(oPnlAdconal, aCallAdm[nCards][5], aCallAdm[nCards][2], aCallAdm[nCards][3])
	ElseIf STIGetMult() .And. Len(aFormMultNeg) > 1 .And. aFormMultNeg[nCards][4] .And. aFormMultNeg[nCards + IIF(lConfPay, 1, 0)][1] $ "CC|CD|PX"
		// Atualiza os valores do Painel para o proximo Cart„o da Multinegociacao
		STIPayCard(oPnlAdconal, aFormMultNeg[nCards][1], aFormMultNeg[nCards][2], aFormMultNeg[nCards][3])

		cCardEntra := aFormMultNeg[nCards][1]

		If lConfPay
            nCards += 1
        EndIf
	Else
		
		If !lContTef // Se tiver em contingencia do TEF n„o limpa os objetos
		   	// Limpa objetos da tela de cart„o
		   	STIClnVar(.T.)
		EndIf
		
		nCards := 1
		oPnlAdconal:Hide()
		
		STIEnblPaymentOptions()
	EndIf

	STIBtnActivate()

EndIf
		
Return lRet


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGetCard
Retorna que teve transacao TEF

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGetCard()
Return lCard

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STISetCard
Seta a variavel lCard para .F.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetCard(lCartao)

Default lCartao := .F.

lCard := lCartao

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STISetTef
Set no objeto do TEF

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	27/03/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetTef(oTEF)
oTEF20 := oTEF
Return .T.


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STICardOrc
Chamada somente quando for importacao de orcamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STICardOrc(dDate, nValor, nParcels, cAdm, cTypeCard)

Local oMdl 	:= Nil		//Recupera o model ativo
Local oTEF20	:= Nil		//Obj TEF

Default nParcels := 1

//Parcela tem que ser 1 - mesmo se for a vista
If nParcels < 1
	nParcels := 1
EndIf

ModelCard()
oMdl := oModel:GetModel("CARDMASTER")

oMdl:DeActivate()
oMdl:Activate()

oMdl:LoadValue("L4_FILIAL", xFilial("SL4"))
oMdl:LoadValue("L4_DATA", dDate)
oMdl:LoadValue("L4_VALOR", nValor)
oMdl:LoadValue("L4_PARC", nParcels)
oMdl:LoadValue("L4_ADMINIS", cAdm)

oTEF20 := STBGetTEF()

STWTypeTran(oMdl, oTEF20, cTypeCard)

Return .T.
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STISetContTef
Informa a variavel Static que o usuario quer passar o 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetContTef(lCont)
lContTef := lCont
Return .T.


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STICrdSlAdm
SeleÁ„o da administradora Financeira
@param  aAdmSel - Array das Administradoras com as formas de pagamento
@param  nValor - Valor do pagamento
@param 	cAdmin - Administradora Financeira
@author  	Vendas & CRM
@version 	P12
@since   	24/02/2015
@return  	aRet - Array com os dados da adminsitradora Financeira selecionada
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STICrdSlAdm(aAdmSel, nValor, cAdmin, lIsCard)

Local aRet := {} //Retorno da Rotina
Local nPosAdm	:= 0 //Retorna a Adm selecionada
Local aCoordAdms    := MsAdvSize(.T.)  //Vetor com as coordenadas da tela
Local oDlgAdms      := Nil  //Objeto com a tela de escolha das Administradoras
Local oListAdms     := Nil  //Listbox com as administradoras cadastradas
Local cTitle		:= "" //Titulo da Tela
Local cMsgTela 		:= "" //mensagem da Tela
Local aAdmTmp			:= {} //Array temporario

DEFAULT	aAdmSel	:= {}
Default nValor 	:= 0
Default cAdmin 	:= ""
Default lIsCard := .T. //Define se È selecao de Adm. Financeira para Cart„o ou N„o

If lIsCard
	cTitle   := STR0014 //"SeleÁ„o da Administradora de Cart„o de CrÈdito/DÈbito"
	cMsgTela := STR0013 + cAdmin//"Selecione a administradora do cart„o: "
Else
	cTitle   := STR0019 //"Selecione a administradora"
	cMsgTela := STR0019 //"Selecione a administradora"
EndIf

If Len(aAdmSel) == 1
	// Caso existir somente uma adm financeira para a forma de pagamento seleciona automaticamente, sem mostrar a tela. 
	nPosAdm:= 1
Else
	Aeval(aAdmSel, { | l | aAdd(aAdmTmp, {.f.,  l[1], l[2], l[3] })})
	//Se nao foi identificada a Administradora, obriga que usuario selecione uma das administradoras validas
	While nPosAdm <= 0
		oDlgAdms := TDialog():New(000,000,aCoordAdms[6]/2,aCoordAdms[5]/2,OemToAnsi(cTitle),,,,,,,,oMainWnd,.T.)
			TSay():New(005,003,{|| cMsgTela },oDlgAdms,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,oDlgAdms:nClientWidth/2-7,008)
			TGroup():New(015,003,oDlgAdms:nClientHeight/2-30,oDlgAdms:nClientWidth/2-7,STR0015,oDlgAdms,,,.T.,.F. ) //"Lista das Administradoras Cadastradas"
				oListAdms := TWBrowse():New(025,005,oDlgAdms:nClientWidth/2-15,oDlgAdms:nClientHeight/2-58,,{" ",STR0016, STR0017,STR0018,},,oDlgAdms,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Codigo"#"Tipo"#"Administradora"
					oListAdms:SetArray(aAdmTmp)
					oListAdms:bLDblClick := {||	STICrdLblClick(@oListAdms,@aAdmTmp,@nPosAdm) }

					oListAdms:bLine := {||{ IIf(aAdmTmp[oListAdms:nAt][1],LoadBitmap( GetResources(), "CHECKED" ),LoadBitmap( GetResources(), "UNCHECKED" )),;
											aAdmTmp[oListAdms:nAt][2],;
											aAdmTmp[oListAdms:nAt][3],;
											aAdmTmp[oListAdms:nAt][4] }}
			TButton():New(oDlgAdms:nClientHeight/2-27,003,OemToAnsi("&Ok"),oDlgAdms,{|| oDlgAdms:End() },040,010,,,,.T.,,,,{|| })
		oDlgAdms:Activate(,,,.T.)
	EndDo
Endif 

If nPosAdm > 0
	aRet := aAdd(aRet, {aClone(aAdmSel[nPosAdm])})
EndIf

Return aRet	


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STICrdLblClick
FunÁ„o associada ao evento duploclique do grid de administradoras
@param  oListAdms - Array das Administradoras com as formas de pagamento
@param  aListAdms - Array de administradoras financeiras
@param 	nPosAdm - Posicao da administradora selecionada
@author  	Vendas & CRM
@version 	P12
@since   	24/02/2015
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STICrdLblClick(oListAdms,aListAdms,nPosAdm)
Local nI := 0 //contador

Default oListAdms := NIL
Default aListAdms := {}
Default nPosAdm := 0

aListAdms[oListAdms:nAt,1] := !aListAdms[oListAdms:nAt,1]

For nI := 1 To Len(aListAdms)
	If nI <> oListAdms:nAt
		aListAdms[nI,1] := .F.
	EndIf
Next nI

nPosAdm := oListAdms:nAt                  
oListAdms:Refresh()

Return(Nil)


//------------------------------------------------------------------------------
/*{Protheus.doc} STIClnVar
FunÁ„o para limpar os objetos Static da criaÁ„o da tela de cart„o
@param   	
@author  	eduardo.sales
@version 	P12
@since   	07/02/2017
@return  	Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------
Static Function STIClnVar(lAll) 


IIf (ValType(oLblData)		== 	'O', (oLblData		:= Nil, FreeObj( oLblData )	  ), Nil)
IIf (ValType(oGetData) 		== 	'O', (oGetData 		:= Nil, FreeObj( oGetData )	  ), Nil)
IIf (ValType(oLblValor) 	== 	'O', (oLblValor		:= Nil, FreeObj( oLblValor )  ), Nil)
IIf (ValType(oGetValor) 	== 	'O', (oGetValor		:= Nil, FreeObj( oGetValor )  ), Nil) 
IIf (ValType(oLblParcels) 	== 	'O', (oLblParcels	:= Nil, FreeObj( oLblParcels )), Nil)
IIf (ValType(oGetParcels) 	== 	'O', (oGetParcels	:= Nil, FreeObj( oGetParcels )), Nil)
IIf (ValType(oBtnOk) 		== 	'O', (oBtnOk		:= Nil, FreeObj( oBtnOk )     ), Nil)
IIf (ValType(oBtnCa) 		== 	'O', (oBtnCa		:= Nil, FreeObj( oBtnCa )	  ), Nil)
IIf (ValType(oLblAdmFin) 	== 	'O', (oLblAdmFin	:= Nil, FreeObj( oLblAdmFin ) ), Nil)
IIf (ValType(oCboAdmFin) 	== 	'O', (oCboAdmFin	:= Nil, FreeObj( oCboAdmFin ) ), Nil)
IIf (ValType(oLblNSU) 		== 	'O', (oLblNSU		:= Nil, FreeObj( oLblNSU )    ), Nil)
IIf (ValType(oGetNSU) 		== 	'O', (oGetNSU		:= Nil, FreeObj( oGetNSU )    ), Nil)
IIf (ValType(oLblAutoiz) 	== 	'O', (oLblAutoiz	:= Nil, FreeObj( oLblAutoiz	) ), Nil)
IIf (ValType(oGetAutoriz) 	== 	'O', (oGetAutoriz	:= Nil, FreeObj( oGetAutoriz )), Nil)
IIf (ValType(oGetJurAdm) 	== 	'O', (oGetJurAdm	:= Nil, FreeObj( oGetJurAdm ) ), Nil)
IIf (ValType(oLblAdmFin) 	== 	'O', (oLblAdmFin	:= Nil, FreeObj( oLblAdmFin ) ), Nil)

If lAll
	cGetData	:= ""
	cGetVal		:= ""
	cGetNSU		:= ""
	cGetAutoriz	:= ""
	nGetParc	:= 1
	aAdmFin		:= {}
	nCards		:= 1
	nGetJurAdm	:= 0
EndIf

Return .T.
//------------------------------------------------------------------------------
/*{Protheus.doc} STISetnCards
FunÁ„o para Setar a vari·vel contadora de cart„o
@param      
@author     fabiana.silva
@version    P12
@since      19/04/2017
@return     nCards
@obs     
@sample
/*/
//------------------------------------------------------------------------------
Function STISetnCards(nCard)
Default nCard := 1

nCards := nCard

Return nCards

/*/{Protheus.doc} STIGetAJur
Retorna o array aJurosAdm

@param   	
@author  	joao.marcos
@version 	P12
@since   	08/06/2021
@return  	aJurosAdm
@obs     
@sample
/*/
Function STIGetAJur()
Return aJurosAdm

/*/{Protheus.doc} STISetAJur
Seta valor ao array aJurosAdm

@param   	
@author  	joao.marcos
@version 	P12
@since   	08/06/2021
@param aJuros, array, dados dos juros da Adm
@return  	
@obs     
@sample
/*/
Function STISetAJur(aJuros)

Default aJuros := {.F.,"",0,0}

aJurosAdm := aJuros

Return


/*/{Protheus.doc} STIClrObj
	Limpa os objetos da interface de Pagamento com Cart„o
	@type  Function
	@author caio.okamoto
	@since 07/12/2022
	@version 12.1.2210
	/*/
Function STIClrObj()

If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
Endif 

STIClnVar(.T.)
	
Return 


/*/{Protheus.doc} STIVldAltVP
	valida a permiss„o se pode alterar o valor e parcela das formas CC e CD
	@type  Function
	@author caio.okamoto
	@since 22/07/2025
	@version 12
	@param nValue	, numÈrico	, valor original da forma de pagamento
	@param nParcels	, numÈrico	, valor original da parcela
	@return lRet	, lÛgico	, .T. permite alterar valor e parcela, .F., n„o permite
	/*/
Static Function STIVldAltVP(nValue, nParcels)
Local lRet := .T. 

If  STBIsImpOrc() .AND. !Empty(STIGetPgOr()) .AND. (cGetVal <> nValue .OR. nGetParc <> nParcels) .AND. !STFPROFILE(44)[1]
	lRet:= .F.
	STFMessage( ProcName(),"POPUP", STR0029)
	STFShowMessage( ProcName() )
	cGetVal:= nValue
	nGetParc:= nParcels
Endif 

Return lRet 

