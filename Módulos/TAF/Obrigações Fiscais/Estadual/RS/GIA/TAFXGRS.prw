#Include 'Protheus.ch'
#Include "ApWizard.ch"

#Define cObrig "GIA-RS"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGRS

Esta rotina tem como objetivo a geracao do Arquivo GIA-RS

@Author marcos.vecki
@Since 21/04/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGRS()
Local cNomWiz    := cObrig + FWGETCODFILIAL
Local lEnd       := .F.

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess := Nil
Private aWizard	:= {}

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

   //Cria objeto de controle do processamento
   oProcess := TAFProgress():New( { |lEnd| ProcGIARS( @lEnd, @oProcess, cNomWiz ) }, "Processando GIA-RS" )
   oProcess:Activate()

   //Limpando a memória
   DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcGIARS

Inicia o processamento para geracao da GIA-RS


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
		oProcess  -> Objeto da barra de progresso da emissao da GIA-RS
		cNomWiz   -> Nome da Wizard criada para a GIA


@Return ( Nil )

@Author marcos.vecki
@Since 25/07/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------


Static Function ProcGIARS( lEnd, oProcess, cNomWiz )

Local cCabecalho 	as Char
Local cDatIni		as Char
Local cDatFim	 	as Char
Local cErrorGIA	 	as char
Local cErrorTrd	 	as char
Local cNatOper    	as Char
Local Codigo  		as Char
Local Nome			as Char
Local CodMun  		as Char
Local CNAE    		as Char
Local InscEst 		as Char
Local cUF     		as Char
Local cUFID 		as Char
Local cTpReg        as Char

Local nI			as Numeric
Local nX			as Numeric
Local nPos			as Numeric
Local nProgress1	as Numeric
Local nValor   		as Numeric
Local nC	 		as Numeric
Local nL			as Numeric

Local aRegGIA		as Array
Local aContab		as Array
Local aJobAux		as Array
Local aFiliais		as Array

Local oTbTemp       as Object

Local lProc			as Logical

//Variáveis de Thread
Local cSemaphore	as Char
Local cJobAux    	as Char
Local nQtdThread	as Numeric
Local lMultThread	as Logical

Private aFil 		as Array
Private nSeqGiaRS	as Numeric
Private cAliasCFOP	as Char
Private aTotAnexo	as Array

//**********************
// INICIALIZA VARIÁVEIS
//**********************
cCabecalho	:= ""
cErrorGIA	:= ""
cErrorTrd	:= ""
cNatOper    := ""
Codigo  	:= ""
Nome		:= ""
CodMun  	:= ""
CNAE    	:= ""
InscEst 	:= ""
cUF     	:= ""
cUFID 		:= ""
cTpReg      := ""
cAliasCFOP 	:= ""

nSeqGiaRS 	:= 1
nI			:= 0
nX			:= 0
nPos		:= 0
nProgress1	:= 0
nValor   	:= 0
nC			:= 0
nL 			:= 0

aRegGIA		:= {}
aContab		:= {}
aJobAux		:= {}
aFiliais	:= {}
aFil		:= {}
aTotAnexo	:= {}

lProc		:= .T.

//Variáveis de Thread
cJobAux    	:= ""
cSemaphore	:= ""
nQtdThread	:= 0
lMultThread	:= .F.

//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

//*****************************
//MONTA PERIODO INICIAL / FINAL
cDatIni := cValToChar(aWizard[1,4]) + SubStr(aWizard[1,3],1,2) + "01"
cDatFim := cValToChar(aWizard[1,4]) + SubStr(aWizard[1,3],1,2) + cValToChar(Day(LastDay(CTOD(SubStr(cDatIni,7,2)+"/"+SubStr(cDatIni,5,2)+"/"+SubStr(cDatIni,1,4)))))

DBSELECTAREA("C09")

//Verificação das filiais selecionadas para processamento da operação
If "1" $ aWizard[1,10]
  	aFiliais := xFunTelaFil( .T. )
	If Empty( aFiliais )
		lProc := .F.
	Else
		If Len( aFiliais ) > 0
          For nI := 1 to Len( aFiliais )
				If aFiliais[nI][1]
					cCodigo := aFiliais[nI][2]
					cNome	:= Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_FILIAL")
					cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CODMUN")
					cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CNAE")
					cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_INSC")
					cUF     := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_ESTCOB")
					cTel    := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_TEL")
					cCgc    := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CGC")

					C09->(DBSETORDER(1))
					If (DBSEEK(xFilial("C09")+cUF))
						cUFID := C09->C09_ID
					Endif

					AADD(aFil,{cCodigo, cNome, cCodMun, cCNAE, cInscEst,cUF, cUFID, cTel, cCgc})
				Endif
			Next
		EndIf
	EndIf
Else
	cNome	:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_FILIAL")
	cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CODMUN")
	cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CNAE")
	cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")
	cUF     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_ESTCOB")
	cTel    := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_TEL")
	cCgc    := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CGC")

	C09->(DBSETORDER(1))
	If (DBSEEK(xFilial("C09")+cUF))
		cUFID := C09->C09_ID
	Endif

	AADD(aFil,{cFilAnt, cNome, cCodMun, cCNAE, cInscEst, cUF, cUFID, cTel, cCgc})
EndIf

