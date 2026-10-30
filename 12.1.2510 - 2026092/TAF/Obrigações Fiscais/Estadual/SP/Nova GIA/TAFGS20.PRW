#Include "Protheus.ch"


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS20

Rotina de geração do registro CR=20 da GIA-SP - OCORRENCIA

@Param cCNAE		->	CNAE da Filial que de geração
		cCNPJ   	->	Cnpj da Filial que de geração
		cInscEst  	->	Inscrição Estadual da Filial que de geração
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread

@Author Paulo V.B. Santana
@Since 27/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGS20( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn  )

Local oError	  := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

Local cREG 		  := "CR20" + cInscEst
Local cStrTxt 	  := ""
Local cStrTxt20   := ""
Local cStrTxt25   := ""
Local cStrTxt26   := ""
Local cStrTxt27   := ""
Local cStrTxt28	  := ""
Local cTxtSys  	  := CriaTrab( , .F. ) + ".TXT"
Local nHandle     := MsFCreate( cTxtSys )
Local cAnoMesRef  := Alltrim( aWizard[1][11]) + Alltrim(aWizard[1][9] )
Local cRegTrib	  := Alltrim( Left(aWizard[1][10],2) )
Local cIeSubs     := ""
Local cAnoMesIni  := Alltrim(aWizard[1][13]) + Alltrim(aWizard[1][12])
Local cMesAnoRef  := Alltrim(aWizard[1][9]) + Alltrim(aWizard[1][11])
Local cCodSubi    := ""
Local cOperac     := ""
Local cCodAut     := ""
Local nValor20    := 0
Local nValor25    := 0
Local nValor26    := 0
Local nValor27    := 0
Local nValor28    := 0
Local nScanCR20   := 0
Local nPosCR20    := 0
Local nQtd20      := 0 
Local nQtd25      := 0
Local nQtd26      := 0
Local nQtd27      := 0
Local nQtd28      := 0
Local cAliasQry   := GetNextAlias()
Local cAliasQry25 := GetNextAlias()
Local cFlegal 	  := "" 
Local cOcorren    := ""
Local lFound      := .T.
Local cFundLegal  := ""
Local cDescri     := ""
Local nSeqReg 	  := 0
Local aCR20		  := {}
Local aCR25		  := {}
Local aCR20Tot    := {}
Local nPosCR25	  := 0
Local cCfop		  := ""
Local lApura	  := .f.
Local i           := 0

Default cMesRef	  := ""
Default	cAnoRef	  := ""
Default	lSomaFil  := .F.  
Default	cIn		  := ""

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence  
  
QryCR20(cAnoMesRef,cFilSel,cAliasQry, cIn)  
(cAliasQry)->(dbGotop()) 

