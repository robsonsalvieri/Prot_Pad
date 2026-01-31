#INCLUDE "FISA325.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE INFO_APURACAO 8
#DEFINE PROCESSAMENTO 2
#DEFINE SELECIONA_FILIAL 3
#DEFINE AGRUPA_CNPJ_IE 4
#DEFINE FIL_CENTRALIZADORA   7

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA325()

Função de apuração do IPM

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISA325()

Local oBrowse as object

oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CKG")
oBrowse:SetDescription(STR0001) //"Apuração de IPM"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef

Funcao responsável por gerar o menu.

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina as array

aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'FSA325PROC()'    OPERATION 3 ACCESS 0 //"Processar"
ADD OPTION aRotina TITLE STR0004 ACTION 'FSA325VIS()'     OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION 'FSA325EXC()' 	  OPERATION 5 ACCESS 0 //"Excluir"

Return (aRotina)


//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função que criará o modelo do cadastro das regras de apuração

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel     as object
Local oCabecalho as object
Local oApuracao  as object

oModel	   := MPFormModel():New('FISA325')
oCabecalho := FWFormStruct(1, "CKG")
oApuracao  := FWFormStruct(1, "CKH")
oDetApur   := FWFormStruct(1, "CKI")

oModel:AddFields("MODEL_CKG",,oCabecalho)
oModel:SetPrimaryKey( {"CKG_FILIAL", "CKG_ID"} )

oModel:AddGrid("MODEL_CKH", "MODEL_CKG", oApuracao)
oModel:AddGrid("MODEL_CKI", "MODEL_CKG", oDetApur)

oModel:GetModel( "MODEL_CKH" ):SetOptional( .T. )
oModel:GetModel( "MODEL_CKI" ):SetOptional( .T. )
oModel:GetModel( "MODEL_CKH" ):SetUniqueLine({"CKH_FILIAL", "CKH_IDAPUR", "CKH_UF", "CKH_DIPAM", "CKH_CODMUN"})
oModel:SetRelation("MODEL_CKH", {{"CKH_FILIAL", "xFilial('CKH')"}, {"CKH_IDAPUR", "CKG_ID"}}, CKH->(IndexKey(1))) //Relacionamento com o detalhamento da apuração
oModel:SetRelation("MODEL_CKI", {{"CKI_FILIAL", "xFilial('CKI')"}, {"CKI_IDDETA", "CKG_ID"}}, CKI->(IndexKey(1))) //Relacionamento com o relatório da apuração

oModel:SetDescription(STR0001)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função que monta a view da rotina.

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel     as object
Local oView      as object
Local oApuracao  as object
Local cCmpFolder as character

oModel     := FWLoadModel("FISA325")
oView      := FWFormView():New()
oApuracao  := Nil
cCmpFolder := ''

oView:SetModel(oModel)

