#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "LJCADAUX.CH"

Static oStJsonCfg   //Objeto Json criado para controlar o conteudo dos campo _CONFIG e os objetos não MVC
Static cStTipoCad   //Tipo do cadastro que esta sendo utilizado
Static lBusGit := .T.    // Busca apenas uma vez o no Git
//Variaveis utilizadas na função LjCadAuxF3, para efetuar consulta padrão
Static cStConF3
Static cStFilF3
Static aStAuxF3
Static lStUmEle

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAux
Modelo MVC Integrações Varejo

@type    function
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjCadAux(cTipoCad,lAbreTela)
    Local lContinua := .T.
	Local oBrowse := Nil

    Default cTipoCad := ""
    Default lAbreTela:= .T.

    If lBusGit
        Processa( {|| lContinua:= LjCadAuxVd(),lBusGit:=.F. }, STR0019,"Aguarde..." )//"Carregando os Layouts Auxiliares"
    EndIf    
    //Valida o dicionario de dados
    If lContinua
        
        If Empty(cTipoCad)
            If Pergunte("LJCADAUX", .T.)
                cTipoCad := MV_PAR01
            Else
                Return Nil
            EndIf
        EndIf

        cStTipoCad := Upper( AllTrim(cTipoCad) )

        oBrowse := FWMBrowse():New()
        oBrowse:SetDescription( Capital(cStTipoCad) )
        oBrowse:SetAlias("MIH")
        oBrowse:SetLocate()

        oBrowse:SetFilterDefault( "MIH_TIPCAD == '" + PadR( cStTipoCad, TamSX3("MIH_TIPCAD")[1] ) + "'" )  
        oBrowse:SetMenuDef("LjCadAux")
        oBrowse:Activate()
        If lAbreTela
            LjCadAux()//executada novamente para escolher outro cadastro auxiliar.
        EndIf    
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type   function
@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, {STR0002, "PesqBrw"         , 0, 1, 0, .T. } )   //"Pesquisar"
    aAdd( aRotina, {STR0003, "VIEWDEF.LjCadAux", 0, 2, 0, NIL } )	//"Visualizar"
    aAdd( aRotina, {STR0004, "VIEWDEF.LjCadAux", 0, 3, 0, NIL } )	//"Incluir"
    aAdd( aRotina, {STR0005, "VIEWDEF.LjCadAux", 0, 4, 0, NIL } )	//"Alterar"
    aAdd( aRotina, {STR0006, "VIEWDEF.LjCadAux", 0, 5, 0, NIL } )	//"Excluir"
	aAdd( aRotina, {STR0007, "VIEWDEF.LjCadAux", 0, 8, 0, NIL } )	//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados das Integrações Varejo

@type    function
@return  FWFormView, Objeto com as configurações a interface do MVC
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "LjCadAux" )
	Local oStructMIH := Nil
    Local oStructDet := NIL
	Local oView		 := Nil
  
	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructMIH := FWFormStruct( 2, "MIH" )
    oStructMIH:RemoveField("MIH_FILIAL")
    oStructMIH:RemoveField("MIH_TIPCAD")
    oStructMIH:RemoveField("MIH_CONFIG")

    //Carrega os campos definidos pelo json
    oStructDet := FWFormViewStruct():New()
    AddCampo("VIEW", @oStructDet, oStJsonCfg["Components"])

    if allTrim(cStTipoCad) == "CADASTRO DE LOJA"
        aAtivo := StrTokArr( allTrim( GetSx3Cache("MIH_ATIVO", "X3_CBOX") ), ";" )

        If Len(aAtivo) < 3
            Aadd(aAtivo, "3=Pendente carga")

            oStructMIH:SetProperty("MIH_ATIVO", MVC_VIEW_COMBOBOX , aAtivo)
        EndIf
    endIf

  	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( Capital(cStTipoCad) )

	oView:AddField("MIHMASTER_VIEW", oStructMIH, "MIHMASTER" )

    //Define a quantidade de colunas por linha
    oView:SetViewProperty("MIHMASTER_VIEW", "SETCOLUMNSEPARATOR", {05}) 
   	oView:SetViewProperty("MIHMASTER_VIEW", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 5}) 

    oView:AddField("MIHDETAIL_VIEW", oStructDet, "MIHDETAIL" )

    oView:SetViewProperty("MIHDETAIL_VIEW", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 4}) 

	oView:CreateHorizontalBox("PANEL_1", 20)
	oView:CreateHorizontalBox("PANEL_2", 80)

    oView:SetOwnerView("MIHMASTER_VIEW", "PANEL_1")
    oView:SetOwnerView("MIHDETAIL_VIEW", "PANEL_2")

    oView:EnableTitleView("MIHMASTER_VIEW", STR0001)    //"Dados para Localização"
    oView:EnableTitleView("MIHDETAIL_VIEW", STR0008)    //"Dados para Integração"
    
	oView:SetUseCursor(.T.)
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Mode de Integrações Varejo

