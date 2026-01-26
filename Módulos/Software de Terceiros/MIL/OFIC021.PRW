#include "totvs.ch"
#include "fwMVCdef.ch"
#include "ofic021.ch"

/*/{Protheus.doc} OFIC021
Tela para visualizar os Logs
@type function
@version 1.0
@author cristiamRossi
@since  05/07/2024
/*/
function OFIC021
local   aColumns := {}
local   aFields  := {}
local   nI
private oBrowse  := FWMBrowse():New()

    oBrowse:SetMenuDef("OFIC021")
    oBrowse:SetAlias("VQL")
    oBrowse:AddFilter( STR0001,"'-SM' $ VQL_AGROUP"   ,.T.,.T.)             // "Filtro"
    oBrowse:AddLegend( "!Empty(VQL_DATAF)" , "BR_VERDE"    , STR0002 )      // "Pendência resolvida"
    oBrowse:AddLegend( " Empty(VQL_DATAF)" , "BR_VERMELHO" , STR0003 )      // "Pendência ativa"
    oBrowse:SetOnlyFields( { "VQL_CODVQL", "VQL_TIPO", "VQL_DADOS" } )

    aAdd( aFields, {"VQL_CODVQL","CHAINT" } )
    aAdd( aFields, {"VQL_DATAI" ,STR0004  } )        // "Registro"
    for nI := 1 to Len( aFields )
        aAdd( aColumns, FWBrwColumn():New() )
        aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nI,1] + " }") )
        aColumns[Len(aColumns)]:SetTitle( aFields[nI,2] )
        aColumns[Len(aColumns)]:SetSize( tamSX3( aFields[nI,1] )[1] )
        aColumns[Len(aColumns)]:SetID( aFields[nI,1] )
    next nI

    oBrowse:SetColumns(aColumns)

    oBrowse:SetDescription( STR0005 )      // "Pendências"
    oBrowse:DisableDetails()
    oBrowse:Activate()
return nil


/*/{Protheus.doc} MenuDef
MenuDef - itens de menu - opções no browse 
@type function
@version 1.0
@author cristiamRossi
@since 7/8/2024
@return array, lista de botões de ação
/*/
static Function MenuDef()
local aAuxRot := {}
    aAdd( aAuxRot, { STR0006, 'VIEWDEF.OFIC021'  , 0, 2, 0, NIL } )  // 'Visualizar'
    aAdd( aAuxRot, { STR0007, 'OC020001C_Filtros', 0, 6, 0, NIL } )  // 'Filtros'
return aAuxRot


/*/{Protheus.doc} ModelDef
ModelDef - modelo MVC
@type function
@version 1.0
@author cristiamRossi
@since 7/8/2024
@return object, objeto Model
/*/
static function ModelDef()
local oModel
local oStruVQL := FWFormStruct(1,"VQL")

    oModel := MPFormModel():New("OFIC021") 
    oModel:addFields('MODEL_VQL',,oStruVQL)
return oModel


/*/{Protheus.doc} ViewDef
ViewDef - view MVC
@type function
@version 1.0
@author cristiamRossi
@since 7/8/2024
@return object, objeto View
/*/
static function ViewDef()
local oModel   := ModelDef()
local oView    := FWFormView():New()
local oStruVQL := FWFormStruct(2, 'VQL')
 
    oStruVQL:RemoveField("VQL_CODIGO")
    oStruVQL:RemoveField("VQL_AGROUP")
    oStruVQL:RemoveField("VQL_HORAI")
    oStruVQL:RemoveField("VQL_HORAF")
    oStruVQL:RemoveField("VQL_FILORI")
    oStruVQL:RemoveField("VQL_MSGLOG")

	oStruVQL:SetProperty( 'VQL_CODVQL'	, MVC_VIEW_TITULO    , "CHAINT" )	
	oStruVQL:SetProperty( 'VQL_DATAI'	, MVC_VIEW_TITULO    , STR0004 )    // "Registro"
	oStruVQL:SetProperty( 'VQL_DATAF'	, MVC_VIEW_TITULO    , STR0008 )	// "Resolução"

	oStruVQL:SetProperty( 'VQL_CODVQL'	, MVC_VIEW_ORDEM,	'01')
	oStruVQL:SetProperty( 'VQL_TIPO'	, MVC_VIEW_ORDEM,	'02')
	oStruVQL:SetProperty( 'VQL_DADOS'	, MVC_VIEW_ORDEM,	'03')
	oStruVQL:SetProperty( 'VQL_DATAI'	, MVC_VIEW_ORDEM,	'04')
	oStruVQL:SetProperty( 'VQL_DATAF'	, MVC_VIEW_ORDEM,	'05')

    oView:SetModel(oModel)
    oView:AddField('VIEW_VQL' , oStruVQL,'MODEL_VQL' ) 
    oView:CreateHorizontalBox( 'TELA', 100)
    oView:SetOwnerView('VIEW_VQL','TELA') 
