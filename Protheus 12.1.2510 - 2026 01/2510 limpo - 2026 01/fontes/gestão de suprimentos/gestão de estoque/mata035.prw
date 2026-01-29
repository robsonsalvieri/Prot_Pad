#INCLUDE "MATA035.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#DEFINE nTamRot 50
#DEFINE nTamMod 50
PUBLISH MODEL REST NAME MATA035
Static cXX4Model

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATA035  ³ Autor ³  Eduardo Motta        ³ Data ³ 20/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Grupo                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡ao ³ PLANO DE MELHORIA CONTINUA        ³Programa    MATA035.PRW ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data       	|BOPS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³           	|                 ³±±
±±³      02  ³                          ³           	|                 ³±±
±±³      03  ³                          ³           	|                 ³±±
±±³      04  ³ Ricardo Berti            ³ 20/04/2006	| 096844          ³±±
±±³      05  ³                          ³           	|                 ³±±
±±³      06  ³                          ³           	|                 ³±±
±±³      07  ³ Ricardo Berti            ³ 20/04/2006	| 096844          ³±±
±±³      08  ³                          ³           	|                 ³±±
±±³      09  ³                          ³           	|                 ³±±
±±³      10  ³                          ³           	|                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MATA035(aRotAuto,nOpcAuto)

	Default nOpcAuto := 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar no arquivo SBM o conteudo da tabela 03 do SX5         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	A508Grupo()
	If	aRotAuto <> NIL
		Private aRotina := MenuDef()
		FWMVCRotAuto(ModelDef(),"SBM",nOpcAuto,{{"MATA035_SBM",aRotAuto}})	
	Else
		oMBrowse:= FWMBrowse():New()
		oMBrowse:SetAlias("SBM")
		oMBrowse:SetDescription(STR0020 )  //"Grupo de Produto"
		oMBrowse:DisableDetails()
		oMBrowse:SetAttach( .T. )//Habilita as visões do Browse
		//Se não for SIGACRM inibe a exibição do gráfico
		If nModulo <> 73
			oMBrowse:SetOpenChart( .F. )
		EndIf
		oMBrowse:SetTotalDefault('BM_GRUPO','COUNT',STR0018)//'Total de Registros'
		ACTIVATE FWMBROWSE oMBrowse
	EndIf
	
Return .T.     
                               
Static Function BrowseDef()
Local oBrowse as object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SBM")
	oBrowse:SetDescription(STR0001)  //"Grupo"
	oBrowse:SetOnlyFields( { 'BM_FILIAL', 'BM_GRUPO', 'BM_DESC', 'BM_CODGRT', 'BM_DESGRT','BM_CLASGRU', 'BM_CONC', 'BM_CORP', 'BM_EVENTO', 'BM_LAZER'  } ) // Define campos q aparecerao no browser 