While ( cAliasQry )->( !Eof() )

	cStrTxt 	:= ""
	cStrTxt20 	:= ""
	cStrTxt25 	:= "" 
	cStrTxt26 	:= ""
	cStrTxt27 	:= ""
	cStrTxt28	:= ""

	nValor20   := 0
	nValor25   := 0
	nValor26   := 0
	nValor27   := 0
	nValor28   := 0
	
	//PrópriaOuST=0 e RegTrib=04 não podem ocorrer em conjunto ou operação '0' para seguintes cfops
	While (( cAliasQry )->( !Eof() ) .And. ( cAliasQry )->OPERAC == '0' ;
	    .And. cRegTrib == '04') .OR.  (( cAliasQry )->OPERAC == '0' ;
		.AND.( cAliasQry )->CODSUBITEM $ ( "00201|00203|00204|00702|00703|00205|00701|00715" ) ) 
		( cAliasQry )->( dbSkip() )
	End
		
	If Alltrim(( cAliasQry )->REGISTRO) == 'CR20'

		cCodSubi   := ( cAliasQry )->CODSUBITEM
		cOperac    := ( cAliasQry )->OPERAC
		nSeqReg    := ( cAliasQry )->SEQREG
		cCodAjApur := ( cAliasQry )->CODAJU
	
		if ( cAliasQry )->CODSUBITEM $ ("00299|00399|00799|00899|01499")
			// para o caso específico de 00299 podemos atribuir a mesma descrição
			// em implementações de outros cóodigos, avaliar com critérios, a escrituração de cFundLegal
			cDescri := cFundLegal := alltrim(GetDescri(cAnoMesRef, cFilSel, cCodSubi, nSeqReg, cOperac, ( cAliasQry )->IDPAI))
		else
			cDescri    := alltrim(( cAliasQry )->DESCRI)
			cFundLegal := alltrim(( cAliasQry )->FLEGAL)
		endif
		
		If cCodSubi == ( cAliasQry )->CODSUBITEM .And. cOperac == ( cAliasQry )->OPERAC .AND. alltrim(( cAliasQry )->REGISTRO) == 'CR20'
			nValor20	+= ( cAliasQry )->VALOR
		Endif
		
		If cOperac == '1'
		
			nScanCR20 := AScan(aCR20Tot, {|x|  x[02] == AllTrim(cOperac) .and. x[06] == AllTrim(cCodAjApur) .and. AllTrim(x[03]) == AllTrim(cDescri) .and. x[01] == Alltrim(cCodSubi)})

			If nScanCR20 == 0
				aAdd(aCR20Tot, {})	
				nPosCR20 :=	Len(aCR20Tot)
				aAdd (aCR20Tot[nPosCR20], AllTrim(cCodSubi))				   				
				aAdd (aCR20Tot[nPosCR20], AllTrim(cOperac))
				aAdd (aCR20Tot[nPosCR20], AllTrim(cDescri))
				aAdd (aCR20Tot[nPosCR20], AllTrim(cFundLegal))
				aAdd (aCR20Tot[nPosCR20], nValor20)
				aAdd (aCR20Tot[nPosCR20], AllTrim(cCodAjApur))
			Else
				aCR20Tot[nScanCR20][05] += nValor20
			EndIf

			( cAliasQry )->( dbSkip() )

			If (cAliasQry)->(EOF()) .or. Alltrim((cAliasQry)->REGISTRO) <> 'CR20'

				For i := 1 To Len(aCR20Tot)

					cStrTxt20 	:= ""
					nQtd20++

					cFlegal := Iif( right(aCR20Tot[i][1],2)=='99', PADL(aCR20Tot[i][4],100),Space(100) )
					cOcorren:= Iif( right(aCR20Tot[i][1],2)=='99', PADL(aCR20Tot[i][3],300),Space(300) )
				
					cStrTxt20	:= "20"
					cStrTxt20	+= aCR20Tot[i][1]
					cStrTxt20	+= xConvGIA(aCR20Tot[i][5],15)
					cStrTxt20	+= aCR20Tot[i][2]
					cStrTxt20	+= cFlegal
					cStrTxt20	+= cOcorren

					aadd(aCR20, {cStrTxt20})

				Next i

				aCR20Tot := {}
			EndIf
		Else
			nQtd20++

			cFlegal := Iif( right(cCodSubi,2)=='99', PADL(cFundLegal,100),Space(100) )
			cOcorren:= Iif( right(cCodSubi,2)=='99', PADL(cDescri   ,300),Space(300) )
			
			cStrTxt20	:= "20"
			cStrTxt20	+= cCodSubi
			cStrTxt20	+= xConvGIA(nValor20,15)
			cStrTxt20	+= cOperac
			cStrTxt20	+= cFlegal
			cStrTxt20	+= cOcorren

			aadd(aCR20, {cStrTxt20})
			
			( cAliasQry )->( dbSkip() )
		EndIf		  				
	Endif
	
	// Recebimentos - Entradas
	If cCodSubi  $ ('00219')
		cCfop := "'1605'"
	ElseIf cCodSubi  $ ('00704|00705|00706|00707|00747')
	  	cCfop := "'1601'"
	ElseIf cCodSubi  $ ('00730')
	  	cCfop := "'1602'"

	// Transferência - Saídas
	ElseIf cCodSubi  $ ('00218')
	  	cCfop := "'5602'"
	ElseIf cCodSubi  $ ('00225')
	  	cCfop := "'5601'"
	ElseIf cCodSubi  $ ('00729')
		cCfop := "'5605'"

	// Entrada e Saída - ST
	ElseIf cCodSubi  $ ('00210') 
	  	cCfop := "'1603','5603','6603'"
	Endif
	
	If !Empty(cCfop)
		lApura := .f.
		QryCR25(cAnoMesRef,cFilSel,cAliasQry25,cCfop,cCodSubi,@lApura, cIn)
		(cAliasQry25)->(dbGotop())
		
		if alltrim(( cAliasQry25 )->REGISTRO) == 'CR25'
			
			aCR25 	:= {}
			nQtd25	:= 0

			While ( cAliasQry25 )->( !Eof() ) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//³IES remetentes CR=25                                                                                           ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				
				nValor25 	:= ( cAliasQry25 )->VALOR
				if lApura
					C2T->(DbGoTo( ( cAliasQry25 )->RECC2T ))
					cIE := C2T->C2T_AJUCOM
				else
					cIE	:= iif( empty((cAliasQry25)->IE), space(12),alltrim(( cAliasQry25 )->IE) )
				endif	

				nPosCR25 := aScan( aCR25, { |x| x[ 2 ] == Alltrim(cIE) } )

				if nPosCR25 > 0
					aCR25[nPosCR25][3] += nValor25
				else
					aadd(aCR25,{"25",Substr(cIE,1,12),nValor25} )
				endif	

				( cAliasQry25 )->( dbSkip() )
			Enddo

			aCR25:= Asort(aCR25, , , { | x,y | x[2] < y[2] } )

			For i:= 1 to len(aCR25)
				cStrTxt25	:= "25"
				cStrTxt25	+= aCR25[i][2]
				cStrTxt25	+= xConvGIA(aCR25[i][3],15)
				cStrTxt	+= cStrTxt25 + CRLF
				nQtd25++
				aadd(aCR20, {cStrTxt25})
			Next		
						
			cIE := ""
		Endif
		cCfop := ''
		( cAliasQry25 )->( DbCloseArea() )
	endif
	
	//( cAliasQry )->( dbSkip() )	
			
	If alltrim(( cAliasQry )->REGISTRO) =='CR26'
		cIeSubs:= alltrim(( cAliasQry )->IE)
		cNF    := Alltrim(( cAliasQry )->NUMDOC)
				
		While 	( cAliasQry )->( !Eof() ) 
			if cIeSubs == alltrim(( cAliasQry )->IE) .And. cNF == Alltrim(( cAliasQry )->NUMDOC) .AND. alltrim(( cAliasQry )->REGISTRO) == 'CR26'
				nValor26 += ( cAliasQry )->VALOR
			else
				exit
			endif
			nQtd26++	
			( cAliasQry )->( dbSkip())
		Enddo
		If cCodSubi == '00211'
			cNF    := '000000000' 
		Endif			
		cStrTxt26:= "26"
		cStrTxt26+= Substr(cIeSubs,1,12)									    		// IE
		cStrTxt26+= iif(Alltrim(cCodSubi) == '00211','000000000',right(cNF,9))	// NF
		cStrTxt26+= cAnoMesIni									    					// DataInicio
		cStrTxt26+= right(Alltrim(cMesAnoRef),4) + Left(Alltrim(cMesAnoRef),2)	// DataFim
		cStrTxt26+= xConvGIA(nValor26,15)  				 				  			// Valor

		aadd(aCR20, {cStrTxt26})
	Endif

	If alltrim(( cAliasQry )->REGISTRO) =='CR27'
		cIeSubs:= alltrim(( cAliasQry )->IE )
		cNF    := alltrim(( cAliasQry )->NUMDOC )
			
		While 	( cAliasQry )->( !Eof() )
			if cIeSubs == alltrim(( cAliasQry )->IE) .And. cNF == alltrim(( cAliasQry )->NUMDOC) .And. alltrim(( cAliasQry )->REGISTRO) == 'CR27'			
				nValor27 += ( cAliasQry )->VALOR		
			else
				exit
			endif
			nQtd27++
			( cAliasQry )->( dbSkip())
		Enddo
		cStrTxt27:= "27"
		cStrTxt27+= Substr(cIeSubs,1,12)   								    			// IE
		cStrTxt27+= SubSTR(cNF,1,9)											    			// NF
		cStrTxt27+=  xConvGIA(nValor27,15)						    					   	// Valor
		
		aadd(aCR20, {cStrTxt27})
	
	Endif

	If alltrim(( cAliasQry )->REGISTRO) =='CR28'
		cCodAut:= alltrim(( cAliasQry )->CODAUTORIZA)
		While ( cAliasQry )->( !Eof() )
		
			if cCodAut == alltrim(( cAliasQry )->CODAUTORIZA) .AND. alltrim(( cAliasQry )->REGISTRO) == 'CR28'
				nValor28 += ( cAliasQry )->VALOR		
			else
				exit
			endif
			nQtd28++
			( cAliasQry )->( dbSkip())
		Enddo
		cStrTxt28:= "28"
		cStrTxt28+= subSTR(cCodAut,1,12)														// CodAutorizacao
		cStrTxt28+= xConvGIA(nValor28,15)						    	     				   	// Valor
		//cStrTxt28+= CRLF
		
		aadd(aCR20, {cStrTxt28})
	
	Endif	

	if ( cAliasQry )->(eof()) .or. alltrim(( cAliasQry )->REGISTRO) =='CR20'
		for i := 1 to len(aCR20)
			if left(aCR20[i][1],2) == '20'
				aCR20[i][1] += Strzero(nQtd25,4) + Strzero(nQtd26,4) + Iif(Substr(aCR20[i][1],3,5) $ '00701|00702',Strzero(nQtd27,4),'0000') + Strzero(nQtd28,4)
			endif	
			WrtStrTxt( nHandle, aCR20[i][1] + CRLF )
		next
		nQtd25     := 0
		nQtd26     := 0
		nQtd27     := 0
		nQtd28     := 0
		aCR20 := {}		
	endif

