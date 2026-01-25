#include "Protheus.ch"
#include "FWMVCDEF.ch"
#include "TMSAE71.CH"

Static aAgends  := {}

/*/{Protheus.doc} TMSAE71A
    (Chama Rotina de Monitor do Comprovante de Entrega em MODO 'MONITOR')
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
Function TMSAE71A
    TMSAE71(0)
Return NIL

/*/{Protheus.doc} TMSAE71B
    (Chama Rotina de Monitor do Comprovante de Entrega em MODO 'MAMUTENCAO')
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
Function TMSAE71B()
    TMSAE71(1)
Return Nil

/*/{Protheus.doc} TMSAE71
    TMSAE71() Rotina Padrão MVC Painel do Comprovante
    TMSAE71A - Modo Monitor
    TMSAE71B - Modo Manutenção
    @Author tiago.dsantos
    @since  08/08/2019
    @Param nOption, Numeric, "nOption : 0-Monitor;1-Manutenção"
    @Param aArgs  , Array  , "Informar um vetor para cada tipo de rotina que utiliza o programa exemplo"
                +-------------------+-----------------------------------------------------------------------+
                | Rotina de Chamada | Descrição do elemento do vetro                                        |
                +-------------------+-----------------------------------------------------------------------+
                |TMSA360            | [1] Filial Origem De; [2] Filial Origem Até                           |
                |                   | [3] Nr.Ocorr. De      [4] Nr.Ocorr. Ate                               |
                +-------------------+-----------------------------------------------------------------------+
 /*/
Function TMSAE71(nOption,aArgs)
Local nViewRes   := 0
Local cPerg      := "TMSAE71"
Local lComprEnt  := TableInDic("DLY")
Local lDLYDOC    := DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0
Local cFunction  := ProcName()
Local lDicDNN   := AliasIndic("DNN")

private aRotina    := MenuDef()
private lMonitora  := .F.
private lInTmsa360 := (Funname() == "TMSA360")
private aParam     := {}  

Private lDeFora    := IsInCallStack("TMSA141") .Or. IsInCallStack("TMSA144") .Or. IsInCallStack("TMSAF76") .Or. IsInCallStack("TMSAF60")
Private cAlias     := ""
Private cTableName := ""
Private oTempTable

Default nOption    := 0
Default aArgs      := {"","","",""}

    If lDicDNN
        DbSelectArea("DNN")
    EndIf

    Iif(ExistFunc('FwPdLogUser'),FwPdLoguser(cFunction),)
   
    //-- Proteção para quando tabela não atualizada
    If !lComprEnt
        Aviso("",STR0045,{"OK"})//"Não foi localizada a tabela DLY-Eventos do Comprovante Entrega na Base de Dados, atualize o dicionário"
        Return
    EndIf

    //-- Proteção para quando tabela não atualizada
    If !lDLYDOC
        Aviso("",STR0046,{"OK"})//"Não foi localizado campos importantes para o Comprovante Entrega na Base de Dados, atualize o dicionário"
        Return
    EndIf

    //-- Tela de pergunta é chamada somente pelo menu
    //If funname() $ "TMSAE71A|TMSAE71B"
    If lInTmsa360
		aParam := aClone(aArgs)
    Else
    	If !lDeFora
			If !Pergunte(cPerg)
	            Return Nil
			EndIf
		EndIf
    EndIf
    //EndIf
    //+---------------------------------------
    //| Modo Monitor
    //+---------------------------------------
    DbSelectArea("DLY")
    If nOption == 0
       lMonitora := .T.
    //+---------------------------------------
    //| Modo Manutenção
    //+---------------------------------------
    ElseIf nOption == 1
       lMonitora := .F.
    EndIf

	If lDeFora
		TMSCmpTrb(@oTempTable,@cAlias,@cTableName)
	EndIf

    FWExecView( STR0001 ,'TMSAE71',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },nViewRes,,{ || .T. })	//-- "Painel Acompanhamento de Documentos"

	If lDeFora
		TMSCmpDel(oTempTable)
	EndIf

Return Nil

/*/{Protheus.doc} ModelDef()
    (Modelo da rotina
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
Static Function ModelDef()

Local oDT6Stru   := FwFormStruct( 1,"DT6", {|xCampo| (AllTrim(xCampo) $ getCampos("DT6")) })
Local oDLYStru
Local oDNNStru
Local oModel     := NIL
Local aPKDT6     := Strtokarr2( DT6->(IndexKey(1)),"+",.F.)
Local bMDT6Pre   := {|oModel,nLine,cAction,cFieldID,xNewValue,xOldValue| TMAE71Pre1(oModel,nLine,cAction,cFieldID,xNewValue,xOldValue) }
Local aDLYKey    := {}
Local aDNNKey    := {}
Local lDicDNN   := AliasIndic("DNN")

oDLYStru := FwFormStruct(1,"DLY", {|xCampo| !(AllTrim(xCampo) $ "DLY_DIRIMG") })

If lDicDNN
    oDNNStru := FwFormStruct( 1, "DNN" )
    oDNNStru:SetProperty( 'DNN_JUSTIF', MODEL_FIELD_WHEN,   { |oModel| TAE71WHEN('DNN_JUSTIF' ) } )
    oDNNStru:SetProperty( 'DNN_JUSTIF', MODEL_FIELD_VALID,  { |oModel| TAE71Vld( 'DNN_JUSTIF', '0', oModel:GetModel() ) } )
    oDNNStru:SetProperty( 'DNN_IMAGEM', MODEL_FIELD_WHEN,   { |oModel| .F. } )
    AddCFields( @oDNNStru, 1, "DNN" )
EndIf

If isBlind() //-- Quando chamada via api rest lMonitora não é declarada
    Private lMonitora  := .F.
    private lInTmsa360 := .F.
    private aParam     := {}
    private MV_PAR01 := "" //-- Codigo Remetente De
    private MV_PAR02 := "" //-- Loja Remetente De
    private MV_PAR03 := "" //-- Codigo Remetente Ate
    private MV_PAR04 := "" //-- Loja Remetente Ate
    private MV_PAR05 := Date() //-- Data Entrega De
    private MV_PAR06 := Date() //-- Data Entrega Ate
EndIf

oDT6Stru:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F. )

//-- Adiciona campos virtuais
AddCFields(@oDT6Stru,1,"DT6") 
AddCFields(@oDLYStru,1,"DLY")

oModel := MPFormModel():New("TMSAE71",,,{ |oMdl| TMSAE71Cmt( oMdl ) })

oModel:AddFields("MASTER",,oDT6Stru)
oModel:GetModel("MASTER"):SetDescription(STR0001)	//-- "Painel Acompanhamento de Entregas"
oModel:SetPrimaryKey(aPKDT6)

//----------------------------------------------------------------------------
//-- Grid Superior DT6
//----------------------------------------------------------------------------
//--           Grid-ID   ,Father-ID,FormStruct,bLinePre,bLinhaOk,bpre    ,bPost,{ |oMDGDTQ,lCopia| LdDataSet(oMDGDTQ,lCopia,"DTQ") } )
oModel:AddGrid("MGRIDDT6","MASTER" ,oDT6Stru, , , bMDT6Pre, , { |oMdGrid| LdDataSet( oMdGrid, "DT6", .F. ) } )
oModel:getModel("MGRIDDT6"):SetDescription(STR0002)	//-- "Documentos de Transporte"
oModel:GetModel("MGRIDDT6"):SetOnlyQuery(.T.)
oModel:GetModel("MGRIDDT6"):SetNoInsertLine(.T.)
oModel:GetModel("MGRIDDT6"):SetNoDeleteLine(.T.)
oModel:GetModel("MGRIDDT6"):SetForceLoad(.T.)

//----------------------------------------------------------------------------
//-- Grid Inferior DLY
//----------------------------------------------------------------------------
oModel:AddGrid("MGRIDDLY","MGRIDDT6",oDLYStru, , , ,  )
oModel:GetModel("MGRIDDLY"):SetDescription(STR0003)	//-- "Notas Fiscais do Evento Entrega"
oModel:GetModel("MGRIDDLY"):SetNoInsertLine(.T.)
oModel:GetModel("MGRIDDLY"):SetNoDeleteLine(.T.)
oModel:GetModel("MGRIDDLY"):SetOptional(.T.)

// Relation DT6 x DLY
aDLYKey := {{"DLY_FILIAL","xFilial('DLY')"},{"DLY_CHVCTE","TMSAE71Val('DT6_CHVCTE')"}}

oModel:SetRelation("MGRIDDLY",aDLYKey, "DLY_FILIAL+DLY_CHVCTE+DLY_STATUS" )

//----------------------------------------------------------------------------
//-- Grid Inferior DNN
//----------------------------------------------------------------------------
If lDicDNN
    oModel:AddGrid("MGRIDDNN","MGRIDDT6",oDNNStru, , , ,  )
    oModel:GetModel("MGRIDDNN"):SetDescription('STR0003')	//-- "Notas Fiscais do Evento Insucesso"
    oModel:GetModel("MGRIDDNN"):SetNoInsertLine(.T.)
    oModel:GetModel("MGRIDDNN"):SetNoDeleteLine(.T.)
    oModel:GetModel("MGRIDDNN"):SetOptional(.T.)

    // Relation DT6 x DNN
    aDNNKey := {{"DNN_FILIAL","xFilial('DNN')"},{"DNN_FILDOC",'TMSAE71Val("DT6_FILDOC")'},{"DNN_DOC",'TMSAE71Val("DT6_DOC")'},{"DNN_SERIE",'TMSAE71Val("DT6_SERIE")'}}

    oModel:SetRelation("MGRIDDNN", aDNNKey,  DNN->(IndexKey(1)) )
EndIf

Return oModel

/*/{Protheus.doc} ViewDef
    Visao da rotina
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
Static Function ViewDef()
Local oDT6Stru  := FwFormStruct(2,"DT6",{|xCampos| (AllTrim(xCampos) $ getCampos("DT6")) })
Local oDLYStru  := Nil
Local oDNNStru  := Nil
Local oView     := NIL
Local oModel    := FwLoadModel("TMSAE71")
Local lDicDNN   := AliasIndic("DNN")

oDLYStru := FwFormStruct( 2, "DLY", {|xCampo| !( AllTrim(xCampo) $ "DLY_DIRIMG" ) } )
If lDicDNN
    oDNNStru := FwFormStruct( 2, "DNN", {|xCampo| !( AllTrim(xCampo) $ "DNN_DOC|DNN_FILDOC|DNN_SERIE|DNN_IMAGEM" ) } )
    AddCFields( @oDNNStru, 2, "DNN" )
    TMSAE71Ord( @oDNNStru, "DNN" )
    AddCFields(@oDNNStru,2,"DNN")
EndIf
//-- Adiciona campos virtuais
AddCFields(@oDT6Stru,2,"DT6")
AddCFields(@oDLYStru,2,"DLY")

TMSAE71Ord(@oDT6Stru,"DT6")
TMSAE71Ord(@oDLYStru,"DLY")

oDT6Stru:SetProperty("T1_STATUS", MVC_VIEW_PICT   ,"@BMP")

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("DUMMYVIEW",oDT6Stru,"MASTER")

//------------------------------------------------------------
//| View Grid - Superior
//------------------------------------------------------------
oView:CreateHorizontalBox("DOCUMENTOS",40)
oView:AddGrid("VGRID_DT6",oDT6Stru,"MGRIDDT6")
//oView:AddIncrementField("VGRID_DT6","DTQ_ITEM")
oView:EnableTitleView("VGRID_DT6",STR0004)	//-- "Documentos Transportados"
oView:SetOwnerView("VGRID_DT6","DOCUMENTOS")

//------------------------------------------------------------
//| View Buttons - Centro
//------------------------------------------------------------
If lMonitora
    oView:CreateHorizontalBox("BUTTONS1",10)
    oView:AddOtherObject("BUTTONS_PANEL1",{|oPanel1| AddButtons(oPanel1,1) })
    oView:SetOwnerView("BUTTONS_PANEL1","BUTTONS1")
EndIf

//------------------------------------------------------------
//| View Grid - Inferior Tabela DLY
//------------------------------------------------------------
oView:CreateHorizontalBox("INVOICES_DLY",40)
oView:CreateFolder( 'FOLDER', 'INVOICES_DLY')
oView:AddSheet('FOLDER','DLY',STR0005)
oView:CreateHorizontalBox( 'BOXFORM1', 100, , , 'FOLDER', 'DLY')
oView:AddGrid("VGRID_DLY",oDLYStru,"MGRIDDLY")
oView:EnableTitleView("VGRID_DLY",STR0005)	//-- "Notas Fiscais x Documentos Entregues"
oView:SetOwnerView("VGRID_DLY","BOXFORM1")

