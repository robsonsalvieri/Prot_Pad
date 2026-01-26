#INCLUDE "loca050.ch" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                              

/*/{PROTHEUS.DOC} LOCA050.PRW
ITUP BUSINESS - TOTVS RENTAL
RETORNO / DISPONIBILIZAวรO DO EQUIPAMENTO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA050()
//Local _CUSER	  := RETCODUSR(SUBSTR(CUSUARIO,7,15))  		// RETORNA O CำDIGO DO USUมRIO
Local AAREA       := GETAREA() 
Local CFILTRO     := "" 
Local CQRYLEG     := ""
Local lMvLocBac	  := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC

Private CCADASTRO := OEMTOANSI(STR0001) //"RETORNO / DISPONIBILIZAวรO DO EQUIPAMENTO"
Private AROTINA   := {} 
Private ACORES	  := {}
Private CRET00    := ""
Private CRET10    := ""
Private CRET20    := ""
//Private CRET30    := ""
//Private CRET40    := ""
Private CRET50    := ""
Private CRET60    := ""
//Private CRET70    := ""
Private CSTSANTI  := "" 
Private CSTSNOVO  := "" 
	/*
	IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA050" , .T.)) 	// PROCURA O CำDIGO DE USUมRIO NA TABELA DE USUมRIOS ANALIZADORES DE PROMOวีES (SZ5)
		_LUSER := .T. 
	ELSE
		MSGALERT("SEU USUมRIO NรO POSSUI DIREITO PARA ACESSAR ESTA ROTINA, VERIFIQUE COM O ADMINISTRADOR DO SISTEMA. CADASTRO ROTINA NA TABELA Z_5." , "GPO - LOCT039.PRW") 
		RETURN 
	ENDIF 
	*/
	/*
	EXEMPLO
	TQY_STATUS	TQY_DESTAT                    	FQ5_STTCTR
	----------  ----------------------------    ----------
	00        	DISPONIVEL                    	00
	DI        	DISPONIVEL (DI)               	00
	10        	CONTRATO GERADO               	10
	20        	NF DE REMESSA GERADA          	20
	30        	EM TRANSITO PARA ENTREGA      	30
	40        	ENTREGUE                      	40
	50        	RETORNO DE LOCACAO            	50
	RL        	RETORNO DE LOCACAO (RL)       	50
	60        	NF DE RETORNO GERADA          	60
	70        	EM MANUTENวรO                 	70
	*/


	If VerLOCBAC() // Verifica existencia de campos para LOCBAC = .f.
	Else
		Return
	EndIf

	IF SELECT("TMPLEG") > 0 
		TMPLEG->( DBCLOSEAREA() ) 
	ENDIF 

	If !lMvLocBac
		CQRYLEG := " SELECT TQY_STATUS , TQY_STTCTR FROM "+ RETSQLNAME("TQY") +" TQY WHERE TQY.TQY_STTCTR IN ('00','10','20','30','40','50','60') AND TQY.D_E_L_E_T_ = ' ' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		WHILE TMPLEG->(!EOF()) 
			IF TMPLEG->TQY_STTCTR = "00" 		// --> 00 - DISPONIVEL               - VERDE 
				CRET00 := CRET00 + TMPLEG->TQY_STATUS + "*" 
				IF EMPTY(CSTSNOVO)
					CSTSNOVO := TMPLEG->TQY_STATUS 
				ENDIF 
			ELSEIF TMPLEG->TQY_STTCTR = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
				CRET10 := CRET10 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
				CRET20 := CRET20 + TMPLEG->TQY_STATUS + "*" 
			//ELSEIF TMPLEG->TQY_STTCTR = "30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
			//	CRET30 := CRET30 + TMPLEG->TQY_STATUS + "*" 
			//ELSEIF TMPLEG->TQY_STTCTR = "40" 		// --> 40 - ENTREGUE                 - LARANJA 
			//	CRET40 := CRET40 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
				CRET50 := CRET50 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
				CRET60 := CRET60 + TMPLEG->TQY_STATUS + "*" 
			//ELSEIF TMPLEG->TQY_STTCTR = "70" 		// --> 70 - EM MANUTENCAO            - ******** 
			//	CRET70 := CRET70 + TMPLEG->TQY_STATUS + "*" 
			ENDIF 
			TMPLEG->(DBSKIP()) 
		ENDDO 
	else
		CQRYLEG := " SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" FQD WHERE FQD.FQD_STAREN IN ('00','10','20','30','40','50','60') AND FQD.D_E_L_E_T_ = ' ' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		TMPLEG->(DBGOTOP())
		WHILE TMPLEG->(!EOF())
			IF TMPLEG->FQD_STAREN = "00" 		// --> 00 - DISPONIVEL               - VERDE 
				CRET00 := CRET00 + TMPLEG->FQD_STATQY + "*" 
				IF EMPTY(CSTSNOVO)
					CSTSNOVO := TMPLEG->FQD_STATQY 
				ENDIF 
			ELSEIF TMPLEG->FQD_STAREN = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
				CRET10 := CRET10 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
				CRET20 := CRET20 + TMPLEG->FQD_STATQY + "*" 
			//ELSEIF TMPLEG->FQD_STAREN = "30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
			//	CRET30 := CRET30 + TMPLEG->FQD_STATQY + "*" 
			//ELSEIF TMPLEG->FQD_STAREN = "40" 		// --> 40 - ENTREGUE                 - LARANJA 
			//	CRET40 := CRET40 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
				CRET50 := CRET50 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
				CRET60 := CRET60 + TMPLEG->FQD_STATQY + "*" 
			//ELSEIF TMPLEG->FQD_STAREN = "70" 		// --> 70 - EM MANUTENCAO            - ******** 
			//	CRET70 := CRET70 + TMPLEG->FQD_STATQY + "*" 
			ENDIF 
			TMPLEG->(DBSKIP()) 
		ENDDO
	EndIf

	//{'ST9->T9_STATUS $ "'+CRET30+'"' , "BR_CINZA"   },;
	//{'ST9->T9_STATUS $ "'+CRET40+'"' , "BR_LARANJA" },;

	ACORES := { {'ST9->T9_STATUS $ "'+CRET00+'"' , "BR_VERDE"   },;
				{'ST9->T9_STATUS $ "'+CRET10+'"' , "BR_AMARELO" },;
				{'ST9->T9_STATUS $ "'+CRET20+'"' , "BR_AZUL"    },;
				{'ST9->T9_STATUS $ "'+CRET50+'"' , "BR_PRETO"   },;
				{'ST9->T9_STATUS $ "'+CRET60+'"' , "BR_VERMELHO"}}
				//{'ST9->T9_STATUS $ "'+CRET70+'"' , "BR_PINK"    } } 

	aRotina := menudef(aRotina)
		
	MBROWSE( , , , , "ST9" , , , , , 02 , ACORES , , , , , , , , CFILTRO ) 

	TMPLEG->( DBCLOSEAREA() ) 
	RESTAREA( AAREA )

