#Include "Protheus.ch"
#Include 'TAFXDIEFCE.ch'
#INCLUDE "FILEIO.CH"

#Define cObrig "DIEF-CE"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFXDFCE             
Esta função tem o objetivo de gerar o arquivo magnetico da rotina DIEF-CE 

@author David Costa
@since  16/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFXDFCE()
Local cNomWiz 		:= cObrig + FWGETCODFILIAL 
Local lEnd     	  	:= .F.
Local cFunction 	:= ProcName()
Local nOpc      	:= 2 //View
Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess		:= Nil

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
If(AliasInDic("T30") .And. AliasInDic("T39"))

	//Protect Data / Log de acesso / Central de Obrigacoes
	Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

	//Cria objeto de controle do processamento
	oProcess := TAFProgress():New( { |lEnd| ProcDIEFCE( @lEnd, @oProcess, cNomWiz ) }, STR0020 )//"Processando a DIEF-CE"
	oProcess:Activate()

	//Limpando a memória
	DelClassIntf()
Else
	Aviso( "Atenção!", STR0019, { "Sair" } )//"Para executar esta rotina é necessário atualizar o dicionário."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcDIEFCE             
Processo de geração do arquivo magnetico da DIEF-CE

@Param	lEnd		-> Verifica se a operacao foi abortada pelo usuario 
		cNomWiz	-> Nome da Wizard criada para a DIEF-CE
        oProcess	-> Objeto da barra de progresso da Geração da DIEF-CE

@Return ( Nil )

@author David Costa
@since  16/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcDIEFCE ( lEnd, oProcess, cNomWiz )

Local aWizard		:= {}
Local aRegDIEF	:= {}
Local lProc		:=	.T.
Local cFunction	:= ""
Local nIndiceReg	:= 0
Local nIndiceJob	:= 0
Local nThread		:= 0
Local nBarProgr1	:= 0
Local nBarProgr2	:= 0
Local cRegime		:= ""
Local cFileLog	:= TAFGetPath( "2" , "DIEF-CE" ) + "\LOG-DIEF.txt"

Local cParamThre	:= "DIEFCE"
Local cSemaphore	:=	""
Local lMultThread	:=	.F.
Local nQtdThread	:=	0
Local aJobAux		:=	{}
Local cJobAux		:=	""
Local nTryExec	:=	0

//Total de linhas
ClearGlbValue( "cTotLin" )

//Semafaro do Log 0 - Livre, 1 - Bloqueado
ClearGlbValue( "cFreeLog" )
PutGlbValue( "cFreeLog", "0" )
GlbUnlock()

