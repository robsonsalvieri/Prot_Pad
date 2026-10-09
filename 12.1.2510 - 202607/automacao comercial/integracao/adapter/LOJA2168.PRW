#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA2168.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัอออออออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJAIntegrationConfig บAutor  ณVendas Clientes  บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse abstrata responsแvel por configurar e validar a uma          บฑฑ
ฑฑบ          ณintegra็ใo especํfica.                                              บฑฑ
ฑฑบ          ณEssa classe nใo pode ser instanciada diretamente.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJAIntegrationConfig
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArray com as classes que observam a execu็ใo da configura็ใoณ
	//ณe valida็ใo da integra็ใo.                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Data aoObservers	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArray com informa็๕es da valida็ใo das configura็๕es, sendo:                                             ณ
	//ณ aPreRequisitesStatus[n,1]: .T. se o pr้-requisito estแ correto, .F. se o pr้ requisito nใo estแ correto;ณ
	//ณ aPreRequisitesStatus[n,2]: Texto informativo do pr้-requisito;                                          ณ
	//ณCada vez que os observadores sใo notificados eles l๊em essa variแvel.                                    ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Data aPreRequisitesStatus
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTexto que ้ apresentado durante a configura็ใo. Cada vez    ณ
	//ณque os observadores sใo notificados eles l๊em essa variแvel.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Data cText
	Data lCancel
	Data lEAI20

	Method New()
	Method GetClassInterface()
	Method GetDisplayName()
	Method GetConfigurationText()
	Method Configure()
	Method Validate() 
	Method GetEndText()  
	Method SetEAI20()   //CRIADO NOVO METODO PARA INDICAR QUE A INTEGRACAO UTILIZA O NOVO EAI
	Method ADDPROCESS()
	Method AddTable()
	
	// M้todos para gerencia de observadores dessa classe
	Method Cancel()
	Method AddObserver()
	Method Notify()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJAIntegrationConfig.	              บฑฑ
ฑฑบ          ณNesse m้todo sใo definidas as variแveis do objeto com as    บฑฑ
ฑฑบ          ณconfigura็๕es e valida็๕es que serใo processadas.           บฑฑ
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
Method New() Class LJAIntegrationConfig 
	Self:aoObservers	:= {}
	Self:lCancel		:= .F.
	Self:aProcesses		:= {}
	Self:aTables		:= {}  
	Self:lEAI20			:= .F.  //INCLUIDA VALIACOES PARA O NOVO EAI
Return Self

//METODO QUE INDICA O NOVO EAI
Method SetEAI20( lHabilita ) Class LJAIntegrationConfig
	Self:lEAI20 := lHabilita
Return

Method AddProcess( aProcess ) Class LJAIntegrationConfig
	aAdd( Self:aProcesses, aProcess )
Return

Method AddTable( aTable ) Class LJAIntegrationConfig
	aAdd( Self:aTables, aTable )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCancel    บAutor  ณVendas Clientes     บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que cancela o processamento que estแ sendo executado.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Cancel() Class LJAIntegrationConfig
	Self:lCancel := .T.
Return           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAddObserver บAutor  ณVendas Clientes   บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que adiciona um objeto que irแ observar esse.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddObserver( oObserver ) CLass LJAIntegrationConfig
	aAdd( Self:aoObservers, oObserver )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAddObserver บAutor  ณVendas Clientes   บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que notifica todos os observadores.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Notify() Class LJAIntegrationConfig
	Local nCount := 0
	
	For nCount := 1 To Len(Self:aoObservers)
		Self:aoObservers[nCount]:Update( Self )
	Next
Return  

