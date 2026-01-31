#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "tafxdiap.ch"

#Define cObrig "DIAP"


//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDIAP

Esta rotina tem como objetivo a geracao do Arquivo DIAP

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDIAP()
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
   oProcess := TAFProgress():New( { |lEnd| ProcDIAP( @lEnd, @oProcess, cNomWiz ) }, STR0001 ) //"Processando DIAP" 
   oProcess:Activate()

   //Limpando a memória
   DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcDIAP

Inicia o processamento para geracao da DIAP


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da DIAP
	   cNomWiz   -> Nome da Wizard criada para a GIA

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------


Static Function ProcDIAP( lEnd, oProcess, cNomWiz )


Local cErrorDIAP	as char
Local cErrorTrd	 	as char

Local nI			as Numeric
Local nX			as Numeric
Local nPos			as Numeric
Local nProgress1	as Numeric


Local aJobAux		as Array
Local lProc			as Logical

//Variáveis de Thread
Local cSemaphore	as Char
Local cJobAux    	as Char
Local nQtdThread	as Numeric
Local lMultThread	as Logical

Private aFil 		as Array
Private nSeqDIAP	as Numeric

//**********************
// INICIALIZA VARIÁVEIS
//**********************

cErrorDIAP	:= ""
cErrorTrd	:= ""

nSeqDIAP 	:= 1
nI			:= 0
nX			:= 0
nPos		:= 0
nProgress1	:= 0

aJobAux		:= {}
lProc		:= .T.

//Variáveis de Thread
cJobAux    	:= ""
cSemaphore	:= ""
nQtdThread	:= 0
lMultThread	:= .F.

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

If lProc


	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( STR0003 ) //"Preparando o Ambiente..." 
	oProcess:Inc1Progress( STR0004 ) //"Executando o Processamento..."	

	//************************************************************************
	//Geração DIAP - Aqui vão a chamada das funções da geração dos registros
	TAFDIAPPR(aWizard)  //Registro principal
	If !("3" $ aWizard[1, 5]) 
		TAFDIAPMV(aWizard)  //Moviemntações de Entrada/Saída
		TAFDIAPAJ(aWizard)  //Ajustes
	EndIf
	
	If ("1" $ aWizard[2,3]) //Gerar Movimentações Interestaduais
		TAFDIAPUF(aWizard)  //Entradas/Saída por UF
	EndIf	

	If !("3" $ aWizard[1, 5]) 
		TAFDIAPIS(aWizard)  //Isenções
		
		/* INFORMAÇÕES DA IMPORTAÇÃO*/
		If ("1" $ aWizard[2,6]) //Gerar Informações de Importação
			TAFDIAPDI(aWizard)  //Declaração de Importação
		EndIf
	EndIf
	
	//************************************************************************
	//********* FIM da chamada das função da geração dos registros **********
	//************************************************************************
	
Else
	oProcess:Inc1Progress( STR0005 ) //"Processamento cancelado" 
	oProcess:Inc2Progress( STR0006 ) //"Clique em Finalizar" 
	oProcess:nCancel = 1

EndIf

