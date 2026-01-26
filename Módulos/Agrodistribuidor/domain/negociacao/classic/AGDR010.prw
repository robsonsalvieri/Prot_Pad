#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AGDR010.CH"


/** {Protheus.doc} 
Rotina de Integracao com MS-Word - **** CONTRATOS
@param: 	nil 
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Function AGDR010(lShowDlg)
	//Declaracao de arrays para dimensionar tela
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}

	Private oDlg		:= NIL
	Private aInfo		:= {}
	Private nDepen		:= 0
	Private lLinux 		:= IIf( GetRemoteType() == 2 , .T., .F. )
	Private lChangeCase := .F.
	Private cFileSystem := GetSrvProfString("Startpath", "")

	Default lShowDlg := .T.

	AGDR010PAR()

	// OpenProfile()

	//*=================================================================================
	//*	Monta as Dimensoes dos Objetos
	//*=================================================================================
	If lShowDlg
		aAdvSize		:= MsAdvSize()
		aAdvSize[5]		:= (aAdvSize[5]/100) * 60	//horizontal
		aAdvSize[6]		:= (aAdvSize[6]/100) * 40	//Vertical
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }

		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
		aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	//1,3 Vertical /1,4 Horizontal

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL		//"Integração Com Ms-word"

		@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
		@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0003) PIXEL	//"Impressão de documentos no Word."
		@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0004) PIXEL	//"Serão impressos de acordo com a Seleção Dos Parâmetros."

		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-125 BUTTON OemToAnsi(STR0005) SIZE 55,11 ACTION AGDR010PAR(.T.) //Parametros"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60  BUTTON OemToAnsi(STR0006) SIZE 55,11 ACTION AGDR010VAR() //"Impr. Variáveis"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5   BUTTON OemToAnsi(STR0007) SIZE 55,11 ACTION fWord_Imp(NEA->NEA_CODIGO, NEA->NEA_VERSAO)	//"Impr. _Documento"

		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)

		ACTIVATE DIALOG oDlg CENTERED
	Else
		fWord_Imp(NEA->NEA_CODIGO, NEA->NEA_VERSAO)
	Endif

Return( NIL )

/*/{Protheus.doc} AGDR010PAR
Executa o Pergunte definido no Include AGDR010.CH - STR0001
@type function
@version 12
@author jc.maldonado
@since 07/07/2025
@param lShowDlg, logical, mostra janela
/*/
Function AGDR010PAR(lShowDlg)
	Default lShowDlg := .F.

	Pergunte(STR0001, lShowDlg) //"AGDR010"
Return

/** {Protheus.doc} 
Selecionando as pastas dos Arquivos do Word.  
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Function AGDR010FWD(lDir)
	Local cTipo			:= STR0008	//"Modelo de Documentos(*.DOT)  |*.DOT|Modelo de Documentos(*.DOTM) |*.DOTM|Modelo de Documentos(*.DOTX) |*.DOTX|"
	Local cNewPathArq
	local tmp 	   := getTempPath()

	if lDir
		cNewPathArq	:= cGetFile( '' , '', 1, tmp, .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. ) //:= tFileDialog( "",STR0009,, tmp, .F., GETF_RETDIRECTORY) //"Seleção de Arquivos" //cGetFile( cTipo,STR0013,,,,nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD))
		IF !Empty( cNewPathArq )
			cNewPathArq := STRTRAN(cNewPathArq, "\\", "\")
			IF Len( cNewPathArq ) > 50
				AGDHELP(STR0022, STR0010, STRTRAN(STR0027, "*", "50") ) //"Atenção!"#"O caminho de destino para salvar o ficheiro do Word excedeu o limite de 50 caracteres" # "Informe o caminho que seja inferior a # caracteres"
				Return
			Else
				mv_par02 := cNewPathArq
			endif

		Else
			AGDHELP(STR0011, STR0026,  STR0012 ) //"Cancelada a Seleção!"#"Destino não selecionado"#"Selecione o destino para salvar o ficheiro do Word."
			Return
		EndIF
	else
		cNewPathArq	:= cGetFile( cTipo, STR0013,,,,nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD)) //"Selecione o ficheiro *.DOT, *.DOTM ou *.DOTX"
		IF !Empty( cNewPathArq )
			IF Len( cNewPathArq ) > 80
				AGDHELP(STR0011, STR0014, STRTRAN(STR0027, "*", "80") ) //"Cancelada a Seleção!" # "A localização completa do lugar onde está o ficheiro do Word excedeu o limite de 80 caracteres."# "Informe o caminho que seja inferior a # caracteres"
				Return
			Else
				mv_par01 := cNewPathArq
			endif
		Else
			AGDHELP(STR0011, STR0025, STR0013 ) // "Cancelada a Seleção!" # "Arquivo modelo não selecionado" # "Selecione o ficheiro *.DOT, *.DOTM ou *.DOTX"
			Return
		EndIF

	endif

Return(.T.)

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Function AGDR010VAR()
	/*Define Variaveis Locais */
	Local cString		:= 'NEA'
	Local aOrd			:= {STR0015,STR0016}	//"Variável"#"Descrição Da Variável"

	/*Define Variaveis Privates Basicas*/
	Private NomeProg	:= STR0001
	Private AT_PRG		:= NomeProg
	Private aReturn		:= {"Código de barras", 1,"Administração", 2, 2, 1, '',1 }
	Private cDesc1		:= STR0017	//"Relatório Das Variáveis AGD_word."
	Private cDesc2		:= STR0018	//"Sera impresso de acordo com os parâmetro s solicitados pelo"
	Private cDesc3		:= STR0019	//"Utilizador."
	Private wCabec0		:= 1
	Private wCabec1		:= STR0020	//"Variáveis                      Descrição"
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1
	Private cBtxt		:= ""
	Private aLinha		:= {}
	Private nLastKey	:= 0
	Private lEnd		:= .F.

	/*Envia controle para a funcao SETPRINT*/
	WnRel := STR0021
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	SetDefault(aReturn,cString)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	/*Chamada do Relatorio. */
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fImpVar()

	Local nOrdem		:= aReturn[8]
	Local aCampos		:= {}
	Local aInsumos		:= {}
	Local aContratos	:= {}
	Local nX			:= 0
	Local cDescr		:= ""
	Local nTam			:= 0

	/*Carregando Variaveis*/
	aCampos		:= fCpos_Word()
	aInsumos 	:= fGrid_Insumo_Word()
	aContratos	:= fGrid_Contrato_Word()

	/*Ordena aCampos de Acordo com a Ordem Selecionada*/        
	IF nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIF

	//adicionando campos de insumos as variaveis
	nTam = len(aCampos)
	asize(aCampos, nTam + len(aInsumos) )
	acopy(aInsumos, aCampos, 1, len(aInsumos), nTam + 1)

	//adicionando campos de contratos as variaveis
	nTam = len(aCampos)
	asize(aCampos, nTam + len(aContratos) )
	acopy(aContratos, aCampos, 1, len(aContratos), nTam + 1)

	/*Carrega Regua de Processamento*/        
	SetRegua( Len( aCampos ) )

	/*Impressao do Relatorio*/        
	For nX := 1 To Len( aCampos )

        /*Movimenta Regua Processamento*/        
		IncRegua()

        /*Cancela Impressao*/
		// IF lEnd
		// 	@ Prow()+1,0 PSAY cCancel
		// 	Exit
		// EndIF

		/*Carregando Variavel de Impressao*/
		cDescr := AllTrim( aCampos[nX,4] )

      	/*Imprimindo Relatorio*/
		Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )

		If Len(cDescr) > 50
			Impr( Space(31) + SubStr(cDescr,51,50) )
		Endif

		If Len(cDescr) > 100
			Impr( Space(31) + SubStr(cDescr,101,50) )
		Endif

	Next nX

	IF aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIF

	MS_FLUSH()

