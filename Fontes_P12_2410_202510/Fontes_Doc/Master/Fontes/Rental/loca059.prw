#INCLUDE "LOCA059.ch"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/*/{PROTHEUS.DOC} LOCA059.PRW
ITUP BUSINESS - TOTVS RENTAL
APONTADOR AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
FUNCTION LOCA059()
Local CEXPFILTRO
Local _LTEMVINC := SUPERGETMV("MV_LOCX029",.F.,.T.)
Local _LC111COR := EXISTBLOCK("LC111COR")
Local _LC059FIL := EXISTBLOCK("LC059FIL")
Local _LC111ROT := EXISTBLOCK("LC111ROT")

Private AROTINA   := {}
Private CCADASTRO := STR0001 //"Apontador AS"
Private CPERG     := "LOCP010"
Private CSERV	  := ""
Private ACORES
Private LMINUTA	  := SUPERGETMV("MV_LOCX097",.F.,.T.) //SUPERGETMV("MV_LOCX052",.F.,.T.) trocado a pedido do Lui em 19/08/21 Frank.
Private LROMANEIO := SUPERGETMV("MV_LOCX071",.F.,.T.)
Private LFUNCAS   := SUPERGETMV("MV_LOCX237" ,.F.,.F.)
Private LFILTFIL  := SUPERGETMV("MV_LOCX236",.F.,.T.)

Private lGeraFPF := .T.

// DSERLOCA-1982 - Frank em 30/04/2024
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)
Public  DDT1      := CTOD("")
Public  DDT2      := CTOD("")
Public  CTP1      := ""
Public  CFIL1     := ""
Public  CFIL2     := ""

	If !(AMIIn(05,19,94))// Só continua se tiver licença do Rental/Faturamento/MNT
		MSGSTOP(STR0295) //"Utilizar Módulo RENTAL para Essa Funcionalidade - Configure corretamento o Menu"
		Return .t.
	Endif

	if TamSx3("FPA_FILREM")[1] <> TamSx3("C6_FILIAL")[1]
		MSGSTOP("Tamanho do campo FPA_FILREM diferente do tamanho dos demais campos de Filial, Ajuste antes de continuar.") //"Utilizar Módulo RENTAL para Essa Funcionalidade - Configure corretamento o Menu"
		Return .t.
	endif

	// FRANK 23/09/2020 - SE FOREM CRIADAS NOVAS PERGUNTAS PRECISAM SER TRATADAS NO FILTRO DO ACEITE EM LOTE
	IF ! PERGUNTE(CPERG,.T.)
		RETURN NIL
	ENDIF

	If MV_PAR03 == 1
		MV_PAR03 := "L"
	Else
		MV_PAR03 := "F"
	EndIf

	DDT1  := MV_PAR01
	DDT2  := MV_PAR02
	CTP1  := MV_PAR03
	CFIL1 := MV_PAR04
	CFIL2 := MV_PAR05

	CSERV := IIF( CTP1 $ "TELF" , CTP1 , " " )

	//para criação dos botoes em AROTINA para MBROWSE, deve-se seguir a seguinte documentação: https://tdn.totvs.com/pages/releaseview.action?pageId=24346981

	aRotina := menudef(aRotina,LFUNCAS,CSERV, MV_PAR03, LROMANEIO, _LTEMVINC )

	ACORES := { {' EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_VERDE'    },; //  PENDENTE
				{'!FQ5->FQ5_STATUS $ "1/6" '														 , 'BR_VERMELHO' },; //  REJEITADO
				{'FQ5->FQ5_STATUS == "6"'															 , 'BR_LARANJA'  } } //  ACEITA

				// Legendas removida por Frank em 06/07/21 a pedido do Lui
				//{'!EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_AMARELO'  },; //  FECHADA
				//{'!EMPTY(FQ5->FQ5_DATFEC) .AND. !EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1"', 'BR_AZUL'     },; //  ENCERRADO

	IF _LC111COR 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CORES NO BROWSER.
		ACORES := EXECBLOCK("LC111COR",.T.,.T.,{ACORES})
	ENDIF

	DBSELECTAREA("FQ5")

	CEXPFILTRO         := "     FQ5_DATINI >= '" + DTOS(DDT1) + "'"
	CEXPFILTRO         += " AND FQ5_DATFIM <= '" + DTOS(DDT2) + "'"
	CEXPFILTRO         += " AND FQ5_TPAS    = '" + CSERV      + "'"
	CEXPFILTRO         += " AND FQ5_FILIAL  = '" + xFilial("FQ5") + "'"

	// Ponto de entrada para filtrar o browse
	// Frank Zwarg Fuga - 16/06/2021
	IF _LC059FIL //EXISTBLOCK("LC059FIL")
		CEXPFILTRO += EXECBLOCK("LC059FIL" , .T. , .T. , {CEXPFILTRO})
	ENDIF

	IF _LC111ROT //EXISTBLOCK("LC111ROT") 												// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NO AÇÕES RELACIONADAS
		AROTINA := EXECBLOCK("LC111ROT",.T.,.T.,{AROTINA})
	ENDIF

	MBROWSE(6 , 1 , 22 , 75 , "FQ5" , , , , , 1 , ACORES , , , , , , , , CEXPFILTRO)

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05901
ITUP BUSINESS - TOTVS RENTAL
Legenda
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05901()
Local ALEGENDA
Local _LC111LEG := EXISTBLOCK("LC111LEG")

	ALEGENDA := { {"BR_VERDE"  , STR0018},; //"Em aberto"
				{"BR_VERMELHO" , STR0019},; //"Rejeitada"
				{"BR_LARANJA"  , STR0020} } //"AS aceita"


	IF _LC111LEG //EXISTBLOCK("LC111LEG") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE LEGENDA.
		ALEGENDA := EXECBLOCK("LC111LEG",.T.,.T.,{ALEGENDA})
	ENDIF

	BRWLEGENDA(CCADASTRO , STR0012 , ALEGENDA)  //"Legenda"

RETURN .T.

/*/{PROTHEUS.DOC} LOCA05902
ITUP BUSINESS - TOTVS RENTAL
Impressão da AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05902()
	LOCR015( FQ5->FQ5_AS )
RETURN .T.

/*/{PROTHEUS.DOC} LOCA05903
ITUP BUSINESS - TOTVS RENTAL
Fechamento da AS
@TYPE FUNCTION
@AUTHOR ITUP
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05903()
Local CFILOLD := CFILANT

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	CFILANT := FQ5->FQ5_FILORI

	IF FQ5->FQ5_STATUS == "6"
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0025}) //"AS aceita, operação cancelada."
	ELSEIF ! EMPTY(FQ5->FQ5_DATFEC)
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0026}) //"AS já se encontra fechada."
	ELSEIF ! EMPTY(FQ5->FQ5_DATENC)
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0027}) //"AS já se encontra encerrada."
	ELSEIF MSGYESNO(STR0028 + DTOC(DDATABASE) + ") ?" , STR0022)  //"CONFIRMA O FECHAMENTO DA AS NA DATA DE HOJE ("###"Atenção!"
		RECLOCK("FQ5",.F.)
		FQ5->FQ5_DATFEC := DDATABASE
		FQ5->FQ5_HORFEC := TIME()
		FQ5->(MSUNLOCK())
	ENDIF

	CFILANT := CFILOLD

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05904
ITUP BUSINESS - TOTVS RENTAL
Encerramento da AS
@TYPE FUNCTION
@AUTHOR ITUP
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05904()

Local CFILOLD := CFILANT

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	CFILANT := FQ5->FQ5_FILORI

	IF FQ5->FQ5_STATUS == "6"
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0025}) //"AS aceita, operação cancelada."
	ELSEIF ! EMPTY(FQ5->FQ5_DATENC)
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0027}) //"AS já se encontra encerrada."
	ELSEIF   EMPTY(FQ5->FQ5_DATFEC)
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0029}) //"AS precisa ser fechada antes de ser encerrada."
	ELSEIF MSGYESNO(STR0030 + DTOC(DDATABASE) + ") ?" , STR0022)  //"Confirma o encerramento da AS na data de hoje ("###"Atenção!"
		RECLOCK("FQ5",.F.)
		FQ5->FQ5_DATENC := DDATABASE
		FQ5->FQ5_HORENC := TIME()
		FQ5->(MSUNLOCK())
	ENDIF

	CFILANT := CFILOLD

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05905
ITUP BUSINESS - TOTVS RENTAL
Reabertura da AS
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05905()
Local CFILOLD := CFILANT

	CFILANT := FQ5->FQ5_FILORI

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	DO CASE
	CASE  FQ5->FQ5_STATUS == "6"
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0025}) //"AS aceita, operação cancelada."
	CASE ! EMPTY(FQ5->FQ5_DATENC)							// --> SE A AS ENCONTRA-SE ENCERRADA
		IF MSGYESNO(STR0031 , STR0022) //"Confirma o estorno do encerramento da AS ?"###"Atenção!"
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_DATENC := CTOD("//")
			FQ5->FQ5_HORENC := SPACE(LEN(FQ5->FQ5_HORENC))
			FQ5->(MSUNLOCK())
		ENDIF
	CASE ! EMPTY(FQ5->FQ5_DATFEC)
		IF MSGYESNO(STR0285 , STR0022) //"Confirma o estorno do fechamento da AS?"###"Atenção!"
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_DATFEC := CTOD("//")
			FQ5->FQ5_HORFEC := SPACE(LEN(FQ5->FQ5_HORENC))
			FQ5->(MSUNLOCK())
		ENDIF
	OTHERWISE
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0032}) //"AS encontra-se aberta."
	ENDCASE

	CFILANT := CFILOLD

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05906
ITUP BUSINESS - TOTVS RENTAL
Estorno da AS
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05906(LRET)
Local _AAREAOLD  := GETAREA()
Local _AAREAZA0  := FP0->(GETAREA())
Local _AAREAZAG  := FPA->(GETAREA())
Local _AAREAZBX  := FPF->(GETAREA())
Local _AAREAZLG  := FPO->(GETAREA())
Local CRET       := ""
Local CFILOLD    := CFILANT
Local _cQuery    := ""
Local lMvGSxRent := SuperGetMv("MV_GSXRENT",.F.,.F.)
Local aBindParam := {} // Parametros das Querys
Local _MV_LOC207 := SUPERGETMV("MV_LOCX207",,.F.)
Local  CGRPAND	 := SUPERGETMV("MV_LOCX014",.F.,"" )

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ELSE
		CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	CFILANT := FQ5->FQ5_FILORI

	IF FQ5->FQ5_STATUS == "6"
		FP0->(DBSETORDER(1))
		FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))

		DO CASE
		CASE FP0->FP0_TIPOSE == "L"
			FPA->(DBSETORDER(3))
			IF FPA->(MSSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) //"FPA"

				IF EMPTY(FPA->FPA_GRUA) .or. !Empty(POSICIONE("ST9",1, xFilial("ST9")+FPA->FPA_GRUA, "T9_STATUS"))

					IF ! EMPTY(FPA->FPA_NFREM) // Teve remessa para essa AS
						CRET := STR0034+ ALLTRIM(FQ5->FQ5_AS)+STR0035 //"Não será possível estonar o aceite da(S) AS(S): "###" Já existe NF de remessa atrelada a este(S) item(S)."
					Else
						dbSelectArea("FQ3")
						FQ3->(dbSetOrder(3))
						if FQ3->(dbSeek(xFilial("FQ3")+FQ5->FQ5_AS)) // A AS está em romaneio
							CRET := STR0034+ ALLTRIM(FQ5->FQ5_AS)+STR0296 //"Não será possível estonar o aceite da(S) AS(S): " //" já existe romaneio atrelado a este(s) item(s)."
						endif
					endif

					if  lRet .and. _MV_LOC207 .and. Empty(CRET) // Automatico  Deve gerar AS Aceita e está apta o Estorno do Aceite
						CRET := STR0034+ ALLTRIM(FQ5->FQ5_AS)+STR0297 //" Aceite automático ligado não pode haver estorno de Aceite."
					endif

				endif

			Else
				dbSelectArea("FQ3")
				FQ3->(dbSetOrder(2))
				if FQ3->(dbSeek(xFilial("FQ3")+FQ5->FQ5_AS)) // A AS está em romaneio
					CRET := STR0034+ ALLTRIM(FQ5->FQ5_AS)+STR0296 //"Não será possível estonar o aceite da(S) AS(S): " //" já existe romaneio atrelado a este(s) item(s)."
				endif

			endif
		ENDCASE

		// DSERLOCA-1982 - Frank em 09/05/2024
		// Valida se existe OS gerada
		If lImplemento
			If !LOCA05911()
				Return .F.
			EndIF
		EndIF
		// DSERLOCA-3515 - Rossana em 10/07/2024
		// Valida se existe Minuta diferente de 1
		If !LOCA05934()
			Return .F.
		EndIF
		// Jose Eulalio - 16/01/2023 - SIGALOC94-619 - Integaão com GS, Gestão de Serviços
		// Integação com GS, Gestão de Serviços
		If lMvGSxRent
			If !LOCA084(.T.)
				CRET := STR0036+ ALLTRIM(FQ5->FQ5_AS) + STR0298 //"Não será possível estornar o aceite da(S) AS(S): "###" STR0298 //"A Base de Atendimento (AAS) não pode ser excluída."
			EndIf
		EndIf
		IF EMPTY(CRET) .and. FPA->FPA_TIPOSE <> "Z"
			FPF->(DBSETORDER(4))							// FPF_FILIAL + FPF_AS + FPF_MINUTA
			IF FPF->( MSSEEK( XFILIAL("FPF") + FQ5->FQ5_AS ) )
				WHILE FPF->(!EOF()) .AND. FPF->(FPF_FILIAL + FPF_AS) == (XFILIAL("FPF") + FQ5->FQ5_AS)
					IF FPF->FPF_STATUS $ "1#5"				// PREVISTA / CANCELADA
						IF FPF->(RECLOCK("FPF",.F.))
							FPF->(DBDELETE())
							FPF->(MSUNLOCK())
						ENDIF
					ENDIF
					FPF->(DBSKIP())
				ENDDO
			ENDIF

			aBindParam := {}
			_CQUERY := " SELECT   ZLO.R_E_C_N_O_ ZLORECNO"
			_CQUERY += " FROM " + RETSQLNAME("FPQ") + " ZLO"
			_CQUERY += " WHERE    FPQ_AS         = ? "
			Aadd( aBindParam, FQ5->FQ5_AS )
			_CQUERY += "   AND    FPQ_AGENDA     = '1'"
			_CQUERY += "   AND    ZLO.D_E_L_E_T_ = ''"
			_CQUERY += " ORDER BY FPQ_AS , FPQ_DATA DESC"
			IF SELECT("TRBFPQ") > 0
				TRBFPQ->(DBCLOSEAREA())
			ENDIF

			_CQUERY := CHANGEQUERY(_CQUERY)

			MPSysOpenQuery(_CQUERY,"TRBFPQ",,,aBindParam)

			WHILE TRBFPQ->(!EOF())
				DBSELECTAREA("FPQ")
				FPQ->(DBGOTO(TRBFPQ->FPQRECNO))
				IF FPQ->(RECLOCK("FPQ",.F.))
					FPQ->(DBDELETE())
					FPQ->(MSUNLOCK())
				ENDIF
				TRBFPQ->(DBSKIP())
			ENDDO

			TRBFPQ->(DBCLOSEAREA())

			IF RECLOCK("FQ5",.F.)
				FQ5->FQ5_STATUS := "1"
				FQ5->FQ5_ACEITE := CTOD("")
				FQ5->(MSUNLOCK())
			ENDIF
			CPARA := GETMV("MV_LOCX180",,"")

			CTITULO	:= "Estorno de AS"
			CBODY   := " AS " + AllTrim(FQ5->FQ5_AS) + " <BR><BR> Data estorno " + Dtoc(dDataBase)
			IF !EMPTY(ALLTRIM(CPARA))
				// Rossana - 10/12 - Envia email estorno AS
				LOCX059A( , CPARA , , CTITULO, CBODY , NIL, , )  
			ENDIF

			IF  EXISTBLOCK("LC59EST")
				EXECBLOCK("LC59EST" ,.T.,.T.,{})
			ENDIF
		ENDIF
	ENDIF

	CFILANT := CFILOLD

	FPO->(RESTAREA( _AAREAZLG ))
	FPF->(RESTAREA( _AAREAZBX ))
	FPA->(RESTAREA( _AAREAZAG ))
	FP0->(RESTAREA( _AAREAZA0 ))
	RESTAREA( _AAREAOLD )

RETURN IIF( LRET , CRET , "" )

/*/{PROTHEUS.DOC} LOCA05907
ITUP BUSINESS - TOTVS RENTAL
Rejeita AS
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05907(XMSG)
LOCAL LOK      := .F.
LOCAL CMSG     := ""
LOCAL CPARA	   := ""
LOCAL CTITULO  := ""
LOCAL OMSG
LOCAL ABUTTONS := {}
LOCAL CBODY    := ""
LOCAL _LREJ    := .T.
LOCAL CFILOLD  := CFILANT
Local _LC111VRJ := EXISTBLOCK("LC111VRJ")
Local _LC111REJ := EXISTBLOCK("LC111REJ")

PRIVATE _ODLGMAIL
Private _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	CFILANT := FQ5->FQ5_FILORI

	IF _LC111VRJ //EXISTBLOCK("LC111VRJ") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO/INCLUSÃO DE CONDIÇÕES DA QUERY PARA GERAÇÃO DA NOTA FISCAL DE REMESSA.
		_LREJ := EXECBLOCK("LC111VRJ",.T.,.T.,NIL)
		IF !_LREJ
			CFILANT := CFILOLD
			RETURN NIL
		ENDIF
	ELSE
		IF FQ5->FQ5_STATUS == "6" 	// VALIDAÇÃO PARA NÃO PERMITIR QUE A AS SEJA REJEITADA DEPOIS DO ACEITE.
			Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0040}) //"AS encontra-se aceita e não poderá ser rejeitada."
			CFILANT := CFILOLD
			RETURN NIL
		ENDIF
		IF FQ5->FQ5_STATUS == "9" 	// VALIDAÇÃO PARA NÃO PERMITIR QUE A AS SEJA REJEITADA DEPOIS DO ACEITE.
			Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0041}) //"AS já encontra-se rejeitada."
			CFILANT := CFILOLD
			RETURN NIL
		ENDIF
	ENDIF

	FP0->( DBSETORDER(1))
	FP0->( DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT) )

	CMSG  := FQ5->FQ5_OBSCOM + CRLF

	IF EMPTY(XMSG)
		DEFINE MSDIALOG _ODLGMAIL TITLE STR0049   FROM C(230),C(359) TO C(400),C(882) PIXEL		// DE 610 PARA 400 //"Motivo da rejeição"
			@ C(014),C(011) SAY STR0050   			SIZE C(030),C(008) COLOR CLR_BLACK PIXEL OF _ODLGMAIL //"Motivo:"
			@ C(015),C(042) GET OMSG VAR CMSG MEMO 		SIZE C(210),C(065) 				   PIXEL OF _ODLGMAIL
		ACTIVATE MSDIALOG _ODLGMAIL CENTERED ON INIT ENCHOICEBAR(_ODLGMAIL, {||LOK:=.T., _ODLGMAIL:END()},{||_ODLGMAIL:END()},,ABUTTONS)
	ELSE
		CMSG := XMSG										// --> VEM MENSAGEM COMO PARÂMETRO DA ROTINA DE REJEIÇÃO POR LOTE
		LOK  := .T.
	ENDIF

	IF LOK
		CPARA := GETMV("MV_LOCX178",,"")
		CTITULO	:= "Rejeição de AS"
		CBODY   := "AS " + AllTrim(FQ5->FQ5_AS) + "<BR><BR> Data " + Dtoc(dDataBase) + "<BR><BR> " + CMSG

		IF !EMPTY(ALLTRIM(CPARA))
			// Rossana - 05/12 - Envia email rejeição AS
			LOCX059A( , CPARA , , CTITULO, CBODY , NIL, , )  
		ENDIF
		IF RECLOCK("FQ5",.F.)
			FQ5->FQ5_STATUS := "9"
			FQ5->FQ5_ACEITE := CTOD("")
			FQ5->FQ5_OBSCOM := "==> " + CTITULO + CRLF + CMSG
			FQ5->(MSUNLOCK())
		ENDIF
		IF _LC111REJ //EXISTBLOCK("LC111REJ") 											// --> PONTO DE ENTRADA EXECUTADO APÓS A REJEIÇÃO DA AS.
			EXECBLOCK("LC111REJ",.T.,.T.,{FQ5->FQ5_FILIAL, FQ5->FQ5_FILORI, FQ5->FQ5_SOT, FQ5->FQ5_OBRA, FQ5->FQ5_AS})
		ENDIF
	ENDIF

	CFILANT := CFILOLD

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05908
ITUP BUSINESS - TOTVS RENTAL
Realiza o aceite da AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05908(CLOTE , LMSROTAUTO, _lAviso)
	PROCESSA({|| LOCA05908X(CLOTE , LMSROTAUTO, _lAviso) } , STR0327 , STR0235 , .T.) // Registrando o aceite da AS###Aguarde
Return

/*/{PROTHEUS.DOC} LOCA05908X
ITUP BUSINESS - TOTVS RENTAL
Processamento do aceite da AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025 - Revitalizado
/*/
FUNCTION LOCA05908X(CLOTE , LMSROTAUTO, _lAviso)
Local OFONT      := TFONT():NEW("ARIAL",11,,.T.,.T.,5,.T.,5,.T.,.F.)
Local LOK 		 := .F.
Local CCC	 	 := SPACE(100)
Local CMSG	 	 := ""
Local CPARA	 	 := SPACE(100)
Local CTITULO	 := SPACE(100)
Local EFROM		 := ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
Local LCONFLITO  := .F.
Local COBRA      := ""
Local _CQUERY	 := "" //ifranzoi - 26/06/2021 - MIT1A
Local CFILOLD    := CFILANT
Local _LMAIL
Local LGRVPERZLG
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"
Local _LC111AC1 := EXISTBLOCK("LC111AC1")
Local _LC111ANT := EXISTBLOCK("LC111ANT")
Local _LC111ACE := EXISTBLOCK("LC111ACE")
Local CGRPAND	:= SUPERGETMV("MV_LOCX014",.F.,"" )
Local _LRET 	:= .T.
Local lLOCA59A  := EXISTBLOCK("LOCA59A")
Local lLOCA59B  := EXISTBLOCK("LOCA59B")
Local lLOCA59C  := EXISTBLOCK("LOCA59C")
Local lLOCA59D  := EXISTBLOCK("LOCA59D")
Local lLOCA59Z  := EXISTBLOCK("LOCA59Z")
Local lForca    := .F.
Local lLOCA59x1 := EXISTBLOCK("LOCA59X1")
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)
Local aBindParam := {}
Local lMao := .F.

Private _ODLG
Private LACESS   := .F.
Private _ASS     := {}
Private LANTACE  := .T.

DEFAULT LMSROTAUTO := .F.
DEFAULT _lAviso    := .T.

	ProcRegua(0)
	IncProc()
	SysRefresh()

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If FQ5->FQ5_TPAS == "L" .and. !LOCA059DE()
		Return
	elseif FQ5->FQ5_TPAS == "F" .and. !LOCA059AROM()
		return
	EndIf

	_lMens := _lAviso

	IF ! (VALTYPE("LROMANEIO") == "L")
		LROMANEIO := SUPERGETMV("MV_LOCX071" , .F. , .T.)
	ENDIF

	CFILANT    := FQ5->FQ5_FILORI
	_LMAIL     := SUPERGETMV("MV_LOCX018" ,.F.,.T.)
	LGRVPERZLG := SUPERGETMV("MV_LOCX240",.F.,.T.)

	//caso exista o campo BM_XACESS, utiliza ele como referência
	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ENDIF

	//valida se existe produto que pode gerar sem Equipamento
	If FQ5->FQ5_TPAS == "L" .And. Empty(FQ5->FQ5_GUINDA)
		//Posiciona na FPA
		FPA->(DBSETORDER(3))				// FPA_FILIAL + FPA_AS + FPA_VIAGEM
		If FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS)
			//Posiciona no produto
			SB1->(DBSETORDER(1))
			If SB1->(DBSEEK(XFILIAL("SB1") + FPA->FPA_PRODUT))
				//verifica se o grupo de produto está liberado
				If FPA->FPA_TIPOSE <> "M"
					_LRET := ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1") + FPA->FPA_PRODUT,1,"")) $ ALLTRIM(CGRPAND)
				EndIf
			EndIf
		EndIf
		//retorno do erro
		If lLOCA59A
			_LRET := EXECBLOCK("LOCA59A",.T.,.T.,{})
		EndIf
		If !_LRET
			//Ferramenta Migrador de Contratos
			lForca := .F.
			If lLOCA59B
				lForca := EXECBLOCK("LOCA59B",.T.,.T.,{})
			EndIf
			If (Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C") .or. lForca
				cLocErro := STR0265 + CRLF //"É necessário indicar um Equipamento ou Produto válido para prosseguir com o Aceite de AS."
			Else
				MSGSTOP(STR0265 , STR0022) //"É necessário indicar um Equipamento ou Produto válido para prosseguir com o Aceite de AS."###"Atenção!"
			EndIf
			//RETIRAR ESSE RETURN (TROCAR POR LCONTINUA)
			RETURN _LRET
		EndIf
	EndIf
	DBSELECTAREA("FQ5")

	IncProc()
	SysRefresh()

	IF _LC111AC1 //EXISTBLOCK("LC111AC1") 												// --> PONTO DE ENTRADA PARA VALIDAR AS LINHAS DA ABA LOCAÇÕES ANTES DE SALVAR.
		_LRET := .T.
		_LRET := EXECBLOCK("LC111AC1",.T.,.T.,{FQ5->FQ5_GUINDA, FQ5->FQ5_AS, FQ5->FQ5_VIAGEM, CLOTE })
		IF !_LRET
			CFILANT := CFILOLD
			RETURN _LRET
		ENDIF
	ENDIF

	IF FQ5->FQ5_STATUS != "1" .OR. ! EMPTY(FQ5->FQ5_DATENC)
		If _lMens
			//Ferramenta Migrador de Contratos
			If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := STR0052+CRLF // "Somente uma AS aberta pode ser aceita"
			Else
				MSGSTOP(STR0052 , STR0022) //"Somente uma AS aberta pode ser aceita!"###"Atenção!"
			EndIf
		EndIF
		CFILANT := CFILOLD
		RETURN .F.
	ENDIF

	FP0->(DBSETORDER(1))
	FP0->(DBSEEK(FQ5->FQ5_FILORI + FQ5->FQ5_SOT))

	// 01/11/2022 - Jose Eulalio - SIGALOC94-543 - Apontador de AS não aceita tipo de locação = cobrança única
	If !Empty(FQ5->FQ5_GUINDA)
		lMinuta := IsEqMinuta(FQ5->FQ5_GUINDA)
	Else
		lMinuta := .F. //IsEqMinuta(FQ5->FQ5_GUINDA)
	EndIf

	/* ISSUE 7918 - possibilitar a geração de minuta para mão de obra - 26/08/25 - Frank
	IF LMINUTA
		FPA->(DBSETORDER(3))				// FPA_FILIAL + FPA_AS + FPA_VIAGEM
		IF FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS)
			IF FPA->FPA_TIPOSE == "M" //ifranzoi - 30/06/2021 - se for Mão de obra não gera minuta
				LMINUTA := .F. 
			ENDIF
		ENDIF
	ENDIF*/
	If !empty(FQ5->FQ5_AS) .and. FPA->FPA_TIPOSE == "M" // 26/08/25 ISSUE 7918 - Frank
		lMinuta := .T.
		lMao := .T.
	EndIF

	IncProc()
	SysRefresh()

	// Frank em 14/10/22
	If lMinuta
		If FQ5->FQ5_TPAS == "F"
			lMinuta := .F.
		EndIf
	EndIF

	// Frank em 15/01/25 - DSERLOCA-5001
	If lMinuta .and. !empty(FQ5->FQ5_AS) .and. !lMao // 26/08/25 ISSUE 7918 - Frank
		// Validar o bloqueio por conflito
		If !LOCA059W(FQ5->FQ5_AS)
			Return .F.
		EndIF
	EndIf

	IncProc()
	SysRefresh()

	//ifranzoi - 26/06/2021 - MIT1A
	If LMINUTA .AND. !EMPTY(FQ5->FQ5_AS) .and. !lMao // 26/08/25 ISSUE 7918 - Frank
		If ( CSERV != "F" )

			// Ajuste feito por Frank em 19/10/23 sobre a validacao das data e horarios
			//Caso a minuta esteja ativada, verifica encavalamento do equipamento
			aBindParam := {}
			_CQUERY := " SELECT COUNT(FPF_FROTA) TOT FROM "+RETSQLNAME("FPF")+" " // Retirado AS para Oracle - DSER
			_CQUERY += " WHERE FPF_FILIAL = ? AND "
			Aadd(aBindParam, FwxFilial("FPF") ) //
			_CQUERY += " FPF_DATA BETWEEN ? AND ? AND "
			Aadd(aBindParam, Dtos(FQ5->FQ5_DATINI) )
			Aadd(aBindParam, Dtos(FQ5->FQ5_DATFIM) )
			_cQuery += " FPF_HORAI <= ? AND FPF_HORAF >= ? "
			Aadd(aBindParam, FQ5->FQ5_HORFIM )
			Aadd(aBindParam, FQ5->FQ5_HORINI )
			_cQuery += " AND "

			nForca := 0
			If lLOCA59X1
				nForca := EXECBLOCK("LOCA59X1",.T.,.T.,{})
			EndIf

			If !EMPTY(FQ5->FQ5_GUINDA) .or. nForca == 2
				_CQUERY += " FPF_FROTA = ? AND "
				Aadd(aBindParam, FQ5->FQ5_GUINDA )
			EndIf

			_CQUERY += " FPF_AS <> ? AND D_E_L_E_T_ = ' ' "
			Aadd(aBindParam, FQ5->FQ5_AS )

			IF SELECT("TRBVLD") > 0
				TRBVLD->(DBCLOSEAREA())
			ENDIF

			_CQUERY := CHANGEQUERY(_CQUERY)

			MPSysOpenQuery(_CQUERY,"TRBVLD",,,aBindParam)

			IF TRBVLD->(!EOF()) .or. nForca == 3
				If TRBVLD->TOT > 0 .or. nForca == 3
					Help(Nil,	Nil,STR0023+" "+Alltrim(Upper(Procname())),; // Rental
					Nil,STR0266,1,0,Nil,Nil,Nil,Nil,Nil,; // Conflito de equipamentos
					{STR0267 + ALLTRIM(POSICIONE("ST9",1,FwxFilial("ST9")+FQ5->FQ5_GUINDA,"T9_CODBEM")) +; // o equipamento:
						" - " + ALLTRIM(POSICIONE("ST9",1,FwxFilial("ST9")+FQ5->FQ5_GUINDA,"T9_NOME")) + STR0268}) // já encontra-se na minuta

					Return .F.
				EndIf
			ENDIF
			TRBVLD->(DBCLOSEAREA())
		EndIf
	EndIf

	IncProc()
	SysRefresh()

	If lMinuta
		FACEMINUTA(CLOTE, lMao) // 26/08/25 ISSUE 7918 - Frank
		CFILANT := CFILOLD
		RETURN NIL
	ENDIF

	CPROJET := FQ5->FQ5_SOT
	COBRA   := FQ5->FQ5_OBRA

	IncProc()
	SysRefresh()

	CMSG  := FP0->FP0_OBS + CHR(13)+CHR(10)
	_CFIL := XFILIAL() 		// RIGHT(ALLTRIM(FQ5->FQ5_AS),2)
	CCC   := ""
	CPARA := ""

	IncProc()

	DO CASE
	CASE FP0->FP0_TIPOSE == "L"
		_CTIPOAS := "ASG"
		CPARA    := GETMV("MV_LOCX178",,"")
	ENDCASE

	IF FQ5->FQ5_TPAS == "F"
		_CTIPOAS := "ASF"
		CPARA := GETMV("MV_LOCX033",,"")
	Else
		_CTIPOAS := "AS "
		CPARA := GETMV("MV_LOCX033",,"")
	ENDIF

	IF FQ5->FQ5_TPAS == "F" .AND. (EMPTY(FQ5->FQ5_DTINI) .OR. EMPTY(FQ5->FQ5_DTFIM))
		LCONFLITO := .T.
		XMSG      := STR0073 //"A AS deve ser programada!"
	ENDIF

	IF EMPTY(CLOTE) .and. _lMens .and. !IsInCallStack("LOCA01302")
		DEFINE MSDIALOG _ODLG     TITLE STR0074+_CTIPOAS  FROM C(230),C(359) TO C(400),C(882) PIXEL		// DE 610 PARA 400 //"Aceite de "
			@ C(017),C(010) SAY STR0075+_CTIPOAS+" Nº: "+FQ5->FQ5_AS FONT OFONT COLOR CLR_BLACK PIXEL OF _ODLG //"Confirma o aceite da "
			@ C(025),C(010) SAY _MV_LOC248 + STR0076+ALLTRIM(FQ5->FQ5_SOT) + STR0077 + FP0->FP0_REVISA + " ?" FONT OFONT COLOR CLR_BLACK PIXEL OF _ODLG //"PROJETO"###" Nº: "###" Rev.: "
			IF LCONFLITO
				@ C(040),C(010) SAY XMSG FONT OFONT COLOR CLR_RED PIXEL OF _ODLG
			ENDIF
		ACTIVATE MSDIALOG _ODLG CENTERED ON INIT ENCHOICEBAR(_ODLG, {|| LOK := .T. , _ODLG:END()} , {||_ODLG:END() } )
	ELSE
		LOK := .T.
	ENDIF

	IF LCONFLITO
		Help(	Nil,	Nil, "LOCA05908_01" ,; //"RENTAL: "
				Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
				{STR0142}) //"Existem ASF sem programação."
		CFILANT := CFILOLD
		RETURN .F.
	ENDIF

	IncProc()
	SysRefresh()

	IF LOK

		IncProc()

		IF FQ5->FQ5_TPAS == "F"
			DDTINI  := FQ5->FQ5_DTINI
			DDTFIM  := FQ5->FQ5_DTFIM
			CHRINI  := SUBSTR(FQ5->FQ5_HRINI,1,2) + SUBSTR(FQ5->FQ5_HRINI,3,4)
			CHRFIM  := SUBSTR(FQ5->FQ5_HRFIM,1,2) + SUBSTR(FQ5->FQ5_HRFIM,3,4)
			CTPAMA  := FQ5->FQ5_TIPAMA
			CPACLIS := FQ5->FQ5_PACLIS
			CTITULO := STR0083 + _CTIPOAS + STR0043 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0045 + FP0->FP0_REVISA + SPACE(100) //"Referente a aceite da "###" Número "###"PROJETO"###", Revisão "
			EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"

			CMSG	:= CTITULO + "<BR><BR>"
			CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR>" //"Data INI/FIM: "###", Obra: "###", Cliente: "
			CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
			CMSG	+= "<TABLE><TR><TH>"+STR0087+"</TH><TD>"+DTOC(DDTINI)+"</TD></TR>" //"<TABLE><TR><TH>Data carregamento:</TH><TD>"
			CMSG	+= "<TR><TH>"+STR0088+"</TH><TD>"+SUBSTR(CHRINI,1,2)+":"+SUBSTR(CHRINI,3,2)     +"</TD></TR>" //"<TR><TH>Hora carregamento:       </TH><TD>"
			CMSG	+= "<TR><TH>"+STR0089+"</TH><TD>"+DTOC(DDTFIM)+"</TD></TR>" //"<TR><TH>Data descarregamento:    </TH><TD>"
			CMSG	+= "<TR><TH>"+STR0090+"</TH><TD>"+SUBSTR(CHRFIM,1,2)+":"+SUBSTR(CHRFIM,3,2)     +"</TD></TR>" //"<TR><TH>Hora descarregamento:    </TH><TD>"
			CMSG	+= "<TR><TH>"+STR0091+"</TH><TD>"+CTPAMA      +"</TD></TR>" //"<TR><TH>Tipo amarração:          </TH><TD>"
			CMSG	+= "<TR><TH>"+STR0092+"</TH><TD>"+CPACLIS  +"</TD></TR></TABLE>" //"<TR><TH>Nº da carreta:           </TH><TD>"

			IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
			ENDIF

			IF LANTACE
				RECLOCK("FQ5",.F.)
				FQ5->FQ5_STATUS := "6" 					// APROVADO !
				FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
				FQ5->(MSUNLOCK())

				// DSERLOCA-1982 - Frank em 08/05/2024
				If lImplemento
					Loca059A()
				EndIF
				IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
					EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG , CLOTE})
				ENDIF

				IF LROMANEIO  .AND.  ALLTRIM(FQ5->FQ5_TPAS) == "F"
					GERROMAN()
				ENDIF
			ENDIF

		ENDIF

		IncProc()
		SysRefresh()

		IF FQ5->FQ5_TPAS $ "L" 						// SE FOR GUINDASTE OU GRUA
			LAVALIA := .F. 								// DISPARA AVALIACAO DAS PROGRAMACOES

			DBSELECTAREA("FPA")
			DBSETORDER(3)
			DBSEEK(XFILIAL("FPA")+ FQ5->FQ5_AS +FQ5->FQ5_VIAGEM)
			LAVALIA := ! EMPTY(FPA->FPA_VIAGEM) 	// ATIVA AVALIACAO SE VIAGEM NAO VAZIA

		ENDIF								// FIM CRIAÇÃO DE PROGRAMAÇÃO DE GUINDASTES E GRUAS

		// --> CRIANDO REGISTROS PARA MEDIÇÃO
		// --> QUANTIDADES DE ITENS PARA O REGISTRO DE MEDIÇÃO
		IF FP4->FP4_TIPOCA == "F" 			// GERAR SOMENTE UMA MEDIÇÃO CASO A LOCAÇÃO SEJA FECHADA.
			_NITENS := 1
		ELSEIF !EMPTY(FQ5->FQ5_DATFIM) .AND. !EMPTY(FQ5->FQ5_DATINI) .AND. FQ5->FQ5_DATINI <= FQ5->FQ5_DATFIM
			_NITENS := IIF(FQ5->FQ5_DATFIM - FQ5->FQ5_DATINI==0, 1,(FQ5->FQ5_DATFIM - FQ5->FQ5_DATINI)+1)
		ELSE
			CFILANT := CFILOLD
			//Ferramenta Migrador de Contratos
			If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := STR0253+CRLF //"Erro nos campos de Data Inicial e Data Final"
			EndIf
			RETURN NIL
		ENDIF

		DBSELECTAREA("FPO")
		FPO->(DBSETORDER(4))
		FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM))

		_DMOBREA := CTOD("//")
		_DDESREA := CTOD("//")

		// PROJETO
		DBSELECTAREA("FP0")
		FP0->(DBSETORDER(1))
		FP0->(DBSEEK(XFILIAL("FP0") + FQ5->FQ5_SOT))
		_CNUMPED := FP0->FP0_NUMPED
		_CFILPED := FP0->FP0_FILPED
		_CCODCLI := FP0->FP0_CLI
		_CLOJCLI := FP0->FP0_LOJA

		IncProc()
		SysRefresh()

		IF FP0->FP0_TIPOSE == "L"
			DBSELECTAREA("FPA")
			FPA->(DBSETORDER(2))
			FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS + FQ5->FQ5_VIAGEM))
			IF FPA->FPA_TPMEDI == "Q"
				_DMEDPRE := FPA->FPA_DTINI + 15
			ELSEIF FPA->FPA_TPMEDI == "M"
				_DMEDPRE := FPA->FPA_DTINI + 30
			ELSEIF FPA->FPA_TPMEDI == "S"
				_DMEDPRE := FPA->FPA_DTINI + 7
			ELSEIF FPA->FPA_TPMEDI == "E"
				_DMEDPRE := FPA->FPA_DTINI
			ELSE
				_DMEDPRE := FPA->FPA_DTINI
			ENDIF
			_CFROTA := FPA->FPA_GRUA
			_CDESEQ := POSICIONE("ST9", 1, XFILIAL("ST9") + _CFROTA, "T9_NOME")
			_CHRINI := SUBSTR(FPA->FPA_HRINI,1,2)  + SUBSTR(FPA->FPA_HRINI,3,4)
			_CHRFIM := SUBSTR(FPA->FPA_HRFIM,1,2)  + SUBSTR(FPA->FPA_HRFIM,3,4)
			_NHRTOT := FPA->FPA_PREDIA 				// FPA->FPA_MINDIA
			_CBASE  := FPA->FPA_TIPOCA
			_NVRHOR := FPA->FPA_VRHOR
			_NVTOTH := FPA->FPA_VRHOR * _NHRTOT 	// FPA->FPA_MINDIA
			_NVRMOB := FPA->FPA_VRMOB
			_NVRDES := FPA->FPA_VRDES
			_CTPSEG := FPA->FPA_TPSEGU
			_NPERSG := FPA->FPA_PERSEG
			_NVBASS := FPA->FPA_VRCARG
			_NVRSEG := FPA->FPA_VRSEGU
			_CTPISS := FPA->FPA_TPISS
			_NPRISS := FPA->FPA_PERISS
			_NVRISS := FPA->FPA_VRISS
			_NTNSPS := FPA->FPA_VRPESO
			_NANCOR := FPA->FPA_ANCORA
			_NTELES := FPA->FPA_TELESC
			_MONTAG := FPA->FPA_MONTAG
			_DESMON := FPA->FPA_DESMON
			_CCDANT := FPA->FPA_CODLCR
			_NTOTKM := 0
			IF _CTPSEG $ "I;C"
				IF _CBASE == "K"
					_NVRTOM := (_NTOTKM * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
				ELSE
					_NVRTOM := (      0 * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS
				ENDIF
			ELSE
				IF _CBASE == "K"
					_NVRTOM := (_NTOTKM * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
				ELSE
					_NVRTOM := (      0 * _NVRHOR ) + _NVRMOB + _NVRDES + _NANCOR + _NTELES + _MONTAG + _DESMON + _NTNSPS + _NVRSEG
				ENDIF
			ENDIF
			_CORIVN := FPA->FPA_FILIAL
			_CFIMAQ := FPA->FPA_FLMAQ
			_CFIMOR := FPA->FPA_FLMO
			_NPOVEN := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PCOML")
			_NPRMAQ := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PBEM")
			_NPRMAO := 0 //POSICIONE("ZLK", 1, XFILIAL("ZLK") + FPA->FPA_RATEIO, "ZLK_PMO")
			_NPORMA := FPA->FPA_PERMAO
			_NVRORV := _NVRTOM * _NPOVEN / 100
			_NVRMAQ := _NVRTOM * _NPRMAQ / 100
			_NVRMAO := _NVRTOM * _NPRMAO / 100

		ENDIF

		IncProc()
		SysRefresh()

		IF LACESS
			CTITULO := STR0083 + _CTIPOAS + STR0043 + FQ5->FQ5_AS + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0045 + FP0->FP0_REVISA + SPACE(100) //"Referente a aceite da "###" Número "###", Revisão "
			CMSG    := STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" //"Data INI/FIM: "###",  Obra: "###",  Cliente: "

			IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
			ENDIF

			IF LANTACE

				RECLOCK("FQ5",.F.)
				FQ5->FQ5_STATUS := "6" 					// APROVADO !
				FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
				FQ5->(MSUNLOCK())

				IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
					EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG})
				ENDIF

				IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
					GERROMAN()
				ENDIF

				// [inicio] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
				If FQ5->(FIELDPOS("FQ5_NSC")) > 0
					If !Empty(FQ5->FQ5_NSC)
						//verifica se já gerou pedido de compras
						SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
						If SC1->(DbSeek(xFilial("SC1") + FQ5->FQ5_NSC))
							If Empty(SC1->C1_PEDIDO)
								If MsgYesNo("Deseja Excluir a Solicitação de Compras " + AllTrim(FQ5->FQ5_NSC), STR0022) // "Deseja Excluir a Solicitação de Compras " + NNNN ### Atenção!
									LOCA05930()
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				// [fim] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
			ENDIF
		ENDIF

		lForca := .F.
		If lLOCA59Z
			lForca := EXECBLOCK("LOCA59Z",.T.,.T.,{})
		EndIf

		IncProc()
		SysRefresh()

		IF (FQ5->FQ5_TPAS == "L" .AND. (FQ5->FQ5_STATUS != "6" .AND. FQ5->FQ5_ACEITE != DDATABASE)) .or. lForca 		// LOCAÇÃO DE PLATAFORMA
			IF _LC111ANT //EXISTBLOCK("LC111ANT") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
			ENDIF
			IF LANTACE
				// Jose Eulalio - 16/01/2023 - SIGALOC94-619 - Integaão com GS, Gestão de Serviços
				// Integaão com GS, Gestão de Serviços
				If lMvGSxRent
					If !LOCA084()
						Return .F.
					EndIf
				EndIf
				RECLOCK("FQ5",.F.)
				FQ5->FQ5_STATUS := "6" 					// APROVADO !
				FQ5->FQ5_ACEITE := DDATABASE 			// DATA APROVAÇÃO
				FQ5->(MSUNLOCK())

				CPARA := GETMV("MV_LOCX032",,"")

				CTITULO	:= "Aceite de AS"
				CBODY   := "AS " + AllTrim(FQ5->FQ5_AS) + "<BR><BR> Data " + Dtoc(dDataBase)

				IF !EMPTY(ALLTRIM(CPARA))
					// Rossana - 10/12 - Envia email aceite AS
					LOCX059A( , CPARA , , CTITULO, CBODY , NIL, , )  
				ENDIF

				// DSERLOCA-1982 - Frank em 08/05/2024
				If lImplemento
					Loca059A()
				EndIF
				IF _LC111ACE //EXISTBLOCK("LC111ACE") 									// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
					EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , "" , ""})
				ENDIF
				IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
					GERROMAN()
				ENDIF
				// [inicio] José Eulálio - 13/05/2022 -  SIGALOC94-338 - Geração de cancelamento SC via Apontador
				lForca := .F.
				If lLOCA59C
					lForca := EXECBLOCK("LOCA59C",.T.,.T.,{})
				EndIf
				If FQ5->(FIELDPOS("FQ5_NSC")) > 0
					If !Empty(FQ5->FQ5_NSC) .or. lForca
						//verifica se já gerou pedido de compras
						SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
						If SC1->(DbSeek(xFilial("SC1") + FQ5->FQ5_NSC))
							lForca := .F.
							If lLOCA59D
								lForca := EXECBLOCK("LOCA59D",.T.,.T.,{})
							EndIf
							If Empty(SC1->C1_PEDIDO) .or. lForca
								If MsgYesNo("Deseja Excluir a Solicitação de Compras " + AllTrim(FQ5->FQ5_NSC), STR0022) // "Deseja Excluir a Solicitação de Compras " + NNNN ### Atenção!
									LOCA05930()
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			ENDIF

		ENDIF

	ENDIF

	IncProc()
	SysRefresh()

	CFILANT := CFILOLD

