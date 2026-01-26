#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"
#Include "GTPA502.ch"

/*/{Protheus.doc} GTPA502
Função da Tela de Controle de Malotes.
@type  function Static
@author Eduardo Silva
@since  04/04/2024
@version 12.1.2310
/*/

Function GTPA502()
Local oBrowse
Local aNewFields   := {{'GIC','GIC_CODH7C'},{'G99','G99_CODH7C'},{'GQL','GQL_CODH7C'},;
                       {'H7C','H7C_RECCOD'},{'H7C','H7C_RECDAT'},{'H7C','H7C_RECOK'},;
                       {'H7D','H7D_CODH7C'},{'G57','G57_CODH7C'},{'GQW','GQW_CODH7C'},{'GZG','GZG_CODH7C'} }
Local nX           := 1


    For nX := 1 to Len(aNewFields)
        if &(aNewFields[nX][1])->(FieldPos(aNewFields[nX][2])) <= 0
            FwAlertHelp('Dicionário de dados desatualizado','Necessário atualizar dicionário de dados') //'Dicionário de dados desatualizado' //'Necessário atualizar dicionário de dados'
            Return Nil
        endif
    Next nX

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("H7C")
    oBrowse:SetDescription(STR0001)   // "Malotes"
    oBrowse:AddLegend("Empty(H7C_CODVIA)  .And. Empty(H7C_RECURS)  .And. Empty(H7C_RECCOD)"  , "RED" , "Nao Enviado")       // "Nao Enviado"
    oBrowse:AddLegend("!Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. Empty(H7C_RECCOD)"  , "YELLOW" , "Enviado")        // "Enviado"
    oBrowse:AddLegend("!Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. !Empty(H7C_RECCOD)" , "GREEN"  , "Recebido")       // "Recebido"
    oBrowse:Activate()
    oBrowse:Destroy()
    GTPDestroy(oBrowse)
Return Nil

/*/{Protheus.doc} MenuDef
Função para criação dos menus.
@type  Static MenuDef
@author Eduardo Silva
@since  04/04/2024
@version 12.1.2310
/*/

Static Function MenuDef()
Local aRot := {}
    ADD OPTION aRot TITLE STR0039   ACTION 'VIEWDEF.GTPA502' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0   // 'Visualizar'
    ADD OPTION aRot TITLE STR0040   ACTION 'VIEWDEF.GTPA502' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0   // 'Incluir'
    ADD OPTION aRot TITLE STR0041   ACTION 'VIEWDEF.GTPA502' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // 'Alterar'
    ADD OPTION aRot TITLE STR0042   ACTION 'VIEWDEF.GTPA502' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0   // 'Excluir'
    ADD OPTION aRot TITLE STR0043	ACTION 'GP502ECM()' 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // 'Enviar malote'
    ADD OPTION aRot TITLE STR0044	ACTION 'GTPA502A()' 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // 'Receber malote'
    ADD OPTION aRot TITLE STR0045   ACTION 'GP502REI()' 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // 'Reimprimir'
Return aRot


/*/{Protheus.doc} ModelDef
Função para criação do Modelo da Tela em MVC
@type  Static ModelDef
@author Eduardo Silva
@since  04/04/2024
@version 12.1.2310
/*/