Return( NIL )

/** {Protheus.doc} 
Impressao do Documento Word   
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fWord_Imp(cBarter, cVersao)

	Local oWord		:= NIL
	Local cNomeAq 	:= ""

	/*PARAMETROS*/
	Local cArqWord 	:= mv_par01		//local do arquivo
	Local cDestino 	:= mv_par02		//local destino do arquivo

	// *Checa o SO do Remote (1=Windows, 2=Linux)
	// If GetRemoteType() == 2
	// 	AGDHELP(STR0022, STR0023, "" ) //#"Atenção !"#"A integração word funciona somente com windows!!!"
	// 	Return
	// EndIf

	If Empty(cArqWord)
		AGDHELP(STR0022, STR0013, "" ) //"Atenção"#"Selecione o ficheiro *.DOT, *.DOTM ou *.DOTX"
		Return
	EndIf

	If Empty(cDestino)
		AGDHELP(STR0022, STR0012, "" ) //"Atenção"#"Selecione o destino para salvar o ficheiro do Word."
		Return
	EndIf



	dbSelectArea('NEA')
	dbSetOrder(1)
	If dbSeek(xFilial('NEA')+cBarter+cVersao)

		cNomeAq := "BARTER_"+ AllTrim(cBarter+cVersao) +".docx"

		// *Checa o SO do Remote (1=Windows, 2=Linux)
		if lLinux
			IF ".odt" $ LOWER(cArqWord)
				fWord_Xml(cBarter, cVersao)
				RETURN
			ENDIF
		endif
		// *CONECTA COM WORD
		oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
		/*Carrega Campos Disponiveis para Edicao*/
		aCampos := fCpos_Word()

		/*Ajustando as Variaveis do Documento*/
		Aeval( aCampos,;
			{ |x| OLE_SetDocumentVar( oWord, x[1], IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
			Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
			Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
			Transform( x[2] , x[3] )));
			})

		//MACRO DE INSUMOS
		If mv_par03 == 1 //SIM
			fNEBMacro(oWord)
		EndIf

		//MACRO DE CONTRATOS
		If mv_par04 == 1 //SIM
			fNEEMacro(oWord)
		EndIf

		/*Atualiza as Variaveis*/
		OLE_UpDateFields( oWord )

		/*Imprimindo o Documento */
		OLE_SetProperty( oWord, '208', .F. )

		OLE_SaveAsFile( oWord, Alltrim(cDestino)+Alltrim(cNomeAq) )

		/*Encerrando o Link com o Documento*/
		OLE_CloseLink(oWord)

		//ABRE WORD
		ShellExecute( "Open", Alltrim(cDestino)+Alltrim(cNomeAq), " "," ", 1 )
	Else
		AGDHELP(STR0022, STR0024, "" ) //"Atencao"#"Não foi possivel imprimir o arquivo!"
	EndIf

	If oDlg != Nil
		oDlg:End()
	Endif

