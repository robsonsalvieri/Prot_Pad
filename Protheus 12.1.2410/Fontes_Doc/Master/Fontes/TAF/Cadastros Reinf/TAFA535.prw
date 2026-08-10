#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA535.CH"

PUBLISH MODEL REST NAME TAFA535 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA535
MVC Pagamentos das Parcelas da fatura/recibo 
Layout totvs T158 / T158AA

@author Henrique Pereira			
@since 11/06/2019
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA535(cTafatura, cSerie, cIdPart, lAutomato)  
Private cNumFat     as Character
Private cFatParc    as Character
Private cSerieFat   as Character
Private cIdParFat   as Character

Default cTafatura   :=  ''
Default cSerie      :=  ''
Default cIdPart     :=  ''
Default lAutomato   :=  .F.

cNumFat     := cTafatura
cSerieFat   := cSerie
cIdParFat   := cIdPart
cFatParc    := ''



if TAFAlsInDic("V3U") .And. TAFAlsInDic("V85") .And. TAFAlsInDic("V90") .And. TAFAlsInDic("V95")   
    browsedef(lAutomato)  
else
    Aviso( STR0001, STR0002, { STR0003 }, 3 )  // #Aviso , "Ambiente desatualizado para execução desta Rotina. Tabelas: V3U e V3V não existem no metadados.", {Encerrar}                                                                                                                                                                                                                                                                                                                                                                                                                 
endif

return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//-------------------------------------------------------------------
static function browsedef(lAutomato)

local oBrowse   as object
Default lAutomato   :=  .F.
//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oBrowse := FWmBrowse():New()

DBSelectArea("V3U")
DbSetOrder(1)

oBrowse:SetDescription( STR0004 )	//"Pagamentos das Parcelas da fatura/recibo  //#STR
if !empty(cNumFat)
    oBrowse:SetFilterDefault( "V3U_NUMERO == '" + cNumFat + "' .And. V3U_SERIE == '" + cSerieFat + "' .And. V3U_IDPART == '" + cIdParFat + "' ")
endif
oBrowse:SetAlias( 'V3U')
oBrowse:SetMenuDef( 'TAFA535' )	
If !lAutomato
    oBrowse:Activate()
EndIf

return oBrowse

