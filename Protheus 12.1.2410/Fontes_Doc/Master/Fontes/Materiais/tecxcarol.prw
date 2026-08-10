#INCLUDE "TOTVS.CH"
#INCLUDE "TECXCAROL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecFtCarol

@description Utiliza a classe ServCarol para enviar as fotos dos funcionários
que são atendentes para a plataforma Carol 

@author	Diego Bezerra
@since	18/04/2023
/*/
//------------------------------------------------------------------------------

Function TecFtCarol(aData,aDtReturn,lInvite, lLog, cNomeFile)
    Local oServCarol := Nil
    Local aErr := {}
    Local cMsgErr := ""

    Default lLog := .F.
    Default aData := {}

    Processa({|| connectCarol(@oServCarol, lLog, cNomeFile)},STR0001,STR0002)//"Conectando com a plataforma Carol"#"Aguarde"
    
    If !Empty(oServCarol:getAuthKey())
        PUTMV("MV_APICLOA",ALLTRIM(oServCarol:getAuthKey()))
    EndIf

    If !oServCarol:getLError()
        processData(oServCarol,aData,lInvite)
    Else
        aErr := oServCarol:getError()
        if Len(aErr) > 0 
            cMsgErr += 'Método ' + aErr[1][1]+CRLF
            cMsgErr += 'Mensagem: ' + aErr[1][2] 
        EndIf
        Help( ,, 'Comunicação com Carol',, cMsgErr, 1, 0) 
    EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} connectCarol
Realiza a verificação dos parâmetros necessários para a integração e
instancia o objeto de integração oServCarol
Verifica se existe token de api e se o mesmo ainda é válido
Realiza a geração de novo tokende api, caso este não esteja disponível ou
esteja expirado. 
/*/
//------------------------------------------------------------------------------
Static Function connectCarol(oServCarol, lLog, cNomeFile)
    Local cApiToken := Alltrim(SUPERGETMV('MV_APICLOA', .F., ''))
    
    Default lLog := .F.
    Default cNomeFile := 'integracaocarol'

    oServCarol := ServCarol():New(/*cBaseUrl*/Alltrim(SUPERGETMV('MV_APICLO1', .F., '')),/*cAuthKey*/,/*cConnId*/,/*lGeraLog*/lLog, /*cNomeLog*/cNomeFile)
    oServCarol:defConector(Alltrim(SUPERGETMV('MV_APICLO3', .F., '')))
    oServCarol:defOrg(Alltrim(SUPERGETMV('MV_APICLO9', .F., '')))
    oServCarol:defDomin(Alltrim(SUPERGETMV('MV_APICLO6', .F., '')))
    oServCarol:defUser(Alltrim(SUPERGETMV('MV_APICLO4', .F., '')))
    oServCarol:defPw(Alltrim(SUPERGETMV('MV_APICLO5', .F., '')))
    oServCarol:defApiToken(Alltrim(SUPERGETMV('MV_APICLOA', .F., '')))
    /* Caso cPath não seja informado, será considerado o caminho da api '/api/v3/oauth2/token'*/
    oServCarol:defEndpoint(/*cPath*/)
    
    If !Empty(oServCarol:getApiToken(cApiToken))
        If !oServCarol:validToken(cApiToken)
            oServCarol:auth(/*cPath*/,"user",/*cParamKey*/,/*lGeraToken*/.T.,/*cTknApiEnd*/)
        Else
            oServCarol:defLToken(.T.) 
            oServCarol:auth(/*cPath*/,"chaveAuth",/*cParamKey*/,/*lGeraToken*/.F.,/*cTknApiEnd*/)
        EndIf
    Else
        oServCarol:auth(/*cPath*/,"user",/*cParamKey*/,/*lGeraToken*/.T.,/*cTknApiEnd*/)
    EndIf
    
    if !oServCarol:getLError()
        If FindFunction("TECTelMets")
	        TECTelMets("login_carol_app", "meu-posto-by-carol-totvsapp_users_total",,dDatabase)
            TECTelMets("login_carol_portal", "portal-operacional-totvsapp_users_total",,dDatabase)
	    Endif	 
    EndIf

    If lLog
        oServCarol:gerarLog(cNomeFile)
    EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} processData