//------------------------------------------------------------
//| View Grid - Inferior Tabela DNN
//------------------------------------------------------------
If lDicDNN
    oView:AddSheet( 'FOLDER', 'DNN', STR0050 )
    oView:CreateHorizontalBox( 'BOXFORM2', 100, , , 'FOLDER', 'DNN' )
    oView:AddGrid("VGRID_DNN",oDNNStru,"MGRIDDNN")
    oView:EnableTitleView("VGRID_DNN",STR0050)	//-- "Notas Fiscais x Documentos Insucesso"
    oView:SetOwnerView("VGRID_DNN","BOXFORM2")
EndIf

//------------------------------------------------------------
//| View Buttons - Inferior
//------------------------------------------------------------
If lMonitora
    oView:CreateHorizontalBox("BUTTONS2",10)
    oView:AddOtherObject("BUTTONS_PANEL2",{|oPanel2| AddButtons(oPanel2,2) })
    oView:SetOwnerView("BUTTONS_PANEL2","BUTTONS2")
EndIf

//-- Grid de Notas Fiscais não poderá ser editada, somente visualização
oView:SetViewProperty("VGRID_DLY", "ONLYVIEW") 
oView:SetViewProperty("VGRID_DLY", "ENABLENEWGRID")

//Habilita filtro no grid
oView:SetViewProperty("VGRID_DLY", "GRIDFILTER", {.T.})
//Habilita pesquisa no grid
oView:SetViewProperty("VGRID_DLY", "GRIDSEEK", {.T.})

//-- Ao realizar a mudança de linha na grid superior é realizado um refresh
//-- na grid inferior e atualiza os status se necessário.
oView:SetViewProperty("VGRID_DT6","CHANGELINE",{{|oView,cViewId| T71DT6ChL(oView,cViewId)}})

//------------------------------------------------------------
// Folder para ocultar o cabeçalho e exibir apenas os grides
//------------------------------------------------------------
oView:CreateHorizontalBox("FOLDER_AREA_A",0)
oView:CreateFolder("FOLDER_GROUP_A","FOLDER_AREA_A")
oView:AddSheet("FOLDER_GROUP_A","FOLDER_A","DLY_FIELDS")
oView:CreateHorizontalBox( "DUMMY_HEADER", 100, , , "FOLDER_GROUP_A", "FOLDER_A", "DLY_FIELDS" )
oView:SetOwnerView("DUMMYVIEW","DUMMY_HEADER")

oView:bAfterViewActivate := { |oView| TMSAE71Act(oView)}

If !lMonitora
    oView:AddUserButton(STR0036,'',{|| Tmae71Sel() }) //Selecionar Comprovante de Entrega
    If lDicDNN
        oView:AddUserButton(STR0049,'',{|| Tmae71Sel(.T.) }) //Selecionar Comprovante de Insucesso
    EndIf
EndIf

oView:AddUserButton(STR0006,'',{|| TMAE71Leg("DT6") })  //| Legenda DT6-Documentos Transportes	//-- "Leg. Documentos"
oView:AddUserButton(STR0007,'',{|| TMAE71Leg("DLY") })  //| Legenda DLY-Comprovantes de Entrega	//-- "Leg. Eventos"

If lDicDNN
    oView:SetViewProperty("VGRID_DNN","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})
    oView:AddUserButton( STR0057, '', { || TMAE71Leg("DNN") } )  //| Legenda DNN-Insucesso na Entrega	//-- "Leg. Eventos Insucesso"
EndIf

oView:SetViewProperty("VGRID_DT6","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})

If lMonitora
        //Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o qustionamento ao usuario de formulario modificado
    oView:SetCloseOnOk({|| .T.})
    oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
    oView:ShowInsertMsg(.F.)
EndIf

Return oView

/*/{Protheus.doc} TMAE71Pre1
    (realiza pre validação do campo em edição para a linha em foco usado na grid do DT6)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function TMAE71Pre1(oModel,nLine,cAction,cFieldID,xNewValue,xOldValue)
Local lRet      := .T.
Local oFmodel   := FwModelActive()
Local oMDLY     := oFmodel:GetModel("MGRIDDLY")
Local oView     := FWViewActive()
Local cChvCte   := oModel:GetValue("DT6_CHVCTE")
Local lDocApto  := .F.
Local aEvtNF    := {}

Default oModel     := Nil
Default nLine      := 1
Default cAction    := ''
Default cFieldId   := ''
Default xNewValue  := ''
Default xOldValue  := ''

    If cAction == "ATUSTTS"
        If oMDLY:SeekLine({{"DLY_CHVCTE",cChvCte}})
            //-- Atualiza os campos da grid referente ao DLY
            UpdateDLY(oMDLY,cFieldID,xNewValue,@lDocApto)
            oModel:LoadValue("T1_STATUS",getStatus(IIf(lDocApto,"1","2"),"DT6"))
            oMDLY:GoLine(1)
            //--Chama Refresh da View da Grid DLY
            oView:Refresh('VGRID_DLY')
            oView:Refresh('VGRID_DT6')
        EndIf
    EndIf
    If cAction == "SETVALUE"
        If cFieldID $ "T1_RECEB|T1_DOCREC|T1_DIRIMG"
            If oMDLY:SeekLine({{"DLY_CHVCTE",cChvCte}})
                //-- Atualiza os campos da grid referente ao DLY
                UpdateDLY(oMDLY,cFieldID,xNewValue,@lDocApto)
                oModel:LoadValue("T1_STATUS",getStatus(IIf(lDocApto,"1","2"),"DT6"))
                oMDLY:GoLine(1)
                //--Chama Refresh da View da Grid DLY
                oView:Refresh('VGRID_DLY')
                oView:Refresh('VGRID_DT6')
            EndIf
        EndIf
    EndIf
    If cAction == "CANSETVALUE" .And. !lMonitora
        If cFieldID $ "T1_RECEB|T1_DOCREC|T1_DIRIMG"
            aEvtNF := getLastDLY(cChvCte)
            For nLine := 1 To Len(aEvtNF)
                If oMDLY:SeekLine(aEvtNF[nLine])
                    If oMDLY:GetValue("DLY_STATUS") $ "3|4|5"
                        lRet := .F.
                        //Help( ,, 'HELP',, STR0027,1,0) //-- ### "Existem Notas Fiscais Aguardando Retorno ou Autorizadas pela SEFAZ. O registro não poderá ser alterado."
                        oFModel:SetErrorMessage(oFModel:GetId(), cFieldID , , , , STR0027/*cMessage*/, /** cSolution */)
                        Exit
                    EndIf
                EndIf
            Next nLine
        EndIf
    EndIf
Return lRet
//--
//-- ATUALIZA OS CAMPOS RECEBEDOR, DOCUMENTO RECEBEDOR E CAMINHO IMAGEM DA GRID DLY
//--
Static Function UpdateDLY(oMDLY, cCampo, xValue, lApto)
Local nk        := 1
Local nApto     := 0
Local cFilDoc   := ''
Local cDoc      := ''
Local cSerie    := ''

For nk := 1 To oMDLY:Length()
    oMDLY:GoLine(nk)
    If !(oMDLY:GetValue("DLY_STATUS") == "5")
        Do Case
            Case cCampo == "T1_RECEB"
                oMDLY:LoadValue("DLY_RECEBE", xValue)
            Case cCampo == "T1_DOCREC"
                oMDLY:LoadValue("DLY_DOCREC", xValue)
        EndCase
    EndIf
    //+---------------------------------------------------------------------
    //| Com todos os campos(DLY_RECEBE,DLY_DOCREC e DLY_DIRIMG) preenchido
    //| 1.atualiza o flag da grid do DT6 para AZUL(Apto) 
    //| 2.Atualiza o flag da grid do DLY para Verde(Apto)
    //| 3.Atualiza o campo STATUS para '2-Apto'
    //| 4.Atualiza o tipo de envento para '1-Envio' somente se este campo estiver vazio.
    //+---------------------------------------------------------------------
    cFilDoc   := oMDLY:GetValue("DLY_FILDOC")
    cDoc      := oMDLY:GetValue("DLY_DOC")
    cSerie    := oMDLY:GetValue("DLY_SERIE")
  
    If !Empty(oMDLY:GetValue("DLY_RECEBE")) .And. !Empty(oMDLY:GetValue("DLY_DOCREC")) .And. TMAE71VImg(cFilDoc,cDoc,cSerie)
        If !(oMDLY:GetValue("DLY_STATUS") $ "345")
            oMDLY:LoadValue("T2_FLAG",getStatus("2","DLY"))
            oMDLY:LoadValue("DLY_STATUS","2")
            If Empty(oMDLY:GetValue("DLY_TIPEVE"))
                oMDLY:LoadValue("DLY_TIPEVE","1")
            EndIf
            nApto ++
        Else
            nApto ++
        EndIf
    EndIf
Next nk
lApto := (nApto == oMDLY:Length())
Return Nil

/*/{Protheus.doc} TMSAE71Val()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function TMSAE71Val(cCampo)
Local xValue  := ""
Local oModel  := FwModelActive()
Local oEntity := oModel:GetModel("MGRIDDT6")

If oEntity:getLine() > 0
    xValue := oEntity:GetValue(cCampo)
EndIf

Return xValue

/*/{Protheus.doc} ViewDef
    Menu da rotina
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
Static Function MenuDef()
Local aRotinas := {}
    
    ADD OPTION aRotinas Title STR0008 Action 'VIEWDEF.TMSAK0001' OPERATION 1 ACCESS 0	//-- "Pesquisar"
    ADD OPTION aRotinas Title STR0009 Action 'VIEWDEF.TMSAK0001' OPERATION 2 ACCESS 0	//-- "Visualizar"
    ADD OPTION aRotinas Title STR0010 Action 'VIEWDEF.TMSAK0001' OPERATION 3 ACCESS 0	//-- "Incluir"
    ADD OPTION aRotinas Title STR0011 Action 'VIEWDEF.TMSAK0001' OPERATION 6 ACCESS 0	//-- "Estornar"
    ADD OPTION aRotinas Title STR0012 Action 'VIEWDEF.TMSAK0001' OPERATION 7 ACCESS 0	//-- "Ajustar"

Return aRotinas

/**
    Executado após a ativação da view
*/
Function TMSAE71Act(oView)
      oView:HideFolder('FOLDER_GROUP_A',1,2)
      oView:HideFolder('FOLDER_GROUP_A',1,1)
Return 

Static Function AddButtons(oPanel,nAcao)

    Local lDicDNN   := AliasIndic("DNN")

	Default nAcao := 0
	
	If nAcao == 1	//-- Botões da parte superior da tela
	    @ 5,4   Button STR0013 Size 35, 12 Message '' Pixel Action {|| Tmae71Send(1) } of oPanel	//-- "Transmitir"
	    @ 5,44  Button STR0014 Size 35, 12 Message '' Pixel Action {|| Tmae71Send(2) } of oPanel	//-- "Cancelar"
	    @ 5,84  Button STR0015 Size 35, 12 Message '' Pixel Action {|| Tmae71Send(3) } of oPanel	//-- "Refresh"
        @ 5,124 Button STR0029 Size 35, 12 Message '' Pixel Action {|| Tmae71Send(4) } of oPanel	//-- "Obter XML"
    ElseIf nAcao == 2	//-- Botões da parte inferior da tela
        If lDicDNN
            @ 5,4   Button STR0051  Size 55, 12 Message '' Pixel Action {|| T71EnvIns(1) } of oPanel	//-- "Trans. Insucesso"
            @ 5,64  Button STR0052  Size 55, 12 Message '' Pixel Action {|| T71EnvIns(2) } of oPanel	//-- "Canc. Insucesso"
            @ 5,125 Button STR0055  Size 55, 12 Message '' Pixel Action {|| T71EnvIns(3) } of oPanel	//-- "Refresh Insucesso"
            @ 5,186 Button STR0029  Size 35, 12 Message '' Pixel Action {|| T71EnvIns(4) } of oPanel	//-- "Obter XML"
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} Tmae71Send()
    (Realiza a transmissão do evento de envio para 'n' registros com o status apto)
    @type  Static Function
    @author user
    @since date
    @version version
    @param nOption, Numeric, define o tipo de acao: 1-Transmissao Envio;2-Transmissao Cancelamento;3-Atualiza registros refresh de tela.
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function Tmae71Send(nOption)
 Local oModel    := FwModelActive()
 Local oMDDT6    := oModel:GetModel("MGRIDDT6")
 Local oMDDLY    := oModel:GetModel("MGRIDDLY")
 Local nj        :=  1
 Local aChvCTe_E := {} //-- para Transmissão do Comprovante
 Local aChvCTe_C := {} //-- para Transmissão de Cancelamento do Comprovante
 Local aChvCte_U := {} //-- Para update da Grid DLY 
 Local cChvCte   := Space(Len(DT6->DT6_CHVCTE))
 Local oView     := FWViewActive()
 Local nCount    := 1

 Default nOption := 1

		If nOption < 4	//-- Transmitir, Cancelar ou Refresh
	        For nj := 1 To oMDDT6:Length()
	            oMDDT6:GoLine(nj)
	            cChvCte := oMDDT6:GetValue("DT6_CHVCTE")
	            
	            //-- Somente registros marcados no cabeçalho grid DL6
	            If oMDDT6:GetValue("T1_MARK")
	
	                //+--------------------------------------------------------------------------------------------------
	                //--Posiciona no registro do DLY para verificar o tipo de evento
	                //--Notas Fiscais(DLY)
	                //+--------------------------------------------------------------------------------------------------
	                aKeyFind := getLastDLY(cChvCte) //-- obtém a sequencia de registros do DLY gerado com a maior sequencia(considera sempre o ultimo)
	                For nCount := 1 To Len(aKeyFind)
	                    If oMDDLY:SeekLine(aKeyFind[nCount])
	                        //+-----------------------------------------------------------
	                        //| Verifica se o registro é de envio e está apto
	                        //| DLY_TIPEVE == vazio ou '1'
	                        //| Inicia a transmissão do evento de comprovante de entrega.
	                        //+-----------------------------------------------------------
	                        If nOption == 1
	                            If oMDDLY:GetValue("DLY_STATUS") $ "2"
	                                Aadd(aChvCTe_E,cChvCte)
	                                EXIT
	                            EndIf
	
	                        //+--------------------------------------------------
	                        //| Verifica se o registro é de cancelamento
	                        //| DLY_TIPEVE == 2
	                        //+--------------------------------------------------
	                        ELSEIF nOption == 2
	                            If oMDDLY:GetValue("DLY_STATUS") $ "124"
	                               Aadd(aChvCTe_C,cChvCte)
	                               EXIT
	                            EndIf
	
	                        //+--------------------------------------------------
	                        //-- Se for atualização de status
	                        //+--------------------------------------------------
	                        ELSEIF  nOption == 3
	                            If oMDDLY:GetValue("DLY_TIPEVE") == "1"
	                                Aadd(aChvCTe_E,cChvCte)
	                            ELSE
	                                Aadd(aChvCTe_C,cChvCte)
	                            ENDIF
	                            EXIT
	                        //+--------------------------------------------------
	                        //-- SE DLY_STATUS FOR DIFERENTE DE 2-APTO e não foi 
	                        //-- solictado atualização de status.
	                        //+--------------------------------------------------
	                        ELSE
	                            EXIT
	                        EndIf
	                    EndIf
	                Next nCount
	
	                //-- Gera Array com as Chaves de CT-es que serão atualizados na Model Grid da DLY
	                Aadd(aChvCte_U,cChvCte)
	
	            EndIf
	
	        Next nj
        EndIf
        
        //+--------------------------------------------------------------------------------------------------
        //-- Inicia a transmissão dos comprovantes de entrega
        //+--------------------------------------------------------------------------------------------------
        If nOption == 1  //-- Envio
            If FindFunction("TMSVLDECMP")
                Processa( { |lEnd| TMSPrcCmp(aChvCTe_E) }, , STR0025, .T. ) //-- ## Transmitindo Documentos
            EndIf
        ElseIf nOption == 2 //-- Cancelamento
            If FindFunction("TMSVLDECMP")
                aRet := TMSVldECmp({},aChvCTe_C)
                If !Empty(aRet)
                    Processa( { |lEnd| TMSCanECmp(aRet,"1") }, , STR0026, .T. ) //-- ## Cancelando Evento...
				EndIf
            EndIf
        ElseIf nOption == 3 //-- Refresh usa ambos os vetores cancelados e enviados.
            If !Empty(aChvCTe_E) .Or. !Empty(aChvCTe_C)
                Processa( { |lEnd| TMSRefCmp(aChvCTe_E,aChvCTe_C) }, , STR0024, .T. )
            EndIf
		ElseIf nOption == 4	//-- Exportar XML
			TMSAE71XML(oMDDLY)
        EndIf
        //+--------------------------------------------------------------------------------------------------
        //| Atualiza os dados da grid DLY após atualização da base pelas rotinas de transmissão de eventos.
        //+--------------------------------------------------------------------------------------------------
        UpdDLYGrid(aChvCte_U)
        oView:Refresh("VGRID_DLY")

