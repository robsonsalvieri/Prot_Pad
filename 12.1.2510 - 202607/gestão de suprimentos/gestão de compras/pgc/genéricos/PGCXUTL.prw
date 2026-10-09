#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PGCXUTL.CH"
#INCLUDE 'FWLIBVERSION.CH'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PGCMsgAuto
    Pega mensagem gerada pelo MSExecAuto e converte para string.
    Antes de chamar esta função utilizar as variáveis privadas lAutoErrNoFile e lMsHelpAuto como .T. (apenas em execuções automáticas).
@author	juan.felipe
@since 08/08/2023
@param cHelpCode, character, código do help retornado por referência.
@param lRemoveHelp, logical, remove código do help.
@return cMessage, caracter, mensagem gerada.
/*/
//-------------------------------------------------------------------
Function PGCMsgAuto(cHelpCode, lRemoveHelp)
	Local aMessage As Array
    Local cMessage As Character
	Local nX    As Numeric
    Local nPos  As Numeric
    Default cHelpCode := ''
    Default lRemoveHelp := .F.

	aMessage := GetAutoGRLog()
    cMessage := ''
    
    For nX := 1 To Len(aMessage)
        cMessage += aMessage[nX] + ' '
    Next nX

    cMessage := StrTran(cMessage, CHR(10), ' ')
    cMessage := FwCutOff(cMessage) //-- Remove TAB e CRLF

    nPos := At(' ', cMessage)
    cHelpCode := Left(cMessage, nPos-1)

    If lRemoveHelp //-- Remove código do help
        cMessage := StrTran(cMessage, cHelpCode + ' ', '')
    EndIf

    FwFreeArray(aMessage)
Return cMessage

//-------------------------------------------------------------------
/*/{Protheus.doc} PGCReqFlds
    Remove a obrigatoriedade dos campos.
@author	juan.felipe
@since 15/08/2023
@param oModel, object, modelo de dados.
@param cModel, character, id do modelo.
@param cModel, character, id do modelo.
@param aNoRemove, array, campos que não devem ter a obrigatoriedade removida.
@return Nil, nulo.
/*/
//-------------------------------------------------------------------
Function PGCReqFlds(oModel, cModel, aNoRemove)
    Local cField As Character
    Local lRequired As Logical
    Local nX As Numeric
	Local oStruct As Object
    Default oModel := Nil
    Default cModel := ''
    Default aNoRemove := {}

    If oModel <> Nil .And. ValType(oModel) == 'O'
	    oStruct	:= oModel:GetModel(cModel):GetStruct()

        For nX := 1 To len(oStruct:aFields)
            cField := oStruct:aFields[nX][MODEL_FIELD_IDFIELD]
            lRequired := oStruct:aFields[nX][MODEL_FIELD_OBRIGAT]

            If aScan(aNoRemove, {|x| x == cField}) == 0 .And. lRequired
                oStruct:SetProperty(cField, MODEL_FIELD_OBRIGAT, .F.) //-- Remove obrigatoriedade do campo
            EndIf
        Next nX
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PGCVldTables
    Valida campos necessários para execução o NFC
@author	juan.felipe
@since 15/08/2023
@param cMessage, mensagem de erro retornada por referência.
@return lRet, logical, retorna .T. se todos os campos forem válidos.
/*/
//-------------------------------------------------------------------
Function PGCVldTables(cMessage, cRoutine, cHelp)
    Local lRet As Logical
    Local lHasSched As Logical
    Local cRelease As Character
    Local cPrefix As Character
    Local oScheduleInfo As Object
    Default cMessage := ''
    Default cRoutine := 'PGCA010'
    Default cHelp := ''

    lRet := .T.

    If cRoutine == 'PGCA010'
        cRelease := '12.1.2210'
        cPrefix := 'PG010'
    Else
        cRelease := '12.1.2510'

        If cRoutine == 'COMA230'
            cPrefix := 'A230'
        Else
            cPrefix := 'A240'
        EndIf
    EndIf

    If cRoutine == 'PGCA010'
        lRet := AliasIndic('DHU') .And. AliasIndic('DHV')
        cHelp := 'PG010DICT'

        lRet := lRet .And. FindFunction('A131SetPGC')

        DbSelectArea("DHU")
        lRet := lRet .And. DHU->(FieldPos('DHU_TPAMR')) > 0 .And. DHU->(FieldPos('DHU_QTDFOR')) > 0
        lRet := lRet .And. DHU->(FieldPos('DHU_QTDPRO')) > 0

        DbSelectArea("SC8")
        lRet := lRet .And. SC8->(FieldPos('C8_SITUAC')) > 0 .And. SC8->(FieldPos('C8_EMAILWF')) > 0
        lRet := lRet .And. SC8->(FieldPos('C8_DIFAL')) > 0 .And. SC8->(FieldPos('C8_BASEDES')) > 0
        lRet := lRet .And. SC8->(FieldPos('C8_PDORI')) > 0 .And. SC8->(FieldPos('C8_PDDES')) > 0
        lRet := lRet .And. SC8->(FieldPos('C8_IDTRIB')) > 0 .And. SC8->(FieldPos('C8_QTDISP')) > 0

        DbSelectArea("SCE")
        lRet := lRet .And. SCE->(FieldPos('CE_NUMPED')) > 0 .And. SCE->(FieldPos('CE_ITEMPED')) > 0
        lRet := lRet .And. SCE->(FieldPos('CE_NUMCTR')) > 0
    EndIf

    If !lRet
        cMessage := STR0001 //-- O dicionário de dados do sistema está desatualizado. Contate o administrador do sistema para que o ambiente seja atualizado com a última versão da expedição contínua.
    EndIf

    If cRoutine == 'COMA230'
        cHelp := 'A230CONFIG'

        If lRet .And. !FwIsInCallStack('PGCA010')
            lHasSched := !Empty(FWSchdByFunction('A230EXECSCHED'))
            oScheduleInfo := totvs.framework.schedule.information.ScheduleInformation():New()

            If FWLibVersion() < "20240424" .Or. !(totvs.framework.smartschedule.startSchedule.smartSchedIsRunning() .Or. (MethIsMemberOf(oScheduleInfo , "getEnvironmentsScheduleRunning") .And. Len(oScheduleInfo:getEnvironmentsScheduleRunning(2)) > 0)) 
                cMessage += STR0033 + CRLF + CRLF //-- É necessário que o Smart Schedule esteja em execução.
                lRet := .F.
            EndIf

            FreeObj(oScheduleInfo)

            If !lHasSched
                cMessage += STR0034 + CRLF //-- É necessário configurar o agendamento A230EXECSCHED no Smart Schedule.
                lRet := .F.
            EndIf

            If !A230EmpFilSched()
                If !lHasSched
                    cMessage += CRLF
                EndIf

                cMessage += STR0035 + CRLF //-- O agendamento A230EXECSCHED do Smart Schedule não possui configuração para a empresa/filial logada no sistema.
                lRet := .F.
            EndIf

            If !lRet
                cMessage := STR0036 + CRLF + CRLF + cMessage + CRLF + CRLF //-- Para utilizar a funcionalidade de transferência temporária, as seguintes configurações devem ser realizadas:
                cMessage += STR0037 //-- Contate o administrador do sistema para que o ambiente seja configurado conforme a documentação oficial.
            EndIf
        EndIf
    EndIf

    If GetRpoRelease() < cRelease //-- Valida versão do RPO
        cHelp := cPrefix + 'RELEASE'
        cMessage := STR0040 + ' ' + cRelease //-- Para acessar esta rotina é necessário utilizar um Release igual ou superior ao 12.1.XX10
        lRet := .F.
    EndIf