@description Realiza o envio de imagens para a plataforma carol, utilizando um 
objeto do tipo ServCarol, autenticado
@param oServCarol, ServCarol, objeto autenticado do tipo ServCarol
@author	Diego Bezerra
@since	18/04/2023
/*/
//------------------------------------------------------------------------------
Static Function processData(oServCarol,aData,lInvite)
    Local cPathPict		:= GetSrvProfString("Startpath","")
    Local cBmpPic       := ""
    Local aParams       := {}
    Local oSayMtr       := NIL
    Local oMeter        := Nil
    Local oDlg          := Nil
    Local nMeter        := 0
    Local aAtend        := {}
    Local cMtrTitle     := ""
    Local cMtrMsg       := ""
    Default aData       := {}
   
    If lInvite
        cMtrTitle   := "Criação de usuários Carol."
        cMtrMsg     := "Enviando convite para os usuários." 
    Else
        cMtrTitle   := STR0003
        cMtrMsg     := STR0004
    EndIf

    If !Empty(oServCarol:getAuthToken()) .OR. oServCarol:lApiToken 
        If !Empty(aData)
            aAtend := aData
        EndIf

        AADD(aParams, {'conectorId', oServCarol:getConector()})
        AADD(aParams, {'returnData', 'true'})
        
        DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE cMtrTitle Style 128 //"Exportar fotos para a Plataforma Carol" 
            oSayMtr := tSay():New(10,10,{||cMtrMsg},oDlg,,,,,,.T.,,,220,20) //"Enviando fotos, aguarde..." 
            oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},Len(aAtend),oDlg,220,10,,.T.)
        ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnvioCarol(@oDlg,@oMeter,aAtend,cBmpPic,cPathPict,aParams,@oServCarol,lInvite))
    Else
        oServCarol:defError('Exportarfotos','Erro ao obter o token de autenticação com a plataforma carol. Programa tecxcarol')
    EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} EnvioCarol

@description Realiza o envio das fotos para a plataforma Carol
@param oDlg, objeto, representação da janela que exibirá o componente contador de progresso oMeter
@param oMeter, objeto, representa o objeto contador de progresso
@param aAtend, array, array com dados e fotos do atendente que serão enviadas
@param cBmpPic, string, nome do arquivo de foto que será criado (extraído do cadastro de funcionários)
@param cPathPict, string, caminho padrão do arquivo que será criado (geralmente pasta system)
@param aParams, array, parâmetros adicionais para o envio das fotos
@param oServCarol, objeto, objeto do tipo ServCarol utilizado para fazer a integração entre protheus e carol

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static function EnvioCarol(oDlg, oMeter, aAtend, cBmpPic, cPathPict, aParams, oServCarol, lInvite)
Local cBase64       := ""
Local cBodyStagin   := ""
Local nX            := 1
Local lLoadBar      := !isBlind() .AND. oMeter != nil .AND. oDlg != nil
Local oFile         := Nil
Local nCount        := 0

For nX := 1 to Len(aAtend)
    If lInvite
        oServCarol:sendUserInvite(;
                    "mdmAdminInvite",;
                    ALLTRIM(aAtend[nX][3]),;
                    oServCarol:getBaseUrl()+"/auth/register/env/"+oServCarol:getOrg()+"?",;
                    "business";
                )
        oServCarol:gerarLog()
        If FindFunction("TECTelMets")
	        TECTelMets("incluir_usuario_app", "meu-posto-by-carol-totvsapp_users_total",,dDatabase)
            TECTelMets("incluir_usuario_portal", "portal-operacional-totvsapp_users_total")
	    Endif 
    Else
        cBmpPic := UPPER(ALLTRIM(aAtend[nX][1]))
        If RepExtract(cBmpPic,cPathPict+cBmpPic)
            If File(cPathPict + cBmpPic+".JPG")
                oFile := FwFileReader():New(cPathPict + cBmpPic+".JPG")
                If oFile:Open()
                    cBase64 := Encode64(,oFile:CFILENAME,.F.,.F.)
                    cBase64 := "data:image/jpg;base64," + cBase64
                    cBodyStagin := '[{"imagecode":"' + aAtend[nX][2] + '","imagedata": "' + cBase64 + '","imagesequence": 1 }]'
                    oServCarol:addStagingValue(;
                        /*cTable*/"employeeimage",;
                        /*cBodyReq*/cBodyStagin,;
                        /*aParams*/aParams,;
                        /*cConector*/,;
                        /*cEndPoint*/,;
                        /*cAuth*/,;
                        /*aCustomHeaders*/;
                    )

                    If FindFunction("TECTelMets")
                        TECTelMets("exportar_foto_app", "meu-posto-by-carol-totvsapp_users_total",,dDatabase)
                        TECTelMets("exportar_fotos_portal", "portal-operacional-totvsapp_users_total",,dDatabase)
                    EndIf
                    
                    setEnvCarol(aAtend[nX][4],aAtend[nX][3])
                EndIf
            EndIf
        EndIf
    EndIf
    If lLoadBar
        oMeter:Set(++nCount)
        oMeter:Refresh()
    EndIf
Next nX

If lLoadBar
    oDlg:End()
    If lInvite
        Help(" ",1,STR0005, ,"Convite para utilização enviado com sucesso.", 3, 1 )//"Integração Carol"#"Convite para utilização enviado com sucesso."
    Else
        Help(" ",1,STR0005, ,STR0006, 3, 1 )//"Integração Carol"#"Processamento de envio das fotos finalizado. "
    EndIf
EndIF

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} qryBrw

@description Responsável por fazer a query utilizada na montagem do mark browse
@param cMark, string, restorna query, alias e colunas que serão exibidas no mark browse
@param cCodtec, string, código do técnico que será exportado. Parâmetro não obrigatório. 

@return aRet, array, {query<string>, alias<string>, colunas<array>}
@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function qryBrw(cMark,cCodTec,lInvite)

Local cQry      := ''
Local aCampos   := {}
Local aRetCol   := {}
Local cAlias    := GetNextAlias()
Local nX        := 1
Local aTmpFld   := {}
Local nReg      := 0
Local aRet      := {}
Local nNumQuery := 1
Local oQuery    := Nil

Default cMark   := 'C'
Default cCodTec := ''

aAdd(aCampos, 'AA1_CODTEC')
aAdd(aCampos, 'AA1_NOMTEC')

If lInvite
    aAdd(aCampos, 'AA1_EMAIL')

    cQry += "SELECT '' OK, AA1_FILIAL,AA1_CODTEC, AA1_NOMTEC, AA1_EMAIL, AA1_ICAROL "
    cQry += " FROM ? AA1 "
    cQry += " WHERE AA1.AA1_FILIAL = ? "
    cQry += " AND AA1.D_E_L_E_T_ = ' ' "
    cQry += " AND AA1.AA1_EMAIL <> ' ' "
