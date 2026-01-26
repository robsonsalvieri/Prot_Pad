#INCLUDE "PROTHEUS.CH"         
#DEFINE MODELIMPRES "EPSON"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBZRedProc
Function emite redução Z  
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Emissão com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBZRedProc(lEmiteRedZ)
Local aArea			:= GetArea()									// Salva a area atual
Local aReduction    := {}											// Array auxiliar para leitura dos dados da reducao e gravacao do SFI
Local cReduction    := space(5000)									// Armazena o conteudo do parametro que define se na operacao da Reducao Z, grava o Mapa Resumo.
Local cTax        	:= ""											// Valor dos tributos para impressao
Local nCont															// Contador auxiliar	
Local dAuxData														// Data auxiliar para controle da Data do movimento
Local dDate															// Data base
Local dMvmtDate													    // Data real de movimento
Local nGTIni														// Contador do Grande Total (ECF)	
Local nImpDebt       := 0											// Total de impostos (Tributo)
Local nAtAux		 := 0											// Variavel auxiliar para busca dentro de STRING.
Local nTamCOO		 := 0											// Tamanho do campo FI_COO
Local nTamFICRO		 := TamSx3("FI_CRO")[1]							// Tamanho do campo FI_CRO
Local cCOOIni        := "1"											// Numero inicial do cupom da data do movimento
Local nLenAux 		 := 0 											// Variavel auxiliar para o LEN
Local lLjNfPafEcf	 := STBIsPAF(SM0->M0_CGC)
Local cMV_LJGRMR	 := IIF(lLjNfPafEcf, "S", SuperGetMv("MV_LJGRMR", ,"S"))  // Variavel auxiliar para nao ler diversas vezes o mesmo parametro
Local cPDV           := AllTrim(STFGetStat("PDV")) 
Local cPafMd5		:= "" 											//Chave MD5
Local cLegTrib 		:= ""       									//Legenda da Aliquota
Local cCodAliq		:= ""                                           //Aliquota
Local aField		:= {}											//Array de campos e valores de ICMS e ISS
Local nValor		:= 0
Local nOutrosR		:= 0                                            //Outros Recebimentos
Local nBas001		:= 0											//Base 001      
Local aRet			:= {}
Local aDados		:= {}
Local nPosTotAliq	:= 21											//total de aliquotas
Local lHomolPaf		:= STBHomolPaf() 
Local lRMS 			:= SuperGetMv('MV_LJRMS',,.F.)  			//Integracao RMS
Local nTamTribt		:= 0											//Tamanho do corte para alíquotas
Local nTamCorte		:= 0											//Tamanho do corte para alíquotas
Local cHrRetEcf		:= ""
Local cHoraRedZ		:= ""
Local cNumCup		:= ""

Default lEmiteRedZ	:= .T.											//Utilizado para gravar dados de reducao ja realizada e nao emitir novo comando de Z para o ECF

