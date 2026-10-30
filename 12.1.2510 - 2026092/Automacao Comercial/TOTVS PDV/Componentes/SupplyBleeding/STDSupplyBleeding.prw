#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STDSUPPLYBLEEDING.CH"

Static lPDVOnline	:= ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv()	// Variável para definir se o totvs PDV está no modo online
//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecSup
Grava o Registro no SE5 conforme os parametros recebidos

@param cCode			Codigo do caixa 
@param cRecPag		Recebimento ou pagamento
@param aNum			Array de numerarios
@param aSimbs		Array de simbolos 
@param cNumCup		Numero do cupom
@param cCoin 		Moeda corrente
@param nTypeOpe		Tipo da rotina: (1) Sangria / Entrada de troco (2)	

  
@author  Varejo
@version P11.8
@since   23/07/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDRecSup(	cCode 		, 	cRecPag 	, 	aNum 	,cNumCup,	;
					nCoin		,	nTypeOpe		,   cSerie	, cAgecia , cConta, cOrigemMov )

Local cCashier 		:= xNumCaixa()						// Caixa 
Local cAgency  		:= ""								// Agencia
Local cAccount    	:= ""								// Conta
Local nDecs1    	:= MsDecimais(1)					//	Numero de decimais
Local cPrefixo  	:= STFGetStation("LG_SERIE")		// Numero de serie do PDV
Local nSequencia	:= 0								// Proxima sequecia a ser gravada
Local lRet			:= .T.								// Retorno
Local aRet			:= {}								//Retorno do ponto de entrada STCpCuston	
Local aSimbs		:= {}								// Array de simbolos 
Local nTamSA6		:= SA6->(TamSx3("A6_COD"))[1]	
Local nTamAgen		:= SA6->(TamSx3("A6_AGENCIA"))[1]
Local lRMS			:= SuperGetMv("MV_LJRMS",,.F.)		//Integracao com CRM da RMS
Local lMobile 		:= STFGetCfg("lMobile" , .F. )		// Verifica versao Mobile
Local cMvCxLj		:= SuperGetMv("MV_CXLOJA",,"")		//Integracao com CRM da RMS
Local cCodSa6		:= Substr(cMvCxLj,1,nTamSA6)		// Caixa padrão no parametro MV_CXLOJA
Local cAgenSa6		:= ""								// Agencia no parametro MV_CXLOJA
Local cContSa6		:= ""								// Conta no parametro MV_CXLOJA
Local cMvNatSang	:= "" 	
Local cMvNatTrc		:= ""
Local aCampos		:= {}								//Array que recebe os campos informados no ponto de entrada STCpCuston
Local nCampos		:= 0								//Variavel de loop

Default cCode		:= 	""								// Codigo do caixa
Default cRecPag		:= 	""								// Recebimento ou pagamento
Default aNum		:= 	{}								// Array de numerarios
Default cNumCup		:= 	""								// 	Numero do cupom		
Default nCoin		:= STBGetCurrency()					// Moeda corrente	
Default nTypeOpe	:= 2								// Tipo de operacao 1=Sangria | 2= Suprimento/Troco
Default cSerie		:= ""								// Serie do documento
Default cOrigemMov	:= ""								// Estacao de origem

ParamType 0 Var 	cCode 		As Character	Default 	""
ParamType 1 Var 	cRecPag 	As Character	Default 	""
ParamType 2 Var 	aNum 		As Array		Default 	{}	
ParamType 3 Var 	cNumCup 	As Character	Default 	""
ParamType 4 Var 	nCoin 		As Numeric		Default 	STBGetCurrency()
ParamType 5 Var 	nTypeOpe 	As Numeric		Default 	2
ParamType 6 Var 	cSerie 	    As Character	Default 	""

lMobile := ValType(lMobile) == "L" .AND. lMobile

/*/ 
	Efetua apenas 1 lancamento pois somente batera o  
	Resumo de Caixa qdo os dados subirem p/ o servidor.
	Sangria de Cx para Cx jah possui 2 registros, um R e um P.      
/*/

If !Empty(cSerie)
	cPrefixo := cSerie
EndIf

