//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA089.CH'
 #Include "VKEY.ch"

//Variáveis Estáticas
Static cTitulo := "Interação com Locador"
 
/*/{Protheus.doc} LOCA093
Rotina de Interação com o Usuário do Portl do Locador
@author Dennis Calabrez
@since 10/02/2025
@version 1.0
/*/
Function LOCA097()
Local oBrowse
Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("TRX")
    //oBrowse:SetMenuDef("LOCA089")
    oBrowse:SetDescription(cTitulo)
    //oBrowse:DisableDetails()
  
    oBrowse:AddLegend( "RetLeg() == 'p'", "GREEN",    "Respondido" )
    oBrowse:AddLegend( "RetLeg() == 'w'", "RED",    "Não Respondido" )    
    oBrowse:AddLegend( "RetLeg() == ''", "BLUE",    "Sem Interação" ) 
    //Filtrando
    oBrowse:SetFilterDefault("TRX->TRX_PROJETO <> '' .And. TRX->TRX_AS <> ''")    

    //Ativa a Browse
    oBrowse:Activate()

    //FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes
@author Dennis Calabrez
@since 10/02/2025
@version 1.0
/*/

Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina,{ "Pesquisar", "PESQBRW"           ,0,2,0, NIL } ) //"Pesquisar"
    aAdd(aRotina,{ "Visualizar", "ExeC97(2)"       ,0,2,0, NIL } ) //"Visualizar"
    aAdd(aRotina,{ "Interagir", "IntLoca"       ,0,4,0, NIL } ) //"Interagir"
    aAdd(aRotina,{ "Legenda", "MVC01Leg1"       ,0,4,0, NIL } ) //"Interagir"
    //ADD OPTION aRotina TITLE 'Legenda'    ACTION 'MVC01Leg'     OPERATION 6  ACCESS 0 //OPERATION X

Return aRotina    

/*/{Protheus.doc} ModelDef
Modelo de dados
@author Dennis Calabrez
@since 10/02/2025
@version 1.0
/*/

Static Function ModelDef()
Local oStruct		:= FWFormStruct( 1, 'TRX' )
Local oModel		// Modelo de dados que será construído

    oModel := MPFormModel():New( 'LOCA097' )
    //Antiga enchoice
    oModel:AddFields( 'TRXMASTER', /*cOwner*/, oStruct )
    //Descrição do modelo
    oModel:SetDescription( cTitulo ) 		//"Cadastro de operações com controle de aprovação"

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados
@author Dennis Calabrez
@since 10/02/2025
@version 1.0
/*/

Static Function ViewDef()
Local oModel 	:= FWLoadModel( 'LOCA097' ) 		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruFNH 	:= FWFormStruct( 2, 'TRX' ) 		// Cria a estrutura a ser usada na View
Local oView  									// Interface de visualização construída

    // Cria o objeto de View
    oView := FWFormView():New()
    // Define qual o Modelo de dados será utilizado na View
    oView:SetModel( oModel )
    // Adiciona no nosso View um controle do tipo formulário
    oView:AddField( 'VIEWTRX', oStruFNH, 'TRXMASTER' )
    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 100 )
    // Relaciona o identificador (ID) da View com o "box" para exibição
    oView:SetOwnerView( 'VIEWTRX', 'TELA' )
    /* Desabilita o novo botao "salvar e criar novo" */
    oView:SetCloseOnOK({ || .T. })

Return oView

