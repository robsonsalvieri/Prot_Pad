#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA2166.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบClasse    ณLJCCargaIntegracaoFormบAutor  ณVendas Clientes     บ Data ณ28/09/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณClasse com o Wizard de integra็ใo para integra็๕es que nใo usam MVC.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCCargaIntegracaoForm
	Data lCancel
	Data aoIntegrationsConfig	
	Data lLoaded
	Data lLoadData

	// GUI gen้rico
	Data oWizard
	
	// Pain้l da sele็ใo de integra็๕es possํveis
	Data oPSelSup   
	Data oPSelRes
	Data oRadIntegrations 
	Data nSelectedIntegration		
	
	// Pain้l da configura็ใo da integra็ใo
	Data oPConSup
	Data oPConInf
	Data oPConInfSup
	Data oPConInfInf
	Data oSCon
	Data oSPCon
	Data oTMConfigText
	Data oTMConfigResu	
	Data cConfigText
	Data oBtnConfigurar	
	Data oBtnCanCon
	
	// Pain้l da valida็ใo da configura็ใo
	Data oPPreSup
	Data oPPreInf
	Data oTMConfigInf
	Data oBtnValidar
	Data oBtnCanVal
	
	// Pain้l de carga inicial
	Data oProcessText
	Data oProcess
	Data oTableText
	Data oTable 
	Data oRecordText
	Data oRecord  
	Data oBtnCarga
	Data oBtnCanCar
	
	// Pain้l de encerramento
	Data oSEnd
	Data oSPEnd
	Data oTMEncerrText
	Data cEndText

	Method New()
	Method Show()
	Method Initialize()
	Method IniciaCarga()
	Method IniciaConfig()
	Method VerificaConfig()
	Method Cancel()
	Method StartProcess()
	Method EndProcess()
	Method ResetProgress()
	Method EnableButtons()
	Method DisableButtons()
	Method RefreshProgress()
	Method AddIntegration()
	Method Update()
	Method LoadTextConfig()
	Method LoadEndText()
