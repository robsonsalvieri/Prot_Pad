#Include 'Protheus.ch'
#Include "ApWizard.ch"

#Define cObrig "DAPI-MG"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDAPI

Esta rotina tem como objetivo a geracao do Arquivo DAPI-MG

@Author Rafael Völtz
@Since 21/04/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDAPI()
Local cNomWiz    := cObrig + FWGETCODFILIAL
Local lEnd       := .F.
Local cFunction  := ProcName()
Local nOpc       := 2 //View

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess := Nil

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//Protect Data / Log de acesso / Central de Obrigacoes
Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

//Cria objeto de controle do processamento
oProcess := TAFProgress():New( { |lEnd| ProcDapiMg( @lEnd, @oProcess, cNomWiz ) }, "Processando DAPI - MG" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcDapiMg

Inicia o processamento para geracao da DAPI - MG


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
		oProcess  -> Objeto da barra de progresso da emissao da DAPI-MG
		cNomWiz   -> Nome da Wizard criada para a DAPI


@Return ( Nil )

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
*/

Static Function ProcDapiMg( lEnd, oProcess, cNomWiz )

Local cErrorDAPI	:=	""
Local cErrorTrd	:=	""

Local nI			:=	0
Local nProgress1	:=	0

Local aWizard		:=	{}
Local aJobAux		:=	{}
Local lProc		:=	.T.
Local nCont   	:= 0
Local lTermo      := .F.

Local cCodigo  := ""
Local cNome		:= ""
Local cCodMun  := ""
Local cCNAE    := ""
Local cInscEst := ""
Local cUF     := ""
Local aFiliais	:=	{}
Local cUFID := ""
Private aFil := {}

	//Carrega informações na wizard
 	If !xFunLoadProf( cNomWiz , @aWizard )
 		Return( Nil )
 	EndIf

 	If(!valWizard(aWizard))
 		lProc := .F.
	Else

		DBSELECTAREA("C09")

		//Verificação das filiais selecionadas para processamento da operação
		If "1" $ aWizard[1,8]
		  	aFiliais := xFunTelaFil( .T. )
			If Empty( aFiliais )
				lProc := .F.
			Else
				If Len( aFiliais ) > 0
		          For nI := 1 to Len( aFiliais )
						If aFiliais[nI][1]
							cCodigo := aFiliais[nI][2]
							cNome	 := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_FILIAL")
							cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CODMUN")
							cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CNAE")
							cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_INSC")
							cUF     := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_ESTCOB")

							C09->(DBSETORDER(1))
							If (DBSEEK(xFilial("C09")+cUF))
								cUFID := C09->C09_ID
							Endif

							AADD(aFil,{cCodigo, cNome, cCodMun, cCNAE, cInscEst,cUF, cUFID})
						Endif
					Next
				EndIf
			EndIf
		Else
			cNome	 := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_FILIAL")
			cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CODMUN")
			cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CNAE")
			cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")
			cUF     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_ESTCOB")

			C09->(DBSETORDER(1))
			If (DBSEEK(xFilial("C09")+cUF))
				cUFID := C09->C09_ID
			Endif

			AADD(aFil,{cFilAnt, cNome, cCodMun, cCNAE, cInscEst, cUF, cUFID})
		EndIf
	EndIf

	If lProc

	 	//Alimentando a variável de controle da barra de status do processamento
	 	nProgress1 := 2
	 	oProcess:Set1Progress( nProgress1 )

		//Iniciando o Processamento
		oProcess:Inc1Progress( "Preparando o Ambiente..." )

		//Geração DAPI-MG
		For nI := 1 To Len(aFil)
			oProcess:Inc1Progress( "Executando o Processamento Filial "+aFil[nI][1] + " - " + aFil[nI][2])
			TAFDAPI00(aWizard, @nCont,aFil[nI],@lTermo)
			TAFDAPI10(aWizard, @nCont,aFil[nI],lTermo)
			TAFDAPI20(aWizard, @nCont,aFil[nI])
			TAFDAPI21(aWizard, @nCont,aFil[nI])
			TAFDAPI22(aWizard, @nCont,aFil[nI])
			TAFDAPI23(aWizard, @nCont,aFil[nI])
			TAFDAPI24(aWizard, @nCont,aFil[nI])
			TAFDAPI25(aWizard, @nCont,aFil[nI])
			TAFDAPI27(aWizard, @nCont,aFil[nI])
			TAFDAPI28(aWizard, @nCont,aFil[nI])
			TAFDAPI29(aWizard, @nCont,aFil[nI])
			TAFDAPI34(aWizard, @nCont,aFil[nI])
			TAFDAPI36(aWizard, @nCont,aFil[nI])
			If lTermo
				TAFDAPI37(aWizard, @nCont,aFil[nI])
			Endif
			TAFDAPI99(aWizard, @nCont,aFil[nI])
		Next nI
	Else
		oProcess:Inc1Progress( "Processamento cancelado" )
		oProcess:Inc2Progress( "Clique em Finalizar" )
		oProcess:nCancel = 1
	EndIf

	//Tratamento para quando o processamento tem problemas
	If oProcess:nCancel == 1 .or. !Empty( cErrorDAPI ) .or. !Empty( cErrorTrd )

		//Cancelado o processamento
		If oProcess:nCancel == 1

			Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

		//Erro na inicialização das threads
		ElseIf !Empty( cErrorTrd )

			Aviso( "Atenção!", cErrorTrd, { "Sair" } )

		//Erro na execução dos Blocos
		Else

			cErrorDAPI := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorDAPI, 2, Len( cErrorDAPI ) )
			cErrorDAPI += "da DAPI-MG " + Chr( 10 ) + Chr( 10 )
			cErrorDAPI += "Favor efetuar o reprocessamento da DAPI-MG, caso o erro persista entre em contato "
			cErrorDAPI += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

			Aviso( "Atenção!", cErrorDAPI, { "Sair" } )

		EndIf

	Else

		//Atualizando a barra de processamento
		oProcess:Inc1Progress( "Informações processadas" )
		oProcess:Inc2Progress( "Consolidando as informações e gerando arquivo..." )


		If GerTxtCons( aWizard )
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
/*/{Protheus.doc} valWizard

valWizard () Valida informações da Wizard
@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function valWizard(aWizard)

	If((Month(aWizard[1][1]) + Year(aWizard[1][1])) != (Month(aWizard[1][2]) + Year(aWizard[1][2])))
		Aviso( "Atenção!", "Data inicial e final devem estar dentro do mesmo mês.", { "Sair" } )
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens0	:= {}
	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens6	:= {}

	Local	cTitObj1	:= ""
	Local	aRet		:= {}
	Local lWebApp		:= GetRemoteType() = 5
	Local lWhen			:= !lWebApp //Se for WebApp, nao passa pelo campo.	

	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético DAPI-MG.")

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DAPI-MG.")
	aAdd (aPaineis[nPos], {})


	//Coluna1																//Coluna 2
	cTitObj1	:=	"Período referência de:";						    	cTitObj2	:=	"Até: "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {2,,,3,,,,});	 				           		aAdd (aPaineis[nPos][3], {2,,,3,,,,})   // calendário

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	"Diretório do Arquivo Destino";							cTitObj2	:=	"Nome do Arquivo Destino"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 100);					    			cTitObj2	:=	Replicate ("X", 100)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50,,,,,,,,,,,,,,,lWhen});	aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})


	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


	cTitObj1	:=	"Regime de Recolhimento"			 ;               cTitObj2	:=	"Data limite para pagamento"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	 ;               aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens0, "1 - Débito e Crédito")
	aAdd (aItens0, "3 - Isento ou Imune")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens0,,,,,});                aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 	 // calendário

   aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


   cTitObj1	:=	"Desmembramento do CNAE-F"	   ;                 cTitObj2	:=  "Seleciona filiais?"
   aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

   cTitObj1	:=	"99" ;                                          aAdd (aItens6, "0 - Não")
   aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,2});                aAdd (aItens6, "1 - Sim")
                                                                  aAdd (aPaineis[nPos][3], {3,,,,,aItens6,,,,,})





//PAINEL 2
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DAPI-MG")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//Coluna 1																//Coluna 2

	cTitObj1	:=  "DAPI com movimento?";                          cTitObj2 := "DAPI para substituição?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,});

	aAdd (aItens1, "0 - Não");                                      aAdd (aItens2, "0 - Não")
	aAdd (aItens1, "1 - Sim");                                      aAdd (aItens2, "1 - Sim")

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});                 aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                         aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=  "Regime especial de fiscalização?";				cTitObj2	:=  "Termo de Aceite?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});	 		        aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	
																	aItens2 := {}
	aAdd (aItens3, "0 - Não");                                      aAdd (aItens2, "0 - Não")
	aAdd (aItens3, "1 - Sim");                                      aAdd (aItens2, "1 - Sim")

	aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd(aPaineis[nPos][3], {0,"",,,,,,})


	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDAPI() } )
Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDAPI

Geracao do Arquivo TXT da DAPI-MG.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DAPI-MG
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDAPI( nHandle, cTXTSys, cReg, cFil)

Local	cDirName		:=	TAFGetPath( "2" , "DAPIMG" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\DAPIMG. Erro: " + cValToChar( FError() ) , 1, 0 )

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
	cFileDest := AllTrim( cDirName ) + cFil + "_"+cReg

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
	EndIf

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest, .t. )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da DAPI-MG. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][3] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	TAFGetPath( "2" , "DAPIMG" )		                  //diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".txt"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" 
			cFileDest += "/"
			cFileDest += Alltrim(aWizard[1][4]) //Incrementa o nome do arquivo de geração
		elseIf  SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" 
			cFileDest += Alltrim(aWizard[1][4]) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" 
			cFileDest += "\"
			cFileDest += Alltrim(aWizard[1][4]) //Incrementa o nome do arquivo de geração
		elseIf  SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" 
			cFileDest += Alltrim(aWizard[1][4]) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := DAPIFilesTxt(cPathTxt)
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

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".txt"
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
/*/{Protheus.doc} DAPIFilesTxt

DAPIFilesTxt() - Arquivos por bloco da DAPI

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function DAPIFilesTxt(cPathTxt)

Local aRet	:=	{}
Local nI := 0

 For nI :=1 to Len(aFil)
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_00.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_10.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_20.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_21.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_22.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_23.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_24.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_25.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_27.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_28.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_29.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_34.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_36.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_37.TXT"})
	AADD(aRet,{cPathTxt+aFil[nI][1]+"_99.TXT"})
 Next
return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AddLinDAPI
Incrementa uma linha no total de linhas do arquivo DAPI-MG

@author Rafael Völtz
@since  03/11/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function AddLinDAPI(nCont)

Local nTotLin	:= 0

nTotLin	:= val(GetGlbValue( "cTotLinMG" ))
nTotLin    += nCont

PutGlbValue( "cTotLinMG" , Str(nTotLin) )
GlbUnlock()

Return
