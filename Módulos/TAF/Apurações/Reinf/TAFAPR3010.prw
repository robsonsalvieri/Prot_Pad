#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR3010.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR3010
Função que efetua chamada da rotina de copia/apuração do evento R-1070

@return Nil

@author Helena Adrignoli Leal 
@since  28/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFAPR3010( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lSucesso, cIdTrans, lApi)
	Local lProc     as logical

	Default lSucesso := .F.
	Default lApi	 := .F.
	Default cIdTrans := ""
	
	lProc := oProcess <> nil
	
	If lProc
		oProcess:IncRegua2(STR0002)
	EndIf	
	TAFR3010COP( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, @lSucesso, cIdTrans, lApi) 	
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR3010COP
Função que copia registros Tabela T9F(Receita de Espetáculo Desportivo) - S-3010 e-Social 


@return Nil

@author Helena Adrignoli Leal
@since 28/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFR3010COP(cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lSucesso, cIdTrans, lApi)

Local aErro 		as array
Local aAreaSM0		as array
Local aProcErro		as array
Local aDadosErro 	as array

Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cFilialQry 	as character
Local cWhere		as character
Local cErro			as character
Local cVerReg		as character
Local cVerAnt		as character
Local cProtAnt		as character
Local cKeyProc 		as character

Local lErro 		as logical
Local lProc 		as logical
Local lVldProc		as logical
Local lVldData		as logical

Local nTotReg		as numeric
Local nCont			as numeric
Local nItem			as numeric
Local nOper			as numeric
Local nX			as numeric

Local nLineV0M 		as numeric 
Local nLineV0N 		as numeric 
Local nLineT9H 		as numeric 
Local nLineT9I 		as numeric 
Local nLineT9J 		as numeric 
Local nLineV0Q 		as numeric 

Local nSumValTot 	as numeric
Local nVlrReceTot	as numeric 
Local nVlrCP		as numeric 
Local nVlrRecClub	as numeric 
Local nVlrRetParc	as numeric 
Local nVlrCPSTot	as numeric
Local nErro			as numeric
Local nRecnoT9F		as numeric
Local lSkip 		as logical
Local cIdBol		as character
Local cDtApur		as character
Local cTpEvento		as character
Local oModel 		as object

Default aFiliais := {}
Default cIdTrans := ""
Default lApi	 := .F.


aErro 		:= {}
aAreaSM0 	:= SM0->(GetArea())
aProcErro	:= {}
aDadosErro  := {}

cAliasQry	:= GetNextAlias()
cFilialQry	:= ""
cErro		:= ""
cKeyProc	:= ""
cFilBkp		:= SM0->M0_CODFIL

lErro 		:= .F.
lProc 		:= oProcess <> nil
lVldData	:= .T.
lVldProc	:= .T.

nTotReg 	:= 0
nCont 		:= 1
nItem 		:= 0
nOper 		:= 3
nX	 		:= 0
nLineV0M 	:= 0
nLineV0N 	:= 0
nLineT9H 	:= 0
nLineT9I 	:= 0
nLineT9J 	:= 0
nLineV0Q 	:= 0
nErro		:= 0
nVlrReceTot	:= 0
nVlrCP		:= 0
nVlrRecClub	:= 0
nVlrRetParc	:= 0
nVlrCPSTot	:= 0
nSumValTot 	:= 0
nRecnoT9F	:= 0
lSkip		:= .T.
cIdBol		:= ""
cDtApur		:= ""
cTpEvento	:= "I"
oModel 		:= Nil


DBSelectArea("T9G")
T9G->(dBSetOrder(1))

DBSelectArea("T9H")
T9H->(dBSetOrder(1))

DBSelectArea("T9I")
T9I->(dBSetOrder(1))

DBSelectArea("T9J")
T9J->(dBSetOrder(1))

DbSelectArea("V0L")
V0L->(DbSetOrder(2))

DbSelectArea("C1G")
C1G->(DbSetOrder(8))

