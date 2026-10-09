#include "protheus.ch"
#include "FwMvcDef.ch"
#include "fwmbrowse.ch"
#include "FINA708.CH"

#Define NOTAGERADA 1
#Define IDNOTA 2
#Define MENSAGEM 3

Static __lSched     := FWGetRunSchedule()
Static __oTempDb    := NIL
Static __aCampos    := {}
Static __aIndex     := {}
Static __oEstNF     := NIL

/*/{Protheus.doc} FINA708
    Faturamento de Encargos e Antecipações (IBS/CBS)

    @type       Function
    @author     Vitor Duca
    @since      17/04/2026
    @version    1.0
/*/
Function FINA708()
    If AliasInDic("F7T")
        If __lSched
            F708GerND()
        Else
            FWLoadBrw("FINA708")
        Endif
    Endif
Return

/*/{Protheus.doc} BrowseDef
    Definição do browse
    
    @type  Function
    @author Vitor Duca
    @since 17/04/2026
    @version version    
/*/
Static Function BrowseDef() as object
    local oBrowse   as object
    
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( "F7T" )
    oBrowse:SetDescription( STR0001 ) //"Faturamento de encargos e antecipações (IBS/CBS)"
    oBrowse:SetMenuDef( "FINA708" )

    //Definição das legendas para os status
    oBrowse:AddLegend(" F7T_TIPMOV == '2' ","YELLOW", X3CboxDesc( "F7T_TIPMOV", "2" ), "TIPMOV")
    oBrowse:AddLegend(" F7T_TIPMOV == '1' ","BLUE"  , X3CboxDesc( "F7T_TIPMOV", "1" ), "TIPMOV")

    if hasSmartX()
        oBrowse:setSmartX()
    endif

    oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef
    Definição do menu
    
    @type  Function
    @author Vitor Duca
    @since 16/04/2026
    @version version    
/*/
Static Function MenuDef() as Array
    Local aRotina   as Array

    aRotina := {}

    ADD OPTION aRotina TITLE STR0002    ACTION 'F708GerND'          OPERATION MODEL_OPERATION_INSERT    ACCESS 0 PAGEACTION //'Gerar Notas de Déb./Créd.'
    ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.FINA708'   	OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0004	ACTION 'F708Log'   	        OPERATION 9                         ACCESS 0 //Historico
    ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.FINA708'    OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //'Excluir'

Return aRotina

/*/{Protheus.doc} ModelDef
    Definição do model
    
    @type  Function
    @author Vitor Duca
    @since 16/04/2026
    @version version    
/*/
Static Function ModelDef() as Object
    Local oModel    as Object
    Local oStruF7T  as Object
    Local oStruSE1  as Object
    Local oStruSF2  as Object

    oStruF7T    := FWFormStruct( 1, 'F7T')
    oStruSE1    := FWFormStruct(1, 'SE1', { |x| ALLTRIM(x) $ "E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI"} )
    oStruSF2    := FWFormStruct(1, 'SF2', { |x| ALLTRIM(x) $ "F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT"} )
    oModel      := MPFormModel():New( 'FINA718', /*bPreValidacao*/, { |oModel| FPosValid(oModel) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )    

    oModel:AddFields( 'F7TMASTER', /*cOwner*/, oStruF7T, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )   
    oModel:AddGrid( 'SE1DETAIL', 'F7TMASTER', oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/ )
    oModel:AddGrid( 'SF2DETAIL', 'F7TMASTER', oStruSF2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/ )

    oModel:GetModel('SE1DETAIL'):SetOnlyQuery( .T. )
    oModel:GetModel("SE1DETAIL"):SetOptional( .T. )
    oModel:SetRelation( 'SE1DETAIL', { { 'E1_FILIAL', 'xFilial( "SE1" )' }, { 'E1_PREFIXO', 'F7T_PREFIX' }, { 'E1_NUM', 'F7T_NUMTIT'}, { 'E1_PARCELA', 'F7T_PARCEL' }, { 'E1_TIPO', 'F7T_TIPO' } }, SE1->( IndexKey( 1 ) ) )

    oModel:GetModel('SF2DETAIL'):SetOnlyQuery( .T. )
    oModel:GetModel("SF2DETAIL"):SetOptional( .T. )
    oModel:SetRelation( 'SF2DETAIL', { { 'F2_FILIAL', 'xFilial( "SF2" )' }, { 'F2_DOC', 'F7T_NUMNOT' }, { 'F2_IDNF', 'F7T_IDNF' } }, SF2->( IndexKey( 17 ) ) )

    oModel:GetModel( 'F7TMASTER' ):SetDescription( STR0006 )//Detalhe da movimentação    
    oModel:GetModel( 'SE1DETAIL' ):SetDescription( STR0007 )//"Titulo"
    oModel:GetModel( 'SF2DETAIL' ):SetDescription( STR0008 )//"Nota de débito/crédito"

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View
    
    @type  Function
    @author Vitor Duca
    @since 16/04/2026
    @version version    
