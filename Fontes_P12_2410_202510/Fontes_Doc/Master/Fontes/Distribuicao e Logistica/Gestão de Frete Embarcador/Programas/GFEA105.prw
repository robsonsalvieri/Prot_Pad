#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105
Rotina que realiza o(s) estorno(s) da(s) provisão(ões).

@author Elynton Fellipe Bazzo
@since 30/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA105()

	Processa({||GFEA105PRC() },"Estornando... Aguarde") //"Estornando... Aguarde"
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105PRC
Função que exibe a pergunta, realiza as respectivas validações da 
rotina e processa os estornos.

@author Elynton Fellipe Bazzo
@since 30/12/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105PRC()

	Private cTipoEst := SuperGetMv('MV_TPEST',, '1')
	Private s_GFEA105 := Pergunte( "GFEA105",.T. )
	
	/*If FUNNAME() == "GFEA096"
		//Adiciona o período do lote ao parâmetro "Período ?"
		SetMVValue("GFEA105","MV_PAR03", SubStr(GXE->GXE_PERIOD,6,7) + "/" + SubStr(GXE->GXE_PERIOD,1,4) )
	EndIf*/
	
	//Apresenta a pergunta GFEA105
	If !s_GFEA105
		Return .F.
	EndIf
	
	If FUNNAME() == "GFEA096"
		Pergunte( "GFEA105",.F. )// Evitar qeu seja utilizado um valor não confirmado pelo usuário
	EndIf
	
	//Função que valida os parâmetros informados.
	While !GFEA105VAL( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05 )
		If !s_GFEA105
			Return .F.
		EndIf
	EndDo
	
	//Função que realiza o processamento conforme o tipo de estorno setado no parâmetro MV_TPEST
	If !GFEA105REG( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05 )
		Return .F.
	EndIf
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105VAL
Validações dos conteúdos preenchidos junto aos parâmetros.

@author Elynton Fellipe Bazzo
@since 12/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105VAL( cFilialIni, cFilialFim, cPeriod, dDataIni, dDataFim )

	Local aUserFils	:= GetBrwFils()
	
	// Verifica acesso do usuário na filial em processamento
	If ( !Empty( cFilialIni ) .Or. !Empty( cFilialFim ) ) .And. ( aScan( aUserFils, cFilialIni ) == 0 .Or. aScan( aUserFils, cFilialFim ) == 0 )
		Help( ,, 'HELP',,"Usuário não tem acesso na filial informada.", 1, 0)
		Return .F.
	EndIf
	
	If cFilialIni > cFilialFim
		Alert("O campo 'Filial De' deve ser menor ou igual que o campo 'Filial Ate'")
		Return .F.
	EndIf
	
	If Len(AllTrim(StrTran(cPeriod,"/",""))) < 6
		Alert("O período deve estar no formato de data mm/aaaa")
		Return .F.
	EndIf
	
	If Val(SubStr(cPeriod,1,2)) <= 0 .Or. Val(SubStr(cPeriod,1,2)) > 12
		Alert( "O mês do período é inválido" )
		Return .F.
	EndIf
	
	If cTipoEst == "1" //Tipo Estorno Total
		If dDataIni > dDataFim
			Alert("O campo 'Data De' deve possuir uma data menor ou igual que o campo 'Data Ate'")
			Return .F.
		EndIf
	ElseIf cTipoEst == "2" //Tipo Estorno Parcial
		If Empty( cPeriod ) //Se o período estiver vazio
			Alert("Para geração do estorno parcial, é obrigatório informar o período")
			Return .F.
		EndIf
	EndIf
	
	If cTipoEst == "2" //Tipo Estorno Parcial
		If CTOD( '01/' + cPeriod ) > DDATABASE
			Alert("O período informado não pode ser maior que o período atual.")
			Return .F.
		EndIf
	EndIf
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105REG
Função que realiza o processamento conforme tipo do estorno.

