#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160I.CH"
#Include "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA160I
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160I()

Esta rotina tem objetivo de realizar cadastro de classificação fiscal

Esta rotina estará disponível somente na versão 12.

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160I()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ0") .AND. AliasIndic("CJ1") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ0")
    oBrowse:SetDescription(STR0001) //"Código de situação tributária"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160I" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro de classificação fiscal

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel      := Nil
Local oCabecalho  := FWFormStruct(1, "CJ0" )
Local oItens      := FWFormStruct(1, "CJ1" )
Local aRelCJ1     := {}

    //Instanciando o modelo
    oModel	:=	MPFormModel():New('FISA160I', , {|oModel|VALIDACAO(oModel) .AND. PosProces(oModel)} )

    //Atribuindo cabeçalho para o modelo
    oModel:AddFields("FISA160I",,oCabecalho)

    //Adicionando o grid das variações do tributo
    oModel:AddGrid( 'FISA160ICST','FISA160I',oItens)

    //==================================Propriedades dos campos=============================================

    //Não permite alterar codigo quando alteração
    oCabecalho:SetProperty('CJ0_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == MODEL_OPERATION_INSERT) })

    //Validação para não permitir informar um código da regra que já exista no sistema (legado)
    oCabecalho:SetProperty('CJ0_CODIGO' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})	

      

    //==================================Definições do modelo ================================================


    //PrimaryKey
    oModel:SetPrimaryKey( {"CJ0_CODIGO","CJ0_ID"} )

    //Define o valor maximo de linhas do grid
    oModel:GetModel('FISA160ICST'):SetMaxLine(9999)

    //Define para não repetir o CST
    oModel:GetModel( 'FISA160ICST' ):SetUniqueLine( { 'CJ1_CST' } ) 

    //Grid não pode ser vazio
    oModel:GetModel('FISA160ICST'):SetOptional(.F.)

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0003) //"Cadastro de código de situação tributária"

    //Relacionamento das tabelas.
    aAdd(aRelCJ1 ,{ "CJ1_FILIAL"	,"xFilial('CJ1')"} )
    aAdd(aRelCJ1 ,{ "CJ1_ID_CAB"	,"CJ0_ID"        } )
    aAdd(aRelCJ1 ,{ "CJ1_CODCAB"	,"CJ0_CODIGO"        } )
    oModel:SetRelation("FISA160ICST"	, aRelCJ1	, CJ1->( IndexKey(2) ))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Rafael Oliveira
@since 30/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA160I" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho   := FWFormStruct(2, "CJ0" )
Local oItens   := FWFormStruct(2, "CJ1" )
Local oView  := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField('VIEW_CAB' ,oCabecalho, 'FISA160I')
oView:AddGrid( 'VIEW_ITEM',oItens, 'FISA160ICST')

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_ITEM', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_ITEM', "GRIDSEEK"   , {.T.})

//Retira os campos da View
oCabecalho:RemoveField('CJ0_ID')

//Retira os campos da View
oItens:RemoveField('CJ1_ID')
oItens:RemoveField('CJ1_ID_CAB')
oItens:RemoveField('CJ1_CODCAB')


//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CAB", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Altera titulo
oCabecalho:SetProperty("CJ0_DESCTR", MVC_VIEW_TITULO, "Descrição do Tributo")


//Cria box
//oView:CreateHorizontalBox( 'SUPERIOR'   , 250 , /*cIdOwner*/, .T./*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
//oView:CreateHorizontalBox( 'INFERIOR'   , 600 , /*cIdOwner*/, .T./*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

