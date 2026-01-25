#include "protheus.ch"
#include "GEMA160.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA160   บAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento da Cessao de direito                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMA160()
Local aArea   := GetArea()
                                                                                                          
Private cCadastro := OemToAnsi(STR0001) //"Cessใo de Direito"
Private aRotina   := MenuDef()
Private aCores := {{'LIT->LIT_STATUS == "1"','ENABLE'    },; // "Em aberto"
                   {'LIT->LIT_STATUS == "2"','DISABLE'   },; // "Encerrado"
                   {'LIT->LIT_STATUS == "3"','BR_CINZA'  },; // "Cancelado"
                   {'LIT->LIT_STATUS == "4"','BR_AMARELO'} } // "Cessao de direito"

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

/*
Insere o tipo de motivo de cessao de direito
*/
GEMMotivo()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEndereca para a funcao MBrowse                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("LIT")
dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
MsSeek(xFilial("LIT"))
mBrowse(06,01,22,75,"LIT",,,,,, aCores)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a Integridade da Rotina                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("LIT")
dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
dbClearFilter()

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GMA160DlgบAutor  ณReynaldo Miyashita  บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao de cessao de direito                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA160Dlg(cAlias,nReg,nOpc)
Local oDlg
Local nOpcA       := 0
Local cNewCliente := ""
Local cNewLoja    := ""
Local cNewNome    := ""
Local lContinua   := .T.

Static oGetNewCli
Static oGetNewLJ
Static oGetNewNom 

DEFAULT cAlias := "LIT"

	dbSelectArea(cAlias)
	If !((cAlias)->LIT_STATUS == "1")
		MsgStop(STR0002)   //"Este contrato nใo estแ ativo. Verifique."
		lContinua := .F.
	EndIf
	
If lContinua

	cNewCliente := Space(TamSX3("LIT_CLIENT")[1])
	cNewLoja    := Space(TamSX3("LIT_LOJA")[1])
	cNewNome    := Space(TamSX3("LIT_NOMCLI")[1])

	DEFINE MSDIALOG oDlg FROM	15,6 TO 281,597 TITLE OemToAnsi(STR0001) PIXEL   //Cessใo de Direito

	@ 20, 13 SAY	OemToAnsi(STR0003)	SIZE  21,  7	 OF oDlg PIXEL   //cONTRATO
	@ 17, 42 MSGET  (cAlias)->LIT_NCONTR	SIZE 149, 10	 OF oDlg PIXEL HASBUTTON WHEN .F.

	@ 015, 200 BUTTON OemToAnsi(STR0004) ;   //"Ver Detalhes"
               SIZE 40, 15 PIXEL ;
               ACTION  {||t_GMA160Contr( cAlias ,nReg ,2 ) } ;
               OF oDlg

	@ 40,  1 TO  70, 294 LABEL OemToAnsi(STR0005) OF oDlg PIXEL        //"Contrato Atual"

	@ 50, 14 SAY   OemToAnsi(STR0006)	SIZE  21,  7	 OF oDlg PIXEL  //"Cliente"
	@ 47, 42 MSGET (cAlias)->LIT_CLIENT	SIZE  54, 10	 OF oDlg PIXEL HASBUTTON WHEN .F.
	@ 47,100 MSGET (cAlias)->LIT_LOJA	SIZE  30, 10	 OF oDlg PIXEL WHEN .F.
	@ 47,140 MSGET (cAlias)->LIT_NOMCLI	SIZE 149, 10	 OF oDlg PIXEL READONLY

	@ 74,  1 TO 106, 294 LABEL OemToAnsi(STR0007) OF oDlg PIXEL   //"Transferir para"
	
	@ 85, 14 SAY   OemToAnsi(STR0006)	SIZE  25,  7	 OF oDlg PIXEL
	@ 83, 42 MSGET oGetNewCli VAR cNewCliente	F3 "SA1"	SIZE  54, 10	 OF oDlg PIXEL HASBUTTON  Valid VldCliente( cAlias ,@cNewCliente ,@cNewLoja ,@cNewNome )
	@ 83,100 MSGET oGetNewLJ  VAR cNewLoja    				SIZE  30, 10	 OF oDlg PIXEL Valid VldCliente( cAlias ,@cNewCliente ,@cNewLoja ,@cNewNome )
	@ 83,140 MSGET oGetNewNom VAR cNewNome    				SIZE 149, 10	 OF oDlg PIXEL READONLY

	DEFINE SBUTTON FROM 112, 235 ;
		TYPE 1 ;
		ACTION iIf( ValidOk( cAlias ,cNewCliente ,cNewLoja ,@cNewNome ) ,(nOpcA := 1 ,oDlg:End()) ,.T. ) ;
		ENABLE OF oDlg
	DEFINE SBUTTON FROM 112, 265;
		TYPE 2;
		ACTION (nOpcA := 0 ,oDlg:End());
		ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcA == 1
		//
		// abre a janela de contratos.
		//                           
		If Existblock("GEMVLDCCD")
			lContinua := Execblock("GEMVLDCCD",.F.,.F.,{LIT->LIT_NCONTR}) 
		else
			lContinua := .T.
		EndIf         
		
		If lContinua
			t_GMA160Contr( cAlias ,nReg ,nOpc ,cNewCliente ,cNewLoja ,cNewNome )
		endIf
	
	EndIf
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldClienteบAutor  ณReynaldo Miyashita  บ Data ณ             บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do cliente                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCliente( cAlias ,cCliCod ,cCliLj ,cCliNome )
Local lOk      := .F.
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())

	If Empty(cCliLj)
		lOk := Empty(cCliCod) .Or. ExistCpo("SA1",cCliCod)
	Else
		lOk := Empty(cCliLj) .Or. ExistCpo("SA1",cCliCod+cCliLj)
	EndIf
	
	If lOk
		lOk := .F.
		If ((cAlias)->LIT_CLIENT <> cCliCod) .or. ((cAlias)->LIT_CLIENT == cCliCod .and. (cAlias)->LIT_LOJA <> cCliLj )
			dbSelectArea("SA1")
			dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			If dbSeek(xFilial("SA1")+cCliCod+cCliLj)
				cCliNome   := SA1->A1_NOME
				oGetNewNom:refresh()
		
				lOk := .T.
			EndIf
		Else 
			Help(" ",1,"CLINAOINF",,STR0008,1)  //"C๓digo do cliente e/ou Loja nใo pode ser igual."
		EndIf
    EndIf
    
	RestArea(aAreaSA1)
	RestArea(aArea)