//--------------------------------------------------
/*/{Protheus.doc} modeldef
Model de Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
static function modeldef()
local oModel     as object
local oStruV3U   as object
local oStruV3V   as object
Local oStruV46   as object
local oStruV4H   as object
local oStruV4I   as object
local oStruV85   as object
local oStruV90   as object
local oStruV95   as object
local oStruV4J   as object
Local bValidV46

oModel := MPFormModel():new("TAFA535")

//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oStruV3U := FWFormStruct(1,"V3U") 
oStruV3V := FWFormStruct(1,"V3V")
oStruV46 := FWFormStruct(1,"V46")
oStruV4H := FWFormStruct(1,"V4H")
oStruV4I := FWFormStruct(1,"V4I")
oStruV85 := FWFormStruct(1,"V85")
oStruV90 := FWFormStruct(1,"V90")
oStruV95 := FWFormStruct(1,"V95")

oStruV4J := FWFormStruct(1,"V4J")
oModel   := MPFormModel():new("TAFA535",,{ | oModel | ValidModel( oModel ) },{|oModel| SaveModel( oModel ) })

oModel:addfields('MODEL_V3U',,oStruV3U ) // Pagamentos
oModel:GetModel('MODEL_V3U'):SetPrimaryKey( { "V3U_FILIAL", "V3U_NUMERO", "V3U_SERIE", "V3U_IDPART", "V3U_DTEMIS", "V3U_NATTIT", "V3U_PARCEL", "V3U_DTPAGT", "V3U_SEQUEN" } )

oStruV3U:SetProperty( "V3U_NUMERO", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_SERIE", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_CODPAR", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_DTEMIS", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_NATTIT", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_PARCEL", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
oStruV3U:SetProperty( "V3U_SEQUEN", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )
If TAFColumnPos("V3U_PERAPU")
    oStruV3U:SetProperty( "V3U_PERAPU", MODEL_FIELD_WHEN, { || Iif(oModel:GetOperation( ) == MODEL_OPERATION_UPDATE,Empty(V3U->V3U_PRID40),Empty(M->V3U_PRID40)) } )
EndIf    

oStruV3V:SetProperty( "V3V_CNATRE", MODEL_FIELD_VALID, { | | VldNat( @oModel ) }  ) // Validação do campo V3V_CNATRE

oModel:addgrid('MODEL_V3V','MODEL_V3U',oStruV3V,, { | | VldLineV3V( @oModel:GetModel( "MODEL_V3V" ) ) } ) // Natureza
oModel:GetModel("MODEL_V3V"):SetUniqueLine( { "V3V_CNATRE", "V3V_DECTER" } )
oModel:SetRelation("MODEL_V3V",{ {"V3V_FILIAL","xFilial('V3V')"}, {"V3V_ID","V3U_ID"} },V3V->(IndexKey(1)))

bValidV46 := { | oModelGrid, nLine, cAction, cField, xValNew, xValOld | VldV46Pre( oModelGrid, cAction, cField, xValNew, xValOld ) }

oModel:addgrid( "MODEL_V46", "MODEL_V3V", oStruV46, bValidV46 ) // Tributos
oModel:GetModel( "MODEL_V46" ):SetUniqueLine( { "V46_IDTRIB" } )
oModel:SetRelation( "MODEL_V46", { { "V46_FILIAL", "xFilial( 'V46' )" }, { "V46_ID", "V3U_ID" }, { "V46_IDNAT", "V3V_CNATRE" } }, V46->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_V46' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4H','MODEL_V3V',oStruV4H) // Suspensao
oModel:GetModel("MODEL_V4H"):SetUniqueLine({"V4H_IDPROC","V4H_IDSUSP","V4H_IDTRIB"})
oModel:SetRelation("MODEL_V4H",{ {"V4H_FILIAL","xFilial('V4H')"}, {"V4H_ID","V3U_ID"}, { "V4H_CNATRE", "V3V_CNATRE" } },V4H->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4H' ):SetOptional( .T. )

oModel:addgrid('MODEL_V90','MODEL_V4H',oStruV90,, {|oModelGrid| TafVldV90(oModelGrid)}) //V90_FILIAL, V90_ID, V90_CNATRE, V90_IDPROC, V90_IDSUSP, V90_IDTRIB, V90_TPDEDU
oModel:GetModel("MODEL_V90"):SetUniqueLine({"V90_TPDEDU"})
oModel:SetRelation("MODEL_V90",{ {"V90_FILIAL","xFilial('V90')"}, {"V90_ID","V3U_ID"}, { "V90_CNATRE", "V3V_CNATRE" }, { "V90_IDPROC", "V4H_IDPROC" }, { "V90_IDSUSP", "V4H_IDSUSP" }, { "V90_IDTRIB", "V4H_IDTRIB" } },V90->(IndexKey(1)))
oModel:GetModel( 'MODEL_V90' ):SetOptional( .T. )

oModel:addgrid('MODEL_V95','MODEL_V90',oStruV95,, {|oModelGrid| TafVldV95(oModelGrid)}) //V95_FILIAL+V95_ID+V95_IDPART+V95_CNATRE+V95_IDPROC+V95_IDSUSP+V95_IDTRIB+V95_TPDEDU+V95_CODDEP
oModel:GetModel("MODEL_V95"):SetUniqueLine({"V95_CODDEP"})
oModel:SetRelation("MODEL_V95",{ {"V95_FILIAL","xFilial('V95')"}, {"V95_ID","V3U_ID"}, {"V95_IDPART","V3U_IDPART"}, { "V95_CNATRE", "V3V_CNATRE" }, { "V95_IDPROC", "V4H_IDPROC" }, { "V95_IDSUSP", "V4H_IDSUSP" }, { "V95_IDTRIB", "V4H_IDTRIB" }, { "V95_TPDEDU", "V90_TPDEDU" } },V95->(IndexKey(1)))
oModel:GetModel( 'MODEL_V95' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4I','MODEL_V46',oStruV4I,, { | | VldLineV4I( ) } ) // Dedução
oModel:GetModel("MODEL_V4I"):SetUniqueLine({"V4I_TPDEDU"}) //V4I_FILIAL+V4I_ID+V4I_IDNAT+V4I_IDTRIB+V4I_TPDEDU
oModel:SetRelation("MODEL_V4I",{{"V4I_FILIAL","xFilial('V4I')"},{"V4I_ID","V3U_ID"}, {"V4I_IDNAT","V3V_CNATRE"}, {"V4I_IDTRIB","V46_IDTRIB"} },V4I->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4I' ):SetOptional( .T. )

oModel:addgrid('MODEL_V85','MODEL_V4I',oStruV85,, {|oModelGrid| TafVldV85(oModelGrid)} /*blinepost*/ ) // T158AF (V85) Beneficiário da pensão alimentícia
oModel:GetModel("MODEL_V85"):SetUniqueLine({"V85_CODDEP"}) //V85_FILIAL+V85_ID+V85_IDPART+V85_IDNAT+V85_IDTRIB+V85_TPDEDU+V85_CODDEP
oModel:SetRelation("MODEL_V85",{{"V85_FILIAL","xFilial('V85')"},{"V85_ID","V3U_ID"},{"V85_IDPART","V3U_IDPART"},{"V85_IDNAT","V3V_CNATRE"},{"V85_IDTRIB","V46_IDTRIB"},{"V85_TPDEDU","V4I_TPDEDU"}},V85->(IndexKey(1)))
oModel:GetModel( 'MODEL_V85' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4J','MODEL_V46',oStruV4J,, { | | VldLineV4J( ) } ) // Isenção
oModel:GetModel("MODEL_V4J"):SetUniqueLine({"V4J_IDTPIS"})
oModel:SetRelation("MODEL_V4J",{{"V4J_FILIAL","xFilial('V4J')"},{"V4J_ID","V3U_ID"}, {"V4J_IDNAT","V3V_CNATRE"}, {"V4J_IDTRIB","V46_IDTRIB"} },V4J->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4J' ):SetOptional( .T. )

return oModel

//--------------------------------------------------
/*/{Protheus.doc} viewdef
View de Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
static function viewdef()

local oView     as object
local oModel    as object
local oStruV3U  as object
local oStruV3V  as object
local oStruV4H  as object
local oStruV4I  as object
local oStruV4J  as object
local oStruV85  as object
local oStruV90  as object
local oStruV95  as object

//--------------------------------------------
// Inicialização variáveis do tipo obejeto
//--------------------------------------------
oView    := FWFormView():new()
oModel   := FWLoadModel('TAFA535')
oStruV3U := FwFormStruct(2,"V3U")
oStruV46 := FwFormStruct(2,"V46")
oStruV3V := FwFormStruct(2,"V3V")
oStruV4H := FwFormStruct(2,"V4H")
oStruV4I := FwFormStruct(2,"V4I")
oStruV85 := FwFormStruct(2,"V85")
oStruV90 := FwFormStruct(2,"V90")
oStruV95 := FwFormStruct(2,"V95")
oStruV4J := FwFormStruct(2,"V4J")

oView:SetModel( oModel )
oView:SetContinuousForm( .T. )

oView:AddField( "VIEW_V3U", oStruV3U, "MODEL_V3U" )
oView:EnableTitleView( "VIEW_V3U", STR0015 ) //"Pagamentos"
oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 25 )
oView:SetOwnerView( "VIEW_V3U", "PAINEL_SUPERIOR" )

oView:AddGrid(  "VIEW_V3V", oStruV3V, "MODEL_V3V" )
oView:EnableTitleView( "VIEW_V3V", STR0036 ) //"Naturezas de Rendimento"
oView:CreateHorizontalBox( "PAINEL_INTERMEDIARIO", 25 )
oView:SetOwnerView( "VIEW_V3V", "PAINEL_INTERMEDIARIO" )

oView:CreateHorizontalBox( "PAINEL_INFERIOR", 50 )
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

oView:AddSheet("FOLDER_INFERIOR","ABA01", STR0017 ) //"Tributos
oView:AddGrid(  "VIEW_V46", oStruV46, "MODEL_V46" )
oView:EnableTitleView( "VIEW_V46", STR0016 ) //"Tributos sobre o pagamento da parcela por Natureza de Rendimento"
oView:CreateHorizontalBox("BOXH_TRIBUTOS", 50,,,"FOLDER_INFERIOR","ABA01" )
oView:SetOwnerView( "VIEW_V46", "BOXH_TRIBUTOS" ) 

oView:AddSheet("FOLDER_INFERIOR","ABA02", STR0020) //"Suspensão"
oView:AddGrid(  "VIEW_V4H", oStruV4H, "MODEL_V4H" )
oView:EnableTitleView( "VIEW_V4H", STR0021 ) //"Suspensão de exigibilidade de tributo por natureza de rendimento"
oView:CreateHorizontalBox("BOXH_SUSPENSAO", 50,,,"FOLDER_INFERIOR","ABA02")
oView:SetOwnerView( "VIEW_V4H", "BOXH_SUSPENSAO" )   

oView:CreateHorizontalBox( 'PAINEL_INFERIOR3',25,,,'FOLDER_INFERIOR', 'ABA02' ) //cria origem PAINEL_INFERIOR2 no destino FOLDER_CHILD_V46 ABA03
oView:CreateFolder( 'FOLDER_INFERIOR3', 'PAINEL_INFERIOR3' )

oView:AddSheet("FOLDER_INFERIOR3","ABA01",STR0049 ) //"Deduções Suspensas"
oView:AddGrid(  "VIEW_V90", oStruV90, "MODEL_V90" )
oView:EnableTitleView( "VIEW_V90", STR0048 ) //"Detalhamento das deduções com exigibilidade suspensa."

oView:CreateHorizontalBox("BOXH_DEDUSUSP", 50,,,"FOLDER_INFERIOR3","ABA01" )
oView:SetOwnerView( "VIEW_V90", "BOXH_DEDUSUSP" )

oView:CreateHorizontalBox( 'PAINEL_INFERIOR4',50,,,'FOLDER_INFERIOR3', 'ABA01' )
oView:CreateFolder( 'FOLDER_INFERIOR4', 'PAINEL_INFERIOR4' )

oView:AddSheet("FOLDER_INFERIOR4","ABA01",STR0054 ) //"Beneficiários Pensão"
oView:AddGrid(  "VIEW_V95", oStruV95, "MODEL_V95" )
oView:EnableTitleView( "VIEW_V95", STR0055 ) //"Informação dos dependentes e beneficiários da pensão alimentícia."

oView:CreateHorizontalBox("BOXH_BENDEDUSUSP", 100,,,"FOLDER_INFERIOR4","ABA01" )
oView:SetOwnerView( "VIEW_V95", "BOXH_BENDEDUSUSP" )

oView:CreateHorizontalBox( 'BOX_CHILD_V46',50,,,'FOLDER_INFERIOR', 'ABA01' )
oView:CreateFolder( 'FOLDER_CHILD_V46', 'BOX_CHILD_V46' )

oView:AddSheet( 'FOLDER_CHILD_V46', 'ABA03', STR0018 ) //"Dedução"
oView:AddGrid(  "VIEW_V4I", oStruV4I, "MODEL_V4I" )
oView:EnableTitleView( "VIEW_V4I", STR0022 ) //"Dedução do Tributo por Natureza de Rendimento"
oView:CreateHorizontalBox( 'BOXH_DEDUCAO', 50,,, 'FOLDER_CHILD_V46', 'ABA03' )
oView:SetOwnerView( "VIEW_V4I", "BOXH_DEDUCAO" )

oView:AddSheet( 'FOLDER_CHILD_V46', 'ABA04', STR0019 ) //"Isenção"
oView:AddGrid(  "VIEW_V4J", oStruV4J, "MODEL_V4J" )
oView:EnableTitleView( "VIEW_V4J", STR0023 ) //"Isenção do Tributo por Natureza de Rendimento"
oView:CreateHorizontalBox( 'BOXH_ISENCAO',50,,, 'FOLDER_CHILD_V46', 'ABA04' )
oView:SetOwnerView( "VIEW_V4J", "BOXH_ISENCAO" )

oView:CreateHorizontalBox( 'PAINEL_INFERIOR2',25,,,'FOLDER_CHILD_V46', 'ABA03' ) //cria origem PAINEL_INFERIOR2 no destino FOLDER_CHILD_V46 ABA03
oView:CreateFolder( 'FOLDER_INFERIOR2', 'PAINEL_INFERIOR2' )

oView:AddSheet("FOLDER_INFERIOR2","ABA01", STR0042) //"Dependentes Beneficiários Pensão"
oView:AddGrid(  "VIEW_V85", oStruV85, "MODEL_V85" )
oView:EnableTitleView( "VIEW_V85", STR0043 ) //"Informação dos dependentes e beneficiários da pensão alimentícia"

oView:CreateHorizontalBox("BOXH_BEN", 100,,,"FOLDER_INFERIOR2","ABA01" )
oView:SetOwnerView( "VIEW_V85", "BOXH_BEN" )

//Removendo campos que não devem ser exibidos
oStruV3U:RemoveField( "V3U_ID"     )
oStruV3U:RemoveField( "V3U_IDPART" )
oStruV3U:RemoveField( "V3U_IDFTPC" )

oStruV3V:RemoveField( "V3V_ID"     )
oStruV3V:RemoveField( "V3V_IDPROC" )
oStruV3V:RemoveField( "V3V_CNATRE" )

If TAFColumnPos("V3V_IFCISC")
    oStruV3V:RemoveField( "V3V_IFCISC" )
EndIf

oStruV46:RemoveField( "V46_ID"     )
oStruV46:RemoveField( "V46_IDNAT"  )
oStruV46:RemoveField( "V46_IDTRIB" )

oStruV4H:RemoveField( "V4H_ID"     )
oStruV4H:RemoveField( "V4H_IDTRIB" )
oStruV4H:RemoveField( "V4H_IDSUSP" )

oStruV4I:RemoveField( "V4I_ID"     )
oStruV4I:RemoveField( "V4I_IDTRIB" )
oStruV4I:RemoveField( "V4I_IDNAT"  )

oStruV4J:RemoveField( "V4J_ID"     )
oStruV4J:RemoveField( "V4J_IDTRIB" )
oStruV4J:RemoveField( "V4J_IDNAT"  )
oStruV4J:RemoveField( "V4J_IDTPIS" )

return oView

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
Static Function MenuDef()

Local aRotina as array

//--------------------------------------------
// Inicialização variáveis do tipo array
//--------------------------------------------
aRotina := {}

ADD OPTION aRotina Title "Visualizar"  Action 'VIEWDEF.TAFA535' OPERATION 2 ACCESS 0 //"Visualizar" #str
ADD OPTION aRotina Title "Incluir"     Action 'VIEWDEF.TAFA535' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title "Alterar"     Action 'VIEWDEF.TAFA535' OPERATION 4 ACCESS 0 //"Alterar" #str
ADD OPTION aRotina Title "Excluir"     Action 'VIEWDEF.TAFA535' OPERATION 5 ACCESS 0 //"Excluir" 

Return(aRotina)

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
Static Function SaveModel(oModel)

Local nOper := oModel:getOperation()
Begin Transaction
    If ( nOper == MODEL_OPERATION_UPDATE )  .OR. ( nOper == MODEL_OPERATION_INSERT )
        AmarraFat( oModel )
    EndIf

    If FWFormCommit( oModel ) 
        If  ( nOper == MODEL_OPERATION_UPDATE ) .Or. ( nOper == MODEL_OPERATION_DELETE ) 
            TafEndGRV( "V3U","V3U_PRID40", '', V3U->(Recno())  )
        Endif
    Endif
End Transaction

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AmarraFat

Função de validação da inclusão dos dados, chamada
no final, no momento da gravação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T. ou .F.

@Author	Henrique Pereira
@Since		14/06/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AmarraFat( oModel )
Local oModelV3U     as object 
Local cIdFatParc    as character
Local cNumero       as character
Local cSerie        as character
Local cIdPart       as character
Local dDtEmiss      as character
Local cNatTit       as character

//-----------------------------------------------
// Inicialização variáveis do tipo objeto
//-----------------------------------------------
oModelV3U   :=  oModel:GetModel('MODEL_V3U')

//-----------------------------------------------
// Inicialização variáveis do tipo caracter
//-----------------------------------------------
cIdFatParc := oModelV3U:GetValue("V3U_IDFTPC")

If Empty( cIdFatParc )

    cNumero     :=  oModelV3U:GetValue("V3U_NUMERO")
    cSerie      :=  oModelV3U:GetValue("V3U_SERIE")
    cIdPart     :=  oModelV3U:GetValue("V3U_IDPART")
    dDtEmiss    :=  oModelV3U:GetValue("V3U_DTEMIS")
    cNatTit     :=  oModelV3U:GetValue("V3U_NATTIT")
    cFatParc    :=  ExistFat(cNumero, cSerie, cIdPart, dDtEmiss, cNatTit )

    oModel:LoadValue( 'MODEL_V3U', 'V3U_IDFTPC', cFatParc)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistFat 

Função de busca da fatura existente na base com base nos valores digitado na tela ou mesmo vindo de integração
no final, no momento da gravação do modelo.

@Return	.T. ou .F.

@Author	Henrique Pereira
@Since		14/06/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
function ExistFat(cNumero, cSerie, cIdPart, dDtEmiss, cNatTit )

Local cRet      as character
Local cAlias    as character

default cNumero  := ''
default cSerie   := '' 
default cIdPart  := ''
default dDtEmiss := '' 
default cNatTit  := ''

cRet := ''
 
//-----------------------------------------------
// Inicialização variáveis do tipo caracter
//-----------------------------------------------
cAlias :=  getnextalias()

if len(alltrim(cIdPart)) < 36 .and. !empty(cIdPart)
    cIdPart := POSICIONE("C1H",1,XFILIAL("C1H")+cIdPart,"C1H_ID") 
endif

beginsql alias cAlias
    SELECT LEM.LEM_ID AS ID
    FROM %TABLE:LEM% LEM
    WHERE LEM.D_E_L_E_T_        <> %Exp:'*'% 
        AND LEM.LEM_FILIAL    = %xFilial:LEM%
        AND LEM.LEM_NUMERO    = %Exp:cNumero%
        AND LEM.LEM_PREFIX    = %Exp:cSerie%
        AND LEM.LEM_IDPART    = %Exp:cIdPart% 
        AND LEM.LEM_DTEMIS    = %Exp:dDtEmiss%
        AND LEM.LEM_NATTIT    = %Exp:cNatTit% 
endsql 

(cAlias)->(DbGoTop())
if (cAlias)->(!EOF())
    cRet := (cAlias)->ID
endif
(cAlias)->( DbCloseArea())
return(cRet)

//-------------------------------------------------------------------
/*{Protheus.doc} TAF535Cbox
Função de combo box para o campo V4I_TPDEDU, necessário pois as opções ultrapassam o tamanho máx. 

@author Denis Souza
@since 17/07/2019
@version 1.0
*/
Function TAF535Cbox()

Local cString	:=	""

cString := "1=" + STR0024 //"Previdência Oficial;"
cString += "2=" + STR0025 //"Previdência Privada;"
cString += "3=" + STR0026 //"Fapi;"
cString += "4=" + STR0027 //"Funpresp;" 
cString += "5=" + STR0028 //"Pensão Alimentícia;"
cString += "7=" + STR0030 //"Dependentes;"
cString += "8=" + STR0056 //"Desconto simplificado mensal;"


Return( cString )

//-------------------------------------------------------------------
/*{Protheus.doc} VldLineV4I
Função que realiza a validação dos campos da tabela V4I

@author Denis Souza / Wesley Pinheiro
@since 07/11/2019
@version 1.0
*/
Static Function VldLineV4I( )

    Local lOk := .T.

    If FwFldGet("V4I_TPDEDU") $ '234' .And. Empty( FwFldGet("V4I_NUMPRE") )
		Help("",1,"Help","Help",STR0031, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0033}) //"O N° de Inscrição da Previdência se torna obrigatório quando o Tipo Dedução é igual 2, 3 ou 4."#"Informe um conteúdo válido."
		lOk := .F.
	EndIf

Return lOk

//-------------------------------------------------------------------
/*{Protheus.doc} VldLineV4J
Função que realiza a validação dos campos da tabela V4J

@author Denis Souza / Wesley Pinheiro
@since 07/11/2019
@version 1.0
*/
Static Function VldLineV4J( )

    Local lOk := .T.

    If FwFldGet("V4J_CDTPIS") $ '99' .And. Empty( FwFldGet("V4J_DRENDI") )
		Help("",1,"Help","Help",STR0032, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0033}) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"#"Informe um conteúdo válido."
		lOk := .F.
	EndIf

