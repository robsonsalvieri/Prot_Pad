#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR1070.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR1070
Função que efetua chamada da rotina de copia/apuração do evento R-1070

@return Nil

@author Helena Adrignoli Leal 
@since  19/02/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFAPR1070( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lValid, cNumProc, lSucesso )
	
	Local lProc     as logical	
	Local nQtdFil   as numeric
	Local nMatriz   as numeric
	Local cCompC1G  as character
	Local cCompT9V  as character

	cCompC1G	:= Upper( AllTrim( FWModeAccess( "C1G", 1 ) + FWModeAccess( "C1G", 2 ) + FWModeAccess( "C1G", 3 ) ) )  // 1=Empresa, 2=Unidade de Negócio e 3=Filial
	cCompT9V	:= Upper( AllTrim( FWModeAccess( "T9V", 1 ) + FWModeAccess( "T9V", 2 ) + FWModeAccess( "T9V", 3 ) ) )  // 1=Empresa, 2=Unidade de Negócio e 3=Filial

	If cCompC1G == cCompT9V

		nQtdFil  := IIF( cCompC1G == "CCC", 1, Len( aFiliais ) ) // Se o modo de acesso da C1G for compartilhado, não é necessário rodar a query de apuração ( TAFR1070COP ) para todas as filiais marcadas
		lProc    := oProcess <> nil
		
		If lProc
			oProcess:IncRegua2(STR0002)
		EndIf

		nMatriz := aScan( aFiliais, {|x| x[07] })

		If nMatriz > 0
			cIdMatriz 	:= aFiliais[nMatriz][01]
		Else
			cIdMatriz := GetAdvFVal( "C1E", "C1E_ID", xFilial( "C1E" ) + cFilAnt + "1", 3 )
		EndIf

		TAFR1070COP( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, oProcess, lValid, cIdMatriz, cNumProc, @lSucesso, nQtdFil, aFiliais)

	Else
		TafXLog( cIdLog, cEvento, "ERRO", STR0004, cPeriodo ) // "Tabelas de Cadastro 'Procs Referenciado' ( C1G e T5L ) e tabelas de apuração 'R-1070 - Processos Adm/Judiciais' ( T9V e T9X ) obrigatoriamente devem ter o mesmo nível de compartilhamento."
	EndIf

Return Nil



//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA495COP
Função que copia registros Tabela C1G(Processo) - S-1070 e-Social 


@return Nil

@author Helena Adrignoli Leal
@since 19/02/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFR1070COP(cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, oProcess, lValid, cIdMatriz, cNumProc, lSucesso, nQtdFil, aFiliais) 

Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cOrder		as character
Local cFilialQry 	as character
Local cWhere		as character
Local cErro			as character
Local cVerReg		as character
Local cVerAnt		as character
Local cProtAnt		as character
Local cKeyProc 		as character
Local cKeyLog		as character
Local cTpProc		as character
Local nTotReg		as numeric
Local nCont			as numeric
Local nItem			as numeric
Local nOper			as numeric
Local nX			as numeric
Local nY			as numeric
Local nLine 		as numeric 
Local nAux			as numeric
Local oModel 		as object
Local oModelT9X		as object
Local AutoGrLog		as array
Local aErro 		as array
Local aKeyPro		as array
Local lErro 		as logical
Local lProc 		as logical
Local lDelet		as logical
Local nRecnoOri		as numeric 
Local cLogErr		as character
Local aLogErro 		as array
Local aDadosUtil	as array
Local aCpos			as array
Local cAmbReinf		as character
Local cTpEvento		as character
Local cFilC1G       as character
Local aIN			as array

Default lValid		:= .F.	
Default lSucesso	:= .F.	