//Natureza das movimentações:
If FindFunction("LjMExeParam")
	If nTypeOpe == 1 //SANGRIA
		cMvNatSang	:= LjMExeParam("MV_NATSANG",,'"SANGRIA"')	//Função que trata macroexecucao
	Else
		cMvNatTrc	:= LjMExeParam("MV_NATTROC",,'"TROCO"')		//Função que trata macroexecucao
	EndIf

Else
	cMvNatSang	:= SuperGetMv("MV_NATSANG",,'"SANGRIA"')	//Natureza da Sangria
	If AllTrim(cMvNatSang) == '"SANGRIA"'
		cMvNatSang := "SANGRIA"
	EndIf

	cMvNatTrc := SuperGetMv("MV_NATTROC",,'"TROCO"')	//Natureza do Troco
	If AllTrim(cMvNatTrc) == '"TROCO"'
		cMvNatTrc := "TROCO"
	EndIf
EndIf

DbSelectArea("SE5")
DbSetOrder(2) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
If DbSeek(xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cNumCup, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase))
   While !Eof() .AND. xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cNumCup, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase) == SE5->E5_FILIAL + SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA)
       nSequencia  := Val(SE5->E5_SEQ)
       DbSkip()
   End
EndIf

// Caso o caixa seja o msm do parametro, complementa com agencia e conta para que   
// seja posicionado no banco (SA6) correto, pois pode ter Cod iguais e Contas diferentes
If AllTrim(cCodSa6) == AllTrim(cCode) 
	cMvCxLj			:= Substr(cMvCxLj,At("/", cMvCxLj)+1,len(cMvCxLj)) 
	cAgenSa6		:= Substr(cMvCxLj,1,At("/", cMvCxLj)-1)
	cMvCxLj			:= Substr(cMvCxLj,At("/", cMvCxLj)+1,len(cMvCxLj))
	cContSa6		:= Substr(cMvCxLj,1,len(cMvCxLj))
	cSeek			:= Padr(cCode,nTamSA6)+Padr(cAgenSa6,nTamAgen)+cContSa6
Else
	If (nTypeOpe == 1 .AND. cRecPag == "P" ) .OR. (nTypeOpe == 2 .AND. cRecPag == "R" )
		cSeek			:= cCode
	Else				// Banco + Agencia + Conta
		cSeek			:= cCode + cAgecia + cConta
	Endif
EndIf

DbSelectArea("SA6")
DbSetOrder(1)//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If !SA6->(DbSeek(xFilial("SA6")+cSeek))
	// Apenas um DEFAULT caso nao encontre , pois nao possuia
	SA6->(DbSeek(xFilial("SA6")+ Upper(cUserName))) 
Endif	

//Busca o Caixa da moeda correspondente a sangria se usa Multimoeda
If STFGetCfg("lMultCoin")  .AND. nCoin > 1     
	cAccount:= SA6->A6_NUMCON	      					// Conta do Caixa na moeda 1                            
   
   	// Verifica se existe o Caixa na moeda da 
   	// sangria/troco. Se nao existir,cria.     
   	STDChkCashier( nCoin , cCode , cAgency , cAccount ) 
              
   	SA6->(dbSeek(xFilial("SA6")+cCode+cAgency))  				// Posiciona no Caixa da moeda da sangria/troco
                             
EndIf	

If ExistBlock("STCpCuston")  //Gravação de campos customizados
	aRet := ExecBlock("STCpCuston",.F.,.F.,{nTypeOpe,cRecPag,IIf(Empty(aNum[1]),"TC",aNum[1])})
	lRet := aRet[1] 
	If lRet .AND. len(aRet[2]) > 0
		For nCampos := 1 To len(aRet[2])
			If SE5->(ColumnPos(aRet[2][nCampos][1]))
				AADD(aCampos,{{aRet[2][nCampos][1]},{aRet[2][nCampos][2]}} )
				LjGrvLog(STR0007, STR0005 + aRet[2][nCampos][1] + STR0010 + cValTochar(aRet[2][nCampos][2]) + STR0011 )//"STCpCuston"  "Campo: " ###### " será gravado com o Valor " ##### "atravez do ponto de entrada STCpCuston"
			Else
				LjGrvLog(STR0007, STR0005 + aRet[2][nCampos][1] + STR0006 )//"STCpCuston"  "Campo: " #### " " não encontrado, será desconsiderado no ponto de entrada STCpCuston"
			EndIf
		Next
	Else
		LjGrvLog(STR0007,STR0008)//"STCpCuston" "Retorno do ponto de entrada STCpCuston invalido ou negativo"
	Endif