EndClass     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCCargaIntegracaoForm.	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCCargaIntegracaoForm
	Self:lCancel				:= .F.
	Self:aoIntegrationsConfig	:= {}
	Self:lLoaded				:= .F.  
	Self:lLoadData				:= .T.
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณInitializeบAutor ณVendas Clientes         บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo responsแvel por inicializar os componentes grแficos. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Initialize() Class LJCCargaIntegracaoForm 
	Local nCount 			:= 0
	Local aIntegrations		:= {}	
	Local nMeter1 := 1
	Local nMeter2 := 1
	Local nMeter3 := 1
	
	DEFINE WIZARD Self:oWizard TITLE IIF(Self:lLoadData, STR0001, STR0023 ) HEADER STR0002 MESSAGE " "; // "Assistente de Configura็ใo" "Assistente de configura็ใo e carga de integra็ใo"
			TEXT IIF(Self:lLoadData, STR0003, STR0024)  PANEL ; // )  PANEL ; // "Esse assistente lhe auxiarแ no processo de configura็ใo de integra็ใo e na gera็ใo da carga inicial dos dados." /"Esse assistente lhe auxiliarแ no processo de configura็ใo de integra็ใo."
			NEXT {|| .T.} FINISH {|| .T.}			

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSele็ใo das integra็๕es disponํveis.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL Self:oWizard HEADER STR0004 MESSAGE STR0005 PANEL; // "Assistente de configura็ใo" "Sele็ใo de integra็๕es"
		BACK {|| .T.} NEXT {|| Self:LoadTextConfig() } FINISH {|| .T.} EXEC {|| .T.}								
		
	Self:oPSelSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 10 )
	Self:oPSelSup:Align := CONTROL_ALIGN_TOP
	Self:oPSelRes := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPSelRes:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 000,000 Say STR0006 Size 200,008 COLOR CLR_BLACK PIXEL OF Self:oPSelSup // "Selecione uma integra็ใo:"
	
	For nCount := 1 To Len(Self:aoIntegrationsConfig)
		aAdd( aIntegrations, Self:aoIntegrationsConfig[nCount]:GetDisplayName() )
	Next
		
	Self:oRadIntegrations := TRadMenu():New( 0, 0, aIntegrations, bSetGet(Self:nSelectedIntegration), Self:oPSelRes,,,,,,,,0, 0,,,,.T. )
	Self:oRadIntegrations:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfigura็ใo da integra็ใo.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	CREATE PANEL Self:oWizard HEADER STR0005 MESSAGE STR0007 PANEL; // "Assistente de configura็ใo" "Configura็ใo integra็ใo"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}
	
	Self:oPConSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPConSup:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oPConInf := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 50 )
	Self:oPConInf:Align := CONTROL_ALIGN_BOTTOM
	
	Self:oPConInfSup := TPanel():New( 0, 0, , Self:oPConInf, , , , , , 0, 0 )
	Self:oPConInfSup:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oPConInfInf := TPanel():New( 0, 0, , Self:oPConInf, , , , , , 0, 10 )
	Self:oPConInfInf:Align := CONTROL_ALIGN_BOTTOM
	
	@ 000,000 Button Self:oBtnConfigurar PROMPT STR0008 Size 040,010  ACTION Self:IniciaConfig() PIXEL OF Self:oPConInfInf // "Configurar"
	
	@ 000,042 Button Self:oBtnCanCon PROMPT STR0009 Size 040,010 ACTION (Self:Cancel()) PIXEL OF Self:oPConInfInf // "Cancelar"
	Self:oBtnCanCon:Disable()	
	
	Self:oSCon := TScrollArea():New(Self:oPConSup,0,0,0,0,.T.,.T.,.T.)
	Self:oSCon:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oSPCon := TPanel():New( 0, 0, , Self:oSCon, , , , , , 0, 500 )
	Self:oSPCon:Align := CONTROL_ALIGN_TOP
	
	Self:oSCon:SetFrame( Self:oSPCon )	
	
	Self:oTMConfigText := TSay():New( 0, 0, bSetGet( Self:cConfigText ), Self:oSPCon,,,,,,.T.,,,0,0,,,,,,.T.)
	Self:oTMConfigText:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oTMConfigResu := TSimpleEditor():New( 0, 0, Self:oPConInfSup, 0, 0, , )
	Self:oTMConfigResu:Align := CONTROL_ALIGN_ALLCLIENT	
        
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida็ใo de ambiente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL Self:oWizard HEADER IIF(Self:lLoadData, STR0010, STR0025) MESSAGE IIF(Self:lLoadData, STR0011, STR0026) PANEL; // "Assistente de carga"/"Assistente de Integra็ใo" "Valida็ใo das configura็๕es necessแrias para a carga" /"Valida็ใo das configura็๕es necessแrias para a integra็ใo." 
		BACK {|| .T.} NEXT {|| IIF(!Self:lLoadData, Self:LoadEndText() ,.T.) } FINISH {|| .T.} EXEC {|| .T.}
	
	Self:oPPreSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPPreSup:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oPPreInf := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 10 )	
	Self:oPPreInf:Align := CONTROL_ALIGN_BOTTOM
	
	Self:oTMConfigInf := TSimpleEditor():New( 0, 0, Self:oPPreSup, 0, 0, , )
	Self:oTMConfigInf:Align := CONTROL_ALIGN_ALLCLIENT
	  	
	@ 000,000 Button Self:oBtnValidar PROMPT STR0012 Size 040,010  ACTION Self:VerificaConfig() PIXEL OF Self:oPPreInf // "Validar"
	@ 000,042 Button Self:oBtnCanVal PROMPT STR0013 Size 040,010 ACTION (Self:Cancel()) PIXEL OF Self:oPPreInf // "Cancelar"
	Self:oBtnCanVal:Disable()	
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarga inicial.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	If Self:lLoadData
	
		CREATE PANEL Self:oWizard HEADER STR0010 MESSAGE STR0014 PANEL; // "Assistente de carga" "Gera็ใo de carga"
			BACK {|| .T.} NEXT {|| Self:LoadEndText() } FINISH {|| .T.} EXEC {|| .T.}		
			
		@ 010,008 Say Self:oProcessText PROMPT STR0015 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Processo:"
		@ 020,008 METER Self:oProcess VAR nMeter1 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		@ 030,008 Say Self:oTableText PROMPT STR0016 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Tabela:"
		@ 040,008 METER Self:oTable VAR nMeter2 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		@ 050,008 Say Self:oRecordText PROMPT STR0017 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Registro:"
		@ 060,008 METER Self:oRecord VAR nMeter3 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		
		@ 070,008 Button Self:oBtnCarga PROMPT STR0018 Size 040,010  ACTION Self:IniciaCarga() PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Iniciar carga"
		@ 070,050 Button Self:oBtnCanCar PROMPT STR0019 Size 040,010 ACTION (Self:CancelCarga()) PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Cancelar"
		Self:oBtnCanCar:Disable()
	
	EndIf	  
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEncerramento.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	CREATE PANEL Self:oWizard HEADER IIF(Self:lLoadData, STR0010, STR0025) MESSAGE STR0020 PANEL; // "Assistente de carga"/"Assistente de Integra็ใo" "Encerramento"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}				
		
	Self:oSEnd := TScrollArea():New(Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)],0,0,0,0,.T.,.T.,.T.)
	Self:oSEnd:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oSPEnd := TPanel():New( 0, 0, , Self:oSEnd, , , , , , 0, 500 )
	Self:oSPEnd:Align := CONTROL_ALIGN_TOP
	
	Self:oSEnd:SetFrame( Self:oSPEnd )			

	Self:oTMEncerrText := TSay():New( 0, 0, {|| Self:cEndText }, Self:oSPEnd,,,,,,.T.,,,0,0,,,,,,.T.)
	Self:oTMEncerrText:Align := CONTROL_ALIGN_ALLCLIENT				
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณShow      บAutor ณVendas Clientes         บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo responsแvel por exibir o wizard.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Show() Class LJCCargaIntegracaoForm	
	Self:Initialize()
			
	ACTIVATE WIZARD Self:oWizard CENTERED VALID {|| .T. } 	
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณEnableButtonsบAutor ณVendas Clientes      บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo para habilitar os bot๕es de navega็ใo do wizard,     บฑฑ
ฑฑบ          ณal้m dos bot๕es especํficos.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnableButtons() Class LJCCargaIntegracaoForm	
	// Gen้ricos
	Self:oWizard:oBack:Enable()
	Self:oWizard:oNext:Enable()
	Self:oWizard:oCancel:Enable()
	Self:oWizard:oFinish:Enable()
	
	// Especํficos
	If Self:lLoadData
		Self:oBtnCarga:Enable()	
	EndIf
	Self:oBtnConfigurar:Enable()	
	Self:oBtnValidar:Enable()	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณDisableButtonsบAutor ณVendas Clientes     บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo para desabilitar os bot๕es de navega็ใo do wizard,   บฑฑ
