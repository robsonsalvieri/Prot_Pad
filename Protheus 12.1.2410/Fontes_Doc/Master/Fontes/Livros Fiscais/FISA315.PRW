#include "PROTHEUS.CH"
#include "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA315.CH"
#Include "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA315


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA315()

Esta rotina tem objetivo de realizar cadastro de regra de apuração 
para controle de Debitos realizado por operações de cancelamento
ou de periodo anterioes.

Esta rotina estará disponível somente na versão 12.1.2410

@author Bruce Mello	
@since 20/03/2024
@version P12.1.2410
/*/
//-------------------------------------------------------------------

Function FISA315()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJV") .AND. AliasIndic("CJW") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJV")
    oBrowse:SetDescription(STR0001) //"Cadastro Regra de Apuração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Bruce Mello	
@since 20/03/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA315" )

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro de regra de cadastro de Apuração

@author Bruce Mello	
@since 20/03/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oCabecalho := FWFormStruct(1, "CJV" )
Local oItem      := FWFormStruct(1, "CJW" )

    //Instanciando o modelo
    oModel  := MPFormModel():New('FISA315', ,{|oModel|VALIDACAO(oModel)})

    //Atribuindo cabeçalho para o modelo
    oModel:AddFields("MASTER",,oCabecalho)
    
    //Adiciona Grids
    oModel:AddGrid("GRID","MASTER",oItem)
    

    //==================================Propriedades dos campos=============================================

    //Não permite alterar codigo quando alteração
    oCabecalho:SetProperty('CJV_CODREG' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == 3) })
    oItem:SetProperty('CJW_TRIB'   , MODEL_FIELD_WHEN, {|| EdtTRIB(oModel) })
    oItem:SetProperty('CJW_VALOR'   , MODEL_FIELD_WHEN, {|| EdtTRIB(oModel) })
    oItem:SetProperty('CJW_TRILEG'   , MODEL_FIELD_WHEN, {|| EdtTrileg(oModel) })

    

    //Validação para não permitir informar um código da regra que já exista no sistema (legado)
    oCabecalho:SetProperty('CJV_CODREG' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})	
    
    //Validação para limpar campo CJW_CODLAN quando alterar o conteudo do campo CJW_CODTAB
    oItem:SetProperty('CJW_CODTAB' , MODEL_FIELD_VALID , {|| (Fsa315MCpo("CJW_CODLAN")),XTabLanc(.T.) })

    //Validação para limpar campo CJW_ORIVLR quando alterar o conteudo do campo CJW_REGAPU
    oItem:SetProperty('CJW_REGAPU' , MODEL_FIELD_VALID , {|| (Fsa315M2Cpo("CJW_ORIVLR")),XRegraApu(.T.)    })

    //Validação para limpar campo CJW_ORIVLR quando alterar o conteudo do campo CJW_REGAPU
    oItem:SetProperty('CJW_ORIVLR' , MODEL_FIELD_VALID , {|| (Fsa315M3Cpo("CJW_TRIB")),XOrigVlr(.T.)    })

    //Validação para nao permitir informar codigo de lançamento que não existam na tabela CDO e CDY
    oItem:SetProperty('CJW_CODLAN' , MODEL_FIELD_VALID , {|| (ValidLanc("CJW_CODLAN"))    })

    //Validação para nao permitir informar um valor onde já está sendo utilizado com o mesmo tributo cadastrado.
    oModel:GetModel('GRID'):SetUniqueLine({'CJW_VALOR'})
    

    



     
    //==================================Definições do modelo ================================================

    //PrimaryKey
    oModel:SetPrimaryKey( {"CJV_CODREG","CJV_ID"} )

    oModel:SetRelation("GRID",{{ 'CJW_FILIAL' , 'xFilial("CJW")' }, { 'CJW_ID_CAB','CJV_ID'}},CJW->(IndexKey(1)))            

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0001) //"Cadastro da regra de Ajuste de Lançamento"

    // Controle de campo obrigatorio. T - obrigaotorio F . não obrigatorio
    oItem:SetProperty( 'CJW_CODTAB'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJW_CODLAN'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJW_VIGINI'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJW_VIGFIM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJW_REGAPU'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJW_ORIVLR'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJW_TRIB'     , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJW_TRILEG'   , MODEL_FIELD_OBRIGAT,  .F. ) 


        
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina FISA315

@author Bruce Mello	
@since 20/03/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel        := FWLoadModel("FISA315")
Local oView         := Nil
Local oCabecalho    := FWFormStruct(2, "CJV" )
Local cCmpFolder    := ''
Local o315Lanc      := Nil
Local o315Valr      := Nil
Local cCmpRelac     := ""


//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

//Campos para a Aba de Codigo Lançamento:
cCmpFolder	:=	cCmpRelac + "CJW_CODTAB|CJW_CODLAN|CJW_VIGINI|CJW_VIGFIM|"

o315Lanc	:=	FwFormStruct( 2, 'CJW', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

//Campos para a Aba Filtro Ajuste:
cCmpFolder	:=	cCmpRelac + "CJW_CODLAN|CJW_REGAPU|CJW_ORIVLR|CJW_TRIB|CJW_VALOR|CJW_TRILEG|"
o315Valr	:=	FwFormStruct( 2, 'CJW', {|x| AllTrim( x ) + "|" $ cCmpFolder } )   

//Atribuindo formulários para interface
// Por ser 3 abas estamos dividindo no GRID em 3 view
oView:AddField('VIEW_CAB'        ,oCabecalho     , 'MASTER')
oView:AddGrid( 'VIEW_LANC'       ,o315Lanc       , 'GRID'  )
oView:AddGrid( 'VIEW_VLR'        ,o315Valr       , 'GRID'  )



oView:SetViewProperty( 'VIEW_LANC', "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )
oView:SetViewProperty( 'VIEW_VLR' , "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )



//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_LANC', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_LANC', "GRIDSEEK"   , {.T.})

oView:SetViewProperty('VIEW_VLR', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_VLR', "GRIDSEEK"   , {.T.})

//Retira os campos da View
oCabecalho:RemoveField('CJV_ID')

//Cria três box
oView:CreateHorizontalBox( 'SUPERIOR'   , 20 )
//oView:CreateHorizontalBox( 'MEIO'       , 19 )
oView:CreateHorizontalBox( 'INFERIOR'   , 80 )

//Cria o Folder Principal
oView:CreateFolder( 'Folder_CJW', 'INFERIOR' )

//Cria as Abas Principais
oView:AddSheet( 'Folder_CJW', 'ABA_LANC', "Lançamentos" ) //"Lançamentos"
oView:AddSheet( 'Folder_CJW', 'ABA_VLR'	, "Configurações" ) //"Valores"



//Cria box da aba de Principais
oView:CreateHorizontalBox( 'PAINEL_LANC' , 100,,, 'Folder_CJW', 'ABA_LANC'     )
oView:CreateHorizontalBox( 'PAINEL_VLR'  , 100,,, 'Folder_CJW', 'ABA_VLR'      )


//Faz vínculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'  , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_LANC' , 'PAINEL_LANC'     )
oView:SetOwnerView( 'VIEW_VLR'  , 'PAINEL_VLR'      )



//Colocando título do formulário
oView:EnableTitleView('VIEW_CAB'  , "Cadastro Regra de Apuração" ) 
oView:EnableTitleView('VIEW_LANC' , "Codigos de Lançamento" ) 
oView:EnableTitleView('VIEW_VLR'  , "Inf. Valores dos Lançamentos" ) 




//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CAB", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Altera titulo CJV - Cabeçalho da Regra
oCabecalho:SetProperty("CJV_CODREG", MVC_VIEW_TITULO, "Código da Regra de Ajuste")
oCabecalho:SetProperty("CJV_DESCR", MVC_VIEW_TITULO, "Descrição da Regra de Apuração")
oCabecalho:SetProperty("CJV_VIGINI", MVC_VIEW_TITULO, "Data Inicio da Vigencia da Regra")
oCabecalho:SetProperty("CJV_VIGFIM", MVC_VIEW_TITULO, "Data Fim da Vigencia da Regra")


//Altera titulo CJW - Itens do Cadastro de Regra de Lançamento
o315Lanc:SetProperty("CJW_CODTAB", MVC_VIEW_TITULO, "Tabela de Lançamento")
o315Lanc:SetProperty("CJW_CODLAN", MVC_VIEW_TITULO, "Código de Lançamento")
o315Lanc:SetProperty("CJW_VIGINI", MVC_VIEW_TITULO, "Início Vigência Lançamento")
o315Lanc:SetProperty("CJW_VIGFIM", MVC_VIEW_TITULO, "Fim Vigência Lançamento")



o315Valr:SetProperty("CJW_CODLAN", MVC_VIEW_TITULO, "Código de Lançamento")
o315Valr:SetProperty("CJW_REGAPU", MVC_VIEW_TITULO, "Regra de Apuração")
o315Valr:SetProperty("CJW_ORIVLR" , MVC_VIEW_TITULO, "Origem do Valor")
o315Valr:SetProperty("CJW_TRIB"  , MVC_VIEW_TITULO, "Tributo do Configurador") 
o315Valr:SetProperty("CJW_VALOR" , MVC_VIEW_TITULO, "Considera Valor")
o315Valr:SetProperty("CJW_TRILEG"  , MVC_VIEW_TITULO, "Tributo do Legado") 

//Ordem dos campos para realizarem filtros nas fórmulas
o315Lanc:SetProperty("CJW_CODTAB" , MVC_VIEW_ORDEM, "01")
o315Lanc:SetProperty("CJW_CODLAN" , MVC_VIEW_ORDEM, "02")
o315Lanc:SetProperty("CJW_VIGINI" , MVC_VIEW_ORDEM, "03")
o315Lanc:SetProperty("CJW_VIGFIM" , MVC_VIEW_ORDEM, "04")


//
o315Valr:SetProperty("CJW_CODLAN"  , MVC_VIEW_ORDEM, "01")
o315Valr:SetProperty("CJW_REGAPU"  , MVC_VIEW_ORDEM, "02")
o315Valr:SetProperty("CJW_ORIVLR"  , MVC_VIEW_ORDEM, "03")
o315Valr:SetProperty("CJW_TRIB"    , MVC_VIEW_ORDEM, "04")
o315Valr:SetProperty("CJW_VALOR"    , MVC_VIEW_ORDEM, "05")
o315Valr:SetProperty("CJW_TRILEG"    , MVC_VIEW_ORDEM, "06")

//Altero a consulta padrão do campo
o315Lanc:SetProperty("CJW_CODLAN",MVC_VIEW_LOOKUP,{ || X315ChgF3(oModel) })

//Desabilitando opção de ordenação
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

oView:SetFieldAction('CJW_CODLAN'  , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJW_REGAPU'  , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJW_ORIVLR'  , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJW_TRIB'    , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJW_VALOR'    , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJW_TRILEG'  , {|oView| AtuGrid(oView,oModel) })

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA315
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.

   @author Bruce Mello	
    @since 20/03/2024
    version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cRegra        := oModel:GetValue ('MASTER',"CJV_CODREG" ) 
Local dDtIni        := oModel:GetValue ('MASTER',"CJV_VIGINI" )
Local dDtFim        := oModel:GetValue ('MASTER',"CJV_VIGFIM" )
Local cID           := oModel:GetValue ('MASTER',"CJV_ID" )
Local nOperation 	:= oModel:GetOperation()
Local lAtualiza     := nOperation == MODEL_OPERATION_UPDATE
Local lInclui       := nOperation == MODEL_OPERATION_INSERT


//Verifica se já existe regra com mesmo código e mesma vigência já gravados
IF lInclui .OR. lAtualiza

    IF VigIniFIm(cRegra, dDtIni, dDtFim, lAtualiza, cID)
        lRet:= .F.
        Help( ,, 'Help',, STR0003 , 1, 0 ) //'Regra já cadastrada para a vigência informada'
    EndIF

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Função que verifica se data inicial e data final já existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vigência
@param     dDtFim      - Date - Data final de vigência
@param     lEdit       - Booleano - indica se é uma operação de edição

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vigência vazio 
   @author Bruce Mello	
    @since 20/03/2024
    version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdCJV)

Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry	:= ""
Local oMontQry 	:= Nil
Local cDataIni  := ""
Local cDataFim  := ""
Local nRecno    := 0 

If oMontQry == Nil
    //Query filtrando filial e regra
    cQuery += " SELECT "
    cQuery += "CJV.CJV_CODREG"
    cQuery += " FROM ? CJV "
    cQuery  += "WHERE CJV.CJV_FILIAL = ? AND "
    cQuery  += "CJV.CJV_CODREG = ? AND "
    

    cQuery  += "( "

    //Verifica se está compreendido em cadastro somente com data inicial preenchida
    cQuery  += "( ? >= CJV.CJV_VIGINI  AND CJV.CJV_VIGFIM = ? ) OR"
    //Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
    cQuery  += "( ? >= CJV.CJV_VIGINI  AND ? <= CJV.CJV_VIGFIM ) "

    //Tratamento para data final
    IF Empty(dDtFim)
        //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
        cQuery  += " OR ( CJV.CJV_VIGFIM = ?) "
    ElseIf !Empty(dDtFim)
        //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
        cQuery  += " AND ( ? >= CJV.CJV_VIGINI  AND ? <= CJV.CJV_VIGFIM ) "
        cQuery  += " AND (? >= CJV.CJV_VIGINI  AND CJV.CJV_VIGFIM = ?) "
    EndIF

    cQuery  += " )" 

    If lEdit
        //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
        //Como temos consulta padrão da CJV, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a CJV originalmente clicada no browse para edição
        DbSelectArea("CJV")
        CJV->(DbSetOrder(1))
        If CJV->(MsSeek( xFilial("CJV") + cRegra + cIdCJV ))
            nRecno  := CJV->(recno())
            cQuery  += " AND CJV.R_E_C_N_O_ <> ? "
        EndIF    
    EndIF

    cQuery += " AND D_E_L_E_T_ = ? "

    oMontQry := FwExecStatement():New(cQuery)
Endif
cDataIni  := DTOS(dDtIni)
cDataFim  := DTOS(dDtFim)

IF Empty(dDtFim)
    oMontQry:SetUnsafe(1, RetSqlName("CJV"))
    oMontQry:SetString(2, xFilial("CJV"))
    oMontQry:SetString(3, cRegra)
    oMontQry:SetString(4, cDataIni)
    oMontQry:SetString(5, cDataFim) 
    oMontQry:SetString(6, cDataIni)
    oMontQry:SetString(7, cDataFim) 
    oMontQry:SetString(8, cDataFim) 
    If lEdit
        oMontQry:SetNumeric(9, nRecno)
        oMontQry:SetString(10, ' ')
    Else
        oMontQry:SetString(9, ' ')
    EndIf
Else
    oMontQry:SetUnsafe(1, RetSqlName("CJV"))
    oMontQry:SetString(2, xFilial("CJV"))
    oMontQry:SetString(3, cRegra)
    oMontQry:SetString(4, cDataIni)
    oMontQry:SetString(5, cDataFim)
    oMontQry:SetString(6, cDataIni)
    oMontQry:SetString(7, cDataFim)
    oMontQry:SetString(8, cDataIni)
    oMontQry:SetString(9, cDataFim)
    oMontQry:SetString(10, cDataIni)
    oMontQry:SetString(11, cDataFim)
    If lEdit
        oMontQry:SetNumeric(12, nRecno)
        oMontQry:SetString(13, ' ')
    Else
        oMontQry:SetString(12, ' ')
    EndIf
Endif

cAliasQry := oMontQry:OpenAlias()

//Executa uma consulta e retorna a primeira linha no conjunto de resultados retornados pela consulta. Colunas ou linhas adicionais são ignoradas.
lRet := !Empty(oMontQry:ExecScalar("CJV_CODREG"))

dbSelectArea(cAliasQry)
(cAliasQry)->(DbCloseArea())

oMontQry:Destroy()
oMontQry:= Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Validação do código da regra

   @author Bruce Mello	
    @since 20/03/2024
    version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('MASTER', "CJV_CODREG")
Local lRet          := .T.

//Verifico se o perfil já existe.
//Procura se já existe regra de alíquota com o mesmo código e ativa
CJV->(DbSetOrder(1))

If CJV->( MsSeek ( xFilial('CJV') + cCodigo  ) )
    Help( ,, 'Help',, STR0007, 1, 0 ) 
    return .F.
EndIF

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0004    + STR0006, 1, 0 ) //"Código não pode conter os caracteres."
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0005, 1, 0 ) //Código não pode conter espaço.
    Return .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} X315ChgF3
Função para alterar a consulta padrão do campo CJW_CODTAB onde irá 
trazer a tabela 5.1.1 ou 5.2

@author Bruce Egnor  
@since 01/04/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function X315ChgF3(oModel)

Local cTbLan	:= Alltrim(oModel:GetValue ('GRID',"CJW_CODTAB"))
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.
If cTbLan == '01'
    cRet    := "CDO"
/*ElseIf cTbLan == '02'
    cRet    := "CDY"
ElseIf cTbLan == '03'
    cRet    := "CC6"*/
