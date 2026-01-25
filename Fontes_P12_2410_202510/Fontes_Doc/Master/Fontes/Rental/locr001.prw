#Include "Totvs.ch"
#INCLUDE "LOCR001.ch" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
 
/*/{PROTHEUS.DOC} LOCR001.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DE INTEGRAวรO POR OBRA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020 
@VERSION P12 
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/ 

FUNCTION LOCR001()
LOCAL CDESC1         := STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
LOCAL CDESC2         := STR0002 //"DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC3         := STR0003 //"RELATำRIO DE INTEGRAวรO POR OBRA"
LOCAL TITULO         := STR0003 //"RELATำRIO DE INTEGRAวรO POR OBRA"
LOCAL NLIN           := 80
LOCAL CABEC1         := ""
LOCAL CABEC2         := ""
LOCAL AORD           := {}
LOCAL IMPRIME 

PRIVATE LEND         := .F.
PRIVATE LABORTPRINT  := .F.
PRIVATE LIMITE       := 80
PRIVATE TAMANHO      := "P"
PRIVATE NOMEPROG     := "INTOBRA"
PRIVATE NTIPO        := 18
PRIVATE ARETURN      := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY     := 0
PRIVATE CPERG        := "LOCP012"
PRIVATE CBTXT        := SPACE(10)
PRIVATE CBCONT       := 00
PRIVATE CONTFL       := 01
PRIVATE M_PAG        := 01
PRIVATE WNREL        := "INTOBRA"
PRIVATE CSTRING      := "FPU"

	IMPRIME := .T.

	DBSELECTAREA("FPU")
	DBSETORDER(1)

	PERGUNTE(CPERG,.F.)

	WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.F.,TAMANHO,,.T.)

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
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNO    ณ RUNREPORT บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
LOCAL AARRAY := {}
LOCAL N      := 0 
Local CQRY1

	DBSELECTAREA(CSTRING)
	DBSETORDER(1)

	SETREGUA(RECCOUNT())

	NX       := 1
	CPROJANT := ""
	COBRAANT := ""  

	CQRY1 := "	SELECT FPU_CONTRO, FPU.FPU_PROJ, FPU.FPU_OBRA, FPU.FPU_MAT, FPU.FPU_NOME , FPU_AS , FPU_VALID, FPU_CRACHA, FPU_DTFIN " 
	CQRY1 += "	FROM "+RETSQLNAME("FPU")+" FPU  " 																		                                   				
	CQRY1 += " 	WHERE FPU.D_E_L_E_T_='' "                                                                        	              										
	CQRY1 += "   	AND FPU.FPU_FILIAL = '"+XFILIAL("FPU")+"'  "                                                                       									
	CQRY1 += "		AND FPU.FPU_MAT BETWEEN '"
	&('CQRY1 += MV_PAR03')
	CQRY1 += "' AND '"
	&('CQRY1 += MV_PAR04')
	CQRY1 += "' "                                                        									
	CQRY1 += "		AND FPU.FPU_DTFIN BETWEEN '"
	&('CQRY1 += DTOS(MV_PAR05)')
	CQRY1 += "' AND '"
	&('CQRY1 += DTOS(MV_PAR06)')
	CQRY1 += "'  " 				                                  					
	CQRY1 += "		AND FPU_CONTRO <> '' "																															
	CQRY1 += "	ORDER BY FPU_PROJ "		
	CQRY1 := ChangeQuery(CQRY1) 																																
	TCQUERY CQRY1 NEW ALIAS "TRB2"

	DBSELECTAREA("TRB2")
	TRB2->(DBGOTOP()) 
                   
	WHILE TRB2->(!EOF())
		AADD(AARRAY, {TRB2->FPU_CONTRO,TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->FPU_AS,TRB2->FPU_CRACHA, TRB2->FPU_DTFIN, TRB2->FPU_VALID})	
		TRB2->(DBSKIP()) 
	ENDDO             

	FOR N:= 1 TO LEN(AARRAY)
		
		IF LABORTPRINT
			@ NLIN,00 PSAY STR0023 //"*** CANCELADO PELO OPERADOR ***"
			EXIT
		ENDIF
		
		IF NLIN > 55 .OR. 	CPROJANT <> AARRAY[N][2] .OR. COBRAANT <> AARRAY[N][3]// SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			NLIN := 6
	
			NX++
			@ NLIN,00 PSAY " ________________________________________________________________________________"
			NLIN++
	
			@ NLIN,00 PSAY STR0024 //"|PROJETO:"
			@ NLIN,40 PSAY AARRAY[N][2]
			@ NLIN,81 PSAY "|"
	
			NLIN++
			@ NLIN,00 PSAY STR0025 //"|OBRA:"
			@ NLIN,40 PSAY AARRAY[N][3]
			@ NLIN,81 PSAY "|"
		
			@ NLIN,00 PSAY " ________________________________________________________________________________ "
			NLIN++
			@ NLIN,00 PSAY STR0028 //"|MATRอCULA |NOME FUNCIONมRIO                     |VAL.INTEGR. |VAL. ASO   |CRACHA|"
			@ NLIN,00 PSAY " ________________________________________________________________________________ "
			NLIN++
		ENDIF
		
		@ NLIN, 00 PSAY "|"+ ALLTRIM(AARRAY[N][4])  										//MATRICULA
		@ NLIN, 11 PSAY "|"+ ALLTRIM(AARRAY[N][5])                                        //NOME DO FUNCIONARIO
		@ NLIN, 49 PSAY "|"+ CVALTOCHAR((MONTHSUM( stod(AARRAY[N][8]), AARRAY[N][9])))	//CVALTOCHAR((MONTHSUM(FPU->FPU_DTFIN, FPU->FPU_VALID)))					    //VAL. INTEGRAวAี

		FPV->(dbSetOrder(3))
		If FPV->(dbSeek(xFilial("FPV")+AARRAY[N][6]))
			dTemp := FPV->FPV_DATVLD
		Else
			dTemp := ctod("")
		EndIf
		@ NLIN, 62 PSAY "|"+ DTOC(dTemp)
			
		IF ALLTRIM(AARRAY[N][7]) = '1'
			CCRACHA := STR0029 //"ATIVO"
		ELSE
			CCRACHA := STR0030 //" NAO "
		ENDIF
				
		@ NLIN, 74 PSAY "|"+ CCRACHA
		@ NLIN, 81 PSAY "|"
		NLIN := NLIN + 1 // AVANCA A LINHA DE IMPRESSAO
			
		CPROJANT := AARRAY[N][2]
		COBRAANT := AARRAY[N][3]
	
		@NLIN-1,00 PSAY  " ________________________________________________________________________________"
				
	NEXT

	TRB2->(DBCLOSEAREA())
		
	SET DEVICE TO SCREEN
		
	IF ARETURN[5]==1
		DBCOMMITALL()
		SET PRINTER TO
		OURSPOOL(WNREL)
	ENDIF
		
	MS_FLUSH() 

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALIDSX1  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//STATIC FUNCTION VALIDSX1(CPERG)
/*
PUTSX1(CPERG, "01",STR0031," "," ","MV_CH1" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR01","","",""," ","","","" ,"","","","","","","",""," ") //"PROJETO DE         ?"
PUTSX1(CPERG, "02",STR0032," "," ","MV_CH2" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR02","","",""," ","","","" ,"","","","","","","",""," ") //"PROJETO ATE        ?"
PUTSX1(CPERG, "03",STR0033," "," ","MV_CH3" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR03","","",""," ","","","" ,"","","","","","","",""," ") //"MATRICULA DE       ?"
PUTSX1(CPERG, "04",STR0034," "," ","MV_CH4" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR04","","",""," ","","","" ,"","","","","","","",""," ") //"MATRICULA ATE      ?"
PUTSX1(CPERG, "05",STR0035," "," ","MV_CH5" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR05","","",""," ","","","" ,"","","","","","","",""," ") //"DT.INTEGRAวรO DE   ?"
PUTSX1(CPERG, "06",STR0036," "," ","MV_CH6" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR06","","",""," ","","","" ,"","","","","","","",""," ") //"DT.INTEGRAวรO ATE  ?"
PUTSX1(CPERG, "07",STR0037," "," ","MV_CH7" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR07","","",""," ","","","" ,"","","","","","","",""," ") //"VENCTO ASO DE      ?"
PUTSX1(CPERG, "08",STR0038," "," ","MV_CH8" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR08","","",""," ","","","" ,"","","","","","","",""," ") //"VENCTO ASO ATE     ?"
PUTSX1(CPERG, "09",STR0039," "," ","MV_CH9" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR09","","",""," ","","","" ,"","","","","","","",""," ") //"CLIENTE DE         ?"
PUTSX1(CPERG, "10",STR0040," "," ","MV_CHA" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR10","","",""," ","","","" ,"","","","","","","",""," ") //"CLIENTE ATE        ?"
PUTSX1(CPERG, "11",STR0041," "," ","MV_CHB" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR11","","",""," ","","","" ,"","","","","","","",""," ") //"LOJA DE            ?"
PUTSX1(CPERG, "12",STR0042," "," ","MV_CHC" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR12","","",""," ","","","" ,"","","","","","","",""," ") //"LOJA ATE           ?"
PUTSX1(CPERG, "13",STR0043," "," ","MV_CHD" ,"N",01,0,0,"C","        "      , ""       ,"","","MV_PAR13",STR0044,"",""," ",STR0045,"","" ,"","","","","","","",""," ") //"EXPORTA EXCEL      ?"###"SIM"###"NรO"
*/
//RETURN NIL
