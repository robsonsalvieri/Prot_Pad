#Include 'Protheus.ch'

#Define cObrig "DMA-BA"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDMA

Esta rotina tem como objetivo a geracao do Arquivo DMA - BA

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDMA()

Local cNomWiz   := cObrig + FWGETCODFILIAL
Local lEnd      := .F.
Local cFunction := ProcName()
Local nOpc      := 2 //View

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
oProcess := TAFProgress():New( { |lEnd| ProcDMABA( @lEnd, @oProcess, cNomWiz ) }, "Processando DMA - BA" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcDMABA

Inicia o processamento para geracao da DMA - BA


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
		oProcess  -> Objeto da barra de progresso da emissao da DMA-BA
		cNomWiz   -> Nome da Wizard criada para a DMA


@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
*/

Function ProcDMABA( lEnd, oProcess, cNomWiz )


Local cErrorDMA	:=	""
Local cErrorTrd	:=	""

Local nI			:=	0
Local nPos			:=	0
Local nProgress1	:=	0

Local aWizard		:=	{}
Local aFiliais		:=	{}
Local aJobAux		:=	{}

Local lProc		:=	.T.

Local nCont   	:= 0
Local cCodigo  := ""
Local cNome		:= ""
Local cCodMun  := ""
Local cCNAE    := ""
Local cInscEst := ""
Local cUFID   := ""

private aArrayExc := {}
private aArrayDed := {}
private aArrayCpl := {}

Private aFil := {}

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

If(!valWizard(aWizard))
	lProc := .F.
Else
	If "1" $ aWizard[3,2] //Verificação das filiais selecionadas para processamento da operação

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

						C09->(DBSETORDER(1))
						If (DBSEEK(xFilial("C09")+Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_ESTCOB")))
							cUFID := C09->C09_ID
						Endif

						AADD(aFil,{cCodigo, cNome, cCodMun, cCNAE, cInscEst})
					Endif
				Next
			EndIf
		EndIf
	Else
		cNome	 := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_FILIAL")
		cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CODMUN")
		cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CNAE")
		cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")

		C09->(DBSETORDER(1))
		If (DBSEEK(xFilial("C09")+Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_ESTCOB")))
			cUFID := C09->C09_ID
		Endif

		AADD(aFil,{cFilAnt, cNome, cCodMun, cCNAE, cInscEst, cUFID})
	EndIf
Endif

If(lProc)
	If "1" $ aWizard[3][3] //Verificação as naturezas de exceção
		If(!FNatOpUso())
			lProc := .F.
		EndIf
	EndIf

	If "1" $ aWizard[3][4] //Verificação as naturezas de operações dedutiveis / não dedutiveis
		If(!FNatOpUso2())
			lProc := .F.
		EndIf
	EndIf

	If(!FNatOpUso3())
		lProc := .F.
	EndIf
EndIf

If lProc


	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )
	oProcess:Inc1Progress( "Executando o Processamento...")

	//Geração DMA-BA
	nCont := 0
	For nPos := 1 To len(aFil)
		nCont++
		TAFDMA00   	(aWizard, aFil[nPos])
		TAFDMA01   	(aWizard, aFil[nPos])
		TAFDMA0809	(aWizard, aFil[nPos]) //OPERAÇÕES E/S POR UF	TIPO 08 E 09
		TAFDMA1011  (aWizard, aFil[nPos])
		TAFDMA12  	(aWizard, aFil[nPos])
		TAFDMA13  	(aWizard, aFil[nPos])
		TAFDMA14  	(aWizard, aFil[nPos])
		TAFDMA15  	(aWizard, aFil[nPos])
		TAFDMA16  	(aWizard, aFil[nPos])
		TAFDMA17  	(aWizard, aFil[nPos], aArrayCpl)
		TAFDMA19  	(aWizard, aFil[nPos])
		TAFDMA20  	(aWizard, aFil[nPos])
		TAFDMA2122 	(aWizard, aFil[nPos])
		TAFDMA3031 	(aWizard, aFil[nPos])
		TAFDMA4092 	(aWizard, aFil[nPos], aArrayExc, aArrayDed)
	Next nPos

	If nCont > 0
		TAFDMA99   (aWizard, nCont)
	EndIf
Else
	oProcess:Inc1Progress( "Processamento cancelado" )
	oProcess:Inc2Progress( "Clique em Finalizar" )
	oProcess:nCancel = 1

EndIf

//Tratamento para quando o processamento tem problemas
If oProcess:nCancel == 1 .or. !Empty( cErrorDMA ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorDMA := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorDMA, 2, Len( cErrorDMA ) )
		cErrorDMA += "da DMA-BA " + Chr( 10 ) + Chr( 10 )
		cErrorDMA += "Favor efetuar o reprocessamento da DMA-BA, caso o erro persista entre em contato "
		cErrorDMA += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorDMA, { "Sair" } )

	EndIf

Else

	//Atualizando a barra de processamento
	oProcess:Inc1Progress( "Informações processadas" )
	oProcess:Inc2Progress( "Consolidando as informações e gerando arquivo..." )


	If GerTxtCons( aWizard, aFil )
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

@author Jean Battista Grahl Espindola
@since	27/08/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens4	:= {}
	Local	aItens6	:= {}
	Local	aItens7	:= {}
	Local	aItens8	:= {}

	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}
	Local lWebApp	:= GetRemoteType() = 5
	Local lWhen		:= !lWebApp //Se for WebApp, nao passa pelo campo.

	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético DMA-BA.")

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DMA-BA.")
	aAdd (aPaineis[nPos], {})

	//Coluna1																	//Coluna 2
	cTitObj1	:=	"Diretório do Arquivo Destino:";							cTitObj2	:=	"Mes/Ano Referência:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});								aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 100);					    				cTitObj2	:=	"99/9999"
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50,,,,,,,,,,,,,,,lWhen});		aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,7})


