#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "TAFXDESBH.ch"

#Define cObrig "DES - Belo Horizonte MG" 

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDBH 

Esta rotina tem como objetivo a geracao do Arquivo DES - Declaração Eletrônica de Serviços

@Author João Vitor Spieker
@Since 18/09/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------------------
Function TAFXDBH()

Local cNomWiz    as char
Local lEnd       as logical
Local cFunction	 as char
Local nOpc       as numeric

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private cIndOpe   as char
Private dInicial  as date
Private dFinal    as date
Private oProcess  as object
Private lCancel   as logical
Private lBrwServ  as logical
Private cCodServ  as char
Private cOpe	  as char

	cNomWiz	  := cObrig + FWGETCODFILIAL
	lEnd	  := .F.
	lCancel	  := .F.
	oProcess  := Nil
	cFunction := ProcName()
	nOpc      := 2 //View

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

	//Protect Data / Log de acesso / Central de Obrigacoes
	Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

   	//Cria objeto de controle do processamento
   	oProcess := TAFProgress():New( { |lEnd| ProcDBH( @lEnd, @oProcess, cNomWiz ) }, "" )
   	oProcess:Activate()

	If !lCancel
		If (MSGYESNO( STR0001, STR0002)) //"Deseja gerar o relatório de conferência?", Atenção!
			TDBHRelat()
	   	EndIf
	EndIf

   //Limpando a memória
   DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcDBH

Inicia o processamento para geracao da DESBH


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da DES
	   cNomWiz   -> Nome da Wizard criada para a DES


@Return ( Nil )

@Author João Vitor Spieker
@Since 18/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Static Function ProcDBH( lEnd as logical, oProcess as object, cNomWiz as char)

Local cErrorDBH   as char
Local cErrorTrd   as char
Local nX          as numeric
Local nPos        as numeric
Local nProgress1  as numeric
Local nCont       as numeric
Local aWizard     as array
Local lProc       as logical
Local cInsc  	  as char
Local cCNPJ       as char
Local nAuxCid     as numeric
Local nAuxEst     as numeric
Local nIdUf       as numeric