Return( lOk )

Static Function ValidOk( cAlias ,cCliCod ,cCliLj ,cCliNome )
Local lOk := .F. 

	lOk := VldCliente( cAlias ,cCliCod ,cCliLj ,cCliNome )

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณGMA160Dlg ณ Autor ณ Reynaldo Miyashita    ณ Data ณ 14.02.2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRotina de Distrato do contrato                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณT_GMA160Dlg()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1: Alias do Arquivo                                       ณฑฑ
ฑฑณ          ณExpN2: Numero do Registro                                     ณฑฑ
ฑฑณ          ณExpN3: Opcao do aRotina                                       ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA160Contr( cAlias ,nReg ,nOpc ,cCliente ,cLoja ,cNome )

Local lA160Inclui 	:= .F.
Local lA160Visual 	:= .F.
Local lA160Cancel 	:= .F.
Local lContinua  		:= .T.
Local lOk         	:= .F.
Local lExiste 			:= .T.
Local nSaveSX8    	:= GetSX8Len()

Local aArea    			:= GetArea()
Local oDlg 
Local oEnch
Local oFolder1
Local oFolder2
Local oGD1      		:= array(2)
Local oGD2      		:= array(2)
Local aObjects 		:= {}
Local aSize    			:= {}
Local aInfo    			:= {}
Local aPosObj  		:= {}
Local aButtons 		:= {}
Local aLITFields  	:= {}

Local aCampos  		:= {}
Local aTitles1 			:= {}
Local aTitles2 			:= {}
Local nCount   		:= 0
Local nGDOpc   		:= 0

Local aHeader1 		:= {{} ,{} }
Local aHeader2 		:= {{} ,{} }
Local aCols1   			:= {{} ,{} }
Local aCols2   			:= {{} ,{} }

Private aGets[0]
Private aTela[0][0]

If Type("INCLUI") == "U"
	Private INCLUI
EndIf

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case                              
	Case aRotina[nOpc][4] == 2
		INCLUI := .F.
		Altera := .F.
		lA160Inclui := .F.
		lA160Visual := .T.
		nGDOpc := 0
	Case aRotina[nOpc][4] == 5
		INCLUI := .F.
		Altera := .F.
		lA160Inclui := .F.
		lA160Visual := .T.  
		lA160Cancel := .T.
		nGDOpc := 0
	Case aRotina[nOpc][4] == 4
		INCLUI := .T.
		Altera := .F.
		lA160Inclui := .T.
		lA160Visual := .F.
		nGDOpc := GD_UPDATE+GD_INSERT+GD_DELETE
EndCase

cAlias := "LIT"
dbSelectArea(cAlias)
nRecNo := (cAlias)->(Recno())    

If lA160Cancel .and. (LIT->(FieldPos("LIT_ORIGEM"))==0)
	//"Para utilizar esta funcionalidade, deve-se ter o campo LIT_ORIGEM na Base de Dados. Atualize o pacote do template e rode o U_UPDTPLGEM."#"Ambiente nใo atualizado!"
	MsgAlert(STR0009,STR0010)	
	lContinua:= .F.	
EndIF

If lA160Cancel .and. ( LIT->LIT_STATUS <> "1" )
	//"Para cancelar, deve-se somente selecionar contratos com status em aberto."#"Status Incorreto!"
	MsgAlert(STR0011,STR0012)	
	lContinua:= .F.
EndIF               