EndIf

If lRet  
	Reclock("SE5",.T.)
	
	SE5->E5_FILIAL		:= xFilial("SE5")										// Filial
	
	//Grava os campos recebidos no ponto de entrada STCpCuston
	If Len(aCampos) > 0 
		For nCampos := 1 To len(aCampos)
			Replace &(aCampos[nCampos][1][1]) with aCampos[nCampos][2][1]
		Next
	Endif
	
	SE5->E5_DATA		:= Date()												// Data da Movimentacao
	SE5->E5_BANCO		:= SA6->A6_COD											// Codigo do banco
	SE5->E5_AGENCIA		:= SA6->A6_AGENCIA										// Agencia
	SE5->E5_CONTA		:= SA6->A6_NUMCON										// Conta do banco
	SE5->E5_RECPAG		:= cRecPag												// Recebimento "R" ou Pagamento "P"

	If nTypeOpe == 1
		If lRMS
			SE5->E5_HISTOR	:= "SC " + cCashier + " - " + STFGetStation("CODIGO")// Historico do movimento 	| "SANGRIA DO CAIXA "
		Else
			SE5->E5_HISTOR	:= "SANGRIA DO CAIXA " + cCashier 					// Historico do movimento 	| "SANGRIA DO CAIXA "	
		EndIf
		SE5->E5_MOEDA		:= aNum[1] 											//	Numerario    	
		SE5->E5_NATUREZ		:= cMvNatSang										// Natureza					 	|	"Sangria"
	Else
		If lRMS
			SE5->E5_HISTOR	:= "TC " + cCashier + " - " + STFGetStation("CODIGO")// Historico do movimento 	| "TROCO PARA O CAIXA "
		Else
			SE5->E5_HISTOR	:= "TROCO PARA O CAIXA " + cCashier 				// Historico do movimento 	| "TROCO PARA O CAIXA "
		EndIf	
		SE5->E5_MOEDA		:= "TC" 											//	Numerario
		SE5->E5_NATUREZ		:= cMvNatTrc										// Natureza						|	"Troco"  
	EndIf
	  	
	SE5->E5_TIPODOC		:= "TR"													// Tipo da movimentacao
	SE5->E5_VALOR		:= aNum[2]												// Valor
	SE5->E5_DTDIGIT		:= Date()												// Data da Digitacao
	SE5->E5_BENEF		:= Space(15)											// Beneficiario
	SE5->E5_DTDISPO		:= SE5->E5_DATA											// Data de Disponibilizacao		 
	SE5->E5_SITUA		:= StrZero(0,TamSx3("E5_SITUA")[1])						// Situacao
	SE5->E5_PREFIXO 	:= cPrefixo												// Prefixo
	SE5->E5_NUMERO  	:= cNumCup												// Numero do Titulo
	SE5->E5_SEQ     	:= StrZero(nSequencia + 1, TamSX3("E5_SEQ")[1])			// Sequencia 
	
	SE5->E5_NUMMOV	:=  STDNumMov()  											// Numero do movimento
	
	// Se usa Multimoeda
	If STFGetCfg("lMultCoin") //Para compatibilizar com o Resumo de Caixa
	   SE5->E5_VLMOED2	:= Round(xMoeda(SE5->E5_VALOR,nCoin,1,Date(),nDecs1+1),nDecs1)
	   SE5->E5_TIPO     	:= aNum[1]	   
	EndIf   

	SE5->E5_FILORIG := cFilAnt

	If !Empty(cOrigemMov) 
		SE5->E5_ORIGEM := cOrigemMov
	EndIf
		
	SE5->(dbCommit())
	SE5->(MsUnLock())

	If ExistFunc("STFPdvOn") .AND. STFPdvOn()	          				     
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,If(Upper(AllTrim(cRecPag)) == "P","-","+"))//Atualiza Saldo Bancario	                       
	EndIf

	If lPDVOnline //Quando o PDV é offline, esse processo de gravar os FKs é chamado pela rotina GeraE5() do FRTA020.PRW
		LjSE5ToFKs()
	EndIf 

	// Grava na tabela de Monitoramento das Estacoes(SLI) 
	// para subir os movimentos para a retaguarda 
	If !lMobile //Versao mobile nao gera SLI
		STFSLICreate("    ", "050", Str(SE5->(Recno()),17,0), "NOVO")
	EndIf	
	lRet	:= .T.	