@author Elynton Fellipe Bazzo
@since 03/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105REG( cFilialIni, cFilialFim, cPeriod, dDataIni, dDataFim )

	Local nX 		:= 0
	Local cFilBkp	:= cFilAnt
	Local cQuery 	:= "", cMotivo := "", cSubLotRel
	Local aDadosGXO	:= {}, aGWA := {}, aGXD := {}
	Local cMsgErro 	:= "", cMsg := ""
	Local lRetErro 	:= .F.
	Local cDataR := ""
	
	Private cDadosGXN := ""
	Private aDadosGXN := {}
	
	If cTipoEst == "1" //Estorno Total
		cAliasQry := GetNextAlias()
		cQuery := " SELECT GXE_FILIAL, GXE_CODLOT FROM " + RetSQLName( "GXE" ) 
		cQuery += " WHERE GXE_FILIAL >= '" + cFilialIni + "' AND GXE_FILIAL <= '" + cFilialFim + "' AND "
		cQuery += " GXE_DTCRIA >= '" + DTOS(dDataIni) + "' AND GXE_DTCRIA <= '" + DTOS(dDataFim) + "' AND "
		If !Empty( cPeriod )
			cQuery += " GXE_PERIOD = '" + AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) + "' AND "
		EndIf
		cQuery += " D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While !(cAliasQry)->( Eof() )
			If GXE->( dbSeek( (cAliasQry)->GXE_FILIAL + (cAliasQry)->GXE_CODLOT ))
				GFEA096DES() //Desatualiza o financeiro no ERP
			EndIf
			
			( cAliasQry )->( dbSkip() )
		EndDo
		
		(cAliasQry)->(dbCloseArea())
		
	ElseIf cTipoEst == "2" //Estorno Parcial
	
		cAliasQry := GetNextAlias()
		cQuery := " SELECT GXE_FILIAL, GXE_CODLOT FROM " + RetSQLName( "GXE" ) 
		cQuery += " WHERE ( GXE_SIT = '4' OR GXE_SIT = '8' ) AND "
		cQuery += " GXE_FILIAL >= '" + cFilialIni + "' AND GXE_FILIAL <= '" + cFilialFim + "' AND "
		If !Empty( cPeriod )
			cQuery += " GXE_PERIOD <= '" + AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) + "' AND "
		EndIf
		cQuery += " D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		GXE->(dbSetOrder(1))
		
		If (cAliasQry)->( Eof() )
			cAliasQry1 := GetNextAlias()
			cQuery := " SELECT GXE_FILIAL, GXE_CODLOT FROM " + RetSQLName( "GXE" ) 
			cQuery += " WHERE GXE_SIT = '6' AND GXE_FILIAL >= '" + cFilialIni + "' AND GXE_FILIAL <= '" + cFilialFim + "' AND "
			If !Empty( cPeriod )
				cQuery += " GXE_PERIOD <= '" + AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) + "' AND "
			EndIf
			cQuery += " D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry1, .F., .T.)
			
			If !(cAliasQry1)->( Eof() )
				Help( ,, 'HELP',,"Todos os lotes existentes para o período informado estão estornados.", 1, 0)
			Else
				Help( ,, 'HELP',,"Não há lotes aptos para geração de sublotes de estorno no período informado.", 1, 0)
			EndIf
			
			(cAliasQry1)->(dbCloseArea())
			(cAliasQry)->(dbCloseArea())
			Return .F.
		EndIf
		
		While !(cAliasQry)->( Eof() ) .And. GXE->( dbSeek( (cAliasQry)->GXE_FILIAL + (cAliasQry)->GXE_CODLOT ))//Percorre todos os lotes
		
			aGWA 		:= {}
			aGXD 		:= {}
			aDadosGXO	:= {}
			cFilAnt 	:= GXE->GXE_FILIAL
			lDadosGXN	:= .F.
			cSubLotRel	:= ""
			//Retira o relacionamento para adicionar a um novo sublote.
			GXN->(dbSetOrder( 01 ))
			If GXN->(dbSeek( xFilial( "GXN" ) + GXE->GXE_CODLOT ))
				While !GXN->(Eof()) .And. GXE->GXE_CODLOT == GXN->GXN_CODLOT
					If GXN->GXN_SIT $ '1;3' //Não-Enviado ou Rejeitado
						aAdd( aDadosGXN,{ GXN->GXN_CODLOT,GXN->GXN_CODEST,GXE->GXE_PERIOD })
						cDadosGXN += "O sublote " + GXN->GXN_CODEST + " relacionado ao lote " + GXN->GXN_CODLOT + " do período " + GXE->GXE_PERIOD + " ainda não foi integrado." + CRLF
						lDadosGXN := .T.
						cSubLotRel	:= GXN->GXN_CODEST
					EndIf
					
					GXN->( dbSkip() )
				EndDo
			EndIf
			
