#include 'PROTHEUS.CH'
#include 'FINA476.CH'

Static __oSmartLk := Nil
/*/{Protheus.doc} FINA476
    Função para o job do SmartLink de Retorno (Recebimento / Conciliação) conta digital   
    @type  Function
    @author Luiz Gustavo R. Jesus
    @since 01/11/2023    
    @param aParam, Array, vetor com as informações para execução da função via Schedule.
    @param lAutomato, Logical, variavel para verificar se a chamada esta sendo feita pela automação.
/*/
Function FINA476( aParam As Array, lAutomato As Logical )                
    Local cLock As Character
    Local cData As Character
    Local cHora As Character
    
    Default aParam    := {}
    Default lAutomato := .F.

    cData := DToC( Date() )
    cHora := Time()
    cLock := "FINA476"

    If Len(aParam) > 0
        RpcSetType(3) //Não consome licenças.
        RpcSetEnv( aParam[1], aParam[2] )
        //Trava para somente um processamento por empresa
        If LockByName( cLock, .T., .F. ) 
            If AliasInDic("SIG")        
                DbSelectArea("SIG")	
                If SIG->(ColumnPos( "IG_STATUCD")) > 0 .and. SIG->(ColumnPos( "IG_IDCD")) > 0 .and. SIG->(ColumnPos( "IG_CODBAR")) > 0 .and. SIG->(ColumnPos( "IG_IDTPIX")) > 0
                    LogMsg( cLock, 23, 6, 1, "", "", I18N( STR0001, {cLock, aParam[1], aParam[2], cData, cHora} )) // "******Iniciado #1 Empresa: #2 Filial: #3 as #4 #5******"
                    If FindFunction("F475Concil")
                        ProConcil()
                    EndIf
                    ProFina476()
                    LogMsg( cLock, 23, 6, 1, "", "", I18N( STR0002, {cLock, aParam[1], aParam[2], cData, cHora} )) // "******Finalizado #1 Empresa: #2 Filial: #3 iniciado as #4 #5******"
                EndIf
            EndIf
            UnLockByName( cLock, .T., .F. )
        Else
            LogMsg( cLock, 23, 6, 1, "", "", STR0003) //"******Ja existe uma execucao da rotina FINA476 em andamento******"            
        EndIf
        If !lAutomato
            RpcClearEnv()
        EndIf
    EndIf
    FwFreeArray(aParam)
Return 

/*/{Protheus.doc} ProConcil()
    Função para efetuar a consulta do status dos registros da SIG para a conciliação
    @type Function
    @author Luiz Gustavo R. Jesus
    @since 26/01/2024
/*/
Static Function ProConcil()
    Local aArea      As Array    
    Local aConcil    As Array
	Local cQuery 	 As Character
 	Local cNextAlias As Character
    Local nCount     As Numeric
    Local nLimit     As Numeric
    Local oQryCon    As Object
    Local cChave     As Character
    Local cBanco     As Character
    Local cAgencia   As Character
    Local cConta     As Character

    aArea      := GetArea()     
    aConcil    := {}
    cNextAlias := GetNextAlias()
    cChave     := ""
    cBanco     := ""
    cAgencia   := ""
    cConta     := ""
    nCount     := 1
    nLimit     := 100

	cQuery := "SELECT  "    
    cQuery += "     SIG.IG_FILIAL, "
    cQuery += "     SIG.IG_BCOEXT, "   
    cQuery += "     SIG.IG_AGEEXT, "    
    cQuery += "     SIG.IG_CONEXT, "    
    cQuery += "     SIG.IG_IDPROC  "    
	cQuery += " FROM ? SIG "
	cQuery += " WHERE "
	cQuery += "     SIG.IG_FILIAL = ? AND "
    cQuery += "     SIG.IG_IDCD <> ' ' AND "
    cQuery += "		SIG.IG_STATUS <> '3' AND "
	cQuery += "     SIG.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY SIG.IG_FILIAL, SIG.IG_BCOEXT, SIG.IG_AGEEXT, SIG.IG_CONEXT, SIG.IG_IDPROC "
	cQuery += " ORDER BY SIG.IG_FILIAL, SIG.IG_BCOEXT, SIG.IG_AGEEXT, SIG.IG_CONEXT "
    
    cQuery := ChangeQuery(cQuery)
    oQryCon := FWPreparedStatement():New(cQuery)
    oQryCon:SetUnsafe(1,RetSqlName("SIG"))
    oQryCon:SetString(2,xFilial("SIG"))	

    cQuery := oQryCon:GetFixQuery()		
	cNextAlias := MPSysOpenQuery( cQuery )

    (cNextAlias)->(DBGoTop())
    While (cNextAlias)->(!Eof())
        cChave   := (cNextAlias)->IG_FILIAL + (cNextAlias)->IG_BCOEXT + (cNextAlias)->IG_AGEEXT + (cNextAlias)->IG_CONEXT
        cBanco   := (cNextAlias)->IG_BCOEXT
        cAgencia := (cNextAlias)->IG_AGEEXT
        cConta   := (cNextAlias)->IG_CONEXT
        aConcil  := {}
        nCount   := 1

        While (cNextAlias)->(!Eof()) .And. (cNextAlias)->IG_FILIAL + (cNextAlias)->IG_BCOEXT + (cNextAlias)->IG_AGEEXT + (cNextAlias)->IG_CONEXT == cChave .And. nCount <= nLimit
            nCount++
            aAdd(aConcil, (cNextAlias)->IG_IDPROC)
            (cNextAlias)->(dbSkip())
        EndDo

        F475Concil("2", cBanco, cAgencia, cConta, aConcil)
    EndDo
    (cNextAlias)->(dbCloseArea())
    RestArea(aArea)
    FwFreeArray(aArea)
    FwFreeArray(aConcil)
    FwFreeObj(oQryCon)
