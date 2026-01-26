#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "AUTODEF.CH" 

//STFCFG - carrega configuracoes globais no inicio do sistema

Static lMobilePDV := Nil			// Verifica se é PDV Mobile
Static lPDVOnLine := .F.			// Verifica se é PDV On-Line
//-------------------------------------------------------------------
/*/{Protheus.doc} STFConfAmb
Classe de Inicialização do Sistema, carrega configuracoes
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Class STFConfAmb

	Data lMultCoin
	Data lPafEcf
	Data lUseECF
	Data lUsesNotFiscal
	Data lTEFMex
	Data lConfCash 
	Data lEcfArg
	Data lImpExtChq
	Data lCredDF
	Data lSaveCmdFch
	Data lCanChoose
	Data lFiCanCancel
	Data lCanActSale
	Data lVldCanLastSale
	Data lseDocChoose
	Data lGlobFact
	Data lCtrlFol
	Data cRFDShowObs
	Data cRFDObrigat	
	Data lRuleDiscShow
	Data lSugRuleDisc
	Data nVlrRngSugRD
	Data cCtrlDesc
	Data lUsaDisplay
	Data lUsaTef
	Data lOnlyMenuFiscal
	Data lUseSAT
	Data lMobile
	Data cIntegration
	Data lNFCETSS
	Data cTypeOperation
	Data lChangePay
	Data lUseNFCE
	Data lPAFNFCe
	
	Method New()				//Construtor
	Method LoadConfig()		//Carrega configuracoes gerais

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} STFConfAmb
Metodo construtor
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method New() Class STFConfAmb
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadConfig
Carrega as configuracoes 
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method LoadConfig() Class STFConfAmb

// Trabalha com multimoeda
Self:lMultCoin := cPaisLoc <> "BRA"

// Configuracao para a NFC-e
If  IIF(STFGetStation("NFCE") == Nil,.F.,STFGetStation("NFCE")) 
	Self:lUseECF := .F.
Else
	// Trabalha com Impressora Fiscal ECF
	Self:lUseECF := STFProFile(3)[1] 
EndIf

//Configuração para SAT
If Iif(STFGetStation("USESAT") == NIL, .F., STFGetStation("USESAT"))
    Self:lUseECF := .F.
EndIf

// Trabalha com Impressora nao Fiscal
Self:lUsesNotFiscal := STWVldEcfPtg()

// Trabalha com PAFECF 
Self:lPafEcf := STBIsPAF()

// Trabalha com TEF do Mexico
Self:lTEFMex := cPaisLoc == "MEX"

// Trabalha com conferencia de caixa
Self:lConfCash := SuperGetMV( "MV_LJCONFF",,.F. )

// Trabalha com ECF da argentina
Self:lEcfArg := cPaisLoc == "ARG"

// Trabalha com impressao extensa do cheque
Self:lImpExtChq := cPaisLoc <> "BRA"

// Trabalha com programa de credito para DF
Self:lCredDF := cPaisLoc $ "BRA" .AND. SM0->M0_ESTCOB $ "DF"		

// Trabalha com armazenamento do comando de fechamento
Self:lSaveCmdFch := cPaisLoc $ "EUA|POR"	

// Verifica se pode escolher a venda a ser cancelada
Self:lCanChoose := cPaisLoc <> "BRA"
	
// Verifica se pode cancelar vendas ja finalizadas
Self:lFiCanCancel := cPaisLoc $ "CHI|COL"	
	
// Verifica se pode cancelar venda atual em andamento
Self:lCanActSale := cPaisLoc $ "CHI|COL"	

// Valida se pode cancelar somente a ultima venda
Self:lVldCanLastSale := cPaisLoc == "BRA"	

// Verifica se escolhe venda a ser Cancelada a Partir do doc
Self:lseDocChoose := cPaisLoc == "MEX"

// Valida se faz verificacao de factura global
Self:lGlobFact := cPaisLoc == "MEX"

// Trabalha com controle de formularios
Self:lCtrlFol := SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc $ "CHI|COL"

// Motivo de desconto Exibe observação na interface 
// "N" - Não Aparece	"B" - Aparece e é obrigatório	"P" - Aparece e é opcional
Self:cRFDShowObs := "N"

// Motivo de desconto Exibe observação na interface obrigatoriamente
// "N" - Não Aparece	"B" - Aparece e é obrigatório	"P" - Aparece e é opcional
Self:cRFDObrigat := "B"	

// Mostra regras de descontos aplicadas
Self:lRuleDiscShow := .T.

// Exibe sugestao de regra de desconto
Self:lSugRuleDisc := .F.

// Valor do range para exibicao da sugestao de regra de desconto
Self:nVlrRngSugRD := 50 

// Fazer Facilitador para configuração se usa desconto via usuário, via regra ou ambos
// "U" - Usuário	"R" - Regra de Desconto	"A" - Ambos
Self:cCtrlDesc := SuperGetMV("MV_LJCFDES",.T.,"A")

// Verifica se a estacao possui Display
Self:lUsaDisplay 	:= !Empty(STFGetStation("DISPLAY")) 	

// Verifica se usa TEF 
Self:lUsaTef 	:= STFProFile(2,,,,,.T.)[1]

// Verifica se habilita somente o menu fiscal na tela
// Padrao sempre falso, alterado na entrado do sistema 
Self:lOnlyMenuFiscal 	:= .F.
                           
// Verifica se utiliza SAT 
If SLG->(ColumnPos("LG_USESAT")) > 0
	Self:lUseSAT 	:= IIF(STFGetStation("USESAT") == Nil,.F.,STFGetStation("USESAT"))
Else
	Self:lUseSAT 	:= .F.
Endif

//Utilização do PDV atraves de dispositivos Móveis
Self:lMobile := STFIsMobile()

// Usa NFC-e com TSS
Self:lNFCETSS := !Self:lMobile

// Define o tipo de integração usada DEFAULT = "Protheus" 
Self:cIntegration := STFCfgIntegration()

//Tipos de Transacao: "VENDA|TROCADEVOLUCAO|DEMONSTRACAO|"	
Self:cTypeOperation := STFTypeOperation() //Seta o mode de operacao 

//habilta troca de pagamento para orcamentos
Self:lChangePay := STFChangePay()

//Verifica se usa NFCE
Self:lUseNFCE := Iif(ExistFunc("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e

Self:lPAFNFCe := ExistFunc("LjTipoPAF") .AND. LjTipoPAF(STFGetStation("CODIGO")) $ TIPO_PAF_NFCE

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} STFIsFrs
Verifica se está integrando com o FIRST
@param 
@author  Varejo
@version P11.8
@since   16/04/2015
@return  STFIsMobile()
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFIsFrs() //Se integra com first
Local cIntegration := Upper(SuperGetMv("MV_LJRETIN", .F.,  "DEFAULT")) //Parâmetro que indica a integração com retaguarda
Local lRet := .F. //Retorno da rotina

lRet := cIntegration == "FIRST"

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFCfgIntegration
Verifica se está integrando com o FIRST ou com a RMS
@param 
@author  Varejo
@version P11.8
@since   16/04/2015
@return  cIntegration
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCfgIntegration()

Local cIntegration := "DEFAULT"  // Nome da integração "DEFAULT" = Protheus

	Do Case
	
		Case STFIsFrs() 
			cIntegration := "FIRST"
			
		Case SuperGetMv("MV_LJRMS",,.F.)
			cIntegration := "RMS"
				
		Otherwise
			cIntegration := "DEFAULT"	// Protheus Padrão
			
	EndCase

Return cIntegration


//-------------------------------------------------------------------
/*/{Protheus.doc} STFIsMobile
Verifica a informação do Mobile
@param 
@author  Varejo
@version P11.8
@since   16/04/2015
@return  STFGetMobile()
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFIsMobile()

