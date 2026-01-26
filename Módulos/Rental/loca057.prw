#Include "loca057.ch"
#INCLUDE "loca057.ch" 
#INCLUDE "PROTHEUS.CH"                                                                                                                     
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{PROTHEUS.DOC} LOCA057.PRW
ITUP BUSINESS - TOTVS RENTAL
ROTINA DE APROVAÇÃO DE PROJETOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/  

FUNCTION LOCA057()
//LOCAL   _CCODUSR	:= RETCODUSR()
LOCAL _CFILATU	:= SM0->M0_CODFIL 
LOCAL _CUSRINC    := SPACE(06) 
LOCAL _CUSRALT    := SPACE(06) 
Local _CNMEINC := SUBSTR(ALLTRIM(USRFULLNAME(ALLTRIM(_CUSRINC))),1,30) 
Local _CNMEALT := SUBSTR(ALLTRIM(USRFULLNAME(ALLTRIM(_CUSRALT))),1,30)
Local CT67B
Local _CQUERY

PRIVATE _CCODUSR	:= RETCODUSR() 
PRIVATE CCADASTRO	:= STR0001 //"APROVAÇÃO DE PROJETOS"
PRIVATE _CMARCA		:= GETMARK()
PRIVATE CPERG		:= "LOCP029"
PRIVATE _LCAL		:= {}
PRIVATE _NCOL01		:= 0
PRIVATE _NCOL02		:= 0
PRIVATE _NCOL03		:= 0
PRIVATE _NCOL07		:= 0 //Quantidade Base
PRIVATE _NCOL08		:= 0 //Quantidade
PRIVATE _NCOL09		:= 0 //Acréscimo
PRIVATE _NCOL10		:= 0 //Valor Unitário
PRIVATE _NCOL11		:= 0 //Valor bruto
PRIVATE _NCOL12		:= 0 //% Desconto
PRIVATE _NCOL13		:= 0 //Valor de frete ida
PRIVATE _NCOL14		:= 0 //Valor de frete volta	
PRIVATE	_NCOL15 	:= 0 //Custo direto
PRIVATE	_NCOL16 	:= 0 //Receita
//PRIVATE _NLIMITE	:= 0
PRIVATE _MOBS		:= ""
PRIVATE AROTINA 	:= {}
PRIVATE ACAMPOS 	:= {}
PRIVATE AFIELDS		:= {}
PRIVATE _ARESUMO	:= {}
PRIVATE ACAMPOZA0	:= {}
private lImplemento := .F. // DSERLOCA 3817 - para nao dar erro na visualização no LOCA001

	//IF !LOCA061() 								// --> VALIDAÇÃO DO LICENCIAMENTO (WS) DO GPO 
		//RETURN 
	//ENDIF 

	// U_AJREMOCAO()								// CRIA PARÂMETROS, TABELAS, CONSULTAS E ETC - DESCONTINUADO, POIS ESTÁ NO WIZARD DE INSTALAÇÃO.

	IF ! GETMV("MV_LOCX020")
		MSGALERT(STR0002+CCADASTRO+STR0003 , STR0004)  //"ROTINA '"###"' DESABILITADA, VERIFIQUE MV_LOCX020"###"GPO - LOCT067.PRW"
		RETURN NIL
	ENDIF
	IF _CCODUSR != "000000" .AND. ! FPR->(DBSEEK(XFILIAL("FPR") + _CCODUSR))
		MSGALERT(STR0005 , STR0004)  //"ATENÇÃO: VOCÊ NÃO POSSUI AUTORIZAÇÃO PARA EFETUAR APROVAÇÃO DE PROJETOS."###"GPO - LOCT067.PRW"
		RETURN .F.
	ENDIF
	//ifranzoi
	If FPR->(FieldPos("FPR_TIPAPR")) == 0
		Help(Nil,Nil,AllTrim(Upper(Procname())),; // "RENTAL: "
				Nil,STR0004+" "+STR0049,1,0,Nil,Nil,Nil,Nil,Nil,; // "O campo FPR_TIPAPR não esta cadastrado."
				{STR0021})	 //"Aprovação"
		Return .F.
	EndIf
	//ifranzoi
	/*
	MV_PAR01 = PROJETO DE
	MV_PAR02 = PROJETO ATÉ
	MV_PAR03 = PERÍODO DE
	MV_PAR04 = PERÍODO ATÉ
	MV_PAR05 = TIPO DO SERVIÇO
	*/
	//VALIDPERG(CPERG)								// CRIA PERGUNTAS SE NÃO EXISTIR

	IF ! PERGUNTE(CPERG,.T.)
		RETURN NIL
	ENDIF

	//Proteção para não causar erro quando não é alterada a pergunta
	If ValType(MV_PAR05) == "N" .And. MV_PAR05 == 1
		MV_PAR05 := "L" //Locação
	Else 
		//05/10/2022 - Jose Eulalio - SIGALOC94-530 - Não possibilita aprovação do Projeto //
		MV_PAR05 := "E" //Equipamento
	EndIf

	//MV_PAR05 := UPPER(MV_PAR05) 

	// ALTERO O PARÂMETRO INFORMADO PARA O TIPO A SER USADO
	IF MV_PAR05 $ "T;E;L"
		_CDESCSE := ALLTRIM(CAPITAL(POSICIONE("SX5",1,XFILIAL("SX5")+"78" + MV_PAR05,"X5_DESCRI")))
	ELSE
		MSGALERT(STR0006 , STR0004)  //"ATENÇÃO: TIPO DE SERVIÇO NÃO IDENTIFICADO OU VAZIO."###"GPO - LOCT067.PRW"
		RETURN .F.
	ENDIF

	IF _CCODUSR != "000000" .AND. !FPR->(DBSEEK(XFILIAL("FPR") + _CCODUSR + MV_PAR05)) 
		MSGALERT(STR0007 + _CDESCSE , STR0004) //"ATENÇÃO: VOCÊ NÃO POSSUI AUTORIZAÇÃO PARA EFETUAR APROVAÇÃO DE PROJETOS DE "###"GPO - LOCT067.PRW"
		RETURN .F. 
	ENDIF 

	//_NLIMITE := IIF( _CCODUSR == "000000" , 999999999999999 , POSICIONE("FPR",1,XFILIAL("FPR") + _CCODUSR + MV_PAR05 , "FPR_LIMITE") )

	aRotina := menudef(aRotina)
	
	IF SELECT("QRY") > 0
		QRY->(DBCLOSEAREA())
	ENDIF

	/*
	+ _CFILATU +
	+      MV_PAR01  +
	+      MV_PAR02  +
	+ DTOS(MV_PAR03) +
	+ DTOS(MV_PAR04) +
	+ MV_PAR05 +
	*/

	_CQUERY := "SELECT * "
	_CQUERY += "FROM   " + RETSQLNAME("FP0") + " FP0 "
	_CQUERY += "WHERE  "
	_CQUERY += "	FP0.FP0_FILIAL = ? AND "
	_CQUERY += "	FP0.FP0_PROJET BETWEEN ? AND ? AND "
	_CQUERY += "	FP0.FP0_DATINC BETWEEN ? AND ? AND "
	_CQUERY += "	FP0.FP0_STATUS = '2' AND "								// EM APROVAÇÃO
	_CQUERY += "	FP0.FP0_TIPOSE = ? AND "				// TIPO DO SERVIÇO
	_CQUERY += "	FP0.D_E_L_E_T_ = ''  "
	_CQUERY := CHANGEQUERY(_CQUERY)

	aBindParam := {_CFILATU, MV_PAR01, MV_PAR02, DTOS(MV_PAR03), DTOS(MV_PAR04), MV_PAR05 }
	MPSysOpenQuery(_cQuery,"QRY",,,aBindParam)	
	//DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,, _CQUERY) , "QRY" , .T. , .T.) 

	ACAMPOS := {}
	ATAM    := TAMSX3("RA_OKTRANS")
	AADD(ACAMPOS , {"FP0_OK"     , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FP0_PROJET")
	AADD(ACAMPOS , {"FP0_PROJET" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FP0_CLINOM")
	AADD(ACAMPOS , {"FP0_CLINOM" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FP0_VALCON")
	AADD(ACAMPOS , {"FP0_COL01"  , "C"     , 18      , 0      })
	AADD(ACAMPOS , {"FP0_COL02"  , "C"     , 18      , 0      })
	AADD(ACAMPOS , {"FP0_COL03"  , "C"     , 18      , 0      })

	AADD(ACAMPOS , {"FP0_USERGI" , "C"     , 30      , 0      }) 

	AADD(ACAMPOS , {"FP0_USERGA" , "C"     , 30      , 0      })

	//ifranzoi - 01/08/2021
	ATAM    := TAMSX3("FPA_PREDIA")  //Quantidade Base
	AADD(ACAMPOS , {"FPA_PREDIA" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_QUANT") //Quantidade
	AADD(ACAMPOS , {"FPA_QUANT" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_ACRESC") //Acréscimo
	AADD(ACAMPOS , {"FPA_ACRESC" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_PRCUNI") //Valor Unitário
	AADD(ACAMPOS , {"FPA_PRCUNI" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_VLBRUT") //Valor bruto
	AADD(ACAMPOS , {"FPA_VLBRUT" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_GUIMON") //% Desconto
	AADD(ACAMPOS , {"FPA_GUIMON" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_PDESC") //
	AADD(ACAMPOS , {"FPA_PDESC" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_GUIDES") //
	AADD(ACAMPOS , {"FPA_GUIDES" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FP6_VALOR") //Custo direto
	AADD(ACAMPOS , {"FP6_VALOR" , ATAM[3] , ATAM[1] , ATAM[2]}) 

	ATAM    := TAMSX3("FPA_VRHOR") //Receita
	AADD(ACAMPOS , {"FPA_VRHOR" , ATAM[3] , ATAM[1] , ATAM[2]})
	//ifranzoi - 01/08/2021					
	// --> CRIA ARQUIVO DE TRABALHO PARA O BROWSE INICIAL
	//CNOMARQ := CRIATRAB(ACAMPOS)
	IF (SELECT("TRB") <> 0)
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
	ENDIF
	//DBUSEAREA(.T. , , CNOMARQ , "TRB" , NIL , .F.) 
	//INDREGUA("TRB" , CNOMARQ , "ZA0_PROJET" , , , "SELECIONANDO REGISTROS...") 

	CT67  := "T67"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI67 := "TI67"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT67)
		TCDELFILE(CT67)
	ENDIF
	DBCREATE(CT67, ACAMPOS, "TOPCONN")
	DBUSEAREA(.T., "TOPCONN", CT67, ("TRB"), .F., .F.)
	DBCREATEINDEX(CTI67, "FP0_PROJET"         , {|| FP0_PROJET         })
	TRB->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
	DBSETINDEX(CTI67) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

	ACAMPOS2 := {}
	ATAM     := TAMSX3("FP0_PROJET")
	AADD(ACAMPOS2 , {STR0011 , ATAM[3] , ATAM[1] , ATAM[2]} ) //"PROJETO"
	AADD(ACAMPOS2 , {"COLUNA1" , "C"     , 59      , 0      } )
	AADD(ACAMPOS2 , {"COLUNA2" , "C"     , 57      , 0      } )
	AADD(ACAMPOS2 , {"COLUNA3" , "C"     , 30      , 0      } )
	AADD(ACAMPOS2 , {"COLUNA4" , "C"     , 18      , 0      } )
	AADD(ACAMPOS2 , {"COLUNA5" , "C"     , 18      , 0      } )
	AADD(ACAMPOS2 , {"COLUNA6" , "C"     , 18      , 0      } )
	ATAM     := TAMSX3("FPA_PREDIA")
	AADD(ACAMPOS2 , {"COLUNA7" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_QUANT")
	AADD(ACAMPOS2 , {"COLUNA8" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_ACRESC")
	AADD(ACAMPOS2 , {"COLUNA9" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_PRCUNI")
	AADD(ACAMPOS2 , {"COLUNA10" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_VLBRUT")
	AADD(ACAMPOS2 , {"COLUNA11" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_PDESC")
	AADD(ACAMPOS2 , {"COLUNA12" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_GUIMON")
	AADD(ACAMPOS2 , {"COLUNA13" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_GUIDES")
	AADD(ACAMPOS2 , {"COLUNA14" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FP6_VALOR")
	AADD(ACAMPOS2 , {"COLUNA15" , ATAM[3] , ATAM[1] , ATAM[2]} )

	ATAM     := TAMSX3("FPA_VRHOR")
	AADD(ACAMPOS2 , {"COLUNA16" , ATAM[3] , ATAM[1] , ATAM[2]} )

	// --> CRIA ARQUIVO DE TRABALHO PARA O BOTÃO DETALHES
	//CNOMARQ2 := CRIATRAB(ACAMPOS2) 
	IF (SELECT("TMP") <> 0) 
		DBSELECTAREA("TMP") 
		DBCLOSEAREA() 
	ENDIF 
	//DBUSEAREA(.T. , , CNOMARQ2 , "TMP" , NIL , .F.) 
	//INDREGUA("TMP" , CNOMARQ2 , "PROJETO" , , , "SELECIONANDO REGISTROS...") 

	CT67B  := "T67B"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI67B := "TI67B"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT67B)
		TCDELFILE(CT67B)
	ENDIF
	DBCREATE(CT67B, ACAMPOS2, "TOPCONN")
	DBUSEAREA(.T., "TOPCONN", CT67B, ("TMP"), .F., .F.)
	DBCREATEINDEX(CTI67B, "PROJETO"         , {|| PROJETO         })
	TMP->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
	DBSETINDEX(CTI67B) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA


	DBSELECTAREA("QRY")
	DBGOTOP()
	WHILE QRY->(!EOF()) 
		LOCA05702(QRY->FP0_PROJET)

		_CUSRINC := SUBSTR(QRY->FP0_USERGI,03,1) + SUBSTR(QRY->FP0_USERGI,07,1) + SUBSTR(QRY->FP0_USERGI,11,1) + SUBSTR(QRY->FP0_USERGI,15,1) + ; 
					SUBSTR(QRY->FP0_USERGI,02,1) + SUBSTR(QRY->FP0_USERGI,06,1) + SUBSTR(QRY->FP0_USERGI,10,1) + SUBSTR(QRY->FP0_USERGI,14,1) + ; 
					SUBSTR(QRY->FP0_USERGI,01,1) + SUBSTR(QRY->FP0_USERGI,05,1) + SUBSTR(QRY->FP0_USERGI,09,1) + SUBSTR(QRY->FP0_USERGI,13,1) + ; 
					SUBSTR(QRY->FP0_USERGI,17,1) + SUBSTR(QRY->FP0_USERGI,04,1) + SUBSTR(QRY->FP0_USERGI,08,1)
		_CUSRINC := SUBSTR(_CUSRINC,3,6) 
		&('_CNMEINC := SUBSTR(ALLTRIM(USRFULLNAME(ALLTRIM(_CUSRINC))),1,30)')

		_CUSRALT := SUBSTR(QRY->FP0_USERGA,03,1) + SUBSTR(QRY->FP0_USERGA,07,1) + SUBSTR(QRY->FP0_USERGA,11,1) + SUBSTR(QRY->FP0_USERGA,15,1) + ; 
					SUBSTR(QRY->FP0_USERGA,02,1) + SUBSTR(QRY->FP0_USERGA,06,1) + SUBSTR(QRY->FP0_USERGA,10,1) + SUBSTR(QRY->FP0_USERGA,14,1) + ; 
					SUBSTR(QRY->FP0_USERGA,01,1) + SUBSTR(QRY->FP0_USERGA,05,1) + SUBSTR(QRY->FP0_USERGA,09,1) + SUBSTR(QRY->FP0_USERGA,13,1) + ; 
					SUBSTR(QRY->FP0_USERGA,17,1) + SUBSTR(QRY->FP0_USERGA,04,1) + SUBSTR(QRY->FP0_USERGA,08,1)
		_CUSRALT := SUBSTR(_CUSRALT,3,6) 
		&('_CNMEALT := SUBSTR(ALLTRIM(USRFULLNAME(ALLTRIM(_CUSRALT))),1,30)') 

		RECLOCK("TRB",.T.) 
		TRB->FP0_OK     := "   "
		TRB->FP0_PROJET := QRY->FP0_PROJET
		TRB->FP0_CLINOM := QRY->FP0_CLINOM
		TRB->FP0_COL01	:= TRANSFORM(_NCOL01,"@E 999,999,999,999.99")
		TRB->FP0_COL02 	:= TRANSFORM(_NCOL02,"@E 999,999,999,999.99")
		TRB->FP0_COL03	:= TRANSFORM(_NCOL03,"@E 999,999,999,999.99")
		TRB->FP0_USERGI	:= _CNMEINC 
		TRB->FP0_USERGA	:= _CNMEALT 
		//ifranzoi
		TRB->FPA_PREDIA	:= _NCOL07 //Quantidade Base
		TRB->FPA_QUANT	:= _NCOL08 //Quantidade
		TRB->FPA_ACRESC	:= _NCOL09 //Acréscimo
		TRB->FPA_PRCUNI	:= _NCOL10 //Valor Unitário
		TRB->FPA_VLBRUT	:= _NCOL11 //Valor bruto
		//TRB->FPA_PDESC	:= _NCOL12 //% Desconto
		TRB->FP6_VALOR	:= _NCOL15 //Custo direto
		TRB->FPA_VRHOR	:= _NCOL16 //Receita
		//ifranzoi

		TRB->(MsUnlock())
		QRY->(DBSKIP())
	ENDDO

	ASTRU := TRB->(DBSTRUCT())

	QRY->(DBCLOSEAREA())  		// FECHA ALIAS

	AFIELDSI := {}
	AADD(AFIELDS , {"FP0_OK"     , "C" , OEMTOANSI("   ")             })
	AADD(AFIELDS , {"FP0_PROJET" , "C" , OEMTOANSI("PROJETO")         })
	AADD(AFIELDS , {"FP0_CLINOM" , "C" , OEMTOANSI(STR0012) }) //"NOME DO CLIENTE"
	AADD(AFIELDS , {"FP0_COL01"  , "C" , OEMTOANSI(IIF(MV_PAR05$"T|O" , STR0013      , STR0014))      })	// MV_PAR05=="T" SIGNIFICA QUE É TRANSPORTE //"VR.BASE TOTAL"###"VR.BASE"
	AADD(AFIELDS , {"FP0_COL02"  , "C" , OEMTOANSI(IIF(MV_PAR05$"T|O" , "VR.TARIFAS"         , "VR.MOB/DESMOB"))})
	AADD(AFIELDS , {"FP0_COL03"  , "C" , OEMTOANSI(IIF(MV_PAR05$"T|O" , STR0015 , STR0016))     }) //"VR.FRETE INFORMADO"###"VR.TOTAL"
	AADD(AFIELDS , {"FP0_USERGI" , "C" , OEMTOANSI(STR0017)    }) //"INCLUÍDO POR"
	AADD(AFIELDS , {"FP0_USERGA" , "C" , OEMTOANSI(STR0018)}) //"ÚLTIMA ALTERAÇÃO"

	DBSELECTAREA("TRB")
	DBGOTOP()
	MARKBROW("TRB" , "FP0_OK" , , AFIELDS , , _CMARCA)

	TRB->( DBCLOSEAREA() )
	//FERASE( CNOMARQ + ".DBF" )
	//FERASE( CNOMARQ + ORDBAGEXT() )

	&('TCSQLEXEC("DROP TABLE "+CT67B)')
	&('TCSQLEXEC("DROP TABLE "+CTI67B)')

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05701(POPC)
// ======================================================================= \\

LOCAL _NOPC 	  := POPC
//LOCAL _NAPROVA    := VAL(STRTRAN(STRTRAN(TRB->FP0_COL03,".",""),",","."))
//Local nPrcDes := 0 //Percentual desconto
//Local nPrcMrg := 0 //Percentual margem

//ifranzoi
//Local cTipApr := "" //tipo de aprovação do usuário
//Local cUsuBlq := "" //bloqueio de usuário
//Local cLvlApp := "" //Nível do aprovador
//Local cLvlPrj := ""
//Local cQryExe := "" 
Local lReprova:= .F.
Local aAreaFP0:= FP0->(GetArea())
PRIVATE CCADASTRO := STR0019 //"DETALHES DO PROJETO"

	DO CASE

	//CASE (_NOPC == 1 .OR. _NOPC ==2) .AND. MSGYESNO("CONFIRMA A " + IIF(_NOPC == 1,"APROVAÇÃO","REPROVAÇÃO") + " DA(S) PROPOSTA(S) SELECIONADA(S) ?")	//APROVAÇÃO E REPROVAÇÃO
	CASE (_NOPC == 1 .OR. _NOPC ==2) .AND. MSGYESNO(STR0020 + IIF(_NOPC == 1,STR0021,STR0022) + STR0023 )	//APROVAÇÃO E REPROVAÇÃO

		// Jose Eulalio - 11/11/2022 - SIGALOC94-572 - Cadastro de Aprovação 
		// define se escolheu Aprova ou Reprova
		lReprova := If(_NOPC == 1,.F.,.T.)
		//escolhe indice 
		FP0->(DbSetOrder(1)) // FP0_FILIAL+FP0_PROJET
		//vai para o topo da grid
		TRB->(DBGOTOP())
		//roda a grid toda
		WHILE TRB->(!EOF())
			//executa somente os selecionados
			IF TRB->FP0_OK == _CMARCA
				//localiza contrato
				If FP0->(dbSeek(FwxFilial("FP0")+TRB->FP0_PROJET))
					// chama função de Aprovação / Reprovação
					If LOCA05704(NIL,NIL,NIL,NIL,lReprova)
						// DELETO DO ARQUIVO TEMPORÁRIO PARA NÃO APARECER MAIS NA TELA
						RECLOCK("TRB")
							TRB->(DBDELETE())
						MSUNLOCK()
					EndIf
				EndIf
			EndIf
			TRB->(DBSKIP())
		ENDDO
		
		TRB->(DBGOTOP())
		/*
		//ifranzoi
		//Dados da FPR para aprovação
		cQryExe := " SELECT " + CRLF
		// Jose Eulalio - 11/11/2022 - SIGALOC94-572 - Cadastro de aprovadores
		//cQryExe += " 	FPR_LIMITE, FPR_NIVEL, FPR_TIPAPR, FPR_PRCDES, FPR_PRCMRG, FPR_MSBLQL "+ CRLF
		cQryExe += " 	FPR_NIVEL, FPR_TIPAPR, FPR_PRCDES, FPR_PRCMRG, FPR_MSBLQL "+ CRLF
		cQryExe += " FROM " + RETSQLNAME("FPR") + " FPR "+ CRLF
		cQryExe += " WHERE "+ CRLF
		cQryExe += " 	FPR_FILIAL = '"+FwxFilial("FPR")+"' AND "+ CRLF
		cQryExe += "	FPR_CODUSR = '"+_CCODUSR+"' AND FPR.D_E_L_E_T_ = '' AND "+ CRLF
		cQryExe += "	FPR_TIPOSE = '"+MV_PAR05+"' "+ CRLF
		
		TcQuery cQryExe NEW ALIAS "TMPVAL"

		If TMPVAL->(!Eof())
			nPrcDes := TMPVAL->FPR_PRCDES //Percentual desconto
			nPrcMrg := TMPVAL->FPR_PRCMRG //Percentual margem
			cTipApr := TMPVAL->FPR_TIPAPR //tipo de aprovação do usuário
			cUsuBlq := TMPVAL->FPR_MSBLQL //bloqueio de usuário
			cLvlApp := TMPVAL->FPR_NIVEL //Nível do aprovador
		EndIf

		TMPVAL->(dbCloseArea())

		//Usuário bloqueado no cadastro de aprovadores
		If ( cUsuBlq == "1" )
			Help(Nil,Nil,alltrim(upper(Procname())),; // "RENTAL: "
				Nil,STR0004+" "+STR0040,1,0,Nil,Nil,Nil,Nil,Nil,;  //"Rental"
				{STR0021}) //"Aprovação"
		Else
			TRB->(DBGOTOP())
			WHILE TRB->(!EOF())
				IF TRB->FP0_OK == _CMARCA
					If FP0->(dbSeek(FwxFilial("FP0")+TRB->FP0_PROJET))
						If FP0->(FieldPos("FP0_NIVEL")) > 0
							cLvlPrj := FP0->FP0_NIVEL
						EndIf

						//Verifica o nível de aprovação que o projeto se encontra
						//Caso o nível do usuário seja menor igual, não deixa aprovar					
						If ( cLvlApp <= cLvlPrj )
							Help(Nil,Nil,alltrim(Upper(Procname())),; // "RENTAL: "
								Nil,STR0004+" "+STR0041,1,0,Nil,Nil,Nil,Nil,Nil,;  //"Rental"
								{STR0042})					 //"Verifique o nível da aprovação do usuário"
						Else
							//% Margem de contribuição = Margem de Contribuição (Valor Base - Custo Direto) / Receita
							nMrgCtr := ( Val(TRB->FP0_COL01) - TRB->FP6_VALOR ) / TRB->FPA_VRHOR

							//Considerar o pior caso - Desconto Maior ou Margem maior para realizar a aprovação
							If ( TRB->FPA_PDESC > nMrgCtr ) //Aprovação por Desconto
								//Verifica se o usuário pode aprovar por Desconto
								If ( cTipApr == "2" .or. cTipApr == "3" )
									//Se tem alçada, realiza a alteração do status do projeto, senão,
									//grava o nível e deixa para o próximo nível realizar a aprovação
									If ( nPrcDes >= TRB->FPA_PDESC )
										// ALTERO O STATUS PARA APROVADO OU REPROVADO (CONFORME A OPÇÃO)
										RecLock("FP0",.F.)
										FP0->FP0_STATUS := If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
										FP0->FP0_USUAPR	:= AllTrim(CUSERNAME)
										FP0->FP0_DTAPRO	:= DDATABASE
										FP0->FP0_HORAPR	:= Time()
										If FP0->(FieldPos("FP0_NIVEL")) > 0
											FP0->FP0_NIVEL := cLvlApp
										EndIf
										FP0->(MsUnlock()) 							
									Else
										//Se o usuário não tem alçada
										//Envia para o próximo nível de aprovação
										RecLock("FP0",.F.)									
										FP0->FP0_USUAPR	:= AllTrim(CUSERNAME)
										FP0->FP0_DTAPRO	:= DDATABASE
										FP0->FP0_HORAPR	:= Time()
										If FP0->(FieldPos("FP0_NIVEL")) > 0
											FP0->FP0_NIVEL := cLvlApp
										EndIf
										FP0->(MsUnlock())						
									EndIf

									//DELETO DO ARQUIVO TEMPORÁRIO PARA NÃO APARECER MAIS NA TELA
									RecLock("TRB")
									TRB->(DBDELETE())
									TRB->(MSUNLOCK())
									//TRB->(DBGOTOP())

								Else
									//Mensagem de aviso - não tem alçada de aprovação
									Help(Nil,Nil,alltrim(Upper(Procname())),; // "RENTAL: "
										Nil,STR0004+" "+STR0043,1,0,Nil,Nil,Nil,Nil,Nil,; // "Usuário sem alçada para aprovação do desconto."
										{STR0021})	 //"Aprovação"
								EndIf
							Else //Aprovação por Margem
								//Verifica se o usuário pode aprovar por Margem
								If ( cTipApr == "1" .or. cTipApr == "3" )
									//Se tem alçada, realiza a alteração do status do projeto, senão,
									//grava o nível e deixa para o próximo nível realizar a aprovação
									If ( nPrcMrg >= nMrgCtr )
										// ALTERO O STATUS PARA APROVADO OU REPROVADO (CONFORME A OPÇÃO)
										RecLock("FP0",.F.)
										FP0->FP0_STATUS := If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
										FP0->FP0_USUAPR	:= AllTrim(CUSERNAME)
										FP0->FP0_DTAPRO	:= DDATABASE
										FP0->FP0_HORAPR	:= Time()
										If FP0->(FieldPos("FP0_NIVEL")) > 0
											FP0->FP0_NIVEL := cLvlApp
										EndIf
										FP0->(MsUnlock())
									Else
										
										// ALTERO O STATUS PARA APROVADO OU REPROVADO (CONFORME A OPÇÃO)
										RecLock("FP0",.F.)									
										FP0->FP0_USUAPR	:= AllTrim(CUSERNAME)
										FP0->FP0_DTAPRO	:= DDATABASE
										FP0->FP0_HORAPR	:= Time()
										If FP0->(FieldPos("FP0_NIVEL")) > 0
											FP0->FP0_NIVEL := cLvlApp
										EndIf
										FP0->(MsUnlock())
									EndIf
									//DELETO DO ARQUIVO TEMPORÁRIO PARA NÃO APARECER MAIS NA TELA
									RecLock("TRB")
									TRB->(DBDELETE())
									TRB->(MSUNLOCK())
									//TRB->(DBGOTOP())
								Else
									//Mensagem de aviso - não tem alçada de aprovação
									Help(Nil,Nil,alltrim(Upper(Procname())),; // "RENTAL: "
										Nil,STR0004+" "+STR0043,1,0,Nil,Nil,Nil,Nil,Nil,;  //"Rental"
										{STR0021}) //"Aprovação"
								EndIf							
							EndIf
						EndIf
					EndIf
		
					//Regra antiga
					/*IF _NOPC == 1 .AND. _NLIMITE < _NAPROVA
						MSGALERT("ATENÇÃO: SEU LIMITE POR APROVAÇÃO (R$ " + ALLTRIM(TRANSFORM(_NLIMITE,"@E 999,999,999.99")) + ") É MENOR QUE O" + CHR(13) + CHR(10) + ;
								"VALOR DO PROJETO " + ALLTRIM(TRB->FP0_PROJET) + " (R$ " + ALLTRIM(TRB->FP0_COL03) + ")." , "GPO - LOCT067.PRW") 
						Help(Nil,Nil,alltrim(upper(Procname())),; // "RENTAL: "
								Nil,STR0004 + " "+ STR0017 +" "+ ALLTRIM(TRANSFORM(_NLIMITE,"@E 999,999,999.99")) + STR0019 + ALLTRIM(TRB->FP0_PROJET) + " (R$ " + ALLTRIM(TRB->FP0_COL03) + ").",1,0,Nil,Nil,Nil,Nil,Nil,;  //"Rental"
								{""})						 
					ELSE
						IF FP0->(DBSEEK(XFILIAL("FP0") + TRB->FP0_PROJET))
							// ALTERO O STATUS PARA APROVADO OU REPROVADO (CONFORME A OPÇÃO)
							RECLOCK("FP0",.F.)
							FP0->FP0_STATUS := IIF(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
							FP0->FP0_USUAPR	:= ALLTRIM(CUSERNAME)
							FP0->FP0_DTAPRO	:= DDATABASE
							FP0->FP0_HORAPR	:= TIME()
							FP0->(MSUNLOCK()) 
					
							// DELETO DO ARQUIVO TEMPORÁRIO PARA NÃO APARECER MAIS NA TELA
							RECLOCK("TRB")
							TRB->(DBDELETE())
							MSUNLOCK()
							TRB->(DBGOTOP())
						ENDIF
					ENDIF*/
				/*ENDIF
				TRB->(DBSKIP())
			ENDDO
			TRB->(DBGOTOP())
		EndIf		
		*/

	CASE _NOPC == 3 				// DETALHES
		_CFILTRO := "TMP->PROJETO == TRB->FP0_PROJET"
		TMP->( DBSETFILTER( {||&_CFILTRO}, _CFILTRO) )

		ABROWSE := {}
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0011                        , STR0011         ) , STR0011 , "C" , 22 , 0 , ""}) //"PROJETO"###"PROJETO"###"PROJETO"
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0027                        , STR0028            ) , "COLUNA1" , "C" , 59 , 0 , ""}) //"VIAGENS"###"OBRA"
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0029                         , STR0030    ) , "COLUNA2" , "C" , 48 , 0 , ""}) //"CARGAS"###"EQUIPAMENTOS"
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0031 , STR0032         ) , "COLUNA3" , "C" , 30 , 0 , ""}) //"COMP X LARG X ALTURAXPESO(TON)"###"PERIODO"
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0013                  , STR0014         ) , "COLUNA4" , "C" , 18 , 0 , ""}) //"VR.BASE TOTAL"###"VR.BASE"
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0033                     , STR0034) , "COLUNA5" , "C" , 18 , 0 , ""}) //"VR.TARIFAS"###"VR.MOB./ DESMOB."
		AADD(ABROWSE , {IIF(MV_PAR05=="T" , STR0015             , STR0016        ) , "COLUNA6" , "C" , 18 , 0 , ""}) //"VR.FRETE INFORMADO"###"VR.TOTAL"
		//ifranzoi - inicio
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0044, STR0044 ), "COLUNA7",	"C", 18, 0, ""}) //"Quantidade Base"
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0045, STR0045 ), "COLUNA8",	"C", 18, 0, ""}) //"Quantidade"
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0046, STR0046 ), "COLUNA9",	"C", 18, 0, ""}) //"Acréscimo"
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0047, STR0047 ), "COLUNA10",	"C", 18, 0, ""}) //"Valor Unitário"
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0048, STR0048 ), "COLUNA11",	"C", 18, 0, ""}) //"Valor Bruto"
		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0049, STR0049 ), "COLUNA12",	"C", 18, 0, ""}) //"% Desconto"

		If (MV_PAR05 == "L")
			aAdd(aBrowse , {IIF(MV_PAR05=="T", STR0050, STR0050 ), "COLUNA13" , "C" , 18 , 0 , ""}) //"Valor de frete ida"
			aAdd(aBrowse , {IIF(MV_PAR05=="T", STR0051, STR0051 ), "COLUNA14" , "C" , 18 , 0 , ""}) //"Valor de frete volta"
		EndIf

		aAdd(aBrowse, {IIF(MV_PAR05=="T", STR0052, STR0052 ), "COLUNA15",	"C", 18, 0, ""}) //"Custo"	
		//ifranzoi - fim	
		AROTANT   := ACLONE(AROTINA)

		AROTINA := { {STR0023,"LOCA05703()",0,1} } //" da(s) proposta(s) selecionada(s) ?"

		MBROWSE( 6 , 1 , 22 , 75 , "TMP" , ABROWSE , , , , 1 , ) 

		AROTINA   := AROTANT

	CASE _NOPC == 3 				// VISUALIZAR PROJETO
		FP0->(DBSEEK(XFILIAL("FP0") + TRB->FP0_PROJET))
		LOCA00110()

	ENDCASE   

	RestArea(aAreaFP0)

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05702(_PPROJET)
// ======================================================================= \\

