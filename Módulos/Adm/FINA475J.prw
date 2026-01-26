#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA475J.CH"

STATIC __lPosGrv  := NIL
STATIC __lPosCan  := NIL
STATIC __lActions := NIL
STATIC __lIgnore  := NIL
STATIC __lLegends := NIL
STATIC __lExpciMI := NIL 
//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA475J
    Verificação e atulização das configurações Financeiras no Conciliador Backoffice

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310
/*/
//-------------------------------------------------------------------------------------------
Function FINA475J()
    If QLB->(FieldPos("QLB_VERSAO")) > 0 .and. QLB->(FieldPos("QLB_LEGEND")) > 0 
        UpdateQLB()
    Else
        FWAlertHelp( STR0001 ;//"Não foi encontrado o campo QLB_VERSAO em seu dicionário de dados";
            , STR0002 ) //"Atualize seu dicionário de dados com a expedição continua para incluir o campo, assim poderemos atualizar e implementar novas configurações de forma automática em seu Conciliador."
    EndIf
Return

Static Function UpdateQLB()

    Local cCodCfg   := ""                 as Character
    Local cVersion  := ""                 as Character
    Local jsonLoop  := JsonObject():New() as Json
    Local jsonSave  := JsonObject():New() as Json
    Local lFound    := .T.                as Logical
    Local nI        := 0                  as Numeric

    //Pós Gravação
    If __lPosGrv == NIL
        __lPosGrv := QLB->(FieldPos("QLB_POSGRV")) > 0
    Endif
    //Pós Cancelamento
    If __lPosCan == NIL
        __lPosCan := QLB->(FieldPos("QLB_POSCAN")) > 0
    Endif
    //Ações da configuração
    If __lActions == NIL
        __lActions := (QLB->(FieldPos("QLB_ACTEFT")) > 0)
    Endif
    //Habilitar ação de ignorar registros
    If __lIgnore == NIL 
        __lIgnore  := (QLB->(FieldPos("QLB_IGNORE")) > 0)
    Endif
    //Configuração de Legendas
    If __lLegends == NIL 
        __lLegends := (QLB->(FieldPos("QLB_LEGEND")) > 0) 
    Endif

    jsonLoop:FromJson(GetJsonCfgInfo())  
    
    for nI := 1 to Len(jsonLoop["items"])

        cCodCfg := jsonLoop["items"][nI]["codcfg"]
        cVersion := GetJsonVersion(cCodCfg)
        
        //Se a função CheckUpdate retornar falso, não há necessidade de atualização
        If (CheckUpdate(cCodCfg, cVersion, @lFound) )

            jsonSave["codcfg"]  := cCodCfg
            jsonSave["descfg"]  := jsonLoop["items"][nI]["descfg"]
            jsonSave["tabori"]  := jsonLoop["items"][nI]["tabori"]
            jsonSave["descor"]  := jsonLoop["items"][nI]["descor"]
            jsonSave["tabdes"]  := jsonLoop["items"][nI]["tabdes"]
            jsonSave["descde"]  := jsonLoop["items"][nI]["descde"]
            jsonSave["fields"]  := GetJsonFields(cCodCfg) 
            jsonSave["filter"]  := GetJsonFilters(cCodCfg)
            jsonSave["cidori"]  := GetCIDFields(cCodCfg, /*lIDOrigem*/ .T.)
            jsonSave["ciddes"]  := GetCIDFields(cCodCfg, /*lIDOrigem*/ .F.)
            jsonSave["regmat"]  := GetJsonRegMatch(cCodCfg)
            jsonSave["total"]   := GetJsonTotal(cCodCfg)
            jsonSave["version"] := cVersion

            If __lPosGrv
                jsonSave["posgrv"] := GetPosGrv(cCodCfg, .T.)
            Endif

            If __lPosCan
                jsonSave["poscan"] := GetPosGrv(cCodCfg, .F.)
            Endif

            If __lActions
                jsonSave["actions"]  := GetJsonActions(cCodCfg)
            Endif

            If __lIgnore
                jsonSave["ignore"]  := GetJsonIgnore(cCodCfg)
            EndIf

            If __lLegends
                jsonSave["legends"]  := GetJsonLegends(cCodCfg)
            EndIf

            //Gravar os dados na QLB
            SaveJsonOnQLB(jsonSave, lFound)

        EndIf

        //Limpar o Json ao final do loop para receber os dados do próximo item
        jsonSave := JsonObject():New()

    next nI
Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonCfgInfo
    Retorna as informações basicas da configuração

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @return cCfgInfo, Character, informações basicas da configuração