Return lRet

/*/{Protheus.doc} PGCCarEsp(cTexto)
Função que limpa os caracteres especiais de uma String informada

@author rd.santos
@since 10/10/2023
@param cTexto, character, Texto recebido.
@return cTexto, Texto ajustado.
@version 12
/*/

Function PGCCarEsp(cTexto)
    Local aCarEsp	  := {"'","#","%","*","&",">","<","!","@","$","(",")","_","=","+","{","}","[","]","?","\","|",":",";",'"','°','ª'}
    Local nI		  := 0
    Default cTexto    := ''

    For nI := 1 To Len(aCarEsp)
    	If aCarEsp[nI] == "&"
    		cTexto := StrTran(cTexto,aCarEsp[nI],"E") 
    	Else
    		cTexto := StrTran(cTexto,aCarEsp[nI]," ")
    	Endif 
    Next nI
	
Return cTexto

/*/{Protheus.doc} NFCLineToJs
	Converte linha de um Grid MVC e retorna em formato Json.
@author juan.felipe
@since 01/02/2024
@param oModelGrid, object, código da resposta.
@param cCopy, character, campos a serem copiados (caso esteja vazio copia tudo).
@return oJsonData, object, json com os dados.
/*/
Function NFCLineToJs(oModelGrid, nLine, cCopy)
    Local aFields As Array
    Local cField As Character
    Local nX As Numeric
    Local oJsonData As Object
    Local oStruct As Object
    Default oModelGrid := Nil
    Default nLine := 1
    Default cCopy := ''
    
    oJsonData := JsonObject():New()

    If oModelGrid <> Nil
        oStruct := oModelGrid:GetStruct()
        aFields := oStruct:GetFields()

        oModelGrid:GoLine(nLine)

        For nX := 1 To Len(aFields)
            cField := aFields[nX][3]

            If Empty(cCopy) .Or. aFields[nX][3] $ cCopy //-- Não copia campos que não estão em cCopy
                oJsonData[cField] := oModelGrid:GetValue(cField)
            Else
                oJsonData[cField] := oModelGrid:InitValue(cField)
            EndIf
        Next nX
    EndIf
Return oJsonData

/*/{Protheus.doc} NFCAddLine
	Adiciona uma nova linha a um Grid MVC a partir de um Json com os dados
@author juan.felipe
@since 01/01/2024
@param oModelGrid, object, código da resposta.
@return oJsonData, object, json com os dados.
/*/
Function NFCAddLine(oModelGrid, oJsonData)
    Local lOk As Logical
    Local nY As Numeric
    Local oModel As Object
    Default oModelGrid := Nil
    Default oJsonData := JsonObject():New()

    lOk := .F.

    If oModelGrid <> Nil
        oModel := oModelGrid:GetModel()

        oModelGrid:AddLine()

        For nY := 1 To Len(oJsonData:GetNames())
            If !oModel:HasErrorMessage()
                cField := oJsonData:GetNames()[nY]
                xValue := oJsonData[cField]
                
                If ValType(xValue) == 'C' .And. oModelGrid:CanSetValue(cField)
                    oModelGrid:SetValue(cField, xValue)
                Else
                    oModelGrid:LoadValue(cField, xValue)
                EndIf

                lOk := !oModel:HasErrorMessage()
            EndIf
        Next nY
    EndIf
Return lOk

/*/{Protheus.doc} NFCVldEmail
	Valida uma lista de e-mails separados por ponto e vírgula.
@author juan.felipe
@since 02/2024
@param cEmails, character, lista de e-mails
@param cMessage, character, mensagem (retornada por referência).
@param cSolution, character, solução (retornada por referência).
@param lSemicolon, logical, indica se valida ponto e vírgula.
@return lRet, logical, indica se os e-mails são válidos.
/*/
Function NFCVldEmail(cEmails, cMessage, cSolution, lSemicolon)
    Local lRet As Logical
    Local nX As Numeric
    Local aEmails As Array
    Default cEmails := ''
    Default cMessage := ''
    Default cSolution := ''
    Default lSemicolon := .F.

    aEmails := Separa(cEmails, ';')
    lRet := .T.

    If lSemicolon
        If Len(aEmails) > 1
            cMessage := STR0002 //-- Formato do campo e-mail inválido.
            cSolution := STR0007 //-- Verifique o formato do e-mail digitado.
            lRet := .F.
        EndIf
    EndIf

    If lRet
        For nX := 1 To Len(aEmails)
            If !IsEmail(aEmails[nX])
                lRet := .F.
                cMessage := STR0002 //-- Formato do campo e-mail inválido.
                cSolution := STR0003 //-- Verifique se os e-mails estão no formato correto, ou se estão separados por ponto e vírgula.
                Exit
            EndIf
        Next nX
    EndIf

    FwFreeArray(aEmails)
Return lRet

/*/{Protheus.doc} NFCIsLocked
	Verifica se o registro está bloqueado por outro usuário.
@author juan.felipe
@since 19/04/2024
@param cAlias, character, alias da tabela.
@param cTableName, character, nome da tabela.
@param cKeyReg, character, chave do registro.
@param cMessage, character, mensagem retornada por referência.
@return lRet, logical, retorna .T. se estiver bloqueado.
/*/
Function NFCIsLocked(cAlias, cTableName, cKeyReg, cMessage)
    Local lRet As Logical
    Local nRecno As Numeric
    Default cAlias := ''
	Default cTableName := ''
    Default cKeyReg := ''
    Default cMessage := ''

    If lRet := !(cAlias)->(RLock())
        //-- O Registro XXX da tabela (XXX) não pode ser utilizado/alterado pois está em uso por outro usuário. Tente novamente em alguns minutos.
        cMessage := STR0004 + ' ' + cKeyReg + ' ' + STR0005 + ' ' + cTableName + ' (' + cAlias + ') ' + STR0006
    Else
        nRecno := (cAlias)->(Recno())
        (cAlias)->(DBRUnlock(nRecno))
    EndIf
Return lRet

/*/{Protheus.doc} NFCSetContactList
	Insere no json de retorno a listagem de contatos cadastradas na DKI
@author Leandro Fini
@since 04/2024
@param oJsonResponse, object, json com os fornecedores que devem ter os contatos carregados.
@param nOption, numeric, opção para definir de quais propriedades carregar os dados.
/*/
Function NFCSetContactList(oJsonResponse, nOption, cMessage)
    Local aItems as Array
    Local aDataSup as Array
    Local nLenItems As Numeric
    Local nX As Numeric
    Local cSupplierCode As Character
    Local cSupplierStore As Character
    Local cCompanyName As Character
    Local cSupplier AS Character
    Local cContactList As Character
    Local cEmail As Character
    Local lParticipant As Logical
    Default oJsonResponse := JsonObject():New()
    Default nOption := 1
    Default cMessage := ''

    If nOption == 3
        aItems := oJsonResponse['suppliers']
    ElseIf nOption == 4
        aItems := oJsonResponse['proposals']
    Else
        aItems := oJsonResponse['items']
    EndIf

    nLenItems := Len(aItems)
    nX := 1
    cContactList := ''

    if FwAliasInDic("DKI")
        DbSelectArea("DKI")
        DKI->(DbSetOrder(1))//DKI_FILIAL+DKI_FORNEC+DKI_LOJA+DKI_ITEM

        While nX <= nLenItems
            cSupplierCode := if(nOption == 1 .Or. nOption == 3 .Or. nOption == 4, aItems[nX]['suppliercode'], aItems[nX]['supplier'])
            cSupplierStore := aItems[nX]['store']
            cContactList := ""

            if( DKI->(DbSeek(fwxFilial("DKI")+cSupplierCode+cSupplierStore)) )
                While ( DKI->DKI_FILIAL == fwxFilial("DKI") .and. DKI->DKI_FORNEC == cSupplierCode .and. DKI->DKI_LOJA == cSupplierStore )
                    if DKI->DKI_WFNFC == '1' // -- Envia WF para este contato = Sim
                        cContactList += Alltrim(DKI->DKI_EMAIL) + ";"
                    endif
                    DKI->(DbSkip())
                EndDo
            endif

            If !Empty(cContactList)
                cContactList := SubStr(cContactList, 1, Len(cContactList) - 1) //-- Remove último caracter "ponto e vírgula"
            EndIf

            If nOption == 3
                aItems[nX]['emaillist'] := IIf(!Empty(cContactList), cContactList, aItems[nX]['email'])
            Else
                aItems[nX]['emaillist'] := cContactList
            EndIf

            If nOption == 4 //-- Carrega dados via ExecAuto de geração da cotação
                lParticipant := Empty(aItems[nX]['suppliercode']) .And. Empty(aItems[nX]['store'])

                If !lParticipant
                    aDataSup := GetAdvFVal('SA2', {'A2_NOME', 'A2_EMAIL'}, xFilial('SA2') + cSupplierCode + cSupplierStore, 1)
                    cCompanyName := aDataSup[1]
                    cEmail := aDataSup[2]

                    aItems[nX]['companyname'] := cCompanyName
                    aItems[nX]['email'] := ''

                    If !Empty(cContactList)
                        aItems[nX]['email'] := cContactList
                    Else
                        If !Empty(cEmail)
                            aItems[nX]['email'] := cEmail
                        EndIf
                    EndIf
                EndIf

                If Empty(aItems[nX]['email']) .And. oJsonResponse:HasProperty('sendWorkflow') .And. oJsonResponse['sendWorkflow'] //-- Valida quando for envio de workflow
                    cSupplier := Iif(lParticipant,  aItems[nX]['companyname'], AllTrim(cSupplierCode) + "-" + AllTrim(cSupplierStore))
                    cMessage := STR0039 + ' ' + cSupplier //-- Não foram informados e-mails para o fornecedor XXXX
                    Exit
                EndIf
            EndIf

            nX ++
        EndDo
    endif
Return cContactList

/*/{Protheus.doc} NFCVldQuery
	Valida se a query pode ser executada sem erros.
@author juan.felipe
@since 21/05/2024
/*/
Function NFCVldQuery(cQuery)          
    Local lRet As Logical
    Local nQueryRet As Numeric
    Default cQuery := ''

    lRet := .T.
    nQueryRet  := 0
    
    nQueryRet := TCSQLEXEC(cQuery)
    
    If nQueryRet < 0
        lRet := .F.
    Endif
Return lRet

/*/{Protheus.doc} getQtySC8(cQuoteNumber)
Função para retornar a quantidade de fornecedores e produtos 

@author Leandro Fini
@since 02/2024
@param cQuoteNumber, character, número da cotação recebida.
@return oJsonResponse com as propriedades suppliers e products.
@version 12
/*/
Function getQtySC8(cQuoteNumber as character, oItemsSC8 as object)

    Local oJsonResponse As Object
    Local oJsonAux      As Object
    Local oJsonAux1     As Object
    local cQuery        as character
    local oQuery        as object
    local cAliasTmp     as character
    local aSuppliers    as array
    local aProducts     as array
    local cKey          as character
    local cSupKey       as character
    local cItem         as character

    default cQuoteNumber := ""
    default oItemsSC8   := JsonObject():New()

    cQuery := " SELECT DISTINCT SC8.C8_ITEM, SC8.C8_PRODUTO, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_QUANT, "
    cQuery += " SC1.C1_DATPRF, SC1.C1_CC, SC1.C1_CONTA, SC1.C1_ITEMCTA, SC1.C1_CLVL, SC1.C1_NUM, SC1.C1_ITEM "
    cQuery += "   FROM " + RetSQLName("SC8") + " SC8 "
    cQuery += "   LEFT JOIN " + RetSQLName("SC1") + " SC1 " 
    cQuery += "         ON SC1.C1_FILIAL    = SC8.C8_FILIAL "
    cQuery += "        AND SC1.C1_NUM       = SC8.C8_NUMSC "
    cQuery += "        AND SC1.C1_ITEM      = SC8.C8_ITEMSC " 
    cQuery += "        AND SC1.D_E_L_E_T_   = ' ' "
    cQuery += "   WHERE "
    cQuery += "     SC8.C8_FILIAL = ? "
    cQuery += "     AND SC8.C8_NUM = ? "
    cQuery += "     AND SC8.C8_ORIGEM <> 'PGCA020' "
    cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "

    oQuery := FwExecStatement():New(cQuery)
    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuoteNumber)       

    cAliasTmp := oQuery:OpenAlias()

    aProducts   := {}
    aSuppliers  := {}

    oJsonResponse := JsonObject():New()
    oJsonAux := JsonObject():New()

    While !(cAliasTmp)->(eof())
        oJsonResponse["products"]  := {}
        oJsonResponse["suppliers"] := {}

        cKey := Alltrim((cAliasTmp)->C8_PRODUTO) + "|" + Alltrim((cAliasTmp)->C1_DATPRF) + "|" + Alltrim((cAliasTmp)->C1_CC) + "|" + ; 
                 Alltrim((cAliasTmp)->C1_CONTA) + "|" + Alltrim((cAliasTmp)->C1_ITEMCTA) + "|" + Alltrim((cAliasTmp)->C1_CLVL)

        if aScan(aProducts, {|x| x == cKey}) == 0
            aAdd(aProducts, cKey)
            cItem := (cAliasTmp)->C8_ITEM
            oJsonAux1 := JsonObject():New()
            oJsonAux[cKey] := {}
            oJsonAux1["productcode"] := (cAliasTmp)->C8_PRODUTO
            oJsonAux1["qty"] := (cAliasTmp)->C8_QUANT
            oJsonAux1["item"] := cItem
            oJsonAux1["request"] := (cAliasTmp)->C1_NUM
            oJsonAux1["itemRequest"] := (cAliasTmp)->C1_ITEM
            oJsonAux[cKey] := oJsonAux1

            If oItemsSC8[cItem] == NIL
                oItemsSC8[cItem]            := JsonObject():New()
                oItemsSC8[cItem]["count"]   := 1
                oItemsSC8[cItem]["used"]    := .F.
            Else
                oItemsSC8[cItem]["count"]++
            EndIf

        endif
        cSupKey := Alltrim((cAliasTmp)->C8_FORNECE) + "|" + Alltrim((cAliasTmp)->C8_LOJA)
        if aScan(aSuppliers, {|x| x == cSupKey }) == 0
            aAdd(aSuppliers, cSupKey)
            //oJsonResponse["suppliers"] := oJsonAux
        endif 
        
        (cAliasTmp)->(dbSkip())
    enddo

     oJsonResponse["suppliers"] := aSuppliers
     oJsonResponse["products"] := oJsonAux

    (cAliasTmp)->(DbCloseArea())

