#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS3O

Rotina de geração do registro CR=30 da GIA-SP - DIPAM-B

@Param cCNAE		->	CNAE da Filial que de geração
		cCNPJ   	->	Cnpj da Filial que de geração
		cInscEst  	->	Inscrição Estadual da Filial que de geração
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGS30( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn )
Local oError		:=	ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
Local cREG 			:= "CR30" + cInscEst
Local cStrTxt 		:= ""
Local cTxtSys  		:= CriaTrab( , .F. ) + ".TXT"
Local nHandle    	:= MsFCreate( cTxtSys )
Local cAnoMesRef 	:= Alltrim(aWizard[1][11]) + Alltrim(aWizard[1][9])
Local cOpcDpam25    := SUBSTR( aWizard[1][16], 1, 2 )
Local cCFOP25       := "5153|6153|5251|5252|5253|5254|5255|5256|5257|5258|6251|6252|6253|6254|6255|6256|6257|6258|7251"
Local cCFOP23       := "5350|5351|5352|5353|5354|5355|5356|5357|5359|5360|6350|6351|6352|6353|6354|6355|6356|6357|6359|7358|6360"
Local cOpComunic    := "5301|5302|5303|5304||5305|5306|5307|6301|6302|6303|6304|6305|6306|6307|7301" //DIPAM 2.4 CFOP 5.301 a 5.307, 6.301 a 6.307 e 7.301.
Local nValor		:= 0
Local cAliasQry  	:= GetNextAlias()
Local cCodmun		:= ""
Local nQtd30     	:= 0
Local lFound     	:= .T.
Local cCodDip    	:= ""
Local nValorEnt		:= 0
Local nValorSai		:= 0
Local aDadosC1E 	:= {}
Local aMunicRat 	:= {}
Local lV81          := TAFAlsInDic( "V81" )
Local lRateio       := .F.
Local cStrBase		:= ""
Local nTmC1EFil     := TamSX3("C1E_FILTAF")[1]
Local nDifMov       := 0
Local nPct			:= 0
Local nlA           := 1
Local cMunContrib   := ''
Local nVlEnt26		:= 0
Local nVlSai26		:= 0
Local lVlSimbB23	:= .F. //Inseri valor simbólico de R$0.01 para o DIPAMB23
Local lAddDipB23	:= .F. //Adiciona ao menos um DIPAMB23 válido
Local lOnceB23 		:= .F. //Se foi imprimido uma única vez no DIPAMB23
Local lLastRegB23	:= .F. //se existe apenas um registro e foi o último DIPAMB23
Local lIseDipB24    := .F.
Local lAddIseD24    := .F.
Local oPrepare 		:= Nil

Default cMesRef			:= ""
Default	cAnoRef			:= ""
Default	lSomaFil		:= .F.
Default	cIn				:= ""

if lV81
	aDadosC1E := GetAdvFVal("C1E",{"C1E_ID","C1E_VERSAO"},xFilial('C1E')+Padr(cFilSel,nTmC1EFil),3,{"",""})
	if len( aDadosC1E ) >= 2
		GetRatMun( aDadosC1E, @aMunicRat )
	endif
endif
If len( aMunicRat ) > 0
	lRateio := .T.
endif

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

QryCR30(cAnoMesRef, cFilSel, cAliasQry, cIn, @cMunContrib, @oPrepare)