Private lBrwNat   as logical
Private lBrwIte   as logical
Private lBrwPar   as logical
	
	cErrorDBH  := ""
	cErrorTrd   := ""	
	lBrwNat     := .F.
	lBrwIte     := .F.
	lBrwPar     := .F.
	
	nX          := 0
	nPos        := 0
	nProgress1  := 0 
	
	aWizard     := {}
	
	lProc       := .T.
	nCont       := 1	
	

	
	//Carrega informações na wizard
	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf	
	
	cCNPJ     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CGC")    // CNPJ
	cInsc     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")   //Inscrição Municipal
	dInicial  := aWizard[1,1]  
	dFinal    := aWizard[1,2]
	
	If aWizard[1,5] == '1 - Serviços Tomados'
		cIndOpe := 'R'
		cOpe	:= '0'
    ElseIf aWizard[1,5] == '2 - Serviços Prestados'
       	cIndOpe := 'P'
       	cOpe	:= '1'
	Elseif(aWizard[1,5] == '3 - Ambos')
		cIndOpe := 'A'
		cOpe	:= '2'
	Endif
	
	If TAFConsServ(dInicial, dFinal)
	 	If (MSGYESNO( STR0003, STR0002 ))//"Para o período selecionado existem documentos fiscais com campos da natureza de operação não informados. Esses documentos não serão considerados. Deseja informá-los?" "Atenção!"
			If !TAFCadAdic(dInicial, dFinal)
			 	lProc := MSGYESNO( STR0004, STR0002 ) //"Deseja gerar a obrigação sem finalizar o cadastro dos campos da natureza de operação?", "Atenção!" 	 	 
			EndIf
		EndIF	
    EndIf
	
	If lProc
		
		//Alimentando a variável de controle da barra de status do processamento
		nProgress1 := 2
		oProcess:Set1Progress( nProgress1 )
	
		//Iniciando o Processamento
		oProcess:Inc1Progress(STR0005) //"Preparando o Ambiente" 
		oProcess:Inc1Progress( STR0006 ) //"Executando o Processamento..."
		
		//************************************************************************
		//Geração DES - Belo Horizonte MG - Aqui vão a chamada das funções da geração dos registros
		
		TAFDBHH(cCNPJ, cInsc)
		
		If aWizard[1,5] == '2 - Serviços Prestados' .or. aWizard[1,5] == '3 - Ambos'
			TAFDBHE(aWizard)
		EndIf
		
		If aWizard[1,5] == '1 - Serviços Tomados' .or. aWizard[1,5] == '3 - Ambos'
			TAFDBHR(aWizard)
		EndIf
		
		//TAFDEST(aTotais)	
							
		//************************************************************************
		//********* FIM da chamada das funções da geração dos registros **********
		//************************************************************************		
	Else
		oProcess:Inc1Progress(STR0007)	//"Processamento cancelado"
		oProcess:Inc2Progress(STR0008)	//"Clique em Finalizar"  
		oProcess:nCancel = 1
	EndIf
	
	//Tratamento para quando o processamento tem problemas
	
	If oProcess:nCancel == 1 .or. !Empty( cErrorDBH ) .or. !Empty( cErrorTrd )
	
		//Cancelado o processamento
		If oProcess:nCancel == 1
	
			//Aviso( "Atenção" "A geração do arquivo foi cancelada com sucesso!" "Sair", "" ) 	//
			lCancel := .T.
	
		//Erro na inicialização das threads
		ElseIf !Empty( cErrorTrd )
	
			Aviso( STR0002 , cErrorTrd, { STR0009 } ) //"Atenção" "Sair"    
	
		//Erro na execução dos Blocos
		Else
	
			cErrorDBH := STR0010    //"Ocorreu um erro fatal durante a geração do(s) Registro(s) da DES - BH" 
			cErrorDBH += STR0011   + Chr( 10 ) + Chr( 10 )//"Favor efetuar o reprecessamento da DES - BH, caso o erro persista entre em contato com o administrador de sistemas / suporte TOTVS"			
			/*Aviso( STR0006, cErrorDBH, { STR0008 } )*/
	
		EndIf
	
	Else
	
		//Atualizando a barra de processamento
		oProcess:Inc1Progress( STR0012 )	//"Informações processadas" 
		oProcess:Inc2Progress( STR0013 )	//"Consolidando as informações e gerando arquivo..." 		
	
		If GerArqCons( aWizard )			
			//Atualizando a barra de processamento
			oProcess:Inc2Progress( STR0014 ) //"Arquivo gerado com sucesso." 			
			msginfo(STR0014) 					 //"Arquivo gerado com sucesso." 
		Else
			oProcess:Inc2Progress( STR0015 ) 	//"Falha na geração do arquivo." 			
		EndIf	
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author João Vitor Spieker
@Since 18/09/2017
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens	:= {}

	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}

   	

	aAdd (aTxtApre, STR0016) //"Processando Empresa." 
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0017) //"Preencha corretamente as informações solicitadas."
	aAdd (aTxtApre, STR0018) //"Informações necessárias para a geração do meio-magnético DES - Belo Horizonte MG."
	aAdd (aItens, "1 - Serviços Tomados" ) 
	aAdd (aItens, "2 - Serviços Prestados" )
	aAdd (aItens, "3 - Ambos" )
	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0017) //"Preencha corretamente as informações solicitadas." 
	aAdd (aPaineis[nPos], STR0018) //"Informações necessárias para a geração do meio-magnético DES - Belo Horizonte MG."
	aAdd (aPaineis[nPos], {})

	//Coluna1			
	//Coluna1														//Coluna 2
	cTitObj1	:=	"Período referência de:";						cTitObj2    :=	"Até: "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {2,,,3,,,,});  	      		        aAdd (aPaineis[nPos][3], {2,,,3,,,,})   // calendário

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
																	//Coluna 2
	cTitObj1	:=	"Diretório do Arquivo Destino";					cTitObj2	:=	"Nome do Arquivo Destino"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 100);					    	cTitObj2	:=	Replicate ("X", 100)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	
	cTitObj1 := "Serviços Gerados" 								
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} );			aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	aAdd (aPaineis[nPos,3], { 3,,,,,aItens,,,,,});			aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
		
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha	 	 

	//PAINEL 1
	//PAINEL 1
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	/*aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético DES")
	aAdd (aPaineis[nPos], {})*/
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDBH() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDBH

Geracao do Arquivo TXT da DESBH.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pela DESBH
        lCons   -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author João Vitor Spieker
@Since 18/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDBH( nHandle as numeric, cTXTSys as char, cReg as char)
	
	Local cDirName	as char
	Local cFileDest	as char
	Local lRetDir		as logical
	Local lRet			as logical

	cDirName	:=	TAFGetPath( "2" , "DESBH" )
	cFileDest	:=	""
	lRetDir	:= .T.
	lRet		:= .T.
	
	//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
	if !File( cDirName )
	
		lRetDir := FWMakeDir( cDirName )
	
		if !lRetDir
	
			cDirName	:=	""
	
	
			Help( ,,"CRIADIR",, STR0019 + cValToChar( FError() ) , 1, 0 )   //"Não foi possível criar o diretório \Obrigacoes_TAF\DESBH . Erro:"
	
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
/*/{Protheus.doc} GerArqCons

Geracao do Arquivo .TXT da DESBH. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author João Spieker
@Since 18/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerArqCons( aWizard as array )

Local cFileDest  	as char
Local cPathTxt		as char
Local cStrTxtFIM	as char
Local cTxtSys		as char
Local nx			as numeric
Local nHandle		as numeric
Local aFiles		as array

	cFileDest	:=	Alltrim( aWizard[1][3] ) 		    //diretorio onde vai ser gerado o arquivo consolidado
	cPathTxt	:=	TAFGetPath( "2" , "DESBH" )			//diretorio onde foram gerados os arquivos txt temporarios
	nx			:=	0
	cTxtSys	:=	CriaTrab( , .F. ) + ".TXT"
	nHandle	:=	MsFCreate( cTxtSys )
	aFiles		:=	{}
	cStrTxtFIM	:= ""

	cNomeArq	:= Alltrim(aWizard[1,4])

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

	aFiles := DBHFilesTxt(cPathTxt)
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
/*/{Protheus.doc} DBHFilesTxt