Method Validate() Class LJAIntegrationConfig
	Local cJobs					:= ""
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()		
	Local oSchedule				:= Nil
	Local oTarefas				:= Nil		
	Local oAgentes				:= Nil	
	Local lTarefaConfigurada	:= .F.
	Local lAgentConfigurado		:= .F.	
	Local cURL					:= ""
	Local cChannel				:= ""	
	Local oErrorHandler			:= Nil	 
	Local oIntegrator			:= Nil
	Local nCount				:= 0  
	Local cEAIWS				:= "" //Nome do WebService do novo EAI  
	Local oSchedule2			:= Nil
	Local oTarefas2				:= Nil   
	Local nCount2				:= 0
		
	Self:aPreRequisitesStatus := {} 	
	Self:lCancel := .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o Schedule estแ ativo e configurado.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cJobs := GetPvProfString( "ONSTART" , "JOBS" , "" , GetADV97() )
	If	"FWSCHDMANAG" $ cJobs .And.;
		"FWSCHDQUEUE" $ cJobs
		aAdd( Self:aPreRequisitesStatus, { .T., STR0001 , "" } ) // "Schedule ativo"
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0002 , STR0003 } )	// "Schedule inativo" "Utilize o boletim especํfico para configurar o Schedule."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se hแ tarefa para o EAI dessa empresa.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If !Self:lEAI20
		If FindFunction("FWCheckDic") .And. FWCheckDic( "_SCHDTSK", .T. )
			oSchedule := oLJCEntidadeFactory:Create( "_SCHDTSK" )
			
			oTarefas := oSchedule:Consultar(1)
			For nCount := 1 To oTarefas:Count()
				If	oTarefas:Elements(nCount):DadosGet( "TSK_EMP" ) == cEmpAnt .And.;
					AllTrim(oTarefas:Elements(nCount):DadosGet( "TSK_ROTINA" )) == "FWEAI"
					lTarefaConfigurada := .T.
					Exit
				EndIf			
			Next
			
			If lTarefaConfigurada
				aAdd( Self:aPreRequisitesStatus, { .T., STR0004 , "" } ) // "Tarefa do EAI configurada no Schedule"
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0005 , STR0006 } ) // "Tarefa do EAI nใo configurada no Schedule" "Utilize o boletim t้cnico do EAI para configurแ-lo corretamente."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0007 , STR0008 } ) // "Nใo foi possํvel abrir a tabela de tarefas do Schedule" "Utilize o boletim especํfico para configurar o Schedule."
		EndIf	
	Else 
	    //NOVO EAI, UTILIZA O NOVO SCHEDULE
		If FindFunction("FWCheckDic") .And. FWCheckDic( "XX1", .T. ) .And. FWCheckDic( "XX2", .T. )
		
			oSchedule := oLJCEntidadeFactory:Create( "XX1" ) 
			oSchedule2 := oLJCEntidadeFactory:Create( "XX2" )
			
			oTarefas := oSchedule:Consultar(1)
			For nCount := 1 To oTarefas:Count()

				 If	AllTrim(Upper(oTarefas:Elements(nCount):DadosGet( "XX1_ROTINA" ))) == "FWEAI"
					
						oSchedule2:DadosSet( "XX2_AGEND", oTarefas:Elements(nCount):DadosGet( "XX1_CODIGO" ) )		
						oTarefas2 := oSchedule2:Consultar(1)
						
						For nCount2 := 1 To oTarefas2:Count()
					    	If cEmpAnt $ AllTrim(oTarefas2:Elements(nCount2):DadosGet( "XX2_EMPFIL"))
					    						    		
					    		lTarefaConfigurada := .T.
					    		Exit
					    	EndIf
					    Next nCount2
					    
					    If lTarefaConfigurada
							Exit
						EndIf
				EndIf			
			Next
			
			If lTarefaConfigurada
				aAdd( Self:aPreRequisitesStatus, { .T., STR0004 , "" } ) // "Tarefa do EAI configurada no Schedule"
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0005 , STR0006 } ) // "Tarefa do EAI nใo configurada no Schedule" "Utilize o boletim t้cnico do EAI para configurแ-lo corretamente."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0007 , STR0008 } ) // "Nใo foi possํvel abrir a tabela de tarefas do Schedule" "Utilize o boletim especํfico para configurar o Schedule."
		EndIf		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se hแ agente para a tarefa do EAI.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If FindFunction("FWCheckDic") .And. FWCheckDic( "XX0", .T. )
		oSchedule := oLJCEntidadeFactory:Create( "XX0" )
		
		oAgentes := oSchedule:Consultar(1)
		For nCount := 1 To oAgentes:Count()
			If	oAgentes:Elements(nCount):DadosGet( "XX0_EMP" ) == cEmpAnt
				lAgentConfigurado := .T.
				Exit
			EndIf			
		Next
		
		If lAgentConfigurado
			aAdd( Self:aPreRequisitesStatus, { .T., STR0009 , "" } ) // "Agente do EAI configurado no Schedule"
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0010 , STR0011 } ) // "Agente do EAI nใo configurado no Schedule" "Utilize o boletim t้cnico do EAI para configurแ-lo corretamente."
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0012 , STR0013 } ) // "Nใo foi possํvel abrir a tabela de agentes do Schedule" "Utilize o boletim especํfico para configurar o Schedule."
	EndIf	

	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o EAI estแ configurado corretamente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
	
	If !Self:lEAI20
		cUrl := GetNewPar( "MV_EAIURL", "" )
		cChannel := GetNewPar( "MV_EAIPORT", "" )
		
		If !Empty(cUrl)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0014 , "" } ) // "URL de comunica็ใo com TOTVS ESB configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0015 , STR0016 } ) // "URL de comunica็ใo com TOTVS ESB nใo configurado." "Utilize o boletim t้cnico do EAI para configurแ-lo corretamente."
		EndIf
		
		If !Empty(cChannel)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0017 , "" } ) // "O channel de comunica็ใo com TOTVS ESB configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0018 , STR0019 } ) // "O channel de comunica็ใo com TOTVS ESB nใo configurado." "Utilize o boletim t้cnico do EAI para configurแ-lo corretamente."
		EndIf
	
	Else 
	
	
		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAฟ
		//ณVerifica os parโmetros minimos necessarios do novo EAI 2.0ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤAู
		ENDDOC*/      
		
		cUrl := GetNewPar( "MV_EAIURL2", "" )
		cEAIWS := GetNewPar( "MV_EAIWS", "" )              //Informe o nome do Client WebService do EAI para envio a outro EAI   
		
		If !Empty(cUrl)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0025 , "" } ) // "URL de comunica็ใo com TOTVS EAI configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0026 , "" } ) // "URL de comunica็ใo com TOTVS EAI nใo configurado." 
		EndIf
		
		If !Empty(cEAIWS)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0027 , "" } ) // "O Client WebService do EAI para envio a outro EAI configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 , "" } ) // "O Client WebService do EAI para envio a outro EAI nใo configurado."
		EndIf
			
		
	EndIf	
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	
	If !Self:lEAI20
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o EAI estแ conversando com o TOTVS ESB.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oErrorHandler := ErrorBlock( {|e| Break(e) } )
		Begin Sequence		           
			//FWEAI ChkSendChannel - verifica se o canal configurado existe no TOTVS ESB - ExistService.
			oIntegrator := FWEAI():New()                                                 
			oIntegrator:SetSendChannel(EAI_CHANNEL_ESB)
			If oIntegrator:ChkSendChannel()
				aAdd( Self:aPreRequisitesStatus, { .T., STR0020 , "" } ) // "O protheus estแ se comunicando com TOTVS ESB configurado."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0021 , STR0022 } ) // "O protheus nใo estแ se comunicando com TOTVS ESB configurado." "Verificar se os parโmetros do EAI estใo configurados corretamente."
			EndIf 
		Recover
			aAdd( Self:aPreRequisitesStatus, { .F., STR0023 , STR0024 } ) // "Nใo foi possํvel a tentativa de comunica็ใo com o TOTVS ESB." "Possivelmente faltam patchs a serem aplicados no sistema."
		End Sequence
		ErrorBlock(oErrorHandler)  
	Else   
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o EAI 2 estแ conversando com o TOTVS ESB.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oErrorHandler := ErrorBlock( {|e| Break(e) } )
		Begin Sequence		           
			//FWEAI ChkSendChannel - verifica se o canal configurado existe no TOTVS ESB - ExistService.
			oIntegrator := FWEAI():New()                                                 
			oIntegrator:DeActivate()  
	        oIntegrator:Read()
	        oIntegrator:Activate()		 
	        		
			If oIntegrator:nTrials <= 5
				aAdd( Self:aPreRequisitesStatus, { .T., STR0029 , "" } ) // "O protheus estแ se comunicando com TOTVS ESB configurado."
			ElseIf oIntegrator:cStatus <> TRANS_FAILED 
				aAdd( Self:aPreRequisitesStatus, { .T., STR0029 , "" } ) // "O protheus estแ se comunicando com TOTVS ESB configurado."		
			Else
			
				aAdd( Self:aPreRequisitesStatus, { .F., STR0030 , STR0022 } ) // "O protheus nใo estแ se comunicando com TOTVS ESB configurado." "Verificar se os parโmetros do EAI estใo configurados corretamente."
			EndIf 
		Recover
			aAdd( Self:aPreRequisitesStatus, { .F., STR0031  , STR0024 } ) // "Nใo foi possํvel a tentativa de comunica็ใo com o TOTVS ESB." "Possivelmente faltam patchs a serem aplicados no sistema."
		End Sequence
		ErrorBlock(oErrorHandler) 
	EndIf
		
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf  									
Return