Return oBrowse 
                               
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A035Visual³ Autor ³ Nereu Humberto Junior ³ Data ³ 19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupos de Produtos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A035Visual(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION A035Visual(cAlias,nReg,nOpc)

LOCAL nOpcA    := 0      
LOCAL aButtons := {}
LOCAL aUsrBut  := {}

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA := AxVisual(cAlias,nReg,nOpc,,,,,aButtons )

dbSelectArea(cAlias)

Return Nil
      

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A035Inclui³ Autor ³ Nereu Humberto Junior ³ Data ³ 19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A035Inclui(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A035Inclui(cAlias,nReg,nOpc)

LOCAL nOpcA    := 0      
LOCAL aButtons := {}
LOCAL aUsrBut  := {}
LOCAL lPIMSINT := (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integração Protheus x PIMS Graos 
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| .T.}, {|| .T.}, {||A035Int( 2, nOpc, aIntSBM )}}	// Bloco de código executado após a transação da inclusão do cliente
Local lMa035Inc := ExistBlock( "MA035INC" )

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

	A035Int( 1, nOpc, aIntSBM )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	nOpcA := AxInclui(cAlias,nReg,nOpc, , , ,"Ma035Valid(nOpc)", , ,aButtons, aParam )
	If nOpcA == 1
	If lMa035Inc
			Execblock( "MA035INC", .F., .F.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao PIMS GRAOS        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPIMSINT
			PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
		EndIf 
		
		//³ Integracao Shopify - Adicionado integração com Shopify SHPXFUN.PRW
		If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYCMAT035")
			SPYCMAT035()   
		EndIf        	             			
	EndIf

dbSelectArea(cAlias)

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A035Altera³ Autor ³ Nereu Humberto Junior ³ Data ³ 19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A035Altera(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A035Altera(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
LOCAL nOpcA:=0 
LOCAL aButtons := {}
LOCAL aUsrBut  := {}
LOCAL lPIMSINT := (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integração Protheus x PIMS Graos 
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| .T.}, {|| .T.}, {||A035Int( 2, nOpc, aIntSBM )}}	// Bloco de código executado após a transação da inclusão do cliente
Local lMa035Alt := ExistBlock( "MA035ALT" )

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

A035Int( 1, nOpc, aIntSBM )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
nOpcA := AxAltera( cAlias, nReg, nOpc, , , , , "Ma035Valid(nOpc)", , , aButtons, aParam )
If nOpcA == 1
	If lMa035Alt
		Execblock( "MA035ALT", .F., .F. )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao PIMS GRAOS        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPIMSINT
		PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
	EndIf
	//³ Integracao Shopify - Adicionado integração com Shopify SHPXFUN.PRW
	If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYCMAT035")
		SPYCMAT035()
	EndIf

EndIf

RestArea( aArea )
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A035Deleta³ Autor ³ Nereu Humberto Junior ³ Data ³ 19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A035Deleta(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A035Deleta(cAlias,nReg,nOpc)

Local nOpcA		:= 0
Local aButtons  := {}
Local aUsrBut   := {}  
Local aArea		:= GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local lRet		:= .T.
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| MATA035Ex()}, {|| .T.}, {|| .T.}}  
Local cAliasAAI	:= ""
Local cQuery	:= ""
Local cMsg	    := ""
Local cAliasACP	:= ""
Local cAliasACR := ""
Local cAliasACX := ""
Local cAliasAI2	:= ""
Local cAliasDA1	:= ""

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 

(cAlias)->(dbGoto(nReg))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Grupo de Produto está vinculado a um Produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
SB1->(dbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
If SB1->(MsSeek(xFilial("SB1")+(cAlias)->BM_GRUPO))
	Help(" ",1,"A035EXGRPR") 
	lRet := .F.
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Grupo está vinculado a um Responsável		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
If lRet
	dbSelectArea("AGX")
	AGX->(dbSetOrder(2)) //AGX_FILIAL+AGX_GRUPO+AGX_CODRSP
	If AGX->(dbSeek(xFilial("AGX")+(cAlias)->BM_GRUPO))
		Help(" ",1,"NODELETA",,STR0014,2,0)	//"Este grupo esta sendo utilizado pela rotina de Responsáveis X Grupo de Produtos."
		lRet := .F.
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Grupo de Produto está vinculado a um Solicitante ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If lRet .And. MATA035Sol(cAlias)
   lRet := .F.
EndIf

If lRet .And. !SoftLock(cAlias)
	lRet := .F.
Endif
  
If lRet
   cAliasAAI := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "AAI" )
   cQuery += "  WHERE AAI_FILIAL='" + xFilial( "AAI" ) + "'"
   cQuery += "    AND AAI_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAAI,.F.,.T. )

   If (cAliasAAI)->TOT_GRP > 0      
      Help(" ",1,"HELP", , STR0015, 3, 1 )  //"EEste grupo esta sendo utilizado por uma tabela (FAQ) e nao podera ser excluida."
      lRet := .F.
   Endif
   (cAliasAAI)->(DbCloseArea())   
EndIf   

If lRet
   cAliasDA1 := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "DA1" )
   cQuery += "  WHERE DA1_FILIAL = '" + xFilial( "DA1" ) + "'"
   cQuery += "    AND DA1_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.F.,.T. )

   If (cAliasDA1)->TOT_GRP > 0      
      Help(" ",1,"NODELETA",,STR0019,2,0)	//"Este grupo esta sendo utilizado pela rotina de Tabela de Preço."
      lRet := .F.
   Endif
   (cAliasDA1)->(DbCloseArea())   
EndIf   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Grupo de Produto está vinculado a uma regra de negocio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If lRet

   cAliasACP := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACP" )
   cQuery += "  WHERE ACP_FILIAL='" + xFilial( "ACP" ) + "'"
   cQuery += "    AND ACP_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACP,.F.,.T. )

	If (cAliasACP)->TOT_GRP > 0
	      
		SX2->(MsSeek("ACP"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACP)->(DbCloseArea())   


EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Grupo de Produto está vinculado a uma regra de Bonificação ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If lRet

   cAliasACR := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACR" )
   cQuery += "  WHERE ACR_FILIAL='" + xFilial( "ACR" ) + "'"
   cQuery += "    AND ACR_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACR,.F.,.T. )

	If (cAliasACR)->TOT_GRP > 0
	      
		SX2->(MsSeek("ACR"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACR)->(DbCloseArea())   


EndIf 

If lRet

   cAliasACX := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACX" )
   cQuery += "  WHERE ACX_FILIAL='" + xFilial( "ACX" ) + "'"
   cQuery += "    AND ACX_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACX,.F.,.T. )

   If (cAliasACX)->TOT_GRP > 0      
		SX2->(MsSeek("ACX"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACX)->(DbCloseArea())   
EndIf   


If lRet

   cAliasAI2 := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "AI2" )
   cQuery += "  WHERE AI2_FILIAL='" + xFilial( "AI2" ) + "'"
   cQuery += "    AND AI2_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAI2,.F.,.T. )

   If (cAliasAI2)->TOT_GRP > 0      
		SX2->(MsSeek("AI2"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasAI2)->(DbCloseArea())   
EndIf   


RestArea(aArea)    
RestArea(aAreaSB1)    
    
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MATA035EX ³ Autor ³ Eduardo Motta         ³ Data ³ 28/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se pode ser feita a exclusao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA035Ex()

Local aArquivos	:= {}
Local lRet		    := .T.
Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utilizado em produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(4)
If dbSeek(xFilial()+SBM->BM_GRUPO)
	Aviso(STR0002,STR0003,{STR0004},2) //"Atencao!"###"Este grupo de produto esta sendo utilizado em algum produto e nao podera ser excluido."###"Voltar"
	lRet := .F.
ElseIf GetMV('MV_VEICULO') == 'S'
   aadd(aArquivos,{"AAB","AAB_GRUPO ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"AAI","AAI_GRUPO ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SAD",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SB1",4           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SB4","B4_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SBI",4           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SC9","C9_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SCT","CT_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD1","D1_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD2","D2_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD3","D3_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE4","VE4_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE6","VE6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE8",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE8",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE9",5           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VEH",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VEK","VEK_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF6","VF6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF7","VF7_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF8","VF8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF9","VF9_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VFC","VFC_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG5","VG5_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG6","VG6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG8","VG8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VO3",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VO8","VO8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VOK","VOK_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VOV",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VS3","VS3_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VSD","VSD_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VV6","VV6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VVT","VVT_GRUITE", SBM->BM_GRUPO,   })
   lRet := FG_DELETA(aArquivos)
EndIf

If lRet
	If (ExistBlock("MT035EXC"))
		lRet := ExecBlock("MT035EXC",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³01/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados			  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()     
	Local aArea   := GetArea()

	Private aRotina := {}

	// ADICIONA MENU
	ADD OPTION aRotina TITLE STR0005  ACTION 'PesqBrw' 			OPERATION OP_PESQUISAR	ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0006  ACTION 'VIEWDEF.MATA035'	OPERATION OP_VISUALIZAR	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0007  ACTION 'VIEWDEF.MATA035'	OPERATION OP_INCLUIR	ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0008  ACTION 'VIEWDEF.MATA035'	OPERATION OP_ALTERAR	ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0009  ACTION 'VIEWDEF.MATA035'	OPERATION OP_EXCLUIR	ACCESS 0 // "Excluir"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MTA035MNU")
		ExecBlock("MTA035MNU",.F.,.F.)
	EndIf
	
	If IsInCallStack("MATA035")
		aRotina := CRMXINCROT("SBM",aRotina)
	EndIf

	RestArea(aArea)

Return(aRotina) 
                                                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma035Valid³ Autor ³ Andre Sperandio       ³ Data ³ 14/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Alteracao		                        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma035Valid(nOpc)

Local lRet 	:= .T.
Local lRetPE:= .T.

If lRet .And. ExistBlock('MA035VLD')
	lRet := If(ValType(lRetPE := ExecBlock('MA035VLD',.F.,.F., { nOpc }))=='L', lRetPE, lRet)
EndIf

Return lRet                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MATA035SOL³ Autor ³ Aline Sebrian                      ³ Data ³ 03/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe solicitante vinculado ao grupo de produtos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA035Sol(cAlias)    

Local lRet		 := .F.   
Local cAliasSAI := ""      


Local cQuery    := ""

cAliasSAI := GetNextAlias()
 	
If Select(cAliasSAI) > 0 
	dbSelectArea(cAliasSAI)
	dbCloseArea()
EndIf
    
cQuery    := "SELECT AI_FILIAL, AI_GRUPO "
cQuery    += "FROM "+RetSqlName("SAI")+" SAI "     
cQuery    += "WHERE SAI.AI_FILIAL='"+xFilial("SAI")+"' AND "
cQuery    += " SAI.AI_GRUPO='"+(cAlias)->BM_GRUPO+"' AND "
cQuery    += "SAI.D_E_L_E_T_=' ' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSAI, .T., .T. )      

If (cAliasSAI)->(!Eof())
   	Help(" ",1,"A035EXGRSO") 
	lRet := .T.
EndIf

(cAliasSAI)->(dbCloseArea())

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A035Int³ Autor ³ Vendas CRM               ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Realiza integracao com a criterium ou outra integracao       ³±±
±±³          ³que utiliza o framework do SIGALOJA de integracao.            ³±±
±±³          ³ O parâmetro aIntSB1 normalmente é vazio.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A035Int()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Momento da chamada, sendo:                             ³±±
±±³          ³           1: Antes de qualquer alteração                     ³±±
±±³          ³           2: Depois das alterações                           ³±±
±±³          ³ExpN2: Opção da rotina                                        ³±±
±±³          ³ExpA3: Array contendo o número do registro e adaptador do SBM.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A035Int( nMomento, nOpc, aIntSBM )

	Local lIntegra 		:= SuperGetMv("MV_LJGRINT", .F., .F.)	// Se há integração ou não
	Local aArea			:= GetArea()

	If lIntegra
		If nMomento == 1
			MsgRun( STR0012, STR0011, {|| A035IniInt( nOpc, aIntSBM ) } ) // "Aguarde" "Anotando registros para integração"
		ElseIf nMomento == 2			
			MsgRun( STR0013, STR0011, {|| A035FimInt( nOpc, aIntSBM ) } ) // "Aguarde" "Executando integração"
		EndIf
	EndIf
	
	RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A035IniInt   ³ Autor ³ Vendas CRM         ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Faz o cache dos itens antes de serem excluídos, possibilitan-³±±
±±³          ³do o envio dos mesmos, mesmo após de serem apagados.          ³±±
±±³          ³ O parâmetro aIntSBM normalmente é vazio.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A035IniInt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opção da rotina                                        ³±±
±±³          ³ExpA2: Array contendo o número do registro e adaptador do SBM.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A035IniInt( nOpc, aIntSBM )
	Local oFactory		:= LJCAdapXmlEnvFactory():New()
	Local cChave		:= ""
	
	// Se houver integração e não for inclusão, anota todos os registros para exclusão, caso algum seja excluído
	If nOpc != 3
		aIntSBM :=	{ SBM->(Recno()), oFactory:Create( "SBM" ) }		
		cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
	    aIntSBM[2]:Inserir( "SBM", cChave, "1", "5" )
	    aIntSBM[2]:Gerar()
	EndIf	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A035FimInt   ³ Autor ³ Vendas CRM         ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Envia os itens apagados e todos os outros itens.             ³±±
±±³          ³ O parâmetro aIntSBM normalmente é vazio.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A035FimInt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opção da rotina                                        ³±±
±±³          ³ExpA2: Array contendo o número do registro e adaptador do SBM.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A035FimInt( nOpc, aIntSBM )
	Local oFactory		:= LJCAdapXmlEnvFactory():New( )	// Cria a fabrica de Adaptadores de envio
	Local cChave		:= ""
	
	// Verifica se houve algum registro apagado, e gera a integração desse registro
	If nOpc != 3
		If Len(aIntSBM) > 0
			// Procura pelo registro do cabeçalho
			SBM->(DbGoTo( aIntSBM[1] ) ) 
			
			// Se não encontrar, significa que o cabeçalho foi apagado, então envia somente a exclusão do cabeçalho
			If SBM->( DELETED() )
				aIntSBM[2]:Finalizar()
			EndIf
		EndIf
	EndIf
	
	// Independente de ter registros apagados ou não, gera quando não for exclusão, todos os outros registros
	If nOpc != 5
		aIntSBM := { SBM->( Recno() ), oFactory:Create( "SBM" ) }		
		cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
	    aIntSBM[2]:Inserir( "SBM", cChave, "1", cValToChar( nOpc ) )
	    aIntSBM[2]:Gerar()
		aIntSBM[2]:Finalizar()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do cadastro de grupo de produtos

@author Leandro F. Dourado
@since 05/04/2012
@version P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oStructSBM 	:= Nil
	Local oModel     	:= Nil
	Local auMovStatus 	:= {}
	Local oEvent  		:= Nil

	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructSBM := FWFormStruct(1,"SBM",{||.T.})

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oEvent:= MATA035EvDef():New()
	oModel:= MPFormModel():New("MATA035", /*{| oModel | A035PreVld(oModel, auMovStatus) }*/, /*{| oModel | A035PosVld(oModel, auMovStatus) }*/, /*{| oModel | Mt035Grv(oModel, auMovStatus)}*/ )
	oModel:AddFields("MATA035_SBM", Nil, oStructSBM )
	oModel:GetModel("MATA035_SBM"):SetDescription(STR0010)
	oModel:InstallEvent("MATA035EvDef", /*cOwner*/, oEvent)

	//Integracao Shopify - Adicionado integração com Shopify SHPXFUN.PRW
	If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYIMAT035")
		SPYIMAT035(@oModel)
	EndIf
	
Return(oModel)

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados do cadastro de grupo de produtos

@author Leandro F. Dourado
@since 13/09/2011
@version P12
*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView  		:= Nil
	Local oModel  		:= FWLoadModel("MATA035")
	Local oStructSBM 	:= Nil
	Local aButtons  	:= {}
	Local aUsrBut   	:= {} 
	Local nX			:= 0
	
	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructSBM := FWFormStruct(2,"SBM")
	//-----------------------------------------
	//Monta o modelo da interface do formulário
	//-----------------------------------------
	oView := FWFormView():New()
	oView:SetContinuousForm()
	oView:SetModel(oModel)   
	oView:EnableControlBar(.T.)      
	oView:AddField( "MATA035_SBM" , oStructSBM )
	oView:CreateHorizontalBox( "HEADER" , 100 )
	oView:SetOwnerView( "MATA035_SBM" , "HEADER" )

	If ExistBlock( "MA035BUT" ) 
		If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
			AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
		EndIf 
	EndIf

	//loop para incluir todos os botões na View
	For nX := 1 to Len(aButtons)
		oView:AddUserButton(aButtons[nX][3], aButtons[nX][1],aButtons[nX][2]) 
	Next nX 

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A035ValSeg(oSBMMASTER)

VALIDA SE FOI SELECIONADO ALGUM SEGMENTO PARA ESTE GRUPO  DE PRODUTO

@sample 	A035ValSeg()
@return  	aRotina                       
@author  	Fanny Mieko Suzuki
@since   	18/06/2015
@version  	P12
@return 	lRet
/*/
//------------------------------------------------------------------------------------------

Static Function A035ValSeg(oSBMMASTER)

Local nOperation	:= 0
Local lLazer		:= ""
Local lCorpor		:= ""
Local lEvento		:= ""
Local cValid 		:= ""
Local lRet 		:= .T.

// VERIFICAR QUAL O TIPO DE OPERAÇÃO ESTA SENDO REALIZADA
nOperation 	:= oSBMMASTER:GetOperation()

lCorpor 	:= FwFldGet("BM_CORP")
lEvento 	:= FwFldGet("BM_EVENTO")
lLazer 	:= FwFldGet("BM_LAZER")

// VERIFICA SE É INCLUSÃO OU ALTERAÇÃO?
If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 
	// VALIDA SE NENHUM SEGMENTO FOI SELECIONADO PARA ESTA ENTIDADE
	If lCorpor == .F. .AND. lEvento == .F. .AND. lLazer == .F.
		Help( "A035VALSEG", 1, STR0022, , STR0023, 1, 0) // "Atenção" - "É necessário selecionar pelo menos um segmento para este Grupo de Produto."
		lRet:= .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} A035PreVld
Realiza pre validacoes do modelo de dados

@author Leandro F. Dourado
@since 09/04/2012
@version P12
*/
//-------------------------------------------------------------------

Static Function A035PreVld(oModel, auMovStatus) 
Local aArea			:= GetArea()
Local aAreaSB1  		:= SB1->(GetArea())
Local aIntSBM			:= {}
Local nOpc 			:= oModel:GetOperation()

If nOpc == 1
	nOpc := 2
EndIf

auMovStatus := {}

A035Int( 1, nOpc, aIntSBM )
    
RestArea(aAreaSB1)
RestArea(aArea) 

Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} A035PosVld
Realiza pos validacoes do Model

@author Leandro F. Dourado
@since 09/04/2012
@version P11.6
*/
//-------------------------------------------------------------------

Static Function A035PosVld(oModel,auMovStatus)
Local nOpc 			:= oModel:GetOperation()
Local lRet 			:= .T.
Local lIntSFC 		:= ExisteSFC("SBM") .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o SFC
Local lIntDPR 		:= IntegraDPR() .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o DPR
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integração Protheus x uMov.me
Local oMdl
Local cDescricao 	:= ""
Local lMa035Del 	:= ExistBlock( "MA035DEL" )



If	nOpc == 3 .Or. nOpc == 4
	lRet := Ma035Valid(nOpc)
ElseIf nOpc == 5
	lRet := A035Deleta("SBM", SBM->(Recno()), nOpc)
EndIf

If lRet
	A035Int( 2, 2, {} )
	If lMa035Del
		Execblock( "MA035DEL", .F., .F. )
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina para integracao com DPR(Desenvolvedor de Produtos) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And.(lIntDPR .Or. lIntSFC)
	lRet := A035IntDPR(nOpc)	
EndIf

If	luMovme .And. (nOpc == 3 .Or. nOpc == 4)
	oMdl := oModel:GetModel('MATA035_SBM')
	cDescricao := oMdl:GetValue('BM_DESC')
	If cDescricao <> SBM->BM_DESC
		aAdd( auMovStatus, oMdl:GetValue('BM_GRUPO') )
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} Mt035Grv
Funcao que realiza a gravacao dos dados

@author Leandro F. Dourado
@since 09/04/2012
@version P11.6
*/
//-------------------------------------------------------------------

Static Function Mt035Grv(oModel,auMovStatus)
Local nOpc 		:= oModel:GetOperation()
Local lRet	
Local cNameBlock  := Iif(nOpc == 3,"MA035INC","MA035ALT")
Local cAlias		:= "SBM"
Local aIntSBM		:= {}
LOCAL lPIMSINT 	:= (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integração Protheus x PIMS Graos
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integração Protheus x uMov.me  
Local cID			:= "MATA035_SBM"
Local nX			:= 1
Local lExistBlk		:= ExistBlock( cNameBlock )

If nOpc == 3 .OR. nOpc == 4
	lRet := FWFormCommit(oModel,,{|oModel,cID,cAlias|A035Int( 2, nOpc, aIntSBM )})
ElseIf nOpc == 5
	lRet := FWFormCommit(oModel)
EndIf

If lRet
	If nOpc == 3 .OR. nOpc == 4
		If lExistBlk
			Execblock( cNameBlock, .F., .F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao PIMS GRAOS        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPIMSINT
			PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
		EndIf
	
		If luMovme .And. Len( auMovStatus ) > 0
			For nX := 1 to Len( auMovStatus )
				If SBM->(MsSeek( xFilial("SBM") + auMovStatus[nX]))
					RecLock( "SBM", .F.)	
					SBM->BM_DTUMOV := CTOD("")
					SBM->BM_HRUMOV := ""
					SBM->(MsUnlock())
				EndIf
			Next 
		EndIf
		 
	EndIf
EndIf

Return lRet     

//-------------------------------------------------------------------
/*{Protheus.doc} A035IntDPR
Atualiza tabelas do DPR conforme modelagem dos dados(MVC)

@author Leonardo Quintania
@since 13/11/2012
@version 11.80
*/
//-------------------------------------------------------------------
Function A035IntDPR(nOpc,cError,cNome,oModel)
	Local aArea   := GetArea()	// Salva area atual para posterior restauracao
	Local lRet    := .T.		// Conteudo de retorno
	Local aCampos := {}			// Array dos campos a serem atualizados pelo modelo
	Local aAux    := {}			// Array auxiliar com o conteudo dos campos
	Local nX	  	:= 0			// Indexadora de laco For/Next
	Local oModelAnt := FwModelActive() //Modelo ativo atual

	Default oModel := FWLoadModel("SFCA021")

	If nOpc == 3
		aAdd(aCampos,{"CY7_CDGE",M->BM_GRUPO})
	EndIf

	If nOpc # 5
		aAdd(aCampos,{"CY7_DSGE",M->BM_DESC})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Instancia modelo de dados(Model) do Grupo de Estoque - DPR ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oModel := FWLoadModel("SFCA021")
	oModel:SetOperation(nOpc)

	If nOpc # 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando se tratar de alteracao ou exclusao primeiramente o registro devera ser posicionado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CY7->(dbSetOrder(1))
		CY7->(dbSeek(xFilial("CY7")+SBM->BM_GRUPO))
	EndIf
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ativa o modelo de dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lRet := oModel:Activate())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a estrutura de dados do Model ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAux := oModel:GetModel("CY7MASTER"):GetStruct():GetFields()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Loop para validacao e atribuicao de dados dos campos do Model ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aCampos)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida os campos existentes na estrutura do Model ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCampos[nX,1])}) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atribui os valores aos campos do Model caso passem pela validacao do formulario ³
				//³referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(oModel:SetValue("CY7MASTER",aCampos[nX,1],aCampos[nX,2]))
					lRet := .F.
					Exit       
				EndIf
			EndIf
		Next nX
	Endif

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida os dados e integridade conforme dicionario do Model ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lRet := oModel:VldData())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva gravacao dos dados na tabela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := oModel:CommitData()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera log de erro caso nao tenha passado pela validacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet
		A010SFCErr(oModel,@cError,NIL,cNome,SBM->BM_GRUPO)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa o Model ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:DeActivate()

	If ValType( oModelAnt ) == "O"
        FwModelActive( oModelAnt )
    EndIf
	RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Function  ³ IntegDef º Autor ³ Alex Egydio          º Data ³  03/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Funcao de tratamento para o recebimento/envio de mensagem    º±±
