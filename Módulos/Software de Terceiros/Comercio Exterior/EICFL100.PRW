#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICFL100.CH"

/*/{Protheus.doc} EICFL100
    Função para a funcionalidade de Fundamento Legal

    @type  Function
    @author user
    @since 27/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function EICFL100()
Local oBrowse

// Criação do Browse
oBrowse := FWMBrowse():New() // Instanciando a Classe
oBrowse:SetAlias("EKU") // Informando o Alias
oBrowse:SetMenuDef("EICFL100") // Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) // Fundamento Legal
oBrowse:Activate()

Return

// Criação do MenuDef
Static Function MenuDef() 
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICFL100" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICFL100" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EICFL100" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICFL100" OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0026 ACTION "FL100ImpCsv()"    OPERATION 6 ACCESS 0 // "Importar Arquivo"
ADD OPTION aRotina TITLE STR0027 ACTION "FL100ImpPU()"     OPERATION 3 ACCESS 0 // "Importar do Portal Único"

Return aRotina

// Criação do ModelDef
Static Function ModelDef()
Local oModel
Local oStruEKU := FWFormStruct(1, "EKU")
local oStruEKV := FWFormStruct(1, "EKV")

oModel := MPFormModel():New('EICFL100', /*bPreValidacao*/, {|oMdl| FL100PosVld(oMdl)}, /*bCommit*/, /*bCancel*/ )
oModel:AddFields('EKU_MASTER',/*nOwner*/,oStruEKU, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

if( oStruEKV:HasField('EKV_FDTDES'), oStruEKV:RemoveField('EKV_FDTDES'), nil )
oModel:AddGrid("EKVDETAIL", "EKU_MASTER", oStruEKV)
oModel:GetModel("EKVDETAIL"):SetOptional(.T.)
If AvFlags("FUNDLEGAL_PORTALUNICO")
    //EKV_FILIAL+EKV_NCM+EKV_FDTLGL+EKV_TRIBUT+EKV_PAIS
    oModel:GetModel("EKVDETAIL"):SetUniqueLine({"EKV_FILIAL", "EKV_NCM", "EKV_FDTLGL", "EKV_TRIBUT", "EKV_PAIS"} )
Else
    oModel:GetModel("EKVDETAIL"):SetUniqueLine({"EKV_FILIAL", "EKV_NCM", "EKV_FDTLGL", "EKV_TRIBUT"} )
EndIf
oModel:SetRelation('EKVDETAIL', {{ 'EKV_FILIAL', 'xFilial("EKV")'},{ 'EKV_FDTLGL', 'EKU_FDTLGL'    }},"EKV_FILIAL + EKV_FDTLGL" )
oModel:SetDescription(STR0001) // Fundamento Legal

oModel:SetPrimaryKey({'EKU_FILIAL','EKU_FDTLGL'}) 

Return oModel

// Criação do ViewDef
Static Function ViewDef()
Local oModel   := FWLoadModel("EICFL100")
Local oStruEKU := FWFormStruct(2, "EKU")
local oStruEKV := FWFormStruct(2, "EKV")
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("CAPA", 50)
oView:AddField( 'VIEW_EKU', oStruEKU,'EKU_MASTER')
oView:SetOwnerView( 'VIEW_EKU', 'CAPA' )
oView:EnableTitleView( 'VIEW_EKU', STR0001) // Fundamento Legal

if( oStruEKV:HasField('EKV_FDTDES'), oStruEKV:RemoveField('EKV_FDTDES'), nil )
if( oStruEKV:HasField('EKV_FDTLGL'), oStruEKV:RemoveField('EKV_FDTLGL'), nil )
oView:CreateHorizontalBox("DETAIL", 50)
oView:AddGrid( 'VIEW_EKV', oStruEKV, 'EKVDETAIL' )
oView:SetOwnerView( 'VIEW_EKV', 'DETAIL' )
oView:EnableTitleView( 'VIEW_EKV', STR0007) // "Amarração Fundamento Legal x NCM x Tributo"

oView:EnableControlBar(.T.)

Return oView 

// Função para validar os campos
Function FL100Valid(cCampo)
Local lRet       := .T.
Local oModel     := FWModelActive()
local oModelEKU  := nil
local oModelEKV  := nil
local cInfNCM    := ""

Default cCampo     := ""

Do Case
    Case cCampo == "EKU_REGIME"

        oModelEKU := oModel:GetModel("EKU_MASTER")
        If !Empty(oModelEKU:GetValue("EKU_REGIME"))
            lRet := ExistCpo("SJP", AvKey(oModelEKU:GetValue("EKU_REGIME"), "JP_CODIGO"), 1 )
        EndIf

    case cCampo == "EKV_NCM"

        oModelEKV := oModel:GetModel("EKVDETAIL")
        cInfNCM := oModelEKV:GetValue("EKV_NCM")
        if !empty(cInfNCM)
            lRet := ExistCpo("SYD", AvKey(cInfNCM, "YD_TEC"), 1 )
        endif

    case cCampo == "EKV_TRIBUT"
        lRet := Vazio() .or. Pertence(TEListComb( TEOpcTribu(), ";" ))

EndCase

Return lRet

// Função de gatilho do campo de descrição do regime (EKU_REGDES)
Function FL100RegDsc(lIniBrowse)
Local cRet         := ""
Default lIniBrowse := .F.

cRet := Posicione("SJP", 1, xFilial("SJP") + IIF(lIniBrowse, EKU->EKU_REGIME, M->EKU_REGIME), "JP_DESC")

Return cRet

// Função para pós validação quando for salvar
Static Function FL100PosVld(oModel)
Local lRet := .T. 
Local nOpc := oModel:GetOperation()
Local oModelEKU := oModel:GetModel("EKU_MASTER")
local oModelEKV := nil
local nPosLin   := 0
local nLin      := 0

If nOpc == MODEL_OPERATION_INSERT
    If EKU->(DbSeek(xFilial("EKU") + oModelEKU:GetValue("EKU_FDTLGL")))
        lRet := .F.
        EasyHelp(STR0013 + " '"+ oModelEKU:GetValue("EKU_FDTLGL") +"' " + STR0014, STR0009, STR0015) // "Fundamento Legal com o código" ### "já cadastrado." ### "Atenção" ### "Altere o código do fundamento legal para um código não utilizado."
    EndIf
EndIf

If lRet .and. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
    If !Empty(oModelEKU:GetValue("EKU_VIGFIN")) .and. oModelEKU:GetValue("EKU_VIGINI") > oModelEKU:GetValue("EKU_VIGFIN")
        lRet := .F.
        EasyHelp(STR0016 + " '"+ DtoC(oModelEKU:GetValue("EKU_VIGINI")) +"' " + STR0017 + " '" + DtoC(oModelEKU:GetValue("EKU_VIGFIN")) + "'.", STR0009, STR0018) // "A data inicial" ### "é maior que a data final" ### "Atenção" ### "Altere a data inicial para que seja igual ou menor que a data final."
    EndIf

    if lRet
        oModelEKV := oModel:GetModel("EKVDETAIL")
        nPosLin := oModelEKV:getLine()
        for nLin := 1 to oModelEKV:Length(.T.)
            oModelEKV:goLine(nLin)
            if (!empty(oModelEKV:getValue("EKV_NCM")) .and. empty(oModelEKV:getValue("EKV_TRIBUT"))) .or. (empty(oModelEKV:getValue("EKV_NCM")) .and. !empty(oModelEKV:getValue("EKV_TRIBUT")))
                lRet := .F.
                EasyHelp(STR0019, STR0009, StrTran(STR0020, "XXXX", cValToChar(nLin))) // "É obrigatório informar a NCM e seu tributo para o fundamento legal." ### "Atenção" ### "Verifique os campos 'NCM' ou 'Tributo' da linha XXXX."
                exit
            endif
            // deleta a linha se os campos NCM e Tributo estiverem vazios evitar de gravar vazio
            if( empty(oModelEKV:getValue("EKV_NCM")) .and. empty(oModelEKV:getValue("EKV_TRIBUT")), (lRet := oModelEKV:deleteLine()), nil )
        next
        oModelEKV:goLine(nPosLin)
    endif

EndIf

Return lRet

/*/{Protheus.doc} FL100Pict
    Função para retornar a picture de um campo 

    @type  Function
    @author user
    @since 27/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
function FL100Pict(cCampo)
    local cPict      := ""

    default cCampo := ""

    do case
        case cCampo == "EKV_NCM"
            cPict := "@R 9999.99.99"
    
    end case

    cPict := cPict + "%C"

return cPict

/*/{Protheus.doc} FL100Relac
    Função para utilizar no X3_RELACAO

    @type  Function
    @author user
    @since 27/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
function FL100Relac(cCampo)
    local cRet       := ""
    local oModel     := FWModelActive()
    local nOpc       := oModel:GetOperation()
    local aArea      := {}

    default cCampo := "EKV_FDTDES"

    do case
        case cCampo == "EKV_FDTDES"
            cRet := space( getSX3Cache(cCampo, "X3_TAMANHO"))
            if !(nOpc == MODEL_OPERATION_INSERT)
                aArea := EKU->(getArea())
                EKU->(dbSetOrder(1))
                if EKU->(dbSeek( xFilial("EKU") + EKV->EKV_FDTLGL))
                    cRet := EKU->EKU_FDTDES
                endif
                RestArea(aArea)
            endif
    end case

return cRet

/*/{Protheus.doc} FL100ImpCsv
    Função para importar o arquivos CSV proveniente do Portal Único

    @type  Function
    @author user
    @since 27/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function FL100ImpCsv()
local aAreaEKU := EKU->(getArea())
Local cDir
Local oArquivo := AvImport():New()
Local oModel
Local i
Local nTamCod := GetSX3Cache("EKU_FDTLGL", "X3_TAMANHO")
Local nTamCodDes := GetSX3Cache("EKU_FDTDES", "X3_TAMANHO")
Local cErros := ""
local lSeekEKU := .F.
local cDescFund := ""
local cDescDecod := ""

cDir := oArquivo:ChooseFile(STR0021,"Arquivo separado por ; | *.csv",cDir,,{|X| INT104ValTipo(X,".CSV")}) // "Selecione o arquivo CSV para integração de Fundamentos Legais"

oArquivo:cSeparador := ";"
oArquivo:Import(.T.)
EKU->(dbSetOrder(1))

// Ignora a primeira linha pelo fato de ser o cabeçalho
For i := 2 to Len(oArquivo:aDados)
    // Carrega o modelo de dados
    oModel := FWLoadModel("EICFL100")
    // Verifica se já existe o registro na base para ser atualizado ou inserido 
    lSeekEKU := EKU->(DbSeek(xFilial("EKU") + SubStr(oArquivo:aDados[i][1], 1, nTamCod)))
    IIF(lSeekEKU, oModel:SetOperation(MODEL_OPERATION_UPDATE), oModel:SetOperation(MODEL_OPERATION_INSERT))

    // Ativa o modelo de dados
    oModel:Activate()

    // 1 - Fundamento Legal
    if !lSeekEKU
        oModel:SetValue("EKU_MASTER", "EKU_FDTLGL", SubStr(oArquivo:aDados[i][1], 1, nTamCod))
    endif
    cDescFund := SubStr(oArquivo:aDados[i][1], nTamCod + 4, nTamCodDes)
    cDescDecod := DecodeUtf8(cDescFund, 'cp1252')
    oModel:SetValue("EKU_MASTER", "EKU_FDTDES", if( cDescDecod == nil, cDescFund, cDescDecod))
    // 2 - Regime
    oModel:SetValue("EKU_MASTER", "EKU_REGIME", SubStr(oArquivo:aDados[i][2], 1, 1))
    // 3 - Tipo de Operação
    oModel:SetValue("EKU_MASTER", "EKU_TPOPER", SubStr(oArquivo:aDados[i][3], 1, 1))
    // 4 - Tributos
    // 5 - NCM Vigente?
    oModel:SetValue("EKU_MASTER", "EKU_NCM", IIF(oArquivo:aDados[i][5] == "Sim", "1", "2"))
    // 6 - Nomenclatura
    // 7 - Vigência Inicial
    oModel:SetValue("EKU_MASTER", "EKU_VIGINI", CtoD(oArquivo:aDados[i][7]))
    // 8 - Vigência Final
    oModel:SetValue("EKU_MASTER", "EKU_VIGFIN", CtoD(oArquivo:aDados[i][8]))

    // Valida os campos e commita se não tiver erros
    IIF(oModel:VldData(), oModel:CommitData(), cErros += SubStr(oArquivo:aDados[i][1], 1, nTamCod) + ", ")

    // Desativa o modelo de dados e destrói
    oModel:DeActivate()
    oModel:Destroy()
Next i

If !Empty(cErros)
    cErros := SubStr(cErros, 1, Len(cErros) - 2) // Retira a última vírgula
    EasyHelp(STR0022 + CRLF + cErros, STR0009, STR0023) // "Não foi possível realizar a importação do(s) seguinte(s) fundamento(s) legal(is)": / "Atenção" / "Verifique se as informações dos fundamentos legais citados acima estão corretas."
Elseif Len(oArquivo:aDados) > 0
    MsgInfo(STR0024, STR0025) // Importação realizada com sucesso! ### "Importação do CSV"
EndIf

// Libera os objetos da memória
FwFreeObj(oArquivo)
FwFreeObj(oModel)

RestArea(aAreaEKU)

Return

// Função para importar as informações diretamente do Portal Único
Function FL100ImpPU()
local aAreaEKU := EKU->(getArea())
Local lCancelou
Local cUrl
Local cUrlAuth := "/portal/api/autenticar"
Local cRet := ""
Local cRetAtr := ""
Local cErros := ""
local cRetErros := ""
local lOk := .t.
Local oEasyJS
local lIntAtrib := .F.

Begin Sequence

    cUrl := AVgetUrl(, , @lCancelou, "EIC")
    If lCancelou
        break
    EndIf
    lIntAtrib := VldIntAtrb()

    oEasyJS := EasyJS():New()
    oEasyJS:cUrl := cUrl + cUrlAuth
    oEasyJS:setTimeOut(60)
    oEasyJS:AddLib( EasyAppFetch(cUrl + cUrlAuth) )
    oEasyJS:AddLib( FL100Script() )
    if lIntAtrib
    	oEasyJS:AddLib( TEGetJSZip() )
    endif

    FWMsgRun(, {|| cErros := FL100Auth(oEasyJS) }, STR0035, STR0036) // "Autenticação" | "Autenticando com o Portal Único..."
    If !Empty(cErros)
        oEasyJS:Destroy()
        break
    EndIf

    FWMsgRun(, {|| oEasyJS:runJSSync("getFdtLegal('" + cUrl + "/tabx/api/ext/tabela/FUNDAMENTO_LEGAL_TT" + "', retAdvplError, retAdvpl);" , {|x| cRet := x}, {|x| cRetErros := x }) }, STR0001, STR0044) // "Fundamento Legal" | "Solicitando os Fundamentos Legais ao Portal Único"

    lOk := getError(@cErros, @cRet,STR0028,cRetErros) // "Não foi possível obter os dados do Portal Único. Verifique se os parâmetros estão corretos e tente novamente mais tarde."

    if lOk .and. lIntAtrib
        FWMsgRun(, {|| oEasyJS:runJSSync("DownloadFundLegal('" + cUrl + "/cadatributos/api/ext/atributo-fundamento-legal/download/json" + "', retAdvplError, retAdvpl);" , {|x|  cRetAtr := x }, {|x| cRetErros := x}) }, STR0001, STR0045) // "Fundamento Legal" | "Solicitando os Atributos ao Portal Único"
        lOk := getError(@cErros, cRetAtr,STR0039,cRetErros)    // Não foi possível obter os dados do atributo do fundamento legal do Portal Único. Verifique se os parâmetros estão corretos e tente novamente mais tarde.
    Endif     
    
    oEasyJS:Destroy()

    if !lOk
       break    
    EndIf       

    Processa({ || FL100TrataJson(cRet,cRetAtr) }, STR0037, STR0038) // "Processando" | "Importando fundamentos legais..."

End Sequence

If !Empty(cErros)
    EasyHelp(cErros, STR0009, STR0029) // "Atenção" | "Verifique o erro apresentado."
EndIf

RestArea(aAreaEKU)

Return

Static Function FL100Auth(oEasyJS)

If !oEasyJS:Activate(.T.)
    Return STR0028 // "Não foi possível obter os dados do Portal Único. Verifique se os parâmetros estão corretos e tente novamente mais tarde."
EndIf
Return ""

Static Function FL100Script(cUrl)
Local cScript := ''

begincontent var cScript

    var XCSRFToken = '';
    var SetToken = '';

    function getFdtLegal(cUrl, retAdvplError, retAdvpl) {
        return EasyFetch( retAdvplError, cUrl, 'GET')
        .then( (res) => res.text() )
        .then( (res) => retAdvpl(res) )
        .catch((e) => { retAdvplError(e) });
    }

    async function DownloadFundLegal(cUrl, retAdvplError, retAdvpl, retAdvplChunk) {
        let contType = 'application/json';
        let options = {
            method: 'GET',
            mode: 'cors'
        };
        options.headers = {
            'Content-Type': contType,
            "Authorization": SetToken,
            "X-CSRF-Token": XCSRFToken
        }

        try {

            const response = await fetch(cUrl, options);
            if (!response.ok) throw new Error('Erro ao baixar o arquivo');

            const blob = await response.blob();
            const arrayBuffer = await blob.arrayBuffer();

            const zip = await JSZip.loadAsync(arrayBuffer);

            let fileNames = Object.keys(zip.files);
            let jsonFiles = fileNames.filter(fileName => fileName.endsWith('.json'));

            for (let fileName of jsonFiles) {
                const file = zip.files[fileName];
                const content = await file.async('string');
                retAdvpl(content);
            }

        } catch (e) {
            retAdvplError('Erro: ' + e.message);

        }
        return
    }

endcontent

Return cScript

Static Function FL100TrataJson(cRet,cRetAtr)
Local oJson := JsonObject():New()
Local oJsonDet := JsonObject():New()
Local oModel
local oModelEKU
Local i
Local cErros := ""
Local cCodigo
Local cCodOri
Local cDescricao
Local dDataInicio
Local dDataFim
Local lErroCommit := .F.
Local cLib
Local nTotal := 0
local lIntAtrib := .F.
local nPosCod := 0
local nPosDesc := 0
local nPosDtIni := 0
local nPosDtFim := 0
local nTamCod := GetSX3Cache("EKU_FDTLGL", "X3_TAMANHO")
local nTamDesc := GetSX3Cache("EKU_FDTDES", "X3_TAMANHO")
local lSeekEKU := .F.
local aFund := {}
local cJson := ""

Private aAtrib := {}
Private aDetalhes := {}      

default cRetAtr := ""

// Verifica se é desktop ou webapp
GetRemoteType(@cLib)

oJson:FromJson(cRet)
cErros := if(!ValType(oJson) == "J", STR0030 + CRLF + CRLF + " " + cRet + CRLF, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."

if Empty(cErros) .and. !empty(cRetAtr)
    oJsonDet:FromJson(cRetAtr)
    cErros := if(!ValType(oJsonDet) == "J", STR0041 + CRLF + CRLF + " " + cRetAtr + CRLF, "" ) // "Não foi possível fazer o parse do JSON dos detalhes dos atributos do retorno da integração."
EndIf    

If Empty(cErros)
    cErros := if(Len(oJson['dados']) == 0, STR0031, "") // "Arquivo de retorno sem itens!"  
    If Empty(cErros)
        nTotal := Len(oJson['dados'])
        if nTotal > 0

            lIntAtrib := VldIntAtrb()

            ProcRegua(nTotal)

            if !empty(cRetAtr)
                aAtrib := getAtrib(oJsonDet,{'listaFundamentoLegal','codigoFundamentoLegal'})
                aDetalhes := getAtrib(oJsonDet,{'detalhesAtributos','codigo'})
            endif

            // Modelo de dados
            oModel := FWLoadModel("EICFL100")
            oModelEKU := oModel:GetModel("EKU_MASTER")
            lIntAtrib := lIntAtrib .and. oModelEKU:HasField("EKU_ATT_FL")
            EKU->(dbSetOrder(1))

            For i := 1 to nTotal

                nPosCod := aScan( oJson['dados'][i]['campos'], { |X| X["nome"] == "CODIGO"} )
                nPosDesc := aScan( oJson['dados'][i]['campos'], { |X| X["nome"] == "DESCRICAO"} )
                nPosDtIni := aScan( oJson['dados'][i]['campos'], { |X| X["nome"] == "DATA_INICIO"} )
                nPosDtFim := aScan( oJson['dados'][i]['campos'], { |X| X["nome"] == "DATA_FIM"} )

                // Obtenção das variáveis
                cCodOri :=  oJson['dados'][i]['campos'][nPosCod]['valor']
                cCodigo := PadL(cCodOri, nTamCod, '0')
                aAdd( aFund, cCodigo)
                cDescricao := subStr(IIF("HTML" $ cLib, DecodeUtf8(oJson['dados'][i]['campos'][nPosDesc]['valor'], 'cp1252'), oJson['dados'][i]['campos'][nPosDesc]['valor']), 1, nTamDesc)
                dDataInicio := SToD(StrTran(oJson['dados'][i]['campos'][nPosDtIni]['valor'],'-',''))
                dDataFim := SToD(StrTran(oJson['dados'][i]['campos'][nPosDtFim]['valor'],'-',''))
                cJson := ""
                if !empty(cRetAtr)
                    cJson := getJson(cCodOri,cLib)
                endif

                // Verifica se já existe o registro na base para ser atualizado ou inserido 
                lSeekEKU := EKU->(DbSeek(xFilial("EKU") + cCodigo))
                IIF(lSeekEKU, oModel:SetOperation(MODEL_OPERATION_UPDATE), oModel:SetOperation(MODEL_OPERATION_INSERT))

                // Atualiza os dados
                oModel:Activate()
                if !lSeekEKU
                    oModel:SetValue("EKU_MASTER", "EKU_FDTLGL", cCodigo)
                endif
                oModel:SetValue("EKU_MASTER", "EKU_FDTDES", cDescricao)
                oModel:SetValue("EKU_MASTER", "EKU_VIGINI", dDataInicio)
                oModel:SetValue("EKU_MASTER", "EKU_VIGFIN", dDataFim)
                if lIntAtrib .and. !empty(cJson)
                    oModel:SetValue("EKU_MASTER", "EKU_ATT_FL", cJson)
                endif

                // Caso a data final não seja vazia e a data atual seja maior que a data final, seta o campo de bloqueado com 1-Sim
                IIF((!Empty(dDataFim) .and. Date() > dDataFim), oModel:SetValue("EKU_MASTER", "EKU_MSBLQL", "1"), oModel:SetValue("EKU_MASTER", "EKU_MSBLQL", "2"))
                
                // Valida os campos e commita se não tiver erros
                IIF(oModel:VldData(), oModel:CommitData(), cErros += cCodigo + ", ")

                // Desativa o modelo de dados e destrói
                oModel:DeActivate()

                IncProc()
                
            Next i

            If !Empty(cErros)
                lErroCommit := .T.
            else
                ExecBloq(aFund, oModel)
            EndIf
        endif

    EndIf

EndIf
// Libera os objetos da memória
FwFreeObj(oModel)
FwFreeObj(oJson)

// Mensagem de retorno
If !Empty(cErros)
    If lErroCommit
        cErros := SubStr(cErros, 1, Len(cErros) - 2) // Retira a última vírgula
        EasyHelp(STR0022 + CRLF + cErros, STR0009, STR0034) // "Não foi possível realizar a importação do(s) seguinte(s) fundamento(s) legal(is)": / "Atenção" / "Os fundamentos legais retornados do Portal Único apresentaram alguma inconsistência e consequentemente não foram integrados."
    Else
        EasyHelp(STR0032 + CRLF + cErros, STR0009) // "Houve o seguinte erro durante a importação do Json do Portal Único:" | "Atenção"
    EndIf
Else
    MsgInfo(STR0024, STR0033) // Importação realizada com sucesso! ### "Importação do Portal Único"
EndIf

Return

/*/{Protheus.doc} getAtrib
   Função para geração dos arrays com os atributos ou detalhes dos atributos
   @type  Static Function
   @author user
   @since 15/05/2025
   @version version
   @param oJson, json a ser extraído os arrays
          aParam, array, parâmetros para indicar se será gerado o array os atributos ou com os detalhes dos atributos
   @return aAtrib, array com o resultado dos atributos ou detalhes dos atributos
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getAtrib(oJson,aParam)
local i:=0
local cCodAtr := ""
local aAtrib := {}

for i:=1 to len(oJson[aParam[1]])
    cCodAtr := oJson[aParam[1]][i][aParam[2]]
    aadd(aAtrib,{cCodAtr,oJson[aParam[1]][i]})
next i
return aAtrib

/*/{Protheus.doc} getJson
   Função para geração da string do json contendo as informações principais junto com as informações dos detalhes de um determinado atributo
   @type  Static Function
   @author user
   @since 15/05/2025
   @version version
   @param cCodigo, string, código do atributo a ser gerado as informações
          cLib, string, indica qual formato de acentuação está sendo utilizado
   @return cJson, string, com o resultado do json
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getJson(cCodigo,cLib)
local nRes := 0
local i:= 0
local cCodDet := ""
local oJson := JsonObject():New()
local oJsonAtr   
local oJsonDet
local cJson := ""
if (nRes := aScan(aAtrib, {|x| x[1] == cCodigo }) ) # 0
    oJson := aAtrib[nRes][2]
    for i:=1 to len(oJson['listaAtributos'])   
        oJsonAtr := oJson['listaAtributos'][i] 
        cCodDet := oJsonAtr['codigo'] 
        oJsonDet := getDetJson(cCodDet)
        getMontajson(oJsonAtr,oJsonDet)
    next i    
Endif
oJson:DelName("codigoFundamentoLegal")
cJson := oJson:toJson()
cJson := IIF("HTML" $ cLib, DecodeUtf8(cJson, 'cp1252'), cJson)
return cJson

/*/{Protheus.doc} getMontaJson
   Função para vai adicionar as propriedades dos detalhes do atributo nas propriedades principais do atributo para a geraçao de um json único por atributo com todas as informaçoes dele
   @type  Static Function
   @author user
   @since 15/05/2025
   @version version
   @param oJsonAtr, json, json dos atributos
          oJsonDet, json, json dos detalhes do atributo
   @return oJsonAtr, json, com o resultado do json agregado dos dois json´s
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getMontajson(oJsonAtr,oJsonDet)
local i:=0
local aNames := oJsonDet:GetNames()
for i := 1 to len(aNames)
    ojsonAtr[aNames[i]] := oJsonDet[aNames[i]]
next i    
Return ojsonAtr


/*/{Protheus.doc} getDetJson
   Função para retorna os detalhes dos atributo enviado no parâmetro
   @type  Static Function
   @author user
   @since 15/05/2025
   @version version
   @param cCodDet, string, string com o código do atributo que deve retornar o detalhe
      @return oJsonDet, json, json com os detalhes do atributo
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getDetJson(cCodDet)
local nRes := 0
local oJsonDet := JsonObject():New()
if (nRes := aScan(aDetalhes, {|x| x[1] == cCodDet }) ) # 0
   oJsonDet := aDetalhes[nRes][2]
Endif
Return oJsonDet

/*/{Protheus.doc} getError
   Função para retorna o erro caso exista
   @type  Static Function
   @author user
   @since 15/05/2025
   @version version
   @param cErros, string com erro na autenticação se teve erro
          cRet, string com o retorno do json da api
          cMsg, string com a mensagem de erro do ch
          cRetErros, string com o retorno de erro da api
   @return lOk, booleano, retorna .t. se houve se não houver erro e .f. se houver erro
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getError(cErros, cRet, cMsg, cRetErros) 
local lOk := .t.
If !Empty(cErros) .or. Empty(cRet)
    lOk := .f.
    IIF(Empty(cRet), cErros := cMsg, cErros := cRetErros) 
EndIf
return lOk

/*/{Protheus.doc} ExecBloq
    Realiza o bloqueio dos fundamentos legais que não retornaram do Portal Único
    
    @type  Static Function
    @author user
    @since 01/07/2025
    @version version
    @param aFund, vetor, fundamento legais que foram atualizados ou inseridos
           oModel, modelo de dados, modelo de dados que está sendo utilizado
           cErros, string, string com os erros que ocorreram durante a importação
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
static function ExecBloq(aFund, oModel, cErros)
    local cQuery    := ""
    local oQuery    := nil
    local cAliasQry := ""
    local nPos      := 0

    default aFund  := {}
    default cErros := ""
    
    if len(aFund) > 0

        cQuery := " SELECT "
        cQuery += " EKU_FILIAL, EKU_FDTLGL "
        cQuery += " FROM " + RetSqlName('EKU') + " EKU "
        cQuery += " WHERE EKU.EKU_FILIAL = ? "
        cQuery += " AND EKU.EKU_MSBLQL = ? "
        cQuery += " AND EKU.D_E_L_E_T_ = ? "
        cQuery += " ORDER BY EKU_FILIAL, EKU_FDTLGL "

        oQuery := FWPreparedStatement():New(cQuery)
        oQuery:SetString( 1, xFilial('EKU')) // EKU_FILIAL
        oQuery:SetString( 2, "2") // EKU_MSBLQL
        oQuery:SetString( 3, " ") // D_E_L_E_T_
        cQuery := oQuery:GetFixQuery()

        cAliasQry := getNextAlias()
        MPSysOpenQuery(cQuery, cAliasQry)
        (cAliasQry)->(dbGoTop())

        if (cAliasQry)->(!eof())
            EKU->(dbSetOrder(1))
        endif

        while (cAliasQry)->(!eof())
            nPos := aScan(aFund, {|x| x == (cAliasQry)->EKU_FDTLGL })
            if nPos == 0 .and. EKU->(DbSeek((cAliasQry)->EKU_FILIAL + (cAliasQry)->EKU_FDTLGL))
                oModel:SetOperation(MODEL_OPERATION_UPDATE)
                if oModel:Activate()
                    oModel:SetValue("EKU_MASTER", "EKU_MSBLQL", "1")
                    if(oModel:VldData(), oModel:CommitData(), cErros += (cAliasQry)->EKU_FDTLGL + ", ")
                endif
                oModel:DeActivate()
            endif
            (cAliasQry)->(dbSkip())
        end
        (cAliasQry)->(dbCloseArea())

        if(!empty(cErros),;
            (cErros := SubStr(cErros, 1, Len(cErros) - 2),EasyHelp( "STR0042" + CRLF + cErros, STR0009, "STR0043")),; // "Não foi possível realizar o bloqueio do(s) seguinte(s) fundamento(s) legal(is):" / "Atenção" / "Verifique se os fundamentos legais citados acima estão corretos."
            nil)

    endif

return nil

/*/{Protheus.doc} VldIntAtrb
    Verifica se o ambiente está preparado para integração dos atributos do fundamento legal

    @type  Static Function
    @author user
    @since 01/07/2025
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
static function VldIntAtrb()
    local lRet       := .F.

    lRet := EKU->(ColumnPos("EKU_ATT_FL")) > 0
    if lRet
        lRet := !comex.generics.IsWebApp() .or. comex.generics.VldVrsWAgt("1.0.22-RC2") // Verificar se é essa versão que está disponível o consumo da API com retorno do arquivo ZIP
    endif

return lRet