RETURN .T.

/*/{PROTHEUS.DOC} LOCA05913
ITUP BUSINESS - TOTVS RENTAL
Programação de ASF
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05913()
LOCAL CFILOLD   := CFILANT

PRIVATE ODLG
PRIVATE LOK     := .F.
PRIVATE DDTINI  := FQ5->FQ5_DTINI
PRIVATE DDTFIM  := FQ5->FQ5_DTFIM
PRIVATE CHRINI  := FQ5->FQ5_HRINI
PRIVATE CHRFIM  := FQ5->FQ5_HRFIM
PRIVATE CTPAMA  := FQ5->FQ5_TIPAMA
PRIVATE CPACLIS := FQ5->FQ5_PACLIS
Private _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059AROM() // Abnadona se a ASF já está em uso na Gestão de Expedição
		Return
	EndIf

	CFILANT := FQ5->FQ5_FILORI

	IF  !EMPTY(FQ5->FQ5_DATFEC) .OR. !EMPTY(FQ5->FQ5_DATENC) .OR. !FQ5->FQ5_STATUS $ "16"
		MSGINFO(STR0109 , STR0022)  //"Operação cancelada. Só é possível realizar a programação do frete, com uma AS aberta."###"Atenção!"
		CFILANT := CFILOLD
		RETURN NIL
	ENDIF

	DEFINE MSDIALOG ODLG  TITLE STR0110         FROM C(230),C(360) TO C(460),C(600)                      PIXEL  //"Programação de frente"
		@ C(030),C(010) SAY   STR0111                                                                      PIXEL OF ODLG  //"Data carregamento:"
		@ C(037),C(010) GET   DDTINI                                                                                    PIXEL OF ODLG
		@ C(030),C(070) SAY   STR0112                                                                      PIXEL OF ODLG  //"Hora carregamento:"
		@ C(037),C(070) GET   CHRINI  PICTURE "@R 99:99"         VALID LOCA05915(CHRINI)                               PIXEL OF ODLG

		@ C(055),C(010) SAY   STR0113                                                                   PIXEL OF ODLG  //"Data descarregamento:"
		@ C(062),C(010) MSGET DDTFIM                                                                                    PIXEL OF ODLG
		@ C(055),C(070) SAY   STR0114                                                                   PIXEL OF ODLG  //"Hora descarregamento:"
		@ C(062),C(070) MSGET CHRFIM  PICTURE "@R 99:99"         VALID LOCA05915(CHRFIM)                               PIXEL OF ODLG

		@ C(080),C(010) SAY   STR0115                                                                         PIXEL OF ODLG  //"Tipo amarração:"
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"ZL"))
			@ C(087),C(010) MSGET CTPAMA  PICTURE "XXXXXX"  F3 "ZL"  VALID EMPTY(CTPAMA) .OR. EXISTCPO("SX5","ZL"+CTPAMA,1) PIXEL OF ODLG
		Else
			@ C(087),C(010) MSGET CTPAMA  PICTURE "XXXXXX"  F3 "QT"  VALID EMPTY(CTPAMA) .OR. EXISTCPO("SX5","QT"+CTPAMA,1) PIXEL OF ODLG
		EndIf

		@ C(080),C(070) SAY   STR0116                                                                          PIXEL OF ODLG  //"Nº da carreta:"
		@ C(087),C(070) MSGET CPACLIS PICTURE "@R 999"           /*VALID LOCA05918()*/  when(.F.)                                     PIXEL OF ODLG
	ACTIVATE MSDIALOG ODLG CENTERED ON INIT ENCHOICEBAR(ODLG, {|| LOK := LOCA05914() }, {|| ODLG:END()} )

	IF LOK
		BEGIN TRANSACTION
			RECLOCK("FQ5",.F.)
			FQ5->FQ5_DTINI	:= DDTINI
			FQ5->FQ5_DTFIM	:= DDTFIM
			FQ5->FQ5_HRINI	:= CHRINI
			FQ5->FQ5_HRFIM	:= CHRFIM
			FQ5->FQ5_TIPAMA	:= CTPAMA
			FQ5->FQ5_PACLIS	:= CPACLIS
			FQ5->FQ5_DTPROG	:= DDATABASE
			FQ5->FQ5_STATUS := "1"
			FQ5->(MSUNLOCK())
		END TRANSACTION

		CPARA	:= SUPERGETMV("MV_LOCX057",.F.,"LOLIVEIRA@ITUP.COM.BR")
		EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
		CTITULO := STR0117 + FQ5->FQ5_AS + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) //"Referente a programação da ASF número "###"PROJETO"

		CMSG	:= CTITULO + "<BR><BR>"
		CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
		CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR>"  //"Data INI/FIM: "###", Obra: "###", Cliente: "
		CMSG	+= STR0087+DTOC(DDTINI)+"</TD></TR>" //"<TABLE><TR><TH>Data carregamento:</TH><TD>"
		CMSG	+= STR0088+SUBSTR(CHRINI,1,2)+":"+SUBSTR(CHRINI,3,2)     +"</TD></TR>" //"<TR><TH>Hora carregamento:       </TH><TD>"
		CMSG	+= STR0089+DTOC(DDTFIM)+"</TD></TR>" //"<TR><TH>Data descarregamento:    </TH><TD>"
		CMSG	+= STR0090+SUBSTR(CHRFIM,1,2)+":"+SUBSTR(CHRFIM,3,2)     +"</TD></TR>" //"<TR><TH>Hora descarregamento:    </TH><TD>"
		CMSG	+= STR0091+CTPAMA      +"</TD></TR>" //"<TR><TH>Tipo amarração:          </TH><TD>"
		CMSG	+= STR0092+CPACLIS     +"</TD></TR>" //"<TR><TH>Nº da carreta:           </TH><TD>"

		CANEXO := ""

	ENDIF

	CFILANT := CFILOLD

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05914
ITUP BUSINESS - TOTVS RENTAL
Validação da Programação de ASF
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05914()
LOCAL LRET := .T.

	IF DDTINI > DDTFIM .OR. (DDTINI == DDTFIM .AND. CHRINI > CHRFIM)
		LRET := .F.
		MSGSTOP(STR0118 , STR0022)  //"Dados incorretos: a data de carregamento não pode ser maior do que a data de descarregamento."###"Atenção!"
	ELSE
		ODLG:END()
	ENDIF

RETURN LRET

/*/{PROTHEUS.DOC} LOCA05915
ITUP BUSINESS - TOTVS RENTAL
Validação dos campos da Programação de ASF
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05915(CPARAM)
LOCAL LRET := .T.

	IF LEFT(CPARAM,2) > "23" .OR. RIGHT(ALLTRIM(CPARAM),2) > "59"
		MSGSTOP(STR0119 , STR0022)  //"Dados incorretos: o horário deve ser entre 00:00 ATÉ 23:59"###"Atenção!"
		LRET := .F.
	ENDIF

RETURN LRET

/*/{PROTHEUS.DOC} LOCA05916
ITUP BUSINESS - TOTVS RENTAL
Tratamento da AS por Lote
@TYPE FUNCTION
@AUTHOR ITUP
/*/
FUNCTION LOCA05916(_CFILTRO)
Local AAREADTQ  := FQ5->(GETAREA())
Local CMSG      := ""
Local NI        := 0
Local _NX       := 0
Local CAVISO    := ""
Local LOK       := .F.
Local LNPROG    := .F.
Local CPARA     := ""
Local _CPRJOLD  := ""
Local _AASLOTE  := {}
Local CTITULO   := ""
Local _CQUERY   := ""
Local cPesq 	:= Space(50)
Local cMvPar01	:= MV_PAR01
Local cMvPar02	:= MV_PAR02
Local cExistPerg:= "SX1->(DbSeek('LOCP05901'))"
Local lExistPerg:= &(cExistPerg)
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"
Local _LC111TIT := EXISTBLOCK("LC111TIT")
Local _LC111USR := EXISTBLOCK("LC111USR")
Local _LC111LFL := EXISTBLOCK("LC111LFL")
Local _LC111LBT := EXISTBLOCK("LC111LBT")
Local aBindParam := {}

Private CACAO   := ""
Private OOK     := LOADBITMAP( GETRESOURCES(), "LBOK" )
Private ONO     := LOADBITMAP( GETRESOURCES(), "LBNO" )
Private ALINHA  := {}
Private _AALX   := {}
Private LTODOS  := .F.
Private OLBX
Private ODLG
Private _NTPACE	:= 0
Private NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
Private aLstBxOri	:= {}

DEFAULT _CFILTRO := "" // FRANK ZWARG FUGA EM 23/09/2020

	// 07/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS
	//Chama a pergunta, caso exista
	If lExistPerg
		PERGUNTE("LOCP05901",.T.)
	ENDIF
	aBindParam := {}
	_CQUERY := " SELECT DTQ.FQ5_AS     , DTQ.FQ5_GUINDA , DTQ.FQ5_VIAGEM , DTQ.FQ5_SOT , "
	_CQUERY += "        DTQ.FQ5_DESTIN , DTQ.FQ5_ORIGEM , DTQ.FQ5_XPROD, DTQ.FQ5_OBRA, DTQ.R_E_C_N_O_ REG "
	_CQUERY += " FROM " + RETSQLNAME("FQ5") + " DTQ "
	_CQUERY += " WHERE  DTQ.FQ5_FILIAL =  '" + XFILIAL("FQ5") + "'"
	_CQUERY +=   " AND  DTQ.FQ5_FILORI =  ? "
	aadd( aBindParam, CFILANT )
	_CQUERY +=   " AND  DTQ.FQ5_DATFEC =  '' "
	_CQUERY +=   " AND  DTQ.FQ5_DATENC =  '' "
	_CQUERY +=   " AND  DTQ.FQ5_STATUS =  '1'"
	_CQUERY +=   " AND  DTQ.FQ5_TPAS   = ? "
	aadd( aBindParam, CSERV)
	// 07/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS
	//Se não existir, faz da forma antiga
	If !lExistPerg
		_CQUERY +=   " AND  DTQ.FQ5_DATINI >= ? "
		aadd( aBindParam, DTOS(MV_PAR01) )
		_CQUERY +=   " AND  DTQ.FQ5_DATFIM <= ? "
		aadd( aBindParam, DTOS(MV_PAR02) )
	Else
		_CQUERY +=   " AND  DTQ.FQ5_DATINI >= ? "
		aadd( aBindParam, DTOS(MV_PAR09) )
		_CQUERY +=   " AND  DTQ.FQ5_DATFIM <= ? "
		aadd( aBindParam,  DTOS(MV_PAR10) )
		_CQUERY +=   " AND  DTQ.FQ5_CODCLI 	BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR01 )
		aadd( aBindParam, MV_PAR03 )
		_CQUERY +=   " AND  DTQ.FQ5_LOJA   	BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR02 )
		aadd( aBindParam, MV_PAR04 )
		_CQUERY +=   " AND  DTQ.FQ5_SOT   	BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR05 )
		aadd( aBindParam, MV_PAR06 )
		_CQUERY +=   " AND  DTQ.FQ5_OBRA   	BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR07 )
		aadd( aBindParam, MV_PAR08 )
		_CQUERY +=   " AND  DTQ.FQ5_XPROD   BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR11 )
		aadd( aBindParam, MV_PAR12 )
		_CQUERY +=   " AND  DTQ.FQ5_GUINDA  BETWEEN ? AND ? "
		aadd( aBindParam, MV_PAR13 )
		aadd( aBindParam, MV_PAR14 )

		//Devolve para como estava originalmente
		MV_PAR01	:= cMvPar01
		MV_PAR02	:= cMvPar02
	EndIf

	_CQUERY +=   " AND  DTQ.D_E_L_E_T_ = ''"
	_CQUERY += " ORDER BY DTQ.FQ5_SOT , DTQ.FQ5_AS , DTQ.FQ5_VIAGEM , DTQ.R_E_C_N_O_ "
	IF SELECT("TRBFQ5") > 0
		TRBFQ5->(DBCLOSEAREA())
	ENDIF

	_CQUERY := CHANGEQUERY(_CQUERY)

	MPSysOpenQuery(_CQUERY,"TRBFQ5",,,aBindParam)

	WHILE TRBFQ5->(!EOF())

			FQ5->(dbGoto(TRBFQ5->REG))
			
			// Controle de acesso por usar uma demanda - Frank em 23/04/2025
			If !LOCA059DE(.F.)
				TRBFQ5->(dbSkip())
				Loop
			EndIf

			AADD(ALINHA, { .F.            	 ,;
						TRBFQ5->FQ5_AS    ,;
						TRBFQ5->FQ5_GUINDA,;
						TRBFQ5->FQ5_VIAGEM,;
						TRBFQ5->FQ5_SOT   ,;
						TRBFQ5->FQ5_DESTIN,;
						TRBFQ5->FQ5_ORIGEM,;
						TRBFQ5->FQ5_XPROD,;  // FRANK - 23/09/2020
						TRBFQ5->FQ5_OBRA,;   // FRANK - 23/09/20
						TRBFQ5->REG         })	// FRANK - 26/10/2020
		TRBFQ5->(DBSKIP())
	ENDDO
	TRBFQ5->(DBCLOSEAREA())

	IF _LC111LFL //EXISTBLOCK("LC111LFL") 												// --> PONTO DE ENTRADA PARA FILTRO DAS AS'S EXIBIDAS PARA ACEITE EM LOTE.
		ALINHA := EXECBLOCK("LC111LFL",.T.,.T.,{ALINHA})
	ENDIF

	IF LEN(ALINHA) > 0
		DEFINE MSDIALOG ODLG FROM  000,000 TO 430,780 TITLE STR0120 PIXEL //"Selecione as AS (Lote)"

			//Texto de pesquisa
			@ 003,002 MsGet oPesqEv Var cPesq Size 342,009 COLOR CLR_BLACK PIXEL OF oDlg

			//05/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS
			//Interface para selecao de indice e filtro
			@ 003,345 Button STR0002    Size 043,012 PIXEL OF oDlg Action IF(!Empty(oLbx:aArray[oLbx:nAt][2]),ITPESQ5916(oLbx,cPesq),Nil) //Pesquisar

			@ 022,5 LISTBOX OLBX FIELDS HEADER "", STR0121,STR0122,STR0123,_MV_LOC248,STR0124,STR0125,STR0126,STR0127,STR0128  SIZE 380,170 OF ODLG PIXEL ON DBLCLICK (MARCARREGI(.F.)) //"Nº AS"###"Equipamento"###"Viagem"###"PROJETO"###"Destino"###"Origem"###"Produto"###"Obra"###"Registro"
			OLBX:SETARRAY(ALINHA)
			//copia array original
			aLstBxOri := aClone(oLbx:aArray)
			OLBX:BLINE := {|| { IF( ALINHA[OLBX:NAT,1],OOK,ONO),; 			// CHECKBOX
									ALINHA[OLBX:NAT,2],; 					// Nº AS
									ALINHA[OLBX:NAT,3],; 					// EQUIPAMENTO
									ALINHA[OLBX:NAT,4],;					// VIAGEM
									ALINHA[OLBX:NAT,5],;					// PROJETO
									ALINHA[OLBX:NAT,6],;            		// DESTINO
									ALINHA[OLBX:NAT,7],;            		// ORIGEM
									ALINHA[OLBX:NAT,8],;					// PRODUTO - FRANK 23/09/2020
									ALINHA[OLBX:NAT,9],;					// OBRA
									ALINHA[OLBX:NAT,10]}}   				// RECNO()

			@ 195,5 CHECKBOX LTODOS PROMPT STR0129 SIZE 100, 10 OF ODLG PIXEL ON CLICK MARCARREGI(.T.) //"Marca/Desmarca Todos"

			IF _LC111LBT //EXISTBLOCK("LC111LBT") 										// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NA TELA DE ACEITE EM LOTE.
				EXECBLOCK("LC111LBT",.T.,.T.,{_CQUERY, _NTPACE})
			ELSE
				//@ 195, 200 BUTTON "FILTRO"	  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="F", ODLG:END())
				@ 195, 280 BUTTON STR0130   SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="A", ODLG:END()) // 240 //"Aceitar"
				//@ 195, 280 BUTTON "ESTORNAR"  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="E", ODLG:END())
				@ 195, 320 BUTTON STR0131  SIZE 30,15 PIXEL OF ODLG ACTION (CACAO:="R", ODLG:END()) //"Rejeitar"
			ENDIF
			@ 195, 360 BUTTON STR0132  SIZE 30,15 PIXEL OF ODLG ACTION (ODLG:END()) //"Cancelar"
		ACTIVATE MSDIALOG ODLG CENTERED
	ELSE
		CAVISO := STR0133 //"Não há AS(S) a serem exibidas!"
	ENDIF

	IF !EMPTY(CACAO)

		IF CACAO == "R"
			CPARA := GETMV("MV_LOCX178",,"")
			LOK   := .F.
			DEFINE MSDIALOG _ODLGMAIL TITLE STR0135 FROM C(230),C(359) TO C(400),C(882) PIXEL	//DE 610 PARA 400 //"Motivo da rejeição do lote"
				@ C(025),C(011) SAY STR0050   			SIZE C(030),C(008) PIXEL OF _ODLGMAIL //"Motivo:"
				@ C(025),C(042) GET OMSG VAR CMSG MEMO 		SIZE C(200),C(055) PIXEL OF _ODLGMAIL
			ACTIVATE MSDIALOG _ODLGMAIL CENTERED ON INIT ENCHOICEBAR(_ODLGMAIL, {||LOK:=.T., _ODLGMAIL:END()}, {||_ODLGMAIL:END()} )
			IF ! LOK
				FQ5->(RESTAREA(AAREADTQ))
				RETURN .F.
			ENDIF
			CMSG := STR0136 + CMSG + CRLF + CRLF //"Motivo: "
		ELSE
			CPARA := GETMV("MV_LOCX033",,"")
		ENDIF

		FOR NI:=1 TO LEN(ALINHA)
			IF ALINHA[NI,1]													// SELECIONADO
				FQ5->(DBGOTO( ALINHA[NI,10] ))					// RECNO
				IF CACAO == "R"
					LOCA05907(CMSG)
				ELSEIF CACAO == "A"
					IF ! LNPROG .AND. CSERV=="F" .AND. EMPTY(FQ5->FQ5_TIPAMA)
						LNPROG := .T.
					ENDIF
					IF CSERV!="F" .OR. !EMPTY(FQ5->FQ5_TIPAMA)
						LOCA05908("LOTE")
					ENDIF
				ELSEIF CACAO == "E"
					CAVISO += LOCA05906(.T.)
				ENDIF
			ENDIF
		NEXT NI

		IF (CACAO == "A" .OR. CACAO == "R") .AND. !EMPTY(ALLTRIM(CPARA))
			FOR NI := 1 TO LEN(ALINHA)
				IF ALINHA[NI,1]

					IF EMPTY(_CPRJOLD)
						_CPRJOLD := ALINHA[NI,5]
					ENDIF

					IF ALLTRIM(_CPRJOLD) <> ALLTRIM(ALINHA[NI,5])
						// MANDA E-MAIL
						IF CACAO == "R"
							CTITULO := STR0137 + _MV_LOC248 + ": " + ALLTRIM(_CPRJOLD) //"Referente ao rejeite da(s) AS(s) - "###"PROJETO"
						ELSE
							IF _LC111TIT //EXISTBLOCK("LC111TIT")
								CTITULO := EXECBLOCK("LC111TIT", .T., .T., {_NTPACE, _CPRJOLD})
							ELSE
								CTITULO := STR0138 + _MV_LOC248 + ": " + ALLTRIM(_CPRJOLD) //"Referente ao aceite da(s) AS(s) - "###"MV_LOCX248"###"PROJETO"
							ENDIF
						ENDIF

						CMSG := CTITULO + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CMSG + CHR(13) + CHR(10)

						IF _LC111USR // EXISTBLOCK("LC111USR")
							CMSG += EXECBLOCK("LC111USR", .T., .T., {_NTPACE, CACAO}) + CRLF + CRLF
						ENDIF

						FOR _NX := 1 TO LEN(_AASLOTE)
							FQ5->(DBGOTO( _AASLOTE[_NX] ))	// RECNO
							IF CACAO == "R"
								CMSG += STR0140 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao rejeite da AS número "###"PROJETO"
							ELSE
								CMSG += STR0141 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao aceite da AS número "###"PROJETO"
							ENDIF
							CMSG     += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //"Data INI/FIM: "###",  Obra: "###",  Cliente: "
						NEXT _NX

						_AASLOTE := {}
					ENDIF

					AADD(_AASLOTE,ALINHA[NI,LEN(ALINHA[NI])])

					_CPRJOLD := ALINHA[NI,5] 		// PROJETO
				ENDIF
			NEXT NI

			IF LEN(_AASLOTE) > 0
				// MANDA E-MAIL
				FQ5->(DBGOTO( _AASLOTE[1] ))		// RECNO

				IF CACAO == "R"
					CTITULO := STR0137 + _MV_LOC248 + ": " + ALLTRIM(FQ5->FQ5_SOT) //"Referente ao rejeite da(s) AS(s) - "###"PROJETO"
				ELSE
					IF _LC111TIT //EXISTBLOCK("LC111TIT")
						CTITULO := EXECBLOCK("LC111TIT", .T., .T., {_NTPACE, _CPRJOLD})
					ELSE
						CTITULO := STR0138 + _MV_LOC248 + ": " + ALLTRIM(FQ5->FQ5_SOT) //"Referente ao aceite da(s) AS(s) - "###"PROJETO"
					ENDIF
				ENDIF

				CMSG := CTITULO + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CMSG + CHR(13) + CHR(10)

				IF _LC111USR //EXISTBLOCK("LC111USR")
					CMSG += EXECBLOCK("LC111USR", .T., .T., {_NTPACE, CACAO}) + CRLF + CRLF
				ENDIF

				FOR _NX := 1 TO LEN(_AASLOTE)
					FQ5->(DBGOTO( _AASLOTE[_NX] )) 	// RECNO
					IF CACAO == "R"
						CMSG += STR0140 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao rejeite da AS número "###"PROJETO"
					ELSE
						CMSG += STR0141 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente ao aceite da AS número "###"PROJETO"
					ENDIF
					CMSG     += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0047+ALLTRIM(FQ5->FQ5_DESTIN)+STR0048+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF //"Data INI/FIM: "###",  Obra: "###",  Cliente: "
				NEXT _NX

			ENDIF

		ENDIF

		IF LNPROG
			Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
				Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
				{STR0142}) //"Existem ASF sem programação."
		ENDIF
		IF NTOTMIN > 0
			MSGINFO(STR0143 +ALLTRIM(STR(NTOTMIN))+STR0144 , STR0022)  //"Foram geradas "###" minutas."###"Atenção!"
		ENDIF
	ENDIF

	IF ! EMPTY(CAVISO)
		AVISO(CTITULO,CAVISO,{"OK"},2)
	ENDIF

	FQ5->(RESTAREA(AAREADTQ))

RETURN .T.

/*/{PROTHEUS.DOC} MARCARREGI
ITUP BUSINESS - TOTVS RENTAL
FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR OS ITENS
@TYPE FUNCTION
@AUTHOR ITUP
/*/
STATIC FUNCTION MARCARREGI(LTODOS)
Local LMARCADOS := ALINHA[OLBX:NAT,1]
Local LDESMARQ  := .F.
Local LMARK     := .T.
Local LFIRST    := .T.
Local NI        := 0
Local _NXX
Local _CPAI
Local _MARKREG := EXISTBLOCK("MARKREG")

	IF LTODOS
		LMARCADOS := ! LMARCADOS
		FOR NI := 1 TO LEN(ALINHA)
			IF _MARKREG //EXISTBLOCK("MARKREG") 										// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE ESTÁ SENDO MARCADO ESTÁ DISPONÍVEL.
				LTEM := EXECBLOCK("MARKREG",.T.,.T.,{LTODOS, ALINHA, NI, ASCAN(ALINHA , { |X| X[1] == .T. } ),IIF(LFIRST,.T.,.F.)})
				LFIRST := .F.
				IF !LTEM
					LMARK := .F.
				ELSE
					LMARK := .T.
				ENDIF
			ENDIF
			IF LMARK
				ALINHA[NI,1] := LMARCADOS
				OLBX:AARRAY[NI,1] := ALINHA[NI,1] // 07/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS
			ENDIF
		NEXT NI
		IF LDESMARQ
			Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
				Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
				{STR0145}) //"Falta preencher a programação. AS não selecionadas."
		ENDIF
	ELSE
		IF _MARKREG //EXISTBLOCK("MARKREG") 											// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE ESTÁ SENDO MARCADO ESTÁ DISPONÍVEL.
			LTEM := EXECBLOCK("MARKREG",.T.,.T.,{LTODOS, ALINHA, OLBX:NAT, ALINHA[OLBX:NAT,1], .F.})
			IF !LTEM
				MSGSTOP(STR0146 , STR0022)  //"Não é possível marcar esse item, pois o equipamento não está como reservado."###"Atenção!"
				RETURN ALINHA
			ENDIF
		ENDIF
		ALINHA[OLBX:NAT,1] := ! LMARCADOS
		OLBX:AARRAY[OLBX:NAT,1] := ALINHA[OLBX:NAT,1] // 07/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS

		// FRANK 23/09/2020
		// VERIFICAR SE O PRODUTO MARCADO FAZ PARTE DE UMA ESTRUTURA
		IF SUPERGETMV("MV_LOCX028",,.F.) // PARAMETRO QUE INDICA SE USA O CONCEITO DE ENTRUTURA PAI -> FILHO //"MV_LOCX028"
			IF ALINHA[OLBX:NAT,1]
				FPA->(DBSETORDER(3))
				IF FPA->(DBSEEK(XFILIAL("FPA")+ALINHA[OLBX:NAT,2]))
					IF !EMPTY(FPA->FPA_SEQEST)
						IF MSGYESNO(STR0148,STR0149) //"MARCAR TODOS OS ITENS?"###"ITEM FORMADOR DE UMA ESTRUTURA PAI-FILHO."
							_CPAI := SUBSTR(FPA->FPA_SEQEST,1,3)
							FOR _NXX := 1 TO LEN(ALINHA)
								IF FPA->(DBSEEK(XFILIAL("FPA")+ALINHA[_NXX,2]))
									IF SUBSTR(FPA->FPA_SEQEST,1,3) == _CPAI
										ALINHA[_NXX,1] := .T.
										OLBX:AARRAY[_NXX,1] := ALINHA[_NXX,1] // 07/10/2022 - Jose Eulalio - SIGALOC94-515 - Colocar pesquisa e filtro na tela de lote (aceite e rejeite) Apontador de AS
									ENDIF
								ENDIF
							NEXT
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF

	ENDIF

	OLBX:REFRESH()
	ODLG:REFRESH()

RETURN NIL

/*/{PROTHEUS.DOC} LOCA05919
TOTVS RENTAL - módulo 94
Esta função tem por finalidade a execução da troca do equipamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 23/06/2020
/*/
FUNCTION LOCA05919()
Local CFILOLD 		:= CFILANT

Private lExibe    	:= .T.
Private cEscolhe  	:= ""

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	CFILANT := FQ5->FQ5_FILORI

	IF SUBSTR(FQ5->FQ5_AS,1,2) == "22" // RECURSO HUMANO
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0171}) //"Só é possível realizar a troca de equipamentos, no caso de recurso a seleção é feita no aceita da AS."
	ELSE
		LOCA05920()
	ENDIF

	CFILANT := CFILOLD

RETURN

/*/{PROTHEUS.DOC} LOCA05920
TOTVS RENTAL - módulo 94
Esta função tem por finalidade o processamento da troca do equipamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 23/06/2020
/*/
FUNCTION LOCA05920()
LOCAL AAREA       := GETAREA()
LOCAL AAREAZA0    := FP0->(GETAREA())
LOCAL AAREAZA5    := FP4->(GETAREA())
Local aAreaSB1    := SB1->(GetArea())
LOCAL ODLGT       := NIL
LOCAL ACAB        := {}
LOCAL ACOLSCP1    := {}
LOCAL AFIELDFILL  := {}
LOCAL ABUTTONS 	  := {}
LOCAL LOK         := .F.
LOCAL NX          := 0
LOCAL NY          := 0
Local _MV_LOC248  := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"
Local _LTREQCAB   := EXISTBLOCK("LTREQCAB")
Local lLOCX305	  := SuperGetMV("MV_LOCX305",.F.,.T.) //Define se aceita geração de contrato sem equipamento
Local cItem		  := "01" // 01/11/2022 - Jose Eulalio - Troca de equipamento - contrato com mais de 99 AS
Local lLOCA59X3   := EXISTBLOCK("LOCA59X3")

PRIVATE AALTERCPO := {"EQUIPNV"}
PRIVATE AITENS    := {}
PRIVATE OLBX1     := NIL
PRIVATE BFIELDOK  := {|| VALIDTRC()}
PRIVATE BLINHAOK  := {|| VALIDLIN()}

Private nMilissegundos := 1000 // 1 decimo de segundo

Private oTimer

	IF !(EMPTY(FQ5->FQ5_DATFEC) .AND.  EMPTY(FQ5->FQ5_DATENC) .AND. FQ5->FQ5_STATUS == "1")
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0172}) //"Só é permitido trocar equipamento de AS 'EM ABERTO'."
		RETURN
	ENDIF

	AADD(ACAB , { "Item"              , ;
				"ITEM"              , ;
				"@!"                , ;
				02            	  , ;
				00                  , ;
				""                  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"   "               , ;
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { FWX3Titulo("FPA_AS" ) , ;
				"XAS"              , ;
				"@!"                , ;
				TAMSX3("FPA_AS")[1]           	  , ;
				00                  , ;
				""                  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"   "               , ;
				"R"                 , ;
				" "                 , ;
				" " })
	AADD(ACAB , { STR0173     , ; //"Recurso atual"
				"EQUIPAT"           , ;
				"@!"                , ;
				16                  , ;
				00                  , ;
				""                  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"   "               , ;
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { STR0174 , ; //"Placa + Descrição"
				"PLADESC"           , ;
				"@!"                , ;
				71                  , ;
				00                  , ;
				""                  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"   "               , ;
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { "Produto"      , ; //"Produto"
				"PRODCOD"           , ;
				"@!"                , ;
				TamSx3("B1_COD")[1] , ;
				00                  , ;
				""  	  			  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				""            	  , ;
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { "Descrição"      , ; //"Descrição"
				"PRODDES"           , ;
				"@!"                , ;
				TamSx3("B1_DESC")[1], ;
				00                  , ;
				""  	  			  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				""                  , ;
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { STR0175      , ; //"Novo Recurso"
				"EQUIPNV"           , ;
				"@!"                , ;
				16                  , ;
				00                  , ;
				"LOCA05933()"  	  , ; // José Eulálio - 01/11/2022 - SIGALOC94-541 - Colocar valid na troca de equipamento.
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"ST9003"            , ; // José Eulálio - 12/05/2022 - SIGALOC94-337 - Ajuste na troca de equipamento (seleção de bem) conforme campo
				"R"                 , ;
				" "                 , ;
				" " })

	AADD(ACAB , { STR0174 , ; //"Placa + Descrição"
				"DESCPLA"           , ;
				"@!"                , ;
				71                  , ;
				00                  , ;
				""                  , ;
				"€€€€€€€€€€€€€€ "   , ;
				"C"                 , ;
				"   "               , ;
				"R"                 , ;
				" "                 , ;
				" " })

	DBSELECTAREA("FP0")
	DBSETORDER(1)
	IF ! DBSEEK(XFILIAL("FP0")+FQ5->FQ5_SOT)
		Help(Nil,	Nil,STR0023+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0024,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{ STR0176+CHR(10)+CHR(13) + _MV_LOC248 + STR0177+ALLTRIM(FQ5->FQ5_SOT)  }) //"Troca de equipamento."###"Projeto"###" não encontrado: "
		RETURN .F.
	ENDIF

	IF FP0->FP0_TIPOSE == "L"
		DBSELECTAREA("FPA")
		DBSETORDER(1) 					// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
		DBSEEK(XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA, .T. )

		FQ5->( DBSETORDER(1) )			// FILIAL + VIAGEM
		WHILE !(FPA->(EOF())) .AND. FPA->(FPA_FILIAL+FPA_PROJET+FPA_OBRA) == XFILIAL("FPA") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA
			// 16/09/2022 - Jose Eulalio - SIGALOC94-517 - Parou de apresentar no GRID todos itens da obra na opção troca de equipamento
			//IF !EMPTY( FPA->FPA_VIAGEM ) .AND. FPA->FPA_VIAGEM == FQ5->FQ5_VIAGEM //FQ5->( DBSEEK( XFILIAL("FQ5") + FPA->FPA_VIAGEM ) )
			IF !EMPTY( FPA->FPA_VIAGEM ) .AND. FQ5->( DBSEEK( XFILIAL("FQ5") + FPA->FPA_VIAGEM ) ) .And. FQ5->FQ5_STATUS == "1"
				If FPA->FPA_TIPOSE <> "M"
					If !empty(FPA->FPA_GRUA)
						ATMP := GETEQPINFO(FPA->FPA_GRUA)
						// 01/11/2022 - Jose Eulalio - Troca de equipamento - contrato com mais de 99 AS
						//AADD(AITENS, { STRZERO(NITEM,2), FPA->FPA_GRUA, ATMP[1]+" "+ATMP[2],SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
						//NITEM++
						//AADD(AITENS, { cItem, FPA->FPA_GRUA, ATMP[1]+" "+ATMP[2],SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
						AADD(AITENS, { 	cItem, ;
										FPA->FPA_AS, ;
										FPA->FPA_GRUA, ;
										ATMP[1]+" "+ATMP[2], ;
										FPA->FPA_PRODUT,;
										Posicione("SB1",1,xFilial("SB1")+FPA->FPA_PRODUT,"B1_DESC"), ;
										SPACE(16), ;
										SPACE(71), ;
										FPA->(RECNO()), ;
										FQ5->(RECNO()) } )
						cItem := Soma1(cItem)
					ElseIf lLOCX305

						lForca := .F.
						If lLOCA59X3
							lForca := EXECBLOCK("LOCA59X3",.T.,.T.,{})
						EndIf

						SB1->(DBSETORDER(1))
						If SB1->(DBSEEK(XFILIAL("SB1") + FQ5->FQ5_XPROD)) .or. lForca
							//Se não for um bem acessório, adiciona
							If !LOCXITU26(SB1->B1_COD) .or. lForca
								// 01/11/2022 - Jose Eulalio - Troca de equipamento - contrato com mais de 99 AS
								//AADD(AITENS, { STRZERO(NITEM,2), FPA->FPA_GRUA, AllTrim(FQ5->FQ5_XPROD) + "|" + AllTrim(SB1->B1_DESC),SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
								//NITEM++
								//AADD(AITENS, { cItem, FPA->FPA_GRUA, AllTrim(FQ5->FQ5_XPROD) + "|" + AllTrim(SB1->B1_DESC),SPACE(16),SPACE(71), FPA->(RECNO()), FQ5->(RECNO()) } )
								AADD(AITENS, {	cItem, ;
												FPA->FPA_AS, ;
												FPA->FPA_GRUA, ;
												AllTrim(FQ5->FQ5_XPROD) + "|" + AllTrim(SB1->B1_DESC), ;
												SB1->B1_COD, ;
												AllTrim(SB1->B1_DESC), ;
												SPACE(16), ;
												SPACE(71), ;
												FPA->(RECNO()), ;
												FQ5->(RECNO())} )
								cItem := Soma1(cItem)
							EndIf
						EndIf
					EndIf
				EndIf
			ENDIF
			FPA->(DBSKIP())
		ENDDO

	ELSE
		MSGALERT(STR0176+CHR(10)+CHR(13)+STR0179 + _MV_LOC248 + STR0180+ FP0->FP0_TIPOSE , STR0022)  //"Troca de equipamento."###"Tipo do "###"Projeto"###" Inválido: "###"Atenção!"
		RESTAREA( AAREA )				// RESTAURA DTQ
		RETURN .F.

	ENDIF

	RESTAREA( AAREA )					// RESTAURA DTQ

	IF _LTREQCAB //EXISTBLOCK("LTREQCAB") 												// --> PONTO DE ENTRADA PARA ALTERAÇÃO DE CAMPOS NA TROCA DE EQUIPAMENTO.
		ACAB := EXECBLOCK("LTREQCAB",.T.,.T.,{ACAB})
	ENDIF

	If len(aItens) == 0
		Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
			Nil,STR0181,1,0,Nil,Nil,Nil,Nil,Nil,; //"Não foram localizados equipamentos para substituição."
			{STR0182}) //"Verifique no orçamento se foram informados os bens, para a locação em questão."
		RESTAREA(AAREAZA5)
		RESTAREA(AAREAZA0)
		RESTAREA(AAREA)
		Return .F.
	EndIF

	// ALIMENTA O ACOLS
	FOR NX := 1 TO LEN(AITENS)
		AFIELDFILL := {}
		FOR NY := 1 TO LEN(AITENS[NX])
			AADD(AFIELDFILL, AITENS[NX,NY])
		NEXT NY

		AADD(AFIELDFILL, .F.)

		AADD(ACOLSCP1, AFIELDFILL)
	NEXT NX

	OSIZE := FWDEFSIZE():NEW( .T.)
	OSIZE:ADDOBJECT("CGETD" , 90 , 75 , .T. , .T.) // ENCHOICE
	OSIZE:LPROP := .T.
	OSIZE:PROCESS()
								// DISPARA OS CALCULOS
	//DEFINE MSDIALOG ODLGT FROM 0,0 TO 285,1100 PIXEL TITLE STR0122 //"Equipamento"
	DEFINE MSDIALOG ODLGT FROM OSIZE:AWINDSIZE[1],OSIZE:AWINDSIZE[2] TO OSIZE:AWINDSIZE[3],OSIZE:AWINDSIZE[4] PIXEL TITLE STR0122 //"Equipamento"
		NW := (ODLGT:NCLIENTWIDTH/2)
		NH := (ODLGT:NCLIENTHEIGHT/2)-25

		NPOS      := ASCAN( OSIZE:APOSOBJ, { |X| ALLTRIM(X[7]) == "CGETD"} )
		NSUPERIOR := OSIZE:APOSOBJ[NPOS][1]
		NESQUERDA := OSIZE:APOSOBJ[NPOS][2]
		NINFERIOR := OSIZE:APOSOBJ[NPOS][3]
		NDIREITA  := OSIZE:APOSOBJ[NPOS][4]

		//OLBX1 := MSNEWGETDADOS():NEW( 05 , 01, 120, NW, GD_UPDATE, "EVAL(BLINHAOK)", "ALLWAYSTRUE", "+", AALTERCPO,, 999, "EVAL( BFIELDOK )", "", "ALLWAYSTRUE", ODLGT, ACAB, ACOLSCP1)
		OLBX1 := MSNEWGETDADOS():NEW( NSUPERIOR, NESQUERDA , NINFERIOR , NDIREITA, GD_UPDATE, "EVAL(BLINHAOK)", "ALLWAYSTRUE", "+", AALTERCPO,, 999, "EVAL( BFIELDOK )", "", "ALLWAYSTRUE", ODLGT, ACAB, ACOLSCP1)
		oTimer := TTimer():New(nMilissegundos, {|| LOCA059X() }, ODLGT )

		//OTBROWSEBUTTON := TBROWSEBUTTON():NEW( 130,500,"OK",ODLGT  , {|| IIF(VALIDTROCAEQ(OLBX1:ACOLS),(LOK := .T., ODLGT:END()),LOK := .F.)},37,12,,,.F.,.T.,.F.,,.F.,,,)
		ODLGT:BINIT := {|| ENCHOICEBAR(ODLGT , {|| IIF(VALIDTROCAEQ(OLBX1:ACOLS),(LOK := .T., ODLGT:END()),LOK := .F.)} , {||LOK := .F.,ODLGT:END()},,@ABUTTONS,,,,,.F.)}
	ACTIVATE MSDIALOG ODLGT CENTERED

	IF LOK
		LOCA05921(OLBX1:ACOLS,FP0->FP0_TIPOSE)
	ENDIF

	RESTAREA(AAREAZA5)
	RESTAREA(AAREAZA0)
	RESTAREA(AAREA)
	RestArea(aAreaSB1)

RETURN NIL

/*/{PROTHEUS.DOC} VALIDLIN
TOTVS RENTAL - módulo 94
Valida a linha na troca do equipamento
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
STATIC FUNCTION VALIDLIN()
LOCAL LRET := .T.
Local _LCVLDLIN := EXISTBLOCK("LCVLDLIN")

	IF _LCVLDLIN //EXISTBLOCK("LCVLDLIN") 												// --> PONTO DE ENTRADA PARA INCLUSÃO DE BOTÕES NA TELA DE ACEITE EM LOTE.
		LRET := EXECBLOCK("LCVLDLIN",.T.,.T.,{})
	ENDIF

