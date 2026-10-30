#Include "loca040.ch"
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
Local AAREA    := GETAREA()
Local AAREAZA0 := FP0->(GETAREA())
Local AAREADTQ := FQ5->(GETAREA())
Local AITENS   := {}
Local OOK      := LOADBITMAP( GETRESOURCES(), "LBOK")
Local ONO      := LOADBITMAP( GETRESOURCES(), "LBNO")
Local _CQUERY  := ""
Local _CWHERE  := ""
Local cComando := ""
Local aHeader  := {}						//DSERLOCA-13030
Local aCampos  := {}						//DSERLOCA-13030
Local aBusca   := {}						//DSERLOCA-13030
Local aLinha   := {}						//DSERLOCA-13030
Local nI       := 0						//DSERLOCA-13030
Local cPesq    := Space(30)				//DSERLOCA-13030
Local oGetPesq							//DSERLOCA-13030
Local cFiltro  := ""					//DSERLOCA-13030
Local aFilPar  := {}					//DSERLOCA-13030
Local lMVLoc315 := .F. //SuperGetMV("MV_LOCX315",, .F.)

	PRIVATE ODLG , OLBXITENS

	IF SELECT("FP0") == 0 .OR. FP0->(EOF() .OR. EMPTY(FP0->FP0_PROJET))
		MSGSTOP(IIF(SELECT("FP0")==0 , STR0001 , STR0002) , STR0003) //"OPERAÇÃO CANCELADA: O ARQUIVO ZA0 NÃO ESTÁ ABERTO!"###"OPERAÇÃO CANCELADA: SELECIONE UM PROJETO ANTES DE ACESSAR ESTA ROTINA"###"GPO - LOCF145.PRW"
		RETURN NIL
	ENDIF

	// DSERLOCA-11386 - Frank em 07/08/2026
	If lMVLoc315
		If FP0->FP0_STATUS == "A" .or. FP0->FP0_STATUS == "5"
			MsgAlert(STR0028,STR0029) //"O status do orçamento não permite o cancelamento da AS."###"Atenção!"
			Return .F.
		EndIf
	EndIf

	//DSERLOCA-13030 - Filtros de abertura da rotina. Cancelando o ParamBox, traz todos os registros
	LOC040PAR(@cFiltro, @aFilPar)			//DSERLOCA-13030

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

	//DSERLOCA-13030 - Aplica as faixas informadas no ParamBox
	_CWHERE += cFiltro						//DSERLOCA-13030

	cComando := '_CQUERY += _CWHERE '
	&(cComando)
	_CQUERY     += " ORDER BY FQ5_FILIAL , FQ5_FILORI , FQ5_SOT , FQ5_AS "
	_CQUERY := CHANGEQUERY(_CQUERY) 
	aBindParam := {XFILIAL("FQ5"),FP0->FP0_FILIAL,FP0->FP0_PROJET }
	For nI := 1 To Len(aFilPar)				//DSERLOCA-13030
		aAdd(aBindParam, aFilPar[nI])		//DSERLOCA-13030
	Next nI									//DSERLOCA-13030
	MPSysOpenQuery(_CQUERY,"TRBFQ5",,,aBindParam)
	//TCQUERY _CQUERY NEW ALIAS "TRBFQ5"

	FQ5->(DBSETORDER(RETORDEM("FQ5","FQ5_FILIAL+FQ5_SOT+FQ5_OBRA+FQ5_VIAGEM")))

	//DSERLOCA-13030 - Monta dinamicamente as colunas com todos os campos da tabela FQ5
	aCampos := LOC040EST()					//DSERLOCA-13030
	aHeader := {"SEL", STR0007}				//DSERLOCA-13030 //"OBSERVAÇÕES"
	For nI := 1 To Len(aCampos)				//DSERLOCA-13030
		aAdd(aHeader, aCampos[nI][3])		//DSERLOCA-13030
	Next nI									//DSERLOCA-13030

	WHILE TRBFQ5->(!EOF())
		FQ5->(DBGOTO(TRBFQ5->FQ5RECNO))
		//DSERLOCA-13030 - Layout do item: 1=Flag de marcação / 2=Observações / 3..N=Campos da FQ5 / Ultimo=Recno
		aLinha := {.F., FSTATUS()}			//DSERLOCA-13030
		For nI := 1 To Len(aCampos)			//DSERLOCA-13030
			aAdd(aLinha, LOC040VAL(aCampos[nI]))	//DSERLOCA-13030
		Next nI								//DSERLOCA-13030
		aAdd(aLinha, FQ5->(RECNO()))		//DSERLOCA-13030
		AADD(AITENS, aLinha)				//DSERLOCA-13030
		aAdd(aBusca, LOC040CHV())			//DSERLOCA-13030   
		TRBFQ5->(DBSKIP())
	ENDDO
	TRBFQ5->(DBCLOSEAREA())

	IF LEN(AITENS) > 0
		DEFINE MSDIALOG ODLG TITLE STR0004+FP0->FP0_PROJET FROM 000,000 TO 620,1400 PIXEL //"AS DO PROJETO: " //DSERLOCA-13030
			@ 005,005 SAY STR0005 OF ODLG PIXEL //"SELECIONE AS AUTORIZAÇÕES DE SERVIÇO PARA CANCELAMENTO:"

			//DSERLOCA-13030 - Pesquisa por Código do Produto / Bem / Data de Geração / Data de Início (apenas posiciona, não filtra)
			@ 019,005 SAY "Pesquisar:" OF ODLG PIXEL SIZE 035,008		//DSERLOCA-13030
			@ 017,040 MSGET oGetPesq VAR cPesq PICTURE "@!" OF ODLG PIXEL SIZE 120,010	//DSERLOCA-13030
			@ 016,166 BUTTON "Pesquisar" SIZE 045,013 PIXEL OF ODLG ACTION LOC040PSQ(aBusca, cPesq, OLBXITENS)	//DSERLOCA-13030
			@ 019,218 SAY "(Cód.Produto / Bem / Data Geração / Data Início)" OF ODLG PIXEL SIZE 200,008	//DSERLOCA-13030

			@ 034,005 LISTBOX OLBXITENS FIELDS HEADER "SEL" SIZE 690,222 OF ODLG PIXEL ON DBLCLICK ( FSELECIONA(AITENS, OLBXITENS:NAT, .F.) ) //DSERLOCA-13030
			OLBXITENS:aHeaders := aHeader			//DSERLOCA-13030
			OLBXITENS:SETARRAY(AITENS)
			OLBXITENS:BLINE := {|| LOC040LIN(AITENS[OLBXITENS:NAT], OOK, ONO) }	//DSERLOCA-13030
			
			@ 275,010 BUTTON STR0008	  SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.T., AITENS) //"MARCA TODOS" //DSERLOCA-13030
			@ 275,075 BUTTON STR0009 SIZE 50,15 PIXEL OF ODLG ACTION FMARCATUDO(.F., AITENS) //"DESMARCA TODOS" //DSERLOCA-13030
			@ 275,570 BUTTON STR0010	  SIZE 50,15 PIXEL OF ODLG ACTION (FCANCELAR(AITENS), ODLG:END()) //"CANCELAR AS" //DSERLOCA-13030
			@ 275,635 BUTTON STR0011			  SIZE 50,15 PIXEL OF ODLG ACTION ODLG:END() //"SAIR" //DSERLOCA-13030
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

	IF !empty(FQ5->FQ5_DEMAND)
		_RET := STR0025 + alltrim(FQ5->FQ5_DEMAND) + "" //"A.S. VINCULADA A DEMANDA "
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
		IF EMPTY(AITENS[NAT,2])	//DSERLOCA-13030 - Observações passou da posição 4 para a posição 2 do array
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
Local cStatus
Local lMVLOC278 := SuperGetMV("MV_LOCX278",,.F.)

