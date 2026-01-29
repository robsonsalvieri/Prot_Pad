#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA710.CH'

/*/{Protheus.doc} GTPA710
Função responsavel para trazer o Browse do cadastro de Regras de produtos x Tipos de Bilhetes
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA710()

Local oBrowse  := Nil
Local cMsgErro := ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    If G710VldDic(@cMsgErro)    
        oBrowse := FwMBrowse():New()
        oBrowse:SetAlias('G9O')
        oBrowse:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes
        oBrowse:Activate()
    Else
        FwAlertHelp(cMsgErro, STR0007) //"Banco de dados desatualizado, não será possível iniciar a rotina"
    Endif

EndIf

Return Nil

/*/{Protheus.doc} ModelDef
Função responsavel para a definição do modelo
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel     := nil
Local oStruG9O   := FWFormStruct(1, 'G9O' )
Local oStruH601  := FWFormStruct(1, 'H60' )
Local oStruH602  := Nil
Local bLoadH601  := Nil
Local bLoadH602  := Nil
Local bPosValid  := {|oModel| G710PosVld(oModel) }
Local bLnPsH601  := {|oModelGrid| GTP721LPos(oModelGrid,"1")}
Local bLnPsH602  := {|oModelGrid| GTP721LPos(oModelGrid,"2")}
Local lCategoria := H60->( ColumnPos( 'H60_CATEGO' ) ) > 0 .And. H60->( ColumnPos("H60_PRDGRT")) > 0
Local oStruH87   := FWFormStruct(1, 'H87' )
Local bFieldVld  := {|oMdl, cField, uNewValue, uOldValue | FieldValid(oMdl, cField, uNewValue, uOldValue)}
If lCategoria
    oStruH602 := FWFormStruct(1,'H60')
    bLoadH601 := {|oModel| LoadH60(oModel,"1")}
    bLoadH602 := {|oModel| LoadH60(oModel,"2")}
Endif

SetModelStruct(oStruG9O, oStruH601, oStruH602, lCategoria,oStruH87)

oStruH87:SetProperty('H87_LOCORI', MODEL_FIELD_VALID, bFieldVld)
oStruH87:SetProperty('H87_LOCDES', MODEL_FIELD_VALID, bFieldVld)

