#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIValePresente.CH"

Static oPanGetValPre	:= Nil
Static cQtdDesc		:= ''
Static cVale			:= {}
Static oLblLimiteVP	:= Nil
Static aVpMinMax		:= {}
Static oVlrVP			:= Nil
Static nVlrVP			:= 0
Static oLblDescricao	:= Nil
Static cCodVPre 		:= ""

//-------------------------------------------------------------------
/*{Protheus.doc} STIValPre
Abre a tela de vale presente

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIValPre()

Local lVPProd  := SuperGetMv("MV_LJVPPRO",,.F.) //Permite vender Vale Presente e produtos na mesma venda 

If  (!lVPProd .And. !STBExistItemFiscal(.F.)) .Or. lVPProd
	STIChangeCssBtn('oBtnRegItem')
	STIExchangePanel( { ||  STIValePresente() } )
Else
	STFMessage(ProcName(0),"STOP",STR0014) //"A venda do vale presente deve ser feita separada."
	STFShowMessage(ProcName(0))
EndIf

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} STIValePresente
Monta a tela de vale presente

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIValePresente()

Local oPanelMVC	:= STIGetPanel()
Local oLblCab		:= Nil
Local oLblCodProd	:= Nil
Local nMddCodigo	:= TamSX3('MDD_CODIGO')[1] //tamanho do campo MDD_CODIGO
Local cGetProd	:= Space(nMddCodigo)
Local oLblHelpGet	:= Nil
Local oCodProd	:= Nil
Local oLblInfProd	:= Nil
Local cTipoVp		:= "P"

nVlrVP				:= 0

oPanGetValPre		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)

/* Objetos */
oLblCab := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetValPre,,,,,,.T.,,,,) //"Vale Presente"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oLblCodProd := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0002},oPanGetValPre,,,,,,.T.,,,,) //"Código do Vale Presente"
oLblCodProd:SetCSS( POSCSS (GetClassName(oLblCodProd), CSS_LABEL_FOCAL ))

oCodProd := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetProd:=u,cGetProd)},oPanGetValPre,170,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetProd")
oCodProd:SetCSS( POSCSS (GetClassName(oCodProd), CSS_GET_FOCAL )) 

//Venda valor variável do vale presente
If SuperGetMV("MV_LJVPVAR",,.F.)

	oCodProd:bLostFocus := {|| nVlrVP := 0, oLblLimiteVP:SetText(""), oLblDescricao:SetText("") , oVlrVP:lReadOnly := .T. } //reseta os campos

	oButtonVP := TButton():New(POSVERT_GET1 ,POSHOR_1 * 14,STR0008,oPanGetValPre,{ || nVlrVP := 0, aVpMinMax := STBGetMinMaxVP(cGetProd), STIUpdMinMaxVP(),;
																								 (cTipoVp := iIf(len(aVpMinMax)>2,aVpMinMax[3],cTipoVp)) },40,15,,,,.T.) //"Buscar Vale Presente"
	oButtonVP:SetCSS( POSCSS (GetClassName(oButtonVP), CSS_BTN_FOCAL ))
	
	//Descrição do produto:
	oLblDescricao := TSay():New(oPanGetValPre:nHeight/7.55,POSHOR_1,{||"                               "},oPanGetValPre,,,,,,.T.,,,,) //Campo de descricao do produto.
	oLblDescricao:SetCSS( POSCSS (GetClassName(oLblDescricao), CSS_LABEL_FOCAL ))
	
	//Valores do Vale Presente (Min e Max:
	oLblLimiteVP := TSay():New(oPanGetValPre:nHeight/6.30,POSHOR_1 ,{||"                               "},oPanGetValPre,,,,,,.T.,,,,) //Valores: Min - Max
	oLblLimiteVP:SetCSS( POSCSS (GetClassName(oLblLimiteVP), CSS_LABEL_FOCAL )) 
	
	//Valor do vale presente:
	oLblVlrVP := TSay():New(oPanGetValPre:nHeight/5.30,POSHOR_1,{||STR0009},oPanGetValPre,,,,,,.T.,,,,) //"Valor do vale presente"
	oLblVlrVP:SetCSS( POSCSS (GetClassName(oLblVlrVP), CSS_LABEL_FOCAL )) 

	//Campo para informar o valor
	oVlrVP := TGet():New(oPanGetValPre:nHeight/4.90,POSHOR_1,{|u| If(PCount()>0,nVlrVP:=u,nVlrVP)},oPanGetValPre,100,ALTURAGET,"@E 99,999,999.99",,,,,,,.T.,,,,,,,,,,) //Informar valor do vale presente
	oVlrVP:SetCSS( POSCSS (GetClassName(oVlrVP), CSS_GET_FOCAL ))
	
	oVlrVP:lReadOnly := .T.