Local aInfoRmt := {}			// Informações do remote
Local lMobile := .F.		// Verificação do mobile

If STFGetMobile() = Nil .AND. GetSrvProfString("FLY01","2") $ "01"

	If FindFunction("GetRmtInfo")
		aInfoRmt := GetRmtInfo()
	EndIf	
	
	If ValType(aInfoRmt) == "A" .AND. Len(aInfoRmt) >= 2
		lMobile := Upper(aInfoRmt[2]) == "ANDROID" .OR. (Upper(aInfoRmt[2]) == "WINDOWS RUNTIME") //Windowns Mobile
	EndIf
	
	//Temporario. 
	//Usado apenas para testes no Windows onde nao se tem aparelho mobile disponivel
	lMobile := lMobile .OR. GetSrvProfString("PDVMOBILE","0") == "1" 
	
	STFSetMobile(lMobile)

Else 
	If GetSrvProfString("FLY01","2") $ "01"
		lMobile := STFGetMobile()
	Else
		lMobile := .F.
	EndIf	
EndIf

Return lMobile


//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetMobile
Retorna a flag se for Mobile
@param
@author  Varejo
@version P11.8
@since   16/04/2015
@return  lMobilePDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFGetMobile()

Return lMobilePDV


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetMobile
Atribui a flag se for Mobile
@param   lValue
@author  Varejo
@version P11.8
@since   16/04/2015
@return  lMobilePDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSetMobile(lValue)

