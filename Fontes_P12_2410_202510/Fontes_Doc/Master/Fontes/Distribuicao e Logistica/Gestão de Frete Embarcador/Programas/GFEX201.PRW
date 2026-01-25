#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "GFEX201.CH"

#DEFINE GFEX201001 'GFEX201001'
#DEFINE GFEX201002 'GFEX201002'
#DEFINE GFEX201003 'GFEX201003'
#DEFINE GFEX201004 'GFEX201004'
#DEFINE GFEX201005 'GFEX201005'
#DEFINE GFEX201006 'GFEX201006'
#DEFINE GFEX201007 'GFEX201007'
#DEFINE GFEX201008 'GFEX201008'
#DEFINE GFEX201009 'GFEX201009'
#DEFINE GFEX201010 'GFEX201010'
#DEFINE GFEX201011 'GFEX201011'
#DEFINE GFEX201012 'GFEX201012'
#DEFINE GFEX201013 'GFEX201013'
#DEFINE GFEX201014 'GFEX201014'
#DEFINE GFEX201015 'GFEX201015'
#DEFINE GFEX201016 'GFEX201016'
#DEFINE GFEX201017 'GFEX201017'
#DEFINE GFEX201018 'GFEX201018'
#DEFINE GFEX201019 'GFEX201019'
#DEFINE GFEX201020 'GFEX201020'
#DEFINE GFEX201021 'GFEX201021'
#DEFINE GFEX201022 'GFEX201022'
#DEFINE GFEX201023 'GFEX201023'
#DEFINE GFEX201024 'GFEX201024'
#DEFINE GFEX201025 'GFEX201025'
#DEFINE GFEX201026 'GFEX201026'
#DEFINE GFEX201027 'GFEX201027'
#DEFINE GFEX201028 'GFEX201028'
#DEFINE GFEX201029 'GFEX201029'
#DEFINE GFEX201030 'GFEX201030'


Static aTpVeic  := {}
Static aCarVeic := {}
Static aRetEsp  := {}
Static aRetPrc  := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201
Função base da rotinade integração GFE X FreteBras

@author João Leonardo Schmidt/Jefferson Luiz de Hita Silva
@since 25/06/2020
@version 1.0

@param cNrRom - Passado pela rotina de romaneio, indica para qual 
romaneio o registro está sendo criado.
/*/
//-------------------------------------------------------------------
Function GFEX201(cFilRom, cNrRom)
    Local oBrowse
    Local cAliGZY

    Private aRotina     := MenuDef()
    Private cNumRom     := ""
    Private cFilialRom  := ""

    Default cFilRom := ""
    Default cNrRom  := ""
    
    // Atribui a filial e o número do romaneio para variável Static
    cNumRom     := cNrRom
    cFilialRom  := cFilRom

    // Suavização das tabelas para uso da rotina
    // Validação para confirmar se a configuração de integração Frete Bras
    // está cadastrada e com a situação diferente de bloqueado
    If !IntGFEFrtBr()
        Return .F.
    EndIf

    // Caso o número do romaneio esteja diferente de vazio
    // verifica se o registro já existe para o romaneio, caso não exista chama a View
    // se já existir, chama o browse normalmente.
    If !Empty(cNrRom)
        cAliGZY := GetNextAlias()
        BeginSql Alias cAliGZY
            SELECT 1
            FROM %Table:GZY% GZY
            WHERE GZY.GZY_FILIAL = %Exp:cFilRom%
            AND GZY.GZY_NRROM = %Exp:cNrRom%
            AND GZY.%NotDel%
        EndSql
        If (cAliGZY)->(Eof())
            FWExecView(,"VIEWDEF.GFEX201",MODEL_OPERATION_INSERT,,{|| .T.})
        EndIf
        (cAliGZY)->(dbCloseArea())
    EndIf

    // Informações do browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("GZY")
    oBrowse:SetMenuDef('GFEX201')
    oBrowse:SetProfileID('1')
    oBrowse:DisableDetails()
    oBrowse:SetDescription(STR0001) // "Integração GFE X FreteBras"
    If !Empty(cNumRom)
        oBrowse:SetFilterDefault("GZY_NRROM == cNumRom")
    EndIf

    oBrowse:Activate()
Return Nil

Static Function MenuDef()
    Local aRotina   := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEX201" OPERATION 2 ACCESS 0 // Visualizar
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEX201" OPERATION 3 ACCESS 0 // Incluir
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEX201" OPERATION 4 ACCESS 0 // Alterar
    ADD OPTION aRotina TITLE STR0014 ACTION "GFEX201ENV()"    OPERATION 6 ACCESS 0 // Enviar FreteBras
    ADD OPTION aRotina TITLE STR0034 ACTION "GFEX201CON()"    OPERATION 7 ACCESS 0 // Concretizar FreteBras
    ADD OPTION aRotina TITLE STR0035 ACTION "GFEX201CAN()"    OPERATION 8 ACCESS 0 // Excluir FreteBras
Return aRotina

Static Function ModelDef()
    Local oModel
    Local oStruGZY := FWFormStruct(1, "GZY")

    oModel := MPFormModel():New("GFEX201", /*bPre*/, {|oModel| GFEX201VP(oModel)} /* bPost*/, /*bCommit*/, /*bCancel*/)
    oModel:AddFields("GFEX201_GZY", Nil, oStruGZY)
    oModel:SetPrimaryKey({"GZY_FILIAL", "GZY_NRROM"})
    oModel:SetActivate( {|oModel| GFEX201ACT(oModel)} )
Return oModel

Static Function ViewDef()
    Local oModel    := FWLoadModel("GFEX201")
    Local oView     := Nil
    Local oStruGZY  := FWFormStruct(2, "GZY")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("GFEX201_GZY", oStruGZY )
    oView:CreateHorizontalBox("MASTER", 100)
    oView:SetOwnerView("GFEX201_GZY", "MASTER")
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEFretBr
Função para montar o F3 das informações do FreteBras e retornar o item selecionado

@author João Leonardo Schmidt/Jefferson Luiz de Hita Silva
@since 25/06/2020
@version 1.0

