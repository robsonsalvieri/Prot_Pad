#INCLUDE "Protheus.ch"
#INCLUDE "UpdPcl01.ch"


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpdPCL01      ³ Autor ³Janaina Silva          ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da tabela LEG (template de combustivel)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    
User Function UpdPCL01()

Local   cMsg     := "Deseja atualizar os campos da tabela LEG? Esta rotina deve ser utilizada em modo exclusivo ! Faca um backup da Base de Dados antes da atualização para eventuais falhas de atualização !"
Local   cTipoMsg := "Atenção"

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE oMainWnd 


Set Dele On

lHistorico 	:= MsgYesNo(cMsg, cTipoMsg)
lEmpenho	:= .F.
lAtuMnu		:= .F.

DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE STR0003 //"Atualizando Base de Dados"

ACTIVATE WINDOW oMainWnd ;                        //"Processando" "Aguarde, atualizando base de dados", "Processo finalizado", "Processo finalizado"
	ON INIT If(lHistorico,(Processa({|| AtualizaLEG()},STR0007,STR0008,.F.) , Final(STR0009)),Final(STR0009))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Final     ³ Autor ³Mauro Sano             ³ Data ³ 10/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra mensagem e finaliza o processo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao da tabela SAE                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Final(cMensagem)
	MsgStop(cMensagem)
	oMainWnd:End()	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AtualizaLEG    ³ Autor ³Janaina Silva          ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a atualizacao dos dados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao da tabela LEG                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtualizaLEG()
Local lOpen     := .F.									//Indica se conseguiu fazer a abertura
Local aRecnoSM0 := {}     								//Array com os Recnos da tab. de empresas
local nX   
local nI  
Local cMsg     := "Campo LEG_NUMORC nao foi criado na tabela LEG, favor executar os passos definidos no boletim tecnico."
Local cTipoMsg := "Atenção"

//IncProc(STR0008) //"Verificando integridade dos dicionários...."
If ( lOpen := MyOpenSm0Ex() )                                                     
             
	dbSelectArea("SM0")
	dbGotop()

	While !Eof() 
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		dbSkip()
	EndDo	
                
	ProcRegua(Len(aRecnoSM0))
	For nI := 1 To Len(aRecnoSM0)
		SM0->(dbGoto(aRecnoSM0[nI,1]))
		RpcSetType(2) 
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
		
		AjustaSX3() 
				
		__SetX31Mode(.F.)
		
		For nX := 1 To Len(aArqUpd)
			IncProc() 
			If Select(aArqUpd[nx])>0
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[nx])
			If __GetX31Error()
				Alert(__GetX31Trace())
			EndIf
		Next nX		
		RpcClearEnv()
		If !( lOpen := MyOpenSm0Ex() )
			Exit 
		EndIf 

	Next nI 
	

	dbSelectArea("SM0")
	dbGotop()
		
	For nI := 1 To Len(aRecnoSM0)
		SM0->(dbGoto(aRecnoSM0[nI,1]))
		RpcSetType(2) 
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

                                                                                       
		If LEG->(FieldPos("LEG_NUMORC")) == 0

			MsgStop(cMsg, cTipoMsg)	
			Return .F.
		EndIf 
		
		RpcClearEnv()
		If !( lOpen := MyOpenSm0Ex() )
			Exit 
		EndIf 
		
	Next nI 
 EndIf 	

Return(.T.)                       
                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX3 ³ Autor ³Mauro Sano             ³ Data ³ 10/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui no SX3 os campos LG_PORTBAL e LG_TIMEBAL            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao da tabela SAE                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX3()
Local aSX3      := {}		//Array com os campos a incluir no SX3
Local nI, nJ				//variaveis para loop na insersao do campo
Local cUsado2	:= ""		//Guarda conteudo do X3_USADO
Local cReserv2	:= ""		//Guarda conteudo do X3_RESERV
Local aEstrut   := {}		//Array com a estrutura do SX3

