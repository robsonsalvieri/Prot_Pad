//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

PUBLISH MODEL REST NAME ArmzIA SOURCE ArmzIA
 
//Variáveis Estáticas
Static cTitulo := "Filtro de Armazéns para IA" 
/*/{Protheus.doc} ArmzIA
Cadastro de tabelas SX5
@DANILO SANTOS
@since 31/05/2023
@version 1.0
    @param cTabela, character, Código da tabela genérica
    @param cTitRot, character, Título da Rotina
    @example
    ArmzIA("4B", "Filtro de Armazéns para IA")
/*/
 
Function ArmzIA()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
    Local cTabel1 := "2B"
    Local cTabel2 := "4B"

    Private cTabX := ""

    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    (DbGoTop())
    
    If SX5->(DbSeek(FWxFilial("SX5") + cTabel2))  
        cTabX := cTabel2
        cTabela := cTabel2
        ImpTab2B()
    ElseIf SX5->(DbSeek(FWxFilial("SX5") + cTabel1))
        cTabX := cTabel1
        cTabela := cTabel1
    Else
        Alert("Tabela nao existe no dicionario de Dados")
        Return
    Endif         
    //Instânciando FWMBrowse - Somente com dicionário de dados
    SetFunName("ArmzIA")
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SX5")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Filtrando
    oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"'")
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Danilo Santos                                                |
 | Data:  05/06/2023                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ArmzIA' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ArmzIA' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ArmzIA' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'DelX52B()' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Danilo Santos                                                |
 | Data:  01/06/2023                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStSX5 := FWFormStruct(1, "SX5")
     
    //Editando características do dicionário
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edição
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                     //Ini Padrão
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edição
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Chv()'))               //Validação de Campo
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
    oStSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
         
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("ArmzIAM",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMSX5"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Danilo Santos                                                |
 | Data:  01/06/2023                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("ArmzIA")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSX5 := FWFormStruct(2, "SX5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SX5', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SX5","TELA")
    
    //Retira o campo de tabela da visualização
    oStSX5:RemoveField("X5_TABELA")
    
Return oView
 

/*/{Protheus.doc} zSX5Chv
Função que valida a digitação do campo Chave, para verificar se já existe
@type function
@author Danilo Santos
@since 03/06/2023
@version 1.0
/*/ 
User Function zSX5Chv()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := M->X5_CHAVE
     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
     
    //Se conseguir posicionar, já existe
    If SX5->(DbSeek(FWxFilial('SX5') + cTabX + cX5Chave))
        MsgAlert("Já existe chave com esse código (<b>"+cX5Chave+"</b>)!", "Atenção")
        lRet := .F.
    EndIf
     
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} zSX5Chv
Função que Exclui o registro que esta posicionado na tela
@type function
@author Danilo Santos
@since 03/06/2023
@version 1.0
/*/
Function DelX52B()
Local lContinua := .F.
Local cArmazem := Alltrim(SX5->X5_CHAVE)
    //"Pergunta se deseja excluir o registro: Sim/Não"
    If MsgYesNo("Excluir Armazem " + cArmazem + " ? ")
        lContinua := .T.
        conout("Teste") 
	Endif
    If lContinua
        SX5->(DbSeek(xFilial() + cTabX + SX5->X5_CHAVE)) 
            RecLock("SX5", .F.)
        SX5->(DbDelete())
        SX5->(MsUnLock())
        Alert("Resgistro do Armazen do " + cArmazem + " excluido! ")    
    Endif   
Return


/*/{Protheus.doc} ImpTab2B
Função que importa os dados cadastrado na tabela 2B para a tabela 4B
@type function
@author Danilo Santos
@since 10/06/2024
@version 1.0
/*/
Function ImpTab2B()
Local cQuery := ""
Local cNextAlias := ""

cNextAlias := GetNextAlias()

cQuery := "SELECT * "
cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
cQuery += " WHERE "
cQuery += " SX5.X5_TABELA = '2B' AND"
cQuery += " SX5.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY R_E_C_N_O_ ASC"

cQuery := ChangeQuery(cQuery)

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cNextAlias, .F.,.T. )

While (cNextAlias)->(!Eof()) //!Eof() 

    If Alltrim((cNextAlias)->X5_CHAVE) $ "01|03"
        (cNextAlias)->(dbSkip())
    Else
        DbSelectArea('SX5')
        SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
        
        //Verificar se o registro ja existe na tabela fisica
        IF SX5->(MSSeek(FWxFilial("SX5") + "4B"+ (cNextAlias)->X5_CHAVE))
            (cNextAlias)->(dbSkip())
        Else        
            FwPutSX5("", "4B",(cNextAlias)->X5_CHAVE , (cNextAlias)->X5_DESCRI, (cNextAlias)->X5_DESCSPA , (cNextAlias)->X5_DESCENG )
            (cNextAlias)->(dbSkip())
        Endif
        SX5->(DbCloseArea())
    Endif
End

(cNextAlias)->(dbCloseArea())

//Após importar os registros dpara a tabela 4B 
// deletar os registros da tabela 2B
DelTab2B()

Return


/*/{Protheus.doc} DelTab2B
Função que deleta os dados cadastrado na tabela 2B
@type function
@author Danilo Santos
@since 13/06/2024
@version 1.0
/*/
Static Function DelTab2B()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta os itens cadastrados como 2B³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TcSQLExec("DELETE FROM " + RetSqlName("SX5") + " WHERE X5_TABELA = '00' AND X5_CHAVE = '2B'" )
TcSQLExec("DELETE FROM " + RetSqlName("SX5") + " WHERE X5_TABELA = '2B'" )

Return