/*
NOTA : A partir da versão 0.3.135.13 da SIGALOJA foi adicionado mais dois parâmetros em cRedução 
		( desconto e cancelamento de ISS);	Para a TOTVSAPI não foi gerada nova versão pois somente 
		foram utilizados os fontes do Protheus, portanto valida a versão da SIGALOJA.
		
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Descricao do retorno da variavel cReduction                      			³
	  ³-------------------------------------------------------------------------³
	  ³Seq- LAYOUT              - Conteudo                            			³
	  ³-------------------------------------------------------------------------³
	  ³01 - XX/XX/XX            - Data do Movimento                   			³
	  ³02 - XXXX                - Numero do ECF                       			³
	  ³03 - XXXXXXXXXXXXX       - Serie do ECF                        			³
	  ³04 - XXXX                - Numero de reducoes                  			³
	  ³05 - XXXXXXXXXXXXXXXX.XX - Grande Total Final                  			³
	  ³06 - XXXXXX              - Numero doumento Inical              			³
	  ³07 - XXXXXX              - Numero doumento Final               			³
	  ³08 - XXXXXXXXXXXX.XX     - Valor do Cancelamento               			³
	  ³09 - XXXXXXXX.XX         - Valor Contabil ( Venda Liquida )    			³
	  ³10 - XXXXXXXX.XX         - Desconto                            			³
	  ³11 - XXXXXXXX.XX         - Nao tributado SUBSTITUIcao TRIB     			³
	  ³12 - XXXXXXXX.XX         - Nao tributado ISENTO                			³
	  ³13 - XXXXXXXX.XX         - Nao tributado Nao Tributado         			³
	  ³14 - XX/XX/XX            - Data da Reducao Z                   			³
	  ³15 - XXXXXX              - Contador de Ordem de Operação       			³
	  ³16 - 0000000000000000    - Outros Recebimentos                 			³
	  ³17 - XXX                 - Contador de Ordem de Reinicio       			³
	  ³18 - XX                  - Quantidade de Aliquotas Programadas no ECF  	³
	  ³19 - XXXXXXXXXXXXX.XX    - valor desconto de ISS               		  	³
	  ³20 - XXXXXXXXXXXXX.XX    - valor de cancelamento de ISS        		  	³
	  ³21 - TXX,XX999999999.99  - Todas as Aliquotas e seus valores.. 		  	³
	  ³                           que estao gravados no ECF           		  	³	  
	  ³                           Ex.: T07.00 99999999999.99 99999999999.99	  	³	  	  
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  */
CursorWait()

cReduction := cMV_LJGRMR + cReduction		//Define se na operacao da Reducao Z grava o Mapa Resumo
cHoraRedZ	:= StrTran(Time(),":")

If lLjNfPafEcf //PAF-ECF deve capturar a hora do ECF
	nRet := STWPrinterStatus( '1', @cHrRetEcf )
	If nRet == 0
		cHoraRedZ	:= StrTran(cHrRetEcf,":")
	EndIf
EndIf

/*
	Tratar o tamanho do COO conforme o ECF,
	alguns modelos tem 6 outros 9 dígitos
*/
cNumCup := STBCSNumPrinter()
If cNumCup == "ERROR"
	nTamCOO := TamSX3("FI_COO")[1]
Else
	nTamCOO := Len(cNumCup)
EndIf

cCOOIni := StrZero(1, nTamCOO )

aDados := {cReduction}

If lEmiteRedZ
	STFMessage("STBZRedProc",;
				"RUN","Processando Redução Z(Processo poderá demorar alguns minutos).",;
				{|| aRet := STFFireEvent( ProcName(0)	,;		// Nome do processo
				  							 "STReductZ"	,;		// Nome do evento
											 aDados)})				// Dados de retorno da RedZ
Else
	STFMessage("STBZRedProc",; 
				"RUN","Processando dados da última Redução Z",;
				{|| aRet := STFFireEvent( ProcName(0)		,;		// Nome do processo
											"STDadoReductZ"	,;		// Nome do evento
											aDados)})																									
EndIf
STFShowMessage("STBZRedProc")

If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0
	cReduction := aDados[1]
Else 
	If lHomolPaf
		cReduction := cMV_LJGRMR + space(5000)	//PROBLEMAS NO TIMEOUT, CAPTURA OS DADOS DA REDUCAO
		aDados := {cReduction}
		aRet := STFFireEvent(	ProcName(0)	,;		// Nome do processo
								"STRedZData",;		// Nome do evento
								aDados)

		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0
			cReduction := aDados[1]
		Else
			cReduction := ""
		EndIf
	ElseIf  Len(aRet) > 0 .AND. aRet[1] == -2
		Conout("REDUCAOZ NÃO EMITIDA: STATUS DO ECF -> POUCO PAPEL.")
		cReduction := ""
	EndIf
EndIf

While Len(cReduction) > 0
	nAtAux := At("|", cReduction)
	If nAtAux > 0
		AAdd(aReduction, SUBS(cReduction,1,nAtAux-1) )
		cReduction := SUBS(cReduction, nAtAux + 1, LEN(cReduction) )
	Else
		cReduction := ""
	Endif
End