EndIf

oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0001,oPanGetValPre,{ || STISelValePresente(cGetProd,cTipoVp) ,oCodProd:SetFocus() }, ; //"Vale Presente"
							LARGBTN,ALTURABTN,,,,.T.)
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

oCodProd:SetFocus()

Return(oPanGetValPre)

//-------------------------------------------------------------------
/*{Protheus.doc} STISelValePresente
Seleciona o vale presente na retaguarda

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STISelValePresente(cGetCodPres,cTipoVp)

Local uResult			:= Nil     																//Resultado
Local lRet				:= .F.																	//Retorno
Local cStatus			:= '0'																	//Status
Local lMVLJVPAR			:= SuperGetMV("MV_LJVPVAR",,.F.)										//Venda de vale presente valor variável
Local lContinua			:= .T. 																	//Controla o fluxo do processo
Local lVPImpFiscal		:= .F. 																	//Define se o item de vale presente é impresso em cupom fiscal
Local lExistVP			:= IIF(FindFunction("STDVldVP"),!STDVldVP(cGetCodPres,cTipoVp),.F.)		//Valida se o vale presente já foi registrado
Local cTipo				:= ""																	//Tipo do Vale - P=Presente ou C=Credito
Local aRet 				:= {}																	//Retorno da Busca do item encontrado  	

Default cGetCodPres := ""

/*Validacao do vale presente*/
If lExistVP 

	If SuperGetMV("MV_LJVPCNF",,.F.) //verifica se imprime vale presente no cupom não fiscal
		 lVPImpFiscal := .T. 		 //como não imprime em cupom fiscal desabilita esta variavel
	EndIf
	
	lRet := STBRemoteExecute("STBGDatPre" ,{cGetCodPres}, NIL,.F.,@uResult)

	If ValType(uResult) == 'A'
	
		If Len(uResult) > 0
			cStatus := uResult[1][1]
		EndIf
				
		If cStatus == '0'
		
			STFMessage(ProcName(0),"STOP",STR0003) //"Vale Presente não encontrado!"
			STFShowMessage(ProcName(0))

		ElseIf cStatus == '1'
		
			nPrice 			:= 		uResult[1][2]
			cGetProd 		:=  	uResult[1][3]
			If Len(uResult[1]) > 3
				cTipo		:= 		uResult[1][4]
			EndIf

			If Len(uResult[1]) >= 5 .AND. uResult[1][5]< DATE() 
				STFMessage(ProcName(0),"STOP",STR0028) //Vale Presente/Crédito Vencido!
				STFShowMessage(ProcName(0))
			Else
				aRet := STWFindItem(cGetProd)
				If len(aRet) > 0 .AND. aRet[1]

					cVale := cGetCodPres

					//Seta o valor do produto
					If lMVLJVPAR .AND. Len(aVpMinMax) > 0  .AND. !oVlrVP:lReadOnly 
						//Verifica se o valor esta no Range limite para venda do vale presente
						If nVlrVP > 0  .AND. (aVpMinMax[1] > 0 .AND. aVpMinMax[2] > 0) .AND. (nVlrVP >= aVpMinMax[1] .AND. nVlrVP <= aVpMinMax[2])
							nPrice := nVlrVP
							STBSetVlrVP(cVale,nPrice)
						Else
							STFMessage(ProcName(0),"STOP",STR0010 + AllTrim(Str(aVpMinMax[1])) + STR0011 + AllTrim(Str(aVpMinMax[2])) ) //O valor do vale presente informado deve ser maior que R$00,00 e menor que R$00,00
							STFShowMessage(ProcName(0))	
							lContinua := .F.
						EndIf	 
					EndIf

					//Valida se o cliente foi informado quando o tipo do vale for credito.
					If lContinua
						lContinua := STIValidVP(cTipo,cGetProd)
					EndIf
					
					If lContinua
						
						STBSetCodVP(cVale) //Guarda Codigo do Vale Presente
						
						STBSetPric(nPrice)

						//Registra o Item
						STIItemRegister( cGetProd, lVPImpFiscal ) 
					
						//Abre Registro do Item
						STIExchangePanel( { ||  STIPanItemRegister() } )

					EndIf
				Else
					STFMessage(ProcName(0),"STOP",STR0019) 	//"Produto Vale Presente/Crédito não encontrado no PDV"
					STFShowMessage(ProcName(0))
				EndIf  
			Endif 
		ElseIf cStatus == '2'
			STFMessage(ProcName(0),"STOP",STR0004) 		//"Vale Presente/Crédito já foi vendido!"
			STFShowMessage(ProcName(0))
		ElseIf cStatus == '3'
			STFMessage(ProcName(0),"STOP",STR0005)		//"Vale Presente/Crédito já foi utilizado!"
			STFShowMessage(ProcName(0))
		ElseIf cStatus == '4'
			STFMessage(ProcName(0),"STOP",STR0006) 		//"Vale Presente/Crédito cancelado!"
			STFShowMessage(ProcName(0))
		EndIf
	Else
		STFMessage(ProcName(0),"STOP",STR0007) 			//"Sem Conexao com a Retaguarda!"
		STFShowMessage(ProcName(0))
	
	EndIf