//============= Painel 1 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DMA-BA.")
	aAdd (aPaineis[nPos], {})

	cTitObj2	:=	"Declaração Retificadora:"
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens1, "0 - Não")
	aAdd (aItens1, "1 - Sim")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                       		aAdd (aPaineis[nPos][3], {0,"",,,,,,});

	cTitObj1	:=  "Declaração por motivo de baixa"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 				 		aAdd (aPaineis[nPos][3], {0,"",,,,,,})

   	cTitObj1	:=  "da empresa:"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

   	aAdd (aItens2, "0 - Não")
   	aAdd (aItens2, "1 - Sim")

   	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,});               		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

   	cTitObj1	:=  "Contribuinte possui inscrição única,"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "código de atividade referente a"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "transporte ou regime especial de"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "escrituração centralizada:"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

   	aAdd (aItens3, "0 - Não")
   	aAdd (aItens3, "1 - Sim")
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                       		aAdd (aPaineis[nPos][3], {0,"",,,,,,});

	cTitObj1 :=  "Declaração por motivo de mudança de"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	cTitObj1 :=  "condição da empresa:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

   	aAdd (aItens4, "0 - Não")
   	aAdd (aItens4, "1 - Sim")
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})

   	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                       		aAdd (aPaineis[nPos][3], {0,"",,,,,,})

   	cTitObj1 :=  "Data de encerramento do balanço:"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})

   	aAdd (aPaineis[nPos][3], {0,"",,,,,,});



//PAINEL 1
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DMA-BA")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Contabilista:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

	cTitObj1	:=	Replicate ("X", 36)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )


	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1 :=    "Selecione Filiais:"
    aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

    aAdd (aItens6, "0 - Não")
    aAdd (aItens6, "1 - Sim")
    aAdd (aPaineis[nPos][3], {3,,,,,aItens6,,,,,})

    aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=  "Deseja informar as naturezas de operação"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "como exceções para os registros"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "tipo 40, 50, 60, 66, 77 e 88?"

   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

   	aAdd (aItens7, "0 - Não")
   	aAdd (aItens7, "1 - Sim")
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens7,,,,,})

   	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=  "Deseja informar as naturezas de operação"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   	cTitObj1	:=  "como operações dedutíveis e não-dedutíveis ?"

   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

   	aAdd (aItens8, "0 - Não")
   	aAdd (aItens8, "1 - Sim")
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens8,,,,,})

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDMA() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDMA

Geracao do Arquivo TXT da DMA-BA.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DMA
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDMA( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "DMABA" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\DMABA. Erro: " + cValToChar( FError() ) , 1, 0 )

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

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest, .t. )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da DMA BA. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard, aFil)

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 						//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	TAFGetPath( "2" , "DMABA" )		              //diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""
Local cFile 		:= "adma"
	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" 
			cFileDest += "/"
			cFileDest += Alltrim(cFile) //Incrementa o nome do arquivo de geração
		elseIf SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" 
			cFileDest += Alltrim(cFile) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" 
			cFileDest += "\"
			cFileDest += Alltrim(cFile) //Incrementa o nome do arquivo de geração
		elseIf SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" 
			cFileDest += Alltrim(cFile) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := DMAFilesTxt(cPathTxt, aFil)
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
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
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

// ----------------------------
static function DMAFilesTxt(cPathTxt, aFil)

	Local aRet	:=	{}
	Local nPos	:= 0

	For nPos := 1 To len(aFil)

		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO00.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO01.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO0809.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO1011.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO12.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO13.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO14.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO15.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO16.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO17.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO19.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO20.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO2122.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO3031.TXT"})
		AADD(aRet,{cPathTxt + aFil[nPos,1] + "_TIPO4092.TXT"})

	Next nPos

	AADD(aRet,{cPathTxt+"99.TXT"})

return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FNatOpUso

Tela de selação das naturezas de operação de uso e consumo para cfop 2.653

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FNatOpUso()
Local nOpc 		:= GD_INSERT+GD_UPDATE+GD_DELETE
Local aArea		:= GetArea()
Local aAlter 		:= {}

Private aColsGrid:= {}
Private aHeaGrid:= {}
Private oBrowNAT
Private oDlg1
Private noBrw := 0
Private lConfirm := .T.

MHoBrwNAT()
If !LoadProf( "DMA-BA_Grid1" , @aColsGrid ) //Leitura do Profile
	AADD(aColsGrid,Array(noBrw+1))
	aColsGrid[Len(aColsGrid)][1] := Replicate (" ", 10)
	aColsGrid[Len(aColsGrid)][2] := Replicate (" ", 6)
  	aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