Return

/** {Protheus.doc} 
Variaveis disponiveis para dados de Negociacao (NEA)  
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fCpos_Word()
	Local aExp	:= {}

	Local cNomeVendedor := Alltrim(Posicione("SA3",1,xFilial("SA3")+NEA->NEA_CVEND1,"A3_NOME"))
	Local cCGC			:= ""
	Local cNomeCliente 	:= ""
	Local cEndCliente 	:= ""
	Local cTelCliente	:= ""
	Local cEmpresa		:= ""
	Local aFrete		:= x3CboxToArray("NEA_TPFRET")
	Local cFrete		:= ""
	Local cMoeda		:= ""
	Local nPos			:= 0
	Local cCondPG 		:= Alltrim(Posicione("SE4",1,xFilial("SE4")+NEA->NEA_CONDPG,"E4_DESCRI"))


	aAreaSA1 := SA1->(GetArea())
	Dbselectarea("SA1")
	SA1->(Dbseek(xFilial("SA1")+NEA->NEA_CODCLI+NEA->NEA_LOJCLI))

	IF SA1->A1_PESSOA  == "F"
		cCGC := Transform(Alltrim(SA1->A1_CGC), "@R 999.999.999-99")
	ELSEIF SA1->A1_PESSOA == "J"
		cCGC := Transform(Alltrim(SA1->A1_CGC), "@R! NN.NNN.NNN/NNNN-99")
	ELSE
		cCGC := Transform(SA1->A1_CGC,PesqPict("SA1","A1_CGC"))
	ENDIF

	cNomeCliente 	:= Alltrim(SA1->A1_NOME)
	cEndCliente 	:= Alltrim(SA1->A1_END)
	cTelCliente		:= SA1->A1_TEL
	cInscCliente	:= SA1->A1_INSCR

	RestArea(aAreaSA1)

	//Busca dados da empresa
	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	If (SM0->(DbSeek( cEmpAnt + XFILIAL("NEA"))))
		cEmpresa := AllTrim(SM0->M0_NOMECOM)
	ENDIF

	cMoeda := AllTrim( Str( NEA->NEA_MOEDRT )) + " - " + Alltrim(SuperGetMv( 'MV_MOEDA' + AllTrim( Str( NEA->NEA_MOEDRT ) ) ))

	//recuperando string de combobox
	nPos	:= aScan(aFrete[2],{|x|x == NEA->NEA_TPFRET})
	cFrete 	:= aFrete[1][nPos]

	cCondPG := IIF( !Empty(NEA->NEA_CONDPG) , NEA->NEA_CONDPG + " - "+ cCondPG, "")

	aAdd(aExp, {'AGD_FILIAL', 			NEA->NEA_FILIAL, 		GetSx3Cache("NEA_FILIAL", "X3_PICTURE"),	GetSx3Cache("NEA_FILIAL", "X3_TITULO") })
	aAdd(aExp, {"AGD_NEGOCIACAO", 		NEA->NEA_CODIGO, 		GetSx3Cache("NEA_CODIGO", "X3_PICTURE"),	GetSx3Cache("NEA_CODIGO", "X3_TITULO") })
	aAdd(aExp, {"AGD_EMISSAO",  		DTOC(NEA->NEA_EMISSA),  ""									   ,	GetSx3Cache("NEA_EMISSA", "X3_TITULO") })
	aAdd(aExp, {"AGD_COD_VENDEDOR", 	isNull(NEA->NEA_CVEND1),GetSx3Cache("NEA_CVEND1", "X3_PICTURE"),	GetSx3Cache("NEA_CVEND1", "X3_TITULO") })
	aAdd(aExp, {"AGD_NOME_VENDEDOR",	isNull(cNomeVendedor),	""									   ,	GetSx3Cache("A3_NOME"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_COD_CLIENTE", 		NEA->NEA_CODCLI,  		GetSx3Cache("NEA_CODCLI", "X3_PICTURE"),	GetSx3Cache("NEA_CODCLI", "X3_TITULO") })
	aAdd(aExp, {"AGD_LOJA_CLIENTE", 	NEA->NEA_LOJCLI,  		GetSx3Cache("NEA_LOJCLI", "X3_PICTURE"),	GetSx3Cache("NEA_LOJCLI", "X3_TITULO") })
	aAdd(aExp, {"AGD_NOME_CLIENTE", 	cNomeCliente,  			GetSx3Cache("A1_NOME"	, "X3_PICTURE"),	GetSx3Cache("A1_NOME"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_NOME_EMPRESA", 	cEmpresa,			  	""									   ,	"Empresa" 							   })
	aAdd(aExp, {"AGD_END_CLIENTE", 		isNull(cEndCliente),	GetSx3Cache("A1_END"	, "X3_PICTURE"),	GetSx3Cache("A1_END"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_CGC_CLIENTE", 		isNull(cCGC) ,			""									   ,	GetSx3Cache("A1_CGC"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_TEL_CLIENTE", 		isNull(cTelCliente),	""									   ,	GetSx3Cache("A1_TEL"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_IE_CLIENTE", 		isNull(cInscCliente),	GetSx3Cache("A1_INSCR"	, "X3_PICTURE"),	GetSx3Cache("A1_INSCR"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_SAFRA", 			isNull(NEA->NEA_CODSAF),GetSx3Cache("NEA_CODSAF", "X3_PICTURE"),	GetSx3Cache("NEA_CODSAF", "X3_TITULO") })
	aAdd(aExp, {"AGD_COD_PRODUTO", 		isNull(NEA->NEA_CODPRO),GetSx3Cache("NEA_CODPRO", "X3_PICTURE"),	GetSx3Cache("NEA_CODPRO", "X3_TITULO") })
	aAdd(aExp, {"AGD_UM_PRECO", 		isNull(NEA->NEA_UMPRC),	""									   ,	GetSx3Cache("NEA_UMPRC" , "X3_TITULO") })
	aAdd(aExp, {"AGD_CULTURA", 			isNull(NEA->NEA_CULTRA),GetSx3Cache("NEA_CULTRA", "X3_PICTURE"),	GetSx3Cache("NEA_CULTRA", "X3_TITULO") })
	aAdd(aExp, {"AGD_MOEDA", 			isNull(cMoeda),			""									   ,	GetSx3Cache("NEA_MOEDRT", "X3_TITULO") })
	aAdd(aExp, {"AGD_COTACAO_MOEDA", 	NEA->NEA_TXMOED,  		GetSx3Cache("NEA_TXMOED", "X3_PICTURE"),	GetSx3Cache("NEA_TXMOED", "X3_TITULO") })
	aAdd(aExp, {"AGD_DATA_COTACAO", 	DTOC(NEA->NEA_DTMOED),	""									   ,	GetSx3Cache("NEA_DTMOED", "X3_TITULO") })
	aAdd(aExp, {"AGD_VALOR_RT", 		NEA->NEA_VLRRT,  		GetSx3Cache("NEA_VLRRT"	, "X3_PICTURE"),	GetSx3Cache("NEA_VLRRT"	, "X3_TITULO") })
	aAdd(aExp, {"AGD_IMPOSTO", 			NEA->NEA_IMPOST, 		GetSx3Cache("NEA_IMPOST", "X3_PICTURE"),	GetSx3Cache("NEA_IMPOST", "X3_TITULO") })
	aAdd(aExp, {"AGD_RT_LIQUIDO", 		NEA->NEA_VLRRTL,  		GetSx3Cache("NEA_VLRRTL", "X3_PICTURE"),	GetSx3Cache("NEA_VLRRTL", "X3_TITULO") })
	aAdd(aExp, {"AGD_FRETE", 			isNull(cFrete),			""									   ,	GetSx3Cache("NEA_TPFRET", "X3_TITULO") })
	aAdd(aExp, {"AGD_COND_PAGTO", 		isNull(cCondPG),		""									   ,	GetSx3Cache("NEA_CONDPG", "X3_TITULO") })
	aAdd(aExp, {"AGD_QTD_NEGOCIADA", 	NEA->NEA_QTTNEG,  		GetSx3Cache("NEA_QTTNEG", "X3_PICTURE"),	GetSx3Cache("NEA_QTTNEG", "X3_TITULO") })

	//P.E para manipular dados de negociacao
	If ExistBlock("AGDR010N")
		aExp := ExecBlock("AGDR010N",.F.,.F.,{aExp})
	EndIf

Return( aExp )


/** {Protheus.doc} 
Variaveis disponiveis para Grid de Insumos (NEB) 
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fGrid_Insumo_Word()

	Local aExp			:= {}
	Local cDescricao 	:= ""

	aExp 		:= {}
	cDescricao 	:= Alltrim(Posicione("SB1",1,xFilial("SB1")+ALLTRIM(NEB->NEB_CODPRO),"B1_DESC"))

	aAdd(aExp, {"AGD_INSUMO_PRODUTO"	,	ALLTRIM(NEB->NEB_CODPRO),	GetSx3Cache("NEB_CODPRO", "X3_PICTURE")	,	GetSx3Cache("NEB_CODPRO", "X3_TITULO") 	})
	aAdd(aExp, {"AGD_INSUMO_DESCRICAO"	,	cDescricao				,	""										,	GetSx3Cache("B1_DESC", "X3_TITULO") 	})
	aAdd(aExp, {"AGD_INSUMO_UM"			,	NEB->NEB_UM				,	""										,	GetSx3Cache("NEB_UM", "X3_TITULO") 		})
	aAdd(aExp, {"AGD_INSUMO_QUANT"		, 	NEB->NEB_QTDVEN			,	GetSx3Cache("NEB_QTDVEN", "X3_PICTURE")	,	GetSx3Cache("NEB_QTDVEN", "X3_TITULO") 	})

	//P.E para manipular dados de insumos
	If ExistBlock("AGDR010I")
		aExp := ExecBlock("AGDR010I",.F.,.F.,{aExp})
	EndIf

Return( aExp )

/** {Protheus.doc} 
Variaveis disponiveis para Grid de Contratos (NEE) 
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fGrid_Contrato_Word()
	Local aExp	:= {}

	aAdd(aExp, {"AGD_CONTRATO_PROPRIEDADE"	,	ALLTRIM(NEE->NEE_CDPROP),	GetSx3Cache("NEE_CDPROP", "X3_PICTURE")	,	GetSx3Cache("NEE_CDPROP", "X3_TITULO") 	})
	aAdd(aExp, {"AGD_CONTRATO_NOME"			,	ALLTRIM(NEE->NEE_NMPROP),	GetSx3Cache("NEE_NMPROP", "X3_PICTURE")	,	GetSx3Cache("NEE_NMPROP", "X3_TITULO") 	})
	aAdd(aExp, {"AGD_CONTRATO_QUANT"		, 	NEE->NEE_QTDSAC			,	GetSx3Cache("NEE_QTDSAC", "X3_PICTURE")	,	GetSx3Cache("NEE_QTDSAC", "X3_TITULO") 	})

	//P.E para manipular dados de contratos
	If ExistBlock("AGDR010C")
		aExp := ExecBlock("AGDR010C",.F.,.F.,{aExp})
	EndIf

Return( aExp )

/** {Protheus.doc} fNEBMacro
Macro Word - Tabela NEB - Dados de Insumos
@param: 	oWord
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fNEBMacro(oWord)

	Local aItens	:= {}
	Local aInsumos	:= {}
	Local cCampos	:= ""
	Local nItem		:= 0

	dbSelectArea('NEB')
	NEB->(DBGoTop())
	dbSetOrder(1)
	IF NEB->(dbSeek(xFilial('NEB')+NEA->NEA_CODIGO+NEA->NEA_VERSAO))
		nItem		:= 0
		While NEB->(!EoF()) .and. (xFilial('NEB')+NEA->NEA_CODIGO+NEA->NEA_VERSAO == NEB->(NEB_FILIAL+NEB_CODBRT+NEB_VERSAO))
			nItem++
			aInsumos	:= fGrid_Insumo_Word()
			cCampos 	:= ""

			//GERAR COLUNAS DINAMICAS PARA MACRO
			AEval( aInsumos, { |x| cCampos += x[1] + "," } )
			cCampos := SubStr(cCampos,1, LEN(cCampos) -1)
			OLE_SetDocumentVar(oWord,"AGD_INSUMOS", cCampos)

			/*Ajustando as Variaveis do Documento*/
			Aeval( aInsumos,;
				{ |x| OLE_SetDocumentVar( oWord, x[1] + Alltrim(str(nItem)), IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
				Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
				Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
				Transform( x[2] , x[3] )));
				})

			NEB->(DBSkip())
		endDo

		if nItem > 0
			OLE_SetDocumentVar(oWord,"AGD_ITENS_INSUMOS", nItem )
			OLE_ExecuteMacro(oWord,"AddItemInsumos")
		endif

	ENDIF