oModel := MPFormModel():New('GTPA710', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G9OMASTER',/*cOwner*/,oStruG9O)

oModel:AddGrid('H60DETAIL1','G9OMASTER',oStruH601, , bLnPsH601,,,bLoadH601)
oModel:SetRelation('H60DETAIL1', {{'H60_FILIAL','xFilial("H60")'},{'H60_CODG9O','G9O_CODIGO'}}, H60->(IndexKey(1)))
oModel:GetModel('H60DETAIL1'):SetOptional(.T.)
oModel:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes

If lCategoria
    oModel:AddGrid('H60DETAIL2','G9OMASTER',oStruH602, , bLnPsH602,,,bLoadH602)
    oModel:SetRelation('H60DETAIL2', {{'H60_FILIAL','xFilial("H60")'},{'H60_CODG9O','G9O_CODIGO'}}, H60->(IndexKey(1)))
    oModel:GetModel('H60DETAIL2'):SetOptional(.T.)
Endif

oModel:GetModel('G9OMASTER'):SetDescription(STR0002)	//Regras de Produtos x Tipos de Bilhetes

oModel:AddGrid('H87DETAIL','G9OMASTER',oStruH87,,,,,)
oModel:SetRelation('H87DETAIL', {{'H87_FILIAL','xFilial("H87")'},{'H87_CODG9O','G9O_CODIGO'}}, H87->(IndexKey(1)))
oModel:GetModel('H87DETAIL'):SetOptional(.T.)

oModel:SetVldActivate({|oModel| G710VldAct(oModel)})
oModel:SetPrimaryKey({"G9O_FILIAL","G9O_ORIGEM","G9O_TIPO","G9O_STATUS"})

Return ( oModel )

/*/{Protheus.doc} SetModelStruct
Função responsavel para alteração da estrutura do modelo
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oStruG9O, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStruG9O, oStruH601, oStruH602, lCategoria, oStruH87)

oStruG9O:AddTrigger("G9O_PRDTAR", "G9O_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDTAR'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDTAX", "G9O_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDTAX'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDPED", "G9O_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDPED'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDSEG", "G9O_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDSEG'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDOUT", "G9O_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDOUT'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_GQCCOD", "G9O_GQCDES"  ,{ || .T. }, { |oMdl| Posicione('GQC',1,xFilial('GQC')+oMdl:GetValue('G9O_GQCCOD'),'GQC_DESCRI') } )
oStruG9O:AddTrigger("G9O_TIPO"  , "G9O_TIPO"    ,{ || .T. }, { |oMdl| AtuGerFis(oMdl) } )

oStruH601:AddTrigger("H60_PRDTAR", "H60_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAR'),'B1_DESC') } )
oStruH601:AddTrigger("H60_PRDTAX", "H60_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAX'),'B1_DESC') } )
oStruH601:AddTrigger("H60_PRDPED", "H60_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDPED'),'B1_DESC') } )
oStruH601:AddTrigger("H60_PRDSEG", "H60_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDSEG'),'B1_DESC') } )
oStruH601:AddTrigger("H60_PRDOUT", "H60_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDOUT'),'B1_DESC') } )

oStruH87:AddTrigger("H87_PRDTAR", "H87_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H87_PRDTAR'),'B1_DESC') } )
oStruH87:AddTrigger("H87_PRDTAX", "H87_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H87_PRDTAX'),'B1_DESC') } )
oStruH87:AddTrigger("H87_PRDPED", "H87_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H87_PRDPED'),'B1_DESC') } )
oStruH87:AddTrigger("H87_PRDSEG", "H87_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H87_PRDSEG'),'B1_DESC') } )
oStruH87:AddTrigger("H87_PRDOUT", "H87_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H87_PRDOUT'),'B1_DESC') } )

oStruH87:SetProperty('H87_LOCORI', MODEL_FIELD_OBRIGAT, .T.)
oStruH87:SetProperty('H87_LOCDES', MODEL_FIELD_OBRIGAT, .T.)

If lCategoria
    oStruH602:AddTrigger("H60_PRDTAR", "H60_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAR'),'B1_DESC') } )
    oStruH602:AddTrigger("H60_PRDTAX", "H60_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAX'),'B1_DESC') } )
    oStruH602:AddTrigger("H60_PRDPED", "H60_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDPED'),'B1_DESC') } )
    oStruH602:AddTrigger("H60_PRDSEG", "H60_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDSEG'),'B1_DESC') } )
    oStruH602:AddTrigger("H60_PRDOUT", "H60_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDOUT'),'B1_DESC') } )
    oStruH602:AddTrigger("H60_PRDGRT", "H60_DSCGRT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDGRT'),'B1_DESC') } )

    oStruH602:SetProperty('H60_UF', MODEL_FIELD_OBRIGAT, .F.)
Endif

If H60->(FieldPos("H60_GERFIS")) > 0
    oStruH601:SetProperty('H60_GERFIS', MODEL_FIELD_WHEN, {|| M->G9O_TIPO == 'T'})
    If lCategoria
        oStruH602:SetProperty('H60_GERFIS', MODEL_FIELD_WHEN, {|| M->G9O_TIPO == 'T'})
    Endif
Endif

Return

/*/{Protheus.doc} GTP721LPos(oModel)
@type function
@author flavio.martins
@since 01/04/2022
@version 1.0
@return lógico , ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTP721LPos(oModelGrid,cTipH60)
Local lRet      :=  .T.
Local oModel 	:= oModelGrid:GetModel()
Local nMk       := 0
Local nLinAtu   := 0
Local cContLin  := ""

If cTipH60 == "1" 
    If (!Empty(Alltrim(oModelGrid:GetValue('H60_UF'))) .And. Empty(oModelGrid:GetValue('H60_PRDTAR'))) .or. !Empty(oModelGrid:GetValue('H60_PRDTAR'))
        If Empty(Alltrim(oModelGrid:GetValue('H60_PRDTAR')))
            lRet := .F.
            oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", STR0012) //"Nenhum produto foi informado para o Estado"
        ElseIf Empty(oModelGrid:GetValue('H60_UF'))
             lRet := .F.
            oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", "Nenhum Estado foi informado para o Produto") //"Nenhum Estado foi informado para o Produto"
        EndIF
    ElseIf Empty(Alltrim(oModelGrid:GetValue('H60_UF'))) .And. Empty(Alltrim(oModelGrid:GetValue('H60_PRDTAR')))
        If !oModelGrid:IsDeleted()
            oModelGrid:DeleteLine()
        EndIf
    EndIf
Endif

If cTipH60 == "2"
    If lRet .And. Empty(oModelGrid:GetValue('H60_CATEGO')) 
        If Empty(oModelGrid:GetValue('H60_UF')) .And. Empty(oModelGrid:GetValue('H60_CATEGO')) .And. Empty(oModelGrid:GetValue('H60_PRDGRT'))
            If !oModelGrid:IsDeleted()
                oModelGrid:DeleteLine()
            EndIf
        Else
            lRet := .F.
            oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", STR0013) //"Informe a Categoria"
        EndIf
    ElseIf lRet .And. Empty(oModelGrid:GetValue('H60_PRDGRT'))
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", STR0018) //"Informe um produto de gratuidade"  
    Endif
    //Verifica duplicidade das linhas
    If lRet
        nLinAtu := oModelGrid:GETLINE()
        cContLin:= oModelGrid:GetValue('H60_UF',nLinAtu) + oModelGrid:GetValue('H60_CATEGO',nLinAtu) + oModelGrid:GetValue('H60_PRDGRT',nLinAtu)
        For nMk:= 1 to oModelGrid:Length()
            If !oModelGrid:IsDeleted(nMk) .And. nLinAtu <> nMk
                If cContLin == oModelGrid:GetValue('H60_UF',nMk) + oModelGrid:GetValue('H60_CATEGO',nMk) + oModelGrid:GetValue('H60_PRDGRT',nMk)
                    lRet := .F.
                    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", "Linha Duplicada") //"Informe um produto de gratuidade" 
                    Exit
                EndIf
            EndIf

        Next nMk
    EndIf
Endif

Return lRet

/*/{Protheus.doc} ViewDef
Função responsavel para a definição da interface
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA710') 
Local oView		:= FwFormView():New()
Local oStruG9O	:= FwFormStruct(2, 'G9O')
Local oStruH601  := FwFormStruct(2, 'H60', {|cCampo| !(AllTrim(cCampo) $'H60_CODIGO|H60_CODG9O|H60_CATEGO|H60_PRDGRT|H60_DSCGRT')})
Local oStruH602  := Nil
Local lCategoria := H60->( ColumnPos('H60_CATEGO') ) > 0 .And. H60->( ColumnPos("H60_PRDGRT")) > 0
Local oStruH87	:= FWFormStruct(2,'H87')
If lCategoria
    oStruH602  := FwFormStruct(2, 'H60', {|cCampo| !(AllTrim(cCampo) $'H60_CODIGO|H60_CODG9O|H60_PRDTAR|H60_DSCTAR|H60_PRDTAX|H60_DSCTAX|H60_PRDPED|H60_DSCPED|H60_PRDSEG|H60_DSCSEG|H60_PRDOUT|H60_DSCOUT')} )
Endif
oStruH87:RemoveField("H87_CODG9O")
SetViewStruct(oStruG9O, oStruH601, oStruH602, lCategoria)

oView:SetModel(oModel)

oView:AddField('VIEW_G9O' ,oStruG9O,'G9OMASTER')
oView:AddGrid('VIEW_H601', oStruH601, 'H60DETAIL1')

If lCategoria
    oView:AddGrid('VIEW_H602', oStruH602, 'H60DETAIL2')
Endif
oView:AddGrid('VIEW_H87', oStruH87, 'H87DETAIL')
oView:CreateHorizontalBox('HEADER', 70)
oView:CreateHorizontalBox('DETAIL', 30)

oView:CreateFolder('PASTAS','DETAIL')

oView:AddSheet('PASTAS','ABAREGRAS1',STR0016) //"Regras por Estado"

If lCategoria
    oView:AddSheet('PASTAS','ABAREGRAS2',STR0017) //"Regras para Gratuidade"
    oView:CreateVerticalBox( 'BOX_H601', 100, , , 'PASTAS', 'ABAREGRAS1')
    oView:CreateVerticalBox( 'BOX_H602', 100, , , 'PASTAS', 'ABAREGRAS2')
Else
    oView:CreateVerticalBox( 'BOX_H601', 100, , , 'PASTAS', 'ABAREGRAS1')
Endif
oView:AddSheet('PASTAS','ABATRECHO',STR0019) //'Regras Trechos da linha'
oView:CreateVerticalBox( 'BOX_H87', 100, , , 'PASTAS', 'ABATRECHO')
oView:SetOwnerView('VIEW_H87','BOX_H87')
oView:EnableTitleView('VIEW_H87', STR0019) //'Regras Trechos da linha'

oView:SetOwnerView('VIEW_G9O','HEADER')
oView:SetOwnerView('VIEW_H601','BOX_H601')
oView:EnableTitleView('VIEW_H601', STR0008) //'Regras de Produto por Estado'

If lCategoria
    oView:SetOwnerView('VIEW_H602','BOX_H602')
    oView:EnableTitleView('VIEW_H602', STR0015) //"Regra de Produtos para Gratuidade"
Endif

oView:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes

Return ( oView )

/*/{Protheus.doc} SetViewStruct
Função responsavel para alterar a estrutura da View
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oStruG9O, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruG9O, oStruH601, oStruH602, lCategoria)
Local aFldsG9O  := StrToKarr('G9O_CODIGO|G9O_ORIGEM|G9O_TIPO|G9O_STATUS|G9O_GQCCOD|G9O_GQCDES|G9O_MSBLQL', "|")
Local nX 		:= 0