Else
    cQry += "SELECT '' OK, AA1_FILIAL,AA1_CODTEC, AA1_NOMTEC, AA1_EMAIL, AA1_ICAROL, RA_CIC, RA_BITMAP "
    cQry += "FROM ? AA1 "
    cQry += "INNER JOIN ? SRA "
    cQry += "ON SRA.RA_MAT = AA1.AA1_CDFUNC AND "
    cQry +=    "SRA.RA_FILIAL = AA1.AA1_FUNFIL AND " 
    cQry +=    "SRA.RA_BITMAP <> ' ' AND "
    cQry +=    "SRA.D_E_L_E_T_ = ' ' "
    cQry += "WHERE AA1.D_E_L_E_T_ = ' ' "
EndIf

If !Empty(cCodTec)
    cQry += "AND AA1.AA1_CODTEC = ? "
EndIf

cQry := ChangeQuery( cQry )
oQuery := FwExecStatement():New( cQry )

If lInvite
    oQuery:SetUnsafe( nNumQuery++, RetSqlName('AA1') )
    oQuery:SetString( nNumQuery++, xFilial('AA1') )
Else
    oQuery:SetUnsafe( nNumQuery++, RetSqlName('AA1') )
    oQuery:SetUnsafe( nNumQuery++, RetSqlName('SRA') )
EndIf

If !Empty(cCodTec)
    oQuery:SetString( nNumQuery++, ALLTRIM(cCodTec) )
EndIf

cQry := oQuery:GetFixQuery()
cAlias := oQuery:OpenAlias()

dbSelectArea(cAlias)
While !(cAlias)->(Eof()) 
    nReg++
    (cAlias)->(DbSkip())
End
(cAlias)->(DbGoTop())
If nReg > 0
    For nX := 1 to Len(aCampos)
        aTmpFld := retInfFld(aCampos[nX])

        aAdd(aRetCol, FWBrwColumn():New())
        aRetCol[nX]:SetData( &("{||" + aCampos[nX] + "}"))
        aRetCol[nX]:SetTitle(aTmpFld[1])
        aRetCol[nX]:SetSize(aTmpFld[3])
        aRetCol[nX]:SetDecimal(aTmpFld[4])
        aRetCol[nX]:SetPicture(aTmpFld[5])
    Next nX
    aRet := {cQry,cAlias,aRetCol}
EndIf
oQuery:Destroy()
FwFreeObj(oQuery)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} attToCarol

@description Abrir browse para exibir os atendentes, que são funcionários e serão exportados para a Carol
@param oView, objeto, objeto de view passado via chamada da view def do teca020, quando chamado do menu da view

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Function attToCarol(lUnic,cCod,lInvite, lLog, cNomeFile)
Local aRetQry       := {} 
Local oMark         := FWMarkBrowse():New()
Local cTabAlias     := getNextAlias()
Local cMsg          := ""
Local cCodTec       := ""
Local cBwTitle      := ""
Local cBwDesc       := ""
Local cBtnTitle     := ""
Default cAlias      := ""
Default lInvite     := .F.
Default lLog        := .T.
Default cNomeFile   := 'AtendenteToCarol'

If !Valtype(lInvite) == 'L'
    lInvite := .F.
EndIf

If lInvite
    cBwTitle    := STR0021 //"Convidar usuários para o app meu posto by carol."
    cBwDesc     := STR0022 //"Enviar Convites"
    cBtnTitle   := STR0023 //"Enviar"
Else
    cBwTitle := STR0007
    cBwDesc  := STR0009
    cBtnTitle := STR0008
EndIf
If Valtype(lUnic) == 'L' .AND. lUnic
    cCodTec := cCod
EndIf

If AA1->(ColumnPos('AA1_ICAROL')) > 0
    If !Empty(cCodTec)
        sendDataCarol(,cCodTec,lInvite, lLog, cNomeFile)
    Else
        aRetQry := qryBrw('C',,lInvite)
        If Len(aRetQry) > 0
            (aRetQry[2])->(DbCloseArea()) //Fecha a área que foi aberta na query
            If !IsBlind()
                DEFINE MSDIALOG oDlg TITLE cBwTitle From 300,0 To 700,1000 PIXEL //"Exportação de atendentes x Plataforma Carol"
                    oMark:SetOwner(oDlg)
                    oMark:SetDataQuery(.T.)
                    oMark:AddButton(cBtnTitle,{||sendDataCarol(oMark,,lInvite,lLog, cNomeFile),oDlg:End()},,3,)
                    oMark:AddButton("Marcar todos",{||oMark:AllMark()})			
                    oMark:setDescription(cBwDesc) 
                    oMark:setAlias(cTabAlias)
                    oMark:setQuery(aRetQry[1])
                    oMark:setColumns(aRetQry[3])
                    oMark:setFieldMark('OK')
                    oMark:setAllMark({|| oMark:AllMark() })
                    oMark:DisableReport()
                    oMark:SetMenuDef("")
                    oMark:Activate()
                    markReg(oMark)
                ACTIVATE MSDIALOG oDlg CENTERED
            EndIf
        Else
            Help(" ",1,STR0010, ,STR0011, 3, 1 )//"Integração Carol"#"Não existem atendentes com fotos para serem exportadas."
        EndIf
    EndIf
Else
    // Exibe mensagem de erro caso não exista o campo AA1_ICAROL criado
    cMsg += STR0012 + CRLF //'É necessário a criação do campo'
    cMsg += STR0013 + ' AA1_ICAROL'+CRLF //"Nome: "
    cMsg += STR0014 + CRLF //' Titulo: Int. Carol'
    cMsg += STR0015 + CRLF //' Tipo: Numérico'
    cMsg += STR0016 + CRLF //' Tamanho: 1'
    cMsg += STR0017 // ' Formato: 9'
    IF !ISBLIND()
        AtShowLog(cMsg, STR0018,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)  //'Necessidade de ajustes na base de dados'
    EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} markReg