cAliasQry 	:= GetNextAlias()
cFilialQry	:= ""
cErro		:= ""
cOrder		:= ""
lProc 		:= oProcess <> nil
nTotReg 	:= 0
nCont 		:= 1
nAux		:= 0
nItem 		:= 0
nOper 		:= 3
nX	 		:= 0
nLine 		:= 0
AutoGrLog 	:= aErro := {}
oModel 		:= Nil
oModelT9X	:= Nil
cKeyProc	:= ""
cKeyLog		:= ""
lErro 		:= .F.
lDelet		:= .F.
cFilBkp		:= SM0->M0_CODFIL
aDadosUtil	:= {}
aKeyPro		:= {}
cTpProc		:= ""
aCpos		:= {}
cAmbReinf	:= Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
cTpEvento	:= "I"
aIN			:= Array(4)

	aIN[1] := "C09"
	aIN[2] := "C07" 
	aIN[3] := "C8S" 
	aIN[4] := "C1G"

	FilialIN(@aIN, aFiliais, nQtdFil)
	aIN[4] := TafRetFilC("C1G", aFiliais)

	DBSelectArea( "C1G" )
	T9V->( DBSetOrder( 1 ) )

	aCpos 		:= TafR1070Cpo()

	cSelect		:= " "+ aCpos[01] + " "
 	cFrom		:= RetSqlName( "C1G" ) + " C1G " 
	cFrom		+= " INNER JOIN " + RetSqlName( "T5L" ) + " T5L "
	cFrom		+= "  ON T5L.T5L_ID = C1G.C1G_ID "
	cFrom		+= " AND T5L.T5L_VERSAO = C1G.C1G_VERSAO "
	cFrom		+= " AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "
	cFrom		+= " AND T5L.D_E_L_E_T_ = ' '"
	 
	cFrom		+= " LEFT JOIN " + RetSqlName( "C09" ) + " C09 "
	cFrom		+= "  ON C09.C09_ID = C1G.C1G_UFVARA "
	cFrom		+= " AND C09.C09_FILIAL IN " + aIN[1]
	cFrom		+= " AND C09.D_E_L_E_T_ = ' ' "
	
	cFrom		+= " LEFT JOIN  " + RetSqlName( "C07" ) + " C07 "
	cFrom		+= "  ON C07.C07_ID = C1G.C1G_CODMUN "
	cFrom		+= " AND C07.C07_FILIAL IN " + aIN[2]
	cFrom		+= " AND C07.D_E_L_E_T_ = ' ' "
		 
	cFrom		+= " LEFT JOIN " + RetSqlName( "C8S" ) + " C8S "
	cFrom		+= "  ON C8S.C8S_ID = T5L.T5L_INDDEC "
	cFrom		+= " AND C8S.C8S_FILIAL IN " + aIN[3] 
	cFrom		+= " AND C8S.D_E_L_E_T_ = ' ' "
	
	cWhere		:= " C1G.C1G_ATIVO IN (' ', '1') AND C1G.D_E_L_E_T_ = ' ' "
	If !Empty( xFilial("C1G") )
		cWhere		+= " AND C1G.C1G_FILIAL IN " + aIN[4]
	EndIf

	If !Empty(cNumProc)
        cWhere    += " AND C1G_NUMPRO in ('" + cNumProc + "') " 
	EndIf
	
	cWhere		+= " AND C1G.C1G_ESOCIA = '' "
	cWhere		+= " AND C1G.C1G_PROCID = '' "

	cOrder		:= " C1G_NUMPRO, C1G_INDPRO "
	
	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%" 
	cWhere 	:= "%" + cWhere  	+ "%"
	cOrder	:= "%" + cOrder  	+ "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
		ORDER BY %Exp:cOrder% 
	EndSql
	
	DBSelectArea(cAliasQry)	
	(cAliasQry )->(DBEVAL({|| ++nTotReg }))
	(cAliasQry)->(DbGoTop())

	If lProc
		oProcess:SetRegua2( nTotReg )
	EndIf

	If (cAliasQry )->(!Eof())
		oModel 		:= FWLoadModel("TAFA495")
		
		DbSelectArea("T9V")
		DbSetOrder(1)
		
		If lProc
			oProcess:IncRegua2(STR0003 + cValTochar(nCont) + "/" + cValTochar(nTotReg))
		EndIf 
		
		While (cAliasQry )->(!Eof())			

			oModel:DeActivate()		
			
			cFilC1G := (cAliasQry)->C1G_FILIAL

			cKeyProc 	:= (cAliasQry)->C1G_NUMPRO
			nLine		:= 0
			cTpProc 	:= IiF( (cAliasQry)->C1G_TPPROC=="1","2","1")
			
			cKeyLog		:= "Id.............: "+(cAliasQry)->C1G_ID + CRLF
			cKeyLog		+= "Versão.........: "+(cAliasQry)->C1G_VERSAO +CRLF
			cKeyLog		+= "Tipo Processo..: "+ IIf( cTpProc =="1","Administrativo",IIf( cTpProc =="2","Judicial","Inválido"))

			//---- Busca Apuração
			lSeekT9V	:= .F.
			nRecnoOri	:= foundVerOri("T9V",cFilAnt,(cAliasQry)->C1G_ID,(cAliasQry)->C1G_VERSAO )
			If nRecnoOri > 0
				T9V->(DBGoto(nRecnoOri) )
				lSeekT9V := .T.
			EndIf
			lGrava		:= .T.
			cKeyC1G		:= cFilC1G+(cAliasQry)->C1G_ID+"1"
			cVerAnt		:= ""
			cProtAnt	:= ""
			cTpEvento 	:= 'I'
			lDelet 		:= .F.

			If lSeekT9V
				//Aguardando retorno transmissão e exclussão
				If T9V->T9V_STATUS == "2" .Or. T9V->T9V_STATUS == "6"
					lGrava	:= .F.
				else
					//Sobrepor inclusao simples não transmitida
					if T9V->T9V_EVENTO == "I" .And. ( Empty(T9V->T9V_STATUS) .Or. T9V->T9V_STATUS == "0" .Or. T9V->T9V_STATUS == "1" .Or. T9V->T9V_STATUS == "3" )
						cTpEvento 	:= 'I'
						lDelet 		:= .T.
					//Sobrepor alteração não transmitida
					elseif T9V->T9V_EVENTO == "A" .And. Empty( T9V->T9V_STATUS )
						cVerAnt	 	:= T9V->T9V_VERANT 	//herda do pai
						cProtAnt 	:= T9V->T9V_PROTPN 	//herda do pai
						cTpEvento 	:= 'A'
						lDelet 		:= .T.
					//Nova inclusão após efetivação da exclusão, é considerado como inclusão
					elseif T9V->T9V_EVENTO == "E" .And. T9V->T9V_STATUS == "7"
						//cVerAnt	:= T9V->T9V_VERANT 	//herda do pai
						//cProtAnt 	:= T9V->T9V_PROTPN 	//herda do pai
						cVerAnt	 	:= " "	//não herda do pai
						cProtAnt 	:= " " 	//não herda do pai
						FAltRegAnt( 'T9V', '2', .F. ) 	//inativo anterior
						cTpEvento	:= 'I'
						lDelet 		:= .F.
					//Nova inclusão após exclusão sem transmissão, é considerado como alteracao
					elseif T9V->T9V_EVENTO == "E" .And. Empty( T9V->T9V_STATUS )
						cVerAnt	 	:= T9V->T9V_VERANT 	//herda do pai
						cProtAnt 	:= T9V->T9V_PROTPN 	//herda do pai
						FAltRegAnt( 'T9V', '2', .F. ) 	//inativo anterior
						cTpEvento	:= 'A'
						lDelet 		:= .F.
					//Alteracao após transmissão
					elseIf T9V->T9V_STATUS == "4" .And. ( T9V->T9V_EVENTO == "I" .Or. T9V->T9V_EVENTO == "A" )
						cVerAnt		:= T9V->T9V_VERSAO 	//primeiro filho
						cProtAnt 	:= T9V->T9V_PROTUL 	//primeiro filho
						FAltRegAnt( 'T9V', '2', .F. )	//inativo anterior
						cTpEvento 	:= 'A'
						lDelet 		:= .F.
					endif
					if lDelet
						oModel:SetOperation(MODEL_OPERATION_DELETE)
						oModel:Activate()
						FwFormCommit( oModel )
						oModel:DeActivate()
					endif
				endif
			endif

			AADD( aDadosUtil, { cIdMatriz , ;
								(cAliasQry)->C1G_DTINI, ;
								(cAliasQry)->C1G_DTFIN,	;
								(cAliasQry)->C1G_ID  ;
								}  )

			cLogErr := ProcValid( @aLogErro, aDadosUtil )

			If !Empty( cLogErr )
				If lValid
					lGrava := .F.
				Else
					TafXLog( cIdLog, cEvento, "ALERTA"			, cLogErr+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo )																
				EndIf
			EndIf

			If lGrava

				cVerReg := xFunGetVer()
				
				//---- Sempre será uma inclusão
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()

				oModel:GetModel( 'MODEL_T9V' )
				oModel:LoadValue('MODEL_T9V', "T9V_ID"		, (cAliasQry)->C1G_ID)
				oModel:LoadValue('MODEL_T9V', "T9V_VERSAO"	, cVerReg )
				oModel:LoadValue('MODEL_T9V', "T9V_TPPROC"	, cTpProc  )
				oModel:LoadValue('MODEL_T9V', "T9V_NUMPRO"	, (cAliasQry)->C1G_NUMPRO)
				oModel:LoadValue('MODEL_T9V', "T9V_DTINI"	, (cAliasQry)->C1G_DTINI)
				oModel:LoadValue('MODEL_T9V', "T9V_DTFIN"	, (cAliasQry)->C1G_DTFIN)
				oModel:LoadValue('MODEL_T9V', "T9V_INDAUD"	, (cAliasQry)->C1G_INDAUT)
				oModel:LoadValue('MODEL_T9V', "T9V_IDUFVA"	, (cAliasQry)->C1G_UFVARA)
				oModel:LoadValue('MODEL_T9V', "T9V_CDUFVA"	, (cAliasQry)->C09_UF)
				oModel:LoadValue('MODEL_T9V', "T9V_DSUFVA"	, (cAliasQry)->C09_DESCRI)
				oModel:LoadValue('MODEL_T9V', "T9V_IDMUNI"	, (cAliasQry)->C1G_CODMUN)
				oModel:LoadValue('MODEL_T9V', "T9V_CDMUNI"	, (cAliasQry)->C07_CODIGO)
				oModel:LoadValue('MODEL_T9V', "T9V_DSMUNI"	, (cAliasQry)->C07_DESCRI)
				oModel:LoadValue('MODEL_T9V', "T9V_IDVARA"	, AllTrim((cAliasQry)->C1G_VARA))
				oModel:LoadValue('MODEL_T9V', "T9V_EVENTO"	, cTpEvento )
				oModel:LoadValue('MODEL_T9V', "T9V_ATIVO"	, "1" )
				oModel:LoadValue('MODEL_T9V', "T9V_PROTPN"	, AllTrim(cProtAnt) )
				oModel:LoadValue('MODEL_T9V', "T9V_VERANT"	, AllTrim(cVerAnt) )
	
				If TAFColumnPos("T9V_VERORI")	
					oModel:LoadValue('MODEL_T9V', "T9V_VERORI"	, (cAliasQry)->C1G_VERSAO )
				EndIf

				// Campo que armazena o ambiente gerado para transmissão
				If TafColumnPos("T9V_TPAMB")
					oModel:LoadValue('MODEL_T9V', "T9V_TPAMB", cAmbReinf ) 
				EndIf

				// Indica se um Filho está consistente
				lOkChild 	:= .T.
				cErroChild 	:= ""
				While cKeyProc == (cAliasQry)->C1G_NUMPRO .And. (cAliasQry )->(!Eof()) 	

					If aScan(aKeyPro, (cAliasQry)->C1G_FILIAL+(cAliasQry)->C1G_ID+"1") == 0
						AADD(aKeyPro, (cAliasQry)->C1G_FILIAL+(cAliasQry)->C1G_ID+"1")
					EndIf

					If !Empty( (cAliasQry)->T5L_ID )

						// Valida As regras do governo no Item

						If cTpProc == "1"
							If !( (cAliasQry)->C8S_CODIGO $ "03|90|92" )
								lOkChild := .F.
							EndIf	
						ElseIf cTpProc == "2"
							If !( (cAliasQry)->C8S_CODIGO $ "01|02|04|05|08|09|10|11|12|13|90|92" )
								lOkChild := .F.
							EndIf
						Else
							lOkChild := .F.
						EndIf
						If !lOkChild
							If Empty(cErroChild)
								cErroChild += "Validação: "+CRLF
								cErroChild += "Se {tpProc} = [Administrativo], deve ser preenchido com [03, 90, 92]. "+CRLF
								cErroChild += "Se {tpProc} = [Judicial], deve ser preenchido com [01, 02, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92]. "+CRLF
								cErroChild += "Valores Válidos: 01, 02, 03, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92."+CRLF+CRLF
							EndIf
							cErroChild += "Cod. Suspensão..: "+(cAliasQry)->T5L_CODSUS + CRLF
							cErroChild += "Ind. Suspensão..: "+(cAliasQry)->C8S_CODIGO + "-"+(cAliasQry)->C8S_DESCRI
						Else
							/*
							Indicativo de Depósito do Montante Integral: 
								S - Sim; 
								N - Não. 
								Validação: 
									Se {indSusp} = [90], preencher obrigatoriamente com [N]. 
									Se {indSusp} = [02, 03] preencher obrigatoriamente com [S]. 
									Valores Válidos: S, N.
							*/
							If ( (cAliasQry)->C8S_CODIGO $ "90" .And. (cAliasQry)->T5L_INDDEP <> "2" ) ;
								.Or. ( (cAliasQry)->C8S_CODIGO $ "02|03" .And. (cAliasQry)->T5L_INDDEP <> "1" ) ;
								.Or. Empty( (cAliasQry)->T5L_INDDEP ) 
								If Empty(cErroChild)
									cErroChild += "Validação: "+CRLF
									cErroChild += "Se {indSusp} = [90], preencher obrigatoriamente com [N]. "+CRLF
									cErroChild += "Se {indSusp} = [02, 03] preencher obrigatoriamente com [S]."+CRLF 
									cErroChild += "Valores Válidos: S, N. (Não pode ser vazio)"+CRLF+CRLF
								EndIf
								cErroChild += "Cod. Suspensão..: "+(cAliasQry)->T5L_CODSUS + CRLF
								cErroChild += "Ind. Suspensão..: "+(cAliasQry)->C8S_CODIGO + "-"+(cAliasQry)->C8S_DESCRI+ CRLF
								cErroChild += "Ind. Deposito...: "+IIf( (cAliasQry)->T5L_INDDEP =="1","S-Sim",IIf( (cAliasQry)->T5L_INDDEP=="2","N-Não","Vazio"))
								
								lOkChild := .F.
							EndIf

						EndIf

						oModelT9X := oModel:GetModel( "MODEL_T9X" )

						If !(oModelT9X:SeekLine( { {"T9X_CODSUS",(cAliasQry)->T5L_CODSUS} } ) ) 
							If lOkChild .Or. !lValid 
								If nLine > 0
									oModel:GetModel( "MODEL_T9X" ):lValid:= .T.
									oModel:GetModel( "MODEL_T9X" ):AddLine()
								EndIf
								oModel:LoadValue('MODEL_T9X', "T9X_ID"		, (cAliasQry)->T5L_ID	)
								oModel:LoadValue('MODEL_T9X', "T9X_VERSAO"	, cVerReg )
								oModel:LoadValue('MODEL_T9X', "T9X_CODSUS"	, (cAliasQry)->T5L_CODSUS)
								oModel:LoadValue('MODEL_T9X', "T9X_IDSUSP"	, (cAliasQry)->T5L_INDDEC)
								oModel:LoadValue('MODEL_T9X', "T9X_CIDSUS"	, (cAliasQry)->C8S_CODIGO)
								oModel:LoadValue('MODEL_T9X', "T9X_DTDECI"	, Stod((cAliasQry)->T5L_DTDEC) )
								oModel:LoadValue('MODEL_T9X', "T9X_DIDSUS"	, (cAliasQry)->C8S_DESCRI)
								oModel:LoadValue('MODEL_T9X', "T9X_INDDEP"	, (cAliasQry)->T5L_INDDEP)
							
								nLine++
							EndIf
						EndIf
					EndIf
					( cAliasQry )->(DbSkip())
					If lProc 
						oProcess:IncRegua2(STR0003 + cValTochar(nCont++) + "/" + cValTochar(nTotReg))
					EndIf 	
				EndDo	
				
				If lOkChild .Or. !lValid
					If oModel:VldData() 
						lSucesso := FwFormCommit( oModel )
						oModel:DeActivate()
						
						TafEndGRV( "T9V","T9V_PROCID", cIdLog, T9V->(Recno())  )
						If lValid
							TafEndGRV( "T9V","T9V_STATUS", "0", T9V->(Recno())  )
						EndIf
						DBSelectArea("C1G") 
						C1G->( dbSetOrder(8) ) //C1G_FILIAL+C1G_ID+C1G_ATIVO
						For nY:= 1 to Len(aKeyPro)
							If C1G->( DbSeek( aKeyPro[nY] ) )
								While !C1G->(Eof()) .And. C1G->(C1G_FILIAL + C1G_ID + C1G_ATIVO) == aKeyPro[nY] .And. C1G->C1G_ESOCIA == "1" 
									C1G->(DbSkip())
								EndDo
								TafEndGRV( "C1G","C1G_PROCID", cIdLog, C1G->(Recno())  )
							EndIf

							TafXLog( cIdLog, cEvento, "MSG"			, "Registro Gravado com sucesso."+CRLF+cKeyProc , cPeriodo )
						Next
					Else
						aErro   :={}
						cErro := TafRetEMsg( oModel )

						TafXLog( cIdLog, cEvento, "ERRO"		, "Mensagem do erro: " + CRLF + cErro , cPeriodo)						
					EndIf
					If !lOkChild
						TafXLog( cIdLog, cEvento, "ALERTA"			, cErroChild+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo)					
					EndIf	
				Else

					TafXLog( cIdLog, cEvento, "ERRO"			, cErroChild+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo )					
					
				EndIf
				oModel:DeActivate()
			Else
				While cKeyProc == (cAliasQry)->C1G_NUMPRO .And. (cAliasQry )->(!Eof()) 						
					nLine++
					( cAliasQry )->(DbSkip())	
					If lProc
						oProcess:IncRegua2(STR0003 + cValTochar(nCont++) + "/" + cValTochar(nTotReg))
					EndIf 
				EndDo	

				If !Empty( cLogErr ) 
					TafXLog( cIdLog, cEvento, "ERRO"			, cLogErr+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo)										
				Else
					TafXLog( cIdLog, cEvento, "ALERTA"			, "Evento transmitido e aguardando retorno:"+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo)										
				EndIf

			EndIf

			aKeyPro := {}

		EndDo

	EndIf
	(cAliasQry)->(DbCloseArea())	
