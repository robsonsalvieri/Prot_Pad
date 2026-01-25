#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "TAFXDES.ch"

#Define cObrig "DES - Contagem MG" 

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDES

Esta rotina tem como objetivo a geracao do Arquivo DES - Declaração Eletrônica de Serviços

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------------------
Function TAFXDES()

Local cNomWiz    as char
Local lEnd       as logical
Local cFunction	 as char
Local nOpc       as numeric

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private cCPFCNPJ  as char
Private nTotRegF  as numeric
Private cTipRecol as char
Private nTotRecC  as numeric
Private nTotRecI  as numeric
Private nTotRecO  as numeric
Private nAliqServ as numeric 
Private nAliqISS  as numeric 
Private cTipRecei as char
Private dInicial  as date
Private dFinal    as date
Private cMunicip  as char
Private oProcess  as object
Private lCancel   as logical
Private lBrwServ  as logical
Private lAutomacao := Iif( IsBlind(), .T., .F. )

	cNomWiz	:= cObrig + FWGETCODFILIAL
	lEnd		:= .F.	
	lCancel	:= .F.
	oProcess	:= Nil	
	cFunction 	:= ProcName()
	nOpc      	:= 2 //View

	If (!lAutomacao)

		//Função para gravar o uso de rotinas e enviar ao LS (License Server)
		Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)		
		
		//Protect Data / Log de acesso / Central de Obrigacoes
		Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

		//Cria objeto de controle do processamento
		oProcess := TAFProgress():New( { || ProcDES( @lEnd, @oProcess, cNomWiz ) }, "" )
		oProcess:Activate()

		If !lCancel
			If (MSGYESNO( STR0030, STR0006)) //"Deseja gerar o relatório de conferência?", Atenção!
				TDESRelat()
			EndIf
		EndIf
	Else
		ProcDES( @lEnd, @oProcess, cNomWiz )
		DelClassIntf()
	Endif
	//Limpando a memória

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcDES

Inicia o processamento para geracao da DES


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da DES
	   cNomWiz   -> Nome da Wizard criada para a DES


@Return ( Nil )

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Static Function ProcDES( lEnd as logical, oProcess as object, cNomWiz as char)

Local cErrorDES   as char
Local cErrorTrd   as char
Local nX          as numeric
Local nPos        as numeric
Local nProgress1  as numeric
Local nCont       as numeric
Local aWizard     as array
Local lProc       as logical
Local cCNPJ       as char
Local aTotais     as Array

