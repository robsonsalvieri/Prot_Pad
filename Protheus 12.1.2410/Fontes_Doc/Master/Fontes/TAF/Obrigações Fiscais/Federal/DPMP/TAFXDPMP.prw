#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "TAFXDPMP.ch"

#Define cObrig "DPMP"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDPMP

Esta rotina tem como objetivo a geracao do Arquivo DPMP

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDPMP()

	Local cNomWiz   as char
	Local lEnd      as logical
	Local cFunction as char
	Local nOpc      as numeric

	Local cCode		:= "LS006"
	Local cUser		:= RetCodUsr()
	Local cModule	:= "84"
	Local cRoutine  := ProcName()

	Private oProcess 	as object
	Private dInicial    as date
	Private dFinal      as date
	Private cCodRegAnp  as char
	Private aListaProd  as array
	Private lCancel     as logical

	cNomWiz    	:= cObrig + FWGETCODFILIAL
	lEnd       	:= .F.
	lCancel     := .F.
	oProcess 	:= Nil
	cFunction 	:= ProcName()
	nOpc      	:= 2 //View

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

	//Protect Data / Log de acesso / Central de Obrigacoes
	Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

	//Cria objeto de controle do processamento
	oProcess := TAFProgress():New( { |lEnd| ProcDPMP( @lEnd, @oProcess, cNomWiz ) }, STR0001 ) //Processando DPMP
	oProcess:Activate()

	If !lCancel
		If (MSGYESNO( STR0047, STR0003)) //Deseja gerar o relatório de conferência?
			TDPMPRelat()
		EndIf
	EndIf

	//Limpando a memória
	DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcDPMP

Inicia o processamento para geracao da DPMP


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da DPMP
	   cNomWiz   -> Nome da Wizard criada para a DPMP


@Return ( Nil )

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------


Static Function ProcDPMP( lEnd as logical, oProcess as object, cNomWiz as char)

Local cErrorDPMP  as char
Local cErrorTrd   as char
Local nX          as numeric
Local nPos        as numeric
Local nProgress1  as numeric
Local nCont       as numeric
Local aWizard     as array
Local aTotaliz    as array
Local aTotalizFn  as array
Local lProc       as logical

Private lBrwNat  as logical
Private lBrwIte  as logical
Private lBrwPar  as logical
	
	cErrorDPMP  :=	""
	cErrorTrd   :=	""	
	lBrwNat     := .F.
	lBrwIte     := .F.
	lBrwPar     := .F.
	
	nX          := 	0
	nPos        :=	0
	nProgress1  :=	0 
	
	aWizard     :=	{}
	
	lProc       :=	.T.
	nCont       := 1 
	aTotaliz    := {}
	aTotalizFn  := {}
	
	//Carrega informações na wizard
	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf
	
	dInicial 	:= CTOD("01/"+Substr(aWizard[1][3],1,2)+"/"+LTRIM(cValToChar(aWizard[1][4])))
	dFinal 		:= LastDay(dInicial)
	cCodRegAnp	:= cValToChar(aWizard[1][5])
		
	If TAFConsANP(dInicial, dFinal)
		If (MSGYESNO( STR0002, STR0003 )) //Existe(em) registro(s) sem o código ANP preenchido. Deseja informá-lo(s)?     Atenção!
			If !TAFCadAdic(dInicial, dFinal)
			 	lProc := MSGYESNO( STR0004, STR0003 ) //"Deseja gerar a obrigação sem finalizar o cadastro de códigos ANP"	   Atenção!	 	 
			EndIf
		EndIF	
	EndIf
	
	If lProc
	
	
		//Alimentando a variável de controle da barra de status do processamento
		nProgress1 := 2
		oProcess:Set1Progress( nProgress1 )
	
		//Iniciando o Processamento
		oProcess:Inc1Progress( STR0005 )	//"Preparando o Ambiente..."
		oProcess:Inc1Progress( STR0006 )    //"Executando o Processamento..."		
		
		//************************************************************************
		//Geração DPMP - Aqui vão a chamada das funções da geração dos registros
				
		TAFDPMPDOC(aWizard,@nCont,@aTotalizFn,@aTotaliz) // Registro de Movimentação (Documentos Fiscais)
		TAFDPMPPRD(aWizard,@nCont,@aTotalizFn,@aTotaliz) // Registro de Movimentação (Produção Própria)
		//TAFDPMPEST(aWizard,@nCont) // Registro de Movimentação (Estoque Final e Inicial)
		TAFDPMPTOT(aWizard,@nCont,aTotalizFn,aTotaliz)   // Registro de Movimentação (Totalizadores)
		TAFDPMPCON(aWizard,nCont)                        // Registro de Controle
		
		//************************************************************************
		//********* FIM da chamada das funções da geração dos registros **********
		//************************************************************************		
	Else
		oProcess:Inc1Progress( STR0007 )	//"Processamento cancelado"
		oProcess:Inc2Progress( STR0008 )	//"Clique em Finalizar"
		oProcess:nCancel = 1
	EndIf
	
	//Tratamento para quando o processamento tem problemas
	If oProcess:nCancel == 1 .or. !Empty( cErrorDPMP ) .or. !Empty( cErrorTrd )
	
		//Cancelado o processamento
		If oProcess:nCancel == 1
	
			Aviso( STR0003, STR0009, { STR0010 } ) 	//"Atenção" 	"A geração do arquivo foi cancelada com sucesso!"     "Sair"
			lCancel := .T.
	
		//Erro na inicialização das threads
		ElseIf !Empty( cErrorTrd )
	
			Aviso( STR0003, cErrorTrd, { STR0010 } ) //"Atenção"    "Sair"
	
		//Erro na execução dos Blocos
		Else
	
			cErrorDPMP := STR0011 + SubStr( cErrorDPMP, 2, Len( cErrorDPMP ) )	//"Ocorreu um erro fatal durante a geração do(s) Registro(s)"
			cErrorDPMP += STR0012 + Chr( 10 ) + Chr( 10 )						//"da DPMP"
			cErrorDPMP += STR0013												//"Favor efetuar o reprocessamento da DPMP, caso o erro persista entre em contato"
			cErrorDPMP += STR0014 + Chr( 10 ) + Chr( 10 )						//"com o administrador de sistemas / suporte Totvs"
	
			Aviso( STR0003, cErrorDPMP, { "Sair" } )
	
		EndIf
	
	Else
	
		//Atualizando a barra de processamento
		oProcess:Inc1Progress( STR0015 )	//"Informações processadas"		
		oProcess:Inc2Progress( STR0016 )	//"Consolidando as informações e gerando arquivo..."		
	
		If GerTxtCons( aWizard )
			//Atualizando a barra de processamento
			oProcess:Inc2Progress( STR0017 ) 	//"Arquivo gerado com sucesso."			
			msginfo(STR0017) 					//"Arquivo gerado com sucesso."
		Else
			oProcess:Inc2Progress( STR0018 ) 	//"Falha na geração do arquivo."			
		EndIf	
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

Local	cNomWiz		as char
Local 	cNomeAnt 	as char
Local	cTitObj1	as char
Local	aTxtApre	as array
Local	aPaineis	as array	
Local	aItens1		as array
Local	aRet		as array
	
	cNomWiz	:= cObrig+FWGETCODFILIAL
	cNomeAnt 	:= ""
	aTxtApre	:= {}
	aPaineis	:= {}	
	aItens1	:= {}	
	cTitObj1	:= ""
	aRet		:= {}
	
	aAdd (aTxtApre, STR0019)	//"Processando Empresa."	
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0020)	//"Preencha corretamente as informações solicitadas."	
	aAdd (aTxtApre, STR0021)	//"Informações necessárias para a geração do meio-magnético DPMP."	

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0022)	//"Preencha corretamente as informações solicitadas."	
	aAdd (aPaineis[nPos], STR0023)	//"Informações necessárias para a geração do meio-magnético DPMP."
	aAdd (aPaineis[nPos], {})
																
	//LINHA 1---------------------------------------------------------------------------------------------//
	cTitObj1 := STR0024 //"Diretório do Arquivo Destino"	                 
	cTitObj2 := STR0025 //"Nome do Arquivo Destino"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( "X", 50 )
	cTitObj2 := Replicate( "X", 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,, { "xValWizCmp", 3 , { "", "" } } } ) //Valida campo: "Diretório do Arquivo Destino" no Botão Avançar
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,, { "xValWizCmp", 4 , { "", "" } } } ) //Valida campo: "Nome do Arquivo Destino" no Botão Avançar

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
   
   //LINHA 2---------------------------------------------------------------------------------------------//

	cTitObj1	:=	STR0026   //"Mês Referência"
	cTitObj2	:=	STR0027   //"Ano Referência"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	aAdd (aItens1, STR0028)     //"01 - Janeiro"
	aAdd (aItens1, STR0029)     //"02 - Fevereiro"
	aAdd (aItens1, STR0030)     //"03 - Março"
	aAdd (aItens1, STR0031)     //"04 - Abril"
	aAdd (aItens1, STR0032)     //"05 - Maio"
	aAdd (aItens1, STR0033)     //"06 - Junho"
	aAdd (aItens1, STR0034)     //"07 - Julho"
	aAdd (aItens1, STR0035)     //"08 - Agosto"
	aAdd (aItens1, STR0036)     //"09 - Setembro"
	aAdd (aItens1, STR0037)     //"10 - Outubro"
	aAdd (aItens1, STR0038)     //"11 - Novembro"
	aAdd (aItens1, STR0039)     //"12 - Dezembro"

	cTitObj2 :=	"@E 9999"

	aAdd (aPaineis[nPos,3], {3,,,,,aItens1,,,,,}) 
	aAdd( aPaineis[nPos,3], {2,,cTitObj2,2,0,,,4})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

   //LINHA 3---------------------------------------------------------------------------------------------//

	cTitObj1	:=	STR0040 	//"Cód. Regulador ANP:"
	cTitObj2    :=  STR0090     //"Modal de Transporte Padrão:"
	
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )	

	cTitObj1 :=	"@E 9999999999"
	aAdd( aPaineis[nPos,3], {2,,cTitObj1,2,0,,,10})
	
	aItens1 := {}
	
	aAdd (aItens1, "") 
	aAdd (aItens1, STR0091)  //"1 - Rodoviário"
	aAdd (aItens1, STR0092)  //"2 - Ferroviário"
	aAdd (aItens1, STR0093)  //"3 - Rodo/Ferroviário"
	aAdd (aItens1, STR0094)  //"4 - Aquaviário"
	aAdd (aItens1, STR0095)  //"5 - Dutoviário"
	aAdd (aItens1, STR0096)  //"6 - Aéreo"
	aAdd (aItens1, STR0097)  //"7 - Navegação Interior"
	aAdd (aItens1, STR0098)	 //"8 - Cabotagem/Longo Curso"
	
	aAdd (aPaineis[nPos,3], {3,,,,,aItens1,,,,,})
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha   
   
   	//LINHA 4---------------------------------------------------------------------------------------------//
	//"Abrir Programa"
	cTitObj1 := STR0089 
	cAction	 :=	"TAFA472()"
	aAdd( aPaineis[nPos,3], { 7, cTitObj1,,,,,,,,,,,,,,, cAction } ); aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd(aPaineis[nPos][3], {0,"",,,,,,});	

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDPMP() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDPMP

Geracao do Arquivo TXT da DPMP.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DPMP
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDPMP( nHandle as numeric, cTXTSys as char, cReg as char)

Local cDirName	as char
Local cFileDest as char
Local lRetDir	as logical
Local lRet		as logical

	cDirName		:=	TAFGetPath( "2" , "DPMP" )
	cFileDest		:=	""
	lRetDir		:= .T.
	lRet			:= .T.
	
	//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
	if !File( cDirName )
	
		lRetDir := FWMakeDir( cDirName )
	
		if !lRetDir
	
			cDirName	:=	""
	
			Help( ,,"CRIADIR",, STR0041 + cValToChar( FError() ) , 1, 0 )   //"Não foi possível criar o diretório \Obrigacoes_TAF\DPMP. Erro:"
	
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

Geracao do Arquivo TXT da DPMP. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard as array )

