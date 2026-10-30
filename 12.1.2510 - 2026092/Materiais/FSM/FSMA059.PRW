#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMGRUPATEND source FSMA059 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOT - Grupo de Atendimento
@author raphael.canduria
@since 23/07/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruJOT := FWFormStruct(1,"JOT")
Local oStruJOU := FWFormStruct(1, "JOU")
Local oCommit  := Fsm059Comm():New()

oStruJOU:AddField(;
    "Nome Atendente",;              // Titulo
    "Nome do Atendente",;           // Tooltip
    "JOU_NOMTEC",;                  // Id do Field Virtual
    "C",;                           // Tipo
    TamSx3('AA1_NOMTEC')[1],;       // Tamanho baseado na AA1
    0,;                             // Decimal
    {|| .T.},;                      // Valid Usuário
    {|| .T.},;                      // Valid Sistema
    {},;                            // Combo
    .F.,;                           // Obrigatorio
    /*bInit*/,;                     // Init Padrão
    .F.,;                           // Chave
    .F.,;                           // Altera
    .T. ;                           // Virtual
)	

oModel := MPFormModel():New('FSMA059', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOTMASTER',/*cOwner*/,oStruJOT)
oModel:AddGrid('JOUDETAIL', 'JOTMASTER', oStruJOU, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

oModel:SetRelation('JOUDETAIL', {;
    {'JOU_FILIAL', 'xFilial("JOU")'},;
    {'JOU_CODJOT', 'JOT_CODIGO'};
}, JOU->(IndexKey(1)))

oStruJOU:SetProperty("JOU_NOMTEC", MODEL_FIELD_INIT, ;
    FwBuildFeature(STRUCT_FEATURE_INIPAD, ;
    'If(!INCLUI, Posicione("AA1", 1, xFilial("AA1") + JOU->JOU_CODAA1, "AA1_NOMTEC"), "")'))



oModel:SetDescription('Grupo de Atendimento - SIGAFSM')
oModel:GetModel('JOTMASTER'):SetDescription("Grupo de Atendimento - SIGAFSM")
oModel:GetModel('JOUDETAIL'):SetDescription("Tecnicos do Grupo - SIGAFSM")

oModel:GetModel('JOUDETAIL'):SetOptional(.T.)
oModel:SetPrimaryKey({"JOT_CODIGO"})


oModel:InstallEvent("FSM059COMM", /*cOwner*/, oCommit)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsm059Commit
Classe de Eventos do Modelo FSMA059
/*/
//-------------------------------------------------------------------
Class Fsm059Comm FROM FwModelEvent
    Method New()
    Method BeforeTTS(oModel, cModelId)
End Class

Method New() Class Fsm059Comm
Return Self

Method BeforeTTS(oModel, cModelId) Class Fsm059Comm
    Local nOperation := oModel:GetOperation()


    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE        
        
        oModel:SetValue('JOTMASTER', 'JOT_QTDTEC', oModel:GetModel("JOUDETAIL"):Length(.T.))

    EndIf

Return .T.