//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
xParObrMT( cParamThre, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

cRegime := GetRegime(aWizard, lProc)

//Alimentando o array com os registros que devem ser processados juntamente com seus respectivos filhos
aRegDIEF := GetRegDIEF( aWizard, cRegime )

//Quantidade de registro + 2 mensagens de Posicionamento
nBarProgr1 := (Len(aRegDIEF)) + 2
nBarProgr2 := nBarProgr1

oProcess:Set1Progress( nBarProgr1 )
oProcess:Set2Progress( nBarProgr2 )


For nIndiceReg := 1 to Len(aRegDIEF)
	If lProc .Or. oProcess:nCancel == 1
		cFunction := aRegDIEF[nIndiceReg][2]
		
		If lMultThread
			//Inicializa variavel global de controle das Threads
			cJobAux := StrTran( "cDIEF_" + FwGrpCompany() + FwCodFil(), ' ', '_' ) + StrZero( nIndiceReg , 2 )
			
			//Adiciona o nome do arquivo de Job no array aJobAux
			aAdd( aJobAux, { cJobAux, aRegDIEF[nIndiceReg,3] } )
			
			//Variavel de controle de Start das Execuções
			nTryExec := 0
			
			While .T.
				If IPCGo( cSemaphore, cParamThre, cFunction, aWizard, cRegime, cJobAux )
					//"0" Thread Iniciada e pendente de processamento
					PutGlbValue( cJobAux, "0" )
					GlbUnlock()
					Exit
				Else
					nTryExec ++
					Sleep( 200 )
				EndIf

				//Caso ocorra erro em 10 tentativas de iniciar a Thread aborta informando ao usuário o erro
				If nTryExec > 10
					lProc := .F.
					AddLogDIEF(STR0022) //"Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo."
					Exit
				EndIf
			EndDo
		Else
			oProcess:Inc1Progress( STR0027 + aRegDIEF[nIndiceReg][3])//"Gerando registro "
			oProcess:Inc2Progress( STR0023 )//"Processando os registros da DIEF-CE..."
			
			&cFunction.( aWizard, cRegime, cJobAux )
			
			If (File( cFileLog ))
				lProc := .F.
			EndIf
		EndIf
	Else
		oProcess:Inc1Progress( STR0024 )//"Cancelando..."
		oProcess:Inc2Progress( STR0024 )//"Cancelando..."
	EndIf
Next

If lProc .And. oProcess:nCancel != 1
	
	//Se for multiThread deverá ser verificado o resultado do processamento das threads antes de gerar o registro fim 
	If(lMultThread)
		nThread := Len(aRegDIEF)
		While nThread > 0
			
			For nIndiceJob := 1 To Len(aJobAux) 
				cJobAux := aJobAux[nIndiceJob,1]
				Do Case
				//1- Thread Finalizou com sucesso
				Case GetGlbValue( cJobAux ) == "1"
					
					oProcess:Inc1Progress( STR0026 + " " + aJobAux[nIndiceJob,2] + STR0028)//"Registro"; //" Gerado com sucesso!"
					oProcess:Inc2Progress( STR0023 )//"Processando os registros da DIEF-CE..."
	
					nThread--
					ClearGlbValue( cJobAux )
	
				//9- Thread Apresentou erro, verificar log
				Case GetGlbValue( cJobAux ) == "9"
	
					oProcess:Inc1Progress( STR0029 + aJobAux[nIndiceJob,2]) //"Não possível gerar o registro "
					oProcess:Inc2Progress( STR0023 )//"Processando os registros da DIEF-CE..."
					
					lProc := .F.
					nThread--
					ClearGlbValue( cJobAux )
				EndCase
			Next
		EndDo
	EndIf
	
	TAFDFFIM( aWizard, cRegime )
	
	oProcess:Inc1Progress( STR0025 )//"Gerando o aquivo magnetico da DIEF-CE..."
	oProcess:Inc2Progress( STR0030 )//"Processando..."
Else
	oProcess:Inc1Progress( STR0024 )//"Cancelando..."
	oProcess:Inc2Progress( STR0024 )//"Cancelando..."
EndIf

xFinalThread( cSemaphore, nQtdThread )
GerTxtDIEF(aWizard, lProc)

//Tratamento para quando o processamento tem problemas
If !lProc .Or. oProcess:nCancel == 1

	//Cancelado o processamento
	If oProcess:nCancel == 1
		Aviso( "Atenção!", STR0031, { "Sair" } )//"A geração do arquivo foi cancelada com sucesso!"
		oProcess:Inc1Progress(STR0032)//"Cancelado pelo usuário"
		oProcess:Inc2Progress(STR0032)//"Cancelado pelo usuário"

	Else

		Aviso( "Atenção!", STR0034 + STR0035, { "Sair" } )//"Verifique o log de erros da rotina. Não foi possível gerar o arquivo magnetico da DIEF-CE."
		oProcess:Inc1Progress( STR0034 ) //"Verifique o log de erros da rotina."
		oProcess:Inc2Progress( STR0035 ) //"Não foi possível gerar o arquivo magnetico da DIEF-CE."

	EndIf

Else
	oProcess:Inc1Progress(STR0033) //"Finalizado a Geração da DIEF-CE"
	oProcess:Inc2Progress(STR0036) //"Arquivo gerado com sucesso!"
EndIf


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam             
Desenha o wizard com os parametros para a execução da rotina

Array do wizard
[1]		Diretório do Arquivo Destino
[2]		Nome do Arquivo Destino
[3]		Versão do Layout Nova DIEF-CE
[4]		Tipo DIEF-CE
[5]		Inicio Periodo
[6]		Fim Periodo
[7]		Finalidade DIEF-CE
[8]		Motivo DIEF-CE
[9]		Código do transmissor responsável
[10]	Contabilista
[11]	Percentual FDI
[12]	Data de Vencimento FDI
[13]	Contribuinte de IPI
[14]	Substituto nas operações de saída
[15]	Informar valores extemporâneos manualmente

@author David Costa
@since  16/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function getObrigParam()
Local  cNomWiz  	:= cObrig + FWGETCODFILIAL 
Local 	cNomeAnt 	:= ""	
Local	cTitObj1	:= ""
Local	cTitObj2	:= ""
Local	aTxtApre	:= {}
Local	aPaineis	:= {}
Local	aRet		:= {}
Local	aItens1	:= {}
Local  nPos		:= 0

aAdd (aTxtApre, STR0001)//Processando Empresa
aAdd (aTxtApre, "")	
aAdd (aTxtApre, STR0002)//"Preencha corretamente as informações solicitadas."
aAdd (aTxtApre, STR0003)//"Informações necessárias para a geração do arquivo magnético da DIEFE-CE."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 0     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], STR0002)//"Preencha corretamente as informações solicitadas."
aAdd (aPaineis[nPos], STR0003)//"Informações necessárias para a geração do arquivo magnético da DIEF-CE."
aAdd (aPaineis[nPos], {})

cTitObj1	:=	STR0004 ;											cTitObj2	:=	STR0005//Diretório do Arquivo Destino; Nome do Arquivo Destino
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 100);							cTitObj2	:=	Replicate ("X", 100)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	STR0006;											cTitObj2	:=	STR0007//"Versão do Layout Nova DIEF-CE"; "Tipo DIEF-CE:"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

															    	aItens2	:=	{} 
																	aAdd (aItens2, "1 - DIEF") 
																	aAdd (aItens2, "3 - Inventário") 
																	aAdd (aItens2, "4 - Centros Comerciais") 
																	