/*/
//-----------------------------------------------------------------------------------
Static Function GetJsonCfgInfo()
    Local cCfgInfo := "" as Character

    cCfgInfo := '{"items":['
    cCfgInfo +=    '{'
    cCfgInfo +=         '"codcfg": "0023",'
    cCfgInfo +=         '"descfg": "'+ STR0003 + '",' //"Conciliação Bancária Automática"
    cCfgInfo +=         '"tabori": "SIG",'
    cCfgInfo +=         '"descor": "'+ STR0004 + '",' //"Movimentos Extrato"
    cCfgInfo +=         '"tabdes": "FK5",'
    cCfgInfo +=         '"descde": "'+ STR0005 +'"'     //"Movimentos Bancários"
    cCfgInfo +=     '},'
    cCfgInfo +=     '{'
    cCfgInfo +=         '"codcfg": "0024",'
    cCfgInfo +=         '"descfg": "'+ STR0006 +'",' //"Conciliação Bancária Manual"
    cCfgInfo +=         '"tabori": "SIG",'
    cCfgInfo +=         '"descor": "'+ STR0004 +'",' //"Movimentos Extrato"
    cCfgInfo +=         '"tabdes": "FK5",'
    cCfgInfo +=         '"descde": "'+ STR0005 +'"' //"Movimentos Bancários"
    cCfgInfo +=     '}'
    cCfgInfo += ']}'
    
Return cCfgInfo

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonFields
    Retorna Json com os campos das tabelas de origem e destino utilizados
    na regra de Conciliação.

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param  cCodCfg, Character, Código da configuração
    @return jFields , Json    , Campos da configuração

/*/
//-----------------------------------------------------------------------------------
Static Function GetJsonFields(cCodCfg as Character) 

    Local cFields := "" as Character
    Local jFields := JsonObject():New() as Json

    If  cCodCfg $ "0023|0024"
        cFields :=  '{'
        cFields +=      '"data_ori": ['
        cFields +=          '"IG_DTEXTR",'
        cFields +=          '"IG_DOCEXT",'
        cFields +=          '"IG_VLREXT",'
        cFields +=          '"IG_HISTEXT",'
        cFields +=          '"IG_CARTER",'
        cFields +=          '"IG_BCOEXT",'
        cFields +=          '"IG_AGEEXT",'
        cFields +=          '"IG_CONEXT",'
        cFields +=          '"IG_FILIAL"'
        cFields +=      '],'
        cFields +=      '"data_des": ['

        If cCodCfg == "0023"
            cFields +=          '"FK5_DTDISP",'
            cFields +=          '"FK5_VALOR",'
            cFields +=          '"FK5_HISTOR",'
            cFields +=          '"FK5_NUMCH",'
            cFields +=          '"FK5_RECPAG",'
            cFields +=          '"FK5_BANCO",'
            cFields +=          '"FK5_AGENCI",'
            cFields +=          '"FK5_CONTA",'
            cFields +=          '"FK5_NATURE",'
            cFields +=          '"FK5_FILORI",'
            cFields +=          '"E5_PREFIXO",'
            cFields +=          '"E5_NUMERO",'
            cFields +=          '"E5_PARCELA",'
            cFields +=          '"E5_TIPO",'
            cFields +=          '"E5_CLIFOR",'
            cFields +=          '"E5_LOJA",'
            cFields +=          '"FK5_IDMOV",'
            cFields +=          '"FK5_IDFK7"'
        Else
            cFields +=          '"FK5_FILORI",'
            cFields +=          '"FK5_DTDISP",'
            cFields +=          '"FK5_DATA",'
            cFields +=          '"FK5_MOEDA",'
            cFields +=          '"FK5_VALOR",'
            cFields +=          '"FK5_NATURE",'
            cFields +=          '"FK5_BANCO",'
            cFields +=          '"FK5_AGENCI",'
            cFields +=          '"FK5_CONTA",'
            cFields +=          '"FK5_NUMCH",'
            cFields +=          '"FK5_DOC",'
            cFields +=          '"FK5_RECPAG",'
            cFields +=          '"FK5_BENEF",'
            cFields +=          '"FK5_HISTOR",'
            cFields +=          '"E5_PREFIXO",'
            cFields +=          '"E5_NUMERO",'
            cFields +=          '"E5_PARCELA",'
            cFields +=          '"E5_TIPO",'
            cFields +=          '"E5_CLIFOR",'
            cFields +=          '"E5_LOJA",'
            cFields +=          '"E5_CREDITO",'
            cFields +=          '"FK5_IDMOV",'
            cFields +=          '"FK5_IDFK7"'
        Endif
        cFields +=      ']'
        cFields +=  '}' 
    EndIf

    jFields:FromJson(cFields)

Return jFields

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonFilters
    Retorna Json contendo os filtros da regra
    
    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310
    @param  cCodCfg  ,Character, Código da configuração
    @return jFilters ,Json     , Campos da configuração