Local cFileDest  	as char
Local cPathTxt		as char
Local cStrTxtFIM  	as char
Local cTxtSys		as char
Local nx			as numeric
Local nHandle		as numeric
Local aFiles		as array

	cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
	cPathTxt		:=	TAFGetPath( "2" , "DPMP" )			                 	//diretorio onde foram gerados os arquivos txt temporarios
	nx			:=	0
	cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
	nHandle		:=	MsFCreate( cTxtSys )
	aFiles		:=	{}
	cStrTxtFIM  	:= ""

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

	aFiles := DPMPFilesTxt(cPathTxt)
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
/*/{Protheus.doc} DPMPFilesTxt

DPMPFilesTxt() - Arquivos por bloco da DPMP

@Author francisco.nunes
@Since 20/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function DPMPFilesTxt( cPathTxt as char )

Local aRet	as array

	aRet	:=	{}
	
	AADD(aRet,{cPathTxt + "CONTROLE.TXT"})  // Registro de Controle
	AADD(aRet,{cPathTxt + "MOV_DOC.TXT"})   // Registro de Movimentação (Documentos Fiscais)
	AADD(aRet,{cPathTxt + "MOV_PRD.TXT"})   // Registro de Movimentação (Produção Própria)
	//AADD(aRet,{cPathTxt + "MOV_EST.TXT"}) // Registro de Movimentação (Estoque)
	AADD(aRet,{cPathTxt + "MOV_TOT.TXT"})   // Registro de Movimentação (Totalizadores) 	

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCadAdic

Cadastro adicional para manutenção dos código ANP

@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFCadAdic(dIni as date, dFim as date)

Local nOpc         as numeric
Local aArea	       as array
Local aAlter       as array
Local lOk          as logical

Private aColsGrid  as array
Private aHeaGrid   as array
Private oBrowDPMP   as object
Private oDlg1      as object
Private noBrw      as numeric
	
	nOpc		:= GD_UPDATE	
	aArea		:= GetArea()	
	
	/* TELA DE CÓDIGO ANP POR NATUREZA DE OPERAÇÃO */
	If lBrwNat 
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeaGrid	:= {}
		oBrowDPMP	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		TAFA456Brw("C1N")
		TAFA456Cols("C1N",dIni, dFim)
	
		aAdd(aAlter,aHeaGrid[3,2]) //COD. ANP
	
		oDlg1    := MSDialog():New( 091,232,502,900,STR0042,,,.F.,,,,,,.T.,,,.T. )   //"Código ANP por Natureza de Operação"
		
		DbSelectArea("C1N")
		oBrowDPMP := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeaGrid, aColsGrid)
		
		oBrowDPMP:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid("C1N"), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
	
	
	/* TELA DE CÓDIGO ANP POR PARTICIPANTE */
	If lBrwPar
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeaGrid	:= {}
		oBrowDPMP	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		TAFA456Brw("C1H")
		TAFA456Cols("C1H", dIni, dFim)
	
		aAdd(aAlter,aHeaGrid[3,2]) //COD. ANP
	
		oDlg1    := MSDialog():New( 091,232,502,900,STR0044,,,.F.,,,,,,.T.,,,.T. )   //"Código ANP por Participante"
		
		DbSelectArea("C1H")
		oBrowDPMP := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeaGrid, aColsGrid)
		
		oBrowDPMP:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid("C1H"), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
	
	/* TELA DE CÓDIGO ANP POR ITEM */
	If lBrwIte
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeaGrid	:= {}
		oBrowDPMP	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		DbSelectArea("C0G")
		TAFA456Brw("C1L")
		TAFA456Cols("C1L", dIni, dFim)
	
		aAdd(aAlter,aHeaGrid[3,2]) 
		aAdd(aAlter,aHeaGrid[5,2]) 
		aAdd(aAlter,aHeaGrid[7,2]) 
		aAdd(aAlter,aHeaGrid[9,2]) 
		aAdd(aAlter,aHeaGrid[11,2]) 
		aAdd(aAlter,aHeaGrid[13,2])
		aAdd(aAlter,aHeaGrid[15,2])
			
		oDlg1    := MSDialog():New( 091,232,502,900,STR0043,,,.F.,,,,,,.T.,,,.T. )   //"Código ANP por Item"
		
		DbSelectArea("C1L")
		oBrowDPMP := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeaGrid, aColsGrid)
		
		oBrowDPMP:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid("C1L"), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
		
	RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA456Brw

TAFA456Brw() - Monta aHeaGrid da MsNewGetDados
@Param 
 cAlias  - Alias principal que será alterado 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFA456Brw(cAlias as char)

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	
	Do Case 
		Case cAlias == "C1N"
		  	While !Eof() .and. SX3->X3_ARQUIVO == "C1N"
		  		
				If Alltrim(SX3->X3_CAMPO) $ "C1N_CODNAT"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;				// 09 - F3
					SX3->X3_CONTEXT ,;       	// 10 - Contexto
					SX3->X3_CBOX	,; 	  	  	// 11 - ComboBox
				    "", } ) 	   	    		// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1N_DESNAT"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	50,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif  		
				
				
				If Alltrim(SX3->X3_CAMPO) $ "C1N_CODANP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	"IIF (!Empty(M->C1N_CODANP), ExistCpo( 'T5A' , M->C1N_CODANP , 2 ), .T.)",;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX,;		 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1N_DESANP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX,;		 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				  		
				DbSkip()
			EndDo
		
		Case cAlias == "C1H"
		  	While !Eof() .and. SX3->X3_ARQUIVO == "C1H"
		  		
				If Alltrim(SX3->X3_CAMPO) $ "C1H_CODPAR"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;				// 09 - F3
					SX3->X3_CONTEXT ,;       	// 10 - Contexto
					SX3->X3_CBOX	,; 	  	  	// 11 - ComboBox
				    "", } ) 	   	    		// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1H_NOME"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	40,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif  		
				
				
				If Alltrim(SX3->X3_CAMPO) $ "C1H_CODATV"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	"IIF (!Empty(M->C1H_CODATV), ExistCpo( 'T5B' , M->C1H_CODATV , 2 ), .T.)",;			       	
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1H_DESATV"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				  		
				DbSkip()
			EndDo
		
		Case cAlias == "C1L"
		  	While !Eof() .and. SX3->X3_ARQUIVO == "C1L"
		  		
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODIGO"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	20,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;				// 09 - F3
					SX3->X3_CONTEXT ,;       	// 10 - Contexto
					SX3->X3_CBOX	,; 	  	  	// 11 - ComboBox
				    "", } ) 	   	    		// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESCRI"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	40,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif  		
				
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODANP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;			       	
			       	"IIF (!Empty(M->C1L_CODANP), ExistCpo( 'C0G' , M->C1L_CODANP , 8 ), .T.)",;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	"TDPMPCoPdr()"	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DANP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	40,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODCFQ"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	10,;
			       	"IIF (!Empty(M->C1L_CODCFQ), ExistCpo( 'T5C' , M->C1L_CODCFQ , 2 ), .T.)",;			       	
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESCFQ"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODCNM"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;			       	
			       	"IIF (!Empty(M->C1L_CODCNM), ExistCpo( 'T5D' , M->C1L_CODCNM , 2 ), .T.)",;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESCNM"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODGLP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	"IIF (!Empty(M->C1L_CODGLP), ExistCpo( 'T5E' , M->C1L_CODGLP , 2 ), .T.)",;			       	
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESGLP"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODAFE"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;
			       	"IIF (!Empty(M->C1L_CODAFE), ExistCpo( 'T5F' , M->C1L_CODAFE , 2 ), .T.)",;			       	
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESAFE"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CODUM"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;			       	
			       	"IIF (!Empty(M->C1L_CODUM), ExistCpo( 'T59' , M->C1L_CODUM , 2 ), .T.)",;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_DESUM"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	30,;
			       	SX3->X3_DECIMAL,;
			       	SX3->X3_VALID,;
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				
				If Alltrim(SX3->X3_CAMPO) $ "C1L_CERTIF"
			 		noBrw++
					aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
					SX3->X3_CAMPO,;
			       	SX3->X3_PICTURE,;
			       	SX3->X3_TAMANHO,;
			       	SX3->X3_DECIMAL,;	
			       	SX3->X3_VALID,;		       				       	
			       	SX3->X3_USADO,;
			       	SX3->X3_TIPO,;
			       	SX3->X3_F3	,;					// 09 - F3
					SX3->X3_CONTEXT ,;       		// 10 - Contexto
					SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
				    "", } ) 		  				// 12 - Relacao
				Endif
				  		
				DbSkip()
			EndDo
	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConsANP()

TAFConsANP() - 	Consulta nos cadastros de Natureza de operação, 
				Participante e Item para os movimentos do período,
				se existe código ANP não preenchido para questionar
				se abre a tela de manutenção.

@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 
 @Return
 lExist  - Indica se existe algum cadastro com ANP em branco. 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFConsANP(dIni as date, dFim as date)
 
	Local cAliasQry	 as character 
	Local aInfoEUF   as character
	Local cFilJC20   as character
	Local cCompC1H   as character
	Local cCompC1L   as character
	Local cCompC1N   as character
	Local cFilJC30   as character
	Local cJC1HxC20  as character
	Local cJC1LxC30  as character
	Local cJC1NxC30	 as character
	
	cAliasQry 		:= GetNextAlias()

	//Inicializo as variáves para o controle do compartilhamento no JOIN
	aInfoEUF   := {}
	cFilJC20   := ""
	cCompC1H   := "" 
	cCompC1L   := ""
	cCompC1N   := ""
	cFilJC30   := ""
	cJC1HxC20  := ""
	cJC1LxC30  := ""
	cJC1NxC30  := ""

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H", 1) + FWModeAccess("C1H", 2) + FWModeAccess("C1H", 3)))
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))
	cCompC1N := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3)))

	cFilJC20 := "C20.C20_FILIAL"
	cFilJC30 := "C30.C30_FILIAL"

	// Obtém as condições de join usando TAFCompDPMP e informações de aInfoEUF
	cJC1HxC20 := TAFCompDPMP("C1H", cCompC1H, aInfoEUF, cFilJC20)
	cJC1LxC30 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJC30)
	cJC1NxC30 := TAFCompDPMP("C1N", cCompC1N, aInfoEUF, cFilJC30)

	/* VERIFICA ANP DA NATUREZA DE OPERAÇÃO */
	BeginSQL Alias cAliasQry
			SELECT COUNT(*) COUNT
			FROM %table:C20% C20
		INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
		INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID = C30.C30_CODITE AND C1L.%NotDel%
		INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%	
		INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID = C30.C30_NATOPE AND C1N.%NotDel%
			WHERE C20.C20_FILIAL = %xFilial:C20%	 	    
			AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
			AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
			AND (C1N.C1N_IDOPAN IS NULL OR C1N.C1N_IDOPAN = ' ')
			AND C1N.C1N_OBJOPE != '01' //DIF. USO E CONSUMO		  	 	   
			AND C20.%NotDel%
	EndSQL
	
	IIF ((cAliasQry)->COUNT > 0, lBrwNat := .T., lBrwNat := .F.)  

	(cAliasQry)->(DbCloseArea())
	
	/* VERIFICA ANP DO PARTICIPANTE */
	BeginSQL Alias cAliasQry
			SELECT COUNT(*) COUNT
			FROM %table:C20% C20	
			INNER JOIN %table:C1H% C1H %Exp:cJC1HxC20% AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.%NotDel%
			INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
			INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID = C30.C30_CODITE AND C1L.%NotDel%
			INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	 = C1L.C1L_CODANP AND C0G.%NotDel%
			WHERE C20.C20_FILIAL = %xFilial:C20%
			AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
			AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
			AND (C1H.C1H_IDATV IS NULL OR C1H.C1H_IDATV = ' ')
			AND C20.%NotDel%
	EndSQL
	
	IIF ((cAliasQry)->COUNT > 0, lBrwPar := .T., lBrwPar := .F.)
	
	(cAliasQry)->(DbCloseArea())  
	
	/* VERIFICA ANP DO ITEM */
	BeginSQL Alias cAliasQry
			SELECT COUNT(*) COUNT
			FROM %table:C20% C20	
		INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
		INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
		INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	 = C1L.C1L_CODANP AND C0G.%NotDel%
			WHERE C20.C20_FILIAL = %xFilial:C20%
			AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
			AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)	 	   
			AND (C1L.C1L_IDCFQ     IS NULL OR C1L.C1L_IDCFQ  = ' '
					OR C1L.C1L_IDCNM  IS NULL OR C1L.C1L_IDCNM  = ' '
					OR C1L.C1L_IDGLP  IS NULL OR C1L.C1L_IDGLP  = ' '
					OR C1L.C1L_IDAFE  IS NULL OR C1L.C1L_IDAFE  = ' '
					OR C1L.C1L_IDUM   IS NULL OR C1L.C1L_IDUM   = ' ' 
					OR C1L.C1L_CERTIF IS NULL OR C1L.C1L_CERTIF = ' ')
			AND C20.%NotDel%	 	   
	EndSQL
	
	IIF ((cAliasQry)->COUNT > 0, lBrwIte := .T., lBrwIte := .F.)

	(cAliasQry)->(DbCloseArea())
   
