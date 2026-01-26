#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PSHSTAINTE.CH"

Static cDtHrGet := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author  Evandro Pattaro
@since 	 04/10/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStResView(oView)

Local oStrServi     := FWFormViewStruct():New()

//Carrega campo do status servicos
camposServicos(oStrServi, .T.)

oView:AddGrid("SERDETAIL_VIEW"  , oStrServi , "SERDETAIL")
oView:AddOtherObject("BTN_REFRESH", {|oPanel| BtnStatus(oPanel)})

oView:AddSheet('FOLDER', 'ABA_F03', STR0009)    //"Resumo"    
oView:CreateHorizontalBox("BOX_F03_01", 20,,, "FOLDER", "ABA_F03")
oView:CreateHorizontalBox("BOX_F03_02", 80,,, "FOLDER", "ABA_F03")

oView:SetOwnerView("BTN_REFRESH", "BOX_F03_01")
oView:SetOwnerView("SERDETAIL_VIEW", "BOX_F03_02")

oView:EnableTitleView("SERDETAIL_VIEW", STR0121)    //"Status dos Serviços"
oView:SetNoInsertLine("SERDETAIL_VIEW")
oView:SetNoUpdateLine("SERDETAIL_VIEW")
oView:SetNoDeleteLine("SERDETAIL_VIEW")
oView:SetViewProperty("SERDETAIL_VIEW", "GRIDVSCROLL", {.T.})

oView:AddIncrementField("SERDETAIL_VIEW","ITEM") //Campo criado para numerar as linhas do grid

oView:SetAfterViewActivate({|oView| LoadStatus()})

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author  Rafael tenorio da Costa 
@since 	 12/04/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshStResMod(oModel)

Local oStrServi     := FWFormModelStruct():New()

//Carrega campo do status servicos
camposServicos(oStrServi, .F.)