RETURN LRET


/*/{PROTHEUS.DOC} VALIDTRC
TOTVS RENTAL - módulo 94
Valida a troca do equipamento
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
STATIC FUNCTION VALIDTRC()
LOCAL LRET := .T.

	ST9->( DBSETORDER(1) )
	IF !ST9->( DBSEEK(XFILIAL("ST9") + M->EQUIPNV ) )
		MSGALERT(STR0183+ALLTRIM(M->EQUIPNV)+STR0184 , STR0022)  //"Recurso informado ("###") Inválido."###"Atenção!"
		LRET := .F.
	ELSE
		ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="DESCPLA"})] := ST9->T9_NOME
	ENDIF

	If len(aCols) > 1
		oTimer:Activate()
	EndIF

RETURN LRET


/*/{PROTHEUS.DOC} VALIDTROCAEQ
TOTVS RENTAL - módulo 94
Valida a troca do equipamento, se as siglas são iguais
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
STATIC FUNCTION VALIDTROCAEQ(ATROCA)
LOCAL CEQUIATU  := ""
LOCAL CEQUINOV	:= ""
LOCAL LRET		:= .T.
LOCAL _LVLDTIPO := SUPERGETMV("MV_LOCX256",.F.,.F.)
LOCAL NX        := 0
Local _VALGRUA := EXISTBLOCK("VALGRUA")

	FOR NX := 1 TO LEN(ATROCA)

		IF ! EMPTY( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] )
			CEQUIATU := ALLTRIM(GETADVFVAL("ST9", "T9_CODFAMI",XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})],1,"")) //SUBSTR(ATROCA[NX,2],1,3)//+SUBSTR(ATROCA[NX,2],6,3)
			CEQUINOV := ALLTRIM(GETADVFVAL("ST9", "T9_CODFAMI",XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})],1,"")) //SUBSTR(ATROCA[NX,4],1,3)//+SUBSTR(ATROCA[NX,4],6,3)

			DBSELECTAREA("ST9")
			DBSETORDER(1)
			IF !DBSEEK(XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})])
				MSGALERT(STR0185+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="ITEM"})]+STR0186+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})])+STR0187 , STR0022)  //"Item: "###" - O recurso selecionado ("###") é inválido."###"Atenção!"
				LRET := .F.
				EXIT
			ENDIF

			IF _LVLDTIPO
				IF (CEQUIATU <> CEQUINOV) .AND. LRET
					MSGALERT(STR0185+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="ITEM"})]+STR0186+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})])+STR0188+ALLTRIM(ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])+")." , STR0022)  //"Item: "###" - O recurso selecionado ("###"), não tem o mesmo tipo ou configuração do que foi vendido ("###"Atenção!"
					LRET := .F.
					EXIT
				ENDIF
			ENDIF

			// VERIFICA SE O EQUIPAMENTO É VALIDO.
			IF _VALGRUA //EXISTBLOCK("VALGRUA") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
				LRET := EXECBLOCK("VALGRUA",.T.,.T.,{.T.,ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]})
				IF !LRET
					EXIT
				ENDIF
			ENDIF
		ENDIF

	NEXT NX

RETURN(LRET)