/*/
Static Function ViewDef() as Object
    Local oView     as Object
    Local oModel    as Object
    Local oStruF7T  as Object
    Local oStruSE1  as Object
    Local oStruSF2  as Object

    oStruF7T    := FWFormStruct( 2, 'F7T')
    oStruSE1    := FWFormStruct(2, 'SE1', { |x| ALLTRIM(x) $ "E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI"} )
    oStruSF2    := FWFormStruct(2, 'SF2', { |x| ALLTRIM(x) $ "F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT"} )
    oModel      := FWLoadModel( 'FINA708' )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    
    oStruF7T:RemoveField('F7T_FILIAL')
    oStruF7T:RemoveField('F7T_IDF7T')
    oStruF7T:RemoveField('F7T_IDDOC')
    oStruF7T:RemoveField('F7T_IDMOV')
    oStruF7T:RemoveField('F7T_IDNF')
    oStruF7T:RemoveField('F7T_TABORI')
    oStruF7T:RemoveField('F7T_TIPMOV')

    oStruF7T:RemoveField('F7T_FILTIT')
    oStruF7T:RemoveField('F7T_PREFIX')
    oStruF7T:RemoveField('F7T_NUMTIT')
    oStruF7T:RemoveField('F7T_PARCEL')
    oStruF7T:RemoveField('F7T_TIPO')
    oStruF7T:RemoveField('F7T_PARTIC')
    oStruF7T:RemoveField('F7T_LOJA')
    oStruF7T:RemoveField('F7T_VENCTO')
    oStruF7T:RemoveField('F7T_NOMPAR')

    oStruF7T:RemoveField('F7T_NUMNOT')
    oStruF7T:RemoveField('F7T_VALOR')

    oView:AddField( 'VIEW_F7T', oStruF7T, 'F7TMASTER' )
    oView:AddGrid( 'VIEW_SE1', oStruSE1,  'SE1DETAIL' )
    oView:AddGrid( 'VIEW_SF2', oStruSF2,  'SF2DETAIL' )

    oView:SetViewProperty("SE1DETAIL", "GRIDDOUBLECLICK", {{|| ViewBill()}})
    oView:SetViewProperty("VIEW_SF2", "GRIDDOUBLECLICK", {{|| ViewInvoic()}})

    oView:CreateHorizontalBox( 'MASTER', 50 )
    oView:CreateHorizontalBox( 'DETAILSE1', 25 )
    oView:CreateHorizontalBox( 'DETAILSF2', 25 )

    oView:SetOwnerView( 'VIEW_F7T', 'MASTER' )
    oView:SetOwnerView( 'VIEW_SE1', 'DETAILSE1' )
    oView:SetOwnerView( 'VIEW_SF2', 'DETAILSF2' )

    oView:SetDescription(STR0001) //"Faturamento de encargos e antecipações (IBS/CBS)"

    oView:EnableTitleView('VIEW_F7T', STR0006 ) //'Detalhe da movimentação'
	oView:EnableTitleView('VIEW_SE1', STR0007 ) //'Titulo'
    oView:EnableTitleView('VIEW_SF2', STR0008 ) //'Nota de Débito/crédito'

Return oView

/*/{Protheus.doc} FPosValid
    Pos validação do modelo, executada no confirmar após as validações do MVC
    @type  Static Function
    @author Vitor Duca
    @since 06/05/2026
    @version 1.0
    @param oModel, Object, Modelo contendo a folha de dados da tabela F7T
    @return lRet, Logical, Define se a operação pode ser concluida com sucesso
/*/
Static Function FPosValid(oModel as object) as logical
    local lRet  as logical

    lRet := .T.

    If oModel:GetOperation() == MODEL_OPERATION_DELETE

        lRet := Empty(F7T->F7T_NUMNOT)

        If !lRet
            Help(,,"NFGERADA",, STR0009,1,0, NIL, NIL, NIL, NIL, NIL, {STR0010}) //"Nota de débito/crédito gerada, não será permitido a exclusão"#"Realize o estorno da baixa e cancelamento da nota para conseguir excluir o registro"
        Endif
    Endif
Return lRet

/*/{Protheus.doc} F708GerND
    Gerar Nota de Débito/Credito

    @author Vitor Duca
    @since 16/04/2026
    @version 1.0
/*/
Function F708GerND()
    local aAreaF7T  as array
    local aArea     as array

    aArea := FwGetArea()
    aAreaF7T := F7T->(FwGetArea())

    If VldParams()
        If __lSched .or. ( !__lSched .and. Pergunte("FIN708", .T.) )
            PrepareTmp()
            If !__lSched
                FMrkBrowse()
            Else
                FProcessND()
            Endif
        Endif
    Endif

    FwRestArea(aAreaF7T)
    FwRestArea(aArea)
Return

/*/{Protheus.doc} VldParams
    Realização a validação dos parametros necessarios para geração da ND
    @type  Static Function
    @author Vitor Duca
    @since 12/06/2026
    @version 1.0
    @return lRet, Logical, Define se o processo de geração pode ser executado
