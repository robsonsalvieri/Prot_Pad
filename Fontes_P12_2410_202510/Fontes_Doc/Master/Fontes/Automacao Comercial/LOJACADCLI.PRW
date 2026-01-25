#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJACADCLI.CH'

Static nAutPCNPJ   := 1
Static nAutPCEP    := 1
Static lDominios   := .T.
Static cOpcao      := "" 
Static lA1MSBLSQ   := SA1->(ColumnPos("A1_MSBLQL")) > 0

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
@param  cOp, Caracter, Opcao Inclusao/ Alteracao
        nSA1Recno, Caracter, RECNO do registro na SA1
/*/
Function LJCADCLI(cOp, nSA1Recno)

Default cOp := "I"

cOpcao := AllTrim(cOp)

If AllTrim(cOp) == "I"
    FWExecView(STR0015,'LOJACADCLI',MODEL_OPERATION_INSERT) // 'Incluir'
ElseIf AllTrim(cOp) == "A"
    FWExecView(STR0016,'LOJACADCLI',MODEL_OPERATION_UPDATE) // 'Alterar'
ElseIf AllTrim(cOp) == "V"
    FWExecView(STR0014,"LOJACADCLI",MODEL_OPERATION_VIEW) //"Visualizar"
EndIf

Return NIL

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
Local oModel    := MPFormModel():New('LOJACADCLI_M',/*bPreValid*/,{ |oModel| LJCDCLPOST( oModel )})	// Modelo de Dados
Local aGatilhos := {}
Local nX        := 0
Local lCtPdv    := AllTrim(SuperGetMV("MV_LJCTPDV",,"2")) == "1" // Utilizado pela Central PDV (Varejo)

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
NiL                                        , ; // [08]  B   Code-block de validação When do campo
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

oStruSA1:SetProperty('A1_SITUA',   MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "00"))