Return Nil


//---------------------------------------------------------------------
/*/{Protheus.doc} foundVerOri

Retorna o RecNo do registro original

@Param  cAliasEvt  - Alias do Evento anterior
@Param  cFilEvt    - Filial do Evento anterior
@Param  cIdEvt     - Id do Evento anterior
@Param  cReciboEvt - versao original do registro anterior

@Author		Evandro dos Santos O. Teixeira
@Since		18/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function foundVerOri(cAliasEvt,cFilEvt,cIdEvt,cReciboEvt)

	Local nRecNo as numeric 
	Local cQuery as character 
	Local cAlias as character 
	
	nRecNo := 0
	cQuery := ""
	cAlias := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(cAliasEvt)
	cQuery += " WHERE " + cAliasEvt + "_FILIAL = '" + xFilial(cAliasEvt, cFilEvt) + "'"
	cQuery += " AND " + cAliasEvt + "_ID = '" + cIdEvt + "'"
	cQuery += " AND " + cAliasEvt + "_VERORI = '"+ cReciboEvt + "' "
	cQuery += " AND " + cAliasEvt + "_ATIVO = '1' "
	cQuery += " AND D_E_L_E_T_ = ' '

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAlias)

		If !Empty((cAlias)->RECNO)
			nRecNo := (cAlias)->RECNO
		EndIf 

	(cAlias)->(dbCloseArea())

Return nRecNo



//---------------------------------------------------------------------
/*/{Protheus.doc} TafR1070Cpo