oStruG9O:AddGroup('GRP001', STR0009,'', 2) // "Dados do Bilhetes"

oStruG9O:SetProperty( 'G9O_CODIGO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_ORIGEM'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_TIPO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_STATUS'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_GQCCOD'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_GQCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_MSBLQL'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')

oStruG9O:AddGroup('GRP002', STR0010,'', 2) // "Produtos"

oStruG9O:SetProperty( 'G9O_PRDTAR', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDTAX', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDPED', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDSEG', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDOUT', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCTAR', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCTAX', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCPED', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCSEG', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCOUT', MVC_VIEW_GROUP_NUMBER, 'GRP002')


For nX := 1 To Len(aFldsG9O)
    oStruG9O:SetProperty(aFldsG9O[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

Return 

/*/{Protheus.doc} MenuDef
Função responsavel para definir as operações do browse
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA710' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA710' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA710' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA710' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

/*/{Protheus.doc} G710PosVld
Função responsavel para pós validação do modelo (Tudo OK)
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G710PosVld(oModel)
Local lRet	:= .T.
Local oMdlG9O	:= oModel:GetModel('G9OMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlG9O:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG9O:GetOperation() == MODEL_OPERATION_UPDATE)
	lRet := ExistChav("G9O", oMdlG9O:GetValue("G9O_ORIGEM") + oMdlG9O:GetValue("G9O_TIPO") + oMdlG9O:GetValue("G9O_STATUS")+ oMdlG9O:GetValue("G9O_GQCCOD"),2 )
EndIf

Return lRet

/*/{Protheus.doc} G710VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 30/03/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G710VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G710VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0011 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G710VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} G710VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 30/03/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G710VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H60','H87'}
Local aFields       := {'H60_CODG9O','H60_UF','H60_PRDTAR','H60_PRDTAX','H60_PRDPED','H60_PRDSEG','H60_PRDOUT'}
Local nX            := 0
Default cMsgErro    := ''

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet

/*/{Protheus.doc} AtuGerFis
(long_description)
@type  Static Function
@author flavio.martins
@since 22/05/2023
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuGerFis(oMdl)
Local oModel := oMdl:GetModel()
Local nX     := 0

If H60->(FieldPos('H60_GERFIS')) > 0

    If oModel:GetValue('G9OMASTER', 'G9O_TIPO') != 'T'

        For nX := 1 To oModel:GetModel("H60DETAIL1"):Length()
            oModel:GetModel("H60DETAIL1"):GoLine(nX)
            oModel:GetModel("H60DETAIL1"):LoadValue('H60_GERFIS', '1')
        Next nX
        
        If H60->(FieldPos('H60_CATEGO')) > 0
            For nX := 1 To oModel:GetModel("H60DETAIL2"):Length()
                oModel:GetModel("H60DETAIL2"):GoLine(nX)
                oModel:GetModel("H60DETAIL2"):LoadValue('H60_GERFIS', '1')
            Next nX
        Endif
    Endif

Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadH60
@Description	Pré carrega cadastro de Tecnicos
@sample			LoadH60(oMdlH60)
@param			oMdlH60,cTipH60
@return			aLoadH60
@author			kaique.olivero 
@since			21/11/2023
/*/
//-----------------------------------------------------------------------------
Static Function LoadH60(oMdlH60,cTipH60)
Local aLoadH60		:= {}
Local oStructH60 	:= oMdlH60:GetStruct()
Local aFieldsH60	:= oStructH60:GetFields()
Local nY			:= 0
Local nMk           := 0
Local cCodPai		:= G9O->G9O_CODIGO

H60->(DBSetOrder(1))
If H60->(DBSeek(xFilial("H60") + cCodPai))
    While xFilial("H60") == H60->H60_FILIAL .And. H60->H60_CODG9O == cCodPai
        If (cTipH60 == "1" .And. Empty(H60->H60_CATEGO)) .Or. (cTipH60 == "2" .And. !Empty(H60->H60_CATEGO)) 
            aAdd(aLoadH60,{H60->(RecNo()), Array(Len(aFieldsH60))})
            nMk:= Len(aLoadH60)
            For nY := 1 To Len(aFieldsH60)
                If !aFieldsH60[nY][MODEL_FIELD_VIRTUAL]
                    aLoadH60[nMk][2][nY] := &("H60->"+ (AllTrim(aFieldsH60[nY][MODEL_FIELD_IDFIELD])))
                Else
                    aLoadH60[nMk][2][nY] := CriaVar(aFieldsH60[nY][MODEL_FIELD_IDFIELD], .T.)
                EndIf
            Next(nY)
        Endif
        H60->(dbSkip())
    EndDo
EndIf

Return(aLoadH60)

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função chamada pelo bloco de validação dos campos

@type static function
@version 12.1.2310
@author jose.darocha
@since 20/10/2025
@param oMdl, object, Modelo
@param cField, character, Campo
@param uNewValue, variant, Novo Valor
@param uOldValue, variant, Antigo Valor
@return lRet, Retorna se permite o conteúdo do campo ou não.
/*/
//-------------------------------------------------------------------
Static Function FieldValid(oMdl, cField, uNewValue, uOldValue) 
    Local lRet      := .T.
    Local oModel	:= oMdl:GetModel()
    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    If cField == 'H87_LOCDES' .And. (lRet := ExistCpo('GI1'))
        If Alltrim(FwFldGet('H87_LOCORI')) == Alltrim(uNewValue)         
            lRet := .F.
            cMsgErro := STR0020  //'Não é permitido localidades Destino e Origem iguais.'
            cMsgSol  := STR0021  //'Revise as localidades.'
        EndIf 
    ElseIf cField == 'H87_LOCORI' .And. (lRet := ExistCpo('GI1'))
        If Alltrim(FwFldGet('H87_LOCDES')) == Alltrim(uNewValue)         
            lRet := .F.
            cMsgErro := STR0022 //'Não é permitido localidades Origem e Destino iguais.'
            cMsgSol  := STR0021 //'Revise as localidades.'
        EndIf 
    Endif    

    If !lRet .and. !Empty(cMsgErro)
        oModel:SetErrorMessage(cMdlId, cField, cMdlId, cField, "FieldValid", cMsgErro, cMsgSol, uNewValue, uOldValue)
    Endif

Return lRet