If lCtPdv
    oStruSA1:SetProperty( "A1_COD"  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
    oStruSA1:SetProperty( "A1_LOJA" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
EndIf

oStruSA1:SetProperty('A1_CGC',  MODEL_FIELD_OBRIGAT, .T. )

aAdd(aGatilhos, FWStruTriggger( "A1_CGC",;                                  //Campo Origem
                                "A1_CGC",;                                  //Campo Destino
                                "LJCdClCNPJ( )",;                           //Regra de Preenchimento                                
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "01");                                      //Sequência do gatilho
)

aAdd(aGatilhos, FWStruTriggger( "A1_CEP",;                                  //Campo Origem
                                "A1_CEP",;                                  //Campo Destino
                                "LJCadClCEP(,M->A1_CEP)",;                   //Regra de Preenchimento                                
                                .F.,;                                       //Irá Posicionar?
                                "",;                                        //Alias de Posicionamento
                                0,;                                         //Índice de Posicionamento
                                '',;                                        //Chave de Posicionamento
                                NIL,;                                       //Condição para execução do gatilho
                                "01");                                      //Sequência do gatilho
)
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

lDominios := Iif( (Len(aComboMail) == 1 .And. Empty(aComboMail[1]) ), .F., Iif( Len(aComboMail) > 1, .T., .F. ) )

// Ordena campos adicionais, inclusos pelo P.E.
If lAdicCamps
    cCampoAdic := ExecBlock("LJCAMCADCL",.F.,.F.,)
    aCampoAdic := StrTokArr(cCampoAdic,"/")   
EndIf

If  cOpcao == "A"
    oStruSA1:SetProperty('A1_CGC'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_INSCR'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_PAIS'	    , MVC_VIEW_CANCHANGE, .F. )
    oStruSA1:SetProperty('A1_PESSOA'    , MVC_VIEW_CANCHANGE, .F. )
EndIf

oStruSA1:AddField( "A1_MAILDIG" ,"19", STR0002 , STR0002 ,/*aHelp*/,"C",/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO02",/*aComboMail*/,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Nome e-mail"
oStruSA1:AddField( "A1_DOMMAIL" ,"20", STR0001 , STR0001 ,/*aHelp*/,"COMBO"    ,/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,"GRUPO02",aComboMail,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/.F.,/*nWidth*/ ) //,,,,.F.,,,,,,.T. ) // "Domínio do e-mail"

oStruSA1:SetProperty( "A1_MAILDIG"  , MVC_VIEW_HELP, {STR0036} ) // "Digite a base do e-mail, por exemplo, se o e-mail for protheus@gmail.com, neste campo digite apenas protheus, e selecione o domínio @gmail.com no campo Dominio."

oStruSA1:AddFolder('FOLDER01', STR0004,'',2) // "Cadastrais"
oStruSA1:AddFolder('FOLDER02', STR0037,'',2) // "Outros

oStruSA1:AddGroup( "GRUPO01", STR0006, "", 2 ) // "Dados para venda"
oStruSA1:AddGroup( "GRUPO02", "", "", 2 )
oStruSA1:AddGroup( "GRUPO03", STR0037, "", 2 ) // "Outros"

oStruSA1:SetProperty("A1_TIPO"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_PESSOA"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_CGC"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_COD"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_LOJA"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_NOME"       , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_NREDUZ"     , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
oStruSA1:SetProperty("A1_END"        , MVC_VIEW_FOLDER_NUMBER, "FOLDER01")
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
oStruSA1:SetProperty( "A1_END"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_EST"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_BAIRRO"   , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_CEP"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_COD_MUN"  , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_MUN"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_PAIS"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_COMPLEM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_DDD"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_TEL"      , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_INSCR"    , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_CNAE"     , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_DTNASC"   , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruSA1:SetProperty( "A1_EMAIL"    , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

oStruSA1:SetProperty( "A1_MAILDIG"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruSA1:SetProperty( "A1_DOMMAIL"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

oStruSA1:SetProperty("A1_COD"       , MVC_VIEW_ORDEM, "01")
oStruSA1:SetProperty("A1_LOJA"      , MVC_VIEW_ORDEM, "02")
oStruSA1:SetProperty("A1_PESSOA"    , MVC_VIEW_ORDEM, "03")
oStruSA1:SetProperty("A1_CGC"       , MVC_VIEW_ORDEM, "04")
oStruSA1:SetProperty("A1_NOME"      , MVC_VIEW_ORDEM, "05")
oStruSA1:SetProperty("A1_NREDUZ"    , MVC_VIEW_ORDEM, "06")
oStruSA1:SetProperty("A1_TIPO"      , MVC_VIEW_ORDEM, "07")
oStruSA1:SetProperty("A1_INSCR"     , MVC_VIEW_ORDEM, "08")
oStruSA1:SetProperty("A1_CNAE"      , MVC_VIEW_ORDEM, "09")
oStruSA1:SetProperty("A1_CEP"       , MVC_VIEW_ORDEM, "10")
oStruSA1:SetProperty("A1_END"       , MVC_VIEW_ORDEM, "11")
oStruSA1:SetProperty("A1_COMPLEM"   , MVC_VIEW_ORDEM, "12")
oStruSA1:SetProperty("A1_EST"       , MVC_VIEW_ORDEM, "13")
oStruSA1:SetProperty("A1_BAIRRO"    , MVC_VIEW_ORDEM, "14")
oStruSA1:SetProperty("A1_COD_MUN"   , MVC_VIEW_ORDEM, "15")
oStruSA1:SetProperty("A1_MUN"       , MVC_VIEW_ORDEM, "16")
oStruSA1:SetProperty("A1_PAIS"      , MVC_VIEW_ORDEM, "17")
oStruSA1:SetProperty("A1_DDD"       , MVC_VIEW_ORDEM, "18")
oStruSA1:SetProperty("A1_TEL"       , MVC_VIEW_ORDEM, "19")
oStruSA1:SetProperty("A1_DTNASC"    , MVC_VIEW_ORDEM, "20")

oStruSA1:SetProperty("A1_MAILDIG"   , MVC_VIEW_ORDEM, "21")
oStruSA1:SetProperty("A1_DOMMAIL"   , MVC_VIEW_ORDEM, "22")

oStruSA1:SetProperty("A1_EMAIL"     , MVC_VIEW_ORDEM, "23")

// Adiciona os campos adicionais no grupo, inclusos pelo P.E.
If lAdicCamps
    For nX := 1 To Len(aCampoAdic)
        oStruSA1:SetProperty(aCampoAdic[nX]  , MVC_VIEW_GROUP_NUMBER    , "GRUPO02")
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
Local cCamposLoj := 'A1_CGC|A1_COD|A1_LOJA|A1_NOME|A1_NREDUZ|A1_END|A1_TIPO|A1_EST|A1_MUN|A1_PESSOA|A1_TEL|A1_EMAIL|A1_BAIRRO|A1_INSCR|A1_CNAE|A1_PAIS|A1_COMPLEM|A1_CEP|A1_COD_MUN|A1_DDD|A1_DTNASC'
Local cCampoAdic := ""  // Campos adicionais

If ExistBlock("LJCAMCADCL")
    cCampoAdic := ExecBlock("LJCAMCADCL",.F.,.F.,)
EndIf 

cCamposLoj := cCamposLoj + cCampoAdic

If Alltrim(cCampo) $ cCamposLoj
	lRet := .T.
EndIf

Return lRet

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
Local nX		:= 0 // Contador do For

oStructSA1:SetProperty( "A1_COD"  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
oStructSA1:SetProperty( "A1_LOJA" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

oStructSA1:SetProperty('A1_CGC',  MODEL_FIELD_OBRIGAT, .T. )

//Adicionando gatilhos, pois os campos A1_COD 1 A1_LOJA são gerados com base no campo A1_CGC
aAdd(aGatilhos, FWStruTriggger( "A1_CGC",;                                  //Campo Origem
                                "A1_COD",;                                 //Campo Destino
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

If nAutPCNPJ == 1
    FWMsgRun(, {|| LjBuscaCNPJ() }, STR0022, STR0023) // "Consulta", "Consultando CNPJ..."
EndIf

Return

/*/{Protheus.doc} LjBuscaCNPJ
Autopreenche os dados do cliente com base no CNPJ informado
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
/*/
Function LjBuscaCNPJ()
Local oConsultaCNPJ := Nil
Local oResposta     := Nil
Local oModel        := FWModelActive()
Local oModelSA1     := oModel:GetModel('SA1MASTER')
Local cCNPJ         := oModelSA1:GetValue('A1_CGC')

If Len(AllTrim(cCNPJ)) > 11
    oConsultaCNPJ := LjCallApiAutoPreenchimento():New()
    oConsultaCNPJ:BuscaCNPJCarol(AllTrim(cCNPJ))
    oResposta :=  oConsultaCNPJ:GetResposta()

    If oResposta:hasproperty('Error') .AND. Len(oResposta['Error']) > 0
        LjGrvLog( "LJCdClCNPJ", "Erro ao consultar CNPJ, erro:", oResposta['Error'][1]['Mensagem'])
        OmsMsgTime(oResposta['Error'][1]['Mensagem'],5)
    Else
    
        oModel:SetValue( 'SA1MASTER', 'A1_CGC'      ,oResposta["Empresa"][1]["cnpj"])
        oModel:SetValue( 'SA1MASTER', 'A1_NOME'     ,oResposta["Empresa"][1]["nome"])
        oModel:SetValue( 'SA1MASTER', 'A1_NREDUZ'   ,oResposta["Empresa"][1]["nomeFantasia"])
        oModel:SetValue( 'SA1MASTER', 'A1_PESSOA'   ,oResposta["Empresa"][1]["tipoPessoa"])
        oModel:SetValue( 'SA1MASTER', 'A1_CNAE'     ,SubStr(oResposta["Empresa"][1]["cnae"],1,4)+"-"+SubStr(oResposta["Empresa"][1]["cnae"],5,1)+"/"+SubStr(oResposta["Empresa"][1]["cnae"],6,2))
        
        oModel:SetValue( 'SA1MASTER', 'A1_CEP'      ,oResposta["Endereco"][1]["cep"])
        oModel:SetValue( 'SA1MASTER', 'A1_END'      ,oResposta["Endereco"][1]["endereco"])
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
@param cCEP, Caracter, CEP a ser consultado
@param lInterno, Lógico, Indica se a chamada é interna 
/*/
Function LJCadClCEP(lInterno, cCEP, oModel) As array

If nAutPCEP == 1
    FWMsgRun(, {|| LJBuscaCEP(lInterno, cCEP, oModel) }, STR0022, STR0024) // "Consulta", "Consultando CEP..."
EndIf

Return

/*/{Protheus.doc} LJBuscaCEP
Retorna os dados retornados pela consulta do CEP
@type  Function
@author joao.marcos
@since 31/07/2025
@version v1.0
@param cCEP, Caracter, CEP a ser consultado
@param lInterno, Lógico, Indica se a chamada é interna 
/*/
Function LJBuscaCEP(lInterno, cCEP, oModel) As array
Local oConsultaCEP  := Nil
Local oResposta     := Nil
Local oModeAct      := Nil
Local lRetCep       := .T.
Local lTAS          := .F.
Local lTASConfig    := !Empty(SuperGetMV("MV_URLMSHP")) .AND. !Empty(SuperGetMV("MV_MASHKEY"))

Default lInterno := .F.
Default oModel := Nil

If lInterno .OR. !Empty(cCEP)

    oConsultaCEP := LjCallApiAutoPreenchimento():New()
    oConsultaCEP:BuscaCEPViaCEP(AllTrim(cCEP))
    oResposta :=  oConsultaCEP:GetResposta()

    lRetCep := ValidRetCep(oResposta,@lTAS, lTASConfig)    

    If !lRetCep .AND. lTAS .AND. lTASConfig
        oConsultaCEP:BuscaCEPTAS(AllTrim(cCEP))
        oResposta :=  oConsultaCEP:GetResposta()

        lRetCep := ValidRetCep(oResposta,,lTASConfig)
    EndIF

    // Preenche os dados do endereço com base no CEP
    If lRetCep
        
        oModeAct      := FWModelActive()

        oModeAct:SetValue( 'SA1MASTER', 'A1_CEP'      ,oResposta["Endereco"][1]["cep"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_END'      ,oResposta["Endereco"][1]["logradouro"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_BAIRRO'   ,oResposta["Endereco"][1]["bairro"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_EST'      ,oResposta["Endereco"][1]["uf"])
        oModeAct:SetValue( 'SA1MASTER', 'A1_PAIS'     ,"105" )         
        oModeAct:SetValue( 'SA1MASTER', 'A1_DDD'      ,oResposta["Endereco"][1]["ddd"])

        If !Empty(oResposta["Endereco"][1]["cidade"])
            oModeAct:SetValue( 'SA1MASTER', 'A1_MUN'      ,oResposta["Endereco"][1]["cidade"])
        EndIf

        oModeAct:SetValue( 'SA1MASTER', 'A1_COD_MUN'  ,SubStr(oResposta["Endereco"][1]["ibge"],3,5)) 
        
        If oResposta["Endereco"][1]:hasproperty('complemento')
            oModeAct:SetValue( 'SA1MASTER', 'A1_COMPLEM' , oResposta["Endereco"][1]["complemento"] )
        EndIf       

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

    If "200 OK" $ oResposta['Error'][1]['Mensagem'] .OR. "400" $ oResposta['Error'][1]['Mensagem']
        cMsgError := STR0038 // "CEP Inválido"
    EndIf

    Iif(!("200 OK" $ oResposta['Error'][1]['Mensagem'] .OR. "400" $ oResposta['Error'][1]['Mensagem']),lTAS := .T.,)  // Usa API do TAS como contingencia
    
    OmsMsgTime(cMsgError,5)
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

If At( "@", cEmailDig, 1) > 0
    oModel:SetValue( 'SA1MASTER', 'A1_EMAIL'    , cEmailDig )
    oModel:SetValue( 'SA1MASTER', 'A1_DOMMAIL'  , "" )
ElseIf !Empty(cDominio)
    oModel:SetValue( 'SA1MASTER', 'A1_EMAIL'    , cEmailDig + cDominio )
EndIf

Return

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
Local bAcBtPesq		:= {|| PesqSA1(cCliente, cRealName, cAliasSA1) }
Local aPrincipal    := FWGetDialogSize(oMainWnd)
Local aCliente		:= {}												                            //Retorno do cliente selecionado	

Local nLinFim       := 27
Local nColFim       := 100
Local nLinBot       := 178
Local aHeaderSA1    := {}
Local lCliBloq      := .F.                                          //Controla se o cliente está bloqueado
Local bBtOk         := {|| aCliente := AcaoBot("OK" , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA, @lCliBloq), Iif(!lCliBloq,oDlg:End(),) }
Local bBtFecha      := {|| lBtFecha := .T.,  aCliente := AcaoBot("F" , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA), oDlg:End() }
Local lBtFecha      := .F.                                                                          //Controla o fechamento da tela

Local cCliPad       := Upper( AllTrim( SuperGetMV("MV_CLIPAD",,) ) ) + " " + Upper( AlLTrim( SuperGetMV("MV_LOJPAD",,) ) )
Local cCliTela      := Upper(AlLTrim(M->LQ_CLIENTE)) + " " + Upper(AlLTrim(M->LQ_LOJA))
Local lCliPad       := cCliPad == cCliTela

//Cria tabela temporária auxiliar da pesquisa
aHeaderSA1  := {{"A1_FILIAL"    , "C" , TAMSX3("A1_FILIAL")[1]  , 0 },;
                {"A1_COD"       , "C" , TAMSX3("A1_COD")[1]     , 0 },;
                {"A1_LOJA"      , "C" , TAMSX3("A1_COD")[1]     , 0 },;
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
@ 05,40  MSGET o_Get1 VAR cCliente Picture("@!") ON CHANGE (PesqSA1(cCliente, cRealName, cAliasSA1)) Of oDlg PIXEL SIZE C(210),C(10)
o_Get1:cPlaceHold := STR0008 //"Digite para pesquisar o produto..."

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

// Pesquisar
oButPesq := TButton():New( 006, 318, STR0007,oDlg,bAcBtPesq, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Pesquisar"

oButVisua 	:= TButton():New( nLinBot, 197, STR0014  ,oDlg ,{|| AcaoBot("V"  , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Visualizar"
oButInclu 	:= TButton():New( nLinBot, 231, STR0015  ,oDlg ,{|| AcaoBot("I"  , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Incluir"
oButAlter 	:= TButton():New( nLinBot, 267, STR0016  ,oDlg ,{|| AcaoBot("A"  , (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA) }  , 30,15,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Alterar"
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
Local cPesquisa := AllTrim(cPesquisar)
Local cPesq		:= " "
Local cQry      := ""
Local cCampos	:= ""
Local cDelete 	:= ""
Local cInsert   := ""
Local cStatement:= "" 

Default lCliLoja := .F.
Default cCliente := ""
Default cLoja    := ""

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
    cQry += " AND SA1.A1_COD   = '" + AllTrim(cCliente) + "'"
    cQry += " AND SA1.A1_LOJA  = '" + AllTrim(cLoja) + "'"
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
cQry += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_CGC" 

cDelete 	:= " DELETE FROM " + cRealName +";" + chr(10)
cInsert 	:= " INSERT INTO " + cRealName + " ( " +cCampos+" ) " + cQry + ";" + chr(10)
cStatement 	:= cDelete + cInsert

//Executa dois comandos (DELETE/INSERT) de uma só vez para diminuir I/O no banco de dados
nStatus := TCSqlExec( cStatement )

If nStatus == 0
	Dbselectarea(cAliasSA1)
	(cAliasSA1)->(DbGotop())
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
@param cAcao, Caracter, Ação do botão (A- Alterar, I- Incluir, V- Visualizar, OK- Retorna o cliente selecionado)
@param cCod, Caracter, Código do cliente    
@param cLoja, Caracter, Loja do cliente 
/*/
Static Function AcaoBot(cAcao, cCod, cLoja, lCliBloq)
Local aCliente	    := {"",""}
Local nSA1Recno     := 0
Local lChamaTela    := .T.
Local cCliOld       := SA1->A1_COD
Local cLojaOld      := SA1->A1_LOJA

If AllTrim(cAcao) $ "A/V/F/OK" .AND. (Empty(cCod) .AND. Empty(cLoja))
    If  AllTrim(cAcao) $ "F/OK"
        aCliente[1] := SA1->A1_COD
        aCliente[2] := SA1->A1_LOJA
    EndIf
    lChamaTela := .F.
EndIf

If lChamaTela
    SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
    SA1->(dbSeek( xFilial("SA1") + PadR(cCod,TamSX3("A1_COD")[1]) + PadR(cLoja,TamSX3("A1_COD")[1]) ))    

    If lA1MSBLSQ .AND. AllTrim(cAcao) $ "OK/F" .AND. SA1->A1_MSBLQL == "1"
        // Registro bloqueado para uso
        If AllTrim(cAcao) == "OK"
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
            Case Upper(cAcao) == "OK"
                If !Empty(cCod)
                    aCliente[1] := cCod
                    aCliente[2] := cLoja
                EndIf
            Case Upper(cAcao) == "V"  //Visualizar
                LJCADCLI("V", nSA1Recno)        
            Case Upper(cAcao) == "I"  //Incluir
                LJCADCLI("I", nSA1Recno)        
            Case Upper(cAcao) == "A"  //Alterar
                LJCADCLI("A", nSA1Recno)    
        End Case
    EndIf
EndIf

Return aCliente

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
/*/
Static Function GetProfile()

Pergunte("LJCADCLIAP",.F.)

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
