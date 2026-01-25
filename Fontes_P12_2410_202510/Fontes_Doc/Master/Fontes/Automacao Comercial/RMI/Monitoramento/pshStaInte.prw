#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PSHSTAINTE.CH"

Static aStProcesso
Static cStProcesso
Static cStStatus
Static cStFilial
Static cStDataPor
Static dStDataDe
Static dStDataAte
Static cStChave
Static nStQtdInt
Static nStQtdInAl
Static nStQtdPed
Static nStQtdNoInt
Static nStQtdTotal
Static cStCnChave
Static nStAba
Static nMaxSize
Static nStart
Static nLimit
Static cLimQry

Static lPag

//Definições do array aStProcesso
#DEFINE MHNCOD      1
#DEFINE MHNTABELA   2
#DEFINE MHNCHAVE    3
#DEFINE MHNFILTRO   4
#DEFINE MHNF3       5
#DEFINE MHNCMPDES   6

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStaInte
Tela de Status da integração

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStaInte()

	Local aBotoes   := {{.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,STR0001}, {.T.,STR0002}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}}  //"Confirmar"    //"Fechar"

	/*	
	VERSAO 11
	O array aEnableButtons tem por padrão 14 posições: aBotoes
	1 - Copiar
	2 - Recortar
	3 - Colar
	4 - Calculadora
	5 - Spool
	6 - Imprimir
	7 - Confirmar
	8 - Cancelar
	9 - WalkTrhough
	10 - Ambiente
	11 - Mashup
	12 - Help
	13 - Formulário HTML
	14 - ECM
	*/

    aStProcesso := {}
    cStProcesso := ""
    cStStatus   := ""
    cStFilial   := ""    
    cStDataPor  := ""
    dStData     := cToD("")
    cStChave    := ""
    nStQtdInt   := 0
    nStQtdInAl  := 0    
    nStQtdPed   := 0
    nStQtdNoInt := 0
    nStQtdTotal := 0
    nStAba      := 1
    nMaxSize    := Val(IIF( GetPvProfString("GENERAL", "MaxStringSize", "undefined", GetAdv97()) <> "",  GetPvProfString("GENERAL", "MaxStringSize", "undefined", GetAdv97()) , "1")) * 1000000
    cLimQry:= "1000"
    
    Private aDados := {}
    Private nPage  := 1

    FWExecView(STR0003/*cTitulo*/, "pshStaInte"/*cPrograma*/, MODEL_OPERATION_UPDATE/*nOperation*/,  /*oDlg*/, {|| .T.}/*bCloseOnOK*/, {|| .T.}/*bOk*/, /*nPercReducao*/,  aBotoes/*aEnableButtons*/, {|| .T.}/*bCancel*/, /*cOperatId*/,  /*cToolBar*/, /*oModelAct*/)	//"Alterar"

    FwFreeArray(aStProcesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

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

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, {STR0004, "PesqBrw"           , 0, 1, 0, .T. } )    //"Pesquisar"
	aAdd( aRotina, {STR0005, "VIEWDEF.pshStaInte", 0, 2, 0, NIL } )    //"Visualizar"
	aAdd( aRotina, {STR0006, "VIEWDEF.pshStaInte", 0, 3, 0, NIL } )    //"Incluir"
	aAdd( aRotina, {STR0003, "VIEWDEF.pshStaInte", 0, 4, 0, NIL } )    //"Alterar"
	aAdd( aRotina, {STR0007, "VIEWDEF.pshStaInte", 0, 5, 0, NIL } )    //"Excluir"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de importação de documentos

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel        := FWLoadModel("pshStaInte")
	Local oStrEnvio     := FWFormViewStruct():New()
    Local oStrResumo    := FWFormViewStruct():New()    
	Local oStrEnvioGrid := FWFormStruct(2/*nType*/, "MIP"/*cAliasSX2*/,/*bSX3*/, /*lViewUsado*/, /*lVirtual*/, .T./*lFilOnView*/, /*cProgram*/)
	Local oView         := Nil
	Local cLink         := STR0141  //"https://tdn.totvs.com/pages/releaseview.action?pageId=861568709"
    Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

    //Carrega campo do filtro
    camposFiltro(oStrEnvio, .T.)

    //Carrega campo do Resumo
    camposResumo(oStrResumo, .T.)

    //Carrega campo do grid
    camposGrid(oStrEnvioGrid, .T.)

	//Monta o view do formulário
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Cria folder
	oView:CreateFolder("FOLDER")

     //Aba Status serviços
    If ExistFunc("pshStResView")
        pshStResView(@oView)
    EndIf
	//Aba de Envio - Cadastros
	oView:AddField("ENVMASTER_VIEW" , oStrEnvio     , "ENVMASTER")
    oView:AddField("ENVRESUMO_VIEW" , oStrResumo    , "ENVRESUMO")
	oView:AddGrid("ENVDETAIL_VIEW"  , oStrEnvioGrid , "ENVDETAIL")

    oView:SetViewProperty("ENVDETAIL_VIEW", "GRIDDOUBLECLICK", bDblClick)

	oView:AddSheet('FOLDER', 'ABA_F01', STR0116,{|| aDados := {}}) //"Cadastros"
	oView:CreateHorizontalBox("BOX_F01_01", 35,,, "FOLDER", "ABA_F01")
    oView:CreateHorizontalBox("BOX_F01_03", 5,,,  "FOLDER", "ABA_F01")
	oView:CreateHorizontalBox("BOX_F01_02", 60,,, "FOLDER", "ABA_F01")
    

    oView:CreateVerticalBox('BOX_F01_01_ESC', 70, 'BOX_F01_01', ,"FOLDER", "ABA_F01")
    oView:CreateVerticalBox('BOX_F01_01_DIR', 30, 'BOX_F01_01', ,"FOLDER", "ABA_F01")
	
	oView:SetOwnerView("ENVMASTER_VIEW", "BOX_F01_01_ESC")
    oView:SetOwnerView("ENVRESUMO_VIEW", "BOX_F01_01_DIR")
	oView:SetOwnerView("ENVDETAIL_VIEW", "BOX_F01_02")

    oView:AddOtherObject("CTRL_PAGINA", {|oPanel| SetButtons(oPanel)})
    oView:SetOwnerView("CTRL_PAGINA", "BOX_F01_03")
	
	oView:EnableTitleView("ENVMASTER_VIEW", STR0008)    //"Filtro"
    oView:SetViewProperty("ENVMASTER_VIEW", "SETLAYOUT"         , {FF_LAYOUT_VERT_DESCR_TOP, 4})
   
    oView:EnableTitleView("ENVRESUMO_VIEW", STR0009)    //"Resumo"
    oView:SetViewProperty("ENVRESUMO_VIEW", "SETLAYOUT"         , {FF_LAYOUT_HORZ_DESCR_TOP, 3})
    oView:SetViewProperty("ENVRESUMO_VIEW", "SETCOLUMNSEPARATOR", {10})

    oView:EnableTitleView("ENVDETAIL_VIEW", STR0010)    //"Resultado"
    oView:SetNoInsertLine("ENVDETAIL_VIEW")
    oView:SetNoUpdateLine("ENVDETAIL_VIEW")
    oView:SetNoDeleteLine("ENVDETAIL_VIEW")
	oView:SetViewProperty("ENVDETAIL_VIEW", "GRIDVSCROLL", {.T.})
    //oView:SetViewProperty("ENVDETAIL_VIEW", "GRIDFILTER" , {.T.})     //Insere filtro no grid
	
	oView:SetUseCursor(.T.)
	oView:EnableControlBar(.T.)

    oView:AddIncrementField("ENVDETAIL_VIEW", "ITEM")   //Campo criado para numerar as linhas do grid

    //Aba Vendas
    pshStBuWiew(@oView)

    oView:AddUserButton( STR0047, "BUDGET", { |oView| Processa( {|| lPag := .F.,PSHStaPsq(oView)} ) } ,,,,.T.) 	                    //"Pesquisar"
    oView:AddUserButton( STR0048, "BUDGET", { |oView| Processa( {|| exportar(oView) } ) } ,,,,.T.)	                    //"Exportar"
    oView:AddUserButton( STR0068, "BUDGET", { |oView| Processa( {|| PSHArtef(oView) } ) } ,,,,.T.)                      //"Gerar Artefato"
    oView:AddUserButton( STR0089, "BUDGET", { |oView| Processa( {|| ShellExecute("Open", cLink, "", "", 1)} ) } ,,,,.T.)//"Ajuda"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de importação de documentos

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel         := Nil
	Local oStrEnvio      := FWFormModelStruct():New()
    Local oStrResumo     := FWFormModelStruct():New()
	Local oStrEnvioGrid  := FWFormStruct(1, "MIP")

    //Carrega campo do filtro
    camposFiltro(oStrEnvio, .F.)

    //Carrega campo do Resumo
    camposResumo(oStrResumo, .F.)

    //Carrega campo do grid
    camposGrid(oStrEnvioGrid, .F.)

	//Monta o modelo do formulário
	oModel:= MPFormModel():New("pshStaInte", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	
	oModel:SetDescription(STR0011)  //"Status da Integração"

	//Aba Envio - Cadastros
    oModel:AddFields("ENVMASTER", /*cOwner*/, oStrEnvio, /*Pre-Validacao*/, /*Pos-Validacao*/, {|| })
	oModel:GetModel("ENVMASTER"):SetDescription(STR0008)    //"Filtro"

	oModel:AddFields("ENVRESUMO", "ENVMASTER", oStrResumo, /*Pre-Validacao*/, /*Pos-Validacao*/, {|| })
	oModel:GetModel("ENVRESUMO"):SetDescription(STR0009)    //"Resumo"

    oModel:AddGrid("ENVDETAIL", "ENVMASTER", oStrEnvioGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid, lCopia| selectEnv(oGrid, lCopia)})
	oModel:GetModel("ENVDETAIL"):SetDescription(STR0010)    //"Resultado"
	oModel:GetModel("ENVDETAIL"):SetOnlyView(.T.)           //Define que nao permitira a alteração dos dados
    oModel:GetModel("ENVDETAIL"):SetUseOldGrid(.T.)         //Indica que o submodelo deve trabalhar com aCols/aHeader.

    oModel:getModel("ENVDETAIL"):SetOnlyQuery(.T.)

    //Aba Busca - Movimentações
    pshStBuMod(@oModel)
   
    //Aba Status serviços
    If ExistFunc("pshStResMod")   
        pshStResMod(@oModel)
    EndIf

    oModel:setOnDemand(.T.)

    oModel:SetPrimaryKey( {} )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} camposFiltro
