#INCLUDE "BADEFINITION.CH"

NEW APP RENTAL   
   
//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppRental
Modelagem da area do Rental. 
Atualizar Fontes
@author  Djalma Mathias da Silva
@author  Djalma.Mathias  
@since   24/08/2022  
/*/    
//-------------------------------------------------------------------
Class BAAppRental      
	Data cApp  
 
	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome unico para a area. 

@author  Djalma Mathias da Silva
@author  Djalma.Mathias
@since   24/08/2022 
/*/ 
//-------------------------------------------------------------------
Method Init() Class BAAppRental 
	::cApp := "Rental" 
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  Djalma Mathias da Silva
@author  Djalma.Mathias
@since   24/08/2022    
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppRental
Return	{   "FILIAL", + ;			// Dimensao BAFilial
			"EMPRESA", +;			// Dimensao BAEmpresa 
			"XCONTRENTAL", + ; 	// Fato 	BAContrRental
			"ULTMOVRENTAL", + ; 	// Fato 	BAUltMovRental
			"CTBEMRENTAL", + ; 		// Fato 	BACtBemRental 			
			"CADBEMRENTAL", + ; 	// Dimensao BACadBemRental
			"CDCLIENTRENTAL", + ; 	// Dimensao BAClienteRental
			"CNDPGTORENTAL", + ; 	// Dimensao BACNDPGTORENTAL 
			"FAMIBEMRENTAL", + ; 	// Dimensao BAFamiBemRental  
			"CADBENSRENTAL", + ; 	// Dimensao BALocProjRental 
			"OBRASRENTAL", + ; 		// Dimensao BAObrasRental
			"PROSPECTRENTAL", + ; 	// Dimensao BAPROSPRENTAL   
			"REGIAORENTAL", + ; 	// Dimensao BARegiaoRental
			"STATBEMRENTAL", + ; 	// Dimensao BASTATBEMRENTAL
			"CADVENDRENTAL", + ;	// Dimensao VENDEDORRENTAL   
			"FILIALRENTAL" }		// Dimensao BAFilialRental  
			