Private lBrwNat  as logical
Private lBrwIte  as logical
Private lBrwPar  as logical
	
	cErrorDES  := ""
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

	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf

	cCNPJ     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CGC")    // CNPJ
	cInsc     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")   //Inscrição Municipal
	cMunicip  := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CODMUN") //Código Município
	
	dInicial  := aWizard[1,1]  
	dFinal    := aWizard[1,2]
	
	If (!lAutomacao)	   
		If TAFConsServ(dInicial, dFinal)
			 	If (MSGYESNO( STR0018, STR0006 )) //Para o período selecionado existem documentos fiscais com código de serviço não informado. Esses documentos não serão considerados. Deseja informá-los?     Atenção!
					If !TAFCadAdic(dInicial, dFinal)
					 	lProc := MSGYESNO( STR0019, STR0006 ) //"Deseja gerar a obrigação sem finalizar o cadastro de códigos de serviço?"	   Atenção!	 	 
					EndIf
				EndIF	
	    EndIf
    Endif
	
	If lProc
		
	
	    If (!lAutomacao)
			//Alimentando a variável de controle da barra de status do processamento
			nProgress1 := 2
			oProcess:Set1Progress( nProgress1 )
		
			//Iniciando o Processamento
			oProcess:Inc1Progress( STR0002 ) // "Preparando o Ambiente"
			oProcess:Inc1Progress( STR0003 ) //	"Executando o Processamento..."
		Endif
		//************************************************************************
		//Geração DES - Contagem MG - Aqui vão a chamada das funções da geração dos registros
		TAFDESH(aWizard , cCNPJ , cInsc )            // Imprimir Cabeçalho
		
		aTotais :=  TAFDESNF(aWizard, cMunicip)    // Processamento dos Documentos Fiscais		
		
		If aWizard[1][6] == "1 - Sim"
			TAFDESF(aWizard)		
	    EndIf		
		
		TAFDEST(aTotais)	
							
		//************************************************************************
		//********* FIM da chamada das funções da geração dos registros **********
		//************************************************************************		
	Else
		oProcess:Inc1Progress( STR0004 )	// "Processamento cancelado"
		oProcess:Inc2Progress( STR0005 )	// "Clique em Finalizar"
		oProcess:nCancel = 1
	EndIf
	
	//Tratamento para quando o processamento tem problemas
	
		//Tratamento para quando o processamento tem problemas
	Iif(!lAutomacao, nCancel := oProcess:nCancel, nCancel := 0)
	
	If (nCancel == 1 .or. !Empty( cErrorDES ) .or. !Empty( cErrorTrd )) .And. !lAutomacao
	
		//Cancelado o processamento
		If oProcess:nCancel == 1
	
			Aviso( STR0007, "" ) 	//"Atenção" "A geração do arquivo foi cancelada com sucesso!" "Sair"
			lCancel := .T.
	
		//Erro na inicialização das threads
		ElseIf !Empty( cErrorTrd )
	
			Aviso( STR0006, cErrorTrd, { STR0008 } ) //"Atenção"    "Sair"
	
		//Erro na execução dos Blocos
		Else
	
			cErrorDES := STR0009   // "Ocorreu um erro fatal durante a geração do(s) Registro(s) da DES - MG"
			cErrorDES += STR0010  + Chr( 10 ) + Chr( 10 )//"Favor efetuar o reprecessamento da DES - MG, caso o erro persista entre em contato com o administrador de sistemas / suporte TOTVS" //			
			/*Aviso( STR0006, cErrorDES, { STR0008 } )*/
	
		EndIf
	
	Else
	
	    If (!lAutomacao)
			//Atualizando a barra de processamento
			oProcess:Inc1Progress( STR0011 )	// "Informações processadas"
			oProcess:Inc2Progress( STR0012 )	// "Consolidando as informações e gerando arquivo..."		
		Endif
		
		If GerArqCons( aWizard )
			
			If (!lAutomacao)
				//Atualizando a barra de processamento
				oProcess:Inc2Progress( STR0013 ) // "Arquivo gerado com sucesso."			
				msginfo(STR0013) 				 // "Arquivo gerado com sucesso."
			EndIf
		Else
			Iif(!lAutomacao, oProcess:Inc2Progress( STR0014 ), "") //"Falha na geração do arquivo."			
		EndIf	
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens1	:= {}

	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}

   	

	aAdd (aTxtApre, STR0015) // "Processando Empresa."
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0016) // "Preencha corretamente as informações solicitadas."
	aAdd (aTxtApre, STR0017) // "Informações necessárias para a geração do meio-magnético DES - Contagem MG."

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0016) // "Preencha corretamente as informações solicitadas."
	aAdd (aPaineis[nPos], STR0017) // "Informações necessárias para a geração do meio-magnético DES - Contagem MG."
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
	
	cTitObj1	:=	"Código Sistema";	             				cTitObj2	:=	"Gerar Registro F"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			     	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	
	cTitObj1	:=	Replicate ("X", 100);                              aAdd (aItens1, "0 - Não")															
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50}); 	               aAdd (aItens1, "1 - Sim")		
																	
																	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
																	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
     
     
     cTitObj1	:=	"Contabilista";								    aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});   
     
     cTitObj1	:=	Replicate ("X", 36);                           aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha													                                 
	 aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} ); aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	 																	   
	
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
	aAdd(aRet, { || TAFXDES() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDES

Geracao do Arquivo TXT da DES.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pela DES
        lCons   -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDES( nHandle as numeric, cTXTSys as char, cReg as char)

Local cDirName	as char
Local cFileDest	as char
Local lRetDir		as logical
Local lRet			as logical

	cDirName	:=	TAFGetPath( "2" , "DES" )
	cFileDest	:=	""
	lRetDir	:= .T.
	lRet		:= .T.
	
	//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
	if !File( cDirName )
	
		lRetDir := FWMakeDir( cDirName )
	
		if !lRetDir
	
			cDirName	:=	""
	
			Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\DES . Erro:" + cValToChar( FError() ) , 1, 0 )   //
	
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

Geracao do Arquivo .TXT da DES. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerArqCons( aWizard as array )

Local cFileDest  	as char
Local cPathTxt	as char
Local cStrTxtFIM	as char
Local cTxtSys		as char
Local nx			as numeric
Local nHandle		as numeric
Local aFiles		as array

	cFileDest	:=	Alltrim( aWizard[1][3] ) 		  //diretorio onde vai ser gerado o arquivo consolidado
	cPathTxt	:=	TAFGetPath( "2" , "DES" )//diretorio onde foram gerados os arquivos txt temporarios
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

	aFiles := DESFilesTxt(cPathTxt)
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
/*/{Protheus.doc} DESFilesTxt

DESFilesTxt() - Arquivos por bloco da DES

@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function DESFilesTxt( cPathTxt as char )

Local aRet	as array

	aRet	:=	{}
	
	AADD(aRet,{cPathTxt + "DES_H.TXT"})  // Registro H    - Identificador do contribuinte
	AADD(aRet,{cPathTxt + "DES_N.TXT"})  // Registro N    - Notas/Recibo
	AADD(aRet,{cPathTxt + "DES_I.TXT"})  // Registro I    - Serviços dos documentos	 
	AADD(aRet,{cPathTxt + "DES_F.TXT"})  // Registro F    - Receitas
	AADD(aRet,{cPathTxt + "DES_T.TXT"})  // Registro T    - totalização de valores		
	
Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConsServ()

TAFConsServ() - Consulta no cadastro de Produto para os movimentos do período,
				para verificar se existe código de serviço não preenchido. 
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
Static Function TAFConsServ(dIni as date, dFim as date)
 
 Local cAliasQry	as char 
 Local nCount       as numeric
 Local nTot         as numeric
 
 cAliasQry 		:= GetNextAlias() 
 
 BeginSQL Alias cAliasQry
		SELECT COUNT(*) COUNT
	 	  FROM %table:C20% C20	
	INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
	INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
	INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C30.C30_FILIAL AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
	 	 WHERE C20.C20_FILIAL = %xFilial:C20%	 	    
	 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%	 	   
	 	   AND (C1L.C1L_SRVMUN IS NULL OR C1L.C1L_SRVMUN = ' ') 	   
	 	   AND C20.%NotDel% 
  UNION 
	 	SELECT COUNT(*) COUNT
		 	  FROM %table:LEM% LEM
		INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%
		 	 WHERE LEM.LEM_FILIAL = %xFilial:LEM%	 	    
		 	   AND LEM_NATTIT = '0'
		 	   AND LEM.LEM_DTEMIS BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%	 	   		 	   	 	   
		 	   AND (LEM.LEM_SRVMUN IS NULL OR LEM.LEM_SRVMUN = ' ') 	   
		 	   AND LEM.%NotDel% 	   
 
  EndSQL
  
   While (cAliasQry)->(!Eof())   
      nCount := (cAliasQry)->COUNT
      
      nTot := nTot + nCount 
      DbSkip()
   EndDo
 
 
 
 IIF (nCount > 0, lBrwServ := .T., lBrwServ := .F.)  

 (cAliasQry)->(DbCloseArea())
   
Return lBrwServ

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCadAdic

Cadastro adicional para manutenção dos códigos de serviço

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
Local aIDRec       := {}

Private aColsGrid  as array
Private aHeader    as array
Private oBrowDES   as object
Private oDlg1      as object
Private noBrw      as numeric

	
	nOpc		:= GD_UPDATE	
	aArea		:= GetArea()	
	
	If lBrwServ
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeader     := TAFADESBrw()
		oBrowDES 	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		aIDRec := TAFADESCols(dInicial, dFinal)
	
		aAdd(aAlter, aHeader[3,2]) //Código do serviço municipal
	
		oDlg1    := MSDialog():New( 091,232,502,900,STR0020,,,.F.,,,,,,.T.,,,.T. )   //str0058 Código de Serviço/Atividade Municipal por Item"
				

		oBrowDES := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeader, aColsGrid )
		
		oBrowDES:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid(aIDRec), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
		
	RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADESBrw

TAFADESBrw() - Monta aHeaGrid da MsNewGetDados
@Param 
 cAlias  - Alias principal que será alterado 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFADESBrw()

	Local aCabec := { }
	Local cUsado := Replicate( chr( 128 ), 14 ) + chr( 160 ) 

	Aadd( aCabec, {;
		"Código",;       // X3_TITULO
		"XX_CODIGO",;    // X3_CAMPO
		"@!",;           // X3_PICTURE
		20,;             // X3_TAMANHO
		0,;              // X3_DECIMAL
		"",;             // X3_VALID
		cUsado,;         // X3_USADO
		"C",;            // X3_TIPO
		"",;             // X3_F3
		"V",;            // X3_CONTEXT
	} )

	Aadd( aCabec, {;
		"Descrição",;    // X3_TITULO
		"XX_DESCRI",;    // X3_CAMPO
		"@!",;           // X3_PICTURE
		40,;             // X3_TAMANHO
		0,;              // X3_DECIMAL
		"",;             // X3_VALID
		cUsado,;         // X3_USADO
		"C",;            // X3_TIPO
		"",;             // X3_F3
		"V",;            // X3_CONTEXT
	} )

	Aadd( aCabec, {;
		"Cod. Serviço",; // X3_TITULO
		"XX_CODSRV",;    // X3_CAMPO
		"@!",;           // X3_PICTURE
		20,;             // X3_TAMANHO
		0,;              // X3_DECIMAL
		"",;             // X3_VALID
		cUsado,;         // X3_USADO
		"C",;            // X3_TIPO
		"",;             // X3_F3
		"V",;            // X3_CONTEXT
	} )

	Aadd( aCabec, {;
		"Doc/Rec",;      // X3_TITULO
		"XX_TIPO",;      // X3_CAMPO
		"@!",;           // X3_PICTURE
		10,;             // X3_TAMANHO
		0,;              // X3_DECIMAL
		"",;             // X3_VALID
		cUsado,;         // X3_USADO
		"C",;            // X3_TIPO
		"",;             // X3_F3
		"V",;            // X3_CONTEXT
	} )

Return aCabec

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADESCols()

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

Static Function TAFADESCols(dIni as date, dFim as date)
Local nX         as numeric
Local nY         as numeric
Local cAliasQry  as char
local aIDRec     := {}
Local nTamHead   := Len( aHeader ) + 1

 nX        := 0
 nY        := 0
 
 cAliasQry := GetNextAlias()
 	
	BeginSQL Alias cAliasQry
		 	SELECT DISTINCT 
		 		   'DOC' TIPO,
		 	       C1L_CODIGO CODIGO,
			       C1L_DESCRI DESCRI,
			       C1L_SRVMUN SRVMUN,
			       ""         ID
		 	  FROM %table:C20% C20
		INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C30.C30_FILIAL AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%				
		 	 WHERE C20.C20_FILIAL = %xFilial:C20%			 	 
		 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%		 	   	 	   
		 	   AND (C1L.C1L_SRVMUN IS NULL OR C1L.C1L_SRVMUN = ' ')			 	   		
		 	   AND C20.%NotDel%	
		 	    GROUP BY C1L_CODIGO,	
		 	    		 C1L_DESCRI,
		 	    		 C1L_SRVMUN  	  
    
    UNION 
        	SELECT 'RECIBO' TIPO,
        		   LEM_NUMERO CODIGO,
        	       C8C_DESCRI DESCRI,
        	       LEM_SRVMUN SRVMUN,
        	       LEM_ID     ID 
	 	     FROM %table:LEM% LEM
		INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%		
		INNER JOIN %table:C8C% C8C ON C8C.C8C_FILIAL = %xFilial:C8C% AND C8C.C8C_ID     = T5M.T5M_IDTSER AND C8C.%NotDel%
		 	 WHERE LEM.LEM_FILIAL = %xFilial:LEM%	 	    
		 	   AND LEM_NATTIT = '0'
		 	   AND LEM.LEM_DTEMIS BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%	 	   	 	   
		 	   AND (LEM.LEM_SRVMUN IS NULL OR LEM.LEM_SRVMUN = ' ') 	   
		 	   AND LEM.%NotDel%	 	
		 	   GROUP BY LEM_NUMERO,
		 	   			C8C_DESCRI,
		 	   			LEM_SRVMUN,
		 	   			LEM_ID	 	         	 	  
        		 	  
	EndSql
	 
	 While (cAliasQry)->(!Eof())
	 	AADD(aColsGrid, Array( nTamHead ) )	
		aColsGrid[Len(aColsGrid)][1]  := (cAliasQry)->CODIGO
		aColsGrid[Len(aColsGrid)][2]  := substr((cAliasQry)->DESCRI,   1, 50)
		
		//Código do Serviço
		aColsGrid[Len(aColsGrid)][3]  := space(20)
		aColsGrid[Len(aColsGrid)][4]  := (cAliasQry)->TIPO
		aColsGrid[Len(aColsGrid), nTamHead]:=.F.
		
		aAdd(aIDRec, (cAliasQry)->ID)
	
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea()) 
 
Return aIDRec

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGrid

Atualiza código do serviço municipal na tabela informada por parâmetro

@Param 
cAlias - Tabela onde será realizada a atualização

@Return 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaGrid(aIDRec)
Local nX   		as numeric
Local lAlterou	as logical

	lAlterou := .F.
	
	Begin Transaction
		DbSelectArea("C1L")
		DbSelectArea("LEM")			
		
		C1L->(DbSetOrder(1))	
		LEM->(DbSetOrder(1))			
		
		For nX := 1 To Len(oBrowDES:aCols)				
			If(!oBrowDES:aCols[nX][5])						
				
				If (C1L->(DbSeek(xFilial("C1L") + oBrowDES:aCols[nX][1])))
					While C1L->(!Eof()) .AND. (C1L->C1L_FILIAL + C1L->C1L_CODIGO) == (xFilial("C1L") + oBrowDES:aCols[nX][1])
						
						//Código Serviço Municipal
						If !Empty(oBrowDES:aCols[nX][3])
							RecLock("C1L",.F.) //alteração
							C1L->C1L_SRVMUN := Alltrim(oBrowDES:aCols[nX][3])
							MsUnLock()
							lAlterou := .T.									
						EndIf
						C1L->(DbSkip())								
					EndDo
				EndIf		
								
				If (oBrowDES:aCols[nX][4] == "RECIBO")
				
				  If (LEM->(DbSeek(xFilial("LEM") + aIDRec[nx] )))
					   	
					 While LEM->(!Eof()) .AND. (LEM->LEM_FILIAL + Alltrim(LEM->LEM_NUMERO)) == (xFilial("LEM") + Alltrim(oBrowDES:aCols[nX][1]))  	
					   	If !Empty(oBrowDES:aCols[nX][3])
							RecLock("LEM",.F.) //alteração
							LEM->LEM_SRVMUN := Alltrim(oBrowDES:aCols[nX][3])
							MsUnLock()
							lAlterou := .T.									
						EndIf
						LEM->(DbSkip())				
					 Enddo
					 
				  Endif
				  
				Endif		
			EndIf
		Next
		
		C1L->(DbCloseArea())
				
	End Transaction	
	
	If lAlterou
		msginfo( STR0021 ) 	//"Atenção" 	"Informações atualizadas com sucesso."   	"Sair"
	Else
		msginfo( STR0022 ) 	//"Atenção"		"Nenhum registro foi alterado"     			"Sair"
	EndIf

Return	.T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TGISSRelat

TGISSRelat() - Gera relatório de conferência da GISS ONLINE para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TDESRelat()
	Local oReport
	Private cTipoServico as char

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
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport as object)
	Local oSectionNF 	as object
	Local oSectionRec   as object
	Local oSectionF     as object
	Local cNF 			as char
	Local cRec          as char
	Local cRegF         as char
	Local cNota         as char
	Local cRamo         as char
        	
	dInic  := dInicial  
	dFim   := dFinal
	
	cAliasRelNF := DesTAFSQLServ(dInic,dFim)	 
	
	oSectionNF  := oReport:Section(1)	
	cNF   := ""
	cRec  := ""
	cRegF := ""
		
	While !(cAliasRelNF)->(Eof()) .And. !oReport:Cancel()		
		
		If Empty(cNF)
			oSectionNF:Init()
			cNF := (cAliasRelNF)->C20_NUMDOC
		EndIf
		
		cCPFCNPJ := Iif ( !Empty((cAliasRelNF)->C1H_CNPJ),  (cAliasRelNF)->C1H_CNPJ, (cAliasRelNF)->C1H_CPF )
		
		cAuxMun := (cAliasRelNF)->C07_CODIGO
		 
		If ( (cAuxMun != Alltrim(cMunicip) .And.  (cAliasRelNF)->C20_INDOPE == "1" .And. (cAliasRelNF)->C3S_CODIGO == "16") .OR. (cAuxMun != Alltrim(cMunicip) .And. (cAliasRelNF)->C3S_CODIGO == "16" .And. (cAliasRelNF)->C20_INDOPE == "0") )	    	 	
    	 	cTipRecol := "F"	    	 	  
    	Endif
    	
    	If ( (cAliasRelNF)->C3S_CODIGO == "01" .And. (cAliasRelNF)->C20_INDOPE == "1" .And. (cAliasRelNF)->C35_VALOR > 0 )
    	   cTipRecol := "P"	    	    
    	Endif
    	
    	If ( (cAliasRelNF)->C3S_CODIGO == "01" .And. (cAliasRelNF)->C20_INDOPE == "0" .And. (cAliasRelNF)->C35_VALOR > 0 )
    	   cTipRecol := "O"
    	Endif
    	
    	If ( (cAuxMun == Alltrim(cMunicip) .And. (cAliasRelNF)->C20_INDOPE == "1" .And. (cAliasRelNF)->C3S_CODIGO == "16") .OR. (cAuxMun == Alltrim(cMunicip) .And. (cAliasRelNF)->C3S_CODIGO == "16" .And. (cAliasRelNF)->C20_INDOPE == "0") )
    	   cTipRecol := "S"
    	endif
    	
    	If ( (cAliasRelNF)->C02_CODIGO == "02")
    	   cTipRecol := "C"
    	Endif
    	
    	If ( (cAliasRelNF)->C35_VLISEN > 0)
    	   cTipRecol := "I"
    	Endif  	
		
		If ( (cAliasRelNF)->C1H_SIMPLS == "1")
		   nAliqISS = (cAliasRelNF)->C35_ALIQ
		   nAliqServ  = 0
		Else
		   nAliqServ  = (cAliasRelNF)->C35_ALIQ
		   nAliqISS = 0
		EndIf	
		
		oSectionNF:PrintLine()		

		(cAliasRelNF)->(dbSkip())
	EndDo
			
	oSectionNF:Finish()
	
	oSectionNF:SetHeaderPage(.F.)
	oSectionNF:SetHeaderBreak(.F.)
	oSectionNF:SetHeaderSection(.F.)
	
	(cAliasRelNF)->(DbCloseArea())
		
	/* Serviços Tomados sem documentos fiscal */	
	If TAFAlsInDic( "LEM",.F. )
	   
	    cTipRecol := ""
	
		oSectionRec := oReport:Section(2)	
	
		cAliasRec := TAFRecServ(dInic,dFim)
		
		While !(cAliasRec)->(Eof()) .And. !oReport:Cancel()		
		
		If Empty(cRec)
			oSectionRec:Init()
			cRec := (cAliasRec)->LEM_NUMERO
		EndIf
		
		cCPFCNPJ := Iif ( !Empty((cAliasRec)->C1H_CNPJ),  (cAliasRec)->C1H_CNPJ, (cAliasRec)->C1H_CPF )
			
		If ( cAuxMun != Alltrim(cMunicip)     .And. (cAliasRec)->C3S_CODIGO == "16") 	    	 	
	    	cTipRecol := "F"	    	 	  
	    Endif
	    	 
	    If ( (cAliasRec)->C3S_CODIGO == "01" .And. (cAliasRec)->T52_VLTRIB > 0 )
	    	cTipRecol := "O"	    	    
	    Endif
	    	  	 
	    If ( cAuxMun == Alltrim(cMunicip)     .And. (cAliasRec)->C3S_CODIGO == "16") 
	        cTipRecol := "S"
	    endif	
					
		If ( (cAliasRec)->C1H_SIMPLS == "1")
		   nAliqISS = (cAliasRec)->T52_ALIQ
		   nAliqServ  = 0
		Else
		   nAliqServ  = (cAliasRec)->T52_ALIQ
		   nAliqISS = 0
		EndIf	
			
		oSectionRec:PrintLine()
		
		(cAliasRec)->(dbSkip())
		EndDo		
		
	EndIf	
	
	oSectionRec:Finish()
		
	oSectionRec:SetHeaderPage(.F.)
	oSectionRec:SetHeaderBreak(.F.)
	oSectionRec:SetHeaderSection(.F.)
		
	( cAliasRec )->( DbCloseArea( ) )
		
	oSectionF := oReport:Section(3)	

    cAliasF   := TAFRegF(dInic,dFim)
 	
 	nTotRecC   := 0
	nTotRecI   := 0
	nTotRecO   := 0
	nTotRegF   := 0
	cNota      := ""
	
	While !(cAliasF)->(Eof()) .And. !oReport:Cancel()    
	      	    	    
	    nValFatura := (cAliasF)->LEM_VLBRUT  
	    cAuxNota   := (cAliasF)->LEM_NUMERO
	    cRamo      := (cAliasF)->C1H_RAMO
	    
	    If Empty(cRegF)    
	       oSectionF:Init()
	       cRegF := (cAliasF)->LEM_NUMERO  
	    endif	   
	    
	    If (Alltrim(cNota) != Alltrim(cAuxNota))	       
			 
			cTipRecei := "" 
			 
		    If ((cAliasF)->C1H_RAMO == '1')
		        nTotRecC  := nTotRecC +  nValFatura
		        cTipRecei := "Comércio"
		    Endif
		   
		    If ((cAliasF)->C1H_RAMO == '5')
		        nTotRecI := nTotRecI +  nValFatura
		        cTipRecei := "Indústria"
		    Endif
		          		    
		    If ((cAliasF)->C1H_RAMO != '5' .And. (cAliasF)->C1H_RAMO != '1')				    
			    nTotRecO := nTotRecO +  nValFatura
			    cTipRecei := "Outros"
			Endif
		    

		    If ((cAliasF)->C1H_RAMO != '5' .And. (cAliasF)->C1H_RAMO != '1' .And. (cAliasF)->C1H_RAMO != '2' .And. (cAliasF)->C1H_RAMO != '3'.And. (cAliasF)->C1H_RAMO != '4')  
		    	cTipRecei := "Sem Informação"    
		    Endif
		    	    
		    oSectionF:PrintLine()
		    	    
	        cNota     := cAuxNota
	        
		Endif	    
	    	    
        (cAliasF)->(dbSkip())	    	    
	EndDo 	    
    
    oSectionF:Finish()
		
	oSectionF:SetHeaderPage(.F.)
	oSectionF:SetHeaderBreak(.F.)
	oSectionF:SetHeaderSection(.F.)
		
	(cAliasF)->(DbCloseArea()) 

	
Return

/*/{Protheus.doc} ReportDef

ReportDef() - Gera relatório de conferência da GISS ONLINE para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef	

	Local oReport     	as object
	Local oSectionNF   	as object
	Local oSectionRec  	as object
	Local oSectionF     as object
	Private cAliasRelNF as char	
	Private cAliasRec   as char
	Private cAliasF     as char
	
	
	oReport 	:= TReport():New("DES Contagem MG",UPPER(STR0028),"",{|oReport| ReportPrint(oReport)},STR0029)		//Conferência dos documentos gerados na GISS ONLINE
	cAliasRelNF	:= ""
	cAliasRec   := ""
	cAliasF     := ""		
	
	oSectionNF := TRSection():New(oReport,"Documentos Fiscais de Serviço",{"(cAliasRelNF)"},{"C20_NUMDOC"})  //Documentos Fiscais de Serviço
	oSectionNF:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.

	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_NUMDOC",	"(cAliasRelNF)", UPPER(STR0031),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasRelNF)->C20_NUMDOC }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_SERIE",	"(cAliasRelNF)", UPPER(STR0032),	/*Picture*/,  3,	/*lPixel*/,{|| (cAliasRelNF)->C20_SERIE })													    	//SÉRIE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_DTDOC",	"(cAliasRelNF)", UPPER(STR0046),	/*Picture*/,  10,	/*lPixel*/,{|| SToD((cAliasRelNF)->C20_DTDOC)}) 												//DATA EMISSAO
	oCell := TRCell():New(oSectionNF,"cCPFCNPJ",		            "(cAliasRelNF)", UPPER(STR0034),	/*Picture*/,  14,	/*lPixel*/,{|| cCPFCNPJ })		//CNPJ PARTICI.
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C1H_NOME",		"(cAliasRelNF)", UPPER(STR0035),	/*Picture*/,  60,	/*lPixel*/,{|| (cAliasRelNF)->C1H_NOME })														    //UF PART.
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C09_UF",		"(cAliasRelNF)", UPPER(STR0036),	/*Picture*/,  2,	/*lPixel*/,{|| (cAliasRelNF)->C09_UF })														    //UF PART.
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C07_DESCRI",	"(cAliasRelNF)", UPPER(STR0037),	/*Picture*/,  20,	/*lPixel*/,{|| (cAliasRelNF)->C07_DESCRI })														    //CIDADE PART.
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C20_VLDOC)",    "(cAliasRelNF)", UPPER(STR0038),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasRelNF)->C20_VLDOC })														//Valor
	oCell := TRCell():New(oSectionNF,"cTipRecol",	                           	,    UPPER(STR0039),	/*Picture*/,  3,	/*lPixel*/,{|| cTipRecol })													    	//SÉRIE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C30_SERVI",	"(cAliasRelNF)", UPPER(STR0049),	/*Picture*/,  10,	/*lPixel*/,{|| (cAliasRelNF)->C1L_SERVI }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C35_BASE",	    "(cAliasRelNF)", UPPER(STR0047),	"@E 999,999,999.99",  13,	/*lPixel*/,{|| (cAliasRelNF)->C35_BASE }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"nAliqServ",                   "(cAliasRelNF)",  UPPER(STR0048),	"@E 999.99",  5,	/*lPixel*/,{||  nAliqServ }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"nAliqISS",                    "(cAliasRelNF)",  UPPER(STR0050),	"@E 999.99",  10,	/*lPixel*/,{||  nAliqISS }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->C35_VALOR",    "(cAliasRelNF)", UPPER(STR0043),	"@E 999,999,999.99",  14,	/*lPixel*/,{|| (cAliasRelNF)->C35_VALOR }) 														//NOTA FISCAL
		
	oReport:HideParamPage()   		//Define se será permitida a alteração dos parâmetros do relatório.	
	oReport:SetLandScape()  		//Define orientação de página do relatório como paisagem
	oReport:ParamReadOnly()			//Parâmetros não poderão ser alterados pelo usuário
	oReport:DisableOrientation()	//Desabilit a seleção da orientação (Retrato/Paisagem)
	oReport:HideFooter()			//Define que não será impresso o rodapé padrão da página

    oBreak:= TRBreak():New(oSectionNF, "" , , .F., 'NOMEBRK', .T.)    
    	
	oSectionRec := TRSection():New(oReport,"Recibos de Serviços Tomados",{"(cAliasRec)"},{"LEM_NUMERO"})  //Documentos Fiscais de Serviço
	oSectionRec:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.				
	
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_NUMERO",	"(cAliasRec)", UPPER(STR0044),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasRec)->LEM_NUMERO }) 																//RECIBO
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_PREFIX",	"(cAliasRec)", UPPER(STR0032),	/*Picture*/,  3,	/*lPixel*/,{|| (cAliasRec)->LEM_PREFIX }) 																	//SERIE	
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_DTEMIS",	"(cAliasRec)", UPPER(STR0046),	/*Picture*/,  10,	/*lPixel*/,{|| (cAliasRec)->LEM_DTEMIS }) 														 			//DATA
	oCell := TRCell():New(oSectionRec,"cCPFCNPJ",	                "(cAliasRec)", UPPER(STR0034),	/*Picture*/,  14,	/*lPixel*/,{|| cCPFCNPJ }) 	//CNPJ/CPF
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->C1H_NOME",	    "(cAliasRec)", UPPER(STR0035),	/*Picture*/,  60,	/*lPixel*/,{|| (cAliasRec)->C1H_NOME }) 															//PARTICIPANTE
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->C09_UF",	    "(cAliasRec)", UPPER(STR0036),	/*Picture*/,  2,	/*lPixel*/,{|| (cAliasRec)->C09_UF }) 																		//UF
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->C07_DESCRI",	"(cAliasRec)", UPPER(STR0037),	/*Picture*/,  20,	/*lPixel*/,{|| (cAliasRec)->C07_DESCRI }) 																//CIDADE
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_VLBRUT",	"(cAliasRec)", UPPER(STR0038),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasRec)->LEM_VLBRUT }) 															//VALOR RECIBO
    oCell := TRCell():New(oSectionRec,"cTipRecol",	"",                            UPPER(STR0039),	/*Picture*/,  3,	/*lPixel*/,{|| cTipRecol }) 																	//TIPO DE RECOLHIMENTO
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_SRVMUN",	"(cAliasRec)", UPPER(STR0049),	/*Picture*/,  10,	/*lPixel*/,{|| (cAliasRec)->LEM_SRVMUN }) 														//CODIGO DO SERVIÇO
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->T52_BASECA",	"(cAliasRec)", UPPER(STR0047),	"@E 999,999,999.99",  13,	/*lPixel*/,{|| (cAliasRec)->T52_BASECA }) 													//BASE DE CALCULO
	oCell := TRCell():New(oSectionRec,"nAliqServ",           	    "(cAliasRec)", UPPER(STR0048),	"@E 999,999,999.99",  5,	/*lPixel*/,{|| nAliqServ	 }) 													//ALIQUOTA
	oCell := TRCell():New(oSectionRec,"nAliqISS",                    "(cAliasRec)", UPPER(STR0050), "@E 999.99",  10,	/*lPixel*/,{||  nAliqISS }) 														//NOTA FISCAL
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->T52_VLTRIB",	"(cAliasRec)", UPPER(STR0043),	"@E 999,999,999.99",  14,	/*lPixel*/,{|| (cAliasRec)->T52_VLTRIB }) 									     			//VALOR TRIBUTO
								
	oBreak:= TRBreak():New(oSectionRec, "" , , .F., 'NOMEBRK', .T.)	
	
	oSectionF := TRSection():New(oReport,"Outras Receitas",{""},{"cTipRecei"})  //Outras Receitas
	oSectionF:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.				
	
 	oCell := TRCell():New(oSectionF,"cTipRecei",	                           	,    UPPER(STR0045),	/*Picture*/,  14,	/*lPixel*/,{|| cTipRecei })													    	//TIPO DE RECEITA
	oCell := TRCell():New(oSectionF,"(cAliasF)->LEM_NUMERO",	        "(cAliasF)", UPPER(STR0044),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasF)->LEM_NUMERO }) 																//RECIBO
	oCell := TRCell():New(oSectionF,"(cAliasF)->LEM_DTEMIS",	        "(cAliasF)", UPPER(STR0046),	/*Picture*/,  10,	/*lPixel*/,{|| (cAliasF)->LEM_DTEMIS }) 														 			//DATA
	oCell := TRCell():New(oSectionF,"(cAliasF)->LEM_VLBRUT",         	"(cAliasF)", UPPER(STR0038),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasF)->LEM_VLBRUT }) 															//VALOR RECIBO
	
	oBreak:= TRBreak():New(oSectionF, "cTipRecei" , {|| "TOTAL RECEITAS "} , .F., 'NOMEBRK', .T.)	
	
	oSum  := TRFunction():New(oSectionF:Cell('(cAliasF)->LEM_VLBRUT'),"TOTALSERV", 'SUM',oBreak,"","@E 999,999,999.99",,.F.,.F.,.F., oSectionF)			
	
	oReport:SetCustomText({|| TCabecDES( oReport )})			
	                                    
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} TCabecGISS