cTitObj1	:=	Replicate ("X", 3)							
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	STR0008 ;											cTitObj2	:=	STR0009//"Inicio Periodo"; "Fim Periodo"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 10);								cTitObj2	:=	Replicate ("X", 10)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,3,,,,});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,3,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	STR0010;											cTitObj2	:=  STR0011 //"Finalidade DIEF-CE:" ; "Motivo DIEF-CE:"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "01 - Normal (inclusão)"); 					aAdd (aItens2, "01 - Mensal")
aAdd (aItens1, "02 - Retificação");							aAdd (aItens2, "03 - Baixa cadastral")								
																	aAdd (aItens2, "04 - Alteração de regime de recolhimento")
																	aAdd (aItens2, "05 - Alteração de endereço")    
																	aAdd (aItens2, "06 - Alteração de sistemática de tributação")	
																	aAdd (aItens2, "07 - Fiscalização")
																	aAdd (aItens2, "09 - Estoque final do Exercício")
																	aAdd (aItens2, "10 - Estoque na Baixa Cadastral")
																	
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	STR0012; 											cTitObj2	:= STR0018//"Código do transmissor responsável"; "Contabilista "
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,});

cTitObj1	:=	Replicate ("X", 20);								cTitObj2	:=	Replicate ("X", 100)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})			

cTitObj1	:=	"Percentual FDI" ;											cTitObj2	:=	"Data de Vencimento FDI" //Percentual FDI; Data de Vencimento FDI
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 100);							cTitObj2	:=	Replicate ("X", 10)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,3,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
										
cTitObj1	:=	STR0013 //"Contribuinte de IPI?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	

cTitObj1	:=	Replicate ("X", 1)	
aAdd (aPaineis[nPos][3], {4,,cTitObj1,1,,,.F.,})	

cTitObj1	:= STR0014	//"Substituto nas operações de saída?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	

cTitObj1	:=	Replicate ("X", 1)	
aAdd (aPaineis[nPos][3], {4,,cTitObj1,1,,,.F.,})

cTitObj1	:= STR0038//"Informar valores extemporâneos manualmente?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	

cTitObj1	:=	Replicate ("X", 1)	
aAdd (aPaineis[nPos][3], {4,,cTitObj1,1,,,.F.,})