/*/{PROTHEUS.DOC} LOCA05921
TOTVS RENTAL - módulo 94
Gravação da troca de equipamentos
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
FUNCTION LOCA05921(ATROCA,CTIPO)
LOCAL AAREA    := GETAREA()
LOCAL AAREAZA5 := FP4->(GETAREA())
LOCAL AAREAZLG := FPO->(GETAREA())
LOCAL AAREAST9 := ST9->(GETAREA())
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL AAREASHB := SHB->(GETAREA())
LOCAL CMSG     := ""
LOCAL NX       := 0
LOCAL _cStOld  := ""
Local _LC111TEQ := EXISTBLOCK("LC111TEQ")
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local _cQuery   := ""
Local aBindParam := {}

	FOR NX := 1 TO LEN(ATROCA)
		IF !EMPTY( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] )	// SÓ VAI TROCAR SE ESTIVER PREENCHIDO

			// posicionar no bem antigo para saber o status dele
			IF ST9->( DBSEEK( XFILIAL("ST9") + FQ5->FQ5_GUINDA ) )
				_cStOld := ST9->T9_STATUS
			Else
				//08/09/2021 - Jose Eulalio - DSERLOCA-296
				//Caso não localize o bem (produto sem bem)
				_cStOld := "10"
			EndIf

			ST9->( DBSETORDER(1) )
			IF ! ST9->( DBSEEK( XFILIAL("ST9")+ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] ) )
				CMSG := "BEM " + ALLTRIM( ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})] ) + STR0189 //" NÃO ENCONTRADO!"
				EXIT
			ENDIF

			FQ5->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-1] )) 							// POSICIONA A DTQ DA LINHA DO ITEM
			FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )

			If !empty(ST9->T9_STATUS)
				// ALOCA BEM NOVO
				//IF EXISTBLOCK("T9STSALT") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
					//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,_cStOld,FQ5->FQ5_SOT,"",""})
					LOCXITU21(ST9->T9_STATUS,_cStOld,FQ5->FQ5_SOT,"","")
				//ENDIF
				//Valtenio Oliveira card DSERLOCA-8043
				// Atualmente, o sistema grava o status 10, porém o correto seria L1.
				_cStOld := "10" 	
				RECLOCK("ST9",.F.)
				//ST9->T9_STATUS := _cStOld //Alterado Valtenio Oliveira card DSERLOCA-8043				
				ST9->T9_STATUS := POSICIONE("FQD", 1, XFILIAL("FQD") + _cStOld, "FQD_STATQY")
				ST9->(MSUNLOCK())

				RECLOCK("FQ5",.F.)
				IF FP0->FP0_TIPOSE == "T"
					CBEMOLD         := FQ5->FQ5_EQUIP
					FQ5->FQ5_EQUIP  := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
				ELSE
					CBEMOLD         := FQ5->FQ5_GUINDA
					FQ5->FQ5_GUINDA := ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
				ENDIF
				FQ5->(MSUNLOCK())

				// DISPONIBILIZA BEM ANTIGO
				NRECST9 := ST9->( RECNO() )

				//IF EXISTBLOCK("T9STSALT") 										// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
				//	EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,"01",FQ5->FQ5_SOT,"","",.T.})
				//ENDIF

				_cTemps00 := ""
				If !lMvLocBac
					TQY->(dbSetOrder(1))
					TQY->(dbGotop())
					While !TQY->(Eof())
						If TQY->TQY_STTCTR == "00"
							_cTemps00 := TQY->TQY_STATUS
						EndIF
						TQY->(dbSkip())
					EndDo
				else
/*					FQD->(dbSetOrder(1))
					FQD->(dbGotop())
					While !FQD->(Eof())
						If FQD->FQD_STAREN == "00"
							_cTemps00 := FQD->FQD_STATQY
						EndIF
						FQD->(dbSkip())
					EndDo*/

				   	_cQuery := " SELECT FQ4_STSOLD FROM " + RETSQLNAME("FQ4") + " FQ4 "
 			       	_cQuery += " WHERE  FQ4.FQ4_SEQ =    
   		     		_cQuery += " (SELECT MAX(FQ4_SEQ) SEQ FROM " + RETSQLNAME("FQ4")  + " FQ4M "    
   	 				_cQuery += " WHERE  FQ4M.D_E_L_E_T_ = ''"    
					_cQuery += "   AND  FQ4M.FQ4_FILIAL = ? "
					Aadd(aBindParam, xFilial("FQ4") )
					_cQuery += "   AND  FQ4M.FQ4_CODBEM = ? )"
					Aadd(aBindParam, CBEMOLD )
					_cQuery := CHANGEQUERY(_cQuery)
					MPSysOpenQuery(_cQuery,"TRBFQ4",,,aBindParam)
       				If !TRBFQ4->(Eof())
						_cTemps00 := TRBFQ4->FQ4_STSOLD
    			    EndIf
   	       			TRBFQ4->(dbCloseArea())

				EndIF

				IF ST9->( DBSEEK( XFILIAL("ST9") + CBEMOLD ) )
					//IF EXISTBLOCK("T9STSALT") 									// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
						//EXECBLOCK("T9STSALT",.T.,.T.,{ST9->T9_STATUS,"00",FQ5->FQ5_SOT,"","",.T.})
						LOCXITU21(ST9->T9_STATUS,_cTemps00,FQ5->FQ5_SOT,"","",.T.)
					//ENDIF
					RECLOCK("ST9",.F.)
					ST9->T9_STATUS := _cTemps00 //"01" - atendimento ao card gerado pelo Rafael em 11/02/21 - Frank Fuga
					ST9->(MSUNLOCK())
				ENDIF

				ST9->( DBGOTO( NRECST9 ) )
			EndIf

			IF FP0->FP0_TIPOSE == "L"
				DBSELECTAREA("ST9")
				ST9->( DBSETORDER(1) )
				ST9->(DBSEEK(XFILIAL("ST9") + ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]))
				DBSELECTAREA("SHB")
				SHB->( DBSETORDER(1) )
				SHB->(DBSEEK(XFILIAL("SHB") + ST9->T9_CENTRAB))

				FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-2] ) )		// FPA->( DBGOTO( ATROCA[NX,LEN(ATROCA[NX])-1] ) )
				RECLOCK("FPA",.F.)
				FPA->FPA_GRUA	:= ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]
				FPA->FPA_DESGRU	:= ALLTRIM(ST9->T9_NOME)
				IF SHB->(FIELDPOS("HB_XCCFAT")) > 0
					FPA->FPA_CUSTO	:= SHB->HB_XCCFAT
				ENDIF
				FPA->(MSUNLOCK())
			ENDIF

			// INTEGRAÇÃO DIÁRIO DE BORDO / OCORRÊNCIAS
			FQA->( DBSETORDER(1) )									// VIAGEM
			IF FQA->( DBSEEK(XFILIAL("FQA")+FQ5->FQ5_VIAGEM) )
				RECLOCK("FQA",.F.)
				IF NX == 1
					FQA->FQA_PLACA	:= ST9->T9_PLACA
				ELSE
					FQA->FQA_VEICUL := ST9->T9_PLACA
				ENDIF
				FQA->(MSUNLOCK())
			ENDIF

			IF FP0->FP0_TIPOSE == "T"
				// CRIA A ZLE
			ENDIF

			IF _LC111TEQ //EXISTBLOCK("LC111TEQ") 										// --> PONTO DE ENTRADA NO FINAL DA ATUALIZAÇÃO DE TROCA DE EQUIPAMENTO DA AS.
				EXECBLOCK("LC111TEQ",.T.,.T.,{ATROCA[NX,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"})]})
			ENDIF

		ENDIF
	NEXT NX

	IF ! EMPTY( CMSG )
		MSGALERT(CMSG , STR0022) //"Atenção!"
	ELSE
		MSGINFO(STR0190 , STR0022) //"Troca de equipamento efetuada com sucesso."###"Atenção!"
	ENDIF

	RESTAREA(AAREASHB)
	RESTAREA(AAREADTQ)
	RESTAREA(AAREAST9)
	RESTAREA(AAREAZLG)
	RESTAREA(AAREAZA5)
	RESTAREA(AAREA)

RETURN EMPTY( CMSG )

/*/{PROTHEUS.DOC} LOCA05922
TOTVS RENTAL - módulo 94
Executa filtro do controle de acesso e restrição na consulta SXB
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
FUNCTION LOCA05922()
LOCAL LRET := .F.
STATIC CCONDICAO

	IF CCONDICAO == NIL
		CCONDICAO := &( " { || " + CHKRH( FUNNAME() , ALIAS() , IF(ISINCALLSTACK("SETPRINT"), "2", "1") ) + " } " )
	ENDIF

	LRET := EVAL( CCONDICAO )

RETURN(IIF( VALTYPE(LRET)=="U" , .T. , LRET))

/*/{PROTHEUS.DOC} GETEQPINFO
@AUTHOR  IT UP BUSINESS
@SINCE   22/12/2014
@VERSION 1.0
@RETURN  AEQUIP , ARRAY , DADOS DO EQUIPAMENTO
				  AEQUIP[1] - PLACA
				  AEQUIP[2] - DESCRIÇÃO
/*/
STATIC FUNCTION GETEQPINFO(CCODEQUIP)
LOCAL AAREAST9 	:= ST9->(GETAREA())
LOCAL AEQUIP	:= {}

	DBSELECTAREA("ST9")
	DBSETORDER(1)
	IF MSSEEK(XFILIAL("ST9") + CCODEQUIP)
		AADD(AEQUIP , ALLTRIM(ST9->T9_PLACA))
		AADD(AEQUIP , ALLTRIM(ST9->T9_NOME))
	ELSE
		AADD(AEQUIP , "")
		AADD(AEQUIP , "")
	ENDIF

	RESTAREA(AAREAST9)

RETURN AEQUIP

/*/{PROTHEUS.DOC} FACEMINUTA
TOTVS RENTAL - módulo 94
Aceite da minuta
@TYPE FUNCTION
@AUTHOR Itup
@SINCE 23/06/2020
/*/
STATIC FUNCTION FACEMINUTA(CLOTE, lMao) // 26/08/25 ISSUE 7918 - Frank
LOCAL NVERZBX , AVERZBX , AERROSZBX := {}
LOCAL NPOS , DDATAAUX
LOCAL CFROTA , CAS , DINI , DFIM
LOCAL CPROJET , COBRA
LOCAL AGRAVAR
LOCAL NGRAVADOS  := 0
LOCAL AFROTAS    := {}				// TODO CONJUNTO TRANSPORTADOR
LOCAL _NX        := 0
LOCAL _U         := 0
LOCAL _V         := 0
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0044) //"Projeto"
Local _LC111ANT  := EXISTBLOCK("LC111ANT")
Local _LC111ACE  := EXISTBLOCK("LC111ACE")
LOCAL NTOTMIN	 := 0
Local lLOCA59X4  := EXISTBLOCK("LOCA59X4")
Local lLOCA59X5  := EXISTBLOCK("LOCA59X5")
Local lMvGSxRent := SuperGetMv("MV_GSXRENT",.F.,.F.)
Local lMinOK	 := .T.

Default cLote := ""
Default lMao := .F.

	IF FQ5->FQ5_STATUS != "1" .OR. !EMPTY(FQ5->FQ5_DATENC) .OR. !EMPTY(FQ5->FQ5_DATENC)
		IF EMPTY( CLOTE )
			If _lMens
				//Ferramenta Migrador de Contratos
				If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
					cLocErro := STR0052+CRLF //"Somente uma AS aberta pode ser aceita!"
				Else
					MSGSTOP(STR0052 , STR0022) //"Somente uma AS aberta pode ser aceita!"###"Atenção!"
				EndIf
			EndIF
		ENDIF
		RETURN .F.
	ENDIF

	// --> VALIDAÇÃO DA DISPONIBILIDADE DO EQUIPAMENTO   (*INICIO*)
	// POSICIONAR NA ZA5 PEGAR A DATA INICIO E A DATA FIM.
	// AINDA NA ZA5 PEGAR O TURNO, PODE EXISTIR TURNOS ESPECIFICOS PARA OS FINAIS DE SEMANA.  PEGAR O HORÁRIO INICIO E FIM.
	// TENDO AS INFORMAÇÕES DE DATA INICIO, DATA FIM, HORÁRIOS... POSICIONAR ZLG E VERIFICAR SE ESTIVER PRE-RESERVADO CRIAR
	// UM REGISTRO PASSANDO PARA RESERVADO, SE ESTIVER DIFERENTE DE PRE-RESERVADO, AVISAR QUE O O BEM JÁ ESTA RESERVADO.
	_LXBLOQ := .F.

	lForca := .F.
	If lLOCA59X4
		lForca := EXECBLOCK("LOCA59X4",.T.,.T.,{})
	EndIf

	IF !EMPTY(FQ5->FQ5_GUINDA) .or. lForca .or. lMao
		_AXVALEQUI	:= {}
		FP4->(DBSETORDER(7))
		IF FP4->(DBSEEK(XFILIAL("FP4")+FQ5->FQ5_SOT+FQ5->FQ5_AS))  .or. lForca
			_DXINI 	 := FP4->FP4_DTINI
			_DXFIM	 := FP4->FP4_DTFIM
			_CRESERV := ""
			FPE->(DBSETORDER(1))
			FPE->(DBSEEK(XFILIAL("FPE")+FQ5->FQ5_SOT+FP4->FP4_OBRA+FQ5->FQ5_GUINDA))
			WHILE !FPE->(EOF()) .AND. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA+FPE_FROTA) == XFILIAL("FPE")+FQ5->FQ5_SOT+FP4->FP4_OBRA+FQ5->FQ5_GUINDA

				// DSERLOCA-3409 - Frank Zwarg Fuga em 23/12/2024
				If FPE->FPE_DIASEM <> "M"
					//                PROJETO        , OBRA         , EQUIPAMENTO   , DTINI , DTFIM , HINI           , HFIM           , 1-OK, 2-NAO, 3-TROCA
					AADD(_AXVALEQUI,{ FPE->FPE_PROJET, FPE->FPE_OBRA, FPE->FPE_FROTA, _DXINI, _DXFIM, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, "1" })
				EndIf
				FPE->(DBSKIP())
			ENDDO

			_LXBLOQ   := .F. // VERIFICA SE BLOQUEIA
			_LXBLOQ2  := .F. // VERIFICA SE BLOQUEIA POR PRE-RESERVA
			_CRESERV  := ""
			_CRESERV2 := ""
			FOR _NX:=1 TO LEN(_AXVALEQUI)
				IF _AXVALEQUI[_NX][08] == "2"
					_LXBLOQ := .T.
					_CRESERV += IF(EMPTY(_CRESERV),"","; ")+ALLTRIM(_AXVALEQUI[_NX][03])
				ENDIF
				IF _AXVALEQUI[_NX][08] == "3"
					_LXBLOQ2 := .T.
					_CRESERV2 += IF(EMPTY(_CRESERV2),"","; ")+ALLTRIM(_AXVALEQUI[_NX][03])
				ENDIF
			NEXT _NX
			IF _LXBLOQ
				MSGALERT(STR0193+_CRESERV , STR0022) //"Operação cancelada! Existem itens reservados "###"Atenção!"
				RETURN .F.
			ENDIF
			IF _LXBLOQ2
				MSGALERT(STR0194+_CRESERV2 , STR0022)  //"Operação cancelada! Existem itens que precisam ser reservados."###"Atenção!"
				RETURN .F.
			ENDIF
		ENDIF
	ENDIF
	// --> VALIDAÇÃO DA DISPONIBILIDADE DO EQUIPAMENTO   (*FINAL* )

	CFROTA  := FQ5->FQ5_GUINDA
	CAS     := FQ5->FQ5_AS
	DINI    := FQ5->FQ5_DATINI
	DFIM    := FQ5->FQ5_DATFIM
	CPROJET := FQ5->FQ5_SOT
	COBRA   := FQ5->FQ5_OBRA

	IF DINI > DFIM
		IF EMPTY( CLOTE )
			MSGALERT(STR0195+DTOC(DINI)+STR0196+DTOC(DFIM)+"." , STR0022)  //"Data de início "###" maior que data final "###"Atenção!"
		ENDIF
		RETURN .F.
	ENDIF

	IF ! EMPTY( CFROTA ) .or. lMao
		AADD( AFROTAS, CFROTA )
	ENDIF

	// 01/11/2022 - Jose Eulalio - SIGALOC94-543 - Apontador de AS não aceita tipo de locação = cobrança única

	lForca := .F.
	If lLOCA59X5
		lForca := EXECBLOCK("LOCA59X5",.T.,.T.,{})
	EndIf

	If !lMao // 26/08/25 ISSUE 7918 - Frank
		lMinuta := IsEqMinuta(CFROTA)
		If empty(FQ5->FQ5_GUINDA) .or. lForca
			lMinuta := .F.
		EndIF
	EndIf

	/*
	IF LMINUTA ISSUE 7918 - possibilitar a geração de minuta para mão de obra - 26/08/25 - Frank
		FPA->(DBSETORDER(3))			// FPA_FILIAL + FPA_AS + FPA_VIAGEM
		IF FPA->(DBSEEK( XFILIAL("FPA") + FQ5->FQ5_AS )) .AND. !EMPTY(FQ5->FQ5_AS)
			// 10/10/2022 - Regra passada por Lui - Quando for igual a mão de obra não deverá gerar Minuta
			IF FPA->FPA_TIPOSE == "M"
				LMINUTA := .F.
			ENDIF
		ENDIF
	ENDIF*/

	//IF LEFT( FQ5->FQ5_AS, 2 ) == "06"	// M.O.
	//	AADD( AFROTAS , "" )
	//ENDIF

	If lMinuta //  Rossana - DSERLOCA 3653 - 25/07/2024
		FPF->(DbSetOrder(4))
		FPF->(DbSeek(xFilial("FPF")+FQ5->FQ5_AS))
		While !FPF->(Eof()) .and. FPF->FPF_FILIAL+FPF->FPF_AS==xFilial("FPF")+FQ5->FQ5_AS
			If FPF->FPF_STATUS <> "1"
				If FPF->FPF_DATA < FQ5->FQ5_DATINI .or. FPF->FPF_DATA > FQ5->FQ5_DATFIM
					lMinOK := .f.
				EndIf
			EndIf
			FPF->(DbSkip())
		End
	EndIf

	IF LEN( AFROTAS ) > 0
		AERROSZBX := {}					// GUARDA INCONSISTENCIAS PARA EXIBIR
		FOR _U := DINI TO DFIM
			FOR _V := 1 TO LEN( AFROTAS )
				CFROTA  := AFROTAS[_V]
				AVERZBX := LOCA00514("FACEMINUTA",CFROTA,CFROTA, /*DINI*/ _U, /*DFIM*/ _U, CAS, FQ5->FQ5_HORINI, FQ5->FQ5_HORFIM)  //VERIFICA SE EXISTE ZBX
				IF LEN(AVERZBX) > 0 .AND. FQ5->FQ5_TPAS != "F"
					FOR NVERZBX :=1 TO LEN(AVERZBX)
						AADD(AERROSZBX,{CFROTA,CAS,DINI,DFIM,AVERZBX[NVERZBX,2],AVERZBX[NVERZBX,4],AVERZBX[NVERZBX,5],STR0197}) //" ==> EXISTE MINUTA COM STATUS DIFERENTE DE 1=PREVISTA"
					NEXT
				ENDIF
			NEXT _V
		NEXT _U

		If !lMinuta .or. (lMinuta .and. !lMinOK) //  Rossana - DSERLOCA 3653 - 25/07/2024
			IF LEN( AERROSZBX ) > 0 
				IF EMPTY( CLOTE ) .AND. MSGYESNO(STR0198) //"Visualiza as inconsistências ?"
						LOCA00516(AERROSZBX,STR0199)  //VISUALIZA OS ERROS //"INCONSISTÊNCIAS"
				ENDIF
				RETURN .F.
			EndIf
		ENDIF
	ENDIF

	FP4->(DBSETORDER(2)) 		// FP4_FILIAL + FP4_PROJET + FP4_OBRA + FP4_AS + FP4_VIAGEM
	FPA->(DBSETORDER(1)) 		// FPA_FILIAL, FPA_PROJET, FPA_OBRA, FPA_SEQGRU, R_E_C_N_O_, D_E_L_E_T_
	AGRAVAR := {}

	FOR _V := 1 TO LEN( AFROTAS )
		CFROTA := AFROTAS[_V]
		FOR NPOS := 1 TO (DFIM-DINI)+1
			DDATAAUX := DINI + (NPOS-1)

			IF DOW(DDATAAUX) == 1 .OR. DOW(DDATAAUX) == 7	// EH SABADO OU DOMINGO
				IF FP4->(DBSEEK(XFILIAL("FP4")+FQ5->FQ5_SOT+FQ5->FQ5_OBRA+FQ5->FQ5_AS+FQ5->FQ5_VIAGEM))  //POSICIONA NO EQUIPAMENTO
					DO CASE
					CASE FP4->(DOW(DDATAAUX)==1 .AND. FP4_DOMING=="N") ; LOOP  //TRABALHA SÁBADO?
					CASE FP4->(DOW(DDATAAUX)==7 .AND. FP4_SABADO=="N") ; LOOP  //TRABALHA DOMINGO?
					ENDCASE
				ENDIF

				FPA->(dbSetOrder(3))
				IF FPA->( DBSEEK(XFILIAL("FPA")+FQ5->FQ5_AS, .T. ) )  //FPA->( DBSEEK(XFILIAL("FPA")+CPROJET+COBRA, .T. ) )
					IF ( DOW(DDATAAUX) == 1 .AND. FPA->FPA_DOMING == "N" ) .OR. ( DOW(DDATAAUX) == 7 .AND. FPA->FPA_SABADO == "N" )
						LOOP
					ENDIF
				ENDIF
			ENDIF
			AADD(AGRAVAR,{CFROTA,DDATAAUX,CPROJET,COBRA,0,FQ5->FQ5_HORINI,FQ5->FQ5_HORFIM, FQ5->FQ5_AS, ""})  //A QUINTA POSIÇÃO É PARA GUARDAR O RECNO() NA FAJUSTAZBX()
		NEXT NPOS
	NEXT

	If lMvGSxRent
		If !LOCA084()
			Return .F.
		EndIf
	EndIf

	NGRAVADOS := FAJUSTAZBX(CAS, AGRAVAR, CLOTE, lMao)

	IF LEN(AGRAVAR) == 0
		IF EMPTY( CLOTE )
			MSGALERT(STR0200 , STR0022) //"Nenhuma data selecionada para geração da minuta."###"Atenção!"
		ENDIF
		//DisarmTransaction()
		RETURN .F.
	ENDIF

	IF EMPTY( CLOTE )
		MSGINFO(STR0143+ALLTRIM(STR(NGRAVADOS))+STR0201 , STR0022)  //"Foram geradas "###" minutas para a AS selecionada."###"Atenção!"
	ELSE
		NTOTMIN += NGRAVADOS
	ENDIF

	IF NGRAVADOS > 0 .OR. ! LMINUTA .or. (!lGeraFPF .and. lMinuta)
		CPARA	:= SUPERGETMV("MV_LOCX057",.F.,"LOLIVEIRA@ITUP.COM.BR")
		EFROM 	:= ALLTRIM(USRRETNAME(__CUSERID)) + " <" + ALLTRIM(USRRETMAIL(__CUSERID)) + ">"
		CTITULO := STR0202 + ALLTRIM(FQ5->FQ5_AS) + ", " + _MV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + STR0203 //"AS No. "###"PROJETO"###" Aceita "

		CMSG	:= CTITULO + "<BR><BR>"
		CMSG	+= STR0086 + USRRETNAME(__CUSERID) + "<BR><BR>" //"Dados informados pelo usuário: "
		CMSG    += STR0046+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0084+ALLTRIM(FQ5->FQ5_DESTIN)+STR0085+ALLTRIM(FQ5->FQ5_NOMCLI)+"<BR><BR><BR>"  //"Data INI/FIM: "###", Obra: "###", Cliente: "
		IF NGRAVADOS > 0
			CMSG    += STR0143+ ALLTRIM(STR(NGRAVADOS)) +STR0204 //"Foram geradas "###" Minutas"
		ENDIF

		CPARA := GETMV("MV_LOCX033",,"")

		IF _LC111ANT //EXISTBLOCK("LC111ANT") 											// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
			LANTACE := EXECBLOCK("LC111ANT",.T.,.T.,{ FQ5->FQ5_AS, CTITULO, CMSG, CLOTE })
		ENDIF

		IF LANTACE
			IF FQ5->(RECLOCK("FQ5",.F.))
				FQ5->FQ5_STATUS := "6"
				FQ5->FQ5_ACEITE := DDATABASE
				FQ5->(MSUNLOCK())
			ENDIF
			IF _LC111ACE //EXISTBLOCK("LC111ACE") 										// --> PONTO DE ENTRADA EXECUTADO APÓS O ACEITE DA AS
				EXECBLOCK("LC111ACE",.T.,.T.,{FQ5->FQ5_AS , CTITULO , CMSG})
			ENDIF
			IF LROMANEIO .AND. ALLTRIM(FQ5->FQ5_TPAS) == "F"
				GERROMAN()
			ENDIF
		ENDIF
	ELSE
		IF EMPTY( CLOTE )
			MSGALERT(STR0205 , STR0022)  //"Não foi gerada nenhuma minuta para a AS selecionada."###"Atenção!"
		ENDIF
	ENDIF

RETURN .T.

/*/{PROTHEUS.DOC} FAJUSTAZBX
ITUP BUSINESS - TOTVS RENTAL
Geração das minutas no aceite da AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025 - revitalizada
/*/
Static Function FAJUSTAZBX(cAS, aGravar, cLote, lMao)
Local aAreaDTQ	:= FQ5->( GETAREA() )
Local nPos
Local nGravados
Local cTipoSE
Local lPula
Local aErrosZBX := {}
Local aExcluir  := {}
Local LC111ZBX  := EXISTBLOCK("LC111ZBX")
Local cFilFP0   := xFilial("FP0")
Local cFilFPF   := xFilial("FPF")

Default cLote   := ""
Default lMao := .F.

	// DSERLOCA-5001
	// Frank em 15/01/25
	// Acrescentar no array aGravar os turnos do tipo diurno/noturno
	// Exceção: sem os sábados, domingos, feriados e sexta especial, o tipo M ignorar
	aGravar := LOCA059Z(aGravar, cAs)

	// Frank em 15/01/25 - DSERLOCA-5001
	// Fazer os ajustes dos horários com base nos turnos
	aGravar := LOCA059M(aGravar)

	FQ5->( dbSetOrder(9) )
	if FQ5->( dbSeek( xFilial("FQ5") + cAS, .T. ) ) .and. FQ5->FQ5_TPAS != "F"

		FMONTAZBX("QRYFPF",cAS)	// MONTA A QUERY
		QRYFPF->(dbGotop())

		While QRYFPF->(!eof())

			nPos := QRYFPF->(ascan(aGravar,{|X| X[1]+dtos(X[2])==FPF_FROTA+dtos(FPF_DATA)}))

			If nPos == 0 // VAI EXCLUIR A MINUTA
				If QRYFPF->(FPF_STATUS$"1,5") // 1=PREVISTA , 2=CONFIRMADA , 3=BAIXADA , 4=ENCERRADA , 5=CANCELADA , 6=MEDIDA
					QRYFPF->(aadd(aExcluir,FPF_RECNO)) // VAI EXCLUIR A MINUTA
				Else
					QRYFPF->(aadd(aErrosZBX,{FPF_FROTA,FPF_AS,FPF_DATA,FPF_DATA,FPF_DATA,FPF_MINUTA,FPF_STATUS,STR0206+FPF_MINUTA+STR0207+DTOC(FPF_DATA)+".",STR0208+FPF_MINUTA+STR0209})) //"EXISTE UMA MINUTA ("###") CONFIRMADA NO DIA "###"ESTORNAR A MINUTA "###" E ACEITAR A AS NOVAMENTE."
				EndIf
			Else
				aGravar[nPos,5] := QRYFPF->FPF_RECNO // 5=GUARDA O RECNO()
			ENDIF

			QRYFPF->( dbSkip() )

		EndDo

	EndIf

	nGravados := 0

	If len(AERROSZBX) == 0 // CRIACAO DA MINUTA

		For nPos := 1 to len(aGravar)

			If aGravar[nPos,5] == 0	// 5=GUARDA O RECNO()

				lPula := .F.

				If left( cAs, 2 ) == "31" // FRETE DE LOCAÇÃO
					cTipoSE := "T"
				Else // SENÃO BUSCA O BEM
					//SIGALOC94-853 - 06/07/2023 - Busca Projeto do Array, pois está gerando pela primeira vez FPF
					cTipoSE := Posicione("FP0",1,cFilFP0 + AllTrim(aGravar[nPos,3]), "FP0_TIPOSE")
				EndIf

				If cTipoSE == "T"

					FPF->( dbSetOrder(5) )	// FPF_FILIAL, FPF_DATA, FPF_FROTA, FPF_MINUTA, R_E_C_N_O_, D_E_L_E_T_
					FPF->( dbSeek( cFilFPF + dtos(aGravar[nPos,2]) + aGravar[nPos,1], .T. ) )

					While !FPF->(eof()) .and. FPF->FPF_FILIAL == cFilFPF .and. FPF->FPF_DATA == aGravar[nPos,2] .and. FPF->FPF_FROTA == aGravar[nPos,1]

						If FPF->FPF_PROJET == aGravar[nPos,3] .and. FPF->FPF_OBRA == aGravar[nPos,4]
							lPula := .T.
							nGravados ++
							Exit
						EndIf

						FPF->( dbSkip() )

					EndDo

				EndIf

				FPA->(dbSetOrder(3))
				FPA->(dbSeek(xFilial("FPA")+aGravar[nPos,8]))
				
				If !lPula .AND. FPF->(RecLock("FPF",.T.)) 

					FPF->FPF_FILIAL := cFilFPF
					FPF->FPF_FROTA  := aGravar[nPos,1]

					//If left( cAS, 2 ) == "06" .or. lMao
					//	FPF->FPF_TIPOSE := "E" // MAO DE OBRA
					//Else
						FPF->FPF_TIPOSE := FPA->FPA_TIPOSE //cTipoSE // POSICIONE("ST9",1,XFILIAL("ST9")+AGRAVAR[NPOS,1], "T9_TIPOSE")
					//EndIf

					FPF->FPF_DATA   := aGravar[nPos,2]
					FPF->FPF_MINUTA := FPROXIMAM()
					FPF->FPF_AS     := cAS
					FPF->FPF_PROJET := aGravar[nPos,3]
					FPF->FPF_OBRA   := aGravar[nPos,4]
					FPF->FPF_STATUS := "1" // 1=PREVISTA,2=CONFIRMADA,3=BAIXADA,4=ENCERRADA,5=CANCELADA,6=MEDIDA
					FPF->FPF_HORAI  := aGravar[nPos, 6]
					FPF->FPF_HORAF  := aGravar[nPos, 7]
					FPF->FPF_EMISSA := dDataBase
					If FPF->(FIELDPOS("FPF_TURNO")) > 0
						FPF->FPF_TURNO  := aGravar[nPos, 9]
					EndIf
					
					nGravados ++
					FPF->(MsUnlock())
					confirmSX8()

					IF LC111ZBX //EXISTBLOCK("LC111ZBX")
						EXECBLOCK("LC111ZBX",.T.,.T., NIL)
					ENDIF

				ENDIF

			Else

				nGravados ++

			EndIf

		Next

		For nPos := 1 to len(aExcluir)

			FPF->(dbGoto(aExcluir[nPos])) // POSICIONA NA MINUTA

			If FPF->(RecLock("FPF",.F.))
				FPF->FPF_DTOCOR := dDataBase
				FPF->(dbDelete()) 
				FPF->(msUnlock())
			EndIf

		next

	Else

		If empty(cLote) .and. MsgYesNo(STR0198) //"Visualiza as inconsistências ?"
			LOCA05924(aErrosZBX,STR0199) // VISUALIZA OS ERROS //"INCONSISTÊNCIAS"
			Return(nGravados)
		EndIf

	EndIf

	FQ5->( RestArea( aAreaDTQ ) )

Return (nGravados)

/*/{PROTHEUS.DOC} FMONTAZBX
ITUP BUSINESS - TOTVS RENTAL
Montagem da query usada no aceite da minuta
@TYPE FUNCTION
/*/
STATIC FUNCTION FMONTAZBX(CALIASQRY,CAS)
LOCAL AESTRU
Local CQRY := ""
LOCAL NPOS := 0
Local _cCampos := ""
Local aBindParam := {}

	_cCampos := "FPF_FROTA,FPF_AS,FPF_DATA,FPF_STATUS,FPF_MINUTA,FPF_HORAI,FPF_HORAF,FPF_FILIAL,FPF_RECNO"

	CQRY += " SELECT FPF_FROTA , FPF_AS    , FPF_DATA   , FPF_STATUS , FPF_MINUTA , "
	CQRY +=        " FPF_HORAI , FPF_HORAF , FPF_FILIAL , R_E_C_N_O_ FPF_RECNO "
	CQRY += " FROM " + RETSQLNAME("FPF") + " ZBX"
	CQRY += " WHERE  ZBX.D_E_L_E_T_=''"
	CQRY +=   " AND  FPF_FILIAL = '" + XFILIAL("FPF") + "'"
	CQRY +=   " AND  FPF_AS     = ? "
	Aadd(aBindParam, CAS )
	CQRY := CHANGEQUERY(CQRY)
	IF !SELECT(CALIASQRY) == 0
		(CALIASQRY)->(DBCLOSEAREA())
	ENDIF
	MPSysOpenQuery(CQRY,CALIASQRY,,,aBindParam)
	dbSelectArea(CALIASQRY)

	AESTRU := FPF->(DBSTRUCT())
	FOR NPOS:=1 TO LEN(AESTRU)
		IF AESTRU[NPOS][2]<>"C" .AND. AESTRU[NPOS][2]<>"M"
			//IF (CALIASQRY)->(!TYPE(AESTRU[NPOS][1])=="U")
			If alltrim(AESTRU[NPOS][1]) $ _cCampos
				TCSETFIELD(CALIASQRY,AESTRU[NPOS][1],AESTRU[NPOS][2],AESTRU[NPOS][3],AESTRU[NPOS][4])
			ENDIF
		ENDIF
	NEXT NPOS

RETURN NIL

/*/{PROTHEUS.DOC} FPROXIMAM
ITUP BUSINESS - TOTVS RENTAL
Geração do código da minuta
@TYPE FUNCTION
/*/
STATIC FUNCTION FPROXIMAM()
LOCAL AAREA    := GETAREA()
LOCAL AAREAZBX := FPF->(GETAREA())
LOCAL CRET

	FPF->( DBSETORDER(2) ) 			// FPF_FILIAL+FPF_MINUTA

	WHILE .T.
		CRET := GETSXENUM("FPF","FPF_MINUTA")
		IF ! FPF->( DBSEEK(XFILIAL("FPF")+CRET) )
			EXIT
		ELSE
			CONFIRMSX8()
		ENDIF
	ENDDO

	RESTAREA(AAREAZBX)
	RESTAREA(AAREA)

RETURN CRET

/*/{PROTHEUS.DOC} LOCA05924
ITUP BUSINESS - TOTVS RENTAL
Visualização dos erros na geração das minutas
@TYPE FUNCTION
/*/
FUNCTION LOCA05924(AERROS,CTITJAN)
LOCAL NPOS , ACOLS , ACOLS0 , AHEADER , BHEADER , ODLG , ABUTTONS:={}
LOCAL NSTATUS , ASTATUS:=LOCA00559()    // MONTA OS STATUS // /DSERLOCA-3350 - Rossana - 24/06/2024

PRIVATE OBROWSE

	ACOLS:={}
	FOR NPOS:=1 TO LEN(AERROS)
		ACOLS0:={}
		AADD(ACOLS0,AERROS[NPOS,1])
		AADD(ACOLS0,AERROS[NPOS,2])
		AADD(ACOLS0,AERROS[NPOS,3])
		AADD(ACOLS0,AERROS[NPOS,4])
		AADD(ACOLS0,AERROS[NPOS,5])
		AADD(ACOLS0,AERROS[NPOS,6])
		AADD(ACOLS0,AERROS[NPOS,8])  				// INCONSISTÊNCIA
		AADD(ACOLS0,AERROS[NPOS,9])  				// SOLUÇÃO
		AADD(ACOLS0,AERROS[NPOS,7])  				// STATUS
		AADD(ACOLS,ACOLS0)
	NEXT NPOS

	AHEADER := {}
	BHEADER := "{||ACOLS[OBROWSE:AT(),7]}";AADD(AHEADER,{OEMTOANSI(STR0210),&BHEADER,"C","@X",1,40,0}) //"Inconsistência"
	BHEADER := "{||ACOLS[OBROWSE:AT(),8]}";AADD(AHEADER,{OEMTOANSI(STR0211       ),&BHEADER,"C","@X",1,40,0}) //"Solução"
	BHEADER := "{||ACOLS[OBROWSE:AT(),1]}";AADD(AHEADER,{OEMTOANSI(STR0122   ),&BHEADER,"C","@!",1,10,0}) //"Equipamento"
	BHEADER := "{||ACOLS[OBROWSE:AT(),2]}";AADD(AHEADER,{OEMTOANSI(STR0212        ),&BHEADER,"C","@!",1,10,0}) //"Nro AS"
	BHEADER := "{||ACOLS[OBROWSE:AT(),3]}";AADD(AHEADER,{OEMTOANSI(STR0213        ),&BHEADER,"D","@E",1,08,0}) //"Início"
	BHEADER := "{||ACOLS[OBROWSE:AT(),4]}";AADD(AHEADER,{OEMTOANSI(STR0214           ),&BHEADER,"D","@E",1,08,0}) //"Fim"
	BHEADER := "{||ACOLS[OBROWSE:AT(),5]}";AADD(AHEADER,{OEMTOANSI(STR0215          ),&BHEADER,"D","@E",1,08,0}) //"Data"
	BHEADER := "{||ACOLS[OBROWSE:AT(),6]}";AADD(AHEADER,{OEMTOANSI(STR0216        ),&BHEADER,"C","@!",1,10,0}) //"Minuta"
	BHEADER := "{||ACOLS[OBROWSE:AT(),9]}";AADD(AHEADER,{OEMTOANSI(STR0217        ),&BHEADER,"C","@!",1,01,0}) //"Status"

	DEFINE MSDIALOG ODLG FROM 100,0 TO 500,1000 TITLE OEMTOANSI(CTITJAN) OF OMAINWND PIXEL
		OBROWSE := FWBROWSE():NEW()
		OBROWSE:SETDATAARRAY()
		OBROWSE:SETARRAY(ACOLS)
		FOR NSTATUS:=1 TO LEN(ASTATUS)
			OBROWSE:ADDLEGEND(ASTATUS[NSTATUS,3],ASTATUS[NSTATUS,1],ASTATUS[NSTATUS,2])
		NEXT
		OBROWSE:SETCOLUMNS(AHEADER)
		OBROWSE:SETOWNER(ODLG)
		OBROWSE:DISABLEREPORT()
		OBROWSE:DISABLECONFIG()
		OBROWSE:ACTIVATE()
	ACTIVATE MSDIALOG ODLG CENTERED ON INIT ENCHOICEBAR(ODLG,{|| ODLG:END() },{|| ODLG:END() },,ABUTTONS)

RETURN

/*/{PROTHEUS.DOC} GERROMAN
@DESCRIPTION GERACAO DE ROMANEIO.
@TYPE FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   10/08/2016
@VERSION 1.0
/*/
STATIC FUNCTION GERROMAN()
LOCAL _AAREAOLD := GETAREA()
LOCAL _AAREAZUC := FQ7->(GETAREA())
LOCAL _AAREASZ0 := FQ2->(GETAREA())
LOCAL _CQUERY   := ""
LOCAL _CNUMROM  := ""

	// --> BUSCA O ULTIMO NUMERO DE ROMANEIO.
	_CQUERY := " SELECT MAX(FQ2_NUM) NUMROM"
	_CQUERY += " FROM " + RETSQLNAME("FQ2") + " SZ0"
	_CQUERY += " WHERE  FQ2_FILIAL = '" + XFILIAL("FQ2") + "'"
	_CQUERY += "   AND  SZ0.D_E_L_E_T_ = ' '"
	IF SELECT("TRBFQ2") > 0
		TRBFQ2->(DBCLOSEAREA())
	ENDIF
	_CQUERY := CHANGEQUERY(_CQUERY)
	TCQUERY _CQUERY NEW ALIAS "TRBFQ2"

	IF TRBFQ2->(EOF())
		_CNUMROM := STRZERO(1,GETSX3CACHE("FQ2_NUM","X3_TAMANHO"))
	ELSE
		_CNUMROM := STRZERO(VAL(TRBFQ2->NUMROM)+1,GETSX3CACHE("FQ2_NUM","X3_TAMANHO"))
	ENDIF

	TRBFQ2->(DBCLOSEAREA())

	IF ALLTRIM(FQ5->FQ5_TPAS) == "F"
		DBSELECTAREA("FQ7")
		FQ7->(DBSETORDER(3))				// FQ7_FILIAL + FQ7_VIAGEM
		IF FQ7->(DBSEEK(XFILIAL("FQ7") + FQ5->FQ5_VIAGEM))
			DBSELECTAREA("FQ2")
			FQ2->(DBSETORDER(3))			// FQ2_FILIAL + FQ2_ASF + FQ2_NUM
			IF FQ2->(!DBSEEK(XFILIAL("FQ2") + FQ5->FQ5_AS))
				IF RECLOCK("FQ2",.T.)
					FQ2->FQ2_FILIAL  := XFILIAL("FQ2")
					FQ2->FQ2_NUM	    := _CNUMROM
					FQ2->FQ2_PROJET  := FQ5->FQ5_SOT
					FQ2->FQ2_OBRA    := FQ5->FQ5_OBRA
					FQ2->FQ2_PEDIDO  := FQ5->FQ5_SOT
					FQ2->FQ2_ASF     := FQ5->FQ5_AS
					FQ2->FQ2_VIAGEM  := FQ5->FQ5_VIAGEM
					FQ2->FQ2_TPROMA := FQ7->FQ7_TPROMA
					FQ2->FQ2_CLIENT := FQ5->FQ5_CODCLI
					FQ2->FQ2_LOJA    := FQ5->FQ5_LOJA
					FQ2->FQ2_TIPOVE	:= FQ7->FQ7_X5COD
					FQ2->FQ2_PTIPVE := FQ7->FQ7_DESCRI
					FQ2->FQ2_OBS		:= FQ7->FQ7_OBS
					FQ2->FQ2_NOMCLI  := ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1") + FQ5->FQ5_CODCLI + FQ5->FQ5_LOJA,"A1_NOME"))
					FQ2->(MSUNLOCK())

					// GUARDAR NUMERO DO ROMANEIO NO NOVO CAMPO
					FQ5->(RECLOCK("FQ5",.F.))
					FQ5->FQ5_XROMAN := FQ2->FQ2_NUM
					FQ5->(MSUNLOCK())
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	FQ2->(RESTAREA( _AAREASZ0 ))
	FQ7->(RESTAREA( _AAREAZUC ))
	RESTAREA( _AAREAOLD )

RETURN

/*/{PROTHEUS.DOC} LOCA05925
ITUP BUSINESS - TOTVS RENTAL
Romaneio
@TYPE FUNCTION
/*/
FUNCTION LOCA05925(_CASF , LMSROTAUTO, _CFILAUTO)  // FRANK 06/10/2020 INSERIDO A FILIAL DA REMESSA PARA O CASO DE SER AUTOMATICO
LOCAL _AAREAOLD  := GETAREA()
LOCAL _AAREADTQ  := FQ5->(GETAREA())
LOCAL _AAREASZ0  := FQ2->(GETAREA())
LOCAL _AAREASZ1  := FQ3->(GETAREA())
LOCAL _AAREAZUC  := FQ7->(GETAREA())
LOCAL _AAREAST9  := ST9->(GETAREA())
LOCAL _AAREASF2  := SF2->(GETAREA())
LOCAL _CERRO	 := ""
LOCAL _CQUERY	 := ""
LOCAL _CNUMROM   := ""
LOCAL CMV_LOCX014 := ""
LOCAL LUMAOPCAO  := .F.
LOCAL LMARCAITEM := .T.
LOCAL OOK        := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL ONO        := LOADBITMAP(GETRESOURCES(),"LBNO")
LOCAL BACAO      := NIL
LOCAL OVINCZAG
LOCAL OCANC
LOCAL _NOPC      := 0
LOCAL NINICIAL   := 0
LOCAL _NQTD		 := 0 // CONTROLE DO SALDO NA SZ1
LOCAL _NENV      := 0 // QUANTIDADE ENVIADA PELA NOTA DE SAIDA
LOCAL _NRET      := 0 // QUANTIDADE JA PROGRAMADA EM ROMANEIO
LOCAL _LFORCA    := .F. // FORCA HABILITAR O BOTACO DE VINCULAR - FRANK 26/10/20
Local lLOCX304	 := SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador será o utilizado como cliente da nota fiscal de remessa,
Local lLOCA59E   := EXISTBLOCK("LOCA59E")
Local lLOCA59F   := EXISTBLOCK("LOCA59F")
Local lLC059FTSL := EXISTBLOCK("LC059FTSL")
Local nCol
Local ORETX
Local cTitpe
Local aBindParam := {}

PRIVATE _AARRAY  := {}
PRIVATE _ABACK   := {} // USADO PARA FAZER UM BACKUP DOS ROMANEIOS DE RETORNO PARCIAL. FRANK 15/10/20
PRIVATE OLISTBOX


DEFAULT _CASF 		:= FQ5->FQ5_AS
DEFAULT	LMSROTAUTO 	:= .F.
DEFAULT _CFILAUTO	:= CFILANT

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CMV_LOCX014 := LOCA00189()
	ELSE
		CMV_LOCX014 := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	DBSELECTAREA("FQ5")
	FQ5->(DBSETORDER(9))
	IF FQ5->(DBSEEK(XFILIAL("FQ5") + _CASF))

		// Controle de acesso por usar uma demanda - Frank em 23/04/2025
		If !LOCA059AROM() // Verifica se a A.S.F. já está associada a um Romaneio da Gestão de Expedição
			Return
		EndIf

		IF FQ5->FQ5_STATUS <> "6" .OR. FQ5->FQ5_TPAS <> "F"
			_CERRO := STR0218 //"ASF não está aceita, ou não é do tipo frete!"
		ENDIF

		DBSELECTAREA("FQ2")
		FQ2->(DBSETORDER(3))			// FQ2_FILIAL + FQ2_ASF + FQ2_NUM
		IF !FQ2->(DBSEEK(XFILIAL("FQ2") + _CASF)) .AND. EMPTY(_CERRO)
			_CERRO := STR0219 //"Romaneio não encontrado!"

			DBSELECTAREA("FQ7")
			FQ7->(DBSETORDER(3))
			IF FQ7->(DBSEEK(XFILIAL("FQ7") + FQ5->FQ5_VIAGEM))

				FQ2->(DBSETORDER(1))	// FQ2_FILIAL + FQ2_NUM
				_CNUMROM	:= GETSXENUM("FQ2","FQ2_NUM")
				WHILE .T.
					IF FQ2->( DBSEEK(XFILIAL("FQ2") + _CNUMROM) )
						CONFIRMSX8()
						_CNUMROM := GETSXENUM("FQ2","FQ2_NUM")
						LOOP
					ELSE
						EXIT
					ENDIF
				ENDDO

				ROLLBACKSXE()

				FQ2->(DBSETORDER(3))	// FQ2_FILIAL + FQ2_ASF + FQ2_NUM

				IF RECLOCK("FQ2",.T.)
					FQ2->FQ2_FILIAL  := XFILIAL("FQ2")
					FQ2->FQ2_NUM	    := _CNUMROM
					FQ2->FQ2_PROJET  := FQ5->FQ5_SOT
					FQ2->FQ2_OBRA    := FQ5->FQ5_OBRA
					FQ2->FQ2_ASF     := _CASF
					FQ2->FQ2_VIAGEM  := FQ5->FQ5_VIAGEM
					FQ2->FQ2_TPROMA := FQ7->FQ7_TPROMA
					FQ2->FQ2_CLIENT := FQ5->FQ5_CODCLI
					FQ2->FQ2_LOJA    := FQ5->FQ5_LOJA
					FQ2->FQ2_NOMCLI  := ALLTRIM(POSICIONE("SA1" , 1 , XFILIAL("SA1") + FQ5->FQ5_CODCLI + FQ5->FQ5_LOJA , "A1_NOME"))
					FQ2->(MSUNLOCK())
					_CERRO := ""

					// GUARDAR NUMERO DO ROMANEIO NO NOVO CAMPO
					FQ5->(RECLOCK("FQ5",.F.))
					FQ5->FQ5_XROMAN := FQ2->FQ2_NUM
					FQ5->(MSUNLOCK())
				ENDIF
			ENDIF
		ENDIF

	ELSE
		_CERRO := "ASF " + ALLTRIM(_CASF) + STR0220 //" Não encontrada!"
	ENDIF

	// VERIFICAR SE É A VIAGEM DE RETORNO - FRANK - 15/10/20
	IF EMPTY(_CERRO)
		FQ7->(DBSETORDER(3)) // FILIAL + VIAGEM
		IF !FQ7->(DBSEEK(XFILIAL("FQ7")+FQ5->FQ5_VIAGEM))
			_CERRO := STR0221 //"Viagem não localizada no conjunto transportador."
		ENDIF
	ENDIF

	IF EMPTY(_CERRO)

		/*
			PROCEDIMENTO PARA SEPARAÇÃO DO QUE É REMESSA E RETORNO DE LOCAÇÃO.
			ESSE PROCEDIMENTO FOI NECESSÁRIO CRIAR POIS A SELEÇÃO DOS ITENS DE RETORNO SERÁ FEITO PELO PEDIDO COMERCIAL.
		*/
		aBindParam := {}
		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			//_CQUERY     += "  SELECT DISTINCT FQ7_LCCORI, FQ7_LCLORI, FQ7_LCCDES, FQ7_LCLDES, FPA_PROJET PROJETO , FPA_GRUA CODBEM , ISNULL(T9_NOME,FPA_DESGRU) BEM , "
			_CQUERY     += "  SELECT DISTINCT F2_CLIENTE, F2_LOJA, FPA_PROJET PROJETO , FPA_GRUA CODBEM , COALESCE(T9_NOME,FPA_DESGRU) BEM , "
		Else
			_CQUERY     += "  SELECT  FPA_PROJET PROJETO , FPA_GRUA CODBEM , COALESCE(T9_NOME,FPA_DESGRU) BEM , "
		EndIf
		_CQUERY     += "          COALESCE(T6_NOME,FPA_DESGRU) FAMILIA , FPA_SEQGRU , FPA_AS , FPA_PRODUT, FPA_QUANT, FPA_FILREM, FPA_FILEMI, FPA_OBRA, ZAG.R_E_C_N_O_ AS REG, "
		_CQUERY     += "   FPA_FILREM, FPA_NFREM, FPA_SERREM, FPA_ITEREM "
		_CQUERY     += "  FROM " + RETSQLNAME("FPA")+" ZAG "
		_CQUERY     += "  	      INNER JOIN " + RETSQLNAME("FQ5") + " DTQ ON  DTQ.FQ5_AS     = ZAG.FPA_AS "
		_CQUERY     += "                                                   AND DTQ.FQ5_STATUS = '6' "
		if FQ5->(FieldPos("FQ5_DEMAND")) > 0 // Se AS já estiver numa demanda não pode incluir no Romaneio
			_CQUERY     += "                                                   AND DTQ.FQ5_DEMAND = ' ' "
		endif
		_CQUERY     += "                                                   AND DTQ.FQ5_STATUS = '6' "
		
		_CQUERY     += "                                                   AND DTQ.D_E_L_E_T_ = '' "
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST9") + " ST9 ON  ST9.T9_CODBEM  = ZAG.FPA_GRUA "
		_CQUERY     += "  	                                               AND ST9.D_E_L_E_T_ = '' "
		_CQUERY     += "  	      LEFT  JOIN " + RETSQLNAME("ST6") + " ST6 ON  ST6.T6_CODFAMI = ST9.T9_CODFAMI "
		_CQUERY     += "  	                                               AND ST6.D_E_L_E_T_ = '' "
		If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
			_CQUERY     += "  	      LEFT JOIN " + RETSQLNAME("FQ7") + " FQ7 "
			_CQUERY     += "  	      	ON FQ7_FILIAL = ? "
			Aadd( aBindParam, FQ5->FQ5_FILORI)
			_CQUERY     += "  	     	AND FQ7.D_E_L_E_T_ = ' ' "
			_CQUERY     += "  	      	AND FQ7_PROJET = FPA_PROJET "
			_CQUERY     += "  	      	AND FPA_OBRA = FPA_OBRA "
			_CQUERY     += "  	      	AND FQ7_SEQGUI = FPA_SEQGRU "
			_CQUERY     += "  	      LEFT JOIN " + RETSQLNAME("SF2") + " SF2 "
			_CQUERY     += "  	      	ON F2_FILIAL = FPA_FILREM "
			_CQUERY     += "  	      	AND F2_DOC = FPA_NFREM "
			_CQUERY     += "  	      	AND F2_SERIE = FPA_SERREM "
			_CQUERY     += "  	      	AND SF2.D_E_L_E_T_ = ' ' "
		EndIf
		_CQUERY     += " WHERE    ZAG.FPA_FILIAL =  ? "
		Aadd( aBindParam, FQ5->FQ5_FILORI)
		_CQUERY     += "   AND    ZAG.FPA_PROJET =  ? "
		Aadd( aBindParam, FQ5->FQ5_SOT)
		_CQUERY     += "   AND    ZAG.FPA_OBRA   =  ? "
		Aadd( aBindParam, FQ5->FQ5_OBRA)
		_CQUERY     += "   AND    ZAG.FPA_AS     <> '' "
		// alterado por Frank em 28/09/21 para aceitar tambem os itens substituidos
		_CQUERY     += "   AND    (ZAG.FPA_TIPOSE =  'L' OR  ZAG.FPA_TIPOSE =  'S')"
		_CQUERY     += "   AND    ZAG.D_E_L_E_T_ =  '' "
		IF     (FQ2->FQ2_TPROMA == "0")				// --> REMESSA
			_CQUERY += "   AND    ZAG.FPA_NFREM  =  '' "
		ELSEIF (FQ2->FQ2_TPROMA == "1")				// --> RETORNO
			_CQUERY += "   AND    ZAG.FPA_NFREM  <> '' "
			//_CQUERY += "   AND    ZAG.FPA_DTPRRT <> '' "                                                                        FRANK REMOVEU EM 02/11/20
			_CQUERY += "   AND    ZAG.FPA_NFRET  =  '' "
		ELSE
			RETURN
		ENDIF

		//IF FQ7->FQ7_TPROMA == "0" // VIAGEM DE IDA	removido por frank em 03/01/2022
		_CQUERY += " AND NOT EXISTS( SELECT * "
		_CQUERY += " FROM " + RETSQLNAME("FQ2") + " SZ0 "
		_CQUERY += " INNER JOIN " + RETSQLNAME("FQ3") + " SZ1 ON  SZ1.FQ3_FILIAL  = FQ2_FILIAL "
		_CQUERY += " AND SZ1.FQ3_NUM     = FQ2_NUM "
		_CQUERY += " AND SZ1.FQ3_ASF     = FQ2_ASF "
		_CQUERY += " AND SZ1.FQ3_PROJET  = FQ2_PROJET "
		_CQUERY += " AND SZ1.FQ3_OBRA    = FQ2_OBRA "
		_CQUERY += " AND SZ1.FQ3_AS      = FPA_AS "
		_CQUERY += " AND SZ1.FQ3_NFRET   = '' "  // DSERLOCA - 3200 - Rossana - 04/06/2024
		_CQUERY += " AND SZ1.D_E_L_E_T_  = '' "
		_CQUERY += " WHERE  SZ0.FQ2_FILIAL  = FPA_FILIAL "
		_CQUERY     += " AND  SZ0.FQ2_TPROMA = ? "
		Aadd( aBindParam, FQ2->FQ2_TPROMA)
		_CQUERY     += " AND  SZ0.D_E_L_E_T_ = '') "

		IF SELECT("TRBFPA") > 0
			TRBFPA->(DBCLOSEAREA())
		ENDIF

		_CQUERY := CHANGEQUERY(_CQUERY)
		MPSysOpenQuery(_CQUERY,"TRBFPA",,,aBindParam)

		IF TRBFPA->(EOF())
			AADD(_AARRAY , {.F. , "" , "" , "" , "" , "", 0,"","","",0,0}) // FRANK 06/10/2020 CONTROLE POR FILIAL
		ELSE

			If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
				cCliOri := LOCA05931("FQ2_CLIFAT") + LOCA05931("FQ2_LOJFAT")
			EndIf

			WHILE TRBFPA->(!EOF())

				//verifica se o cliente é o mesmo no conjunto transportador SOMENTE no retorno
				If lLOCX304 .And. FQ2->FQ2_TPROMA == "1"
					//Se for diferente pula
					lForca := .F.
					If lLOCA59E
						lForca := EXECBLOCK("LOCA59E",.T.,.T.,{})
					EndIf
					If LOCA05931("FQ2_CLIFAT") + LOCA05931("FQ2_LOJFAT") <> TRBFPA->( F2_CLIENTE + F2_LOJA ) .or. lForca
						TRBFPA->(DBSKIP())
						Loop
					EndIf
				EndIf
				IF FQ7->FQ7_TPROMA == "1" // VIAGEM DE RETORNO FRANK - 15/10/20
					// VALIDAR A QUANTIDADE LIBERADA POR ROMANEIO - FRANK 14/10/2020
					_NQTD := 0

					// ENCONTRAR A QUANTIDADE ENVIADA (NOTA FISCAL DE SAIDA)
					_NENV := 0
					IF !EMPTY(TRBFPA->FPA_NFREM) // Rossana - DSERLOCA 3836 - acessar SC6 pela SD2 - item da nota pode não ser o mesmo do pedido
						aBindParam := {}
						_cQuery :=  "SELECT C6_QTDVEN
						_cQuery += " FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SD2")+" SD2 "
						_cQuery += " WHERE SC6.D_E_L_E_T_ = ' '"
						_cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
						_cQuery += "   AND SD2.D2_FILIAL = ?"
						Aadd(aBindParam, TRBFPA->FPA_FILREM )
						_cQuery += "   AND SD2.D2_DOC = ?"
						Aadd(aBindParam, TRBFPA->FPA_NFREM )
						_cQuery += "   AND SD2.D2_SERIE = ?"
						Aadd(aBindParam, TRBFPA->FPA_SERREM )
						_cQuery += "   AND SD2.D2_ITEM = ?"
						Aadd(aBindParam, TRBFPA->FPA_ITEREM )
						_cQuery += "   AND SC6.C6_FILIAL = SD2.D2_FILIAL "
						_cQuery += "   AND SC6.C6_NUM    = SD2.D2_PEDIDO "
						_cQuery += "   AND SC6.C6_ITEM   = SD2.D2_ITEMPV "

						_CQUERY := CHANGEQUERY(_CQUERY)
						MPSysOpenQuery(_CQUERY,"TRBSC6",,,aBindParam)


						if TRBSC6->(!Eof())
							_NENV := TRBSC6->C6_QTDVEN
						endif

					ENDIF

					_NRET := 0

					if FWSIXUtil():ExistIndex( "FQZ" , "3" )
						FQZ->(DBSETORDER(3))
						FQZ->(DBSEEK(XFILIAL("FQZ")+TRBFPA->FPA_AS))
						WHILE !FQZ->(EOF()) .AND. FQZ->FQZ_FILIAL == XFILIAL("FQZ") .AND. FQZ->FQZ_AS== TRBFPA->FPA_AS

								IF FQZ->FQZ_MSBLQL == "2"

									_NRET += FQZ->FQZ_QTD //TRBFPA->FPA_QUANT

								ENDIF

							FQZ->(DBSKIP())
						ENDDO
					else
						FQZ->(DBSETORDER(2))
						FQZ->(DBSEEK(XFILIAL("FQZ")+TRBFPA->PROJETO))
						WHILE !FQZ->(EOF()) .AND. FQZ->FQZ_FILIAL == XFILIAL("FQZ") .AND. FQZ->FQZ_PROJET == TRBFPA->PROJETO
							IF FQZ->FQZ_OBRA == TRBFPA->FPA_OBRA
								IF FQZ->FQZ_MSBLQL == "2"
									IF ALLTRIM(FQZ->FQZ_AS) == ALLTRIM(TRBFPA->FPA_AS)
										_NRET += FQZ->FQZ_QTD //TRBFPA->FPA_QUANT
									ENDIF
								ENDIF
							ENDIF

							FQZ->(DBSKIP())
						ENDDO
					endif

					_NQTD := _NENV - _NRET

				ELSE
					_NQTD := TRBFPA->FPA_QUANT
				ENDIF

				IF TRBFPA->FPA_QUANT >= _NQTD .OR. FQ7->FQ7_TPROMA == "1" // CONTROLE DA QUANTIDADE FRANK 14/10/2020

					SB1->(DBSETORDER(1))
					SB1->(DBSEEK(XFILIAL("SB1")+TRBFPA->FPA_PRODUT))

					IF EMPTY(TRBFPA->CODBEM) .AND. ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CMV_LOCX014)
						AADD(_AARRAY , {.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , ALLTRIM(SB1->B1_DESC) , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS, TRBFPA->FPA_QUANT, TRBFPA->FPA_PRODUT, SB1->B1_DESC, TRBFPA->FPA_FILEMI, _NQTD, TRBFPA->REG	})
					ELSE
						AADD(_AARRAY , {.F. , TRBFPA->FAMILIA , TRBFPA->CODBEM , TRBFPA->BEM           , TRBFPA->FPA_SEQGRU , TRBFPA->FPA_AS, TRBFPA->FPA_QUANT, TRBFPA->FPA_PRODUT, SB1->B1_DESC, TRBFPA->FPA_FILEMI, _NQTD, TRBFPA->REG})
					ENDIF

					IF FQ7->FQ7_TPROMA == "0"
						_AARRAY[LEN(_AARRAY)][1] := .T.
						_LFORCA := .T.
					ELSE
						If !lLOCX304
							_AARRAY[LEN(_AARRAY)][1] := .T.
							_LFORCA := .T.
						EndIf
					ENDIF

				ENDIF

				TRBFPA->(DBSKIP())
			ENDDO
		ENDIF

		lForca := .F.
		If lLOCA59F
			lForca := EXECBLOCK("LOCA59F",.T.,.T.,{})
		EndIf
		If Len(_AARRAY) == 0 .or. lForca
			AADD(_AARRAY , {.F. , "" , "" , "" , "" , "", 0,"","","",0,0})
		EndIf

		_ABACK := aClone(_AARRAY) // BACKUP ANTES DE INFORMAR OS ROMANEIOS PARCIAIS - FRANK 15/10/20

		IF !LMSROTAUTO
			DEFINE MSDIALOG ODLG1 TITLE STR0222 FROM 0,0 TO 25,86 OF OMAINWND //"Vínculo frete X equipamento"
				@ 1.5 , .7 LISTBOX OLISTBOX FIELDS ;
						HEADER  " " , STR0223 , STR0224 , STR0225 , STR0226 , "AS", STR0227,STR0228,STR0229,STR0230,STR0231,STR0128 SIZE 330,147 ;  //"Família"###"Cód. bem"###"Bem"###"Sequência"###"Quantidade"###"Cód.prod"###"Desc.prod"###"Fil.remessa"###"Qtd.ret"###"Registro"
						ON DBLCLICK (_AARRAY := FMARCAITM(OLISTBOX:NAT,_AARRAY,LUMAOPCAO,LMARCAITEM) , IIF((EMPTY(_AARRAY[OLISTBOX:NAT][4]) .OR. !FVERARRY(_AARRAY)) , OVINCZAG:DISABLE() , OVINCZAG:ENABLE()) , ;
						IIF(BACAO==NIL , , EVAL(BACAO)) , OLISTBOX:REFRESH())

				OLISTBOX:SETARRAY(_AARRAY)
				OLISTBOX:BLINE := { || { IIF(_AARRAY[OLISTBOX:NAT][1],OOK,ONO) , ;
											_AARRAY[OLISTBOX:NAT][2]          , ;
											_AARRAY[OLISTBOX:NAT][3]          , ;
											_AARRAY[OLISTBOX:NAT][4]          , ;
											_AARRAY[OLISTBOX:NAT][5]          , ;
											_AARRAY[OLISTBOX:NAT][6]          , ;
											_AARRAY[OLISTBOX:NAT][7]          , ;
											_AARRAY[OLISTBOX:NAT][8]          , ;
											_AARRAY[OLISTBOX:NAT][9]          , ;
											_AARRAY[OLISTBOX:NAT][10]         , ;
											_AARRAY[OLISTBOX:NAT][11]         , ;
											_AARRAY[OLISTBOX:NAT][12]         } }

				@ 172, 7 BUTTON OVINCZAG PROMPT STR0232 SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 1,ODLG1:END())  //"Vincular"
				OVINCZAG:DISABLE()
				IF _LFORCA
					OVINCZAG:ENABLE()
				ENDIF
				@ 172,57 BUTTON OCANC    PROMPT STR0132 SIZE 45,12 OF ODLG1 PIXEL ACTION (_NOPC := 0,ODLG1:END()) //"Cancelar"
				IF FQ7->FQ7_TPROMA == "1" // VIAGEM DE RETORNO - FRANK 15/10/20 - BOTAO PARA RETORNO PARCIAL
					@ 172,107 BUTTON ORETP   PROMPT STR0233  SIZE 45,12 OF ODLG1 PIXEL ACTION (RETPARX(OLISTBOX:NAT)) //"Ret.parcial"
				ENDIF

				OLISTBOX:bheaderclick := {|| LOCA059T() }

				// Ponto de entrada para auxilio na selecao dos registros
				If lLC059FTSL
					If FQ7->FQ7_TPROMA == "1"
						nCol := 157
					Else
						nCol := 107
					EndIF
					cTitpe := EXECBLOCK("LC059FTSL",.T.,.T.,{"2","Seleção",FQ7->FQ7_TPROMA})
					@ 172,nCol BUTTON ORETX PROMPT cTitpe  SIZE 45,12 OF ODLG1 PIXEL ACTION (EXECBLOCK("LC059FTSL",.T.,.T.,{"1","Seleção",FQ7->FQ7_TPROMA}))
				EndIF

			ACTIVATE MSDIALOG ODLG1 CENTERED
		ELSE
			FOR NINICIAL := 1 TO LEN(_AARRAY)
				IF _AARRAY[NINICIAL][10] == _CFILAUTO // FRANK 06/10/2020 TRATAMENTO DA FILIAL DE REMESSA
					_AARRAY[NINICIAL][1]:= .T.	// SE FOR ROTINA AUTOMATICA TODOS OS ITENS SERÃO VINCULADOS
				ENDIF
			NEXT NINICIAL
			_NOPC := 1
		ENDIF
		IF _NOPC == 1
			PROCESSA({|| FGERASZ1(_CASF) } , STR0234 , STR0235 , .T.)  //"Gravando no Romaneio..."###"Aguarde..."
		ENDIF

	ELSE
		MSGALERT(_CERRO , STR0022)  //"Atenção!"
	ENDIF

	IF SELECT("TRBFPA")
		TRBFPA->(DBCLOSEAREA())
	EndIF

	RESTAREA( _AAREAST9 )
	RESTAREA( _AAREAZUC )
	RESTAREA( _AAREASZ1 )
	RESTAREA( _AAREASZ0 )
	RESTAREA( _AAREADTQ )
	RESTAREA( _AAREAOLD )
	RESTAREA( _AAREASF2 )

