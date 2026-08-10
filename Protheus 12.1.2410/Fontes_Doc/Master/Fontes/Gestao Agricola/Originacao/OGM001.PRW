#INCLUDE "OGM001.ch"
#Include 'Protheus.ch'

/** {Protheus.doc} OGM001
Rotina para recalculo de saldos dos contratos
@author Marlon Richard Trettin
@since 10/04/2015
@version 2.0
@type function
*/
Function OGM001()
	Private cPergunta	:= "OGM001001"

	If .Not. Pergunte( cPergunta, .t. )
		Return( Nil )
	EndIf

	If MsgYesNo( STR0001, STR0002 ) //"Deseja processar o recálculo de saldo dos contratos?"###"Atenção"
		oProcess := MsNewProcess():New( { |lEnd| OGM001Repr( @oProcess, @lEnd) }, STR0003, STR0004, .t.)  //"Reprocessamento de Contratos"###"Lendo Registros"
		oProcess:Activate()
		MsgInfo(STR0007,STR0002) //"Contratos atualizado com sucesso!"###"Atenção"
	EndIf

Return ( Nil )

/** {Protheus.doc} OGM001Repr
Rotina para recalculo de saldos dos contratos
@author Marlon Richard Trettin
@since 10/04/2015
@version 2.0
@type function
*/