/*/
//-----------------------------------------------------------------------------------
Static Function GetJsonFilters(cCodCfg as Character)

    Local jFilters := JsonObject():New()
    Local jField   := JsonObject():New()

    If cCodCfg $ "0023|0024"
        jFilters["tabori"] := {}
        
        jField["order"]     := "01"
        jField["field"]     := "IG_DTEXTR"
        jField["operation"] := ">="
        aAdd(jFilters["tabori"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "02"
        jField["field"]     := "IG_DTEXTR"
        jField["operation"] := "<="
        aAdd(jFilters["tabori"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "03"
        jField["field"]     := "IG_BCOEXT"
        jField["operation"] := "="
        jField["f3"]        := "SA6001"

        jField["f3trigger"] := getTrigger()    
        aAdd(jFilters["tabori"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "04"
        jField["field"]     := "IG_AGEEXT"
        jField["operation"] := "="
        aAdd(jFilters["tabori"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "05"
        jField["field"]     := "IG_CONEXT"
        jField["operation"] := "="
        aAdd(jFilters["tabori"], jField) 
        
        jFilters["tabdes"] := {}
        
        jField              := JsonObject():New()
        jField["order"]     := "01"
        jField["field"]     := "FK5_DTDISP"
        jField["operation"] := ">="
        aAdd(jFilters["tabdes"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "02"
        jField["field"]     := "FK5_DTDISP"
        jField["operation"] := "<="
        aAdd(jFilters["tabdes"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "03"
        jField["field"]     := "FK5_BANCO"
        jField["operation"] := "="
        jField["f3"]        := "SA6001"
        jField["f3trigger"] := getTrigger()
        aAdd(jFilters["tabdes"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "04"
        jField["field"]     := "FK5_AGENCI"
        jField["operation"] := "="
        aAdd(jFilters["tabdes"], jField) 
        
        jField              := JsonObject():New()
        jField["order"]     := "05"
        jField["field"]     := "FK5_CONTA"
        jField["operation"] := "="
        aAdd(jFilters["tabdes"], jField)

        jField              := JsonObject():New()
        jField["order"]     := "06"
        jField["field"]     := "FK5_RECPAG"
        jField["operation"] := "IN"
        aAdd(jFilters["tabdes"], jField)
        
        jField              := JsonObject():New()
        jField["order"]     := "07"
        jField["field"]     := STR0007
        jField["title"]     := STR0008
        jField["operation"] := "Query"
        jField["idquery"]   := "001"
        aAdd(jFilters["tabdes"], jField)
        
        If cPaisLoc $ "ARG|DOM|EQU|MEX"
            jField              := JsonObject():New()
            jField["order"]     := "08"
            jField["field"]     :=  IIF(cPaisLoc <> "MEX", STR0042, "PA") // "Cheques" || "PA "
            jField["title"]     :=  IIF(cPaisLoc <> "MEX", STR0043, "No mostrar PA anulada") // "Remover cheques anulados" || "Não mostrar PA anulada."
            jField["operation"] := "Query"
            jField["idquery"]   := "002"
            jField["default"]   := .T.
            aAdd(jFilters["tabdes"], jField)
        EndIf 
    EndIf

Return jFilters

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetCIDFields
    Retorna os campos _MSUIDT de cada regra

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param cCodCfg  ,Character, Código da configuração
    @param lIDOrigem,Logical  , Identifica se está buscando o ID 
                                da tabela Origem ou Destino
    
    @return cIdField ,Character, Campos de _MSUIDT da configuração
/*/
//-----------------------------------------------------------------------------------
Static Function GetCIDFields(cCodCfg as Character, lIDOrigem as Logical)

    Local cIdField := "" as Character

    If cCodCfg $ "0023|0024"
        If lIDOrigem
            cIdField := "IG_MSUIDT"
        Else
            cIdField := "FK5_MSUIDT"
        EndIf
    EndIf

Return cIdField

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonRegMatch
    Retorna Json contendo as regras de match da regra
    
    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param  cCodCfg   ,Character, Código da configuração
    @return jRegMatch ,Json     , Regras de Match

