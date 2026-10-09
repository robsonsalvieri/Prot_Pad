#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJACADCLI.CH'

Static nAutPCNPJ   := 1
Static nAutPCEP    := 1
Static lDominios   := .T.
Static nOpcao
Static cDB         := TcGetDB()

/*/{Protheus.doc} LOJACADCLI
Tela para cadastro de clientes para varejo, gerando o código A1_COD com base do CPF/CNPJ
@author joao.marcos
@since 10/11/2023
@version V12
/*/
Function LOJACADCLI()
Local oBrowse

Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SA1')
oBrowse:SetDescription(STR0030) // "Cadastro de Clientes Simplificado do Varejo"
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} LJCADCLI
Faz a chamada da tela de cadastro de Cliente
@type  Function
@author joao.marcos
@since 27/11/2023
@version V12
@param  nOp, Numeric, Opcao Inclusao/ Alteracao
        nSA1Recno, Caracter, RECNO do registro na SA1
/*/
Function LJCADCLI(nOp, nSA1Recno)
Local nRet := 0

Default nOp := MODEL_OPERATION_INSERT

GetProfile(.F.)

nOpcao := nOp

If nOp == MODEL_OPERATION_INSERT
    nRet := FWExecView(STR0015,'LOJACADCLI',MODEL_OPERATION_INSERT) // 'Incluir'
ElseIf nOp == MODEL_OPERATION_UPDATE
    nRet := FWExecView(STR0016,'LOJACADCLI',MODEL_OPERATION_UPDATE) // 'Alterar'
ElseIf nOp == MODEL_OPERATION_VIEW
    nRet := FWExecView(STR0014,"LOJACADCLI",MODEL_OPERATION_VIEW) //"Visualizar"
EndIf

Return nRet

/*/{Protheus.doc} MenuDef
Menu da tela
@type  Static Function
@author joao.marcos
@since 10/11/2023
@version V10
/*/
Static Function MenuDef()
Local aRotina := {}

GetProfile()

ADD OPTION aRotina TITLE STR0014    ACTION 'VIEWDEF.LOJACADCLI' OPERATION MODEL_OPERATION_VIEW    ACCESS 0 // 'Visualizar'
ADD OPTION aRotina TITLE STR0015    ACTION 'VIEWDEF.LOJACADCLI' OPERATION MODEL_OPERATION_INSERT  ACCESS 0 // 'Incluir'
ADD OPTION aRotina TITLE STR0016    ACTION 'VIEWDEF.LOJACADCLI' OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 // 'Alterar'
ADD OPTION aRotina TITLE STR0031    ACTION 'VIEWDEF.LOJACADCLI' OPERATION MODEL_OPERATION_DELETE  ACCESS 0 // 'Excluir'
ADD OPTION aRotina TITLE STR0032    ACTION "VIEWDEF.LOJACADCLI" OPERATION 9                       ACCESS 0 // 'Copiar'
ADD OPTION aRotina TITLE STR0033    ACTION 'LjAtAutPCC'         OPERATION 10                      ACCESS 0 // 'Auto Preenchimento'

Return aRotina

/*/{Protheus.doc} ModelDef
@type  Static Function
@author joao.marcos
@since 10/11/2023
@version V12
/*/
Static Function ModelDef()

Local oStruSA1  := FWFormStruct( 1, "SA1", /*bAvalCampo*/,/*lViewUsado*/ )
Local bCommit   := {|oModel| CadCliComt(oModel) }
Local oModel    := MPFormModel():New('LOJACADCLI_M',/*bPreValid*/,{ |oModel| LJCDCLPOST( oModel )}, bCommit)	// Modelo de Dados
Local aGatilhos := {}
Local nX        := 0
Local lCtPdv    := AllTrim(SuperGetMV("MV_LJCTPDV",,"2")) == "1" // Utilizado pela Central PDV (Varejo)
Local aCpoObrig := { "A1_COD","A1_LOJA","A1_CGC","A1_NOME","A1_NREDUZ","A1_TIPO","A1RUAAV","A1_MUN","A1_EST"}
Local oEvtBRAFIS    := CRM980EventBRAFIS():New()
Local oEvtBRA		:= CRM980EventBRA():New()

oStruSA1:AddField( ;                      // Ord. Tipo Desc.
AllTrim( STR0034 )                         , ; // [01]  C   Titulo do campo // Situacão FRT
AllTrim( STR0035 )                         , ; // [02]  C   ToolTip do campo // Situacão Front Loja
'A1_SITUA'                                 , ; // [03]  C   Id do Field
'C'                                        , ; // [04]  C   Tipo do campo
TamSX3("A1_SITUA")[1]                      , ; // [05]  N   Tamanho do campo
0                                          , ; // [06]  N   Decimal do campo
Nil                                        , ; // [07]  B   Code-block de validação do campo
NiL                                        , ; // [08]  B   Code-block de validação When do campo
Nil                                        , ; // [09]  A   Lista de valores permitido do campo
Nil                                        , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
{|| "00" }                                 , ; // [11]  B   Code-block de inicializacao do campo
Nil                                        , ; // [12]  L   Indica se trata-se de um campo chave
Nil                                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
.F.                                         )  // [14]  L   Indica se o campo é virtual

oStruSA1:AddField( ;                      // Ord. Tipo Desc.
AllTrim( STR0001 )                         , ; // [01]  C   Titulo do campo #'Domínio do e-mail'
AllTrim( STR0001 )                         , ; // [02]  C   ToolTip do campo #'Domínio do e-mail'
'A1_DOMMAIL'                               , ; // [03]  C   Id do Field
'C'                                        , ; // [04]  C   Tipo do campo
15                                         , ; // [05]  N   Tamanho do campo
0                                          , ; // [06]  N   Decimal do campo
Nil                                        , ; // [07]  B   Code-block de validação do campo
{|| VlCombMail()}                                        , ; // [08]  B   Code-block de validação When do campo
                                           , ; // [09]  A   Lista de valores permitido do campo "#LjOpDomMail"
Nil                                        , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
{|| "" }                                   , ; // [11]  B   Code-block de inicializacao do campo
Nil                                        , ; // [12]  L   Indica se trata-se de um campo chave
Nil                                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                         )  // [14]  L   Indica se o campo é virtual

oStruSA1:AddField( ;                           // Ord. Tipo Desc.
AllTrim( STR0002 )                         , ; // [01]  C   Titulo do campo #'Nome e-mail'
AllTrim( STR0002 )                         , ; // [02]  C   ToolTip do campo #'Nome e-mail'
'A1_MAILDIG'                               , ; // [03]  C   Id do Field
'C'                                        , ; // [04]  C   Tipo do campo
30                                         , ; // [05]  N   Tamanho do campo
0                                          , ; // [06]  N   Decimal do campo
{|| ValidaCpos("A1_MAILDIG")}              , ; // [07]  B   Code-block de validação do campo
NiL                                        , ; // [08]  B   Code-block de validação When do campo
Nil                                        , ; // [09]  A   Lista de valores permitido do campo
Nil                                        , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
Nil                                        , ; // [11]  B   Code-block de inicializacao do campo
Nil                                        , ; // [12]  L   Indica se trata-se de um campo chave
Nil                                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                         )  // [14]  L   Indica se o campo é virtual