TCabecGISS() - Montagem do cabeçalho do relatório

@Param
 oReport   - Objeto do relatório
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TCabecDES( oReport as object )

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
	          , "SIGATAF /" + 'DES Contagem MG' + " /v." + cVersao ; 
	          + "            " + cChar + UPPER( oReport:CTITLE ) ; 
	          + "            " + cChar;
	          , "            " + cChar + RptEmiss + " " + Dtoc(dDataBase);
	          ,(STR0023 + "...........: " +Trim(SM0->M0_NOME) + " / " + STR0024+": " + Trim(SM0->M0_FILIAL));  //"Empresa:"  "Filial:"
	          + "            " + cChar + STR0025+":  " + " " + time();
	          ,(STR0026+"....: " + DTOC(dInicial) + " "+ STR0027 + " "+ DTOC(dFinal)); //Período Gerado:	   à       
	          , cChar + "            " }
	
	RestArea( aArea )
              
Return aCabec

//---------------------------------------------------------------------------
Function DesTAFSQLServ(dDatIni, dDatFim)

 Local cAliasDoc as char

 cAliasDoc := GetNextAlias()
 
 BeginSql Alias cAliasDoc

		SELECT C20.C20_DTDOC	  C20_DTDOC,
			   C20.C20_INDOPE	  C20_INDOPE,
	           C20.C20_NUMDOC	  C20_NUMDOC,
	           C20.C20_SERIE      C20_SERIE,	           
	           C20.C20_VLDOC	  C20_VLDOC,          
	           C1H.C1H_CNPJ       C1H_CNPJ,
		       C1H.C1H_CPF        C1H_CPF,           
	           C1L.C1L_SRVMUN     C1L_SERVI,
	           C35.C35_BASE       C35_BASE,
		       C35.C35_ALIQ   	  C35_ALIQ,
		       C35.C35_VALOR      C35_VALOR,
		       C02.C02_CODIGO     C02_CODIGO,	   
		       C07.C07_CODIGO     C07_CODIGO,      
		       C3S.C3S_CODIGO     C3S_CODIGO,
		       C35.C35_VLISEN     C35_VLISEN,
		       C1H.C1H_NOME       C1H_NOME,
		       C09.C09_UF         C09_UF,
		       C07.C07_DESCRI     C07_DESCRI,
		       C1H.C1H_SIMPLS     C1H_SIMPLS	 	          		                          		                      
		FROM %table:C20% C20			
			INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID  AND C1H.%NotDel%  	  
			INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%  AND C20.C20_TPDOC  = C0U.C0U_ID  AND C0U.%NotDel%  
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
			INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel%
			INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xFilial:C3S% AND C35.C35_CODTRI  = C3S.C3S_ID AND C3S.%NotDel%
			INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xFilial:C02% AND C20.C20_CODSIT  = C02.C02_ID AND C02.%NotDel%
			INNER JOIN %table:C07% C07 ON C07.C07_FILIAL = %xFilial:C07% AND C07.C07_ID      = C1H.C1H_CODMUN AND C07.%NotDel% 
			INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID      = C1H.C1H_UF     AND C09.%NotDel%
			INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel%	   	   	   	  		   	 			 		 		 			
		WHERE C20.C20_FILIAL = %xFilial:C20%
			  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
			  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido
			  AND C1L.C1L_SRVMUN <> ""
			  AND C20.%NotDel%			  
		GROUP BY C20.C20_DTDOC,
				 C20.C20_INDOPE,
		         C20.C20_NUMDOC,
		         C20.C20_SERIE,	           
		         C20.C20_VLDOC,          
		         C1H.C1H_CNPJ,
		         C1H.C1H_CPF,	           
		         C1L.C1L_SRVMUN,
		         C35.C35_BASE,
			     C35.C35_ALIQ,
			     C35.C35_VALOR,
			     C02.C02_CODIGO,	   
			     C07.C07_CODIGO,      
			     C3S.C3S_CODIGO,
			     C35.C35_VLISEN,
			     C1H.C1H_NOME,
			     C09.C09_UF,
			     C07.C07_DESCRI,
			     C1H.C1H_SIMPLS
	    ORDER BY C20.C20_NUMDOC
	EndSql

	DbSelectArea(cAliasDoc)
	(cAliasDoc)->(DbGoTop())
	
	
