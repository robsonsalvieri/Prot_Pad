#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMPRODUTOS source FSMA015 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
//Local cCampos   := "B1_FILIAL|B1_COD|B1_DESC|"
Local oStruSB1	:= FwFormStruct(1, "SB1" /*, {|cCampo| AllTrim(cCampo)+ "|" $ cCampos}*/)
Local oStruJO2  := FwFormStruct(1, "JO2")
Local oStruJOE  := FwFormStruct(1, "JOE")
Local oCommit   := FSM015COMMIT():New()	

oStruSB1:AddField("Des.Grupo","Descrição do Grupo","B1_DSGRUP","C",TamSx3('BM_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJO2:AddField("Descr. Produto","Descr. Produto","JO2_DESPRO","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOE:AddField("Arquivo","Arquivo","JOE_ARQUIV","M",10,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		

oModel := MPFormModel():New('FSMA015', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oStruSB1:SetProperty("B1_DSGRUP",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"),"")'))

oStruJO2:SetProperty("JO2_DESPRO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'Fsm015Desc(JO2->JO2_PROALT)'))

oModel:AddFields('SB1MASTER',/*cOwner*/, oStruSB1)
oModel:AddGrid('JO2DETAIL', 'SB1MASTER', oStruJO2)
oModel:AddGrid('JOEDETAIL', 'SB1MASTER', oStruJOE)

oModel:SetRelation('JO2DETAIL', {{'JO2_FILIAL', 'xFilial("JO2")'};
                              ,  {'JO2_CODPRO', 'B1_COD' }};
                              ,  JO2->(IndexKey(1)))

oModel:SetRelation('JOEDETAIL', {{'JOE_FILIAL', 'xFilial("JOE")'};
                              ,  {'JOE_CODPRO', 'B1_COD' }};
                              ,  JOE->(IndexKey(1)))

oModel:GetModel('JO2DETAIL'):SetDescription("Produtos Alternativos")                              
oModel:GetModel('JOEDETAIL'):SetDescription("Anexos do Produto")                              
oModel:GetModel("JO2DETAIL"):SetOptional(.T.)
oModel:GetModel("JOEDETAIL"):SetOptional(.T.)

oModel:SetDescription('Cadastro de Produtos')
oModel:GetModel('SB1MASTER'):SetDescription("Cadastro de Produtos")

oModel:InstallEvent("FSM015COMMIT", /*cOwner*/, oCommit)

Return oModel

Function Fsm015Desc(cCodigo)
Local cDescri 
Local aAreaSB1  := SB1->( GetArea() )

cDescri := Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_DESC")

RestArea(aAreaSB1)

Return cDescri

Class FSM015COMMIT FROM FwModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class FSM015COMMIT

Return

Method BeforeTTS(oSubModel, cModelId) Class FSM015COMMIT
	ModelCommit(oSubModel:GetModel())
Return


Static Function ModelCommit(oModel)
Local oMdlJO2   := oModel:GetModel('JO2DETAIL')
Local oMdlJOE   := oModel:GetModel('JOEDETAIL')
Local nX        := 0
Local aAreaSB1  := SB1->(GetArea())
Local aAreaJO2  := JO2->(GetArea())
Local cPath     := '\FSM\DOCUMENTOSPRODUTO\' 
Local oFWriter
Local cFileName := ""

For nX := 1 To oMdlJO2:Length() 

    oMdlJO2:GoLine(nX)

    If oMdlJO2:IsInserted(nX)

        If SB1->(dbSeek(xFilial('SB1')+oMdlJO2:GetValue('JO2_PROALT')))

            RecLock('JO2',.T.)	
                JO2_FILIAL := xFilial('JO2')
                JO2_CODIGO := GetSxEnum('JO2','JO2_CODIGO')
                JO2_CODPRO := oMdlJO2:GetValue('JO2_PROALT')
                JO2_PROALT := oMdlJO2:GetValue('JO2_CODPRO')
            JO2->(MsUnlock())

        Endif

        RestArea(aAreaSB1)

        IncluiAssoc(oMdlJO2:GetValue('JO2_CODPRO'), oMdlJO2:GetValue('JO2_PROALT'))

    Endif

    If oMdlJO2:IsDeleted(nX)

        JO2->(dbSetOrder(2))

        If JO2->(dbSeek(xFilial('JO2')+oMdlJO2:GetValue('JO2_PROALT')+oMdlJO2:GetValue('JO2_CODPRO')))

	        JO2->(RecLock("JO2",.F.))
				JO2->(DbDelete())
			JO2->(MsUnLock())	

        Endif

        RestArea(aAreaJO2)

    Endif

Next

For nX := 1 To oMdlJOE:Length() 

    oMdlJOE:GoLine(nX)

    If oMdlJOE:IsInserted(nX)

        If !ExistDir(cPath)
            FwMakeDir(cPath)
        EndIf 

        If !Empty(oMdlJOE:GetValue('JOE_ARQUIV'))
            cFile := Decode64(oMdlJOE:GetValue('JOE_ARQUIV'))

            cFileName := FWUUID(oMdlJOE:GetValue('JOE_CODIGO')) + oMdlJOE:GetValue('JOE_EXTARQ')

            oFWriter := FwFileWriter():New(cPath + cFileName, .T.)

            If oFWriter:Create()
                oFWriter:Write(cFile)
            EndIf	

            lOk := oFWriter:Exists()
            oFWriter:Close()
            FreeObj(oFWriter)

            oMdlJOE:ClearField('JOE_ARQUIV')
            oMdlJOE:LoadValue('JOE_NOMARQ', cFileName)

        Endif

    Endif

    If oMdlJOE:IsDeleted(nX)

       FErase(cPath + oMdlJOE:GetValue('JOE_NOMARQ'))

    Endif

Next

Return

Static Function IncluiAssoc(cProdMaster, cProdDetail)
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp	:= Nil

cQuery := "SELECT JO2_PROALT, JO2_CODPRO FROM " + RetSqlName("JO2") + " JO2 "
cQuery += " WHERE "
cQuery += " JO2_FILIAL = ? "
cQuery += " AND JO2_CODPRO = ? "
cQuery += " AND JO2.D_E_L_E_T_ = ' ' "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JO2"))
oQryTmp:SetString(2, cProdMaster)

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

While !(cAliasTmp)->(Eof())

    RecLock('JO2',.T.)	
        JO2_FILIAL := xFilial('JO2')
        JO2_CODIGO := GetSxEnum('JO2','JO2_CODIGO')
        JO2_CODPRO := (cAliasTmp)->JO2_PROALT
        JO2_PROALT := cProdDetail
	JO2->(MsUnlock())

    RecLock('JO2',.T.)	
        JO2_FILIAL := xFilial('JO2')
        JO2_CODIGO := GetSxEnum('JO2','JO2_CODIGO')
        JO2_CODPRO := cProdDetail
        JO2_PROALT := (cAliasTmp)->JO2_PROALT
	JO2->(MsUnlock())


  	(cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

Return