If lProc

	Conout( "Tempo de Inicio " + Time() )

	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )
	oProcess:Inc1Progress( "Executando o Processamento...")

	CriaTab( @oTbTemp )
	For nI := 1 To Len(aFil)

		//**********************************************************************
		//*** MONTA CABEÇALHO PARCIAL PARA OS REGISTROS DOS ARQUIVOS GERADOS ***
		//**********************************************************************
		cCabecalho += "****"										//FIXO
		cCabecalho += "08"											//Versão
		cCabecalho += SubStr(cDatIni,7,2)							//Dia Início
		cCabecalho += SubStr(cDatFim,7,2)							//Dia término
		cCabecalho += SubStr(cDatIni,5,2) + SubStr(cDatIni,1,4)		//Referencia - Mês/Ano
		cCabecalho += PADL(Alltrim(aFil[1,5]),10," ") 				//Inscrição Estadual

		//Geração GIA-RS
		TAFGRSOBS(aWizard, aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSCO (aWizard, aFil[nI], cCabecalho)
		TAFGRSA1 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA2 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA4 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA5 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA6 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA7 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA8 (aWizard, aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA14 (aWizard, aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSA16 (aFil[nI], cDatIni, cDatFim, cCabecalho)
		TAFGRSABCE(aWizard, aFil[nI], cDatIni, cDatFim, cCabecalho)
	Next nI
	oTbTemp:Delete( )
Else
	oProcess:Inc1Progress( "Processamento cancelado" )
	oProcess:Inc2Progress( "Clique em Finalizar" )
	oProcess:nCancel = 1

EndIf

//Tratamento para quando o processamento tem problemas
If oProcess:nCancel == 1 .or. !Empty( cErrorGIA ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorGIA := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorGIA, 2, Len( cErrorGIA ) )
		cErrorGIA += "da GIA-RS " + Chr( 10 ) + Chr( 10 )
		cErrorGIA += "Favor efetuar o reprocessamento da GIA-RS, caso o erro persista entre em contato "
		cErrorGIA += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorGIA, { "Sair" } )

	EndIf

Else
	//Tratamento para exibir mensagem no console quando processamento multi thread
	If lMultThread
		Conout( "*** Realizando geração do arquivo magnético ***" )
	EndIf

	//Atualizando a barra de processamento
	oProcess:Inc1Progress( "Informações processadas" )
	oProcess:Inc2Progress( "Consolidando as informações e gerando arquivo..." )


	If GerTxtCons( aWizard )
		Conout( "Tempo Final " + Time() )
		//Atualizando a barra de processamento
		oProcess:Inc2Progress( "Arquivo gerado com sucesso." )
		msginfo("Arquivo gerado com sucesso!")
	Else
		oProcess:Inc2Progress( "Falha na geração do arquivo." )
	EndIf


EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author marcos.vecki
@Since 25/07/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}
// PAINEL-1
	Local	aItens0	:= {}
	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens4	:= {}
	Local	aItens5	:= {}
	Local	aItens6	:= {}
	Local	aItens7	:= {}

	Local	cTitObj1	:= ""
	Local	aRet		:= {}


	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético GIA-RS.")

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 0³
	//ÀÄÄÄÄÄÄÄÄÙ

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas - INFORMAÇÕES DA GIA.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIA-RS.")
	aAdd (aPaineis[nPos], {})


	//Coluna1																//Coluna 2
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1 := "Diretório do Arquivo Destino"
	cTitObj2 := "Nome do Arquivo Destino"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( "X", 50 )
	cTitObj2 := Replicate( "X", 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,,, { "xFunVldWiz", "ECF-DIRETORIO" } } )
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,,,,} )

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Mês Referencia"
	cTitObj2	:=	"Ano Referencia"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	aAdd (aItens1, "01 - Janeiro")
	aAdd (aItens1, "02 - Fevereiro")
	aAdd (aItens1, "03 - Março")
	aAdd (aItens1, "04 - Abril")
	aAdd (aItens1, "05 - Maio")
	aAdd (aItens1, "06 - Junho")
	aAdd (aItens1, "07 - Julho")
	aAdd (aItens1, "08 - Agosto")
	aAdd (aItens1, "09 - Setembro")
	aAdd (aItens1, "10 - Outubro")
	aAdd (aItens1, "11 - Novembro")
	aAdd (aItens1, "12 - Dezembro")

	cTitObj2 :=	"@E 9999"

	aAdd (aPaineis[nPos,3], {3,,,,,aItens1,,,,,})
	aAdd( aPaineis[nPos,3], {2,,cTitObj2,2,0,,,4})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//---------------------------------------------------------------------------------------------------------------
	cTitObj1	:=	"Retificação";							cTitObj2	:=	"Entrega Completa"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens2, "0 - Não");								aAdd (aItens3, "0 - Não")
	aAdd (aItens2, "1 - Sim");								aAdd (aItens3, "1 - Sim")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,});			aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,})

   aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//---------------------------------------------------------------------------------------------------------------
	cTitObj1	:=	"Início de Atividade";					cTitObj2	:=	"Fim de Atividade"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens4, "0 - Não");								aAdd (aItens5, "0 - Não")
	aAdd (aItens4, "1 - Sim");								aAdd (aItens5, "1 - Sim")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,});			aAdd (aPaineis[nPos][3], {3,,,,,aItens5,,,,,})

   aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"CGC/TE Centralizador";					cTitObj2	:=	"Seleciona Filial"
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

															aAdd (aItens0, "0 - Não")
	cTitObj1 := Replicate( "X", 10 );						aAdd (aItens0, "1 - Sim")
	aAdd (aPaineis[nPos,3],  {2,, cTitObj1, 1,,,, 10});		aAdd (aPaineis[nPos][3], {3,,,,,aItens0,,,,,});


	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//---------------------------------------------------------------------------------------------------------------
	cTitObj1	:=	"Transp. Sld. Dev. Prox. Mês";			cTitObj2	:=	"Transportou Sld. Dev. Mês Anterior"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens6, "0 - Não");								aAdd (aItens7, "0 - Não")
	aAdd (aItens6, "1 - Sim");								aAdd (aItens7, "1 - Sim")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens6,,,,,});			aAdd (aPaineis[nPos][3], {3,,,,,aItens7,,,,,})

   aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Observação"
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );			aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1 := Replicate( "X", 150 )
	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 150,,,,,,} )

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//--------------------------------------------------------------------------------------------------------------------------------------------------//

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXGRS() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGRS

Geracao do Arquivo TXT da GIA-RS.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo GIA-RS
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author marcos.vecki
@Since 25/07/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtGRS( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "GIARS" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\GIARS. Erro: " + cValToChar( FError() ) , 1, 0 )

		lRet	:=	.F.

	endIf

endIf

if lRet

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "/" )
			cDirName += "/"
		EndIf
	Else
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "\" )
			cDirName += "\"
		EndIf
	EndIf

	//Monto nome do arquivo que será gerado
	cFileDest := AllTrim( cDirName ) + cReg

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
	EndIf

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da GIA-RS. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author marcos.vecki
@Since 25/07/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt		:=	TAFGetPath( "2" , "GIARS" )			                 	//diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".txt"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""

cNomeArq := aWizard[1,2]

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" )
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" )
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := GIAFilesTxt(cPathTxt)
	for nx := 1 to Len( aFiles )

		//Verifica se o arquivo foi encontrado no diretorio
		if File( aFiles[nx][1] )

			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()				//POSICIONO NO TOPO

			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
	 			cStrTxtFIM += cBuffer + CRLF
				FT_FSKIP()
			endDo
			FT_FUSE()
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".txt"
	EndIf

	WrtStrTxt( nHandle, cStrTxtFIM )

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

	for nx := 1 to Len( aFiles )

		//Verifica se o arquivo foi encontrado no diretorio
		if File( aFiles[nx][1] )

			FERASE( aFiles[nx][1] )

		endif
	next

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GIAFilesTxt

GIAFilesTxt() - Arquivos por bloco da GIA

@Author marcos.vecki
@Since 25/07/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function GIAFilesTxt( cPathTxt )

Local aRet	:=	{}
Local nPos  as Numeric

For nPos := 1 To len(aFil)
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_ABCE.TXT"}) //Registro Principal
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_OBS.TXT"}) //Observações
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_XDC.TXT"}) //Dados do Contribuinte
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X01.TXT"}) //Dados do Anexo I - Ic
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X02_X03.TXT"}) //Dados do Anexo II e III
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X04.TXT"}) //Dados do Anexo IV
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X05.TXT"}) //Dados do Anexo V - Va - Vb - Vc
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X06.TXT"}) //Dados do Anexo VI
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X07.TXT"}) //Dados do Anexo VII - VIIa - VIIb
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X08.TXT"}) //Dados do Anexo VIII - IX - X
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X14.TXT"}) //Dados do Anexo XIV - XV
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_X16.TXT"}) //Dados do Anexo XVI
Next nPos

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TabCfop

CriaTab() - Função que Cria a tabela de CFOP X Ajuste.