Return oJsonResponse

/*/{Protheus.doc} getQtySC8(cQuoteNumber)
Função para retornar a quantidade de fornecedores e produtos 

@author Leandro Fini
@since 02/2024
@param cQuoteNumber, character, número da cotação recebida.
@return oJsonResponse com as propriedades suppliers e products.
@version 12
/*/
Function existSCE(cFilSCE as character, cQuoteNumber as character, cProductCode as character)

    local cQuery        as character
    local oQuery        as object
    local cAliasTmp     as character
    local lExistSCE     as logical

    default cFilSCE      := ""
    default cQuoteNumber := ""
    default cProductCode := ""
    

    cQuery := " SELECT CE_FILIAL, CE_NUMCOT, CE_PRODUTO FROM " + RetSQLName("SCE") + " SCE"
    cQuery += "   WHERE "
    cQuery += "     SCE.CE_FILIAL = ? "
    cQuery += " AND CE_NUMCOT = ? "
    cQuery += "     AND SCE.CE_PRODUTO = ? "
    cQuery += "     AND SCE.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetString(1, FWxFilial('SCE', cFilSCE))
    oQuery:SetString(2, cQuoteNumber) 
    oQuery:SetString(3, cProductCode)      

    cAliasTmp := GetNextAlias()
    cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

    lExistSCE := .F.

    If !(cAliasTmp)->(eof())
        
        lExistSCE := .T.
        
    Endif

    (cAliasTmp)->(DbCloseArea())