Else
	STFMessage(ProcName(0),"STOP",STR0013) 				//"Vale presente/Crédito já registrado ou não foi possível validar." 
	STFShowMessage(ProcName(0))
EndIf	

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STBGDatPre
Funcao retorna o vale presente

@param   cCodVP   Codigo do vale presente
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGDatPre(cCodVP)

Local aArea 		:= GetArea()              			// Guarda area corrente
Local aRet 		:= {}									// Retorno
Local lRet			:= .F.									// Retorno
Local lMDDTIPO	:= MDD->(ColumnPos("MDD_TIPO"))>0	// Tipo do Vale
Local cTipo		:= ""

Default cCodVP := ""

cCodVP := AllTrim(cCodVP)

DbSelectArea("MDD")
DbSetOrder(1)//MDD_FILIAL+MDD_CODIGO 

If DbSeek(xFilial("MDD")+cCodVP)

	If !EOF() .AND. MDD->MDD_FILIAL == xFilial("MDD") .AND. AllTrim(MDD->MDD_CODIGO) == cCodVP

		If lMDDTIPO
			cTipo := MDD->MDD_TIPO
		Else
			cTipo := "P"
		EndIf

		Aadd(aRet, {MDD_STATUS, MDD_VALOR, MDD_PROD, cTipo, MDD_DTFIM})
		lRet := .T.
		
	EndIf
	
EndIf

If !lRet
	//Nao Encontrou. retorna status "0"
	Aadd( aRet, {"0"} )
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} STBBaixaPr
Funcao que baixa o vale presente depois de vendido

@param  cVale  Vale presente
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBBaixaPr(cVale		, aVlrVP	, cDoc	, cSerie,;
					  cEstacao	, cPDV		, dData	, cHora	,;
					  cVend		, cCliente	, cLoja	)

Local aArea 		:= GetArea()            // Guarda area corrente
Local cGetProd		:= ""					// Vale presente
Local lRet			:= .F.					// Retorno
Local nX 			:= 0 					//contador
Local aInfoNcc	:= {}
Local lMDDTIPO	:= MDD->(ColumnPos("MDD_TIPO"))>0// Tipo do Vale
Local nValVP	:= 0 // Valor do Vale Presente

