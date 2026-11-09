#Include 'Protheus.ch'
#include 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDMOVPESL
Função principal para montagem da DIOPS

@author  Rodrigo Morgon
@version P12
@since   03/02/2017
/*/
//-------------------------------------------------------------------
Function PLDMOVPESL()

//Abre pergunte "PLDMOVPESL"
/*
cTrimestre 	mv_par01
cAno			mv_par02
*/

local aDados 	:= {}
local cPerg	:= "PLDMOVPESL"      
local AMESESTRIM:={}

if !Pergunte(cPerg,.t.)
	return
endif
cTrimestre:= mv_par01
cAno	  := mv_par02

//Chama função para obter os dados
Processa({|| aDados := PLDMOVPDAD(cTrimestre, cAno , .T.) }, "Aguarde", "Gerando dados...", .t.)

//Chama função para gerar o .CSV
if len(aDados) > 0
	PLDMOVPCSV(aDados, aMesesTrim)
else
	MsgAlert("Não foram encontrados dados para este quadro da DIOPS.")
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDMOVPDAD
Dados da DIOPS da movimentação de PESL

@author  Rodrigo Morgon
@version P12
@since   03/02/2017
@param   aDados, array, dados considerados para gerar o CSV

@return  nil, resultado da função é o .CSV gerado na pasta do server.
/*/
//-------------------------------------------------------------------
Function PLDMOVPDAD(cTrimestre, cAno, lDadosCSV)
Local cQuery		:= ""
Local cSql			:= ""
Local aContas		:= {}
Local aDados 		:= {}
Local aDadosRet		:= {}
Local nI 			:= 1
Local nX 			:= 1
Local nY			:= 1
Local nZ			:= 1
Local nVal			:= 0
Local aDadosTemp	:= {}
Local dDtFim		:= nil
Local nValTotal		:= 0
Local aMesesTrim	:= {}
Local cCtas         := ""
Default lDadosCSV	:= .T.
Default cTrimestre	:= MV_PAR01
Default cAno		:= MV_PAR02 

aMesesTrim := CalcTriMes(cTrimestre, cAno)

//Monta aDados de acordo com o array esperado no CSV
//aDados[ [ano,mes,codigo,valor] , [ano,mes,codigo,valor] , ... , [ano,mes,codigo,valor] ]	

//Monta régua dos meses
ProcRegua(len(aMesesTrim)) 

for nI := 1 to len(aMesesTrim)
	
	//Adiciona novo item do mês para o array de dados
	aadd(aDados, {})
			
	//------------- Início 1º quadro ----------------
	// Código 0 - Saldo início do mês
	//-----------------------------------------------
	aadd(aContas,"21111903")
	aadd(aContas,"21112903")
	aadd(aContas,"23111903")
	aadd(aContas,"23112903")
	
	nVal := 0
			
	//Percorre todos os itens das contas e utiliza função do contábil para retornar os dados
	for nX := 1 to len(aContas)
		nVal += SaldoConta(aContas[nX],STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"01"),"01","1",1,1)
	next nX
	
	//Adiciona no array principal os valores para o código 0, primeiro quadro
	aadd(aDados[nI], {{0,nVal}})
	//------------- FIM 1º quadro -------------------
	
	//------------- INÍCIO 2º quadro ----------------
	// Código 29 a 32 - Total pago no mês
	//-----------------------------------------------
	//BD7 - Faturado (fase 4) / contabilizado / pago
	// |--- SE2 - Verificar data de baixa
	//Considerar E2_BAIXA como data de baixa (pagamento do título)
							
	//Fazer a query repetidas vezes para n igual 1 até que n seja igual a 3
	for nY := 0 to 3		
		//Cálculo para obter mês e ano corretos			
		if nY > 0
			//Se for da segunda linha em diante
			if cMesAnt == "01"
				//Mes anterior igual a janeiro, diminuo um numero do ano e defino o mês como dezembro (último mês do ano anterior)
				cMesOcorr := AllTrim(STR(Val(cAnoAnt)-1)) + "12"
				cMesAnt := "12"
				cAnoAnt := STR(Val(cAnoAnt)-1)
			else
				//Subtrai um mês para obter os valores da query
				cMesOcorr := cAnoAnt + AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
				cMesAnt := AllTrim(STRZERO(Val(cMesAnt)-1,2,0))										
			endif
		else
			//Primeira linha do quadro, utiliza os dados de ano e mês atuais
			cMesAnt := aMesesTrim[nI][2]
			cAnoAnt := aMesesTrim[nI][1]
			cMesOcorr := aMesesTrim[nI][1]+aMesesTrim[nI][2]
		endif
		
		//Buscar a query, agrupar por ano, mês, where feito com base no aMesesTrim[nI][1] <-- ano e aMesesTrim[nI][2] <-- mes					
		//cQuery	:= "SELECT SUM(CT2_VALOR) AS VALOR " //Soma dos valores para a linha do mês correspondente
		cQuery	:= "SELECT CT2_VALOR AS VALOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"
		cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "	
				
		//Rede de Atendimento
		cQuery	+= "INNER JOIN "+RetSqlName("BAU")+" BAU "
		cQuery	+= "ON BAU_FILIAL	= '" + xFilial("BAU") + "' " 
		cQuery	+= "AND BAU_CODIGO = BD7.BD7_CODRDA "
		cQuery	+= "AND BAU.D_E_L_E_T_ = ' ' "
									
		//Títulos a pagar
		cQuery	+= "INNER JOIN "+RetSqlName("SE2")+" SE2 "
		cQuery	+= "ON  E2_FILIAL 	= '" + xFilial("SE2") + "' "
		cQuery	+= "AND E2_FORNECE	= BAU.BAU_CODSA2 "
		cQuery	+= "AND E2_LOJA		= BAU.BAU_LOJSA2 "
		cQuery	+= "AND E2_ANOBASE	= BD7.BD7_ANOPAG "
		cQuery	+= "AND E2_MESBASE	= BD7.BD7_MESPAG "
		cQuery	+= "AND E2_PLOPELT	= BD7.BD7_OPELOT "
		cQuery	+= "AND E2_PLLOTE	= BD7.BD7_NUMLOT "
		cQuery	+= "AND E2_CODRDA	= BD7.BD7_CODRDA "
		cQuery	+= "AND E2_BAIXA BETWEEN '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"01' AND '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31' "
		//Já foi pago e não há saldo
		cQuery	+= "AND E2_SALDO = '0'"	
		cQuery	+= "AND SE2.D_E_L_E_T_ = ' ' "
		
		//Rastreamento Contábil
		cQuery	+= "INNER JOIN "+RetSqlName("CV3")+" CV3 "
		cQuery	+= "ON CV3_FILIAL	= '" + xFilial("CV3") + "' "
		cQuery	+= "AND CV3.CV3_TABORI = 'BD7' "	
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_  "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ "
		EndIf
		
		cQuery	+= "AND CV3.D_E_L_E_T_ 	= '' "
		
		//Lançamentos Contábeis
		cQuery += "INNER JOIN "+RetSqlName("CT2")+" CT2 "
		cQuery += "ON CT2_FILIAL 	= '" + xFilial("CT2") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND CT2.R_E_C_N_O_ = NVL(CAST(CV3_RECDES as int),0)  "
		Else
			cQuery	+= "AND CT2.R_E_C_N_O_ = CONVERT(Int,CV3_RECDES)  "
		EndIf		
		cQuery	+= "AND CT2.D_E_L_E_T_ = ' ' "
					
		//----------- Where -----------
		cQuery += "WHERE BD7_FILIAL	= '" + xFilial("BD7") + "' "
			
		//Data de ocorrência do evento. Para a ultima linha, serão considerados inclusive todos os itens anteriores da base.
		if nY == 3
			cQuery	+= "AND BD7.BD7_DTDIGI <= '" + cMesOcorr + "31' "	
		else
			cQuery	+= "AND BD7.BD7_DTDIGI BETWEEN '" + cMesOcorr + "01' AND '" + cMesOcorr + "31' "	
		endif
		cQuery	+= "AND BD7_SITUAC = '1' "
		cQuery	+= "AND BD7_FASE = '4' " 								
		cQuery	+= "AND BD7.D_E_L_E_T_ = '' "							
		
		//Garanto que não está aberto
		If Select("TMPMOVPESL") > 0
			TMPMOVPESL->(dbSelectArea("TMPMOVPESL"))
			TMPMOVPESL->(dbCloseArea())
		EndIf
		
		cQuery	:= ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPMOVPESL",.T.,.F.)
				
		dDtFim := LastDay(STOD(alltrim(aMesesTrim[nI][1])+alltrim(aMesesTrim[nI][2])+'01'))
		While TMPMOVPESL->(!EOF())
			nValTotal += TMPMOVPESL->VALOR
			TMPMOVPESL->(DbSkip())
		End
		//----------------------------------------------------------------------------------------------
		// Percorre títulos encontrados que tem vínculo com a SE2 e CV3
		//    para retirar do valor total baixado os títulos de renegociação que ainda estão em aberto
		//----------------------------------------------------------------------------------------------
		//While DEBPESL->(!EOF())
		TMPMOVPESL->(DbGoTop())
		
		While TMPMOVPESL->(!EOF())	
						
			//busco o título, pois preciso ver em qual período aconteceu o evento e preciso assegurar que ele foi baixado mesmo
			/*if(DEBPESL->CV3_TABORI == "SE5")
				SE5->(dbGoTo(val(DEBPESL->CV3_RECORI)))
				SE2->(msSeek(xFilial("SE2")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
			elseif(DEBPESL->CV3_TABORI == "SE2")
				SE2->(dbGoTo(val(DEBPESL->CV3_RECORI)))
			endIf*/		

			//Com a função saldotit eu asseguro se o titulo está baixado mesmo, se não estiver baixado
			//significa que está em aberto e eu tenho que manter o saldo da PEL
			//Verifico se o titulo foi negociado, se foi, vou desconsiderar,
			//pq dps vou pegar o debito da parcela que estará contabilizada				
			//verifico se é um título de negociação para fazer o valor proporcional, aqui é a parcela e não o tit origem
			FI8->(dbSetOrder(2)) //FI8_PRFDES+FI8_NUMDES+FI8_PARDES+FI8_TIPDES+FI8_FORDES+FI8_LOJDES
			FI8->(dbGoTop())
			
			if(FI8->(msSeek(xFilial("FI8")+TMPMOVPESL->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))))	
				lNeg := .T.
				nVlrTitNeg := SE2->E2_VALOR
				//posiciono no titulo origem
				SE2->(msSeek(xFilial("SE2")+FI8->(FI8_PRFORI+FI8_NUMORI+FI8_PARORI+FI8_TIPORI+FI8_FORORI+FI8_LOJORI)))
			else
				lNeg := .F.
				nVlrTitNeg := 0
			endIf
				
			//verifico se no meu título eu tenho eventos que foram conhecidos no mês da linha atual
			//se eu tiver eventos em apenas um período, não preciso nem olhar o BD7, só pegar o CT2_VALOR da
			//conta debito e subtrair do saldo certo
			//mas se eu tiver eventos nos dois períodos eu preciso subtrair cada um do seu saldo
			
			cSql := " SELECT "
			cSql += " BD7_DTDIGI, "
			cSql += " BD7_VLRAPR,
			cSql += " BD7_VLRPAG "
			cSql += " FROM " + RetSqlName("BD7") 
			cSql += " WHERE "
			cSql += " BD7_FILIAL = '" + XFILIAL('BD7') + "' "
			cSql += " AND BD7_OPELOT = '" + SE2->E2_PLOPELT + "' " 
			cSql += " AND BD7_NUMLOT = '" + SE2->E2_PLLOTE  + "' "
			cSql += " AND BD7_ANOPAG = '" + SE2->E2_ANOBASE + "' "
			cSql += " AND BD7_MESPAG = '" + SE2->E2_MESBASE + "' "
			cSql += " AND D_E_L_E_T_ = ' ' "
			cSql += " ORDER BY BD7_DTDIGI ASC "
			
			cSql := ChangeQuery(cSql)
			
			If Select("EVEPESL") > 0
				EVEPESL->(dbSelectArea("EVEPESL"))
				EVEPESL->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"EVEPESL",.T.,.F.)
				
			//como está ordenado por data, se a primeira e a ultima data estiverem no mesmo
			//mês, sei que não preciso percorrer o while da query para subtrair/ratear o valor nos meses anteriores ou posteriores
			if EVEPESL->(!EOF())						
				//Verifico se a data de conhecimento dos eventos está dentro do mês da linha, caso contrario, percore cada um deles para verificar o intervalo
				if nY == 3 //Ultima linha						
					if (EVEPESL->BD7_DTDIGI <= cMesOcorr + "31")
						nValTotal -= TMPMOVPESL->CT2_VALOR
					endif							
				elseif (EVEPESL->BD7_DTDIGI >= (cMesOcorr + "01")) .and. (EVEPESL->BD7_DTDIGI <= (cMesOcorr + "31"))							
					EVEPESL->(dbGoBottom())	
					//Verifica se a última linha está no mesmo intervalo. Se tiver, retiro o valor em aberto do valor do mês referenciado
					if (EVEPESL->BD7_DTDIGI >= cMesOcorr + "01") .and. (EVEPESL->BD7_DTDIGI <= cMesOcorr + "31")
						nValTotal -= TMPMOVPESL->CT2_VALOR
					endif
				else
					//Se chegar nessa condição, significa que possui eventos tanto no mês referenciado quanto em outros, percorre então todos os itens para								
					While EVEPESL->(!EOF())
						nVlrEvento := iif(EVEPESL->BD7_VLRAPR > 0, EVEPESL->BD7_VLRAPR, EVEPESL->BD7_VLRPAG)
						
						//se for negociação, pego o valor proporcional do evento
						if lNeg
							nVlrEvento := (nVlrEvento/SE2->E2_VALOR)*nVlrTitNeg							
						endif
						
						if nY == 3
							if (EVEPESL->BD7_DTDIGI <= cMesOcorr + "31")
								nValTotal -= nVlrEvento
							endif
						elseif (EVEPESL->BD7_DTDIGI >= cMesOcorr + "01") .and. (EVEPESL->BD7_DTDIGI <= cMesOcorr + "31")
							nValTotal -= nVlrEvento
						endif
						
						EVEPESL->(dbSkip())
					EndDo						
				endIf						
			endIf				
							
			TMPMOVPESL->(dbSkip())		
		End
		
		
		
		//Se tiver registro, adiciona no aDadosTemp o codigo correspondente somado com 33 que é o início desse quadro.
		//Ao final do for, será 13 + 33 = 46 que é o último item do quadro.
		aadd(aDadosTemp, {nY + 33, Round(nValTotal,2)})
			
		nValTotal := 0
		
		//DEBPESL->(dbCloseArea())	
		TMPMOVPESL->(dbCloseArea())
	next nY
			
	//Adiciona no aDados os registros obtidos no 3º quadro
	aadd(aDados[nI], aDadosTemp)
	
	aDadosTemp := {}
	
	//------------- FIM 2º quadro -------------------	
	
	//------------- INÍCIO 3º quadro -----------------------------
	// Código 33 a 46 - Total dos novos avisos reconhecidos no mês 
	//------------------------------------------------------------
	//Lista contas a serem buscadas
	//TODO: Desenvolver forma de customizar as contas
	cContas :="'411111011','411111021','411111031','411111041','411111051','411111061','411111017','411111027','411111037',"
	cContas +="'411111047','411111057','411111067','411111081','411121011','411121021','411121031','411121041','411121051',"
	cContas +="'411121061','411121017','411121027','411121037','411121047','411121057','411121067','411121081','411211011',"
	cContas +="'411211021','411211031','411211041','411211051','411211061','411211081','411221011','411221021','411221031',"
	cContas +="'411221041','411221051','411221061','411221081','411311011','411311021','411311031','411311041','411311051',"
	cContas +="'411311061','411311081','411321011','411321021','411321031','411321041','411321051','411321061','411321081',"
	cContas +="'411411011','411411021','411411031','411411041','411411051','411411061','411411017','411411027','411411037',"
	cContas +="'411411047','411411057','411411067','411411081','411421011','411421021','411421031','411421041','411421051',"
	cContas +="'411421061','411421017','411421027','411421037','411421047','411421057','411421067','411421081','411511011',"
	cContas +="'411511021','411511031','411511041','411511051','411511061','411511081','411521011','411521021','411521031',"
	cContas +="'411521041','411521051','411521061','411521081','411711011','411711021','411711031','411711041','411711051',"
	cContas +="'411711061','411711017','411711027','411711037','411711047','411711057','411711067','411721011','411721021',"
	cContas +="'411721031','411721041','411721051','411721061','411721017','411721027','411721037','411721047','411721057',"
	cContas +="'411721067','411911011','411911021','411911031','411911041','411911051','411911061','411911017','411911027',"
	cContas +="'411911037','411911047','411911057','411911067','411911081','411921011','411921021','411921031','411921041',"
	cContas +="'411921051','411921061','411921017','411921027','411921037','411921047','411921057','411921067','411921081'" 
				
	//Fazer a query repetidas vezes para n igual 1 até que n seja igual a 13
	
	for nY := 0 to 13			
		//Cálculo para obter mês e ano corretos			
		if nY > 0
			//Se for da segunda linha em diante
			if cMesAnt == "01"
				//Mes anterior igual a janeiro, diminuo um numero do ano e defino o mês como dezembro (último mês do ano anterior)
				cMesOcorr := AllTrim(STR(Val(cAnoAnt)-1)) + "12"
				cMesAnt := "12"
				cAnoAnt := AllTrim(STR(Val(cAnoAnt)-1))
			else
				//Subtrai um mês para obter os valores da query
				cMesOcorr := cAnoAnt + AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
				cMesAnt := AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
			endif
		else
			//Primeira linha do quadro, utiliza os dados de ano e mês atuais
			cMesAnt := aMesesTrim[nI][2]
			cAnoAnt := aMesesTrim[nI][1]
			cMesOcorr := aMesesTrim[nI][1]+aMesesTrim[nI][2]
		endif
		
		//Buscar a query, agrupar por ano, mês, where feito com base no aMesesTrim[nI][1] <-- ano e aMesesTrim[nI][2] <-- mes					
		cQuery	:= "SELECT CASE BD7_VLRAPR WHEN 0 THEN SUM(BD7_VLRBPR) ELSE SUM(BD7_VLRAPR) END AS VALOR " 
		cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "		
		
		// Rastreamento Contábil
		cQuery	+= "INNER JOIN "+RetSqlName("CV3")+" CV3 "
		cQuery	+= "ON CV3_FILIAL = '" + xFilial("CV3") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_  "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ "
		EndIf
		cQuery	+= "AND CV3_TABORI		= 'BD7' "
		cQuery	+= "AND CV3.D_E_L_E_T_	= ' ' "
		
		// Lançamentos Contábeis
		cQuery	+= "INNER JOIN "+RetSqlName("CT2")+" CT2 "
		cQuery += "ON CT2_FILIAL = '" + xFilial("CT2") + "' "	
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECDES as int),0)= CT2.R_E_C_N_O_ "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_ "
		EndIf
		cQuery += "AND CT2.CT2_DEBITO IN (" + cContas + ") " //Contas débito
		cQuery	+= "AND CT2.D_E_L_E_T_	= ' ' "
		
		//----------- WHERE -------------
		cQuery	+= "WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "				
		cQuery += "AND BD7.BD7_DTDIGI BETWEEN '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"01' AND '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31' "
		
		if nY == 13 //Data de ocorrência do evento. Para a ultima linha, serão considerados inclusive todos os itens anteriores da base.
			cQuery	+= "AND BD7.BD7_DATPRO <= '" + cMesOcorr + "31' "	
		else
			cQuery	+= "AND BD7.BD7_DATPRO BETWEEN '" + cMesOcorr + "01' AND '" + cMesOcorr + "31' "	
		endif
				
		cQuery	+= "AND BD7.D_E_L_E_T_	= ' ' "
		cQuery += "GROUP BY BD7.BD7_VLRBPR, BD7.BD7_VLRAPR"
		
		cQuery	:= ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPMOVPESL",.T.,.F.)
					
		if !TMPMOVPESL->(EoF())
			//Se tiver registro, adiciona no aDadosTemp o codigo correspondente somado com 33 que é o início desse quadro.
			//Ao final do for, será 13 + 33 = 46 que é o último item do quadro.
			aadd(aDadosTemp, {nY + 33, TMPMOVPESL->VALOR})
		else
			//Se não tiver registro, adiciona linha em branco
			aadd(aDadosTemp, {nY + 33, 0}) 
		endif
					
		TMPMOVPESL->(dbCloseArea())
	next nY
			
	//Adiciona no aDados os registros obtidos no 3º quadro
	aadd(aDados[nI], aDadosTemp)
	aDadosTemp := {}
	
	//------------------- FIM 3º quadro ----------------						

	//----------------- Início 4º quadro ----------------------------	
	// Códigos 47 a 60 - Total de baixa por glosa reconhecidas no mês 
	//---------------------------------------------------------------	
	//TODO: Desenvolver forma de customizar as contas
	//Lista contas a serem buscadas
	cContas :="'411111012','411111022','411111032','411111042','411111052','411111062','411111082','411121012','411121022','411121032','411121042','411121052','411121062','411121082','411211012',"
	cContas +="'411211022','411211032','411211042','411211052','411211062','411211082','411221012','411221022','411221032','411221042','411221052','411221062','411221082','411311012','411311022',"
	cContas +="'411311032','411311042','411311052','411311062','411311082','411321012','411321022','411321032','411321042','411321052','411321062','411321082','411411012','411411022','411411032',"
	cContas +="'411411042','411411052','411411062','411411082','411421012','411421022','411421032','411421042','411421052','411421062','411421082','411511012','411511022','411511032','411511042',"
	cContas +="'411511052','411511062','411511082','411521012','411521022','411521032','411521042','411521052','411521062','411521082','411711012','411711022','411711032','411711042','411711052',"
	cContas +="'411711062','411721012','411721022','411721032','411721042','411721052','411721062','411911012','411911022','411911032','411911042','411911052','411911062','411911082','411921012',"
	cContas +="'411921022','411921032','411921042','411921052','411921062','411921082'"

	cMesAnt 	:= ""
	cAnoAnt 	:= ""
	cMesOcorr 	:= ""
	
	//Fazer a query repetidas vezes para n igual 1 até que n seja igual a 13
	
	for nY := 0 to 13
		//Cálculo para obter mês e ano corretos			
		if nY > 0
			//Se for da segunda linha em diante
			if cMesAnt == "01"
				//Mes anterior igual a janeiro, diminuo um numero do ano e defino o mês como dezembro (último mês do ano anterior)
				cMesOcorr := AllTrim(STR(Val(cAnoAnt)-1)) + "12"
				cMesAnt := "12"
				cAnoAnt := AllTrim(STR(Val(cAnoAnt)-1))
			else
				//Subtrai um mês para obter os valores da query
				cMesOcorr := cAnoAnt + AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
				cMesAnt := AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
			endif
		else
			//Primeira linha do quadro, utiliza os dados de ano e mês atuais
			cMesAnt := aMesesTrim[nI][2]
			cAnoAnt := aMesesTrim[nI][1]
			cMesOcorr := aMesesTrim[nI][1]+aMesesTrim[nI][2]
		endif
		
		//Buscar a query, agrupar por ano, mês, where feito com base no aMesesTrim[nI][1] <-- ano e aMesesTrim[nI][2] <-- mes	
					
		cQuery	:= "SELECT BD7_VLRGLO AS VALOR " 
		cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "		
		
		// Rastreamento Contábil
		cQuery	+= "INNER JOIN "+RetSqlName("CV3")+" CV3 "
		cQuery	+= "ON CV3_FILIAL = '" + xFilial("CV3") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_  "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ "
		EndIf
		cQuery	+= "AND CV3_TABORI 		= 'BD7' "
		cQuery	+= "AND CV3.D_E_L_E_T_ 	= ' ' "
		
		// Lançamentos Contábeis
		cQuery	+= "INNER JOIN "+RetSqlName("CT2")+" CT2 "
		cQuery += "ON	CT2_FILIAL = '" + xFilial("CT2") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECDES as int),0)= CT2.R_E_C_N_O_ "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_ "
		EndIf
		cQuery += "AND	CT2.CT2_DATA BETWEEN '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"01' AND '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31' "
		cQuery += "AND CT2.CT2_DEBITO IN (" + cContas + ") "
		cQuery += "AND CT2.D_E_L_E_T_ 	= ' ' "
		
		cQuery += "WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
								
		if nY == 13 //Data de ocorrência. Para a ultima linha, serão considerados inclusive todos os itens anteriores da base.
			cQuery	+= "AND BD7.BD7_DATPRO <= '" + cMesOcorr + "31' "	
		else
			cQuery	+= "AND BD7.BD7_DATPRO BETWEEN '" + cMesOcorr + "01' AND '" + cMesOcorr + "31' "	
		endif		
				
		cQuery	+= "AND BD7.BD7_FASE IN ('3','4') "
		cQuery	+= "AND BD7.D_E_L_E_T_ 	= ' ' "
		
		cQuery	:= ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPMOVPESL",.T.,.F.)
					
		if !TMPMOVPESL->(EoF())
			//Se tiver registro, adiciona no aDadosTemp o codigo correspondente somado com 33 que é o início desse quadro.
			//Ao final do for, será 13 + 47 = 60 que é o último item do quadro.
			aadd(aDadosTemp, {nY + 47, TMPMOVPESL->VALOR})
		else
			//Se não tiver registro, adiciona linha em branco
			aadd(aDadosTemp, {nY + 47, 0}) 
		endif
		
		TMPMOVPESL->(dbCloseArea())
	next nY
	
	//Adiciona no aDados os registros obtidos no 4º quadro
	aadd(aDados[nI], aDadosTemp)
	aDadosTemp := {}
	
	//------------------- FIM 4º quadro ----------------
	
	//----------------- Início 5º quadro ---------------
	// Codigos 61, 62, 63 e 64
	//--------------------------------------------------
	
	//-------------------- Codigo 61 -------------------------	
	nVal61 := SaldoConta('411112',STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31"),"01","1",1,1)
	
	//Adiciona no array principal os valores para o código 61, primeiro quadro
	aadd(aDados[nI], {{61,nVal61}})
	//--------------------------------------------------------
			
	//-------------------- Codigo 62 -------------------------
	aContas := {}
	nVal := 0
	
	aadd(aContas,"21111903")
	aadd(aContas,"21112903")
	aadd(aContas,"23111903")
	aadd(aContas,"23112903")
			
	//Percorre todos os itens das contas e utiliza função do contábil para retornar os dados
	for nX := 1 to len(aContas)
		nVal += SaldoConta(aContas[nX],STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31"),"01","1",1,1)
	next nX
	
	//Adiciona no array principal os valores para o código 62, primeiro quadro
	aadd(aDados[nI], {{62,nVal}})
	
	//--------------------------------------------------------
	
	//-------------------- Codigo 63 -------------------------
	//Percorre todos os valores de todas as contas no mês com as contas já existentes antes, tira o valor do 61
	aContas := {}
	nVal := 0	
		
	cCtas :="'411111011'/'411111021'/'411111031'/'411111041'/'411111051'/'411111061'/'411111017'/'411111027'/'411111037'/'411111047'/'411111057'/'411111067'/'411111081'/'411121011'/'411121021'/'411121031'/'411121041'/'411121051'/"
	cCtas +="'411121061'/'411121017'/'411121027'/'411121037'/'411121047'/'411121057'/'411121067'/'411121081'/'411211011'/'411211021'/'411211031'/'411211041'/'411211051'/'411211061'/'411211081'/'411221011'/'411221021'/'411221031'/"
	cCtas +="'411221041'/'411221051'/'411221061'/'411221081'/'411311011'/'411311021'/'411311031'/'411311041'/'411311051'/'411311061'/'411311081'/'411321011'/'411321021'/'411321031'/'411321041'/'411321051'/'411321061'/'411321081'/"
	cCtas +="'411411011'/'411411021'/'411411031'/'411411041'/'411411051'/'411411061'/'411411017'/'411411027'/'411411037'/'411411047'/'411411057'/'411411067'/'411411081'/'411421011'/'411421021'/'411421031'/'411421041'/'411421051'/"
	cCtas +="'411421061'/'411421017'/'411421027'/'411421037'/'411421047'/'411421057'/'411421067'/'411421081'/'411511011'/'411511021'/'411511031'/'411511041'/'411511051'/'411511061'/'411511081'/'411521011'/'411521021'/'411521031'/"
	cCtas +="'411521041'/'411521051'/'411521061'/'411521081'/'411711011'/'411711021'/'411711031'/'411711041'/'411711051'/'411711061'/'411711017'/'411711027'/'411711037'/'411711047'/'411711057'/'411711067'/'411721011'/'411721021'/"
	cCtas +="'411721031'/'411721041'/'411721051'/'411721061'/'411721017'/'411721027'/'411721037'/'411721047'/'411721057'/'411721067'/'411911011'/'411911021'/'411911031'/'411911041'/'411911051'/'411911061'/'411911017'/'411911027'/"
	cCtas +="'411911037'/'411911047'/'411911057'/'411911067'/'411911081'/'411921011'/'411921021'/'411921031'/'411921041'/'411921051'/'411921061'/'411921017'/'411921027'/'411921037'/'411921047'/'411921057'/'411921067'/'411921081'" 
	
	aContas:=StrTokArr(cCtas, "'/'")
			
	//Percorre todos os itens das contas e utiliza função do contábil para retornar os dados
	for nX := 1 to len(aContas)
		nVal += SaldoConta(aContas[nX],STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31"),"01","1",1,1)
	next nX		
	
	//Adiciona no array principal os valores para o código 63, primeiro quadro
	aadd(aDados[nI], {{63,nVal-nVal61}})
	
	//--------------------------------------------------------
	
	//-------------------- Codigo 64 -------------------------
	//Percorre todos os valores de todas as contas no mês com as contas já existentes antes, tira o valor do 61
	aContas := {}
	nVal := 0		
	cCtas :="'411111012'/'411111022'/'411111032'/'411111042'/'411111052'/'411111062'/'411111082'/'411121012'/'411121022'/'411121032'/'411121042'/'411121052'/'411121062'/'411121082'/'411211012'/"
	cCtas +="'411211022'/'411211032'/'411211042'/'411211052'/'411211062'/'411211082'/'411221012'/'411221022'/'411221032'/'411221042'/'411221052'/'411221062'/'411221082'/'411311012'/'411311022'/"
	cCtas +="'411311032'/'411311042'/'411311052'/'411311062'/'411311082'/'411321012'/'411321022'/'411321032'/'411321042'/'411321052'/'411321062'/'411321082'/'411411012'/'411411022'/'411411032'/"
	cCtas +="'411411042'/'411411052'/'411411062'/'411411082'/'411421012'/'411421022'/'411421032'/'411421042'/'411421052'/'411421062'/'411421082'/'411511012'/'411511022'/'411511032'/'411511042'/"
	cCtas +="'411511052'/'411511062'/'411511082'/'411521012'/'411521022'/'411521032'/'411521042'/'411521052'/'411521062'/'411521082'/'411711012'/'411711022'/'411711032'/'411711042'/'411711052'/"
	cCtas +="'411711062'/'411721012'/'411721022'/'411721032'/'411721042'/'411721052'/'411721062'/'411911012'/'411911022'/'411911032'/'411911042'/'411911052'/'411911062'/'411911082'/'411921012'/"
	cCtas +="'411921022'/'411921032'/'411921042'/'411921052'/'411921062'/'411921082'"
	
	aContas:=StrTokArr(cCtas, "'/'")
			
	//Percorre todos os itens das contas e utiliza função do contábil para retornar os dados
	for nX := 1 to len(aContas)
		nVal += SaldoConta(aContas[nX],STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31"),"01","1",1,1)
	next nX		
	
	//Adiciona no array principal os valores para o código 64, primeiro quadro
	aadd(aDados[nI], {{64,nVal-nVal61}})
	
	//--------------------------------------------------------
	
	//------------------- FIM 5º quadro ----------------
					
	//----------------- Início 6º quadro -------------------------
	// Códigos 65 a 78 - Total de recuperações reconhecidas no mês
	//------------------------------------------------------------		
	//Lista contas a serem buscadas
	//TODO: Desenvolver forma de customizar as contas
	cContas :="'411111013','411111023','411111033','411111043','411111053','411111063','411111019','411111029','411111039','411111049','411111059','411111069','411121013','411121023','411121033',"
	cContas +="'411121043','411121053','411121063','411121019','411121029','411121039','411121049','411121059','411121069','411211013','411211023','411211033','411211043','411211053','411211063',"
	cContas +="'411211019','411211029','411211039','411211049','411211059','411211069','411221013','411221023','411221033','411221043','411221053','411221063','411221019','411221029','411221039',"
	cContas +="'411221049','411221059','411221069','411311013','411311023','411311033','411311043','411311053','411311063','411311019','411311029','411311039','411311049','411311059','411311069',"
	cContas +="'411321013','411321023','411321033','411321043','411321053','411321063','411321019','411321029','411321039','411321049','411321059','411321069','411411013','411411023','411411033',"
	cContas +="'411411043','411411053','411411063','411411019','411411029','411411039','411411049','411411059','411411069','411421013','411421023','411421033','411421043','411421053','411421063',"
	cContas +="'411421019','411421029','411421039','411421049','411421059','411421069','411511013','411511023','411511033','411511043','411511053','411511063','411511019','411511029','411511039',"
	cContas +="'411511049','411511059','411511069','411521013','411521023','411521033','411521043','411521053','411521063','411521019','411521029','411521039','411521049','411521059','411521069',"
	cContas +="'411711013','411711023','411711033','411711043','411711053','411711063','411711019','411711029','411711039','411711049','411711059','411711069','411721013','411721023','411721033',"
	cContas +="'411721043','411721053','411721063','411721019','411721029','411721039','411721049','411721059','411721069','411911013','411911023','411911033','411911043','411911053','411911063',"
	cContas +="'411911019','411911029','411911039','411911049','411911059','411911069','411921013','411921023','411921033','411921043','411921053','411921063','411921019','411921029','411921039',"
	cContas +="'411921049','411921059','411921069'"

	cMesAnt 	:= ""
	cAnoAnt 	:= ""
	cMesOcorr 	:= ""	
	//Fazer a query repetidas vezes para n igual 1 até que n seja igual a 13
	for nY := 0 to 13
		//Cálculo para obter mês e ano corretos			
		if nY > 0
			//Se for da segunda linha em diante
			if cMesAnt == "01"
				//Mes anterior igual a janeiro, diminuo um numero do ano e defino o mês como dezembro (último mês do ano anterior)
				cMesOcorr := AllTrim(STR(Val(cAnoAnt)-1)) + "12"
				cMesAnt := "12"
				cAnoAnt := AllTrim(STR(Val(cAnoAnt)-1))
			else
				//Subtrai um mês para obter os valores da query
				cMesOcorr := cAnoAnt + AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
				cMesAnt := AllTrim(STRZERO(Val(cMesAnt)-1,2,0))
			endif
		else
			//Primeira linha do quadro, utiliza os dados de ano e mês atuais
			cMesAnt := aMesesTrim[nI][2]
			cAnoAnt := aMesesTrim[nI][1]
			cMesOcorr := aMesesTrim[nI][1]+aMesesTrim[nI][2]
		endif
		
		//Buscar a query, agrupar por ano, mês, where feito com base no aMesesTrim[nI][1] <-- ano e aMesesTrim[nI][2] <-- mes	
					
		cQuery	:= "SELECT BD7_VLRGLO AS VALOR " 
		cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "		
		
		// Rastreamento Contábil
		cQuery	+= "INNER JOIN "+RetSqlName("CV3")+" CV3 "
		cQuery	+= "ON CV3_FILIAL	= '" + xFilial("CV3") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_  "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ "
		EndIf
		cQuery	+= "AND CV3_TABORI		= 'BD7' "
		cQuery	+= "AND CV3.D_E_L_E_T_	= '' "
		
		// Lançamentos Contábeis
		cQuery	+= "INNER JOIN "+RetSqlName("CT2")+" CT2 "
		cQuery	+= "ON CT2_FILIAL	= '" + xFilial("CT2") + "' "
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
			cQuery	+= "AND NVL(CAST(CV3_RECDES as int),0)= CT2.R_E_C_N_O_ "
		Else
			cQuery	+= "AND CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_ "
		EndIf
		cQuery += "AND CT2.CT2_DATA BETWEEN '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"01' AND '"+aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31' "
		cQuery += "AND CT2.CT2_CREDIT IN (" + cContas + ") " //Contas crédito
		cQuery	+= "AND CT2.D_E_L_E_T_	= '' "
		
		//------------------ Where ----------------------
		cQuery	+= "WHERE BD7_FILIAL	= '" + xFilial("BD7") + "' "		
					
		if nY == 13 //Data de ocorrência do evento. Para a ultima linha, serão considerados inclusive todos os itens anteriores da base.
			cQuery	+= "AND BD7.BD7_DATPRO <= '" + cMesOcorr + "31' "	
		else
			cQuery	+= "AND BD7.BD7_DATPRO BETWEEN '" + cMesOcorr + "01' AND '" + cMesOcorr + "31' "	
		endif		
					
		cQuery += "AND BD7.BD7_FASE IN ('3','4') " 
		cQuery	+= "AND BD7.D_E_L_E_T_	= '' "
			
		cQuery	:= ChangeQuery(cQuery)
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPMOVPESL",.T.,.F.)
					
		if !TMPMOVPESL->(EoF())
			//Se tiver registro, adiciona no aDadosTemp o codigo correspondente somado com 33 que é o início desse quadro.
			//Ao final do for, será 13 + 65 = 78 que é o último item do quadro.
			aadd(aDadosTemp, {nY + 65, TMPMOVPESL->VALOR})
		else
			//Se não tiver registro, adiciona linha em branco
			aadd(aDadosTemp, {nY + 65, 0}) 
		endif
		
		TMPMOVPESL->(dbCloseArea())
	next nY
	
	//Adiciona no aDados os registros obtidos no 6º quadro
	aadd(aDados[nI], aDadosTemp)
	aDadosTemp := {}
	
	//------------------- FIM 6º quadro ----------------
	
	//----------------- Início 7º quadro ---------------
	// Código 79 - PEONA
	//--------------------------------------------------
	aContas := {}
	aadd(aContas,"211111041")
	aadd(aContas,"211121041")
	aadd(aContas,"231111041")
	aadd(aContas,"231121041")
	
	nVal := 0
	
	//Percorre todos os itens das contas e utiliza função do contábil para retornar os dados
	for nX := 1 to len(aContas)
		nVal += SaldoConta(aContas[nX],STOD(aMesesTrim[nI][1]+aMesesTrim[nI][2]+"31"),"01","1",1,1)
	next nX
	
	//Adiciona no array principal os valores para o código 79, primeiro quadro
	//aMesesTrim[nI][1] = Ano
	//aMesesTrim[nI][2] = Mês
	aadd(aDados[nI], {{79,nVal}})
	
	//------------------- FIM 7º quadro ----------------
	//Incrementa a régua
	IncProc()
		
Next nI //Proximo mês	


If !lDadosCSV

	//Monta aDados de acordo com padrão esperado na central de obrigações do Protheus. 
	// Primeira posição confirma se processou corretamente
	// Envia na segunda posição os dados de cada linha 
	/* 
	- Exemplo:
	aAdd( aDadosRet, { {'33',3000,2000,1000}, {'34',3000,2000,1000}, {'35',3000,2000,1000}, {'36',3000,2000,1000}, {'37',3000,2000,1000}, {'38',3000,2000,1000}, {'39',3000,2000,1000},; // 33 a 46 - Novos Avisos de Eventos
					{'40',3000,2000,1000}, {'41',3000,2000,1000}, {'42',3000,2000,1000}, {'43',3000,2000,1000}, {'44',3000,2000,1000}, {'45',3000,2000,1000}, {'46',3000,2000,1000},;				
					{'47',3000,2000,1000}, {'48',3000,2000,1000}, {'49',3000,2000,1000}, {'50',3000,2000,1000}, {'51',3000,2000,1000}, {'52',3000,2000,1000}, {'53',3000,2000,1000},; // 47 a 60 - Glosas
					{'54',3000,2000,1000}, {'55',3000,2000,1000}, {'56',3000,2000,1000}, {'57',3000,2000,1000}, {'58',3000,2000,1000}, {'59',3000,2000,1000}, {'60',3000,2000,1000},;
					{'65',3000,2000,1000}, {'66',3000,2000,1000}, {'67',3000,2000,1000}, {'68',3000,2000,1000}, {'69',3000,2000,1000}, {'70',3000,2000,1000}, {'71',3000,2000,1000},; // 65 a 78 - Outras Recuperações 
					{'72',3000,2000,1000}, {'73',3000,2000,1000}, {'74',3000,2000,1000}, {'75',3000,2000,1000}, {'76',3000,2000,1000}, {'77',3000,2000,1000}, {'78',3000,2000,1000},;
					{'79',3000,2000,1000} }	)	// 79 - PEONA				
	*/

	For nI := 1 to Len(aDados)
		
		For nX := 1 to Len(aDados[nI])
			
			For nY := 1 to Len(aDados[nI,nX])

				If Len(aDadosRet) > 0 .and. aDados[nI,nX,nY][1] > 0		
					nZ := aScan(aDadosRet,{|x| x[1] == StrZero(aDados[nI,nX,nY][1],2) })
					If nZ == 0 
						aAdd(aDadosRet, { StrZero(aDados[nI,nX,nY][1],2) , IIf(nI==3, aDados[nI,nX,nY][2], 0),IIf(nI==2, aDados[nI,nX,nY][2], 0), IIf(nI==1, aDados[nI,nX,nY][2], 0) } )
					Else
						aDadosRet[nZ][ IIf(nI==1, 4, IIf(nI==2, 3, 2 ) ) ] += aDados[nI,nX,nY][2]		
					EndIf

				ElseIf aDados[nI,nX,nY][1] > 0
					aAdd(aDadosRet, { StrZero(aDados[nI,nX,nY][1],2) , IIf(nI==3, aDados[nI,nX,nY][2], 0),IIf(nI==2, aDados[nI,nX,nY][2], 0), IIf(nI==1, aDados[nI,nX,nY][2], 0) } )

				EndIf  
			
			Next
			
		Next
		
	Next
	// Retorna dados formatados para a Central
	Return( { (Len(aDadosRet)>0), aDadosRet } )

EndIf

// Retorna dados formatados para o relatório
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDMOVPCSV
Função responsável por gerar o CSV a partir dos dados obtidos na função 

@author  Rodrigo Morgon
@version P12
@since   03/02/2017
@param   aDados, array, dados considerados para gerar o CSV

@return  nil, resultado da função é o .CSV gerado na pasta do server.
/*/
//-------------------------------------------------------------------
static function PLDMOVPCSV(aDados, aMesesTrim)

	local nLenMeses := 0
	local cMesesHead := ""
	local nI := 1
	
	cDirCsv := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
	nFileCsv := FCreate(cDirCsv+"DIOPS_Movimentacao_PESL.csv",0,,.F.)
	
	//Formato
	//aDados[nMes][nQuadro]
	//		nQuadro == 1: Saldo inicial do mês 													(linha)
	//		nQuadro == 2: Total pago no mês 														(array)
	//		nQuadro == 3: Total dos novos avisos reconhecidos no mês							(array)
	//		nQuadro == 4: Baixa de evento por glosa referentes a eventos ocorridos no mês  	(array)
	//		nQuadro == 5: Saldo final da PSL relacionados a contratos em pós-pagamento (+)	(linha)
	//		nQuadro == 6: Saldo final da PSL														(linha)
	//		nQuadro == 7: Total dos eventos ocorridos, avisados e pagos dentro do mês e... 	(linha)
	//		nQuadro == 8: Total das glosas reconhecidas no mês que não tenham transitado...	(linha)
	//		nQuadro == 9:	Outras recuperações referentes a eventos ocorridos no mês			(array)
	//		nQuadro == 10: PEONA																		(linha)
	
	
	//Cria arquivo CSV
	If nFileCsv > 0
		//Monta título
		FWrite(nFileCSV,"Movimentação da Provisão de Eventos/Sinistros a Liquidar"+CRLF)
		
		nLenMeses := len(aMesesTrim)
		
		for nI := 1 to nLenMeses
			cMesesHead += aMesesTrim[nI][2] + "/" + aMesesTrim[nI][1] + ";"
		next nI
		
		//No cabeçalho, irá incluir os meses referenciados no relatório
		FWrite(nFileCSV,"Código;Descrição;" + cMesesHead + CRLF) //Pegar meses para iterar
		
		//Para montar as linhas do relatório, altero a ordem do array para escrever cada linha.
		FWrite(nFileCSV,"0;Saldo Início do mês;" + RetValPESL(aDados,nLenMeses,1,1) + CRLF)
		FWrite(nFileCSV,"29;Total de eventos pagos no mês para os eventos avisados no mês;" + RetValPESL(aDados,nLenMeses,2,1) + CRLF)
		FWrite(nFileCSV,"30;Total de eventos pagos no mês para os eventos avisados no mês n-1;" + RetValPESL(aDados,nLenMeses,2,2) + CRLF)
		FWrite(nFileCSV,"31;Total de eventos pagos no mês para os eventos avisados no mês n-2;" + RetValPESL(aDados,nLenMeses,2,3) + CRLF)
		FWrite(nFileCSV,"32;Total de eventos pagos no mês para os eventos avisados no mês n-3 e anteriores a essa data;" + RetValPESL(aDados,nLenMeses,2,4) + CRLF)		
		FWrite(nFileCSV,"33;Novos avisos referentes a eventos ocorridos no mês;" + RetValPESL(aDados,nLenMeses,3,1) + CRLF)
		FWrite(nFileCSV,"34;Novos avisos referentes a eventos ocorridos no mês n-1;" + RetValPESL(aDados,nLenMeses,3,2) + CRLF)
		FWrite(nFileCSV,"35;Novos avisos referentes a eventos ocorridos no mês n-2;" + RetValPESL(aDados,nLenMeses,3,3) + CRLF)
		FWrite(nFileCSV,"36;Novos avisos referentes a eventos ocorridos no mês n-3;" + RetValPESL(aDados,nLenMeses,3,4) + CRLF)
		FWrite(nFileCSV,"37;Novos avisos referentes a eventos ocorridos no mês n-4;" + RetValPESL(aDados,nLenMeses,3,5) + CRLF)
		FWrite(nFileCSV,"38;Novos avisos referentes a eventos ocorridos no mês n-5;" + RetValPESL(aDados,nLenMeses,3,6) + CRLF)
		FWrite(nFileCSV,"39;Novos avisos referentes a eventos ocorridos no mês n-6;" + RetValPESL(aDados,nLenMeses,3,7) + CRLF)
		FWrite(nFileCSV,"40;Novos avisos referentes a eventos ocorridos no mês n-7;" + RetValPESL(aDados,nLenMeses,3,8) + CRLF)
		FWrite(nFileCSV,"41;Novos avisos referentes a eventos ocorridos no mês n-8;" + RetValPESL(aDados,nLenMeses,3,9) + CRLF)
		FWrite(nFileCSV,"42;Novos avisos referentes a eventos ocorridos no mês n-9;" + RetValPESL(aDados,nLenMeses,3,10) + CRLF)
		FWrite(nFileCSV,"43;Novos avisos referentes a eventos ocorridos no mês n-10;" + RetValPESL(aDados,nLenMeses,3,11) + CRLF)
		FWrite(nFileCSV,"44;Novos avisos referentes a eventos ocorridos no mês n-11;" + RetValPESL(aDados,nLenMeses,3,12) + CRLF)
		FWrite(nFileCSV,"45;Novos avisos referentes a eventos ocorridos no mês n-12;" + RetValPESL(aDados,nLenMeses,3,13) + CRLF)
		FWrite(nFileCSV,"46;Novos avisos referentes a eventos ocorridos no mês n-13 e anteriores a essa data;" + RetValPESL(aDados,nLenMeses,3,14) + CRLF)
		FWrite(nFileCSV,"47;Baixa de evento por glosa referentes a eventos ocorridos no mês;" + RetValPESL(aDados,nLenMeses,4,1) + CRLF)
		FWrite(nFileCSV,"48;Baixa de evento por glosa referentes a eventos ocorridos no mês n-1;" + RetValPESL(aDados,nLenMeses,4,2) + CRLF)
		FWrite(nFileCSV,"49;Baixa de evento por glosa referentes a eventos ocorridos no mês n-2;" + RetValPESL(aDados,nLenMeses,4,3) + CRLF)
		FWrite(nFileCSV,"50;Baixa de evento por glosa referentes a eventos ocorridos no mês n-3;" + RetValPESL(aDados,nLenMeses,4,4) + CRLF)
		FWrite(nFileCSV,"51;Baixa de evento por glosa referentes a eventos ocorridos no mês n-4;" + RetValPESL(aDados,nLenMeses,4,5) + CRLF)
		FWrite(nFileCSV,"52;Baixa de evento por glosa referentes a eventos ocorridos no mês n-5;" + RetValPESL(aDados,nLenMeses,4,6) + CRLF)
		FWrite(nFileCSV,"53;Baixa de evento por glosa referentes a eventos ocorridos no mês n-6;" + RetValPESL(aDados,nLenMeses,4,7) + CRLF)
		FWrite(nFileCSV,"54;Baixa de evento por glosa referentes a eventos ocorridos no mês n-7;" + RetValPESL(aDados,nLenMeses,4,8) + CRLF)
		FWrite(nFileCSV,"55;Baixa de evento por glosa referentes a eventos ocorridos no mês n-8;" + RetValPESL(aDados,nLenMeses,4,9) + CRLF)
		FWrite(nFileCSV,"56;Baixa de evento por glosa referentes a eventos ocorridos no mês n-9;" + RetValPESL(aDados,nLenMeses,4,10) + CRLF)
		FWrite(nFileCSV,"57;Baixa de evento por glosa referentes a eventos ocorridos no mês n-10;" + RetValPESL(aDados,nLenMeses,4,11) + CRLF)
		FWrite(nFileCSV,"58;Baixa de evento por glosa referentes a eventos ocorridos no mês n-11;" + RetValPESL(aDados,nLenMeses,4,12) + CRLF)
		FWrite(nFileCSV,"59;Baixa de evento por glosa referentes a eventos ocorridos no mês n-12;" + RetValPESL(aDados,nLenMeses,4,13) + CRLF)
		FWrite(nFileCSV,"60;Baixa de evento por glosa referentes a eventos ocorridos no mês n-13 e anteriores a essa data;" + RetValPESL(aDados,nLenMeses,4,14) + CRLF)
		FWrite(nFileCSV,"61;Saldo final da PSL relacionados a contratos em pós-pagamento (+);" + RetValPESL(aDados,nLenMeses,5,1) + CRLF)
		FWrite(nFileCSV,"62;Saldo final da PSL;" + RetValPESL(aDados,nLenMeses,6,1) + CRLF)
		FWrite(nFileCSV,"63;Total dos eventos ocorridos, avisados e pagos dentro do mês e que não tenham transitado pela Provisão de Sinistros a Liquidar;" + RetValPESL(aDados,nLenMeses,7,1) + CRLF)
		FWrite(nFileCSV,"64;Total das glosas reconhecidas no mês que não tenham transitado pela Provisão de Sinistros a Liquidar;" + RetValPESL(aDados,nLenMeses,8,1) + CRLF)
		FWrite(nFileCSV,"65;Outras recuperações referentes a eventos ocorridos no mês;" + RetValPESL(aDados,nLenMeses,9,1) + CRLF)
		FWrite(nFileCSV,"66;Outras recuperações referentes a eventos ocorridos no mês n-1;" + RetValPESL(aDados,nLenMeses,9,2) + CRLF)
		FWrite(nFileCSV,"67;Outras recuperações referentes a eventos ocorridos no mês n-2;" + RetValPESL(aDados,nLenMeses,9,3) + CRLF)
		FWrite(nFileCSV,"68;Outras recuperações referentes a eventos ocorridos no mês n-3;" + RetValPESL(aDados,nLenMeses,9,4) + CRLF)
		FWrite(nFileCSV,"69;Outras recuperações referentes a eventos ocorridos no mês n-4;" + RetValPESL(aDados,nLenMeses,9,5) + CRLF)
		FWrite(nFileCSV,"70;Outras recuperações referentes a eventos ocorridos no mês n-5;" + RetValPESL(aDados,nLenMeses,9,6) + CRLF)
		FWrite(nFileCSV,"71;Outras recuperações referentes a eventos ocorridos no mês n-6;" + RetValPESL(aDados,nLenMeses,9,7) + CRLF)
		FWrite(nFileCSV,"72;Outras recuperações referentes a eventos ocorridos no mês n-7;" + RetValPESL(aDados,nLenMeses,9,8) + CRLF)
		FWrite(nFileCSV,"73;Outras recuperações referentes a eventos ocorridos no mês n-8;" + RetValPESL(aDados,nLenMeses,9,9) + CRLF)
		FWrite(nFileCSV,"74;Outras recuperações referentes a eventos ocorridos no mês n-9;" + RetValPESL(aDados,nLenMeses,9,10) + CRLF)
		FWrite(nFileCSV,"75;Outras recuperações referentes a eventos ocorridos no mês n-10;" + RetValPESL(aDados,nLenMeses,9,11) + CRLF)
		FWrite(nFileCSV,"76;Outras recuperações referentes a eventos ocorridos no mês n-11;" + RetValPESL(aDados,nLenMeses,9,12) + CRLF)
		FWrite(nFileCSV,"77;Outras recuperações referentes a eventos ocorridos no mês n-12;" + RetValPESL(aDados,nLenMeses,9,13) + CRLF)
		FWrite(nFileCSV,"78;Outras recuperações referentes a eventos ocorridos no mês n-13 e anteriores a essa data;" + RetValPESL(aDados,nLenMeses,9,14) + CRLF)
		FWrite(nFileCSV,"79;PEONA;" + RetValPESL(aDados,nLenMeses,10,1) + CRLF)
				
		FClose(nFileCSV)
		
		MsgInfo("Arquivo gerado com sucesso: " + cDirCsv + "DIOPS_Movimentacao_PESL.csv","TOTVS")
	Else
		MsgAlert("Não foi possível criar o arquivo " + cDirCsv + "DIOPS_Movimentacao_PESL","TOTVS")
	EndIf
return


//-------------------------------------------------------------------
/*/{Protheus.doc} CalcTrimes
Calcula os meses e anos de cada trimestre informado na busca

@author  Rodrigo Morgon
@version P12
@since   08/02/2017

@return  aMesesTrim, array de meses e anos baseado no trimestre
/*/
//-------------------------------------------------------------------
Static Function CalcTriMes(cTrimestre, cAno)
Local aMesesTrim := {}

Default cTrimestre	:= MV_PAR01
Default cAno		:= MV_PAR02

If cTrimestre == "1"
		aadd(aMesesTrim, {cAno,"01"}) //Jan
		aadd(aMesesTrim, {cAno,"02"}) //Fev
		aadd(aMesesTrim, {cAno,"03"}) //Mar
ElseIf cTrimestre == "2"
		aadd(aMesesTrim, {cAno,"04"}) //Abr
		aadd(aMesesTrim, {cAno,"05"}) //Mai
		aadd(aMesesTrim, {cAno,"06"}) //Jun
ElseIf cTrimestre == "3"
		aadd(aMesesTrim, {cAno,"07"}) //Jul
		aadd(aMesesTrim, {cAno,"08"}) //Ago
		aadd(aMesesTrim, {cAno,"09"}) //Set
Else		
		aadd(aMesesTrim, {cAno,"10"}) //Out
		aadd(aMesesTrim, {cAno,"11"}) //Nov
		aadd(aMesesTrim, {cAno,"12"}) //Dez
EndIf

Return(aMesesTrim)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValPESL
Retorna os dados de cada linha dos quadros de acordo com a linha solicitada.

@author  Rodrigo Morgon
@version P12
@since   08/02/2017

@return  cRetValPESL, valor da linha com todas as colunas de todos os meses solicitados
/*/
//-------------------------------------------------------------------
static function RetValPESL(aDados,nLenMeses,nQuadro,nLinha)

local cRetValPESL := ""
local nX := 0

default aDados := {}
default nLenMeses := 0
default nQuadro := 1
default nLinha := 1

//		nQuadro == 1: Saldo inicial do mês 													(linha / array de 1)
//		nQuadro == 2: Total pago no mês 														(array)
//		nQuadro == 3: Total dos novos avisos reconhecidos no mês							(array)
//		nQuadro == 4: Baixa de evento por glosa referentes a eventos ocorridos no mês  	(array)
//		nQuadro == 5: Saldo final da PSL relacionados a contratos em pós-pagamento (+)	(linha / array de 1)
//		nQuadro == 6: Saldo final da PSL														(linha / array de 1)
//		nQuadro == 7: Total dos eventos ocorridos, avisados e pagos dentro do mês e... 	(linha / array de 1)
//		nQuadro == 8: Total das glosas reconhecidas no mês que não tenham transitado...	(linha / array de 1)
//		nQuadro == 9:	Outras recuperações referentes a eventos ocorridos no mês			(array)
//		nQuadro == 10: PEONA																		(linha / array de 1)

if !empty(aDados) .and. nLenMeses > 0
	for nX := 1 to nLenMeses
		//Percorre todos os registros de todos os meses e adiciona na string para retorno
		cRetValPESL += AllTrim(Str(aDados[nX][nQuadro][nLinha][2])) + ";"
	next nX
endif

Return cRetValPESL



//-------------------------------------------------------------------
/*/{Protheus.doc} PLDMOVPD2
Dados da DIOPS da movimentação de PESL

@author  Roger C
@version P12
@since   20/11/2018
@param   Trimestre e Ano para cálculo

@return  aDados formatada para Central de Obrigações
/*/
//-------------------------------------------------------------------
Function PLDMOVPD2(cTrimestre, cAno)
Local cQuery		:= ""
Local cSql			:= ""
Local aContas		:= {}
Local aDados 		:= {}
Local aDadosRet		:= {}
Local nVez 			:= 0
Local nX			:= 0
Local nVal			:= 0
Local aDadosTemp	:= {}
Local dDtFim		:= nil
Local nValTotal		:= 0
Local aMesesTrim	:= {}
Local aMeses1		:= {}
Local aMeses2		:= {}
Local aMeses3		:= {}
Local nPosK			:= 0
Local nPosM			:= 0
Local nPosZ			:= 0
Local nPosF			:= 0

Default lDadosCSV	:= .T.
Default cTrimestre	:= MV_PAR01
Default cAno		:= MV_PAR02 

aAdd( aDadosRet, { {'33',0,0,0}, {'34',0,0,0}, {'35',0,0,0}, {'36',0,0,0}, {'37',0,0,0}, {'38',0,0,0}, {'39',0,0,0},; // 33 a 46 - Novos Avisos de Eventos
				{'40',0,0,0}, {'41',0,0,0}, {'42',0,0,0}, {'43',0,0,0}, {'44',0,0,0}, {'45',0,0,0}, {'46',0,0,0},;				
				{'47',0,0,0}, {'48',0,0,0}, {'49',0,0,0}, {'50',0,0,0}, {'51',0,0,0}, {'52',0,0,0}, {'53',0,0,0},; // 47 a 60 - Glosas
				{'54',0,0,0}, {'55',0,0,0}, {'56',0,0,0}, {'57',0,0,0}, {'58',0,0,0}, {'59',0,0,0}, {'60',0,0,0},;
				{'65',0,0,0}, {'66',0,0,0}, {'67',0,0,0}, {'68',0,0,0}, {'69',0,0,0}, {'70',0,0,0}, {'71',0,0,0},; // 65 a 78 - Outras Recuperações 
				{'72',0,0,0}, {'73',0,0,0}, {'74',0,0,0}, {'75',0,0,0}, {'76',0,0,0}, {'77',0,0,0}, {'78',0,0,0},;
				{'79',0,0,0}})
				
aMesesTrim 	:= CalcTriM2(cTrimestre, cAno)

//Monta régua dos meses
ProcRegua(Len(aMesesTrim)) 

//Avisos reconhecidos
dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(retQry02())),"TMPMOV1",.f.,.t.)

While !TMPMOV1->(EoF())

	nPosK := ascan(aDadosRet[1], {|x| x[1] == TMPMOV1->CODMOV } )

	If TMPMOV1->MESTRI == '3'
		aDadosRet[1][nPosK][2] += TMPMOV1->TOTVAL
	elseif TMPMOV1->MESTRI == '2'
		aDadosRet[1][nPosK][3] += TMPMOV1->TOTVAL
	elseif TMPMOV1->MESTRI == '1'
		aDadosRet[1][nPosK][4] += TMPMOV1->TOTVAL
	endIf

	TMPMOV1->(dbSkip())

EndDo

TMPMOV1->(dbCloseArea())
IncProc()

//Recuperação por glosa
dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(retQry02(2))),"TMPMOV2",.f.,.t.)