Static Function OGM001Repr( oProcess, lEnd )
	Local nVlrSFis	:= 0
	Local nVlrEFis	:= 0
	Local nTotCtr		:= 0
	Local cAliasQry	 := ""
	Local cAliasQry2 := ""
	Local cQuery 		:= ""
	Local nVlrTotSD2 := 0
	Local cCtrDe		:= mv_par01
	Local cCtrAte		:= mv_par02
	Local cFiltro		:= "NJR_FILIAL = '" + xFilial( "NJR" ) + "' .And. NJR_CODCTR >= '" + cCtrDe + "' .And. NJR_CODCTR <= '" + cCtrAte + "'"
	Default lEnd 		:= .F.

	DbSelectArea("NJR")
	NJR->(DbSetOrder( 1 ))
	NJR->(DbSetFilter( {|| &cFiltro }, cFiltro ))

	oProcess:SetRegua1( NJR->( RecCount( ) ) )
	oProcess:SetRegua2( 0 )

	NJR->(DbGotop())
	While .Not. NJR->( Eof() )

		If lEnd
			Exit
		EndIf

		oProcess:IncRegua1( OemToAnsi( STR0006 ) +"[ "+ NJR->( NJR_CODCTR ) +" ]..." ) //"Atualizando contrato [ ###### ]..."

		If NJR->( NJR_STATUS ) $ "E|F"
			NJR->( dbSkip() )
			Loop
		EndIf

		//////////////////////////
		// Atualiza contratos
		//////////////////////////
		NJR->( RecLock("NJR",.F.) )
		NJR->( NJR_QTSFCO ) := 0
		NJR->( NJR_QTSFIS ) := 0
		NJR->( NJR_VLSFIS ) := 0
		NJR->( NJR_QTEFCO ) := 0
		NJR->( NJR_QTEFIS ) := 0
		NJR->( NJR_VLEFIS ) := 0

		//Ajusta NJM -  Devolução Compra / Devolução depósito
		cAliasQry	:= GetNextAlias()
		cQuery := " SELECT NJM.NJM_FILIAL, NJM.NJM_CODENT, NJM.NJM_LOJENT, NJM.NJM_DOCNUM, NJM.NJM_DOCSER, "
		cQuery += " NJM.R_E_C_N_O_ E2Registro, NJJ.NJJ_TIPO "
		cQuery += " FROM " + RetSqlName("NJM") + " NJM "
		cQuery += " INNER JOIN " + RetSqlName("NJJ") + " NJJ ON NJJ.D_E_L_E_T_  =  ' ' "
		cQuery += " AND NJJ.NJJ_FILIAL = NJM.NJM_FILIAL "
		cQuery += " AND NJJ.NJJ_CODROM = NJM.NJM_CODROM "
		cQuery += " AND NJJ.NJJ_STATUS IN ('3') "   // somente confirmado
		cQuery += " and NJJ.NJJ_TIPO   IN ('6','8') "
		cQuery += " WHERE NJM.D_E_L_E_T_  =  ' ' "
		cQuery += " AND NJM_FILIAL LIKE  '%" + Alltrim(NJR->( NJR_FILIAL)) + "%' "
		cQuery += " AND NJM_CODCTR = '" + NJR->( NJR_CODCTR ) + "' "
		cQuery := ChangeQuery(cQuery)		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasQry),.F.,.T.)	

		(cAliasQry)->( dbGoTop() )
		While .Not. (cAliasQry)->( Eof() )

			// Buscar as notas de saída
			dbSelectArea('NJ0')
			NJ0->(dbSetOrder( 1 ))
			If NJ0->(dbSeek( xFilial( "NJ0" ) + ( cAliasQry )->NJM_CODENT + ( cAliasQry )->NJM_LOJENT ))  
											
				dbSelectArea('SF2')
				SF2->(dbSetOrder(2))
				If  SF2->(dbSeek(( cAliasQry )->NJM_FILIAL + NJ0->NJ0_CODCLI + NJ0->NJ0_LOJCLI + ( cAliasQry )->NJM_DOCNUM + ( cAliasQry )->NJM_DOCSER))

					cAliasQry2 := GetNextAlias()                     
					BeginSql Alias cAliasQry2
					SELECT D2_TOTAL
					FROM %Table:SD2% SD2
					WHERE SD2.%notDel%
					AND D2_FILIAL  = %exp:( cAliasQry )->NJM_FILIAL%
					AND D2_DOC     = %exp:SF2->F2_DOC%
					AND D2_SERIE   = %exp:SF2->F2_SERIE%
					AND D2_CLIENTE = %exp:SF2->F2_CLIENTE%
					AND D2_LOJA    = %exp:SF2->F2_LOJA%
					EndSQL

					nVlrTotSD2 := 0 //zera o contador

					dbSelectArea(cAliasQry2)
					(cAliasQry2)->( dbGoTop() )
					While .Not. (cAliasQry2)->( Eof() ) //soma os valores
						nVlrTotSD2 += (cAliasQry2)->D2_TOTAL
						(cAliasQry2)->( DbSkip() )
					endDo
					(cAliasQry2)->( dbCloseArea() )

					dbSelectArea('NJM')
					NJM->( DbGoTo(( cAliasQry )->E2Registro  ) )	//posiciona conforme recno		

					If RecLock( "NJM", .F. )
						//atualiza a NJM com o valor total e unitário				
						NJM->( NJM_VLRUNI ) := Round(( nVlrTotSD2 / NJM->( NJM_QTDFIS )),TamSX3( "NJM_VLRUNI" )[2])
						NJM->( NJM_VLRTOT ) := NJM->( NJM_VLRUNI ) * NJM->( NJM_QTDFIS )
						msUnLock("NJM")

						//atualiza os dados da NJJ
						OGX140AtNJJ( ( cAliasQry )->NJM_FILIAL, NJM->( NJM_CODROM ) )
					endif			    

				endif 
			endif	
			(cAliasQry)->( DbSkip() ) 
		endDo

		//////////////////////////
		// Ajusta valores totais da NJR
		//////////////////////////	
		cAliasQry	:= GetNextAlias()
		cQuery := " SELECT NJJ.NJJ_TIPO,
		cQuery += " SUM(NJM.NJM_QTDFIS) NJM_QTDFIS, "
		cQuery += " SUM(NJM.NJM_QTDFCO) NJM_QTDFCO, "
		cQuery += " SUM(NJM.NJM_VLRTOT) NJM_VLRTOT "
		cQuery += " FROM " + RetSqlName("NJM") + " NJM "
		cQuery += " INNER JOIN " + RetSqlName("NJJ") + " NJJ ON NJJ.D_E_L_E_T_ = ' ' " 
		cQuery += " AND NJJ.NJJ_FILIAL = NJM.NJM_FILIAL " 
		cQuery += " AND NJJ.NJJ_CODROM = NJM.NJM_CODROM "
		cQuery += " AND NJJ.NJJ_STATUS IN ('2','3') "
		cQuery += " WHERE NJM.D_E_L_E_T_ = ' ' "
		cQuery += " AND NJM_FILIAL LIKE  '%" + Alltrim(NJR->( NJR_FILIAL)) + "%' "
		cQuery += " AND NJM_CODCTR = '" + NJR->( NJR_CODCTR ) + "' "		  
		cQuery += " GROUP BY NJJ_TIPO "
		cQuery := ChangeQuery(cQuery)		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasQry),.F.,.T.)

		(cAliasQry)->( dbGoTop() )
		While .Not. (cAliasQry)->( Eof() )
			If (cAliasQry)->( NJJ_TIPO ) $ "2/4/6/8"
				NJR->( NJR_QTSFCO ) += (cAliasQry)->( NJM_QTDFCO )
				NJR->( NJR_QTSFIS ) += (cAliasQry)->( NJM_QTDFIS )
				NJR->( NJR_VLSFIS ) += (cAliasQry)->( NJM_VLRTOT )

				nVlrSFis += (cAliasQry)->( NJM_VLRTOT )

			ElseIf (cAliasQry)->( NJJ_TIPO ) $ "3/5/7/9"
				NJR->( NJR_QTEFCO ) += (cAliasQry)->( NJM_QTDFCO )
				NJR->( NJR_QTEFIS ) += (cAliasQry)->( NJM_QTDFIS )
				NJR->( NJR_VLEFIS ) += (cAliasQry)->( NJM_VLRTOT )

				nVlrEFis += (cAliasQry)->( NJM_VLRTOT )

			EndIf
			oProcess:IncRegua2( OemToAnsi( STR0011 ) ) //"Lendo romaneios..."
			(cAliasQry)->( DbSkip() )
		EndDo
		NJR->( MsUnLock() )
		(cAliasQry)->( dbCloseArea() )

		//////////////////////////
		// Atualiza quantidades do contrato de acordo com as aditações / supressões
		//////////////////////////
		OGA335AtuQtd()

		//////////////////////////
		// Atualiza qtdes do contrato e saldos
		//////////////////////////
		OGX010QTDS()

		//////////////////////////
		// Atualiza autorizações
		//////////////////////////
		OGX010QAut()

		//////////////////////////
		// Atualiza reservas
		//////////////////////////

		If NJR->( RecLock("NJR",.F.) )
			NJR->NJR_QTDRES := 0      // INICIALIZAR COM ZERO PARA RECOMPOR COM BASE NA NJB

			dbSelectArea('NJB')
			dbSetOrder(2)
			If (dbSeek( xFilial('NJB') + NJR->( NJR_CODCTR )))
				While !( NJB->( Eof() ) ) .And. xFilial( 'NJB' ) + NJB->( NJB_CODCTR ) == NJB->( NJB_FILIAL ) + NJR->( NJR_CODCTR )
					If NJB->NJB_STATUS == '1'     // RESERVADO
						NJR->NJR_QTDRES := NJR->NJR_QTDRES + NJB->NJB_QTDPRO
					EndIf
					oProcess:IncRegua2( OemToAnsi( STR0013 ) ) //"Atualizando reservas..."
					NJB->( dbSkip() )    
				EndDo
			EndIf
			NJR->( MsUnLock() )
		EndIf

		//////////////////////////
		// Atualiza financeiro
		//////////////////////////

		If NJR->( NJR_TIPO ) == "1" //COMPRA

			nTotCtr := ( NJR->( NJR_VLRTOT ) - nVlrEFis ) + nVlrSFis

			cAliasQry	:= GetNextAlias()
			BeginSql Alias cAliasQry
			Select
			R_E_C_N_O_ as E2Registro
			From
			%table:SE2% SE2
			Where
			SE2.E2_PREFIXO In ( 'CTR', 'FX1', 'FX2' ) And
			SE2.E2_NUM = %exp:NJR->( NJR_CODCTR )% And
			SE2.E2_TIPO = 'PR' And
			SE2.%NotDel%
			EndSql
		
			(cAliasQry)->( dbGoTop() )
			While .Not. (cAliasQry)->( Eof() )
				dbSelectArea( "SE2" )
				dbGoto( (cAliasQry)->( E2Registro ) )
				RecLock( "SE2", .f. )

				If nTotCtr <= 0
					dbDelete()
				Else
					E2_VALOR	:= nTotCtr
					E2_SALDO	:= nTotCtr
					E2_VLCRUZ	:= nTotCtr
				EndIf
				SE2->( msUnLock() )
				oProcess:IncRegua2( OemToAnsi( STR0013) ) //"Atualizando financeiro..."
				(cAliasQry)->( dbSkip() )
			EndDo
			(cAliasQry)->( dbCloseArea() )

		Else

			cAliasQry	:= GetNextAlias()
			BeginSql Alias cAliasQry
			Select
			R_E_C_N_O_ as E1Registro
			From
			%table:SE1% SE1
			Where
			SE1.E1_PREFIXO In ( 'CTR', 'FX1', 'FX2' ) And
			SE1.E1_NUM = %exp:NJR->( NJR_CODCTR )% And
			SE1.E1_TIPO = 'PR' And
			SE1.%NotDel%
			EndSql
		
			(cAliasQry)->( dbGoTop() )
			While .Not. (cAliasQry)->( Eof() )
				dbSelectArea( "SE1" )
				dbGoto( (cAliasQry)->( E1Registro ) )
				RecLock( "SE1", .f. )

				If nTotCtr <= 0
					dbDelete()
				Else
					E1_VALOR 	:= nTotCtr
					E1_SALDO	:= nTotCtr
					E1_VLCRUZ	:= nTotCtr
				EndIf

				SE1->( msUnLock() )
				oProcess:IncRegua2( OemToAnsi( STR0013) ) //"Atualizando financeiro..."
				(cAliasQry)->( dbSkip() )
			EndDo
			(cAliasQry)->( dbCloseArea() )
		EndIf
		NJR->( MsUnLock() )

		oProcess:IncRegua2()

		NJR->( DbSkip() )
	EndDo
	NJR->( dbClearFilter() )

Return( Nil )