Return Nil
//---------------------------------------------------------------------------------------
/*/
{Protheus.doc} T71EnvIns()
(Realiza a transmissão do evento de envio para 'n' registros com o status apto)
@type  Static Function
@author user
@since date
@version version
@param nOption, Numeric, define o tipo de acao: 1-Transmissao Envio;
                                                2-Transmissao Cancelamento;
                                                3-Atualiza registros refresh de tela.
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------
Static Function T71EnvIns( nOption )

Local oModel    := FwModelActive()
Local oMDDT6    := oModel:GetModel("MGRIDDT6")
Local oMDDNN    := oModel:GetModel("MGRIDDNN")
Local nj        :=  1
Local aDNNC     := {} //-- Para Cancelamento da Grid DNN
Local aDNN      := {} //-- Para Transmissão da Grid DNN
Local aDNNU     := {} //-- Para Update da Grid DNN
Local cFilDoc   := ""
Local cDoc      := ""
Local cSerie    := ""
Local oView     := FWViewActive()
Local nCount    := 1
Local nPos      := 0
Local nPosC     := 0

Default nOption := 1

If nOption < 4	//-- Transmitir, Cancelar ou Refresh
    For nj := 1 To oMDDT6:Length()
        oMDDT6:GoLine(nj)
        
        cFilDoc := oMDDT6:GetValue("DT6_FILDOC")
        cDoc    := oMDDT6:GetValue("DT6_DOC")
        cSerie  := oMDDT6:GetValue("DT6_SERIE")
        
        //-- Somente registros marcados no cabeçalho grid DL6
        If oMDDT6:GetValue("T1_MARK") .AND. oMDDT6:GetValue("T1_STTS2") == "BR_AZUL_OCEAN"
            
            For nCount := 1 To oMDDNN:Length()
                If oMDDT6:GetValue("T1_MARK") 
                    
                    If nOption == 1
                        If Len(aDNN) > 0
                            nPos := AScan( aDNN, {|x| x[1]+x[2]+x[3] == cFilDoc + cDoc + cSerie })
                        EndIf
                        If (oMDDNN:GetValue("DNN_STATUS") $ "2|5") .OR. (oMDDNN:GetValue("DNN_SEQEVE") = "02" .AND. oMDDNN:GetValue("DNN_STATUS") = "4" ) .AND. (nPos == 0 .Or. Len(aDNN) == 0 )
                            Aadd( aDNN, { cFilDoc, cDoc, cSerie } )
                        EndIf
                    //+--------------------------------------------------
                    //| Verifica se o registro é de cancelamento
                    //| DNN_SEQEVE == 2
                    //+--------------------------------------------------
                    ElseIf nOption == 2 
                        If Len(aDNNC) > 0
                            nPosC := AScan( aDNNC, {|x| x[1]+x[2]+x[3] == cFilDoc + cDoc + cSerie })
                        EndIf

                        If oMDDNN:GetValue("DNN_STATUS") = "4" .AND. (nPosC == 0 .Or. Len(aDNNC) == 0 )
                            Aadd( aDNNC, { cFilDoc, cDoc, cSerie } )
                            Exit
                        EndIf

                    //+--------------------------------------------------
                    //-- Se for atualização de status
                    //+--------------------------------------------------
                    ElseIf nOption == 3
                        If Len(aDNN) > 0
                            nPos := AScan( aDNN, {|x| x[1]+x[2]+x[3] == cFilDoc + cDoc + cSerie })
                        EndIf
                       
                        If oMDDNN:GetValue("DNN_STATUS") $ "3|5" .AND. (nPos == 0 .Or. Len(aDNN) == 0 )
                            Aadd( aDNN, { cFilDoc, cDoc, cSerie } )
                        EndIf

                    EndIf
                EndIf
            Next nCount

            //-- Gera Array com as Chaves de CT-es que serão atualizados na Model Grid da DLY
            Aadd( aDNNU, { cFilDoc, cDoc, cSerie } )

        EndIf

    Next nj
EndIf

//---------------------------------------------------
// Inicia a transmissão dos eventos de insucesso
//---------------------------------------------------
If nOption == 1  // Envio
    If Len(aDNN) > 0
        Processa( { |lEnd| TMSPrcIns( aDNN, "1", nOption ) }, , STR0025, .T. ) // ## Transmitindo Documentos
    EndIf
ElseIf nOption == 2 //-- Cancelamento
    If Len(aDNNC) > 0
        Processa( { |lEnd| TMSPrcIns( aDNNC, "2", nOption ) }, , STR0026, .T. ) // ## Cancelando Evento
    EndIf
ElseIf nOption == 3 //-- Refresh usa ambos os vetores cancelados e enviados.
    If Len(aDNN) > 0 
        Processa( { |lEnd| TMSPrcIns( aDNN, "1", nOption ) }, , STR0024, .T. )
    EndIf
ElseIf nOption == 4	//-- Exportar XML
    TMSAE71INS(oMDDNN)
EndIf

// Atualiza os dados da grid DNN após atualização da base pelas rotinas de transmissão de eventos.
UpdDNNGrid(aDNNU)
oView:Refresh("VGRID_DNN")

Return Nil

//----------------------------------------------------
/*/ {Protheus.doc} DataSetRes(oModel)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
//----------------------------------------------------

Static Function DataSetRes(oModel,cQuery,cAlias)
 Local aResult    := {}
 Local aliasTB    := GetNextAlias()
 Local nLine      := 0
 Local nTotFields := 0
 Local nCampo     := 1
 Local cRecebe    := Space(TamSx3("DLY_RECEBE")[1])
 Local cDocRec    := Space(TamSx3("DLY_DOCREC")[1])
 Local cDirImg    := Space(10)
 Local aRecebe    := {}
 Local lDicDNN   := AliasIndic("DNN")

 If ValType(oModel) == "O"
      oStructDb   := oModel:GetStruct()
      aCampos     := aClone(oStructDb:GetFields())
      nTotFields  := Len(aCampos)
 Else
     Return aResult
 EndIf

//+--------------------------------------------------------
//| Load dos Campos
//+--------------------------------------------------------
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aliasTB,.T.,.F.)

TcSetField(aliasTB,"DT6_DATEMI","D",8,0)
TcSetField(aliasTB,"DT6_DATENT","D",8,0)

While((aliasTB)->(!EOF()))
     nLine += 1
     AADD(aResult,{nLine,Array(nTotFields)})
     aRecebe := dadosReceb((aliasTB)->DT6_CHVCTE)
     cRecebe := aRecebe[1]
     cDocRec := aRecebe[2]
     cDirImg := aRecebe[3]

     //+----------------------------------------------------------------------------------
     //-- Set os valores de cada campo da linha adicionada ao modelo
     //+----------------------------------------------------------------------------------
     For nCampo := 1 To nTotFields
            If !aCampos[nCampo][MODEL_FIELD_VIRTUAL]
                If aCampos[nCampo,MODEL_FIELD_IDFIELD] == "T1_MARK"
                    aResult[nLine,2,nCampo] := .F.
                Else
                    aResult[nLine,2,nCampo] := (aliasTB)->&(aCampos[nCampo,MODEL_FIELD_IDFIELD])
                EndIf
            Else
                If aCampos[nCampo,MODEL_FIELD_IDFIELD] $ "DT6_NOMEXP"
                    aResult[nLine,2,nCampo] := (aliasTB)->DT6_NOMEXP

                ElseIf aCampos[nCampo,MODEL_FIELD_IDFIELD] $ "DT6_NOMREM"
                    aResult[nLine,2,nCampo] := (aliasTB)->DT6_NOMREM

                ElseIf aCampos[nCampo,MODEL_FIELD_IDFIELD] == "T1_STATUS"
                    If Empty(cRecebe) .Or. Empty(cDocRec) .Or. Empty(cDirImg)
                        aResult[nLine,2,nCampo] := getStatus("2","DT6") //--Nao esta Apto
                    Else
                        aResult[nLine,2,nCampo] := getStatus((aliasTB)->T1_STATUS,"DT6")
                    EndIf
                ElseIf lDicDNN .AND. aCampos[nCampo,MODEL_FIELD_IDFIELD] == "T1_STTS2"
                    aResult[nLine,2,nCampo] := getStatus((aliasTB)->T1_STTS2,"DT6I")

                ElseIf aCampos[nCampo,MODEL_FIELD_IDFIELD] $ "T1_RECEB"
                    aResult[nLine,2,nCampo] := cRecebe

                ElseIf aCampos[nCampo,MODEL_FIELD_IDFIELD] $ "T1_DOCREC"
                    aResult[nLine,2,nCampo] := cDocRec

                ElseIf aCampos[nCampo,MODEL_FIELD_IDFIELD] $ "T1_DIRIMG"
                    aResult[nLine,2,nCampo] := cDirImg

                Else
                    aResult[nLine,2,nCampo] := CriaVar(aCampos[nCampo,MODEL_FIELD_IDFIELD],.F.)
                EndIf
            EndIf
     Next nCampo             
    ((aliasTB))->(DbSKip())