Return (lBrwNat .Or. lBrwPar .Or. lBrwIte)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA456Cols()

TAFA456Cols() - Monta aColsGrid da MsNewGetDados

@Param 
 cAlias  - Alias principal que será alterado
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFA456Cols(cAlias as char, dIni as date, dFim as date)
	Local nX         as numeric
	Local nY         as numeric
	Local cAliasQry  as character
	Local aInfoEUF   as character
	Local cCompC1H   as character
	Local cCompC1L	 as character
	Local cCompC1N	 as character
	Local cJC1HxC20  as character
	Local cJC1LxC30  as character
	Local cJC1NxC30  as character
	Local cFilJC20   as character
	Local cFilJC30   as character


	nX        := 0
	nY        := 0
	cAliasQry := GetNextAlias()

	//Inicializo as variáves para o controle do compartilhamento no JOIN
 	aInfoEUF   := {}
	cCompC1H   := ""   
	cCompC1L   := ""
	cCompC1N   := ""
	cJC1HxC20  := ""
	cJC1LxC30  := ""
	cJC1NxC30  := ""
	cFilJC20   := ""
	cFilJC30   := ""

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H", 1) + FWModeAccess("C1H", 2) + FWModeAccess("C1H", 3)))
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))
	cCompC1N := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3)))

	cFilJC20 := "C20.C20_FILIAL"
	cFilJC30 := "C30.C30_FILIAL"

	// Obtém as condições de join usando TAFCompDPMP e informações de aInfoEUF
	cJC1HxC20 := TAFCompDPMP("C1H", cCompC1H, aInfoEUF, cFilJC20)
	cJC1LxC30 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJC30)
	cJC1NxC30 := TAFCompDPMP("C1N", cCompC1N, aInfoEUF, cFilJC30)
 
	Do Case
		
		Case  cAlias == "C1N"
		
			BeginSQL Alias cAliasQry
					SELECT C1N_CODNAT,
						C1N_DESNAT
					FROM %table:C20% C20
				INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
				INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
				INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
				INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%	
				INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID    = C30.C30_NATOPE AND C1N.%NotDel%
					WHERE C20.C20_FILIAL = %xFilial:C20%
					AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
					AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
					AND (C1N.C1N_IDOPAN IS NULL OR C1N.C1N_IDOPAN = ' ')
						AND C1N.C1N_OBJOPE != '01' //DIF. USO E CONSUMO		  	
					AND C20.%NotDel%
				GROUP BY C1N_CODNAT, C1N_DESNAT
			EndSql
			
			While (cAliasQry)->(!Eof())
				AADD(aColsGrid,Array(noBrw+1))
				aColsGrid[Len(aColsGrid)][1] := (cAliasQry)->C1N_CODNAT
				aColsGrid[Len(aColsGrid)][2] := substr((cAliasQry)->C1N_DESNAT, 1, 50)
				aColsGrid[Len(aColsGrid)][3] := space(7) 		
				aColsGrid[Len(aColsGrid)][4] := space(220)
				aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
			
				(cAliasQry)->(DbSkip())
			EndDo
			
			(cAliasQry)->(DbCloseArea())
		
		Case  cAlias == "C1H"
		
			BeginSQL Alias cAliasQry
					SELECT C1H_CODPAR,
						C1H_NOME
					FROM %table:C20% C20			
				INNER JOIN %table:C1H% C1H %Exp:cJC1HxC20% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel%
				INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
				INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
				INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
				INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%
					WHERE C20.C20_FILIAL = %xFilial:C20%
					AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
					AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
					AND (C1H.C1H_IDATV IS NULL OR C1H.C1H_IDATV = ' ')
					AND C20.%NotDel%
				GROUP BY C1H_CODPAR, C1H_NOME
			EndSql
			
			While (cAliasQry)->(!Eof())
				AADD(aColsGrid,Array(noBrw+1))
				aColsGrid[Len(aColsGrid)][1] := (cAliasQry)->C1H_CODPAR
				aColsGrid[Len(aColsGrid)][2] := substr((cAliasQry)->C1H_NOME,   1, 50)
				aColsGrid[Len(aColsGrid)][3] := space(7) 		
				aColsGrid[Len(aColsGrid)][4] := space(220)
				aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
			
				(cAliasQry)->(DbSkip())
			EndDo
			
			(cAliasQry)->(DbCloseArea())
		
		Case  cAlias == "C1L"
		
			BeginSQL Alias cAliasQry
					SELECT C1L_CODIGO,
						C1L_DESCRI,
						C0G_ID,
						C0G_DESCRI,
						T5C_CODIGO,
						T5C_CARACT,
						T5D_CODIGO,
						T5D_CARACT,
						T5E_CODIGO,
						T5E_VASILH,
						T5F_CODIGO,
						T5F_METODO,
						T59_CODIGO,
						T59_UNMEDI,
						C1L_CERTIF 
					FROM %table:C20% C20			
				INNER JOIN %table:C02% C02 ON C02.C02_ID     = C20.C20_CODSIT AND C02.%NotDel%
				INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
				INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
				INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%
				LEFT JOIN %table:T5C% T5C ON T5C.T5C_FILIAL = %xFilial:T5C%  AND T5C.T5C_ID 	= C1L.C1L_IDCFQ  AND T5C.%NotDel%
				LEFT JOIN %table:T5D% T5D ON T5D.T5D_FILIAL = %xFilial:T5D%  AND T5D.T5D_ID	= C1L.C1L_IDCNM  AND T5D.%NotDel%
				LEFT JOIN %table:T5E% T5E ON T5E.T5E_FILIAL = %xFilial:T5E%  AND T5E.T5E_ID 	= C1L.C1L_IDGLP  AND T5E.%NotDel%
				LEFT JOIN %table:T5F% T5F ON T5F.T5F_FILIAL = %xFilial:T5F%  AND T5F.T5F_ID 	= C1L.C1L_IDAFE  AND T5F.%NotDel%
				LEFT JOIN %table:T59% T59 ON T59.T59_FILIAL = %xFilial:T59%  AND T59.T59_ID 	= C1L.C1L_IDUM   AND T59.%NotDel%
					WHERE C20.C20_FILIAL = %xFilial:C20%			 	 
					AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%
					AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)	 	   
					AND (   C1L.C1L_IDCFQ  IS NULL OR C1L.C1L_IDCFQ  = ' '
							OR C1L.C1L_IDCNM  IS NULL OR C1L.C1L_IDCNM  = ' '
							OR C1L.C1L_IDGLP  IS NULL OR C1L.C1L_IDGLP  = ' '
							OR C1L.C1L_IDAFE  IS NULL OR C1L.C1L_IDAFE  = ' '
							OR C1L.C1L_IDUM   IS NULL OR C1L.C1L_IDUM   = ' ' 
							OR C1L.C1L_CERTIF IS NULL OR C1L.C1L_CERTIF = ' ')			 	   		
					AND C20.%NotDel%
				GROUP BY C1L_CODIGO,
						C1L_DESCRI,
						C0G_ID,
						C0G_DESCRI,
						T5C_CODIGO,
						T5C_CARACT,
						T5D_CODIGO,
						T5D_CARACT,
						T5E_CODIGO,
						T5E_VASILH,
						T5F_CODIGO,
						T5F_METODO,
						T59_CODIGO,
						T59_UNMEDI,
						C1L_CERTIF 
			EndSql
			
			While (cAliasQry)->(!Eof())
				AADD(aColsGrid,Array(noBrw+1))
				aColsGrid[Len(aColsGrid)][1]  := (cAliasQry)->C1L_CODIGO
				aColsGrid[Len(aColsGrid)][2]  := substr((cAliasQry)->C1L_DESCRI,   1, 50)
				
				//Código Produto ANP		
				If (!Empty((cAliasQry)->C0G_ID))
					aColsGrid[Len(aColsGrid)][3]  := (cAliasQry)->C0G_ID
					aColsGrid[Len(aColsGrid)][4]  := (cAliasQry)->C0G_DESCRI
				Else
					aColsGrid[Len(aColsGrid)][3]  := space(10)   
					aColsGrid[Len(aColsGrid)][4]  := space(60)
				EndIf
						
				//Código Fisic. Quimi 					 		
				If (!Empty((cAliasQry)->T5C_CODIGO))
					aColsGrid[Len(aColsGrid)][5]  := (cAliasQry)->T5C_CODIGO
					aColsGrid[Len(aColsGrid)][6]  := (cAliasQry)->T5C_CARACT
				Else
					aColsGrid[Len(aColsGrid)][5]  := space(3)    
					aColsGrid[Len(aColsGrid)][6]  := space(30)
				EndIf
				
				//Código Carac. Não Mensuráveis
				If (!Empty((cAliasQry)->T5D_CODIGO))
					aColsGrid[Len(aColsGrid)][7]  := (cAliasQry)->T5D_CODIGO
					aColsGrid[Len(aColsGrid)][8]  := (cAliasQry)->T5D_CARACT
				Else
					aColsGrid[Len(aColsGrid)][7]  := space(2)        		
					aColsGrid[Len(aColsGrid)][8]  := space(20)
				EndIf
				
				//Código Características GLP
				If (!Empty((cAliasQry)->T5E_CODIGO))
					aColsGrid[Len(aColsGrid)][9]  := (cAliasQry)->T5E_CODIGO
					aColsGrid[Len(aColsGrid)][10] := (cAliasQry)->T5E_VASILH
				Else
					aColsGrid[Len(aColsGrid)][9]  := space(2)           		
					aColsGrid[Len(aColsGrid)][10] := space(20)
				EndIf
				
				//Código Aferição
				If (!Empty((cAliasQry)->T5F_CODIGO))
					aColsGrid[Len(aColsGrid)][11] := (cAliasQry)->T5F_CODIGO
					aColsGrid[Len(aColsGrid)][12] := (cAliasQry)->T5F_METODO
				Else
					aColsGrid[Len(aColsGrid)][11] := space(3) 	             	
					aColsGrid[Len(aColsGrid)][12] := space(20)
				EndIf
				
				//Código UM ANP
				If (!Empty((cAliasQry)->T59_CODIGO))
					aColsGrid[Len(aColsGrid)][13] := (cAliasQry)->T59_CODIGO
					aColsGrid[Len(aColsGrid)][14] := (cAliasQry)->T59_UNMEDI
				Else
					aColsGrid[Len(aColsGrid)][13] := space(2)                    		
					aColsGrid[Len(aColsGrid)][14] := space(20)
				EndIf	
				
				//Cerfificado ANP
				If (!Empty((cAliasQry)->C1L_CERTIF))
					aColsGrid[Len(aColsGrid)][15] := (cAliasQry)->C1L_CERTIF
				Else				                    	
					aColsGrid[Len(aColsGrid)][15] := space(10)
				EndIf		
				
				aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
			
				(cAliasQry)->(DbSkip())
			EndDo
			
			(cAliasQry)->(DbCloseArea())
	EndCase
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGrid

Atualiza código ANP na tabela informada por parâmetro

@Param 
cAlias - Tabela onde código ANP será atualizado.