//			If lDadosGXN
//				(cAliasQry)->( dbSkip() )
//				Loop
//			EndIf
			
			GXD->(dbSetOrder( 03 ))
			If GXD->( dbSeek( xFilial("GXD") + GXE->GXE_CODLOT + Space(TamSx3("GXD_CODEST")[1]))) //Ao menos um cálculo sem sub lote de estorno

				cQuery := "SELECT GXD_NRCALC, GXD.R_E_C_N_O_ GXD_RECNO FROM " + RetSqlName("GXD") + " GXD LEFT JOIN " + RetSqlName("GXN") + " GXN"
				cQuery += " ON GXN_FILIAL = GXD_FILIAL"
				cQuery += " AND GXN_CODLOT = GXD_CODLOT"
				cQuery += " AND GXN_CODEST = GXD_CODEST"
				cQuery += " AND GXN.D_E_L_E_T_ = ' '"
				cQuery += " WHERE (GXN_CODEST IS NULL OR GXN_SIT IN ('1','3'))"
				cQuery += " AND GXD.D_E_L_E_T_ = ' '"
				cQuery += " AND GXD_FILIAL = '" + xFilial("GXD")  + "'"
				cQuery += " AND GXD_CODLOT = '" + GXE->GXE_CODLOT + "'"
				
				cAliasQry1 := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasQry1, .F., .T.)
				
				While !(cAliasQry1)->(Eof())
				
					GWF->(dbSetOrder( 01 ))
					If GWF->( dbSeek( xFilial("GWF") + (cAliasQry1)->GXD_NRCALC ))
					
						lParVenc := .F.
						lProv := .F.
						
						//Se atende parâmetro de lote vencido
						If AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) != GXE->GXE_PERIOD // estorno automatico somente para periodos diferentes do informado.
							lParVenc := GFEA105PAR( GWF->GWF_TPCALC, cPeriod, GXE->GXE_PERIOD, GWF->GWF_NRCALC,  GWF->GWF_FILIAL )
						EndIf
						
						If !lParVenc
							
							GWJ->(dbSetOrder(1))
							If GWJ->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRPREF) ) .And. GWJ->GWJ_SITFIN == '4'
								cMotivo := "01" //01-Cálculo relacionado a uma Pré-Fatura
								lProv := .T.
							EndIf
							
							GW2->(dbSetOrder(1))
							If !Empty(GWF->GWF_NRCONT) .And. GW2->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCONT)) .And. GW2->GW2_SITFIN $ "2;4"
								cMotivo := "02" //02-Documento de Carga relacionado a Contrato de Autônomo
								lProv := .T.
							EndIf
							
							cDataR := DtoS(GFA105GWH( GWF->GWF_NRCALC, GWF->GWF_FILIAL, .T. ))
							If !Empty(cDataR) .And. Alltrim(SubSTR(cDataR, 1, 4)) + "/" + Alltrim(SubSTR(cDataR, 5, 2)) <= AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 ))
								cMotivo := "03" //03-Documento de Carga relacionado a Documento de Frete
								lProv := .T.
							EndIf
							
							If GWF->GWF_TPCALC == "8" // Se o tipo do cálculo igual a 'Estimativa'
							
								aAreaGWF := GWF->( GetArea() )
								
								GWH->(dbSetOrder( 01 ))
								If GWH->(dbSeek(GWF->(GWF_FILIAL+GWF_NRCALC)))
									cChvDC := GWH->( GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC )
									GWH->(dbSetOrder( 02 ))
									If GWH->(dbSeek( cChvDC ))
										While !GWH->(Eof()) .And. cChvDC == GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC)
											If GWF->(dbseek(GWH->(GWH_FILIAL + GWH_NRCALC))) .And. GWF->GWF_TPCALC $ '1;6'
												cMotivo := "04" //04-Documento de Carga possui Cálculo Normal
												lProv := .T.
												Exit
											EndIf
											GWH->(dbSkip())
										EndDo
									EndIf
								EndIf
								
								RestArea( aAreaGWF )
								
							EndIf
						Else
							lProv := .T.
							cMotivo := "05" //Ajuste de provisão não realizada
						EndIf
						
						If lProv
							GWA->(dbSetOrder(3))
							If GWA->(dbSeek(GWF->GWF_FILIAL+If(GWF->GWF_TPCALC $ "1;6;4;5;7","1","4")+GWF->GWF_NRCALC))
								While !GWA->(Eof()) .And. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
									.And. GWA->GWA_TPDOC == If(GWF->GWF_TPCALC $ "1;6;4;5;7","1","4");
										.And. AllTrim(GWA->GWA_NRDOC) == AllTrim(GWF->GWF_NRCALC)
									If (nX := aScan(aDadosGXO,{|x| x[1] == GWA->GWA_CTADEB .And. x[2] == GWA->GWA_CCDEB .And. x[3] == GWA->GWA_UNINEG})) > 0
										aDadosGXO[nX][4] += GWA->GWA_VLMOV //Acumula o valor do movimento
									Else
										aAdd(aDadosGXO,{GWA->GWA_CTADEB,GWA->GWA_CCDEB,GWA->GWA_UNINEG,GWA->GWA_VLMOV})
									EndIf
									
									aAdd(aGWA,GWA->(RecNo()))
									GWA->( dbSkip() )
									
									aAdd(aGXD,{ (cAliasQry1)->GXD_RECNO,cMotivo })
									
								EndDo
							EndIf
						EndIf
					Else //Cálculo apagado da Base mas ainda no Lote de Provisão.
						
						cQuery := "SELECT * FROM " + RetSQLName("GWF") + " GWF "
						cQuery += "WHERE GWF.GWF_FILIAL = '" + xFilial("GWF") + "'"
						cQuery += "AND GWF.GWF_NRCALC = '" + (cAliasQry1)->GXD_NRCALC + "'"

						cAliGWF := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliGWF, .F., .T.)
						
						cQuery := ""
						lParVenc := .F.
						lProv := .F.
						
						//Se atende parâmetro de lote vencido
						If AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) != GXE->GXE_PERIOD // estorno automatico somente para periodos diferentes do informado.
							lParVenc := GFEA105PAR( (cAliGWF)->GWF_TPCALC, cPeriod, GXE->GXE_PERIOD, (cAliGWF)->GWF_NRCALC,  (cAliGWF)->GWF_FILIAL )
						EndIf
						
						If lParVenc
							lProv := .T.
							cMotivo := "05" //Ajuste de provisão não realizada
						EndIf
						
						If lProv
							
							cQuery := "SELECT * FROM " + RetSQLName("GWA") + " GWA "
							cQuery += "WHERE GWA.GWA_FILIAL = '" + (cAliGWF)->GWF_FILIAL + "' "
							cQuery += "AND GWA.GWA_NRDOC = '" + (cAliGWF)->GWF_NRCALC + "' "
							cQuery += "AND GWA.GWA_TPDOC = '" + If((cAliGWF)->GWF_TPCALC $ "1;6;4;5;7","1","4") + "' "
							
							cAliGWA := GetNextAlias()
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliGWA, .F., .T.)

							cQuery := ""
							
							While !(cAliGWA)->(Eof()) 
								
								If (nX := aScan(aDadosGXO,{|x| x[1] == (cAliGWA)->GWA_CTADEB .And. x[2] == (cAliGWA)->GWA_CCDEB .And. x[3] == (cAliGWA)->GWA_UNINEG})) > 0
									aDadosGXO[nX][4] += (cAliGWA)->GWA_VLMOV //Acumula o valor do movimento
								Else
									aAdd(aDadosGXO,{(cAliGWA)->GWA_CTADEB,(cAliGWA)->GWA_CCDEB,(cAliGWA)->GWA_UNINEG,(cAliGWA)->GWA_VLMOV})
								EndIf
								
								aAdd(aGWA,(cAliGWA)->(RecNo()))
								(cAliGWA)->( dbSkip() )
								
								aAdd(aGXD, {(cAliasQry1)->GXD_RECNO, cMotivo})
							EndDo
						EndIf
					EndIf
	
					(cAliasQry1)->( dbSkip() )
				EndDo
				(cAliasQry1)->(dbCloseArea())
			EndIf
			
			If Len( aDadosGXO ) > 0 //Se houver dados
				begin transaction
				//Geração de um novo SubLote de Estorno
				If Empty(cSubLotRel)
					RecLock( "GXN", .T. )
					GXN->GXN_FILIAL := (cAliasQry)->GXE_FILIAL // Filial
					GXN->GXN_CODLOT := (cAliasQry)->GXE_CODLOT // Cod Lote
					GXN->GXN_CODEST := GETSXENUM( "GXN","GXN_CODEST","GXN" ) // Código Estorno
					GXN->GXN_PERIES := AllTrim(SUBSTR( cPeriod, 4, 6 )) + "/" +  AllTrim(SUBSTR( cPeriod, 1, 2 )) // Período Informado
					GXN->GXN_DTCRIA := LastDate(StoD(AllTrim(SUBSTR( cPeriod, 4, 6 )) + AllTrim(SUBSTR( cPeriod, 1, 2 )) + "01" )) //Ultimo dia do periodo. 
					GXN->GXN_USUCRI := CUSERNAME // Usuário Logado
					GXN->GXN_SIT	:= "1" //Não-Enviado
					GXN->( MsUnLock() )
					ConfirmSX8()
					aAdd( aDadosGXN,{ GXN->GXN_CODLOT,GXN->GXN_CODEST,GXE->GXE_PERIOD })
					cDadosGXN += "Foi gerado o sublote " + GXN->GXN_CODEST + " relacionado ao lote " + GXN->GXN_CODLOT + " do período " + GXE->GXE_PERIOD + CRLF + " "
				Else
					GXN->(dbSetOrder(1))
					GXN->(dbSeek(xFilial("GXN") + (cAliasQry)->GXE_CODLOT + cSubLotRel))
					dbSelectArea("GXO")
					GXO->( dbSetOrder( 01 ))
					If GXO->(dbSeek( xFilial("GXN") + (cAliasQry)->GXE_CODLOT + cSubLotRel ))
						While !GXO->(Eof()) .And. xFilial("GXN") + (cAliasQry)->GXE_CODLOT + cSubLotRel == GXO->(GXO_FILIAL+GXO_CODLOT+GXO_CODEST)
							RecLock( "GXO", .F. )
							dbDelete()
							MsUnlock( "GXO" )
							GXO->( dbSkip() )
						EndDo
					EndIf
				EndIf
				
				//Gera um novo Lançamento de Estorno
				For nX := 1 to Len( aDadosGXO )
					RecLock( "GXO",.T. )
					GXO->GXO_FILIAL := GXE->GXE_FILIAL
					GXO->GXO_CODLOT := GXE->GXE_CODLOT
					GXO->GXO_CODEST := GXN->GXN_CODEST
					GXO->GXO_SEQ 	:= nX
					GXO->GXO_CONTA  := aDadosGXO[nX][1]//GWA_CTADEB
					GXO->GXO_VALOR  := aDadosGXO[nX][4]//GWA_VLMOV
					GXO->GXO_TPLANC := "1" //Débito
					GXO->GXO_CCUSTO := aDadosGXO[nX][2]//GWA_CCDEB
					GXO->GXO_UNINEG := aDadosGXO[nX][3]//GWA_UNINEG	
					GXO->( MsUnlock() )
				Next nX

				//Atualiza o código estorno do movimento contábil
				For nX := 1 to Len( aGWA )
					GWA->(dbGoTo(aGWA[nX]))
					RecLock("GWA",.F.)
					GWA->GWA_CODEST := GXN->GXN_CODEST
					GWA->( msUnlock() )
				Next nX
				
				For nX := 1 to Len( aGXD )
					GXD->(dbGoTo(aGXD[nX][1]))
					RecLock( "GXD",.F. )
					GXD->GXD_CODEST := GXN->GXN_CODEST
					GXD->GXD_MOTIES := aGXD[nX][2] //Atualiza campo motivo
					GXD->( msUnlock() )
				Next nX
				
				end transaction
			
			Else
			
				lRetErro := .T.
				cMsgErro += (cAliasQry)->GXE_CODLOT + CRLF
				
			EndIf
			
			
			(cAliasQry)->( dbSkip() )
		EndDo
		
	EndIf
	
	If Len(aDadosGXN) > 0
	
		cDadosGXN := cDadosGXN + CRLF + "Deseja enviá-lo(s) para o ERP?"
		
		If MsgYesNo( cDadosGXN )
		
			For nX := 1 To Len( aDadosGXN )
			
				GXN->(dbSetOrder( 01 ))
				If GXN->(dbSeek( xFilial( "GXN" ) + aDadosGXN[nX][1] + aDadosGXN[nX][2] ))
					RecLock( "GXN",.F. )
					GXN->GXN_SIT := "2" //Situação do Sublote - Pendente
					GXN->( msUnlock() )
				EndIf
				
				GXE->(dbSetOrder( 01 ))
				If GXE->(dbSeek( xFilial( "GXE" ) + aDadosGXN[nX][1] ))
					If GXE->GXE_SIT != "7" //Se o lote não está atualizado
						RecLock( "GXE", .F. )
						GXE->GXE_SIT := "7" //Situação do Lote - Pendente Estorno Parcial
						GXE->( MsUnLock() )
					EndIf
				EndIf
				
			Next nX
			
		EndIf
	ElseIf lRetErro
		cMsg := "Não foram encontrados dados para geração de sublote de estorno para o(s) lote(s): " + CRLF + cMsgErro
		Help( ,, 'HELP',,cMsg, 1, 0)
	EndIf
	
	If Select(cAliasQry) > 0
	   (cAliasQry)->(dbCloseArea())
	EndIf	
	
	cFilAnt := cFilBkp
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105PAR
Função que verifica se o está lote vencido.