EndDo
(aliasTB)->(DbCloseArea())

Return aResult

Static Function LdDataSet(oGridModel,cAlias,lOwnerIsGrid)
Local aResult  := {}
Local oGdOwner := Nil
Local nLnOwner := 1

    If lOwnerIsGrid
        oGdOwner := oGridModel:getOwner()
        nLnOwner := oGdOwner:GetLine()
    EndIf
    aResult  := DataSetRes(oGridModel,queryDT6(),"DT6")

Return aResult

/*/{Protheus.doc} QueryDT6()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function QueryDT6()
Local cResult  := ""
Local dDataDe  := CTOD("") //-- Data de Entrega/Mesmo da Ocorrencia
Local dDataAte := Date()   //-- Data de Entrega/Mesmo da Ocorrencia
Local cCampos := "DT6.DT6_FILDOC,DT6.DT6_DOC,DT6.DT6_SERIE,DT6.DT6_CLIREM,DT6.DT6_LOJREM,A1REM.A1_NOME DT6_NOMREM,DT6.DT6_CLIEXP,DT6.DT6_LOJEXP," +;
					" A1EXP.A1_NOME DT6_NOMEXP,DT6.DT6_DATEMI,DT6.DT6_DATENT,DT6.DT6_CHVCTE,DT6.DT6_RETCTE"
Local lDNN     := AliasInDic("DNN")

If Type("MV_PAR07") == "U"
    Private MV_PAR07 := 1
EndIf
If type("lInTmsa360") == "U"
    Private lInTmsa360 := .F.
EndIf

If lDeFora
	TMSCmpGrv(Iif(IsInCallStack("TMSAF76"),2,1),;
			  Iif(IsInCallStack("TMSAF76"),"",DTQ->DTQ_FILORI),;
			  Iif(IsInCallStack("TMSAF76"),"",DTQ->DTQ_VIAGEM),;
			  cAlias,aAgends)
EndIf

//------------------------------------------------------------------------------------
//-- Proteção dos parametros de pergunte para quando vazio
//------------------------------------------------------------------------------------
MV_PAR01 := IIF(!EMPTY(MV_PAR01),MV_PAR01,Space(GetSx3Cache("A1_COD" ,"X3_TAMANHO")))
MV_PAR02 := IIF(!EMPTY(MV_PAR02),MV_PAR02,Space(GetSx3Cache("A1_LOJA","X3_TAMANHO")))
MV_PAR03 := IIF(!EMPTY(MV_PAR03),MV_PAR03,Replicate("Z",GetSx3Cache("A1_COD","X3_TAMANHO")))
MV_PAR04 := IIF(!EMPTY(MV_PAR04),MV_PAR04,Replicate("Z",GetSx3Cache("A1_LOJA","X3_TAMANHO")))
dDataDe  := IIF(!EMPTY(MV_PAR05),MV_PAR05,dDataDe )
dDataAte := IIF(!EMPTY(MV_PAR06),MV_PAR06,dDataAte)
        
cResult := "SELECT DISTINCT " + cCampos 
cResult += ","

cResult += "  CASE "
cResult += "    WHEN "
cResult += "	(SELECT COUNT(1) QUANTIDADE "
cResult += "     FROM " + RetSqlName("DLY") + " DLY2 "
cResult += "	  WHERE DLY2.DLY_FILIAL = '" + xFilial("DLY") + "' "
cResult += "      AND DLY2.DLY_CHVCTE = DT6.DT6_CHVCTE "
cResult += "	AND DLY2.R_E_C_N_O_ = (SELECT MAX(DLY3.R_E_C_N_O_) ULTIMO "
cResult += "	     FROM " + RetSqlName("DLY") + " DLY3 "
cResult += "	WHERE DLY3.DLY_FILIAL = '" +xFilial("DLY") + "' "
cResult += "	  AND DLY3.DLY_CHVCTE = DT6.DT6_CHVCTE "
cResult += "	  AND DLY3.DLY_CLIREM = DLY2.DLY_CLIREM "
cResult += "	  AND DLY3.DLY_LOJREM = DLY2.DLY_LOJREM "
cResult += "	  AND DLY3.DLY_NUMNFC = DLY2.DLY_NUMNFC "
cResult += "	  AND DLY3.DLY_SERNFC = DLY2.DLY_SERNFC "
cResult += "	  AND DLY3.DLY_EMINFC = DLY2.DLY_EMINFC "
cResult += "	  AND DLY3.D_E_L_E_T_ = ' ') "
cResult += "	  AND (DLY2.DLY_STATUS <> '2' OR "
cResult += "          (DLY2.DLY_RECEBE = ' ' "
cResult += "           OR DLY2.DLY_DOCREC = ' ' "
cResult += " ))	AND DLY2.D_E_L_E_T_ = ' ') > 0 "
cResult += "	THEN "
cResult += "	'2' "
cResult += "	ELSE "
cResult += "	'1' "
cResult += "  END AS T1_STATUS "

If lDNN
    cResult += ","
    cResult += " CASE "
    cResult +=      " WHEN "
    cResult +=              " ( SELECT COUNT(1) QUANTIDADE "
    cResult +=                  " FROM " + RetSqlName("DNN") + " DNN2 "
    cResult +=                  " WHERE DNN2.DNN_FILIAL = '" + FWxFilial("DNN") + "' "
    cResult +=                    " AND DNN2.DNN_FILDOC = DT6.DT6_FILDOC "
    cResult +=                    " AND DNN2.DNN_DOC = DT6.DT6_DOC "
    cResult +=                    " AND DNN2.DNN_SERIE = DT6.DT6_SERIE "
    cResult +=                    " AND ( DNN2.DNN_STATUS IN ('2','3','4') AND "
    cResult +=                          " DNN2.DNN_EXTENS <> ' ' "
    cResult +=                          ") "
    cResult +=                    " AND DNN2.D_E_L_E_T_ = ' ') > 0 "
    cResult +=      " THEN "
    cResult +=              " '1' "
    cResult +=      " ELSE "
    cResult +=              " '2' "
    cResult += " END AS T1_STTS2 "
EndIf

cResult += " FROM " + RetSqlName("DT6") + " DT6 "

cResult += " LEFT JOIN " + RetSqlName("DM0") + " DM0 "
cResult +=      " ON DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
cResult +=          " AND DM0.DM0_FILDOC = DT6.DT6_FILDOC "
cResult +=          " AND DM0.DM0_DOC = DT6.DT6_DOC "
cResult +=          " AND DM0.DM0_SERIE = DT6.DT6_SERIE "
cResult +=          " AND DM0.D_E_L_E_T_ = ' ' "

cResult += " LEFT JOIN " + RetSqlName("DLY") + " DLY1 "
cResult +=          " ON DLY1.DLY_FILIAL = '" + xFilial("DLY") + "' "
cResult +=              " AND DLY1.DLY_CHVCTE = DT6.DT6_CHVCTE "
cResult +=              " AND DLY1.D_E_L_E_T_ = ' ' "

If lDNN
    cResult += " LEFT JOIN " + RetSqlName("DNN") + " DNN "
    cResult +=          " ON DNN.DNN_FILIAL = '" + xFilial("DNN") + "' "
    cResult +=              " AND DNN.DNN_FILDOC = DT6.DT6_FILDOC "
    cResult +=              " AND DNN.DNN_DOC = DT6.DT6_DOC "
    cResult +=              " AND DNN.DNN_SERIE = DT6.DT6_SERIE "
    cResult +=              " AND DNN.D_E_L_E_T_ = ' ' "
EndIf

cResult += " INNER JOIN " + RetSqlName("SA1") + " A1REM "
cResult +=      " ON A1REM.A1_COD  = DT6.DT6_CLIREM "
cResult +=          " AND A1REM.A1_FILIAL = '" + xFilial("SA1") + "' "
cResult +=          " AND A1REM.A1_LOJA = DT6.DT6_LOJREM "
cResult +=          " AND A1REM.D_E_L_E_T_ = ' ' "

cResult += " LEFT JOIN " + RetSqlName("SA1") + " A1EXP "
cResult +=      " ON A1EXP.A1_COD  = DT6.DT6_CLIEXP "
cResult +=          " AND A1EXP.A1_FILIAL = '" + xFilial("SA1") + "' "
cResult +=          " AND A1EXP.A1_LOJA = DT6.DT6_LOJEXP "
cResult +=          " AND A1EXP.D_E_L_E_T_ = ' ' "

If lInTmsa360 .And. !lDeFora
    cResult += "  LEFT JOIN " + RetSqlName("DUA") + " DUA ON "
    cResult += "  DUA.D_E_L_E_T_ = ' ' "
    cResult += "  AND DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
    cResult += "  AND DUA.DUA_FILDOC = DT6.DT6_FILDOC "
    cResult += "  AND DUA.DUA_DOC    = DT6.DT6_DOC "
    cResult += "  AND DUA.DUA_SERIE  = DT6.DT6_SERIE "
EndIf

If lDeFora
	cResult += " JOIN " + cTableName + " "
	cResult += "   ON TRB_FILDOC = DT6.DT6_FILDOC "
	cResult += "  AND TRB_DOC    = DT6.DT6_DOC "
	cResult += "  AND TRB_SERIE  = DT6.DT6_SERIE "
EndIf

cResult += "WHERE DT6_FILIAL = '" + xFilial("DT6")+ "' "
cResult +=  " AND DT6.DT6_FILDOC =  '"+Alltrim(cFilAnt)+"'"
cResult +=  " AND DT6.DT6_SERIE <> 'COL' "
cResult +=  " AND DT6.DT6_CHVCTE <> ' ' "
cResult +=  " AND DT6.D_E_L_E_T_ = ' ' "

If lInTmsa360 .And. !lDeFora
    cResult += "  AND DUA.DUA_FILOCO BETWEEN '" + aParam[1] + "' AND '" + aParam[2] + "' "
    cResult += "  AND DUA.DUA_NUMOCO BETWEEN '" + aParam[3] + "' AND '" + aParam[4] + "' "
Else
	If !lDeFora
	    cResult += " AND DT6.DT6_CLIREM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' "
	    cResult += " AND DT6.DT6_LOJREM BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' "
        cResult += " AND (DT6.DT6_DATENT BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' OR DT6.DT6_DATEMI BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' ) "
	    //--
	    //-- Se Status informado for 1-Apto ou 2-Inapto insere clausula para busca dos dados.
	    If (MV_PAR07-1) > 0
	        cResult += " AND ( "
            cResult +=          " ( "
            cResult +=              " ( "
            cResult +=                  " CASE WHEN ( "
	        cResult +=                              " SELECT COUNT(1) QUANTIDADE
	        cResult +=                              " FROM " + RetSqlName("DLY") + " DLY2 "
	        cResult +=                              " WHERE DLY2.DLY_FILIAL = '" + xFilial("DLY") + "' "
	        cResult +=                                " AND DLY2.DLY_CHVCTE = DT6.DT6_CHVCTE "
	        cResult +=                                " AND DLY2.R_E_C_N_O_ = ( "
	        cResult +=                                                          " SELECT MAX(DLY3.R_E_C_N_O_) ULTIMO "
	        cResult +=                                                          " FROM " + RetSqlName("DLY") + " DLY3 "
	        cResult +=                                                          " WHERE DLY3.DLY_FILIAL = '" + xFilial("DLY") + "' "
	        cResult +=                                                              " AND DLY3.DLY_CHVCTE = DT6.DT6_CHVCTE "
	        cResult +=                                                              " AND DLY3.DLY_CLIREM = DLY2.DLY_CLIREM "
	        cResult +=                                                              " AND DLY3.DLY_LOJREM = DLY2.DLY_LOJREM "
	        cResult +=                                                              " AND DLY3.DLY_NUMNFC = DLY2.DLY_NUMNFC "
	        cResult +=                                                              " AND DLY3.DLY_SERNFC = DLY2.DLY_SERNFC "
	        cResult +=                                                              " AND DLY3.DLY_EMINFC = DLY2.DLY_EMINFC "
	        cResult +=                                                              " AND DLY3.D_E_L_E_T_ = ' ' "
            cResult +=                                                       " ) "
	        cResult +=                                " AND DLY2.DLY_STATUS <> '2' "
	        cResult +=                                " AND DLY2.D_E_L_E_T_ = ' ' "
            cResult +=                             " ) > 0 THEN '2' ELSE '1' END "
            cResult +=              " ) = '" + AllTrim( Str( MV_PAR07 - 1 ) ) + "' "
            cResult +=           " ) "
            
            If lDNN
                cResult +=    " OR ( "
                cResult +=          " ( "
                cResult +=              " CASE WHEN ( "
                cResult +=                          " SELECT COUNT(1) QUANTIDADE "
                cResult +=                          " FROM " + RetSqlName("DNN") + " DNN2 "
                cResult +=                          " WHERE	DNN2.DNN_FILIAL = '  ' "
                cResult +=                              " AND DNN2.DNN_FILDOC = DT6.DT6_FILDOC "
                cResult +=                              " AND DNN2.DNN_DOC = DT6.DT6_DOC "
                cResult +=                              " AND DNN2.DNN_SERIE = DT6.DT6_SERIE "
                cResult +=                              " AND (DNN2.DNN_STATUS <> '2' AND DNN2.DNN_EXTENS = ' ' ) "
                cResult +=                              " AND DNN2.D_E_L_E_T_ = ' ' "
                cResult +=                         " )  > 0 THEN '2' ELSE '1' END "
                cResult +=           " ) = '" + AllTrim( Str( MV_PAR07 - 1 ) ) + "' "
                cResult +=        " ) "
            EndIf
            cResult +=      " ) "
	    EndIf
	EndIf
EndIf

cResult := ChangeQuery(cResult)

Return cResult


Static Function getCampos(cAlias)
Local cCampos := ""

    IF cAlias == "DT6"
        cCampos := "DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_CLIREM,DT6_LOJREM,DT6_NOMREM,DT6_CLIEXP,DT6_LOJEXP,DT6_NOMEXP,DT6_DATEMI,DT6_DATENT,DT6_CHVCTE,DT6_RETCTE,DT6_RECEB, DT6_DIRIMG"
    EndIf
Return cCampos

/*/{Protheus.doc} AddCFields()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function AddCFields(oForm,nTipo,cTbl)
Local lDicDNN   := AliasIndic("DNN")
default nTipo      := 1
    oForm:DeActivate()
    If cTbl == "DT6"
        //-- Modelo
        If nTipo == 1
            If lMonitora
                oForm:AddField("T1_MARK"  ,"" ,"T1_MARK"  ,"L",1                                     , 0, {|| TMAE71Mrk1()},{|| .T. } ,{}  ,    ,FwBuildFeature(STRUCT_FEATURE_INIPAD,".T.")  ,    ,    ,.F.)
            EndIf
            oForm:AddField("T1_STATUS"," ","T1_STATUS","C", 20, 0, NIL, NIL, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD,"2"), .F. ,.F. ,.T.)
            If lDicDNN
                oForm:AddField("T1_STTS2"," ","T1_STTS2","C", 20, 0, NIL, NIL, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD,"2"), .F. ,.F. ,.T.)
            EndIf
            oForm:AddField("T1_RECEB" ," ","T1_RECEB" ,"C"   , getSx3Cache("DLY_RECEBE","X3_TAMANHO"), 0, NIL, { |oModel| TAE71WHEN('T1_RECEB') }       ,NIL ,.F. ,NIL ,.F. ,.F. ,.T.)
            oForm:AddField("T1_DOCREC"," ","T1_DOCREC","C"   , getSx3Cache("DLY_DOCREC","X3_TAMANHO"), 0, NIL, { |oModel| TAE71WHEN('T1_DOCREC') }       ,NIL ,.F. ,NIL ,.F. ,.F. ,.T.)
            oForm:AddField("T1_DIRIMG"," ","T1_DIRIMG","C"   , 10, 0, NIL              ,{|| .F. }, NIL ,.F. ,NIL ,.F. ,.F. ,.T.)
        Else         // View
            If lMonitora
                oForm:AddField("T1_MARK"  ,"01"," "         ,"T1_MARK",, "@BMP")
            EndIf
            oForm:AddField("T1_STATUS","01" ,STR0047   ," " ,  , "GET","@BMP", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )	//-- "Status Compr. Entrega"
            If lDicDNN
                oForm:AddField("T1_STTS2","02"  ,STR0048   ," " ,  , "GET","@BMP", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )	//-- "Status Insucesso"
            EndIf
            oForm:AddField("T1_RECEB" ,"091",FWX3Titulo("DLY_RECEBE")," " ,  ,"C" ,"@!"  , NIL, NIL, , NIL, NIL, NIL, NIL, NIL, .T. )
            oForm:AddField("T1_DOCREC","092", FWX3Titulo("DLY_DOCREC")," " ,  ,"C" ,"@!"  , NIL, NIL, , NIL, NIL, NIL, NIL, NIL, .T. )
            oForm:AddField("T1_DIRIMG","093", FWX3Titulo("DM0_IMAGEM")," " , ,"M" ,"@!"  , NIL, NIL, , NIL, NIL, NIL, NIL, NIL, .T. )
        EndIf

    ElseIf cTbl == "DLY"
        If nTipo == 1 // Modelo
            If lMonitora
                oForm:AddField("T2_MARK" ,"","T2_MARK", "L", 1, 0, {|| .T. }, {|| .T. } ,NIL ,.F. ,FwBuildFeature(STRUCT_FEATURE_INIPAD,".F."),.F. ,.F. ,.F.)
            EndIf
            //    AddField(cTitulo,     cTooltip,  cIdField, cTipo , nTamanho, nDecimal,    bValid, bWhen, aValues, lObrigat,                                                           bInit, lKey, lNoUpd, lVirtual, cValid )
            oForm:AddField("T2_FLAG",         "", "T2_FLAG",    "C",       20,        0, {|| .T. },      ,        ,      .F., FwBuildFeature(STRUCT_FEATURE_INIPAD,"TMAE71Ini('DLY_STATUS')"), .F., .F.,      .T.,        )
            oForm:AddField("DLY_RECNO",       "","DLY_RECNO",   "N",       20,        0, {|| .T. },      ,        ,      .F., FwBuildFeature(STRUCT_FEATURE_INIPAD,"TMAE71Ini('RECNO')"     ), .F., .F.,      .T.,        )
        Else
            If lMonitora
                oForm:AddField("T2_MARK"  ,"01", " "     ," " ,  ,"L" ,"@BMP", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )
            EndIf
            //    AddField( cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine, nWidth )
            oForm:AddField("T2_FLAG",   "01",     " ",      " ",      ,   "C",   "@BMP",      NIL,     NIL,        .F.,     NIL,    NIL,          NIL,          NIL,      NIL,      .T.,         ,            ,        )
            oForm:AddField("DLY_RECNO", "99",     " ",      " ",      ,   "N","9999999999",   NIL,     NIL,        .F.,     NIL,    NIL,          NIL,          NIL,      NIL,      .T.,         ,            ,        )
        EndIf
    ElseIf cTbl == "DNN"
        If nTipo == 1 // Modelo
            If lMonitora
                oForm:AddField( "T3_MARK",      "", "T3_MARK",  "L", 1,     0, { || .T. }, { || .T. },  NIL,    .F., FwBuildFeature( STRUCT_FEATURE_INIPAD, ".F." ),                    .F., .F., .F.)
            EndIf
            oForm:AddField(     "T3_FLAG",      "", "T3_FLAG",  "C", 20,    0, {|| .T. },           ,       ,   .F., FwBuildFeature( STRUCT_FEATURE_INIPAD, "TMAE71Ini('DNN_STATUS')"), .F., .F., .T. )
            oForm:AddField(     "T3_DIRIMG",    " ","T3_DIRIMG","C", 10,    0,      NIL, { || .F. },    NIL,    .F., FwBuildFeature( STRUCT_FEATURE_INIPAD, "TMAE71Ini('T3_DIRIMG')"),  .F., .F., .T. )
        Else
            If lMonitora
                oForm:AddField("T3_MARK"  ,"01", " "     ," " ,  ,"L" ,"@BMP", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )
            EndIf
            oForm:AddField( "T3_FLAG", "01", " ", " ", , "C", "@BMP", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )
            oForm:AddField( "T3_DIRIMG", "16", FWX3Titulo("DNN_IMAGEM"), " ", , "M", "@!", NIL, NIL, , NIL, NIL, NIL, NIL, NIL, .T. )
        EndIf
    EndIf
    oForm:Activate()

