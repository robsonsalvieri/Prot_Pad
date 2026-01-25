#include "protheus.ch" 
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160A.ch" 

PUBLISH MODEL REST NAME FISA160A

/*/{Protheus.doc} FISA160A
    (Regra de tabela Progressiva fiscal)

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

    /*/
Function FISA160A()

    IF AliasIndic("CIQ") .and. AliasIndic("CIR")
        dbSelectArea("CIQ")
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("CIQ")    
        oBrowse:SetDescription(STR0001) // Regra de tabela progressiva
        oBrowse:Activate()
    Else
        Help("",1,"Help","Help",STR0021,1,0) //"Dicionario desatualizado, Verifique as atualizações do configurar fiscal"
    Endif

Return 

/*/{Protheus.doc} MenuDef
    (Funcao responsável por gerar o menu.)
    
    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

    /*/
Static Function MenuDef()
Return FWMVCMenu( "FISA160A" )

/*/{Protheus.doc} ModelDef
    (Função que responsavel pelo modelo da rotina de cadastro de regras de tabelela progressiva)

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
    /*/
Static Function ModelDef()
 
    Local oModel     := Nil                     //Criação do objeto do modelo de dados
    Local oCabecalho := FWFormStruct(1, "CIQ" ) //Estrutura Pai correspondete a tabela da regra.
    Local oItens     := FWFormStruct(1, "CIR" ) //Estrutura filho correspondete a tabela da regra.
    Local bLinPosCIR := {||FSAPosCIR()}         //Validação dos Itens    
    Local aRelCIR    := {}                      //Relacionamento

    //Instanciando o modelo    
    oModel	:=	MPFormModel():New('FISA160A',/**/,{|oModel| VALIDACAO(oModel) .AND. PosProces(oModel)}, { |oModel| FSA160AGRV( oModel ) })    

    // Adiciona ao modelo uma estrutura de formulario de edicao por campo
    oModel:AddFields( "FISA160A", /*cOwner*/, oCabecalho,/*bPreValidacao*/, /*bPosValidacao*/, /*bLoad*/ )

    //Adiciona o Grid ao modelo
    oModel:AddGrid( "CIR_ITENS", "FISA160A", oItens,/*bLinePre*/, bLinPosCIR, /*bPre*/, /*bPos*/, /*bLoad*/)
    
    //===================================Propriedades dos campos=============================================


    //Não permite alterar codigo quando alteração
    oCabecalho:SetProperty('CIQ_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == MODEL_OPERATION_INSERT) })

    //Validação para não permitir informar um código da regra que já exista no sistema (legado)
    oCabecalho:SetProperty('CIQ_CODIGO' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})	

    // Campo obrigatorio
	oItens:SetProperty("CIR_ITEM"	, MODEL_FIELD_OBRIGAT, .T.)
	oItens:SetProperty("CIR_VALFIM"	, MODEL_FIELD_OBRIGAT, .T.)	
 

    //==================================Definições do modelo ================================================

    //Grid não pode ser vazio
    oModel:GetModel('CIR_ITENS'):SetOptional(.F.)

    // //Define para não repetir o Valor Inicial e Final
	oModel:GetModel( "CIR_ITENS" ):SetUniqueLine( { "CIR_VALINI" } )	
    oModel:GetModel( "CIR_ITENS" ):SetUniqueLine( { "CIR_VALFIM" } )
    
    //Define o valor maximo de linhas do grid
    oModel:GetModel('CIR_ITENS'):SetMaxLine(9999)

    //Relacionamento das tabelas.
	aAdd(aRelCIR ,{ "CIR_FILIAL"	,"xFilial('CIR')"} )
	aAdd(aRelCIR ,{ "CIR_IDCAB"	    ,"CIQ_ID"        } )
	oModel:SetRelation("CIR_ITENS"	, aRelCIR	, CIR->( IndexKey(3) ))   

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0001) //'Cadastro de Perfil Tributário de Operação'	

Return oModel

/*/{Protheus.doc} ViewDef
    (Função que monta a view da rotina.)

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
    /*/