Return lExistSCE

/*/{Protheus.doc} migrateLegacyQuote
Realiza a migração da cotação legada para estrutura do NFC

Etapas:
1 - Executa query na SC8 para verificar cotações a serem migradas.
2 - Compatibilizar e gravar tabela DHU
3 - Compatibilizar e gravar tabela DHV
3 - Atualizar o status da cotação migrada
4 - Atualizar os campos novos - C8_ORIGEM, C8_SITUAC, C8_QTDISP
5 - Compatibilizar preenchimento dos pedidos de compra e contratos já gerados - CE_NUMPED/CE_NUMCTR

@author Leandro Fini
@since 02/2024
@return oJsonResponse, object, resposta no formato json.
/*/
Function migrateLegacyQuote(cEmpEnv,cFilEnv,cInitialDate,cEndDate,cEmail)

    Local oJsonData     As Object
    local cAliasTmp     as character
    local cQuote        as character
    local cSupplier     as character
    local cStore        as character
    local aProducts     as array
    local cProductCode  as character
    local nQty          as numeric
    local dDatPRF       as date
    local nX            as numeric
    local cItem         as character
    local cUpdateQry    as character
    local aQuoteList    as array
    local cBody         as character
    local aDataItem     as array
    local cFilialSC8    as character
    local aDataProd     as array
    Local aUpdSc8       as array
    Local aUpdSce       as array
    local cFilialSB1    as character
    local cKeyAdjTbs    as character
    local lAdjTbs       as logical
    local oObjComp      as Object
    Local oItemsSC8     as Object
    Local oAdjTbs       as Object

    Default cInitialDate := ""
    Default cEndDate     := ""
    Default cEmail       := ""

    RpcSetEnv(cEmpEnv,cFilEnv)

    _migrationStatus := 1

    FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0012)// -- "Registros encontrados, iniciando migracao ..."

    cAliasTmp := getLegacyQuot(cInitialDate,cEndDate)

    cQuote      := ""
    cSupplier   := ""
    cStore      := ""
    cBody       := ""
    aProducts   := {}
    aQuoteList  := {}
    aDataItem   := {}
    aDataProd   := {}

    cFilialSC8  := fwxFilial("SC8")
    cFilialSB1  := fwxFilial("SB1")
    oObjComp    := JsonObject():New()

    DbSelectArea("SCE")
    SCE->(DbSetOrder(1))//CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_FORNECE+CE_LOJA

    DbSelectArea("SC8")
    SC8->(DbSetOrder(1))//C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

    (cAliasTmp)->(DbGoTop())

    Begin Transaction

        While !(cAliasTmp)->(eof())

            cQuote  := (cAliasTmp)->C8_NUM
            FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0013 +" --> " + cQuote)//Iniciando migracao cotacao
            aDataItem := {}

            DbSelectArea("DHU")
            DHU->(DbSetOrder(1))//DHU_FILIAL + DHU_NUM
            If !(DHU->(Dbseek(fwxFilial("DHU") + cQuote)))

                aAdd(aQuoteList, cQuote)
                aDataItem   := GetAdvFVal("SC8", {"C8_DATPRF", "C8_EMISSAO"}, cFilialSC8 + cQuote, 1)
                dDatPRF     := aDataItem[1]
                oJsonData   := JsonObject():New()
                oItemsSC8   := JsonObject():New()
                oAdjTbs     := JsonObject():New()
                oJsonData   := getQtySC8((cAliasTmp)->C8_NUM, @oItemsSC8)
                aProducts   := oJsonData["products"]:GetNames()
                cKeyAdjTbs  := ""
				aUpdSc8     := {}
				aUpdSce     := {}
				lAdjTbs     := .F.

                FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0014 +" --> " + cQuote)//"1º Etapa - Gravar DHU - Cabeçalho da cotação"
                
                // -- 1º Etapa - Gravar DHU - Cabeçalho da cotação
                Reclock("DHU",.T.)
                    DHU->DHU_FILIAL := (cAliasTmp)->C8_FILIAL
                    DHU->DHU_NUM    := cQuote
                    DHU->DHU_STATUS := "1"
                    DHU->DHU_DTEMIS := aDataItem[2]
                    DHU->DHU_AGPCOT := STR0015//"COTAÇÃO LEGADA MIGRADA AUTOMATICAMENTE"
                    DHU->DHU_DTRCOT := dDatPRF
                    DHU->DHU_TPAMR  := "1"
                    DHU->DHU_QTDFOR := len(oJsonData["suppliers"])
                    DHU->DHU_QTDPRO := len(oJsonData["products"]:GetNames())
                    DHU->DHU_LEGACY := "2" //-- Determina que essa cotação é legada e foi migrada. 1=Não/2=Sim
                DHU->(MsUnlock())   

                FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0016 +" --> " + cQuote)//2º Etapa - Gravar DHV - Saldo dos itens da cotação
                // -- 2º Etapa - Gravar DHV - Saldo dos itens da cotação
                aDataProd := {}
     
                For nX := 1 To Len(aProducts) //-- Copia cabeçalho do JSON da requisição para o novo JSON formatado
                    
                    cItem       := oJsonData["products"][aProducts[nX]]["item"]
                    cKeyAdjTbs  := Alltrim(oJsonData["products"][aProducts[nX]]["request"]) + Alltrim(oJsonData["products"][aProducts[nX]]["itemRequest"])

                    // Trativa criada para casos onde o campo C8_ITEM tenha o mesmo codigo.
                    // Dessa forma não salva códigos iguais na DHV_ITEM, visto que DHV_NUM+DHV_ITEM são chaves unicas.
                    If oItemsSC8[cItem]:HasProperty('count') .AND. oItemsSC8[cItem]:HasProperty('used') 
                        If oItemsSC8[cItem]['count'] > 1 .AND. oItemsSC8[cItem]['used']

                            While oItemsSC8[cItem] <> Nil
                                cItem := Soma1(cItem)
                            EndDo
                            
                            oItemsSC8[cItem] := JsonObject():New()
                            oItemsSC8[cItem]['count'] := 1
                            oItemsSC8[cItem]['used']  := .T.
                        Else   
                            oItemsSC8[cItem]['used'] := .T.
                        EndIf
                    EndIf   

                    //  Trativa criada para salvar os itens da DHV, para que seja ajustado posteriormente na SC8 e SCE
                    If oAdjTbs[cKeyAdjTbs] == Nil
                        oAdjTbs[cKeyAdjTbs] := JsonObject():New()
                        oAdjTbs[cKeyAdjTbs]['dhvItem']  := cItem
                    EndIf 
              
                    cProductCode := oJsonData["products"][aProducts[nX]]["productcode"]
                    nQty := oJsonData["products"][aProducts[nX]]["qty"]

                    //Para otimizar buscas e evitar seeks na tabela SB1, gravo as propriedades no JSON
                    if oObjComp[cFilialSB1 + cProductCode] == Nil
                        aDataProd := GetAdvFVal("SB1", {"B1_UM", "B1_SEGUM"}, cFilialSB1 + cProductCode, 1)
                        oObjComp[cFilialSB1 + cProductCode] := aDataProd
                    else
                        aDataProd := oObjComp[cFilialSB1 + cProductCode]
                    endif 
                    
                    Reclock("DHV",.T.)
                        DHV->DHV_FILIAL := (cAliasTmp)->C8_FILIAL
                        DHV->DHV_NUM    := cQuote
                        DHV->DHV_ITEM   := cItem
                        DHV->DHV_CODPRO := cProductCode
                        DHV->DHV_QUANT  := nQty
                        DHV->DHV_SALDO  := if(existSCE((cAliasTmp)->C8_FILIAL,cQuote,cProductCode),0,nQty) //-- Se não existe SCE a cotação está aberta.
                        DHV->DHV_UM     := aDataProd[1]
                        DHV->DHV_SEGUM  := aDataProd[2]
                        DHV->DHV_QSEGUM := 0
                        DHV->DHV_SALSEG := 0
                        DHV->DHV_DATPRF := dDatPRF
                    DHV->(MsUnlock())

                    FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0017 +" --> " + cQuote)//3º Etapa - Gravar o status correto da DHU - Cabeçalho
                    
                    // -- 3º Etapa - Gravar o status correto da DHU - Cabeçalho
                    setQuoteStatus(cQuote)

                    FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0018 +" --> " + cQuote)//4º Etapa - Atualizar campos do NFC na SC8 (C8_ORIGEM, C8_SITUAC, C8_QTDISP)
                    
                    // -- 4º Etapa - Atualizar campos do NFC na SC8 (C8_ORIGEM, C8_SITUAC, C8_QTDISP)
                    cUpdateQry := "UPDATE " + RetSQLName("SC8")
                    cUpdateQry += " SET C8_SITUAC = '1', "
                    cUpdateQry += "C8_ORIGEM = 'PGCA020', "
                    cUpdateQry += "C8_QTDISP = C8_QUANT "
                    cUpdateQry += "WHERE C8_FILIAL = '" + (cAliasTmp)->C8_FILIAL + "' "
                    cUpdateQry += "AND C8_NUM = '"+ cQuote +"' "
                    cUpdateQry += "AND D_E_L_E_T_ = ' ' "

                    TcSqlExec(cUpdateQry)

                Next nX

                FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0019 +" --> " + cQuote)//5º Etapa - Preencher campos de pedidos de compra e contratos gerados (CE_NUMPED,CE_ITEMPED,CE_NUMCTR)
                
                if SC8->(Msseek((cAliasTmp)->(C8_FILIAL+C8_NUM)))
                    While SC8->(!Eof()) .and. SC8->C8_FILIAL == (cAliasTmp)->C8_FILIAL .and. SC8->C8_NUM == (cAliasTmp)->C8_NUM
                        cKeyAdjTbs  := Alltrim(SC8->C8_NUMSC) + Alltrim(SC8->C8_ITEMSC) 
                        lAdjTbs     := oAdjTbs <> Nil .AND. oAdjTbs[cKeyAdjTbs] <> Nil .AND. oAdjTbs[cKeyAdjTbs]:hasproperty('dhvItem')
                        if !empty(SC8->C8_NUMPED) .and. !("XXXX" $ SC8->C8_NUMPED)
                            if SCE->(DbSeek(fwxFilial("SCE") + SC8->(C8_NUM+C8_ITEM+C8_PRODUTO+C8_FORNECE+C8_LOJA)))
                                if empty(SCE->CE_NUMPED)
                                    Reclock("SCE",.F.)
                                        SCE->CE_NUMPED  := SC8->C8_NUMPED
                                        SCE->CE_ITEMPED := SC8->C8_ITEMPED
                                    SCE->(MsUnlock())
                                endif
                                // Manipulação da numeração do item para ficar equivalente a DHV
                                If lAdjTbs
                                    Aadd(aUpdSce, { SCE->(RecNo()), oAdjTbs[cKeyAdjTbs]['dhvItem'] })
                                EndIF
                            endif
                        elseif !empty(SC8->C8_NUMCON) .and. !("XXXX" $ SC8->C8_NUMPED)
                            if SCE->(DbSeek(fwxFilial("SCE") + SC8->(C8_NUM+C8_ITEM+C8_PRODUTO+C8_FORNECE+C8_LOJA)))
                                if empty(SCE->CE_NUMCTR)
                                    Reclock("SCE",.F.)
                                        SCE->CE_NUMCTR := SC8->C8_NUMCON
                                    SCE->(MsUnlock())
                                endif
                                If lAdjTbs
                                    Aadd(aUpdSce, { SCE->(RecNo()), oAdjTbs[cKeyAdjTbs]['dhvItem'] })
                                EndIF
                            endif
                        endif
                        If lAdjTbs
                            Aadd(aUpdSc8, { SC8->(RecNo()), oAdjTbs[cKeyAdjTbs]['dhvItem'] })
                        EndIF
                        SC8->(DbSkip())
                    EndDo
                endif

                If Len(aUpdSc8) > 0 .OR. Len(aUpdSce) > 0 .AND. FindFunction("NFCAdjItsCeC8") 
                    NFCAdjItsCeC8(aUpdSce, aUpdSc8, cQuote)
                EndIf
                FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0020 +" --> " + cQuote)//Finalizado migracao cotacao
            endif

            (cAliasTmp)->(dbSkip())
        enddo

    End Transaction
    FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0021 + DtoC(StoD(cInitialDate)) + " - " + DtoC(StoD(cEndDate)))//Finalizado processo de migracao de cotacoes com datas de emissao de:
    
    if !empty(cEmail)
        //'Migração de cotação' # 'Processo de migração de cotações com data de emissão de ' # foi finalizado
        cBody := NFCHtmlMsg(,cFilAnt,STR0022,STR0023 + " " + DtoC(StoD(cInitialDate)) + ' - ' + DtoC(StoD(cEndDate))+ " " +STR0024)
        NFCSendMail(cEmail,cBody,STR0025)//"NFC - Finalizado processo de migração de cotações"
    endif
    
    (cAliasTmp)->(DbCloseArea())
    
    FreeObj(oJsonData)
    FreeObj(oObjComp)
    FreeObj(oItemsSC8)
    FreeObj(oAdjTbs)
    FwFreeArray(aProducts )
    FwFreeArray(aQuoteList)
    FwFreeArray(aDataItem )
    FwFreeArray(aDataProd )
    FwFreeArray(aUpdSc8)
    FwFreeArray(aUpdSce)
    RpcClearEnv()

