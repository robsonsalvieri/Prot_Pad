#INCLUDE "TOTVS.CH"
#INCLUDE "TCFA160.CH" // Criar a include.

STATIC oQryFb    := NIL
STATIC cAccToken := Nil
STATIC dDtToken  := Ctod("//")
STATIC nHrToken  := 0


/*/{Protheus.doc} TCFA160
Dispara um Push Notification
@type  Function
@author Henrique Ferreira
@params cRot = Rotina que será executada.
               1 - Recibo de Pagamento
               2 - Férias
               3 - Marcações de Ponto.
               4 - Abonos.
        lAppr = .T. para aprovação, .F. para reprovação.
@since 17/01/2024
/*/
Function TCFA160()

Local aArea		    := GetArea()
Local cDescricao    := STR0001 // Esta rotina envia o Gatilho do Envelope de Pagamento.
Local lTables       := ChkFile("RUY") .And. ChkFile("RUX") .And. ChkFile("RUZ") // RUY - Tokens, RUX - Tipos, RUZ - Logs de envio.
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= { "RA_FILIAL", "RA_MAT", "RA_NOME" }
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private aLogTitle	:= {}
Private aLogRUZ 	:= {{}}

If !lTables
    //"Funcionalidade não disponível para esta versão do sistema."
    Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0003}) // "As tabelas RUY, RUX ou RUZ não foram encontradas."
    Return
EndIf

If !fExistPerg("TCFA160")
    //"Funcionalidade não disponí­vel para esta versío do sistema."
    Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0013}) // "Não foi encontrado o grupo de perguntas do TCFA160."
    Return
EndIf

If lBlqAcesso
    //"Dados Protegidos-Acesso Restrito"
    Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
    Break
EndIf

// Criar grupo de perguntas no ATUSX
Pergunte("TCFA160", .F.)

// Se entrar no IF é que foi executado pelo protheus
If !( isBlind() )
    tNewProcess():New( "TCFA160", STR0004, {|oSelf| fProcPush(oSelf) }, cDescricao, "TCFA160",,,,,,.T.) // "Enviando Notificações."
    MsAguarde({|| fMakeLog( aLogRUZ, aLogTitle, "TCFA160", NIL , "TCFA160", STR0005 )}, STR0005) // "Ocorrências no envio das notificações."
Else
    // Se entrar no else é que foi executado via Schedule ou pelas rotinas de solicitações do MeuRH.
    fProcPush()
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fProcPush
Busca as informações e dispara as notificações
@type  Function
@author Henrique Ferreira
@since 17/01/2024
@param oProcess, Objeto, instí¢ncia da classe tNewProcess
       cRotina, String, rotina que será disparada a notificação
                1 - Recibo
                2 - Férias
                3 - Ponto
                4 - Abono