If lContinua
	
	If lA160Inclui
		aLITFields  := {}
		For nCount := 1 TO (cAlias)->(FCount())
			aAdd( aLITFields ,{ (cAlias)->(FieldName(nCount)) ,(cAlias)->(FieldGet(nCount)) })
		Next nCount
	EndIf
	
	RegToMemory( cAlias ,lA160Inclui )
	
	If lA160Inclui
		If Len(aLITFields) > 0
			For nCount := 1 TO Len(aLITFields)
				If !(aLITFields[nCount ,01] $ "LIT_NCONTR;LIT_REVISA")
					M->&(aLITFields[nCount ,01]) := aLITFields[nCount ,02]
				EndIf
			Next nCount
			M->LIT_CLIENT := cCliente 
			M->LIT_LOJA   := cLoja 
			M->LIT_NOMCLI := cNome
			If left(M->LIT_PREFIX,1)== "C"
				M->LIT_PREFIX := "C" + Soma1( Right(M->LIT_PREFIX ,TamSX3("LIT_PREFIX")[1]-1) )
				dbSelectArea("SE1")
				dbSetOrder(1)
				While lExiste 
					If SE1->(dbSeek(xFilial("SE1")+M->LIT_PREFIX+M->LIT_DOC))
						M->LIT_PREFIX := "C" + Soma1( Right(M->LIT_PREFIX ,TamSX3("LIT_PREFIX")[1]-1) )
					else
						lExiste := .F.
					EndIf
					LOOP
				EndDo
			Else
				M->LIT_PREFIX := "C" +StrZero( 1 ,TamSX3("LIT_PREFIX")[1]-1 )
				dbSelectArea("SE1")
				dbSetOrder(1)
				While lExiste  
					If SE1->(dbSeek(xFilial("SE1")+M->LIT_PREFIX+M->LIT_DOC))
						M->LIT_PREFIX := "C" + Soma1( Right(M->LIT_PREFIX ,TamSX3("LIT_PREFIX")[1]-1) )
					else
						lExiste := .F.
					EndIf 
					LOOP
				EndDo
			EndIf
			M->LIT_REVISA := StrZero( 1 ,TamSX3("LIT_REVISA")[1] )
			
		EndIf
		nRecNo := (cAlias)->(Recno())
	EndIf
	
	aCampos := {"LIT_NCONTR"}
	aTitles1 := {STR0003 ,STR0013,STR0014}  //"Contrato" ,"Condi็ใo de Venda","Solidarios"
	aTitles2 := {STR0015  ,STR0016}     //"Itens do Contrato"  ,"Titulos a receber"

	//
	// carrega as definicoes das colunas do browse
	//
	LoadHeader( {"LJO","LK6"} ,@aHeader1 )
	LoadHeader( {"LIU","SE1"} ,@aHeader2 )
	
	//
	// carrega os itens do browses
	//
	LoadCols1( aHeader1 ,@aCols1 ,lA160Inclui )
 	LoadCols2( aHeader2 ,@aCols2 ,lA160Inclui )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de objetos     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 200, 200, .T., .T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

	oFolder1 := TFolder():New(aPosObj[1,1],aPosObj[1,2],aTitles1,{},oDlg,,,, .T., .T.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1])
	For nCount := 1 to Len(oFolder1:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder1:aDialogs[nCount]
		oFolder1:aDialogs[nCount]:oFont := oDlg:oFont
	Next nCount
	
	oEnch := MsMGet():New(cAlias,(cAlias)->(RecNo()),nOpc,,,,,aPosObj[1],aCampos,3,,,,oFolder1:aDialogs[1])
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// condicao de venda do contrato
	//			
	dbSelectArea("LJO")
	oGD1[1] := MsNewGetDados():New( 2,2,aPosObj[1,3]-aPosObj[1,1]-16,aPosObj[1,4]-6 ,0 ,"AllwaysTrue","AllwaysTrue","+LJO_ITEM",,,9999,,,,oFolder1:aDialogs[2],@aHeader1[1],@aCols1[1])

	//
	// Solidarios do Contrato
	//			
	dbSelectArea("LK6")
	oGD1[2] := MsNewGetDados():New( 2,2,aPosObj[1,3]-aPosObj[1,1]-16,aPosObj[1,4]-6 ,nGDOpc ,"BrwLK6Lin()","AllwaysTrue","+LK6_ITEM",,,9999,,,,oFolder1:aDialogs[3],@aHeader1[2],@aCols1[2])

	oFolder2 := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles2,{},oDLG,,,, .T., .T.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1])
	For nCount := 1 to Len(oFolder2:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder2:aDialogs[nCount]
		oFolder2:aDialogs[nCount]:oFont := oDlg:oFont
	Next nCount

	//
	// Itens do Contrato
	//			
	dbSelectArea("LIU")
	oGD2[1] := MsNewGetDados():New( 2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6 ,0 ,"AllwaysTrue","AllwaysTrue","+LIU_ITEM",,,9999,,,,oFolder2:aDialogs[1],aHeader2[1],aCols2[1])

	//
	// Titulos a receber
	//			
	dbSelectArea("SE1")
	oGD2[2] := MsNewGetDados():New( 2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6 ,0 ,"AllwaysTrue","AllwaysTrue","+E1_PARCELA",,,9999,,,,oFolder2:aDialogs[2],aHeader2[2],aCols2[2])
         
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| iIf( lA160Visual .and. !lA160Cancel,(lOk := .F.,oDlg:End()) ;
	                                                                       ,iIf( Obrigatorio(aGets,aTela);
	                                                                            ,(lOk := .T.,oDlg:End()) ;
	                                                                            ,lOk := .F. ) ) ;
	                                                },{||(lOk := .F.,oDlg:End())},,aButtons) ;
	                                ,aeval(oGD1,{|oObj|oObj:Refresh()}) ;
	                                ,aeval(oGD2,{|oObj|oObj:Refresh()}) )
  
	If lOk .AND. (lA160Inclui .or. lA160Cancel)
		Begin Transaction
			Processa({|| A160Grava( nRecNo ,nSaveSX8 ,oGD1 ,oGD2 ,aLITFields, lA160Cancel) },STR0017,STR0018,.F.) //"Processando o contrato"#"Aguarde..."
		End Transaction
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBrwLK6Lin บAutor  ณReynaldo Miyashita  บ Data ณ  21/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle da MsNewGetdados Linha OK Cadastros de Solidarios บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMa160                                                    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบOBS.      ณ Por ser uma funcao chamada pela MSNewGetDados os arrays    บฑฑ
ฑฑบ          ณ aHeader e a aCols estใo carregados.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function BrwLK6Lin()
Local lRet       := .T.
Local nOcoCodSol := 0
Local nX         := 0
Local nPosCodSol := GdFieldPos( "LK6_CODSOL" ,aHeader)
Local nPosJlSol	 := GdFieldPos( "LK6_LJSOLI" ,aHeader)
Local nUsado 	 := Len(aHeader)

If M->LIT_CLIENT == aCols[N,nPosCodSol] .AND. M->LIT_LOJA == aCols[N,nPosJlSol]
	Help("",1,"GFXEXISSOL",,OemToAnsi(STR0019),1)  //"Existem Solidarios Duplicados"
	lRet := .F.