while ( cAliasQry )->( !Eof() )
    lIseDipB24 := .F.
	cCodmun := Alltrim(( cAliasQry )->C07_MUNGIA)
	cCodDip	:= SUBSTR(( cAliasQry )->LF0_CODIGO,8,2)
	// Para DIPAM 1.1 a 1.3 é considerado apenas participantes que sejam produtores rurais
	If ( cCodDip $ "11|12|13" ) .and. ( cAliasQry )->C1H_RAMO != "4"
		( cAliasQry )->( dbSkip() )
		Loop
	EndIf
	/*
		De acordo com o Manual pré-formatado da GIA, o arquivo .prf pode ter apenas um registro 31, 35 ou 36.
		Devido a isso, o acumulo de valores se dá apenas pelo código DIPAM
	*/
	If !( cCodDip $  "31|35|36" )
		While cCodmun == Alltrim(( cAliasQry )->C07_MUNGIA) .and. cCodDip == SUBSTR(( cAliasQry )->LF0_CODIGO,8,2) .And. ( cAliasQry )->( !Eof() )
			if cCodDip == "23"
				//Caso o início seja diferente de SP e destino Exterior, seus valores não serão computados, ou seja ignorados através do skip e do loop.
				//Se lAddDipB23 for .F. e lVlSimbB23 for .T., ao final do programa haverá um controle de R$0,01 no único CR30 que será gerado para o DIPAM B 2.3.
				if (cAliasQry)->C39_UFORIG <> '000027' .And. (cAliasQry)->C39_UFDEST == '000009' //000027(sp) e 000009(exterior)
					if !lAddDipB23
						lVlSimbB23 := .T.
					endif
					(cAliasQry)->(dbSkip())

					//Depois do skip e antes do loop, atualiza as variáveis de controle do while acima.
					lIseDipB24 := .F.
					cCodmun := Alltrim(( cAliasQry )->C07_MUNGIA)
					cCodDip	:= SUBSTR(( cAliasQry )->LF0_CODIGO,8,2)

					//Se houver ao menos um DIPAM B 2.3 com operação início SP e destino diferente de exterior, será inserido no CR30 com o seu valor correspondente.
					if (cAliasQry)->(!Eof()) .And. cCodDip == "23" .And. !((cAliasQry)->C39_UFORIG <> '000027' .And. (cAliasQry)->C39_UFDEST == '000009')
						lAddDipB23 := .T.
						lVlSimbB23 := .F. //se existir condicao que gere valor nao havera valor simbólico
					elseif (cAliasQry)->(Eof())
						lLastRegB23 := .T.
					endif
					//Somente efetua loop no cCodDip 2.3 quando for origem diferente de SP e destino exterior, para que seus valores nao sejam computados.
					Loop
				endif
			endif
			// Valido novamente a DIPAM 1.1 a 1.3, pois dentro do laço posso ter vários participantes do mesmo municipio, produtor rural sim/não
			If ( cCodDip $ "11|12|13" )
				If ( cAliasQry )->C1H_RAMO == "4" // acumulo apenas para produtores rurais
					nValor+= ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				EndIf
			ElseIf ( cCodDip == "25" ) .and. ( ( cAliasQry )->C0Y_CODIGO $ cCFOP25 )
				If cOpcDpam25 == "02" // 02 - Comercialização -> opção Wizard "Rateio DIPAM 2.5"
					nValor := 1
				Else
					nValor+= ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				EndIf
			//No isento do dipam24 CST41 nao soma os valores, sera valor simbolico de R$0.01
			Elseif cCodDip == "24" .And. (cAliasQry)->C0Y_CODIGO $ cOpComunic .And. (cAliasQry)->D24C41 == 'S'
				lIseDipB24 := .T.
			Else
				If SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) == cCodDip .And. ( cAliasQry )->C20_INDOPE == '1'  
					nValor+= ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				Else
					nValor:= ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				Endif
				If SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "24" .And. ( cAliasQry )->C20_INDOPE == '0'
					nValorEnt += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				ElseIf SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "24" .And. ( cAliasQry )->C20_INDOPE == '1'
					nValorSai += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				ElseIf SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "23" .And. ( cAliasQry )->C20_INDOPE == '0' .And. ( ( cAliasQry )->C0Y_CODIGO $ cCFOP23 )
					nValorEnt += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				ElseIf SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "23" .And. ( cAliasQry )->C20_INDOPE == '1' .And. ( ( cAliasQry )->C0Y_CODIGO $ cCFOP23 )
					nValorSai += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS					
				Endif
				If SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "26" .And. ( cAliasQry )->C20_INDOPE == '0'
					nVlEnt26 += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				ElseIf SUBSTR( Alltrim((cAliasQry )->LF0_CODIGO) ,8,2 ) $ "26" .And. ( cAliasQry )->C20_INDOPE == '1' .And. SubStr(Alltrim((cAliasQry)->C0Y_CODIGO),1,1) $ "5|6|7"
					nVlSai26 += ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
				endif
			EndIf
			( cAliasQry )->( dbSkip() )
		EndDo
	Else
		While ( cAliasQry )->( !Eof( ) ) .and. SUBSTR( Alltrim( ( cAliasQry )->LF0_CODIGO ) ,8 ,2 ) == cCodDip
			nValor+= ( cAliasQry )->BASE + ( cAliasQry )->ISENCAO + ( cAliasQry )->OUTROS
			( cAliasQry )->( dbSkip( ) )
		EndDo
	EndIf