Endif

Return cRet

//-------------------------------------------------------------------
//-------------------------------------------------------------------
Static Function AtuGrid(oView,oModel)

//Atualizo a view
oview:Refresh( 'VIEW_LANC')
oview:Refresh( 'VIEW_VLR')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa315MCpo
Função que valida os campos, quando alterado o conteudo do CJW_CODTAB, limpar os campos
CJW_CODLAN, CJW_VIGINI e CJW_VIGFIM.
@author Bruce Mello  
@since 23/03/2024
@version P12.1.2410


/*/
//-------------------------------------------------------------------
Function Fsa315MCpo(cCampo)

Local oModel        := FWModelActive()
Local oItens	    := oModel:GetModel("GRID")

If !Empty(cCampo)
     //grupo de regras de titulos
      oItens:LoadValue('CJW_CODLAN' , Criavar("CJW_CODLAN") )
      oItens:LoadValue('CJW_VIGINI' , Criavar("CJW_VIGINI") )
      oItens:LoadValue('CJW_VIGFIM' , Criavar("CJW_VIGFIM") )
EndIf

Return .T.



//-----------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine()
Propriedade da View executada na mudança de linhas dos grids.
@author Bruce Mello  
@since 23/03/2024
@version P12.1.2410
/*/
//-----------------------------------------------------------------------