Return


/*/{Protheus.doc} getLegacyQuot
Realiza a consulta de registros para serem migrados

@author Leandro Fini
@since 06/2024
@return cAliasTmp --> Tabela temporária contendo os registros
/*/
Function getLegacyQuot(cInitialDate,cEndDate)

    local cQuery        as character
    local oQuery        as object
    local cAliasTmp     as character

    Default cInitialDate := ""
    Default cEndDate     := ""

    FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0026)
    
    cQuery := " SELECT C8_FILIAL, C8_NUM FROM " + RetSQLName("SC8") + " SC8"
    cQuery += "   WHERE "
    cQuery += "     SC8.C8_FILIAL = ? "
    cQuery += "     AND SC8.C8_ORIGEM <> 'PGCA020' "
    cQuery += "     AND SC8.C8_ORIGEM <> 'NFCA020' "
    cQuery += "     AND SC8.C8_EMISSAO >= ? "
    cQuery += "     AND SC8.C8_EMISSAO <= ? "
    cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY C8_FILIAL,C8_NUM "

    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetString(1, FWxFilial('SC8'))   
    oQuery:SetString(2, cInitialDate)   
    oQuery:SetString(3, cEndDate)   
    
    cAliasTmp := GetNextAlias()
    cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

Return cAliasTmp

