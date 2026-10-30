#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA960A.CH"

Static _JsonTables

Function UpdateQLF()
    Local jsonLoop  := JsonObject():New() as Json
    Local jsonSave  := JsonObject():New() as Json
    Local lContinue := .T. as Logical
    Local lFound := .T. as Logical
    Local cCodModule   := "" as Character
    Local cVersion  := "" as Character
    Local nI        := 0 as Numeric

    If AliasInDic("QLF")

        jsonLoop:FromJson(GetModulesInfo())

        for nI := 1 to Len(jsonLoop["items"])

            cCodModule := jsonLoop["items"][nI]["QLF_MODULE"]
            cVersion := GetJsonVersion(cCodModule)

            //Se a função CheckUpdate retornar falso, não há necessidade de atualização
            If (CheckUpdate(cCodModule, cVersion, @lFound) )
                lContinue := .T.

                jsonSave["QLF_MODULE"]  := cCodModule
                jsonSave["QLF_MODNAM"]  := jsonLoop["items"][nI]["QLF_MODNAM"]
                jsonSave["QLF_TABLES"]  := GetJsonTables(cCodModule)
                jsonSave["QLF_VERSIO"]  := cVersion

                SaveJsonOnQLF(jsonSave, lFound)

            EndIf

            //Limpar o Json ao final do loop para receber os dados do próximo item
            jsonSave := JsonObject():New()

        next nI
    Else
        FWAlertHelp(STR0015, STR0016) //"Tabela QLF não encontrada" // "Atualize o dicionário de dados de seu ambiente"
    EndIf
Return

//Retorna as informações basicas da configuração
Static Function GetModulesInfo()
    Local cModuleInfo      := "" as Character
    
    cModuleInfo := '{"items":['+;
                        '{'+;
                            '"QLF_MODULE": "SIGACOM",'+;
                            '"QLF_MODNAM": "' + STR0001 + '"'+; //"COM - Compras"
                        '},'+;
                        '{'+;
                            '"QLF_MODULE": "SIGAFAT",'+;
                            '"QLF_MODNAM": "'+ STR0002+'"'+; //"FAT - Faturamento"
                        '},'+;
                        '{'+;
                            '"QLF_MODULE": "SIGAFIN",'+;
                            '"QLF_MODNAM": "'+ STR0003 +'"'+; //"FIN - Financeiro"
                        '},'+;
                        '{'+;
                            '"QLF_MODULE": "SIGAEST",'+;
                            '"QLF_MODNAM": "'+ STR0004 +'"'+; //"EST - Estoque/Custos"
                        '}'+;
                    ']}'
Return cModuleInfo

/*{Protheus.doc} GetJsonVersion
Retorna a versão das configurações de conciliação

@author: TOTVS
@since 19/04/2023
@version 1.0
*/
Function GetJsonVersion(cCodModule as Character)

    Local cVersion := "" as Character

    If cCodModule == "SIGACOM"
        cVersion := "20231025"
    ElseIf cCodModule == "SIGAFAT"
        cVersion := "20231025"
    ElseIf cCodModule == "SIGAFIN"
        cVersion := "20231025"
    ElseIf cCodModule == "SIGAEST"
        cVersion := "20231025"
    EndIf

Return cVersion

Function C960TabFC(cTable)
If _JsonTables == Nil
    C960LoadTb()
EndIf
Return _JsonTables[cTable]<>Nil

Static Function C960LoadTb()
Local cTables := "SF1/SC7/SF2/SC5/SE1/SE2/SE5/SEF/SEU/SD3"
Local aTables := STRTOKARR( cTables, "/" )
Local nI := 0

_JsonTables := JsonObject():New()

For nI:=1 to Len(aTables)
    _JsonTables[aTables[nI]] := .T.
Next nI

Return 
 