@param cCampo   - Define o campo para o qual deve ser montado o F3 e retornado o valor
/*/
//-------------------------------------------------------------------
Function GFEFretBr(cCampo)
    Local lRet      := .F. 
    Local aArea     := GetArea()
    Local aHeader   := {}
    Local aRet      := {} 
    Local aAux      := {}
    Local aOpc      := {}
    Local cRet      := ""
    Local nGFEItem  := 0 
    Local nI        := 0
    Local nF        := 0
    
    Default cCampo  := ReadVar()

    // Limpeza da variável de retorno
    If VAR_IXB == NIL
        VAR_IXB := ""
    EndIf

    // Define os dados do F3 de acordo com o campo a ser carregado
    If  "VEIC" $ cCampo
        aHeader := { STR0007, STR0008, STR0009}   //-- id,nome,categoria
        aRet := aTpVeic
    ElseIf "TPCAR" $ cCampo
        aHeader := { STR0007, STR0008, STR0009}   //-- id,nome,categoria
        aRet := aCarVeic
    ElseIf "TIPESP" $ cCampo
        aHeader := { STR0007, STR0008}   //-- id,nome
        aRet := aRetEsp
    ElseIf "TIPPRE" $ cCampo
        aHeader := { STR0007, STR0008}   //-- id,nome
        aRet := aRetPrc
    EndIf
    // Utiliza a função do TMS para montagem do F3
    If  "TIPESP" $ cCampo .Or.  "TIPPRE" $ cCampo 
        // Utiliza a função do TMS para montagem do F3
        nGFEItem := TmsF3Array(aHeader, aRet, STR0006) //"Codigo"###"Descricao"

        // Verifica o retorno e seleciona o valor no array para preenchimento do campo
        If nGFEItem > 0   
            VAR_IXB    := cValToChar( aRet[ nGFEItem, 1 ] )
            lRet    := .T. 
        EndIf    
    ElseIf "VEIC" $ cCampo .Or. "TPCAR" $ cCampo
        aOpc := StrTokArr(AllTrim(&(cCampo)),";")
        nF := Len(aRet)
        For nI := 1 To nF
            Aadd( aAux , {} )
            Aadd( aAux[Len(aAux)] , IIf(AScan(aOpc,{|x| x == cValToChar(aRet[nI,1])}) > 0 ,.T., .F.) ) 
            Aadd( aAux[Len(aAux)] ,  aRet[nI][1] )
            Aadd( aAux[Len(aAux)] ,  aRet[nI][2] )
            Aadd( aAux[Len(aAux)] ,  aRet[nI][3] )
        Next nCount

        TMSABrowse(aAux,STR0001,,.F.,.T.,.F. ,aHeader,,)
        nF := Len(aAux)
        For nI := 1 To nF
            If aAux[nI,1]
                lRet := .T.
                If !Empty(cRet)
                    cRet += ";"
                EndIf
                cRet += cValToChar( aAux[nI,2] )
            EndIf
        Next nI
        VAR_IXB := cRet
    EndIf
    // Limpa o array aHeader. Não limpar o array a aRet devido ao ponteiro de memória compartilhado
    FwFreeArray(aHeader)
    FwFreeArray(aOpc)
    RestArea( aArea )
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFESetCampos
Função responsável por retornar a descrição dos dados para os campos do dicionário.
Esta função é chamada através do gatilho do dicionário 

@author João Leonardo Schmidt/Jefferson Luiz de Hita Silva
@since 25/06/2020
@version 1.0

@param cCampo   - Define o campo inicial do gatilho, informação importante 
para que seja definido o array a ser consultado
@param nOpc     - Define o valor do campo inicial para busca da descrição
/*/
//-------------------------------------------------------------------
Function GFESetCampos(cCampo, nOpc)
    Local aOpc      := {}
    Local cConteudo := ""
    Local nPos      := 0
    Local nI        := 0
    Local nF        := 0
    
    Default cCampo := ReadVar()
    Default nOpc   := 0

    aOpc := StrTokArr(AllTrim(nOpc),";")
    nF := Len(aOpc)
    For nI := 1 To nF
        nOpc := aOpc[nI]

        If !Empty(cConteudo)
            cConteudo += ";"
        EndIf

        // Verifica a validade da opção selecionada
        If Val(nOpc) > 0
            // Campos referentes ao Veículo
            If  "VEIC" $ cCampo
                If (nPos := AScan(aTpVeic,{|x| x[1] == Val(nOpc)})) > 0
                    cConteudo += AllTrim(aTpVeic[nPos,2])
                EndIf
            // Campos referentes a Carroceria
            ElseIf "TPCAR" $ cCampo
                If (nPos := AScan(aCarVeic,{|x| x[1] == Val(nOpc)})) > 0
                    cConteudo += AllTrim(aCarVeic[nPos,2])
                EndIf
            // Campo referente a Espécie
            ElseIf "TIPESP" $ cCampo
                If (nPos := AScan(aRetEsp,{|x| x[1] == Val(nOpc)})) > 0
                    cConteudo := AllTrim(aRetEsp[nPos,2])
                EndIf
            // Campo referente ao Preço
            ElseIf "TIPPRE" $ cCampo
                If (nPos := AScan(aRetPrc,{|x| x[1] == Val(nOpc)})) > 0 
                    cConteudo := AllTrim(aRetPrc[nPos,2])
                EndIf
            EndIf
        EndIf
    Next nI
    FwFreeArray(aOpc)
Return cConteudo
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201ACT
Função responsável por efetuar a consulta ao FreteBras e setar 
o campo de romaneio quando preenchido 

@author João Leonardo Schmidt/Jefferson Luiz de Hita Silva
@since 25/06/2020
@version 1.0