@Return 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaGrid(cAlias as char)
Local nX   		as numeric
Local lAlterou	as logical

	lAlterou := .F.
	
	Begin Transaction
		Do Case
			Case cAlias == "C1N"
				DbSelectArea("C1N")
				DbSelectArea("T5A")					
				C1N->(DbSetOrder(1))
				T5A->(DbSetOrder(2))
				
				For nX := 1 To Len(oBrowDPMP:aCols)				
					If(!oBrowDPMP:aCols[nX][5] .AND. !Empty(oBrowDPMP:aCols[nX][3]))						
						
						If (C1N->(DbSeek(xFilial("C1N") + oBrowDPMP:aCols[nX][1])))
							While C1N->(!Eof()) .AND. (C1N->C1N_FILIAL + C1N->C1N_CODNAT) == (xFilial("C1N") + oBrowDPMP:aCols[nX][1])
								If(T5A->(DbSeek(xFilial("T5A") + oBrowDPMP:aCols[nX][3]))) 
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDOPAN := T5A->T5A_ID
									MsUnLock()
									lAlterou := .T.
								EndIf														
								C1N->(DbSkip())
							EndDo
						EndIf	
									
					EndIf
				Next
				
				C1N->(DbCloseArea())
				T5A->(DbCloseArea())
				
			Case cAlias == "C1H"
				DbSelectArea("C1H")
				DbSelectArea("T5B")					
				C1H->(DbSetOrder(1))
				T5B->(DbSetOrder(2))
				
				For nX := 1 To Len(oBrowDPMP:aCols)				
					If(!oBrowDPMP:aCols[nX][5] .AND. !Empty(oBrowDPMP:aCols[nX][3]))						
						
						If (C1H->(DbSeek(xFilial("C1H") + oBrowDPMP:aCols[nX][1])))
							While C1H->(!Eof()) .AND. (C1H->C1H_FILIAL + C1H->C1H_CODPAR) == (xFilial("C1H") + oBrowDPMP:aCols[nX][1])
								If(T5B->(DbSeek(xFilial("T5B") + oBrowDPMP:aCols[nX][3]))) 
									RecLock("C1H",.F.) //alteração
									C1H->C1H_IDATV := T5B->T5B_ID
									MsUnLock()
									lAlterou := .T.
								EndIf														
								C1H->(DbSkip())
							EndDo
						EndIf	
									
					EndIf
				Next
				
				C1H->(DbCloseArea())
				T5B->(DbCloseArea())			
			
			Case cAlias == "C1L"
				DbSelectArea("C1L")
				DbSelectArea("C0G")					
				DbSelectArea("T5C")
				DbSelectArea("T5D")
				DbSelectArea("T5E")
				DbSelectArea("T5F")
				DbSelectArea("T59")
				
				C1L->(DbSetOrder(1))
				C0G->(DbSetOrder(8))
				T5C->(DbSetOrder(2))
				T5D->(DbSetOrder(2))
				T5E->(DbSetOrder(2))
				T5F->(DbSetOrder(2))
				T59->(DbSetOrder(2))
				
				For nX := 1 To Len(oBrowDPMP:aCols)				
					If(!oBrowDPMP:aCols[nX][16])						
						
						If (C1L->(DbSeek(xFilial("C1L") + oBrowDPMP:aCols[nX][1])))
							While C1L->(!Eof()) .AND. (C1L->C1L_FILIAL + C1L->C1L_CODIGO) == (xFilial("C1L") + oBrowDPMP:aCols[nX][1])
								
								//Código Produto ANP 	
								If !Empty(oBrowDPMP:aCols[nX][3]) 
									If(C0G->(DbSeek(xFilial("C0G") + oBrowDPMP:aCols[nX][3]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_CODANP := C0G->C0G_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Código Fisic. Quimi 		
								If !Empty(oBrowDPMP:aCols[nX][5]) 
									If(T5C->(DbSeek(xFilial("T5C") + oBrowDPMP:aCols[nX][5]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_IDCFQ := T5C->T5C_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Código Carac. Não Mensuráveis    
								If !Empty(oBrowDPMP:aCols[nX][7]) 
									If(T5D->(DbSeek(xFilial("T5D") + oBrowDPMP:aCols[nX][7]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_IDCNM := T5D->T5D_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Código Características GLP        
								If !Empty(oBrowDPMP:aCols[nX][9]) 
									If(T5E->(DbSeek(xFilial("T5E") + oBrowDPMP:aCols[nX][9]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_IDGLP := T5E->T5E_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Código Código Aferição 
								If !Empty(oBrowDPMP:aCols[nX][11]) 
									If(T5F->(DbSeek(xFilial("T5F") + oBrowDPMP:aCols[nX][11]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_IDAFE := T5F->T5F_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Código UM ANP      
								If !Empty(oBrowDPMP:aCols[nX][13]) 
									If(T59->(DbSeek(xFilial("T59") + oBrowDPMP:aCols[nX][13]))) 
										RecLock("C1L",.F.) //alteração
										C1L->C1L_IDUM := T59->T59_ID
										MsUnLock()
										lAlterou := .T.
									EndIf														
								EndIf
								
								//Certificado ANP
								If !Empty(oBrowDPMP:aCols[nX][15]) 
									RecLock("C1L",.F.) //alteração
									C1L->C1L_CERTIF := oBrowDPMP:aCols[nX][15]
									MsUnLock()
									lAlterou := .T.														
								EndIf
								
								C1L->(DbSkip())								
							EndDo
						EndIf	
									
					EndIf
				Next
				
				C1L->(DbCloseArea())
				C0G->(DbCloseArea())
				T5C->(DbCloseArea())
				T5D->(DbCloseArea())
				T5E->(DbCloseArea())
				T5F->(DbCloseArea())
				T59->(DbCloseArea())
		EndCase
		
	End Transaction	
	
	If lAlterou
		msginfo( STR0045 ) 	//"Atenção" 	"Informações atualizadas com sucesso."   	"Sair"
	Else
		msginfo( STR0046 ) 	//"Atenção"		"Nenhum registro foi alterado"     			"Sair"
	EndIf

Return	.T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TDPMPCoPdr

TDPMPCoPdr() - Chama a consulta padrão para a tabela C0G

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TDPMPCoPdr()
  
  If CONPAD1(,,,"C0G")
  	M->C1L_CODANP := C0G->C0G_ID  	
  Endif
  
  oBrowDPMP:oBrowse:Refresh()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TDPMPRelat

TDPMPRelat() - Gera relatório de conferência da DPMP para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TDPMPRelat()
	Local oReport

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()		
		oReport:PrintDialog()
	EndIf	
	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

ReportDef() - Gera relatório de conferência da DPMP para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef	

	Local oReport     	as object
	Local oSectionNF   	as object
	Local oSectionIT   	as object
	Private cAliasNF  	as char
	Private cAliasTot 	as char
	
	oReport 	:= TReport():New("DPMP",UPPER(STR0048),"",{|oReport| ReportPrint(oReport)},STR0049)		//DPMP - RELATÓRIO DE CONFERÊNCIA  //Conferência dos documentos gerados na DPMP
	cAliasNF	:= ""
	cAliasTot 	:= ""
	
	oSectionNF := TRSection():New(oReport,STR0050,{"(cAliasNF)"},{"NUM_DOC"})  //Documentos Fiscais	
	oSectionNF:SetHeaderPage(.T.)	//Define que imprime cabeçalho das células no topo da página.		
	
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->NUM_DOC",	"(cAliasNF)",UPPER(STR0051),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasNF)->NUM_DOC }) 		//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->SERIE",	"(cAliasNF)",UPPER(STR0052),	/*Picture*/,  3,	/*lPixel*/,{|| (cAliasNF)->SERIE })			//SÉRIE
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->DTA_ES",	"(cAliasNF)",UPPER(OEMTOANSI(STR0053)),	/*Picture*/,  10,	/*lPixel*/,{|| SToD((cAliasNF)->DTA_ES)}) 	//DATA EMISSAO
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->IND_OPER","(cAliasNF)",UPPER(OEMTOANSI(STR0054)),	/*Picture*/,  6,	/*lPixel*/,{|| (cAliasNF)->IND_OPER})		//TIPO OPERACAO
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->PART",	"(cAliasNF)",UPPER(STR0055),	/*Picture*/,  60,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_PART) 	+ '-' +  Alltrim((cAliasNF)->DESC_PART)}) 		//PARTICIPANTE
	oCell := TRCell():New(oSectionNF,"(cAliasNF)->COD_ATV",	"(cAliasNF)",UPPER(STR0056),	/*Picture*/,  60,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_ATV) 	+ '-' +  Alltrim((cAliasNF)->DESC_ATV)})		//ATIVIDADE ANP
	
	oSectionIT := TRSection():New(oSectionNF,STR0057,{"(cAliasNF)"},{"ITEM"})  //Itens
	oSectionIT:SetLeftMargin(2)		//Define a margem à esquerda do relatório.	
	oSectionIT:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.
	//oSectionIT:SetLinesBefore(2)	
	
	TRCell():New(oSectionIT,"(cAliasNF)->ITEM",			"(cAliasNF)",	UPPER(STR0058),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_ITEM) 	+ '-' +  Alltrim((cAliasNF)->DESC_ITEM)})		//ITEM
	TRCell():New(oSectionIT,"(cAliasNF)->NATUREZA",		"(cAliasNF)",	UPPER(STR0059),	/*Picture*/,  20,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_NAT)	 	+ '-' +  Alltrim((cAliasNF)->DESC_NAT)})		//NATUREZA OPERAÇÃO
	TRCell():New(oSectionIT,"(cAliasNF)->COD_OPERANP",	"(cAliasNF)",	UPPER(STR0060),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_OPERANP) + '-' +  Alltrim((cAliasNF)->DESC_OPERANP)})	//ANP NAT. OPER.
	TRCell():New(oSectionIT,"(cAliasNF)->COD_ANP",		"(cAliasNF)",	UPPER(STR0061),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_ANP)	 	+ '-' +  Alltrim((cAliasNF)->DESC_ANP)})		//ANP ITEM
	TRCell():New(oSectionIT,"(cAliasNF)->COD_CFQ",		"(cAliasNF)",	UPPER(STR0062),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_CFQ) 	+ '-' +  Alltrim((cAliasNF)->DESC_CFQ)})		//CARACT FISICA/QUIMICA
	TRCell():New(oSectionIT,"(cAliasNF)->COD_CNM",		"(cAliasNF)",	UPPER(STR0063),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_CNM) 	+ '-' +  Alltrim((cAliasNF)->DESC_CNM)})		//CARACT. NAO MENSURÁVEL
	TRCell():New(oSectionIT,"(cAliasNF)->COD_GLP",		"(cAliasNF)",	UPPER(STR0064),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_GLP) 	+ '-' +  Alltrim((cAliasNF)->DESC_GLP)})		//RECIPIENTE GLP
	TRCell():New(oSectionIT,"(cAliasNF)->COD_AFE",		"(cAliasNF)",	UPPER(STR0065),	/*Picture*/,  20,	/*lPixel*/,{|| Alltrim((cAliasNF)->COD_AFE) 	+ '-' +  Alltrim((cAliasNF)->DESC_AFE)})		//METODO AFERICAO
	TRCell():New(oSectionIT,"(cAliasNF)->COD_UM",		"(cAliasNF)",	UPPER(STR0066),	/*Picture*/,  10,	/*lPixel*/,{|| Alltrim((cAliasNF)->DESC_UM)})													//U.M. ANP
	TRCell():New(oSectionIT,"(cAliasNF)->UNID_MED",		"(cAliasNF)",	UPPER(STR0067),	/*Picture*/,  5,	/*lPixel*/,{|| (cAliasNF)->UNID_MED})															//U.M.
	TRCell():New(oSectionIT,"(cAliasNF)->CERT_ANP",		"(cAliasNF)",	UPPER(STR0078),	/*Picture*/,  5,	/*lPixel*/,{|| (cAliasNF)->CERT_ANP})															//CERTIFICADO ANP
	TRCell():New(oSectionIT,"(cAliasNF)->QUANT_ITEM",	"(cAliasNF)",	UPPER(STR0068),    "@E 9,999,999,999.99999", 16,	/*lPixel*/,{|| (cAliasNF)->QUANT_ITEM})												//QUANTIDADE
	
	oReport:HideParamPage()   		//Define se será permitida a alteração dos parâmetros do relatório.
	oReport:SetLandScape()  		//Define orientação de página do relatório como paisagem
	oReport:ParamReadOnly()			//Parâmetros não poderão ser alterados pelo usuário
	oReport:DisableOrientation()	//Desabilita a seleção da orientação (Retrato/Paisagem)
	oReport:HideFooter()			//Define que não será impresso o rodapé padrão da página
		
	/* Operações de Produção - Itens Produzidos */
			
	oSectionPrd := TRSection():New(oReport,STR0077,{"(cAliasPrd)"},{"COD_OPERANP"})
		
	oCell := TRCell():New(oSectionPrd,"(cAliasPrd)->COD_OPERANP"," (cAliasPrd)", UPPER(STR0077), /*Picture*/,  99,	/*lPixel*/,{|| TDescNatOpe("", (cAliasPrd)->COD_OPERANP) })
	oCell:lBold := .T.				
	
	oSectionPITEM := TRSection():New(oSectionPrd,STR0079,{"(cAliasPrd)"},{"C0G_CODIGO"})
	oCell := TRCell():New(oSectionPITEM,"(cAliasPrd)->COD_ANP",  "(cAliasPrd)",UPPER(STR0061),				/*Picture*/,   15,	/*lPixel*/,{|| (cAliasPrd)->COD_ANP })  //ANP ITEM
	oCell := TRCell():New(oSectionPITEM,"(cAliasPrd)->DES_ANP",  "(cAliasPrd)",UPPER(STR0071),				/*Picture*/,   50,	/*lPixel*/,{|| (cAliasPrd)->DES_ANP })  //DESCRIÇÃO ANP ITEM
	oCell := TRCell():New(oSectionPITEM,"(cAliasPrd)->QTD_PROD", "(cAliasPrd)",UPPER(STR0068),	"@E 9,999,999,999.99999", 15,	/*lPixel*/,{|| (cAliasPrd)->QTD_PROD }) //QUANTIDADE
	
	oBreak:= TRBreak():New(oSectionPrd, "(cAliasPrd)->COD_ANP" ,  , .F., 'NOMEBRK', .F.)	
	oSum  := TRFunction():New(oSectionPITEM:Cell('(cAliasPrd)->QTD_PROD'),, 'SUM',oBreak,,,,.F.,.F.,.F., oSectionPrd)
	
	/* Operações de Produção - Itens Consumidos */
	
	oSectionIns := TRSection():New(oReport,STR0082,{"(cAliasIns)"},{"COD_OPERANP"})
		
	oCell := TRCell():New(oSectionIns,"(cAliasIns)->COD_OPERANP"," (cAliasIns)", UPPER(STR0082), /*Picture*/,  99,	/*lPixel*/,{|| TDescNatOpe("", (cAliasIns)->COD_OPERANP) })
	oCell:lBold := .T.				
	
	oSectionIITEM := TRSection():New(oSectionIns,STR0081,{"(cAliasIns)"},{"C0G_CODIGO"})
	oCell := TRCell():New(oSectionIITEM,"(cAliasIns)->COD_ANP_I",  "(cAliasIns)",UPPER(STR0061),				/*Picture*/,   15,	/*lPixel*/,{|| (cAliasIns)->COD_ANP_I })  //ANP ITEM
	oCell := TRCell():New(oSectionIITEM,"(cAliasIns)->DES_ANP_I",  "(cAliasIns)",UPPER(STR0071),				/*Picture*/,   50,	/*lPixel*/,{|| (cAliasIns)->DES_ANP_I })  //DESCRIÇÃO ANP ITEM
	oCell := TRCell():New(oSectionIITEM,"(cAliasIns)->COD_ANP_P",  "(cAliasIns)",UPPER(STR0083),				/*Picture*/,   15,	/*lPixel*/,{|| (cAliasIns)->COD_ANP_P })  //ANP ITEM
	oCell := TRCell():New(oSectionIITEM,"(cAliasIns)->DES_ANP_P",  "(cAliasIns)",UPPER(STR0084),				/*Picture*/,   50,	/*lPixel*/,{|| (cAliasIns)->DES_ANP_P })  //DESCRIÇÃO ANP ITEM
	oCell := TRCell():New(oSectionIITEM,"(cAliasIns)->QTD_CON", 	"(cAliasIns)",UPPER(STR0068),	"@E 9,999,999,999.99999", 15,	/*lPixel*/,{|| (cAliasIns)->QTD_CON }) 	//QUANTIDADE	
	
	oBreak:= TRBreak():New(oSectionIns, "(cAliasIns)->COD_ANP_I" ,  , .F., 'NOMEBRK', .F.)	
	oSum  := TRFunction():New(oSectionIITEM:Cell('(cAliasIns)->QTD_CON'),, 'SUM',oBreak,,,,.F.,.F.,.F., oSectionIns)
	
	/* Operações Sem Documento Fiscal / Informações de Produção */
	
	oSectionOut := TRSection():New(oReport,STR0088,{"(cAliasOut)"},{"COD_OPERANP"})
				
	oSectionOITEM := TRSection():New(oSectionOut,STR0088,{"(cAliasOut)"},{"COD_OPERANP"})
	oCell := TRCell():New(oSectionOITEM,"(cAliasOut)->COD_OPERANP","(cAliasOut)",UPPER(STR0060), /*Picture*/,  99,	/*lPixel*/,{|| Alltrim((cAliasOut)->COD_OPERANP) + ' - ' +  Alltrim((cAliasOut)->DES_OPERANP) }) //OPERAÇÃO ANP
	oCell := TRCell():New(oSectionOITEM,"(cAliasOut)->COD_ITEMANP","(cAliasOut)",UPPER(STR0061),				/*Picture*/,   15,	/*lPixel*/,{|| (cAliasOut)->COD_ITEMANP })  	//ANP ITEM
	oCell := TRCell():New(oSectionOITEM,"(cAliasOut)->DES_ITEMANP","(cAliasOut)",UPPER(STR0071),				/*Picture*/,   50,	/*lPixel*/,{|| (cAliasOut)->DES_ITEMANP })  	//DESCRIÇÃO ANP ITEM	
	oCell := TRCell():New(oSectionOITEM,"(cAliasOut)->QTD", 	   	"(cAliasOut)",UPPER(STR0068),	"@E 9,999,999,999.99999", 15,	/*lPixel*/,{|| (cAliasOut)->QTD })				//QUANTIDADE	
	
	oBreak:= TRBreak():New(oSectionOut, "" ,  , .F., 'NOMEBRK', .F.)	
	oSum  := TRFunction():New(oSectionOITEM:Cell('(cAliasOut)->QTD'),, 'SUM',oBreak,,,,.F.,.F.,.F., oSectionOut)
		
	/* Totalizadores */
				
	oReport:SetCustomText({|| TCabecDPMP( oReport )})
		
	oSectionTLabel := TRSection():New(oReport,STR0069,STR0069) //Totalizadores	
	oSectionTLabel:SetLineStyle(.T.)	
	oSectionTLabel:SetLinesBefore(1)
		
	oCell2 := TRCell():New(oSectionTLabel,"LABEL_TOTAL","",UPPER(STR0069),	/*Picture*/,  99,	/*lPixel*/) //TOTALIZADORES
	oCell2:oFontBody := TFont():New('Courier new',/*uPar2*/,-14,/*uPar4*/,.T., /*uPar6*/,/*uPar7*/ ,/*uPar8*/ , /*uPar9*/, .T. ) 	
	
	oSectionTOper := TRSection():New(oSectionTLabel,STR0069,STR0069)	//Totalizadores		
	oSectionTOper:SetLineStyle(.T.)	
	oSectionTOper:SetLinesBefore(1)	
			
	oCell := TRCell():New(oSectionTOper,"(cAliasTOT)->COD_OPERANP"," (cAliasTOT)", UPPER(STR0060),				/*Picture*/,  99,	/*lPixel*/,{|| TDescNatOpe((cAliasTOT)->COD_OPERANP, (cAliasTOT)->COD_ANP_NAT) })	//ANP NAT. OPER	
	oCell:lBold := .T.				
	
	oSectionTITEM := TRSection():New(oSectionTOper,STR0050,{"(cAliasTOT)"},{"C20_NUMDOC"})
	oCell := TRCell():New(oSectionTITEM,"(cAliasTOT)->COD_ANP_NAT",  	"(cAliasTOT)",UPPER(STR0060),				/*Picture*/,  15,	/*lPixel*/,{|| (cAliasTOT)->COD_ANP_NAT })	 //ANP NAT. OPER.
	oCell := TRCell():New(oSectionTITEM,"(cAliasTOT)->DESC_OPERANP", 	"(cAliasTOT)",UPPER(STR0070),				/*Picture*/,  50,	/*lPixel*/,{|| TDescNatOpe('', (cAliasTOT)->COD_ANP_NAT)}) //DESCRIÇÃO ANP NAT. OPER
	oCell := TRCell():New(oSectionTITEM,"(cAliasTOT)->COD_ANP_ITEM", 	"(cAliasTOT)",UPPER(STR0061),				/*Picture*/,  15,	/*lPixel*/,{|| (cAliasTOT)->COD_ANP_ITEM }) 	//ANP ITEM
	oCell := TRCell():New(oSectionTITEM,"(cAliasTOT)->DESC_ANP_ITEM",	"(cAliasTOT)",UPPER(STR0071),				/*Picture*/,  50,	/*lPixel*/,{|| (cAliasTOT)->DESC_ANP_ITEM })	//DESCRIÇÃO ANP ITEM
	oCell := TRCell():New(oSectionTITEM,"(cAliasTOT)->QTD",				"(cAliasTOT)",UPPER(STR0068),	"@E 9,999,999,999.99999", 15,	/*lPixel*/,{|| (cAliasTOT)->QTD })			//QUANTIDADE
	
	oBreak:= TRBreak():New( oSectionTOper, "(cAliasTOT)->COD_OPERANP" ,  , .F., 'NOMEBRK', .F.)	
	oSum  := TRFunction():New(oSectionTITEM:Cell('(cAliasTOT)->QTD'),, 'SUM',oBreak,,,,.F.,.F.,.F., oSectionTOper)	
	
	/* Movimentos do período não considerados na DPMP */
	
	oReport:SetCustomText({|| TCabecDPMP( oReport )})
		
	oSecDocNLabel := TRSection():New(oReport,STR0080,STR0080)
	oSecDocNLabel:SetLineStyle(.T.)	
	oSecDocNLabel:SetLinesBefore(2)
		
	oCell4 := TRCell():New(oSecDocNLabel,"LABEL_TOTAL","",UPPER(STR0080),/*Picture*/,99,/*lPixel*/)	
	oCell4:oFontBody := TFont():New('Courier new',/*uPar2*/,-14,/*uPar4*/,.T., /*uPar6*/,/*uPar7*/ ,/*uPar8*/ , /*uPar9*/, .T. ) 	
	
	oSecDocNOper := TRSection():New(oSecDocNLabel,STR0080,STR0080)
	oSecDocNOper:SetLineStyle(.T.)	
	oSecDocNOper:SetLinesBefore(2)	
			
	oSecDocNITEM := TRSection():New(oSecDocNOper,STR0080,{"(cAliasDocN)"},{"C20_NUMDOC"})
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->NUM_DOC",	"(cAliasDocN)",UPPER(STR0051),	          /*Picture*/,15,/*lPixel*/,{|| (cAliasDocN)->NUM_DOC }) 		//NOTA FISCAL
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->SERIE",	"(cAliasDocN)",UPPER(STR0052),	          /*Picture*/, 3,/*lPixel*/,{|| (cAliasDocN)->SERIE })			//SÉRIE
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->DTA_ES",	"(cAliasDocN)",UPPER(OEMTOANSI(STR0053)), /*Picture*/,10,/*lPixel*/,{|| SToD((cAliasDocN)->DTA_ES)}) 	//DATA EMISSAO
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->NATUREZA","(cAliasDocN)",UPPER(STR0059),			    /*Picture*/,30,/*lPixel*/,{|| Alltrim((cAliasDocN)->COD_NAT) + ' - ' + Alltrim((cAliasDocN)->DESC_NAT)}) //NATUREZA OPERAÇÃO	
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->ITEM",	"(cAliasDocN)",UPPER(STR0058),           /*Picture*/,60,/*lPixel*/,{|| Alltrim((cAliasDocN)->COD_ITEM) + ' - ' + Alltrim((cAliasDocN)->DESC_ITEM)}) //ITEM
	oCell := TRCell():New(oSecDocNITEM,"(cAliasDocN)->QUANT_ITEM","(cAliasDocN)",UPPER(STR0068),"@E 9,999,999,999.99999",16,/*lPixel*/,{|| (cAliasDocN)->QUANT_ITEM}) //QUANTIDADE
	
	oSecPrdNITEM := TRSection():New(oSecDocNOper,STR0080,{"(cAliasPrdN)"},{"T21_CODITE"})
	oCell := TRCell():New(oSecPrdNITEM,"(cAliasPrdN)->TP_PRD","(cAliasPrdN)",UPPER(STR0054),/*Picture*/, 				9,/*lPixel*/,{|| TDescTpPrd((cAliasPrdN)->TP_PRD) })			//Tipo de Utilização do Item na Produção
	oCell := TRCell():New(oSecPrdNITEM,"(cAliasPrdN)->ITEM", "(cAliasPrdN)",UPPER(STR0058),/*Picture*/,             60,/*lPixel*/,{|| Alltrim((cAliasPrdN)->COD_ITEM) + ' - ' + Alltrim((cAliasPrdN)->DESC_ITEM) }) //ITEM	
	oCell := TRCell():New(oSecPrdNITEM,"(cAliasPrdN)->QUANT","(cAliasPrdN)",UPPER(STR0068),"@E 9,999,999,999.99999",16,/*lPixel*/,{|| (cAliasPrdN)->QTD_PROD}) //QUANTIDADE
		
	/* ------------------------------------------------ */
	                                    
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

