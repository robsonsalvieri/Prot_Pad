#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA160M.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA160M

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160M()

Esta rotina tem objetivo de realizar o cadastro das
Regras para geração do Código de receita

@author Rafael oliveira
@since 23/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FISA160M()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ5")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ5")
    oBrowse:SetDescription(STR0001) //Regra para geração do Código da receita
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Rafael oliveira
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160M" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro da regra de código de receita

@author Rafael oliveira
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel := Nil

    //Estrutura Pai do cabeçalho da rotina
    Local oCabecalho := FWFormStruct(1, "CJ5")

    //Estrutura Do modelo de Documento
    Local oModDoc := FWFormStruct(1, "CJ7")    

    //Estrutura das UFs
    Local oItens := FWFormStruct(1, "CJ6")
   
    //Validação dos Itens    
    Local bValdGrid   := {||PosVldCJ6()}//Validação da linha do grid

    //=====================Definição de Modelo com formulario e Grid ========================================

    //Instanciando o modelo
    oModel	:=	MPFormModel():New('FISA160M',,{|oModel|ValidForm(oModel) })

    //Atribuindo cabeçalho para o modelo
    oModel:AddFields("FISA160M" ,,oCabecalho)    

    oModel:addGrid("MODELO_DOC", "FISA160M", oModDoc, /*bLinePre*/, bValdGrid, /*bPre*/, /*bPos*/, /*bLoad*/)

    //Atribuindo as Ufs para Grid do modelo
    oModel:addGrid("ITENS","FISA160M",oItens,/*bLinePre*/, /*bLinPosCIR*/, /*bPre*/, /*bPos*/, /*bLoad*/)



    //===================================Propriedades dos campos=============================================

    //Indica que o campo é chave
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_KEY   , .T. )

    //Validação para não permitir informar um código da regra que já exista no sistema (legado)
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_VALID , {|| ( VldCod(oModel) )})

    //Não permite alterar codigo quando alteração
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == MODEL_OPERATION_INSERT) })
    
    //Campos Obrigatorios no Grid
    oItens:SetProperty("CJ6_ESTADO",MODEL_FIELD_OBRIGAT, .T.)    
    oItens:SetProperty("CJ6_CODREC",MODEL_FIELD_OBRIGAT, .T.)

    
    //==================================Definições adicionais do modelo ================================================

    //Grid não pode ser vazio
    oModel:GetModel('ITENS'):SetOptional(.F.)

    //Grid Não pode ser vazio
    oModel:GetModel('MODELO_DOC'):SetOptional(.F.)


    //Define para não repetir o estado
	oModel:GetModel( "ITENS" ):SetUniqueLine( { "CJ6_ESTADO" } )	

    //Define para não repetir a Especie
    oModel:GetModel( "MODELO_DOC" ):SetUniqueLine( { "CJ7_ESPECI" } )	


    //Define o valor maximo de linhas do grid
    oModel:GetModel('ITENS'):SetMaxLine(9999)

    //Define o valor maximo de linhas do grid
    oModel:GetModel('MODELO_DOC'):SetMaxLine(9999)

    //Relacionamento das tabelas.	
	oModel:SetRelation("ITENS"	, {{ "CJ6_FILIAL", "xFilial('CJ6')"} ,{ "CJ6_CODIGO" ,"CJ5_CODIGO" }} , CJ6->( IndexKey(1) ))

    oModel:SetRelation("MODELO_DOC"	, {{ "CJ7_FILIAL", "xFilial('CJ7')"} ,{ "CJ7_CODIGO" ,"CJ5_CODIGO" }} , CJ7->( IndexKey(1) ))

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0001) //"Regra para geração do Código da receita"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Rafael oliveira    
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    //Criação do objeto do modelo de dados da Interface do Cadastro
    Local oModel     := FWLoadModel( "FISA160M" )

    //Criação da estrutura de dados utilizada na interface do cadastro
    Local oCabecalho := FWFormStruct(2, "CJ5")
    Local oItens     := FWFormStruct(2, "CJ6")
    Local oModDoc    := FWFormStruct(2, "CJ7")    
    Local oView      := Nil

    oView := FWFormView():New()
    oView:SetModel( oModel )

    
    //Adiciona na grid um controle de FormFields
    oView:AddField("VIEW_CABECALHO" , oCabecalho, "FISA160M")
    oView:AddGrid( "VIEW_MODELO_DOC", oModDoc   , "MODELO_DOC" ) 
    oView:AddGrid( "VIEW_ITENS"     , oItens    , "ITENS" ) 

    //Retira da view os campos de ID
    oItens:RemoveField('CJ6_ID')
    oItens:RemoveField('CJ6_CODIGO')    
    oModDoc:RemoveField('CJ7_CODIGO')

    // Cria box visual para separação dos elementos em tela.
	oView:createHorizontalBox( "SUPERIOR", 15, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
    oView:createHorizontalBox( "MEIO"    , 30, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:createHorizontalBox( "INFERIOR", 55, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

    //Faz vínculo do box com a view
    oView:SetOwnerView( 'VIEW_CABECALHO' , 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_MODELO_DOC', 'MEIO'     )
    oView:SetOwnerView( 'VIEW_ITENS'     , 'INFERIOR' )

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_CABECALHO', STR0003 ) //"Definição da Regra"
    oView:EnableTitleView('VIEW_MODELO_DOC', STR0004 ) //"Definição da Regra"
    oView:EnableTitleView('VIEW_ITENS', STR0008 ) //"Definição de modelos de documento"

    //Alteração de Titulo dos campos
    oCabecalho:SetProperty("CJ5_CODIGO", MVC_VIEW_TITULO, STR0009) //"Código do Tributo"
    oModDoc:SetProperty("CJ7_ESPECI", MVC_VIEW_TITULO, STR0010) //"Modelo do Documento"
    
    oItens:SetProperty('CJ6_REF',MVC_VIEW_COMBOBOX,{'1=Mensal','2=1º Quinzena','3=2º Quinzena','4=1º Decêndio','5=2º Decêndio','6=3º Decêndio'})	

    //Aqui é a definição de exibir dois campos por linha
    //oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )
   
    

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Função que valida se o código da regra

@author Rafael oliveira
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160M',"CJ5_CODIGO")
Local lRet      := .T.

//Procura se já existe regra com o mesmo código
CJ5->(DbSetOrder(1))
If CJ5->( MsSeek ( xFilial('CJ5') + cCodigo ) )
    Help( ,, 'Help',, STR0005, 1, 0 ) //"Código já cadastrado!"
    return .F.    
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0007, 1, 0 ) // "Código não pode conter espaço."
    Return .F.
EndIf

//Permite código válido
If Empty(cCodigo)
    Return .T.
EndIF

//Procura se já existe regra com o mesmo código
F2E->(DbSetOrder(2))
If !F2E->( MsSeek ( xFilial('F2E') + cCodigo ) )
    Help( ,, 'Help',, STR0016, 1, 0 ) //"Código já cadastrado!"
    return .F.    
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CodRec
Função que retorna código da Receita

Parametros:
Tributo
Estado
Modelo de nota

Retorno:
Código da receita
Detalhamento
Referência

@author Rafael oliveira
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------

Function CodRec(cTributo, cEstado, cModelo)

    Local aRet      := ""
    Local cSelect	:= ""
    Local cFrom	    := ""
    Local cWhere	:= ""
    Local cAliasQry	:= ""
    Local oQryTmp   := NIL as Object
    Local lCobRec   := CJ6->(FieldPos("CJ6_COBREC")) > 0 // fisExtCmp('CJ6', 'CJ6_COBREC') - Será atualizado para nova função em breve.

    Default cModelo := ""

    cSelect := "SELECT DISTINCT CJ6.CJ6_CODREC, CJ6.CJ6_DETALH, CJ6.CJ6_REF "
    iF lCobRec
        cSelect += ", CJ6.CJ6_COBREC "
    EndIf
    cSelect += ", (CASE WHEN CJ6.CJ6_ESTADO = ? THEN 'S' ELSE 'N' END ) ESTADO "

    cFrom   := "FROM ? CJ5 "

    cFrom   += "INNER JOIN ? F2B ON (F2B.F2B_FILIAL = ? AND CJ5.CJ5_CODIGO = F2B.F2B_TRIB AND F2B_REGRA = ? AND F2B.F2B_ALTERA = '2' AND F2B.D_E_L_E_T_ = ' '  ) "
    cFrom   += "INNER JOIN ? CJ6 ON (CJ6.CJ6_FILIAL = ? AND CJ5.CJ5_CODIGO = CJ6.CJ6_CODIGO AND (CJ6.CJ6_ESTADO = ? OR  CJ6.CJ6_ESTADO = '**') AND CJ6.D_E_L_E_T_ = ' ' ) "  
    cFrom   += "INNER JOIN ? CJ7 ON (CJ7.CJ7_FILIAL = ? AND CJ5.CJ5_CODIGO = CJ7.CJ7_CODIGO AND (CJ7.CJ7_ESPECI = ? OR  CJ7.CJ7_ESPECI = 'TODOS') AND CJ7.D_E_L_E_T_ = ' ' ) "
       
    cWhere  := "WHERE CJ5.CJ5_FILIAL = ? "
    cWhere  += "AND CJ5.D_E_L_E_T_ = ' ' "
    cWhere  += "ORDER BY ESTADO DESC " 

    cAliasQry := ChangeQuery(cSelect+cFrom+cWhere)
    oQryTmp := FwExecStatement():New(cAliasQry)

    oQryTmp:SetString(1,cEstado)
    oQryTmp:SetUnsafe(2,RetSQLName("CJ5"))
    oQryTmp:SetUnsafe(3,RetSQLName("F2B"))
    oQryTmp:SetString(4,xFilial("F2B"))
    oQryTmp:SetString(5,cTributo)
    oQryTmp:SetUnsafe(6,RetSQLName("CJ6"))
    oQryTmp:SetString(7,xFilial("CJ6"))
    oQryTmp:SetString(8,cEstado)
    oQryTmp:SetUnsafe(9,RetSQLName("CJ7"))
    oQryTmp:SetString(10,xFilial("CJ7"))
    oQryTmp:SetString(11,cModelo)
    oQryTmp:SetString(12,xFilial("CJ5"))

    cAliasQry := oQryTmp:OpenAlias(GetNextAlias())

    FREEOBJ( oQryTmp )

    If !(cAliasQry)->(Eof())
        If lCobRec        
            aRet := {ALLTRIM((cAliasQry)->CJ6_CODREC), ALLTRIM((cAliasQry)->CJ6_DETALH), ALLTRIM((cAliasQry)->CJ6_REF), ALLTRIM((cAliasQry)->CJ6_COBREC)}
        Else
            aRet := {ALLTRIM((cAliasQry)->CJ6_CODREC), ALLTRIM((cAliasQry)->CJ6_DETALH), ALLTRIM((cAliasQry)->CJ6_REF), " "}
        EndIf    
    Else
        aRet := {" "," "," "," "}
    Endif 

    //Fecha o Alias antes de sair da função
    dbSelectArea(cAliasQry)
    dbCloseArea()

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160MPOS
Função auxiliar para tratar o inicializador padrão da descrição do 
do Produto, pois o campo X3_RELACAO é limitado e não cabia 
toda a instrução necessária.

@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------

Function FSA160MPOS()

Local cDescr    := ""
Local cEspeci := Upper(Alltrim(CJ7->CJ7_ESPECI)) 

If !INCLUI 
    If AllTrim(cEspeci) == "TODOS"
        cDescr  := "TODOS OS MODELOS"
    Else
        cDescr  := Posicione("SX5",1,xFilial("SX5")+"42"+CJ7->CJ7_ESPECI,"X5_DESCRI")
    EndIF
EndIF

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Função que valida se o código de regra já existe

@author Rafael Oliveira
@since 25/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel) 

Local lRet        := .T.
Local cCodigo     := oModel:GetValue('FISA160M','CJ5_CODIGO')
Local nOperation  := oModel:GetOperation()
Local nRecno      := CJ5->(Recno())
Local nRecnoVld   := 0

If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
	CJ5->(DbSetOrder(1))
	//CJ5_FILIAL, CJ5_CODAJU, CJ5_DTINI
	If CJ5->(DbSeek(xFilial("CJ5")+cCodigo))
		If nOperation == MODEL_OPERATION_UPDATE //Alteração
			nRecnoVld :=  CJ5->(Recno())
			If nRecnoVld <> nRecno
				Help(" ",1,"Help",,STR0011,1,0)//Registro já cadastrado
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"Help",,STR0011,1,0)//Registro já cadastrado
			lRet := .F.
		EndIf
		//Volta Recno posicionado na tela
		CJ5->(DbGoTo(nRecno))
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldCJ6
Função que realiza a validação de pós edição da linha do grid dos valores

@Return     lRet    - Booleano  - REtorno com validação, .T. pode prosseguir, .F. não poderá prosseguir

@author Rafael Oliveira
@since 28/09/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function PosVldCJ6()
Local oModel		:= FWModelActive()
Local oGrid         := oModel:GetModel("MODELO_DOC")
Local nTamGrid	    := oGrid:Length()
Local nLnAtual      := oGrid:Getline()
Local cEsp          := oGrid:GetValue("CJ7_ESPECI")
Local nX            := 0
Local cMsgErro      := ""

For nX := 1 to nTamGrid
    
    //Muda linha do grid
    oGrid:GoLine(nX)    
    
    //Verifico se não estou validando a própria linha
    If nLnAtual <> nX .And. !oGrid:IsDeleted() 

        //Verifica se existe duplicidade ou esta usandoestado especifico ou opção: TODOS
        If (cEsp  == oGrid:GetValue("CJ7_ESPECI")  .OR. AllTrim(cEsp)  == "TODOS" .Or. AllTrim(oGrid:GetValue("CJ7_ESPECI"))  == "TODOS")

            //Mensagem para identificar a linha que está divergente com a linha atual do grid            
            cMsgErro := STR0012 + AllTrim(cEsp) + STR0013  + AllTrim(oGrid:GetValue("CJ7_ESPECI")) + " )" + CRLF //"O Modelo Atual (" -- ") está em conflito  com modelo já cadastrada(: "")"
            
            //Restauro a linha inicial do grid antes de saír da função
            oGrid:GoLine(nLnAtual)
            HELP(' ',1, STR0014 ,, cMsgErro ,2,0,,,,,, {STR0015} ) //"Inconsistência de valores" -- "Verifique os Modelos Digitados"
            Return .F.
            

        EndIF

    EndIF

Next nX

Return .T.