Endif
	
If lRet
	For nX := 1 To Len(aCols)
		// se o item nao foi deletado
		If !(aCols[N,nUsado+1])
			If aCols[nX,nPosCodSol]+aCols[nX,nPosJlSol] == aCols[N,nPosCodSol]+aCols[N,nPosJlSol]
				If !(aCols[nX,nUsado+1])
					nOcoCodSol++
				EndIf
			EndIf
		EndIf
	Next
	
	If nOcoCodSol > 1
		Help("",1,"GFXEXISSOL",,OemToAnsi(STR0019),1)//"Existem Solidarios Duplicados"
		lRet := .F.
	Else
		If Empty(aCols[N,nPosCodSol]) .Or. Empty(aCols[N,nPosJlSol])
			If !(aCols[N,nUsado+1])
				Help("",1,"OBRIGAT2")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef() บAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Defini็ใo os itens de menu                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

	aRotina := {{ OemToAnsi(STR0020)  ,"AxPesqui"    ,0,1},;  //"Pesquisar"
	            { OemToAnsi(STR0021) ,"T_GMA160Contr" ,0,2},; //"Visualizar"
                { OemToAnsi(STR0022)    ,"T_GMA160Dlg" ,0,4},;  //"Incluir"
                { OemToAnsi(STR0023) ,"T_GMA160Contr" ,0,5} }  //"Cancelar"
                
Return( aRotina )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA160Grava บAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ao dos dados nas tabelas da cessao de direito        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A160Grava( nRecLIT ,nSaveSX8 ,oGD1 ,oGD2 ,aLITFields, lCancel )
Local aArea    := GetArea()
Local aAreaLIT := LIT->(GetArea())
Local aTmpLIX  := {}
Local aTmpLIT  := {}
Local bCampo  	:= {|n| FieldName(n) }
Local nCorrMon := 0
Local nCount  	:= 0
Local nCnt    	:= 0 
Local cPrefix 	:= LIT->LIT_PREFIX
Local cNContr 	:= LIT->LIT_NCONTR
Local nPosCodSol := 0
Local aAuxHeader := {}
Local aAuxCols   := {}
Local cMsgHist   := ""
Local aBaixa	  := {}   
Local aRegSE1	  := {} 
Local aRegDel	  := {}  
Local aRegDelLIX  := {}
Local cUltFech   := GetMV("MV_GMULTFE")   
Local nRegLIT 	  := 0
Local nX		  := 0
Local cOldTipo	  := ""
Local lChkLIW    := .T.


PRIVATE lMsErroAuto := .F.

DEFAULT nSaveSX8 := GetSX8Len()

	ProcRegua( 100 )
	
