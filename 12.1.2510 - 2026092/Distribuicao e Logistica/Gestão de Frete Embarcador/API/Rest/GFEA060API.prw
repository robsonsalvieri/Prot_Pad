#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

//dummy function
Function GFEFreightComponents(); Return

/*/{Protheus.doc} FreightComponents
Implementa API de Componentes de Frete.

Verbos disponíveis: POST, GET, PUT, DELETE
@author Leandro Conradi Zmovirzynski
/*/

WSRESTFUL GFEFreightComponents DESCRIPTION 'Componente de Frete' FORMAT 'application/json,text/html'
    WSDATA Fields           AS  STRING  OPTIONAL
    WSDATA Order            AS  STRING  OPTIONAL
    WSDATA Page             AS  INTEGER OPTIONAL
    WSDATA PageSize         AS  INTEGER OPTIONAL
    WSDATA InternalId       AS  STRING  OPTIONAL
    WSDATA Code             AS  STRING  OPTIONAL


    WSMETHOD POST   v1 DESCRIPTION 'Cadastrar um novo componente de frete';
    PATH '/v1/freightComponents';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    all_v1 DESCRIPTION 'Carrega os componentes de frete';
    PATH '/v1/freightComponents';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    v1 DESCRIPTION 'Carrega um componente de frete específico';
    PATH '/v1/freightComponents/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT    v1 DESCRIPTION 'Altera um componente de frete específico';
    PATH '/v1/freightComponents/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE    v1 DESCRIPTION 'Deleta um componente de frete específicio';
    PATH '/v1/freightComponents/{InternalId}';
    PRODUCES APPLICATION_JSON


ENDWSRESTFUL

WSMETHOD POST    v1 WSSERVICE GFEFreightComponents
    Local oAdapter := GFEFreightComponentsAdapter():New( Self )
    Return oAdapter:Post()

WSMETHOD GET    all_v1 QUERYPARAM Page, PageSize, Order, Fields WSSERVICE GFEFreightComponents
    Local oAdapter := GFEFreightComponentsAdapter():New(Self)
    Return oAdapter:Get()

WSMETHOD GET    v1 PATHPARAM InternalId QUERYPARAM Fields WSSERVICE GFEFreightComponents
    Local oAdapter := GFEFreightComponentsAdapter():New( Self )
    Local cCode := ""
    Local cFilCod := ""

    SetArgument(::InternalId, @cFilCod, @cCode) 
    oAdapter:AddFilter('BranchId', cFilCod)
    oAdapter:AddFilter('Code', cCode)
    
Return oAdapter:Get()

WSMETHOD PUT v1 PATHPARAM InternalId WSSERVICE GFEFreightComponents
    Local oAdapter := GFEFreightComponentsAdapter():New( Self )
    Local cCode := ""
    Local cFilCod := ""
    
    SetArgument(::InternalId, @cFilCod, @cCode)
    oAdapter:AddFilter('BranchId', cFilCod)
    oAdapter:AddFilter('Code', cCode)

Return oAdapter:Put()

WSMETHOD DELETE v1 PATHPARAM InternalId WSSERVICE GFEFreightComponents
    Local oAdapter := GFEFreightComponentsAdapter():New( Self )
    Local cCode := ""
    Local cFilCod := ""
    
    SetArgument(::InternalId, @cFilCod, @cCode)
    oAdapter:AddFilter('BranchId', cFilCod)
    oAdapter:AddFilter('Code', cCode)

Return oAdapter:Delete()

Static Function SetArgument(cArgument, cFilCod, cCode)

    If Empty( XFilial( "GV2" ) )
        cFilCod := XFilial( "GV2" )
        cCode   := cArgument
    Else
        cFilCod := SubStr(cArgument, 1, Len( XFilial( "GV2" ) ) )
        cCode   := SubStr(cArgument, 1 + Len( XFilial( "GV2" ) ) )
    EndIf

Return