While !TMPMOV2->(EoF())

	nPosM := ascan(aDadosRet[1], {|x| x[1] == TMPMOV2->CODMOV } )

	If TMPMOV2->MESTRI == '3'
		aDadosRet[1][nPosM][2] += TMPMOV2->TOTVAL
	elseif TMPMOV2->MESTRI == '2'
		aDadosRet[1][nPosM][3] += TMPMOV2->TOTVAL
	elseif TMPMOV2->MESTRI == '1'
		aDadosRet[1][nPosM][4] += TMPMOV2->TOTVAL
	endIf

	TMPMOV2->(dbSkip())

EndDo

TMPMOV2->(dbCloseArea())
IncProc()

//demais recuperações
dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(retQry02(3))),"TMPMOV3",.f.,.t.)

While !TMPMOV3->(EoF())

	nPosZ := ascan(aDadosRet[1], {|x| x[1] == TMPMOV3->CODMOV } )

	If TMPMOV3->MESTRI == '3'
		aDadosRet[1][nPosZ][2] += TMPMOV3->TOTVAL
	elseif TMPMOV3->MESTRI == '2'
		aDadosRet[1][nPosZ][3] += TMPMOV3->TOTVAL
	elseif TMPMOV3->MESTRI == '1'
		aDadosRet[1][nPosZ][4] += TMPMOV3->TOTVAL
	endIf

	TMPMOV3->(dbSkip())