if !("26" $ cCodDip) .And.;
   !("24" $ cCodDip .And. lIseDipB24 .And. lAddIseD24) //entra apenas uma vez no DipamB24, caso seja isento pois aglutina todos no municipio do contribuinte
   	if ( lLastRegB23 .Or. cCodDip > "23" .Or. (cCodDip == "23" .And. nValorSai <= 0) ) .And. !lOnceB23 .And. !lAddDipB23 .And. lVlSimbB23
		lOnceB23 := .T. //controle para entrar somente uma vez
		cStrTxt := "30"
		cStrTxt += "23"
		cStrTxt += PadL( Alltrim(cMunContrib),5 ,"0" ) //municipio do contribuinte {ex: M0_CODMUN=3550308 ou 50308 -> C07_MUNGIA = '01004'}
		cStrTxt += xConvGIA(0.01,15)
		cStrTxt += CRLF
		nQtd30++
		WrtStrTxt( nHandle, cStrTxt )
		if lLastRegB23
			exit
		endif
	endif
	cStrTxt := "30"
	cStrTxt += cCodDip // CódDIP
	if ("24" $ cCodDip) .And. lIseDipB24
		lAddIseD24 := .T. //Tratamento para nao inserir o mesmo municipio do contribuinte caso existam outros municipios isentos.
		if !Empty( cMunContrib )
			cCodmun := cMunContrib
		endif
	endif
	cStrTxt += padl(IIF(Left(cCodDip,1)=='3','00000',alltrim(cCodmun)),5,"0") // Município

	//DIPAM2.3 Cliente não é empresa aérea, porem efetua operações de transporte com cargas, não necessariamente deverá enviar valor simbólico.
	If cCodDip $ "24" .And. lIseDipB24
		cStrTxt += xConvGIA(0.01,15)
	ElseIf (nValorSai-nValorEnt) <= 0 .And. cCodDip $ "24"
		cStrTxt += xConvGIA(1,15)
	Elseif cCodDip $ "23"
		cStrTxt += xConvGIA(nValorSai, 15)
	Else
		cStrTxt += xConvGIA(nValor, 15) // Valor
	Endif

	cStrTxt += CRLF

	if cCodDip $ "23" .And. nValorSai > 0
		nQtd30++
		WrtStrTxt( nHandle, cStrTxt )
	elseif !(cCodDip $ "23")
		nQtd30++
		WrtStrTxt( nHandle, cStrTxt )
	Endif

	//zera as variaveis de calculo
	nValor    := 0
	nValorSai := 0
	nValorEnt := 0
endif

EndDo

if ("26" $ cCodDip) //DIPAMB 2.6
	cStrBase := "3026"
	if lRateio //Com Rateio ( V81 )
		For nlA := 1 to len( aMunicRat )
			nQtd30++ //qtd de municipios
			cStrTxt := cStrBase + padl( alltrim(aMunicRat[nlA][1]) , 5 , "0" ) // Município
			nPct := (aMunicRat[nlA][2]/100)
			nDifMov := ( nVlSai26 - nVlEnt26 )
			If nDifMov <= 0
				cStrTxt += xConvGIA(1,15)
			else
				cStrTxt += xConvGIA( (nDifMov * nPct) , 15)
			endif
			cStrTxt += CRLF
			WrtStrTxt( nHandle, cStrTxt )
		Next nla
	else //Sem rateio Acumulado no Municipio do SIGAMAT
		nQtd30++ //qtd de municipios
		cStrTxt := cStrBase + padl( cMunContrib , 5 , "0" ) // Município
		nDifMov := ( nVlSai26 - nVlEnt26 )
		If nDifMov <= 0
			cStrTxt += xConvGIA(1,15)
		else
			cStrTxt += xConvGIA( nDifMov, 15 )
		endif
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt )
	endif
endif

( cAliasQry )->( dbCloseArea())
if oPrepare != Nil
	oPrepare:Destroy()
	oPrepare := nil
endif

cStrTxt:= "QTD" + STRZERO(nQtd30,4)
WrtStrTxt( nHandle, cStrTxt )

GerTxtGIA( nHandle, cTXTSys, cReg )

Recover
	lFound := .F.