@type    function
@return  MpFormModel, Objeto com as configurações do modelo de dados do MVC
@author  Rafael Tenorio da Costa
@Obs para o SetProperty MODEL_FIELD_WHEN = 8
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStructMIH := NIL
    Local oStructDet := NIL
    Local oModel     := NIL
    Local bPreValid  := Nil
    Local bPosValid  := Nil
    Local nY         := 0
    Local xValue     := Nil
    //Proteção para execAuto do Modelo.
    cStTipoCad := IIF(Valtype(cStTipoCad) !='U', cStTipoCad, "")

    //Objeto Json criado para controlar o conteudo do campo _CONFIG
    IniciaJson()
    
	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructMIH := FWFormStruct(1, "MIH")

    oStructMIH:SetProperty("MIH_TIPCAD", MODEL_FIELD_INIT, {|| cStTipoCad})

    if allTrim(cStTipoCad) == "CADASTRO DE LOJA"
        aAtivo := StrTokArr( allTrim( GetSx3Cache("MIH_ATIVO", "X3_CBOX") ), ";" )

        If Len(aAtivo) < 3
            Aadd(aAtivo, "3=Pendente carga")

            oStructMIH:SetProperty("MIH_ATIVO", MODEL_FIELD_VALUES  , aAtivo)
            oStructMIH:SetProperty("MIH_ATIVO", MODEL_FIELD_VALID   , fwBuildFeature(STRUCT_FEATURE_VALID, "Pertence('123')") )
        EndIf
    endIf

    //Carrega os campos definidos pelo json
    oStructDet := FWFormModelStruct():New()
    If ValType(oStJsonCfg) == "J"

        If oStJsonCfg:hasProperty("Components")
            AddCampo("MODEL", @oStructDet, oStJsonCfg["Components"],oStructMIH)
        EndIf

        If oStJsonCfg:hasProperty("PreValid")
            bPreValid := &("{|oModel| " + oStJsonCfg["PreValid"]["Condition"] + " }") 
        EndIf

        If oStJsonCfg:hasProperty("PosValid")
            bPosValid := &("{|oModel| " + oStJsonCfg["PosValid"]["Condition"] + " }") 
        EndIf
        If oStJsonCfg:hasProperty("SetProperty")
            For nY := 1 To Len(oStJsonCfg["SetProperty"])
                xValue := &("{||" + oStJsonCfg['SetProperty'][nY]['SetValue'] +" }")  
                oStructMIH:SetProperty(oStJsonCfg['SetProperty'][nY]['IdField'],oStJsonCfg['SetProperty'][nY]['Parameter'],xValue)
            next    
        EndIf

    EndIf

	//-----------------------------------------
	//Monta o modelo do formulário  
	//-----------------------------------------
	oModel:= MpFormModel():New("LjCadAux", bPreValid, bPosValid, {|oModel| SalvaMod(oModel)}/*Commit*/, /*Cancel*/)
	oModel:SetDescription( Capital(cStTipoCad) )

	oModel:AddFields("MIHMASTER", /*cOwner*/, oStructMIH, /*Pre-Validacao*/, /*Pos-Validacao*/)

    oModel:AddFields("MIHDETAIL", "MIHMASTER", oStructDet, /*Pre-Validacao*/, /*Pos-Validacao*/, {|oModel, lCopia| CarregaDet(oModel, lCopia)})
    //oModel:GetModel("MIHDETAIL"):SetForceLoad(.T.)

    oModel:GetModel("MIHMASTER"):SetDescription(STR0001)    //"Dados para Localização"
    oModel:GetModel("MIHDETAIL"):SetDescription(STR0008)    //"Dados para Integração"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaMod(oModel)
Faz o commit das informações

@type    function
@param   oModel, MpFormModel, Modelo MVC que será salvo
@return  Lógico, Define se as informações forão salvas corretamente
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function SalvaMod(oModel)

    Local lRetorno  := .T.
    Local nOperacao := oModel:GetOperation()
    Local oRelac    := Nil
    Local aRelac    := {}
    
    If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE

        If nOperacao == MODEL_OPERATION_INSERT

            //Tratamento para não gerar o mesmo MIH_ID, caso tenha algum problema no controle de numeração.
            While Len( RmiXSql("SELECT MIH_ID FROM " + RetSqlName("MIH") + " WHERE MIH_ID = '" + oModel:getValue("MIHMASTER", "MIH_ID") + "'", "*", /*lCommit*/, /*aReplace*/) ) > 0
                oModel:setValue( "MIHMASTER", "MIH_ID", getSxeNum("MIH", "MIH_ID") )
            EndDo
        EndIf

        oModel:SetValue("MIHMASTER", "MIH_DATALT", FWTimeStamp(3) )

        //Insere campos pricipais no json de configuração
        AtuJson(oModel)

        oModel:SetValue("MIHMASTER", "MIH_CONFIG", oStJsonCfg:ToJson() )
        
    ElseIf nOperacao == MODEL_OPERATION_DELETE .And. Alltrim(oModel:GetValue("MIHMASTER", "MIH_TIPCAD")) $ "FECP|ICMS|PIS/COFINS"

        oRelac := RmiRelacionaObj():New()

        oRelac:SetTipo(Alltrim(oModel:GetValue("MIHMASTER", "MIH_TIPCAD")))

        aRelac := oRelac:Consulta(.F.,oModel:GetValue("MIHMASTER", "MIH_ID"))

        If Len(aRelac) > 0 
            lRetorno := .F.
            oModel:SetErrorMessage('MIHMASTER',,,,,STR0018)
        EndIf

        FwFreeObj(oRelac)
        FwFreeArray(aRelac)
    EndIf

    If lRetorno
        lRetorno := FwFormCommit(oModel)
    EndIf

Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuJson
Atualiza json com "Dados para Integração" no objeto oStJsonCfg

