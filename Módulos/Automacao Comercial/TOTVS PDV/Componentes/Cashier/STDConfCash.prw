#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STDCONFCASH.CH"

Static lDetADMF 	:= SuperGetMV("MV_LJDESM",.T.,.F.) //Utiliza detalhamento por administradora financeira
Static dDtMov		:= ""									//Data de movimento do caixa

#DEFINE POS_FP			1
#DEFINE POS_DESCFP		2
#DEFINE POS_CODADM		3
#DEFINE POS_QTDE		5
#DEFINE POS_MOEDA		6
#DEFINE POS_VALDIG		7
#DEFINE POS_VALAPU		8  


//-------------------------------------------------------------------
/*/{Protheus.doc} STDUtMovAb
Funcao para retornar a chave do primeiro movimento pend. fechamento
encontrado no controle de movimento de abertura e fecha. de caixa.

@param 	nOpc  		- Numero de operacao 1 ou 2
@param 	cOper 		- Numero do caixa
@param 	cPDV		- Numero do PDV
@param 	cEstacao	- Numero da estacao
@param 	cNumMov	- Numero da movimentacao
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	cChave - Retorna a chave do movimento pendente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDUtMovAb(	nOpc	,cOper,cPDV,cEstacao,;
							cNumMov)

Local cChave		:= ""						//Chave
Local cTab			:= "SLW"					//Tabela a ser processada
Local aEstru		:= {}						//Estrutura de tabela
Local cArqInd		:= ""						//Arquivo para o indice temporario
Local cIndice		:= ""						//Campos do indice
Local cFiltro		:= ""						//Filtro do novo indice
Local nIndice		:= 0						//Sequencia dos indices
Local aAreaSLW		:= SLW->(GetArea())		//Area SLW
Local nIndAnt		:= SLW->(IndexOrd())	//Indice atual

Default nOpc		:= 0
Default cOper		:= ""
Default cPDV		:= ""
Default cEstacao	:= ""
Default cNumMov		:= ""


ParamType 0 Var 	nOpc 				As Numeric			Default 0			
ParamType 1 var  	cOper				As Character		Default  ""
ParamType 2 var  	cPDV				As Character		Default  ""
ParamType 3 var  	cEstacao			As Character		Default  ""
ParamType 4 var  	cNumMov				As Character		Default  ""

//Determinando a estrutura
dbSelectArea(cTab)
aEstru := (cTab)->(dbStruct())

//Formatar variaveis
cOper 		:= PadR(cOper		,TamSX3("LW_OPERADO")[1])
cPDV		:= PadR(cPDV		,TamSX3("LW_PDV")[1])
cEstacao	:= PadR(cEstacao	,TamSX3("LW_ESTACAO")[1])
cNumMov	:= PadR(cNumMov	,TamSX3("LW_NUMMOV")[1])

Do Case

	//Pesquisa completa - busca dados da abertura vigente, em processo de fechamento
	Case nOpc == 1
		If Empty(cOper) .OR. Empty(cPDV) .OR. Empty(cEstacao) .OR. Empty(cNumMov)
			Return cChave
		Endif
		cArqInd := CriaTrab(,.F.)
		cIndice := "LW_FILIAL+DTOS(LW_DTFECHA)+LW_TIPFECH+LW_OPERADO+LW_PDV+LW_ESTACAO+LW_NUMMOV"
		cFiltro := "LW_FILIAL = '" + xFilial(cTab) + "' .AND. "
		cFiltro += "!LW_TIPFECH $ '2|3|4|5|6' .AND. "
		cFiltro += "LW_OPERADO = '" + RTrim(cOper) + "' .AND. "
		cFiltro += "LW_PDV = '" + RTrim(cPDV) + "' .AND. " 
		cFiltro += "LW_ESTACAO = '" + RTrim(cEstacao) + "' .AND. "
		cFiltro += "LW_NUMMOV = '" + RTrim(cNumMov) + "' "
		cFiltro += ".AND. LW_ORIGEM <> 'LOJ' "
		
	//Pesquisa incompleta - busca movimentos jah fechados, por simplificados
	Case nOpc == 2
		If Empty(cOper)
			Return cChave
		Endif
		cArqInd := CriaTrab(,.F.)
		cIndice := "LW_FILIAL+DTOS(LW_DTFECHA)+LW_TIPFECH+LW_OPERADO+LW_PDV+LW_ESTACAO+LW_NUMMOV"
		cFiltro := "LW_FILIAL = '" + xFilial(cTab) + "' "
		cFiltro += ".AND. !LW_TIPFECH $ '2|3|4|5|6' "
		cFiltro += ".AND. LW_OPERADO = '" + RTrim(cOper) + "' "
		If !Empty(cPDV)
			cFiltro += ".AND. LW_PDV = '" + RTrim(cPDV) + "' " 
		Endif
		If !Empty(cEstacao)
			cFiltro += ".AND. LW_ESTACAO = '" + RTrim(cEstacao) + "' "
		Else
			//O campo LW_ESTACAO vazio caracteriza registros anteriores ao update, desconsiderar
			cFiltro += ".AND. !Empty(LW_ESTACAO) "
		Endif
		If !Empty(cNumMov)
			cFiltro += ".AND. LW_NUMMOV = '" + RTrim(cNumMov) + "' "
		Endif
		cFiltro += ".AND. LW_ORIGEM <> 'LOJ' "
			
	OtherWise
		Return cChave
		
EndCase

IndRegua("SLW",cArqInd,cIndice,,cFiltro,"")
dbSelectArea("SLW")
nIndice := RetIndex("SLW")
#IFNDEF TOP
	SLW->(dbSetIndex(cArqInd + OrdBagExt()))
#ENDIF
SLW->(dbSetOrder(nIndice + 1))
SLW->(dbGoTop())
Do While !SLW->(Eof())
	//Se o tipo de fechamento nao for simplificado ou completo, e a 
	//data de fechamento nao estiver em branco, desconsiderar
	If !SLW->LW_TIPFECH $ "1|2" .AND. !Empty(SLW->LW_DTFECHA)
		SLW->(dbSkip())
		Loop
	Else
		dDtMov	:= SLW->LW_DTABERT
		cChave := SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + DtoS(LW_DTABERT) + LW_ESTACAO + LW_NUMMOV)
		Exit	
	EndIf	
EndDo

//Retornar ao indice anterior e eliminar o arquivo de indice


SLW->(DBCloseArea())
dbSelectArea("SLW")
RetIndex("SLW")	
SET FILTER TO 
SLW->(dbSetOrder(nIndAnt))

If File(cArqInd + OrdBagExt())
	fErase(cArqInd + OrdBagExt())
Endif		

RestArea(aAreaSLW)

Return cChave


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCreatGd
Funcao que retorna os dados da SLT para se realizar a conferencia.

@param 	
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	aNumerario[x,1] - Sigla da Forma de Pagamento;
			aNumerario[x,2] - Descricao da Forma de Pagamento;
			aNumerario[x,3] - Codigo da Administradora Financeira;
			aNumerario[x,4] - ???
			aNumerario[x,5] - Quantidade Utilizada da forma de pagamento.
			aNumerario[x,6] - Moeda utilizada
			aNumerario[x,7] - Valor informado pelo usuario
			aNumerario[x,8] - Valor apurado pelo sistema
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCreatGd()

Local aArea			:= GetArea()													//Retrato da workarea
Local lMoedaEst		:= .F.															//Utiliza moeda estrangeira
Local aFPADM		:= {}															//Forma de pagamento das administradoras financeiras
Local lConfCega		:= SuperGetMV("MV_LJEXAPU",.T.,.F.) == .F.						//Utiliza a conferencia cega?
Local aNumerario	:= {}															//1. Forma de pagamento 2. Descricao da FP 3. Quantidade 4. Moeda 5. Valor a ser apontado 6. Valor apurado 7. Cod Adm Fin 8. Nome Adm Fin
Local aID			:= STBInfoEst(1,.F.,.T.)										//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV [5]-SERIE NAO FISCAL + TAMANHO DE CADA CAMPO CORRESPONDENTE
Local cNumMov		:= STDNumMov()													//Numero da movimentacao
Local lApura		:= IsInCallStack("STDGRVSLT")									//Apurar o valor das vendas quando for gerar a tabela SLT quando estiver fechamento a cegas.
Local dMovimento    := POSICIONE("SA6",1,XFILIAL("SA6")+xNumCaixa(),"A6_DATAABR") 	//Data do movimento aberto
Local cfiltro 		:= ""														 	//Armazena o filtro a ser aplicado na tabela
Local aFechaCx		:= STDDtAbCx() 													//Pega os dados de abertura do caixa Data/Hora

If Len(aFechaCx) > 0 .AND. !Empty(aFechaCx[1]) 
	dMovimento := aFechaCx[1] //Pega a data de abertura da tabela SLW
Else
	LjGrvLog("Conferencia de Caixa","Nao sera possivel efeturar a conferencia de caixa pois nao retornou a data de abertura da SLW - LW_DTABERT")
EndIf

/* Carrega as adm financeiras */
aFPADM := STDLoadAdm()