End Sequence

//Tratamento para ocorrência de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()
Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()
EndIf 

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} QueryCR30

Efetua query que busca os registros referentes ao A PERG-B

@Param canoMEsRef-> Ano e mes referencia 
		cFilSel -> Filial selecionada

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function QryCR30(cAnoMesRef,cFilSel,cAliasQry,cIn,cMunContrib,oPrepare)
Local cSelect   := ""
Local cWhere    := ""
Local cFrom     := ""
Local cFrom2	:= ""
Local cDtiniRef := dtos(Firstday(stod(cAnoMesRef+'01'),1))
Local cDtFimRef := dtos(Lastday(stod(cAnoMesRef+'01'),0))
Local cFilAux 	:= cFilAnt
Local cMunFil   := ""
Local cInC2F	:= ""
Local cInC1H	:= ""
Local cIdCST41  := ""
Local aBind		:= {}

Default	cIn			:= ""
Default cMunContrib := ""
Default oPrepare    := Nil

lIN	:= Iif( !Empty(cIn), .T., .F. )

If lIN
	cInC2F	:=	INCompFil("C2F", cFilSel, cIn)
	cInC1H	:=	INCompFil("C1H", cFilSel, cIn)
EndIf

/*	Código 2.2 - Revendedores Autônomos - Valores adicionados por operações e prestações realizadas por revendedores autônomos.
	Critérios de Geração: (Empresas que preparam refeições fora do município de seu estabelecimento) ; CNAE 5620-1/01 até 5620-1/04 
	                      (Empresas que devam distribuir seu valor adicionado por decisão judicial ou por Regime Especial) 
							 Se houver cadastro com o código 2.2, preencher com o valor da DIPAM e Preencher com o código de Município de Origem
	
	SOLUÇÃO -> FILTRAR AS NOTAS QUE VENHAM COM O CODIGO DA DIPAM E CRIADO PARA GERAR OU NÃO O CÓDIGO 2.2
	**********************************************************************************************************************************************************
	Código 2.3 - Prestadores de Serviço Transporte - Valores adicionados por prestação de transporte intermunicipal e interestadual, distribuídos por Município 
				Paulista, onde tenha iniciado o serviço (ORIGEM DO FRETE). 
				As prestações iniciadas em outros Estados, deverão ser apropriadas ao município paulista onde esteja inscrito o contribuinte.
	Critérios de Geração: Considerar os CFOPs nesta operação (5.351 a 5.360); (6.351 a 6.360) 
							 O total lançado não pode ultrapassar a soma dos CFOPs ; 
							 Considerar Município paulista na origem(Verificar - 'Município Coleta (IBGE)' 
							 Município de Origem e Local de Retirada. ; 
							 Se houver aquisição de serviço de transporte para prestação de serviço da mesma natureza, deve ser deduzido do 
							 valor total do serviço prestado (CFOP 1.932, 1.351, 2.351 E 3.351), desde que não rateado pela subcontratada. 
							 Se o resultado for igual ou menor que zero, deve ser informado um valor simbólico no código 2.3 de R$ 1,00.
	SOLUÇÃO -> FILTRAR AS NOTAS QUE VENHAM COM O CODIGO DA DIPAM, SEPARAR POR ENTRADA (1.932, 1.351, 2.351 E 3.351) E SAIDA ((5.351 a 5.360) E (6.351 a 6.360)
	           SUBTRAIR O SERVIÇO PRESTADO POR ARQUISIÇÃO DE SERVIÇO E SE O VALOR FOR INFERIOR A 0, EFETUAR UM LANÇAMENTO NO VALOR DE 1,00
	**********************************************************************************************************************************************************
	Código 2.4 - Prestadores de Serviço de Comunicação - Valores adicionados por prestação de serviços de comunicação, distribuídos por Município Paulista, onde
				o serviço tenha sido prestado.
	Critérios de Geração: Considerar os CFOPS nesta operação: (5.301 a 5.349) ; (6.301 a 6.349) 
							 O total lançado não pode ultrapassar a soma dos CFOPs ; 
							 Se houver aquisição de serviço de comunicação para prestação de serviço da mesma natureza (CFOP 1.301, 2.301 e 3.301), o valor dessa 
							 entrada deve ser deduzido do valor total do subsequente serviço prestado. 
							 Se o resultado for igual ou menor que zero, deve ser informado um valor simbólico no código 2.3 de R$ 1,00.
	SOLUÇÃO -> FILTRAR AS NOTAS QUE VENHAM COM O CODIGO DA DIPAM, SEPARAR POR ENTRADA (1.301, 2.301 e 3.301) E SAIDA (5.301 a 5.349) e (6.301 a 6.349) 
	           SUBTRAIR O SERVIÇO PRESTADO POR ARQUISIÇÃO DE SERVIÇO E SE O VALOR FOR INFERIOR A 0, EFETUAR UM LANÇAMENTO NO VALOR DE 1,00 
	**********************************************************************************************************************************************************
	Código 2.5	- Geradoras ou Distribuidoras de Energia Elétrica 
				- Valores adicionados por fornecimento de energia elétrica, distribuídos por Município Paulista onde a energia tenha sido consumida.
	Critérios de Geração: Considerar os CFOPS nesta operação: (5.153; 6.153) ; (5.251 a 5.258) ; (6.251 a 6.258) e 7.251.
							 O total lançado não pode ultrapassar a soma dos CFOPs.
	SOLUÇÃO -> FILTRAR AS NOTAS QUE VENHAM COM O CODIGO DA DIPAM PARA GERAR OU NÃO O CÓDIGO 2.5
	**********************************************************************************************************************************************************
	Código 2.6 - Apropriação do Valor da Produção Agropecuária - Distribuir por Município Paulista o valor da produção agropecuária, inclusive de 
				hortifrutigranjeiros, nos casos de a produção ocorrer no território de mais de um município.
	Critérios de Geração: Se houver cadastro com o código 2.6, preencher com o valor da DIPAM e preencher com o código de Município de Origem.
	SOLUÇÃO -> COMO JÁ É FEITO NOS DIAS DE HOJE (SEM CRITÉRIO ESPECIFICO)
	**********************************************************************************************************************************************************
	Código 2.7	- Vendas Presenciais com Saídas em Outro Estabelecimento - O estabelecimento que promover saídas de mercadorias por estabelecimento diverso 
				daquele na qual as transações comerciais são realizadas, excluídas as transações comerciais não presenciais, deve informar neste código o valor 
				das operações informando os respectivos Municípios onde as transações foram realizadas. 
	Critérios de Geração: Válido apenas para casos em que ambos estabelecimentos estejam localizados no Estado de São Paulo ; considerar os CFOPs de Saídas/Vendas; 
							 além das seguintes condições:
							 Condição 01: O deslocamento fisicamente do Comprador/Adquirente a um estabelecimento paulista, para efetuar a negociação ou a transação comercial,
							 Condição 02: A mercadoria objeto desta negociação deve sair de outro estabelecimento deste Estado, diferente do estabelecimento onde ocorreu a 
							 transação/negociação (INICIAL), em CFOP de SAÍDAS constante no Anexo 1 do Manual da DIPAM.
	SOLUÇÃO -> COMO JÁ É FEITO NOS DIAS DE HOJE, POREM SUBTRAIR AS ENTRADAS E SAIDAS PERTINENTES AO CODIGO 2.7 E SE O VALOR FOR INFERIOR A 0, EFETUAR UM LANÇAMENTO NO VALOR DE 1,00
*/