RETURN IIF(EMPTY(_CERRO) , .T. , .F.)

/*/{PROTHEUS.DOC} FGERASZ1
ITUP BUSINESS - TOTVS RENTAL
TELA PARA VINCULAR UM EQUIPAMENTOS AO FRETE, NA ROTINA DE ROMANEIO
@TYPE FUNCTION
/*/
STATIC FUNCTION FGERASZ1(_CASF)
Local nRecFPA := 0
Local nTotFQ3 := 0
Local nOrdFQ5 := RetOrder("FQ5","FQ5_FILIAL+FQ5_VIAGEM")
Local nPrcFPA := 0 //FPA_PRCUNI
Local nQtdFPA := 0 //FPA_QUANT
Local nBrtFPA := 0 //FPA_VLBRUT
Local nVrhFPA := 0 //FPA_VRHOR
Local nDesFPA := 0 //FPA_PDESC
Local nPAcFPA := 0 //FPA_PACRES
Local nAcrFPA := 0 //FPA_ACRESC

Local cPrjFPA := ""
Local cObrFPA := ""
Local cSeqFPA := ""
Local cTipFPA := ""
Local cNasFPA := ""
Local cSegFPA := ""
Local cViaFQ5 := ""

Local cFldFPA := "FPA_NFREM/FPA_DNFREM/FPA_NFENT/FPA_DNFENT/FPA_PEDIDO/FPA_FILREM/FPA_SEREM/FPA_ITEREM" //SUPERGETMV("MV_LCNFP59",.F.,"FPA_NFREM/FPA_DNFREM/FPA_NFENT/FPA_DNFENT/FPA_PEDIDO/FPA_FILREM/FPA_SEREM/FPA_ITEREM") //Não replica os campos da tabela FPA
Local cFldFQ5 := "" //SUPERGETMV("MV_LCNFQ59",.F.,"") //Não replica os campos da tabela FQ5

Local cMaxFPA := ""
LOCAL _CQUERY := ""
LOCAL _CMSG   := ""
LOCAL _NX	  := 1
LOCAL _NITEM  := 1
LOCAL _NGRAVA := 0
LOCAL _NRECEB := 0
Local _nGrAcr := 0

//Local cViagem

Local aNewFPA := {}
Local aNewFQ5 := {}
Local aFldFPA := {}
Local aFldFQ5 := {}
Local lLOCA59X6 := EXISTBLOCK("LOCA59X6")
Local lLOCA59X7 := EXISTBLOCK("LOCA59X7")
Local aBindParam := {}

Local cFilFPA := xFilial("FPA")
Local cFilST9 := XFILIAL("ST9")
Local cFilFQ3 := XFILIAL("FQ3")
Local cFilFQ5 := XFILIAL("FQ5")

	_CQUERY := " SELECT MAX(FQ3_ITEM) ITEM"
	_CQUERY += " FROM " + RETSQLNAME("FQ3") + " FQ3"
	_CQUERY += " WHERE  FQ3_FILIAL = '" + XFILIAL("FQ2") + "'"
	_CQUERY += "   AND  FQ3_NUM    = ? "
	Aadd(aBindParam, FQ2->FQ2_NUM )
	_CQUERY += "   AND  FQ3_ASF    = ? "
	Aadd(aBindParam, _CASF )
	_CQUERY += "   AND  FQ3.D_E_L_E_T_ = ''"
	_CQUERY := CHANGEQUERY(_CQUERY)

	MPSysOpenQuery(_CQUERY,"TRBMAX",,,aBindParam)
	dbSelectArea("TRBMAX")

	IF TRBMAX->(!EOF())
		_NITEM := VAL(TRBMAX->ITEM)+1
	ENDIF

	TRBMAX->(DBCLOSEAREA())

	FOR _NX := 1 TO LEN(_AARRAY)
		IF !_AARRAY[_NX][1] .OR. EMPTY(_AARRAY[_NX][4])
			LOOP
		ENDIF

		_NRECEB++

		DBSELECTAREA("FQ3")
		FQ3->(DBSETORDER(1))
		IF RECLOCK("FQ3",.T.)
			FQ3->FQ3_FILIAL  := cFilFQ3
			FQ3->FQ3_NUM     := FQ2->FQ2_NUM
			FQ3->FQ3_PROJET  := FQ2->FQ2_PROJET
			FQ3->FQ3_OBRA    := FQ2->FQ2_OBRA
			FQ3->FQ3_ASF     := _CASF
			FQ3->FQ3_AS      := _AARRAY[_NX][6]
			FQ3->FQ3_ITEM    := STRZERO(_NITEM,TAMSX3("FQ3_ITEM")[1])
			FQ3->FQ3_VIAGEM  := POSICIONE("FPA" , 3 , XFILIAL("FPA") + _AARRAY[_NX][6] , "FPA_VIAGEM")
			//se for retorno
			If FQ2->FQ2_TPROMA == "1"
				FQ3->FQ3_QTD	:= _AARRAY[_NX][11] // ERA A POSICAO 7 FRANK Z FUGA EM 14/10/20
			Else
				FQ3->FQ3_QTD	:= _AARRAY[_NX][07] //como o usuário pode alterar, grava o conteúdo da posição 07
			EndIf
			FQ3->FQ3_PROD	:= _AARRAY[_NX][8]
			FQ3->FQ3_DESPROD	:= _AARRAY[_NX][9]

			DBSELECTAREA("ST9")

			ST9->(DBSETORDER(1))
			IF ST9->(DBSEEK(cFilST9 + _AARRAY[_NX][3]))
				FQ3->FQ3_CODBEM  := ST9->T9_CODBEM
				FQ3->FQ3_NOMBEM  := ST9->T9_NOME
				FQ3->FQ3_FAMBEM  := ST9->T9_CODFAMI
				FQ3->FQ3_FAMILIA := ALLTRIM(POSICIONE("ST6" , 1 , XFILIAL("ST6")+ST9->T9_CODFAMI , "T6_NOME"))
				FQ3->FQ3_HORBEM  := ST9->T9_POSCONT
			ENDIF
			FQ3->(MSUNLOCK())

			_NITEM++
			_NGRAVA++
		ENDIF
	NEXT _NX

	nTotFQ3 := _NGRAVA

	//ifranzoi - 20/07/2021
	//atualizar - FPA - atual e gerar nova linha com a quantidade reduzida
	//gerar novo registro na FQ5 - nova viagem
	dbSelectArea("FPA")
	dbSelectArea("FQ5")

	aFldFPA := FPA->(dbStruct())
	aFldFQ5 := FQ5->(dbStruct())

	//Passa em todos os itens, verifica se foi alterado para um quantidade menor,
	//caso sim, diminui a quantidade e gera uma nova
	For _nItem := 1 To Len(_aArray)
		//No registro atual da FPA - reduz a quantidade atual, conforme a quantidade passada
		If ( _aArray[_nItem][12] > 1 )

			FPA->(dbGoTo(_aArray[_nItem][12]))  //Posiciona no registro atual da FPA para diminuir a quantidade

			DbSelectArea("FQ5")
			DbSetOrder(9)
			DbGoTop()
			DbSeek(cFilFQ5+FPA->FPA_AS+FPA->FPA_VIAGEM)
			If Found() .and. FQ5->FQ5_STATUS = '6'
				If Empty(FQ5->FQ5_GUINDA)
					aNewFPA := {}

					//Verifica se a quantidade informada é diferente para gerar um novo registro na FPA
					// Só usada no momento da Remessa parcial no retorno será abatida da quantidade
					If ( _aArray[_nItem][07] != FPA->FPA_QUANT )
						aBindParam := {}
						_CQUERY := " SELECT MAX(FPA_SEQGRU) MAXFPA FROM "+RetSqlName("FPA")+ " WHERE D_E_L_E_T_ = ' ' "
						//Clona as informações para gravar novo registro da FPA
						For _nGrava := 1 To Len(aFldFPA)
							If ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_QUANT" )
								aAdd( aNewFPA, { aFldFPA[_nGrava][01], nQtdFPA := FPA->&(aFldFPA[_nGrava][01])-_aArray[_nItem][07] } )
							Else
								aAdd( aNewFPA, { aFldFPA[_nGrava][01], FPA->&(aFldFPA[_nGrava][01]) } )

								If ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PRCUNI" )
									nPrcFPA := aNewFPA[Len(aNewFPA)][02]
								ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PDESC" )
									nDesFPA := aNewFPA[Len(aNewFPA)][02]
								ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_ACRESC" )
									nAcrFPA := aNewFPA[Len(aNewFPA)][02]
								ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PACRES" )
									nPAcFPA := aNewFPA[Len(aNewFPA)][02]
								EndIf

								Do Case
									Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_FILIAL"
										cFilFPA := FPA->&(aFldFPA[_nGrava][01])
										_CQUERY += " AND FPA_FILIAL = ? "
										Aadd( aBindParam, cFilFPA)
									Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_PROJET"
										cPrjFPA := FPA->&(aFldFPA[_nGrava][01])
										_CQUERY += " AND FPA_PROJET = ? "
										Aadd( aBindParam,cPrjFPA)
									Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_OBRA"
										cObrFPA := FPA->&(aFldFPA[_nGrava][01])
										_CQUERY += " AND FPA_OBRA = ? "
										Aadd( aBindParam,cObrFPA)
									Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_SEQGRU"
										cSeqFPA := FPA->&(aFldFPA[_nGrava][01])
									Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_TIPOSE"
										cTipFPA := FPA->&(aFldFPA[_nGrava][01])
								EndCase
							EndIf
						Next
						_CQUERY := ChangeQuery(_CQUERY)
						MPSysOpenQuery(_CQUERY,"FPAMAX",,,aBindParam)

						If FPAMAX->(!Eof())
							cMaxFPA := FPAMAX->MAXFPA
						EndIf

						FPAMAX->(dbCloseArea())

						RecLock("FPA", .F.)
							FPA->FPA_QUANT	:= _aArray[_nItem][07]
							FPA->FPA_VLBRUT	:= _aArray[_nItem][07]*FPA->FPA_PRCUNI
							If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
									FPA->FPA_ACRESC := FPA->FPA_VLBRUT * FPA->FPA_PACRES
							EndIf
							FPA->FPA_VRHOR		:= (((FPA->FPA_PRCUNI * _aArray[_nItem][07] -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
							FPA->(MsUnlock())

						//Gerar novo número de AS

						nForca := 0
						If lLOCA59X6
							nForca := EXECBLOCK("LOCA59X6",.T.,.T.,{})
						EndIf

						Do Case
							Case cTipFPA == "E" .or. nForca == 1
								cSegFPA := "20"				// "02"
							Case cTipFPA $ "L;S" .or. nForca == 2
								cSegFPA := "30"				// "04"
							Case cTipFPA $ "M;T;Z" .or. nForca == 3
								cSegFPA := "32"				// "04"
							Case cTipFPA  == "O" .or. nForca == 4
								cSegFPA := "39"				// "04"
						EndCase

						//GERANUMAS("31", CPROJETO, FQ7->FQ7_OBRA, FQ7->FQ7_SEQGUI, FQ7->FQ7_FILIAL)
						cNasFPA := GERANUMAS( cSegFPA, cPrjFPA, cObrFPA, cSeqFPA, cFilFPA )

						//Substituir os totais
						_nGrava := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_VLBRUT" } )
						If (_nGrava > 0)
							//FPA_VLBRUT := M->FPA_QUANT*M->FPA_PRCUNI
							nBrtFPA := nQtdFPA*nPrcFPA
							aNewFPA[_nGrava][02] := nBrtFPA
						EndIf

						_nGrava := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_VRHOR" } )
						If (_nGrava > 0)
							//FPA_VRHOR := (((M->FPA_PRCUNI * M->FPA_QUANT -(M->FPA_VLBRUT*(M->FPA_PDESC/100))) + (M->FPA_ACRESC)))
							If nPAcFPA > 0
								nAcrFPA := (nBrtFPA * nPAcFPA)
								_nGrAcr  := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_ACRESC" } )
								aNewFPA[_nGrAcr][02] := nAcrFPA
							EndIf
							nVrhFPA := (((nPrcFPA * nQtdFPA -(nBrtFPA*(nDesFPA/100))) + (nAcrFPA)))
							aNewFPA[_nGrava][02] := nVrhFPA
						EndIf

						//Gerar novo registro da FPA - com a quantidade atualizada
						RecLock("FPA", .T.)
							For _nGrava := 1 To Len(aNewFPA)
								If ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_FILIAL" ) .or.;
									( AllTrim(aNewFPA[_nGrava][01]) == "FPA_PROJET" ) .or.;
									( AllTrim(aNewFPA[_nGrava][01]) == "FPA_OBRA" ) .or.;
									( AllTrim(aNewFPA[_nGrava][01]) == "FPA_TIPOSE" )
									FPA->&(aNewFPA[_nGrava][01]) := aNewFPA[_nGrava][02]
								ElseIf ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_SEQGRU" )
									FPA->FPA_SEQGRU	:= Soma1(cMaxFPA)
								ElseIf ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_AS" )
									FPA->&(aNewFPA[_nGrava][01]) := cNasFPA
								Else
									If !( aNewFPA[_nGrava][01] $ cFldFPA )
										FPA->&(aNewFPA[_nGrava][01]) := aNewFPA[_nGrava][02]
									EndIf
								EndIf
							Next
						FPA->(MsUnlock())

						nRecFPA := FPA->(Recno())

						//Gera o registro FQ5 - pendente de aprovação
						//Clona as informações para gravar novo registro da FPA
						FQ5->(dbSetOrder(nOrdFQ5))
						If FQ5->(dbSeek(FQ5->FQ5_FILIAL+FQ5->FQ5_VIAGEM))
							//Atualiza a quantidade da FQ5 - FQ5 atual - envio de itens parcias
							RecLock("FQ5", .F.)
								FQ5->FQ5_XQTD	:= _aArray[_nItem][07]
							FQ5->(MsUnlock())

							For _nGrava := 1 To Len(aFldFQ5)
								If ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_FILIAL" ) .or.;
									( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_FILORI" ) .or.;
									( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_SOT" ) .or.;
									( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_GUIND" ) .or.;
									( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_XPROD" ) .or.;
									( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_OBRA" )
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], FQ5->&(aFldFQ5[_nGrava][01]) } )
								ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_VIAGEM" )
/*									While .T.
										CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
										CONFIRMSX8()
										FQ5->(dbSetOrder(1))
										If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
											Exit
										EndIF
									Enddo
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], cViaFQ5 := cViagem } )
									*/ // Voltado ao processo anterior, sem validar a existencia do novo numero da viagem
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], cViaFQ5 := GetSx8Num("FQ5","FQ5_VIAGEM") } )
								ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_STATUS" )
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], '6' } ) //pendente de aprovação
								ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_AS" )
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], cNasFPA } )
								ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_XQTD" ) //gera a FQ5 com os itens restantes
									aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], nQtdFPA } )
								Else
									If !( aFldFQ5[_nGrava][01] $ cFldFQ5 )
										aAdd( aNewFQ5, { aFldFQ5[_nGrava][01], FQ5->&(aFldFQ5[_nGrava][01]) } )
									EndIf
								EndIf
							Next

							//Gerar novo registro da FQ5 - nova viagem para o novo FPA
							RecLock("FQ5", .T.)
								For _nGrava := 1 To Len(aNewFQ5)
									FQ5->&(aNewFQ5[_nGrava][01]) := aNewFQ5[_nGrava][02]
								Next
							FQ5->(MsUnlock())
						EndIf

						//Grava a viagem gerada no FPA
						FPA->(dbGoTo(nRecFPA))
						RecLock("FPA", .F.)
							FPA->FPA_AS := cNasFPA
							FPA->FPA_VIAGEM := cViaFQ5
						FPA->(MsUnlock())

					EndIf
				EndIf
			EndIf

		EndIf
	Next

	_CMSG := CVALTOCHAR(nTotFQ3) + STR0269 + CVALTOCHAR(_NRECEB) + STR0270 // de###itens foram gravados no romaneio

	lForca := .F.
	If lLOCA59X7
		lForca := EXECBLOCK("LOCA59X7",.T.,.T.,{})
	EndIf

	IF nTotFQ3 < _NRECEB .or. lForca
		_CMSG += CRLF + CRLF + STR0271 //"VERIFIQUE SE O EQUIPAMENTO DO PROJETO ESTÁ OK NO CADASTRO DE BENS!"
		MSGALERT(_CMSG , ProcName())
	ELSE
		MSGINFO(_CMSG , ProcName())
	ENDIF

RETURN


/*/{PROTHEUS.DOC} FVERARRY
ITUP BUSINESS - TOTVS RENTAL
VERIFICA SE O ARRAY POSSUI ALGUM REGISTRO MARCADO COMO .T.
@TYPE FUNCTION
/*/
STATIC FUNCTION FVERARRY(_AARRAY)
LOCAL _NCNT		 := 1
LOCAL _LRETORNO := .F.

	WHILE _NCNT <= LEN(_AARRAY)
		IF _AARRAY[_NCNT][1]
			_LRETORNO := .T.
			EXIT
		ENDIF
		_NCNT++
	ENDDO

RETURN _LRETORNO


/*/{PROTHEUS.DOC} FMARCAITM
ITUP BUSINESS - TOTVS RENTAL
MARCA E DESMARCA UM ÚNICO ITEM
@TYPE FUNCTION
/*/
STATIC FUNCTION FMARCAITM(NAT,_AARRAY,LUMAOPCAO,LMARCAITEM)
Local lPrmEdt	:= .T.
Local nQtdVal	:= 0 //guardar a quantidade anterior a alteração do usuário para validação
LOCAL _NX
LOCAL _CFILREM	:= _AARRAY[NAT][10] // FRANK 06/10/20 CONTROLE DA FILIAL DE REMESSA
LOCAL _AAREA	:= GETAREA()
LOCAL _LBLOQ	:= .F.
Local lLOCA59X8 := EXISTBLOCK("LOCA59X8")
Local lLOCA59X9 := EXISTBLOCK("LOCA59X9")

