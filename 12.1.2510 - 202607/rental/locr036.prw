#INCLUDE "TOTVS.CH"
//#INCLUDE "LOCR036.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCR036.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DE INTEGRAวรO POR OBRA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
FUNCTION LOCR036()
Alert("LOCR036 - Entre em contato com o administrador.")
/* Fonte comentado, pois nใo estแ no menu e o Relat๓rio LOCR001 parece ter as mesmas fun็๕es
LOCAL CDESC1         := OemToAnsi(STR0001) //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
LOCAL CDESC2         := OemToAnsi(STR0002) //"DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC3         := OemToAnsi(STR0003) //"RELATำRIO DE INTEGRAวรO POR OBRA"
LOCAL TITULO         := OemToAnsi(STR0003) //"RELATำRIO DE INTEGRAวรO POR OBRA"
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
PRIVATE ARETURN      := { STR0004, 1, STR0005, 2, 2, 1, "", 1} //"ZEBRADO" - "ADMINISTRACAO"
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

	//VALIDSX1(CPERG)
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
*/ //Fonte comentado, pois nใo estแ no menu e o Relat๓rio LOCR001 parece ter as mesmas fun็๕es
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
/* Fonte comentado, pois nใo estแ no menu e o Relat๓rio LOCR001 parece ter as mesmas fun็๕es
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

LOCAL CARQUIVO  								// ARQUIVO PADRรO HTML NA PASTA SERVER\SYSTEM
LOCAL NARQ      								// ABERTURA DO ARQUIVO BINมRIO
LOCAL CHTML										// STRINGS TEMPORมRIA PARA ALIMENTAR O ARQUIVO.HTML
LOCAL AARRAY := {}
LOCAL N      := 0 
Local CQRY1

	IF MV_PAR13 == 1								// SE FOR EXPORTAR PARA O EXCEL
		CARQUIVO  := CRIATRAB(,.F.)+".HTM"			// ARQUIVO PADRรO HTML NA PASTA SERVER\SYSTEM
		NARQ      := &('FCREATE(CARQUIVO,0)')			// ABERTURA DO ARQUIVO BINมRIO

		CHTML := "<HTML><HEAD><TITLE>"+OemToAnsi(STR0003)+"</TITLE></HEAD>" + CRLF
		CHTML += "<BODY><TABLE BORDER='1'><TR>"
		CHTML += "<TD COLSPAN='9'><CENTER><H2>"+OemToAnsi(STR0003)+"</H2></CENTER>"
		CHTML += STR0006 + IF( EMPTY(MV_PAR01), "", STR0012+MV_PAR01) + STR0013 + MV_PAR02
		CHTML += STR0007 + IF( EMPTY(MV_PAR03), "", STR0012+MV_PAR03) + STR0013 + MV_PAR04
		CHTML += STR0008 + IF( EMPTY(MV_PAR05), "", STR0012+DTOC(MV_PAR05)) + STR0013 + DTOC(MV_PAR06)
		CHTML += STR0009 + IF( EMPTY(MV_PAR07), "", STR0012+DTOC(MV_PAR07)) + STR0013 + DTOC(MV_PAR08)
		CHTML += STR0010 + IF( EMPTY(MV_PAR09), "", STR0012+MV_PAR09) + STR0013 + MV_PAR10
		CHTML += STR0011 + IF( EMPTY(MV_PAR11), "", STR0012+MV_PAR11) + STR0013 + MV_PAR12
		CHTML += "</TD></TR><TR>"

		CHTML += "<TH>"+OemToAnsi(STR0014)+"</TH>" //PROJETO
		CHTML += "<TH>"+OemToAnsi(STR0015)+"</TH>" //OBRA
		CHTML += "<TH>"+OemToAnsi(STR0016)+"</TH>" //MATRอCULA
		CHTML += "<TH>"+OemToAnsi(STR0017)+"</TH>" //NOME
		CHTML += "<TH>"+OemToAnsi(STR0018)+"</TH>" //VAL. INTEGRAวรO
		//CHTML += "<TH>"+OemToAnsi(STR0019)+"</TH>" //VAL. ASO
		CHTML += "<TH>"+OemToAnsi(STR0020)+"</TH>" //CRACHม
		//CHTML += "<TH>"+OemToAnsi(STR0021)+"</TH>" //PPRA VมLIDO ATษ:
		//CHTML += "<TH>"+OemToAnsi(STR0022)+"</TH>" //PCMSO VมLIDO ATษ:	
		CHTML += "</TR>" + CRLF
		FWRITE(NARQ,CHTML,LEN(CHTML))
	ENDIF

	DBSELECTAREA(CSTRING)
	DBSETORDER(1)

	SETREGUA(RECCOUNT())

	NX       := 1
	CPROJANT := ""
	COBRAANT := ""  

	// MONTAGEM DOS ITENS DO RELATำRIO
	// INCLUIDO A CONDIวรO FPU_CONTRO. SOMENTE TRAZER REGISTROS COM O CAMPO PREENCHIDO E O MAIOR NUMERO REFERENTE AO FUNCIONARIO.
	/*
	+MV_PAR03+
	+MV_PAR04+
	+DTOS(MV_PAR05)+
	+DTOS(MV_PAR06)+
	*/