EndDo

TMPMOV3->(dbCloseArea())
IncProc()

//peona
dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(retQry03())),"TMPMOVP",.f.,.t.)

While !TMPMOVP->(EoF())

	nPosF := ascan(aDadosRet[1], {|x| x[1] == '79' } )

	If TMPMOVP->MESTRI == '3'
		aDadosRet[1][nPosF][2] += TMPMOVP->TOTVAL
	elseif TMPMOVP->MESTRI == '2'
		aDadosRet[1][nPosF][3] += TMPMOVP->TOTVAL
	elseif TMPMOVP->MESTRI == '1'
		aDadosRet[1][nPosF][4] += TMPMOVP->TOTVAL
	endIf

	TMPMOVP->(dbSkip())

EndDo

TMPMOVP->(dbCloseArea())

IncProc()


//Monta aDados de acordo com padrão esperado na central de obrigações do Protheus. 
// Primeira posição confirma se processou corretamente
// Envia na segunda posição os dados de cada linha 
/* 
- Exemplo:
aAdd( aDadosRet, { {'33',3000,2000,1000}, {'34',3000,2000,1000}, {'35',3000,2000,1000}, {'36',3000,2000,1000}, {'37',3000,2000,1000}, {'38',3000,2000,1000}, {'39',3000,2000,1000},; // 33 a 46 - Novos Avisos de Eventos
				{'40',3000,2000,1000}, {'41',3000,2000,1000}, {'42',3000,2000,1000}, {'43',3000,2000,1000}, {'44',3000,2000,1000}, {'45',3000,2000,1000}, {'46',3000,2000,1000},;				
				{'47',3000,2000,1000}, {'48',3000,2000,1000}, {'49',3000,2000,1000}, {'50',3000,2000,1000}, {'51',3000,2000,1000}, {'52',3000,2000,1000}, {'53',3000,2000,1000},; // 47 a 60 - Glosas
				{'54',3000,2000,1000}, {'55',3000,2000,1000}, {'56',3000,2000,1000}, {'57',3000,2000,1000}, {'58',3000,2000,1000}, {'59',3000,2000,1000}, {'60',3000,2000,1000},;
				{'65',3000,2000,1000}, {'66',3000,2000,1000}, {'67',3000,2000,1000}, {'68',3000,2000,1000}, {'69',3000,2000,1000}, {'70',3000,2000,1000}, {'71',3000,2000,1000},; // 65 a 78 - Outras Recuperações 
				{'72',3000,2000,1000}, {'73',3000,2000,1000}, {'74',3000,2000,1000}, {'75',3000,2000,1000}, {'76',3000,2000,1000}, {'77',3000,2000,1000}, {'78',3000,2000,1000},;
				{'79',3000,2000,1000} }	)	// 79 - PEONA				
*/