Return Nil

Static Function TMSAE71Ord(oStru,cTbl)
Local cOrdem := If(lMonitora,"T1_MARK,","")+"T1_STATUS,T1_RECEB,T1_DOCREC,T1_DIRIMG,DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_CLIREM,DT6_LOJREM,DT6_NOMREM,DT6_CLIEXP,DT6_LOJEXP,DT6_NOMEXP,DT6_DATEMI,DT6_DATENT,DT6_CHVCTE,DT6_RETCTE"
Local aOrdem := Strtokarr2( cOrdem,",",.F.)
Local ni     := 1

    If cTbl == "DT6"
        For ni := 1 To Len(aOrdem)
            oStru:SetProperty( aOrdem[ni] , MVC_VIEW_ORDEM, StrZero(ni,2))
            If aOrdem[ni] == "T1_MARK"
                oStru:SetProperty(aOrdem[ni],MVC_VIEW_CANCHANGE,.T.)
            ElseIf aOrdem[ni] $ "T1_RECEB|T1_DIRIMG|T1_DOCREC" .And. !lMonitora
                oStru:SetProperty(aOrdem[ni],MVC_VIEW_CANCHANGE,.T.)
            Else
                oStru:SetProperty(aOrdem[ni],MVC_VIEW_CANCHANGE,.F.)
            EndIf
        Next ni
    
    ElseIf cTbl == "DLY"
        If lMonitora
            oStru:SetProperty( "T2_MARK" , MVC_VIEW_ORDEM, "01")
            oStru:SetProperty( "T2_MARK" , MVC_VIEW_CANCHANGE,.T.)
        EndIf
    ElseIf cTbl == "DNN"
        If lMonitora
            oStru:SetProperty( "T3_MARK" , MVC_VIEW_ORDEM, "01")
            oStru:SetProperty( "T3_MARK" , MVC_VIEW_CANCHANGE,.T.)
        EndIf
        oStru:SetProperty( "T3_FLAG", MVC_VIEW_ORDEM, "01" )
        oStru:SetProperty( "DNN_STATUS", MVC_VIEW_ORDEM, "02" )
        oStru:SetProperty( "DNN_EXTENS", MVC_VIEW_ORDEM, "16" )
    EndIf

Return Nil

/*/{Protheus.doc}  gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView)

If cFieldName == "T1_DIRIMG" 
    TMSAE71Img()
ElseIf cFieldName == "T3_DIRIMG"
    TMSAE71Img( , , , .T. )
EndIf

Return .T.

/*/{Protheus.doc} TMAE71Mrk1
    (Evento de Marca ou Desmarca da linha da grid de Documentos de Transporte)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function TMAE71Mrk1(cCampo)

Local lResult   := .T.
Local oView     := FWViewActive()
Local oModel    := FwModelActive()
Local oMGridDT6 := oModel:GetModel("MGRIDDT6")
Local oMGridDLY := oModel:GetModel("MGRIDDLY")
Local oMGridDNN := Nil
Local lMark     := .F.
Local aSaveLine := FWSaveRows()
Local nK        := 1
Local lDicDNN   := AliasIndic("DNN")

