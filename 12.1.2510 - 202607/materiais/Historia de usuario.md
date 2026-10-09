h2. História de Usuário

_Como_ usuário da API de Sales Taxes  
_Quero_ que o retorno da API inclua, além dos tributos legados, também os novos tributos calculados pelo configurador de tributos  
_Para_ garantir que todos os impostos aplicáveis sejam considerados e identificados corretamente no retorno.

h3. Objetivo

O objetivo desta demanda é garantir que a API de Sales Taxes seja capaz de retornar todos os tributos calculados, tanto os legados quanto os novos criados pelo configurador de tributos, de forma clara e sem duplicidade. Isso permitirá que os clientes tenham uma visão completa dos impostos incidentes em suas operações, facilitando integrações, conferências fiscais e auditorias.

h3. Contexto

Atualmente, a API de Sales Taxes retorna apenas os tributos legados. É necessário adaptar o retorno para incluir também os novos tributos calculados pelo configurador, utilizando a classe [TCIProcessing|https://tdn.totvs.com/pages/viewpage.action?pageId=825302215]. Os tributos legados devem permanecer como estão.

Para facilitar a identificação dos tributos será necessário converter a sigla do tributo criado pelo usuário para o nome esperado do tributo, convertendo o ID_TOTVS pelo tributo correspondente.

_Exemplo:_  
Sigla: IBS001 | ID_TOTVS: 000060 | Tributo: IBSESTADUAL  
Sigla: CBS001 | ID_TOTVS: 000062 | Tributo: CBS FEDERAL

h3. Estrutura do JSON Esperado

O JSON retornado pela API deve conter:

- Os tributos legados nas chaves já existentes.
- Os novos tributos do configurador em chaves específicas, identificados pelo ID_TOTVS e nome do tributo.
- Detalhamento dos tributos por item, conforme já ocorre atualmente.

_Exemplo simplificado de estrutura:_

{code:json}
{
"valor_contabil": 1000.0,
"valor_mercadoria": 900.0,
"total_impostos_embutidos": 120.0,
"total_impostos_sem_incidencia": 30.0,
"total_impostos": 150.0,
"TaxesDetail": [
{
"imposto": "ICMS",
"descricao": "Imposto sobre Circulação de Mercadorias",
"base_calculo": 800.0,
"aliquota": 18.0,
"valor": 144.0
},
{
"imposto": "IBSESTADUAL",
"descricao": "Imposto sobre Bens e Serviços Estadual",
"base_calculo": 800.0,
"aliquota": 1.0,
"valor": 8.0,
"id_totvs": "000060"
}
],
"itens": [
{
"produto": {
"codigo_produto": "PROD001",
"valor_mercadoria": 500.0,
"valor_icms": 90.0,
"valor_ibse": 4.0
// ... outros campos ...
}
}
]
}
{code}

h3. Fluxo de Validação

# Obter os tributos legados normalmente.

# Utilizar a classe TCIProcessing para obter os novos tributos do configurador.

# Para cada tributo retornado pelo configurador:

## Validar se possui o campo _ID_TOTVS_.

## Converter a sigla para o nome esperado conforme tabela de conversão.

## Incluir no JSON apenas se não for um tributo legado já presente nas chaves atuais.

# Garantir que não haja duplicidade de tributos entre os modelos legado e novo.

h3. Critérios de Aceite

- O retorno da API deve incluir os novos tributos calculados pelo configurador, além dos tributos legados.
- Apenas tributos que possuam o campo _ID_TOTVS_ devem ser incluídos nas novas chaves do JSON.
- Tributos legados que já possuem chaves e valores específicos no JSON não devem ser duplicados nas novas chaves.
- A estrutura do JSON deve seguir o padrão esperado pela API, garantindo integridade e consistência dos dados.
- O detalhamento dos tributos por item deve ser mantido, considerando todos os tributos calculados.
- O código deve ser adaptado para utilizar a classe TCIProcessing para obtenção dos novos tributos.

h3. Exemplo de Comportamento Esperado

Se tributos como ICMS, IPI e outros legados forem retornados com o campo _ID_TOTVS_, eles devem ser ignorados nas novas chaves, pois já estão presentes no JSON legado.

h3. Trecho de código a ser adaptado

{code:java}
If lApiTrib

    aJSon := MaFisRodape(1,Nil,,,Nil,.T.,,,,,,,,,,,,,,,.T.)
    nDetImp := Len(aJson) //Linhas do detalhamento de impostos

    oImpostos := JsonObject():New()
    oImpostos["valor_contabil"]      			:= MaFisRet(,"NF_TOTAL")
    oImpostos["valor_mercadoria"]    			:= MaFisRet(,"NF_VALMERC")
    oImpostos["total_impostos_embutidos"]		:= MaFisRet(,"NF_VALICM") + MaFisRet(,"NF_VALCOF") + MaFisRet(,"NF_VALCF2") + MaFisRet(,"NF_VALPIS") + MaFisRet(,"NF_VALPS2") + MaFisRet(,"NF_VALCSL") + MaFisRet(,"NF_VALISS")
    oImpostos["total_impostos_sem_incidencia"]  := MaFisRet(,"NF_VALIPI") + MaFisRet(,"NF_VALSOL")
    oImpostos["total_impostos"]                 := 0
    oImpostos["TaxesDetail"]					:= {}
    oImpostos["itens"]							:= {}
    oImpostos["desconto"]   					:= MaFisRet(,"NF_DESCONTO")
    oImpostos["base_duplicada"] 				:= MaFisRet(,"NF_BASEDUP")
    oImpostos["seguro"]     					:= MaFisRet(,"NF_SEGURO")
    oImpostos["frete"]      					:= MaFisRet(,"NF_FRETE")
    oImpostos["despesas_acessorias"]    		:= MaFisRet(,"NF_DESPESA")

    For nX := 1 To nDetImp
        oImpDet := JsonObject():New()
        oImpDet["imposto"]      := aJson[nX,1]
        oImpDet["descricao"]    := aJson[nX,2]
        oImpDet["base_calculo"] := aJson[nX,3]
        oImpDet["aliquota"]     := aJson[nX,4]
        oImpDet["valor"]        := aJson[nX,5]

    	nImpTot += aJson[nX,5]

        aAdd( oImpostos["TaxesDetail"], oImpDet )
    Next nX

    oImpostos["total_impostos"] := nImpTot

    IF (nItens := MaFisRet(,"NF_QTDITENS")) > 0

        For nX := 1 To nItens
            oItens := JsonObject():New()
            oItens["produto"]   := {}

            oItemDet := JsonObject():New()
            oItemDet["valor_mercadoria"] 	:= MaFisRet(nX,'IT_VALMERC')
            oItemDet["valor_st"]	     	:= MaFisRet(nX,'IT_VALSOL')
            oItemDet["valor_total"]      	:= MaFisRet(nX,'IT_TOTAL')
            oItemDet["seguro"]		     	:= MaFisRet(nX,'IT_SEGURO')
            oItemDet["valor_csll"]       	:= MaFisRet(nX,'IT_VALCSL')
            oItemDet["valor_unitario"]   	:= MaFisRet(nX,'IT_PRCUNI')
            oItemDet["quantidade"]       	:= MaFisRet(nX,'IT_QUANT')
            oItemDet["aliquota_pis"]     	:= MaFisRet(nX,'IT_ALIQPIS')
            oItemDet["aliquota_ipi"]     	:= MaFisRet(nX,'IT_ALIQIPI')
            oItemDet["valor_pis"]        	:= MaFisRet(nX,'IT_VALPIS') 	// Valor do PIS retido
    		oItemDet['valor_pis_apur']		:= MaFisRet(nX,'IT_VALPS2') 	// Valor do PIS via apuração
    		oItemDet['valor_pis_st']		:= MaFIsRet(nX,'IT_VALPS3')		// Valor do PIS Subst. Tributaria
            oItemDet["aliquota_cofins"]  	:= MaFisRet(nX,'IT_ALIQCOF')
            oItemDet["valor_cofins"]     	:= MaFisRet(nX,'IT_VALCOF')		// Valor da COFINS retida
    		oItemDet["valor_cofins_apur"]	:= MaFisRet(nX,'IT_VALCF2')		// Valor da COFINS via apuração
    		oItemDet["valor_cofins_st"]		:= MaFisRet(nX,'IT_VALCF3')		// Valor da COFINS Subst. Tributaria
            oItemDet["aliquota_st"]      	:= MaFisRet(nX,'IT_ALIQSOL')
            oItemDet["aliquota_icms"]    	:= MaFisRet(nX,'IT_ALIQICM')
            oItemDet["frete"]	         	:= MaFisRet(nX,'IT_FRETE')
            oItemDet["codigo_produto"]   	:= MaFisRet(nX,'IT_PRODUTO')
            oItemDet["aliquota_csll"]    	:= MaFisRet(nX,'IT_ALIQCSL')
            oItemDet["valor_icms"]       	:= MaFisRet(nX,'IT_VALICM')
            oItemDet["valor_ipi"]        	:= MaFisRet(nX,'IT_VALIPI')
            oItemDet["desconto"]	     	:= MaFisRet(nX,'IT_DESCONTO')
            oItemDet["despesas_acessorias"] := MaFisRet(nX,'IT_DESPESA')
            oItemDet["tes"]		           	:= MaFisRet(nX,'IT_TES')

            oItens["produto"] :=  oItemDet
            aAdd( oImpostos["itens"], oItens )
        Next nX
    Endif

    oAPIManager:SetJson(.F.,{oImpostos})

    //Limpa objetos e array
    FreeObj(oImpostos)
    FreeObj(oItemDet)
    FreeObj(oItens)
    FreeObj(oImpDet)
    FwFreeArray(aJson)

{code}

h3. Automação

Atualmente existem duas automações para esta API que devem ser utilizadas para garantir que o comportamento atual continua funcionando e criar novos cases para nova implementação.

- Fiscal: FISComZFMMovTestCase
- Faturamento: MATSIMPTestCase

Os casos de teste existentes não devem ser alterados, mas novos casos podem ser adicionados conforme necessário para cobrir novas funcionalidades ou alterações no comportamento da API.

h3. Importante

- É preciso alinhar com a equipe de desenvolvimento do faturamento sobre o retorno esperado, conversão da sigla do tributo para o ID_TOTVS e nome do tributo esperado, além do tratamento dos tributos legados.
- Também é necessário alinhar se será gerada uma nova versão de endpoint para a API, caso haja mudanças significativas na estrutura ou no comportamento dos dados retornados.
- Este alinhamento deve ocorrer antes da implementação das mudanças.

h3. Impactos

A alteração pode impactar integrações que consomem o JSON da API, principalmente se houver mudança na estrutura ou inclusão de novos campos. Recomenda-se comunicar os clientes e parceiros sobre a mudança e validar se há necessidade de ajustes nas integrações existentes.

h3. Observações Finais

Este documento deve servir como referência para o desenvolvimento, testes e homologação da melhoria, garantindo clareza no objetivo, critérios de aceitação e exemplos práticos para facilitar o entendimento de todos os envolvidos.