Default lValue := .F.

lMobilePDV := lValue

Return lMobilePDV


//-------------------------------------------------------------------	
/*/{Protheus.doc} STFIniMobile
Faz alteracoes nos ini do PDV mobile

@param 
@author  Varejo
@version P11.8
@since   13/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Main Function STFIniMobile()

Local oButton1			:= Nil			//Botao 
Local oButton2			:= Nil			//Botao 
Local oButton3			:= Nil			//Botao 
Local oSay1				:= Nil			//Say 
Local oSay2				:= Nil			//Say
Local oSay3				:= Nil			//Say 
Local oSay4				:= Nil			//Say 
Local oSay5				:= Nil			//Say 
Local oSay6				:= Nil			//Say 
Local oDlg					:= Nil			//Dialog Principal			
Local lHideParams 		:= AllTrim(GetPvProfString("config","HideParamsForm","", "SMARTCLIENT.INI" )) == "1" //Esconde parametros
Local lLaunchAsServer 	:= AllTrim(GetPvProfString("Local","LaunchAsServer","", "SMARTCLIENT.INI" ) ) == "1" //Executa server
Local lLogMessage 		:= AllTrim(GetPvProfString("General","LogMessages","",GetAdv97()) ) == "1"			 //habilita log de mensagem
Local lLicenseServer 	:= AllTrim(GetPvProfString("LicenseServer","enable","",GetAdv97()) ) == "1"          //Licence
Local serverLcClient		:= AllTrim(GetPvProfString("LicenseClient","server","",GetAdv97()) )					 //Licence	
Local portLcClient		:= AllTrim(GetPvProfString("LicenseClient","port","",GetAdv97()) )						 //Licence

Local bBlock1 := {|| WritePProString("config"		,"HideParamsForm"	,IIF(lHideParams		,"0","1"),"SMARTCLIENT.INI" ), lHideParams:=!lHideParams }//Bloco de Codigo 
Local bBlock2 := {|| WritePProString("Local"	,"LaunchAsServer"	,IIF(lLaunchAsServer	,"0","1"),"SMARTCLIENT.INI" ), lLaunchAsServer:=!lLaunchAsServer }//Bloco de Codigo
Local bBlock3 := {|| WritePProString("General"	,"LogMessage"		,IIF(lLogMessage		,"0","1"),GetAdv97() ), lLogMessage:=!lLogMessage }//Bloco de Codigo
Local bBlock4 := {|| WritePProString("LicenseServer"	,"enable"		,IIF(lLicenseServer		,"0","1"),GetAdv97() ), lLicenseServer:=!lLicenseServer }//Bloco de Codigo


DEFINE MSDIALOG oDlg TITLE "TOTVS FATCLIENT" FROM 000, 000  TO 500, 300 COLORS 0, 16777215 PIXEL //"TOTVS FATCLIENT"

@ 020, 009 BUTTON oButton1 PROMPT "On/Off" SIZE 062, 022 OF oDlg ACTION Eval(bBlock1) PIXEL //"On/Off"
@ 075, 009 BUTTON oButton2 PROMPT "On/Off" SIZE 062, 022 OF oDlg ACTION Eval(bBlock2) PIXEL //"On/Off"
@ 120, 009 BUTTON oButton3 PROMPT "On/Off" SIZE 062, 022 OF oDlg ACTION Eval(bBlock3) PIXEL //"On/Off"
@ 165, 009 BUTTON oButton4 PROMPT "On/Off" SIZE 062, 022 OF oDlg ACTION Eval(bBlock4) PIXEL //"On/Off"

@ 020, 081 SAY oSay1 PROMPT IIF(lHideParams,"On","Off") SIZE 062, 022 OF oDlg COLORS 0, 16777215 PIXEL //"On/Off"
@ 075, 080 SAY oSay2 PROMPT IIF(lLaunchAsServer,"On","Off") SIZE 062, 022 OF oDlg COLORS 0, 16777215 PIXEL //"On/Off"
@ 130, 080 SAY oSay3 PROMPT IIF(lLogMessage,"On","Off") SIZE 062, 022 OF oDlg COLORS 0, 16777215 PIXEL //"On/Off"
@ 185, 080 SAY oSay3 PROMPT IIF(lLicenseServer,"On","Off") SIZE 062, 022 OF oDlg COLORS 0, 16777215 PIXEL //"On/Off"

@ 005, 008 SAY oSay4 PROMPT "HideParamsForm" SIZE 136, 014 OF oDlg COLORS 0, 16777215 PIXEL
@ 060, 008 SAY oSay5 PROMPT "LaunchAsServer" SIZE 136, 014 OF oDlg COLORS 0, 16777215 PIXEL
@ 115, 008 SAY oSay6 PROMPT "LogMessage" SIZE 137, 014 OF oDlg COLORS 0, 16777215 PIXEL
@ 170, 008 SAY oSay6 PROMPT "LicenseServer" SIZE 137, 014 OF oDlg COLORS 0, 16777215 PIXEL


oButton1:SetCSS( POSCSS (GetClassName(oButton1), CSS_BTN_FOCAL )) 
oButton2:SetCSS( POSCSS (GetClassName(oButton2), CSS_BTN_FOCAL )) 
oButton3:SetCSS( POSCSS (GetClassName(oButton3), CSS_BTN_FOCAL ))
oButton4:SetCSS( POSCSS (GetClassName(oButton3), CSS_BTN_FOCAL )) 

ACTIVATE MSDIALOG oDlg CENTERED

Return Nil



//-------------------------------------------------------------------	
/*/{Protheus.doc} ISFly01
Retorna se está com a versão Fly ativa