If !lCancel // inclusao
	// Cabecalho do contrato
	dbSelectArea("LIT")
	dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
	RecLock("LIT",.T.)
	For nCount := 1 TO FCount()
		FieldPut(nCount ,M->&(EVAL(bCampo ,nCount)))
	Next nCount
	If LIT->(FieldPos("LIT_ORIGEM"))>0
		LIT->LIT_ORIGEM := cNContr
   EndIf
	MsUnlock()

	aAuxHeader := oGD2[1]:aHeader
	aAuxCols   := oGD2[1]:aCols

	// Itens do contrato 
	dbSelectArea("LIU") 
	dbSetOrder(1) // LIU_FILIAL+LIU_DOC+LIU_SERIE+LIU_CLIENT+LIU_LOJA+LIU_COD+LIU_ITEM
	For nCount := 1 TO Len(aAuxCols)
		If !aAuxCols[nCount,Len(aAuxHeader)+1]
			RecLock("LIU",.T.)
			For nCnt := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCnt,10] != "V" )
		      		LIU->(FieldPut(FieldPos(aAuxHeader[nCnt,2]),aAuxCols[nCount,nCnt]))
				EndIf
			Next nCnt
			LIU->LIU_FILIAL  := xFilial("LIU")
			LIU->LIU_NCONTR  := M->LIT_NCONTR
			LIU->LIU_CLIENTE := M->LIT_CLIENT
			LIU->LIU_LOJA    := M->LIT_LOJA
			MsUnlock()
		EndIf
	Next nCount
	
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	Enddo
	
	aAuxHeader := oGD1[1]:aHeader
	aAuxCols   := oGD1[1]:aCols
	
	// condicao de venda do contrato
	dbSelectArea("LJO")
	dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	For nCount := 1 TO Len(aAuxCols)
		If !aAuxCols[nCount,Len(aAuxHeader)+1]
			RecLock("LJO",.T.)
			For nCnt := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCnt,10] != "V" )
		      		LJO->(FieldPut(FieldPos(aAuxHeader[nCnt,2]),aAuxCols[nCount,nCnt]))
				EndIf
			Next nCnt
			LJO->LJO_FILIAL := xFilial("LJO")
			LJO->LJO_NCONTR := M->LIT_NCONTR
			MsUnlock()
		EndIf
	Next nCount

	aAuxHeader := oGD1[2]:aHeader
	aAuxCols   := oGD1[2]:aCols
	
	// Solidarios do contrato 
	nPosCodSol := aScan( aAuxHeader ,{|x|x[2] == "LK6_CODSOL"})
	dbSelectArea("LK6")
	dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
	For nCount := 1 TO Len(aAuxCols )
		If !aAuxCols[nCount,Len(aAuxHeader)+1] .and. !Empty(aAuxCols[nCount,nPosCodSol])
			RecLock("LK6",.T.)
			For nCnt := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCnt,10] != "V" )
		      		LK6->(FieldPut(FieldPos(aAuxHeader[nCnt,2]),aAuxCols[nCount,nCnt]))
				EndIf
			Next nCnt
			
			LK6->LK6_FILIAL := xFilial("LK6")
			LK6->LK6_NCONTR := M->LIT_NCONTR
			
			MsUnlock()
		EndIf
	Next nCount
    
	// Detalhes do Titulos a receber
	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	dbSeek(xFilial("LIX")+cNContr )
	While LIX->(!Eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+cNContr
		nRecNo := LIX->(RecNo())

		// Titulos a receber
		dbSelectArea("SE1")
		dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
		
						// Correcao monetaria dos titulos a receber
			dbSelectArea("LIW")
			dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
			lChkLIW := dbSeek(xFilial("LIW")+ SE1->(E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+LIX->LIX_TIPO+M->LIT_DTCM ))
				
			IncProc()
			nCnt++
			If nCnt ==100
				nCnt := 1
			EndIf
			
			// Existe Titulos em aberto, sem baixa parcial?
			lEmAberto := Empty(SE1->E1_BAIXA) .AND. (SE1->E1_SALDO==SE1->E1_VALOR) .AND. Empty(SE1->E1_NUMBOR)   
			
			If lEmAberto

		   		RegToMemory("LIX",.F.,.F.)
				RegToMemory("LIW",.F.,.F.)
	                
				RegToMemory("SE1",.F.,.F.)
				
				// Altera o tipo do titulo a receber para a baixa 
				cOldTipo := M->E1_TIPO
				If AltTipoNF( M->E1_NCONTR ,M->E1_PREFIXO ,M->E1_NUM ,M->E1_PARCELA ,"PR " ,"NF " )
					M->E1_TIPO := "NF "
				EndIf
				
				cMsgHist := STR0024  //"Baixa Total Cessao de Direito"
				
				//
				// alimenta o array para baixa do titulo pela rotina fina070()
				//
				   	aVetor := {	{"E1_PREFIXO"		,M->E1_PREFIXO 		,Nil } ;
				   				,{"E1_NUM"		 	,M->E1_NUM     		,Nil } ;
								,{"E1_PARCELA"	 	,M->E1_PARCELA    	,Nil } ;
								,{"E1_TIPO"	    	,M->E1_TIPO      	,Nil } ;
								,{"AUTMOTBX"	    ,"CSS"            	,Nil } ;
								,{"AUTDTBAIXA"	 	,dDataBase        	,Nil } ;
								,{"AUTHIST"	    	,cMsgHist       	,Nil } ;
								,{"AUTBANCO"		,""       			,Nil } ;
								,{"AUTAGENCIA"		,""       			,Nil } ;
								,{"AUTCONTA"		,""					,Nil } ;
								,{"AUTJUROS"		,0 					,Nil ,.T. } ;
								,{"AUTMULTA"		,0 					,Nil ,.T. } ;
								,{"AUTCM1"			,nCorrMon			,Nil ,.T. } ;
								,{"AUTPRORATA"		,0 					,Nil ,.T. } ;
					 			,{"AUTVALREC"	 	,SE1->E1_SALDO	  	,Nil } }
					 			
				lMsErroAuto := .F.
		 	  	MSExecAuto({|x,y| fina070(x,y)},aVetor,3)
				If lMsErroAuto
				    // "Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: "
					Alert(STR0025 + M->E1_PREFIXO + "/" + M->E1_NUM + "/" + M->E1_PARCELA + ")")
					MostraErro()					
					M->E1_TIPO := cOldTipo
		   		Else
	
					RecLock("LIX",.T.)
						For nCount := 1 TO FCount()
							FieldPut(nCount ,M->&(EVAL(bCampo ,nCount)))
						Next nCount
						If lEmAberto
							LIX->LIX_PREFIX := M->LIT_PREFIX
						EndIf
						LIX->LIX_NCONTR := M->LIT_NCONTR
					MsUnlock()
		         
					If lChkLIW
						RecLock("LIW",.T.)
							For nCount := 1 TO FCount()
								FieldPut(nCount ,M->&(EVAL(bCampo ,nCount)))
							Next nCount
							If lEmAberto
								LIW->LIW_PREFIX := M->LIT_PREFIX
								nCorrMon := LIW->LIW_VLRAMO + LIW->LIW_ACUAMO
							EndIf
						MsUnlock()
					EndIf
	
					RecLock("SE1",.T.)
						For nCount := 1 TO FCount()
							FieldPut(nCount ,M->&(EVAL(bCampo ,nCount)))
						Next nCount
						SE1->E1_CLIENTE := M->LIT_CLIENT
						SE1->E1_LOJA    := M->LIT_LOJA
						SE1->E1_NOMCLI  := M->LIT_NOMCLI
						SE1->E1_PREFIXO := M->LIT_PREFIX
						SE1->E1_NCONTR  := M->LIT_NCONTR
						SE1->E1_TIPO 	:= cOldTipo
					MsUnlock()
	
		   		EndIf
			EndIf   	
		
		EndIf
	
		dbSelectArea("LIX")
		dbSetOrder(3)
		LIX->( dbGoto(nRecNo) )
		LIX->( dbSkip() )
	EndDo
	
	////////////////////////////////////////////////////////////////////////////////////
	//
	// O Contrato original gero a cessใo de direito
	//
	If (nPos_NCONTR := aScan( aLITFields ,{|x| x[1] == "LIT_NCONTR" })) >0
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+aLITFields[nPos_NCONTR][2])
			RecLock("LIT",.F.)
				LIT->LIT_STATUS := "4" // 4-Cessao de direito
			MsUnlock()
		EndIf
	EndIf