/* Fonte comentado, pois nใo estแ no menu e o Relat๓rio LOCR001 parece ter as mesmas fun็๕es
	
	CQRY1 := " SELECT DISTINCT " 
	CQRY1 += " MAX(FPU_CONTRO) FPU_CONTRO,FPU_PROJ, FPU_OBRA, FPU_MAT, FPU_NOME, FPU_AS, FPU_DTFIN, FPU_VALID, " 
	CQRY1 += " FPU_CRACHA, CONVERT(VARCHAR(8),DATEADD ( MONTH ,FPU_VALID, FPU_DTFIN ),112) SOMDATA " 
	CQRY1 += " FROM	( "																																					
	CQRY1 += "	SELECT FPU_CONTRO, FPU.FPU_PROJ, FPU.FPU_OBRA, FPU.FPU_MAT, FPU.FPU_NOME, FPU_AS ,FPU_DTFIN, FPU_VALID, FPU_CRACHA " 							
	CQRY1 += "	FROM "+RETSQLNAME("FPU")+" FPU  " 																		                                   		
	CQRY1 += " 	WHERE FPU.D_E_L_E_T_='' "                                                                        	              								
	CQRY1 += "   	AND FPU.FPU_FILIAL = '"+XFILIAL("FPU")+"'  "                                                                       							
	CQRY1 += "		AND FPU.FPU_MAT BETWEEN ? AND ? "                                                        							
	CQRY1 += "		AND FPU.FPU_DTFIN BETWEEN ? AND ?  " 				                                  					
	CQRY1 += "		AND FPU_CONTRO <> '' "																														
	CQRY1 += "	) TMP "																																			
	CQRY1 += "  GROUP BY FPU_PROJ, FPU_OBRA, FPU_MAT, FPU_NOME ,FPU_AS ,FPU_DTFIN, FPU_VALID, FPU_CRACHA "														
	CQRY1 += "	ORDER BY FPU_PROJ "

	CQRY1 := ChangeQuery(CQRY1)
	aBindParam := {MV_PAR03,MV_PAR04,DTOS(MV_PAR05),DTOS(MV_PAR06)}
	MPSysOpenQuery(CQRY1,"TRB2",,,aBindParam)
	//TCQUERY CQRY1 NEW ALIAS "TRB2"

	DBSELECTAREA("TRB2")
	TRB2->(DBGOTOP()) 
					
	WHILE TRB2->(!EOF())
		NPOS := ASCAN(AARRAY,{|X| X[2] == TRB2->FPU_PROJ .AND. X[4] == TRB2->FPU_MAT .AND. X[3] == TRB2->FPU_OBRA})
		
		IF NPOS > 0
			IF AARRAY[NPOS][10] < TRB2->SOMDATA //CVALTOCHAR((MONTHSUM(STOD(TRB2->FPU_DTFIN), TRB2->FPU_VALID)))//
				IF AARRAY[NPOS][1] <= TRB2->FPU_CONTRO
					//AARRAY[NPOS]:= {TRB2->FPU_CONTRO,TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->TM5_DATVAL ,TRB2->TO0_DTVALI,TRB2->TMW_DTFIM, TRB2->FPU_AS ,TRB2->SOMDATA,TRB2->FPU_CRACHA}
					AARRAY[NPOS]:= {TRB2->FPU_CONTRO,TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->FPU_AS, TRB2->SOMDATA, TRB2->FPU_CRACHA }
				ENDIF
			ENDIF
		ELSE
			//AADD(AARRAY, {TRB2->FPU_CONTRO, TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->TM5_DATVAL ,TRB2->TO0_DTVALI,TRB2->TMW_DTFIM, TRB2->FPU_AS,TRB2->SOMDATA,TRB2->FPU_CRACHA})
			AADD(AARRAY, {TRB2->FPU_CONTRO, TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->FPU_AS,TRB2->SOMDATA,TRB2->FPU_CRACHA } )	
		ENDIF
		
		TRB2->(DBSKIP()) 
	ENDDO             

	FOR N:= 1 TO LEN(AARRAY)
		
	//	IF FPU->(DBSEEK(XFILIAL("FPU")+AARRAY[N][3]+AARRAY[N][2]+AARRAY[N][4]))
			IF LABORTPRINT
				@ NLIN,00 PSAY STR0023 //"*** CANCELADO PELO OPERADOR ***"
				EXIT
			ENDIF
		
			// IMPRIME CABEวALHO		
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
		
			// IMPRESSรO DOS ITENS
			@ NLIN, 00 PSAY "|"+ ALLTRIM(AARRAY[N][4])  										//MATRICULA
			@ NLIN, 11 PSAY "|"+ ALLTRIM(AARRAY[N][5])                                        //NOME DO FUNCIONARIO
			//@ NLIN, 49 PSAY "|"+ CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][10])))//CVALTOCHAR((MONTHSUM(FPU->FPU_DTFIN, FPU->FPU_VALID)))					    //VAL. INTEGRAวAี
			@ NLIN, 49 PSAY "|"+ CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][07])))
			//@ NLIN, 62 PSAY "|"+ DTOC(STOD(AARRAY[N][6]))
				
			IF ALLTRIM(AARRAY[N][08]) = '1'
				CCRACHA := STR0029 //"ATIVO"
			ELSE
				CCRACHA := STR0030 // " NAO "
			ENDIF
				
			@ NLIN, 62 PSAY "|"+ CCRACHA
			@ NLIN, 81 PSAY "|"
			NLIN := NLIN + 1 // AVANCA A LINHA DE IMPRESSAO
				
			CPROJANT := AARRAY[N][2]
			COBRAANT := AARRAY[N][3]
		
			@NLIN-1,00 PSAY  " ________________________________________________________________________________"
			
		//	NLIN:= 95 //SALDO DE PAGINA
			
			IF MV_PAR13 == 1		// SE FOR EXPORTAR PARA O EXCEL
				CHTML := '<TR>'
				CHTML += '<TD>' + AARRAY[N][2] + '</TD>'
				CHTML += '<TD>&NBSP;' + AARRAY[N][3] + '</TD>'
				CHTML += '<TD>&NBSP;' + ALLTRIM(AARRAY[N][4]) + '</TD>'
				CHTML += '<TD>' + ALLTRIM(AARRAY[N][5]) + '</TD>'
				//CHTML += '<TD>' + CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][10]))) + '</TD>'
				CHTML += '<TD>' + CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][07]))) + '</TD>'
				//CHTML += '<TD>' + DTOC(STOD(AARRAY[N][6])) + '</TD>'
				CHTML += '<TD>' + CCRACHA + '</TD>' + CRLF
				//CHTML += '<TD>' + DTOC(STOD(AARRAY[N][7])) + '</TD>' + CRLF
				//CHTML += '<TD>' + DTOC(STOD(AARRAY[N][8])) + '</TD></TR>' + CRLF
				FWRITE(NARQ,CHTML,LEN(CHTML))
			ENDIF    
	//	ENDIF
	//	TRB2->(DBSKIP())  
	//	TRB1->(DBCLOSEAREA()) 
		
	NEXT

	TRB2->(DBCLOSEAREA())
	//FPU->(DBCLOSEAREA())
		
	SET DEVICE TO SCREEN
		
	IF ARETURN[5]==1
		DBCOMMITALL()
		SET PRINTER TO
		OURSPOOL(WNREL)
	ENDIF
		
	MS_FLUSH() 

	IF MV_PAR13 == 1							// SE FOR EXPORTAR PARA O EXCEL
		CHTML := ' </TABLE></BODY></HTML>'+CRLF
		FWRITE(NARQ,CHTML,LEN(CHTML))
		FCLOSE(NARQ)							// FECHAMOS O ARQUIVO PADRรO HTML
		CPYS2T(GETSRVPROFSTRING("STARTPATH","")+CARQUIVO, ALLTRIM(GETTEMPPATH()), .T.)	// COPIA ARQUIVO HTML DO SERVER\SYSTEM P/ TEMPORมRIO DO CLIENTE
		FERASE(CARQUIVO)						// REMOVE ARQUIVO DO SERVER\SYSTEM

		IF APOLECLIENT("MSEXCEL") 				// SE TEM EXCEL NO CLIENTE. ABRIMOS O EXCEL COM O ARQUIVO HTML
			OEXCELAPP := MSEXCEL():NEW()
			OEXCELAPP:WORKBOOKS:OPEN(ALLTRIM(GETTEMPPATH()) + CARQUIVO)
			OEXCELAPP:SETVISIBLE(.T.)
			OEXCELAPP:DESTROY()
		ELSE									//SE NรO ENCONTROU O EXCEL, O S.O. DECIDE COMO ABRIR
			SHELLEXECUTE("OPEN",ALLTRIM(GETTEMPPATH()) + CARQUIVO,"","",1)
		ENDIF
	ENDIF

	//DBSELECTAREA("FPU")
	//RETINDEX("FPU")
	//FERASE(CARQUIVO+ORDBAGEXT())


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
/*
STATIC FUNCTION VALIDSX1(CPERG)

PUTSX1(CPERG, "01","PROJETO DE         ?"," "," ","MV_CH1" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR01","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "02","PROJETO ATE        ?"," "," ","MV_CH2" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR02","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "03","MATRICULA DE       ?"," "," ","MV_CH3" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR03","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "04","MATRICULA ATE      ?"," "," ","MV_CH4" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR04","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "05","DT.INTEGRAวรO DE   ?"," "," ","MV_CH5" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR05","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "06","DT.INTEGRAวรO ATE  ?"," "," ","MV_CH6" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR06","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "07","VENCTO ASO DE      ?"," "," ","MV_CH7" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR07","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "08","VENCTO ASO ATE     ?"," "," ","MV_CH8" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR08","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "09","CLIENTE DE         ?"," "," ","MV_CH9" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR09","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "10","CLIENTE ATE        ?"," "," ","MV_CHA" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR10","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "11","LOJA DE            ?"," "," ","MV_CHB" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR11","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "12","LOJA ATE           ?"," "," ","MV_CHC" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR12","","",""," ","","","" ,"","","","","","","",""," ")
PUTSX1(CPERG, "13","EXPORTA EXCEL      ?"," "," ","MV_CHD" ,"N",01,0,0,"C","        "      , ""       ,"","","MV_PAR13","SIM","",""," ","NรO","","" ,"","","","","","","",""," ")

RETURN NIL
*/
