#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"   
 
PUBLISH MODEL REST NAME CRMA980MEX

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980MEX
Cadastro de clientes para localização México.
@param		Ninguno
@return	    Nil
@author 	Luis Enríquez
@version	12.1.2210 / Superior
@since		12/07/2023 
/*/
//-------------------------------------------------------------------
Function CRMA980MEX()
	Local oMBrowse	:= BrowseDef()
	
	Private aRotina	:= MenuDef()
	
	//------------------------------------------------------------
	// Variaveis serão mantidas até descontinuar o fonte MATA030
	// devido o uso nas validações de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se é rotina automática
	
	oMBrowse:SetMenuDef("CRMA980MEX")
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configurações do browse de clientes para localização México.
@param		Ninguno
@return	    oMBrowse - Objeto de Browse de CRMA980
@author 	Luis Enríquez
@version	12.1.2210 / Superior
@since		12/07/2023 
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oMBrowse := FWLoadBrw("CRMA980")
Return oMBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de clientes para localização México.
@param		Ninguno
@return	    oModel - Objeto del Modelo de CRMA980
@author 	Luis Enríquez
@version	12.1.2210 / Superior
@since		12/07/2023 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 	 := FWLoadModel("CRMA980")
	Local lFoundAIT	 := FwSX2Util():SeekX2File( "AIT" )
	Local oStructAIT := Nil
	
	If lFoundAIT
		oStructAIT := FWFormStruct(1,"AIT",/*bAvalCampo*/,/*lViewUsado*/)
		oModel:AddGrid("AITCHILD","SA1MASTER",oStructAIT,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
		oModel:SetRelation("AITCHILD",{{"AIT_FILIAL", "xFilial('AIT')"},{"AIT_CODCLI","A1_COD"},{"AIT_LOJA","A1_LOJA"}},AIT->( IndexKey( 1 ) ))
		oModel:GetModel("AITCHILD"):SetOptional(.T.)
	EndIf
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localização México.
@param		Ninguno
@return     oView - Objeto de la Vista de CRMA980
@author 	Luis Enríquez
@version	12.1.2210 / Superior
@since		12/07/2023 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWLoadView("CRMA980")
	If FindFunction("FATXMI980")
		FATXMI980(oView)
	EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localização México.
@param		Ninguno
@return	    aRotina - Arreglo con Menú de CRMA980 
@author 	Luis Enríquez
@version	12.1.2210 / Superior
@since		12/07/2023 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FWLoadMenuDef("CRMA980")
Return aRotina 
