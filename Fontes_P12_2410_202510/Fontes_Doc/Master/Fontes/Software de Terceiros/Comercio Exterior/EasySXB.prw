#include "protheus.ch"
#include "easySXB.ch"

function EasySXB()
return

/*/{Protheus.doc} EasySXB
    Classe para criação de consulta padrão específica

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
/*/
class EasySXB

    data cClassName
    data oDlgSXB
    data oBrowseSXB
    data cTitle
    data nWidth
    data nHeight

    method New()
    method CreateDlg()
    method ViewSXB()

end class

/*/{Protheus.doc} New
    Método construtor da classe EasySXB

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return self, objeto da classe, EasySXB
/*/
method New() class EasySXB
    local aCoors := FWGetDialogSize()

    EasySXB()

    self:cClassName := "EasySXB"

    FwFreeObj(self:oDlgSXB)
    FwFreeObj(self:oBrowseSXB)

    self:cTitle := STR0001 // "Consulta padrão"
    self:nWidth := aCoors[4] * 0.30 // 480
    self:nHeight := aCoors[3] * 0.30 // 250

return self

/*/{Protheus.doc} New
    Método construtor da classe EasySXB

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param  cTitle, caractere, titulo da dialog
            nWidth, numerico, largura da dialog
            nHeight, numerico, altura da dialog
            lAllClient, logico, .T. para toda a tela / .F. será utilizado o que for definido no nWidth e nHeight
    @return nenhum
/*/
method CreateDlg(cTitle, nWidth, nHeight, lAllClient) class EasySXB

    default cTitle     := self:cTitle
    default nWidth     := self:nWidth
    default nHeight    := self:nHeight
    default lAllClient := .F.

    fwFreeObj(self:oDlgSXB)
    self:oDlgSXB := FWDialogModal():New()
    self:oDlgSXB:setEscClose(.F.)
    self:oDlgSXB:setTitle( OemTOAnsi(cTitle) )
    if( lAllClient, self:oDlgSXB:enableAllClient(), self:oDlgSXB:setSize( nHeight, nWidth ) )
    self:oDlgSXB:enableFormBar(.F.)
    self:oDlgSXB:SetCloseButton( .F. )
    self:oDlgSXB:createDialog()

return

/*/{Protheus.doc} New
    Método construtor da classe EasySXB

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param  cTitle, caractere, titulo da dialog
            cAliasTmp, caractere, alias do arquivo temporario
            nWidth, numerico, largura da dialog
            nHeight, numerico, altura da dialog
            lAllClient, logico, .T. para toda a tela / .F. será utilizado o que for definido no nWidth e nHeight
            aColumns, array, vetor com as colunas do FWBrowse
            aNotFields, array, vetor para informar os campos que NÃO devem apresentar no FWBrowse
    @return lRet, logico, .T. confirmou a operação / .F. cancelou
/*/
method ViewSXB(cTitle, cAliasTmp, nWidth, nHeight, lAllClient, aColumns, aNotFields) class EasySXB
    local lRet       := .F.
    local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
    local nCpo       := 0
    local aStruct    := {}
    local aColumns   := {}
    local nOpc       := 0

    default cTitle     := self:cTitle
    default nWidth     := self:nWidth
    default nHeight    := self:nHeight
    default lAllClient := .F.
    default cAliasTmp  := ""
    default aColumns   := {}
    default aNotFields := {}

    if !empty(cAliasTmp)

        aRotina := {}
        if len(aColumns) == 0
            aStruct := (cAliasTmp)->(dbStruct())
            for nCpo := 1 To Len(aStruct)
                if len(aNotFields) == 0 .or. aScan( aNotFields , { |X| X == aStruct[nCpo][1] } ) == 0
                    aAdd(aColumns,FWBrwColumn():New())
                    aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
                    aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
                    aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
                    aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
                    aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
                endif
            next nCpo 
        endif

        if self:oDlgSXB == nil
            self:CreateDlg(cTitle, nWidth, nHeight, lAllClient)
        endif

        fwFreeObj(self:oBrowseSXB)
        self:oBrowseSXB := FWMBrowse():New()
        self:oBrowseSXB:SetOwner( self:oDlgSXB:getPanelMain() )
        self:oBrowseSXB:SetAlias( cAliasTmp )
        self:oBrowseSXB:AddButton( OemTOAnsi(STR0002) , { || nOpc := 1 , self:oDlgSXB:DeActivate() },, 2 ) // "Confirmar"
        self:oBrowseSXB:AddButton( OemTOAnsi(STR0003)  , { || self:oDlgSXB:DeActivate() },, 2 ) // "Cancelar"
        self:oBrowseSXB:SetColumns( aColumns )
        self:oBrowseSXB:SetMenuDef("")
        self:oBrowseSXB:SetTemporary(.T.)
        self:oBrowseSXB:DisableDetails()
        self:oBrowseSXB:DisableFilter()
        self:oBrowseSXB:DisableConfig()
        self:oBrowseSXB:DisableReport()
        self:oBrowseSXB:SetDoubleClick({ || nOpc := 1 , self:oDlgSXB:DeActivate() })
        self:oBrowseSXB:Activate()

        self:oDlgSXB:Activate()

        if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

    endif

    lRet := nOpc == 1

return lRet