±±º           ³ unica do Grupo de Produtos.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ MATA035                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local aRet 		:= {}
Local cRotina	:= Padr( 'MATA035'	 , nTamRot )
Local cFamily	:= Padr( 'FAMILY' 	 , nTamMod )
Local cStockGrp	:= Padr( 'STOCKGROUP', nTamMod )

Default xEnt 		:= ""
Default nTypeTrans 	:= ""
Default cTypeMessage:= ""
Default cVersion 	:= ""
Default cTransac 	:= ""
Default lEAIObj 	:= .F.

//Function FWXX4Seek( cSeekKey, nOrder, cFilExec, cRotina, cModel ) 
// Armazena busca na variavel Static para nao posicionar XX4 a cada chamada da IntegDef
// caso contrario se tiver mais de um cadastro de adapter para a mesma rotina o programa fica em looping
If cXX4Model == Nil
	If FWXX4Seek( cRotina + cFamily, /*nOrder*/, /*cFilExec*/, cRotina, cFamily )
		cXX4Model := "FAMILY"
	ElseIf FwXX4Seek( cRotina + cStockGrp, /*nOrder*/, /*cFilExec*/, cRotina, cStockGrp )
		cXX4Model := "STOCKGROUP"
	Else
		cXX4Model := " " 
	EndIf
EndIf

// Ao cadastrar um dos três adapters a rotina CFGA020 precisará requisitar o
// WhoIs para saber quais as versões disponíveis. Como no cadastro nenhum
// dos três adapters estará na tabela XX4 as versões disponíveis terão que
// ser cadastradas aqui dentro. Ao criar uma nova versão dos adapters o array
// de versões terá que ser atualizado aqui também.

Do Case
	Case "FAMILY" $ cXX4Model
		aRet := MATI035(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Case "STOCKGROUP" $ cXX4Model
		aRet := MATI035A(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Case cTypeMessage == EAI_MESSAGE_WHOIS
		//WhoIs
		//MATI035  v1.000, 2.000, 2.001, 2.002
		//MATI035a v1.000
		aRet := {.T., '1.000|2.000|2.001|2.002'}
EndCase

Return aRet
