#DEFINE SOURCEFATHER "RSPA100"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RSPA100.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} RSPA100RUS
    Russian Localization of Vacancy Registration
    @type  Function
    @author eduardo.FLima
    @since 17/03/2024
    @version R14
/*/
Function RSPA100RUS()
    Local oBrowse         as Object
    Local cSRJ            as Character
    Local cSQS            as Character

    Private cCadastro     as Character
    Private aRotina     as ARRAY
    Private cFiltraSQS     as Character

    aRotina        := {}
    cCadastro     := OemtoAnsi(STR0009) 
    cFiltraSQS     := ""
    oBrowse        := Nil

    cSQS := FWModeAccess( "SQS", 1) + FWModeAccess( "SQS", 2) + FWModeAccess( "SQS", 3)
    cSRJ := FWModeAccess( "SRJ", 1) + FWModeAccess( "SRJ", 2) + FWModeAccess( "SRJ", 3)

    If cSRJ > cSQS
        MsgInfo( oEmToAnsi( STR0024 ) + CRLF + CRLF + oEmToAnsi( STR0025 ) )
        Return (.F.)
    EndIf


    oBrowse := BrowseDef()
    oBrowse:Activate()

Return Nil


/*/{Protheus.doc} BrowseDef
    Browse definition
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @return oBrowse, Object    , Browse Object
/*/
Static Function BrowseDef() as Object
    Local     oBrowse        as Object
    Local     nX               as Numeric
    Private aLegenda    as Array
    
    oBrowse := FWLoadBrw(SOURCEFATHER)
    If oBrowse == nil
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('SQS')

        If ExistBlock("RSP100FT")
            ExecBlock("RSP100FT",.F.,.F.)
        Endif     

        If ValType(cFiltraSQS) == "C" .And. !Empty(cFiltraSQS)
            oBrowse:SetFilterDefault(cFiltraSQS)
        EndIf
        aLegenda:= {}

        Aadd(aLegenda,{"SQS->QS_NRVAGA >  SQS->QS_VAGAFEC", "GREEN" , STR0011})  
        Aadd(aLegenda,{"SQS->QS_NRVAGA <= SQS->QS_VAGAFEC"    ,"RED"    ,STR0012})  

        If ExistBlock("RSP100LG")
            ExecBlock("RSP100LG",.F.,.F.)
        Endif     

        For nX := 1 to len(aLegenda)
            oBrowse:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3]    )
        Next nX
    Endif 
    oBrowse:SetDescription(cCadastro)
Return oBrowse

/*/{Protheus.doc} MenuDef
    Menu Definition
    @type  Static Function
    @since 17/03/2024
    @version R14
    @return aRotina    , array    , array with the menu options of the routine