Static Function ChangeLine(oView, oModel)

Local nLnAtual      := 0
Local oGrid         := nil

oGrid := oModel:GetModel("GRID")
nLnAtual:= oGrid:Getline()

//Restauro a linha inicial do grid antes de saír da função
oGrid:GoLine(nLnAtual)

oView:Refresh( 'VIEW_LANC')
oView:Refresh( 'VIEW_VLR')

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa315M2Cpo
Função que valida os campos, quando alterar o conteudo do CJW_REGAPU, limpa os campos 
CJW_TRIB, CJW_VALOR e CJW_TRILEG

@author Bruce Mello  
@since 23/03/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Function Fsa315M2Cpo(cCampo)

Local oModel        := FWModelActive()
Local oItens	    := oModel:GetModel("GRID")

If !Empty(cCampo)
     //grupo de regras de titulos
      oItens:LoadValue('CJW_ORIVLR' , Criavar("CJW_ORIVLR") )
      oItens:LoadValue('CJW_TRIB' , Criavar("CJW_TRIB") )
      oItens:LoadValue('CJW_TRILEG' , Criavar("CJW_TRILEG") )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa315M3Cpo
Função que valida os campos, quando alterar o conteudo do CJW_ORIVLR, limpa os campos
CJW_TRIB, CJW_VALOR e CJW_TRILEG