Return cAliasDoc


Function TAFRecServ(dDatIni, dDatFim)

 Local cAliasRec as char

 cAliasRec := GetNextAlias()

 BeginSql Alias cAliasRec
     
        SELECT LEM.LEM_DTEMIS  LEM_DTEMIS,
               LEM.LEM_NATTIT  LEM_NATTIT,
               LEM.LEM_NUMERO  LEM_NUMERO,
               LEM.LEM_PREFIX  LEM_PREFIX,  
		       LEM.LEM_VLBRUT  LEM_VLBRUT,
		       C1H.C1H_CNPJ	   C1H_CNPJ,
	           C1H.C1H_CPF	   C1H_CPF,
	           C1H.C1H_NOME    C1H_NOME,
	           LEM.LEM_SRVMUN  LEM_SRVMUN,	             	           
		       T52.T52_VLTRIB  T52_VLTRIB,
		       T52.T52_BASECA  T52_BASECA,
		       T52.T52_ALIQ    T52_ALIQ,
		       C09.C09_UF      C09_UF,
		       C07.C07_DESCRI  C07_DESCRI,
		       C3S.C3S_CODIGO  C3S_CODIGO,
		       C1H.C1H_SIMPLS  C1H_SIMPLS	 			           	 		
		      FROM %table:LEM% LEM
		      	  INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = LEM.LEM_FILIAL AND LEM.LEM_IDPART = C1H.C1H_ID     AND C1H.%NotDel%           
		          INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%			        
			      INNER JOIN %table:T52% T52 ON T52.T52_FILIAL = T52.T52_FILIAL AND T52.T52_ID	  = T5M.T5M_ID     AND T52.T52_IDTSER = T5M.T5M_IDTSER AND T52.%NotDel%
			      INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND T52.T52_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%
			      INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C1H.C1H_UF     AND C09.%NotDel% 
			      INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%       			        
	         WHERE LEM.LEM_FILIAL = %xFilial:LEM%
		 	   AND LEM_DTEMIS BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%	
		 	   AND LEM_NATTIT = '0'
		 	   AND LEM_TIPDOC = '0'  
		 	   AND LEM_SRVMUN <> ""
		 	   AND LEM.%NotDel%
	 		   AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido	     
    	  GROUP BY LEM.LEM_DTEMIS, 
                   LEM.LEM_NATTIT, 
	               LEM.LEM_NUMERO,     
	               LEM.LEM_PREFIX,       
			       LEM.LEM_VLBRUT, 
			       C1H.C1H_CNPJ,	      
		           C1H.C1H_CPF,	  
		           C1H.C1H_NOME,    
		           LEM.LEM_SRVMUN,        	           
			       T52.T52_VLTRIB, 
			       T52.T52_BASECA, 
			       T52.T52_ALIQ,
			       C09.C09_UF,
			       C07.C07_DESCRI,
			       C3S.C3S_CODIGO,
			       C1H.C1H_SIMPLS    		 
		  
    EndSql

	DbSelectArea(cAliasRec)
	(cAliasRec)->(DbGoTop())
	
	