// Retorna dados formatados para a Central
Return( { (Len(aDadosRet)>0), IIF(Len(aDadosRet)>0,aDadosRet[1],aDadosRet) } )



//-------------------------------------------------------------------
/*/{Protheus.doc} CalcTrim2
Calcula os meses e anos de cada trimestre informado na busca

@author  Roger C
@version P12
@since   20/11/2018

@return  aMesesTrim, array de meses e anos baseado no trimestre
/*/
//-------------------------------------------------------------------
Static Function CalcTriM2(cTrimestre, cAno)
Local aMesesTrim := {}

Default cTrimestre	:= MV_PAR01
Default cAno		:= MV_PAR02
If cTrimestre == "1"
		aadd(aMesesTrim, {cAno,"01",FirstDay(Ctod('01/01/'+cAno)),LastDay(Ctod('01/01/'+cAno))}) //Jan
		aadd(aMesesTrim, {cAno,"02",FirstDay(Ctod('01/02/'+cAno)),LastDay(Ctod('01/02/'+cAno))}) //Fev
		aadd(aMesesTrim, {cAno,"03",FirstDay(Ctod('01/03/'+cAno)),LastDay(Ctod('01/03/'+cAno))}) //Mar
ElseIf cTrimestre == "2"
		aadd(aMesesTrim, {cAno,"04",FirstDay(Ctod('01/04/'+cAno)),LastDay(Ctod('01/04/'+cAno))}) //Abr
		aadd(aMesesTrim, {cAno,"05",FirstDay(Ctod('01/05/'+cAno)),LastDay(Ctod('01/05/'+cAno))}) //Mai
		aadd(aMesesTrim, {cAno,"06",FirstDay(Ctod('01/06/'+cAno)),LastDay(Ctod('01/06/'+cAno))}) //Jun
ElseIf cTrimestre == "3"
		aadd(aMesesTrim, {cAno,"07",FirstDay(Ctod('01/07/'+cAno)),LastDay(Ctod('01/07/'+cAno))}) //Jul
		aadd(aMesesTrim, {cAno,"08",FirstDay(Ctod('01/08/'+cAno)),LastDay(Ctod('01/08/'+cAno))}) //Ago
		aadd(aMesesTrim, {cAno,"09",FirstDay(Ctod('01/09/'+cAno)),LastDay(Ctod('01/09/'+cAno))}) //Set
Else		
		aadd(aMesesTrim, {cAno,"10",FirstDay(Ctod('01/10/'+cAno)),LastDay(Ctod('01/10/'+cAno))}) //Out
		aadd(aMesesTrim, {cAno,"11",FirstDay(Ctod('01/11/'+cAno)),LastDay(Ctod('01/11/'+cAno))}) //Nov
		aadd(aMesesTrim, {cAno,"12",FirstDay(Ctod('01/12/'+cAno)),LastDay(Ctod('01/12/'+cAno))}) //Dez
EndIf

Return(aMesesTrim)


//-------------------------------------------------------------------
/*/{Protheus.doc} CalcTrim3
Calcula os meses e anos para cada mes do trimestre 

@author  Roger C
@version P12
@since   20/11/2018

@return  aMeses, array de meses e anos baseado no mes 
/*/
//-------------------------------------------------------------------
Static Function CalcTriM3(cMes, cAno)
Local aMeses := {}
Local nVez	:= 0
Local dDatAtu := Ctod('01/'+cMes+'/'+cAno)