End

cStrTxt:= "QTD" + STRZERO(nQtd20,4)
WrtStrTxt( nHandle, cStrTxt )

GerTxtGIA( nHandle, cTXTSys, cReg)

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
/*/{Protheus.doc} QryCR20

Efetua query que busca os registros referentes ao registro CR=20 - 
Ocorrencias e os registros filhos

@Param canoMEsRef-> Ano e mes referencia 
		cFilSel -> Filial selecionada

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function QryCR20(cAnoMesRef,cFilSel,cAliasQry, cIn)
Local cSelect   := ""
Local cWhere    := ""
Local cFrom     := ""
Local cSelect2  := ""
Local cWhere2   := ""
Local cGrpBy2   := ""
Local cFrom2    := ""
Local cSelect3  := ""
Local cWhere3   := ""
Local cFrom3    := ""
Local cSelect5  := ""
Local cWhere5   := ""
Local cFrom5    := ""
Local cSelect6  := ""
Local cWhere6   := ""
Local cFrom6    := ""
Local cSelect7  := ""
Local cWhere7   := ""
Local cFrom7    := ""
Local cSelect8  := ""
Local cWhere8   := ""
Local cFrom8    := ""
Local cDtiniRef := Dtos(Firstday(stod(cAnoMesRef+'01'),1))
Local cDtFimRef := BuscaDiaUtil(Dtos(Firstday(stod(cAnoMesRef+'01'),1))) 
Local cFilAux 	:= cFilAnt
Local lIN		:= .F.
Local cInC3K	:= ""
Local cInC2S	:= ""
Local cInC2T	:= ""
Local cInC1H	:= ""
Local cInC20	:= ""
Local cInC2D	:= ""
Local cBd		:= TcGetDb()
Default	cIn		:= ""


lIN	:=	Iif( !Empty(cIn), .T., .F. )

If lIN
	cInC3K	:=	INCompFil("C3K", cFilSel, cIn)
	cInC2S	:=	INCompFil("C2S", cFilSel, cIn)
	cInC2T	:=	INCompFil("C2T", cFilSel, cIn)
	cInC1H	:=	INCompFil("C1H", cFilSel, cIn)
	cInC20	:=	INCompFil("C20", cFilSel, cIn)
	cInC2D	:=	INCompFil("C2D", cFilSel, cIn)
EndIf

cFilAnt := cFilSel

//--------------------------------------------------------------------------
//REGISTRO CR=20												                  ||
//--------------------------------------------------------------------------
cSelect := " 'CR20' REGISTRO, C3J.C3J_ID IDPAI, C3K.C3K_CODAJU CODAJU, C3K.C3K_VLRAJU VALOR, CHY.CHY_CODIGO CODSUBITEM,"
If TAFColumnPos('C3K_SEQREG')
	cSelect += " CASE WHEN CHY.CHY_CODIGO IN ('00299','00399','00799','00899','01499') THEN CAST(C3K.C3K_SEQREG AS INTEGER) ELSE 0 END SEQREG,"
Else
	cSelect += " 0 SEQREG, " 
Endif
cSelect += " CHY.CHY_DESCRI DESCRI,CHY.CHY_FLEGAL FLEGAL,' ' IE,CHY.CHY_OPERAC OPERAC, ' ' NUMDOC,"
cSelect += " ' ' UFPART, ' ' CODAUTORIZA "    

cFrom  := RetSqlName("C3K") + " C3K "
cFrom  += " INNER JOIN " + RetSqlName("C3J") + " C3J ON C3J.C3J_FILIAL = C3K.C3K_FILIAL AND C3J.C3J_ID = C3K.C3K_ID AND C3J.C3J_DTINI >= '" + cDtiniRef + "' AND C3J.C3J_DTFIN <= '" + cDtFimRef + "' AND C3J.C3J_UF = '000027' AND C3J.D_E_L_E_T_ = ' ' "
cFrom  += " INNER JOIN " + RetSqlName("CHY") + " CHY ON CHY.CHY_FILIAL = '" + xFilial("CHY") + "' AND CHY.CHY_ID = C3K.C3K_IDSUBI AND CHY.D_E_L_E_T_ = ' ' "  
 
cWhere += " C3K.C3K_FILIAL IN (" + Iif( lIN, cInC3K , "'" +xFilial("C3K")+ "'") + ") AND C3K.D_E_L_E_T_ = ' ' "

cSelect2 := " 'CR20' REGISTRO, ' ' IDPAI, ' ' CODAJU, SUM(C2T.C2T_VLRAJU) VALOR, CHY.CHY_CODIGO CODSUBITEM, CASE WHEN CHY.CHY_CODIGO IN ('00299','00399','00799','00899','01499') THEN C2T.C2T_SEQREG ELSE 0 END SEQREG, CHY.CHY_DESCRI DESCRI,CHY.CHY_FLEGAL FLEGAL,' ' IE,CHY.CHY_OPERAC OPERAC,' ' NUMDOC,' ' UFPART,' ' CODAUTORIZA "

cFrom2   := RetSqlName("C2T") + " C2T "
cFrom2   += " INNER JOIN " + RetSqlName("C2S") + " C2S ON C2S.C2S_FILIAL = C2T.C2T_FILIAL AND C2S.C2S_ID = C2T.C2T_ID AND C2S.C2S_DTINI >='" + cDtIniRef + "' AND C2S.C2S_DTFIN <= '" + cDtFimRef + "' AND C2S.D_E_L_E_T_ = ' ' "
cFrom2   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON C2T.C2T_IDSUBI = CHY.CHY_ID AND CHY.D_E_L_E_T_ = ' ' "   

cWhere2  += " C2T.C2T_FILIAL IN (" + Iif( lIN, cInC2T , "'" +xFilial("C2T")+ "'") + ") AND C2T.D_E_L_E_T_ = ' ' "

cGrpBy2  := " CHY.CHY_CODIGO,CHY.CHY_DESCRI,CHY.CHY_FLEGAL,CHY.CHY_OPERAC,"+iif(cBd $ "INFORMIX"," SEQREG"," CASE WHEN CHY.CHY_CODIGO IN('00299','00399','00799','00899','01499') THEN C2T.C2T_SEQREG ELSE 0 END")

cSelect3 := " 'CR20' REGISTRO, ' ' IDPAI, ' ' CODAJU, C2D.C2D_VLICM VALOR, CHY.CHY_CODIGO CODSUBITEM, 0 SEQREG, CHY.CHY_DESCRI DESCRI, CHY.CHY_FLEGAL FLEGAL, C1H.C1H_IE IE, CHY.CHY_OPERAC OPERAC,' ' NUMDOC,' ' UFPART, ' ' CODAUTORIZA " 

cFrom3   := RetSqlName("C20") + " C20 "  
cFrom3   += " INNER JOIN " + RetSqlName("C2D") + " C2D ON C20.C20_FILIAL = C2D.C2D_FILIAL AND C20.C20_CHVNF = C2D.C2D_CHVNF AND C2D.D_E_L_E_T_ =' ' " 
cFrom3   += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL IN (" + Iif( lIN, cInC1H , "'" +xFilial("C1H")+ "'") + ") AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ =' ' "  
cFrom3   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON CHY.CHY_FILIAL = '" + xFilial("CHY") + "' AND C2D.C2D_IDSUBI = CHY.CHY_ID AND CHY.D_E_L_E_T_ =' ' "  

cWhere3  := " C20.C20_FILIAL IN (" + Iif( lIN, cInC20 , "'" +xFilial("C20")+ "'") + ") AND C20.C20_DTDOC >= '" + cDtIniRef + "' AND C20.C20_DTDOC <= '" + cDtFimRef + "' AND C20.D_E_L_E_T_ = ' ' "  

//--------------------------------------------------------------------------
//REGISTRO CR=26		 										           ||
//--------------------------------------------------------------------------
cSelect5 := " 'CR26' REGISTRO, ' ' IDPAI, ' ' CODAJU, C2D.C2D_VLICM VALOR, CHY.CHY_CODIGO CODSUBITEM, 0 SEQREG, ' ' DESCRI,' ' FLEGAL, C1F.C1F_IEST IE, CHY.CHY_OPERAC OPERAC, C20.C20_NUMDOC NUMDOC, C1H.C1H_UF UFPART, ' ' CODAUTORIZA "

cFrom5   := RetSqlName("C2D") + " C2D "  
cFrom5   += " INNER JOIN " + RetSqlname("C20") + " C20 ON C2D.C2D_FILIAL = C20.C20_FILIAL AND C2D.C2D_CHVNF = C20.C20_CHVNF AND C20.D_E_L_E_T_ =' ' "  
cFrom5   += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL IN (" + Iif( lIN, cInC1H , "'" +xFilial("C1H")+ "'") + ") AND C20.C20_CODPAR = C1H.C1H_ID AND C1H.D_E_L_E_T_ =' ' "
cFrom5   += " INNER JOIN " + RetSqlName("C1E") + " C1E ON C1E.C1E_FILTAF = C2D.C2D_FILIAL AND C1E.D_E_L_E_T_ = ' ' " 
cFrom5   += " INNER JOIN " + RetSqlName("C1F") + " C1F ON C1E.C1E_FILIAL = C1F.C1F_FILIAL AND C1E.C1E_ID = C1F.C1F_ID AND C1F.C1F_ATIVO = '1' AND C1F.C1F_UFST = C1H.C1H_UF AND C1F.D_E_L_E_T_ =' '" 
cFrom5   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON CHY.CHY_FILIAL = '" + xFilial("CHY") + "' AND C2D.C2D_IDSUBI = CHY.CHY_ID AND CHY.CHY_CODIGO IN ('00210','00211') AND CHY.CHY_OPERAC ='0' AND CHY.D_E_L_E_T_ =' ' " 

cWhere5  := " C2D.C2D_FILIAL= '" + xFilial("C2D") + "' AND C2D.D_E_L_E_T_ =' ' "

//--------------------------------------------------------------------------
//REGISTRO CR=27												           ||
//--------------------------------------------------------------------------
cSelect6 := " 'CR27' REGISTRO, ' ' IDPAI, ' ' CODAJU, C2D.C2D_VLICM VALOR, CHY.CHY_CODIGO CODSUBITEM, 0 SEQREG, ' ' DESCRI, ' ' FLEGAL, C1H.C1H_IE IE, CHY.CHY_OPERAC OPERAC, C20.C20_NUMDOC NUMDOC, C1H.C1H_UF UFPART, ' ' CODAUTORIZA " 

cFrom6   := RetSqlName("C2D") + " C2D " 
cFrom6   += " INNER JOIN " + RetSqlName("C20") + " C20 ON C2D.C2D_FILIAL = C20.C20_FILIAL AND C2D.C2D_CHVNF = C20.C20_CHVNF AND C20.D_E_L_E_T_ =' ' "
cFrom6   += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL IN (" + Iif( lIN, cInC1H , "'" +xFilial("C1H")+ "'") + ") AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ =' ' "  
cFrom6   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON CHY.CHY_FILIAL = '" + xFilial("CHY") + "' AND C2D.C2D_IDSUBI = CHY.CHY_ID AND CHY.CHY_CODIGO IN ('00701','00702') AND CHY.CHY_OPERAC ='1' AND CHY.D_E_L_E_T_ =' ' "  

cWhere6  := " C2D.C2D_FILIAL IN (" + Iif( lIN, cInC2D , "'" +xFilial("C2D")+ "'") + ") AND C2D.D_E_L_E_T_ =' ' "

//--------------------------------------------------------------------------
//REGISTRO CR=28												           ||
//--------------------------------------------------------------------------
cSelect7 := " 'CR28' REGISTRO , ' ' IDPAI, ' ' CODAJU, T00.T00_VALOR VALOR, CHY.CHY_CODIGO CODSUBITEM, 0 SEQREG, ' ' DESCRI,' ' FLEGAL, ' ' IE, CHY.CHY_OPERAC OPERAC, ' ' NUMDOC,' ' UFPART, T00.T00_CODIGO CODAUTORIZA "   

cFrom7   := RetSqlName("T00") + " T00 "  
cFrom7   += " LEFT JOIN " + RetSqlName("C2D") + " C2D ON C2D.C2D_CHVNF = T00.T00_CHVNF AND C2D.C2D_ID = T00.T00_ID "
cFrom7   += " AND C2D.C2D_IDSUBI = T00.T00_IDSUBI AND C2D.C2D_FILIAL = T00.T00_FILIAL "
cFrom7   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON C2D.C2D_IDSUBI = CHY.CHY_ID "   

cWhere7  := " CHY.CHY_CODIGO IN ('00220','00221','00740','00741','00223','00744','00745','00749') AND CHY.CHY_OPERAC ='0' AND  C2D.C2D_FILIAL IN (" + Iif( lIN, cInC2D , "'" +cFilSel+ "'") + ") "
cWhere7  += " AND T00.D_E_L_E_T_ =' ' AND C2D.D_E_L_E_T_ =' ' AND CHY.D_E_L_E_T_ =' ' "   

cSelect8 := " 'CR28' REGISTRO, ' ' IDPAI, ' ' CODAJU, T02.T02_VALOR VALOR, CHY.CHY_CODIGO CODSUBITEM, 0 SEQREG, ' ' DESCRI, ' ' FLEGAL, ' ' IE, CHY.CHY_OPERAC OPERAC, ' ' NUMDOC, ' ' UFPART, T02.T02_CODIGO CODAUTORIZA "  

cFrom8   := RetSqlName("C2S") + " C2S "
cFrom8   += " LEFT JOIN " + RetSqlName("T02") + " T02 ON T02.T02_FILIAL = C2S.C2S_FILIAL AND T02.T02_ID = C2S.C2S_ID "
cFrom8   += " LEFT JOIN " + RetSqlName("C2T") + " C2T ON C2T.C2T_ID = T02.T02_ID AND C2T.C2T_IDSUBI = T02.T02_IDSUBI AND "
cFrom8   += " C2T.C2T_CODAJU = T02.T02_CODAJU AND C2T.C2T_FILIAL = T02.T02_FILIAL "  
cFrom8   += " INNER JOIN " + RetSqlName("CHY") + " CHY ON C2T.C2T_IDSUBI = CHY.CHY_ID "  
cWhere8  := " CHY.CHY_CODIGO IN ('00220','00221','00740','00741','00223','00744','00745','00749') AND CHY.CHY_OPERAC ='0' AND  C2T.C2T_FILIAL IN (" + Iif( lIN, cInC2T , "'" +cFilSel+ "'") + ") "  
cWhere8  += " AND T02.D_E_L_E_T_ =' ' AND CHY.D_E_L_E_T_ =' ' AND C2T.D_E_L_E_T_ =' ' " 

If cBd $ "ORACLE|POSTGRES|DB2"
	cWhere8 += " AND SUBSTR(C2S.C2S_DTINI,1,6) = '" + cAnoMesRef + "'"
ElseIf cBd $ "INFORMIX"
	cWhere8 += " AND C2S.C2S_DTINI[1,6] = '" + cAnoMesRef + "' "
Else
	cWhere8 += " AND SUBSTRING(C2S.C2S_DTINI,1,6) = '" + cAnoMesRef + "' "
EndIf

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"
cGrpBy2  := "%" + cGrpBy2  + "%"

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

cSelect5 := "%" + cSelect5 + "%"
cFrom5   := "%" + cFrom5   + "%"
cWhere5  := "%" + cWhere5  + "%"

cSelect6 := "%" + cSelect6 + "%"
cFrom6   := "%" + cFrom6   + "%"
cWhere6  := "%" + cWhere6  + "%"
 
cSelect7 := "%" + cSelect7 + "%"
cFrom7   := "%" + cFrom7   + "%"
cWhere7  := "%" + cWhere7  + "%"

cSelect8 := "%" + cSelect8 + "%"
cFrom8   := "%" + cFrom8   + "%"
cWhere8  := "%" + cWhere8  + "%"

BeginSql Alias cAliasQry
	SELECT * FROM (
	
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
	
	UNION	
		
	SELECT
		%Exp:cSelect2%
	FROM
		%Exp:cFrom2%
	WHERE
		%EXP:cWhere2%
	GROUP BY
		%EXP:cGrpBy2%

	UNION
		
	SELECT
		%Exp:cSelect3%
	FROM
		%Exp:cFrom3%
	WHERE
		%EXP:cWhere3%

	UNION
		
	SELECT
		%Exp:cSelect5%
	FROM
		%Exp:cFrom5%
	WHERE
		%EXP:cWhere5%
	
	UNION
	
	SELECT
		%Exp:cSelect6%
	FROM
		%Exp:cFrom6%
	WHERE
		%EXP:cWhere6%
	
	UNION
		
	SELECT
		%Exp:cSelect7%
	FROM
		%Exp:cFrom7%
	WHERE
		%EXP:cWhere7%
		
	UNION
		
	SELECT
		%Exp:cSelect8%
	FROM
		%Exp:cFrom8%
	WHERE
		%EXP:cWhere8%		
	) TBGER
	ORDER BY
		TBGER.OPERAC,
		TBGER.CODSUBITEM,
        TBGER.SEQREG,
        TBGER.REGISTRO,
        TBGER.IE,
        TBGER.CODAUTORIZA,
        TBGER.IDPAI
EndSql

cFilAnt := cFilAux

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QryCR25

Efetua query que busca os registros referentes ao registro CR=25 – IEs:

@Param 	canoMEsRef
		cFilSel
		cAliasQry25
		cCfop
		cSubItem
		lApura
		cIn
@Param
@Author
@Since
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function QryCR25(cAnoMesRef,cFilSel,cAliasQry25,cCfop,cSubItem,lApura, cIn)

Local cSelect   := ""
Local cWhere    := ""
Local cFrom     := ""
Local cDtiniRef := cAnoMesRef+'16' 
Local cDtFimRef := BuscaDiaUtil(Dtos(Firstday(stod(cAnoMesRef+'01'),1))) 
Local cFilAux	:= cFilAnt
Local cExpreSql := ""
Local lIN		:= .F.
Local cInC20	:= ""
Local cInC1H	:= ""
Local cInC30	:= ""
Local cInC2T	:= ""
Local cInC2S	:= ""

Default cSubItem	:= ''
Default lApura		:= .f.
Default	cIn			:= ""

lIN	:=	Iif( !Empty(cIn), .T., .F. )

If lIN
	cInC20	:=	INCompFil("C20", cFilSel, cIn)
	cInC1H	:=	INCompFil("C1H", cFilSel, cIn)
	cInC30	:=	INCompFil("C30", cFilSel, cIn)
	cInC2T	:=	INCompFil("C2T", cFilSel, cIn)
	cInC2S	:=	INCompFil("C2S", cFilSel, cIn)
EndIf

cFilAnt := cFilSel

cSelect := "'CR25' REGISTRO, C1H.C1H_IE IE, C30.C30_TOTAL VALOR, C0Y.C0Y_CODIGO CFOP "
cFrom := RetSqlName("C30") + " C30 "
cFrom += " INNER JOIN " + RetSqlName('C20') + " C20 ON C20.C20_FILIAL = C30.C30_FILIAL AND C20.C20_CHVNF = C30.C30_CHVNF  AND C20.C20_CODSIT NOT IN ('000003', '000006') AND C20.C20_DTES BETWEEN '" + cDtiniRef + "' AND '" + cDtFimRef + "' AND C20.D_E_L_E_T_ = ' ' "
cFrom += " INNER JOIN " + RetSqlName('C1H') + " C1H ON C1H.C1H_FILIAL = C30.C30_FILIAL AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "
cFrom += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial('C0Y') + "' AND C0Y.C0Y_ID = C30.C30_CFOP  AND C0Y.C0Y_CODIGO IN ("+cCfop+") AND C0Y.D_E_L_E_T_ = ' ' "
cWhere   += " C30.D_E_L_E_T_ = ' ' AND C30.C30_FILIAL IN (" + Iif( lIN, cInC30 , "'" +xFilial("C30")+ "'") + ") "
cGroupBy := " C1H.C1H_IE , C30.C30_TOTAL, C0Y.C0Y_CODIGO "
cOrderBy := " C0Y.C0Y_CODIGO DESC "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"
cGroupBy := "%" + cGroupBy + "%"
cOrderBy := "%" + cOrderBy + "%"

BeginSql Alias cAliasQry25
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
	GROUP BY 		
		%EXP:cGroupBy%
	ORDER BY
		%Exp:cOrderBy%
		
EndSql

/*
	Recebimento de saldo credor/devedor de ICMS não é obrigatório ter nf de entrada
	Se nao achar informacoes de outras ocorrencias (CR=25 IE) entre as notas fiscais de entrada, verifica se tem itens lancados manualmente nas apuracoes.

	Transferência de saldo credor/devedor de ICMS pela nf de saída ( gerado pelo Faturamento ) pode ter valores zerados ( Valor Total e ICMS ) -> http://tdn.totvs.com/x/IADxAw
	Caso a nf de saída seja gerada com valores zerados, também será necessário verificar o lançamento manual.

	Nos dois casos o cliente tem que informar a IE na linha de apuração do ICMS ( campo descrição - MATA953.prx )
*/
if ( ( cAliasQry25 )->( eof( ) ) ) .or. ( ( cAliasQry25 )->VALOR == 0 )
	(cAliasQry25)->(DbCloseArea())

	If ( Upper( AllTrim( TCGetDB( ) ) ) ) $ "ORACLE|DB2|POSTGRES|INFORMIX"
		cExpreSql := "SUBSTR"
	Else
		cExpreSql := "SUBSTRING"
	EndIf

	cSelect := "'CR25' REGISTRO, C2T.C2T_VLRAJU VALOR, C2T.R_E_C_N_O_ RECC2T "
	cFrom 	:= RetSqlName('C2S') + " C2S "
	cFrom	+= " INNER JOIN " + RetSqlName('C2T') + " C2T ON C2T.C2T_FILIAL = C2S.C2S_FILIAL AND C2T.C2T_ID = C2S.C2S_ID AND C2T.D_E_L_E_T_ = ' ' "
	cFrom	+= " INNER JOIN " + RetSqlName('CHY') + " CHY ON CHY.CHY_FILIAL = '" + xFilial('CHY') + "' AND CHY.CHY_ID = C2T.C2T_IDSUBI AND CHY.D_E_L_E_T_ = ' ' "
	cWhere 	:= " C2S.D_E_L_E_T_ = ' ' "
	cWhere	+= " AND C2S.C2S_FILIAL IN (" + Iif( lIN, cInC2S , "'" +xFilial("C2S")+ "'") + ") "
	cWhere	+= " AND " + cExpreSql + "(C2S.C2S_DTINI,1,6) >= '" + cAnoMesRef + "' AND " + cExpreSql + "(C2S.C2S_DTFIN,1,6) <= '" + cAnoMesRef + "' "
	cWhere	+= " AND CHY.CHY_CODIGO = '" + cSubItem + "' "
	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"
	
	BeginSql Alias cAliasQry25
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%EXP:cWhere%
	EndSql

	lApura := .t.

