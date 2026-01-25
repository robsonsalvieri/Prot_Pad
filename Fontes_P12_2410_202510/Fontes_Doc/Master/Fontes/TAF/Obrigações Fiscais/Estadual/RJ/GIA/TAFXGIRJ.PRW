#Include 'Protheus.ch'
#Define cObrig "GIA-RJ" 

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGIRJ

Esta rotina tem como objetivo a geracao do Arquivo GIA - RJ

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGIRJ()
Local cNomWiz    := cObrig + FWGETCODFILIAL 
Local lEnd       := .F.
Local cFunction	 := ProcName()
Local nOpc     	 := 2 //View

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
oProcess := TAFProgress():New( { |lEnd| ProcGIARJ( @lEnd, @oProcess, cNomWiz ) }, "Processando GIA - RJ" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcGIARJ

Inicia o processamento para geracao da GIA - RJ


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario 
	   oProcess  -> Objeto da barra de progresso da emissao da GIA-RJ 
	   cNomWiz   -> Nome da Wizard criada para a GIA

       
@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
*/

Static Function ProcGIARJ( lEnd, oProcess, cNomWiz )

Local cErrorGIA	:=	""
Local cErrorTrd	:=	""
Local nProgress1	:=	0
Local aWizard		:=	{}
Local aJobAux		:=	{}
Local lProc		:=	.T.
Local nValor   	:= 0
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
	
	//Geração GIA-RJ
	TAFGIRJ00 (aWizard)
	TAFGIR110 (aWizard, @nValor, @nCont)
	TAFGIRMOVT(aWizard, @nValor, @nCont, 1)
	TAFGIRAJU (aWizard, @nValor, @nCont)
	TAFGIRMOVT(aWizard, @nValor, @nCont, 2)
	TAFGIRMOVT(aWizard, @nValor, @nCont, 3)
	TAFGIR9999(@nValor, @nCont)

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
		cErrorGIA += "da GIA-RJ " + Chr( 10 ) + Chr( 10 )
		cErrorGIA += "Favor efetuar o reprocessamento da GIA-RJ, caso o erro persista entre em contato "
		cErrorGIA += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorGIA, { "Sair" } )

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
	Local	aItens5	:= {}
	
	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}

	If !AliasInDic("T37") .OR. !AliasInDic("T38") .OR. !AliasInDic("T36") .OR. !AliasInDic("T35")
		Aviso( "Atenção!", "Dicionário desatualizado, atualize pacote 12.1.9!", { "Sair" } )
		Return .F.
	EndIf

	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético GIA-RJ.")

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIA-RJ.")
	aAdd (aPaineis[nPos], {})

	//Coluna1																//Coluna 2
	cTitObj1	:=	"Diretório do Arquivo Destino:";					cTitObj2	:=	"Nome do Arquivo Destino:"    
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})		

	cTitObj1	:=	Replicate ("X", 100);					    		cTitObj2	:=	Replicate ("X", 100)           
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
                                                        
	cTitObj1	:=	"Versão da GIA-RJ:";	   								cTitObj2	:=	"Mês/Ano Referência:"				
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
                                                                                                                                                                
	cTitObj1	:=	Replicate ("X", 10);                             cTitObj2	:=	"99/9999"        																							             
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,10}); 				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,7})
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	
	cTitObj1	:=  "Indicador  Retificadora:";                     	cTitObj2	:=	"Valor do Saldo Anterior SCE:"
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})		   
                                                                                                                           
   	aAdd (aItens1, "0 - Não")                                                     
   	aAdd (aItens1, "1 - Sim");                                     cTitObj2	:=	"@E 9999999999999.99"		   
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,2,2,,,13})
	
	               
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                      	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
		                    	
	// ============================= VALORES =====================                         
	cTitObj1	:=  "Valor do Crédito de Energia SCE:";      	   		cTitObj2	:=	"Valor do Estorno de Provisão SCE:"				  
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	   
	                                                                                                              
	cTitObj1	:=	"@E 9999999999999.99";  	                       	cTitObj2	:=	"@E 9999999999999.99"           
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,2,2,,,13});                aAdd (aPaineis[nPos][3], {2,,cTitObj1,2,2,,,13})
		
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                      	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
		
	cTitObj1	:=	"Valor de Provisão SCE:"	;							cTitObj2	:=	"" 			   							  				
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});     				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
                                                                                                                                                               
	cTitObj1	:=	"@E 9999999999999.99"                                                 
   	aAdd (aPaineis[nPos][3], {2,,cTitObj1,2,2,,,13})					
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
														            		
//PAINEL 1
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIA-RJ")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//Coluna1																//Coluna 2
	cTitObj1	:=  "Ind. Sem Mov. Operações Próprias:";            	cTitObj2	:=  "Ind. Sem Mov. Substituição Tributária:"   
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,}) 
                                                                                                                  
   	aAdd (aItens2, "0 - Não");                                     aAdd (aItens4, "0 - Não")                      
   	aAdd (aItens2, "1 - Sim");                                     aAdd (aItens4, "1 - Sim")                     
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})
   	
   	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha	
	
	cTitObj1	:=  "Ind. Sem Mov. Outros ICMS:";                   	cTitObj2	:=  "Ind. Sem Mov. ALC/ZFM:"   
   	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,}) 
                                                                                                                  
   	aAdd (aItens3, "0 - Não");                                     aAdd (aItens5, "0 - Não")                      
   	aAdd (aItens3, "1 - Sim");                                     aAdd (aItens5, "1 - Sim")                     
   	aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens5,,,,,})
   	
   	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	"Observação:";						              cTitObj2	:=	"Obervação ST:"    
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	

	cTitObj1	:=	Replicate ("X", 255);					    		cTitObj2	:=	Replicate ("X", 255)           
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,255});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,255})
//PAINEL 2
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIA-RJ")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Contabilista:"																		
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})													
	                                                                                              		                                                                                                    
	cTitObj1	:=	Replicate ("X", 36)															  		                                 
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )                     
																							  			    
																								
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXGIRJ() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGIRJ

Geracao do Arquivo TXT da GIA-RJ. 
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo GIA
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtGIRJ( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "GIARJ" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )
	
	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""
		
		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\GIARJ. Erro: " + cValToChar( FError() ) , 1, 0 )
		
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

Geracao do Arquivo TXT da GIA RJ. Gera o arquivo dos registros e arquivo 
consolidado

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 						//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	TAFGetPath( "2" , "GIARJ" )		              //diretorio onde foram gerados os arquivos txt temporarios
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
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
	EndIf
	
	WrtStrTxt( nHandle, cStrTxtFIM )
	
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

Return( lRet )

// ----------------------------
static function GIAFilesTxt(cPathTxt)

	Local aRet	:=	{}

	AADD(aRet,{cPathTxt+"0000.TXT"})
	AADD(aRet,{cPathTxt+"0110.TXT"})	
	AADD(aRet,{cPathTxt+"MOVTO1.TXT"})
	AADD(aRet,{cPathTxt+"AJUSTE.TXT"})
	AADD(aRet,{cPathTxt+"MOVTO2.TXT"})
	AADD(aRet,{cPathTxt+"MOVTO3.TXT"})
    AADD(aRet,{cPathTxt+"9999.TXT"})

return( aRet )