@description Realiza a marcação dos registros elegíveis para exportação de fotos
@param oMark, objeto, objeto que representa o markbrowse

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static function markReg(oMark)

Local nX        := 1
Local nLimite   := 1
Local cAlias    := oMark:Alias()

DbSelectArea('AA1')
oMark:GoBottom(.F.)
nLimite := oMark:At()
oMark:GoTop()

For nX := 1 to nLimite
    IF (cAlias)->AA1_ICAROL <> 2
        oMark:MarkRec()
    EndIf
    oMark:GoDown()
Next nX
oMark:Refresh(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} retInfFld

@description Retorna a estrutura de um determinado campo, do dicionário de dados
@param cCampo, string, nome do campo

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function retInfFld( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
SX3->( DbGoTop() )

If ( SX3->( MsSeek( cCampo ) ) )

	AAdd( aDados, X3Titulo() )			//Retorna título do campo no X3
	AAdd( aDados, X3Descric() )			//Retorna descrição do campo no X3
	AAdd( aDados, TamSX3(cCampo)[1] )	//Retorna tamanho do campo
	AAdd( aDados, TamSX3(cCampo)[2] )	//Retorna quantidade de casas decimais do campo
	AAdd( aDados, X3Picture(cCampo) )	//Retorna a picture do campo

EndIf

RestArea( aArea )

Return aDados

//------------------------------------------------------------------------------
/*/{Protheus.doc} setEnvCarol

@description Atualiza o registro da tabela AA1 para sinalizar que este teve a foto enviada para a plataforma Carol
@param cFil, string, filial
@param cCodTec, string, código do técnico que será enviado

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function setEnvCarol(cFil,cCodTec)

Local aAreaAA1 := AA1->(GetArea())

AA1->(DbSetOrder(1))
AA1->(DbSeek(cFil+cCodTec))
AA1->(RecLock("AA1",.F.))
AA1->AA1_ICAROL := 2
AA1->(MsUnlock())

RestArea(aAreaAA1)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} sendDataCarol

@description Realiza a exportação das fotos para a plataforma carol
@param oMark, objeto, objeto que representa o markbrowse
@param cCodTec, string, código do técnico que será enviado

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function sendDataCarol(oMark,cCodTec,lInvite, lLog, cNomeFile)

Local nX        := 1
Local nLimite   := 1
Local cAlias    := ''
Local aData     := {}
Local aAux      := {}
Local aDtReturn := {}

Default lInvite    := .F.
Default lLog       := .T.
Default cNomeFile  := 'integracaocarol'

/* 
Array com dados do processamento
Posições:
 1-Array com erros
 2-Contador de registros que serão processados (numérico)
 3-Contador de registros que tiveram problemas no envio
*/
Default oMark      := Nil

Default cCodTec := ""

If !Empty(cCodTec)
    aAux := qryBrw(,cCodTec,lInvite)
    If Len(aAux) > 0
        cAlias := aAux[2]
        if lInvite
            aAdd(aData,{(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL}) 
        Else
            aAdd(aData,{ENCODEUTF8((cAlias)->RA_BITMAP),(cAlias)->RA_CIC,(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL})
        EndIf
        TecFtCarol(aData,@aDtReturn,lInvite, lLog)
    Else
        Help(" ",1,STR0005, ,STR0019, 3, 1 )//"Integração Carol"#//"O atendente não tem fotos para exportar.""O atendente não tem fotos para exportar."
    EndIf
Else
    cAlias := oMark:Alias()
    aAdd(aDtReturn,{{},0})
    oMark:GoBottom(.F.)
    nLimite := oMark:At()
    oMark:GoTop()
    aDtReturn[1][2] := nLimite
    
    For nX := 1 to nLimite
        If oMark:isMark()
            If lInvite
                aAdd(aData,{(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL})
            Else
                aAdd(aData,{ENCODEUTF8((cAlias)->RA_BITMAP),(cAlias)->RA_CIC,(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL}) 
            EndIf
        EndIf
        oMark:GoDown()
    Next nX

    oMark:GoTop()
    If Len(aData) > 0
        TecFtCarol(aData,@aDtReturn, lInvite, lLog, cNomeFile)
    Else
        Help(" ",1,STR0005, , STR0020, 3, 1 ) //"Integração Carol"#"Não foram selecionados registros para serem processados. Tente novamente."
    EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} tecInvUsers

@description Realiza o envio de convites de utilização para o aplicativo Meu Posto By Carol
@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Function tecInvUsers(lUnic,cCod)

Default lUnic   := .F.
Default cCod    := ""

    If ValType(lUnic) == 'L' .AND. lUnic
        attToCarol(lUnic,cCod,.T.)
    Else
        attToCarol(.F.,,.T.)
    EndIf
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} atPRTCarol

@description Realiza a integração entre a mesa operacional Protheus e a plataforma Carol
@author	Diego Bezerra
@since	04/10/2023
/*/
//------------------------------------------------------------------------------
Function atPRTCarol(cDtIni,cDtFim, lAuto, lLog, cNomefile)

Local oServCarol    := NIL
Local aMark     := {}
Local lRet      := .T.
Local aArea     := GetArea()

Default cDtini        := ''
Default cDtFim        := ''
Default lAuto         := .F.

lExistT40 := AliasInDic("T40")

If lExistT40
    cDtIni := dToS(cDtIni)
    cDtFim := dToS(cDtFim)
    cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
    cDtFim := Substr(cDtFim,1,4) + '-' + Substr(cDtFim,5,2) + '-' + Substr(cDtFim,7,2)

    If !lAuto
        Processa({|| processCarol(@oServCarol, @aMark, cDtIni, cDtFim, lRet, lLog, cNomeFile)}, "Obtendo dados do aplicativo Meu Posto By Carol", "Aguarde...")
    Else
        processCarol(@oServCarol, @aMark, cDtIni, cDtFim, lRet, lLog, cNomeFile)
    EndIf
EndIf  

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} processCarol

@description Realiza conexão, busca dos apontamentos na plataforma Carol e gravação da tabela t40
dos dados da plataforma Carol
@author	Diego Bezerra
@since	04/10/2023
/*/
//------------------------------------------------------------------------------
Static Function processCarol(oServCarol, aMark, cDtIni, cDtFim, lRet, lLog, cNomeFile)
    connectCarol(@oServCarol, lLog, cNomeFile)
    appointments(@oServCarol,@aMark, cDtini, cDtFim, @lRet)
    t40process(aMark,.F.)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} appointments

@description Realiza a busca dos apontamentos realizados via aplicativo, na plataforma Carol
dos dados da plataforma Carol
@author	Diego Bezerra
@since	04/10/2023
/*/
//------------------------------------------------------------------------------
Static Function appointments(oServCarol, aMark, cDtIni, cDtFim, lRet)
    Local cQuery  := ""
    cQuery += "SELECT clockinDatetimeStr, employeePersonId,supervisorPersonId,clockinCoordinates,deviceCode, "
    cQuery += "CASE WHEN IFNULL(clockinCoordinates, '') = '' THEN '' "
    cQuery += "ELSE CAST(SPLIT(clockinCoordinates, ',')[OFFSET(0)] AS STRING) "
    cQuery += "END AS latitude,"
    cQuery += "CASE WHEN IFNULL(clockinCoordinates, '') = '' THEN '' "
    cQuery += "ELSE CAST(SPLIT(clockinCoordinates, ',')[OFFSET(1)] AS STRING) "
    cQuery += "END AS longitude "
    cQuery += "FROM stg_clockinmobile_clockinrecords "
    cQuery += "WHERE PARSE_DATETIME('%Y-%m-%dT%H:%M:%S', SUBSTR(clockinDatetimeStr, 1, 19)) "
    cQuery += "BETWEEN '"+cDtIni + " 00:00:00' AND '"  + cDtFim + " 23:59:59' "
    If !oServCarol:getLError()
        aMark := oServCarol:getMark(cDtIni,cDtFim,cQuery)
        lRet := .T.
    Else
        lRet := .F.
    EndIf
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} compararData

@description compara duas datas
@author	Diego Bezerra
@since	04/10/2023
/*/
//------------------------------------------------------------------------------
Static function compararData(Item1, Item2)
   Local cDate1 := Item1[1]
   Local cDate2 := Item2[1]
   Local lRet   := 0

   If cDate1 < cDate2
      lRet := -1
   ElseIf cDate1 > cDate2
      lRet := 1
   EndIf

return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} t40process

@description Realiza o processamento das marcações vindas da plataforma Carol e grava na tabela t40
@author	Diego Bezerra
@since	04/10/2023
/*/
//------------------------------------------------------------------------------
Static function t40process(aMarc, lProcIni)
Local dDTMarc	  := CToD("")
Local nTam		  := FwTamSX3("T40_CIC")[1]
Local lenMarc     := 0
Local nMarc       := 0
Local nHoraMarc   := 0
Local cAliasSRA   := ""
Local cQry        := ""
Local cFilFun     := ""
Local cMatFun     := ""
Local cCic        := ''
Local cCicAnt     := ''
Local cTempHora   := ''
Local cProxireg   := ''
Local cLongitude  := ''
Local clatitude   := ''
Local cGeofence   := ''
Local cDispo      := ''
Local lRet        := .T.
Local lAdd        := .T.
Local oQuery      := Nil

Default lProcIni  := .F.

lenMarc := Len(aMarc)
aMarc := ASort(aMarc,,,{|x,y|x[2]+x[1]<y[2]+y[1]})
For nMarc := 1 To lenMarc
    lAdd := .T.
    cTempHora  := SubStr(aMarc[nMarc][1],At("T",aMarc[nMarc][1])+1,5)
    nHoraMarc  := ((Val(SubStr(cTempHora,4,2))/60) + (Val(SubStr(cTempHora,1,2)))) * 3600		
    cDataMarc  := aMarc[nMarc][1]
    cCic       := aMarc[nMarc][2]
    clatitude  := If(Len(aMarc[nMarc]) >= 4 .AND. !Empty(aMarc[nMarc][4]), cValToChar(aMarc[nMarc][5]), "")
    cLongitude := If(Len(aMarc[nMarc]) >= 5 .AND. !Empty(aMarc[nMarc][5]), cValToChar(aMarc[nMarc][4]), "")
    cGeofence  := If(Len(aMarc[nMarc]) >= 6 .AND. !Empty(aMarc[nMarc][6]), cValToChar(aMarc[nMarc][6]), "")
    cDispo     := aMarc[nMarc][3]
    dDTMarc    := sToD( StrTran( SubStr(cDataMarc, 1, 10), "-" ) )

    If !Empty(cLongitude) .AND. !Empty(clatitude)  .AND. !Empty(cCic)
        If cCic <> cCicAnt
            cCicAnt := cCic
            cFilFun := ""
            cMatFun := ""
            cQry := " SELECT RA_FILIAL, RA_MAT FROM ? SRA WHERE "
            cQry += " SRA.RA_CIC = ? AND (RA_DEMISSA=' ' OR RA_DEMISSA > ?) AND "
            cQry += " SRA.D_E_L_E_T_ = ' ' "
            cQry := ChangeQuery( cQry )

            oQuery := FwExecStatement():New(cQry)
            oQuery:SetUnsafe( 1, RetSQLName("SRA") )
            oQuery:SetString( 2, cCic )
            oQuery:SetString( 3, DTOS(dDTMarc) )
            cAliasSRA := oQuery:OpenAlias()

            dbSelectArea(cAliasSRA)
            If (cAliasSRA)->(!Eof())
                cFilFun := (cAliasSRA)->RA_FILIAL
                cMatFun := (cAliasSRA)->RA_MAT
            EndIf
            (cAliasSRA)->(DbCloseArea())
            oQuery:Destroy()
            FwFreeObj(oQuery)
        EndIf

        If !Empty(cFilFun+cMatFun)
            dbSelectArea("T40")
            T40->(DbSetOrder(4)) //T40-FILIAL+T40_CIC+DTOS(dDTMarc)+T40_NUMMAR
            If !T40->(dbSeek(xFilial("T40")+Padr(cCic,nTam)+DTOS(dDTMarc)+Str(nHoraMarc,6,0)))
                BEGIN TRANSACTION
                    cProxireg := TecProNum("T40","T40_VALCON",4)
                    IF T40->( Reclock("T40", .T.))
                        T40->T40_FILIAL := xFilial("T40",cFilFun)
                        T40->T40_VALCON	:= cProxireg
                        T40->T40_CODREL	:= cDispo
                        T40->T40_LOGIP	:= "0"
                        T40->T40_CODNSR	:= 0
                        T40->T40_CODPIS	:= " "
                        T40->T40_DATMAR	:= dDTMarc
                        T40->T40_NUMMAR	:= nHoraMarc
                        T40->T40_CODREP	:= "00001"
                        T40->T40_CODUNI	:= " "
                        T40->T40_LATITU	:= clatitude
                        T40->T40_LONGIT	:= cLongitude
                        T40->T40_GEOFEN	:= cGeofence
                        T40->T40_CIC    := cCic
                        T40->T40_CODFUN := cMatFun
                        T40->( MsUnlock() )
                        T40->( ConfirmSX8() )
                        // Gravar Agendas do atendente na data
                        TeUpdABB(cCic,dDTMarc,cTempHora,cProxireg,cFilFun,cMatFun)
                    EndIf
                END TRANSACTION
            EndIf
        EndIf
    EndIf
Next nMarc

Return lRet

/*/{Protheus.doc} TeUpdABB
// funcao para gravar agenda do atendente
@author flavio.vicco
@since 25/10/2024
@version 1.0
@return NIL
@type static function
/*/
Static Function TeUpdABB(cCic,dDTMarc,cTempHora,cProxireg,cFilFun,cMatFun)

Local aRtABB   := {}
Local cCicAnt  := ""
Local cHoraSav := ""
Local cMarcSav := ""
Local dDtAnt   := CToD("")
Local lPendSav := .T.
Local lOk      := .F.
Local nCont    := 0
Local nRecNSav := 0

// Pesquisar Agendas do atendente na data
If dDtAnt <> dDTMarc .OR. cCic <> cCicAnt
    dDtAnt  := dDTMarc
    cCicAnt := cCic
    aRtABB  := TeGetAgen(cCic,dDTMarc,cFilFun,cMatFun)
EndIf

For nCont := 1 To Len(aRtABB)
    cHoraSav := ""
    cMarcSav := ""
    lPendSav := .F.
    nRecNSav := 0
    // Gravar marcacao na Agenda do Atendente na sequencia
    ABB->(dbGoto(aRtABB[nCont,1]))
    RecLock("ABB", .F.)
    //INTRAJORNADA (SEM INTERVALO):
    If Len(aRtABB) == 2
        //Na intrajornada é feito check-out e check-in fake com o horário do "intervalo" 
        //apenas para seguir estrutura da ABB para envio pro Ponto eletrônico
        If aRtABB[nCont,14] //Se .T. intrajornada
            //Se PRIMEIRO período, existe check-IN e data+hora marcaç posterior a intrajornada -> faz check-OUT fake:
            If nCont == 1 .And. !aRtABB[nCont,02] .And. (aRtABB[nCont+1,03]) .Or. (aRtABB[nCont,02] .And. !(dDTMarc == ABB->ABB_DTFIM .And. cTempHora < aRtABB[nCont,05]))
                ABB->ABB_DTCHOU  := ABB->ABB_DTFIM
                ABB->ABB_MARSAI  := ""
                ABB->ABB_HRCOUT  := aRtABB[nCont,05] //Fake check-OUT com Hora final
                ABB->ABB_SAIU    := "S"
                ABB->ABB_ATENDE  := "1"
                aRtABB[nCont,03] := .T. // marca agenda atendida SAIDA
                aRtABB[nCont,09] := dDTMarc
                aRtABB[nCont,11] := cTempHora
            //Se SEGUNDO período, não existe check-IN e data+hora marcaç posterior a intrajornada -> faz check-IN fake:
            ElseIf nCont == 2 .And. !aRtABB[nCont,2] .And. !(dDTMarc == ABB->ABB_DTINI .And. cTempHora < aRtABB[nCont,5])
                ABB->ABB_DTCHIN  := ABB->ABB_DTINI
                ABB->ABB_MARENT  := ""
                ABB->ABB_HRCHIN  := aRtABB[nCont,4] //Fake check-IN com Hora Inicial
                ABB->ABB_CHEGOU  := "S"
                aRtABB[nCont,02] := .T. // marca agenda atendida ENTRADA
                aRtABB[nCont,08] := dDTMarc
                aRtABB[nCont,10] := cTempHora
            EndIf
        EndIf
    EndIf
    // Verifica se checkin entrada = .F. ou checkin saida = .F. e sem manutencao manual
    If !aRtABB[nCont,02] .And. !aRtABB[nCont,06]
        // Comparar Hora Entrada do segundo periodo com Hora Saida do primeiro periodo em um mesmo dia e sem manutencao manual
        If nCont == 2 .And. aRtABB[1,09] == dDTMarc .And. aRtABB[1,11] > cTempHora .And. !aRtABB[1,07]
            cHoraSav := aRtABB[1,11]
            cMarcSav := aRtABB[1,13]
            // Atualizar a saida no registro anterior com hora a menor
            lPendSav := .T.
            nRecNSav := aRtABB[1,01]
            // Atualizar a entrada no posterior com hora a maior
            ABB->ABB_DTCHIN  := dDTMarc
            ABB->ABB_MARENT  := cMarcSav
            ABB->ABB_HRCHIN  := cHoraSav
            ABB->ABB_CHEGOU  := "S"
            aRtABB[nCont,02] := .T. // marca agenda atendida ENTRADA
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cHoraSav
        Else
            ABB->ABB_DTCHIN  := dDTMarc
            ABB->ABB_MARENT  := cProxireg
            ABB->ABB_HRCHIN  := cTempHora
            ABB->ABB_CHEGOU  := "S"
            aRtABB[nCont,02] := .T. // marca agenda atendida ENTRADA
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cTempHora
        EndIf
        lOk := .T.
    ElseIf !aRtABB[nCont,03] .And. !aRtABB[nCont,07]
        // Comparar Hora Saida com Hora Entrada dentro de um mesmo periodo em um mesmo dia e sem manutencao manual
        If aRtABB[nCont,08] == dDTMarc .And. aRtABB[nCont,10] > cTempHora .And. !aRtABB[nCont,06]
            cHoraSav := TRIM(ABB->ABB_HRCHIN)
            cMarcSav := ABB->ABB_MARENT
            // Atualizar a entrada com hora a menor
            ABB->ABB_MARENT  := cProxireg
            ABB->ABB_HRCHIN  := cTempHora
            aRtABB[nCont,02] := .T. // marcar agenda atendida ENTRADA
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cTempHora
            // Atualizar a saida com hora a maior
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cMarcSav
            ABB->ABB_HRCOUT  := cHoraSav
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T. // marcar agenda atendida SAIDA
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
        Else
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cProxireg
            ABB->ABB_HRCOUT  := cTempHora
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T. // marcar agenda atendida SAIDA
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
        EndIf
        lOk := .T.
    EndIf
    ABB->(MsUnlock())
    If lOk
        If lPendSav
            // Gravacao da Agenda do periodo anterior e mesmo dia com hora a maior
            ABB->(dbGoto(nRecNSav))
            RecLock("ABB", .F.)
            // Atualizar a saida com hora a menor
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cProxireg
            ABB->ABB_HRCOUT  := cTempHora
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T. // marcar agenda atendida SAIDA
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
            ABB->(MsUnlock())
        EndIf
        Exit
    EndIf
Next nCont

Return

/*/{Protheus.doc} TeGetAgen
// funcao para pesquisar agendas do atendente
@author flavio.vicco
@since 31/10/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function TeGetAgen(cCic,dDTMarc,cFilFun,cMatFun)
Local aArea      := GetArea()
Local aRet       := {}
Local cAliasABB  := ""
Local cQry       := ""
Local lMV_MultFil:= TecMultFil() //Indica se considera multiplas filiais
Local nNumQuery  := 1
Local oQuery     := Nil

cQry := " SELECT ABB.R_E_C_N_O_ RECABB,   ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_HRCHIN, ABB.ABB_HRCOUT, "
cQry += " ABB.ABB_MARENT, ABB.ABB_MARSAI, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_DTCHIN, ABB.ABB_DTCHOU, "
cQry += " COALESCE(TV3_HRCHIN,'-') TV3_HRCHIN, COALESCE(TV3_HRCOUT,'-') TV3_HRCOUT "
cQry += " FROM ? ABB "
    cQry += " INNER JOIN ? AA1 ON "
        cQry += " AA1.AA1_FILIAL = ? AND "
        cQry += " AA1.AA1_FUNFIL = ? AND "
        cQry += " AA1.AA1_CDFUNC = ? AND "
        cQry += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
        cQry += " AA1.D_E_L_E_T_ = ' ' "
    cQry += " INNER JOIN ? TDV ON "
        cQry += " TDV.TDV_FILIAL= ABB.ABB_FILIAL AND "
        cQry += " TDV.TDV_CODABB=ABB.ABB_CODIGO AND "
        cQry += " TDV.D_E_L_E_T_ = ' ' "
        cQry += " AND TDV.TDV_DTREF IN ( "
            cQry += " SELECT DISTINCT TDV.TDV_DTREF "
            cQry += " FROM ? ABB "
            cQry += " INNER JOIN ? AA1 ON AA1.AA1_FILIAL = ? AND AA1.AA1_FUNFIL = ? AND AA1.AA1_CDFUNC = ? AND AA1.AA1_CODTEC = ABB.ABB_CODTEC AND AA1.D_E_L_E_T_ = ' ' "
            cQry += " INNER JOIN ? TDV ON TDV.TDV_FILIAL = ABB.ABB_FILIAL AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.D_E_L_E_T_ = ' ' "
            cQry += " WHERE "
            If !lMV_MultFil
                cQry += " ABB.ABB_FILIAL = ? AND "
            EndIf
            cQry += " ABB.ABB_ATIVO = '1' AND ( ABB.ABB_DTINI = ? OR ABB.ABB_DTFIM = ? ) AND ABB.D_E_L_E_T_ = ' ') "
    cQry += " LEFT JOIN ? TV3 ON "
        cQry += " TV3.TV3_FILIAL = ? AND "
        cQry += " TV3.TV3_FILABB = ABB.ABB_FILIAL AND "
        cQry += " TV3.TV3_CODABB = ABB.ABB_CODIGO AND "
        cQry += " TV3.D_E_L_E_T_ = ' ' "    
cQry += " WHERE "
    If !lMV_MultFil
        cQry += " ABB.ABB_FILIAL = ? AND "
    EndIf
    cQry += " ABB.ABB_ATIVO = '1' AND "
    cQry += " ABB.D_E_L_E_T_ = ' ' "
cQry += " ORDER BY "
    cQry += " ABB.ABB_DTINI, ABB.ABB_HRINI "

//Prepara a query:
oQuery := FwExecStatement():New(cQry)

//SELECT ABB
oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABB") )
//INNER JOIN AA1
oQuery:SetUnsafe( nNumQuery++, RetSQLName("AA1") )
oQuery:SetString( nNumQuery++, FwxFilial("AA1",cFilFun) )
oQuery:SetString( nNumQuery++, cFilFun)
oQuery:SetString( nNumQuery++, cMatFun)
//INNER JOIN TDV
oQuery:SetUnsafe( nNumQuery++, RetSQLName("TDV") )
//SUBQUERY
oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABB") )
oQuery:SetUnsafe( nNumQuery++, RetSQLName("AA1") )
oQuery:SetString( nNumQuery++, FwxFilial('AA1',cFilFun) )
oQuery:SetString( nNumQuery++, cFilFun)
oQuery:SetString( nNumQuery++, cMatFun)
oQuery:SetUnsafe( nNumQuery++, RetSQLName("TDV") )
If !lMV_MultFil
    oQuery:SetString( nNumQuery++, FwxFilial("ABB",cFilFun) )
EndIf
oQuery:SetString( nNumQuery++, DTOS(dDTMarc) )
oQuery:SetString( nNumQuery++, DTOS(dDTMarc) )
//Historico ajustes de batidas  
oQuery:SetUnsafe( nNumQuery++, RetSQLName("TV3") )
oQuery:SetString( nNumQuery++, FwxFilial('TV3',cFilFun) )
//WHERE ABB
If !lMV_MultFil
    oQuery:SetString( nNumQuery++, FwxFilial("ABB",cFilFun) )
EndIf

cAliasABB := oQuery:OpenAlias()

dbSelectArea(cAliasABB)
While (cAliasABB)->(!Eof())
    //Se não tem hora informada ou não tem codigo da marcação considera agenda não atendida pela Carol
    aAdd(aRet,{(cAliasABB)->RECABB,;
                !(Empty((cAliasABB)->ABB_HRCHIN).Or.Empty((cAliasABB)->ABB_MARENT)),;
                !(Empty((cAliasABB)->ABB_HRCOUT).Or.Empty((cAliasABB)->ABB_MARSAI)),;
                TRIM((cAliasABB)->ABB_HRINI),;
                TRIM((cAliasABB)->ABB_HRFIM),;
                !Empty((cAliasABB)->ABB_HRCHIN).And.TRIM((cAliasABB)->ABB_HRCHIN)==TRIM((cAliasABB)->TV3_HRCHIN),;
                !Empty((cAliasABB)->ABB_HRCOUT).And.TRIM((cAliasABB)->ABB_HRCOUT)==TRIM((cAliasABB)->TV3_HRCOUT),;
                SToD((cAliasABB)->ABB_DTCHIN),;
                SToD((cAliasABB)->ABB_DTCHOU),;
                (cAliasABB)->ABB_HRCHIN,;
                (cAliasABB)->ABB_HRCOUT,;
                (cAliasABB)->ABB_MARENT,;
                (cAliasABB)->ABB_MARSAI,;
                .F.}) //INTRAJORNADA ?
    (cAliasABB)->(DbSkip())
EndDo
(cAliasABB)->(DbCloseArea())
RestArea(aArea)
oQuery:Destroy()
FwFreeObj(oQuery)

//Intrajornada (SEM INTERVALO):
If Len(aRet) == 2
    //Se a hora final do primeiro PERÍODO for igual a inicial do segundo PERÍODO:
    If aRet[1,5] == aRet[2,4]
        aRet[1,14] := .T. //MARCA INTRAJORNADA COMO TRUE
        aRet[2,14] := .T. //MARCA INTRAJORNADA COMO TRUE
    EndIf
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecProNum

@description Retornar proximo codigo 
@author	Diego Bezerra
@since	28/07/2023
/*/
//------------------------------------------------------------------------------
Static Function TecProNum(cAlias,cCampo,nIndex)

Local aArea     := GetArea()
Local aAreaTmp  := (cAlias)->(GetArea())
Local cProxNum  := ""
Local lSeek     := .T.

Default cAlias := "T40"
Default cCampo := "T40_VALCON"
Default nIndex := 1

If cCampo == 'T40_VALCON'
    DbSelectArea('T40')
    DbSetOrder(1)
    While lSeek
        cProxNum    := GetSxeNum(cAlias, cCampo,, nIndex)
        lSeek       := DbSeek( xFilial('T40')+cProxNum)
    EndDO
Else 
    cProxNum := GetSxeNum(cAlias, cCampo,, nIndex)
EndIf

dbSelectArea(cAlias)
dbSetOrder(nIndex)

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)

//------------------------------------------------------------------------------
/*/{Protheus.doc} tecConfCarol

@description 
@author	Diego Bezerra
@since	23/11/2023
/*/
//------------------------------------------------------------------------------
Function tecConfCarol()
    Local oWizard As Object
    oWizard := FWCarolWizard():New()
    oWizard:SetExclusiveCompany(.F.)
Return oWizard:Activate()