aEstrut:= { 	"X3_ARQUIVO",	"X3_ORDEM",		"X3_CAMPO",		"X3_TIPO"   ,;
				"X3_TAMANHO",	"X3_DECIMAL",	"X3_TITULO",	"X3_TITSPA",;
				"X3_TITENG" ,	"X3_DESCRIC",	"X3_DESCSPA",	"X3_DESCENG",;
				"X3_PICTURE",	"X3_VALID"  ,	"X3_USADO"  ,	"X3_RELACAO",;
				"X3_F3"     ,	"X3_NIVEL"  ,	"X3_RESERV" ,	"X3_CHECK"  ,;
				"X3_TRIGGER",	"X3_PROPRI" ,	"X3_BROWSE" ,	"X3_VISUAL" ,;
				"X3_CONTEXT",	"X3_OBRIGAT",	"X3_VLDUSER",	"X3_CBOX"   ,;
				"X3_CBOXSPA",	"X3_CBOXENG",	"X3_PICTVAR",	"X3_WHEN"   ,;
				"X3_INIBRW" ,	"X3_GRPSXG" ,	"X3_FOLDER",	"X3_PYME"}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtendo a Proxima Ordem disponivel na tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetOrder(1))
SX3->(DbSeek("LEG"+"Z",.T.))
SX3->(dbSkip(-1))
If SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "LEG"
	cOrdem  := Soma1(SX3->X3_ORDEM)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o campo ja' existe na tabela	  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetOrder(2))
If !SX3->(DbSeek("LEG_NUMORC"))     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando os campos da Tabela SAE             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aSX3,{"LEG",;										//Arquivo
		cOrdem,;				  							//Ordem
		"LEG_NUMORC",;		   								//Campo
		"C",;				   								//Tipo
		6,;					 								//Tamanho
		0,;					 								//Decimal
		"Nr Orcamento",;	  								//Titulo
		"",;	 											//Titulo SPA
		"",;	  											//Titulo ENG
		"Nr Orc. do Abastecimento",;						//Descricao
		"",;						//Descricao SPA
		"",;							//Descricao ENG
		"@!",;												//Picture
		'',;									//VALID
		cUsado2,;				   							//USADO
		"",;					  							//RELACAO - default
		"",;					 							//F3
		1,;											   		//NIVEL
		cReserv2,;			   								//RESERV
		"",;					 							//CHECK
		"",;												//TRIGGER
		"",;					  							//PROPRI
		"S",;					 							//BROWSE
		"V",;												//VISUAL
		"",;				   								//CONTEXT
		"",;												//OBRIGAT
		"",;												//VLDUSER
		"",;												//CBOX
		"",;				   								//CBOX SPA
		"",;					  							//CBOX ENG
		"",;												//PICTVAR
		"",;												//WHEN
		"",;					  							//INIBRW
		"",;												//SXG
		"",;				  								//FOLDER
		"S"})												//PYME
	    
	ProcRegua(Len(aSX3))
	
	SX3->(DbSetOrder(2))
	
	For nI:= 1 To Len(aSX3)
		If !Empty(aSX3[nI][1])
			If !DbSeek(aSX3[nI,3])
				lSX3	:= .T.
				RecLock("SX3",.T.)     
				
				aAdd(aArqUpd,aSX3[nI,1])
				
				For nJ:=1 To Len(aSX3[nI])
					If FieldPos(aEstrut[nJ])>0 .And. aSX3[nI,nJ] <> NIL
						FieldPut(FieldPos(aEstrut[nJ]),aSX3[nI,nJ])
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
				IncProc()
			Endif
		EndIf
	Next nI
Else
	Conout(STR0005)	
Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zero o array com a atualizacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSx3 := {} 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.		//Indica se conseguiu fazer a abertura
Local nLoop := 0 		//Usada em lacos For...Next

For nLoop := 1 To 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) //Verificar 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetIndex("SIGAMAT.IND") 
		Exit	
	EndIf
	Sleep( 500 )                                                                                    
Next nLoop 

If !lOpen 
	MsgStop(STR0010, STR0002)  //"Nao foi possivel a abertura da tabela de empresas de forma exclusiva !" "Atencao !"
EndIf                                 

Return( lOpen ) 