LOCAL _CPROJET	:= _PPROJET
LOCAL _CEQUIP	:= ""
LOCAL _CDTINI	:= ""
LOCAL _CDTFIM	:= ""
LOCAL _NVALBAS	:= 0
LOCAL _NVALMOB	:= 0
LOCAL _NVALDES	:= 0
LOCAL _NVALTOT	:= 0  
LOCAL _NVALSEG	:= 0
//LOCAL _ARESUMO := {}

	_NCOL01 := _NCOL02 := _NCOL03 := _NCOL07 := _NCOL08 := _NCOL09 := _NCOL10 := _NCOL11 := _NCOL12 := 0 
	_NCOL13 := _NCOL14 := _NCOL15 := _NCOL16 := 0 

	DO CASE
	CASE MV_PAR05 $ "E;L"
		// NÍVEL OBRAS
		FP1->(DBSEEK(XFILIAL("FP1") + _PPROJET))
		WHILE FP1->(!EOF())  .AND.  FP1->FP1_PROJET == _PPROJET 
			_COBRA   := FP1->FP1_OBRA
			_CNOMORI := FP1->FP1_NOMORI

	// ======================================================================= \\
			IF MV_PAR05 == "L"							// --> LOCAÇÃO 
	// ======================================================================= \\
				// NIVEL LOCAÇÃO (ZAG)
				FPA->(DBSEEK(XFILIAL("FPA") + FP1->FP1_PROJET + FP1->FP1_OBRA ))
				WHILE FPA->(!EOF())  .AND.  FPA->FPA_PROJET == FP1->FP1_PROJET  .AND.  FPA->FPA_OBRA == FP1->FP1_OBRA 
					_CGRUA	   := FPA->FPA_GRUA
					_CDESGRU   := FPA->FPA_DESGRU
					_CEQUIP    := ALLTRIM(FPA->FPA_GRUA) + "-" + FPA->FPA_DESGRU
					_CDTINI	   := DTOC(FPA->FPA_DTINI)
					_CDTFIM	   := DTOC(FPA->FPA_DTFIM)
					_NVALBAS   := _NVRHOR := FPA->FPA_VRHOR
					_NPREDIAU  := FPA->FPA_PREDIA
					_NQTDFPA   := FPA->FPA_QUANT
					_NVALACRE  := FPA->FPA_ACRESC
					_VALUNITA  := FPA->FPA_PRCUNI
					_VALBRUTO  := FPA->FPA_VLBRUT
					_PRCDESCO  := FPA->FPA_PDESC
					_NVALBASU  := FPA->FPA_VRHOR 
					_NVALBASUT := _NPREDIAU * _NVALBASU
					_NMONTAGU  := FPA->FPA_MONTAG
					_NDESMONU  := FPA->FPA_DESMON
					_NTELESCU  := FPA->FPA_TELESC
					_NANCORAU  := FPA->FPA_ANCORA
					_NGUIMONU  := FPA->FPA_GUIMON
					_NGUIDESU  := FPA->FPA_GUIDES
					_NOPERADU  := FPA->FPA_OPERAD
					_NVALISSU  := FPA->FPA_VRISS
					_NVALSEGU  := FPA->FPA_VRSEGU

					// NÍVEL CUSTOS X PROJETO
					_NVALLSR   := _NVALPRE := _NVALPRF := _NVALTAP := _NVALTUV := _NVALTUR := _NVALESC := _NVALPED := _NVALINV := _NVALALE := 0
					_NVALIPT   := _NVALACO := _NVALCET := _NVALSEM := _NVALTVA := _NVALTEL := _NVALOUT := _NVALCON := _NVALADI := _NVALAUX := 0
					_NVL2LSR   := _NVL2PRE := _NVL2PRF := _NVL2TAP := _NVL2TUV := _NVL2TUR := _NVL2ESC := _NVL2PED := _NVL2INV := _NVL2ALE := 0
					_NVL2IPT   := _NVL2ACO := _NVL2CET := _NVL2SEM := _NVL2TVA := _NVL2TEL := _NVL2OUT := _NVL2CON := _NVL2ADI := _NVL2AUX := 0
					FQ8->(DBSETORDER(1))
					FQ8->(DBSEEK(XFILIAL("FQ8") + FPA->FPA_PROJET + FPA->FPA_OBRA + FPA->FPA_SEQTRA + "   " + FPA->FPA_SEQGRU ))
					WHILE FQ8->(!EOF())  .AND.  FQ8->FQ8_PROJET == FPA->FPA_PROJET  .AND.  FQ8->FQ8_OBRA == FPA->FPA_OBRA  .AND.  FQ8->FQ8_SEQTRA == FPA->FPA_SEQTRA  .AND.  FQ8->FQ8_SEQGRU == FPA->FPA_SEQGRU 
						_NVALLSR += FQ8->FQ8_VALLSR
						_NVALPRE += FQ8->FQ8_VALPRE
						_NVALPRF += FQ8->FQ8_VALPRF
						_NVALTAP += FQ8->FQ8_VALTAP
						_NVALTUV += FQ8->FQ8_VALTUV
						_NVALTUR += FQ8->FQ8_VALTUR
						_NVALESC += FQ8->FQ8_VALESC
						_NVALPED += FQ8->FQ8_VALPED
						_NVALINV += FQ8->FQ8_VALINV
					//	_NVALALE += FQ8->FQ8_VALALE
						_NVALIPT += FQ8->FQ8_VALIPT
						_NVALACO += FQ8->FQ8_VALACO
						_NVALCET += FQ8->FQ8_VALCET
						_NVALSEM += FQ8->FQ8_VALSEM
						_NVALTVA += FQ8->FQ8_VALTVA
						_NVALTEL += FQ8->FQ8_VALTEL
						_NVALOUT += FQ8->FQ8_VALOUT
						_NVALCON += FQ8->FQ8_VALCON
						_NVALADI += FQ8->FQ8_VALADI
						_NVALAUX += FQ8->FQ8_VALAUX

						_NVL2LSR += FQ8->FQ8_VL2LSR
						_NVL2PRE += FQ8->FQ8_VL2PRE
						_NVL2PRF += FQ8->FQ8_VL2PRF
						_NVL2TAP += FQ8->FQ8_VL2TAP
						_NVL2TUV += FQ8->FQ8_VL2TUV
						_NVL2TUR += FQ8->FQ8_VL2TUR
						_NVL2ESC += FQ8->FQ8_VL2ESC
						_NVL2PED += FQ8->FQ8_VL2PED
						_NVL2INV += FQ8->FQ8_VL2INV
					//	_NVL2ALE += FQ8->FQ8_VL2ALE
						_NVL2IPT += FQ8->FQ8_VL2IPT
						_NVL2ACO += FQ8->FQ8_VL2ACO
						_NVL2CET += FQ8->FQ8_VL2CET
						_NVL2SEM += FQ8->FQ8_VL2SEM
						_NVL2TVA += FQ8->FQ8_VL2TVA
						_NVL2TEL += FQ8->FQ8_VL2TEL
						_NVL2OUT += FQ8->FQ8_VL2OUT
						_NVL2CON += FQ8->FQ8_VL2CON
						_NVL2ADI += FQ8->FQ8_VL2ADI
						_NVL2AUX += FQ8->FQ8_VL2AUX
						FQ8->(DBSKIP())
					ENDDO

					_NVALCUS   := _NVALLSR + _NVALPRE + _NVALPRF + _NVALTAP + _NVALTUV + _NVALTUR + _NVALESC + _NVALPED + _NVALINV + _NVALALE
					_NVALCUS   += _NVALIPT + _NVALACO + _NVALCET + _NVALSEM + _NVALTVA + _NVALTEL + _NVALOUT + _NVALCON + _NVALADI + _NVALAUX
					_NVL2CUS   := _NVL2LSR + _NVL2PRE + _NVL2PRF + _NVL2TAP + _NVL2TUV + _NVL2TUR + _NVL2ESC + _NVL2PED + _NVL2INV + _NVL2ALE
					_NVL2CUS   += _NVL2IPT + _NVL2ACO + _NVL2CET + _NVL2SEM + _NVL2TVA + _NVL2TEL + _NVL2OUT + _NVL2CON + _NVL2ADI + _NVL2AUX

					_NVALMOB   := _NVALCUS 
					_NVALDES   := _NVL2CUS 

					// NÍVEL ACESSÓRIOS
					_NVRDIA := 0
					/*
					ZAK->(DBSETORDER(1))
					ZAK->(DBSEEK(XFILIAL("ZAK") + FPA->FPA_PROJET + FPA->FPA_OBRA + FPA->FPA_SEQGRU ))
					WHILE ZAK->(!EOF())  .AND.  ZAK->ZAK_PROJET == FPA->FPA_PROJET  .AND.  ZAK->ZAK_OBRA == FPA->FPA_OBRA  .AND.  ZAK->ZAK_SEQGRU == FPA->FPA_SEQGRU 
						_NVRDIA += ZAK->ZAK_VRDIA
						ZAK->(DBSKIP())
					ENDDO
					*/
					_NACESSOU  := _NVRDIA

					_NVALTOT   := _NVALBASUT + _NVALMOB  + _NVALDES 
					_NVALTOT   += _NMONTAGU  + _NDESMONU + _NTELESCU + _NANCORAU + _NGUIMONU + _NGUIDESU + _NOPERADU + _NACESSOU 
					_NVALTOT   += _NVALISSU  + _NVALSEGU 
					
					_NCOL01    += _NVALBAS 
					_NCOL02    += _NGUIMONU + _NGUIDESU 		// _NVALMOB + _NVALDES 
					_NCOL03    += _NVALTOT 

					//ifranzoi
					_NVALCUS := 0
					FP6->(dbSetOrder(1))
					FP6->(dbSeek(FwxFilial("FP6")+FPA->FPA_PROJET+FPA->FPA_OBRA))
					While !FP6->(EOF()) .and. FP6->(FP6_FILIAL+FP6_PROJET) == FwxFilial("FP6")+FPA->FPA_PROJET+FPA->FPA_OBRA
						_NVALCUS += FP6->FP6_VALOR
						FP6->(dbSkip())
					EndDo
					//ifranzoi

					//ifranzoi
					_NCOL07	+= _NPREDIAU //Quantidade Base
					_NCOL08	+= _NQTDFPA  //Quantidade
					_NCOL09	+= _NVALACRE //Acréscimo
					_NCOL10	+= _VALUNITA //Valor Unitário
					_NCOL11	+= _VALBRUTO //Valor bruto
					_NCOL12	+= _PRCDESCO //% Desconto
					_NCOL13	+= _NGUIMONU //Valor de frete ida
					_NCOL14	+= _NGUIDESU //Valor de frete volta
					_NCOL15 += _NVALCUS	 //Custo
					_NCOL16 += _NVALBASU //Receita
					DBSELECTAREA("TMP")
					RECLOCK("TMP",.T.)
					TMP->PROJETO	:= _CPROJET 
					TMP->COLUNA1	:= _CNOMORI 
					TMP->COLUNA2	:= _CEQUIP 
					TMP->COLUNA3	:= _CDTINI + " A " + _CDTFIM 
					TMP->COLUNA4	:= TRANSFORM(_NVALBAS         ,"@E 999,999,999,999.99") //Valor Base
					TMP->COLUNA5	:= TRANSFORM(_NVALMOB+_NVALDES,"@E 999,999,999,999.99") 
					TMP->COLUNA6	:= TRANSFORM(_NVALTOT         ,"@E 999,999,999,999.99")
					TMP->COLUNA7	:= _NPREDIAU //Quantidade Base
					TMP->COLUNA8	:= _NQTDFPA  //Quantidade
					TMP->COLUNA9	:= _NVALACRE //Acréscimo
					TMP->COLUNA10	:= _VALUNITA //Valor Unitário
					TMP->COLUNA11	:= _VALBRUTO //Valor bruto
					TMP->COLUNA12	:= _PRCDESCO //% Desconto
					TMP->COLUNA13	:= _NGUIMONU //Valor de frete ida
					TMP->COLUNA14	:= _NGUIDESU //Valor de frete volta
					TMP->COLUNA15	:= _NVALCUS	 //Custo direto
					TMP->COLUNA16	:= _NVALBASU //Receita
					MSUNLOCK("TMP")

					FPA->(DBSKIP())
				ENDDO
	// ======================================================================= \\
			ELSE										// --> EQUIPAMENTOS 
	// ======================================================================= \\
				// NIVEL LOCAÇÃO (ZA5)
				FP4->(DBSEEK(XFILIAL("FP4") + FP1->FP1_PROJET + FP1->FP1_OBRA ))
				WHILE FP4->(!EOF())  .AND.  FP4->FP4_PROJET == FP1->FP1_PROJET  .AND.  FP4->FP4_OBRA == FP1->FP1_OBRA 
					_CGUINDA   := FP4->FP4_GUINDA
					_CDESGUI   := FP4->FP4_DESGUI
					_CEQUIP    := FP4->FP4_GUINDA+"-"+FP4->FP4_DESGUI
					_CDTINI	   := DTOC(FP4->FP4_DTINI)
					_CDTFIM	   := DTOC(FP4->FP4_DTFIM)
					_NVALBAS   := _NVRHOR := FP4->FP4_VRHOR
					_NVALMOB   := FP4->FP4_VRMOB
					_NVALDES   := FP4->FP4_VRDES
					_NVALSEG   := FP4->FP4_VRSEGU

					_NQTMES	   := FP4->FP4_QTMES
					_NQTDIA	   := FP4->FP4_QTDIA
					_CTIPOCA   := FP4->FP4_TIPOCA
					_CTIPOISS  := FP4->FP4_TPISS

					_NPREDIA   := FP4->FP4_PREDIA
					_NVRHOR    := FP4->FP4_VRHOR
					_NMINDIA   := FP4->FP4_MINDIA
					_NMINMES   := FP4->FP4_MINMES
					
					_NVALISS   := FP4->FP4_VRISS
					_NVALTOT   := FP4->FP4_VALAS

					IF _NQTMES == 0 .AND. _NQTDIA == 0
						DO CASE
						CASE _CTIPOCA == "H" ; _NVALEQU := _NPREDIA * _NVRHOR * _NMINDIA
						CASE _CTIPOCA == "D" ; _NVALEQU := _NPREDIA * _NVRHOR * _NMINDIA
						CASE _CTIPOCA == "M" ; _NVALEQU := _NPREDIA * _NVRHOR * _NMINMES
						CASE _CTIPOCA == "F" ; _NVALEQU := _NVRHOR
						OTHERWISE            ; _NVALEQU := 0
						ENDCASE
					ELSE
						DO CASE
						CASE _CTIPOCA == "H" ; _NVALEQU := (_NQTMES * _NMINMES * _NVRHOR) + (_NQTDIA * _NMINDIA * _NVRHOR)
						CASE _CTIPOCA == "D" ; _NVALEQU := (_NQTMES * _NMINMES * _NVRHOR) + (_NQTDIA * _NMINDIA * _NVRHOR)
						CASE _CTIPOCA == "M" ; _NVALEQU := (_NQTMES * _NMINMES * _NVRHOR) + (_NQTDIA * _NMINDIA * _NVRHOR)
						CASE _CTIPOCA == "F" ; _NVALEQU := _NVRHOR
						OTHERWISE            ; _NVALEQU := 0
						ENDCASE
					ENDIF
						
					_NVALBAS   := _NVALEQU
						
					_NCOL01    += _NVALBAS
					_NCOL02    += _NVALMOB + _NVALDES
					_NCOL03    += _NVALTOT

					DBSELECTAREA("TMP")
					RECLOCK("TMP",.T.)
					TMP->PROJETO := _CPROJET
					TMP->COLUNA1 := _CNOMORI
					TMP->COLUNA2 := _CEQUIP
					TMP->COLUNA3 := _CDTINI + " A " + _CDTFIM
					TMP->COLUNA4 := TRANSFORM(_NVALBAS           ,"@E 999,999,999,999.99") 
					TMP->COLUNA5 := TRANSFORM(_NVALMOB + _NVALDES,"@E 999,999,999,999.99") 
					TMP->COLUNA6 := TRANSFORM(_NVALTOT           ,"@E 999,999,999,999.99") 
					MSUNLOCK("TMP")

					FP4->(DBSKIP())
				ENDDO
				
			ENDIF

			FP1->(DBSKIP())
		ENDDO

	// ======================================================================= \\
	CASE MV_PAR05 == "T"								// --> TRANSPORTE
	// ======================================================================= \\
		// NÍVEL VIAGENS
		ZA6->(DBSEEK(XFILIAL("ZA6") + _PPROJET))
		WHILE ZA6->(!EOF())  .AND.  ZA6->ZA6_PROJET == _PPROJET 
			_COBRA   := ZA6->ZA6_OBRA
			_CMUNORI := ZA6->ZA6_MUNORI
			_CESTORI := ZA6->ZA6_ESTORI
			_CMUNDES := ZA6->ZA6_MUNDES
			_CESTDES := ZA6->ZA6_ESTDES

			// NÍVEL CARGAS
			ZA7->(DBSEEK(XFILIAL("ZA7") + ZA6->ZA6_PROJET + ZA6->ZA6_OBRA ))
			WHILE ZA7->(!EOF())  .AND.  ZA7->ZA7_PROJET == ZA6->ZA6_PROJET  .AND.  ZA7->ZA7_OBRA == ZA6->ZA6_OBRA 
				_CSEQCAR  := ZA7->ZA7_SEQCAR
				_NQUANT   := VAL(ZA7->ZA7_QUANT)
				_CCARGA   := ZA7->ZA7_CARGA
				_NCOMP    := ZA7->ZA7_COMP
				_NLARG    := ZA7->ZA7_LARG
				_NALTU    := ZA7->ZA7_ALTU
				_NPESO    := ZA7->ZA7_PESO

				// NÍVEL CONJUNTO TRANSPORTADOR
				_CTRANSP  := ""
				_CTIPOCA  := ""
				_NDIASV   := 0
				_NDIASC   := 0
				_NVRDIA   := 0
				_NVALBASE := 0
				FP8->(DBSEEK(XFILIAL("FP8") + ZA7->ZA7_PROJET + ZA7->ZA7_OBRA + ZA7->ZA7_SEQTRA + ZA7->ZA7_SEQCAR ))
				WHILE FP8->(!EOF())  .AND.  FP8->FP8_PROJET == ZA7->ZA7_PROJET  .AND.  FP8->FP8_OBRA == ZA7->ZA7_OBRA  .AND.  FP8->FP8_SEQTRA == ZA7->ZA7_SEQTRA  .AND.  FP8->FP8_SEQCAR == ZA7->ZA7_SEQCAR 
					_CTRANSP := FP8->FP8_TRANSP
					_CTIPOCA := FP8->FP8_TIPOCA
					_NDIASV  += FP8->FP8_DIASV
					_NDIASC  += FP8->FP8_DIASC
					_NVRDIA  += FP8->FP8_VRDIA
					DO CASE
					CASE FP8->FP8_TIPOCA == "D"
						_NVALBASE += FP8->FP8_VRDIA
					OTHERWISE
						_NVALBASE := 0 // removido o campo na 94 frank em 26/02/21 POSICIONE("ST9" , 1 , XFILIAL("ST9")+FP8->FP8_TRANSP , "T9_VRDIA") 
					ENDCASE
					FP8->(DBSKIP())
				ENDDO
				// CALCULO A COLUNA VR.BASE TOTAL
				_NVALBASET := (_NDIASV + _NDIASC) * _NVALBASE
				
				// NÍVEL CUSTOS X PROJETO
				_NVALLSR   := _NVALPRE := _NVALPRF := _NVALTAP := _NVALTUV := _NVALTUR := _NVALESC := _NVALPED := _NVALINV := _NVALALE := 0
				_NVALIPT   := _NVALACO := _NVALCET := _NVALSEM := _NVALTVA := _NVALTEL := _NVALOUT := _NVALCON := _NVALADI := _NVALAUX := 0
				_NVALFRETE := 0
				FQ8->(DBSETORDER(2))
				FQ8->(DBSEEK(XFILIAL("FQ8") + ZA7->ZA7_PROJET + ZA7->ZA7_OBRA + ZA7->ZA7_SEQTRA + ZA7->ZA7_SEQCAR ))
				WHILE FQ8->(!EOF())  .AND.  FQ8->FQ8_PROJET == ZA7->ZA7_PROJET  .AND.  FQ8->FQ8_OBRA == ZA7->ZA7_OBRA  .AND.  FQ8->FQ8_SEQTRA == ZA7->ZA7_SEQTRA  .AND.  FQ8->FQ8_SEQCAR == ZA7->ZA7_SEQCAR 
					_NVALLSR   += FQ8->FQ8_VALLSR + FQ8->FQ8_VL2LSR
					_NVALPRE   += FQ8->FQ8_VALPRE + FQ8->FQ8_VL2PRE
					_NVALPRF   += FQ8->FQ8_VALPRF + FQ8->FQ8_VL2PRF
					_NVALTAP   += FQ8->FQ8_VALTAP + FQ8->FQ8_VL2TAP
					_NVALTUV   += FQ8->FQ8_VALTUV + FQ8->FQ8_VL2TUV
					_NVALTUR   += FQ8->FQ8_VALTUR + FQ8->FQ8_VL2TUR
					_NVALESC   += FQ8->FQ8_VALESC + FQ8->FQ8_VL2ESC
					_NVALPED   += FQ8->FQ8_VALPED + FQ8->FQ8_VL2PED
					_NVALINV   += FQ8->FQ8_VALINV + FQ8->FQ8_VL2INV
				//	_NVALALE   += FQ8->FQ8_VALALE + FQ8->FQ8_VL2ALE
					_NVALIPT   += FQ8->FQ8_VALIPT + FQ8->FQ8_VL2IPT
					_NVALACO   += FQ8->FQ8_VALACO + FQ8->FQ8_VL2ACO
					_NVALCET   += FQ8->FQ8_VALCET + FQ8->FQ8_VL2CET
					_NVALSEM   += FQ8->FQ8_VALSEM + FQ8->FQ8_VL2SEM
					_NVALTVA   += FQ8->FQ8_VALTVA + FQ8->FQ8_VL2TVA
					_NVALTEL   += FQ8->FQ8_VALTEL + FQ8->FQ8_VL2TEL
					_NVALOUT   += FQ8->FQ8_VALOUT + FQ8->FQ8_VL2OUT
					_NVALCON   += FQ8->FQ8_VALCON + FQ8->FQ8_VL2CON
					_NVALADI   += FQ8->FQ8_VALADI + FQ8->FQ8_VL2ADI
					_NVALAUX   += FQ8->FQ8_VALAUX + FQ8->FQ8_VL2AUX
					_NVALFRETE += FQ8->FQ8_VRFRET
					FQ8->(DBSKIP())
				ENDDO

				_NVALCUT := _NVALLSR + _NVALPRE + _NVALPRF + _NVALTAP + _NVALTUV + _NVALTUR + _NVALESC + _NVALPED + _NVALINV + _NVALALE
				_NVALCUT += _NVALIPT + _NVALACO + _NVALCET + _NVALSEM + _NVALTVA + _NVALTEL + _NVALOUT + _NVALCON + _NVALADI + _NVALAUX

				AADD(_ARESUMO , {_CPROJET , _COBRA , _CMUNORI , _CESTORI , _CMUNDES , _CESTDES , _CSEQCAR , _NQUANT   , _CCARGA    , _NCOMP   , _NLARG , ; 
								_NALTU   , _NPESO , _CTRANSP , _CTIPOCA , _NDIASV  , _NDIASC  , _NVRDIA  , _NVALBASE , _NVALBASET , _NVALCUT } ) 
			
				_NCOL01 += _NVALBASET 
				_NCOL02 += _NVALCUT 
				_NCOL03 += _NVALFRETE 

				DBSELECTAREA("TMP")
				RECLOCK("TMP",.T.)
				TMP->PROJETO := _CPROJET
				TMP->COLUNA1 := LEFT(ALLTRIM(_CMUNORI) + "/"   + ALLTRIM(_CESTORI) + SPACE(28) ,28) + " X " + LEFT(ALLTRIM(_CMUNDES) + "/" + ALLTRIM(_CESTDES) + SPACE(28) , 28)
				TMP->COLUNA2 := STR(_NQUANT,5,0)       + " X " + _CCARGA
				TMP->COLUNA3 := STR(_NCOMP ,6,0)       + "X"   + STR(_NLARG ,6,0)  + "X" + STR(_NALTU ,6,0) + "X" + STR(_NPESO ,9,3)
				TMP->COLUNA4 := TRANSFORM(_NVALBASET,"@E 999,999,999,999.99")
				TMP->COLUNA5 := TRANSFORM(_NVALCUT  ,"@E 999,999,999,999.99")
				TMP->COLUNA6 := TRANSFORM(_NVALFRETE,"@E 999,999,999,999.99")
				MSUNLOCK("TMP")

				ZA7->(DBSKIP())
			ENDDO

			ZA6->(DBSKIP())
		ENDDO

	ENDCASE