Else //Cancelar

	If LIT->(FieldPos("LIT_ORIGEM"))>0
		cNContr := LIT->LIT_ORIGEM  
		
		If !EMPTY(LIT->LIT_ORIGEM) .AND. LIT->LIT_STATUS == "1"
		
			// Faz a exclusao de todos os registros do contrato gerado na cessao de direito
			dbSelectArea("LIT")
		   	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		   	If dbSeek(xFilial("LIT")+LIT->LIT_NCONTR)
		   
				dbSelectArea("LIX")
				dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				IF dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_PREFIX+LIT_DUPL) )
	                                          
					While LIX->(!Eof()) .AND. (LIX->(LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM) == xFilial("LIX")+LIT->LIT_NCONTR+LIT_PREFIX+LIT_DUPL)
				   	  
						dbSelectArea("SE1")
						dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						IF dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL))
		               		// Verifica existencia de baixa total ou parcial 
			           		If Empty(SE1->E1_BAIXA) .and. (SE1->E1_SALDO == SE1->E1_VALOR ) 
						
								aaDD( aRegDel, {SE1->(Recno())}  )
								aaDD( aRegDelLIX, {LIX->(Recno())}  )							
								
							Else	  
								// O Titulo # " registrou caracteristicas de baixa. Este contrato nao poderแ ser cancelado." # Atencao
								MsgAlert(STR0026 +alltrim(E1_PREFIXO)+"/"+alltrim(E1_NUM)+"/"+alltrim(E1_PARCELA)+ STR0027 , STR0028)
								Return
							EndIf
				   		EndIf        
				   	    
				   		dbSelectArea("LIW")
						dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
						If dbSeek(xFilial("LIW")+ SE1->(E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)+LIX->LIX_TIPO+LIT->LIT_DTCM )
                  			Reclock("LIW", .F.)          						
								DbDelete()			
							MsUnlock("LIW")
						EndIf               
						
						LIX->( dbSkip() )
					
					EndDo					
				EndIf
				
				// Efetua a exclusao dos registros SE1 caso nao encontre nenhuma baixa
				For nX:=1 to Len(aRegDel)
					dbSelectArea("SE1")
					dbGoTo(aRegDel[nX][1])
					Reclock("SE1", .F.)          						
						DbDelete()			
					MsUnlock("SE1")
				Next nX               
				
				// Efetua a exclusao dos registros LIX caso nao encontre nenhuma baixa
				For nX:=1 to Len(aRegDelLIX)
					dbSelectArea("LIX")
					dbGoTo(aRegDelLIX[nX][1])
					Reclock("LIX", .F.)          						
						DbDelete()			
					MsUnlock("LIX")
				Next nX                     
				
				// DELETA ITENS DA CONDICAO DE VENDA DO CONTRATO		
				dbSelectArea("LJO")
				dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				If dbSeek(xFilial("LJO")+LIT->(LIT_NCONTR))
				   While LJO->( !EOF() ) .and. (LJO->LJO_NCONTR == LIT->LIT_NCONTR)
					
						Reclock("LJO", .F.)          						
						DbDelete()			
						MsUnlock("LJO")
		              
				   LJO->( dbSkip() )
				   EndDo
				EndIf 
		      
				// DELETA CONTRATO DA CESSAO DE DIREITO
		
				Reclock("LIT", .F.)          						
					DbDelete()			
				MsUnlock("LIT")
	      
			EndIf	                                      
			                                       
	      //     
			// CONTRATO ORIGINAL QUE SERA RECONSTRUIDO
			// NESTE PROCESSO, O SISTEMA TENDE A PERDER OS POSICIONAMENTOS DE TABELAS
			// POR ESSE MOTIVO EXISTEM MUITOS REPOSICIONAMENTOS (DBSELECT, SETORDER, RECNO)
			//
			dbSelectArea("LIT")
			dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		   	If dbSeek(xFilial("LIT")+cNContr)
	
		   		aTmpLIT := LIT->(GetArea())
	
		   		dbSelectArea("LIX")
				LIX->(dbSetOrder(3)) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_PREFIX+LIT_DUPL) )
				While LIX->(!Eof()) .AND. LIX->(LIX_NCONTR+LIX_PREFIX+LIX_NUM) == LIT->(LIT_NCONTR+LIT_PREFIX+LIT_DUPL)
	                                           
			   	aTmpLIX := {}
			   	
			   	dbSelectArea("SE1")
			   	SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			   	IF dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL))
						// SE EXISTIR ALGUMA BAIXA QUE NAO SEJA POR CESSAO DE DIREITO, 
						//NAO DEVEMOS CANCELA-LA         
				   	dbSelectArea("SE5")
				   	SE5->(dbSetOrder(7)) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
					If dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA) )
						If ALLTRIM(SE5->E5_MOTBX) <> "CSS"
							LIX->( dbSkip() )	
						ENDIF
					ENDIF
			   		aTmpLIX := LIX->(GetArea()) 
					aBaixa  := {}
					
					AADD(aBaixa,{"E1_PREFIXO" 	,SE1->E1_PREFIXO			, Nil})	// 01
					AADD(aBaixa,{"E1_NUM"     	,SE1->E1_NUM				, Nil})	// 02
					AADD(aBaixa,{"E1_PARCELA" 	,SE1->E1_PARCELA			, Nil})	// 03
					AADD(aBaixa,{"E1_TIPO"    	,SE1->E1_TIPO				, Nil})	// 04
					AADD(aBaixa,{"E1_MOEDA"    	,SE1->E1_MOEDA				, Nil})	// 05
					AADD(aBaixa,{"E1_TXMOEDA"		,SE1->E1_TXMOEDA			, Nil})	// 06
					AADD(aBaixa,{"E1_CLIENTE"		,SE1->E1_CLIENTE			, Nil})	// 07
					AADD(aBaixa,{"E1_LOJA"		,SE1->E1_LOJA				, Nil})	// 08
					
				   	MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)	 
				   		
				  	//PROCURA CORRECAO MONETARIA PARA CADA PARCELA DE ACORDO COM O PARAMETRO DE ULTIMO FECHAMENTO
					dbSelectArea("LIW")
					LIW->(dbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
					If !dbSeek(xFilial("LIW")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+MVNOTAFIS))
						aaDD( aRegSE1, SE1->(recno()) )
					EndIF			                                              
					
	    			RestARea(aTmpLIX)
					RestArea(aTmpLIT)
			   	EndIf    				
			   	
			 		LIX->(dbSetOrder(3))
			   	LIX->( dbSkip() )
			   EndDo
				// VERIFICA O REAL TIPO DA PARCELA DE ACORDO COM A LIW (CORRECAO MONETARIO) 
				// E DE ACORDO COM O PARAMETRO MV_GMULTFE (ULTIMO FECHAMENTO)		   		
	   		T_GemGetParc(aRegSE1)      	
		                                   
		   	dbSelectArea("LIT")
			   	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
				dbSeek(xFilial("LIT")+cNContr)
		   		Reclock("LIT", .F.)          						
					LIT->LIT_STATUS := "1" // 1-Aberto 
				MsUnlock("LIT")
			
		   EndIf       
		   
	   EndIf
	EndIF	