For nVez := 1 to 14
	dDatAtu := FirstDay(dDatAtu)
	aadd(aMeses, {nVez, dDatAtu, LastDay(dDatAtu) } )
	dDatAtu	:= dDatAtu - 25
Next

Return(aMeses)

//contas de reconhecimento de despesa - crédito
static function retCTAcre()
Local cSql := ""

cSql += " CT2_CREDIT Like '411111011%' OR "
cSql += " CT2_CREDIT Like '411111021%' OR "
cSql += " CT2_CREDIT Like '411111031%' OR "
cSql += " CT2_CREDIT Like '411111041%' OR "
cSql += " CT2_CREDIT Like '411111051%' OR "
cSql += " CT2_CREDIT Like '411111061%' OR "
cSql += " CT2_CREDIT Like '411111017%' OR "
cSql += " CT2_CREDIT Like '411111027%' OR "
cSql += " CT2_CREDIT Like '411111037%' OR "
cSql += " CT2_CREDIT Like '411111047%' OR "
cSql += " CT2_CREDIT Like '411111057%' OR "
cSql += " CT2_CREDIT Like '411111067%' OR "
cSql += " CT2_CREDIT Like '411111081%' OR "
cSql += " CT2_CREDIT Like '411121011%' OR "
cSql += " CT2_CREDIT Like '411121021%' OR "
cSql += " CT2_CREDIT Like '411121031%' OR "
cSql += " CT2_CREDIT Like '411121041%' OR "
cSql += " CT2_CREDIT Like '411121051%' OR "
cSql += " CT2_CREDIT Like '411121061%' OR "
cSql += " CT2_CREDIT Like '411121017%' OR "
cSql += " CT2_CREDIT Like '411121027%' OR "
cSql += " CT2_CREDIT Like '411121037%' OR "
cSql += " CT2_CREDIT Like '411121047%' OR "
cSql += " CT2_CREDIT Like '411121057%' OR "
cSql += " CT2_CREDIT Like '411121067%' OR "
cSql += " CT2_CREDIT Like '411121081%' OR "
cSql += " CT2_CREDIT Like '411211011%' OR "
cSql += " CT2_CREDIT Like '411211021%' OR "
cSql += " CT2_CREDIT Like '411211031%' OR "
cSql += " CT2_CREDIT Like '411211041%' OR "
cSql += " CT2_CREDIT Like '411211051%' OR "
cSql += " CT2_CREDIT Like '411211061%' OR "
cSql += " CT2_CREDIT Like '411211081%' OR "
cSql += " CT2_CREDIT Like '411221011%' OR "
cSql += " CT2_CREDIT Like '411221021%' OR "
cSql += " CT2_CREDIT Like '411221031%' OR "
cSql += " CT2_CREDIT Like '411221041%' OR "
cSql += " CT2_CREDIT Like '411221051%' OR "
cSql += " CT2_CREDIT Like '411221061%' OR "
cSql += " CT2_CREDIT Like '411221081%' OR "
cSql += " CT2_CREDIT Like '411311011%' OR "
cSql += " CT2_CREDIT Like '411311021%' OR "
cSql += " CT2_CREDIT Like '411311031%' OR "
cSql += " CT2_CREDIT Like '411311041%' OR "
cSql += " CT2_CREDIT Like '411311051%' OR "
cSql += " CT2_CREDIT Like '411311061%' OR "
cSql += " CT2_CREDIT Like '411311081%' OR "
cSql += " CT2_CREDIT Like '411321011%' OR "
cSql += " CT2_CREDIT Like '411321021%' OR "
cSql += " CT2_CREDIT Like '411321031%' OR "
cSql += " CT2_CREDIT Like '411321041%' OR "
cSql += " CT2_CREDIT Like '411321051%' OR "
cSql += " CT2_CREDIT Like '411321061%' OR "
cSql += " CT2_CREDIT Like '411321081%' OR "
cSql += " CT2_CREDIT Like '411411011%' OR "
cSql += " CT2_CREDIT Like '411411021%' OR "
cSql += " CT2_CREDIT Like '411411031%' OR "
cSql += " CT2_CREDIT Like '411411041%' OR "
cSql += " CT2_CREDIT Like '411411051%' OR "
cSql += " CT2_CREDIT Like '411411061%' OR "
cSql += " CT2_CREDIT Like '411411017%' OR "
cSql += " CT2_CREDIT Like '411411027%' OR "
cSql += " CT2_CREDIT Like '411411037%' OR "
cSql += " CT2_CREDIT Like '411411047%' OR "
cSql += " CT2_CREDIT Like '411411057%' OR "
cSql += " CT2_CREDIT Like '411411067%' OR "
cSql += " CT2_CREDIT Like '411411081%' OR "
cSql += " CT2_CREDIT Like '411421011%' OR "
cSql += " CT2_CREDIT Like '411421021%' OR "
cSql += " CT2_CREDIT Like '411421031%' OR "
cSql += " CT2_CREDIT Like '411421041%' OR "
cSql += " CT2_CREDIT Like '411421051%' OR "
cSql += " CT2_CREDIT Like '411421061%' OR "
cSql += " CT2_CREDIT Like '411421017%' OR "
cSql += " CT2_CREDIT Like '411421027%' OR "
cSql += " CT2_CREDIT Like '411421037%' OR "
cSql += " CT2_CREDIT Like '411421047%' OR "
cSql += " CT2_CREDIT Like '411421057%' OR "
cSql += " CT2_CREDIT Like '411421067%' OR "
cSql += " CT2_CREDIT Like '411421081%' OR "
cSql += " CT2_CREDIT Like '411511011%' OR "
cSql += " CT2_CREDIT Like '411511021%' OR "
cSql += " CT2_CREDIT Like '411511031%' OR "
cSql += " CT2_CREDIT Like '411511041%' OR "
cSql += " CT2_CREDIT Like '411511051%' OR "
cSql += " CT2_CREDIT Like '411511061%' OR "
cSql += " CT2_CREDIT Like '411511081%' OR "
cSql += " CT2_CREDIT Like '411521011%' OR "
cSql += " CT2_CREDIT Like '411521021%' OR "
cSql += " CT2_CREDIT Like '411521031%' OR "
cSql += " CT2_CREDIT Like '411521041%' OR "
cSql += " CT2_CREDIT Like '411521051%' OR "
cSql += " CT2_CREDIT Like '411521061%' OR "
cSql += " CT2_CREDIT Like '411521081%' OR "
cSql += " CT2_CREDIT Like '411711011%' OR "
cSql += " CT2_CREDIT Like '411711021%' OR "
cSql += " CT2_CREDIT Like '411711031%' OR "
cSql += " CT2_CREDIT Like '411711041%' OR "
cSql += " CT2_CREDIT Like '411711051%' OR "
cSql += " CT2_CREDIT Like '411711061%' OR "
cSql += " CT2_CREDIT Like '411711017%' OR "
cSql += " CT2_CREDIT Like '411711027%' OR "
cSql += " CT2_CREDIT Like '411711037%' OR "
cSql += " CT2_CREDIT Like '411711047%' OR "
cSql += " CT2_CREDIT Like '411711057%' OR "
cSql += " CT2_CREDIT Like '411711067%' OR "
cSql += " CT2_CREDIT Like '411721011%' OR "
cSql += " CT2_CREDIT Like '411721021%' OR "
cSql += " CT2_CREDIT Like '411721031%' OR "
cSql += " CT2_CREDIT Like '411721041%' OR "
cSql += " CT2_CREDIT Like '411721051%' OR "
cSql += " CT2_CREDIT Like '411721061%' OR "
cSql += " CT2_CREDIT Like '411721017%' OR "
cSql += " CT2_CREDIT Like '411721027%' OR "
cSql += " CT2_CREDIT Like '411721037%' OR "
cSql += " CT2_CREDIT Like '411721047%' OR "
cSql += " CT2_CREDIT Like '411721057%' OR "
cSql += " CT2_CREDIT Like '411721067%' OR "
cSql += " CT2_CREDIT Like '411911011%' OR "
cSql += " CT2_CREDIT Like '411911021%' OR "
cSql += " CT2_CREDIT Like '411911031%' OR "
cSql += " CT2_CREDIT Like '411911041%' OR "
cSql += " CT2_CREDIT Like '411911051%' OR "
cSql += " CT2_CREDIT Like '411911061%' OR "
cSql += " CT2_CREDIT Like '411911017%' OR "
cSql += " CT2_CREDIT Like '411911027%' OR "
cSql += " CT2_CREDIT Like '411911037%' OR "
cSql += " CT2_CREDIT Like '411911047%' OR "
cSql += " CT2_CREDIT Like '411911057%' OR "
cSql += " CT2_CREDIT Like '411911067%' OR "
cSql += " CT2_CREDIT Like '411911081%' OR "
cSql += " CT2_CREDIT Like '411921011%' OR "
cSql += " CT2_CREDIT Like '411921021%' OR "
cSql += " CT2_CREDIT Like '411921031%' OR "
cSql += " CT2_CREDIT Like '411921041%' OR "
cSql += " CT2_CREDIT Like '411921051%' OR "
cSql += " CT2_CREDIT Like '411921061%' OR "
cSql += " CT2_CREDIT Like '411921017%' OR "
cSql += " CT2_CREDIT Like '411921027%' OR "
cSql += " CT2_CREDIT Like '411921037%' OR "
cSql += " CT2_CREDIT Like '411921047%' OR "
cSql += " CT2_CREDIT Like '411921057%' OR "
cSql += " CT2_CREDIT Like '411921067%' OR "
cSql += " CT2_CREDIT Like '411921081%' "

return cSql

//contas de reconhecimento de despesa - débito
static function retCTAdeb()
local cSql := ""

cSql += " CT2_DEBITO Like '411111011%' OR "
cSql += " CT2_DEBITO Like '411111021%' OR "
cSql += " CT2_DEBITO Like '411111031%' OR "
cSql += " CT2_DEBITO Like '411111041%' OR "
cSql += " CT2_DEBITO Like '411111051%' OR "
cSql += " CT2_DEBITO Like '411111061%' OR "
cSql += " CT2_DEBITO Like '411111017%' OR "
cSql += " CT2_DEBITO Like '411111027%' OR "
cSql += " CT2_DEBITO Like '411111037%' OR "
cSql += " CT2_DEBITO Like '411111047%' OR "
cSql += " CT2_DEBITO Like '411111057%' OR "
cSql += " CT2_DEBITO Like '411111067%' OR "
cSql += " CT2_DEBITO Like '411111081%' OR "
cSql += " CT2_DEBITO Like '411121011%' OR "
cSql += " CT2_DEBITO Like '411121021%' OR "
cSql += " CT2_DEBITO Like '411121031%' OR "
cSql += " CT2_DEBITO Like '411121041%' OR "
cSql += " CT2_DEBITO Like '411121051%' OR "
cSql += " CT2_DEBITO Like '411121061%' OR "
cSql += " CT2_DEBITO Like '411121017%' OR "
cSql += " CT2_DEBITO Like '411121027%' OR "
cSql += " CT2_DEBITO Like '411121037%' OR "
cSql += " CT2_DEBITO Like '411121047%' OR "
cSql += " CT2_DEBITO Like '411121057%' OR "
cSql += " CT2_DEBITO Like '411121067%' OR "
cSql += " CT2_DEBITO Like '411121081%' OR "
cSql += " CT2_DEBITO Like '411211011%' OR "
cSql += " CT2_DEBITO Like '411211021%' OR "
cSql += " CT2_DEBITO Like '411211031%' OR "
cSql += " CT2_DEBITO Like '411211041%' OR "
cSql += " CT2_DEBITO Like '411211051%' OR "
cSql += " CT2_DEBITO Like '411211061%' OR "
cSql += " CT2_DEBITO Like '411211081%' OR "
cSql += " CT2_DEBITO Like '411221011%' OR "
cSql += " CT2_DEBITO Like '411221021%' OR "
cSql += " CT2_DEBITO Like '411221031%' OR "
cSql += " CT2_DEBITO Like '411221041%' OR "
cSql += " CT2_DEBITO Like '411221051%' OR "
cSql += " CT2_DEBITO Like '411221061%' OR "
cSql += " CT2_DEBITO Like '411221081%' OR "
cSql += " CT2_DEBITO Like '411311011%' OR "
cSql += " CT2_DEBITO Like '411311021%' OR "
cSql += " CT2_DEBITO Like '411311031%' OR "
cSql += " CT2_DEBITO Like '411311041%' OR "
cSql += " CT2_DEBITO Like '411311051%' OR "
cSql += " CT2_DEBITO Like '411311061%' OR "
cSql += " CT2_DEBITO Like '411311081%' OR "
cSql += " CT2_DEBITO Like '411321011%' OR "
cSql += " CT2_DEBITO Like '411321021%' OR "
cSql += " CT2_DEBITO Like '411321031%' OR "
cSql += " CT2_DEBITO Like '411321041%' OR "
cSql += " CT2_DEBITO Like '411321051%' OR "
cSql += " CT2_DEBITO Like '411321061%' OR "
cSql += " CT2_DEBITO Like '411321081%' OR "
cSql += " CT2_DEBITO Like '411411011%' OR "
cSql += " CT2_DEBITO Like '411411021%' OR "
cSql += " CT2_DEBITO Like '411411031%' OR "
cSql += " CT2_DEBITO Like '411411041%' OR "
cSql += " CT2_DEBITO Like '411411051%' OR "
cSql += " CT2_DEBITO Like '411411061%' OR "
cSql += " CT2_DEBITO Like '411411017%' OR "
cSql += " CT2_DEBITO Like '411411027%' OR "
cSql += " CT2_DEBITO Like '411411037%' OR "
cSql += " CT2_DEBITO Like '411411047%' OR "
cSql += " CT2_DEBITO Like '411411057%' OR "
cSql += " CT2_DEBITO Like '411411067%' OR "
cSql += " CT2_DEBITO Like '411411081%' OR "
cSql += " CT2_DEBITO Like '411421011%' OR "
cSql += " CT2_DEBITO Like '411421021%' OR "
cSql += " CT2_DEBITO Like '411421031%' OR "
cSql += " CT2_DEBITO Like '411421041%' OR "
cSql += " CT2_DEBITO Like '411421051%' OR "
cSql += " CT2_DEBITO Like '411421061%' OR "
cSql += " CT2_DEBITO Like '411421017%' OR "
cSql += " CT2_DEBITO Like '411421027%' OR "
cSql += " CT2_DEBITO Like '411421037%' OR "
cSql += " CT2_DEBITO Like '411421047%' OR "
cSql += " CT2_DEBITO Like '411421057%' OR "
cSql += " CT2_DEBITO Like '411421067%' OR "
cSql += " CT2_DEBITO Like '411421081%' OR "
cSql += " CT2_DEBITO Like '411511011%' OR "
cSql += " CT2_DEBITO Like '411511021%' OR "
cSql += " CT2_DEBITO Like '411511031%' OR "
cSql += " CT2_DEBITO Like '411511041%' OR "
cSql += " CT2_DEBITO Like '411511051%' OR "
cSql += " CT2_DEBITO Like '411511061%' OR "
cSql += " CT2_DEBITO Like '411511081%' OR "
cSql += " CT2_DEBITO Like '411521011%' OR "
cSql += " CT2_DEBITO Like '411521021%' OR "
cSql += " CT2_DEBITO Like '411521031%' OR "
cSql += " CT2_DEBITO Like '411521041%' OR "
cSql += " CT2_DEBITO Like '411521051%' OR "
cSql += " CT2_DEBITO Like '411521061%' OR "
cSql += " CT2_DEBITO Like '411521081%' OR "
cSql += " CT2_DEBITO Like '411711011%' OR "
cSql += " CT2_DEBITO Like '411711021%' OR "
cSql += " CT2_DEBITO Like '411711031%' OR "
cSql += " CT2_DEBITO Like '411711041%' OR "
cSql += " CT2_DEBITO Like '411711051%' OR "
cSql += " CT2_DEBITO Like '411711061%' OR "
cSql += " CT2_DEBITO Like '411711017%' OR "
cSql += " CT2_DEBITO Like '411711027%' OR "
cSql += " CT2_DEBITO Like '411711037%' OR "
cSql += " CT2_DEBITO Like '411711047%' OR "
cSql += " CT2_DEBITO Like '411711057%' OR "
cSql += " CT2_DEBITO Like '411711067%' OR "
cSql += " CT2_DEBITO Like '411721011%' OR "
cSql += " CT2_DEBITO Like '411721021%' OR "
cSql += " CT2_DEBITO Like '411721031%' OR "
cSql += " CT2_DEBITO Like '411721041%' OR "
cSql += " CT2_DEBITO Like '411721051%' OR "
cSql += " CT2_DEBITO Like '411721061%' OR "
cSql += " CT2_DEBITO Like '411721017%' OR "
cSql += " CT2_DEBITO Like '411721027%' OR "
cSql += " CT2_DEBITO Like '411721037%' OR "
cSql += " CT2_DEBITO Like '411721047%' OR "
cSql += " CT2_DEBITO Like '411721057%' OR "
cSql += " CT2_DEBITO Like '411721067%' OR "
cSql += " CT2_DEBITO Like '411911011%' OR "
cSql += " CT2_DEBITO Like '411911021%' OR "
cSql += " CT2_DEBITO Like '411911031%' OR "
cSql += " CT2_DEBITO Like '411911041%' OR "
cSql += " CT2_DEBITO Like '411911051%' OR "
cSql += " CT2_DEBITO Like '411911061%' OR "
cSql += " CT2_DEBITO Like '411911017%' OR "
cSql += " CT2_DEBITO Like '411911027%' OR "
cSql += " CT2_DEBITO Like '411911037%' OR "
cSql += " CT2_DEBITO Like '411911047%' OR "
cSql += " CT2_DEBITO Like '411911057%' OR "
cSql += " CT2_DEBITO Like '411911067%' OR "
cSql += " CT2_DEBITO Like '411911081%' OR "
cSql += " CT2_DEBITO Like '411921011%' OR "
cSql += " CT2_DEBITO Like '411921021%' OR "
cSql += " CT2_DEBITO Like '411921031%' OR "
cSql += " CT2_DEBITO Like '411921041%' OR "
cSql += " CT2_DEBITO Like '411921051%' OR "
cSql += " CT2_DEBITO Like '411921061%' OR "
cSql += " CT2_DEBITO Like '411921017%' OR "
cSql += " CT2_DEBITO Like '411921027%' OR "
cSql += " CT2_DEBITO Like '411921037%' OR "
cSql += " CT2_DEBITO Like '411921047%' OR "
cSql += " CT2_DEBITO Like '411921057%' OR "
cSql += " CT2_DEBITO Like '411921067%' OR "
cSql += " CT2_DEBITO Like '411921081%' "

