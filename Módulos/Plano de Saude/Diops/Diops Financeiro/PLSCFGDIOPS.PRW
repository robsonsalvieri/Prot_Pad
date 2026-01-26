#include "Protheus.ch"
#include "FWMVCDef.ch"

Static cCadastro := "Configurador DIOPS Financeiro"

#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status ATIVO
#define CRITICADO   "3" // status na Centra de Obrigações 

#define CODQUADRO   2   // codigo do quadro
#define DESQUADRO   3   // descricao do quadro
#define TABQUADRO   4   // tabela (alias)
#define FNCQUADRO   5   // funcao de execução do extrator 
#define CENQUADRO   6   // codigo do quadro na central de obrigações
#define CENVALID    7   // validacao automatica .T. ou .F. 

#define QDR_PLANO   ""  // Plano de Contas ANS
#define QDR_BALANC	"1"	 // Balancete Trimestral
#define QDR_CADAST	"2"	 // Dados Cadatrai
#define QDR_AGIMOB	"3"	 // Ativos Garantidores - Imobiliario
#define QDR_FLUXCA	"4"	 // Fluxo de Caixa Trimestral
#define QDR_IDASPA	"5"	 // Idade de Saldos - Contas a Pagar - Passivo
#define QDR_LUCPRE	"6"	 // Lucros e Prejuízos
#define QDR_CONEST	"7"	 // Contratos Estipulados
#define QDR_CONREP	"8"	 // Segregação do Montante de Contraprestações a Repassar
#define QDR_COBASS	"9"	 // Cobertura Assistencial
#define QDR_EVEIND	"11" // Movimentação de Eventos Indenizáveis
#define QDR_AGRCON	"12" // Agrupamento de Contratos
#define QDR_PESL	"13" // Saldo da Provisão de Eventos Sinistros a Liquidar
#define QDR_CCCOOP	"14" // Conta-Corrente Cooperado
#define QDR_CTRPAS	"15" // Conta Tributo Passivo
#define QDR_IDASRE	"16" // Idade de Saldos - Contas a Receber - Ativo
#define QDR_EVECOR	"18" // Eventos em Corresponsabilidade (2018)
#define QDR_FUNCOM	"19" // Programas-Fundos Comuns de Despesas Assistenciais (2018)
#define QDR_EVCCC	"20" // Eventos de Contraprestação de Corresponsabilidade Cedid
#define QDR_MPC		"21" // Modelo Padrão de Capital
#define QDR_TAP		"22" // Teste de Adequação do Passivo - TAP
#define QDR_CONPEC	"23" // Contraprestações Pecuniárias.
#define QDR_INAD    "98" // Inadimplencia
#define QDR_RISCO   "99" // Risco de Mercado 

#define __CODPLA    "06/07/13/19"   // Quadros que podem Utilizar Visao Gerencial no Extrator Diosp Financeiro