ReportPrint() - Query de consulta para extração do relatório

@Param
 oReport   - Objeto do relatório
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oSectionNF 	as object
	Local oSectionIT 	as object
	Local oSectionTOper as object
	Local oSectionTITEM as object
	Local oTFont    	as object	
	Local cNF 			as character
	Local cNatOper  	as character
	Local dIniAnt       as date
	Local dFinAnt       as date
	Local cAlias4    	as character
	Local cNotIn     	as character
	Local aInfoEUF 		as array
	Local cCompC1H 		as character
	Local cCompC1L 		as character
	Local cCompC1N		as character
	Local cCompC1J		as character
	Local cFilJC20   	as character
	Local cFilJC30   	as character
	Local cFilJT19		as character
	Local cFilJT21		as character   
	Local cFilJT22		as character   
	Local cJC1HxC20 	as character
	Local cJC1LxC30 	as character
	Local cJC1NxC30		as character
	Local cJC1JxC30		as character
	Local cJC1LxT19		as character
	Local cJC1LxT21		as character
	Local cJC1LxT22		as character
	
	Default oReport 	:= nil

	dIniAnt    := TAFSubMes( dInicial , 1 )
	dFinAnt    := LastDay(dIniAnt)
	cNotIn     := ""
	aInfoEUF   := {}
	cCompC1H   := ""   
	cCompC1L   := ""
	cCompC1N   := ""
	cJC1NxC30  := ""
	cJC1JxC30  := ""
	cCompC1J   := ""
	cJC1HxC20  := ""
	cJC1LxC30  := ""
	cJC1LxT19  := ""
	cJC1LxT21  := ""
	cJC1LxT22  := ""
	cFilJC20   := ""
	cFilJC30   := ""
	cFilJT19   := ""	
	cFilJT21   := ""
	cFilJT22   := ""
		
	oSectionNF := oReport:Section(1)
	oSectionIT := oSectionNF:Section(1)
	cNF := ""
	
	cNatCtaOrd := TDPMP456(dInicial)  
	/* Busca o Código da Instalação ANP da Filial */
	cInstalEst := POSICIONE("C1E",3,xFilial("C1E")+FWGETCODFILIAL+"1","C1E_CDINAN")

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H", 1) + FWModeAccess("C1H", 2) + FWModeAccess("C1H", 3)))
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))
	cCompC1N := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3)))
	cCompC1J := Upper(AllTrim(FWModeAccess("C1J", 1) + FWModeAccess("C1J", 2) + FWModeAccess("C1J", 3)))

	cFilJC20 := "C20.C20_FILIAL"
	cFilJC30 := "C30.C30_FILIAL"
	cFilJT19 := "T19.T19_FILIAL"	
	cFilJT21 := "T21.T21_FILIAL"
	cFilJT22 := "T22.T22_FILIAL"

	// Obtém as condições do join usando TAFCompDPMP e informações de aInfoEUF
	cJC1HxC20 := TAFCompDPMP("C1H", cCompC1H, aInfoEUF, cFilJC20)
	cJC1LxC30 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJC30)
	cJC1NxC30 := TAFCompDPMP("C1N", cCompC1N, aInfoEUF, cFilJC30)
	cJC1JxC30 := TAFCompDPMP("C1J", cCompC1J, aInfoEUF, cFilJC30)
	cJC1LxT19 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJT19)
	cJC1LxT21 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJT21)
	cJC1LxT22 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJT22)

	/* Busca notas de Remessa das Operações de Conta e Ordem */
	If !Empty(cNatCtaOrd)
		cAlias4 := TDPMPTerc(cNatCtaOrd, dInicial, dFinal)
		
		While (cAlias4)->(!EOF())			
			Iif (!Empty(cNotIn),cNotIn += ", '","")		 
			cNotIn +=  "'" + Alltrim((cAlias4)->C26_CHVNF) + "'"
			(cAlias4)->(DbSkip())		
		EndDo
		
		( cAlias4 )->( DbCloseArea() )
		
		If !Empty(cNotIn)
			cNotIn := "% AND C20.C20_CHVNF NOT IN (" + cNotIn + ")%"
		Else
			cNotIn := "%%"
		EndIf
	Else
		cNotIn := "%%"
	EndIf
			
	cAliasNF := GetNextAlias()
	
	BeginSql Alias cAliasNF
		SELECT C20_NUMDOC 	NUM_DOC,
		       C20_SERIE 	SERIE,		       
		       (CASE WHEN C20_INDOPE = %Exp:'0'% THEN C20_DTES WHEN C20_INDOPE = %Exp:'1'% THEN C20_DTDOC END) DTA_ES,
		       (CASE WHEN C20_INDOPE = %Exp:'0'% THEN %Exp:'ENTRADA'% WHEN C20_INDOPE = %Exp:'1'% THEN %Exp:'SAIDA'% END) IND_OPER,       
		       C1H_CODPAR COD_PART, 
		       C1H_NOME   DESC_PART,              
		       T5B_CODIGO COD_ATV, 
		       T5B_DESATI DESC_ATV,        
		       C1L_CODIGO COD_ITEM, 
		       C1L_DESCRI DESC_ITEM,       
		       C1N_CODNAT COD_NAT, 
		       C1N_DESNAT DESC_NAT,  
		       T5A_CODOPE COD_OPERANP, 
		       T5A_ESPECI DESC_OPERANP,  
		       C0G_CODIGO COD_ANP, 
		       C0G_DESCRI DESC_ANP,
		       T5C_CODIGO COD_CFQ, 
		       T5C_CARACT DESC_CFQ,
		       T5D_CODIGO COD_CNM, 
		       T5D_CARACT DESC_CNM,
		       T5E_CODIGO COD_GLP, 
		       T5E_VASILH DESC_GLP,
		       T5F_CODIGO COD_AFE, 
		       T5F_METODO DESC_AFE,
		       T59_CODIGO COD_UM, 
		       T59_UNMEDI DESC_UM,        
		       C1J_CODIGO UNID_MED,
		       C1L_CERTIF CERT_ANP,
		       C30_QUANT QUANT_ITEM       
		  FROM %table:C20% C20
		    INNER JOIN %table:C1H% C1H %Exp:cJC1HxC20% AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.%NotDel%
			INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xFilial:C02%  AND C02.C02_ID 	= C20.C20_CODSIT AND C02.%NotDel%
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
			INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID = C30.C30_NATOPE AND C1N.%NotDel%
			INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID = C30.C30_CODITE AND C1L.%NotDel%
			INNER JOIN %table:C1J% C1J %Exp:cJC1JxC30% AND C1J.C1J_ID = C30.C30_UM 	   AND C1J.%NotDel%
			INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%   AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%
			LEFT JOIN %table:T5C% T5C ON T5C.T5C_FILIAL = %xFilial:T5C%   AND T5C.T5C_ID 	= C1L.C1L_IDCFQ  AND T5C.%NotDel%
			LEFT JOIN %table:T5D% T5D ON T5D.T5D_FILIAL = %xFilial:T5D%   AND T5D.T5D_ID 	= C1L.C1L_IDCNM  AND T5D.%NotDel%
			LEFT JOIN %table:T5E% T5E ON T5E.T5E_FILIAL = %xFilial:T5E%   AND T5E.T5E_ID 	= C1L.C1L_IDGLP  AND T5E.%NotDel%
			LEFT JOIN %table:T5F% T5F ON T5F.T5F_FILIAL = %xFilial:T5F%   AND T5F.T5F_ID 	= C1L.C1L_IDAFE  AND T5F.%NotDel%
			LEFT JOIN %table:T59% T59 ON T59.T59_FILIAL = %xFilial:T59%   AND T59.T59_ID 	= C1L.C1L_IDUM   AND T59.%NotDel%
			LEFT JOIN %table:T5B% T5B ON T5B.T5B_FILIAL = %xFilial:T5B%   AND T5B.T5B_ID 	= C1H.C1H_IDATV  AND T5B.%NotDel%
			LEFT JOIN %table:T5A% T5A ON T5A.T5A_FILIAL = %xFilial:T5A%   AND T5A.T5A_ID 	= C1N.C1N_IDOPAN AND T5A.%NotDel%
		 WHERE C20.C20_FILIAL    = %xFilial:C20%
		   AND (C20_INDOPE = '0' AND C20.C20_DTES BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)% OR
		  		C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)%)
		   AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)		   
		   AND C20.%NotDel%
		   AND C1N.C1N_OBJOPE != '01' //DIF. USO E CONSUMO
		   %Exp:cNotIn%		  	
		ORDER BY C20.C20_INDOPE, C20.C20_DTES, C20.C20_DTDOC
	
	EndSQL	
		
	While !(cAliasNF)->(Eof()) .And. !oReport:Cancel()
		
		If cNF != (cAliasNF)->NUM_DOC
			If !Empty(cNF)				
				oReport:SkipLine(2)
				oSectionIT:Finish()				
			EndIf	
					
			oSectionNF:Init()			
			oSectionNF:PrintLine()			
			oSectionIT:Init()					
			
			cNF := (cAliasNF)->NUM_DOC
		EndIf
		
		oSectionIT:PrintLine()

		(cAliasNF)->(dbSkip())
	EndDo
	
	If !Empty(cNF)
		oSectionIT:Finish()
	EndIf		
	
	oSectionNF:Finish()	
	
	oSectionNF:SetHeaderPage(.F.)
	oSectionNF:SetHeaderBreak(.F.)
	oSectionNF:SetHeaderSection(.F.)	
	
	/*
	oReport:StartPage()
	oReport:SkipLine(1)
	oReport:Say(oReport:Row(),30,"TOTALIZADORES",oTFont)	
	oReport:SkipLine(3)
	*/	
	
	(cAliasNF)->(dbCloseArea())
	
	/* Operações de Produção - Itens Produzidos */
   
   oSectionOut   := oReport:Section(4)   
   oSectionOITEM := oSectionOut:Section(1)
   
   cAliasOut = GetNextAlias()
   
   oSectionOut:Init()
   oSectionOITEM:Init()
   
   BeginSQL Alias cAliasOut
   		SELECT T5A.T5A_CODOPE COD_OPERANP, 
   				T5A.T5A_ESPECI DES_OPERANP, 
   				C0G.C0G_CODIGO COD_ITEMANP, 
   				C0G.C0G_DESCRI DES_ITEMANP, 
   				SUM(T6L.T6L_QTDANP) QTD
		  FROM %table:T6L% T6L
		INNER JOIN %table:T5A% T5A ON T5A.T5A_ID = T6L.T6L_IDOANP AND T5A.%NotDel%
		INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = T6L.T6L_IDANPI AND C0G.%NotDel%
		WHERE T6L.T6L_FILIAL = %xFilial:T6L%
		  AND T6L.T6L_DTLANC BETWEEN %Exp:DTOS(dInicial)% AND %Exp:DTOS(dFinal)%
		  AND T6L.%NotDel%
		  AND T5A_CODOPE IN ('1021002','1021004','1021005','1022018','1022015')
		GROUP BY T5A.T5A_CODOPE, 
   				  T5A.T5A_ESPECI, 
   				  C0G.C0G_CODIGO, 
   				  C0G.C0G_DESCRI
   EndSql
   
   If !(cAliasOut)->(Eof())
	
		oTFont := TFont():New(,,,,.T.)
		
		oReport:Say(oReport:Row(),29,STR0087,oTFont)	
		oReport:SkipLine(2)
	EndIf
   
   
   While !(cAliasOut)->(Eof()) .And. !oReport:Cancel()
   		oSectionOITEM:PrintLine()
   		
   		(cAliasOut)->(dbSkip())	
   EndDo
   
   oSectionOITEM:Finish()
   oSectionOut:Finish()
   
   (cAliasOut)->(dbCloseArea())
   /* Operações Sem Documento Fiscal / Informações de Produção */
   
   oSectionOut   := oReport:Section(4)   
   oSectionOITEM := oSectionOut:Section(1)
   
   cAliasOut = GetNextAlias()
   
   oSectionOut:Init()
   oSectionOITEM:Init()
   
   BeginSQL Alias cAliasOut
   		SELECT T5A.T5A_CODOPE COD_OPERANP, 
   				T5A.T5A_ESPECI DES_OPERANP, 
   				C0G.C0G_CODIGO COD_ITEMANP, 
   				C0G.C0G_DESCRI DES_ITEMANP, 
   				SUM(T6L.T6L_QTDANP) QTD
		  FROM %table:T6L% T6L
		INNER JOIN %table:T5A% T5A ON T5A.T5A_ID = T6L.T6L_IDOANP AND T5A.%NotDel%
		INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = T6L.T6L_IDANPI AND C0G.%NotDel%
		WHERE T6L.T6L_FILIAL = %xFilial:T6L%
		  AND T6L.T6L_DTLANC BETWEEN %Exp:DTOS(dInicial)% AND %Exp:DTOS(dFinal)%
		  AND T6L.%NotDel%
		  AND T5A_CODOPE NOT IN ('1021002','1021004','1021005','1022018','1022015')
		GROUP BY T5A.T5A_CODOPE, 
   				  T5A.T5A_ESPECI, 
   				  C0G.C0G_CODIGO, 
   				  C0G.C0G_DESCRI
   EndSql
   
   If !(cAliasOut)->(Eof())
	
		oTFont := TFont():New(,,,,.T.)
		
		oReport:Say(oReport:Row(),29,STR0088,oTFont)	
		oReport:SkipLine(2)
	EndIf
   
   
   While !(cAliasOut)->(Eof()) .And. !oReport:Cancel()
   		oSectionOITEM:PrintLine()
   		
   		(cAliasOut)->(dbSkip())	
   EndDo
   
   oSectionOITEM:Finish()
   oSectionOut:Finish()
   
   (cAliasOut)->(dbCloseArea())
   
   /* Totalizadores */  		
		
	oSectionTLabel	:= oReport:Section(5)
	oSectionTOper		:= oSectionTLabel:Section(1)	
	oSectionTITEM		:= oSectionTOper:Section(1)
	cNatOper 		:= ""	
		
	cAliasTOT := GetNextAlias()
		
	BeginSQL Alias cAliasTOT
		SELECT SUBSTRING(T5A.T5A_CODOPE, 1,4) COD_OPERANP,
			   T5A_CODOPE COD_ANP_NAT,
			   T5A_ESPECI DESC_OPERANP,
			   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
			   SUM(C30.C30_QUANT) QTD
		  FROM %table:C20% C20
		  	INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xFilial:C02%  AND C02.C02_ID 	= C20.C20_CODSIT  AND C02.%NotDel%
		  	INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF   AND C30.%NotDel%		  			  			  
		  	INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID 	= C30.C30_CODITE AND C1L.%NotDel%
		  	INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%
		  	INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID	= C30.C30_NATOPE  AND C1N.%NotDel%		  			  	
		  	INNER JOIN %table:T5A% T5A ON T5A.T5A_FILIAL = %xFilial:T5A%  AND T5A.T5A_ID	= C1N.C1N_IDOPAN  AND T5A.%NotDel%		  	  
		 WHERE C20.C20_FILIAL = %xFilial:C20%
		   AND (C20.C20_INDOPE = '0' AND C20.C20_DTES BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)% OR
		         C20.C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)%)		   
		   AND C02.C02_CODIGO NOT IN (%Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
		   AND SUBSTRING(T5A.T5A_CODOPE, 4,1) > %Exp: '0'%
		   AND C1N.C1N_OBJOPE != '01' //DIF. USO E CONSUMO		   
		   AND C20.%NotDel%		         
		   GROUP BY SUBSTRING(T5A.T5A_CODOPE, 1,4), 
		   			T5A_CODOPE,
		   			T5A_ESPECI,
		   			C0G_CODIGO,
		   			C0G_DESCRI
	UNION
	   SELECT '1021' COD_OPERANP,
			   '' DESC_OPERANP,
			   '' COD_ANP_NAT,
			   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
			   SUM(T21.T21_QTDPRO) QTD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:C1L% C1L %Exp:cJC1LxT21% AND C1L.C1L_ID = T21.T21_CODITE AND C1L.%NotDel%
		   INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%			  	
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(dInicial)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(dFinal)%		  
		  AND T18.%NotDel%	    
		   GROUP BY	C0G_CODIGO,
		   			C0G_DESCRI
	UNION
		SELECT '1022' COD_OPERANP,
			   '' COD_ANP_NAT,
			   '' DESC_OPERANP,
			   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
			   SUM(T22.T22_QTDCON) QTD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:T22% T22 ON T22.T22_FILIAL = T21.T21_FILIAL AND T22.T22_CODOP = T21.T21_CODOP AND T22.T22_CODITE = T21.T21_CODITE AND T22.%NotDel%
		   INNER JOIN %table:C1L% C1L %Exp:cJC1LxT22% AND C1L.C1L_ID = T22.T22_CODINS AND C1L.%NotDel%		   
		   INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  			   
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(dInicial)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(dFinal)%
		  AND T18.%NotDel%      
		   GROUP BY 
		   			C0G_CODIGO,
		   			C0G_DESCRI
	UNION
		SELECT SUBSTRING(T5A.T5A_CODOPE, 1,4) COD_OPERANP,
				T5A.T5A_CODOPE COD_ANP_NAT, 
   				T5A.T5A_ESPECI DESC_OPERANP, 
   				C0G.C0G_CODIGO COD_ANP_ITEM, 
   				C0G.C0G_DESCRI DESC_ANP_ITEM, 
   				SUM(T6L.T6L_QTDANP) QTD
		  FROM %table:T6L% T6L
		INNER JOIN %table:T5A% T5A ON T5A.T5A_ID = T6L.T6L_IDOANP AND T5A.%NotDel%
		INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = T6L.T6L_IDANPI AND C0G.%NotDel%
		WHERE T6L.T6L_FILIAL = %xFilial:T6L%
		  AND T6L.T6L_DTLANC BETWEEN %Exp:DTOS(dInicial)% AND %Exp:DTOS(dFinal)%
		  AND T6L.%NotDel%
		   AND SUBSTRING(T5A.T5A_CODOPE, 4,1) > %Exp: '0'%		   
		GROUP BY SUBSTRING(T5A.T5A_CODOPE, 1,4),
				  T5A.T5A_CODOPE, 
   				  T5A.T5A_ESPECI, 
   				  C0G.C0G_CODIGO, 
   				  C0G.C0G_DESCRI
	EndSql
	
	oSectionTLabel:SetPageBreak(.T.)
	oSectionTLabel:Init()
	oSectionTLabel:PrintLine()
	
	While !(cAliasTOT)->(Eof()) .And. !oReport:Cancel()
		
		If AllTrim(cNatOper) != Alltrim((cAliasTOT)->COD_OPERANP)
			If !Empty(cNatOper)				
				oSectionTITEM:Finish()					
			EndIf
					
			oSectionTOper:Init()			
			oSectionTOper:PrintLine()			
			oSectionTITEM:Init()
			cNatOper := (cAliasTOT)->COD_OPERANP			
		EndIf
				
		oSectionTITEM:PrintLine()		
		(cAliasTOT)->(dbSkip())
	EndDo
	
	If !Empty(cNatOper)				
		oSectionTITEM:Finish()
	EndIf	
		
	oSectionTOper:Finish()
	
	(cAliasTOT)->(dbCloseArea())	
			
	/* Totalizadores - Estoque */	
	
	BeginSql Alias cAliasTOT
	 	SELECT "3010"  		COD_OPERANP,   
	 		   '3010003'	COD_ANP_NAT,	 		  	 		   
	 		   'Estoque inicial sem movimentação próprio' DESC_OPERANP,
	 		   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
	 		   SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dIniAnt)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinAnt)%
	  	   AND T19.T19_INDEST IN ('0','1')
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
		   		
	UNION	
		
		SELECT "3010"  		COD_OPERANP,  //estoque inicial 
	 		   '3010001' 	COD_ANP_NAT,	 		  	 		   
	 		   'Estoque inicial sem movimentação em terceiros' DESC_OPERANP,
	 		   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
	 		   SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dIniAnt)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinAnt)%
	  	   AND T19.T19_INDEST = '1'
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
		   		
	UNION
	
		SELECT "3010"  		COD_OPERANP,  //estoque inicial 
	 		   '3010002' 	COD_ANP_NAT,	 		  	 		   
	 		   'Estoque inicial sem movimentação de terceiros' DESC_OPERANP,
	 		   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
	 		   SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dIniAnt)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinAnt)%
	  	   AND T19.T19_INDEST = '2'
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
		   
	UNION
      SELECT "3020"  	COD_OPERANP,  //estoque inicial 
	 		  '3020003' COD_ANP_NAT,	 		  	 		   
	 		  'Estoque final sem movimentação próprio' DESC_OPERANP,
	 		  C0G_CODIGO COD_ANP_ITEM,
			  C0G_DESCRI DESC_ANP_ITEM,
	 		  SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dInicial)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinal)%
	  	   AND T19.T19_INDEST IN ('0','1')
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
		   		
	UNION	
		
		SELECT "3020"  		COD_OPERANP,  //estoque inicial 
	 		   '3020001' 	COD_ANP_NAT,	 		  	 		   
	 		   'Estoque final sem movimentação em terceiros' DESC_OPERANP,
	 		   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
	 		   SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dInicial)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinal)%
	  	   AND T19.T19_INDEST = '1'
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
		   		
	UNION
	
		SELECT "3020"  		COD_OPERANP,  //estoque inicial 
	 		   '3020002' 	COD_ANP_NAT,	 		  	 		   
	 		   'Estoque final sem movimentação de terceiros' DESC_OPERANP,
	 		   C0G_CODIGO COD_ANP_ITEM,
			   C0G_DESCRI DESC_ANP_ITEM,
	 		   SUM(T19_QTDEST) QTD
	 	  FROM %table:T18% T18
	 	 INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	   AND T19.%NotDel%
	  	 INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
	  	 INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%	  	 
	  	 WHERE T18.T18_FILIAL = %xFilial:T18%
	  	   AND T18.T18_DTINI >= %Exp: DTOS(dInicial)% 
	  	   AND T18.T18_DTFIN <= %Exp: DTOS(dFinal)%
	  	   AND T19.T19_INDEST = '2'
	  	   AND C1L.C1L_CODANP IS NOT NULL
	       AND C1L.C1L_CODANP != ' '
	       AND T18.%NotDel%  
	   GROUP BY C0G_CODIGO,
		   		C0G_DESCRI
	   ORDER BY COD_OPERANP
	EndSql
	
	While !(cAliasTOT)->(Eof()) .And. !oReport:Cancel()
		
		If AllTrim(cNatOper) != Alltrim((cAliasTOT)->COD_OPERANP)
			If !Empty(cNatOper)				
				oSectionTITEM:Finish()					
			EndIf	
					
			oSectionTOper:Init()			
			oSectionTOper:PrintLine()			
			oSectionTITEM:Init()
			cNatOper := (cAliasTOT)->COD_OPERANP			
		EndIf
				
		oSectionTITEM:PrintLine()		
		(cAliasTOT)->(dbSkip())
	EndDo
	
	If !Empty(cNatOper)				
		oSectionTITEM:Finish()
	EndIf		
	oSectionTOper:Finish()
	oSectionTLabel:Finish()
	(cAliasTOT)->(dbCloseArea())
	
	/* Movimentos do período não considerados na DPMP */
	
	oSecDocNLabel := oReport:Section(6)
	oSecDocNOper	:= oSecDocNLabel:Section(1)	
	oSecDocNITEM	:= oSecDocNOper:Section(1)
	oSecPrdNITEM	:= oSecDocNOper:Section(2)
	
	oSecDocNLabel:SetPageBreak(.T.)
	oSecDocNLabel:Init()
	oSecDocNLabel:PrintLine()
	
	oSecDocNOper:Init()			
	oSecDocNOper:PrintLine()
	
	/* Documentos Ficais não consideradas na DPMP */
				
	cAliasDocN := GetNextAlias()
	
	BeginSql Alias cAliasDocN
		SELECT C20_NUMDOC	NUM_DOC,
		       C20_SERIE	SERIE,
		       (CASE WHEN C20_INDOPE = %Exp:'0'% THEN C20_DTES WHEN C20_INDOPE = %Exp:'1'% THEN C20_DTDOC END) DTA_ES,		            
		       C1L_CODIGO	COD_ITEM, 
		       C1L_DESCRI	DESC_ITEM,       
		       C1N_CODNAT	COD_NAT, 
		       C1N_DESNAT	DESC_NAT,
		       SUM(C30_QUANT) QUANT_ITEM	             
		  FROM %table:C20% C20		    
			INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xFilial:C02%  AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel%
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
			INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID = C30.C30_NATOPE AND C1N.%NotDel%
			INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30% AND C1L.C1L_ID = C30.C30_CODITE AND C1L.%NotDel%					
		 WHERE C20.C20_FILIAL    = %xFilial:C20%		   
		   AND (C20_INDOPE = '0' AND C20.C20_DTES BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)% OR
		         C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN %Exp: dtos(dInicial)%  AND %Exp: dtos(dFinal)%)
		   AND C20.%NotDel%
		   AND C02.C02_CODIGO NOT IN (%Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)		   
		   AND (C1L.C1L_CODANP IS NULL OR C1L.C1L_CODANP = ' ')		   		  	
		GROUP BY C20_INDOPE,
		         C20_NUMDOC,
		         C20_SERIE,
		         C20_DTES,	
		         C20_DTDOC,	            
		         C1L_CODIGO, 
		         C1L_DESCRI,       
		         C1N_CODNAT, 
		         C1N_DESNAT
		ORDER BY C20_INDOPE,
		         C20_NUMDOC,
		         C20_SERIE,
		         C20_DTES,	
		         C20_DTDOC,	            
		         C1L_CODIGO,
		         C1N_CODNAT
	EndSQL
	
	If !(cAliasDocN)->(Eof())
	
		oTFont := TFont():New(,,,,.T.)
		
		oReport:Say(oReport:Row(),29,STR0050,oTFont)	
		oReport:SkipLine(1)
	EndIf
	
	oSecDocNITEM:Init()	
	
	While !(cAliasDocN)->(Eof()) .And. !oReport:Cancel()
									
		oSecDocNITEM:PrintLine()		

		(cAliasDocN)->(dbSkip())
	EndDo	
	
	oSecDocNITEM:Finish()
	
	/* Itens das Operações de Produção não considerados na DPMP */
	
	cAliasPrdN := GetNextAlias()
	
	BeginSql Alias cAliasPrdN
		SELECT	'1' TP_PRD,
				C1L_CODIGO	COD_ITEM, 
		       C1L_DESCRI	DESC_ITEM, 
		       SUM(T21.T21_QTDPRO) QTD_PROD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:C1L% C1L %Exp:cJC1LxT21% AND C1L.C1L_ID = T21.T21_CODITE AND C1L.%NotDel%		   			  
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(dInicial)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(dFinal)%
		  AND T18.%NotDel%
		  AND (C1L.C1L_CODANP IS NULL OR C1L.C1L_CODANP = ' ')	
		GROUP BY C1L_CODIGO, 
		         C1L_DESCRI		
	UNION
		SELECT	'2' TP_PRD,
				C1L_CODIGO	COD_ITEM, 
		       C1L_DESCRI	DESC_ITEM, 
		       SUM(T22.T22_QTDCON) QTD_PROD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:T22% T22 ON T22.T22_FILIAL = T21.T21_FILIAL AND T22.T22_CODOP = T21.T21_CODOP AND T22.T22_CODITE = T21.T21_CODITE AND T22.%NotDel%
		   INNER JOIN %table:C1L% C1L %Exp:cJC1LxT22% AND C1L.C1L_ID = T22.T22_CODINS AND C1L.%NotDel%		   			  
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(dInicial)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(dFinal)%
		  AND T18.%NotDel%
		  AND (C1L.C1L_CODANP IS NULL OR C1L.C1L_CODANP = ' ')	
		GROUP BY C1L_CODIGO, 
		         C1L_DESCRI
	EndSql
	
	If !(cAliasPrdN)->(Eof())	
		oTFont := TFont():New(,,,,.T.)
	
		oReport:SkipLine(1)
		oReport:Say(oReport:Row(),29,STR0087,oTFont)	
		oReport:SkipLine(1)			
	EndIf
	
	oSecPrdNITEM:Init()
	
	While !(cAliasPrdN)->(Eof()) .And. !oReport:Cancel()
							
		oSecPrdNITEM:PrintLine()			

		(cAliasPrdN)->(dbSkip())
	EndDo	
	
	oSecPrdNITEM:Finish()
	
	oSecDocNOper:Finish()
	oSecDocNLabel:Finish()
		
	(cAliasDocN)->(dbCloseArea())	
	(cAliasPrdN)->(dbCloseArea())
	
	/* ----------------------------------------------- */
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCabecDPMP

TCabecDPMP() - Montagem do cabeçalho do relatório

@Param
 oReport   - Objeto do relatório
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TCabecDPMP( oReport as object )

Local aArea     as array
Local aCabec    as array
Local cChar     as char

	aArea     := GetArea()
	aCabec    := {}
	cChar     := chr(160)  // caracter dummy para alinhamento do cabeçalho
	
	If SM0->(Eof())                                
	    SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif
	
	aCabec := {    "__LOGOEMP__" , cChar + "            " ;
	          + "            " + cChar + RptFolha + TRANSFORM(oReport:Page(),'9999');
	          , cChar + "            " ;
	          + "            " + cChar ;
	          , "SIGATAF /" + 'DPMP' + " /v." + cVersao ; 
	          + "            " + cChar + UPPER( oReport:CTITLE ) ; 
	          + "            " + cChar;
	          , "            " + cChar + RptEmiss + " " + Dtoc(dDataBase);
	          ,(STR0072 + "...........: " +Trim(SM0->M0_NOME) + " / " + STR0073+": " + Trim(SM0->M0_FILIAL));  //"Empresa:"  "Filial:"
	          + "            " + cChar + "Hora:  " + " " + time();
	          ,(STR0074+"....: " + DTOC(dInicial) + " à " + DTOC(dFinal)); //Período Gerado:
	          ,(STR0040  + ": " + Trim(cCodRegAnp)); //"Cód. Regulador ANP:"
	          , cChar + "            " }
	
	RestArea( aArea )
              