return cSql

/*
----------------------------------------------------------------------------------------
Grupo 33 ao 46 Contas: 

411111011 + 411111021 + 411111031 + 411111041 + 411111051 + 411111061 + 
411111017 + 411111027 + 411111037 + 411111047 + 411111057 + 411111067 + 411111081 + //1
411121011 + 411121021 + 411121031 + 411121041 + 411121051 + 411121061 +
411121017 + 411121027 + 411121037 + 411121047 + 411121057 + 411121067 + 411121081 + //2
411211011 + 411211021 + 411211031 + 411211041 + 411211051 + 411211061 + 411211081 +
411221011 + 411221021 + 411221031 + 411221041 + 411221051 + 411221061 + 411221081 + //3
411311011 + 411311021 + 411311031 + 411311041 + 411311051 + 411311061 + 411311081 +
411321011 + 411321021 + 411321031 + 411321041 + 411321051 + 411321061 + 411321081 + //4
411411011 + 411411021 + 411411031 + 411411041 + 411411051 + 411411061 +
411411017 + 411411027 + 411411037 + 411411047 + 411411057 + 411411067 + 411411081 + //5
411421011 + 411421021 + 411421031 + 411421041 + 411421051 + 411421061 +
411421017 + 411421027 + 411421037 + 411421047 + 411421057 + 411421067 + 411421081 + //6
411511011 + 411511021 + 411511031 + 411511041 + 411511051 + 411511061 + 411511081 +
411521011 + 411521021 + 411521031 + 411521041 + 411521051 + 411521061 + 411521081 + //7
411711011 + 411711021 + 411711031 + 411711041 + 411711051 + 411711061 +
411711017 + 411711027 + 411711037 + 411711047 + 411711057 + 411711067 + //8
411721011 + 411721021 + 411721031 + 411721041 + 411721051 + 411721061 +
411721017 + 411721027 + 411721037 + 411721047 + 411721057 + 411721067 + //9
411911011 + 411911021 + 411911031 + 411911041 + 411911051 + 411911061 + 
411911017 + 411911027 + 411911037 + 411911047 + 411911057 + 411911067 + 411911081 + //10
411921011 + 411921021 + 411921031 + 411921041 + 411921051 + 411921061 +
411921017 + 411921027 + 411921037 + 411921047 + 411921057 + 411921067 + 411921081 
----------------------------------------------------------------------------------------
*/
//query principal para reconhecimento e recuperações
static function retQry02(ntipo)

Local csql := ""
Local aMeses := CalcTriMes()
Local cMesult := aMeses[Len(aMeses)][2]
Local canoUlt := aMeses[Len(aMeses)][1]
Local cIniPriMes := aMeses[1][1]+aMeses[1][2]+'01'
Local cFimUltMes := canoUlt + cMesult + '31'

Default nTipo := 0

cSql += " select Distinct MESTRI, CODMOV, SUM(VAL) TOTVAL from ( "
cSql += " select MESTRI, VAL, "
cSql += retCodMov(ntipo)
cSql += " From ( "
cSql += " Select MESTRI, SUM(B) VAL, "
cSql += " Case "
cSql += " 	When EVENTO >= '" + canoUlt + cMesult + '01' + "' Then '00' "
cSql += " 	when EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '01' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '02' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '03' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '04' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '05' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '06' "
cSql += " 	when EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '07' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '08' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '09' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '10' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '11' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '12' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '13' "
cSql += " 	When EVENTO >= '" + retDateant(@canoUlt, @cMesult) + "' Then '14' "
cMesult := aMeses[Len(aMeses)][2]
canoUlt := aMeses[Len(aMeses)][1]

cSql += " 	else '15' "
cSql += " end MESEXE "
cSql += "  from ("
cSql += " Select distinct MESTRI, EVENTO, RECCT2, VALOR A, SUM(VALCV3) B from ("
cSql += " Select distinct  "
cSql += " Case "
cSql += "When CT2_DATA >= '" + canoUlt + cMesult + '01' + "' THEN '3' "
cSql += "When CT2_DATA >= '" + retDateant(@canoUlt, @cMesult) + "' then '2' "
cSql += "When CT2_DATA >= '" + retDateant(@canoUlt, @cMesult) + "' then '1' else '0' end MESTRI, "
cSql += "CONTA, VALOR, RECCT2, "
cSql += " COALESCE(BD7.BD7_DATPRO, CT2_DATA) EVENTO, "
cSql += " COALESCE(BD7.R_E_C_N_O_ , 0) RECBD7, "
cSql += " VALCV3 "
cSql += " from ( "
cSql += " Select DISTINCT  CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR "
If nTipo <> 2 //só pra recuperação por glosa é invertido
	cSql += " * -1 "
endIf
cSql += " VALOR, CT2.R_E_C_N_O_ RECCT2  , "
cSql += " COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI, CV3_VLR01 VALCV3 from " + RetSqlName("CT2") + " CT2  "
cSql += " LEFT Join " + RetSqlName("CV3") + " CV3  On  CV3_FILIAL = '" + xFilial("CV3") + "' AND  CV3_RECDES = CT2.R_E_C_N_O_ AND  CV3.D_E_L_E_T_ = ' '  Where  "
cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' "
cSql += " AND CT2_DATA >= '" + cIniPriMes + "' "
cSql += " AND  CT2_DATA <= '" + cFimUltMes + "' "
cSql += " AND  ( "
If ntipo == 2
	cSql += retCTAcre2()
elseIf ntipo == 3
	cSql += retCTAcre3()	  	  
else
	cSql += retCTAcre()	 
endIf
cSql += ") AND  CT2.D_E_L_E_T_ = ' '  "
cSql += " Union  "
cSql += " Select DISTINCT  CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR "
If nTipo == 2 //só pra recuperação por glosa é invertido
	cSql += " * -1 "
endIf
cSql += " VALOR, CT2.R_E_C_N_O_ RECCT2  , "
cSql += " COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI, CV3_VLR01 VALCV3  from " + RetSqlName("CT2") + " CT2  "
cSql += " LEFT Join " + RetSqlName("CV3") + " CV3  On  CV3_FILIAL = '" + xFilial("CV3") + "' AND  CV3_RECDES = CT2.R_E_C_N_O_ AND  CV3.D_E_L_E_T_ = ' '  Where  "
cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' "
cSql += " AND CT2_DATA >= '" + cIniPriMes + "' "
cSql += " AND  CT2_DATA <= '" + cFimUltMes + "' "
cSql += " AND  (  "
If ntipo == 2
	cSql += retCTAdeb2()
elseIf ntipo == 3
	cSql += retCTAdeb3()
else
	cSql += retCTAdeb()	 
endIf
cSql += "	) AND  CT2.D_E_L_E_T_ = ' '  "
cSql += " ) Z "
cSql += " Inner join  " + retSqlName("BD7") + "  BD7 On Z.TABORI = 'BD7' AND BD7.R_E_C_N_O_ = Z.RECORI AND BD7.BD7_LAPRO = 'S' AND BD7.D_E_L_E_T_ = ' ' "
cSql += " ) H "
cSql += " group by MESTRI, EVENTO, RECCT2, VALOR "
cSql += " ) K "
cSql += " Where MESTRI <> '0' "
cSql += " Group by MESTRI, EVENTO "
cSql += " ) NE "
cSql += " ) X  "
cSql += " Group By MESTRI, CODMOV "
cSql += " Order By MESTRI, CODMOV "

return cSql


static function retDateant(__cParAno, __cParMes)

Local cMesant := ""
Local canoant := ""
Local cRet := ""

If __cParMes == "01"
	cMesant := "12"
	canoant := StrZero(Val(__cParAno) - 1, 4)
else
	cMesant := StrZero(Val(__cParMes) - 1, 2)
	canoant := __cParAno
endIf

cret := canoant + cMesant + '01'
__cParAno := canoant
__cParMes := cMesant

return cret

/*
Grupo 47 ao 60 Contas: 

411111012 + 411111022 + 411111032 + 411111042 + 411111052 + 411111062 + 411111082 +
411121012 + 411121022 + 411121032 + 411121042 + 411121052 + 411121062 + 411121082 +
411211012 + 411211022 + 411211032 + 411211042 + 411211052 + 411211062 + 411211082 +
411221012 + 411221022 + 411221032 + 411221042 + 411221052 + 411221062 + 411221082 +
411311012 + 411311022 + 411311032 + 411311042 + 411311052 + 411311062 + 411311082 +
411321012 + 411321022 + 411321032 + 411321042 + 411321052 + 411321062 + 411321082 +
411411012 + 411411022 + 411411032 + 411411042 + 411411052 + 411411062 + 411411082 +
411421012 + 411421022 + 411421032 + 411421042 + 411421052 + 411421062 + 411421082 +
411511012 + 411511022 + 411511032 + 411511042 + 411511052 + 411511062 + 411511082 +
411521012 + 411521022 + 411521032 + 411521042 + 411521052 + 411521062 + 411521082 +
411711012 + 411711022 + 411711032 + 411711042 + 411711052 + 411711062 + 
411721012 + 411721022 + 411721032 + 411721042 + 411721052 + 411721062 + 
411911012 + 411911022 + 411911032 + 411911042 + 411911052 + 411911062 + 411911082 +
411921012 + 411921022 + 411921032 + 411921042 + 411921052 + 411921062 + 411921082 
*/
//contas para recuperação por glosa - crédito
static function retCTAcre2()

Local cSql := ""

cSql += " CT2_CREDIT Like '411111012%' OR "
cSql += " CT2_CREDIT Like '411121012%' OR "
cSql += " CT2_CREDIT Like '411211012%' OR "
cSql += " CT2_CREDIT Like '411221012%' OR "
cSql += " CT2_CREDIT Like '411311012%' OR "
cSql += " CT2_CREDIT Like '411321012%' OR "
cSql += " CT2_CREDIT Like '411411012%' OR "
cSql += " CT2_CREDIT Like '411421012%' OR "
cSql += " CT2_CREDIT Like '411511012%' OR "
cSql += " CT2_CREDIT Like '411521012%' OR "
cSql += " CT2_CREDIT Like '411711012%' OR "
cSql += " CT2_CREDIT Like '411721012%' OR "
cSql += " CT2_CREDIT Like '411911012%' OR "
cSql += " CT2_CREDIT Like '411921012%' OR "

cSql += " CT2_CREDIT Like '411111022%' OR "
cSql += " CT2_CREDIT Like '411121022%' OR "
cSql += " CT2_CREDIT Like '411211022%' OR "
cSql += " CT2_CREDIT Like '411221022%' OR "
cSql += " CT2_CREDIT Like '411311022%' OR "
cSql += " CT2_CREDIT Like '411321022%' OR "
cSql += " CT2_CREDIT Like '411411022%' OR "
cSql += " CT2_CREDIT Like '411421022%' OR "
cSql += " CT2_CREDIT Like '411511022%' OR "
cSql += " CT2_CREDIT Like '411521022%' OR "
cSql += " CT2_CREDIT Like '411711022%' OR "
cSql += " CT2_CREDIT Like '411721022%' OR "
cSql += " CT2_CREDIT Like '411911022%' OR "
cSql += " CT2_CREDIT Like '411921022%' OR "

cSql += " CT2_CREDIT Like '411111032%' OR "
cSql += " CT2_CREDIT Like '411121032%' OR "
cSql += " CT2_CREDIT Like '411211032%' OR "
cSql += " CT2_CREDIT Like '411221032%' OR "
cSql += " CT2_CREDIT Like '411311032%' OR "
cSql += " CT2_CREDIT Like '411321032%' OR "
cSql += " CT2_CREDIT Like '411411032%' OR "
cSql += " CT2_CREDIT Like '411421032%' OR "
cSql += " CT2_CREDIT Like '411511032%' OR "
cSql += " CT2_CREDIT Like '411521032%' OR "
cSql += " CT2_CREDIT Like '411711032%' OR "
cSql += " CT2_CREDIT Like '411721032%' OR "
cSql += " CT2_CREDIT Like '411911032%' OR "
cSql += " CT2_CREDIT Like '411921032%' OR "

cSql += " CT2_CREDIT Like '411111042%' OR "
cSql += " CT2_CREDIT Like '411121042%' OR "
cSql += " CT2_CREDIT Like '411211042%' OR "
cSql += " CT2_CREDIT Like '411221042%' OR "
cSql += " CT2_CREDIT Like '411311042%' OR "
cSql += " CT2_CREDIT Like '411321042%' OR "
cSql += " CT2_CREDIT Like '411411042%' OR "
cSql += " CT2_CREDIT Like '411421042%' OR "
cSql += " CT2_CREDIT Like '411511042%' OR "
cSql += " CT2_CREDIT Like '411521042%' OR "
cSql += " CT2_CREDIT Like '411711042%' OR "
cSql += " CT2_CREDIT Like '411721042%' OR "
cSql += " CT2_CREDIT Like '411911042%' OR "
cSql += " CT2_CREDIT Like '411921042%' OR "

cSql += " CT2_CREDIT Like '411111052%' OR "
cSql += " CT2_CREDIT Like '411121052%' OR "
cSql += " CT2_CREDIT Like '411211052%' OR "
cSql += " CT2_CREDIT Like '411221052%' OR "
cSql += " CT2_CREDIT Like '411311052%' OR "
cSql += " CT2_CREDIT Like '411321052%' OR "
cSql += " CT2_CREDIT Like '411411052%' OR "
cSql += " CT2_CREDIT Like '411421052%' OR "
cSql += " CT2_CREDIT Like '411511052%' OR "
cSql += " CT2_CREDIT Like '411521052%' OR "
cSql += " CT2_CREDIT Like '411711052%' OR "
cSql += " CT2_CREDIT Like '411721052%' OR "
cSql += " CT2_CREDIT Like '411911052%' OR "
cSql += " CT2_CREDIT Like '411921052%' OR "

cSql += " CT2_CREDIT Like '411111062%' OR "
cSql += " CT2_CREDIT Like '411121062%' OR "
cSql += " CT2_CREDIT Like '411211062%' OR "
cSql += " CT2_CREDIT Like '411221062%' OR "
cSql += " CT2_CREDIT Like '411311062%' OR "
cSql += " CT2_CREDIT Like '411321062%' OR "
cSql += " CT2_CREDIT Like '411411062%' OR "
cSql += " CT2_CREDIT Like '411421062%' OR "
cSql += " CT2_CREDIT Like '411511062%' OR "
cSql += " CT2_CREDIT Like '411521062%' OR "
cSql += " CT2_CREDIT Like '411711062%' OR "
cSql += " CT2_CREDIT Like '411721062%' OR "
cSql += " CT2_CREDIT Like '411911062%' OR "
cSql += " CT2_CREDIT Like '411921062%' OR "

cSql += " CT2_CREDIT Like '411111082%' OR "
cSql += " CT2_CREDIT Like '411121082%' OR "
cSql += " CT2_CREDIT Like '411211082%' OR "
cSql += " CT2_CREDIT Like '411221082%' OR "
cSql += " CT2_CREDIT Like '411311082%' OR "
cSql += " CT2_CREDIT Like '411321082%' OR "
cSql += " CT2_CREDIT Like '411411082%' OR "
cSql += " CT2_CREDIT Like '411421082%' OR "
cSql += " CT2_CREDIT Like '411511082%' OR "
cSql += " CT2_CREDIT Like '411521082%' OR "
cSql += " CT2_CREDIT Like '411911082%' OR "
cSql += " CT2_CREDIT Like '411921082%'  "

return cSql

//contas para recuperação por glosa - débito
static function retCTAdeb2()

Local cSql := ""

