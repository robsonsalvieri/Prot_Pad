#INCLUDE "TOTVS.ch"
#INCLUDE 'FILEIO.CH'    
#INCLUDE 'QPPM040.CH'    
                                                                             
#Define PARETO "6"      

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPM040	  ³ Autor ³ Cleber Souza          ³ Data ³ 17/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grafico de Pareto - FMEA´s Processo e Projeto.        	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPM040()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Numero da Peca      								    ³±±
±±³			 ³ EXPC2 = Revisao da Pecao 								    ³±±
±±³			 ³ EXPC3 = Tipo do Grafico (1= Projeto, 2= Processo)		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPPAP				                 					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS  ³ MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPPM040(cPeca,cRevisao,cTipo)

Local cPerg    := "QPPM40"

Private aDados := {}
Private aNPR   := {}

If Pergunte(cPerg,.T.) 
	QPPM40PROC(cPeca,cRevisao,cTipo)
EndIF

Return          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPM40PROCºAutor  ³Cleber Souza        º Data ³  17/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Geração do Grafico de Pareto.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPM040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPPM40PROC(cPeca,cRevisao,cTipo) 
Local aDad64      := {}
Local cArqSPC     := ""
Local cDir        := GetMv("MV_QDIRGRA") //Diretorio para geracao do grafico
Local cSenhas     := "1"
Local lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A"
Local nI          := 0
	      
// Verifica se o diretorio do grafico é  um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

If cTipo=="1"
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK6")
	DbSetOrder(4)
	DbSeek(xFilial("QK6")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK6->QK6_PECA+QK6->QK6_REV
    	AADD(aNPR,{QK6->QK6_SEQ,IIF(mv_par01==1,QK6->QK6_NPR,QK6->QK6_RNPR)})
    	QK6->(dbSkip())
    EndDo 
    
Else
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK8")
	DbSetOrder(4)
	DbSeek(xFilial("QK8")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK8->QK8_PECA+QK8->QK8_REV
    	AADD(aNPR,{QK8->QK8_SEQ,IIF(mv_par01==1,QK8->QK8_NPR,QK8->QK8_RNPR)})
    	QK8->(dbSkip())
    EndDo 

EndIf

// Organiza array com as NPRs.
If mv_par02==2
	aNPR := aSort(aNPR,,, { | x,y | x[2] < y[2] })
ElseIf mv_par02==3
   	aNPR := aSort(aNPR,,, { | x,y | x[2] > y[2] })
EndIF

// Monta vetor com os dados do grafico
Aadd(aDados,"QACHART.DLL - PARETO")

// Define Texto do Titulo
aAdd( aDados,"[TITLE]" )

If cTipo=="1"
	aAdd( aDados,STR0001) //" - FMEA de Projeto"
Else
	aAdd( aDados,STR0002) //" - FMEA de Processo"
EndIF

Aadd(aDados,"[LANGUAGE]")
Aadd(aDados,Upper(__Language) )

//Tira a linha do Pareto
aAdd( aDados,"[LINHA PARETO]" )
aAdd( aDados,"FALSE" )

//Define o Rodape do grafico.
aAdd( aDados,"[FOOT]" )
aAdd( aDados,STR0003+Alltrim(cPeca)+STR0004+Alltrim(cRevisao) ) //"Peca: "###" Revisao: "

Aadd(aDados,"[DADOS PARETO]")

For nI := 1 to Len(aNPR)
	Aadd(aDados,AllTrim(aNPR[nI,2])+";"+Alltrim(aNPR[nI,1]))
	If lExistChart
		Aadd(aDad64,{ AllTrim( aNPR[nI,2] ), aNPR[nI,1]})
	EndIf
Next nI

Aadd(aDados,"[FIM DADOS PARETO]")

// Gera o nome do arquivo SPC
cArqSPC := QPP40NoArq(cDir)

If !Empty(cArqSPC) .And. lExistChart
	QIEMGRAFIC(aDad64, 2)
Else
	MessageDlg(STR0005,,3)  //"Não foram encontradas NPRs, a partir dos dados solicitados."
EndIf

Return
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPP40NoArq³ Autor ³ Cleber Souza          ³ Data ³ 17/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera nome do arquivo SPC									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP40NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0
// Verifica o arquivo disponivel com extensao SPC
For nI := 1 to 99999
	cArq := "QPP" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI
Return cArq     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QPP40GerAr³ Autor ³ Cleber Souza      	³ Data ³17/08/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava um arquivo Txt no formato da OCX QC_CHART		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com os dados a gravar						  ³±±
±±³			 ³ExpC1 - Arquivo para dados								  ³±±
±±³			 ³ExpC2 - Diretorio para gerar o arquivo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - TRUE - caso criou o arquivo corretamente e FALSE	  ³±±
±±³			 ³ caso tenha havido alguma falha							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPP40GerAr( aDados , cFile , cDir )
Local lOk		:= .T.
Local nHandle	:= 0
Local nSec		:= 0

Default cFile	:= "QACHART.SPC"
Default aDados	:= { }

// Formato do array a ser passado
// Array de uma coluna contendo uma string
If File( cDir+cFile )
	If FErase(cDir+cFile) == 0
		lOk := .T.
	else
		nSec := Seconds()
		While FErase(cDir+cFile) <> 0
			if Seconds() > nSec + 5
				lOk := .F.
				Exit
			Endif
		EndDo
		if !lOk
			MsgStop(STR0006,STR0007)	//"Outro usuário utilizando o arquivo. Tente novamente" #### "Atenção"
		Endif
	Endif
Endif

If lOk
	IF (nHandle := FCREATE(cDir+cFile, FC_NORMAL)) == -1
		lOk := .F.
		MsgStop(STR0008 + cDir+cFile,STR0007) //"Não foi possível criar o arquivo para o gráfico " #### "Atenção" 
	Endif
Endif

If lOk
	aEval( aDados, { |cTexto,nX| FWrite( nHandle, cTexto + Chr(13)+Chr(10) ), Len(cTexto) } )
	FClose(nHandle)
Endif

Return lOk