Cria campos do box filtro

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function camposFiltro(oStruct as Object, lView as Logical)

    Local cOrdem        := "00"
    Local aProcessos    := processos("1")
    Local aStatus       := {"", STR0070, STR0012, STR0013}      //"1=Pendente   //"2=Integrados com sucesso"    //"3=Falha na integração"
    Local aDataPor      := {"", STR0014, STR0015, STR0046}      //"1=Envio"     //"2=Retorno"                   //"3=Alteração"

    If lView

        oStruct:AddField( ;
        "PROCESSO"                  , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0017                     , ; // [03] Titulo          //"Processo"
        STR0018                     , ; // [04] Descricao       //"Processo para filtro"
                                    , ; // [05] Help
        'COMBO'                     , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!S11'                     , ; // [07] Picture - [@!S para fixar o tamanho]
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
        aProcessos                  )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "STATUS"                    , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0019                     , ; // [03] Titulo          //"Status"
        STR0020                     , ; // [04] Descricao       //"Status para filtro"
                                    , ; // [05] Help
        'COMBO'                     , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
        aStatus                     )   // [13] Array com os Valores do combo


        oStruct:AddField( ;
        "FILIAL"                    , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0045                     , ; // [03] Titulo          //"Filial"
        STR0045                     , ; // [04] Descricao       //"Filial"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        'SM0EMP'                    , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo        

        oStruct:AddField( ;
        "DATAPOR"                   , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0021                     , ; // [03] Titulo          //"Data por"
        STR0022                     , ; // [04] Descricao       //"Define como será aplicado o filtro de data"
        {STR0023}                   , ; // [05] Help            //"Define como será aplicado o filtro de data no grid, por data de envio ou data de retorno."
        'COMBO'                     , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
        aDataPor                    )   // [13] Array com os Valores do combo        

        oStruct:AddField( ;
        "DATADE"                    , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0024                     , ; // [03] Titulo          //"Data"
        STR0025                     , ; // [04] Descricao       //"Data para filtro"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "DATAATE"                   , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0120                     , ; // [03] Titulo          //"Data"
        STR0025                     , ; // [04] Descricao       //"Data para filtro"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "CHAVE"                     , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0026                     , ; // [03] Titulo          //"Palavra chave"
        STR0027                     , ; // [04] Descricao       //"Palavra chave para filtro"
        {STR0016}                   , ; // [05] Help            //"Será utilizada no filtro dentro do campo Chave Única, pode ser o código do produto por exemplo, caso o processo sejá PRODUTO. Também pode ser o código UUID de alguma integração expecifica."
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        ''                          , ; // [07] Picture
                                    , ; // [08] PictVar
        {|| pshStF3Chv()}           , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        //Pula linha
	    oStruct:SetProperty("FILIAL"    , MVC_VIEW_INSERTLINE   , .T.)

    Else

        oStruct:AddField(	;
        STR0017           	                                , ; // [01] Titulo do campo         //"Processo"
        STR0018             	                            , ; // [02] ToolTip do campo        //"Processo para filtro"
        "PROCESSO"        	                                , ; // [03] Id do Field
        "C"                                                 , ; // [04] Tipo do campo
        TamSx3("MHN_COD")[1]                                , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        FwBuildFeature(1, "pshStVlPro()" )                  , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
        aProcessos                                          , ; // [09] Lista de valores permitido do campo
        .T.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
                                                            , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.


        oStruct:AddField(	;
        STR0019      	                                    , ; // [01] Titulo do campo         //"Status"
        STR0020             	                            , ; // [02] ToolTip do campo        //"Status para filtro"
        "STATUS"        	                                , ; // [03] Id do Field
        "C"                                                 , ; // [04] Tipo do campo
        1                                                   , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
        aStatus                                             , ; // [09] Lista de valores permitido do campo
        .F.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
                                                            , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.                                                            

        oStruct:AddField(	;
        STR0045      	                                    , ; // [01] Titulo do campo         //"Filial"
        STR0045             	                            , ; // [02] ToolTip do campo        //"Filial"
        "FILIAL"        	                                , ; // [03] Id do Field
        "C"                                                 , ; // [04] Tipo do campo
        TamSx3("MIP_FILIAL")[1]                             , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
                                                            , ; // [09] Lista de valores permitido do campo
        .F.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
                                                            , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0021                                             , ; // [01] Titulo do campo         //"Data por"
        STR0022                                             , ; // [02] ToolTip do campo        //"Define como será aplicado o filtro de data"
        "DATAPOR"        	                                , ; // [03] Id do Field
        "C"                                                 , ; // [04] Tipo do campo
        1                                                   , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
        aDataPor                                            , ; // [09] Lista de valores permitido do campo
        .T.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
        {||"1"}                                                    , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0024  	                                        , ; // [01] Titulo do campo         //"Data"
        STR0025               	                            , ; // [02] ToolTip do campo        //"Data para filtro"
        "DATADE"        	                                , ; // [03] Id do Field
        "D"                                                 , ; // [04] Tipo do campo
        8                                                   , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
                                                            , ; // [09] Lista de valores permitido do campo
        .T.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
        {||DDATABASE}                                       , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0024  	                                        , ; // [01] Titulo do campo         //"Data"
        STR0025               	                            , ; // [02] ToolTip do campo        //"Data para filtro"
        "DATAATE"        	                                , ; // [03] Id do Field
        "D"                                                 , ; // [04] Tipo do campo
        8                                                   , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
                                                            , ; // [09] Lista de valores permitido do campo
        .T.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
        {||DDATABASE}                                       , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0026     	                                    , ; // [01] Titulo do campo         //"Palavra chave"
        STR0027                 	                        , ; // [02] ToolTip do campo        //"Palavra chave para filtro"
        "CHAVE"        	                                    , ; // [03] Id do Field
        "C"                                                 , ; // [04] Tipo do campo
        TamSx3("MHQ_CHVUNI")[1]                             , ; // [05] Tamanho do campo
        0                                                   , ; // [06] Decimal do campo
        		                                            , ; // [07] Code-block de validação do campo
        					                                , ; // [08] Code-block de validação When do campo
                                                            , ; // [09] Lista de valores permitido do campo
        .F.                                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
                                                            , ; // [11] Bloco de código de inicialização do campo
                                                            , ; // [12] Indica se trata-se de um campo chave.
                                                            , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                                                 )   // [14] Indica se o campo é virtual.

        oStruct:AddTrigger( "PROCESSO"          , ; // [01] Id do campo de origem
                            "CHAVE"             , ; // [02] Id do campo de destino
                            { || .T.}           , ; // [03] Bloco de codigo de validação da execução do gatilho
                            { || "" } )             // [04] Bloco de codigo de execução do gatilho

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} camposResumo
Cria campos do box resumo

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function camposResumo(oStruct as Object, lView as Logical)

    If lView

        oStruct:AddField( ;
        "QTDINT"                    , ; // [01] Campo
        "01"                        , ; // [02] Ordem
        STR0042                     , ; // [03] Titulo          //"Integrados"
        STR0042                     , ; // [04] Descricao       //"Integrados"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
        .F.                         , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "QTDPED"                    , ; // [01] Campo
        "02"                        , ; // [02] Ordem
        STR0043                     , ; // [03] Titulo          //"Pendentes"
        STR0043                     , ; // [04] Descricao       //"Pendentes"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
        .F.                         , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "QTDNOINT"                  , ; // [01] Campo
        "03"                        , ; // [02] Ordem
        STR0044                     , ; // [03] Titulo          //"Falha"
        STR0044                     , ; // [04] Descricao       //"Falha"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
        .F.                         , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo    

        oStruct:AddField( ;
        "QTDTOTAL"                  , ; // [01] Campo
        "04"                        , ; // [02] Ordem
        STR0084                     , ; // [03] Titulo          //"Total"
        STR0084                     , ; // [04] Descricao       //"Total"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
        .F.                         , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

    Else

        oStruct:AddField(	;
        STR0042  	                , ; // [01] Titulo do campo         //"Integrados"
        STR0042     	            , ; // [02] ToolTip do campo        //"Integrados"
        "QTDINT"                    , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.


        oStruct:AddField(	;
        STR0043       	            , ; // [01] Titulo do campo         //"Pendentes"
        STR0043                     , ; // [02] ToolTip do campo        //"Pendentes"
        "QTDPED"                    , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.    


        oStruct:AddField(	;
        STR0044                     , ; // [01] Titulo do campo         //"Falha"
        STR0044                     , ; // [02] ToolTip do campo        //"Falha"
        "QTDNOINT"                  , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.    

        oStruct:AddField(	;
        STR0084                     , ; // [01] Titulo do campo         //"Total"
        STR0084                     , ; // [02] ToolTip do campo        //"Total"
        "QTDTOTAL"                  , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} camposGrid
Cria campos do grid resultado e atualiza propriedades

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function camposGrid(oStruct as Object, lView as Logical)

    Local aStatus := {"1=" + STR0028, STR0029, STR0030, "6=" + STR0028}    //"Pendente"     //"2=Integrado"     //"3=Falha na integração"       //"Pendente retorno"

    If lView

        oStruct:AddField( ;
        "ITEM"                      , ; // [01] Campo
        "00"                        , ; // [02] Ordem
        ""                          , ; // [03] Titulo
        ""                          , ; // [04] Descricao
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo     

        oStruct:AddField( ;
        "LEGENDA"                   , ; // [01] Campo
        "01"                        , ; // [02] Ordem
        ""                          , ; // [03] Titulo
        ""                          , ; // [04] Descricao
                                    , ; // [05] Help
        'BT'                        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@BMP'                      , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "NOMEFILIAL"                , ; // [01] Campo
        "04"                        , ; // [02] Ordem
        STR0031                     , ; // [03] Titulo          //"Nome Filial"
        STR0031                     , ; // [04] Descricao       //"Nome Filial"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        ''                          , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo   

        oStruct:AddField( ;
        "DESCRICAO"                 , ; // [01] Campo
        "06"                        , ; // [02] Ordem
        STR0069                     , ; // [03] Titulo          //"Descrição"
        STR0069                     , ; // [04] Descricao       //"Descrição"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo       

        oStruct:AddField( ;
        "ALTERACAO"                 , ; // [01] Campo
        "07"                        , ; // [02] Ordem
        STR0032                     , ; // [03] Titulo          //"Alteração"
        STR0032                     , ; // [04] Descricao       //"Alteração"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo                                    

        oStruct:AddField( ;
        "MENSAGEM"                  , ; // [01] Campo
        "13"                        , ; // [02] Ordem
        STR0033                     , ; // [03] Titulo          //"Mensagem"
        STR0034                     , ; // [04] Descricao       //"Descrição da Falha"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        ''                          , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        //Remove campos do grig
        oStruct:RemoveField("MIP_CPROCE")
        oStruct:RemoveField("MIP_UUID")
        oStruct:RemoveField("MIP_UIDORI")
        oStruct:RemoveField("MIP_IDRET")
        oStruct:RemoveField("MIP_PDV")
        oStruct:RemoveField("MIP_DTDADO")   //Este é um campo que retiramos do ATUSX, só esta aqui para não ser apresentado caso exista na base
        oStruct:RemoveField("MIP_EVENTO")
        oStruct:RemoveField("MIP_UIDCON")
        oStruct:RemoveField("MIP_STCON" )
        oStruct:RemoveField("MIP_VALCON")
        oStruct:RemoveField("MHR_ENVIO")

        oStruct:SetProperty("ITEM"      , MVC_VIEW_ORDEM    , "00")
        oStruct:SetProperty("LEGENDA"   , MVC_VIEW_ORDEM    , "01")
        oStruct:SetProperty("MIP_STATUS", MVC_VIEW_ORDEM    , "02")
        oStruct:SetProperty("MIP_FILIAL", MVC_VIEW_ORDEM    , "03")
        oStruct:SetProperty("NOMEFILIAL", MVC_VIEW_ORDEM    , "04")
        oStruct:SetProperty("MIP_CHVUNI", MVC_VIEW_ORDEM    , "05")
        oStruct:SetProperty("DESCRICAO" , MVC_VIEW_ORDEM    , "06")
        oStruct:SetProperty("ALTERACAO" , MVC_VIEW_ORDEM    , "07")
        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_ORDEM    , "08")
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_ORDEM    , "09")
        oStruct:SetProperty("MIP_DATPRO", MVC_VIEW_ORDEM    , "10")
        oStruct:SetProperty("MIP_HORPRO", MVC_VIEW_ORDEM    , "11")
        oStruct:SetProperty("MIP_ULTOK" , MVC_VIEW_ORDEM    , "12")
        oStruct:SetProperty("MIP_LOTE"  , MVC_VIEW_ORDEM    , "13")
        oStruct:SetProperty("MENSAGEM"  , MVC_VIEW_ORDEM    , "14")

        oStruct:SetProperty("MIP_STATUS", MVC_VIEW_COMBOBOX , aStatus)

        oStruct:SetProperty("NOMEFILIAL", MVC_VIEW_WIDTH    , 150)
        oStruct:SetProperty("MIP_CHVUNI", MVC_VIEW_WIDTH    , 150)
        oStruct:SetProperty("DESCRICAO" , MVC_VIEW_WIDTH    , 200)
        oStruct:SetProperty("ALTERACAO" , MVC_VIEW_WIDTH    , 150)
        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("MIP_DATPRO", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("MIP_HORPRO", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("MIP_ULTOK" , MVC_VIEW_WIDTH    , 110)
        oStruct:SetProperty("MIP_LOTE" , MVC_VIEW_WIDTH     , 110)

        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_TITULO   , STR0035)     //"Data Envio"
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_TITULO   , STR0036)     //"Hora Envio"
        oStruct:SetProperty("MIP_DATPRO", MVC_VIEW_TITULO   , STR0037)     //"Data Retorno"
        oStruct:SetProperty("MIP_HORPRO", MVC_VIEW_TITULO   , STR0038)     //"Hora Retorno"

    Else

        oStruct:AddField(	;
        ""  	                    , ; // [01] Titulo do campo
        ""     	                    , ; // [02] ToolTip do campo
        "ITEM"                      , ; // [03] Id do Field
        "N"                         , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
                                    )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        ""  	                    , ; // [01] Titulo do campo
        ""     	                    , ; // [02] ToolTip do campo
        "LEGENDA"                   , ; // [03] Id do Field
        "BT"                        , ; // [04] Tipo do campo
        5                           , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
        {|| pshStLeg(MIP_STATUS, STATUS) }  , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0031  	                , ; // [01] Titulo do campo             //"Nome Filial"
        STR0031      	            , ; // [02] ToolTip do campo            //"Nome Filial"
        "NOMEFILIAL"                , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        30                          , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
        	                        , ; // [07] Code-block de validação do campo
        	                        , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
        {|| SubStr(FwSM0Util():GetSM0Data(/*cEmpAnt*/, MIP_FILIAL, {"M0_FILIAL"})[1][2], 1, 30) }                            , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0069  	            , ; // [01] Titulo do campo             //"Descrição" 
        STR0069      	        , ; // [02] ToolTip do campo            //"Descrição" 
        "DESCRICAO"                 , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        150                         , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
        	                        , ; // [07] Code-block de validação do campo
        	                        , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0032  	                , ; // [01] Titulo do campo             //"Alteração"
        STR0032      	            , ; // [02] ToolTip do campo            //"Alteração"
        "ALTERACAO"    	            , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        25                          , ; // [05] Tamanho do campo
                                    , ; // [06] Decimal do campo
        	                        , ; // [07] Code-block de validação do campo
        	                        , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.


        oStruct:AddField(	;
        STR0033  	                , ; // [01] Titulo do campo             //"Mensagem"
        STR0034                     , ; // [02] ToolTip do campo            //"Descrição do Erro"
        "MENSAGEM"                  , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        100                         , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    )   // [11] Bloco de código de inicialização do campo

        oStruct:AddField(	;
        STR0147                     , ; // [01] Titulo do campo             //"Dados enviados ao PDV"
        STR0147                     , ; // [02] ToolTip do campo            //"Dados enviados ao PDV"
        "MHR_ENVIO"                 , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        100                         , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    )   // [11] Bloco de código de inicialização do campo

        oStruct:SetProperty("MIP_STATUS", MODEL_FIELD_VALUES, aStatus)
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PSHStaPsq
Botão que pesquisa os dados que serão apresentados no grid

@param  oView - View de dados

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function PSHStaPsq(oView)
 
	Local oModel    := FwModelActive()
    Local aModels   := buscaModel()
	Local lResumo   := .F.
    nStAba := oView:GetFolderActive("FOLDER", 2)[1]
    
    If IIf(ExistFunc("pshStResView"),nStAba > 1,.T.)
        If !oModel:getModel(aModels[1]):vldData()

            LjxjMsgErr(STR0039, /*cSolucao*/, /*cRotina*/)      //"Filtros obrigatórios não preenchidos"
        Else
            lResumo := aModels[2] == "BUSRESUMO"
            ProcRegua(0)

            IncProc(STR0040)        //"Aguarde... pesquisando"
            IncProc(STR0040)        //"Aguarde... pesquisando"

            cStProcesso := oModel:getValue(aModels[1], "PROCESSO")
            cStStatus   := oModel:getValue(aModels[1], "STATUS")
            cStFilial   := oModel:getValue(aModels[1], "FILIAL")        
            cStDataPor  := oModel:getValue(aModels[1], "DATAPOR")
            dStDataDe   := oModel:getValue(aModels[1], "DATADE")
            dStDataAte  := oModel:getValue(aModels[1], "DATAATE")
            cStChave    := AllTrim( oModel:getValue(aModels[1], "CHAVE") )


            oModel:deActivate()
            oModel:activate()

            oModel:loadValue(aModels[1], "PROCESSO", cStProcesso)
            oModel:loadValue(aModels[1], "STATUS"  , cStStatus)
            oModel:loadValue(aModels[1], "FILIAL"  , cStFilial)        
            oModel:loadValue(aModels[1], "DATAPOR" , cStDataPor)
            oModel:loadValue(aModels[1], "DATADE"  , dStDataDe)
            oModel:loadValue(aModels[1], "DATAATE" , dStDataAte)
            oModel:loadValue(aModels[1], "CHAVE"   , cStChave)

            oModel:loadValue(aModels[2], "QTDINT"   , IIF(lResumo,nStQtdInt,cValToChar(nStQtdInt)))
            IIF(lResumo,oModel:loadValue(aModels[2], "QTDINAL", nStQtdInAl),.F.)
            oModel:loadValue(aModels[2], "QTDPED"   , IIF(lResumo,nStQtdPed,cValToChar(nStQtdPed)))
            oModel:loadValue(aModels[2], "QTDNOINT" , IIF(lResumo,nStQtdNoInt,cValToChar(nStQtdNoInt)))
            oModel:loadValue(aModels[2], "QTDTOTAL" , IIF(lResumo,nStQtdTotal,cValToChar(nStQtdTotal)))

            oModel:getModel(aModels[3]):goLine(1)

            oView:Refresh()

            //Aba Envio - Cadastros
            if oView:GetFolderActive("FOLDER", 2)[1] == IIf(ExistFunc("pshStResView"),2,1)
                If !empty(cStChave) .and. oModel:getModel(aModels[3]):isEmpty()
                    PshDetPesq()
                EndIf
            endIf
        EndIf
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} exportar
Botão que exporta os dados que apresentados no grid

@param  oView - View de dados

@author  Rafael tenorio da Costa 
@since 	 26/10/23
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function exportar(oView)
 
	Local oModel        := FwModelActive()
    Local aModel        := buscaModel(oView)
    Local oEnvDetail    := oModel:getModel(aModel[3])
    Local aDetail       := {}
    Local aCabeçalho    := {}
    Local nCont         := 0

    If !oEnvDetail:isEmpty()
        ProcRegua(0)

        IncProc(STR0041)        //"Aguarde... gerando arquivo"
        IncProc(STR0041)        //"Aguarde... gerando arquivo"
        IncProc(STR0041)        //"Aguarde... gerando arquivo"
        
        aDetail := oEnvDetail:getOldData()

        For nCont:=1 To Len(aDetail[1])
            aAdd(aCabeçalho, aDetail[1][nCont][1])
        Next nCont

        rmiExpExcel(aDetail[2], aCabeçalho, "statusIntegração_")

        oModel:getModel(aModel[3]):goLine(1)
    EndIf

    fwFreeArray(aModel)
    fwFreeArray(aCabeçalho)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} selectEnv
Carrega dados do grid de resultado a cada active do modelo.

@param  oModel Modelo de dados ativo
@return aRet Dados que serão exibidos no grid de máscaras

@author  Rafael Tenorio da Costa
@since   01/11/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function selectEnv(oGrid, lCopia)

    Local aArea     := GetArea()
    Local aAreaMIP  := MIP->( GetArea() )
    Local aGrid     := {}
    Local cTabela   := GetNextAlias()
    Local cSql      := ""
    Local aProcesso := {}
    Local cBanco    := upper( tcGetDb() )
    Local nX1       := 0
    Local nI        := 0
    Local cSelect   := ""
    Local cFrom     := ""
    Local cWhere    := ""
    Local cStamp    := ""
    Local nMaxPag   := 100
    Local aDtSlct   := {}
    
    If FwIsInCallStack("PSHStaPsq") .and. nStAba == IIf(ExistFunc("pshStResView"),2,1)
        If !lPag 

            aDados := {}
            nPage := 1
            nStart := 1
            nLimit := nMaxPag

            nStQtdInt   := 0
            nStQtdInAl  := 0        
            nStQtdPed   := 0
            nStQtdNoInt := 0
            nStQtdTotal := 0

            //Criação da string para comparação de datas PADRÃO
            cStamp += " REPLACE(FORMAT("+sqlUtcLocal(cBanco)+",'G','pt-BR'),' ','-') "

            //Primeiro select cria a temporaria com menos dados para carregamento
            cSelect := " SELECT "+PSHLimitQry("SELECT")+" 0 AS ITEM, "
            cSelect +=          " MIP_FILIAL,MIP_CPROCE,MIP_CHVUNI,MIP_LOTE,MIP_IDRET,MIP_DATGER, "
            cSelect +=          " MIP_HORGER,MIP_DATPRO,MIP_HORPRO,MIP_STATUS,MIP_ULTOK,MIP_UUID, "
            cSelect +=          " MIP_UIDORI,MIP_PDV,MIP_EVENTO,MIP_DTCONF,MIP_TENTAT,MIP.D_E_L_E_T_,MIP.R_E_C_N_O_,"
            cSelect +=          " ISNULL(CAST(CAST(MHL_ERROR AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS MHL_ERROR, "
            cSelect +=          " ISNULL( " + cStamp + ",' ') "
            cSelect +=          " AS STAMP "
            
            cFrom := " FROM " + RetSqlName("MIP") + " MIP"
            
            cFrom +=    " LEFT JOIN " + RetSqlName("MHL") + " MHL"
            cFrom +=        " ON (MHL_FILIAL = ' ' OR MHL_FILIAL = MIP_FILIAL) AND (MIP_UIDORI = MHL_UIDORI OR MIP_UUID = MHL_UIDORI) AND MHL.D_E_L_E_T_ = ' '"

            cFrom +=    " LEFT JOIN " + RetSqlName("MHR") + " MHR"
            cFrom +=        " ON MHR_FILIAL = '" + xFilial("MHR") + "' AND MIP_UIDORI = MHR_UIDMHQ AND MHR.D_E_L_E_T_ = ' '"
          
           //Inclui data de alteração do registro
            aProcesso := retProcesso(cStProcesso)
            If Len(aProcesso) > 0

                cSelect += " ," + cStamp
                cSelect += " AS ALTERACAO"

                cSelect += " ,"
                cSelect +=      IIF( !empty(aProcesso[MHNCMPDES]), aProcesso[MHNCMPDES], "''") 
                cSelect += " AS DESCRICAO"  

                cFrom += " LEFT JOIN " + RetSqlName( aProcesso[MHNTABELA] ) + " PR"
                cFrom +=    " ON RTRIM(MIP_CHVUNI) = RTRIM(CONCAT(" + StrTran(aProcesso[MHNCHAVE], "+", ",'|',") + ")) AND PR.D_E_L_E_T_ = ' ' "

            EndIf

            cSelect += ",CASE WHEN MIP_STATUS IN ('1','6') AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) > CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '" + STR0086 + "' )"   //"O dado foi enviado do Protheus para o PDV OMNI e esta aguardando se foi integrado com sucesso no PDV."
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) < CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '" + STR0086 + "' )"   //"O registro foi alterado recentemente e está aguardando o processamento dos serviços/jobs de integração (RMIPUBLICA,RMIDISTRIB,RMIENVIA)"
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) = CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '" + STR0086 + "' )"   //"O dado foi enviado do Protheus para o PDV OMNI e esta aguardando se foi integrado com sucesso no PDV."
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND MIP_ULTOK = ' '   THEN ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '" + STR0086 + "' )"   //"O dado foi enviado do Protheus para o PDV OMNI e esta aguardando se foi integrado com sucesso no PDV."
            cSelect +=      " WHEN MIP_STATUS = '2' AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) > CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN '" + STR0090 + "'"                                                     //"Registro integrado com sucesso."
            cSelect +=      " WHEN MIP_STATUS = '2' AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) < CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '" + STR0087 + "' )"          //"O dado foi enviado do Protheus para o PDV OMNI e esta aguardando se foi integrado com sucesso no PDV."
            cSelect +=      " WHEN MIP_STATUS = '2' AND CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) = CONVERT(datetime,"+sqlUtcLocal(cBanco)+") THEN '" + STR0090 + "'"                                                     //"Registro integrado com sucesso."
            cSelect +=      " WHEN MIP_STATUS IN ('3','A') THEN CONCAT('"+STR0073+"',ISNULL( CAST(MHL_ERROR AS VARCHAR(4000)), ''))"                  //"Motivo: "
            cSelect +=      " ELSE ISNULL(CAST(MHL_ERROR AS VARCHAR(4000)), '') "
            cSelect += " END AS MENSAGEM, "

            cSelect += " CASE "
            cSelect +=      " WHEN "+CompStamp("ULTOK")+" THEN  'ULTOK' "
            cSelect +=      " WHEN "+CompStamp("STAMP")+" THEN  'STAMP' "
            cSelect +=      " WHEN MIP_STATUS IN ('3','A') THEN 'ULTOK' "
            cSelect +=      " ELSE 'ULTOK' "
            cSelect += " END AS STATUS, "

            cSelect += "LTRIM( RTRIM( " + jQryMemo("MHR_ENVIO", /*cBanco*/, /*nReduz*/, 4000) + ") ) AS MHR_ENVIO"

            //Aplica filtros
            cWhere := " WHERE MIP.D_E_L_E_T_ = ' '"

            If !Empty(cStFilial)
                cWhere += " AND MIP_FILIAL = '" + cStFilial + "'"
            EndIf  

            If !Empty(cStProcesso)
                cWhere += " AND MIP_CPROCE = '" + cStProcesso + "'"
            EndIf

            If !Empty(cStChave)
                cWhere += " AND ( MIP_CHVUNI LIKE '%" + cStChave + "%' OR MIP_UUID = '" + cStChave + "' OR MIP_UIDORI = '" + cStChave + "' )"
            EndIf

            If !Empty(dStDataDe) .and. !Empty(dStDataAte)
                //1=Envio
                If cStDataPor == "1"
                    cWhere += " AND (MIP_DATGER >= '" + dToS(dStDataDe) + "'"
                    cWhere += " AND MIP_DATGER <= '" + dToS(dStDataAte) + "')"
                //2=Retorno
                ElseIf cStDataPor == "2"
                    cWhere += " AND (MIP_DATPRO >= '" + dToS(dStDataDe) + "'"
                    cWhere += " AND MIP_DATPRO <= '" + dToS(dStDataAte) + "')"
                //3=Alteração
                Else
                    cWhere += " AND (" + IIF(cBanco == "MSSQL", "FORMAT(SWITCHOFFSET(PR.S_T_A_M_P_, SUBSTRING(CAST(SYSDATETIMEOFFSET() AS VARCHAR(35)), 29, 6)),'yyyyMMdd')", "TO_CHAR(S_T_A_M_P_, 'YYYYMMDD')") + " >= '" + dToS(dStDataDe) + "'"
                    cWhere += " AND " + IIF(cBanco == "MSSQL", "FORMAT(SWITCHOFFSET(PR.S_T_A_M_P_, SUBSTRING(CAST(SYSDATETIMEOFFSET() AS VARCHAR(35)), 29, 6)),'yyyyMMdd')", "TO_CHAR(S_T_A_M_P_, 'YYYYMMDD')") + " <= '" + dToS(dStDataAte) + "')"
                EndIf
            EndIf

            If !Empty(cStStatus)

                //1=Pendente retorno
                If cStStatus == "1"
                    cWhere += " AND (MIP_STATUS IN ('1','6') OR ("+CompStamp("STAMP")+")) "
                
                //2=Integrado com Sucesso
                elseif cStStatus == "2"
                    cWhere += " AND MIP_STATUS = '2' AND ("+CompStamp("ULTOK")+")"

                //3=Falha na integração
                Else
                    cWhere += " AND MIP_STATUS IN ('3','A') "
                EndIf
            EndIf

            cWhere += PSHLimitQry("WHERE")

            cWhere += " ORDER BY MIP.R_E_C_N_O_ DESC"

            cWhere += PSHLimitQry("ORDER")

            cSql += cSelect + cFrom + cWhere

            dbUseArea(.T., "TOPCONN", TcGenQry( , , cSql), cTabela, .F., .T.)

            TcSetField(cTabela, "MIP_DATGER", "D" , 8 , 0)
            TcSetField(cTabela, "MIP_DATPRO", "D" , 8 , 0)

            aDtSlct := FwLoadByAlias(oGrid, cTabela)

            aDados := aClone(aDtSlct)
            nStQtdTotal := Len(aDtSlct)

            For nI := 1 To Len(aDtSlct)
                AtuQtdStat(aDtSlct[nI][2][10],aDtSlct[nI][2][22])
            Next

            //limite de 100 itens por página
            If Len(aDtSlct) < nMaxPag
                nLimit := Len(aDtSlct)
            Else
                nLimit := nMaxPag
            EndIf

            For nI:= 1 to nLimit
                Aadd(aGrid,aDtSlct[nI])
            Next


            For nX1:= 1 to len(aGrid)
                If aGrid[nX1][2][17] ==  "BR_AMARELO.PNG"
                    aGrid[nX1][2][10] := "6"
                Endif
            Next
            
            (cTabela)->( dbCloseArea() )
        Else //controle de paginação

            aDtSlct := aClone(aDados)

            If nPage <= 0
                nPage := 1
            EndIf

            If nPage > 1
                If Len(aDtSlct) < ((nPage - 1) * nMaxPag) + 1
                    nPage--
                EndIf
                nStart := ((nPage - 1) * nMaxPag) + 1
            Else 
                nStart := 1    
            EndIf

            If Len(aDtSlct) < nPage * nMaxPag
                nLimit := Len(aDtSlct)
            Else
                nLimit := nPage * nMaxPag
            EndIf

            If Len(aDtSlct) < nPage * nMaxPag
                nLimit := Len(aDtSlct)
            Else
                nLimit := nPage * nMaxPag
            EndIf

            For nI := nStart to nLimit
                Aadd(aGrid,aDtSlct[nI])
            Next

            For nX1:= 1 to len(aGrid)
                If aGrid[nX1][2][17] ==  "BR_AMARELO.PNG"
                    aGrid[nX1][2][10] := "6"
                Endif
            Next

        EndIf

    EndIf
    
    RestArea(aAreaMIP)
    RestArea(aArea)

Return aGrid

//-------------------------------------------------------------------
/*/{Protheus.doc} processos
Carrega os processos que serão apresentados no campo combo PROCESSO

@param  cTipo, caractere, define o tipo 1=Envio, 2=Busca
@return aRet, array, retorna os processos ativos na integração

@author  Rafael Tenorio da Costa
@since   01/11/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function processos(cTipo as Character) as Array

    Local aArea     := GetArea()
    Local aRet      := {""}
    Local cTabela   := GetNextAlias()
    Local cSql      := ""
    Local cPdvOmni  := PadR("PDVSYNC"   , TamSx3("MHP_CASSIN")[1])
    Local cTotvsPdv := PadR("TOTVS PDV" , TamSx3("MHP_CASSIN")[1])    
    Local lMhnF3    := MHN->( ColumnPos("MHN_F3") ) > 0
    Local lMhnDsc   := MHN->( ColumnPos("MHN_CMPDES") ) > 0

    aStProcesso := {}

    cSql := " SELECT MHP_CPROCE, MHN_TABELA, MHN_CHAVE, MHN_FILTRO"
    cSql += IIF(lMhnF3, ", MHN_F3", ", '' AS MHN_F3")
    cSql += IIF(lMhnDsc, ", MHN_CMPDES", ", '' AS MHN_CMPDES")
    cSql +=    " FROM " + RetSqlName("MHP") + " MHP INNER JOIN " + RetSqlName("MHN") + " MHN"
    cSql += " ON MHP_FILIAL = MHN_FILIAL AND MHP_CPROCE = MHN_COD AND MHN.D_E_L_E_T_ = ' '"
    cSql += " WHERE MHP.D_E_L_E_T_ = ' '"
    cSql +=     " AND MHP_CASSIN IN ('" + cPdvOmni + "', '" + cTotvsPdv + "')"
    cSql +=     " AND MHP_TIPO = '" + cTipo + "'"
    cSql +=     " AND MHP_ATIVO = '1'"
    cSql += "GROUP BY MHP_CPROCE, MHN_TABELA, MHN_CHAVE, MHN_FILTRO"
    cSql += IIF(lMhnF3, ", MHN_F3", "")
    cSql += IIF(lMhnDsc, ", MHN_CMPDES", "")

    dbUseArea(.T., "TOPCONN", TcGenQry( , , cSql), cTabela, .F., .T.)

    While !(cTabela)->( Eof() )
        aAdd(aRet, (cTabela)->MHP_CPROCE)

        aAdd(aStProcesso, {(cTabela)->MHP_CPROCE, IIf(Alltrim((cTabela)->MHP_CPROCE) == "CONDICAO PAGTO","SAE",(cTabela)->MHN_TABELA), IIF(Alltrim((cTabela)->MHP_CPROCE) == "CONDICAO PAGTO","AE_FILIAL+AE_COD",(cTabela)->MHN_CHAVE), (cTabela)->MHN_FILTRO, (cTabela)->MHN_F3,(cTabela)->MHN_CMPDES})

        (cTabela)->( dbSkip() )
    EndDo

    (cTabela)->( dbCloseArea() )

    RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStLeg
Carrega a legenda do grid resultados

@param  cStatus, caractere, MIP_STATUS define o resultado na integração o registros
@return cImagem, caractere, descrição da legenda que será apresentada

@author  Rafael Tenorio da Costa
@since   01/11/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStLeg(cStatus, cSituacao)

    Local cImagem := ""

    If Alltrim(cSituacao) == "STAMP"
        cImagem     := 'BR_AMARELO.PNG'
    Else
        Do Case
            Case cStatus $ "2|A" 
                cImagem     := 'BR_VERDE.PNG' 
            Case cStatus $ "3|IR"
                cImagem     := 'BR_VERMELHO.PNG'


            Otherwise 
                cImagem     := 'BR_AMARELO.PNG'
        EndCase
    Endif
Return cImagem

/*/{Protheus.doc} PSHArtef
    Rotina para geração dos artefatos para o Suporte
    @type  Static Function
    @author Samuel de Vincenzo
    @since 20/02/2024
    @version 12.1.2410
/*/
Static Function PSHArtef(oView)

    Local oModel        := FwModelActive()
    Local aModel        := buscaModel(oView)
    Local oEnvDetail    := oModel:getModel(aModel[3])
    Local aDetail       := oEnvDetail:getOldData()
    Local oDialog 	    := nil
    Local oContainer    := nil
    Local oSay1		    := nil
    Local oSay2		    := nil
    Local oSay3		    := nil
    Local oSay4		    := nil
    Local oSay5		    := nil
    Local oSay6		    := nil
    Local oTFont
    Local bOk           := {||  nOpcao := 1, oDialog:End()  }
    Local bCancel       := {|| oDialog:End() }
    Local cUrl          := STR0146  //"https://tdn.totvs.com/pages/viewpage.action?pageId=828435185"
    Local cLink         := '<a href=' + STR0146 + '>'+I18n(STR0058)+'</a>'  //"https://tdn.totvs.com/pages/viewpage.action?pageId=828435185"    //"Extração de Artefatos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    Local bBlock        :=  {|| ShellExecute("open",cUrl,"","",1) }
    Local nOpcao        := 0 
    Local lContinua     := .T.
    Local cAmbJob       := GetPvProfString("RMIPUBLICA", "Environment", "undefined", GetAdv97())
   
    nStAba := oView:GetFolderActive("FOLDER", 2)[1]

    if IIF(ExistFunc("pshStResView"), nStAba > 1,.T.) .And. !oEnvDetail:isEmpty()
        if (Len(aDetail[2]) > 400)
            lContinua := MsgYesNo(I18n(STR0082, {Len(aDetail[2]), 400}), I18n(STR0058)) //"Seu resultado de pesquisa trouxe mais de #1 registros, deseja gerar para os primeiros #2?" //"Extração de Artefatos"  
        endif

        if lContinua
        oTFont := TFont():New('Courier new',,16,.T.)
        Define MsDialog oDialog TITLE I18n(STR0058) STYLE DS_MODALFRAME From 000,000 To 300, 400 OF oMainWnd PIXEL //"Extração de Artefatos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            oContainer := TPanel():New( ,,, oDialog, oTFont, .T., , CLR_BLACK,CLR_WHITE, 400, 500, ,.T. )
            @ 040,005 SAY oSay1 PROMPT STR0112 + cAmbJob                                 COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//"Atenção os serviços de integração estão configurados no ambiente: "
            @ 050,005 SAY oSay2 PROMPT STR0113 + GetEnvServer()                          COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//"E o ambiente que você está logado é : "
            @ 060,005 SAY oSay4 PROMPT STR0114                                           COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//"É indicado estar conectado no mesmo ambiente para a geração"
            @ 070,005 SAY oSay3 PROMPT STR0115                                           COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//"correta dos artefatos de logs.(console.log)"
            @ 080,005 SAY oSay3 PROMPT I18n(STR0118, {cValtoChar(nMaxSize/1000000)})     COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//Atenção: arquivos maiores que #1 Mega, não serão adicionados aos Artefatos." 
            @ 090,005 SAY oSay3 PROMPT STR0119                                           COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//Este parâmetro é definido na chave MAXSTRINGSIZE do arquivo ini da aplicação Protheus." 
            @ 110,005 SAY oSay5 PROMPT STR0059+CRLF+STR0060+CRLF+STR0061    SIZE 190,110 COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL//"Esta rotina tem a finalidade de gerar Artefatos para o Suporte" "Clique em Confirmar para prosseguir..." "Para mais informações acesse: "
            @ 130,005 SAY oSay6 PROMPT cLink                                             COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL  

            oSay6:bLClicked := {|| MsgRun( STR0076, "URL", bBlock ) }	//"Abrindo o link... Aguarde..."


        ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog, bOk , bCancel) CENTERED
        

        If nOpcao == 1
            LjGrvLog(I18n(STR0058),STR0061+" "+cUrl) //"Extração de Artefatos"  ""Para mais informações acesse: " "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            PSHcDtc()
        EndIf 
    
        else
            FWAlertInfo(I18n(STR0083), I18n(STR0058)) //"Revise os parâmetros para reduzir a quantidade de registros"  //"Extração de Artefatos"
        endif
        
    endif

Return 

/*/{Protheus.doc} PSHcDtc
    Rotina para geração dos Arquivos CTREE DTC
    @type  Static Function
    @author Samuel de Vincenzo
    @since 20/02/2024
    @version 12.1.2410
/*/
Static Function PSHcDtc()
    Local aTabelas := {"MIP","MHQ","MHL","MHR", "SL1", "SLX"}
    Local lRet := .T.
    Local nRet := 0
    Local cCaminho := "\autocom\psh\"
    Local aFiliais := {}

    if !ExistDir(cCaminho)

        nRet := makeDir(cCaminho)

        if nRet != 0
            FWAlertError(I18n(STR0066,{cCaminho}) + cValToChar( FError() ), STR0058 ) //"Artefatos -> Não foi possível criar o diretório #1. Erro: ","Extração de Artefatos"            
            lRet := .F.
        endIf
    endIf

    cCaminho := cCaminho + "artefatos\"
    if !ExistDir(cCaminho)

        nRet := makeDir(cCaminho)

            if nRet != 0
            FWAlertError(I18n(STR0066,{cCaminho}) + cValToChar( FError() ), STR0058 ) //"Artefatos -> Não foi possível criar o diretório #1. Erro: ","Extração de Artefatos"            
                lRet := .F.
        endIf
    endIf

    if lRet
            
        // Faz a criação dos aquivos CTREE DTC
        PSHCriaDTC(aTabelas)

        // Popula as tabelas CTREE
        PshPCtree(aTabelas,aFiliais)

        //Faz a geração do arquivo ZIP
        PSHZip(aFiliais)
    endif
Return

/*/{Protheus.doc} PSHCriaDTC
    Rotina que cria as tabelas na pasta designada
    @type  Static Function
    @author Samuel de Vincenzo
    @since 20/02/2024
    @version 12.1.2410
    @param aTab, Array, Array com as tabelas para geração
/*/
Static Function PSHCriaDTC(aTab as Array)
    Local aCampos      := {}
    Local aEstrut      := {}
    Local cCaminhoArq  := "\autocom\psh\artefatos\"
    Local cNomTab      := ""     
    Local cArquivo     := "" 
    Local cIndice      := ""
    Local cIndiceTab   := ""
    Local nAtual       := 0
    Local nX           := 0
    
    Default aTab       := {}

    if !Empty(aTab)

        for nX := 1 to Len(aTab)
            aCampos     := {}
            aEstrut     := {}
            cNomTab     := RetSqlName(aTab[nX])
            cArquivo    := cCaminhoArq+cNomTab+".dtc"
            cIndice     := cCaminhoArq+cNomTab
            aEstrut     := &(aTab[nX])->( DbStruct() )
            cIndiceTab  := &(aTab[nX])->(IndexKey(1) )
            
            for nAtual := 1 to Len(aEstrut)
                aAdd(aCampos, {;
                    aEstrut[nAtual][1],;
                    aEstrut[nAtual][2],;
                    aEstrut[nAtual][3],;
                    aEstrut[nAtual][4]; 
                })    
            next nAtual
       
            //Crio o DTC
            DBCreate(cArquivo, aCampos, "CTREECDX")
            dbUseArea( .T.,"CTREECDX",cArquivo,cNomTab,.F.,.F. )
            IndRegua( cNomTab, cIndice, cIndiceTab )
            dbClearIndex()
            dbSetIndex( cIndice + OrdBagExt() )
            &(cNomTab)->( dbCloseArea() )
            
            LjGrvLog(I18n(STR0058),I18n(STR0079, {cNomTab, cCaminhoArq})) //"" "Gerando o arquivo #1 no caminho #2  "

        next nX
         
    endif        
    
Return

/*/{Protheus.doc} PshRmvDir
    Rotina para remover Arquivos e Diretórios
    @type  Static Function
    @author Samuel de Vincenzo
    @since 23/02/2024
    @version 12.1.2410
    @param 	cDir	    Diretorio/subdiretorio a ser criado
    @param 	lElimArq	Se remove ou não as pastas dos Diretorio/subdiretorio
    @return lRet,       Retorna .T. ou .F. 
/*/
Static Function PshRmvDir(cDir, lCompleto, lElimArq)
    Local aLimpar   := {}
    Local cDirElim  := '\'
	Local cDirTrb   := cDir + IIf( SubStr( cDir, Len( cDir ), 1 ) <> '\', '\', '' )
	Local lRet      := .T.
    Local nI        := 0
	Local nPosBarra := 0

    Default lCompleto := .F.
    Default lElimArq  := .F.

    if lCompleto

        // Elimina toda a arvore do diretorio
		nPosBarra := RAt( '\', cDirTrb )

        if nPosBarra > 2
            cDirElim := SubStr( cDirTrb, 1, nPosBarra )

            if lIsDir( cDirElim )
                // Elimina arquivos do diretorio
                if lElimArq
                    aLimpar := Directory( cDirElim + '*.*', 'D' )

                    aSort(aLimpar, , , {|x, y| y[1]+y[1] < x[1]+x[1]})

                    for nI := 1 to Len(aLimpar)
                        if SubStr(aLimpar[nI][1], 1, 1 ) <> '.'
                            if aLimpar[nI][5] == 'D'
                                PshRmvDir( AllTrim( cDirElim + aLimpar[nI][1] ), lCompleto, lElimArq )
                            endif

                            FErase( cDirElim + aLimpar[nI][1] )
                        endif
                    next nI
                endif
                if !( lRet := DirRemove( cDirElim ) )
                endif
            endif
        endif    
    endif
    LjGrvLog(I18n(STR0058),I18n(STR0080, {cDirTrb})) //"Deletando os arquivos no caminho #1 "
Return lRet

/*
{Protheus.doc} PshPCtree
    Rotina para popular com os dados o arquivo cTree
    @type  Static Function
    @author Samuel de Vincenzo
    @since 23/02/2024
    @version 12.1.2410
    @param aTab, Array, Contem as tabelas que precisa ser populada
*/
Static Function PshPCtree(aTab as Array, aFiliais as Array)

    Local oModel       := FwModelActive()
    Local aModel       := buscaModel(/*oView*/)
    Local oEnvDetail   := oModel:getModel(aModel[3])
    Local aDetail      := oEnvDetail:getOldData()
    Local aEstrut      := {}
    Local cCaminhoArq  := "\autocom\psh\artefatos\"
    Local cArquivo     := ""
    Local cIndice      := ""
    Local cIndiceTab   := ""        
    Local cQry         := ""
    Local cWhere       := ""
    Local cTabela      := ""
    Local cUIDMIP      := PSHUUID(aDetail) //Recupero todos os UUID da MIP
    Local cNomTab      := ""
    Local nAtual       := 0
    Local nTotal       := 0
    Local nTab         := 0
    Local _nRecno      := 0
    Local nX           := 0

    Default aTab := {}

    if !Empty(aTab)

        for nX := 1 to Len(aTab)

            //Monto o nome da tabela
            aEstrut     := {}
            cNomTab     := RetSqlName(aTab[nX])
            cArquivo    := cCaminhoArq+cNomTab+".dtc"
            cIndice     := cCaminhoArq+cNomTab
            aEstrut     := &(aTab[nX])->( DbStruct() )
            cIndiceTab  := &(aTab[nX])->(IndexKey(1) )
            
            Do Case
                Case aTab[nX] == "MIP"
                    cWhere := "WHERE MIP_UIDORI IN " + FormatIn(cUIDMIP, ";")
                Case aTab[nX] == "MHL"
                    cWhere := "WHERE MHL_UIDORI IN " + FormatIn(cUIDMIP, ";")
                    cWhere += " OR MHL_UIDORI IN " + FormatIn(PSHUUID(aDetail, 2), ";")
                Case aTab[nX] == "MHQ"
                    cWhere := "WHERE MHQ_UUID IN " + FormatIn(cUIDMIP, ";")
                Case aTab[nX] == "MHR"
                    cWhere := "WHERE MHR_UIDMHQ IN " + FormatIn(cUIDMIP, ";") 
                Case aTab[nX] == "SL1"
                    cWhere := "WHERE L1_UMOV IN " + FormatIn(cUIDMIP, ";") 
                Case aTab[nX] == "SLX"
                    cWhere := "WHERE LX_UUID IN " + FormatIn(cUIDMIP, ";") 
            EndCase    

            cTabela := "QRYDAD"+aTab[nX]    
            cQry := "SELECT R_E_C_N_O_ as RECNO ,"+PrefixoCPO(aTab[nX])+"_FILIAL FROM "+ RetSqlName(aTab[nX]) + CRLF 
            
            cQry := cQry + cWhere
            
            PLSQuery(cQry, cTabela) 

            dbSelectArea(cTabela)
            
            Count to nTotal
            ProcRegua(nTotal)
            (cTabela)->(dbGoTop())
			//faço a abertura da tabela CTREE para incluir
            dbUseArea( .T.,"CTREECDX", cArquivo,cNomTab, .T., .F. )
            dbSelectArea(cNomTab)
            IndRegua( cNomTab, cIndice, cIndiceTab )
            dbClearIndex()
            
            while ! (cTabela)->(EoF())
                _nRecno := (cTabela)->RECNO
                If aTab[nX] == "MIP"                    
                    If aScan(aFiliais, {|x| x == (cTabela)->(&(PrefixoCPO(aTab[nX])+"_FILIAL"))}) == 0
                        AAdd(aFiliais, (cTabela)->(&(PrefixoCPO(aTab[nX])+"_FILIAL")))
                    EndIf                
                EndIf
                dbSelectArea(aTab[nX])
                &(aTab[nX])->(dbGoTo(_nRecno))
            
                nAtual ++
                IncProc(STR0074+aTab[nX]+'. Registro ' +cValToChar(nAtual)+ ' de ' + cValToChar(nTotal) +' ... ') //'Gravando Registro da Tabela '
                
                dbSelectArea(cNomTab)
                RecLock(cNomTab, .T.)

                    for nTab := 1 to Len(aEstrut)

                        if GetSx3Cache(aEstrut[nTab][1],"X3_TIPO") $ "C|M"
                            &((cNomTab)+"->"+GetSx3Cache(aEstrut[nTab][1],"X3_CAMPO")) := Alltrim(&((aTab[nX])+"->"+aEstrut[nTab][1]))
                        else
                            &((cNomTab)+"->"+GetSx3Cache(aEstrut[nTab][1],"X3_CAMPO")) := &((aTab[nX])+"->"+aEstrut[nTab][1])
                        endIf
                    next

                MsUnLock(cNomTab)
                nTab := 0
                &(cTabela)->(dbSkip())

                LjGrvLog(I18n(STR0058),I18n(STR0081, {cNomTab})) //"Gravando dados na tabela #1 "
            end

            &(aTab[nX])->(dbCloseArea())
            (cTabela)->(dbCloseArea())
            &(cNomTab)->(dbCloseArea())
            nAtual       := 0
            nTotal       := 0
        next
    endif
Return 

/*/{Protheus.doc} PSHUUID
    Rotina para ajustar os UUID da Tabela MIP
    @type  Static Function
    @author Samuel de Vincenzo
    @since 28/03/2024
    @version 12.1.2410
    @param aDetMIP, Array, Contém os dados da MIP apresentado em TELA
    @param nTipo, Numeric, Contém qual será a forma de geração dos registros, 1=Geral, 2=MHL
    @return cUUID, Character, Retorna a string com os dados dos UUID para busca
/*/
Static Function PSHUUID(aDetMIP as Array, nTipo) as character
    Local cUUID     := "" as character
    Local nLinha    := 0  as numeric
    Local nqtde     := Iif(Len(aDetMIP[2]) < 400 , Len(aDetMIP[2]), 400 )
    Local nPosIdOri := aScan(aDetMIP[1], {|x| x[2] == "MIP_UIDORI"} )
    Local nPosId    := aScan(aDetMIP[1], {|x| x[2] == "MIP_UUID"}   )

    Default nTipo := 1

    for nLinha := 1 to nqtde
        cUUID += Iif( nTipo == 1, aDetMIP[2][nLinha][nPosIdOri], aDetMIP[2][nLinha][nPosId] ) + ";" 
    next nLinha
    cUUID := SubString(cUUID,1,Len(cUUID)-1)

Return cUUID

/*/{Protheus.doc} PSHZip
    Rotina para geração do arquivo zip com os arquivos necessários 
    @type  Static Function
    @author Samuel de Vincenzo
    @since 20/02/2024
    @version 12.1.2410
/*/
Static Function PSHZip(aFiliais)
    Local aFiles := {}
    Local aFileF := {}
    Local aFontes := {"*.PRW","*.TLPP"}
    Local aFRet   := {}
    Local aLogL  := Directory(GetSrvProfString("ROOTPATH","")+"\autocom\logs\"+"*.txt", "A") 
    Local cDirR  := "\autocom\psh\artefatos\"
    Local cDIRLL := GetSrvProfString("ROOTPATH","")+"\autocom\logs\" 
    Local cCnsL  := substring (GetPvProfString("GENERAL", "ConsoleFile", "undefined", GetAdv97()) , 1, len(GetPvProfString("GENERAL", "ConsoleFile", "undefined", GetAdv97()) )-3)+"*"
    Local aCnsL  := Directory(cCnsL, "A") 
    Local cNomA  := "PSHArtefatos_"+dToS(Date())+"_"+StrTran(Time(),":","")+".zip"
    Local cDirUser := ""
    Local nRet
    Local nX  := 0   
    Local nF  := 0
    Local dDtlim := DaySum(dDataBase, -7)

    
    IncProc("Extraindo dados do Repositório...") //"Extraindo dados do Repositório..."
    //Busco os fontes PRW e TLPP
    for nF := 1 to Len(aFontes)
        aFRet := GetSrcArray(aFontes[nF]) // Busco a relação do fontes do RPO, suprimi o repsitorio de busca para trazer de todos (RPOPadrao, TLPP, CUSTOM)
        PSHSLog(cDirR, aFRet, SubStr(aFontes[nF],3,3), .T.)
    next

    ProcRegua(len(aLogL))
    IncProc("Buscando arquivos do LOGLOJA...")
    //Busco o arquivo do LOGLOJA
    //Verifico se arquivo é menor que o tamanho definido, se está dentro da data limite e se é de uma filial do resultado da busca no monitor.
    For nF:=1 to len(aLogL)
        iF aLogL[nF][3] >= dDtlim .And. aLogL[nF][2] < nMaxSize .And. (!("_" $ aLogL[nF][1]) .Or. aScan(aFiliais,{|x| x $ aLogL[nF][1]}) > 0 )
            CpyT2S( cDIRLL+aLogL[nF][1], cDirR,.T. )
        EndIF
    Next nF

    ProcRegua(0)
    //Busco o arquivo do Console.*
    IncProc("Buscando arquivo do console...")
    For nF := 1 to len(aCnsL)
        iF aCnsL[nF][3] >= dDtlim
            CpyT2S( substring(cCnsl,1,len(cCnsl)-len(aCnsL[nF][1])+2) + aCnsL[nF][1], cDirR,.T. )
        EndIF
    Next

    aFileF := Directory(cDirR+"*.*", "A")
    IncProc("Compactando arquivos...")
    for nX := 1 to Len(aFileF)
        iF aFileF[nX][2] < nMaxSize 
            aadd(aFiles, cDirR + aFileF[nX][1])
        Else 
            LjGrvLog(I18n(STR0117, {aFileF[nX][1],cValtoChar(nMaxSize/1000000)}))//"O arquivo #1 não será adicionado pois é maior que #2 Mega. Este parâmetro é definido na chave MAXSTRINGSIZE do arquivo ini da aplicação Protheus." 
        Endif
        
    next nX

    cDirUser := cGetFile("*.*", ( STR0071 ),,"C:\",.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_RETDIRECTORY ) //"Selecione Pasta para gração do arquivo ZIP "

    if !Empty(cDirUser)

        nRet := FZip(cDirR+cNomA, aFiles, cDirR)

        if nRet != 0
            FWAlertError(STR0063,STR0058) //"Não foi possível criar o arquivo zip." //"Extração de Artefatos"
        else

            CpyS2T(cDirR+cNomA, cDirUser)
            FWAlertSuccess(STR0064+ CRLF + STR0065+ AllTrim(cDirUser),STR0058) //"Arquivo zip criado com sucesso!" //"Arquivo gerado em: " //"Extração de Artefatos"
            LjGrvLog(I18n(STR0058),I18n(STR0064+ CRLF + STR0065+ AllTrim(cDirUser))) //"Extração de Artefatos" //"Arquivo zip criado com sucesso!" //"Arquivo gerado em: "  
        endif
    else
        FWAlertWarning(STR0075, STR0058) //"Geração de arquivo zip cancelado pelo operador." //"Extração de Artefatos"   
        LjGrvLog(I18n(STR0058),I18n(STR0075)) //"Extração de Artefatos" //"Arquivo zip criado com sucesso!" //"Arquivo gerado em: "  
    endif
        
    pshRmvDir(cDirR, .T., .T.)
Return

/*/{Protheus.doc} PSHSLog
    Rotina para gerar log
    @type  Static Function
    @author Samuel de Vincenzo
    @since 28/03/2024
    @version 12.1.2410
    @param cCaminho, Character, Caminho onde será salvo o log
    @param aDados, Array, Array com os dados a serem preenchidos no arquivo
    @param cTipo, Character, qual o tipo do Log 
    @param lFont, Logico, se o log é fonte ou não
/*/
Static Function PSHSLog(cCaminho as Character, aDados as Array, cTipo as Character, lFont)
    
    Local aLogRpo  := {}
    Local cFileNom := cCaminho+IIf(lFont, "lista_fontes_"+cTipo+"_"+dToS(Date())+StrTran(Time(),":")+".txt", cTipo)
    Local cTexto   := ""
    Local cQuebra  := "+=======================================================================+" + CRLF
    Local nD       := 0

    Default cCaminho := "\autocom\psh\artefatos\"
    Default aDados   := {}

    // Monto a Mensagem
    cTexto += "Data     - "+ dToC(dDataBase) + CRLF
    cTexto += "Hora     - "+ Time()          + CRLF
    cTexto += cQuebra
    
    for nD := 1 to Len(aDados)

    if lFont
        aLogRpo := GetAPOInfo(aDados[nD])
        cTexto += aLogRpo[1]+" - "+ DtoC(aLogRpo[4])+" - "+aLogRpo[5] + CRLF    
    else
        cTexto += aDados[nD][1] + CRLF    
    endif   
        
    next nD

    MemoWrite(cFileNom, cTexto)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStVlPro
Valida o campo PROCESSO

@return lRetorno, lógico, determina se as validações foram processadas corretamente. 

@author  Rafael Tenorio da Costa
@since   04/03/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStVlPro()

    Local lRetorno  := .T.
    Local cProcesso := M->PROCESSO

    If !empty(cProcesso)
        cStCnChave  := retProcesso(cProcesso, MHNF3)
        cStProcesso := cProcesso
    Else
    
        lRetorno    := .F.
        help("", 1, "PROCESSO", /*cNome*/, STR0049, 1,,,,,, .F., /*aSolucao*/)  //"Processo é de preenchimento obrigatório."
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStF3Chv
Consulta padrão utilizada pelo campo chave, apresenta mensagem caso não tenha sido carregada nenhuma consulta.

@return cStCnChave, caractere, define a consulta padrão atrelada ao processo

@author  Rafael Tenorio da Costa
@since   04/03/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStF3Chv()

    If cStCnChave <> Nil .and. empty(cStCnChave)
        help("", 1, "HELP", STR0050, STR0051, 1,,,,,, .F., {STR0052})  //"Consulta padrão"     //"Não foi informada uma consulta padrão para este processo."    //"Acesse a rotina de Processos e configure uma consulta para o processo."
    EndIf

Return cStCnChave

//-------------------------------------------------------------------
/*/{Protheus.doc} PshDetPesq
Verifica se encontra a chave pesquisada em alguma etapa da integração, caso no encontre apresenta tela explicando o motivo.

@author  Rafael Tenorio da Costa
@since   04/03/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function PshDetPesq()

    Local aArea     := GetArea()
    Local cTabela   := GetNextAlias()
    Local cSql      := ""
    Local cProtheus := PadR("PROTHEUS", TamSx3("MHP_CASSIN")[1])
    Local cMensagem := ""
    Local cFiltro   := ""
    Local cProcesso := AllTrim(cStProcesso)
    Local cDB       := AllTrim( TcGetDB() )    

    cSql := " SELECT "
    If cDB == "MSSQL" 
        cSql += " TOP 1 " 
    EndIf
    cSql += " MHQ_STATUS, ISNULL( MHR_STATUS, '') AS MHR_STATUS, ISNULL( CAST(MHL_ERROR AS VARCHAR(4000)), '') AS MHL_ERROR"
    cSql += " FROM " + RetSqlName("MHQ") + " MHQ LEFT JOIN " + RetSqlName("MHR") + " MHR"
    cSql +=     " ON MHQ_FILIAL = MHR_FILIAL AND MHQ_UUID = MHR_UIDMHQ AND MHR.D_E_L_E_T_ = ' '"
    cSql += " LEFT JOIN " + RetSqlName("MHL") + " MHL"
    cSql +=     " ON MHQ_FILIAL = MHL_FILIAL AND MHQ_UUID = MHL_UIDORI AND MHL.D_E_L_E_T_ = ' '"
    
    cSql += " WHERE MHQ.D_E_L_E_T_ = ' '"
    cSql +=     " AND MHQ_FILIAL = '" + xFilial("MHQ") + "'"
    cSql +=     " AND MHQ_ORIGEM = '" + cProtheus + "'"
    cSql +=     " AND MHQ_CPROCE = '" + cStProcesso + "'"
    cSql +=     " AND MHQ_DATGER >= '" + dToS(dDataBase - 30) + "' AND MHQ_DATGER <= '" + dToS(dDataBase) + "'"
    cSql +=     " AND ( MHQ_CHVUNI LIKE '%" + cStChave + "%' OR MHQ_UUID = '" + cStChave + "' )"
    
    If cDB == "ORACLE" 
        cSql += " AND ROWNUM <= 1 "
    EndIf
    
    cSql += " ORDER BY MHQ.R_E_C_N_O_ DESC "
    
    If cDB $ "POSTGRES|MYSQL"
        cSql += " LIMIT 1 "   
    EndIf

    dbUseArea(.T., "TOPCONN", TcGenQry( , , cSql), cTabela, .F., .T.)

    If  !(cTabela)->( Eof() )

        Do Case
            Case (cTabela)->MHQ_STATUS == "1" .or. (cTabela)->MHR_STATUS == "1"
                cMensagem := I18n(STR0053, {cProcesso})                                                         //"Aguarde, ainda não foi feito o envio, mas a integração do(a) #1 está em andamento."

            Case (cTabela)->MHQ_STATUS == "3" .or. (cTabela)->MHR_STATUS == "3"
                cMensagem :=  I18n(STR0054, {cProcesso, CRLF}) + AllTrim((cTabela)->MHL_ERROR)                   //"Existe uma falha na integração antes de efetuar o envio do(a) #1.#2#2Motivo: "

            Case (cTabela)->MHQ_STATUS <> "2" .or. (cTabela)->MHR_STATUS <> "2"
                cMensagem := I18n(STR0055, {(cTabela)->MHQ_STATUS, (cTabela)->MHR_STATUS, CRLF, cProcesso})     //"Foi encontrado um status incorreto (#1/#2) para a integração, provavelmente houve manipulação dos dados.#3#3Esta integração não irá prosseguir, altere novamente o dado origem para integrar o #4."
        End Case
    Else


        cFiltro := retProcesso(cStProcesso, MHNFILTRO)

        If !empty(cFiltro)
            cMensagem := I18n(STR0056, {cProcesso, CRLF, AllTrim(cFiltro)})                         //"Não foi encontrado nenhum vestígio de integração para o(a) #1.#2#2Verifique se o #1 atende as regras de filtro para a integração, regra: [#3]"
        EndIf
    EndIf

    (cTabela)->( dbCloseArea() )

    If !empty(cMensagem)
        LjExibeTexto(STR0057, cMensagem, .T./*lBotSalvar*/, 0.4/*nPercLarg*/, 0.5/*nPercAlt*/)      //"Detalhes da pesquisa"
    EndIf

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} retProcesso
Retorna dados do processo selecionado no filtro

@param cProcesso, caractere, define o processo que será retornado
@param nTipo, numérico, campo relacionado o processo que será retornado
@return variável, dado(s) do processo 

@author  Rafael Tenorio da Costa
@since   04/03/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function retProcesso(cProcesso, nTipo)

    Local xRetorno  := Nil

    Default nTipo := 0

    If nTipo == 0
        xRetorno := aClone( aStProcesso[ aScan(aStProcesso, {|x| x[MHNCOD] == cProcesso}) ] )
    Else
        xRetorno := aStProcesso[ aScan(aStProcesso, {|x| x[MHNCOD] == cProcesso}) ][nTipo]
    EndIf

Return xRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaModel()
Retorna nome do modelo de grid da aba que está ativa

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Static Function buscaModel(oView)

    Local nAba      := 0
    Local aModels   := {}

    Default oView   := fwViewActive()

	nAba := oView:GetFolderActive("FOLDER", 2)[1]

    If ExistFunc("pshStResView") .And. nAba == 1
        aAdd(aModels, "ENVMASTER")    
        aAdd(aModels, "ENVRESUMO")
        aAdd(aModels, "SERDETAIL")
	ElseIf nAba == IIf(ExistFunc("pshStResView"),2,1)
        aAdd(aModels, "ENVMASTER")
        aAdd(aModels, "ENVRESUMO")
        aAdd(aModels, "ENVDETAIL")

    ElseIf nAba == IIf(ExistFunc("pshStResView"),3,2)
        aAdd(aModels, "BUSMASTER")
        aAdd(aModels, "BUSRESUMO")
        aAdd(aModels, "BUSDETAIL")
	endIf

Return aModels

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtAba()
Retorna qual a aba selecionada

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtAba()
Return nStAba

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtFil()
Retorna a filial selecionada no filtro

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtFil()
Return cStFilial

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtPro()
Retorna o processo selecionada no filtro

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtPro()
Return cStProcesso

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtChv()
Retorna a chave selecionada no filtro

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtChv()
Return cStChave

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtDtP()
Retorna o tipo de data selecionado no filtro

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtDtP()
Return cStDataPor

//-------------------------------------------------------------------
/*/{Protheus.doc} pshStGtSta()
Retorna o status selecionado no filtro

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStGtSta()
Return cStStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} sqlUtcLocal()
Retorna query com o campo S_T_A_M_P_ alterado para o fuso UTC da maquina onde esta o banco de dados

@author     Rafael Tenorio da Costa
@since      04/07/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Static Function sqlUtcLocal(cBanco)

    Local cSql := ""

    cSql += IIF( cBanco == "MSSQL",  " SWITCHOFFSET( PR.S_T_A_M_P_, SUBSTRING(CAST(SYSDATETIMEOFFSET() AS VARCHAR(35)), 29, 6) )"   , "" )
    cSql += IIF( cBanco <> "MSSQL",  " PR.S_T_A_M_P_"                                                                               , "" )

return cSql
//-------------------------------------------------------------------
/*/{Protheus.doc} PshGetGrf()
Retorna variavel staticas

@author     Rafael Tenorio da Costa
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function PshGetGrf(xStatic)

Return &xStatic

//-------------------------------------------------------------------
/*/{Protheus.doc} PshSetGrf()
Retorna variavel staticas

@author     Evandro Pattaro
@since      15/05/2024
@version    12.1.2410
/*/
//-------------------------------------------------------------------
Function PshSetGrf(xStatic,xVal)
    &xStatic := xVal
Return &xStatic

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Funcao de tratamento para duplo clique no grid
@type  Static Function
@author Evandro Pattaro
@since 03/09/24
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oModel := FwModelActive()
    If cField == "MENSAGEM"
        LjExibeTexto(cField,oModel:GetModel("ENVDETAIL"):getValue(cField,nLineModel), .F./*lBotSalvar*/, 0.4/*nPercLarg*/, 0.5/*nPercAlt*/)
    EndIf
Return .T.


/*/{Protheus.doc} SetButtons(oGrid,cField,nLineGrid,nLineModel)
Funcao de tratamento para duplo clique no grid
@type  Static Function
@author Evandro Pattaro
@since 03/09/24
/*/
Static Function SetButtons(oPanel)

Local oSay1
Local oSay2
Local oButton1
Local oButton2

Default oPanel := NIL

// Ancoramos os objetos no oPanel passado
@ 000, 000 Say oSay1 Prompt I18n(STR0142,{cValToChar(nStart),cValToChar(nLimit),cValToChar(nStQtdTotal)}) Of oPanel Size 100, 012 Pixel //"Exibindo de #1 até #2 de #3 Registros"
@ 000, 000 Button oButton1 Prompt STR0143 Of oPanel Size 055, 012 Pixel //"Pagina anterior"
@ 000, 000 Button oButton2 Prompt STR0144 Of oPanel Size 055, 012 Pixel //"Proxima Pagina"
@ 000, 000 Say oSay2 Prompt I18n(STR0145,{cLimQry}) Of oPanel Size 300, 012 Pixel //"**Os resultados da pesquisa são limitados em até #1 registros"
oSay1:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton1:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton1:bAction := { || nPage-- ,lPag := .T.,PSHStaPsq(fwViewActive()) }
oButton2:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton2:bAction := { || nPage++ ,lPag := .T.,PSHStaPsq(fwViewActive()) }
oSay2:Align := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel


Return(Nil)

/*/{Protheus.doc} AtuQtdStat(cStatus,cSituacao)
Atualiza a quatidade dos registros em seus respectivos status
@type  Static Function
@author Evandro Pattaro
@since 03/09/24
/*/
Static Function AtuQtdStat(cStatus,cSituacao)

    If Alltrim(cSituacao) == "STAMP"
        nStQtdPed   += 1
    Else
        Do Case
            Case cStatus == "2" 

                nStQtdInt   += 1
            
            Case cStatus == "A" 
                nStQtdInAl  += 1
                
            Case cStatus $ "3|IR"
                nStQtdNoInt += 1

            Otherwise 
                nStQtdPed   += 1
        EndCase
    Endif

Return(Nil)

/*/{Protheus.doc} PSHLimitQry(cPonto)
Retorna o comando de limitação de registros na query conforme o SGBD do ambiente
@type  Static Function
@author Evandro Pattaro
@since 03/09/24
/*/
Function PSHLimitQry(cPonto)
Local cRet := ""
Local cBanco := upper( tcGetDb() )
Do Case
    Case cPonto == "SELECT" .And.cBanco $ "MSSQL" 
        cRet := " TOP "+PshGetGrf("cLimQry")+" " 
    Case cPonto == "WHERE" .And. cBanco $ "ORACLE"
        cRet := "AND ROWNUM <= "+PshGetGrf("cLimQry")+" "
    Case cPonto == "ORDER" .and. cBanco $ "MYSQL/POSTGRES"
        cRet := " LIMIT "+PshGetGrf("cLimQry")+" "
EndCase

Return(cRet)

Static function CompStamp(cStatus)
Local cQry := ""
Local cBanco := upper( tcGetDb() )
If cStatus == "STAMP"
    cQry := "CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) < CONVERT(datetime,"+sqlUtcLocal(cBanco)+") AND MIP_STATUS NOT IN ('3','A')"
ElseIf cStatus == "ULTOK"
    cQry := "CONVERT(datetime,REPLACE(IIF(LEN(MIP.MIP_ULTOK) = 8 OR LEN(MIP.MIP_ULTOK) = 0,NULL,MIP.MIP_ULTOK), '-', ' '),103) > CONVERT(datetime,"+sqlUtcLocal(cBanco)+") AND MIP_STATUS NOT IN ('3','A')"
EndIf

Return cQry