Default cCampo  := ""

    lMark := oMGridDT6:GetValue("T1_MARK")
    
    For nK := 1 To oMGridDLY:Length()
        oMGridDly:GoLine(nK)
        If oMGridDly:GetValue("DLY_RECNO") > 0
            oMGridDLY:LoadValue("T2_MARK",lMark)
        EndIf
    Next nK

    oMGridDly:GoLine(1)

    If lDicDNN
        oMGridDNN   := oModel:GetModel("MGRIDDNN")
        If !oMGridDNN:IsEmpty()
            For nK := 1 To oMGridDNN:Length()
                oMGridDNN:GoLine(nK)
                
                oMGridDNN:LoadValue("T3_MARK", lMark )
            Next nK
        EndIf
        oMGridDNN:GoLine(1)
        oView:Refresh('VGRID_DNN')
    EndIf

oView:Refresh('VGRID_DLY')

FWRestRows(aSaveLine)
Return lResult

/*/{Protheus.doc} T71DT6Chl()
    (Função para inicialização de campos)
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
Static Function T71DT6ChL( oView, cViewId )

Local lRet      := .T.
Local oModel    := FwModelActive()
Local oMDLY     := oModel:GetModel("MGRIDDLY")
Local oMDDT6    := oModel:GetModel("MGRIDDT6")
Local oMDNN     := Nil
Local cStatus   := ""
Local nY        := 0
Local lImagem   := .F.

Default oView := FwViewActive()
Default cViewId:= ""

If cViewId == 'MGRIDDT6'
    cStatus := oMDLY:GetValue("DLY_STATUS")
    If oMDLY:GetValue("DLY_RECNO") > 0
        If cStatus == "1"
            If !Empty(oMDLY:GetValue("DLY_RECEBE")) .And. !Empty(oMDLY:GetValue("DLY_DOCREC"))
                oMDLY:LoadValue("T2_FLAG",getStatus("2","DLY"))
                oMDLY:LoadValue("DLY_STATUS","2")
            Else
                oMDLY:LoadValue("T2_FLAG",getStatus("1","DLY"))
                oMDLY:LoadValue("DLY_STATUS","1")
            EndIf
        Else
            oMDLY:LoadValue("T2_FLAG",getStatus(cStatus,"DLY"))
        EndIf
    EndIf    
    oView:Refresh("VGRID_DLY")

ElseIf cViewId == 'VGRID_DNN'
    
    oMDNN   := oModel:GetModel("MGRIDDNN")

    For nY := 1 To oMDNN:Length()
        oMDNN:GoLine(nY)
        cStatus := oMDNN:GetValue("DNN_STATUS")
        lImagem := !Empty(oMDNN:GetValue("DNN_EXTENS")) .AND. !Empty(oMDNN:GetValue("DNN_EXTENS"))
        
        If cStatus $ (" |1|2")
            If ( ( oMDNN:GetValue("DNN_TIPINS") == '4' .AND. !Empty(oMDNN:GetValue("DNN_JUSTIF")) .AND. lImagem ) .OR. ( oMDNN:GetValue("DNN_TIPINS") <> '4' .AND. lImagem ) )
                oMDNN:LoadValue( "DNN_STATUS", "2" )
                cStatus := "2"

                oMDDT6:LoadValue("T1_STTS2", getStatus("1","DT6") ) //--APTO no status de insucesso dos documentos
                oView:Refresh("VGRID_DT6")

            Else
                oMDNN:LoadValue( "DNN_STATUS","1")
                cStatus := "1"

                oMDDT6:LoadValue("T1_STTS2", getStatus("2","DT6") ) //--NAO APTO no status de insucesso do documento
                oView:Refresh("VGRID_DT6")

            EndIf
        EndIf
        oMDNN:LoadValue( "T3_FLAG", getStatus( cStatus, "DNN" ) )
    Next nY
    
    oView:Refresh("VGRID_DNN")

EndIf
    
Return lRet

/*/{Protheus.doc} getStatus(cStatus)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getStatus(cStatus,cAlias)
 Local cResult := ""
 Local aStatus := {}
 Local nPos    := 0

    If cAlias == "DT6" .OR. cAlias == "DT6I"
        
        AADD(aSTATUS,{"1","BR_AZUL_OCEAN"    }) //- AUTENTICACAO COMPLETA DO ENVIO
        AADD(aSTATUS,{"2","BR_VERMELHO_OCEAN"}) //- REGISTROS COM DIVERGENCIAS OU NAO APTOS PARA TRANSMISSAO
        // AADD(aSTATUS,{"1","BR_VERDE_OCEAN"   }) 
        // AADD(aSTATUS,{"3","BR_AMARELO_OCEAN" }) 
        // AADD(aSTATUS,{"4","BR_LARANJA_OCEAN" }) 
        // AADD(aSTATUS,{"6","BR_CINZA_OCEAN"   }) 
        // AADD(aSTATUS,{"7","BR_MARRON_OCEAN"  }) 
        // AADD(aSTATUS,{"8","BR_PINK_OCEAN"    }) 
        // AADD(aSTATUS,{"9","BR_CANCEL_OCEAN"  }) 
        // AADD(aSTATUS,{"A","BR_BRANCO_OCEAN"  }) 
        // AADD(aSTATUS,{"B","PMSEDT4_OCEAN"    }) 
        // AADD(aSTATUS,{"C","PMSEDT3_OCEAN"    }) 
        // AADD(aSTATUS,{"D","PMSEDT1_OCEAN"    }) 

    ElseIf cAlias == "DLY"
        AADD(aSTATUS,{"0","BR_LARANJA"})        //-- 0-Integração meu check-list
        AADD(aSTATUS,{"1","BR_VERMELHO_OCEAN"}) //-- 1-NAO APTO
        AADD(aSTATUS,{"2","BR_VERDE_OCEAN"   }) //-- 2-APTO
        AADD(aSTATUS,{"3","BR_AMARELO_OCEAN" }) //-- 3-ENVIDADO
        AADD(aSTATUS,{"4","BR_AZUL_OCEAN"    }) //-- 4-AUTENTICADO
        AADD(aSTATUS,{"5","BR_PRETO_OCEAN"   }) //-- 5-REJEITADO
    ElseIf cAlias == "DNN"
        //AADD(aSTATUS,{"0","BR_LARANJA"})        //-- 0-Integração meu check-list
        AADD(aSTATUS,{"1","BR_VERMELHO_OCEAN"}) //-- 1-NAO APTO
        AADD(aSTATUS,{"2","BR_VERDE_OCEAN"   }) //-- 2-APTO
        AADD(aSTATUS,{"3","BR_AMARELO_OCEAN" }) //-- 3-ENVIDADO
        AADD(aSTATUS,{"4","BR_AZUL_OCEAN"    }) //-- 4-AUTENTICADO
        AADD(aSTATUS,{"5","BR_PRETO_OCEAN"   }) //-- 5-REJEITADO
    EndIf

    If (nPos:=AScan(aStatus,{|y| y[1] == Upper(cStatus)})) > 0
        cResult := aStatus[nPos][2]
    EndIf

Return cResult

/*/{Protheus.doc} Tmae71Ups(oForm,)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMAE71Leg(cAlias)
 Local aLegenda := {}
 Local cTitulo  := STR0001
 
 Default cAlias := ""

    If cAlias == "DT6"
        aLegenda := {{ "BR_VERMELHO"	, STR0017 },;	//-- "Não Apto."
                     { "BR_AZUL"		, STR0018 }}    //-- "Aptos para envio."
    ElseIf cAlias == "DLY"
            aLegenda := {{"BR_LARANJA",         STR0042 + " - " + STR0041},;      //-- "0 - Integração Meu-Checklist"
                         {"BR_VERMELHO_OCEAN",  STR0019 },;	//-- "1-Não Apto"
                         {"BR_VERDE_OCEAN",     STR0020 },;	//-- "2-Apto"
                         {"BR_AMARELO_OCEAN",   STR0021 },;	//-- "3-Enviado"
                         {"BR_AZUL_OCEAN",      STR0022 },;	//-- "4-Autenticado"
                         {"BR_PRETO_OCEAN",     STR0023 }}	//-- "5-Rejeitado"
    ElseIf cAlias == "DNN"
            //{"BR_LARANJA",         STR0042 + " - " + STR0041},;      //-- "0 - Integração Meu-Checklist"                         
            aLegenda := {{"BR_VERMELHO_OCEAN",  STR0019 },;	//-- "1-Não Apto"
                         {"BR_VERDE_OCEAN",     STR0020 },;	//-- "2-Apto"
                         {"BR_AMARELO_OCEAN",   STR0021 },;	//-- "3-Enviado"
                         {"BR_AZUL_OCEAN",      STR0022 },;	//-- "4-Autenticado"
                         {"BR_PRETO_OCEAN"   ,STR0023}}		//-- "5-Rejeitado"
    EndIf

    If !Empty(cAlias)
        BrwLegenda( cTitulo, STR0016, aLegenda  )	//-- "Status"
    EndIf

Return( Nil )

/*/{Protheus.doc} TMAE71Ini()
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
Function TMAE71Ini(cCampo)
Local oModel  := FWModelActive() 
Local xRes    := "BR_VERMELHO_OCEAN"
	
    If oModel:GetID() == "TMSAE71" .And. oModel:IsActive()
        If Upper(cCampo) == "DLY_STATUS"
            xRes    := getStatus(DLY->DLY_STATUS,"DLY")
        ElseIf Upper(cCampo) == "DNN_STATUS"
            xRes    := getStatus( DNN->DNN_STATUS, "DNN" )
        ElseIf Upper(cCampo) == "T3_DIRIMG"
            xRes    := If( !Empty(DNN->DNN_EXTENS), "<<IMAGEM>>", "" )
        ElseIf Upper(cCampo) == "RECNO"
            If Type("RECNO") == "N"
                xRes := DLY->(RECNO)
            Else
                xRes := 0
            EndIf
        EndIf
    EndIf

Return xRes