/*/{Protheus.doc} NFCSendMail
Envio de notificações via e-mail

@author Leandro Fini
@since 06/2024
@param cTo --> Email destinatário
@param cBody --> Body do e-mail, podendo ser html (função NFCHtmlMsg)
@param cSubject --> Assunto do e-mail
/*/
Function NFCSendMail(cTo,cBody,cSubject, oHtml, cUser)
    Local oProcess  := Nil
    Local oWorkflow := Nil
    Local cMailBox  := ''
    Local cIDWF     := ''
    Local cNameWF   := 'NfcWFMsg'
    Local lPgcWF    := WFGetMV( "MV_PGCWF", .F. )
    Local cUserLog  := RetCodUsr()
    Default cTo   := ""
    Default cBody := ""
    Default cSubject := ""
    Default oHtml := Nil
    Default cUser := ""

    If !Empty(cTo)
        FwLogMsg("INFO",,"NFC","PGCXUTL",,,STR0027 +" - " + cSubject)//Inicializando envio de e-mail de notificação

        oWorkflow := pgc.workflowRepository.pgcWorkflowRepository():New()

        If lPgcWF
            cMailBox := oWorkflow:getMailBox(cUser)
        EndIf

        oProcess := TWFProcess():New(cNameWF, 'Envio de notificação via workflow')

        If oHtml == Nil
            oHtml := TWFHtml():New()
            oHtml:LoadStream(cBody)
        EndIf

        If lPgcWF .and. !empty(cMailBox)
            oProcess:oWf:cMailBox := cMailBox
            oProcess:cFrom := cMailBox
        EndIf

        oProcess:cSubject := DecodeUTF8(EncodeUTF8(cSubject)) // Assunto e-mail
        oProcess:cTo := cTo
        oProcess:bReturn  := ''
        oProcess:bTimeOut := {{"__WFTimeout()", 0, 0, 5 }}
        oProcess:UserSiga := cUserLog
        oProcess:oHtml := oHtml
        oProcess:oHTML:lUsaJs  := .F.
        oProcess:oWF:lHtmlBody := .T.
        oProcess:NewVersion(.T.)
        
        cIDWF := oProcess:Start()

        If !Empty(cIDWF)
            FwLogMsg("INFO",,"NFC","PGCXUTL",,,'Envio de e-mail de notificação finalizado' +" - " + cSubject) //Envio de e-mail de notificação finalizado.
        EndIf

        FreeObj(oWorkflow)
        FreeObj(oProcess)
    Else
        FwLogMsg("INFO",,"NFC","PGCXUTL",,,'Não foi informado e-mail para recebimento das notificações.')
    EndIf