Return cAliasRec

Function TAFRegF(dDatIni, dDatFim)	  

 Local cAliasF as char

 cAliasF := GetNextAlias()	
	
   BeginSql  Alias cAliasF
        
        SELECT LEM.LEM_NUMERO LEM_NUMERO,
               LEM.LEM_DTEMIS LEM_DTEMIS,
               LEM.LEM_VLBRUT LEM_VLBRUT,               
               C1H.C1H_RAMO   C1H_RAMO
          FROM %table:LEM% LEM
          	  INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = LEM.LEM_FILIAL AND LEM.LEM_IDPART = C1H.C1H_ID     AND C1H.%NotDel%
          	  INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%			        
			  INNER JOIN %table:T52% T52 ON T52.T52_FILIAL = T52.T52_FILIAL AND T52.T52_ID	  = T5M.T5M_ID     AND T52.T52_IDTSER = T5M.T5M_IDTSER AND T52.%NotDel%
			  INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND T52.T52_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%               
          WHERE LEM.LEM_FILIAL = %xFilial:LEM%
		    AND LEM_DTEMIS BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%	
		    AND LEM_NATTIT = '1'
		    AND C3S.C3S_CODIGO NOT IN ( %Exp:'01'%, %Exp:'16'% ) 				//ISSQN / ISSQN Retido
		    AND LEM.%NotDel%	
		GROUP BY LEM.LEM_NUMERO,
				 LEM.LEM_DTEMIS,				 
				 LEM.LEM_VLBRUT,
				 C1H.C1H_RAMO		    
	    ORDER BY C1H.C1H_RAMO	    	
	    	       
	EndSql
		
	DbSelectArea(cAliasF)
	(cAliasF)->(DbGoTop())		

Return cAliasF