EndIf

If ExistBlock("GEMA160GRV")
	ExecBlock("GEMA160GRV",.F.,.F.)
Endif

RestArea(aAreaLIT)
RestArea(aArea)
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadHeaderบAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a variavel aHeader com as definicoes das           บฑฑ
ฑฑบ          ณ colunas dos browses.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadHeader( aAlias ,aHeader )
Local aArea := GetArea()
Local nCnt := 0      

	For nCnt := 1 To Len(aAlias)
		//
		// montagem do aHeader 
		//
		aHeader[nCnt] := aClone(TableHeader(aAlias[nCnt]))
		aEval( aHeader[nCnt] ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
		
    Next nCnt
    
RestArea(aArea)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadCols1 บAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a variavel aCols de acordo com as definicoes das   บฑฑ
ฑฑบ          ณ colunas dos browses conforme a variavel aHeader.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadCols1( aHeaders ,aCols ,lIncluir )
Local aArea    := GetArea()
Local aAreaLK6 := LK6->(GetArea())
Local aAreaLJO := LJO->(GetArea())
Local nCount   := 0
Local nPosGD   := 0
	
	// define a posicao de qual acols utilizar
	nPosGD   := 2
	If !lIncluir
		// faz a montagem do aCols da tabela LK6
		dbSelectArea("LK6")
		dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
		dbSeek(xFilial("LK6")+LIT->LIT_NCONTR)
		While !Eof() .And. LK6->LK6_FILIAL+LK6->LK6_NCONTR == xFilial("LK6")+LIT->LIT_NCONTR
	
			aAdd(aCols[nPosGD],Array(Len(aHeaders[nPosGD])+1))
			For nCount := 1 to Len(aHeaders[nPosGD])
				If ( aHeaders[nPosGD ,nCount ,10] != "V")
					aCols[nPosGD ,Len(aCols[nPosGD]) ,nCount] := FieldGet(FieldPos(aHeaders[nPosGD ,nCount ,2]))
				Else
					aCols[nPosGD ,Len(aCols[nPosGD]) ,nCount] := CriaVar(aHeaders[nPosGD ,nCount ,2])
				EndIf
			Next nCount
			aCols[nPosGD][Len(aCols[nPosGD])][Len(aHeaders[nPosGD])+1] := .F.
			
			dbSelectArea("LK6")
			dbSkip()    
		EndDo
    EndIf
    
    If Len(aCols[nPosGD]) == 0
		aAdd(aCols[nPosGD],Array(Len(aHeaders[nPosGD])+1))
		For nCount := 1 to Len(aHeaders[nPosGD])
			aCols[nPosGD ,Len(aCols[nPosGD]) ,nCount] := CriaVar(aHeaders[nPosGD ,nCount ,2])
		Next nCount
		aCols[nPosGD ,Len(aCols[nPosGD]) ,Len(aHeaders[nPosGD])+1] := .F.
	EndIf
    
    
	// define a posicao de qual acols utilizar
	nPosGD := 1
	// faz a montagem do aCols da tabela LJO
	dbSelectArea("LJO")
	dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
	While !Eof() .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR == xFilial("LJO")+LIT->LIT_NCONTR

		aAdd(aCols[nPosGD],Array(Len(aHeaders[nPosGD])+1))
		For nCount := 1 to Len(aHeaders[nPosGD])
			If ( aHeaders[nPosGD][nCount][10] != "V")
				aCols[nPosGD][Len(aCols[nPosGD])][nCount] := FieldGet(FieldPos(aHeaders[nPosGD][nCount][2]))
			Else
				aCols[nPosGD][Len(aCols[nPosGD])][nCount] := CriaVar(aHeaders[nPosGD][nCount][2])
			EndIf
		Next nCount
		aCols[nPosGD][Len(aCols[nPosGD])][Len(aHeaders[nPosGD])+1] := .F.
		dbSelectArea("LJO")
		dbSkip()    
	EndDo

RestArea(aAreaLK6)
RestArea(aAreaLJO)
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadCols2 บAutor  ณReynaldo Miyashita  บ Data ณ 14.02.2007  ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a variavel aCols de acordo com as definicoes das   บฑฑ
ฑฑบ          ณ colunas dos browses conforme a variavel aHeader.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadCols2( aHeader ,aCols ,nOpcX )
Local aArea    := GetArea()
Local aAreaLIU := LIU->(GetArea())
Local aAreaLIX := LIX->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local nCount   := 0
Local nPosGD   := 0

	nPosGD := 1
	// faz a montagem do aCols da tabela LIU
	dbSelectArea("LIU")
	dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR
	dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
	While !Eof() .And. LIU->LIU_FILIAL+LIU->LIU_NCONTR == xFilial("LIU")+LIT->LIT_NCONTR

		aAdd(aCols[nPosGD],Array(Len(aHeader[nPosGD])+1))
		For nCount := 1 to Len(aHeader[nPosGD])
			If ( aHeader[nPosGD][nCount][10] != "V")
				aCols[nPosGD][Len(aCols[nPosGD])][nCount] := FieldGet(FieldPos(aHeader[nPosGD][nCount][2]))
			Else
				aCols[nPosGD][Len(aCols[nPosGD])][nCount] := CriaVar(aHeader[nPosGD][nCount][2])
			EndIf
		Next nCount
		aCols[nPosGD][Len(aCols[nPosGD])][Len(aHeader[nPosGD])+1] := .F.
		
		dbSelectArea("LIU")
		dbSkip()    
	EndDo

	nPosGD := 2
	// faz a montagem do aCols da tabela SE1 atrav้s da LIX
	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
	While !Eof() .And. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+LIT->LIT_NCONTR

		dbSelectArea("SE1")
		dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
			aAdd(aCols[nPosGD],Array(Len(aHeader[nPosGD])+1))
			For nCount := 1 to Len(aHeader[nPosGD])
				If ( aHeader[nPosGD][nCount][10] != "V")
					aCols[nPosGD][Len(aCols[nPosGD])][nCount] := FieldGet(FieldPos(aHeader[nPosGD][nCount][2]))
				Else
					aCols[nPosGD][Len(aCols[nPosGD])][nCount] := CriaVar(aHeader[nPosGD][nCount][2])
				EndIf
			Next nCount
			aCols[nPosGD][Len(aCols[nPosGD])][Len(aHeader[nPosGD])+1] := .F.
		EndIf
		
		dbSelectArea("LIX")
		dbSkip()    
	EndDo
	
RestArea(aAreaSE1)
RestArea(aAreaLIX)
RestArea(aAreaLIU)
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMotivo บAutor  ณReynaldo Miyashita  บ Data ณ  01.03.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui na Tabela de Motivos da baixa a baixa por Cessao    บฑฑ
ฑฑบ          ณ de direito                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GEMMotivo()
Local nHandle := 0
Local nTamArq := 0
Local nBytes  := 0
Local nTamLin := 19
Local xBuffer := ""
Local lExiste := .F.

	If (nHandle := fOpen( "SigaAdv.MOT" ,2+32 ) ) == -1
		HELP(" ",1,"MOT_ERROR")
		Final("Erro F_"+str(fError(),2)+" em SIGAADV.MOT")
	EndIf

	nTamArq := fSeek(nHandle,0,2)	// Verifica tamanho do arquivo
	fSeek( nHandle,0,0)	     	// Volta para inicio do arquivo
	
	While nBytes<nTamArq
		
		xBuffer := Space(nTamLin)
		fRead(nHandle,@xBuffer,nTamLin)
		If ! Empty(xBuffer)
			If "CDD" == left(xBuffer,3)
				lExiste := .T.
			EndIf
		EndIf
		
		nBytes+=nTamLin
	EndDo

	If !lExiste	
		fWrite(nHandle,"CDDCESS.DIREIANNN"+chr(13)+chr(10))
	EndIf	

	fClose(nHandle)

Return( .T. )


Static Function AltTipoNF( cContrato ,cPrefixo ,cNumero ,cParcela ,cTipo ,cNewTipo )
Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local aAreaLIX := LIX->(GetArea())
Local aAreaLIW := LIW->(GetArea())
Local aRecord  := {}
Local nCount   := 0
Local lOk      := .F. 

DEFAULT cNewTipo := MVNOTAFIS 

	//
    // copia a registro da tabela SE1
    //
	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If MsSeek( xFilial("LIX")+cContrato+cPrefixo+cNumero+cParcela+cTipo)
		//
	    // copia a registro da tabela SE1
	    //
		dbSelectArea("SE1")
		dbSetOrder(1) // E1_FILIAL+ E1_PREFIXO+ E1_NUM+ E1_PARCELA+ E1_TIPO 
		If MsSeek( xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo)
			RecLock("SE1",.F.,.T.)
				For nCount := 1 to FCount()
					aAdd( aRecord ,FieldGet( nCount ) )
				Next nCount
				
				dbDelete()
			MsUnlock()
									
			RecLock("SE1",.T.)
				For nCount := 1 to Len(aRecord)
					SE1->(FieldPut( nCount ,aRecord[nCount] ))
				Next nCount
				
				SE1->E1_TIPO := cNewTipo
			MsUnlock()
					
	        //
	        // copia a registro da tabela LIX
	        //
	        dbSelectArea("LIX")
			aRecord := {}
			RecLock("LIX",.F.,.T.)
				For nCount := 1 to FCount()
					aAdd( aRecord ,FieldGet( nCount ) )
				Next nCount
				dbDelete()
			MsUnlock()
		
			RecLock("LIX",.T.)
				For nCount := 1 to Len(aRecord)
					LIX->(FieldPut( nCount ,aRecord[nCount] ))
				Next nCount
				LIX->LIX_TIPO := cNewTipo
			MsUnlock()
		
			lOk := .T.
		EndIf
	EndIf
	
RestArea(aAreaLIW)
RestArea(aAreaLIX)
RestArea(aAreaSE1)
RestArea(aArea)

Return( lOk )  