oView:CreateHorizontalBox( 'SUPERIOR'   , 35 , /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
oView:CreateHorizontalBox( 'INFERIOR'   , 65 , /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )



//Faz vínculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'      , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_ITEM'     , 'INFERIOR'    )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CAB'    , STR0001) //"Cadastro de código de situação tributária"
oView:EnableTitleView('VIEW_ITEM'   , STR0004 ) //"CST"

//Desabilitando opção de ordenação
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

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
Local cRegra        := oModel:GetValue ('FISA160I',"CJ0_CODIGO" ) 
Local dDtIni        := oModel:GetValue ('FISA160I',"CJ0_VIGINI" )
Local dDtFim        := oModel:GetValue ('FISA160I',"CJ0_VIGFIM" )
lOCAL cID           := oModel:GetValue ('FISA160I',"CJ0_ID" )
Local nOperation 	:= oModel:GetOperation()
Local lAtualiza     := nOperation == MODEL_OPERATION_UPDATE
Local lInclui       := nOperation == MODEL_OPERATION_INSERT


//Verifica se já existe regra com mesmo código e mesma vigência já gravados
IF lInclui .OR. lAtualiza

    IF VigIniFIm(cRegra, dDtIni, dDtFim, lAtualiza, cID)
        lRet:= .F.
        Help( ,, 'Help',, STR0005 , 1, 0 ) //'Regra já cadastrada para a vigência informada'
    EndIF
EndiF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Função que verifica se data inicial e data final já existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vigência
@param     dDtFim      - Date - Data final de vigência
@param     lEdit       - Booleano - indica se é uma operação de edição

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vigência vazio 

@author Erick G Dias
@since 09/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdCJ0)

Local lRet       := .F.
Local cSelect	 := ""
Local cFrom	     := ""
Local cWhere	 := ""
Local cAliasQry	 := ""
Local cQuery     := ""
Local oStatement := Nil
Local nRecno     := 0
Local nX         := 1

//Query filtrando filial e regra
cSelect := " SELECT CJ0.CJ0_CODIGO "
cFrom   += " FROM ? CJ0 " 
cWhere  += " WHERE CJ0.CJ0_FILIAL = ? AND "
cWhere  += " CJ0.CJ0_CODIGO = ? "
cWhere  += " AND ( "

//Verifica se está compreendido em cadastro somente com data inicial preenchida
cWhere  += " ( ? >= CJ0.CJ0_VIGINI  AND CJ0.CJ0_VIGFIM = ' ' ) OR " 
//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
cWhere  += " ( ? >= CJ0.CJ0_VIGINI  AND ? <= CJ0.CJ0_VIGFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( CJ0.CJ0_VIGFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( ? >= CJ0.CJ0_VIGINI  AND ? <= CJ0.CJ0_VIGFIM ) " 
    cWhere  += " OR ( ? >= CJ0.CJ0_VIGINI  AND CJ0.CJ0_VIGFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
    //Como temos consulta padrão da CJ0, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a CJ0 originalmente clicada no browse para edição
    DbSelectArea("CJ0")
    CJ0->(DbSetOrder(1))
    If CJ0->(MsSeek( xFilial("CJ0") + cIdCJ0 ))
        cWhere  += " CJ0.R_E_C_N_O_ <> ? AND "
        nRecno := CJ0->(recno()) 
    EndIF    
EndIF

cWhere  += " CJ0.D_E_L_E_T_ = ' '"		

cQuery := cSelect + cFrom + cWhere

oStatement := FwExecStatement():New(cQuery)

oStatement:SetUnsafe(  nX++,  RetSQLName("CJ0"))
oStatement:SetString(  nX++,  xFilial("CJ0"))
oStatement:SetString(  nX++,  cRegra)
oStatement:SetDate(    nX++,  dDtIni)
oStatement:SetDate(    nX++,  dDtIni)
oStatement:SetDate(    nX++,  dDtIni)

If !Empty(dDtFim)
    oStatement:SetDate(    nX++,  dDtFim)
    oStatement:SetDate(    nX++,  dDtFim)
    oStatement:SetDate(    nX++,  dDtFim)
EndIf

If lEdit
    oStatement:SetNumeric(nX++,  nRecno)
EndIf

cQuery	  := oStatement:GetFixQuery()
cAliasQry := oStatement:OpenAlias(GetNextAlias())

IF !(cAliasQry)->(Eof())
    //já existe regra cadastrada para esta vigência
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
(cAliasQry)->(dbCloseArea())

oStatement:Destroy()

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

Local cCodigo     := oModel:GetValue ('FISA160I', "CJ0_CODIGO")
Local lRet          := .T.

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0006 + ": '*', '/', '+', '-', '(' e ')'", 1, 0 ) //"Código não pode conter os caracteres."
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0007, 1, 0 ) //Código não pode conter espaço.
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160DCIZ
Função executada quando usuário entrada na rotina FISA170
Essa rotina faz carga inicial dos CST para os tributos

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160ICJ0()