Return

/*/{Protheus.doc} NFCHtmlMsg
Template html padrão de envio de notificações do NFC - Novo Fluxo de Compras

@author Leandro Fini
@since 06/2024
@param cTitulo --> Título da notificação
@param cFilMsg --> Filial a que corresponde a notificação.
@param cRotina --> De qual rotina pertence a notificação
@param cMsg    --> A mensagem que deverá ser enviada.
@return cHtml --> String contendo o template html.
/*/
Function NFCHtmlMsg(cTitulo,cFilMsg,cRotina,cMsg)

    Local cHtml as Character

    Default cTitulo := STR0008 //" Notificação - Novo Fluxo de Compras "
    Default cFilMsg := ""
    Default cRotina := ""
    Default cMsg    := ""

    cHtml := '<h1 style= "font: normal normal normal 22px '
    cHtml += " 'open sans' "
    cHtml += ', sans-serif;color: rgb(0, 136, 203);padding-top: 5px;padding-bottom:3px;margin: 5px auto 5px 10px;">'
    cHtml += cTitulo
    cHtml += '</h1>'
    cHtml += '<div style="border-top: solid rgb(0, 136, 203) 2px;padding: 10px 5px 0 10px;margin-right: 15px;margin-top: 10px;">'
    cHtml += '   <table style="font: normal normal normal 14px '
    cHtml += " 'open sans' "
    cHtml += ', sans-serif;text-align: left;border-width:0px;width:100%;">'
    cHtml += '      <tr>'
    cHtml += '         <td style="width:100px;">'+ STR0009 +' </td>' // Filial
    cHtml += '         <td style="width:500px;">'+ cFilMsg + " - " + FwFilialName() +'</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td style="width:100px;">'+ STR0010 +'</td>' //Rotina
    cHtml += '         <td style="width:500px;">'+ cRotina +'</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td colspan="04">'
    cHtml += '            <hr>'
    cHtml += '         </td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td style="width:100px;">'+ STR0011 +'</td>'//Mensagem
    cHtml += '         <td style="width:500px;">' + cMsg + '</td>'
    cHtml += '      </tr>'
    cHtml += '   </table>'
    cHtml += '</div>'

Return cHtml


/*/{Protheus.doc} NFCAdjDHUBase
Ajuste temporário, que deve ser removido na próxima expedição contínua de agosto de 2024.
Serve para ajustar o valor do campo DHU_LEGACY, para mudar o 'S' para o valor '2', igual ao combobox do campo 1=Não/2=Sim.
@author renan.martins
@since 07/2024
@return nil --> nil
/*/
function NFCAdjDHUBase()
Local cQueryUpd := ""

cQueryUpd := " UPDATE " + RetSQLName("DHU")
cQueryUpd += "   SET DHU_LEGACY = '2' "
cQueryUpd += "     WHERE DHU_FILIAL = '" + FWxFilial("DHU") + "' "
cQueryUpd += "       AND DHU_LEGACY = 'S' "
cQueryUpd += "       AND D_E_L_E_T_ = ' ' "