Return lOk

//-------------------------------------------------------------------
 /*{Protheus.doc} VldLineV3V
Valida linha V3V - Natureza
@author Wesley Pinheiro 
@since 17/10/2019
@version 1.0
*/
Static Function VldLineV3V( oModelV3V )

    Local cIndRRA := ""
	Local cTpProc := ""
	Local cNrProc := ""
    Local lRet    := .T.

    cIndRRA := oModelV3V:GetValue( "V3V_INDRRA" )
    cTpProc := oModelV3V:GetValue( "V3V_TPCRRA" )
    cNrProc := oModelV3V:GetValue( "V3V_NRPROC" )

    If !Empty( cIndRRA ) .Or. !Empty( cTpProc ) .Or. !Empty( cNrProc ) 
        DBSelectArea( "V4F" )
        V4F->( DbSetOrder( 2 ) ) // V4F_FILIAL + V4F_INDRRA + V4F_TPPROC + V4F_NRPROC

        If V4F->( DbSeek( xFilial( "V4F" ) + Alltrim( cIndRRA ) + Alltrim( cTpProc ) + cNrProc ) )
            oModelV3V:LoadValue( "V3V_IDPROC", V4F->V4F_ID )
        Else
            lRet := .F.
            oModelV3V:GetModel():SetErrorMessage( ,,,, STR0034, STR0037, STR0038 ) // #"ATENÇÃO!", #"A Despesa Processsual informada não existe." , #"Verifique se os campos: Num.processo, Indicat.RRA e Tp.Proc. RRA forma preenchidos corretamente."
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
 /*{Protheus.doc} VldNat
Função que verifica se a natureza de rendimento não é tributável
@author Wesley Pinheiro 
@since 17/10/2019
@version 1.0
*/
Static Function VldNat( oModel )

    Local oModelV46
    Local cNatRen   := oModel:GetModel( "MODEL_V3V" ):GetValue( "V3V_CNATRE" )
    Local nI        := 0
    Local nLinhas   := 0
    Local lRet      := .T.
    Local lEmptyV46 := .F.
    Local cNotTrib  := ""
    Local cCodNat   := ""

    If !Empty( cNatRen )

        cNotTrib := GetAdvFVal( "V3O", "V3O_TRIB", xFilial( "V3O" ) + cNatRen, 2 ) // V3O_FILIAL + V3O_ID

        If cNotTrib == "8"
            oModelV46 := oModel:GetModel( "MODEL_V46" )
            nLinhas   := oModelV46:Length( )

            for nI := 1 to nLinhas // É feito a verificação da grid V46 ( Tributos ) porque o usuário pode alterar a grid V3V ( Naturezas ) para uma natureza não tributável

                oModelV46:GoLine( nI )
                
                If oModelV46:IsDeleted( )
                    Loop
                EndIf

                if  (; 
                    Empty( FwFldGet( "V46_DESTRI", nI ) ).and. Empty( FwFldGet( "V46_IDTRIB", nI ) ) .and.;
                    Empty( FwFldGet( "V46_BASE"  , nI ) ).and. Empty( FwFldGet( "V46_VALOR" , nI ) ) .and.;
                    Empty( FwFldGet( "V46_ALIQ"  , nI ) );
                    )
                        lEmptyV46 := .T.
                EndIf

                If !lEmptyV46
                    cCodNat := GetAdvFVal( "V3O", "V3O_CODIGO", xFilial( "V3O" ) + cNatRen, 2 )
                    oModel:SetErrorMessage( ,,,, STR0034, STR0035 + " " + cCodNat, STR0039 + " " + cCodNat ) // #"ATENÇÃO", #"A Natureza de Rendimento selecionada não possui tributação. Cod: ", #"Não preencha a aba tributos para a Natureza de Rendimento"
                    lRet := .F.
                    exit
                endif

            Next nI

        EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
 /*{Protheus.doc} VldV46Pre 
Função que verifica se a natureza de rendimento não é tributável
@author Wesley Pinheiro
@since 17/10/2019
@version 1.0
*/
Static Function VldV46Pre( oModelGrid, cAction, cField, xValNew, xValOld )

    Local oModel	:= FWModelActive( )
    Local cNatRen   := oModel:GetModel( "MODEL_V3V" ):GetValue( "V3V_CNATRE" )
    Local lRet      := .T.
    Local cNotTrib  := ""
    Local cCodNat   := ""


    If ( cAction == "CANSETVALUE" .or. (cAction == "SETVALUE" .and. isBlind()) ) .and. !Empty( cNatRen )

        cNotTrib := GetAdvFVal( "V3O", "V3O_TRIB", xFilial( "V3O" ) + cNatRen, 2 ) // V3O_FILIAL + V3O_ID

        If cNotTrib == "8"
            
            cCodNat := GetAdvFVal( "V3O", "V3O_CODIGO", xFilial( "V3O" ) + cNatRen, 2 )

            if isBlind( )
                 oModel:SetErrorMessage( ,,,, STR0034, STR0035 + " " + cCodNat, STR0039 + " " + cCodNat ) //"ATENÇÃO!"  #"A Natureza de Rendimento selecionada não possui tributação. Cod: "
            Else
                MsgAlert(  STR0035 + " " + cCodNat, STR0034 ) //#"A Natureza de Rendimento selecionada não possui tributação. Cod: " #"ATENÇÃO!"                 
            EndIf
            
            lRet := .F.

        EndIf
    
    EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} ValidModel