/*/
//-----------------------------------------------------------------------------------
Static Function GetJsonRegMatch(cCodCfg as Character)

    Local jRegMatch := JsonObject():New()
    Local cRegMatch := "" as Character
    Local cCodExpMI := "" as Character 

    //Função do filtro específica para o MI
    If __lExpciMI == NIL 
        __lExpciMI := FindFunction("CodExpMI")
    Endif
    //Validação específica para o MI
    If cPaisLoc $ "ARG|DOM|EQU|MEX" .AND. __lExpciMI
        cCodExpMI := CodExpMI(cCodCfg)
    EndIf 

    If cCodCfg = "0023"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "regra_001",'+;
                                    '"idlegend": "MC",'+;
                                     '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                      'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "002",'+;
                                    '"name": "regra_002",'+;
                                    '"idlegend": "MP",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "003",'+;
                                    '"name": "regra_003",'+;
                                    '"idlegend": "MP",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "004",'+;
                                    '"name": "regra_004",'+;
                                    '"idlegend": "MC",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                      'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "005",'+;
                                    '"name": "regra_005",'+;
                                    '"idlegend": "MP",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "006",'+;
                                    '"name": "regra_006",'+;
                                    '"idlegend": "MP",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '}'+;
                            '],'+;
                            '"conditionalQuery": {'+;
                                '"tabori": [],'+;
                                '"tabdes": ['+;
                                    '{'+;
                                        '"idquery": "001",'+;
                                        '"tableaux": ['+;
                                            '{'+;
                                                '"table": "FKA",'+;
                                                '"alias": "FKA"'+;
                                            '},'+;
                                            '{'+;
                                                '"table": "FKA",'+;
                                                '"alias": "FKAEST"'+;
                                            '}'+;
                                        '],'+;
                                        '"query": "SELECT FKA.FKA_IDFKA FROM {FKA} FKA WHERE FKA.FKA_FILIAL = FK5_FILIAL AND FKA.FKA_TABORI = '+"'FK5'"+' AND FKA.FKA_IDORIG = FK5_IDMOV AND FKA.D_E_L_E_T_ = '+"' '"+' AND ' +;
                                                    'NOT EXISTS ( SELECT FKAEST.R_E_C_N_O_ ,  FKAEST.D_E_L_E_T_ FROM {FKAEST} FKAEST '+;
                                                    'WHERE FKAEST.FKA_FILIAL = FKA.FKA_FILIAL AND FKAEST.FKA_IDORIG <> FK5_IDMOV AND FKAEST.FKA_IDPROC = FKA.FKA_IDPROC AND FK5_PROTRA = '+"' '"+' AND FKAEST.FKA_TABORI = FKA.FKA_TABORI AND FKAEST.D_E_L_E_T_ = '+"' '"+') "'+;
                                    cCodExpMI+; 
                                    '}'+;
                                ']'+;
                            '}'+;
                        '}'

    ElseIf cCodCfg == "0024"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "regra_001",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                      'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "002",'+;
                                    '"name": "regra_002",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+'  AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "003",'+;
                                    '"name": "regra_003",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'R'" + ' AND IG_CARTER = '+"'1'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "004",'+;
                                    '"name": "regra_004",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                      'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "005",'+;
                                    '"name": "regra_005",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_NUMCH = IG_DOCEXT AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '},'+;
                                '{'+;
                                    '"idrule": "006",'+;
                                    '"name": "regra_006",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "IG_MSUIDT,IG_BCOEXT,IG_AGEEXT,IG_CONEXT,IG_DOCEXT,IG_DTEXTR,IG_VLREXT,IG_CARTER",'+;
                                        '"des_fields": "FK5_MSUIDT,FK5_BANCO,FK5_AGENCI,FK5_CONTA,FK5_NUMCH,FK5_DTDISP,FK5_VALOR,FK5_RECPAG",'+;
                                        '"condition": "FK5_BANCO = IG_BCOEXT AND FK5_AGENCI = IG_AGEEXT AND FK5_CONTA = IG_CONEXT AND FK5_DTDISP = IG_DTEXTR AND '+;
                                                     'FK5_VALOR = IG_VLREXT AND FK5_RECPAG = ' + "'P'" + ' AND IG_CARTER = '+"'2'"+' AND SEQMATCH = '+"' '"+'",'+;
                                        '"max_match": 1'+;
                                    '}'+;
                                '}'+;
                            '],'+;
                            '"conditionalQuery": {'+;
                                '"tabori": [],'+;
                                '"tabdes": ['+;
                                    '{'+;
                                        '"idquery": "001",'+;
                                        '"tableaux": ['+;
                                            '{'+;
                                                '"table": "FKA",'+;
                                                '"alias": "FKA"'+;
                                            '},'+;
                                            '{'+;
                                                '"table": "FKA",'+;
                                                '"alias": "FKAEST"'+;
                                            '}'+;
                                        '],'+;
                                        '"query": "SELECT FKA.FKA_IDFKA FROM {FKA} FKA WHERE FKA.FKA_FILIAL = FK5_FILIAL AND FKA.FKA_TABORI = '+"'FK5'"+' AND FKA.FKA_IDORIG = FK5_IDMOV AND FKA.D_E_L_E_T_ = '+"' '"+' AND ' +;
                                                    'NOT EXISTS ( SELECT FKAEST.R_E_C_N_O_ ,  FKAEST.D_E_L_E_T_ FROM {FKAEST} FKAEST '+;
                                                    'WHERE FKAEST.FKA_FILIAL = FKA.FKA_FILIAL AND FKAEST.FKA_IDORIG <> FK5_IDMOV AND FKAEST.FKA_IDPROC = FKA.FKA_IDPROC AND FK5_PROTRA = '+"' '"+' AND FKAEST.FKA_TABORI = FKA.FKA_TABORI AND FKAEST.D_E_L_E_T_ = '+"' '"+') "'+;
                                    cCodExpMI+; 
                                    '}'+;
                                ']'+;
                            '}'+;
                        '}'

    EndIf

    jRegMatch:FromJson(cRegMatch)

Return jRegMatch

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonTotal
    Montagem do Json referente as regras de totalização
    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
//----------------------------------------------------------------------------------
Static Function GetJsonTotal(cCodCfg as Character)

    Local cTotal := "" as Character
    Local jTotal := JsonObject():New() as Json

    If cCodCfg $ "0023|0024"
        cTotal := '{'
        cTotal +=    '"totalori": ['
        cTotal +=       '{'
        cTotal +=            '"label": "'+ STR0009 +'",' //"Valor Total Entradas"
        cTotal +=            '"condition": "IG_CARTER = '+"'1'"+'",'
    	cTotal +=            '"total":"IG_VLREXT"'
        cTotal +=        '},'
        cTotal +=        '{'
        cTotal +=           '"label": "'+ STR0010 +'",' //"Valor Total Saídas"
        cTotal +=           '"condition": "IG_CARTER = '+"'2'"+'",'
        cTotal +=           '"total":"IG_VLREXT"'
        cTotal +=        '},'
        cTotal +=        '{'
        cTotal +=           '"label": "'+ STR0011 +'",' //"Total Extrato"
		cTotal +=           '"total": "CASE WHEN IG_CARTER = '+"'1'"+' THEN IG_VLREXT WHEN IG_CARTER = '+"'2'"+' THEN -IG_VLREXT END",'
        cTotal +=           '"valid": true'
        cTotal +=        '}'
        cTotal +=    '],'
		cTotal +=    '"totaldes": ['
		cTotal +=        '{'
		cTotal +=           '"label": "'+ STR0009 +'",' //"Valor Total Entradas"
		cTotal +=           '"condition": "FK5_RECPAG = '+"'R'"+'",'
		cTotal +=           '"total": "FK5_VALOR"'
        cTotal +=         '},'
        cTotal +=         '{'
        cTotal +=           '"label": "'+ STR0010 +'",' //"Valor Total Saídas"
        cTotal +=           '"condition": "FK5_RECPAG = '+"'P'"+'",'
        cTotal +=           '"total": "FK5_VALOR"'
        cTotal +=         '},'
        cTotal +=         '{'
        cTotal +=           '"label": "'+ STR0012 +'",' //"Total Movimentos"
        cTotal +=           '"total": "CASE WHEN FK5_RECPAG = '+"'R'"+' THEN FK5_VALOR WHEN FK5_RECPAG = '+"'P'"+' THEN -FK5_VALOR END",'
        cTotal +=           '"valid": true'
        cTotal +=          '}'
        cTotal +=    ']'
        cTotal += '}'
    EndIf

    jTotal:FromJson(cTotal)

Return jTotal

//---------------------------------------------------------------------------
/*/{Protheus.doc} SaveJsonOnQLB
    Gravação das regras na tabela QLB

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310
    
    @param jsonSave    , Json   , Json contendo as regras a serem gravadas
    @param lJaExisteQLB, Logical, Indica se está incluindo ou alterando uma
                                    regra de conciliação
