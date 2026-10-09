#include "Protheus.ch"
#include "FILEIO.CH"      
#INCLUDE "rwmake.ch"
#INCLUDE "FINA317.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNIREL999 º Autor ³ Fabrica            º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de demostracao de mutuo entre empresas.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

User Function CNIR317()
     
Local cPerg := "CNIR317"
Local aHelpPor 	:= {}
Local aHelpEng 	:= {}
Local aHelpSpa 	:= {}
Local aRegs		:= {}

Aadd( aHelpPor, STR0082 )   ////"Informe a Numero da Compensação que"
Aadd( aHelpPor, STR0083 )	////"deseja imprimir"
Aadd( aHelpEng, "" )
Aadd( aHelpSpa, "" ) 
aAdd(aRegs,{cPerg,'01',STR0084,STR0084,STR0084,'mv_ch1','C' ,06  	,0      ,0    ,'G' ,  ,'mv_par01', "" ,""	  ,""  ,""   ,""    ,""     ,""    	 ,"" 	  ,""	  ,""    ,""      ,""   	,""      ,""	 ,""	,""		 ,""  		,""  	,""	 	,""		 ,""	 ,""  	   ,""		 ,""	,''	,"","",aHelpPor,aHelpEng,aHelpSPA	 })     /////'Numero Compensação ?'

ValidPerg(aRegs,cPerg,.F.)

If Pergunte(cPerg,.T.)
	u_CNIRL317(MV_PAR01)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNIREL999 º Autor ³ Fabrica            º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de demostracao de mutuo entre empresas.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

User Function CNIRL317  (cComp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1        := STR0085				/////"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0086				/////"de acordo com os parametros informados pelo usuario."
Local cDesc3        := STR0087				/////"Demonstrativo de Mutuo entre Empresas"
Local cPict         := ""
Local titulo       	:= STR0087				/////"Demonstrativo de Mutuo entre Empresas"
Local nLin         	:= 80
Local Cabec1 		:= STR0089 + cComp		/////"Demonstrativo de Mutuo entre Empresas - DME - N."
Local Cabec2 		:= STR0090				/////"Ordem                Provisão    Vencimento  Historico                                      Valor Ordem"
Local aOrd 			:= {}
Local cQuery		:= ""

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "CNIREL317" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, STR0091, 2, 2, 1, "", 1}    ////"Administracao"
Private nLastKey    := 0
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "CNIREL317" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString 	:= "TMPREL"



cQuery := "SELECT SE1.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE1' AS ALIAS, "
cQuery += "E1_OK AS OK, "
cQuery += "E1_FILIAL AS FILIAL, "
cQuery += "E1_PREFIXO AS PREFIXO, "
cQuery += "E1_NUM AS NUM, "
cQuery += "E1_PARCELA AS PARCELA, "
cQuery += "E1_TIPO AS TIPO, "
cQuery += "E1_EMISSAO AS EMISSAO, "
cQuery += "E1_VENCREA AS VENCTO, "
cQuery += "E1_HIST AS HISTOR, "
cQuery += "E1_VALLIQ AS VALOR "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE E1_IDENTEE = '"+cComp+"' AND D_E_L_E_T_ = ' ' "
cQuery += "UNION "
cQuery += "SELECT SE2.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE2' AS ALIAS, "
cQuery += "E2_OK AS OK, "
cQuery += "E2_FILIAL AS FILIAL, "
cQuery += "E2_PREFIXO AS PREFIXO, "
cQuery += "E2_NUM AS NUM, "
cQuery += "E2_PARCELA AS PARCELA, "
cQuery += "E2_TIPO AS TIPO, "
cQuery += "E2_EMISSAO AS EMISSAO, "
cQuery += "E2_VENCREA AS VENCTO, "
cQuery += "E2_HIST AS HISTOR, "
cQuery += "E2_VALLIQ AS VALOR "
cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
cQuery += "WHERE E2_IDENTEE = '"+cComp+"' AND D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY FILIAL, ALIAS, NUM "

cQuery := ChangeQuery( cQuery ) 
dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPREL", .F., .T. ) 
TMPREL->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	dbSelectArea("TMPREL")
	TMPREL->(DbCloseArea())

	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbSelectArea("TMPREL")
	TMPREL->(DbCloseArea())

	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

