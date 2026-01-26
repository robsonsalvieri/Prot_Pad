#Include 'Protheus.ch'
#Define cObrig "DFC-PR"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDFPR

Esta rotina tem como objetivo a geracao do Arquivo DFC-PR

@Author Marcos Buschmann
@Since 11/12/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDFPR()
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

Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

//Cria objeto de controle do processamento
oProcess := TAFProgress():New( { |lEnd| ProcDfcPr( @lEnd, @oProcess, cNomWiz ) }, "Processando DFC-PR" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcDfcPr

Inicia o processamento para geracao da DFC-PR


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario 
		oProcess  -> Objeto da barra de progresso da emissao da DFC-PR 
		cNomWiz   -> Nome da Wizard criada para a DFC-PR

       
@Return ( Nil )

@Author Marcos Buschmann
@Since 11/12/2015
@Version 1.0
*/

Static Function ProcDfcPr( lEnd, oProcess, cNomWiz )

Local cErrorDECL	:=	""
Local cErrorTrd	:=	""
Local nProgress1	:=	0
Local aWizard		:=	{}
Local aJobAux		:=	{}
Local lProc		:=	.T.
Local nCont   	:= 0

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf


If lProc
		

	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )
	oProcess:Inc1Progress( "Executando o Processamento...")
	
	//Geração DFC-PR
	TAFDFC0002(aWizard, @nCont)
	TAFDFC0001(aWizard, @nCont)
	
	//Marcos Buschmann
	//TAFDE0100(aWizard)
	//TAFDE0200(aWizard, @nValor, @nCont)
	//TAFDE0300(aWizard, @nValor, @nCont)
	//TAFDE0400(aWizard, @nValor, @nCont)
	//TAFDE0500(aWizard, @nValor, @nCont)
	//TAFDE9999(aWizard, @nValor, @nCont)

Else
	oProcess:Inc1Progress( "Processamento cancelado" )
	oProcess:Inc2Progress( "Clique em Finalizar" )
	oProcess:nCancel = 1

EndIf

//Tratamento para quando o processamento tem problemas
If oProcess:nCancel == 1 .or. !Empty( cErrorDECL ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorDECL := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorDECL, 2, Len( cErrorDECL ) )
		cErrorDECL += "da DECL-RJ " + Chr( 10 ) + Chr( 10 )
		cErrorDECL += "Favor efetuar o reprocessamento da DECL-RJ, caso o erro persista entre em contato "
		cErrorDECL += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorDECL, { "Sair" } )

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
/*/{Protheus.doc} getObrigParam

@author Marcos Buschmann
@since	11/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens0	:= {}
	Local	aItens1	:= {}
	
	Local	cTitObj1	:= ""
	Local	aRet		:= {}

	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético DFC-PR.")

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ
//aAdd (aPaineis[nPos][3], {0,"",,,,,,}) Coluna de espaços


	aAdd (aPaineis, {})
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DFC-PR - Registro 0001.")
	aAdd (aPaineis[nPos], {})


	//Coluna1																//Coluna 2
	cTitObj1	:=	"Diretório do Arquivo Destino";						cTitObj2	:=	"Nome do Arquivo Destino"    
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})		

	cTitObj1	:=	Replicate ("X", 100);					    		cTitObj2	:=	Replicate ("X", 100)           
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
                                                        
	cTitObj1	:=	"Tipo de documento";									cTitObj2	:=	"Selecione Filiais:"			
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
                                                                                                                                                               
	aAdd (aItens1, "21 - Normal");										aAdd (aItens0, "0 - Não")                     
	aAdd (aItens1, "22 - Retificação");								aAdd (aItens0, "1 - Sim")
	aAdd (aItens1, "24 - Baixa")										
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});                aAdd (aPaineis[nPos][3], {3,,,,,aItens0,,,,,})   
														            		
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	
	cTitObj1	:=	"Ano Referência:"	;									cTitObj2	:=  "Contabilista:" //ComboBox   		
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	
	cTitObj1	:=	Replicate ("X", 04);                           	cTitObj2	:=	Replicate ("X", 36)                                  
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,4});           	   aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )                     

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	aAdd(aRet , aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDFPR() } )	
	
	

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDFC

Geracao do Arquivo TXT da DFC-PR. Gera o arquivo dos registros e arquivo 
consolidado

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DFC
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Marcos Buschmann
@Since 11/12/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDFPR( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "DFCPR" )
Local	cFileDest		:=	""
Local	nRetDir		:=	.T.
Local	lRet			:=	.T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )
	
	nRetDir := FWMakeDir( cDirName )

	if !nRetDir

		cDirName	:=	""
		
		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\DFCPR. Erro: " + cValToChar( FError() ) , 1, 0 )
		
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

Geracao do Arquivo TXT da DFC-PR. Gera o arquivo dos registros e arquivo 
consolidado

@Return ( Nil )

@Author Marcos Buschmann
@Since 11/12/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	TAFGetPath( "2" , "DFCPR" )		                  //diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" )
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" )
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := DFCLFiles(cPathTxt)
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

Return( lRet )

// ----------------------------
static function DFCLFiles(cPathTxt)

Local aRet	:=	{}

	AADD(aRet,{cPathTxt+"1.TXT"})
	AADD(aRet,{cPathTxt+"2.TXT"})
	
	//Marcos Buschmann
	//AADD(aRet,{cPathTxt+"0100.TXT"})
	//AADD(aRet,{cPathTxt+"0200.TXT"})
	//AADD(aRet,{cPathTxt+"0300.TXT"})
	//AADD(aRet,{cPathTxt+"0400.TXT"})
	//AADD(aRet,{cPathTxt+"0500.TXT"})
	//AADD(aRet,{cPathTxt+"9999.TXT"})

return( aRet )