/* Carrega as formas de pagamento */
aNumerario := STDFormsPay(aFPADM)

//Filtro a ser aplicado na tabela
cFiltro := "L1_FILIAL = '" + xFilial("SL1") + "' .AND. L1_OPERADO = '" + PadR(aID[1][1],aID[1][2]) + "' .AND. DToS(L1_EMISSAO) >='" + DtoS(dMovimento) + "' .AND. DToS(L1_EMISSAO) <= '" + DToS(dDataBase) + "'"

DbSelectArea("SL1")
SL1->(DbSetFilter({||&cFiltro},cFiltro))
SL1->(DbGoTop())

//Caso nao seja conferencia cega, levantar os valores apurados, senao apenas as quantidades
Do While !SL1->(Eof())

	If	(AllTrim(SL1->L1_SERIE) # AllTrim(aID[3][1]) .AND. AllTrim(SL1->L1_SERIE) # AllTrim(SuperGetMV("MV_LOJANF", .F. ,"")) .AND. AllTrim(SL1->L1_SERPED) # AllTrim(aID[5][1]) .AND. Empty(SL1->L1_DOCRPS)).OR.;
		(AllTrim(SL1->L1_PDV) # AllTrim(aID[4][1]) .OR. AllTrim(SL1->L1_ESTACAO) # AllTrim(aID[2][1]))	.OR.;
		(SL1->L1_SITUA == "07" .OR. (!Empty(cNumMov) .AND. AllTrim(SL1->L1_NUMMOV) # AllTrim(cNumMov)))	.OR.;
		(SL1->L1_STORC $ "C|E")
		
		SL1->(dbSkip())
		Loop
	
	Else

		If SL1->L1_CREDITO > 0
			aNumerario := STDCredVal(aNumerario)
		EndIf

		/* Totalizar as formas de pagamento */
		aNumerario := STDTotPay(aNumerario, @lMoedaEst)
	
	EndIf  

	SL1->(dbSkip())
	
EndDo

SL1->(dbClearFilter())

//Totalizadores de MovimentaÁ„o n„o venda (Recebimento/Sangria/Troco e etc)
aNumerario := STDConfMov({xFilial("SE5"),DtoS(dMovimento),PadR(aID[1][1],aID[1][2])},aNumerario, cNumMov )

/* Ordenar a sequencia por forma de PG e moeda */
aNumerario := STDOrderPay(aNumerario,lMoedaEst)

RestArea(aArea)

Return aNumerario


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGrvSLT
Apos realizar a conferencia, gravar a SLT

@param 	
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGrvSLT(aDados,dDataMov,lFechaSimp)

Local lRet				:= 	.T.										//Retorno da funcao
Local lMoedaC			:= 	.F.										//Moeda corrente
Local cFP				:= 	""										//Forma de pagamento
Local cAgencia			:= 	""										//Agencia
Local cChave			:= 	""										//Chave
Local nTamFP			:= 	TamSX3("LT_FORMPG")[1]					//Tamanho do campo da forma de pagamento
Local nTamMV			:= 	TamSX3("LT_NUMMOV")[1]					//Tamanho do campo de movimento
Local cCampos			:= 	""										//Campos do indice utilizado, para comparacoes
Local nI				:= 	0										//Variavel de Loop
Local aLstCxAb			:= 	{}										//Lista de caixas abertos - Agencias (moedas)
Local cAgenC			:= 	PadR(".",TamSX3("A6_AGENCIA")[1])		//Codigo da agencia corrente
Local aCaixaC			:= 	Array(5)								//Caixa na moeda corrente - 1.Filial 2.Codigo 3.Agencia 4.Dt Abertura 5.Aberto?
Local lUsaFecha			:= 	SuperGetMV("MV_LJCONFF",.T.,.F.) 		//Usa conferencia de cx
Local lNovo				:= 	.F.										//Utilizada no ReckLok para um novo registro ou apenas atualizar
Local aDataHr			:=	STDGDtAbFch( )							//Array com data e hora
Local aID				:= 	STBInfoEst(1,.F.,.T.)					//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV + TAMANHO DE CADA CAMPO CORRESPONDENTE
Local lConfCega			:= SuperGetMV("MV_LJEXAPU",.T.,.F.) == .F.	//Utiliza a conferencia cega?
Local lExistGNum		:= ExistFunc("STIGetNume")
Local aNumerario		:= Iif(lExistGNum,STIGetNume(),{})			//Preenche os numerarios com as forma de pagamento
Local nModoChama		:= 2										//Compatibilidade 'a conferencia de caixa do FrontLoja, vide FRTA272B ( 1 = LOJA260, 2 = FRTA271 )
Local nVlrTot			:= 0										//Valor total acumulado por fechamento 
Local nQtdTot			:= 0										//Qtde total de vendas por fechamento
Local nPosANum			:= 0 										//PosiÁ„o do numerario resgatado pelo aScan 

Default aDados			:= {}
Default dDataMov		:= CtoD("  /  /  ")
Default lFechaSimp		:= .F.

ParamType 0 Var aDados 		As Array 	Default {}
ParamType 1 Var dDataMov 	As Date 	Default CtoD("  /  /  ")
ParamType 2 Var lFechaSimp 	As Logical	Default .F.

//Pesquisa caixa na moeda principal
dbSelectArea("SA6")
SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
SA6->(dbSeek(xFilial("SA6") + PadR(aID[1][1],aID[1][2]) + cAgenC))
If !SA6->(Found())
	LjGrvLog("Conferencia de Caixa","Caixa n„o encontrado na tabela SA6, verifique as informaÁıes de: Agencia e Conta.")
	LjGrvLog("Conferencia de Caixa","Tabela SLT n„o sera gravada.")
	lRet := .F.	
Else
	aCaixaC[1] := SA6->A6_FILIAL
	aCaixaC[2] := SA6->A6_COD
	aCaixaC[3] := SA6->A6_AGENCIA
	aCaixaC[4] := SA6->A6_DATAABR
	aCaixaC[5] := IIf(Empty(SA6->A6_DATAABR),.F.,.T.)
EndIf

If lRet
	//Pesquisar se o movimento do caixa foi aberto em mais de 
	//uma moeda (localizadas). Para criar o array de moedas   
	//utilizadas no processo de abertura de caixa.            
	Do While !SA6->(Eof()) .AND. SA6->(A6_FILIAL + A6_COD) == (aCaixaC[1] + aCaixaC[2])
		//Se for a agencia principal, saltar
		If SA6->A6_AGENCIA == aCaixaC[3]
			SA6->(dbSkip())
			Loop
		EndIf
		//Exigir que as datas de abertura sejam as mesmas para que as moedas nao
		//correntes sejam consideradas (caso o caixa esteja aberto)
		If nModoChama == 2 .AND. aCaixaC[5]
			If SA6->A6_DATAABR == aCaixaC[4] .AND. IsMoney(SA6->A6_AGENCIA)
				aAdd(aLstCxAb,AllTrim(SA6->A6_AGENCIA))
			EndIf
		Else
			If IsMoney(SA6->A6_AGENCIA)
				aAdd(aLstCxAb,SA6->A6_AGENCIA)
			EndIf
		EndIf
	EndDo

	//Gravar a conferencia SLT  
	dbSelectArea("SLT")
	SLT->(dbSetOrder(4))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG+LT_PDV+LT_NUMMOV+LT_ADMIFIN
	For nI := 1 to Len(aDados)
		If STFGetCfg("lMultCoin")
			lMoedaC  := IIf(aScan(aLstCxAb,{|x| AllTrim(x) == AllTrim(aDados[nI][POS_MOEDA])}) == 0,.T.,.F.)

			If lMoedaC
				cFP 		:= aDados[nI][1]
				cAgencia 	:= cAgenC
			Else
				cFP 		:= aDados[nI][1] + cValToChar(RetMoeda(aDados[nI][POS_MOEDA]))
				cAgencia 	:= PadR(AllTrim(aDados[nI][POS_MOEDA]),TamSX3("A6_AGENCIA")[1])
			EndIf
		Else
			lMoedaC 	:= .T.
			cFP 		:= aDados[nI][1]
			cAgencia 	:= cAgenC		
		EndIf

		If lExistGNum
			If lDetADMF
				nPosANum := aScan(aNumerario, {|x| x[POS_FP] == aDados[nI][POS_FP] .And. x[POS_CODADM] == aDados[nI][POS_CODADM] })
			Else
				nPosANum := aScan(aNumerario, {|x| x[POS_FP] == aDados[nI][POS_FP] })
			EndIf
		Else
			LjGrvLog("GravaÁ„o da Tabela SLT","O Campo LT_VLRAPU N„o ser· gravado, atualizar o fonte STIConfCash com data superior a 08/11/2018" )
		EndIf

		RecLock("SLT",.T.)
		SLT->LT_FILIAL		:= xFilial("SLT")
		SLT->LT_OPERADO		:= aID[1][1]
		SLT->LT_DTFECHA		:= aDataHr[3]
		SLT->LT_FORMPG		:= cFP
		If !lFechaSimp
			SLT->LT_VLRDIG	:= Val(aDados[nI][POS_VALDIG])
		Else
			SLT->LT_VLRDIG	:= 0
		Endif
		SLT->LT_SANPAR			:= 0
		SLT->LT_AGENCIA			:= cAgencia
		SLT->LT_NUMMOV			:= STDGLstNumMov()
		SLT->LT_DTMOV			:= aDataHr[1] 				//Data de abertura do movimento.
		SLT->LT_MOEDA			:= STBGetCurrency()
		SLT->LT_ESTACAO			:= aID[2][1]
		SLT->LT_PDV				:= aID[4][1]
		If !lFechaSimp
			SLT->LT_CONFERE	:= "1"
		Else
			SLT->LT_CONFERE	:= "2"		
		EndIf
		If lDetADMF
			SLT->LT_ADMIFIN		:= aDados[nI][POS_CODADM]
		EndIf
		SLT->LT_QTDE			:= aDados[nI][POS_QTDE]

		If nPosANum > 0
			SLT->LT_VLRAPU	:= aNumerario[nPosANum][POS_VALAPU]
			nQtdTot    		+=  aNumerario[nPosANum][POS_QTDE]
			nVlrTot    		+= aNumerario[nPosANum][POS_VALAPU]
			//Quarda chave para alterar Tabela SLW
			cChave     		:= SLT->LT_PDV + SLT->LT_OPERADO + DTOS(SLT->LT_DTFECHA) + SLT->LT_ESTACAO + SLT->LT_NUMMOV
		EndIf
		SLT->LT_SITUA		:= "00"

		MsUnlock()
		
	Next nI


	//Grava Valor e quantidade de venda
	//para posterior comparacao na Retaguarda
	STDGrvVlrQtd( xFilial("SLW")+cChave , nQtdTot , nVlrTot )

Endif

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} STDGrvVlrQtd
Grava quantidade e valores de vendas na SLW
@param	 cChave   Chave de pesquisa 
@param	 nQtdTot  Quantidade total de vendas
@param	 nVlrTot  Valor total de vendas
@author  	Varejo
@version 	P11.8
@since   	27/05/2016
@return  	lSet - Retorna se o campo foi gravado ou n„o
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function STDGrvVlrQtd( cChave , nQtdTot , nVlrTot )

Local aArea		:= GetArea()	//Salva area
Local lRet			:= .F. 		//Retorno da funÁ„o 
Local lContinua  	:= .F.			//Continua Fluxo

Default 	cChave 		:= ""			//	Chave de pesquisa 
Default 	nQtdtot 		:= 0			//	Quantidade total de vendas
Default 	nVlrTot 		:= 0			//	Valor total de vendas

If SLW->(ColumnPos("LW_QTDTOT")) > 0 .AND. SLW->(ColumnPos("LW_VLRTOT")) > 0
	lContinua  	:= .T.
EndIf

DbSelectArea("SLW")                                      
DbSetOrder(3) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
If lContinua .AND. DbSeek( cChave ) 
	
	If RecLock("SLW", .F.)
				
		SLW->LW_QTDTOT := nQtdTot
		SLW->LW_VLRTOT := nVlrTot
		
		SLW->(MsUnLock())	
		lRet := .T.
		
	EndIf

EndIf
	
RestArea(aArea)	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDFormsPay
Carrega as formas de pagamento

@param 	aFPADM   Forma de Pgto 
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	aNumerario - Numerarios
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFormsPay( aFPADM )

Local cChave 			:= xFilial("SX5") + "24"		// Chave
Local aTMP			:= {}							// Array Temp
Local aNumerario		:= {}							// Numerarios
Local nI				:= 0							// Contador

Default aFPADM		:= {}

ParamType 0 Var aFPADM 		As Array 	Default {}

dbSelectArea("SX5")
SX5->(dbSetOrder(1))//X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(dbSeek(cChave))

If SX5->(Found())
	Do While !SX5->(Eof()) .AND. RTrim(SX5->(X5_FILIAL + X5_TABELA)) == cChave
		aTMP := {}
		If !SX5->(Deleted())
			If !lDetADMF
			
				aAdd(aNumerario,{SX5->X5_CHAVE,SX5->X5_DESCRI,"","",0,1,0,0})
				
			Else
				
				/* Levantar todas as adm financeiras associadas com esta forma de pagamento */
				For nI := 1 to Len(aFPADM)
					If AllTrim(aFPADM[ni][1]) == AllTrim(SX5->X5_CHAVE)
						aAdd(aTMP,{aFPADM[ni][2],aFPADM[nI][3]})
					EndIf
				Next nI
				
				/* Listar todas as administradoras financeiras na lista de numerarios */
				If Len(aTMP) == 0
					aAdd(aNumerario,{SX5->X5_CHAVE,SX5->X5_DESCRI,"","",0,1,0,0})
				Else
					For nI := 1 to Len(aTMP)
						aAdd(aNumerario,{SX5->X5_CHAVE,aTMP[nI][2],aTMP[nI][1],aTMP[nI][2],0,1,0,0})
					Next nI
				EndIf
				
			EndIf
		EndIf                                                         	
		SX5->(dbSkip())
	EndDo
EndIf

Return aNumerario


//-------------------------------------------------------------------
/*/{Protheus.doc} STDOrderPay
Ordenar a sequencia por forma de PG e moeda

@param 	aNumerario - Forma de pagamento
@param 	lMoedaEst  - Moeda corrente
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	aNumerario - Retorna as formas de pagamento ja ordenadas.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDOrderPay(aNumerario,lMoedaEst)

Default aNumerario 		:= {}
Default lMoedaEst		:= .F.

ParamType 0 Var aNumerario 		As Array 	Default {}
ParamType 1 Var lMoedaEst 		As Logical	Default .F.

If Len(aNumerario) > 0

	If lMoedaEst .AND. !lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_MOEDA]) < (y[POS_FP] + y[POS_MOEDA])})
	ElseIf !lMoedaEst .AND. lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_CODADM]) < (y[POS_FP] + y[POS_CODADM])})
	ElseIf lMoedaEst .AND. lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_MOEDA] + x[POS_CODADM]) < (y[POS_FP] + y[POS_MOEDA] + y[POS_CODADM])})
	EndIf
	
EndIf

Return aNumerario


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCredVal
Trata o valor do credito da venda.

@param 	aNumerario  Numerario
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	aNumerario  Numerario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCredVal(aNumerario)

Local nValFP 		:= 0 	//Valor por forma de pagamento
Local nPos		:= 0	//Posicionador
Local nPos02		:= 0	//Posicionador

Default aNumerario 		:= {}

ParamType 0 Var aNumerario 		As Array 	Default {}

nValFP := SL1->L1_CREDITO

If SL1->L1_MOEDA > 1 .AND. !STFGetCfg("lMultCoin") 
	nValFP := xMoeda( nValFP, SL1->L1_MOEDA, 1, SL1->L1_EMISSAO )
EndIf

If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == "CR"})) > 0
	If STFGetCfg("lMultCoin")
		/* Caso o movimento esteja na moeda corrente, apenas totalizar */
		If SL1->L1_MOEDA == 0 .OR. SL1->L1_MOEDA == 1
			aNumerario[nPos][POS_QTDE] 		+= 1
			aNumerario[nPos][POS_VALAPU] 	+= nValFP			
		Else
			/*Verificar se a moeda associada a forma de pagamento esta na array, caso nao esteja, incluir
			Aplicar um filtro para verificar a existencia da agencia (moeda) na forma de pagamento associada*/
			nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == "CR" .AND. x[POS_MOEDA] == SL1->L1_MOEDA})
			If nPos02 == 0						
				aAdd(aNumerario,{"CR", STDDescFP("CR"), 0, SL1->L1_MOEDA, 0, 0, "", ""})
				nPos := Len(aNumerario)
			Else
				nPos := nPos02
			EndIf
			aNumerario[nPos][POS_QTDE] 		+= 1
			aNumerario[nPos][POS_VALAPU] 	+= nValFP
		EndIf				
	Else
		aNumerario[nPos][POS_QTDE] 		+= 1
		aNumerario[nPos][POS_VALAPU] 	+= nValFP
	EndIf
EndIf

Return aNumerario

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLoadAdm
Carrega as administradoras financeiras

@param 	
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	aFPADM - Retorna Tipo, Codigo e Descricao da adm financeira
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDLoadAdm()
                        
Local aFPADM		:= {}		// Array formas de Pgto

If lDetADMF

	dbSelectArea("SAE")
	SAE->(dbGoTop())
	
	Do While !SAE->(Eof())
	
		If aScan(aFPADM,{|x| x[1] == AllTrim(SAE->AE_TIPO) .AND. AllTrim(x[2]) == AllTrim(SAE->AE_COD)}) == 0

			aAdd(aFPADM,{AllTrim(SAE->AE_TIPO),SAE->AE_COD,SAE->AE_DESC})
			
		EndIf
		
		SAE->(dbSkip())
	EndDo
	
EndIf

Return aFPADM

//-------------------------------------------------------------------
/*/{Protheus.doc} STDTotPay
Totaliza todas as formas de pagamento que

@param 	cFM - Chave
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	cRet - Retorna a descricao da forma de pagamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDTotPay(aNumerario)

Local lHabTroco 		:= SuperGetMV("MV_LJTROCO",,.F.) 	//Habilita troco
Local cCodADM			:= ""									//Codigo administadora financeira
Local nTamCADM		:= TamSX3("AE_COD")[1]				//Tamanho do codigo da adm financeira
Local aLstFPQ			:= {}									//Variavel Provisoria
Local lFiltraADMF	:= .F.									//Filtrar por administradora financeira
Local cTMP			:= ""									//Temporaria
Local nPos			:= 0									//Posicionador
Local nPos02			:= 0									//Posicionador
Local lSomaQtde		:= .T.									//Variavel de controle de soma das quantidades de vendas
Local lMoedaEst		:= .F.									//Utiliza moeda estrangeira
Local nValFP 			:= 0 									//Valor por forma de pagamento

Default aNumerario 		:= {}

ParamType 0 Var aNumerario 		As Array 	Default {}

dbSelectArea("SL4")
SL4->(dbSetOrder(1))//L4_FILIAL+L4_NUM+L4_ORIGEM
SL4->(dbSeek(xFilial("SL4") + SL1->L1_NUM + Space(TamSX3("L4_ORIGEM")[1])))
Do While !SL4->(Eof()) .AND. RTrim(SL4->(L4_FILIAL + L4_NUM)) == RTrim(xFilial("SL4") + SL1->L1_NUM) .AND. Empty(SL4->L4_ORIGEM)

	If lHabTroco
		nValFP := SL4->L4_VALOR
	Else
		nValFP := SL4->(L4_VALOR - L4_TROCO)
	EndIf
	
	cCodADM := Substr( SL4->L4_ADMINIS, 1, nTamCADM ) 

	/* Se ja existe a FP no array aLstFPQ ent„o n„o soma a quantidade 1 na FP */     				
	If aScan(aLstFPQ,{|x| x[1] == AllTrim(SL4->L4_FILIAL) .AND. x[2] == AllTrim(SL4->L4_NUM) .AND. ; 
		x[3] == AllTrim(SL4->L4_FORMA) .AND. x[4] == AllTrim(cCodADM) .AND. x[5] == AllTrim(SL4->L4_MOEDA)}) == 0 
					
		aAdd(aLstFPQ,{AllTrim(SL4->L4_FILIAL),AllTrim(SL4->L4_NUM),AllTrim(SL4->L4_FORMA),AllTrim(cCodADM),AllTrim(SL4->L4_MOEDA)})
		lSomaQtde := .T.
		
	Else	
		lSomaQtde := .F.		
	EndIf
	
	/*Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao*/
	If SL4->L4_MOEDA > 1 .AND. !STFGetCfg("lMultCoin")
		nValFP := xMoeda( nValFP, SL4->L4_MOEDA, 1, SL1->L1_EMISSAO )
	EndIf
	
	/* Fazer o posicionamento na array */
	If !lDetADMF
		nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})
	Else
		If !Empty(cCodADM)
			lFiltraADMF := .T.
			If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. AllTrim(x[POS_CODADM]) == cCodADM})) == 0
				/* Caso a adm financeira nao tenha sido encontrada, pesquisar apenas pela forma de pagamento */
				nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})					
			EndIf
		Else
			nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})
		EndIf
	EndIf
	
	If nPos > 0
		If STFGetCfg("lMultCoin") 
			
			/* Caso o movimento esteja na moeda corrente, apenas totalizar */
			If SL4->L4_MOEDA == 0 .OR. SL4->L4_MOEDA == 1
				aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
				aNumerario[nPos][POS_VALAPU] 	+= nValFP
			Else
				/*Verificar se a moeda associada a forma de pagamento esta na array, caso nao esteja, incluir
				Aplicar um filtro para verificar a existencia da agencia (moeda) na forma de pagamento associada*/
				If lFiltraADMF
					/* Filtro : Forma Pagto + Agencia + Adm Financeira */
					If (nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA .AND. ;
						AllTrim(x[POS_CODADM]) == cCodADM})) == 0
						
						/* Caso a adm financeira nao tenha sido encontrada, pesquisa apenas pela forma de pagamento e moeda */
						nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA})
						
					EndIf
				Else
					/* Filtro : Forma Pagto + Agencia */
					nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA})
				EndIf
				
				If nPos02 == 0						
					lMoedaEst := .T.
					If lDetADMF .AND. !Empty(cCodADM)
						cTMP := GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(cCodADM),1)
					EndIf
					If !lDetADMF
						aAdd(aNumerario,{SL4->L4_FORMA, STDDescFP(SL4->L4_FORMA), 0, SL4->L4_MOEDA, 0, 0, cCodADM, cTMP})
					Else
						aAdd(aNumerario,{SL4->L4_FORMA, STDDescFP(SL4->L4_FORMA), cCodADM, cTMP, 0, SL4->L4_MOEDA, 0, 0})
					EndIf
					nPos := Len(aNumerario)
				Else
					nPos := nPos02
				EndIf
				aNumerario[nPos][POS_QTDE]		+= IIf(lSomaQtde,1,0)
				aNumerario[nPos][POS_VALAPU] 	+= nValFP
			EndIf				
		Else
			aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
			aNumerario[nPos][POS_VALAPU] 	+= nValFP
		EndIf
	EndIf
	SL4->(dbSkip())
