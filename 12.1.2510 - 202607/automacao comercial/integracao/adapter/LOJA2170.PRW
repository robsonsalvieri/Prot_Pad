#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA2170.CH"

Function LOJA2170; Return  // "dummy" function - Internal Use 
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCRM             บAutor  ณVendas Clientes     บ Data ณ  14/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em configurar e validar a integra็ใo com o       บฑฑ
ฑฑบ          ณproduto RM da empresa TOTVS.			                              บฑฑ
ฑฑบ          ณEssa classe ้ herda a classe abstrata LJAIntegrationConfig.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCRM From LJAIntegrationConfig
	
	Data lConfigured                          
	Data lValidated
	Data aProcesses
	Data aTables	

	Method New()
	Method GetClassInterface()
	Method GetDisplayName()
	Method GetConfigurationText()
	Method Configure()
	Method Validate()
	Method GetEndText()
    
	//Metodos internos
	Method ConfProcs()
	Method ConfTabs()
	Method ConfParans()
	Method ConfInt()
	Method ValProcs()
	Method ValTabs()
	Method ValParans()
	Method ValConfig()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCBestSales.	                      บฑฑ
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
Method New() Class LJCRM
	
	_Super:New()
	
	Self:aPreRequisitesStatus	:= {}
	Self:cText					:= ""
	
	// Processos que devem ser cadastrados no MDO 
	Self:aProcesses :=	{										;
							{ "002", "CAD VENDEDOR"			}	,;
							{ "003", "CAD ESTACAO"		 	}	,;
							{ "005", "MAPA RESUMO"		 	}	,;
							{ "006", "CUPOM FISCAL"			}	,;
							{ "007", "SANGRIA"				}	,;
							{ "008", "SUPRIMENTO"			}	,;
							{ "016", "ITENS CF CANC"		}	;
						}
						
	// Tabelas que devem ser cadastradas no MDP
	Self:aTables :=	{						;
						{ "002", "SA3" }	,;
						{ "003", "SLG" }	,;
						{ "005", "SFI" }	,;
						{ "006", "SF2" }	,;
						{ "006", "SD2" }	,;
						{ "006", "SE1" }	,;
						{ "006", "SEF" }	,;
						{ "006", "SLX" }	,;						
						{ "007", "SE5" }	,;
						{ "008", "SE5" }	,;
						{ "016", "SLX" }	;
					}
								
	Self:lConfigured	:= .F.
	Self:lValidated		:= .F.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบMetodo    ณGetClassInterfaceบAutor  ณVendas Clientesบ Data ณ 27/03/09  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que retorna o nome da classe abstrata que a classe   บฑฑ
ฑฑบ          ณherda.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString: Interface que esta classe herda.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetClassInterface() Class LJCRM
Return "LJIIntegrationConfig"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบMetodo    ณGetDisplayName   บAutor  ณVendas Clientesบ Data ณ 27/03/09  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que retorna o nome da integra็ใo que esta classe     บฑฑ
ฑฑบ          ณrepresenta.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString: Nome da integra็ใo que esta classe representa.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDisplayName() Class LJCRM
Return "RM Nucleus"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณGetConfigurationTextบAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que retorna o texto com informa็๕es das configura็๕esบฑฑ
ฑฑบ          ณefetuadas por essa classe.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString: Texto com informa็๕es das configura็๕es efetuadas   บฑฑ
ฑฑบ          ณpor essa classe.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetConfigurationText() Class LJCRM
	Local cText		:= ""
	Local nCount	:= 0
	Local nProcess	:= 0
	
	cText += "<p>"
	cText += STR0001 //"Para criar automaticamente as configura็๕es bแsicas para o funcionamento da integra็ใo com a RM, clique no botใo 'Configurar'."
	cText += "<br>"
	cText += 	STR0002 //"As seguintes configura็๕es serใo efetuadas:"
	cText += 	"<ul>"
	cText += 		"<li> " + STR0003 + "</li>" //"Processos de integra็ใo:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aProcesses)
		cText += 			"<li>" + " " + Self:aProcesses[nCount][1] + " - " + Self:aProcesses[nCount][2] + "</li>"
	Next

	cText += 		"</ul>"		
	cText += 		"<li> " + STR0004 + "</li>" //"Tabelas dos processos de integra็ใo:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aTables)
		nProcess := aScan( Self:aProcesses, { |x| x[1] == Self:aTables[nCount][1] } )
		cText += 			"<li> " + STR0005 + ": " + Self:aTables[nCount][2] + If(nProcess > 0, " - " + STR0006 + ": " + Self:aProcesses[nProcess][1] + " - " + Self:aProcesses[nProcess][2],"") + "</li>" //"Tabela:" ; "Processo"
	Next

	cText += 		"</ul>"			
	cText += 		"<li> " + STR0007 + "</li>" //"Parโmetros:"
	cText += 		"<ul>"
	cText += 			"<li> " + "MV_LJGRINT " + STR0008 + "</li>" //"como .T. para a gera็ใo da integra็ใo"
	cText += 		"</ul>"		
	cText += 	"</ul>"
	cText += "</p>"	
	