ฑฑบ          ณal้m dos bot๕es especํficos.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DisableButtons() Class LJCCargaIntegracaoForm
	// Gen้ricos
	Self:oWizard:oBack:Disable()
	Self:oWizard:oNext:Disable()
	Self:oWizard:oCancel:Disable()
	Self:oWizard:oFinish:Disable()
	
	// Especํficos
	If Self:lLoadData
		Self:oBtnCarga:Disable()
	EndIf	
	Self:oBtnConfigurar:Disable()
	Self:oBtnValidar:Disable()	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณIniciaCargaบAutor ณVendas Clientes        บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que executa o processamento de carga inicial.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IniciaCarga() Class LJCCargaIntegracaoForm
	Local oCargaIni	:= Nil					//Objeto do tipo LJCCargaInicialInt
	
	// Reafirma que o processamento nใo estแ cancelado.
	Self:lCancel := .F.
	
	Self:DisableButtons()
	Self:StartProcess()

	//Instancia o objeto LJCCargaInicialInt
	oCargaIni := LJCCargaInicialInt():New()
	
	// Se adiciona como observador
	oCargaIni:AddObserver(Self)
	
	// Executa a carga inicial
	Self:lLoaded := oCargaIni:Gerar() 
	
	// Atualiza tela
	Self:ResetProgress()
	Self:EnableButtons()
	Self:EndProcess()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณIniciaConfigบAutor ณVendas Clientes       บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que executa o processamento de configura็ใo.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IniciaConfig() Class LJCCargaIntegracaoForm
	// Reafirma que o processamento nใo estแ cancelado.
	Self:lCancel := .F.
	
	// Atualiza tela
	Self:DisableButtons()		    
	Self:StartProcess()

	// Se tiver alguma configura็ใo selecionada	
	If Self:nSelectedIntegration > 0
		nSelectedIntegration := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:Configure()
	EndIf
	
	// Atualiza tela
	Self:EnableButtons()
	Self:EndProcess()
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณVerificaConfigบAutor ณVendas Clientes     บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que executa o processamento de verifica็ใo de config.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VerificaConfig() Class LJCCargaIntegracaoForm
	// Reafirma que o processamento nใo estแ cancelado.
	Self:lCancel := .F.
	
	// Atualiza tela
	Self:DisableButtons()
	Self:StartProcess()
	
	// Se tiver alguma configura็ใo selecionada
	If Self:nSelectedIntegration > 0
		nSelectedIntegration := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:Validate()
	EndIf
	
	// Atualiza tela
	Self:EnableButtons()
	Self:EndProcess()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณCancel    บAutor ณVendas Clientes         บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que cancela o processamento ativo.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Cancel() Class LJCCargaIntegracaoForm
	Self:lCancel := .T.  
Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณStartProcessบAutor ณVendas Clientes       บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que habilita os bot๕es de cancelamento durante algum บฑฑ
ฑฑบ          ณprocessamento.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method StartProcess() Class LJCCargaIntegracaoForm
	Self:oBtnCanCon:Enable()	
	Self:oBtnCanVal:Enable()			
	If Self:lLoadData
		Self:oBtnCanCar:Enable()
	EndIf			
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณEndProcessบAutor ณVendas Clientes         บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que desabilita os bot๕es de cancelamento no final    บฑฑ
ฑฑบ          ณde algum processamento.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EndProcess() Class  LJCCargaIntegracaoForm
	Self:oBtnCanCon:Disable()	
	Self:oBtnCanVal:Disable()		
	If Self:lLoadData
		Self:oBtnCanCar:Disable() 
	EndIf		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณResetProgressบAutor ณVendas Clientes      บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que reinicia os componentes de exibi็ใo de progresso บฑฑ
