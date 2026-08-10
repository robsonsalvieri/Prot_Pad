#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"
#Include "GTPC300S.ch"

/*/{Protheus.doc} GTPC300S
Função da Tela de + Documentos de Viagens em Monitor Operacional.
@type  function Static
@author Eduardo Silva
@since  19/03/2024
@version 12.1.2310
/*/

//Function GTPC300S()
//Return Nil

/*/{Protheus.doc} MenuDef
Função para criação dos menus.
@type  Static MenuDef
@author Eduardo Silva
@since  19/03/2024
@version 12.1.2310
/*/

//Static Function MenuDef()
//Local aRot := {}
//ADD OPTION aRot TITLE STR0001       ACTION 'VIEWDEF.GTPC300S' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0   // 'Visualizar'
//ADD OPTION aRot TITLE STR0002       ACTION 'VIEWDEF.GTPC300S' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0   // 'Incluir'  
//ADD OPTION aRot TITLE STR0003 		ACTION 'VIEWDEF.GTPC300S' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // 'Alterar'
//ADD OPTION aRot TITLE STR0004 		ACTION 'VIEWDEF.GTPC300S' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0   // 'Excluir'
//Return aRot

/*/{Protheus.doc} ModelDef
Função para criação do Modelo da Tela em MVC
@type  Static ModelDef
@author Eduardo Silva
@since  19/03/2024
@version 12.1.2310
/*/