Else
	LjGrvLog(STR0007,STR0009)//"STCpCuston" "SE5 Não será gravada, motivo:  Retorno do ponto de entrada STCpCuston é negativo."
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDChkCashier
Verifica se caixa existe(tratamento multi-moeda).
O portador do titulo(caixa) sera definido pela moeda 

@param 	nCoin 			Moeda do titulo
@param 	cCode 			Codigo do Caixa logado
@param 	cAgency 		Codigo da agencia do Caixa
@param 	cAccount 		Codigo da conta do Caixa

@param   
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDChkCashier(		nCoin		,	cCode	,	cAgency	,	cAccount	)

Local cName			:= ""					// Nome
Local cNReduced		:= ""					// Nome Reduzido
Local cAlias 			:= Alias()			// Alias atual
Local nOrd   		:= IndexOrd()		// Index atual
Local nRec   		:= Recno()			// Recno Atual
Local lRet			:= .F.					// Retorno

Default nCoin		:= STBGetCurrency()			// Moeda do titulo
Default cCode		:= ""					// Codigo do Caixa logado
Default cAgency 		:= "."					//	Codigo da agencia do Caixa
Default cAccount		:= "."					// Codigo da conta do Caixa

ParamType 0 Var 	nCoin 		As Numeric		Default 	0
ParamType 1 Var 	cCode 		As Character	Default 	""
ParamType 2 Var 	cAgency 	As Character	Default 	""
ParamType 3 Var 	cAccount 	As Character	Default 	""

cName   	:= SA6->A6_NOME
cNReduced 	:= SA6->A6_NREDUZ

/*/
	Se banco nao encontrado, cria um novo caixa para a moeda do titulo
	O codigo desta caixa sera igual ao corrente com a diferenca de que
	sua agencia eh o MV_SIMB da moeda
/*/
DbSelectArea("SA6")
DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If !DbSeek(xFilial("SA6")+cCode+GetMV("MV_SIMB"+AllTrim(Str(nCoin))))

	Reclock( "SA6", .T. )
	
	Replace A6_FILIAL  	with xFilial("SA6")
	Replace A6_COD 	   	with cCode
	Replace A6_AGENCIA 	with GetMV("MV_SIMB"+AllTrim(Str(nCoin)))
	Replace A6_NUMCON  	with cAccount
	Replace A6_NOME	   	with cName
	Replace A6_NREDUZ  	with cNReduced
	Replace A6_MOEDA   	with nCoin
	Replace A6_DATAABR 	With dDatabase
	Replace A6_HORAABR 	With Substr(Time(),1,5)
	Replace A6_DATAFCH 	With CtoD("  /  /  ")
	Replace A6_HORAFCH 	With "  :  "

	MsUnlock()
	
	lRet := .T.
	
EndIf

// Retorno ao estado anterior
DbSelectArea(cAlias)
DbSetOrder(nOrd)
DbGoto(nRec)

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} STDGrvBleedingMGX
Subtrai da tabela MGX os valores da Sangria.

@param 
@author  Varejo
@version P12
@since   29/03/2012
@return  .T.
@obs     
@sample
*/
//-------------------------------------------------------------------

Function STDGrvBleedingMGX(aNum)

Local nValor := 0		// Valor atual do campo MGX_VALOR posicionado.

Default aNum := {"R$",0}	// Array contendo forma de pagamento[1] e valor da Sangria[2]

