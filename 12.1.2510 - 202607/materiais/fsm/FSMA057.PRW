#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMPLANOMANUT source FSMA057 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOQ - Plano de Manutenção
@author fernanda.rigolin
@since 12/05/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruJOQ := FWFormStruct(1,"JOQ")
Local oStruJOR:= FwFormStruct(1,'JOR')
Local oStruJOS:= FwFormStruct(1,'JOS')
Local oCommit  := Fsm057Commit():New()

oStruJOR:AddField("Descr. Tp. Oco.","Descr. Tipo Ocorrência","JOR_DSCJOK","C",TamSx3('JOK_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)	
oStruJOR:AddField("Descr. Serviço","Descr. Serviço","JOR_DSCJN1","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)	
oStruJOS:AddField("Descr.Prod.","Descr.Prod.","JOS_DSCSB1","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOS:AddField("Nome", "Nome", "JOS_NOMCLI","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oModel := MPFormModel():New('FSMA057', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOQMASTER',/*cOwner*/,oStruJOQ)
oModel:AddGrid('JORDETAIL','JOQMASTER',oStruJOR, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid('JOSDETAIL','JOQMASTER',oStruJOS, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:SetRelation('JORDETAIL', {{'JOR_FILIAL', 'xFilial("JOR")'},;
                                 {'JOR_CODJOQ', 'JOQ_CODIGO'}},;
                                 JOR->(IndexKey(1)))

oModel:SetRelation('JOSDETAIL', {{'JOS_FILIAL', 'xFilial("JOS")'},;
                                 {'JOS_CODJOQ', 'JOQ_CODIGO'}},;
                                 JOS->(IndexKey(1)))                                 

oStruJOR:SetProperty("JOR_DSCJOK",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOK",1,xFilial("JOK")+JOR->JOR_CODJOK,"JOK_DESCRI"),"")'))

oStruJOR:SetProperty("JOR_DSCJN1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JOR->JOR_CODJN1,"JN1_DESCRI"),"")'))

oStruJOS:SetProperty("JOS_DSCSB1",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JOS->JOS_CODPRO,"B1_DESC"),"")'))

oStruJOS:SetProperty("JOS_NOMCLI",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JOS->JOS_CLIENT+JOS->JOS_LOJA,"A1_NOME"),"")'))

oModel:SetDescription('Plano de Manutenção - SIGAFSM')
oModel:GetModel('JOQMASTER'):SetDescription("Plano de Manutenção - SIGAFSM")
oModel:GetModel('JORDETAIL'):SetDescription("Itens do Plano de Manutenção - SIGAFSM")
oModel:GetModel('JOSDETAIL'):SetDescription("Equipamentos do Plano de Manutenção - SIGAFSM")

oModel:GetModel("JOSDETAIL"):SetOptional(.T.)

oModel:SetPrimaryKey({"JOQ_CODIGO"})

oModel:InstallEvent("FSM057COMMIT", /*cOwner*/, oCommit)

Return oModel

Class Fsm057Commit FROM FwModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class Fsm057Commit

Return

Method BeforeTTS(oModel, cModelId) Class Fsm057Commit
Local nX 	  := 0
Local cCodCli := ''
Local cLoja   := ''
Local cCodPro := ''
Local cNumSer := ''
Local cCodPla := ''	
Local lUpdAA3 := .F.

If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
	For nX := 1 To oModel:GetModel("JOSDETAIL"):Length()

		oModel:GetModel("JOSDETAIL"):GoLine(nX)

		lUpdAA3 := .F.

		cCodCli := oModel:GetValue("JOSDETAIL", "JOS_CLIENT")
		cLoja   := oModel:GetValue("JOSDETAIL", "JOS_LOJA")
		cCodPro := oModel:GetValue("JOSDETAIL", "JOS_CODPRO")
		cNumSer := oModel:GetValue("JOSDETAIL", "JOS_NUMSER")

		If oModel:GetModel("JOSDETAIL"):IsInserted()

			cCodPla := oModel:GetValue("JOSDETAIL", "JOS_CODJOQ")
			lUpdAA3 := .T.

		ElseIf oModel:GetModel("JOSDETAIL"):IsDeleted() 
			cCodPla := ''
			lUpdAA3 := .T.

		Endif

		If lUpdAA3
			dbSelectArea("AA3")
			AA3->(dbSetOrder(1))

			If AA3->(dbSeek(xFilial('AA3')+cCodCli+cLoja+cCodPro+cNumSer))
				AA3->(RecLock("AA3",.F.))
					AA3->AA3_CODJOQ := cCodPla
				AA3->(MsUnLock())		

			Endif

		Endif

	Next
    oModel:SetValue('JOQMASTER', 'JOQ_QTDEQP', oModel:GetModel("JOSDETAIL"):Length(.T.))
Endif

Return .T.