RETURN .T.



/*/{PROTHEUS.DOC} LOCA057.PRW
ITUP BUSINESS - TOTVS RENTAL
Fechar o mBrowse do Resumo
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 31/07/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
Function LOCA05703()

	CloseBrowse()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05704

Verifica se usuário pode ou não aprovar um contrato
@type   Function
@author Jose Eulalio
@since 10/11/2022

/*/
//------------------------------------------------------------------------------
Function LOCA05704(cAprovProj,cAprovUser,lMsg,lGrava,lReprova)
Local nPosPDesc		:= 1
Local nPosPMarg		:= 2
Local nPosTpApr		:= 3
Local nPosMsBlq		:= 4
Local nPosNivel		:= 5
Local lRet 			:= .T.
Local aAprovInfo	:= {}
Local aAreaFP0		:= FP0->(GetArea())
Local nOldDesc      := 0 // Frank em 14/11/22
Local nOldMargem    := 0 // Frank em 14/11/22
Local nNewDesc      := 0 // Frank em 14/11/22
Local nNewMargem    := 0 // Frank em 14/11/22

Default cAprovProj	:= FP0->FP0_PROJET
Default cAprovUser	:= __cUserId
Default lMsg		:= .T.
Default lGrava		:= .T.
Default lReprova	:= .F.

	//Retorna as informações do Aprovador
	aAprovInfo	:= LOCA05705(cAprovUser)

	//Segue para validações se existir aprovador
	If ATail(aAprovInfo)
		//Posiciona no Contrato
		FP0->(DbSetOrder(1)) // FP0_FILIAL+FP0_PROJET
		If FP0->(DbSeek(xFilial("FP0") + cAprovProj))

			// Frank em 14/11/2022
			// Se a rotina for da geracao do contrato e o status estiver 3 = aprovado, nao precisa passar pelos controles abaixo.
			If FWIsInCallStack("LOCA013")
				If FP0->FP0_STATUS == "3"
					Return .T.
				Else
					// Status que entra na validacao: 
						// pasta verde bola cinza FP0_STATUS == "0"
						// verde FP0_STATUS == "1"
					// qualquer status <> dar mensagem que o status nao possibilita a geracao do contrato
					// 1. Passo, se o usuario logado nao estiver cadastrado como aprovador dar a mensagem e bloquear
					// 2. Passo: verificar se houve alteração da margem, ou do desconto.
					// 3. Passo: tendo alteracao, se o tipo do usuario for ambos bloquear se, a margem for para menos, ou o desconto para mais
					// 4. Passo: se a alteração for de desconto e o tipo do aprovador for margem aceitar
					// 5. Passo: se a alteração for de desconto e o tipo do usuario for de desconto e o desconto foi acima do que já estava antes bloquear
					// 6. Passo: se a alteração for de margem e o tipo do aprovador for de desconto aceitar. 
					// 7. Passo: se a alteração for de margem e o tipo do usuario for margem e a margem for abaixo do que já estava antes bloquear.
					// 8. Passo: se a alteração for de margem para baixo e desconto acima (as duas alteracoes). Sempre travar.

					If FP0->FP0_STATUS == "0" .or. FP0->FP0_STATUS == "1"
						nOldDesc      := FP0->FP0_PDESCO
						nOldMargem    := FP0->FP0_PMARGE
						nNewDesc      := round(LOCA057R("D"),2)
						nNewMargem    := round(LOCA057R("M"),2)
						If aAprovInfo[nPosMsBlq] == "1"
							Help(Nil,Nil, "LOCA057_01",Nil, STR0053,1,0,Nil,Nil,Nil,Nil,Nil, {STR0054})	 // "Usuário bloqueado no Cadasdro de Aprovadores" ###  // "Verifique a situação do cadastro com o Responsável."
							Return .F.
						EndIf
						If nOldDesc <> nNewDesc .or. nNewMargem <> nOldMargem
							If aAprovInfo[nPosTpApr] $ "3" // Ambos
								If nNewDesc > nOldDesc .or. nNewMargem <  nOldMargem
									Help(Nil,Nil, STR0076,Nil, STR0074,1,0,Nil,Nil,Nil,Nil,Nil, {STR0075})  //"Projeto necessita passar por aprovação!" //"Solicitar aprovação e aguardar liberação antes de gerar o contrato!" //"LOCA057_F1"
									//MsgAlert("Usuario do tipo ambos com desconto acima do anterior, ou margem abaixo da anterior.","Erro 1 - valido apenas para usuario do tipo desconto, ou margem.")
									Return .F.
								EndIF
							EndIF
							If nOldDesc <> nNewDesc .and. nOldMargem == nNewMargem
								//If aAprovInfo[nPosTpApr] $ "2" // Desconto (entendimento 1 - Lui)
								If aAprovInfo[nPosTpApr] $ "1" // 1 = aprovador do tipo Margem sempre aceitar, pouco importa o % que foi alterado
									// Sempre aceitar
								Else
									// se o tipo do usuario for "2"  2 = Desconto
									If nNewDesc > nOldDesc
										Help(Nil,Nil, "LOCA057_F2",Nil, STR0069,1,0,Nil,Nil,Nil,Nil,Nil, {STR0070}) // "O tipo do usuario é desconto e o desconto atual é maior do que o anterior."###"Verificar o desconto informado." 
										//MSgAlert("O tipo do usuario é desconto e o desconto atual é maior do que o anterior.","Erro 2")
										Return .F.
									EndIF
								EndIF
							EndIF
							If nOldDesc == nNewDesc .and. nOldMargem <> nNewMargem
								If aAprovInfo[nPosTpApr] $ "2" // 2 = aprovador do tipo desconto sempre aceitar, pouco importa o % que foi alterado
									// Sempre aceitar
								Else
									// se o tipo do usuario for "1"  1 = Margem
									If nNewMargem < nOldMargem
										Help(Nil,Nil, "LOCA057_F3",Nil, STR0071,1,0,Nil,Nil,Nil,Nil,Nil, {STR0072}) //"O tipo do usuario é margem e a margem atual é menor do que a anterior."###"Verificar a margem informada." 
										Return .F.
									EndIF
								EndIF							
							EndIF
							If nOldDesc <> nNewDesc .and. nOldMargem <> nNewMargem
								//MsgAlert("Houve alteração do desconto e da margem, necessário aprovar novamente.","Atenção!")
								Help(Nil,Nil, "LOCA057_F5",Nil, STR0065,1,0,Nil,Nil,Nil,Nil,Nil, {STR0066}) //"Houve alteração do desconto e da margem, necessário aprovar novamente."###"Faz-se necessário aprovar novamente."
								Return .F.
							EndIF
						EndIf
					Else
						//MsgAlert("O status não permite a geração do contrato.","Atenção!")
						Help(Nil,Nil, STR0078,Nil, "Projeto está com status em aprovação!",1,0,Nil,Nil,Nil,Nil,Nil, {STR0077})  //"Necessário aprovar pela rotina específica antes de gerar contrato!" //"LOCA057_F6" //'em aprovação'
						Return .F.
					EndIF
				EndIF
			EndIF

			//verifca se o contrato tem desconto ou margem para serem aprovados
			nNewDesc      := round(LOCA057R("D"),2)
			nNewMargem    := round(LOCA057R("M"),2)
			//If FP0->FP0_PDESCO > 0 .Or. FP0->FP0_PMARGE <> 100
			//If nNewDesc > 0 .Or. nNewMargem <> 100 // Jose Eulalio - 20/04/2023 - SIGALOC94-674 - Linha retirada, pois o projeto deverá ser aprovado/reprovado, mesmo se não for alterado
				//verifica se está bloqueado
				If aAprovInfo[nPosMsBlq] == "1"
					lRet := .F.
					If lMsg
						Help(Nil,Nil, "LOCA057_01",Nil, STR0053,1,0,Nil,Nil,Nil,Nil,Nil, {STR0054})	 // "Usuário bloqueado no Cadasdro de Aprovadores" ###  // "Verifique a situação do cadastro com o Responsável."
					EndIf
				//verifica o nível, só passa se o nível do contrato for menor que o do usuário aprovador
				ElseIf FP0->FP0_NIVEL <= aAprovInfo[nPosNivel] .or. FWIsInCallStack("LOCA013") // Frank em 16/11/22 se for geracao do contrato permitir independente do nivel do usuario
					// Regra exclusiva para desconto
					If aAprovInfo[nPosTpApr] $ "2"
						//verifica o se o usuário pode liberar desconto maior do que o contrato
						//If ( aAprovInfo[nPosPDesc] >= FP0->FP0_PDESCO ) .or. FWIsInCallStack("LOCA013")
						If ( aAprovInfo[nPosPDesc] >= nNewDesc ) .or. FWIsInCallStack("LOCA013")
							//grava as informações no contrato
							If lGrava
								RecLock("FP0",.F.)
									FP0->FP0_STATUS := If(lReprova, "4","3")  //If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
									FP0->FP0_USUAPR	:= AllTrim(cUserName)
									FP0->FP0_DTAPRO	:= dDataBase
									FP0->FP0_HORAPR	:= Time()
									If FP0->(FieldPos("FP0_NIVEL")) > 0
										FP0->FP0_NIVEL := aAprovInfo[nPosNivel]
									EndIf
								FP0->(MsUnlock())
							EndIf
						Else	
							lRet := .F.
						EndIf
					EndIf
					// Especifico para tipo de aprovador ambos - Frank
					If aAprovInfo[nPosTpApr] $ "3"
						If (( aAprovInfo[nPosPDesc] >= nNewDesc ) .and. ( aAprovInfo[nPosPMarg] <= nNewMargem )) .or. FWIsInCallStack("LOCA013")
							//grava as informações no contrato
							If lGrava
								RecLock("FP0",.F.)
									FP0->FP0_STATUS := If(lReprova, "4","3")  //If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
									FP0->FP0_USUAPR	:= AllTrim(cUserName)
									FP0->FP0_DTAPRO	:= dDataBase
									FP0->FP0_HORAPR	:= Time()
									If FP0->(FieldPos("FP0_NIVEL")) > 0
										FP0->FP0_NIVEL := aAprovInfo[nPosNivel]
									EndIf
								FP0->(MsUnlock())
							EndIf
						Else	
							lRet := .F.
						EndIf
					EndIf
					// Especifico para tipo margem
					If aAprovInfo[nPosTpApr] $ "1"
						If aAprovInfo[nPosPMarg] <= nNewMargem  .or. FWIsInCallStack("LOCA013")
							//grava as informações no contrato
							If lGrava
								RecLock("FP0",.F.)
									FP0->FP0_STATUS := If(lReprova, "4","3")  //If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
									FP0->FP0_USUAPR	:= AllTrim(cUserName)
									FP0->FP0_DTAPRO	:= dDataBase
									FP0->FP0_HORAPR	:= Time()
									If FP0->(FieldPos("FP0_NIVEL")) > 0
										FP0->FP0_NIVEL := aAprovInfo[nPosNivel]
									EndIf
								FP0->(MsUnlock())
							EndIf
						Else	
							lRet := .F.
						EndIf
					EndIf
					//verfifica se é aprovação por margem ou se foi reprovado por Desconto e Aprovador é Tipo Ambos
					If !lRet 
						//verifica o se o usuário pode liberar margem maior do que o contrato
						//If ( aAprovInfo[nPosPMarg] >= FP0->FP0_PMARGE ) .or. FWIsInCallStack("LOCA013")
						//If ( aAprovInfo[nPosPMarg] <= nNewMargem ) .or. FWIsInCallStack("LOCA013")
							//grava as informações no contrato
							If lGrava
								RecLock("FP0",.F.)
									// Alterado por Frank em 17/11/22
									//FP0->FP0_STATUS := If(lReprova, "4","3")  //If(_NOPC == 1,"3","4")	// 3=APROVADO E 4=REPROVADO
									//FP0->FP0_USUAPR	:= AllTrim(cUserName)
									//FP0->FP0_DTAPRO	:= dDataBase
									//FP0->FP0_HORAPR	:= Time()
									If FP0->(FieldPos("FP0_NIVEL")) > 0
										FP0->FP0_NIVEL := aAprovInfo[nPosNivel]
									EndIf
								FP0->(MsUnlock())
							EndIf
						//Else	
						//	lRet := .F.
						//EndIf
					EndIf

					If !lRet
						//grava as informações no contrato
						If lMsg
							Help(Nil,Nil, "LOCA057_02",Nil, STR0055,1,0,Nil,Nil,Nil,Nil,Nil, {STR0056})	 // "Limite superior à alçada do Aprovador" ###  //"Solicite para um Usuário Aprovador com limite superior aprovar o Ceontrato ou revise os valores do mesmo."
							lRet := .F.		
						EndIf
					EndIf
				Else
					lRet := .F.
					If lMsg
						Help(Nil,Nil, "LOCA057_03",Nil, STR0057,1,0,Nil,Nil,Nil,Nil,Nil, {STR0058})	 // "Usuário sem direitos de Aprovação" #### "Solicite para um Usuário Aprovador realizar este processo."
					EndIf
				EndIf	
			//EndIf
		EndIf
	Else
		lRet := .F.
		If lMsg
			Help(Nil,Nil, "LOCA057_04",Nil, STR0057,1,0,Nil,Nil,Nil,Nil,Nil, {STR0058})	// "Usuário sem direitos de Aprovação" #### "Solicite para um Usuário Aprovador realizar este processo."
		EndIf
	EndIf

	RestArea(aAreaFP0)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA05705

