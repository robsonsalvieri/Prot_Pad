#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMcMoB7Z
Classes para geracao de registros de eventos B7Z para casos de teste

@author renan.almeida
@since 24/12/19
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenMcMoB7Z
    
    Data aEventos as Array

    Method New() Constructor
    Method gerRegist()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@author renan.almeida
@since 24/12/19
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class CenMcMoB7Z
  	    
                       //B7Z_CODTAB  - B7Z_CODPRO  - B7Z_FORENV  - B7Z_CODGRU  - B7Z_TIPEVE
    self:aEventos := {{'22'           ,'10101012'   ,'1'          ,''           ,'0'},;
	                  {'22'           ,'40303136'   ,'1'          ,''           ,'0'},;
	                  {'22'           ,'20010010'   ,'1'          ,''           ,'0'},;
	                  {'18'           ,'60000015'   ,'2'          ,'031'        ,'4'},;
	                  {'18'           ,'60000031'   ,'2'          ,'031'        ,'4'},;
	                  {'18'           ,'60000023'   ,'2'          ,'031'        ,'4'},;
	                  {'19'           ,'70000034'   ,'1'          ,''           ,'5'},;
	                  {'20'           ,'90018338'   ,'1'          ,''           ,'2'},;
	                  {'18'           ,'60018038'   ,'1'          ,''           ,'3'},;
	                  {'19'           ,'70704163'   ,'1'          ,''           ,'1'} }
Return self          



//-------------------------------------------------------------------
/*/{Protheus.doc} gerRegist
Gera os registros no Alias B7Z

@author renan.almeida
@since 24/12/19
@version 1.0
/*/
//-------------------------------------------------------------------
Method gerRegist() Class CenMcMoB7Z
    
    Local nX := 0

	for nX := 1 to len(self:aEventos)
		oCltB7Z := CenCltB7Z():New()
		oCltB7Z:setValue("tableCode"       ,self:aEventos[nX,1]) //B7Z_CODTAB
		oCltB7Z:setValue("procedureCode"   ,self:aEventos[nX,2]) //B7Z_CODPRO
		oCltB7Z:setValue("submissionMethod",self:aEventos[nX,3]) //B7Z_FORENV
		oCltB7Z:setValue("procedureGroup"  ,self:aEventos[nX,4]) //B7Z_CODGRU
		oCltB7Z:setValue("eventType"       ,self:aEventos[nX,5]) //B7Z_TIPEVE
		
		if !oCltB7Z:bscChaPrim()
			oCltB7Z:insert()				
		endIf
		oCltB7Z:destroy()
	next

Return