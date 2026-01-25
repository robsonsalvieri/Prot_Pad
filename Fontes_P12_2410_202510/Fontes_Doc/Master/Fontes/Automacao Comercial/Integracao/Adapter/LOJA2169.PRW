#INCLUDE "PROTHEUS.CH"                              
#INCLUDE "LOJA2169.CH"
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCBestSales      บAutor  ณVendas Clientes     บ Data ณ  28/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em configurar e validar a integra็ใo com o       บฑฑ
ฑฑบ          ณproduto BestSales da empresa Criterium.                             บฑฑ
ฑฑบ          ณEssa classe ้ herda a classe abstrata LJAIntegrationConfig.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCBestSales From LJAIntegrationConfig
	Data aCamposObrigatorios
	Data aCamposNumericos
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
Method New() Class LJCBestSales
	_Super:New()
	Self:aPreRequisitesStatus	:= {}
	Self:cText					:= ""
	
	// Processos que devem ser cadastrados no MDO 
	Self:aProcesses :=	{										;
		 					{ "001", STR0001	}	,;	// "Clientes"
							{ "002", STR0002	}	,;	// "Vendedores"
							{ "017", STR0003	}	,;	// "Tabelas gen้ricas"
							{ "018", STR0004	}	,;	// "Grupo de produtos"
							{ "019", STR0005	}	,;	// "Cab. tabela de pre็o"
							{ "020", STR0006	}	,;	// "Itens tabela de pre็o"
							{ "021", STR0007	}	,;	// "Condi็๕es de pagamento"
							{ "024", STR0008	}	,;	// "Empresas e filiais"
							{ "025", STR0009	}	;	// "Produtos e Grupo"
						}
						
	// Tabelas que devem ser cadastradas no MDP
	Self:aTables	:=	{						;
							{ "001", "SA1" }	,;
							{ "002", "SA3" }	,;
							{ "017", "SX5" }	,;
							{ "018", "SBM" }	,;
							{ "019", "DA0" }	,;
							{ "020", "DA1" }	,;
							{ "021", "SE4" }	,;
							{ "024", "SM0" }	,;
							{ "025", "SB1" }	,;
							{ "025", "SBM" }	;														
						}
							
	// Campos que devem estar configurados como obrigat๓rios
	Self:aCamposObrigatorios :=	{					;
									"A1_COD"		,;
									"A1_NOME"		,;
									"A1_CGC"		,;
									"A1_MSBLQL"		,;									
									"A1_COND"		,;
									"A1_TABELA"		,;
									"A1_END"		,;
									"A1_BAIRRO"		,;
									"A1_MUN"		,;
									"A1_EST"		,;
									"A1_CEP"		,;
									"A1_CLASSE"		,;
									"A1_VEND"		,;
									"B1_COD"		,;
									"B1_GRUPO"		,;
									"B1_SITPROD"	,;
									"B1_ATIVO"		,;
									"B1_DESC"		,;
									"B1_UM"			,;
									"B1_SEGUM"		,;
									"B1_LM"			,;
									"B1_LE"			,;
									"BM_GRUPO"		,;
									"BM_TIPGRU"		,;
									"BM_DESC"		,;
									"DA0_CODTAB"	,;
									"DA0_DESCRI"	,;
									"DA0_DATDE"		,;
									"DA0_DATATE"	,;
									"DA0_HORADE"	,;
									"DA0_HORATE"	,;
									"DA1_CODPRO"	,;
									"DA1_CODTAB"	,;
									"DA1_PRCVEN"	,;
									"B2_COD"		,;
									"A3_NREDUZ"		,;
									"A3_SENHA"		,;
									"E4_CODIGO"		,;
									"E4_DESCRI"		,;
									"E4_COND"		,;
									"A4_COD"		,;
									"A4_NOME"		;
								}
									
	// Campos que devem estar configurados como num้ricos
	Self:aCamposNumericos :=	{					;
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
Method GetClassInterface() Class LJCBestSales
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
Method GetDisplayName() Class LJCBestSales
Return "Criterium - Best Sales"

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
Method GetConfigurationText() Class LJCBestSales
	Local cText		:= ""
	Local nCount	:= 0
	Local nProcess	:= 0
	
	cText += "<p>"
	cText += STR0010 // "Para criar automaticamente as configura็๕es bแsicas para o funcionamento da integra็ใo com a BestSales, clique no botใo 'Configurar'."
	cText += "<br>"
	cText += 	STR0011 // "As seguintes configura็๕es serใo efetuadas:"
	cText += 	"<ul>"
	cText += 		"<li> " + STR0012 + "</li>" // "Processos de integra็ใo:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aProcesses)
		cText += 			"<li>" + " " + Self:aProcesses[nCount][1] + " - " + Self:aProcesses[nCount][2] + "</li>"
	Next

	cText += 		"</ul>"		
	cText += 		"<li> " + STR0013 + "</li>" // "Tabelas dos processos de integra็ใo:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aTables)
		nProcess := aScan( Self:aProcesses, { |x| x[1] == Self:aTables[nCount][1] } )
		cText += 			"<li> " + STR0014 + " " + Self:aTables[nCount][2] + If(nProcess > 0, " - " + STR0015 + " " + Self:aProcesses[nProcess][1] + " - " + Self:aProcesses[nProcess][2],"") + "</li>" // "Tabela:" "Processo:"
	Next

	cText += 		"</ul>"			
	cText += 		"<li> " + STR0016 + "</li>" // "Parโmetros:"
	cText += 		"<ul>"
	cText += 			"<li> " + STR0017 + "</li>" // "MV_LJGRINT como .T. para a gera็ใo da integra็ใo"
	cText += 		"</ul>"		
	cText += 		"<li> " + STR0018 + "</li>" // "Obrigatoriedade dos sequintes campos:"
	cText += 		"<ul>"
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		cText += 			"<li> " + Self:aCamposObrigatorios[nCount] + "</li>"
	Next
	cText += 		"</ul>"			
	cText += 		"<li> " + STR0019 + "</li>" // "Picture dos sequintes campos:"
	cText += 		"<ul>"
	For nCount := 1 To Len( Self:aCamposNumericos )
		cText += 			"<li>" + " " + Self:aCamposNumericos[nCount] + "</li>"
	Next	
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
Method Configure() Class LJCBestSales
	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oCampos				:= Nil
	Local oParametros			:= Nil
	Local oProcessos			:= Nil
	Local oTabelas				:= Nil	
	
	Self:cText		:= ""
	Self:lCancel	:= .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCadastra os processos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCount := 1 To Len(Self:aProcesses)
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos := oLJCEntidadeFactory:Create( "MDO" )
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )		
		If oProcessos:Consultar(1):Count() == 0
			oProcessos:DadosSet( "MDO_DESCRI", Self:aProcesses[nCount][2] )
			oProcessos:DadosSet( "MDO_HABINC", .T. )
			oProcessos:DadosSet( "MDO_HABALT", .T. )
			oProcessos:DadosSet( "MDO_HABEXC", .T. )
			oProcessos:DadosSet( "MDO_HABCAR", .T. )
			oProcessos:Incluir()
			Self:cText += STR0020 + " " + Self:aProcesses[nCount][1] + " - " +Self:aProcesses[nCount][2] + "<br>" // "Adicionado processo"
		Else
			Self:cText += STR0021 + " " + Self:aProcesses[nCount][1] + " " + STR0022 + ";" + "<br>" // "Processo" "jแ cadastrado"
		EndIf
		
		Self:Notify()
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCadastra as tabelas dos processos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCount := 1 To Len(Self:aTables)
		If Self:lCancel
			Exit
		EndIf		
	
		oTabelas := oLJCEntidadeFactory:Create( "MDP" )
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )
		If oTabelas:Consultar(1):Count() == 0
			oTabelas:DadosSet( "MDP_HABILI", .T. )
			oTabelas:DadosSet( "MDP_HABCAR", .T. )
			oTabelas:Incluir()
			Self:cText += STR0023 + " " + Self:aTables[nCount][1] + ";<br>" // "Adicionada tabela"
		Else
			Self:cText += STR0024 + " " + Self:aTables[nCount][1] + " " + STR0025 + "<br>" // "Tabela" "jแ cadastrada;"
		EndIf		
		
		Self:Notify()
	Next	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfigura os parโmetros.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )		
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	If oParametros:Consultar(1):Count() == 0
		oParametros:DadosSet( "X6_TIPO",  "L" )
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Incluir()
		Self:cText += STR0026 + ";<br>" // "Adicionado parโmetro " + "MV_LJGRINT e configurado para .T."
	Else
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Alterar(1)
		Self:cText += STR0027 + ";<br>" // "Parโmetro MV_LJGRINT configurado para .T."
	EndIf			
	
	Self:Notify()		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfigura a obrigatoriedade dos campos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oCampos := oLJCEntidadeFactory:Create( "SX3" )
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposObrigatorios[nCount] )
		
		If oCampos:Consultar(2):Count() > 0
			oCampos:DadosSet( "X3_OBRIGAT", "€" )
			oCampos:Alterar(2)
			Self:cText += STR0028 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0029 + ";<br>" // "Campo" "configurado como obrigat๓rio."
		EndIf
	Next
	
	Self:Notify() 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfigura a picture dos campos chave.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oCampos := oLJCEntidadeFactory:Create( "SX3" )
	For nCount := 1 To Len( Self:aCamposNumericos )
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposNumericos[nCount] )
		
		If oCampos:Consultar(2):Count() > 0
			oCampos:DadosSet( "X3_PICTURE", "@9" )
			oCampos:Alterar(2)
			Self:cText += STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0030 + ";<br>" // "Campo" "configurado com picture num้rica."
		EndIf
	Next
	
	Self:Notify()
	
	Self:lConfigured	:= .T.					