oStruSA1:AddField( ;                           // Ord. Tipo Desc.
AllTrim( STR0002 )                         , ; // [01]  C   Titulo do campo #'Nome e-mail'
AllTrim( STR0002 )                         , ; // [02]  C   ToolTip do campo #'Nome e-mail'
'A1RUAAV'                                  , ; // [03]  C   Id do Field
'C'                                        , ; // [04]  C   Tipo do campo
TAMSX3("A1_END")[1]                        , ; // [05]  N   Tamanho do campo
0                                          , ; // [06]  N   Decimal do campo
{|| ValidaCpos("A1RUAAV")}                 , ; // [07]  B   Code-block de validação do campo
{|| !LjPDCmpPrt("A1_END")}                 , ; // [08]  B   Code-block de validação When do campo
Nil                                        , ; // [09]  A   Lista de valores permitido do campo
Nil                                        , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
{|| ExtraiRua()}                           , ; // [11]  B   Code-block de inicializacao do campo
Nil                                        , ; // [12]  L   Indica se trata-se de um campo chave
Nil                                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                         )  // [14]  L   Indica se o campo é virtual

oStruSA1:AddField( ;                           // Ord. Tipo Desc.
AllTrim( STR0002 )                         , ; // [01]  C   Titulo do campo #'Nome e-mail'
AllTrim( STR0002 )                         , ; // [02]  C   ToolTip do campo #'Nome e-mail'
'A1NUMERO'                                 , ; // [03]  C   Id do Field
'C'                                        , ; // [04]  C   Tipo do campo
10                                         , ; // [05]  N   Tamanho do campo
0                                          , ; // [06]  N   Decimal do campo
{|| ValidaCpos("A1NUMERO")}                , ; // [07]  B   Code-block de validação do campo
{|| !LjPDCmpPrt("A1_END")}                 , ; // [08]  B   Code-block de validação When do campo
Nil                                        , ; // [09]  A   Lista de valores permitido do campo
Nil                                        , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
{|| ExtraiNum()}                           , ; // [11]  B   Code-block de inicializacao do campo
Nil                                        , ; // [12]  L   Indica se trata-se de um campo chave
Nil                                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
.T.                                         )  // [14]  L   Indica se o campo é virtual

oStruSA1:SetProperty('A1_SITUA', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, "00"))
oStruSA1:SetProperty('A1_CEP'  , MODEL_FIELD_VALID, {|| LJCadClCEP() })
oStruSA1:SetProperty('A1_CGC'  , MODEL_FIELD_VALID, {|| LJCdClCNPJ() })