Function IntLoca()      
Local nTamObserv    := TamSX3("B1_OBS")[1]                  
Local oGetNom
Local cGetNom := Posicione("FP0",1,xFilial("FP0")+TRX->TRX_PROJETO,"FP0_CLINOM")
Local oGetInt
Local oGetCli
Local cGetCli := Posicione("FP0",1,xFilial("FP0")+TRX->TRX_PROJETO,"FP0_CLI")
Local oGetLoj
Local cGetLoj := Posicione("FP0",1,xFilial("FP0")+TRX->TRX_PROJETO,"FP0_LOJA")
Local oGetObra
Local cGetObra := Posicione("FPA",3,xFilial("FPA")+TRX->TRX_AS,"FPA_OBRA")
Local oGetProj
Local cGetProj := TRX->TRX_PROJETO
Local oGetAs
Local cGetAs := TRX->TRX_AS
Local oGetcMot
Local cGetcMot := TRX->TRX_CODMO
Local oGetnMot
Local cGetnMot := Posicione("DA4",1,xFilial("DA4")+TRX->TRX_CODMO,"DA4_NOME")
Local oGetcMult
Local cGetcMult := TRX->TRX_MULTA
Local oGetcNotif
Local cGetcNotif := TRX->TRX_MULTA
Local oGetDtInfra
Local cGetDtInfra := DTOC(TRX->TRX_DTINFR)
Local oGroup1  
Local oGroup2
Local oSayCli
Local oSayLoj
Local oSayNom
Local oSayProj
Local oSayObra
Local oSayInt
Local oSaynMot
Local oSaycMot
Local oSaycMult
Local oSaycNotif
Private oDlg
Private oMultiGe1
Private cMultiGe1 := MSMM(TRX->TRX_MMCOND, nTamObserv)
Private oMultiGe2
Private cMultiGe2 := ""
Private cGetInt := space(250)

  DEFINE MSDIALOG oDlg TITLE "Interação com Locador" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
  
    //Grupo dos dados da Multa - Cabeçalho
    @ 003, 002 GROUP oGroup1 TO 090, 250 PROMPT "Dados da Multa" OF oDlg COLOR CLR_BLUE PIXEL
    @ 008, 006 SAY oSayCli PROMPT "Cliente" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 006 MSGET oGetCli VAR cGetCli When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 008, 082 SAY oSayLoj PROMPT "Loja" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 082 MSGET oGetLoj VAR cGetLoj When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 008, 157 SAY oSayNom PROMPT "Nome Cliente" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 157 MSGET oGetNOM VAR cGetNom When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 006 SAY oSayProj PROMPT "Projeto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 006 MSGET oGetProj VAR cGetProj When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 082 SAY oSayObra PROMPT "Obra" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 082 MSGET oGetObra VAR cGetObra When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 157 SAY oSayAs PROMPT "AS" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 157 MSGET oGetAs VAR cGetAs When .F. SIZE 091, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 048, 006 SAY oSaycMot PROMPT "Cod. Motorista" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 054, 006 MSGET oGetcMot VAR cGetcMot When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  
    @ 048, 082 SAY oSaynMot PROMPT "Nome Motorista" SIZE 058, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 054, 082 MSGET oGetnMot VAR cGetnMot When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL   
    @ 048, 157 SAY oSay8 PROMPT "Data Infração" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 054, 157 MSGET oGetDtInfra VAR cGetDtInfra  When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL      
    @ 068, 006 SAY oSaycNotif PROMPT "Cod. Notificação" SIZE 054, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 074, 006 MSGET oGetcNotif VAR cGetcNotif  When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  
    @ 068, 082 SAY oSaycMult PROMPT "Cod Multa" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL  
    @ 074, 082 MSGET oGetcMult VAR cGetcMult  When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

    //Grupo das interações entre Locador e Locatário
    @ 093, 002 GROUP oGroup2 TO 195, 250 PROMPT "Interações Locador x Locatário" OF oDlg COLOR CLR_BLUE PIXEL
    @ 101, 006 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE When .F. SIZE 240, 088 COLORS 0, 16777215 HSCROLL PIXEL

    //Campo de interação com o Locatário
    @ 199, 012 SAY oSayInt PROMPT "Interação" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 208, 011 GET oMultiGe2 VAR cMultiGe2 OF oDlg MULTILINE SIZE 223, 020 COLORS 0, 16777215 HSCROLL PIXEL
    //@ 208, 011 MSGET oGetInt VAR cGetInt SIZE 223, 010 OF oDlg COLORS 0, 16777215 PIXEL

    //Botões da rotina
    @ 230, 028 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION grvint(cMultiGe2) PIXEL
    @ 230, 157 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION cancint() PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return

Function grvint(cMultiGe2)
Local cObservacao   := ""
Local nTamObserv    := TamSX3("B1_OBS")[1]

    cObservacao := MSMM(TRX->TRX_MMCOND, nTamObserv)    
    If Empty(cMultiGe2)
        MsgStop("Campo de Interação precisa ser preenchido")
        Return(.F.)
    EndIf

    //Agora defino algum texto, adicionando na observação
    cObservacao := Alltrim(cObservacao) + ";mensagem no dia: " + dToC(Date()) + " as " + Time() + CHR(13)+CHR(10)                                      			
	cObservacao += ";mensagem: " + cMultiGe2 + CHR(13)+CHR(10)
	cObservacao += ";usuario: " + UPPER(SubStr(cUsuario,7,15)) + CHR(13)+CHR(10)
    cObservacao += ";tipo: " + 'p' + CHR(13)+CHR(10)
	cObservacao += CHR(13)+CHR(10)
    cMultiGe1 += cObservacao
    cMultiGe2 := ""
		RecLock("TRX", .F.)
            MSMM(, nTamObserv, , (cObservacao), 1, , , "TRX", "TRX_MMCOND")
		TRX->(MsUnlock())
    oDlg:Refresh()  
    //oDlg:End()  
Return()

Function cancint()

    oDlg:End() 

Return()

Function ExeC97(nOpc)
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

    If nOpc == 2
        FWExecView("Sub-Status",'LOCA097', MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons ) // Sub-Status
    EndIf
Return

Function MVC01Leg1()
Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Respondido"  })
    AADD(aLegenda,{"BR_VERMELHO",	"Não respondido"})
	AADD(aLegenda,{"BR_AZUL",	"Sem Interação"})
	BrwLegenda("Interações", "Interações", aLegenda)
Return

Function RetLeg()
Local cleg := ""
Local aBindParam := {}
Local cQuery := ""

                
                cQuery := "SELECT YP_TEXTO "
                cQuery += " FROM "+RetSqlName("SYP")+" SYP "
                cQuery += " WHERE SYP.YP_CHAVE = ? AND SYP.YP_CAMPO = 'TRX_MMCOND' AND SYP.D_E_L_E_T_ = ' ' "
                cQuery += " ORDER BY YP_SEQ DESC"

                aBindParam := {TRX->TRX_MMCOND}
				MPSysOpenQuery(cQuery,"TRBSPY",,,aBindParam)
                        	
                
                While TRBSPY->(!EOF())        
                    
                    If At("tipo:",TRBSPY->YP_TEXTO) > 0
                        cleg := SubStr(TRBSPY->YP_TEXTO,At("tipo:",TRBSPY->YP_TEXTO)+6,1)
                        Exit
                    EndIf    

                    TRBSPY->(DBSKIP())
                End
                 
Return(cleg)