@param oModel - Modelo de Dados da função principal
/*/
//-------------------------------------------------------------------
Function GFEX201ACT(oModel)
    Local _oFreteBr := Nil
    Local nOp       := oModel:GetOperation()

    If _oFreteBr == Nil
        // Classe de conexão com o FreteBras 
        _oFreteBr := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken()
    EndIf

    // Métodos para o carregamento de dados do FreteBras
    aTpVeic  := _oFreteBr:GetTipoVeiculo()
    aCarVeic := _oFreteBr:GetCarroceriaVeiculo()
    aRetEsp  := _oFreteBr:GetEspecie()
    aRetPrc  := _oFreteBr:GetPreco()

    // Preenchimento do número do romaneio na operação de inserção
    If nOp == MODEL_OPERATION_INSERT
        If !Empty(cNumRom)
            oModel:SetValue("GFEX201_GZY", "GZY_NRROM", cNumRom)
            oModel:GetModel('GFEX201_GZY'):GetStruct():SetProperty("GZY_NRROM", MODEL_FIELD_WHEN,{||.F.})
        Else
            oModel:GetModel('GFEX201_GZY'):GetStruct():SetProperty("GZY_NRROM", MODEL_FIELD_WHEN,{||.T.})
        EndIf
        // Atribui as informações default via parâmetro
        oModel:SetValue("GFEX201_GZY", "GZY_PROD",   AllTrim(SuperGetMv("MV_GFEFBPR", .F., "")))
        oModel:SetValue("GFEX201_GZY", "GZY_TIPESP", AllTrim(SuperGetMv("MV_GFEFBTE", .F., "")))
        oModel:SetValue("GFEX201_GZY", "GZY_RASTRE", AllTrim(SuperGetMv("MV_GFEFBRA", .F., "")))
        oModel:SetValue("GFEX201_GZY", "GZY_LOTAC",  AllTrim(SuperGetMv("MV_GFEFBLT", .F., "1")))
        oModel:SetValue("GFEX201_GZY", "GZY_TIPPRE", AllTrim(SuperGetMv("MV_GFEFBTP", .F., " ")))
    Else
        oModel:GetModel('GFEX201_GZY'):GetStruct():SetProperty("GZY_NRROM", MODEL_FIELD_WHEN,{||.F.})
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201VLDC
Função responsável por validar o preenchimento dos campos referente ao FreteBras 

@author João Leonardo Schmidt
@since 30/06/2020
@version 1.0

@param cCampo - Campo a ser validado
@param cValor - Valor do campo a ser validado
/*/
//-------------------------------------------------------------------
Function GFEX201VLDC(cCampo, cValor)
    Local lRet := .T.
    Local aOpc := {}
    Local nI   := 0
    Local nF   := 0
    
    Default cCampo := ""
    Default cValor := ""

    // Verifica se os parâmetros vieram preenchidos corretamente
    If !Empty(cCampo) .And. !Empty(cValor)
        // Campos referentes ao Veículo
        If "VEIC" $ cCampo
            aOpc := StrTokArr(AllTrim(cValor),";")
            nF := Len(aOpc)
            For nI := 1 To nF
                // Confirma se a opção não existe no FreteBras e retorna como falso
                If AScan(aTpVeic,{|x| x[1] == Val(aOpc[nI])}) == 0
                    lRet := .F.
                EndIf
                If !lRet
                    Exit
                EndIf
            Next nI
        // Campos referentes a Carroceria
        ElseIf "TPCAR" $ cCampo
            aOpc := StrTokArr(AllTrim(cValor),";")
            For nI := 1 To Len(aOpc)
                // Confirma se a opção não existe no FreteBras e retorna como falso
                If AScan(aCarVeic,{|x| x[1] == Val(aOpc[nI])}) == 0
                    lRet := .F.
                EndIf
                If !lRet
                    Exit
                EndIf
            Next nI
        // Campo referente a Espécie
        ElseIf "TIPESP" $ cCampo
            // Confirma se a opção não existe no FreteBras e retorna como falso
            If AScan(aRetEsp,{|x| x[1] == Val(cValor)}) == 0
                lRet := .F.
            EndIf
        // Campo referente ao Preço
        ElseIf "TIPPRE" $ cCampo
            // Confirma se a opção não existe no FreteBras e retorna como falso
            If AScan(aRetPrc,{|x| x[1] == Val(cValor)}) == 0
                lRet := .F.
            EndIf
        EndIf
    EndIf
    FwFreeArray(aOpc)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201ENV
Função responsável por enviar a demanda ao FreteBras

