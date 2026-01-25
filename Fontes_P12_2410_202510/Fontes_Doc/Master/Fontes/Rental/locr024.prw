#Include "LOCR024.ch" 
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "RWMAKE.ch"

/*/ 
{PROTHEUS.DOC} LOCR024.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO PLANILHA DE LOCAÇÃO DE RELAÇÃO DE COLABORADORES ALOCADOS EM OBRAS VIA TIME SHEET
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020 
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/    
// ======================================================================= \\
Function LOCR024()
// ======================================================================= \\
    
// --> DECLARACAO DE VARIAVEIS. 
Local    aORD       := {}
Local    cDESC1     := STR0001 													// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local    cDESC2     := STR0002  												// "EXIBINDO A RELAÇÃO DE COLABORADORES ALOCADOS EM OBRAS."
Local    cDESC3     := STR0003 													// "ALOCAÇÕES / OBRAS"
Local    TITULO     := STR0004 													// "PLANILHA DE ALOCAÇÃO"
Local    _nLIN      := 80
Local    CABEC1     := ""
Local    CABEC2     := ""
Local    IMPRIME 

Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 80
Private TAMANHO     := "P"
Private NomeProg    := "LOCR024" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 15
Private aReturn     := { "ZEBRADO", 1, "ADMINISTRACAO", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "LOCR024" 												// "LOCP028"
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := "LOC065" 												// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
Private cString     := "FPQ"

	IMPRIME := .T.

	dbSelectArea("FPQ")
	dbSetOrder(1)

	//ValidPerg()
	Pergunte(cPerg , .F.)

	// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
	WNREL := SetPrint(cString , NomeProg , cPerg , @TITULO , cDESC1 , cDESC2 , cDESC3 , .F. , aORD , .F. , TAMANHO , , .F.) 

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn , cString)

	If nLastKey == 27
		Return
	EndIf

	nTIPO := Iif(aReturn[4]==1 , 15 , 18) 

	// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
	RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,_nLin) } , TITULO) 

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³ RUNREPORT º AUTOR ³ AP5 IDE            º DATA ³ 07/05/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS º±±
±±º          ³ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ PROGRAMA PRINCIPAL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , _nLin) 

	SetPrvt("XTQCOM , XTQVEN , XTQEST , XTQPED , XTVCOM , XTVVEN , XTVEST , XTVPED , XIMPLINHA") 

	// MONTA ARQUIVO DE TRABALHO
	// CRIA O ARQUIVO TEMPORARIO PARA SELECIONAR OS BUDGETS
	Private xSTRU := {}

	aTam := TamSX3("RA_FILIAL")
	aAdd(xSTRU , {"RA_FILIAL"  ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("RA_MAT")
	aAdd(xSTRU , {"RA_MAT"     ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("RA_NOME")
	aAdd(xSTRU , {"RA_NOME"    ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("FPQ_PROJET")
	aAdd(xSTRU , {"FPQ_PROJET" ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("RA_SALARIO")
	aAdd(xSTRU , {"RA_DSHEET"  ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("A1_COD")
	aAdd(xSTRU , {"A1_COD"     ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("A1_LOJA")
	aAdd(xSTRU , {"A1_LOJA"    ,aTam[3],aTam[1],aTam[2]} )
	aTam := TamSX3("FQ5_OBRA")
	aAdd(xSTRU , {"FQ5_OBRA"   ,aTam[3],aTam[1],aTam[2]} )

	CT65  := "T65" +SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2)
	CTI65 := "TI65"+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2)
	If TCCANOPEN(CT65)
		TCDELFILE(CT65)
	EndIf

	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	dbCreate(CT65 , xSTRU , "TOPCONN") 
	dbUseArea(.T. , "TOPCONN" , CT65 , ("TRB") , .F. , .F.) 
	dbCreateIndex(CTI65 , "FPQ_PROJET+RA_MAT" , {|| FPQ_PROJET+RA_MAT}) 
	TRB->( dbClearIndex() ) 														// FORÇA O FECHAMENTO DOS INDICES ABERTOS
	dbSetIndex(CTI65) 																// ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

	// --> CARREGA OS DADOS PARA IMPRESSAO
	QRYLOCR24()

	TITULO := AllTrim(TITULO) +" " + AllTrim(DtoC(MV_PAR01)) + "-" + AllTrim(DtoC(MV_PAR02))

	// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA
	dbSelectArea("TRB") 
	SetRegua(RecCount()) 

	dbGoTop()
	While !Eof()

		_cPRJ      := TRB->FPQ_PROJET 
		_lImpLinha := .T. 
		_lPriLinha := .T. 
		While !Eof()
			//If lAbortPrint
			//	@ _nLin,00 PSay STR0005 											// "*** CANCELADO PELO OPERADOR ***"
			//	Exit
			//EndIf

			IncRegua()

			If _nLin > 58 															// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 58 LINHAS...
				CABEC(TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
				_nLin := 6
			EndIf

			If _lImpLinha .Or. _cPRJ <> TRB->FPQ_PROJET
				If _lPriLinha
					_lPriLinha := .F.
				Else
					_nLin := IMPOBS(_nLin , _cPRJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
					@_nLin,00 PSay Replicate("_",LIMITE)
					_nLin++
				EndIf

				_nLin := IMPPRJ(_nLin , TRB->FPQ_PROJET , TITULO       , CABEC1 , CABEC2 , NomeProg , TAMANHO  , nTIPO)
				_nLin := IMPCLI(_nLin , TRB->A1_COD     , TRB->A1_LOJA , TITULO , CABEC1 , CABEC2   , NomeProg , TAMANHO , nTIPO) 
				_nLin := IMPDOC(_nLin , TRB->FPQ_PROJET , TITULO       , CABEC1 , CABEC2 , NomeProg , TAMANHO  , nTIPO)

				@_nLin,000 PSay STR0006 											// "FUNCIONARIOS  FL     MATRIC  NOME DO FUNCIONARIO                          DIAS"
				_nLin++
				_cPRJ      := TRB->FPQ_PROJET
				_lImpLinha := .F.
			EndIf 
			
			@_nLin,014 PSay TRB->RA_FILIAL 
			@_nLin,021 PSay TRB->RA_MAT 
			@_nLin,029 PSay SubStr(TRB->RA_NOME,1,38) 
			@_nLin,069 PSay TRB->FQ5_OBRA
			@_nLin,073 PSay TRB->RA_DSHEET Picture "99999" 
			_nLin++ 																// AVANCA A LINHA DE IMPRESSAO

			dbSelectArea("TRB") 
			dbSkip() 									   							// AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
		EndDo	
	
		_nLin := IMPOBS(_nLin , _cPRJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
		@_nLin,00 PSay Replicate("_",LIMITE)
		_nLin ++
	EndDo

	// --> FINALIZA A EXECUCAO DO RELATORIO... 
	Set Device To Screen

	// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
	If aReturn[5]==1
	DBCOMMITALL()
	Set Printer To
	OurSpool(WNREL)
	EndIf

	MS_FLUSH()

	// --> DELETA O ARQUIVO DE TRABALHO
	dbSelectArea("TRB") 
	dbCloseArea() 

	&('TCSQLEXEC("DROP TABLE "+CT65)')
	&('TCSQLEXEC("DROP TABLE "+CTI65)')

Return 



// ======================================================================= \\
Static Function IMPPRJ(_pLIN , _pPRJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
// ======================================================================= \\

//PROJETO/OBRA  XXXXXXXXXXXXXXXXXXXXXX / EI 123456789012345-123456789012345-123456789012345
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220

	If _pLIN > 54 																	// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 54 LINHAS...
		CABEC(TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO)
		_pLIN := 6
	EndIf

	@ _pLIN,000 PSay STR0007 														// "PROJETO/OBRA"

	If FP1->(dbSeek(xFilial("FP1")+_pPRJ))
		While FP1->(!Eof()) .And. FP1->FP1_PROJET == _pPRJ
			If _pLIN > 58 															// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 58 LINHAS...
				CABEC(TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
				_pLIN := 6
			EndIf
			@ _pLIN,014 PSay AllTrim(_pPRJ) + " / " + FP1->FP1_OBRA + "  CEI " + FP1->FP1_CEIORI
			_pLIN ++
			FP1->(dbSkip())
		EndDo
	Else
		@ _pLIN,014 PSay AllTrim(_pPRJ) + STR0008 + xFilial("FP1") + "." 			// ", NÃO CADASTRADO NA FILIAL "
		_pLIN++
	EndIf

Return _pLIN



// ======================================================================= \\
Static Function IMPCLI(_pLIN , _PCOD , _PLOJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO)
// ======================================================================= \\

//CLIENTE       999999/99 - 1234567890123456789012345678901234567890
//              123456789012345678901234567890123456789012345678901234567890
//              99999-999-123456789012345678901234567890-1234567890123456789012345-12
//              CNPJ 99.999.999/9999-99 IE 123456789012345678
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220

	@ _pLIN,000 PSay STR0009 														// "CLIENTE     "
	If SA1->(dbSeek(xFilial("SA1")+_PCOD+_PLOJ))
		@ _pLIN,014 PSay SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME
		_pLIN ++
		@ _pLIN,014 PSay SA1->A1_END
		_pLIN++
		// 16/11/2022 - Jose Eulalio - SIGALOC94-565 - Retirar hifen quando não houver bairro
		//@ _pLIN,014 PSay Transform(SA1->A1_CEP,"@R 99999-999") + "-" + AllTrim(SA1->A1_BAIRRO) + "-" + AllTrim(SA1->A1_MUN) + "/" + SA1->A1_EST
		@ _pLIN,014 PSay Transform(SA1->A1_CEP,"@R 99999-999") + IF(!Empty(SA1->A1_BAIRRO)," - " + AllTrim(SA1->A1_BAIRRO),"") + IF(!Empty(SA1->A1_MUN)," - " + AllTrim(SA1->A1_MUN),"") + IF(!Empty(SA1->A1_EST),"/" + SA1->A1_EST,"") 
		_pLIN++
		@ _pLIN,014 PSay STR0010 + Transform(SA1->A1_CGC, "@!R NN.NNN.NNN/NNNN-99") + STR0011 + AllTrim(SA1->A1_INSCR) 	// "CNPJ "###" IE "
	Else
		@ _pLIN,014 PSay STR0012 + _PCOD + "/" + _PLOJ + STR0013 					// "CLIENTE "###", NÃO CADASTRADO."
	EndIf

	_pLIN += 2

Return _pLIN



// ======================================================================= \\
Static Function IMPDOC(_pLIN , _pPRJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO)
// ======================================================================= \\

//Local _LFLAG		:= .F.

//DOCUMENTOS    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//              XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220

	@ _pLIN,000 PSay STR0014 														// "DOCUMENTOS  "
	_LIMP := .T.
	FPB->(dbSetOrder(1))
	If FPB->(dbSeek( xFilial("FPB") + _pPRJ))
		While FPB->(!Eof()) .And. FPB->FPB_PROJET == _pPRJ
			If _pLIN > 60 															// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 60 LINHAS...
				CABEC(TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO)
				_pLIN := 6
				@ _pLIN,000 PSay STR0014 											// "DOCUMENTOS  "
			EndIf

			If !Empty(FPB->FPB_CODIGO)
				_LIMP := .F.
				//If _LFLAG
				//	@ _pLIN,045 PSay "- " + FPB->FPB_DESCRI
				//	_pLIN++ 
				//	_LFLAG := .F.
				//Else
					@ _pLIN,014 PSay substr(FPB->FPB_DESCRI,1,30) + space(28) + " - " + FPB->FPB_OBRA
					_pLIN++
					//_LFLAG := .T.
				//EndIf
			EndIf
			
			FPB->(dbSkip())
		EndDo
	EndIf

	If _LIMP
		@ _pLIN,014 PSay STR0015 													// "NAO APRESENTAR DOCUMENTACAO"
	EndIf

	_pLIN += 2

Return _pLIN



// ======================================================================= \\
Static Function IMPOBS(_pLIN , _pPRJ , TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO) 
// ======================================================================= \\

Local _nNRLIN := 0 

	@ _pLIN,000 PSay STR0016 														// "OBSERVAÇÕES "
	If FP0->(dbSeek(xFilial("FP0")+_pPRJ))
		_NQTDLIN := MLCOUNT(FP0->FP0_OBSDOC,65)
		For _nNRLIN := 1 TO _NQTDLIN
			If _pLIN > 60 															// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 60 LINHAS...
				CABEC(TITULO , CABEC1 , CABEC2 , NomeProg , TAMANHO , nTIPO)
				_pLIN := 6
				@ _pLIN,000 PSay STR0016 											// "OBSERVAÇÕES "
			EndIf
			@ _pLIN,014 PSay MEMOLINE(FP0->FP0_OBSDOC,65,_nNRLIN)
			_pLIN++
		Next _nNRLIN
	EndIf

	_pLIN++

Return _pLIN



// ======================================================================= \\
Static Function QRYLOCR24() 
// ======================================================================= \\
// --> UTILIZADA PARA CARREGAR OS VALORES DAS COMPRAS DOS PRODUTOS.
Local _cQUERY

//Local	_cDirPad 	:= AllTrim(GetSrvProfString ("Startpath", ""))

	If Select("QRY") > 0 
		dbSelectArea("QRY") 
		dbCloseArea() 
	EndIf 

	/*
	+      MV_PAR03  +
	+      MV_PAR04  +
	+      MV_PAR05  +
	+      MV_PAR06  +
	+ DtoS(MV_PAR01) +
	+ DtoS(MV_PAR02) +
	*/

	_cQUERY := "SELECT FPQ.FPQ_FILIAL , FPQ.FPQ_MAT , FPQ.FPQ_DATA , FPQ.FPQ_STATUS , FPQ.FPQ_AS , FPQ.FPQ_PROJET , FPQ.FPQ_OBRA , FPQ.FPQ_DESC , FPQ.FPQ_VT , FPQ.FPQ_HORAS , " 
	_cQUERY += "       SRA.RA_FILIAL  , SRA.RA_MAT  , SRA.RA_NOME  , SRA.RA_CODFUNC , DTQ.FQ5_AS , DTQ.FQ5_CONTRA , " 
	_cQUERY += "       DTQ.FQ5_CODCLI , DTQ.FQ5_LOJA , SA1.A1_COD , SA1.A1_LOJA, DTQ.FQ5_OBRA     "                   
	_cQUERY += "FROM   " + RetSQLName("FPQ") + " FPQ "                                                                
	_cQUERY += "       INNER JOIN " + RetSQLName("SRA") + " SRA ON SRA.D_E_L_E_T_ = '' AND SRA.RA_FILIAL  = '"+xFilial("SRA")+"' AND FPQ.FPQ_MAT    = SRA.RA_MAT "     
	_cQUERY += "       LEFT  JOIN " + RetSQLName("FQ5") + " DTQ ON DTQ.D_E_L_E_T_ = '' AND FPQ.FPQ_AS     = DTQ.FQ5_AS     AND FPQ.FPQ_PROJET = DTQ.FQ5_CONTRA " 
	//_cQUERY += "       LEFT  JOIN " + RetSQLName("AAM") + " AAM ON AAM.D_E_L_E_T_ = '' AND DTQ.FQ5_CONTRA = AAM.AAM_CONTRT "                                     + CRLF 
	_cQUERY += "       LEFT  JOIN " + RetSQLName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND DTQ.FQ5_CODCLI = SA1.A1_COD     AND DTQ.FQ5_LOJA   = SA1.A1_LOJA "    
	_cQUERY += "WHERE  FPQ.D_E_L_E_T_ = ''                             AND "                                         
	_cQUERY += "       FPQ.FPQ_MAT    BETWEEN ? AND ? AND "            
	_cQUERY += "       FPQ.FPQ_PROJET BETWEEN ? AND ? AND "            
	_cQUERY += "       FPQ.FPQ_DATA   BETWEEN ? AND ? AND "            
	_cQUERY += "       FPQ.FPQ_STATUS >= 'OBRA  ' AND FPQ.FPQ_STATUS  <= 'OBRASL' AND "                
	_cQUERY += "       FPQ.FPQ_PROJET <> '                      ' "                                    

	//If !ExistDir( _cDirPad )
		//If MakeDir(_cDirPad) != 0
			//MsgAlert(OemToAnsi("O relatório não pode ser gerado, sem dados para exportação e criação do arquivo de relatório."))
		//endif
	//EndIf

	_cQUERY := ChangeQuery(_cQUERY) 
	aBindParam := {	MV_PAR03,;
					MV_PAR04,;
					MV_PAR05,;
					MV_PAR06,;
					DtoS(MV_PAR01),;
					DtoS(MV_PAR02)}
	MPSysOpenQuery(_cQuery,"QRY",,,aBindParam)

	//TCQUERY _cQUERY NEW ALIAS "QRY" 
		
	dbSelectArea("QRY") 
	dbGoTop()
	While QRY->(!Eof())
		dbSelectArea("TRB")
		If dbSeek(QRY->FPQ_PROJET + QRY->RA_MAT)
			RecLock("TRB",.F.)
		Else
			RecLock("TRB",.T.)
			TRB->RA_FILIAL	:= QRY->RA_FILIAL
			TRB->RA_MAT		:= QRY->RA_MAT
			TRB->RA_NOME	:= QRY->RA_NOME
			TRB->FPQ_PROJET	:= QRY->FPQ_PROJET
			TRB->A1_COD		:= QRY->A1_COD
			TRB->A1_LOJA	:= QRY->A1_LOJA
			TRB->FQ5_OBRA   := QRY->FQ5_OBRA
		EndIf
		TRB->RA_DSHEET	    := TRB->RA_DSHEET + 1 
		TRB->(MsUnLock()) 

		dbSelectArea("QRY")
		dbSkip()
	EndDo

	QRY->(dbCloseArea()) 