DBHFilesTxt() - Arquivos por bloco da DESBH

@Author João Vitor Spieker
@Since 18/09/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function DBHFilesTxt( cPathTxt as char )

Local aRet	as array

	aRet	:=	{}
	
	AADD(aRet,{cPathTxt + "DBH_H.TXT"})  // Registro H    - Identificador do contribuinte
	AADD(aRet,{cPathTxt + "DBH_E.TXT"}) 
	AADD(aRet,{cPathTxt + "DBH_R.TXT"}) 
	
Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConsServ()

TAFConsServ() - Consulta no cadastro de Produto para os movimentos do período,
				para verificar se existe campo não preenchido. 
@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 
 @Return
 lExist  - Indica se existe algum cadastro com ANP em branco. 

@Author João Vitor Spieker
@Since 09/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFConsServ(dIni as date, dFim as date)
 
 Local cAliasQry	as char 
 
 
 cAliasQry 		:= GetNextAlias() 
 
 	BeginSQL Alias cAliasQry
			SELECT COUNT(*) COUNT
		 	  FROM %table:C20% C20	
		INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
		INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL = %xFilial:C1N% AND C1N.C1N_ID    = C30.C30_NATOPE AND C1N.%NotDel%
		 	 WHERE C20.C20_FILIAL = %xFilial:C20%	 	    
		 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%	 	   
		 	   AND (C1N.C1N_IDMOT IS NULL OR C1N.C1N_IDMOT = ' '		 	   
	 	   OR C1N.C1N_IDREG IS NULL OR C1N.C1N_IDREG = ' '
		 	   OR C1N.C1N_IDTIPO IS NULL OR C1N.C1N_IDTIPO = ' '	 	   
	 	   OR C1N.C1N_IDSIT IS NULL OR C1N.C1N_IDSIT = ' '
	 	   OR C1N.C1N_IDEXIG IS NULL OR C1N.C1N_IDEXIG = ' ')
		 	   AND C20.%NotDel%
		 	   
   
	    EndSQL 
   
		

 IIF ((cAliasQry)->COUNT > 0, lBrwServ := .T., lBrwServ := .F.)  

 (cAliasQry)->(DbCloseArea())
   
Return lBrwServ

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCadAdic

Cadastro adicional para manutenção dos campos da natureza de operação

@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 

@Author João Vitor Spieker
@Since 09/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFCadAdic(dIni as date, dFim as date)

Local nOpc         as numeric
Local aArea	       as array
Local aAlter       as array
Local lOk          as logical
Local aIDRec       := {}

Private aColsGrid  as array
Private aHeader    as array
Private oBrowDBH   as object
Private oDlg1      as object
Private noBrw      as numeric

	
	nOpc		:= GD_UPDATE	
	aArea		:= GetArea()	
	
	If lBrwServ
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeader	:= {}
		oBrowDBH 	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		TAFADBHBrw()
		aIDRec := TAFADBHCols(dInicial, dFinal)	
		
			aAdd(aAlter,aHeader[3,2])
			aAdd(aAlter,aHeader[5,2])
			aAdd(aAlter,aHeader[7,2])
			aAdd(aAlter,aHeader[9,2])
			aAdd(aAlter,aHeader[11,2])
		
		oDlg1    := MSDialog():New( 091,232,502,900,STR0020,,,.F.,,,,,,.T.,,,.T. )//"Natureza de Operação"
	    
	    DbSelectArea("C1N")
		oBrowDBH := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeader, aColsGrid)
		
		oBrowDBH:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid(aIDRec), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
		
	RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADBHBrw

TAFADBHBrw() - Monta aHeader da MsNewGetDados
@Param 
 cAlias  - Alias principal que será alterado 

@Author João Vitor Spieker
@Since 09/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFADBHBrw()
	
Local aC1N		:= {'C1N_CODNAT','C1N_DESNAT','C1N_CODMOT','C1N_DESMOT','C1N_CODREG','C1N_DESREG','C1N_CODTIP','C1N_DESTIP','C1N_CODSIT','C1N_DESSIT','C1N_CODEXI','C1N_DESEXI'} 
Local aCpoDel := {'alias wt','recno wt'} //Campos que serão retirados do aHeader da GetDados
Local nPosCpo := 0
Local i := 0

//Carrega o aHeader com os campos da tabela CWX
FillGetDados(4,'C1N',/*nOrder*/,/*cSeekKey*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,aC1N,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.t./*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,/*lUserFields*/,/*aYesUsado*/)

//Tira o campos do controle da GetDados do aHeader ( 'alias wt' e 'recno wt' )
for i := 1 to len(aCpoDel)
	nPosCpo := aScan(aHeader, {|x| lower(x[1]) == aCpoDel[i]} )
	if nPosCpo > 0
		aDel(aHeader,nPosCpo)
		aSize(aHeader,len(aHeader)-1)
	endif
next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADBHCols()

TAFA456Cols() - Monta aColsGrid da MsNewGetDados

@Param 
 cAlias  - Alias principal que será alterado
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard 