Return cText

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณConfigure           บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que efetua as configura็๕es necessแrias para que essaบฑฑ
ฑฑบ          ณintegra็ใo funcione corretamente.                           บฑฑ
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
Method Configure() Class LJCRM
		
	Self:cText		:= ""
	Self:lCancel	:= .F.	
		
	//Cadastra os processos
	Self:ConfProcs()
	
	//Cadastra as tabelas dos processos
	Self:ConfTabs()
		
	//Configura os parโmetros
	Self:ConfParans()
	
	//Configuracao da integracao
	Self:ConfInt()

	Self:lConfigured	:= .T.					

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณValidate            บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que efetua a valida็ใo das configura็๕es necessแrias บฑฑ
ฑฑบ          ณpara que essa integra็ใo funcione corretamente.             บฑฑ
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
Method Validate() Class LJCRM 
	
	Self:lCancel 				:= .F.
	Self:aPreRequisitesStatus 	:= {}
	
	//Chama as valida็๕es gen้ricas de integra็ใo
	_Super:Validate()
	
	//Verifica se os processos estใo cadastrados
	Self:ValProcs()

	//Verifica se as tabelas dos processos estใo cadastrados
	Self:ValTabs()

	//Verifica se os parโmetros necessแrios estใo cadastrados
	Self:ValParans()
	
	//Verifica se as configura็oes da integra็ใo estใo cadastradas
	Self:ValConfig()
	
	Self:lValidated		:= .T.	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณGetEndText          บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณM้todo que retorna o texto de encerramento da configura็ใo  บฑฑ