aAdd(aRet , aTxtApre)
aAdd(aRet, aPaineis)
aAdd(aRet, cNomWiz)
aAdd(aRet, cNomeAnt)
aAdd(aRet, Nil )
aAdd(aRet, Nil )
aAdd(aRet, { || TAFXDFCE() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo

Return (aRet) 

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtReg

Gera o arquivo dos registros

@Return ( Nil )

@Author David Costa
@Since 16/07/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtReg( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "DIEF-CE" )
Local	cFileDest		:=	""
Local	nRetDir		:=	0
Local	lRet			:=	.T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )
	
	nRetDir := FWMakeDir( cDirName )

	if nRetDir <> 0

		cDirName	:=	""
		
		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\DIEF-CE. Erro: " + cValToChar( FError() ) , 1, 0 )
		
		lRet	:=	.F.
	
	endIf

endIf

If lRet
	//Monta nome do arquivo que será gerado
	cFileDest := TAFAPath(cDirName) + cReg
	
	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".txt"
	EndIf
	
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDIEF

Geracao do Arquivo TXT da DIEF-CE

@Return ( Nil )

@Author David Costa
@Since 16/07/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtDIEF(aWizard, lProc)

Local cFileDest  	:=	""
Local cPathTxt	:=	TAFGetPath( "2" , "DIEF-CE" )		      //diretorio onde foram gerados os arquivos txt temporarios
Local aArqReg		:= {}
Local nIndiceArq	:= 0
Local cTxtDIEF	:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local cFileLog	:= TAFGetPath( "2" , "DIEF-CE" ) + "\LOG-DIEF.txt"

aArqReg := DIEFArqReg(TAFAPath( cPathTxt ))

If (!File( cFileLog ) .And. lProc)
	cFileDest :=	Alltrim( TAFAPath(aWizard[1][1])) + Alltrim(aWizard[1][2] )		//diretorio + nome do arquivo final ( consolidado )
	
	For nIndiceArq := 1 to Len(aArqReg)
		If File( aArqReg[nIndiceArq][1] )
			FT_FUSE( aArqReg[nIndiceArq][1] )		//ABRIR
			FT_FGOTOP()								//POSICIONO NO TOPO
			While !FT_FEOF()
		   		cBuffer := FT_FREADLN()
	   			cTxtDIEF += cBuffer + CRLF
	 			FT_FSKIP()
	    	EndDo
		EndIf
		FT_FUSE()
	Next
ElseIf(File( cFileLog )) //Log de Erros
	
	//diretorio + nome do arquivo de log
	cFileDest :=	Alltrim( TAFAPath(aWizard[1][1])) + Alltrim(aWizard[1][2] ) + "_Log_Erros"
	
	FT_FUSE( cFileLog )
	FT_FGOTOP()
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
   		cTxtDIEF += cBuffer + CRLF
 		FT_FSKIP()
    EndDo
	FT_FUSE()
	//Adiciona o arquivo no array para ser apagado junto com os demais
	Aadd( aArqReg, { cFileLog } )
EndIf

If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".txt"
	cFileDest := cFileDest + ".txt"
EndIf

WrtStrTxt( nHandle, cTxtDIEF )

lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

//Apaga os arquivos temporário utilizados na geração
For nIndiceArq := 1 to Len(aArqReg)
	If File( aArqReg[nIndiceArq][1] )
		FErase(aArqReg[nIndiceArq][1])
	EndIf
Next

Return( lRet )

// ----------------------------
Static Function DIEFArqReg(cPathTxt)

Local aRet	:=	{}

AADD(aRet,{cPathTxt+"EMP.TXT"})
AADD(aRet,{cPathTxt+"CTD.TXT"})
AADD(aRet,{cPathTxt+"MES.TXT"})
AADD(aRet,{cPathTxt+"PRD.TXT"})
AADD(aRet,{cPathTxt+"GNR.TXT"})
AADD(aRet,{cPathTxt+"CFC.TXT"})
AADD(aRet,{cPathTxt+"DOC.TXT"})
AADD(aRet,{cPathTxt+"ITE.TXT"})
AADD(aRet,{cPathTxt+"DCT.TXT"})
AADD(aRet,{cPathTxt+"PAR.TXT"})
AADD(aRet,{cPathTxt+"REF.TXT"})
AADD(aRet,{cPathTxt+"TOT.TXT"})
AADD(aRet,{cPathTxt+"LEX.TXT"})
AADD(aRet,{cPathTxt+"OCR.TXT"})
AADD(aRet,{cPathTxt+"DAE.TXT"})
AADD(aRet,{cPathTxt+"ODB.TXT"})
AADD(aRet,{cPathTxt+"IDA.TXT"})
AADD(aRet,{cPathTxt+"DED.TXT"})
AADD(aRet,{cPathTxt+"DCE.TXT"})
AADD(aRet,{cPathTxt+"VIC.TXT"})
AADD(aRet,{cPathTxt+"STB.TXT"})
AADD(aRet,{cPathTxt+"PRI.TXT"})
AADD(aRet,{cPathTxt+"STQ.TXT"})
AADD(aRet,{cPathTxt+"ACS.TXT"})
AADD(aRet,{cPathTxt+"EST.TXT"})
AADD(aRet,{cPathTxt+"INV.TXT"})
AADD(aRet,{cPathTxt+"FIM.TXT"})

return( aRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRegDIEF

Definição dos registros que serão gerados no arquivo magnetico

@Return Array com os registro que deverão ser gerados

@Author David Costa
@Since 29/10/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetRegDIEF( aWizard, cRegime )

Local aObrBloco := {}

//Comum a todos os tipo de geração
aAdd( aObrBloco, { .T., "TAFDFEMP", "EMP" } )
aAdd( aObrBloco, { .T., "TAFDFCTD", "CTD" } )

//Gerar Inventário
If( aWizard[1][4] == "3 - Inventário" )
	aAdd( aObrBloco, { .T., "TAFDFPRD", "PRD" } )
	aAdd( aObrBloco, { .T., "TAFDFEST", "EST" } )
	aAdd( aObrBloco, { .T., "TAFDFINV", "INV" } )

//Centros Comerciais, shoppings ou semelhantes
ElseIf( aWizard[1][4] == "4 - Centros Comerciais" )
	aAdd( aObrBloco, { .T., "TAFDFACS", "ACS" } )

Else
	If(!Empty(cRegime))
		//1 - Normal
		If( cRegime $ ('|01|') )
			aAdd( aObrBloco, { .T., "TAFDFPRD", "PRD" } ) 
			aAdd( aObrBloco, { .T., "TAFDFGNR", "GNR" } )
			aAdd( aObrBloco, { .T., "TAFDFDOC", "DOC" } )
			aAdd( aObrBloco, { .T., "TAFDFCFC", "CFC" } )
			aAdd( aObrBloco, { .T., "TAFDFLEX", "LEX" } )
			aAdd( aObrBloco, { .T., "TAFDFOCR", "OCR" } )
			aAdd( aObrBloco, { .T., "TAFDFODB", "ODB" } )
			aAdd( aObrBloco, { .T., "TAFDFDED", "DED" } )
			aAdd( aObrBloco, { .T., "TAFDFDCE", "DCE" } )
			aAdd( aObrBloco, { .T., "TAFDFVIC", "VIC" } )
			aAdd( aObrBloco, { .T., "TAFDFSTB", "STB" } )
			aAdd( aObrBloco, { .T., "TAFDFPRI", "PRI" } )
		
		//7 – Microempresa-SN ou 8 – EPP-SN
		ElseIf( cRegime $ ('|07|08|') )
			aAdd( aObrBloco, { .T., "TAFDFMES", "MES" } )
			aAdd( aObrBloco, { .T., "TAFDFDOC", "DOC" } )
			aAdd( aObrBloco, { .T., "TAFDFDCE", "DCE" } )
			aAdd( aObrBloco, { .T., "TAFDFVIC", "VIC" } )
			aAdd( aObrBloco, { .T., "TAFDFSTB", "STB" } )
		
		//5 – Reg. Especial.
		ElseIf( cRegime $ ('|05|') )
			aAdd( aObrBloco, { .T., "TAFDFMES", "MES" } )
			aAdd( aObrBloco, { .T., "TAFDFDOC", "DOC" } )
			aAdd( aObrBloco, { .T., "TAFDFDCE", "DCE" } )
			aAdd( aObrBloco, { .T., "TAFDFVIC", "VIC" } )
			aAdd( aObrBloco, { .T., "TAFDFPRI", "PRI" } )
			aAdd( aObrBloco, { .T., "TAFDFSTQ", "STQ" } )
		
		//6 – Reg.Outros
		ElseIf( cRegime $ ('|06|') )
			aAdd( aObrBloco, { .T., "TAFDFMES", "MES" } )
			aAdd( aObrBloco, { .T., "TAFDFDOC", "DOC" } )
			aAdd( aObrBloco, { .T., "TAFDFDCE", "DCE" } )
			aAdd( aObrBloco, { .T., "TAFDFVIC", "VIC" } )
			aAdd( aObrBloco, { .T., "TAFDFPRI", "PRI" } )
		
		//12 – Produtor Rural.
		ElseIf( cRegime $ ('|12|') )
			aAdd( aObrBloco, { .T., "TAFDFMES", "MES" } )
			aAdd( aObrBloco, { .T., "TAFDFDOC", "DOC" } )
			aAdd( aObrBloco, { .T., "TAFDFDCE", "DCE" } )
		
		EndIf 
	EndIf
	DbCloseArea("C1E")
EndIf

Return( aObrBloco )

//-------------------------------------------------------------------
/*/{Protheus.doc} AddLinDIEF             
Incrementa uma linha no total de linhas do arquivo DIEF-CE

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function AddLinDIEF( )

Local nTotLin	:= 0

nTotLin	:= val(GetGlbValue( "cTotLin" ))
nTotLin++
PutGlbValue( "cTotLin" , Str(nTotLin) )
GlbUnlock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRegime
Retorna o Regime da Filial

@author David Costa
@since  18/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function GetRegime( aWizard, lProc )

Local cRegime	:= ""
Local cAliasQry	:= GetNextAlias()
Local cMesIni	 	:= SubStr( DToS( aWizard[1][5] ), 5, 2)
Local cAnoIni	 	:= SubStr( DToS( aWizard[1][5] ), 1, 4)
Local cMesFim	 	:= SubStr( DToS( aWizard[1][6] ), 5, 2)
Local cAnoFim	 	:= SubStr( DToS( aWizard[1][6] ), 1, 4)
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " T39_TIPREG "
cFrom   	:= RetSqlName("T39") + " T39 "
cWhere  	:= " T39.D_E_L_E_T_ = '' "
cWhere  	+= " AND T39_FILIAL = '" + xFilial( "T39" ) + "' "
cWhere  	+= " AND (( SUBSTRING(T39_PERINI, 1, 2) <= '" + cMesIni + "'  AND SUBSTRING(T39_PERINI, 4, 4) = '" + cAnoIni + "') " 
cWhere  	+= " 		OR (SUBSTRING(T39_PERINI, 4, 4) < '" + cAnoIni + "') ) "
cWhere  	+= " AND ((SUBSTRING(T39_PERFIN, 1, 2) >= '" + cMesFim + "'  AND SUBSTRING(T39_PERFIN, 4, 4) = '" + cAnoFim + "') "
cWhere  	+= " OR(SUBSTRING(T39_PERFIN, 4, 4) > '" + cAnoFim + "') "
cWhere  	+= " OR T39_PERFIN = '') "

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

cRegime := (cAliasQry)->T39_TIPREG

If !( cRegime $ "|01|05|06|07|08|12|" )
	AddLogDIEF("Regime da Filial Inválido, verifique o cadastro de Regimes." + CRLF)
	lProc := .F.
EndIf

DbCloseArea(cAliasQry)

Return( cRegime )


//---------------------------------------------------------------------
/*/{Protheus.doc} AddLogDIEF

Preenche o Log de Erros do processo

@Author David Costa
@Since 22/05/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Function AddLogDIEF( cError )
Local cFileLog	:= TAFGetPath( "2" , "DIEF-CE" ) + "\LOG-DIEF.txt"
Local cSeparador	:= "//---------------------------------------------------------------------" + CRLF
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local nCtrlLog	:= 0

While( GetGlbValue( "cFreeLog" ) == "1")
	Sleep( 200 )
	nCtrlLog ++
	If( nCtrlLog > 50)
		Exit
	EndIf
EndDo

//Semafaro do Log 0 - Livre, 1 - Bloqueado
PutGlbValue( "cFreeLog", "1" )
GlbUnlock()

cError := cError + CRLF

//Verifica se o Log já existe
If File( cFileLog )
	nHandle := FOPEN(cFileLog, FO_WRITE)
	FSEEK(nHandle, 0, FS_END)
	FWrite( nHandle , cSeparador , Len( cSeparador ) )
	FWrite( nHandle , cError , Len( cError ) )
   	FCLOSE( nHandle )
Else
	WrtStrTxt( nHandle, cError )
	GerTxtReg( nHandle, cTXTSys, "LOG-DIEF" )
EndIf


//Semafaro do Log 0 - Livre, 1 - Bloqueado
PutGlbValue( "cFreeLog", "0" )
GlbUnlock()

Return
