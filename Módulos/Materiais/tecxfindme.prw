#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECXFINDME.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} intFindMe

@since	15/09/2023
@author	diego.bezerra
@description Abre a tela para configuração da integração com a findme
/*/
//------------------------------------------------------------------------------
Function intFindMe()

    Local cApi      := GetMV("MV_GSXFM01",.F.,"-1")
    Local cUser     := GetMV("MV_GSXFM02",.F.,"-1")
    Local cPsw      := GetMV("MV_GSXFM03",.F.,"-1")
    Local cPwReal   := ""
    Local cTimeZone := GetMV("MV_FINTIME",.F.,"-1")
    Local cRegiao   := GetMV("MV_DEFREG",.F.,"-1")
    Local nIntegra  := GetMV('MV_FINDME',.F.,-1)
    Local nX        := 1

    Local aParamBox := {}
    Local aParams   := {}
    Local aLog      := {}
    
    Local lContinua := .F.

    AADD(aParams, {'MV_GSXFM01', cApi})
    AADD(aParams, {'MV_GSXFM02', cUser})
    AADD(aParams, {'MV_GSXFM03', cPsw})
    AADD(aParams, {'MV_GSFINDME', nIntegra})
    AADD(aParams, {'MV_FINTIME', cTimeZone})
    AADD(aParams, {'MV_DEFREG', cRegiao})

    If cApi != "-1" .AND. cUser != '-1' .AND. cPsw != '-1'; 
        .AND. nIntegra != -1 .And. cTimeZone != '-1' .And. cRegiao != '-1'
        lContinua := .T.
    EndIf

    If lContinua 

        If EMPTY(cApi)
            cApi := Space(50)
        EndIf

        If EMPTY(cUser)
            cUser := Space(20)
        EndIf

        If EMPTY(cPsw)
            cPsw := Space(10)
        Else
            cPwReal := cPsw
            cPsw    := '**********'
        EndIf

        If EMPTY(cTimeZone)
            cTimeZone := Space(90)
        EndIf

        If EMPTY(cRegiao)
            cRegiao := Space(90)
        EndIf

        aAdd(aParamBox, {2, STR0001, nIntegra,   {STR0002,STR0003},     50, ".T.", .F.})	// "Habilitar integração?" # "1=Não" # "2=Sim"
        aAdd(aParamBox, {1, STR0004, PADR(cApi,90), "" ,, ,, 90, .F.} ) // "Endereço da API"
        aAdd(aParamBox, {1, STR0005, PADR(cUser,90), "" ,, ,, 90, .F.} ) // "Usuário de integração"
        aAdd(aParamBox, {1, STR0006, PADR(cPsw,40), "" ,, ,, 40, .F.} ) //"Senha da integração"
        aAdd(aParamBox, {1, "Time Zone", PADR(cTimeZone,90), "" ,, ,, 90, .F.} ) //"Região (Time Zone)"
        aAdd(aParamBox, {1, "Região", PADR(cRegiao,90), "" ,, ,, 90, .F.} ) //"Região"

        If ParamBox(aParamBox /*aParam*/, /*cTitle*/ STR0007,/*aRet*/,/*bOk*/,/*aButtons*/,; //"Integração FindMe"
                    /*lCentered*/,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.F.,/*lUserSave*/.F.)//, aPergRet) // "Informe a Agência"
            
            If Valtype(MV_PAR01) == 'C'
                MV_PAR01 := VAL(MV_PAR01)
            EndIf

            IF MV_PAR01 != nIntegra
                // Grava valor da escolha de habilitar/desabilitar a integração em MV_FINDME
                PutMv('MV_FINDME', MV_PAR01)
            EndIf
            
            If MV_PAR02 != cApi
                // Grava a url da api de integração
                PutMv("MV_GSXFM01",MV_PAR02)
            EndIf

            If MV_PAR03 != cUser
                // Grava o usuário utilizado na integração
                PutMv("MV_GSXFM02",PADR(LOWER(MV_PAR03),90))
            EndIf
            
            If MV_PAR04 != '**********' .AND. MV_PAR04 != cPwReal
                // Grava a senha utilizada na integração
                PutMv("MV_GSXFM03",ALLTRIM(MV_PAR04))
            EndIf

            If Alltrim(MV_PAR05) != Alltrim(cTimeZone)
                PutMv("MV_FINTIME",ALLTRIM(MV_PAR05))
            EndIf

            If Alltrim(MV_PAR06) != Alltrim(cRegiao)
                PutMv("MV_DEFREG",ALLTRIM(MV_PAR06))
            EndIf

        EndIf

    Else
        lErr := .T. 
        For nX := 1 to Len(aParams)
            If Valtype(aParams[nX][2]) == 'C'
                aParams[nX][2] := Val(aParams[nX][2])
            EndIf
            If aParams[nX][2] == -1
                AADD(aLog,aParams[nX][1])
            EndIf
        Next nX
    EndIf

    IntLog(aLog, !lContinua)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} usrFindMe

@since	15/09/2023
@author	diego.bezerra
@description Realiza a criação de usuário na plataforma findme
@param aAtend, array, informações do atendente
// {codigo,filial,loja,nome,identifier,email,password,phone,locale} (identifier = matrícula do funcionário)
@param oFindMe, objeto, objeto instanciado da classe GsFindMe
@return lRet, lógico, informa se houve algum erro no cadastro do antendente na findme
/*/
//------------------------------------------------------------------------------
Function fndmeExp(oFindMe, cTipo, aData)
    Local nX := 0

    If cTipo == 'regiao'
        For nX := 1 to Len(aData)
            oFindMe:addRegions(/*cCodRegiao*/aData[nX][1], /*cCodFilial*/aData[nX][2],;
                        /*cCodloja*/aData[nX][3],aData[nX][8] /*{"norte","Sao_Paulo"}*/)
        Next nX
    EndIf

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} usrFindMe