cFilAnt := cFilSel

cMunFil := AllTrim( FWSM0Util( ):GetSM0Data( , cFilSel , { "M0_CODMUN" } )[1][2] )

// Realizado tratativa para codigo de município, pois no campo SM0->M0_CODMUN pode ser informado o codigo da UF + o código de municipio
If !Empty( cMunFil )
	If Len(  cMunFil ) > 5
		cMunFil := Substr( cMunFil, 3 )
    Else
		cMunFil := StrZero( Val(  cMunFil  ), TamSx3( "C07_CODIGO")[1] )
	EndIf
Endif
cMunContrib := Posicione("C07",1,xFilial("C07")+"000027"+cMunFil,"C07_MUNGIA") //C07_FILIAL, C07_UF, C07_CODIGO
cIdCST41 := Posicione("C14",1,xFilial("C14")+"41","C14_ID") //C14_FILIAL, C14_CODIGO, C14_VALIDA, R_E_C_N_O_, D_E_L_E_T_

cSelect := "SELECT "
cSelect += "TMPA.LF0_CODIGO, TMPA.C2F_CODTRI, C07.C07_MUNGIA, TMPA.C0Y_CODIGO, TMPA.C1H_RAMO, TMPA.BASE, TMPA.ISENCAO, "
cSelect += "TMPA.OUTROS, TMPA.C20_INDOPE, TMPA.C20_NUMDOC, TMPA.D24C41, TMPA.C39_UFORIG, TMPA.C39_UFDEST "
cSelect += "FROM ( "
cSelect += "SELECT DISTINCT LF0.LF0_CODIGO, "
If lIN
	cSelect += "C20.C20_FILIAL, "
