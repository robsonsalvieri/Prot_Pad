#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
 
//--------------------------------------------------------------------
/*/ {Protheus.doc} PLIncRestModel
Publicação dos modelos de inclusão de beneficiário que ficaram disponíveis 
no REST.

@author Vinicius Queiros Teixeira
@since 11/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Class PLIncRestModel From FwRestModel

    Method SetFilter(cFilter)
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter
Método responsável por setar algum filtro que tenha sido informado
por Query String no REST.

@param  cFilter - Valor do filtro a ser aplicado no alias
@return lRet - Indica se o filtro foi aplicado corretamente
@author Vinicius Queiros Teixeira
@since 17/08/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class PLIncRestModel

	Self:cFilter := Alltrim(cFilter)

    If !Empty(Self:cFilter)
        Self:cFilter += " AND "  
    EndIf

    Self:cFilter += "BBA_TIPMAN = 1" // 1 = Inclusão

    Do Case
        Case "PLINCAUTOBENMODEL" $ Upper(self:GetHttpHeader("_PATH_"))
            Self:cFilter += " AND BBA_STATUS = 7" // 7 = Aprovado Automaticamente

        Case "PLINCBENMODEL" $ Upper(self:GetHttpHeader("_PATH_"))
            Self:cFilter += " AND BBA_STATUS <> 7" // 7 = Aprovado Automaticamente
    EndCase

Return .T.