RETURN



// ======================================================================= \\
FUNCTION LOCA05001() 					// AXALTERA 
// ======================================================================= \\
/*
"00" 		// --> 00 - DISPONIVEL               - VERDE 
"10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
"20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
"30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
"40" 		// --> 40 - ENTREGUE                 - LARANJA 
"50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
"60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
"70" 		// --> 70 - EM MANUTENCAO            - ******** 
LOCAL ASITUA   := {"00 - DISPONIVEL" , "10 - CONTRATO GERADO" , "20 - NF DE REMESSA GERADA" , "30 - EM TRANSITO PARA ENTREGA" , "40 - ENTREGUE", "50 - RETORNO DE LOCACAO" , "60 - NF DE RETORNO GERADA" , "70 - EM MANUTENCAO"} 
*/
Local _CUSER		:= RETCODUSR(SUBSTR(CUSUARIO,7,15))  		// RETORNA O CำDIGO DO USUมRIO
Local AAREA	   		:= GETAREA() 
//Local CQRYZZZ  	:= "" 
//Local NMRECZZZ	 := 0 
Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC

Local cQuery 		:= ""

	CSTSANTI := ST9->T9_STATUS 

	IF (ST9->T9_STATUS $ CRET00) 
		MSGALERT(STR0005+ST9->T9_STATUS+STR0006 , STR0007)  //"ESTE EQUIPAMENTO Jม ESTม COM O STATUS ["###"] - DISPONIVEL."###"GPO - LOCT039.PRW"
		RETURN 
	ENDIF 

	IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA050" , .T.)) 	// PROCURA O CำDIGO DE USUมRIO NA TABELA DE USUมRIOS ANALIZADORES DE PROMOวีES (SZ5)
		_LUSER := .T. 
	ELSE
		_LUSER := .F. 
	ENDIF 

	_cTemps50 := ""
	_cTemps60 := ""
	
	If !lMvLocBac
		TQY->(dbSetOrder(1))
		TQY->(dbGotop())
		While !TQY->(Eof())
			If TQY->TQY_STTCTR == "60"
				_cTemps60 := TQY->TQY_STATUS
			EndIF
			If TQY->TQY_STTCTR == "50"
				_cTemps50 := TQY->TQY_STATUS
			EndIF
			TQY->(dbSkip())
		EndDo
	Else
		FQD->(dbSetOrder(1))
		FQD->(dbGotop())
		While !FQD->(Eof())
			If FQD->FQD_STAREN == "60"
				_cTemps60 := FQD->FQD_STATQY
			EndIF
			If FQD->FQD_STAREN == "50"
				_cTemps50 := FQD->FQD_STATQY
			EndIF
			FQD->(dbSkip())
		EndDo
	EndIF

	IF (ST9->T9_STATUS <> _cTemps60 .and. ST9->T9_STATUS <> _cTemps50) .AND. !_LUSER
		MSGALERT(STR0008 , STR0007)  //"ESTE EQUIPAMENTO NรO ESTม COM O STATUS 60 - NF RETORNO GERADO."###"GPO - LOCT039.PRW"
		RETURN 
	ENDIF 

	cQuery := " SELECT FQ4_PROJET"      
	cQuery += " FROM  " + RetSqlName("FQ4") + " FQ4 " 
	cQuery += " WHERE  FQ4.D_E_L_E_T_ = '' "       
	cQuery += "   AND  FQ4.FQ4_CODBEM = ? "       
	cQuery += "   AND  FQ4.FQ4_STATUS = ? "       
	cQuery += " ORDER BY FQ4_DTFIM DESC "
	cQuery := changequery(cQuery) 
    aBindParam := {ST9->T9_CODBEM, ST9->T9_STATUS}
	MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)

    TRBFQ4->(dbGotop())

	IF MSGYESNO(STR0009+ALLTRIM(ST9->T9_CODBEM)+STR0010+ALLTRIM(TRBFQ4->FQ4_PROJET)+STR0011+ST9->T9_STATUS+"] ???" , STR0007)  //"CONFIRMA A DISPONIBILIZAวรO DO EQUIPAMENTO ["###"], VINCULADO AO PROJETO ["###"], STATUS ATUAL ["###"GPO - LOCT039.PRW"
		DBSELECTAREA("ST9") 
		RECLOCK("ST9",.F.) 
		ST9->T9_STATUS := CSTSNOVO 			// --> 00 - DISPONIVEL 
		ST9->(MSUNLOCK()) 
		LOCXITU21(CSTSANTI, CSTSNOVO, FQ4->FQ4_PROJET , "", "")
	ENDIF 

    TRBFQ4->(dbCloseArea())

	RESTAREA(AAREA)