endif

cFilAnt := cFilAux

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} BuscaDiaUtil

Formata Data com Ano Mes e Dia Correspondente

@Param 	cDtFimRef
@Author
@Since
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function BuscaDiaUtil(cDtFimRef)
Local cDtGia
Local cDia := '15'
Local cMes := SUBSTRING(cDtFimRef,5,2)
Local cAno := SUBSTRING(cDtFimRef,1,4)

If cMes = '12'
   cMes := '01
   cAno := strzero(Val(cAno)+1,4)
Else
   cMes := strzero(Val(cMes)+1,2)
Endif

cDtGia := cAno+cMes+cDia

Return(cDtGia)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDescri

Busca a descrição da tabela C2T para preenchimento do CR=20 da GIA-SP

@Param 	cAnoMesRef -> Ano e mês da geração do arquivo
		cFilSel -> Filiais selecionadas para o processamento
@Author jfelipe / felipe.guarnieri
@Since 19/10/2020
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function GetDescri(cAnoMesRef, cFilSel, cCodSubi, nSeqReg, cOperac, cIDPai)

Local cSelect   := ""
Local cFrom     := ""
Local cWhere    := ""
Local cAlias    := GetNextAlias()
Local cDesc     := ""
Local cAliasPai := ""
Local cAliasFil := ""
Local cGetDB    := Upper(AllTrim(TCGetDB()))