ฑฑบ          ณda carga inicial.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ResetProgress() Class LJCCargaIntegracaoForm
	Self:oProcessText:SetText( STR0015 ) // "Processo:"
	Self:oProcess:SetTotal( 100 )
	Self:oProcess:Set( 0 )
	Self:oTableText:SetText( STR0016 ) // "Tabela:"
	Self:oTable:SetTotal( 100 )
	Self:oTable:Set( 0 )
	Self:oRecordText:SetText( STR0017 ) // "Registro:"
	Self:oRecord:SetTotal( 100 )
	Self:oRecord:Set( 0 )
	Self:RefreshProgress()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณRefreshProgressบAutor ณVendas Clientes    บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que atualiza os componentes de exibi็ใo de progresso บฑฑ
ฑฑบ          ณda carga inicial.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RefreshProgress() Class LJCCargaIntegracaoForm
	Self:oProcessText:Refresh()
	Self:oProcess:Refresh()
	Self:oTableText:Refresh()
	Self:oTable:Refresh()
	Self:oRecordText:Refresh()
	Self:oRecord:Refresh()
	Self:oWizard:oDlg:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณUpdate         บAutor ณVendas Clientes    บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que atualiza o progresso de alguma processamento.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoSubject: Objeto que avisou da atualiza็ใo do progresso.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Method Update( oSubject ) Class LJCCargaIntegracaoForm
	Local nCount	:= 0
	Local cTempText	:= ""

	// Se for o objeto de carga
	If oSubject:GetClassInterface() == "LJCCargaInicialInt"
		Self:oProcess:SetTotal( oSubject:nTotal )
		Self:oProcess:Set( oSubject:nValue )
		Self:oProcessText:SetText( STR0015 + " " + oSubject:cProcessText ) // "Processo:"
		Self:oTable:SetTotal( oSubject:nItemTotal )
		Self:oTable:Set( oSubject:nItemValue )
		Self:oTableText:SetText( STR0016 + " " + oSubject:cTableText) // "Tabela:"
		Self:oRecord:SetTotal( oSubject:nSubItemTotal )
		Self:oRecord:Set( oSubject:nSubItemValue )
		Self:oRecordText:SetText( STR0017 + " " + AllTrim(Str(oSubject:nSubItemValue)) + "/" + AllTrim(Str(oSubject:nSubItemTotal)) ) // "Registro:"
		Self:RefreshProgress()
	// Se for o objeto de configura็ใo de integra็ใo
	ElseIf oSubject:GetClassInterface() == "LJIIntegrationConfig"	
		// Atualiza o texto do processamento da configura็ใo
		Self:oTMConfigResu:Load( oSubject:cText )
		
		// Atualiza o processamento da verifica็ใo de requisitos
		For nCount := 1 To Len( oSubject:aPreRequisitesStatus )
			cTempText += If( oSubject:aPreRequisitesStatus[nCount][1], "<font color='green'>" + STR0021 + "</font>" + " - " + oSubject:aPreRequisitesStatus[nCount][2], "<font color='red'>" + STR0022 + "</font>" + " - " + oSubject:aPreRequisitesStatus[nCount][2] + " - " + oSubject:aPreRequisitesStatus[nCount][3] ) + "<BR>" // "OK" "Nใo OK"
		Next
		Self:oTMConfigInf:Load( cTempText )		
		
		// Faz a atualiza็ใo da tela
		Self:oWizard:oDlg:Refresh()
	EndIf

	// Envia o cancelamento para o assunto	
	If Self:lCancel
		oSubject:Cancel()
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณAddIntegration บAutor ณVendas Clientes    บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que adiciona um objeto de configura็ใo de integra็ใo บฑฑ
ฑฑบ          ณao wizard de integra็ใo.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddIntegration( oIntegrationConfig ) Class LJCCargaIntegracaoForm
	aAdd( Self:aoIntegrationsConfig, oIntegrationConfig )
	oIntegrationConfig:AddObserver( Self )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณAddIntegration บAutor ณVendas Clientes    บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que carrega o texto com instru็๕es da configura็ใo   บฑฑ
ฑฑบ          ณda integra็ใo selecionada.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadTextConfig() Class LJCCargaIntegracaoForm
	If Self:nSelectedIntegration > 0
		Self:cConfigText := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:GetConfigurationText()
	Else
		Self:cConfigText := ""
	EndIf		
	
	Self:oTMConfigText:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณLoadEndText    บAutor ณVendas Clientes    บ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que carrega o texto de encerramento da configura็ใo  บฑฑ
ฑฑบ          ณda integra็ใo selecionada.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadEndText() Class LJCCargaIntegracaoForm
	If Self:nSelectedIntegration > 0
		Self:cEndText := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:GetEndText( Self:lLoaded )
	Else
		Self:cEndText := ""
	EndIf		
	
	Self:oTMConfigText:Refresh()
Return .T.
