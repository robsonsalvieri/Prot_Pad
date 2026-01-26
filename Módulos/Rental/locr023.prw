#INCLUDE "TOTVS.CH"
#INCLUDE "LOCR023.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE NCOLFUNC 41
#DEFINE NCOLDATA 63
#DEFINE NCOLDIVE 74

/*/{PROTHEUS.DOC} LOCR023.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DE DIVERGENCIAS DO TIME SHEET
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCR023()
LOCAL AORD := {}
LOCAL CDESC1       := STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC2       := STR0002 //"EXIBINDO AS DIVERGสNCIAS ENCONTRADAS NOS LANวAMENTOS DE TIME SHEET."
LOCAL CDESC3       := STR0003 //"DIVERGENCIAS TIME SHEET"
LOCAL TITULO       := STR0004 //"DIVERGสNCIAS TIME SHEET"
LOCAL NLIN         := 80
LOCAL CABEC1       := STR0005 //"MATRIC  NOME DO FUNCIONARIO                            FUNCAO                DATA      DIVERGENCIA ENCONTRADA                       "
//  999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  99/99/99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
//  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//           10        20        30        40        50        60        70        80        90       100       110       120       130
LOCAL CABEC2       := ""
LOCAL IMPRIME 

PRIVATE LEND       := .F.
PRIVATE LABORTPRINT:= .F.
PRIVATE LIMITE     := 80
PRIVATE TAMANHO    := "M"
PRIVATE NOMEPROG   := "DSHEET" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO      := 15
PRIVATE ARETURN    := { "ZEBRADO", 1, "ADMINISTRACAO", 1, 2, 1, "", 1}
PRIVATE NLASTKEY   := 0
PRIVATE CPERG      := "LOCR023"
PRIVATE CBTXT      := SPACE(10)
PRIVATE CBCONT     := 00
PRIVATE CONTFL     := 01
PRIVATE M_PAG      := 01
PRIVATE WNREL      := "DSHEET" // COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING    := "FPQ"
PRIVATE CT61  := "T1"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
PRIVATE CTI61 := "TI1"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)


	DBSELECTAREA("FPQ")
	DBSETORDER(1)

	IMPRIME := .T.

	PERGUNTE(CPERG,.F.)

	WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,,TAMANHO)

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณRUNREPORT บ AUTOR ณ AP5 IDE            บ DATA ณ  07/05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
PRIVATE XSTRU := {}

	SETPRVT("XTQCOM,XTQVEN,XTQEST,XTQPED,XTVCOM,XTVVEN,XTVEST,XTVPED,XIMPLINHA")
	SETPRVT("XLQCOM,XLQVEN,XLQEST,XLQPED,XLVCOM,XLVVEN,XLVEST,XLVPED")
	ATAM:=TAMSX3("FPQ_DATA")
	AADD(XSTRU, {"FPQ_DATA"   ,ATAM[3],ATAM[1],ATAM[2] } )
	ATAM:=TAMSX3("RA_MAT")
	AADD(XSTRU, {"RA_MAT"     ,ATAM[3],ATAM[1],ATAM[2] } )
	ATAM:=TAMSX3("RA_NOME")
	AADD(XSTRU, {"RA_NOME"    ,ATAM[3],ATAM[1],ATAM[2] } )
	ATAM:=TAMSX3("RA_CODFUNC")
	AADD(XSTRU, {"RA_CODFUNC" ,ATAM[3],ATAM[1],ATAM[2] } )
	ATAM:=TAMSX3("RA_DESCFUN")
	AADD(XSTRU, {"RA_DESCFUN" ,ATAM[3],ATAM[1],ATAM[2] } )
	//ATAM:=TAMSX3("RA_NOME")
	//AADD(XSTRU, {"FPQ_DESC"   ,ATAM[3],ATAM[1],ATAM[2] } )
	AADD(XSTRU, {"FPQ_DESC"   ,"C"		,50		,0 		} )

	CT61  := "T61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI61 := "TI61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT61)
		TCDELFILE(CT61)
	ENDIF
	DBCREATE(CT61, XSTRU, "TOPCONN")
	DBUSEAREA(.T., "TOPCONN", CT61, ("TRB"), .F., .F.)
	DBCREATEINDEX(CTI61, "RA_MAT+DTOC(FPQ_DATA)"         , {|| RA_MAT+DTOC(FPQ_DATA)         })
	TRB->( DBCLEARINDEX() ) //FORวA O FECHAMENTO DOS INDICES ABERTOS
	DBSETINDEX(CTI61) //ACRESCENTA A ORDEM DE INDICE PARA A มREA ABERTA

	LoadData()

	//TITULO := ALLTRIM(TITULO) +" PERIODO DE " + ALLTRIM(DTOC(MV_PAR01)) + " A " + ALLTRIM(DTOC(MV_PAR02))
	TITULO := ALLTRIM(TITULO) + STR0018 + ALLTRIM(DTOC(MV_PAR01)) + STR0019 + ALLTRIM(DTOC(MV_PAR02)) //" PERIODO DE " ###  " A " 

	DBSELECTAREA("TRB")
	SETREGUA(RECCOUNT())

	DBGOTOP()
	WHILE !EOF()
		_CMAT := TRB->RA_MAT
		_LIMPLINHA := .T.
		WHILE !EOF()
			///IF LABORTPRINT
			//	@ NLIN,00 PSAY STR0006 //"*** CANCELADO PELO OPERADOR ***"
			//	EXIT
			//ENDIF
			
			INCREGUA()
			
			IF NLIN > 60 // SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 60 LINHAS...
				CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO,,.F.)
				NLIN := 7
				_LIMPLINHA := .T.
			ENDIF
			
			IF _LIMPLINHA .OR. _CMAT <> TRB->RA_MAT
				NLIN++
				@ NLIN,000 PSAY TRB->RA_MAT
				@ NLIN,008 PSAY TRB->RA_NOME
				//@ NLIN,055 PSAY TRB->RA_DESCFUN
				@ NLIN,NCOLFUNC PSAY TRB->RA_DESCFUN
				_CMAT := TRB->RA_MAT
				_LIMPLINHA := .F.
			ENDIF
			
			//@ NLIN,077 PSAY DTOC(FPQ_DATA)
			//@ NLIN,088 PSAY TRB->FPQ_DESC
			@ NLIN,NCOLDATA PSAY DTOC(FPQ_DATA)
			@ NLIN,NCOLDIVE PSAY TRB->FPQ_DESC
			NLIN++ // AVANCA A LINHA DE IMPRESSAO
			
			DBSELECTAREA("TRB")
			DBSKIP() // AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
		ENDDO
		
		@ NLIN,00 PSAY REPLICATE("_",132)
		NLIN ++
	ENDDO

	SET DEVICE TO SCREEN

	IF ARETURN[5]==1
		DBCOMMITALL()
		SET PRINTER TO
		OURSPOOL(WNREL)
	ENDIF

	MS_FLUSH()

	DBSELECTAREA("TRB")
	DBCLOSEAREA()

	&('TCSQLEXEC("DROP TABLE "+CT61)')
	&('TCSQLEXEC("DROP TABLE "+CTI61)')

RETURN

/*/{PROTHEUS.DOC} LOCR023.PRW
ITUP BUSINESS - TOTVS RENTAL
Carrega os dados a serem impressos
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 13/07/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
STATIC FUNCTION LoadData
LOCAL _CSITFOLH	:=	""
LOCAL NX        := 0 
LOCAL _F        := 0 
Local _CQUERY

	If !Empty(MV_PAR04)
		FOR NX := 1 TO LEN(MV_PAR04)
			_CSITFOLH += "'"+SUBSTR(MV_PAR04,NX,1)+"',"
		NEXT NX
		_CSITFOLH := SUBSTR(_CSITFOLH,1,LEN(_CSITFOLH)-1)
	EndIf

	/*
	+ALLTRIM(_CSITFOLH)+
	*/

	_CQUERY := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CODFUNC, SRA.RA_CC, SRJ.RJ_FUNCAO, SRJ.RJ_DESC " 
	_CQUERY += "FROM   " + RETSQLNAME("SRA") + " SRA INNER JOIN " 
	_CQUERY +=             RETSQLNAME("SRJ") + " SRJ ON "
	_CQUERY += "       SRJ.D_E_L_E_T_ = '' AND " 
	_CQUERY += "       SRA.RA_CODFUNC = SRJ.RJ_FUNCAO " 
	_CQUERY += "WHERE  SRA.D_E_L_E_T_ = '' "
	If MV_PAR03 == 1
		_CQUERY += "  AND  SRA.RA_FILIAL = '" + xFilial("SRA") + "' " 
	EndIF
	// 16/11/2022 - Jose Eulalio - SIGALOC94-566 - Somente se indicar ele realiza condi็ใo
	//_CQUERY += "       SRA.RA_TSHEET = 'S' AND "
	//_CQUERY += "       SRA.RA_SITFOLH  IN ("+ALLTRIM(_CSITFOLH)+") "
	//_CQUERY += "       SRA.RA_TSHEET = 'S' " + CRLF
	If !Empty(_CSITFOLH)
		_CQUERY += "       AND SRA.RA_SITFOLH  IN ( ? ) "
	EndIf

	_CQUERY := CHANGEQUERY(_CQUERY)
	aBindParam := {ALLTRIM(_CSITFOLH)}
	MPSysOpenQuery(_cQuery,"QRY",,,aBindParam)
	//TCQUERY _CQUERY NEW ALIAS "QRY"

	DBSELECTAREA("QRY")
	DBGOTOP()
	WHILE QRY->(!EOF())
		//IF MV_PAR03 == 2 
			FOR _F:= 0 TO MV_PAR02-MV_PAR01

				//AVISO! NรO FOI LANวADO HORAS DE INTEGRAวรO
				// status intgr e nใo tem horas no campo hrini ou hrfim
				//ERRO! NรO EXISTE LANวAMENTO NO DIA
				// nao esta em nenum dos status  nao precisa ver hrini e hrfin

				IF FPQ->(DBSEEK(XFILIAL("FPQ") + QRY->RA_MAT + DTOS(MV_PAR01 + _F)))
					If FPQ->FPQ_STATUS == "INTEGR" .AND. (empty(FPQ->FPQ_HRINI) .or. empty(FPQ->FPQ_HRFIN))
						LOC61GRV((MV_PAR01 + _F), QRY->RA_MAT, QRY->RA_NOME, QRY->RA_CODFUNC, QRY->RJ_DESC, STR0011 +" " + STR0012 + FPQ->FPQ_STATUS) //"AVISO! NรO FOI LANวADO HORAS DE INTEGRAวรO   "  ###  "ERRO! "
					EndIf
				ELSE
					_CERRO := STR0012 //"ERRO! XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					LOC61GRV((MV_PAR01 + _F), QRY->RA_MAT, QRY->RA_NOME, QRY->RA_CODFUNC, QRY->RJ_DESC, STR0013 + DTOC(MV_PAR01 + _F)) //"ERRO! NรO EXISTE LANวAMENTO NO DIA "
				ENDIF
			NEXT _F
		//ENDIF
		
		DBSELECTAREA("QRY")
		DBSKIP()
	ENDDO

	QRY->(DBCLOSEAREA()) 

