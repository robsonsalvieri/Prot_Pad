#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFREGRVXML.CH"

Static nFilTam := FWSizeFilial()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFREGRVXML
Rotina para regravar o valor original do campo com base no XML que foi transmitido ao TSS;
@type  Function
@author Lucas Passos
@since 23/07/2024
/*/
//-------------------------------------------------------------------
Function TAFREGRVXML()

    Local cError as character

    Private __aRelation := {}
    Private __cCombo    := ""
    Private __cXmlId    := Space(36)
    Private cArquivo    := ""
    Private cLog        := ""
    Private cTempPath   := ""
    Private lLogError   := .F.
    Private nTamTpDep   := TamSX3( "V8S_TPDEP" )[1]
    Private oEdit       := Nil
    Private oLog        := Nil

    cError := ""

    If FWIsAdmin( __cUserID )

        MontaTela()

    Else

        cError := STR0024 + cUserName + STR0025 //" O usuário " // " não pertence ao grupo de administradores, entre em contato com o administrador do sistema."
        MsgStop( cError, STR0026 ) //"Usuário sem acesso"

    EndIf
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTela
    (long_description)
    @type  Static Function
    @author Lucas Passos
    @since 23/07/2024
/*/
//-------------------------------------------------------------------
Static Function MontaTela()

    Local lExecute as logical
    Local oNewPag  as object
    Local oStepWiz as object

    lExecute := .F.
    oNewPag  := Nil
    oStepWiz := Nil

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