cSql += " CT2_DEBITO Like '411111012%' OR "
cSql += " CT2_DEBITO Like '411121012%' OR "
cSql += " CT2_DEBITO Like '411211012%' OR "
cSql += " CT2_DEBITO Like '411221012%' OR "
cSql += " CT2_DEBITO Like '411311012%' OR "
cSql += " CT2_DEBITO Like '411321012%' OR "
cSql += " CT2_DEBITO Like '411411012%' OR "
cSql += " CT2_DEBITO Like '411421012%' OR "
cSql += " CT2_DEBITO Like '411511012%' OR "
cSql += " CT2_DEBITO Like '411521012%' OR "
cSql += " CT2_DEBITO Like '411711012%' OR "
cSql += " CT2_DEBITO Like '411721012%' OR "
cSql += " CT2_DEBITO Like '411911012%' OR "
cSql += " CT2_DEBITO Like '411921012%' OR "

cSql += " CT2_DEBITO Like '411111022%' OR "
cSql += " CT2_DEBITO Like '411121022%' OR "
cSql += " CT2_DEBITO Like '411211022%' OR "
cSql += " CT2_DEBITO Like '411221022%' OR "
cSql += " CT2_DEBITO Like '411311022%' OR "
cSql += " CT2_DEBITO Like '411321022%' OR "
cSql += " CT2_DEBITO Like '411411022%' OR "
cSql += " CT2_DEBITO Like '411421022%' OR "
cSql += " CT2_DEBITO Like '411511022%' OR "
cSql += " CT2_DEBITO Like '411521022%' OR "
cSql += " CT2_DEBITO Like '411711022%' OR "
cSql += " CT2_DEBITO Like '411721022%' OR "
cSql += " CT2_DEBITO Like '411911022%' OR "
cSql += " CT2_DEBITO Like '411921022%' OR "

cSql += " CT2_DEBITO Like '411111032%' OR "
cSql += " CT2_DEBITO Like '411121032%' OR "
cSql += " CT2_DEBITO Like '411211032%' OR "
cSql += " CT2_DEBITO Like '411221032%' OR "
cSql += " CT2_DEBITO Like '411311032%' OR "
cSql += " CT2_DEBITO Like '411321032%' OR "
cSql += " CT2_DEBITO Like '411411032%' OR "
cSql += " CT2_DEBITO Like '411421032%' OR "
cSql += " CT2_DEBITO Like '411511032%' OR "
cSql += " CT2_DEBITO Like '411521032%' OR "
cSql += " CT2_DEBITO Like '411711032%' OR "
cSql += " CT2_DEBITO Like '411721032%' OR "
cSql += " CT2_DEBITO Like '411911032%' OR "
cSql += " CT2_DEBITO Like '411921032%' OR "

cSql += " CT2_DEBITO Like '411111042%' OR "
cSql += " CT2_DEBITO Like '411121042%' OR "
cSql += " CT2_DEBITO Like '411211042%' OR "
cSql += " CT2_DEBITO Like '411221042%' OR "
cSql += " CT2_DEBITO Like '411311042%' OR "
cSql += " CT2_DEBITO Like '411321042%' OR "
cSql += " CT2_DEBITO Like '411411042%' OR "
cSql += " CT2_DEBITO Like '411421042%' OR "
cSql += " CT2_DEBITO Like '411511042%' OR "
cSql += " CT2_DEBITO Like '411521042%' OR "
cSql += " CT2_DEBITO Like '411711042%' OR "
cSql += " CT2_DEBITO Like '411721042%' OR "
cSql += " CT2_DEBITO Like '411911042%' OR "
cSql += " CT2_DEBITO Like '411921042%' OR "

cSql += " CT2_DEBITO Like '411111052%' OR "
cSql += " CT2_DEBITO Like '411121052%' OR "
cSql += " CT2_DEBITO Like '411211052%' OR "
cSql += " CT2_DEBITO Like '411221052%' OR "
cSql += " CT2_DEBITO Like '411311052%' OR "
cSql += " CT2_DEBITO Like '411321052%' OR "
cSql += " CT2_DEBITO Like '411411052%' OR "
cSql += " CT2_DEBITO Like '411421052%' OR "
cSql += " CT2_DEBITO Like '411511052%' OR "
cSql += " CT2_DEBITO Like '411521052%' OR "
cSql += " CT2_DEBITO Like '411711052%' OR "
cSql += " CT2_DEBITO Like '411721052%' OR "
cSql += " CT2_DEBITO Like '411911052%' OR "
cSql += " CT2_DEBITO Like '411921052%' OR "

cSql += " CT2_DEBITO Like '411111062%' OR "
cSql += " CT2_DEBITO Like '411121062%' OR "
cSql += " CT2_DEBITO Like '411211062%' OR "
cSql += " CT2_DEBITO Like '411221062%' OR "
cSql += " CT2_DEBITO Like '411311062%' OR "
cSql += " CT2_DEBITO Like '411321062%' OR "
cSql += " CT2_DEBITO Like '411411062%' OR "
cSql += " CT2_DEBITO Like '411421062%' OR "
cSql += " CT2_DEBITO Like '411511062%' OR "
cSql += " CT2_DEBITO Like '411521062%' OR "
cSql += " CT2_DEBITO Like '411711062%' OR "
cSql += " CT2_DEBITO Like '411721062%' OR "
cSql += " CT2_DEBITO Like '411911062%' OR "
cSql += " CT2_DEBITO Like '411921062%' OR "

cSql += " CT2_DEBITO Like '411111082%' OR "
cSql += " CT2_DEBITO Like '411121082%' OR "
cSql += " CT2_DEBITO Like '411211082%' OR "
cSql += " CT2_DEBITO Like '411221082%' OR "
cSql += " CT2_DEBITO Like '411311082%' OR "
cSql += " CT2_DEBITO Like '411321082%' OR "
cSql += " CT2_DEBITO Like '411411082%' OR "
cSql += " CT2_DEBITO Like '411421082%' OR "
cSql += " CT2_DEBITO Like '411511082%' OR "
cSql += " CT2_DEBITO Like '411521082%' OR "
cSql += " CT2_DEBITO Like '411911082%' OR "
cSql += " CT2_DEBITO Like '411921082%'  "

return cSql

/*
Grupo 65 ao 78 Contas:

411111013 + 411111023 + 411111033 + 411111043 + 411111053 + 411111063 +
411111019 + 411111029 + 411111039 + 411111049 + 411111059 + 411111069 + 
411121013 + 411121023 + 411121033 + 411121043 + 411121053 + 411121063 + 
411121019 + 411121029 + 411121039 + 411121049 + 411121059 + 411121069 + 
411211013 + 411211023 + 411211033 + 411211043 + 411211053 + 411211063 + 
411211019 + 411211029 + 411211039 + 411211049 + 411211059 + 411211069 +
411221013 + 411221023 + 411221033 + 411221043 + 411221053 + 411221063 + 
411221019 + 411221029 + 411221039 + 411221049 + 411221059 + 411221069 +
411311013 + 411311023 + 411311033 + 411311043 + 411311053 + 411311063 + 
411311019 + 411311029 + 411311039 + 411311049 + 411311059 + 411311069 +
411321013 + 411321023 + 411321033 + 411321043 + 411321053 + 411321063 +
411321019 + 411321029 + 411321039 + 411321049 + 411321059 + 411321069 +
411411013 + 411411023 + 411411033 + 411411043 + 411411053 + 411411063 +
411411019 + 411411029 + 411411039 + 411411049 + 411411059 + 411411069 + 
411421013 + 411421023 + 411421033 + 411421043 + 411421053 + 411421063 +
411421019 + 411421029 + 411421039 + 411421049 + 411421059 + 411421069 +
411511013 + 411511023 + 411511033 + 411511043 + 411511053 + 411511063 + 
411511019 + 411511029 + 411511039 + 411511049 + 411511059 + 411511069 +
411521013 + 411521023 + 411521033 + 411521043 + 411521053 + 411521063 +
411521019 + 411521029 + 411521039 + 411521049 + 411521059 + 411521069 +
411711013 + 411711023 + 411711033 + 411711043 + 411711053 + 411711063 +
411711019 + 411711029 + 411711039 + 411711049 + 411711059 + 411711069 + 
411721013 + 411721023 + 411721033 + 411721043 + 411721053 + 411721063 +
411721019 + 411721029 + 411721039 + 411721049 + 411721059 + 411721069 +
411911013 + 411911023 + 411911033 + 411911043 + 411911053 + 411911063 + 
411911019 + 411911029 + 411911039 + 411911049 + 411911059 + 411911069 +
411921013 + 411921023 + 411921033 + 411921043 + 411921053 + 411921063 +
411921019 + 411921029 + 411921039 + 411921049 + 411921059 + 411921069

*/

//contas para demais recuperações - débito
static function retCTAdeb3()

Local cSql := ""

cSql += " CT2_DEBITO Like '411111013%' OR "
cSql += " CT2_DEBITO Like '411111019%' OR "
cSql += " CT2_DEBITO Like '411121013%' OR "
cSql += " CT2_DEBITO Like '411121019%' OR "
cSql += " CT2_DEBITO Like '411211013%' OR "
cSql += " CT2_DEBITO Like '411211019%' OR "
cSql += " CT2_DEBITO Like '411221013%' OR "
cSql += " CT2_DEBITO Like '411221019%' OR "
cSql += " CT2_DEBITO Like '411311013%' OR "
cSql += " CT2_DEBITO Like '411311019%' OR "
cSql += " CT2_DEBITO Like '411321013%' OR "
cSql += " CT2_DEBITO Like '411321019%' OR "
cSql += " CT2_DEBITO Like '411411013%' OR "
cSql += " CT2_DEBITO Like '411411019%' OR "
cSql += " CT2_DEBITO Like '411421013%' OR "
cSql += " CT2_DEBITO Like '411421019%' OR "
cSql += " CT2_DEBITO Like '411511013%' OR "
cSql += " CT2_DEBITO Like '411511019%' OR "
cSql += " CT2_DEBITO Like '411521013%' OR "
cSql += " CT2_DEBITO Like '411521019%' OR "
cSql += " CT2_DEBITO Like '411711013%' OR "
cSql += " CT2_DEBITO Like '411711019%' OR "
cSql += " CT2_DEBITO Like '411721013%' OR "
cSql += " CT2_DEBITO Like '411721019%' OR "
cSql += " CT2_DEBITO Like '411911013%' OR "
cSql += " CT2_DEBITO Like '411911019%' OR "
cSql += " CT2_DEBITO Like '411921013%' OR "
cSql += " CT2_DEBITO Like '411921019%' OR "

cSql += " CT2_DEBITO Like '411111023%' OR "
cSql += " CT2_DEBITO Like '411111029%' OR "
cSql += " CT2_DEBITO Like '411121023%' OR "
cSql += " CT2_DEBITO Like '411121029%' OR "
cSql += " CT2_DEBITO Like '411211023%' OR "
cSql += " CT2_DEBITO Like '411211029%' OR "
cSql += " CT2_DEBITO Like '411221023%' OR "
cSql += " CT2_DEBITO Like '411221029%' OR "
cSql += " CT2_DEBITO Like '411311023%' OR "
cSql += " CT2_DEBITO Like '411311029%' OR "
cSql += " CT2_DEBITO Like '411321023%' OR "
cSql += " CT2_DEBITO Like '411321029%' OR "
cSql += " CT2_DEBITO Like '411411023%' OR "
cSql += " CT2_DEBITO Like '411411029%' OR "
cSql += " CT2_DEBITO Like '411421023%' OR "
cSql += " CT2_DEBITO Like '411421029%' OR "
cSql += " CT2_DEBITO Like '411511023%' OR "
cSql += " CT2_DEBITO Like '411511029%' OR "
cSql += " CT2_DEBITO Like '411521023%' OR "
cSql += " CT2_DEBITO Like '411521029%' OR "
cSql += " CT2_DEBITO Like '411711023%' OR "
cSql += " CT2_DEBITO Like '411711029%' OR "
cSql += " CT2_DEBITO Like '411721023%' OR "
cSql += " CT2_DEBITO Like '411721029%' OR "
cSql += " CT2_DEBITO Like '411911023%' OR "
cSql += " CT2_DEBITO Like '411911029%' OR "
cSql += " CT2_DEBITO Like '411921023%' OR "
cSql += " CT2_DEBITO Like '411921029%' OR "

cSql += " CT2_DEBITO Like '411111033%' OR "
cSql += " CT2_DEBITO Like '411111039%' OR "
cSql += " CT2_DEBITO Like '411121033%' OR "
cSql += " CT2_DEBITO Like '411121039%' OR "
cSql += " CT2_DEBITO Like '411211033%' OR "
cSql += " CT2_DEBITO Like '411211039%' OR "
cSql += " CT2_DEBITO Like '411221033%' OR "
cSql += " CT2_DEBITO Like '411221039%' OR "
cSql += " CT2_DEBITO Like '411311033%' OR "
cSql += " CT2_DEBITO Like '411311039%' OR "
cSql += " CT2_DEBITO Like '411321033%' OR "
cSql += " CT2_DEBITO Like '411321039%' OR "
cSql += " CT2_DEBITO Like '411411033%' OR "
cSql += " CT2_DEBITO Like '411411039%' OR "
cSql += " CT2_DEBITO Like '411421033%' OR "
cSql += " CT2_DEBITO Like '411421039%' OR "
cSql += " CT2_DEBITO Like '411511033%' OR "
cSql += " CT2_DEBITO Like '411511039%' OR "
cSql += " CT2_DEBITO Like '411521033%' OR "
cSql += " CT2_DEBITO Like '411521039%' OR "
cSql += " CT2_DEBITO Like '411711033%' OR "
cSql += " CT2_DEBITO Like '411711039%' OR "
cSql += " CT2_DEBITO Like '411721033%' OR "
cSql += " CT2_DEBITO Like '411721039%' OR "
cSql += " CT2_DEBITO Like '411911033%' OR "
cSql += " CT2_DEBITO Like '411911039%' OR "
cSql += " CT2_DEBITO Like '411921033%' OR "
cSql += " CT2_DEBITO Like '411921039%' OR "

cSql += " CT2_DEBITO Like '411111043%' OR "
cSql += " CT2_DEBITO Like '411111049%' OR "
cSql += " CT2_DEBITO Like '411121043%' OR "
cSql += " CT2_DEBITO Like '411121049%' OR "
cSql += " CT2_DEBITO Like '411211043%' OR "
cSql += " CT2_DEBITO Like '411211049%' OR "
cSql += " CT2_DEBITO Like '411221043%' OR "
cSql += " CT2_DEBITO Like '411221049%' OR "
cSql += " CT2_DEBITO Like '411311043%' OR "
cSql += " CT2_DEBITO Like '411311049%' OR "
cSql += " CT2_DEBITO Like '411321043%' OR "
cSql += " CT2_DEBITO Like '411321049%' OR "
cSql += " CT2_DEBITO Like '411411043%' OR "
cSql += " CT2_DEBITO Like '411411049%' OR "
cSql += " CT2_DEBITO Like '411421043%' OR "
cSql += " CT2_DEBITO Like '411421049%' OR "
cSql += " CT2_DEBITO Like '411511043%' OR "
cSql += " CT2_DEBITO Like '411511049%' OR "
cSql += " CT2_DEBITO Like '411521043%' OR "
cSql += " CT2_DEBITO Like '411521049%' OR "
cSql += " CT2_DEBITO Like '411711043%' OR "
cSql += " CT2_DEBITO Like '411711049%' OR "
cSql += " CT2_DEBITO Like '411721043%' OR "
cSql += " CT2_DEBITO Like '411721049%' OR "
cSql += " CT2_DEBITO Like '411911043%' OR "
cSql += " CT2_DEBITO Like '411911049%' OR "
cSql += " CT2_DEBITO Like '411921043%' OR "
cSql += " CT2_DEBITO Like '411921049%' OR "

cSql += " CT2_DEBITO Like '411111053%' OR "
cSql += " CT2_DEBITO Like '411111059%' OR "
cSql += " CT2_DEBITO Like '411121053%' OR "
cSql += " CT2_DEBITO Like '411121059%' OR "
cSql += " CT2_DEBITO Like '411211053%' OR "
cSql += " CT2_DEBITO Like '411211059%' OR "
cSql += " CT2_DEBITO Like '411221053%' OR "
cSql += " CT2_DEBITO Like '411221059%' OR "
cSql += " CT2_DEBITO Like '411311053%' OR "
cSql += " CT2_DEBITO Like '411311059%' OR "
cSql += " CT2_DEBITO Like '411321053%' OR "
cSql += " CT2_DEBITO Like '411321059%' OR "
cSql += " CT2_DEBITO Like '411411053%' OR "
cSql += " CT2_DEBITO Like '411411059%' OR "
cSql += " CT2_DEBITO Like '411421053%' OR "
cSql += " CT2_DEBITO Like '411421059%' OR "
cSql += " CT2_DEBITO Like '411511053%' OR "
cSql += " CT2_DEBITO Like '411511059%' OR "
cSql += " CT2_DEBITO Like '411521053%' OR "
cSql += " CT2_DEBITO Like '411521059%' OR "
cSql += " CT2_DEBITO Like '411711053%' OR "
cSql += " CT2_DEBITO Like '411711059%' OR "
cSql += " CT2_DEBITO Like '411721053%' OR "
cSql += " CT2_DEBITO Like '411721059%' OR "
cSql += " CT2_DEBITO Like '411911053%' OR "
cSql += " CT2_DEBITO Like '411911059%' OR "
cSql += " CT2_DEBITO Like '411921053%' OR "
cSql += " CT2_DEBITO Like '411921059%' OR "