/*/{Protheus.doc} PLSCFGDIOPS
Configurador dos Extrator DIOPS Financeiro
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSCFGDIOPS()
Local oBrowse   := Nil

    // Chamada da função para inicializar as tabelas do configurador Diops Financeiro
    fIniParDIOPS()

    // cria o objeto Browse com os controles de manuteção da tabela de valor
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("B3I")
    oBrowse:SetDescription(cCadastro)

    // configuração das legendas para facilitar a visualização pelo usuário
    oBrowse:AddLegend("B3I_STATUS == '1' .And. FindFunction(B3I_ROTINA)"    , "GREEN" , "Quadro de Detalhamento esta Ativo no Extrador DIOPS Financeiro"	      )
    oBrowse:AddLegend("B3I_STATUS == '1' .And. !FindFunction(B3I_ROTINA)"   , "RED"   , "Quadro de Detalhamento não compilado no Extrador DIOPS Financeiro"       )     
    oBrowse:AddLegend("B3I_STATUS == '0'"                                   , "BLACK" , "Quadro de Detalhamento não será executado pelo Extrator DIOPS Financeiro")

    // ativa o controle 
    oBrowse:DisableDetails()
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria o menu utilizado pelo modelo MVC
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PLSCFGDIOPS" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.PLSCFGDIOPS" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE "Atualizar"  ACTION "PLSATUDIOPS"         OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4    

Return aRotina

/*/{Protheus.doc} ModelDef
Cria o modelo de dados MVC
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStruB3I 		:= FWFormStruct(1, "B3I")
	Local oStruB3Y 		:= FWFormStruct(1, "B3Y")
	Local oStruBRK 		:= FWFormStruct(1, "BRK")
	Local aRelB3Y		:= {}
	Local aRelBRK		:= {}
	
    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("MCFGDIOPS", /*bPreValidacao*/, /*bPosValidacao*/ , /*bPosGrava*/ , /*bCancel*/ )
    // Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("B3IMASTER",/*cOwner*/,oStruB3I)

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("B3YDETAIL"  ,"B3IMASTER",oStruB3Y,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:AddGrid("BRKDETAIL"  ,"B3YDETAIL",oStruBRK,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

    // Não permite inserir linhas na grid de Itens 
    oModel:GetModel("B3YDETAIL"):SetNoInsertLine( .T. )
    oModel:GetModel("B3YDETAIL"):SetNoDeleteLine( .T. )

	//Relacionamento da tabela Itens x Cadastro DIOPS Financeiro
	aAdd(aRelB3Y, {"B3Y_FILIAL" ,"xFilial('B3Y')"      })
	aAdd(aRelB3Y, {"B3Y_CODIGO" ,"B3I_CODIGO"          })
	
	//Relacionamento da tabela Contas Contabeis x Itens
	aAdd(aRelBRK, {"BRK_FILIAL" ,"xFilial('BRK')"      })
	aAdd(aRelBRK, {"BRK_CODIGO" ,"B3Y_CODIGO"          }) 
	aAdd(aRelBRK, {"BRK_ITEM"   ,"B3Y_ITEM"            }) 
	
    // Controle de nao repeticao de linha
	oModel:SetRelation("B3YDETAIL", aRelB3Y, B3Y->(IndexKey(1))) 
	oModel:GetModel("B3YDETAIL"):SetUniqueLine({"B3Y_ITEM"})
	oModel:SetPrimaryKey({"B3Y_FILIAL","B3Y_CODIGO","B3Y_ITEM","B3Y_SEQUEN"})
	
	oModel:SetRelation("BRKDETAIL", aRelBRK, BRK->(IndexKey(1))) 
	oModel:GetModel("BRKDETAIL"):SetUniqueLine({"BRK_CONTA","BRK_CCUSTO"})
	oModel:SetPrimaryKey({"BRK_FILIAL","BRK_CODIGO","BRK_ITEM","BRK_SEQUEN","BRK_CONTA"})
	
    // Desabilita a edicao de todos os campos do modelo        
    oStruB3I:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})        
    oStruB3Y:SetProperty("*",MODEL_FIELD_WHEN,{||.F.}) 

    // Adiciona condicao para editar os campos do cabecalho
    oStruB3I:SetProperty("B3I_STATUS",MODEL_FIELD_WHEN,{||.T.})
    oStruB3I:SetProperty("B3I_TIPVLD",MODEL_FIELD_WHEN,{||.T.})

    // Verifica o campo Cod Visao existe na base 
    If FieldPos("B3I_CODPLA") > 0
        oStruB3I:SetProperty("B3I_CODPLA",MODEL_FIELD_WHEN,{||.F.})
    EndIf

    // Adiciona validacao de campo 
    oStruBRK:SetProperty("BRK_CONTA" ,MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID,"Vazio() .Or. ExistCpo('CT1',FWFldGet('BRK_CONTA' ),1)"))
    oStruBRK:SetProperty("BRK_CCUSTO",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID,"Vazio() .Or. ExistCpo('CTT',FWFldGet('BRK_CCUSTO'),1)"))

    //Deixa o prenchimento das tabelas opcional
    oModel:GetModel("B3YDETAIL"):SetOptional( .T. )   
    oModel:GetModel("BRKDETAIL"):SetOptional( .T. )    

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription("Configurador DIOPS Financeiro")
	oModel:GetModel("B3IMASTER"):SetDescription("Quadros de Detalhamento")
	oModel:GetModel("B3YDETAIL"):SetDescription("Itens dos Quadros")
	oModel:GetModel("BRKDETAIL"):SetDescription("Contas Contábeis")
	
Return oModel

