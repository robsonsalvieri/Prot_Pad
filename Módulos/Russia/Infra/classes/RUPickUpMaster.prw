#INCLUDE "PROTHEUS.CH"

// Dirty hack caused by AdvPL specificity
static ThisPickUpMaster As Object

/*/
{Protheus.doc} RUPickUpMaster
    A universal pickup tool for taking links to data in the system

    @type Class
    @author dtereshenko
    @since 10/04/2019
    @version 12.1.23
/*/
Class RUPickUpMaster From LongNameClass
    Data cAlias As Char
    Data cIndexOrdem As Char
    Data cIndexFields As Char
    Data cIndex As Char
    Data oParent As Object
    Data oMarkBrowse As Object
    Data oBrowse As Object

    Method New(cAlias, lStartNow, cIndexOrdem) Constructor

    Method Activate(oParent)
    Method OnRecordSelect()

EndClass

/*/
{Protheus.doc} New(cAlias As Char, lStartNow As Logical, cIndexOrdem As Char)
    Default RUPickUpMaster constructor

    @type Method
    @params cAlias,       Char,       Alias of the table from which records will be selected
            lStartNow,    Logical,    Flag indicating whether to start the browser immediately
            cIndexOrdem,  Char,       Index order from SIX
    @author dtereshenko
    @since 10/07/2019
    @version 12.1.23
    @return RUPickUpMaster,    Object,    RUPickUpMaster instance
/*/
Method New(cAlias, lStartNow, cIndexOrdem) Class RUPickUpMaster
    Local oDefSize As Object
    Local aSize As Array

    Default cIndexOrdem := "1"
    Default lStartNow := .F.

    ::cAlias := cAlias
    ::cIndexOrdem := cIndexOrdem

    oDefSize := FwDefSize():New()
    oDefSize:Process()
    aSize := oDefSize:aWindSize

    If aSize[1] == 0 .And. aSize[2] == 0 .And. aSize[3] == 0 .And. aSize[4] == 0
        aSize[1] := 0
        aSize[2] := 0
        aSize[3] := 600
        aSize[4] := 800
    EndIf

    ::oBrowse := FWMBrowse():New()
	ThisPickUpMaster := Self
    ::oBrowse:SetAlias(cAlias)
    ::oParent := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], cAlias, , , , , , , , ,.T. , ,  )

    ::oBrowse:SetOwner(::oParent)
    
    blDblClick := {|| ThisPickUpMaster::OnRecordSelect()}
    ::oBrowse:SetMenuDef( '' ) 
    ::oBrowse:SetDoubleClick(blDblClick)
    
    ::oBrowse:SetDBFFilter( .T. )
    If lStartNow == .T.
        ::oBrowse:Activate()
        ::oParent:Activate(,,,.T.,,,)
    EndIf
    
Return Self

/*/
{Protheus.doc} Activate(oParent As Object)
    Run MarkBrowse in transfered GUI element or default window

    @type Method
    @params oParent,    Object,    GUI element to display the browse
    @author dtereshenko
    @since 10/07/2019
    @version 12.1.23
    @return
/*/
Method Activate(oParent) Class RUPickUpMaster
    Default oParent := ::oParent

    ::oMarkBrowse:SetOwner(oParent)
    ::oMarkBrowse:Activate()
Return

/*/
{Protheus.doc} OnRecordSelect()
    Set up primary key (or another index) of selected entry

    @type Method
    @params
    @author dtereshenko
    @since 10/07/2019
    @version 12.1.23
    @return
/*/
Method OnRecordSelect() Class RUPickUpMaster
    Local cIndexOrdem as Char
    cIndexOrdem := ::cIndexOrdem

    dbSelectArea(::cAlias)
    ::cIndexFields := INDEXKEY(Val(cIndexOrdem))
	dbCloseArea()

    ::cIndex := &((::cAlias)->(::cIndexFields))
    VAR_IXB := ::cIndex
    ::oParent:End()
Return

/*/
{Protheus.doc} OnRecordSelect()
    Set up primary key (or another index) of selected entry

    @type Function
    @params
    @author iprokhorenko
    @since 27/02/2020
    @version 12.1.23
    @return
/*/
Function RUXXPickUp(cAlias, lStartNow, cIndexOrdem)
    RUPickUpMaster():New(cAlias,lStartNow,cIndexOrdem)
Return .T.