/*/
//---------------------------------------------------------------------------
Static Function SaveJsonOnQLB(jsonSave as Json, lJaExisteQLB as Logical)
    Local jValidFields  as Json

    jValidFields := ValidFields(jsonSave["fields"])

    QLB->(dbSetOrder(1))
    If jValidFields["update"]
        jValidFields:DelName("update")

        RecLock("QLB", !lJaExisteQLB)
            QLB->QLB_FILIAL := xFilial("QLB")
            QLB->QLB_CODCFG := jsonSave["codcfg"]
            QLB->QLB_DESCFG := jsonSave["descfg"]
            QLB->QLB_TABORI := jsonSave["tabori"]
            QLB->QLB_TABDES := jsonSave["tabdes"]
            QLB->QLB_FIELDS := jValidFields:toJson()
            QLB->QLB_FILTER := jsonSave["filter"]:toJson()
            QLB->QLB_CIDORI := jsonSave["cidori"]
            QLB->QLB_CIDDES := jsonSave["ciddes"]
            QLB->QLB_DESCOR := jsonSave["descor"]
            QLB->QLB_DESCDE := jsonSave["descde"]
            QLB->QLB_REGMAT := jsonSave["regmat"]:toJson()
            QLB->QLB_TOTAL  := jsonSave["total"]:toJson()
            QLB->QLB_VERSAO := jsonSave["version"]

            If __lPosGrv
                QLB->QLB_POSGRV := jsonSave["posgrv"]
            Endif

            If __lPosCan
                QLB->QLB_POSCAN := jsonSave["poscan"]
            Endif

            If __lActions
                QLB->QLB_ACTEFT := jsonSave["actions"]:toJson()
            Endif

            If __lIgnore
                QLB->QLB_IGNORE := jsonSave["ignore"]
            Endif

            If __lLegends
                QLB->QLB_LEGEND := jsonSave["legends"]
            EndIf
        QLB->(MsUnlock())
    Endif

Return

//---------------------------------------------------------------------------
/*{Protheus.doc} ValidFields
    Validacao da existência de campos para adicionar na QLB

    @author: TOTVS
    @since 06/03/2023
    @version 1.0
*/
//---------------------------------------------------------------------------
Static Function ValidFields(jFields)
    Local nI := 0 as Numeric
    Local nx := 0 as Numeric
    Local jReturn := JsonObject():new() as Json
    Local aFields := {} as Array
    Local aReturn := {} as Array
    Local cCpoMeus := "E5_PREFIXO|E5_NUMERO|E5_PARCELA|E5_TIPO|E5_CLIFOR|E5_LOJA|E5_CREDITO"

    If jFields <> Nil .And. ValType(jFields) == "J"
        aFields := jFields:GetNames()
        If aFields <> Nil .And. ValType(aFields) == "A"
            jReturn["update"] := .T.

            For nI := 1 To Len(aFields)			
                If jFields[aFields[nI]] <> Nil				
                    aReturn := {}
                    For nX := 1 To Len(jFields[aFields[nI]])
                        If ValType(jFields[aFields[nI]][nX]) == "C" .And. ;
                            ((Len(FWSX3Util():GetFieldStruct(jFields[aFields[nI]][nX])) > 0) .or. (jFields[aFields[nI]][nX] $ cCpoMeus))
                            aAdd(aReturn, jFields[aFields[nI]][nX])
                        Else
                           jReturn["update"] := .F. 
                        Endif
                    Next nX
                    jReturn[aFields[nI]] := aClone(aReturn)
                EndIf
            Next nI
        EndIf	
    EndIf

    FwFreeArray(aFields)
    FwFreeArray(aReturn)