/*/
Function fProcPush(oProcess, aDados)

    Local aArea         := GetArea()
    Local cWhere		:= ""
    Local cFilDe        := ""
    Local cFilAte       := ""
    Local cMatDe        := ""
    Local cMatAte       := ""
    Local cCCDe         := ""
    Local cCCAte        := ""
    Local cDeptoDe      := ""
    Local cDeptoAte     := ""
    Local cCpf          := "!!"
    Local lRet          := .T.
    Local cInicio       := "SRA->RA_FILIAL + SRA->RA_MAT"
    Local cFim          := ""
    Local aAreaSRA      := SRA->(GetArea())
    Local aAreaRUY      := RUY->(GetArea())
    Local lProcRegua    := .F.
    Local lToken        := .F.

    Private oMsg       := NIL
    Private aVerbas    := {}
    Private lMeuRH     := .F.
    Private cFilFb     := ""
    Private cMatFb     := ""
    Private cNome      := ""
    Private cDestino   := ""
    Private cFilProc   := ""
    Private cCodRH3    := ""
    Private cFilIni    := ""
    Private cMatIni    := ""
    Private cEmpIni    := ""
    Private cTipMsg    := "001"
    Private cTitulo    := EncodeUTF8(STR0006) // "Ficou Sabendo?"
    Private cMsg       := EncodeUTF8(STR0007) // "Seu envelope de pagamento está disponível."
    Private cCodRot    := "FOL"
    Private aLibDemo   := {}
    Private cOpReg     := ""

    DEFAULT aDados     := {}

    lMeuRH     := Len(aDados) > 0
    lProcRegua := !lMeuRH .And. !( isBlind() )

    // Se não houver
    cFilDe      := If( lMeuRH, aDados[01], MV_PAR01  )                                          // Filial de quem receberá a notificação
    cFilAte     := If( lMeuRH, aDados[02], MV_PAR02  )                                          // Filial de quem receberá a notificação
    cMatDe      := If( lMeuRH, aDados[03], MV_PAR03  )                                          // Matrícula de quem receberá a notificação
    cMatAte     := If( lMeuRH, aDados[04], MV_PAR04  )                                          // Matrícula de quem receberá a notificação
    cCCDe       := If( lMeuRH, aDados[05], MV_PAR05  )                                          // Centro de Cust de quem receberá a notificação
    cCCAte      := If( lMeuRH, aDados[06], MV_PAR06  )                                          // Centro de Cust de quem receberá a notificação
    cDeptoDe    := If( lMeuRH, aDados[07], MV_PAR07  )                                          // Departamento de quem receberá a notificação
    cDeptoAte   := If( lMeuRH, aDados[08], MV_PAR08  )                                          // Departamento de quem receberá a notificação
    cCodRot     := IF( lMeuRH, aDados[09], AllTrim(MV_PAR09))                                   // Roteiro de cálculo.
    cTipMsg     := If( lMeuRH, aDados[10], If(!Empty(MV_PAR10), cTipMsg, "" ) )                 // Tipo da mensagem 1 = Envelope de Pagamento.
    cTitulo     := If( lMeuRH, aDados[11], If(!Empty(MV_PAR11), AllTrim(MV_PAR11), cTitulo) )   // Titulo utilizado na mensagem.
    cMsg        := If( lMeuRH, aDados[12], If(!Empty(MV_PAR12), AllTrim(MV_PAR12), cMsg ) )     // Mensagem que será enviada.
    cCodRH3     := If( lMeuRH, aDados[13], "")                                                  // Codigo da RH3, conforme solicitação.
    cFilIni     := If( lMeuRH, aDados[14], "")                                                  // Filial da RH3 que recebeu a solicitação
    cMatIni     := If( lMeuRH, aDados[15], "")                                                  // Matricula da RH3 recebeu a solicitação.
    cEmpIni     := If( lMeuRH, aDados[16], "")                                                  // Empresa da RH3 recebeu a solicitação.

    cFim := cFilAte + cMatAte
    DbSelectArea("SRA")
    dbSetOrder(1)
    DbGoTop()
    // seta regua de processamento.
    If lProcRegua
        oProcess:SetRegua1(SRA->(RecCount()))
    EndIf

    If cAccToken == NIL .Or. ;
       dDtToken < Date() .Or. ;
       ( Seconds() - nHrToken > 3600 )
        lToken := fGetToken()
    EndIf

    If lToken
        While SRA->(!EOF()) .And. &cInicio <= cFim
            // Processa Filtros, desprezando demitidos e transferidos.
            IF  ( SRA->RA_FILIAL < cFilDe )  .OR. ( SRA->RA_FILIAL > cFilAte )    .OR. ;
                ( SRA->RA_MAT < cMatDe )   .Or. ( SRA->RA_MAT > cMatAte ) .Or. ;
                ( SRA->RA_CC < cCcDe )     .Or. ( SRA->RA_CC > cCcAte )   .Or. ;
                ( SRA->RA_DEPTO < cDeptoDe ) .Or. ( SRA->RA_DEPTO > cDeptoAte ) .Or. ;
                ( SRA->RA_SITFOLH $ "D/T" )
                SRA->(dbSkip())
                Loop
            EndIf

            cFilFb := SRA->RA_FILIAL
            cMatFb := SRA->RA_MAT
            cNome  := AllTrim(SRA->RA_NOME)

            // movimenta régua de processamento.
            If lProcRegua
                oProcess:IncRegua1(STR0015 + " " + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " - " + SRA->RA_NOME ) // Processando funcionário:
            EndIf

            If RUY->(DbSeek( SRA->RA_FILIAL+SRA->RA_MAT ))

                cFilFb      := RUY->RUY_FILIAL
                cMatFb      := RUY->RUY_MAT
                cDestino    := AllTrim(RUY->RUY_TOKEN)

                // Busca a descrição a mensagem e a descrição
                fBuscaRUX()

                // Gatilho do Recibo de pagamento
                If !( lMeuRH )
                    If !( cFilProc == cFilFb )
                        // Seta array de comparação das verbas com roteiros de cálculo.
                        fSetaVbs()
                        // Busca conteudo dos parametros do recibo de pagamento.
                        fBuscaPars()
                    EndIf
                    // Verifica se o funcionário possui dados de pagamento.
                    If !( lRet := fBuscaVerbas() )
                        SRA->(dbSkip())
                        Loop
                    EndIf
                EndIf

                // Caso possuir, dispara o push e grava.
                fMontaObj()
                fDispara()
                cFilProc := cFilFb
            Else
                fGeraLog(STR0010) // Funcionário sem token cadastrado na tabela RUY.
            EndIf
            SRA->(dbSkip())
        EndDo
    Else
        fGeraLog(STR0016) // Não foi possivel gerar o token de acesso, consulte a documentação para saber mais
    EndIf
    RestArea(aAreaSRA)
    RestArea(aAreaRUY)
    RestArea(aArea)
Return


/*/{Protheus.doc} fBuscaVerbas
Verifica se existe pelo menos uma verba de provento no cálculo mensal do funcionário.
@type static function
@author Henrique Ferreira
@since 17/01/2024
@param 
@return lRet, Lógico, Indica se existe ou não
/*/
Static Function fBuscaVerbas()

    Local cQryObj    := ""
    Local lRet       := .T.
    Local aArea      := GetArea()
    Local cQuery     := GetNextAlias()


    // Query no lançamento mensal do funcionário.
    If oQryFb == Nil .Or. cFilProc <> cFilFb
        oQryFb := FWPreparedStatement():New()
        cQryObj := "SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD, SRC.RC_DATA,"
        cQryObj += " SRV.RV_COD, SRV.RV_TIPOCOD
        cQryObj += " FROM " + RetFullName('SRC', cEmpAnt) + " SRC "
        cQryObj += " INNER JOIN " + RetFullName('SRV', cEmpAnt) + " SRV "
        cQryObj += " ON " +  FWJoinFilial( "SRC", "SRV" ) + " AND SRC.RC_PD = SRV.RV_COD"
        cQryObj += " WHERE "
        cQryObj += " SRC.RC_FILIAL = ?"
        cQryObj += " AND SRC.RC_MAT = ?"
        cQryObj += " AND SRC.RC_ROTEIR = ?"
        cQryObj += " AND SRV.RV_TIPOCOD = '1'"
        cQryObj += " AND SRV.D_E_L_E_T_ = ' '"
        cQryObj += " AND SRC.D_E_L_E_T_ = ' '"

        cQryObj := ChangeQuery(cQryObj)
        oQryFb:SetQuery(cQryObj)
    EndIf

    //DEFINIÇÃO DOS PARÂMETROS.
    oQryFb:SetString(1,cFilFb)
    oQryFb:SetString(2,cMatFb)
    oQryFb:SetString(3,cCodRot)

    //RESTAURA A QUERY COM OS PARÂMETROS INFORMADOS.
    cQryObj := oQryFb:GetFixQuery()

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)

    //Se encontrar pelo menos uma verba de provento, então tem pagamento.
    DbSelectArea(cQuery)
    DbGoTop()
    If ( (cQuery)->( !Eof() ) )
        // Se possuir registro na SRC, verifica se os dados de pagamento estão prontos para serem consultados conforme os parametros.
        If !( lRet := fVldPagto((cQuery)->RC_DATA) )
            fGeraLog(STR0012) // Recibo de pagamento ainda não está disponível para ser consultado.
        EndIf
    Else
        lRet := .F.
        fGeraLog(STR0009) // Funcionários sem pagamentos para o período/roteiro.
    EndIf

    (cQuery)->(dbCloseArea())

    RestArea(aArea)

Return lRet

/*/{Protheus.doc} fExistPerg
Verifica se o grupo de perguntas existe no ambiente
@type static function
@author Henrique Ferreira
@since 17/01/2024
@param cPergunte, Caractere, Código do grupo de perguntas
@return lRet, Lógico, Indica se o grupo de perguntas existe ou nío
/*/
Static Function fExistPerg(cPergunte)
	
	Local lRet	:= .F.
	Local oSX1	:= FWSX1Util():New()
	
	oSX1:AddGroup(cPergunte)
	oSX1:SearchGroup()
	
	If !Empty(oSX1:aGrupo[1,2])
		lRet:= .T.
	EndIf
	
	FreeObj(oSX1)
	
Return lRet


/*/{Protheus.doc} fMontaObj
Monta o objeto que será enviado ao firebase para disparar a notificação
@type static function
@author Henrique Ferreira
@since 17/01/2024
@param  oFB, Objeto, objeto json.
@return lRet, Lógico, Indica se o grupo de perguntas existe ou nío
/*/
Static Function fMontaObj()

    Local oToken  := JsonObject():New()
    Local oNotify := JsonObject():New()

    oMsg          := JsonObject():New()

    oNotify["title"] := cTitulo
    oNotify["body"]  := cMsg
    
    oToken["notification"] := oNotify
    oToken["token"] := cDestino

    oMsg["message"] := oToken

    FreeObj(oToken)
    FreeObj(oNotify)

Return .T.

/*/{Protheus.doc} fDispara
Envia a notificação nos celulares dos colaboradores.
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param
/*/
Static Function fDispara()

    Local cMsgErro := ""
    Local aHeader  := {}
    Local cPath    := "https://fcm.googleapis.com"
    Local cSource  := "/v1/projects/tab1784-service-91-322963/messages:send"
    Local oRest    := NIL
    Local lSuccess := .F.

    AAdd(aHeader, "Content-Type: application/json")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "Authorization: Bearer " + cAccToken)

    oRest := FwRest():New(cPath)
    oRest:SetPath(cSource)
    oRest:SetPostParams(oMsg:toJson())
    If ( lSuccess := oRest:Post(aHeader) )
        fGrava() // // Caso a conexão com o firebase dê sucesso, grava os registros na tabela RUZ.
    Else
        cMsgErro := oRest:GetLastError()
        fGeraLog(STR0011 + cMsgErro)
    EndIf
    
    FreeObj(oRest)
    FreeObj(oMsg)

Return .T.

Static Function fGetToken()

    Local aHeader   := {}
    Local cPath     := "https://api-hrplatform.totvs.app
    Local cSource   := "/hrplatform/api/firebase-access-token"
    Local oRest     := NIL
    Local lSuccess  := .F.
    Local cId       := "firebaseaccess"
    Local cSecret   := "115437260987254067088"
    Local cAccept   := "*/*"
    Local cAgent    := "Platform"

    aAdd(aHeader, "Content-Type: application/json")
    aAdd(aHeader, "User-Agent: " + cAgent)
    aAdd(aHeader, "Accept: " + cAccept) 
    AAdd(aHeader, "ClientId: " + cId)
    AAdd(aHeader, "ClientSecret: " + cSecret)

    oRest := FwRest():New(cPath)
    oRest:SetPath(cSource)
    If ( lSuccess := oRest:Get(aHeader) )
        dDtToken  := Date()
        cAccToken := oRest:GetResult()
        nHrToken  := Seconds()
    EndIf
    FreeObj(oRest)

