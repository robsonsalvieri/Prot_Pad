#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA632.CH"


PUBLISH MODEL REST NAME TAFA632

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA632
Nome: Mit - Modulo de Inclusão do Tributos

@author Wesley Matos
@since 09/01/2025
@version 1.0
  
/*/
//-------------------------------------------------------------------

Function TAFA632() 
    
    if AliasInDic('T1A')
        BrowseDef()
    else
        MsgInfo( STR0002 , STR0003 )//Base de dados desatualizada. Favor, aplicar ultimo pacote da Expedição Continua', Importante!
    endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Wesley Matos
@since 09/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina as array

    aRotina := {}

    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TAFA632" OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TAFA632" OPERATION 3 ACCESS 0 //"incluir"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA632" OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TAFA632" OPERATION 5 ACCESS 0 //"Excluir"

Return( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Wesley Matos
@since 09/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruT1A	as object
    Local oStruT1B	as object
    Local oModel	as object

    oStruT1A :=	FWFormStruct( 1, "T1A" )
    oStruT1B := FWFormStruct( 1, 'T1B' )
    oModel	 :=	MPFormModel():New( "TAFA632",,{ |oModel| ValidT1A(oModel)}, { |oModel| SaveModel( oModel ) } )
    
    oModel:AddFields( "MODEL_T1A",, oStruT1A )
    oModel:AddGrid( "MODEL_T1B", 'MODEL_T1A', oStruT1B )

    oModel:GetModel( "MODEL_T1A" ):SetPrimaryKey({"T1A_ID"})
    oModel:GetModel( "MODEL_T1B" ):SetOptional( .T. )
    oModel:GetModel( "MODEL_T1B" ):SetUniqueLine( { 'T1B_IDPROC','T1B_CODSUS' } )

    oModel:SetRelation( "MODEL_T1B", { { "T1B_FILIAL", "xFilial( 'T1B' )" }, { "T1B_ID", "T1A_ID" }}, T1B->( IndexKey( 1 ) ) )


Return( oModel )


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC
@author Wesley Matos
@since 09/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel 	:= FWLoadModel( 'TAFA632' )
    Local oView 	:= FWFormView():New()
    Local oStruT1A	:= Nil
    Local oStruT1B	:= Nil

    oStruT1A := FWFormStruct( 2, "T1A" )
    oStruT1B := FWFormStruct( 2, "T1B" )

    oView:SetModel( oModel )
    oView:AddField("VIEW_T1A",oStruT1A, 'MODEL_T1A')
    oView:EnableTitleView("VIEW_T1A", STR0001) //MIT - Modulo de Inclusão dos Tributos

    oView:CreateHorizontalBox("PAINEL_PRINCIPAL",60)
    oView:CreateHorizontalBox("PAINEL_INFERIOR",40)

    oView:AddGrid("VIEW_T1B", oStruT1B, "MODEL_T1B")
    oView:EnableTitleView("VIEW_T1B", STR0008) //Processos MIT

    oView:SetOwnerView( 'VIEW_T1A', 'PAINEL_PRINCIPAL' )
    oView:SetOwnerView( 'VIEW_T1B', 'PAINEL_INFERIOR' )

    //Defino a ordem de alguns campos
    oStruT1A:SetProperty( "T1A_PERAPU"	, MVC_VIEW_ORDEM, '001' )
    oStruT1A:SetProperty( "T1A_IDDEBI"	, MVC_VIEW_ORDEM, '002' )
    oStruT1A:SetProperty( "T1A_CODREC"	, MVC_VIEW_ORDEM, '003' )
    oStruT1A:SetProperty( "T1A_CODTRI"	, MVC_VIEW_ORDEM, '004' )
    oStruT1A:SetProperty( "T1A_IDTRIB"	, MVC_VIEW_ORDEM, '005' )
    oStruT1A:SetProperty( "T1A_DESTRI"	, MVC_VIEW_ORDEM, '006' )
    oStruT1A:SetProperty( "T1A_FILORI"	, MVC_VIEW_ORDEM, '007' )
    oStruT1A:SetProperty( "T1A_ANOPOS"	, MVC_VIEW_ORDEM, '008' )
    oStruT1A:SetProperty( "T1A_TRIPOS"	, MVC_VIEW_ORDEM, '009' )
    oStruT1A:SetProperty( "T1A_DTDEBI"	, MVC_VIEW_ORDEM, '010' )
    oStruT1A:SetProperty( "T1A_PERIOD"	, MVC_VIEW_ORDEM, '011' )
    oStruT1A:SetProperty( "T1A_CPNEST"	, MVC_VIEW_ORDEM, '012' )
    oStruT1A:SetProperty( "T1A_CNPINC"	, MVC_VIEW_ORDEM, '013' )
    oStruT1A:SetProperty( "T1A_VALTRI"	, MVC_VIEW_ORDEM, '014' )
    oStruT1A:SetProperty( "T1A_UF"	    , MVC_VIEW_ORDEM, '015' )
    oStruT1A:SetProperty( "T1A_DESCUF"	, MVC_VIEW_ORDEM, '016' )
    oStruT1A:SetProperty( "T1A_CODMUN"	, MVC_VIEW_ORDEM, '017' )
    oStruT1A:SetProperty( "T1A_DCODMU"	, MVC_VIEW_ORDEM, '018' )
    oStruT1A:SetProperty( "T1A_CNPSCP"	, MVC_VIEW_ORDEM, '019' )
    oStruT1A:SetProperty( "T1A_NOMSCP"	, MVC_VIEW_ORDEM, '020' )

    //Defino que alguns campos serão somente para visualização
    oStruT1A:SetProperty( "T1A_IDDEBI"	,MVC_VIEW_CANCHANGE, .F.)
    oStruT1A:SetProperty( "T1A_IDTRIB"	,MVC_VIEW_CANCHANGE, .F.)

    //Defino os campos que não serão exibidos na tela
    oStruT1A:RemoveField('T1A_IDDEBI') //Não deve ser apresentado para o usuário.
    oStruT1A:RemoveField('T1A_ID')
    oStruT1A:RemoveField('T1A_IDSCP')
    oStruT1B:RemoveField('T1B_ID')
    oStruT1B:RemoveField('T1B_IDSUSP')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Wesley Matos
@since 15/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrw as object

    oBrw := FWmBrowse():New()
    oBrw:SetAlias( 'T1A')
    oBrw:SetDescription(STR0001) //"Info Contrapartes Trans. Controladas"
    oBrw:Activate()

Return( oBrw )


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do modelo

@Param  oModel -> Modelo de dados
@Return .T.
@Author Wesley Matos
@Since 09/01/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation as numeric
	Local lRetorno	 as logical

	nOperation 		 := oModel:GetOperation()
	lRetorno		 := .T.

	FWFormCommit( oModel )

Return( lRetorno )


//-------------------------------------------------------------------
/*/	{Protheus.doc} ValidT1A
Validacao de campos do Model