@Author marcos.vecki
@Since 29/07/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab( oTbTemp )

	Local nI		 as Numeric
	Local cArqTrab	 as Char
	Local cIndex	 as Char
	Local cChave	 as Char
	Local aFields	 as Array

	//**********************
	// INICIALIZA VARIÁVEIS
	//**********************
	aFields 	:= {}
	nI			:= 0
	cArqui		:= ""
	cAliasCFOP 	:= getNextAlias( )

	//--------------------------
	//Monta os campos da tabela
	//--------------------------
	aadd( aFields, { "CFOP"	  , "C", 4, 0 } )
	aadd( aFields, { "CODAJU" , "C", 1, 0 } )

	oTbTemp	:= FWTemporaryTable( ):New( cAliasCFOP, aFields )

	//--------------------------
	//Monta os índices da tabela
	//--------------------------
	oTbTemp:AddIndex( "1", { "CFOP" } )

	//------------------
	//Criação da tabela
	//------------------
	oTbTemp:Create( )

	dbSelectArea( cAliasCFOP )

	AddTable('1101','1')
	AddTable('1101','2')
	AddTable('1101','4')
	AddTable('1102','1')
	AddTable('1102','2')
	AddTable('1102','4')
	AddTable('1111','2')
	AddTable('1111','4')
	AddTable('1111','5')
	AddTable('1113','2')
	AddTable('1113','4')
	AddTable('1113','5')
	AddTable('1116','1')
	AddTable('1116','2')
	AddTable('1116','4')
	AddTable('1117','1')
	AddTable('1117','2')
	AddTable('1117','4')
	AddTable('1118','1')
	AddTable('1118','2')
	AddTable('1118','4')
	AddTable('1120','1')
	AddTable('1121','1')
	AddTable('1122','1')
	AddTable('1122','2')
	AddTable('1122','4')
	AddTable('1124','1')
	AddTable('1124','2')
	AddTable('1125','1')
	AddTable('1125','2')
	AddTable('1126','1')
	AddTable('1126','2')
	AddTable('1126','4')
	AddTable('1126','6')
	AddTable('1128','1')
	AddTable('1128','2')
	AddTable('1128','4')
	AddTable('1128','5')
	AddTable('1151','1')
	AddTable('1151','2')
	AddTable('1151','4')
	AddTable('1152','1')
	AddTable('1152','2')
	AddTable('1152','4')
	AddTable('1154','1')
	AddTable('1154','2')
	AddTable('1154','4')
	AddTable('1154','6')
	AddTable('1201','1')
	AddTable('1201','2')
	AddTable('1201','4')
	AddTable('1202','1')
	AddTable('1202','2')
	AddTable('1203','5')
	AddTable('1204','5')
	AddTable('1206','4')
	AddTable('1208','1')
	AddTable('1208','2')
	AddTable('1208','4')
	AddTable('1252','6')
	AddTable('1253','5')
	AddTable('1254','5')
	AddTable('1255','5')
	AddTable('1256','5')
	AddTable('1257','6')
	AddTable('1301','6')
	AddTable('1302','6')
	AddTable('1303','5')
	AddTable('1304','5')
	AddTable('1305','5')
	AddTable('1306','5')
	AddTable('1351','4')
	AddTable('1352','3')
	AddTable('1352','4')
	AddTable('1352','6')
	AddTable('1353','3')
	AddTable('1353','4')
	AddTable('1353','6')
	AddTable('1354','3')
	AddTable('1354','4')
	AddTable('1354','6')
	AddTable('1355','3')
	AddTable('1355','4')
	AddTable('1355','6')
	AddTable('1356','4')
	AddTable('1356','5')
	AddTable('1360','4')
	AddTable('1360','6')
	AddTable('1401','1')
	AddTable('1401','2')
	AddTable('1403','1')
	AddTable('1403','2')
	AddTable('1406','1')
	AddTable('1406','2')
	AddTable('1406','5')
	AddTable('1407','1')
	AddTable('1407','2')
	AddTable('1407','5')
	AddTable('1408','1')
	AddTable('1408','2')
	AddTable('1409','1')
	AddTable('1409','2')
	AddTable('1410','1')
	AddTable('1410','2')
	AddTable('1411','1')
	AddTable('1411','2')
	AddTable('1414','1')
	AddTable('1414','2')
	AddTable('1414','5')
	AddTable('1415','1')
	AddTable('1415','5')
	AddTable('1452','2')
	AddTable('1505','5')
	AddTable('1506','5')
	AddTable('1551','1')
	AddTable('1551','2')
	AddTable('1551','5')
	AddTable('1552','5')
	AddTable('1553','5')
	AddTable('1554','5')
	AddTable('1555','5')
	AddTable('1556','1')
	AddTable('1556','2')
	AddTable('1556','4')
	AddTable('1556','5')
	AddTable('1557','4')
	AddTable('1557','5')
	AddTable('1601','5')
	AddTable('1602','5')
	AddTable('1603','5')
	AddTable('1604','5')
	AddTable('1605','5')
	AddTable('1651','1')
	AddTable('1651','2')
	AddTable('1652','1')
	AddTable('1652','2')
	AddTable('1653','1')
	AddTable('1653','2')
	AddTable('1653','6')
	AddTable('1658','1')
	AddTable('1658','2')
	AddTable('1659','1')
	AddTable('1659','2')
	AddTable('1660','1')
	AddTable('1660','2')
	AddTable('1661','1')
	AddTable('1661','2')
	AddTable('1662','1')
	AddTable('1662','2')
	AddTable('1663','1')
	AddTable('1663','2')
	AddTable('1663','5')
	AddTable('1664','5')
	AddTable('1901','4')
	AddTable('1901','5')
	AddTable('1902','4')
	AddTable('1902','5')
	AddTable('1903','4')
	AddTable('1903','5')
	AddTable('1904','1')
	AddTable('1904','2')
	AddTable('1904','4')
	AddTable('1904','5')
	AddTable('1905','1')
	AddTable('1905','2')
	AddTable('1905','5')
	AddTable('1906','5')
	AddTable('1907','5')
	AddTable('1908','1')
	AddTable('1908','2')
	AddTable('1908','5')
	AddTable('1909','5')
	AddTable('1910','1')
	AddTable('1910','2')
	AddTable('1910','6')
	AddTable('1911','2')
	AddTable('1911','5')
	AddTable('1912','2')
	AddTable('1912','5')
	AddTable('1913','2')
	AddTable('1913','5')
	AddTable('1914','1')
	AddTable('1914','2')
	AddTable('1914','4')
	AddTable('1915','5')
	AddTable('1916','5')
	AddTable('1917','1')
	AddTable('1917','2')
	AddTable('1917','4')
	AddTable('1918','1')
	AddTable('1918','2')
	AddTable('1918','4')
	AddTable('1919','5')
	AddTable('1920','2')
	AddTable('1920','5')
	AddTable('1921','5')
	AddTable('1922','5')
	AddTable('1923','5')
	AddTable('1924','5')
	AddTable('1925','1')
	AddTable('1925','2')
	AddTable('1925','5')
	AddTable('1931','4')
	AddTable('1932','4')
	AddTable('1933','5')
	AddTable('1934','5')
	AddTable('1949','1')
	AddTable('1949','2')
	AddTable('1949','4')
	AddTable('1949','5')
	AddTable('2101','1')
	AddTable('2101','2')
	AddTable('2101','4')
	AddTable('2102','1')
	AddTable('2102','2')
	AddTable('2102','4')
	AddTable('2111','2')
	AddTable('2111','4')
	AddTable('2111','5')
	AddTable('2113','2')
	AddTable('2113','4')
	AddTable('2113','5')
	AddTable('2116','1')
	AddTable('2116','2')
	AddTable('2116','4')
	AddTable('2117','1')
	AddTable('2117','2')
	AddTable('2117','4')
	AddTable('2118','1')
	AddTable('2118','2')
	AddTable('2118','4')
	AddTable('2120','1')
	AddTable('2121','1')
	AddTable('2122','1')
	AddTable('2122','2')
	AddTable('2122','4')
	AddTable('2124','1')
	AddTable('2124','2')
	AddTable('2125','1')
	AddTable('2125','2')
	AddTable('2126','1')
	AddTable('2126','2')
	AddTable('2126','4')
	AddTable('2126','6')
	AddTable('2128','1')
	AddTable('2128','2')
	AddTable('2128','4')
	AddTable('2128','5')
	AddTable('2151','1')
	AddTable('2151','2')
	AddTable('2151','4')
	AddTable('2152','1')
	AddTable('2152','2')
	AddTable('2152','4')
	AddTable('2154','1')
	AddTable('2154','2')
	AddTable('2154','4')
	AddTable('2154','6')
	AddTable('2201','1')
	AddTable('2201','2')
	AddTable('2201','4')
	AddTable('2202','1')
	AddTable('2202','2')
	AddTable('2206','3')
	AddTable('2206','4')
	AddTable('2208','1')
	AddTable('2208','2')
	AddTable('2208','4')
	AddTable('2252','1')
	AddTable('2252','6')
	AddTable('2253','5')
	AddTable('2254','5')
	AddTable('2255','5')
	AddTable('2256','5')
	AddTable('2257','6')
	AddTable('2301','6')
	AddTable('2302','6')
	AddTable('2303','5')
	AddTable('2304','5')
	AddTable('2305','5')
	AddTable('2306','5')
	AddTable('2351','4')
	AddTable('2352','3')
	AddTable('2352','4')
	AddTable('2352','6')
	AddTable('2353','3')
	AddTable('2353','4')
	AddTable('2353','6')
	AddTable('2354','3')
	AddTable('2354','4')
	AddTable('2354','6')
	AddTable('2355','3')
	AddTable('2355','4')
	AddTable('2355','6')
	AddTable('2356','4')
	AddTable('2356','5')
	AddTable('2401','1')
	AddTable('2401','2')
	AddTable('2403','1')
	AddTable('2403','2')
	AddTable('2406','1')
	AddTable('2406','2')
	AddTable('2406','5')
	AddTable('2407','1')
	AddTable('2407','2')
	AddTable('2407','5')
	AddTable('2408','1')
	AddTable('2408','2')
	AddTable('2409','1')
	AddTable('2409','2')
	AddTable('2410','1')
	AddTable('2410','2')
	AddTable('2411','1')
	AddTable('2411','2')
	AddTable('2414','1')
	AddTable('2414','2')
	AddTable('2414','5')
	AddTable('2415','1')
	AddTable('2415','5')
	AddTable('2505','5')
	AddTable('2506','5')
	AddTable('2551','1')
	AddTable('2551','2')
	AddTable('2551','5')
	AddTable('2552','5')
	AddTable('2553','5')
	AddTable('2554','5')
	AddTable('2555','5')
	AddTable('2556','1')
	AddTable('2556','2')
	AddTable('2556','4')
	AddTable('2556','5')
	AddTable('2557','4')
	AddTable('2557','5')
	AddTable('2603','5')
	AddTable('2651','1')
	AddTable('2651','2')
	AddTable('2652','1')
	AddTable('2652','2')
	AddTable('2653','1')
	AddTable('2653','2')
	AddTable('2653','6')
	AddTable('2658','1')
	AddTable('2658','2')
	AddTable('2659','1')
	AddTable('2659','2')
	AddTable('2660','1')
	AddTable('2660','2')
	AddTable('2661','1')
	AddTable('2661','2')
	AddTable('2662','1')
	AddTable('2662','2')
	AddTable('2663','1')
	AddTable('2663','2')
	AddTable('2663','5')
	AddTable('2664','5')
	AddTable('2901','1')
	AddTable('2901','2')
	AddTable('2901','4')
	AddTable('2901','5')
	AddTable('2902','1')
	AddTable('2902','2')
	AddTable('2902','4')
	AddTable('2902','5')
	AddTable('2903','1')
	AddTable('2903','2')
	AddTable('2903','4')
	AddTable('2903','5')
	AddTable('2904','1')
	AddTable('2904','2')
	AddTable('2904','4')
	AddTable('2904','5')
	AddTable('2905','1')
	AddTable('2905','2')
	AddTable('2905','4')
	AddTable('2905','5')
	AddTable('2906','1')
	AddTable('2906','2')
	AddTable('2906','4')
	AddTable('2906','5')
	AddTable('2907','5')
	AddTable('2908','1')
	AddTable('2908','2')
	AddTable('2908','5')
	AddTable('2909','5')
	AddTable('2910','1')
	AddTable('2910','2')
	AddTable('2910','6')
	AddTable('2911','2')
	AddTable('2911','5')
	AddTable('2912','1')
	AddTable('2912','2')
	AddTable('2912','5')
	AddTable('2913','1')
	AddTable('2913','2')
	AddTable('2913','5')
	AddTable('2914','1')
	AddTable('2914','2')
	AddTable('2914','4')
	AddTable('2915','5')
	AddTable('2916','5')
	AddTable('2917','1')
	AddTable('2917','2')
	AddTable('2917','4')
	AddTable('2918','1')
	AddTable('2918','2')
	AddTable('2918','4')
	AddTable('2919','5')
	AddTable('2920','5')
	AddTable('2921','5')
	AddTable('2922','5')
	AddTable('2923','5')
	AddTable('2924','5')
	AddTable('2925','1')
	AddTable('2925','2')
	AddTable('2925','5')
	AddTable('2931','4')
	AddTable('2932','4')
	AddTable('2933','5')
	AddTable('2934','5')
	AddTable('2949','1')
	AddTable('2949','2')
	AddTable('2949','4')
	AddTable('2949','5')
	AddTable('3101','1')
	AddTable('3101','2')
	AddTable('3102','1')
	AddTable('3102','2')
	AddTable('3126','2')
	AddTable('3126','6')
	AddTable('3128','2')
	AddTable('3128','5')
	AddTable('3301','6')
	AddTable('3356','5')
	AddTable('3551','2')
	AddTable('3551','5')
	AddTable('3553','5')
	AddTable('3556','2')
	AddTable('3556','5')
	AddTable('3651','2')
	AddTable('3652','2')
	AddTable('3653','2')
	AddTable('3653','6')
	AddTable('3949','2')
	AddTable('3949','5')
	AddTable('5101','1')
	AddTable('5101','2')
	AddTable('5101','4')
	AddTable('5102','1')
	AddTable('5102','2')
	AddTable('5103','1')
	AddTable('5103','2')
	AddTable('5103','4')
	AddTable('5104','1')
	AddTable('5105','1')
	AddTable('5105','2')
	AddTable('5105','4')
	AddTable('5106','1')
	AddTable('5109','5')
	AddTable('5110','5')
	AddTable('5111','2')
	AddTable('5111','4')
	AddTable('5111','5')
	AddTable('5112','5')
	AddTable('5113','2')
	AddTable('5113','4')
	AddTable('5113','5')
	AddTable('5114','5')
	AddTable('5116','1')
	AddTable('5116','2')
	AddTable('5116','4')
	AddTable('5117','1')
	AddTable('5117','4')
	AddTable('5118','1')
	AddTable('5118','2')
	AddTable('5118','4')
	AddTable('5119','1')
	AddTable('5120','1')
	AddTable('5122','1')
	AddTable('5122','2')
	AddTable('5122','4')
	AddTable('5123','1')
	AddTable('5124','1')
	AddTable('5124','2')
	AddTable('5125','1')
	AddTable('5125','2')
	AddTable('5151','1')
	AddTable('5151','2')
	AddTable('5151','4')
	AddTable('5152','1')
	AddTable('5155','1')
	AddTable('5155','2')
	AddTable('5155','4')
	AddTable('5156','1')
	AddTable('5201','1')
	AddTable('5201','2')
	AddTable('5201','4')
	AddTable('5202','1')
	AddTable('5202','2')
	AddTable('5202','4')
	AddTable('5205','6')
	AddTable('5207','6')
	AddTable('5208','1')
	AddTable('5208','2')
	AddTable('5208','4')
	AddTable('5209','1')
	AddTable('5209','2')
	AddTable('5209','4')
	AddTable('5210','1')
	AddTable('5210','2')
	AddTable('5210','4')
	AddTable('5210','6')
	AddTable('5351','4')
	AddTable('5352','4')
	AddTable('5353','4')
	AddTable('5354','4')
	AddTable('5355','4')
	AddTable('5356','4')
	AddTable('5357','4')
	AddTable('5359','4')
	AddTable('5360','4')
	AddTable('5360','6')
	AddTable('5401','1')
	AddTable('5401','2')
	AddTable('5401','4')
	AddTable('5402','1')
	AddTable('5402','2')
	AddTable('5402','4')
	AddTable('5403','1')
	AddTable('5403','2')
	AddTable('5405','2')
	AddTable('5408','1')
	AddTable('5408','2')
	AddTable('5408','4')
	AddTable('5409','1')
	AddTable('5410','1')
	AddTable('5410','2')
	AddTable('5410','4')
	AddTable('5411','1')
	AddTable('5411','2')
	AddTable('5411','4')
	AddTable('5412','1')
	AddTable('5412','2')
	AddTable('5412','5')
	AddTable('5413','1')
	AddTable('5413','2')
	AddTable('5413','5')
	AddTable('5414','1')
	AddTable('5414','2')
	AddTable('5414','4')
	AddTable('5414','5')
	AddTable('5415','1')
	AddTable('5415','5')
	AddTable('5451','2')
	AddTable('5504','5')
	AddTable('5505','5')
	AddTable('5551','5')
	AddTable('5552','5')
	AddTable('5553','1')
	AddTable('5553','2')
	AddTable('5553','5')
	AddTable('5554','5')
	AddTable('5555','5')
	AddTable('5556','1')
	AddTable('5556','2')
	AddTable('5556','4')
	AddTable('5556','5')
	AddTable('5557','5')
	AddTable('5601','5')
	AddTable('5602','5')
	AddTable('5603','1')
	AddTable('5603','5')
	AddTable('5605','5')
	AddTable('5606','5')
	AddTable('5651','1')
	AddTable('5651','2')
	AddTable('5652','1')
	AddTable('5652','2')
	AddTable('5653','1')
	AddTable('5653','2')
	AddTable('5654','1')
	AddTable('5655','1')
	AddTable('5656','1')
	AddTable('5657','1')
	AddTable('5657','5')
	AddTable('5658','1')
	AddTable('5658','2')
	AddTable('5659','1')
	AddTable('5660','1')
	AddTable('5660','2')
	AddTable('5661','1')
	AddTable('5661','2')
	AddTable('5662','1')
	AddTable('5662','2')
	AddTable('5662','6')
	AddTable('5663','1')
	AddTable('5663','2')
	AddTable('5663','5')
	AddTable('5664','5')
	AddTable('5665','5')
	AddTable('5666','5')
	AddTable('5667','2')
	AddTable('5901','1')
	AddTable('5901','2')
	AddTable('5901','4')
	AddTable('5901','5')
	AddTable('5902','1')
	AddTable('5902','2')
	AddTable('5902','4')
	AddTable('5902','5')
	AddTable('5903','1')
	AddTable('5903','2')
	AddTable('5903','4')
	AddTable('5903','5')
	AddTable('5904','1')
	AddTable('5904','2')
	AddTable('5904','4')
	AddTable('5904','5')
	AddTable('5905','5')
	AddTable('5906','5')
	AddTable('5907','5')
	AddTable('5908','1')
	AddTable('5908','2')
	AddTable('5908','5')
	AddTable('5909','5')
	AddTable('5910','1')
	AddTable('5910','2')
	AddTable('5910','6')
	AddTable('5911','2')
	AddTable('5911','5')
	AddTable('5912','2')
	AddTable('5912','5')
	AddTable('5913','2')
	AddTable('5913','5')
	AddTable('5914','1')
	AddTable('5914','2')
	AddTable('5914','4')
	AddTable('5915','5')
	AddTable('5916','5')
	AddTable('5917','1')
	AddTable('5917','2')
	AddTable('5917','4')
	AddTable('5918','1')
	AddTable('5918','2')
	AddTable('5918','4')
	AddTable('5919','5')
	AddTable('5920','5')
	AddTable('5921','5')
	AddTable('5922','5')
	AddTable('5923','4')
	AddTable('5923','5')
	AddTable('5924','4')
	AddTable('5924','5')
	AddTable('5925','4')
	AddTable('5925','5')
	AddTable('5927','2')
	AddTable('5928','1')
	AddTable('5928','2')
	AddTable('5928','4')
	AddTable('5929','5')
	AddTable('5931','4')
	AddTable('5932','4')
	AddTable('5932','5')
	AddTable('5933','5')
	AddTable('5934','5')
	AddTable('5949','1')
	AddTable('5949','2')
	AddTable('5949','4')
	AddTable('5949','5')
	AddTable('6101','1')
	AddTable('6101','2')
	AddTable('6101','4')
	AddTable('6102','1')
	AddTable('6102','2')
	AddTable('6103','1')
	AddTable('6103','2')
	AddTable('6103','4')
	AddTable('6104','1')
	AddTable('6105','1')
	AddTable('6105','2')
	AddTable('6105','4')
	AddTable('6106','1')
	AddTable('6107','2')
	AddTable('6107','4')
	AddTable('6108','2')
	AddTable('6111','2')
	AddTable('6111','4')
	AddTable('6111','5')
	AddTable('6112','5')
	AddTable('6113','2')
	AddTable('6113','4')
	AddTable('6113','5')
	AddTable('6114','5')
	AddTable('6116','1')
	AddTable('6116','2')
	AddTable('6116','4')
	AddTable('6117','1')
	AddTable('6118','1')
	AddTable('6118','2')
	AddTable('6118','4')
	AddTable('6119','1')
	AddTable('6120','1')
	AddTable('6122','1')
	AddTable('6122','2')
	AddTable('6122','4')
	AddTable('6123','1')
	AddTable('6124','1')
	AddTable('6124','2')
	AddTable('6125','1')
	AddTable('6125','2')
	AddTable('6151','1')
	AddTable('6151','2')
	AddTable('6151','4')
	AddTable('6152','1')
	AddTable('6155','1')
	AddTable('6155','2')
	AddTable('6155','4')
	AddTable('6156','1')
	AddTable('6201','1')
	AddTable('6201','2')
	AddTable('6201','4')
	AddTable('6202','1')
	AddTable('6202','2')
	AddTable('6202','4')
	AddTable('6205','6')
	AddTable('6207','6')
	AddTable('6208','1')
	AddTable('6208','2')
	AddTable('6208','4')
	AddTable('6209','1')
	AddTable('6209','2')
	AddTable('6209','4')
	AddTable('6210','1')
	AddTable('6210','2')
	AddTable('6210','4')
	AddTable('6210','6')
	AddTable('6351','4')
	AddTable('6352','4')
	AddTable('6353','4')
	AddTable('6354','4')
	AddTable('6355','4')
	AddTable('6356','4')
	AddTable('6357','4')
	AddTable('6359','4')
	AddTable('6360','4')
	AddTable('6360','6')
	AddTable('6401','1')
	AddTable('6401','2')
	AddTable('6401','4')
	AddTable('6402','1')
	AddTable('6402','2')
	AddTable('6402','4')
	AddTable('6403','1')
	AddTable('6403','2')
	AddTable('6404','1')
	AddTable('6404','2')
	AddTable('6408','1')
	AddTable('6408','2')
	AddTable('6408','4')
	AddTable('6409','1')
	AddTable('6410','1')
	AddTable('6410','2')
	AddTable('6410','4')
	AddTable('6411','1')
	AddTable('6411','2')
	AddTable('6411','4')
	AddTable('6412','1')
	AddTable('6412','2')
	AddTable('6412','5')
	AddTable('6413','1')
	AddTable('6413','2')
	AddTable('6413','5')
	AddTable('6414','1')
	AddTable('6414','2')
	AddTable('6414','4')
	AddTable('6414','5')
	AddTable('6415','1')
	AddTable('6415','5')
	AddTable('6504','5')
	AddTable('6505','5')
	AddTable('6551','5')
	AddTable('6552','5')
	AddTable('6553','1')
	AddTable('6553','2')
	AddTable('6553','5')
	AddTable('6554','5')
	AddTable('6555','5')
	AddTable('6556','1')
	AddTable('6556','2')
	AddTable('6556','4')
	AddTable('6556','5')
	AddTable('6557','5')
	AddTable('6603','1')
	AddTable('6603','5')
	AddTable('6651','1')
	AddTable('6651','2')
	AddTable('6652','1')
	AddTable('6652','2')
	AddTable('6653','1')
	AddTable('6653','2')
	AddTable('6654','1')
	AddTable('6655','1')
	AddTable('6656','1')
	AddTable('6657','1')
	AddTable('6657','5')
	AddTable('6658','1')
	AddTable('6658','2')
	AddTable('6659','1')
	AddTable('6660','1')
	AddTable('6660','2')
	AddTable('6661','1')
	AddTable('6661','2')
	AddTable('6662','1')
	AddTable('6662','2')
	AddTable('6662','6')
	AddTable('6663','1')
	AddTable('6663','2')
	AddTable('6663','5')
	AddTable('6664','5')
	AddTable('6665','5')
	AddTable('6666','5')
	AddTable('6667','2')
	AddTable('6901','1')
	AddTable('6901','2')
	AddTable('6901','4')
	AddTable('6901','5')
	AddTable('6902','1')
	AddTable('6902','2')
	AddTable('6902','4')
	AddTable('6902','5')
	AddTable('6903','1')
	AddTable('6903','2')
	AddTable('6903','4')
	AddTable('6903','5')
	AddTable('6904','1')
	AddTable('6904','2')
	AddTable('6904','4')
	AddTable('6904','5')
	AddTable('6905','1')
	AddTable('6905','2')
	AddTable('6905','4')
	AddTable('6905','5')
	AddTable('6906','1')
	AddTable('6906','2')
	AddTable('6906','4')
	AddTable('6906','5')
	AddTable('6907','5')
	AddTable('6908','1')
	AddTable('6908','2')
	AddTable('6908','5')
	AddTable('6909','5')
	AddTable('6910','1')
	AddTable('6910','2')
	AddTable('6910','6')
	AddTable('6911','2')
	AddTable('6911','5')
	AddTable('6912','1')
	AddTable('6912','2')
	AddTable('6912','5')
	AddTable('6913','1')
	AddTable('6913','2')
	AddTable('6913','5')
	AddTable('6914','1')
	AddTable('6914','2')
	AddTable('6914','4')
	AddTable('6915','5')
	AddTable('6916','5')
	AddTable('6917','1')
	AddTable('6917','2')
	AddTable('6917','4')
	AddTable('6918','1')
	AddTable('6918','2')
	AddTable('6918','4')
	AddTable('6919','5')
	AddTable('6920','5')
	AddTable('6921','5')
	AddTable('6922','5')
	AddTable('6923','4')
	AddTable('6923','5')
	AddTable('6924','4')
	AddTable('6924','5')
	AddTable('6925','4')
	AddTable('6925','5')
	AddTable('6929','5')
	AddTable('6931','4')
	AddTable('6932','4')
	AddTable('6932','5')
	AddTable('6933','5')
	AddTable('6934','5')
	AddTable('6949','1')
	AddTable('6949','2')
	AddTable('6949','4')
	AddTable('6949','5')
	AddTable('7358','5')
	AddTable('7551','5')
	AddTable('7553','5')
	AddTable('7556','5')

Return ()
Static Function AddTable(pCfop, pAjuste)
	RecLock(cAliasCfop,.T.)
		(cAliasCfop)->CFOP		:= pCfop
		(cAliasCfop)->CODAJU	:= pAjuste
	(cAliasCfop)->(MsUnlock())
Return
