#include "PROTHEUS.CH"
#include "fwmvcdef.ch"
#include "OFIC549.ch"

/*/{Protheus.doc} OFIC549
    Tela de Consulta - Historico de Passagem Control Tower no Protheus
    @type  Function
    @author Bruno Forcato
    @since 25/11/2025
/*/
Function OFIC549()
    Local oBrowse
    Local aArea
    PRIVATE aRotina := MenuDef()

    aArea := GetArea()
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('VEW')
    oBrowse:SetDescription(STR0001) //Historico de Passagem Control Tower
    oBrowse:AddLegend("VEW_STAPAS == '0'", "YELLOW",STR0002) //Em Andamento
    oBrowse:AddLegend("VEW_STAPAS == '1'", "RED",STR0003) //Fechada
    oBrowse:Activate()
    RestArea(aArea)
Return

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIC549' OPERATION 2 ACCESS 0 // "Visualizar"

Return aRotina

Static Function ModelDef()
    Local oStruVEW := FWFormStruct( 1, 'VEW' )
    local oStruVEX := FWFormStruct( 1, 'VEX' )
    Local aVEXRel := {}
    Local oModel

    SetLegIntegracao(oStruVEX, .T.)

    oModel := MPFormModel():New('OFIC549M')
    oModel:AddFields( 'VEWMASTER',, oStruVEW)
    oModel:AddGrid("VEXDETAIL","VEWMASTER",oStruVEX)

    aAdd(aVEXRel, {"VEX_FILIAL","VEW_FILIAL"} )
    aAdd(aVEXRel, {"VEX_CODVEW","VEW_CODIGO" } )

    oModel:SetRelation("VEXDETAIL", aVEXRel, VEX->(IndexKey(1)))
    oModel:GetModel("VEXDETAIL"):SetUniqueLine({"VEX_CODIGO","VEX_CODVEW"})  

    oModel:SetDescription(STR0001) //Historico de Passagem Control Tower
    oModel:GetModel( 'VEWMASTER' ):SetDescription(STR0005) //Cabecalho
    oModel:GetModel( 'VEXDETAIL' ):SetDescription(STR0006) //Eventos
    oModel:SetPrimaryKey( { "VEW_FILIAL", "VEW_CODIGO" } )
    oModel:SetOptional('VEXDETAIL')
Return oModel

Static Function ViewDef()
    Local oModel   := FWLoadModel('OFIC549')
    Local oStruVEW := FWFormStruct( 2, 'VEW' )
    Local oStruVEX := FWFormStruct( 2, 'VEX' )
    Local oView

	//Remove os campos de Filial e Tabela da Grid
	oStruVEX:RemoveField('VEX_FILIAL')
	oStruVEX:RemoveField('VEX_CODVEW')
    oStruVEX:RemoveField('VEX_CODIGO')
    ostruVEX:RemoveField('VEX_CODUEV')
    ostruVEX:RemoveField('VEX_INTCON')
    ostruVEX:RemoveField('VEX_CODEVE')

    SetLegIntegracao(oStruVEX)

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_VEW', oStruVEW, 'VEWMASTER' )
    oView:AddGrid('VIEW_VEX', oStruVEX,'VEXDETAIL')

    oView:CreateHorizontalBox( 'TELA' , 60 )
    oView:CreateHorizontalBox('GRID',40)

    oView:SetOwnerView( 'VIEW_VEW', 'TELA' )
    oView:SetOwnerView( 'VIEW_VEX', 'GRID' )
 
    //Botão Legenda
    oView:AddUserButton( 'Legenda', 'CLIPS', { |oView| FLegenda() } )//'Legenda'

    oView:SetCloseOnOk({||.T.})
Return oView


Static Function SetLegIntegracao( oStruVEX, lModel )  

    Default lModel := .F.

 // ---------------------
 // Integração concluída   0=Não;1=Sim       
 // ----------------------

If lModel 

    oStruVEX:AddField( ;
        AllTrim('') , ;               // [01] C Titulo do campo
        AllTrim('') , ;               // [02] C ToolTip do campo
        'VEX_LEGINT' , ;               // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                      // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de validação do campo
        NIL , ;                     // [08] B Code-block de validação When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
        FwBuildFeature(STRUCT_FEATURE_INIPAD,'OFIC549Legenda()' ) , ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
        .T. )                      // [14] L Indica se o campo é virtual    

Else 

    oStruVEX:AddField( ;                      // Ord. Tipo Desc.
        'VEX_LEGINT'                        , ;        // [01] C   Nome do Campo
        "00"                             , ;     // [02] C   Ordem
        AllTrim( ''    )        , ;     // [03] C   Titulo do campo
        AllTrim( '' )       , ;     // [04] C   Descricao do campo
        { 'Legenda' }           , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo é alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opção do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo é virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha após o campo 
 

EndIf 


Return()

Function OFIC549Legenda() 

Local oModel    := FwModelActive()
Local cRet      := "BR_VERMELHO" 

If oModel:GetOperation() <> MODEL_OPERATION_INSERT    
    If VEX->VEX_INTCON == "1" .or. Empty(VEX->VEX_CODVK5)
        cRet :=  "BR_VERDE"
    EndIf 
EndIf 

Return( cRet )

Static Function FLegenda()

	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERMELHO"    ,	STR0007  })     // "Pendente"
	AADD(aLegenda,{"BR_VERDE"       ,	STR0008  })     // "Integrado"
	
	BrwLegenda( STR0009, STR0010 , aLegenda)   // "Integração Control Tower" #"Histórico de Passagem"

Return()