Static Function ModelDef()
Local oStruH7C  := FWFormStruct( 1, "H7C")  // Malotes
Local oStruH7D  := FWFormStruct( 1, "H7D")  // Itens de Malote
Local oStruGIC  := FWFormStruct( 1, "GIC")  // Tabela de Bilhetes
Local oStruG57  := FWFormStruct( 1, "G57")  // Tabela de Taxas
Local oStruG99  := FWFormStruct( 1, "G99")  // Tabela de Conhecimento
Local oStruGQL  := FWFormStruct( 1, "GQL")  // Tabela de pos
Local oStruGQM  := FWFormStruct( 1, "GQM")  // Tabela de pos
Local oStruGQW  := FWFormStruct( 1, "GQW")  // Tabela de Requisição
Local oStruGZGD := FWFormStruct( 1, "GZG")  // Tabela de Receita e Despesa
Local oStruGZGE := FWFormStruct( 1, "GZG")  // Tabela de Receita e Despesa
Local bVldActivate := {|oModel| VldActivate(oModel)}
Local bCommit	   := {|oModel|TP502Grv(oModel)}
Local aModels      := {}
Local nCont        := 0
Local oModel

    // Criação dos campos Virtuais
    oStruH7C:AddField(FWX3Titulo("G55_DTPART"), FWX3Titulo("G55_DTPART"), "G55DTPART", "D", TamSX3("G55_DTPART")[1], 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField(FWX3Titulo("G55_HRINI") , FWX3Titulo("G55_HRINI") , "G55HRINI" , "C", TamSX3("G55_HRINI")[1] , 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField(FWX3Titulo("G55_LOCORI"), FWX3Titulo("G55_LOCORI"), "G55LOCORI", "C", TamSX3("G55_LOCORI")[1], 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField("Descrição Origem"      , "Descrição Origem"      , "G55DSCORI", "C",                      30, 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField(FWX3Titulo("G55_DTCHEG"), FWX3Titulo("G55_DTCHEG"), "G55DTCHEG", "D", TamSX3("G55_DTCHEG")[1], 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField(FWX3Titulo("G55_HRFIM") , FWX3Titulo("G55_HRFIM") , "G55HRFIM" , "C", TamSX3("G55_HRFIM")[1] , 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField(FWX3Titulo("G55_LOCDES"), FWX3Titulo("G55_LOCDES"), "G55LOCDES", "C", TamSX3("G55_LOCDES")[1], 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField("Descrição Destino"     , "Descrição Destino"     , "G55DSCDES", "C",                      30, 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField("Descrição Recurso"     , "Descrição Recurso"     , "GQEDSCREC", "C",                      40, 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruH7C:AddField("Descrição Veiculo"     , "Descrição Veiculo"     , "GQEDSCVEI", "C",                      40, 0, Nil, Nil, Nil, Nil, Nil, .F., .F., .T.)
    oStruGIC:AddField("" , "", "GIC_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, GIC->GIC_CODIGO, GIC->GIC_CODIGO),"","GIC")}, .F., .F., .T.)
    oStruG57:AddField("" , "", "G57_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, G57->G57_NUMMOV + G57->G57_SERIE + G57->G57_SUBSER + G57->G57_NUMCOM + G57->G57_CODIGO + G57->G57_TIPO, G57->G57_NUMMOV + G57->G57_SERIE + G57->G57_SUBSER + G57->G57_NUMCOM + G57->G57_CODIGO + G57->G57_TIPO), "", "G57")}, .F., .F., .T.)
    oStruG99:AddField("" , "", "G99_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, G99->G99_CODIGO, G99->G99_CODIGO),"","G99")}, .F., .F., .T.)
    oStruGQL:AddField("" , "", "GQL_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, GQL->GQL_CODIGO, GQL->GQL_CODIGO),"","GQL")}, .F., .F., .T.)
    oStruGQM:AddField("" , "", "GQM_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, GQM->GQM_CODGQL + GQM->GQM_CODNSU + GQM->GQM_CODAUT, GQM->GQM_CODGQL + GQM->GQM_CODNSU + GQM->GQM_CODAUT), "", "GQM")}, .F., .F., .T.)
    oStruGZGD:AddField("", "", "GZG2_ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, GZG->GZG_AGENCI + GZG->GZG_NUMFCH + GZG->GZG_SEQ + GZG->GZG_TIPO, GZG->GZG_AGENCI + GZG->GZG_NUMFCH + GZG->GZG_SEQ + GZG->GZG_TIPO), "", "GZG")}, .F., .F., .T.)
    oStruGZGE:AddField("", "", "GZG1_ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui, GZG->GZG_AGENCI + GZG->GZG_NUMFCH + GZG->GZG_SEQ + GZG->GZG_TIPO, GZG->GZG_AGENCI + GZG->GZG_NUMFCH + GZG->GZG_SEQ + GZG->GZG_TIPO), "", "GZG")}, .F., .F., .T.)
    oStruGQW:AddField("" , "", "GQW_ANEXO" , "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld(Iif( Inclui,  GQW->GQW_CODIGO, GQW->GQW_CODIGO),"","GQW")}, .F., .F., .T.)

    //recnos
    oStruGIC:AddField("" , "", "GIC_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruG57:AddField("" , "", "G57_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruG99:AddField("" , "", "G99_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruGQL:AddField("" , "", "GQL_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruGQW:AddField("" , "", "GQW_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruGZGD:AddField("" , "", "GZG_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)
    oStruGZGE:AddField("" , "", "GZG_RECNO" , "N", 15,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)


    // Gatilhos
    oStruH7C:AddTrigger('H7C_SEQ'    , 'H7C_SEQ'  , {||.T.}, {|oMdl,cField,uVal| G502Trigger(oMdl,cField,uVal)})
    oStruH7C:AddTrigger('H7C_RECURS' , 'H7C_RECURS' , {||.T.}, {|oMdl,cField,uVal| G502Trigger(oMdl,cField,uVal)})
    oStruH7D:AddTrigger('H7D_NUMFCH', 'H7D_NUMFCH', {||.T.}, {|oMdl,cField,uVal| G502Trigger(oMdl,cField,uVal)})

    // Desabilitando os campos do cabeçalho
    If IsInCallStack("GP502ECM")
        oStruH7C:SetProperty("*"         , MODEL_FIELD_WHEN, {|| .F.} )
        oStruH7C:SetProperty("H7C_CODVIA", MODEL_FIELD_WHEN, {|| .T.} )
        oStruH7C:SetProperty("H7C_SEQ"   , MODEL_FIELD_WHEN, {|| .T.} )
        oStruH7C:SetProperty("H7C_RECURS", MODEL_FIELD_WHEN, {|| .T.} )
        oStruH7C:SetProperty("H7C_VEICUL", MODEL_FIELD_WHEN, {|| .T.} )
        oStruH7D:SetProperty("*"         , MODEL_FIELD_WHEN, {|| .F.} )
        oStruH7C:SetProperty('H7C_CODVIA', MODEL_FIELD_OBRIGAT, .T.)
        oStruH7C:SetProperty('H7C_RECURS', MODEL_FIELD_OBRIGAT, .T.)
    Else
        // Desabilitando os campos das Grids
        
        oStruH7C:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruH7C:SetProperty("H7C_DESCRI"   , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGIC:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGIC:SetProperty("GIC_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruG57:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruG57:SetProperty("G57_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruG99:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruG99:SetProperty("G99_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGQL:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGQL:SetProperty("GQL_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGQM:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGQM:SetProperty("GQM_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGZGD:SetProperty("*"           , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGZGD:SetProperty("GZG2_ANEXO"  , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGZGE:SetProperty("*"           , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGZGE:SetProperty("GZG1_ANEXO"  , MODEL_FIELD_WHEN  , {|| .T.} )
        oStruGQW:SetProperty("*"            , MODEL_FIELD_WHEN  , {|| IsInCallStack("GP502GAT")} )
        oStruGQW:SetProperty("GQW_ANEXO"    , MODEL_FIELD_WHEN  , {|| .T.} )
        
    EndIf

    // Tirando a obrigatoriedade dos campos das Grids
    oStruGIC:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
    oStruG57:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
    oStruG99:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
    oStruGQL:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
    oStruGQM:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )
    oStruGZGD:SetProperty('*'   , MODEL_FIELD_OBRIGAT, .F. )
    oStruGZGE:SetProperty('*'   , MODEL_FIELD_OBRIGAT, .F. )
    oStruGQW:SetProperty('*'    , MODEL_FIELD_OBRIGAT, .F. )

    // Modelo de Dados
    oModel := MPFormModel():New( 'GTPA502', /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )
    oModel:AddFields('H7CMASTER',, oStruH7C )
    oModel:AddGrid('H7DDETAIL','H7CMASTER',oStruH7D,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    If IsInCallStack("GP502ECM")
        oModel:GetModel("H7DDETAIL"):SetOnlyQuery(.T.)
        oModel:GetModel("H7DDETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("H7DDETAIL"):SetOptional(.T.)
        oModel:GetModel("H7DDETAIL"):SetNoDeleteLine( .T. )
        oModel:GetModel("H7DDETAIL"):SetMaxLine(999999)
    EndIf
    oModel:AddGrid("GICDETAIL", "H7DDETAIL", oStruGIC,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GICDETAIL"):SetDescription("Bilhetes")     //"Bilhetes"
    oModel:AddGrid("G57DETAIL", "H7DDETAIL", oStruG57,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("G57DETAIL"):SetDescription("Taxas")        //"Taxas"
    oModel:AddGrid("G99DETAIL", "H7DDETAIL", oStruG99,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("G99DETAIL"):SetDescription("Conhecimento") //"Conhecimento"
    oModel:AddGrid("GQLDETAIL", "H7DDETAIL", oStruGQL,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GQLDETAIL"):SetDescription("Vendas POS")   //"Vendas POS"
    oModel:AddGrid("GQMDETAIL", "GQLDETAIL", oStruGQM,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GQMDETAIL"):SetDescription("Vendas POS")   //"Vendas POS"
    oModel:AddGrid("GZGDETAILE", "H7DDETAIL", oStruGZGE,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GZGDETAILE"):SetDescription("Receita")     //"Receita"
    oModel:AddGrid("GZGDETAILD", "H7DDETAIL", oStruGZGD,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GZGDETAILD"):SetDescription("Despesa")     //"Despesa"
    oModel:AddGrid("GQWDETAIL", "H7DDETAIL", oStruGQW,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:GetModel("GQWDETAIL"):SetDescription("Requisição")   //"Requisição"

    // Relacinando as tabelas
    oModel:SetRelation('H7DDETAIL', {{'H7D_FILIAL','xFilial("H7D")'},{'H7D_CODH7C','H7C_CODIGO'}},H7D->(IndexKey(1)))
    oModel:SetRelation('GICDETAIL', {{'GIC_FILIAL','xFilial("GIC")'},{'GIC_CODH7C','H7C_CODIGO'},{'GIC_AGENCI','H7D_AGENCI'},{'GIC_NUMFCH','H7D_NUMFCH'}},GIC->(IndexKey(11)))
    oModel:SetRelation('G57DETAIL', {{'G57_FILIAL','xFilial("G57")'},{'G57_CODH7C','H7C_CODIGO'},{'G57_CODGIC','GIC_CODIGO'},{'G57_AGENCI','H7D_AGENCI'},{'G57_NUMFCH','H7D_NUMFCH'}},G57->(IndexKey(6)))
    oModel:SetRelation('G99DETAIL', {{'G99_FILIAL','xFilial("G59")'},{'G99_CODH7C','H7C_CODIGO'},{'G99_CODEMI','H7D_AGENCI'},{'G99_NUMFCH','H7D_NUMFCH'}},G99->(IndexKey(7)))
    oModel:SetRelation('GQLDETAIL', {{'GQL_FILIAL','xFilial("GQL")'},{'GQL_CODH7C','H7C_CODIGO'},{'GQL_CODAGE','H7D_AGENCI'},{'GQL_NUMFCH','H7D_NUMFCH'}},GQL->(IndexKey(5)))
    oModel:SetRelation('GQMDETAIL', {{'GQM_FILIAL','xFilial("GQM")'},{'GQM_CODGQL','GQL_CODIGO'}})
    oModel:SetRelation('GQWDETAIL', {{'GQW_FILIAL','xFilial("GQW")'},{'GQW_CODH7C','H7C_CODIGO'},{'GQW_CODAGE','H7D_AGENCI'},{'GQW_NUMFCH','H7D_NUMFCH'}},GQW->(IndexKey(6)))
    oModel:SetRelation('GZGDETAILE',{{'GZG_FILIAL','xFilial("GZG")'},{'GZG_CODH7C','H7C_CODIGO'},{'GZG_AGENCI','H7D_AGENCI'},{'GZG_NUMFCH','H7D_NUMFCH'}},GZG->(IndexKey(3)))
    oModel:SetRelation('GZGDETAILD',{{'GZG_FILIAL','xFilial("GZG")'},{'GZG_CODH7C','H7C_CODIGO'},{'GZG_AGENCI','H7D_AGENCI'},{'GZG_NUMFCH','H7D_NUMFCH'}},GZG->(IndexKey(3)))
    oModel:GetModel("GZGDETAILE"):SetLoadFilter(,"GZG_TIPO = '1'")
    oModel:GetModel("GZGDETAILD"):SetLoadFilter(,"GZG_TIPO = '2'")


    If GQW->(FieldPos('GQW_NUMFCH')) > 0 
        oModel:SetRelation('GQWDETAIL',{{'GQW_FILIAL','xFilial("GQW")'},{'GQW_CODH7C','H7C_CODIGO'},{'GQW_CODAGE','H7D_AGENCI'},{'GQW_NUMFCH','H7D_NUMFCH'}},GQW->(IndexKey(6)))
    EndIf

    oModel:GetModel('H7DDETAIL'):SetUniqueLine( {'H7D_CODG6X'})    // Este campo não pode se repetir
    oModel:SetDescription(STR0002)                                 // "Controle de Malotes"
    oModel:GetModel('H7CMASTER'):SetDescription(STR0003)           // "Cabeçalho do Malote"
    oModel:GetModel('H7DDETAIL'):SetDescription(STR0004)           // "Itens do Malote"
    oModel:SetVldActivate(bVldActivate)

    //Feito um laço pois não mudaria as propriedades para os modelos
    aModels := {"GICDETAIL","G57DETAIL","G99DETAIL","GQLDETAIL","GQMDETAIL","GZGDETAILE","GZGDETAILD","GQWDETAIL"}
    For nCont := 1 To Len(aModels)
        oModel:GetModel(aModels[nCont]):SetOnlyQuery(.T.)
        oModel:GetModel(aModels[nCont]):SetNoInsertLine(.T.)
        oModel:GetModel(aModels[nCont]):SetNoUpdateLine(.F.)
        oModel:GetModel(aModels[nCont]):SetOptional(.T.)
        oModel:GetModel(aModels[nCont]):SetNoDeleteLine(.T.)
        oModel:GetModel(aModels[nCont]):SetMaxLine(999999)
    Next nCont
    oModel:SetActivate( {|oModel| Initially(oModel) } )
Return oModel




/*/{Protheus.doc} ViewDef
Função para criação da View em MVC
@type  Static ViewDef
@author Eduardo Silva
@since  04/04/2024
@version 12.1.2310
/*/

Static Function ViewDef()
Local oModel     := FWLoadModel( 'GTPA502' )   
Local oView
Local oStH7CPrin := FWFormStruct(2, "H7C", { |x| AllTrim(x) $ "H7C_CODIGO|H7C_DESCRI|H7C_STATUS" })
Local oStH7CSecu := FWFormStruct(2, "H7C", { |x| AllTrim(x) $ "H7C_CODVIA|H7C_SEQ|G55DTPART|G55HRINI|G55LOCORI|G55DSCORI|G55DTCHEG|G55HRFIM|G55LOCDES|G55DSCDES|H7C_RECURS|H7C_VEICUL" }) 
Local oStruH7D  := FWFormStruct(2, 'H7D')
Local oStruGIC  := FWFormStruct(2, 'GIC', { |x| AllTrim(x) + "|" $  "GIC_CODIGO|GIC_BILHET|GIC_LOCORI|GIC_LOCDES|GIC_HORA|GIC_LINHA|GIC_TIPO|GIC_AGENCI|GIC_NUMFCH|"+;
                                                                    "GIC_DTVEND|GIC_TAR|GIC_TAX|GIC_PED|GIC_SGFACU|GIC_OUTTOT|GIC_VALTOT|GIC_VLACER|GIC_SERIE|GIC_SUBSER|"+;
                                                                    "GIC_NUMCOM|GIC_CONFER|" })
Local oStruG57  := FWFormStruct(2, "G57", { |x| AllTrim(x) + "|" $  "G57_CODIGO|G57_DESCRI|G57_SERIE|G57_SUBSER|G57_NUMCOM|G57_EMISSA|G57_VALOR|G57_TIPO|G57_VALACE|"+;
                                                                    "G57_NUMMOV|G57_CONFER|" })
Local oStruG99  := FWFormStruct(2, "G99")
Local oStruGQW  := FWFormStruct(2, "GQW")
Local oStruGQM  := FWFormStruct(2, "GQM")
Local oStruGQL  := FWFormStruct(2, "GQL")
Local oStruGZGD := FWFormStruct(2, "GZG")
Local oStruGZGE := FWFormStruct(2, "GZG")
Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

    // Remove os campos da View
    oStruH7D:RemoveField( "H7D_CODIGO" )
    oStruH7D:RemoveField( "H7D_CODH7C" )

    // Cria os campos Virtuais
    oStH7CSecu:AddField("G55DTPART" ,"06",FWX3Titulo("G55_DTPART"),FWX3Titulo("G55_DTPART"),{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Data Partida"
    oStH7CSecu:AddField("G55HRINI"  ,"07",FWX3Titulo("G55_HRINI") ,FWX3Titulo("G55_HRINI") ,{""},"GET","@R 99:99",Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Hora Inicio"
    oStH7CSecu:AddField("G55LOCORI" ,"08",FWX3Titulo("G55_LOCORI"),FWX3Titulo("G55_LOCORI"),{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Local Origem"
    oStH7CSecu:AddField("G55DSCORI" ,"09",STR0050                 ,STR0050                 ,{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Descrição Origem"
    oStH7CSecu:AddField("G55DTCHEG" ,"10",FWX3Titulo("G55_DTCHEG"),FWX3Titulo("G55_DTCHEG"),{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Data Chegada"
    oStH7CSecu:AddField("G55HRFIM"  ,"11",FWX3Titulo("G55_HRFIM") ,FWX3Titulo("G55_HRFIM") ,{""},"GET","@R 99:99",Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Hora Fim"
    oStH7CSecu:AddField("G55LOCDES" ,"12",FWX3Titulo("G55_LOCDES"),FWX3Titulo("G55_LOCDES"),{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Local Destino"
    oStH7CSecu:AddField("G55DSCDES" ,"13",STR0047                 ,STR0047                 ,{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Descrição Destino"
    oStH7CSecu:AddField("GQEDSCREC" ,"15",STR0048                 ,STR0048                 ,{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Nome Motorista"
    oStH7CSecu:AddField("GQEDSCVEI" ,"17",STR0049                 ,STR0049                 ,{""},"GET",""        ,Nil,"",.F.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Nome Veiculo"
    oStruGIC:AddField("GIC_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruG57:AddField("G57_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruG99:AddField("G99_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruGQL:AddField("GQL_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruGQM:AddField("GQM_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruGZGE:AddField("GZG1_ANEXO" ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruGZGD:AddField("GZG2_ANEXO" ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStruGQW:AddField("GQW_ANEXO"   ,"01",STR0046                 ,STR0046                 ,{""},"GET","@BMP"    ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"

    //recnos
    oStruGIC:AddField("GIC_RECNO"   ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruG57:AddField("G57_RECNO"   ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruG99:AddField("G99_RECNO"   ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruGQL:AddField("GQL_RECNO"   ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruGQW:AddField("GQW_RECNO"   ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruGZGD:AddField("GZG_RECNO"  ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"
    oStruGZGE:AddField("GZG_RECNO"  ,"60",STR0051                 ,STR0051                 ,{""},"GET",""        ,Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Recno"

    // Ordenacao dos campos
    oStH7CSecu:SetProperty("H7C_RECURS"	,MVC_VIEW_ORDEM		, '14' )
    oStH7CSecu:SetProperty("GQEDSCREC"	,MVC_VIEW_ORDEM		, '15' )
    oStH7CSecu:SetProperty("H7C_VEICUL"	,MVC_VIEW_ORDEM		, '16' )
    oStH7CSecu:SetProperty("GQEDSCVEI"	,MVC_VIEW_ORDEM		, '17' )

    // Modelo da View
    oView := FWFormView():New()
    oView:SetModel(oModel)

    // Grupo 01
    oStH7CSecu:AddGroup( 'GRUPO01', 'Viagem', '', 2 )
    oStH7CSecu:SetProperty( 'H7C_CODVIA', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStH7CSecu:SetProperty( 'H7C_SEQ'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

    // Grupo 02
    oStH7CSecu:AddGroup( 'GRUPO02', 'Itinerarios', '', 2 )
    oStH7CSecu:SetProperty( 'G55DTPART' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55HRINI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55LOCORI' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55DSCORI' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55DTCHEG' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55HRFIM'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55LOCDES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStH7CSecu:SetProperty( 'G55DSCDES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

    // Grupo 03
    oStH7CSecu:AddGroup( 'GRUPO03', 'Recurso', '', 2 )
    oStH7CSecu:SetProperty( 'H7C_RECURS', MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
    oStH7CSecu:SetProperty( 'GQEDSCREC' , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

    // Grupo 04
    oStH7CSecu:AddGroup( 'GRUPO04', 'Veiculo', '', 2 )
    oStH7CSecu:SetProperty( 'H7C_VEICUL', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
    oStH7CSecu:SetProperty( 'GQEDSCVEI' , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
    oView:AddField("VIEW_H7CPRIN", oStH7CPrin, "H7CMASTER")
    oView:AddField("VIEW_H7CSECU", oStH7CSecu, "H7CMASTER")
    oView:AddGrid('VIEW_H7D',  oStruH7D , 'H7DDETAIL' )
    oView:AddGrid("VIEW_GIC",  oStruGIC,  "GICDETAIL" )
    oView:AddGrid("VIEW_G57",  oStruG57,  "G57DETAIL" )
    oView:AddGrid("VIEW_G99",  oStruG99,  "G99DETAIL" )
    oView:AddGrid("VIEW_GQL",  oStruGQL,  "GQLDETAIL" )
    oView:AddGrid("VIEW_GQM",  oStruGQM,  "GQMDETAIL" )
    oView:AddGrid("VIEW_GZGE", oStruGZGE, "GZGDETAILE")
    oView:AddGrid("VIEW_GZGD", oStruGZGD, "GZGDETAILD")
    oView:AddGrid("VIEW_GQW",  oStruGQW,  "GQWDETAIL" )

    // Cria o Double Click
    oView:SetViewProperty("VIEW_GIC", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_G57", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_G99", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_GQL", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_GQM", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_GZGE", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_GZGD", "GRIDDOUBLECLICK", bDblClick)
    oView:SetViewProperty("VIEW_GQW", "GRIDDOUBLECLICK", bDblClick)

    //Cria a View Horizontal
    oView:CreateHorizontalBox('SUPERIOR'  , 30)
    oView:CreateHorizontalBox('INFERIORA' , 30)
    oView:CreateHorizontalBox('INFERIORB' , 40)

    //Cria o controle de Abas
    oView:CreateFolder( 'FOLDER', 'SUPERIOR')
    oView:AddSheet('FOLDER','VIEW_H7CPRIN', STR0005)        //"Dados do Malote"
    oView:AddSheet('FOLDER','VIEW_H7CSECU', STR0006)        //"Transporte de Malotes"

    //Cria os Box que serão vinculados as abas
    oView:CreateHorizontalBox( 'MALOTE', 100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'VIEW_H7CPRIN')
    oView:CreateHorizontalBox( 'TRANSP', 100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'VIEW_H7CSECU')

    //Cria o controle de Abas
    oView:CreateFolder( 'FOLDER2', 'INFERIORB')
    oView:AddSheet('FOLDER2','SHEET1', STR0007)             //"Bilhetes"
    oView:AddSheet('FOLDER2','SHEET2', STR0008)             //"Taxas"
    oView:AddSheet('FOLDER2','SHEET3', STR0009)             //"Conhecimento"
    oView:AddSheet('FOLDER2','SHEET5', STR0010)             //"Vendas POS"
    oView:AddSheet('FOLDER2','SHEET4', STR0011)             //"Receita/Despesa"
    oView:AddSheet('FOLDER2','SHEET6', STR0012)             //"Requisições"

    // Cria os Box na Horizontal
    oView:CreateHorizontalBox( 'BOX1', 100, , , 'FOLDER2', 'SHEET1')
    oView:CreateHorizontalBox( 'BOX2', 100, , , 'FOLDER2', 'SHEET2')
    oView:CreateHorizontalBox( 'BOX3', 100, , , 'FOLDER2', 'SHEET3')

    // Cria os Box na Vertical
    oView:CreateVerticalBox( 'BOX1ESQ', 50, , , 'FOLDER2', 'SHEET5') // Box de Receitas
    oView:CreateVerticalBox( 'BOX1DIR', 50, , , 'FOLDER2', 'SHEET5') // Box de Despesas
    oView:CreateVerticalBox( 'BOX2ESQ', 50, , , 'FOLDER2', 'SHEET4') // Box de Receitas
    oView:CreateVerticalBox( 'BOX2DIR', 50, , , 'FOLDER2', 'SHEET4') // Box de Despesas
    oView:CreateHorizontalBox( 'BOX5', 100, , , 'FOLDER2', 'SHEET6')

    // Incrementa o item da grid
    oView:AddIncrementalField('VIEW_H7D','H7D_ITEM')

    //Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView('VIEW_H7CPRIN' , 'MALOTE')
    oView:SetOwnerView('VIEW_H7CSECU' , 'TRANSP')
    oView:SetOwnerView('VIEW_H7D' , 'INFERIORA')
    oView:SetOwnerView("VIEW_GIC" , "BOX1")
    oView:SetOwnerView("VIEW_G57" , "BOX2")
    oView:SetOwnerView("VIEW_G99" , "BOX3")
    oView:SetOwnerView("VIEW_GQM" , "BOX1DIR")
    oView:SetOwnerView("VIEW_GQL" , "BOX1ESQ")
    oView:SetOwnerView("VIEW_GZGE", "BOX2DIR")
    oView:SetOwnerView("VIEW_GZGD", "BOX2ESQ")
    oView:SetOwnerView("VIEW_GQW" , "BOX5")

    // Descrição dos titulos da Tela
    //oView:EnableTitleView('VIEW_H7C', "Cabeçalho do Malote")      // "Cabeçalho do Malote"
    oView:EnableTitleView('VIEW_H7D'    , STR0013)      // "Itens do Malote (Fichas)"
    oView:EnableTitleView('VIEW_GZGE'   , STR0014)      // "Receitas"
    oView:EnableTitleView('VIEW_GZGD'   , STR0015)      // "Despesas"
    oView:EnableTitleView('VIEW_GQM'    , STR0016)      // "Itens Vendas POS"
    oView:EnableTitleView('VIEW_GQL'    , STR0017)      // "Vendas POS"
    oView:SetAfterViewActivate( { || AfterActiv(oView)})
Return oView


/*/{Protheus.doc} G502Trigger
Função responsavel pelo gatilho do campo G6X_CODIGO carregando os campos virtuais (AGENCIA, NUMFICHA).
@type function
@author Eduardo Silva
@since 04/04/2024
@version 12.1.2310
/*/

Static Function G502Trigger(oMdl,cField,uVal)
Local oView     := FwViewActive()
Local lNumFch   := .F.
    Do Case
        Case cField == "H7C_SEQ"
            G55->( dbSetOrder(4) )   // G55_FILIAL + G55_CODVIA + G55_SEQ
            If G55->( dbSeek(xFilial("G55") + oMdl:GetValue("H7C_CODVIA") + oMdl:GetValue("H7C_SEQ")) )
                oMdl:LoadValue('G55DTPART',G55->G55_DTPART)
                oMdl:LoadValue('G55HRINI' ,Alltrim(G55->G55_HRINI))
                oMdl:LoadValue('G55LOCORI',Alltrim(G55->G55_LOCORI))
                oMdl:LoadValue('G55DSCORI',Alltrim(Posicione("GI1", 1, xFilial("GI1") + G55->G55_LOCORI, "GI1_DESCRI")))
                oMdl:LoadValue('G55DTCHEG',G55->G55_DTCHEG)
                oMdl:LoadValue('G55HRFIM' ,Alltrim(G55->G55_HRFIM))
                oMdl:LoadValue('G55LOCDES',Alltrim(G55->G55_LOCDES))
                oMdl:LoadValue('G55DSCDES',Alltrim(Posicione("GI1", 1, xFilial("GI1") + G55->G55_LOCDES, "GI1_DESCRI")))
                GQE->( dbSetOrder(1) )  // GQE_FILIAL, GQE_VIACOD, GQE_SEQ, GQE_TRECUR, GQE_RECURS, R_E_C_N_O_, D_E_L_E_T_
                If GQE->( dbSeek(xFilial("GQE") + G55->G55_CODVIA + G55->G55_SEQ) )
                    While GQE->( !Eof() ) .And. GQE->GQE_VIACOD + GQE->GQE_SEQ == G55->G55_CODVIA + G55->G55_SEQ
                        If GQE->GQE_TRECUR == "1"
                            oMdl:LoadValue('H7C_RECURS',GQE->GQE_RECURS)
                            oMdl:LoadValue('GQEDSCREC',Alltrim(Posicione("GYG", 1, xFilial("GYG") + GQE->GQE_RECURS, "GYG_NOME")))
                        ElseIf GQE->GQE_TRECUR == "2"
                            oMdl:LoadValue('H7C_VEICUL',GQE->GQE_RECURS)
                            oMdl:LoadValue('GQEDSCVEI',Alltrim(Posicione("ST9", 1, xFilial("ST9") + GQE->GQE_RECURS, "T9_NOME")))
                        EndIf
                        GQE->( dbSkip() )
                    EndDo
                EndIf

            EndIf
        Case cField == "H7D_NUMFCH"
            If !Empty(oMdl:GetValue("H7D_NUMFCH"))
                lNumFch := .T.
            EndIf
        Case cField == "H7C_RECURS"
            oMdl:LoadValue('GQEDSCREC',Alltrim(Posicione("GYG", 1, xFilial("GYG") + oMdl:GetValue("H7C_RECURS"), "GYG_NOME")))
    EndCase
    If !IsBlind() .And. ValType(oView) == "O" .And. oView:IsActive()
        oView:Refresh()
        If lNumFch
            GP502ABAS(oMdl:GetValue("H7D_AGENCI"), oMdl:GetValue("H7D_NUMFCH"), oView, oView:GetModel():GetModel('H7CMASTER'):GetValue('H7C_CODIGO'))
        EndIf
    EndIf
    // Bloqueio de inclusao e exclusao das Views
    oView:SetNoDeleteLine('VIEW_GIC')
    oView:SetNoInsertLine('VIEW_GIC')
    oView:SetNoDeleteLine('VIEW_G57')
    oView:SetNoInsertLine('VIEW_G57')
    oView:SetNoDeleteLine('VIEW_G99')
    oView:SetNoInsertLine('VIEW_G99')
    oView:SetNoDeleteLine('VIEW_GQL')
    oView:SetNoInsertLine('VIEW_GQL')
    oView:SetNoDeleteLine('VIEW_GQM')
    oView:SetNoInsertLine('VIEW_GQM')
    oView:SetNoDeleteLine('VIEW_GZGD')
    oView:SetNoInsertLine('VIEW_GZGD')
    oView:SetNoDeleteLine('VIEW_GZGE')
    oView:SetNoInsertLine('VIEW_GZGE')
    oView:SetNoDeleteLine('VIEW_GQW')
    oView:SetNoInsertLine('VIEW_GQW')
Return uVal




/*/{Protheus.doc} GP502ABAS
Função responsavel pelo carregamento das informações das Grids das Abas.
@type function
@author Eduardo Silva
@since 04/04/2024
@version 12.1.2310
/*/

Static Function GP502ABAS(cAgencia, cNumFich, oView, cCodH7c)
Local oModel    := FwModelActive()
Local oGridGIC  := oModel:GetModel('GICDETAIL')
Local oGridG57  := oModel:GetModel('G57DETAIL')
Local oGridG99  := oModel:GetModel("G99DETAIL")
Local oGridGQL  := oModel:GetModel("GQLDETAIL")
Local oGridGQM  := oModel:GetModel("GQMDETAIL")
Local oGridDGZG := oModel:GetModel("GZGDETAILD")
Local oGridEGZG := oModel:GetModel("GZGDETAILE")
Local oGridGQW  := oModel:GetModel("GQWDETAIL")
Local cAliasGIC := GetNextAlias()
Local cAliasG57 := GetNextAlias()
Local cAliasG99 := GetNextAlias()
Local cAliasGQL := GetNextAlias()
Local cAliasGQM := GetNextAlias()
Local cAliasGZGD := GetNextAlias()
Local cAliasGZGE := GetNextAlias()
Local cAliasGQW := GetNextAlias()
Local dIni      := Date()
Local dFim      := Date()
Local nOperacao := oModel:GetModel("H7CMASTER"):GetOperation()

If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE
    // Bilhetes
    BeginSQL alias cAliasGIC
        SELECT
            GIC.GIC_CODIGO, GIC.GIC_BILHET, GIC_LOCORI , GIC_LOCDES    , GIC_HORA      , GIC_LINHA     , GIC.GIC_TIPO  , GIC_AGENCI   , GIC_NUMFCH    , GIC.GIC_DTVEND,
            GIC.GIC_TAR   , GIC.GIC_TAX   , GIC.GIC_PED, GIC.GIC_SGFACU, GIC.GIC_OUTTOT, GIC.GIC_VALTOT, GIC.GIC_VLACER, GIC.GIC_SERIE, GIC.GIC_SUBSER, GIC.GIC_NUMCOM,
            GIC.GIC_CONFER, GIC.R_E_C_N_O_ AS GIC_RECNO, GIC.GIC_CODH7C
        FROM
            %TABLE:GIC% GIC
        WHERE GIC.%NotDel%
            AND GIC_FILIAL = %xFilial:GIC%
            AND GIC_AGENCI = %Exp:cAgencia%
            AND GIC_NUMFCH = %Exp:cNumFich%
    EndSQL

    If nOperacao==MODEL_OPERATION_UPDATE
        GP502ALT(oModel, oModel:GetModel("GICDETAIL"):cid)
    EndIf
    
    While (cAliasGIC)->( !Eof() )
        If !Empty(oGridGIC:GetValue('GIC_BILHET')) .And. ! (oGridGIC:SeekLine({{"GIC_RECNO", (cAliasGIC)->GIC_RECNO }}))
            oGridGIC:SetNoInsertLine(.F.)
            oGridGIC:AddLine()
        EndIf
        oGridGIC:LoadValue("GIC_CODIGO",	(cAliasGIC)->GIC_CODIGO)
        oGridGIC:LoadValue("GIC_BILHET",	(cAliasGIC)->GIC_BILHET)
        oGridGIC:LoadValue("GIC_LOCORI",	(cAliasGIC)->GIC_LOCORI)
        oGridGIC:LoadValue("GIC_LOCDES",	(cAliasGIC)->GIC_LOCDES)
        oGridGIC:LoadValue("GIC_HORA"  ,    (cAliasGIC)->GIC_HORA)
        oGridGIC:LoadValue("GIC_LINHA" ,    (cAliasGIC)->GIC_LINHA)
        oGridGIC:LoadValue("GIC_TIPO"  ,	(cAliasGIC)->GIC_TIPO)
        oGridGIC:LoadValue("GIC_DTVEND",	StoD((cAliasGIC)->GIC_DTVEND))
        oGridGIC:LoadValue("GIC_TAR"   , 	(cAliasGIC)->GIC_TAR)
        oGridGIC:LoadValue("GIC_TAX"   ,	(cAliasGIC)->GIC_TAX)
        oGridGIC:LoadValue("GIC_PED"   ,	(cAliasGIC)->GIC_PED)
        oGridGIC:LoadValue("GIC_AGENCI",    (cAliasGIC)->GIC_AGENCI)
        oGridGIC:LoadValue("GIC_NUMFCH",    (cAliasGIC)->GIC_NUMFCH)
        oGridGIC:LoadValue("GIC_SGFACU",	(cAliasGIC)->GIC_SGFACU)
        oGridGIC:LoadValue("GIC_OUTTOT",	(cAliasGIC)->GIC_OUTTOT)
        oGridGIC:LoadValue("GIC_VALTOT",	(cAliasGIC)->GIC_VALTOT)
        oGridGIC:LoadValue("GIC_VLACER",	(cAliasGIC)->GIC_VLACER)
        oGridGIC:LoadValue("GIC_SERIE" ,	(cAliasGIC)->GIC_SERIE)
        oGridGIC:LoadValue("GIC_SUBSER",	(cAliasGIC)->GIC_SUBSER)
        oGridGIC:LoadValue("GIC_NUMCOM",	(cAliasGIC)->GIC_NUMCOM)
        oGridGIC:LoadValue("GIC_CONFER",	(cAliasGIC)->GIC_CONFER)
        oGridGIC:LoadValue("GIC_RECNO" ,	(cAliasGIC)->GIC_RECNO)
        oGridGIC:LoadValue("GIC_CODH7C" ,	(cAliasGIC)->GIC_CODH7C)
        (cAliasGIC)->( dbSkip() )
    EndDo
    (cAliasGIC)->( dbCloseArea() )
    oGridGIC:GoLine(1)


    // Taxas
    BeginSql Alias cAliasG57
        SELECT 
            G57.G57_CODIGO, G57.G57_DESCRI, G57.G57_SERIE, G57.G57_SUBSER, G57.G57_NUMCOM,
            G57.G57_EMISSA, G57.G57_VALOR , G57.G57_TIPO , G57.G57_VALACE, G57.G57_NUMMOV,
            G57.G57_CONFER, G57.R_E_C_N_O_ AS G57_RECNO, G57.G57_CODH7C
        FROM 
            %Table:G57% G57
        WHERE G57.%NotDel%
            AND G57.G57_FILIAL = %xFilial:G57%
            AND G57.G57_AGENCI = %Exp:cAgencia%
            AND G57.G57_NUMFCH = %Exp:cNumFich%
    EndSql
    If nOperacao==MODEL_OPERATION_UPDATE
        GP502ALT(oModel, oModel:GetModel("G57DETAIL"):cid)
    EndIf
    
    While (cAliasG57)->( !Eof() )
        If !Empty(oGridG57:GetValue('G57_TIPO')) .And. ! (oGridG57:SeekLine({{"G57_RECNO", (cAliasG57)->G57_RECNO }}))
            oGridG57:SetNoInsertLine(.F.)
            oGridG57:AddLine()
        EndIf
        oGridG57:LoadValue("G57_CODIGO", (cAliasG57)->G57_CODIGO)
        oGridG57:LoadValue("G57_DESCRI", (cAliasG57)->G57_DESCRI)
        oGridG57:LoadValue("G57_SERIE" , (cAliasG57)->G57_SERIE)
        oGridG57:LoadValue("G57_SUBSER", (cAliasG57)->G57_SUBSER)
        oGridG57:LoadValue("G57_NUMCOM", (cAliasG57)->G57_NUMCOM)
        oGridG57:LoadValue("G57_EMISSA", StoD((cAliasG57)->G57_EMISSA))
        oGridG57:LoadValue("G57_VALOR" , (cAliasG57)->G57_VALOR)
        oGridG57:LoadValue("G57_TIPO"  , (cAliasG57)->G57_TIPO)
        oGridG57:LoadValue("G57_VALACE", (cAliasG57)->G57_VALACE)
        oGridG57:LoadValue("G57_NUMMOV", (cAliasG57)->G57_NUMMOV)
        oGridG57:LoadValue("G57_CONFER", (cAliasG57)->G57_CONFER)
        oGridG57:LoadValue("G57_RECNO" , (cAliasG57)->G57_RECNO)
        oGridG57:LoadValue("G57_CODH7C", (cAliasG57)->G57_CODH7C)
        (cAliasG57)->( dbSkip() )
    EndDo
    (cAliasG57)->( dbCloseArea() )
    oGridG57:GoLine(1)


    // Conhecimento
    If ChkFile("G99") .And. G99->( FieldPos( "G99_VALACE" ) ) > 0 .And. G99->( FieldPos( "G99_CONFER" ) ) > 0
        BeginSql Alias cAliasG99    
            SELECT
                G99_CODIGO, G99_SERIE , G99_NUMDOC, G99_DTEMIS, G99_HREMIS, G99_KMFRET,
                G99_VALOR , G99_TIPCTE, G99_STAENC, G99_STATRA, G99_CONFER, G99_VALACE, G99.R_E_C_N_O_ AS G99_RECNO, G99.G99_CODH7C
            FROM
                %Table:G99% G99
            WHERE G99.%NotDel%
                AND G99.G99_FILIAL = %xFilial:G99%
                AND ( (G99.G99_CODEMI = %Exp:cAgencia% AND G99.G99_TOMADO = '0') OR (G99.G99_CODREC = %Exp:cAgencia% AND G99.G99_TOMADO = '3' AND G99_STAENC = '5') )
                AND ( (G99.G99_DTEMIS BETWEEN  %Exp:dIni% AND %Exp:dFim% AND G99.G99_NUMFCH = ' ') OR G99.G99_NUMFCH = %Exp:cNumFich% )
                AND G99.G99_STATRA = '2'
                AND G99_TIPCTE != '2' 
                AND G99_COMPLM != 'I'
        EndSql
        If nOperacao==MODEL_OPERATION_UPDATE
            GP502ALT(oModel, oModel:GetModel("G99DETAIL"):cid)
        EndIf
        
        While (cAliasG99)->( !Eof() )
            If !Empty(oGridG99:GetValue('G99_CODIGO')) .And. ! (oGridG99:SeekLine({{"G99_RECNO", (cAliasG99)->G99_RECNO }}))
                oGridG99:SetNoInsertLine(.F.)
                oGridG99:AddLine()
            EndIf
            oGridG99:LoadValue("G99_CODIGO", (cAliasG99)->G99_CODIGO)
            oGridG99:LoadValue("G99_SERIE" , (cAliasG99)->G99_SERIE)
            oGridG99:LoadValue("G99_NUMDOC", (cAliasG99)->G99_NUMDOC)
            oGridG99:LoadValue("G99_HREMIS", (cAliasG99)->G99_HREMIS)
            oGridG99:LoadValue("G99_KMFRET", (cAliasG99)->G99_KMFRET)
            oGridG99:LoadValue("G99_VALOR" , (cAliasG99)->G99_VALOR)
            oGridG99:LoadValue("G99_TIPCTE", (cAliasG99)->G99_TIPCTE)
            oGridG99:LoadValue("G99_STAENC", (cAliasG99)->G99_STAENC)
            oGridG99:LoadValue("G99_STATRA", (cAliasG99)->G99_STATRA)
            oGridG99:LoadValue("G99_CONFER", (cAliasG99)->G99_CONFER)
            oGridG99:LoadValue("G99_VALACE", (cAliasG99)->G99_VALACE)
            oGridG99:LoadValue("G99_DTEMIS", StoD((cAliasG99)->G99_DTEMIS))            
            oGridG99:LoadValue("G99_RECNO" , (cAliasG99)->G99_RECNO)
            oGridG99:LoadValue("G99_CODH7C", (cAliasG99)->G99_CODH7C)
            (cAliasG99)->( dbSkip() )
        EndDo
        (cAliasG99)->( dbCloseArea() )
        oGridG99:GoLine(1)
    EndIf


    // Venda Pos
    If ChkFile("GQM") .And. GQM->(FieldPos("GQM_CONFER")) > 0 .And. GQM->(FieldPos("GQM_VLACER")) > 0
        BeginSql Alias cAliasGQL
            SELECT
                GQL.GQL_DTMOVI, GQL.GQL_TPDDOC, GQL.GQL_NUMFCH, GQL.GQL_DTVEND, GQL.GQL_CODLAN, GQL.GQL_VLRTOT,
                GQL.GQL_FILIAL, GQL.GQL_CODAGE, GQL.GQL_CODIGO, GQL.GQL_CODADM, GQL.GQL_IDECNT, GQL.GQL_TPVEND, GQL.R_E_C_N_O_ AS GQL_RECNO, 
                GQL.GQL_CODH7C
            FROM
                %Table:GQL% GQL
            WHERE GQL.%NotDel%
                AND GQL.GQL_FILIAL = %xFilial:GQL% 
                AND GQL.GQL_CODAGE = %Exp:cAgencia%
                AND GQL.GQL_NUMFCH = %Exp:cNumFich%               
        EndSql
        If nOperacao==MODEL_OPERATION_UPDATE
            GP502ALT(oModel, oModel:GetModel("GQLDETAIL"):cid)
        EndIf
        
        While (cAliasGQL)->( !Eof() )
            If !Empty(oGridGQL:GetValue('GQL_CODAGE')) .And. ! (oGridGQL:SeekLine({{"GQL_RECNO", (cAliasGQL)->GQL_RECNO }}))
                oGridGQL:SetNoInsertLine(.F.)
                oGridGQL:AddLine()
            EndIf
            oGridGQL:LoadValue('GQL_DTMOVI', StoD((cAliasGQL)->GQL_DTMOVI))
            oGridGQL:LoadValue('GQL_TPDDOC', (cAliasGQL)->GQL_TPDDOC)
            oGridGQL:LoadValue('GQL_DESDOC', Posicione("GYA", 1, xFilial("GYA") + (cAliasGQL)->GQL_TPDDOC, "GYA_DESCRI"))
            oGridGQL:LoadValue('GQL_NUMFCH', (cAliasGQL)->GQL_NUMFCH)
            oGridGQL:LoadValue('GQL_CODAGE', (cAliasGQL)->GQL_CODAGE)
            oGridGQL:LoadValue('GQL_DESCAG', Posicione("GI6", 1, xFilial("GI6") + (cAliasGQL)->GQL_CODAGE, "GI6_DESCRI"))
            oGridGQL:LoadValue('GQL_CODADM', (cAliasGQL)->GQL_CODADM)
            oGridGQL:LoadValue('GQL_DESCAD', Posicione("SAE", 1, xFilial("SAE") + (cAliasGQL)->GQL_CODADM, "AE_DESC"))
            oGridGQL:LoadValue('GQL_IDECNT', (cAliasGQL)->GQL_IDECNT)
            oGridGQL:LoadValue('GQL_TPVEND', (cAliasGQL)->GQL_TPVEND)
            oGridGQL:LoadValue('GQL_CODIGO', (cAliasGQL)->GQL_CODIGO)
            oGridGQL:LoadValue('GQL_FILIAL', (cAliasGQL)->GQL_FILIAL)
            oGridGQL:LoadValue('GQL_RECNO' , (cAliasGQL)->GQL_RECNO)
            oGridGQL:LoadValue('GQL_CODH7C', (cAliasGQL)->GQL_CODH7C)
            BeginSql Alias cAliasGQM
                SELECT
                    GQM.GQM_CODIGO, GQM.GQM_CODGQL, GQM.GQM_NUMDOC, GQM.GQM_CODNSU, GQM.GQM_CODAUT, GQM.GQM_DTVEND, GQM.GQM_QNTPAR, GQM.GQM_VALOR ,
                    GQM.GQM_FILIAL, GQM.GQM_ESTAB , GQM.GQM_FILTIT, GQM.GQM_MOTREJ, GQM.GQM_CONFER, GQM.GQM_DTCONF, GQM.GQM_USUCON, GQM.GQM_VLACER 
                FROM
                    %Table:GQM% GQM
                INNER JOIN %Table:GQL% GQL
                    ON GQL.GQL_FILIAL = %xFilial:GQL%
                    AND GQL.GQL_CODAGE = %Exp:(cAliasGQL)->GQL_CODAGE%
                    AND GQL.GQL_NUMFCH = %Exp:(cAliasGQL)->GQL_NUMFCH%
                    AND GQL.GQL_CODIGO = %Exp:(cAliasGQL)->GQL_CODIGO%
                    AND GQL.%NotDel%
                WHERE GQM.%NotDel%
                    AND GQM.GQM_FILIAL = GQL.GQL_FILIAL
                    AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
            EndSql
            If nOperacao==MODEL_OPERATION_UPDATE
                GP502ALT(oModel, oModel:GetModel("GQMDETAIL"):cid)
            EndIf
            
            While !(cAliasGQM)->(Eof())
                If !Empty(oGridGQM:GetValue('GQM_CODGQL')) .And. ! (oGridGQM:SeekLine({{"GQM_CODIGO", (cAliasGQM)->GQM_CODIGO }}))
                    oGridGQM:SetNoInsertLine(.F.)
                    oGridGQM:AddLine()
                EndIf
                oGridGQM:LoadValue('GQM_CODIGO', (cAliasGQM)->GQM_CODIGO)
                oGridGQM:LoadValue('GQM_CODGQL', (cAliasGQM)->GQM_CODGQL)
                oGridGQM:LoadValue('GQM_CODNSU', (cAliasGQM)->GQM_CODNSU)
                oGridGQM:LoadValue('GQM_CODAUT', (cAliasGQM)->GQM_CODAUT)
                oGridGQM:LoadValue('GQM_DTVEND', StoD((cAliasGQM)->GQM_DTVEND))
                oGridGQM:LoadValue('GQM_QNTPAR', (cAliasGQM)->GQM_QNTPAR)
                oGridGQM:LoadValue('GQM_VALOR ', (cAliasGQM)->GQM_VALOR )
                oGridGQM:LoadValue('GQM_FILIAL', (cAliasGQM)->GQM_FILIAL)
                oGridGQM:LoadValue('GQM_ESTAB ', (cAliasGQM)->GQM_ESTAB )
                oGridGQM:LoadValue('GQM_FILTIT', (cAliasGQM)->GQM_FILTIT)
                oGridGQM:LoadValue('GQM_MOTREJ', (cAliasGQM)->GQM_MOTREJ)
                oGridGQM:LoadValue('GQM_CONFER', (cAliasGQM)->GQM_CONFER)
                oGridGQM:LoadValue('GQM_DTCONF', StoD((cAliasGQM)->GQM_DTCONF))
                oGridGQM:LoadValue('GQM_USUCON', (cAliasGQM)->GQM_USUCON)
                oGridGQM:LoadValue('GQM_VLACER', (cAliasGQM)->GQM_VLACER)
                (cAliasGQM)->( dbSkip() )
            EndDo
            (cAliasGQM)->( dbCloseArea() )
            oGridGQM:GoLine(1)
            (cAliasGQL)->( dbSkip() )
        EndDo
        (cAliasGQL)->( dbCloseArea() )
        oGridGQL:GoLine(1)
    EndIf

    // Receitas e Despesas
    If GZG->(FieldPos("GZG_CONFER")) > 0 .And. GZG->(FieldPos("GZG_DTCONF")) > 0 .And. GZG->(FieldPos("GZG_VLACER")) > 0
        BeginSql Alias cAliasGZGD
            SELECT 
                GZG.GZG_FILIAL, GZG.GZG_SEQ   , GZG.GZG_AGENCI, GZG.GZG_NUMFCH, GZG.GZG_COD   , GZG.GZG_TIPO  , GZG.GZG_DESCRI, GZG.GZG_VALOR ,
                GZG.GZG_CQVINC, GZG.GZG_CARGA , GZG.GZG_CONFER, GZG.GZG_DTCONF, GZG.GZG_USUCON, GZG.GZG_FILTIT, GZG.GZG_PRETIT, GZG.GZG_NUMTIT,
                GZG.GZG_PARTIT, GZG.GZG_TIPTIT, GZG.GZG_MOTREJ, GZG.GZG_STATIT, GZG.GZG_VLACER, GZG.R_E_C_N_O_ AS GZG_RECNO, GZG.GZG_CODH7C
            FROM 
                %Table:GZG% GZG
            WHERE GZG.%NotDel%
                AND GZG.GZG_FILIAL = %xFilial:GZG%
                AND GZG.GZG_AGENCI = %Exp:cAgencia%
                AND GZG.GZG_NUMFCH = %Exp:cNumFich%
                AND GZG.GZG_TIPO   = "2"                
        EndSql

        If nOperacao==MODEL_OPERATION_UPDATE
            GP502ALT(oModel, oModel:GetModel("GZGDETAILE"):cid)
        EndIf
        
        While (cAliasGZGD)->( !Eof() )
            If !Empty(oGridDGZG:GetValue('GZG_SEQ')) .And. ! (oGridDGZG:SeekLine({{"GZG_RECNO", (cAliasGZGD)->GZG_RECNO }}))
                oGridDGZG:SetNoInsertLine(.F.)
                oGridDGZG:AddLine()
            EndIf
            oGridDGZG:LoadValue("GZG_SEQ"   , (cAliasGZGD)->GZG_SEQ   )
            oGridDGZG:LoadValue("GZG_AGENCI", (cAliasGZGD)->GZG_AGENCI)
            oGridDGZG:LoadValue("GZG_NUMFCH", (cAliasGZGD)->GZG_NUMFCH)
            oGridDGZG:LoadValue("GZG_COD"   , (cAliasGZGD)->GZG_COD   )
            oGridDGZG:LoadValue("GZG_TIPO"  , (cAliasGZGD)->GZG_TIPO  )
            oGridDGZG:LoadValue("GZG_DESCRI", (cAliasGZGD)->GZG_DESCRI)
            oGridDGZG:LoadValue("GZG_VALOR" , (cAliasGZGD)->GZG_VALOR )
            oGridDGZG:LoadValue("GZG_CQVINC", (cAliasGZGD)->GZG_CQVINC)
            oGridDGZG:LoadValue("GZG_CARGA" , Iif((cAliasGZGD)->GZG_CARGA == "T", .T., .F.))
            oGridDGZG:LoadValue("GZG_CONFER", (cAliasGZGD)->GZG_CONFER)
            oGridDGZG:LoadValue("GZG_DTCONF", StoD((cAliasGZGD)->GZG_DTCONF))
            oGridDGZG:LoadValue("GZG_USUCON", (cAliasGZGD)->GZG_USUCON)
            oGridDGZG:LoadValue("GZG_FILTIT", (cAliasGZGD)->GZG_FILTIT)
            oGridDGZG:LoadValue("GZG_PRETIT", (cAliasGZGD)->GZG_PRETIT)
            oGridDGZG:LoadValue("GZG_NUMTIT", (cAliasGZGD)->GZG_NUMTIT)
            oGridDGZG:LoadValue("GZG_PARTIT", (cAliasGZGD)->GZG_PARTIT)
            oGridDGZG:LoadValue("GZG_TIPTIT", (cAliasGZGD)->GZG_TIPTIT)
            oGridDGZG:LoadValue("GZG_MOTREJ", (cAliasGZGD)->GZG_MOTREJ)
            oGridDGZG:LoadValue("GZG_STATIT", (cAliasGZGD)->GZG_STATIT)
            oGridDGZG:LoadValue("GZG_VLACER", (cAliasGZGD)->GZG_VLACER)
            oGridDGZG:LoadValue("GZG_RECNO" , (cAliasGZGD)->GZG_RECNO)
            oGridDGZG:LoadValue("GZG_CODH7C" , (cAliasGZGD)->GZG_CODH7C)            
            (cAliasGZGD)->( dbSkip() )
        EndDo
        (cAliasGZGD)->( dbCloseArea() )
        oGridDGZG:GoLine(1)
        BeginSql Alias cAliasGZGE
            SELECT
                GZG.GZG_FILIAL, GZG.GZG_SEQ   , GZG.GZG_AGENCI, GZG.GZG_NUMFCH, GZG.GZG_COD   , GZG.GZG_TIPO  , GZG.GZG_DESCRI, GZG.GZG_VALOR ,
                GZG.GZG_CQVINC, GZG.GZG_CARGA , GZG.GZG_CONFER, GZG.GZG_DTCONF, GZG.GZG_USUCON, GZG.GZG_FILTIT, GZG.GZG_PRETIT, GZG.GZG_NUMTIT,
                GZG.GZG_PARTIT, GZG.GZG_TIPTIT, GZG.GZG_MOTREJ, GZG.GZG_STATIT, GZG.GZG_VLACER, GZG.R_E_C_N_O_ AS GZG_RECNO, GZG.GZG_CODH7C
            FROM 
                %Table:GZG% GZG
            WHERE GZG.%NotDel%
                AND GZG.GZG_FILIAL = %xFilial:GZG%
                AND GZG.GZG_AGENCI = %Exp:cAgencia%
                AND GZG.GZG_NUMFCH = %Exp:cNumFich%
                AND GZG.GZG_TIPO   = "1"
                //AND GZG.GZG_CARGA   = 'F'
        EndSql
        If nOperacao==MODEL_OPERATION_UPDATE
            GP502ALT(oModel, oModel:GetModel("GZGDETAILD"):cid)
        EndIf
        
        While (cAliasGZGE)->( !Eof() )
            If !Empty(oGridEGZG:GetValue('GZG_SEQ')) .And. ! (oGridEGZG:SeekLine({{"GZG_RECNO", (cAliasGZGE)->GZG_RECNO }}))
                oGridEGZG:SetNoInsertLine(.F.)
                oGridEGZG:AddLine()
            EndIf
            oGridEGZG:LoadValue("GZG_SEQ"   , (cAliasGZGE)->GZG_SEQ   )
            oGridEGZG:LoadValue("GZG_AGENCI", (cAliasGZGE)->GZG_AGENCI)
            oGridEGZG:LoadValue("GZG_NUMFCH", (cAliasGZGE)->GZG_NUMFCH)
            oGridEGZG:LoadValue("GZG_COD"   , (cAliasGZGE)->GZG_COD   )
            oGridEGZG:LoadValue("GZG_TIPO"  , (cAliasGZGE)->GZG_TIPO  )
            oGridEGZG:LoadValue("GZG_DESCRI", (cAliasGZGE)->GZG_DESCRI)
            oGridEGZG:LoadValue("GZG_VALOR" , (cAliasGZGE)->GZG_VALOR )
            oGridEGZG:LoadValue("GZG_CQVINC", (cAliasGZGE)->GZG_CQVINC)
            oGridEGZG:LoadValue("GZG_CARGA" , Iif((cAliasGZGE)->GZG_CARGA == "T", .T., .F.) )
            oGridEGZG:LoadValue("GZG_CONFER", (cAliasGZGE)->GZG_CONFER)
            oGridEGZG:LoadValue("GZG_DTCONF", StoD((cAliasGZGE)->GZG_DTCONF))
            oGridEGZG:LoadValue("GZG_USUCON", (cAliasGZGE)->GZG_USUCON)
            oGridEGZG:LoadValue("GZG_FILTIT", (cAliasGZGE)->GZG_FILTIT)
            oGridEGZG:LoadValue("GZG_PRETIT", (cAliasGZGE)->GZG_PRETIT)
            oGridEGZG:LoadValue("GZG_NUMTIT", (cAliasGZGE)->GZG_NUMTIT)
            oGridEGZG:LoadValue("GZG_PARTIT", (cAliasGZGE)->GZG_PARTIT)
            oGridEGZG:LoadValue("GZG_TIPTIT", (cAliasGZGE)->GZG_TIPTIT)
            oGridEGZG:LoadValue("GZG_MOTREJ", (cAliasGZGE)->GZG_MOTREJ)
            oGridEGZG:LoadValue("GZG_STATIT", (cAliasGZGE)->GZG_STATIT)
            oGridEGZG:LoadValue("GZG_VLACER", (cAliasGZGE)->GZG_VLACER)
            oGridEGZG:LoadValue("GZG_RECNO" , (cAliasGZGE)->GZG_RECNO)
            oGridEGZG:LoadValue("GZG_CODH7C", (cAliasGZGE)->GZG_CODH7C)            
            (cAliasGZGE)->( dbSkip() )
        End
        (cAliasGZGE)->( dbCloseArea() )
        oGridEGZG:GoLine(1)
    EndIf

    // Conferência de Requisição
    If ChkFile("GQW") .And. GQW->(FieldPos("GQW_TOTAL")) > 0 .And. GQW->( FieldPos("GQW_CONFCH")) > 0 .And. GQW->(FieldPos("GQW_NUMFCH")) > 0
        BeginSql Alias cAliasGQW
            SELECT 
                GQW.GQW_CODIGO, GQW.GQW_REQDES, GQW.GQW_CODCLI, GQW.GQW_CODLOJ, GQW.GQW_CODAGE, GQW.GQW_DATEMI, GQW.GQW_TOTAL ,
                GQW.GQW_STATUS, GQW.GQW_CONFER, GQW.GQW_CODLOT, GQW.GQW_CODORI, GQW.GQW_TOTDES, GQW.GQW_CONFCH, GQW.GQW_USUCON , GQW.R_E_C_N_O_ AS GQW_RECNO,
                GQW.GQW_CODH7C
            FROM 
                %Table:GQW% GQW
            WHERE GQW.%NotDel%
                AND GQW.GQW_FILIAL = %xFilial:GQW%
                AND GQW.GQW_CODAGE = %Exp:cAgencia%
                AND GQW.GQW_NUMFCH = %Exp:cNumFich%
        EndSql
        If nOperacao==MODEL_OPERATION_UPDATE
            GP502ALT(oModel, oModel:GetModel("GQWDETAIL"):cid)
        EndIf
        
        While (cAliasGQW)->( !Eof() )
            If !Empty(oGridGQW:GetValue('GQW_CODIGO')) .And. ! (oGridGQW:SeekLine({{"GQW_RECNO", (cAliasGQW)->GQW_RECNO }}))
                oGridGQW:SetNoInsertLine(.F.)
                oGridGQW:AddLine()
            EndIf
            oGridGQW:LoadValue("GQW_CODIGO", (cAliasGQW)->GQW_CODIGO)
            oGridGQW:LoadValue("GQW_REQDES", (cAliasGQW)->GQW_REQDES)
            oGridGQW:LoadValue("GQW_CODCLI", (cAliasGQW)->GQW_CODCLI)
            oGridGQW:LoadValue("GQW_CODLOJ", (cAliasGQW)->GQW_CODLOJ)
            oGridGQW:LoadValue("GQW_NOMCLI", Posicione("SA1", 1, xFilial("SA1") + (cAliasGQW)->GQW_CODCLI + (cAliasGQW)->GQW_CODLOJ, "A1_NOME"))
            oGridGQW:LoadValue("GQW_CODAGE", (cAliasGQW)->GQW_CODAGE)
            oGridGQW:LoadValue("GQW_DATEMI", StoD((cAliasGQW)->GQW_DATEMI))
            oGridGQW:LoadValue("GQW_TOTAL ", (cAliasGQW)->GQW_TOTAL )
            oGridGQW:LoadValue("GQW_STATUS", (cAliasGQW)->GQW_STATUS)
            oGridGQW:LoadValue("GQW_CONFER", (cAliasGQW)->GQW_CONFER)
            oGridGQW:LoadValue("GQW_CODLOT", (cAliasGQW)->GQW_CODLOT)
            oGridGQW:LoadValue("GQW_CODORI", (cAliasGQW)->GQW_CODORI)
            oGridGQW:LoadValue("GQW_TOTDES", (cAliasGQW)->GQW_TOTDES)
            oGridGQW:LoadValue("GQW_CONFCH", (cAliasGQW)->GQW_CONFCH)
            oGridGQW:LoadValue("GQW_USUCON", (cAliasGQW)->GQW_USUCON)
            oGridGQW:LoadValue("GQW_RECNO" , (cAliasGQW)->GQW_RECNO)
            oGridGQW:LoadValue("GQW_CODH7C", (cAliasGQW)->GQW_CODH7C)
            (cAliasGQW)->( dbSkip() ) 
        EndDo
        (cAliasGQW)->( dbCloseArea() )
        oGridGQW:GoLine(1)
    EndIf
    GP502GAT(oModel)
EndIf
If ValType(oView) == "O" .And. oView:IsActive()
    oView:Refresh()
EndIf    
Return



/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Funcao de tratamento par ao duplo clique do anexo.
@type  Static Function
@author Eduardo Silva
@since 20/03/2024
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()
    If cField $ 'GIC_ANEXO/G57_ANEXO/G99_ANEXO/GQL_ANEXO/GQM_ANEXO/GZG2_ANEXO/GZG1_ANEXO/GQW_ANEXO'
        AttachDocs(oView,cField)
    EndIf
Return .T.



/*/{Protheus.doc} AttachDocs(oView)
Funcao para tratamento do MsDocument para anexar os documentos aos itens.
@type  Static Function
@author Eduardo Silva
@since 20/03/2024
/*/
Static Function AttachDocs(oView,cField)
Local cCodTab   := ""
Local cSerie    := ""
Local cSubSer   := ""
Local cAgenc    := ""
Local NroFich   := ""
Local cSeq      := ""
Local cTipo     := ""
Local cClient   := ""
Local cLoja     := ""
Local cCodNsu   := ""
Local cCodAut   := ""
Local cTable    := ""
Local cSeek     := ""

    If cField == "GIC_ANEXO"    // Indice - GIC_FILIAL + GIC_CODIGO
        cCodTab := oView:GetModel():GetValue('GICDETAIL','GIC_CODIGO')
        cSeek   := cCodTab
        cTable  := "GIC"
    ElseIf cField == "G57_ANEXO"    // Indice - G57_FILIAL + G57_CODIGO + G57_SERIE + G57_SUBSER
        cCodTab := oView:GetModel():GetValue('G57DETAIL','G57_CODIGO')
        cSerie  := oView:GetModel():GetValue('G57DETAIL','G57_SERIE')
        cSubSer := oView:GetModel():GetValue('G57DETAIL','G57_SUBSER')
        cSeek   := cCodTab + cSerie + cSubSer
        cTable  := "G57"
    ElseIf cField == "G99_ANEXO"    // Indice - G99_FILIAL + G99_CODIGO
        cCodTab := oView:GetModel():GetValue('G99DETAIL','G99_CODIGO')
        cSeek   := cCodTab
        cTable  := "G99"
    ElseIf cField == "GQL_ANEXO"    // Indice - GQL_FILIAL + GQL_CODIGO
        cCodTab := oView:GetModel():GetValue('GQLDETAIL','GQL_CODIGO')
        cSeek   := cCodTab
        cTable  := "GQL"
    ElseIf cField == "GQM_ANEXO"    // Indice - GQM_FILIAL + GQM_CODGQL + GQM_CODNSU + GQM_CODAUT
        cCodTab := oView:GetModel():GetValue('GQMDETAIL','GQM_CODGQL')
        cCodNsu := oView:GetModel():GetValue('GQMDETAIL','GQM_CODNSU')
        cCodAut := oView:GetModel():GetValue('GQMDETAIL','GQM_CODAUT')
        cSeek   := cCodTab + cCodNsu + cCodAut
        cTable  := "GQM"
    ElseIf cField == "GZG1_ANEXO"   // Indice - GZG_FILIAL + GZG_AGENCI + GZG_NUMFCH + GZG_SEQ + GZG_TIPO
        cAgenc  := oView:GetModel():GetValue('GZGDETAILE','GZG_AGENCI')
        NroFich := oView:GetModel():GetValue('GZGDETAILE','GZG_NUMFCH')
        cSeq    := oView:GetModel():GetValue('GZGDETAILE','GZG_SEQ')
        cTipo   := oView:GetModel():GetValue('GZGDETAILE','GZG_TIPO')
        cSeek   := cAgenc + NroFich + cSeq + cTipo
        cTable  := "GZG"
    ElseIf cField == "GZG2_ANEXO"   // Indice - GZG_FILIAL + GZG_AGENCI + GZG_NUMFCH + GZG_SEQ + GZG_TIPO
        cAgenc  := oView:GetModel():GetValue('GZGDETAILD','GZG_AGENCI')
        NroFich := oView:GetModel():GetValue('GZGDETAILD','GZG_NUMFCH')
        cSeq    := oView:GetModel():GetValue('GZGDETAILD','GZG_SEQ')
        cTipo   := oView:GetModel():GetValue('GZGDETAILD','GZG_TIPO')
        cSeek   := cAgenc + NroFich + cSeq + cTipo
        cTable  := "GZG"
    ElseIf cField == "GQW_ANEXO"    // Indice - GQW_FILIAL + GQW_CODIGO + GQW_CODCLI + GQW_CODLOJ
        cCodTab := oView:GetModel():GetValue('GQWDETAIL','GQW_CODIGO')
        cClient := oView:GetModel():GetValue('GQWDETAIL','GQW_CODCLI')
        cLoja   := oView:GetModel():GetValue('GQWDETAIL','GQW_CODLOJ')
        cSeek   := cCodTab + cClient + cLoja
        cTable  := "GQW"
    EndIf
    (cTable)->( dbSetOrder(1) )  // Indice por tabela
    If (cTable)->( dbSeek( xFilial(cTable) + cSeek) )
        MsDocument(cTable , (cTable)->( Recno() ), 4)
    EndIf
Return 



/*/{Protheus.doc} SetIniFld()
Funcao para tratamento da legenda do item (campo anexo).
@type  Static Function
@author Eduardo Silva
@since 13/03/2024
/*/
Static Function SetIniFld(cCodEnt, cCodObj, cTable)
Local cValor    := ""
Default cCodEnt := ""
Default cCodObj := ""
Default cTable  := ""

    AC9->( dbSetOrder(2) )  // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
    If AC9->( dbSeek(xFilial('AC9') + cTable + xFilial(cTable) + xFilial(cTable) + cCodEnt + cCodObj) )
        cValor := "F5_VERD"
    Else
        cValor := 'F5_VERM'
    EndIf
Return cValor



/* /{Protheus.doc} GP502GAT
Função responsavel pelo carregamento dos registros na tela das tabelas GYN, H68, GQE e G6W.
@type Static Function
@author Eduardo Silva
@since 25/03/2024
@version 12.1.2310
/*/
Static Function GP502GAT(oModel)    
Local oGridGIC  := oModel:GetModel('GICDETAIL')
Local oGridG57  := oModel:GetModel('G57DETAIL')
Local oGridG99  := oModel:GetModel("G99DETAIL")
Local oGridGQL  := oModel:GetModel("GQLDETAIL")
Local oGridGQM  := oModel:GetModel("GQMDETAIL")
Local oGridDGZG := oModel:GetModel("GZGDETAILD")
Local oGridEGZG := oModel:GetModel("GZGDETAILE")
Local oGridGQW  := oModel:GetModel("GQWDETAIL")
Local nX

    For nX := 1 to oGridGIC:Length()
        oGridGIC:GoLine(nX)  
        oGridGIC:SetValue("GIC_ANEXO", SetIniFld(oGridGIC:GetValue("GIC_CODIGO"), "", "GIC"))
    Next nX
    For nX := 1 to oGridG57:Length()
        oGridG57:GoLine(nX)  
        oGridG57:SetValue("G57_ANEXO", SetIniFld(oGridG57:GetValue("G57_NUMMOV") + oGridG57:GetValue("G57_SERIE") + oGridG57:GetValue("G57_SUBSER") + oGridG57:GetValue("G57_NUMCOM") + oGridG57:GetValue("G57_CODIGO") + oGridG57:GetValue("G57_TIPO"), "", "G57"))
    Next nX
    For nX := 1 to oGridG99:Length()
        oGridG99:GoLine(nX)  
        oGridG99:SetValue("G99_ANEXO", SetIniFld(oGridG99:GetValue("G99_CODIGO"), "", "G99"))
    Next nX
    For nX := 1 to oGridGQL:Length()
        oGridGQL:GoLine(nX)  
        oGridGQL:SetValue("GQL_ANEXO", SetIniFld(oGridGQL:GetValue("GQL_CODIGO"), "", "GQL"))
    Next nX
    For nX := 1 to oGridGQM:Length()
        oGridGQM:GoLine(nX)  
        oGridGQM:SetValue("GQM_ANEXO", SetIniFld(oGridGQM:GetValue("GQM_CODGQL") + oGridGQM:GetValue("GQM_CODNSU") + oGridGQM:GetValue("GQM_CODAUT"), "", "GQM"))
    Next nX

    For nX := 1 to oGridDGZG:Length()
        oGridDGZG:GoLine(nX)  
        oGridDGZG:SetValue("GZG2_ANEXO", SetIniFld(oGridDGZG:GetValue("GZG_AGENCI") + oGridDGZG:GetValue("GZG_NUMFCH") + oGridDGZG:GetValue("GZG_SEQ") + oGridDGZG:GetValue("GZG_TIPO"), "", "GZG"))
    Next nX
    For nX := 1 to oGridEGZG:Length()
        oGridEGZG:GoLine(nX) 
        oGridEGZG:SetValue("GZG1_ANEXO", SetIniFld(oGridEGZG:GetValue("GZG_AGENCI") + oGridEGZG:GetValue("GZG_NUMFCH") + oGridEGZG:GetValue("GZG_SEQ") + oGridEGZG:GetValue("GZG_TIPO"), "", "GZG"))
    Next nX

    For nX := 1 to oGridGQW:Length()
        oGridGQW:GoLine(nX)  
        oGridGQW:SetValue("GQW_ANEXO", SetIniFld(oGridGQW:GetValue("GQW_CODIGO"), "", "GQW"))
    Next nX
Return



/*/{Protheus.doc} VldActivate(oModel)
Faz validação para verificar se os campos de malotes foram preenchidos nao permitindo a exclusão.
@type function
@author Eduardo Silva
@since 04/04/2024
@version 12.1.2310
/*/
Static Function VldActivate(oModel)
Local cMdlId    := oModel:GetId()

    If oModel:GetModel("H7CMASTER"):GetOperation() == MODEL_OPERATION_DELETE 
        If !Empty(H7C->H7C_CODVIA) .And. !Empty(H7C->H7C_RECURS)
            oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"VldActivate",STR0018,STR0019)        //"Não é possível excluir um malote já enviado."  //"Para excluir cancele o Malote e repita a operação !!!"
            Return .F.
        EndIf
    EndIf
    If oModel:GetModel("H7CMASTER"):GetOperation() == MODEL_OPERATION_UPDATE
        If !Empty(H7C->H7C_CODVIA) .And. !Empty(H7C->H7C_RECURS)
            oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"VldActivate",STR0038,STR0020)      //"Não é possível alterar um malote já enviado."     //"Para alterar cancele o Malote e repita a operação !!!"
            Return .F.
        EndIf
    EndIf
Return .T.



/*/{Protheus.doc} GP502ECM
Função responsavel pelo envio do malote posicionado.
@type function
@author Eduardo Silva
@since 04/04/2024
@version 12.1.2310
/*/
Function GP502ECM()
Local lret := .T.

    If !Empty(H7C->H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. !Empty(H7C_RECCOD) //recebido
        FwAlertHelp(STR0021,STR0022)                   //'Malote já enviado/recebido.'    //'Antes de cancelar o envio, cancele o envio/recebimento.'
        lret := .F.
    EndIf

    If lret
        IF Empty(H7C->H7C_CODVIA)
            If FwAlertYesNo(STR0023,STR0024)                                                // M"Deseja enviar o malote ?" //"Atenção!!!"
                FWExecView(STR0025,"VIEWDEF.GTPA502",MODEL_OPERATION_UPDATE,,{|| .T.})      //"Envio de Malote"
                If FwAlertYesNo(STR0026,STR0024)                                            // "Deseja imprimir o malote ?"//"Atenção!!!"
                    GTP502REL()
                EndIf
            EndIf
        Else
            If FwAlertYesNo(STR0027,STR0024)                                            // "Malote já foi enviado, Deseja cancelar o malote ?" //"Atenção!!!"
                Reclock("H7C", .F.)
                    H7C->H7C_CODVIA     := ""
                    H7C->H7C_SEQ        := ""
                    H7C->H7C_RECURS     := ""
                    H7C->H7C_VEICUL     := ""
                H7C->( MsUnlock() )
                If Empty(H7C->H7C_CODVIA)
                    MsgInfo(STR0028)                                                    //"Malote cancelado com sucesso !!!"
                EndIf
            EndIf
        EndIf
    EndIf

Return



/*/{Protheus.doc} GTP480REL
Função que realiza a impressão do Relatório de Caixa do Colaborador em Html.
@type  Static Function
@author Eduardo Pereira
@since 03/05/2023
@version 12.1.2310
/*/
Function GTP502REL(nOperac,cDir)
Local cFile       := ""
Local cHTMLDt     := ""
Local cPathhmtl   := Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\DIRDOC\" ) )
Local cHtmlCol    := Alltrim(SuperGetMv( "MV_DIRHTML", .F., "\HTML\" ) )
Local cArqhtml    := ""
Local cHTMLSrc    := ""
Local cPath       := ""
Local lRet        := .T.
Local oHTMLBody   := Nil
Local cQryGIC     := ""
Local oQryGIC     := Nil
Local cAliaGIC    := ""
Local cQryG57     := ""
Local oQryG57     := Nil
Local cAliaG57    := ""
Local cQryG99     := ""
Local oQryG99     := Nil
Local cAliaG99    := ""
Local cQryGQL     := ""
Local oQryGQL     := Nil
Local cAliaGQL    := ""
Local cQryGQM     := ""
Local oQryGQM     := Nil
Local cAliaGQM    := ""
Local cQryGZG2    := ""
Local oQryGZG2    := Nil
Local cAliaGZG2   := ""
Local cQryGZG1    := ""
Local oQryGZG1    := Nil
Local cAliaGZG1   := ""
Local cQryGQW     := ""
Local oQryGQW     := Nil
Local cAliaGQW    := ""
Local aTabH7D     := {}
Local aGtpa502    := {}
Local nX          := 0
Local nY          := 0
Local nZ          := 0
Local cHoraIni    := ""
Local cLocOri     := ""
Local cDscLocOri  := ""
Local cHoraFim    := ""
Local cLocDes     := ""
Local cDscLocDes  := ""
Local cMV_MODMALO := Alltrim(SuperGetMv( "MV_MODMALO", .F., "Malotes.html" )  )
Local cMV_MODMALR := Alltrim(SuperGetMv( "MV_MODMALR", .F., "Malotesrec.html" )  ) 
Default nOperac   := 1
Default cDir      := ""

    H7D->( dbGoTop() )
    While H7D->( !Eof() )
        If H7D->H7D_FILIAL + H7D->H7D_CODH7C == H7C->H7C_FILIAL + H7C->H7C_CODIGO
            // Bilhetes
            cQryGIC :=  " SELECT        "+;
                    "   GIC_FILIAL, GIC_AGENCI, GIC_NUMFCH, COUNT(*) QTDEGIC, SUM(GIC_TAR) TOTTARGIC     "+;
                    " FROM ? GIC    "+;
                    " WHERE GIC.D_E_L_E_T_ = ' '    "+;
                    "   AND GIC_FILIAL = ?        "+;
                    "   AND GIC_AGENCI = ?          "+;
                    "   AND GIC_NUMFCH = ?          "+;
                    " GROUP BY GIC_FILIAL, GIC_AGENCI, GIC_NUMFCH   "+;
                    " ORDER BY GIC_AGENCI "
            cQryGIC := ChangeQuery(cQryGIC)
            oQryGIC := FWPreparedStatement():New(cQryGIC)
            oQryGIC:SetUnsafe(1, RetSqlName("GIC"))
            oQryGIC:SetString(2, H7D->H7D_FILIAL)
            oQryGIC:SetString(3, H7D->H7D_AGENCI)
            oQryGIC:SetString(4, H7D->H7D_NUMFCH)
            cQryGIC  := oQryGIC:GetFixQuery()
            cAliaGIC := MPSysOpenQuery( cQryGIC )
            If (cAliaGIC)->( !Eof() )
                While (cAliaGIC)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GIC", (cAliaGIC)->QTDEGIC, (cAliaGIC)->TOTTARGIC })
                    (cAliaGIC)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GIC", (cAliaGIC)->QTDEGIC, (cAliaGIC)->TOTTARGIC })
            EndIf
            (cAliaGIC)->( dbCloseArea() )
            // Taxas
            cQryG57 :=  " SELECT        "+;
                        "   G57_FILIAL, G57_AGENCI, G57_NUMFCH, COUNT(*) QTDEG57, SUM(G57_VALOR) TOTVALG57     "+;
                        " FROM ? G57    "+;
                        " WHERE G57.D_E_L_E_T_ = ' '    "+;
                        "   AND G57_FILIAL = ?          "+;
                        "   AND G57_AGENCI = ?          "+;
                        "   AND G57_NUMFCH = ?          "+;
                        " GROUP BY G57_FILIAL, G57_AGENCI, G57_NUMFCH   "+;
                        " ORDER BY G57_AGENCI "
            cQryG57 := ChangeQuery(cQryG57)
            oQryG57 := FWPreparedStatement():New(cQryG57)
            oQryG57:SetUnsafe(1, RetSqlName("G57"))
            oQryG57:SetString(2, H7D->H7D_FILIAL)
            oQryG57:SetString(3, H7D->H7D_AGENCI)
            oQryG57:SetString(4, H7D->H7D_NUMFCH)
            cQryG57  := oQryG57:GetFixQuery()
            cAliaG57 := MPSysOpenQuery( cQryG57 )
            If (cAliaG57)->( !Eof() )
                While (cAliaG57)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "G57", (cAliaG57)->QTDEG57, (cAliaG57)->TOTVALG57 })
                    (cAliaG57)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "G57", (cAliaG57)->QTDEG57, (cAliaG57)->TOTVALG57 })
            EndIf
            (cAliaG57)->( dbCloseArea() )
            // Conhecimento
            cQryG99 :=  " SELECT        "+;
                        "   G99_FILIAL, G99_CODEMI, G99_NUMFCH, COUNT(*) QTDEG99, SUM(G99_VALOR) TOTVALG99     "+;
                        " FROM ? G99    "+;
                        " WHERE G99.D_E_L_E_T_ = ' '    "+;
                        "   AND G99.G99_FILIAL = ?      "+;
                        "   AND ( (G99.G99_CODEMI = ? AND G99.G99_TOMADO = '0') OR (G99.G99_CODREC = ? AND G99.G99_TOMADO = '3' AND G99_STAENC = '5') )     "+;
                        "   AND ( (G99.G99_DTEMIS BETWEEN ? AND ? AND G99.G99_NUMFCH = ' ') OR G99.G99_NUMFCH = ? )     "+;
                        "   AND G99.G99_STATRA = '2'    "+;
                        "   AND G99_TIPCTE != '2'       "+;
                        "   AND G99_COMPLM != 'I'       "+;
                        " GROUP BY G99_FILIAL, G99_CODEMI, G99_NUMFCH   "+;
                        " ORDER BY G99_CODEMI "
            cQryG99 := ChangeQuery(cQryG99)
            oQryG99 := FWPreparedStatement():New(cQryG99)
            oQryG99:SetUnsafe(1, RetSqlName("G99"))
            oQryG99:SetString(2, H7D->H7D_FILIAL)
            oQryG99:SetString(3, H7D->H7D_AGENCI)
            oQryG99:SetString(4, H7D->H7D_AGENCI)
            oQryG99:SetString(5, DtoS(Date()))
            oQryG99:SetString(6, DtoS(Date()))
            oQryG99:SetString(7, H7D->H7D_NUMFCH)
            cQryG99  := oQryG99:GetFixQuery()
            cAliaG99 := MPSysOpenQuery( cQryG99 )
            If (cAliaG99)->( !Eof() )
                While (cAliaG99)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "G99", (cAliaG99)->QTDEG99, (cAliaG99)->TOTVALG99 })
                    (cAliaG99)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "G99", (cAliaG99)->QTDEG99, (cAliaG99)->TOTVALG99 })
            EndIf
            (cAliaG99)->( dbCloseArea() )
            // Venda Pos Cabeçalho
            cQryGQL :=  " SELECT    "+;
                        "   GQL_FILIAL, GQL_CODAGE, GQL_NUMFCH, COUNT(*) QTDEGQL, SUM(GQL_VLRTOT) TOTVALGQL     "+;
                        " FROM ? GQL   "+;
                        " WHERE GQL.D_E_L_E_T_ = ' '    "+;
                        "   AND GQL.GQL_FILIAL = ?      "+;
                        "   AND GQL.GQL_CODAGE = ?      "+;
                        "   AND GQL.GQL_NUMFCH = ?      "+;
                        " GROUP BY GQL_FILIAL, GQL_CODAGE, GQL_NUMFCH   "+;
                        " ORDER BY GQL_CODAGE   "
            cQryGQL := ChangeQuery(cQryGQL)
            oQryGQL := FWPreparedStatement():New(cQryGQL)
            oQryGQL:SetUnsafe(1, RetSqlName("GQL"))
            oQryGQL:SetString(2, H7D->H7D_FILIAL)
            oQryGQL:SetString(3, H7D->H7D_AGENCI)
            oQryGQL:SetString(4, H7D->H7D_NUMFCH)
            cQryGQL  := oQryGQL:GetFixQuery()
            cAliaGQL := MPSysOpenQuery( cQryGQL )
            If (cAliaGQL)->( !Eof() )
                While (cAliaGQL)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQL", (cAliaGQL)->QTDEGQL, (cAliaGQL)->TOTVALGQL })
                    // Venda Pos Cabeçalho
                    cQryGQM :=  " SELECT    "+;
                                "   GQM_FILIAL, GQM_ESTAB, COUNT(*) QTDEGQM, SUM(GQM_VALOR) TOTVALGQM   "+;
                                " FROM ? GQM   "+;
                                " INNER JOIN ? GQL "+;
                                "   ON GQL.GQL_FILIAL = ?    "+;
                                "   AND GQL.GQL_CODAGE = ?   "+;
                                "   AND GQL.GQL_NUMFCH = ?   "+;
                                "   AND GQL.D_E_L_E_T_ = ' '    "+;
                                " WHERE GQM.D_E_L_E_T_ = ' '    "+;
                                "   AND GQM.GQM_FILIAL = GQL.GQL_FILIAL     "+;
                                "   AND GQM.GQM_CODGQL = GQL.GQL_CODIGO     "+;
                                " GROUP BY GQM_FILIAL, GQM_ESTAB            "+;
                                " ORDER BY GQM_ESTAB "
                                // "   --AND GQL.GQL_CODIGO = (cAliasGQL)->GQL_CODIGO    "+;
                    cQryGQM := ChangeQuery(cQryGQM)
                    oQryGQM := FWPreparedStatement():New(cQryGQM)
                    oQryGQM:SetUnsafe(1, RetSqlName("GQM"))
                    oQryGQM:SetUnsafe(2, RetSqlName("GQL"))
                    oQryGQM:SetString(3, (cAliaGQL)->GQL_FILIAL)
                    oQryGQM:SetString(4, (cAliaGQL)->GQL_CODAGE)
                    oQryGQM:SetString(5, (cAliaGQL)->GQL_NUMFCH)
                    cQryGQM  := oQryGQM:GetFixQuery()
                    cAliaGQM := MPSysOpenQuery( cQryGQM )
                    If (cAliaGQM)->( !Eof() )
                        While (cAliaGQM)->( !Eof() )
                            aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQM", (cAliaGQM)->QTDEGQM, (cAliaGQM)->TOTVALGQM })
                            (cAliaGQM)->( dbSkip() )
                        EndDo
                    Else
                        aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQM", (cAliaGQM)->QTDEGQM, (cAliaGQM)->TOTVALGQM })
                    EndIf
                    (cAliaGQM)->( dbCloseArea() )
                    (cAliaGQL)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQL", (cAliaGQL)->QTDEGQL, (cAliaGQL)->TOTVALGQL })
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQM", 0, 0 })
            EndIf
            (cAliaGQL)->( dbCloseArea() )
            // Despesas
            cQryGZG2 := " SELECT   "+;
                        "   GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH, COUNT(*) QTDEGZG2, SUM(GZG_VALOR) TOTVALGZG2    "+;
                        " FROM ? GZG   "+;
                        " WHERE GZG.D_E_L_E_T_ = ' '    "+;
                        "   AND GZG.GZG_FILIAL = ? "+;
                        "   AND GZG.GZG_AGENCI = ?   "+;
                        "   AND GZG.GZG_NUMFCH = ?   "+;
                        "   AND GZG.GZG_TIPO   = '2'    "+;
                        " GROUP BY GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH   "+;
                        " ORDER BY GZG_AGENCI   "
            cQryGZG2 := ChangeQuery(cQryGZG2)
            oQryGZG2 := FWPreparedStatement():New(cQryGZG2)
            oQryGZG2:SetUnsafe(1, RetSqlName("GZG"))
            oQryGZG2:SetString(2, H7D->H7D_FILIAL)
            oQryGZG2:SetString(3, H7D->H7D_AGENCI)
            oQryGZG2:SetString(4, H7D->H7D_NUMFCH)
            cQryGZG2  := oQryGZG2:GetFixQuery()
            cAliaGZG2 := MPSysOpenQuery( cQryGZG2 )
            If (cAliaGZG2)->( !Eof() )
                While (cAliaGZG2)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GZG2", (cAliaGZG2)->QTDEGZG2, (cAliaGZG2)->TOTVALGZG2 })
                    (cAliaGZG2)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GZG2", (cAliaGZG2)->QTDEGZG2, (cAliaGZG2)->TOTVALGZG2 })
            EndIf
            // Receitas
            cQryGZG1 := " SELECT   "+;
                        "   GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH, COUNT(*) QTDEGZG1, SUM(GZG_VALOR) TOTVALGZG1    "+;
                        " FROM ? GZG   "+;
                        " WHERE GZG.D_E_L_E_T_ = ' '    "+;
                        "   AND GZG.GZG_FILIAL = ? "+;
                        "   AND GZG.GZG_AGENCI = ?   "+;
                        "   AND GZG.GZG_NUMFCH = ?   "+;
                        "   AND GZG.GZG_TIPO   = '1'    "+;
                        " GROUP BY GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH   "+;
                        " ORDER BY GZG_AGENCI   "
            cQryGZG1 := ChangeQuery(cQryGZG1)
            oQryGZG1 := FWPreparedStatement():New(cQryGZG1)
            oQryGZG1:SetUnsafe(1, RetSqlName("GZG"))
            oQryGZG1:SetString(2, H7D->H7D_FILIAL)
            oQryGZG1:SetString(3, H7D->H7D_AGENCI)
            oQryGZG1:SetString(4, H7D->H7D_NUMFCH)
            cQryGZG1  := oQryGZG1:GetFixQuery()
            cAliaGZG1 := MPSysOpenQuery( cQryGZG1 )
            If (cAliaGZG1)->( !Eof() )
                While (cAliaGZG1)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GZG1", (cAliaGZG1)->QTDEGZG1, (cAliaGZG1)->TOTVALGZG1 })
                    (cAliaGZG1)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GZG1", (cAliaGZG1)->QTDEGZG1, (cAliaGZG1)->TOTVALGZG1 })
            EndIf
            // Requisições
            cQryGQW :=  " SELECT    "+;
                        "   GQW_FILIAL, GQW_CODAGE, GQW_NUMFCH, COUNT(*) QTDEGQW, SUM(GQW_TOTAL) TOTVALGQW  "+;
                        " FROM ? GQW   "+;
                        " WHERE GQW.D_E_L_E_T_ = ' '    "+;
                        "   AND GQW.GQW_FILIAL = ?      "+;
                        "   AND GQW.GQW_CODAGE = ?      "+;
                        "   AND GQW.GQW_NUMFCH = ?      "+;
                        " GROUP BY GQW_FILIAL, GQW_CODAGE, GQW_NUMFCH   "+;
                        " ORDER BY GQW_CODAGE   "
            cQryGQW := ChangeQuery(cQryGQW)
            oQryGQW := FWPreparedStatement():New(cQryGQW)
            oQryGQW:SetUnsafe(1, RetSqlName("GQW"))
            oQryGQW:SetString(2, H7D->H7D_FILIAL)
            oQryGQW:SetString(3, H7D->H7D_AGENCI)
            oQryGQW:SetString(4, H7D->H7D_NUMFCH)
            cQryGQW  := oQryGQW:GetFixQuery()
            cAliaGQW := MPSysOpenQuery( cQryGQW )
            If (cAliaGQW)->( !Eof() )
                While (cAliaGQW)->( !Eof() )
                    aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQW", (cAliaGQW)->QTDEGQW, (cAliaGQW)->TOTVALGQW })
                    (cAliaGQW)->( dbSkip() )
                EndDo
            Else
                aAdd(aTabH7D, { H7D->H7D_FILIAL, H7D->H7D_CODH7C, H7D->H7D_ITEM, H7D->H7D_CODG6X, H7D->H7D_AGENCI, H7D->H7D_NUMFCH, "GQW", (cAliaGQW)->QTDEGQW, (cAliaGQW)->TOTVALGQW })
            EndIf
        EndIf
        H7D->( dbSkip() )
    EndDo
    For nX := 1 to Len(aTabH7D)
        If (nPosM := ASCan(aGtpa502, {|x|, Alltrim(x[01]) + Alltrim(x[02]) == Alltrim(aTabH7D[nX,1]) + Alltrim(aTabH7D[nX,2])})) > 0   // Filial + Codigo H7C já existem
            If (nPosN := ASCan(aGtpa502[nPosM,03], {|x|, Alltrim(x[03]) + Alltrim(x[04]) == Alltrim(aTabH7D[nX,5]) + Alltrim(aTabH7D[nX,6])})) > 0   // Agencia + Ficha já existem
                aAdd(aGtpa502[nPosM,03,nPosN,05], { aTabH7D[nX,7], cValtoChar(aTabH7D[nX,8]), Alltrim(Transform(aTabH7D[nX,9],"@E 999,999,999.99")) })
            Else
                aAdd(aGtpa502[nPosM,03], { aTabH7D[nX,3], aTabH7D[nX,4], aTabH7D[nX,5], aTabH7D[nX,6], {{ aTabH7D[nX,7], cValtoChar(aTabH7D[nX,8]), Alltrim(Transform(aTabH7D[nX,9],"@E 999,999,999.99")) }} })
            EndIf
        Else
            aAdd(aGtpa502, { aTabH7D[nX,1], aTabH7D[nX,2], {{ aTabH7D[nX,3], aTabH7D[nX,4], aTabH7D[nX,5], aTabH7D[nX,6], {{ aTabH7D[nX,7], cValtoChar(aTabH7D[nX,8]), Alltrim(Transform(aTabH7D[nX,9],"@E 999,999,999.99")) }} }} })
        EndIf
    Next nX
    If FWIsInCallStack('GTPA502') .Or. FWIsInCallStack('GTPA502A')
        For nX := 1 to Len(aGtpa502)
            If nOperac == 1
                cArqhtml   := cMV_MODMALO 
            Else
                cArqhtml   := cMV_MODMALR  
            EndIf
            cHTMLSrc   := StrTran(cPathhmtl + cHtmlCol + cArqhtml,'\\','\')
            
            If File(cHTMLSrc)
                oHTMLBody:= TWFHTML():New(cHTMLSrc)
                //Dados Empresa e Data
                oHTMLBody:ValByName('empresa'       , Alltrim(SM0->M0_FILIAL))  // Alltrim(Posicione("SM0", 1, xFilial("SM0") + cEmpAnt + cFilAnt, "M0_FILIAL"))) 
                oHTMLBody:ValByName('data'		    , DtoC(dDataBase))
                //Dados Malote
                oHTMLBody:ValByName('codmalote'     , aGtpa502[nX,02])
                oHTMLBody:ValByName('nomemalote'    , Alltrim(H7C->H7C_DESCRI))
                //Transporte de Malotes
                oHTMLBody:ValByName('codviagem'	    , H7C->H7C_CODVIA)
                oHTMLBody:ValByName('sequencia'	    , H7C->H7C_SEQ)
                oHTMLBody:ValByName('recurso'	    , H7C->H7C_RECURS)
                oHTMLBody:ValByName('nomerecurso'   , Alltrim(Posicione("GYG", 1, xFilial("GYG") + H7C->H7C_RECURS, "GYG_NOME")))
                oHTMLBody:ValByName('veiculo'	    , H7C->H7C_VEICUL)
                oHTMLBody:ValByName('nomeveiculo'	, Alltrim(Posicione("ST9", 1, xFilial("ST9") + H7C->H7C_VEICUL, "T9_NOME")))
                oHTMLBody:ValByName('datapartida'	, Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_DTPART"))
                cHoraIni := Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_HRINI")
                oHTMLBody:ValByName('horainicio'	, Substr(cHoraIni,1,2) + ":" + Substr(cHoraIni,3,4))
                cLocOri := Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_LOCORI")
                oHTMLBody:ValByName('locorigem'	    , cLocOri)
                cDscLocOri := Alltrim(Posicione("GI1", 1, xFilial("GI1") + cLocOri, "GI1_DESCRI"))
                oHTMLBody:ValByName('nomeorigem'	, cDscLocOri)
                oHTMLBody:ValByName('datachegada'	, Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_DTCHEG"))
                cHoraFim := Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_HRFIM")
                oHTMLBody:ValByName('horafim'	    , Substr(cHoraFim,1,2) + ":" + Substr(cHoraFim,3,4))
                cLocDes := Posicione("G55", 4, xFilial("G55") + H7C->H7C_CODVIA + H7C->H7C_SEQ, "G55_LOCDES")
                oHTMLBody:ValByName('locdestino'	, cLocDes)
                cDscLocDes := Alltrim(Posicione("GI1", 1, xFilial("GI1") + cLocOri, "GI1_DESCRI"))
                oHTMLBody:ValByName('nomedestino'	, cDscLocDes)
                For nY := 1 To Len(aGtpa502[nX,03])
                    //Itens do Malote (Fichas)
                    aAdd(oHTMLBody:ValByName('a.item'	   ), aGtpa502[nX,03,nY,01])
                    aAdd(oHTMLBody:ValByName('a.codigoG6X' ), aGtpa502[nX,03,nY,02])
                    aAdd(oHTMLBody:ValByName('a.agencia'   ), aGtpa502[nX,03,nY,03])
                    aAdd(oHTMLBody:ValByName('a.numficha'  ), aGtpa502[nX,03,nY,04])
                    For nZ := 1 to Len(aGtpa502[nX,03,nY,05])
                        //Totais por Item e Valor
                        If aGtpa502[nX,03,nY,05,nZ,01] == "GIC"
                            aAdd(oHTMLBody:ValByName('b.numficha'           ), aGtpa502[nX,03,nY,04])
                            aAdd(oHTMLBody:ValByName('b.itensbilhete'	    ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totbilhete'	        ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "G57"
                            aAdd(oHTMLBody:ValByName('b.itenstaxas'	        ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.tottaxas'	        ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "G99"                        
                            aAdd(oHTMLBody:ValByName('b.itensconhec'	    ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totconhec'	        ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "GQL"                       
                            aAdd(oHTMLBody:ValByName('b.itenscabecvenda'	), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totcabecvenda'	    ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "GQM"                        
                            aAdd(oHTMLBody:ValByName('b.itensvenda'		    ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totitensvenda'	    ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "GZG1"                        
                            aAdd(oHTMLBody:ValByName('b.itensreceitas'	    ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totreceitas'	    ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "GZG2"                        
                            aAdd(oHTMLBody:ValByName('b.itensdespesas'	    ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totdespesas'	    ), aGtpa502[nX,03,nY,05,nZ,03])
                        ElseIf aGtpa502[nX,03,nY,05,nZ,01] == "GQW"                        
                            aAdd(oHTMLBody:ValByName('b.itensrequisicoes'   ), aGtpa502[nX,03,nY,05,nZ,02])
                            aAdd(oHTMLBody:ValByName('b.totrequisicoes'     ), aGtpa502[nX,03,nY,05,nZ,03])
                        EndIf
                    Next nZ
                Next nY
            Else
                lRet := .F.
            EndIf
            If lRet
                If (FWIsInCallStack('GTPA502A') .And. !Empty(cDir))
                    cPath := cDir
                Else
                    cPath := cGetFile( STR0029 + "|*.*" ,STR0030 ,0, ,.T. ,GETF_LOCALHARD+GETF_RETDIRECTORY ,.T.,) //"Diretório" //"Procurar"
                    cDir := cPath
                EndIf
                cFile := STR0031 + FWTimeStamp(1) + ".htm"  //"Malotes_"
                cHTMLDt := cPath + cValtoChar(nY) + cFile
                oHTMLBody:SaveFile(cHTMLDt)
                lRet := !Empty( MtHTML2Str(cHTMLDt) )
                ShellExecute("open",cHTMLDt,"","",5)
            EndIf
        Next nX
        If !lRet
            MsgStop(STR0032,STR0033)    // "Arquivo html não encontrado !!!"    //"Verifique os parametros MV_DIRDOC, MV_DIRHTML e MV_MODMALO"
        EndIf
    EndIf        
Return lRet




/*/{Protheus.doc} GP502ALT
//Atualiza grids na alteração dos registros tratando os modelos ainda conectados ao banco de dados
@author Yuri Porto 
@since 01/08/2024
@type function
/*/
Static Function GP502ALT(oModelo,cSubModel)

Local oModelox,oModGrid 
Local nA		:= 0

    oModelox	:= oModelo:GetModel() 
    oModGrid	:= oModelox:GetModel(cSubModel)

    oModGrid:SetNoInsertLine(.T.)
    oModGrid:SetNoDeleteLine(.F.)

    //deleta as linhas.
    If ValType(oModGrid)=="O" .And. oModGrid:Length()>0
        For nA	:= 1 to oModGrid:Length()				
            If	!oModGrid:IsDeleted(nA)
                oModGrid:GoLine(nA)
                oModGrid:DeleteLine()
            EndIf	
        Next
        If !(cSubModel$"GQLDETAIL|" ) //Modelos conectados ao banco não podem chamar o metodo CanClearData
            If oModGrid:CanClearData()
                oModGrid:ClearData()
            EndIf
        EndIf
    EndIf

Return 




/*/{Protheus.doc} GP502REI
//Reimpressão do html
@author Yuri Porto 
@since 14/08/2024
@type function
/*/
Function GP502REI()
Local   nOperac := 1//Enviado
Local   lret    := .T.

    If Empty(H7C_CODVIA)  .And. Empty(H7C_RECURS).And. Empty(H7C_RECCOD)
        FwAlertHelp('Malote ainda não enviado','Para reimpressão use um molete recebido ou enviado')     //'Malote ainda não enviado'   //'Para reimpressão use um molete recebido ou enviado'
        lRet    := .F.
    Elseif !Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. !Empty(H7C_RECCOD) //Recebido
        nOperac := 2
    EndIf
    If lRet
        GTP502REL(nOperac)
    EndIf

Return





/*/{Protheus.doc} TP502Grv
//Bloco de commit customizado
@author João Pires 
@since 01/08/2024
@version undefined
@param oModel
@type function
/*/
Static Function TP502Grv(oModel)
    Local oModel500  := FWLoadModel("GTPA500")
    Local oModelGIC  := FWLoadModel("GTPA115")
    Local oModelG57  := FWLoadModel("GTPA117")
    Local oModelG99  := FWLoadModel("GTPA117")

    Local oModelGQL     := FWLoadModel("GTPA026") //oModel500:GetModel("GQLDETAIL")
    Local oModelGQW     := FWLoadModel("GTPA283") //oModel500:GetModel("GQWDETAIL")

    Local oGridGIC  := oModel:GetModel('GICDETAIL')
    Local oGridG57  := oModel:GetModel('G57DETAIL')
    Local oGridG99  := oModel:GetModel("G99DETAIL")
    Local oGridGQL  := oModel:GetModel("GQLDETAIL")
    Local oGridDGZG := oModel:GetModel("GZGDETAILD")
    Local oGridEGZG := oModel:GetModel("GZGDETAILE")
    Local oGridGQW  := oModel:GetModel("GQWDETAIL")


    Local lRet		:= .T.    
    Local nOp		:= oModel:GetOperation()
    Local aArea     := FWGetArea()
    Local cCodH7C   := oModel:GetModel("H7CMASTER"):GetValue('H7C_CODIGO')
    Local nI        := 0
    Local aErrorMsg := {}
    
    
    If oModel:VldData()        
        Begin Transaction

        If ValType(cCodH7C)=="C" .And. !Empty(cCodH7C)


            If nOp == MODEL_OPERATION_DELETE
                cCodH7C := ''
            EndIf
                
            oModel500:SetOperation(MODEL_OPERATION_UPDATE)
            oModelGIC:SetOperation(MODEL_OPERATION_UPDATE)
            oModelG57:SetOperation(MODEL_OPERATION_UPDATE)
            oModelG99:SetOperation(MODEL_OPERATION_UPDATE)

            //GIC
            GIC->(DBSetOrder(1)) // GIC_FILIAL + GIC_CODIGO
            For nI := 1 To oGridGIC:Length()
                If GIC->(DBSeek(xFilial("GIC") + oGridGIC:GetValue("GIC_CODIGO", nI) ))
                    oModelGIC:Activate()
                    If !oGridGIC:IsDeleted(nI) 
                        oModelGIC:GetModel("GICMASTER"):LoadValue("GIC_CODH7C",cCodH7C )
                    EndIf
                    If oModelGIC:VldData()
                        lRet := oModelGIC:CommitData()
                    EndIF
                    aErrorMsg := oModelGIC:GetErrormessage() 
                    oModelGIC:DeActivate()
                EndIf
            Next
 
 
            //G57
            G57->(DBSetOrder(1)) //G57_FILIAL, G57_CODIGO, G57_SERIE, G57_SUBSER, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridG57:Length()
                If G57->(DBSeek(xFilial("G57") + oGridG57:GetValue("G57_CODIGO", nI) + oGridG57:GetValue("G57_SERIE", nI) + oGridG57:GetValue("G57_SUBSER", nI) ))
                    oModelG57:Activate()
                    If !oGridG57:IsDeleted(nI) 
                        oModelG57:GetModel("G57MASTER"):LoadValue("G57_CODH7C",cCodH7C )
                    EndIf
                    If oModelG57:VldData()
                        lRet := oModelG57:CommitData()
                    EndIf   
                    aErrorMsg := oModelG57:GetErrormessage()               
                    oModelG57:DeActivate()
                EndIf
            Next



            //G99
            G99->(DBSetOrder(1))//G99_FILIAL, G99_CODIGO, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridG99:Length()
                If G99->(DBSeek(xFilial("G99") + oGridG99:GetValue("G99_CODIGO", nI) ))
                    oModelG99:Activate()
                    If !oGridG99:IsDeleted(nI) 
                        oModelG99:GetModel("G99MASTER"):LoadValue("G99_CODH7C",cCodH7C )
                    EndIf
                    If oModelG99:VldData()
                        lRet := oModelG99:CommitData()
                    EndIf
                    aErrorMsg := oModelG99:GetErrormessage()                           
                    oModelG99:DeActivate()
                EndIf
            Next

          
            //GQL
            GQL->(DBSetOrder(1)) //GQL_FILIAL, GQL_CODIGO, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridGQL:Length()
                If GQL->(DBSeek(xFilial("GQL") + oGridGQL:GetValue("GQL_CODIGO", nI)  ))
                    oModelGQL:SetOperation(MODEL_OPERATION_UPDATE) //força para ativar o modelo
                    oModelGQL:Activate()
                    If !oGridGQL:IsDeleted(nI) 
                        oModelGQL:GetModel("GQLMASTER"):LoadValue("GQL_CODH7C",cCodH7C )
                    EndIf                        
                    If oModelGQL:VldData()
                        lRet := oModelGQL:CommitData()
                    Endif
                    aErrorMsg := oModelGQL:GetErrormessage()       
                    oModelGQL:DeActivate()
                EndIf
            Next


            //GQW
            GQW->(DBSetOrder(1)) //GQW_FILIAL, GQW_CODIGO, GQW_CODCLI, GQW_CODLOJ, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridGQW:Length()
                If GQW->(DBSeek(xFilial("GQW") + oGridGQW:GetValue("GQW_CODIGO", nI)  + oGridGQW:GetValue("GQW_CODCLI", nI)  + oGridGQW:GetValue("GQW_CODLOJ", nI) ))
                    oModelGQW:SetOperation(MODEL_OPERATION_UPDATE) //força para ativar o modelo
                    oModelGQW:Activate()
                    If !oGridGQW:IsDeleted(nI) 
                        oModelGQW:GetModel("FIELDGQW"):LoadValue("GQW_CODH7C",cCodH7C )
                    EndIf                        
                    If oModelGQW:VldData()
                        lRet := oModelGQW:CommitData()
                    Endif
                    aErrorMsg := oModelGQW:GetErrormessage()       
                    oModelGQW:DeActivate()
                EndIf
            Next


            //GZG_RECEITAS
            GZG->(DBSetOrder(1)) //GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH, GZG_SEQ, GZG_TIPO, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridEGZG:Length()
                If GZG->(DBSeek(xFilial("GZG") + oGridEGZG:GetValue("GZG_AGENCI", nI)  + oGridEGZG:GetValue("GZG_NUMFCH", nI) + oGridEGZG:GetValue("GZG_SEQ", nI) + "1"))
            
                    If !oGridEGZG:IsDeleted(nI)                         
                        Reclock("GZG",.F.)
                            GZG->GZG_CODH7C := cCodH7C
                        GZG->(MsUnlock())
                    EndIf                        
                    
                EndIf
            Next


            //GZG_DESPESAS
            GZG->(DBSetOrder(1)) //GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH, GZG_SEQ, GZG_TIPO, R_E_C_N_O_, D_E_L_E_T_
            For nI := 1 To oGridDGZG:Length()
                If GZG->(DBSeek(xFilial("GZG") + oGridDGZG:GetValue("GZG_AGENCI", nI)  + oGridDGZG:GetValue("GZG_NUMFCH", nI) + oGridDGZG:GetValue("GZG_SEQ", nI) + "2" ))
                    
                    If !oGridDGZG:IsDeleted(nI)                         
                        Reclock("GZG",.F.)
                            GZG->GZG_CODH7C := cCodH7C
                        GZG->(MsUnlock())
                    EndIf                        
                   
                EndIf
            Next


        EndIf    
        
        lRet := FwFormCommit(oModel)
        lRet := IIF(lRet,.T. ,DisarmTransaction() )

        End Transaction               
    EndIf

    FWRestArea(aArea)
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcReproc()
Função de Processamento
@author  José Carlos
@since   21/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function Initially(oModel)
    Local oModelH7D := NIL
    If FwIsInCallStack('GTPA421')
        oModelH7D	:= oModel:GetModel("H7DDETAIL") // Itens do Malote (Fichas)

        oModelH7D:SetValue('H7D_CODG6X', G6X->G6X_CODIGO)
        oModelH7D:SetValue('H7D_AGENCI', G6X->G6X_AGENCI)
        oModelH7D:SetValue('H7D_NUMFCH', G6X->G6X_NUMFCH)
    EndIf 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterActiv(oView)
Atualiza dados das pastas
@author  José Carlos
@since   27/08/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function AfterActiv(oView)

    If FwIsInCallStack('G421Malote')
        GP502ABAS(FwFldGet("H7D_AGENCI"), FwFldGet("H7D_NUMFCH"), NIL, NIL)    
    EndIF 
    oView:Refresh()

Return
