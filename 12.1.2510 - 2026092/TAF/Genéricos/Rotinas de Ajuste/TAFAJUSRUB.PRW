#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFREGRVXML.CH"

Static nFilTam := FWSizeFilial()

/*/{Protheus.doc} TAFREGRVXML
Rotina para regravar o valor original do campo com base no XML que foi transmitido ao TSS;
@type  Function
@author Lucas Passos
@since 23/07/2024
/*/
Function TAFAJUSRUB()

    Local cError as character

    Private __cXmlId      := Space(36)
    Private __cCombo      := ""
    Private __aRelation   := {}
    Private cLog            := ""
    Private cArquivo        := ""
    Private cTempPath       := ""
    Private lLogError       := .F.
    Private oEdit           := Nil
    Private oLog            := Nil

    cError := ""

    If FWIsAdmin( __cUserID )
        MontaTela()
    Else
        cError := STR0024 + cUserName + STR0025 //" O usuário " // " não pertence ao grupo de administradores, entre em contato com o administrador do sistema."
        MsgStop( cError, STR0026 ) //"Usuário sem acesso"
    EndIf
    
Return Nil


/*/{Protheus.doc} MontaTela
    (long_description)
    @type  Static Function
    @author Lucas Passos
    @since 23/07/2024
/*/
Static Function MontaTela()

    Local lExecute      as logical
    Local oStepWiz      as object 
    Local oNewPag       as object 

    lExecute    := .F.
    oStepWiz    := Nil  
    oNewPag     := Nil


    oStepWiz:= FWWizardControl():New()

        
        oStepWiz:SetSize({600, 600})
        oStepWiz:ActiveUISteps()

        oNewPag := oStepWiz:AddStep( "1" )
        oNewPag:SetStepDescription("Introdução a Rotina")
        oNewPag:SetConstruction( { | Panel | TafBVindas( Panel ) } )
        oNewPag:SetCancelAction({||.T.})
        oNewPag:SetNextAction( {||.T.})

        oNewPag := oStepWiz:AddStep("2", {|oPanel| Params(oPanel)})
        oNewPag:SetStepDescription(STR0001) // "Parâmetros"
        oNewPag:SetCancelAction({|| .T.})
        oNewPag:SetNextTitle(STR0002) // "Processar"
        oNewPag:SetNextAction({||Validation()})

        oNewPag := oStepWiz:AddStep("3", {|oPanel| Finish(oPanel), ExecProc(__aRelation)})      
        oNewPag:SetStepDescription(STR0003) // "Processamento"
        oNewPag:SetNextTitle(STR0004) // "Fechar"
        oNewPag:SetNextAction({|| .T.})
        oNewPag:SetCancelWhen({|| .F.})
        oNewPag:SetPrevWhen({|| .F.})

    oStepWiz:Activate()

    oStepWiz:Destroy()

  
Return 

/*/{Protheus.doc} Params
Monta tela de parâmetros

@param oPanel - Objeto FWWizardControl()

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Params(oPanel as object)

    Local aItems as array
    Local oFontC as object
    Local oCombo as object
    
    Default oPanel  := Nil

    oFontC  := Nil
    oCombo  := Nil
    aItems  := {'','S-1010 | Tag codIncIRRF | C8R_CINTIR'}

    oFontC  := TFont():New('Arial',,15,,.F.)

    WizSay(STR0005, oPanel, 015, 10, 4, "#3C769C",, .T., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Informe os parâmetros para o processamento:"

    WizSay(STR0006, oPanel, 040, 10, 3, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Selecione o evento a ser alterado:"
    oCombo := TComboBox():New(60,10,{|u|if(PCount()>0,__cCombo:=u,__cCombo)},aItems,120,30,oPanel,,,,,,.T.,,,,,,,,,)

    WizSay(STR0007, oPanel, 80, 10, 3, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Opcional: Realizar ajuste por XMLID"
    TGet():New(100, 10, {|u| Iif(PCount() == 0, __cXmlId, __cXmlId := PadR(u, 36))}, oPanel, 100, 10,,, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,,,,, .T.) 
    
Return


/*/{Protheus.doc} Validation
Valida parametros informados