@since	15/09/2023
@author	diego.bezerra
@description Realiza a criação de usuário na plataforma findme
@param aAtend, array, informações do atendente
// {codigo,filial,loja,nome,identifier,email,password,phone,locale} (identifier = matrícula do funcionário)
@param oFindMe, objeto, objeto instanciado da classe GsFindMe
@return lRet, lógico, informa se houve algum erro no cadastro do antendente na findme
/*/
//------------------------------------------------------------------------------
Function usrFindMe(aAtend, oFindMe)

Local lAuth		:= .F.
Local nX        := {}
Local aPosto    := {}
Local lRet      := .F.

Default oFindMe	:= GsFindMe():new()

lAuth := oFindMe:lAuth

If lAuth
    if Len(aAtend) > 0
        for nX := 1 to Len(aAtend)
            aPosto := qryUsrFind(aAtend[nX][1],aAtend[nX][3])
            if Len(aPosto) > 0
                lRet := oFindMe:newUser(aPosto[1],aAtend[nX]) 
            Else
                lRet := oFindMe:newUser(,aAtend[nX])
            EndIf
        Next nX   
    EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} qryUsrFind

@since	14/09/2023
@author	diego.bezerra
@description Retorna os postos relacioandos a um deterninado atendente
@param cCodTec, string, código do técnico
@param loja, string, loja
@return aPosto, array, informações dos postos relacionados ao cliente
/*/
//------------------------------------------------------------------------------
static function qryUsrFind(cCodTec,loja)
    
    Local cAlias    := GetNextAlias()
    Local aPosto    := {}

    BeginSql Alias cAlias
        SELECT DISTINCT TFF.TFF_COD,
                TFF.TFF_FILIAL
        FROM %table:ABB% ABB
            INNER JOIN %table:ABQ% ABQ 
                ON ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
                AND ABQ.%NotDel%
            INNER JOIN %table:TFF% TFF
                ON ABQ.ABQ_CODTFF = TFF.TFF_COD
                AND TFF.%NotDel%
        WHERE ABB.ABB_CODTEC = %exp:cCodTec%
                AND ABB.%NotDel%
    EndSql

    If (cAlias)->(!Eof())

        AADD(aPosto,{(cAlias)->TFF_COD,;
                    (cAlias)->TFF_FILIAL,;
                    loja;
                    })
                        
        
    EndIf
(cAlias)->(DbCloseArea())
Return aPosto

//------------------------------------------------------------------------------
/*/{Protheus.doc} authFindMe

@since	14/09/2023
@author	diego.bezerra
@description Instancia o objeto GsFindMe e realiza a autenticação
@return oFindMe
/*/
//------------------------------------------------------------------------------
Function authFindMe()
Local oFindMe	:= GsFindMe():new()
Return oFindMe

//------------------------------------------------------------------------------
/*/{Protheus.doc} IntLog

@since	14/09/2023
@author	diego.bezerra
@description Exibe logs de integração
@param aDados, aDados, dados que serão exibidos no log
@param cTimezone, string, timezone
@return aRegiao, array, informações da região - conforme api da findme
/*/
//------------------------------------------------------------------------------
Static Function IntLog(aDados, lErr)

Local cLog     := ""
Local cTitle   := ""  
Local lVScroll := .F.
Local lHScroll := .F.
Local lWrdWrap := .F.
Local lCancel  := .F.
Local nX       :=  0

Default aDados   := {}

    If lErr
        cTitle := STR0008 // 'Integração FindMe - inconsistência'
        cLog += STR0009 + CRLF //"Não foi possível ligar a integração. "
        If Len(aDados) > 0
            cLog += STR0010 + CRLF //'Parâmetros de sistema não encontrados:'
        EndIF
        For nX := 1 to Len(aDados)
            cLog += '   ' + aDados[nX] + CRLF
        Next nX
    Else
        cTitle := STR0007 //'Integração FindMe'
        cLog += STR0011 // "Alterações nos parâmetros realizados com sucesso!"
    EndIf

    AtShowLog(cLog,cTitle,lVScroll,lHScroll,lWrdWrap,lCancel)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} regFindMe

@since	14/09/2023
@author	diego.bezerra
@description Obtem o array para o cadastro de regiões
@param cCodSup, string, código da área de supervisão
@param cTimezone, string, timezone
@return aRegiao, array, informações da região - conforme api da findme
/*/
//------------------------------------------------------------------------------
function regFindMe(cCodSup, ctimezone)

    Local aRegiao := {}
    Local cAlias := GetNextAlias()
     BeginSql Alias cAlias
        SELECT TGS_FILIAL,
            ABS_LOJA, 
            TGS_DESCRI
        FROM %table:TGS% TGS
            INNER JOIN %table:ABS% ABS 
                ON ABS.ABS_CODSUP = TGS.TGS_COD 
            WHERE TGS.TGS_COD = %exp:cCodSup% AND TGS.%NotDel%
     EndSql
    If (cAlias)->(!Eof())
        AADD(aRegiao,cCodSup) 
        AADD(aRegiao,(cAlias)->TGS_FILIAL)      
        AADD(aRegiao,'01') // Utilizado valor fixo, pois a tabela TGS não possui o campo loja e o cadastro de região é universal
        AADD(aRegiao, (cAlias)->TGS_DESCRI)
        AADD(aRegiao, ctimezone)
    EndIf
    (cAlias)->(DbCloseArea())
Return aRegiao