Local cAlias     := ""
Local cTipoTrib  := ""
Local cCodRegra  := ""
Local cDescr     := ""
local lcargaIni  := !ExisteCarga()
local aRet       := {}
Local aTributos  := {}
Local cQuery     := ""
Local oStatement := Nil

//Se não houver nenhuma relação Tributo/CST cadastrada, fará a carga das informações iniciais.
If lcargaIni

    //Query na SX5
    cQuery := " SELECT X5_TABELA, X5_CHAVE, X5_DESCRI "
    cQuery += " FROM ? SX5 "
    cQuery += " WHERE SX5.X5_TABELA IN ('S2','S3','SG','S9','SX') "
    cQuery += " AND SX5.X5_FILIAL = ? "
    cQuery += " AND SX5.D_E_L_E_T_= ' ' "
    cQuery += " ORDER BY SX5.X5_TABELA, SX5.X5_CHAVE "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:SetUnsafe(1,  RetSQLName("SX5"))
	oStatement:SetString(2,  xFilial("SX5"))

    cQuery	:= oStatement:GetFixQuery()
	cAlias	:= oStatement:OpenAlias(GetNextAlias())

    DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

    //Percorre o resultado da consulta
    Do While !(cAlias)->(Eof())
        If (cAlias)->X5_TABELA == 'S2'
            cTipoTrib:= "000021"//"ICMS"
            cDescr:= STR0009 //"CST DO ICMS"
            cCodRegra:= "000001"
        
        ElseIf (cAlias)->X5_TABELA $ 'SG'
            cTipoTrib:= "000021"//"ICMS"
            cDescr:= STR0010 //"CSOSN DO ICMS NO SIMPLES NACIONAL"
            cCodRegra:= "000002"

        ElseIf (cAlias)->X5_TABELA == 'S3'
            cTipoTrib:= "000022"//"IPI"
            cDescr:= STR0011 //"CST DO IPI"
            cCodRegra:= "000003"

        ElseIf (cAlias)->X5_TABELA == 'S9'
            cTipoTrib:= "000020"//"ISS"
            cDescr:= STR0012 //"CST DO ISS"
            cCodRegra:= "000004"

        ElseIf (cAlias)->X5_TABELA == 'SX'
            cTipoTrib:= "000015"//"PIS"
            cDescr:= STR0013 //"CST DO PIS"
            cCodRegra:= "000005"
            
            //Inclusão do Cofins
            aAdd(aTributos,{"000006", "000016", STR0014, SubStr(Alltrim((cAlias)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI((cAlias)->X5_DESCRI)) } ) //"CST DO COFINS"

        EndIf

        aAdd( aTributos,{ cCodRegra, cTipoTrib, cDescr, SubStr(Alltrim((cAlias)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI((cAlias)->X5_DESCRI)) } )
        (cAlias)->(DbSkip())
    EndDo

    Begin Transaction
        //Gravação da tabela CJ0 e CJ1
        LoadCJ0CJ1(aTributos)

    End Transaction

    (cAlias)->(dbCloseArea())
    oStatement:Destroy()
EndIF

If !lcargaIni 
    aRet := compTable() 
    If Len(aRet) > 0 // Se houver valores no array chama a function updtCJ1 para gravação no CJ1.
        updtCJ1(aRet)
    EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FIS160Inci
Realiza um de/para do CST com a Incidência.

@Return cRet -  Character  - Retorna 1=Tributado,2=Isento ou 3=Outros

@author leandro.faggyas
@since 14/06/2022
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FIS160Inci( cCST, cTipoTrib )
Local cRet     := ""

If     cTipoTrib == "000021" //ICMS
    If cCST $ "|00|10|20|70|101|102|201|202|500|"
        cRet := "1"
    ElseIf cCST $ "|30|40|41|103|203|300|400|"
        cRet := "2"
    ElseIf cCST $ "|50|51|60|90|900|"
        cRet := "3"
    EndIf
ElseIf cTipoTrib == "000022" //IPI
    If cCST $ "|00|01|50|51|"
        cRet := "1"
    ElseIf cCST $ "|02|03|04|52|53|54|"
        cRet := "2"
    ElseIf cCST $ "|05|49|55|99|"
        cRet := "3"
    EndIf
ElseIf cTipoTrib == "000020" //ISS
    If cCST $ "|00|01|02|03|04|05|"
        cRet := "1"
    ElseIf cCST $ "|06|07|08|"
        cRet := "2"
    ElseIf cCST $ "|09|10|"
        cRet := "3"
    EndIf
ElseIf cTipoTrib == "000015" //PIS
    If cCST $ "|01|02|03|04|05|06|"
        cRet := "1"
    ElseIf cCST $ "|07|08|"
        cRet := "2"
    ElseIf cCST $ "|09|49|50|51|52|53|54|55|56|60|61|62|63|64|65|66|67|70|71|72|73|74|75|98|99|"
        cRet := "3"
    EndIf
ElseIf cTipoTrib == "000016" //COFINS
    If cCST $ "|01|02|03|04|05|06|"
        cRet := "1"
    ElseIf cCST $ "|07|08|"
        cRet := "2"
    ElseIf cCST $ "|09|49|50|51|52|53|54|55|56|60|61|62|63|64|65|66|67|70|71|72|73|74|75|98|99|"
        cRet := "3"
    EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteCarga
Função que fará verificação se já existe carga do CST criada nas
tabelas CJ0 e CJ1.
Se houver então retornará verdadeiro, caso contrário retornará falso.

@Return lRet -  Boolean  - Retorna .T. caso exista ao menos 1 CST cadastrado.

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ExisteCarga()

Local lRet      := .F.

dbSelectArea('CJ0')
CJ0->(dbSetOrder(1))

//Se houver ao menos uma linha criada na tabela CJ0, a rotina não fará a carga inicial.
lRet:= Iif(CJ0->( MsSeek ( xFilial('CJ0')) ),.T.,.F.)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCJ0CJ1
Função que carregará o model e incluirá os novos registros nas
tabelas C0J e CJ1

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function LoadCJ0CJ1(aTributos)

Local oModel    := FWLoadModel('FISA160I')
Local nR        := 0
Local cCodRegra := ""

//Ordenar os tributos para a inclusão
ASORT(aTributos, , , { | x,y | x[1]+x[4] < y[1]+y[4]} )

for nR:= 1 to len(aTributos)

    //Verificar se eh um novo imposto para ser gravado
    If cCodRegra <> aTributos[nR][1]
        cCodRegra:= aTributos[nR][1]

        //Quando mudar o Id da regra deverá commitar a inclusão
        If nR <> 1
            If oModel:VldData()
                oModel:CommitData()
            Else		
                VarInfo("",oModel:GetErrorMessage())
                Exit
            EndIf

            oModel:DeActivate()
        
        EndIf
        
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()

        //Para essa operação é preciso especificar qual o modelo que queremos inserir o valor
        oModel:SetValue("FISA160I","CJ0_CODIGO"     , aTributos[nR][1])
        oModel:SetValue("FISA160I","CJ0_DESCR"      , aTributos[nR][3])
        oModel:SetValue("FISA160I","CJ0_IDTRIB"     , aTributos[nR][2])
        oModel:SetValue("FISA160I","CJ0_VIGINI"     , cToD("01/01/1990"))
    EndIf

    //Adiciona uma nova linha no grid
    oModel:GetModel("FISA160ICST"):AddLine()

    oModel:SetValue("FISA160ICST","CJ1_CST"     , aTributos[nR][4])
    oModel:SetValue("FISA160ICST","CJ1_DESCR"   , aTributos[nR][5])

next nR


//Commit da inclusão do último registro
If len(aTributos) > 0
    If oModel:VldData()
        oModel:CommitData()
    Else		
        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PosProces
Função que realiza alterações que devem ocorrer no pre - procesamento 


    @author Rafael Oliveira
    @since 17/08/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------

Static Function PosProces(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cIdCJ0        := ""
Local oItens        := nil
Local nTam          := 0
Local nX            := 0

IF nOperation == MODEL_OPERATION_INSERT
    //Atribui  novo ID
    cIdCJ0  := FWUUID("CJ0")
    oModel:SetValue( 'FISA160I', 'CJ0_ID', cIdCJ0)

    //-----------------------------------
    //Atribui o ID para o grid das faixas
    //-----------------------------------
    oItens := oModel:GetModel("FISA160ICST")
    nTam  := oItens:Length()

    //Laço no grid do tributo
    For nX := 1 to nTam 
        oItens:GoLine(nX)
        oItens:SetValue('CJ1_ID'    , FWUUID("CJ1"))  //Chave da CJ1
        oItens:SetValue('CJ1_ID_CAB' , cIdCJ0) //Chave estrangeira com CJ0
    Next nX

Endif

Return .T.


/*/{Protheus.doc} compTable
Verificar novos cadastros de códigos de CST do ICMS na tabela generica S2 do SX5 para espelhar nos cadastros do Configurador de Tributos 
@type function
@version 12.1.33
@author edinei.pereira
@since 4/4/2023
@return variant, Retarona a difrença da tabela generica S2 do SX5 comparado com CJ1, CST do ICMS
/*/
Static function compTable()
Local cAliasQry  := ""
local aDiferen   := {}
Local cQuery     := ""
Local oStatement := Nil

    //Query no S2 do SX5 bucando códigos de CST do ICMS para comparação com CJ1.
    cQuery := " SELECT X5_TABELA, X5_CHAVE, X5_DESCRI, CJ1.CJ1_CODCAB "
    cQuery += " FROM ? SX5 "
    cQuery += " LEFT JOIN ? CJ1 ON CJ1.CJ1_CODCAB = '000001' AND CJ1.CJ1_FILIAL = ? "
    cQuery += " AND CJ1.D_E_L_E_T_ = ' ' "
    cQuery += " AND CJ1.CJ1_CST = SX5.X5_CHAVE "
    cQuery += " WHERE SX5.X5_TABELA = 'S2' "
    cQuery += " AND SX5.X5_FILIAL = ? "
    cQuery += " AND SX5.D_E_L_E_T_= ' ' "
    cQuery += " ORDER BY SX5.X5_FILIAL, SX5.X5_TABELA, SX5.X5_CHAVE "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:SetUnsafe(1,  RetSQLName("SX5"))
    oStatement:SetUnsafe(2,  RetSQLName("CJ1"))
    oStatement:SetString(3,  xFilial("CJ1"))
	oStatement:SetString(4,  xFilial("SX5"))

    cQuery	  := oStatement:GetFixQuery()
	cAliasQry := oStatement:OpenAlias(GetNextAlias())

    DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

    While !(cAliasQry)->(Eof())
        if Empty((cAliasQry)->CJ1_CODCAB) 
            aAdd( aDiferen,{ SubStr(Alltrim((cAliasQry)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI(ALLTRIM((cAliasQry)->X5_DESCRI))) } )
        endif
        (cAliasQry)->(DbSkip())
    ENDDO

    (cAliasQry)->(dbCloseArea())

    oStatement:Destroy()

Return aDiferen //Retorna diferença do comparado entre S2 do SX5 com CJ1.


/*/{Protheus.doc} updtCJ1
 Update dos cadastros de CST do ICMS nas tabelas do Configurador de Trinutos
@type function
@version 12.1.33
@author edinei.pereira
@since 4/4/2023
@param aDados, array, Diferença de novos códigos de CST do ICMS verificados em comparação na function compTable
@return variadic, Faz gravação de novos códigos de CST do ICMS na tabela CJ1 
/*/
Static function  updtCJ1(aDados)
local oModel := FWLoadModel('FISA160I')
local nX := 0

    oModel:SetOperation(MODEL_OPERATION_UPDATE)

    DBSELECTAREA( 'CJ0' )
    CJ0->(DBSETORDER( 2 ))

    if CJ0->(DBSEEK( xFilial("CJ0") + "000001"))
        oModel:Activate()

        for nX := 1 to len(aDados)
            //Adiciona uma nova linha no grid
            oModel:GetModel("FISA160ICST"):AddLine()

            oModel:SetValue("FISA160ICST","CJ1_CST"     , aDados[nX][1])
            oModel:SetValue("FISA160ICST","CJ1_DESCR"   , aDados[nX][2])
        Next

        If oModel:VldData()
            oModel:CommitData()
        Else
            VarInfo("",oModel:GetErrorMessage())
        EndIf

    endif

    oModel:DeActivate()

return