Return aItens


/** {Protheus.doc} fNEEMacro
Macro Word - Tabela NEE - Dados de Contratos
@param: 	oWord
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
Static Function fNEEMacro(oWord)

	Local aItens		:= {}
	Local aContratos	:= {}
	Local cCampos		:= ""
	Local nItem			:= 0

	dbSelectArea( 'NEE' )
	NEE->(DBGoTop())
	dbSetOrder(1)
	IF NEE->(dbSeek(xFilial( 'NEE' )+NEA->NEA_CODIGO+NEA->NEA_VERSAO))
		nItem	:= 0
		While NEE->(!EoF()) .and. (xFilial( 'NEE' )+NEA->NEA_CODIGO+NEA->NEA_VERSAO == NEE->(NEE_FILIAL+NEE_CODBRT+NEE_VERSAO))
			nItem++
			aContratos	:= fGrid_Contrato_Word()
			cCampos		:= ""

			//GERAR COLUNAS DINAMICAS PARA MACRO
			AEval( aContratos, {|x| cCampos += x[1] + ","} )
			cCampos	:= SubStr(cCampos,1, LEN(cCampos) -1)
			OLE_SetDocumentVar(oWord,"AGD_CONTRATOS", cCampos)

			/*Ajustando as Variaveis do Documento*/
			Aeval( aContratos,;
				{ |x| OLE_SetDocumentVar( oWord, x[1] + Alltrim(str(nItem)), IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
				Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
				Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
				Transform( x[2] , x[3] )));
				})

			NEE->(DBSkip())
		endDo

		if nItem > 0
			OLE_SetDocumentVar(oWord,"AGD_ITENS_CONTRATOS", nItem )
			OLE_ExecuteMacro(oWord,"AddItemContratos")
		endif

	ENDIF

