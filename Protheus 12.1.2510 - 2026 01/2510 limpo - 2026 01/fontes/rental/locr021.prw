#INCLUDE "TOTVS.CH"
#INCLUDE "LOCR021.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*/{PROTHEUS.DOC} LOCR021.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATпїЅRIO DO TIME SHEET
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
  
FUNCTION LOCR021()
LOCAL AORD := {}
LOCAL CDESC1       := STR0001 	//"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC2       := STR0002  	//"EXIBINDO A LOCAпїЅпїЅO DE FUNCIONпїЅRIOS POR PERпїЅODO, DATA, STATUS, AS COM AS HORAS DE INTEGRAпїЅпїЅO."
LOCAL CDESC3       := STR0006 	//"TIME SHEET"
LOCAL TITULO       := STR0006	// "TIME SHEET"
LOCAL NLIN         := 80
LOCAL CABEC1       := STR0007	//"FL      MATRIC  NOME DO FUNCIONARIO             FUNCAO                STATUS                           AS                   CLIENTE                                        MUNICIPIO                   UF DIAS  HORAS"
					//"FL      MATRIC  NOME DO FUNCIONARIO             FUNCAO                STATUS                           AS                   CLIENTE                                        MUNICIPIO                   UF DIAS  HORAS"
					// 999999  999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 99999 99999					// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
					//          10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230

LOCAL CABEC2       := ""
LOCAL IMPRIME 

PRIVATE LEND       := .F.
PRIVATE LABORTPRINT:= .F.
PRIVATE LIMITE     := 220
PRIVATE TAMANHO    := "G"
PRIVATE NOMEPROG   := STR0006 	// "TSHEET" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO      := 15
PRIVATE ARETURN    := { "ZEBRADO", 1, "ADMINISTRACAO", 1, 2, 1, "", 1}
PRIVATE NLASTKEY   := 0
PRIVATE CPERG      := "LOCP069"
PRIVATE CBTXT      := SPACE(10)
PRIVATE CBCONT     := 00
PRIVATE CONTFL     := 01
PRIVATE M_PAG      := 01
PRIVATE WNREL      := STR0006 // "TSHEET" // COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING    := "FPQ"

	IMPRIME := .T.

	DBSELECTAREA("FPQ")
	DBSETORDER(1)

	PERGUNTE(CPERG,.F.)

	WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.F.,TAMANHO,,.F.)

	IF NLASTKEY == 27
		RETURN
	ENDIF
 
	SETDEFAULT(ARETURN,CSTRING)

	IF NLASTKEY == 27
		RETURN
	ENDIF

	NTIPO := IF(ARETURN[4]==1,15,18)

	RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

RETURN