@type       function
@param      oModel, FwModelActive, Modelo ativo
@author     Rafael Tenorio da Costa
@since      23/08/21
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Static Function AtuJson(oModel)

    Local nPos       := 0
    Local oStructAux := oModel:GetModel("MIHMASTER"):GetStruct()
	Local aCampos    := oStructAux:GetFields()                  	//Array com os campos da estrutura
    Local nCampo     := 0
    Local cCampo     := ""

    //Atualiza "Dados para Integração" no oStJsonCfg
    oStructAux := oModel:GetModel("MIHDETAIL"):GetStruct()
	aCampos    := oStructAux:GetFields()                  	//Array com os campos da estrutura

    For nCampo:=1 To Len(aCampos)

        cCampo := AllTrim( aCampos[nCampo][3] )

        If ( nPos := aScan( oStJsonCfg["Components"], {|x| x["IdFieldModel"] == cCampo} ) ) == 0          
            nPos := aScan( oStJsonCfg["Components"], {|x| x["IdComponent"] == cCampo})             
        EndIf
        If nPos > 0 
            oStJsonCfg["Components"][nPos]["ComponentContent"] := oModel:GetValue("MIHDETAIL", cCampo)  
        EndIf

    Next nCampo
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAuxF3
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC.

@type    function
@param   cTabela, Caractere, Nome da consulta
@param   cFiltro, Caractere, Filtro que será aplicado na consulta
@param   cTipoRet, Caractere, Define em que ponto a função foi chamada 1=Abertura da Consulta \ 2=Filtro da Consulta(SXB)
@return  Caractere, Retorna a consulta padrão ou o filtro da consulta, depende do parâmetro cTipoRet
@author  Rafael Tenorio da Costa
@since   01/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadAuxF3(cConsulta, cFiltro, cTipoRet, aAuxF3, lUmEle)

    Local cRetorno := ""

    Default cConsulta   := ""
    Default cFiltro     := ""
    Default aAuxF3      := {}
    Default lUmEle      := .F.

    If cTipoRet == "1"
        cStConF3 := cConsulta
        cStFilF3 := cFiltro
        aStAuxF3 := aAuxF3
        lStUmEle := lUmEle

        cRetorno := cStConF3
    Else

        cRetorno := cStFilF3
        cRetorno := "@#(" + cRetorno + ")@#"
    EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAuxVd
Valida artefatos para correta utilização da rotina.

@type    function
@return  Logico, Define se o dicionario está atualizado. 
@author  Rafael Tenorio da Costa
@since   01/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadAuxVd()

    Local lRetorno := .F.

    Do Case 
        
        Case !AmIIn(12)
            LjxjMsgErr(STR0010)             //"Esta rotina deve ser executada somente pelo módulo Controle de Lojas (12)."
        
        Case !FwAliasInDic("MIG") .Or. !FwAliasInDic("MIH")
            LjxjMsgErr(STR0011, STR0012)    //"Dicionário de dados desatualizado."  //"Aplique o pacote de Expedição Contínua - Varejo"
        
        OTherWise
            lRetorno := .T.

            //Carrega layouts iniciais
            If ExistFunc("LjLayAuxCg")
                LjLayAuxCg()
                CadPadrao()
            EndIf
    
    End Case

Return lRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCampo
Adiciona campo ao View ou Model.