@author Elynton Fellipe Bazzo
@since 16/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105PAR( cTipoCalc, cPeriod, cGXEPeriod, cNrCalc, cFilCalc )

	Local lRet := .F.
	Local aAreaGWF := GWF->(GetArea())
	If cTipoCalc $ "1;6;2;3;4;5;7" //Cálculos do Tipo Normal, Redespacho, Complementar Valor e Imposto
		If MonthSub( Ctod( "01" + "/" + SubStr( cPeriod,1,2 ) + "/" + SubStr( cPeriod,4,6 ) ), SuperGetMv('MV_PEPRONO',, 1) ) >= Ctod( "01" + "/" + SubStr( cGXEPeriod,6,6 ) + "/" + SubStr( cGXEPeriod,1,4 ) )
			lRet := .T.
		EndIf
	ElseIf cTipoCalc == "8" //Ccálculos do tipo Estimativa
		If MonthSub( Ctod( "01" + "/" + SubStr( cPeriod,1,2 ) + "/" + SubStr( cPeriod,4,6 ) ), SuperGetMv('MV_PEPROES',, 1) ) >= Ctod( "01" + "/" + SubStr( cGXEPeriod,6,6 ) + "/" + SubStr( cGXEPeriod,1,4 ) )
			lRet := .T.
		EndIf
	
	EndIf
	RestArea(aAreaGWF)
	
Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFA105GWH
Documentos de Carga relacionados a Documento de Frete: 
1. Com Fatura atualizada no Contas a Pagar (Se contabiliza pelo Financeiro MV_DSCTB = 1) 
2. Atualizado no Fiscal (Se contabilização pelo Recebimento - MV_DSCTB = 2) 

