#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA401.CH"

/*/{Protheus.doc} GTPA401
Função paleativa para chamada do cadastro de veículos dentro do gtp
@type  Function
@author user
@since 11/01/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA401()
    
    Local oBrowse
    //Filtro Browse
	Local cFiltro	:= ""
    
    If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

	    cFiltro	:= "ST9->T9_CATBEM $ '24'"
        //Initializes Browse
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("ST9")
        oBrowse:SetDescription( STR0001 )
        oBrowse:SetFilterDefault( cFiltro )
        oBrowse:SetMenuDef("MNTA084")
        GA401LEG(oBrowse)
        oBrowse:Activate()
    
   EndIf 
   
Return() 


//------------------------------------------------------------------------------
/*/{Protheus.doc} GA401LEG
Caption Browse

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Function GA401LEG( oBrowse )

	oBrowse:AddLegend("ST9->T9_SITBEM == 'A' .And. ST9->T9_SITMAN = 'A'","BR_VERDE"   ,STR0008) //"Bem Ativo Manutenção Ativo"
	oBrowse:AddLegend("ST9->T9_SITBEM == 'A' .And. ST9->T9_SITMAN = 'I'","BR_AMARELO" ,STR0009) //"Bem Ativo Manutenção Inativo"
	oBrowse:AddLegend("ST9->T9_SITBEM == 'I' .And. ST9->T9_SITMAN = 'A'",'BR_AZUL'    ,STR0010) //"Bem Inativo Manutenção Ativo"
	oBrowse:AddLegend("ST9->T9_SITBEM == 'I' .And. ST9->T9_SITMAN = 'I'",'BR_VERMELHO',STR0011) //"Bem Inativo Manutenção Inativo"
	oBrowse:AddLegend("ST9->T9_SITBEM == 'T'"                           ,'BR_CINZA'   ,STR0012) //"Bem Transferido"

Return