Return aItens



/** {Protheus.doc} 
Impressao do Documento ODT para ambientes LINUX   
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/04/2025
@Uso: 		SIGAAGD
*/ 
Static Function fWord_Xml(cBarter, cVersao)

	Local cArqWord 		:= alltrim(mv_par01)	//local do arquivo
	Local cDestino 		:= alltrim(mv_par02)	//local destino do arquivo
	Local cConteudo 	:= ""
	Local aCampos		:= {}
	Local cNomeAq 		:= "BARTER_"+ AllTrim(cBarter+cVersao) +".odt"
	Local _cFile
	Local _newFile		:= ""
	Local _cFolder		:= "NEGOCIACAO_" + cBarter+cVersao
	Local nResult
	Local lChangeCase 	:= .F.
	Local aFileList		:= {}
	Local aInsumos		:= {}
	Local aContratos	:= {}
	Local cReplace		:= ""
	Local lSucess		:= .F.

	cFileSystem := IF( IsSrvUNIX(), StrTran(cFileSystem, '\', '/'), cFileSystem)

	if lLinux

		If File(cDestino + cNomeAq,,lChangeCase)
			FErase(cDestino + cNomeAq,,lChangeCase)
		Endif

		_cFile := AllTrim(SubStr(cArqWord,RAT('\',cArqWord)+1,100))
		//COPIANDO ARQUIVO PARA TRATAMENTO NO SERVIDOR
		lSucess := CpyT2S(cArqWord, cFileSystem,.F., lChangeCase)
		if lSucess

			cArqWord 	:= cFileSystem + _cFile
			_newFile	:= cFileSystem + STRTRAN(_cFile, "odt", "zip")

			nResult := FRename(cArqWord, _newFile ,nil, lChangeCase )
			//Se foi renomeado com sucesso
			If nResult == 0
				If ! ExistDir(cFileSystem + _cFolder)
					MakeDir(cFileSystem + _cFolder, , lChangeCase)
				endif
				nResult := FUnZip( _newFile , cFileSystem + _cFolder,nil, lChangeCase)
				if nResult == 0
					cArqWord := cFileSystem + _cFolder +"\content.xml"
					//LIMPANDO ARQUIVO DO SERVIDOR
					If File(_newFile,,lChangeCase)
						FErase(_newFile,,lChangeCase)
					Endif
				endif
			EndIf

		endif

		If File(cArqWord,,lChangeCase)

			cConteudo := fMemoRead(cArqWord)
			aCampos := fCpos_Word()

			Aeval( aCampos,;
				{ |x| cConteudo := StrTran(  cConteudo, x[1], IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
				Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
				Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
				Transform( x[2] , x[3] )));
				})

			//MACRO DE INSUMOS
			If mv_par03 == 1 //SIM

				dbSelectArea('NEB')
				NEB->(DBGoTop())
				dbSetOrder(1)
				IF NEB->(dbSeek(xFilial('NEB')+NEA->NEA_CODIGO+NEA->NEA_VERSAO))
					cLinhaItem		:= ""
					While NEB->(!EoF()) .and. (xFilial('NEB')+NEA->NEA_CODIGO+NEA->NEA_VERSAO == NEB->(NEB_FILIAL+NEB_CODBRT+NEB_VERSAO))
						aInsumos	:= fGrid_Insumo_Word()
						cReplace 	:= getInsumo()

					/*Ajustando as Variaveis do Documento*/
						Aeval( aInsumos,;
							{ |x| cReplace := StrTran(cReplace, x[1], IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
							Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
							Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
							Transform( x[2] , x[3] )));
							})

						cLinhaItem += cReplace
						cReplace := ""
						NEB->(DBSkip())
					endDo

					if !Empty(cLinhaItem)
						// Substitui o placeholder da tabela de itens
						cConteudo := StrTran(cConteudo, getInsumo(), cLinhaItem)
					endif

				ENDIF

			EndIf

			//MACRO DE CONTRATOS
			If mv_par04 == 1 //SIM

				dbSelectArea( 'NEE' )
				NEE->(DBGoTop())
				dbSetOrder(1)
				IF NEE->(dbSeek(xFilial( 'NEE' )+NEA->NEA_CODIGO+NEA->NEA_VERSAO))
					cLinhaItem		:= ""
					While NEE->(!EoF()) .and. (xFilial( 'NEE' )+NEA->NEA_CODIGO+NEA->NEA_VERSAO == NEE->(NEE_FILIAL+NEE_CODBRT+NEE_VERSAO))

						aContratos	:= fGrid_Contrato_Word()
						cReplace := getContrato()

					/*Ajustando as Variaveis do Documento*/
						Aeval( aContratos,;
							{ |x| cReplace := StrTran(cReplace, x[1], IF( Subst( AllTrim( x[3] ) , 4 , 2 ) == "->" ,;
							Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ) ,;
							Subst( AllTrim( x[3] ) , - ( Len( AllTrim( x[3] ) ) - 5 )))) ,;
							Transform( x[2] , x[3] )));
							})

						cLinhaItem += cReplace
						cReplace := ""

						NEE->(DBSkip())
					endDo

					if !Empty(cLinhaItem)
						// Substitui o placeholder da tabela de itens
						cConteudo := StrTran(cConteudo, getContrato(), cLinhaItem)
					endif

				ENDIF
			EndIf

			MemoWrite(cArqWord, cConteudo)

			cArqWord 	:= cFileSystem + STRTRAN(cNomeAq, "odt", "zip")
			_newFile	:= cFileSystem + STRTRAN(cNomeAq, "zip", "odt")
			//GERANDO ARRAY DE ARQUIVO PARA COMPACTACAO
			ListDir(cFileSystem + _cFolder, @aFileList, .F.)
			nResult := FZip( cArqWord , aFileList, cFileSystem + _cFolder,,lChangeCase)
			if nResult == 0
				nResult := FRename(cArqWord, _newFile ,nil, lChangeCase )
				If nResult == 0
					//COPIANDO ARQUIVO NOVAMENTE PARA O CLIENT
					lSucess := CpyS2T(cFileSystem + cNomeAq, cDestino,.F., lChangeCase)
					if lSucess
						//limpa arquivo gerado no servidor
						If File(cFileSystem + cNomeAq,,lChangeCase)
							FErase(cFileSystem + cNomeAq,,lChangeCase)
						Endif
						cArqWord := _newFile
						FWAlertSuccess(STRTRAN(STR0028, "*", cDestino + cNomeAq)) //#Arquivo: * criado com sucesso!
						shellExecute( "Open", "/usr/lib/libreoffice/program/swriter", cNomeAq, StrTran(cDestino, "l:", ''), 1 )
					endif
				endif

			endif
			// REMOVENDO ARQUIVOS E DIRETORIOS
			ListDir(cFileSystem + _cFolder, @aFileList, .T.)
			DirRemove(cFileSystem + _cFolder,,lChangeCase)


		endif
	EndIF