EndIf
cSelect += "C2F.C2F_CODTRI, "
cSelect += "(CASE WHEN (LF0.LF0_CODIGO = ? AND C39.C39_CMUNOR <> C1H.C1H_CODMUN AND C39.C39_CMUNOR <> ? "
cSelect += "AND C39.C39_CHVNF <> ? AND C39.C39_NUMITE <> ? AND C39.C39_CODITE <> ? AND C39.D_E_L_E_T_ = ? ) "
cSelect += "THEN C39.C39_CMUNOR ELSE C1H.C1H_CODMUN END) MUNGIA, "
aadd(aBind,'SPDIPAM23')
aadd(aBind,space(1))
aadd(aBind,space(1))
aadd(aBind,space(1))
aadd(aBind,space(1))
aadd(aBind,space(1))

cSelect += "COALESCE(C39.C39_CMUNOR,' ') C39_CMUNOR, "
cSelect += "C1H.C1H_UF, "
cSelect += "COALESCE(C39.C39_UFORIG,' ') C39_UFORIG, "
cSelect += "COALESCE(C39.C39_UFDEST,' ') C39_UFDEST, "
cSelect += "C0Y.C0Y_CODIGO, " // Incluído campo de CFOP para validar CFOP's da DIPAM 2.5
cSelect += "C1H.C1H_RAMO, "   // Campo utilizado para validar registro DIPAM 1.1 a 1.3
cSelect += "C2F_BASE BASE, "
cSelect += "C2F.C2F_VLISEN ISENCAO, "
cSelect += "C2F.C2F_VLOUTR OUTROS, "
cSelect += "C20.C20_INDOPE, "
cSelect += "C20.C20_NUMDOC, "

cSelect += "(CASE WHEN LF0.LF0_CODIGO = ? AND EXISTS( SELECT A.C2F_CST FROM " + RetSqlName( "C2F" ) + " A "
cSelect += "WHERE A.C2F_FILIAL = C2F.C2F_FILIAL AND A.C2F_CHVNF = C2F.C2F_CHVNF "
cSelect += "AND A.C2F_CODTRI = ? AND A.C2F_CST = ? AND A.D_E_L_E_T_ = ? ) THEN 'S' ELSE 'N' END ) D24C41 "
aadd(aBind,'SPDIPAM24')
aadd(aBind,'000002')
aadd(aBind,(cIdCST41))
aadd(aBind,space(1))

cFrom := RetSqlName( "C2F" ) + " C2F "

cFrom += "INNER JOIN " + RetSqlName( "C20" ) + " C20 ON "
cFrom += "C20.C20_FILIAL = C2F.C2F_FILIAL "
cFrom += "AND C20.C20_CHVNF = C2F.C2F_CHVNF "
cFrom += "AND C20.C20_CODSIT IN (?) "
cFrom += "AND C20.C20_DTES >= ? AND C20.C20_DTES <= ? "
cFrom += "AND C20.D_E_L_E_T_ = ? "
aadd(aBind,{'000001','000002','000007','000008','000009'})
aadd(aBind,cDtiniRef)
aadd(aBind,cDtFimRef)
aadd(aBind,space(1))

cFrom += "INNER JOIN " + RetSqlName( "C30" ) + " C30 ON " // Tributos NF x Itens NF
cFrom += "C30.C30_FILIAL = C2F.C2F_FILIAL "
cFrom += "AND C30.C30_CHVNF = C2F.C2F_CHVNF "
cFrom += "AND C30.C30_CFOP = C2F.C2F_CFOP "
cFrom += "AND C30.C30_CODIPA <> ? "
cFrom += "AND C30.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,space(1))

