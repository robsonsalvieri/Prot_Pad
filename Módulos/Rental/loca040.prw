#INCLUDE "loca040.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

/*/{PROTHEUS.DOC} LOCA040.PRW
ITUP BUSINESS - TOTVS RENTAL
CANCELAMENTO DE AS (AUTORIZAÇÃO DE SERVIÇO)
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.   
/*/ 

FUNCTION LOCA040()
LOCAL AAREA    := GETAREA()
LOCAL AAREAZA0 := FP0->(GETAREA())
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL AITENS   := {}
LOCAL OOK      := LOADBITMAP( GETRESOURCES(), "LBOK")
LOCAL ONO      := LOADBITMAP( GETRESOURCES(), "LBNO")
LOCAL _CQUERY  := ""
LOCAL _CWHERE  := ""
Local cComando := ""

	PRIVATE ODLG , OLBXITENS

	IF SELECT("FP0") == 0 .OR. FP0->(EOF() .OR. EMPTY(FP0->FP0_PROJET))
		MSGSTOP(IIF(SELECT("FP0")==0 , STR0001 , STR0002) , STR0003) //"OPERAÇÃO CANCELADA: O ARQUIVO ZA0 NÃO ESTÁ ABERTO!"###"OPERAÇÃO CANCELADA: SELECIONE UM PROJETO ANTES DE ACESSAR ESTA ROTINA"###"GPO - LOCF145.PRW"
		RETURN NIL
	ENDIF

	IF SELECT("TRBFQ5") > 0
		TRBFQ5->(DBCLOSEAREA())
	ENDIF

	/*
	+ XFILIAL("FQ5") +
	+ FP0->FP0_FILIAL +
	+ FP0->FP0_PROJET +
	*/

	_CQUERY     := " SELECT DTQ.R_E_C_N_O_ FQ5RECNO "
	_CQUERY     += " FROM " + RETSQLNAME("FQ5") + " DTQ"

	_CWHERE     := " WHERE  FQ5_FILIAL = ? "
	_CWHERE     += "   AND  FQ5_FILORI = ? " // DOUGLAS TELLES
	_CWHERE     += "   AND  FQ5_SOT    = ? "
	_CWHERE     += "   AND  FQ5_AS    <> ''"
	_CWHERE     += "   AND  FQ5_STATUS NOT IN ('9')"
	_CWHERE     += "   AND  DTQ.D_E_L_E_T_ = ''" 
	_CWHERE     += "   AND  NOT EXISTS(SELECT *"
	_CWHERE     += " 				   FROM " + RETSQLNAME("FPZ") + " FPZ, " + RETSQLNAME("FPY") + " FPY "
	_CWHERE     += " 				   WHERE  FPZ.FPZ_FILIAL =  FQ5_FILORI"
	_CWHERE     += " 					 AND  FPZ.FPZ_PROJET =  FQ5_CONTRA"
	_CWHERE     += " 					 AND  FQ5_TPAS       = 'F' "   
	_CWHERE     += " 					 AND  FPY.FPY_FILIAL =  FPZ.FPZ_FILIAL "   
	_CWHERE     += " 					 AND  FPY.FPY_PEDVEN =  FPZ.FPZ_PEDVEN "   
	_CWHERE     += " 					 AND  FPY.FPY_STATUS =  '1 ' "   
	_CWHERE     += " 					 AND  FPY.FPY_TIPFAT =  'R' "   
	_CWHERE     += " 					 AND  FPZ.D_E_L_E_T_ =  ''  "      
	_CWHERE     += " 					 AND  FPY.D_E_L_E_T_ =  '') "      
	_CWHERE     += "   AND  NOT EXISTS(SELECT *"
	_CWHERE     += " 				   FROM " + RETSQLNAME("FPZ") + " FPZ, " + RETSQLNAME("FPY") + " FPY "
	_CWHERE     += " 				   WHERE  FPZ.FPZ_FILIAL =  FQ5_FILORI"
	_CWHERE     += " 					 AND  FPZ.FPZ_AS     =  FQ5_AS "   
	_CWHERE     += " 					 AND  FPY.FPY_FILIAL =  FPZ.FPZ_FILIAL "   
	_CWHERE     += " 					 AND  FPY.FPY_PEDVEN =  FPZ.FPZ_PEDVEN "   
	_CWHERE     += " 					 AND  FPY.FPY_STATUS =  '1 ' "   
	_CWHERE     += " 					 AND  FPY.FPY_TIPFAT =  'R' "   
	_CWHERE     += " 					 AND  FPZ.D_E_L_E_T_ =  ''  "      
	_CWHERE     += " 					 AND  FPY.D_E_L_E_T_ =  '') "      
	_CWHERE     += "   AND  NOT EXISTS(SELECT *"
	_CWHERE     += " 				   FROM " + RETSQLNAME("FPA") + " ZAG "
	_CWHERE     += " 				   WHERE  ZAG.FPA_FILIAL =  FQ5_FILORI"
	_CWHERE     += " 				     AND  ZAG.FPA_PROJET =  FQ5_SOT "  
	_CWHERE     += " 					 AND  ZAG.FPA_AS     =  FQ5_AS "   
	_CWHERE     += " 					 AND  ZAG.FPA_AS     <> '' "       
	_CWHERE     += " 					 AND  ZAG.FPA_NFREM  <> '' "       
	_CWHERE     += " 					 AND  ZAG.D_E_L_E_T_ =  '') "      
	_CWHERE     += "    AND DTQ.D_E_L_E_T_ = ''" 
	IF EXISTBLOCK("LC145QRY")								// PONTO DE ENTRADA PARA INCLUSAO DE CONDICOES NA QUERY COM ITENS QUE PODERAO SOFRER CANCELAMENTO DE AS.
		cComando := '_CWHERE := EXECBLOCK("LC145QRY",.T.,.T.,{_CWHERE})'
		&(cComando)
	ENDIF
	cComando := '_CQUERY += _CWHERE '
	&(cComando)
	_CQUERY     += " ORDER BY FQ5_FILIAL , FQ5_FILORI , FQ5_SOT , FQ5_AS "
	_CQUERY := CHANGEQUERY(_CQUERY) 
	aBindParam := {XFILIAL("FQ5"),FP0->FP0_FILIAL,FP0->FP0_PROJET }
	MPSysOpenQuery(_CQUERY,"TRBFQ5",,,aBindParam)
	//TCQUERY _CQUERY NEW ALIAS "TRBFQ5"

	FQ5->(DBSETORDER(RETORDEM("FQ5","FQ5_FILIAL+FQ5_SOT+FQ5_OBRA+FQ5_VIAGEM")))

	WHILE TRBFQ5->(!EOF())
		FQ5->(DBGOTO(TRBFQ5->FQ5RECNO))
		AADD(AITENS, {.F., FQ5->FQ5_AS, FQ5->FQ5_GUINDA,FSTATUS(), FQ5->(RECNO())} )
		TRBFQ5->(DBSKIP())
	ENDDO
	TRBFQ5->(DBCLOSEAREA())

	IF LEN(AITENS) > 0
		DEFINE MSDIALOG ODLG TITLE STR0004+FP0->FP0_PROJET FROM 000,000 TO 500,735 PIXEL //"AS DO PROJETO: "
			@ 005,005 SAY STR0005 OF ODLG PIXEL //"SELECIONE AS AUTORIZAÇÕES DE SERVIÇO PARA CANCELAMENTO:"
			@ 015,005 LISTBOX OLBXITENS FIELDS HEADER "SEL","AS",STR0006,STR0007 SIZE 360,210 OF ODLG PIXEL ON DBLCLICK ( FSELECIONA(AITENS, OLBXITENS:NAT, .F.) )  //"EQUIPAMENTO"###"OBSERVAÇÕES"
			OLBXITENS:SETARRAY(AITENS)
			OLBXITENS:BLINE := {|| {IF(AITENS[OLBXITENS:NAT][1],OOK,ONO),AITENS[OLBXITENS:NAT][2],AITENS[OLBXITENS:NAT][3],AITENS[OLBXITENS:NAT][4]} }
			
			@ 230,030 BUTTON STR0008	  SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.T., AITENS) //"MARCA TODOS"
			@ 230,090 BUTTON STR0009 SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.F., AITENS) //"DESMARCA TODOS"
			@ 230,200 BUTTON STR0010	  SIZE 50,15 PIXEL OF ODLG ACTION (FCANCELAR(AITENS), ODLG:END()) //"CANCELAR AS"
			@ 230,300 BUTTON STR0011			  SIZE 50,15 PIXEL OF ODLG ACTION ODLG:END() //"SAIR"
		ACTIVATE MSDIALOG ODLG CENTERED
	ELSE
		MSGSTOP(STR0012 , STR0003) //"Não há AS a ser canceladas, pois a solicitação não atende aos critérios"
	ENDIF

	RESTAREA(AAREA)
	FP0->(RESTAREA(AAREAZA0))
	FQ5->(RESTAREA(AAREADTQ))

