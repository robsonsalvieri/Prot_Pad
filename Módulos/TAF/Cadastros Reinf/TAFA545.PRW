#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA545.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA545
MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0
  
/*/
//-------------------------------------------------------------------

Function TAFA545()  

if ProtData()//Função utilizada para a LGPD

	if TAFAlsInDic("V4Q")
		browsedef()  
	else
		Aviso( STR0001, TafAmbInvMsg(), { STR0003 }, 3 )  // #Aviso , "Ambiente desatualizado para execução desta Rotina. Tabelas: V4Q ... não existem no metadados.", {Encerrar}                                                                                                                                                                                                                                                                                                                                                                                                                 
	endif

endIf

return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//-------------------------------------------------------------------

static function browsedef()

Private oBrowse   as object

//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oBrowse := FWmBrowse():New()

DBSelectArea("V4Q")
DbSetOrder(1)

oBrowse:SetDescription(STR0004)	//"R-4010 - Retenções na Fonte - Pessoa Física"
oBrowse:SetAlias( 'V4Q')
oBrowse:SetMenuDef( 'TAFA545' )	
oBrowse:SetFilterDefault( "V4Q_ATIVO == '1'" )

TAFLegReinf( 'V4Q', oBrowse)

oBrowse:Activate()

return oBrowse

//--------------------------------------------------
/*/{Protheus.doc} modeldef
Model MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------

static function modeldef()
local cInfoPgto  as character 
local cInfoPgtEx as character
local cInfoFisca as character
local cRRAProcJ  as character
local cDespProcJ as character
local oModel     as object
local oStruV4Q   as object
local oStruV4R   as object
local oStruV5E   as object
local oStruV5Ed  as object
local oStruV5Ee  as object
local oStruV5Eg  as object
local oStruV5Eh  as object
local oStruV4T   as object
local oStruV4U   as object
local oStruV4V   as object
local oStruV4X   as object
local oStruV4W   as object
local oStruV4Y   as object
local oStruV4Z   as object
local oStruV5A   as object
local oStruV5B   as object
local oStruV86   as object
local oStruV92   as object
local oStruV93   as object

oModel      := MPFormModel():new("TAFA545")

//--------------------------------------------
// Inicialização variáveis do tipo obejeto 
//--------------------------------------------
oStruV4Q    := FWFormStruct(1,"V4Q") // cabeçalho
oStruV4R    := FWFormStruct(1,"V4R") // idePgto         - Identificação do rendimento
oStruV4T    := FWFormStruct(1,"V4T") // detDed          - O possui na Sociedade em Conta de Participação
oStruV4U    := FWFormStruct(1,"V4U") // detDed/benefPen - Informação dos beneficiários da pensão alimentícia
oStruV4V    := FWFormStruct(1,"V4V") // rendIsento      - Rendimentos isentos ou não tributáveis
oStruV4X    := FWFormStruct(1,"V4X") // infoProcRet     - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oStruV4W    := FWFormStruct(1,"V4W") // ideAdv          - Identificação do advogado
oStruV4Y    := FWFormStruct(1,"V4Y") // ideOpSaude      - Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oStruV4Z    := FWFormStruct(1,"V4Z") // infoReemb       - Informação de reembolso do titular do plano de saúde coletivo empresarial.
oStruV5A    := FWFormStruct(1,"V5A") // infoDependPl    - Informações de dependente do plano de saúde coletivo empresarial.
oStruV5B    := FWFormStruct(1,"V5B") // infoReembDep    - Informação de reembolso do dependente do plano de saúde coletivo empresarial
oStruV86    := FWFormStruct(1,"V86") // infoDepBenef    - Informação do dependente do Beneficiario
oStruV92    := FWFormStruct(1,"V92") // infoProcRet/dedSusp - Detalhamento das deduções 
oStruV93    := FWFormStruct(1,"V93") // dedSusp/benefPen  - Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia.

oModel      := MPFormModel():new("TAFA545")

cInfoPgto	:= "V5E_DATAFG|V5E_COMPFP|V5E_INDDEC|V5E_VLRBRU|V5E_VLRTRI|V5E_VLRIR|V5E_INDRRA|V5E_FCISCP|V5E_NFCISC|V5E_PERSCP|V5E_INDJUD|V5E_PAISRE|V5E_DTESCO|V5E_OBSERV|"
oStruV5E    := FWFormStruct(1,'V5E', {|x| AllTrim( x ) + "|" $ cInfoPgto } ) // infoPgto        - Informações relativas ao pagamento efetuado

cRRAProcJ := 'V5E_TPPROC|V5E_NRPROC|V5E_INDORI|V5E_DESCRI|V5E_QTDMES|V5E_CNPJOR|'  
oStruV5Ed := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cRRAProcJ } )  

cDespProcJ:= 'V5E_VLRDES|V5E_VLRADV|'
oStruV5Ee := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cDespProcJ } )  

cInfoFisca := 'V5E_INDNIF|V5E_NIF|V5E_IDTRIB|V5E_CTRIB|V5E_DTRIB|'
oStruV5Eg := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoFisca } )  

cInfoPgtEx := 'V5E_LOGRAD|V5E_NRLOGR|V5E_COMPLE|V5E_BAIRRO|V5E_CIDADE|V5E_ESTADO|V5E_CEP|V5E_TELEF|'                                                                                                          
oStruV5Eh := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoPgtEx } )     

oModel:addfields('MODEL_V4Q',,oStruV4Q) // cabeçalho  fields
oModel:GetModel('MODEL_V4Q'):SetPrimaryKey({'V4Q_ID'}) 