@Author João Vitor Spieker
@Since 09/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFADBHCols(dIni as date, dFim as date)
Local nX         as numeric
Local nY         as numeric
Local cAliasQry  as char
local aIDRec     := {}
 
 nX        := 0
 nY        := 0

 cAliasQry := GetNextAlias()
 	
		BeginSQL Alias cAliasQry
			 	SELECT DISTINCT 
			 		   'DOC' TIPO,
			 	        C1N_CODNAT,
				        C1N_DESNAT,
				        T81_CODIGO,
				        T81_DESCRI,
			 	    	T82_CODIGO,
			 	    	T82_DESCRI,
			 	    	T83_CODIGO,
			 	    	T83_DESCRI,
			 	    	T84_CODIGO,
			 	    	T84_DESCRI,
			 	    	T85_CODIGO,
			 	    	T85_DESCRI, 
				       ""         ID
			 	  FROM %table:C20% C20
			INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
			INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL = C30.C30_FILIAL AND C1N.C1N_ID    = C30.C30_NATOPE AND C1N.%NotDel%
			LEFT JOIN %table:T81% T81 ON T81.T81_FILIAL = %xFilial:T81% AND T81.T81_ID 	= C1N.C1N_IDMOT	 AND T81.%NotDel%
			LEFT JOIN %table:T82% T82 ON T82.T82_FILIAL = %xFilial:T82% AND T82.T82_ID 	= C1N.C1N_IDREG	 AND T82.%NotDel%
			LEFT JOIN %table:T83% T83 ON T83.T83_FILIAL = %xFilial:T83% AND T83.T83_ID 	= C1N.C1N_IDTIPO AND T83.%NotDel%
			LEFT JOIN %table:T84% T84 ON T84.T84_FILIAL = %xFilial:T84% AND T84.T84_ID 	= C1N.C1N_IDSIT	 AND T84.%NotDel%
			LEFT JOIN %table:T85% T85 ON T85.T85_FILIAL = %xFilial:T85% AND T85.T85_ID 	= C1N.C1N_IDEXIG AND T85.%NotDel%			
			 	 WHERE C20.C20_FILIAL = %xFilial:C20%			 	 
			 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%		 	   	 	   
			 	   AND (C1N.C1N_IDMOT IS NULL OR C1N.C1N_IDMOT = ' '
			 	   OR C1N.C1N_IDREG IS NULL OR C1N.C1N_IDREG = ' '
			 	   OR C1N.C1N_IDTIPO IS NULL OR C1N.C1N_IDTIPO = ' '
			 	   OR C1N.C1N_IDSIT IS NULL OR C1N.C1N_IDSIT = ' '
			 	   OR C1N.C1N_IDEXIG IS NULL OR C1N.C1N_IDEXIG = ' ')
			 	   AND C20.%NotDel%	
			 	   GROUP BY C1N_CODNAT,
					        C1N_DESNAT,
					        T81_CODIGO,
					        T81_DESCRI,
				 	    	T82_CODIGO,
				 	    	T82_DESCRI,
				 	    	T83_CODIGO,
				 	    	T83_DESCRI,
				 	    	T84_CODIGO,
				 	    	T84_DESCRI,
				 	    	T85_CODIGO,
				 	    	T85_DESCRI
	           	 	  
	        		 	  
		EndSql
	
	 While (cAliasQry)->(!Eof())
	 	AADD(aColsGrid,Array(Len(aHeader)+1))	
		aColsGrid[Len(aColsGrid)][1]  := (cAliasQry)->C1N_CODNAT
		aColsGrid[Len(aColsGrid)][2]  := substr((cAliasQry)->C1N_DESNAT,   1, 50)
		
			If (!Empty((cAliasQry)->T81_CODIGO))
				aColsGrid[Len(aColsGrid)][3]  := (cAliasQry)->T81_CODIGO
				aColsGrid[Len(aColsGrid)][4]  := (cAliasQry)->T81_DESCRI
			Else
				aColsGrid[Len(aColsGrid)][3]  := space(2)   
				aColsGrid[Len(aColsGrid)][4]  := space(60)
			EndIf
			
			If (!Empty((cAliasQry)->T82_CODIGO))
				aColsGrid[Len(aColsGrid)][5]  := (cAliasQry)->T82_CODIGO
				aColsGrid[Len(aColsGrid)][6]  := (cAliasQry)->T82_DESCRI
			Else
				aColsGrid[Len(aColsGrid)][5]  := space(2)   
				aColsGrid[Len(aColsGrid)][6]  := space(60)
			EndIf		
			
			If (!Empty((cAliasQry)->T83_CODIGO))
				aColsGrid[Len(aColsGrid)][7]  := (cAliasQry)->T83_CODIGO
				aColsGrid[Len(aColsGrid)][8]  := (cAliasQry)->T83_DESCRI
			Else
				aColsGrid[Len(aColsGrid)][7]  := space(2)   
				aColsGrid[Len(aColsGrid)][8]  := space(80)
			EndIf
			
			If (!Empty((cAliasQry)->T84_CODIGO))
				aColsGrid[Len(aColsGrid)][9]  := (cAliasQry)->T84_CODIGO
				aColsGrid[Len(aColsGrid)][10]  := (cAliasQry)->T84_DESCRI
			Else
				aColsGrid[Len(aColsGrid)][9]  := space(2)   
				aColsGrid[Len(aColsGrid)][10]  := space(80)
			EndIf
		
			If (!Empty((cAliasQry)->T85_CODIGO))
				aColsGrid[Len(aColsGrid)][11]  := (cAliasQry)->T85_CODIGO
				aColsGrid[Len(aColsGrid)][12]  := (cAliasQry)->T85_DESCRI
			Else
				aColsGrid[Len(aColsGrid)][11]  := space(2)   
				aColsGrid[Len(aColsGrid)][12]  := space(80)
			EndIf			
	
		aColsGrid[Len(aColsGrid),Len(aHeader)+1]:=.F.
		
		aAdd(aIDRec, (cAliasQry)->ID)
	
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea()) 
 