RETURN NIL 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FSTATUS   º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ RETORNA SE A AS TEM CTRC E/OU CTRB                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FSTATUS()

LOCAL _RET := ""
Local cAux := ""

	IF FQ5->FQ5_STATUS == "9"
		_RET += STR0013 //"AS CANCELADA"
	ENDIF

	IF !EMPTY(FQ5->FQ5_NUMCTR) .AND. FQ5->FQ5_NUMCTR != "-"
		IF !EMPTY(_RET)
			_RET += STR0014 //" E "
		ENDIF
		_RET += STR0015 //"TEM CTRC"
	ENDIF

	IF !EMPTY(FQ5->FQ5_NUMCTC) .AND. FQ5->FQ5_IMPCTB == "S"
		IF !EMPTY(_RET)
			_RET := STRTRAN(_RET,STR0014,", ") //" E "
			_RET += STR0014 //" E "
		ENDIF
		_RET += STR0016 //"TEM CTRB"
	ENDIF

	IF !EMPTY(FQ5->FQ5_NUMCTC) .AND. FQ5->FQ5_IMPCTB == "A"
		IF !EMPTY(_RET)
			_RET := STRTRAN(_RET," E ",", ")
			_RET += " E "
		ENDIF
		_RET += STR0017 //"VIAGEM C/ ADIANTAMENTO"
	ENDIF

	IF !EMPTY(FQ5->FQ5_NUMSLD) .AND. FQ5->FQ5_IMPCTB == "S"
		IF !EMPTY(_RET)
			_RET := STRTRAN(_RET," E ",", ")
			_RET += " E "
		ENDIF
		_RET += STR0018 //"VIAGEM C/ SALDO"
	ENDIF

	cAux := LOCA04002( FQ5->FQ5_AS )
	if !Empty(cAux)
		IF !EMPTY(_RET)
			_RET := STRTRAN(_RET," E ",", ")
			_RET += " E "
		ENDIF
		_RET += cAux
	endif