Return lSuccess

/*/{Protheus.doc} fGrava
Gravar os registros de push na tabela RUZ.
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param
/*/
Static Function fGrava()

    Local cBkpFil   := cFilAnt
    Local aArea     := GetArea()
    Local cCodUser  := RetCodUsr()
    Local nSaveSX8  := GetSX8Len()
    Local cCodigo   := ""
    Local lFilRH3   := RUZ->(ColumnPos("RUZ_FILRH3")) > 0
    Local lMatRH3   := RUZ->(ColumnPos("RUZ_MATRH3")) > 0
    Local lEmpRH3   := RUZ->(ColumnPos("RUZ_EMPRH3")) > 0

    cCodUser := If( Empty(cCodUser), "000000", cCodUser ) 
    cFilAnt := cFilFb
    cCodigo := GetSX8Num("RUZ", "RUZ_CODIGO")
    Begin Transaction
        RecLock("RUZ",.T.)
            RUZ->RUZ_FILIAL     := cFilFb
            RUZ->RUZ_MAT        := cMatFb
            RUZ->RUZ_CODIGO     := cCodigo
            RUZ->RUZ_CODRH3     := cCodRH3
            If lFilRH3
                RUZ->RUZ_FILRH3 := cFilIni
            EndIf
            If lMatRH3
                RUZ->RUZ_MATRH3 := cMatIni
            EndIf
            If lEmpRH3
                RUZ->RUZ_EMPRH3 := cEmpIni
            EndIf
            RUZ->RUZ_DTENVI     := dDataBase
            RUZ->RUZ_TIPMSG     := cTipMsg
            RUZ->RUZ_TITMSG     := DecodeUTF8( cTitulo )
            RUZ->RUZ_MENSAG     := DecodeUTF8( cMsg )
            RUZ->RUZ_USUARI     := cCodUser
            RUZ->RUZ_MSGLID     := .F.
            RUZ->RUZ_HRENVI     := Time()
    End Transaction

    While (GetSx8Len() > nSaveSx8)
        ConfirmSX8()
    EndDo

    // Log de confirmação dos registros gravados.
    fGeraLog(STR0014) // Notificação enviada com sucesso.
    RestArea(aArea)
    cFilAnt := cBkpFil
