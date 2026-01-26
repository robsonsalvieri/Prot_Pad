#INCLUDE "PROTHEUS.CH"
#INCLUDE "mata038.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} MATA038
    @description: Acompanha Custos
    @since 08/10/2020
    @version 12.1.33
*/
//-------------------------------------------------------------------
Function MATA038()
    Local llocaliza     := .F.
    Private oError      := JsonObject():New()
    Private oProfile    := FwProFile():New()
    Private lCheck      := .F.  
    Private oCheck1     := Nil
    

    //Valores gerais para tamanho de width e height
    Private nWidGen     := 380
    Private nHeiGen     := 20

    Private lWizardOk   := .T.

    VerifyInitApp(@oError,@llocaliza)

    If !ProfileOk(@oProfile) .Or. !EnvironOk()   // Ativa o Wizard
        lWizardOk := .F.
        WizardDlg()
    elseIf  llocaliza
        WizardDlg()
    ENDIF

    If lWizardOk
        FWCallApp( "MATA038" )
    Endif

    oProfile:Destroy()
    oProfile := nil

Return 

/*/{Protheus.doc} Page_01
    @description: Tela de introdução da rotina Acompanha Custos
    @author Pedro Missaglia
    @since 30/09/2022
    @version 12.1.33
/*/
Static Function SetPage(cPageNum, oNewPag, oStepWiz, oDlg, oPage)

//Variaveis de Controle de Actions
Local lNext_01 := .T.
Local lNext_02 := .F.
Local lNext_03 := .F.
Local lNext_04 := .F.
Local lNext_05 := .F.
 
oNewPag := oStepWiz:AddStep(cPageNum)

Do Case
    Case cPageNum == "1"
        oNewPag:SetStepDescription(STR0013)
        oNewPag:SetConstruction({|Panel| ViewPg_01(Panel, @oPage)})
        oNewPag:SetNextAction({|| lNext_01 })
    Case cPageNum == "2"
        oNewPag:SetStepDescription(STR0014)
        oNewPag:SetConstruction({|Panel| ViewPg_02(Panel, @oPage)})
        oNewPag:SetNextAction({|| lNext_02})
        oNewPag:SetPrevAction({|| .T.})
        oNewPag:SetPrevTitle(STR0015) 
        oNewPag:SetNextWhen({|Panel| PosView_02(Panel, @oPage, @lNext_02)})
        oNewPag:SetCancelWhen({||.T.})
    Case cPageNum == "3"    
        oNewPag:SetStepDescription(STR0016)
        oNewPag:SetConstruction({|Panel| ViewPg_03(Panel, @oPage)})
        oNewPag:SetNextAction({|| lNext_03 })
        oNewPag:SetNextWhen({|Panel| PosView_03(Panel, @oPage, @lNext_03)})
        oNewPag:SetPrevAction({|| .T.})
        oNewPag:SetPrevTitle(STR0015) 
        oNewPag:SetCancelWhen({||.T.})
    Case cPageNum == "4"
        oNewPag:SetStepDescription(STR0017)
        oNewPag:SetConstruction({|Panel| ViewPg_04(Panel,  @oPage)})
        oNewPag:SetNextAction({|| lNext_04})
        oNewPag:SetNextWhen({|Panel| PosView_04(Panel, @oPage, @lNext_04)})
        oNewPag:SetPrevAction({|| .T.})
        oNewPag:SetPrevTitle(STR0015) 
        oNewPag:SetCancelWhen({||.T.})
    Case cPageNum == "5"
        oNewPag:SetStepDescription(STR0086)//"Importante"
        oNewPag:SetConstruction({|Panel| ViewPg_05(Panel,  @oPage)})
        oNewPag:SetNextAction({|| lNext_05, HandleFinish(@oDlg)})
        oNewPag:SetNextWhen({|Panel| PosView_05(Panel, @oPage, @lNext_05)})
        oNewPag:SetPrevAction({|| .T.})
        oNewPag:SetPrevTitle(STR0015) 
        oNewPag:SetCancelWhen({||.T.})
EndCase

oNewPag:SetCancelAction({|| .T., oDlg:End()})

Return 

/*/{Protheus.doc} Page_01
    @description: Tela de introdução da rotina Acompanha Custos
    @author Pedro Missaglia
    @since 30/09/2022
    @version 12.1.33
/*/
Static Function HandleFinish(oDlg)

    oProfile:SetProfile({lCheck})
    oProfile:Save()
    
    oDlg:End()

    If EnvironOk()
        lWizardOk := .T.
    EndIf

Return ( Nil )