//Tratamento para quando o processamento tem problemas
If oProcess:nCancel == 1 .or. !Empty( cErrorDIAP ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( STR0007, STR0008, { STR0009 } ) //"Atenção!" "A geração do arquivo foi cancelada com sucesso!" "Sair"

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( STR0007, cErrorTrd, { STR0009 } ) //"Atenção!" "Sair"

	//Erro na execução dos Blocos
	Else

		cErrorDIAP := STR0010 + SubStr( cErrorDIAP, 2, Len( cErrorDIAP ) ) //"Ocorreu um erro fatal durante a geração do(s) Registro(s) " 
		cErrorDIAP += STR0011 + Chr( 10 ) + Chr( 10 ) //"da DIAP " 
		cErrorDIAP += STR0012 //"Favor efetuar o reprocessamento da DIAP, caso o erro persista entre em contato "
		cErrorDIAP += STR0013 + Chr( 10 ) + Chr( 10 ) //"com o administrador de sistemas suporte Totvs" 

		Aviso( STR0007, cErrorDIAP, { STR0009 } ) //"Atenção!" "Sair"

	EndIf

Else

	//Atualizando a barra de processamento
	oProcess:Inc1Progress( STR0014 ) //"Informações processadas" 
	oProcess:Inc2Progress( STR0015 ) //"Consolidando as informações e gerando arquivo..." 

	If GerTxtCons( aWizard )
		//Atualizando a barra de processamento
		oProcess:Inc2Progress( STR0017 ) //"Arquivo gerado com sucesso."
		msginfo( STR0017 ) //"Arquivo gerado com sucesso!"
	Else
		oProcess:Inc2Progress( STR0018 ) //"Falha na geração do arquivo." 
	EndIf


EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	 := cObrig+FWGETCODFILIAL
	Local 	cNomeAnt := ""
	Local	aTxtApre := {}
	Local	aPaineis := {}
	
	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens4	:= {}
	Local	aItens5	:= {}

	Local	cTitObj1	:= ""
	Local	aRet		:= {}

	aAdd (aTxtApre, STR0019 ) //"Processando Empresa."
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0020 ) //"Preencha corretamente as informações solicitadas."
	aAdd (aTxtApre, STR0021 ) //"Informações necessárias para a geração do meio-magnético DIAP."

	//
	//Painel 0
	//

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0022 ) //"Preencha corretamente as informações solicitadas - INFORMAÇÕES DA DIAP.")
	aAdd (aPaineis[nPos], STR0023 ) //"Informações necessáas para a geração do meio-magnético DIAP.")
	aAdd (aPaineis[nPos], {})
	
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1 := STR0024 //"Diretório do Arquivo Destino"
	cTitObj2 := STR0025 //"Nome do Arquivo Destino"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( "X", 50 )
	cTitObj2 := Replicate( "X", 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,,, { "xFunVldWiz", "ECF-DIRETORIO" } } )
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,,,,} )

	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aItens1, STR0026 ) //"1 - Padrão")
	aAdd (aItens1, STR0027 ) //"2 - Paralisação para Conclusão de Baixa")
	aAdd (aItens1, STR0028 ) //"3 - Paralisação Temporária")
	aAdd (aItens1, STR0029 ) //"4 - Reativação de Atividades")
	aAdd (aItens1, STR0030 ) //"5 - Mudançaa de Domicílio Fiscal")
	aAdd (aItens1, STR0031 ) //"6 - Mudança de Regime")
	
	aAdd (aItens2, STR0032 ) //"1 - Original")
	aAdd (aItens2, STR0033 ) //"2 - Retificadora")
	
	aAdd (aItens3, STR0034 ) //"1 - Mensal")
	aAdd (aItens3, STR0035 ) //"2 - Trimestral")
	aAdd (aItens3, STR0036 ) //"3 - Anual")
	
	aAdd (aItens4, STR0037 ) //"0 - Não")
	aAdd (aItens4, STR0038 ) //"1 - Sim")	
	
	aAdd (aItens5, STR0039 ) //"601	Amapa")
	aAdd (aItens5, STR0040 ) //"603	Calcoene")
	aAdd (aItens5, STR0041 ) //"605	Macapa")
	aAdd (aItens5, STR0042 ) //"607	Mazagão")
	aAdd (aItens5, STR0043 ) //"609	Oiapoque")
	aAdd (aItens5, STR0044 ) //"610	Vitória do Jari")
	aAdd (aItens5, STR0045 ) //"611	Ferreira Gomes")
	aAdd (aItens5, STR0046 ) //"613	Laranjal do Jari")
	aAdd (aItens5, STR0047 ) //"615	Santana")
	aAdd (aItens5, STR0048 ) //"617	Tartarugalzinho")
	aAdd (aItens5, STR0049 ) //"663	Amapari")
	aAdd (aItens5, STR0050 ) //"665	Serra do Navio")
	aAdd (aItens5, STR0051 ) //"667	Cutias do Araguary")
	aAdd (aItens5, STR0052 ) //"669	Itaubal do Piririm")
	aAdd (aItens5, STR0053 ) //"671	Porto Grande")
	aAdd (aItens5, STR0054 ) //"673	Pracuuba")
	aAdd (aItens5, STR0055 ) //"699	Nenhum")
	
	//"Motivo"                                             //"Tipo DIAP"
	cTitObj1 :=	STR0056; 								   cTitObj2 := STR0057 						
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );		   aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )
	aAdd (aPaineis[nPos,3], { 3,,,,,aItens1,,,,,});		   aAdd (aPaineis[nPos,3], { 3,,,,,aItens2,,,,,})	
	
	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 
	
	//"Periodicidade"
	cTitObj1 := STR0058 								
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );			aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	aAdd (aPaineis[nPos,3], { 3,,,,,aItens3,,,,,});			aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
		
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