If cMV_LJGRMR == "S" .AND. LEN(aReduction) > 0
    STDZRedData(@dAuxData)
   	dDate  		:= CTOD( aReduction[1] )
	Conout("01. STWZREDUCTION -  Data existente SFI - dAuxData: " + dToC(dAuxData) + " Data Reducao Z - dDate: " + dToc(dDate))
	LjGrvLog( Nil, "01. STWZREDUCTION -  Data existente SFI - dAuxData: " + dToC(dAuxData) + " Data Reducao Z - dDate: " + dToc(dDate))
		
	// Se retornou vazio considera a data base como data do movimento
	If Empty(dDate)                               
		dDate := dDataBase
	Endif

	nGTIni     := 0
	dMvmtDate := dDate

	Conout("02. STWZREDUCTION -  PDV da Reducao: " + aReduction[2] + ". String inteira: " + aReduction[2])
	LjGrvLog( Nil,"02. STWZREDUCTION -  PDV da Reducao: " + aReduction[2] + ". String inteira: " + aReduction[2])
	Conout("03. STWZREDUCTION -  dAuxData <= dDate .AND. !EMPTY(dDate): " + IIF(dAuxData <= dDate .AND. !EMPTY(dAuxData),"Sim","Nao" ) )
	LjGrvLog( Nil,"03. STWZREDUCTION -  dAuxData <= dDate .AND. !EMPTY(dDate): " + IIF(dAuxData <= dDate .AND. !EMPTY(dAuxData),"Sim","Nao" ) )
	Conout("04. STWZREDUCTION -  Campo FI_PDV: " + cPDV)
	LjGrvLog( Nil,"04. STWZREDUCTION -  Campo FI_PDV: " + cPDV)
	While dAuxData <= dDate .AND. !EMPTY(dAuxData)
		dDate := dDate-1
		
		If STDZRedGTCOO(@nGTIni, @cCOOIni,aReduction[2], dDate)
			Conout("05. STWZREDUCTION -  Realizou a busca no SFI.")
			LjGrvLog( Nil,"05. STWZREDUCTION -  Realizou a busca no SFI.")
			Exit
		EndIf
	End

	Conout("06. STWZREDUCTION -  nGTIni: ",nGTIni)
	LjGrvLog( Nil,"06. STWZREDUCTION -  nGTIni: ",nGTIni)
	Conout("07. STWZREDUCTION -  cCOOIni: ",cCOOIni)
	LjGrvLog( Nil,"07. STWZREDUCTION -  cCOOIni: ",cCOOIni)

	aRet := STFFireEvent(ProcName(0),"STDLLVersionControl",{ .F. , .F. })
	
	nTamTribt := 14
	nTamCorte := 38
	nLenAux := Val(aReduction[nPosTotAliq])
		
	For nCont := 1 To nLenAux
		cTax := cTax + aReduction[nPosTotAliq+nCont] + '|'
	Next nCont
		
	While Len(cTax) > 0 
		//³Valida o estado e as aliquotas  para lancar separadamente³
		If ( Subs(cTax,2,5) == "00,00" ) .AND. LjAnalisaLeg(16)[1]
			nOutrosR := Val(Subs(cTax,8,14))		
		ElseIf ( Subs(cTax,2,5) == "00,01" ) .AND. LjAnalisaLeg(16)[1]
			//³ Grava a aliq. 0,01%(Garantido Integral ECF Mato Grosso) ³
			If SFI->(ColumnPos("FI_BAS001")) > 0
				nBas001 := Val(Subs(cTax,8,14))
			EndIf
		Else
			cCampo	:="FI_BAS"
			
			If Val( Subs(cTax,2,2) ) >= 10
				cCampo += Subs(cTax,2,2)
			Else
				cCampo += Subs(cTax,3,1)
			Endif         
			
			If Val( Subs(cTax,5,2) ) > 0
				cCampo += Subs(cTax,5,2)
			Endif
			
			If SFI->(ColumnPos(cCampo))  > 0
				nValor := Val( SubStr(cTax,8,14) )
				Aadd( aField, STLdField(cCampo, nValor) )
				
				nImpDebt += Val( SubStr(cTax,23,nTamTribt) )
				If lRMS
					Aadd( aField, STLdField("FI_IMP" + SubStr(cCampo,7), Val(SubStr(cTax,23,14))) )
				EndIf 
				
				//PAF-ECF: Grava o código da alíquota Ex.: para FI_BAS18 grava o código no campo FI_COD18 = T1800 para validacao de banco(BLOCO VII)
				If Len( AllTrim(cCampo) ) == 7 .OR. Len( AllTrim(cCampo) ) == 9
					cLegTrib	:= "T0"		// Acrescenta um zero para entrar no padrao do arquivo
				Else
					cLegTrib	:= "T"
				EndIf

				cCodAliq := Subs(cLegTrib + PadR(AllTrim(StrTran(Subs(cCampo,7,Len(cCampo)) , ",", ".")) , 4 ,"0" ),0,5)					
				cCampo := "FI_COD" + Substr( cCampo, 7, Len(cCampo)-6 )
				Aadd( aField, STLdField(cCampo, cCodAliq) )
			EndIf
		Endif
		cTax := Subs(cTax,nTamCorte)
	End

	//Tratamento de algumas informacoes do aReduction
	aReduction[4] 	:= STRedZAjusC(aReduction[4])
	aReduction[7]	:= RemoveASC0(aReduction[7], "")	//remove caractares CHR(0) da string
	aReduction[18]	:= AllTrim( SubStr(aReduction[18],;
								IIf( (Len(aReduction[18]) - nTamFICRO) < 0,	1, (Len(aReduction[18]) - nTamFICRO) + 1 ),;
	   							Len(aReduction[18])) )

	//Realiza a gravacao do SFI
	STDZRedGr(	dMvmtDate	, cCOOIni, nGTIni	, aReduction, ;
				nOutrosR	, nBas001, aField	, nImpDebt, ;
				@cPafMd5	,		 , cHoraRedZ)

	/*Geração dos Arquivos Obrigatorios do PAF*/ 
	If lLjNfPafEcf
		STBProcRedZ( .T. , dMvmtDate , xFilial("SFI") + DTOS(dMvmtDate) + aReduction[2],cPDV)
	EndIf
	
	Conout("08. LOJA160 -  Fim de Gravação da SFI")
	LjGrvLog( Nil, "08. LOJA160 -  Fim de Gravação da SFI")