Retorna os campos do legado que são usados na apuração

@Author		Roberto Souza
@Since		05/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafR1070Cpo()
	Local cRet as character
	Local aRet as array

	aRet 	:= {}

	cRet := "C1G_FILIAL,"
	cRet += "C1G_ID,"
	cRet += "C1G_VERSAO,"
	cRet += "C1G_ATIVO,"
	cRet += "C1G_TPPROC,"
	cRet += "C1G_NUMPRO,"
	cRet += "C1G_DTINI,"
	cRet += "C1G_DTFIN,"
	cRet += "C1G_INDAUT,"
	cRet += "C1G_UFVARA,"
	cRet += "C1G_CODMUN,"
	cRet += "C1G_VARA,"

	cRet += "T5L_FILIAL,"
	cRet += "T5L_ID,"
	cRet += "T5L_VERSAO,"
	cRet += "T5L_CODSUS,"
	cRet += "T5L_INDDEC,"
	cRet += "T5L_DTDEC,"
	cRet += "T5L_INDDEP,"

	cRet += "C07_CODIGO,"
	cRet += "C07_DESCRI,"

	cRet += "C09_CODIGO,"
	cRet += "C09_UF,"
	cRet += "C09_DESCRI,"

	cRet += "C8S_CODIGO,"
	cRet += "C8S_DESCRI"

	AADD( aRet , cRet )
	AADD( aRet , Separa( cRet , "," ) ) 