Return jReturn

//---------------------------------------------------------------------------
/*{Protheus.doc} GetJsonVersion
Retorna a versão das configurações de conciliação

@author: TOTVS
@since 19/04/2023
@version 1.0
*/
//---------------------------------------------------------------------------
Static Function GetJsonVersion(cCodCfg as Character)
    
    Local cVersion := "" as Character
    
    If cCodCfg == "0023"
        cVersion := "20250704"
    ElseIf cCodCfg == "0024"
        cVersion := "20250704"
    EndIf

Return cVersion

//---------------------------------------------------------------------------
/*/{Protheus.doc} CheckUpdate
    Verifica se há necessidade de atualizar a configuração
    @type  Static
    @author pequim
    @since 19/04/2023
    @version 12.1.2210
    @param 
        cCodCfg, Character, Codigo de configuração
        cVersion, Character, Codigo de versão
    @return 
        lRet, Logico, Se deve ou não atualizar
/*/
//---------------------------------------------------------------------------
Static Function CheckUpdate(cCodCfg as Character, cVersion as Character, lFound as Logical)

    Local lRet      := .T. as Logical

    QLB->(dbSetOrder(1))
    lFound := (QLB->(MsSeek(xFilial("QLB")+cCodCfg)))

    //Se encontrar, confiro se a versão em QLB é menor que a versão do Json no fonte.
    If lFound
        // Se sim, devo atualizar a QLB
        If Empty(QLB->QLB_VERSAO) .Or. (QLB->QLB_VERSAO < cVersion)
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

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GetPosGrv
    Retorna as rotinas de PosGrv e PosCan de cada regra

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param cCodCfg ,Character, Código da configuração
    @param Logical ,Logical  , Identifica se está a rotina de PosGRV (.T.)
                                ou PosCan (.F.)
    
    @return cIdFunc ,Character, Função as ser executada no PosGrv ou PosCan