/*/{Protheus.doc} ViewDef
Cria a visão do modelo de dados MVC
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel("PLSCFGDIOPS")
	Local oStruB3I	:= FWFormStruct(2, "B3I")
	Local oStruB3Y	:= FWFormStruct(2, "B3Y")
	Local oStruBRK	:= FWFormStruct(2, "BRK")
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_B3I",oStruB3I,"B3IMASTER")
	oView:AddGrid("VIEW_B3Y",oStruB3Y,"B3YDETAIL")
	oView:AddGrid("VIEW_BRK",oStruBRK,"BRKDETAIL")
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",25)
	oView:CreateHorizontalBox("GRID1",35)
	oView:CreateHorizontalBox("GRID2",40)
	
	//Amarrando a view com as box
	oView:SetOwnerView("VIEW_B3I","CABEC")
	oView:SetOwnerView("VIEW_B3Y","GRID1")
	oView:SetOwnerView("VIEW_BRK","GRID2")

    //Campo incremental
    oView:AddIncrementField("VIEW_BRK", "BRK_SEQUEN")
	
	//Habilitando título
	oView:EnableTitleView("VIEW_B3I","Quadro de Detalhamento")
	oView:EnableTitleView("VIEW_B3Y","Itens do Quadro")
	oView:EnableTitleView("VIEW_BRK","Configuração das Contas Contábeis")
	
Return oView

/*/{Protheus.doc} fIniParDIOPS()
Inicializa tabelas de parâmetros do Configurador DIOPS Financeiro  
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fIniParDIOPS()
Local aQuadros  := {}
Local aItens    := {}
Local cCodigo
Local cDescri
Local cIdQuadro
Local cItem
Local cSequen
Local nI

    // Tabela QUADROS DIOPS FINANCEIRO
    dbSelectArea("B3I")       
    B3I->(dbSetOrder(1))    //B3I_FILIAL+B3I_CODIGO

    // Tabela ITENS DOS QUADROS DIOPS FINANC
    dbSelectArea("B3Y")
    B3Y->(dbSetOrder(1))    //B3Y_FILIAL+B3Y_CODIGO+B3Y_SEQUEN+B3Y_ITEM

    // Tabela CONFIGURACAO DOS QUADROS DIOPS
    dbSelectArea("BRK")  
    BRK->(dbSetOrder(1))    //BRK_FILIAL+BRK_COD+BRK_ITEM+BRK_SEQ

    // monta array de atributos dos quadros DIOPS Financeiro
    //aAdd(aQdrAux,{/*01 Flag*/,/*02 codigo*/,/*03 Descricao*/,/*04 Tabela*/,/*05 Função*/,/*06 IDCentral*/,/*07 Valida*/})   
    aAdd(aQuadros,{.F.,"01","Plano de Contas ANS"                                            ,"B8B"  ,"PLSEXTPLA",QDR_PLANO ,.F.})  
    aAdd(aQuadros,{.F.,"02","Balancete"                                                      ,"B8A"  ,"PLSEXTBAL",QDR_BALANC,.T.})
    aAdd(aQuadros,{.F.,"03","Ativos Garantidores Imobiliário"                                ,"B8C"  ,"PLSEXTAGI",QDR_AGIMOB,.T.})
    aAdd(aQuadros,{.F.,"04","Idade dos Saldos - A Pagar"                                     ,"B8F"  ,"PLSEXTIPG",QDR_IDASPA,.T.})
    aAdd(aQuadros,{.F.,"05","Idade dos Saldos - A Receber"                                   ,"B8G"  ,"PLSEXTIRC",QDR_IDASRE,.T.})
    aAdd(aQuadros,{.F.,"06","Lucros e Prejuízos"                                             ,"B8E"  ,"PLSEXTLCR",QDR_LUCPRE,.T.})
    aAdd(aQuadros,{.F.,"07","Fluxo de Caixa"                                                 ,"B8H"  ,"PLSEXTFLX",QDR_FLUXCA,.T.}) 
    aAdd(aQuadros,{.F.,"08","Cobertura Assistencial"                                         ,"B8I"  ,"PLSEXTCBA",QDR_COBASS,.T.})
    aAdd(aQuadros,{.F.,"09","Saldo da Provisão de Eventos/Sinistros a Liquidar"              ,"B8J"  ,"PLSEXTPEL",QDR_PESL  ,.T.})
    aAdd(aQuadros,{.F.,"10","Movimentação de Agrupamento de Contratos"                       ,"B8K"  ,"PLSEXTACT",QDR_AGRCON,.T.})
    aAdd(aQuadros,{.F.,"11","Movimentação de Eventos Indenizáveis"                           ,"B8L"  ,"PLSEXTEVI",QDR_EVEIND,.T.})
    aAdd(aQuadros,{.F.,"12","Contraprestação de Corresponsabilidade Cedida"                  ,"B36"  ,"PLSEXTCOR",QDR_EVECOR,.T.})
    aAdd(aQuadros,{.F.,"13","Fundos Comuns de Despesas Assistenciais"                        ,"B6R"  ,"PLSEXTFCO",QDR_FUNCOM,.T.})
    aAdd(aQuadros,{.F.,"14","Modelo Padrão de Capital"                                       ,"B82"  ,"PLSEXTMPC",QDR_MPC   ,.T.})
    aAdd(aQuadros,{.F.,"15","Contraprestações Pecuniárias"                                   ,"B37"  ,"PLSEXTCPE",QDR_CONPEC,.T.})
    aAdd(aQuadros,{.F.,"16","Segregação do Montante de Contraprestações a Repassar"          ,"BVS"  ,"PLSEXTREP",QDR_CONREP,.T.})
    aAdd(aQuadros,{.F.,"17","Contratos Estipulados"                                          ,"BUP"  ,"PLSEXTEST",QDR_CONEST,.T.})
    aAdd(aQuadros,{.F.,"18","Percentual de Inadimplência (Administradora de Benefícios)"     ,"B7W"  ,"PLSEXTINA",QDR_INAD  ,.F.})
    aAdd(aQuadros,{.F.,"19","Conta Tributo Passivo"                                          ,"BUY"  ,"PLSEXTCTP",QDR_CTRPAS,.T.})
    aAdd(aQuadros,{.F.,"20","Quadro Auxiliar de Risco de Mercado"                            ,"BVU"  ,"PLSEXTRIS",QDR_RISCO ,.T.})    

    // Inclusao dos quadros na tabela do configurador Diops Financeiro 
    For nI := 1 to Len(aQuadros)
        // Id do Quadro  
        cCodigo := aQuadros[nI,CODQUADRO]
        cDescri := aQuadros[nI,CODQUADRO]
        cIdQuadro := aQuadros[nI,CENQUADRO]

        // Verifica se o Quadro ainda não foi incluido na tabela do Configurador Diops Financeiro 
        If B3I->(!dbSeek(xFilial("B3I")+cCodigo))
            RecLock("B3I",.t.)
            B3I->B3I_FILIAL := xFilial("B3I")
            B3I->B3I_CODIGO := aQuadros[nI,CODQUADRO]
            B3I->B3I_DESCRI := aQuadros[nI,DESQUADRO]
            B3I->B3I_ALIAS  := aQuadros[nI,TABQUADRO]
            B3I->B3I_ROTINA := aQuadros[nI,FNCQUADRO]
            B3I->B3I_STATUS := ATIVO
            B3I->B3I_TIPVLD := IIf(aQuadros[nI,CENVALID],"1","2") //Tipo de Validação: 1=Autormatica 2=Manual  
            B3I->B3I_IDQDR  := aQuadros[nI,CENQUADRO]       
            B3I->(msUnLock())
        EndIf 

        // No passo abaixo, serão criados os itens do Configurador de cada Quadro e 
        // incluidas as parametrizações de contas contábeis para que o cliente 
        // possa atualizar conforme o plano de contas OU customizar com novas contas contábeis 
        // Os Quadros "Lucros e Prejuízos" e "Fluxo de Caixa" fazem uso da função utilizada no dicionario de dados para retornar as opções  
        // aItens = Array onde serão adicionados os atributos de cada Quadro para inclusão na tabela BRK
        // Os Quadros Plano de Contas ANS e Balancete Trimestral não utilizam parametrização de contas contábeis        
        Do Case
            // Ativos Garantidores Imobiliário
            Case cIdQuadro==QDR_AGIMOB  
                aAdd(aItens,{cCodigo,"01","AGI","Ativos Garantidores Imobiliário"})

            // Idade dos Saldos - A Pagar    
            Case cIdQuadro==QDR_IDASPA  
                aAdd(aItens,{cCodigo,"01","SUS","Eventos ou sinistros a liquidar referente ao ressarcimento SUS"})
                aAdd(aItens,{cCodigo,"02","EVE","Eventos/Sinistros a Liquidar"})
                aAdd(aItens,{cCodigo,"03","CSO","Comercialização sobre Operações"})
                aAdd(aItens,{cCodigo,"04","DOP","Débitos com outras operadoras"})
                aAdd(aItens,{cCodigo,"05","ODO","Outros débitos com operadoras de saúde"})
                aAdd(aItens,{cCodigo,"06","TOE","Títulos e outros encargos a recolher"})
                aAdd(aItens,{cCodigo,"07","DEP","Depósitos realizados por beneficiários"})
                aAdd(aItens,{cCodigo,"08","ASS","Serviços de assistência à saúde"})
                aAdd(aItens,{cCodigo,"09","AQC","Débitos com aquisição de carteira de beneficiários"})
                aAdd(aItens,{cCodigo,"10","ODP","Outros Debitos a Pagar"})

            // Idade dos Saldos - A Receber   
            Case cIdQuadro==QDR_IDASRE  
                aAdd(aItens,{cCodigo,"01","IN1","Invididual Preço Pré-estabelecido"})
                aAdd(aItens,{cCodigo,"02","IN2","Individual Preço Pós-estabelecido"})
                aAdd(aItens,{cCodigo,"03","CO1","Coletivo Preço Pré-estabelecido"})
                aAdd(aItens,{cCodigo,"04","CO2","Coletivo Preço Pós-estabelecido"})                
                aAdd(aItens,{cCodigo,"05","COB","Credito Operação Beneficiários"})
                aAdd(aItens,{cCodigo,"06","PAR","Participação de beneficiários em eventos ou sinistros"})
                aAdd(aItens,{cCodigo,"07","CR1","Creditos de operadoras"})
                aAdd(aItens,{cCodigo,"08","CR2","Credito de Operadoras em planos Pos Pagamento"})
                aAdd(aItens,{cCodigo,"09","OC1","Outros creditos com planos"})
                aAdd(aItens,{cCodigo,"10","OC2","Outros creditos nao relacionados a planos"})

            // Lucros e Prejuízos  
            Case cIdQuadro==QDR_LUCPRE  
                aAdd(aItens,{cCodigo,"01","1","Lucros distribuidos (-)"})
                aAdd(aItens,{cCodigo,"02","2","Constituição de reservas (-)"})
                aAdd(aItens,{cCodigo,"03","3","Reversão de reservas (+)"})
                aAdd(aItens,{cCodigo,"04","5","Juros sobre capital próprio (-)"})
                aAdd(aItens,{cCodigo,"05","6","Ajustes de exercícios anteriores (com sinal)"})
                aAdd(aItens,{cCodigo,"06","7","Lucro incorporado ao capital (-)"})
                aAdd(aItens,{cCodigo,"07","8","Outros (com sinal)"})

            // Fluxo de Caixa  
            Case cIdQuadro==QDR_FLUXCA  
                aAdd(aItens,{cCodigo,"01","101", "Recebimentos de Plano Saúde (+)"})
                aAdd(aItens,{cCodigo,"02","102", "Resgate de Aplicações Financeiras (+)"})
                aAdd(aItens,{cCodigo,"03","103", "Recebimentos de Juros de Aplicações Financeiras (+)"})
                aAdd(aItens,{cCodigo,"04","104", "Outros Recebimentos Operacionais (+)"})
                aAdd(aItens,{cCodigo,"05","105", "Pagamentos a Fornecedores/Prestadores de Serviço de Saúde (-)"})
                aAdd(aItens,{cCodigo,"06","106", "Pagamentos de Comissões (-)"})
                aAdd(aItens,{cCodigo,"07","107", "Pagamentos de Pessoal (-)"})
                aAdd(aItens,{cCodigo,"08","108", "Pagamentos de Pró-Labore (-)"})
                aAdd(aItens,{cCodigo,"09","109", "Pagamentos de Serviços Terceiros (-)"})
                aAdd(aItens,{cCodigo,"10","110", "Pagamentos de Tributos (-)"})
                aAdd(aItens,{cCodigo,"11","111", "Pagamentos de Processos Judiciais (-) (Cíveis/Trabalhistas/Tributárias)"})
                aAdd(aItens,{cCodigo,"12","112", "Pagamentos de Aluguel (-)"})
                aAdd(aItens,{cCodigo,"13","113", "Pagamentos de Promoção/Publicidade (-)"})
                aAdd(aItens,{cCodigo,"14","114", "Aplicações Financeiras (-)"})
                aAdd(aItens,{cCodigo,"15","115", "Outros Pagamentos Operacionais (-)"})
                aAdd(aItens,{cCodigo,"16","201", "Recebimentos de Venda de Ativo Imobilizado - Hospitalar (+)"})
                aAdd(aItens,{cCodigo,"17","202", "Recebimentos de Venda de Ativo Imobilizado - Outros (+)"})
                aAdd(aItens,{cCodigo,"18","203", "Recebimentos de Venda de Investimentos (+)"})
                aAdd(aItens,{cCodigo,"19","204", "Recebimentos de Dividendos (+)"})
                aAdd(aItens,{cCodigo,"20","205", "Outros Recebimentos das Atividades de Investimento (+)"})
                aAdd(aItens,{cCodigo,"21","206", "Pagamentos de Aquisição de Ativo Imobilizado - Hospitalar (-)"})
                aAdd(aItens,{cCodigo,"22","207", "Pagamentos de Aquisição de Ativo Imobilizado - Outros (-)"})
                aAdd(aItens,{cCodigo,"23","208", "Pagamentos Relativos ao Ativo Intangível (-)"})
                aAdd(aItens,{cCodigo,"24","209", "Pagamentos de Aquisição de Participação em Outras Empresas (-)"})
                aAdd(aItens,{cCodigo,"25","210", "Outros Pagamentos das Atividade de Investimento (-)"})
                aAdd(aItens,{cCodigo,"26","301", "Integralização Capital em Dinheiro (+)"})
                aAdd(aItens,{cCodigo,"27","302", "Recebimento Empréstimos/Financiamentos (+)"})
                aAdd(aItens,{cCodigo,"28","303", "Títulos Descontados (+)"})
                aAdd(aItens,{cCodigo,"29","304", "Outros Recebimentos das Atividades de Financiamento (+)"})
                aAdd(aItens,{cCodigo,"30","305", "Pagamentos de Juros - Empréstimos/Financiamentos/Leasing (-)"})
                aAdd(aItens,{cCodigo,"31","306", "Pagamentos de Amortização - Empréstimos/Financiamentos/Leasing (-)"})
                aAdd(aItens,{cCodigo,"32","307", "Pagamento de Participação nos Resultados (-)"})
                aAdd(aItens,{cCodigo,"33","308", "Outros Pagamentos das Atividades de Financiamento (-)"})

            // Cobertura Assistencial  
            Case cIdQuadro==QDR_COBASS  
                aAdd(aItens,{cCodigo,"01","COA","Cobertura Assistencial"})

            // Saldo da Provisão de Eventos/Sinistros a Liquidar  
            Case cIdQuadro==QDR_PESL  
                aAdd(aItens,{cCodigo,"01","SUS","PESL-SUS"})
                aAdd(aItens,{cCodigo,"02","CAP","PESL-OUTROS Carteira Própria"})
                aAdd(aItens,{cCodigo,"03","COA","PESL-OUTROS Corresponsabilidade Assumida"})
                
            //Movimentação de Agrupamento de Contratos
            Case cIdQuadro==QDR_AGRCON 
                aAdd(aItens,{cCodigo,"01","CTR","Contraprestação Emitida"})
                aAdd(aItens,{cCodigo,"01","REC","Corresponsabilidade Cedida"})
                aAdd(aItens,{cCodigo,"01","EVE","Eventos/Sinistros Conhecidos"})

            //Movimentação de Eventos Indenizáveis
            Case cIdQuadro==QDR_EVEIND 
                aAdd(aItens,{cCodigo,"01","EVE","Novos avisos referentes a eventos ocorridos"})
                aAdd(aItens,{cCodigo,"02","GLO","Baixa de evento por glosa referentes a eventos ocorridos"})
                aAdd(aItens,{cCodigo,"03","REC","Outras recuperações referentes a eventos ocorridos"})
                aAdd(aItens,{cCodigo,"04","PEO","PEONA"})  

            //Contraprestação de Corresponsabilidade Cedida
            Case cIdQuadro==QDR_EVECOR 
                aAdd(aItens,{cCodigo,"01","EVE","Novos avisos referentes a eventos ocorridos"})  

            //Fundos Comuns de Despesas Assistenciais
            Case cIdQuadro==QDR_FUNCOM 
                aAdd(aItens,{cCodigo,"01","FCP","Participações em Programas ou Fundos Comuns de Despesas de Assistência Médico-Hospitalar"})
                aAdd(aItens,{cCodigo,"02","FCA","Saldos de Programas ou Fundos Comuns de Despesas de Assistência Médico-Hospitalar Administrados pela Operadora"})

            //Modelo Padrão de Capital
            Case cIdQuadro==QDR_MPC 
                aAdd(aItens,{cCodigo,"01","SMTP","Soma das contraprestações dos beneficiários da remissão, não remidos, em contratos com remissão temporária"})
                aAdd(aItens,{cCodigo,"02","SMVI","Soma das contraprestações dos beneficiários da remissão, não remidos, em contratos com remissão vitalícia"})
                aAdd(aItens,{cCodigo,"03","VLTP","Soma dos valores das despesa de assistência à saúde dos beneficiários remidos, em contratos com remissão temporária"})
                aAdd(aItens,{cCodigo,"04","VLVI","Soma dos valores das despesa de assistência à saúde dos beneficiários remidos, em contratos com remissão vitalícia"})

            //Contraprestações Pecuniárias 
            Case cIdQuadro==QDR_CONPEC   
                aAdd(aItens,{cCodigo,"01","PIF","Planos Individuais/Familiares (Pessoa Física)"})
                aAdd(aItens,{cCodigo,"02","PCJ","Planos Coletivos (Pessoa Jurídica)"})

            //Segregação do Montante de Contraprestações a Repassar
            Case cIdQuadro==QDR_CONREP 
                aAdd(aItens,{cCodigo,"01","REP","Segregação do Montante de Contraprestações a Repassar"})

            //Contratos Estipulado
            Case cIdQuadro==QDR_CONEST    
                aAdd(aItens,{cCodigo,"01","CTE","Contratos Estipulado"})  
                aAdd(aItens,{cCodigo,"02","CTN","Contratos Não Estipulado"})  

            //Percentual de Inadimplência (Administradora de Benefícios) 
            Case cIdQuadro==QDR_INAD                   
                aAdd(aItens,{cCodigo,"01","1","Metodologia Própria Autorizada"})  
                aAdd(aItens,{cCodigo,"02","2","Outras Metodologias"}) 

            //Conta Tributo Passivo 
            Case cIdQuadro==QDR_CTRPAS  
                aAdd(aItens,{cCodigo,"01","CTP","Conta Tributo Passivo"})   

            //Quadro Auxiliar de Risco de Mercado 
            Case cIdQuadro==QDR_RISCO  
                aAdd(aItens,{cCodigo,"01","0","Indexador do Fluxo em Questão - Pre-fixado"})        
                aAdd(aItens,{cCodigo,"02","1","Indexador do Fluxo em Questão - Pós-fixado"})   
                aAdd(aItens,{cCodigo,"03","2","Indexador do Fluxo em Questão - IPCA"})   
                aAdd(aItens,{cCodigo,"04","3","Indexador do Fluxo em Questão - IGPM"})   
                aAdd(aItens,{cCodigo,"05","4","Indexador do Fluxo em Questão - Cambial"})
        EndCase
    Next

    // Atualiza tabela de itens dos quadros diops e também inclui a parametrizacao de contas contabeis
    // para que o cliente possa customizar e que serao utilizadas pelo extrator diops financeiro 
    // Verfica se possui itens para processar 
    If Len(aItens)>0
        For nI := 1 to Len(aItens)
            cCodigo := aItens[nI,1]
            cSequen := aItens[nI,2]
            cItem   := aItens[nI,3]
            cDescri := aItens[nI,4]

            If B3Y->(!dbSeek(xFilial("B3Y")+cCodigo+cSequen+cItem)) //B3Y_FILIAL+B3Y_CODIGO+B3Y_SEQUEN+B3Y_ITEM
                RecLock("B3Y",.T.)
                B3Y->B3Y_FILIAL := xFilial("B3Y") 
                B3Y->B3Y_CODIGO := cCodigo 
                B3Y->B3Y_SEQUEN := cSequen
                B3Y->B3Y_ITEM   := cItem
                B3Y->B3Y_DESCRI := cDescri
                B3Y->(msUnLock())
            EndIf 
        Next 
    EndIf    

Return 