Return 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³ValidPerg º AUTOR ³ AP5 IDE            º DATA ³  07/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   º±±
±±º          ³ NECESSARIO (CASO NAO EXISTAM).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*Static Function ValidPerg() 
Local _SALIAS := ALIAS()
Local aRegs   := {}
Local I , J

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PadR(cPerg,10)

//          GRUPO/ORDEM/PERGUNTA                                                        /VARIAVEL /TIP/TAM/DEC/PRESEL/GSC/VALID                                    /VAR01     /DEF01/DEF01/DEF01/CNT01/VAR02/DEF02/DEF02/DEF02/CNT02/VAR03/DEF03/DEF03/DEF03/CNT03/VAR04/DEF04/DEF04/DEF04/CNT04/VAR05/DEF05/DEF05/DEF05/CNT05/F3    /PYME/SXG/HELP/PICTURE/IDFIL
aAdd(aRegs,{cPerg,"01" ,"Período de ?"        ,"¿De Período ?"     ,"From period ?"     ,"MV_CH1" ,"D",08 ,0  ,0     ,"G",""                                       ,"MV_PAR01",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
aAdd(aRegs,{cPerg,"02" ,"Período até ?"       ,"¿A Período ?"      ,"To Period ?"       ,"MV_CH2" ,"D",08 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","MV_PAR02",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""    ,""  ,"" ,""  ,""     ,""})
aAdd(aRegs,{cPerg,"03" ,"Matricula de ?"      ,"¿De Matrícula ?"   ,"From Record ?"     ,"MV_CH3" ,"C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR03",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
aAdd(aRegs,{cPerg,"04" ,"Matricula até ?"     ,"¿A Matrícula ?"    ,"To Record ?"       ,"MV_CH4" ,"C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR04 >= MV_PAR03)","MV_PAR04",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SRA" ,"S" ,"" ,""  ,""     ,""})
aAdd(aRegs,{cPerg,"05" ,"Nr. do Projeto de ?" ,"¿De Nº Proyecto ?" ,"From Project No. ?","MV_CH5" ,"C",22 ,0  ,0     ,"G",""                                       ,"MV_PAR05",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0" ,"S"  ,"" ,"" ,""     ,""})
aAdd(aRegs,{cPerg,"06" ,"Nr. do Projeto até ?","¿A Nº Proyecto ?"  ,"To Project No. ?"  ,"MV_CH6" ,"C",22 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR06 >= MV_PAR05)","MV_PAR06",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"FP0" ,"S"  ,"" ,"" ,""     ,""})

For I:=1 To Len(aRegs)
	If !dbSeek(cPerg+aRegs[I,2])
		RecLock("SX1",.T.)
		For J:=1 To FCount()
			If J <= Len(aRegs[I])
                FIELDPUT(J,aRegs[I,J])
			EndIf
        Next J 
        MsUnLock()
	EndIf
Next I 

dbSelectArea(_SALIAS)
Return*/