return

/** {Protheus.doc} 
Funcao para replace de Insumos do arquivo modelo
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	28/04/2025
@Uso: 		SIGAAGD
*/ 
static function getInsumo()
	//layout odt de tabela
	Local cItem := '<table:table-row><table:table-cell table:style-name="Table1.A2" office:value-type="string"><text:p text:style-name="P6">AGD_INSUMO_PRODUTO</text:p></table:table-cell><table:table-cell table:style-name="Table1.A2" office:value-type="string"><text:p text:style-name="P6">AGD_INSUMO_DESCRICAO</text:p></table:table-cell><table:table-cell table:style-name="Table1.A2" office:value-type="string"><text:p text:style-name="P7">AGD_INSUMO_UM</text:p></table:table-cell><table:table-cell table:style-name="Table1.D2" office:value-type="string"><text:p text:style-name="P8">AGD_INSUMO_QUANT</text:p></table:table-cell></table:table-row>'

return cItem

/** {Protheus.doc} 
Funcao para replace de Contrato do arquivo modelo
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	28/04/2025
@Uso: 		SIGAAGD
*/ 
static function getContrato()
	//layout odt de tabela
	Local cItem := '<table:table-row><table:table-cell table:style-name="Table2.A2" office:value-type="string"><text:p text:style-name="P9">AGD_CONTRATO_PROPRIEDADE</text:p></table:table-cell><table:table-cell table:style-name="Table2.A2" office:value-type="string"><text:p text:style-name="P9">AGD_CONTRATO_NOME</text:p></table:table-cell><table:table-cell table:style-name="Table2.C2" office:value-type="string"><text:p text:style-name="P10">AGD_CONTRATO_QUANT</text:p></table:table-cell></table:table-row>'