cFrom += "INNER JOIN " + RetSqlName( "LF0" ) + " LF0 ON " //Codigos DIPAM x Itens NF que tenham DIPAM
cFrom += "LF0.LF0_FILIAL = ? "
cFrom += "AND LF0.LF0_ID = C30.C30_CODIPA "
cFrom += "AND LF0.D_E_L_E_T_ = ? "
aadd(aBind,xFilial("LF0"))
aadd(aBind,space(1))

cFrom += "INNER JOIN " + RetSqlName( "C1H" ) + " C1H ON " // Participantes x Participantes da NF
if lIN
	cFrom += "C1H.C1H_FILIAL IN (?) "
	aadd(aBind,cInC1H)
else
	cFrom += "C1H.C1H_FILIAL = ? "
	aadd(aBind,xFilial("C1H"))
endif
cFrom += "AND C1H.C1H_ID = C20.C20_CODPAR "
cFrom += "AND C1H.D_E_L_E_T_ = ? "
aadd(aBind,space(1))

cFrom += "LEFT JOIN " + RetSqlName( "C39" ) + " C39 ON "
cFrom += "C39.C39_FILIAL = C30.C30_FILIAL "
cFrom += "AND C39.C39_CHVNF  = C30.C30_CHVNF "
cFrom += "AND C39.C39_NUMITE = C30.C30_NUMITE "
cFrom += "AND C39.C39_CODITE = C30.C30_CODITE "
cFrom += "AND C39.D_E_L_E_T_ = ? "
aadd(aBind,space(1))

cFrom += "INNER JOIN " + RetSqlName( "C0Y" ) + " C0Y ON " // CFOP do tributo NF x autocontida CFOP
cFrom += "C0Y.C0Y_FILIAL = ? "
cFrom += "AND C0Y.C0Y_ID = C2F.C2F_CFOP "
cFrom += "AND C0Y.D_E_L_E_T_ = ? "
aadd(aBind,xFilial("C0Y"))
aadd(aBind,space(1))

if lIN
	cWhere := "C2F.C2F_FILIAL IN (?) "
	aadd(aBind,cInC2F)
else
	cWhere := "C2F.C2F_FILIAL = ? "
	aadd(aBind,xFilial("C2F"))
endif
cWhere += "AND C2F.C2F_CODTRI IN (?) "
cWhere += "AND C2F.D_E_L_E_T_ = ? "
aadd(aBind,{'000002','000003','000017'})
aadd(aBind,space(1))

cFrom2 += "INNER JOIN " + RetSqlName( "C07" ) + " C07 ON " // Municipios IBGE
cFrom2 += "C07_FILIAL = ? AND C07.C07_ID = TMPA.MUNGIA "
aadd(aBind,xFilial("C07"))

cFrom2 += " AND ( ( TMPA.C1H_UF = ? AND C07.C07_MUNGIA <> ? ) "
aadd(aBind,'000027')
aadd(aBind,space(1))

/*
	Situação especifica para NF saída DIPAM 2.5
    Filial do municipio de São Paulo comercializou energia para o fora do Estado de SP
    Por isso foi considerado o Codigo de Municipio da Filial logada ( SM0->M0_CODMUN ) e Participante da NF Saída de outro estado
*/
cFrom2 += " OR ( TMPA.LF0_CODIGO = ? AND C07.C07_CODIGO = ? AND TMPA.C1H_UF != ? AND C07.C07_MUNGIA = ? ) " // Participantes de outro estado
aadd(aBind,'SPDIPAM25')
aadd(aBind,cMunFil)
aadd(aBind,'000027')
aadd(aBind,space(1))

/*
	Situação especifica para NF saída DIPAMB 2.6 
    Filial do municipio de São Paulo comercializou para fora do Estado de SP
    Por isso foi considerado o Participante da NF Saída de outro estado
*/
cFrom2 += " OR ( TMPA.LF0_CODIGO = ? AND TMPA.C1H_UF != ? AND C07.C07_MUNGIA = ? ) "
aadd(aBind,'SPDIPAM26')
aadd(aBind,'000027')
aadd(aBind,space(1))

//Situação especifica para NF DIPAM 2.3
// Participantes de outro estado, ex: RJ porem efetua operacoes em SP (ex: sorocaba p/ sp)
cFrom2 += " OR ( TMPA.LF0_CODIGO = ? AND C07.C07_UF = ? AND TMPA.C39_CMUNOR <> ? AND TMPA.C1H_UF != ? ) ) "
aadd(aBind,'SPDIPAM23')
aadd(aBind,'000027')
aadd(aBind,space(1))
aadd(aBind,'000027')