RETURN 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNวรO	 ณ L139LEG   บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 07/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ LEGENDA.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION LOCA05002()
LOCAL _ALEGENDA := {}

	AADD(_ALEGENDA , {"BR_VERDE"    , STR0012 })  //"DISPONอVEL"
	AADD(_ALEGENDA , {"BR_AMARELO"  , STR0013 })  //"CONTRATO GERADO"
	AADD(_ALEGENDA , {"BR_AZUL"     , STR0014 })  //"REMESSA GERADA"
	//AADD(_ALEGENDA , {"BR_CINZA"    , STR0015 })  //"EM TRยNSITO"
	//AADD(_ALEGENDA , {"BR_LARANJA"  , STR0016 })  //"ENTREGUE"
	AADD(_ALEGENDA , {"BR_PRETO"    , STR0017 })  //"RETORNO LOCACAO"
	AADD(_ALEGENDA , {"BR_VERMELHO" , STR0018 })  //"RETORNO GERADO"
	//AADD(_ALEGENDA , {"BR_PINK"     , STR0019 })  //"EM MANUTENวรO"

	BRWLEGENDA(STR0020 , STR0004 , _ALEGENDA)  //"STATUS ATUAL"###"LEGENDA"

RETURN

// Montagem do aRotina
// Frank Fuga
// 17/11/23 - card 1288
Static Function menudef(aRotina)
	aRotina := {}
	AADD( AROTINA , {STR0002 , "AXVISUAL"    , 0 , , 2 , NIL} ) //"VISUALIZAR"
	AADD( AROTINA , {STR0003 , "LOCA05001()" , 0 , , 4 , NIL} )  //"LIBERAR EQUIP."
	AADD( AROTINA , {STR0004 , "LOCA05002()" , 0 , , 7 , NIL} )  //"LEGENDA"
Return aRotina