/*/{Protheus.doc} UpdDLYGrid()
    (Sincroniza a GRID da DLY com as informações atualizadas da tabela DLY )
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function UpdDLYGrid(aCHVCTE)
 Local oModel       := FwModelActive()
 Local oGridDLY     := oModel:GetModel("MGRIDDLY")
 Local oGridDT6     := oModel:GetModel("MGRIDDT6")
 Local nCount       := 1
 Local nCount2      := 1
 Local nCount3      := 1
 Local aDLYArea     := DLY->(GetArea())
 Local lMatched     := .F.
 Local aUpdDLY      := {}
 Local nMaxLinOld   := oGridDLY:Length()
 Local aCampos      := {}
 Local nDocApto     := 0 //-- Quando documento estiver apto variável será igual a quantidade de registros da DLY
 
 Default aChvCte    := {}

    For nCount := 1 To Len(aCHVCTE)
        //-- Posiciona na linha do respectivo ct-e pela sua chave para não atualiar conjunto de comprovantes errado na grid.
        oGridDT6:SeekLine({{"DT6_CHVCTE",aCHVCTE[nCount]}})
        nMaxLinOld   := oGridDLY:Length()
        //-- Obtém os registros das ultimas notas atualizadas realizando, sempre considerando os registros
        //-- com maior sequencia de evento campo(DLY_SEQEVE)
        aUpdDLY  := getLastDLY(aCHVCTE[nCount],1)
        aCampos  := oGridDLY:GetStruct():GetFields()
        nDocApto := 0

        For nCount2 := 1 To Len(aUpdDLY)
            lAddNewLine := .F.
            lMatched := oGridDLY:SeekLine(aUpdDLY[nCount2])
            If !lMatched
                oGridDLY:SetNoInsertLine(.F.)
                lAddNewLine := oGridDLY:AddLine() > nMaxLinOld
            EndIf
            //-- Se encontrou o registro atualiza ou se não encontrou adiciona uma nova linha para o registro
            //-- novo inserido na base.
            If lMatched .Or. lAddNewLine
                DLY->(DbGoTo(aUpdDLY[nCount2,1,2]))
                For nCount3 := 1 To Len(aCampos)
                    If aCampos[nCount3][MODEL_FIELD_IDFIELD] $ "T2_FLAG"
                        oGridDLY:LoadValue("T2_FLAG"   ,getStatus(DLY->DLY_STATUS,"DLY"))
                    ElseIf aCampos[nCount3][MODEL_FIELD_IDFIELD] $ "DLY_RECNO"
                        oGridDLY:LoadValue("DLY_RECNO"   ,DLY->(RECNO()))
                    ElseIf aCampos[nCount3][MODEL_FIELD_IDFIELD] $ "DLY_NOMREM"
                        oGridDLY:LoadValue("DLY_NOMREM", AllTrim(Posicione("SA1",1,xFilial("SA1")+DLY->(DLY_CLIREM+DLY_LOJREM),"A1_NOME")))
                    ElseIf aCampos[nCount3][MODEL_FIELD_IDFIELD] $ "T2_MARK"
                        oGridDLY:LoadValue("T2_MARK"   ,.T.)
                    Else
                        oGridDLY:LoadValue(aCampos[nCount3][MODEL_FIELD_IDFIELD],DLY->&(aCampos[nCount3][MODEL_FIELD_IDFIELD]))
                    EndIf
                Next nCount3
                If !Empty(DLY->DLY_RECEBE) .And. !Empty(DLY->DLY_DOCREC) .And. !Empty(DLY->DLY_DIRIMG)
                    nDocApto +=1
                EndIf
            EndIf
            If lAddNewLine .And. !lMatched
                oGridDLY:SetNoInsertLine(.T.)
            EndIf
        Next nCount2 //--[For nCount2 := 1 To Len(aUpdDLY)]
        If nDocApto == oGridDLY:Length()
            oGridDT6:LoadValue("T1_STATUS",getStatus("1","DT6"))
        EndIf
    Next nCount
    oGridDLY:GoLine(1)
    RestArea(aDLYArea)

Return Nil

/*/{Protheus.doc} getLastDLY(cChvCte)
    (Função que obtém os dados do DLY de contém a maior sequência)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getLastDLY(cChvCte,nRecursivo,cSeq2Add)
 Local cQuery       := ""
 Local cAliasDLY    := GetNextAlias()
 Local aKeyRes      := {}
 Local nSeqAnt      := 0
 Local nCount       := 1

 Default nRecursivo := 0
 Default cSeq2Add   := ""

        cQuery := "SELECT R_E_C_N_O_, DLY_SEQEVE FROM	" + RetSqlName("DLY") + " "
        cQuery += " WHERE DLY_FILIAL = '" + xFilial("DLY") + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += " AND DLY_CHVCTE = '" + cChvCte + "' "
        If !Empty(cSeq2Add)
            cQuery += " AND DLY_SEQEVE = '" + cSeq2Add + "' "
        Else        
            cQuery += " and DLY_SEQEVE = (SELECT MAX(DLY_SEQEVE)	FROM " + RetSqlName("DLY") + " "
            cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' "
            cQuery += " AND D_E_L_E_T_ = ' ' "
            cQuery += " AND DLY_CHVCTE = '" + cChvCte + "' "
        EndIf
        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY,.T.,.T.)
        //-- Cria as chaves de pesquisa pelo model do MVC referente a grid do DLY
        //-- que auxilia na montagem da chave de buscar passado para o SEEKLINE
        While (cAliasDLY)->(!EOF())

            AADD(aKeyRes,{ {"DLY_RECNO",(cAliasDLY)->R_E_C_N_O_} })
            //--Guarda a sequencia anterior utilizanda antes de atualizar os dados dos novos registros
            If nSeqAnt == 0 .And. nRecursivo > 0
                nSeqAnt := (val((cAliasDLY)->DLY_SEQEVE)-1) //-- Pega a sequencia anterior
                nRecursivo-- //--Decremento a recursividade e quando chegar a zero não chama a função
                If nSeqAnt <= 0
                    nSeqAnt := 0
                EndIf
            EndIf
            (cAliasDLY)->(DbSkip())
        EndDo
        (cAliasDLY)->(DbCloseArea())

        //-- Adiciona os recnos dos registros do evento anterior, quando informado por parâmetro
        If nSeqAnt > 0
            aTemp := getLastDLY(cChvCte,nRecursivo,StrZero(nSeqAnt,Len(DLY->DLY_SEQEVE)))
            For nCount := 1 To Len(aTemp)
                AADD(aKeyRes,{ {"DLY_RECNO",aTemp[nCount,1,2]} })
            Next nCount
        EndIf

Return aKeyRes

/*/{Protheus.doc} dadosReceb(cChvCTE,cNumnfc,cSernfc,cSeqeve)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function dadosReceb(cChvCTE)
 Local cQuery  := ""
 Local cAlias  := GetNextAlias()
 Local aResult := {Space(GetSx3Cache("DLY_RECEBE","X3_TAMANHO")),Space(GetSx3Cache("DLY_DOCREC","X3_TAMANHO")),Space(TamSx3("DLY_DIRIMG")[1])}

        cQuery := "SELECT DLY_RECEBE,DLY_DOCREC "
        cQuery += "FROM " + RetSqlName("DLY") + " DLY "
        cQuery += " WHERE "
		cQuery += " DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
		cQuery += " AND DLY.D_E_L_E_T_ = ' ' "
		cQuery += " AND DLY.DLY_CHVCTE = '" + cChvCTE + "' "
		cQuery += " AND DLY.DLY_SEQEVE = (SELECT MAX(DLY_SEQEVE) FROM " + RetSqlName("DLY") + " DLY2"
		cQuery += " WHERE DLY2.DLY_FILIAL = '" + xFilial("DLY") + "' "
        cQuery += " AND DLY2.D_E_L_E_T_ = ' ' "
		cQuery += " AND DLY2.DLY_CHVCTE = '" + cCHVCTE + "') "

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
        If (cAlias)->(!EOF())
            aResult[1] := (cAlias)->DLY_RECEBE
            aResult[2] := (cAlias)->DLY_DOCREC
            
                 aResult[3] := STR0039 //"<<<IMAGEM>>"
            
        EndIf
        (cAlias)->(DbCloseArea())

Return aResult


/*/{Protheus.doc} TMSAE71Cmt(oModel)
    Validação do Model
    @type  Static Function
    @author felipe.barbieri
    @since 23/08/2019
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function TMSAE71Cmt(oModel)
 Local aError	:= {}
 Local lRet		:= .F.

//Valida e grava as informações
If (lRet:= oModel:VldData())
    lRet:= FWFORMCOMMIT(OMODEL)
EndIf
If !lRet
    aError := oModel:GetErrorMessage()
    oModel:SetErrorMessage(,,,,,oModel:GetErrorMessage()[6])
    lRet:= .F.
EndIf

Return lRet

/*/{Protheus.doc} TMSAE71XML(oModel)
    Desenha tela com o XML posicionado
    @type  Function
    @author Valdemar Roberto Mognon
    @since 14/11/2019
    @version version
    @param oModel
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function TMSAE71XML(oMDDLY)
Local cTipEve   := oMDDLY:GetValue("DLY_TIPEVE")
Local cChvCTe   := oMDDLY:GetValue("DLY_CHVCTE") 
Local cStatus   := oMDDLY:GetValue("DLY_STATUS") 
Local cEventID  := Iif(cTipEve == "1","110180","110181")
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt    := ""
Local cXML      := ""
Local lOk       := .F.
Local lUsaColab := UsaColaboracao("2")

If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

//+------------------------------------------------------------------------------
//| Busca XML do Comprovante pela Chave do CT-e
//+------------------------------------------------------------------------------
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN  := "TOTVS"
oWS:cID_ENT     := cIdEnt
oWS:_URL        := AllTrim(cURL) + "/NFeSBRA.apw"
oWS:cID_EVENTO  := cEventID
oWS:cCHVINICIAL := cChvCTe
oWS:cCHVFINAL   := cChvCTe
lOk := oWS:NFEEXPORTAEVENTO()
If cStatus $ "345" .And. lOk
	cXML := oWS:oWSNFEEXPORTAEVENTORESULT:CSTRING[1]
	Aviso(STR0030 + Iif(cTipEve == "1",STR0032,STR0033),cXML,{STR0031},3)	//-- "XML do Comprovante de Entrega" # "-Envio" # "-Cancelamento" # "OK"
Else
	MsgAlert(STR0034,STR0035)	//-- "Comprovante não enviado ou não autorizado pela SEFAZ." ### "Atenção"
EndIf

Return

/*/{Protheus.doc} TMSAE71XML(oModel)
    Desenha tela com o XML posicionado
    @type  Function
    @author Valdemar Roberto Mognon
    @since 14/11/2019
    @version version
    @param oModel
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function TMSAE71INS(oMDDNN)
Local cTipEve   := oMDDNN:GetValue("DNN_SEQEVE")
Local cChvCTe   := ""
Local cStatus   := oMDDNN:GetValue("DNN_STATUS") 
Local cEventID  := Iif(cTipEve == "01","110190","110191")
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt    := ""
Local cXML      := ""
Local lOk       := .F.
Local lUsaColab := UsaColaboracao("2")
Local aAreaDT6  := DT6->( GetArea() )
Local cFilDoc   := oMDDNN:GetValue("DNN_FILDOC")
Local cDoc      := oMDDNN:GetValue("DNN_DOC")
Local cSerie    := oMDDNN:GetValue("DNN_SERIE")

DT6->(dbSetOrder(1))

If	DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	cChvCTe := DT6->DT6_CHVCTE

    If CTIsReady(,,,lUsaColab)
        cIdEnt := RetIdEnti(lUsaColab)
    EndIf

    //+------------------------------------------------------------------------------
    //| Busca XML do Insucesso pela Chave do CT-e
    //+------------------------------------------------------------------------------
    oWS:= WSNFeSBRA():New()
    oWS:cUSERTOKEN  := "TOTVS"
    oWS:cID_ENT     := cIdEnt
    oWS:_URL        := AllTrim(cURL) + "/NFeSBRA.apw"
    oWS:cID_EVENTO  := cEventID
    oWS:cCHVINICIAL := cChvCTe
    oWS:cCHVFINAL   := cChvCTe
    lOk := oWS:NFEEXPORTAEVENTO()
    If cStatus $ "345" .And. lOk
        cXML := oWS:oWSNFEEXPORTAEVENTORESULT:CSTRING[1]
        Aviso(STR0059 + Iif(cTipEve == "01",STR0032,STR0033),cXML,{STR0031},3)	//-- "XML do Insucesso na Entrega" # "-Envio" # "-Cancelamento" # "OK"
    Else
        MsgAlert(STR0060,STR0035)	//-- "Insucesso não enviado ou não autorizado pela SEFAZ." ### "Atenção"
    EndIf

EndIf

RestArea( aAreaDT6 )

Return

/*/{Protheus.doc} TMSAE71Age()
Carrega variável de agendamentos
@type Function
@author Valdemar Roberto Mognon
@since 31/03/2020
@version version
@param aVetor
@return 
@example
(examples)
@see (links_or_references)
/*/
Function TMSAE71Age(aWrkAge)

aAgends := Aclone(aWrkAge)

Return