RETURN _RET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³FSELECIONA º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ SELECIONA O ITEM (AS)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPARÂMETROS³ AITENS - ARRAY DOS DADOS PREENCHIDOS                       º±±
±±º          ³ NAT    - POSIÇÃO DO ELEMENTO NO ARRAY                      º±±
±±º          ³ LQUIET - EM CASO DE NÃO SELEÇÃO POR EXISTÊNCIA DE CTRC     º±±
±±º          ³          E/OU CTRB, SE NÃO EXIBE MENSAGEM DE ALERTA        º±±
±±º          ³ LACAO  - MARCA .T. OU DESMARCA .F.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FSELECIONA(AITENS , NAT , LQUIET , LACAO)
	IF EXISTBLOCK("LC145SEL") 		// PONTO DE ENTRADA NA SELEÇÃO DAS AS A SEREM CANCELADAS.
		AITENS := EXECBLOCK("LC145SEL",.T.,.T.,{AITENS, NAT, LQUIET, LACAO})
	ELSE
		IF EMPTY(AITENS[NAT,4])
			IF VALTYPE(LACAO) == "L"
				AITENS[NAT,1] := LACAO
			ELSE
				AITENS[NAT,1] := ! AITENS[NAT,1]
			ENDIF
		ELSE
			IF ! LQUIET
				MSGSTOP(STR0019 , STR0003) //"NÃO É POSSÍVEL MARCAR ESTA AS, VEJA COLUNA OBSERVAÇÕES"###"GPO - LOCF145.PRW"
			ENDIF
		ENDIF
	ENDIF

	OLBXITENS:REFRESH()

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³FMARCATUDO º AUTOR ³ IT UP BUSINESS     º DATA ³ 13/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ MARCA OU DESMARCA TODOS OS ITENS (AS)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPARÂMETROS³ LACAO  - SE .T. MARCA SENÃO DESMARCA                       º±±
±±º          ³ AITENS - ARRAY DOS ELEMENTOS (AS)                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FMARCATUDO(LACAO , AITENS)
LOCAL NI

	FOR NI := 1 TO LEN(AITENS)
		FSELECIONA(AITENS, NI, .T., LACAO)
	NEXT NI

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FCANCELAR º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ REALIZA O CANCELAMENTO DAS AS MARCADAS                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FCANCELAR(AITENS)
LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREADTQ := FQ5->(GETAREA())
LOCAL _AAREAZLG := FPO->(GETAREA())
LOCAL _AAREAZAG := FPA->(GETAREA())
LOCAL _AAREAZA5 := FP4->(GETAREA())
LOCAL _AAREAST9 := ST9->(GETAREA())
LOCAL _CQUERY   := ""
LOCAL CQUERY    := ""
LOCAL _CNFREM   := ""
LOCAL NI
LOCAL NCOUNT    := 0
LOCAL LVERZBX   := SUPERGETMV("MV_LOCX097",,.F.)  // HABILITA CONTROLE DE MINUTA
LOCAL _LEXCZAG  := SUPERGETMV("MV_LOCX274",,.F.)  // EXCLUÍ ZAG NO CANCELAMENTO DA AS
Local _LC145ACE := EXISTBLOCK("LC145ACE")
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local aBindParam

	BEGIN TRANSACTION

	FPA->(DBSETORDER(3)) //FPA_FILIAL+FPA_AS+FPA_VIAGEM
	ST9->(DBSETORDER(1)) //T9_FILIAL+T9_CODBEM
	FPO->(DBSETORDER(5)) //FPO_FILIAL+FPO_NRAS+FPO_FROTA+FPO_CODBEM

	FOR NI:=1 TO LEN(AITENS)
		
		IF AITENS[NI,1]
			FQ5->(DBGOTO(AITENS[NI,LEN(AITENS[NI])]))
			IF FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_AS))
				// Jose Eulalio - 16/01/2023 - SIGALOC94-619 - Integração com GS, Gestão de Serviços
				If lMvGSxRent
					If !LOCA084(.T.)
						Loop
					EndIf
				EndIf
				IF EMPTY(ALLTRIM(FPA->FPA_NFREM))
					//Atualiza Status
					IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
						If !lMvLocBac
							IF GETADVFVAL("TQY", "TQY_STTCTR",XFILIAL("TQY")+ST9->T9_STATUS,1,"") == "10" .and. !empty(ST9->T9_STATUS)
								IF LVERZBX		// TEM MINUTA? SE TIVER CHAMA ROTINA P/ EXCLUIR PROGRAMACAO E CANCELAR MINUTA
									LOCA00519( FQ5->FQ5_AS )
								ENDIF		
								
								IF SELECT("TRBTQY") > 0
									TRBTQY->(DBCLOSEAREA())
								ENDIF
								_CQUERY := " SELECT TQY_STATUS"
								_CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY"
								_CQUERY += " WHERE  TQY_STTCTR = '00'"
								_CQUERY += "   AND  TQY.D_E_L_E_T_ = ''"
								TCQUERY _CQUERY NEW ALIAS "TRBTQY"
								IF TRBTQY->(!EOF())
									LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,"","",.T.)
									IF RECLOCK("ST9",.F.)
										ST9->T9_STATUS := TRBTQY->TQY_STATUS
										ST9->(MSUNLOCK())
									ENDIF
								ENDIF
								
								TRBTQY->(DBCLOSEAREA())
							ENDIF
						else
							IF GETADVFVAL("FQD", "FQD_STAREN",XFILIAL("FQD")+ST9->T9_STATUS,1,"") == "10" .and. !empty(ST9->T9_STATUS)
								IF LVERZBX		// TEM MINUTA? SE TIVER CHAMA ROTINA P/ EXCLUIR PROGRAMACAO E CANCELAR MINUTA
									LOCA00519( FQ5->FQ5_AS )
								ENDIF
								
								IF SELECT("TRBTQY") > 0
									TRBTQY->(DBCLOSEAREA())
								ENDIF
								_CQUERY := " SELECT FQD_STATQY"
								_CQUERY += " FROM " + RETSQLNAME("FQD") + " FQD"
								_CQUERY += " WHERE  FQD_STAREN = '00'"
								_CQUERY += "   AND  FQD.D_E_L_E_T_ = ''"
								TCQUERY _CQUERY NEW ALIAS "TRBTQY"
								IF TRBTQY->(!EOF())
									LOCXITU21(ST9->T9_STATUS,TRBTQY->FQD_STATQY,FPA->FPA_PROJET,"","",.T.)
									IF RECLOCK("ST9",.F.)
										ST9->T9_STATUS := TRBTQY->FQD_STATQY
										ST9->(MSUNLOCK())
									ENDIF
								ENDIF
								
								TRBTQY->(DBCLOSEAREA())
							ENDIF
						ENDIF
					EndIF

					//atualiza campos após cancelar
					IF FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_AS))
						WHILE FPO->(!EOF()) .AND. FPO->FPO_FILIAL == XFILIAL("FPO") .AND. FPO->FPO_NRAS == FQ5->FQ5_AS
							IF RECLOCK("FPO",.F.)
								FPO->(DBDELETE())
								FPO->(MSUNLOCK())
							ENDIF
							FPO->(DBSKIP())
						ENDDO
					ENDIF
					
					// exclui FPA ou apaga viagem e AS
					IF _LEXCZAG
						IF RECLOCK("FPA",.F.)
							FPA->FPA_AS     := ""
							FPA->FPA_VIAGEM := ""
							FPA->(DBDELETE())
							FPA->(MSUNLOCK())
						ENDIF
					ELSE
						IF RECLOCK("FPA",.F.)
							FPA->FPA_AS     := ""
							FPA->FPA_VIAGEM := ""
							FPA->(MSUNLOCK())
						ENDIF
					ENDIF
					
					// Circenis - 25/01/2024 - Excluir as minutas antes de cancelar a AS
					msAguarde( {||LOCA04003(FQ5->FQ5_AS)}, "Aguarde! Excluindo informações de Minuta")

					IF FQ5->(RECLOCK("FQ5",.F.))
						FQ5->FQ5_STATUS := "9"
						FQ5->(MSUNLOCK())
					ENDIF
					
					IF _LC145ACE //EXISTBLOCK("LC145ACE") //PONTO DE ENTRADA PARA CANCELAMENTO DE AS DE ACESSÓRIO.
						EXECBLOCK("LC145ACE",.T.,.T.,{LVERZBX,_LEXCZAG,FPA->FPA_PROJET,FQ5->FQ5_AS,FQ5->FQ5_VIAGEM})
					ENDIF
					NCOUNT++
				ELSE
					IF EMPTY(_CNFREM)
						_CNFREM := ALLTRIM(FQ5->FQ5_AS)
					ELSE
						_CNFREM += CRLF + ALLTRIM(FQ5->FQ5_AS)
					ENDIF
					LOOP
				ENDIF
			ELSE
				FQ7->(DbSetOrder(3))			
				IF FQ7->(DBSEEK(XFILIAL("FQ7") + FQ5->FQ5_VIAGEM))
					IF FQ5->(RECLOCK("FQ5",.F.))
						FQ5->FQ5_STATUS := "9"
						FQ5->(MSUNLOCK())
					ENDIF
					IF RECLOCK("FQ7",.F.)
						FQ7->FQ7_VIAGEM := ""
						FQ7->(MSUNLOCK())
					ENDIF
					NCOUNT++
				EndIf	
			ENDIF
			
		ENDIF
	NEXT

	END TRANSACTION
	//DENNIS
	/*
	+ FP0->FP0_PROJET +
	*/
	CQUERY := " SELECT R_E_C_N_O_ AS REG" 
	CQUERY += " FROM " + RETSQLNAME("FPA") + " ZAG" 
	CQUERY += " WHERE FPA_PROJET = ? " 
	CQUERY += " AND FPA_AS <> ''" 
	CQUERY += " AND ZAG.D_E_L_E_T_ = ''"

	IF SELECT("TRBFPA") > 0
		TRBFPA->(DBCLOSEAREA())
	ENDIF
	CQUERY := CHANGEQUERY(CQUERY) 
	aBindParam := {FP0->FP0_PROJET}
	MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)

	//TCQUERY CQUERY NEW ALIAS "TRBFPA"

	IF TRBFPA->(EOF())
		IF RECLOCK("FP0", .F.)
			FP0->FP0_DATAS  := CTOD("  /  /    ")		// GRAVO A DATA DA GERAÇÃO DA AS
			FP0->(MSUNLOCK())
		ENDIF
	ENDIF

	IF !EMPTY(_CNFREM)
		AVISO(STR0022,STR0023+; //"CANCELAMENTO DE AS"###"AS AS'S ABAIXO NÃO FORAM CANCELADAS POR POSSUÍREM NOTAS FISCAIS DE REMESSA OU FATURAMENTO AUTOMÁTICO: "
		CRLF + CRLF + _CNFREM,{"OK"})
	ENDIF

	IF NCOUNT > 0
		AVISO(STR0022,STR0024+ALLTRIM(STR(NCOUNT))+" AS!",{"OK"}) //"CANCELAMENTO DE AS"###"FORAM CANCELADAS "
	ENDIF

	RESTAREA( _AAREAST9 )
	RESTAREA( _AAREADTQ )
	RESTAREA( _AAREAZA5 )
	RESTAREA( _AAREAZAG )
	RESTAREA( _AAREAZLG )
	RESTAREA( _AAREAOLD )