@author Elynton Fellipe Bazzo
@since 16/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------------------------------
Function GFA105GWH( cNrCalc,cFilCalc, lData )

	Local xRet := .F.
	Local cQuery := "", cAliasQry := ""
	Local cFinRem := SuperGetMv( 'MV_DSCTB',,'1' )
	Local cMV_DSCTB   := If (Empty(cFinRem),"1",cFinRem)
	Default lData := .F.
		
	If cMV_DSCTB == "1" .Or. SuperGetMv('MV_ERPGFE',.F.,'1') == '2' // ERP Protheus considera o cálculo realizado somente pela fatura.
		cAliasQry := GetNextAlias()
		cQuery := " SELECT GW6.GW6_DTFIN FROM " + RetSQLName( "GWF" ) + " GWF "
		IF GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
			cQuery += " INNER JOIN " + RetSQLName( "GW3" ) + " GW3 ON GWF.GWF_NRDF = GW3.GW3_NRDF AND GWF_FILIAL = GW3_FILIAL AND GWF_CDESP = GW3_CDESP AND GWF_EMISDF = GW3_EMISDF AND GWF_SERDF = GW3_SERDF AND GWF_DTEMDF = GW3_DTEMIS "
			cQuery += " INNER JOIN " + RetSQLName( "GW6" ) + " GW6 ON GW6.GW6_FILIAL = GW3.GW3_FILFAT AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT AND "
			cQuery += " GW6.GW6_SERFAT = GW3.GW3_SERFAT AND GW6.GW6_NRFAT = GW3.GW3_NRFAT AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA "
			cQuery += " WHERE GW6.GW6_SITFIN = '4' AND GWF.GWF_NRCALC = '" + cNrCalc + "' AND GWF_FILIAL = '" + cFilCalc + "' AND "
			cQuery += " GWF.D_E_L_E_T_ = ' ' AND "
			cQuery += " GW3.D_E_L_E_T_ = ' ' AND "
			cQuery += " GW6.D_E_L_E_T_ = ' ' "
		Else
		cQuery += " INNER JOIN " + RetSQLName( "GWH" ) + " GWH ON GWH.GWH_FILIAL = GWF.GWF_FILIAL AND GWH.GWH_NRCALC = GWF.GWF_NRCALC "
		cQuery += " INNER JOIN " + RetSQLName( "GW4" ) + " GW4 ON GW4.GW4_FILIAL = GWH.GWH_FILIAL AND GW4.GW4_SERDC = GWH.GWH_SERDC AND GW4.GW4_NRDC = GWH.GWH_NRDC AND GW4.GW4_TPDC = GWH.GWH_CDTPDC "
		cQuery += " INNER JOIN " + RetSQLName( "GW3" ) + " GW3 ON GW3.GW3_FILIAL =  GW4.GW4_FILIAL AND GW3.GW3_CDESP = GW4.GW4_CDESP AND GW3.GW3_EMISDF = GW4.GW4_EMISDF AND "
		cQuery += " GW3.GW3_SERDF = GW4.GW4_SERDF AND GW3.GW3_NRDF = GW4.GW4_NRDF AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS "
		cQuery += " INNER JOIN " + RetSQLName( "GW6" ) + " GW6 ON GW6.GW6_FILIAL = GW3.GW3_FILIAL AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT AND "
		cQuery += " GW6.GW6_SERFAT = GW3.GW3_SERFAT AND GW6.GW6_NRFAT = GW3.GW3_NRFAT AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA " 
		cQuery += " WHERE GW6.GW6_SITFIN = '4' AND GWF.GWF_NRCALC = '" + cNrCalc + "' AND GWF.GWF_FILIAL = '" + cFilCalc + "' AND GWF.GWF_TPCALC = GW3.GW3_TPDF AND  "
		cQuery += " GWF.D_E_L_E_T_ = ' ' AND "
		cQuery += " GWH.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW4.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW3.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW6.D_E_L_E_T_ = ' ' "
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			If lData
				xRet := STOD((cAliasQry)->GW6_DTFIN)
			Else
				xRet := .T.
			EndIf
		ElseIf lData
			xRet := STOD(Space(8))
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	ElseIf cMV_DSCTB == "2"
		cAliasQry := GetNextAlias()
		cQuery := "SELECT GW3.GW3_DTFIS FROM " + RetSQLName( "GWF" ) + " GWF "
		If GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
			cQuery += " INNER JOIN " + RetSQLName( "GW3" ) + " GW3 ON GWF.GWF_NRDF = GW3.GW3_NRDF AND GWF_FILIAL = GW3_FILIAL AND GWF_CDESP = GW3_CDESP AND GWF_EMISDF = GW3_EMISDF AND GWF_SERDF = GW3_SERDF AND GWF_DTEMDF = GW3_DTEMIS "
			cQuery += " WHERE GW3.GW3_SITFIS = '4' AND GWF.GWF_NRCALC = '" + cNrCalc + "' AND GWF_FILIAL = '" + cFilCalc + "' AND "
			cQuery += " GWF.D_E_L_E_T_ = ' ' AND "
			cQuery += " GW3.D_E_L_E_T_ = ' '"
		Else	
		cQuery += "INNER JOIN " + RetSQLName( "GWH" ) + " GWH "
		cQuery += "ON GWH.GWH_FILIAL = GWF.GWF_FILIAL "
		cQuery += "AND GWH.GWH_NRCALC = GWF.GWF_NRCALC "
		cQuery += "INNER JOIN " + RetSQLName( "GW4" ) + " GW4 "
		cQuery += "ON GW4_FILIAL = GWH_FILIAL "
		cQuery += "AND GW4_TPDC = GWH_CDTPDC "
		cQuery += "AND GW4_SERDC = GWH_SERDC "
		cQuery += "AND GW4_EMISDC = GWH_EMISDC "
		cQuery += "AND GW4_NRDC = GWH_NRDC "
		cQuery += "INNER JOIN " + RetSQLName( "GW3" ) + " GW3 " 
		cQuery += "ON GW4_NRDF = GW3.GW3_NRDF "
		cQuery += "AND GW4_FILIAL = GW3_FILIAL "
		cQuery += "AND GW4_CDESP = GW3_CDESP "
		cQuery += "AND GW4_EMISDF = GW3_EMISDF "
		cQuery += "AND GW4_SERDF = GW3_SERDF "
		cQuery += "AND GW4_DTEMIS = GW3_DTEMIS "
		cQuery += "WHERE GW3.GW3_SITFIS = '4' "
		cQuery += " AND GWF.GWF_NRCALC = '" + cNrCalc + "' "
		cQuery += " AND GWF_FILIAL = '" + cFilCalc + "' "
		cQuery += " AND GWF.D_E_L_E_T_ = ' ' "
		cQuery += " AND GW3.D_E_L_E_T_ = ' ' "
		cQuery += " AND GWH.D_E_L_E_T_ = ' ' "
		cQuery += " AND GW4.D_E_L_E_T_ = ' ' "		
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			If lData
				xRet := STOD((cAliasQry)->GW3_DTFIS)
			Else
				xRet := .T.
			EndIf
		ElseIf lData
			xRet := STOD(Space(8))
		EndIf
		
		(cAliasQry)->(dbCloseArea())
	EndIf	
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105ATV
Retorna .T. se existe a tabela "GXN" - Sublote de estorno de Provisão.
Para verificação nos fontes GFEA096, GFEA096A e GFEA094A