cCmpFolder := "CKH_DIPAM|CKH_DSCDIP|CKH_UF|CKH_MUNICI|CKH_VLRADC|CKH_TIPO|"
oApuracao  := FwFormStruct( 2, 'CKH', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

oApuracao:SetProperty("CKH_DIPAM" , MVC_VIEW_ORDEM, "01")
oApuracao:SetProperty("CKH_DSCDIP", MVC_VIEW_ORDEM, "02")
oApuracao:SetProperty("CKH_UF"    , MVC_VIEW_ORDEM, "03")
oApuracao:SetProperty("CKH_MUNICI", MVC_VIEW_ORDEM, "04")
oApuracao:SetProperty("CKH_VLRADC", MVC_VIEW_ORDEM, "05")
oApuracao:SetProperty("CKH_TIPO"  , MVC_VIEW_ORDEM, "06")

oView:AddGrid('VIEW_APU', oApuracao, 'MODEL_CKH')
oView:SetViewProperty('VIEW_APU', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_APU', "GRIDSEEK"  , {.T.})

oView:CreateHorizontalBox('BOX', 100)

oView:SetOwnerView('VIEW_APU', 'BOX')

oView:EnableTitleView('VIEW_APU', STR0006)

oView:AddUserButton( 'Relatorio', '', { || ReportSV(oModel) },'Relatório',,{MODEL_OPERATION_VIEW},.T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA325PROC

Função que iniciará o processamento da apuração

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSA325PROC()

Local aParam   	as array
Local aFil     	as array
Local lSchedule as logical
Local cFilCentr as character
Local cChave    as character

aParam    := FISA323()
aFil      := {}
lSchedule := SSchedEnab()
cFilCentr := ""
cChave	  := ""

If Len(aParam) > 0

	If aParam[INFO_APURACAO][PROCESSAMENTO]
		aFil := x325GetFil(aParam[SELECIONA_FILIAL] == '1', aParam[AGRUPA_CNPJ_IE] == '1')

		IF Len(aFil) > 0
			cFilCentr := aParam[FIL_CENTRALIZADORA]
			cChave	  := cFilCentr + DTOS(CKG->CKG_DTINI) + DTOS(CKG->CKG_DTFIM)

			If CKG->(DbSeek(cChave))
					RecLock("CKG",.F.)
					CKG->CKG_CONAPU := '1'
					CKG->( MsUnLock( ) )
				
				If !lSchedule
					//Executa a apuração de forma manual
					ApurIpm(aFil, aParam, cChave)
				Else
					//Executa a apuração através do SMARTSCHEDULE em segundo plano
					ApurIpmSch(aFil, aParam, cChave)
				EndIf
			EndIf

		EndIf
	Else
		MsgInfo(STR0019, STR0015)//"Operação cancelada" ## "Apuração de IPM" 
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA325VIS

Função que faz a visualização da apuração.

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSA325VIS()
	if CKG->CKG_CONAPU == '2'
		FWExecView(STR0009 + DTOC(CKG->CKG_DTINI) + STR0010 +  DTOC(CKG->CKG_DTFIM), 'FISA325', MODEL_OPERATION_VIEW,, { || .T. }, { || OnClose() }) //"(Visualizando) - Período Inicial: " // " Período Final: " 
	else
		MsgInfo(STR0018,STR0015) //"A apuração deste registro ainda está em andamento. Solicitamos, por gentileza, que aguarde a conclusão." ## "Apuração de IPM" 
	endIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA325EXC

Função que faz a Exclusão da apuração

@author Wesley matos
@since 29/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSA325EXC()
	if CKG->CKG_CONAPU == '2'
		FWExecView(STR0009 + DTOC(CKG->CKG_DTINI) + STR0010 +  DTOC(CKG->CKG_DTFIM), 'FISA325', MODEL_OPERATION_DELETE,, { || .T. },,,) //"(Excluindo) - Período Inicial: " // " Período Final: " 
	else
		MsgInfo(STR0018,STR0015) //"A apuração deste registro ainda está em andamento. Solicitamos, por gentileza, que aguarde a conclusão." ## "Apuração de IPM" 
	endIf
return
//------------------------------------------------------------
/*/{Protheus.doc} x325GetFil

Função que fará tratamento das filiais selecionadas pelo usuário, e que 
serão consideradas na apuração

@author Rafael de Paula Leme
@since 11/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Function x325GetFil(lPergunta, lAgrupa)

Local aFil     as array
Local aSM0     as array
Local aAreaSM0 as array
Local nFil     as numeric

Default lPergunta := .F.
Default lAgrupa	  := .F.

aFil	 := {}
aSM0	 := {}
aAreaSM0 := {}
nFil	 := 0

If lPergunta	
    //chama função para usuário escolher filial
    aFil:= MatFilCalc(.T.,,,lAgrupa,,IIf(lAgrupa,1,0))
    If len(aFil) == 0
        MsgAlert(STR0011) //"Nenhuma filial foi selecionada, o processamento não será realizado."
    EndiF
Else	
	aAdd(aFil, {.T., SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC})
EndIF

IF Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil, {|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				aAdd(aSM0, {SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_NOME, {SM0->M0_CGC, SM0->M0_INSC}})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0

//------------------------------------------------------------
/*/{Protheus.doc} ReportSV
Função para chamada do relatório Smart View, visão de dados.

@param oModel - Object - Modelo de dados da tabela CKH para recuperar através do modelo o ID e a Filial 
como parametros na geração do relatório.

@Return Nil
@author Wesley Matos
@since 14/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function ReportSV(oModel)

Local oSmartView     as object
Local oModelCKG      as object
Local lConfig        as logical
Local cId            as character
Local cFilApu        as character
Local cDataIni		 as character
Local cDataFim		 as character

oModelCKG := oModel:GetModel( 'MODEL_CKG' )
cId 	  := oModelCKG:GetValue('CKG_ID')
cFilApu   := oModelCKG:GetValue('CKG_FILIAL')
cDataIni  := DtoS(oModelCKG:GetValue('CKG_DTINI'))
cDataFim  := DtoS(oModelCKG:GetValue('CKG_DTFIM'))

lConfig := totvs.framework.smartview.util.isConfig()

if lConfig
    oSmartView := totvs.framework.smartview.callSmartView():new('fiscal.sv.fis.ipm.dg.bra','data-grid')
    oSmartView:setParam("MV_PAR01", cId	    , "Hidden")
	oSmartView:setParam("MV_PAR02", cFilApu , "Disabled")
	oSmartView:setParam("MV_PAR03", cDataIni, "Disabled")
	oSmartView:setParam("MV_PAR04", cDataFim, "Disabled")

	oSmartView:setForceParams(.T.)
    oSmartView:executeSmartView()

	if oSmartView != Nil
		oSmartView:destroy()
		FwFreeObj(oSmartView)
	endif
else
    Alert(STR0013)//"Smart View não configurado."
endIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SSchedEnab
Função responsavel por verificar se os serviços do SMARTSCHEDULE estão ativos e funcionando
corretamente.

@Return lRet
@author Wesley Matos
@since 20/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function SSchedEnab()

Local lRet       as logical
Local lEnableSS  as logical
Local lRunningSS as logical

lRet := .F.
lEnableSS  := (FindClass("totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled") .Or. FindFunction('totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled')) .And. totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled()
lRunningSS := (FindClass("totvs.framework.smartschedule.startSchedule.smartSchedIsRunning") .Or. FindFunction('totvs.framework.smartschedule.startSchedule.smartSchedIsRunning')) .And. totvs.framework.smartschedule.startSchedule.smartSchedIsRunning()

if lEnableSS .and. lRunningSS
	lRet := .T.
endIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ApurIpm
Função responsavel por executar a apuração de IPM de forma manual

@param aFil   - Array - Filial selecionadas no combo "Seleciona Filiais".
@param aParam - Array - Parametros selecionados na tela de Wizard.
@param cChave - Character - Chave para posicionamento correto do registro na hora de alterar o status

@Return Nil
@author Wesley Matos
@since 20/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function ApurIpm(aFil, aParam, cChave)

Local aAreaSM0 	 as array
Local lRet     	 as logical
Local cMsgProc 	 as character

aAreaSM0  := SM0->(GetArea())
lRet      := .T.
cMsgProc  := ""

FwMsgRun(,{|oSay| FISA324Apu(aFil, aParam, @lRet, @cMsgProc)}, STR0007, "")
RestArea (aAreaSM0)

if CKG->(DbSeek(cChave))
	RecLock("CKG",.F.)
	CKG->CKG_CONAPU := '2'
	CKG->( MsUnLock( ) )
endIf
		
if lRet
	cMsgProc := STR0008 //"Apuração concluída com sucesso!"
endIf
	
MsgInfo(cMsgProc) 

if lRet
	FSA325VIS()
endIf

return

//-----------------------------------------------------------------
/*/{Protheus.doc} ApurIpmSch

Função responsavel por executar a apuração de IPM pelo SCHEDULE

@param aFil   - Array - Filial selecionadas no combo "Seleciona Filiais".
@param aParam - Array - Parametros selecionados na tela de Wizard.
@param cChave - Character - Chave para posicionamento correto do registro na hora de alterar o status

@Return Nil
@author Wesley Matos
@since 20/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function ApurIpmSch(aFil, aParam, cChave)

Local aParSch 	 as array
Local cGrCompany as character
Local cFil		 as character
Local cUserCode  as character
Local oTask 	 as object
Local cFunction  as character
Local cMsg		 as character
Local cEnvSched  as character
	
aParSch    := {}
cGrCompany := FWGrpCompany()
cFil	   := FWCodFil()
cUserCode  := RetCodUsr()
oTask      := Nil
cFunction  := 'Fisa324SCH'
cMsg	   := ''
cEnvSched  := GetEnvServer()
cEnv	   := SchEnv()

aAdd(aParSch, aFil)
aAdd(aParSch, aParam)
aAdd(aParSch, cChave)

if !Empty(cEnv)
    cEnvSched := cEnv
endif

cMsg := STR0016 //"A tarefa não pode ser agendada, verifique."

oTask := totvs.framework.schedule.utils.createTask(cEnvSched, cGrCompany, cFil, cFunction, 09, cUserCode,,aParSch, /*lReuse*/, .F.,.T.)
	
if !Empty(oTask)
	cMsg := STR0014 //"A tarefa foi agendada com sucesso e a apuração será executada em segundo plano pelo SMARTSCHEDULE. Caso inscrito no event viewer, o fim do processamento será informado na Central de Notificações. Para mais informações, acessa a doc: https://tdn.totvs.com.br/display/public/framework/Event+Viewer')"
endIf

MsgInfo(cMsg, STR0015) //## "Apuração de IPM"

return

/*----------------------------------------------------------------------
{Protheus.doc} SchEnv
Retorna o Environment que esta rodando o Smart Schedule

@author Wesley Matos
@since 29/08/2025
@return	cEnv 
//----------------------------------------------------------------------*/
Function SchEnv()

Local aEnvs  	as array
Local cEnv  	as character
Local oSchdInfo as object
Local cLibVers  as character

aEnvs         := {}
cEnv          := ""
oSchdInfo	  := Nil
cLibVers 	  := FwLibVersion()
	
If cLibVers >= "20250224"
	oSchdInfo  := totvs.framework.schedule.information.ScheduleInformation():New()
	aEnvs := oSchdInfo:getEnvironmentsScheduleRunning(2) // Retorna quais Environments tem Smart Schedule rodando
	If Len(aEnvs) > 0
		cEnv := aEnvs[1]
	EndIf
EndIf

Return cEnv