Retorna informações de um usuário aprovador, pelo código do usuário
@type   Function
@author Jose Eulalio
@since 10/11/2022

/*/
//------------------------------------------------------------------------------
Function LOCA05705(cAprovUser)
Local cQryExe		:= ""
Local cAliasExe		:= GetNextAlias()
Local aAprovInfo 	:= {0,0,"","","",.F.}

	//Dados da FPR para aprovação
	/*
	+ __cUserID +
	*/
	cQryExe := " SELECT FPR_NIVEL, FPR_TIPAPR, FPR_PRCDES, FPR_PRCMRG, FPR_MSBLQL  "
	cQryExe += " FROM " + RETSQLNAME("FPR") + " FPR " 
	cQryExe += " WHERE 	FPR_FILIAL = '" + xFilial("FPR") + "' AND " 
	cQryExe += "		D_E_L_E_T_ = '' AND " 
	cQryExe += "		FPR_CODUSR = ? " 

	cQryExe := CHANGEQUERY(cQryExe)
	aBindParam := {__cUserID}
	cAliasExe := MPSysOpenQuery(cQryExe,,,,aBindParam)
	//DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,, cQryExe) , cAliasExe , .T. , .T.) 

	If (cAliasExe)->(!Eof())
		aAprovInfo[1] := (cAliasExe)->FPR_PRCDES 	//Percentual desconto
		aAprovInfo[2] := (cAliasExe)->FPR_PRCMRG 	//Percentual margem
		aAprovInfo[3] := (cAliasExe)->FPR_TIPAPR 	//tipo de aprovação do usuário
		aAprovInfo[4] := (cAliasExe)->FPR_MSBLQL 	//bloqueio de usuário
		aAprovInfo[5] := (cAliasExe)->FPR_NIVEL 	//Nível do aprovador
		aAprovInfo[6] := .T. 						// Existe Aprovador, deixe sempre na última posição e consulte com ATail para garantir
	EndIf

	(cAliasExe)->(dbCloseArea())