EndIf


aAdd( aAlter, aHeaGrid[1,2] ) //Filial
aAdd(aAlter,aHeaGrid[2,2]) //Natureza de operação

oDlg1    := MSDialog():New( 091,232,502,820,"Naturezas de Operação de exceção para tipo 40, 50, 60, 66, 77 e 88",,,.F.,,,,,,.T.,,,.T. )

oBrowNAT := MsNewGetDados():New(024,016,216,368,nOpc,"vldLinUso()","AllwaysTrue",""      ,aAlter    ,000    ,999 ,"AllwaysTrue","","AllwaysTrue",oDlg1,aHeaGrid,aColsGrid)

oBrowNAT:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GrvGrid(1, oBrowNAT, aColsGrid),iif(lOk,oDlg1:End(),"")},{|| lConfirm := .F.,oDlg1:End()})
oDlg1:lCentered	:= .T.
oDlg1:Activate()

RestArea(aArea)

Return lConfirm

//-------------------------------------------------------------------
/*/{Protheus.doc} MHoBrwNAT

MHoBrwNAT() - Monta aHeaGrid da MsNewGetDados

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function MHoBrwNAT()

DbSelectArea("SX3")
DbSetOrder(1)

DbSeek("C30")
While !Eof() .and. SX3->X3_ARQUIVO == "C30"
	If Alltrim(SX3->X3_CAMPO) $ "C30_FILIAL"
 		noBrw++
		aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
	       	SX3->X3_TAMANHO,;
	       	SX3->X3_DECIMAL,;
	       	"vldFilGrid()",;
	       	"",;
	       	SX3->X3_TIPO,;
	       	SX3->X3_F3	,;					// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		    // 12 - Relacao
	Endif

	If Alltrim(SX3->X3_CAMPO) $ "C30_NATOPE"
 		noBrw++
		aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
       	SX3->X3_PICTURE,;
       	SX3->X3_TAMANHO,;
       	SX3->X3_DECIMAL,;
       	"validNatu(M->C30_NATOPE)",;
       	"",;
       	SX3->X3_TIPO,;
       	"consPdNat()"	,;				// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		   // 12 - Relacao
	Endif

	If Alltrim(SX3->X3_CAMPO) $ "C30_DNATOP"
 		noBrw++
		aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
       	SX3->X3_PICTURE,;
       	SX3->X3_TAMANHO,;
       	SX3->X3_DECIMAL,;
       	"",;
       	"",;
       	SX3->X3_TIPO,;
       	SX3->X3_F3	,;					// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		   // 12 - Relacao
	Endif
   DbSkip()
EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} vldLinUso

vldLinUso() - Realiza validação da linha na Tela de Uso e Consumo

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldLinUso
 Local lRet := .T.
 Local nY   := 0

 For nY := 1 to Len (aCols)
   If (aCols[nY][2] == aCols[n][2] .AND. aCols[nY][1] == aCols[n][1] .AND. n != nY .And. aCols[nY][4] == .F.)
     MSGALERT( "Natureza de Operação já informada para esta filial.", "Aviso" )
     Return .F.
   EndIf
 Next

 If (Empty(aCols[n][1]))
 	MSGALERT( "Filial não informada.", "Aviso" )
 	Return .F.
 EndIf

 If (Empty(aCols[n][2]))
 	MSGALERT( "Natureza de Operação não informada.", "Aviso" )
 	Return .F.
 EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldFilGrid

vldFilGrid() - Valida a natureza de operação informada

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  validNatu(cNatOper, cFil)
   Local lRet := .T.
   
   If(Empty(cFil))
      cFil := aCols[n][1]
   EndIf

	If(!Empty(cNatOper))
		DbSelectArea("C1N")
		DbSetOrder(3)
		If DbSeek(cFil+cNatOper)
			aCols[n][2] := C1N->C1N_ID
			aCols[n][3] := C1N->C1N_DESNAT
	   Else
	      MSGALERT( "Natureza de operação não cadastrada", "Aviso" )
	      lRet := .F.
	   EndIf
	EndIf

	oBrowNAT:oBrowse:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldFilGrid

vldFilGrid() - Valida a filial informada para a natureza de operação

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldFilGrid()
   Local lRet   :=  .T.

   If(Empty(M->C30_FILIAL))
   		MSGALERT( "Filial não informada.", "Aviso" )
   		Return .F.
   Else
	   lRet := FWFilExist(SM0->M0_CODIGO,M->C30_FILIAL)

	   If(lRet == .F.)
	   		MSGALERT( "Filial não cadastrada.", "Aviso" )
	   		Return lRet
	  	EndIf
   EndIf

   If(aScan(aFil,{|x| Alltrim( x[1] ) == Alltrim( M->C30_FILIAL )})) == 0
   		MSGALERT( "Filial não selecionada na etapa anterior.", "Aviso" )
   		Return .F.
   EndIf

	If(!validNatu(aCols[n][2],M->C30_FILIAL))
	  	  lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} consPdNat

consPdNat() - Chama a consulta padrão conforme a filial escolhida na coluna da grid

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  consPdNat()
	Local cBkpFil := cFilAnt

	If(!Empty(aCols[n][1]))
		cFilAnt := aCols[n][1]
	EndIf

	If CONPAD1(,,,"C1N")
		M->C30_NATOPE := C1N->C1N_ID
		M->C30_DNATOP := C1N->C1N_DESNAT

		aCols[n][1] := xFilial('C30')
		aCols[n][2] := M->C30_NATOPE
		aCols[n][3] := M->C30_DNATOP
	Endif

	cFilAnt := cBkpFil

	oBrowNAT:oBrowse:Refresh()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} vldGrid

vldGrid() - Realiza validação do Grid após o Confirm

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldGrid1
 Local lRet := .T.
 Local nY   := 0
 Local nX   := 0

 For nY := 1 to Len(oBrowNAT:Acols)
   If(!oBrowNAT:Acols[nY][4])
	   If ((Empty(oBrowNAT:Acols[nY][1]) 	.AND. !Empty(oBrowNAT:Acols[nY][2])) 	.or.;
	      (!Empty(oBrowNAT:Acols[nY][1]) 	.AND. Empty(oBrowNAT:Acols[nY][2])))
	 		MSGALERT( "Existe linha com filial, natureza de operação não informada.", "Aviso" )
	 		lRet := .F.
	 		Exit
	 	EndIf

	 	For nX := 1 to Len(oBrowNAT:Acols)
	 		If(!oBrowNAT:Acols[nX][4])
		 	    If(oBrowNAT:Acols[nX][1] == oBrowNAT:Acols[nY][1] .And. oBrowNAT:Acols[nX][2] == oBrowNAT:Acols[nY][2] .And. nX != nY)
		 	    	MSGALERT( "Existem linhas duplicadas.", "Aviso" )
		 			lRet := .F.
		 			Exit
		 	   EndIf
		 	EndIf
	 	Next

	 	If(!lRet)
	 		Exit
	 	EndIf
	 EndIf
 Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNatOpUso2

Tela de selação das naturezas de operação de uso e consumo para cfop 2.653

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FNatOpUso2()
Local nOpc 		:= GD_INSERT+GD_UPDATE+GD_DELETE
Local aArea		:= GetArea()
Local aAlter 		:= {}

Private aColsGrid2:= {}
Private aHeaGrid2:= {}
Private oBrowNAT2
Private oDlg2
Private noBrw2 := 0
Private lConfirm2 := .T.

MHoBrwNAT2()

If !LoadProf( "DMA-BA_Grid2" , @aColsGrid2 ) //Leitura do Profile
    AADD(aColsGrid2,Array(noBrw2+1))
	aColsGrid2[Len(aColsGrid2)][1] := Replicate (" ", 10)
	aColsGrid2[Len(aColsGrid2)][2] := Replicate (" ", 1)
	aColsGrid2[Len(aColsGrid2)][3] := Replicate (" ", 6)
  	aColsGrid2[Len(aColsGrid2),noBrw2+1]:=.F.
EndIf


aAdd( aAlter,aHeaGrid2[1,2] ) //Filial
aAdd(aAlter,aHeaGrid2[2,2]) //Tipo de Operação
aAdd(aAlter,aHeaGrid2[3,2]) //Natureza de operação

oDlg2    := MSDialog():New( 091,232,502,820,"Naturezas de Operação para operações dedutíveis e não-dedutíveis",,,.F.,,,,,,.T.,,,.T. )

oBrowNAT2 := MsNewGetDados():New(024,016,216,368,nOpc,"vldLinUso2()","AllwaysTrue",""      ,aAlter    ,000    ,999 ,"AllwaysTrue","","AllwaysTrue",oDlg2,aHeaGrid2,aColsGrid2)

oBrowNAT2:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg2:bInit 		:= EnchoiceBar(oDlg2,{||lOk:=GrvGrid(2, oBrowNAT2, aColsGrid2),iif(lOk,oDlg2:End(),"")},{|| lConfirm2 := .F.,oDlg2:End()})
oDlg2:lCentered	:= .T.
oDlg2:Activate()

RestArea(aArea)

Return lConfirm2

//-------------------------------------------------------------------
/*/{Protheus.doc} MHoBrwNAT2

