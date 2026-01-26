#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PSHSTAINTE.CH"

Static nStart
Static nLimit
Static cStFonte := procSource()

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author  Rafael tenorio da Costa 
@since 	 12/04/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStBuWiew(oView)

	Local oStrBusca     := FWFormViewStruct():New()
    Local oStrResumo    := FWFormViewStruct():New()    
	Local oStrBuscaGrid := FWFormStruct(2/*nType*/, "MIP"/*cAliasSX2*/,/*bSX3*/, /*lViewUsado*/, /*lVirtual*/, .T./*lFilOnView*/, /*cProgram*/)
    Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}


    //Carrega campo do filtro
    camposFiltro(oStrBusca, .T.)

    //Carrega campo do Resumo
    camposResumo(oStrResumo, .T.)
    
    //Carrega campo do grid
    camposGrid(oStrBuscaGrid, .T.)

	//Aba de Buscas - Movimentações
	oView:AddField("BUSMASTER_VIEW" , oStrBusca     , "BUSMASTER")
    oView:AddField("BUSRESUMO_VIEW" , oStrResumo    , "BUSRESUMO")
	oView:AddGrid("BUSDETAIL_VIEW"  , oStrBuscaGrid , "BUSDETAIL")

    oView:SetViewProperty("BUSDETAIL_VIEW", "GRIDDOUBLECLICK", bDblClick)

	oView:AddSheet('FOLDER', 'ABA_F02', STR0091, {|| aDados := {}})    //"Vendas"
	oView:CreateHorizontalBox("BOX_F02_01", 35,,, "FOLDER", "ABA_F02")
    oView:CreateHorizontalBox("BOX_F02_03", 5,,,  "FOLDER", "ABA_F02")
	oView:CreateHorizontalBox("BOX_F02_02", 60,,, "FOLDER", "ABA_F02")

    oView:CreateVerticalBox('BOX_F02_01_ESC', 70, 'BOX_F02_01', ,"FOLDER", "ABA_F02")
    oView:CreateVerticalBox('BOX_F02_01_DIR', 30, 'BOX_F02_01', ,"FOLDER", "ABA_F02")
	
	oView:SetOwnerView("BUSMASTER_VIEW", "BOX_F02_01_ESC")
    oView:SetOwnerView("BUSRESUMO_VIEW", "BOX_F02_01_DIR")
	oView:SetOwnerView("BUSDETAIL_VIEW", "BOX_F02_02")

    oView:AddOtherObject("CTRL_PAGVEN", {|oPanel| SetButtons(oPanel)})
    oView:SetOwnerView("CTRL_PAGVEN", "BOX_F02_03")	

	oView:EnableTitleView("BUSMASTER_VIEW", STR0008)    //"Filtro"
    oView:SetViewProperty("BUSMASTER_VIEW", "SETLAYOUT"         , {FF_LAYOUT_VERT_DESCR_TOP, 4})
   
    oView:EnableTitleView("BUSRESUMO_VIEW", STR0009)    //"Resumo"
    oView:SetViewProperty("BUSRESUMO_VIEW", "SETLAYOUT"         , {FF_LAYOUT_HORZ_DESCR_TOP, 3})
    oView:SetViewProperty("BUSRESUMO_VIEW", "SETCOLUMNSEPARATOR", {10})   

    oView:EnableTitleView("BUSDETAIL_VIEW", STR0010)    //"Resultado"
    oView:SetNoInsertLine("BUSDETAIL_VIEW")
    oView:SetNoUpdateLine("BUSDETAIL_VIEW")
    oView:SetNoDeleteLine("BUSDETAIL_VIEW")
	oView:SetViewProperty("BUSDETAIL_VIEW", "GRIDVSCROLL", {.T.})
    //oView:SetViewProperty("BUSDETAIL_VIEW", "GRIDFILTER" , {.T.})     //Insere filtro no grid

    oView:AddIncrementField("BUSDETAIL_VIEW","ITEM") //Campo criado para numerar as linhas do grid
    
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author  Rafael tenorio da Costa 
@since 	 12/04/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStBuMod(oModel)

	Local oStrBusca      := FWFormModelStruct():New()
    Local oStrResumo     := FWFormModelStruct():New()
	Local oStrBuscaGrid  := FWFormStruct(1, "MIP")

    //Carrega campo do filtro
    camposFiltro(oStrBusca, .F.)

    //Carrega campo do Resumo
    camposResumo(oStrResumo, .F.)

    //Carrega campo do grid
    camposGrid(oStrBuscaGrid, .F.)

	//Aba Envio - Cadastros
    oModel:AddFields("BUSMASTER", "ENVMASTER"/*cOwner*/, oStrBusca, /*Pre-Validacao*/, /*Pos-Validacao*/, {|| })
	oModel:GetModel("BUSMASTER"):SetDescription(STR0008)    //"Filtro"

	oModel:AddFields("BUSRESUMO", "BUSMASTER", oStrResumo, /*Pre-Validacao*/, /*Pos-Validacao*/, {|| })
	oModel:GetModel("BUSRESUMO"):SetDescription(STR0009)    //"Resumo"

    oModel:AddGrid("BUSDETAIL", "BUSMASTER", oStrBuscaGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid, lCopia| selectBus(oGrid, lCopia)})
	oModel:GetModel("BUSDETAIL"):SetDescription(STR0010)    //"Resultado"
	oModel:GetModel("BUSDETAIL"):SetOnlyView(.T.)           //Define que nao permitira a alteração dos dados
    oModel:GetModel("BUSDETAIL"):SetUseOldGrid(.T.)         //Indica que o submodelo deve trabalhar com aCols/aHeader.
    