/*/
Static Function VldParams() as logical
    Local cNDTES        as character
    Local cNDSERIE      as character
    Local lRet          as logical

    cNDTES := ""
    cNDSERIE := ""
    lRet := .T.
    
    If FindFunction("RetParam")
        cNDTES := RetParam(SuperGetMv("MV_NDTES",.F.,""), "4", GetSX3Cache("D2_TES", "X3_TAMANHO"))
        cNDSERIE := RetParam(SuperGetMv("MV_NDSERIE",.F.,""), "4", GetSX3Cache("F2_SERIE", "X3_TAMANHO"))
        lRet := !Empty(cNDTES) .and. !Empty(cNDSERIE)
    Endif

    If !lRet
        If !__lSched
            helpParams()
        Endif

        FwLogMsg("WARN",, STR0022,,, , STR0028 , , ,) //"Configuração do ambiente" # "Os parâmetros MV_NDTES e MV_NDSERIE não estão configurados corretamente para a geração das notas"
    Endif

Return lRet

/*/{Protheus.doc} helpParams
    Exibe a tela de alerta para o usuario sobre os parametros que devem ser configurados
    no ambiente
    @type  Static Function
    @author Vitor Duca
    @since 12/06/2026
    @version 1.0
/*/
Static Function helpParams()
    Local oModal        as object
    Local oContainer    as object
    Local oSay1         as object
    Local oSay2         as object
    Local cLinkTDN      as character
    Local cMsgLink      as character

    cLinkTDN := ""
    cMsgLink := ""

    oModal := FWDialogModal():New()
    oModal:SetCloseButton( .F. )
    oModal:SetEscClose( .F. )
    oModal:setTitle(STR0022) //"Configuração do ambiente"

    //define a altura e largura da janela em pixel
    oModal:setSize(150, 250)

    oModal:createDialog()

    oModal:AddButton( STR0013, {|| oModal:DeActivate() }, STR0013, , .T., .F., .T., ) //"Confirmar"

    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    cLinkTDN := "https://tdn.totvs.com/pages/releaseview.action?pageId=1043712225"

    cMsgLink := "<b><a target='_blank' href='" + cLinkTDN + "'> "
    cMsgLink += STR0023 // "Clique aqui para saber mais."
    cMsgLink += "</a></b>"

    oSay1 := TSay():New( 10, 10, {|| STR0024 + " <b>MV_NDTES</b> "+ STR0025 +" <b>MV_NDSERIE</b> " + STR0026 }, oContainer,,,,,, .T.,,, 220, 20,,,,,, .T.) //"Verificamos que os parâmetros" # "e" # "não estão configurados corretamente para a geração das notas, por favor verifique!"
    oSay2 := TSay():New(30, 10, {|| cMsgLink }, oContainer,,,,,, .T.,,, 220, 20,,,,,, .T.)
    oSay2:bLClicked := {|| MsgRun(  STR0027, "URL",{|| ShellExecute("open", cLinkTDN, "", "", 1) } ) } // "Acessando a documentação..."

    oModal:Activate()
Return

/*/{Protheus.doc} PrepareTmp
    Realiza a criação da tabela temporaria que será utilizada no processo
    de geração das ND e NC
    @type  Static Function
    @author Vitor Duca
    @since 06/05/2026
    @version 1.0