cSql += " CT2_DEBITO Like '411111063%' OR "
cSql += " CT2_DEBITO Like '411111069%' OR "
cSql += " CT2_DEBITO Like '411121063%' OR "
cSql += " CT2_DEBITO Like '411121069%' OR "
cSql += " CT2_DEBITO Like '411211063%' OR "
cSql += " CT2_DEBITO Like '411211069%' OR "
cSql += " CT2_DEBITO Like '411221063%' OR "
cSql += " CT2_DEBITO Like '411221069%' OR "
cSql += " CT2_DEBITO Like '411311063%' OR "
cSql += " CT2_DEBITO Like '411311069%' OR "
cSql += " CT2_DEBITO Like '411321063%' OR "
cSql += " CT2_DEBITO Like '411321069%' OR "
cSql += " CT2_DEBITO Like '411411063%' OR "
cSql += " CT2_DEBITO Like '411411069%' OR "
cSql += " CT2_DEBITO Like '411421063%' OR "
cSql += " CT2_DEBITO Like '411421069%' OR "
cSql += " CT2_DEBITO Like '411511063%' OR "
cSql += " CT2_DEBITO Like '411511069%' OR "
cSql += " CT2_DEBITO Like '411521063%' OR "
cSql += " CT2_DEBITO Like '411521069%' OR "
cSql += " CT2_DEBITO Like '411711063%' OR "
cSql += " CT2_DEBITO Like '411711069%' OR "
cSql += " CT2_DEBITO Like '411721063%' OR "
cSql += " CT2_DEBITO Like '411721069%' OR "
cSql += " CT2_DEBITO Like '411911063%' OR "
cSql += " CT2_DEBITO Like '411911069%' OR "
cSql += " CT2_DEBITO Like '411921063%' OR "
cSql += " CT2_DEBITO Like '411921069%' "

return csql

//contas para demais recuperações - crédito
static function retCTAcre3()

Local cSql := ""

cSql += " CT2_CREDIT Like '411111013%' OR "
cSql += " CT2_CREDIT Like '411111019%' OR "
cSql += " CT2_CREDIT Like '411121013%' OR "
cSql += " CT2_CREDIT Like '411121019%' OR "
cSql += " CT2_CREDIT Like '411211013%' OR "
cSql += " CT2_CREDIT Like '411211019%' OR "
cSql += " CT2_CREDIT Like '411221013%' OR "
cSql += " CT2_CREDIT Like '411221019%' OR "
cSql += " CT2_CREDIT Like '411311013%' OR "
cSql += " CT2_CREDIT Like '411311019%' OR "
cSql += " CT2_CREDIT Like '411321013%' OR "
cSql += " CT2_CREDIT Like '411321019%' OR "
cSql += " CT2_CREDIT Like '411411013%' OR "
cSql += " CT2_CREDIT Like '411411019%' OR "
cSql += " CT2_CREDIT Like '411421013%' OR "
cSql += " CT2_CREDIT Like '411421019%' OR "
cSql += " CT2_CREDIT Like '411511013%' OR "
cSql += " CT2_CREDIT Like '411511019%' OR "
cSql += " CT2_CREDIT Like '411521013%' OR "
cSql += " CT2_CREDIT Like '411521019%' OR "
cSql += " CT2_CREDIT Like '411711013%' OR "
cSql += " CT2_CREDIT Like '411711019%' OR "
cSql += " CT2_CREDIT Like '411721013%' OR "
cSql += " CT2_CREDIT Like '411721019%' OR "
cSql += " CT2_CREDIT Like '411911013%' OR "
cSql += " CT2_CREDIT Like '411911019%' OR "
cSql += " CT2_CREDIT Like '411921013%' OR "
cSql += " CT2_CREDIT Like '411921019%' OR "

cSql += " CT2_CREDIT Like '411111023%' OR "
cSql += " CT2_CREDIT Like '411111029%' OR "
cSql += " CT2_CREDIT Like '411121023%' OR "
cSql += " CT2_CREDIT Like '411121029%' OR "
cSql += " CT2_CREDIT Like '411211023%' OR "
cSql += " CT2_CREDIT Like '411211029%' OR "
cSql += " CT2_CREDIT Like '411221023%' OR "
cSql += " CT2_CREDIT Like '411221029%' OR "
cSql += " CT2_CREDIT Like '411311023%' OR "
cSql += " CT2_CREDIT Like '411311029%' OR "
cSql += " CT2_CREDIT Like '411321023%' OR "
cSql += " CT2_CREDIT Like '411321029%' OR "
cSql += " CT2_CREDIT Like '411411023%' OR "
cSql += " CT2_CREDIT Like '411411029%' OR "
cSql += " CT2_CREDIT Like '411421023%' OR "
cSql += " CT2_CREDIT Like '411421029%' OR "
cSql += " CT2_CREDIT Like '411511023%' OR "
cSql += " CT2_CREDIT Like '411511029%' OR "
cSql += " CT2_CREDIT Like '411521023%' OR "
cSql += " CT2_CREDIT Like '411521029%' OR "
cSql += " CT2_CREDIT Like '411711023%' OR "
cSql += " CT2_CREDIT Like '411711029%' OR "
cSql += " CT2_CREDIT Like '411721023%' OR "
cSql += " CT2_CREDIT Like '411721029%' OR "
cSql += " CT2_CREDIT Like '411911023%' OR "
cSql += " CT2_CREDIT Like '411911029%' OR "
cSql += " CT2_CREDIT Like '411921023%' OR "
cSql += " CT2_CREDIT Like '411921029%' OR "

cSql += " CT2_CREDIT Like '411111033%' OR "
cSql += " CT2_CREDIT Like '411111039%' OR "
cSql += " CT2_CREDIT Like '411121033%' OR "
cSql += " CT2_CREDIT Like '411121039%' OR "
cSql += " CT2_CREDIT Like '411211033%' OR "
cSql += " CT2_CREDIT Like '411211039%' OR "
cSql += " CT2_CREDIT Like '411221033%' OR "
cSql += " CT2_CREDIT Like '411221039%' OR "
cSql += " CT2_CREDIT Like '411311033%' OR "
cSql += " CT2_CREDIT Like '411311039%' OR "
cSql += " CT2_CREDIT Like '411321033%' OR "
cSql += " CT2_CREDIT Like '411321039%' OR "
cSql += " CT2_CREDIT Like '411411033%' OR "
cSql += " CT2_CREDIT Like '411411039%' OR "
cSql += " CT2_CREDIT Like '411421033%' OR "
cSql += " CT2_CREDIT Like '411421039%' OR "
cSql += " CT2_CREDIT Like '411511033%' OR "
cSql += " CT2_CREDIT Like '411511039%' OR "
cSql += " CT2_CREDIT Like '411521033%' OR "
cSql += " CT2_CREDIT Like '411521039%' OR "
cSql += " CT2_CREDIT Like '411711033%' OR "
cSql += " CT2_CREDIT Like '411711039%' OR "
cSql += " CT2_CREDIT Like '411721033%' OR "
cSql += " CT2_CREDIT Like '411721039%' OR "
cSql += " CT2_CREDIT Like '411911033%' OR "
cSql += " CT2_CREDIT Like '411911039%' OR "
cSql += " CT2_CREDIT Like '411921033%' OR "
cSql += " CT2_CREDIT Like '411921039%' OR "

cSql += " CT2_CREDIT Like '411111043%' OR "
cSql += " CT2_CREDIT Like '411111049%' OR "
cSql += " CT2_CREDIT Like '411121043%' OR "
cSql += " CT2_CREDIT Like '411121049%' OR "
cSql += " CT2_CREDIT Like '411211043%' OR "
cSql += " CT2_CREDIT Like '411211049%' OR "
cSql += " CT2_CREDIT Like '411221043%' OR "
cSql += " CT2_CREDIT Like '411221049%' OR "
cSql += " CT2_CREDIT Like '411311043%' OR "
cSql += " CT2_CREDIT Like '411311049%' OR "
cSql += " CT2_CREDIT Like '411321043%' OR "
cSql += " CT2_CREDIT Like '411321049%' OR "
cSql += " CT2_CREDIT Like '411411043%' OR "
cSql += " CT2_CREDIT Like '411411049%' OR "
cSql += " CT2_CREDIT Like '411421043%' OR "
cSql += " CT2_CREDIT Like '411421049%' OR "
cSql += " CT2_CREDIT Like '411511043%' OR "
cSql += " CT2_CREDIT Like '411511049%' OR "
cSql += " CT2_CREDIT Like '411521043%' OR "
cSql += " CT2_CREDIT Like '411521049%' OR "
cSql += " CT2_CREDIT Like '411711043%' OR "
cSql += " CT2_CREDIT Like '411711049%' OR "
cSql += " CT2_CREDIT Like '411721043%' OR "
cSql += " CT2_CREDIT Like '411721049%' OR "
cSql += " CT2_CREDIT Like '411911043%' OR "
cSql += " CT2_CREDIT Like '411911049%' OR "
cSql += " CT2_CREDIT Like '411921043%' OR "
cSql += " CT2_CREDIT Like '411921049%' OR "

cSql += " CT2_CREDIT Like '411111053%' OR "
cSql += " CT2_CREDIT Like '411111059%' OR "
cSql += " CT2_CREDIT Like '411121053%' OR "
cSql += " CT2_CREDIT Like '411121059%' OR "
cSql += " CT2_CREDIT Like '411211053%' OR "
cSql += " CT2_CREDIT Like '411211059%' OR "
cSql += " CT2_CREDIT Like '411221053%' OR "
cSql += " CT2_CREDIT Like '411221059%' OR "
cSql += " CT2_CREDIT Like '411311053%' OR "
cSql += " CT2_CREDIT Like '411311059%' OR "
cSql += " CT2_CREDIT Like '411321053%' OR "
cSql += " CT2_CREDIT Like '411321059%' OR "
cSql += " CT2_CREDIT Like '411411053%' OR "
cSql += " CT2_CREDIT Like '411411059%' OR "
cSql += " CT2_CREDIT Like '411421053%' OR "
cSql += " CT2_CREDIT Like '411421059%' OR "
cSql += " CT2_CREDIT Like '411511053%' OR "
cSql += " CT2_CREDIT Like '411511059%' OR "
cSql += " CT2_CREDIT Like '411521053%' OR "
cSql += " CT2_CREDIT Like '411521059%' OR "
cSql += " CT2_CREDIT Like '411711053%' OR "
cSql += " CT2_CREDIT Like '411711059%' OR "
cSql += " CT2_CREDIT Like '411721053%' OR "
cSql += " CT2_CREDIT Like '411721059%' OR "
cSql += " CT2_CREDIT Like '411911053%' OR "
cSql += " CT2_CREDIT Like '411911059%' OR "
cSql += " CT2_CREDIT Like '411921053%' OR "
cSql += " CT2_CREDIT Like '411921059%' OR "

cSql += " CT2_CREDIT Like '411111063%' OR "
cSql += " CT2_CREDIT Like '411111069%' OR "
cSql += " CT2_CREDIT Like '411121063%' OR "
cSql += " CT2_CREDIT Like '411121069%' OR "
cSql += " CT2_CREDIT Like '411211063%' OR "
cSql += " CT2_CREDIT Like '411211069%' OR "
cSql += " CT2_CREDIT Like '411221063%' OR "
cSql += " CT2_CREDIT Like '411221069%' OR "
cSql += " CT2_CREDIT Like '411311063%' OR "
cSql += " CT2_CREDIT Like '411311069%' OR "
cSql += " CT2_CREDIT Like '411321063%' OR "
cSql += " CT2_CREDIT Like '411321069%' OR "
cSql += " CT2_CREDIT Like '411411063%' OR "
cSql += " CT2_CREDIT Like '411411069%' OR "
cSql += " CT2_CREDIT Like '411421063%' OR "
cSql += " CT2_CREDIT Like '411421069%' OR "
cSql += " CT2_CREDIT Like '411511063%' OR "
cSql += " CT2_CREDIT Like '411511069%' OR "
cSql += " CT2_CREDIT Like '411521063%' OR "
cSql += " CT2_CREDIT Like '411521069%' OR "
cSql += " CT2_CREDIT Like '411711063%' OR "
cSql += " CT2_CREDIT Like '411711069%' OR "
cSql += " CT2_CREDIT Like '411721063%' OR "
cSql += " CT2_CREDIT Like '411721069%' OR "
cSql += " CT2_CREDIT Like '411911063%' OR "
cSql += " CT2_CREDIT Like '411911069%' OR "
cSql += " CT2_CREDIT Like '411921063%' OR "
cSql += " CT2_CREDIT Like '411921069%' "

return csql

/*
PEONA
211111041 + 211121041 + 231111041 + 231121041
*/
//contas para o peona - crédito
static function retCTAcre4()

Local cSql := ""

cSql += " CT2_CREDIT Like '211111041%' OR "
cSql += " CT2_CREDIT Like '211121041%' OR "
cSql += " CT2_CREDIT Like '231111041%' OR "
cSql += " CT2_CREDIT Like '231121041%'  "

return cSql

//contas para o peona - débito
static function retCTAdeb4()

Local cSql := ""

cSql += " CT2_DEBITO Like '211111041%' OR "
cSql += " CT2_DEBITO Like '211121041%' OR "
cSql += " CT2_DEBITO Like '231111041%' OR "
cSql += " CT2_DEBITO Like '231121041%'  "

return cSql

//query principal do peona
static function retQry03()

Local csql := ""
Local aMeses := CalcTriMes()
Local cMesult := aMeses[Len(aMeses)][2]
Local canoUlt := aMeses[Len(aMeses)][1]
Local cIniPriMes := aMeses[1][1]+aMeses[1][2]+'01'
Local cFimUltMes := canoUlt + cMesult + '31'

cSql += " select Distinct MESTRI, SUM(VAL) TOTVAL from ( "
cSql += " Select MESTRI, SUM(A) VAL "

cSql += "  from ("
cSql += " Select distinct MESTRI, RECCT2, VALOR A from ("
cSql += " Select distinct  "
cSql += " Case "
cSql += "When CT2_DATA >= '" + canoUlt + cMesult + '01' + "' THEN '3' "
cSql += "When CT2_DATA >= '" + retDateant(@canoUlt, @cMesult) + "' then '2' "
cSql += "When CT2_DATA >= '" + retDateant(@canoUlt, @cMesult) + "' then '1' else '0' end MESTRI, "
cSql += "CONTA, VALOR, RECCT2 "

cSql += " from ( "
cSql += " Select DISTINCT  CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR "

cSql += " VALOR, CT2.R_E_C_N_O_ RECCT2  "
cSql += "  from " + RetSqlName("CT2") + " CT2  "
cSql += "  Where  "
cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' "
cSql += " AND CT2_DATA >= '" + cIniPriMes + "' "
cSql += " AND  CT2_DATA <= '" + cFimUltMes + "' "
cSql += " AND  ( "

cSql += retCTAcre4()	 

cSql += ") AND  CT2.D_E_L_E_T_ = ' '  "
cSql += " Union  "
cSql += " Select DISTINCT  CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR "
cSql += " * -1 "
cSql += " VALOR, CT2.R_E_C_N_O_ RECCT2  "
cSql += "  from " + RetSqlName("CT2") + " CT2  "
cSql += " Where  "
cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' "
cSql += " AND CT2_DATA >= '" + cIniPriMes + "' "
cSql += " AND  CT2_DATA <= '" + cFimUltMes + "' "
cSql += " AND  (  "

cSql += retCTAdeb4()	 

cSql += "	) AND  CT2.D_E_L_E_T_ = ' '  "
cSql += " ) Z "

cSql += " ) H "
cSql += " group by MESTRI, RECCT2, VALOR "
cSql += " ) K "
cSql += " Where MESTRI <> '0' "
cSql += " Group by MESTRI "
cSql += " ) X  "
cSql += " Group By MESTRI "
cSql += " Order By MESTRI "

return cSql

//Monta o Case pra separar pelo código
static function retCodMov(ntipo)

Local cSql  := ""
Local nI := 0
Local nStart := 0
Local nMax := 0
Local nMesTrimes := 3
Local nP := 0
Local nGrupo  := 0

Default ntipo :=  0

If nTipo == 3
	nStart := 65
	nMax := 78
elseif ntipo == 2
	nStart := 47
	nMax := 60
else
	nStart := 33
	nMax := 46
endIf

cSql += " Case "
for nP := 1 To 3
	cSql += " When MESTRI = '" + strzero(nMesTrimes,1) + "'  Then "
	cSql += " Case "
		nGrupo := nStart
		for nI := 1 To 16
			If nI > nP .AND. nStart < nMax
				nStart++
			endIf
			cSql += "  When  MESEXE =  '" + StrZero(nI - 1, 2) + "' Then '" + strZero(nStart,2) + "' "
		Next
		nStart := nGrupo
	cSql += " else  '"  + Strzero(nMax,2) + "' "
	cSql += " end "
	nMesTrimes--
next
cSql += " end CODMOV "

return Csql