@author Bruce Mello  
@since 23/03/2024
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Function Fsa315M3Cpo(cCampo)

Local oModel        := FWModelActive()
Local oItens	    := oModel:GetModel("GRID")

If !Empty(cCampo)
     //grupo de regras de titulos
      oItens:LoadValue('CJW_TRIB' , Criavar("CJW_TRIB") )
      oItens:LoadValue('CJW_VALOR' , Criavar("CJW_VALOR") )
      oItens:LoadValue('CJW_TRILEG' , Criavar("CJW_TRILEG") )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} XTabelaLanc
Função para Retornar conteudo para combo do campo CJW_CODTAB
@type  Function
@author Bruce Mello
@since 22/03/2024
@version version
@param lValid - Reliza controle de quantidade de itens evitando travar a quantidade no x3_valid
/*/
//-------------------------------------------------------------------
Function XTabLanc(lValid)                                                                                                              
Local cRet := ""
Default lValid := .F.

If lValid
    cRet := .T.
Else
    cRet+="01=Tabela 5.1.1;"
    /*cRet+="02=Tabela 5.2;"
    cRet+="03=Tabela 5.3;"*/
Endif
   
Return cRet     


//-------------------------------------------------------------------
/*/{Protheus.doc} XRegraApu
Função para Retornar conteudo para combo do campo CJW_REGAPU
@type  Function
@author Bruce Mello
@since 22/03/2024
@version version
@param lValid - Reliza controle de quantidade de itens evitando travar a quantidade no x3_valid
/*/
//-------------------------------------------------------------------
Function XRegraApu(lValid)                                                                                                              
Local cRet := ""
Default lValid := .F.