Return .T.

/*/{Protheus.doc} fGeraLog
Log de processamento.
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param cMsg - Mensagem que será utilizada para gerar o log.
/*/
Static Function fGeraLog(cMsg)

    If !lMeuRH 
        If Empty(aLogTitle)
            Aadd(aLogTitle, STR0008) //"Funcionários processados."
        EndIf
        Aadd(aLogRUZ[1], cFilFb + " - " + cMatFb + " - " + cNome + ": " + cMsg ) // Filial, Matrícula e descrição da mensagem.
    Else
        Conout(cFilFB + " - " + cMatFb + " - " + cNome + ": " + cMsg)
    EndIf

Return .T.

/*/{Protheus.doc} fVldPagto
Verifica se deverá disparar ou não o push conforme a data de pagamento e a configuração dos parâmetros.
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param cDataPagto - Data de Pagamento conforme cálculo da folha - SRC.
/*/

Static Function fVldPagto(cDataPgto)

    Local dDataLib    := ctod("//")
    Local nType       := 0
    Local lMostraRec  := .F.
    
    nType := aScan(aVerbas, {|x| x == cCodRot } )

    If ( nType == 2 .Or. nType == 6 .Or. nType == 8 ) // Folha ou ( Pro-labore e Autonomos) ou Outros Roteiros
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Trata o parametro "MV_TCFDFOL" como excecao, pois este parametro indica a quantidade de dias para liberacao ³
        //³do demonstrativo. Os demais parametros, indicam a data inicial de liberacao.                                ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
        If ( aLibDemo[nType] < 0 )
            lMostraRec  :=  dDataBase - STOD(cDataPgto) >= aLibDemo[nType]
        Else
            lMostraRec  :=  dDataBase >= STOD(cDataPgto) + aLibDemo[nType]
        EndIf
    Else
        If nType > 0
            //Monta a data de liberação do recibo de pagamento.
            dDataLib    :=  StoD(SubStr(cDataPgto,1,4) + SubStr(cDataPgto,5,2) + STRZERO(aLibDemo[nType],2))
            lMostraRec  := ( dDataBase  >= dDataLib )
        EndIf
    EndIf

    //valida se o tipo de holerite deve ser mostrado, para que aconteça os itens deverão ser lanctos no Param
    //01-Adiantamento, 02-Folha, 03-1ª parcela do 13º, 04-2ª parcela do 13º, 05-PLR, 06-Autonomos, 07-Valores Extras 
    If lMostraRec .and. !Empty(cOpReg) .and. !( cValToChar(nType) $ cOpReg )
        lMostraRec := .F.
    EndIF