If lCtPdv
    oStruSA1:SetProperty( "A1_COD"  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
    oStruSA1:SetProperty( "A1_LOJA" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
EndIf

// Tira a obrigatoriedade dos campos
For nX := 1 To Len(oStruSA1:aFields)
    oStruSA1:SetProperty(oStruSA1:aFields[nX][3],  MODEL_FIELD_OBRIGAT, .F. )
Next

// Seta a obrigatoriedade dos campos
For nX := 1 To Len(aCpoObrig)
    oStruSA1:SetProperty(aCpoObrig[nX],  MODEL_FIELD_OBRIGAT, .T. )
Next

aAdd(aGatilhos, FWStruTriggger( "A1_MAILDIG",;                              //Campo Origem
                                "A1_MAILDIG",;                              //Campo Destino
                                "LJCdClEmail( )",;                          //Regra de Preenchimento                                
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "01");                                      //Sequência do gatilho
)

aAdd(aGatilhos, FWStruTriggger( "A1_DOMMAIL",;                              //Campo Origem
                                "A1_DOMMAIL",;                              //Campo Destino
                                "LJCdClEmail( )",;                          //Regra de Preenchimento                                
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "01");                                      //Sequência do gatilho
)

//Percorrendo os gatilhos e adicionando na Struct
For nX := 1 To Len(aGatilhos)
    oStruSA1:AddTrigger( aGatilhos[nX][01],;    //Campo Origem
                        aGatilhos[nX][02],;     //Campo Destino
                        aGatilhos[nX][03],;     //Bloco de código na validação da execução do gatilho
                        aGatilhos[nX][04])      //Bloco de código de execução do gatilho
Next

oModel:AddFields( "SA1MASTER", Nil  , oStruSA1)	
oModel:GetModel( "SA1MASTER" ):SetDescription( STR0003 ) // "Cadastro de clientes - Varejo"

oModel:SetVldActivate({|oModel| VldActivate(oModel)})

oModel:InstallEvent("LOCBRA"	,/*cOwner*/,oEvtBRA)
oModel:InstallEvent("LOCBRAFIS"	,/*cOwner*/,oEvtBRAFIS)

Return oModel

/*/{Protheus.doc} ViewDef
Modelo de Visualização
@type  Function
@author joao.marcos
@since 10/11/2023
@version V12
/*/
Static Function ViewDef()

Local bAvalCampo    := {|cCAmpo| VldCampos(cCampo) } // Seleciona os campos que serao apresentados
Local oModel        := FWLoadModel( 'LOJACADCLI' )
Local oStruSA1      := FWFormStruct( 2, 'SA1', bAvalCampo)
Local oView         := FWFormView():New()
Local nX            := 0
Local cCampoAdic    := ""
Local aCampoAdic    := {}
Local lAdicCamps    := ExistBlock("LJCAMCADCL")
Local aComboMail    := LjOpDomMail()

If Empty(nOpcao)
    nOpcao := oModel:GetOperation()
EndIf

lDominios := Iif( (Len(aComboMail) == 1 .And. Empty(aComboMail[1]) ), .F., Iif( Len(aComboMail) > 1, .T., .F. ) )

// Ordena campos adicionais, inclusos pelo P.E.
If lAdicCamps
    cCampoAdic := ExecBlock("LJCAMCADCL",.F.,.F.,)
    aCampoAdic := StrTokArr(cCampoAdic,"/")   
EndIf

oStruSA1:AddField( "A1_MAILDIG" ,"19", STR0002 , STR0002 ,/*aHelp*/,"C"    ,/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO04",/*aComboMail*/,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Nome e-mail"
oStruSA1:AddField( "A1_DOMMAIL" ,"20", STR0001 , STR0001 ,/*aHelp*/,"COMBO",/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO04",aComboMail,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Domínio do e-mail"

oStruSA1:AddField( "A1RUAAV"  ,"19", STR0049 , STR0049 ,/*aHelp*/,"C"    ,/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO02",/*aComboMail*/,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Rua/Avenida"
oStruSA1:AddField( "A1NUMERO" ,"20", STR0044 , STR0044 ,/*aHelp*/,"C"    ,/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO02",/*aComboMail*/,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Numero"

oStruSA1:SetProperty( "A1_MAILDIG"  , MVC_VIEW_HELP, {STR0036} ) // "Digite a base do e-mail, por exemplo, se o e-mail for protheus@gmail.com, neste campo digite apenas protheus, e selecione o domínio @gmail.com no campo Dominio."

If  nOpcao == MODEL_OPERATION_UPDATE
    oStruSA1:SetProperty('A1_CGC'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_INSCR'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_PAIS'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_PESSOA'    , MVC_VIEW_CANCHANGE, .F. )
    //Definindo que não irá usar o "Salvar e Criar Novo"
    oView:SetCloseOnOk({|| .T.})
EndIf

oStruSA1:AddFolder('FOLDER01', STR0004,'',2) // "Cadastrais"
oStruSA1:AddFolder('FOLDER02', STR0037,'',2) // "Outros

oStruSA1:AddGroup( "GRUPO01", ""     , "FOLDER01", 2 ) // "Dados para venda"
oStruSA1:AddGroup( "GRUPO02", STR0020, "FOLDER01", 2 ) // "Endereço"
oStruSA1:AddGroup( "GRUPO03", STR0047, "FOLDER01", 2 ) // "Telefone"
oStruSA1:AddGroup( "GRUPO04", STR0048, "FOLDER01", 2 ) // "E-mail"
oStruSA1:AddGroup( "GRUPO05", ""     , "FOLDER02", 2 ) // "Outros"

oStruSA1:SetProperty("A1_TIPO"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_PESSOA"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_CGC"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_COD"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_LOJA"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_NOME"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_NREDUZ"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1RUAAV"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1NUMERO"      , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_EST"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_BAIRRO"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_CEP"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_COD_MUN"    , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_MUN"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_PAIS"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_COMPLEM"    , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_DDD"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_TEL"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_INSCR"      , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_CNAE"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_TIPO"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_TIPO"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_DTNASC"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_EMAIL"      , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_MAILDIG"    , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_DOMMAIL"    , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")

oStruSA1:SetProperty( "A1_TIPO"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_PESSOA"   , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_CGC"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_COD"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_LOJA"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_NOME"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_NREDUZ"   , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_INSCR"    , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_CNAE"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_DTNASC"   , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

// Endereco
oStruSA1:SetProperty( "A1_CEP"      , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1RUAAV"     , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1NUMERO"    , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_COMPLEM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_BAIRRO"   , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_COD_MUN"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_MUN"      , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_EST"      , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_PAIS"     , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

// Telefone
oStruSA1:SetProperty( "A1_DDD"      , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
oStruSA1:SetProperty( "A1_TEL"      , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )

// E-mail
oStruSA1:SetProperty( "A1_EMAIL"    , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
oStruSA1:SetProperty( "A1_MAILDIG"  , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
oStruSA1:SetProperty( "A1_DOMMAIL"  , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )

oStruSA1:SetProperty("A1_COD"       , MVC_VIEW_ORDEM, "01")
oStruSA1:SetProperty("A1_LOJA"      , MVC_VIEW_ORDEM, "02")
oStruSA1:SetProperty("A1_PESSOA"    , MVC_VIEW_ORDEM, "03")
oStruSA1:SetProperty("A1_CGC"       , MVC_VIEW_ORDEM, "04")
oStruSA1:SetProperty("A1_NOME"      , MVC_VIEW_ORDEM, "05")
oStruSA1:SetProperty("A1_NREDUZ"    , MVC_VIEW_ORDEM, "06")
oStruSA1:SetProperty("A1_TIPO"      , MVC_VIEW_ORDEM, "07")
oStruSA1:SetProperty("A1_INSCR"     , MVC_VIEW_ORDEM, "08")
oStruSA1:SetProperty("A1_CNAE"      , MVC_VIEW_ORDEM, "09")
oStruSA1:SetProperty("A1_DTNASC"    , MVC_VIEW_ORDEM, "10")

// Endereço
oStruSA1:SetProperty("A1_CEP"       , MVC_VIEW_ORDEM, "11")
oStruSA1:SetProperty("A1RUAAV"      , MVC_VIEW_ORDEM, "12")
oStruSA1:SetProperty("A1NUMERO"     , MVC_VIEW_ORDEM, "13")
oStruSA1:SetProperty("A1_COMPLEM"   , MVC_VIEW_ORDEM, "14")
oStruSA1:SetProperty("A1_BAIRRO"    , MVC_VIEW_ORDEM, "15")
oStruSA1:SetProperty("A1_COD_MUN"   , MVC_VIEW_ORDEM, "16")
oStruSA1:SetProperty("A1_MUN"       , MVC_VIEW_ORDEM, "17")
oStruSA1:SetProperty("A1_EST"       , MVC_VIEW_ORDEM, "18")

// Telefone
oStruSA1:SetProperty("A1_PAIS"      , MVC_VIEW_ORDEM, "19")
oStruSA1:SetProperty("A1_DDD"       , MVC_VIEW_ORDEM, "20")
oStruSA1:SetProperty("A1_TEL"       , MVC_VIEW_ORDEM, "21")

// E-mail
oStruSA1:SetProperty("A1_MAILDIG"   , MVC_VIEW_ORDEM, "22")
oStruSA1:SetProperty("A1_DOMMAIL"   , MVC_VIEW_ORDEM, "23")
oStruSA1:SetProperty("A1_EMAIL"     , MVC_VIEW_ORDEM, "24")

// Adiciona os campos adicionais no grupo, inclusos pelo P.E.
If lAdicCamps
    For nX := 1 To Len(aCampoAdic)
        oStruSA1:SetProperty(aCampoAdic[nX]  , MVC_VIEW_GROUP_NUMBER    , "GRUPO05")
        oStruSA1:SetProperty(aCampoAdic[nX]  , MVC_VIEW_FOLDER_NUMBER   , "FOLDER02")
        oStruSA1:SetProperty(aCampoAdic[nX]  , MVC_VIEW_ORDEM           , AllTrim(STR(23 + nX)))  
    Next 
EndIf 

oView:SetModel( oModel )
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_SA1", oStruSA1, "SA1MASTER" )
oView:CreateHorizontalBox( "TELA" , 100 )
oView:SetOwnerView( "VIEW_SA1", "TELA" )

Return oView

/*/{Protheus.doc} LJCDCLPOST
Rotina para validação no momento da confirmação da inclusao
@type  Static Function
@author joao.marcos
@since 10/11/2023
@version V1.0
@param oModel, object, model da tela
@return lRet, lógico, se passar na validação retorna .T.
/*/
Static Function LJCDCLPOST(oModel)

Local lRet      := .T.
Local lCentPDV  := If( FindFunction("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Verifica se eh Central de PDV  

If oModel:getOperation() <> MODEL_OPERATION_DELETE
    If lCentPDV .AND. AllTrim(oModel:GetValue( 'SA1MASTER', 'A1_SITUA')) <> "00"
        oModel:SetValue( 'SA1MASTER', 'A1_SITUA',"00")
    ElseIf !lCentPDV
        oModel:SetValue( 'SA1MASTER', 'A1_SITUA',"")
    EndIf

EndIf

Return lRet

/*/{Protheus.doc} VldCampos
Valida os campos a serem apresentados na tela
@type  Static Function
@author joao.marcos
@since 10/11/2023
@version V12
@param cCampo, caracter, nome do campo
@return lRet, logico, retorna se o campo sera ou nao apresentado
/*/
Static Function VldCampos(cCampo)

Local lRet := .F.
Local cCamposLoj := 'A1_CGC|A1_COD|A1_LOJA|A1_NOME|A1_NREDUZ|A1_TIPO|A1_EST|A1_MUN|A1_PESSOA|A1_TEL|A1_EMAIL|A1_BAIRRO|A1_INSCR|A1_CNAE|A1_PAIS|A1_COMPLEM|A1_CEP|A1_COD_MUN|A1_DDD|A1_DTNASC'
Local cCampoAdic := ""  // Campos adicionais

If ExistBlock("LJCAMCADCL")
    cCampoAdic := ExecBlock("LJCAMCADCL",.F.,.F.,)
EndIf 

cCamposLoj := cCamposLoj + cCampoAdic

If Alltrim(cCampo) $ cCamposLoj
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
Validacao ao ativar o modelo
@author Seu Nome
@since 23/10/2025
/*/
//-------------------------------------------------------------------
Static Function VldActivate(oModel)
    Local aEndereco := {}
    Local nConfianca := 0

    nOpcao := oModel:GetOperation()
    
    If nOpcao <> MODEL_OPERATION_INSERT
        aEndereco := SepNumEnd(SA1->A1_END)
        nConfianca := aEndereco[3]
        
        // Exibe alerta se confianca for baixa
        If nConfianca == 0
            FWAlertWarning(STR0050, STR0051) // "Atencao: Não foi possível identificar o numero do enderço automaticamente. Por favor, verifique os dados." ## "Validacao de Endereco"
        EndIf
    EndIf
    
Return .T.

/*/{Protheus.doc} CadGrpComt
Tratativas no Commit do Model
@type  Static Function
@author joao.marcos
@since 03/05/2024
@version 1.0
/*/
Static Function CadCliComt(oModel)
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cRua          := ""
Local cNumero       := ""
Local cEndCompleto  := ""

FWFormCommit( oModel )

cRua    := oModelSA1:GetValue("A1RUAAV")
cNumero := oModelSA1:GetValue("A1NUMERO")

If !Empty(cRua) .AND. !( AllTrim(cRua) $ AllTrim(SA1->A1_END) .AND. AllTrim(cNumero) $ AllTrim(SA1->A1_END) )
    cEndCompleto := MontarEndereco(cRua, cNumero)
    
    RecLock("SA1", .F.)
    SA1->A1_END := cEndCompleto
    MsUnlock()
EndIf

Return .T.

/*/{Protheus.doc} ExtraiRua
Inicializador do campo virtual de rua
@author joao.marcos
@since 23/10/2025
@version V1.0
@return cRua, caracter, retorna o nome da rua extraida do endereco
/*/
Static Function ExtraiRua()
    Local cRua := ""
    Local aEndereco := {}    
    
    If nOpcao <> MODEL_OPERATION_INSERT
        aEndereco := SepNumEnd(SA1->A1_END)        
        // Verifica se o usuário tem permissão para acessar o campo
        If Len(FwProtectedDataUtil():UsrAccessPDField(__cUserId, {"A1_END"})) == 0
            cRua := Replicate("*",Len(AllTrim(aEndereco[1]))) // Ofusca o dado
        Else
            cRua := aEndereco[1]
        EndIf
    EndIf
    
Return cRua

/*/{Protheus.doc} ExtraiNumero
Inicializador do campo virtual de numero
@author joao.marcos
@since 23/10/2025
/*/
Static Function ExtraiNum()
    Local cNumero := ""
    Local aEndereco := {}
    
    If nOpcao <> MODEL_OPERATION_INSERT
        aEndereco := SepNumEnd(SA1->A1_END)        
        // Verifica se o usuário tem permissão para acessar o campo
        If Len(FwProtectedDataUtil():UsrAccessPDField(__cUserId, {"A1_END"})) == 0
            cNumero := Replicate("*",Len(AllTrim(aEndereco[1]))) // Ofusca o dado    
        Else
            cNumero := aEndereco[2]
        EndIf
    EndIf
    
Return cNumero

/*/{Protheus.doc} SepNumEnd
Extrai rua e numero de um endereco completo
@author joao.marcos
@since 23/10/2025
@param cEndCompleto, caracter, Endereco completo do banco
@return array, {cRua, cNumero, nConfianca}
/*/
Static Function SepNumEnd(cEndCompleto)
Local cTexto := AllTrim(cEndCompleto)
Local cRua := ""
Local cNumero := ""
Local nConfianca := 0
Local nPos := 0
Local cUltimaParte := ""
Local lValidado := .F.
Local aSeparador := {" ", ",", ".", "-"}
Local nX := 0
Local lAchouNum := .F.

// Verifica se tem marcador de validado
If RAt(", Numero", cTexto)
    lValidado := .T.
EndIf

// Tenta encontrar numero no final
// Padrao: procura por espaco/virgula/ponto/hifen seguido de numeros
For nX := 1 To Len(aSeparador)
    nPos := RAt(aSeparador[nX], cTexto)
    
    lAchouNum := EhNumero(cTexto, nPos, @cUltimaParte )    
    
    If lAchouNum
        Exit
    EndIf
Next
    
// Verifica se a ultima parte e um numero (pode ter letras no final tipo 123-A)
If lAchouNum
    cNumero := cUltimaParte
    cRua    := AllTrim(SubStr(cTexto, 1, nPos - 1))
    If lValidado
        cRua := AllTrim( StrTran( StrTran(cRua, ", Numero", ""), ",", "" ) )
        cRua := Iif(Right(cRua, 1) == ",", SubStr(cRua,1,Len(cRua)-1), cRua )
    EndIf
    nConfianca := 1
Else
    cRua        := cTexto
    cNumero     := ""
    nConfianca  := 0
EndIf

    
Return {cRua, cNumero, nConfianca}

/*/{Protheus.doc} EhNumero
Verifica se a ultima parte do endereco e um numero
@author joao.marcos
@since 23/10/2025
@param cTexto, caracter, Endereco completo
        nPos, numerico, Posicao do separador
        cUltimaParte, caracter, Retorna a ultima parte do endereco
@return lRet, logico, Se for numero retorna .T.
/*/
Static Function EhNumero(cTexto, nPos, cUltimaParte )
Local lRet       := .F.

cUltimaParte := AllTrim(SubStr(cTexto, nPos + 1))
        
// Verifica se a ultima parte e um numero (pode ter letras no final tipo 123-A)
If IsDigit(Left(cUltimaParte, 1)) .And. Len(cUltimaParte) >= 1 .And. Len(cUltimaParte) <= 10
    lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} MontarEndereco
Monta o endereco completo com marcador de validacao
@author joao.marcos
@since 23/10/2025
@param cRua, caracter, Nome da rua
@param cNumero, caracter, Numero da residencia
@return caracter, Endereco formatado para gravar
/*/
Static Function MontarEndereco(cRua, cNumero)
Local cEndCompleto := ""

cRua := AllTrim(cRua)
cNumero := AllTrim(cNumero)

If !Empty(cNumero)
    cEndCompleto := cRua + ", Numero " + cNumero
Else
    cEndCompleto := cRua 
EndIf
    
Return cEndCompleto

/*/{Protheus.doc} LjCRMA980
Faz adequações no Model CRMA980 da tela de cadastro de clientes padrão
@type  Function
@author joao.marcos
@since 15/12/2023
@version V12
@param oStructSA1, Objetc, Model CRMA980
@return oStructSA1, Object, Retorna o Model após os ajustes
/*/
Function LjCRMA980(oStructSA1)
Local aGatilhos := {}
Local nX		:= 0

oStructSA1:SetProperty( "A1_COD"  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
oStructSA1:SetProperty( "A1_LOJA" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

oStructSA1:SetProperty('A1_CGC',  MODEL_FIELD_OBRIGAT, .T. )

//Adicionando gatilhos, pois os campos A1_COD 1 A1_LOJA são gerados com base no campo A1_CGC
aAdd(aGatilhos, FWStruTriggger( "A1_CGC",;                                  //Campo Origem
                                "A1_COD",;                                  //Campo Destino
                                "STICGCVld( A1_CGC,A1_PESSOA,,,.T. )[1]",;  //Regra de Preenchimento
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "01");                                      //Sequência do gatilho
)

aAdd(aGatilhos, FWStruTriggger( "A1_CGC",;                                  //Campo Origem
                                "A1_LOJA",;                                 //Campo Destino
                                "STICGCVld( A1_CGC,A1_PESSOA,,,.T. )[2]",;  //Regra de Preenchimento
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "02");                                      //Sequência do gatilho
)

//Percorrendo os gatilhos e adicionando na Struct
For nX := 1 To Len(aGatilhos)
    oStructSA1:AddTrigger( aGatilhos[nX][01],; //Campo Origem
                        aGatilhos[nX][02],; //Campo Destino
                        aGatilhos[nX][03],; //Bloco de código na validação da execução do gatilho
                        aGatilhos[nX][04])  //Bloco de código de execução do gatilho
Next

Return oStructSA1

/*/{Protheus.doc} LJCdClCNPJ
Faz a chamada da função LjBuscaCNPJ para preenchimento dos campos do cliente
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
/*/
Function LJCdClCNPJ() As array
Local lCNPJOk       := .F.
Local oModel        := FWModelActive()
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cCNPJ         := oModelSA1:GetValue('A1_CGC')
Local cA1Tipo       := oModelSA1:GetValue('A1_TIPO')
Local cA1Pessoa     := oModelSA1:GetValue('A1_PESSOA')

If nAutPCNPJ == 1 .AND. (Len(AllTrim(cCNPJ)) >= 14) .AND. ( (Upper(AllTrim(cA1Pessoa)) == "J") .OR. Empty(cA1Pessoa) ) .AND.;
    ( AllTrim(cCNPJ) <> "00000000000000" ) .AND. CGC(cCNPJ) .AND. Iif(!Empty(cCNPJ),A030CGC(cA1Pessoa,cCNPJ), .T.)
    FWMsgRun(, {|| LjBuscaCNPJ(@lCNPJOk) }, STR0022, STR0024) // "Consulta", "Consultando Dados..."
ElseIf nAutPCNPJ <> 1 .OR. (Len(AllTrim(cCNPJ)) < 14)
    If (Upper(AllTrim(cA1Tipo)) == "X")
        lCNPJOk := .T.
    ElseIf (Upper(AllTrim(cA1Pessoa)) == "J") .AND. CGC(cCNPJ)
        lCNPJOk := A030CGC(cA1Pessoa,cCNPJ)
    ElseIf (Upper(AllTrim(cA1Pessoa)) == "F") .AND. CGC(cCNPJ) 
        lCNPJOk := A030CGC(cA1Pessoa,cCNPJ)
    Else
        lCNPJOk := .F.
    EndIf
EndIf

Return lCNPJOk

/*/{Protheus.doc} LjBuscaCNPJ
Autopreenche os dados do cliente com base no CNPJ informado
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
@param lCNPJOk, Lógico, Indica se o CNPJ eh valido
/*/
Function LjBuscaCNPJ(lCNPJOk)
Local oConsultaCNPJ := Nil
Local oResposta     := Nil
Local oModel        := FWModelActive()
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cCNPJ         := oModelSA1:GetValue('A1_CGC')
Local aRuaNumero    := {}                               // Array para separar rua e numero

If Len(AllTrim(cCNPJ)) > 11
    oConsultaCNPJ := LjCallApiAutoPreenchimento():New()
    oConsultaCNPJ:BuscaCNPJCarol(AllTrim(cCNPJ))
    oResposta :=  oConsultaCNPJ:GetResposta()

    If oResposta:hasproperty('Error') .AND. Len(oResposta['Error']) > 0
        LjGrvLog( "LJCdClCNPJ", "Erro ao consultar CNPJ, erro:", oResposta['Error'][1]['Mensagem'])
        If oResposta['Error'][1]['Codigo'] == "001"
            lCNPJOk := .T.
        Else
            lCNPJOk := .F.        
        EndIF
        If !Empty(oResposta['Error'][1]['Mensagem'])
            OmsMsgTime(oResposta['Error'][1]['Mensagem'],5)
        EndIf
    Else
        lCNPJOk := .T.
    
        oModel:SetValue( 'SA1MASTER', 'A1_NOME'     ,oResposta["Empresa"][1]["nome"])
        oModel:SetValue( 'SA1MASTER', 'A1_NREDUZ'   ,oResposta["Empresa"][1]["nomeFantasia"])
        oModel:SetValue( 'SA1MASTER', 'A1_PESSOA'   ,oResposta["Empresa"][1]["tipoPessoa"])
        oModel:SetValue( 'SA1MASTER', 'A1_CNAE'     ,SubStr(oResposta["Empresa"][1]["cnae"],1,4)+"-"+SubStr(oResposta["Empresa"][1]["cnae"],5,1)+"/"+SubStr(oResposta["Empresa"][1]["cnae"],6,2))
        
        oModel:SetValue( 'SA1MASTER', 'A1_CEP'      ,oResposta["Endereco"][1]["cep"])

        aRuaNumero := SepNumEnd(oResposta["Endereco"][1]["endereco"])
        oModel:SetValue( 'SA1MASTER', 'A1RUAAV'      ,aRuaNumero[1])
        oModel:SetValue( 'SA1MASTER', 'A1NUMERO'     ,aRuaNumero[2])

        oModel:SetValue( 'SA1MASTER', 'A1_BAIRRO'   ,oResposta["Endereco"][1]["bairro"])
        oModel:SetValue( 'SA1MASTER', 'A1_MUN'      ,oResposta["Endereco"][1]["municipio"])
        oModel:SetValue( 'SA1MASTER', 'A1_EST'      ,oResposta["Endereco"][1]["estado"])
        oModel:SetValue( 'SA1MASTER', 'A1_PAIS'     ,oResposta["Endereco"][1]["pais"])

        oModel:SetValue( 'SA1MASTER', 'A1_TEL'      ,oResposta["Telefone"][1]["telefone"])
        oModel:SetValue( 'SA1MASTER', 'A1_DDD'      ,oResposta["Telefone"][1]["ddd"])
        oModel:SetValue( 'SA1MASTER', 'A1_DDI'      ,oResposta["Telefone"][1]["ddi"])

    EndIf

    // Limpa variaveis
    oConsultaCNPJ:FreeVar()

    FreeObj(oResposta)
    oResposta := Nil
    FreeObj(oConsultaCNPJ)
    oConsultaCNPJ := Nil
EndIf

Return

/*/{Protheus.doc} LJCadClCEP
Chama  afunção LJBuscaCEP para retornar os dados da consulta do CEP
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
@param lInterno, Lógico, Indica se a chamada é interna 
/*/
Function LJCadClCEP(lInterno) As array
Local lCepOk    := .F.

Default lInterno := .F.

If nAutPCEP == 1 
    FWMsgRun(, {|| LJBuscaCEP(lInterno, @lCepOk) }, STR0022, STR0024) // "Consulta", "Consultando Dados..."
Else
    lCepOk := .T.
EndIf

Return lCepOk

/*/{Protheus.doc} LJBuscaCEP
Retorna os dados retornados pela consulta do CEP
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
@param lCepOk, Lógico, Indica se o CEP eh valido
@param lInterno, Lógico, Indica se a chamada é interna 
/*/
Function LJBuscaCEP(lInterno, lCepOk) As array
Local oConsultaCEP  := Nil
Local oResposta     := Nil
Local oModeAct      := FWModelActive()
Local oModelSA1     := oModeAct:GetModel('SA1MASTER')
Local cCEP       := oModelSA1:GetValue('A1_CEP')
Local lRetCep       := .T.
Local lTAS          := .F.
Local lTASConfig    := !Empty(SuperGetMV("MV_URLMSHP",,"")) .AND. !Empty(SuperGetMV("MV_MASHKEY",,""))

Default lInterno := .F.

If Empty(cCEP)
    lCepOk := .T.
ElseIf lInterno .OR. !Empty(cCEP)

    oConsultaCEP := LjCallApiAutoPreenchimento():New()
    oConsultaCEP:BuscaCEPViaCEP(AllTrim(cCEP))
    oResposta :=  oConsultaCEP:GetResposta()

    lRetCep := ValidRetCep(oResposta,@lTAS, lTASConfig)    

    If !lRetCep .AND. lTAS .AND. lTASConfig
        oConsultaCEP:BuscaCEPTAS(AllTrim(cCEP))
        oResposta :=  oConsultaCEP:GetResposta()

        lRetCep := ValidRetCep(oResposta,,lTASConfig)
    EndIF

    If !lRetCep
        oModeAct:SetValue( 'SA1MASTER', 'A1_CEP'      , "")
        lCepOk := .F.   
    ElseIf lRetCep
        // Preenche os dados do endereço com base no CEP       
        lCepOk := .T.
        oModeAct:SetValue( 'SA1MASTER', 'A1_CEP'      ,oResposta["Endereco"][1]["cep"])
        oModeAct:SetValue( 'SA1MASTER', 'A1RUAAV'     ,oResposta["Endereco"][1]["logradouro"])
        oModeAct:SetValue( 'SA1MASTER', 'A1NUMERO'    ,"" )  // Numero fica em branco para o usuario preencher
        oModeAct:SetValue( 'SA1MASTER', 'A1_BAIRRO'   ,oResposta["Endereco"][1]["bairro"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_EST'      ,oResposta["Endereco"][1]["uf"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_PAIS'     ,"105" )         
        oModeAct:SetValue( 'SA1MASTER', 'A1_DDD'      ,oResposta["Endereco"][1]["ddd"])

        If !Empty(oResposta["Endereco"][1]["cidade"])
            oModeAct:SetValue( 'SA1MASTER', 'A1_MUN'      ,oResposta["Endereco"][1]["cidade"])
        EndIf

        oModeAct:SetValue( 'SA1MASTER', 'A1_COD_MUN'  ,SubStr(oResposta["Endereco"][1]["ibge"],3,5))

    EndIf

    FreeObj(oResposta)
    oResposta := Nil
    FreeObj(oConsultaCEP)
    oConsultaCEP := Nil
    
EndIf

Return

/*/{Protheus.doc} ValidRetCep
Valida retorno da API de CEP
@type  Function
@author joao.marcos
@since 17/09/2025
@version v1.0
/*/
Static Function ValidRetCep(oResposta, lTAS, lTASConfig)
Local lRet := .T.

If oResposta:hasproperty('Error') .AND. Len(oResposta['Error']) > 0
    lRet := .F.

    LjGrvLog( "ValidRetCep",  "Erro ao consultar CEP, erro:", oResposta['Error'][1]['Mensagem'])

    Iif(!("200 OK" $ oResposta['Error'][1]['Mensagem'] .OR. "400" $ oResposta['Error'][1]['Mensagem']),lTAS := .T.,)  // Usa API do TAS como contingencia    

EndIf

Return lRet

/*/{Protheus.doc} LJCdClEmail
Preenche o campo A1_EMAIL com o e-mail digitado juntamente com o domínio selecionado
@type  Function
@author joao.marcos
@since 14/08/2025
@version v1.0
/*/
Function LJCdClEmail()
Local oModel        := FWModelActive()
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cEmailDig     := AllTrim( oModelSA1:GetValue('A1_MAILDIG') )
Local cDominio      := AllTrim( oModelSA1:GetValue('A1_DOMMAIL') )

If At( "@", cEmailDig, 1) > 0 .OR. Empty(cDominio)
    oModel:SetValue( 'SA1MASTER', 'A1_EMAIL'    , cEmailDig )
    oModel:SetValue( 'SA1MASTER', 'A1_DOMMAIL'  , "" )
ElseIf !Empty(cDominio)
    oModel:SetValue( 'SA1MASTER', 'A1_EMAIL'    , cEmailDig + cDominio )   
EndIf
Return

/*/{Protheus.doc} VlCombMail
Valida a selecao do combo no vampo A1_MAILDIG
@type  Function
@author joao.marcos
@since 08/11/2025
@version v1.0
/*/
Function VlCombMail()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cEmailDig     := AllTrim( oModelSA1:GetValue('A1_MAILDIG') )

If !Empty(cEmailDig) .AND. At( "@", cEmailDig, 1) > 0
    lRet := .F.
EndIf

Return lRet


/*/{Protheus.doc} LjOpDomMail
Retona as opções de domínio para o campo A1_DOMMAIL
@type  Function
@author joao.marcos
@since 15/08/2025
@version v1.0
@gmail.com;@outlook.com;@hotmail.com;@yahoo.com;@uol.com.br;@bol.com.br
/*/
Function LjOpDomMail()
Local cDomMailCl    := SuperGetMv("MV_LJDMAIL",,"")
Local aDominios     := {""}
Local aDomMailCl    := {}

If Len(cDomMailCl) > 0 .AND. !Empty(cDomMailCl)
    aDomMailCl := StrTokArr(cDomMailCl,';')
    aSize(aDominios, Len(aDominios) + Len(aDomMailCl))
    aCopy(aDomMailCl, aDominios, 1, ,  Len(aDominios) - Len(aDomMailCl) + 1)
EndIf

Return aDominios

/*/{Protheus.doc} LjConsPCli
Consulta Padrão de Clientes
@type  Function
@author joao.marcos
@since 20/08/2025
@version v1.0
/*/
Function LjConsPCli()
Local oTempTable   		
Local aArea 			:= GetArea()																//Salva área
Local cCliente          := Space(50)																//Codigo do Produto
Local cRealName   		:= "" 																		//Variavel auxiliar da tabela temporaria principal, para utilização da TCSqlExec()
Local cAliasSA1   		:= GetNextAlias()															//Tabela temporaria. Pesquisa Principal.

Local oButPesq		:= Nil
Local oButVisua		:= Nil
Local oButInclu		:= Nil
Local oButAlter		:= Nil
Local oButOk		:= Nil
Local oButFechar    := Nil
Local bAcBtPesq		:= {|| PesqSA1(cCliente, cRealName, cAliasSA1), o_Get1:SetFocus() }			//Ação do Botão Pesquisar
Local aPrincipal    := FWGetDialogSize(oMainWnd)
Local aCliente		:= {}												                            //Retorno do cliente selecionado	

Local nLinFim       := 27
Local nColFim       := 100
Local nLinBot       := 178
Local aHeaderSA1    := {}
Local lCliBloq      := .F.                                          //Controla se o cliente está bloqueado
Local bBtOk         := {|| aCliente := AcaoBot(999 , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA, @lCliBloq), Iif(!lCliBloq,oDlg:End(),) }
Local bBtFecha      := {|| lBtFecha := .T.,  aCliente := AcaoBot(998), oDlg:End() }
Local lBtFecha      := .F.                                                                          //Controla o fechamento da tela

Local cCliPad       := Upper( AllTrim( SuperGetMV("MV_CLIPAD",,"") ) ) + " " + Upper( AlLTrim( SuperGetMV("MV_LOJPAD",,"") ) )
Local cCliTela      := Upper(AlLTrim(M->LQ_CLIENTE)) + " " + Upper(AlLTrim(M->LQ_LOJA))
Local lCliPad       := cCliPad == cCliTela

//Cria tabela temporária auxiliar da pesquisa
aHeaderSA1  := {{"A1_FILIAL"    , "C" , TAMSX3("A1_FILIAL")[1]  , 0 },;
                {"A1_COD"       , "C" , TAMSX3("A1_COD")[1]     , 0 },;
                {"A1_LOJA"      , "C" , TAMSX3("A1_LOJA")[1]     , 0 },;
                {"A1_NOME"      , "C" , TAMSX3("A1_NOME")[1]    , 0 },;
                {"A1_CGC"       , "C" , TAMSX3("A1_CGC")[1]     , 0 },;
                {"A1_NREDUZ"    , "C" , TAMSX3("A1_NREDUZ")[1]  , 0 },;
                {"A1_EST"       , "C" , TAMSX3("A1_EST")[1]     , 0 },;
                {"A1_MUN"       , "C" , TAMSX3("A1_MUN")[1]     , 0 },;
                {"A1_END"       , "C" , TAMSX3("A1_END")[1]     , 0 }}

//Cria a tabela temporária com base na estrutura
oTempTable := LjCrTmpTbl(cAliasSA1, aHeaderSA1, {"A1_FILIAL","A1_COD","A1_LOJA"})
cRealName := oTempTable:GetRealName()
cRealName := StrTran(cRealName,"dbo.","")
cAliasSA1 := oTempTable:GetAlias()

Dbselectarea(cAliasSA1)

If Upper(Alltrim(FunName())) == "LOJA701"
   Lj7SetKEYs(.F.)          
   SetKey(17,Nil)
   SetKey(18,Nil)
   SetKey(20,Nil)
EndIf

oDlg := MSDialog():New(aPrincipal[1],aPrincipal[2], nLinFim, nColFim, OemToAnsi(STR0039),,,,,,,,,,,,) // Consulta de Cliente

@ 07,10  SAY STR0007 PIXEL   //Pesquisar
@ 05,40  MSGET o_Get1 VAR cCliente Picture("@!") Of oDlg PIXEL SIZE C(210),C(10)
o_Get1:cPlaceHold := STR0008 //"Digite para pesquisar o produto..."

// Pesquisar
oButPesq := TButton():New( 006, 318, STR0007,oDlg,bAcBtPesq, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Pesquisar"

oMsdb := TCBrowse():New(23, 05, C(290), C(112), Nil, Nil, Nil, odlg, , , , , , , , , , , , .F., cAliasSA1, .T., , .F., , , ) 
oMsdb:AddColumn( TCColumn():New( STR0009    ,{|| (cAliasSA1)->A1_COD  	},,,,"LEFT"	,50,.f.,.F.,,,,.F.))   //Código
oMsdb:AddColumn( TCColumn():New( STR0010    ,{|| (cAliasSA1)->A1_LOJA  	},,,,"LEFT"	,30,.f.,.F.,,,,.F.))	//Loja
oMsdb:AddColumn( TCColumn():New( STR0011    ,{|| (cAliasSA1)->A1_NOME  	},,,,"LEFT"	,100,.f.,.F.,,,,.F.))	//Nome
oMsdb:AddColumn( TCColumn():New( STR0012    ,{|| (cAliasSA1)->A1_NREDUZ },,,,"LEFT"	,100,.f.,.F.,,,,.F.))	//Nome Fantasia
oMsdb:AddColumn( TCColumn():New( STR0013    ,{|| (cAliasSA1)->A1_CGC	},,,,"LEFT"	,060,.f.,.F.,,,,.F.))	//CPF/CNPJ
oMsdb:AddColumn( TCColumn():New( STR0018    ,{|| (cAliasSA1)->A1_EST	},,,,"LEFT"	,030,.f.,.F.,,,,.F.))	//Estado
oMsdb:AddColumn( TCColumn():New( STR0019    ,{|| (cAliasSA1)->A1_MUN	},,,,"LEFT"	,050,.f.,.F.,,,,.F.))	//Municipio
oMsdb:AddColumn( TCColumn():New( STR0020    ,{|| (cAliasSA1)->A1_END	},,,,"LEFT"	,080,.f.,.F.,,,,.F.))	//Endereço

oMsdb:lVScroll 		:= .T.
oMsdb:nScrollType 	:= 0 
oMsdb:Cargo      	:= .T. 

oMsdb:nColPos    	:= 1
oMsdb:blDblClick 	:= bBtOk
oMsdb:aObfuscatedCols := {  Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_COD"   } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_LOJA"  } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_NOME"  } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_NREDUZ"} ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_CGC"   } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_EST"   } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_MUN"   } ) ) == 0 ,;
                            Len( FwProtectedDataUtil():UsrAccessPDField( __cUserId, {"A1_END"   } ) ) == 0  }

oButVisua 	:= TButton():New( nLinBot, 197, STR0014  ,oDlg ,{|| AcaoBot(MODEL_OPERATION_VIEW  , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Visualizar"
oButInclu 	:= TButton():New( nLinBot, 231, STR0015  ,oDlg ,{|| AcaoBot(MODEL_OPERATION_INSERT, (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA, ,cRealName, cAliasSA1) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Incluir"
oButAlter 	:= TButton():New( nLinBot, 267, STR0016  ,oDlg ,{|| AcaoBot(MODEL_OPERATION_UPDATE, (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA, ,cRealName, cAliasSA1) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Alterar"
oButOk		:= TButton():New( nLinBot, 302, STR0017  ,oDlg , bBtOk	                                                         , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Ok"
oButFechar	:= TButton():New( nLinBot, 337, STR0021  ,oDlg , bBtFecha                                                        , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Fechar"

If !lCliPad
    PesqSA1(cCliente, cRealName, cAliasSA1, .T., M->LQ_CLIENTE, M->LQ_LOJA)
EndIf

oDlg:Activate()

If Upper(Alltrim(FunName())) == "LOJA701"
    Iif(!lBtFecha .AND. Len(aCliente) > 1, M->LQ_LOJA := aCliente[2],)
    Lj7SetKEYs(.T.)
EndIf

Dbselectarea("SA1")

Retindex("SA1")
RestArea(aArea)

oTempTable:Delete()

Return .T.

/*/{Protheus.doc} PesqSA1
Pesquisa os clientes conforme o texto digitado no campo de pesquisa
@type  Function
@author joao.marcos
@since 20/08/2025
@version v1.0
/*/
Static Function PesqSA1(cPesquisar, cRealName, cAliasSA1, lCliLoja, cCliente, cLoja)

Local aPesq     := {}
Local nX		:= 1
Local nY		:= 1
Local nStatus	:= 0
Local cErrorQry	:= ""
Local cPesquisa := ""
Local cPesq		:= " "
Local cQry      := ""
Local cCampos	:= ""
Local cDelete 	:= ""
Local cInsert   := ""

Default cPesquisar := ""
Default lCliLoja := .F.
Default cCliente := ""
Default cLoja    := ""

cPesquisa := Alltrim(cPesquisar)

For nX := 1 To Len(cPesquisa)
	If nX == 1 .AND. AT(" ",cPesquisa) <> 0   
        aadd(aPesq,SubStr(cPesquisa,nX,AT(" ",cPesquisa)-1))		
		nX += AT(" ",cPesquisa)-1
		cPesq := SubStr(cPesquisa,AT(" ",cPesquisa)+1,len(cPesquisa))
	Else 
		If AT(" ",IIF(Empty(cPesq),cPesquisa,cPesq)) == 0   
			aadd(aPesq,SubStr(IIF(Empty(cPesq),cPesquisa,cPesq),1,len(IIF(Empty(cPesq),cPesquisa,cPesq)) ) )
			nX := Len(cPesquisa)		
		EndIf
	EndIf
Next nX

cCampos  := "A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_CGC, A1_EST, A1_MUN, A1_END" 

cQry := " SELECT " + cCampos + " "
cQry += " FROM " + RetSqlName("SA1") + " SA1 "
cQry += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "'"

If lCliLoja
    cQry += " AND SA1.A1_COD   = '" + RTrim(cCliente) + "'"
    cQry += " AND SA1.A1_LOJA  = '" + RTrim(cLoja) + "'"
ElseIf Len(aPesq) > 0
		cQry += " AND ( UPPER(SA1.A1_COD)     Like '%" 	+ aPesq[1]	+"%' "
		cQry += " OR UPPER(SA1.A1_LOJA)     Like '%"	+ aPesq[1] +"%' "
        If Len(aPesq) > 1
            cQry += " OR ( UPPER(SA1.A1_NOME)     Like '%"	+ aPesq[1] +"%' AND"
            For nY := 2 To Len(aPesq)
                cQry += " UPPER(SA1.A1_NOME)     Like '%"	+ aPesq[nY] +"%' AND"
            Next nY

            cQry := SubStr(cQry,1,Len(cQry)-3) + " ) " //Remove o ultimo AND

            cQry += " OR ( UPPER(SA1.A1_END)     Like '%"	+ aPesq[1] +"%' AND"
            For nY := 2 To Len(aPesq)
                cQry += " UPPER(SA1.A1_END)     Like '%"	+ aPesq[nY] +"%' AND"
            Next nY

            cQry := SubStr(cQry,1,Len(cQry)-3) + " ) "

             cQry += " OR ( UPPER(SA1.A1_MUN)     Like '%"	+ aPesq[1] +"%' AND"
            For nY := 2 To Len(aPesq)
                cQry += " UPPER(SA1.A1_MUN)     Like '%"	+ aPesq[nY] +"%' AND"
            Next nY

            cQry := SubStr(cQry,1,Len(cQry)-3) + " ) "
        Else
            cQry += " OR UPPER(SA1.A1_NOME)     Like '%"	+ aPesq[nY] +"%' "
            cQry += " OR UPPER(SA1.A1_NREDUZ)   Like '%"	+ aPesq[nY] +"%' "
            cQry += " OR UPPER(SA1.A1_END)      Like '%"	+ aPesq[nY] +"%' "
            cQry += " OR UPPER(SA1.A1_MUN)      Like '%"	+ aPesq[nY] +"%' "
            cQry += " OR UPPER(SA1.A1_EST)      Like '%"	+ aPesq[nY] +"%' "
        EndIf
		cQry += " OR UPPER(SA1.A1_CGC)      Like '%"	+ aPesq[1] +"%' )"
EndIf

cQry += " AND SA1.D_E_L_E_T_ = ' ' " 

If cDB == "MSSQL"
    cQry += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA,A1_NOME,A1_CGC" 
EndIf

cDelete 	:= " DELETE FROM " + cRealName +"" + chr(10)
nStatus := TCSqlExec( cDelete )

Iif(nStatus <> 0,cErrorQry := TCSQLError(),)

If nStatus == 0
    cInsert 	:= " INSERT INTO " + cRealName + " ( " +cCampos+" ) " + cQry + "" + chr(10)
    nStatus := TCSqlExec( cInsert )
EndIf

If nStatus == 0
	Dbselectarea(cAliasSA1)
	(cAliasSA1)->(DbGotop())
    If (cAliasSA1)->(EOF()) 
        MsgAlert( STR0045 ) // "Nenhum registro encontrado."
    EndIf
Else
	cErrorQry := TCSQLError()
	LjGrvLog("LjConsPCli", "PesqSA1 | Falha na manipulação da tabela temporaria " + cRealName + " | Erro: " + cErrorQry, nStatus)	
EndIf

oMsdb:Refresh()

Return

/*/{Protheus.doc} AcaoBot
Ação dos botões da tela de consulta de clientes
@type  Function
@author joao.marcos
@since 20/08/2025
@version v1.0
@param nAcao, numeric, Ação do botão (A- Alterar, I- Incluir, V- Visualizar, OK- Retorna o cliente selecionado)
@param cCod, Caracter, Código do cliente    
@param cLoja, Caracter, Loja do cliente 
/*/
Static Function AcaoBot(nAcao, cCod, cLoja, lCliBloq, cRealName, cAliasSA1)
Local aCliente	    := {"",""}
Local nSA1Recno     := 0
Local lChamaTela    := .T.          // Chama tela de cadastro LJCADCLI
Local cCliOld       := SA1->A1_COD
Local cLojaOld      := SA1->A1_LOJA
Local nRetCad       := 0            // Retorno do cadastro 0 - Ok, 1 - Cancelou
Local lA1MSBLSQ     := SA1->(ColumnPos("A1_MSBLQL")) > 0

Default cRealName := ""
Default cAliasSA1 := ""

If ( (nAcao == MODEL_OPERATION_VIEW .OR. nAcao == MODEL_OPERATION_UPDATE .OR. nAcao == 999) .AND. (Empty(cCod) .AND. Empty(cLoja)) )  .OR. nAcao == 998
    If (Empty(cCod) .AND. Empty(cLoja))
        MsgAlert( STR0046 ) // "Nenhum cliente selecionado."
    EndIf

    If  nAcao == 999 .OR. nAcao == 998
        aCliente[1] := SA1->A1_COD
        aCliente[2] := SA1->A1_LOJA
    EndIf

    Iif( ValType(lCliBloq) <> "U" .AND. nAcao == 999, lCliBloq := .T.,)
    lChamaTela := .F.
EndIf

If lChamaTela
    SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
    SA1->(dbSeek( xFilial("SA1") + PadR(cCod,TamSX3("A1_COD")[1]) + PadR(cLoja,TamSX3("A1_COD")[1]) ))    

    If lA1MSBLSQ .AND. (nAcao == 999 .OR. nAcao == 998) .AND. SA1->A1_MSBLQL == "1"
        // Registro bloqueado para uso
        If nAcao == 999
            MsgAlert( STR0041 + CHR(13)+CHR(10) + STR0042 + CHR(13)+CHR(10) + STR0043 ) // "Registro bloqueado para uso SA1-Clientes." + CHR(13) + "Entre em contato com o administrador do sistema ou responsável pelo registro para identificar o motivo do bloqueio." + CHR(13) + "O bloqueio/desbloqueio do registro é realizado pelo campo A1_MSBLQL."
        EndIf
        lCliBloq := .T.
        SA1->(dbSeek( xFilial("SA1") + PadR(cCliOld,TamSX3("A1_COD")[1]) + PadR(cLojaOld,TamSX3("A1_COD")[1]) ))
        aCliente[1] := cCliOld
        aCliente[2] := cLojaOld
    Else
        nSA1Recno := SA1->(RecNo())
        lCliBloq := .F.

        Do Case
            Case nAcao == 999
                If !Empty(cCod)
                    aCliente[1] := cCod
                    aCliente[2] := cLoja
                EndIf
            Case nAcao == MODEL_OPERATION_VIEW  //Visualizar
                LJCADCLI(MODEL_OPERATION_VIEW, nSA1Recno)        
            Case nAcao == MODEL_OPERATION_INSERT  //Incluir
                nRetCad := LJCADCLI(MODEL_OPERATION_INSERT, nSA1Recno)
                SetaCli(nRetCad, cRealName, cAliasSA1, cCliOld, cLojaOld)
            Case nAcao == MODEL_OPERATION_UPDATE  //Alterar
                nRetCad := LJCADCLI(MODEL_OPERATION_UPDATE, nSA1Recno)
                SetaCli(nRetCad, cRealName, cAliasSA1, cCliOld, cLojaOld)
        End Case
        
    EndIf
EndIf

Return aCliente

/*/{Protheus.doc} SetaCli
Aciona a pesquisa para o cliente apos o cadastro
@type  Static Function
@author joao.marcos
@since 29/10/2025        
/*/
Static Function SetaCli(nRetCad, cRealName, cAliasSA1, cCliOld, cLojaOld)

PesqSA1(, cRealName, cAliasSA1, .T., SA1->A1_COD, SA1->A1_LOJA)      
SA1->(dbSeek( xFilial("SA1") + PadR(cCliOld,TamSX3("A1_COD")[1]) + PadR(cLojaOld,TamSX3("A1_COD")[1]) ))

Return

/*/{Protheus.doc} LjAtAutPCC
Apresenta tela para ativar/desativar o auto preenchimento de CNPJ e CEP
@type  Function
@author joao.marcos
@since 03/09/2025   
/*/
Function LjAtAutPCC()

Pergunte("LJCADCLIAP",.T.)

nAutPCNPJ   := MV_PAR01
nAutPCEP    := MV_PAR02

Return

/*/{Protheus.doc} GetProfile
Carrega pergunte com as escolhas do auto preenchimento de CNPJ e CEP
@type  Function
@author joao.marcos
@since 03/09/2025
@param lTela, Lógico, Indica se vai apresentar a tela do pergunte    
/*/
Static Function GetProfile(lTela)
Default lTela := .F.

Pergunte("LJCADCLIAP",lTela)

nAutPCNPJ   := MV_PAR01
nAutPCEP    := MV_PAR02

Return

/*/{Protheus.doc} ValidaCpos
Faz a validacao dos campos
@type  Function
@author joao.marcos
@since 16/09/2025
@version v1.0
@param cField, Caracter, Nome do campo a ser validado
/*/
Static Function ValidaCpos(cField)
Local lRet := .T.

If cField == "A1_MAILDIG" .AND. !lDominios
    MsgAlert(STR0040) // "Para habilitar o combo com as opções de domínios de e-mail configure o parâmetro MV_LJDMAIL"
EndIf

Return lRet