If lValid
    cRet := .T.
Else
    cRet+="01=Nota Cancelada;"
    //cRet+="02=Crédito Periodo Anterior;"
Endif
   
Return cRet    
    


/*/{Protheus.doc} XOrigVlr
    Função para Retornar conteudo para combo do campo CJW_ORIVLR
    @type  Function
    @author Bruce Mello
    @since 05/04/2024
    @version 12.1.2410
    @param lValid - Reliza controle de quantidade de itens evitando travar a quantidade no x3_valid
    @return return_var, return_type, return_description
    /*/
Function XOrigVlr(lValid)
Local cRet := ""
Default lValid := .F.

If lValid
    cRet := .T.
Else
    cRet+="01=Configurador de Tributos;"
    cRet+="02=Sistema Legado;"
Endif    
Return cRet

/*/{Protheus.doc} XTribLeg
    Função para Retornar conteudo para combo do campo CJW_TRILEG
    @type  Function
    @author Bruce Mello 
    @since 05/04/2024
    @version 12.1.2410
    @param lValid - Reliza controle de quantidade de itens evitando travar a quantidade no x3_valid
    @return cRet
    /*/
Function XTribLeg(lValid)
Local cRet := ""
Default lValid := .F.

If lValid
    cRet := .T.
Else
    cRet ="01=FABOV - Fundo de Apoio a Bovinocultura de Corte;"
    cRet+="02=FACS - Fundo de Apoio à Cultura da Soja;"
    cRet+="03=FAMAD - Fundo de Apoio à Madeira;"
    cRet+="04=FASE/MT - Fundo Mato-Grossense de Apoio à Cultura da Semente;"
    cRet+="05=FETHAB - Fundo Estadual de Transporte e Habitação;"
    cRet+="06=FUNDERSUL - Fundo de Desenvolvimento do Sistema Rodoviário do Estado de Mato Grosso do Sul;"
    cRet+="07=FUNDESA - Fundo de Desenvolvimento e Defesa Sanitária Animal;"
    cRet+="08=IMA/MT - Instituto Mato-Grossense do Algodão;"
    //cRet+="09=TPDP - Taxa de Processamento de Despesa Pública do Estado da Paraíba;"
    cRet+="10=ICMS - Imposto sobre Circulação de Mercadorias e Serviços;"
    cRet+="11=ICMS-ST - Imposto sobre Circulação de Mercadorias e Serviços - Substituição Tributária;"
    cRet+="12=FEEF - Fundo Estadual de Equilíbrio Fiscal;"
    cRet+="13=PROTEG - Fundo de Proteção Social do Estado de Goiás;"
    cRet+="14=Crédito Presumido para Icms;"
    cRet+="15=Crédito Presumido sobre prestação Serviço de Transporte com ICMS/ST;"
    //cRet+="16=FRTAUT - Frete Autônomo;"
    cRet+="17=FRTEMB - Frete Embarcado;"
    cRet+="18=PRESCG - Crédito Presumido pela Carga Tributária;"
    cRet+="19=DIFAL - Diferencial de Alíquota;"
    cRet+="20=Icms Complementar;"
    cRet+="21=Antecipação do ICMS;"
    cRet+="22=FECP ICMS - Fundo de Combate à Pobreza;"
    cRet+="23=FECP ICMS ST - Fundo de Combate à Pobreza ICMS-ST;"
    cRet+="24=FECP ICMS COMPLEMENTAR- Fundo de Combate à Probreza;"
    cRet+="25=ESTICM - Estorno Crédito do ICMS;"