//---------------------------------------------------------------------------------------------------------------

	//"Período Inicial"                                   //"Período Final"
	cTitObj1 := STR0059;                                   cTitObj2 := STR0060 
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );		  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});				  aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	
	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				  aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 
	
	//"Município Origem"                                  //"Município Destino"
	cTitObj1 := STR0061; 		                          cTitObj2 := STR0062 	
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );		  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	aAdd (aPaineis[nPos,3], { 3,,,,,aItens5,,,,,});		  aAdd (aPaineis[nPos,3], { 3,,,,,aItens5,,,,,})	
	
	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				  aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				  aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
//---------------------------------------------------------------------------------------------------------------	

//--------------------------------------------------------------------------------------------------------------------------------------------------//
//PAINEL 2

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)	
	aAdd (aPaineis[nPos], STR0022 ) //"Preencha corretamente as informações solicitadas - INFORMAÇÕES DA DIAP.")
	aAdd (aPaineis[nPos], STR0023 ) //"Informações necessáas para a geração do meio-magnético DIAP.")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//

	//"Houve Movimentação de Entrada/Saída?"                       //"Houve Reduãoo de Base Cálculo?"
	cTitObj1 := STR0063;                                  cTitObj2 := STR0064 
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});		  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,});       aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})
	
	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				  aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 
		
	//"Houve Operações Interestadual?"                    //"Houve Movimentação de Estoque?"
	cTitObj1 := STR0065;                                  cTitObj2 := STR0066
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});		  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,});       aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})

	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				  aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	//"Gerar Informações GIA-ST?"                         //"Gerar Informações de Importação?"
	cTitObj1 := STR0067;                                  cTitObj2 := STR0068 		
    aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});        aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
    aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,});		  aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})

	//Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					 aAdd (aPaineis[nPos][3], {0,"",,,,,,})
									
//---------------------------------------------------------------------------------------------------------------

	//"Cadastro de Compl. Fiscais" 
	cTitObj1 := STR0069 
    aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )				  
    aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 

    //"Abrir Programa"
    cTitObj1 := STR0070 
    cAction 	:= "TAFA456('000016')"
    aAdd( aPaineis[nPos,3], { 7, cTitObj1,,,,,,,,,,,,,,, cAction } ); aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    aAdd (aPaineis[nPos][3], {0,"",,,,,,});							  aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//---------------------------------------------------------------------------------------------------------------

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDIAP() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDIAP

Geracao do Arquivo TXT da DIAP.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DIAP
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDIAP( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "DIAP" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, STR0071 + " \\Obrigacoes_TAF\DIAP. Erro: " + cValToChar( FError() ) , 1, 0 )  

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

Geracao do Arquivo TXT da DIAP. Gera o arquivo dos registros e arquivo
consolidado

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt		:=	TAFGetPath( "2" , "DIAP" )			                 	//diretorio onde foram gerados os arquivos txt temporarios
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
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geraçãoo
		EndIf
	EndIf

	aFiles := DIAPFilesTxt(cPathTxt)
	for nx := 1 to Len( aFiles )

		//Verifica se o arquivo foi encontrado no diretorio
		if File( aFiles[nx][1] )

			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()					//POSICIONO NO TOPO

			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
	   			
	   			IF(len(cBuffer) == 1023)
	   				cStrTxtFIM += cBuffer	   			
	   			Else
	   				cStrTxtFIM += cBuffer  + CRLF
	   			EndIf
				FT_FSKIP()
			endDo
			FT_FUSE()
			FERASE( aFiles[nx][1] )
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".txt"
	EndIf

	WrtStrTxt( nHandle, cStrTxtFIM )

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} DIAPFilesTxt

DIAPFilesTxt() - Arquivos por bloco da GIA

@Author Jean Espindola
@Since 06/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function DIAPFilesTxt( cPathTxt )

Local aRet	:=	{}

	AADD(aRet,{cPathTxt + "_DIPR.TXT"}) //Principal
	AADD(aRet,{cPathTxt + "_MVES.TXT"}) //Movimentações de Entradas e Saídas
	AADD(aRet,{cPathTxt + "_DIAJ.TXT"}) //Ajustes Apuração
	AADD(aRet,{cPathTxt + "_DIUF.TXT"}) //Movimentações de Entradas e Saídas por UF
	AADD(aRet,{cPathTxt + "_DIIS.TXT"}) //Isenções
	AADD(aRet,{cPathTxt + "_DIDI.TXT"}) //Declaração de Importação

Return( aRet )