/*/
Static Function PrepareTmp()
    local cQuery    as character
    local cMark     as character

    If Empty(__aCampos)
        AAdd(__aCampos, {"MARK", "C", 1, 0, "", ""})
        AAdd(__aCampos, {"F7T_FILIAL", FWSX3Util():GetFieldType("F7T_FILIAL"), TamSX3("F7T_FILIAL")[1], TamSX3("F7T_FILIAL")[2], X3Picture("F7T_FILIAL"), Alltrim(RetTitle("F7T_FILIAL"))})
        AAdd(__aCampos, {"TITULO", "C", TamSX3("F7T_PREFIX")[1] + TamSX3("F7T_NUMTIT")[1] + TamSX3("F7T_PARCEL")[1] + TamSX3("F7T_TIPO")[1] + 3, 0, "@!", "Dados do Titulo"})
        AAdd(__aCampos, {"CLIFOR", "C", TamSX3("F7T_PARTIC")[1] + TamSX3("F7T_LOJA")[1] + TamSX3("F7T_NOMPAR")[1] + 4, 0, "@!", "Participante"})
        AAdd(__aCampos, {"F7T_VENCTO", FWSX3Util():GetFieldType("F7T_VENCTO"), TamSX3("F7T_VENCTO")[1], TamSX3("F7T_VENCTO")[2], X3Picture("F7T_VENCTO"), Alltrim(RetTitle("F7T_VENCTO"))})
        AAdd(__aCampos, {"F7T_VLRMOV", FWSX3Util():GetFieldType("F7T_VLRMOV"), TamSX3("F7T_VLRMOV")[1], TamSX3("F7T_VLRMOV")[2], X3Picture("F7T_VLRMOV"), Alltrim(RetTitle("F7T_VLRMOV"))})
        AAdd(__aCampos, {"F7T_SEQBX", FWSX3Util():GetFieldType("F7T_SEQBX"), TamSX3("F7T_SEQBX")[1], TamSX3("F7T_SEQBX")[2], X3Picture("F7T_SEQBX"), Alltrim(RetTitle("F7T_SEQBX"))})
        AAdd(__aCampos, {"F7T_DTMOV", FWSX3Util():GetFieldType("F7T_DTMOV"), TamSX3("F7T_DTMOV")[1], TamSX3("F7T_DTMOV")[2], X3Picture("F7T_DTMOV"), Alltrim(RetTitle("F7T_DTMOV"))})
        AAdd(__aCampos, {"F7T_VALOR", FWSX3Util():GetFieldType("F7T_VALOR"), TamSX3("F7T_VALOR")[1], TamSX3("F7T_VALOR")[2], X3Picture("F7T_VALOR"), Alltrim(RetTitle("F7T_VALOR"))})
        AAdd(__aCampos, {"RECNO", "N", 14, 0, "", ""})
        AAdd(__aCampos, {"FILORI", "C", TamSX3("E1_FILORIG")[1], 0, "", ""})
        AAdd(__aCampos, {"SERIEND", "C", TamSX3("E1_SERIE")[1], 0, "", ""})
    Endif

    If Empty(__aIndex)
        Aadd(__aIndex, {"F7T_FILIAL","TITULO","CLIFOR"})
        Aadd(__aIndex, {"MARK"})
    Endif

    cMark := "X"

    If !__lSched
        cMark := " "
    Endif

    cQuery := "SELECT '" + cMark + "' MARK, F7T.F7T_FILIAL, F7T.F7T_PREFIX|| ' ' ||F7T.F7T_NUMTIT|| ' ' ||F7T.F7T_PARCEL|| ' ' ||F7T.F7T_TIPO TITULO, "
    cQuery += "F7T.F7T_PARTIC||'/'||F7T.F7T_LOJA|| ' - ' ||F7T.F7T_NOMPAR CLIFOR, F7T.F7T_VENCTO, F7T.F7T_VLRMOV, F7T.F7T_SEQBX, F7T.F7T_DTMOV, "
    cQuery += "F7T.F7T_VALOR, F7T.R_E_C_N_O_, SE1.E1_FILORIG FILORI, SE1.E1_SERIE SERIEND "
    cQuery += "FROM " + RetSqlName("F7T") + " F7T "
    cQuery += "INNER JOIN " + RetSqlName("SE1") + " SE1 "
    cQuery += "ON "
    cQuery += "SE1.E1_FILIAL = F7T.F7T_FILTIT "
    cQuery += "AND SE1.E1_PREFIXO = F7T.F7T_PREFIX "
    cQuery += "AND SE1.E1_NUM = F7T.F7T_NUMTIT "
    cQuery += "AND SE1.E1_PARCELA = F7T.F7T_PARCEL "
    cQuery += "AND SE1.E1_TIPO = F7T.F7T_TIPO "
    cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE "
    cQuery += "F7T_FILIAL >= '" + FwXFilial("F7T", MV_PAR02) + "' " //Filial De ?
    cQuery += "AND F7T_FILIAL <= '" + FwXFilial("F7T", MV_PAR03) + "' " //Filial Ate ?
    cQuery += "AND F7T_PREFIX >= '" + MV_PAR04 + "' " //Prefixo De ?
    cQuery += "AND F7T_PREFIX <= '" + MV_PAR05 + "' " //Prefixo Ate ?
    cQuery += "AND F7T_NUMTIT >= '" + MV_PAR06 + "' " //Nro Titulo De ?
    cQuery += "AND F7T_NUMTIT <= '" + MV_PAR07 + "' " //Nro Titulo Ate ?
    cQuery += "AND F7T_TIPO >= '" + MV_PAR08 + "' " //Tipo do Titulo De ?
    cQuery += "AND F7T_TIPO <= '" + MV_PAR09 + "' " //Tipo do Titulo Ate ?
    cQuery += "AND F7T_PARTIC >= '" + MV_PAR10 + "' "  //Participante De ?
    cQuery += "AND F7T_PARTIC <= '" + MV_PAR11 + "' " //Participante Ate ?

    If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
        cQuery += "AND F7T_DTMOV >= '" + DtoS(MV_PAR12) + "' " //Data do Movimento De ?
        cQuery += "AND F7T_DTMOV <= '" + DtoS(MV_PAR13) + "' " //Data do Movimento Ate ?
    Endif

    If !Empty(MV_PAR14)
        cQuery += "AND F7T_BANCO = '" + MV_PAR14 + "' " //Banco ?
    EndIf

    If !Empty(MV_PAR15)
        cQuery += "AND F7T_AGENCI = '" + MV_PAR15 + "' " //Agência ?
    EndIf

    If !Empty(MV_PAR16)
        cQuery += "AND F7T_CONTA = '" + MV_PAR16 + "' " //Conta ?
    EndIf

    cQuery += "AND F7T_NUMNOT = '"+Space(GetSx3Cache( "F7T_NUMNOT", 'X3_TAMANHO' ))+"' "
    cQuery += "AND F7T_STATUS = '1' "
    cQuery += "AND F7T.D_E_L_E_T_ = ' ' "

    If tlpp.ffunc("totvs.protheus.backoffice.techfin.util.createTemporaryTable")
        totvs.protheus.backoffice.techfin.util.createTemporaryTable(@__oTempDb, __aCampos, __aIndex, ChangeQuery(cQuery))
    Endif

Return

/*/{Protheus.doc} FMrkBrowse
    Realiza a criação da markBrowse que irá conter os registros que serão utilizados
    para a geração da ND e NC
    @type  Static Function
    @author Vitor Duca
    @since 07/05/2026
    @version 1.0
    @return lConfirm, Logical, Se o usuario confirmou a seleção dos movimentos
