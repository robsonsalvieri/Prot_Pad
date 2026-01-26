#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA960.CH"

Function CTBA960()

    UpdateQLF()

    If MinimumRequirements()
        FWCallApp("ctba960")
    EndIf

Return 

/*/{Protheus.doc} JsToAdvpl
    Função para intermediação de comunicação de Javascript com ADVPL
    @type  Function
    @author totvs
    @since 17/07/2023
    @version 12.1.2310
    @param 
        param_name: oWebChannel, param_type: object, param_descr: Objeto de comunicação entre SmartClient e o Componente TWebEngine 
        param_name: cType, param_type: character, param_descr: ID enviado pelo front-end para sinalizar a ação a ser realizada
        param_name: cContent, param_type: character, param_descr: Conteúdo enviado pelo front-end caso haja necessidade
/*/

Static Function JsToAdvpl(oWebChannel, cType, cContent)

    Default cContent := ""

    Do Case
        //Chamada do app do Conciliador
        Case cType == "openCTBA940"
            CTBA940()
        Case cType == "lockUUID"
            LockUUID(cContent)
        Case cType == "unlockUUID"
            UnlockUUID(cContent)
    EndCase

Return

Static Function MinimumRequirements()

    Local oBtnLink 
    Local cMsg	     := ""
    Local cTitle     := ""
    Local cSubTitle  := ""
    Local cLink      := ""
    Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","01"), "CTB020") //Processo 01
    Local cCTB965    := IIF(FindFunction("GetSPName"), GetSPName("CTB965","29"), "CTB965") //Processo 29    
    Local lRet       := .T.    

    // Release
    If  GetRPORelease() < "12.1.2310" 
        cTitle    := STR0001 // ""Ambiente Desatualizado"
        cSubTitle := STR0002 // "Acesse o Portal do Cliente"
        cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"
        
        cMsg += '<b>' + STR0003 + ' </b><br>' 	// "RPO está desatualizado"
        cMsg += ' ' + STR0004 + ' ' + GetRPORelease() + ' - ' + STR0005 + '12.1.2310 <br><br>' 	//"Versão atual: " | "Versão mínima: "   	
    EndIf

    //Ambiente
    If Empty(cMsg)
        //Procedures                
        If !ExistProc(cCTB020) .Or. !ExistProc(cCTB965)
            cTitle    := STR0015 // "Configurar Stored Procedures"
            cSubTitle := STR0007 // "Saiba mais"
            cLink     := "https://tdn.totvs.com/pages/viewpage.action?pageId=651665430"
            
            cMsg += '<b> '+ STR0016 + ' </b><br>' //"As Stored Procedures de Fechamento Contábil encontram-se"
            cMsg += '<b> '+ STR0023 + ' </b><br>' //"desatualizadas"
            cMsg += ' ' + STR0017 + "<br>"        //"Necessário instalar os processos 01 e 29"
            cMsg += ' ' + STR0018 + "<br><br>"    //"Contabilidade Gerencial"
        EndIf
                        
        //Dicionario
        If Empty(cMsg)
            If !AliasInDic("QLF") .Or. !AliasInDic("QLJ") // Pacotes: 012152 e 012811
                cTitle    := STR0019 // "Configurar Dicionário de Dados"
                cSubTitle := STR0007 // "Saiba mais"
                cLink     := "https://tdn.totvs.com/pages/releaseview.action?pageId=334342777"
            
                cMsg += '<b> '+ STR0020 + ' </b><br>' //"O Dicionário de Dados encontra-se desatualizado"
                cMsg += ' ' + STR0021 + "<br>"        //"Atualize o dicionário aplicando UPDDISTR do pacote"
                cMsg += ' ' + STR0022 + "<br><br>"    //"acumulado para o módulo Contabilidade Gerencial"
            EndIf
        EndIf

        //Campos MSUIDT
        If Empty(cMsg)
            If !X3HasMSUIDT(@cMsg)
                cTitle    := STR0027 // "Campos MSUIDT não encontrados em dicionário de Dados"
                cSubTitle := STR0007 // "Saiba mais"
                cLink     := "https://tdn.totvs.com/pages/releaseview.action?pageId=638741736"
            EndIf
        EndIf
    EndIf

    If !Empty(cMsg)
        If !IsBlind()
            DEFINE DIALOG oDlg TITLE cTitle FROM 180,180 TO 500,750 PIXEL
            // Cria fonte para ser usada no TSay
            oFont := TFont():New('Courier new',,-15,.T.)
        
            lHtml := .T.
            oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

            oBtnLink := TButton():New( 145, 5, cSubTitle, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
            oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
            oBtnLink:bLClicked := {|| ShellExecute("open", cLink,"","",3) }
            
            ACTIVATE DIALOG oDlg CENTERED
        EndIf
        lRet := .F.
    EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} LockByUUID
Cria um semaforo que não permite que outra thread apague os registros da tabela QLJ enquanto o processamento não finaliza

@author Totvs
/*/
//-------------------------------------------------------------------
Static Function LockUUID(cUUID)
    If !Empty(cUUID)
        LockByName("CTBA960_"+cUUID)
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LockByUUID
Desativa o semaforo criado na função LockUUID

@author Totvs
/*/
//-------------------------------------------------------------------
Static Function UnlockUUID(cUUID)
    If !Empty(cUUID)
        UnlockByName("CTBA960_"+cUUID)
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X3HasMSUIDT
Valida se o ambiente possui os campos MSUIDT

@author Totvs
/*/
//-------------------------------------------------------------------
Static Function X3HasMSUIDT(cMsg)
    Local nI        as Numeric
    Local lRet      as Logical
    Local aTables   as Array

    nI      := 0
    lRet    := .T.
    aTables := {}
    cMsg  := ""

    aAdd(aTables, {"SF1", "F1_MSUIDT"})
    aAdd(aTables, {"SF2", "F2_MSUIDT"})
    aAdd(aTables, {"SC7", "C7_MSUIDT"})
    aAdd(aTables, {"SC6", "C6_MSUIDT"})
    aAdd(aTables, {"SD3", "D3_MSUIDT"})
    aAdd(aTables, {"SE1", "E1_MSUIDT"})
    aAdd(aTables, {"SE2", "E2_MSUIDT"})
    aAdd(aTables, {"SE5", "E5_MSUIDT"})
    aAdd(aTables, {"SEF", "EF_MSUIDT"})
    aAdd(aTables, {"SEU", "EU_MSUIDT"})

    for nI := 1 to Len(aTables)
        DbSelectArea(aTables[nI][1])
        If FieldPos(aTables[nI][2]) < 1
            If Empty(cMsg)
                cMsg := STR0025 + CRLF +  aTables[nI][1] //"Não foram encontrados os campos MSUIDT nas tabelas: "
            Else
                cMsg += ", " + aTables[nI][1]
            EndIf
        EndIf
    next nI

    If !Empty(cMsg)
        lRet := .F.
        cMsg += CRLF + CRLF + STR0024 + CRLF + STR0026 //"Realize a implantação do Conciliador Backoffice e execute o WIZARDUUID para incluir estes campos em seu ambiente"
    EndIf

    FwFreeArray(aTables) 

Return lRet