return cItem

/** {Protheus.doc} 
Funcao para leitura do arquivo XML
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	28/04/2025
@Uso: 		SIGAAGD
*/ 
Static Function fMemoRead(cArquivo)
	Local cConteudo := ""
	Local oFile := FWFileReader():New(cArquivo)
	Local aLinhas
	Local cLinAtu

	//Se o arquivo pode ser aberto
	If (oFile:Open())

		//Se não for fim do arquivo
		If ! (oFile:EoF())
			//Definindo o tamanho da régua
			aLinhas := oFile:GetAllLines()
			ProcRegua(Len(aLinhas))

			//Método GoTop não funciona, deve fechar e abrir novamente o arquivo
			oFile:Close()
			oFile := FWFileReader():New(cArquivo)
			oFile:Open()

			//Enquanto houver linhas a serem lidas
			While (oFile:HasLine())
				//Buscando o texto da linha atual
				cLinAtu := oFile:GetLine()
				cConteudo += cLinAtu
			EndDo
		EndIf

		//Fecha o arquivo e finaliza o processamento
		oFile:Close()
	EndIf

Return cConteudo


/** {Protheus.doc} 
Funcao para substituicao em caso de campo vazio
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	24/03/2025
@Uso: 		SIGAAGD
*/ 
static function isNull(cCampo)

	Local cRet := "-"
	if !Empty(cCampo)
		cRet := cCampo
	endif

return cRet

/** {Protheus.doc} 
Funcao para listar/deletar arquivos 
@param: 	Nil
@author: 	lindembergson.pacheco
@since: 	28/04/2025
@Uso: 		SIGAAGD
*/ 
Static Function ListDir(cPath, aArquivos, lDel)
	Local cFile := ""
	Local cPathFull := ""
	Local aFiles := Directory( cPath + "\*.*" ,"D",,lChangeCase)
	Local nI

	For nI := 1 To Len(aFiles)
		cFile := aFiles[nI][1]

		If cFile == "." .Or. cFile == ".."
			Loop
		EndIf

		cPathFull := cPath + "\" + cFile

		If aFiles[nI][5] == "D" // Se for diretório
			// Chama a função recursivamente
			ListDir(cPathFull, aArquivos, lDel)
			if lDel
				//REMOVENDO DIRETORIO
				DirRemove(cPathFull,,lChangeCase)
			endif
		Else
			if lDel
				//REMOVENDO ARQUIVOS
				If File(cPathFull,,lChangeCase)
					FErase(cPathFull,,lChangeCase)
				Endif
			else
				AAdd(aArquivos, cPathFull)
			endif
		EndIf
	Next
Return