/*/
Static Function FMrkBrowse()
    local oMarkBrowse   as object
    local cAlias        as character
    local nColumn       as numeric
    local aColumns      as array
    local oModal        as object

    cAlias := ""
    nColumn := 0
    aColumns := {}

    If __oTempDb <> NIL
        cAlias := __oTempDb:GetAlias()
        oMarkBrowse := FWMarkBrowse():New()

        For nColumn := 1 To Len(__aCampos)
            If !(__aCampos[nColumn][1] $ "MARK|RECNO|FILORI|SERIEND")
                AAdd(aColumns, FWBrwColumn():New())
                aColumns[Len(aColumns)]:SetData(&("{||"+__aCampos[nColumn][1]+"}"))
                aColumns[Len(aColumns)]:SetType(__aCampos[nColumn][2])
                aColumns[Len(aColumns)]:SetTitle(__aCampos[nColumn][6])
                aColumns[Len(aColumns)]:SetSize(__aCampos[nColumn][3])
                aColumns[Len(aColumns)]:SetDecimal(__aCampos[nColumn][4])
                aColumns[Len(aColumns)]:SetPicture(__aCampos[nColumn][5])
            Endif
        Next
        
        oModal:= FWDialogModal():New()      
        oModal:SetEscClose(.T.)
        oModal:setTitle(STR0002) //"Gerar Notas de Déb./Créd."
        oModal:setSubTitle(STR0011) //"Selecione os movimentos para a geração das notas de débito/crédito"
        oModal:setSize( ( FWGetDialogSize( oMainWnd )[3] / 2 ) - 50, 750 )
        oModal:createDialog()

        oMarkBrowse:SetFieldMark("MARK")
        oMarkBrowse:SetOwner(oModal:getPanelMain())
        oMarkBrowse:SetMainProc("FINA708")
        oMarkBrowse:SetAlias(cAlias)
        oMarkBrowse:SetDescription("")
        oMarkBrowse:SetColumns(aColumns)
        oMarkBrowse:SetMark("X", cAlias, "MARK")
        oMarkBrowse:SetMenuDef("")
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:AddButton(STR0012, {|| F708Reload(oMarkBrowse) },,,, .F., 2 ) //"Parâmetros"
        oMarkBrowse:AddButton(STR0013, {|| FOkMarkBrw(), oModal:DeActivate() },,3) //"Confirmar"
        oMarkBrowse:DisableReport()
        oMarkBrowse:DisableConfig()
        oMarkBrowse:Activate()

        oModal:Activate()
    Endif
Return

/*/{Protheus.doc} FOkMarkBrw
    Confirmação dos registros selecionados
    @type  Static Function
    @author Vitor Duca
    @since 11/05/2026
    @version 1.0
/*/
Static Function FOkMarkBrw()
    FWMsgRun(, {|| FProcessND() }, '', STR0014) //"Gerando notas de débito/crédito, por favor aguarde..."
Return

/*/{Protheus.doc} F708Reload
    Recarrega os dados da tabela temporaria
    @type  Function
    @author Vitor Duca
    @since 06/05/2026
    @version 1.0
    @param oMarkBrowse, Object, Objeto visual que contem a FwMarkBrowse
/*/
Static Function F708Reload(oMarkBrowse as object)
    If Pergunte("FIN708", .T.)
        FWMsgRun(, {|| PrepareTmp(), oMarkBrowse:Refresh(.T.)}, '', STR0015) //"Carregando informações.."
    Endif
Return

/*/{Protheus.doc} FProcessND
    Processamento e geração da ND e NC, realizando a integração
    com o modulo SIGAFAT
    @type  Static Function
    @author Vitor Duca
    @since 07/05/2026
    @version 1.0