DEFAULT LMARCAITEM := .T.

	IF TYPE("LUMAOPCAO") == "L" .AND. LUMAOPCAO
		//LMARCAITEM := .F.
	ENDIF

	// FRANK - 06/10/2020 NÃO PERMITE MARCAR ITENS DE FILIAIS DIFERENTES
	FOR _NX := 1 TO LEN(_AARRAY)
		IF _NX <> NAT
			IF _AARRAY[_NX][10] <> _CFILREM .AND. _AARRAY[_NX][1]
				MSGALERT(STR0239+ALLTRIM(STR(_NX)),STR0022) //"Conflito de filiais de remessa, veja o item: "###"Atenção!"
				LMARCAITEM := .F.
				EXIT
			ENDIF
		ENDIF
	NEXT

	// FRANK - 06/10/2020 VERIFICAR NOS ITENS JÁ GRAVADOS SE HAVERÁ CONFLITO DE FILIAIS.
	IF LMARCAITEM
		FQ3->(DBSETORDER(1))
		FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
		WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
			FPA->(DBSETORDER(3))
			IF FPA->(DBSEEK(XFILIAL("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))
				IF FPA->FPA_FILEMI <> _AARRAY[NAT][10]
					_LBLOQ := .T.
					EXIT
				ENDIF
			ENDIF
			FQ3->(DBSKIP())
		ENDDO
		IF _LBLOQ
			MSGALERT(STR0240,STR0022) //"Conflito de filiais de remessa, gere um novo conjunto transpotador, para realizar o vínvulo."###"Atenção!"
			LMARCAITEM := .F.
		ENDIF
	ENDIF

	// FRANK - 06/10/20 VERIFICAR SE JÁ EXISTE O ROMANEIO COM NOTA AGREGADA, SE FOR O CASO NÃO PERMITIR O VÍNCULO
	IF LMARCAITEM
		FQ3->(DBSETORDER(1))
		FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
		WHILE !FQ3->(EOF()) .AND. FQ3->FQ3_FILIAL == XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
			IF !EMPTY(FQ3->FQ3_NFREM)
				MSGALERT(STR0241+ALLTRIM(FQ3->FQ3_NFREM),STR0022) //"Já existe uma nota emitida para este romaneio: "###"Atenção!"
				LMARCAITEM := .F.
			ENDIF
			FQ3->(DBSKIP())
		ENDDO
	ENDIF


	_AARRAY[NAT][1] := !_AARRAY[NAT][1]

	IF !LMARCAITEM
		_AARRAY[NAT][1] := .F.
	ENDIF

	//ifranzoi - 17/07/2021
	If ( oListBox:ColPos == 7 ) //Verifica se o usuário posicionou na coluna de quantidade

		//Verifica se o campo FQ5_GUINDA não está preenchido - o usuário só pode realizar a alteração
		//de quantidade caso este campo esteja em branco

		lForca := .F.
		If lLOCA59X8
			lForca := EXECBLOCK("LOCA59X8",.T.,.T.,{})
		EndIf

		If  !Empty(_aArray[nAt,3]) .or. lForca
			lPrmEdt := .F.
		EndIf

		nForca := 0
		If lLOCA59X9
			nForca := EXECBLOCK("LOCA59X9",.T.,.T.,{})
		EndIf

		If lPrmEdt .or. (nForca > 0 .and. nForca < 3)

			//Faz um backup do valor que o usuário pode alterar - nQtdVal
			nQtdVal := _ABACK[oListBox:nAt][07]

			//Permitir edição da célula
			lEditCell(@_aArray,oListBox,PesqPict("FPA","FPA_QUANT",TamSx3("FPA_QUANT")[1]),7)

			//Os valores só podem ser reduzidos, a partir do valor já existente na FPA, ou seja,
			//quantidade só pode ser diminuida
			If ( _aArray[oListBox:nAt][07] > nQtdVal ) .or. nForca == 1
				_aArray[oListBox:nAt][07] := nQtdVal

				Help(Nil,	Nil,STR0023+AllTrim(Upper(Procname())),; // Rental
					Nil,STR0272,1,0,Nil,Nil,Nil,Nil,Nil,; //"Valores informados não pode ser maiores que os anteriores."
					{STR0273+AllTrim(Str(nQtdVal))+" !" } ) // "Os valores aceitos, só podem ser menores que: "
			ElseIf ( _aArray[oListBox:nAt][07] <= 0 ) .or. nForca == 2
				Help(Nil,	Nil,STR0023+AllTrim(Upper(Procname())),; // Rental
					Nil,STR0274,1,0,Nil,Nil,Nil,Nil,Nil,; // "Valores informados não pode ser menores que zero."
					{STR0275 } ) //"Informe um valor maior que zero !"
			EndIf
		Elseif !lPrmEdt .or. nForca == 5
			Help(Nil,	Nil,STR0023+AllTrim(Upper(Procname())),; // Rental
				Nil,STR0276,1,0,Nil,Nil,Nil,Nil,Nil,; // "As quantidades não podem ser alteradas."
				{STR0277 } ) // "Verifique o tipo de serviço!"
		EndIf
	EndIf

	oListBox:SetFocus()
	oListBox:GoDown()

	RESTAREA(_AAREA)
RETURN _AARRAY

/*/{PROTHEUS.DOC} RETPARX
ITUP BUSINESS - TOTVS RENTAL
TRATAMENTO PARA O RETORNO PARCIAL
@TYPE FUNCTION
/*/
STATIC FUNCTION RETPARX(NAT)
LOCAL ORETPAR
LOCAL LOK
LOCAL _NX
LOCAL _LPASSA := .F.
LOCAL AHEADER := {}
LOCAL ACOLS   := {}
LOCAL CALIAS
LOCAL CCHAVE
LOCAL CCONDICAO
LOCAL NINDICE
LOCAL CFILTRO
LOCAL _CTEMP  := "" // MONTAGEM DO FILTRO
LOCAL ODLGGET
LOCAL NSTYLE   := GD_UPDATE
LOCAL MAXGETDAD := 99999
LOCAL CCAMPOSSIM := "FPA_GRUA;FPA_DESGRU;FPA_PRODUT;FPA_DESPRO;FPA_QUANT"
LOCAL _NY
LOCAL _NREG
LOCAL _NQTD

	FOR _NX := 1 TO LEN(_AARRAY)
		IF _AARRAY[_NX][01]
			_LPASSA := .T.
			IF !EMPTY(_CTEMP)
				_CTEMP += ";"
			ENDIF
			//_CTEMP += "'"+ALLTRIM(STR(_AARRAY[_NX][12]))+"'" // CONTEÚDO DO RECNO DA ZAG
			_CTEMP += ALLTRIM(STR(_AARRAY[_NX][12])) // CONTEÚDO DO RECNO DA ZAG
		ENDIF
	NEXT
	IF !_LPASSA
		MSGALERT(STR0242,STR0243) //"Nenhum item do romaneio foi selecionado."###"Falha na seleção."
		RETURN .F.
	ENDIF

	// MONTAGEM DO CABECALHO E ITENS DA GETDADOS COM BASE NA ZAG
	CALIAS    := "FPA"
	CCHAVE    := XFILIAL(CALIAS)+FQ5->FQ5_SOT
	CCONDICAO := 'FPA_FILIAL+FPA_PROJET=="'+CCHAVE+'"'
	NINDICE   := 1
	CFILTRO   := CCONDICAO+" .AND. ALLTRIM(STR(FPA->(RECNO()))) $ " + "'"+_CTEMP+"'"
	AHEADER   := FHEADER("FPA", CCAMPOSSIM)
	ACOLS     := FCOLS(AHEADER,CALIAS,NINDICE,CCHAVE,CCONDICAO,CFILTRO)

	DEFINE MSDIALOG ORETPAR TITLE STR0244   FROM 30,20 TO 500,882 PIXEL		// DE 610 PARA 400 //"Retorno parcial."
	ODLGGET := MSNEWGETDADOS():NEW(34,02,232,432 ,NSTYLE,,,"",,,MAXGETDAD,,,.T.,ORETPAR,AHEADER,ACOLS)
	ACTIVATE MSDIALOG ORETPAR CENTERED ON INIT ENCHOICEBAR(ORETPAR, {||LOK:=.T., IF(MSGYESNO(STR0245,STR0022),ORETPAR:END(),.F.)},{||ORETPAR:END()},,) //"Confirma o retorno parcial dos itens informados?"###"Atenção!"
	IF LOK
		FOR _NX:=1 TO LEN(ODLGGET:ACOLS)
			IF !ODLGGET:ACOLS[_NX][LEN(AHEADER)+1]
				_NREG := ODLGGET:ACOLS[_NX][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX4"})] // RECNO DA ZAG
				_NQTD := ODLGGET:ACOLS[_NX][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX3"})] // QUANTIDADE INFORMADA
				FOR _NY := 1 TO LEN(_AARRAY)
					IF _AARRAY[_NY][12] == _NREG
						_AARRAY[_NY][11] := _NQTD
					ENDIF
				NEXT
			ENDIF
		NEXT
	ELSE
		// VOLTAR COM AS QUANTIDADES ORIGINAIS DA NOTA DE REMESSA X ROMANEIO
		_AARRAY := _ABACK
	ENDIF
	OLISTBOX:REFRESH()
RETURN .T.

/*/{PROTHEUS.DOC} FHEADER
ITUP BUSINESS - TOTVS RENTAL
Criação do aHeader para uso na MsNewGetDados
@TYPE FUNCTION
/*/
STATIC FUNCTION FHEADER( CALIAS , CCAMPOSSIM , CCAMPOSNAO)
LOCAL   ATABAUX
LOCAL   AHEADER    := {}

DEFAULT CCAMPOSSIM := ""
DEFAULT CCAMPOSNAO := ""

	CCAMPOSSIM := UPPER( ALLTRIM(CCAMPOSSIM) )
	CCAMPOSNAO := UPPER( ALLTRIM(CCAMPOSNAO) )

	(LOCXCONV(1))->( DBSETORDER(1) )
	(LOCXCONV(1))->( DBSEEK( CALIAS, .T. ) )
	WHILE ! (LOCXCONV(1))->( EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS

		IF ! X3USO( &(LOCXCONV(3)) )					// NÃO ESTÁ EM USO
			(LOCXCONV(1))->(DBSKIP())
			LOOP
		ENDIF

		IF UPPER( ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) ) $ CCAMPOSNAO	// ESTÁ EM CAMPOSNÃO
			(LOCXCONV(1))->(DBSKIP())
			LOOP
		ENDIF

		IF ! EMPTY( CCAMPOSSIM ) .AND. ! UPPER( ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) ) $ CCAMPOSSIM		// NÃO É EM CAMPOSSIM
			(LOCXCONV(1))->(DBSKIP())
			LOOP
		ENDIF

		ATABAUX := {}
		IF ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")) == "FPA_QUANT"
			AADD(ATABAUX , STR0227) //"Quantidade"
		ELSE
			AADD(ATABAUX , TRIM(X3TITULO()))
		ENDIF
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")   )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )
		AADD(ATABAUX , "V"  ) // SX3->X3_VISUAL
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )
		AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )

		AADD(AHEADER , ATABAUX             )

		(LOCXCONV(1))->(DBSKIP())
	ENDDO

	// INSERINDO A COLUNA SOBRE A QUANTIDADE ENVIADA VIA NOTA DE SAIDA
	(LOCXCONV(1))->(DBSETORDER(2))
	(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
	ATABAUX := {}
	AADD(ATABAUX , STR0246) //"Enviado"
	AADD(ATABAUX , "FPA_XXX1"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )
	AADD(ATABAUX , "V"  )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )
	AADD(AHEADER , ATABAUX             )

	// INSERINDO A COLUNA SOBRE A QUANTIDADE JA DIGITADA EM OUTROS ROMANEIOS
	(LOCXCONV(1))->(DBSETORDER(2))
	(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
	ATABAUX := {}
	AADD(ATABAUX , STR0247) //"Qtd.Romaneio"
	AADD(ATABAUX , "FPA_XXX2"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN") )
	AADD(ATABAUX , "V"  )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") )
	AADD(AHEADER , ATABAUX             )

	// QUANTIDADE INFORMADA
	(LOCXCONV(1))->(DBSETORDER(2))
	(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
	ATABAUX := {}
	AADD(ATABAUX , STR0248) //"A Receber"
	AADD(ATABAUX , "FPA_XXX3"   ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") )
	AADD(ATABAUX , "LOCA05926()"   )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    )
	AADD(ATABAUX , "R"  )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR")     )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT")     )
	AADD(AHEADER , ATABAUX             )

	// ARMAZENAR O RECNO PARA VINCULO COM A LISTBOX
	(LOCXCONV(1))->(DBSETORDER(2))
	(LOCXCONV(1))->(DBSEEK("FPA_QUANT"))
	ATABAUX := {}
	AADD(ATABAUX , STR0249      ) //"Controle"
	AADD(ATABAUX , "FPA_XXX4"      ) // SOMENTE ESTRUTURA DA GETDADOS, ESTE CAMPO NAO EXISTE
	AADD(ATABAUX , "9999999999999" )
	AADD(ATABAUX , 12              )
	AADD(ATABAUX , 0               )
	AADD(ATABAUX , ""              )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    )
	AADD(ATABAUX , "V"  )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR")     )
	AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT")     )
	AADD(AHEADER , ATABAUX             )

RETURN ACLONE(AHEADER)

/*/{PROTHEUS.DOC} FCOLS
ITUP BUSINESS - TOTVS RENTAL
Criação do aCols para uso na MsNewGetDados
@TYPE FUNCTION
/*/
STATIC FUNCTION FCOLS(AHEADER, CALIAS, NINDICE, CCHAVE, CCONDICAO, CFILTRO)
LOCAL NPOS
LOCAL ACOLS0
LOCAL ACOLS     := {}
LOCAL CALIASANT := ALIAS()
LOCAL _NENV     := 0 // QUANTIDADE ENVIADA
LOCAL _NRET     := 0 // QUANTIDADE RETORNADA
LOCAL _CITEM

	DBSELECTAREA(CALIAS)

	(CALIAS)->(DBSETORDER(NINDICE))
	(CALIAS)->(DBSEEK(CCHAVE,.T.))
	WHILE (CALIAS)->(!EOF() .AND. &CCONDICAO)
		IF !(CALIAS)->(&CFILTRO)
			(CALIAS)->(DBSKIP())
			LOOP
		ENDIF
		ACOLS0 := {}
		FOR NPOS:=1 TO LEN(AHEADER)
			IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3" .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
				IF !AHEADER[NPOS,10]=="V"  				// X3_CONTEXT
					(CALIAS)->(AADD(ACOLS0,FIELDGET(FIELDPOS(AHEADER[NPOS,2]))))
				ELSE
					(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
				ENDIF
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DO QUE FOI INSERIDO NA ZA1
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // DIGITAR
				(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
			ENDIF
		NEXT
		AADD(ACOLS0,.F.  )  						// DELETED
		AADD(ACOLS,ACOLS0)

		IF !EMPTY(FPA->FPA_NFREM)
			SC6->(DBSETORDER(4))
			SC6->(DBSEEK(FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM))
			WHILE !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM
				IF ALLTRIM(SC6->C6_ITEM) == ALLTRIM(FPA->FPA_ITEREM)
					_NENV := SC6->C6_QTDVEN
					EXIT
				ENDIF
				SC6->(DBSKIP())
			ENDDO
			ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX1"})] := _NENV
		ENDIF

		_NRET := 0

		FQZ->(DBSETORDER(2))
		FQZ->(DBSEEK(XFILIAL("FQZ")+FPA->FPA_PROJET))
		WHILE !FQZ->(EOF()) .AND. FQZ->FQZ_FILIAL == XFILIAL("FQZ") .AND. FQZ->FQZ_PROJET == FPA->FPA_PROJET
			IF FQZ->FQZ_OBRA == FPA->FPA_OBRA
				IF FQZ->FQZ_MSBLQL == "2"
					IF ALLTRIM(FQZ->FQZ_AS) == ALLTRIM(FPA->FPA_AS)
						_NRET += FQZ->FQZ_QTD
					ENDIF
				ENDIF
			ENDIF
			FQZ->(DBSKIP())
		ENDDO

		ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX2"})] := _NRET

		// QUANTIDADE A SER RETORNADO NO ROMANEIO
		ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX3"})] := _NENV - _NRET

		// INFORME DO REGISTRO DA ZAG
		ACOLS[LEN(ACOLS)][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX4"})] := FPA->(RECNO())

		(CALIAS)->(DBSKIP())
	ENDDO

	IF EMPTY(ACOLS)
		ACOLS0 := {}
		FOR NPOS := 1 TO LEN(AHEADER)
			IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3" .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
				(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DA ZA1
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
				(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
			ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // RECNO
				(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
			ENDIF
		NEXT
		AADD(ACOLS0 , .F.)  						// DELETED
		AADD(ACOLS,ACOLS0)
	ENDIF

	ACOLS0 := {}
	FOR NPOS := 1 TO LEN(AHEADER)
		IF AHEADER[NPOS,2] <> "FPA_XXX1" .AND. AHEADER[NPOS,2] <> "FPA_XXX2" .AND. AHEADER[NPOS,2] <> "FPA_XXX3"  .AND. AHEADER[NPOS,2] <> "FPA_XXX4"
			(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX1" // BUSCAR DAS NOTAS DE SAIDA
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX2" // BUSCAR DA ZA1
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX3" // DIGITAR
			(CALIAS)->(AADD(ACOLS0,CRIAVAR("FPA_QUANT")))
		ELSEIF AHEADER[NPOS,2] == "FPA_XXX4" // RECNO
			(CALIAS)->(AADD(ACOLS0,FPA->(RECNO())))
		ENDIF
	NEXT
	AADD( ACOLS0, .F. )  							// DELETED

	DBSELECTAREA(CALIASANT)

RETURN ACLONE(ACOLS)

/*/{PROTHEUS.DOC} LOCA05926
ITUP BUSINESS - TOTVS RENTAL
ROTINA PARA VALIDACAO DA QUANTIDADE DO ROMANEIO
@TYPE FUNCTION
/*/
FUNCTION LOCA05926
LOCAL _LRET := .T.
LOCAL _CERRO := ""
	IF &(READVAR()) > ACOLS[N][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_XXX1"})]
		_CERRO := STR0250 //"Quatidade informada no romaneio maior do que a quantidade enviada para o cliente."
		_LRET := .F.
	ENDIF
	IF &(READVAR()) > ACOLS[N][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})] .AND. _LRET
		_CERRO := STR0251 //"Quantidade informada é maior do que a disponível no contrato."
		_LRET := .F.
	ENDIF
	IF &(READVAR()) == 0 .AND. _LRET
		_CERRO := STR0252 //"Quantidade inválida."
		_LRET := .F.
	ENDIF
	IF !_LRET
		MSGALERT(_CERRO,STR0022) //"Atenção!"
	ENDIF
RETURN _LRET


//------------------------------------------------------------------------------
/*/	{Protheus.doc} LOCA05928

@description	Gera Solicitação de Compras
@type			function
@return			Boolean
@author			Jose Eulalio
@since			14/04/2022
@version		12
/*/
//------------------------------------------------------------------------------
Function LOCA05928()
Local cTitDlg	:= STR0254 + ' - ' + STR0044 + ' - ' + FQ5->FQ5_SOT //Seleção de Itens // Projeto
Local aTamObra	:= TamSx3("FQ5_OBRA")
Local aTamSeqG	:= TamSx3("FPA_SEQGRU")
Local aTamAS	:= TamSx3("FQ5_AS")
Local aTamProd	:= TamSx3("FQ5_XPROD")
Local aTamQtde	:= TamSx3("FPA_QUANT")
Local aTamClie	:= TamSx3("FQ5_NOMCLI")
Local aCampos	:= {{"","","","","",""}}
Local aPesquisa	:= {}
Local nI		:= 0
//Local oColumn

Private lMarker := .T.
Private aBusca	:= {}

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	//atualiza cCadastro
	ccadastro := STR0044  + " " + FQ5->FQ5_SOT //Projeto ####

	//Alimenta o array
	If CargaFQ5(FQ5->FQ5_SOT)

		DEFINE MsDIALOG o3Dlg TITLE cTitDlg From 0, 4 To 650, 1180 Pixel

			oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
			oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT

			oBuscaBrw := fwBrowse():New()
			oBuscaBrw:setOwner( oPnMaster )

			oBuscaBrw:setDataArray()
			oBuscaBrw:setArray( aBusca )
			oBuscaBrw:disableConfig()
			oBuscaBrw:disableReport()

			oBuscaBrw:SetLocate() // Habilita a Localização de registros

			//Create Mark Column
			oBuscaBrw:AddMarkColumns({|| IIf(aBusca[oBuscaBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
				{|| SelectOne(oBuscaBrw, aBusca)},; //Code-Block Double Click
				{|| SelectAll(oBuscaBrw, 01, aBusca) }) //Code-Block Header Click

			//-------------------------------------------------------------------
			// Campos
			//-------------------------------------------------------------------
			// Estrutura do aFields
			//				[n][1] Campo
			//				[n][2] Título
			//				[n][3] Tipo
			//				[n][4] Tamanho
			//				[n][5] Decimal
			//				[n][6] Picture
			//-------------------------------------------------------------------

			Aadd(aCampos, {"CAMPO02", STR0127	,aTamObra[3] ,aTamObra[1] ,aTamObra[2]	, X3Picture( "FPA_OBRA" )}	) //"Obra"
			Aadd(aCampos, {"CAMPO03", STR0226	,aTamSeqG[3] ,aTamSeqG[1] ,aTamSeqG[2]	, X3Picture( "FPA_SEQGRU" )}) //"Sequencia"
			Aadd(aCampos, {"CAMPO04", STR0121	,aTamAS[3]   ,aTamAS[1]   ,aTamAS[2]	, X3Picture( "FPA_AS" )}	) //"Nº AS"
			Aadd(aCampos, {"CAMPO05", STR0126	,aTamProd[3] ,aTamProd[1] ,aTamProd[2]	, X3Picture( "FPA_PRODUT" )}) //"Produto"
			Aadd(aCampos, {"CAMPO06", STR0255	,aTamClie[3] ,aTamClie[1] ,aTamClie[2]	, X3Picture( "FQ5_NOMCLI" )}) //"Cliente"
			Aadd(aCampos, {"CAMPO07", STR0227	,aTamQtde[3] ,aTamQtde[1] ,aTamQtde[2]	, X3Picture( "FPA_QUANT" )}	) //"Quantidade"

			// Adiciona as colunas do Browse
			/*For nI := 2 To Len( aCampos )
				ADD COLUMN oColumn DATA { || aBusca[oBuscaBrw:nAt,nI] + ' }' ) Title aCampos[nI][2]  PICTURE aCampos[nI][6] Of oBuscaBrw
			Next nI*/

			For nI := 2 To Len( aCampos )
				Aadd( aPesquisa, { aCampos[nI][2], {{"",aCampos[nI][3],aCampos[nI][4],aCampos[nI][5],aCampos[nI][2],,}} } ) //"Código"
			Next nI

			oBuscaBrw:DisableReport()
			oBuscaBrw:DisableConfig(.T.)
			oBuscaBrw:SetSeek( , aPesquisa )

			oBuscaBrw:addColumn({ STR0127	, {||aBusca[oBuscaBrw:nAt,02]}, "C", "@!"    , 1,  	aTamObra[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,02]",, .F., .T.,  , "CAMPO02"    }) //"Obra"
			oBuscaBrw:addColumn({ STR0226	, {||aBusca[oBuscaBrw:nAt,03]}, "C", "@!"    , 1,  	aTamSeqG[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,03]",, .F., .T.,  , "CAMPO03"    }) //"Sequencia"
			oBuscaBrw:addColumn({ STR0121   , {||aBusca[oBuscaBrw:nAt,04]}, "C", "@!"    , 1,  	aTamAS[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,04]",, .F., .T.,  , "CAMPO04"    }) //"Nº AS"
			oBuscaBrw:addColumn({ STR0126   , {||aBusca[oBuscaBrw:nAt,05]}, "C", "@!"    , 1, 	aTamProd[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,05]",, .F., .T.,  , "CAMPO05"    }) //"Produto"
			oBuscaBrw:addColumn({ STR0255   , {||aBusca[oBuscaBrw:nAt,06]}, "C", "@!"    , 1, 	aTamClie[1]	, , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,06]",, .F., .T.,  , "CAMPO06"    }) //"Cliente"
			oBuscaBrw:addColumn({ STR0227   , {||aBusca[oBuscaBrw:nAt,07]}, "N", ""      , 1,  	aTamQtde[1] , , .F. , , .F.,, "aBusca[oBuscaBrw:nAt,07]",, .F., .T.,  , "CAMPO07"    }) //"Quantidade"


			// Adiciona as colunas do Filtro
			/*oBuscaBrw:SetFieldFilter(aCampos)
			oBuscaBrw:SetUseFilter()*/

			oBuscaBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation

			oBuscaBrw:Activate(.T.)

		Activate MsDialog o3Dlg CENTERED On Init EnchoiceBar(o3Dlg, {||GeraSc(),o3Dlg:end()},{||o3Dlg:end()})
	EndIf

return .t.

/*/{PROTHEUS.DOC} SelectOne
ITUP BUSINESS - TOTVS RENTAL
Tratamento para seleção de um registro
@TYPE FUNCTION
/*/
Static Function SelectOne(oBrowse, aArquivo)
	aArquivo[oBuscaBrw:nAt,1] := !aArquivo[oBuscaBrw:nAt,1]
	oBrowse:Refresh()
Return .T.

/*/{PROTHEUS.DOC} SelectAll
ITUP BUSINESS - TOTVS RENTAL
Tratamento para seleção de todos os registros
@TYPE FUNCTION
/*/
Static Function SelectAll(oBrowse, nCol, aArquivo)
Local _ni := 1
	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next
	oBrowse:Refresh()
	lMarker:=!lMarker
Return .T.


//------------------------------------------------------------------------------
/*/	{Protheus.doc} CargaFQ5
@description	Realiza carga dos itens que podem gerar SC
@type 			function
@author			Jose Eulalio
@since			14/04/2022
@version		12
/*/
///------------------------------------------------------------------------------
Static Function CargaFQ5(cAsFq5)
Local cQuery 	:= ""
Local cCliSC 	:= ""
Local cQryT3	:= ""
Local lRet		:= .T.
Local lLOCA59G  := EXISTBLOCK("LOCA59G")
Local lLOCA59H  := EXISTBLOCK("LOCA59H")
Local lLOCA59I  := EXISTBLOCK("LOCA59I")
Local aBindParam := {}

	//If FQ5->(FIELDPOS("FQ5_NSC")) == 0 .or. FPA->(FIELDPOS("FPA_NOMFAT"))  == 0
	If FPA->(FIELDPOS("FPA_NOMFAT"))  == 0
		Return .F.
	EndIf

	cQuery += " SELECT DISTINCT "
	cQuery += " 	FPA_PROJET, FPA_OBRA, FPA_SEQGRU, FPA_AS, FPA_PRODUT, FPA_NOMFAT CLIFPA, "
	cQuery += " 	FP1_NOMDES CLIFP1,FP0_CLINOM CLIFP0, FPA_QUANT, FPA.R_E_C_N_O_ RECNOFPA,  "
	If FQ5->(FIELDPOS("FQ5_NSC")) > 0
		cQuery += " 	FQ5_NOMCLI, FQ5_NSC, FQ5.R_E_C_N_O_ RECNOFQ5 "
	Else
//		cQuery += " 	FQ5_NOMCLI, FQ5.R_E_C_N_O_ RECNOFQ5 " // Se po campo não existir nem entra na rotina
	EndIF
	cQuery += " FROM " + RetSqlName("FPA") + " FPA "
	cQuery += " INNER JOIN " + RetSqlName("FP0") + " FP0 "
	cQuery += " 	ON FP0_PROJET = FPA_PROJET "
	cQuery += " INNER JOIN " + RetSqlName("FQ5") + " FQ5 "
	cQuery += " 	ON FQ5_FILIAL = '" + xFilial("FQ5") + "' AND "
	cQuery += " 	FQ5.D_E_L_E_T_ = ' ' AND "
	cQuery += " 	FPA_PROJET = FQ5_SOT AND"
	cQuery += " 	FQ5_TPAS = 'L' AND "
	cQuery += " 	FQ5_GUINDA = '' AND "
	cQuery += " 	FQ5_DATFEC = '' AND "
	cQuery += " 	FQ5_DATENC = '' AND "
	cQuery += " 	FQ5_STATUS = '1' AND "
	If FQ5->(FIELDPOS("FQ5_NSC")) > 0
		cQuery += " 	FQ5_NSC = '' AND "
	EndIf
	//cQuery += " 	FQ5_ISC = '' AND "
	cQuery += " 	FPA_AS = FQ5_AS "
	cQuery += " INNER JOIN " + RetSqlName("FP1") + " FP1 "
	cQuery += " 	ON FP1_PROJET = FPA_PROJET "
	cQuery += " 	AND FP1_OBRA = FPA_OBRA "
	cQuery += " WHERE "
	cQuery += " 	FP0_FILIAL = '" + xFilial("FP0") + "' AND "
	cQuery += " 	FP1_FILIAL = '" + xFilial("FP1") + "' AND "
	cQuery += " 	FPA_FILIAL = '" + xFilial("FPA") + "' AND "
	cQuery += " 	FP0.D_E_L_E_T_ = ' ' AND "
	cQuery += " 	FP1.D_E_L_E_T_ = ' ' AND "
	cQuery += " 	FPA.D_E_L_E_T_ = ' ' AND "
	cQuery += " 	FPA_PROJET = ? "
	Aadd(aBindParam, cAsFq5 )
	cQuery:=ChangeQuery(cQuery)
	cQryT3 := MPSysOpenQuery(cQuery,,,,aBindParam)

	(cQryT3)->(DbGoTop())
	lForca := .F.
	If lLOCA59I
		lForca := EXECBLOCK("LOCA59I",.T.,.T.,{})
	EndIf
	If (cQryT3)->(!EOF()) .and. !lForca
		While (cQryT3)->(!EOF())

			lForca := .F.
			If lLOCA59G
				lForca := EXECBLOCK("LOCA59G",.T.,.T.,{})
			EndIf

			If FQ5->(FIELDPOS("FQ5_NSC")) > 0
				If Empty((cQryT3)->FQ5_NSC) .or. lForca
					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					If lLOCA59H
						EXECBLOCK("LOCA59H",.T.,.T.,{})
					EndIf
					If !Empty((cQryT3)->CLIFPA)
						cCliSC := alltrim((cQryT3)->CLIFPA)
					ElseIf !Empty((cQryT3)->CLIFP1)
						cCliSC := alltrim((cQryT3)->CLIFP1)
					ElseIf !Empty((cQryT3)->FQ5_NOMCLI)
						cCliSC := alltrim((cQryT3)->FQ5_NOMCLI)
					Else
						cCliSC := alltrim((cQryT3)->CLIFP0)
					EndIf
					aadd(aBusca,	{	.f.								, ;
										alltrim((cQryT3)->FPA_OBRA)		, ;
										alltrim((cQryT3)->FPA_SEQGRU)	, ;
										alltrim((cQryT3)->FPA_AS)		, ;
										alltrim((cQryT3)->FPA_PRODUT)	, ;
										cCliSC							, ;
										(cQryT3)->FPA_QUANT				, ;
										(cQryT3)->RECNOFPA				, ;
										(cQryT3)->RECNOFQ5				})
				EndIf
			EndIf

			(cQryT3)->(dbSkip())
		EndDo
	Else
		lRet := .F.
		FwAlertInfo(STR0256, STR0022) // "Não existem itens que possam gerar Solicitação de Compras"   //"Atenção!"
	EndIf
	(cQryT3)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraSc

Gera solicitações de compras a partir de AS sem equipamentos indicados
@type Function
@author Jose Eulalio
@since 14/04/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Static Function GeraSc()
Local cDoc 		:= ""
Local cItem		:= ""
Local cListaSC	:=  STR0257 + ": " + CRLF //"Solicitações de Compras incluídas com sucesso: "
Local nX 		:= 0
Local nY 		:= 0
Local nTamItem	:= TamSx3("C1_ITEM")[1]
Local aCabSC 	:= {}
Local aItens 	:= {}
Local aItensSC 	:= {}
Local aLinhaC1 	:= {}
Local aAreaFQ5 	:= FQ5->(GetArea())
Local aAreaFPA 	:= FPA->(GetArea())
Local aHeaderAux:= {}
Local lLOCX051	:= SuperGetMV("MV_LOCX051",.F.,.F.)
Local lLOCA59J  := EXISTBLOCK("LOCA59J")
Local lLOCA59K  := EXISTBLOCK("LOCA59K")
Local lLOCA59L  := EXISTBLOCK("LOCA59L")
Local lAheader  := Type("aHeader") == "A"

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

	For nX := 1 To Len(oBuscaBrw:oData:aArray)
		If oBuscaBrw:oData:aArray[nX][1]
			Aadd(aItens, {oBuscaBrw:oData:aArray[nX][5],oBuscaBrw:oData:aArray[nX][7],oBuscaBrw:oData:aArray[nX][9]})
		EndIf
	Next nX

	//Begin TRANSACTION

	For nX := 1 To Len(aItens)

		//Limpa as variáveis para a rotina automática
		aCabSC 		:= {}
		aItensSC	:= {}
		aLinhaC1 	:= {}
		//cItem		:= StrZero(nx,nTamItem)
		cItem		:= StrZero(1,nTamItem)

		//| Verifica numero da SC |
		cDoc := GetSXENum("SC1","C1_NUM")
		SC1->(dbSetOrder(1))
		lForca := .F.
		If lLOCA59J
			lForca := EXECBLOCK("LOCA59J",.T.,.T.,{})
		EndIf
		While SC1->(dbSeek(xFilial("SC1") + cDoc)) .or. lForca
			ConfirmSX8()
			cDoc := GetSXENum("SC1","C1_NUM")
			If lforca
				exit
			EndIf
		EndDo

		//| Monta cabecalho |
		aadd(aCabSC,{"C1_NUM" 		, cDoc					})
		aadd(aCabSC,{"C1_SOLICIT"	, UsrRetName(__cUserID)	})
		aadd(aCabSC,{"C1_EMISSAO"	, dDataBase				})

		aadd(aLinhaC1,{"C1_ITEM" 	, cItem						,Nil})

		lForca := .F.
		If lLOCA59K
			lForca := EXECBLOCK("LOCA59K",.T.,.T.,{})
		EndIf

		If aItens[nX][3] > 0 .and. !lForca
			FQ5->(DbGoTo(aItens[nX][3]))
			aadd(aLinhaC1,{"C1_PRODUTO"	, FQ5->FQ5_XPROD 			,Nil})
			aadd(aLinhaC1,{"C1_QUANT" 	, FQ5->FQ5_XQTD  			,Nil})
			aadd(aLinhaC1,{"C1_DATPRF" 	, FQ5->FQ5_DATINI  			,Nil})
			aadd(aLinhaC1,{"C1_OBS" 	, FQ5->FQ5_OBSCOM  			,Nil})
			//posiciona no armazém da FPA
			FPA->(DBSETORDER(3))
			If FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_AS))
				aadd(aLinhaC1,{"C1_LOCAL" 	, FPA->FPA_LOCAL  			,Nil})
			EndIf
			//envia Classe Valor
			If lLOCX051
				aadd(aLinhaC1,{"C1_CLVL" 	, FQ5->FQ5_AS      		,Nil})
			EndIf
		Else
			aadd(aLinhaC1,{"C1_PRODUTO"	, AllTrim(aItens[nX][1])	,Nil})
			aadd(aLinhaC1,{"C1_QUANT" 	, aItens[nX][2] 			,Nil})
		EndIf
		aadd(aItensSC,aLinhaC1)

		//Guardo o aHeader atual para não causar problema na rotina automática
		If lAheader //Type("aHeader") == "A"   // Frank em 03/08/23
			aHeaderAux 	:= aClone(aHeader)
			aHeader		:= {}
		EndIf

		//| Teste de Inclusao - Execução Rotina Automática |
		MSExecAuto({|x,y| mata110(x,y)},aCabSC,aItensSC)

		//Restauro o aHeader
		If lAheader //Type("aHeader") == "A"   // Frank em 03/08/23
			aHeader := aClone(aHeaderAux)
		EndIf

		lForca := .F.
		If lLOCA59L
			lForca := EXECBLOCK("LOCA59L",.T.,.T.,{})
		EndIf

		If !lMsErroAuto .and. !lForca
			cListaSC += cDoc + CRLF
		Else
			MostraErro()
			aErrPCAuto := GETAUTOGRLOG()
			For nY := 1 to Len(aErrPCAuto)
				//Conout(aErrPCAuto[nY])
			Next nY
			//DisarmTransaction()
			Exit
		EndIf

		//Grava na FQ5
		If aItens[nX][3] > 0
			FQ5->(DbGoTo(aItens[nX][3]))
			RecLock("FQ5",.F.)
				If FQ5->(FIELDPOS("FQ5_NSC")) > 0
					FQ5->FQ5_NSC := cDoc
					FQ5->FQ5_ISC := cItem
				EndIf
			FQ5->(MsUnlock())
		EndIf

	Next nX

	If !lMsErroAuto
		FwAlertSuccess(cListaSC,STR0258) //"Sucesso"
	EndIf

	//End TRANSACTION

	RestArea(aAreaFQ5)
	RestArea(aAreaFPA)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiSc

Exclui solicitações de compras geradas no apontador
@type Function
@author Jose Eulalio
@since 13/05/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Function LOCA05930()
Local cDoc
Local lLOCA59M  := EXISTBLOCK("LOCA59M")

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	nForca := 0
	If FQ5->(FIELDPOS("FQ5_NSC")) > 0
		cDoc	:= FQ5->FQ5_NSC
	Else
		cDoc    := ""
	EndIF
	If lLOCA59M
		nForca := EXECBLOCK("LOCA59M",.T.,.T.,{})
	EndIf
	If !(Empty(cDoc)) .or. nForca == 1
		ExcluiSc(cDoc)
	ElseIf Empty(cDoc) .or. nForca == 2
		FWAlertWarning("Não existe Solicitação de Compras para esta Autorização de Serviço!",STR0022) //"Atenção!"
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiSc

Exclui solicitações de compras geradas no apontador
@type Function
@author Jose Eulalio
@since 13/05/2022
@see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=318605213

/*/
//------------------------------------------------------------------------------
Static Function ExcluiSc(cDoc)
Local nY		:= 0
Local aCabSC	:= {}
Local aItensSC 	:= {}
Local aRateioCX := {}
Local aAreaSC1	:= SC1->(GetArea())
Local lContinua	:= .T.
Local lLOCA59N  := EXISTBLOCK("LOCA59N")
Local lLOCA59O  := EXISTBLOCK("LOCA59O")

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

	//verifica se já gerou pedido de compras
	SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
	lForca := .F.
	If lLOCA59N
		lForca := EXECBLOCK("LOCA59N",.T.,.T.,{})
	EndIf
	If SC1->(DbSeek(xFilial("SC1") + cDoc)) .or. lForca
		If !(Empty(SC1->C1_PEDIDO)) .or. lForca
			lContinua := .F.
			FWAlertWarning(STR0262 + AllTrim(cDoc) + STR0263,STR0022) // "A Solicitação de Compras " + cDoc + " não pode ser excluída, pois já gerou Pedido de Compras." ####  "Atenção!"
		EndIf
	EndIf

	If lContinua

		//Begin TRANSACTION

		aadd(aCabSC,{"C1_NUM" 		,cDoc		})
		aadd(aCabSC,{"C1_SOLICIT"	,cUserName 	})
		aadd(aCabSC,{"C1_EMISSAO"	,dDataBase	})

		MSExecAuto({|w,x,y,z| MATA110(w,x,y,,,z)},aCabSC,aItensSC,5,aRateioCX)
		lForca := .F.
		If lLOCA59O
			lForca := EXECBLOCK("LOCA59O",.T.,.T.,{})
		EndIf

		If !lMsErroAuto .and. !lForca
			RecLock("FQ5",.F.)
			If FQ5->(FIELDPOS("FQ5_NSC")) > 0
				FQ5->FQ5_NSC := ""
				FQ5->FQ5_ISC := ""
			EndIf
			FQ5->(MsUnlock())
			FwAlertSuccess(STR0262 + AllTrim(cDoc) + STR0264,STR0258) //"A Solicitação de Compras " + cDod + " foi excluída!" #### "Sucesso"
		Else
			MostraErro()
			aErrPCAuto := GETAUTOGRLOG()
			For nY := 1 to Len(aErrPCAuto)
				//Conout(aErrPCAuto[nY])
			Next nY
			//DisarmTransaction()
		EndIf

		//End TRANSACTION
	EndIf

	RestArea(aAreaSC1)

Return

Function LOCA05932
	lExibe := .T.
Return ST9->T9_CODBEM

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05929

Consulta específica que substitui o Filtro adicional na consulta padrão ST9002 (Function LOCA05927), a consulta atual é ST9003
@type Function
@author Jose Eulalio
@since 12/05/2022
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018949211-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Consulta-espec%C3%ADfica

/*/
//------------------------------------------------------------------------------
Function LOCA05929()
Local aCpos  	:= {}
Local aRet   	:= {}
Local cQuery 	:= ""
Local cQueryNew	:= ""
Local cAlias 	:= GetNextAlias()
Local cAliasT9 	:= GetNextAlias()
Local cEquipAtu := " "
Local cPlaDesc	:= AllTrim(ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="PLADESC"})])
Local cFamilia	:= CriaVar("T9_CODFAMI", .T.)
Local cModelo	:= CriaVar("T9_TIPMOD", .T.)
Local cTroqEq	:= ""
Local cPesq 	:= Space(50)
Local cProduto  := ""
Local oDlg
Local oLbx
Local lLOCA59P  := EXISTBLOCK("LOCA59P")
Local aArea     := GetArea()
Local lLOCA59XA := EXISTBLOCK("LOCA59XA")
Local lLOCA59XB := EXISTBLOCK("LOCA59XB")
Local lMinuta   := .F. // Card 603 - Frank em 08/11/23
Local aBindParam := {}

Private lPadrao	:= AllTrim(AHEADER[ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPNV"}),9]) == "ST9003"
Private aLstBxOri	:= {}

// Rossana - estava dando erro quando preenchia no local
If !Empty(ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])
	cEquipAtu := AllTrim(ACOLS[N,ASCAN(OLBX1:AHEADER,{|X|ALLTRIM(X[2])=="EQUIPAT"})])
EndIf
	//query para recuperar Produto, Familia e Modelo do Equipamento atual
	cQuery	:= " SELECT T9_CODESTO, T9_CODFAMI, T9_MODELO, T9_TIPMOD FROM " + RetSqlName("ST9") + " "
	cQuery	+= " WHERE T9_CODBEM = ? "
	cQuery	+= " AND T9_FILIAL = '" + xFilial("ST9") + "' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "

	Aadd(aBindParam, cEquipAtu )
	cQueryNew := ChangeQuery(cQuery)
	MPSysOpenQuery(cQueryNew, cAliasT9,,, aBindParam)

	lForca := .F.
	If lLOCA59XA
		lForca := EXECBLOCK("LOCA59XA",.T.,.T.,{})
	EndIf

	If (cAliasT9)->(!EOF()) .or. lForca
		cFamilia := (cAliasT9)->T9_CODFAMI
		cModelo  := (cAliasT9)->T9_TIPMOD
	EndIf

	(cAliasT9)->(dbCloseArea())

	//retorna a opção do tipo de troca de equipamento da obra
	FPA->(dbSetOrder(6)) //FPA_FILIAL+FPA_PROJET+FPA_AS
	If FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_SOT+FQ5->FQ5_AS))
		FP1->(dbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
		If FP1->(dbSeek(xFilial("FPA")+ FPA->(FPA_PROJET + FPA_OBRA)))
			//olha campo novo
			If FP1->(fieldPos("FP1_TROCEQ")) > 0
				cTroqEq := FP1->FP1_TROCEQ
			EndIf
		EndIf
	EndIf

	//se tiver equipamento, pega produto da ST9
	If !empty(cEquipAtu)
		ST9->(dbSetOrder(1))
		If ST9->(dbSeek(xFilial("ST9")+cEquipAtu))
			cProduto := ST9->T9_CODESTO
			If empty(ST9->T9_STATUS)
				lMinuta := .T.
			EndIf
		EndIF
	//Se não tiver pega o código do produto que vem na descrição
	Else
		cProduto := SubStr(cPlaDesc,1,At("|",cPlaDesc)-1)
	EndIF

	//query para filtrar os bens disponíveis e dentro da regra de produto, familia e modelo
	aBindParam := {}
	cQuery	:= " SELECT DISTINCT T9_CODBEM, T9_NOME,T9_CODESTO, T9_CODFAMI,T9_MODELO,T9_TIPMOD FROM " + RetSqlName("ST9")
	cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
	cQuery	+= " AND D_E_L_E_T_ = ' '  "
	cQuery	+= " AND T9_SITMAN = 'A' "
	cQuery	+= " AND T9_SITBEM = 'A' "
	If !lMinuta // Card 603 - Frank em 08/11/23
		cQuery	+= " AND T9_STATUS IN ('  ','00')"  //" AND T9_STATUS = '00'" // Rossana - 25/06/24 / DSERLOCA - 3350
	Else
		cQuery	+= " AND T9_STATUS = '  ' "
	EndIF
	cQuery  += " AND T9_CODBEM <> ? "
	Aadd(aBindParam, cEquipAtu )

	nForca := 0
	If lLOCA59XB
		nForca := EXECBLOCK("LOCA59XB",.T.,.T.,{})
	EndIf

	//filtro de Acordo a escolha
	If cTroqEq == "2" .or. nForca == 1 // Produto OU Familia
		cQuery	+= " AND (T9_CODESTO = ?  "
		Aadd(aBindParam, cProduto )
		If !Empty(cFamilia)
			cQuery	+= " OR T9_CODFAMI = ? "
			Aadd(aBindParam, cFamilia )
		EndIf
		cQuery	+= ")"
	ElseIf cTroqEq == "3" .or. nForca == 2 // Produto E Modelo
		cQuery	+= " AND (T9_CODESTO = ?  "
		Aadd(aBindParam, cProduto)
		cQuery	+= " AND T9_TIPMOD <> '' "
		cQuery	+= " AND T9_TIPMOD = ? )"
		Aadd(aBindParam, cModelo)
	ElseIf cTroqEq == "4" .or. nForca == 3 .or. nForca == 4 // Produto OU Modelo OU Familia
		cQuery	+= " AND (T9_CODESTO = ?  "
		Aadd(aBindParam, cProduto)
		If !Empty(cFamilia) .or. nforca == 3
			cQuery	+= " OR T9_CODFAMI = ? "
			Aadd(aBindParam, cFamilia )
		EndIf
		If !Empty(cModelo) .or. nforca == 4
			cQuery	+= " OR T9_TIPMOD = ? "
			Aadd(aBindParam, cModelo)
		EndIf
		cQuery	+= ")"
	Else
		cQuery	+= " AND T9_CODESTO = ?  "
		Aadd(aBindParam, cProduto)
	EndIf

	cQuery += " ORDER BY 1 "

	cQuery := CHANGEQUERY(cQuery)

	MPSysOpenQuery(cQuery, cAlias,,, aBindParam)

	While (cAlias)->(!Eof())
		//aAdd(aCpos,{(cAlias)->(T9_CODBEM), (cAlias)->(T9_NOME), (cAlias)->(T9_CODESTO), (cAlias)->(T9_CODFAMI), (cAlias)->(T9_MODELO)})
		aAdd(aCpos,{(cAlias)->(T9_CODBEM), (cAlias)->(T9_NOME), (cAlias)->(T9_CODESTO), (cAlias)->(T9_CODFAMI), (cAlias)->(T9_TIPMOD)})
		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

	lForca := .F.
	If lLOCA59P
		lForca := EXECBLOCK("LOCA59P",.T.,.T.,{})
	EndIf

	//caso seja consulta ST9003, sempre exibe ao selecionar a lupa
	If lPadrao
		lExibe := .T.
	EndIf

	If lExibe
		lRet 	:= .F.
		lExibe 	:= .F.
		If ((Len(aCpos) < 1 ) .or. lForca) .and. !lMinuta // Card 603 - Frank em 08/11/23
			//aAdd(aCpos,{" "," "," "," "," "})
			//pergunta se deseja gerar Solicitação de Compras
			If MsgYesNo(STR0286, STR0287) //"Deseja gerar Solicitação de Compras?" ###  "Sem produtos para indicar"
				//Gera Solicitação de Compras
				LOCA05928()
			EndIf
		Else

			If Len(aCpos) > 0
				//monta a tela da consulta
				DEFINE MSDIALOG oDlg TITLE STR0259 FROM 0,0 TO 320,700 PIXEL	// "Equipamentos disponíveis"
					//Texto de pesquisa
					@ 003,002 MsGet oPesqEv Var cPesq Size 292,009 COLOR CLR_BLACK PIXEL OF oDlg

					//Interface para selecao de indice e filtro
					@ 003,295 Button STR0002    Size 043,012 PIXEL OF oDlg Action IF(!Empty(oLbx:aArray[oLbx:nAt][2]),ITPESQ(oLbx,cPesq),Nil) //Pesquisar

					@ 023,003 LISTBOX oLbx FIELDS HEADER STR0225, STR0260, STR0126, STR0223, STR0261 SIZE 345,115 OF oDlg PIXEL	// 'Bem' ### 'Descrição' ### 'Produto' ### 'Familia' ### 'Modelo'
					oLbx:SetArray( aCpos )
					//copia array original
					aLstBxOri := aClone(oLbx:aArray)
					oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}}
					oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4], oLbx:aArray[oLbx:nAt,5]}}}
				DEFINE SBUTTON FROM 140,318 TYPE 1 ACTION (oDlg:End(),  lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4], oLbx:aArray[oLbx:nAt,5]})  ENABLE OF oDlg
				ACTIVATE MSDIALOG oDlg CENTER

				//retorna o resultado
				If Len(aRet) > 0 .And. lRet .or. lForca
					If Empty(aRet[1]) .or. lForca
						lRet := .F.
						cEscolhe := ""
					Else
						//If alltrim(ST9->T9_CODBEM) == alltrim(aRet[1])
						//	lRet := .T.
							cEscolhe := aRet[1]
							//caso seja consulta ST9003, posiciona na ST9
							If lPadrao
								ST9->(dbSetOrder(1))
								ST9->(dbSeek(xFilial("ST9")+aRet[1]))
							EndIf
						//EndIF
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIF
		EndIf
	Else
		If len(ST9->T9_CODBEM) == len(cEscolhe) .and. ST9->T9_CODBEM == cEscolhe
			lRet := .T.
		Else
			lRet := .F.
		EndIF
	EndIf
	RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05931

Retorna Cliente do do Conjunto Transportador
@type Function
@author Jose Eulalio
@since 27/05/2022

/*/
//------------------------------------------------------------------------------
Function LOCA05931(cCampo)
Local cRet		:= ""
Local aAreAtu	:= GetArea()
Local aAreFp1	:= FP1->(GetArea())
Local aAreFq7	:= FQ7->(GetArea())
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador será o utilizado como cliente da nota fiscal de remessa,
Local nPosVirt	:= 0

	nPosVirt:= TamSx3(cCampo)[1]

	// 27/10/2022 - Jose Eulalio - SIGALOC94-499 - Em teste com Analista Lucas essa variável não estava retornando o valor correto com Type, o que causava erro
	//If lLOCX304 .and. Type("nPosVirt") == "N" .And. nPosVirt > 0
	If lLOCX304 .and. ValType(nPosVirt) == "N" .And. nPosVirt > 0
		FQ7->(DbSetOrder(3)) // FQ7_FILIAL + FQ7_VIAGEM
		If FQ7->(DbSeek(xFilial("FQ7") + FQ2->FQ2_VIAGEM))
			//SE ENVIO
			If FQ2->FQ2_TPROMA == "0"
				If cCampo == "FQ2_CLIFAT"
					cRet	:= FQ7->FQ7_LCCDES
				ElseIf cCampo == "FQ2_LOJFAT"
					cRet	:= FQ7->FQ7_LCLDES
				ElseIf cCampo == "FQ2_NOMFAT"
					cRet	:= FQ7->FQ7_LOCDES
				EndIf
			//SE RETORNO
			Else
				If cCampo == "FQ2_CLIFAT"
					cRet	:= FQ7->FQ7_LCCORI
				ElseIf cCampo == "FQ2_LOJFAT"
					cRet	:= FQ7->FQ7_LCLORI
				ElseIf cCampo == "FQ2_NOMFAT"
					cRet	:= FQ7->FQ7_LOCCAR
				EndIf
			EndIf
		EndIf
	EndIf

	//Caso não venha do parâmetro, busca da Obra
	If Empty(cRet)
		FP1->(DbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
		If FP1->(DbSeek(xFilial("FP1") + FQ2->(FQ2_PROJET + FQ2_OBRA)))
			If cCampo == "FQ2_CLIFAT"
				cRet	:= FP1->FP1_CLIORI
			ElseIf cCampo == "FQ2_LOJFAT"
				cRet	:= FP1->FP1_LOJORI
			ElseIf cCampo == "FQ2_NOMFAT"
				cRet	:= FP1->FP1_NOMORI
			EndIf
		EndIf
	EndIf

	RestArea(aAreAtu)
	RestArea(aAreFp1)
	RestArea(aAreFq7)

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ITPESQEV

Funcao para pesquisar dentro da consulta padrao SXB
@type  Function
@author Jose Eulalio
@since 16/09/2022

/*/
//------------------------------------------------------------------------------
Static Function ITPESQ(oLstBx,cPesq)
Local _nX
Local _nY
Local nTamArray	:= len(oLstBx:aArray)
Local nContArra	:= 1
Local _lAchou 	:= .F.
Local aLstBxNew	:= {}
Local lLOCA59XC  := EXISTBLOCK("LOCA59XC")

	lForca := .F.
	If lLOCA59XC
		lForca := EXECBLOCK("LOCA59XC",.T.,.T.,{})
	EndIf

	If empty(cPesq) .Or. Len(cPesq) < 2 .or. lForca
		MsgAlert(STR0288,STR0022)	// "Favor informar o que deseja pesquisar " ##### "Atenção!"
		oLstBx:setarray(aLstBxOri)
		oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
								aLstBxOri[oLstBx:nAt,2],;
								aLstBxOri[oLstBx:nAt,3],;
								aLstBxOri[oLstBx:nAt,4],;
								aLstBxOri[oLstBx:nAt,5]}}
		oLstBx:nAt := 1
		oLstBx:Refresh()
	Else
		//Busca a partir da linha posicionada + 1
		For _nx := 1 to nTamArray
			For _nY := 1 to 5
				If UPPER(AllTrim(cPesq)) $ UPPER(alltrim(oLstBx:aArray[_nX,_nY]))
					Aadd(aLstBxNew,oLstBx:aArray[_nX])
					Exit
				EndIf
				++nContArra
			Next _nY
		Next _nx
		If Len(aLstBxNew) > 0
			_lAchou := .T.
			aSort(aLstBxNew,,,{|x,y| x[1]+x[5] < y[1]+y[5]})
			oLstBx:setarray(aLstBxNew)
			oLstBx:bLine 	:= {|| {aLstBxNew[oLstBx:nAt,1],;
									aLstBxNew[oLstBx:nAt,2],;
									aLstBxNew[oLstBx:nAt,3],;
									aLstBxNew[oLstBx:nAt,4],;
									aLstBxNew[oLstBx:nAt,5]}}
			oLstBx:nAt := 1
			oLstBx:Refresh()
		EndIf
		If !_lAchou
			If nContArra >= nTamArray
				MsgAlert(STR0289,STR0022)	// "Não localizado." ##### "Atenção!"
				oLstBx:setarray(aLstBxOri)
				oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
										aLstBxOri[oLstBx:nAt,2],;
										aLstBxOri[oLstBx:nAt,3],;
										aLstBxOri[oLstBx:nAt,4],;
										aLstBxOri[oLstBx:nAt,5]}}
				oLstBx:nAt := 1
				oLstBx:Refresh()
			//Else
				//oLstBx:nAt := 1
			EndIf
		EndIf
	EndIf
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ITPESQ5916

Funcao para pesquisar dentro da consulta padrao SXB
@type Function
@author Jose Eulalio
@since 16/09/2022

/*/
//------------------------------------------------------------------------------
Static Function ITPESQ5916(oLstBx,cPesq)
Local _nX
Local _nY
Local nTamArray	:= len(oLstBx:aArray)
Local nContArra	:= 1
Local _lAchou 	:= .F.
Local aLstBxNew	:= {}
Local lLOCA59XD := EXISTBLOCK("LOCA59XD")
Local lLOCA59XE := EXISTBLOCK("LOCA59XE")

	lForca := .F.
	If lLOCA59XD
		lForca := EXECBLOCK("LOCA59XD",.T.,.T.,{})
	EndIf

	lForca1 := .F.
	If lLOCA59XE
		lForca1 := EXECBLOCK("LOCA59XE",.T.,.T.,{})
	EndIf


	If empty(cPesq) .Or. Len(cPesq) < 2 .or. lForca
		MsgAlert(STR0288,STR0022) // "Favor informar o que deseja pesquisar " ##### "Atenção!"
		oLstBx:setarray(aLstBxOri)
		aLinha := AClone(aLstBxOri)
		oLstBx:bLine 	:= {|| {IF( aLstBxOri[oLstBx:nAt,1],OOK,ONO),;
									aLstBxOri[oLstBx:nAt,2],;
									aLstBxOri[oLstBx:nAt,3],;
									aLstBxOri[oLstBx:nAt,4],;
									aLstBxOri[oLstBx:nAt,5],;
									aLstBxOri[oLstBx:nAt,6],;
									aLstBxOri[oLstBx:nAt,7],;
									aLstBxOri[oLstBx:nAt,9],;
									aLstBxOri[oLstBx:nAt,10],;
									aLstBxOri[oLstBx:nAt,11]}}
		oLstBx:nAt := 1
		oLstBx:Refresh()
	Else
		//Busca a partir da linha posicionada + 1
		For _nx := 1 to nTamArray
			For _nY := 1 to 11
				If UPPER(AllTrim(cPesq)) $ UPPER(alltrim(oLstBx:aArray[_nX,_nY]))
					Aadd(aLstBxNew,oLstBx:aArray[_nX])
					Exit
				EndIf
				++nContArra
			Next _nY
		Next _nx
		If Len(aLstBxNew) > 0
			_lAchou := .T.
			aSort(aLstBxNew,,,{|x,y| x[2] < y[2]})
			aLinha := AClone(aLstBxNew)
			oLstBx:setarray(aLstBxNew)
			oLstBx:bLine 	:= {|| {IF( aLstBxNew[oLstBx:nAt,1],OOK,ONO),;
										aLstBxNew[oLstBx:nAt,2],;
										aLstBxNew[oLstBx:nAt,3],;
										aLstBxNew[oLstBx:nAt,4],;
										aLstBxNew[oLstBx:nAt,5],;
										aLstBxNew[oLstBx:nAt,6],;
										aLstBxNew[oLstBx:nAt,7],;
										aLstBxNew[oLstBx:nAt,9],;
										aLstBxNew[oLstBx:nAt,10],;
										aLstBxNew[oLstBx:nAt,11]}}
			oLstBx:nAt := 1
			oLstBx:Refresh()
		EndIf

		If !_lAchou .or. lForca1
			If nContArra >= nTamArray .or. lForca1
				MsgAlert(STR0289,STR0022) // "Não localizado." ####  "Atenção!"
				oLstBx:setarray(aLstBxOri)
				aLinha := AClone(aLstBxOri)
				oLstBx:bLine 	:= {|| {IF( aLstBxOri[oLstBx:nAt,1],OOK,ONO),;
											aLstBxOri[oLstBx:nAt,2],;
											aLstBxOri[oLstBx:nAt,3],;
											aLstBxOri[oLstBx:nAt,4],;
											aLstBxOri[oLstBx:nAt,5],;
											aLstBxOri[oLstBx:nAt,6],;
											aLstBxOri[oLstBx:nAt,7],;
											aLstBxOri[oLstBx:nAt,9],;
											aLstBxOri[oLstBx:nAt,10],;
											aLstBxOri[oLstBx:nAt,11]}}
				oLstBx:nAt := 1
				oLstBx:Refresh()
			//Else
				//oLstBx:nAt := 1
			EndIf
		EndIf
	EndIf
Return .T.



/*/{PROTHEUS.DOC} LOCA059.PRW
ITUP BUSINESS - TOTVS RENTAL
APONTADOR AS
@TYPE FUNCTION
@AUTHOR FRANKC
@SINCE 31/08/2021
@VERSION P12
/*/
STATIC FUNCTION GERANUMAS( PSRV , PPROJETO, POBRA, PSEQ, PFILIAL)

LOCAL AAREA     := GETAREA()
LOCAL AAREADTQ  := FQ5->(GETAREA())
LOCAL LCONTINUA := .T.
LOCAL CSERVICO  := ALLTRIM( PSRV )
LOCAL CPROJETO  := SUBSTR( ALLTRIM( PPROJETO ), 5, 5 )
LOCAL COBRA     := ALLTRIM( POBRA )
LOCAL CNEWSEQ   := ALLTRIM( IIF( VALTYPE(PSEQ) == "N", STRZERO(PSEQ, 3), PSEQ ) )
LOCAL _CFILIAL  := ALLTRIM( PFILIAL )
Local lLOCA59XE := EXISTBLOCK("LOCA59XE")

	nForca := 0
	If lLOCA59XE
		nForca := EXECBLOCK("LOCA59XE",.T.,.T.,{})
	EndIf

	IF LEN( CSERVICO ) != 2 .or. nForca == 1
		FINAL(STR0278+CSERVICO+STR0279, STR0280) // "Servico informado ["###"] invalido"###"GERANUMAS - Geracao de AS"
	ENDIF

	IF LEN( CPROJETO ) != 5 .or. nForca == 2
		FINAL(STR0281+CPROJETO+STR0282, STR0280) //"Projeto informado ["###"] invalido"###
	ENDIF

	IF LEN( COBRA ) != 3 .or. nForca == 3
		FINAL(STR0283+COBRA+STR0284, STR0280) // "Obra/Viagem informada ["###"] invalida"###
	ENDIF

	IF LEN( CNEWSEQ ) != 3 .or. nForca == 4
		CNEWSEQ := RIGHT( "000" + CNEWSEQ, 3 )
	ENDIF

	IF EMPTY( _CFILIAL ) .or. nForca == 5	 			// CASO NÃO TENHA CONTEÚDO
		_CFILIAL := REPLICATE("0", LEN( CFILANT ) )		// PREENCHE O TAMANHO DO XFILIAL() COM ZEROS
	ENDIF

	FQ5->(DBSETORDER(9))								// FQ5_FILIAL + FQ5_AS + FQ5_VIAGEM
	WHILE LCONTINUA
		CNRAS     := CSERVICO + CPROJETO + COBRA + CNEWSEQ + _CFILIAL
		LCONTINUA := FQ5->(DBSEEK( XFILIAL("FQ5") + CNRAS, .T.))
		CNEWSEQ   := SOMA1(CNEWSEQ)
	ENDDO

	FQ5->(RESTAREA(AAREADTQ))
	RESTAREA( AAREA )

RETURN CNRAS

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05933

Valid do Equipamento novo na rotina de Troca de Equipamento
@type Function
@author Jose Eulalio
@since 01/11/2022

/*/
//------------------------------------------------------------------------------
Function LOCA05933()
Local lRet		:= .T.
Local cEquip	:= EquipNv
Local nX		:= 0
Local nPosEqNv	:= Ascan(oLbx1:aHeader,{|X|AllTrim(X[2])=="EQUIPNV"})
Local aAreaSt9	:= ST9->(GetArea())
Local lLOCA59XF := EXISTBLOCK("LOCA59XF")
Local lLOCA59XG := EXISTBLOCK("LOCA59XG")

	nForca := 0
	If lLOCA59XF
		nForca := EXECBLOCK("LOCA59XF",.T.,.T.,{})
	EndIf

	If lLOCA59XG
		EquipNv := EXECBLOCK("LOCA59XG",.T.,.T.,{EquipNv})
	EndIf

	//Se estiver preenchido
	If !Empty(EquipNv) .or. nForca == 1 .or. nForca == 2
		//Verifica se está disponível
		ST9->(DbSetOrder(1)) //T9_FILIAL + T9_CODBEM
		If ST9->(DbSeek(xFilial("ST9") + EquipNv)) .And. !(ST9->T9_STATUS $ "  |00") .or. nforca == 1
			Help(	Nil,	Nil, "LOCA05933_01",;
					Nil,STR0290,1,0,Nil,Nil,Nil,Nil,Nil,; //"Equipamento não disponível"
					{STR0293}) //"Informe um Equipamento válido"
			lRet := .F.

		Else

			// Verificar se o equipamento está num substatus que não permite a locação
			// DSERLOCA-3906 - Cicenis - Desabilitado pq agora o status do bem sempre volta pra disponivel (Rossana)
			//if FindFunction("LOCA224G") .and. LOCA224G(EquipNv, .T.)
			//	lRet := .F.*/
			//Else
			//Percorre todo o aCols
			For nX := 1 To Len(oLbx1:aCols)
				//se for linha diferente, verifica se já existe equipamento em outra linha
				If oLbx1:nAt <> nX .And. oLbx1:aCols[nX][nPosEqNv] == cEquip .or. nForca == 2
					Help(	Nil,	Nil, "LOCA05933_02",;
							Nil,STR0291,1,0,Nil,Nil,Nil,Nil,Nil,; //"Equipamento já informado"
							{STR0293}) //"Informe um Equipamento válido"
					lRet := .F.
					Exit
				EndIf
			Next nX
			//EndIf
		EndIf
	Else
		Help(	Nil,	Nil, "LOCA05933_03",;
				Nil,STR0292,1,0,Nil,Nil,Nil,Nil,Nil,; //"Equipamento não informado"
				{STR0293}) //"Informe um Equipamento válido"
		lRet := .F.
	EndIf

	RestArea(aAreaSt9)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsEqMinuta

Verifica se o Equipamento é para minuta, ou seja contém Status da ST9 vazio
@type Function
@author Jose Eulalio
@since 01/11/2022

/*/
//------------------------------------------------------------------------------
Static Function IsEqMinuta(cCodBem)
Local lRet		:= .F.
Local aAreaSt9	:= ST9->(GetArea())

	ST9->(DbSetOrder(1)) //T9_FILIAL + T9_CODBEM
	lRet := ST9->(DbSeek(xFilial("ST9") + cCodBem)) .And. Empty(ST9->T9_STATUS)

	RestArea(aAreaSt9)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA059T

Marcar/Desmarcar os registros da listbox do vínculo romaneio ao clicar no cabeçalho
@type Function
@author Frank Zwarg Fuga
@since 28/11/2022

/*/
//------------------------------------------------------------------------------
Static Function LOCA059T
Local lTemMarc := .F.
Local nX
Local lTodos   := .T.

	For nX := 1 to len(_aArray)
		If _aArray[nX][01]
			lTemMarc := .T.
		EndIf
		If lTemMarc .and. !_aArray[nX][01]
			lTodos := .F.
		EndIF
	Next

	If MsgYesNo(STR0294,STR0022) //"Deseja marcar/desmarcar os registros?"###"Atenção!"
		For nX := 1 to len(_aArray)
			If lTodos .and. !lTemMarc
				_aArray[nX][01] := .T.
			EndIF
			If lTodos .and. lTemMarc
				_aArray[nX][01] := .F.
			EndIF
			If !lTodos .and. lTemMarc
				_aArray[nX][01] := .T.
			EndIF
		Next
		oListBox:Refresh()
	EndIF

Return

// Frank Z Fuga em 08/05/23
// Rotina para pular para a próxima linha quando preenche o equipamento
function loca059X()
Local nVar 		:= OLBX1:nAt + 1
Local nColEquip	:= Ascan(oLbx1:aHeader,{|X|AllTrim(X[2])=="EQUIPNV"})
	If nVar <= len(OLBX1:aCols)
		n := nVar
		OLBX1:nAt := nVar
		OLBX1:obrowse:nat := nVar
		oLbx1:oBrowse:GoColumn(nColEquip) //posiciona na coluna do Equipamento novo
		OLBX1:Refresh()
		oTimer:deActivate()
	EndIF
Return

// Montagem do aRotina
// Frank em 17/11/23
// Card 1293
Static function menudef(aRotina, LFUNCAS, CSERV, MV_PAR03, LROMANEIO, _LTEMVINC )
Local aScFunc	:= {}
Local lLOCA59Q  := EXISTBLOCK("LOCA59Q")
Local lForca    := .F.

	aRotina := {}
	AADD(AROTINA     , {STR0002, "AXPESQUI"			, 0 , 01} )	// PESQUISAR //"Pesquisar"
	AADD(AROTINA     , {STR0003, "LOCA05902()"		, 0 , 02} )	// IMPRESSÃO DA  AS //"Imprime AS"

	IF LFUNCAS
		AADD(AROTINA , {STR0004, "LOCA05903()"		, 0 , 07} )	// FECHA         AS //"Fecha AS"
		AADD(AROTINA , {STR0005, "LOCA05904()"		, 0 , 07} )	// ENCERRA       AS //"Encerra AS"
		AADD(AROTINA , {STR0006, "LOCA05905()"		, 0 , 07} )	// REABERTURA DA AS //"Reabre AS"
		AADD(AROTINA , {STR0007, "Loca05910()"	, 0 , 07} ) //"Estornar AS"
		AADD(AROTINA , {STR0008, "LOCA05907()"		, 0 , 07} )	// REJEITA AS DO DIA //"Rejeita AS"
	ENDIF

	AADD(AROTINA, {STR0009, "LOCA05908()", 0 , 07} ) // ACEITA  AS SELECIONADA  //"Aceitar AS"

	IF CSERV == "F"
		AADD(AROTINA, {STR0010, "LOCA05913()", 0 , 02} ) // DIÁLOGO QUE PREENCHE ALGUNS CAMPOS  //"Programação ASF"
	ENDIF

	AADD(AROTINA, {STR0011, "LOCA05916()"	, 0 , 07} ) // TRATAMENTO AS POR LOTE  //"Lote"
	AADD(AROTINA, {STR0012, "LOCA05901"		, 0 , 07} ) // LEGENDA  //"Legenda"

	If lLOCA59Q
		lForca := EXECBLOCK("LOCA59Q",.T.,.T.,{})
	EndIf

	//Gerar SC
	If CSERV == "L"  .And. FQ5->(FIELDPOS("FQ5_NSC")) > 0 .or. lForca // verifica se o campo existe
		AADD(aScFunc, {"Geração"				, "LOCA05928" , 0 , 07}) //"Geração"
		AADD(aScFunc, {"Exclusão"              , "LOCA05930"  , 0 , 07}) //"Geração"
		AADD(AROTINA, {"Solicitação de Compras", aScFunc      , 0 , 07} ) // "Solicitação de Compras"
	EndIf

	If MV_PAR03 <> "F" // solicitação do Lui feito por Frank em 06/07/21
		AADD(AROTINA, {STR0013, "LOCA05919", 0 , 10} ) // TROCA EQUIPAMENTO  //"Trocar Equip."
	EndIf

	IF LROMANEIO
		AADD(AROTINA, {STR0014, "LOCA05925(FQ5->FQ5_AS)" , 0 , 07} ) // ROMANEIO		// --> ERA - P.E:  LOC05101(FQ5->FQ5_AS)  //"Romaneio"
	ENDIF

	If !LFUNCAS
		AADD(AROTINA, {STR0017, "Loca05910()", 0 , 07} ) //"Estornar AS"
	EndIf

Return aRotina

/*/{Protheus.doc} Loca05910
Chama a rotina de estorno da AS, usada para apresentar a mesagem do motivo do não
estrono da AS
@type function
@version  1
@author alecircenis
@since 5/1/2024
@return variant, Sempre .T.
/*/
Function Loca05910()
Local CAVISO

	// Controle de acesso por usar uma demanda - Frank em 23/04/2025
	If !LOCA059DE()
		Return
	EndIf

	CAVISO := LOCA05906(.T.)

	if !Empty(cAviso)
		MsgAlert(cAviso, STR0007) //"Estornar AS"
	endif

Return .T.

/*/{Protheus.doc} LOCA059A
Cria as Ordens de Serviço - SIGALOC-1982 - Implemento
@author Frank Zwarg Fuga
@since 8/5/2024
/*/
Function Loca059A()
Local lRet := .T.
Local aArea := GetArea()
Local FPAAREA := FPA->(GetArea())
Local aGerOS := {}
Local nX
Local nY
Local nZ
Local nSepara := 0
Local nRecno := 0
Local aRet
Local aEtapas := {}
Local aInsumos := {}
Local aServicos := {}
Local lTem := .F.
Local nTemp
Local cSeq
Local cTipHor := AllTrim(GetMv("MV_NGUNIDT"))
Local cAs
Local nReg
Local cCod
Local aOsGerada := {}
Local cResult

	FPA->(dbSetOrder(3))
	If FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_AS))
		FQG->(dbSetOrder(1))
		If FQG->(dbSeek(xFilial("FQG")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
			While !FQG->(Eof()) .and. FQG->(FQG_PROJET+FQG_OBRA+FQG_SEQ) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
				If FQG->FQG_GERAOS == "S"
					If empty(FQG->FQG_OS) .or. FQG->FQG_FEITO == "N" .or. FQG->FQG_FEITO == "C"
						nRecno := FQG->(RECNO())
						aadd(aGerOS,{FQG->FQG_SERV,0,nRecno,FPA->FPA_GRUA, FPA->FPA_AS})
					EndIf
				EndIf
				FQG->(dbSkip())
			EndDo
		EndIF
	EndIf

	If len(aGerOS) > 0
		// Separar em array os serviços diferentes
		For nX := 1 to len(aGerOS)
			lTem := .F.
			For nY := 1 to len(aServicos)
				If aServicos[nY][1] == aGerOS[nX][1]
					lTem := .T.
					Exit
				EndIf
			Next
			If !lTem
				//              serviço, aglutinador
				aadd(aServicos,{aGerOS[nX][1],0})
			EndIF
		Next

		nSepara := 1 // gerador do aglutinador

		// Nomear agrupadores dos serviços
		For nX := 1 to len(aServicos)
			aServicos[nX,2] := nSepara
			nSepara ++
		Next

		// passar os agrupadores para o array das OS
		For nX := 1 to len(aGerOS)
			For nY := 1 to len(aServicos)
				If aServicos[nY,1] == aGerOS[nX,1]
					nTemp := aServicos[nY,2]
					Exit
				EndIf
			Next
			aGerOS[nX,2] := nTemp
		Next

		If len(aGerOS) > 0
			// Preparar as etapas das os
			For nX := 1 to len(aServicos)
				For nY := 1 to len(aGerOS)
					If aGerOS[nY,2] == aServicos[nX,2]
						FQG->(dbGoto(aGerOS[nY,3]))
						If !empty(FQG->FQG_ETAPA)
							aadd(aEtapas,{aServicos[nX,1],FQG->FQG_ETAPA,aServicos[nX,2]})
						EndIf
					EndIf
				Next
			Next

			// Preparar os insumos das os
			For nX := 1 to len(aServicos)
				For nY := 1 to len(aGerOS)
					If aGerOS[nY,2] == aServicos[nX,2]
						FQG->(dbGoto(aGerOS[nY,3]))
						If !empty(FQG->FQG_PRODUT)
							aadd(aInsumos,{aServicos[nX,1],FQG->FQG_PRODUT,FQG->FQG_QTD,aServicos[nX,2]})
						EndIf
					EndIf
				Next
			Next
		EndIf

		For nX := 1 to len(aServicos)
			aRet := {}
			cSeq := "000"
			For nY := 1 to len(aGerOs)
				If aGerOs[nY,2] == aServicos[nX,2]
					If len(aRet) == 0
						FQG->(dbGoto(aGerOS[nY,3]))
						//                               bem            servico
						aRet := NGGERAOS("C", dDatabase, aGerOS[nX][4], aGerOS[nX][1], '0','N','N','N',cFilAnt,"L")
						If len(aRet) > 0

							aadd(aOsGerada,{aRet[1,3]})

							STJ->(RecLock("STJ",.F.))
							STJ->TJ_AS		:= aGerOs[nY,5]
							STJ->TJ_PROJETO	:= FQG->FQG_PROJET
							STJ->TJ_OBRA	:= FQG->FQG_OBRA
							STJ->(MsUnlock())
							For nZ := 1 to len(aGerOS)
								If aGerOs[nZ,2] == aGerOS[nY,2]
									FQG->(dbGoto(aGerOS[nZ,3]))
									FQG->(RecLock("FQG",.F.))
									FQG->FQG_OS := aRet[1,3]
									FQG->FQG_FEITO := "N"
									FQG->(MsUnlock())
								EndIf
							Next
							// Criar os insumos
							For nZ := 1 to len(aInsumos)
								If aInsumos[nZ,4] == aGerOS[nY,2]
									SB1->(dbSetOrder(1))
									SB1->(dbSeek(xFilial("SB1")+aInsumos[nZ,2]))
									STL->(RecLock("STL",.T.))
									STL->TL_FILIAL	:= xFilial("STL")
									STL->TL_ORDEM	:= aRet[1,3]
									STL->TL_PLANO	:= STJ->TJ_PLANO
									STL->TL_TAREFA  := "0     "
									STL->TL_SEQRELA	:= "0  "
									STL->TL_TIPOREG	:= "P"
									STL->TL_CODIGO	:= aInsumos[nZ,2]
									STL->TL_USACALE	:= "N"
									STL->TL_QUANTID	:= aInsumos[nZ,3]
									STL->TL_LOCAL	:= SB1->B1_LOCPAD
									STL->TL_UNIDADE := SB1->B1_UM
									STL->TL_DESTINO	:= "A"
									STL->TL_DTINICI	:= STJ->TJ_DTORIGI
									STL->TL_HOINICI	:= Time()
									STL->TL_SEQTARE	:= cSeq
									STL->TL_DTFIM   := STL->TL_DTINICI
									STL->TL_HOFIM   := STL->TL_HOINICI
									STL->TL_GARANTI := "N"
									STL->TL_TIPOHOR	:= cTipHor
									STL->(MsUnlock())
									cSeq := soma1(cSeq)
								EndIf
							Next
							// Criar as etapas
							cSeq := "000"
							For nZ := 1 to len(aEtapas)
								If aEtapas[nZ,3] == aGerOS[nY,2]
									STQ->(RecLock("STQ",.T.))
									STQ->TQ_FILIAL	:= xFilial("STQ")
									STQ->TQ_ORDEM	:= aRet[1,3]
									STQ->TQ_PLANO	:= STJ->TJ_PLANO
									STQ->TQ_ETAPA	:= aEtapas[nZ,2]
									STQ->TQ_SEQTARE	:= cSeq
									STQ->(MsUnlock())
									cSeq := soma1(cSeq)
								EndIf
							Next

							// Atualização do sub-status
							If !empty(STJ->TJ_DTPRINI) .or. !empty(STJ->TJ_DTPRFIM) .or. !empty(STJ->TJ_DTPPINI) .or. !empty(STJ->TJ_DTPPFIM) .or. file("\SYSTEM\LOCA059X1.TXT")
								cAs := STJ->TJ_AS
								nReg := 0
								cSeq := ""
								If !empty(cAs)
									FPA->(dbSetOrder(3))
									If FPA->(dbSeek(xFilial("FPA")+cAs))
										FQ4->(dbSeek(xFilial("FQ4")+STJ->TJ_CODBEM))
										While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+STJ->TJ_CODBEM
											If FQ4->FQ4_SEQ > cSeq
												cSeq := FQ4->FQ4_SEQ
												nReg := FQ4->(Recno())
											EndIf
											FQ4->(dbSkip())
										EndDo

										// Se nReg for 0 criar a FQ4
										If nReg == 0
											ST9->(dbSetOrder(1))
											ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))
											LOCXITU21("",ST9->T9_STATUS,"","","")
											FQ4->(RecLock("FQ4",.F.))
											FQ4->FQ4_OBRA   := ""
											FQ4->FQ4_AS     := ""
											FQ4->FQ4_CODCLI := ""
											FQ4->FQ4_NOMCLI := ""
											FQ4->FQ4_CODMUN := ""
											FQ4->FQ4_MUNIC  := ""
											FQ4->FQ4_EST    := ""
											FQ4->FQ4_DTINI  := ctod("")
											FQ4->FQ4_DTFIM  := ctod("")
											FQ4->FQ4_PREDES := ctod("")
											FQ4->FQ4_LOJCLI := ""
											If empty(FQ4->FQ4_PROJET)
												FQ4->FQ4_AS := ""
											EndIf
											FQ4->(MsUnlock())
										EndIf
										// Se nReg for > 0 posiconar na FQ4
										If nReg > 0
											FQ4->(dbGoto(nReg))
										EndIf

										// Localizar o movimento do substatus
										lTem := .F.
										FQF->(dbSetOrder(5)) // Codigo do bem
										FQF->(dbSeek(xFilial("FQF")+STJ->TJ_CODBEM))
										While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_CODBEM) == xFilial("FQF")+STJ->TJ_CODBEM
											If FQF->FQF_OS == STJ->TJ_ORDEM
												lTem := .T.
												Exit
											EndIf
											FQF->(dbSkip())
										EndDo
										
										If !lTem
											cCod := GetSx8Num("FQF","FQF_COD")
											ConfirmSx8()
											FQF->(RecLock("FQF",.T.))
										Else
											FQF->(RecLock("FQF",.F.))
										EndIF

										// Gerar o registro do sub-status
										FQF->FQF_FILIAL := xFilial("FQF") 
										FQF->FQF_CODBEM := STJ->TJ_CODBEM
										FQF->FQF_STATUS := FQ4->FQ4_STATUS
										FQF->FQF_CC     := FPA->FPA_CUSTO
										FQF->FQF_DTINI  := dDataBase
										FQF->FQF_HORA   := Time()
										FQF->FQF_SUBST  := ACHAFQH(FQ4->FQ4_STATUS, STJ->TJ_SERVICO)
										FQF->FQF_PROJET := FPA->FPA_PROJET
										FQF->FQF_AS     := cAs
										FQF->FQF_CONTA  := STJ->TJ_POSCONT
										FQF->FQF_SEQ    := FQ4->FQ4_SEQ
										FQF->FQF_OS     := STJ->TJ_ORDEM
										FQF->FQF_DPPINI := STJ->TJ_DTPPINI
										FQF->FQF_HPPINI := STJ->TJ_HOPPINI
										FQF->FQF_DPPFIM := STJ->TJ_DTPPFIM
										FQF->FQF_HPPFIM := STJ->TJ_HOPPFIM
										FQF->FQF_DPRINI := STJ->TJ_DTPRINI
										FQF->FQF_HPRINI := STJ->TJ_HOPRINI
										FQF->FQF_DPRFIM := STJ->TJ_DTPRFIM
										FQF->FQF_HPRFIM := STJ->TJ_HOPRFIM
										If !lTem
											FQF->FQF_COD    := cCod
										EndIf
										FQF->(MsUnlock())
									EndIf
								EndIf
							EndIf

						EndIf
					EndIf
				EndIf
			Next
		Next

		cResult := STR0302 //"OS geradas: "
		For nX := 1 to len(aOsGerada)
			cResult += "[" + alltrim(aOsGerada[nX,1]) + "]"
		Next

		If len(aOsGerada) > 0
			MsgInfo(cResult, STR0022) // Atenção
		EndIF

	EndIF

	FPA->(RestArea(FPAAREA))
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} LOCA05911
Valida se existem Ordens de Serviço - SIGALOC-1982 - Implemento
@author Frank Zwarg Fuga
@since 8/5/2024
/*/

Function LOCA05911(nOperacao)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaFPA := FPA->(GetArea())
	FPA->(dbSetOrder(3))
	If FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_AS))
		FQG->(dbSetOrder(1))
		FQG->(dbSeek(xFilial("FQG")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
		While !FQG->(Eof()) .and. FQG->(FQG_PROJET+FQG_OBRA+FQG_SEQ) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
			If !empty(FQG->FQG_OS)
				If FQG->FQG_FEITO <> "C"
					lRet := .F.
					MsgAlert(STR0299+alltrim(FQG->FQG_OS)+STR0300,STR0301) //"A OS: "###" precisa ser cancelada."###"Processo bloqueado."
					Exit
				EndIF
			EndIF
			FQG->(dbSkip())
		EndDo
	EndIF
	FPA->(RestArea(aAreaFPA))
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} LOCA05934
Valida se existem Minuta diferente de 1 (prevista)
/*/
Function LOCA05934()
Local lRet := .T.
Local aArea := GetArea()
Local aAreaFPF := FPF->(GetArea())
Local cMinutas := ""

	FPF->(dbSetOrder(4))
	If FPF->(dbSeek(xFilial("FPF")+FQ5->FQ5_AS)) 
		While FPF->FPF_FILIAL+FPF->FPF_AS == xFilial("FPF")+FQ5->FQ5_AS
			If FPF->FPF_STATUS <> "1"
				cMinutas := cMinutas + "/" + FPF->FPF_MINUTA
				lRet := .F.
			EndIf
			FPF->(dbSkip())
		EndDo 
		If Len(AllTrim(cMinutas)) > 0
			MsgAlert(STR0304+alltrim(FQ5->FQ5_AS)+STR0303+alltrim(cMinutas))  //" possui as minutas com status diferente de (prevista). " //"A AS: "
		EndIf
	EndIF

	FPF->(RestArea(aAreaFPF))
	RestArea(aArea)