Return( aRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcValid

Efetua as pré-validações do governo para evitar rejeição.

@Author		Roberto Souza
@Since		07/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ProcValid( aLogErro, aDadosUtil )
	Local cLogErr 	as character
	Local aRegras 	as array
	Local Nx		as numeric

	Default aLogErro	:= {}
	Default aDadosUtil	:= {}

	cLogErr	:= ""
	aRegras	:= {}	
	Nx		:= 0
 
	//-------------------------------------
	// Estrutura aRegras
	// [01] - Regra do governo ou interna TAF tratada no ReinfRules()
	// [02] - Ativo - A regra é inativa quando a mesma já é tratada em algum momento anterior à apuração


	AADD( aRegras , {"REGRA_EXISTE_INFO_CONTRIBUINTE" , .T. } ) 
	/*	O evento somente pode ser recepcionado se existir evento de informações cadastrais do
		contribuinte vigente para a data do evento, ou seja, a data do evento (ou período de
		apuração, no caso de evento periódico) deve estar compreendida entre o {iniValid} e
		{fimValid} do evento de informações do contribuinte.
	*/

//	################################# Pendente
	AADD( aRegras , {"REGRA_PERMITE_ALT_EXCL_CODSUSP" , .T. } ) 
	/*	Não pode haver alteração ou exclusão de {nrProc} + {codSusp} que esteja sendo utilizado
		em outro evento.*/

	AADD( aRegras , {"REGRA_TABGERAL_ALTERACAO_PERIODO_CONFLITANTE", .F. } ) 
	/*	Em caso de alteração de período de validade das informações, não deve existir outro
		registro na tabela com o mesmo código de identificação (chave) em período de vigência
		conflitante com o novo período de validade informado.
	
		o Xml Gera data de nova validade quando há alguma alteração então quando ocorre, somente transmitindo e recebendo a rejeição do governo. 
	*/

	AADD( aRegras , {"REGRA_TABGERAL_EXISTE_REGISTRO_ALTERADO", .F. } )  
	/*	Em caso de alteração, deve existir registro na tabela com o mesmo código e período de
		validade informados no evento.
		
		o Xml Gera data de nova validade quando há alguma alteração então quando ocorre, somente transmitindo e recebendo a rejeição do governo. 
	*/

	AADD( aRegras , {"REGRA_TABGERAL_EXISTE_REGISTRO_EXCLUIDO", .F. } )  
	/*	Em caso de exclusão, deve existir o registro na tabela com o mesmo código e período de
		validade informados no evento.

		o Xml Gera data de nova validade quando há alguma alteração então quando ocorre, somente transmitindo e recebendo a rejeição do governo. 	
	*/

	AADD( aRegras , {"REGRA_TABGERAL_INCLUSAO_PERIODO_CONFLITANTE", .F. } ) 
	/*	Em caso de inclusão, não deve existir outro registro na tabela com o mesmo código de
		identificação (chave) em período de vigência conflitante com o período informado no
		registro atual.
		Tratado pelo modelo MVC / Apuração / Exclusão	
	*/

	AADD( aRegras , {"REGRA_TAB_PERMITE_EXCLUSAO" , .F. } ) 
	/*Em caso de {exclusao}, o registro identificado pelo período de validade deve existir e o
		registro somente pode ser excluído se não houver outros arquivos de eventos enviados
		anteriormente que façam referência ao mesmo. */

	AADD( aRegras , {"REGRA_VALIDA_ID_EVENTO", .F. } )
	/*A identificação única do evento (Id) é composta por 36 caracteres, conforme o que segue:
		IDTNNNNNNNNNNNNNNAAAAMMDDHHMMSSQQQQQ
		ID - Texto Fixo "ID";
		T - Tipo de Inscrição do Empregador (1 - CNPJ; 2 - CPF);
		NNNNNNNNNNNNNN - Número do CNPJ ou CPF do empregador - Completar com
		zeros à direita. No caso de pessoas jurídicas, o CNPJ informado deve conter 8 ou 14
		posições de acordo com o enquadramento do contribuinte para preenchimento do campo
		{ideEmpregador/nrInsc} do evento R-1000, completando-se com zeros à direita, se
		necessário.
		AAAAMMDD - Ano, mês e dia da geração do evento;
		HHMMSS - Hora, minuto e segundo da geração do evento;
		QQQQQ - Número sequencial da chave. Incrementar somente quando ocorrer geração de
		eventos na mesma data/hora, completando com zeros à esquerda.
		OBS.: No caso de pessoas jurídicas, o CNPJ informado deverá conter 8 ou 14 posições de
		acordo com o enquadramento do contribuinte para preenchimento do campo
		{ideEmpregador/nrInsc} do evento S-1000, completando-se com zeros à direita, se
		necessário. */

	AADD( aRegras , {"REGRA_TAF_PROCESSO_NUM_VALIDO", .F. } )
	/*	Informar o número do processo administrativo/judicial. Validação: Validar o número do processo
		NNNNNNN-DD.AAAA.J.TR.OOOO
		http://www.cnj.jus.br/programas-e-acoes/pj-numeracao-unica/perguntas-frequentes
	*/

	AADD( aRegras , {"REGRA_TAF_DTINI_EVENTO", .T. } )
	/*	Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM.*/

	AADD( aRegras , {"REGRA_TAF_DTFIM_EVENTO", .T. } )
	/*	Preencher com o mês e ano de término da validade das informações, se houver. Validação: Se informado, deve estar no formato AAAA-MM e ser um período igual ou posterior a {iniValid} */


	AADD( aRegras , {"REGRA_TAF_PROCESSO_IND_SUS", .F. } )
	// Tratado no item da apuração
	/*	Indicativo de suspensão da exigibilidade: 
			01 - Liminar em Mandado de Segurança; 
			02 - Depósito Judicial do Montante Integral; 
			03 - Depósito Administrativo do Montante Integral; 
			04 - Antecipação de Tutela; 
			05 - Liminar em Medida Cautelar; 
			08 - Sentença em Mandado de Segurança Favorável ao Contribuinte; 
			09 - Sentença em Ação Ordinária Favorável ao Contribuinte e Confirmada pelo TRF; 
			10 - Acórdão do TRF Favorável ao Contribuinte; 
			11 - Acórdão do STJ em Recurso Especial Favorável ao Contribuinte; 
			12 - Acórdão do STF em Recurso Extraordinário Favorável ao Contribuinte; 
			13 - Sentença 1ª instância não transitada em julgado com efeito suspensivo; 
			90 - Decisão Definitiva a favor do contribuinte; 
			92 - Sem suspensão da exigibilidade. 
			Validação: 
				Se {tpProc} = [1], deve ser preenchido com [03, 90, 92]. 
				Se {tpProc} = [2], deve ser preenchido com [01, 02, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92]. 
				Valores Válidos: 01, 02, 03, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92.
	*/

	AADD( aRegras , {"REGRA_TAF_PROCESSO_IND_DEP", .F. } )
	// Tratado no item da apuração	
	/* Indicativo de Depósito do Montante Integral: 
		S - Sim; 
		N - Não. 
		Validação: 
			Se {indSusp} = [90], preencher obrigatoriamente com [N]. 
			Se {indSusp} = [02, 03] preencher obrigatoriamente com [S]. 
			Valores Válidos: S, N.
	*/

	If FindFunction( "ReinfRules" )
		For Nx := 1 To Len( aRegras )
			If aRegras[nx][02]
				cLogErr += ReinfRules( "C1G", aRegras[Nx][01] , @aLogErro, aDadosUtil, "C1G", .F. )
			EndIf
		Next
	EndIf			
Return( cLogErr ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} FilialIN

Cria uma string com as filiais selecionadas e o xFilial do alias para ser 
usada no IN.

@Param 	- aIN: Array com os alias quer serão usados
		- aFils: Array com todas as filiais selecionadas
		- nQtdFil: Tamanho do array de aFils se o compartilhamento não for CCC

@Author		Matheus Prada
@Since		19/12/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FilialIN(aIN, aFils, nQtdFil)

Local cIN		as character 
Local nX		as numeric
Local nY		as numeric
Local cFilBkp	as character 

nY	:= 1
nX	:= 0 
cIN := ""

for nY := 1 to Len(aIN)

	If !Empty(xFilial(aIN[nY])) 

		cFilBkp := cFilAnt
		
		for nX := 1 to nQtdFil
			cFilAnt := aFils[nX][02]
			If nX == 1
				cIN := "('"
			Else 
				cIN += "', '"
			EndIf
			cIN  += Iif(xFilial(aIN[nY]) $ cIN, "", xFilial(aIN[nY]))
		next nX

		cIN += "')"
		cFilAnt := cFilBkp
		aIN[nY] := cIN
		
	Else
		cIN := "('" + xFilial(aIN[nY]) + "')"
		aIN[nY] := cIN
	EndIf

Next nY

Return