Função utilizada para validar a gravação do Model.
Validação: Evitar gravar fatura/recibo com os mesmos valores da chave mais forte da tabela V3U
indice 2 -> V3U_FILIAL + V3U_NUMERO + V3U_SERIE + V3U_IDPART + V3U_DTEMIS + V3U_NATTIT + V3U_PARCEL + V3U_DTPAGT + V3U_SEQUEN

@return lRet .T. = Gravação será realizada ( Não existe chave ) / .F. = Gravação não será realizada ( existe chave )

@author Wesley Pinheiro
@since 29/10/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
	Local cNum  		as Character
	Local cSerie     	as Character
	Local cIdPartic		as Character
	Local cDtEmiss 		as Character
    Local cNatTit  		as Character
    Local cParcela      as Character
    Local cDtPgto       as Character
    Local cSequen       as Character
	Local oModelV3U 	as Object
	Local lRet			as Logical
	Local aAreaV3U		as Array

	oModelV3U  := oModel:GetModel( "MODEL_V3U" )
	aAreaV3U   := V3U->( GetArea( ) )
	lRet       := .T.
    cNum       := ""
    cSerie     := ""
    cIdPartic  := ""
    dDtEmiss   := Ctod( "//" )
    cNatTit    := ""
    cParcela   := ""
    dDtPgto    := Ctod( "//" )
    cSequen    := ""
	
	If oModel:GetOperation( ) == MODEL_OPERATION_INSERT

		V3U->( DbSetOrder( 2 ) ) //  V3U_FILIAL + V3U_NUMERO + V3U_SERIE + V3U_IDPART + V3U_DTEMIS + V3U_NATTIT + V3U_PARCEL + V3U_DTPAGT + V3U_SEQUEN

        cNum      := oModelV3U:GetValue( "V3U_NUMERO" )
        cSerie    := oModelV3U:GetValue( "V3U_SERIE"  )
        cIdPartic := oModelV3U:GetValue( "V3U_IDPART" )
        cDtEmiss  := Dtos( oModelV3U:GetValue( "V3U_DTEMIS" ) )
        cNatTit   := oModelV3U:GetValue( "V3U_NATTIT" )
        cParcela  := oModelV3U:GetValue( "V3U_PARCEL" )
        cDtPgto   := Dtos( oModelV3U:GetValue( "V3U_DTPAGT" ) )
        cSequen   := oModelV3U:GetValue( "V3U_SEQUEN" )
		
        If V3U->( DbSeek( xFilial( "V3U" ) + cNum + cSerie + cIdPartic + cDtEmiss + cNatTit + cParcela + cDtPgto + cSequen ) )
            lRet := .F.
            Help( ,1, "HELP",, STR0040, 1, 0,,,,,,{ STR0041 } ) // #"Já existe um Pagamento com as informações de: Série, Cod.Partic., Dt. Emissão, Natureza, Num. Parcela, Dt Pagto e Sequencial." #"Altere o conteúdo dos campos informados acima!"
        EndIf
    
	EndIf

	RestArea( aAreaV3U )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} SX7CabV3U

