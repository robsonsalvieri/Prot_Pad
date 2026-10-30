#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA039
Negociação
@author Vitor kwon
@since 19/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------

PUBLISH MODEL REST NAME FSMKITSENTREGUES source FSMA039 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruJOC	:= FWFormStruct(1,"JOC")
Local oModelEvent   := FSM039Event():New()	

oStruJOC:AddField("Nome do Atendente" ,"Nome do Atendente","JOC_DSCAA1","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJOC:AddField("Descrição do KIT"  ,"Descr.Kit","JOC_DSCJOA","C",TamSx3('JOA_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruJOC:AddField("Armazem"           ,"Armazem" ,"JOC_LOCAL","C",TamSx3('AA1_LOCAL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruJOC:AddField("PecasBoas"         ,"Pecas Boas"  ,"JOC_LOCLZB","C",TamSx3('AA1_LOCLZB')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruJOC:AddField("PecasRuins"        ,"Pecas Ruins","JOC_LOCLZR","C",TamSx3('AA1_LOCLZR')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOC:AddField("Armazem Origem"    ,"Armazem Origem"      ,"JOC_ARMORI","C",TamSx3('AA1_LOCAL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruJOC:AddField("Endereço Origem"   ,"Endereço Origem"     ,"JOC_ENDORI","C",TamSx3('AA1_LOCLZB')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOC:AddField("Tes Entrega"       ,"Tes Entrega"         ,"JOC_TESENT","C",TamSx3('F4_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOC:AddField("Cliente"           ,"Cliente Entrega"     ,"JOC_CODCLI","C",TamSx3('A1_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOC:AddField("Loja"              ,"Loja do Cliente"     ,"JOC_LOJCLI","C",TamSx3('A1_LOJA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOC:AddField("Condição de pagamento" ,"Condição de pagamento"     ,"JOC_CONPAG","C",TamSx3('E4_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oModel := MPFormModel():New('FSMA039', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOCMASTER',nil,oStruJOC)

oModel:GetModel( "JOCMASTER" ):SetDescription( 'Entrega dos Kits' ) 

oStruJOC:SetProperty("JOC_DSCAA1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getInfAA1("AA1_NOMTEC")'))

oStruJOC:SetProperty("JOC_LOCAL",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getInfAA1("AA1_LOCAL")'))   

oStruJOC:SetProperty("JOC_LOCLZB",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getInfAA1("AA1_LOCLZB")'))   

oStruJOC:SetProperty("JOC_LOCLZR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getInfAA1("AA1_LOCLZR")'))   

oStruJOC:SetProperty("JOC_DSCJOA",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOA",1,xFilial("JOA")+JOC->JOC_CODJOA,"JOA_DESCRI"),"")'))   

oStruJOC:SetProperty("JOC_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOC","JOC_CODIGO")'))

oModel:SetPrimaryKey({"JOC_FILIAL","JOC_CODIGO"})

oModel:InstallEvent("FSM039Event", /*cOwner*/, oModelEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Vitor kwon
@since 19/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------

Class FSM039Event FROM FwModelEvent
	Method New()
    Method ModelPosVld()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Vitor kwon
@since 19/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class FSM039Event
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} pos valid
@author Vitor kwon
@since 19/09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class FSM039Event
Local lRet      := .T.
Local cMsgErro  := ''

        lRet := grvtDtkits(oModel, @cMsgErro)

        If !(lRet)
           	oModel:SetErrorMessage('JOCMASTER', ,'JOCMASTER',, "GRVDTKITS", cMsgErro, '') 
        Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} grvtDtkits
@author Vitor kwon
@since 19/09/2025
@version 1.0
status 01 = Atribuido
status 02 = Entregue
status 03 = Devolvido
/*/
//-------------------------------------------------------------------

Static Function grvtDtkits(oModel, cMsgErro)
Local lRet      := .T.
local lContinua   := .T.
Local oMdlJOA  := FwLoadModel('FSMA038')
Local aItensNew := {}
LOCAL aItemMov  := {}
local oEst     := FSM_ESTO():New()
lOCAL oMdlJOB
lOCAL nX   := 0
Local lPV  := .T.
Local cMsgRet	   := ''
Local cCodRet      := ''
Local cCodJOA      := ''
Private lMsErroAuto := .F.

    Begin Transaction 

        dbSelectArea("JOA")
        JOA->(dbSetOrder(1))

        If JOA->(dbSeek(xFilial('JOA')+oModel:GetValue('JOCMASTER','JOC_CODJOA')))
            oMdlJOA:SetOperation(MODEL_OPERATION_UPDATE)
            oMdlJOA:Activate()

            if oModel:GetValue('JOCMASTER','JOC_STATUS') == '01'
                oMdlJOA:SetValue('JOAMASTER','JOA_DTENTR', dDatabase)
                oMdlJOA:SetValue('JOAMASTER','JOA_ENTREG', '1')
                lContinua := .F.

            Elseif  oModel:GetValue("JOCMASTER","JOC_STATUS") == "02" .or. ;
                    oModel:GetValue("JOCMASTER","JOC_STATUS") == "03"
                aItensNew:={}
                cDocumento := nextnumero("SD3",2,"D3_DOC",.t.)
                aadd (aItensNew,{ cDocumento, ddatabase})
                oMdlJOB := oMdlJOA:GetModel("JOBDETAIL")
                cCodJOA := oMdlJOB:GetValue("JOB_CODJOA")
                For nX := 1 To oMdlJOB:Length()
                    oMdlJOB:GoLine(nX)
                    cProduto  := oMdlJOB:GetValue("JOB_CODPRO")
                    nQtd      := Val(Alltrim(oMdlJOB:GetValue("JOB_QUANTI")))
                    if oModel:GetValue('JOCMASTER','JOC_STATUS') == '02'
                        aItemMov := oEst:FSMTransfer( ;
                        cProduto, ;  
                        oModel:GetValue('JOCMASTER','JOC_ARMORI'), ;   // armazem de origem
                        oModel:GetValue('JOCMASTER','JOC_LOCAL'), ;    // armazem de destino
                        oModel:GetValue('JOCMASTER','JOC_ENDORI'), ;   // endereco de origem
                        oModel:GetValue('JOCMASTER','JOC_LOCLZB'), ;   // endereco  de destino 
                        nQtd, ;        
                        )
                        aAdd(aItensNew, aClone(aItemMov))
                    Else
                        aItemMov := oEst:FSMTransfer( ;
                        cProduto, ;   
                        oModel:GetValue('JOCMASTER','JOC_LOCAL'), ;      // armazem de destino
                        oModel:GetValue('JOCMASTER','JOC_ARMORI'), ;     // armazem de origem   
                        oModel:GetValue('JOCMASTER','JOC_LOCLZB'), ;     // endereco  de destino 
                        oModel:GetValue('JOCMASTER','JOC_ENDORI'), ;     // endereco de origem     
                        nQtd, ;        
                        )
                        aAdd(aItensNew, aClone(aItemMov))
                    Endif
                Next nX	 
            Endif 
            if lContinua 
                if oModel:GetValue('JOCMASTER','JOC_STATUS') == '02'   // Geração de Pedido de venda apenas com o status 02
                    lPV := GerPVKit(oModel:GetValue('JOCMASTER','JOC_CODJOA'),cMsgRet,cCodRet,;
                     oModel:GetValue('JOCMASTER','JOC_TESENT'),;
                     oModel:GetValue('JOCMASTER','JOC_CODCLI'),;
                     oModel:GetValue('JOCMASTER','JOC_LOJCLI'),;
                     oModel:GetValue('JOCMASTER','JOC_CONPAG')) 
                Endif
                IF lPV // Se gerou PV realizo a movimentação entre armazens 
                    MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3) // Geração da Movimentacao interna
                    If lMsErroAuto
                        cFileLog := NomeAutoLog()
                        cPath := "\"
                        If !Empty(cFileLog)
                            cMsgRet := MostraErro(cPath, cFileLog)
                            lRet := .F.
                            DisarmTransaction() // Desarma a treansação
                        Endif
                    Else  
                        IF lRet .And. lPV .And. oModel:GetValue("JOCMASTER","JOC_STATUS") == "02" // Se gerado Pedido de Venda, Movimentação interna e se for entrega atualiza grava o numero do Pedido de Venda
                            oModel:SetValue('JOCMASTER','JOC_NUMPED', SC5->C5_NUM) 
                        Endif    
                    Endif
                Endif
            Endif

            If oMdlJOA:VldData() .And. lRet .And. lPV
                oMdlJOA:CommitData()
            Endif
            oMdlJOA:DeActivate()
        Endif

    End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getInfAA1

@author	Vitor Kwon
@since	07/08/2025
/*/
//-------------------------------------------------------------------

Function getInfAA1(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := Posicione("AA1",1,xFilial("AA1")+JOC->JOC_CODAA1,cCampo)
 
RestArea(aAreaAA1)

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} FsmStEntr
Status do combobox das entregas do kit - campo JOC_STATUS
@author	Vitor Kwon
@since	27/08/2025
/*/
//-----
Function FsmStEntr()
Local aArea   := GetArea()
Local cOpcoes := ""
 
cOpcoes += "01=ATRIBUIDO 01;"
cOpcoes += "02=ENTREGUE 02;"
cOpcoes += "03=DEVOLVIDO 03;"
cOpcoes += "04=DEV_PARCIAL 04;"
cOpcoes += "05=DEV_TOTAL 05;"
cOpcoes += "06=PENDENTE 06;"
cOpcoes += "07=ENT_PARCIAL 07;"
cOpcoes += "08=ENT_TOTAL 08;"
cOpcoes += "09=ANALISE 07;"
cOpcoes += "10=REJEITADO 10;"
cOpcoes += "11=AGUARDANDO 11;"
cOpcoes += "12=SUCATA 12;"

RestArea(aArea)
Return cOpcoes


//-------------------------------------------------------------------

//-------------------------------------------------------------------
static Function GerPVKit(cCodigoJOA, cMsgRet, cCodRet,cTes,cCliente, cLoja,cCondPag)
Local lRet      := .T.
Local aSC5      := {}
Local aSC6      := {}
Local aLinha     := {}
Local cAliasTmp := Nil
Local nItems    := 0
Local cQuery    := ''
Local oQryTmp   := Nil
LOCAL cProduto  := ''
local nQtdPro   := 0

Default cCodigoJOA := ''
Default cMsgRet := ''
Default cCodRet := ''
Default cTes := ''
Default cCliente := ''
Default cLoja := ''
Default cCondPag := ''

Private lMsErroAuto := .F.

Begin Transaction

    cQuery := " SELECT JOB_CODPRO , JOB_CODJOA, JOB_ITEM, JOB_QUANTI"
    cQuery += " FROM " + RetSqlName('JOB') + " JOB "
    cQuery += " WHERE "
    cQuery += " JOB.JOB_FILIAL = ? "
    cQuery += " AND JOB_CODJOA = ? "
    cQuery += " AND JOB.D_E_L_E_T_ = ' ' "

    oQryTmp := FwPreparedStatement():New(cQuery)
    oQryTmp:SetString(1, xFilial("JOA"))
    oQryTmp:SetString(2, cCodigoJOA)

    cQuery    := oQryTmp:GetFixQuery()
    cAliasTmp := MpSysOpenQuery(cQuery)
    
    cDoc := GetSxeNum("SC5", "C5_NUM")
    aadd(aSC5,{"C5_NUM"    ,cDoc      , Nil})
    aAdd(aSC5,{"C5_TIPO"   ,"N"       , Nil}) 
    aAdd(aSC5,{"C5_CLIENTE",cCliente  , Nil})
    aAdd(aSC5,{"C5_LOJA"   ,cLoja     , Nil})
    aAdd(aSC5,{"C5_TIPOCLI",'F'       , Nil}) 
    aAdd(aSC5,{"C5_CONDPAG",cCondPag  , Nil})
    aAdd(aSC5,{"C5_ORIGEM" ,"FSMA039" , Nil})

    While !(cAliasTmp)->(Eof())

        nItems++

        cProduto  := criavar('B1_COD')
        cProduto  := (cAliasTmp)->JOB_CODPRO

        nQtdPro   := criavar('C6_QTDVEN')
        nQtdPro := Alltrim((cAliasTmp)->JOB_QUANTI)
        nQtdPro := val(nQtdPro)

        SB1->(DbSetOrder(1))
        SB1->(DbSeek( xFilial('SB1') + cProduto ))   

        aadd(aLinha,{"C6_ITEM",    StrZero(nItems,TamSx3("C6_ITEM")[1]), Nil})
        aadd(aLinha,{"C6_PRODUTO", cProduto     ,NIL})
        aadd(aLinha,{"C6_QTDVEN",  nQtdPro      ,Nil})
        aadd(aLinha,{"C6_PRCVEN",  SB1->B1_PRV1 ,Nil})
        aadd(aLinha,{"C6_TES",     cTes        ,Nil})
        aAdd(aLinha,{"AUTDELETA","N",Nil})

        aAdd(aSC6,aClone(aLinha))
        aLinha := {}

        (cAliasTmp)->(dbSkip())

    EndDo

    MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aSC5, aSC6, 3, .F.)

    If lMsErroAuto
        cFileLog := NomeAutoLog()
        cPath := "\"
        If !Empty(cFileLog)
            cMsgRet := MostraErro(cPath, cFileLog)
            lRet := .F.
        Endif
        DisarmTransaction()
    Endif
    

End Transaction    

Return lRet