@type    function
@param   cOrigem, Caractere, VIEW ou MODEL.
@param   oStruct, FWFormStruct, Objeto com informações do campo 
@param   oJson, JsonObject, Json com a estrutura para criação do campo. 
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddCampo(cOrigem, oStruct, oJson,oStructMIH)

    Local nCampos     := Len(oJson)
    Local nCont       := 0
    Local cCampo      := ""
    Local xConteudo   := Nil
    Local cComponente := ""    
    Local cTitulo     := ""
    Local bValid      := {|| .T. }
    Local bInit       := {||'' }    
    Local cTipo       := ""
    
    Local cValid      := ""
    Local cF3         := ""
    Local lObrigat    := .F.
    Local xWhen       := Nil
    Local bWhen  := {|| .T.}
    Local nTamanho    := 0
    Local aLista      := {}
    Local cPicture    := ""
    Local aTrigger    := {}
    Local nTri        := 0
    Local cOrder      := ""
    Local lVisible    := .T.
    Local aHelp       := {}
    Local cCmpModel   := ""

    Local bPre              := {|| .T.}
    Local cTargetIdField    := "" 
    Local bSetValue         := {|| .T.}

    For nCont:=1 To nCampos
        lVisible := .T.
        aHelp   := {}
        cCmpModel := ""
        If oJson[nCont]:HasProperty("Component")

            cCampo      := oJson[nCont]["IdComponent"]
            xConteudo   := oJson[nCont]["ComponentContent"]
            cTipo       := Upper( oJson[nCont]["ContentType"] )
            cTipo       := IIF( cTipo == "NUMBER", "N", IIF(cTipo == "LOGICAL", "L", IIF(cTipo == "DATE", "D", "C") ) )

            cComponente := Upper( oJson[nCont]["Component"]["ComponentType"] )
            cTitulo     := oJson[nCont]["Component"]["ComponentLabel"]
            lObrigat    := oJson[nCont]["Component"]["Parameters"]["Required"]
            cF3         := oJson[nCont]["Component"]["Parameters"]["F3"]
            cValid      := oJson[nCont]["Component"]["Parameters"]["Valid"]
            nTamanho    := oJson[nCont]["Component"]["Parameters"]["Size"]
            aLista      := oJson[nCont]["Component"]["Parameters"]["List"]
            cPicture    := oJson[nCont]["Component"]["Parameters"]["Picture"]
            aTrigger    := oJson[nCont]["Component"]["Parameters"]["Trigger"]
            xWhen       := oJson[nCont]["Component"]["Parameters"]["CanChange"]
            bInit       := oJson[nCont]["Component"]["Parameters"]["IniPad"]
            cOrder      := oJson[nCont]["Component"]["Parameters"]["Order"]

            If oJson[nCont]:HasProperty("IdFieldModel")   //ID do campo para referenciar no modelo MVC  
                cCmpModel  := oJson[nCont]["IdFieldModel"] 
            EndIf

            If oJson[nCont]["Component"]["Parameters"]:HasProperty("visible")           
                lVisible := oJson[nCont]["Component"]["Parameters"]["visible"]    
            EndIf

            If oJson[nCont]["Component"]["Parameters"]:HasProperty("Help")           
                aHelp := oJson[nCont]["Component"]["Parameters"]["Help"]    
            EndIf

            if nTamanho == Nil
                LjxjMsgErr("LJCADAUX",I18n(STR0013, {cTitulo})) //"Parametro Size não informado no ComponentLabel: #1"                                                                                                                                                                                                                                                                                                                                                                                                                                                                
                Return .F.
            ElseIf ValType( nTamanho ) == "C"
                  nTamanho := &(nTamanho) // macro execução do tamsx3 (Exemplo)
            endif


            If cOrigem == "VIEW" 
                If lVisible
                    If !Empty(cF3) .And. SubStr(cF3, 1, 2) == "{|"
                        cF3 := &(cF3)
                    EndIf
    
                    oStruct:AddField(   ;
                    iif(Empty(cCmpModel),cCampo, cCmpModel)         , ;             // [01] Campo
                    iif(Empty(cOrder),cValToChar(nCont), cOrder)    , ;             // [02] Ordem
                    cTitulo                                         , ;             // [03] Titulo
                    cTitulo                                         , ;             // [04] Descricao
                    aHelp                                           , ;             // [05] Help
                    cComponente                                     , ;             // [06] Tipo do campo: COMBO, GET ou CHECK
                    cPicture                                        , ;             // [07] Picture
                                                                    , ;		        // [08] PictVar
                    cF3                                             , ;             // [09] F3
                                                                    , ;             // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                                                    , ;             // [11] Id da Folder onde o field esta
                                                                    , ;             // [12] Id do Group onde o field esta
                    aLista                                          )               // [13] Array com os Valores do combo
                EndIf
            Else    
      
                If !Empty(cValid)
                    bValid := &("{|oModel,cCampo,xValor| " + cValid + " }")
                Else
                    bValid := {|| .T. }
                EndIf 

                If ValType( xWhen ) <> "U" //se a tag CanChange nao existir nao deixa dar erro.log
                    If ValType( xWhen ) == "L"
                        bWhen := &("{||" + cValToChar(xWhen) +"} ")
                    Else
                        bWhen := &("{|oModel| " + xWhen + " }")
                    EndIf
                EndIf

                oStruct:AddField(   ;
                cTitulo             , ;             // [01] Titulo do campo
                cTitulo             , ;             // [02] ToolTip do campo
                iif(Empty(cCmpModel),cCampo, cCmpModel) , ;             // [03] Id do Field
                cTipo               , ;             // [04] Tipo do campo
                nTamanho            , ;             // [05] Tamanho do campo
                0                   , ;             // [06] Decimal do campo
                bValid              , ;             // [07] Code-block de validação do campo
                bWhen               , ;             // [08] Code-block de validação When do campo
                aLista              , ;             // [09] Lista de valores permitido do campo
                lObrigat            , ;             // [10] Indica se o campo tem preenchimento obrigatório
                FwBuildFeature(STRUCT_FEATURE_INIPAD,bInit))// [11] Bloco de código de inicialização do campo


                If aTrigger <> Nil 
                    For nTri := 1 to Len(aTrigger)           
            
                        cTargetIdField  := aTrigger[nTri]["TargetIdField"] 
                        bSetValue       := &("{|oModel| " + aTrigger[nTri]["SetValue"] + " }")
                        
                        
                        If "MIH" $ Alltrim(aTrigger[nTri]["FieldTrigger"])
                            oStructMIH:AddTrigger( ;
                                Alltrim(aTrigger[nTri]["FieldTrigger"])  , ;          // [01] Id do campo de origem
                                cTargetIdField , ;  // [02] Id do campo de destino
                                bPre, ;             // [03] Bloco de codigo de validação da execução do gatilho
                                bSetValue )         // [04] Bloco de codigo de execução do gatilho
                        else
                        
                            oStruct:AddTrigger( ;
                                iif(Empty(cCmpModel),cCampo, cCmpModel) , ;          // [01] Id do campo de origem
                                cTargetIdField , ;  // [02] Id do campo de destino
                                bPre, ;             // [03] Bloco de codigo de validação da execução do gatilho
                                bSetValue )         // [04] Bloco de codigo de execução do gatilho
                        EndIf
                    Next nTri
                EndIf
            EndIf
        EndIf

    Next nCont

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IniciaJson
Inicializa o objeto oStJsonCfg com o conteudo do campo MIH_CONFIG.