Return nil

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
    Local aProcessos    := {"VENDA"}//processos(cTipo)
    Local aStatus       := {"", STR0070, STR0012, STR0013}     //"1=Pendente       //"2=Integrado com sucesso"   //"3=Falha na integração" //"A=Integrado com alerta"         
    Local aDataPor      := {"", STR0093, STR0094}                       //"1=Integração"    //"2=Venda"

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
        "DATADE"                      , ; // [01] Campo
        cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
        STR0024                     , ; // [03] Titulo          //"Data de"
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
        STR0120                     , ; // [03] Titulo          //"Data até"
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
        STR0095                     , ; // [03] Titulo          //"Venda"
        STR0095                     , ; // [04] Descricao       //"Venda"
        {STR0096}                   , ; // [05] Help            //"Será utilizada no filtro dentro do campo Venda, pode ser o código da venda ou série por exemplo. Também pode ser o código UUID de alguma integração expecifica."
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        ''                          , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        //Pula linha
	    oStruct:SetProperty("FILIAL", MVC_VIEW_INSERTLINE, .T.)

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
        {|| "VENDA"}                                        , ; // [11] Bloco de código de inicialização do campo
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
        "DATAATE"        	                                    , ; // [03] Id do Field
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
        "QTDINAL"                   , ; // [01] Campo
        "02"                        , ; // [02] Ordem
        STR0097                     , ; // [03] Titulo          //"Integrados com alerta"
        STR0097                     , ; // [04] Descricao       //"Integrados com alerta"
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
        "03"                        , ; // [02] Ordem
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
        "04"                        , ; // [02] Ordem
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
        "05"                        , ; // [02] Ordem
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
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0097  	                , ; // [01] Titulo do campo         //"Integrados com alerta"
        STR0097     	            , ; // [02] ToolTip do campo        //"Integrados com alerta"
        "QTDINAL"                   , ; // [03] Id do Field
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
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:AddField(	;
        STR0043       	            , ; // [01] Titulo do campo         //"Pendentes"
        STR0043                     , ; // [02] ToolTip do campo        //"Pendentes"
        "QTDPED"                    , ; // [03] Id do Field
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
        .T.                         )   // [14] Indica se o campo é virtual.    


        oStruct:AddField(	;
        STR0044                     , ; // [01] Titulo do campo         //"Falha"
        STR0044                     , ; // [02] ToolTip do campo        //"Falha"
        "QTDNOINT"                  , ; // [03] Id do Field
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
        .T.                         )   // [14] Indica se o campo é virtual.    

        oStruct:AddField(	;
        STR0084                     , ; // [01] Titulo do campo         //"Total"
        STR0084                     , ; // [02] ToolTip do campo        //"Total"
        "QTDTOTAL"                  , ; // [03] Id do Field
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

    Local aStatus := {"1=" + STR0028, STR0029, STR0030, STR0092}   //"Pendente"     //"2=Integrado"     //"3=Falha na integração"       //"A=Integrado com alerta"
    Local aEvento := {"1=" + STR0095, STR0098, STR0099}             //"Venda"       //"2=Cancelamento"  //"3=Inutilização"
    Local aTam    := tamSx3("L1_VLRTOT")

    If lView

        oStruct:AddField( ;
        "ITEM"                      , ; // [01] Campo
        "00"                        , ; // [02] Ordem
        ""                          , ; // [03] Titulo          //"Data Alteração"
        ""                          , ; // [04] Descricao       //"Data Alteração"
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
        "L1_VLRTOT"                 , ; // [01] Campo
        "07"                        , ; // [02] Ordem
        STR0100                     , ; // [03] Titulo          //"Valor Total"
        STR0100                     , ; // [04] Descricao       //"Valor Total"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@E 99,999,999,999.99'      , ; // [07] Picture
                                    , ; // [08] PictVar
        ''                          , ; // [09] F3
                                    , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:AddField( ;
        "MENSAGEM"                  , ; // [01] Campo
        "11"                        , ; // [02] Ordem
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
        oStruct:RemoveField("MIP_LOTE")
        oStruct:RemoveField("MIP_UUID")
        oStruct:RemoveField("MIP_UIDORI")
        oStruct:RemoveField("MIP_IDRET")
        oStruct:RemoveField("MIP_PDV")
        oStruct:RemoveField("MIP_DATPRO")
        oStruct:RemoveField("MIP_HORPRO")
        oStruct:RemoveField("MIP_DTDADO")   //Este é um campo que retiramos do ATUSX, só esta aqui para não ser apresentado caso exista na base
        oStruct:RemoveField("MIP_UIDCON")

        oStruct:SetProperty("ITEM"      , MVC_VIEW_ORDEM    , "00")
        oStruct:SetProperty("LEGENDA"   , MVC_VIEW_ORDEM    , "01")
        oStruct:SetProperty("MIP_STATUS", MVC_VIEW_ORDEM    , "02")
        oStruct:SetProperty("MIP_FILIAL", MVC_VIEW_ORDEM    , "03")
        oStruct:SetProperty("NOMEFILIAL", MVC_VIEW_ORDEM    , "04")
        oStruct:SetProperty("MIP_CHVUNI", MVC_VIEW_ORDEM    , "05")
        oStruct:SetProperty("MIP_EVENTO", MVC_VIEW_ORDEM    , "06")
        oStruct:SetProperty("L1_VLRTOT" , MVC_VIEW_ORDEM    , "07")

        If MIP->(FieldPos("MIP_VALCON")) > 0 
            oStruct:SetProperty("MIP_VALCON", MVC_VIEW_ORDEM    , "08")
        EndIf
        
        oStruct:SetProperty("MIP_ULTOK" , MVC_VIEW_ORDEM    , "09")        
        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_ORDEM    , "10")
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_ORDEM    , "11")
        oStruct:SetProperty("MENSAGEM"  , MVC_VIEW_ORDEM    , "12")

        oStruct:SetProperty("MIP_STATUS", MVC_VIEW_COMBOBOX , aStatus)
        oStruct:SetProperty("MIP_EVENTO", MVC_VIEW_COMBOBOX , aEvento)

        oStruct:SetProperty("MIP_STATUS", MVC_VIEW_MAXTAMCMB, 20)
        oStruct:SetProperty("MIP_EVENTO", MVC_VIEW_MAXTAMCMB, 12)

        oStruct:SetProperty("NOMEFILIAL", MVC_VIEW_WIDTH    , 150)
        oStruct:SetProperty("MIP_CHVUNI", MVC_VIEW_WIDTH    , 120)
        oStruct:SetProperty("MIP_EVENTO", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("L1_VLRTOT" , MVC_VIEW_WIDTH    , 120)
        
        If MIP->(FieldPos("MIP_VALCON")) > 0
            oStruct:SetProperty("MIP_VALCON", MVC_VIEW_WIDTH    , 080)
        EndIf
        
        oStruct:SetProperty("MIP_ULTOK" , MVC_VIEW_WIDTH    , 080)        
        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_WIDTH    , 100)
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_WIDTH    , 100)

        oStruct:SetProperty("MIP_CHVUNI", MVC_VIEW_TITULO   , STR0095)      //"Venda"
        oStruct:SetProperty("MIP_EVENTO", MVC_VIEW_TITULO   , STR0101)      //"Tipo"
        oStruct:SetProperty("MIP_DATGER", MVC_VIEW_TITULO   , STR0102)      //"Data Integração"
        oStruct:SetProperty("MIP_HORGER", MVC_VIEW_TITULO   , STR0103)      //"Hora Integração"
        oStruct:SetProperty("MIP_ULTOK" , MVC_VIEW_TITULO   , STR0104)      //"Data\Hora Venda"
        oStruct:SetProperty("L1_VLRTOT" , MVC_VIEW_TITULO   , STR0148)      //"Valor Retaguarda"

        If MIP->(FieldPos("MIP_VALCON")) > 0
            oStruct:SetProperty("MIP_VALCON", MVC_VIEW_TITULO   , STR0149)      //"Valor Pdv"
        EndIf
        If MIP->(FieldPos("MIP_STCON")) > 0
            oStruct:SetProperty("MIP_STCON" , MVC_VIEW_TITULO   , STR0150)      //"Status Consolidação"
        EndIf

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
        {|| pshStLeg(MIP_STATUS) }  , ; // [11] Bloco de código de inicialização do campo
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
        STR0100  	                , ; // [01] Titulo do campo             //"Valor Total"
        STR0100      	            , ; // [02] ToolTip do campo            //"Valor Total"
        "L1_VLRTOT"                 , ; // [03] Id do Field
        "N"                         , ; // [04] Tipo do campo
        aTam[1]                     , ; // [05] Tamanho do campo
        aTam[2]                     , ; // [06] Decimal do campo
        	                        , ; // [07] Code-block de validação do campo
        	                        , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    )   // [11] Bloco de código de inicialização do campo

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
        "Msg Original"  	                , ; // [01] Titulo do campo             //"Mensagem"
        "Mensagem Original"                     , ; // [02] ToolTip do campo            //"Descrição do Erro"
        "MHQ_MSGORI"                  , ; // [03] Id do Field
        "M"                         , ; // [04] Tipo do campo
        10                         , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
                                    , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    )   // [11] Bloco de código de inicialização do campo

        oStruct:SetProperty("MIP_STATUS", MODEL_FIELD_VALUES, aStatus)
        oStruct:SetProperty("MIP_EVENTO", MODEL_FIELD_VALUES, aEvento)
    EndIf

    fwFreeArray(aTam)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} selectBus