dbSelectArea("TMPREL")
TMPREL->(DbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nVlrTotal	:= 0
Local nVlrSub	:= 0
Local nVlrDif	:= 0
Local lVazio	:= .T.
         
dbSelectArea("TMPREL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())

dbGoTop()

cFilAnt 	:= TMPREL->FILIAL
cAliasAnt 	:= TMPREL->ALIAS
lPrimeiro	:= .T.

While !EOF()
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Verifica o cancelamento pelo usuario...                             ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If lAbortPrint
    	@nLin,00 PSAY STR0092				//////"*** CANCELADO PELO OPERADOR ***"
    	Exit
   	Endif
	lVazio	:= .F.
	If TMPREL->FILIAL <> cFilAnt
   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('-',130)
   		nLin := nLin + 1
   		@ nLin,00 PSAY STR0096+If(cAliasAnt="SE1",STR0093,STR0094)     /////// "Total de "         "Recebimento:"      "Pagamento:"
   		@ nLin,110 PSAY nVlrSub  Picture "@E 999,999,999.99"
   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('=',130)
   		nLin := nLin + 2

		nVlrSub		:= 0
		
   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('-',130)
   		nLin := nLin + 1
   		@ nLin,00 PSAY STR0095							////////"Resultado (Recebimento - Pagamento) "
   		@ nLin,110 PSAY nVlrDif  Picture "@E 999,999,999.99"
   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('=',130)
   		nLin := nLin + 2
		
		nVlrDif		:= 0

		lPrimeiro	:= .T.
		cAliasAnt 	:= TMPREL->ALIAS
	    cFilAnt		:= TMPREL->FILIAL       
	    nLin := 80 //força salto de linha
	    
	EndIf
	
	IF TMPREL->ALIAS <> cAliasAnt

   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('-',130)
   		nLin := nLin + 1
   		@ nLin,00 PSAY STR0096+If(cAliasAnt="SE1",STR0093,STR0094)     /////// "Total de "         "Recebimento:"      "Pagamento:"
   		@ nLin,110 PSAY nVlrSub  Picture "@E 999,999,999.99"
   		nLin := nLin + 1
		@ nLin,00 PSay Replicate('=',130)
   		nLin := nLin + 2

		nVlrSub		:= 0
		
		lPrimeiro	:= .T.
		cAliasAnt 	:= TMPREL->ALIAS
	
	EndIf
	
	dbSelectArea(cAliasAnt)
	dbGoTo(TMPREL->CRECNO)
	
	If lPrimeiro                             
		      
		lPrimeiro := .F.	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio. . .                            ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	      Cabec(Titulo,Cabec1+" - "+TMPREL->FILIAL,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 9
	   Endif
	
		If cAliasAnt == "SE1"
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
			cNome := STR0088+SA1->A1_NOME      ////"Cliente - "
		Else                         

			SA2->(dbSetOrder(1))

			SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
			cNome := STR0097+SA2->A2_NOME        ////"Fornecedor - "
		EndIf		
	   	@ nLin,00 PSAY STR0098+cNome                 /////"Entidade:      "
	   	nLin++
	   	nLin++
		If cAliasAnt == "SE1"
		   	@ nLin,00 PSAY STR0099			/////"Recebimentos:      "
		Else
		   	@ nLin,00 PSAY STR0100			/////"Pagamentos:      "
		EndIf				
	   	nLin++	
	EndIf
		   	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Impressao do cabecalho do relatorio. . .                            ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1+" - "+TMPREL->FILIAL,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   	Endif

   	@ nLin,00 	PSAY TMPREL->(PREFIXO+NUM+PARCELA+TIPO)
   	@ nLin,21 	PSAY DTOC(STOD(TMPREL->EMISSAO))
   	@ nLin,33 	PSAY DTOC(STOD(TMPREL->VENCTO))
   	@ nLin,45 	PSAY TMPREL->HISTOR
   	@ nLin,110 	PSAY TMPREL->VALOR  Picture "@E 999,999,999.99"

   	nLin := nLin + 1
	nVlrSub		:= nVlrSub		+ TMPREL->VALOR
	nVlrTotal	:= nVlrTotal	+ TMPREL->VALOR
	If cAliasAnt == "SE1"
		nVlrDif += TMPREL->VALOR
	Else
		nVlrDif -= TMPREL->VALOR
	EndIf		
         
   	dbSelectArea("TMPREL")
   	dbSkip()

EndDo

If !lVazio
	nLin := nLin + 1
	@ nLin,00 PSay Replicate('-',130)
	nLin := nLin + 1
	@ nLin,00 PSAY STR0096+If(cAliasAnt="SE1",STR0099,STR0094)           /////"Total de "    "Recebimento:" "Pagamento:" 
	@ nLin,110 PSAY nVlrSub  Picture "@E 999,999,999.99"
	nLin := nLin + 1
	@ nLin,00 PSay Replicate('=',130)
	nLin := nLin + 2

	nVlrSub		:= 0

	nLin := nLin + 1
	@ nLin,00 PSay Replicate('-',130)
	nLin := nLin + 1
	@ nLin,00 PSAY STR0095			/////"Resultado (Recebimento - Pagamento) "
	@ nLin,110 PSAY nVlrDif  Picture "@E 999,999,999.99"
	nLin := nLin + 1
	@ nLin,00 PSay Replicate('=',130)
	nLin := nLin + 2

	nVlrDif		:= 0

Else

	@ nLin,00 PSAY STR0101    ////"Não existem dados a imprimir"
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