cFrom2 += " AND C07.D_E_L_E_T_ = ? "
aadd(aBind,space(1))

cQuery := cSelect + " FROM " + cFrom + " WHERE " + cWhere + " ) TMPA " + cFrom2
cQuery += " ORDER BY TMPA.LF0_CODIGO, TMPA.C2F_CODTRI, C07.C07_MUNGIA, TMPA.C0Y_CODIGO, TMPA.C1H_RAMO, TMPA.C20_INDOPE "

cQuery := ChangeQuery( cQuery ) //nao eh necessario fazer cache na string da query pois eh executado apenas uma vez.

oPrepare := FwExecStatement():New( cQuery )

TafSetPrepare(@oPrepare, @aBind)

oPrepare:OpenAlias( cAliasQry ) //oPrepare:GetFixQuery()

cFilAnt := cFilAux

aSize(aBind,0)
aBind := nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRatMu
Verifica se existe rateio e referencia o array com a % de participacao

@parametro
aDadosC1E[1] Id
aDadosC1E[2] Versao

@author Denis Souza \ Jose Felipe
@since 21/01/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------- 
Static Function GetRatMun( aDadosC1E, aMunicRat )

Local cAlias   := ""
Local cSelect  := ""
Local cFrom    := ""
Local cInnerJ  := ""
Local cWhere   := ""
Local cOrderBy := ""
Local cQuery   := ""

Local aBind	:= {}
Local oExec := Nil

Default aDadosC1E := {'',''}
Default aMunicRat := {}

cSelect += "C07.C07_MUNGIA, V81.V81_PERC"

cFrom   += RetSqlName("V81") + " V81 "

cInnerJ += RetSqlName("C07") + " C07 ON "
cInnerJ += "C07.C07_FILIAL = ? AND C07.C07_UF = V81.V81_UF AND C07.C07_ID = V81.V81_CODMUN AND C07.C07_MUNGIA <> ? AND C07.D_E_L_E_T_ = ? "
aadd(aBind,xFilial("C07"))
aadd(aBind,space(1))
aadd(aBind,space(1))

cWhere += "V81.V81_FILIAL = ? AND V81.V81_ID = ? AND V81.V81_VERSAO = ? AND V81.V81_ATIVO = ? AND V81.D_E_L_E_T_ = ? "
aadd(aBind,xFilial("V81"))
aadd(aBind,aDadosC1E[1])
aadd(aBind,aDadosC1E[2])
aadd(aBind,'1')
aadd(aBind,space(1))

cOrderBy := "C07.C07_MUNGIA"

cQuery := "SELECT " + cSelect + " FROM " + cFrom + " INNER JOIN " + cInnerJ + " WHERE " + cWhere + " ORDER BY " + cOrderBy

cQuery := ChangeQuery( cQuery ) //nao eh necessario fazer cache na string da query pois eh executado apenas uma vez.

oExec := FwExecStatement():New( cQuery )

TafSetPrepare(@oExec,@aBind)

cAlias := GetNextAlias()

oExec:OpenAlias( cAlias ) //oExec:GetFixQuery()

If (cAlias)->(!EOF())
	aMunicRat := {}
	While (cAlias)->(!EOF())
		aAdd( aMunicRat , { (cAlias)->C07_MUNGIA, (cAlias)->V81_PERC } )
		(cAlias)->( DbSkip())
	EndDo
endif

(cAlias)->(dbCloseArea())
aSize(aBind,0)
aBind := nil
if oExec != Nil
	oExec:Destroy()
	oExec := nil
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSetPrepare
Realiza atribuicao dos filtros, seja string ou array
para utilizacao do bind nas queries com FwExecStatement e OpenAlias

@parametro
oPrepare nil
aBind {}

@author Denis Souza
@since 05/09/2024
@version 1.0
/*/ 
//-------------------------------------------------------------------- 
Static Function TafSetPrepare(oObj,aBind)

Local nA := 0

Default oObj := Nil
Default aBind := {}

for nA := 1 to len(aBind)
    if Valtype(aBind[nA]) == 'A'
        oObj:setIn( nA, aBind[nA] )
    else
        oObj:setString( nA, aBind[nA] )
    endif
next nA

Return Nil