EndDo

Return aNumerario


//-------------------------------------------------------------------
/*/{Protheus.doc} STDDescFP
Retorna a descricao da forma de pagamento

@param 	cFM - Chave
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	cRet - Retorna a descricao da forma de pagamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDescFP( cFM )

Local cRet := "" //Retorno

Default cFM := ""

ParamType 0 var  	cFM			As Character		Default  ""

dbSelectArea("SX5")
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(dbSeek(xFilial("SX5") + "24" + AllTrim(cFM)))
If SX5->(Found())
	cRet := SX5->X5_DESCRI
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetMoeda
funÁ„o statica: Retorna o codigo da moeda associada a um simbolo ou nome. 
@param 	cStr - Simbolo ou nome da moeda a se obter o codigo correspondente                                     
@param nOpc - Opcao            
@param 	nTipoRet - Tipo de retorno 1 numÈrico  - 2. Retorno caracter 
@param 	lFrmtStr - A string de retorno deve ser fomrmatada?
@author  	Varejo
@version 	P11.8
@since   	29/11/2013
@return  	uMoeda - Codigo da moeda em formato numerico ou caracter 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function RetMoeda(cStr,nOpc,nTipoRet,lFrmtStr)

Local aAreaSM2		:= SM2->(GetArea())
Local ni				:= 1
Local uMoeda			:= 0
Local cAcentua		:= "¡…Õ”⁄¬ Œ‘€¿»Ã“ŸƒÀœ÷‹¬ Œ‘€√’"	//Acentuacoes
Local cAcentuaCorr	:= "AEIOUAEIOUAEIOUAEIOUAEIOUAO"	//Correspondentes
Local cTMP			:= ""
Local cTMP02			:= ""
Local nx				:= 0
Local nPos			:= 0
Local nTamMoeda		:= TamSX3("L1_MOEDA")[1]

Default cStr			:= ""
Default nOpc			:= 1
Default nTipoRet		:= 1
Default lFrmtStr		:= .T.

If ValType(cStr) # "C" .OR. ValType(nOpc) # "N" .OR. Empty(cStr) .OR. ValType(nTipoRet) # "N"
	Return uMoeda
Else
	If (nOpc < 1 .OR. nOpc > 2) .OR. (nTipoRet < 1 .OR. nTipoRet > 2)
		Return uMoeda
	Endif
EndIf

dbSelectArea("SM2")
Do While SM2->(FieldPos("M2_MOEDA" + cValToChar(ni))) > 0
	Do Case
		Case nOpc == 1
			//Igualar caixa e remover espacos
			cTMP := Upper(AllTrim(SuperGetMV("MV_SIMB" + cValToChar(ni),.F.,"")))
			cTMP02 := Upper(AllTrim(cStr))
		Case nOpc == 2
			//Igualar caixa e remover espacos
			cTMP := Upper(AllTrim(SuperGetMV("MV_MOEDA" + cValToChar(ni),.F.,"")))
			cTMP02 := Upper(AllTrim(cStr))
		Otherwise
			Return uMoeda			
	EndCase
	//Remover acentuacao do parametro e variavel, caso exista
	For nx := 1 to Len(IIf(Len(cTMP) >= Len(cTMP02),cTMP,cTMP02))
		If nx <= Len(cTMP)
			If (nPos := At(Substr(cTMP,nx,1),cAcentua)) > 0
				cTMP := IIf(nx > 1, Substr(cTMP,1,nx - 1),"") + Substr(cAcentuaCorr,nPos,1) + Right(cTMP,Len(cTMP) - nx)
			Endif
		Endif
		If nx <= Len(cTMP02)
			If (nPos := At(Substr(cTMP02,nx,1),cAcentua)) > 0
				cTMP02 := IIf(nx > 1, Substr(cTMP02,1,nx - 1),"") + Substr(cAcentuaCorr,nPos,1) + Right(cTMP02,Len(cTMP) - nx)
			Endif
		Endif
	Next ni
	If cTMP == cTMP02
		uMoeda := ni
		Exit
	Endif	
	ni++
EndDo
//Caso tenha que ser retornado como caracter
If nTipoRet == 2
	If lFrmtStr
		uMoeda := StrZero(uMoeda,nTamMoeda)
	Else
		uMoeda := cValToChar(uMoeda)
	Endif
Endif
RestArea(aAreaSM2)

Return uMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} STDConfMov
Realiza a conferencia de caixa para movimentaÁıes SE5 (n„o vendas)
@param		cChave - Chave de localizaÁ„o das movimentaÁıes na tabela SE5
			aNumerario - Array com os numerarios da venda
			cNumMov - Numero do movimento atual do caixa
@author  	Vearejo
@version 	P11.8
@since   	11/08/2015
@return  	aRet - Array com todos os registros do fechamento de caixa.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDConfMov(aChave,aNumerario,cNumMov)
Local aRet			:= {}
Local cForma		:= ""
Local cDesForma		:= ""
Local nValFP		:= 0
Local cNatRece		:= &(SuperGetMV("MV_NATRECE"))
Local nOpcConf		:= SuperGetmv("MV_LJOPCON",,2) //1-Conferencia por forma e totalizador (Recebimento/Sangria/Suprimento); 2-Conferencia por forma de pagamento;
Local cMoedaSimb	:= SuperGetMV( "MV_SIMB" + Str(STBGetCurrency() ,1 ) ) 	// Simbolo da moeda corrente
Local cMvNatSang	:= "" 	
Local cMvNatTrc		:= "" 
Local cfiltro 		:= "" //Variavel para filtro nas tabelas SE5 e MHK
Local cCodAdmins	:= "" //Codigo da Administradora
Local cDescAdmins	:= "" //DescriÁ„o da administradora

Default aNumerario	:= {}
Default aChave		:= {}
Default cNumMov		:= STDGLstNumMov( )

//Natureza das movimentaÁıes:
If FindFunction("LjMExeParam")
	cMvNatSang	:= LjMExeParam("MV_NATSANG",,"SANGRIA")	//FunÁ„o que trata macroexecucao
	cMvNatTrc	:= LjMExeParam("MV_NATTROC",,"TROCO")		//FunÁ„o que trata macroexecucao
Else
	cMvNatSang	:= SuperGetMv("MV_NATSANG",,"SANGRIA")	//Natureza da Sangria
	If AllTrim(cMvNatSang) == '"SANGRIA"'
		cMvNatSang := "SANGRIA"
	EndIf

	cMvNatTrc := SuperGetMv("MV_NATTROC",,"TROCO")	//Natureza do Troco
	If AllTrim(cMvNatTrc) == '"TROCO"'
		cMvNatTrc := "TROCO"
	EndIf
EndIf

aRet := aClone(aNumerario)
cFiltro := "E5_FILIAL = '" + aChave[1] + "' .AND. DToS(E5_DATA) >= '" + aChave[2] + "' .AND. DToS(E5_DATA) <= '" + DToS(dDataBase) + "' " +;
" .AND. E5_BANCO = '" + aChave[3] + "' .AND. E5_NUMMOV = '" + cNumMov + "' .AND. AllTrim(SE5->E5_TIPODOC) <> 'VL' .AND. AllTrim(SE5->E5_TIPODOC) <> 'ES'  .AND. AllTrim(SE5->E5_TIPO) <> 'FI' "

DbSelectArea("SE5")
SE5->(DbSetFilter({||&cFiltro},cFiltro))
SE5->(dbGoTop())

While !SE5->(EOF()) 

	cForma		:= ""
	cDesForma	:= ""
	nValFP		:= SE5->E5_VALOR

	If AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_MOEDA)) == "TC" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == cMvNatTrc //Troco
		If nOpcConf == 2
			cForma		:= AllTrim(cMoedaSimb)
			cDesForma	:= STDDescFP(cForma)
		Else
			cForma	  := "TC"
		EndIf
		cDesForma := iIf(!Empty(cDesForma), cDesForma, STR0001) //"ENTRADA DE TROCO"

	ElseIf AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == cMvNatSang //Sangria
		If nOpcConf == 2
			cForma		:= AllTrim(SE5->E5_MOEDA)
			cDesForma	:= STDDescFP(cForma)
			nValFP		:= nValFP * -1 	// Transforma o valor em negativo para subtrair o valor e a quantidade
		Else
			cForma	  := "SG"
		EndIf
		cDesForma := iIf(!Empty(cDesForma), cDesForma, STR0002) //"SANGRIA"
	ElseIf Upper(AllTrim(SE5->E5_HISTOR)) == Upper(AllTrim("CORRESPONDENTE BANCARIO"))  .Or. (Upper(AllTrim(SE5->E5_NATUREZ)) == Upper(AllTrim(SuperGetMv("MV_NATCB",,""))) .Or. Upper(AllTrim(SE5->E5_NATUREZ)) == SuperGetMV("MV_NATTEF") )
		cForma	  := "CB"
		cDesForma := STR0004 //"CORRESPONDENTES BANCARIOS"

	ElseIf SubSTR(Upper(AllTrim(SE5->E5_HISTOR)),1,18) == Upper(AllTrim("RECARGA DE CELULAR"))
		cForma	  := "RCE"
		cDesForma :=  STR0005 //"RECARGA DE CELULAR"
	EndIf

	If !Empty(cForma)
		If (nPos := aScan(aRet,{|x| AllTrim(x[POS_FP]) == AllTrim(cForma)}) ) > 0
			//Quando dinheiro e for sangria nao deve somar nem subtrair a quantidede
			aRet[nPos][POS_QTDE] 	+= IIf(nValFP < 0, IIf(AllTrim(cMoedaSimb) == AllTrim(cForma),0,-1),1)
			aRet[nPos][POS_VALAPU]	+= nValFP
		Else 
			If !lDetADMF
				aAdd(aRet,{PadR(cForma,6),PadR(cDesForma,TamSX3("X5_DESCRI")[1]),0,0,0,0,"",""})
			Else
				aAdd(aRet,{PadR(cForma,6),PadR(cDesForma,TamSX3("X5_DESCRI")[1]),"","",0,0,0,0})
			Endif
			aRet[Len(aRet)][POS_QTDE]	+= 1
			aRet[Len(aRet)][POS_VALAPU]	:= nValFP
		Endif
	EndIf
	SE5->(DBSkip())
End

If ChkFile("MHJ") .AND. ChkFile("MHK")
	
	//Recebimentos de Titulos
	DbSelectArea("MHK")
	cFiltro := "MHK_FILIAL = '" + xFilial("MHK") + "' .AND. DToS(MHK_DATMOV) >= '" + aChave[2] + "' .AND. DToS(MHK_DATMOV) <= '" + DToS(dDataBase) + "' " +;
			" .AND. MHK_BANCO = '" + aChave[3] + "' .AND. MHK_NUMMOV = '" + cNumMov  + "'"

	MHK->(DbSetFilter({||&cFiltro},cFiltro))
	MHK->(dbGoTop())

	While !MHK->(EOF()) 

		cForma		:= ""
		cDesForma	:= ""
		nValFP		:= MHK->MHK_VALOR

		If nOpcConf == 2
			cForma		:= AllTrim(MHK->MHK_TIPOPG)
			cDesForma	:= STDDescFP(cForma)
			cCodAdmins  := MHK->MHK_CODADM
			cDescAdmins := MHK->MHK_DESADM
		Else
			cForma	  := "REC"
		EndIf 

		If !Empty(cForma)
			If lDetADMF .AND. (AllTrim(cForma) == "CC" .OR. AllTrim(cForma) == "CD" )
				nPos := aScan(aRet,{|x| AllTrim(x[POS_CODADM]) == AllTrim(cCodAdmins)}) 
			Else
				nPos := aScan(aRet,{|x| AllTrim(x[POS_FP]) == AllTrim(cForma)}) 
			Endif

			If nPos > 0
				//Quando dinheiro e for sangria nao deve somar nem subtrair a quantidede
				aRet[nPos][POS_QTDE] 	+= IIf(nValFP < 0, IIf(AllTrim(cMoedaSimb) == AllTrim(cForma),0,-1),1)
				aRet[nPos][POS_VALAPU]	+= nValFP
			Else 
				If !lDetADMF
					aAdd(aRet,{PadR(cForma,6),PadR(cDesForma,TamSX3("X5_DESCRI")[1]),0,0,0,0,"",""})
				Else
					aAdd(aRet,{PadR(cForma,6),PadR(cDescAdmins,TamSX3("X5_DESCRI")[1]),cCodAdmins,PadR(cDescAdmins,TamSX3("X5_DESCRI")[1]),0,0,0,0})
				Endif
				aRet[Len(aRet)][POS_QTDE]	+= 1
				aRet[Len(aRet)][POS_VALAPU]	:= nValFP
			Endif
		EndIf

		MHK->(DBSkip())
	End

	SE5->(dbClearFilter())
	MHK->(dbClearFilter())

Else 
	LjGrvLog("STDConfMov","Tabelas MHJ e/ou MHK n„o encontrada, a ausencia destas tabelas implicara na conferÍncia  de caixa n„o listando os recebimentos realizados.")
Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDAjustNum
Remove os registros (formas) que n„o possue valores a serem exibidos na conferencia.

@param		aNumerario - Array com as formas e valores para o fechamento
@author  	Vearejo
@version 	P11.8
@since   	19/08/2015
@return  	aRet - Array com as formas e valores para o fechamento sem as formas em branco.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STDAjustNum(aNumerario)
Local aRet		:= {} 
Local aCopyNum	:= aClone(aNumerario)
Local nI		:= 1
Local lConfCega	:= SuperGetMV("MV_LJEXAPU",Nil,.F.) //Utiliza a conferencia cega?

If !lConfCega
	//Remove os registros sem valores
	For nI := 1 To Len(aCopyNum)
		If aCopyNum[nI][POS_VALAPU] <> 0
			aAdd(aRet, aCopyNum[nI])
		EndIf
	Next
EndIf

//Caso n„o tenha nenhuma movimentaÁ„o ser· exibido todos os registros em branco
If Len(aRet) == 0
	aRet := aClone(aNumerario)
EndIf

Return aRet