Static Function ViewDef()

    //Inicializa as variáveis
	Local oModel      := FWLoadModel("FISA160A")	
	Local oCabecalho  := FWFormStruct(2, 'CIQ')
	Local oItens      := FWFormStruct(2, 'CIR')
    Local oView      := Nil

    oView := FWFormView():New()
    //Seta o modelo de dados a ser usado na view
    oView:SetModel(oModel)

    //Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_CIQ", oCabecalho, "FISA160A")
	oView:AddGrid( "VIEW_CIR", oItens, "CIR_ITENS" )    

    //Retira da view os campos de ID
    oCabecalho:RemoveField('CIQ_ID')
    oItens:RemoveField('CIR_ID')
    oItens:RemoveField('CIR_IDCAB')
	
	// Cria box visual para separação dos elementos em tela.
	oView:createHorizontalBox( "FORM", 20, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:createHorizontalBox( "GRID", 80, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	oView:SetOwnerView( "VIEW_CIQ", "FORM" )
	oView:SetOwnerView( "VIEW_CIR", "GRID" )

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_CIQ', STR0002) //"Tabela Progressiva"	

    //==============================Alteração de campos============================
	//Desabilita a edição do campo CIR_ITEM
	oItens:SetProperty("CIR_ITEM", MVC_VIEW_CANCHANGE, .F.)

    oView:EnableTitleView('VIEW_CIR', STR0022) //"Informe os valores das faixas"

    //Define campos que terao Auto Incremento
	oView:AddIncrementField( "VIEW_CIR", "CIR_ITEM" )
    
    //Ordem dos campos
    oItens:SetProperty("CIR_ITEM"  , MVC_VIEW_ORDEM, "01")
    oItens:SetProperty("CIR_VALINI", MVC_VIEW_ORDEM, "02")
    oItens:SetProperty("CIR_VALFIM", MVC_VIEW_ORDEM, "03")
    oItens:SetProperty("CIR_ALIQ", MVC_VIEW_ORDEM, "04")
    oItens:SetProperty("CIR_VALDED", MVC_VIEW_ORDEM, "05")

    oItens:SetProperty("CIR_VALINI", MVC_VIEW_TITULO, STR0025) //"Valor Inicial"
    oItens:SetProperty("CIR_VALFIM", MVC_VIEW_TITULO, STR0026) //"Valor Final"
    oItens:SetProperty("CIR_VALDED", MVC_VIEW_TITULO, STR0027)//"Valor da Dedução"

    //Desabilitando opção de ordenação
    oView:SetViewProperty("*", "ENABLENEWGRID")
    oView:SetViewProperty( "*", "GRIDNOORDER" )
 
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSAPosCIR()
Pos Validacao de preenchimento do Grid

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
/*/
//-------------------------------------------------------------------
Static Function FSAPosCIR()

Local oModel		:= FWModelActive()
Local oCIR		    := oModel:GetModel("CIR_ITENS")
Local nTamGrid	    := oCIR:Length()
Local nOperation    := oModel:GetOperation()
Local lRet		    := .T. 
Local cItemOgi      := oCIR:GetValue("CIR_ITEM")
Local nLnAtual      := oCIR:Getline() 
Local cLinhaAux     := ""
Local nValIniPrx    := 0
Local nValFimAnt    := 0

If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT
    
    //Value check
    //Valor final precisa estar preenchido
    If Empty(oCIR:GetValue("CIR_VALFIM"))        
        HELP(' ',1, STR0003 + cItemOgi ,, STR0004 ,2,0,,,,,, {STR0005} )	//"Existem informações necessárias não preenchidas."###"É obrigatório o preenchimento do Valor Final."         
        Return .F.
    Endif        
    
    //Alíquota precisa estar preenchida
    If Empty(oCIR:GetValue("CIR_ALIQ"))			        
        HELP(' ',1, STR0003 + cItemOgi ,, STR0004 ,2,0,,,,,, {STR0009} )	//"Existem informações necessárias não preenchidas."###"É obrigatório o preenchimento da Alíquota."                 
        Return .F.
    Endif        

    If oCIR:GetValue("CIR_VALFIM") < oCIR:GetValue("CIR_VALINI")        
        HELP(' ',1, STR0003 + cItemOgi ,, STR0014 ,2,0,,,,,, {STR0013} )	//"Valor final não deve ser menor que valor inicial"###"É necessário revisar valor final."         
        Return .F.
    Endif

    //Range check
    //ValIni deve ser maior que ValFim do item anterior            
    IF MoveLine(nLnAtual, nTamGrid, oCIR, "1", @nValFimAnt, @cLinhaAux) .And. oCIR:GetValue("CIR_VALINI") <= nValFimAnt
        HELP(' ',1, STR0003 + cItemOgi ,, STR0015 + cItemOgi + STR0016 + cLinhaAux + " ." ,2,0,,,,,, {STR0017 + cItemOgi} )	//"Valor Inicial do item XXX deve ser maior que o valor final do item xxx"
        Return .F.
    EndiF

    //ValFim deve ser menor que o ValIni do próximo item
    IF MoveLine(nLnAtual, nTamGrid, oCIR, "2", @nValIniPrx, @cLinhaAux) .And. oCIR:GetValue("CIR_VALFIM") >= nValIniPrx
        HELP(' ',1, STR0003 + cItemOgi ,, STR0018 + cItemOgi + STR0019 + cLinhaAux + " ." ,2,0,,,,,, {STR0020 + cItemOgi} )	//Valor findl do item xxx deve ser menor que o valo inicial do item xxx / revisar valor final
        Return .F.
    EndIF
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Validação do código da regra

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('FISA160A', "CIQ_CODIGO")
Local lRet          := .T.

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0006 + ": '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0007, 1, 0 ) 
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA160A
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cRegra        := oModel:GetValue ('FISA160A',"CIQ_CODIGO" ) 
Local nOperation 	:= oModel:GetOperation()

//Verifica se já existe regra com mesmo código e mesma vigência já gravados
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    IF VigIniFIm(cRegra, nOperation == MODEL_OPERATION_UPDATE)
        lRet:= .F.
        Help( ,, 'Help',, STR0008, 1, 0 ) //'Regra já cadastrada para a vigência informada'
    EndIF
EndiF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PosProces
Função que realiza alterações que devem ocorrer no pre - procesamento 


    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------

Static Function PosProces(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cIdCIQ        := ""
Local oItens        := nil
Local nTam          := 0
Local nX            := 0

IF nOperation == MODEL_OPERATION_INSERT
    //Atribui  novo ID
    cIdCIQ  := FWUUID("CIQ")
    oModel:SetValue( 'FISA160A', 'CIQ_ID', cIdCIQ)
    
    //-----------------------------------
    //Atribui o ID para o grid das faixas
    //-----------------------------------
    oItens := oModel:GetModel("CIR_ITENS")
    nTam  := oItens:Length()

    //Laço no grid do tributo
    For nX := 1 to nTam 
        oItens:GoLine(nX)
        oItens:SetValue('CIR_ID'    , FWUUID("CIR"))  //Chave da CIR
        oItens:SetValue('CIR_IDCAB' , cIdCIQ) //Chave estrangeira com CIQ
    Next nX

Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Função que verifica se data inicial e data final já existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vigência
@param     dDtFim      - Date - Data final de vigência
@param     lEdit       - Booleano - indica se é uma operação de edição

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vigência vazio 

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, lEdit)

Local lRet      := .F.
Local cSelect	:= " SELECT "
Local cFrom	    := " FROM "
Local cWhere	:= " WHERE "
local oStatement

//Query filtrando filial e regra
cSelect += "CIQ.CIQ_CODIGO "

cFrom   += RetSQLName("CIQ") + " CIQ "

cWhere  += "CIQ.CIQ_FILIAL = ? AND "
cWhere  += "CIQ.CIQ_CODIGO = ? AND "

If lEdit
    //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
    cWhere  += " CIQ.R_E_C_N_O_ <> " + ValtoSql(CIQ->(recno())) + " AND "
EndIF
cWhere  += "CIQ.D_E_L_E_T_ = ' '"

//Prepara classe para query
oStatement := FWPreparedStatement():New(ChangeQuery(cSelect+cFrom+cWhere))

//Informa a query a ser executada ja com ChangeQuery
oStatement:setString(1,xFilial("CIQ"))
oStatement:setString(2,cRegra)
//Executa uma consulta e retorna a primeira linha no conjunto de resultados retornados pela consulta. Colunas ou linhas adicionais são ignoradas.
lRet := !Empty(MpSysExecScalar(oStatement:GetFixQuery(),"CIQ_CODIGO"))

//Destroi a classe
oStatement:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MoveLine
Função auxiliar que busca informações de linhas anteriores e/ou próximas
válidas, ou seja não deletadas.

@param     nLnAtual   - Número da linha atual
@param     nTamGrid   - Quantidade de linhas do grid 
@param     oCIR       - Objeto do modelo com o grid
@param     cOpc       - Opção, 1=Verifica linha anterior(se houver), 2=Verifica linha posterior(se houver)
@param     nValAux    - Valor auxiliar passado como referência
@param     cItemAux    - Item auxiliar passado como referência

@return    lRet        - Retorna verdadeiro caso consiga encontrar item anterior/posterior válido, e preenche as variaveis nValAux e cItemAux

@author Erick Dias
@since 22/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function MoveLine(nLnAtual, nTamGrid, oCIR, cOpc, nValAux, cItemAux)
Local nLinAux   := nLnAtual

nValAux := 0
cItemAux := ""

//Verifica linha anterior
If cOpc == "1"
    nLinAux -= 1    
    While(nLinAux > 0)            
        oCIR:GoLine(nLinAux)        
        If !oCIR:IsDeleted()            
            //Preenche as variáveis
            nValAux  := oCIR:GetValue("CIR_VALFIM")
            cItemAux := oCIR:GetValue("CIR_ITEM")
            //Retorna para linha atual antes de sair da função
            oCIR:GoLine( nLnAtual )
            Return .T.
        Else
            //Tentará veriricar outra linha anterior já que está deletada
            nLinAux -= 1
        EndIF    
    EndDo

//Verifica próxima linha
ElseIF cOpc == "2" .And. nTamGrid > 1    
    nLinAux += 1
    While(nLinAux  <= nTamGrid) 
        oCIR:GoLine(nLinAux)        
        If !oCIR:IsDeleted()                        
		    //Preenche as variáveis
            nValAux := oCIR:GetValue("CIR_VALINI")
			cItemAux := oCIR:GetValue("CIR_ITEM")
            //Retorna para linha atual antes de sair da função
            oCIR:GoLine( nLnAtual )
            Return .T.
        Else
            nLinAux += 1
        EndIF
    EndDo

EndIf

//Se não consguir encontrar linha válida retornará false!
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160AGRV
Função que fará o commit do modelo e também gravação da tabela CIN
disponibilizando as regras para utilização nas fórmulas.

@param     oModel    - Modelo com as informações preenchidas

@author Erick Dias
@since 13/07/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function FSA160AGRV(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo       := oModel:GetValue ('FISA160A',"CIQ_CODIGO")  // Código da Regra
Local cIdRegra      := oModel:GetValue ('FISA160A',"CIQ_ID")      // Id da Regra a ser gravada

//Aqui commito o modelo principal
FWFormCommit( oModel )

//Gravo aqui a CIN 
If nOperation == MODEL_OPERATION_INSERT
    //Gravo as regras na CIN para ficarem disponíveis para utilização das fórmulas
    //Gravo a regra de alíquota da tabela progressiva
    GravaCIN("1","11", cCodigo, cIdRegra, "(Alíquota Tabela Progressiva) | "     + cCodigo, xFisTpForm("11") +cCodigo)
    
    //Gravo a regra de dedução da tabela progressiva
    GravaCIN("1","12", cCodigo, cIdRegra, "(Desconto Tabela Progressiva) | "     + cCodigo, xFisTpForm("12") +cCodigo)

ElseIf nOperation == MODEL_OPERATION_DELETE    

    //Aqui deleto as regras da CIN do código da tabela progressiva
    GravaCIN("3","11",, cIdRegra)
    GravaCIN("3","12",, cIdRegra)

EndIF

Return .T.