DbSelectArea("MGX")
DbSetOrder(1) // MGX_FILIAL+MGX_FPAGTO+DTOS(MGX_DATA)
If DbSeek (xFilial("MGX") + PadR(aNum[1],TamSX3("MGX_FPAGTO")[1]))
	nValor := MGX->MGX_VALOR
	Reclock("MGX", .F.)
	MGX->MGX_VALOR := nValor - aNum[2]
	MsUnlock()
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STDVerLimSan
Verifica se atingiu o limite estabelecido no cadastro de limite de sangria.

@param 
@author  Varejo
@version P12
@since   04/02/2015
@return  lRet
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDVerLimSan()

Local cCaixa        := STDNumCash()     // Retorna o código do Caixa que está logado
Local lRet          := .T.              // retorno da função
Local aArea         := GetArea()        // Area
Local aForms        := STDFormsPay()    // Reetorna as formas de pagamento da tabela 24 (sx5)  
Local cSupID        := Space(25)        // Caixa Superior validado. Tamanho do ID do usuario 
Local lSup          := .F.              // Se irá solicitar superior 
Local lCaixa        := .F.              // Se irá exibir mensagem ao caixa 
Local cMsgCaixa     := SuperGetMv("MV_LJMSGCX")			// Parametro que armazena a função de usuário do cliente
Local lAtMail       := SuperGetMv("MV_LJSMAIL",,.F.)	// Habilita o envio de e-mail para o Superior
Local cParamText    := STR0002 + cCaixa + STR0003		//"O Caixa" + "atingiu o limite para sangria" 
Local nX            := 0                // Contador das formas de pagamento da tabela 24 (sx5) para posicionamento da tabela MGW  
Local cTexto			:= ""			// Texto para saber qual forma de pagamento tem que fazer sua sangria
                                                                                                                                
For nX := 1 to Len(aForms)
    aForms[nX][1] := SubStr(aForms[nX][1],1,3)
    DbSelectArea("MGW")
    DbSetOrder(1) //MGW_FILIAL+MGW_CAIXA       
    If DbSeek (xFilial("MGW") + cCaixa + aForms[nX][1])
		DbSelectArea("MGX") //MGX_FILIAL+MGX_FPAGTO+DTOS(MGX_DATA)                                                                                                                        
		DbSetOrder(1)
		If Dbseek (xFilial("MGX") + aForms[nX][1])
                
			Do Case                         
				Case MGX->MGX_VALOR >= MGW->MGW_LIM2 .AND. MGW->MGW_LIM2 > 0
					lSup := .T. // superior
					cTexto := cTexto + Chr(13) + Chr(10) + aForms[nX][1]
				Case MGX->MGX_VALOR >= MGW->MGW_LIM1 .AND. MGW->MGW_LIM1 > 0
					lCaixa := .T. // mensagem
					cTexto := cTexto + Chr(13) + Chr(10) + aForms[nX][1]
			EndCase 
                
		EndIf
     EndIf              
 Next nX

If lSup .OR. lCaixa	//Entrar somente se passou em um dos dois limites 
	If !Empty(cMsgCaixa)
		&(cMsgCaixa) // macro executa    
		MsgAlert(Iif(Len(cTexto)>0,"Formas de Pagamento a efetuar sangria: "+Alltrim(cTexto),"")) //"Formas de Pagamento a efetuar sangria: " 
	Else    
		MsgAlert(STR0001 +;
					 Iif(Len(cTexto)>0,Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
					 "Formas de Pagamento a efetuar sangria: "+cTexto,"")) //'Caixa, favor efetuar procedimento de Sangria!'###"Formas de Pagamento a efetuar sangria: "
		STFMessage("STDVerLimSan", "STOP", STR0001) //'Caixa, favor efetuar procedimento de Sangria!'
		STFShowMessage("STDVerLimSan")  
	EndIf
    
	lRet := .T.                             
   
	// Envia e-mail ao superior
	If lAtMail
		STFSendMail(cParamText,,,.F.)
	EndIf

	If (lSup .AND. lCaixa) .OR. lSup	//Se passou do limite de supervisor, 
	    lRet := FWAuthSuper(@cSupID)	//Solicita usuario e senha do superior do Caixa
    
		While !lRet 
			lRet := FWAuthSuper(@cSupID) 
    	End
	EndIf 
    
EndIf

      
RestArea(aArea)

Return lRet