Carrega dados do grid de resultado a cada active do modelo.

@param  oModel Modelo de dados ativo
@return aRet Dados que serão exibidos no grid de máscaras

@author  Rafael Tenorio da Costa
@since   01/11/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function selectBus(oGrid, lCopia)

    Local aArea     := GetArea()
    Local aAreaMIP  := MIP->( GetArea() )
    Local aGrid     := {}
    Local cTabela   := GetNextAlias()
    Local cSql      := ""
    Local cFil      := ""
    Local cProcesso := ""
    Local cChave    := ""
    Local dDataDe   := ""
    Local dDataAte  := ""
    Local cDataPor  := ""
    Local cStatus   := ""
    Local aTam      := tamSx3("L1_VLRTOT")
    Local oStrGrd   := oGrid:GetStruct()
    Local aFields   := {}
    Local nPosMHQ   := 0
    Local nCount	:= 0
    Local nX1       := 0    
    Local nI        := 0
    Local nMaxPag   := 100
    Local aDtSlct   := {}
    

    If FwIsInCallStack("PSHStaPsq") .And. pshStGtAba() == IIf(ExistFunc("pshStResView"),3,2)
        If !PshGetGrf("lPag")

            aDados := {}
            nPage := 1
            nStart := 1
            nLimit := nMaxPag

            aFields := aClone(oStrGrd:GetFields())
            nPosMHQ := aScan( aFields , { |x| x[MODEL_FIELD_IDFIELD] == "MHQ_MSGORI" }) 

            cFil      := pshStGtFil()
            cProcesso := pshStGtPro()
            cChave    := pshStGtChv()
            dDataDe   := PshGetGrf("dStDataDe")
            dDataAte  := PshGetGrf("dStDataAte")  
            cDataPor  := pshStGtDtP()
            cStatus   := pshStGtSta()

            PshSetGrf("nStQtdPed",0)
            PshSetGrf("nStQtdNoInt",0)
            PshSetGrf("nStQtdInt",0)
            PshSetGrf("nStQtdInAl",0)

            cSelect := " SELECT "+PSHLimitQry("SELECT")+" 0 AS ITEM,"
            cSelect += " MIP.*, ISNULL(MHQ.R_E_C_N_O_,0) MHQ_RECNO,"
            cSelect += " ISNULL( L1_VLRTOT, 0 ) AS L1_VLRTOT,"
            cSelect += " CASE "
            cSelect +=      " WHEN MIP_STATUS = 'A' OR ( MIP_STATUS = '2' AND ISNULL( MHL_STATUS, '' ) = 'AL' )"
            cSelect +=          " THEN CONCAT('" + STR0105 + "', ISNULL( CAST(MHL_ERROR AS VARCHAR(4000)), '') )"       //"Venda foi processada pelo Serviço de Venda (Gravabatch) e gerou os Livros Fiscais. Porém foi identificado divergência de valores fiscais calculados entre Protheus(MATXFIS) x PDV OMNI.  Entre em contato com o suporte técnico: "
            cSelect +=      " WHEN MIP_STATUS = '2' AND MIP_EVENTO = '1' "
            cSelect +=          " THEN '" + STR0106 + "'"                                                               //"Venda foi processada pelo Serviço de Venda (Gravabatch) e gerou os Livros Fiscais."
            cSelect +=      " WHEN MIP_STATUS = '2' AND MIP_EVENTO = '2' "
            cSelect +=          " THEN '" + STR0111 + "'"                                                               //"Cancelamento realizado com sucesso."
            cSelect +=      " WHEN MIP_STATUS = '3'"
            cSelect +=          " THEN CONCAT('" + STR0073 + "', ISNULL( CAST(MHL_ERROR AS VARCHAR(4000)), '') )"       //"Motivo: "

            //Neste ponto poderiamos alterar o MIP_STATUS no momento da gravação dos registros, para facilitar na query
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND MIP_EVENTO = '1' AND NOT EXISTS (SELECT '' FROM " + RetSqlName("SL1") + " L1 WHERE L1_FILIAL = MIP_FILIAL AND L1_UMOV = MIP_UIDORI AND L1.D_E_L_E_T_ = ' ')"
            cSelect +=          " THEN '" + STR0107 + "'"   //"Etapa 1/3 - Aguardando processamento dos serviços\jobs RMIBUSCA, RMIDISTRIB e RMIENVIA e a gravação das tabelas SL1\SL2\SL4."
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND MIP_EVENTO = '2' AND NOT EXISTS (SELECT '' FROM " + RetSqlName("SLX") + " LX WHERE LX_FILIAL = MIP_FILIAL AND LX_UUID = MIP_UIDORI AND LX.D_E_L_E_T_ = ' ')"
            cSelect +=          " THEN '" + STR0108 + "'"   //"Etapa 1/3 - Aguardando processamento dos serviços\jobs RMIBUSCA, RMIDISTRIB e RMIENVIA e a gravação da tabela SLX."
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND"
            cSelect +=          " ("
            cSelect +=              " EXISTS (SELECT '' FROM " + RetSqlName("SL1") + " L1 WHERE L1_FILIAL = MIP_FILIAL AND L1_SITUA = 'IP' AND L1_UMOV = MIP_UIDORI AND L1.D_E_L_E_T_ = ' ')"
            cSelect +=                  " OR"
            cSelect +=              " EXISTS (SELECT '' FROM " + RetSqlName("SLX") + " LX WHERE LX_FILIAL = MIP_FILIAL AND LX_SITUA = 'IP' AND LX_UUID = MIP_UIDORI AND LX.D_E_L_E_T_ = ' ')"
            cSelect +=          " )"
            cSelect +=          " THEN '" + STR0109 + "'"   //"Etapa 2/3 - Aguardando processamento do serviço\job RMICONTROL."
            cSelect +=      " WHEN MIP_STATUS IN ('1','6') AND"
            cSelect +=          " ("
            cSelect +=              " EXISTS (SELECT '' FROM " + RetSqlName("SL1") + " L1 WHERE L1_FILIAL = MIP_FILIAL AND L1_SITUA IN ('RX','PR') AND L1_UMOV = MIP_UIDORI AND L1.D_E_L_E_T_ = ' ')"
            cSelect +=                  " OR"
            cSelect +=              " EXISTS (SELECT '' FROM " + RetSqlName("SLX") + " LX WHERE LX_FILIAL = MIP_FILIAL AND LX_SITUA = 'RX' AND LX_UUID = MIP_UIDORI AND LX.D_E_L_E_T_ = ' ')"
            cSelect +=          " )"
            cSelect +=          " THEN '" + STR0110 + "'"   //"Etapa 3/3 - Aguardando processamento do serviço\job LJGRVBATCH."

            cSelect +=      " ELSE"
            cSelect +=          " ISNULL( CAST(MHL_ERROR AS VARCHAR(4000)), '')"
            cSelect += " END AS MENSAGEM "
        
            cFrom := " FROM " + RetSqlName("MIP") + " MIP"

            cFrom += " LEFT JOIN " + RetSqlName("MHL") + " MHL"
            cFrom +=    " ON MIP_UIDORI = MHL_UIDORI AND MIP_CHVUNI = MHL_CHAVE AND MHL.D_E_L_E_T_ = ' '"

            cFrom += " LEFT JOIN " + RetSqlName("MHQ") + " MHQ"
            cFrom +=    " ON MIP_UIDORI <> '" + space( tamSx3("MIP_UIDORI")[1] ) + "' AND MIP_UIDORI = MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"
    
            cFrom += " LEFT JOIN " + RetSqlName("SL1") + " SL1"
            cFrom +=    " ON MIP_FILIAL = L1_FILIAL AND L1_EMISSAO >= (MIP_DATGER - 15) AND MIP_UIDORI <> '" + space( tamSx3("MIP_UIDORI")[1] ) + "' AND MIP_UIDORI = L1_UMOV AND SL1.D_E_L_E_T_ = ' '"

            cWhere := " WHERE MIP.D_E_L_E_T_ = ' '"

            //Aplica filtros
            If !Empty(cFil)
                cWhere += " AND MIP_FILIAL = '" + cFil + "'"
            EndIf  

            If !Empty(cProcesso)
                cWhere += " AND MIP_CPROCE = '" + cProcesso + "'"
            EndIf

            If !Empty(cChave)
                cWhere += " AND ( MIP_CHVUNI LIKE '%" + cChave + "%' OR MIP_UUID = '" + cChave + "' OR MIP_UIDORI = '" + cChave + "' )"
            EndIf

            If !Empty(dDataDe) .and. !Empty(dDataAte)
                //1=Integração
                If cDataPor == "1"
                    cWhere += " AND (MIP_DATGER >= '" + dToS(dDataDe) + "'"
                    cWhere += " AND MIP_DATGER <= '" + dToS(dDataAte) + "')"
                //2=Venda
                Else
                    cWhere += " AND (SUBSTRING(MIP_ULTOK, 1, 10) >= '" + substr(dToC(dDataDe),1,6)+substr(dToC(dDataDe),9,2) + "'"
                    cWhere += " AND SUBSTRING(MIP_ULTOK, 1, 10) <= '" + substr(dToC(dDataAte),1,6)+substr(dToC(dDataAte),9,2) + "')"
                EndIf
            EndIf
            
            If !Empty(cStatus)

                //1=Pendente retorno
                If cStatus == "1"
                    cWhere += " AND MIP_STATUS IN ('1','6') "
                ElseIf cStatus == "2"
                    cWhere += " AND MIP_STATUS IN ('2','A') "
                Else
                    cWhere += " AND MIP_STATUS = '" + cStatus + "'"
                EndIf
            EndIf

            cWhere += PSHLimitQry("WHERE")

            cSql := cSelect + cFrom + cWhere

            cSql += " ORDER BY MIP.R_E_C_N_O_ DESC"

            cSql += PSHLimitQry("ORDER")

            cSql := ChangeQuery(cSql)

            ljGrvLog(cStFonte, "Query da rotina status de integração com as vendas:", cSql)

            dbUseArea(.T., "TOPCONN", TcGenQry( , , cSql), cTabela, .F., .T.)

            TcSetField(cTabela, "MIP_DATGER", "D", 8      , 0)
            TcSetField(cTabela, "MIP_DATPRO", "D", 8      , 0)
            TcSetField(cTabela, "L1_VLRTOT" , "N", aTam[1], aTam[2])

            aDtSlct := FwLoadByAlias(oGrid, cTabela)
            //aGrid := FwLoadByAlias(oGrid, cTabela)

            aDados := aClone(aDtSlct)
            PshSetGrf("nStQtdTotal",Len(aDtSlct))

            For nI := 1 To Len(aDtSlct)
                AtuQtdStat(aDtSlct[nI][2][10])
            Next

            (cTabela)->(DbGoTop())
        
            nCount := 1
            DBSelectArea("MHQ")
            // Atualiza o Campo Memo 
            While (cTabela)->(!Eof())
                
                If (cTabela)->MHQ_RECNO > 0 
                    MHQ->(dbGoTo((cTabela)->MHQ_RECNO))
                    aDtSlct[nCount][2][nPosMHQ] := MHQ->MHQ_MSGORI
                Else
                    aDtSlct[nCount][2][nPosMHQ] := ""
                EndIf
                (cTabela)->(dbSkip())
                nCount += 1
                
            EndDo        

            //limite de 100 itens por página
            If Len(aDtSlct) < nMaxPag
                nLimit := Len(aDtSlct)
            Else
                nLimit := nMaxPag
            EndIf

            For nI:= 1 to nLimit
                Aadd(aGrid,aDtSlct[nI])
            Next

            (cTabela)->( dbCloseArea() )
        Else //Controle de paginação
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

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Funcao de tratamento para duplo clique no grid
@type  Static Function
@author Evandro Pattaro
@since 03/09/24\p
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oModel := FwModelActive()
    If cField == "MENSAGEM"
        LjExibeTexto(cField,oModel:GetModel("BUSDETAIL"):getValue(cField,nLineModel), .F./*lBotSalvar*/, 0.4/*nPercLarg*/, 0.5/*nPercAlt*/)
    EndIf