Return aIDRec

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGrid

Atualiza natureza de operação na tabela informada por parâmetro

@Param 
cAlias - Tabela onde será realizada a atualização

@Return 
ADM
@Author João Vitor Spieker
@Since 09/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaGrid(aIDRec)
Local nX         as numeric
local aIDRec     := {}

	lAlterou := .F.
	
	Begin Transaction
		DbSelectArea("C1N")
		DbSelectArea("T81")			
		DbSelectArea("T82")
		DbSelectArea("T83")
		DbSelectArea("T84")
		DbSelectArea("T85")								
		
		C1N->(DbSetOrder(1))	
		T81->(DbSetOrder(2))
		T82->(DbSetOrder(2))				
		T83->(DbSetOrder(2))
		T84->(DbSetOrder(2))
		T85->(DbSetOrder(2))
					
		For nX := 1 To Len(oBrowDBH:aCols)				
			If(!oBrowDBH:aCols[nX][13])						
				
				If (C1N->(DbSeek(xFilial("C1N") + oBrowDBH:aCols[nX][1])))
					While C1N->(!Eof()) .AND. (C1N->C1N_FILIAL + C1N->C1N_CODNAT) == (xFilial("C1N") + oBrowDBH:aCols[nX][1])
						
							If (!Empty(oBrowDBH:aCols[nX][3]))
								If (T81->(DbSeek (xFilial("T81") + oBrowDBH:aCols[nX][3])))
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDMOT := T81->T81_ID
									MsUnLock()
									lAlterou := .T.									
								EndIf
							EndIf	
							If (!Empty(oBrowDBH:aCols[nX][5]))
								If(T82->(DbSeek(xFilial("T82") + oBrowDBH:aCols[nX][5])))
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDREG := T82->T82_ID
									MsUnLock()
									lAlterou := .T.									
								EndIf
							EndIf
							If (!Empty(oBrowDBH:aCols[nX][7]))
								If(T83->(DbSeek(xFilial("T83") + oBrowDBH:aCols[nX][7])))
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDTIPO := T83->T83_ID
									MsUnLock()
									lAlterou := .T.									
								EndIf
							EndIf
							If (!Empty(oBrowDBH:aCols[nX][9]))
								If(T84->(DbSeek(xFilial("T84") + oBrowDBH:aCols[nX][9])))
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDSIT := T84->T84_ID
									MsUnLock()
									lAlterou := .T.									
								EndIf
							EndIf
							If (!Empty(oBrowDBH:aCols[nX][11]))
								If(T85->(DbSeek(xFilial("T85") + oBrowDBH:aCols[nX][11])))
									RecLock("C1N",.F.) //alteração
									C1N->C1N_IDEXIG := T85->T85_ID
									MsUnLock()
									lAlterou := .T.									
								EndIf
							EndIf	
							
						C1N->(DbSkip())								
					EndDo
				EndIf		
								
					
			EndIf
		Next
		
		C1N->(DbCloseArea())
				
	End Transaction	
	
	If lAlterou
		msginfo( STR0002, STR0021, STR0009  ) 	//"Atenção" 	"Informações atualizadas com sucesso."   	"Sair"
	Else
		msginfo( STR0002, STR0022, STR0009  ) 	//"Atenção"		"Nenhum registro foi alterado"     			"Sair"
	EndIf

Return	.T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TDBHRelat

TDBHRelat() - Gera relatório de conferência da DES BH para os registros
que foram impressos no arquivo da obrigação

@Author João Vitor Spieker
@Since 13/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TDBHRelat()
	Local oReport
	Private cNatOpe as char

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()		
		oReport:PrintDialog()
	EndIf	
	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

ReportPrint() - Query de consulta para extração do relatório

@Param
 oReport   - Objeto do relatório
 