@author Elynton Fellipe Bazzo
@since 12/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105ATV()
   Local lExistGXN
	
	If Select( "SX2" ) > 0
		If lExistGXN == Nil
			lExistGXN := GFXTB12117('GXN')  
		EndIf
	Else
		Return .F.
	EndIf
	
Return lExistGXN

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105DET
Função que realiza a deleção do último sublote de estorno gerado.

@author Elynton Fellipe Bazzo
@since 05/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105DET( cFilGxe,cCodLot )

	Local cTipoEst	:= SuperGetMv('MV_TPEST',, '1')
	Local lBlind	:= !IsBlind() //Esta função determina se a conexão efetuada com o Protheus não possui interface com o usuário.
	Local aArea		:= GetArea()
	
	If cTipoEst == "1" //Se o tipo de estorno for total.
		//"Opção disponível apenas para Provisão com Estorno Parcial"
		If lBlind
			Help( ,, 'HELP',,"Opção disponível apenas para Provisão com Estorno Parcial", 1, 0)
		EndIf
		Return .F.
	EndIf
	
	dbSelectArea( "GXE" )
	GXE->( dbSetOrder( 01 ))
	If GXE->( dbSeek( xFilial( "GXE" ) + cCodLot ))
		If GXE->GXE_SIT $ '1;2;3;4;5;7' //Se diferente de Estornado ou Estornado Parcial.
			Help( ,, 'HELP',,"Não é possível desfazer o último sublote quando a situação do lote for diferente de Estornado ou Estornado Parcial.", 1, 0)
			Return .F.
		EndIf
	EndIf
	
	//Busco o último registro de sublote de estorno (GXN).
	cAliasQry := GetNextAlias()
	cQuery := " SELECT GXN_FILIAL,GXN_CODLOT,GXN_CODEST FROM " + RetSQLName( "GXN" )
	cQuery += " WHERE R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) NRECNO FROM " + RetSQLName( "GXN" ) + " WHERE "
	cQuery += " GXN_FILIAL = '" + cFilGxe + "' AND GXN_CODLOT = '" + cCodLot + "'  AND D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If !(cAliasQry)->( Eof() )
		
		dbSelectArea( "GXN" )
		dbSetOrder( 01 )
		If GXN->(dbSeek( xFilial( "GXN" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST ))
			
			If GXN->GXN_SIT == '4' //Atualizado

				//Situação do Lote permanece como "Estornado Parcial", se houverem outros lotes de estorno 
				//ou é alterado para "Atualizado", caso não existam outros lotes.
				dbSelectArea( "GXE" )
				GXE->( dbSetOrder( 01 ))
				If GXE->( dbSeek( xFilial( "GXE" ) + (cAliasQry)->GXN_CODLOT ))
									
					dbSelectArea( "GXN" )
					RecLock( "GXN", .F. )
					GXN->GXN_SIT := "5" //Pendente Desatualização
					GXN->( MsUnlock( "GXN" ))
					
					dbSelectArea( "GXE" )
					RecLock( "GXE", .F. )
					GXE->GXE_SIT := "7" //Pendente estorno parcial
					GXE->( MsUnlock( "GXE" ))
					
					If lBlind
						//"Solicitação de desatualização do lote enviada ao ERP."
						Help( ,, 'HELP',,"Solicitação de desatualização do lote enviada ao ERP.", 1, 0)
					EndIf
					
				EndIf
			Else
				Help( ,, 'HELP',,"O último sublote não está atualizado. Se necessário, utilize a ação Excluir Sublote Estorno.", 1, 0)
			EndIf
		EndIf
	Else
		If lBlind
			//"Não foram encontrados sublotes de estornos pendentes."
			Help( ,, 'HELP',,"Não foram encontrados sublotes de estornos pendentes.", 1, 0)
		EndIf
	EndIf

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105VL
//Retorna o valor de um lote sem usar o model

@author Elynton Fellipe Bazzo
@since 10/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105VL( cFil,cLot,cSub )

	Local nValor := 0
	Default cFil := GXE->GXE_FILIAL
	Default cLot := GXE->GXE_CODLOT
	Default cSub := GXN->GXN_CODEST
	dbSelectArea( "GXO" )
	GXO->(dbSetOrder(1))
	GXO->(dbSeek(cFil + cLot + cSub))
	While !GXO->(Eof()) .And. GXO->GXO_FILIAL == cFil .And. GXO->GXO_CODLOT == cLot .And. GXO->GXO_CODEST == cSub
		nValor += GXO->GXO_VALOR
		GXO->(dbSkip())
	EndDo
	
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA105DEL
//Deleção de sublotes de estorno

@author Elynton Fellipe Bazzo
@since 06/04/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA105DEL( cFilGxe,cCodLot )

	Local cTipoEst	:= SuperGetMv('MV_TPEST',, '1')
	Local lBlind	:= !IsBlind() //Esta função determina se a conexão efetuada com o Protheus não possui interface com o usuário.
	Local cFilBkp	:= cFilant
	Local cSubLot	:= ""
	Local aArea		:= Getarea()
		
	If cTipoEst == "1" //Se o tipo de estorno for total.
		//"Opção disponível apenas para Provisão com Estorno Parcial"
		If lBlind
			Help( ,, 'HELP',,"Opção disponível apenas para Provisão com Estorno Parcial", 1, 0)
		EndIf
		Return .F.
	EndIf
	
	dbSelectArea( "GXE" )
	GXE->( dbSetOrder( 01 ))
	If GXE->( dbSeek( xFilial( "GXE" ) + cCodLot ))
		If GXE->GXE_SIT $ '1;2;3;5;7' //Se diferente de Estornado ou Estornado Parcial.
			Help( ,, 'HELP',,"Não é possível desfazer o último sublote quando a situação do lote for diferente de Estornado ou Estornado Parcial.", 1, 0)
			Return .F.
		EndIf
	EndIf
		
	If MsgYesNo("Essa ação irá excluir o último sublote. Deseja continuar?")
		
		//Busco o último registro de sublote de estorno (GXN).
		cAliasQry := GetNextAlias()
		cQuery := " SELECT GXN_FILIAL,GXN_CODLOT,GXN_CODEST FROM " + RetSQLName( "GXN" )
		cQuery += " WHERE R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) NRECNO FROM " + RetSQLName( "GXN" )
		cQuery += " WHERE GXN_FILIAL = '" + cFilGxe + "' AND GXN_CODLOT = '" + cCodLot + "' AND D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			cFilant := (cAliasQry)->GXN_FILIAL
			dbSelectArea( "GXN" )
			dbSetOrder( 01 )
			If GXN->(dbSeek( xFilial( "GXN" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST ))
				
				If GXN->GXN_SIT $ '1;3' //1=Nao-enviado;3=Rejeitado
					
					cSubLot := GXN->GXN_SIT
					
					//Sublote não integrado no Financeiro - Elimina o sublote e seus relacionamentos
					dbSelectArea( "GXO" )
					GXO->( dbSetOrder( 01 ))
					If dbSeek( xFilial( "GXO" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST )
						While !GXO->(Eof()) .And. xFilial( "GXO" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST == GXO->(GXO_FILIAL+GXO_CODLOT+GXO_CODEST)
							RecLock( "GXO", .F. )
							dbDelete()
							MsUnlock( "GXO" )
							GXO->( dbSkip() )
						EndDo
					EndIf
					
					//Antes de deletar o sublote de estorno, o campo código de estorno do Lote Provisão x Calculo Frete é setado como vazio. 
					dbSelectArea( "GXD" )
					GXD->( dbSetOrder( 03 ))
					If GXD->( dbSeek( xFilial( "GXD" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST ))
						While !GXD->(Eof()) .And. xFilial( "GXD" ) + (cAliasQry)->GXN_CODLOT  == GXD->(GXD_FILIAL+GXD_CODLOT)
							If (cAliasQry)->GXN_CODEST == GXD->GXD_CODEST
								RecLock( "GXD", .F. )
								GXD->GXD_CODEST := ""
								GXD->GXD_MOTIES := ""
								MsUnlock( "GXD" )
							EndIf
							GXD->( dbSkip() )
						EndDo
					EndIf
					
					// Removido o relacionamento do sublote com os movimentos contábeis.
					dbSelectArea( "GWA" )
					GWA->( dbSetOrder( 07 ))
					If GWA->( dbSeek( xFilial( "GWA" ) + (cAliasQry)->GXN_CODLOT + (cAliasQry)->GXN_CODEST ))
						While !GWA->(Eof()) .And. xFilial( "GWA" ) + (cAliasQry)->GXN_CODLOT == GWA->(GWA_FILIAL+GWA_CODLOT)
							If (cAliasQry)->GXN_CODEST == GWA->GWA_CODEST 
								RecLock( "GWA", .F. )
								GWA->GWA_CODEST := ""
								MsUnlock( "GWA" )
							EndIf
							GWA->( dbSkip() )
						EndDo
					EndIf
					
					//Desfaz o último sublote de Estorno gerado
					dbSelectArea( "GXN" )
					RecLock( "GXN", .F. )
					dbDelete()
					MsUnlock( "GXN" )
					
					dbSelectArea( "GXN" )
					GXN->( dbSetOrder( 01 ))
					If !GXN->( dbSeek( xFilial( "GXN" ) + cCodLot )) //Se não encontrar um sublote de estorno 
						dbSelectArea( "GXE" )
						GXE->( dbSetOrder( 01 ))
						If GXE->( dbSeek( xFilial( "GXE" ) + cCodLot ))
							RecLock( "GXE", .F. )
							GXE->GXE_SIT := "4" //Atualizado
							MsUnlock( "GXE" )
						EndIf
					Else
						dbSelectArea( "GXE" )
						GXE->( dbSetOrder( 01 ))
						If GXE->( dbSeek( xFilial( "GXE" ) + cCodLot ))
							RecLock( "GXE", .F. )
							GXE->GXE_SIT := "8" //Estornado Parcial
							MsUnlock( "GXE" )
						EndIf
					EndIf
					
					If lBlind
						Help( ,, 'HELP',,"Sublote de estorno eliminado com sucesso.", 1, 0) //"Sublote de estorno eliminado com sucesso."
					EndIf
				Else
					Help( ,, 'HELP',,"Utilize a ação Desatualizar Sublote ERP antes de excluir o sublote.", 1, 0)
				EndIf
			EndIf
		Else
			//"Não foram encontrados sublotes de estornos pendentes."
			Help( ,, 'HELP',,"Não foram encontrados sublotes de estornos pendentes.", 1, 0)
		EndIf
	
		(cAliasQry)->(dbCloseArea())
		cFilant := cFilBkp
		RestArea(aArea)

	Else
		Return .F.
	EndIf
	
Return .T.