/*/
Static Function FProcessND()
    local cQuery    as character
    local cAlsTmp   as character
    local aRetorno  as array
    local cFilBkp   as character
    local aAreaSF2  as array
    local cTpLog    as character
    local cTextLog  as character
    Local lGrvNDTp4 as logical

    cFilBkp := cFilAnt
    aAreaSF2 := SF2->(FwGetArea())
    cTextLog := ""
    lGrvNDTp4 := FindFunction("GrvNDTp4")

    cQuery := "SELECT RECNO, FILORI, SERIEND "
    cQuery += "FROM " + __oTempDb:GetRealName() + " "
    cQuery += "WHERE MARK = 'X' "

    cAlsTmp := MpSysOpenQuery(cQuery)

    SF2->(DbSetOrder(17)) //F2_FILIAL, F2_IDNF

    While (cAlsTmp)->(!Eof())
        aRetorno := {}
        cFilAnt := (cAlsTmp)->FILORI
        cTpLog := "ERRO"
        cTextLog := ""

        F7T->(dbGoto((cAlsTmp)->RECNO))
        Begin Transaction
            If Reclock("F7T", .F.)
                If lGrvNDTp4
                    aRetorno := GrvNDTp4({{"Multa/Juros", F7T->F7T_VALOR}}, F7T->F7T_NUMTIT, (cAlsTmp)->SERIEND, F7T->F7T_PARTIC, F7T->F7T_LOJA, .F., .T.)
                    cTextLog := aRetorno[MENSAGEM]
                    
                    If aRetorno[NOTAGERADA]
                        cTpLog := "MENSAGEM"
                        F7T->F7T_IDNF := aRetorno[IDNOTA]

                        If SF2->(DbSeek(FWxFilial("SF2") + aRetorno[IDNOTA]))
                            cTextLog := STR0016 + SF2->F2_SERIE + STR0017 +SF2->F2_DOC + STR0018//"Nota de débito/crédito - Série: "#" Numero: "#" gerada com sucesso!"
                            F7T->F7T_NUMNOT := SF2->F2_DOC
                        Endif
                    Endif

                    ProcLogIni( {}, F7T->F7T_IDF7T, "GrvNDTp4")
                    ProcLogAtu( cTpLog, "GERANOTA", cTextLog, , .T.)
                Endif
                F7T->(MsUnLock())
            Endif
        End Transaction
        (cAlsTmp)->(dbSkip())
    EndDo

    (cAlsTmp)->(DbCloseArea())
    cFilAnt := cFilBkp

    FwRestArea(aAreaSF2)
Return

/*/{Protheus.doc} ViewBill
    Ação do duplo click da grid dos titulos

    @type  Function
    @author Vitor Duca
    @since 05/05/2026
    @version 1.0  
/*/
Static Function ViewBill() as logical
    Local cKeyBill  as Character
    Local oModel    as Object
    Local aArea     as Array
    Local aAreaSE1  as Array
    
    Private cCadastro as Character

    aArea := FwGetArea()
    aAreaSE1 := SE1->(FwGetArea())

    oModel	:= FWModelActive()
    cKeyBill := oModel:GetValue("SE1DETAIL", "E1_PREFIXO") + oModel:GetValue("SE1DETAIL", "E1_NUM") +  oModel:GetValue("SE1DETAIL", "E1_PARCELA") + oModel:GetValue("SE1DETAIL", "E1_TIPO")

    If !Empty(cKeyBill)
        SE1->(DbSetOrder(1)) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
        SE1->(MsSeek(FwxFilial("SE1") + cKeyBill))
        cCadastro := STR0029 //"Contas a Receber - VISUALIZAR"
        FWMsgRun(, {|| FA280Visua("SE1", SE1->(Recno()), 2) }, "", STR0015 ) //"Carregando informações.."
    Endif

    FwRestArea(aAreaSE1)
    FwRestArea(aArea)
Return .T.

/*/{Protheus.doc} ViewInvoic
    Ação do duplo click da grid das notas

    @type  Function
    @author Vitor Duca
    @since 05/05/2026
    @version 1.0  
/*/
Static Function ViewInvoic() as logical
    Local cKeyNF    as Character
    Local oModel    as Object
    Local aArea     as Array
    Local aAreaSF2  as Array

    aArea := FwGetArea()
    aAreaSF2 := SF2->(FwGetArea())

    oModel	:= FWModelActive()
    cKeyNF := oModel:GetValue("F7TMASTER", "F7T_IDNF")

    If !Empty(cKeyNF)
        SF2->(DbSetOrder(17)) //F2_FILIAL, F2_IDNF
        SF2->(MsSeek(FwxFilial("SF2") + cKeyNF))

        //-- Visualização da NF de Saída
		FWMsgRun(, {|| Mc090Visual( "SF2", SF2->( recno() ), 2 ) }, "", STR0015 ) //"Carregando informações.."
    Endif

    FwRestArea(aAreaSF2)
    FwRestArea(aArea)

Return .T.

/*/{Protheus.doc} F708Log
    Apresentação do historico de operações que ocorreram no registro posicionado (CV8)
    @type  Function
    @author Vitor Duca
    @since 15/05/2026
    @version 1.0