@param oModel -> Modelo de dados
@return lRet
@author  Wesley Matos
@since   15/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidT1A(oModel)

    Local cSeek		 as Character
    Local lRet       as logical
    Local alGetT1A	 as array
    Local nTamPeraPu as numeric
    Local aStrucT1A  as array
    Local nTamIdDebi as numeric
    
    cSeek       := ''
    lRet 		:= .T.
    alGetT1A 	:= T1A->( GetArea() )
    aStrucT1A   := FwSx3Util():GetListFieldsStruct( 'T1A' , .F.)
    nTamPeraPu  := aStrucT1A[7][3]
    nTamIdDebi  := aStrucT1A[4][3]

    //Validação do campo T1A_PERAPU
    if !Len(Alltrim(FwFldGet("T1A_PERAPU"))) == nTamPeraPu .or. !ValidMes(Val(SubStr(FwFldGet("T1A_PERAPU"),1,2)))
        oModel:SetErrorMessage( ,,,,, STR0011, STR0012,, )//Preenchimento invalido, O conteúdo preenchido no campo T1A_PERAPU esta incorreto
        lRet := .F.
    endIf

    //Validação para chave duplicada
    dbSelectArea("T1A")
    T1A->(dbSetOrder(2)) //T1A_FILIAL+T1A_PERAPU+T1A_IDDEBI+T1A_IDTRIB+T1A_CODREC
    
    cSeek := xFilial("T1A") + FwFldGet("T1A_PERAPU") + Str(FwFldGet("T1A_IDDEBI"),nTamIdDebi) + FwFldGet("T1A_IDTRIB") + FwFldGet("T1A_CODREC")
    if T1A->( DbSeek( cSeek) )
        if T1A->T1A_ID <> FwFldGet("T1A_ID")
            lRet := .F.
            oModel:SetErrorMessage( ,,,,, STR0013, STR0014,, )//Chave duplicada, O conteúdo preenchido forma uma chave já cadastrada
        endif
    endif
    
    RestArea( alGetT1A )
    T1A->(DbCloseArea())
    