MHoBrwNAT2() - Monta aHeaGrid2 da MsNewGetDados

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function MHoBrwNAT2()

DbSelectArea("SX3")
DbSetOrder(1)

DbSeek("C30")
While !Eof() .and. SX3->X3_ARQUIVO == "C30"
	If Alltrim(SX3->X3_CAMPO) $ "C30_FILIAL"
 		noBrw2++
		aAdd( aHeaGrid2, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"vldFiGrid2()",;
			"",;
			SX3->X3_TIPO,;
			SX3->X3_F3	,;					// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		    // 12 - Relacao
	Endif
	DbSkip()
EndDo

noBrw2++
aAdd( aHeaGrid2, { "Operação dedutível?",; // 01 - Titulo
		"Operac",;
		"",;
		1,;
		0,;
		"vldGridOp2(M->Operac)",;
		"",;
		"C",;
		""	,;				// 09 - F3
		"",;       	// 10 - Contexto
		"S=Sim;N=Não",; 	  	  	// 11 - ComboBox
		"xFRelacao()", } ) 		   // 12 - Relacao

DbSeek("C30")
While !Eof() .and. SX3->X3_ARQUIVO == "C30"
	If Alltrim(SX3->X3_CAMPO) $ "C30_NATOPE"
 		noBrw2++
		aAdd( aHeaGrid2, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"validNatu2(M->C30_NATOPE)",;
			"",;
			SX3->X3_TIPO,;
			"consPdNat2()"	,;				// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		   // 12 - Relacao
	Endif

	If Alltrim(SX3->X3_CAMPO) $ "C30_DNATOP"
 		noBrw2++
		aAdd( aHeaGrid2, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"",;
			"",;
			SX3->X3_TIPO,;
			SX3->X3_F3	,;					// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		   // 12 - Relacao
	Endif
   DbSkip()
EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} vldLinUso2

vldLinUso2() - Realiza validação da linha na Tela de Uso e Consumo

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldLinUso2
 Local lRet := .T.
 Local nY   := 0

 For nY := 1 to Len (aCols)
   If (aCols[nY][3] == aCols[n][3] .AND. aCols[nY][1] == aCols[n][1] .AND. n != nY .And. aCols[nY][5] == .F.)
     MSGALERT( "Natureza de Operação já informada para esta filial.", "Aviso" )
     Return .F.
   EndIf
 Next

 If (Empty(aCols[n][1]))
 	MSGALERT( "Filial não informada.", "Aviso" )
 	Return .F.
 EndIf

 If (Empty(aCols[n][2]))
 	MSGALERT( "Tipo de Operação não informada.", "Aviso" )
 	Return .F.
 EndIf

 If (Empty(aCols[n][3]))
 	MSGALERT( "Natureza de Operação não informada.", "Aviso" )
 	Return .F.
 EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldFiGrid2

vldFiGrid2() - Valida a natureza de operação informada

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  validNatu2(cNatOper, cFil)
   Local lRet := .T.

   If(Empty(cFil))
      cFil := aCols[n][1]
   EndIf

	If(!Empty(cNatOper))
		DbSelectArea("C1N")
		DbSetOrder(3)
		If DbSeek(cFil+cNatOper)
			aCols[n][3] := C1N->C1N_ID
			aCols[n][4] := C1N->C1N_DESNAT
	   Else
	      MSGALERT( "Natureza de operação não cadastrada", "Aviso" )
	      lRet := .F.
	   EndIf
	EndIf

	oBrowNAT2:oBrowse:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldGridOp2

vldGridOp2() - Valida a Tipo de operação informada

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldGridOp2(cTipo)
	Local lRet := .T.

	If(!Empty(cTipo))
		If(cTipo != "S" .AND. cTipo != "N")
			MSGALERT( "Tipo de operação inválida", "Aviso" )
			lRet := .F.
		EndIf
	EndIf

	oBrowNAT2:oBrowse:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldFiGrid2

vldFiGrid2() - Valida a filial informada para a natureza de operação

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldFiGrid2()
   Local lRet   := .T.

   If(Empty(M->C30_FILIAL))
   		MSGALERT( "Filial não informada.", "Aviso" )
   		Return .F.
   Else
	   lRet := FWFilExist(SM0->M0_CODIGO,M->C30_FILIAL)

	   If(lRet == .F.)
	   		MSGALERT( "Filial não cadastrada.", "Aviso" )
	   		Return lRet
	  	EndIf
   EndIf

   If(aScan(aFil,{|x| Alltrim( x[1] ) == Alltrim( M->C30_FILIAL ) })) == 0
   		MSGALERT( "Filial não selecionada na etapa anterior.", "Aviso" )
   		Return .F.
   EndIf

	If(!validNatu2(aCols[n][2],M->C30_FILIAL))
	  	  lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} consPdNat2

consPdNat2() - Chama a consulta padrão conforme a filial escolhida na coluna da grid

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  consPdNat2()
	Local cBkpFil := cFilAnt

	If(!Empty(aCols[n][1]))
		cFilAnt := aCols[n][1]
	EndIf

	If CONPAD1(,,,"C1N")
		M->C30_NATOPE := C1N->C1N_ID
		M->C30_DNATOP := C1N->C1N_DESNAT

		aCols[n][1] := xFilial('C30')
		aCols[n][3] := M->C30_NATOPE
		aCols[n][4] := M->C30_DNATOP
	Endif

	cFilAnt := cBkpFil

	oBrowNAT2:oBrowse:Refresh()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} vldGrid2