Endif

    
Return cRet


    


/*/{Protheus.doc} EdtTRIB
    Função para ler o conteudo o campo CJW_ORIVLR e tratar o prenchimento do campo CJW_TRIB,
    quando este for Trbuto Legado
    @type  Static Function
    @author Bruce Mello
    @since 05/04/2024
    @version 12.1.24.10
    @return lRet
    @param oModel
/*/
Static Function EdtTRIB(oModel)
Local lRet    := .F.
Local cOriVlr   := AllTrim(oModel:GetValue('GRID',"CJW_ORIVLR"))

IF cOriVlr == "01"
    lRet    := .T. 
Endif
    
Return lRet


/*/{Protheus.doc} EdtTrileg
    Função para ler o conteudo o campo CJW_ORIVLR e tratar o prenchimento do campo CJW_TRILEG,
    quando este for Configurador de Tributos
    @type  Static Function
    @author Bruce Mello
    @since 05/04/2024
    @version 12.1.24.10
    @param oModel
    @return lRet
/*/
Static Function EdtTrileg(oModel)
Local lRet    := .F.
Local cOriVlr   := AllTrim(oModel:GetValue('GRID',"CJW_ORIVLR"))

IF cOriVlr == "02"
    lRet    := .T. 
Endif
    
Return lRet


