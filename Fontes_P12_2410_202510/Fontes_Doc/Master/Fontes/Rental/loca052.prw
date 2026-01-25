#INCLUDE "loca052.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±PROGRAMA   ³ CONSULTAS º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ CONSULTA ESPECIFICA PARA NUMERO DE AS                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA05209(PTIPO)
LOCAL CCHAVE
LOCAL CVIAGEM 
LOCAL NPOSLIST := 0
LOCAL OLISTBOX , OCONF , OCANC  
LOCAL ODLG
LOCAL OCBX, AORD := {STR0107,STR0108,STR0109} //"NR. AS"###"VIAGEM"###"CLIENTE"
LOCAL OBIGGET, CCAMPO := CRIAVAR("FPM_AS")+CRIAVAR("FPM_VIAGEM")
LOCAL ADTQ  	:= {}
Local CQUERY

PRIVATE NORD := 1, CORD:="1",LOK := .F.

STATIC CRETZLE

	IF SELECT("TRB") > 0
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
	ENDIF
	CQUERY := " SELECT  FQ5_AS , FQ5_SOT , FQ5_OBRA , FQ5_VIAGEM , FQ5_NOMCLI "
	CQUERY += " FROM "+RETSQLNAME("FQ5")+" (NOLOCK) "
	CQUERY += " WHERE   D_E_L_E_T_ = '' "
	CQUERY += "   AND   FQ5_ENCERR != '2' "
	CQUERY += "   AND   FQ5_TPAS IN ('T','G','U', 'P','M') "
	CQUERY += "   AND   FQ5_STATUS != '9' "
	CQUERY += "GROUP BY FQ5_AS,FQ5_SOT,FQ5_OBRA,FQ5_VIAGEM,FQ5_NOMCLI "
	CQUERY += "ORDER BY FQ5_AS"
	DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRB", .F., .T.)

	DBSELECTAREA("TRB")
	DBGOTOP()

	IF TRB->(EOF())
		MSGSTOP(STR0110 , STR0026)  //"NÃO EXISTEM REGISTROS CADASTRADOS."###"GPO - LOCT049.PRW"
		TRB->(DBCLOSEAREA())
		RETURN .F.
	ENDIF

	TRB->(DBGOTOP())
	WHILE ! TRB->(EOF())
		AADD(ADTQ, {	ALLTRIM(TRB->FQ5_AS    ) ,;
		ALLTRIM(TRB->FQ5_VIAGEM) ,;
		ALLTRIM(TRB->FQ5_SOT   ) ,;
		ALLTRIM(TRB->FQ5_OBRA  ) ,;
		ALLTRIM(TRB->FQ5_NOMCLI) } )
		TRB->(DBSKIP())
	ENDDO 

	TRB->(DBCLOSEAREA())

	DEFINE MSDIALOG ODLG FROM 00,00 TO 400,490 PIXEL TITLE OEMTOANSI(STR0003) //"PESQUISAR"

		@05,05 COMBOBOX OCBX VAR CORD ITEMS AORD SIZE 206,36 PIXEL OF ODLG FONT ODLG:OFONT

		@ 22,005 MSGET OBIGGET VAR CCAMPO SIZE 206,10 PIXEL
		@ 05,215 BUTTON OCONF PROMPT STR0003 SIZE 30,10  FONT ODLG:OFONT   ACTION (OLISTBOX:NAT := PESQZLQ(ADTQ,ALLTRIM(CCAMPO),OLISTBOX,OCBX),; //"PESQUISAR"
							OLISTBOX:BLINE:={||{ADTQ[OLISTBOX:NAT][1],ADTQ[OLISTBOX:NAT][2],;
												ADTQ[OLISTBOX:NAT][3],ADTQ[OLISTBOX:NAT][4],;
												ADTQ[OLISTBOX:NAT][5]}},OCONF:SETFOCUS()) OF ODLG PIXEL
		OCBX:BCHANGE := {|| PESQZLQ(ADTQ,ALLTRIM(CCAMPO),OLISTBOX,OCBX) }

		@ 0,0 BITMAP OBMP RESNAME STR0111 OF ODLG SIZE 100,300 NOBORDER WHEN .F. PIXEL //"PROJETOAP"
		OLISTBOX := TWBROWSE():NEW( 40,05,204,140,,{STR0112,STR0108,STR0113,STR0114,STR0109},,ODLG,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"NUMERO AS"###"VIAGEM"###"PROJETO"###"OBRA"###"CLIENTE"
		OLISTBOX:SETARRAY(ADTQ)
		OLISTBOX:BLINE := { ||{ADTQ[OLISTBOX:NAT][1],ADTQ[OLISTBOX:NAT][2],;
		ADTQ[OLISTBOX:NAT][3],ADTQ[OLISTBOX:NAT][4],ADTQ[OLISTBOX:NAT][5] }}
		OLISTBOX:BLDBLCLICK := { ||EVAL(OCONF:BACTION), ODLG:END()}

		@ 185,05 	BUTTON OCONF PROMPT STR0115 		SIZE 45 ,10   FONT ODLG:OFONT ACTION (LOK:=.T.,CCHAVE:=ADTQ[OLISTBOX:NAT][1],CVIAGEM:=ADTQ[OLISTBOX:NAT][2],ODLG:END())  OF ODLG PIXEL //"CONFIRMA"
		@ 185,55 	BUTTON OCANC PROMPT STR0116  		SIZE 45 ,10   FONT ODLG:OFONT ACTION (LOK:=.F.,ODLG:END())  OF ODLG PIXEL //"CANCELA"

		IF NPOSLIST > 0
			OLISTBOX:NAT := NPOSLIST
			OLISTBOX:BLINE := { ||{ADTQ[OLISTBOX:NAT][1],ADTQ[OLISTBOX:NAT][2],;
			ADTQ[OLISTBOX:NAT][3],ADTQ[OLISTBOX:NAT][4],ADTQ[OLISTBOX:NAT][5] }}
			OCONF:SETFOCUS()
		ENDIF

	ACTIVATE MSDIALOG ODLG CENTERED

	// VARIAVEL UTILIZADA NO RETORNO SXB
	IF PTIPO = "T"
		CRETZLE := CVIAGEM
	ELSE
		CRETZLE := CCHAVE
	ENDIF

RETURN LOK 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±PROGRAMA   ³ RETZLE    º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ RETORNO DA CONSULTA ESPECIFICA                             º±±
±±º          ³ CHAMADA: CONSULTA PADRÃO - "ZLDDTQ", "ZLFDTQ" E "ZLGDTQ"   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA05210()

RETURN(CRETZLE)



// ======================================================================= \\
FUNCTION LOCA05212(PCAMPO)
// ======================================================================= \\
// --> CHAMADA: GATILHO DO  CAMPO  FPL_AS 
LOCAL DRET      := CTOD("//")
RETURN DRET 


// ======================================================================= \\
FUNCTION LOCA05213(PCAMPO)
// ======================================================================= \\
// --> CHAMADA: GATILHO DOS CAMPOS FPM_NRAS E FPO_NRAS 
LOCAL CRET     := ""

RETURN CRET



// ======================================================================= \\
FUNCTION LOCA05217(CCAMPO)			// VALIDAÇÕES
// ======================================================================= \\
LOCAL LRET   := .T.

RETURN(LRET)


// ======================================================================= \\
FUNCTION LOCA05218(CPARFROTA, CPARAS)
// ======================================================================= \\
// --> CHAMADA: VALIDAÇÃO DE USUÁRIO DOS CAMPOS FPL_AS E FPO_NRAS 
// --> VALIDAÇÃO DE AS CADASTRADA MANUALMENTE.
LOCAL   LRET   := .T.
RETURN LRET


// Criação da rotina PESQZLQ para efeito de débitos técnicos
// Frank em 03/01/24
Function PESQZLQ
Return .T.