/*/
//-----------------------------------------------------------------------------
Static Function GetPosGrv(cCodCfg as Character, __lPosGrv as Logical)

    Local cIdFunc := "" as Character

    If cCodCfg $ "0023|0024"
        If __lPosGrv
            cIdFunc := "F475PosGrv"
        Else
            cIdFunc := "F475PosCan"
        EndIf
    EndIf

Return cIdFunc

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonActions
    Retorna Json com as ações a serem habilitadas, na pasta Dados Não Encontrados, 
    para as tabelas de origem e destino utilizados na regra de Conciliação.

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param  cCodCfg , Character, Código da configuração
    @return jActions, Json     , Ações da configuração

/*/
//-----------------------------------------------------------------------------------
Static Function GetJsonActions(cCodCfg as Character) 

    Local cActions := "" as Character
    Local jActions := JsonObject():New() as Json

    If  cCodCfg == "0023"
        cActions := '{'+;
                        '"tabori": ['+;
                            '{'+;
                                '"label": "'+ STR0013 + '",'+;     //"Efetivação"
                                '"description":  "'+ STR0014 + '",'+; //"Efetivação Movimentos Bancários"
                                '"order": "1",'+;
                                '"action": "F475Efetiv",'+;
                                '"data": ' + '{'+;
                                    '"title": "'+ STR0015 + '",'+;        //"Dados da Efetivação"
                                    '"fields": ['+;
                                        '{'+;
                                            '"field": "naturefet",'+;
                                            '"type": "C",'+;
                                            '"title": "'+ STR0016 +'",'+;   //"Natureza do Movimento"
                                            '"f3": "SED",'+;
                                            '"required": true'+;
                                        '},'+;
                                        '{'+;
                                            '"field": "histor",'+;
                                            '"type": "C",'+;
                                            '"title": "'+ STR0017 +'",'+;       //"Histórico"
                                            '"f3": "",'+;
                                            '"required": false'+;
                                        '},'+;
                                        '{'+;
                                            '"fields": ['+;
                                                '{'+;
                                                    '"field": "cdeb",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0018 +'",'+;    //"Conta Débito"
                                                    '"f3": "CT1",'+;
                                                    '"required": false'+;
                                                '},'+;
                                                '{'+;
                                                    '"field": "ccrd",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0019 +'",'+;   //"Conta Crédito"
                                                    '"f3": "CT1",'+;
                                                    '"required": false'+;
                                                '}'+;
                                            ']'+;      
                                        '},'+;
                                        '{'+;
                                            '"fields": ['+;
                                                '{'+;
                                                    '"field": "ccd",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0020 +'",'+; //"Centro Custo Débito"
                                                    '"f3": "CTT",'+;
                                                    '"required": false'+;
                                                '},'+;
                                                '{'+;
                                                    '"field": "ccc",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0021 +'",'+;    //"Centro Custo Crédito"
                                                    '"f3": "CTT",'+;
                                                    '"required": false'+;
                                                '}'+;
                                            ']'+;      
                                        '},'+;
                                        '{'+;
                                            '"fields": ['+;
                                                '{'+;
                                                    '"field": "itemd",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0022 +'",'+;    //"Item Contabil Débito"
                                                    '"f3": "CTD",'+;
                                                    '"required": false'+;
                                                '},'+;
                                                '{'+;
                                                    '"field": "itemc",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0023 +'",'+;    //"Item Contabil Crédito"
                                                    '"f3": "CTD",'+;
                                                    '"required": false'+;
                                                '}'+;
                                            ']'+;      
                                        '},'+;
                                        '{'+;
                                            '"fields": ['+;
                                                '{'+;
                                                    '"field": "clvldb",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0024 +'",'+;     //"Classe Valor Débito"
                                                    '"f3": "CTH",'+;
                                                    '"required": false'+;
                                                '},'+;
                                                '{'+;
                                                    '"field": "clvlcr",'+;
                                                    '"type": "C",'+;
                                                    '"title": "'+ STR0025 +'",'+;    //"Classe Valor Crédito"
                                                    '"f3": "CTH",'+;
                                                    '"required": false'+;
                                                '}'+;
                                            ']'+;      
                                        '}'+;                                        
      					            ']'+;
				                '}'+;
			                '},'+;
			                '{'+;
                				'"label": "'+ STR0026 +'",'+;      //"Cancelar Efetivação"
				                '"description": "'+ STR0027 +'",'+;   //"Cancelar Efetivação de Movimentos Bancários"
				                '"order": "1",'+;
				                '"action": "F475CanEft"'+;
			                '}'+;
		                '],'+;
		                '"tabdes": ['+;
                            '{'+;
                                '"label": "'+ STR0032 +'",'+;        //"Disponibilidade"
                                '"description": "'+ STR0033 +'",'+;    //"Ajustar data de disponibilidade do movimento bancário."
                                '"order": "2",'+;
                                '"action": "F475Dispo",'+;
                                '"data": ' + '{'+;
                                    '"title": "'+ STR0034 + '",'+;        //"Dados da Disponibilidade"
                                    '"fields": ['+;
                                        '{'+;
                                            '"field": "dtdispo",'+;
                                            '"type": "D",'+;
                                            '"title": "'+ STR0035 +'",'+;   //"Data de Disponibilidade"
                                            '"required": true'+;
                                        '},'+;
                                        '{'+;
                                            '"field": "aplicdispo",'+;
                                            '"type": "radio",'+;
                                            '"title": "'+ STR0036 +'",'+;       //"Aplicar essa data para quais registros?"
                                            '"required": true,'+;
                                            '"options": ['+;
                                                '{"label": "' + STR0037 + '", "value": 1},'+;     //"Registros selecionados"
                                                '{"label": "' + STR0038 + '", "value": 2},'+;     //"Registros com mesma data"
                                                '{"label": "' + STR0039 + '", "value": 3}' +;     //"Todos os registros do processo" 
                                            ']'+;
                                        '}'+;
                                    ']'+;
                                '}'+;
                            '}'+;
                        ']'+;
	                '}'
    ElseIf  cCodCfg == "0024"
        cActions := '{'+;
                        '"tabori": [],'+;
                        '"tabdes": ['+;
                            '{'+;
                                '"label": "'+ STR0028+'",'+;        //"Conciliar"
                                '"description": "'+ STR0029 +'",'+;    //"Conciliar Movimentos Bancários"
                                '"order": "1",'+;
                                '"enable": "allways",'+;
                                '"message": {'+;
                                    '"title": "'+ STR0040+'",'+;        // "Conciliação total dos itens"
                                    '"description": "'+ STR0041+'",'+;  // "Deseja realizar a conciliação de todos os movimentos bancários?"
                                    '"show": "no-mark"'+;
                                '},'+;
                                '"action": "F475Efetiv"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0032 +'",'+;        //"Disponibilidade"
                                '"description": "'+ STR0033 +'",'+;    //"Ajustar data de disponibilidade do movimento bancário."
                                '"order": "2",'+;
                                '"enable": "mark",'+;
                                '"action": "F475Dispo",'+;
                                '"data": ' + '{'+;
                                    '"title": "'+ STR0034 + '",'+;        //"Dados da Disponibilidade"
                                    '"fields": ['+;
                                        '{'+;
                                            '"field": "dtdispo",'+;
                                            '"type": "D",'+;
                                            '"title": "'+ STR0035 +'",'+;   //"Data de Disponibilidade"
                                            '"required": true'+;
                                        '},'+;
                                        '{'+;
                                            '"field": "aplicdispo",'+;
                                            '"type": "radio",'+;
                                            '"title": "'+ STR0036 +'",'+;       //"Aplicar essa data para quais registros?"
                                            '"required": true,'+;
                                            '"options": ['+;
                                                '{"label": "' + STR0037 + '", "value": 1},'+;     //"Registros selecionados"
                                                '{"label": "' + STR0038 + '", "value": 2},'+;     //"Registros com mesma data"
                                                '{"label": "' + STR0039 + '", "value": 3}' +;     //"Todos os registros do processo" 
                                            ']'+;
                                        '}'+;
                                    ']'+;
                                '}'+;
                            '}'+;
                        ']'+;
                    '}'

    Endif

    jActions:FromJson(cActions)