@Author João Vitor Spieker
@Since 13/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport as object)
	Local oSectionNF 	as object
	Local cNF 			as char
	


	
        	
	dInic  := dInicial  
	dFim   := dFinal
	
	cAliasRelNF := DBHSQLServ(dInic,dFim)	 
	
	oSectionNF  := oReport:Section(1)	
	cNF   := ""
	cRec  := ""
	cRegF := ""
		
	While !(cAliasRelNF)->(Eof()) .And. !oReport:Cancel()		
		
		If Empty(cNF)
			oSectionNF:Init()
			cNF := (cAliasRelNF)->C20_NUMDOC
		EndIf
		
		cCodServ := (cAliasRelNF)->C1L_CODSER
		If ((cAliasRelNF)->C3S_CODIGO == "16") 	    	 	
	    	cTipRecol := "1"
	    Else
	    	cTipRecol := "2"    	 	  
	    Endif
	    
	    nAuxCid := POSICIONE("C07",3,xFilial("C07")+(cAliasRelNF)->C20_CODLOC,"C07_CODIGO")    
  	    nIdUf   := POSICIONE("C07",3,xFilial("C07")+(cAliasRelNF)->C20_CODLOC,"C07_UF")
        nAuxEst := POSICIONE("C09",3,xFilial("C09")+nIdUf,"C09_CODUF")
        
        nLocPrest := nAuxEst + Substr(nAuxCid,2,5)

		oSectionNF:PrintLine()		

		(cAliasRelNF)->(dbSkip())
	EndDo
			
	oSectionNF:Finish()
	
	oSectionNF:SetHeaderPage(.F.)
	oSectionNF:SetHeaderBreak(.F.)
	oSectionNF:SetHeaderSection(.F.)
	(cAliasRelNF)->(DbCloseArea())
 	
 
Return


/*/{Protheus.doc} ReportDef

ReportDef() - Gera relatório de conferência da DES BH para os registros
que foram impressos no arquivo da obrigação

@Author João Vitor Spieker
@Since 16/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef	

	Local oReport     	as object
	Local oSectionNF   	as object
	Private cAliasRelNF as char	
	
	oReport 	:= TReport():New("DES Belo Horizonte MG",UPPER(STR0023),"",{|oReport| ReportPrint(oReport)},STR0024)		//"DES Belo Horizonte MG - Relatório de Conferência"   "Conferência dos documentos gerados na DES BH"
	cAliasRelNF	:= ""	
	
	oSectionNF := TRSection():New(oReport,STR0025,{"(cAliasRelNF)"},{"C20_NUMDOC"})  //Documentos Fiscais de Serviço
	oSectionNF:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.

	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_NUMDOC",	"(cAliasRelNF)", UPPER(STR0032),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasRelNF)->C20_NUMDOC }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_SERIE",	"(cAliasRelNF)", UPPER(STR0033),	/*Picture*/,  3,	/*lPixel*/,{|| (cAliasRelNF)->C20_SERIE })													    	//SÉRIE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_DTDOC",	"(cAliasRelNF)", UPPER(STR0034),	/*Picture*/,  10,	/*lPixel*/,{|| SToD((cAliasRelNF)->C20_DTDOC)}) 													//DATA
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C1H_CODPAR",	"(cAliasRelNF)", UPPER(STR0035),	/*Picture*/,  20,	/*lPixel*/,{|| (cAliasRelNF)->C1H_CODPAR })															//CÓDIGO DO PARTICIPANTE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C1H_NOME",		"(cAliasRelNF)", UPPER(STR0036),	/*Picture*/,  60,	/*lPixel*/,{|| (cAliasRelNF)->C1H_NOME })															//NOME DO PARTICIPANTE
	oCell := TRCell():New(oSectionNF,"nLocPrest",					"(cAliasRelNF)", UPPER(STR0037),	/*Picture*/,  6,	/*lPixel*/,{|| nLocPrest })														    				//LOCAL DE PRESTAÇÃO
	oCell := TRCell():New(oSectionNF,"cCodServ",					"(cAliasRelNF)", UPPER(STR0038),	/*Picture*/,  6,	/*lPixel*/,{|| cCodServ })														    				//CÓDIGO DE SERVIÇO
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_VLDOC",    "(cAliasRelNF)", UPPER(STR0039),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasRelNF)->C20_VLDOC })													//Valor
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C35_VALOR",    "(cAliasRelNF)", UPPER(STR0040),	"@E 999,999,999.99",  14,	/*lPixel*/,{|| (cAliasRelNF)->C35_VALOR }) 													//VALOR
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C35_ALIQ",     "(cAliasRelNF)", UPPER(STR0041),	"@E 999.99",  6,	/*lPixel*/,{||  (cAliasRelNF)->C35_ALIQ }) 															//ALIQUOTA
	oCell := TRCell():New(oSectionNF,"cTipRecol",	                           	,    UPPER(STR0042),	/*Picture*/,  3,	/*lPixel*/,{|| cTipRecol })													    					//TIPO DE RECOLHIMENTO
	
	
		
	oReport:HideParamPage()   		//Define se será permitida a alteração dos parâmetros do relatório.	
	oReport:SetLandScape()  		//Define orientação de página do relatório como paisagem
	oReport:ParamReadOnly()			//Parâmetros não poderão ser alterados pelo usuário
	oReport:DisableOrientation()	//Desabilit a seleção da orientação (Retrato/Paisagem)
	oReport:HideFooter()			//Define que não será impresso o rodapé padrão da página

    oBreak:= TRBreak():New(oSectionNF, "(cAliasRelNF)->C20_INDOPE" , {|| STR0031}  , .F., 'NOMEBRK', .T.)  
    	
	oSum  := TRFunction():New(oSectionNF:Cell('(cAliasRelNF)->C20_VLDOC'),"TOTALSERV", 'SUM',oBreak,"","@E 999,999,999.99",,.F.,.F.,.F., oSectionNF)			
	
	oReport:SetCustomText({|| TCabecDBH( oReport )})			
	                                    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} TCabecDBH