RETURN NIL

// Frank Zwarg Fuga
// Rotina para verificar se existem algum pedido de venda gerado antes de cancelar.
// 10/02/2023
FUNCTION LOCA04001(CNUMAS)
local _LRET   := .T.
local _CQUERY := ""
local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

	If !lMvLocBac

		/*
		+ALLTRIM(CNUMAS)+
		*/

		_cQuery := " SELECT C6_NUM "
		_cQuery += " FROM "+RETSQLNAME("SC6")+" SC6 "
		_cQuery += " WHERE  SC6.D_E_L_E_T_ = '' "
		_cQuery += "   AND  SC6.C6_XAS = ? "
		_cQuery := changequery(_cQuery) 
		IF SELECT("TRBSC6") > 0
			TRBSC6->(DBCLOSEAREA())
		ENDIF
		CQUERY := CHANGEQUERY(_CQUERY) 
		aBindParam := {ALLTRIM(CNUMAS)}
		MPSysOpenQuery(_cQuery,"TRBSC6",,,aBindParam)
		//TCQUERY _cQuery NEW ALIAS "TRBSC6"

		IF TRBSC6->(!EOF())
			_LRET := .F.
		ENDIF

		TRBSC6->(DBCLOSEAREA())
	Else
		
		/*
		+xFilial("FPY")+
		+xFilial("FPZ")+
		+ALLTRIM(CNUMAS)+
		*/

		_cQuery += " SELECT FPZ_AS FROM "+RETSQLNAME("FPZ")+" FPZ " "
		_cQuery += " JOIN "+RETSQLNAME("FPY")+ " FPY (NOLOCK) ON "
		_cQuery += " FPY_FILIAL = ? AND " 
		_cQuery += " FPY_PEDVEN = FPZ.FPZ_PEDVEN AND " 
		_cQuery += " FPY_STATUS <> '2' AND "
		_cQuery += " FPY.D_E_L_E_T_ = '' "
		_cQuery += " WHERE FPZ.FPZ_FILIAL = ? AND FPZ.FPZ_AS = ? AND FPZ.D_E_L_E_T_ = ''"
		_cQuery := changequery(_cQuery) 
		IF SELECT("TRBSC6") > 0
			TRBSC6->(DBCLOSEAREA())
		ENDIF
		_CQUERY := CHANGEQUERY(_CQUERY) 
		aBindParam := {xFilial("FPY"), xFilial("FPZ"), ALLTRIM(CNUMAS)}
		MPSysOpenQuery(_cQuery,"TRBSC6",,,aBindParam)
		//TCQUERY _cQuery NEW ALIAS "TRBSC6"

		IF TRBSC6->(!EOF())
			_LRET := .F.
		ENDIF

		TRBSC6->(DBCLOSEAREA())
	EndIF

