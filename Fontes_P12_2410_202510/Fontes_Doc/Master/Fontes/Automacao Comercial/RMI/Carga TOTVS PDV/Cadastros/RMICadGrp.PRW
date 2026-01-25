#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RMICADGRP.CH'
#INCLUDE "FWEDITPANEL.CH"

Static cCodAss      := padR("TOTVS PDV", tamSx3("MHP_CASSIN")[1])
Static cQtdMxLote   := "500"

Static lStRmixFil   := existFunc("rmixFilial")                      //Verifica se existe a função que vai retornar as filiais
Static cStCmpFil    := iif(lStRmixFil, "MHP_LAYFIL", "MHP_FILPRO")  //Campo com as filiais utilizadas para processamento
Static cStFilTela   := iif(lStRmixFil, "FILIAIS"   , "MIR_FILCAR")  //Campo com as filiais para apresentação em tela

/*/{Protheus.doc} RMICadGrp
Cadastro de Grupo de Tabelas (Processos)
@author joao.marcos
@since 09/02/2024
@version V12
/*/
Function RMICadGrp()
Local oBrowse

Private aRotina := MenuDef()

If (FWModeAccess("MIR",1) == "C" .AND. FWModeAccess("MIR",2) == "C" .And. FWModeAccess("MIR",3) == "C") .AND.;
   (FWModeAccess("MHN",1) == "C" .AND. FWModeAccess("MHN",2) == "C" .And. FWModeAccess("MHN",3) == "C") .AND.;
   (FWModeAccess("MHP",1) == "C" .AND. FWModeAccess("MHP",2) == "C" .And. FWModeAccess("MHP",3) == "C") .AND.;
   (FWModeAccess("MHO",1) == "C" .AND. FWModeAccess("MHO",2) == "C" .And. FWModeAccess("MHO",3) == "C")
    If AmIIn(12) // Acesso apenas para modulo e licença do Varejo
        // Valida os Grupos padroes
        RMIVldGrPd()

        oBrowse := FWmBrowse():New()
        oBrowse:SetAlias( "MIR" )
        oBrowse:SetDescription( STR0001 ) // "Grupo de Tabelas"

        // Legenda
        oBrowse:AddLegend( "AllTrim(MIR->MIR_ATIVO) == '1'", "GREEN", "Grupo Ativo",     "1" )
        oBrowse:AddLegend( "AllTrim(MIR->MIR_ATIVO) == '2'", "RED",   "Grupo não Ativo", "1" ) 

        oBrowse:Activate()
    Else
        MsgAlert(STR0002) // "Esta rotina só pode ser utilizada pelo módulo Controle de Lojas (SIGALOJA)"
    EndIf
Else
    MSgAlert(STR0003) // "A Empresa, Unidade de Negócio e Filial da tabela MIQ devem estar em modo compartilhado"
EndIf

Return NIL

/*/{Protheus.doc} MenuDef
Menu
@type Static Function
@author joao.marcos
@since 08/02/2024
@version V12
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title "Visualizar"  Action "VIEWDEF.RMICadGrp" OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"     Action "VIEWDEF.RMICadGrp" OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"     Action "VIEWDEF.RMICadGrp" OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"     Action "VIEWDEF.RMICadGrp" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ViewDef
Estrutura a View da Tela
@type  Static Function
@author joao.marcos
@since 08/02/2024
@version V12
/*/
Static Function ViewDef()
Local oModel        := FWLoadModel( "RMICadGrp" )
Local oView
Local oStruMIR      := FWFormStruct( 2, "MIR" )
Local oStruMHN      := FWFormStruct(2, "MHN", {|cField| !(AllTrim(Upper(cField)) $ "MHN_COD|MHN_CODGRP") })
Local cCampsGrid    := "MHN_TABELA|MHN_CHAVE|MHN_ATIVO" // Campos que serao apresentados do Grid
Local aCpoRemove    := {}                               // array com os campos a serem  removidos do Model
Local nX            := 0
Local aComboValues  := {"1=Sim","2=Não"}

oStruMIR:RemoveField('MIR_FILIAL')

if lStRmixFil
    oStruMIR:removeField("MIR_FILCAR")
    campofilial(oStruMIR, .T.)
endIf

For nX := 1 To Len(oStruMHN:aFields)
    If !(AllTrim(oStruMHN:aFields[nX][1]) $ cCampsGrid)
        AADD(aCpoRemove,AllTrim(oStruMHN:aFields[nX][1]))
    EndIf
Next
/*
|| Foi preciso fazer com dois For porque ao dar o RemoveField, alterava o Len do array aFields, 
|| impossibilitando o controle
*/
For nX := 1 To Len(aCpoRemove)
    oStruMHN:RemoveField(aCpoRemove[nX])
Next

oStruMHN:AddField( "MHN_ATIVO","08","Ativa?","Tabela ativa para geração de Integração.",/*aHelp*/,"COMBO",/*cPicture*/, /*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,aComboValues,/*nMaxLenCombo*/,/*cIniBrow 15*/,/*lVirtual*/.T.,/*cPictVar*/,/*lInsertLine*/,/*nWidth*/ ) //,,,,.F.,,,,,,.T. )
oStruMHN:SetProperty('MHN_ATIVO',  MODEL_FIELD_INIT  , {||IniMHNAtv(oStruMIR,oStruMHN)} )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "VIEW_MIR", oStruMIR, "MIRMASTER" )

oView:AddGrid( "VIEW_MHN", oStruMHN, "MHNDETAIL", /*uParam4*/, /*bGotFocus*/, /*bLostFocus*/ )
oView:CreateHorizontalBox( "GRUPO", 40 )
oView:CreateHorizontalBox( "TABELAS", 60 )
oView:SetOwnerView( "VIEW_MIR", "GRUPO" )
oView:SetOwnerView( "VIEW_MHN", "TABELAS" )

Return oView