Endif

CursorArrow()
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STLdField
Função que carrega o campo
@cCampo   	Nome do Campo
@xValor   	Valor do Campo
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	aArray - Retorno da Função
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STLdField(cCampo, xValor)

Local aArray := Array(2)

Default cCampo := ""
Default xValor := 0

aArray[1] := cCampo
aArray[2] := xValor

Return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} STRedZAjusC
Função que ajusta um campo
@cStr   	Valor
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	cRet - Valor
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STRedZAjusC(cStr)

Local cRet := ''			// Retorno
Local nVal := 0   			// Amazena valor para Bk

Default cStr := '0' 		// Inicializa com zero, mas usar funcao val
	
nVal := Val(cStr)
cRet := cValtoChar(nVal)

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} RemoveASC0
Remove os caracteres especiais

@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function RemoveASC0(cBuffer, cChar)
Local nFor := 0 		// Contador 
Local cRet := ""		// Retorno

Default cBuffer := ""
Default cChar   := " "

For nFor := 1 To Len(cBuffer)
	If Asc(SubStr(cBuffer, nFor, 1)) == 0
		cRet += cChar
	Else
		cRet += SubStr(cBuffer, nFor, 1)
	EndIf
Next nFor

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} STBValidaZ
Retorna se utiliza recuperacao de Reducao Z (protecao fonte)
@author  Paulo Henrique
@version P11.8
@since   29/12/2016
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBValidaZ
Local lRet := .T. //para evitar que rotina de reprocessar Z seja acionada com esse fonte desatualizado, o impacto seria emitir duas Z no mesmo dia STBZRedProc(lEmiteRedZ)
Return lRet
