#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMLOCALATENDIMENTO source FSMA053 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOL - Local de Atendimento
@author flavio.martins
@since 17/02/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruJOL := FWFormStruct(1,"JOL")
Local oStruJOP := FwFormStruct(1,'JOP')
Local oCommit  := Fsm053Commit():New()

oStruJOP:AddField("Descr.Prod.","Descr.Prod.","JOP_DSCSB1","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oStruJOL:AddField("Nome", "Nome", "JOL_NOMCLI","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oStruJOL:SetProperty("JOL_NOMCLI",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JOL->JOL_CLIENT+JOL->JOL_LOJA,"A1_NOME"),"")'))

oStruJOP:SetProperty("JOP_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOP","JOP_CODIGO")'))

oStruJOP:SetProperty("JOP_DSCSB1",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JOP->JOP_CODPRO,"B1_DESC"),"")'))

oModel := MPFormModel():New('FSMA053', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOLMASTER',/*cOwner*/,oStruJOL)
oModel:SetPrimaryKey({"JOL_CODIGO"})

oModel:AddGrid('JOPDETAIL','JOLMASTER',oStruJOP )

oModel:SetRelation('JOPDETAIL', {{'JOP_FILIAL', 'xFilial("JOP")'},;
                                 {'JOP_CODJOL', 'JOL_CODIGO'}},;
                                    JOP->(IndexKey(1)))

oModel:SetDescription('Local de Atendimento - SIGAFSM')

oModel:GetModel('JOLMASTER'):SetDescription("Local de Atendimento - SIGAFSM")
oModel:GetModel('JOPDETAIL'):SetDescription("Vinculo Equipamentos")

oModel:GetModel("JOPDETAIL"):SetOptional(.T.)

oModel:InstallEvent("FSM053COMMIT", /*cOwner*/, oCommit)

Return oModel

Class Fsm053Commit FROM FwModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class Fsm053Commit

Return

Method BeforeTTS(oModel, cModelId) Class Fsm053Commit
Local nX 	  := 0
Local cCodCli := ''
Local cLoja   := ''
Local cCodPro := ''
Local cNumSer := ''
Local cCodLoc := ''	
Local lUpdAA3 := .F.

If oModel:GetOperation() == MODEL_OPERATION_UPDATE 

	For nX := 1 To oModel:GetModel("JOPDETAIL"):Length()

		oModel:GetModel("JOPDETAIL"):GoLine(nX)

		lUpdAA3 := .F.

		cCodCli := oModel:GetValue("JOPDETAIL", "JOP_CLIENT")
		cLoja   := oModel:GetValue("JOPDETAIL", "JOP_LOJA")
		cCodPro := oModel:GetValue("JOPDETAIL", "JOP_CODPRO")
		cNumSer := oModel:GetValue("JOPDETAIL", "JOP_NUMSER")

		If oModel:GetModel("JOPDETAIL"):IsInserted()

			cCodLoc := oModel:GetValue("JOPDETAIL", "JOP_CODJOL")
			lUpdAA3 := .T.

		ElseIf oModel:GetModel("JOPDETAIL"):IsUpdated() .And. oModel:GetValue("JOPDETAIL", "JOP_STATUS") == '2'

			cCodLoc := ''
			lUpdAA3 := .T.

		Endif

		If lUpdAA3
			dbSelectArea("AA3")
			AA3->(dbSetOrder(1))

			If AA3->(dbSeek(xFilial('AA3')+cCodCli+cLoja+cCodPro+cNumSer))

				AA3->(RecLock("AA3",.F.))
					AA3->AA3_CODJOL := cCodLoc
				AA3->(MsUnLock())		

			Endif

		Endif

	Next

Endif

Return .T.