Default cOperac := '0'
Default cIDPai  := ' '

If cOperac == '0'
	cAliasPai := 'C2S'
	cAliasFil := 'C2T'
Else
	cAliasPai := 'C3J'
	cAliasFil := 'C3K'
EndIf

cSelect := cAliasFil + "." + cAliasFil + "_AJUCOM AJUCOM "
cFrom   := RetSqlName(cAliasFil) + " " + cAliasFil + " "
cFrom	+= " INNER JOIN " + RetSqlName("CHY") + " CHY ON " + cAliasFil + "." + cAliasFil + "_IDSUBI = CHY.CHY_ID  AND CHY.D_E_L_E_T_ = ' ' "
cFrom	+= " INNER JOIN " + RetSqlName(cAliasPai) + " " + cAliasPai + " ON " + cAliasFil + "." + cAliasFil + "_ID = " + cAliasPai + "." + cAliasPai + "_ID  AND "
cFrom	+= cAliasFil + "." + cAliasFil + "_FILIAL = " + cAliasPai + "." + cAliasPai + "_FILIAL AND " + cAliasPai + ".D_E_L_E_T_ = ' ' "
cWhere 	:= cAliasFil + "." + cAliasFil + "_FILIAL = '" + cFilSel + "'"

// Adicionado ID da tabela C3J para trazer a descrição correta na tabela C3K
If cOperac == '1'
	cWhere 	+= " AND " + cAliasFil + "." + cAliasFil + "_ID = '" + AllTrim(cIDPai) + "' "
EndIf
cWhere 	+= " AND " + cAliasFil + "." + cAliasFil + "_SEQREG = '" + cValToChar(nSeqReg) + "' AND "
cWhere  += " CHY.CHY_CODIGO = '" + cCodSubi + "' AND "
cWhere  += Iif(cGetDB $ "ORACLE|DB2|POSTGRES", " SUBSTR(" + cAliasPai + "." + cAliasPai + "_DTINI,1,6) = '" + cAnoMesRef + "'",;
           Iif(cGetDB $ "INFORMIX", cAliasPai + "." + cAliasPai + "_DTINI[1,6] = '" + cAnoMesRef + "'",;
		      " SUBSTRING(" + cAliasPai + "." + cAliasPai + "_DTINI,1,6) = '" + cAnoMesRef + "'"))

cWhere += " AND " + cAliasFil + ".D_E_L_E_T_ = ' ' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

BeginSql Alias cAlias
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
EndSql

(cAlias)->(DBGoTop())

if (cAlias)->(!EOF())
	cDesc := (cAlias)->AJUCOM
Endif

(cAlias)->(DbCloseArea())

Return cDesc