TCabecDBH() - Montagem do cabeçalho do relatório

@Param
 oReport   - Objeto do relatório
 
@Author João Vitor Spieker
@Since 16/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TCabecDBH( oReport as object )

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
	          , "SIGATAF /" + 'DES Belo Horizonte MG' + " /v." + cVersao ; 
	          + "            " + cChar + UPPER( oReport:CTITLE ) ; 
	          + "            " + cChar;
	          , "            " + cChar + RptEmiss + " " + Dtoc(dDataBase);
	          ,(STR0026 + "...........: " +Trim(SM0->M0_NOME) + " / " + STR0027+": " + Trim(SM0->M0_FILIAL));  //"Empresa:"  "Filial:"
	          + "            " + cChar + STR0028+":  " + " " + time(); //"Hora"
	          ,(STR0029+"....: " + DTOC(dInicial) + " "+ STR0030 + " "+ DTOC(dFinal)); //Período Gerado:	   à       
	          , cChar + "            " }
	
	RestArea( aArea )
              
Return aCabec

Function DBHSQLServ(dDatIni as date, dDatFim as date)

 	Local cAliasDoc as char

 	cAliasDoc := GetNextAlias()

 	

 	If cOpe=='0'
 		
 		BeginSql Alias cAliasDoc
 		
 		SELECT 	C20.C20_NUMDOC 	C20_NUMDOC,
 				C20.C20_SERIE 	C20_SERIE,
 			    C20.C20_DTDOC 	C20_DTDOC,
	            C1H.C1H_CODPAR 	C1H_CODPAR,
            	C1H.C1H_NOME 	C1H_NOME,
            	C20.C20_CODLOC 	C20_CODLOC,
            	C1L.C1L_CODSER 	C1L_CODSER,
            	C20.C20_VLDOC 	C20_VLDOC,
            	C35.C35_VALOR 	C35_VALOR,
            	C35.C35_ALIQ   	C35_ALIQ,
            	C3S.C3S_CODIGO 	C3S_CODIGO,
            	C20.C20_INDOPE  C20_INDOPE,
            	C07.C07_CODIGO  C07_CODIGO,
            	C07.C07_UF      C07_UF,
            	C09.C09_CODUF 	C09_CODUF            	                        		                    		 	          		                          		                    
	   	 FROM %table:C20% C20 
		   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  
		   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
		   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel%
		   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel% 
		   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%	   	 	   	
			 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDSIT != ""  AND C1N.C1N_IDMOT != "" AND C1N.%NotDel%
		   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%			   	 		   	     	    	   	  		   	 
        WHERE C20.C20_FILIAL = %xFilial:C20%          
		  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
		  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido			
		  AND C20.C20_INDOPE IN (%Exp:'0' %)
		  AND C20.%NotDel%			  		  
		GROUP BY C20.C20_NUMDOC,
 				C20.C20_SERIE,
 			    C20.C20_DTDOC,
	            C1H.C1H_CODPAR,
            	C1H.C1H_NOME,
            	C20.C20_CODLOC,
            	C1L.C1L_CODSER,
            	C20.C20_VLDOC,
            	C35.C35_VALOR,
            	C35.C35_ALIQ,
            	C3S.C3S_CODIGO,
            	C20.C20_INDOPE,
            	C07.C07_CODIGO,
            	C07.C07_UF,
            	C09.C09_CODUF  					             
		     ORDER BY C20.C20_INDOPE
		
		     EndSql
		     
		     Endif
		     
		If cOpe=='1'
 		
 		BeginSql Alias cAliasDoc
 		
 		SELECT 	C20.C20_NUMDOC 	C20_NUMDOC,
 				C20.C20_SERIE 	C20_SERIE,
 			    C20.C20_DTDOC 	C20_DTDOC,
	            C1H.C1H_CODPAR 	C1H_CODPAR,
            	C1H.C1H_NOME 	C1H_NOME,
            	C20.C20_CODLOC 	C20_CODLOC,
            	C1L.C1L_CODSER 	C1L_CODSER,
            	C20.C20_VLDOC 	C20_VLDOC,
            	C35.C35_VALOR 	C35_VALOR,
            	C35.C35_ALIQ   	C35_ALIQ,
            	C3S.C3S_CODIGO 	C3S_CODIGO,
            	C20.C20_INDOPE  C20_INDOPE,
            	C07.C07_CODIGO  C07_CODIGO,
            	C07.C07_UF      C07_UF,
            	C09.C09_CODUF 	C09_CODUF            	                        		                    		 	          		                          		                    
	   	 FROM %table:C20% C20 
		   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  
		   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
		   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel%
		   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel% 
		   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%	   	 	   	
			 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDTIPO != "" AND C1N.C1N_IDEXIG != "" AND C1N.C1N_IDREG != "" AND C1N.C1N_CTISS != "" AND C1N.%NotDel%   			   	 
		   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%			   	 		   	     	    	   	  		   	 
        WHERE C20.C20_FILIAL = %xFilial:C20%          
		  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
		  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido			
		  AND C20.C20_INDOPE IN (%Exp:'1' %)
		  AND C20.%NotDel%			  		  
		GROUP BY C20.C20_NUMDOC,
 				C20.C20_SERIE,
 			    C20.C20_DTDOC,
	            C1H.C1H_CODPAR,
            	C1H.C1H_NOME,
            	C20.C20_CODLOC,
            	C1L.C1L_CODSER,
            	C20.C20_VLDOC,
            	C35.C35_VALOR,
            	C35.C35_ALIQ,
            	C3S.C3S_CODIGO,
            	C20.C20_INDOPE,
            	C07.C07_CODIGO,
            	C07.C07_UF,
            	C09.C09_CODUF  					             
		     ORDER BY C20.C20_INDOPE
		
		     EndSql
		     
	    Endif
		
		If cOpe=='2'
 		
 		BeginSql Alias cAliasDoc
 		
 		SELECT 	C20.C20_NUMDOC 	C20_NUMDOC,
 				C20.C20_SERIE 	C20_SERIE,
 			    C20.C20_DTDOC 	C20_DTDOC,
	            C1H.C1H_CODPAR 	C1H_CODPAR,
            	C1H.C1H_NOME 	C1H_NOME,
            	C20.C20_CODLOC 	C20_CODLOC,
            	C1L.C1L_CODSER 	C1L_CODSER,
            	C20.C20_VLDOC 	C20_VLDOC,
            	C35.C35_VALOR 	C35_VALOR,
            	C35.C35_ALIQ   	C35_ALIQ,
            	C3S.C3S_CODIGO 	C3S_CODIGO,
            	C20.C20_INDOPE  C20_INDOPE,
            	C07.C07_CODIGO  C07_CODIGO,
            	C07.C07_UF      C07_UF,
            	C09.C09_CODUF 	C09_CODUF            	                        		                    		 	          		                          		                    
	   	 FROM %table:C20% C20 
		   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  
		   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
		   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel%
		   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel% 
		   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%	   	 	   	
			 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDSIT != ""  AND C1N.C1N_IDMOT != "" AND C1N.%NotDel%
		   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%			   	 		   	     	    	   	  		   	 
        WHERE C20.C20_FILIAL = %xFilial:C20%          
		  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
		  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido			
		  AND C20.C20_INDOPE IN (%Exp:'0' %)
		  AND C20.%NotDel%			  		  
		GROUP BY C20.C20_NUMDOC,
 				C20.C20_SERIE,
 			    C20.C20_DTDOC,
	            C1H.C1H_CODPAR,
            	C1H.C1H_NOME,
            	C20.C20_CODLOC,
            	C1L.C1L_CODSER,
            	C20.C20_VLDOC,
            	C35.C35_VALOR,
            	C35.C35_ALIQ,
            	C3S.C3S_CODIGO,
            	C20.C20_INDOPE,
            	C07.C07_CODIGO,
            	C07.C07_UF,
            	C09.C09_CODUF  			
		     
		     UNION
		     
		     SELECT 	C20.C20_NUMDOC 	NUMDOC,
 				C20.C20_SERIE 	SERIE,
 			    C20.C20_DTDOC 	DTDOC,
	            C1H.C1H_CODPAR 	CODPAR,
            	C1H.C1H_NOME 	NOME,
            	C20.C20_CODLOC 	CODLOC,
            	C1L.C1L_CODSER 	CODSER,
            	C20.C20_VLDOC 	VLDOC,
            	C35.C35_VALOR 	VALOR,
            	C35.C35_ALIQ   	ALIQ,
            	C3S.C3S_CODIGO 	CODIGO,
            	C20.C20_INDOPE  INDOPE,
            	C07.C07_CODIGO  CODIGO,
            	C07.C07_UF      UF,
            	C09.C09_CODUF 	CODUF            	                        		                    		 	          		                          		                    
	   	 FROM %table:C20% C20 
		   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  
		   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
		   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel%
		   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel% 
		   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%	   	 	   	
			 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDTIPO != "" AND C1N.C1N_IDEXIG != "" AND C1N.C1N_IDREG != "" AND C1N.C1N_CTISS != "" AND C1N.%NotDel%   			   	 
		   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%			   	 		   	     	    	   	  		   	 
        WHERE C20.C20_FILIAL = %xFilial:C20%          
		  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
		  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido					  
		  AND C20.C20_INDOPE IN (%Exp:'1' %)
		  AND C20.%NotDel%			  		  
		GROUP BY C20.C20_NUMDOC,
 				C20.C20_SERIE,
 			    C20.C20_DTDOC,
	            C1H.C1H_CODPAR,
            	C1H.C1H_NOME,
            	C20.C20_CODLOC,
            	C1L.C1L_CODSER,
            	C20.C20_VLDOC,
            	C35.C35_VALOR,
            	C35.C35_ALIQ,
            	C3S.C3S_CODIGO,
            	C20.C20_INDOPE,
            	C07.C07_CODIGO,
            	C07.C07_UF,
            	C09.C09_CODUF  					             
		     ORDER BY C20.C20_INDOPE
		
		     
		     EndSql
		     
	    Endif



	DbSelectArea(cAliasDoc)
	(cAliasDoc)->(DbGoTop())
	
	
Return cAliasDoc