/*/{Protheus.doc} ModelDef
Estrutura o Model
@type  Static Function
@author joao.marcos
@since 08/02/2024
@version V12
/*/
Static Function ModelDef()
Local oStruMIR  := FWFormStruct( 1, "MIR", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruMHN  := FWFormStruct( 1, "MHN", /*bAvlCpoMHN*/, /*lViewUsado*/ )
Local bPosValid := {|| CdGrpPoVld() }
Local bPreValid := {|| CadGrpPVld() }
Local bCommit   := {|oModel| CadGrpComt() }
Local oModel    :=  MPFormModel():New( "RMICadGrp_M", bPreValid, bPosValid, bCommit, /*bCancel*/ ) 
Local bPreVal   := {|oGridModel, nLine, cAction, cIdField, xValue, xCurrentValue| LinePreVal(oGridModel, nLine, cAction, cIdField, xValue, xCurrentValeu)}
Local aGatilhos := {}
Local nX        := 0

if lStRmixFil
    campofilial(oStruMIR, .F.)
endIf

oModel:SetDescription( STR0001 ) // "Grupo de Tabelas"
oModel:AddFields( "MIRMASTER", /*cOwner*/, oStruMIR )   

oModel:SetPrimaryKey( {"MIR_FILIAL", "MIR_COD"} )
oModel:AddGrid( "MHNDETAIL", "MIRMASTER", oStruMHN, /*bLinePre*/, /*bLinePost*/, bPreVal, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation( "MHNDETAIL", { { "MHN_FILIAL", "MIR_FILIAL" },;
                                   { "MHN_CODGRP", "MIR_COD" } ;
                                 },;
                                 MHN->( IndexKey( 4 ) ) ) 

oStruMHN:AddField(  "Ativa?",;                                                // [01] C Titulo do campo
                    "Geração de Integração ativa para esta tabela? ",;        // [02] C ToolTip do campo
                    "MHN_ATIVO",;                                             // [03] C identificador (ID) do Field
                    "C",;                                                     // [04] C Tipo do campo
                    1,;                                                       // [05] N Tamanho do campo
                    0,;                                                       // [06] N Decimal do campo
                    FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"/*VldMhnAtv(oModel,oStruMIR,oStruMHN)*/),;    // [07] B Code-block de validação do campo
                    FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"),;     // [08] B Code-block de validação When do campo
                    {"1","2"},;                                               // [09] A Lista de valores permitido do campo
                    .F.,;                                                     // [10] L Indica se o campo tem preenchimento obrigatório
                    /*{||IniMHNAtv(oStruMIR,oStruMHN)}*/,;                        // [11] B Code-block de inicializacao do campo
                    .F.,;                                                     // [12] L Indica se trata de um campo chave
                    .F.,;                                                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                    .T.,;                                                     // [14] L Indica se o campo é virtual
                    "")

oStruMHN:AddField(  "Controle",;        // [01] C Titulo do campo
                    "Controle",;        // [02] C ToolTip do campo
                    "MHN_CONTR",;       // [03] C identificador (ID) do Field
                    "C",;               // [04] C Tipo do campo
                    1,;                 // [05] N Tamanho do campo
                    0,;                 // [06] N Decimal do campo
                    Nil,;               // [07] B Code-block de validação do campo
                    Nil,;               // [08] B Code-block de validação When do campo
                    Nil,;               // [09] A Lista de valores permitido do campo
                    Nil,;               // [10] L Indica se o campo tem preenchimento obrigatório
                    Nil,;               // [11] B Code-block de inicializacao do campo
                    Nil,;               // [12] L Indica se trata de um campo chave
                    Nil,;               // [13] L Indica se o campo pode receber valor em uma operação de update.
                    .T.)               // [14] L Indica se o campo é virtual

oStruMIR:SetProperty('MIR_COD',     MODEL_FIELD_INIT    , {|oStruMIR| RMISetCGrp()} )
oStruMIR:SetProperty("MIR_FILCAR",  MODEL_FIELD_VALID   , {|oStruMIR| VldFilCar(oStruMIR)} )

oStruMHN:SetProperty('MHN_ATIVO',  MODEL_FIELD_INIT , {||IniMHNAtv(oStruMIR,oStruMHN)} )

oStruMHN:SetProperty('MHN_COD',     MODEL_FIELD_OBRIGAT , .F. )
oStruMHN:SetProperty('MHN_CHAVE',   MODEL_FIELD_OBRIGAT , .F. )
oStruMHN:SetProperty('MHN_CODGRP',  MODEL_FIELD_OBRIGAT , .F. )

oStruMIR:SetProperty( "MIR_COD", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F.") )

//Adicionando gatilho
aAdd(aGatilhos, FWStruTriggger( "MHN_TABELA"    ,;  //Campo Origem
                                "MHN_CHAVE"     ,;  //Campo Destino
                                "RMIX2Unico()"  ,;  //Regra de Preenchimento
                                .F.             ,;  //Irá Posicionar?
                                ""              ,;  //Alias de Posicionamento
                                0               ,;  //Índice de Posicionamento
                                ''              ,;  //Chave de Posicionamento
                                NIL             ,;  //Condição para execução do gatilho
                                "01")           ;   //Sequência do gatilho    
                                )

For nX := 1 To Len(aGatilhos)
    oStruMHN:AddTrigger( aGatilhos[nX][01],; //Campo Origem
                        aGatilhos[nX][02],; //Campo Destino
                        aGatilhos[nX][03],; //Bloco de código na validação da execução do gatilho
                        aGatilhos[nX][04])  //Bloco de código de execução do gatilho
Next

oModel:GetModel( 'MHNDETAIL' ):SetUniqueLine( { 'MHN_TABELA' } )
oModel:GetModel( 'MIRMASTER' ):SetDescription( STR0001 ) // 'Grupo de Tabelas'
oModel:GetModel( 'MHNDETAIL' ):SetDescription( STR0004 ) // 'Tabelas do Grupo de Integração' // Processos

Return oModel

/*/{Protheus.doc} IniMHNAtv
Retorna o valor de inicializaçao do campo virtual MHN_ATIVO
@type  Static Function
@author joao.marcos
@since 13/05/2024
@version 1.0
@param  oStruMIR, Object, Estrutura do cabeçalho
        oStruMHN, Object, Estrutura do grid
@return 
/*/
Static Function IniMHNAtv(oStruMIR,oStruMHN)
Local cVlrInicia    := "1=Sim"
Local oModel        := FWModelActive()
Local nOperation    := 0
Local cCodProcss    := ""
Local aAreaMHP := MHP->(GetArea())

If ValType(oModel) == "O"
    nOperation    := oModel:GetOperation()    
Else
    nOperation := 4
Endif

MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO

If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE

    cCodProcss    := AllTrim(MIR->MIR_COD) + AllTrim(MHN->MHN_TABELA)

    If MHP->( dbSeek( xFIlial("MHP") + PadR(cCodAss,TamSx3("MHP_CASSIN")[1]) + cCodProcss ) )
        cVlrInicia := Iif(MHP->MHP_ATIVO == "1", "1=Sim", "2=Não")
    EndIf
EndIf

RestArea(aAreaMHP)

Return cVlrInicia

/*/{Protheus.doc} VldFilCar
Valida os dados informados no campo MIR_FILCAR
@type  Static Function
@author joao.marcos
@since 13/05/2024
@version 1.0
@return lRet, Logical, retorno da validação
/*/
Static Function VldFilCar(oStruMIR)
Local lRet          := .F.
Local cFilCarDig    := AllTrim( oStruMIR:GetValue("FILIAIS") ) // Filiais digitadas pelo usuario
Local aFiliais      := FWAllFilial(,,cEmpAnt,.F.)   // Filiais do ambiente
Local aFilCarDig    := StrToArray(cFilCarDig,";")   // Array com as filiais para Integração informadas no campo MIR_FILCAR
Local nX            := 0
Local nY            := 0

If ";;" $ cFilCarDig
    lRet := .F.
Else
    lRet := .T.
EndIf

If lRet

    lRet := .F. 

    For nX := 1 To Len(aFilCarDig)
        lRet := .F.
        For nY := 1 To Len(aFiliais)            
            If AllTrim(aFilCarDig[nX]) == AllTrim(aFiliais[nY])
                lRet := .T.
            EndIf
        Next

        If !lRet .AND. nX <= Len(aFilCarDig)
            lRet := .F.
        EndIf
    Next 
EndIf

If SubStr(cFilCarDig,Len(cFilCarDig)) == ";"
    cFilCarDig := ""
    For nX := 1 To Len(aFilCarDig)
        cFilCarDig += aFilCarDig[nX] + ";"
    Next

    cFilCarDig := SubStr(cFilCarDig,1,Len(cFilCarDig)-1)
    oStruMIR:LoadValue("MIR_FILCAR", AllTrim(cFilCarDig) )
    lRet := .T.
ElseIf lRet .AND. Len(aFilCarDig) == 1
    oStruMIR:LoadValue("MIR_FILCAR", AllTrim(aFilCarDig[1]) )
EndIf

Return lRet

/*/{Protheus.doc} RMISetCGrp
Retorna o proximo codigo do grupo MIR_COD
@type  Function
@author joao.marcos
@since 06/05/2024
@version 1.0
@return cRet, Character, proximo codigo a ser utilizado
/*/
Function RMISetCGrp()
Local cRet      := ""
Local cQuery    := ""
Local cAliasMHN := ""

cQuery += " SELECT MAX(MIR_COD) MHN_PROXCOD  "
cQuery += " FROM " + RetSQLName("MIR")
cQuery += " WHERE MIR_FILIAL = '" + xFilial("MIR") + "' "
cQuery += " AND MIR_COD <> '999' "
cQuery += " AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
cAliasMHN := MPSysOpenQuery(cQuery)

cRet := Soma1((cAliasMHN)->MHN_PROXCOD)

Return cRet

/*/{Protheus.doc} CadGrpPVld
Faz as validações antes da abertura da tela
@type  Static Function
@author joao.marcos
@since 09/04/2024
@version 1.0
@param param_name, param_type, param_descr
@return lRet, logico, retorno da validaçao
/*/
Static Function CadGrpPVld()
Local lRet := .T.
Local oModel        := FWModelActive()
Local nOperation    := oModel:GetOperation()        // Operaçao em andamento (Inclusão/Alteracçao/Exclusao)
Local cCodGrupo     := oModel:GetValue("MIRMASTER","MIR_COD")

If cCodGrupo == "999" .AND. nOperation <> MODEL_OPERATION_VIEW
    MSGInfo(STR0017) // "O grupo 999 é específico para utilização na Integração Manual, não pode ser Alterado ou Excluído"
    lRet := .F.
EndIf
    
Return lRet

/*/{Protheus.doc} LinePreVal
Pre validacao dos dados do model
@type  Static Function
@author joao.marcos
@since 19/02/2024
@version V12
@param  oGridModel, objeto,     objeto do Grid
        nLine,      numerico,   numero da inha em ediçao
        cAction,    caracter,   açao que esta sendo tomada (SETVALUE/DELETE/UNDELETE)
        cIdField,   caracter,   id do ampo em ediçao
        xValue,     indefinido, Valor digitado
        xCurrentValue, indefinido,  valor atual do campo
@return lRet,   Logico, Se permite ou não os dados informados na linha
/*/
Static Function LinePreVal(oGridModel, nLine, cAction, cIdField, xValue, xCurrentValue)
Local oModel        := FWModelActive()
Local nOperation    := oModel:GetOperation()        // Operaçao em andamento (Inclusão/Alteracçao/Exclusao)
Local lRet          := .T.
Local oModelGrid    := oModel:GetModel('MHNDETAIL')

oModelGrid:GoLine(nLine)

If !( "CANSETVALUE" $ AllTrim(cAction) ) .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )
    
    If "SETVALUE" $ AllTrim(cAction) .AND. !Empty(xValue)
        If "MHN_TABELA" $ ReadVar()
            lRet := RMIVldTabL( oModel:GetValue("MIRMASTER","MIR_COD"), xValue, oModelGrid, cAction )
        ElseIf "MHN_CHAVE" $ ReadVar()
            lRet := ValidChave(oModelGrid:GetValue("MHN_TABELA"), @xValue)
        ElseIf "MHN_ATIVO" $ ReadVar()
            If xValue == "1"
                lRet := RMITabAtv(oModel, oGridModel)
            ElseIf xValue == "2" .AND.  Empty( oModelGrid:GetValue("MHN_TABELA") )
                xValue := "1"
            EndIf
        EndIf
    ElseIF "DELETE" == AllTrim(cAction)
        If Empty( oModelGrid:GetValue("MHN_TABELA") )
            lRet := .T.
        Else
            If RMIVldTabL( oModel:GetValue("MIRMASTER","MIR_COD"), xValue, oModelGrid, cAction )    
                lRet := .T.  
            Else    
                MSGInfo(STR0019) // "Não é possivel deletar a tabela do grupo, altere o campo Ativo (MHN_ATIVO) para desativar a tabela, com isso não será mais gerada integração desta tabela."
                lRet := .F.
            EndIf
        EndIf
    ElseIf "UNDELETE" $ AllTrim(cAction)
        MSGAlert(STR0005) // "Não é possível reverter uma linha deletada, inclua uma nova linha."
        lRet := .F.
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} RMITabAtv
Validaçao quando alterado o campo MHN_ATIVO para '1', para verificar se a tabela não existe ativa em outro grupo
@type  Static Function
@author joao.marcos
@since 10/05/2024
@version 1.0
@param  oModel,  objeto, model do head
#param  oGridModel, objeto, model do grid
@return lRet, logico, alteraçao valida ou nao
/*/
Static Function RMITabAtv(oModel, oGridModel)
Local lRet      := .T.
Local aAreaMHN  := MHN->( GetArea() )
Local cTabela   := AllTrim( oGridModel:GetValue("MHN_TABELA") )
Local cCodGrupo := AllTrim(oModel:GetValue("MIRMASTER","MIR_COD"))
Local aAreaMHP      := MHP->(GetArea())

MHN->(dbSetOrder(2)) // MHN_FILIAL+MHN_TABELA
MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO

If MHN->( dbSeek(xFilial("MHN") + cTabela ) )    

    While MHN->(!EOF()) .AND. AlLTrim(MHN->MHN_TABELA) == cTabela

        MHP->( dbSeek( xFilial("MHP") + PadR(cCodAss,TamSx3("MHP_CASSIN")[1]) + MHN->MHN_COD ) )
        If MHP->MHP_ATIVO == "1" .AND. AllTrim(MHN->MHN_CODGRP) <> cCodGrupo
            lRet := .F.
            Exit
        EndIf

        MHN->(dbSkip())

    EndDo

    If !lRet
        MSGAlert(STR0006 + cTabela + STR0021 + MHN->MHN_CODGRP + ".") // "A tabela " # " esta ativa no grupo "
    EndIf

EndIf

RestArea(aAreaMHN)
RestArea(aAreaMHP)

Return lRet

/*/{Protheus.doc} RMIVldTabL
Valida tabela digitada na linha
@type  Static Function
@author joao.marcos
@since 19/02/2024
@version V12
@param  cCodGrupo,  caracter, Codigo do grupo
        cTabela,    caracter, Alias da tabela digitada
@return lRet, logico, aceito ou negaçao da validaçao
/*/
Static Function RMIVldTabL(cCodGrupo, cTabela, oModelGrid, cAction)
Local lRet      := .T.
Local aAreaMHN  := MHN->( GetArea() )
Local aAreaMHP  := MHP->( GetArea() )

MHN->(dbSetOrder(2)) // MHN_FILIAL+MHN_TABELA
MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO

If "DELETE" $ AllTrim(cAction) 
    If MHP->( dbSeek( xFilial("MHP") + PadR(cCodAss,TamSX3("MHP_CASSIN")[1]) + AllTrim(oModelGrid:GetValue("MHN_COD")) ) )
        lRet := .F.
    EndIf
ElseIf "SETVALUE" $ AllTrim(cAction)    

    If MHN->( dbSeek(xFilial("MHN") + cTabela ) )
        While MHN->(!EOF()) .AND. MHN->MHN_FILIAL == xFilial("MHN") .AND. AllTrim(MHN->MHN_TABELA) == AllTrim(cTabela)

            MHP->( dbSeek( xFilial("MHP") + PadR(cCodAss,TamSX3("MHP_CASSIN")[1]) + AllTrim(MHN->MHN_COD) ) )

            // Valida se a tabela ja esta cadastrada em outro grupo
            If !Empty(MHN->MHN_CODGRP) .AND. MHP->MHP_ATIVO == "1" .AND. AllTrim(MHN->MHN_CODGRP) <> AllTrim(cCodGrupo)
                lRet := .F.
                Exit
            EndIf

            MHN->(dbSkip())

        EndDo

        If !lRet
            MSGAlert(STR0006 + cTabela + STR0007 + MHN->MHN_CODGRP + ".") // "A tabela " # " já pertence ao grupo "
        EndIf
    EndIf

EndIf

RestArea(aAreaMHN)
RestArea(aAreaMHP)

Return lRet

/*/{Protheus.doc} CdGrpPoVld
Pos validação do Model
Dispara a geração dos registros de Assinante (MHO) e Assinante x Processos (MHP)
@type  Static Function
@author joao.marcos
@since 09/02/2024
@version V12
@param oModel, objeto, Model da tela
@return lRet, logico, retorno da validaçao
/*/
Static Function CdGrpPoVld(oModel)
Local lRet          := .T.
Local oModel        := FWModelActive()
Local nOperation    := oModel:GetOperation()        // Tipo da operação - Inclusao, Alteraçao, Exclusao    
Local cCodGrupo     := AllTrim( oModel:GetValue("MIRMASTER","MIR_COD") )
Local oModelGrid    := oModel:GetModel('MHNDETAIL')
Local cCodProcss    := ""                           // Codigo do processo (MHN)
Local nX            := 0
Local aTabelas      := {}

LjGrvLog("RMICadGrp", "CdGrpPoVld -  Inicio.", )

// Verifica se existe o assiante TOTVS PDV e Inclui Assinante caso não exista
If Empty( GetAdvFVal( "MHO", "MHO_COD", xFilial("MHO") + cCodAss, 1, "" ) )
    RMIInclAss(cCodAss)
EndIf

If cCodGrupo == "999"
    lRet := .F.
ElseIf nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If lRet

        Begin Transaction    

        For nX := 1 To oModelGrid:Length()
        
            oModelGrid:GoLine(nX) 

            If lRet .AND. !Empty(oModelGrid:GetValue("MHN_TABELA"))                  
                    
                If !oModelGrid:IsDeleted() .AND. ( oModelGrid:IsUpdated() .OR. oModelGrid:IsInserted() )
                    
                    cCodProcss  := AllTrim( oModel:GetValue("MIRMASTER","MIR_COD") ) + AllTrim( oModelGrid:GetValue("MHN_TABELA") ) // Codigo do processo é formado pelo Codigo do Grupo e o Alias da Tabela
                    cFilProc    := AllTrim(oModel:GetValue("MIRMASTER", cStFilTela))

                    // Define o codigo do processo
                    oModelGrid:LoadValue("MHN_COD",cCodProcss)

                    // Inclui Assinante x Processo (MHP) se a tabela estiver ativa
                    If oModelGrid:GetValue("MHN_ATIVO") == "1"
                        RMIAssProc(cCodAss, cCodProcss, oModel:GetValue("MIRMASTER","MIR_ATIVO"), cFilProc, "1",,,,cFilProc)
                        AADD(aTabelas,{"",AllTrim( oModelGrid:GetValue("MHN_TABELA"))})
                    EndIf                     
                EndIf

            EndIF

        Next

        If nOperation == MODEL_OPERATION_UPDATE
            If oModel:GetValue("MIRMASTER","MIR_ATIVO") <> MIR->MIR_ATIVO
                // Ativa ou desativa grupo    
                RMIGrpAtiv(oModel:GetValue("MIRMASTER","MIR_COD"),oModel:GetValue("MIRMASTER","MIR_ATIVO"))
            EndIf
            RMIAtuFil( AllTrim(oModel:GetValue("MIRMASTER","MIR_COD")), AllTrim(oModel:GetValue("MIRMASTER", cStFilTela)) )
        EndIf

        End Transaction

        lRet := CriaStamp(aTabelas)  

    EndIf

ElseIf nOperation == MODEL_OPERATION_DELETE
    RMIDelPrAs(oModel)
    lRet := .T.
EndIf

LjGrvLog("RMICadGrp", "CdGrpPoVld -  Fim.", )

Return lRet

/*/{Protheus.doc} RMIAtuFil
Atualiza o campo MHP_FILPRO conforme a alteração do usuario
@type  Static Function
@author joao.marcos
@since 17/04/2024
@version 1.0
@param  cGrupoTab, character, Codigo do Grupo de Tabelas
        cFilInteg, character, Filiais selecionadas pelo usuario
/*/
Static Function RMIAtuFil( cGrupoTab, cFilInteg )
Local aAreaMHN := MHN->(GetArea())
Local aAreaMHP := MHP->(GetArea())

MHN->(dbSetOrder(4)) // MHN_FILIAL+MHN_CODGRP+MHN_TABELA
MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO

MHN->( dbSeek(xFilial("MHN") + cGrupoTab) )

While MHN->(!EOF()) .AND. AllTrim(MHN->MHN_CODGRP) == AllTrim(cGrupoTab)

    If MHP->( dbSeek( xFilial("MHP") + PadR(cCodAss,TamSX3("MHP_CASSIN")[1]) + MHN->MHN_COD ) )
        MHP->(RecLock("MHP",.F.))
            MHP->&(cStCmpFil) := strTran(cFilInteg, CRLF, "")
        MHP->(MsUnLock())
    EndIf    

    MHN->(dbSkip())
EndDo

RestArea(aAreaMHN)
RestArea(aAreaMHP)
Return

/*/{Protheus.doc} RMIDelPrAs
Delete Processo x Assinante, atrelado ao Processo da MHN
@type  Static Function
@author joao.marcos
@since 19/02/2024
@version V12
@param oModel, Objeto, model da tela
/*/
Static Function RMIDelPrAs(oModel)
Local oModel        := FWModelActive()
Local oModelGrid    := oModel:GetModel('MHNDETAIL')
Local cCodProcss    := ""                           // Codigo do Processo
Local aAreaMHP      := MHP->(GetArea())
Local nX            := 0

For nX := 1 To oModelGrid:Length()

    oModelGrid:GoLine(nX)
    cCodProcss :=  oModelGrid:GetValue("MHN_COD")
    MHP->(dbSetOrder(2)) // MHP_FILIAL+MHP_CPROCE+MHP_CASSIN
    If MHP->(dbSeek( xFilial("MHP") + PadR(cCodProcss,TamSx3("MHP_CPROCE")[1]) + PadR(cCodAss,TamSx3("MHP_CASSIN")[1]) ))
        MHP->(RecLock("MHP",.F.))
        MHP->(dbDelete())
        MHP->(MsUnlock())
    EndIf
    
Next

RestArea(aAreaMHP)
    
Return

/*/{Protheus.doc} RMIAssProc
Inclui cadastro de Assinante x Processo (MHP)
@type  Function
@author user
@since 14/02/2024
@version version
@param  cCodAss     , caracter  , MHP_CASSIN
        cCodProcss  , caracter  , MHP_CPROCE            
        cAtivo      , caracter  , MHP_ATIVO
        cTipo       , caracter  , MHP_TIPO
        cFilProc    , caracter  , MHP_FILPRO
        cConfig     , carcter   , MHP_CONFIG
        cLayEnv     , carcter   , MHP_LAYENV
        cLayPub     , caracter  , MHP_LAYPUB
        cLayFil     , carcater  , MHP_LAYFIL
@return lRet        , logico    , incluiu ou não os registros
/*/
Function RMIAssProc(cCodAss, cCodProcss, cAtivo, cFilProc, cTipo, cConfig, cLayEnv, cLayPub, cLayFil)
Local lRet          := .F.
Local aAreaMHP      := MHP->(GetArea())

Default cConfig := " "
Default cLayEnv := " " 
Default cLayPub := " " 
Default cLayFil := " "

If SubStr(cCodProcss,1,3) <> "999"

    MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO
    If !MHP->(dbSeek(xFilial("MHP") + PadR(cCodAss,TamSX3("MHP_CASSIN")[1]) + cCodProcss ))

        LjGrvLog("RMICadGrp", "RMIAssProc -  Inicio.", {cCodAss, cCodProcss, cAtivo, cFilProc, cTipo, cConfig, cLayEnv, cLayPub, cLayFil} )

        MHP->( RecLock("MHP",.T.) )
            MHP->MHP_FILIAL := xFilial("MHP")
            MHP->MHP_CASSIN := cCodAss
            MHP->MHP_CPROCE := cCodProcss
            MHP->MHP_ATIVO  := cAtivo
            MHP->&(cStCmpFil) := strTran(cFilProc, CRLF, "")
            MHP->MHP_TIPO   := cTipo
            MHP->MHP_CONFIG := cConfig
            MHP->MHP_LAYENV := cLayEnv
            MHP->MHP_LAYPUB := cLayPub
            MHP->MHP_LAYFIL := cLayFil
        MHP->(MsUnlock())

        lRet := .T.

    EndIf

EndIf

RestArea(aAreaMHP)

LjGrvLog("RMICadGrp", "RMIAssProc -  Fim.", )

Return lRet

/*/{Protheus.doc} RMIVldGrPd
Valida Grupos Padroes, e o Assinante TOTVS PDV, e caso nao exita faz a criação
@type  Function
@author joao.marcos
@since 09/02/2024
@version V12
/*/
Function RMIVldGrPd()

// Verifica se existe o assiante TOTVS PDV e Inclui Assinante caso não exista
If Empty( GetAdvFVal( "MHO", "MHO_COD", xFilial("MHO") + cCodAss, 1, "" ) ) 
    RMIInclAss(cCodAss)
EndIf

// Verifica se existe pelo menos um grupo cadastrado, caso nao exista faz o cadastro automático dos grupo padroes
If Empty( GetAdvFVal( "MIR", "MIR_COD", xFilial("MIR") + "001", 1, "" ) )
    RMIIncGrTP()    
ElseIf Empty( GetAdvFVal( "MHN", "MHN_TABELA", xFilial("MHN") + "F2B", 2, "" ) ) .And.;
    Empty( GetAdvFVal( "MHN", "MHN_TABELA", xFilial("MHN") + "F27", 2, "" ) ) .And.;
    Empty( GetAdvFVal( "MHN", "MHN_TABELA", xFilial("MHN") + "F28", 2, "" ) )
    
    LjGrpCFGTRIB() //Grupo Padrão Configurador de Tributos
EndIf

Return

/*/{Protheus.doc} RMIX2Unico
Retorna o X2_UNICO da tabela indicada
@type  joao.marcos
@author user
@since 09/02/2024
@version V12
@return X2_UNICO, caracter, X2_UNICO da tabela indicada
/*/
Function RMIX2Unico()
Local oModel        := FWModelActive()
Local oModelGrid    := oModel:GetModel('MHNDETAIL')
Local cTabela       := oModelGrid:GetValue("MHN_TABELA")
Local cIndexKey     := FWX2Unico(cTabela)

ValidChave(cTabela, @cIndexKey, .T.)

Return cIndexKey

/*/{Protheus.doc} RMIInclAss
Inclui cadastro de Assinante na tabela MHO caso nao exista
@type  Function
@author joao.marcos
@since 14/02/2024
@version V12
@param  cCodAss, caracter, codigo do Assinate
        cConfig, caracter, configuração do Assinante
        cToken, caracter, Token do assinante
@return lRet, logico, sucesso ou nao na gravaçao
/*/
Function RMIInclAss(cCodAss, cConfig, cToken)
Local lRet := .F.

Default cConfig := '{ "endpoint": "","usuario": "", "senha": "","access_token": "", "refresh_token": "", "nQtdMxLote":"' + cQtdMxLote + '", "GruposTabelas":"","rmiPublica":"","rmiDistrib":"","rmiEnvia":"" }'
Default cToken  := " "

LjGrvLog("RMICadGrp", "RMIInclAss -  Inicio.", )

If Empty( GetAdvFVal( "MHO", "MHO_COD", xFilial("MHO") + cCodAss, 1, "" ) )
    MHO->( RecLock("MHO",.T.) )
        MHO->MHO_COD    := cCodAss
        MHO->MHO_CONFIG := cConfig
        MHO->MHO_TOKEN  := cToken
    MHO->(MsUnlock())

    lRet := .T.
EndIf

LjGrvLog("RMICadGrp", "RMIInclAss -  Fim.", )

Return lRet

/*/{Protheus.doc} RMIIncGrTP
Inclui grupos de tabela padrao
@type  Function
@author joao.marcos
@since 15/02/2024
@version V12
/*/
Function RMIIncGrTP()
Local aGrupos   := {}                           // Grupos
Local aTabelas  := {}                           // Tabelas
Local aFiliais  := FWAllFilial(,,cEmpAnt,.F.)   // Filiais do sistema  FWLoadSM0()
Local cEmpresaAt:= FWCompany()
Local cFiliais  := ""                           // Filiais
Local nX        := 0
Local lGeraGrpPad   := .T.                      // Gera grupos padroes

LjGrvLog("RMICadGrp", "RMIIncGrTP -  Inicio.", )

If MsgYesNo(STR0038) // "Deseja que a rotina gere automaticamete os grupos de tabelas padrões?"
    lGeraGrpPad   := .T.
Else
    lGeraGrpPad   := .F.
EndIf

For nX := 1 To Len(aFiliais)
    If SubStr(aFiliais[nX],1,Len(cEmpresaAt)) == cEmpresaAt // So considera Filiais da empresa logada
        cFiliais += aFiliais[nX] + ";"
    EndIf
Next nX

cFiliais := SubStr(cFiliais,1,Len(cFiliais)-1)

If lGeraGrpPad
    // Grupos
    AADD(aGrupos,{"001","PRODUTO"                       ,cFiliais,"1"} )
    AADD(aGrupos,{"002","CLIENTE"                       ,cFiliais,"1"} )
    AADD(aGrupos,{"003","PREÇO"                         ,cFiliais,"1"} )
    AADD(aGrupos,{"004","TABELAS DIVERSAS"              ,cFiliais,"1"} )
    AADD(aGrupos,{"005","REGRA DE DESCONTO DO VAREJO"   ,cFiliais,"2"} )
    AADD(aGrupos,{"006","REGRA DE DESCONTO"             ,cFiliais,"2"} )
    AADD(aGrupos,{"007","MULTI NEGOCIAÇÃO"              ,cFiliais,"2"} )
    AADD(aGrupos,{"008","CRM BONUS"                     ,cFiliais,"2"} )
EndIf

AADD(aGrupos,{"999","INTEGRACAO MANUAL"             ,cFiliais,"1"} )

If lGeraGrpPad
    // Tabelas / Processos
    AADD(aTabelas,{"001SB1","SB1","B1_FILIAL+B1_COD"                    ,"2","001"} )   // 001
    AADD(aTabelas,{"001SBZ","SBZ","BZ_FILIAL+BZ_COD"                    ,"2","001"} )
    AADD(aTabelas,{"001SB5","SB5","B5_FILIAL+B5_COD"                    ,"2","001"} )
    AADD(aTabelas,{"002SA1","SA1","A1_FILIAL+A1_COD+A1_LOJA"            ,"2","002"} )   // 002
    AADD(aTabelas,{"002AI0","AI0","AI0_FILIAL+AI0_CODCLI+AI0_LOJA"      ,"2","002"} )
    AADD(aTabelas,{"003SB0","SB0","B0_FILIAL+B0_COD"                    ,"2","003"} )   // 003
    AADD(aTabelas,{"003DA0","DA0","DA0_FILIAL+DA0_CODTAB"               ,"2","003"} )
    AADD(aTabelas,{"003DA1","DA1","DA1_FILIAL+DA1_CODTAB+DA1_ITEM+DA1_CODPRO","2","003"} )
    AADD(aTabelas,{"003SBI","SBI","BI_FILIAL+BI_COD"                    ,"2","003"} )
    AADD(aTabelas,{"004SF4","SF4","F4_FILIAL+F4_CODIGO"                 ,"2","004"} )   // 004
    AADD(aTabelas,{"004SF7","SF7","F7_FILIAL+F7_GRTRIB+F7_SEQUEN"       ,"2","004"} )
    AADD(aTabelas,{"004SFM","SFM","R_E_C_N_O_"                          ,"2","004"} )    
    AADD(aTabelas,{"004SAE","SAE","AE_FILIAL+AE_COD"                    ,"2","004"} )
    AADD(aTabelas,{"004MEN","MEN","MEN_FILIAL+MEN_CODADM+MEN_ITEM"      ,"2","004"} )
    AADD(aTabelas,{"004SA3","SA3","A3_FILIAL+A3_COD"                    ,"2","004"} )
    AADD(aTabelas,{"004MDD","MDD","MDD_FILIAL+MDD_CODIGO"               ,"2","004"} )
    AADD(aTabelas,{"004SLJ","SLJ","LJ_FILIAL+LJ_CODIGO"                 ,"2","004"} )
    AADD(aTabelas,{"004SBM","SBM","BM_FILIAL+BM_GRUPO"                  ,"2","004"} )
    AADD(aTabelas,{"004MEU","MEU","MEU_FILIAL+MEU_CODIGO"                ,"2","004"} )
    AADD(aTabelas,{"004NNR","NNR","NNR_FILIAL+NNR_CODIGO"               ,"2","004"} )
    AADD(aTabelas,{"004SGQ","SGQ","GQ_FILIAL+GQ_TIPOPER+GQ_LOCAL+GQ_USER+GQ_GRPUSER+GQ_PRODUTO+GQ_GRPPROD","2","004"} )
    AADD(aTabelas,{"004ACU","ACU","ACU_FILIAL+ACU_COD"                  ,"2","004"} )
    AADD(aTabelas,{"004ACV","ACV","ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO+ACV_REFGRD","2","004"} )
    AADD(aTabelas,{"004SLK","SLK","LK_FILIAL+LK_CODBAR"                 ,"2","004"} )
    AADD(aTabelas,{"004SE4","SE4","E4_FILIAL+E4_CODIGO"                 ,"2","004"} )
    AADD(aTabelas,{"004SEC","SEC","EC_FILIAL+EC_CODIGO+EC_ITEM"         ,"2","004"} )
    AADD(aTabelas,{"004SA6","SA6","A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON","2","004"} )
    AADD(aTabelas,{"004SLF","SLF","LF_FILIAL+LF_COD"                    ,"2","004"} )
    AADD(aTabelas,{"004CLK","CLK","CLK_FILIAL+CLK_CODNCM+CLK_EX+CLK_CODNBS+CLK_UF+DTOS(CLK_DTINIV)+DTOS(CLK_DTFIMV)","2","004"} ) 
    AADD(aTabelas,{"005MEI","MEI","MEI_FILIAL+MEI_CODREG"               ,"2","005"} )   // 005
    AADD(aTabelas,{"005MEJ","MEJ","MEJ_FILIAL+MEJ_CODREG"               ,"2","005"} )
    AADD(aTabelas,{"005MB2","MB2","MB2_FILIAL+MB2_CODREG+MB2_REFGRD"    ,"2","005"} )
    AADD(aTabelas,{"005MB3","MB3","MB3_FILIAL+MB3_CODREG+MB3_CODEMP+MB3_CODFIL","2","005"} )
    AADD(aTabelas,{"005MB4","MB4","MB4_FILIAL+MB4_CODREG+MB4_CODFRM"    ,"2","005"} )
    AADD(aTabelas,{"005MB5","MB5","MB5_FILIAL+MB5_CODREG+MB5_CODPG"     ,"2","005"})
    AADD(aTabelas,{"005MB6","MB6","MB6_FILIAL+MB6_CODREG+MB6_ADMFIN"    ,"2","005"} )
    AADD(aTabelas,{"005MB7","MB7","MB7_FILIAL+MB7_CODREG"               ,"2","005"} )
    AADD(aTabelas,{"005MB8","MB8","MB8_FILIAL+MB8_CODREG+MB8_REFGRD"    ,"2","005"} )
    AADD(aTabelas,{"006ACO","ACO","ACO_FILIAL+ACO_CODREG"               ,"2","006"} )   // 006
    AADD(aTabelas,{"006ACP","ACP","ACP_FILIAL+ACP_CODREG+ACP_ITEM+ACP_CODPRO","2","006"} )
    AADD(aTabelas,{"007MBS","MBS","MBS_FILIAL+MBS_CODIGO"               ,"2","007"} )   // 007
    AADD(aTabelas,{"007MEK","MEK","MEK_FILIAL+MEK_CODIGO+MEK_PRODUT+MEK_GRPROD","2","007"} )
    AADD(aTabelas,{"007MBT","MBT","MBT_FILIAL+MBT_CODIGO+MBT_FORMPG+MBT_ADM+STR(MBT_MINPAR)+STR(MBT_PARCEL)","2","007"} )
    AADD(aTabelas,{"008MII","MII","MII_FILIAL+MII_PRODUT"               ,"2","008"} )   // 008
    AADD(aTabelas,{"008MIJ","MIJ","MIJ_FILIAL+MIJ_PRODUT+MIJ_LGCOD+MIJ_SIGLA","2","008"} )    
EndIf

AADD(aTabelas,{"999SX6","SX6","X6_FILIAL+X6_VAR","2","999"} )                       // 999
AADD(aTabelas,{"999SX5","SX5","X5_FILIAL+X5_TABELA+X5_CHAVE","2","999"} )

If lGeraGrpPad
    LjGrpCFGTRIB(lGeraGrpPad, cFiliais, @aGrupos, @aTabelas) //Grupo Padrão Configurador de Tributos
EndIf

Processa({|| RMIGrvGrpP(aGrupos,aTabelas,cFiliais)}, STR0010) // "Incluindo Grupos de Tabela Padrões..."

If lGeraGrpPad    
    MsgInfo(STR0020) // "Os grupos de tabelas padrões foram criados, agora é importante que seja feito a configuração para ativar ou desativar cada tabela conforme as necessidades do seu ambiente."
EndIf

FwFreeArray(aGrupos)
FwFreeArray(aTabelas)

LjGrvLog("RMICadGrp", "RMIIncGrTP -  Fim.", )
    
Return

/*/{Protheus.doc} RMIGrvGrpP
Grava os registros dos Grupos de Tabelas padrão
@type  Function
@author joao.marcos
@since 15/02/2024
@version V12
@param  aGrupos , array     , Relaçao de grupos padroes para serem gravados na tabela MIR
        aTabelas, array     , Relaçao de tabelas/Processos para serem gravados na MHN
        cFiliais, caracter  , Filiais
/*/
Function RMIGrvGrpP(aGrupos,aTabelas,cFiliais)
Local nCont := 0
Local aAreaMHN  := MHN->(GetArea())

// Cria campo STAMP
CriaStamp(aTabelas)

Begin Transaction

    ProcRegua(Len(aGrupos))
    // Grava os grupos (Cabeçalho)
    For nCont := 1 To Len(aGrupos)

        IncProc(STR0011 + aGrupos[nCont][1]) // "Incluindo Grupos padrões. Grupo "

        If !MIR->( Dbseek( xFilial("MIR") + PadR(aGrupos[nCont][1], TamSx3("MIR_COD")[1]) ) )

            RecLock("MIR", .T.)
                MIR->MIR_FILIAL := xFilial("MIR")
                MIR->MIR_COD    := aGrupos[nCont][1]
                MIR->MIR_DESCRI := aGrupos[nCont][2]
                MIR->MIR_FILCAR := aGrupos[nCont][3]
                MIR->MIR_ATIVO  := aGrupos[nCont][4]
            MIR->( MsUnLock() )

        EndIf

    Next nCont
    
    ProcRegua(Len(aTabelas))
    // Grava as tabelas (Processos)
    For nCont := 1 To Len(aTabelas)

        IncProc(STR0012 + aTabelas[nCont][2] ) // "Incluindo Tabelas padrões. Tabela "

        MHN->(dbSetOrder(2)) // MHN_FILIAL+MHN_TABELA
        If !( MHN->( Dbseek( xFilial("MHN") + IIF(AllTrim(aTabelas[nCont][1]) == "999SENHAS", "SEN", PadR(aTabelas[nCont][1], TamSx3("MHN_COD")[1]) ) ) ) .AND. !Empty(MHN->MHN_CODGRP) )

            RecLock("MHN", .T.)
                MHN->MHN_FILIAL := xFilial("MHN")
                MHN->MHN_COD    := aTabelas[nCont][1]
                MHN->MHN_TABELA := aTabelas[nCont][2]
                MHN->MHN_CHAVE  := aTabelas[nCont][3]
                MHN->MHN_CODGRP := aTabelas[nCont][5] 
                MHN->MHN_FILTRO := ""
                MHN->MHN_GATILH := ""                
            MHN->( MsUnLock() )            

            // Inclui Assinante x Processo (MHP)
            RMIAssProc(cCodAss, aTabelas[nCont][1], "1", cFiliais, "1",,,,cFiliais)

        EndIf
        
    Next nProc

End Transaction

RestArea(aAreaMHN)
FwFreeArray(aGrupos)
FwFreeArray(aTabelas)

Return

/*/{Protheus.doc} RMIGrpAtiv
Ativa ou desativa os processos do grupo
@type  Static Function
@author joao.marcos
@since 19/02/2024
@version V12
@param cCodGpr, caracter, Codigo do grupo
        cAtivo, caracter, Ativo "1" ou Nao Ativo "2"
/*/
Static Function RMIGrpAtiv(cCodGpr, cAtivo)
Local aAreaMHN := MHN->(GetArea())
Local aAreaMHP := MHP->(GetArea())

MHN->(dbGoTop())
MHN->(dbSetOrder(4)) // MHN_FILIAL+MHN_CODGRP+MHN_TABELA                                                                                                                        
MHN->( dbSeek(xFilial("MHN") + cCodGpr ) )

MHP->(dbGoTop())
MHP->(dbSetOrder(2)) // MHP_FILIAL+MHP_CPROCE+MHP_CASSIN                                                                                                                                     

While MHN->(!EOF()) .AND. MHN->MHN_CODGRP == cCodGpr

    If MHP->( dbSeek(xFilial("MHP") + MHN->MHN_COD ) )
        MHP->( RecLock("MHP",.F.) )
        MHP->MHP_ATIVO  := cAtivo
        MHP->(MsUnlock())
    EndIf

    MHN->(dbSkip())
EndDo

RestArea(aAreaMHN)
RestArea(aAreaMHP)

Return

/*/{Protheus.doc} CadGrpComt
Tratativas no Commit do Model
@type  Static Function
@author joao.marcos
@since 03/05/2024
@version 1.0
/*/
Static Function CadGrpComt(oModel)
Local oModel        := FWModelActive()
Local oModelGrid    := oModel:GetModel('MHNDETAIL')
Local nX            := 0
Local aAreaMHP      := MHP->(GetArea())

FWFormCommit( oModel )

MHP->(dbSetOrder(1)) // MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO

For nX := 1 To oModelGrid:Length()
    oModelGrid:GoLine(nX)    

    If !oModelGrid:IsDeleted() .AND. oModelGrid:IsUpdated()
       MHP->( dbSeek( xFilial("MHP") + PadR(cCodAss,TamSx3("MHP_CASSIN")[1]) + oModelGrid:GetValue("MHN_COD") ) )
       MHP->(RecLock("MHP",.F.))
       If AllTrim( oModelGrid:GetValue("MHN_ATIVO") ) == "2"
            MHP->MHP_ATIVO := "2"
       Else
            MHP->MHP_ATIVO := "1"
       EndIF
       MsUnLock()
    EndIf

Next

RestArea(aAreaMHP)

Return .T.

/*/{Protheus.doc} CriaStamp
Cria e popula o campo STAMP na tabela do processo
@type  Static Function
@author joao.marcos
@since 29/02/2024
@version V12
@param cTabela, caracter, Alias da Tabela
@return lRet, logico, Resultado Sucesso ou nao
/*/
Static Function CriaStamp(aTabelas)
Local lRet := .T.    
Local nCont := 0

IIF(!ExistFunc("FwEnableStamp"),LjGrvLog("RMICadGrp", "CriaStamp -  Não existe a funçao FwEnableStamp no RPO.", ),)

If ExistFunc("FwEnableStamp") 
    For nCont := 1 To Len(aTabelas)
        If !(aTabelas[nCont][2] $ "SX6|SX5|SENHAS")
            (aTabelas[nCont][2])->(dbUnlock())
            // Cria o campo STAMP
            If !FwEnableStamp( aTabelas[nCont][2] )
                MSGAlert(STR0013 + aTabelas[nCont][2] + CHR(10) + STR0015 + CHR(10)+CHR(13) + STR0016)  // "Não foi possível criar o campo S_T_A_M_P_ na tabela"  # "Crie o campo pelo Configurador." # "Atenção: Os registros de Integração só serão gerados após a criação do campo S_T_A_M_P_!" 
                LjGrvLog("RMICadGrp", "CriaStamp  - Não foi possível criar o campo S_T_A_M_P_ na tabela. Execute a rotina novamente com acesso exclusivo! Ou crie o campo pelo Configurador e refaça o cadastro.", aTabelas )
            Else 
                // Popula o campo STAMP depois de criado
                StartJob("RMICarStam", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, {aTabelas[nCont][2]})
            EndIf   
        EndIf
    Next
EndIf

Return lRet

/*/{Protheus.doc} ValidChave
Valida a chave informada da tabela
@type  Static Function
@author joao.marcos
@since 08/08/2024
@version v1.0
@param  cTabela, character, tabela
        cChave, character, chave definida
        lGatilho, logico, informa se esta sendo chamado pelo gatilho de campo ou nao

@return lRet, logico, retorno positivo ou negativo das validaçoes
/*/
Static Function ValidChave(cTabela, cChave, lGatilho)
Local lRet := .T.
Local oModel        := FWModelActive()
Local oModelGrid    := oModel:GetModel('MHNDETAIL')
Local aCposChave    := {}
Local nX            := 0
Local nTamanhoCp    := 0 
Local aStructTab    := {}
Local lExisCampo    := .T.
Local cCampos       := ""
Local cTableExcept  := "SFM|SL4|CIN|CIO|CIS|CIT|CIV|CIX|F20|F21|F22|F23|F24|F25|F26|F27|F28|F2A|F2B|F2E|F2F" // Tabelas que utilizam R_E_C_N_O_

Default lGatilho := .F.

aStructTab := (cTabela)->(Dbstruct())

If lGatilho
    If AllTrim(cTabela) $ cTableExcept
        cChave := "R_E_C_N_O_"
    Else
        cChave := AllTrim(FWX2Unico(cTabela))
    EndIf
EndIf

If AllTrim(cChave) <> "R_E_C_N_O_" .AND. Empty( FWX2Unico(cTabela) ) .AND. Empty(oModelGrid:GetValue("MHN_CONTR")) .AND. Empty(Posicione("MHN", 1, xFilial("MHN") + oModelGrid:GetValue("MHN_COD") , "MHN_TABELA"))
    If MsgNoYes(STR0032 + cTabela + STR0033 + CRLF + CRLF +;        // "Foi identificado que a tabela " ## " não possui chave única definida."
                STR0034 + CRLF +;                                   // "Para garantir a integridade dos registros, caso a tabela for customizada, defina uma chave única (X2_UNICO) para esta tabela, e em seguida, refaça a inclusão dela no grupo."
                STR0035 + CRLF + CRLF +;                            // "Porém é muito importante que antes de definir uma chave única, seja feito um estudo minuncioso sobre os campos e o contexto da tabela, e também que sejam tratados os registros duplicados caso existam."
                STR0036 + CRLF + CRLF +;                            // "Caso decida continuar o cadastro sem definir uma chave única, esteja ciente de que o processo de integração precisará incluir uma etapa de tratamento para registros duplicados, afetando a performance."
                STR0037 )                                           // "Deseja prosseguir sem informar chave unica?"
        cChave := "R_E_C_N_O_"
    Else
        cChave  := ""
        lRet    := .F.
    EndIf
    oModelGrid:LoadValue("MHN_CONTR", "1")

ElseIf AllTrim(cChave) == "R_E_C_N_O_" .AND. !Empty( FWX2Unico(cTabela) ) .AND. !AllTrim(cTabela) $ cTableExcept
    MsgInfo(STR0029 + cTabela + STR0031) // "A tabela " ## " possui chave única definida no dicionário, sendo assim a rotina irá utiliza-la."
    cChave  := AllTrim(FWX2Unico(cTabela))
EndIf

// Valida se os campos da chave pertencem a tabela:
If "R_E_C_N_O_" <> AllTrim(cChave) .AND. !lGatilho

    aCposChave  := StrToKArr(cChave, "+")
    cCampos     := ""

    For nX := 1 To Len(aCposChave)
        If (cTabela)->(FieldPos(aCposChave[nX])) == 0 .AND. aCposChave[nX] <> "R_E_C_N_O_"
            lExisCampo  := .F.
            cCampos     += AllTrim(aCposChave[nX]) + ", "
        EndIf
    Next

    cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

    If !lExisCampo
        MsgAlert(STR0023 + AllTrim(cCampos) + STR0024 + cTabela) // "O(s) campo(s) " ## " não pertence a tabela "
        cChave  := ""
        lRet    := .F.
    EndIf

EndIf

nX := 0

If cChave <> "R_E_C_N_O_" .AND. lExisCampo
    // Valida se o tamanho da chave unica cabe no campo MHQ_CHVUNI  

    For nX := 1 to Len(aCposChave)
        nTamanhoCp += TamSx3(aCposChave[nX])[1]
    Next

    If nTamanhoCp > TamSx3("MHQ_CHVUNI")[1]
        MSGInfo( STR0025 + cTabela + STR0026 + CHR(13)+CHR(10) +;   // "O tamanho da chave única da tabela " ## " excede o tamanho do campo de Chave."
                STR0027 + Alltrim(Str(nTamanhoCp)) + STR0028 )      // "Aumente o tamanho dos campos MHQ_CHVUNI (tabela MHQ) e MIP_CHVUNI (tabela MIP), para no mínimo " ## ", e refaça o cadastro."
        cChave := ""
        lRet := .F.
    EndIf

EndIf

FwFreeArray(aStructTab)
FwFreeArray(aCposChave)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} btnFiliais
Botão que apresenta tela com as filiais e atualiza campo FILIAIS

@type    Function
@author  Rafael Tenorio da Costa
@since   13/03/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static function btnFiliais()

    Local oModel    := FwModelActive()
    Local cFiliais  := rmixSelFil()

    oModel:GetModel("MIRMASTER"):loadValue("FILIAIS", cFiliais)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} campofilial
Inclui o campo virtual FILIAIS no modelo

@type    Function
@author  Rafael Tenorio da Costa
@since   13/03/2025
@version 12.1.2510
/*/ 
//-------------------------------------------------------------------
Static Function campofilial(oStruct, lView)

    if lView

        oStruct:AddField( ;
        "FILIAIS"                   , ; // [01] Campo
        "01"                        , ; // [02] Ordem
        STR0039                     , ; // [03] Titulo      //"Filiais"
        STR0039                     , ; // [04] Descricao   //"Filiais"
                                    , ; // [05] Help
        'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
        '@!'                        , ; // [07] Picture
                                    , ; // [08] PictVar
        'RMISM0'                    , ; // [09] F3
        .T.                         , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                    , ; // [11] Id da Folder onde o field esta
                                    , ; // [12] Id do Group onde o field esta
                                    )   // [13] Array com os Valores do combo

        oStruct:SetProperty("FILIAIS", MVC_VIEW_ORDEM , "10")

    else

        oStruct:AddField(	;
        STR0039  	                , ; // [01] Titulo do campo     //"Filiais"
        STR0039     	            , ; // [02] ToolTip do campo    //"Filiais"
        "FILIAIS"                   , ; // [03] Id do Field
        "C"                         , ; // [04] Tipo do campo
        10000                       , ; // [05] Tamanho do campo
        0                           , ; // [06] Decimal do campo
        {|oStruct| VldFilCar(oStruct)}                            , ; // [07] Code-block de validação do campo
                                    , ; // [08] Code-block de validação When do campo
                                    , ; // [09] Lista de valores permitido do campo
        .T.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                    , ; // [11] Bloco de código de inicialização do campo
                                    , ; // [12] Indica se trata-se de um campo chave.
        .F.                         , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
        .T.                         )   // [14] Indica se o campo é virtual.

        oStruct:SetProperty("FILIAIS",  MODEL_FIELD_INIT, fwBuildFeature(STRUCT_FEATURE_INIPAD , "RmiCdGpFil()") )
    endIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCdGpFil
Inicializador padrão do campo FILIAIS

@type    Function
@author  Rafael Tenorio da Costa
@since   14/03/2025
@version 12.1.2510
/*/ 
//-------------------------------------------------------------------
Function RmiCdGpFil()

    Local cFiliais      := ""
    Local oModel        := FWModelActive()
    Local nOperation    := 0

    if oModel <> nil
        nOperation    := oModel:getOperation()

        if nOperation <> MODEL_OPERATION_INSERT
            cFiliais := posicione("MHP", 1, xFilial("MHP") + cCodAss + oModel:GetValue("MIRMASTER", "MIR_COD"), "MHP_LAYFIL")  //MHP_FILIAL+MHP_CASSIN+MHP_CPROCE+MHP_TIPO
        endIf
    endIf

Return cFiliais

/*/{Protheus.doc} LjGrpCFGTRIB
Inclui grupos de tabela padrao do Configurador de Tributos

@type function
@author Alessandro Santos
@since 17/09/2025
@version P12

@param lGeraGrpPad, logical, Chamado pela rotina de inclusão de grupos padrão
@param cFiliais, character, Filiais do sistema
@param aGrupos, array, Grupos de Tabelas Padrão
@param aTabelas, array, Tabelas Padrão

@return Nil
/*/
Static Function LjGrpCFGTRIB(lGeraGrpPad as Logical, cFiliais as Character, aGrupos as Array, aTabelas as Array)

Local aFiliais as Array       //Filiais
Local cEmpresaAt as Character //Empresa logada
Local cCfgTrib as Character   //Codigo do grupo Configurador de Tributos
Local nX as Numeric
Local lCfgTrib as Logical     //Verifica se Configurador de Tributos esta habilitado

Default lGeraGrpPad := .F. //Chamado pela rotina de inclusão de grupos padrão
Default cFiliais    := ""  //Filiais do sistema
Default aGrupos     := {}  //Grupos de Tabelas Padrão
Default aTabelas    := {}  //Tabelas Padrão

aFiliais   := {}
cEmpresaAt := ""
cCfgTrib   := ""
nX         := 0
lCfgTrib   := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.)

If lCfgTrib .And. (lGeraGrpPad .Or. MsgYesNo(STR0041)) //"Deseja criar o grupo de tabelas para Configurador de Tributos?"
    LjGrvLog("LjGrpCFGTRIB", "LjGrpCFGTRIB -  Inicio.",)
    
    If !lGeraGrpPad //Verifica se foi chamado pela rotina de inclusão de grupos padrão
        //Busca todas as filiais da empresa logada
        aFiliais   := FWAllFilial(,, cEmpAnt, .F.)
        cEmpresaAt := FWCompany()
        
        For nX := 1 To Len(aFiliais)
            If SubStr(aFiliais[nX], 1, Len(cEmpresaAt)) == cEmpresaAt //So considera Filiais da empresa logada
                cFiliais += aFiliais[nX] + ";"
            EndIf
        Next nX

        cFiliais := SubStr(cFiliais, 1, Len(cFiliais) - 1)
    EndIf

    cCfgTrib := If(lGeraGrpPad, "009", RMISetCGrp()) //Grupo Configurador de Tributos

    // Grupos    
    aAdd(aGrupos, {cCfgTrib,"CONFIGURADOR DE TRIBUTOS", cFiliais, "1"} )

    // Tabelas / Processos
    aAdd(aTabelas, {cCfgTrib+"CIN", "CIN", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIO", "CIO", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIQ", "CIQ", "CIQ_FILIAL+CIQ_CODIGO"                  , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIR", "CIR", "CIR_FILIAL+CIR_ID+CIR_ITEM"             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIS", "CIS", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIT", "CIT", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIU", "CIU", "CIU_FILIAL+CIU_ID"                      , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIV", "CIV", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIX", "CIX", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CIY", "CIY", "CIY_FILIAL+CIY_ID"                      , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ0", "CJ0", "CJ0_FILIAL+CJ0_ID+CJ0_CODIGO"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ1", "CJ1", "CJ1_FILIAL+CJ1_ID+CJ1_CST"              , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ2", "CJ2", "CJ2_FILIAL+CJ2_ID+CJ2_CODIGO"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ4", "CJ4", "CJ4_FILIAL+CJ4_CODIGO"                  , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ5", "CJ5", "CJ5_FILIAL+CJ5_CODIGO"                  , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ6", "CJ6", "CJ6_FILIAL+CJ6_CODIGO+CJ6_ID"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ7", "CJ7", "CJ7_FILIAL+CJ7_CODIGO+CJ7_ESPECI"       , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ8", "CJ8", "CJ8_FILIAL+CJ8_CODREF+CJ8_ID"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJ9", "CJ9", "CJ9_FILIAL+CJ9_ID+CJ9_CODREG"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJA", "CJA", "CJA_FILIAL+CJA_ID+CJA_CODREG"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"CJL", "CJL", "CJL_FILIAL+CJL_ID+CJL_INDICE+CJL_CODMSG", "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F20", "F20", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F21", "F21", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F22", "F22", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F23", "F23", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F24", "F24", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F25", "F25", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F26", "F26", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F27", "F27", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F28", "F28", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F29", "F29", "F29_FILIAL+F29_CODIGO+F29_ID"           , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F2A", "F2A", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F2B", "F2B", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F2C", "F2C", "F2C_FILIAL+F2C_CODIGO"                  , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F2E", "F2E", "R_E_C_N_O_"                             , "2", cCfgTrib})
    aAdd(aTabelas, {cCfgTrib+"F2F", "F2F", "R_E_C_N_O_"                             , "2", cCfgTrib})

    If !lGeraGrpPad //Verifica se foi chamado pela rotina de inclusão de grupos padrão
        Processa({|| RMIGrvGrpP(aGrupos,aTabelas,cFiliais)}, STR0042) // "Incluindo Grupos de Tabela Padrões do Configurador de Tributos..."
        MsgInfo(STR0043) // "O grupo de tabelas padrão para Configurador de Tributos foi criado."

        FwFreeArray(aGrupos)
        FwFreeArray(aTabelas)
    EndIf

    LjGrvLog("LjGrpCFGTRIB", "LjGrpCFGTRIB -  Fim.",)
EndIf
    
Return Nil