@author João Leonardo Schmidt
@since 01/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEX201ENV()
    Local aTpVeic   := {}
    Local aTpCarroc := {}
    Local _oFreteBr := Nil
    Local cIdFrete  := ""
    Local lRetFtBr  := .F.
    Local lRet      := .T.
    Local lQuestion := .T.
    Local cMsg      := ""
    Local cTit      := "["+GFEX201023+"] "+STR0053 //-- "Publicação Automática de Cargas – Portal Fretebras"

    Local nQtdFrete := 0
    Local cUrlTotvs := "https://totvs.store/br/produto/publicacao-automatica-de-cargas.html"
    
    // Validar se é degustação e alertar de acordo com as regras de número de envios
    If IntGFEFrtBr(.F.)
        If TrialFrtBr(@nQtdFrete)
            If nQtdFrete == 1
                cMsg := STR0054 + chr(10) + chr(13)  //-- "Você possui 50 movimentações gratuitas para conhecer e avaliar este recurso."
                cMsg += STR0063 + chr(10) + chr(13)  //-- "Para tanto, basta informar as credenciais de acesso do portal Fretebras. Vamos lá?"
                cMsg += STR0055 + chr(10) + chr(13)  //-- "Se deseja saber mais sobre esta oferta, acesse aTotvs Store"
                cMsg += STR0056 //-- "Quer saber mais?"
            ElseIf nQtdFrete > 50
                lRet := .F.
                cMsg := STR0057  + chr(10) + chr(13)   //-- "Você utilizou todas as movimentações gratuitas disponíveis para avaliação deste recurso."
                cMsg += STR0058  + chr(10) + chr(13)  + STR0059 //-- "Para continuar aproveitando seus benefícios, contrate agora!"  //-- "Conheça todos os benefícios e realize a ativação por meio da TOTVS Store." 
                cMsg += STR0056 //-- "Quer saber mais?"
            ElseIf nQtdFrete >= 30
                cMsg := STR0060  + chr(10) + chr(13) //-- "Gostando do recurso de publicação automática de cargas no portal Fretebras?"
                cMsg += GFEMsgFmt(STR0061,{{"[VAR01]",cValToChar(nQtdFrete)}}) + chr(10) + chr(13) //-- "Notamos que você já utilizou ["VAR01"] movimentações do total de 50 disponíveis gratuitamente."
                cMsg += STR0062  + chr(10) + chr(13) //-- "Programe agora a contratação desta oferta para continuar aproveitando os benefícios deste recurso."
                cMsg += STR0056 //-- "Quer saber mais?"
            Else
                lQuestion := .F.
            EndIf
        Else
            lQuestion := .F.
        EndIf
    Else
        lRet := .F.
        cMsg := STR0054 + chr(10) + chr(13)  //-- "Você possui 50 movimentações gratuitas para conhecer e avaliar este recurso."
        cMsg += STR0063 + chr(10) + chr(13)  //-- "Para tanto, basta informar as credenciais de acesso do portal Fretebras. Vamos lá?"
        cMsg += STR0055 + chr(10) + chr(13)  //-- "Se deseja saber mais sobre esta oferta, acesse aTotvs Store"
        cMsg += STR0056 //-- "Quer saber mais?"
    EndIf

    If lQuestion .And. GFEMessage(3,cTit,cMsg)
        ShellExecute("open",cUrlTotvs,"","",3)
    EndIf

    If lRet
        // Validações referente aos dados para envio ao FreteBras
        If Empty(GZY->GZY_CIDORI) .Or. Empty(GZY->GZY_UFORI) .Or. Empty(GZY->GZY_CIDDES) .Or. Empty(GZY->GZY_UFDEST)
            GFEMessage(5,GFEX201005,STR0015,STR0016)
            lRet := .F.
        EndIf

        If lRet .And. Empty(GZY->GZY_PROD)
            GFEMessage(5,GFEX201008,STR0024,STR0025)
            lRet := .F.
        EndIf

        If lRet .And. Empty(GZY->GZY_TIPESP)
            GFEMessage(5,GFEX201009,STR0026,STR0027)
            lRet := .F.
        EndIf

        // Caso não tenha informações adicionais, preenche com a observação informando que não existem informações adicionais.
        // Esse preenchimento ocorre para envio da informação ao FreteBras.
        If lRet .And. Empty(GZY->GZY_INFOAD)
            Reclock("GZY", .F.)
                GZY->GZY_INFOAD := "Sem informações adicionais!"
            GZY->(msUnlock())
        EndIf

        If lRet .And. Empty(GZY->GZY_VEIC)
            GFEMessage(5,GFEX201010,STR0030,STR0031)
            lRet := .F.
        EndIf

        If lRet .And. Empty(GZY->GZY_TPCAR)
            GFEMessage(5,GFEX201011,STR0032,STR0033)
            lRet := .F.
        EndIf

        If lRet .And. Empty(GZY->GZY_TIPPRE)
            GFEMessage(5,GFEX201012,STR0028,STR0029)
            lRet := .F.
        EndIf
    EndIf

    If lRet
        // Montando array com todos os veículos da demanda
        If !Empty(GZY->GZY_VEIC)
            Aadd(aTpVeic, GZY->GZY_VEIC)
        EndIf

        // Montando array com todos os tipos de carroceria da demanda
        If !Empty(GZY->GZY_TPCAR)
            Aadd(aTpCarroc, GZY->GZY_TPCAR)
        EndIf

        // Realizada o instanciamento da classe
        If _oFreteBr == Nil
            // Classe de conexão com o FreteBras 
            _oFreteBr := TMSBCAFreteBras():New()
            // Busca do Token para conexão
            _oFreteBr:GetAccessToken()
            // Seta que não devem ser mostradas mensagens dentro da classe
            _oFreteBr:SetMostraErro(.F.)
        EndIf

        // Setando dados na classe do FreteBras
        _oFreteBr:SetOrigemDestino(GFE065RUF(GZY->GZY_UFORI, 1), GZY->GZY_CIDORI, GFE065RUF(GZY->GZY_UFDEST, 1), GZY->GZY_CIDDES)
        _oFreteBr:SetCarga(GZY->GZY_PROD,.T.,GZY->GZY_TIPESP)
        _oFreteBr:SetVolume(GZY->GZY_QTDVOL, GZY->GZY_PESO, GZY->GZY_VOLUME)
        _oFreteBr:SetPreco(GZY->GZY_TIPPRE, GZY->GZY_VLFRET)
        _oFreteBr:SetInfoAdic(IIf(GZY->GZY_PEDPAG == "1", .T., .F.),GZY->GZY_INFOAD,IIf(GZY->GZY_RASTRE == "1", .T., .F.))
        _oFreteBr:SetVeiculos(aTpVeic, aTpCarroc)

        // Realizando a criação da demanda no FreteBras
        If Empty(GZY->GZY_IDCARG)    
            lRetFtBr := _oFreteBr:CriaFrete()

            // Valida o retorno do envio da demanda ao FreteBras
            If lRetFtBr
                // Mensagem informando que o envio foi realizado com sucesso
                GFEMessage(0,GFEX201006,STR0021,STR0022)

                // Busca do identificador do FreteBras
                cIdFrete := _oFreteBr:GetFreteId()

                If !Empty(cIdFrete)
                    // Grava as informações referente ao controle da integração FreteBras
                    RecLock("GZY", .F.)
                        GZY->GZY_IDCARG := cIdFrete
                        GZY->GZY_STATUS := "1"
                        GZY->GZY_DATENV := Date()
                        GZY->GZY_HRENV  := SubStr(Time(),1,5)
                    GZY->(MsUnlock())
                EndIf
            Else
                // Mensagem com erro retornado pela classe de conexão com o FreteBras
                GFEMessage(5, GFEX201007, _oFreteBr:GetError(), STR0023)
                lRet := .F.
            EndIf
        Else
            // Busca do identificador do FreteBras
            cIdFrete := GZY->GZY_IDCARG 
            // alterar 
            lRetFtBr := _oFreteBr:AlteraFrete(cIdFrete)
            If lRetFtBr
                RecLock("GZY", .F.)
                    GZY->GZY_DATALT := Date()
                    GZY->GZY_HRALT  := SubStr(Time(),1,5)
                GZY->(MsUnlock())
                 GFEMessage(0, GFEX201028,STR0069,)// "Frete alterado com sucesso!"
            Else
                GFEMessage(5, GFEX201007, _oFreteBr:GetError(), STR0023)
                lRet := .F.
            EndiF
            
        EndIf
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201VP
Função responsável por validar os dados do model.
Criada para não permitir a exclusão de uma demanda que possua pendências no FreteBras.