vldGrid2() - Realiza validação do Grid após o Confirm

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldGrid2
 Local lRet := .T.
 Local nY   := 0
 Local nX   := 0

 For nY := 1 to Len(oBrowNAT2:Acols)
   If(!oBrowNAT2:Acols[nY][5])
	   If ((Empty(oBrowNAT2:Acols[nY][1]) 	.AND. !Empty(oBrowNAT2:Acols[nY][2])) 	.or. (!Empty(oBrowNAT2:Acols[nY][1]) 	.AND. Empty(oBrowNAT2:Acols[nY][2])) .OR. ;
		   (Empty(oBrowNAT2:Acols[nY][1]) 	.AND. !Empty(oBrowNAT2:Acols[nY][3])) 	.or. (!Empty(oBrowNAT2:Acols[nY][1]) 	.AND. Empty(oBrowNAT2:Acols[nY][3])) .OR. ;
		   (Empty(oBrowNAT2:Acols[nY][2]) 	.AND. !Empty(oBrowNAT2:Acols[nY][3])) 	.or. (!Empty(oBrowNAT2:Acols[nY][2]) 	.AND. Empty(oBrowNAT2:Acols[nY][3])))
	 		MSGALERT( "Existe linha com filial, tipo de operação ou natureza de operação não informada.", "Aviso" )
	 		lRet := .F.
	 		Exit
	 	EndIf

	 	For nX := 1 to Len(oBrowNAT2:Acols)
	 		If(!oBrowNAT2:Acols[nX][5])
		 	    If(oBrowNAT2:Acols[nX][1] == oBrowNAT2:Acols[nY][1] .And. oBrowNAT2:Acols[nX][2] == oBrowNAT2:Acols[nY][2] .And. oBrowNAT2:Acols[nX][3] == oBrowNAT2:Acols[nY][3] .And. nX != nY)
		 	    	MSGALERT( "Existem linhas duplicadas.", "Aviso" )
		 			lRet := .F.
		 			Exit
		 	   EndIf
		 	EndIf
	 	Next

	 	If(!lRet)
	 		Exit
	 	EndIf
	 EndIf
 Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNatOpUso3