return oView


/*/{Protheus.doc} OC020001C_Filtros
janela de Filtro de registros do browse
@type function
@version 1.0
@author cristiamRossi
@since 7/10/2024
/*/
function OC020001C_Filtros()
local   aArea      := getArea()
local   cAlias     := getNextAlias()
local   oDlg
local   aTipos     := {}
local   oLbTipos
local   lOK        := .F.
local   oOk        := LoadBitmap( GetResources(), "LBTIK" )
local   oNo        := LoadBitmap( GetResources(), "LBNO" )
local   nI
local   oPendIni
local   oPendFim
local   oResIni
local   oResFim
local   oSalvar
local   oCancel
local   oRadSts
local   oChave
local   cAux        := ""
local   dPendIni    := CtoD("  /  /  ")
local   dPendFim    := dDatabase
local   dResIni     := CtoD("  /  /  ")
local   dResFim     := dDatabase
local   cCondition  := ""
local   nRadSts     := 1
local   aItens      := { STR0009, STR0010, STR0011 }      // "Todas", "Ativas", "Resolvidas"
local   cChave      := space(100)
private cChaInt     := ""

    cQuery := "select distinct VQL.VQL_TIPO, PEND, RESOLV"
    cQuery += " from " + retSqlName("VQL") + " VQL "

    cQuery += " left join ("
    cQuery +=       "select VQL_TIPO, count(*) PEND"
    cQuery +=       " from " + retSqlName("VQL")
    cQuery +=       " where VQL_FILIAL = '" + xFilial("VQL") + "'"
    cQuery +=       " and VQL_DATAF = ' '"
    cQuery +=       " and VQL_AGROUP like '%-SM%'"
    cQuery +=       " and D_E_L_E_T_ = ' '"
    cQuery +=       " group by VQL_TIPO"
    cQuery +=       " ) VQLP"
    cQuery += " on VQLP.VQL_TIPO = VQL.VQL_TIPO"

    cQuery += " left join ("
    cQuery +=       "select VQL_TIPO, count(*) RESOLV"
    cQuery +=       " from " + retSqlName("VQL")
    cQuery +=       " where VQL_FILIAL = '" + xFilial("VQL") + "'"
    cQuery +=       " and VQL_DATAF <> ' '"
    cQuery +=       " and VQL_AGROUP like '%-SM%'"
    cQuery +=       " and D_E_L_E_T_ = ' '"
    cQuery +=       " group by VQL_TIPO"
    cQuery +=       " ) VQLR"
    cQuery += " on VQLR.VQL_TIPO = VQL.VQL_TIPO"

    cQuery += " where VQL.VQL_FILIAL = '" + xFilial("VQL") + "'"
    cQuery += " and VQL.VQL_AGROUP like '%-SM%'"
    cQuery += " and VQL.D_E_L_E_T_ = ' '"
    cQuery += " order by VQL_TIPO"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )
    while ! (cAlias)->( eof() )
        aAdd( aTipos, { ;
                .T.,;
                (cAlias)->VQL_TIPO,;
                (cAlias)->PEND,;
                (cAlias)->RESOLV;
        } )
        (cAlias)->( dbSkip() )
    endDo
    (cAlias)->( dbCloseArea() )
    restArea( aArea )

    define MSDialog oDlg title STR0007 From 9,0 to 26,64	of oMainWnd     // "Filtros"
    @ 002,003 to 025,125 label STR0012 of oDlg pixel                        // "Pendência"
    @ 011,006 say STR0013 of oDlg pixel                                     // "De:"
    @ 009,018 msGet oPendIni var dPendIni of oDlg pixel
    @ 011,064 say STR0014 of oDlg pixel                                     // "até:"
    @ 009,076 msGet oPendFim var dPendFim of oDlg pixel

    @ 002,126 to 025,252 label STR0008 of oDlg pixel                        // "Resolução"
    @ 011,129 say STR0013 of oDlg pixel                                     // "De:"
    @ 009,141 msGet oResIni var dResIni of oDlg pixel
    @ 011,187 say STR0014 of oDlg pixel                                     // "até:"
    @ 009,199 msGet oResFim var dResFim of oDlg pixel

	@ 027,003 listBox oLbTipos fields header  "", STR0015, STR0010, STR0011 colSizes 10,50,40,10 size 150,100 of oDlg on dblClick (aTipos[oLbTipos:nAt,1] := !aTipos[oLbTipos:nAt,1] ) pixel   // "Tipo", "Ativas", "Resolvidas"
    oLbTipos:bHeaderClick := { |oObj,nCol| iif( nCol == 1 , ( lMarca := ! aTipos[1,1] , aEval( aTipos, { |x| x[1] := lMarca } ) ), nil), oLbTipos:refresh() }
	oLbTipos:setArray(aTipos)
	oLbTipos:bLine := { || { iif(aTipos[oLbTipos:nAt,1],oOk,oNo) ,;
	                            aTipos[oLbTipos:nAt,2],;
	                            aTipos[oLbTipos:nAt,3],;
	                            aTipos[oLbTipos:nAt,4] }}

    @ 027,155 to 067,252 label STR0005 of oDlg pixel   // "Pendências"
    oRadSts := tRadMenu():new( 035,160,aItens,,oDlg,,,,,,,,100,12,,,,.T.)
    oRadSts:bSetGet := {|u| iif(pCount()==0,nRadSts,nRadSts:=u)}

    @ 069,155 to 095,252 label STR0016 of oDlg pixel      // "Chaint / Chassi"
    @ 078,158 msGet oChave var cChave size 90,08 of oDlg pixel F3 "VV1" valid OC020002C_Valid_Chaint( cChave )
    oChave:setFocus()

    @ 100,160 BUTTON oSalvar PROMPT STR0017 OF oDlg SIZE 40,15 PIXEL ACTION ( lOk := .T., oDlg:end() )       // "OK"
    @ 100,210 BUTTON oCancel PROMPT STR0018 OF oDlg SIZE 40,15 PIXEL ACTION ( lOk := .F., oDlg:end() )       // "Cancelar"

	activate MSDialog oDlg                            

    if lOk
        if nRadSts != 3
            cCondition += iif( empty( dPendIni ), "", "VQL_DATAI >= '" + DtoS( dPendIni ) + "' .and. ")
            cCondition += iif( empty( dPendFim ), "", "VQL_DATAI <= '" + DtoS( dPendFim ) + "' .and. ")
        endif

        if nRadSts != 2
            cCondition += iif( empty( dResIni ), "", "VQL_DATAF >= '" + DtoS( dResIni ) + "' .and. ")
            cCondition += iif( empty( dResFim ), "", "VQL_DATAF <= '" + DtoS( dResFim ) + "' .and. ")
        endif

        if nRadSts == 2
            cCondition += "empty( VQL_DATAF ) .and. "
        endif
        if nRadSts == 3
            cCondition += "! empty( VQL_DATAF ) .and. "
        endif

        for nI := 1 to len( aTipos )
            if aTipos[nI,1]
                cAux += aTipos[nI,2] + ";"
            endif
        next

        if ! empty( cAux )
            cCondition += "VQL_TIPO $ '" + cAux + "' .and. "
        endif
    endif

    if ! empty( cChaInt )
        cCondition += "VQL_CODVQL == '" + cChaInt + "' .and. "
    endif

    cCondition += ".T."
    oBrowse:setFilterDefault( cCondition )
return nil


/*/{Protheus.doc} OC020002C_Valid_Chaint
Validação da chave informada Chaint ou Chassi
@type function
@version 1.0
@author cristiamRossi
@since 7/23/2024
@param cChave, character, Chaint ou Chassi
@return logical, encontrado S/N
/*/
static function OC020002C_Valid_Chaint( cChave )
local aArea    := getArea()
local aAreaVV1 := VV1->( getArea() )
local lRet     := .T.
local cAux     := alltrim( cChave )

    cChaInt := ""

    if ! empty( cAux )
        if len( cAux ) == len( VV1->VV1_CHAINT )
            VV1->( dbSetOrder(1) )
        else
            VV1->( dbSetOrder(2) )
        endif
        if ( lRet := VV1->( dbSeek( xFilial("VV1") + cAux ) ) )
            cChaInt := VV1->VV1_CHAINT
        endif
    endif

    VV1->( restArea( aAreaVV1 ) )
    restArea( aArea )
return lRet