Return aCabec


static function TDescNatOpe(cNatOperMin as char, cNatOper as char)

 Local cDesc as char 
 
 If cNatOperMin == "3010" .OR. cNatOperMin == "3020" //ESTOQUE 
 	cDesc := Alltrim(cNatOperMin) + " - " + IIF(cNatOperMin == "3010", "Estoque Inicial", "Estoque Final")
 ElseIf cNatOperMin == "" 
 	cDesc := cNatOper + " - " + POSICIONE( "T5A" , 2 , xFilial( "T5A" ) + cNatOper , "T5A_ESPECI")
 Else
 	cDesc := Alltrim(cNatOperMin) + "998" + " - " + POSICIONE( "T5A" , 2 , xFilial( "T5A" ) + Alltrim(cNatOperMin) + "998" , "T5A_ESPECI")
 EndIf

Return cDesc

static function TDescTpPrd(cTipoNat as char)

 Local cDesc as char 
 
 If cTipoNat == "1"  
 	cDesc := STR0085
 Else
 	cDesc := STR0086
 EndIf

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaOpTot

SomaOpTot() - Realiza a soma das operações de totalizadores da DPMP (ANP)

@Author Francisco Kennedy Nunes Pinheiro
@Since 22/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function SomaOpTot( nQtdPrdANP, nQtdPrdKG, cOperacao, cInstal1, cProdANP, cTipoOper, aTotalizFn, aTotaliz )
		
	Local lInsTotFin := .T.
	Local lInsTotGer := .T.
	Local nPos       := 0
			
	Local cOperacTot := ""	 
	Local cInstalTot := ""
	Local cProdTot   := ""
		
	FOR nPos := 1 TO Len(aTotalizFn) 
		
       cOperacTot := TRIM(aTotalizFn[nPos][1])
		cInstalTot := TRIM(aTotalizFn[nPos][2])
		cProdTot   := TRIM(aTotalizFn[nPos][3])
							   
       If SUBSTR(cOperacTot,1,4) = SUBSTR(cOperacao,1,4) .AND. cInstalTot = cInstal1 .AND. cProdTot = cProdANP	      
          aTotalizFn[nPos][4] := aTotalizFn[nPos][4] + nQtdPrdANP  
          aTotalizFn[nPos][5] := aTotalizFn[nPos][5] + nQtdPrdKG
          lInsTotFin := .F.
       EndIf  
	   	   
	NEXT
	
	If lInsTotFin	= .T.	 
	   cOperacTot := SUBSTR(cOperacao,1,4) + "998"
	    	 
	   AADD(aTotalizFn,{cOperacTot,cInstal1,cProdANP,nQtdPrdANP,nQtdPrdKG})	  
	EndIf
	
	FOR nPos := 1 TO Len(aTotaliz)
	
		cOperacTot := TRIM(aTotaliz[nPos][1])
		cInstalTot := TRIM(aTotaliz[nPos][2])
		cProdTot   := TRIM(aTotaliz[nPos][3])
	
		If ((cTipoOper = "0" .AND. cOperacTot = "4011998") .OR. (cTipoOper = "1" .AND. cOperacTot = "4012998")) .AND. cInstalTot = cInstal1 .AND. cProdTot = cProdANP	      
	      aTotaliz[nPos][4] := aTotaliz[nPos][4] + nQtdPrdANP  
	      aTotaliz[nPos][5] := aTotaliz[nPos][5] + nQtdPrdKG
	      lInsTotGer := .F.
	   EndIf 
	
	NEXT
	
	If lInsTotGer = .T.
	   If cTipoOper = "0" // Entrada
	      cOperacTot := "4011998"
	   Else
	      cOperacTot := "4012998"
	   EndIf
	   
	   AADD(aTotaliz,{cOperacTot,cInstal1,cProdANP,nQtdPrdANP,nQtdPrdKG})	
	EndIf
	
Return( aTotaliz )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCompDPMP

Função para tratar o JOIN para tabelas compartilhadas

@Author Jose Felipe
@Since 18/07/2024
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFCompDPMP(cAlias, cComp, aInfoEUF, cFilComp)
    Local cJoin := ""
    Local cAlsBase := SubStr(cAlias, 1, 3) // Usa apenas os primeiros 3 caracteres do alias

    If cComp == "EEE"
        cJoin := "% ON " + cAlias + "." + cAlsBase + "_FILIAL = " + cFilComp + " %"
    Else
        If cComp == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cJoin := "% ON SUBSTRING(" + cAlias + "." + cAlsBase + "_FILIAL, 1, " + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(" + cFilComp + ", 1, " + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") %"
        ElseIf cComp == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cJoin := "% ON SUBSTRING(" + cAlias + "." + cAlsBase + "_FILIAL, 1, " + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(" + cFilComp + ", 1, " + cValToChar(aInfoEUF[1]) + ") %"
        Else
            cJoin := "% ON " + cAlias + "." + cAlsBase + "_FILIAL = '" + xFilial(cAlias) + "' %"
        EndIf
    EndIf

Return cJoin