Gatilha as informações do cabeçalho da rotina de pagamento de fatura/recibo, desde que exista fatura ( tabela LEM )

@param  cNumFat - Número da fatura
@return cSerie  - Número de séria fatura/recibo

@author Wesley Pinheiro
@since 05/11/2019
@version 1.0
*/
//-------------------------------------------------------------------
Function SX7CabV3U( cNumFat as character, cSerie as character, cIdPart as character)


    Local aAreaLEM  as Array 
    Local aAreaC1H  as Array 
    Local oModel    as Object
    Local oModelV3U as Object
    Local nIndice   as number
    Local cChave    as character

    aAreaLEM  := LEM->( GetArea( "LEM" ) )
    aAreaC1H  := C1H->( GetArea( "C1H" ) )
    oModel    := FWModelActive( )
    oModelV3U := oModel:GetModel( "MODEL_V3U" )

    Default cNumFat     := ''
    Default cSerie      := ''
    Default cIdPart     := ''

    If allTrim(cIdPart) <> '' .And. allTrim(cNumFat) <> ''

		nIndice     := 2 // LEM_FILIAL+LEM_PREFIX+LEM_NUMERO+LEM_IDPART+DTOS(LEM_DTEMIS)
		cChave      := cSerie + cNumFat + cIdPart

	Else
		nIndice := 4 // LEM_FILIAL + LEM_NUMERO
		cChave := cNumFat
		cSerie := LEM->LEM_PREFIX
	EndIf


    LEM->( DbSetOrder( nIndice ) )

    If LEM->( DbSeek( xFilial( "LEM" ) + cChave) )

        cSerie := LEM->LEM_PREFIX

        oModelV3U:LoadValue( "V3U_DTEMIS" , LEM->LEM_DTEMIS )
        oModelV3U:LoadValue( "V3U_NATTIT" , LEM->LEM_NATTIT )

        C1H->( DbSetOrder( 5 ) ) // C1H_FILIAL + C1H_ID
        C1H->( DbSeek( xFilial( "C1H" ) + LEM->LEM_IDPART ) )
        oModelV3U:LoadValue( "V3U_CODPAR", C1H->C1H_CODPAR )
        oModelV3U:LoadValue( "V3U_IDPART", C1H->C1H_ID     )
        oModelV3U:LoadValue( "V3U_DESPAR", C1H->C1H_NOME   )

    Else

        oModelV3U:LoadValue( "V3U_DTEMIS" , Ctod( "" ) )
        oModelV3U:LoadValue( "V3U_NATTIT" , "" )
        oModelV3U:LoadValue( "V3U_CODPAR" , "" )
        oModelV3U:LoadValue( "V3U_IDPART" , "" )
        oModelV3U:LoadValue( "V3U_DESPAR" , "" )
        cSerie := ""

    EndIf

    RestArea( aAreaC1H )
    RestArea( aAreaLEM )

