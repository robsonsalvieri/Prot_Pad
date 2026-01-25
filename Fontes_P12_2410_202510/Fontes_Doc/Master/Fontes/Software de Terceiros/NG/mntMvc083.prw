#INCLUDE "PROTHEUS.CH"

#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/  PUBLICACAO DO MNTA083 COMO ENDPOINT                          /*/
//-------------------------------------------------------------------
PUBLISH USER MODEL REST NAME mntPneus SOURCE MNTA083 RESOURCE OBJECT oMntMvcPne
  
//-------------------------------------------------------------------
/*/{Protheus.doc} oMntMvcPne
Classe que extende a FwRestModel, responsável pela configuração do
Model da rotina MNTA083 ( Pneus )
(Filtro e configuração pra trazer todos os submodelos)

@author João Ricardo Santini Zandoná
@since  07/05/2025
/*/
//-------------------------------------------------------------------
Class oMntMvcPne From FwRestModel

    Method SetFilter()
    Method GetData()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter
Metodo responsável por setar o filtro que será utilizado na query
que busca os dados

@param  cFilter, caractere, filtro recebido via query params
@author João Ricardo Santini Zandoná
@since  07/05/2025
@return logico, sempre retorna verdadeiro
/*/
//-------------------------------------------------------------------
Method SetFilter( cFilter ) Class oMntMvcPne

    If !Empty( cFilter )

        cFilter += ' AND'

    EndIf

    cFilter += " ( T9_CATBEM = '3' ) "

	self:cFilter := Alltrim( cFilter )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetData
Metodo responsável pegar os registros em formato JSON ou XML

@param  lFieldDetail,  logico, Indica se retorna o registro com informações detalhadas
@param  lFieldVirtual, logico, Indica se retorna o registro com campos virtuais
@param  lFieldEmpty,   logico, Indica se retorna o registro com campos nao obrigatorios vazios
@param  lFirstLevel,   logico, Indica se deve retornar todos os modelos filhos ou nao
@param  lInternalID,   logico, Indica se deve retornar o ID como informação complementar das linhas do GRID

@author João Ricardo Santini Zandoná
@since  07/05/2025
@return caractere, Retorna o registro nos formatos XML ou JSON
/*/
//-------------------------------------------------------------------
Method GetData( lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID ) Class oMntMvcPne
    
    Local cRet

	self:oModel:SetOperation( MODEL_OPERATION_VIEW )
	Self:oModel:Activate()

	If self:lXml

		cRet := Self:oModel:GetXmlData( lFieldDetail, , , lFieldVirtual, , lFieldEmpty, .F./*lDefinition*/, , .T./*lPK*/, .T./*lPKEncoded*/, self:aFields, .F., lInternalID )
	
    Else
	
    	cRet := Self:oModel:GetJsonData( lFieldDetail, , lFieldVirtual, , lFieldEmpty, .T./*lPK*/, .T./*lPKEncoded*/, self:aFields, .F., lInternalID )
	
    EndIf
	
    Self:oModel:DeActivate()

Return cRet