//-------------------------------------------------------------------
/*/{Protheus.doc} Params
Monta tela de parâmetros

@param oPanel - Objeto FWWizardControl()

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Params(oPanel as object)

    Local aItems as array
    Local oCombo as object
    Local oFontC as object
    
    Default oPanel  := Nil

    oFontC  := Nil
    oCombo  := Nil

    /*
    aItems  := {'',;
    	        'S-1200 | Tag nrDoc         | C9M_NRDOC',;
                'S-1202 | Tag nrDoc         | T6E_NRDOC',;
                'S-1207 | Tag nrDoc         | T6O_NRDOC',;
                'S-2220 | Tag nrCRM         | C8B_NRCRM',;
                'S-2299 | Tag nrDoc         | T05_NRDOC',;
                'S-2399 | Tag nrDoc         | CMK_NRDOC',;
                'S-2501 | Tag tpDep         | V8S_TPDEP',;
                'S-5003 | Tag nrContrato    | V5X_NRCON'}
    */
    aItems  := {'',;
    	        'S-1200 | Tag nrDoc         | C9M_NRDOC',;
                'S-2220 | Tag nrCRM         | C8B_NRCRM',;
                'S-2501 | Tag tpDep         | V8S_TPDEP'}

    oFontC  := TFont():New('Arial',,15,,.F.)

    WizSay(STR0005, oPanel, 015, 10, 4, "#3C769C",, .T., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Informe os parâmetros para o processamento:"

    WizSay(STR0006, oPanel, 040, 10, 3, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Selecione o evento a ser alterado:"
    oCombo := TComboBox():New(60,10,{|u|if(PCount()>0,__cCombo:=u,__cCombo)},aItems,120,30,oPanel,,,,,,.T.,,,,,,,,,)

    WizSay(STR0007, oPanel, 80, 10, 3, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Opcional: Realizar ajuste por XMLID"
    TGet():New(100, 10, {|u| Iif(PCount() == 0, __cXmlId, __cXmlId := PadR(u, 36))}, oPanel, 100, 10,,, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,,,,, .T.) 
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Validation
Valida parametros informados

@param oPanel - Objeto FWWizardControl()

__aRelation Array com 6 posições, a sexta é a tag que precisa ser pesquisa para
pode restaurar o valor, quando a tag for elemento na documentação do layout
tem que ser colocar desta forma "</tag>", quando a tag for atributo, deve ser 
informador somente a tag ("tag").

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

    If "S-2220" $ __cCombo 

        Aadd(__aRelation,"2220")
        Aadd(__aRelation,"C8B")
        Aadd(__aRelation,"C8B_NRCRM")
        Aadd(__aRelation,"eSocial/evtMonit/exMedOcup/respMonit/nrCRM")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrCRM>")

    ElseIf "S-2501" $ __cCombo 

        Aadd(__aRelation,"2501")
        Aadd(__aRelation,"V7C")
        Aadd(__aRelation,"V8S_TPDEP")
        Aadd(__aRelation,"eSocial/evtContProc/ideTrab/infoIRComplem[@]/infoDep[@]/tpDep")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"tpDep")

    ElseIf "S-1200" $ __cCombo 

        Aadd(__aRelation,"1200")
        Aadd(__aRelation,"C91")
        Aadd(__aRelation,"C9M_NRDOC")
        Aadd(__aRelation,"eSocial/evtRemun/dmDev[@]/infoPerApur/ideEstabLot[@]/remunPerApur[@]/itensRemun[@]/descFolha/nrDoc")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrDoc>")
    /*
    ElseIf "S-1202" $ __cCombo 

        Aadd(__aRelation,"1202")
        Aadd(__aRelation,"C91")
        Aadd(__aRelation,"T6E_NRDOC")
        Aadd(__aRelation,"eSocial/evtRmnRPPS/dmDev[@]/infoPerApur/ideEstab[@]/remunPerApur[@]/itensRemun[@]/descFolha/nrDoc")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrDoc>")

    ElseIf "S-1207" $ __cCombo 

        Aadd(__aRelation,"1207")
        Aadd(__aRelation,"T62")
        Aadd(__aRelation,"T6O_NRDOC")
        Aadd(__aRelation,"eSocial/evtBenPrRP/dmDev[@]/infoPerApur/ideEstab[@]/itensRemun[@]/descFolha/nrDoc")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrDoc>")

    ElseIf "S-2299" $ __cCombo 

        Aadd(__aRelation,"2299")
        Aadd(__aRelation,"CMD")
        Aadd(__aRelation,"T05_NRDOC")
        Aadd(__aRelation,"eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[@]/infoPerApur/ideEstabLot[@]/detVerbas[@]/descFolha/nrDoc")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrDoc>")

    ElseIf "S-2399" $ __cCombo 

        Aadd(__aRelation,"2399")
        Aadd(__aRelation,"T92")
        Aadd(__aRelation,"CMK_NRDOC")
        Aadd(__aRelation,"eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[@]/ideEstabLot[@]/detVerbas[@]/descFolha/nrDoc")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrDoc>")

    ElseIf "S-5003" $ __cCombo 

        Aadd(__aRelation,"5003")
        Aadd(__aRelation,"V2P")
        Aadd(__aRelation,"V5X_NRCON")
        Aadd(__aRelation,"eSocial/evtBasesFGTS/infoFGTS/ideEstab[@]/ideLotacao[@]/infoTrabFGTS[@]/eConsignado[@]/nrContrato")
        Iif(Empty(AllTrim(__cXmlId)),Aadd(__aRelation,""),Aadd(__aRelation,__cXmlId))
        Aadd(__aRelation,"</nrContrato>")
    */
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
//-------------------------------------------------------------------
Static Function TafBVindas( oPanel as object )

    Local bBrower as block
    Local cDescr  as character
    Local cLink   as character
    Local nCol    as numeric
    Local nHeight as numeric
    Local nLin    as numeric
    Local nWidth  as numeric
    Local oButton as object

    bBrower := {|| }
    cLink   := "https://tdn.totvs.com/x/gFRGMw"
    nCol    := 10
    nHeight := 110
    nLin    := 10
    nWidth  := oPanel:NCLIENTWIDTH * 0.47
    oButton := Nil

    Iif(GetRemoteType() == 2 , bBrower := {|| ShellExecute("Browser", "/usr/bin/firefox", cLink, "/", 1)}, bBrower := {|| ShellExecute("Open", cLink, "", "C:\", 1)} )

    cDescr := 'Bem vindo a rotina de regravar campos do XML !'
    WizSay(cDescr,oPanel,nLin,nCol,5,"#0c9abe",,.T.,.F.,1,nWidth,nHeight)

    nLin +=30
    cDescr := 'O objetivo desta rotina é regravar o conteudo de campos que tenham sido alterados na migração de release devido a mudança no tamanho de campo.'
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

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecProc
    Executa processamento da rotina
    @type  Function
    @author Lucas Passos
    @since 24/07/2024
    @version version
    @param aRelation as Array - Array que 
        (aRelation,"2220")                                       --- Evento
        (aRelation,"C8B")                                        --- Alias
        (aRelation,"C8B_NRCRM")                                  --- Campo a ser alterado
        (aRelation,"eSocial/evtMonit/exMedOcup/respMonit/nrCRM") --- Nó do XML
        (aRelation,"")                                           --- XMLID
        (aRelation,"")                                           --- tag a ser pesquisada (atributo -> "tag", elemento -> "</tag>" )
/*/
//-------------------------------------------------------------------
Static Function ExecProc(aRelation as array)
    
    Local aJoinFilho    as array
    Local aJoinPai      as array
    Local aJoinTables   as array
    Local aXmls         as array
    Local cAliasFilho   as character
    Local cAliasPai     as character
    Local cCampo        as character
    Local cLayout       as character
    Local cLayoutForm   as character
    Local cNoUPD        as character
    Local cSysObj       as character
    Local cTag          as character
    Local cX2unic       as character
    Local lJoin         as logical
    Local nB            as numeric
    Local oModel        as Object
    Local oModelGeneric as Object

    Default aRelation := {}

    aJoinFilho  := {}
    aJoinPai    := {}
    aJoinTables := {}
    aXmls       := {}
    cAliasFilho := SubStr(aRelation[3],1,3)
    cAliasPai   := aRelation[2]
    cCampo      := aRelation[3]
    cLayout     := aRelation[1]
    cLayoutForm := ""
    cNoUPD      := "/" + aRelation[4]
    cSysObj     := ""
    cTag        := aRelation[6]
    cX2unic     := ""
    lJoin       := .F.

    If cAliasPai == cAliasFilho

       aXmls := ExecBusca(aRelation)

    Else

        cSysObj := FwSX2Util():GetX2SysObj(cAliasFilho)

        oModel          := FWLoadModel(cSysObj)
        oModelGeneric   := oModel:GetRelation( 'MODEL_'+ SubStr(aRelation[3],1,3) )[1]

        For nB := 2 To len(oModelGeneric)

            If AScan( aJoinTables, Substr(oModelGeneric[nB][2], 1, 3 ) ) == 0

                Aadd( aJoinTables, Substr(oModelGeneric[nB][2], 1, 3 ) )

            EndIf

            Aadd( aJoinFilho, oModelGeneric[nB][1] )
            Aadd( aJoinPai  , oModelGeneric[nB][2] )

        Next

        cX2unic := Alltrim(FwSX2Util():GetSX2data(cAliasFilho, {"X2_UNICO"})[1][2])

        aXmls := ExecBusca( aRelation, aJoinPai, cX2unic, aJoinFilho, cAliasFilho, aJoinTables, cCampo )

    EndIf 

    ExecUPD( aXmls, cCampo, cNoUPD, cAliasPai, cLayout, cTag )

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecBusca
    Executa a busca dos registros nas tabelas de negocio do TAF
    @type  Static Function
    @author Lucas Passos
    @since 24/07/2024
    @version version
    @param aRelation   - array com dados do evento que precisa ser atualizado
           aJoinPai    - array com os campos da tabela pai do relacionamento entre as tabelas 
           cX2unic     - x2_unico da tabela que precisa ser atualizada
           aJoinFilho  - array com os campos da tabela filho do relacionamento entre as tabelas 
           cAliasFilho - alias da tabela filho
           aJoinTables - arrays com todas as tabelas do relacionamento entre as tabelas
           cCampo      - campo a ser atualizado pela rotina
/*/
//-------------------------------------------------------------------
Static Function ExecBusca( aRelation as array, aJoinPai as array, cX2unic as character, aJoinFilho as array, cAliasFilho as character,;
                           aJoinTables as array, cCampo as character )

    Local aCampos    as array
    Local aTafRot    as array
    Local aXmls      as array
    Local cQry       as character
    Local cQryJoin   as character
    Local cQrySelect as character
    Local nRecno     as Numeric
    Local nX         as Numeric
    Local nY         as Numeric

    Default aJoinFilho  := {}
    Default aJoinPai    := {}
    Default aJoinTables := {}
    Default aRelation   := {}
    Default cAliasFilho := ""
    Default cX2unic     := ""
    Default cCampo      := ""

    aCampos    := StrTokArr( cX2unic, "+" )
    aTafRot    := TAFRotinas( aRelation[2], 3, .F., 2 )
    aXmls      := {}
    cQry       := ""
    cQryJoin   := ""
    cQrySelect := ""
    nRecno     := 0
    nX         := 0
    nY         := 0

    If Empty(aJoinPai) .And. Empty(aJoinFilho)

        cQry += " SELECT R_E_C_N_O_ "
        cQry += " , " + aRelation[2] + "_FILIAL "
        cQry += " , " + aRelation[2] + "_ID "
        cQry += " , " + aRelation[2] + "_VERSAO "

        If !aTafRot[4] $ ( "S-5001|S-5002|S-5503|S-5011|S-5012|S-5013|S-5501|S-5503|" )
            cQry += " , " + aRelation[2] + "_XMLID "
        EndIf

        cQry += " FROM " + RetSqlName(aRelation[2]) + " "
        cQry += " WHERE  " + aRelation[2] + "_STATUS = '4' "
        cQry +=     " AND " + aRelation[2] + "_PROTUL <> '' "

        If !aTafRot[4] $ ( "S-5001|S-5002|S-5503|S-5011|S-5012|S-5013|S-5501|S-5503|" )

            If Empty(aRelation[5])
                cQry +=     " AND " + aRelation[2] + "_XMLID <> ''  "
            Else
                cQry +=     " AND " + aRelation[2] + "_XMLID = '" + aRelation[5] + "' "
            EndIf 

        EndIf 

        cQry +=     " AND " + aRelation[2] + "_ATIVO =  '1' "
        cQry +=     " AND D_E_L_E_T_ = '' "

    Else

        For nX := 1 To Len( aJoinTables )

            cQryJoin += "INNER JOIN " + RetSqlName(aJoinTables[nX]) + " " + aJoinTables[nX]
            cQryJoin += " ON " + aJoinTables[nX] + "_FILIAL = " + Substr(aJoinFilho[1],1 ,3 ) + "_FILIAL" 

            For nY := 1 To Len(aJoinPai)

                If aJoinTables[nX] == Substr( aJoinPai[nY], 1, 3 )

                    cQryJoin += " AND " + aJoinPai[nY] + " = " + aJoinFilho[nY] + " "

                EndIf

            Next

        Next

        For nX := 4 To Len( aCampos )

            cQrySelect += " , " + aCampos[nX] + " "

        Next

        cQry += " SELECT DISTINCT "
        cQry += " " + aRelation[2] + ".R_E_C_N_O_ "
        cQry += " , " + aRelation[2] + "_FILIAL "
        cQry += " , " + aRelation[2] + "_ID "
        cQry += " , " + aRelation[2] + "_VERSAO "

        If !aTafRot[4] $ ( "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|S-5501|S-5503|" )
            cQry += " , " + aRelation[2] + "_XMLID "
        EndIf

        If Substr( aRelation[3], 1, 3 ) <> aRelation[2]
            cQry += " , " + Substr( aRelation[3], 1, 3 ) + ".R_E_C_N_O_ AS RECNO_FILHO "
        EndIf

        If !Empty(cQrySelect)
            cQry += cQrySelect
        EndIf 

        cQry += " FROM " + RetSqlName(cAliasFilho) + " " + cAliasFilho + " "

        If !Empty(cQryJoin)
            cQry += cQryJoin
        EndIf

        If !aTafRot[4] $ ( "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|S-5501|S-5503|" )

            If Empty(aRelation[5])
                cQry +=     " WHERE " + aRelation[2] + "_XMLID <> ''  "
            Else
                cQry +=     " WHERE " + aRelation[2] + "_XMLID = '" + aRelation[5] + "' "
            EndIf 

        EndIf  

        cQry +=     " AND " + aRelation[2] + "_ATIVO =  '1' "
        cQry +=     " AND " + aRelation[2] + ".D_E_L_E_T_ = '' "
        cQry +=     " AND " + cCampo + " <> '' "

    EndIf 

    aXmls := BuscaTSS(cQry, aRelation, aCampos, cX2unic, aTafRot)

Return aXmls

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaTSS
    Busca XML que foi enviado ao Governo
    @type  Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param cQry       - query que será executada para identificar quais registros precisam ser atualizados
           aRelation  - array com dados do evento que precisa ser atualizado
           aCampos    - campos que compõem o x2_unico da tabela que precisa ser atualizada
           cX2unic    - x2_unico da tabela que precisa ser atualizada
           aTafRot    - arrays com os dados do tafrotinas
/*/
//-------------------------------------------------------------------
Function BuscaTSS(cQry as character, aRelation as array , aCampos as array , cX2unic as character, aTafRot as array )

    Local aRet       as array
    Local aRetTotal  as array
    Local aXmls      as array
    Local aXmlTss    as array
    Local cAlias     as character
    Local cKeyTaf    as character
    Local cTSSKey    as character
    Local cXmlId     as character
    Local nBlockSize as Numeric
    Local nRecFilho  as numeric
    Local nRecno     as Numeric
    Local nStart     as Numeric
    Local nTotalSize as Numeric
    Local nX         as Numeric
    Local nY         as Numeric
    Local nZ         as Numeric

    Default aJoin     := {}
    Default aRelation := {}
    Default aTafRot   := {}
    Default cJoin     := ""
    Default cQry      := ""
    Default cX2unic   := ""

    aRet       := {}
    aRetTotal  := {}
    aXmls      := {}
    aXmlTss    := {}
    cKeyTaf    := ""
    cXmlId     := ""
    nBlockSize := 50
    nRecFilho  := 0
    nRecno     := 0
    nStart     := 0
    nTotalSize := 0
    nX         := 0
    nY         := 0
    nZ         := 0

    oStatement := FWPreparedStatement():New(ChangeQuery(cQry) )
    cQry       := oStatement:getFixQuery()
    cAlias     := MPSysOpenQuery(cQry)

    ( cAlias )->( DBGoTop() )

    While ( cAlias )->( !Eof() )

        cTSSKey   := "S" + aRelation[1] + AllTrim( (cAlias)->&(aRelation[2] +"_ID") ) + AllTrim( (cAlias)->&(aRelation[2] +"_VERSAO") )
        cKeyTaf   := PadR((cAlias)->&(aRelation[2] +"_FILIAL"),nFilTam) + AllTrim( (cAlias)->&(aRelation[2] +"_ID") ) + AllTrim( (cAlias)->&(aRelation[2] +"_VERSAO") )
        nRecno    := (cAlias)->&("R_E_C_N_O_")

        If Substr( aRelation[3], 1, 3 ) <> aRelation[2]
            nRecFilho := (cAlias)->&("RECNO_FILHO")
        Else 
            nRecFilho := (cAlias)->&("R_E_C_N_O_")
        EndIf

        If !aTafRot[4] $ ( "S-5001|S-5002|S-5003|S-5011|S-5012|S-5013|S-5501|S-5503|" )
            cXmlId  := (cAlias)->&(aRelation[2] +"_XMLID")
        EndIf

        If Len(aCampos) > 0

            For nY := 4 to Len(aCampos)
                cKeyTaf += (cAlias)->&(aCampos[nY])
            Next 

        EndIf

        //Array completo para o UPD
        aAdd( aXmls, {cTSSKey, cKeyTaf, nRecno, cXmlId, cX2unic, nRecFilho })

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
        
        For nZ :=1 To Len(aRet)
            Aadd(aRetTotal, aRet[nZ])
        Next 

    Next

    For nX := 1 To Len(aXmlTss)

        If Len(aRetTotal) > 0 .and. aRetTotal[nX][1]

            If aRetTotal[nX][2] == aXmls[nX][1]
                aAdd( aXmls[nX], aRetTotal[nX][3])
            EndIf

        EndIf 

    Next

Return aXmls

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSubArray
    // Função auxiliar para extrair subarrays
    @type  Static Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param aArray, nStart, nSize
/*/
//-------------------------------------------------------------------
Static Function GetSubArray(aArray as array, nStart as numeric, nSize as numeric)

    Local aSubArray as array
    Local nI        as numeric

    Default aArray := {}
    Default nSize  := 0
    Default nStart := 0

    aSubArray := {}
    nI        := 0

    For nI := nStart To Min(nStart + nSize - 1, Len(aArray))
        aAdd(aSubArray, aArray[nI])
    Next nI

Return aSubArray

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecUPD
    Executa a alteração com base no XML retornado do TSS
    @type  Static Function
    @author Lucas Passos
    @since 25/07/2024
    @version version
    @param aXmls      - array com os xmls encontrados após o resultado da select
           cCampo     - variável com o campo a ser alterado
           cNoUPD     - variável com o caminho da tag que precisa ser encontrada
           cAliasPai  - alias da tabela pai do evento
           cLayout    - evento que esta sendo processado
           cTag       - nome da tag a ser encontrada no xml
    @see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function ExecUPD( aXmls as array, cCampo as character, cNoUPD as character, cAliasPai as character, cLayout as character, cTag as character )

    Local aChave      as array
    Local cAliasFilho as character
    Local cCodEvent   as character
    Local cLog1       as character
    Local cTimeFim    as character
    Local cTimeIni    as character
    Local cValorTag   as character
    Local cXml        as character
    Local nX          as Numeric
    Local nY          as Numeric
    Local oDados      as object
    
    Default aXmls     := {}
    Default cAliasPai := ""
    Default cCampo    := ""
    Default cLayout   := ""
    Default cNoUPD    := ""

    aChave      := {}
    cAliasFilho := Substr(cCampo,1,3)
    cCodEvent   := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
    cLog1       := ""
    cTimeFim    := ""
    cTimeIni    := Time()
    cValorTag   := ""
    cXml        := ""

    (cAliasPai)->(DbSetOrder(1))
    (cAliasFilho)->(DbSetOrder(1))

    If !CreateLog()

        cLog1 := STR0015 + CRLF // "Iniciando Processamento..."
        cLog1 += STR0016  + DToC(Date()) + " Hora: " + cTimeIni + CRLF // "Data: " // " Hora: "
        cLog1 += STR0018 + cUserName + CRLF + CRLF // "Usuário: "
        cLog  += cLog1

        For nX := 1 To Len(aXmls)

            cLog1 += "Registro " + cValToChar(nX) + " de " + cValToChar(Len(aXmls)) + " - "

            oDados := TXMLManager():New()

            If Len(aXmls[nX]) < 7
                cLog1 +=  "XMLID: " + aXmls[nX][4] + " Não encontrado no TSS" + CRLF
            Else
                cXml := FTrocaPath(SubStr(FTrocaPath( aXmls[nX][7] ), 3),"eSocial")
            EndIf 

            If Len(StrTokArr2( cXml, cTag )) > 1

                If !oDados:Parse( cXml )

                    conout( "Errors on Parse!" )
                    Loop 

                EndIf
            
                If !Empty(aXmls[nX][5])

                    aChave:= BusInfoNo( oDados, cNoUPD, cLayout )

                    (cAliasPai)->(DbGoTo(aXmls[nX][3]))

                    If Len(aChave) > 0

                        cLog1 +=  "Alteração de tabelas 0:N caso o XMLID apareça mais de uma vez, " + CRLF
                        cLog1 +=  "siginifica que existia mais de uma linha na grid para o campo alterado" + CRLF

                        For nY := 1 to Len(aChave)

                            (cAliasFilho)->(DbGoTo(aXmls[nX][6]))

                            If cLayout $ "1200|"

                                If Len(aChave[nY][2]) > 12 .And. Substr(aChave[nY][2],1,12) == Alltrim((cAliasFilho)->&("C9M_NRDOC"))

                                    cValorTag := aChave[nY][2]

                                EndIf

                            Else

                                If nTamTpDep < 6  
                                    cValorTag := aChave[nY][4]
                                Else
                                    cValorTag := Posicione( "CMI", 2 , xFilial("CMI") + aChave[nY][4] + PadR('', 8), "CMI_ID")
                                EndIf 

                            EndIf

                            If Empty(cValorTag) .Or. cValorTag == AllTrim((cAliasFilho)->&(cCampo))

                                cLog1 +=  "XMLID: " + aXmls[nX][4] + " Não precisou de alteração" + CRLF

                            Else

                                RecLock(cAliasFilho, .F. )
                                (cAliasFilho)->&(cCampo) := cValorTag
                                (cAliasFilho)->(MsUnlock())
                                cLog1 +=  "XMLID: " + aXmls[nX][4] + " Alterado com sucesso" + CRLF

                            EndIf

                        Next

                    EndIf 

                Else 

                    If TafXNode(oDados , cCodEvent, , cNoUPD)
                        cValorTag := oDados:XPathGetNodeValue(cNoUPD)
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

                EndIf 
            
                oEdit:Load(cLog1)

            EndIf

        Next

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
/*/{Protheus.doc} BusInfoNo
    Busca no XML o campo para complementar a chave e o campo a ser alterado
    @type  Static Function
    @author Lucas Passos
    @since 30/07/2024
    @version version
    @param oDados - objeto com os dados do XML
           cNoUPD - variável com o caminho da taf que precisa ser alterada
           cEvent - variável com o evento a ser alterado
/*/
//-------------------------------------------------------------------
Static Function BusInfoNo(oDados as object, cNoUPD as character, cEvent as character )

    Local aChave as array
    Local cCPF   as character
    Local cTag   as character
    Local nArr   as numeric
    Local nG     as numeric
    Local nJ     as numeric
    Local nW     as numeric
    Local nX     as numeric
    Local nY     as numeric
    Local nZ     as numeric

    Default cEvent := ""
    Default cNoUPD := ""
    Default oDados := Nil

    aChave := {}
    cCPF   := ""
    cTag   := ""
    nArr   := 1
    nG     := 0
    nJ     := 0
    nW     := 0
    nX     := 0
    nY     := 0
    nZ     := 0

    Do Case

        Case cEvent == "1200"

            //"eSocial/evtRemun/dmDev[@]/infoPerApur/ideEstabLot[@]/remunPerApur[@]/itensRemun[@]/descFolha/nrDoc"

            If Len(oDados:XPathGetChildArray(SubSTR(cNoUPD, 1, (At("[",cNoUPD,1))) + cValToChar(nArr) + "]")) > 0

                oDemDev := oDados:XPathGetChildArray(SubSTR(cNoUPD, 1, (At("[",cNoUPD,1))) + cValToChar(nArr) + "]")

                For nX := 1 to Len(oDemDev)

                    If oDemDev[nX][1] $ cNoUPD //infoPerApur (0-1)

                        oIdeEstabLot := oDados:XPathGetChildArray(oDemDev[nX][2]) //ideEstabLot (1-500)

                        For nY := 1 To Len(oIdeEstabLot)

                            If oIdeEstabLot[nY][1] $ cNoUPD
                        
                                oRemPerApur := oDados:XPathGetChildArray(oIdeEstabLot[nY][2]) //remunPerApur (1-8) 

                                For nZ := 1 To Len(oRemPerApur)

                                    If oRemPerApur[nZ][1] $ cNoUPD

                                        oItensRemun := oDados:XPathGetChildArray(oRemPerApur[nZ][2]) //itensRemun (1-200) 

                                        For nW := 1 To Len(oItensRemun)

                                            If oItensRemun[nW][1] $ cNoUPD

                                                oDescFolha := oDados:XPathGetChildArray(oItensRemun[nW][2]) //descFolha (0-1)

                                                For nJ := 1 To Len(oDescFolha)

                                                    If oDescFolha[nJ][1] $ cNoUPD

                                                        oNrDoc := oDados:XPathGetChildArray(oDescFolha[nJ][2])//descFolha (0-1)

                                                        For nG := 1 To Len(oNrDoc)

                                                            If oNrDoc[nG][1] $ cNoUPD

                                                                cTag   := oNrDoc[nG][1]
                                                                cValor := oNrDoc[nG][3]

                                                                Aadd(aChave, { cTag, cValor })

                                                            EndIf

                                                        Next

                                                    EndIf

                                                Next

                                            EndIf

                                        Next

                                    EndIf

                                Next

                            EndIf

                        Next

                    EndIf

                Next  

            EndIf

        Case cEvent == "2501"

            If Len(oDados:XPathGetChildArray(SubSTR(cNoUPD,1, (At("[",cNoUPD,1) - 1)))) > 0

                oAux := oDados:XPathGetChildArray(SubSTR(cNoUPD,1, (At("[",cNoUPD,1) - 1)))

                for nX := 1 to Len(oAux)
                    
                    If !Empty(oAux[nX][2]) /// Logica a ser implementada quando não for possivel usar o XPathGetChildArray
                        
                        If Len(oDados:XPathGetAttArray(oAux[nX][2])) > 0

                            For nY := 1 To Len(oDados:XPathGetAttArray(oAux[nX][2])) 

                                // DEVE SER ADCIONADO IFs PONTUAIS COM O CAMPO CHAVE PARA O SEEK
                                cNochave := "/eSocial/evtContProc/ideTrab/infoIRComplem[@]/infoDep[@]/cpfDep"
                                If SubStr(cNochave, RAt( "/" , cNochave )  + 1 ) == oDados:XPathGetAttArray(oAux[nX][2])[nY][1]
                                    cTag := "cpfDep"
                                    cCPF := oDados:XPathGetAttArray(oAux[nX][2])[nY][2]
                                EndIf 

                                // CAMPO de fato a ser alterado /////// Deve ser alterado a monategm do array com o campo da chave 
                                If SubStr(cNoUPD, RAt( "/" , cNoUPD )  + 1 ) == oDados:XPathGetAttArray(oAux[nX][2])[nY][1]
                                    Aadd(aChave, {cTag, cCPF,  oDados:XPathGetAttArray(oAux[nX][2])[nY][1] , oDados:XPathGetAttArray(oAux[nX][2])[nY][2]} )
                                EndIf 

                            Next 

                        EndIf 

                    EndIf 

                Next   

            EndIf

    Endcase

Return aChave

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

    cArquivo  := "regravaxml" + DToS(Date()) + StrTran(Time(), ":") + ".log"
    cTempPath := GetTempPath(.T.)
    oLog      := FWFileWriter():New(cTempPath + cArquivo, .T.)

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
    
    Local cDiretor := ""
    Local cDirIni  := ""

    If lLogError

        MsgStop(STR0022 + CRLF + oLog:Error():Message, STR0021) // "Falha ao gerar o arquivo de Log: " // "Atenção!"
        Return

    EndIf

    cDirIni   := Iif(GetRemoteType() == 2, "/", "C:\")
    cDiretor  := cGetFile(STR0023+ "|*.*", STR0014,, cDirIni, .T., 176, .T., .T.) // "Todos os arquivos" // "Exportar Log"

    __CopyFile(cTempPath + cArquivo, cDiretor + cArquivo)

Return
