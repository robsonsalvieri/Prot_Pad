#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RSKA120.CH'

PUBLISH MODEL REST NAME RSKA120

//-------------------------------------------------------------------
/*/
    {Protheus.doc} RSKA120
    Rotina MVC para Controle de Impressão dos Boletos em Lote

    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Function RSKA120()

    Local oBrowse As Object

	Private aRotina As Array

    oBrowse := Nil 
    aRotina := MenuDef()

    AR8->( DbSetOrder(2) )
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias( 'AR8' )
    oBrowse:SetDescription( STR0001 ) // "Impressão de Boletos em Lote"
    oBrowse:SetMenuDef( "RSKA120" )
    oBrowse:AddLegend( "AR8_STATUS=='0'", "BR_BRANCO"     , STR0002 ) //"Aguardando Envio"
    oBrowse:AddLegend( "AR8_STATUS=='1'", "BR_AMARELO"    , STR0003 ) //"Aguardando Retorno"
    oBrowse:AddLegend( "AR8_STATUS=='2'", "BR_VERDE"      , STR0004 ) //"Sucesso"
    oBrowse:AddLegend( "AR8_STATUS=='3'", "BR_VERMELHO"   , STR0005 ) //"Boletos com Erros"
    oBrowse:Activate()

	FWFreeArray( aRotina )
    FwFreeObj( oBrowse )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina.

@return vetor, retorna as opções do Menu que será apresentado em tela
@author Daniel Moda
@since 04/04/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION 'Rsk120GerL'      OPERATION MODEL_OPERATION_INSERT ACCESS 3 DISABLE MENU //"Gerar Lote"
	ADD OPTION aRotina TITLE STR0007 ACTION 'Rsk120BPDF'      OPERATION MODEL_OPERATION_UPDATE ACCESS 4 DISABLE MENU //"Boletos"
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.RSKA120' OPERATION MODEL_OPERATION_VIEW   ACCESS 2 DISABLE MENU //"Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/
    {Protheus.doc} ModelDef
    Modelo de dados

    @return objeto, retornar o modelo de dados utilizado no MVC
    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oStruAR8 As Object
	Local oStruAR9 As Object
	Local oModel   As Object

	oStruAR8 := FWFormStruct( 1, 'AR8' )
	oStruAR9 := FWFormStruct( 1, 'AR9' )
	oModel   := Nil

	oModel := MPFormModel():New( 'RSKA120', /*bPreValid*/, /*bPost*/ )
	oModel:AddFields( 'AR8MASTER', /*cOwner*/, oStruAR8 )
	oModel:SetDescription( STR0010 ) //'TOTVS Mais Negócios - Boletos em Lote'
	oModel:SetPrimaryKey( {'AR8_FILIAL', 'AR8_LOTE'} )

	oModel:AddGrid( 'AR9DETAIL', 'AR8MASTER', oStruAR9 )
	oModel:SetRelation( 'AR9DETAIL', { { 'AR9_FILIAL', 'xFilial( "AR9" )' }, { 'AR9_LOTE', 'AR8_LOTE' } }, AR9->( IndexKey( 1 ) ) )
	oModel:GetModel( 'AR9DETAIL' ):SetUniqueLine( { 'AR9_ITEM' } )
	oModel:GetModel( 'AR9DETAIL' ):SetDescription( STR0011 ) //'Detalhes dos Boletos'
	oModel:GetModel( 'AR9DETAIL' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/
    {Protheus.doc} ViewDef
    Modelo de interface

    @return objeto, retorna a View utilizada no MVC.
    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel   As Object
	Local oStruAR8 As Object
	Local oStruAR9 As Object
	Local oView    As Object

	oModel   := FWLoadModel( 'RSKA120' )
	oStruAR8 := FWFormStruct( 2, 'AR8' )
	oStruAR9 := FWFormStruct( 2, 'AR9' )
	oView    := Nil

	oStruAR8:RemoveField( "AR8_IDLOTE" )
	oStruAR8:RemoveField( "AR8_URLPDF" )
	oStruAR8:RemoveField( "AR8_URLPDF" )
	oStruAR8:RemoveField( "AR8_COD" )
	oStruAR9:RemoveField( "AR9_LOTE" )
	oStruAR9:RemoveField( "AR9_IDBOL" )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_AR8', oStruAR8, 'AR8MASTER' )
	oView:AddGrid(  'VIEW_AR9', oStruAR9, 'AR9DETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	oView:SetOwnerView( 'VIEW_AR8', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_AR9', 'INFERIOR' )
	oView:AddIncrementField( 'VIEW_AR9', 'AR9_ITEM' )
	oView:SetViewProperty( 'VIEW_AR9', "ENABLENEWGRID" )
	oView:SetViewProperty( 'VIEW_AR9', "GRIDSEEK", { .T. } )
	oView:SetViewProperty( 'VIEW_AR9', "GRIDFILTER", { .T. } )
    oView:SetProgressBar(.T.)
	oView:ShowUpdateMsg( .T. )

Return oView

//-------------------------------------------------------------------
/*/
    {Protheus.doc} Rsk120GerL
    Função para filtrar as notas que serão enviadas para a geração
    do lote de boleto para impressão.

    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Function Rsk120GerL()

    If Pergunte( "RSKA120001", .T. )
        FWMsgRun(, {|| Rsk120Qry() }, STR0013, STR0014) //"Filtro Notas Fiscais Mais Negócios" # "Gerando Boletos em Lote..."
    EndIf

Return

//-------------------------------------------------------------------
/*/
    {Protheus.doc} Rsk120Qry
    Função para filtrar as notas que serão enviadas para a geração
    do lote de boleto para impressão.

    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Static Function Rsk120Qry()

	Local aErrorMd  As Array
    Local cQuery    As Character
    Local cQueryFim As Character
    Local cTmpCons  As Character
    Local oQueryAR1 As Object
    Local oModel    As Object
    Local oMdlAR8   As Object
    Local oMdlAR9   As Object
    Local cItem     As Character
    Local nTotalNf  As Numeric
    Local cCodUser  As Character

	aErrorMd  := {}
    cQuery    := ""
    cQueryFim := ""
    cTmpCons  := ""
    oQueryAR1 := Nil
    oModel    := Nil
    oMdlAR8   := Nil
    oMdlAR9   := Nil
    cItem     := ""
    nTotalNf  := 0
    cCodUser  := UsrRetName( RetCodUsr() )

    cQuery := "SELECT AR1_FILNF, AR1_SERIE, AR1_DOC, AR1_CLIENT, AR1_LOJA, AR1_NFEMIS " +;
                "FROM ? " +;
                "WHERE AR1_FILNF BETWEEN ? AND ? " +;
                "AND AR1_SERIE BETWEEN ? AND ? " +;
                "AND AR1_DOC BETWEEN ? AND ? " +;
                "AND AR1_NFEMIS BETWEEN ? AND ? " +;
                "AND AR1_CLIENT BETWEEN ? AND ? " +;
                "AND AR1_LOJA BETWEEN ? AND ? " +;
                "AND D_E_L_E_T_ = ' ' " +;
                "ORDER BY AR1_FILNF, AR1_SERIE, AR1_DOC "
    oQueryAR1 := FWPreparedStatement():New()
    oQueryAR1:SetQuery(cQuery)
    oQueryAR1:SetUnsafe(1, RetSqlName( "AR1" ))
    oQueryAR1:SetString(2, MV_PAR01) // Filial de ?
    oQueryAR1:SetString(3, MV_PAR02) // Filial Ate ?
    oQueryAR1:SetString(4, MV_PAR03) // Serie de ?
    oQueryAR1:SetString(5, MV_PAR04) // Serie ate ?
    oQueryAR1:SetString(6, MV_PAR05) // Nota de ?
    oQueryAR1:SetString(7, MV_PAR06) // Nota ate ?
    oQueryAR1:SetString(8, DToS( MV_PAR07 )) // Emissao de ?
    oQueryAR1:SetString(9, DToS( MV_PAR08 )) // Emissao ate ?
    oQueryAR1:SetString(10, MV_PAR09) // Cliente de ?
    oQueryAR1:SetString(11, MV_PAR10) // Cliente ate ?
    oQueryAR1:SetString(12, MV_PAR11) // Loja de ?
    oQueryAR1:SetString(13, MV_PAR12) // Loja ate ?
    cQueryFim := oQueryAR1:GetFixQuery()
    cTmpCons  := MpSysOpenQuery( cQueryFim )

    ( cTmpCons )->( DbGoTop() )
    If ( cTmpCons )->( !EOF() )
        // Gravar o cabeçalho do Lote de Boletos ( tabela AR8 )
        While ( cTmpCons )->( !EOF() )
            nTotalNf := 0
            oModel  := FWLoadModel( "RSKA120" )
            oModel:SetOperation( MODEL_OPERATION_INSERT )
            oMdlAR8 := oModel:GetModel( "AR8MASTER" )

            If oModel:Activate()
                oMdlAR8:SetValue( "AR8_FILIAL", xFilial( "AR8" ) )
                oMdlAR8:SetValue( "AR8_DATA"  , dDataBase )
                oMdlAR8:SetValue( "AR8_STATUS", "0" ) // 0= Aguardando Envio
                oMdlAR8:SetValue( "AR8_HORA", Time() )
                oMdlAR8:SetValue( "AR8_NOMUSR",  cCodUser )
                oMdlAR8:SetValue( "AR8_COD", cValToChar( 99999999999999 - Val( FWTimeStamp() ) ) ) 
                // Gravar os detalhes do Lote de Boletos ( tabela AR9 )
                oMdlAR9 := oModel:Getmodel( "AR9DETAIL" )
                cItem   := StrZero( 0, TAMSX3( "AR9_ITEM" )[1] )
                While ( cTmpCons )->( !EOF() ) .And. nTotalNf < 50
                    cItem := Soma1( cItem )
                    oMdlAR9:SetValue( "AR9_FILIAL" , AR8->AR8_FILIAL )
                    oMdlAR9:SetValue( "AR9_LOTE"   , AR8->AR8_LOTE )
                    oMdlAR9:SetValue( "AR9_ITEM"   , cItem )
                    oMdlAR9:SetValue( "AR9_FILNF"  , ( cTmpCons )->AR1_FILNF )
                    oMdlAR9:SetValue( "AR9_SERIE"  , ( cTmpCons )->AR1_SERIE )
                    oMdlAR9:SetValue( "AR9_NOTA"   , ( cTmpCons )->AR1_DOC )
                    oMdlAR9:SetValue( "AR9_DATANF" , SToD( ( cTmpCons )->AR1_NFEMIS ) )
                    oMdlAR9:SetValue( "AR9_CLIENT" , ( cTmpCons )->AR1_CLIENT )
                    oMdlAR9:SetValue( "AR9_LOJA"   , ( cTmpCons )->AR1_LOJA )
                    oMdlAR9:SetValue( "AR9_STATUS" , "0" ) // 0=Aguardando Envio
                    oMdlAR9:AddLine()
                    nTotalNf++
                    ( cTmpCons )->( DbSkip() )
                EndDo
                oMdlAR8:SetValue( "AR8_QTDENV", nTotalNf )
                If oModel:VldData()
                    oModel:CommitData()
                Else
                    aErrorMd := oModel:GetErrorMessage()
                    Help( "", 1, "RSK120QRY", , aErrorMd[6], 1 )
                EndIf
                oModel:Destroy()
            EndIf
            Sleep(1000)
        EndDo
    Else
        Help( "", 1, "RSK120QRY", , STR0015, 1 ) // "Nenhuma nota processada, por favor, verifique os filtros!"
    EndIf
    ( cTmpCons )->( DbCloseArea() )

	FWFreeArray( aErrorMd )

    FwFreeObj( oQueryAR1 )
    FwFreeObj( oModel )
    FwFreeObj( oMdlAR8 )
    FwFreeObj( oMdlAR9 )
Return

//-------------------------------------------------------------------
/*/
    {Protheus.doc} Rsk120BPDF
    Função para baixar e abrir o arquivo PDF disponibilizado.

    @author Daniel Moda
    @since 04/04/2024
    @version P12
/*/
//-------------------------------------------------------------------
Function Rsk120BPDF()                                   

Local cNomeArq As Character
Local cUrlArq  As Character
Local nPosPesq As Numeric

cNomeArq := ""
cURLArq  := ""
nPosPesq := 0

If !Empty( AR8->AR8_URLPDF )
    nPosPesq := RAt( "\", AllTrim( AR8->AR8_URLPDF ) )
    cNomeArq := SubString( AllTrim( AR8->AR8_URLPDF ), nPosPesq + 1, Len( AllTrim( AR8->AR8_URLPDF ) ) )
    cURLArq  := Left( AllTrim( AR8->AR8_URLPDF ), nPosPesq - 1 )
    If !MsDocView( cNomeArq, , , cURLArq )
        Help( "", 1, "RSK120BPDF", , STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0018 } ) // "Lote expirado!" # "Solicite um novo Lote dos Boletos!"
    EndIf
Else
    Help( "", 1, "RSK120BPDF", , STR0017, 1 ) // "Lote não foi gerado. Aguarde o retorno do processamento!"
EndIf

Return