Static Function GetJsonTables(cCodCfg as Character)

    Local cTables := "" as Character

    Local jTables := JsonObject():New() as Json

    If cCodCfg == "SIGACOM"
        cTables :=   '{'+;
                        '"tables": ['+;
                            '{'+;
                                '"table": "SF1",'+; //"Total"
                                '"description": "'+STR0005+'",'+; //"Cabeçalho NF Entrada"
                                '"flagfield":"F1_DTLANC",'+;
                                '"uuidfield":"F1_MSUIDT",'+;
				                '"datefield":"F1_DTDIGIT",'+;
                                '"branchfield":"F1_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '},'+;
                            '{'+;
                                '"table": "SC7",'+; //"Total"
                                '"description": "'+STR0006+'",'+; //"Ped.Compra / Aut.Entrega"
                                '"flagfield":"C7_DTLANC ",'+;
                                '"uuidfield":"C7_MSUIDT",'+;
				                '"datefield":"C7_EMISSAO",'+;
                                '"branchfield":"C7_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '}'+;
                        ']'+;
                    '}'
    ElseIf cCodCfg == "SIGAFAT"
        cTables :=   '{'+;
                        '"tables": ['+;
                            '{'+;
                                '"table": "SF2",'+; //"Total"
                                '"description": "'+STR0007+'",'+; //"Cabeçalho NF Saída"
                                '"flagfield":"F2_DTLANC",'+;
                                '"uuidfield":"F2_MSUIDT",'+;
				                '"datefield":"F2_EMISSAO",'+;
                                '"branchfield":"F2_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '},'+;
                            '{'+;
                                '"table": "SC5",'+; //"Total"
                                '"description": "'+STR0008+'",'+; //Pedidos de Venda
                                '"flagfield":"C5_DTLANC",'+;
                                '"uuidfield":"C5_MSUIDT",'+;
				                '"datefield":"C5_EMISSAO",'+;
                                '"branchfield":"C5_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '}'+;
                        ']'+;
                    '}'
    ElseIf cCodCfg == "SIGAFIN"
        cTables :=   '{'+;
                        '"tables": ['+;
                            '{'+;
                                '"table": "SE1",'+; //"Total"
                                '"description": "'+ STR0009 +'",'+; //Contas a Receber
                                '"flagfield":"E1_LA",'+;
                                '"uuidfield":"E1_MSUIDT",'+;
				                '"datefield":"E1_EMISSAO",'+;
                                '"branchfield":"E1_FILIAL",'+;
				                '"aditionalcondition":" AND E1_ORIGEM <> ' + "'FINA677'" + ' "'+;
                            '},'+;
                            '{'+;
                                '"table": "SE2",'+; //"Total"
                                '"description": "'+ STR0010 +'",'+; //Contas a Pagar
                                '"flagfield":"E2_LA",'+;
                                '"uuidfield":"E2_MSUIDT",'+;
				                '"datefield":"E2_EMISSAO",'+;
                                '"branchfield":"E2_FILIAL",'+;
				                '"aditionalcondition":" AND E2_ORIGEM <> ' + "'FINA677'" + ' "'+;
                            '},'+;
                            '{'+;
                                '"table": "SE5",'+; //"Total"
                                '"description": "'+ STR0011 +'",'+; //Movimentos Bancários
                                '"flagfield":"E5_LA",'+;
                                '"uuidfield":"E5_MSUIDT",'+;
				                '"datefield":"E5_DATA",'+;
                                '"branchfield":"E5_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '},'+;
                            '{'+;
                                '"table": "SEF",'+; //"Total"
                                '"description": "'+ STR0012 +'",'+; //Cheques
                                '"flagfield":"EF_LA",'+;
                                '"uuidfield":"EF_MSUIDT",'+;
				                '"datefield":"EF_DATA",'+;
                                '"branchfield":"EF_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '},'+;
                            '{'+;
                                '"table": "SEU",'+; //"Total"
                                '"description": "'+ STR0013 +'",'+;
                                '"flagfield":"EU_LA",'+;
                                '"uuidfield":"EU_MSUIDT",'+;
				                '"datefield":"EU_DTDIGIT",'+;
                                '"branchfield":"EU_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '}'+;
                        ']'+;
                    '}'
    ElseIf cCodCfg == "SIGAEST"
        cTables :=   '{'+;
                        '"tables": ['+;
                            '{'+;
                                '"table": "SD3",'+; //"Total"
                                '"description": "'+ STR0014 +'",'+; //Movimentações internas
                                '"flagfield":"D3_DTLANC",'+;
                                '"uuidfield":"D3_MSUIDT",'+;
				                '"datefield":"D3_EMISSAO",'+;
                                '"branchfield":"D3_FILIAL",'+;
				                '"aditionalcondition":""'+;
                            '}'+;
                        ']'+;
                    '}'
    EndIf

    jTables:FromJson(cTables)

Return jTables

/*/{Protheus.doc} CheckUpdate
    Verifica se há necessidade de atualizar a configuração
    @type  Static
    @author caio
    @since 19/04/2023
    @version 12.1.2210
    @param
        cCodCfg, Character, Codigo de configuração
        cVersion, Character, Codigo de versão
    @return
        lRet, Logico, Se deve ou não atualizar
    /*/
Static Function CheckUpdate(cCodModule as Character, cVersion as Character, lFound as Logical)

    Local lRet      := .T. as Logical

    QLF->(dbSetOrder(1))
    lFound := (QLF->(MsSeek(xFilial("QLF")+cCodModule)))

    //Se encontrar, confiro se a versão em QLF é menor que a versão do Json no fonte.
    If lFound
        // Se sim, devo atualizar a QLF
        If Empty(QLF->(QLF_VERSIO)) .Or. QLF->(QLF_VERSIO) < cVersion
            lRet := .T.
        Else
        //Se não, não devo atualizar
            lRet := .F.
        EndIf
    Else
        //Se não encontrar, deve atualizar (Incluir configuração)
        lRet := .T.
    EndIf

Return lRet

Static Function SaveJsonOnQLF(jsonSave as Json, lJaExisteQLF as Logical)

    QLF->(dbSetOrder(1))

    RecLock("QLF", !lJaExisteQLF)
    QLF->QLF_FILIAL := xFilial("QLF")
    QLF->QLF_MODULE := jsonSave["QLF_MODULE"]
    QLF->QLF_MODNAM := jsonSave["QLF_MODNAM"]
    QLF->QLF_TABLES := jsonSave["QLF_TABLES"]:toJson()
    QLF->QLF_VERSIO := jsonSave["QLF_VERSIO"]

    QLF->(MsUnlock())

Return