Return lRet


//-------------------------------------------------------------------
/*/	{Protheus.doc} IncIdDeb
Função de gatilho, incrementa o campo T1A_IDDEBI e retorna o valor sequencial com base no ultimo ID inserido

@param  
@return  cIdDeb
@author  Wesley Matos
@since   15/01/2025
@version 1.0
/*/
Function IncIdDeb()

    Local nIdDeb as numeric
    Local lRet   as logical

    nIdDeb := 0
    lRet   := .T.

    nIdDeb := IdDebQuery()
    nIdDeb += 1
    
Return nIdDeb


//-------------------------------------------------------------------
/*/	{Protheus.doc} IdDebQuery
Retorna o ultimo ID disponivel para um determinado periodo, esse ID será utilizado no campo T1A_IDDEBI.

@param  
@return  nUltIdDeb
@author  Wesley Matos
@since   15/01/2025
@version 1.0
/*/
Static Function IdDebQuery()

    Local oPrepare  as object
    Local nUltIdDeb as numeric
    Local cAlias    as character
    Local cQuery    as aharacter

    oPrepare  := Nil
    nUltIdDeb := 0
    cAlias    := ""
    cQuery	  := ""

    cQuery += " SELECT "
    cQuery += " MAX(T1A.T1A_IDDEBI) MAXID "
    cQuery += " FROM " + RetSqlName("T1A") + " T1A "
    cQuery += " WHERE "
    cQuery += " T1A.T1A_FILIAL = ? AND "
    cQuery += " T1A.T1A_PERAPU = ? AND "
    cQuery += " T1A.D_E_L_E_T_ = ? "

    cQuery := ChangeQuery(cQuery)

    oPrepare := FwExecStatement():New(cQuery)
    oPrepare:setString(1,xFilial("T1A"))
    oPrepare:setString(2,M->T1A_PERAPU)
    oPrepare:setString(3,' ')
    
    cAlias := GetNextAlias()
    oPrepare:OpenAlias(cAlias)

    nUltIdDeb := (cAlias)->MAXID

    (cAlias)->(DbCloseArea())
    freeObj(oPrepare)

return nUltIdDeb


//-------------------------------------------------------------------
/*/	{Protheus.doc} ValidMes
Valida um campo de periodo para garantir que o mês esteja valido

@param   nMes
@return  lRet
@author  Wesley Matos
@since   15/01/2025
@version 1.0
/*/
Static Function ValidMes(nMes)

    Local lRet as logical

    lRet := .F.

    if nMes <= 12 .AND. nMes >= 1
        lRet := .T.
    else
        lRet := .F.
    endIf

return lRet


//-------------------------------------------------------------------
/*/	{Protheus.doc} IncCNPJ
Função de gatilho, busca o CNPJ da filial de origem conforme a seleção do campo T1A_FILORI

@param  
@return  cCgc
@author  Wesley Matos
@since   20/01/2025
@version 1.0
/*/
Function IncCNPJ()

    Local aUtilFlds as array
    Local aUtilData as array
    Local cCgc      as character
    Local cFil      as character

    aUtilFlds := { "M0_CGC" }
    aUtilData := {}
    cCgc      := ''
    cFilori   := M->T1A_FILORI
    cFil      := ''

    if !Empty(Alltrim(cFilori))
        cFil      := Posicione('C1E',1, xFilial('C1E')+cFilori, "C1E_FILTAF")
        aUtilData := FWSM0Util():GetSM0Data( cEmpAnt , cFil , aUtilFlds)
        cCgc      := aUtilData[1][2]
    endIf

Return cCgc
