#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
//Receber e gravar valores do fonte PLSA298

Static Function ModelDef()
Local oModel 
Local oStrB19:= FWFormStruct(1,'B19' )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSA298GRV' ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB19',/*cOwner*/,oStrB19)  // Adiciona ao modelo um componente de formulário

oModel:GetModel('MasterB19'):SetDescription( "Cadastro de NF Entrada x Guias" ) // Adiciona a descrição do Modelo de Dados
oStrB19:setProperty( "*" , MODEL_FIELD_VALID, {||.T. }  )
oStrB19:setProperty( "*" , MODEL_FIELD_INIT, {||'' }  )

oModel:SetPrimaryKey( { "B19_FILIAL", "B19_FORNEC", "B19_LOJA", "B19_DOC", "B19_SERIE", "B19_GUIA" } )

Return oModel // Retorna o Modelo de dados