/*/{Protheus.doc} Tmae71Sel()
    Seleciona a imagem e grava na tabela DM0
    @type  Static Function
    @author felipe.barbiere
    @since 30/04/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Tmae71Sel(lInsuceso)
Local cImagem := ""
Local cFileMask := STR0040 //"Arquivos de imagem|*.jpg|Bitmaps|*.bmp"  
Local oModel    := FwModelActive()
Local oMDDT6    := oModel:GetModel("MGRIDDT6")
Local nHeader   := 0
Local nTam      := 0
Local cBuffer   := ""
Local oMDLY     := oModel:GetModel("MGRIDDLY")
Local oMDNN     := NIL
Local cExt      := ""
Local nCont     := 0
Local aVetDLY   := {}
Local lDicDNN   := AliasIndic("DNN")
Local nY        := 0
Local nLine     := 0
Local lAbre     := .T.
Default lInsuceso := .F.

If lInsuceso .AND. lDicDNN
    oMDNN := oModel:GetModel("MGRIDDNN")
    If oMDNN:IsEmpty()
        lAbre := .F.
    EndIf
ElseIf !lInsuceso
    If oMDLY:IsEmpty()
        lAbre := .F.
    EndIf
EndIf
If lAbre
    cImagem := cGetFile( cFileMask , STR0037, 1, GetTempPath(), .F., GETF_LOCALHARD,.T., .F. ) //Selecionar a imagem

    If !Empty(cImagem)
        nHeader := FOpen(cImagem, 0)
        //-- Pega o tamanho da imagem 
        nTam := FSeek(nHeader,0,2)
        FSeek(nHeader,0)
        cBuffer := space(nTam)
        FRead(nHeader,@cBuffer,nTam)
        FClose(nHeader)

        SplitPath(cImagem,,,, @cExt )
        
        If lInsuceso
            
                nLine := oMDNN:GetLine()
                
                For nY := 1 To oMDNN:Length()
                    oMDNN:GoLine(nY)

                    oMDNN:LoadValue("DNN_IMAGEM",   Encode64(cBuffer)   )
                    oMDNN:LoadValue("DNN_EXTENS",   cExt                )
                    oMDNN:LoadValue("T3_DIRIMG",    "<<IMAGEM>>"        ) //"<<Imagem Selecionada>>"
                Next nY

                T71DT6ChL( , 'VGRID_DNN' )
                oMDNN:GoLine(nLine)
            
        Else
            oMDDT6:LoadValue("T1_DIRIMG",   STR0039) //"<<IMAGEM>>"

            Aadd(aVetDLY, { { "DM0_FILDOC",  oMDDT6:GetValue("DT6_FILDOC"),  Nil }, ;
                            { "DM0_DOC",     oMDDT6:GetValue("DT6_DOC"),     Nil }, ;
                            { "DM0_SERIE",   oMDDT6:GetValue("DT6_SERIE"),   Nil }, ;
                            { "DM0_EXTENS",  cExt,                           Nil }, ;
                            { "DM0_IMAGEM",  Encode64(cBuffer),              Nil } } )

            For nCont := 1 To oMDLY:Length()
                oMDLY:GoLine(nCont)
                DLY->(DbGoTo(oMDLY:GetValue("DLY_RECNO")))
                DM0->(DbSetOrder(1))
                If DM0->(DbSeek(xFilial("DM0") +oMDDT6:GetValue("DT6_FILDOC") +oMDDT6:GetValue("DT6_DOC") + oMDDT6:GetValue("DT6_SERIE")))
                    TMSIntChk("5",{DM0->(Recno()),aVetDLY}) //Altera
                Else
                    TMSIntChk("6", aVetDLY) //Inclui
                EndIf
            Next nCont

            TMAE71Pre1( oMDDT6, oMDDT6:GetLine(), 'ATUSTTS', 'T1_DIRIMG', , )
        EndIf

    Endif
Else
    Help( '', 1, "Tmae71Sel", , STR0056, 1 ) // "Não existem registros validos na tabela para que seja possivel selecionar a imagem."
EndIf

Return
/*/{Protheus.doc} TMSAE71Img()
Exibe a imagem do comprovante de entrega
@type Function
@author Valdemar Roberto Mognon
@since 04/05/2020
@version version
@param Cod Remetente, Loja Remetente, Numero NF, Serie NF, Data Emissao NF
@return Nill
@example
(examples)
@see (links_or_references)
/*/
Function TMSAE71Img(cFilDoc, cDoc, cSerie, lDNN )
Local nHeader   := 0
Local cBuffer   := ""
Local cTmpFile  := ""
Local oModel    := Nil
Local oMDLY     := Nil
Local oMDNN     := Nil
Local oDlg      := Nil
Local oTBitmap1 := Nil
Local oScroll   := Nil
Local lDLYDOC   := DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0
Local lDicDNN   := AliasIndic("DNN")
Local oSize     := Nil
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default lDNN    := .F.

oSize := FwDefSize():New( .T.)

oSize:AddObject( "DIALOG" , 100, 100, .T., .T. ) // DIALOG

oSize:lProp := .T.

If Empty(cFilDoc + cDoc + cSerie) .AND. !lDNN
	oModel   := FwModelActive()
	oMDLY    := oModel:GetModel("MGRIDDLY")
    If lDLYDOC
	    cFilDoc  := oMDLY:GetValue("DLY_FILDOC")
	    cDoc     := oMDLY:GetValue("DLY_DOC")
	    cSerie   := oMDLY:GetValue("DLY_SERIE")
    EndIf
ElseIf lDNN .AND. lDicDNN
	oModel   := FwModelActive()
	oMDNN    := oModel:GetModel("MGRIDDNN")
    cFilDoc  := oMDNN:GetValue("DNN_FILDOC")
	cDoc     := oMDNN:GetValue("DNN_DOC")
	cSerie   := oMDNN:GetValue("DNN_SERIE")
EndIf

//-- Pega a imagem do banco
DM0->(DbSetOrder(1))
If DM0->(DbSeek(xFilial("DM0") + cFilDoc + cDoc + cSerie)) .And. !Empty(DM0->DM0_IMAGEM) .AND. !lDNN
    //-- Decodifica 64
    cBuffer := Decode64(DM0->DM0_IMAGEM)
    
    //-- Gera Arquivo temporário
    cTmpFile := "tmpimgchk" + AllTrim(__cUserID) + DM0->DM0_EXTENS
ElseIf lDNN .AND. lDicDNN
    DNN->( DbSetOrder(1) )
    If DNN->( DbSeek( FWxFilial("DNN") + cFilDoc + cDoc + cSerie ) ) .And. !Empty(DNN->DNN_IMAGEM) .AND. !lDNN
        //-- Decodifica 64
        cBuffer := Decode64(DNN->DNN_IMAGEM)
        
        //-- Gera Arquivo temporário
        cTmpFile := "tmpimgchk" + AllTrim(__cUserID) + DNN->DNN_EXTENS
    ElseIf !Empty(oMDNN:GetValue("DNN_EXTENS"))
        //-- Decodifica 64
        cBuffer := Decode64(oMDNN:GetValue("DNN_IMAGEM"))
        
        //-- Gera Arquivo temporário
        cTmpFile := "tmpimgchk" + AllTrim(__cUserID) + oMDNN:GetValue("DNN_EXTENS")
    EndIf
EndIf

If !Empty(cTmpFile)
    //-- Grava a imagem no arquivo
    nHeader := FCreate(cTmpFile)
    FWrite(nHeader,cBuffer)
    FClose(nHeader)

    DEFINE DIALOG oDlg TITLE STR0038 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL //"Visualizaçao da Imagem"
        
        @ 0,0 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE 10,10 OF oDlg
        oScroll:align := CONTROL_ALIGN_ALLCLIENT

        oTBitmap1 := TBitmap():New(oSize:GetDimension("DIALOG","LININI"),oSize:GetDimension("DIALOG","COLINI"),oSize:GetDimension("DIALOG","LINEND"),oSize:GetDimension("DIALOG","COLEND"),,cTmpFile,.T.,oScroll,,,.F.,.F.,,,.F.,,.T.,,.F.)
        oTBitmap1:lAutoSize := .T.

    ACTIVATE DIALOG oDlg CENTERED

    FErase(cTmpFile)

Else
    MsgAlert(STR0043,STR0035)	//-- "Imagem não localizada." ### "Atenção"
EndIf

Return

/*/{Protheus.doc} TMAE71VImg
    (long_description)
    @type  Function
    @author Vanessa Melo
    @since 10/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function TMAE71VImg(cFilDoc,cDoc,cSerie)

Local lRet := .F.

Local aArea 	  := GetArea()
Local aAreaDM0 	  := DM0->(GetArea())

DbSelectArea("DM0")
DM0->(DbSetOrder(1)) // DM0_FILIAL, DM0_FILDOC, DM0_DOC, DM0_SERIE

If DM0->(DBSeek(xFilial("DM0")+ cFilDoc + cDoc + cSerie)) .And. !Empty(DM0->DM0_EXTENS)
    lRet := .T.
EndIf

RestArea(aArea)
RestArea(aAreaDM0)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAE71WHEN
Bloco When do campo: DNN_JUSTIF
@type function
@author Rodrigo Pirolo
@version 12.1.17
@since 06/12/2023
/*/
//-------------------------------------------------------------------------------------------------

Function TAE71When(cCampo)

Local oMdl  := FwModelActive()
Local oMDNN := Nil
Local oMDLY := Nil
Local lDicDNN:= AliasIndic("DNN")
Local lWhen := If( lDicDNN, .F., .T. )

If !lMonitora .AND. cCampo == 'DNN_JUSTIF'
    oMDNN := oMdl:GetModel("MGRIDDNN")
    If oMDNN:GetValue("DNN_TIPINS") == '4'
        lWhen := .T.
    EndIf
ElseIf lDicDNN .AND. ( cCampo == 'T1_RECEB' .OR. cCampo == 'T1_DOCREC' )
    oMDLY   := oMdl:GetModel("MGRIDDLY")
    If !oMDLY:IsEmpty()
        lWhen := .T.
    EndIf
EndIf

Return lWhen


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAE71Vld
Valid de campos da rotina TAE71Vld
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@Param cCampo - caracter - campo que é chamado no valid
@Param cGrid - caracter - 
@since 20/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TAE71Vld( cCampo, cGrid, oModel )

Local lRet 	 	:= .T.
Local oView     := FWViewActive()
Local oMdl      := FwModelActive()
Local oMDNN     := NIL
Local nLine     := 0
Local nY        := 0
Local cValor    := ""

Default cCampo  := ""
Default cGrid   := ""
Default oModel  := Nil

If lRet .AND. cCampo == 'DNN_JUSTIF'
    oMDNN     := oMdl:GetModel("MGRIDDNN")
    nLine     := oMDNN:GetLine()
    If !Empty(oMDNN:GetValue(cCampo))
        
        cValor    := oMDNN:GetValue(cCampo)

        For nY := 1 To oMDNN:Length()
            
            oMDNN:GoLine(nY)
            
            If nY != nLine .AND. Empty(oMDNN:GetValue(cCampo))
                oMDNN:LoadValue( cCampo, cValor )
            EndIf

        Next nY
        
    EndIf

    T71DT6ChL( , 'VGRID_DNN' )
    
    oMDNN:GoLine(nLine)
    oView:Refresh()
EndIf

Return lRet

/*/{Protheus.doc} UpdDNNGrid()
    (Sincroniza a GRID da DNN com as informações atualizadas da tabela DNN )
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function UpdDNNGrid(aDocs)
 Local oModel       := FwModelActive()
 Local oGridDNN     := oModel:GetModel("MGRIDDNN")
 Local oGridDT6     := oModel:GetModel("MGRIDDT6")
 Local nCount       := 1
 Local nCount2      := 1
 Local aDNNArea     := DNN->(GetArea())
 Local nMaxLinOld   := oGridDNN:Length()
  
 Default aDocs        := {}

    nLnDT6:=oGridDT6:GetLine()
    nLnDNN:=oGridDNN:GetLine()

    For nCount := 1 To Len(aDocs)
        //-- Posiciona na linha do respectivo ct-e pela sua chave para não atualiar conjunto de comprovantes errado na grid.
        oGridDT6:SeekLine( { {"DT6_FILDOC", aDocs[nCount,1]}, {"DT6_DOC", aDocs[nCount,2]}, {"DT6_SERIE", aDocs[nCount,3]} } )
        nMaxLinOld   := oGridDNN:Length()

        For nCount2 := 1 To nMaxLinOld
            oGridDNN:GoLine(nCount2)
 
            dbSelectArea("DNN")
	        dbSetOrder(1) //DNN_FILIAL+DNN_FILDOC+DNN_DOC+DNN_SERIE+DNN_NUMNFC+DNN_SERNFC+DNN_SEQINS+DNN_SEQEVE                                                                             
	        If MsSeek(xFilial("DNN")+oGridDNN:GetValue("DNN_FILDOC")+oGridDNN:GetValue("DNN_DOC")+oGridDNN:GetValue("DNN_SERIE")+oGridDNN:GetValue("DNN_NUMNFC")+oGridDNN:GetValue("DNN_SERNFC"))
                oGridDNN:LoadValue("DNN_STATUS"   ,DNN->DNN_STATUS)
                oGridDNN:LoadValue("DNN_IDRETE"   ,DNN->DNN_IDRETE)
                oGridDNN:LoadValue("DNN_PROTOC"   ,DNN->DNN_PROTOC)
                oGridDNN:LoadValue("DNN_HSHIMG"   ,DNN->DNN_HSHIMG)
                oGridDNN:LoadValue("DNN_DTHRIN"   ,DNN->DNN_DTHRIN)
                oGridDNN:LoadValue("DNN_DRETEV"   ,DNN->DNN_DRETEV)
                oGridDNN:LoadValue("DNN_SEQEVE"   ,DNN->DNN_SEQEVE)
                oGridDNN:LoadValue("T3_FLAG"      ,getStatus(DNN->DNN_STATUS,"DNN"))
            EndIf
   
        Next nCount2 //

    Next nCount

    nLnDT6:=oGridDT6:GetLine()
    nLnDNN:=oGridDNN:GetLine()
   
    oGridDT6:GoLine(nLnDT6)
    oGridDNN:GoLine(nLnDNN)
    RestArea(aDNNArea)

Return Nil