/*/
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН»пїЅпїЅ
пїЅпїЅпїЅFUNпїЅпїЅO    пїЅRUNREPORT пїЅ AUTOR пїЅ AP5 IDE            пїЅ DATA пїЅ  07/05/02   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅDESCRIпїЅпїЅO пїЅ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅUSO       пїЅ ESPECIFICO GPO                                             пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅНјпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
LOCAL NX        := 0 
LOCAL _CSITFOLH	:=	""
LOCAL _CCATFUNC	:=	""
LOCAL _CCCDEPTO

	DO CASE
	CASE ALLTRIM(MV_PAR17) == "T"
		_CCCDEPTO	:=	GETMV("MV_LOCX110",.F.,"")
	CASE ALLTRIM(MV_PAR17) == "E"
		_CCCDEPTO	:=	GETMV("MV_LOCX106",.F.,"")	
	CASE ALLTRIM(MV_PAR17) == "L"
		_CCCDEPTO	:=	GETMV("MV_LOCX105",.F.,"") 
	OTHERWISE
		_CCCDEPTO	:=	"''" 
	ENDCASE	

	FOR NX := 1 TO LEN(MV_PAR13)
		_CSITFOLH += "'"+SUBSTR(MV_PAR13,NX,1)+"',"
	NEXT NX
	_CSITFOLH := SUBSTR(_CSITFOLH,1,LEN(_CSITFOLH)-1)

	FOR NX := 1 TO LEN(MV_PAR14)
		_CCATFUNC += "'"+SUBSTR(MV_PAR14,NX,1)+"',"
	NEXT NX 
	_CCATFUNC := SUBSTR(_CCATFUNC,1,LEN(_CCATFUNC)-1)
	SETPRVT("XTQCOM,XTQVEN,XTQEST,XTQPED,XTVCOM,XTVVEN,XTVEST,XTVPED,XIMPLINHA")
	SETPRVT("XLQCOM,XLQVEN,XLQEST,XLQPED,XLVCOM,XLVVEN,XLVEST,XLVPED")

	LJMSGRUN(STR0003,,{|| LoadData()}) //"SELECIONANDO REGISTROS PARA IMPRESSпїЅO."

	TITULO := ALLTRIM(TITULO) +STR0004 + ALLTRIM(DTOC(MV_PAR01)) + " A " + ALLTRIM(DTOC(MV_PAR02)) //" PERIODO DE "

	DBSELECTAREA("QRY")
	SETREGUA(RECCOUNT())
	If  _CSITFOLH == "'*','*','*','*','*'" .OR. _CCATFUNC == "'*','*','*','*','*','*','*','*','*','*'"
		MsgStop("Й obrigatуrio informmar a situaзгo ou categoria do funcionбrio")
		Return(.F.)
	EndIf	
	DBGOTOP()
	WHILE !EOF() 

		_CMAT := QRY->FPQ_MAT
		_LIMPLINHA := .T.
		WHILE !EOF() 
			If !QRY->RA_SITFOLH $(_CSITFOLH) .OR. !QRY->RA_CATFUNC $(_CCATFUNC)
				QRY->(DBSKIP())
				Loop
			EndIf	
			//IF LABORTPRINT
			//	@ NLIN,00 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
			//	EXIT
			//ENDIF

			INCREGUA()

			IF NLIN > 55 // SALTO DE PпїЅGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
				CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
				NLIN := 7
				_LIMPLINHA := .T.
			ENDIF														   
			// "FL      MATRIC  NOME DO FUNCIONARIO             FUNCAO                STATUS                           AS                   CLIENTE                                        MUNICIPIO                   UF DIAS  HORAS"
			//  999999  999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 99999 99999
			//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
			//           10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230
			IF _LIMPLINHA .OR. _CMAT <> QRY->FPQ_MAT
				NLIN++
				@ NLIN,000 PSAY QRY->FPQ_FILIAL
				@ NLIN,008 PSAY QRY->FPQ_MAT
				@ NLIN,016 PSAY QRY->RA_NOME
				@ NLIN,048 PSAY QRY->RJ_DESC
				_CMAT := QRY->FPQ_MAT
				_LIMPLINHA := .F.
			ENDIF	
			
			@ NLIN,070 PSAY FWGETSX5( "QV", QRY->FPQ_STATUS )[1][4] //QRY->FPQ_STATUS
			@ NLIN,103 PSAY QRY->FPQ_AS
			IF !QRY->FPQ_STATUS $ "AFASTA"
				@ NLIN,124 PSAY QRY->FPQ_DESC
				@ NLIN,170 PSAY QRY->A1_MUN
				@ NLIN,199 PSAY QRY->A1_EST
				//@ NLIN,202 PSAY QRY->RA_DSHEET PICTURE "99999"
				@ NLIN,208 PSAY QRY->FPQ_HORAS PICTURE "99999" 
			ELSE 
				//@ NLIN,201 PSAY QRY->RA_DSHEET PICTURE "99999"
				@ NLIN,207 PSAY QRY->FPQ_HORAS PICTURE "99999" 		
			ENDIF
			
			NLIN++ // AVANCA A LINHA DE IMPRESSAO

			QRY->(DBSKIP()) // AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
		ENDDO	
	
		@ NLIN,00 PSAY REPLICATE("_",LIMITE)
		NLIN ++
	ENDDO

	SET DEVICE TO SCREEN

	IF ARETURN[5]==1
		DBCOMMITALL()
		SET PRINTER TO
		OURSPOOL(WNREL)
	ENDIF

	MS_FLUSH()

	QRY->(DBCLOSEAREA())

RETURN 

/*/{PROTHEUS.DOC} LOCR021.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATпїЅRIO DO TIME SHEET
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 14/07/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
STATIC FUNCTION LoadData()
LOCAL NX        := 0 
LOCAL _CSITFOLH	:=	""
LOCAL _CCATFUNC	:=	""
LOCAL _CCCDEPTO
Local _cQuery 

	DO CASE
	CASE ALLTRIM(MV_PAR17) == "T"
		_CCCDEPTO	:=	GETMV("MV_LOCX110",.F.,"")
	CASE ALLTRIM(MV_PAR17) == "E"
		_CCCDEPTO	:=	GETMV("MV_LOCX106",.F.,"")	
	CASE ALLTRIM(MV_PAR17) == "L"
		_CCCDEPTO	:=	GETMV("MV_LOCX105",.F.,"") 
	OTHERWISE
		_CCCDEPTO	:=	"''" 
	ENDCASE	

	FOR NX := 1 TO LEN(MV_PAR13)
		_CSITFOLH += "'"+SUBSTR(MV_PAR13,NX,1)+"',"
	NEXT NX
	_CSITFOLH := SUBSTR(_CSITFOLH,1,LEN(_CSITFOLH)-1)

	FOR NX := 1 TO LEN(MV_PAR14)
		_CCATFUNC += "'"+SUBSTR(MV_PAR14,NX,1)+"',"
	NEXT NX 
	_CCATFUNC := SUBSTR(_CCATFUNC,1,LEN(_CCATFUNC)-1)

	IF SELECT("QRY") > 0
		QRY->(DBCLOSEAREA()) 
	ENDIF

	/*
	+ MV_PAR03        +
	+ MV_PAR04 +
	+ MV_PAR05        +
	+ MV_PAR06 +
	+ MV_PAR07        +
	+ MV_PAR10 +
	+ MV_PAR08        +
	+ MV_PAR11 +
	+ MV_PAR09        +
	+ MV_PAR12 +
	+ DTOS(MV_PAR01)  +
	+ DTOS(MV_PAR02) +
	+ALLTRIM(_CSITFOLH)+
	+ALLTRIM(_CCATFUNC)+
	*/

	//_CQUERY := "SELECT	ZLO.FPQ_FILIAL	,	ZLO.FPQ_MAT	,	SRA.RA_NOME		,	SRJ.RJ_DESC		,		"
	_CQUERY := "SELECT	FPQ.FPQ_FILIAL	,	FPQ.FPQ_MAT	,	SRA.RA_NOME		,	SRJ.RJ_DESC		,		"
	_CQUERY += "		FPQ.FPQ_STATUS	, 	FPQ.FPQ_AS	,	FPQ.FPQ_DESC	,	FPQ.FPQ_PROJET	,		"
	_CQUERY += "		FPQ.FPQ_OBRA	,	SA1.A1_MUN	, 	SA1.A1_EST		,							"
	_CQUERY += "		0 RA_VT, SRA.RA_SITFOLH , SRA.RA_CATFUNC	,					"
	_CQUERY += "       	SUM(FPQ.FPQ_HORAS) FPQ_HORAS	   							                    "
	_CQUERY += "FROM   " + RETSQLNAME("FPQ") + " FPQ INNER JOIN 										"
	_CQUERY +=             RETSQLNAME("SRA") + " SRA ON 												"
	_CQUERY += "       SRA.D_E_L_E_T_ = '' AND 															"
	_CQUERY += "       SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND 											"
	_CQUERY += "       FPQ.FPQ_MAT = SRA.RA_MAT INNER JOIN 												"
	_CQUERY +=             RETSQLNAME("SRJ") + " SRJ ON 												"                                   	
	_CQUERY += "       SRJ.D_E_L_E_T_ = '' AND 															"
	_CQUERY += "       SRA.RA_CODFUNC = SRJ.RJ_FUNCAO LEFT JOIN 										"
	_CQUERY +=             RETSQLNAME("FQ5") + " FQ5 ON 												"
	_CQUERY += "       FQ5.D_E_L_E_T_ = '' AND 															"
	_CQUERY += "       FPQ.FPQ_AS = FQ5.FQ5_AS AND 														"
	_CQUERY += "       FPQ.FPQ_PROJET = FQ5.FQ5_CONTRA LEFT JOIN 										"
	_CQUERY +=             RETSQLNAME("AAM") + " AAM ON 												"
	_CQUERY += "       AAM.D_E_L_E_T_ = '' AND 															"
	_CQUERY += "       FQ5.FQ5_CONTRA = AAM.AAM_CONTRT LEFT JOIN 										"
	_CQUERY +=             RETSQLNAME("SA1") + " SA1 ON 												"
	_CQUERY += "       SA1.D_E_L_E_T_ = '' AND 															"
	_CQUERY += "       FQ5.FQ5_CODCLI = SA1.A1_COD AND 													"
	_CQUERY += "       FQ5.FQ5_LOJA   = SA1.A1_LOJA 													"
	_CQUERY += "WHERE  FPQ.D_E_L_E_T_ = ''                             	 AND 							"
	_CQUERY += "       FPQ.FPQ_MAT     BETWEEN ? AND ? AND 	"
	_CQUERY += "       FPQ.FPQ_STATUS  BETWEEN ? AND ? AND 	"
	_CQUERY += "       FPQ.FPQ_AS      BETWEEN ? AND ? AND 	"
	_CQUERY += "       FPQ.FPQ_PROJET  BETWEEN ? AND ? AND 	"
	_CQUERY += "       FPQ.FPQ_OBRA    BETWEEN ? AND ? AND 	"
	_CQUERY += "       FPQ.FPQ_DATA    BETWEEN ? AND ? 	"
	//_CQUERY += "       AND	SRA.RA_SITFOLH  IN (" + _CSITFOLH +" )									"
	//_CQUERY += "       AND	SRA.RA_CATFUNC  IN ("+ _CCATFUNC + " ) 								"
	_CQUERY += "GROUP BY FPQ.FPQ_FILIAL,FPQ.FPQ_MAT,SRA.RA_NOME,SRJ.RJ_DESC,FPQ.FPQ_STATUS, 			"
	_CQUERY += "FPQ.FPQ_AS,FPQ.FPQ_DESC,FPQ.FPQ_PROJET, FPQ.FPQ_OBRA, SA1.A1_MUN, SA1.A1_EST,SRA.RA_SITFOLH,SRA.RA_CATFUNC   			"
	IF MV_PAR16 == 2
		_CQUERY += "       ORDER BY RA_NOME+FPQ_MAT+FPQ_STATUS+FPQ_AS"
	ELSE
		_CQUERY += "       ORDER BY RJ_DESC+FPQ_MAT+FPQ_STATUS+FPQ_AS " 
	ENDIF
	_CQUERY := CHANGEQUERY(_CQUERY)  
	aBindParam := {	MV_PAR03,;
					MV_PAR04,;
					MV_PAR05,;
					MV_PAR06,;
					MV_PAR07,;
					MV_PAR10,;
					MV_PAR08,;
					MV_PAR11,;
					MV_PAR09,;
					MV_PAR12,;
					DTOS(MV_PAR01),;
					DTOS(MV_PAR02)}
					//ALLTRIM(_CSITFOLH),;
					//ALLTRIM(_CCATFUNC)}
	MPSysOpenQuery(_cQuery,"QRY",,,aBindParam)

	//TCQUERY _CQUERY NEW ALIAS "QRY"

RETURN 
 
 
 