/*/
Static Function MenuDef() as Array
    Private aRotina as Array

    aRotina := {}
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.RSPA100'    OPERATION MODEL_OPERATION_VIEW ACCESS     0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.RSPA100'    OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.RSPA100'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.RSPA100'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir" 

    If ExistBlock("RSP100ME")
        ExecBlock("RSP100ME",.F.,.F.)
    Endif
Return aRotina


/*/{Protheus.doc} ModelDef
    Model Definition
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @return oModel    , Object    , Model of the Routine
/*/
Static Function ModelDef()
    Local oModel     AS Object
    Local oStruSQS    AS Object
    Local aPrinKey  AS Array
    Local oEvent As Object // Events.

    // oEvent := RSPA100Event():New()

    oStruSQS    := FWFormStruct(1,"SQS")
    oModel := MPFormModel():New(SOURCEFATHER,  ;
                                /*bPre*/, ;
                                /*bPost*/ {|oModel| RUSRPA1004_Commit()} ,;
                                /*bCommit*/ {|oModel| RSP100AGRV(oModel), dbSelectArea( "SQS" ), RSPPerfilVaga()}, ;
                                /*bCancel*/)

    
    oModel:AddFields("SQSMASTER",,oStruSQS,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
    oModel:SetDescription(cCadastro) 
    aPrinKey := RUSRPA1003_GetPk('SQS')
    oModel:SetPrimarykey(aPrinKey)

    oEvent := RSPA100Event():New()
    oModel:InstallEvent("RSPA100_Event",, oEvent)
    
Return oModel

/*/{Protheus.doc} ViewDef
    View Definition
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @return oView    , Object    , View Object
/*/
Static Function ViewDef()
    Local oModel    as Object
    Local oStruSQS    as Object
    Local oView        as Object
    Local aCampos     as Array
    Local aRmv       as Array
    Local nX         as Numeric


    oModel := FWLoadModel(SOURCEFATHER)
    oStruSQS := FWFormStruct(2,'SQS')
    oView := Nil
    aCampos := {}
    aRmv := {}    
    nX := 0

    oView := FWFormView():New()

    oView:SetModel( oModel )

    oStruSQS:AddFolder("1", STR0028)
    oStruSQS:AddFolder("2", STR0029)

    oView:AddField('VIEW_SQS', oStruSQS, 'SQSMASTER')

    oView:CreateHorizontalBox('SUPERIOR',100)

    oView:SetOwnerView('VIEW_SQS','SUPERIOR')

    oView:EnableTitleView('VIEW_SQS')

    oStruSQS:SetProperty( "QS_CODSITE",MVC_VIEW_ORDEM,"19")

    RSP100Uso(@aCampos)
    for nX := 1 to len(oStruSQS:aFields)
        If aScan(aCampos, {|x| x == oStruSQS:aFields[nX][1]}) == 0 
            aadd(aRmv,oStruSQS:aFields[nX][1])
        EndiF
    next nX
    for nX := 1 to len(aRmv)
        oStruSQS:RemoveField( aRmv[nX] )
    next nX
    //field's properties (from sx3) will be reassigned dynamically:
    RUSRPA1002_SetFolder(@oStruSQS)        

Return oView

/*/{Protheus.doc} RSP100AGRV
    Funcion used for commit the model of the routine
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @param oModel    , Object    , Model of the Routine
    @return lRet    , Logical    , If everything went well with the commit
/*/
Static Function RSP100AGRV(oModel)
    Local lRet             as Logical
    Local nOperation     as Numeric
    Local lDeleta         as Logical

    lRet         :=.T.
    nOperation    := oModel:GetOperation()
    lDeleta     := nOperation == MODEL_OPERATION_DELETE


    If lDeleta    
        lRet :=RSP100ChkDel(alias(),recno(),MODEL_OPERATION_DELETE)
        If lRet
            If ExistBlock("RSP100EX")
                lRet := ExecBlock("RSP100EX",.F.,.F.)
            EndIf
        EndIf
    Endif
    PcoIniLan("000080")
    iF lRet
        lRet := FwFormCommit(oModel)
    ENDIF
    iF lRet
        PcoDetLan("000080","01","RSPA100",lDeleta)
        PcoFinLan("000080")
    ENDIF
    PcoFreeBlq("000080")
RETURN lRet

/*/{Protheus.doc} RUSRPA1001_FeedTMpVar
    Feed the temporary variables when the returning of the standard query
    @type  Function
    @author user
    @since 17/03/2024
    @version R14
/*/
Function RUSRPA1001_FeedTMpVar()
    If TYPE('ACPORET')=="A"
        M->QS_MATRESP := ACPORET[1]
        M->QS_FILRESP := ACPORET[2]
    Endif
Return 


/*/{Protheus.doc} Static Function RUSRPA1002_SetFolder(oStr)
    Set the fields to their respective folders
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @param oStr    , Object    , Object with the view structure
/*/
Static Function RUSRPA1002_SetFolder(oStr)
    Local aFilReg     as Array 
    Local nX         as Numeric
    
    aFilReg := {}
    //Fields that will be in the tab Regsiter
    aadd(aFilReg,'QS_FILIAL'    )
    aadd(aFilReg,'QS_VAGA'        )
    aadd(aFilReg,'QS_DESCRIC'    )
    aadd(aFilReg,'QS_POSTO'        )
    aadd(aFilReg,'QS_FILPOST'    )
    aadd(aFilReg,'QS_AREA'        )
    aadd(aFilReg,'QS_CC'        )
    aadd(aFilReg,'QS_FUNCAO'    )
    aadd(aFilReg,'QS_NRVAGA'    )
    aadd(aFilReg,'QS_CLIENTE'    )
    aadd(aFilReg,'QS_SOLICIT'    )
    aadd(aFilReg,'QS_PRAZO'        )
    aadd(aFilReg,'QS_DTABERT'    )
    aadd(aFilReg,'QS_DTFECH'    )
    aadd(aFilReg,'QS_VAGAFEC'    )
    aadd(aFilReg,'QS_VCUSTO'    )
    aadd(aFilReg,'QS_PROCESS'    )
    aadd(aFilReg,'QS_TIPO'        )
    aadd(aFilReg,'QS_TESTE'        )
    aadd(aFilReg,'QS_PONTOS'    )
    aadd(aFilReg,'QS_AUTOM'        )
    aadd(aFilReg,'QS_MSGAPV'    )
    aadd(aFilReg,'QS_MSGREP'    )
    aadd(aFilReg,'QS_REINSC'    )
    aadd(aFilReg,'QS_MATRESP'    )
    aadd(aFilReg,'QS_FILRESP'    )
    aadd(aFilReg,'QS_CODPERF'    )
    aadd(aFilReg,'QS_PERFIL'    )
    aadd(aFilReg,'QS_FILTFF'    )
    aadd(aFilReg,'QS_CODTFF'    )
    aadd(aFilReg,'QS_CODSITE'    )

    For nX := 1 to len(oStr:aFields)
        If aScan(aFilReg, {|x| x == oStr:aFields[nX][1]}) != 0 
            oStr:SetProperty(oStr:aFields[nX][1], MVC_VIEW_FOLDER_NUMBER, "1") 
        Else
            oStr:SetProperty(oStr:aFields[nX][1], MVC_VIEW_FOLDER_NUMBER, "2") 
        EndiF
    next nX
Return 

/*/{Protheus.doc} RUSRPA1003_GetPk
    Returns the primary key of the model based on X2_UNICO
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @param cAlias    , Character    , alias of the X2_UNICO
    @return aRet    , ARRAY        , array with the primary key of the model 
/*/
Static Function RUSRPA1003_GetPk(cAlias)
    Local aArea     as Array
    Local aRet      as Array
    aArea     := GetArea()
        aRet      :={}
        DbSelectARea("SX2")
        DbSetOrder(1)
        If MsSeek(cAlias) .and. (!Empty(SX2->X2_UNICO))
            aRet := SEPARA(alltrim(SX2->X2_UNICO),'+')
        EndiF
    RestArea(aArea)
Return aRet


/*/{Protheus.doc} RUSRPA1004_Commit
    Returns the primary key of the model based on X2_UNICO
    @type  Static Function
    @author eduardo.Flima
    @since 17/03/2024
    @version R14
    @param cAlias    , Character    , alias of the X2_UNICO
    @return aRet    , ARRAY        , array with the primary key of the model 
/*/
Static Function RUSRPA1004_Commit()

    Local lRet as Logical
    
    lRet := RSP100Tok()

    If lRet .and. cPaisloc == "RUS" .And. (M->QS_TIPO == "1" .Or. M->QS_TIPO == "3")
		RU20XFUN13_ValidationSumm()
		lRet := RU20XFUN11_ValidationBeforeJson()
		If lRet
        	RU20XFUN12_generationJson()
		EndIf
    Endif

Return lRet