/*/
Function F708Log()
    ProcLogView( cFilAnt, F7T->F7T_IDF7T)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F708GrvF7T
    @description Função responsável por capturar os dados do modelo 
    de baixa (FINM010) e repassar a integração de Juros e Multa 
    na tabela F7T para posterior geração de Nota de Débito.

    @param oModel, object, Instância do FWFormModel do FINM010
    @param cBankCode, character, Código do banco (opcional, pode ser capturado na FK5)
    @param cAgency, character, Código da agência (opcional, pode ser capturado na FK5)
    @param cAccount, character, Número da conta (opcional, pode ser capturado na FK5)

    @author fabio.casagrande
    @since 15/04/2026
    @type function
/*/
//-------------------------------------------------------------------
Function F708GrvF7T(oModel as object, cBankCode as character, cAgency as character, cAccount as character) as logical
    Local lSuccess as logical
    Local oModelFK1 as object
    Local oModelFK6 as object
    Local oModelFKA as object
    Local nI as numeric
    Local dMovement as date
    Local dDueDate as date
    Local nIncrease as numeric
    Local nMovValue as numeric
    Local cTypeDoc as character
    Local cIdMov as character
    Local cIdDoc as character
    Local cSeqMov as character
    Local cPrefixo as character
    Local cNumber as character
    Local cParcel as character
    Local cType as character
    Local cCliFor as character
    Local cStore as character
    Local cName as character
    Local cBranch as character
    Local aArea as array
    Local aAreaSE1 as array
    Local aAreaFK7 as array
    Local aSaveLine as array
    Local jData as json
    Local oDebitInv as object

    Default oModel := Nil
    Default cBankCode := ""
    Default cAgency := ""  
    Default cAccount := ""
    
    lSuccess := .F.
    nI := 1 
    dMovement := dDataBase 
    dDueDate := dDataBase 
    nIncrease  := 0 
    nMovValue := 0 
    cTypeDoc := ""
    cIdMov := ""
    cIdDoc := ""
    cSeqMov := ""
    cPrefixo := ""
    cNumber := ""
    cParcel := ""
    cType := ""
    cCliFor := ""
    cStore := ""
    cName := ""
    cBranch := ""
    aArea := FwGetArea()
    aAreaSE1 := {}
    aAreaFK7 := {}
    aSaveLine := {}

    If oModel != Nil .And. oModel:isActive() .and. !Empty(cBankCode) .and. !Empty(cAgency) .and. !Empty(cAccount)

        aSaveLine := FWSaveRows()

        oModelFK1 := oModel:GetModel("FK1DETAIL")
        oModelFK6 := oModel:GetModel("FK6DETAIL")
        oModelFKA := oModel:GetModel("FKADETAIL")

        If oModelFK1 != Nil .And. oModelFK6 != Nil .And. oModelFKA != Nil .And. !oModelFK1:isEmpty() .And. !oModelFK6:isEmpty() .And. !oModelFKA:isEmpty()
            
            // Verifica se houve Juros ou Multa na baixa
            For nI := 1 To oModelFK6:Length()
                oModelFK6:GoLine(nI)
                If !oModelFK6:IsDeleted()
                    cTypeDoc := oModelFK6:GetValue("FK6_TPDOC")
                    If cTypeDoc $ "JR|MT|VA" // Juros/Multa/VA
                        nIncrease += oModelFK6:GetValue("FK6_VALMOV")
                    EndIf
                EndIf
            Next nI

            // Se não houver juros nem multa, não grava F7T
            If nIncrease > 0

                // Busca dados na FKA
                cIdMov := oModelFKA:GetValue('FKA_IDORIG')

                // Busca dados na FK1
                oModelFK1:GoLine(1)
                cIdDoc := oModelFK1:GetValue("FK1_IDDOC")
                dMovement := oModelFK1:GetValue("FK1_DATA")
                nMovValue := oModelFK1:GetValue("FK1_VALOR")
                cSeqMov := oModelFK1:GetValue("FK1_SEQ")

                // Busca dados na FK7
                aAreaFK7  := FK7->(FwGetArea())
                FK7->(DbSetOrder(5)) // FK7_IDDOC
                If FK7->(DbSeek(cIdDoc))              
                    // Busca dados na SE1
                    aAreaSE1  := SE1->(FwGetArea())
                    SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
                    SE1->(DbSeek(FK7->FK7_FILTIT + FK7->FK7_PREFIX + FK7->FK7_NUM + FK7->FK7_PARCEL + FK7->FK7_TIPO))

                    cBranch := SE1->E1_FILIAL
                    cPrefixo := SE1->E1_PREFIXO
                    cNumber := SE1->E1_NUM
                    cParcel := SE1->E1_PARCELA
                    cType := SE1->E1_TIPO
                    dDueDate := SE1->E1_VENCTO
                    cCliFor := SE1->E1_CLIENTE
                    cStore := SE1->E1_LOJA
                    cName := Alltrim(SE1->E1_NOMCLI)
                    
                    FwRestArea(aAreaSE1)
                EndIf
                    
                FwRestArea(aAreaFK7)   

                // Prepara os dados para a DebtitTaxInvoice
                jData := JsonObject():New()
                jData['movementBranch'] := FwxFilial("F7T")
                jData['sourceTable'] := "FK1"
                jData['movementIdentification'] := cIdMov
                jData['movementType'] := "1"
                jData['documentId'] := cIdDoc
                jData['billBranch'] := cBranch
                jData['billPrefix'] := cPrefixo
                jData['billNumber'] := cNumber
                jData['billInstallment'] := cParcel
                jData['billType'] := cType
                jData['billParticipantCode'] := cCliFor
                jData['billParticipantStore'] := cStore
                jData['participantName'] := cName
                jData['billDueDate'] := dDueDate
                jData['movementDate'] := dMovement
                jData['movementSequence'] := cSeqMov
                jData['movementValue'] := nMovValue
                jData['increaseValue'] := nIncrease
                jData['bankCode'] := cBankCode
                jData['bankBranch'] := cAgency
                jData['bankAccountNumber'] := cAccount

                oDebitInv := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():new("F7T")
                If MethIsMemberOf(oDebitInv, "prepareRecordF7T") .And. oDebitInv:getValidatedEnvironment()
                    oDebitInv:setParameters(jData)
                    oDebitInv:prepareRecordF7T()
                    lSuccess := oDebitInv:recordInsertF7T()
                EndIf
            EndIf
            FWRestRows(aSaveLine)  
        EndIf

        // NÃO destruir modelos filhos obtidos de GetModel() — pertencem ao oModel pai
        // Apenas limpa as referências locais atribuindo NIL
        oModelFK1 := Nil
        oModelFK6 := Nil
        oModelFKA := Nil
    EndIf

    FwRestArea(aArea)

Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} F708EstF7T
    @description Função responsável por repassar o estorno (exclusão) 
    do controle de Nota de Débito (F7T) gerado na baixa, 
    caso a baixa do título seja cancelada ou excluída.

    @param oModel, object, Instância do FWFormModel do FINM010

    @author fabio.casagrande
    @since 15/04/2026
    @type function
