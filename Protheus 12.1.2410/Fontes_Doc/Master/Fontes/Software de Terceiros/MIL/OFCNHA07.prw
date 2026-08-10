#include "TOTVS.CH"
#include "FWMVCDEF.CH"
#include "OFCNHA07.ch"

/*/{Protheus.doc} OFCNHA07
Rotina de visualização do LOG
@type function
@author Cristiam Rossi
@since 10/02/2025
/*/
Function OFCNHA07()
local   aArea      := getArea()
local   oLayer     := FWLayer():new()
local   oModal     := FWDialogModal():New()
local   aButtons   := {}
local   oBrowse    := FWMBrowse():New()
local   oTempTable := FWTemporaryTable():New()
local   aCampos    := { 'VQL_FILIAL', 'VQL_TIPO', 'VQL_DATAI', 'VQL_HORAI' }
local   aAux
local   nI
local   aStruct    := {}
local   aColumns   := {}
Private oConfig    := OFCNHPrimConfig():New()
Private oCfgAtu    := oConfig:GetConfig()
Private oGetSetFiles := OFCNHA08():new()

    aAdd( aStruct, { "REGISTRO", "N", 9, 0 } )
    aAdd( aStruct, { "CHAVE"   , "N", 9, 0 } )
    for nI := 1 to len( aCampos )
        aAux := FWSX3Util():GetFieldStruct( aCampos[nI] )
        if aCampos[nI] == "VQL_HORAI"
            aAux[5] := "@R 99:99"
        endif
        aAdd( aStruct, aClone( aAux ) )
    next

    oTempTable:setFields( aStruct )
    oTempTable:AddIndex( "INDEX", {"CHAVE"} )
    oTempTable:Create()

    for nI := 03 to len( aStruct )
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nI][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nI][1]))
        aColumns[Len(aColumns)]:SetSize(aStruct[nI][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nI][4])
        aColumns[Len(aColumns)]:SetPicture(aStruct[nI][5])
    next

    aAdd( aButtons, { nil, STR0001, {|| Processa({|lEnd| OA070004C_refresh( oTempTable, oBrowse ) })  }, STR0002, nil, .T., .T. } )    //#Refresh      #"Busca novos registros do log"

    Processa({|lEnd| OA070004C_refresh( oTempTable, oBrowse, .T. ) })

    oModal:SetEscClose(.T.)
    oModal:enableAllClient()
    oModal:setBackground(.t.)
    oModal:createDialog()
    oModal:addCloseButton(nil, STR0003)        //#Fechar
    oModal:addButtons( aButtons )

    oLayer:init(oModal:getPanelMain(),.T.)

    oLayer:addCollumn('Col01',60,.F.)
    oLayer:addCollumn('Col02',40,.F.)

    oLayer:addWindow('Col01','REGS' ,STR0004,100,.F.,.F.)       //#Registros
    oLayer:addWindow('Col02','DADOS',STR0005  ,100,.F.,.F.)       //#Detalhe

    oBrowse:SetAlias( oTempTable:getAlias() )
    oBrowse:SetTemporary( .T. )
    oBrowse:OptionReport(.F.)
    oBrowse:SetColumns(aColumns)
    oBrowse:SetDescription( STR0006 )    // #"Log PRIM"
    oBrowse:setMenuDef("OFCNHA07")
    oBrowse:DisableDetails()
    oBrowse:bChange := {|| OA070001C_showMemo( oLayer:getWinPanel('Col02','DADOS') ) }
    oBrowse:Activate( oLayer:getWinPanel('Col01','REGS') )

    oModal:Activate()
    oTempTable:Delete()
    restArea( aArea )
return nil


/*/{Protheus.doc} Menudef
Menudef
@type function
@author Cristiam Rossi
@since 10/02/2025
/*/
static function menuDef()
local aRotina := {}
    ADD OPTION aRotina Title STR0007 Action 'oGetSetFiles:getFiles()'  OPERATION 3 ACCESS 0      //#"Download Files"
    ADD OPTION aRotina Title STR0008 Action 'oGetSetFiles:sendFiles()' OPERATION 3 ACCESS 0     //#"Upload Files"
return aRotina


/*/{Protheus.doc} OA070001C_showMemo
exibe conteúdo do log no componente Get a direita
@type function
@author Cristiam Rossi
@since 27/02/2025
/*/
function OA070001C_showMemo(oPanel)
local cAlias := alias()
local oGet
local cTGet1

    VQL->( dbGoto( (cAlias)->REGISTRO ) )

    cTGet1 := iif( empty(VQL->VQL_MSGLOG), VQL->VQL_DADOS, VQL->VQL_MSGLOG )

    oGet := tMultiget():new( 01, 01, {|u| iif(pCount()>0, cTGet1 := u, cTGet1)}, oPanel, 260, 92, , , , , , .T., , , , , , .T. )
    oGet:align := CONTROL_ALIGN_ALLCLIENT
return nil


/*/{Protheus.doc} OA070004C_refresh
Atualiza a tela com os últimos logs
@type function
@author Cristiam Rossi
@since 27/02/2025
/*/
function OA070004C_refresh( oTempTable, oBrowse, lFirst )
local   cAlias     := oTempTable:getAlias()
local   nLastRecno := 0
default lFirst     := .F.

    (cAlias)->( dbGotop() )
    nLastRecno := (cAlias)->REGISTRO

    cQuery := "insert into " + oTempTable:getRealName() + " (VQL_FILIAL,VQL_TIPO,VQL_DATAI,VQL_HORAI,REGISTRO,CHAVE) "
    cQuery += "select VQL_FILIAL,VQL_TIPO,VQL_DATAI,VQL_HORAI,R_E_C_N_O_, 999999999-R_E_C_N_O_"
    cQuery += " from "+retSqlName("VQL")+" VQL "
    cQuery += " where VQL_FILIAL = '"+xFilial("VQL")+"'"
    cQuery += " and   VQL_AGROUP = 'PRIM'"
    cQuery += " and   R_E_C_N_O_ > " + cValToChar( nLastRecno )
    cQuery += " and   VQL.D_E_L_E_T_=' '"

    tcSqlExec( cQuery )

    dbSelectArea( cAlias )
    dbGotop()
    if ! lFirst
        oBrowse:refresh(.T.)
    endif
return nil