@type    function
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IniciaJson()

    Local lInclui   := If(Type("INCLUI") = "L", INCLUI, .F.)
    Local cJson     := IIF(lInclui, "", MIH->MIH_CONFIG)
    Local cJsonCfg  := Posicione("MIG", 1, xFilial("MIG") + cStTipoCad, "MIG_LAYOUT")   //MIG_FILIAL + MIG_TIPCAD
    Local oJsonCfg  := Nil        
    Local oJsonInteg:= LjJsonIntegrity():New()

    FwFreeObj(oStJsonCfg)
    oStJsonCfg := Nil

    If Empty(cJson)
        cJson := cJsonCfg
    EndIf

    //Caso não tenha configurações retorna panel vazio
    If !Empty(cJson)

        //Atualiza registro com novos componentes
        If !oJsonInteg:CheckString(cJsonCfg, cJson)
            oStJsonCfg := oJsonInteg:GetJson()
        Else
            oStJsonCfg := JsonObject():New()
            oStJsonCfg:FromJson(cJson)
        EndIf
    EndIf        

    oJsonCfg   := Nil
    oJsonInteg := Nil
    FwFreeObj(oJsonCfg)
    FwFreeObj(oJsonInteg)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaDet
Carga dos dados do submodelo MIHDETAIL, carrega os componentes a partir do campo MIH_CONFIG.

@type    function
@param   oModel, FWFormFieldsModel, Que será carregado
@param   lCopia, Lógico, Define se é um operação de copia
@return  Array, Com os campos que serão carregados no sub modulo
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaDet(oModel, lCopia)

    Local nOperacao  := oModel:GetOperation()
	Local aCampos    := oModel:oFormModelStruct:GetFields()     //Array com os campos da estrutura
    Local nCampo     := 0
    Local cCampo     := "" 
    Local aCmpsIni   := Array( Len(aCampos) )
    Local aRetorno   := {aCmpsIni, 0}

    IniciaJson()

    If nOperacao <> MODEL_OPERATION_INSERT

        //Atualiza modelo a partir do oStJsonCfg
        For nCampo:=1 To Len(aCampos)

            cCampo := AllTrim( aCampos[nCampo][3] )
 
            If ( nPos := aScan( oStJsonCfg["Components"], {|x| x["IdFieldModel"] == cCampo} ) ) == 0 
                nPos := aScan( oStJsonCfg["Components"], {|x| x["IdComponent"] == cCampo} )                                  
            EndIf
            If nPos > 0
                aCmpsIni[nCampo] := oStJsonCfg["Components"][nPos]["ComponentContent"]  
            EndIf
        Next nCampo

        aRetorno := { aClone(aCmpsIni), MIH->( Recno() ) }
    EndIf

    FwFreeArray(aCmpsIni)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxValid
Função para uso no Valid de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   cTipoCad, MIH_TIPCAD, campo para seleção 
@param   cCampo, Caracter, Campo da procura no MIH_CONFIG
@param   xValor, Caracter, Valor da procura no MIH_CONFIG
@return  NIL
@author  Danilo Rodrigues
@since   14/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxValid(cTipoCad, cCampo, xValor)
Return Empty(LjAuxPosic(cTipoCad, cCampo, xValor))

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxPosic
Função para uso no Trigger de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   cTipoCad, MIH_TIPCAD, campo para seleção 
@param   cCampo, Caracter, Campo da procura no MIH_CONFIG
@param   xValor, Caracter, Valor da procura no MIH_CONFIG
@param   cCmpRet,Caracter, Campo informado para o retorno do seu conteúdo na função
@return  NIL
@author  Danilo Rodrigues
@since   14/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxPosic(cTipoCad, cCampo, xValor, cCmpRet)

    Local aAreaMIH      := GetArea()
    Local oJsonCfg      := Nil
    Local cJsonCfg      := ""
    Local cRet          := ""
    Local nPos          := 0

    DEFAULT cCampo  := "MIH_ID" 
    DEFAULT cCmpRet := cCampo

    xValor := Alltrim(xValor)

    MIH->(DbSetOrder(1))    
    MIH->(dbSeek(xFilial("MIH") + cTipoCad))
    While !MIH->(EOF()) .and. Alltrim(cTipoCad) == Alltrim(MIH->MIH_TIPCAD)

        cJsonCfg := MIH->MIH_CONFIG
    
        //Carrega configurações do tipo do cadastro        
        oJsonCfg := JsonObject():New()
        oJsonCfg:FromJson(cJsonCfg)             

        If IIF( cCampo == "MIH_ID", Alltrim(MIH->&(cCampo)) == xValor ,( nPos := aScan( oJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCampo)} ) ) > 0 .and. (Alltrim(oJsonCfg["Components"][nPos]["ComponentContent"]) == xValor))

            If cCmpRet == "MIH_ID"
                cRet := MIH->MIH_ID
                Exit
            ElseIf (nPos := aScan( oJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCmpRet)} ) ) > 0 

                cRet := oJsonCfg["Components"][nPos]["ComponentContent"]
                Exit
            EndIf

        EndIf
        MIH->(dbSkip())    
    EndDo

    RestArea(aAreaMIH)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxMsg
Função para uso no Trigger de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   lvld, lógico, retorno lógico da condição de validação
@param   cCampo, Caracter, Campo a ser validado
@param   cIdMsg, Caracter, Código da mensagem do parâmetro Messages do JSON
@param   nEtapa, Numerico, Indica se é uma validação de componente (Components) = 0 , Pre-validação = 1 ou Pos-Validação = 2
@return  NIL
@author  Evandro Pattaro     
@since   14/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxMsg(lvld,cCampo,cIdMsg,nEtapa)

    Local nPos       := 0
    Local nPosmsg    := 0
    Local aMsg       := {}
    Local oModel     := FwModelActive()
    Local cError     := ""

    Default nEtapa := 0

    If !lvld .And. ((nEtapa == 0 .AND. ( nPos := aScan( oStJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCampo)} ) ) > 0) .Or.;
        (nEtapa == 1 .And. oStJsonCfg:hasProperty("PreValid")) .Or.;
        (nEtapa == 2 .And. oStJsonCfg:hasProperty("PosValid")))

        If nEtapa == 0
            aMsg := oStJsonCfg["Components"][nPos]["Component"]["Parameters"]["Messages"]
        ElseIf nEtapa == 1
            aMsg := oStJsonCfg["PreValid"]["Messages"]
        ElseIf nEtapa == 2
            aMsg := oStJsonCfg["PosValid"]["Messages"]
        EndIf 

        If (nPosmsg := aScan(aMsg ,{|x| UPPER(ALLTRIM(x["Id"])) == UPPER(ALLTRIM(cIdMsg))})) > 0 

            cError := aMsg[nPosmsg]["Message"]
        Else 
            cError := "Mensagem de validação não encontrada no Layout (propriedade 'Messages')"
        Endif
    
        oModel:SetErrorMessage('MIHDETAIL',cCampo,,,,cError)
    EndIf

Return lvld

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetComp
Função para retornar o IDProprietário do cadastro de compartilhamentos a partir do código da filial do protheus.

@type    function
@param   cCodLoj, Caracter, Código da filial protheus(SM0)
@param   cProcesso, Caracter, Processo envolvido na busca (MIH_TIPCAD)
@return  NIL
@author  Evandro Pattaro     
@since   18/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjRetComp(cCodLoj,cProcesso)

    Local cRet      := ""
    Local IDLoj     := ""
    Local cMsgErr   := ""  
    
    If Empty(cCodLoj)
        If Empty(cRet := LjAuxPosic("COMPARTILHAMENTOS", "nivel", '0',"IdProprietario"))
           cMsgErr := STR0015//"Agrupamento geral(nível 0) não encontrado no cadastro de compartilhamentos."   
        EndIf    
    
    Else
        If !Empty(IDLoj := LjAuxPosic(cProcesso, "IDFilialProtheus", cCodLoj,"MIH_ID"))
            If Empty(cRet := LjAuxPosic("COMPARTILHAMENTOS", "CodigoLoja", IDLoj,"IdProprietario"))
                cMsgErr := STR0016//"IDRetaguarda não encontrado para esta filial. Verifique o cadastro de compartilhamentos."
            EndIf
        Else 
            cMsgErr := STR0017//"Filial não encontrada no cadastro de lojas."        
        EndIf
    Endif

    If !Empty(cMsgErr)
        LjGrvLog("LjRetComp", cMsgErr, {cCodLoj,cProcesso}, /*lCallStack*/)
    EndIf    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCAuxRet
Retorna o conteúdo da TAG do campo MIH_CONFIG, já posicionado na MIH.

@type    function
@param   cComponent, Carectere, Identificador do componente
@return  Caractere, Conteúdo do componente
@author  Rafael Tenorio da Costa
@since   08/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCAuxRet(cComponent)

    Local oJsonCfg  := JsonObject():New()
    Local nPos      := 0
    Local xConteudo := ""

    oJsonCfg:FromJson(MIH->MIH_CONFIG)

    If ( nPos := aScan( oJsonCfg["Components"], {|x| x["IdComponent"] == cComponent} ) ) > 0
       xConteudo := oJsonCfg["Components"][nPos]["ComponentContent"]
    EndIf

    FwFreeObj(oJsonCfg)

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCAuxPesq
Pesquisa um registro na MIH a partir do MIH_CONFIG, com as caracteristicas
passadas no array aCampos.