TcSqlExec(cQueryUpd)

return


/*/{Protheus.doc} PGCVldFtWF
    Valida se existem os fontes do Workflow do BI, para envio do e-mails. Se não existir, informar sobre a expedição contínua desse
    módulo na mensagem.
@author	renan.martins
@since 09/2024
@param cMessage, mensagem de erro retornada por referência.
@return lRet, logical, retorna .T. se todos os campos forem válidos.
/*/
Function PGCVldFtWF(cMessage)
    Local lRet      := .T.
    Local aRetFun   := {}
    Local aFontePes := {"WFPROCESS.PRW", "WF.PRW", "WFTSXM.PRW", "WFVISIO.PRW", "WORKFLOW.PRW", "WFRETURN.PRW"}
    Local nFor      := 0
    Local nTamFon   := 0
    Local nIncrem   := 0
    Local oObjSXM   := TSXMTable():New()
    Local cDataWF   := "20230923" //Data que o parâmetro MV_PGCWF foi incluido no WFPROCESS

    //Verifico se os fontes existem no PRW do cliente
    nTamFon := Len(aFontePes)
    For nFor := 1 to nTamFon
        aRetFun := GetSrcArray(aFontePes[nFor])
        if ( len(aRetFun) > 0 )
            nIncrem++
        endif
    next

    if nIncrem != nTamFon
        lRet := .F.
    endif

    if lRet
        aRetFun := {}
        //Verifico se o método existe na classe
        if MethIsMemberOf(oObjSXM , "GrvSxmTskMail")
            //Verifico se a data do fonte WFPROCESS.PRW é igual ou maior que a data de 29/09/23, devido ao parâmetro MV_PGCWF
            aRetFun := GetAPOInfo("WFPROCESS.prw")
            if !(dtos(aRetFun[4]) >= cDataWF)
                lRet := .F.
            endif
        else
            lRet := .F.
        endif
    endif

    if !lRet
        /*STR0038 - Não é possível efetuar o envio do e-mail - pois no Ambiente do sistema - está faltando funcionalidades obrigatórias para o envio do workflow, sendo necessário atualizá-lo.
        STR0037 - Contate o administrador do sistema para que o ambiente seja configurado conforme a documentação oficial. */
        cMessage := STR0038 + CRLF + STR0037
    endif
    FreeObj(oObjSXM)
    FwFreeArray(aRetFun)
    FwFreeArray(aFontePes)

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} filterArray
Filtra um array por determinada condição.

@param aData, array, vetor com as informações originais
@param bCondition, codeblock, condição para execução do filtro

@return array, vetor somente com os itens que satisfazem a condição.
/*/
//-------------------------------------------------------------------------------------
Function ArrFilData( aData, bCondition )
    Local aResult as array
    Default aData       := {}
    Default bCondition  := nil

    aResult := {}

    aEval( aData, {|uValue, nIndex| ;
        If( Eval( bCondition, uValue, nIndex, aData ), ;
            aAdd( aResult, uValue ), ;
        Nil) ;
    })
Return aResult

/*/{Protheus.doc} getUserFil
    Retorna as filiais que o usuário logado tem acesso.
@author	Leandro Fini
@since 03/2026
@return aUserFil -> Array contendo as filiais que o usuário tem acesso.
/*/
Function getUserFil()
    Local aUserFil    as array
    Local aBranches   as array 
    Local aBranchComp as array

    aUserFil    := {}
    aBranches   := {}
    aBranchComp := {}

    aBranches   := FwLoadSM0()
    aBranchComp := ArrFilData( aBranches, {|x| x[ SM0_GRPEMP ] == cEmpAnt  } )
    aUserFil    := ArrFilData( aBranchComp, {|x|  x[ SM0_USEROK ] } )

Return aUserFil

/*/{Protheus.doc} NFCSetReqFld
	Gerencia a variável jReqFldMdls recebida por parametro, controlando desativação da obrigatoriedade do preenchimento dos campos
@author gustavo.pedroso
@since 27/05/2026
@param oModel       , objeto, instância de MPFormModel
@param jReqFldMdls  , json  , Armazena os campos com obrigatoriedade do submodelo
@return Nil, valor nulo
/*/
Function NFCSetReqFld(oModel As Object, jReqFldMdls As Json)
	Local aMdlIdReq     As Object 
	Local aSavedIds	    As Array   
	Local nX            As Numeric   
    Local nSize         As Numeric
	Default oModel      := FwModelActive()
    Default jReqFldMdls := Nil

    aMdlIdReq   := {}
	aSavedIds   := {}
	nX          := 0
    
	If (jReqFldMdls == Nil)		
		jReqFldMdls := JsonObject():New()		
		aSavedIds := {"SC8DETAIL"} //Caso seja necessário liberar outros submodelos, adicionar nesse array		
		aEval(aSavedIds,{|x| jReqFldMdls[x] := NFCGetReq(oModel:GetModel(x))})//Guarda os campos obrigatórios
	EndIf

	aMdlIdReq := jReqFldMdls:GetNames()
    nSize := Len(aMdlIdReq)

	for nX := 1 to nSize
		oModel:GetModel(aMdlIdReq[nX]):GetStruct():SetProperty('*',MODEL_FIELD_OBRIGAT, .F.) //Libera todos os campos
	next nX

    FwFreeArray(aMdlIdReq)
    FwFreeArray(aSavedIds)

Return Nil

/*/{Protheus.doc} NFCGetReq
	Obtem somente os campos obrigatorios do oModel 
@author gustavo.pedroso 
@since 27/05/2026
@param oModel, instância de FWFormGridModel
@return aRet, vetor, contêm lista de campos obrigatorios
/*/
Static Function NFCGetReq(oModel As Object)
	Local aRet	        As Array
	Local nX	        As Numeric
    Local nSize         As Numeric
	Local oStructMdl    As Object 
    Default oModel      := FwModelActive()

    aRet	    := {}
	nX	        :=	0
	oStructMdl	:= oModel:Getstruct()
    nSize       := len(oStructMdl:aFields)	

	For nX := 1 To nSize
        if oStructMdl:aFields[nX][MODEL_FIELD_OBRIGAT]
            aAdd( aRet , oStructMdl:aFields[nX][MODEL_FIELD_IDFIELD] )	
        endif
	Next nX
Return aRet