Return

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
Method Validate() Class LJCBestSales 
	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oTabelaGenerica		:= Nil
	Local cPicture				:= ""
	Local lOnlyNumeric			:= .T.
	Local oGlobal				:= Nil
	Local oProcessos			:= Nil
	Local oTabelas				:= Nil		
	
	Self:lCancel := .F.
	Self:aPreRequisitesStatus := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณChama as valida็๕es gen้ricas de integra็ใo.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_Super:Validate()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se os processos estใo cadastrados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )
	For nCount := 1 To Len(Self:aProcesses)
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )
		oRegistros := oProcessos:Consultar(1)
		
		If oRegistros:Count() > 0 
			If oRegistros:Elements(1):DadosGet( "MDO_HABINC" )			
				aAdd( Self:aPreRequisitesStatus, { .T., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0032 , "" } ) // "Processo" "cadastrado corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0033 , STR0034 + " " + Self:aProcesses[nCount][1] + " " + STR0035 } ) // "Processo" "nใo cadastrado corretamente." "ษ necessแrio que o processo" "esteja habilitado para inclusใo."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0033 , STR0034 + " " + Self:aProcesses[nCount][1] + " " + STR0035 } ) // "Processo" "nใo cadastrado corretamente." "ษ necessแrio que o processo"
		EndIf
				
		Self:Notify()
	Next

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se as tabelas dos processos estใo cadastrados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
			If oRegistros:Elements(1):DadosGet( "MDP_HABILI" ) .And. oRegistros:Elements(1):DadosGet( "MDP_HABCAR" )
				aAdd( Self:aPreRequisitesStatus, { .T., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0037 , "" } ) // "Tabela" "cadastrada corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0038 , STR0039 + " " + Self:aTables[nCount][1] + " " + STR0040 } ) // "Tabela" "nใo cadastrada corretamente." "ษ necessแrio que a tabela" "esteja habilitada para inclusใo e carga."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0038 , STR0039 + " " + Self:aTables[nCount][1] + " " + STR0041 } ) // "Tabela" "nใo cadastrada corretamente." "ษ necessแrio que a tabela" "esteja cadastrada, habilitada para inclusใo e carga."
		EndIf		
		
		Self:Notify()
	Next	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se os parโmetros necessแrios estใo cadastrados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )	
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	oRegistros := oParametros:Consultar(1)
	
	If oRegistros:Count() > 0
		If GetNewPar("MV_LJGRINT")
			aAdd( Self:aPreRequisitesStatus, { .T., STR0042 , "" } ) // "Parโmetro MV_LJGRINT configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0043 , STR0044 } ) // "Parโmetro MV_LJGRINT nใo configurado corretamente." "Configurar o parโmetro para verdadeiro."
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0043 , STR0045 } ) // "Parโmetro MV_LJGRINT nใo configurado corretamente." "Criar o parโmetro e configurแ-lo para verdadeiro."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se os campos obrigat๓rios, estใo configurados corretmante.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		If Self:lCancel
			Exit
		EndIf	
	
		If X3Obrigat( Self:aCamposObrigatorios[nCount] )
			aAdd( Self:aPreRequisitesStatus, { .T., STR0028  + " " + Self:aCamposObrigatorios[nCount] + " " + STR0046 , "" } ) // "Campo" "configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0047 , STR0048 } ) // "Campo"  "nใo configurado corretamente." "Configure o campo como obrigat๓rio."
		EndIf
	Next
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se as chaves da tabela SX5 tem conte๚do para exporta็ใo.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oTabelaGenerica := oLJCEntidadeFactory:Create( "SX5" )
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "V0" )		
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0049 , "" } ) // "Tabela SX5 V0 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0050 , STR0051 } ) // "Tabela SX5 V0 sem items." "Cadastrar os itens bแsicos da tabela SX5 V0."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "T2" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0052 , "" } ) // "Tabela SX5 T2 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0053 , STR0054 } ) // "Tabela SX5 T2 sem items." "Cadastrar os itens bแsicos da tabela SX5 T2."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf		      
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "24" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0055 , "" } ) // "Tabela SX5 24 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0056 , STR0057 } ) // "Tabela SX5 24 sem items." "Cadastrar os itens bแsicos da tabela SX5 24."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "12" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0058 , "" } ) // "Tabela SX5 12 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0059 , STR0060 } ) // "Tabela SX5 12 sem items." "Cadastrar os itens bแsicos da tabela SX5 12."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se os campos que devem receber somente n๚mero, estใo configurados corretamente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oCampos := oLJCEntidadeFactory:Create( "SX3" )

	For nCount := 1 To Len( Self:aCamposNumericos )
		If Self:lCancel
			Exit
		EndIf	
	
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposNumericos[nCount] )
		oRegistros := oCampos:Consultar(2)
		If oRegistros:Count() > 0
			cPicture := oRegistros:Elements(1):DadosGet( "X3_PICTURE" )
			If AllTrim(cPicture) == Replicate( "9", oRegistros:Elements(1):DadosGet( "X3_TAMANHO" ) ) .Or. AllTrim(cPicture) == "@9"
				aAdd( Self:aPreRequisitesStatus, { .T., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0061 , "" } )	// "Campo" "configurado corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0062 , STR0063 + " (Picture:" + " " + Replicate( "9", oRegistros:Elements(1):DadosGet( "X3_TAMANHO" ) ) + " " + STR0064 + " @9)." } )	// "Campo" "nใo configurado corretamente." "ou"
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0065 , STR0066 } )			// "Campo" "nใo existe no dicionแrio de dados." "Adicione o campo ao dicionแrio."
		EndIf
	Next
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se os campos da tabela SX5 V0 e T2 estใo somente com n๚meros.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oTabelaGenerica := oLJCEntidadeFactory:Create( "SX5" )
	oGlobal := LJCGlobal():Global()
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "V0" )		
	oRegistros := oTabelaGenerica:Consultar(1)	
	For nCount := 1 To oRegistros:Count()
		If !oGlobal:Funcoes():IsNumeric(oRegistros:Elements(nCount):DadosGet( "X5_CHAVE"))
			lOnlyNumeric := .F.		
		EndIf
	Next	
	
	If lOnlyNumeric
		aAdd( Self:aPreRequisitesStatus, { .T., STR0067 , "" } )	// "Tabela SX5 V0 s๓ tem registros com chave n๚merica."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0068 , STR0069 } ) // "Tabela SX5 V0 nใo tem somente registros com chave n๚merica." "Configure os registros da tabela SX5 V0 com chave ๚nica num้rica."
	EndIf
	
	lOnlyNumeric := .T. 
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "T2" )		
	oRegistros := oTabelaGenerica:Consultar(1)	
	For nCount := 1 To oRegistros:Count()
		If !oGlobal:Funcoes():IsNumeric(oRegistros:Elements(nCount):DadosGet( "X5_CHAVE"))
			lOnlyNumeric := .F.		
		EndIf
	Next	
	
	If lOnlyNumeric
		aAdd( Self:aPreRequisitesStatus, { .T., STR0070 , "" } )  //	"Tabela SX5 T2 s๓ tem registros com chave n๚merica."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0071 , STR0072 } ) // "Tabela SX5 T2 nใo tem somente registros com chave n๚merica." "Configure os registros da tabela SX5 T2 com chave ๚nica num้rica."
	EndIf	
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
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
Method GetEndText( lLoaded ) Class LJCBestSales
	Local cText := ""
	
	cText += "<p>"
	cText += STR0073 // "A seguir um resumo das tarefas executadas:"
	cText += "<br>"		
	cText += 	"<ul>"
	cText += 		"<li>" + " " + STR0074 + " " + If( Self:lConfigured, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>"	// "Configura็ใo do sistema:" "Efetuado" "Nใo efetuado"
	cText += 		"<li>" + " " + STR0077 + " " + If( Self:lValidated, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>" // "Valida็ใo do sistema:" "Efetuado" "Nใo efetuado"
	cText += 		"<li>" + " " + STR0078 + " " + If( lLoaded, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>" // "Carga inicial:" "Efetuado" "Nใo efetuado"
	cText += 	"</ul>"	
	cText += "</p>"	
Return cText