RETURN



// ======================================================================= \\
STATIC FUNCTION LOC61GRV(_CDATA, _CMAT, _CNOME, _CCODFUNC, _CDESCFUN, _CERRO)
LOCAL _LRET	:= .T.

	DBSELECTAREA("TRB")
	RECLOCK('TRB',.T.)

	TRB->FPQ_DATA	:= _CDATA
	TRB->RA_MAT		:= _CMAT
	TRB->RA_NOME	:= _CNOME
	TRB->RA_CODFUNC	:= _CCODFUNC
	TRB->RA_DESCFUN	:= _CDESCFUN
	TRB->FPQ_DESC	:= _CERRO
	MSUNLOCK('TRB')

RETURN _LRET



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณVALIDPERG บ AUTOR ณ AP5 IDE            บ DATA ณ  07/05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   บฑฑ
ฑฑบ          ณ NECESSARIO (CASO NAO EXISTAM).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*
STATIC FUNCTION VALIDPERG() 
LOCAL _SALIAS := ALIAS()
LOCAL AREGS := {}
LOCAL I,J

	DBSELECTAREA("SX1")
	DBSETORDER(1)
	CPERG := PADR(CPERG,10)

//          GRUPO/ORDEM/PERGUNTA                                                            /VARIAVEL /TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID                                          /VAR01     /DEF01/DEF01/DEF01/CNT01/VAR02/DEF02/DEF02/DEF02/CNT02/VAR03/DEF03/DEF03/DEF03/CNT03/VAR04/DEF04/DEF04/DEF04/CNT04/VAR05/DEF05/DEF05/DEF05/CNT05/F3    /PYME/SXG/HELP/PICTURE/IDFIL
AADD(AREGS,{CPERG,"01" ,"PERอODO DE ?"        ,"PERอODO DE ?"        ,"PERอODO DE ?"        ,"MV_CH1" ,"D" ,08     ,0      ,0     ,"G","NAOVAZIO()"                                   ,"MV_PAR01",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
AADD(AREGS,{CPERG,"02" ,"PERอODO ATษ ?"       ,"PERอODO ATษ ?"       ,"PERอODO ATษ ?"       ,"MV_CH2" ,"D" ,08     ,0      ,0     ,"G","NAOVAZIO()"                                   ,"MV_PAR02",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"03" ,"MATRICULA DE ?"      ,"MATRICULA DE ?"      ,"MATRICULA DE ?"      ,"MV_CH3" ,"C" ,06     ,0      ,0     ,"G",""                                             ,"MV_PAR03",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"04" ,"MATRICULA ATษ ?"     ,"MATRICULA ATษ ?"     ,"MATRICULA ATษ ?"     ,"MV_CH4" ,"C" ,06     ,0      ,0     ,"G",""                                             ,"MV_PAR04",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"05" ,"STATUS DE ?"         ,"STATUS DE ?"         ,"STATUS DE ?"         ,"MV_CH5" ,"C" ,06     ,0      ,0     ,"G","VAZIO() .OR. EXISTCPO('SX5','75'+MV_PAR05)"   ,"MV_PAR05",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"75"  ,"S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"06" ,"STATUS ATษ ?"        ,"STATUS ATษ ?"        ,"STATUS ATษ ?"        ,"MV_CH6" ,"C" ,06     ,0      ,0     ,"G","VAZIO() .OR. EXISTCPO('SX5','75'+MV_PAR06)"   ,"MV_PAR06",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"75"  ,"S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"07" ,"NR. DA A.S. DE ?"    ,"NR. DA A.S. DE ?"    ,"NR. DA A.S. DE ?"    ,"MV_CH7" ,"C" ,27     ,0      ,0     ,"G",""                                             ,"MV_PAR07",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"DTQA","S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"08" ,"NR. DO PROJETO DE ?" ,"NR. DO PROJETO DE ?" ,"NR. DO PROJETO DE ?" ,"MV_CH8" ,"C" ,22     ,0      ,0     ,"G",""                                             ,"MV_PAR08",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0" ,"S"  ,"" ,"" ,""     ,""})
//AADD(AREGS,{CPERG,"09" ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"MV_CH9" ,"C" ,03     ,0      ,0     ,"G",""                                             ,"MV_PAR09",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
//AADD(AREGS,{CPERG,"10" ,"NR. DA A.S. ATษ ?"   ,"NR. DA A.S. ATษ ?"   ,"NR. DA A.S. ATษ ?"   ,"MV_CHA" ,"C" ,27     ,0      ,0     ,"G",""                                             ,"MV_PAR10",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"DTQA","S" ,"" ,""  ,""     ,""})
//AADD(AREGS,{CPERG,"11" ,"NR. DO PROJETO ATษ ?","NR. DO PROJETO ATษ ?","NR. DO PROJETO ATษ ?","MV_CHB" ,"C" ,22     ,0      ,0     ,"G",""                                             ,"MV_PAR11",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0" ,"S"  ,"" ,"" ,""     ,""})
//AADD(AREGS,{CPERG,"12" ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"NR. DA OBRA DE ?"    ,"MV_CHC" ,"C" ,03     ,0      ,0     ,"G",""                                             ,"MV_PAR12",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"13" ,"FILTRA SUA FILIAL ?" ,"FILTRA SUA FILIAL ?" ,"FILTRA SUA FILIAL ?" ,"MV_CHD" ,"N" ,01     ,0      ,2     ,"C",""                                             ,"MV_PAR03","SIM","SIM","SIM",""         ,""   ,"NรO","NรO","NรO",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,"S"  ,"" ,"" ,""     ,""})
AADD(AREGS,{CPERG,"14" ,"SITUACOES ?"         ,"SITUACIONES ?"       ,"STATUS ?"            ,"MV_CHE" ,"C" ,05     ,0      ,0     ,"G","FSITUACAO"                                    ,"MV_PAR04",""   ,""   ,""   ," ****"     ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""   ,"" ,"" ,""     ,""})

FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT
		MSUNLOCK()
	ELSEIF I==13
		RECLOCK("SX1",.F.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT
		MSUNLOCK()
	ENDIF
NEXT

DBSELECTAREA(_SALIAS)

RETURN*/