Private oSay

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

					// DSERLOCA-10875 - Frank em 18/02/2026
					// Tratamento da geração do título provisório pelo campo FP0_PROV
					If FP0->(FieldPos("FP0_PROV")) > 0
						If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
							lMVLOC278 := .T.
						Else
							lMVLOC278 := .F.
						EndIf
					EndIf
					If lMVLOC278	
						If FQB->(fieldpos("FQB_RASTRO")) == 0 .or. !FindFunction( "LOCA10801" )
							// o parâmetro 2 identifica que a chave é por projeto + as
							LOCA013DEL(2, FPA->FPA_PROJET, FPA->FPA_AS)
						Else

							// Refaz os provisórios no caso de serem do modelo antigo
							If FindFunction( "LOCA1080B" )
								LOCA1080B()
							EndIf

							// o parâmetro 2 identifica que a chave é por projeto + as
							FWMsgRun(, {|oSay| aRet := LOCA10806(2, FPA->FPA_PROJET, FPA->FPA_AS,,,.T.) }, STR0026, STR0027) //"Títulos provisórios"###"Estornando a movimentação financeira."
							
						EndIf
					EndIF
					
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

					// Issue: DSERLOCA-9775 - Alessandro Gois, 11/12/2025
					cStatus := POSICIONE("FQD" , 2 , XFILIAL("FQD")+St9->T9_STATUS , "FQD_STAREN")

					if alltrim(cStatus) == '10'
						
						FQ4->(DBSETORDER(1))
						if FQ4->(DBSEEK(XFILIAL("FQ4") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
							do while !eof() .and. FQ4->FQ4_FILIAL == XFILIAL("FQ4") .and. ;
											 FQ4->FQ4_CODBEM == FQ5->FQ5_GUINDA

								if FQ4->FQ4_STATUS == ST9->T9_STATUS .AND. FQ4->FQ4_PROJET == FQ5->FQ5_SOT

									IF RECLOCK("FQ4",.F.)
										FQ4->(DBDELETE())
										FQ4->(MSUNLOCK())
									ENDIF
									
									exit
								
								endif								

								FQ4->(DbSkip())
							enddo

							IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
								IF RECLOCK("ST9",.F.)
									ST9->T9_STATUS := POSICIONE("FQD" , 1 , XFILIAL("FQD")+'00' , "FQD_STATQY")
									ST9->(MSUNLOCK())
								ENDIF
							endif

						endif
					endif
					// Final de alteracao, Issue: DSERLOCA-9775 -  Alessandro Gois, 11/12/2025

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


/*/{Protheus.doc} LOC040EST
Monta a estrutura dinâmica de colunas com todos os campos da tabela FQ5
@type static function
@return array, {{cCampo, cTipo, cTitulo, nTamanho, cPicture, nDecimal}, ...}
/*/
STATIC FUNCTION LOC040EST()					//DSERLOCA-13030
Local aRet    := {}							//DSERLOCA-13030
Local aArea   := GetArea()					//DSERLOCA-13030
Local aAreaX3 := SX3->(GetArea())			//DSERLOCA-13030
Local nNivel  := IIf(Type("cNivel") == "N", cNivel, 9)	//DSERLOCA-13030

	SX3->(DbSetOrder(1))					//DSERLOCA-13030
	If SX3->(DbSeek("FQ5"))					//DSERLOCA-13030
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "FQ5"	//DSERLOCA-13030
			If X3Uso(SX3->X3_USADO) .And. nNivel >= SX3->X3_NIVEL .And. ;	//DSERLOCA-13030
			   SX3->X3_TIPO <> "M" .And. FQ5->(FieldPos(AllTrim(SX3->X3_CAMPO))) > 0	//DSERLOCA-13030
				aAdd(aRet, {AllTrim(SX3->X3_CAMPO)  ,;	//DSERLOCA-13030
							SX3->X3_TIPO           ,;	//DSERLOCA-13030
							AllTrim(X3Titulo())    ,;	//DSERLOCA-13030
							SX3->X3_TAMANHO        ,;	//DSERLOCA-13030
							AllTrim(SX3->X3_PICTURE),;	//DSERLOCA-13030
							SX3->X3_DECIMAL})		//DSERLOCA-13030
			EndIf							//DSERLOCA-13030
			SX3->(DbSkip())					//DSERLOCA-13030
		EndDo								//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	SX3->(RestArea(aAreaX3))				//DSERLOCA-13030
	RestArea(aArea)							//DSERLOCA-13030

RETURN aRet									//DSERLOCA-13030

/*/{Protheus.doc} LOC040VAL
Retorna o conteúdo formatado do campo da FQ5 posicionada
@type static function
@param aCampo, array, Elemento da estrutura montada em LOC040EST
@return character, Conteúdo formatado para exibição na listbox
/*/
STATIC FUNCTION LOC040VAL(aCampo)			//DSERLOCA-13030
Local nPos := FQ5->(FieldPos(aCampo[1]))	//DSERLOCA-13030
Local xVal := Nil							//DSERLOCA-13030
Local cRet := ""							//DSERLOCA-13030

	If nPos == 0							//DSERLOCA-13030
		Return cRet							//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	xVal := FQ5->(FieldGet(nPos))			//DSERLOCA-13030

	Do Case								//DSERLOCA-13030
		Case aCampo[2] == "D"				//DSERLOCA-13030
			cRet := IIf(Empty(xVal), "", DtoC(xVal))	//DSERLOCA-13030
		Case aCampo[2] == "N"				//DSERLOCA-13030
			cRet := IIf(Empty(aCampo[5]), AllTrim(Str(xVal, aCampo[4], aCampo[6])), AllTrim(Transform(xVal, aCampo[5])))	//DSERLOCA-13030
		Case aCampo[2] == "L"				//DSERLOCA-13030
			cRet := IIf(xVal, "Sim", "Nao")		//DSERLOCA-13030
		OtherWise							//DSERLOCA-13030
			cRet := xVal					//DSERLOCA-13030
	EndCase								//DSERLOCA-13030

RETURN cRet									//DSERLOCA-13030

/*/{Protheus.doc} LOC040LIN
Monta a linha exibida na listbox (flag + observações + campos da FQ5), sem o Recno
@type static function
@param aLinha, array, Elemento do array de itens
@param oOk, object, Bitmap de marcado
@param oNo, object, Bitmap de desmarcado
@return array, Conteúdo das colunas da linha
/*/
STATIC FUNCTION LOC040LIN(aLinha, oOk, oNo)	//DSERLOCA-13030
Local aRet := {}							//DSERLOCA-13030
Local nX   := 0								//DSERLOCA-13030

	aAdd(aRet, IIf(aLinha[1], oOk, oNo))	//DSERLOCA-13030

	For nX := 2 To Len(aLinha) - 1			//DSERLOCA-13030
		aAdd(aRet, aLinha[nX])				//DSERLOCA-13030
	Next nX									//DSERLOCA-13030

RETURN aRet									//DSERLOCA-13030

/*/{Protheus.doc} LOC040CHV
Monta a chave de pesquisa da FQ5 posicionada (Cód.Produto / Bem / Data Geração / Data Início)
@type static function
@return character, Chave concatenada para pesquisa
/*/
STATIC FUNCTION LOC040CHV()					//DSERLOCA-13030
Local cRet := "|"							//DSERLOCA-13030

	If FQ5->(FieldPos("FQ5_XPROD")) > 0		//DSERLOCA-13030
		cRet += Upper(AllTrim(FQ5->FQ5_XPROD)) + "|"	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	If FQ5->(FieldPos("FQ5_GUINDA")) > 0	//DSERLOCA-13030
		cRet += Upper(AllTrim(FQ5->FQ5_GUINDA)) + "|"	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	If FQ5->(FieldPos("FQ5_EQUIP")) > 0		//DSERLOCA-13030
		cRet += Upper(AllTrim(FQ5->FQ5_EQUIP)) + "|"	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	If FQ5->(FieldPos("FQ5_DATGER")) > 0 .And. !Empty(FQ5->FQ5_DATGER)	//DSERLOCA-13030
		cRet += DtoC(FQ5->FQ5_DATGER) + "|" + StrTran(DtoC(FQ5->FQ5_DATGER), "/", "") + "|" + DtoS(FQ5->FQ5_DATGER) + "|"	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	If FQ5->(FieldPos("FQ5_DATINI")) > 0 .And. !Empty(FQ5->FQ5_DATINI)	//DSERLOCA-13030
		cRet += DtoC(FQ5->FQ5_DATINI) + "|" + StrTran(DtoC(FQ5->FQ5_DATINI), "/", "") + "|" + DtoS(FQ5->FQ5_DATINI) + "|"	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

RETURN cRet									//DSERLOCA-13030

/*/{Protheus.doc} LOC040PSQ
Pesquisa e posiciona a listbox no registro digitado (não filtra a lista)
@type static function
@param aBusca, array, Chaves de pesquisa de cada item
@param cPesq, character, Conteúdo digitado pelo usuário
@param oLbx, object, Listbox a ser posicionada
/*/
STATIC FUNCTION LOC040PSQ(aBusca, cPesq, oLbx)	//DSERLOCA-13030
Local cChave := Upper(AllTrim(cPesq))		//DSERLOCA-13030
Local nIni   := 0							//DSERLOCA-13030
Local nPos   := 0							//DSERLOCA-13030
Local nX     := 0							//DSERLOCA-13030
Local lAchou := .F.							//DSERLOCA-13030

	If Empty(cChave)						//DSERLOCA-13030
		MsgStop("Informe o código do produto, o bem, a data de geração ou a data de início para pesquisar.", "Pesquisa")	//DSERLOCA-13030
		Return Nil							//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	nIni := oLbx:nAt						//DSERLOCA-13030

	For nX := 1 To Len(aBusca)				//DSERLOCA-13030
		nPos := nIni + nX					//DSERLOCA-13030
		If nPos > Len(aBusca)				//DSERLOCA-13030
			nPos -= Len(aBusca)				//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
		If cChave $ aBusca[nPos]			//DSERLOCA-13030
			lAchou := .T.					//DSERLOCA-13030
			Exit							//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
	Next nX									//DSERLOCA-13030

	If lAchou								//DSERLOCA-13030
		oLbx:nAt := nPos					//DSERLOCA-13030
		oLbx:Refresh()						//DSERLOCA-13030
		oLbx:SetFocus()						//DSERLOCA-13030
	Else								//DSERLOCA-13030
		MsgStop("Nenhum registro localizado para: " + cChave, "Pesquisa")	//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

RETURN Nil									//DSERLOCA-13030

/*/{Protheus.doc} LOC040PAR
Exibe o ParamBox de filtro na abertura da rotina e monta a condição SQL das faixas
informadas. Se o usuário cancelar, nenhum filtro é aplicado e todos os registros
são apresentados.
@type static function
@param cFiltro, character, (Referência) Condição SQL montada
@param aFilPar, array, (Referência) Parâmetros de bind da condição
@return logical, .T. quando o filtro foi confirmado
/*/
STATIC FUNCTION LOC040PAR(cFiltro, aFilPar)	//DSERLOCA-13030
Local aPergs := {}							//DSERLOCA-13030
Local aRet   := {}							//DSERLOCA-13030
Local cFilFPA:= ""							//DSERLOCA-13030

	cFiltro := ""							//DSERLOCA-13030
	aFilPar := {}							//DSERLOCA-13030

	// Campos da FQ5						//DSERLOCA-13030
	aAdd(aPergs, {1, "Cód. Produto De  ", Space(30)          , "@!", "", "SB1", "", 100, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Cód. Produto Até ", Replicate("Z", 30), "@!", "", "SB1", "", 100, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Bem De          ", Space(16)          , "@!", "", "ST9", "", 080, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Bem Até         ", Replicate("Z", 16), "@!", "", "ST9", "", 080, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Data Geração De ", CtoD("")           , ""  , "", ""   , "", 060, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Data Geração Até", CtoD("")           , ""  , "", ""   , "", 060, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Data Início De   ", CtoD("")           , ""  , "", ""   , "", 060, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Data Início Até  ", CtoD("")           , ""  , "", ""   , "", 060, .F.})	//DSERLOCA-13030

	// Campos da FPA						//DSERLOCA-13030
	aAdd(aPergs, {1, "Estrutura De    ", Space(19)          , "@!", "", ""   , "", 090, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Estrutura Até   ", Replicate("Z", 19), "@!", "", ""   , "", 090, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Grp Medição De        ", Space(03)          , "@!", "", ""   , "", 040, .F.})	//DSERLOCA-13030
	aAdd(aPergs, {1, "Grp Medição Até       ", Replicate("Z", 03), "@!", "", ""   , "", 040, .F.})	//DSERLOCA-13030

	If !ParamBox(aPergs, "Filtros - Cancelamento de AS", @aRet)	//DSERLOCA-13030
		cFiltro := ""						//DSERLOCA-13030
		aFilPar := {}						//DSERLOCA-13030
		Return .F.							//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

	// A ordem das chamadas define a ordem dos binds, que deve acompanhar a ordem dos "?" na query	//DSERLOCA-13030
	LOC040RNG("FQ5_XPROD" , aRet[01], aRet[02], @cFiltro, @aFilPar)	//DSERLOCA-13030
	LOC040RNG("FQ5_GUINDA", aRet[03], aRet[04], @cFiltro, @aFilPar)	//DSERLOCA-13030
	LOC040RNG("FQ5_DATGER", aRet[05], aRet[06], @cFiltro, @aFilPar)	//DSERLOCA-13030
	LOC040RNG("FQ5_DATINI", aRet[07], aRet[08], @cFiltro, @aFilPar)	//DSERLOCA-13030

	// Filtros da FPA: aplicados via EXISTS para não duplicar as linhas da FQ5	//DSERLOCA-13030
	LOC040RNG("FPAF.FPA_SEQEST", aRet[09], aRet[10], @cFilFPA, @aFilPar)	//DSERLOCA-13030
	LOC040RNG("FPAF.FPA_GRUPOM", aRet[11], aRet[12], @cFilFPA, @aFilPar)	//DSERLOCA-13030

	If !Empty(cFilFPA)						//DSERLOCA-13030
		cFiltro += "   AND  EXISTS(SELECT 1 "	//DSERLOCA-13030
		cFiltro += "               FROM " + RETSQLNAME("FPA") + " FPAF "	//DSERLOCA-13030
		cFiltro += "               WHERE  FPAF.FPA_FILIAL = FQ5_FILORI "	//DSERLOCA-13030
		cFiltro += "                 AND  FPAF.FPA_PROJET = FQ5_SOT "	//DSERLOCA-13030
		cFiltro += "                 AND  FPAF.FPA_AS     = FQ5_AS "	//DSERLOCA-13030
		cFiltro += "                 AND  FPAF.D_E_L_E_T_ = '' "	//DSERLOCA-13030
		cFiltro += cFilFPA					//DSERLOCA-13030
		cFiltro += ") "						//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

RETURN .T.									//DSERLOCA-13030

/*/{Protheus.doc} LOC040RNG
Acrescenta a faixa (de/até) de um campo na condição SQL. Faixa em branco ou
preenchida somente com "Z" é ignorada, mantendo todos os registros.
@type static function
@param cCampo, character, Campo (aceita o prefixo do alias, ex: FPAF.FPA_SEQEST)
@param xDe, variant, Conteúdo inicial da faixa
@param xAte, variant, Conteúdo final da faixa
@param cWhere, character, (Referência) Condição SQL
@param aBind, array, (Referência) Parâmetros de bind
/*/
STATIC FUNCTION LOC040RNG(cCampo, xDe, xAte, cWhere, aBind)	//DSERLOCA-13030
Local cCpo  := SubStr(cCampo, At(".", cCampo) + 1)	//DSERLOCA-13030
Local nTam  := 0							//DSERLOCA-13030

	If ValType(xDe) == "D"					//DSERLOCA-13030
		If !Empty(xDe)						//DSERLOCA-13030
			cWhere += "   AND  " + cCampo + " >= ? "	//DSERLOCA-13030
			aAdd(aBind, DtoS(xDe))			//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
		If !Empty(xAte)						//DSERLOCA-13030
			cWhere += "   AND  " + cCampo + " <= ? "	//DSERLOCA-13030
			aAdd(aBind, DtoS(xAte))			//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
	Else								//DSERLOCA-13030
		nTam := TamSX3(cCpo)[1]				//DSERLOCA-13030
		If !Empty(AllTrim(xDe))				//DSERLOCA-13030
			cWhere += "   AND  " + cCampo + " >= ? "	//DSERLOCA-13030
			aAdd(aBind, PadR(AllTrim(xDe), nTam))	//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
		If !Empty(AllTrim(xAte)) .And. AllTrim(xAte) <> Replicate("Z", Len(AllTrim(xAte)))	//DSERLOCA-13030
			cWhere += "   AND  " + cCampo + " <= ? "	//DSERLOCA-13030
			aAdd(aBind, PadR(AllTrim(xAte), nTam))	//DSERLOCA-13030
		EndIf							//DSERLOCA-13030
	EndIf								//DSERLOCA-13030

RETURN Nil									//DSERLOCA-13030

// forcar a atualizacao para advpr
function LOCA040ADV
return .t.