@type    function
@param   aCampos, Array, Array com os campos procurados {cTag, xConteudo}
@return  Caractere, MIH_ID do registros localizado
@author  Rafael Tenorio da Costa
@since   08/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCAuxPesq(cTipoCad, aCampos)

    Local aAreaMIH  := GetArea()
    Local cRetorno  := ""
    Local lEncontrou:= .T.
    Local oJsonCfg  := JsonObject():New()
    Local nPos      := 0
    Local cCampo    := ""
    Local xValor    := Nil
    Local nCont     := 0

    MIH->( DbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
    MIH->( DbSeek(xFilial("MIH") + cTipoCad) )
    While !MIH->( Eof() ) .And. Alltrim(MIH->MIH_TIPCAD) == Alltrim(cTipoCad) 

        lEncontrou := .T.

        //Carrega configurações do tipo do cadastro
        oJsonCfg:FromJson(MIH->MIH_CONFIG)

        //Procura todos os campos dentro do JSON
        For nCont:=1 To Len(aCampos)

            cCampo := Alltrim(aCampos[nCont][1])
            xValor := Alltrim(aCampos[nCont][2])

            nPos := aScan( oJsonCfg["Components"], {|x| Alltrim(x["IdComponent"]) == cCampo} )

            If nPos == 0 .Or. Alltrim(oJsonCfg["Components"][nPos]["ComponentContent"]) <> xValor
                lEncontrou := .F.
                Exit
            EndIf
        Next nCont

        If lEncontrou
            cRetorno := MIH->MIH_ID 
            Exit
        EndIf

        MIH->( DbSkip() )
    EndDo

    RestArea(aAreaMIH)

    FwFreeObj(oJsonCfg)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadxF3Mu
Função chamada da consulta padrão LJF3MU, para apresentação de tela com seleção de multiplos registros.

@type    function
@return  Lógico, Definindo se foi confirmada ou não a tela da consulta
@author  Rafael Tenorio da Costa
@since   15/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadxF3Mu()

    Local aArea     := GetArea()
	Local cTitulo 	:= aStAuxF3[3]
	Local aOpcoes	:= {}
    Local cOpcoes	:= ""
    Local cReadVar  := Alltrim( ReadVar() )
	Local aMarcados := {}
    Local cMarcados := ""
    Local cSql      := ""
    Local aSql      := {}
    Local cCmpChave := aStAuxF3[1]
    Local cCmpDesc  := aStAuxF3[2]
    Local cTabela   := ""
    Local nTamChave := 0
    Local nCont     := 1
    Local lConfirma := .F.

    if subStr(cCmpChave, 1, 1) == "X"

        cTabela   := "S" + subStr(cCmpChave, 1, 2)
        nTamChave := 10

        cSql := " SELECT " + cCmpChave + ", " + cCmpDesc
        cSql += " FROM " + retSqlName(cTabela)
        cSql += " WHERE 1=1"
    else

        cTabela   := GetSx3Cache(cCmpChave, "X3_ARQUIVO")
        nTamChave := TamSx3(cCmpChave)[1]

        cSql := " SELECT " + cCmpChave + ", " + cCmpDesc
        cSql += " FROM " + RetSqlName(cTabela)
        cSql += " WHERE " + PrefixoCPO(cTabela) + "_FILIAL = '" + xFilial(cTabela) + "'"
    endIf

    cSql += " AND D_E_L_E_T_ = ' '"

    If !Empty(cStFilF3)
        cSql += " AND " + cStFilF3
    EndIf

    aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    For nCont:=1 To Len(aSql)
        cOpcoes +=    aSql[nCont][1]
        Aadd(aOpcoes, aSql[nCont][2])
    Next nCont

	If f_Opcoes(@aMarcados	,;	//Variavel de Retorno
				cTitulo		,;	//Titulo da Coluna com as opcoes # Tipos
				aOpcoes	    ,;	//Opcoes de Escolha (Array de Opcoes)
				cOpcoes     ,;	//String de Opcoes para Retorno
				NIL			,;	//Nao Utilizado
				NIL			,;	//Nao Utilizado
				lStUmEle	,;	//Se a Selecao sera de apenas 1 Elemento por vez
				nTamChave   ,;	//Tamanho da Chave
				Len(aOpcoes),;	//Número maximo de elementos na variavel de retorno
				NIL     	,;	//Inclui Botoes para Selecao de Multiplos Itens
				.F.			,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
				NIL			,;	//Qual o Campo para a Montagem do aOpcoes
				.T.			,;	//Nao Permite a Ordenacao
				.T.			,;	//Nao Permite a Pesquisa
				.T.     	,;	//Forca o Retorno Como Array
				NIL			 ;	//Consulta F3
		)

        For nCont:=1 To Len(aMarcados)
            cMarcados += aMarcados[nCont] + ";"
        Next nCont

        lConfirma := .T.
        &cReadVar := cMarcados   //Devolve Resultado para ReadVar(), que é utilizado na consulta padrão
    EndIf

    FwFreeArray(aSql)
    FwFreeArray(aOpcoes)
	
    RestArea(aArea)

Return lConfirma
//-------------------------------------------------------------------
/*/{Protheus.doc} LjLayVld
Faz cadastro padrão de Operador e Praça.
@type    function
@author  Everson S P Junior
@since   21/07/23
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CadPadrao()
Local oModel    := Nil
Local aPerfil   := {"CAIXA PADRÃO","VENDEDOR PADRÃO","SUPERVISOR PADRÃO"}
Local nX        := 0
Local lRet      := .T.

MIH->(DbSetOrder(1))    
Begin Transaction
    If !MIH->(dbSeek(xFilial("MIH") + PadR("PRACA",TAMSX3("MIH_TIPCAD")[1])  )) .OR. !MIH->(dbSeek(xFilial("MIH") + PadR("PRACA",TAMSX3("MIH_TIPCAD")[1]) + PadR("00001",TAMSX3("MIH_ID")[1])  ))
        //Execução da cadPadrao de Praça.
        cStTipoCad := "PRACA" 
        oModel    := FWLoadModel('LjCadAux')
        oModel:SetOperation( MODEL_OPERATION_INSERT )
        oModel:Activate()
        oModel:LoadValue( 'MIHMASTER', "MIH_ID", "00001" )    
        oModel:SetValue( 'MIHMASTER', "MIH_DESC", "PRAÇA PADRÃO" )
        IIF(lRet := oModel:VldData(),oModel:CommitData(),MSGINFO(STR0022,STR0021))//"Não foi possivel carregar o Cadastro Padrão de Praça", "Verifique!"
        LjGrvLog("LjCadAux", "CadPadrao -> ", IIF(!lRet,oModel:GetErrorMessage(),"Cadastro Praça Padrao com Sucesso!"), /*lCallStack*/) 
        oModel:DeActivate()
        //------------------------------
    EndIf
    If !MIH->(dbSeek(xFilial("MIH") + PadR("PERFIL DE OPERADOR",TAMSX3("MIH_TIPCAD")[1])  ))
        //"PERFIL DE OPERADOR" 
        cStTipoCad := "PERFIL DE OPERADOR" 
        oModel    := FWLoadModel( 'LjCadAux' )
        For nX := 1 To Len(aPerfil)
            oModel:SetOperation( MODEL_OPERATION_INSERT )
            oModel:Activate()
            oModel:LoadValue( 'MIHMASTER', "MIH_ID", "0000"+Alltrim(Str(nX+1)))    
            oModel:SetValue( 'MIHMASTER', "MIH_DESC", aPerfil[nX] )
            IIF(lRet := oModel:VldData(),oModel:CommitData(),MSGINFO(STR0020+aPerfil[nX],STR0021))    //"Não foi possivel carregar o Cadastro Padrao de PERFIL DE OPERADOR -> ", "Verifique!"
            LjGrvLog("LjCadAux", "CadPadrao -> ", IIF(!lRet,oModel:GetErrorMessage(),"Cadastro PERFIL DE OPERADOR Padrao com Sucesso! "+aPerfil[nX]), /*lCallStack*/) 
            oModel:DeActivate()
        next
    EndIf