Return aAprovInfo


// Recalculo do desconto e da margem de contribuicao
// Frank Fuga em 14/11/22
// cTipo = D (desconto), M (Margem)
Static Function LOCA057R(cTipo)
Local nValor := 0
Local _aArea := GetArea()
Local nTempx16		:= 0 // Frank em 14/11/22
Local nTempx18		:= 0 // Frank em 14/11/22
Local nTempx17  	:= 0 // Frank em 14/11/22
Local nTempx05		:= 0 // Frank em 14/11/22
Local nTempx07		:= 0 // Frank em 14/11/22

	// nTempX17
	FP6->(dbSetOrder(1))
	FP6->(dbSeek(xFilial("FP6")+FP0->FP0_PROJET))
	While !FP6->(Eof()) .and. FP6->FP6_FILIAL == xFilial("FP6") .and. FP6->FP6_PROJET == FP0->FP0_PROJET
		nTempX17 += FP6->FP6_VALOR
		FP6->(dbSkip())
	EndDo

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
	While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == FP0->FP0_PROJET

		// nTempX16
		If FPA->(fieldpos("FPA_QTDPRC")) > 0
			nTempX16 += FPA->FPA_QTDPRC * FPA->FPA_VRHOR
		Else
			nTempX16 += FPA->FPA_VRHOR
		EndIF
		nTempX16 += FPA->FPA_GUIMON
		nTempX16 += FPA->FPA_GUIDES
		nTempX16 += FPA->FPA_VRSEGU

		// nTempX18
		nTempX18 := nTempX16-nTempX17

		// nTempX05
		nTempX05 += FPA->FPA_VLBRUT

		// nTempX07
		nTempX07 += FPA->FPA_VRHOR

		FPA->(dbSkip())
	EndDo

	If cTipo == "M"
		nValor := (nTempX18 / nTempX16) * 100
	Else
		nValor := ((nTempX05 - nTempX07) / nTempX05) * 100
	EndIF

	RestArea(_aArea)
Return nValor


// Preparação do arotina
// Frank Fuga
// 17/11/23 - card 1292
Static Function menudef(aRotina)
	aRotina := {}
	AADD(AROTINA , {STR0008     , "LOCA05701(1)"                , 0 , 4})		// APROVAÇÃO DO PROJETO //"APROVA"
	AADD(AROTINA , {STR0009    , "LOCA05701(2)"                , 0 , 4})		// REPROVAÇÃO DO PROJETO //"REPROVA"
	AADD(AROTINA , {STR0010     , "LOCA05701(3)"                , 0 , 4})		// DETALHES DO PROJETO //"RESUMO"
	AADD(AROTINA , {"VISUALIZAR" , "LOCA00110(TRB->FP0_PROJET)" , 0 , 2})   	// VISUALIZAR PROJETO
Return aRotina
