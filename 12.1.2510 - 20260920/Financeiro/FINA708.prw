#include "protheus.ch"
#include "FwMvcDef.ch"
#include "fwmbrowse.ch"
#include "FINA708.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE NOTAGERADA 1
#DEFINE IDNOTA 2
#DEFINE MENSAGEM 3
#DEFINE CAMPO 1
#DEFINE TIPO 2
#DEFINE TAMANHO 3
#DEFINE DECIMAL 4
#DEFINE PICTURE 5
#DEFINE TITULO 6
#DEFINE X3_SIZE 1
#DEFINE MULTA_JUROS "1"
#DEFINE ANTECIPACAO "2"
#DEFINE IMPRIME_DANFE 1

Static __lSched     := FWGetRunSchedule()
Static __oTempDb    := NIL
Static __aCampos    := {}
Static __aIndex     := {}

/*/{Protheus.doc} FINA708
    Faturamento de Encargos e Antecipações (IBS/CBS)

    @type       Function
    @author     Vitor Duca
    @since      17/04/2026
    @version    1.0
/*/
Function FINA708()
    local cLockName as character

    cLockName := cEmpAnt + " - FINA708"

    If AliasInDic("F7T")
        If __lSched
            If LockByName( cLockName, .T./*lEmpresa*/, .F./*lFilial*/ )
                F708GerND()
                UnLockByName(cLockName, .T./*lEmpresa*/, .F./*lFilial*/ )
            Endif
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
    ADD OPTION aRotina TITLE STR0039    ACTION 'F708IntTSS(1)'      OPERATION 9                         ACCESS 0 //"Download Danfe/XML"
    ADD OPTION aRotina TITLE STR0040    ACTION 'F708IntTSS(2)'      OPERATION 9                         ACCESS 0 //"Status da ND"

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
    oStruSE1    := FWFormStruct(1, 'SE1', { |x| ALLTRIM(x) $ "E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI"} )
    oStruSF2    := FWFormStruct(1, 'SF2', { |x| ALLTRIM(x) $ "F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT"} )
    oModel      := MPFormModel():New( 'FINA718', /*bPreValidacao*/, { |oModel| FPosValid(oModel) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )    

    oModel:AddFields( 'F7TMASTER', /*cOwner*/, oStruF7T, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )   
    oModel:AddGrid( 'SE1DETAIL', 'F7TMASTER', oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/{ || LoadBill() } )
    oModel:AddGrid( 'SF2DETAIL', 'F7TMASTER', oStruSF2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/{ || LoadInvoic() } )

    oModel:GetModel('SE1DETAIL'):SetOnlyQuery( .T. )
    oModel:GetModel("SE1DETAIL"):SetOptional( .T. )

    oModel:GetModel('SF2DETAIL'):SetOnlyQuery( .T. )
    oModel:GetModel("SF2DETAIL"):SetOptional( .T. )

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
    
    If __lSched .or. ( !__lSched .and. Pergunte("FIN708", .T.) )
        
        If ValType(MV_PAR01) == "C"
            MV_PAR01 := Val(MV_PAR01)
        Endif

        If VldParams()
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
    Local cTipoND       as character

    cNDTES := ""
    cNDSERIE := ""
    lRet := .T.
    cTipoND := "4"

    If MV_PAR01 == Val(ANTECIPACAO)
        cTipoND := "6"
    Endif
    
    If FindFunction("RetParam")
        cNDTES := RetParam(SuperGetMv("MV_NDTES",.F.,""), cTipoND, GetSX3Cache("D2_TES", "X3_TAMANHO"))
        cNDSERIE := RetParam(SuperGetMv("MV_NDSERIE",.F.,""), cTipoND, GetSX3Cache("F2_SERIE", "X3_TAMANHO"))
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
    local oExecStm  as object
    local nParam    as numeric

    nParam := 1

    If Empty(__aCampos)
        AAdd(__aCampos, F708GtStru("MARK"))
        AAdd(__aCampos, F708GtStru("F7T_FILIAL"))
        AAdd(__aCampos, F708GtStru("TITULO"))
        AAdd(__aCampos, F708GtStru("CLIFOR"))
        AAdd(__aCampos, F708GtStru("F7T_VENCTO"))
        AAdd(__aCampos, F708GtStru("F7T_VLRMOV"))
        AAdd(__aCampos, F708GtStru("F7T_SEQBX"))
        AAdd(__aCampos, F708GtStru("F7T_DTMOV"))
        AAdd(__aCampos, F708GtStru("F7T_VALOR"))
        AAdd(__aCampos, F708GtStru("RECNO"))
        AAdd(__aCampos, F708GtStru("FILORI"))
        AAdd(__aCampos, F708GtStru("SERIEND"))
    Endif

    If Empty(__aIndex)
        Aadd(__aIndex, {"F7T_FILIAL","TITULO","CLIFOR"})
        Aadd(__aIndex, {"MARK"})
    Endif

    cMark := "X"

    If !__lSched
        cMark := " "
    Endif

    cQuery := "SELECT ? MARK, F7T.F7T_FILIAL, F7T.F7T_PREFIX|| ' ' ||F7T.F7T_NUMTIT|| ' ' ||F7T.F7T_PARCEL|| ' ' ||F7T.F7T_TIPO TITULO, "
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
    cQuery += "F7T_FILIAL >= ? " //Filial De ?
    cQuery += "AND F7T_FILIAL <= ? " //Filial Ate ?
    cQuery += "AND F7T_PREFIX >= ? " //Prefixo De ?
    cQuery += "AND F7T_PREFIX <= ? " //Prefixo Ate ?
    cQuery += "AND F7T_NUMTIT >= ? " //Nro Titulo De ?
    cQuery += "AND F7T_NUMTIT <= ? " //Nro Titulo Ate ?
    cQuery += "AND F7T_TIPO >= ? " //Tipo do Titulo De ?
    cQuery += "AND F7T_TIPO <= ? " //Tipo do Titulo Ate ?
    cQuery += "AND F7T_PARTIC >= ? "  //Participante De ?
    cQuery += "AND F7T_PARTIC <= ? " //Participante Ate ?

    If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
        cQuery += "AND F7T_DTMOV >= ? " //Data do Movimento De ?
        cQuery += "AND F7T_DTMOV <= ? " //Data do Movimento Ate ?
    Endif

    If !Empty(MV_PAR14)
        cQuery += "AND F7T_BANCO = ? " //Banco ?
    EndIf

    If !Empty(MV_PAR15)
        cQuery += "AND F7T_AGENCI = ? " //Agência ?
    EndIf

    If !Empty(MV_PAR16)
        cQuery += "AND F7T_CONTA = ? " //Conta ?
    EndIf

    cQuery += "AND F7T_TIPMOV = ? " //Tipo da Nota de Debito/Cred. ?
    cQuery += "AND F7T_NUMNOT = ? "
    cQuery += "AND F7T_STATUS = ? "
    cQuery += "AND F7T.D_E_L_E_T_ = ? "

    oExecStm := FwExecStatement():new(cQuery)
    oExecStm:setString(nParam++, cMark) //SELECT MARK
    oExecStm:setString(nParam++, FwXFilial("F7T", MV_PAR02)) //F7T_FILIAL >=
    oExecStm:setString(nParam++, FwXFilial("F7T", MV_PAR03)) //F7T_FILIAL <=
    oExecStm:setString(nParam++, MV_PAR04) //F7T_PREFIX >=
    oExecStm:setString(nParam++, MV_PAR05) //F7T_PREFIX <=
    oExecStm:setString(nParam++, MV_PAR06) //F7T_NUMTIT >=
    oExecStm:setString(nParam++, MV_PAR07) //F7T_NUMTIT <=
    oExecStm:setString(nParam++, MV_PAR08) //F7T_TIPO >=
    oExecStm:setString(nParam++, MV_PAR09) //F7T_TIPO <=
    oExecStm:setString(nParam++, MV_PAR10) //F7T_PARTIC >=
    oExecStm:setString(nParam++, MV_PAR11) //F7T_PARTIC <=

    If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
        oExecStm:setDate(nParam++, MV_PAR12) //F7T_DTMOV >=
        oExecStm:setDate(nParam++, MV_PAR13) //F7T_DTMOV <=
    endif

    If !Empty(MV_PAR14)
        oExecStm:setString(nParam++, MV_PAR14) //F7T_BANCO
    EndIf

    If !Empty(MV_PAR15)
        oExecStm:setString(nParam++, MV_PAR15) //F7T_AGENCI
    EndIf

    If !Empty(MV_PAR16)
       oExecStm:setString(nParam++, MV_PAR16) //F7T_CONTA
    EndIf

    oExecStm:setString(nParam++, cValToChar(MV_PAR01)) //F7T_TIPMOV
    oExecStm:setString(nParam++, Space(GetSx3Cache( "F7T_NUMNOT", 'X3_TAMANHO' ))) //F7T_NUMNOT
    oExecStm:setString(nParam++, "1") //F7T_STATUS
    oExecStm:setString(nParam++, " ") //D_E_L_E_T_

    If tlpp.ffunc("totvs.protheus.backoffice.techfin.util.createTemporaryTable")
        totvs.protheus.backoffice.techfin.util.createTemporaryTable(@__oTempDb, __aCampos, __aIndex, ChangeQuery(oExecStm:getFixQuery()))
    Endif

Return

/*/{Protheus.doc} F708GtStru
    Retorna a estrutura do campo passado por parametro de acordo com o 
    dicionario
    @type  Static Function
    @author Vitor Duca
    @since 22/06/2026
    @version 1.0
    @param cCampo, character, Campo do dicionario que será verificado
    @return aStrCampo, array, Matriz contendo as informações do campo
        aStrCampo[1] = Nome
        aStrCampo[2] = Tipo
        aStrCampo[3] = Tamanho
        aStrCampo[4] = Decimal
        aStrCampo[5] = Picture
        aStrCampo[6] = Titulo
/*/
Static Function F708GtStru(cCampo as character) as array
    local aStrCampo as array

    aStrCampo := {}

    Do Case
        Case cCampo == "MARK"
            aStrCampo := {"MARK", "C", 1, 0, "", "", ""}
        Case cCampo == "TITULO"
            aStrCampo := {"TITULO", "C", TamSX3("F7T_PREFIX")[X3_SIZE] + TamSX3("F7T_NUMTIT")[X3_SIZE] + TamSX3("F7T_PARCEL")[X3_SIZE] + TamSX3("F7T_TIPO")[X3_SIZE] + 3, 0, "@!", STR0030} //Dados do titulo
        Case cCampo == "CLIFOR"
            aStrCampo := {"CLIFOR", "C", TamSX3("F7T_PARTIC")[X3_SIZE] + TamSX3("F7T_LOJA")[X3_SIZE] + TamSX3("F7T_NOMPAR")[X3_SIZE] + 4, 0, "@!", STR0031} //Participante
        Case cCampo == "RECNO"
            aStrCampo := {"RECNO", "N", 14, 0, "", "", ""}
        Case cCampo == "FILORI"
            aStrCampo := {"FILORI", "C", TamSX3("E1_FILORIG")[X3_SIZE], 0, "", "", ""}
        Case cCampo == "SERIEND"
            aStrCampo := {"SERIEND", "C", TamSX3("E1_SERIE")[X3_SIZE], 0, "", "", ""}
        OtherWise
            aStrCampo := FWSX3Util():GetFieldStruct(cCampo)
            Aadd(aStrCampo, Alltrim(FwX3Titulo(cCampo)))
    EndCase

Return aStrCampo

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
            If !(__aCampos[nColumn][CAMPO] $ "MARK|RECNO|FILORI|SERIEND")
                AAdd(aColumns, FWBrwColumn():New())
                aColumns[Len(aColumns)]:SetData(&("{||"+__aCampos[nColumn][CAMPO]+"}"))
                aColumns[Len(aColumns)]:SetType(__aCampos[nColumn][TIPO])
                aColumns[Len(aColumns)]:SetTitle(__aCampos[nColumn][TITULO])
                aColumns[Len(aColumns)]:SetSize(__aCampos[nColumn][TAMANHO])
                aColumns[Len(aColumns)]:SetDecimal(__aCampos[nColumn][DECIMAL])
                aColumns[Len(aColumns)]:SetPicture(__aCampos[nColumn][PICTURE])
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
    local lGrvNDTp4 as logical
    local oExecStm  as object
    local oStatPedV as object
    local lGrvNDTp6 as logical
    local cPedido   as character

    cFilBkp := cFilAnt
    aAreaSF2 := SF2->(FwGetArea())
    cTextLog := ""
    lGrvNDTp4 := FindFunction("GrvNDTp4")
    lGrvNDTp6 := FindFunction("GrvNDTp6")
    oStatPedV := NIL
    cPedido := ""
    aRetorno := Array(3)

    cQuery := "SELECT RECNO, FILORI, SERIEND "
    cQuery += "FROM " + __oTempDb:GetRealName() + " "
    cQuery += "WHERE MARK = ? "

    oExecStm := FwExecStatement():new(cQuery)
    oExecStm:setString(1, "X")

    cAlsTmp := oExecStm:openAlias()

    SF2->(DbSetOrder(17)) //F2_FILIAL, F2_IDNF

    Begin Transaction
        While (cAlsTmp)->(!Eof())
            aRetorno[NOTAGERADA] := .F.
            aRetorno[IDNOTA] := ""
            aRetorno[MENSAGEM] := ""
            cFilAnt := (cAlsTmp)->FILORI
            cTpLog := "ERRO"
            cTextLog := ""

            F7T->(dbGoto((cAlsTmp)->RECNO))

            If Reclock("F7T", .F.)
                If lGrvNDTp4 .and. F7T->F7T_TIPMOV == MULTA_JUROS
                    aRetorno := GrvNDTp4({{"Multa/Juros", F7T->F7T_VALOR}}, F7T->F7T_NUMTIT, (cAlsTmp)->SERIEND, F7T->F7T_PARTIC, F7T->F7T_LOJA, .F., .T.)
                Elseif lGrvNDTp6 .and. F7T->F7T_TIPMOV == ANTECIPACAO
                    aRetorno[MENSAGEM] := STR0032 //"A antecipação não esta vinculada a nenhum pedido de venda, sendo assim não é possivel gerar a nota de débito"
                    cPedido := F708GtPedV(F7T->F7T_IDDOC, @oStatPedV)
                    If !Empty(cPedido)
                        aRetorno := GrvNDTp6(cPedido, { F7T->F7T_IDDOC }, F7T->F7T_PARTIC, F7T->F7T_LOJA, F7T->F7T_VALOR)
                    Endif
                Endif

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
                F7T->(MsUnLock())
            Endif
        
            (cAlsTmp)->(dbSkip())
        EndDo
    End Transaction
    
    (cAlsTmp)->(DbCloseArea())
    cFilAnt := cFilBkp

    if oStatPedV <> NIL
        oStatPedV:Destroy()
    endif

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

/*/{Protheus.doc} F708IntTSS
    Função responsavel pelas integrações com o TSS sendo elas
    - 1 = Impressão da DANFE
    - 2 = Consulta status de transmissão da ND
    @type       Function
    @author     Vitor Duca
    @since      01/09/2026
    @version    1.0
    @param nOption, Numeric, Define qual a opção que será utilizada para integração com o TSS
/*/
Function F708IntTSS(nOption as numeric)
    Local aAreaSF2      as array
    Local aAreaSE1      as array
    Local aArea         as array
    Local cFilBkp       as character

    If F708TssEnv(F7T->F7T_IDNF)
        aArea := FwGetArea()
        aAreaSF2 := SF2->(FwGetArea())
        aAreaSE1 := SE1->(FwGetArea())

        SF2->(DbSetOrder(17)) //F2_FILIAL, F2_IDNF
        SE1->(DbSetOrder(1)) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
        If SF2->(MsSeek(FwxFilial("SF2") + F7T->F7T_IDNF)) .and. SE1->(DbSeek(F7T->(F7T_FILTIT+F7T_PREFIX+F7T_NUMTIT+F7T_PARCEL+F7T_TIPO)))
            cFilBkp := cFilAnt
            cFilAnt := SE1->E1_FILORIG

            If nOption == IMPRIME_DANFE
                F708Danfe(SF2->F2_FIMP, "", SF2->F2_EMISSAO)
            Else
                SpedNFe4Mnt("SF2")
            Endif

            cFilAnt := cFilBkp
        Endif

        FwRestArea(aAreaSF2)
        FwRestArea(aAreaSE1)
        FwRestArea(aArea)
    Endif

Return

/*/{Protheus.doc} F708TssEnv
    Verifica os pré-requisitos para realizar a integração com o TSS
    @type  Function
    @author Vitor Duca
    @since 01/09/2026
    @version 1.0
    @param cIdNF, character, Identificador unico da NF (F2_IDNF)
    @return logical, Define se o ambiente esta preparado para integração com o TSS
/*/
Function F708TssEnv(cIdNF as character) as logical
    Local lRet  as logical

    lRet := .T.

    If Empty(cIdNF)
        Help(,,"SEMNOTA",, STR0033,1,0, NIL, NIL, NIL, NIL, NIL, { STR0034 }) //"Nota de débito ainda não foi gerada."#"Realize o processo de geração da nota de débito."
        lRet := .F.
    Endif

    If lRet .and. !( tlpp.ffunc("totvs.protheus.backoffice.techfin.util.TssIsReady") .and. totvs.protheus.backoffice.techfin.util.TssIsReady() )
        Help(,,"TSSCONFIGURADO",, STR0035,1,0, NIL, NIL, NIL, NIL, NIL, {}) //"Ambiente TSS não está configurado no ambiente!"
        lRet := .F.
    Endif

Return lRet

/*/{Protheus.doc} F708Danfe
    Realiza a impressão da DANFE referente a ND
    @type  Function
    @author Vitor Duca
    @since 03/09/2026
    @version 1.0
    @param cF2FIMP, character, Deve representar o campo F2_FIMP, será utilizado para saber se a ND esta transmitida
    @param cIdEnt, character, Entidade configurada no TSS para transmissão de notas
    @param dEmisNF, date, Data de emissão da ND, representa o campo F2_EMISSAO
/*/
Function F708Danfe(cF2FIMP as character, cIdEnt as character, dEmisNF as date)
    Local cError        as character
    Local cFilePrint    as character
    Local oDanfe        as object

    Default cF2FIMP := ""
    Default cIdEnt := ""
    Default dEmisNF := CTOD("//")

    cError := ""
    cFilePrint := ""
    oDanfe := NIL

    If Upper(Alltrim(cF2FIMP)) <> "S"
        Help(,,"NAOAUTORIZADA",, STR0036, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0037 }) //"Nota de débito ainda não foi autorizada."#"Aguarde a autorização da nota antes de realizar a impressão da DANFE."
        Return
    Endif
    
    If Empty(cIdEnt)
        cIdEnt := GetCfgEntidade(@cError)
    Endif

    If !Empty(cIdEnt)
        cFilePrint := "DANFE_" + Dtos(MsDate()) + StrTran(Time(), ":", "")
        oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, .F., NIL, .T., NIL, NIL, NIL, NIL, NIL, NIL, .T.)

        SetMVValue("NFSIGW", "MV_PAR07", dEmisNF)
	    SetMVValue("NFSIGW", "MV_PAR08", dEmisNF)
        Pergunte("NFSIGW", .F.)
        tssExecRdm("PrtNfeSef", .F., cIdEnt,,, oDanfe, NIL, cFilePrint, .T., 0)
    Else
        Help(,,"ENTIDADETSS",, STR0038 + cError, 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"Entidade TSS não configurada: "
    Endif
Return

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

/*/{Protheus.doc} LoadBill
    Carrega as informações do titulo que esta vinculado a F7T
    @type  Static Function
    @author Vitor Duca
    @since 02/07/2026
    @version 1.0
    @return aRetorno, array, Matriz contendo as informações do titulo que será visualizado no MVC
    @example
    aGrid := LoadBill()
/*/
Static Function LoadBill() as array
    local aRetorno  as array
    local aGrid     as array
    local cAlsTmp   as character
    local cQuery    as character
    local oExecQry  as object
    local nParam    as numeric

    aRetorno := {}
    aGrid := {}
    cAlsTmp := ""
    cQuery := ""
    nParam := 1

    cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, R_E_C_N_O_ RECNO "
    cQuery += "FROM " + RetSqlName("SE1") + " "
    cQuery += "WHERE "
    cQuery += "E1_FILIAL = ? "
    cQuery += "AND E1_PREFIXO = ? "
    cQuery += "AND E1_NUM = ? "
    cQuery += "AND E1_PARCELA = ? "
    cQuery += "AND E1_TIPO = ? "
    cQuery += "AND D_E_L_E_T_ = ? "

    oExecQry := FwExecStatement():new(ChangeQuery(cQuery))
    oExecQry:setString(nParam++, F7T->F7T_FILTIT)
    oExecQry:setString(nParam++, F7T->F7T_PREFIX)
    oExecQry:setString(nParam++, F7T->F7T_NUMTIT)
    oExecQry:setString(nParam++, F7T->F7T_PARCEL)
    oExecQry:setString(nParam++, F7T->F7T_TIPO)
    oExecQry:setString(nParam++, " ")

    cAlsTmp := oExecQry:openAlias()

    If !(cAlsTmp)->(EoF())
		aAdd( aGrid , (cAlsTmp)->E1_PREFIXO)
		aAdd( aGrid , (cAlsTmp)->E1_NUM)
		aAdd( aGrid , (cAlsTmp)->E1_PARCELA)
		aAdd( aGrid , (cAlsTmp)->E1_TIPO)
		aAdd( aGrid , (cAlsTmp)->E1_CLIENTE)
		aAdd( aGrid , (cAlsTmp)->E1_LOJA)
		aAdd( aGrid , (cAlsTmp)->E1_NOMCLI)

		aAdd(aRetorno, {(cAlsTmp)->RECNO, aGrid})
	Endif

    (cAlsTmp)->(DbCloseArea())

Return aRetorno

/*/{Protheus.doc} LoadInvoic
    Carrega as informações da nota de débito que esta vinculado a F7T
    @type  Static Function
    @author Vitor Duca
    @since 02/07/2026
    @version 1.0
    @return aRetorno, array, Matriz contendo as informações da nota que será visualizada no MVC
    @example
    aGrid := LoadInvoic()
/*/
Static Function LoadInvoic() as array
    local aRetorno  as array
    local aGrid     as array
    local cAlsTmp   as character
    local cQuery    as character
    local oExecQry  as object
    local nParam    as numeric

    aRetorno := {}
    aGrid := {}
    cAlsTmp := ""
    cQuery := ""
    nParam := 1

    If !Empty(Alltrim(F7T->F7T_IDNF))
        cQuery := "SELECT F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT, R_E_C_N_O_ RECNO "
        cQuery += "FROM " + RetSqlName("SF2") + " "
        cQuery += "WHERE "
        cQuery += "F2_FILIAL = ? "
        cQuery += "AND F2_IDNF = ? "
        cQuery += "AND D_E_L_E_T_ = ? "

        oExecQry := FwExecStatement():new(ChangeQuery(cQuery))
        oExecQry:setString(nParam++, FwXFilial("SF2"))
        oExecQry:setString(nParam++, F7T->F7T_IDNF)
        oExecQry:setString(nParam++, " ")

        cAlsTmp := oExecQry:openAlias()

        If !(cAlsTmp)->(EoF())
            aAdd( aGrid , (cAlsTmp)->F2_DOC)
            aAdd( aGrid , (cAlsTmp)->F2_SERIE)
            aAdd( aGrid , (cAlsTmp)->F2_CLIENTE)
            aAdd( aGrid , (cAlsTmp)->F2_LOJA)
            aAdd( aGrid , Stod((cAlsTmp)->F2_EMISSAO))
            aAdd( aGrid , (cAlsTmp)->F2_VALBRUT)
            aAdd( aGrid , (cAlsTmp)->F2_CLIENTE)

            aAdd(aRetorno, {(cAlsTmp)->RECNO, aGrid})
        Endif

        (cAlsTmp)->(DbCloseArea())
    Endif

Return aRetorno

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