Return .T.

/*/{Protheus.doc} AtuQtdStat(cStatus,cSituacao)
Atualiza a quatidade dos registros em seus respectivos status
@type  Static Function
@author Evandro Pattaro
@since 03/09/24
/*/
Static Function AtuQtdStat(cStatus)

    Do Case
        Case cStatus == "2" 
        
        PshSetGrf("nStQtdInt",PshGetGrf("nStQtdInt")+ 1)
        Case cStatus == "A" 
           
            PshSetGrf("nStQtdInAl",PshGetGrf("nStQtdInAl")+ 1)
        Case cStatus $ "3|IR"
            
            PshSetGrf("nStQtdNoInt",PshGetGrf("nStQtdNoInt")+ 1)
        Otherwise 
            
            PshSetGrf("nStQtdPed",PshGetGrf("nStQtdPed")+ 1)
    EndCase

Return(Nil)

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
@ 000, 000 Say oSay1 Prompt I18n(STR0142,{cValToChar(nStart),cValToChar(nLimit),cValToChar(PshGetGrf("nStQtdTotal"))}) Of oPanel Size 100, 012 Pixel //"Exibindo de #1 até #2 de #3 Registros"
@ 000, 000 Button oButton1 Prompt STR0143 Of oPanel Size 055, 012 Pixel //"Pagina anterior"
@ 000, 000 Button oButton2 Prompt STR0144 Of oPanel Size 055, 012 Pixel //"Proxima Pagina"
@ 000, 000 Say oSay2 Prompt I18n(STR0145,{PshGetGrf("cLimQry")}) Of oPanel Size 300, 012 Pixel //"**Os resultados da pesquisa são limitados em até #1 registros"
oSay1:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton1:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton1:bAction := { || nPage-- ,PshSetGrf("lPag",.T.) ,PSHStaPsq(fwViewActive()) }
oButton2:Align := CONTROL_ALIGN_LEFT // Alinhamento do botao referente ao panel
oButton2:bAction := { || nPage++ ,PshSetGrf("lPag",.T.),PSHStaPsq(fwViewActive()) }
oSay2:Align := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel

Return(Nil)