oModel:addgrid('MODEL_V4R','MODEL_V4Q', oStruV4R) //  idePgto - Identificação do rendimento
oModel:GetModel("MODEL_V4R"):SetUniqueLine({"V4R_NATREN"})
oModel:SetRelation("MODEL_V4R",{ {"V4R_FILIAL","xFilial('V4R')"}, {"V4R_ID","V4Q_ID"},{"V4R_VERSAO","V4Q_VERSAO"} },V4R->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4R' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5Ea','MODEL_V4R',oStruV5E) // infoPgto - Informações relativas ao pagamento efetuado
oModel:GetModel("MODEL_V5Ea"):SetUniqueLine({"V5E_PAISRE","V5E_DATAFG","V5E_INDDEC","V5E_NFCISC"})
oModel:SetRelation("MODEL_V5Ea",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ea' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5Ed','MODEL_V5Ea', oStruV5Ed) //RRA/PROCJUD
oModel:SetRelation("MODEL_V5Ed",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"}, {"V5E_PAISRE","V5E_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ed' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ed' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ee','MODEL_V5Ed', oStruV5Ee) //DespProcJud
oModel:SetRelation("MODEL_V5Ee",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"}, {"V5E_PAISRE","V5E_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ee' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ee' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Eg','MODEL_V5Ea', oStruV5Eg) //InfoPgtoExt
oModel:SetRelation("MODEL_V5Eg",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"}, {"V5E_PAISRE","V5E_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Eg' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Eg' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Eh','MODEL_V5Eg', oStruV5Eh) //EndExt
oModel:SetRelation("MODEL_V5Eh",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"}, {"V5E_PAISRE","V5E_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Eh' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Eh' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V4T','MODEL_V5Ea',oStruV4T) // detDed - O possui na Sociedade em Conta de Participação
oModel:GetModel("MODEL_V4T"):SetUniqueLine({"V4T_TPDEDU"})
oModel:SetRelation("MODEL_V4T",{ {"V4T_FILIAL","xFilial('V4T')"}, {"V4T_ID","V4Q_ID"},{"V4T_VERSAO","V4Q_VERSAO"},{"V4T_NATREN","V4R_NATREN"},{"V4T_PAISRE","V5E_PAISRE"},{"V4T_DATAFG","V5E_DATAFG"},{"V4T_INDDEC","V5E_INDDEC"} },V4T->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4T' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4U','MODEL_V4T',oStruV4U) // benefPen - Informação dos beneficiários da pensão alimentícia 
oModel:GetModel("MODEL_V4U"):SetUniqueLine({"V4U_CPFDEP"})
oModel:SetRelation("MODEL_V4U",{ {"V4U_FILIAL","xFilial('V4U')"}, {"V4U_ID","V4Q_ID"},{"V4U_VERSAO","V4Q_VERSAO"},{"V4U_NATREN","V4R_NATREN"},{"V4U_PAISRE","V5E_PAISRE"},{"V4U_DATAFG","V5E_DATAFG"},{"V4U_INDDEC","V5E_INDDEC"},{"V4U_TPDEDU","V4T_TPDEDU"}},V4U->(IndexKey(1)))
oModel:GetModel('MODEL_V4U' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4V','MODEL_V5Ea',oStruV4V) //rendIsento - Rendimentos isentos ou não tributáveis
oModel:GetModel("MODEL_V4V"):SetUniqueLine({"V4V_TPISEN"})
oModel:SetRelation("MODEL_V4V",{ {"V4V_FILIAL","xFilial('V4V')"}, {"V4V_ID","V4Q_ID"},{"V4V_VERSAO","V4Q_VERSAO"},{"V4V_NATREN","V4R_NATREN"},{"V4V_PAISRE","V5E_PAISRE"},{"V4V_DATAFG","V5E_DATAFG"},{"V4V_INDDEC","V5E_INDDEC"} },V4V->(IndexKey(1)))
oModel:GetModel('MODEL_V4V' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4X','MODEL_V5Ea',oStruV4X) //infoProcRet - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oModel:GetModel("MODEL_V4X"):SetUniqueLine({"V4X_TPPROC","V4X_NRPROC"})
oModel:SetRelation("MODEL_V4X",{ {"V4X_FILIAL","xFilial('V4X')"}, {"V4X_ID","V4Q_ID"},{"V4X_VERSAO","V4Q_VERSAO"},{"V4X_NATREN","V4R_NATREN"},{"V4X_PAISRE","V5E_PAISRE"},{"V4X_DATAFG","V5E_DATAFG"},{"V4X_INDDEC","V5E_INDDEC"}},V4X->(IndexKey(1)))
oModel:GetModel('MODEL_V4X' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V92','MODEL_V4X',oStruV92) // infoProcRet/dedSusp - Detalhamento das deduções 
oModel:GetModel("MODEL_V92"):SetUniqueLine({"V92_TPDEDU"})
oModel:SetRelation("MODEL_V92",{{"V92_FILIAL","xFilial('V92')"},{"V92_ID","V4Q_ID"},{"V92_VERSAO","V4Q_VERSAO"},{"V92_NATREN","V4R_NATREN"},{"V92_PAISRE","V5E_PAISRE"},{"V92_DATAFG","V5E_DATAFG"},{"V92_INDDEC","V5E_INDDEC"},{"V92_TPPROC","V4X_TPPROC"},{"V92_NRPROC","V4X_NRPROC"}},V92->(IndexKey(1)))
oModel:GetModel( 'MODEL_V92' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V93','MODEL_V92',oStruV93) // dedSusp/benefSusp - Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia.
oModel:GetModel("MODEL_V93"):SetUniqueLine({"V93_CPFDEP"})
oModel:SetRelation("MODEL_V93",{{"V93_FILIAL","xFilial('V93')"},{"V93_ID","V4Q_ID"},{"V93_VERSAO","V4Q_VERSAO"},{"V93_NATREN","V4R_NATREN"},{"V93_PAISRE","V5E_PAISRE"},{"V93_DATAFG","V5E_DATAFG"},{"V93_INDDEC","V5E_INDDEC"},{"V93_TPPROC","V4X_TPPROC"},{"V93_NRPROC","V4X_NRPROC"}, {"V93_TPDEDU","V92_TPDEDU"}},V93->(IndexKey(1)))
oModel:GetModel('MODEL_V93' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4W','MODEL_V5Ea',oStruV4W) // ideAdv - Identificação do advogado
oModel:GetModel("MODEL_V4W"):SetUniqueLine({"V4W_TPINSC","V4W_NRINSC"})
oModel:SetRelation("MODEL_V4W",{ {"V4W_FILIAL","xFilial('V4W')"}, {"V4W_ID","V4Q_ID"},{"V4W_VERSAO","V4Q_VERSAO"},{"V4W_NATREN","V4R_NATREN"},{"V4W_PAISRE","V5E_PAISRE"},{"V4W_DATAFG","V5E_DATAFG"},{"V4W_INDDEC","V5E_INDDEC"}},V4W->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4W' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V86','MODEL_V4Q',oStruV86) // infoPgto - Dependentes do Beneficiarios
oModel:GetModel("MODEL_V86"):SetUniqueLine({"V86_CPFDEP"})
oModel:SetRelation("MODEL_V86",{{"V86_FILIAL","xFilial('V86')"},{"V86_ID","V4Q_ID"},{"V86_VERSAO","V4Q_VERSAO"}},V86->(IndexKey(1)))
oModel:GetModel( 'MODEL_V86' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4Y','MODEL_V4Q',oStruV4Y) // ideOpSaude -  Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oModel:GetModel("MODEL_V4Y"):SetUniqueLine({"V4Y_NRINSC"})
oModel:SetRelation("MODEL_V4Y",{ {"V4Y_FILIAL","xFilial('V4Y')"}, {"V4Y_ID","V4Q_ID"},{"V4Y_VERSAO","V4Q_VERSAO"}},V4Y->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4Y' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4Z','MODEL_V4Y',oStruV4Z) // infoReemb - Informação de reembolso do titular do plano de saúde coletivo empresarial
oModel:GetModel("MODEL_V4Z"):SetUniqueLine({"V4Z_TPINSC","V4Z_NRINSC"})
oModel:SetRelation("MODEL_V4Z",{ {"V4Z_FILIAL","xFilial('V4Z')"}, {"V4Z_ID","V4Q_ID"},{"V4Z_VERSAO","V4Q_VERSAO"},{"V4Z_INSC4Y","V4Y_NRINSC"} },V4Z->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4Z' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5A','MODEL_V4Y',oStruV5A) // infoDependPl - Informações de dependente do plano de saúde coletivo empresarial.
oModel:GetModel("MODEL_V5A"):SetUniqueLine({"V5A_CPF"})
oModel:SetRelation("MODEL_V5A",{ {"V5A_FILIAL","xFilial('V5A')"}, {"V5A_ID","V4Q_ID"},{"V5A_VERSAO","V4Q_VERSAO"},{"V5A_NRINSC","V4Y_NRINSC"} },V5A->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5A' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5B','MODEL_V5A',oStruV5B) //infoReembDep - Informação de reembolso do dependente do plano de saúde coletivo empresarial
oModel:GetModel("MODEL_V5B"):SetUniqueLine({"V5B_SEQ"})
oModel:SetRelation("MODEL_V5B",{ {"V5B_FILIAL","xFilial('V5B')"}, {"V5B_ID","V4Q_ID"},{"V5B_VERSAO","V4Q_VERSAO"},{"V5B_INSC4Y","V4Y_NRINSC"},{"V5B_CPF","V5A_CPF"} },V5B->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5B' ):SetOptional( .T. )

return oModel

//--------------------------------------------------
/*/{Protheus.doc} viewdef
View MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira/Katielly Feitosa 		
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------
static function viewdef()
local cCmpFil    as character
local cIdePgto   as character
local cInfoPgtEx as character
local cInfoFisca as character
local cInfoPgto  as character
local cRRAProcJ  as character
local cDespProcJ as character
local oView      as object
local oModel     as object
local oStruV4Q   as object
local oStruV4Qb  as object
local oStruV4R   as object
local oStruV5Eg  as object
local oStruV5Eh  as object
local oStruV5E   as object
local oStruV5Ed  as object
local oStruV5Ee  as object
local oStruV4T   as object
local oStruV4U   as object
local oStruV4V   as object
local oStruV4X   as object
local oStruV4W   as object
local oStruV4Y   as object
local oStruV4Z   as object
local oStruV5A   as object
local oStruV5B   as object
local oStruV86   as object
local oStruV92   as object
local oStruV93   as object

// Inicialização variáveis do tipo obejeto
oView     := FWFormView():new()
oModel    := FWLoadModel('TAFA545')
oStruV4Q  := FwFormStruct(2,"V4Q")   // cabeçalho
oStruV4T  := FwFormStruct(2,"V4T")   // detDed          - O possui na Sociedade em Conta de Participação
oStruV4U  := FwFormStruct(2,"V4U")   // benefPen        - Informação dos beneficiários da pensão alimentícia
oStruV4V  := FwFormStruct(2,"V4V")   // rendIsento      - Rendimentos isentos ou não tributáveis
oStruV4X  := FwFormStruct(2,"V4X")   // infoProcRet     - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oStruV4W  := FwFormStruct(2,"V4W")   // ideAdv          - Identificação do advogado
oStruV4Y  := FwFormStruct(2,"V4Y")   // ideOpSaude      - Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oStruV4Z  := FwFormStruct(2,"V4Z")   // infoReemb       - Informação de reembolso do titular do plano de saúde coletivo empresarial.
oStruV5A  := FwFormStruct(2,"V5A")   // infoDependPl    - Informações de dependente do plano de saúde coletivo empresarial.
oStruV5B  := FwFormStruct(2,"V5B")   // infoReembDep    - Informação de reembolso do dependente do plano de saúde coletivo empresarial
oStruV86  := FwFormStruct(2,"V86")   // infoDepBenef    - Dependentes do Beneficiarios
oStruV92  := FwFormStruct(2,"V92")   // infoProcRet/dedSusp - Detalhamento das deduções 
oStruV93  := FwFormStruct(2,"V93")   // benefPen/dedSusp - Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia.

cCmpFil   := 'V4Q_PROTUL|'
oStruV4Qb := FwFormStruct( 2, 'V4Q', {|x| AllTrim( x ) + "|" $ cCmpFil } )

cIdePgto  := 'V4R_FILIAL|V4R_ID|V4R_VERSAO|V4R_IDNTRE|V4R_DNATRE|V4R_OBSERV|V4R_NATREN|'                                                                                                                                                                                       
oStruV4R  := FwFormStruct( 2, 'V4R', {|x| AllTrim( x ) + "|" $ cIdePgto } )     

cInfoPgto := "V5E_FILIAL|V5E_ID|V5E_VERSAO|V5E_DATAFG|V5E_COMPFP|V5E_INDDEC|V5E_VLRBRU|V5E_VLRTRI|V5E_VLRIR|V5E_INDRRA|V5E_FCISCP|V5E_NFCISC|V5E_PERSCP|V5E_INDJUD|V5E_PAISRE|V5E_DTESCO|V5E_OBSERV|"
oStruV5E  := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoPgto } )    

cRRAProcJ := 'V5E_TPPROC|V5E_NRPROC|V5E_INDORI|V5E_DESCRI|V5E_QTDMES|V5E_CNPJOR|'  
oStruV5Ed := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cRRAProcJ } )  

cDespProcJ:= 'V5E_VLRDES|V5E_VLRADV|'
oStruV5Ee := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cDespProcJ } )   

cInfoFisca:= 'V5E_INDNIF|V5E_NIF|V5E_IDTRIB|V5E_CTRIB|V5E_DTRIB|'
oStruV5Eg := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoFisca } )    

cInfoPgtEx:= 'V5E_LOGRAD|V5E_NRLOGR|V5E_COMPLE|V5E_BAIRRO|V5E_CIDADE|V5E_ESTADO|V5E_CEP|V5E_TELEF|'                                                                                                          
oStruV5Eh := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoPgtEx } )     

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0006 ) // "R-4010"
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_PROTUL', STR0007 ) 

oView:AddField("VIEW_V4Q", oStruV4Q, "MODEL_V4Q" )
oView:EnableTitleView("VIEW_V4Q", STR0004 ) //"R-4010 - Retenções na Fonte - Pessoa Física"
oView:CreateHorizontalBox("PAINEL_SUPERIOR", 30,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V4Q", "PAINEL_SUPERIOR" )   

oView:AddField("VIEW_V4QB", oStruV4Qb, "MODEL_V4Q" )
oView:EnableTitleView("VIEW_V4QB", STR0005) //"Recibo R-4010 - Retenções na Fonte - Pessoa Física"
oView:CreateHorizontalBox("PAINEL_SUPERIORB", 30,,,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V4QB", "PAINEL_SUPERIORB" )   

//INFORMAÇÕES SOBRE A NATUREZA DO RENDIMENTO - NÍVEL 1
oView:CreateHorizontalBox( '1BOXH_IDEBENEF', 70,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_IDEBENEF","1BOXH_IDEBENEF")
oView:AddSheet( 'FOLDER_IDEBENEF', 'SHEET_IDEPGTO', STR0008 ) //"idePgto"

oView:CreateHorizontalBox("BOXH_IDEPGTO",20,,,"FOLDER_IDEBENEF","SHEET_IDEPGTO")
oView:AddGrid("VIEW_V4R", oStruV4R,"MODEL_V4R" )
oView:EnableTitleView("VIEW_V4R", STR0009 )  //"Identificação do rendimento"
oView:SetOwnerView( "VIEW_V4R", "BOXH_IDEPGTO" )

//INFORMAÇÕES REFERENTES AO PAGAMENTO- NÍVEL 2
oView:CreateHorizontalBox( '1BOXH_IDEPGTO', 20,,,"FOLDER_IDEBENEF","SHEET_IDEPGTO")
oView:CreateFolder("FOLDER_IDEPGTO","1BOXH_IDEPGTO")
oView:AddSheet( 'FOLDER_IDEPGTO', 'SHEET_INFOPGTO', STR0028) //"infoPgto"

oView:CreateHorizontalBox( 'BOXH_INFOPGTO', 20,,,"FOLDER_IDEPGTO","SHEET_INFOPGTO")
oView:AddGrid("VIEW_V5E", oStruV5E,"MODEL_V5Ea" )
oView:EnableTitleView("VIEW_V5E", STR0010 ) //"Informações relativas ao pagamento efetuado"
oView:SetOwnerView( "VIEW_V5E", "BOXH_INFOPGTO" )

oView:CreateHorizontalBox( '1BOXH_INFOPGTO', 60,,,"FOLDER_IDEPGTO","SHEET_INFOPGTO")
oView:CreateFolder("FOLDER_INFOPGTO","1BOXH_INFOPGTO")

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_DETDED', STR0011 ) //"detDed"
oView:CreateHorizontalBox( 'BOXH_DETDED', 40,,,"FOLDER_INFOPGTO","SHEET_DETDED" ) 
oView:AddGrid("VIEW_V4T", oStruV4T,"MODEL_V4T" ) 
oView:EnableTitleView("VIEW_V4T", STR0012 ) //"Dedução do Tributo por Natureza de Rendimento"
oView:SetOwnerView( "VIEW_V4T", "BOXH_DETDED" )

oView:CreateHorizontalBox( 'BOX_BENEFPEN', 40,,,"FOLDER_INFOPGTO","SHEET_DETDED" ) 
oView:AddGrid("VIEW_V4U", oStruV4U,"MODEL_V4U" )
oView:EnableTitleView("VIEW_V4U", STR0013 ) //"Informação dos beneficiários da pensão alimentícia"
oView:SetOwnerView( "VIEW_V4U", "BOX_BENEFPEN" )

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_RENDISENTO', STR0014 ) //"rendIsento"
oView:CreateHorizontalBox("BOXH_RENDISENTO",40,,,"FOLDER_INFOPGTO","SHEET_RENDISENTO")
oView:AddGrid("VIEW_V4V", oStruV4V,"MODEL_V4V")
oView:EnableTitleView("VIEW_V4V", STR0015) //"Rendimentos isentos ou não tributáveis"
oView:SetOwnerView( "VIEW_V4V", "BOXH_RENDISENTO" )

oView:AddSheet("FOLDER_INFOPGTO","SHEET_INFOPROCRET",STR0016) //""infoProcRet"
oView:CreateHorizontalBox("BOX_INFOPROCRET",40,,,"FOLDER_INFOPGTO","SHEET_INFOPROCRET")
oView:AddGrid("VIEW_V4X", oStruV4X,"MODEL_V4X")
oView:EnableTitleView("VIEW_V4X",STR0017) //"Informações de processos relacionados a não retenção de tributos ou depósitos judiciais"  
oView:SetOwnerView( "VIEW_V4X", "BOX_INFOPROCRET" )

oView:CreateHorizontalBox("BOX_DETDEDUSUSP",40,,,"FOLDER_INFOPGTO","SHEET_INFOPROCRET")
oView:AddGrid("VIEW_V92", oStruV92,"MODEL_V92")
oView:EnableTitleView("VIEW_V92",STR0044) //STR0044 "Detalhamento das deduções"
oView:SetOwnerView( "VIEW_V92", "BOX_DETDEDUSUSP" )

oView:CreateHorizontalBox("BOX_DEDSUSBENEFPEN",20,,,"FOLDER_INFOPGTO","SHEET_INFOPROCRET")
oView:AddGrid("VIEW_V93", oStruV93,"MODEL_V93")
oView:EnableTitleView("VIEW_V93",STR0046) // "Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia"
oView:SetOwnerView( "VIEW_V93", "BOX_DEDSUSBENEFPEN" )

oView:AddSheet("FOLDER_INFOPGTO","SHEET_RRAPROCJUD", STR0033 ) //"infoRRA/infoProcJud"
oView:CreateHorizontalBox("BOX_RRAPROCJUD",40,,,"FOLDER_INFOPGTO","SHEET_RRAPROCJUD")
oView:AddGrid("VIEW_V5Ed", oStruV5Ed,"MODEL_V5Ed")
oView:EnableTitleView("VIEW_V5Ed", STR0034) //"Informações complemetares relativos a RRA ou Rendimentos decorrentes de Decisão Judicial"
oView:SetOwnerView( "VIEW_V5Ed", "BOX_RRAPROCJUD" )

oView:CreateHorizontalBox( '1BOXH_RRAPROCJUD', 60,,,"FOLDER_INFOPGTO","SHEET_RRAPROCJUD")
oView:CreateFolder("FOLDER_RRAPROCJUD","1BOXH_RRAPROCJUD")

oView:AddSheet( 'FOLDER_RRAPROCJUD', 'SHEET_DESPPROCJU', STR0035  ) //"despProcJud"
oView:CreateHorizontalBox( 'BOXH_DESPPROCJU', 40,,,"FOLDER_RRAPROCJUD","SHEET_DESPPROCJU" )
oView:AddGrid("VIEW_V5Ee", oStruV5Ee, "MODEL_V5Ee" ) 
oView:EnableTitleView("VIEW_V5Ee", STR0036 ) //"Detalhamento das despesas com processo judicial"
oView:SetOwnerView( "VIEW_V5Ee", "BOXH_DESPPROCJU" )

oView:CreateHorizontalBox("BOX_IDEADV",40,,,"FOLDER_RRAPROCJUD","SHEET_DESPPROCJU")
oView:AddGrid("VIEW_V4W", oStruV4W,"MODEL_V4W")
oView:EnableTitleView("VIEW_V4W",STR0019) //"ideAdv - Identificação do advogado"
oView:SetOwnerView( "VIEW_V4W", "BOX_IDEADV" )

//INFORMAÇÕES DE BENEFICIARIOS DO EXTERIOR - NÍVEL 2

oView:AddSheet("FOLDER_INFOPGTO","SHEET_INFOPGTOEX", STR0039 ) //"infoPgtoExt"
oView:CreateHorizontalBox("BOXH_INFOPGTOEX",40,,,"FOLDER_INFOPGTO","SHEET_INFOPGTOEX")
oView:AddGrid("VIEW_V5Eg", oStruV5Eg,"MODEL_V5Eg")
oView:EnableTitleView("VIEW_V5Eg", STR0041) //"informações do pagamento no exterior"
oView:SetOwnerView( "VIEW_V5Eg", "BOXH_INFOPGTOEX" )

oView:CreateHorizontalBox( '1BOXH_ENDEXT', 60,,,"FOLDER_INFOPGTO","SHEET_INFOPGTOEX")
oView:CreateFolder("FOLDER_ENDEXT","1BOXH_ENDEXT")

oView:AddSheet( 'FOLDER_ENDEXT', 'SHEET_INFOPGTOEX', STR0042 ) //"EndExt"
oView:CreateHorizontalBox( 'BOXH_ENDEXT', 40,,,"FOLDER_ENDEXT","SHEET_INFOPGTOEX" )
oView:AddGrid("VIEW_V5Eh", oStruV5Eh, "MODEL_V5Eh" ) 
oView:EnableTitleView("VIEW_V5Eh", STR0040 ) //"Endereço do beneficiário residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V5Eh", "BOXH_ENDEXT" )

//Dependentes do Beneficiario - NÍVEL 1 - V86
oView:AddSheet( 'FOLDER_IDEBENEF', 'SHEET_DEPBENEF', "InfoDepBenefic") 
oView:CreateHorizontalBox( 'BOX_DEPBENEF', 20,,,"FOLDER_IDEBENEF","SHEET_DEPBENEF")//"Dependentes do Beneficiario "

oView:AddGrid("VIEW_V86", oStruV86,"MODEL_V86" )
oView:EnableTitleView("VIEW_V86", "Dependentes do Beneficiario" )
oView:SetOwnerView( "VIEW_V86", "BOX_DEPBENEF" )

//oView:CreateFolder('FOLDER_DEPBENEF','BOX_DEPBENEF')

//PLANO DE SAÚDE E FILHOS - NÍVEL 1
oView:AddSheet( 'FOLDER_IDEBENEF', 'SHEET_IDEOPSAUDE',STR0020)//"ideOpSaude"
oView:CreateHorizontalBox("BOXH_IDEOPSAUDE",20,,,"FOLDER_IDEBENEF","SHEET_IDEOPSAUDE")
oView:AddGrid("VIEW_V4Y", oStruV4Y,"MODEL_V4Y" )
oView:EnableTitleView("VIEW_V4Y",STR0021)  //"Identificação da operadora do plano privado coletivo empresarial de assistência à saúde"
oView:SetOwnerView( "VIEW_V4Y", "BOXH_IDEOPSAUDE" ) 

oView:CreateHorizontalBox( '1BOXH_INFOREEMB', 70,,,"FOLDER_IDEBENEF","SHEET_IDEOPSAUDE")
oView:CreateFolder("FOLDER_INFOREEMB","1BOXH_INFOREEMB")
oView:AddSheet( 'FOLDER_INFOREEMB', 'SHEET_INFOREEMB', STR0022) //"infoReemb"

oView:CreateHorizontalBox("BOXH_INFOREEMB",30,,,"FOLDER_INFOREEMB","SHEET_INFOREEMB")
oView:AddGrid("VIEW_V4Z", oStruV4Z,"MODEL_V4Z" )
oView:EnableTitleView("VIEW_V4Z", STR0023 ) //"Informação de reembolso do titular do plano de saúde coletivo empresarial"
oView:SetOwnerView( "VIEW_V4Z", "BOXH_INFOREEMB" ) 

oView:AddSheet( 'FOLDER_INFOREEMB', 'SHEET_INFODEPENPL', STR0024)  //"infoDependPl"
oView:CreateHorizontalBox("BOXH_INFODEPENPL",30,,,"FOLDER_INFOREEMB","SHEET_INFODEPENPL")
oView:AddGrid("VIEW_V5A", oStruV5A,"MODEL_V5A" )
oView:EnableTitleView("VIEW_V5A", STR0025) // "Informações de dependente do plano de saúde coletivo empresarial." 
oView:SetOwnerView( "VIEW_V5A", "BOXH_INFODEPENPL" ) 

oView:CreateHorizontalBox( '1BOXH_INFOREEMBDEP', 70,,,"FOLDER_INFOREEMB","SHEET_INFODEPENPL")
oView:CreateFolder("FOLDER_INFOREEMBDEP","1BOXH_INFOREEMBDEP")

oView:AddSheet( 'FOLDER_INFOREEMBDEP', 'SHEET_INFOREEMBDEP',STR0026) //"infoReembDep"
oView:CreateHorizontalBox("BOXH_INFOREEMBDEP",30,,,"FOLDER_INFOREEMBDEP","SHEET_INFOREEMBDEP")
oView:AddGrid("VIEW_V5B", oStruV5B,"MODEL_V5B" )
oView:EnableTitleView("VIEW_V5B", STR0027 )  //"Informação de reembolso do dependente do plano de saúde coletivo empresarial"
oView:SetOwnerView( "VIEW_V5B", "BOXH_INFOREEMBDEP" ) 

oStruV4Q:RemoveField("V4Q_PROTUL")
oStruV4Q:RemoveField("V4Q_IDPART")

oStruV4R:RemoveField("V4R_ID"    ) 
oStruV4R:RemoveField("V4R_IDNTRE")

oStruV5B:RemoveField("V5B_SEQ"   )
oStruV5Eg:RemoveField("V5E_IDTRIB")
xFunRmFStr(@oStruV4Q,"V4Q") //Remove campos padrões da tabela espelho

return oView

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------
Static Function MenuDef()

Local aRotina   as array
Local lReinf20  as logical
//--------------------------------------------
// Inicialização variáveis do tipo array
//--------------------------------------------
aRotina := {}
aFuncao := {}
lReinf20 := AllTrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
	aAdd( aFuncao, { "", "TAF545Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V4Q', 'R-4010', 'RetPF', 'TAF545Xml', 5, oBrowse)", "5" } )
	aRotina := TAFMenuReinf( "TAFA545", aFuncao )

	ADD OPTION aRotina Title STR0048 Action 'TAF619Rel' OPERATION 2 ACCESS 0
else
	ADD OPTION aRotina Title STR0047 Action 'VIEWDEF.TAFA545' OPERATION 2 ACCESS 0
EndIf

Return(aRotina) 

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Função com o objetivo de gerar o Evento de Exclusão
@author			Carlos Eduardo
@since			14/10/2022
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	Número do registro
@param			lRotExc	-	Variavel que controla se a function é chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )
Local lRet 		:= .t.
Local lSubModel	:= .f.
Local i 		:= 0
Local J			:= 0
Local oJsonGrv	:= JsonObject():New()
Local cModel	:= ''
Local cVersao	:= ''
Local cField	:= ''
Local xValue	:= nil
Local cType		:= ''
Local cVerAnt	:= ''
Local cRecibo	:= ''

//Transforma dos dados do Model em Json e guarda no objeto para ser usado na nova gravação.
oJsonGrv:FromJson( oModel:GetJSONData(.t.,,.f.,.f.,.t.))

//Posiciono a tabela Pai no registro que esta sendo alterado
DBSelectArea('V4Q')
V4Q->(DBGoTo(nRecno))

//Informações para gravação do rastro
cVerAnt := V4Q->V4Q_VERSAO
cRecibo := V4Q->V4Q_PROTUL

//Gero uma nova versão para o registro que será incluido!
cVersao := xFunGetVer() 

Begin Transaction

	//Seto o registro como Inativo
	FAltRegAnt( 'V4Q', '2' )

	//Operação de inclusão do novo registro
	oModel:DeActivate()
	oModel:SetOperation(3)
	oModel:Activate()
	
	//Grava as informações do Model e Submodel
	for i := 1 to len(oJsonGrv['models'])
		
		//Pega o nome do Model Principal
		cModel := oJsonGrv['models'][i]['id']
		
		//Pega nome e conteudo dos campos que precisam ser gravado e carrega no model
		for j := 1 to len(oJsonGrv['models'][i]['fields'])
			cField := oJsonGrv['models'][i]['fields'][j]['id']
			if x3uso(getSx3Cache(cField,'X3_USADO')) 
				do case //Campos com tratamentos específicos para inclusão do novo registro.
					case '_VERSAO' $ cField
						xValue := cVersao
					case '_VERANT' $ cField
						xValue := cVerAnt
					case '_PROTPN' $ cField
						xValue := cRecibo
					case '_PROTUL' $ cField
						xValue := ''
					case '_EVENTO' $ cField
						xValue	:= 'E'
					case '_ATIVO'  $ cField
						xValue := '1'
					otherwise
						xValue := oJsonGrv['models'][i]['fields'][j]:GetJsonText('value') 
				endcase
				
				if xValue == 'null'; xValue := ''; endif
				cType := oJsonGrv['models'][i]['fields'][j]['datatype'] //Pega o tipo de dado do campo
				//Comverte para o tipo correto de dado
				if cType == 'C'
					xValue := decodeutf8(xValue)
				endif	
				//Carrega o dado no model
				lRet := oModel:LoadValue( cModel, cField , xValue )	

			endif	
		next

		//Verifica se existem submodels para serem gravados
		lSubModel := aScan( oJsonGrv['models'][i]:GetNames(), {|x| x == 'models'}) > 0
		if lSubModel
			//Faz a chamada da função de gravação dos submodes caso seja necessário
			for j := 1 to len(oJsonGrv['models'][i]['models'])
				GrvSubMdl(oModel, oJsonGrv['models'][i]['models'][j] )
			next
		endif		

		//Commita o novo registro
		FWFormCommit( oModel )
		TAFAltStat( 'V4Q', '6' ) 

	next	

end Transaction

return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF545Xml
Retorna o Xml do Registro Posicionado 
	
@author Rafael de Paula Leme		
@since 13/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF545Xml(cAlias, nRecno, nOpc, lJob)
	Local cXml    	as char
	Local cLayout 	as char
	Local cReg    	as char
	Local cPeriodo	as char
	Local cNumDoc	as char
	Local cNameXSD  as char
	Local lReinf212 as logical


	Default lJob 	:= .F.
	Default cAlias 	:= "V4Q"
	Default nRecno	:= 1
	Default nOpc	:= 1

	If lJob .And. nRecno > 0
		DBSelectArea( "V4Q" )
		V4Q->( DBSetOrder( 1 ) )
		V4Q->( DBGoTo( nRecno ) )
	EndIf

	DBSelectArea( "V86" )
	V86->( DBSetOrder( 1 ) )

	DBSelectArea( "V92" )
	V92->( DBSetOrder( 1 ) )

	DBSelectArea( "V93" )
	V93->( DBSetOrder( 1 ) )

	DBSelectArea( "V4R" )
	V4R->( DBSetOrder( 1 ) )

	DBSelectArea( "V4T" )
	V4T->( DBSetOrder( 1 ) )

	DBSelectArea( "V4U" )
	V4U->( DBSetOrder( 1 ) )

	DBSelectArea( "V4V" )
	V4V->( DBSetOrder( 1 ) )

	DBSelectArea( "V4W" )
	V4W->( DBSetOrder( 1 ) )

	DBSelectArea( "V4X" )
	V4X->( DBSetOrder( 1 ) )

	DBSelectArea( "V4Y" )
	V4Y->( DBSetOrder( 1 ) )

	DBSelectArea( "V4Z" )
	V4Z->( DBSetOrder( 1 ) )

	DBSelectArea( "V5A" )
	V5A->( DBSetOrder( 1 ) )

	DBSelectArea( "V5B" )
	V5B->( DBSetOrder( 1 ) )

	cLayout 	:= "4010"
	cXml    	:= ""
	cReg    	:= "RetPF" 
	cPeriodo	:= Substr(V4Q->V4Q_PERAPU,3) + "-" + Substr(V4Q->V4Q_PERAPU,1,2) 
	cNumDoc		:= ""
	cNameXSD	:= '4010PagtoBeneficiarioPF'
	lReinf212  := TAFColumnPos( "V4Q_EVADIC" )

	cXml +=		"<ideEstab>"	
	cXml +=			xTafTag("tpInscEstab", V4Q->V4Q_TPINSC)
	cXml +=			xTafTag("nrInscEstab", V4Q->V4Q_NRINSC)
	cXml +=			"<ideBenef>"
	cXml +=				xTafTag("cpfBenef", V4Q->V4Q_CPF,,.T.)

	If Empty(V4Q->V4Q_CPF)
		cXml +=				xTafTag("nmBenef" , V4Q->V4Q_NOME)
	Endif
	If lReinf212
		cXml +=				xTafTag("ideEvtAdic" , V4Q->V4Q_EVADIC,,.T.)
	EndIf
	
	If V86->( MsSeek( xFilial( "V86" ) + V4Q->( V4Q_ID + V4Q_VERSAO) ) )
		While V86->(!Eof()) .And. V86->( V86_FILIAL + V86_ID + V86_VERSAO) == V4Q->( V4Q_FILIAL + V4Q_ID + V4Q_VERSAO)	
			
			cXml +=		"<ideDep>"
			cXml +=			xTafTag("cpfDep"  , V86->V86_CPFDEP)
			cXml +=			xTafTag("relDep"  , V86->V86_RELDEP)
			cXml +=			xTafTag("descrDep", V86->V86_DSCOUT,,.T.)
			cXml +=		"</ideDep>"
			
			V86->( DbSkip() )
		EndDo
	EndIf

	If V4R->( MsSeek( xFilial( "V4R" ) + V4Q->( V4Q_ID + V4Q_VERSAO) ) )
		While V4R->(!Eof()) .And. V4R->( V4R_FILIAL + V4R_ID + V4R_VERSAO) == V4Q->( V4Q_FILIAL + V4Q_ID + V4Q_VERSAO)

			cXml +=		"<idePgto>"
			cXml +=			xTafTag("natRend", V4R->V4R_NATREN)
			cXml +=			xTafTag("observ" , V4R->V4R_OBSERV,,.T.)

			If V5E->( MsSeek( xFilial( "V5E" ) + V4R->( V4R_ID + V4R_VERSAO + V4R_NATREN) ) )
				While V5E->(!Eof()) .And. V5E->( V5E_FILIAL + V5E_ID + V5E_VERSAO + V5E_NATREN) == V4R->( V4R_FILIAL + V4R_ID + V4R_VERSAO + V4R_NATREN )
					
					cXml += "<infoPgto>"
					
					cXml +=		xTafTag("dtFG", Substr(DTOS(V5E->V5E_DATAFG),1,4) + '-' + Substr(DTOS(V5E->V5E_DATAFG),5,2)+ '-' + Substr(DTOS(V5E->V5E_DATAFG),7,2))
					
					If !Empty(V5E->V5E_COMPFP)
						If AllTrim(V5E->V5E_INDDEC) == '1'
							cXml += xTafTag("compFP", Substr(V5E->V5E_COMPFP,1,4))
						Else
							cXml += xTafTag("compFP", Substr(V5E->V5E_COMPFP,1,4) + '-' + Substr(V5E->V5E_COMPFP,5,2))
						EndIf
					EndIf

					If AllTrim(V5E->V5E_INDDEC) == '1'
						cXml +=	xTafTag("indDecTerc", "S")
					EndIf

					cXml +=		xTafTag("vlrRendBruto", StrTran(Alltrim((TRANSFORM(V5E->V5E_VLRBRU, "@E 9,999,999,999,999.99"))),"." ,""))

					If V5E->V5E_VLRTRI > 0
						cXml +=	xTafTag("vlrRendTrib", StrTran(Alltrim((TRANSFORM(V5E->V5E_VLRTRI, "@E 9,999,999,999,999.99"))),"." ,""))
					EndIf

					If V5E->V5E_VLRIR > 0
						cXml +=	xTafTag("vlrIR", StrTran(Alltrim((TRANSFORM(V5E->V5E_VLRIR, "@E 9,999,999,999,999.99"))),"." ,""))
					EndIf

					If AllTrim(V5E->V5E_INDRRA) == '1' .AND. AllTrim(V5E->V5E_INDJUD) <> '1'
						cXml +=	xTafTag("indRRA", "S")
					EndIf

					If AllTrim(V5E->V5E_FCISCP) $ '1|2'
						cXml +=	xTafTag("indFciScp", V5E->V5E_FCISCP)
						cXml +=	xTafTag("nrInscFciScp", V5E->V5E_NFCISC)
					EndIf

					If AllTrim(V5E->V5E_FCISCP) == '2'
						cXml +=	xTafTag("percSCP",V5E->V5E_PERSCP,"@E 999.9",.T.,.F.,.F.)
					EndIf

					If	AllTrim(V5E->V5E_INDJUD) $ '1|2'
						If AllTrim(V5E->V5E_INDJUD) == '1'
							cXml +=	xTafTag("indJud", "S")
						Else
							cXml +=	xTafTag("indJud", "N")
						EndIf
					EndIf

					If !Empty(V5E->V5E_PAISRE)
						cXml +=	xTafTag("paisResidExt", V5E->V5E_PAISRE)
					EndIf
					If lReinf212 
						If V4R->V4R_NATREN == "12052" .and. !Empty(V5E->V5E_DTESCO)
							cXml +=	xTafTag("dtEscrCont", Substr(DTOS(V5E->V5E_DTESCO),1,4) + '-' + Substr(DTOS(V5E->V5E_DTESCO),5,2)+ '-' + Substr(DTOS(V5E->V5E_DTESCO),7,2))
						EndIf	
						cXml +=	xTafTag("observ", V5E->V5E_OBSERV,,.T.)
					EndIf

					If  Empty(V5E->V5E_PAISRE) .And. V4T->( MsSeek( xFilial( "V4T" ) + V5E->( V5E_ID + V5E_VERSAO + V5E_NATREN + V5E_PAISRE + DTOS(V5E_DATAFG) + V5E_INDDEC ) ) )
						While V4T->(!Eof()) .And. V4T->( V4T_ID+V4T_VERSAO+V4T_NATREN+V4T_PAISRE+DTOS(V4T_DATAFG)+V4T_INDDEC) == V5E->( V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC )

							cXml += 	"<detDed>"
							cXml +=			xTafTag("indTpDeducao", V4T->V4T_TPDEDU)
							cXml +=			xTafTag("vlrDeducao"  , StrTran(Alltrim((TRANSFORM(V4T->V4T_VLRDED, "@E 9,999,999,999,999.99"))),"." ,""))
							
							If AllTrim(V4T->V4T_TPDEDU) $ '2|3|4'
								cXml +=			xTafTag("infoEntid"   , Iif(V4T->V4T_IENTID=="1", "S","N"))
							EndIf	
							
							If AllTrim(V4T->V4T_IENTID) == '1'
								cXml +=		xTafTag("nrInscPrevComp", V4T->V4T_NRPVCM)
							EndIf

							If AllTrim(V4T->V4T_TPDEDU) == '4'
								If V4T->V4T_VLFPRE > 0
									xTafTag("vlrPatrocFunp"  , StrTran(Alltrim((TRANSFORM(V4T->V4T_VLFPRE, "@E 9,999,999,999,999.99"))),"." ,""))
								EndIF
							EndIf

							If AllTrim(V4T->V4T_TPDEDU) $ '5|7' .And. V4U->( MsSeek( xFilial( "V4U" ) + V4T->( V4T_ID+V4T_VERSAO+V4T_NATREN+V4T_PAISRE+DTOS(V4T_DATAFG)+V4T_INDDEC+V4T_TPDEDU ) ) )
								While V4U->(!Eof()) .And. V4U->( V4U_ID+V4U_VERSAO+V4U_NATREN+V4U_PAISRE+DTOS(V4U_DATAFG)+V4U_INDDEC+V4U_TPDEDU) == V4T->( V4T_ID+V4T_VERSAO+V4T_NATREN+V4T_PAISRE+DTOS(V4T_DATAFG)+V4T_INDDEC+V4T_TPDEDU )
									cXml += "<benefPen>"
									cXml +=		xTafTag("cpfDep", V4U->V4U_CPFDEP)
									cXml +=		xTafTag("vlrDepen"  , StrTran(Alltrim((TRANSFORM(V4U->V4U_VALDED, "@E 9,999,999,999,999.99"))),"." ,""))
									cXml += "</benefPen>"

									V4U->( DbSkip() )
								EndDo
							EndIf

							cXml += 	"</detDed>"

							V4T->( DbSkip() )
						EndDo
					Endif

					If Empty(V5E->V5E_PAISRE) .And. V4V->( MsSeek( xFilial( "V4V" ) + V5E->(  V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC ) ) )
						While V4V->(!Eof()) .And. V4V->( V4V_ID+V4V_VERSAO+V4V_NATREN+V4V_PAISRE+DTOS(V4V_DATAFG)+V4V_INDDEC) == V5E->( V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC )
							
							cXml += 	"<rendIsento>"
							cXml +=			xTafTag("tpIsencao", V4V->V4V_TPISEN)
							cXml +=			xTafTag("vlrIsento"  , StrTran(Alltrim((TRANSFORM(V4V->V4V_VLRISE, "@E 9,999,999,999,999.99"))),"." ,""))
							
							If AllTrim(V4V->V4V_TPISEN) == '99'
								cXml +=		xTafTag("descRendimento", V4V->V4V_DESREN)
							EndIf
							
							If AllTrim(V4V->V4V_TPISEN) == '6'
								cXml +=		xTafTag("dtLaudo", V4V->V4V_DTLAUD)
							EndIf

							cXml += 	"</rendIsento>"

							V4V->( DbSkip() )
						EndDo
					EndIf

					If V4X->( MsSeek( xFilial( "V4X" ) + V5E->(  V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC ) ) )
						While V4X->(!Eof()) .And. V4X->( V4X_ID+V4X_VERSAO+V4X_NATREN+V4X_PAISRE+DTOS(V4X_DATAFG)+V4X_INDDEC) == V5E->( V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC )

							cXml += 	"<infoProcRet>"

							cXml +=			xTafTag("tpProcRet"   , V4X->V4X_TPPROC)
							cXml +=			xTafTag("nrProcRet"   , V4X->V4X_NRPROC)
							cXml +=			xTafTag("codSusp"     , V4X->V4X_CODSUS,,.T.)

							If V4X->V4X_VLRETI > 0
								cXml +=		xTafTag("vlrNRetido"  , StrTran(Alltrim((TRANSFORM(V4X->V4X_VLRETI, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf

							If V4X->V4X_VLRDEP > 0
								cXml +=		xTafTag("vlrDepJud"   , StrTran(Alltrim((TRANSFORM(V4X->V4X_VLRDEP, "@E 9,999,999,999,999.99"))),"." ,""))
							Endif

							If V4X->V4X_VLRANO > 0
								cXml +=		xTafTag("vlrCmpAnoCal", StrTran(Alltrim((TRANSFORM(V4X->V4X_VLRANO, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf

							If V4X->V4X_VLRANA > 0
								cXml +=		xTafTag("vlrCmpAnoAnt", StrTran(Alltrim((TRANSFORM(V4X->V4X_VLRANA, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf

							If V4X->V4X_VLRSUS > 0
								cXml +=		xTafTag("vlrRendSusp" , StrTran(Alltrim((TRANSFORM(V4X->V4X_VLRSUS, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf

							If V92->( MsSeek( xFilial( "V92" ) + V4X->(  V4X_ID+V4X_VERSAO+V4X_NATREN+V4X_PAISRE+DTOS(V4X_DATAFG)+V4X_INDDEC+V4X_TPPROC+V4X_NRPROC  ) ) )
								While V92->(!Eof()) .And. V92->( V92_ID+V92_VERSAO+V92_NATREN+V92_PAISRE+DTOS(V92_DATAFG)+V92_INDDEC+V92_TPPROC+V92_NRPROC) == V4X->( V4X_ID+V4X_VERSAO+V4X_NATREN+V4X_PAISRE+DTOS(V4X_DATAFG)+V4X_INDDEC+V4X_TPPROC+V4X_NRPROC )	

									cXml += 	"<dedSusp>"
									cXml +=			xTafTag("indTpDeducao", V92->V92_TPDEDU)
									If V4X->V4X_VLRSUS > 0
										If V92->V92_VDEDSU > 0
											cXml +=		xTafTag("vlrDedSusp"  , StrTran(Alltrim((TRANSFORM(V92->V92_VDEDSU, "@E 9,999,999,999,999.99"))),"." ,""))
										EndIf
									Endif

									If AllTrim(V92->V92_TPDEDU) $ '5|7' .And. V93->( MsSeek( xFilial( "V93" ) +V92->( V92_ID+V92_VERSAO+V92_NATREN+V92_PAISRE+DTOS(V92_DATAFG)+V92_INDDEC+V92_TPPROC+V92_NRPROC+V92_TPDEDU ) ) )
										While V93->(!Eof()) .And. V93->( V93_ID+V93_VERSAO+V93_NATREN+V93_PAISRE+DTOS(V93_DATAFG)+V93_INDDEC+V93_TPPROC+V93_NRPROC+V93_TPDEDU) == V92->( V92_ID+V92_VERSAO+V92_NATREN+V92_PAISRE+DTOS(V92_DATAFG)+V92_INDDEC+V92_TPPROC+V92_NRPROC+V92_TPDEDU )	

											cXml += "<benefPen>"
											cXml +=		xTafTag("cpfDep"      , V93->V93_CPFDEP)
											cXml +=		xTafTag("vlrDepenSusp", StrTran(Alltrim((TRANSFORM(V93->V93_VDEPSU, "@E 9,999,999,999,999.99"))),"." ,""))
											cXml += "</benefPen>"

											V93->( DbSkip() )
										EndDo
									EndIf

									cXml += 	"</dedSusp>"

									V92->( DbSkip() )
								EndDo
							EndIf

							cXml += 	"</infoProcRet>"

							V4X->( DbSkip() )
						EndDo
					EndIf

					If AllTrim(V5E->V5E_INDRRA) == '1'
						
						cXml += "<infoRRA>"
						cXml +=		xTafTag("tpProcRRA"      , V5E->V5E_TPPROC)
						if V5E->V5E_TPPROC == '2'
							cXml +=		xTafTag("nrProcRRA"      , V5E->V5E_NRPROC,,.T.)
						EndIf
						cXml +=		xTafTag("indOrigRec"     , V5E->V5E_INDORI)
						cXml +=		xTafTag("descRRA"        , V5E->V5E_DESCRI,,.T.)
						cXml +=		xTafTag("qtdMesesRRA"	 , V5E->V5E_QTDMES,"@E 999.9",.F.,.F.,.T.)
						
						
						If AllTrim(V5E->V5E_INDORI) == '2'							
							cXml +=	xTafTag("cnpjOrigRecurso", V5E->V5E_CNPJOR,,.T.)
						Endif
						
						If V5E->V5E_VLRDES + V5E->V5E_VLRADV > 0
							cXml += 	"<despProcJud>"
							cXml +=			xTafTag("vlrDespCustas"  , V5E->V5E_VLRDES,"@E 9,999,999,999,999.99",.F.,.F.,.T.,,.T.)
							cXml +=			xTafTag("vlrDespAdvogados"  , V5E->V5E_VLRADV,"@E 9,999,999,999,999.99",.F.,.F.,.T.,,.T.)

							If V4W->( MsSeek( xFilial( "V4W" ) + V5E->(  V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC ) ) )
								While V4W->(!Eof()) .And. V4W->( V4W_ID+V4W_VERSAO+V4W_NATREN+V4W_PAISRE+DTOS(V4W_DATAFG)+V4W_INDDEC) == V5E->( V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC )
									
									cXml+=	"<ideAdv>"
									cXml +=		xTafTag("tpInscAdv", IIf(V4W->V4W_TPINSC == '1','2','1'))
									cXml +=		xTafTag("nrInscAdv", V4W->V4W_NRINSC)
									If V4W->V4W_VLRADV > 0
										cXml +=     xTafTag("vlrAdv"   , V4W->V4W_VLRADV, "@E 9,999,999,999,999.99",.T.,.F.,.F.,,.T.)
									EndIf
									cXml+=	"</ideAdv>"

									V4W->( DbSkip() )
								EndDo
							EndIf

							cXml += 	"</despProcJud>"
						EndIf
						cXml += "</infoRRA>"
					EndIf

					If AllTrim(V5E->V5E_INDJUD) == '1'
						
						cXml +=	"<infoProcJud>"
						cXml +=		xTafTag("nrProc"         , V5E->V5E_NRPROC)
						cXml +=		xTafTag("indOrigRec"     , V5E->V5E_INDORI)
						If AllTrim(V5E->V5E_INDORI) == '2'
							cXml +=	xTafTag("cnpjOrigRecurso", V5E->V5E_CNPJOR,,.T.)
						Endif
						cXml +=		xTafTag("desc"           , V5E->V5E_DESCRI,,.T.)

						If V5E->V5E_VLRDES + V5E->V5E_VLRADV > 0
							cXml +=		"<despProcJud>"
							cXml +=			xTafTag("vlrDespCustas"  , V5E->V5E_VLRDES,"@E 9,999,999,999,999.99",.F.,.F.,.T.,,.T.)
							cXml +=			xTafTag("vlrDespAdvogados"  , V5E->V5E_VLRADV,"@E 9,999,999,999,999.99",.F.,.F.,.T.,,.T.)
							
							If V4W->( MsSeek( xFilial( "V4W" ) + V5E->(  V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC ) ) )
								While V4W->(!Eof()) .And. V4W->( V4W_ID+V4W_VERSAO+V4W_NATREN+V4W_PAISRE+DTOS(V4W_DATAFG)+V4W_INDDEC) == V5E->( V5E_ID+V5E_VERSAO+V5E_NATREN+V5E_PAISRE+DTOS(V5E_DATAFG)+V5E_INDDEC )
									
									cXml +=	"<ideAdv>"
									cXml +=		xTafTag("tpInscAdv", IIF(V4W->V4W_TPINSC == '1','2','1'))
									cXml +=		xTafTag("nrInscAdv", V4W->V4W_NRINSC)	
									If V4W->V4W_VLRADV > 0
										cXml +=		xTafTag("vlrAdv"   , V4W->V4W_VLRADV, "@E 9,999,999,999,999.99",.T.,.F.,.F.,,.T.)
									EndIf
									cXml +=	"</ideAdv>"
									
									V4W->( DbSkip() )
								EndDo
							EndIf

							cXml +=		"</despProcJud>"
						EndIf
						cXml +=	"</infoProcJud>"
					EndIf

					If !Empty(V5E->V5E_PAISRE)
						cXml +=	"<infoPgtoExt>"
						cXml +=		xTafTag("indNIF"   , V5E->V5E_INDNIF)
						cXml +=		xTafTag("nifBenef" , V5E->V5E_NIF,,.T.)
						cXml +=		xTafTag("frmTribut", V5E->V5E_CTRIB)

						If !Empty(V5E->V5E_LOGRAD) .Or. !Empty(V5E->V5E_NRLOGR) .Or. !Empty(V5E->V5E_COMPLE) .Or. !Empty(V5E->V5E_BAIRRO) ;
							.Or. !Empty(V5E->V5E_CIDADE) .Or. !Empty(V5E->V5E_ESTADO) .Or. !Empty(V5E->V5E_CEP) .Or. !Empty(V5E->V5E_TELEF)
							cXml +=		"<endExt>"
							cXml +=			xTafTag("dscLograd", V5E->V5E_LOGRAD,,.T.)
							cXml +=			xTafTag("nrLograd" , V5E->V5E_NRLOGR,,.T.)
							cXml +=			xTafTag("complem"  , V5E->V5E_COMPLE,,.T.)
							cXml +=			xTafTag("bairro"   , V5E->V5E_BAIRRO,,.T.)
							cXml +=			xTafTag("cidade"   , V5E->V5E_CIDADE,,.T.)
							cXml +=			xTafTag("estado"   , V5E->V5E_ESTADO,,.T.)
							cXml +=			xTafTag("codPostal", V5E->V5E_CEP,,.T.)
							cXml +=			xTafTag("telef"    , V5E->V5E_TELEF,,.T.)
							cXml +=		"</endExt>"
						EndIf
						cXml +=	"</infoPgtoExt>"
					EndIf

					cXml +=	"</infoPgto>"

					V5E->( DbSkip() )
				EndDo
			Else
				cXml +=	"<infoPgto></infoPgto>"
			EndIf

			cXml +=	"</idePgto>"

			V4R->( DbSkip() )
		EndDo
	EndIf

	If V4Y->( MsSeek( xFilial( "V4Y" ) + V4Q->( V4Q_ID + V4Q_VERSAO) ) )
		While V4Y->(!Eof()) .And. V4Y->( V4Y_FILIAL + V4Y_ID + V4Y_VERSAO) == V4Q->( V4Q_FILIAL + V4Q_ID + V4Q_VERSAO)	

			cXml +=			"<ideOpSaude>"
			cXml +=				xTafTag("nrInsc"  , V4Y->V4Y_NRINSC)
			cXml +=				xTafTag("regANS"  , V4Y->V4Y_REGANS,,.T.)
			cXml +=				xTafTag("vlrSaude", StrTran(Alltrim((TRANSFORM(V4Y->V4Y_VLRPAG, "@E 9,999,999,999,999.99"))),"." ,""))

			If V4Z->( MsSeek( xFilial( "V4Z" ) + V4Y->( V4Y_ID + V4Y_VERSAO + V4Y_NRINSC) ) )
				While V4Z->(!Eof()) .And. V4Z->(V4Z_FILIAL + V4Z_ID + V4Z_VERSAO + V4Z_INSC4Y) == V4Y->(V4Y_FILIAL + V4Y_ID + V4Y_VERSAO + V4Y_NRINSC)
					cXml +=		"<infoReemb>"
					cXml +=			xTafTag("tpInsc"     , V4Z->V4Z_TPINSC)
					cXml +=			xTafTag("nrInsc"     , V4Z->V4Z_NRINSC)
					If V4Z->V4Z_VLRREE > 0
						cXml +=			xTafTag("vlrReemb"   , StrTran(Alltrim((TRANSFORM(V4Z->V4Z_VLRREE, "@E 9,999,999,999,999.99"))),"." ,""))
					EndIf
					If V4Z->V4Z_VLRANT > 0
						cXml +=			xTafTag("vlrReembAnt", StrTran(Alltrim((TRANSFORM(V4Z->V4Z_VLRANT, "@E 9,999,999,999,999.99"))),"." ,""))
					EndIf
					cXml +=		"</infoReemb>"
					
					V4Z->( DbSkip() )
				EndDo
			EndIf

			If V5A->( MsSeek( xFilial( "V5A" ) + V4Y->( V4Y_ID + V4Y_VERSAO + V4Y_NRINSC) ) )
				While V5A->(!Eof()) .And. V5A->(V5A_FILIAL + V5A_ID + V5A_VERSAO + V5A_NRINSC) == V4Y->(V4Y_FILIAL + V4Y_ID + V4Y_VERSAO + V4Y_NRINSC)	
					
					cXml +=		"<infoDependPl>"
					cXml +=			xTafTag("cpfDep"  , V5A->V5A_CPF)
					cXml +=			xTafTag("vlrSaude", StrTran(Alltrim((TRANSFORM(V5A->V5A_VALOR, "@E 9,999,999,999,999.99"))),"." ,""))
					
					If V5B->( MsSeek( xFilial( "V5B" ) + V5A->( V5A_ID + V5A_VERSAO + V5A_NRINSC + V5A_CPF) ) )
						While V5B->(!Eof()) .And. V5B->( V5B_FILIAL + V5B_ID + V5B_VERSAO + V5B_INSC4Y + V5B_CPF) == V5A->( V5A_FILIAL + V5A_ID + V5A_VERSAO + V5A_NRINSC + V5A_CPF)
						
							cXml +=	"<infoReembDep>"
							cXml +=		xTafTag("tpInsc"     , V5B->V5B_TPINSC)
							cXml +=		xTafTag("nrInsc"     , V5B->V5B_NRINSC)
							If V5B->V5B_VLRREE > 0
								cXml +=		xTafTag("vlrReemb"   , StrTran(Alltrim((TRANSFORM(V5B->V5B_VLRREE, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf
							If V5B->V5B_VLRANT > 0
								cXml +=		xTafTag("vlrReembAnt", StrTran(Alltrim((TRANSFORM(V5B->V5B_VLRANT, "@E 9,999,999,999,999.99"))),"." ,""))
							EndIf
							cXml +=	"</infoReembDep>"

							V5B->( DbSkip() )
						EndDo
					EndIf

					cXml +=		"</infoDependPl>"

					V5A->( DbSkip() )
				EndDo
			EndIf

			cXml +=			"</ideOpSaude>"
				
			V4Y->( DbSkip() )
		EndDo
	EndIf

	cXml +=		"</ideBenef>"
	cXml +=	"</ideEstab>"

	V86->( DBCloseArea( ) )
	V92->( DBCloseArea( ) )
	V93->( DBCloseArea( ) )
	V4R->( DBCloseArea( ) )
	V4T->( DBCloseArea( ) )
	V4U->( DBCloseArea( ) )
	V4V->( DBCloseArea( ) )
	V4W->( DBCloseArea( ) )
	V4X->( DBCloseArea( ) )
	V4Y->( DBCloseArea( ) )
	V4Z->( DBCloseArea( ) )
	V5A->( DBCloseArea( ) )
	V5B->( DBCloseArea( ) )

	// Estrutura do Cabeçalho
	cXml := TAFXmlReinf( cXml, "V4Q", cLayout, cReg, cPeriodo,, cNameXSD)

	// Executa gravacao do registro
	If !lJob
		xTafGerXml(cXml,cLayout,,,,,,"R-" )
	EndIf

	If lJob .And. nRecno > 0
		V4Q->( DBCloseArea( ) )
	EndIf

Return(cXml)