Static Function ModelDef()
Local oStruGYN  := FWFormStruct( 1 , "GYN" )
Local oStruH68  := FWFormStruct( 1 , "H68" )
Local oStruGQE  := FWFormStruct( 1 , "GQE" )
Local oStruG6W  := FWFormStruct( 1 , "G6W" )
Local oModel
oStruGYN:AddField(FWX3Titulo("GI2_ORGAO"), FWX3Titulo("GI2_ORGAO"), "ORGAO", "C", TamSX3("GI2_ORGAO")[1], 0, Nil, Nil, Nil, .F., Nil, .F., .F., .T.)
oStruH68:AddField("", "", "H68_ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., Nil, .F., .F., .T.)
oStruGQE:AddField(STR0005, STR0005, "GQE_CODG6V", "C", 6,0, Nil, Nil, Nil, .F., Nil, .F., .T., .T.)   // "Codigo"
oStruG6W:AddField("", "", "G6W_ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., Nil, .F., .F., .T.)
oStruGYN:SetProperty("*"    , MODEL_FIELD_WHEN  , {|| IsInCallStack("GATGI2ORG")} )
oStruG6W:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
oStruGQE:SetProperty("*", MODEL_FIELD_OBRIGAT , .F.)
oStruGQE:SetProperty('GQE_DRECUR', MODEL_FIELD_INIT,{|| GC300DRECUR()} )
oModel := MPFormModel():New( 'GTPC300S', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields('GYNMASTER',, oStruGYN )
oModel:AddGrid('H68DETAIL','GYNMASTER',oStruH68,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,{|oMdl| LoadMdlH68(oMdl) }/*BLoad*/)
oModel:GetModel('H68DETAIL'):SetOptional(.T.)
oModel:AddGrid('GQEDETAIL','GYNMASTER',oStruGQE,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,{|oMdl| LoadMdlGQE(oMdl) }/*BLoad*/)
oModel:GetModel( 'GQEDETAIL' ):SetOptional(.T.)
oModel:AddGrid('G6WDETAIL','GQEDETAIL',oStruG6W,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,{|oMdl| LoadMdlG6W(oMdl) }/*BLoad*/)
oModel:GetModel( 'G6WDETAIL' ):SetOptional(.T.)
oModel:SetDescription(STR0006) // "Documento Viagem"
oModel:GetModel( 'GYNMASTER' ):SetDescription( STR0006 )    // "Documento Viagem"
oModel:SetActivate({ |oModel| GATGI2ORG( oModel ) })
Return oModel 

/*/{Protheus.doc} ViewDef
Função para criação da View em MVC
@type  Static ViewDef
@author Eduardo Silva
@since  19/03/2024
@version 12.1.2310
/*/

Static Function ViewDef()
Local oModel := FWLoadModel( 'GTPC300S' )   // ModelDef()
Local oView 
Local oStrGYN := FWFormStruct(2, 'GYN', { |x| AllTrim(x) + "|" $ "GYN_CODIGO|GYN_TIPO|GYN_LINCOD|" }) 
Local oStruH68 := FWFormStruct(2, 'H68', { |x| !AllTrim(x) + "|" $ "H68_CODGI0" } )
Local oStruGQE := FWFormStruct(2, 'GQE')
Local oStruG6W := FWFormStruct(2, 'G6W')
Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}
oStruH68:RemoveField( "H68_CODGI0" )
oStruGQE:RemoveField( "GQE_VIACOD" )
oStruGQE:RemoveField( "GQE_SEQ" )
oStrGYN:AddField("ORGAO","08",FWX3Titulo("GI2_ORGAO"),FWX3Titulo("GI2_ORGAO"),{""},"GET","",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Orgão"
oStruH68:AddField("H68_ANEXO","01",STR0007,STR0007,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruG6W:AddField("G6W_ANEXO","01",STR0007,STR0007,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruGQE:SetProperty("GQE_ITEM",MVC_VIEW_ORDEM,"01")
oView := FWFormView():New()  
oView:SetModel(oModel)
oView:AddField('VIEW_GYN', oStrGYN , 'GYNMASTER' )  
oView:AddGrid('VIEW_H68', oStruH68 , 'H68DETAIL' )
oView:AddGrid('VIEW_GQE', oStruGQE , 'GQEDETAIL' )
oView:AddGrid('VIEW_G6W', oStruG6W , 'G6WDETAIL' )
oView:SetViewProperty("VIEW_H68", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_GQE", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_G6W", "GRIDDOUBLECLICK", bDblClick)
oView:CreateHorizontalBox('SUPERIOR' , 10)  
oView:CreateHorizontalBox('INFERIORA' , 30)
oView:CreateHorizontalBox('INFERIORB' , 30)
oView:CreateHorizontalBox('INFERIORC' , 30)
oView:SetOwnerView('VIEW_GYN' , 'SUPERIOR')
oView:SetOwnerView('VIEW_H68' , 'INFERIORA')
oView:SetOwnerView('VIEW_GQE' , 'INFERIORB')
oView:SetOwnerView('VIEW_G6W' , 'INFERIORC')
oView:EnableTitleView('VIEW_GYN', STR0006)  // 'Documento Viagem'
oView:EnableTitleView('VIEW_H68', STR0008)  // 'Documento Orgãos'
oView:EnableTitleView('VIEW_GQE', STR0009)  // 'Recursos'
oView:EnableTitleView('VIEW_G6W', STR0010)  // 'Documento Recursos'
Return oView

/* /{Protheus.doc} GATGI2ORG
Função responsavel pelo carregamento dos registros na tela das tabelas GYN, H68, GQE e G6W.
@type Static Function
@author Eduardo Silva
@since 25/03/2024
@version 12.1.2310
/*/

Static Function GATGI2ORG(oModel)
Local oModelGYN := oModel:GetModel('GYNMASTER')
Local oGridH68  := oModel:GetModel('H68DETAIL')
Local oGridGQE  := oModel:GetModel('GQEDETAIL')
Local oGridG6VW := oModel:GetModel('G6WDETAIL')
Local cOrgao    := ""
Local oView     := FwViewActive()
Local nX
Local nY
Local nZ
cOrgao := Posicione("GI2", 1, xFilial("GI2") + oModelGYN:GetValue("GYN_LINCOD"),"GI2_ORGAO")
oModelGYN:SetValue("ORGAO",cOrgao)
For nX := 1 to oGridH68:Length()
    oGridH68:GoLine(nX)  
    oGridH68:SetValue("H68_ANEXO", SetIniFld(oGridH68:GetValue("H68_CODGI0"), oGridH68:GetValue("H68_CODG6U"), "H68"))
Next nX
For nY := 1 to oGridGQE:Length()
    oGridGQE:GoLine(nY)
    For nZ := 1 to oGridG6VW:Length()
        oGridG6VW:GoLine(nZ)  
        oGridG6VW:SetValue("G6W_ANEXO", SetIniFld(oGridG6VW:GetValue("G6W_CODIGO"), oGridG6VW:GetValue("G6W_SEQ"), "G6W"))
    Next nZ
Next nY
oGridH68:GoLine(1)
oGridGQE:GoLine(1)
oGridG6VW:GoLine(1)
oView:SetNoDeleteLine('VIEW_H68')
oView:SetNoUpdateLine('VIEW_H68')
oView:SetNoInsertLine('VIEW_H68')
oView:SetNoDeleteLine('VIEW_GQE')
oView:SetNoUpdateLine('VIEW_GQE')
oView:SetNoInsertLine('VIEW_GQE')
oView:SetNoDeleteLine('VIEW_G6W')
oView:SetNoUpdateLine('VIEW_G6W')
oView:SetNoInsertLine('VIEW_G6W')
Return 

/*/{Protheus.doc} SetIniFld()
FunÃ§Ã£o para tratamento da legenda do item (campo anexo).
@type  Static Function
@author Eduardo Silva
@since 13/03/2024
/*/
Static Function SetIniFld(cCodOrg, cCodGU6, cTable)
Local cValor    := ""
Default cCodOrg := ""
Default cCodGU6 := ""
Default cTable  := ""
AC9->( dbSetOrder(2) )  // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
If AC9->( dbSeek(xFilial('AC9') + cTable + xFilial(cTable) + xFilial(cTable) + cCodOrg + cCodGU6) )
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
EndIf
Return cValor

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
FunÃ§Ã£o de tratamento par ao duplo clique do anexo.
@type  Static Function
@author Eduardo Silva
@since 20/03/2024
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()
If cField $ 'H68_ANEXO/G6W_ANEXO'
    AttachDocs(oView,cField)
EndIf
Return .T.

/*/{Protheus.doc} AttachDocs(oView)
FunÃ§Ã£o para tratamento do MsDocument para anexar os documentos aos itens.
@type  Static Function
@author Eduardo Silva
@since 20/03/2024
/*/
Static Function AttachDocs(oView,cField)
Local cCodOrg   := ""
Local cCodGU6   := ""
Local cTable    := ""
If cField == "H68_ANEXO"
    cCodOrg := oView:GetModel():GetValue('H68DETAIL','H68_CODGI0')
    cCodGU6 := oView:GetModel():GetValue('H68DETAIL','H68_CODG6U')
    cTable  := "H68"
ElseIf cField == "G6W_ANEXO"
    cCodOrg   := oView:GetModel():GetValue('G6WDETAIL','G6W_CODIGO')
    cCodGU6   := oView:GetModel():GetValue('G6WDETAIL','G6W_SEQ')
    cTable  := "G6W"
EndIf
(cTable)->( dbSetOrder(1) )  // H68_FILIAL + H68_CODGI0 + H68_CODG6U
If (cTable)->( dbSeek( xFilial(cTable) + cCodOrg + cCodGU6) )
    MsDocument(cTable , (cTable)->( Recno() ), 2)
EndIf
Return 

/* /{Protheus.doc} LoadMdlH68
Função responsavel pelo load do modelo da tabela H68.
@type Static Function
@author Eduardo Silva
@since 25/03/2024
@version 12.1.2310
/*/

Static Function LoadMdlH68(oModel)
Local aArea     := GetArea()
Local cOrgao    := ""
Local aRet      := {}
Local cAliasH68 := GetNextAlias() 
cOrgao := Posicione("GI2", 1, xFilial("GI2") + FwFldGet("GYN_LINCOD"),"GI2_ORGAO")
BeginSQL alias cAliasH68
    COLUMN H68_DTINI AS DATE
    COLUMN H68_DTFIM AS DATE
    COLUMN H68_DTMAX AS DATE
    COLUMN H68_VIAFRT AS LOGICAL
    COLUMN H68_VIAREG AS LOGICAL
    COLUMN H68_VIATUR AS LOGICAL
    SELECT H68_CODGI0, H68_CODG6U, H68_DTINI, H68_DTFIM, H68_DTMAX, H68_STATUS, H68_VIAFRT, H68_VIAREG, H68_VIATUR, H68.R_E_C_N_O_ RECNO
    FROM %TABLE:H68% H68
    WHERE H68.%NotDel%
        AND H68_FILIAL = %xFilial:H68%
        AND H68_CODGI0 = %Exp:cOrgao%
    ORDER BY H68_CODGI0, H68_CODG6U
EndSQL
aRet := FWLoadByAlias(oModel, cAliasH68, "H68")
(cAliasH68)->( dbCloseArea() )
RestArea(aArea)
Return aRet

/* /{Protheus.doc} LoadMdlGQE
Função responsavel pelo load do modelo da tabela GQE.
@type Static Function
@author Eduardo Silva
@since 25/03/2024
@version 12.1.2310
/*/

Static Function LoadMdlGQE(oModel)
Local aArea     := GetArea()
Local aRet      := {}
Local cAliasGQE := GetNextAlias()
Local cCodGYN   := FwFldGet("GYN_CODIGO")
GYN->( dbSetOrder(1) )  // GYN_FILIAL + GYN_CODIGO
If GYN->( dbSeek(xFilial("GYN") + cCodGYN) )
    cCodGID := GYN->GYN_CODGID
EndIf
BeginSQL alias cAliasGQE
    SELECT GQE_VIACOD, GQE_SEQ, GQE_TRECUR, GQE_TCOLAB, GQE_RECURS, GQE_STATUS, GQE_CANCEL, GQE_JUSTIF, GQE_ITEM, GQE_HRINTR, GQE_HRFNTR, GQE.R_E_C_N_O_ RECNO   // GQE_VIACOD, GQE_SEQ, GQE_TRECUR, GQE_TCOLAB, GQE_RECURS, GQE_STATUS, GQE_CANCEL, GQE_JUSTIF, GQE_ITEM
    FROM %TABLE:G55% G55
    INNER JOIN %TABLE:GQE% GQE
        ON GQE_FILIAL = GQE_FILIAL AND GQE_VIACOD = G55_CODVIA AND GQE_SEQ = G55_SEQ AND GQE.%NotDel%
    WHERE G55.%NotDel%
        AND G55_FILIAL = %xFilial:G55%
        AND G55_CODVIA = %Exp:cCodGYN% 
        AND G55_CODGID = %Exp:cCodGID% 
EndSQL
aRet := FWLoadByAlias(oModel, cAliasGQE, "GQE")
(cAliasGQE)->( dbCloseArea() )
RestArea(aArea)
Return aRet

/* /{Protheus.doc} LoadMdlG6W
Função responsavel pelo load do modelo da tabela G6W.
@type Static Function
@author Eduardo Silva
@since 25/03/2024
@version 12.1.2310
/*/

Static Function LoadMdlG6W(oModel)
Local aArea     := GetArea()
Local aRet      := {}
Local cAliasG6W := GetNextAlias()
Local cCodRec   := oModel:GetModel():GetValue('GQEDETAIL','GQE_RECURS')
BeginSql Alias cAliasG6W
    COLUMN G6W_DTINI AS DATE
    COLUMN G6W_DTFIM AS DATE
    COLUMN G6W_DTMAX AS DATE
    SELECT G6W_CODIGO, G6W_SEQ, G6W_CODG6U, G6W_DTINI, G6W_DTFIM, G6W_DTMAX, G6W_STATUS, G6W.R_E_C_N_O_ RECNO //  
    FROM %TABLE:G6V% G6V
    INNER JOIN %TABLE:G6W% G6W
    ON G6W_FILIAL = G6V_FILIAL AND G6W_CODIGO = G6V_CODIGO AND G6W.%NotDel%
    WHERE G6V.%NotDel%
        AND G6V_FILIAL = %xFilial:G6V%
        AND G6V_RECURS = %Exp:cCodRec%
    ORDER BY G6W_FILIAL, G6W_CODIGO, G6W_SEQ
EndSql
aRet := FWLoadByAlias(oModel, cAliasG6W, "G6W")
(cAliasG6W)->( dbCloseArea() )
RestArea(aArea)
Return aRet