@param 
@author  Varejo
@version P11.8
@since   13/05/2015
@return  Retorna se está com a versão Fly ativa
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function ISFly01()

Local lIsFly01 := .F. //Controla se é versão Fly01

lIsFly01 := GetSrvProfString("FLY01","0") == "1" 

Return lIsFly01


//-------------------------------------------------------------------	
/*/{Protheus.doc} STFTypeOperation
Retorna o tipo de operacao em uso, venda, troca demonstracao etc

@param 
@author  Varejo
@version P11.8
@since   13/05/2015
@return  Retorna a operacao em uso no momento
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STFTypeOperation()

Local cTypeOperation := "VENDA" //Tipos de operação "VENDA|TROCADEVOLUCAO|DEMONSTRACAO|"	


//Valida versao demostrativa
If UPPER(AllTrim(STFGetStation("LG_TIPTELA") )) == "D" // D = versao demostrativa
	cTypeOperation := "DEMONSTRACAO"

Else
	cTypeOperation := "VENDA"
EndIf	

Return cTypeOperation

//--------------------------------------------------------
/*/{Protheus.doc} STFChangePay
Valida se a troca de forma de pagamentos está ativa
@type function
@author  	rafael.pessoa
@since   	29/03/2018
@version 	P12
@param 		
@return		lRet - Retorna se a troca de pagamentos está habilitada
/*/
//--------------------------------------------------------
Static Function STFChangePay()
Local lRet		:= .F.
Local lHabTFP	:= Iif(SuperGetMV("MV_LJHBTFP",,0) == 0, .F.,.T.) //Habilita ou não a troca de forma de pagamento
Local cCash		:= xNumCaixa()

lRet := AliasIndic("MHI")

lRet := lRet .And. lHabTFP

If lRet

	DbSelectArea("SLF")
	SLF->( DbSetOrder(1) )
	If SLF->( DbSeek(xFilial("SLF")+cCash) )

		cAllAccess := SLF->LF_ACESSO
		cAccess := SubStr( cAllAccess , 41 , 1)

		// status: N - Acesso Negado, S - Acesso Liberado, X - Liberação via Superior
		lRet := If(cAccess <> "S", .T., .F.)

	EndIf

EndIf

lRet := lRet .And. ExistFunc("STIChangePay") //Função que realiza a troca da forma de pagamento

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STFSetOnPdv
Seta se é PDV online
@param   lValue - Determina se é PDV Online
@type function
@author  	rafael.pessoa
@since   	21/05/2018
@version 	P12
@param 		
@return		lPDVOnLine - Retorna se é PDV Online
/*/
//--------------------------------------------------------
Function STFSetOnPdv(lValue)
Default lValue := .F.

lPDVOnLine := lValue

Return lPDVOnLine

//--------------------------------------------------------
/*/{Protheus.doc} STFGetOnPdv
Retorna se é PDV online
@type function
@author  	rafael.pessoa
@since   	21/05/2018
@version 	P12
@param 		
@return		lPDVOnLine - Retorna se é PDV Online
/*/
//--------------------------------------------------------
Function STFGetOnPdv()
Return lPDVOnLine
