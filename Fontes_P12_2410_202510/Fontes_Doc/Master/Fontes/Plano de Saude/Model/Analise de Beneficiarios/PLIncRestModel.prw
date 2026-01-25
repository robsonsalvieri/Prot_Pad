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
    Method GetData()
    Method UpdateModel()
    Method UpdateOpc()
    Method UpdateGen()
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

//-------------------------------------------------------------------
/*/{Protheus.doc} GetData
Método responsável por retornar o registro do modelo no formato XML 
ou JSON.

@param	lFieldDetail	Indica se retorna o registro com informações detalhadas
@param	lFieldVirtual	Indica se retorna o registro com campos virtuais
@param	lFieldEmpty 	Indica se retorna o registro com campos nao obrigatorios vazios
@param	lFirstLevel		Indica se deve retornar todos os modelos filhos ou nao
@param	lInternalID     Indica se deve retornar o ID como informação complementar das linhas do GRID 

@return	cRet		Retorna o registro nos formatos XML ou JSON

@version P11, P12
/*/
//-------------------------------------------------------------------
Method GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID) Class PLIncRestModel
Local cRet

	self:oModel:SetOperation(MODEL_OPERATION_INSERT)
	Self:oModel:Activate()
    
    self:UpdateModels()

	If self:lXml
		cRet := Self:oModel:GetXmlData(lFieldDetail,,,lFieldVirtual,,lFieldEmpty,.F./*lDefinition*/,,.T./*lPK*/,.T./*lPKEncoded*/,self:aFields,lFirstLevel,lInternalID)
	Else
		cRet := Self:oModel:GetJsonData(lFieldDetail,,lFieldVirtual,,lFieldEmpty,.T./*lPK*/,.T./*lPKEncoded*/,self:aFields,lFirstLevel,lInternalID)
	EndIf
	Self:oModel:DeActivate()

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateModels
Grava o retorno dos processo de gravação das tabelas secundarias direto
no modelo de dados que foi criado a partir de uma temporária para manter
o padrão de retorno da API

@version P11, P12
/*/
//-------------------------------------------------------------------
Method UpdateModels() Class PLIncRestModel

    self:UpdateOpc()
    self:UpdateGen()
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateOpc
Atualiza o modelo de opcionais com os dados para retornar na
API de acordo com o padrão modelo e dados

@version P11, P12
/*/
//-------------------------------------------------------------------
Method UpdateOpc() Class PLIncRestModel
    
    If Select("INCOP") > 0
        
        INCOP->(DbGoTop())
        
        While !INCOP->(EOF())
            Self:oModel:loadValue( 'DETAILOPC', 'MATRICULA', INCOP->MATRICULA)
            Self:oModel:loadValue( 'DETAILOPC', 'RESULT', INCOP->RESULT)
            Self:oModel:getModel("DETAILOPC"):AddLine()

            INCOP->(DbSkip())
        EndDo

        INCOP->(DbCloseArea())
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateOpc
Atualiza o modelo de propriedades genéricas com os dados para retornar na
API de acordo com o padrão modelo e dados

@version P11, P12
/*/
//-------------------------------------------------------------------
Method UpdateGen() Class PLIncRestModel
    
    If Select("PROGEN") > 0
        
        PROGEN->(DbGoTop())
        
        While !PROGEN->(EOF())
            Self:oModel:loadValue( 'DETAILPRPGEN', 'SUCESSO', PROGEN->SUCESSO)
            Self:oModel:loadValue( 'DETAILPRPGEN', 'DESCPROP', PROGEN->DESCPROP)
            Self:oModel:loadValue( 'DETAILPRPGEN', 'RETORNO', PROGEN->RETORNO)
            Self:oModel:getModel("DETAILPRPGEN"):AddLine()

            PROGEN->(DbSkip())
        EndDo

        PROGEN->(DbCloseArea())
    EndIf
Return