/*/
//-------------------------------------------------------------------
Function F708EstF7T(oModel as object) as logical
    Local lSuccess as logical
    Local cBranch as character
    Local cIdMov as character
    Local oModelFK1 as object
    Local jData as json
    Local oDebitInv as object
    Local aSaveLine as array

    lSuccess := .F.

    If oModel != Nil .And. oModel:isActive()

        aSaveLine := FWSaveRows()

        oModelFK1 := oModel:getModel("FK1DETAIL")

        If oModelFK1 != Nil
            oModelFK1:GoLine(1)
            cBranch := xFilial("F7T")
            cIdMov := oModelFK1:GetValue("FK1_IDFK1")

            jData := JsonObject():New()
            jData['movementBranch'] := cBranch
            jData['sourceTable'] := "FK1"
            jData['movementIdentification'] := cIdMov

            oDebitInv := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():new("F7T")
            If MethIsMemberOf(oDebitInv, "prepareDeletionF7T") .And. oDebitInv:getValidatedEnvironment()
                oDebitInv:setParameters(jData)
                oDebitInv:prepareDeletionF7T()
                lSuccess := oDebitInv:recordDeletionF7T()
            EndIf
        EndIf
        FWRestRows(aSaveLine)          
    EndIf

    // NÃO destruir modelos filhos obtidos de GetModel() — pertencem ao oModel pai
    // Apenas limpa as referências locais atribuindo NIL
    oModelFK1 := Nil

Return lSuccess

/*/{Protheus.doc} F708EstNF
    @description Função responsável por retirar o vinculo entre a nota e a F7T
    quando a exclusão da nota ocorre pelo Faturamento (MATA600 ou MATA521)
    @type  Function
    @author Vitor Duca
    @since 21/05/2026
    @version 1.0
    @param cIdNF, character, ID unico da NF gerada, representa o campo F2_IDNF
    @param cDoc, character, Representa o numero da nota de debito F2_DOC
    @param cSerie, character, Representa a serie da nota de debito F2_SERIE
/*/
Function F708EstNF(cIdNF as character, cDoc as character, cSerie as character)
    Local cQuery    as character
    Local nParam    as numeric
    Local nRecno    as numeric
    Local cFunName  as character
    Local aArea     as array
    Local aAreaF7T  as array

    cQuery := ""
    nParam := 1
    nRecno := 0
    cFunName := AllTrim(FunName())
    aArea := {}
    aAreaF7T := {}

    If ChkFile("F7T") .and. !FwIsInCallStack("F708EstF7T")
        If __oEstNF == NIL
            cQuery := "SELECT R_E_C_N_O_ RECNOF7T "
            cQuery += "FROM " + RetSqlName("F7T") + " "
            cQuery += "WHERE F7T_IDNF = ? "
            cQuery += "AND D_E_L_E_T_ = ? "

            __oEstNF := FWExecStatement():New( cQuery )
        Endif
        
        __oEstNF:setString(nParam++, cIdNF)
        __oEstNF:setString(nParam++, " ")
        nRecno := __oEstNF:execScalar("RECNOF7T")

        If nRecno > 0
            aArea := FwGetArea()
            aAreaF7T := F7T->(FwGetArea())

            F7T->(DbGoto(nRecno))

            RecLock("F7T", .F.)
                F7T->F7T_IDNF := ""
                F7T->F7T_NUMNOT := ""
            F7T->(MsUnLock())

            ProcLogIni( {}, F7T->F7T_IDF7T, cFunName)
            ProcLogAtu("MENSAGEM", "DELETANOTA", STR0016 + cSerie + STR0017 + cDoc + STR0021 + cFunName, , .T.) //"Nota de debito/credito - Serie: "#" Numero: "#" excluida pela rotina "

            FwRestArea(aAreaF7T)
            FwRestArea(aArea)
        Endif
    Endif
Return

/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@return  aParam
/*/
Static Function SchedDef() as Array
	Local aParam    as Array

	aParam := {"P",;    //Tipo R para relatorio P para processo
			   "FIN708" ,;    //Nome do grupo de perguntas (SX1)
			   Nil,;    //cAlias (para Relatorio)
			   Nil,;	//aArray (para Relatorio)
			   Nil,;	//Titulo (para Relatorio)
			   Nil,;	//Nome do Relatório
			   .F.,;	//Indica se permite que o agendamento possa ser cadastrado como sempre ativo
			   .F.}	    //Indica que o agendamento pode ser realizado por filiais
			
Return aParam