If !Empty(xFilial("T9F")) .And. Len(aFiliais) > 0
	
	For nX := 1 To Len(aFiliais)
		If nX <> 1 .And. nX < Len(cFilialQry)
			cFilialQry += ","
		EndIf

		cFilialQry += "'"+xFilial("T9F",aFiliais[nX][2])+"'" 
	Next
	cFilialQry := "("+cFilialQry+")"
Else
	cFilialQry := xFilial("T9F")
EndIf
	
	DBSelectArea( "T9F" )
	T9F->( DBSetOrder( 2 ) )
	
	cSelect	:= 	" T9F_FILIAL,"+;
				"T9F_ID,"+;
				"T9F_DTAPUR,"+;
				"T9F_VALTOT,"+;
				"T9F_VALPRE,"+;
				"T9F_VALCLU,"+;
				"T9F_VALRET,"+;
				"C1E_ID,"+;
				"C1E_FILIAL,"+;
				"C1E_CODFIL,"+;
				"C1E_FILTAF,"+;
				"C1E_VERSAO,"+;
				"T9F.R_E_C_N_O_"
				

 	cFrom		:= RetSqlName( "T9F" ) + " T9F " 
	cFrom		+= " INNER JOIN " + RetSqlName( "C1E" ) + " C1E "
	cFrom		+= "  ON C1E.C1E_FILTAF = T9F.T9F_FILIAL "
	cFrom		+= " AND C1E.D_E_L_E_T_ = ' ' "
	
	cWhere		:= " C1E.C1E_ATIVO IN (' ', '1') AND C1E.D_E_L_E_T_ = ' ' "
	If !Empty( xFilial("T9F") )
		cWhere		+= " AND T9F.T9F_FILIAL IN " + cFilialQry + " "
	EndIf	
	cWhere		+= " AND T9F.T9F_PROCID = ' ' "
	cWhere		+= " AND T9F.D_E_L_E_T_ = ' ' "

	if  lApi .AND. !Empty(cIdTrans)
		cWhere	+= "  AND T9F_ID IN ( " + cIdTrans + " ) "
	endIf
	
	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
		ORDER BY %Order:T9F% 
	EndSql
	
	DBSelectArea(cAliasQry)	
	(cAliasQry )->(DBEVAL({|| ++nTotReg }))
	(cAliasQry)->(DbGoTop())

	If lProc
		oProcess:SetRegua2( nTotReg )
	EndIf

	If (cAliasQry )->(!Eof())
		oModel 		:= FWLoadModel("TAFA493")
		
		DbSelectArea("T9F")
		DbSetOrder(1)
		
		If lProc
			oProcess:IncRegua2(STR0003 + cValTochar(nCont) + "/" + cValTochar(nTotReg))
		EndIf 
		
		While (cAliasQry )->(!Eof())			

			oModel:DeActivate()		
			
			cKeyProc 	:= (cAliasQry)->T9F_ID +(cAliasQry)->T9F_DTAPUR

			//---- Busca Apuração
			
			lSeekV0L := .F.
			If V0L->(dBSeek ( (cAliasQry)->T9F_FILIAL +(cAliasQry)->T9F_DTAPUR +"1"))
				lSeekV0L := .T.
			EndIf
			
			lSkip		:= .T.
			lGrava		:= .T.	  
			//cFilAnt 	:= (cAliasQry)->C1E_FILTAF
			cVerAnt	:= ""
			cProtAnt	:= ""
			cTpEvento 	:= 'I'

			nVlrReceTot	:= 0
			nVlrCP 		:= 0
			nVlrRecClub	:= 0
			nVlrRetParc	:= 0			
			nVlrCPSTot	:= 0
			
			nSumValTot	:= 0

			If lSeekV0L
				// Desativa
				If V0L->V0L_STATUS == "4" .And. V0L->V0L_EVENTO <>"E"
					cVerAnt	:= V0L->V0L_VERSAO
					cProtAnt	:= V0L->V0L_PROTUL				
					FAltRegAnt( 'V0L', '2', .F. )
					cTpEvento := 'A'
				ElseIf V0L->V0L_STATUS $ "6|2"
					lGrava	:= .F.
				ElseIf V0L->V0L_STATUS $ " |1|0|3|7" 
					// Apaga o Registro
					cVerAnt		:= V0L->V0L_VERANT
					cProtAnt	:= V0L->V0L_PROTPN
					
					//Caso o evento anterior seja do tipo 'A', o evento deve permanecer 'A'.
					If V0L->V0L_EVENTO == 'A'
						cTpEvento := 'A'
					Else
						cTpEvento := 'I'
					EndIf

					oModel:SetOperation(MODEL_OPERATION_DELETE)
					oModel:Activate()
					FwFormCommit( oModel )
					oModel:DeActivate()
				EndIf
			EndIf

			If lGrava
				cVerReg := xFunGetVer()
								
				//---- Sempre será uma inclusão
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				
				oModel:GetModel( 'MODEL_V0L' )
				oModel:LoadValue('MODEL_V0L',	"V0L_VERSAO"	, cVerReg)	
				//oModel:LoadValue('MODEL_V0L',	"V0L_FILIAL"	, (cAliasQry)->T9F_FILIAL)
				oModel:LoadValue('MODEL_V0L',	"V0L_ID"		, (cAliasQry)->T9F_ID)
				oModel:LoadValue('MODEL_V0L',	"V0L_DTAPUR"	, StoD((cAliasQry)->T9F_DTAPUR))
				oModel:LoadValue('MODEL_V0L', 	"V0L_EVENTO"	, cTpEvento )				
				
				If !Empty(cVerAnt)
					oModel:LoadValue('MODEL_V0L', "V0L_VERANT"	, cVerAnt )
					oModel:LoadValue('MODEL_V0L', "V0L_PROTPN"	, cProtAnt )
				EndIf

				nRecnoT9F		:= (cAliasQry)->R_E_C_N_O_
				nLineV0M		:= 0
				nLineV0Q		:= 0
												
				While (cAliasQry )->(!Eof()) .and. cKeyProc == (cAliasQry)->T9F_ID +(cAliasQry)->T9F_DTAPUR 						
					
					If !Empty( (cAliasQry)->T9F_ID )
						
							nSumValTot	+= (cAliasQry)->T9F_VALTOT
							nVlrCP 		+= (cAliasQry)->T9F_VALPRE
							nVlrRecClub	+= (cAliasQry)->T9F_VALCLU
							nVlrRetParc	+= (cAliasQry)->T9F_VALRET
							 
							If nLineV0M > 0
								oModel:GetModel( "MODEL_V0M" ):lValid:= .T.
								oModel:GetModel( "MODEL_V0M" ):AddLine()
							EndIf

							oModel:LoadValue('MODEL_V0M',	"V0M_TPINSC" 	, '1')	//tpInscEstab 
							oModel:LoadValue('MODEL_V0M',	"V0M_NRINSC"	, Posicione("SM0", 1, Alltrim( (cAliasQry)->C1E_CODFIL), "M0_CGC")) //nrInscEstab	
							nLineV0M++
																	
							If T9G->(MsSeek((cAliasQry)->C1E_FILTAF+(cAliasQry)->(T9F_ID+T9F_DTAPUR)))
							
								nLineV0N := 0						
								While T9G->(!EOF()) .and. T9G->(T9G_FILIAL + T9G_ID + DTOS(T9G_DTAPUR) ) == ((cAliasQry)->C1E_FILTAF + (cAliasQry)->(T9F_ID + T9F_DTAPUR))
									If nLineV0N > 0
										oModel:GetModel( "MODEL_V0N" ):lValid:= .T.
										oModel:GetModel( "MODEL_V0N" ):AddLine()
									EndIf
									
									If Empty(T9G->T9G_CNPJVI) .and. Empty(T9G->T9G_NOMVIS)
										//Validação {nomeVisitante}: Preenchimento obrigatório se não preencher {cnpjVisitante}
										lVldData := .F. 
										Aadd(aDadosErro, { T9G->T9G_ID, T9G->T9G_DTAPUR , STR0015 + CRLF + ; //"Nome visitante {nomeVisitante} deve ser informado se não preencher o CNPJ do visitante {cnpjVisitante}. "
																						  STR0011 + T9G->T9G_NUMBOL}) // "Boletim: "
									EndIf
									
									oModel:LoadValue('MODEL_V0N',	"V0N_NRBOLE" 	, T9G->T9G_NUMBOL)//nrBoletim
									oModel:LoadValue('MODEL_V0N',	"V0N_TPCOMP"	, T9G->T9G_TPCOMP)//tpCompeticao	
									oModel:LoadValue('MODEL_V0N',	"V0N_CATEVT"	, T9G->T9G_CATEVE)//categEvento
									oModel:LoadValue('MODEL_V0N',	"V0N_MODDES"	, T9G->T9G_MODDES)//modDesportiva
									oModel:LoadValue('MODEL_V0N',	"V0N_NOMCOM"	, T9G->T9G_NOMCOM)//nomeCompeticao
									oModel:LoadValue('MODEL_V0N',	"V0N_CNPJMA"	, T9G->T9G_CNPJMA)//cnpjMandante
									oModel:LoadValue('MODEL_V0N',	"V0N_CNPJVI"	, T9G->T9G_CNPJVI)//cnpjVisitante
									oModel:LoadValue('MODEL_V0N',	"V0N_NOMVIS"	, Substr(T9G->T9G_NOMVIS,1,80))//nomeVisitante
									oModel:LoadValue('MODEL_V0N',	"V0N_PRACAD"	, T9G->T9G_PRADES)//pracaDesportiva
									oModel:LoadValue('MODEL_V0N',   "V0N_IDCMUN"	, T9G->T9G_CODMUN)//IdCodMunic															
									oModel:LoadValue('MODEL_V0N',   "V0N_CODMUN"	, POSICIONE("C07",3, xFilial("C07")+T9G->T9G_CODMUN,"C07_CODIGO"))//codMunic
									oModel:LoadValue('MODEL_V0N',	"V0N_IDUF"		, T9G->T9G_UF)//IdUF	
									oModel:LoadValue('MODEL_V0N',	"V0N_UF"		, POSICIONE("C09",3, xFilial("C09")+T9G->T9G_UF,"C09_UF"))	  //UF
									oModel:LoadValue('MODEL_V0N',	"V0N_QTDPAG"	, cValToChar(T9G->T9G_PAGANT))//qtdePagantes
									oModel:LoadValue('MODEL_V0N',	"V0N_QTDNPA"	, cValToChar(T9G->T9G_NPAGAN))//qtdeNaoPagantes													
									
									If T9H->(DbSeek((cAliasQry)->C1E_FILTAF + T9G->(T9G_ID + DTOS(T9G_DTAPUR) + T9G_NUMBOL + T9G_TPCOMP + T9G_CATEVE)))
										nLineT9H := 0
										While T9H->(!EOF()) .and. T9H->(T9H_FILIAL+ T9H_ID + DTOS(T9H_DTAPUR) + T9H_NUMBOL + T9H_TPCOMP + T9H_CATEVE) == ((cAliasQry)->C1E_FILTAF + T9G->(T9G_ID + DTOS(T9G_DTAPUR) + T9G_NUMBOL + T9G_TPCOMP + T9G_CATEVE))
										
											If  nLineT9H > 0
												oModel:GetModel( "MODEL_V0O" ):lValid:= .T.
												oModel:GetModel( "MODEL_V0O" ):AddLine()
											EndIf
											
											If T9H->T9H_QTDVDO > T9H->T9H_QTDVDA
												//Validação {qtdeIngrVendidos}: Não pode ser superior ao valor informado em {qtdeIngrVenda}
												lVldData := .F. 
												Aadd(aDadosErro, { T9H->T9H_ID, T9H->T9H_DTAPUR , STR0012 + CRLF + ; //"Qtd. vendidos {qtdeIngrVendidos} não pode ser superior ao valor informado em Qtd. a venda {qtdeIngrVenda}. "
																								  STR0011 + T9H->T9H_NUMBOL}) // "Boletim: "
												
											EndIf

											If T9H->T9H_QTDDEV > T9H->T9H_QTDVDA
												//Validação {qtdeIngrDev}: Não pode ser superior ao valor informado em {qtdeIngrVenda}
												lVldData := .F. 
												Aadd(aDadosErro, { T9H->T9H_ID, T9H->T9H_DTAPUR , STR0013 + CRLF + ;  //"Qtd. devolvidos {qtdeIngrDev} não pode ser superior ao valor informado em Qtd. a venda {qtdeIngrVenda}. "
																								  STR0011 + T9H->T9H_NUMBOL}) // "Boletim: "
												
											EndIf
											
											If T9H->T9H_VLRTOT != T9H->(T9H_QTDVDO * T9H_PREIND)
												//Validação {vlrTotal}: Deve corresponder a {qtdeIngrVendidos} x {precoIndiv}
												lVldData := .F. 
												Aadd(aDadosErro, { T9H->T9H_ID, T9H->T9H_DTAPUR , STR0014+ CRLF + ; //"Vlr total {vlrTotal} deve corresponder a Qtd. vendidos {qtdeIngrVendidos} x Preço Indiv {precoIndiv}. " 
																								  STR0011 + T9H->T9H_NUMBOL}) // "Boletim: "
												
											EndIf											
											
											nLineT9H++									
											oModel:LoadValue('MODEL_V0O',	"V0O_SEQUEN"	, StrZero(nLineT9H,3))//Sequencial							
											oModel:LoadValue('MODEL_V0O',	"V0O_TPINGR"	, T9H->T9H_TPINGR)//tpIngresso
											oModel:LoadValue('MODEL_V0O',	"V0O_DESCIN"	, Substr(T9H->T9H_INGRES,1,30))//descIngr	
											oModel:LoadValue('MODEL_V0O',	"V0O_QTDING"	, cValToChar(T9H->T9H_QTDVDA))//qtdeIngrVenda
											oModel:LoadValue('MODEL_V0O',	"V0O_QTDIVE"	, cValToChar(T9H->T9H_QTDVDO))//qtdeIngrVendidos
											oModel:LoadValue('MODEL_V0O',	"V0O_QTDIDE"	, cValToChar(T9H->T9H_QTDDEV))//qtdeIngrDev
											oModel:LoadValue('MODEL_V0O',	"V0O_PRECOI"	, T9H->T9H_PREIND)//precoIndiv
											oModel:LoadValue('MODEL_V0O',	"V0O_VLRTOT"	, T9H->T9H_VLRTOT)//vlrTotal		
											
											//vlrReceitaTotal = soma de {vlrTotal} de{receitaIngressos} e de {vlrReceita} de {outrasReceitas}
											nVlrReceTot	+= T9H->T9H_VLRTOT //vlrReceitaTotal
											
											T9H->(DbSkip())	
										EndDo
									EndIf
													
									If T9I->(DbSeek((cAliasQry)->C1E_FILTAF + T9G->(T9G_ID + DTOS(T9G_DTAPUR) + T9G_NUMBOL + T9G_TPCOMP + T9G_CATEVE)))
										nLineT9I := 0
										While T9I->(!EOF()) .and. T9I->(T9I_FILIAL + T9I_ID + DTOS(T9I_DTAPUR) + T9I_NUMBOL + T9I_TPCOMP + T9I_CATEVE) == ((cAliasQry)->C1E_FILTAF + T9G->(T9G_ID + DTOS(T9G_DTAPUR) + T9G_NUMBOL + T9G_TPCOMP + T9G_CATEVE))
										
											If  nLineT9I > 0
												oModel:GetModel( "MODEL_V0P" ):lValid:= .T.
												oModel:GetModel( "MODEL_V0P" ):AddLine()
											EndIf
																						
											nLineT9I++	
											oModel:LoadValue('MODEL_V0P',	"V0P_SEQUEN"	, StrZero(nLineT9I,3))//Sequencial					
											oModel:LoadValue('MODEL_V0P',	"V0P_TPRECE"	, T9I->T9I_TPREC)//tpReceita
											oModel:LoadValue('MODEL_V0P',	"V0P_VLRREC"	, T9I->T9I_VALREC)//vlrReceita	
											oModel:LoadValue('MODEL_V0P',	"V0P_DESREC"	, Substr(T9I->T9I_DESREC,1,20))//descReceita																						
											
											//vlrReceitaTotal = soma de {vlrTotal} de{receitaIngressos} e de {vlrReceita} de {outrasReceitas}
											nVlrReceTot	+= T9I->T9I_VALREC //vlrReceitaTotal
											
											T9I->(DbSkip())	
										EndDo
									EndIf
									
									nLineV0N++
									T9G->(DbSkip())	
								EndDo																		
							EndIf
							
							If T9J->(DbSeek((cAliasQry)->C1E_FILTAF+(cAliasQry)->(T9F_ID + T9F_DTAPUR)))
								nLineT9J := 0
								While T9J->(!EOF()) .and. T9J->(T9J_FILIAL + T9J_ID + DTOS(T9J_DTAPUR)) == ((cAliasQry)->C1E_FILTAF + (cAliasQry)->(T9F_ID + T9F_DTAPUR))
									if !C1G->(DbSeek(T9J->T9J_FILIAL+T9J->T9J_IDPROC+"1"))	//Procuro o processo na filial de origem do movimento
										If C1G->(DbSeek(xFilial("C1G")+T9J->T9J_IDPROC+"1")) //Se não encontrar, procuro o processo na matriz (filial logada)
												
											T9V->(DbSetOrder(5))
											If !T9V->(DbSeek(xFilial("T9V") + C1G->C1G_ID + "1")) //Procura o processo na filial logada, pois a apuração ocorreu na matriz
												lVldProc := .F. 
												Aadd(aProcErro,{Alltrim(C1G->C1G_NUMPRO), "PROCESSO NAO ENCONTRADO" }  )
											EndIf
										Else
											lVldProc := .F. 
											Aadd(aProcErro,{Alltrim(T9J->T9J_IDPROC), "ID PROCESSO NAO ENCONTRADO" }  )
										Endif
									Endif
											
									If nLineT9J > 0
										oModel:GetModel( "MODEL_V0R" ):lValid:= .T.
										oModel:GetModel( "MODEL_V0R" ):AddLine()
									EndIf
									 
									nVlrCPSTot += T9J->T9J_VLRSUS
									
									nLineT9J++		
									oModel:LoadValue('MODEL_V0R',	"V0R_IDPROC"	, T9J->T9J_IDPROC) //"IdProc"											
									oModel:LoadValue('MODEL_V0R',	"V0R_TPPROC"	, IiF( C1G->C1G_TPPROC=="1","2","1")  )//"tpProc"
									oModel:LoadValue('MODEL_V0R',	"V0R_NUMPRO"	, C1G->C1G_NUMPRO) //"nrProc"
									oModel:LoadValue('MODEL_V0R',	"V0R_CODSUS"	, POSICIONE("T5L",1,xFilial("TSL")+T9J->T9J_IDSUSP,"T5L_CODSUS")) //"codSusp"	
							   	  	oModel:LoadValue('MODEL_V0R',	"V0R_VLRSUS"	, T9J->T9J_VLRSUS) //"vlrCPSusp"	   	  	
							   	  	
							   	  	If !oModel:GetModel( "MODEL_V0R" ):VldData() 	
							   	  		lVldProc := .F. 
										Aadd(aProcErro,{Alltrim(C1G->C1G_NUMPRO), TafRetEMsg(oModel)}  )
							   	  	EndIf
							   	  	
									T9J->(DbSkip())	
								EndDo
							EndIf
																								
						
						If lProc 
							oProcess:IncRegua2(STR0003 + cValTochar(nCont++) + "/" + cValTochar(nTotReg))
						EndIf 	
						
						nLineV0M++
					EndIF		
					
					cIdBol		:= (cAliasQry)->T9F_ID
					cDtApur		:= (cAliasQry)->T9F_DTAPUR
					
					( cAliasQry )->(DbSkip())
					
					If cKeyProc != (cAliasQry)->T9F_ID + (cAliasQry)->T9F_DTAPUR .or. (cAliasQry)->(Eof())
						lSkip		:= .F.
					EndIf	
					
				EndDo	
						
				If nVlrReceTot != nSumValTot
					//Validação {vlrReceitaTotal}: Deve corresponder a soma de {vlrTotal} de{receitaIngressos} e de {vlrReceita} de {outrasReceitas} que estejam vinculados ao mesmo estabelecimento
					lVldData := .F. 
					Aadd(aDadosErro, {cIdBol, STOD(cDtApur) , STR0016 }) //"A soma de {vlrTotal} de {receitaIngressos} e de {vlrReceita} de {outrasReceitas} não corresponde ao informado em Val Rec Brut {vlrReceitaTotal}." 
				EndIf						
				
				nLineV0Q ++
				oModel:GetModel( "MODEL_V0Q" ):lValid:= .T.
				oModel:LoadValue('MODEL_V0Q',	"V0Q_SEQUEN"	, StrZero(nLineV0Q,3))//Sequencial
				oModel:LoadValue('MODEL_V0Q',	"V0Q_VLRTOT"	, nVlrReceTot)//vlrReceitaTotal
				oModel:LoadValue('MODEL_V0Q',	"V0Q_VLRCP"		, nVlrCP)//vlrCP
				oModel:LoadValue('MODEL_V0Q',	"V0Q_VLRRCL"	, nVlrRecClub)//vlrReceitaClubes
				oModel:LoadValue('MODEL_V0Q',	"V0Q_VLRRET"	, nVlrRetParc)//vlrRetParc
				oModel:LoadValue('MODEL_V0Q',	"V0Q_VLRCPS"	, nVlrCPSTot)//vlrCPSuspTotal
				
				If lVldData .And. oModel:VldData() .And. lVldProc
					FwFormCommit( oModel )
					//grava procid na tabela legado
					TafEndGRV( "T9F","T9F_PROCID", cIdLog, nRecnoT9F  )
					
					//grava procid na tabela espelho
					TafEndGRV( "V0L","V0L_PROCID", cIdLog, V0L->(Recno()))
					
					TafXLog( cIdLog, cEvento, "MSG"			, STR0017+CRLF+cKeyProc ) //"Registro Gravado com sucesso."
					lSucesso 	:= .T.
				Else
					lSucesso 	:= .F.	
					
					If ! lVldProc
						cErro		:= ""
						For nErro := 1 to Len(aProcErro)
							cErro	+= STR0008 + CRLF
							cErro	+= STR0007 + CRLF
							cErro	+= STR0005 + Alltrim(aProcErro[nErro][1]) + Alltrim(aProcErro[nErro][2])  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-3010. Regra de predecessão não atendida."	
						Next nErro	
						
						Aadd(aErro, {"R-3010", "ERRO", cErro})
					EndIf
					
					If !lVldData
						cErro		:= ""
						For nErro := 1 to Len(aDadosErro)
							cErro	:= STR0008 + CRLF
							cErro	+= STR0007 + CRLF
							cErro	+= STR0009 + Alltrim(aDadosErro[nErro][1]) + CRLF  // "ID Boletim: "
							cErro	+= STR0010 + DTOC(aDadosErro[nErro][2])  + CRLF // "Data Boletim: "
							cErro	+= aDadosErro[nErro][3]    
							
							Aadd(aErro, {"R-3010", "ERRO", cErro})	
						Next nErro	
						
												
					EndIf

					For nErro := 1 to Len (aErro) 
						TafXLog(cIdLog, aErro[nErro][1], aErro[nErro][2], STR0018 + CRLF + aErro[nErro][3] ) //"Mensagem do erro: "
					Next nErro

				EndIf

				oModel:DeActivate()
			Else
				cFilAnt := cFilBkp
				TafXLog( cIdLog, cEvento, "ALERTA"			, STR0019+ CRLF + cKeyProc ) //"Evento transmitido e aguardando retorno:"										
			
			EndIf

			If lSkip			
				( cAliasQry )->(DbSkip())
			EndIf		
		
		EndDo

	EndIf
	(cAliasQry)->(DbCloseArea())	
	cFilAnt := cFilBkp
	RestArea(aAreaSM0)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Qury3010