/*/{Protheus.doc} Page_01
    @description: Tela de introdução da rotina Acompanha Custos
    @author Pedro Missaglia
    @since 30/09/2022
    @version 12.1.33
/*/
Static Function ViewPg_01(oPanel, oPage)
    
    //"Bem vindo!"
    oPage["say"]["label_welcome_title"] := TSay():New( 10,10,{|| oPage["message"]["label_welcome_title"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"O Acompanha Custos é um painel moderno que irá concentrar todas as informações necessárias para o acompanhamento dos custos de seu estoque."
    oPage["say"]["label_onboarding_text_01"] := TSay():New( 30,10,{|| oPage["message"]["label_onboarding_text_01"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"As diversas informações disponibilizadas permitirão a análise da composição do custo dos produtos, sua evolução ao longo do tempo, bem como a criação de alertas para monitoramento dos custos de seus produtos mais relevantes e o acompanhamento de todo o processo de fechamento de estoque da empresa."
    oPage["say"]["label_onboarding_text_02"] := TSay():New( 50,10,{|| oPage["message"]["label_onboarding_text_02"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    
    //"Na primeira fase a ser disponibilizada durante o release 12.1.33, apresentamos a nova jornada de Fechamento de Estoque; através de uma interface única, totalmente focada na experiência do usuário, o cliente será conduzido durante seu fechamento de estoque de forma simples, intuitiva e sem a necessidade de realização de configurações ou execução de rotinas adicionais."
    oPage["say"]["label_onboarding_text_03"] := TSay():New( 80,10,{|| oPage["message"]["label_onboarding_text_03"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Para saber mais sobre a rotina, clique aqui." 
    oPage["say"]["label_onboarding_text_04"] := TSay():New(110,10,{|| oPage["message"]["label_onboarding_text_04"]},oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["say"]["label_onboarding_text_04"]:bLClicked := {|| MsgRun(STR0025, "URL",{|| ShellExecute("open",oPage["link"]["doc_acompanha_custos"],"","",1) } ) } // "Abrindo o link... Aguarde..."

    //"A seguir realizaremos algumas validações para verificar que se todos os requisitos necessários estão de acordo para a utilização da rotina."
    oPage["say"]["label_onboarding_text_05"] := TSay():New(130,10,{|| oPage["message"]["label_onboarding_text_05"]},oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Não mostrar novamente esta mensagem caso os requisitos sejam atendidos."
    oCheck1 := TCheckBox():New(220,10,STR0026, {|x|If(Pcount()==0,lCheck,lCheck:=x)},oPanel,nWidGen,nHeiGen,,,,,,,,.T.,,,) 

Return

/*/{Protheus.doc} Page_02
    @description: Tela de validação de chaves do appserver no ambiente
    @author Pedro Missaglia

    @since 30/09/2022
    @version 12.1.33
/*/
Static Function ViewPg_02(oPanel, oPage)
     
    //"Verificação de versão do ambiente:"
    oPage["say"]["label_release_title"] := TSay():New( 10,10,{|| oPage["message"]["label_release_title"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    
    //"Release 12.1.33 ou superior"
    oPage["svg"]["label_release_text"]   := TSVG():New(30, 10,oPanel,20,20,SvgWait())
    oPage["css"]["standard_svg"] := FWCSSVerify( GetClassName(oPage["svg"]["label_release_text"]  ), "QWidget", "QWidget{border: none; background: transparent;}" )
    oPage["svg"]["label_release_text"]  :SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_release_text"]  :LoadSVG( SvgWait() ) 
    oPage["say"]["label_release_text"] := TSay():New( 30,20,{|| oPage["message"]["label_release_text"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Verificação de chaves de configuração no arquivo appserver.ini do ambiente:"
    oPage["say"]["label_key_title"] := TSay():New( 50,10,{|| oPage["message"]["label_key_title"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Seção Drivers:"
    oPage["say"]["label_key_driver"]:= TSay():New( 60,10,{|| oPage["message"]["label_key_driver"] },oPanel,,,,,,.T.,,,420,40,,,,,,.T.)
    //"Chave APP_ENVIRONMENT"
    oPage["svg"]["label_key_text_app_environment"] := TSVG():New(70, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_key_text_app_environment"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_key_text_app_environment"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_key_text_app_environment"] := TSay():New(70,20,{|| oPage["message"]["label_key_text_app_environment"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Seção General:"
    oPage["say"]["label_key_general"]:= TSay():New( 80,10,{|| oPage["message"]["label_key_general"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    //"Chave MULTIPROTOCOLPORT"
    oPage["svg"]["label_key_text_multiprotocolport"] := TSVG():New(90, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_key_text_multiprotocolport"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_key_text_multiprotocolport"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_key_text_multiprotocolport"] := TSay():New(90,20,{|| oPage["message"]["label_key_text_multiprotocolport"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    
    //"Atenção: Secoes"
    oPage["say"]["label_key_text_sections"] := TSay():New( 100,10,{|| oPage["message"]["label_key_text_sections"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Chave LOGPROFILER ativa e CONSOLEMAXSIZE diferente de 10485760"
    oPage["svg"]["label_key_text_logprofiler"] := TSVG():New( 120, 10,oPanel,20,20,"<svg> </svg>")
    oPage["svg"]["label_key_text_logprofiler"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_key_text_logprofiler"]:LoadSVG( "<svg> </svg>" ) 
    oPage["say"]["label_key_text_logprofiler"] := TSay():New( 120,20,{|| "" },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Instalação da Procedure 19 - SB2 ou TR2"
    oPage["svg"]["label_routine_text_STOREDPROCEDURE19"] := TSVG():New(130, 10,oPanel,20,20, "<svg> </svg>" )
    oPage["svg"]["label_routine_text_STOREDPROCEDURE19"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_STOREDPROCEDURE19"]:LoadSVG(  "<svg> </svg>" ) 
    oPage["say"]["label_routine_text_STOREDPROCEDURE19"] := TSay():New( 130,20,{|| oPage["message"]["label_routine_text_STOREDPROCEDURE19"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Foi verificado que uma ou mais pré-condições do ambiente não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
    oPage["font"]["bold"] := TFont():New('Arial',,14,.T.,.T.)
    oPage["say"]["warning_general"] := TSay():New( 150,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Para maiores informações sobre a release necessária, clique aqui."
    oPage["say"]["warning_release"] := TSay():New(170,10,{|| ""},oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Para maiores informações sobre a configuração da chave app_environment, clique aqui."
    //"Para maiores informações sobre a configuração da chave multiprotocolport, clique aqui."
    oPage["say"]["warning_key_app_environment"] := TSay():New(180,10,{|| ""},oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["say"]["warning_key_multiprotocolport"] := TSay():New(190,10,{|| ""},oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)


    oPage["say"]["warning_key_logprofiler"] := TSay():New(210,10,{|| ""},oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
   
Return ( Nil )

/*/{Protheus.doc} Page_03
    @description: Tela de validação do dicionário de dados
    @author Pedro Missaglia
    @since 30/09/2022
    @version 12.1.33
/*/
Static Function ViewPg_03(oPanel, oPage)
     
    //"Verificação de tabelas necessárias para a utilização da rotina no dicionário de dados:"
    oPage["say"]["label_table_title"]   := TSay():New( 10,10,{|| oPage["message"]["label_table_title"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Tabela de logs de fechamentos - D3X"
    oPage["svg"]["label_table_text_d3x"] := TSVG():New(30, 10,oPanel,20,20,SvgWait())
    oPage["css"]["standard_svg"] := FWCSSVerify( GetClassName(oPage["svg"]["label_table_text_d3x"]), "QWidget", "QWidget{border: none; background: transparent;}" )
    oPage["svg"]["label_table_text_d3x"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_table_text_d3x"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_table_text_d3x"] := TSay():New( 30,20,{|| oPage["message"]["label_table_text_d3x"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Tabela de fechamentos realizados - D3Y"
    oPage["svg"]["label_table_text_d3y"] := TSVG():New(40, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_table_text_d3y"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_table_text_d3y"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_table_text_d3y"] := TSay():New( 40,20,{|| oPage["message"]["label_table_text_d3y"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Tabela de controle transacional de processamentos - D3W"
    oPage["svg"]["label_table_text_d3w"] := TSVG():New(50, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_table_text_d3w"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_table_text_d3w"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_table_text_d3w"] := TSay():New( 50,20,{|| oPage["message"]["label_table_text_d3w"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Verificação dos parâmetros de sistema necessários para a utilização da rotina no dicionário de dados:"
    oPage["say"]["label_parameter_title"] := TSay():New( 70,10,{|| oPage["message"]["label_parameter_title"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    
    //"Parâmetro MV_CUSTEXC como não exclusivo"
    oPage["svg"]["label_parameter_text_mv_custexc"] := TSVG():New(90, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_parameter_text_mv_custexc"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_parameter_text_mv_custexc"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_parameter_text_mv_custexc"] := TSay():New( 90,20,{|| oPage["message"]["label_parameter_text_mv_custexc"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Verificação de campos faltantes ou divergentes"
    oPage["say"]["label_dictionary_title"] := TSay():New( 110,10,{|| "" },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento"
    oPage["svg"]["label_dictionary_text_decimal"] := TSVG():New(130, 10,oPanel,20,20,"<svg> </svg>")
    oPage["svg"]["label_dictionary_text_decimal"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_dictionary_text_decimal"]:LoadSVG( "<svg> </svg>" ) 
    oPage["say"]["label_dictionary_text_decimal"] := TSay():New( 130,20,{|| "" },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    oPage["btnbmp"]["tooltip_decimal"] := TBtnBmp2():New( 255,490,26,26,'',,,,{|| },oPanel,,,.T. )

    //"Custo em partes não será considerado pois um ou mais campos não foram criados"
    oPage["svg"]["label_dictionary_text_cost_parts"] := TSVG():New(140, 10,oPanel,20,20,"<svg> </svg>")
    oPage["svg"]["label_dictionary_text_cost_parts"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_dictionary_text_cost_parts"]:LoadSVG( "<svg> </svg>" ) 
    oPage["say"]["label_dictionary_text_cost_parts"] := TSay():New( 140,20,{|| "" },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["btnbmp"]["tooltip_cost_parts"] := TBtnBmp2():New( 275,490,26,26,'',,,,{|| },oPanel,,,.T. )

    //"Custo de reposição não será considerado pois um ou mais campos não foram criados"
    oPage["svg"]["label_dictionary_text_cost_reposition"] := TSVG():New(150, 10,oPanel,20,20, "<svg> </svg>")
    oPage["svg"]["label_dictionary_text_cost_reposition"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_dictionary_text_cost_reposition"]:LoadSVG( "<svg> </svg>" ) 
    oPage["say"]["label_dictionary_text_cost_reposition"] := TSay():New( 150,20,{|| "" },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["btnbmp"]["tooltip_cost_reposition"] := TBtnBmp2():New( 295,490,26,26,'',,,,{|| },oPanel,,,.T. )

    //"Foi verificado que uma ou mais pré-condições do dicionário de dados não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
    oPage["font"]["bold"] := TFont():New('Arial',,14,.T.,.T.)
    oPage["say"]["warning_general"] := TSay():New( 200,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Recomendamos a aplicação da última expedição contínua disponível para a atualização dessas tabelas no dicionário de dados."
    oPage["say"]["warning_table"] := TSay():New( 220,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)  

 
Return ( Nil )

/*/{Protheus.doc} Page_04
    @description: Tela de validação dos fontes no RPO
    @author Pedro Missaglia
    @since 30/09/2022
    @version 12.1.33
/*/
Static Function ViewPg_04(oPanel, oPage)
    //"Verificação de versionamento de fontes necessários para a utilização da rotina no RPO:"
    oPage["say"]["label_routines_title_version"] := TSay():New( 10,10,{|| oPage["message"]["label_routines_title_version"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina do recálculo do custo médio - MATA330"
    oPage["svg"]["label_routine_text_MATA330"] := TSVG():New(30, 10,oPanel,20,20,SvgWait())
    oPage["css"]["standard_svg"] := FWCSSVerify( GetClassName(oPage["svg"]["label_routine_text_MATA330"]), "QWidget", "QWidget{border: none; background: transparent;}" )
    oPage["svg"]["label_routine_text_MATA330"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_MATA330"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_MATA330"] := TSay():New( 30,20,{|| oPage["message"]["label_routine_text_MATA330"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina da contabilização do recálculo do custo médio - MATA331"
    oPage["svg"]["label_routine_text_MATA331"] := TSVG():New(40, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_MATA331"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_MATA331"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_MATA331"] := TSay():New( 40,20,{|| oPage["message"]["label_routine_text_MATA331"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina de virada dos saldos - MATA280"
    oPage["svg"]["label_routine_text_MATA280"] := TSVG():New(50, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_MATA280"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_MATA280"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_MATA280"] := TSay():New( 50,20,{|| oPage["message"]["label_routine_text_MATA280"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina de saldo atual para final - MATA350"
    oPage["svg"]["label_routine_text_MATA350"] := TSVG():New(60, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_MATA350"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_MATA350"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_MATA350"] := TSay():New( 60,20,{|| oPage["message"]["label_routine_text_MATA350"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina de contabilização através de job via recálculo do custo médio - M330JCTB"
    oPage["svg"]["label_routine_text_M330JCTB"] := TSVG():New(70, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_M330JCTB"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_M330JCTB"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_M330JCTB"] := TSay():New( 70,20,{|| oPage["message"]["label_routine_text_M330JCTB"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Rotina de reprocessamento de saldo contábeis  - CTBA190"
    oPage["svg"]["label_routine_text_CTBA190"] := TSVG():New(80, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_CTBA190"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_CTBA190"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_CTBA190"] := TSay():New( 80,20,{|| oPage["message"]["label_routine_text_CTBA190"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    
    //"Rotina de classe de logs - ACJOURNEYLOG"
    oPage["svg"]["label_routine_text_ACJOURNEYLOG"] := TSVG():New(90, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACJOURNEYLOG"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACJOURNEYLOG"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACJOURNEYLOG"] := TSay():New( 90,20,{|| oPage["message"]["label_routine_text_ACJOURNEYLOG"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de serviço do recálculo do custo médio - MATA330"
    oPage["svg"]["label_routine_text_ACCALCSERVICE"] := TSVG():New(100, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACCALCSERVICE"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACCALCSERVICE"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACCALCSERVICE"] := TSay():New( 100,20,{|| oPage["message"]["label_routine_text_ACCALCSERVICE"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de repositório do recálculo do custo médio - MATA330"
    oPage["svg"]["label_routine_text_ACCALCREPOSITORY"] := TSVG():New(110, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACCALCREPOSITORY"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACCALCREPOSITORY"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACCALCREPOSITORY"] := TSay():New( 110,20,{|| oPage["message"]["label_routine_text_ACCALCREPOSITORY"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de serviço da contabilização do recálculo do custo médio - MATA331"
    oPage["svg"]["label_routine_text_ACCONTABSERVICE"] := TSVG():New(120, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACCONTABSERVICE"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACCONTABSERVICE"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACCONTABSERVICE"] := TSay():New( 120,20,{|| oPage["message"]["label_routine_text_ACCONTABSERVICE"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de repositório da contabilização do recálculo do custo médio - MATA331"
    oPage["svg"]["label_routine_text_ACCONTABREPOSITORY"] := TSVG():New(130, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACCONTABREPOSITORY"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACCONTABREPOSITORY"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACCONTABREPOSITORY"] := TSay():New( 130,20,{|| oPage["message"]["label_routine_text_ACCONTABREPOSITORY"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de serviço de saldo atual para final - MATA350"
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGSERVICE"] := TSVG():New(140, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGSERVICE"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGSERVICE"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACBALANCECLOSINGSERVICE"] := TSay():New( 140,20,{|| oPage["message"]["label_routine_text_ACBALANCECLOSINGSERVICE"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de repositório de saldo atual para final - MATA350"
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGREPOSITORY"] := TSVG():New(150, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGREPOSITORY"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACBALANCECLOSINGREPOSITORY"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACBALANCECLOSINGREPOSITORY"] := TSay():New( 150,20,{|| oPage["message"]["label_routine_text_ACBALANCECLOSINGREPOSITORY"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de serviço de virada dos saldos - MATA280"
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGSERVICE"] := TSVG():New(160, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGSERVICE"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGSERVICE"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACSTOCKCLOSINGSERVICE"] := TSay():New( 160,20,{|| oPage["message"]["label_routine_text_ACSTOCKCLOSINGSERVICE"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Classe de repositório de virada dos saldos - MATA280"
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGREPOSITORY"] := TSVG():New(170, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGREPOSITORY"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_routine_text_ACSTOCKCLOSINGREPOSITORY"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_routine_text_ACSTOCKCLOSINGREPOSITORY"] := TSay():New( 170,20,{|| oPage["message"]["label_routine_text_ACSTOCKCLOSINGREPOSITORY"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Foi verificado que uma ou mais pré-condições de versionamento dos fontes não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
    oPage["font"]["bold"] := TFont():New('Arial',,14,.T.,.T.)
    oPage["say"]["warning_general"] := TSay():New( 200,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    //"Recomendamos a aplicação da última expedição contínua disponível para a atualização desses fontes no RPO."
    oPage["say"]["warning_routines_version"] := TSay():New( 220,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)    

Return ( Nil )


/*/{Protheus.doc} ViewPg_05
    @description: Tela de validação de lançamento contabil
    @author Andre Maximo
    @since 20/09/2023
    @version 12.1.33
/*/
Static Function ViewPg_05(oPanel, oPage)
    //"Verificação de lancamento padronizado"
    oPage["say"]["label_welcome_title"] := TSay():New( 10,10,{|| oPage["message"]['label_welcome_title'] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    //"texto explicativo "
    oPage["svg"]["label_key_text_sections1"] := TSVG():New(30, 10,oPanel,20,20,SvgWait())
    oPage["svg"]["label_key_text_sections1"]:SetCSS( oPage["css"]["standard_svg"] )
    oPage["svg"]["label_key_text_sections1"]:LoadSVG( SvgWait() ) 
    oPage["say"]["label_key_text_sections1"] := TSay():New( 30,20,{|| oPage["message"]["label_key_text_sections1"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["say"]["label_key_text_sections2"] := TSay():New( 43,20,{|| oPage["message"]["label_key_text_sections2"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    oPage["say"]["label_welcome_subtitle"] := TSay():New( 70,10,{|| oPage["message"]['label_welcome_subtitle'] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)

    oPage["say"]["label_key_text_sections3"] := TSay():New( 80,20,{|| oPage["message"]["label_key_text_sections3"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["say"]["label_key_text_sections4"] := TSay():New( 98,20,{|| oPage["message"]["label_key_text_sections4"] },oPanel,,,,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)
    oPage["font"]["bold"] := TFont():New('Arial',,14,.T.,.T.)
    //"Informativo que existe o lançamento configurado no ambiente"
    oPage["say"]["warning_no_exist_lanc"] := TSay():New( 220,10,{|| "" },oPanel,,oPage["font"]["bold"],,,,.T.,,,nWidGen,nHeiGen,,,,,,.T.)    

Return ( Nil )


//------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
Bloco de codigo que recebera as chamadas JavaScript
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel,cType,cContent)

    Local cObjSX6           := ResolvSx6()
    Local lAccess           := AccessReop()
    Local lAccessClog       := AccessClos()
    Local lEnvRussia        := CheckEnvRu()
    Local cPictFormat       := CheckPicFo()
    Local cJAccessReo 
    Local cJsonEnvRus
    Local cJsonPicFor
    Local aContent
    Local nX

    Do Case

        Case cType == "preLoad"
            cJsonCompany:= '{"Code":"'+cEmpAnt+'","InternalId":"'+cEmpAnt+'","CorporateName":"'+FWGrpName(cEmpAnt)+'"}'
            cJsonBranch := '{"CompanyCode":"'+cEmpAnt+'","EnterpriseGroup":"'+cEmpAnt+'","ParentCode":"'+cFilAnt+'","Code":"'+cFilAnt+'","Description":"'+encodeUTF8(FWFilialName())+'","Cgc":"'+FWArrFilAtu()[18]+'"}'
            cJsonParams := cObjSX6
            cJAccessReo := '{"reopeningAccess":"'+cvaltochar(lAccess)+'", "closingAccess":"'+cvaltochar(lAccessClog)+'"}'
            cJsonEnvRus := '{"environmentRu":"' + cValToChar(lEnvRussia) + '"}'
            cJsonPicFor := '{"numberFormat":"' + cPictFormat + '"}'
            oWebChannel:AdvPLToJS('setParams',      cJsonParams)
            oWebChannel:AdvPLToJS('setCompany',     cJsonCompany)
            oWebChannel:AdvPLToJS('setBranch',      cJsonBranch)
            oWebChannel:AdvPLToJS('setAccess',      cJAccessReo)
            oWebChannel:AdvPLToJS('setEnvRus',      cJsonEnvRus)
            oWebChannel:AdvPLToJS('setPictForm',    cJsonPicFor)
        Case cType == 'accountingEntries'
            If FindFunction('CTB102POUI')

                aContent := StrTokArr2(cContent, "|")

                cIdProcess := aContent[1]  // CT2_PROCES - Id de processamento
                cIncons    := "1"          // CT2_INCONS - 1 = Abre tela se encontrar lancamentos inconsistentes
                                           //              2 = Abre tela se encontrar lancamentos consistentes
                                           //              " "=Abre tela sempre
                                           //              OBS: todos os lancamentos do mesmo documento serao mostrados na tela, consistentes e inconsistentes
                nOpc       := 4            // 2=Visualizar; 4=Alterar

                For nX := 2 To Len(aContent)

                    cBranch    := aContent[nX]  // CT2_FILIAL - Filial para filtragem dos lancamentos

                    CTB102POUI(cBranch, cIdProcess, cIncons, nOpc)

                Next nX

            EndIf

            oWebChannel:AdvplToJs(cType, 'finished')

    EndCase

Return

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function ResolvSx6()

    Local cResponse := " " 
    Local aSX6      := {}
    Local nI    
    Local oParams	:= getParams()
    Local oJConfig  := JsonObject():New()

    For nI := 1 to Len(oParams['items'])
        aAdd( aSX6,  JsonObject():New() )

        aSX6[nI]["label"]:= oParams['items'][nI]['label']
        aSX6[nI]["value"]:= Iif(Empty(oParams['items'][nI]['value']), oParams['items'][nI]['default'], oParams['items'][nI]['value'])

    Next nI

    oJConfig["params"] := aSX6
    cResponse := oJConfig:toJson() 

    oParams := NIL

Return cResponse

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function getParams()

    Local oSX6      as Object
    Local aParams   as Array
    Local aItems    as Array
    Local nX        as Numeric

    aParams   := {}
    aItems    := {}
    nX        := 0

    //[1] - Parametro de sistema a ser adicionado via WebChannel 
    //[2] - Conteudo default a ser utilizado caso seja retornado vazio
    Aadd(aParams, {'MV_CUSFIL'  , 'A'})
    Aadd(aParams, {'MV_CUSMED'  , 'M'})
    Aadd(aParams, {'MV_CUSTEXC' , 'N'})
    Aadd(aParams, {'MV_M330THR' , 1})
    Aadd(aParams, {'MV_MOEDACM' , '2345'})
    Aadd(aParams, {'MV_PRODPR0' , 1})
    Aadd(aParams, {'MV_SIMB1'   , ''})
    Aadd(aParams, {'MV_SIMB2'   , ''})
    Aadd(aParams, {'MV_SIMB3'   , ''})
    Aadd(aParams, {'MV_SIMB4'   , ''})
    Aadd(aParams, {'MV_SIMB5'   , ''})
    Aadd(aParams, {'MV_SIMB6'   , ''})
    Aadd(aParams, {'MV_SIMB7'   , ''})
    Aadd(aParams, {'MV_THRSEQ'  , .F.})
    Aadd(aParams, {'MV_ULMES'   , StoD('19970101')})
    Aadd(aParams, {'MV_A330SB2' , .F.})

    oSX6 := JsonObject():New()

    oSX6['items'] := aItems

    For nX := 1 to Len(aParams)

        Aadd(aItems, JsonObject():New())

        aItems[nX]['label']     := aParams[nX][1]
        aItems[nX]['value']     := SuperGetMv(aParams[nX][1], .F., aParams[nX][2])
        aItems[nX]['default']   := aParams[nX][2]

    Next nX

Return oSX6

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

Function getLegacy() 
    Local nVersion := 104
return nVersion

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

Function getRoutine(cRoutine)

    Local nVersion := 0

    IF (cRoutine == 'MATA330')
        nVersion := A330Legacy()
    ELSEIF (cRoutine == 'MATA331')
        nVersion := A331Legacy()
    ELSEIF (cRoutine == 'MATA280')
        nVersion := A280Legacy()
    ELSEIF (cRoutine == 'MATA350')
        nVersion := A350Legacy()  
    ELSEIF (cRoutine == 'M330JCTB')
        nVersion := A330CTBLegacy()    
    ELSEIF (croutine =='CTBA190')
        nVersion := A190Legacy()
    ENDIF

return nVersion

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

Function getInfo()

    Local a330 := {"MATA330", "A330Legacy", "label_routine_text_MATA330"}
    Local a331 := {"MATA331", "A331Legacy", "label_routine_text_MATA331"}
    Local a350 := {"MATA350", "A350Legacy", "label_routine_text_MATA350"}
    Local a280 := {"MATA280", "A280Legacy", "label_routine_text_MATA280"}
    Local a190 := {"CTBA190", "A190Legacy", "label_routine_text_CTBA190"}
    Local a330thr := {"M330JCTB", "A330CTBLegacy" , "label_routine_text_M330JCTB"}
    Local aRoutine := { a330, a350, a331, a280, a330thr, a190}

Return aRoutine

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

Function getClasses()

    Local aClasses := {}

    AADD( aClasses, {'ac.acCalc.Service.acCalcService', 'label_routine_text_ACCALCSERVICE'} )
    AADD( aClasses, {'ac.acCalc.Repository.acCalcRep', 'label_routine_text_ACCALCREPOSITORY'} )
    //Fontes respectivos do MATA331
    AADD( aClasses, {'ac.acContab.Service.acContabServ', 'label_routine_text_ACCONTABSERVICE'} )
    AADD( aClasses, {'ac.acContab.Repository.acContabRep', 'label_routine_text_ACCONTABREPOSITORY'} )
    //Fontes respectivos do MATA350
    AADD( aClasses, {'ac.acBalanceClosing.Service.acBalanceClosing', 'label_routine_text_ACBALANCECLOSINGSERVICE'} )
    AADD( aClasses, {'ac.acBalanceClosing.Repository.acBalanceClosing', 'label_routine_text_ACBALANCECLOSINGREPOSITORY'} )
    //Fontes respectivos do MATA280
    AADD( aClasses, {'ac.acStockClosing.Repository.acStockClosingRep', 'label_routine_text_ACSTOCKCLOSINGREPOSITORY'} )
    AADD( aClasses, {'ac.acStockClosing.Service.acStockClosingServ', 'label_routine_text_ACSTOCKCLOSINGSERVICE'} )

Return aClasses

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

Function showNewDialog(aErrorMsg)

    Local nOpc := 0
    Local cLink := "https://tdn.totvs.com/pages/viewpage.action?pageId=610998939"

    nOpc := Aviso(STR0001, getErrorsToString(aErrorMsg), { STR0007, STR0006 }, 3, "",, , .F.)

    If nOpc == 1
        return .F.
    ElseIf nOpc == 2
        ShellExecute("open",cLink  ,"","",1)
    Endif

return

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author Pedro
    @since  April 07, 2021
    @version 12.1.27
/*/

static Function getErrorsToString(aErrorMsg)

    Local nX := 1
    Local cString := ''

    For nX := 1 to Len(aErrorMsg)
        cString += aErrorMsg[nX] + CRLF
        cString += CRLF
    Next nX

return cString


/*/{Protheus.doc} acUserService:postLogUser()
    Metodo responsavel para alterar a propriedade do showModal caso haja um log de usuario previo
    @type  Metodo
    @author Andre maximo
    @since  agosto 03, 2021
    @version 12.1.27
/*/
Function AccessReop()
    
    local lRet     := .F.
    Local lRelease := GetRPORelease() > "12.1.027"
    Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)
    Local lEstWms  := .F.
    Local aInfo    := {}

     //Valida se poderá ser utilizado a reabertura de Estoque com integração WMS
    IF lWmsNew       
        aInfo   :=  GetApoInfo('distribution.WMS.FechamentoEst.tlpp')
        lEstWms := !Empty(aInfo)
    EndIf
    
    If lRelease .And. (!lWmsNew .Or. lEstWms)
        lRet := VerSenha(195)
    else
        Iif(!lWmsNew,lRet := .T. , lRet)
    EndIf

Return lRet

/*/{Protheus.doc} acUserService:postLogUser()
    Metodo responsavel para alterar a propriedade do showModal caso haja um log de usuario previo
    @type  Metodo
    @author Andre maximo
    @since  agosto 03, 2021
    @version 12.1.27
/*/
Function AccessClos()
    local lRet      := VerSenha(18)
Return lRet

/*/{Protheus.doc} getValidRelease()
    Metodo responsavel por validar TokenId de cliente que esteja com a release 12.1.27
    @type  Metodo
    @author Andre maximo
    @since  agosto 03, 2021
    @version 12.1.27
/*/
Static Function getValidRelease(cEnvRpo, cKey)

	Local cEnvFront := '' 
	Local cKeyFront := ''
	Local cEnv      := ''  
	Local cTokenCli := ''  
	Local cCamINI   := ''
	Local lRet      := .T.
	Local cTokenId  := FwGetIdLSV()// Utilizada para pegar o TokenId
	
	Default cEnvRpo := "est_acompanha_custos"
	Default cKey    := "65a2"

	cEnvFront := cEnvRpo
	cKeyFront := cKey

	cTokenCli := GetPvProfString(cEnv := GetEnvServer(), "totvs_" + cEnvFront + "_tokenadm_" + cEnv, "", GetSrvIniName())

	cCamINI   := "totvs_" + cEnvFront + "_tokenadm_" + cEnv

	cTokenAval := SubStr(cCamINI,1,20) + SubStr(cTokenId,1,3) + 'nG8f' + SubStr(cEnv,1,Len(cEnv)) + SubStr(cTokenId,6,2) + 'd3q' + Substr(cEnv,Len(cEnv) - 3,Len(cEnv)) + SubStr(cTokenId,-1,5) + cKey
	cTokenAval := Encode64(cTokenAval)
	lRet := (cTokenAval == cTokenCli)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgWait
XML do ícone de loading animado em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgWait( cBGColor )

    Local cSVG As Char
    Default cBGColor    := "#FFFFFF"

    cSVG := "<?xml version='1.0' standalone='no'?> <!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' "
    cSVG += "'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>"
    cSVG += "<svg viewBox='0 0 90 90' width='36' height='36' version='1.1' xmlns='http://www.w3.org/2000/svg'>"
    cSVG += "<g transform='translate(18,18)' >"
    cSVG += " <g transform='rotate(45)' >"
    cSVG += " <circle fill='none' stroke='#424142' cx='0' cy='0' r='16' stroke-width='3' />"
    cSVG += " <line x1='-13' y1='-13' x2='13' y2='13' stroke='"+ cBGColor +"' stroke-width='4' />"
    cSVG += " <animateTransform attributeName='transform' type='rotate' values='0; 360'"
    cSVG += " dur='2s' repeatCount='indefinite' rotate='auto'/>"
    cSVG += " </g>"
    cSVG += "</g>"
    cSVG += "<circle fill='"+ cBGColor +"' cx='18' cy='18' r='11' stroke-width='3'/>"
    cSVG += "<g transform='translate(18,18)' >"
    cSVG += " <g transform='rotate(45)' >"
    cSVG += "   <circle fill='none' stroke='#9C9A9C' cx='0' cy='0' r='11' stroke-width='3'/>"
    cSVG += "   <circle fill='"+ cBGColor +"' cx='2' cy='0' r='11.5' stroke-width='3'/>"
    cSVG += "   <line x1='0' y1='13' x2='2' y2='-12' stroke='"+ cBGColor +"' stroke-width='5' />"
    cSVG += "   <line x1='2' y1='14' x2='4' y2='-14' stroke='"+ cBGColor +"' stroke-width='2' />"
    cSVG += "   <line x1='4' y1='13' x2='6' y2='-13' stroke='"+ cBGColor +"' stroke-width='2' />"
    cSVG += "   <animateTransform attributeName='transform' type='rotate' values='360; 0'"
    cSVG += "    dur='1.3s' repeatCount='indefinite' rotate='auto'/>"
    cSVG += " </g>"
    cSVG += "</g>"
    cSVG += "</svg>"

Return cSVG

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgCheck
XML do ícone de check positivo em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgCheck()
    Local cSVG As Char

    cSVG := "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
    cSVG += "<svg viewBox='0 0 60 60' width='38' height='38' xmlns='http://www.w3.org/2000/svg'>"
    cSVG += "	<g stroke='#2ca02c' stroke-width='2.3' fill='#fff'> "
	cSVG += "	<circle cx='10' cy='10' r='8.5'/> "
	cSVG += "</g> "
    cSVG += "<g transform='scale(0.48) translate(9,10)' fill='#2ca02c'> "
  	cSVG += "<path d='M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z'/> "
    cSVG += " </g>
    cSVG += "</svg>

Return cSVG

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgWarn
XML do ícone de aviso em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgWarn()

    Local cSVG As Char

    cSVG := "<?xml version='1.0' ?>"
    cSVG +="<svg height='15px' version='1.1' viewBox='0 0 32 32' width='15px'"
    cSVG +="    xmlns='http://www.w3.org/2000/svg'"
    cSVG +="    xmlns:xlink='http://www.w3.org/1999/xlink'>"
    cSVG +="    <g fill='none' fill-rule='evenodd' stroke='none' stroke-width='1'>"
    cSVG +="        <g fill='#FFD700' id='icon-61-warning'>"
    cSVG +="            <path d='M14.3077969,"
    cSVG +="            6.05448962 C15.177863,"
    cSVG +="            4.64682663 16.5905922,"
    cSVG +="            4.65018129 17.4585848,"
    cSVG +="            6.05448962 L28.2436741,"
    cSVG +="            23.5034768 C29.4052031,"
    cSVG +="            25.382692 28.5591104,"
    cSVG +="            26.9060969 26.3549711,"
    cSVG +="            26.9060969 L5.41141065,"
    cSVG +="            26.9060969 C3.20677982,"
    cSVG +="            26.9060969 2.35742742,"
    cSVG +="            25.388761 3.52270757,"
    cSVG +="            23.5034768 L14.3077969,"
    cSVG +="            6.05448962 L14.3077969,"
    cSVG +="            6.05448962 Z M15.8835643,"
    cSVG +="            11.9060969 C15.3312795,"
    cSVG +="            11.9060969 14.8835643,"
    cSVG +="            12.3591332 14.8835643,"
    cSVG +="            12.903127 L14.8835643,"
    cSVG +="            18.9090667 C14.8835643,"
    cSVG +="            19.4597113 15.3274291,"
    cSVG +="            19.9060969 15.8835643,"
    cSVG +="            19.9060969 C16.435849,"
    cSVG +="            19.9060969 16.8835643,"
    cSVG +="            19.4530606 16.8835643,"
    cSVG +="            18.9090667 L16.8835643,"
    cSVG +="            12.903127 C16.8835643,"
    cSVG +="            12.3524825 16.4396994,"
    cSVG +="            11.9060969 15.8835643,"
    cSVG +="            11.9060969 L15.8835643,"
    cSVG +="            11.9060969 Z M15.8835643,"
    cSVG +="            23.9060969 C16.435849,"
    cSVG +="            23.9060969 16.8835643,"
    cSVG +="            23.4583816 16.8835643,"
    cSVG +="            22.9060969 C16.8835643,"
    cSVG +="            22.3538121 16.435849,"
    cSVG +="            21.9060969 15.8835643,"
    cSVG +="            21.9060969 C15.3312795,"
    cSVG +="            21.9060969 14.8835643,"
    cSVG +="            22.3538121 14.8835643,"
    cSVG +="            22.9060969 C14.8835643,"
    cSVG +="            23.4583816 15.3312795,"
    cSVG +="            23.9060969 15.8835643,"
    cSVG +="            23.9060969 L15.8835643,"
    cSVG +="            23.9060969 Z' id='warning'/>"
    cSVG +="        </g>"
    cSVG +="    </g>"
    cSVG +="</svg>"

Return cSVG

/*/{Protheus.doc} mata038:VerifyInitApp()
    Metodo responsavel por verificar se as condições para iniciar a aplicação são validas
    @type  Function
    @author felipe.suetoshi
    @since  April 07, 2021
    @version 12.1.27
/*/
Function VerifyInitApp(oError,llocaliza)

Local oDic                  := JsonObject():New()
Local oRPO                  := JsonObject():New()
Local oEnvi                 := JsonObject():New()
Local oLanc                 := JsonObject():New()
Local nI                    := 1
Local nW                    := 0
Local lD3yExist             := AliasIndic('D3Y')
Local lD3xExist             := AliasIndic('D3X')
Local lD3wExist             := AliasIndic('D3W')
Local lMvCustexc            := Getmv("MV_CUSTEXC")
Local aInfo                 := getInfo()
Local aClasses              := getClasses()
LOCAL lEnviron              := FindFunction("ACVERVLD") .AND. Valtype(ACVERVLD()) == 'N'
Local lRelease              := GetRPORelease() < "12.1.033"
Local cMultiProtocolPort    := GetPvProfString( 'DRIVERS', 'MULTIPROTOCOLPORT', 'NOT FOUNDED' , GetSrvIniName())
Local cfilback              := ''
Local lLogProfile           := !A330LogProfiler()
Local lVClasses             := .F.
Local cParAlt               := ''
Local cMsg                  := ''

IF (lD3yExist .AND. !TcCanOpen("D3Y"))
  dbSelectArea("D3Y")
ENDIF

IF (lD3xExist .AND. !TcCanOpen("D3X"))
  dbSelectArea("D3X")
ENDIF

IF (lD3wExist .AND. !TcCanOpen("D3W"))
  dbSelectArea("D3W")
ENDIF

IF !lD3yExist
    oDic["label_table_text_d3y"] := STR0002 //Tabela D3Y não localizada.
ENDIF

If lLogProfile
    oEnvi["label_key_text_logprofiler"] := STR0011 //Recurso disponível apenas em release iguais ou superior a 12.1.33.
Endif

IF lRelease
    IF !getValidRelease('est_acompanha_custos', '666')
        oEnvi["label_release_text"] := STR0011 //Recurso disponível apenas em release iguais ou superior a 12.1.33.
    ENDIF
ENDIF

IF !lD3xExist
    oDic["label_table_text_d3x"] := STR0003 //Tabela D3X não localizada.
ENDIF
IF !lD3wExist
    oDic["label_table_text_d3w"] := STR0008 //Tabela D3W não localizada.
ENDIF

IF lMvCustexc != 'N' 
    oDic["label_parameter_text_mv_custexc"] := STR0004 //MV_CUSTEXC não está configurado como não exclusivo.
ENDIF

IF !lEnviron
    oRPO["label_routine_text_ACJOURNEYLOG"] := STR0010 //Atualizar AcJourneylog.prw, contido no pacote expedição continua
ENDIF

IF (cMultiProtocolPort == 'NOT FOUNDED' .OR. cMultiProtocolPort == '0')
    oEnvi["label_key_text_multiprotocolport"] := STR0054 //Porta multiprotocolo não configurada.
ENDIF

If !CheckAppEnv(@cMsg)
    oEnvi['label_key_text_app_environment'] := cMsg
EndIf

For nI := 1 to Len(aInfo)
    If !FindFunction(aInfo[nI][2])
        oRPO[aInfo[nI][3]] := aInfo[nI][1] + " " + STR0009 + " " +CValToChar(getLegacy()) //## possui incompatibilidade de versão. Versão mínima: ##
    else
        if !(getRoutine(aInfo[nI][1]) >= 104)
            oRPO[aInfo[nI][3]] := aInfo[nI][1] + " " + STR0009 + " " +CValToChar(getLegacy()) //## possui incompatibilidade de versão. Versão mínima: ##
        endif
    ENDIF
Next nI

For nI := 1 to Len(aClasses)

    lVClasses := !ASCAN(&(aClasses[nI][1] + '():TGetMethods()'), "VERSION") > 0
    If lVClasses
        oRPO[aClasses[nI][2]] := aClasses[nI][1] + " " + STR0009 + " 2.0.0"  //## possui incompatibilidade de versão. Versão mínima: ##
    Endif

Next nI

If !VldProc330(@cParAlt)
    oEnvi["label_routine_text_STOREDPROCEDURE19"] := I18N(STR0073, {cParAlt}) //O parâmetro #1[MV_XPTO]# foi alterado. Reinstale a procedure 19.
EndIf


// Validação de Lançamento padrão 667/669
cfilback := cfilant
afilscalc := matfilcalc(.f.)
For nW := 1 to len(afilscalc)
     cFilAnt := aFilsCalc[nW,2]
    if !llocaliza .And.( VerPadrao("667") .OR. VerPadrao("669"))
        llocaliza := .T.
    EndIF 
next nW
cfilant := cfilback

if llocaliza
    oLanc["warning_no_exist_lanc"]:= STR0085 // "Possui laçamento padrão 667/669 em uma ou mais filiais do grupo de empresa"
EndIf

oError["environment"]   := oEnvi
oError["dictionary"]    := oDic
oError["rpo"]           := oRPO
oError["information"]   := oLanc




Return

/*/{Protheus.doc} A330LogProfiler
	Bloqueia o uso da rotina se a chave logprofiler estiver ativo e a chave ConsoleMaxSize
	não estiver com o conteudo minimo exigido.
	Finalidade para reduzir a possibilidade do arquivo console.log com logprofiler
	ser gerado incompleto
	@type  Function
	@author reynaldo
	@since 03/02/2021
	@version 1.0
	@param lJanela, logica, Se apresenta a janela de aviso
/*/
Static Function A330LogProfiler()
Local cLogProfiler
Local cConsoleMaxSize
Local nMaxSize
Local nSizeRequired
Local lRet
Local cEndWeb

	// endereco web que informações sobre a chave ConsoleMaxSize
	cEndWeb := "https://tdn.totvs.com/display/tec/ConsoleMaxSize+--+29343"

	// Conteudo da chave ConsoleMaxSize com o tamanho minimo necessario
	// 104857600 equivale a 100MB
	nSizeRequired := 104857600

	lRet := .T.
	// Conteúdo de uma chave de configuração do ambiente em uso
	cLogProfiler := GetSrvProfString( "LogProfiler","")
	If cLogProfiler == "1"
		// Busca na seção [GENERAL] a chave de configuração do ambiente em uso
		cSecao := "GENERAL"
		cConsoleMaxSize := GetPvProfString(cSecao, "ConsoleMaxSize", "", GetSrvIniName())

		nMaxSize := Val(cConsoleMaxSize)
		If nMaxSize < nSizeRequired
			lRet := .F.
		Endif

	EndIf

RETURN lRet

Static Function PosView_02(oPanel, oPage, lNext)

Local nX   as Numeric
Local cAux as Character

nX      := 0
cAux    := ""

If !lNext
    If Len(oError["environment"]:GetNames()) == 0
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            If !(cAux $ "label_key_text_logprofiler,label_routine_text_STOREDPROCEDURE19")
                oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
            Endif
        Next nX 
    Else 
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            If oError["environment"]:HasProperty(cAux)
                oPage["svg"][cAux]:LoadSVG( SvgWarn() )
                Do Case 
                    Case cAux == "label_key_text_app_environment"
                        oPage["say"]["warning_key_app_environment"]:SetText(oPage["message"]["warning_key_app_environment"])
                        oPage["say"]["warning_key_app_environment"]:bLClicked := {|| MsgRun( STR0025, "URL",{|| ShellExecute("open",oPage["link"]["doc_app_environment"],"","",1) } ) } // "Abrindo o link... Aguarde..."
                    Case cAux == "label_key_text_multiprotocolport"
                        oPage["say"]["warning_key_multiprotocolport"]:SetText(oPage["message"]["warning_key_multiprotocolport"])
                        oPage["say"]["warning_key_multiprotocolport"]:bLClicked := {|| MsgRun( STR0025, "URL",{|| ShellExecute("open",oPage["link"]["doc_multiprotocolport"],"","",1) } ) } // "Abrindo o link... Aguarde..."
                    Case cAux == "label_release_text"
                        oPage["say"]["warning_release"]:SetText(oPage["message"]["warning_release"])
                        oPage["say"]["warning_release"]:bLClicked := {|| MsgRun( STR0025, "URL",{|| ShellExecute("open",oPage["link"]["doc_release"],"","",1) } ) } // "Abrindo o link... Aguarde..."
                    Case cAux == "label_key_text_logprofiler"
                        oPage["say"]["label_key_text_logprofiler"]:SetText(oPage["message"]["label_key_text_logprofiler"])
                        oPage["say"]["warning_key_logprofiler"]:SetText(oPage["message"]["warning_key_logprofiler"])
                        oPage["say"]["warning_key_logprofiler"]:bLClicked := {|| MsgRun( STR0025, "URL",{|| ShellExecute("open",oPage["link"]["doc_consolemaxsize"],"","",1) } ) } // "Abrindo o link... Aguarde..."
                    Case cAux == "label_routine_text_STOREDPROCEDURE19"
                        oPage["say"]["label_routine_text_STOREDPROCEDURE19"]:SetText(oPage["message"]["label_routine_text_STOREDPROCEDURE19"]) 
                EndCase
            Else 
                If !(cAux $ "label_key_text_logprofiler,label_routine_text_STOREDPROCEDURE19")
                    oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
                Endif
            Endif
        Next nX 
        oPage["say"]["warning_general"]:SetText(oPage["message"]["warning_general"])  
    Endif
Endif

lNext := .T.

Return .T.


Static Function PosView_03(oPanel, oPage, lNext)

Local nX as numeric
Local lMA330CP as logical
Local aLogDec as array
Local aLogsPart as array
Local aRegraCP as array
Local aLogsRep as array
Local lCusRep as logical

If !lNext 
    If Len(oError["dictionary"]:GetNames()) == 0
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            If !(cAux $ "label_dictionary_text_decimal/label_dictionary_text_cost_parts/label_dictionary_text_cost_reposition")
                oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
            Endif
        Next nX 
    Else 
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            If oError["dictionary"]:HasProperty(cAux)
                oPage["svg"][cAux]:LoadSVG( SvgWarn() ) 
                If (cAux $ "label_table_text_d3x/label_table_text_d3y/label_table_text_d3w")
                    //"Recomendamos a aplicação da última expedição contínua disponível para a atualização dessas tabelas no dicionário de dados."
                    oPage["say"]["warning_table"]:SetText(oPage["message"]["warning_table"])
                Endif
            Else 
                If !(cAux $ "label_dictionary_text_decimal/label_dictionary_text_cost_parts/label_dictionary_text_cost_reposition")
                    oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
                Endif
            Endif
        Next nX 
        //"Foi verificado que uma ou mais pré-condições do dicionário de dados não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
        oPage["say"]["warning_general"]:SetText(oPage["message"]["warning_general"])
    Endif

    aLogDec     := {}
    aLogsPart   := {}
    aLogsRep    := {}
    aRegraCP    := {}
    lMA330CP    := (ExistBlock("MA330CP"))
    lCusRep     := SuperGetMv("MV_CUSREP",.F.,.F.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se os campos do custo em partes estao Ok            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lMA330CP
        aRegraCP:=ExecBlock("MA330CP",.F.,.F.)
        If ValType(aRegraCP) # "A"
            aRegraCP:={}
        EndIf
    EndIf

    If Len(aRegraCP) > 0 .And. !MA330AvlCp(aRegracp,aLogsPart)
        oError["dictionary"]["label_dictionary_text_cost_parts"] := oPage["message"]["label_dictionary_text_cost_parts"]
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Avisa o usuario sobre campos faltantes com divergencias      ³
    //³ em decimais                                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If M330AvlDec(aLogDec)
        oError["dictionary"]["label_dictionary_text_decimal"] := oPage["message"]["label_dictionary_text_decimal"]
    Endif

    If lCusRep
        lCusRep := MA330AvRep(aLogsRep)
        If Len(aLogsRep) > 0 .And. !lCusRep
            oError["dictionary"]["label_dictionary_text_cost_reposition"] := oPage["message"]["label_dictionary_text_cost_reposition"]
        Endif
    Endif

    If  oError["dictionary"]:HasProperty("label_dictionary_text_decimal") .OR.;
        oError["dictionary"]:HasProperty("label_dictionary_text_cost_parts") .OR.;
        oError["dictionary"]:HasProperty("label_dictionary_text_cost_reposition")
            //"Verificação de campos faltantes ou divergentes"
            oPage["say"]["label_dictionary_title"]:SetText(oPage["message"]["label_dictionary_title"])
    Endif

    If oError["dictionary"]:HasProperty("label_dictionary_text_decimal")
        //"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento"
        oPage["svg"]["label_dictionary_text_decimal"]:LoadSVG( SvgWarn() ) 
        oPage["say"]["label_dictionary_text_decimal"]:SetText(oPage["message"]["label_dictionary_text_decimal"])
        oPage["btnbmp"]["tooltip_decimal"]:LoadBitmaps('BMPPERG')
        oPage["btnbmp"]["tooltip_decimal"]:bAction := { || M330ShowDc(aLogDec) }
    Endif

    If oError["dictionary"]:HasProperty("label_dictionary_text_cost_parts")
        //"Custo em partes não será considerado pois um ou mais campos não foram criados"
        oPage["svg"]["label_dictionary_text_cost_parts"]:LoadSVG( SvgWarn() ) 
        oPage["say"]["label_dictionary_text_cost_parts"]:SetText(oPage["message"]["label_dictionary_text_cost_parts"])
        oPage["btnbmp"]["tooltip_cost_parts"]:LoadBitmaps('BMPPERG')
        oPage["btnbmp"]["tooltip_cost_parts"]:bAction := { || MA330LPart(aLogsPart) }
    Endif

    If oError["dictionary"]:HasProperty("label_dictionary_text_cost_reposition")
        //"Custo de reposição não será considerado pois um ou mais campos não foram criados"
        oPage["svg"]["label_dictionary_text_cost_reposition"]:LoadSVG( SvgWarn() ) 
        oPage["say"]["label_dictionary_text_cost_reposition"]:SetText(oPage["message"]["label_dictionary_text_cost_reposition"])
        oPage["btnbmp"]["tooltip_cost_reposition"]:LoadBitmaps('BMPPERG')
        oPage["btnbmp"]["tooltip_cost_reposition"]:bAction := { ||  MA330LRep(aLogsRep) }
    Endif
Endif

lNext := .T.

Return

Static Function PosView_04(oPanel, oPage, lNext)

Local nX    as Numeric
Local cAux  as Character 

nX      := 0
cAux    := "" 

If !lNext
    If Len(oError["rpo"]:GetNames()) == 0
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
        Next nX 
    Else 
        For nX := 1 to Len(oPage["svg"]:GetNames())
            cAux := oPage["svg"]:GetNames()[nX]
            If oError["rpo"]:HasProperty(cAux)
                oPage["svg"][cAux]:LoadSVG( SvgWarn() ) 
            Else 
                oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
            Endif
        Next nX 

        //"Foi verificado que uma ou mais pré-condições de versionamento dos fontes não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
        oPage["say"]["warning_general"]:SetText(oPage["message"]["warning_general"])
        //"Recomendamos a aplicação da última expedição contínua disponível para a atualização desses fontes no RPO."
        oPage["say"]["warning_routines_version"]:SetText(oPage["message"]["warning_routines_version"])
    Endif
Endif

lNext := .T.

Return 
/*/{Protheus.doc} PosView_05
	@type  Classe
	@author andre.maximo
	@since 20/09/2023
	@version 1.0
	@return Self
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function PosView_05(oPanel, oPage, lNext)

Local nX    as Numeric
Local cAux  as Character 

nX      := 0
cAux    := 'label_key_text_sections1'

If !lNext
    If Len(oError["information"]:GetNames()) == 0
            oPage["svg"][cAux]:LoadSVG( SvgCheck() ) 
    Else 
        oPage["svg"][cAux]:LoadSVG( SvgWarn() ) 
        oPage["say"]["warning_no_exist_lanc"]:SetText(oPage["message"]["warning_no_exist_lanc"])
    endif
Endif

lNext := .T.

Return 

/*/{Protheus.doc} BuildPage
	@type  Classe
	@author pedro.missaglia
	@since 07/11/2022
	@version 1.0
	@return Self
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function BuildPage(cPageNum)

Local oPage as object

Do Case
    Case cPageNum == "1"
        oPage := BuildPg01()    
    Case cPageNum == "2"
        oPage := BuildPg02()
    Case cPageNum == "3"    
        oPage := BuildPg03()
    Case cPageNum == "4"
        oPage := BuildPg04()
    Case cPageNum == "5"
        oPage := BuildPg05()
EndCase

Return oPage


Static Function BuildPg01()

Local oPage     as object
Local oSay      as object
Local oMsg      as object
Local oLink     as object
Local oCheckBox as object

oPage       := JsonObject():New()
oSay        := JsonObject():New()
oMsg        := JsonObject():New()
oLink       := JsonObject():New()
oCheckBox   := JsonObject():New()

oSay["label_welcome_title"]                 := Nil
oSay["label_onboarding_text_01"]            := Nil
oSay["label_onboarding_text_02"]            := Nil
oSay["label_onboarding_text_03"]            := Nil
oSay["label_onboarding_text_04"]            := Nil
oSay["label_onboarding_text_05"]            := Nil

oLink["doc_acompanha_custos"]    := 'https://tdn.totvs.com/x/2Y8fIg'

oMsg["label_welcome_title"]                 := STR0018 //"Bem vindo!"
oMsg["label_onboarding_text_01"]            := STR0019 //"O Acompanha Custos é um painel moderno que irá concentrar todas as informações necessárias para o acompanhamento dos custos de seu estoque."
oMsg["label_onboarding_text_02"]            := STR0020 //"As diversas informações disponibilizadas permitirão a análise da composição do custo dos produtos, sua evolução ao longo do tempo, bem como a criação de alertas para monitoramento dos custos de seus produtos mais relevantes e o acompanhamento de todo o processo de fechamento de estoque da empresa."
oMsg["label_onboarding_text_03"]            := STR0021 //"Na primeira fase a ser disponibilizada durante o release 12.1.33, apresentamos a nova jornada de Fechamento de Estoque; através de uma interface única, totalmente focada na experiência do usuário, o cliente será conduzido durante seu fechamento de estoque de forma simples, intuitiva e sem a necessidade de realização de configurações ou execução de rotinas adicionais."
oMsg["label_onboarding_text_04"]            := STR0022 + space(01) //"Para saber mais sobre a rotina," 

oMsg["label_onboarding_text_04"] += "<b><a target='_blank' href='"+ oLink["doc_acompanha_custos"] +"'> "
oMsg["label_onboarding_text_04"] += STR0023 // "clique aqui"
oMsg["label_onboarding_text_04"] += " </a></b>."
oMsg["label_onboarding_text_04"] += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

oMsg["label_onboarding_text_05"] := STR0024 //"A seguir realizaremos algumas validações para verificar que se todos os requisitos necessários estão de acordo para a utilização da rotina."

oPage["link"]       := oLink
oPage["say"]        := oSay
oPage["message"]    := oMsg
oPage["checkbox"]   := oCheckBox

Return oPage

Static Function BuildPg02()

Local oPage as object
Local oSay  as object
Local oSVG  as object
Local oFont as object
Local oCss  as object
Local oMsg  as object
Local oLink as object
Local cParAlt as character
Local cMsg  as character

oPage   := JsonObject():New()
oSay    := JsonObject():New()
oSVG    := JsonObject():New()
oFont   := JsonObject():New()
oCss    := JsonObject():New()
oMsg    := JsonObject():New()
oLink   := JsonObject():New()

oCss["standard_svg"]    := Nil
oFont["bold"]           := Nil

oSay["label_release_title"]                 := Nil
oSay["label_release_text"]                  := Nil
oSay["label_key_title"]                     := Nil
oSay["label_key_driver"]                    := Nil
oSay["label_key_general"]                   := Nil
oSay["label_key_text_app_environment"]      := Nil
oSay["label_key_text_multiprotocolport"]    := Nil
oSay["label_key_text_sections"]             := Nil
oSay["label_key_text_logprofiler"]          := Nil
oSay["warning_general"]                     := Nil
oSay["warning_release"]                     := Nil
oSay["warning_key_app_environment"]         := Nil
oSay["warning_key_multiprotocolport"]       := Nil
oSay["warning_key_logprofiler"]             := Nil
oSay["label_routine_text_STOREDPROCEDURE19"] := Nil

oSVG["label_release_text"]                  := Nil
oSVG["label_key_text_app_environment"]      := Nil
oSVG["label_key_text_multiprotocolport"]    := Nil
oSVG["label_key_text_logprofiler"]          := Nil
oSVG["label_routine_text_STOREDPROCEDURE19"]  := Nil

oLink["doc_app_environment"]    := 'https://tdn.totvs.com/x/KeoYI'
oLink["doc_multiprotocolport"]  := 'https://tdn.totvs.com/x/jIUoI'
oLink["doc_release"]            := 'https://tdn.totvs.com/x/2Y8fIg'
oLink["doc_consolemaxsize"]     := 'https://tdn.totvs.com/x/oIpc'

oMsg["label_key_title"]                     := STR0027 //"Verificação de chaves de configuração no arquivo appserver.ini do ambiente:"
oMsg["label_key_driver"]                    := STR0070 //"Seção Drivers:"
oMsg["label_key_general"]                   := STR0071 //"Seção General:"
oMsg["label_key_text_app_environment"]      := STR0028 //"Chave APP_ENVIRONMENT"
If !CheckAppEnv(@cMsg)
    oMsg["label_key_text_app_environment"] += ": "+cMsg
EndIf
oMsg["label_key_text_multiprotocolport"]    := STR0029 //"Chave MULTIPROTOCOLPORT"
oMsg["label_key_text_sections"]             := STR0072 //"Atenção: Caso as chaves já estejam configuradas no AppServer, certifique-se que o arquivo contenha apenas uma única seção 'Drivers' e 'General' configurada."
oMsg["label_release_title"]                 := STR0030 //"Verificação de versão do ambiente:"
oMsg["label_release_text"]                  := STR0031 //"Release 12.1.33 ou superior"
oMsg["warning_general"]                     := STR0032 //"Foi verificado que uma ou mais pré-condições do ambiente não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
oMsg["warning_key_app_environment"]         := STR0033 + space(01) //"Para maiores informações sobre a configuração da chave app_environment,"
oMsg["warning_key_multiprotocolport"]       := STR0034 + space(01) //"Para maiores informações sobre a configuração da chave multiprotocolport,"
oMsg["warning_release"]                     := STR0035 + space(01) //"Para maiores informações sobre a release necessária,"
oMsg["label_key_text_logprofiler"]          := STR0056 //"Chave LOGPROFILER e CONSOLEMAXSIZE"
oMsg["warning_key_logprofiler"]             := STR0057 + space(01) //"Para maiores informações sobre a release necessária,"
    
oMsg["warning_key_app_environment"]  += "<b><a target='_blank' href='"+ oLink["doc_app_environment"] +"'> "
oMsg["warning_key_app_environment"]  += STR0023 // "clique aqui"
oMsg["warning_key_app_environment"]  += " </a></b>."
oMsg["warning_key_app_environment"]  += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

oMsg["warning_key_multiprotocolport"] += "<b><a target='_blank' href='"+ oLink["doc_multiprotocolport"] +"'> "
oMsg["warning_key_multiprotocolport"] += STR0023 // "clique aqui"
oMsg["warning_key_multiprotocolport"] += " </a></b>."
oMsg["warning_key_multiprotocolport"] += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

oMsg["warning_release"] += "<b><a target='_blank' href='"+ oLink["doc_release"] +"'> "
oMsg["warning_release"] += STR0023 // "clique aqui"
oMsg["warning_release"] += " </a></b>."
oMsg["warning_release"] += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

oMsg["warning_key_logprofiler"] += "<b><a target='_blank' href='"+ oLink["doc_consolemaxsize"] +"'> "
oMsg["warning_key_logprofiler"] += STR0023 // "clique aqui"
oMsg["warning_key_logprofiler"] += " </a></b>."
oMsg["warning_key_logprofiler"] += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

If !VldProc330(@cParAlt)
    oMsg["label_routine_text_STOREDPROCEDURE19"] := I18N(STR0073, {cParAlt}) //O parâmetro #1[MV_XPTO]# foi alterado. Reinstale a procedure 19.
Else
	oMsg["label_routine_text_STOREDPROCEDURE19"] := ""
EndIf

oPage["link"]       := oLink
oPage["say"]        := oSay
oPage["svg"]        := oSVG
oPage["font"]       := oFont
oPage["message"]    := oMsg
oPage["css"]        := oCss

Return oPage

Static Function BuildPg03()

Local oPage as object
Local oSay  as object
Local oSVG  as object
Local oFont as object
Local oCss  as object
Local oMsg  as object
Local oLink as object
Local oBtnBmp as object

oPage   := JsonObject():New()
oSay    := JsonObject():New()
oSVG    := JsonObject():New()
oFont   := JsonObject():New()
oCss    := JsonObject():New()
oMsg    := JsonObject():New()
oLink   := JsonObject():New()
oBtnBmp := JsonObject():New()

oCss["standard_svg"]    := Nil
oFont["bold"]           := Nil

oBtnBmp["tooltip_decimal"]          := Nil
oBtnBmp["tooltip_cost_parts"]       := Nil
oBtnBmp["tooltip_cost_reposition"]  := Nil

oSay["label_table_title"]                       := Nil
oSay["label_table_text_d3x"]                    := Nil
oSay["label_table_text_d3y"]                    := Nil
oSay["label_table_text_d3w"]                    := Nil
oSay["label_parameter_title"]                   := Nil
oSay["label_parameter_text_mv_custexc"]         := Nil
oSay["warning_general"]                         := Nil
oSay["warning_table"]                           := Nil
oSay["label_dictionary_title"]                  := Nil
oSay["label_dictionary_text_decimal"]           := Nil
oSay["label_dictionary_text_cost_parts"]        := Nil
oSay["label_dictionary_text_cost_reposition"]   := Nil

oSVG["label_table_text_d3x"]                    := Nil
oSVG["label_table_text_d3y"]                    := Nil
oSVG["label_table_text_d3w"]                    := Nil
oSVG["label_parameter_text_mv_custexc"]         := Nil
oSVG["label_dictionary_text_decimal"]           := Nil
oSVG["label_dictionary_text_cost_parts"]        := Nil
oSVG["label_dictionary_text_cost_reposition"]   := Nil

oMsg["label_table_title"]                       := STR0036 //"Verificação de tabelas necessárias para a utilização da rotina no dicionário de dados:"
oMsg["label_table_text_d3x"]                    := STR0037 //"Tabela de logs de fechamentos - D3X"
oMsg["label_table_text_d3y"]                    := STR0038 //"Tabela de fechamentos realizados - D3Y"
oMsg["label_table_text_d3w"]                    := STR0039 //"Tabela de controle transacional de processamentos - D3W"
oMsg["label_parameter_title"]                   := STR0040 //"Verificação dos parâmetros de sistema necessários para a utilização da rotina no dicionário de dados:"
oMsg["label_parameter_text_mv_custexc"]         := STR0041 //"Parâmetro MV_CUSTEXC como não exclusivo"
oMsg["warning_general"]                         := STR0042 //"Foi verificado que uma ou mais pré-condições do dicionário de dados não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
oMsg["warning_table"]                           := STR0043 //"Recomendamos a aplicação da última expedição contínua disponível para a atualização dessas tabelas no dicionário de dados."
oMsg["label_dictionary_title"]                  := STR0058 //"Verificação de campos faltantes ou divergentes:"
oMsg["label_dictionary_text_decimal"]           := STR0059 //"Existem campos com decimais divergentes, poderão ocorrer diferenças de arredondamento"
oMsg["label_dictionary_text_cost_parts"]        := STR0060 //"Custo em partes não será considerado pois um ou mais campos não foram criados"
oMsg["label_dictionary_text_cost_reposition"]   := STR0061 //"Custo de Reposição nao sera considerado pois algum(ns) campos(s) nao foi(ram) criado(s)"

oPage["say"]        := oSay
oPage["svg"]        := oSVG
oPage["font"]       := oFont
oPage["message"]    := oMsg
oPage["css"]        := oCss
oPage["btnbmp"]     := oBtnBmp

Return oPage

Static Function BuildPg04()

Local oPage as object
Local oSay  as object
Local oSVG  as object
Local oFont as object
Local oCss  as object
Local oMsg  as object

oPage   := JsonObject():New()
oSay    := JsonObject():New()
oSVG    := JsonObject():New()
oFont   := JsonObject():New()
oCss    := JsonObject():New()
oMsg    := JsonObject():New()

oCss["standard_svg"]    := Nil
oFont["bold"]           := Nil

oSay["label_routines_title_version"]        := Nil
oSay["label_routine_text_MATA330"]          := Nil
oSay["label_routine_text_MATA280"]          := Nil
oSay["label_routine_text_MATA331"]          := Nil
oSay["label_routine_text_MATA350"]          := Nil
oSay["label_routine_text_M330JCTB"]         := Nil
oSay["label_routine_text_CTBA190"]          := Nil
oSay["label_routine_text_ACJOURNEYLOG"]     := Nil

//MATA330
oSay["label_routine_text_ACCALCSERVICE"]     := Nil
oSay["label_routine_text_ACCALCREPOSITORY"]  := Nil
//MATA331
oSay["label_routine_text_ACCONTABSERVICE"]   := Nil
oSay["label_routine_text_ACCONTABREPOSITORY"]:= Nil
//MATA350
oSay["label_routine_text_ACBALANCECLOSINGSERVICE"]:= Nil
oSay["label_routine_text_ACBALANCECLOSINGREPOSITORY"]   := Nil
//MATA280
oSay["label_routine_text_ACSTOCKCLOSINGSERVICE"]:= Nil
oSay["label_routine_text_ACSTOCKCLOSINGREPOSITORY"]   := Nil

oSay["warning_general"]                     := Nil
oSay["warning_routines_version"]            := Nil

oSVG["label_routine_text_MATA330"]          := Nil
oSVG["label_routine_text_MATA331"]          := Nil
oSVG["label_routine_text_MATA280"]          := Nil
oSVG["label_routine_text_MATA350"]          := Nil
oSVG["label_routine_text_M330JCTB"]         := Nil
oSVG["label_routine_text_CTBA190"]          := Nil
oSVG["label_routine_text_ACJOURNEYLOG"]     := Nil
oSVG["label_routine_text_ACCALCSERVICE"]     := Nil
oSVG["label_routine_text_ACCALCREPOSITORY"]  := Nil
oSVG["label_routine_text_ACCONTABSERVICE"]   := Nil
oSVG["label_routine_text_ACCONTABREPOSITORY"]:= Nil
oSVG["label_routine_text_ACBALANCECLOSINGSERVICE"]:= Nil
oSVG["label_routine_text_ACBALANCECLOSINGREPOSITORY"]   := Nil
oSVG["label_routine_text_ACSTOCKCLOSINGSERVICE"]:= Nil
oSVG["label_routine_text_ACSTOCKCLOSINGREPOSITORY"]   := Nil

oMsg["label_routines_title_version"]        := STR0044 //"Verificação de versionamento de fontes necessários para a utilização da rotina no RPO:"
oMsg["label_routine_text_MATA330"]          := STR0045 //"Rotina do recálculo do custo médio - MATA330"
oMsg["label_routine_text_MATA331"]          := STR0046 //"Rotina da contabilização do recálculo do custo médio - MATA331"
oMsg["label_routine_text_MATA280"]          := STR0047 //"Rotina de virada dos saldos - MATA280"
oMsg["label_routine_text_MATA350"]          := STR0048 //"Rotina de saldo atual para final - MATA350"
oMsg["label_routine_text_M330JCTB"]         := STR0049 //"Rotina de contabilização através de job via recálculo do custo médio - M330JCTB"
oMsg["label_routine_text_CTBA190"]          := STR0050 //"Rotina de reprocessamento de saldo contábeis  - CTBA190"
oMsg["warning_general"]                     := STR0051 //"Foi verificado que uma ou mais pré-condições de versionamento dos fontes não foram atendidas, favor contatar o administrador do sistema ou o suporte TOTVS."
oMsg["warning_routines_version"]            := STR0052 //"Recomendamos a aplicação da última expedição contínua disponível para a atualização desses fontes no RPO."
oMsg["label_routine_text_ACJOURNEYLOG"]     := STR0053 //"Rotina de classe de logs - ACJOURNEYLOG"
oMsg["label_routine_text_ACCALCSERVICE"]     := STR0062 //'Classe de serviço do recálculo do custo médio - MATA330'
oMsg["label_routine_text_ACCALCREPOSITORY"]  := STR0063 //'Classe de repositório do recálculo do custo médio - MATA330'
oMsg["label_routine_text_ACCONTABSERVICE"]   := STR0064 //'Classe de serviço da contabilização do recálculo do custo médio - MATA331'
oMsg["label_routine_text_ACCONTABREPOSITORY"]:= STR0065 //'Classe de repositório da contabilização do recálculo do custo médio - MATA331'
oMsg["label_routine_text_ACBALANCECLOSINGSERVICE"]:= STR0066 //'Classe de serviço de saldo atual para final - MATA350'
oMsg["label_routine_text_ACBALANCECLOSINGREPOSITORY"]   := STR0067 //'Classe de repositório de saldo atual para final - MATA350'
oMsg["label_routine_text_ACSTOCKCLOSINGSERVICE"]:= STR0068 //'Classe de serviço de virada dos saldos - MATA280'
oMsg["label_routine_text_ACSTOCKCLOSINGREPOSITORY"]   := STR0069 //'Classe de repositório de virada dos saldos - MATA280'

oPage["say"]        := oSay
oPage["svg"]        := oSVG
oPage["font"]       := oFont
oPage["message"]    := oMsg
oPage["css"]        := oCss

Return oPage

/*/{Protheus.doc} BuildPage05
	@type  Classe
	@author andre.maximo
	@since 20/09/2023
	@version 1.0
	@return Self
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function BuildPg05()

Local oPage as object
Local oSay  as object
Local oSVG  as object
Local oFont as object
Local oCss  as object
Local oMsg  as object

oPage   := JsonObject():New()
oSay    := JsonObject():New()
oSVG    := JsonObject():New()
oFont   := JsonObject():New()
oCss    := JsonObject():New()
oMsg    := JsonObject():New()

oCss["standard_svg"]    := Nil
oFont["bold"]           := Nil
oSVG["label_key_text_sections"] := Nil

oMsg["label_welcome_title"]                 := STR0074 //'Lançamentos Padrões 667/669'
oMsg["label_welcome_subtitle"]              := STR0075 //'Como ficou no Acompanha Custos'
oSay["warning_no_exist_lanc"]               := NIL
oMsg["warning_no_exist_lanc"]               := STR0085 // "Possui laçamento padrão 667/669 em uma ou mais filiais do grupo de empresa"
oMsg["label_key_text_sections1"]            := STR0077 // "Os lançamentos padronizados 667/669 tornaram-se obsoletos, pois o mecanismo de execução do processo de contabilização foi otimizado," 
oMsg["label_key_text_sections1"]            += STR0078  //"visando melhoria da performance, e atualmente é executado apenas no final do processo de cálculo e/ou no processo de execução da contabilização." 
 
oMsg["label_key_text_sections2"]            := STR0079 //"Atualmente seu funcionamento é o mesmo dos lançamentos 666 e 668 e são acionados apenas na execução da rotina Recálculo do Custo Médio (MATA330), "
oMsg["label_key_text_sections2"]            += STR0080 //"quando o parâmetro 'Gera Lançamentos Contábeis' está como Sim."

oMsg["label_key_text_sections3"]            := STR0081 //"Como o Acompanha Custos executa o processamento do fechamento em etapas, executando as rotinas de Recálculo do Custo Médio (MATA330) e Contabilização do Custo Médio (MATA331) de maneira individual,"
oMsg["label_key_text_sections3"]            += STR0082 // "os lançamentos 667 e 669 não serão acionados. Como o funcionamento desses lançamentos e dos lançamentos 666 e 668 é exatamente o mesmo, caso sua empresa utilize esse lançamentos recomendamos a migração das regras" 
oMsg["label_key_text_sections4"]            := STR0083 //"existentes neles para os lançamentos 666 e 668, respectivamente."            

oPage["say"]        := oSay
oPage["message"]    := oMsg
oPage["svg"]        := oSVG
oPage["css"]        := oCss
oPage["font"]       := oFont

Return oPage


/*/{Protheus.doc} CheckEnvRu
    Verifica se e ambiente Russia
    @type  Function
    @author Squad.Entradas
    @since 09/12/2022
    @version 1.0
    @return lRet, logical, lRet
    /*/
Static Function CheckEnvRu()

    Local cContent as character
    Local lRet     as logical

    cContent := GetSrvProfString("Theme", "Classic")

    If AllTrim(Upper(cContent)) == "MA3"
        lRet := .T.
    Else
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} ProfileOk
    Verifica se o profile esta configurado para nao exibir mais o Wizard
    @type  Function
    @author Squad.Entradas
    @since 24/04/2023
    @version 1.0
    @return lRet, logical, lRet
    /*/
Static Function ProfileOk(oProfile)

    Local aLoad := {}  as array
    Local lRet  := .F. as logical

    oProfile:SetTask("WIZARD")      // Nome da sessao
    oProfile:SetType("VALIDATION")  // Valor
    aLoad := oProfile:Load()
    lRet := !Empty(aLoad) .And. oProfile:GetProfile()[1]

    aLoad := aSize(aLoad,0)
    aLoad := Nil

Return lRet

/*/{Protheus.doc} EnvironOk
    Verifica se o ambiente esta apto a executar a rotina
    @type  Function
    @author Squad.Entradas
    @since 24/04/2023
    @version 1.0
    @return lRet, logical, lRet
    /*/
Static Function EnvironOk()

    Local lRet := .F. as logical

    lRet := Len(oError["environment"]:GetNames()) == 0 .And.;
            Len(oError["rpo"]:GetNames()) == 0 .And.;
            (Len(oError["dictionary"]:GetNames()) == 0 .Or.;
            Iif(Len(oError["dictionary"]:GetNames()) == 1, oError["dictionary"]:GetNames()[1] == "label_dictionary_text_decimal", .F.))

Return lRet

/*/{Protheus.doc} WizardDlg
    Monta a Dialog do Wizard
    @type  Function
    @author Squad.Entradas
    @since 24/04/2023
    @version 1.0
    @return lRet, logical, lRet
    /*/
Static Function WizardDlg()

    Local oNewPag   := Nil
    Local oStepWiz  := Nil
    Local oDlg      := Nil
    Local oPanelBkg := Nil
    Local oWiz      := JsonObject():New()
    Local nX        := 0

    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE STR0012 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

    /* Define tamanho da Dialog que comportará o Wizard */
    oDlg:nWidth := 800
    oDlg:nHeight := 680
    
    /* Define o tamanho do painel do Wizard */
    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

    /* Instancia a classe FWWizard */
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()

    For nX := 1 to 5
        oWiz['page_'+StrZero(nX,2)] := BuildPage(CValToChar(nX))
        SetPage(cValtoChar(nX),@oNewPag, @oStepWiz, @oDlg, @oWiz['page_'+StrZero(nX,2)])    
    Next nX

    oStepWiz:Activate()
    ACTIVATE DIALOG oDlg CENTER

    /* Destrói o objeto no fechamento total do Wizard */
    oStepWiz:Destroy()

Return

/*/{Protheus.doc} CheckPicFo
    Retorna conteudo da chave PICTFORMAT para formatacao de valores numericos
    @type  Function
    @author Squad.Entradas
    @since 11/04/2024
    @version 1.0
    @return cContent, character, conteudo do PictFormat
    /*/
Static Function CheckPicFo()
    Local cContent as character

    cContent := GetPvProfString(GetEnvServer(), "PictFormat", "DEFAULT", GetSrvIniName())

    If !(AllTrim(Upper(cContent)) $ "AMERICAN|DEFAULT")
        cContent := "DEFAULT"
    EndIf
Return cContent

/*/{Protheus.doc} CheckAppEnv
    Verifica a chave App_Environment e App_Environment_Extra
    @type  Static Function
    @author user
    @since 26/09/2024
/*/
Static Function CheckAppEnv(cMsg)
    Local cRelease        := GetRPORelease()
    Local lRet            := .T.

    If !AmIOnRestEnv()
        If cRelease >= "12.1.2410"
            cMsg := STR0092 //Verifique a chave app_environment, ou configure a chave app_environment_extra.
        Else
            cMsg := STR0055 //Chave app_environment não configurada.
        EndIf
        lRet := .F.
    EndIf

Return lRet