Return cSerie
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV85
Validacao de campo para proteger erro de chave duplicada da V85-Dependentes

@param  
@return lRet
@author  Karen
@since   04/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV85(oMdlDep)

Local lRet 		 as Logical
Local aAreaV85   as Array

lRet 		:= .T.
aAreaV85 	:= V85->( GetArea() )

If !IsBlind()
	dbSelectArea("V85")
	V85->(dbSetOrder(1)) //V85_FILIAL, V85_ID, V85_IDPART, V85_IDNAT, V85_IDTRIB, V85_TPDEDU, V85_CODDEP, R_E_C_N_O_, D_E_L_E_T_

	If oMdlDep:IsInserted() .or. oMdlDep:IsUpdated()
		If Empty(FwFldGet("V85_CODDEP"))
			lRet := .F.
			Help("",1,"Help","Help",STR0044, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0045}) //"O campo código do dependente não pode estar em branco." "Informe um contéudo."
		EndIf
        
		If lRet .and. V85->(DBSeek(xFilial("V85") +  FwFldGet("V3U_ID") + FwFldGet("V3U_IDPART") + FwFldGet("V3V_CNATRE") + FwFldGet("V46_IDTRIB") + FwFldGet("V4I_TPDEDU") + FwFldGet("V85_CODDEP") ) )
			If oMdlDep:GetDataId() != V85->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0046, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0047}) //"O conteúdo preenchido forma uma chave já cadastrada.""Informe outro contéudo."
			EndIf	
		EndIf
	EndIf
	RestArea( aAreaV85 )