@param oPanel - Objeto FWWizardControl()

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Validation()

    Local lContinua as Logical

    lContinua := .F.

    If Empty(__cCombo)
        MsgAlert(STR0009, STR0008) // "Deve ser informado o evento que será alterado" // "Evento Invalido"
        Return .F.

    ElseIf Len(Alltrim(__cXmlId)) != 36 .and. Len(Alltrim(__cXmlId)) != 0
        MsgAlert(STR0011, STR0010) // "A chave XMLID informada deve ter 36 posições" // "XMLID Invalido"
        Return .F.

    EndIf 

    If  "S-1010" $ __cCombo
        Aadd(__aRelation,"1010")
        Aadd(__aRelation,"C8R")
        Aadd(__aRelation,"C8R_CINTIR")
        Aadd(__aRelation,"eSocial/evtTabRubrica/infoRubrica/inclusao/dadosRubrica/codIncIRRF")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))

    EndIf 
    
    lContinua := MsgNoYes(STR0012, STR0003) // "Deseja Continuar?" // "Processamento"

    If !lContinua
        __cXmlId    := ""
        __cCombo    := ""
        __aRelation := {}
    EndIf 

Return  lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} TafBVindas
Boas Vindas da rotina
@Param oPanel - Painel onde serão criados os objetos da tela
*/
Static Function TafBVindas( oPanel as object )

    Local cDescr    as character 
    Local nLin      as numeric
    Local nCol      as numeric
    Local nWidth    as numeric
    Local nHeight   as numeric
    Local oButton   as object
    Local cLink     as character 
    Local bBrower   as codeblock

    Default oPanel:= Nil

    cLink     := "https://tdn.totvs.com/x/wjpPPg"
    bBrower   := {|| }
    oButton   := Nil
    nWidth    := oPanel:NCLIENTWIDTH * 0.47
    nCol      := 10
    nHeight   := 110
    nLin      := 10

    Iif(GetRemoteType() == 2 , bBrower := {|| ShellExecute("Browser", "/usr/bin/firefox", cLink, "/", 1)}, bBrower := {|| ShellExecute("Open", cLink, "", "C:\", 1)} )

    cDescr := 'Bem vindo a rotina de regravar campos do XML !'
    WizSay(cDescr,oPanel,nLin,nCol,5,"#0c9abe",,.T.,.F.,1,nWidth,nHeight)

    nLin +=30
    cDescr := 'O objetivo desta rotina é regravar o conteudo do campo de incidencia de IRRF no evento S-1010 que tenham sido alterado devido uma inconsistência na tabela de Tipos de Incidência - C8U.'
    WizSay(cDescr,oPanel,nLin,nCol,4,"#737373",,.F.,.F.,1,nWidth,nHeight)

    nLin +=40
    cDescr := 'Serão alterados apenas registros que já tenham sido transmitidos e aceito pelo RET, retornando o conteudo original da transmissão. '
    WizSay(cDescr,oPanel,nLin,nCol,4,"#737373",,.F.,.F.,1,nWidth,nHeight)

    nLin +=30

    //nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.68)
    cDescr := 'ATENÇÃO: Para o uso desta funcionalidade o TSS precisa estar ativo.'
    WizSay(cDescr,oPanel,nLin,nCol,3,"#ff0000",,.F.,.F.,1,nWidth,nHeight)

    nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.68)
    oButton := THButton():New(nLin, nCol, STR0013, oPanel, bBrower, nWidth, nHeight,, cLink) // "Clique aqui para acessar a documentação"


Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} Finish
Tela final do wizard

@param oPanel - Objeto FWWizardControl()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0

@author Lucas Passos
@since 31/07/2024
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function Finish(oPanel as object)
    
    Default oPanel  := Nil

    oEdit := TSimpleEditor():New(0.47, 0.47, oPanel, 293, 082,, .T.)
    oEdit:TextBold()
    oEdit:TextColor( CLR_BLACK )
    oEdit:SetWordWrap(.T.)
    oEdit:TextFormat(2)

    TButton():New(091, 125, STR0014, oPanel, {|| ExportLog()}, 50, 10,,, .F., .T., .F.,, .F.,,, .F.) // "Exportar Log"

Return


/*/{Protheus.doc} ExecProc
    Executa processamento da rotina
    @type  Function
    @author Lucas Passos
    @since 24/07/2024
    @version version
    @param aRelation as Array - Array que 
        (aRelation,"2220") -- Evento
        (aRelation,"C8B") -- Alias
        (aRelation,"C8B_NRCRM") -- Campo a ser alterado
        (aRelation,"eSocial/evtMonit/exMedOcup/respMonit/nrCRM") --- Nó do XML
        (aRelation,"")  --- XMLID
/*/
Static Function ExecProc(aRelation as array)
    
    Local cSysObj       as character
    Local cCampo        as character
    Local cNoUPD        as character
    Local lJoin         as logical
    Local cLayoutForm   as character
    Local cLayout       as character
    Local cAliasPai     as character
    Local aJoin         as array
    Local aXmls         as array

    Default aRelation := {}

    lJoin       := .F.
    cSysObj     := ""
    cLayoutForm := ""
    cCampo      := ""
    cNoUPD      := ""
    cX2unic     := ""
    aJoin       := {}
    aXmls       := {}
    cLayout     := aRelation[1]
    cAliasPai   := aRelation[2]
    cCampo      := aRelation[3]
    cNoUPD      := "/" + aRelation[4]
    cAliasFilho := SubStr(aRelation[3],1,3)

    If cAliasPai == cAliasFilho
       aXmls := ExecBusca(aRelation)
    EndIf 

    ExecUPD(aXmls, cCampo, cNoUPD, cAliasPai, cLayout )

Return 


/*/{Protheus.doc} ExecBusca
    Executa a busca dos registros nas tabelas de negocio do TAF
    @type  Static Function
    @author Lucas Passos
    @since 24/07/2024
    @version version
    @param aRelation, aJoin, cX2unic
/*/
Static Function ExecBusca(aRelation as array, aJoin as array, cX2unic as character)

    Local cQry          as character
    Local cQrySelect	as character
    Local cQryJoin	    as character
    Local aXmls         as array
    Local nRecno        as Numeric
    Local nX            as Numeric

    Default aRelation   := {}
    Default aJoin       := {}
    Default cX2unic     := ""

    cQry        := ""
    cQrySelect  := ""
    cQryJoin    := ""
    aXmls       := {}
    nRecno      := 0
    nX          := 0

    If Empty(aJoin)

        cQry += " SELECT R_E_C_N_O_ "
        cQry += " , " + aRelation[2] + "_FILIAL "
        cQry += " , " + aRelation[2] + "_ID "
        cQry += " , " + aRelation[2] + "_VERSAO "
        cQry += " , " + aRelation[2] + "_XMLID "
        cQry += " FROM " + RetSqlName(aRelation[2]) + " "
        cQry += " WHERE  " + aRelation[2] + "_STATUS = '4' "
        cQry +=     " AND " + aRelation[2] + "_PROTUL <> '' "
        If Empty(aRelation[5])
            cQry +=     " AND " + aRelation[2] + "_XMLID <> ''  "
        Else
            cQry +=     " AND " + aRelation[2] + "_XMLID = '" + aRelation[5] + "' "
        EndIf 
        cQry +=     " AND " + aRelation[2] + "_ATIVO =  '1' "
        cQry +=     " AND D_E_L_E_T_ = '' "

    EndIf 

    aXmls := BuscaTSS(cQry, aRelation, aJoin, cX2unic)

Return aXmls


/*/{Protheus.doc} BuscaTSS
    Busca XML que foi enviado ao Governo
    @type  Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param cQry, aRelation, aJoin, cX2unic
    /*/
Static Function BuscaTSS(cQry as character, aRelation as array , aJoin as array , cX2unic as character)

    Local cAlias        as character
    Local cTSSKey       as character
    Local cKeyTaf       as character
    Local aXmls         as array
    Local aXmlTss       as array
    Local aRet          as array
    Local nRecno        as Numeric
    Local nX            as Numeric
    Local nY            as Numeric
    Local aRetTotal     as array
    Local nBlockSize    as Numeric
    Local nTotalSize    as Numeric
    Local nStart        as Numeric
    Local nZ            as Numeric
    Local oStatement    as Object
    Local aSubArray     as array

    Default cQry        := ""
    Default aRelation   := {}
    Default aJoin       := {}
    Default cX2unic     := ""
    Default cJoin       := ""

    oStatement  := FWPreparedStatement():New( ChangeQuery(cQry) )
    cQry        := oStatement:getFixQuery()
    nRecno      := 0
    nX          := 0
    nY          := 0
    aXmlTss     := {}
    aRet        := {}
    aXmls       := {}
    cKeyTaf     := ""
    aRetTotal   := {}
    nBlockSize  := 50
    nTotalSize  := 0
    nStart      := 0
    nZ          := 0

    cAlias := MPSysOpenQuery(cQry)

    ( cAlias )->( DBGoTop() )

    While ( cAlias )->( !Eof() )
        cTSSKey := "S" + aRelation[1] + AllTrim( (cAlias)->&(aRelation[2] +"_ID") ) + AllTrim( (cAlias)->&(aRelation[2] +"_VERSAO") )
        cKeyTaf := PadR((cAlias)->&(aRelation[2] +"_FILIAL"),nFilTam) + AllTrim( (cAlias)->&(aRelation[2] +"_ID") ) + AllTrim( (cAlias)->&(aRelation[2] +"_VERSAO") )
        nRecno  := (cAlias)->&("R_E_C_N_O_")
        cXmlId  := (cAlias)->&(aRelation[2] +"_XMLID")

        //Array completo para o UPD
        aAdd( aXmls, {cTSSKey, cKeyTaf, nRecno, cXmlId, cX2unic })

        ///Array de busca do TSS
        aAdd( aXmlTss, cTSSKey )

        ( cAlias)->( DBSkip() )

    EndDo

    (cAlias)->(DbCloseArea())

    nTotalSize := Len(aXmlTss)

    // Loop para percorrer o array original em blocos de 50 devido a limitação do TSS em requisições
    For nStart := 1 To nTotalSize Step nBlockSize
        // Extrai um subarray de 50 elementos (ou menos na última iteração)
        aSubArray := GetSubArray(aXmlTss, nStart, nBlockSize)
        
        aRet := TAFGETXMLTSS(aSubArray)
        
        for nZ :=1 to Len(aRet)
            Aadd(aRetTotal, aRet[nZ])
        Next 
    Next

    for nX := 1 to Len(aXmlTss)
        If Len(aRetTotal) > 0 .and. aRetTotal[nX][1]
            If aRetTotal[nX][2] == aXmls[nX][1]
                aAdd( aXmls[nX], aRetTotal[nX][3])
            End
        EndIf 
    next

Return aXmls


/*/{Protheus.doc} GetSubArray
    // Função auxiliar para extrair subarrays
    @type  Static Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param aArray, nStart, nSize
/*/
Static Function GetSubArray(aArray as array, nStart as numeric, nSize as numeric)
    Local aSubArray as array
    Local nI        as numeric

    Default aArray  := {}
    Default nStart  := 0
    Default nSize   := 0

    aSubArray       := {}
    nI              := 0

    For nI := nStart To Min(nStart + nSize - 1, Len(aArray))
        aAdd(aSubArray, aArray[nI])
    Next nI

Return aSubArray


/*/{Protheus.doc} ExecUPD
    Executa a alteração com base no XML retornado do TSS
    @type  Static Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param aXmls, cCampo, cNoUPD, cAliasPai, cLayout
    @see (links_or_references)
/*/
Static Function ExecUPD(aXmls as array, cCampo as character, cNoUPD as character, cAliasPai as character, cLayout as character)

    Local nX            as Numeric
    Local oDados        as object
    Local cCodEvent     as character
    Local cValorTag     as character
    Local cXml          as character
    Local cAliasFilho   as character
    Local cTimeIni      as character
    Local cTimeFim      as character
    Local cLog1         as character
    Local aChave        as array 
    
       

    Default aXmls       := {}
    Default cCampo      := ""
    Default cNoUPD      := ""
    Default cAliasPai   := ""
    Default cLayout     := ""

    cCodEvent   := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
    cValorTag   := ""
    aChave      := {}
    cXml        := ""
    cAliasFilho := Substr(cCampo,1,3)
    cTimeIni    := Time()
    cTimeFim    := ""
    cLog1       := ""

    (cAliasPai)->(DbSetOrder(1))
    (cAliasFilho)->(DbSetOrder(1))

    If !CreateLog()

        cLog1 := STR0015 + CRLF // "Iniciando Processamento..."
        cLog1 += STR0016  + DToC(Date()) + " Hora: " + cTimeIni + CRLF // "Data: " // " Hora: "
        cLog1 += STR0018 + cUserName + CRLF + CRLF // "Usuário: "
        cLog  += cLog1

        for nX := 1 to Len(aXmls)

            cLog1 += "Registro " + cValToChar(nX) + " de " + cValToChar(Len(aXmls)) + " - "

            oDados := TXMLManager():New()

            If Len(aXmls[nX]) < 6
                cLog1 +=  "XMLID: " + aXmls[nX][4] + " Não encontrado no TSS" + CRLF
            Else
                cXml := FTrocaPath(SubStr(FTrocaPath( aXmls[nX][6] ), 3),"eSocial")
            EndIf 

            if !oDados:Parse( cXml)
                conout( "Errors on Parse!" )
                Loop 
            endif
            
            If TafXNode(oDados , cCodEvent, , cNoUPD)
                cValorTag := oDados:XPathGetNodeValue(cNoUPD)
                cValorTag := Posicione( "C8U", 2 , xFilial("C8U") + cValorTag + PadR('', 8), "C8U_ID")
            EndIf

            (cAliasPai)->(DbGoTo(aXmls[nX][3]))

            If (cAliasPai)->(MsSeek(aXmls[nX][2]))

                If cValorTag == AllTrim((cAliasPai)->&(cCampo))
                    cLog1 +=  "XMLID: " + aXmls[nX][4] + " Não precisou de alteração" + CRLF

                Else
                    RecLock(cAliasPai, .F. )
                    (cAliasPai)->&(cCampo) := cValorTag
                    (cAliasPai)->(MsUnlock())
                    cLog1 +=  "XMLID: " + aXmls[nX][4] + " Alterado com sucesso" + CRLF
                EndIf
            EndIf

        
            oEdit:Load(cLog1)
        next

        cTimeFim    := Time()
        cLog1       += STR0019 + CRLF // "Processamento concluído com sucesso!"
        cLog1       += STR0016 + DToC(Date()) + STR0017 + cTimeFim + CRLF + CRLF // "Data: " // " Hora: "
        cLog1       += STR0020 + ElapTime(cTimeIni, cTimeFim) // "Tempo de processamento: "
        cLog        += cLog1

        oEdit:Load(cLog)
        oLog:Write(cLog1)
        oLog:Close()

    EndIf 

    (cAliasFilho)->(DbCloseArea())
    (cAliasPai)->(DbCloseArea())
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Cria arquivo de log

@return lLogError - Informa se houve erro na geração do Log 
@author Melkz Siqueira
@since 29/10/2021
@version 1.0

@author Lucas Passos
@since 31/07/2024
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function CreateLog()

    cTempPath   := GetTempPath(.T.)
    cArquivo    := "regravaxml" + DToS(Date()) + StrTran(Time(), ":") + ".log"
    oLog        := FWFileWriter():New(cTempPath + cArquivo, .T.)

    If !oLog:Create()
        MsgStop(STR0022  + CRLF + oLog:Error():Message, STR0021) // "Falha ao gerar o arquivo de Log: " // "Atenção!"
        lLogError := .T.
    EndIf

Return lLogError

//-------------------------------------------------------------------
/*/{Protheus.doc} ExportLog
Exporta arquivo de log

@author Melkz Siqueira
@since 29/10/2021
@version 1.0

@author Lucas Passos
@since 31/07/2024
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function ExportLog()
    
    Local cDirIni   := ""
    Local cDiretor  := ""

    If lLogError
        MsgStop(STR0022 + CRLF + oLog:Error():Message, STR0021) // "Falha ao gerar o arquivo de Log: " // "Atenção!"
        Return
    EndIf

    cDirIni   := Iif(GetRemoteType() == 2, "/", "C:\")
    cDiretor  := cGetFile(STR0023+ "|*.*", STR0014,, cDirIni, .T., 176, .T., .T.) // "Todos os arquivos" // "Exportar Log"

    __CopyFile(cTempPath + cArquivo, cDiretor + cArquivo)

Return