Registro R-3010 da Reinf

@author Roberto Souza
@since  02/04/2018
@version 1.0
@return Retorna a string da query

/*/ 
//-------------------------------------------------------------------
 
Function Qury3010( cPerApu, lApur, lIdProc, aFil, aInfEUF, aMovs, lApi )

	Local cFiliais	As 	Character
	Local cQuery 	As 	Character
	Local cBd		As 	Character
	Local cAliasApr As	Character
	Local cSelect	As	Character
	Local cWhere	As	Character
	Local cOrder 	As	Character
	Local cCmpQry	As 	Character
	Local cFromT9F	As	Character
	Local cIJoinC1E	As 	Character
	Local aRegApur	As 	Array

	Default cPerApu	:= ""	
	Default aInfEUF := {}
	Default aMovs	:= {}
	Default lApi 	:= .F.

	cFiliais	:= TafRetFilC("T9F", aFil) 
	cQuery		:= ""
	cBd			:= alltrim(TcGetDb())
	cAliasApr	:= GetNextAlias()
	cSelect		:= ""
	cWhere		:= ""
	cOrder		:= ""
	cCmpQry		:= ""
	cFromT9F	:= ""
	cIJoinC1E	:= ""
	aRegApur	:= {}

	If lApur
		cSelect	:= 	" T9F_FILIAL,T9F_ID,T9F_DTAPUR,T9F_VALTOT,T9F_VALPRE,T9F_VALCLU,T9F_VALRET,C1E_ID,C1E_FILIAL,C1E_CODFIL,C1E_FILTAF,C1E_VERSAO, T9F.R_E_C_N_O_ "
	Else 
		cSelect	:= " COUNT(*) TOTAL "
	EndIf

	cFromT9F	:= RetSqlName( "T9F" ) + " T9F "
	cIJoinC1E	:= RetSqlName( "C1E" ) + " C1E ON C1E.D_E_L_E_T_ = ' '"
	cIJoinC1E	+= " AND C1E.C1E_FILTAF = T9F.T9F_FILIAL "
	cIJoinC1E	+= " AND C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' "
	
	cIJoinC1E	+= " AND C1E.C1E_ATIVO IN (' ', '1') "

	cWhere		:= " T9F.D_E_L_E_T_ = ' ' "	 
	if !lApur .and. lApi
		cWhere		+= " AND T9F.T9F_FILIAL IN " + cFiliais + " "
	else
		cWhere		+= " AND T9F.T9F_FILIAL = '" + xFilial('T9F') + "' "	
	endIf 

	If !lApur
		If lIdProc
			cWhere	+= " AND T9F.T9F_PROCID <> '' "
		Else
			cWhere	+= " AND T9F.T9F_PROCID = '' "
		EndIf
	Else
		cWhere		+= " AND T9F.T9F_PROCID = ' ' "		
	EndiF

	if cBd $ 'ORACLE|DB2'
		cWhere += " AND SUBSTR(T9F.T9F_DTAPUR,1,6) = '" + cPerApu + "' "
	elseif cBd == 'INFORMIX'
		cWhere += " AND T9F.T9F_DTAPUR[1,6] = '" + cPerApu + "' "
	else
		cWhere += " AND left(T9F.T9F_DTAPUR,6) = '" + cPerApu + "' "
	endif

	If lApur
		cSelect	:= "%" + cSelect		+ "%"
		cFromT9F	:= "%" + cFromT9F		+ "%"
		cIJoinC1E	:= "%" + cIJoinC1E	+ "%"
		cWhere		:= "%" + cWhere		+ "%"

		BeginSql Alias cAliasApr
	
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFromT9F%
			INNER JOIN
				%Exp:cIJoinC1E%
			WHERE
				%Exp:cWhere%
		EndSql

		aRegApur := {{cAliasApr}}
	Else
		cQuery := cSelect + ' FROM ' + cFromT9F + ' INNER JOIN ' + cIJoinC1E + ' WHERE ' + cWhere
		aadd( aRegApur, {cQuery} )
	EndIf

Return( aRegApur )