/*/{Protheus.doc} xRegCal315
    Função auxiliar que retorna o tributo selecionado pelo usuário
    para poder filtrar a consulta das regras.
    @type  Function
    @author Bruce Mello
    @since 05/04/2024
    @version P12.1.2410
    @return cCalReg
/*/
Function xRegCal315()

Local oModel        := FWModelActive()
Local cCalReg	:= Alltrim(oModel:GetValue ('GRID',"CJW_TRIB"))    

Return cCalReg

/*/{Protheus.doc} ValidLanc
    Função que valida que o Codigo de Lançamento informado consta nas tabelas
    CDO e CDY.
    @type  Static Function
    @author Bruce Mello
    @since 05/04/2024
    @version 12.1.24.10
    @param cCampo
    @return lRet
    @example
    cTpLan = 01 retorna a tabela CDO na consulta F3
    cTpLan = 02 retorna a tabela CDY na consulta F3
/*/
Static Function ValidLanc(cCampo)

    Local lRet    := .F.
	Local oModel  := FWModelActive()
	Local oItens  := oModel:GetModel("GRID")
	Local cCodLanc  := oModel:GetValue('GRID', "CJW_CODLAN")
    Local cTpLan := oModel:GetValue('GRID', "CJW_CODTAB")

    If empty(cTpLan)
        Help( ,, 'Help',, STR0008, 1, 0 ) // Escolha a tabela de lançamentos antes incluir o código de lançamento!
    Endif

	Do Case
	Case cCampo $ "CJW_CODLAN"
				
		If cTpLan $ "01" // 5.1 (CDO)
            
            CDO->(DbSetOrder(1))            
            lRet := CDO->(MsSeek(xFilial("CDO") + AllTrim(cCodLanc )))            
            if lRet 
                oItens:LoadValue('CJW_CODLAN', CDO->CDO_CODAJU )  
            endif

        /*Elseif cTpLan $ "02" // 5.2 (CDY)

            CDY->(DbSetOrder(1))
            lRet := CDY->(MsSeek(xFilial("CDY") + AllTrim(cCodLanc)))            
            if lRet 
                oItens:LoadValue('CJW_CODLAN', CDY->CDY_CODAJU )  
            endif

        Elseif cTpLan $ "03" // 5.3 (CC6)

            CC6->(DbSetOrder(1))            
            lRet := CC6->(MsSeek(xFilial("CC6") + AllTrim(cCodLanc )))            
            if lRet 
                oItens:LoadValue('CJW_CODLAN', CC6->CC6_CODLAN )  
            endif*/

		EndIf

    EndCase

Return lRet
    