Return lRet

/*/{PROTHEUS.DOC} LOCA059B1
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/
Static Function LOCA059B1(cCampo, cAlias)
Local a1Struct
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet

/*/{PROTHEUS.DOC} LOCA059Y
ITUP BUSINESS - TOTVS RENTAL
Apresenta os erros de encavalamento das minutas
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025
/*/
Static Function LOCA059Y(aErros)
Private oDlgErro
Private oLstErro
Private aItensErro  := {}
Private cCadastro 	:= ""

	aItensErro := aErros

	Define MSDialog oDlgErro title STR0305 from 100,100 to 530,1000 pixel //"Conflito de equipamento."

	//"Data"###"H.Ini.Proj."###"H.Fim.Proj."###"Minuta"###"H.Ini.Minuta"###"H.Fim.Minuta"###"Projeto"###"Obra"###"AS"###"Turno"###"Bem"###"Situação"###"Tipo conflito"
	@ 08,04 LISTBOX oLstErro FIELDS HEADER STR0306, STR0307, STR0308, STR0309, STR0310, STR0311, STR0312, STR0313, STR0314, STR0315, STR0316, STR0317, STR0318 SIZE 444,200 OF oDlgErro PIXEL  //"Data"

	oLstErro:SetArray(aItensErro)
	oLstErro:bLine 	:= {|| { aItensErro[oLstErro:nAt,01],;
							substr(aItensErro[oLstErro:nAt,02],1,2)+":"+substr(aItensErro[oLstErro:nAt,02],3,2),;
							substr(aItensErro[oLstErro:nAt,03],1,2)+":"+substr(aItensErro[oLstErro:nAt,03],3,2),;
							aItensErro[oLstErro:nAt,04],;
							substr(aItensErro[oLstErro:nAt,05],1,2)+":"+substr(aItensErro[oLstErro:nAt,05],3,2),;
							substr(aItensErro[oLstErro:nAt,06],1,2)+":"+substr(aItensErro[oLstErro:nAt,06],3,2),;
							aItensErro[oLstErro:nAt,07],;
							aItensErro[oLstErro:nAt,08],;
							aItensErro[oLstErro:nAt,09],;
							aItensErro[oLstErro:nAt,10],;
							aItensErro[oLstErro:nAt,11],;
							aItensErro[oLstErro:nAt,12],;
							aItensErro[oLstErro:nAt,13]}}

	oLstErro:Refresh()

	activate MSDialog oDlgErro centered

Return 

/*/{PROTHEUS.DOC} LOCA059W
ITUP BUSINESS - TOTVS RENTAL
Valida os erros de encavalamento das minutas
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025
// Se alterar a lógica desta rotina, também terá que ser feito no LOCA013, função LOCA013X
/*/
Static Function LOCA059W(cAs)
Local aArea := GetArea()
Local aAreaFPAw := FPA->(GetArea())
Local lRet := .T.
Local dDataX
Local aErros := {}
Local cStatus := ""
Local lControle 
Local dInix
Local dFimx
Local aDatas
Local aFeriados := RetFeriados()
Local aAreaFPAx
Local nX
Local aBindParam
Local _CQUERY
Local cQuery

	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))
	
	// DSERLOCA-5063 - Frank Fuga - Retorno da mensagem de conflito de AS
	// -------------------------------------------------------------------------------------------------
	
	/* VALIDACAO 1
	Não pode encontrar na mesma data e horário da minuta
	encavalamento, em AS diferentes da FPA
	*/
	_cQuery := " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME("FPF")+" "
	_cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"' AND "
	_cQuery += " FPF_DATA BETWEEN ? AND ? AND "
	_cQuery += " FPF_FROTA = ? AND "
	_cQuery += " FPF_AS <> ? AND "
	_cQuery += " D_E_L_E_T_ = ' ' "

	IF SELECT("TRBVLD") > 0
		TRBVLD->(DBCLOSEAREA())
	ENDIF
	_CQUERY := CHANGEQUERY(_CQUERY)
	aBindParam := {Dtos(FPA->FPA_DTINI),Dtos(FPA->FPA_DTFIM),FPA->FPA_GRUA, FPA->FPA_AS}
	MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

	While !TRBVLD->(EOF())

		FPF->(dbGoto(TRBVLD->REG))

		lControle := .T.

		If FPF->FPF_DATA >= FPA->FPA_DTINI .and. FPF->FPF_DATA <= FPA->FPA_DTFIM
			If FPF->FPF_HORAI > FPA->FPA_HRINI .and. FPF->FPF_HORAI < FPA->FPA_HRFIM
				lControle := .F.
			EndIf
			If FPF->FPF_HORAF > FPA->FPA_HRINI .and. FPF->FPF_HORAF < FPA->FPA_HRFIM
				lControle := .F.
			EndIf
		EndIF

		cStatus := ""
		If FPF->FPF_STATUS == "1"
			cStatus := STR0319 //"Prevista"
		ElseIf FPF->FPF_STATUS == "2"
			cStatus := STR0320 //"Confirmada"
		ElseIf FPF->FPF_STATUS == "3"
			cStatus := STR0321 //"Baixada"
		ElseIf FPF->FPF_STATUS == "4"
			cStatus := STR0322 //"Encerrada"
		ElseIf FPF->FPF_STATUS == "5"
			cStatus := STR0323 //"Cancelada"
		Else
			cStatus := STR0324 //"Medida"
		EndIf

		If !lControle
			aadd(aErros,{FPF->FPF_DATA,;
							FPF->FPF_HORAI,;
							FPF->FPF_HORAF,;
							FPF->FPF_MINUTA,;
							FPF->FPF_HORAI,;
							FPF->FPF_HORAF,;
							FPF->FPF_PROJET,;
							FPF->FPF_OBRA,;
							FPF->FPF_AS,;
							FPF->FPF_TURNO,;
							FPF->FPF_FROTA,;
							cStatus,;
							STR0325}) //"Conflito Minuta x Locação"
		EndIf
	
		TRBVLD->(dbSkip())

	EndDo
	TRBVLD->(DBCLOSEAREA())

	/* VALIDACAO 2
	Localizar nas Minutas as válidas que não conflitem com a FPE (Turnos)
	*/
	If LOCA059N() // Valida se o dicionário com o campo FPE_DIASEM foi atualizado
		_cQuery := " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME("FPF")+" "
		_cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"' AND "
		_cQuery += " FPF_AS <> ? AND "
		_cQuery += " FPF_FROTA = ? "
		_cQuery += " AND D_E_L_E_T_ = ' ' "

		_CQUERY := CHANGEQUERY(_CQUERY)
		aBindParam := {FPA->FPA_AS, FPA->FPA_GRUA}
		MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

		While !TRBVLD->(EOF())

			FPF->(dbGoto(TRBVLD->REG))

			lControle := .T.

			If FPF->FPF_DATA >= FPA->FPA_DTINI .and. FPF->FPF_DATA <= FPA->FPA_DTFIM
				If FPF->FPF_HORAI > FPA->FPA_HRINI .and. FPF->FPF_HORAI < FPA->FPA_HRFIM
					lControle := .F.
				EndIf
				If FPF->FPF_HORAF > FPA->FPA_HRINI .and. FPF->FPF_HORAF < FPA->FPA_HRFIM
					lControle := .F.
				EndIf
			EndIF

			If lControle

				aDatas := {}

				// Não pode encontrar conflitos com a FPE
				cQuery := " SELECT R_E_C_N_O_ REG1 FROM "+RETSQLNAME("FPE")+" "
				cQuery += " WHERE FPE_FILIAL = '"+xFilial("FPE")+"' AND "
				cQuery += " FPE_FROTA = ? "
				cQuery += " AND D_E_L_E_T_ = ' ' "

				IF SELECT("TRBFPE") > 0
					TRBFPE->(DBCLOSEAREA())
				ENDIF
				cQuery := CHANGEQUERY(cQuery)
				aBindParam := {FPA->FPA_GRUA}
				MPSysOpenQuery(cQuery,"TRBFPE",,,aBindParam)

				While !TRBFPE->(Eof()) 

					FPE->(dbGoto(TRBFPE->REG1))

					cAsx := FPF->FPF_AS
					aAreaFPAx := FPA->(GetArea())

					FPA->(dbSetOrder(1))
					If FPA->(dbSeek(xFilial("FPA")+FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI)))
						If FPA->FPA_AS == cAsx
							TRBFPE->(dbSkip())
							FPA->(RestArea(aAreaFPAx))
							Loop
						EndIF
						dInix := FPA->FPA_DTINI
						dFimx := FPA->FPA_DTFIM

						If ((FPE->FPE_HRINIT > FPF->FPF_HORAI .and. FPE->FPE_HRINIT < FPF->FPF_HORAF) .AND.;
							(FPE->FPE_HOFIMT > FPF->FPF_HORAI .and. FPE->FPE_HOFIMT < FPF->FPF_HORAF))

							//Encontrar as datas validas para ver se não conflita com a FPF
							//A=Diurno/Noturno
							//E=Sexta diferenciada
							//S=Sábado
							//F=Domingo/Feriado
							//M=Manual (não precisa validar)
							
							For dDataX := dInix to dFimx
								If FPE->FPE_DIASEM == "A"
									aadd(aDatas,dDatax)
								EndIf
								If FPE->FPE_DIASEM == "E"
									If dow(dDatax) == 6 // sexta
										aadd(aDatas,dDatax)
									EndIf
								EndIf
								If FPE->FPE_DIASEM == "S"
									If dow(dDatax) == 7 // sabado
										aadd(aDatas,dDatax)
									EndIf
								EndIf
								If FPE->FPE_DIASEM == "F"
									If dow(dDatax) == 1 // domingo
										aadd(aDatas,dDatax)
									Else
										// validar se é um feriado
										If ascan(aFeriados,dtos(dDatax)) > 0
											aadd(aDatas,dDatax)
										EndIf
									EndIf
								EndIf
							Next

						EndIf

					EndIf

					cStatus := ""
					If FPF->FPF_STATUS == "1"
						cStatus := STR0319 //"Prevista"
					ElseIf FPF->FPF_STATUS == "2"
						cStatus := STR0320 //"Confirmada"
					ElseIf FPF->FPF_STATUS == "3"
						cStatus := STR0321 //"Baixada"
					ElseIf FPF->FPF_STATUS == "4"
						cStatus := STR0322 //"Encerrada"
					ElseIf FPF->FPF_STATUS == "5"
						cStatus := STR0323 //"Cancelada"
					Else
						cStatus := STR0324 //"Medida"
					EndIf

					For nX := 1 to len(aDatas)
						If aDatas[nx] == FPF->FPF_DATA 
							If FPE->FPE_HRINIT >= FPF->FPF_HORAI .and. FPE->FPE_HOFIMT <= FPF->FPF_HORAF
								aadd(aErros,{aDatas[nx],;
											FPE->FPE_HRINIT,;
											FPE->FPE_HOFIMT,;
											FPF->FPF_MINUTA,;
											FPF->FPF_HORAI,;
											FPF->FPF_HORAF,;
											FPF->FPF_PROJET,;
											FPF->FPF_OBRA,;
											FPF->FPF_AS,;
											FPF->FPF_TURNO,;
											FPF->FPF_FROTA,;
											cStatus,;
											STR0326}) //"Conflito Turno x Minuta"
							EndIf
						EndIf
					Next

					FPA->(RestArea(aAreaFPAx))
					TRBFPE->(dbSkip())
				EndDo
				TRBFPE->(DBCLOSEAREA())
		
			EndIf

			TRBVLD->(dbSkip())

		EndDo
		TRBVLD->(DBCLOSEAREA())

	EndIf

	If len(aErros) > 0
		LOCA059Y(aErros)
	EndIf

	If len(aErros) > 0
		lRet := .F.
	EndIf

	FPA->(RestArea(aAreaFPAw))
	RestArea(aArea)