ฑฑบ          ณe valida็ใo da integra็ใo.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณlLoaded := Se foi efetuada a carga inicial.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString: Texto de encerramento da configura็ใo e valida็ใo   บฑฑ
ฑฑบ          ณda integ.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetEndText( lLoaded ) Class LJCRM
	
	Local cText := ""
	
	cText += "<p>"
	cText += STR0009 //"A seguir um resumo das tarefas executadas:"
	cText += "<br>"		
	cText += 	"<ul>"
	cText += 		"<li>" + " " + STR0010 + " " + If( Self:lConfigured, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>"	//"Configura็ใo do sistema:" ; "Efetuado" ; "Nใo efetuado"
	cText += 		"<li>" + " " + STR0013 + " " + If( Self:lValidated, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>" //"Valida็ใo do sistema:" ; "Efetuado" ; "Nใo efetuado" 		
	cText += 		"<li>" + " " + STR0014 + " " + If( lLoaded, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>" //"Carga inicial:" ; "Efetuado" ; "Nใo efetuado" 		 			
	cText += 	"</ul>"	
	cText += "</p>"	

Return cText

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณConfProcs           บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณConfigura os processos da integracao  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfProcs() Class LJCRM

	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oProcessos			:= Nil
    
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )

	For nCount := 1 To Len(Self:aProcesses)
		
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )		
		
		If oProcessos:Consultar(1):Count() == 0
			oProcessos:DadosSet( "MDO_DESCRI", Self:aProcesses[nCount][2] )
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .T. )
					oProcessos:DadosSet( "MDO_HABEXC", .T. )
					oProcessos:DadosSet( "MDO_HABCAR", .T. )
					
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .F. )
					oProcessos:DadosSet( "MDO_HABEXC", .F. )
					oProcessos:DadosSet( "MDO_HABCAR", .F. )
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .F. )
					oProcessos:DadosSet( "MDO_HABEXC", .T. )
					oProcessos:DadosSet( "MDO_HABCAR", .F. )

			EndCase
			
			oProcessos:Incluir()
			
			Self:cText += STR0015 + " " + Self:aProcesses[nCount][1] + " - " +Self:aProcesses[nCount][2] + "<br>" //"Adicionado processo"
		Else
			Self:cText += STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0017 + ";" + "<br>" //"Processo" ; "jแ cadastrado"
		EndIf
		
		Self:Notify()
	Next

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณConfTabs            บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณConfigura as tabelas dos processos da integracao  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfTabs() Class LJCRM

	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oTabelas				:= Nil	
	
	oTabelas := oLJCEntidadeFactory:Create( "MDP" )
		
	For nCount := 1 To Len(Self:aTables)
		
		If Self:lCancel
			Exit
		EndIf		
		
		oTabelas:Limpar()
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )
		
		If oTabelas:Consultar(1):Count() == 0
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
					oTabelas:DadosSet( "MDP_HABILI", .T. )
					oTabelas:DadosSet( "MDP_HABCAR", .T. )
			    OtherWise
			    	oTabelas:DadosSet( "MDP_HABILI", .T. )
					oTabelas:DadosSet( "MDP_HABCAR", .F. )
			EndCase
			
			oTabelas:Incluir()
			
			Self:cText += STR0018 + " " + Self:aTables[nCount][2] + STR0019 + Self:aTables[nCount][1] + ";<br>" //"Adicionada tabela" ; " para o processo "
		Else
			Self:cText += STR0005 + " " + Self:aTables[nCount][2] + " " + STR0020 + Self:aTables[nCount][1] + ";<br>" //"Tabela" ; "jแ cadastrada para o processo "
		EndIf		
		
		Self:Notify()
	Next		

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณConfParans          บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณConfigura as tabelas dos processos da integracao  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Method ConfParans() Class LJCRM

	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oParametros			:= Nil
		
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )		
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	If oParametros:Consultar(1):Count() == 0
		oParametros:DadosSet( "X6_TIPO",  "L" )	
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Incluir()
		Self:cText += STR0021 + "MV_LJGRINT " + STR0022 + ";<br>" //"Adicionado parโmetro " ; "e configurado para .T."
	Else
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Alterar(1)
		Self:cText += STR0023 + " MV_LJGRINT " + STR0024 + ";<br>" //"Parโmetro" ; "configurado para .T."
	EndIf
	
	Self:Notify()	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณConfInt             บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณCadastra a configuracao da integracao  		  			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfInt() Class LJCRM

	Local oEntConfInt := Nil
	
	oEntConfInt := LJCEntParamInt():New()
	
	oEntConfInt:DadosSet("MDQ_CODIGO", "001")	

	If oEntConfInt:Consultar(1):Count() == 0
			
		oEntConfInt:Incluir()
			
		Self:cText += STR0025 + ";<br>" //"Adicionada configura็ใo da integra็ใo (Tabela - MDQ)
	Else
		Self:cText += STR0026 + ";<br>" //"Configura็ใo da integra็ใo jแ cadastrado (Tabela - MDQ)
	EndIf		
		
	Self:Notify()
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณValProcs            บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณValida os processos da integracao  					  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValProcs() Class LJCRM

	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oProcessos			:= Nil
	Local oRegistros			:= Nil	
	
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )
	
	For nCount := 1 To Len(Self:aProcesses)
		
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )
		oRegistros := oProcessos:Consultar(1)
		
		If oRegistros:Count() > 0 
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABALT" )	.AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABEXC" )	.AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABCAR" )
					    			
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclusใo."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0030 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja habilitado para inclusใo, altera็ใo, exclusใo e carga inicial."
					EndIf
															
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" )			
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclusใo."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0031 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja habilitado para inclusใo."
					EndIf
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABEXC" )			
						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclusใo."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0032 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja habilitado para inclusใo e exclusใo."
					EndIf
					
			EndCase
			
		Else
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0030 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja habilitado para inclusใo, altera็ใo, exclusใo e carga inicial."			
										
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0033 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja cadastrado e habilitado para inclusใo."
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0034 } ) //"Processo" ; "nใo cadastrado corretamente." ; "ษ necessแrio que o processo" ; "esteja cadastrado e habilitado para inclusใo e exclusใo."
					
			EndCase

		EndIf
				
		Self:Notify()
	Next

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณValTabs             บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณvalida as tabelas dos processos da integracao  		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValTabs() Class LJCRM

	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oTabelas				:= Nil			
	
	oTabelas := oLJCEntidadeFactory:Create( "MDP" )	
	
	For nCount := 1 To Len(Self:aTables)
		
		If Self:lCancel
			Exit
		EndIf		
	
		oTabelas:Limpar()
		
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )		
        
		oRegistros := oTabelas:Consultar(1)
		
		If oRegistros:Count() > 0
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
						
					If oRegistros:Elements(1):DadosGet( "MDP_HABILI" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDP_HABCAR" )
						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0035 , "" } ) //"Tabela" ; "cadastrada corretamente."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0038 + Self:aTables[nCount][1] } ) //"Tabela" ; "nใo cadastrada corretamente." ; "ษ necessแrio que a tabela"; "esteja habilitada e carga inicial configurada para o processo "
					EndIf
					
				Case Self:aTables[nCount][1] == "005" .OR. ;
				     Self:aTables[nCount][1] == "007" .OR. ;
				     Self:aTables[nCount][1] == "008" .OR. ;
					 Self:aTables[nCount][1] == "006" .OR. ;
					 Self:aTables[nCount][1] == "016"
					
					If oRegistros:Elements(1):DadosGet( "MDP_HABILI" )						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0035 , "" } )//"Tabela" ; "cadastrada corretamente."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0039 + Self:aTables[nCount][1] } ) //"Tabela" ; "nใo cadastrada corretamente." ; "ษ necessแrio que a tabela"; "esteja habilitada para o processo "
					EndIf
					
			EndCase
		
		Else
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0038 + Self:aTables[nCount][1] } ) //"Tabela" ; "nใo cadastrada corretamente." ; "ษ necessแrio que a tabela"; "esteja habilitada e carga inicial configurada para o processo "
					
				Case Self:aTables[nCount][1] == "005" .OR. ;
				     Self:aTables[nCount][1] == "007" .OR. ;
				     Self:aTables[nCount][1] == "008" .OR. ;
					 Self:aTables[nCount][1] == "006" .OR. ;
					 Self:aTables[nCount][1] == "016"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0039 + Self:aTables[nCount][1] } )//"Tabela" ; "nใo cadastrada corretamente." ; "ษ necessแrio que a tabela"; "esteja habilitada para o processo "
					
			EndCase
		
		EndIf		
		
		Self:Notify()
	Next		

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณValParans           บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณValida as tabelas dos processos da integracao  		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Method ValParans() Class LJCRM

	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oParametros			:= Nil
	
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )	
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	oRegistros := oParametros:Consultar(1)
	
	If oRegistros:Count() > 0
		If GetNewPar("MV_LJGRINT")
			aAdd( Self:aPreRequisitesStatus, { .T., STR0023 + " MV_LJGRINT " + STR0040 , "" } ) //"Parโmetro" ; "configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0023 + " MV_LJGRINT " + STR0041 , STR0042 } )//"Parโmetro" ; "nใo configurado corretamente."; "Configurar o parโmetro para verdadeiro."		
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0023 + " MV_LJGRINT " + STR0041 , STR0043 } )//"Parโmetro" ; "nใo configurado corretamente."; "Criar o parโmetro e configurแ-lo para verdadeiro."			
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออัอออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบMetodo    ณValConfig           บAutorณVendas Clientesบ Data ณ 27/03/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออฯอออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณValida as configuracoes da integracao (MDQ)	  		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Method ValConfig() Class LJCRM

	Local oEntConfInt			:= Nil	
	Local oRegistros			:= Nil
	
	oEntConfInt := LJCEntParamInt():New()
	
	oEntConfInt:DadosSet("MDQ_CODIGO", "001")	
	
	oRegistros := oEntConfInt:Consultar(1)
	
	If oRegistros:Count() == 0
		aAdd( Self:aPreRequisitesStatus, { .F., STR0044 , STR0045 } )	//"As configura็๕es da integra็ใo nใo estใo cadastradas (Tabela MDQ)." ; "Por favor, verificar."
	Else
		aAdd( Self:aPreRequisitesStatus, { .T., STR0046 , ""} )//"A configuracao da integra็ใo esta corretamente cadastrada (Tabela MDQ)."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf

Return Nil