@author João Leonardo Schmidt
@since 01/07/2020
@version 1.0

@param oModel - Modelo de dados a ser salvo pelo model GFEX201
/*/
//-------------------------------------------------------------------
Function GFEX201VP(oModel)
    Local nOpc      := oModel:GetOperation()
    Local oModelGZY := oModel:GetModel("GFEX201_GZY")
    Local lRet      := .T.
    local cStatus := oModelGZY:getValue("GZY_STATUS")

    // Verifica se a operação é de exclusão
    If nOpc == MODEL_OPERATION_DELETE
        
        If cStatus == "1"
        // Valida se o status da demanda está como em aberto
            // Caso esteja em aberto é emitido um alerta informando que não pode ser excluído e o motivo.
            // Retornado ao model para que não permita a exclusão.
            oModel:SetErrorMessage(,,,,,"["+GFEX201003+"] "+STR0017,STR0018)
            lRet := .F.
        EndIf
    ElseIf nOpc == MODEL_OPERATION_UPDATE
        // Valida se o status da demanda 
        If cStatus == "2" //somente concluido
            oModel:SetErrorMessage(,,,,,"["+GFEX201003+"] "+STR0070,STR0018)
            lRet := .F.
        EndIf
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201CON
Função responsável por concretizar a demanda ao FreteBras

@author João Leonardo Schmidt
@since 05/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEX201CON()
    Local lRet      := .T.
    Local _oFreteBr := Nil
    Local cCPFMot   := ""
    Local cPlacaD   := ""

    // Validações referente a situação, permite a concretização somente para as demandas enviadas
    If (GZY->GZY_STATUS != "1")
        GFEMessage(0,GFEX201017,STR0042,STR0043)
        lRet := .F.
    EndIf

    //Função que permite alterar o transportador, motorista e placa
    If lRet .And. MsgYesNo("Deseja alterar os dados de transporte do Romaneio?" + CRLF + CRLF + "(Transportador, Motorista, Placa do Veículo)")
        GFEX201ALTRANSP(GZY->GZY_FILIAL, GZY->GZY_NRROM)  
    EndIf

    // Validações referentes ao motorista e ao veículo da demanda
    If lRet
        GWN->(dbSetOrder(1))
        If GWN->(dbSeek(GZY->GZY_FILIAL+GZY->GZY_NRROM))
            If Empty(GWN->GWN_CDMTR) .Or. Empty(GWN->GWN_PLACAD)
                GFEMessage(0,GFEX201019,STR0045,STR0046)
                lRet := .F.
            Else
                GUU->(dbSetOrder(1))
                If GUU->(dbSeek(xFilial("GUU")+GWN->GWN_CDMTR))
                    GU8->(dbSetOrder(2))
                    If GU8->(dbSeek(xFilial("GU8")+GWN->GWN_PLACAD))
                            cPlacaD := StrTran(GU8->GU8_PLACA,"-","",1)
                            cCPFMot := SubStr(GUU->GUU_IDFED,1,3) + "." + SubStr(GUU->GUU_IDFED,4,3) + ".";
                                    + SubStr(GUU->GUU_IDFED,7,3) + "-" + SubStr(GUU->GUU_IDFED,10,2)
                            cPlacaD := SubStr(cPlacaD,1,3) + "-" + SubStr(cPlacaD,4,4)
                    Else
                        GFEMessage(0,GFEX201022,STR0051,STR0052)
                        lRet := .F.    
                    EndIf
                Else
                    GFEMessage(0,GFEX201020,STR0047,STR0048)
                    lRet := .F.
                EndIf
            EndIf
        Else
            GFEMessage(0,GFEX201021,STR0049,STR0050)
            lRet := .F.
        EndIf
    EndIf

    // Confirma se o processamento está ok
    If lRet
        // Realizada o instanciamento da classe
        If _oFreteBr == Nil
            // Classe de conexão com o FreteBras 
            _oFreteBr := TMSBCAFreteBras():New()
            // Busca do Token para conexão
            _oFreteBr:GetAccessToken()
            // Seta que não devem ser mostradas mensagens dentro da classe
            _oFreteBr:SetMostraErro(.F.)
        EndIf

        _oFreteBr:SetPlacaCPF(RTrim(cPlacaD), RTrim(cCPFMot))

        // Chama o método de concretização do frete
        If _oFreteBr:FechaFrete(RTrim(GZY->GZY_IDCARG))
            // Mensagem informando que a concretização foi realizado com sucesso
            GFEMessage(0,GFEX201013,STR0036,STR0037)

            // Grava as informações referente ao controle da integração FreteBras
            RecLock("GZY", .F.)
                GZY->GZY_STATUS := "2"
                GZY->GZY_DATCON := Date()
                GZY->GZY_HRCON  := SubStr(Time(),1,5)
            GZY->(MsUnlock())

            _oFreteBr:DeletaFrete(RTrim(GZY->GZY_IDCARG))
        Else
            // Mensagem com erro retornado pela classe de conexão com o FreteBras
            GFEMessage(5, GFEX201014, _oFreteBr:GetError(), STR0038)
            lRet := .F.
        EndIf
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201CAN
Função responsável por cancelar a demanda ao FreteBras

@author João Leonardo Schmidt
@since 05/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEX201CAN()
    Local lRet := .T.
    Local _oFreteBr := Nil

    // Validação referente a situação, permite a exclusão somente para demandas não enviadas ou 
    // que ainda estejam aguardando a execução dentro do FreteBras
    If (GZY->GZY_STATUS != "" .And. GZY->GZY_STATUS != "1")
        GFEMessage(0,GFEX201018,STR0044,STR0043)
        lRet := .F.
    EndIf 

    // Confirma se o processamento está ok
    If lRet
        // Realizada o instanciamento da classe
        If _oFreteBr == Nil
            // Classe de conexão com o FreteBras 
            _oFreteBr := TMSBCAFreteBras():New()
            // Busca do Token para conexão
            _oFreteBr:GetAccessToken()
            // Seta que não devem ser mostradas mensagens dentro da classe
            _oFreteBr:SetMostraErro(.F.)
        EndIf

        // Chama o método de cancelamento do frete caso a demanda já tenha sido enviada ao FreteBras
        If !Empty(GZY->GZY_IDCARG)
            If _oFreteBr:DeletaFrete(RTrim(GZY->GZY_IDCARG))
                // Mensagem informando que a concretização foi realizado com sucesso
                GFEMessage(0,GFEX201015,STR0039,STR0040)

                // Grava as informações referente ao controle da integração FreteBras
                RecLock("GZY", .F.)
                    GZY->GZY_STATUS := "3"
                    GZY->GZY_DATCAN := Date()
                    GZY->GZY_HRCAN  := SubStr(Time(),1,5)
                GZY->(MsUnlock())
            Else
                // Mensagem com erro retornado pela classe de conexão com o FreteBras
                GFEMessage(5, GFEX201016, _oFreteBr:GetError(), STR0041)
                lRet := .F.
            EndIf
        EndIf

        // Exclui o registro para que seja possível criar um novo e enviar ao FreteBras
        RecLock("GZY", .F.)
            GZY->(dbDelete())
        GZY->(MsUnlock())
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} IntGFEFrtBr
Verifica se há integração com o Frete Brás
@type Function
@author Squad GFE
@since 12/11/2020
@version 1.0
@return lRet, logical, Indica de integra com Frete Brás
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function IntGFEFrtBr(lExibe)
    Local lRet      := .F.
    Local cAliasQry := Nil
    Local lExiFtBr  := GFXTB12130("DM1") .And. GFXTB12130("DM2") .And. GFXTB12130("GZY")

    Default lExibe  := .T.

    If lExiFtBr
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT 1
            FROM %Table:DM1% DM1
            WHERE DM1.DM1_FILIAL = %xFilial:DM1%
            AND DM1.DM1_MSBLQL = '2'
            AND DM1.%NotDel%
        EndSql
        If (cAliasQry)->(!Eof())
            lRet := .T.
        Else
            If lExibe
                GFEMessage(5,GFEX201002,STR0012,STR0013)
            EndIf
        EndIf
        (cAliasQry)->(dbCloseArea())
    Else
        If lExibe
            GFEMessage(5,GFEX201001,STR0010,STR0011)
        EndIf
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TrialFrtBr(nQtdAcess)
Indica se é degustação e retorna quantidade
@type  Static Function
@author Squad GFE
@since 12/11/2020
@version 1.0
@param nQtdAcess, numeric, quantidade de acessos (por referencia)
@return lRet, logical, Indica se é degustação
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function TrialFrtBr(nQtdFrete)
    Local lRet      := .T.
    Local cAliasQry := Nil
    
    nQtdFrete := 1
    If DM1->(ColumnPos("DM1_IDTOTV")) > 0
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT DM1.DM1_IDTOTV
            FROM %Table:DM1% DM1
            WHERE DM1.DM1_FILIAL = %xFilial:DM1%
            AND DM1.DM1_MSBLQL = '2'
            AND DM1.%NotDel%
        EndSql
        If (cAliasQry)->(!Eof()) 
            If !Empty((cAliasQry)->DM1_IDTOTV)
                lRet    := .F.
            EndIf
        EndIf
        (cAliasQry)->(dbCloseArea())
    EndIf

    // Caso Trial verifica carrega a quantidade de acessos
    If lRet
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT Count(*) QTDACESSO
            FROM %Table:GZY% GZY
            WHERE GZY.GZY_FILIAL = %xFilial:GZY%
            AND GZY.GZY_IDCARG <> ' '
        EndSql
        If (cAliasQry)->(!Eof())
            nQtdFrete += (cAliasQry)->QTDACESSO
        EndIf
        (cAliasQry)->(dbCloseArea())
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201VLROM
(long_description)
@type  Function
@author Squad GFE
@since 17/12/2020
@version 1.0
@return lRet, Logical, indica se o romaneio é válido
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GFEX201VLROM(cNrRom)
    Local lRet      := .T.
    Local cAliasGWN := Nil
	Local cInner    := Nil
    
    Default cNrRom  := ""

    // Inicialização
    M->GZY_CIDORI := ""
    M->GZY_UFORI  := ""
    M->GZY_CIDDES := ""
    M->GZY_UFDEST := ""
    M->GZY_QTDVOL := 0
    M->GZY_PESO   := 0
    M->GZY_VOLUME := 0

    // Verifica se o romaneio foi informado
    If !Empty(cNrRom)
        cAliasGZY := GetNextAlias()
        BeginSql Alias cAliasGZY
            SELECT 1
            FROM %Table:GWN% GWN
            INNER JOIN %Table:GZY% GZY
            ON GZY.GZY_FILIAL = GWN.GWN_FILIAL
            AND GZY.GZY_NRROM = GWN.GWN_NRROM
            AND GZY.%NotDel%
            WHERE GWN.GWN_FILIAL = %xFilial:GWN%
            AND GWN.GWN_NRROM = %Exp:cNrRom%
            AND GWN.%NotDel%
        EndSql
        If (cAliasGZY)->(Eof())
            If GFXCP1212210('GW1_FILROM')
                cInner := " GW1.GW1_FILROM = GWN.GWN_FILIAL"
            Else
                cInner := " GW1.GW1_FILIAL = GWN.GWN_FILIAL"
            EndIf
            cInner := "%" + cInner + "%"

            cAliasGWN := GetNextAlias()
            BeginSql Alias cAliasGWN
                SELECT GWU.GWU_NRCIDO,
                        GU7A.GU7_CDUF GU7_UFORI,
                        GU7A.GU7_NMCID GU7_NMORI,
                        GWU.GWU_NRCIDD,
                        GU7B.GU7_CDUF GU7_UFDES,
                        GU7B.GU7_NMCID GU7_NMDES
                FROM %Table:GWN% GWN
                INNER JOIN %Table:GW1% GW1
                ON %Exp:cInner%
                AND GW1.GW1_NRROM = GWN.GWN_NRROM
                AND GW1.%NotDel%
                INNER JOIN %Table:GWU% GWU
                ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
                AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
                AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
                AND GWU.GWU_SERDC = GW1.GW1_SERDC
                AND GWU.GWU_NRDC = GW1.GW1_NRDC
                AND GWU.GWU_SEQ = '01'
                LEFT JOIN %Table:GU7% GU7A
                ON GU7A.GU7_FILIAL = %xFilial:GU7%
                AND GU7A.GU7_NRCID = GWU.GWU_NRCIDO
                AND GU7A.%NotDel%
                LEFT JOIN %Table:GU7% GU7B
                ON GU7B.GU7_FILIAL = %xFilial:GU7%
                AND GU7B.GU7_NRCID = GWU.GWU_NRCIDD
                AND GU7B.%NotDel%
                WHERE GWN.GWN_FILIAL = %xFilial:GWN%
                AND GWN.GWN_NRROM = %Exp:cNrRom%
                AND GWN.%NotDel%
            EndSql
            If (cAliasGWN)->(!Eof())
                M->GZY_CIDORI := (cAliasGWN)->GWU_NRCIDO
                M->GZY_NMORI  := (cAliasGWN)->GU7_NMORI
                M->GZY_UFORI  := (cAliasGWN)->GU7_UFORI
                M->GZY_CIDDES := (cAliasGWN)->GWU_NRCIDD
                M->GZY_NMDES  := (cAliasGWN)->GU7_NMDES
                M->GZY_UFDEST := (cAliasGWN)->GU7_UFDES
            Else
                GFEMessage(5,GFEX201024,"["+GFEX201024+"] "+GFEMsgFmt(STR0064,{{"[VAR01]",AllTrim(cNrRom)}}),STR0066)
                lRet := .F.
            EndIf
            (cAliasGWN)->(dbCloseArea())
            If lRet
                cAliasGWN := GetNextAlias()
                BeginSql Alias cAliasGWN
                    SELECT SUM(GW8.GW8_QTDE) GW8_QTDE,
                           SUM(GW8.GW8_VOLUME) GW8_VOLUME,
                           SUM(GW8.GW8_PESOR) GW8_PESOR
                    FROM %Table:GWN% GWN
                    INNER JOIN %Table:GW1% GW1
                    ON %Exp:cInner%
                    AND GW1.GW1_NRROM = GWN.GWN_NRROM
                    AND GW1.%NotDel%
                    INNER JOIN %table:GW8% GW8
                    ON GW8.GW8_FILIAL = %xFilial:GW8%
                    AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
                    AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
                    AND GW8.GW8_SERDC = GW1.GW1_SERDC
                    AND GW8.GW8_NRDC = GW1.GW1_NRDC
                    AND GW8.%NotDel%
                    WHERE GWN.GWN_FILIAL = %xFilial:GWN%
                    AND GWN.GWN_NRROM = %Exp:cNrRom%
                    AND GWN.%NotDel%
                EndSql
                If (cAliasGWN)->(!Eof())
                    M->GZY_QTDVOL := (cAliasGWN)->GW8_QTDE
                    M->GZY_PESO   := (cAliasGWN)->GW8_PESOR
                    M->GZY_VOLUME := (cAliasGWN)->GW8_VOLUME
                Else
                    GFEMessage(5,GFEX201025,"["+GFEX201025+"] "+GFEMsgFmt(STR0064,{{"[VAR01]",AllTrim(cNrRom)}}),STR0066)
                    lRet := .F.
                EndIf
                (cAliasGWN)->(dbCloseArea())
            EndIf
        Else
            GFEMessage(5,GFEX201026,"["+GFEX201026+"] "+GFEMsgFmt(STR0065,{{"[VAR01]",AllTrim(cNrRom)}}),STR0066)
            lRet := .F.
        EndIf
        (cAliasGZY)->(dbCloseArea())
    Else
        lRet := .F.
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX201VLCID
(long_description)
@type  Function
@author Squad GFE
@since 17/12/2020
@version 1.0
@Param nTipCid, numeric, tipo cidade (1=origem,2=Destino)
@Param cCdCid, caracter, código da cidade
@return cNomCid, caracter, nome da cidade
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GFEX201VCD(nTipCid,cCdCid)
    Local lRet      := .T.
    Local cAliasGU7 := Nil

    Default nTipCid := 1

    If !Empty(cCdCid)
        cAliasGU7 := GetNextAlias()
        BeginSql Alias cAliasGU7
            SELECT GU7.GU7_NRCID,
                    GU7.GU7_NMCID,
                    GU7.GU7_CDUF
            FROM %Table:GU7% GU7
            WHERE GU7.GU7_FILIAL = %xFilial:GU7%
            AND GU7.GU7_NRCID = %Exp:cCdCid%
            AND GU7.%NotDel%
        EndSql
        If (cAliasGU7)->(!Eof())
            If nTipCid == 1
                M->GZY_CIDORI := (cAliasGU7)->GU7_NRCID
                M->GZY_NMORI  := (cAliasGU7)->GU7_NMCID
                M->GZY_UFORI  := (cAliasGU7)->GU7_CDUF
            Else
                M->GZY_CIDDES := (cAliasGU7)->GU7_NRCID
                M->GZY_NMDES  := (cAliasGU7)->GU7_NMCID
                M->GZY_UFDEST := (cAliasGU7)->GU7_CDUF
            EndIf
        Else
            GFEMessage(5,GFEX201027,"["+GFEX201027+"] "+GFEMsgFmt(STR0067,{{"[VAR01]",AllTrim(cCdCid)}}),STR0068)
            lRet := .F.
        EndIf
        (cAliasGU7)->(dbCloseArea())
    EndIf
Return lRet

/*/{Protheus.doc} GFE201DEST
    Função para montar filtro da consulta padrão da cidade de destino da integração com o FreteBras

    @type  Function
    @author joao.schmidt
    @since 16/09/2021
    @version 1.0
    @return cFiltro, caracter, comando SQL para filtrar a tabela de cidades no filtro