RETURN _LRET

/*/{Protheus.doc} LOCA04002
Verifica se uma AS possui minutas que não sejam Previstas ou Canceladas
@type function
@version 1
@author aleci
@since 1/25/2024
@param cAS, character, Codigo da AS que poderá ser cancelada
@return variant, Descritivo da Minuta que impede o cancelamento da AS
/*/
Function LOCA04002( cAS)
Local cQuery := ""
Local aBindParam := {}
Local aArea := GetArea()
Local cRet := ""

cQuery += "SELECT DISTINCT FPF_STATUS, FPF_DATA"
cQuery += " FROM "+RETSQLNAME("FPF")
cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"'"
cQuery += " AND FPF_AS = ?"
Aadd( aBindParam, cAS)
cQuery += " AND FPF_STATUS <> '1'" // Planejada
cQuery += " AND FPF_STATUS <> '5'" // Cancelada
cQuery += " AND D_E_L_E_T_ = ' '"
MPSysOpenQuery(cQuery,"TRBFPF",,,aBindParam)

IF TRBFPF->(!EOF())
	cRet := "Há "
	if TRBFPF->FPF_STATUS == "2"
		cRet += "MINUTA CONFIRMADA"
	elseif TRBFPF->FPF_STATUS=="3"'
		cRet += "MINUTA BAIXADA"
	elseif TRBFPF->FPF_STATUS=="4"
		cRet += "MINUTA ENCERRADA"
	//elseif TRBFPF->FPF_STATUS=="5"'
	//	cRet += "MINUTA CANCELADA"
	elseif TRBFPF->FPF_STATUS=="6"
		cRet += "MINUTA MEDIDA"
	else
		cRet += "COM STATUS "+TRBFPF->FPF_STATUS
	endif
	cRet += " em "+Dtoc(Stod(TRBFPF->FPF_DATA))
endif

RestArea(aArea)
Return cRet

/*/{Protheus.doc} LOCA04003
Exclui as Minutas Previstas e Canceladas de Uma AS
@type function
@version 1
@author aleci
@since 1/25/2024
@param cAS, character, Codigo da AS que terá as Minutas excluidas
/*/
Function LOCA04003( cAS)
Local cQuery := ""
Local aBindParam := {}
Local aArea := GetArea()

cQuery += "SELECT R_E_C_N_O_ REG"
cQuery += " FROM "+RETSQLNAME("FPF")
cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"'"
cQuery += " AND FPF_AS = ?"
Aadd( aBindParam, cAS)
cQuery += " AND FPF_STATUS IN ('1', '5')" // Planejada
cQuery += " AND D_E_L_E_T_ = ' '"
MPSysOpenQuery(cQuery,"TRBFPF",,,aBindParam)

while TRBFPF->(!EOF())
	FPF->(dbGoto(TRBFPF->REG))
	RecLock("FPF",.F.)
	FPF->(dbDelete())
	FPF->(msUnLock())
	TRBFPF->(dbSkip())
enddo
RestArea(aArea)
Return