oModel:AddGrid("SERDETAIL", "ENVMASTER", oStrServi, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
oModel:GetModel("SERDETAIL"):SetDescription(STR0121)    //"Status dos Serviços"
oModel:GetModel("SERDETAIL"):SetOnlyView(.T.)           //Define que nao permitira a alteração dos dados
oModel:GetModel("SERDETAIL"):SetUseOldGrid(.T.)         //Indica que o submodelo deve trabalhar com aCols/aHeader.
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author  Rafael tenorio da Costa 
@since 	 12/04/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function camposServicos(oStruct as Object, lView as Logical)
    
Local cOrdem        := "00"

If lView

    oStruct:AddField( ;
    "LEGENDA"                   , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    ""                          , ; // [03] Titulo
    ""                          , ; // [04] Descricao
                                , ; // [05] Help
    'BT'                        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@BMP'                      , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo
    oStruct:AddField( ;
    "STATUS"                    , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    STR0019                     , ; // [03] Titulo          //"Status"
    STR0122                     , ; // [04] Descricao       //"Status do serviço"
    {STR0122}                   , ; // [05] Help            //"Status do serviço"
    'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@!'                        , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo    

    oStruct:AddField( ;
    "FILIAL"                    , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    STR0045                     , ; // [03] Titulo          //"Filial"
    STR0045                     , ; // [04] Descricao       //"Filial"
    {STR0045}                   , ; // [05] Help            //"Filial"
    'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@!'                        , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo                               
    
    oStruct:AddField( ;
    "SERVICO"                    , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    STR0124                    , ; // [03] Titulo          //"Serviço"
    STR0123         , ; // [04] Descricao       //"Nome do serviço"
    {STR0123}       , ; // [05] Help            //"Nome do serviço"
    'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@!'                        , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo       
    oStruct:AddField( ;
    "VERSAO"                    , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    STR0125                    , ; // [03] Titulo          //"Versão"
    STR0126         , ; // [04] Descricao       //"Versão do Client"
    {STR0126}       , ; // [05] Help            //"Versão do Client"
    'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@!'                        , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo   
    oStruct:AddField( ;
    "DTATU"                     , ; // [01] Campo
    cOrdem := Soma1(cOrdem, 2)  , ; // [02] Ordem
    STR0127                     , ; // [03] Titulo          //"Ultima atualização"
    STR0127                     , ; // [04] Descricao       //"Ultima atualização"
    {STR0127}                   , ; // [05] Help            //"Ultima atualização"
    'GET'                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
    '@!'                        , ; // [07] Picture
                                , ; // [08] PictVar
    ''                          , ; // [09] F3
                                , ; // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                , ; // [11] Id da Folder onde o field esta
                                , ; // [12] Id do Group onde o field esta
                                )   // [13] Array com os Valores do combo           
                                                          
Else
    oStruct:AddField(	;
    ""  	                    , ; // [01] Titulo do campo
    ""     	                    , ; // [02] ToolTip do campo
    "LEGENDA"                   , ; // [03] Id do Field
    "BT"                        , ; // [04] Tipo do campo
    5                           , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                , ; // [11] Bloco de código de inicialização do campo
                                , ; // [12] Indica se trata-se de um campo chave.
                                , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
    .T.                         )   // [14] Indica se o campo é virtual.

    oStruct:AddField(	;
    STR0019  	                , ; // [01] Titulo do campo             //"Status"
    STR0122                     , ; // [02] ToolTip do campo            //"Status do serviço"
    "STATUS"                  , ; // [03] Id do Field
    "C"                         , ; // [04] Tipo do campo
    50                         , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                )   // [11] Bloco de código de inicialização do campo    

    oStruct:AddField(	;
    STR0045  	                , ; // [01] Titulo do campo             //"Filial"
    STR0045      	            , ; // [02] ToolTip do campo            //"Filial"
    "FILIAL"                , ; // [03] Id do Field
    "C"                         , ; // [04] Tipo do campo
    15                          , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                , ; // [11] Bloco de código de inicialização do campo
                                , ; // [12] Indica se trata-se de um campo chave.
                                , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
                                )   // [14] Indica se o campo é virtual.
    oStruct:AddField(	;
    STR0124  	                , ; // [01] Titulo do campo             //"Serviço"
    STR0123      	            , ; // [02] ToolTip do campo            //"Nome do serviço"
    "SERVICO"                   , ; // [03] Id do Field
    "C"                         , ; // [04] Tipo do campo
    40                          , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                , ; // [11] Bloco de código de inicialização do campo
                                , ; // [12] Indica se trata-se de um campo chave.
                                , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
                                )   // [14] Indica se o campo é virtual. 
    oStruct:AddField(	;
    STR0125  	                , ; // [01] Titulo do campo             //"Versão"
    STR0126      	            , ; // [02] ToolTip do campo            //"Versão do Client"
    "VERSAO"                   , ; // [03] Id do Field
    "C"                         , ; // [04] Tipo do campo
    30                          , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                , ; // [11] Bloco de código de inicialização do campo
                                , ; // [12] Indica se trata-se de um campo chave.
                                , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
                                )   // [14] Indica se o campo é virtual. 
    oStruct:AddField(	;
    STR0127  	                , ; // [01] Titulo do campo             //"Ultima atualização"
    STR0127      	            , ; // [02] ToolTip do campo            //"Ultima atualização"
    "DTATU"                   , ; // [03] Id do Field
    "C"                         , ; // [04] Tipo do campo
    35                          , ; // [05] Tamanho do campo
    0                           , ; // [06] Decimal do campo
                                , ; // [07] Code-block de validação do campo
                                , ; // [08] Code-block de validação When do campo
                                , ; // [09] Lista de valores permitido do campo
    .F.                         , ; // [10] Indica se o campo tem preenchimento obrigatório
                                , ; // [11] Bloco de código de inicialização do campo
                                , ; // [12] Indica se trata-se de um campo chave.
                                , ; // [13] Indica se o campo não pode receber valor em uma operação de update.
                                )   // [14] Indica se o campo é virtual.                                     
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PshGetStatus
Construtor de tela com botão de refresh dos status dos serviços 


@author  Evandro Pattaro   
@since   04/10/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function BtnStatus(oPanel)

    Local oSay1
    Local oButton1

    Default oPanel := NIL

    @ 010, 000 Say oSay1 Prompt STR0128+cDtHrGet Of oPanel Size 90, 012 Pixel //"Última consulta realizada: "
    @ 000, 170 BTNBMP oButton1 RESOURCE "TK_REFRESH" Of oPanel MESSAGE STR0129 Size 050, 050 Pixel  //"Atualizar"
    oButton1:bAction := { || RegServicos() }

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} RegServicos
Função para setar a régua de processamento do get dos Layouts

@author Evandro Pattaro
@since  29/08/2022
/*/
//-------------------------------------------------------------------

Static Function RegServicos()
Local oProcess		:= Nil	//objeto da classe MsNewProcess

oProcess := MsNewProcess():New( { ||  LoadStatus() },STR0130, STR0131 , .T. ) //"Carregando Status" , "Aguarde..."
oProcess:Activate()  

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadStatus
Carrega o grid com o resultado dos status dos serviços

@author  Evandro Pattaro   
@since   04/10/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function LoadStatus()
Local oModel    := FwModelActive()
Local oView     := fwViewActive()
Local oDetModel := oModel:GetModel("SERDETAIL")
Local jDados    := JsonObject():New()
Local nI        := 0
Local nLine     := 0 
Local xRet      := Nil
Local cRet      := ""
Local aDtHora   := {}

If Empty(cDtHrGet) .OR. (ElapTime(SubStr( cDtHrGet, 12, 8 ),Time()) > "00:01:00" )

    oDetModel:SetNoUpdateLine(.F.) 
    oDetModel:SetNoInsertLine(.F.) 
    oDetModel:SetNoDeleteLine(.F.) 
    oDetModel:SetMaxLine(9999999)
    oDetModel:ClearData()


    cRet := PshGetStatus()
    xRet := jDados:FromJson(cRet) 

    If ValType(xRet) == "U"

        For ni := 1 To Len(jDados)
            If UPPER(Substr(jDados[nI]['retaguarda'],1,8)) == "PROTHEUS"

                nLine++

                If nLine > 1 
                    oDetModel:addLine()
                EndIf

                aDtHora := TrataHoraUTC(jDados[nI]['dataAtualizacao'],jDados[nI]['status'])

                oDetModel:SetValue("LEGENDA",  aDtHora[2])
                oDetModel:SetValue("STATUS",  aDtHora[3])
                oDetModel:SetValue("FILIAL",  jDados[nI]['idLojaRetaguarda'])
                oDetModel:SetValue("SERVICO", jDados[nI]['aplicacao']+" ("+jDados[nI]['servico']+")")
                oDetModel:SetValue("VERSAO", IIF(jDados[nI]['versaoClient'] == Nil,"",jDados[nI]['versaoClient']) )
                oDetModel:SetValue("DTATU", aDtHora[1] )

            EndIf
        Next
        cDtHrGet := FwTimeStamp(2)
    Else
        If IsInCallStack("RegServicos")
            LjxjMsgErr(STR0132 + cRet ,STR0133,"PshGetStatus") // "Retorno da consulta :" , "Por favor, verifique se a propriedade 'url_status' existe no cadastro de assinantes e se está preenchida corretamente com a URL da consulta dos Status."     
        EndIf
    EndIf    

    oDetModel:SetNoUpdateLine(.T.) 
    oDetModel:SetNoInsertLine(.T.) 
    oDetModel:SetNoDeleteLine(.T.) 

    oDetModel:GoLine(1)
    oView:Refresh()
Else
    LjxjMsgErr(STR0134,STR0135,"PshGetStatus") //"Limite Excedido", "Por favor, aguarde até 1 (um) minuto para realizar a próxima consulta."
EndIf
FWFreeArray( aDtHora )
FwFreeObj(jDados)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} PshGetStatus
Realiza a busca dos status dos serviços PdvSync/PSH conforme inquilino configurado em assinante 

@return     Retorna o array em JSON dos serviços listados pelo PDVSYNC

@author  Evandro Pattaro   
@since   04/10/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function PshGetStatus()

Local oPdvSync   := nil
Local oConfAssin := nil
Local oGetStatus := nil
Local cRet       := ""
Local cTabela    := GetNextAlias()
Local cSelect    := ""
Local aHeader    := {}
Local aArea      := GetArea()
Local cParams    := "IdInquilino="


cSelect := " SELECT R_E_C_N_O_ RECMHO "
cSelect += " FROM " + RetSqlName("MHO") + " MHO "
cSelect += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "' AND MHO.D_E_L_E_T_ = ' ' AND MHO_COD = 'PDVSYNC' "
DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

While !(cTabela)->( Eof() )
    MHO->(DbGoto((cTabela)->RECMHO))
    FwFreeObj(oConfAssin)
    oConfAssin := JsonObject():New()
    oConfAssin:FromJson( AllTrim(MHO->MHO_CONFIG) )   

    If oConfAssin:hasProperty("url_status") .And. !Empty(oConfAssin["url_status"])

        oGetStatus:= FWRest():New("")
        oGetStatus:SetPath(oConfAssin["url_status"])
        
        oGetStatus:SetGetParams(cParams+oConfAssin["inquilino"])

        If oConfAssin:hasProperty("autenticacao") 
            oPdvSync := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(oConfAssin["autenticacao"]["tenent"],;
                oConfAssin["autenticacao"]["user"], ;
                oConfAssin["autenticacao"]["password"],;
                oConfAssin["autenticacao"]["clientId"],;
                oConfAssin["autenticacao"]["clientSecret"],;
                oConfAssin["autenticacao"]["environment"])
            
            IIF(oPdvSync:Token()[1],LjGrvLog("PshGetStatus", STR0139),cRet := STR0136 + Chr(13) + Chr(10)) //"Sucesso na busca do Token"|"Token invalido para Status de Serviço - verifique o dados de autenticacao no cadastro de assinante" 
            aHeader:= oPdvSync:getHeader()       
        EndIf

        If oGetStatus:Get(aHeader)
            cRet:= oGetStatus:GetResult()
        Else
            cRet+= oGetStatus:GetLastError() + Chr(13) + Chr(10) + STR0137 + oGetStatus:cPath //"Url da consulta : "
        EndIf
        
        FwFreeObj(oGetStatus)
        FwFreeObj(oPdvSync)
    Else
        cRet := STR0138 //"Propriedade 'url_status' vazia ou inexistente no JSON de configuração do assinante."
    EndIf

    FwFreeObj(oConfAssin)
    (cTabela)->( DbSkip() )
EndDo

(cTabela)->( DbCloseArea() )
RestArea(aArea)


Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TrataHoraUTC
Faz a conversão de data/hora para UTC Local

@return cTimeStamp     Retorna o timestamp com a data/hora convertida para local

@author  Evandro Pattaro   
@since   07/10/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function TrataHoraUTC(cDateTime,cStatus)
    Local aUTC          := {}
    Local aRet          := {}
    Local cTimeStamp    := ""
    Local cDate         := ""
    Local cTime         := ""

    Default cDateTime   := ""
    Default cStatus     := ""
   
    If !Empty( cDateTime ) 
        
        cDateTime   := StrTran( cDateTime, "-", "" )
        cDateTime   := StrTran( cDateTime, "T", "" )
        cDate       := SubStr( cDateTime, 1, 8 )
        cTime       := SubStr( cDateTime, 9, 8 )
        
        aUTC    := UTCToLocal( cDate, cTime )
        cDate   := aUTC[1]
        cTime   := aUTC[2]
       
        cTimeStamp  := DTOC(STOD(cDate)) +" - "+ cTime

        Aadd(aRet,cTimeStamp)

        If Upper(cStatus) == "ATIVO" .And. (ElapTime(cTime,Time()) < "00:45:00" .And. (STOD(cDate) == Date()))           
            Aadd(aRet,"BR_VERDE.PNG")
            Aadd(aRet,"ATIVO")   
        Else
            Aadd(aRet,"BR_VERMELHO.PNG")
            Aadd(aRet,"INATIVO")
        EndIf
    EndIf 

    FWFreeArray( aUTC )
Return aRet