/*/
Function GFE201DEST()
    Local cFiltro   := ""
    Local cAliasGWN := ""
    Local aCidades  := {}
    Local nI        := 0
    Local nQtCid    := 0
	Local cInner    := Nil

    If !Empty(M->GZY_NRROM)
        If GFXCP1212210('GW1_FILROM')
            cInner := " GW1.GW1_FILROM = GWN.GWN_FILIAL"
        Else
            cInner := " GW1.GW1_FILIAL = GWN.GWN_FILIAL"
        EndIf
        cInner := "%" + cInner + "%"

        cAliasGWN := GetNextAlias()
        BeginSQL Alias cAliasGWN
            SELECT GWU.GWU_NRCIDD
            FROM %Table:GWN% GWN
            INNER JOIN %Table:GW1% GW1
            ON %Exp:cInner%
            AND GW1.GW1_NRROM = GWN.GWN_NRROM
            AND GW1.%NotDel%
            INNER JOIN %Table:GWU% GWU
            ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
            AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
            AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
            AND GWU.GWU_SERDC = GW1.GW1_SERDC
            AND GWU.GWU_NRDC = GW1.GW1_NRDC
            AND GWU.GWU_SEQ = '01'
            WHERE GWN.GWN_FILIAL = %xFilial:GWN%
            AND GWN.GWN_NRROM = %Exp:M->GZY_NRROM%
        EndSQL
        While(cAliasGWN)->(!EoF())
            If AScan(aCidades, {|x|x == (cAliasGWN)->GWU_NRCIDD}) == 0
                Aadd(aCidades, (cAliasGWN)->GWU_NRCIDD)
            EndIf

            (cAliasGWN)->(dbSkip())
        EndDo
    
        (cAliasGWN)->(dbCloseArea())        

        nQtCid := Len(aCidades)

        cFiltro := "@GU7_NRCID IN ("

        For nI := 1 To nQtCid
            cFiltro += "'" + aCidades[nI] + "'"

            If nI <> nQtCid
                cFiltro += ","
            Else
                cFiltro += ")"     
            EndIf
        Next nI
    EndIf
    
Return cFiltro

Function GFEX201ALTRANSP(cFil,cNrRom)

    Local oWind
	Local lRet 			:= .F.
	Private cTranspRom 	:= Space(TamSX3("GWN_CDTRP")[1])  
	Private cMotorista	:= Space(TamSX3("GWN_CDMTR")[1])
	Private cPlacaVeic 	:= Space(TamSX3("GWN_PLACAD")[1])

    GWN->(dbSetOrder(1))
    If GWN->(dbSeek(GZY->GZY_FILIAL+GZY->GZY_NRROM))
        cTranspRom := GWN->GWN_CDTRP
        cMotorista := GWN->GWN_CDMTR
        cPlacaVeic := GWN->GWN_PLACAD
    EndIf	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 150,465})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
	
	DEFINE MSDIALOG oWind TITLE "Alterar dados de transporte do Romaneio" FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]COLORS 0, 16777215 PIXEL	
		
		TSay():New(aPosEnch[1]+009,aPosEnch[2]+005,{|| "Transportador "},oWind,,,,,,.T.,,,60,10,)
		oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+005,bSETGET(cTranspRom),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cTranspRom",,,,.T.)
        oGet:cF3 := "GU3TRP"
		
		TSay():New(aPosEnch[1]+009,aPosEnch[2]+085,{|| "Motorista "},oWind,,,,,,.T.,,,60,10,)
		oGet2 := TGet():New(aPosEnch[1]+017,aPosEnch[2]+085,bSETGET(cMotorista),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cMotorista",,,,.T.)
		oGet2:cF3 := "GUUTRP"

		TSay():New(aPosEnch[1]+009,aPosEnch[2]+165,{|| "Placa Veículo"},oWind,,,,,,.T.,,,60,10,)
		oGet3 := TGet():New(aPosEnch[1]+017,aPosEnch[2]+165,bSETGET(cPlacaVeic),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cPlacaVeic",,,,.T.)
		oGet3:cF3 := "GU8FIL"

	oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| lRet := CommitNewTransp(cTranspRom, cMotorista,cPlacaVeic,cFil,cNrRom),, If(lRet,oWind:End(),.F.) }, {|| oWind:End() },,)})

Return lRet

/*/{Protheus.doc} CommitNewTransp
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function CommitNewTransp (cTranspRom, cMotorista,cPlacaVeic,cFil,cNrRom)
    Local lRet := .T.

    If Empty(cTranspRom) .Or. Empty(cMotorista) .Or. Empty(cPlacaVeic)
        GFEMessage(5,GFEX201029,STR0071) //"Todos os campos são de preenchimento obrigatório! "
    lRet := .F.
    EndIf

    If lRet
        GWN->(dbSetOrder(1))

        If GWN->(dbSeek(GZY->GZY_FILIAL+GZY->GZY_NRROM))
            oModel := FWLoadModel('GFEA050')
            oModel:SetOperation( MODEL_OPERATION_UPDATE )

            If oModel:Activate()

                oModel:SetValue( 'GFEA050_GWN','GWN_CDTRP', AllTrim(cTranspRom))
                oModel:SetValue( 'GFEA050_GWN','GWN_CDMTR', AllTrim(cMotorista))
                oModel:SetValue( 'GFEA050_GWN','GWN_PLACAD', AllTrim(cPlacaVeic))

                If oModel:VldData()
                   oModel:CommitData()
                Else
                    GFEMessage(5,GFEX201030,oModel:GetErrorMessage()[6]) //"Todos os campos são de preenchimento obrigatório! "
                    lRet := .F.
                EndIf
            EndIf

            oModel:DeActivate()
        EndIf
    EndIf

Return lRet
