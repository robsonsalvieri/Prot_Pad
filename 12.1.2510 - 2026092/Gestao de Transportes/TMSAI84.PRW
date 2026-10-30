#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI84.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI84
Histórico de Integrações
@author Valdemar Roberto Mognon
@since 02/03/2022
*/
Function TMSAI84()
    Local aCoors  := FWGetDialogSize( oMainWnd )
    Local oDlgPrinc  As Object
    Local oFWLayer   As Object
    Local oPanelUp   As Object
    Local oPanelDown As Object
    Local oBrowseDNC As Object
    Local aFildDN5 := {"DN5_CHAVE","DN5_CODREG","DN5_DESREG","DN5_SEQUEN","DN5_DATGER","DN5_HORGER","DN5_LOCALI"}
    Local aColumns := {}
    Local nField   := 0
    
    Private aRotina := MenuDef()

    oDlgPrinc := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0001,,,,,,,,,.T.,,,)

	oFWLayer:= FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
    oFWLayer:AddLine( "UP", 50, .F. )
	oFWLayer:AddLine( "DOWN", 50, .F. )

    oPanelUp := oFWLayer:GetLinePanel("UP")
    oBrowseDNC:= FWMBrowse():New()
    oBrowseDNC:SetOwner(oPanelUp)
    oBrowseDNC:SetAlias("DNC")
    oBrowseDNC:SetMenuDef("TMSAI84")
    oBrowseDNC:SetDescription(STR0001)	//-- Histórico de Integrações
    oBrowseDNC:DisableDetails()

    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='1'", "GREEN" , STR0022 )	//-- Integrado
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='2'", "BLUE"  , STR0023 )	//-- Não Integrado
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='3'", "RED"   , STR0024 )	//-- Erro Envio
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='4'", "PINK"  , STR0025 )	//-- Erro Retorno
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='5'", "BROWN" , STR0026 )	//-- Estornado
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='6'", "BLACK" , STR0027 )	//-- Estornado Envio
    oBrowseDNC:AddLegend( "DNC->DNC_STATUS=='7'", "YELLOW", STR0035 )   //-- Erro Processo

    oPanelDown := oFWLayer:GetLinePanel("DOWN")
	oBrowseDN5:= FWBrowse():New(oPanelDown)
	oBrowseDN5:SetAlias('DN5')
    oBrowseDN5:SetDataTable()
    oBrowseDN5:DisableConfig()
    oBrowseDN5:DisableReport()
    oBrowseDN5:AddStatusColumns( {|| TMSAI86Leg() }, {|| TMSAI86Leg(.T.)} )
    For nField := 1 To Len( aFildDN5 )
        AAdd( aColumns, FWBrwColumn():New() )
        If aFildDN5[nField] == "DN5_DESREG"
            aColumns[Len(aColumns)]:SetData( {|| Posicione("DN2",1,FWxFilial("DN2") + DN5->(DN5_CODFON + DN5_CODREG),"DN2_DESREG") })
        Else
            aColumns[Len(aColumns)]:SetData( &("{ || " + aFildDN5[nField] + " }") )
        EndIf
        aColumns[Len(aColumns)]:SetTitle( RetTitle(aFildDN5[nField]) )
        aColumns[Len(aColumns)]:SetSize( TamSX3(aFildDN5[nField])[1] )
        aColumns[Len(aColumns)]:SetID( aFildDN5[nField] )
    Next
    oBrowseDN5:SetColumns(aColumns)
    oBrowseDN5:SetDoubleClick( {|| TMSAI84Det() } )
    oBrowseDN5:SetFilterDefault( "DNC->DNC_STATUS $ '5,6' .Or. ( DN5->DN5_STATUS != '5' .AND. DN5->DN5_STATUS != '6' )" )
	oBrowseDN5:Activate()

	oRelacDN5 := FWBrwRelation():New()
	oRelacDN5 :AddRelation(oBrowseDNC,oBrowseDN5,{{"DN5_FILIAL","xFilial('DN5')" },;
                                                  {"DN5_CODFON","DNC_CODFON"},;
                                                  {"DN5_PROCES","DNC_PROCES"}} )
	oRelacDN5 :Activate()

    DNC->(DbSetOrder(1))
    DNC->(DbGoTop())
    DN5->(DbSetOrder(5))
    DN5->(DbGoTop())

    oBrowseDNC:Activate()
    oDlgPrinc:Activate()

Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@author Valdemar Roberto Mognon
@since 02/03/2022
*/
Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0	//-- Pesquisar
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI84"  OPERATION 2 ACCESS 0	//-- Visualizar
    ADD OPTION aRotina TITLE STR0013 ACTION "TMSAI84REP()"     OPERATION 6 ACCESS 0	//-- Reprocessa
Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@author Valdemar Roberto Mognon
@since 02/03/2022
*/
Static Function ModelDef()
    Local oModel
    Local oStruDNC := FwFormStruct(1,"DNC")
    Local oStruDN5 := FwFormStruct(1,"DN5")

    oModel := MpFormModel():New("TMSAI84", /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
    oModel:SetDescription(STR0001)	//-- Histórico de Integrações

    //-- Cabeçalho
    oModel:AddFields("MdFieldDNC",,oStruDNC,,,)
    oModel:SetPrimaryKey({"DNC_CODFON","DNC_PROCES","DNC_LOCALI"})
    oModel:GetModel("MdFieldDNC"):SetDescription(STR0001)	//-- Histórico de Integrações

    //-- Itens
    //-- Histórico
    oModel:AddGrid("MdGridDN5","MdFieldDNC",oStruDN5,,,,,)
    oModel:SetRelation("MdGridDN5",{{"DN5_FILIAL","xFilial('DN5')"},;
                                    {"DN5_CODFON","DNC_CODFON"},;
                                    {"DN5_PROCES","DNC_PROCES"}},;
                                    DN5->(IndexKey(5)))
    oModel:GetModel("MdGridDN5"):SetDescription(STR0007)	//-- Histórico
    oModel:GetModel("MdGridDN5"):SetUniqueLine({"DN5_SEQUEN"})

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@author Valdemar Roberto Mognon
@since 02/03/2022
*/
Static Function ViewDef()
    Local oModel   := FwLoadModel("TMSAI84")
    Local oStruDNC := FwFormStruct(2,"DNC")
    Local oStruDN5 := FwFormStruct(2,"DN5")
    Local oView

    //oStruDN5:RemoveField("DN5_CONTEU")
    //oStruDN5:RemoveField("DN5_MOTIVO")
    oStruDN5:RemoveField("DN5_CHAVE")
    oStruDN5:RemoveField("DN5_PROCES")
    oStruDN5:RemoveField("DN5_LOCALI")
    oStruDN5:RemoveField("DN5_FILORI")

    oView := FwFormView():New()
    oView:SetModel(oModel)

    //-- Define o tamanho da tela principal
    oView:CreateHorizontalBox("Cabecalho",030)
    oView:CreateHorizontalBox("Itens",069)

    //-- Cria área da tabela pai
    oView:AddField("VwFieldDNC",oStruDNC,"MdFieldDNC") 
    oView:EnableTitleView("VwFieldDNC",STR0001)	//-- Histórico de Integrações
    oView:SetOwnerView("VwFieldDNC","Cabecalho")

    //-- Cria área das tabelas filhas
    //-- Histórico
    oView:AddGrid("VwGridDN5",oStruDN5,"MdGridDN5")
    oView:EnableTitleView("VwGridDN5",STR0007)	//-- Histórico
    oView:SetOwnerView("VwGridDN5","Itens")
    oView:AddIncrementField("VwGridDN5","DN5_SEQUEN")

    oView:AddUserButton(STR0013,"",{|oModel| TMSAI84Rep() })	//-- Reprocessa

    oView:SetViewProperty("VwGridDN5","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| I84DblClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})
Return oView

/*{Protheus.doc} VisReg
Visualiza o Registro
@author Valdemar Roberto Mognon
@since 15/03/2022
*/
Function VisReg()
    Local aCpos     := {}
    Local aObjs     := {}
    Local aCoors    := FWGetDialogSize( oMainWnd )
    Local aLayout   := {}
    Local nCntFor1  := 0
    Local oDlgReg AS Object
    Local lOpcOk    := .F.
    Local cConteudo := ""
    Local aButtons  := { { 'BMPUSER', {|| TMSAI84Edt() }, STR0033, STR0033 } }
    Local n := 0

    Private aConteudo := {}
    Private lAlter    := .F.

    aLayout   := BscLayout(FwFldGet("DNC_CODFON"),FwFldGet("DN5_CODREG"))
    aConteudo := QuebraReg(FwFldGet("DNC_CODFON"),FwFldGet("DN5_CODREG"),FwFldGet("DN5_SEQUEN"),Aclone(aLayout))
    For nCntFor1 := 1 To Len(aLayout)
        Aadd(aCpos,{"aConteudo[" + StrZero(nCntFor1,4) + "]",1,aLayout[nCntFor1,1],{aLayout[nCntFor1,5],aLayout[nCntFor1,6],aLayout[nCntFor1,4]},AllTrim(X3Picture(aLayout[nCntFor1,3])),.F.,"lAlter",,,,})
    Next nCntFor1

    If !Empty(aConteudo)
        DEFINE MSDIALOG oDlgReg TITLE STR0008 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL	//-- Registro
        DinamicEnc(oDlgReg,aCpos,,@aObjs)
        ACTIVATE MSDIALOG oDlgReg CENTERED ON INIT EnchoiceBar( oDlgReg, {|| oDlgReg:End(), lOpcOk := .T. }, {|| oDlgReg:End() }, , aButtons )
    EndIf

    If lAlter .And. lOpcOk
        DN5->(DbSetOrder(1))
        If DN5->(MsSeek(xFilial("DN5")+FwFldGet("DNC_CODFON")+FwFldGet("DN5_CODREG")+FwFldGet("DN5_SEQUEN")))
            For n := 1 To Len(aConteudo)
                If aLayout[n,4] == "N"
                    If aLayout[n,6] == 0
                        cConteudo += StrZero(aConteudo[n],aLayout[n,5])
                    Else
                        cConteudo += StrZero(aConteudo[n] * (10^aLayout[n,6]),aLayout[n,5])
                    EndIf
                ElseIf aLayout[n,4] == "D"
                    cConteudo += PadR(DToS(aConteudo[n]),aLayout[n,5])
                Else
                    cConteudo += PadR(aConteudo[n],aLayout[n,5])
                EndIf
            Next
           
            RecLock("DN5",.F.)
            DN5->DN5_CONTEU := cConteudo
            MsUnLock()
            If MsgYesNo(STR0031)
                TMSAI84Rep(.T.)
                FWMsgrun(,{|| TMSAI86AUX(FwFldGet("DNC_PROCES")) }, STR0029, STR0030 )
            EndIf
        EndIf
    EndIf
Return lOpcOk

/*{Protheus.doc} I84DblClick
Apresenta histórico de integração do Registro (campo DN5_MOTIVO)
@author Carlos Alberto Gomes Junior
@since 30/05/22
*/
Static Function I84DblClick(oModel,cFieldName,nLineGrid,nLineModel)
    DEFAULT cFieldName := ""
    Do Case
        Case cFieldName == "DN5_MOTIVO"
            TMSErrDtl(FwFldGet("DN5_MOTIVO"))
        Case cFieldName == "DN5_CONTEU"
            VisReg()
    EndCase
Return

/*{Protheus.doc} TMSAI84Rep
Gera novo registro de histórico do registro posicionado para reprocessamento
@author Carlos Alberto Gomes Junior
@since 30/05/22
*/
Function TMSAI84Rep( lEdit )
    Local aAreas    := {DN5->(GetArea()),GetArea()}
    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()

    DEFAULT lEdit   := .F.

    cCodFon := DNC->DNC_CODFON
    cProces := DNC->DNC_PROCES

    cQuery := "SELECT "
    cQuery += "R_E_C_N_O_ DN5REG FROM "+RetSQLName("DN5")+" " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "DN5_FILIAL = '" + xFilial("DN5") + "' AND " + CRLF
    cQuery += "DN5_CODFON = '" + cCodFon + "' AND " + CRLF
    cQuery += "DN5_PROCES = '" + cProces + "' AND " + CRLF
    cQuery += "DN5_STATUS IN ('3','4','7') AND " + CRLF
    cQuery += "D_E_L_E_T_ = '' " + CRLF

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

    If !(cAliasQry)->(Eof()) 
        Do While !(cAliasQry)->(Eof())
            DN5->(DbGoTo((cAliasQry)->DN5REG))
            RecLock("DN5",.F.)
            If DN5->DN5_STATUS $ "37" // Erro de envio
                DN5->DN5_SITUAC := "1"
                DN5->DN5_STATUS := "2"
            ElseIf DN5->DN5_STATUS == "4" // Erro de Retorno
                DN5->DN5_SITUAC := "2"
                DN5->DN5_STATUS := "1"
            EndIf
            MsUnlock()
            (cAliasQry)->(DbSkip()) 
        EndDo
    EndIf

    (cAliasQry)->(DbCloseArea())
    AEval(aAreas,{|aArea| RestArea(aArea) })

    If lEdit .Or. MsgYesNo(STR0031)
        FWMsgrun(,{|| TMSAI86AUX(cProces) }, STR0029, STR0030 )
    EndIf

    AEval(aAreas,{|aArea| RestArea(aArea), FwFreeArray(aArea) })
    FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSAI84Edt
Habilita a edição de registros
@author Carlos Alberto Gomes Junior
@since 26/08/22
*/
Function TMSAI84Edt
    If FwFldGet("DN5_STATUS") == "3"
        lAlter := MsgNoYes(STR0032)
    Else
        Help(" ", , STR0033, , STR0034, 2, 1)
    EndIf
Return

/*{Protheus.doc} TMSAI86Leg
Legandas do Browse Principal Inferior
@author Carlos Alberto Gomes Junior
@since 12/09/2024
*/
Static Function TMSAI86Leg(lLeg)
    Local aLegenda := {}
    Local xRet     := .T.
    DEFAULT lLeg := .F.

    If lLeg
        Aadd( aLegenda, { "BR_VERDE"   , STR0022 } )	//-- Integrado
        Aadd( aLegenda, { "BR_AZUL"    , STR0023 } )	//-- Não Integrado
        Aadd( aLegenda, { "BR_VERMELHO", STR0024 } )	//-- Erro Envio
        Aadd( aLegenda, { "BR_PINK"    , STR0025 } )	//-- Erro Retorno
        Aadd( aLegenda, { "BR_MARROM"  , STR0026 } )	//-- Estornado
        Aadd( aLegenda, { "BR_PRETO"   , STR0027 } )	//-- Estornado Envio
        Aadd( aLegenda, { "BR_AMARELO" , STR0035 } )	//-- Erro Processo
        BrwLegenda( STR0001 , STR0001 , aLegenda )  
    Else
        Do Case
        Case DN5->DN5_STATUS == '1'
            xRet := "BR_VERDE"
        Case DN5->DN5_STATUS == '2'
            xRet := "BR_AZUL"
        Case DN5->DN5_STATUS == '3'
            xRet := "BR_VERMELHO"
        Case DN5->DN5_STATUS == '4'
            xRet := "BR_PINK"
        Case DN5->DN5_STATUS == '5'
            xRet := "BR_MARROM"
        Case DN5->DN5_STATUS == '6'
            xRet := "BR_PRETO"
        Case DN5->DN5_STATUS == '7'
            xRet := "BR_AMARELO"
        EndCase
    EndIf

Return xRet

/*{Protheus.doc} TMSAI84Det
Nova tela de detalhes de registros de histórico
@author Carlos Alberto Gomes Junior
@since 12/09/2024
*/
Function TMSAI84Det()
    Local aCoors   := FWGetDialogSize( oMainWnd )
    Local cMemo01  := DN5->DN5_MOTIVO
    Local aFildDN5 := {"DN5_CHAVE","DN5_CODREG","DN5_DESREG","DN5_SEQUEN","DN5_DATGER","DN5_HORGER"}
    Local nTag     := 0
    Local aColumns := {}
    Local oDlgDet  := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0001,,,,,,,,,.T.,,,)
    Local aLayout   := BscLayout(DNC->DNC_CODFON,DN5->DN5_CODREG)
    Local aConteudo := QuebraReg(DNC->DNC_CODFON,DN5->DN5_CODREG,DN5->DN5_SEQUEN,Aclone(aLayout))
    Local oFWLayer   As Object
    Local oPanelUpL  As Object
    Local oPanelUpR  As Object
    Local oPanelDown As Object

    Private aDetCols := {}
    Private oBrowDet As Object

	oFWLayer:= FWLayer():New()
	oFWLayer:Init( oDlgDet, .F. )
    oFWLayer:AddLine( "BUTTON", 05, .F. )
    oFWLayer:AddLine( "UP", 35, .F. )
    oFWLayer:AddCollumn( 'LEFT', 60, .T., 'UP' ) 
    oFWLayer:AddCollumn( 'RIGHT', 40, .T., 'UP' ) 
	oFWLayer:AddLine( "DOWN", 60, .F. )
    oPanelUpL  := oFWLayer:GetColPanel("LEFT","UP")
    oPanelUpR  := oFWLayer:GetColPanel("RIGHT","UP")
    oPanelDown := oFWLayer:GetLinePanel("DOWN")
    oPanelUpB  := oFWLayer:GetLinePanel("BUTTON")

	oEnRdg := MsmGet():New("DN5",DN5->(RecNo()),2,,,,aFildDN5,{ , , , },{},,,,,oPanelUpL)
    oEnRdg:oBox:align := CONTROL_ALIGN_ALLCLIENT
    aCoors := FWGetDialogSize( oPanelUpR )
    TSay():New(02,02, {|| STR0001 },oPanelUpR,,,,,,.T.,,,100,10,,,,,,.T.)
    TMultiGet():New(12,02, bSETGET(cMemo01),oPanelUpR,250,140,,,,,,.T.,,,,,,.T.,,,,,)
    oBut := TButton():New(02,aCoors[3]-25,"&"+STR0036,oPanelUpB,{|| oDlgDet:End() },45,15,,,,.T.,,,,,,) //-- Sair

	oBrowDet:= FWBrowse():New(oPanelDown)
    oBrowDet:DisableConfig()
    oBrowDet:DisableReport()
    For nTag := 1 To Len(aLayout)
        AAdd(aDetCols,{aLayout[nTag][2],aLayout[nTag][1],aConteudo[nTag]})
    Next
    AAdd( aColumns, FWBrwColumn():New() )
    aColumns[Len(aColumns)]:SetTitle( RetTitle("DN3_DESCRI") )
    aColumns[Len(aColumns)]:SetSize( 20 )
    aColumns[Len(aColumns)]:SetID( "descricao" )
    aColumns[Len(aColumns)]:SetData( {|| aDetCols[oBrowDet:nAt,1] } )

    AAdd( aColumns, FWBrwColumn():New() )
    aColumns[Len(aColumns)]:SetTitle( RetTitle("DN3_CAMPO") )
    aColumns[Len(aColumns)]:SetSize( 20 )
    aColumns[Len(aColumns)]:SetID( "tag" )
    aColumns[Len(aColumns)]:SetData( {|| aDetCols[oBrowDet:nAt,2] } )

    AAdd( aColumns, FWBrwColumn():New() )
    aColumns[Len(aColumns)]:SetTitle( RetTitle("DN3_CONTEU") )
    aColumns[Len(aColumns)]:SetSize( 200 )
    aColumns[Len(aColumns)]:SetID( "conteudo" )
    aColumns[Len(aColumns)]:SetData( {|| aDetCols[oBrowDet:nAt,3] } )

    oBrowDet:SetColumns(aColumns)
    oBrowDet:SetDataArray()
	oBrowDet:SetArray(aDetCols)

	oBrowDet:Activate()
    oDlgDet:Activate()

Return