Default aVlrVP := {}						//Valores Vale presente
Default cVale  := ""
Default cDoc		:= ""
Default cSerie	:= ""
Default cEstacao	:= ""
Default cPDV		:= ""
Default dData		:= CToD("  /  /  ")
Default cHora		:= ""
Default cVend		:= ""
Default cCliente	:= ""
Default cLoja		:= ""

LjGrvLog( ,"STBBaixaPr | Atualizacao na MDD na Retaguarda | Inicio | ", )

cGetProd := AllTrim(cVale)

DbSelectArea("MDD")
DbSetOrder(1)//MDD_FILIAL+MDD_CODIGO 

//Atualiza os valores do MDD_SALDO e MDD_VALOR caso a venda do vale presente seja valor variável
If Len(aVlrVP) > 0 .AND. SuperGetMV('MV_LJVPVAR',,.F.)

	For nX := 1 TO Len(aVlrVP)
		If DbSeek(xFilial("MDD") + AllTrim(aVlrVP[nX][1]))
			If lMDDTIPO .And. AllTrim(MDD->(MDD_TIPO)) == "C" //Vale credito - Gera NCC
				aInfoNcc := {	AllTrim(aVlrVP[nX][1])	,cDoc	,cSerie	,aVlrVP[nX][2],;
								cCliente					,cLoja	}
				STIVPGerCred(aInfoNcc)
				
			Else
				RecLock( "MDD", .F. )
				MDD->MDD_VALOR	:= aVlrVP[nX][2]
				MDD->MDD_SALDO	:= aVlrVP[nX][2]
				MDD->MDD_STATUS	:= '2'
				MDD->MDD_DOCV	:= IIf(!Empty(cDoc)		, cDoc		, MDD->MDD_DOCV)
				MDD->MDD_SERIV	:= IIf(!Empty(cSerie)	, cSerie	, MDD->MDD_SERIV)
				MDD->MDD_ESTV	:= IIf(!Empty(cEstacao)	, cEstacao	, MDD->MDD_ESTV)
				MDD->MDD_PDVV	:= IIf(!Empty(cPDV)		, cPDV		, MDD->MDD_PDVV)
				MDD->MDD_DATAV	:= IIf(!Empty(dData)	, dData		, MDD->MDD_DATAV)
				MDD->MDD_HORAV	:= IIf(!Empty(cHora)	, cHora		, MDD->MDD_HORAV)
				MDD->MDD_VEND	:= IIf(!Empty(cVend)	, cVend		, MDD->MDD_VEND)
				MDD->MDD_CLIV	:= IIf(!Empty(cCliente)	, cCliente	, MDD->MDD_CLIV)
				MDD->MDD_LJCLIV	:= IIf(!Empty(cLoja)	, cLoja		, MDD->MDD_LJCLIV)
				MsUnLock()
			EndIf
		EndIf
	Next nX
ElseIf DbSeek(xFilial("MDD")+cGetProd)	

	nValVP := MDD->MDD_VALOR	

	If lMDDTIPO .And. AllTrim(MDD->(MDD_TIPO)) == "C"   //Vale credito - Gera NCC
		aInfoNcc := {	AllTrim(cVale)	,cDoc	,cSerie	,MDD->(MDD_VALOR)	,;
						cCliente					,cLoja	}					
		STIVPGerCred(aInfoNcc)

	Else
		RecLock( "MDD", .F. )
		MDD->MDD_STATUS	:= '2'
		MDD->MDD_DOCV	:= IIf(!Empty(cDoc)		, cDoc		, MDD->MDD_DOCV)
		MDD->MDD_SERIV	:= IIf(!Empty(cSerie)	, cSerie	, MDD->MDD_SERIV)
		MDD->MDD_ESTV	:= IIf(!Empty(cEstacao)	, cEstacao	, MDD->MDD_ESTV)
		MDD->MDD_PDVV	:= IIf(!Empty(cPDV)		, cPDV		, MDD->MDD_PDVV)
		MDD->MDD_DATAV	:= IIf(!Empty(dData)	, dData		, MDD->MDD_DATAV)
		MDD->MDD_HORAV	:= IIf(!Empty(cHora)	, cHora		, MDD->MDD_HORAV)
		MDD->MDD_VEND	:= IIf(!Empty(cVend)	, cVend		, MDD->MDD_VEND)
		MDD->MDD_CLIV	:= IIf(!Empty(cCliente)	, cCliente	, MDD->MDD_CLIV)
		MDD->MDD_LJCLIV	:= IIf(!Empty(cLoja)	, cLoja		, MDD->MDD_LJCLIV)
		MDD->MDD_SALDO	:= nValVP
		MsUnLock()
	EndIf
EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} STBGetVales
Retorna o codigo do vale presente no fechamento da venda

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  cVale
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetVales()
Return cVale


//-------------------------------------------------------------------
/*{Protheus.doc} STBSetVales
Funcao que limpa o codigo da static cVale

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSetVales(cValPre)
cVale := cValPre
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STIUpdMinMaxVP
Exibe o limite do range do vale presente a ser inserido

@param
@author  Varejo
@version P1180
@since   14/01/2015
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIUpdMinMaxVP()

If Len(aVpMinMax) > 0
	If aVpMinMax[1] > 0 .AND. aVpMinMax[2] > 0 //valores minimo e maximo do vale presente
		oLblLimiteVP:SetText(STR0018 +"Min. R$ " + AllTrim(Str(aVpMinMax[1])) + " - Max. R$ " + AllTrim(Str(aVpMinMax[2])) ) //"Valores: "
		If Len(aVpMinMax) > 2 .And. Len(aVpMinMax) > 3
			oLblDescricao:SetText(STR0017 + Posicione("SB1",1,xFilial("SB1")+aVpMinMax[4],"B1_DESC")) //"Descrição: "
		EndIf
		oVlrVP:lReadOnly := .F. //seta o campo de valor com somente leitura
		STFMessage(ProcName(0),"STOP","") //Limpa mensagem do rodapé
		STFShowMessage(ProcName(0))		
	Else
		nVlrVP := 0 //inicializa o campo valor do vale presente
		oLblLimiteVP:SetText("") //limpa o texto do limite do vale presente
		oLblDescricao:SetText("") //exibe texto de descricao do vale presente/credito
		oVlrVP:lReadOnly := .T. //define o campo do valor como somente leitura
		STFMessage(ProcName(0),"STOP",STR0012) //Este vale presente não possui venda de valor variável
		STFShowMessage(ProcName(0))
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STIValidVP
Validação executada antes da ação do botão Vale Presente

@param
@author  Varejo
@version P1180
@since   29/03/2016
@return  lRet - .T. -> operação OK / .F. -> operação invalida
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIValidVP(cTipo,cGetProd)
Local lRet			:= .T.
Local cCliVend	:= ""

If cTipo == "C"
	cCliVend := AllTrim(STDGPBasket("SL1", "L1_CLIENTE"))

	If Empty(cCliVend) .Or. cCliVend == AllTrim(SuperGetMV("MV_CLIPAD",,""))
		STFMessage(ProcName(0),"STOP",STR0015) //"Selecionar cliente para venda de vale do tipo crédito."
		STFShowMessage(ProcName(0))
		lRet := .F.	
	EndIf
	
	If lRet .And. "VALE PRESENTE" $ Upper(AllTrim(cGetProd)) .OR. "VALE CREDITO" $ Upper(AllTrim(cGetProd)) 
		STFMessage(ProcName(0),"STOP",STR0016) //"Descrição do produto Vale Presente/Crédito incorreta."
		STFShowMessage(ProcName(0))
		lRet := .F.	
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIVPGerCred
Gerar a NCC do vale credito na retagaurda

@param
@author  Varejo
@version P1180
@since   29/03/2016
@return  lRet - .T. -> operação OK / .F. -> operação invalida
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIVPGerCred(aInfo)
Local lRet		:= .F.
Local cVale		:= "" 
Local cDoc		:= ""
Local cSerie	:= ""
Local nValor	:= 0
Local cCliente	:= ""
Local cLoja		:= ""
Local cTipo		:= "NCC"
Local cNatu		:= &(SuperGetMV("MV_NATNCC"))
Local cParcela	:= ""
Local c1DUP		:= SuperGetMv("MV_1DUP")
Local nI		:= 0
Local nQtdParc	:= 1
Local aRetPE	:= {}
Local aNcc		:= {}

Default aInfo	:= {}

LjGrvLog( STR0001,"Inicio Vale Credito", FWTimeStamp(2))

If Len( aInfo ) > 0
	
	cVale		:= aInfo[1] //Vale
	cDoc		:= aInfo[2] //Documento
	cSerie		:= aInfo[3] //Serie
	nValor 		:= aInfo[4] //Valor
	cCliente	:= aInfo[5] //Cliente
	cLoja		:= aInfo[6] //loja cliente	

	If ExistBlock("STGeraCr")
		aRetPE := ExecBlock("STGeraCr",.F.,.F.,{cVale,nValor,cCliente,cLoja})
		If ValType(aRetPE) == "A" .And. Len(aRetPE) > 1
			nValor		:= aRetPE[1] //Valor a ser gerado
			nQtdParc	:= aRetPE[2] //Quantidade de parcelas
		Endif
	EndIf	
	
	For nI := 1 To nQtdParc
		aNcc := {}
		cParcela := LJParcela( nI, c1DUP )
		LjGrvLog( STR0001,"Vale Credito:"+cVale+"/DOC: "+cDoc+"/Serie: "+cSerie+"/Parcela: "+cParcela+"/R$: "+AllTrim(STR(nValor)), "Gerando crédito") //Vale presente

		aAdd(aNcc,{"E1_PREFIXO"	,cSerie						,Nil})
		aAdd(aNcc,{"E1_NUM"	  	,cDoc						,Nil})
		aAdd(aNcc,{"E1_PARCELA" ,cParcela					,Nil})
		aAdd(aNcc,{"E1_NATUREZ" ,cNatu						,Nil})
		aAdd(aNcc,{"E1_TIPO" 	,cTipo						,Nil})
		aAdd(aNcc,{"E1_EMISSAO"	,dDatabase					,Nil})
		aAdd(aNcc,{"E1_VALOR"	,nValor						,Nil})
		
		If SuperGetMV("MV_LJVLNCC"  ,,.F.)					
			aAdd(aNcc,{"E1_VENCTO"	,(dDataBase + SuperGetMV("MV_LJDTNCC",,0))					,Nil})
			aAdd(aNcc,{"E1_VENCREA"	,DataValida((dDataBase + SuperGetMV("MV_LJDTNCC",,0)),.T.)	,Nil})
		Else
			aAdd(aNcc,{"E1_VENCTO"	,dDataBase					,Nil})
			aAdd(aNcc,{"E1_VENCREA"	,DataValida(dDataBase,.T.)	,Nil})	
			aAdd(aNcc,{"E1_VENCORI"	,dDataBase					,Nil})
		EndIf
		
		aAdd(aNcc,{"E1_SALDO"	,nValor								,Nil})
		aAdd(aNcc,{"E1_VLCRUZ"	,xMoeda(nValor,1,1,nValor)			,Nil})
		aAdd(aNcc,{"E1_CLIENTE"	,cCliente							,Nil})
		aAdd(aNcc,{"E1_LOJA"	,cLoja	   						    ,Nil})
		aAdd(aNcc,{"E1_MOEDA"	,1									,Nil})
		aAdd(aNcc,{"E1_STATUS"	,If(nValor > 0.01,"A","B")			,Nil})
		aAdd(aNcc,{"E1_ORIGEM"	,"STIPOSMAIN"						,Nil})
		aAdd(aNcc,{"E1_HIST"	,AllTrim(cVale)+"-"+cDoc+cSerie	    ,Nil})
		
		
		lRet := Empty(STDIncSE1(aNcc))

		If lRet 
			LjGrvLog( STR0001, "Vale Credito:"+cVale+"/DOC: "+cDoc+"/Serie: "+cSerie+"/R$: "+AllTrim(STR(nValor)), "Gera com sucesso!") //"Vale Credito" 
		Else
			LjGrvLog( STR0001,"Vale Credito:"+cVale+"/DOC: "+cDoc+"/Serie: "+cSerie+"/R$: "+AllTrim(STR(nValor)), "Problema ao gerar o crédito") //"Vale Credito"
		EndIf
	Next nI
EndIf

LjGrvLog( STR0001,"Fim Vale Credito", FWTimeStamp(2))

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} STIConsValPre
Funcao que consulta os códigos de vale presente na tabela MDD da retaguarda

@param   cCodVP, caracter, Codigo do vale presente
@Type Funcion
@author  Vendas & CRM
@version P12
@since   12/12/2023
  

/*/
//-------------------------------------------------------------------
Function STIConsValPre(cStVP)
    Local oDlg
    Local aRet          := {}
    Local lSelVp        := .F.
    Local cDescriSay    := STR0020
    Local oSay          := NIL
    Local aCpos       	:= {}
	Local lRet			:= .T.

	Private oLbx
	Default cStVP 		:= "1"
    
	If ISINCALLSTACK('LJ7TELAFIN')
		cStVP 		:= "2"
	Endif

    FWMsgRun(, {|oSay| STIMontGridVp(oSay,cStVP, @aCpos) }, cDescriSay, STR0021)  //Consulta, carregando dados
 
    DEFINE MSDIALOG oDlg TITLE STR0022  FROM 0,0 TO 320,700 PIXEL  //"Consulta de Vale Presente"
     
    @ 05,010 LISTBOX oLbx FIELDS HEADER STR0023 	,;	//'Codigo Vale'
										STR0024 	,;	//'Valor'
										STR0025 	,;	//'Produto'
										STR0026		,;	//'Inicio Vig'
										STR0027  SIZE 335,120 OF oDlg PIXEL		//'Fim Vig'
 
    oLbx:SetArray( aCpos )
    oLbx:bLine      := {|| aCpos[oLbx:nAt]}
    oLbx:bLDblClick := {|| {oDlg:End(), lSelVp:=.T.,aRet := oLbx:aArray[oLbx:nAt]} }
 
    oTBtn2 := TButton():New( 148, 305, "Selecionar",oDlg,{|| oDlg:End(), lSelVp:=.T., aRet := oLbx:aArray[oLbx:nAt] }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
  
    ACTIVATE MSDIALOG oDlg CENTER
 
    If Len(aRet) > 0 .And. lSelVp
        cCodVPre :=aRet[1]
    else
		cCodVPre :=""
    EndIf

Return(lRet) 
 

/*{Protheus.doc} STIRetCodVP
Retorna o codigo do vale presente selecionado
@Type Funcion
@author  marcos.andrade
@version P12
@since   12/12/2023
@return  cCodVPre, Caracter, Codigo do vale presente selecionado

/*/
Function STIRetCodVP()
Return cCodVPre
 
 
/*{Protheus.doc} STIMontGridVp
Seleciona os vales presentes na tabela MDD e atualiza o objeto oSay com os dados

@param   oSay, objeto, Grid dos vale presentes
@param   cStVP, caracter, Status do vale presente
@param   aCpos, array, campos da consulta

@Type Static funcion
@author  marcos.andrade
@version P12
@since   12/12/2023

/*/ 
Static Function  STIMontGridVp(oSay,cStVP,aCpos)

Default cStVP  	:= "1"		//Status de vale a ser vendido

aCpos:={}  

If FINDFUNCTION("STDGDVpre" )
	STBRemoteExecute("STDGDVpre" ,{cStVP}, NIL,.F.,@aCpos)

	If Len(aCpos) < 1
		aAdd(aCpos,{" "," "," "," ", " "})
	EndIf
	
Endif 

Return

