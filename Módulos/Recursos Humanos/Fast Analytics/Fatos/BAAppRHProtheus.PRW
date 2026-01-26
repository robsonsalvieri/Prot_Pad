#INCLUDE "BADefApp.CH"

NEW APP Recursos_Humanos

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppRHProtheus
Modelagem para Protheus Recursos Humanos.
 
@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAAppRHProtheus
    Data cApp
 
    Method Init() CONSTRUCTOR
    Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome único para a área.
 
@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppRHProtheus
    ::cApp := "Recursos_Humanos"
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensões) disponíveis da área, deve ser
necessariamente o nome das classes das entidades.
 
@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppRHProtheus
Return  { + ;
 			"EMPRESA",			+ ;
 			"FILIAL",			+ ;
  			"CENTROCUSTO",		+ ;
 			"ITEMCONTABIL",		+ ;
  			"CLASSEVALOR",		+ ;
            "Funcionarios", 	+ ;
            "TURNO", 			+ ;
            "Departamentos", 	+ ;
            "Cargo", 			+ ;   
            "Funcao",		 	+ ;
            "TipoAusencias", 	+ ;
 			"CatFunc", 			+;
 			"EstCivl", 			+;
  			"Grinrai", 			+;
 			"RoteirosCalculo", 	+ ;
 			"HistSalarial", 	+ ;
            "Verbas", 			+ ;
            "FuncProcessos", 	+ ; 
            "Periodos", 		+ ; 
            "Eventos", 			+ ;
            "Afastados", 		+ ;
            "AtrasosPonto", 	+ ;
            "FaltasPonto",  	+ ; 
            "BancoDeHoras", 	+ ;
            "DescFerias", 		+ ;
            "ProvFerias", 		+ ;
            "BaseFerias", 		+ ;
            "SitFol",			+ ;
            "DescFolha",	 	+ ;
            "BaseFolha", 		+ ;
            "ProvFolha",	 	+ ;
            "HrTrabPonto",  	+ ;
            "HeTrabPonto", 		+ ;
            "Ativos",	        + ;	
            "Admitidos",        + ;	
            "Demitidos"	          }

            