End Transaction

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PSHSetTCad
Atualiza a varivel Static cStTipoCad Tipo do cadastro
reposalvel pela inicialização do Modelo de dados
@type    function
@author  Everson S P Junior
@since   21/07/23
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function PSHSetTCad(cTipCad)
cStTipoCad := cTipCad
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PshListCad
Retorna uma lista de dados de um campo específico do mesmo tipo de cadastro
@Param  cTipoCad, Caracter, Tipo de cadastro a ser pesquisado
@Param  cCampo, Caracter, Campo a ser pesquisado
@Return aRet, Array, Array com os dados encontrados
@type    function
@author  Evandro Pattaro
@since   21/07/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function PshListCad(cTipoCad,aCampos)

    Local aAreaMIH  := MIH->(GetArea())
    Local oJsonCfg  := JsonObject():New()
    Local aRet := {}
    Local aValues := {}
    Local nCont := 0
    Local cCampo := ""
    

    MIH->( DbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
    MIH->( DbSeek(xFilial("MIH") + cTipoCad) )
    While !MIH->( Eof() ) .And. Alltrim(MIH->MIH_TIPCAD) == Alltrim(cTipoCad) 

        nCont   := 0
        aValues := {}
        //Carrega configurações do tipo do cadastro
        oJsonCfg:FromJson(MIH->MIH_CONFIG)

        For nCont:=1 To Len(aCampos)

            cCampo := Alltrim(aCampos[nCont])

            nPos := aScan( oJsonCfg["Components"], {|x| Alltrim(x["IdComponent"]) == cCampo} )

            If nPos > 0 
                Aadd(aValues, oJsonCfg["Components"][nPos]["ComponentContent"])
            Else 
                Aadd(aValues, "")
            EndIf

        Next nCont
        
        If Len(aValues) > 0
            Aadd(aRet, aClone(aValues))
        EndIf

        MIH->( DbSkip() )
    EndDo

    RestArea(aAreaMIH)
    FwFreeObj(oJsonCfg)
    FwFreeArray(aValues)

Return aRet

/*/{Protheus.doc} PshGrvCad
Função genérica para gravação de cadastros auxiliares na MIH.

@param cTipoDado   Define o tipo de cadastro (ex: "PRACA", "PERFIL DE OPERADOR")
@param nOperacao   Tipo de operação (ex: MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE)
@param aCampos     Array com os dados a serem gravados { { "Model", "Campo", Valor }, ... }

@return lRetorno   Verdadeiro se gravou com sucesso
/*/
Function PshGrvCad(cTipoDado, nOperacao, aCampos)
    Local oModel    := nil
    Local lRetorno  := .F.
    Local cErro     := ""
    Local aCampo
    Local nI
    Local cFonte    := ProcSource()

    // Define o tipo de cadastro
    pshSetTCad(cTipoDado)

    // Carrega o modelo
    oModel := FwLoadModel("LjCadAux")

    oModel:SetOperation(nOperacao)
    oModel:Activate()

    // Preenche os campos
    For nI := 1 To Len(aCampos)
        aCampo := aCampos[nI]
        // aCampo = { "Model", "Campo", Valor }
        oModel:loadValue(aCampo[1], aCampo[2], aCampo[3])
    Next

    lRetorno := oModel:vldData() .And. oModel:commitData()
    cErro    := oModel:GetErrorMessage()[6]

    oModel:DeActivate()
    oModel:Destroy()
    fwFreeObj(oModel)

    ljGrvLog(cFonte, "Resultado da gravação do cadastro genérico:", {cTipoDado,lRetorno, cErro})

Return lRetorno
