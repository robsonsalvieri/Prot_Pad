#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

/*----------------------------------------------------------------------
{Protheus.doc} TAFA364
Cadastro MVC de Códigos de demais informações de Pagamentos ou Remessas 
a Título de Serviços, Juros e Dividendos a Beneficiários do Brasil e do 
Exterior - Reg. X451 da ECF

@author Carlos Eduardo Boy
@since 03/04/2025
@version 1.0
----------------------------------------------------------------------*/
Function TAFA634()
Local lRet := .f.
Local oBrowse :=  FWmBrowse():New()

oBrowse:SetAlias('T17')
oBrowse:SetDescription('Códigos demais informações de Pagtos\Remessas a Título de Serviços, Juros e Dividendos') 
oBrowse:SetMenuDef( 'TAFA634' )
T17->(DbSetOrder(2))
oBrowse:Activate()

return lRet

/*----------------------------------------------------------------------
{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Carlos Eduardo Boy
@since 03/04/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function ModelDef()
Local oStructT17 :=  FWFormStruct(1, 'T17')
Local oModel     :=  MPFormModel():New('TAFA634')

oModel:AddFields('MODEL_T17',, oStructT17)
oModel:GetModel('MODEL_T17'):SetPrimaryKey({'T17_FILIAL','T17_ID'})

Return oModel

/*----------------------------------------------------------------------
/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Carlos Eduardo Boy
@since 03/04/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function ViewDef()
Local   oModel      :=  FWLoadModel('TAFA634')
Local   oStructT17  :=  FWFormStruct(2, 'T17')
Local   oView       :=  FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_T17', oStructT17, 'MODEL_T17')

oView:EnableTitleView('VIEW_T17','Códigos demais informações de Pagtos\Remessas a Título de Serviços, Juros e Dividendos')   
oView:CreateHorizontalBox( 'FIELDST17', 100 )
oView:SetOwnerView('VIEW_T17', 'FIELDST17')

oStructT17:RemoveField('T17_ID')

Return oView 

/*----------------------------------------------------------------------
/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Carlos Eduardo Boy
@since 03/04/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function MenuDef()
Return XFUNMnuTAF('TAFA634',,,.t.)

/*-------------------------------------------------------------------
{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param	nVerEmp	- Versão corrente na empresa
		nVerAtu	- Versão atual ( passado como referência )
'
@Return	aRet - Array com estrutura de campos e conteúdo da tabela

@Author	 Carlos Eduardo Boy
@Since	 03/04/2025
@Version 1.0
-------------------------------------------------------------------*/
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1033.74'

If nVerEmp < nVerAtu
	aAdd( aHeader, 'T17_FILIAL' )
	aAdd( aHeader, 'T17_ID'     )
	aAdd( aHeader, 'T17_CODIGO' )
	aAdd( aHeader, 'T17_DESCRI' )
	aAdd( aHeader, 'T17_DTINI'  )
	aAdd( aHeader, 'T17_DTFIM'  )
    aAdd( aHeader, 'T17_ALTCON' )

	aAdd( aBody, { '', '71d1be0e-3c20-40c8-993b-9de48b538274',  '1', 'Valor dos Serviços de Assistência Técnica, Científica, Administrativa e Assemelhados com Transferência de Tecnologia', '20240101', '', 1033.74} )
	aAdd( aBody, { '', 'f51189b4-cb1c-4b9e-bd80-798ff2e85350',  '2', 'Valor dos Serviços Técnicos e de Assistência sem Transferência de Tecnologia Prestados no Brasil', '20240101', '', 1033.74} )
	aAdd( aBody, { '', '205eacee-3072-4f50-8e0b-a0f542b186e5',  '3', 'Valor dos Serviços Técnicos e de Assistência sem Transferência de Tecnologia Prestados no Exterior', '20240101', '', 1033.74} )
	aAdd( aBody, { '', '1f27f317-ad23-46b3-9876-6ee1732ff445',  '4', 'Valor dos Juros sobre o Capital Próprio Pagos a Pessoa Física', '20240101', '', 1033.74} )
	aAdd( aBody, { '', 'f7870191-f18e-40f1-9438-07b2ccd321bb',  '5', 'Valor dos Juros sobre o Capital Próprio Pagos a Pessoa Jurídica', '20240101', '', 1033.74} )
	aAdd( aBody, { '', '28e10d28-988c-416c-818c-d5eab9610853',  '6', 'Valor dos Demais Juros', '20240101', '', 1033.74} ) 
	aAdd( aBody, { '', '98e0169c-b441-473a-bd8a-70761b07af60',  '7', 'Dividendos Pagos a Pessoa Física', '20240101', '', 1033.74} )
	aAdd( aBody, { '', 'c4beac1e-c493-4ce2-a817-eb6ae0337498',  '8', 'Dividendos Pagos a Pessoa Jurídica', '20240101', '', 1033.74} )
	aAdd( aBody, { '', 'db7410c9-0bbc-41fb-a332-fa1a1493cba9',  '9', 'Despesas - Produtos e Serviços Brasileiros', '20240101', '', 1033.74} ) 
	aAdd( aBody, { '', '7df95587-d49f-4ce6-b5f4-17a799f8f07b', '10', 'Despesas - Promoção do Brasil no Exterior', '20240101', '', 1033.74} )
	aAdd( aBody, { '', '480ae845-82e1-4d4f-a904-ba4e895dae80', '11', 'Despesas - Comissões Pagas', '20240101', '', 1033.74} )
    aAdd( aBody, { '', '5efa107f-18a1-4384-9e46-d74a5933e530', '12', 'Despesas - Cargas no exterior', '20240101', '', 1033.74} )
    aAdd( aBody, { '', '3a7e9369-390b-4e69-a386-6c81bcb36f02', '13', 'Despesas - Cobertura de Risco de Variação', '20240101', '', 1033.74} )
    aAdd( aBody, { '', '93409c8e-2729-44d5-88cc-6125e05c976b', '14', 'Despesas - Juros de Desconto no Exterior', '20240101', '', 1033.74} )
	aAdd( aBody, { '', '8997ad5a-94c4-4697-8d2e-78432ee35037', '15', 'Despesas - Juros – Financiamento de Exportações', '20240101', '', 1033.74} )
    aAdd( aBody, { '', '6579f234-26e6-4fca-8c29-f2c48a67a5ab', '16', 'Despesas - Comissões – Financiamento de Exportações', '20240101', '', 1033.74} )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