Return jActions

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonIgnore
    Retorna a ação de ignorar registros

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param cCodCfg  ,Character, Código da configuração
    
    @return cIgnore ,Character, ação de ignorar registros
/*/
//-----------------------------------------------------------------------------
Static Function GetJsonIgnore(cCodCfg as Character)

    Local cIgnore := "" as Character

    If cCodCfg == "0023"
        cIgnore := '{'+;
		                '"tabori":true,'+;
		                '"tabdes":false'+;
	                '}'
    EndIf

Return cIgnore

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonIgnore
    Retorna a ação de ignorar registros

    @type  Function
    @author pequim
    @since 12/06/2023
    @version 12.1.2310

    @param cCodCfg  ,Character, Código da configuração
    @return cLegends ,Character, ação de ignorar registros
/*/
//-----------------------------------------------------------------------------
Static Function GetJsonLegends(cCodCfg as Character)

    Local cLegends := "" as Character

    If cCodCfg == "0023"
        cLegends := '['
        cLegends +=     '{'
        cLegends +=         '"color":"color-01",'
        cLegends +=         '"label":"'+ STR0030 +'",'        //"Match Completo"
        cLegends +=         '"idlegend":"MC"'
        cLegends +=     '},'
        cLegends +=     '{'
        cLegends +=         '"color":"color-01",'
        cLegends +=         '"label":"'+ STR0031 +'",'        //"Match Parcial"
        cLegends +=         '"idlegend":"MP"'
        cLegends +=     '}'
        cLegends += ']'
    Endif
Return cLegends

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GetTrigger
    
    Retorna os campos a serem alterados via trigger
    @type  Static Function
    @author pequim
    @since 13/09/2023

    @return aFields, Array, Dados para atualização de campos a partir de lookup

/*/
//-------------------------------------------------------------------------------
Static Function getTrigger() 

    Local aFields := {} as Array

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabori"
    aFields[nLen]["from"]  := "A6_COD"
    aFields[nLen]["to"]    := "IG_BCOEXT"

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabori"
    aFields[nLen]["from"]  := "A6_AGENCIA"
    aFields[nLen]["to"]    := "IG_AGEEXT"

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabori"
    aFields[nLen]["from"]  := "A6_NUMCON"
    aFields[nLen]["to"]    := "IG_CONEXT"

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabdes"
    aFields[nLen]["from"]  := "A6_COD"
    aFields[nLen]["to"]    := "FK5_BANCO"

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabdes"
    aFields[nLen]["from"]  := "A6_AGENCIA"
    aFields[nLen]["to"]    := "FK5_AGENCI"

    aAdd(aFields, JsonObject():new())
    nLen := Len(aFields)
    aFields[nLen]["group"] := "tabdes"
    aFields[nLen]["from"]  := "A6_NUMCON"
    aFields[nLen]["to"]    := "FK5_CONTA"

Return aFields
