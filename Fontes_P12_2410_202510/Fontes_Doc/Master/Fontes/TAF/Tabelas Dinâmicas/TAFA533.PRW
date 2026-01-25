#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA533.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA533
MVC DA TABELA AUTO CONTIDA V3O-NATUREZA DE RENDIMENTO

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA533()
Local	oBrw		:=	FWmBrowse():New()

If AliasIndic("V3O")
    oBrw:SetDescription(STR0001)    //"Cadastros das Naturezas de rendimento "
    oBrw:SetAlias( 'V3O')
    oBrw:SetMenuDef( 'TAFA533' )
    V3O->(DbSetOrder(1))
    oBrw:Activate()
Else
	Alert(STR0002)  //"Tabela V3O não existe."
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC para o menu
@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA533" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV3O 	:= 	FWFormStruct( 1, 'V3O' )
Local oModel 	:= 	MPFormModel():New( 'TAFA533' )

oModel:AddFields('MODEL_V3O', /*cOwner*/, oStruV3O)
oModel:GetModel('MODEL_V3O'):SetPrimaryKey({'V3O_FILIAL','V3O_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA533' )
Local 	oStruV3O	:= 	FWFormStruct( 2, 'V3O' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V3O', oStruV3O, 'MODEL_V3O' )

oView:EnableTitleView( 'VIEW_V3O',STR0003)  //"Natureza de Rendimento"
oView:CreateHorizontalBox( 'FIELDSV3O', 100 )
oView:SetOwnerView( 'VIEW_V3O', 'FIELDSV3O' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Autor Katielly Feitosa Rezende
@Since		06/05/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1033.81

If AliasIndic("V3O")
	If nVerEmp < nVerAtu 
        
        aAdd( aHeader, "V3O_FILIAL" ) 
        aAdd( aHeader, "V3O_ID" ) 
        aAdd( aHeader, "V3O_CODIGO" )
        aAdd( aHeader, "V3O_DESCR" )
        aAdd( aHeader, "V3O_FCI" )
        aAdd( aHeader, "V3O_DECSAL" )
        aAdd( aHeader, "V3O_RRA" )
        aAdd( aHeader, "V3O_DEDUC" ) 
        aAdd( aHeader, "V3O_ISENTO" ) 
        aAdd( aHeader, "V3O_BENNAC" ) 
        aAdd( aHeader, "V3O_BENEXT" )
        aAdd( aHeader, "V3O_TRIB" )

        //Tabela 01 – Natureza de Rendimentos
        //GRUPO 10 - Rendimento do Trabalho e da Previdência Social
        //           FIL   ID        COD          DESC                                                       FCI  13º  RRA  DEDUÇOES       ISENTO          BNAC BEXT TRIBUTO
        aAdd( aBody, { "", "000001", "10001", "Rendimento decorrente do trabalho com vínculo empregatício" , "2", "1", "1", "1,2,3,4,5,7,8", "2,3,4,5,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000002", "10002", "Rendimento decorrente do trabalho sem vínculo empregatício" , "2", "2", "1", "1,5,7,8"      , "2,3,4,8,99"  , "1", "1", "1"})
        aAdd( aBody, { "", "000003", "10003", "Rendimento decorrente do trabalho pago a trabalhador avulso", "2", "1", "1", "1,5,7,8"      , "2,3,4,8,99"  , "1", "1", "1"})
        aAdd( aBody, { "", "000004", "10004", "Participação nos lucros ou resultados (PLR)"                , "2", "2", "1", "5"          , "",             "1", "1", "1"})
        aAdd( aBody, { "", "000005", "10005", "Benefício de Regime Próprio de Previdência Social"          , "2", "1", "1", "1,2,3,5,7,8"  , "1,6,99",       "1", "1", "1"})
        aAdd( aBody, { "", "000006", "10006", "Benefício do Regime Geral de Previdência Social"            , "2", "1", "1", "1,2,3,5,7,8"  , "1,6,99",       "2", "2", "1"})
        aAdd( aBody, { "", "000007", "10007", "Rendimentos relativos a prestação de serviços de Transporte Rodoviário Internacional de Carga, Auferidos por Transportador Autônomo Pessoa Física, Residente na República do Paraguai, considerado como Sociedade Unipessoal nesse País" , "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000008", "10008", "Honorários advocatícios de sucumbência recebidos pelos advogados e procuradores públicos de que trata o art. 27 da Lei nº 13.327", "2", "2", "1", "2,3,5,7", "", "1", "1", "1"})
        aAdd( aBody, { "", "000009", "10009", "Auxílio moradia", "2", "2", "2", "", "", "1", "1", "1"})
        aAdd( aBody, { "", "000010", "10010", "Bolsa ao médico residente", "2", "1", "1", "", "", "3", "3", "8"})

        //GRUPO 11 - Rendimento decorrente de Decisão Judicial
        aAdd( aBody, { "", "000011", "11001", "Decorrente de Decisão da Justiça do Trabalho", "2", "1", "1", "1,5,7,8", "10,99"                , "3", "3", "1"})
        aAdd( aBody, { "", "000012", "11002", "Decorrente de Decisão da Justiça Federal"    , "2", "2", "1", "1"    , "6,10"                 , "3", "3", "1"})
        aAdd( aBody, { "", "000013", "11003", "Decorrente de Decisão da Justiça dos Estados/Distrito Federal"   , "2", "1", "1", "1,2,3,4,5,7,8", "6,10", "3", "3", "1"})
        aAdd( aBody, { "", "000014", "11004", "Responsabilidade Civil - juros e indenizações por lucros cessantes, inclusive astreinte", "2", "2", "1", "1,2,3,4,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000015", "11005", "Decisão Judicial – Importâncias pagas a título de indenizações por danos morais, decorrentes de sentença judicial.", "2", "2", "1", "", "", "2", "2", "1"})

        //GRUPO 12 - Rendimento do Capital
        aAdd( aBody, { "", "000016", "12001", "Lucro e Dividendo", "2", "2", "1", "", "", "2", "2", "8"})
        aAdd( aBody, { "", "000017", "12002", "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva", "2", "2", "2", "", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000018", "12003", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva", "2", "2", "2", "", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000019", "12004", "Resgate de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva", "2", "2", "2", "8", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000020", "12005", "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva", "2", "2", "2", "", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000021", "12006", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva", "2", "2", "2", "", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000022", "12007", "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência- Optante pela Tributação Exclusiva", "2", "2", "2", "", "7,11", "1", "1", "1"})
        aAdd( aBody, { "", "000023", "12008", "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000024", "12009", "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva", "2", "1", "1", "2,3,4,5,7,8", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000025", "12010", "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva", "2", "1", "1", "2,3,4,5,7,8", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000026", "12011", "Benefício de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva", "2", "1", "1", "2,3,4,5,7,8", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000027", "12012", "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva", "2", "1", "1", "", "6,7", "2", "2", "1"})
        aAdd( aBody, { "", "000028", "12013", "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva", "2", "1", "1", "", "6,7", "2", "2", "1"})
        aAdd( aBody, { "", "000029", "12014", "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência- Optante pela Tributação Exclusiva", "2", "1", "2", "", "6,7", "1", "1", "1"})
        aAdd( aBody, { "", "000030", "12015", "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva", "2", "2", "1", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000031", "12016", "Juros sobre o Capital Próprio", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000032", "12017", "Rendimento de Aplicações Financeiras de Renda Fixa, decorrentes de alienação, liquidação (total ou parcial), resgate, cessão ou repactuação do título ou aplicação", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000033", "12018", "Rendimentos auferidos pela entrega de recursos à pessoa jurídica, sob qualquer forma e a qualquer título, independentemente de ser ou não a fonte pagadora instituição autorizada a funcionar pelo Banco Central", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000034", "12019", "Rendimentos predeterminados obtidos em operações conjugadas realizadas: nos mercados de opções de compra e venda em bolsas de valores, de mercadorias e de futuros (box); no mercado a termo nas bolsas de valores, de mercadorias e de futuros, em operações de venda coberta e sem ajustes diários, e no mercado de balcão.", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000035", "12020", "Rendimentos obtidos nas operações de transferência de dívidas realizadas com instituição financeira e outras instituições autorizadas a funcionar pelo Banco Central do Brasil", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000036", "12021", "Rendimentos periódicos produzidos por título ou aplicação, bem como qualquer remuneração adicional aos rendimentos prefixados", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000037", "12022", "Rendimentos auferidos nas operações de mútuo de recursos financeiros entre pessoa física e pessoa jurídica e entre pessoas jurídicas, inclusive controladoras, controladas, coligadas e interligadas", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000038", "12023", "Rendimentos auferidos em operações de adiantamento sobre contratos de câmbio de exportação, não sacado (trava de câmbio), bem como operações com export notes, com debêntures, com depósitos voluntários para garantia de instância e com depósitos judiciais ou administrativos, quando seu levantamento se der em favor do depositante", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000039", "12024", "Rendimentos obtidos nas operações de mútuo e de compra vinculada à revenda tendo por objeto ouro, ativo financeiro", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000040", "12025", "Rendimentos auferidos em contas de depósitos de poupança", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000041", "12026", "Rendimentos auferidos sobre juros produzidos por letras hipotecárias", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000042", "12027", "Rendimentos ou ganhos decorrentes da negociação de títulos ou valores mobiliários de renda fixa em bolsas de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000043", "12028", "Rendimentos auferidos em outras aplicações financeiras de renda fixa ou de renda variável", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000044", "12029", "Rendimentos auferidos em Fundo de Investimento", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000045", "12030", "Rendimentos auferidos em Fundos de investimento em quotas de fundos de investimento", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000046", "12031", "Rendimentos produzidos por aplicações em fundos de investimento em ações", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000047", "12032", "Rendimentos produzidos por aplicações em fundos de investimento em quotas de fundos de investimento em ações", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000048", "12033", "Rendimentos produzidos por aplicações em Fundos Mútuos de Privatização com recursos do Fundo de Garantia por Tempo de Serviço (FGTS)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000049", "12034", "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobiliário", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000050", "12035", "Rendimentos distribuídos pelo Fundo de Investimento Imobiliário aos seus cotistas", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000051", "12036", "Rendimento auferido pelo cotista no resgate de cotas na liquidação do Fundo de Investimento Imobiliário", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000052", "12037", "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobiliário – Distribuição semestral", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000053", "12038", "Rendimentos distribuídos pelo Fundo de Investimento Imobiliário aos seus cotistas - Distribuição semestral", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000054", "12039", "Rendimento auferido pelo cotista no resgate de cotas na liquidação do Fundo de Investimento Imobiliário – Distribuição semestral", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000055", "12040", "Rendimentos e ganhos de capital distribuídos pelo Fundo de Investimento Cultural e Artístico (Ficart)", "1", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000056", "12041", "Rendimentos e ganhos de capital distribuídos pelo Fundo de Financiamento da Indústria Cinematográfica Nacional (Funcines)", "1", "2", "2", "", "", "3", "3", "1"})
        //Exclusao do codigo 12042 no layout Reinf 2.1.2
        //aAdd( aBody, { "", "000057", "12042", "Rendimentos auferidos no resgate de quotas de fundos de investimento mantidos com recursos provenientes de conversão de débitos externos brasileiros, e de que participem, exclusivamente, residentes ou domiciliados no exterior", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000058", "12043", "Ganho de capital decorrente da integralização de cotas de fundos ou clubes de investimento por meio da entrega de ativos financeiros", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000059", "12044", "Distribuição de Juros sobre o Capital Próprio pela companhia emissora de ações objeto de empréstimo conforme art. 8º da Lei nº 13.043 de 2014", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000060", "12045", "Rendimentos de Partes Beneficiárias ou de Fundador", "2", "2", "2", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000061", "12046", "Rendimentos auferidos em operações de swap", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000062", "12047", "Rendimentos auferidos em operações day trade realizadas em bolsa de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000063", "12048", "Rendimento decorrente de Operação realizada em bolsas de valores, de mercadorias, de futuros, e assemelhadas, exceto day trade", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000064", "12049", "Rendimento decorrente de Operação realizada no mercado de balcão, com intermediação, tendo por objeto ações, ouro ativo financeiro e outros valores mobiliários negociados no mercado à vista", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000065", "12050", "Rendimento decorrente de Operação realizada em mercados de liquidação futura fora de bolsa", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000066", "12051", "Rendimentos de aplicações financeiras em ativos de infraestrutura - tributação exclusiva - conforme art. 1º da Lei 11.478 de 2007 e arts. 2º e 3º da Lei nº 12.431 de 2011", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000067", "12099", "Demais rendimentos de Capital", "1", "2", "2", "", "", "2", "2", "1"})
        
        //Grupo 13 - Rendimento de Direitos (Royalties)
        aAdd( aBody, { "", "000068", "13001", "Rendimentos de Aforamento", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000069", "13002", "Rendimentos de Aluguéis, Locação ou Sublocação", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000070", "13003", "Rendimentos de Arrendamento ou Subarrendamento", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000071", "13004", "Importâncias pagas por terceiros por conta do locador do bem (juros, comissões etc.)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000072", "13005", "Importâncias pagas ao locador pelo contrato celebrado (luvas, prêmios etc.)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000073", "13006", "Benfeitorias e quaisquer melhoramentos realizados no bem locado", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000074", "13007", "Juros decorrente da alienação a prazo de bens", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000075", "13008", "Rendimentos de Direito de Uso ou Passagem de Terrenos e de aproveitamento de águas", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000076", "13009", "Rendimentos de Direito de colher ou extrair recursos vegetais, pesquisar e extrair recursos minerais", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000077", "13010", "Rendimentos de Direito Autoral", "2", "2", "1", "1,5,7,8", "2,3,4,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000078", "13011", "Rendimentos de Direito Autoral (quando não percebidos pelo autor ou criador da obra)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000079", "13012", "Rendimentos de Direito de Imagem", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000080", "13013", "Rendimentos de Direito sobre películas cinematográficas, Obras Audiovisuais, e Videofônicas", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000081", "13014", "Rendimento de Direito relativo a radiodifusão de sons e imagens e serviço de comunicação eletrônica de massa por assinatura", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000082", "13015", "Rendimentos de Direito de Conjuntos Industriais e Invenções", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000083", "13016", "Rendimento de Direito de marcas de indústria e comércio, patentes de invenção e processo ou fórmulas de fabricação", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000084", "13017", "Importâncias pagas por terceiros por conta do cedente dos direitos (juros, comissões etc.)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000085", "13018", "Importâncias pagas ao cedente do direito, pelo contrato celebrado (luvas, prêmios etc.)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000086", "13019", "Despesas para conservação dos direitos cedidos (quando compensadas pelo uso do bem ou direito)", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000087", "13020", "Juros de mora e quaisquer outras compensações pelo atraso no pagamento de royalties – decorrente de prestação de serviço", "2", "2", "1", "1,5,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000088", "13021", "Juros de mora e quaisquer outras compensações pelo atraso no pagamento de royalties – decorrente de aquisição de bens", "2", "2", "1", "1,5,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000089", "13022", "Juros decorrente da alienação a prazo de direitos – decorrente de prestação de serviço", "2", "2", "1", "1,5,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000090", "13023", "Juros decorrente da alienação a prazo de direitos – decorrente de aquisição de bens", "2", "2", "1", "1,5,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000091", "13024", "Alienação de bens e direitos do ativo não circulante localizados no Brasil", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000092", "13025", "Rendimento de Direito decorrente da transferência de atleta profissional", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000093", "13026", "Juros e comissões correspondentes à parcela dos créditos de que trata o inciso XI do art. 1º da Lei nº 9.481, de 1997, não aplicada no financiamento de exportações", "2", "2", "1", "1,5,8", "", "4", "4", "1"})
        aAdd( aBody, { "", "000094", "13098", "Demais rendimentos de Royalties", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})
        aAdd( aBody, { "", "000095", "13099", "Demais rendimentos de Direito", "2", "2", "1", "1,5,7,8", "", "3", "3", "1"})

        //Grupo 14 - Prêmios e demais rendimentos
        aAdd( aBody, { "", "000096", "14001", "Prêmios distribuídos, sob a forma de bens e serviços, mediante loterias, concursos e sorteios, exceto a distribuição realizada por meio de vale-brinde", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000097", "14002", "Prêmios distribuídos, sob a forma de dinheiro, mediante loterias, concursos e sorteios, exceto os de antecipação nos títulos de capitalização e os de amortização e resgate das ações das sociedades anônimas", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000098", "14003", "Prêmios de Proprietários e Criadores de Cavalos de Corrida", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000099", "14004", "Benefícios líquidos mediante sorteio de títulos de capitalização, sem amortização antecipada", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000100", "14005", "Benefícios líquidos resultantes da amortização antecipada, mediante sorteio, dos títulos de capitalização e benefícios atribuídos aos portadores de títulos de capitalização nos lucros da empresa emitente", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000101", "14006", "Prêmios distribuídos, sob a forma de bens e serviços, mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000102", "14007", "Prêmios distribuídos, em dinheiro, obtido mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000103", "14008", "Importâncias correspondentes a multas e qualquer outra vantagem, ainda que a título de indenização, em virtude de rescisão de contrato", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000104", "14099", "Demais Benefícios Líquidos decorrentes de título de capitalização", "2", "2", "2", "", "", "3", "3", "1"})

        //Grupo 15 - Rendimento Pago/Creditado a Pessoa Jurídica
        aAdd( aBody, { "", "000105", "15001", "Importâncias pagas ou creditadas a cooperativas de trabalho relativas a serviços pessoais que lhes forem prestados por associados destas ou colocados à disposição", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000106", "15002", "Importâncias pagas ou creditadas a associações de profissionais ou assemelhadas, relativas a serviços pessoais que lhes forem prestados por associados destas ou colocados à disposição", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000107", "15003", "Remuneração de Serviços de administração de bens ou negócios em geral, exceto consórcios ou fundos mútuos para aquisição de bens", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000108", "15004", "Remuneração de Serviços de advocacia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000109", "15005", "Remuneração de Serviços de análise clínica laboratorial", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000110", "15006", "Remuneração de Serviços de análises técnicas", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000111", "15007", "Remuneração de Serviços de arquitetura", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000112", "15008", "Remuneração de Serviços de assessoria e consultoria técnica, exceto serviço de assistência técnica prestado a terceiros e concernente a ramo de indústria ou comércio explorado pelo prestador do serviço", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000113", "15009", "Remuneração de Serviços de assistência social", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000114", "15010", "Remuneração de Serviços de auditoria", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000115", "15011", "Remuneração de Serviços de avaliação e perícia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000116", "15012", "Remuneração de Serviços de biologia e biomedicina", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000117", "15013", "Remuneração de Serviços de cálculo em geral", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000118", "15014", "Remuneração de Serviços de consultoria", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000119", "15015", "Remuneração de Serviços de contabilidade", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000120", "15016", "Remuneração de Serviços de desenho técnico", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000121", "15017", "Remuneração de Serviços de economia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000122", "15018", "Remuneração de Serviços de elaboração de projetos", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000123", "15019", "Remuneração de Serviços de engenharia, exceto construção de estradas, pontes, prédios e obras assemelhadas", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000124", "15020", "Remuneração de Serviços de ensino e treinamento", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000125", "15021", "Remuneração de Serviços de estatística", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000126", "15022", "Remuneração de Serviços de fisioterapia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000127", "15023", "Remuneração de Serviços de fonoaudiologia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000128", "15024", "Remuneração de Serviços de geologia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000129", "15025", "Remuneração de Serviços de leilão", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000130", "15026", "Remuneração de Serviços de medicina, exceto aquela prestada por ambulatório, banco de sangue, casa de saúde, casa de recuperação ou repouso sob orientação médica, hospital e pronto-socorro", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000131", "15027", "Remuneração de Serviços de nutricionismo e dietética", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000132", "15028", "Remuneração de Serviços de odontologia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000133", "15029", "Remuneração de Serviços de organização de feiras de amostras, congressos, seminários, simpósios e congêneres", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000134", "15030", "Remuneração de Serviços de pesquisa em geral", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000135", "15031", "Remuneração de Serviços de planejamento", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000136", "15032", "Remuneração de Serviços de programação", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000137", "15033", "Remuneração de Serviços de prótese", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000138", "15034", "Remuneração de Serviços de psicologia e psicanálise", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000139", "15035", "Remuneração de Serviços de química", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000140", "15036", "Remuneração de Serviços de radiologia e radioterapia", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000141", "15037", "Remuneração de Serviços de relações públicas", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000142", "15038", "Remuneração de Serviços de serviço de despachante", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000143", "15039", "Remuneração de Serviços de terapêutica ocupacional", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000144", "15040", "Remuneração de Serviços de tradução ou interpretação comercial", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000145", "15041", "Remuneração de Serviços de urbanismo", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000146", "15042", "Remuneração de Serviços de veterinária", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000147", "15043", "Remuneração de Serviços de Limpeza", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000148", "15044", "Remuneração de Serviços de Conservação/ Manutenção, exceto reformas e obras assemelhadas", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000149", "15045", "Remuneração de Serviços de Segurança/Vigilância/Transporte de valores", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000150", "15046", "Remuneração de Serviços Locação de Mão de obra", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000151", "15047", "Remuneração de Serviços de Assessoria Creditícia, Mercadológica, Gestão de Crédito, Seleção e Riscos e Administração de Contas a Pagar e a Receber", "2", "2", "2", "", "", "2", "2", "2"})
        aAdd( aBody, { "", "000152", "15048", "Pagamentos Referentes à Aquisição de Autopeças", "2", "2", "2", "", "", "2", "2", "3"})
        aAdd( aBody, { "", "000153", "15049", "Pagamentos a entidades imunes ou isentas – IN RFB 1.234/2012", "2", "2", "2", "", "", "2", "2", "8"})
        aAdd( aBody, { "", "000154", "15050", "Pagamento a título de transporte internacional de valores efetuado por empresas nacionais estaleiros navais brasileiros nas atividades de conservação, modernização, conversão e reparo de embarcações pré-registradas ou registradas no Registro Especial Brasileiro (REB)", "2", "2", "2", "", "", "2", "2", "4"})
        aAdd( aBody, { "", "000155", "15051", "Pagamento efetuado a empresas estrangeiras de transporte de valores", "2", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000156", "15099", "Demais Rendimentos de serviços técnicos, de assistência técnica, de assistência administrativa e semelhantes", "2", "2", "2", "", "", "2", "2", "2"})

        //Grupo 16 - Demais Rendimentos de Residentes ou domiciliados no Exterior
        aAdd( aBody, { "", "000157", "16001", "Rendimentos de serviços técnicos, de assistência técnica, de assistência administrativa e semelhantes", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000158", "16002", "Demais Rendimentos de juros e comissões", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000159", "16003", "Rendimento pago a companhia de navegação aérea e marítima", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000160", "16004", "Rendimento de Direito relativo a exploração de obras audiovisuais estrangeiras, radiodifusão de sons e imagens e serviço de comunicação eletrônica de massa por assinatura", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000170", "16005", "Demais Rendimentos de qualquer natureza", "2", "2", "2", "", "", "3", "3", "1"})
        aAdd( aBody, { "", "000171", "16006", "Demais Rendimentos sujeitos à Alíquota Zero", "2", "2", "2", "", "", "3", "3", "8"})

        //Grupo 17 - Rendimentos pagos/creditados EXCLUSIVAMENTE por órgãos da administração federal direta, autarquias e fundações federais, empresas públicas, sociedades de economia mista e demais entidades em que a União, direta ou indiretamente detenha a maioria do capital social sujeito a voto, e que recebam recursos do Tesouro Nacional
        aAdd( aBody, { "", "000172", "17001", "Alimentação", "2", "2","","","","2","2","2" } )
        aAdd( aBody, { "", "000173", "17002", "Energia elétrica", "2", "2","","","","2","2","2" } )
        aAdd( aBody, { "", "000174", "17003", "Serviços prestados com emprego de materiais", "2", "2","","","","2","2", "2" } )
        aAdd( aBody, { "", "000175", "17004", "Construção Civil por empreitada com emprego de materiais", "2", "2","","","","2","2","2" } )
        aAdd( aBody, { "", "000176", "17005", "Serviços hospitalares de que trata o art. 30 da Instrução Normativa RFB nº 1.234, de 11 de janeiro de 2012", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000177", "17006", "Transporte de cargas, exceto os relacionados na natureza de rendimento '17017' ", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000178", "17007", "Serviços de auxílio diagnóstico e terapia, patologia clínica, imagenologia, anatomia patológica e citopatológica, medicina nuclear e análises e patologias clínicas, exames por métodos gráficos, procedimentos endoscópicos, radioterapia, quimioterapia, diálise e oxigenoterapia hiperbárica de que trata o art. 31 e parágrafo único da Instrução Normativa RFB nº 1.234, de 2012", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000179", "17008", "Produtos farmacêuticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista, exceto os relacionados nas naturezas de rendimentos de '17019' a '17022'", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000180", "17009", "Mercadorias e bens em geral", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000181", "17010", "Gasolina, inclusive de aviação, óleo diesel, gás liquefeito de petróleo (GLP), combustíveis derivados de petróleo ou de gás natural, querosene de aviação (QAV), e demais produtos derivados de petróleo, adquiridos de refinarias de petróleo, de demais produtores, de importadores, de distribuidor ou varejista", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000182", "17011", "Álcool etílico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000183", "17012", "Biodiesel adquirido de produtor ou importador", "2", "2","","","","2","2", "2"} )
        aAdd( aBody, { "", "000184", "17013", "Gasolina, exceto gasolina de aviação, óleo diesel e gás liquefeito de petróleo (GLP), derivados de petróleo ou de gás natural e querosene de aviação adquiridos de distribuidores e comerciantes varejistas", "2", "2","","","","2","2", "5"} )
        aAdd( aBody, { "", "000185", "17014", "Álcool etílico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista", "2", "2","","","","2","2","5"} )
        aAdd( aBody, { "", "000186", "17015", "Biodiesel adquirido de distribuidores e comerciantes varejistas", "2", "2","","","","2","2","5"} )
        aAdd( aBody, { "", "000187", "17016", "Biodiesel adquirido de produtor detentor regular do selo “Combustível Social”, fabricado a partir de mamona ou fruto, caroço ou amêndoa de palma produzidos nas regiões norte e nordeste e no semiárido, por agricultor familiar enquadrado no Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf)", "2", "2","","","","2","2", "5"} )
        aAdd( aBody, { "", "000188", "17017", "Transporte internacional de cargas efetuado por empresas nacionais", "2", "2","","","","2","2","5"} )
        aAdd( aBody, { "", "000189", "17018", "Estaleiros navais brasileiros nas atividades de Construção, conservação, modernização, conversão e reparo de embarcações pré-registradas ou registradas no REB", "2", "2","","","","2","2","5"} )
        aAdd( aBody, { "", "000190", "17019", "Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o § 1º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas", "2", "2","","","","2","2", "5"} )
        aAdd( aBody, { "", "000191", "17020", "Produtos a que se refere o § 2º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012","2", "2","","","","2","2", "5"} )
        aAdd( aBody, { "", "000192", "17021", "Produtos de que tratam as alíneas “c” a “k” do inciso I do art. 5º da Instrução Normativa RFB nº 1.234, de 2012", "2", "2","","","","2","2","5"} )
        aAdd( aBody, { "", "000193", "17022", "Outros produtos ou serviços beneficiados com isenção, não incidência ou alíquotas zero da Cofins e da Contribuição para o PIS/Pasep, observado o disposto no § 5º do art. 2º da Instrução Normativa RFB nº 1.234, de 2012","2","2","","","","2","2","5"} )
        aAdd( aBody, { "", "000194", "17023", "Passagens aéreas, rodoviárias e demais serviços de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros, efetuado por empresas nacionais", "2", "2","","","","2","2", "2"} )
        aAdd( aBody, { "", "000195", "17024", "Transporte internacional de passageiros efetuado por empresas nacionais","2","2","","","","2","2","5"} )
        aAdd( aBody, { "", "000196", "17025", "Serviços prestados por associações profissionais ou assemelhadas e cooperativas","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000197", "17026", "Serviços prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econômicas, sociedades de crédito, financiamento e investimento, sociedades de crédito imobiliário, e câmbio, distribuidoras de títulos e valores mobiliários, empresas de arrendamento mercantil, cooperativas de crédito, empresas de seguros privados e de capitalização e entidades abertas de previdência complementar","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000198", "17027", "Seguro Saúde","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000199", "17028", "Serviços de abastecimento de água", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000200", "17029", "Telefone","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000201", "17030", "Correio e telégrafos","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000202", "17031", "Vigilância", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000203", "17032", "Limpeza","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000204", "17033", "Locação de mão de obra", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000205", "17034", "Intermediação de negócios","2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000206", "17035", "Administração, locação ou cessão de bens imóveis, móveis e direitos de qualquer natureza", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000207", "17036", "Factoring", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000208", "17037", "Plano de saúde humano, veterinário ou odontológico com valores fixos por servidor, por empregado ou por animal", "2", "2","","","","2","2","2"} )
        aAdd( aBody, { "", "000209", "17038", "Pagamento efetuado a sociedade cooperativa pelo fornecimento de bens, conforme art. 24, da IN 1234/12.", "2", "2","","","","2","2","7"} )
        aAdd( aBody, { "", "000210", "17039", "Pagamento a Cooperativa de produção, em relação aos atos decorrentes da comercialização ou da industrialização de produtos de seus associados, excetuado o previsto no §§ 1º e 2º do art. 25 da IN 1.234/12", "2", "2","","","","2","2","8"} )
        aAdd( aBody, { "", "000211", "17040", "Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos – Serviços prestados com emprego de materiais, inclusive o de que trata a alínea “C” do Inciso II do art. 27 da IN 1.1234.", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000212", "17041", "Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos - Demais serviços", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000213", "17042", "Pagamentos efetuados às associações e às cooperativas de médicos e de odontólogos, relativamente às importâncias recebidas a título de comissão, taxa de administração ou de adesão ao plano", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000214", "17043", "Pagamento efetuado a sociedade cooperativa de produção, em relação aos atos decorrentes da comercialização ou de industrialização, pelas cooperativas agropecuárias e de pesca, de produtos adquiridos de não associados, agricultores, pecuaristas ou pescadores, para completar lotes destinados aoa cumprimento de contratos ou para suprir capacidade ociosa de suas instalações industriais, conforme § 1º do art. 25, da IN 1234/12.", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000215", "17044", "Pagamento referente a aluguel de imóvel quando efetuado à entidade aberta de previdência complementar sem fins lucrativos, de que trata o art 34, § 2º da IN 1.234/2012.", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000216", "17045", "Serviços prestados por cooperativas de radiotaxi, bem como àquelas cujos cooperados se dediquem a serviços relacionados a atividades culturais e demais cooperativas de serviços, conforme art. 5º–A, da IN RFB 1.234/2012.", "2","2","","","","2","2","4"} )
        aAdd( aBody, { "", "000217", "17046", "Pagamento efetuado na aquisição de bem imóvel, quando o vendedor for pessoa jurídica que exerce a atividade de compra e venda de imóveis, ou quando se tratar de imóveis adquiridos de entidades abertas de previdência complementar com fins lucrativos, conforme art. 23, inc I, da IN RFB 1234/2012.", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000218", "17047", "Pagamento efetuado na aquisição de bem imóvel adquirido pertencente ao ativo não circulante da empresa vendedora, conforme art. 23, inc II da IN RFB 1234/2012.", "2","2","","","","2","2","5"} )
        aAdd( aBody, { "", "000219", "17048", "Pagamento efetuado na aquisição de bem imóvel adquirido de entidade aberta de previdência complementar sem fins lucrativos, conforme art. 23, inc III, da IN RFB 1234/2012.", "2","2","","","","2","2","7"} )
        aAdd( aBody, { "", "000220", "17049", "Propaganda e Publicidade, em desconformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo.", "2","2","","","","2","2","9"} )
        aAdd( aBody, { "", "000221", "17050", "Propaganda e Publicidade, em conformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo.", "2","2","","","","2","2","2"} )
        aAdd( aBody, { "", "000222", "17099", "Demais serviços", "2","2","","","","2","2","2"} )

        //Grupo 18 - Rendimentos pagos/creditados EXCLUSIVAMENTE por órgãos, autarquias e fundações dos estados, do Distrito Federal e dos municípios
        aAdd( aBody, { "", "000223", "18001", "Fornecimento de bens, nos termos do art. 33 da Lei nº 10.833, de 2003", "2","2","","","","2","2","7"} )
        aAdd( aBody, { "", "000224", "18002", "Prestação de serviços em geral, nos termos do art. 33 da Lei nº 10.833, de 2003", "2","2","","","","2","2","7"} )
        aAdd( aBody, { "", "000225", "18003", "Transporte internacional de cargas ou de passageiros efetuados por empresas nacionais, aos estaleiros navais brasileiros e na aquisição de produtos isentos ou com Alíquota zero da Cofins e Pis/Pasep, conforme art. 4º, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","6"} )
        aAdd( aBody, { "", "000226", "18004", "Pagamentos efetuados às cooperativas, em relação aos atos cooperativos, conforme art. 5º, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","3"} )
        aAdd( aBody, { "", "000227", "18005", "Aquisição de imóvel pertencente a ativo permanente da empresa vendedora, conforme art. 19, II, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","6"} )
        aAdd( aBody, { "", "000228", "18006", "Pagamentos efetuados às sociedades cooperativas, pelo fornecimento de bens ou serviços, conforme art. 24, II, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","3"} )
        aAdd( aBody, { "", "000229", "18007", "Pagamentos efetuados à sociedade cooperativa de produção, em relação aos atos decorrentes da comercialização ou industrialização de produtos de seus associados, conforme art. 25, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","8"} )
        aAdd( aBody, { "", "000230", "18008", "Pagamentos efetuados às cooperativas de trabalho, pela prestação de serviços pessoais prestados pelos cooperados, nos termos do art. 26, da IN SRF nº 475 de 2004.", "2","2","","","","2","2","7"} )
        
        //Grupo 19 - Pagamento a Beneficiário não Identificado – Uso exclusivo para o evento R-4040
        aAdd( aBody, { "", "000231", "19001", "Pagamento de remuneração indireta a Beneficiário não identificado", "2","2","","","","2","2","1"} )
        aAdd( aBody, { "", "000232", "19009", "Pagamento a Beneficiário não identificado", "2","2","","","","2","2","1"} )

        //Grupo 20 - Rendimento Pago/Creditado a Pessoa Jurídica – Uso exclusivo para o evento R-4080 – Retenção no Recebimento
        aAdd( aBody, { "", "000233", "20001", "Rendimento de Serviços de propaganda e publicidade", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000234", "20002", "Importâncias a título de comissões e corretagens relativas a colocação ou negociação de títulos de renda fixa", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000235", "20003", "Importâncias a título de comissões e corretagens relativas a operações realizadas em Bolsas de Valores e em Bolsas de Mercadorias", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000236", "20004", "Importâncias a título de comissões e corretagens relativas a distribuição de emissão de valores mobiliários, quando a pessoa jurídica atuar como agente da companhia emissora", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000237", "20005", "Importâncias a título de comissões e corretagens relativas a operações de câmbio", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000238", "20006", "Importâncias a título de comissões e corretagens relativas a vendas de passagens, excursões ou viagens", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000239", "20007", "Importâncias a título de comissões e corretagens relativas a administração de cartões de crédito", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000240", "20008", "Importâncias a título de comissões e corretagens relativas a prestação de serviços de distribuição de refeições pelo sistema de refeições-convênio", "2","2","2","","","2","2","1"} )
        aAdd( aBody, { "", "000241", "20009", "Importâncias a título de comissões e corretagens relativas a prestação de serviço de administração de convênios", "2","2","2","","","2","2","1"} )

        //Grupo 15 - Rendimento Pago/Creditado a Pessoa Jurídica (CONTINUAÇÃO do grupo 15 - Item adicionado no layout da Reinf 02_01_02)
        aAdd( aBody, { "", "000242", "15052", "Demais comissões, corretagens, ou qualquer outra importância paga/creditada pela representação comercial ou pela mediação na realização de negócios civis e comerciais, que não se enquadrem nas situações listadas nos códigos do grupo 20", "2", "2", "2", "", "", "2", "2", "1"})

        //Grupo 12 - Rendimento do Capital (CONTINUAÇÃO do grupo 12 - Item adicionado no layout da Reinf 02_01_02)
        aAdd( aBody, { "", "000243", "12052", "Juros sobre o Capital Próprio cujos beneficiários não estejam identificados no momento do registro contábil", "1", "2", "2", "", "", "2", "2", "1"})

        //Grupo 11 - 
        aAdd( aBody, { "", "000244", "11006", "Rendimentos pagos sem retenção do IR na fonte – Lei 10.833/2003", "2", "2", "2", "", "", "1", "1", "8"})

        aAdd( aBody, { "", "000245", "11007", "Decorrente de Decisão da Justiça dos Estados/Distrito Federal - IRRF pertencente aos Estados/Municípios", "2", "1", "1", "1,2,3,4,5,7,8", "6,10", "3", "3", "1"})
        aAdd( aBody, { "", "000246", "17051", "Pagamentos a entidades imunes ou isentas - IN RFB 1.234/2012", "2", "2", "2", "", "", "2", "2", "8"})

        //Grupo 12 - Itens adicionados conforme a NT EFD-Reinf 02/2024
        aAdd( aBody, { "", "000247", "12053", "Rendimentos e ganhos de capital distribuídos e resgate de cotas de Fundo de Investimento nas Cadeias Produtivas do Agronegócio (Fiagro) conforme art. 20-C e D da Lei 8.668 de 1993", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000248", "12054", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Participações (FIP) classificado como entidade de investimento (art. 18 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000249", "12055", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Índice de Mercado (Exchange Traded Fund - ETF) classificado como entidade de investimento (art. 18 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000250", "12056", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Direitos Creditórios (FIDC) classificado como entidade de investimento (art. 18 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000251", "12057", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Participações (FIP) não classificado como entidade de investimento e sujeito à tributação periódica (art. 26 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000252", "12058", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Índice de Mercado (Exchange Traded Fund - ETF) não classificado como entidade de investimento e sujeito à tributação periódica (art. 26 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000253", "12059", "Rendimentos distribuídos, resgate ou amortização de cotas de Fundo de Investimento em Direitos Creditórios (FIDC) não classificado como entidade de investimento e sujeito à tributação periódica (art. 26 da Lei nº 14.754 de 2023)", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000254", "12060", "Rendimentos e ganhos de capital auferidos por cotistas de Fundo de Índice de Renda Fixa (ETF) conforme art. 2º da Lei nº 13.043 de 2014", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000255", "12061", "Rendimentos distribuidos, resgate ou amortizacao de cotas de Fundo Multimercado(FIM) conforme art. 40 da Lei n® 14.754 de 2023", "1", "2", "2", "", "", "2", "2", "1"})
        aAdd( aBody, { "", "000256", "12062", "Rendimentos decorrente de debéntures de infraestrutura conforme previsto no art. 4º da Lei nº 14.801 de 2024, quando auferidos pelos fundos isentos no resgate, na amortização e na alienação de cotas ou na distribuição de rendimentos.", "1", "2", "2", "", "", "2", "2", "1"})

        //Grupo 17 - NOTA TÉCNICA EFD-REINF 03/2025 - Inclusão dos códigos de natureza de rendimento 17501 a 17538, 17540 a 17550 e 17599 (Continuação do grupo 17)
        //Rendimentos pagos/creditados por órgãos da administração pública na forma da IN RFB 1234/2012
        aAdd( aBody, { "", "000257", "17501", "Intraorçamentário - Alimentação",      "2", "2","2","","","2","2","2" } )
        aAdd( aBody, { "", "000258", "17502", "Intraorçamentário - Energia elétrica", "2", "2","2","","","2","2","2" } )
        aAdd( aBody, { "", "000259", "17503", "Intraorçamentário - Serviços prestados com emprego de materiais", "2", "2","2","","","2","2", "2" } )
        aAdd( aBody, { "", "000260", "17504", "Intraorçamentário - Construção Civil por empreitada com emprego de materiais", "2", "2","2","","","2","2","2" } )
        aAdd( aBody, { "", "000261", "17505", "Intraorçamentário - Serviços hospitalares de que trata o art. 30 da Instrução Normativa RFB nº 1.234, de 11 de janeiro de 2012", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000262", "17506", "Intraorçamentário - Transporte de cargas, exceto os relacionados na natureza de rendimento '17517' ", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000263", "17507", "Intraorçamentário - Serviços de auxílio diagnóstico e terapia, patologia clínica, imagenologia, anatomia patológica e citopatológica, medicina nuclear e análises e patologias clínicas, exames por métodos gráficos, procedimentos endoscópicos, radioterapia, quimioterapia, diálise e oxigenoterapia hiperbárica de que trata o art. 31 e parágrafo único da Instrução Normativa RFB nº 1.234, de 2012", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000264", "17508", "Intraorçamentário - Produtos farmacêuticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista, exceto os relacionados nas naturezas de rendimentos de '17519' a '17522'", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000265", "17509", "Intraorçamentário - Mercadorias e bens em geral", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000266", "17510", "Intraorçamentário - Gasolina, inclusive de aviação, óleo diesel, gás liquefeito de petróleo (GLP), combustíveis derivados de petróleo ou de gás natural, querosene de aviação (QAV), e demais produtos derivados de petróleo, adquiridos de refinarias de petróleo, de demais produtores, de importadores, de distribuidor ou varejista", "2", "2","2","","","2","2","9"} )
        aAdd( aBody, { "", "000267", "17511", "Intraorçamentário - Álcool etílico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor", "2", "2","2","","","2","2","9"} )
        aAdd( aBody, { "", "000268", "17512", "Intraorçamentário - Biodiesel adquirido de produtor ou importador", "2", "2","2","","","2","2", "9"} )
        aAdd( aBody, { "", "000269", "17513", "Intraorçamentário - Gasolina, exceto gasolina de aviação, óleo diesel e gás liquefeito de petróleo (GLP), derivados de petróleo ou de gás natural e querosene de aviação adquiridos de distribuidores e comerciantes varejistas", "2", "2","2","","","2","2", "4"} )
        aAdd( aBody, { "", "000270", "17514", "Intraorçamentário - Álcool etílico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista", "2", "2","2","","","2","2","9"} )
        aAdd( aBody, { "", "000271", "17515", "Intraorçamentário - Biodiesel adquirido de distribuidores e comerciantes varejistas", "2", "2","2","","","2","2","9"} )
        aAdd( aBody, { "", "000272", "17516", "Intraorçamentário - Biodiesel adquirido de produtor detentor regular do selo “Combustível Social”, fabricado a partir de mamona ou fruto, caroço ou amêndoa de palma produzidos nas regiões norte e nordeste e no semiárido, por agricultor familiar enquadrado no Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf)", "2", "2","2","","","2","2", "9"} )
        aAdd( aBody, { "", "000273", "17517", "Intraorçamentário - Transporte internacional de cargas efetuado por empresas nacionais", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000274", "17518", "Intraorçamentário - Estaleiros navais brasileiros nas atividades de Construção, conservação, modernização, conversão e reparo de embarcações pré-registradas ou registradas no REB", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000275", "17519", "Intraorçamentário - Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o § 1º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000276", "17520", "Intraorçamentário - Produtos a que se refere o § 2º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000277", "17521", "Intraorçamentário - Produtos de que tratam as alíneas “c” a “k” do inciso I do art. 5º da Instrução Normativa RFB nº 1.234, de 2012", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000278", "17522", "Intraorçamentário - Outros produtos ou serviços beneficiados com isenção, não incidência ou alíquotas zero da Cofins e da Contribuição para o PIS/Pasep, observado o disposto no § 5º do art. 2º da Instrução Normativa RFB nº 1.234, de 2012","2","2","2","","","2","2","5"} )
        aAdd( aBody, { "", "000279", "17523", "Intraorçamentário - Passagens aéreas, rodoviárias e demais serviços de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros, efetuado por empresas nacionais", "2", "2","2","","","2","2", "2"} )
        aAdd( aBody, { "", "000280", "17524", "Intraorçamentário - Transporte internacional de passageiros efetuado por empresas nacionais","2","2","2","","","2","2","5"} )
        aAdd( aBody, { "", "000281", "17525", "Intraorçamentário - Serviços prestados por associações profissionais ou assemelhadas e cooperativas","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000282", "17526", "Intraorçamentário - Serviços prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econômicas, sociedades de crédito, financiamento e investimento, sociedades de crédito imobiliário, e câmbio, distribuidoras de títulos e valores mobiliários, empresas de arrendamento mercantil, cooperativas de crédito, empresas de seguros privados e de capitalização e entidades abertas de previdência complementar","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000283", "17527", "Intraorçamentário - Seguro Saúde","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000284", "17528", "Intraorçamentário - Serviços de abastecimento de água", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000285", "17529", "Intraorçamentário - Telefone","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000286", "17530", "Intraorçamentário - Correio e telégrafos","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000287", "17531", "Intraorçamentário - Vigilância", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000288", "17532", "Intraorçamentário - Limpeza","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000289", "17533", "Intraorçamentário - Locação de mão de obra", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000290", "17534", "Intraorçamentário - Intermediação de negócios","2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000291", "17535", "Intraorçamentário - Administração, locação ou cessão de bens imóveis, móveis e direitos de qualquer natureza", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000292", "17536", "Intraorçamentário - Factoring", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000293", "17537", "Intraorçamentário - Plano de saúde humano, veterinário ou odontológico com valores fixos por servidor, por empregado ou por animal", "2", "2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000294", "17538", "Intraorçamentário - Pagamento efetuado a sociedade cooperativa pelo fornecimento de bens, conforme art. 24, da IN 1234/12.", "2", "2","2","","","2","2","7"} )
        aAdd( aBody, { "", "000295", "17540", "Intraorçamentário - Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos – Serviços prestados com emprego de materiais, inclusive o de que trata a alínea “C” do Inciso II do art. 27 da IN 1.1234.", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000296", "17541", "Intraorçamentário - Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos - Demais serviços", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000297", "17542", "Intraorçamentário - Pagamentos efetuados às associações e às cooperativas de médicos e de odontólogos, relativamente às importâncias recebidas a título de comissão, taxa de administração ou de adesão ao plano", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000298", "17543", "Intraorçamentário - Pagamento efetuado a sociedade cooperativa de produção, em relação aos atos decorrentes da comercialização ou de industrialização, pelas cooperativas agropecuárias e de pesca, de produtos adquiridos de não associados, agricultores, pecuaristas ou pescadores, para completar lotes destinados ao cumprimento de contratos ou para suprir capacidade ociosa de suas instalações industriais, conforme § 1º do art. 25, da IN 1234/12.", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000299", "17544", "Intraorçamentário - Pagamento referente a aluguel de imóvel quando efetuado à entidade aberta de previdência complementar sem fins lucrativos, de que trata o art 34, § 2º da IN 1.234/2012.", "2","2","2","","","2","2","7"} )
        aAdd( aBody, { "", "000300", "17545", "Intraorçamentário - Serviços prestados por cooperativas de radiotaxi, bem como àquelas cujos cooperados se dediquem a serviços relacionados a atividades culturais e demais cooperativas de serviços, conforme art. 5º–A, da IN RFB 1.234/2012.", "2","2","2","","","2","2","4"} )
        aAdd( aBody, { "", "000301", "17546", "Intraorçamentário - Pagamento efetuado na aquisição de bem imóvel, quando o vendedor for pessoa jurídica que exerce a atividade de compra e venda de imóveis, ou quando se tratar de imóveis adquiridos de entidades abertas de previdência complementar com fins lucrativos, conforme art. 23, inc I, da IN RFB 1234/2012.", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000302", "17548", "Intraorçamentário - Pagamento efetuado na aquisição de bem imóvel adquirido de entidade aberta de previdência complementar sem fins lucrativos, conforme art. 23, inc III, da IN RFB 1234/2012.", "2","2","2","","","2","2","7"} )
        aAdd( aBody, { "", "000303", "17549", "Intraorçamentário - Propaganda e Publicidade, em desconformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo.", "2","2","2","","","2","2","9"} )
        aAdd( aBody, { "", "000304", "17550", "Intraorçamentário - Propaganda e Publicidade, em conformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo.", "2","2","2","","","2","2","2"} )
        aAdd( aBody, { "", "000305", "17599", "Intraorçamentário - Demais serviços", "2","2","2","","","2","2","2"} )

        aAdd( aRet, { aHeader, aBody } )
    EndIf
EndIf
   
Return( aRet )