Tela de selação das naturezas de operação de uso e consumo para cfop 2.653

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FNatOpUso3()
Local nOpc 		:= GD_INSERT+GD_UPDATE+GD_DELETE
Local aArea		:= GetArea()
Local aAlter 		:= {}

Private aColsGrid3:= {}
Private aHeaGrid3:= {}
Private oBrowNAT3
Private oDlg3
Private noBrw3 := 0
Private lConfirm3 := .T.

MHoBrwNAT3()
If !LoadProf( "DMA-BA_Grid3" , @aColsGrid3 ) //Leitura do Profile
    AADD(aColsGrid3,Array(noBrw3+1))
	aColsGrid3[Len(aColsGrid3)][1] := Replicate (" ", 8)
	aColsGrid3[Len(aColsGrid3)][2] := Replicate (" ", 6)
	aColsGrid3[Len(aColsGrid3)][3] := Replicate (" ", 7)
	aColsGrid3[Len(aColsGrid3)][4] := 0
	aColsGrid3[Len(aColsGrid3),noBrw3+1]:=.F.
EndIf

aAdd(aAlter,aHeaGrid3[1,2]) //Filial
aAdd(aAlter,aHeaGrid3[2,2]) //Número de empregados
aAdd(aAlter,aHeaGrid3[3,2]) //Valor COFINS recolhimento

oDlg3    := MSDialog():New( 091,232,502,820,"Informações Complementares DMA-BA",,,.F.,,,,,,.T.,,,.T. )

oBrowNAT3 := MsNewGetDados():New(024,016,216,368,nOpc,"vldLinUso3()","AllwaysTrue","",aAlter,000,999 ,"AllwaysTrue","","AllwaysTrue",oDlg3,aHeaGrid3,aColsGrid3)

oBrowNAT3:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg3:bInit 		:= EnchoiceBar(oDlg3,{||lOk:=GrvGrid(3, oBrowNAT3, aColsGrid3),iif(lOk,oDlg3:End(),"")},{|| lConfirm3 := .F.,oDlg3:End()})
oDlg3:lCentered	:= .T.
oDlg3:Activate()

RestArea(aArea)

Return lConfirm3