Return lRet

/*/{PROTHEUS.DOC} LOCA059Z
ITUP BUSINESS - TOTVS RENTAL
Acrescenta os turnos diurno e noturno no array para gravar
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025
/*/
Static Function LOCA059Z(aGravar, cAs)
Local aArea 	:= GetArea()
Local aAreaFPA 	:= FPA->(GetArea())
Local aTemp 	:= {}
Local dDatax
Local dDataIni
Local dDataFim
Local nX
Local aFeriados := RetFeriados()
Local lTemSexta := .F.

	If LOCA059N() // Valida se o dicionário com o campo FPE_DIASEM foi atualizado
		If !empty(cAs)
			FPA->(dbSetOrder(3))
			IF FPA->(dbSeek(xFilial("FPA")+cAs))
				FPE->(dbSetOrder(2))
				FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
				While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
					If FPE->FPE_DIASEM == "E"
						lTemSexta := .T.
					EndIf
					FPE->(dbSkip())
				EndDo
				FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
				While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
					If FPE->FPE_DIASEM == "A"
						dDataIni := FPA->FPA_DTINI
						dDataFim := FPA->FPA_DTFIM
						For dDatax := dDataIni to dDataFim
							// não gerar para feriados, sabados e domingos (pois é do tipo diurno)
							If AScan(aFeriados,dtos(dDatax)) == 0 .and. dow(dDatax) <> 1 .and. dow(dDatax) <> 7 .and. if(lTemSexta.and.dow(dDatax)==6,.f.,.t.)
								aadd(aTemp,{FPA->FPA_GRUA, dDatax, FPA->FPA_PROJET, FPA->FPA_OBRA, 0, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, cAs, FPE->FPE_TURNO})
							EndIf
						Next
					EndIf					
					FPE->(dbSkip())
				EndDo
			EndIf

			For nX := 1 to len(aTemp)
				AADD(AGRAVAR,{ aTemp[nX,1], aTemp[nX,2], aTemp[nX,3], aTemp[nX,4], aTemp[nX,5], aTemp[nX,6], aTemp[nX,7], aTemp[nX,8], aTemp[nX,9] })
			Next
		EndIF
	EndIf

	FPA->(RestArea(aAreaFPA))
	RestArea(aArea)
Return aGravar

/*/{PROTHEUS.DOC} LOCA059M
ITUP BUSINESS - TOTVS RENTAL
Fazer os ajustes das minutas com base nos turnos gerados
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/01/2025
/*/
Static Function LOCA059M(aGravar)
Local aFeriados := RetFeriados()
Local nX
Local aArea := GetArea()
Local aAreaFPE := FPE->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local lPrimeiro
Local dData

	If LOCA059N() // Valida se o dicionário com o campo FPE_DIASEM foi atualizado
		// Ajuste dos horários e turnos 
		For nX := 1 to len(aGravar)

			dData := aGravar[nX,2]

			FPA->(dbSetOrder(3))
			If FPA->(dbSeek(xFilial("FPA")+aGravar[nX,8])) .and. !empty(aGravar[nX,8])

				// Tratamento para os feriados
				If AScan(aFeriados,dtos(dData)) > 0
					// Se for um feriado atualizar e não for sexta, sabado ou domingo
					lPrimeiro := .T.
					FPE->(dbSetOrder(2))
					FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
					While !FPE->(Eof()) .and. FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
						If FPE->FPE_DIASEM == "F" 
							If lPrimeiro
								aGravar[nX,6] := FPE->FPE_HRINIT
								aGravar[nX,7] := FPE->FPE_HOFIMT
								aGravar[nX,9] := FPE->FPE_TURNO
							Else
								aadd(aGravar,{FPA->FPA_GRUA, dData, FPA->FPA_PROJET, FPA->FPA_OBRA, 0, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, FPA->FPA_AS, FPE->FPE_TURNO})						
							EndIf
							lPrimeiro := .F.
						EndIf
						FPE->(dbSkip())
					EndDo
				EndIf

				// Tratamento para os domingos
				If dow(dData) == 1 .and. AScan(aFeriados,dtos(dData)) == 0
					// Se for um domingo atualizar
					// Se for um feriado atualizar e não for sexta, sabado ou domingo
					lPrimeiro := .T.
					FPE->(dbSetOrder(2))
					FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
					While !FPE->(Eof()) .and. FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
						If FPE->FPE_DIASEM == "F" 
							If lPrimeiro
								aGravar[nX,6] := FPE->FPE_HRINIT
								aGravar[nX,7] := FPE->FPE_HOFIMT
								aGravar[nX,9] := FPE->FPE_TURNO
							Else
								aadd(aGravar,{FPA->FPA_GRUA, dData, FPA->FPA_PROJET, FPA->FPA_OBRA, 0, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, FPA->FPA_AS, FPE->FPE_TURNO})						
							EndIf
							lPrimeiro := .F.
						EndIf
						FPE->(dbSkip())
					EndDo
				EndIf

				// Tratamento para os sabados
				If dow(dData) == 7 .and. AScan(aFeriados,dtos(dData)) == 0
					// Se for um sabado atualizar
					// Se for um domingo atualizar
					// Se for um feriado atualizar e não for sexta, sabado ou domingo
					lPrimeiro := .T.
					FPE->(dbSetOrder(2))
					FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
					While !FPE->(Eof()) .and. FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
						If FPE->FPE_DIASEM == "S" 
							If lPrimeiro
								aGravar[nX,6] := FPE->FPE_HRINIT
								aGravar[nX,7] := FPE->FPE_HOFIMT
								aGravar[nX,9] := FPE->FPE_TURNO
							Else
								aadd(aGravar,{FPA->FPA_GRUA, dData, FPA->FPA_PROJET, FPA->FPA_OBRA, 0, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, FPA->FPA_AS, FPE->FPE_TURNO})						
							EndIf
							lPrimeiro := .F.
						EndIf
						FPE->(dbSkip())
					EndDo

				EndIf

				// Tratamento para as sextas especiais
				If dow(dData) == 6 .and. AScan(aFeriados,dtos(dData)) == 0
					// Se for uma sexta atualizar
					// Se for um sabado atualizar
					// Se for um domingo atualizar
					// Se for um feriado atualizar e não for sexta, sabado ou domingo
					lPrimeiro := .T.
					FPE->(dbSetOrder(2))
					FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
					While !FPE->(Eof()) .and. FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
						If FPE->FPE_DIASEM == "E" 
							If lPrimeiro
								aGravar[nX,6] := FPE->FPE_HRINIT
								aGravar[nX,7] := FPE->FPE_HOFIMT
								aGravar[nX,9] := FPE->FPE_TURNO
							Else
								aadd(aGravar,{FPA->FPA_GRUA, dData, FPA->FPA_PROJET, FPA->FPA_OBRA, 0, FPE->FPE_HRINIT, FPE->FPE_HOFIMT, FPA->FPA_AS, FPE->FPE_TURNO})						
							EndIf
							lPrimeiro := .F.
						EndIf
						FPE->(dbSkip())
					EndDo
				EndIf
			EndIf

		Next
	EndIf

	FPE->(RestArea(aAreaFPE))
	FPA->(RestArea(aAreaFPA))
	RestArea(aArea)

Return aGravar

/*/{PROTHEUS.DOC} LOCA059N
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE A VERSAO DOS TURNOS É A VALIDA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 23/01/2025
/*/
Static Function LOCA059N
Local aFields
Local nX
Local cCampo
Local cCBox := ""
Local lAtivo := .F.

	aFields := FWSX3Util():GetListFieldsStruct( "FPE" , .F.)
	For nX := 1 To Len( aFields )
		cCampo := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CAMPO")
		If alltrim(cCampo) == "FPE_DIASEM"
       		cCbox := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CBOX")
		EndIf
	Next nX

	If At("M=", cCbox) > 0
		lAtivo := .T.
	EndIf

Return lAtivo

/*/{PROTHEUS.DOC} LOCA059DE
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE EXISTE UMA DEMANDA GERADA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 23/04/2025
/*/
Function LOCA059DE(lMsg)
Local lRet := .T.
Local aFields 
Local nX
Local lProc := .F.

Default lMsg := .T.

	if !IsInCallStack("LOCA259EPR") .AND. !IsInCallStack("LOCA229EPR") // Se vier de uma rotina da demanda ou romaneio não precisa validar a demanda

		aFields := FWSX3Util():GetListFieldsStruct("FQ5", .F.)
		For nX := 1 To Len( aFields )
			If alltrim(GetSx3Cache(alltrim(aFields[nX][01]),"X3_CAMPO")) == "FQ5_DEMAND"
				lProc := .T.
				Exit
			EndIf
		Next

		If lProc
			If !empty(FQ5->FQ5_DEMAND)
				lRet := .F.
			EndIf
		EndIf

		If !lRet .and. lMsg
			MsgAlert(STR0328,STR0022) // "Processo bloqueado, pois existe uma demanda associada."###"Atenção!"
		EndIf

	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA059AROM
ITUP BUSINESS - TOTVS RENTAL
Valida se a ASF foi associada ao um Novo Romaneio
@TYPE FUNCTION
@AUTHOR Alexandre Circenis
@SINCE 23/04/2025
/*/
Function LOCA059AROM(lMsg)
Local lRet := .T.
Local cQuery := ''
Local aBindParam := {}

Default lMsg := .T.

if !IsInCallStack("LOCA259EPR") .AND. !IsInCallStack("LOCA229EPR") // Se vier de uma rotina da demanda ou romaneio não precisa validar a demanda

	if FQ5->(FieldPos("FQ5_DEMAND"))
		dbSelectArea("FQU")

		cQuery += " select FQU_NUM "
		cQuery += " from "+RetSqlName("FQU")
		cQuery += " where FQU_FILIAL = '"+xFilial("FQU")+"'"
		cQuery += " and FQU_ASF = ?"
		Aadd(aBindParam , FQ5->FQ5_AS)
		cQuery += " and D_E_L_E_T_ = ' '"

		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,"TRBASF",,,aBindParam)


		if !TRBASF->(Eof()) .and. lMsg
			MsgAlert(STR0329, STR0022)  //"Atenção!" //"Processo bloqueado, a A.S.F. já foi utilizada em um romaneio da Gestão de Expedição."
			lRet := .F.
		endif

	endif

endif

Return lRet


// passagem no advpr
Function LOCA05912
return .T.