endif

Return lRet

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV90
Validacao de campo para proteger erro de chave duplicada da V90 DedSusp

@param  
@return lRet
@author  Denis Souza
@since   08/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV90(oMdlDedS)

Local lRet as Logical
Local aAreaV90 as Array

lRet := .T.
aAreaV90 := V90->( GetArea() )

If !IsBlind()
	dbSelectArea("V90")
	V90->(dbSetOrder(1))
	If oMdlDedS:IsInserted() .or. oMdlDedS:IsUpdated()
		If lRet .and. V90->(DBSeek(xFilial("V90") + FwFldGet("V3U_ID") + FwFldGet("V3V_CNATRE") + FwFldGet("V4H_IDPROC") + FwFldGet("V4H_IDSUSP") + FwFldGet("V4H_IDTRIB") + FwFldGet("V90_TPDEDU") ) )
			If oMdlDedS:GetDataId() != V90->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0052, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0053}) //"O conteúdo preenchido forma uma chave já cadastrada."##"Informe outro contéudo."
			EndIf
		EndIf
	EndIf
	RestArea( aAreaV90 )
endif

Return lRet

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV95
Validacao de campo para proteger erro de chave duplicada da V95

@param  
@return lRet
@author  Denis Souza
@since   29/03/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV95(oMdlDedS)

Local lRet as Logical
Local aAreaV95 as Array

lRet := .T.
aAreaV95 := V95->( GetArea() )

If !IsBlind()
	dbSelectArea("V95")
	V95->(dbSetOrder(1))
	If oMdlDedS:IsInserted() .or. oMdlDedS:IsUpdated()
		If lRet .and. V95->(DBSeek(xFilial("V95") + FwFldGet("V3U_ID") + FwFldGet("V3U_IDPART") + FwFldGet("V3V_CNATRE") + FwFldGet("V4H_IDPROC") + FwFldGet("V4H_IDSUSP") + FwFldGet("V4H_IDTRIB") + FwFldGet("V90_TPDEDU") + FwFldGet("V95_CODDEP") ) )
			If oMdlDedS:GetDataId() != V95->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0052, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0053}) //"O conteúdo preenchido forma uma chave já cadastrada."##"Informe outro contéudo."
			EndIf
		EndIf
	EndIf
	RestArea( aAreaV95 )
endif

Return lRet