//-------------------------------------------------------------------
/*/{Protheus.doc} MHoBrwNAT3

MHoBrwNAT3() - Monta aHeaGrid3 da MsNewGetDados

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function MHoBrwNAT3()

DbSelectArea("SX3")
DbSetOrder(1)

DbSeek("C30")
While !Eof() .and. SX3->X3_ARQUIVO == "C30"
	If Alltrim(SX3->X3_CAMPO) $ "C30_FILIAL"
 		noBrw3++
		aAdd( aHeaGrid3, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"vldFiGrid3()",;
			"",;
			SX3->X3_TIPO,;
			SX3->X3_F3	,;				// 09 - F3
		 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
		 	SX3->X3_CBOX		,; 	  	// 11 - ComboBox
	    	"xFRelacao()", } ) 		    // 12 - Relacao
	Endif
	DbSkip()
EndDo

noBrw3++
aAdd( aHeaGrid3, { "Número de Empregados",; // 01 - Titulo
		"nEmpreg",;
		"999999",;
		6,;
		0,;
		"",;
		"",;
		"C",;
		""	,;		// 09 - F3
		"",;      	// 10 - Contexto
		"",; 	  	// 11 - ComboBox
		"", } ) 	// 12 - Relacao


noBrw3++
aAdd( aHeaGrid3, { "Valor Recolhido a COFINS",; // 01 - Titulo
		"nCofins",;
		"@E 999,999,999.99",;
		11,;
		2,;
		"",;
		"",;
		"N",;
		""	,;		// 09 - F3
		"R",;    	// 10 - Contexto
		"",; 	  	// 11 - ComboBox
		"", } ) 	// 12 - Relacao

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} vldLinUso3

vldLinUso3() - Realiza validação da linha na Tela de Uso e Consumo

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldLinUso3
 Local nY   := 0

 For nY := 1 to Len (aCols)
   If (aCols[nY][1] == aCols[n][1] .AND. n != nY .And. aCols[nY][5] == .F.)
     MSGALERT( "Filial já informada.", "Aviso" )
     Return .F.
   EndIf
 Next

 If (Empty(aCols[n][1]))
 	MSGALERT( "Filial não informada.", "Aviso" )
 	Return .F.
 EndIf

Return .T. //lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldFiGrid3

vldFiGrid3() - Valida a filial informada para a natureza de operação

@Author Jean Espindola
@Since 10/05/3016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldFiGrid3()
	Local lRet   := .T.

	If(Empty(M->C30_FILIAL))
   		MSGALERT( "Filial não informada.", "Aviso" )
   		Return .F.
	Else
		lRet := FWFilExist(SM0->M0_CODIGO,M->C30_FILIAL)

		If(lRet == .F.)
	   		MSGALERT( "Filial não cadastrada.", "Aviso" )
	   		Return lRet
	  	EndIf
	EndIf

	If(aScan(aFil,{|x| x[1] == M->C30_FILIAL})) == 0
   		MSGALERT( "Filial não selecionada na etapa anterior.", "Aviso" )
   		Return .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldGrid3

vldGrid3() - Realiza validação do Grid após o Confirm

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function  vldGrid3
 Local lRet := .T.
 Local nY   := 0
 Local nX   := 0

 For nY := 1 to Len(oBrowNAT3:Acols)
   If(!oBrowNAT3:Acols[nY][4])
	 	For nX := 1 to Len(oBrowNAT3:Acols)
	 		If(!oBrowNAT3:Acols[nX][4])
		 	    If(oBrowNAT3:Acols[nX][1] == oBrowNAT3:Acols[nY][1] .And. nX != nY)
		 	    	MSGALERT( "Existem linhas duplicadas.", "Aviso" )
		 			lRet := .F.
		 			Exit
		 	   EndIf
		 	EndIf
	 	Next

	 	If(!lRet)
	 		Exit
	 	EndIf
	 EndIf
 Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvGrid

Grava informações da GRID no Profile

@Param

@Return

@Author Jean Espindola
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GrvGrid(nGrid, oBrowser, aColsG)
Local nTamACOLS	:= 0
local nL      		:= 0
Local lRet 		:= .T.

Local 	cWrite		:= 	""
Local	cBarra		:= 	If ( IsSrvUnix () , "/" , "\" )
Local	cUserName	:= __cUserID
Local  lUtil  as logical
Local  lColUm as character
Local nTam1 := 0
Local nTam2 := 0
Local nTam3 := 0
Local nTam4 := 0

Begin Transaction

 	aSort(oBrowser:Acols,,,{|x,y| x[1] < y[1]})

	nTamACOLS := len( oBrowser:Acols )
	nTamAGrid := len( aColsG )

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	If nGrid == 1
		If (vldGrid1())

			nTam1 := oBrowser:aHeader[1][4]
			nTam2 := oBrowser:aHeader[2][4]
			nTam3 := oBrowser:aHeader[3][4]

			For nL:=1 To Len(oBrowser:aCols)
			
			lUtil  := oBrowser:aCols[nL, 4]
			lColUm := AllTrim(oBrowser:aCols[nL, 1])
			
				If !lUtil .AND. !Empty(lColUm) //Testa de a linha da Grid não esta deletada
					cWrite 	+= "{GRID}" + CRLF
					cWrite 	+= "{OBJ001;C;" + StrZero( nTam1, 3 ) + "}"  + oBrowser:aCols[nL,1] + CRLF
					cWrite 	+= "{OBJ002;C;" + StrZero( nTam2, 3 ) + "}"  + oBrowser:aCols[nL,2] + CRLF
					cWrite 	+= "{OBJ003;C;" + StrZero( nTam3, 3 ) + "}"  + oBrowser:aCols[nL,3] + CRLF
					cWrite 	+= "{OBJ004;L;001}"  + Iif ( !oBrowser:aCols[nL,4] , "F" , "T" ) + CRLF
					AADD(aArrayExc, {oBrowser:aCols[nL,1], oBrowser:aCols[nL,2]})
				EndIf
			Next nL
			cNomeWizard	:=	"DMA-BA_Grid1"+"_"+cUserName
			MemoWrit ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )
		Else
			lRet := .F.
		EndIf
	ElseIf nGrid == 2
		If (vldGrid2())

			nTam1 := oBrowser:aHeader[1][4]
			nTam2 := oBrowser:aHeader[2][4]
			nTam3 := oBrowser:aHeader[3][4]
			nTam4 := oBrowser:aHeader[4][4]
		
			For nL:=1 To Len(oBrowser:aCols)
			
				lUtil  := oBrowser:aCols[nL, 5]
				lColUm := AllTrim(oBrowser:aCols[nL, 1])
			
				If !lUtil .AND. !Empty(lColUm) //Testa de a linha da Grid não esta deletada				
					cWrite 	+= "{GRID}" + CRLF
					cWrite 	+= "{OBJ001;C;" + StrZero( nTam1, 3 ) + "}"  + oBrowser:aCols[nL,1] + CRLF
					cWrite 	+= "{OBJ002;C;" + StrZero( nTam2, 3 ) + "}"  + oBrowser:aCols[nL,2] + CRLF
					cWrite 	+= "{OBJ003;C;" + StrZero( nTam3, 3 ) + "}"  + oBrowser:aCols[nL,3] + CRLF
					cWrite 	+= "{OBJ004;C;" + StrZero( nTam4, 3 ) + "}"  + oBrowser:aCols[nL,4] + CRLF
					cWrite 	+= "{OBJ005;L;001}"  + Iif ( !oBrowser:aCols[nL,5] , "F" , "T" ) + CRLF
					AADD(aArrayDed, {oBrowser:aCols[nL,1], oBrowser:aCols[nL,2], oBrowser:aCols[nL,3]})
				EndIf
			Next nL
			cNomeWizard	:=	"DMA-BA_Grid2"+"_"+cUserName
			MemoWrit ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )
		Else
			lRet := .F.
		EndIf
	Else
		If (vldGrid3())
			For nL:=1 To Len(oBrowser:aCols)
			
				lUtil  := oBrowser:aCols[nL, 4]
				lColUm := AllTrim(oBrowser:aCols[nL, 1])
			
				If !lUtil .AND. !Empty(lColUm) //Testa de a linha da Grid não esta deletada
				
					cWrite 	+= "{GRID}" + CRLF
					cWrite 	+= "{OBJ001;C;008}"  + oBrowser:aCols[nL,1] + CRLF
					cWrite 	+= "{OBJ002;C;006}"  + oBrowser:aCols[nL,2] + CRLF
					cWrite 	+= "{OBJ003;N;013}"  + cValToChar(oBrowser:aCols[nL,3]) + CRLF
					cWrite 	+= "{OBJ004;L;001}"  + Iif ( !oBrowser:aCols[nL,4] , "F" , "T" ) + CRLF
					AADD(aArrayCpl, {oBrowser:aCols[nL,1], oBrowser:aCols[nL,2], cValToChar(oBrowser:aCols[nL,3])})
				EndIf
			Next nL
			cNomeWizard	:=	"DMA-BA_Grid3"+"_"+cUserName
			MemoWrit ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )
		Else
			lRet := .F.
		EndIf
	EndIF

End Transaction

Return  lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadProf
Funcao que carrega os parametros no profile Das Gris para DMA-BA

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
			aParametros - Array com o conteudo do arquivo texto do Wizard (RETORNO POR REFERENCIA)

@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Marcos Buschmann
@since 16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function LoadProf ( cNomeWizard , aIniWiz )
Local 	nJ			:=	0
Local	nI			:=	0
Local 	cBarra 	:= 	Iif ( IsSrvUnix() , "/" , "\" )
Local	cTipo		:=	""
Local	nPadR		:=	0
Local	cLinha		:=	""
Local	lRet		:=	.F.
Local	cUserName	:= __cUserID

If !ExistDir ( cBarra + "PROFILE" + cBarra )
	Makedir ( cBarra + "PROFILE" + cBarra )
EndIf

cNomeWizard	:=	cNomeWizard+"_"+cUserName
If File ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" )

	If FT_FUse ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" ) <> -1
		FT_FGoTop ()
		While ( !FT_FEof () )
			cLinha	:=	FT_FReadLn ()
			If ( "GRID" $ cLinha )
				aAdd ( aIniWiz , {} )
			Else
				aAdd ( aIniWiz[Len ( aIniWiz )] , cLinha )
			EndIf
			FT_FSkip ()
		Enddo
		FT_FUse ()

		For nJ := 1 To Len ( aIniWiz )
			For nI := 1 To Len ( aIniWiz[nJ] )

				If (SubStr (aIniWiz[nJ][nI], 8, 1)==";")

					cTipo	:=	SubStr ( aIniWiz[nJ][nI] , 9 , 1 )
					nPadR	:=	Val ( SubStr (aIniWiz[nJ][nI] , 11 , 3 ) )
					cLinha	:=	SubStr ( aIniWiz[nJ][nI] , 15 , nPadR )

					Do case
						Case cTipo == "L"
							aIniWiz[nJ][nI]	:= 	Iif ( cLinha == "F" , .F. , .T. )

						Case cTipo == "D"
							aIniWiz[nJ][nI]	:= 	SToD ( cLinha )

						Case cTipo == "N"
							aIniWiz[nJ][nI]	:= 	Val ( cLinha )

						OtherWise
							aIniWiz[nJ][nI]	:=	cLinha
					EndCase

				Else
					aIniWiz[nJ][nI]	:=	SubStr ( aIniWiz[nJ][nI] , 9 )
				EndIf
			Next nI
		Next nJ

		lRet		:=	.T.
	EndIf
EndIf

Return  lRet

Static Function valWizard(aWizard)

Local cData := DtoS(aWizard[2][5])

	IF(Trim(cData) == "")
		Aviso( "Atenção!", "O campo 'Data de Encerramendo' é obrigatório!", { "Sair" } )
		Return .F.
	EndIf
Return .T.