Return lMostraRec

/*/{Protheus.doc} fSetaVbs
Seta os roteiros de cálculo
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param
/*/
Static Function fSetaVbs()
    aAdd(aVerbas, fGetCalcRot('2',,cFilFb)) // ADI
    aAdd(aVerbas, fGetCalcRot('1',,cFilFb)) // FOL
    aAdd(aVerbas, fGetCalcRot('5',,cFilFb)) // 131
    aAdd(aVerbas, fGetCalcRot('6',,cFilFb)) // 132
    aAdd(aVerbas, fGetCalcRot('F',,cFilFb)) // PLR
    aAdd(aVerbas, fGetCalcRot('9',,cFilFb)) // AUT
    aAdd(aVerbas, fGetCalcRot('K',,cFilFb)) // VEX
    aAdd(aVerbas, fGetCalcRot('7',,cFilFb)) // OUT
Return .T.

/*/{Protheus.doc} fBuscaRUX
Busca as informações da tabela RUX - Cadastro dos tipos de notificação
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param
/*/
Static Function fBuscaRUX()

    Local aArea := GetArea()

    If !Empty(cTipMsg)
        // RUX_FILIAL+RUX_CODIGO
        DBSelectArea("RUX")
        dbSetOrder(1)
        If RUX->(DbSeek( xFilial("RUX", cFilFb) + cTipMsg ))
            cTitulo := EncodeUTF8(AllTrim(RUX->RUX_TITULO))
            cMsg    := EncodeUTF8(AllTrim(RUX->RUX_MENSAG))
        EndIf
    EndIf

    RestArea(aArea)

Return .T.

Static Function fBuscaPars()

    cOpReg      := SuperGetMv('MV_TCF013A',,'01.02.03.04.05.06.07.08',cFilFb) //01-ADI, 02-FOL, 03-131, 04-132, 05-PLR, 06-AUT, 07-VEX, 08-Outros Roteiros
    aLibDemo    := { Val(SuperGetMv("MV_TCFDADT", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFDFOL", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFD131", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFD132", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFDEXT", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFDFOL", NIL, "0",cFilFb)),; // Parametro para ser considerado o pagamento do Autonomo. Mesma tratativa do Portal.
                     Val(SuperGetMv("MV_TCFDEXT", NIL, "0",cFilFb)),;
                     Val(SuperGetMv("MV_TCFDOUT", NIL, "0",cFilFb))}  // Outros roteiros - RY_TIPO == 7
Return .T.

// Função padrão para schedule.
Static Function Scheddef()
    Local aOrd		:= {}
    Local aParam	:= {}

    aParam := {	"P"			, ; // Tipo R para relatorio P para processo
                "TCFA160"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
                ""			, ; // Alias para o relatório
                aOrd		, ; // Array de ordens para o relatório
                ""			}
Return aParam