Return

/*/{Protheus.doc} ProFina476()
    Função para efetuar a consulta do status dos registros da SIG
    e enviar o Status para a Conta Digital
    @type Function
    @author Luiz Gustavo R. Jesus
    @since 01/11/2023    
/*/
Static Function ProFina476()
	Local cQuery 	 As Character
 	Local cNextAlias As Character
    Local oGetQry    As Object

	cQuery := "SELECT SIG.IG_FILIAL, SIG.IG_IDPROC, SIG.IG_ITEM "
	cQuery += "FROM ? SIG "
	cQuery += "WHERE "
	cQuery += "SIG.IG_FILIAL = ? AND SIG.IG_IDCD <> ' ' AND "
    cQuery += "( ( SIG.IG_STATUS = ? AND SIG.IG_STATUCD > ? ) OR ( SIG.IG_STATUS > ? AND SIG.IG_STATUCD <> ? ) ) AND "
	cQuery += "SIG.D_E_L_E_T_ = ' ' "
    
    cQuery  := ChangeQuery( cQuery )
    oGetQry := FWPreparedStatement():New( cQuery )
    oGetQry:SetUnsafe( 1, RetSqlName( "SIG" ) )
    oGetQry:SetString( 2, xFilial( "SIG" ) )
    oGetQry:SetString( 3, "1" )
    oGetQry:SetString( 4, "1" )
    oGetQry:SetString( 5, "1" )
    oGetQry:SetString( 6, "3" )

	cNextAlias := MPSysOpenQuery( oGetQry:GetFixQuery() )
    (cNextAlias)->( DbGoTop() )

    While (cNextAlias)->(!Eof())
        F476Send( (cNextAlias)->IG_FILIAL, (cNextAlias)->IG_IDPROC, (cNextAlias)->IG_ITEM )
		(cNextAlias)->( DbSkip() )
	EndDo

	(cNextAlias)->( DbCloseArea() )
    FwFreeObj(oGetQry)

Return

/*/{Protheus.doc} F476Send
    Função para a montagem da mensagem do json para o envio FwTotvsLinkClient
    @type Function    
    @author Luiz Gustavo R. Jesus
    @param cFilialSIG, Character, Filial da tabela SIG (IG_FILIAL)
    @param cIdProcSIG, Character, ID do processamento (IG_IDPROC)
    @param cItemSIG  , Character, Item do processamento (IG_ITEM)
    @since 03/11/2023
/*/
Function F476Send( cFilialSIG As Character, cIdProcSIG As Character, cItemSIG As Character )
    Local aAreaSIG  As Array
    Local aArea     As Array
    Local cMessage  As Character
    Local cIdCD     As Character
    Local cTenantId As Character
    Local cType     As Character
    Local cAudience As Character
    Local cStatuCD  As Character
    Local cStatus   As Character
    Local cDescript As Character

    aAreaSIG  := SIG->( GetArea() )
    aArea     := GetArea()
    cMessage  := ""
    cIdCD     := ""
    cType     := "ReconciliationStatusMessage"
    cAudience := "techfin-conta-digital"
    cStatuCD  := ""
    cStatus   := ""
    cDescript := ""
	SIG->( Dbsetorder(1) ) // IG_FILIAL + IG_IDPROC + IG_ITEM

    If SIG->( MsSeek( cFilialSIG + cIdProcSIG + cItemSIG ) )

        If __oSmartLk == Nil
            __oSmartLk := FwTotvsLinkClient():New()    
        EndIf

        cTenantId  := __oSmartLk:GetTenantClient()
        cIdCD      := SIG->IG_IDCD
        If SIG->IG_STATUS == "1"
            cDescript := "Recebido"
            cStatus   := "2"
            cStatuCD  := "1"
        ElseIf SIG->IG_STATUS $ "2|3"
            cDescript := "Conciliado"
            cStatus   := "3"
            cStatuCD  := "3"
        EndIf

        BeginContent Var cMessage
        {
            "id": "%Exp:cIdCD%",
            "tenantId": "%Exp:cTenantId%",
            "status": "%Exp:cStatus%",            
            "statusDescription": "%Exp:cDescript%"
        }
        EndContent

        If !__oSmartLk:SendAudience( cType, cAudience, EncodeUTF8( cMessage ) )
            If SIG->IG_STATUS == "1"
                cStatuCD := "2"
            ElseIf SIG->IG_STATUS $ "2|3"
                cStatuCD := "4"
            EndIf
            LogMsg( "FINA476", 23, 6, 1, "", "", I18N( STR0004, { cIdCD } ) ) // "******Erro no envio do registro id: #1 para a conta digital******"            
        EndIf

        RecLock( "SIG", .F. )
            SIG->IG_STATUCD	:= cStatuCD
        SIG->( MsUnLock() )
    EndIf

    RestArea(aAreaSIG)
    RestArea(aArea)

    FwFreeArray(aAreaSIG)
    FwFreeArray(aArea)

Return
