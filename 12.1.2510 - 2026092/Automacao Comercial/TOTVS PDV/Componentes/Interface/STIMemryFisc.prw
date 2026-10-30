#Include "PROTHEUS.CH
#INCLUDE "STMEMRYFISC.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMemryFisc
Function interface da memória fiscal
@param   	nTipoRel -Tipo do relatório
@param   	cReducIni - Redução Inicial
@param   	cReducFim - Redução Final
@param   	nCheck1 - CheckBox
@param   	nOpca - Opção selecionada
@param   	dDataIni - Data Inicial
@param   	dDataFinal - Data Final
@param   	lCont - Continua execução
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Abertura com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIMemryFisc(nTipoRel,	cReducIni, cReducFim,	nCheck, ;
						nOpca, 		dDataIni, 	dDataFim, 	lCont,;
						oFont)


Local oDlgMF							// Instaciacao do objeto de montagem da tela
Local oReducIni							// Objeto da reducao inicial
Local oReducFim							// objeto da reducao final
Local oCheck1							// Objeto do check (impressora / disco )
Local oDataIni							// Objeto da data inicial
Local oDataFim							// Objeto da data final
Local oCheck1							// Objeto do check (impressora / disco )
Local oTipoRel							// Objeto do tipo de relatorio memoria fiscal ou MFD
Local oKeyb                       		// Objeto do teclado

DEFINE MSDIALOG oDlgMF FROM 39,85 TO 450,340 TITLE  STR0003 PIXEL OF oMainWnd //"Leitura de Memória Fiscal"

DEFINE FONT oFont NAME "Ms Sans Serif" BOLD
// Definindo o Objeto Teclado

@ 7, 4 TO 60, 121 LABEL STR0004 OF oDlgMF  PIXEL // "Objetivo do Programa" 

//               Este programa tem como objetivo
// efetuar  a  impress„o   da leitura  de   mem¢ria    fiscal   da
// impressora   fiscal
@ 19, 15 SAY STR0005 SIZE 100, 40 OF oDlgMF PIXEL FONT oFont   //"Este programa tem como objetivo efetuar  a  impressão da leitura de mem¢ria fiscal da impressora fiscal."
@ 63,4 TO 90,121 LABEL STR0006 PIXEL OF oDlgMF // "Selecione Relatório"
@ 70,7 Radio oTipoRel Var nTipoRel Items STR0007,STR0008 3D Size 85,10 ON CHANGE ( STBMemVal(nTipoRel,@oReducIni,@oReducFim,@oCheck1) ) PIXEL OF oDlgMF // Memoria Fiscal, MFD (Memoria de Fita Detalhe)
        
@ 93,4 TO 118,121 LABEL STR0009 OF oDlgMF  PIXEL // 'Leitura por data'
@ 103,10  SAY STR0010 SIZE 48, 7 OF oDlgMF PIXEL  // Inicial:
@ 103,70  SAY STR0011 SIZE 48, 7 OF oDlgMF PIXEL  // Final:

                                                               
@ 103, 30 MSGET oDataIni Var dDataIni SIZE 32, 8 OF oDlgMF PIXEL
@ 103, 85 MSGET oDataFim Var dDataFim SIZE 32, 8 OF oDlgMF PIXEL 


@ 122,4 TO 150, 121 LABEL STR0012 OF oDlgMF  PIXEL // Leitura por: Reducao / COO (MFD) 

@ 132,10  SAY STR0010 SIZE 48, 7 OF oDlgMF PIXEL  // Inicial:
@ 132,70  SAY STR0011 SIZE 48, 7 OF oDlgMF PIXEL  // Final:

@ 132, 30 MSGET oReducIni Var cReducIni PICTURE '@E 9999' WHEN empty(dDataIni).AND.empty(dDataFim)  VALID !Empty(cReducIni) .AND. Val(cReducIni)>0 SIZE 30, 8 OF oDlgMF PIXEL
@ 132, 85 MSGET oReducFim Var cReducFim PICTURE '@E 9999' WHEN empty(dDataIni).AND.empty(dDataFim)  VALID !Empty(cReducFim) .AND. Val(cReducFim)>0 SIZE 30, 8 OF oDlgMF PIXEL

@ 153,4 TO 185,121 LABEL STR0013 OF oDlgMF  PIXEL //'Saida da Leitura'
@ 160,10 RADIO oCheck1 VAR nCheck 3D SIZE 60,10 PROMPT STR0014, STR0015 OF oDlgMF PIXEL //'Impressora'/'Disco'

STFMessage("STWMemryFisc2", "YESNO", STR0016)//"Impressora OK?"
        

DEFINE SBUTTON FROM 190, 65 TYPE 1;		// OK
ACTION (nOpca := 1,IF(STFShowMessage("STWMemryFisc2"),oDlgMF:End(),nOpca:=0)) ENABLE OF oDlgMF  // "Impressora Ok?", "Atençäo" 
DEFINE SBUTTON FROM 190, 94 TYPE 2;
ACTION ( oDlgMF:End(), lCont := .F. ) ENABLE OF oDlgMF


ACTIVATE MSDIALOG oDlgMF CENTERED
