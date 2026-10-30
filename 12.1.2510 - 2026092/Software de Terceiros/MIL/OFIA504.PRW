#include "tbiconn.ch"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "OFINJD31.ch"

// FLAGS_DISPONIVEIS = |V
// touch 20191127

Static oModel01
Static oModel02
Static oView
static oEventDef
static lIndVB8CODIGO
static jMem14 := JsonObject():New()
static jMem17 := JsonObject():New()

/*/{Protheus.doc} OFIA504
	Geração de dados diária para o DPM John Deere
	
	@type function
	@author Vinicius Gati
	@since 27/08/2013
/*/
Function OFIA504(aParam,  lSoGer, cLog, cConta)
	Local lSchedule	:= isBlind()
	default cLog	:= ""
	private lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	private jMemCP := JsonObject():New()

	if oEventDef == NIL
		oEventDef := OFIA504EVDEF():New(cLog)
	endif

	if lSchedule
		Processa({|| OA504024_PROCESSO(aParam, lSoGer, cConta) })
	else
		FWExecView(STR0001, "OFIA504", MODEL_OPERATION_INSERT)
	endif
Return .F.
   
/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author BrunoForcato
	@since 07/10/2025
/*/
static function ViewDef()
	Local oModel	:= Modeldef()
	Local oStr1		:= oModel01:GetView()
	local oStr2		:= oModel02:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('BOX_VERT_1', 20)
	oView:CreateHorizontalBox('BOX_VERT_2', 80)

	oView:AddField('CONTAS', oStr1, 'CONTAS')
	oView:AddField('LOGS', oStr2, 'LOGS')

	oView:SetOwnerView('CONTAS','BOX_VERT_1')
	oView:SetOwnerView('LOGS','BOX_VERT_2')

	oView:EnableTitleView('CONTAS'  , STR0038) //Contas
	oView:EnableTitleView('LOGS'    , STR0039) //Logs

	oView:SetModified(.t.)
	oView:SetCloseOnOk({|| .T.})
	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)
	oView := oView
return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@type function
	@author BrunoForcato
	@since 07/10/2025
/*/
static function ModelDef()
	Local oModel
	Local oStr1
	Local oStr2

	If oModel01 == NIL
		oModel01 := GetModel01()
		oModel02 := GetModel02()
	EndIf

	if oEventDef == NIL 
		oEventDef  := OFIA504EVDEF():New()
	EndIf

	oStr1 := oModel01:GetModel()
	oStr2 := oModel02:GetModel()

	oModel := MPFormModel():New('OFIA504',,,{ |oModel| OA50400124_Processar(oModel) })
	oModel:SetDescription(STR0040) // Geração de dados diária
	
	oModel:AddFields("CONTAS",,oStr1,{ |a,b,c| OA50400114_BPRE_CONTAS(a,b,c) })
	oModel:GetModel("CONTAS"):SetDescription(STR0041) //Campos relacionado as contas

	oModel:AddFields("LOGS","CONTAS",oStr2,,,{|| OA50400102_BuscaLog() })
	oModel:GetModel("LOGS"):SetDescription(STR0042) //Campo de Log do processamento

	oModel:InstallEvent("OFIA504", /*cOwner*/, oEventDef)
	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author BrunoForcato
	@since 07/10/2025
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	Local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	Local nX := 1
	Local aOpcoes := {}
	Local bInit := { || "" }

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			aadd(aOpcoes, aContas[nX] + "=" + alltrim(aContas[nX]))
		next
	else
		aOpcoes := {"OLD=CONTA UNICA"}
		bInit := { || "OLD" }
	endif
	
	oMd1:AddField({;
		{'cTitulo'  , STR0038 },; // Contas
		{'cIdField' , "OFA_CONTA" },;
		{'aComboValues', aOpcoes},;
		{'bInit', bInit},;
		{'nTamanho' , 20 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0044 } ; // "Nome da conta para fazer a geração do DPM"
	})
return oMd1

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function GetModel02()
	Local oMd2 := OFDMSStruct():New()
	oMd2:AddField({;
		{'cTitulo'  , STR0043 },; // "Logs da Geração do DPM"
		{'cIdField' , "OFA_LOG" },;
		{'cTipo', "M"},;
		{'bInit', {|| oEventDef:cLog }},;
		{'nTamanho' , 99999 },;
		{'lObrigat' , .f. },;
		{'cTooltip' , STR0045 }; //"Log do processo de geração do DPM"
	})
return oMd2

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

	@author Vinicius Gati
	@since 02/12/2019
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/{Protheus.doc} PROCESSO
	Processamento

	@type function
	@author Vinicius Gati
	@since 02/12/2019
/*/
Function OA504024_PROCESSO(aParam, lSoGer, cConta, oModel)
Local nCont
Local cFilBkp
Local aFilAtu
local cAl
Local cQuery         := ""
local aFilis         := {}
Local oBase
Local oView := FWViewActive()
Local aSegLoc        := {}
Local aRetAux        := {}
Local nPosFilis      := 0
Private cTimeStmp4Log := dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2)
Private cSQLPedNF    := GetNextAlias()
Private cSQLSD2Abe   := GetNextAlias()
Private cSQLVdaPer   := GetNextAlias()
Private cSQLMovInt   := GetNextAlias()
Private aDtReproc    := {}
Private oLogger      := nil
Private oLogQueries  := nil
Private oLogDebug    := nil
Private cTblLogCod   := ""
Private cInGrupos    := ""
Private oSqlHlp      := DMS_SqlHelper():New()
Private oDs          := DMSB_DirectShipment():New()
Private oDpePecas    := DMSB_DpePecas():New(cConta)
Private oDemDpm      := DMS_DemandaDPM():New()
Private oDpm         := OFJDRpmConfig():New(,,cConta)
Private oRPM         := OFJDConfig():New(nil, cConta)
Private oArHelp      := DMS_ArrayHelper():New()
Private lDebug       := .f.
Private lAuto        := FWGetRunSchedule()
Private cDadosProd   := oDpm:getTabelaDadosAdc()
Private lNovoCombo := GetNewPar("MV_MIL0210", .F.)
Private lVS1REMITO := VS1->(fieldPos("VS1_REMITO")) > 0
cInGrupos := oDpm:GetInGroups()

lMultiMoeda := FGX_MULTMOEDA()

if !empty(oModel)
	oBase := oModel:GetModel("LOGS")
endif

if lSoGer
	lAuto := .t. 
endif

if ! oDpm:Ready()
	if ! lAuto
		MsgInfo(oDpm:cLastError, '')
	endif
	Return .F.
endif

oLogger   := DMS_Logger():New("OFIA504_" + cTimeStmp4Log + ".LOG")
oLogDebug := DMS_Logger():New("OFIA504_DBG_" + cTimeStmp4Log + ".LOG")
oLogQueries := DMS_Logger():New("OFIA504_queries_" + cTimeStmp4Log + ".LOG")
lDebug    := oDpm:DebugMode()

conout("OFIA504 -> Iniciando rotina <-")
ProcRegua(5)

if lDebug
	oLogDebug:Log({"OFIA504 -> Modo debug ativado <-"})
endif

if valtype(cConta) != "U"
	oLogger:Log({'TIMESTAMP', STR0008 + iif(lAuto, STR0009, STR0010) + " " + STR0011 + DTOS(dDatabase) + "("+FWTimeStamp(5)+") - " + STR0046 + ": " + cConta}) // "OFIA504 rodado em modo: " / "Agendado" / "Data: "
else
	oLogger:Log({'TIMESTAMP', STR0008 + iif(lAuto, STR0009, STR0010) + " " + STR0011 + DTOS(dDatabase) + "("+FWTimeStamp(5)+") "}) // "OFIA504 rodado em modo: " / "Agendado" / "Data: "
endif
cTblLogCod := oLogger:LogToTable({;
	{'VQL_AGROUP'     , 'OFINJD31' },;
	{'VQL_TIPO'       , 'LOG_EXECUCAO' },;
	{'VQL_DADOS'      , 'MODO: '  + iif(lAuto, STR0009, STR0010) } ;
})

aFilAtu   := FWArrFilAtu()
cFilBkp   := cFilAnt

aFilis := oDpm:GetFiliais()
If oDpm:lNovaConfiguracao
    For nPosFilis := 1 to len(aFilis)
        aAdd(aSegLoc,{ aFilis[nPosFilis,1] , aFilis[nPosFilis,3] , oDpm:oNovaConfiguracao:PrimArmazemProvavel( aFilis[nPosFilis,3] ,aFilis[nPosFilis,1] ) })
    Next
EndIf
aFilis := oArHelp:Select(aFilis, { |aFilData| ! Empty(aFilData[1]) }) // removendo os em branco pra evitar problemas
aFilis := oArHelp:Map(aFilis, { |aFilData| { aFilData[1] } }) // map para remover o segmento
aFilis := oArHelp:Uniq(aFilis) // unique para pegar 1 filial somente sem repetir o detalhe é que o processamento não precisa separar por segmento

// Coleta das peças e atualização das peças direct shipment
// importante que seja após a criação dos SB5 por conta de peças que não tenham o cadastro completo
oDS:AtualizarPecas()
oDpePecas:ColetaItensDia()

if oDpm:getTabelaDadosAdc() == "SBZ"
	oLogger:Log({cFilAnt+STR0013+ " ("+FWTimeStamp(5)+")"}) //" Cria SBZ para todos os SB1"
	For nCont := 1 to Len(aFilis)
		oDpePecas:CriaSBZFaltantes()
	Next
else
	oLogger:Log({cFilAnt+STR0016+ " ("+FWTimeStamp(5)+")"}) //" Cria SB5 para todos os SB1"
	For nCont := 1 to Len(aFilis)
		oDpePecas:CriaSB5Faltantes()
	Next
endif

IncProc(STR0051) // "Levantando Dados"
For nCont := 1 to Len(aFilis)
	cFilAnt := aFilis[nCont,1]
	cDadosProd := oDpm:getTabelaDadosAdc()

	if Alltrim(cDadosProd) == "SBZ"
		oLogger:Log( {cFilAnt+STR0014+ " ("+FWTimeStamp(5)+")"} ) //" Levantamento ULTVDA baseado no SD1"

		// ==============================================
		// LEVANTA DATEADDED BASEADO NO SD1
		// ==============================================
		cAl := GetNextAlias()
		cQuery := "SELECT SBZ.R_E_C_N_O_ BZRECNO , MIN(D1_DTDIGIT) ENTRADA FROM " + oSqlHlp:NoLock("SD1")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ =  ' ' "
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = D1_COD AND SBZ.D_E_L_E_T_ =  ' ' AND BZ_PRIENT = ' ' "
		cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SBZ.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
		DBSelectArea("SBZ")
		While !(cAl)->(Eof())
			DbGoTo((cAl)->(BZRECNO))
			reclock("SBZ",.f.)
			SBZ->BZ_PRIENT := stod((cAl)->(ENTRADA))
			msunlock()
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())

		oLogger:Log( {cFilAnt+STR0015+ " ("+FWTimeStamp(5)+")"} ) // " Levantamento ULTVDA baseado no VB8"

		// ==============================================
		// LEVANTAMENTO ULTVDA BASEADO NO VB8
		// ==============================================
		cAl := GetNextAlias()
		cQuery := "SELECT SBZ.R_E_C_N_O_ BZRECNO, MAX(VB8_ANO "+FG_CONVSQL("CONCATENA")+" VB8_MES "+FG_CONVSQL("CONCATENA")+" VB8_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VB8")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = VB8_PRODUT AND SBZ.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VB8_ANO > '" + cValToChar(Year(MonthSub(dDataBase,36))) + "' AND (VB8_VDAB > 0 OR VB8_VDAO > 0 ) AND VB8_FILIAL = '"+xFilial("VB8")+"' AND VB8.D_E_L_E_T_ =  ' '"
		cQuery += " GROUP BY SBZ.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
		DBSelectArea("SBZ")
		While !(cAl)->(Eof())
			DbGoTo((cAl)->(BZRECNO))
			if SBZ->BZ_ULTVDA < stod((cAl)->(ULTVDA))
				reclock("SBZ",.f.)
				SBZ->BZ_ULTVDA := stod((cAl)->(ULTVDA))
				msunlock()
			endif
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
	EndIf

	if Alltrim(cDadosProd) == "SB5"
		oLogger:Log( {cFilAnt+STR0017+ " ("+FWTimeStamp(5)+")"} ) // " Levantamento DATEADDED baseado no SD1"
		// ==============================================
		// LEVANTA DATEADDED BASEADO NO SD1
		// ==============================================
		cAl := GetNextAlias()
		cQuery := "SELECT  SB5.R_E_C_N_O_ B5RECNO , MIN(D1_DTDIGIT) ENTRADA FROM " + oSqlHlp:NoLock("SD1")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ =  ' '"
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB5") + " ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = D1_COD AND SB5.D_E_L_E_T_ =  ' ' AND B5_DTADDED = ' '"
		cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SB5.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
		DBSelectArea("SB5")
		While !(cAl)->(Eof())
			DbGoTo((cAl)->(B5RECNO))
			reclock("SB5",.f.)
			SB5->B5_DTADDED := stod((cAl)->(ENTRADA))
			msunlock()
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())

		oLogger:Log( {cFilAnt+STR0018+ " ("+FWTimeStamp(5)+")"} ) //" Levantamento ULTVDA baseado no VB8"

		// ==============================================
		// LEVANTAMENTO ULTVDA BASEADO NO VB8
		// ==============================================
		cAl := GetNextAlias()
		cQuery := "SELECT SB5.R_E_C_N_O_ B5RECNO, MAX(VB8_ANO "+FG_CONVSQL("CONCATENA")+" VB8_MES "+FG_CONVSQL("CONCATENA")+" VB8_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VB8")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB5") + " ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = VB8_PRODUT AND SB5.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VB8_ANO > '" + cValToChar(Year(MonthSub(dDataBase,36))) + "' AND (VB8_VDAB > 0 OR VB8_VDAO > 0 ) AND VB8_FILIAL = '"+xFilial("VB8")+"' AND VB8.D_E_L_E_T_ =  ' '"
		cQuery += " GROUP BY SB5.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
		DBSelectArea("SB5")
		While !(cAl)->(Eof())
			DbGoTo((cAl)->(B5RECNO))
			if SB5->B5_ULTVDA < stod((cAl)->(ULTVDA))
				reclock("SB5",.f.)
				SB5->B5_ULTVDA := stod((cAl)->(ULTVDA))
				msunlock()
			endif
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		//
	endif
next

oLogger:Log( {STR0019+ " ("+FWTimeStamp(5)+")"} ) //"Flag notas canceladas na data"

// collects the cancelled invoice dates 
cQuery := ""
cQuery += " select distinct D2_FILIAL, D2_EMISSAO, D2_COD "
cQuery += "   from "+oSqlHlp:NoLock("SD2")
cQuery += "  where D_E_L_E_T_ = '*' "
cQuery += "    and D2_FLGNAT  <> ' ' "
cQuery += "    and D2_FLGNAT  <> 'X' "
cQuery += "    and D2_FLGNAT  <> 'C' "
cQuery += "    and D2_EMISSAO >= '"+dtos(ddatabase-60)+"' "

aDtReproc := oSqlHlp:GetSelectArray(cQuery, 3)
for nCont := 1 to len(aDtReproc)
	JD3100024_TouchItemDelta(aDtReproc[nCont, 3], "", aDtReproc[nCont, 1]) // força o reenvio da peça cancelada
	oDpm:ClrDemanda(stod(aDtReproc[nCont, 2])) // limpa a demanda das notas canceladas do dia
next

oLogger:Log( {STR0020+ " ("+FWTimeStamp(5)+")"} ) //"Flag notas canceladas processadas"

// flagging the cancelled invoices as processed
cQuery := ""
cQuery += " update "+RetSqlName('SD2')
cQuery += "    set D2_FLGNAT  = 'X' "
cQuery += "  where D_E_L_E_T_ = '*' "
cQuery += "    and D2_FLGNAT  <> 'X' "
cQuery += "    and D2_FLGNAT  <> 'C' "
cQuery += "    and D2_EMISSAO >= '"+dtos(ddatabase-60)+"' "
TcSqlExec(cQuery)


// =====================================
// Reprocessamento de NA oficina e pecas
// =====================================

// ordens de servico
//aOssToRep := oDpm:OssToReproc()
IncProc(STR0047)
oLogger:Log( {STR0021+ " ("+FWTimeStamp(5)+")"} ) //"Reprocessamento de NA oficina e pecas"
aOrcToRep := oDpm:OrcsToReproc()
oArHelp:Map(aOrcToRep, {|oEl| oDpm:ResetDemOrc(oEl:GetValue('VQL_FILORI'), oEl:GetValue('VQL_DADOS')) })

TcSqlExec(" UPDATE " + RetSQLName('VQL') + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = 'OFINJD31' AND VQL_TIPO IN ('REPROC_OS', 'REPROC_ORC') ")

dDataCorte := dDatabase - 90 // 90 dias atrás, usado para limpar dados no fim do programa


// ==============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO OFICINA
// ==============================================
IncProc(STR0048)
oLogger:Log( {STR0022+ " ("+FWTimeStamp(5)+")"} ) //"Calculando Nivel de Atendimento Oficina"

For nCont := 1 to Len(aFilis)
	cFilAnt    := aFilis[nCont,1]

	oLogger:Log( {cFilAnt+ STR0023 + "("+FWTimeStamp(5)+")"} ) //" iniciando em: "

	// ajustes para gravacoes erradas (talvez um dia removemos)
	if lNovoCombo
		dDataUpd := dDatabase - 2

		cSeguni := OA50400164_MemSegmtoUnico(cFilAnt)
		if cSeguni != "-" // tem um so segmento entao posso gravar tudo com ele
			TcSqlExec(" UPDATE "+RetSQLName('VS1')+" SET VS1_SEGMTO = '"+cSeguni+"' WHERE VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1_DATORC >= '"+dtos(dDataUpd)+"' AND VS1_TIPORC in ('P','1','2') AND VS1_SEGMTO = ' ' AND D_E_L_E_T_ = ' ' ")
			TcSqlExec(" UPDATE "+RetSQLName('VO1')+" SET VO1_SEGMTO = '"+cSeguni+"' WHERE VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1_DATABE >= '"+dtos(dDataUpd)+"' AND VO1_SEGMTO = ' '  AND D_E_L_E_T_ = ' ' ")
		endif

		cAccUni := OA50400174_MemAccUnico(cFilAnt)
		if cAccUni != "-" 
			TcSqlExec(" UPDATE "+RetSQLName('VS1')+" SET VS1_ACCRPM = '"+cAccUni+"' WHERE VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1_DATORC >= '"+dtos(dDataUpd)+"' AND VS1_TIPORC in ('P','1','2') AND VS1_ACCRPM = ' ' AND D_E_L_E_T_ = ' ' ")
			TcSqlExec(" UPDATE "+RetSQLName('VO1')+" SET VO1_ACCRPM = '"+cAccUni+"' WHERE VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1_DATABE >= '"+dtos(dDataUpd)+"' AND VO1_ACCRPM = ' ' AND D_E_L_E_T_ = ' ' ")
		endif
	endif

	//
	// Nivel Atendimento oficina via orcamento por fases
	//
	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT VO1_NUMOSV, F4_OPEMOV, F4_ESTOQUE, SD2.R_E_C_N_O_ CODIGO, VO1_SEGMTO, VOO_LOJA, VOO_FATPAR, VS3.R_E_C_N_O_ CODIGO2, VS3_CODSIT, D2_COD, B1_COD, B1_CRICOD, D2_CLIENTE, D2_LOJA, D2_EMISSAO, BM_PROORI, D2_TOTAL, D2_CUSTO1, D2_QUANT, VS3_QESTNA, VS3_QTDINI, VS1_SEGMTO, VS3_LOCAL, F2_MOEDA "
	if lNovoCombo
		cQuery += " ,VS1.VS1_ACCRPM "
	endif
	cQuery += "        FROM " + oSqlHlp:NoLock("SD2") + " "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SF2") + " ON F2_FILIAL  = '"+xFilial("SF2")+"' AND F2_DOC        = D2_DOC        AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL  = '"+xFilial("SF4")+"' AND SD2.D2_TES    = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD        = D2_COD        AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO  = SBM.BM_GRUPO  AND BM_VAIDPM = '1'         AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VOO") + " ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMNFI    = D2_DOC        AND VOO_SERNFI = D2_SERIE   AND VOO_TOTPEC     > 0      AND VOO.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VO1") + " ON VO1_FILIAL = '"+xFilial('VO1')+"' AND VO1_NUMOSV    = VOO_NUMOSV    AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS1") + " ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMOSV    = VOO_NUMOSV    AND VS1_TIPORC = '2'        AND VS1_TIPTEM = VOO_TIPTEM AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3_FILIAL = VS1_FILIAL           AND VS3_NUMORC    = VS1_NUMORC    AND VS3_CODITE = B1_CODITE  AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_COD = B1_COD AND D2_QUANT > 0 AND D2_FLGNAT = ' ' AND VS3_MOTPED = ' ' AND SD2.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cAl)->(Eof())
		cCod := ""
		if OA5040014_VerificaDupl((cAl)->(CODIGO))
			(cAl)->(DBSkip())
			loop
		endif

		if Alltrim((cAl)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cAl)->(F4_OPEMOV)) != '05'
			OA50400024_FlagaD2((cAl)->(CODIGO), "V")
			(cAl)->(DBSkip())
			loop
		endif

		cStock := iif((cAl)->(VS3_QESTNA) == 0, "N", "S")

		aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cAl)->(VS1_SEGMTO) , (cAl)->VS3_LOCAL )
		cSegmto := aRetAux[1]
		cNNRCod := aRetAux[2]

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8') },;
			{'VB8_PRODUT' , (cAl)->(B1_COD)},;
			{'VB8_CODCLI' , (cAl)->(VOO_FATPAR)},;
			{'VB8_LOJCLI' , (cAl)->(VOO_LOJA)},;
			{'VB8_CRICOD' , (cAl)->(B1_CRICOD)},;
			{'VB8_ANO'    , Left((cAl)->(D2_EMISSAO),4)},;
			{'VB8_MES'    , Subs((cAl)->(D2_EMISSAO),5,2)},;
			{'VB8_DIA'    , Subs((cAl)->(D2_EMISSAO),7,2)},;
			{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1")},;
			{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")},;
			{'VB8_STOCK'  , cStock},;
			{'VB8_SEGMTO' , cSegmto},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_NNRCOD' , cNNRCod},;
			{'VB8_PROCES' , "N"};
		})

		if lNovoCombo
			aDados   := OA50400094_CertoOuPrincipal((cAl)->(VS1_SEGMTO), (cAl)->(VS1_ACCRPM))
			oDados:SetValue('VB8_ACCRPM', aDados[2])
		else
			aDados   := OA50400094_CertoOuPrincipal((cAl)->(VS1_SEGMTO), "")
		endif
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		oDados:SetValue('VB8_NUMOSV', (cAl)->(VO1_NUMOSV))

		oDem := DMS_DataContainer():New({})

		nTotMoeda := FG_MOEDA( (cAl)->(D2_TOTAL) , (cAl)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cAl)->(D2_EMISSAO))
		nCusMoeda := (cAl)->(D2_CUSTO1)

		If FS_ConsDem( (cAl)->(VS3_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFI' , nTotMoeda          },;
				{'VB8_CUSOFI' , nCusMoeda          },;
				{'VB8_HITSO'  , 1                  },;
				{'VB8_VDAO'   , (cAl)->(D2_QUANT)  };
			})
			if (cAl)->(VS3_QESTNA) >= (cAl)->(VS3_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDO', 1)
			endif
		ElseIf FS_isEspecial( (cAl)->(VS3_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFN' , nTotMoeda          },;
				{'VB8_CUSOFN' , nCusMoeda          },;
				{'VB8_HITSON' , 1                  },;
				{'VB8_VDAON'  , (cAl)->(D2_QUANT)  } ;
			})
			if (cAl)->(VS3_QESTNA) >= (cAl)->(VS3_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDON', 1)
			endif
		EndIf

		if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cAl)->(B1_COD), (cAl)->(VO1_SEGMTO))
			oLogDebug:Log({ "FILIAL: " + xFilial('VB8') + " " + "PRODUT: " + (cAl)->(B1_COD) + " " + "SEGMENTO:" + cValToChar((cAl)->(VO1_SEGMTO)) + " " + "VO1_NUMOSV:" + (cAl)->(VO1_NUMOSV) + " " + "VB8: " + cCod + " " + "PENEIRA: P1" })
		endif

		begin transaction
			cCod := OA50401_GravaDem(oDados, oDem)

			VS3->(DbGoTo((cAl)->(CODIGO2)))
			OA50400054_FlagaVS3((cAl)->(CODIGO2), IIF(VS3->VS3_FLGNAT == '!', "Z", "O"))
			OA50400024_FlagaD2((cAl)->(CODIGO), "N")
		end transaction

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0025 +"("+FWTimeStamp(5)+")"} ) //" termino segunda peneira de dados : "

	//
	// Nível de atendimento oficina faturados
	//
	cAl    := GetNextAlias()
	cQuery := " SELECT DISTINCT VO1_NUMOSV, VSJ.R_E_C_N_O_ CODIGO_VSJ, VOO.R_E_C_N_O_ CODIGO_VOO, SD2.R_E_C_N_O_ CODIGO_SD2, VSJ_CODSIT, B1_COD, B1_CRICOD, "
	if lNovoCombo
		cQuery += " VO1.VO1_ACCRPM, "
	endif
	cQuery += "        F4_OPEMOV, F4_ESTOQUE, D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_TOTAL, D2_CUSTO1, D2_QUANT, D2_DOC, D2_SERIE, VSJ_QESTNA, BM_PROORI, VSJ_QESTNA, VSJ_QTDINI, VO1_SEGMTO, VSJ_NNRCOD, F2_MOEDA "
	cQuery += "  FROM "+oSqlHlp:NoLock('SD2')
	cQuery += "  JOIN "+oSqlHlp:NoLock("SF2")+" ON F2_FILIAL  = '"+xFilial("SF2")+"' AND F2_DOC     = D2_DOC     AND F2_SERIE = D2_SERIE     AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock("SF4")+" ON F4_FILIAL  = '"+xFilial("SF4")+"' AND D2_TES     = F4_CODIGO  AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD     = D2_COD     AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('SBM')+" ON BM_FILIAL  = '"+xFilial("SBM")+"' AND B1_GRUPO   = BM_GRUPO   AND BM_GRUPO IN " + cInGrupos + " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VEC')+" ON VEC_FILIAL = '"+xFilial('VEC')+"' AND VEC_NUMNFI = D2_DOC     AND VEC_SERNFI = D2_SERIE   AND VEC.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VOO')+" ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMOSV = VEC_NUMOSV AND VOO_TIPTEM = VEC_TIPTEM AND D2_COD = VEC_CODITE AND VOO.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock("VO1")+" ON VO1_FILIAL = '"+xFilial('VO1')+"' AND VO1_NUMOSV = VOO_NUMOSV    AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VO3')+" ON VO3_FILIAL = '"+xFilial('VO3')+"' AND VO3_VECREL = VEC_NUMREL AND VO3_CODITE = VEC_CODITE AND VO3_NUMNFI = D2_DOC AND VO3_SERNFI = D2_SERIE AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VSJ')+" ON VSJ_FILIAL = '"+xFilial('VSJ')+"' AND VSJ_CODITE = D2_COD     AND VSJ_CODITE = VO3_CODITE AND VO3_CODVSJ = VSJ_CODIGO AND VSJ.D_E_L_E_T_ =  ' ' "
	cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery += "   AND D2_FLGNAT  = ' ' "
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cAl)->(Eof())
		cStock := iif((cAl)->(VSJ_QESTNA) == 0, "N", "S")

		if OA5040014_VerificaDupl((cAl)->(CODIGO_SD2))
			(cAl)->(DBSkip())
			loop
		endif

		if Alltrim((cAl)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cAl)->(F4_OPEMOV)) != '05'
			OA50400024_FlagaD2((cAl)->(CODIGO_SD2), "U")
			(cAl)->(DBSkip())
			loop
		endif

		aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cAl)->(VO1_SEGMTO) , (cAl)->VSJ_NNRCOD )
		cSegmto := aRetAux[1]
		cNNRCod := aRetAux[2]

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8')                           },;
			{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
			{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
			{'VB8_CODCLI' , (cAl)->(D2_CLIENTE)                      },;
			{'VB8_LOJCLI' , (cAl)->(D2_LOJA)                         },;
			{'VB8_ANO'    , Left((cAl)->(D2_EMISSAO),4)              },;
			{'VB8_MES'    , Subs((cAl)->(D2_EMISSAO),5,2)            },;
			{'VB8_DIA'    , Subs((cAl)->(D2_EMISSAO),7,2)            },;
			{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
			{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
			{'VB8_STOCK'  , cStock                                   },;
			{'VB8_NNRCOD' , cNNRCod                                  },;
			{'VB8_TIPREG' , "N"                                      },;
			{'VB8_PROCES' , "N"                                      } ;
		})

		if lNovoCombo
			aDados   := OA50400094_CertoOuPrincipal((cAl)->(VO1_SEGMTO), (cAl)->(VO1_ACCRPM))
			oDados:SetValue('VB8_ACCRPM', aDados[2])
		else
			aDados   := OA50400094_CertoOuPrincipal((cAl)->(VO1_SEGMTO), "")
		endif
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		oDados:SetValue('VB8_NUMOSV', (cAl)->(VO1_NUMOSV))

		oDem := DMS_DataContainer():New({})

		nTotMoeda := FG_MOEDA( (cAl)->(D2_TOTAL) , (cAl)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cAl)->(D2_EMISSAO))
		nCusMoeda := (cAl)->(D2_CUSTO1)

		If FS_ConsDem( (cAl)->(VSJ_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFI' , nTotMoeda  },;
				{'VB8_CUSOFI' , nCusMoeda },;
				{'VB8_HITSO'  , 1                  },;
				{'VB8_VDAO'   , (cAl)->(D2_QUANT)  };
			})
			if (cAl)->(VSJ_QESTNA) >= (cAl)->(VSJ_QTDINI)
				oDem:SetValue('VB8_IMEDO', 1)
			endif
		ElseIf FS_isEspecial( (cAl)->(VSJ_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFN' , nTotMoeda  },;
				{'VB8_CUSOFN' , nCusMoeda },;
				{'VB8_HITSON' , 1                  },;
				{'VB8_VDAON'  , (cAl)->(D2_QUANT)  } ;
			})
			if (cAl)->(VSJ_QESTNA) >= (cAl)->(VSJ_QTDINI)
				oDem:SetValue('VB8_IMEDON', 1)
			endif
		EndIf

		if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cAl)->(B1_COD), (cAl)->(VO1_SEGMTO))
			oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cAl)->(B1_COD) +" "+ "SEGMENTO:" + cValToChar((cAl)->(VO1_SEGMTO)) +" "+ "VO1_NUMOSV:" + (cAl)->(VO1_NUMOSV) +" "+ "VB8: " + cCod +" "+ "PENEIRA: P2" })
		endif

		begin transaction
			cCod := OA50401_GravaDem(oDados, oDem)
			OA50400034_FlagaVSJ((cAl)->(CODIGO_VSJ), 'A')
			OA50400044_FlagaVOO((cAl)->(CODIGO_VOO), 'A')
			OA50400024_FlagaD2((cAl)->(CODIGO_SD2), 'A')
		end transaction

		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0024+ "("+FWTimeStamp(5)+")"} ) //" termino primeira peneira de dados : "

	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT VO1_NUMOSV, VSJ.R_E_C_N_O_ CODIGO, VSJ_NUMOSV, VSJ_CODSIT, VSJ_FATPAR, VSJ_LOJA, B1_COD, B1_CRICOD, VSJ_QTDINI, VSJ_DATREQ, BM_PROORI, VSJ_QESTNA, VO1_SEGMTO, VSJ_NNRCOD "
	if lNovoCombo
		cQuery += " ,VO1.VO1_ACCRPM "
	endif
	cQuery += "        FROM " + oSqlHlp:NoLock("VSJ")
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VO1") + " ON VO1_FILIAL = '"+xFilial('VO1')+"' AND VO1_NUMOSV     = VSJ_NUMOSV    AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE      = VSJ_CODITE    AND B1_GRUPO   = VSJ_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO   = SBM.BM_GRUPO  AND BM_GRUPO IN " + cInGrupos + " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE VSJ_FILIAL = '"+xFilial('VSJ')+"' AND VSJ_ORIDAD = '4' AND VSJ_FLGNAT = ' ' AND VSJ_MOTPED in ("+oDpm:GetOfiInMotivosVPRpm()+") AND VSJ.D_E_L_E_T_ =  ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	oLogQueries:Log({cQuery})

	While !(cAl)->(Eof())
		cStock := iif((cAl)->(VSJ_QESTNA) == 0, "N", "S")

		begin transaction
			If FS_ConsDem( (cAl)->(VSJ_CODSIT) )

				aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cAl)->(VO1_SEGMTO) , (cAl)->VSJ_NNRCOD )
				cSegmto := aRetAux[1]
				cNNRCod := aRetAux[2]

				oDados := DMS_DataContainer():New({;
					{'VB8_FILIAL' , xFilial('VB8')                           },;
					{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
					{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
					{'VB8_CODCLI' , (cAl)->(VSJ_FATPAR)                      },;
					{'VB8_LOJCLI' , (cAl)->(VSJ_LOJA)                        },;
					{'VB8_ANO'    , Left((cAl)->(VSJ_DATREQ),4)              },;
					{'VB8_MES'    , Subs((cAl)->(VSJ_DATREQ),5,2)            },;
					{'VB8_DIA'    , Subs((cAl)->(VSJ_DATREQ),7,2)            },;
					{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
					{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
					{'VB8_NNRCOD' , cNNRCod                                  },;
					{'VB8_STOCK'  , cStock                                   },;
					{'VB8_TIPREG' , "N"                                      },;
					{'VB8_PROCES' , "N"                                      } ;
				})

				if lNovoCombo
					aDados   := OA50400094_CertoOuPrincipal((cAl)->(VO1_SEGMTO), (cAl)->(VO1_ACCRPM))
					oDados:SetValue('VB8_ACCRPM', aDados[2])
				else
					aDados   := OA50400094_CertoOuPrincipal((cAl)->(VO1_SEGMTO), "")
				endif
				oDados:SetValue('VB8_SEGMTO', aDados[1])
				oDados:SetValue('VB8_NUMOSV', (cAl)->(VO1_NUMOSV))

				oDem := DMS_DataContainer():New({;
					{'VB8_VDPERO' ,iif((cAl)->(VSJ_QTDINI) <= 0 , 1, (cAl)->(VSJ_QTDINI)) },;
					{'VB8_HIPERO' , 1                   } ;
				})

				cCod := OA50401_GravaDem(oDados, oDem)
			EndIf

			if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cAl)->(B1_COD), (cAl)->(VO1_SEGMTO))
				oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cAl)->(B1_COD) +" "+ "SEGMENTO:" + cValToChar((cAl)->(VO1_SEGMTO)) +" "+ "VSJ_NUMOSV:" + (cAl)->(VSJ_NUMOSV) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P3" })
			endif

			OA50400034_FlagaVSJ((cAl)->(CODIGO), 'R')
		end transaction

		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())

	//
	// Vendas perdidas oficina via orcamento por fases
	//
	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT VS1_NUMORC, VS3.R_E_C_N_O_ CODIGO, VS3_CODSIT, B1_COD, B1_CRICOD, VS1_CLIFAT, VS1_LOJA, VS1_DATORC, VS3_QTDINI, VS3_QTDITE, BM_PROORI, VS1_SEGMTO, VS3_LOCAL "
	if lNovoCombo
		cQuery += " ,VS1.VS1_ACCRPM "
	endif
	cQuery += "        FROM " + oSqlHlp:NoLock("VS1")
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3_FILIAL = VS1_FILIAL           AND VS3_NUMORC    = VS1_NUMORC AND VS3.VS3_GRUITE IN " + cInGrupos + " AND VS3_QTDINI >= 0 AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE     = VS3_CODITE AND B1_GRUPO   = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO  = SBM.BM_GRUPO    AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_TIPORC = '2' AND VS3_FLGNAT IN (' ', '!') AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "         AND ( VS3_MOTPED in ("+oDpm:GetOfiInMotivosVPRpm()+") OR VS1_MOTIVO in ("+oDpm:GetOfiInMotivosVPRpm()+") ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cAl)->(Eof())
		cCod := ""
		begin transaction
			If FS_ConsDem( (cAl)->(VS3_CODSIT) )

				aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cAl)->(VS1_SEGMTO) , (cAl)->VS3_LOCAL )
				cSegmto := aRetAux[1]
				cNNRCod := aRetAux[2]

				oDados := DMS_DataContainer():New({;
					{'VB8_FILIAL' , xFilial('VB8')                           },;
					{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
					{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
					{'VB8_CODCLI' , (cAl)->(VS1_CLIFAT)                      },;
					{'VB8_LOJCLI' , (cAl)->(VS1_LOJA)                        },;
					{'VB8_ANO'    , Left((cAl)->(VS1_DATORC),4)              },;
					{'VB8_MES'    , Subs((cAl)->(VS1_DATORC),5,2)            },;
					{'VB8_DIA'    , Subs((cAl)->(VS1_DATORC),7,2)            },;
					{'VB8_NNRCOD' , cNNRCod                                  },;
					{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
					{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
					{'VB8_STOCK'  , "S"                                      },;
					{'VB8_TIPREG' , "N"                                      },;
					{'VB8_PROCES' , "N"                                      } ;
				})

				if lNovoCombo
					aDados   := OA50400094_CertoOuPrincipal((cAl)->(VS1_SEGMTO), (cAl)->(VS1_ACCRPM))
					oDados:SetValue('VB8_ACCRPM', aDados[2])
				else
					aDados   := OA50400094_CertoOuPrincipal((cAl)->(VS1_SEGMTO), "")
				endif
				oDados:SetValue('VB8_SEGMTO', aDados[1])
				oDados:SetValue('VB8_NUMORC', (cAl)->(VS1_NUMORC))

				if VS3->VS3_FLGNAT != '!'
					oDem := DMS_DataContainer():New({;
						{'VB8_VDPERO' ,iif((cAl)->(VS3_QTDITE) <= 0 , 1, (cAl)->(VS3_QTDITE)) },;
						{'VB8_HIPERO' , 1                   } ;
					})
				endif

				cCod := OA50401_GravaDem(oDados, oDem)
			EndIf

			if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cAl)->(B1_COD), (cAl)->(VS1_SEGMTO))
				oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cAl)->(B1_COD) +" "+ "SEGMENTO:" + cValToChar((cAl)->(VS1_SEGMTO)) +" "+ "VS1_NUMORC:" + (cAl)->(VS1_NUMORC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P4" })
			endif

			VS3->(DbGoTo((cAl)->(CODIGO)))
			OA50400054_FlagaVS3((cAl)->(CODIGO), iif(VS3->VS3_FLGNAT == '!', 'Z', 'R')) // aparentemente o Z nunca vai acontecer, pois tiporc = 2 nao abre no painel e por isso nao se clona nem se libera
		end transaction
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0027 +"("+FWTimeStamp(5)+")"} ) //" termino quarta peneira de dados : "

	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT D2_DOC, D2_SERIE, SD2.R_E_C_N_O_ RECNOSD2, SD2.D2_CLIENTE, SD2.D2_LOJA, SB1.B1_COD, SB1.B1_CRICOD, SB1.B1_LOCPAD, SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO, SD2.D2_TOTAL, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_DESC, SD2.D2_CUSTO1, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SD2.D2_LOCAL, F2_MOEDA "
	cQuery += " FROM "+oSqlHlp:NoLock("SD2")
	cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD  = B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  AND B1_GRUPO IN "+cInGrupos
	cQuery += " JOIN "+oSqlHlp:NoLock("SBM")+" ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = F4_CODIGO  AND  SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFOFI","OFI")+"' AND  D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND D2_QUANT > 0  AND SD2.D_E_L_E_T_ = ' ' "
	if oDpm:lNovaConfiguracao // somente armazem de venda e configurados
		aArms := oDpm:oNovaConfiguracao:ArmazensTTOfi(cFilAnt)
		cInLocais := "('" + oArHelp:Join(aArms, "','") + "')"
		cQuery += " AND D2_LOCAL in " + cInLocais
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cSQLPedNF)->(Eof())
		cCod := ""
		if Alltrim((cSQLPedNF)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLPedNF)->(F4_OPEMOV)) != '05'
			OA50400024_FlagaD2((cSQLPedNF)->(RECNOSD2), "D")
			(cSQLPedNF)->(DBSkip())
			loop
		endif
		
		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8')},;
			{'VB8_PRODUT' , (cSQLPedNF)->(B1_COD)},;
			{'VB8_CRICOD' , (cSQLPedNF)->(B1_CRICOD)},;
			{'VB8_CODCLI' , (cSQLPedNF)->(D2_CLIENTE)},;
			{'VB8_LOJCLI' , (cSQLPedNF)->(D2_LOJA)},;
			{'VB8_ANO'    , Left((cSQLPedNF)->(D2_EMISSAO),4)},;
			{'VB8_MES'    , Subs((cSQLPedNF)->(D2_EMISSAO),5,2)},;
			{'VB8_DIA'    , Subs((cSQLPedNF)->(D2_EMISSAO),7,2)},;
			{'VB8_NNRCOD' , iif(empty((cSQLPedNF)->D2_LOCAL), "01", (cSQLPedNF)->D2_LOCAL)},;
			{'VB8_LOCAL'  , IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1")},;
			{'VB8_TIPLOC' , IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N")},;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"};
		})

		aDados := OA50400074_SegmtoVda((cSQLPedNF)->(D2_DOC), (cSQLPedNF)->(D2_SERIE))
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		if lNovoCombo
			oDados:SetValue('VB8_ACCRPM', aDados[2])
		endif

		if empty(aDados[1]) .or. empty(aDados[2])
			aDados2 := OA50400094_CertoOuPrincipal(aDados[1], aDados[2])
			oDados:SetValue('VB8_SEGMTO', aDados[1])
			if lNovoCombo
				oDados:SetValue('VB8_ACCRPM', aDados[2])
			endif
		endif

		if len(aDados) > 2
			if "NUMORC" $ aDados[3]
				oDados:SetValue('VB8_NUMORC', aDados[4])
			else
				oDados:SetValue('VB8_NUMOSV', aDados[4])
			endif
		endif

		nTotMoeda := FG_MOEDA( (cSQLPedNF)->(D2_TOTAL) , (cSQLPedNF)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cSQLPedNF)->(D2_EMISSAO))
		nCusMoeda := (cSQLPedNF)->(D2_CUSTO1)

		oDem := DMS_DataContainer():New({;
			{'VB8_HITSO'  , 1 },;
			{'VB8_TOTOFI' , nTotMoeda },;
			{'VB8_CUSOFI' , nCusMoeda },;
			{'VB8_VDAO'   , (cSQLPedNF)->(D2_QUANT) },;
			{'VB8_IMEDO'  , 1 } ; // notas avulsas feitas fora do padrão serão sempre 100% nivel de atendimento
		})


		if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLPedNF)->(B1_COD))
			oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLPedNF)->(B1_COD) +" "+ "SEGMENTO: N/A" +" "+ "D2_DOC:" + (cSQLPedNF)->(D2_DOC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P5" })
		endif

		if ! OA5040014_VerificaDupl((cSQLPedNF)->(RECNOSD2))
			begin transaction
				cCod := OA50401_GravaDem(oDados, oDem)
				OA50400024_FlagaD2((cSQLPedNF)->(RECNOSD2), "E")
			end transaction
		endif

		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DBCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0028 +"("+FWTimeStamp(5)+")"} ) //" termino quinta peneira de dados : "
next

oLogger:Log( { STR0029+"("+FWTimeStamp(5)+")"} ) //"Fim do Calculo de Nivel de Atendimento Oficina

//
// =============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO BALCAO
// =============================================
IncProc(STR0049)
oLogger:Log( { STR0030+"("+FWTimeStamp(5)+")"} ) //"Calculando Nivel de Atendimento Balcao"

For nCont := 1 to Len(aFilis)
	
	cFilAnt := aFilis[nCont,1]

	lPrimeira := .t.
	cLogNF    := ""

	oLogger:Log( {cFilAnt+ STR0023 +"("+FWTimeStamp(5)+")"} )

	cDadosProd := oDpm:getTabelaDadosAdc()

	if lVS1REMITO

		// -------------------------------------------------------------------------------------------------------
		// PASSO A-B : Levanta os itens de orçamento que possuem **REMITO** emitida mas ainda não foram marcados
		// -------------------------------------------------------------------------------------------------------
		cQuery := " SELECT D2_DOC,"
		cQuery += " VS1O.VS1_NUMNFI NUMNFI, VS1O.VS1_SERNFI SERIE, "
		cQuery += " VS1P.VS1_NUMORC NUMORC, VS1P.VS1_DATORC DATORC, "
		cQuery += " VS1P.VS1_SEGMTO, "
		cQuery += " VS3P.R_E_C_N_O_ VS3RECNO, VS3P.VS3_FLGNAT, VS3P.VS3_QESTNA, VS3P.VS3_QTDELI, VS3P.VS3_CODSIT, VS3P.VS3_QTDINI, "
		cQuery += " SD2.R_E_C_N_O_ SD2RECNO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_TOTAL, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_DESC, SD2.D2_CUSTO1, "
		cQuery += " SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SB1.B1_CRICOD, SBM.BM_PROORI, VS3P.VS3_LOCAL, F2_MOEDA "
		if lNovoCombo
			cQuery += " ,VS1P.VS1_ACCRPM "
		endif
		cQuery += " FROM "+oSqlHlp:NoLock("VS1", 'VS1P')
		cQuery += " JOIN "+oSqlHlp:NoLock("VS1", 'VS1O')+" ON VS1P.VS1_FILIAL = VS1O.VS1_FILIAL AND VS1P.VS1_NUMORC = VS1O.VS1_PEDREF AND VS1O.VS1_PEDREF <> ' '"
		cQuery += " JOIN "+oSqlHlp:NoLock("VS3", 'VS3P')+" ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS1P.VS1_NUMORC = VS3P.VS3_NUMORC AND VS3P.VS3_FLGNAT IN (' ','!') AND VS3P.VS3_MOTPED = ' ' AND VS3P.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1_GRUPO IN " + cInGrupos + " AND VS3P.VS3_GRUITE = SB1.B1_GRUPO AND VS3P.VS3_CODITE = SB1.B1_CODITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SBM")+" ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON SD2.D2_FILIAL = VS1O.VS1_FILIAL AND SD2.D2_DOC = VS1O.VS1_REMITO AND SD2.D2_SERIE = VS1O.VS1_SERREM AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_FLGNAT = ' ' AND SD2.D2_QUANT > 0 AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VS1O.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1O.VS1_NUMNFI = ' ' AND VS1O.VS1_TIPORC = '1' AND VS1P.VS1_TIPORC = 'P'"
		cQuery += "   AND VS1P.D_E_L_E_T_ = ' ' "
		cQuery += "   AND VS1O.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY VS1O.VS1_NUMNFI ASC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )
		oLogQueries:Log({cQuery})
		While !(cSQLSD2Abe)->(Eof())

			if OA5040014_VerificaDupl((cSQLSD2Abe)->(SD2RECNO))
				(cSQLSD2Abe)->(DBSkip())
				loop
			endif

			// -------------------------------------------------------------------------------------
			// PASSO C : Verifica se o TES eh de venda, caso contrario não processa
			// -------------------------------------------------------------------------------------
			if Alltrim((cSQLSD2Abe)->(F4_OPEMOV)) != '05'
				(cSQLSD2Abe)->(DBSkip())
				loop
			endif
			cStock := iif((cSQLSD2Abe)->(VS3_QESTNA) == 0, "N", "S")

			aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cSQLSD2Abe)->(VS1_SEGMTO) , (cSQLSD2Abe)->VS3_LOCAL )
			cSegmto := aRetAux[1]
			cNNRCod := aRetAux[2]

			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial('VB8')},;
				{'VB8_PRODUT' , (cSQLSD2Abe)->(D2_COD)},;
				{'VB8_CRICOD' , (cSQLSD2Abe)->(B1_CRICOD)},;
				{'VB8_CODCLI' , (cSQLSD2Abe)->(D2_CLIENTE)},;
				{'VB8_LOJCLI' , (cSQLSD2Abe)->(D2_LOJA)},;
				{'VB8_ANO'    , Left((cSQLSD2Abe)->(D2_EMISSAO),4)},;
				{'VB8_MES'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),5,2)},;
				{'VB8_DIA'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),7,2)},;
				{'VB8_LOCAL'  , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","D1","N1")},;
				{'VB8_TIPLOC' , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","M","N")},;
				{'VB8_NNRCOD' , cNNRCod},;
				{'VB8_SEGMTO' , cSegmto},;
				{'VB8_STOCK'  , cStock},;
				{'VB8_TIPREG' , "N"},;
				{'VB8_PROCES' , "N"};
			})

			if lNovoCombo
				aDados   := OA50400094_CertoOuPrincipal((cSQLSD2Abe)->(VS1_SEGMTO), (cSQLSD2Abe)->(VS1_ACCRPM))
				oDados:SetValue('VB8_ACCRPM', aDados[2])
			else
				aDados   := OA50400094_CertoOuPrincipal((cSQLSD2Abe)->(VS1_SEGMTO), "")
			endif
			oDados:SetValue('VB8_SEGMTO', aDados[1])
			oDados:SetValue('VB8_NUMORC', (cSQLSD2Abe)->(NUMORC))

			nTotMoeda := FG_MOEDA( (cSQLSD2Abe)->(D2_TOTAL) , (cSQLSD2Abe)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cSQLSD2Abe)->(D2_EMISSAO))
			nCusMoeda := (cSQLSD2Abe)->(D2_CUSTO1)

			oDem := DMS_DataContainer():New({})
			if Empty( (cSQLSD2Abe)->(VS3_FLGNAT) ) // não foi processado
				if (cSQLSD2Abe)->(D2_QUANT) > 0
					if FS_ConsDem( (cSQLSD2Abe)->(VS3_CODSIT) )
						oDem := DMS_DataContainer():New({;
							{'VB8_TOTBAL', nTotMoeda  },;
							{'VB8_CUSBAL', nCusMoeda },;
							{'VB8_HITSB' , 1                         },;
							{'VB8_VDAB'  , (cSQLSD2Abe)->(D2_QUANT)  } ;
						})
						if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
							oDem:SetValue('VB8_IMEDB', 1)
						endif
					else
						If FS_isEspecial( (cSQLSD2Abe)->(VS3_CODSIT) ) // especial soma hits normal, mas só isso
							oDem := DMS_DataContainer():New({;
								{"VB8_HITSBN", 1},;
								{"VB8_VDABN" , (cSQLSD2Abe)->(D2_QUANT) },;
								{"VB8_TOTBAN", nTotMoeda },;
								{"VB8_CUSBAN", nCusMoeda} ;
							})
							if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
								oDem:SetValue('VB8_IMEDBN', 1)
							endif
						EndIf
					endif
				endif
			EndIf


			if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLSD2Abe)->(D2_COD), (cSQLSD2Abe)->(VS1_SEGMTO))
				oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLSD2Abe)->(D2_COD) +" "+ "SEGMENTO: " + (cSQLSD2Abe)->(VS1_SEGMTO) +" "+ "D2_DOC:" + (cSQLSD2Abe)->(D2_DOC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P6" })
			endif

			begin transaction
				cCod := OA50401_GravaDem(oDados, oDem)
				OA50400054_FlagaVS3((cSQLSD2Abe)->(VS3RECNO), "S")
				OA50400024_FlagaD2((cSQLSD2Abe)->(SD2RECNO), "S")
			end transaction

			(cSQLSD2Abe)->(DBSkip())
		enddo
		(cSQLSD2Abe)->(DbCloseArea())

		// -------------------------------------------------------------------------------------------------------
		// FLAG de faturas de remitos já flagados, independente da TES (movimento de estoque)
		// -------------------------------------------------------------------------------------------------------
		cQuery := " SELECT SD2.R_E_C_N_O_ SD2RECNO"
		cQuery += " FROM "+oSqlHlp:NoLock("VS1", 'VS1P')
		cQuery += " JOIN "+oSqlHlp:NoLock("VS1", 'VS1O')+" ON VS1P.VS1_FILIAL = VS1O.VS1_FILIAL AND VS1P.VS1_NUMORC = VS1O.VS1_PEDREF AND VS1O.VS1_PEDREF <> ' '"
		cQuery += " JOIN "+oSqlHlp:NoLock("VS3", 'VS3P')+" ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS1P.VS1_NUMORC = VS3P.VS3_NUMORC AND VS3P.VS3_MOTPED = ' ' AND VS3P.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND VS3P.VS3_GRUITE = SB1.B1_GRUPO AND VS3P.VS3_CODITE = SB1.B1_CODITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SBM")+" ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND BM_VAIDPM = '1' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON SD2.D2_FILIAL = VS1O.VS1_FILIAL AND SD2.D2_DOC = VS1O.VS1_NUMNFI AND SD2.D2_SERIE = VS1O.VS1_SERNFI AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_FLGNAT = ' ' AND SD2.D2_QUANT > 0 AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VS1O.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1O.VS1_TIPORC = '1' AND VS1P.VS1_TIPORC = 'P'"
		cQuery += "   AND VS1O.VS1_NUMNFI != ' ' "
		cQuery += "   AND VS1O.VS1_REMITO != ' ' "
		cQuery += "   AND VS3P.VS3_FLGNAT != ' ' "
		cQuery += "   AND VS1P.D_E_L_E_T_ = ' ' "
		cQuery += "   AND VS1O.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY VS1O.VS1_NUMNFI ASC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )
		oLogQueries:Log({cQuery})
		While !(cSQLSD2Abe)->(Eof())
			OA50400024_FlagaD2((cSQLSD2Abe)->(SD2RECNO), "#")

			(cSQLSD2Abe)->(DBSkip())
		enddo
		(cSQLSD2Abe)->(DbCloseArea())
	endif

	// -------------------------------------------------------------------------------------
	// PASSO A : Levanta os itens de orçamento que possuem nota emitida mas ainda não foram marcados
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT D2_DOC,"
	cQuery += " VS1O.VS1_NUMNFI NUMNFI, VS1O.VS1_SERNFI SERIE, "
	cQuery += " VS1P.VS1_NUMORC NUMORC, VS1P.VS1_DATORC DATORC, "
	cQuery += " VS1P.VS1_SEGMTO, "
	cQuery += " VS3P.R_E_C_N_O_ VS3RECNO, VS3P.VS3_FLGNAT, VS3P.VS3_QESTNA, VS3P.VS3_QTDELI, VS3P.VS3_CODSIT, VS3P.VS3_QTDINI, "
	cQuery += " SD2.R_E_C_N_O_ SD2RECNO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_TOTAL, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_DESC, SD2.D2_CUSTO1, "
	cQuery += " SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SB1.B1_CRICOD, SBM.BM_PROORI, VS3P.VS3_LOCAL, F2_MOEDA "
	if lNovoCombo
		cQuery += " ,VS1P.VS1_ACCRPM "
	endif
	cQuery += " FROM "+oSqlHlp:NoLock("VS1", 'VS1P')
	cQuery += " JOIN "+oSqlHlp:NoLock("VS1", 'VS1O')+" ON VS1P.VS1_FILIAL = VS1O.VS1_FILIAL AND VS1P.VS1_NUMORC = VS1O.VS1_PEDREF "
	cQuery += " JOIN "+oSqlHlp:NoLock("VS3", 'VS3P')+" ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS1P.VS1_NUMORC = VS3P.VS3_NUMORC AND VS3P.VS3_FLGNAT IN (' ','!') AND VS3P.VS3_MOTPED = ' ' AND VS3P.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1_GRUPO IN " + cInGrupos + " AND VS3P.VS3_GRUITE = SB1.B1_GRUPO AND VS3P.VS3_CODITE = SB1.B1_CODITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SBM")+" ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON SD2.D2_FILIAL = VS1O.VS1_FILIAL AND SD2.D2_DOC = VS1O.VS1_NUMNFI AND SD2.D2_SERIE = VS1O.VS1_SERNFI AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_FLGNAT = ' ' AND SD2.D2_QUANT > 0 AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VS1O.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1O.VS1_NUMNFI != ' ' AND VS1O.VS1_TIPORC = '1' AND VS1P.VS1_TIPORC = 'P'"
	cQuery += "   AND VS1P.D_E_L_E_T_ = ' ' "
	cQuery += "   AND VS1O.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VS1O.VS1_NUMNFI ASC"
	cSQLSD2Abe := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cSQLSD2Abe)->(Eof())

		if OA5040014_VerificaDupl((cSQLSD2Abe)->(SD2RECNO))
			(cSQLSD2Abe)->(DBSkip())
			loop
		endif

		// -------------------------------------------------------------------------------------
		// PASSO C : Verifica se o TES movimenta Estoque
		// -------------------------------------------------------------------------------------
		if Alltrim((cSQLSD2Abe)->(F4_OPEMOV)) != '05'
			OA50400024_FlagaD2((cSQLSD2Abe)->(SD2RECNO), "F")
			(cSQLSD2Abe)->(DBSkip())
			loop
		endif
		cStock := iif((cSQLSD2Abe)->(VS3_QESTNA) == 0, "N", "S")

		aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cSQLSD2Abe)->(VS1_SEGMTO) , (cSQLSD2Abe)->VS3_LOCAL )
		cSegmto := aRetAux[1]
		cNNRCod := aRetAux[2]

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8')},;
			{'VB8_PRODUT' , (cSQLSD2Abe)->(D2_COD)},;
			{'VB8_CRICOD' , (cSQLSD2Abe)->(B1_CRICOD)},;
			{'VB8_CODCLI' , (cSQLSD2Abe)->(D2_CLIENTE)},;
			{'VB8_LOJCLI' , (cSQLSD2Abe)->(D2_LOJA)},;
			{'VB8_ANO'    , Left((cSQLSD2Abe)->(D2_EMISSAO),4)},;
			{'VB8_MES'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),5,2)},;
			{'VB8_DIA'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),7,2)},;
			{'VB8_LOCAL'  , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","D1","N1")},;
			{'VB8_TIPLOC' , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","M","N")},;
			{'VB8_NNRCOD' , cNNRCod},;
			{'VB8_SEGMTO' , cSegmto},;
			{'VB8_STOCK'  , cStock},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"} ;
		})

		if lNovoCombo
			aDados   := OA50400094_CertoOuPrincipal((cSQLSD2Abe)->(VS1_SEGMTO), (cSQLSD2Abe)->(VS1_ACCRPM))
		else
			aDados   := OA50400094_CertoOuPrincipal((cSQLSD2Abe)->(VS1_SEGMTO), "")
		endif
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		oDados:SetValue('VB8_ACCRPM', aDados[2])
		oDados:SetValue('VB8_NUMORC', (cSQLSD2Abe)->(NUMORC))

		nTotMoeda := FG_MOEDA( (cSQLSD2Abe)->(D2_TOTAL) , (cSQLSD2Abe)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cSQLSD2Abe)->(D2_EMISSAO))
		nCusMoeda := (cSQLSD2Abe)->(D2_CUSTO1) //FG_MOEDA( (cSQLSD2Abe)->(D2_CUSTO1), (cSQLSD2Abe)->F2_MOEDA, iif(lMultiMoeda, 0, 0),,, (cSQLSD2Abe)->(D2_EMISSAO))

		oDem := DMS_DataContainer():New({})
		if Empty( (cSQLSD2Abe)->(VS3_FLGNAT) ) // não foi processado
			if (cSQLSD2Abe)->(D2_QUANT) > 0
				if FS_ConsDem( (cSQLSD2Abe)->(VS3_CODSIT) )
					oDem := DMS_DataContainer():New({;
						{'VB8_TOTBAL', nTotMoeda  },;
						{'VB8_CUSBAL', nCusMoeda },;
						{'VB8_HITSB' , 1                         },;
						{'VB8_VDAB'  , (cSQLSD2Abe)->(D2_QUANT)  } ;
					})
					if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
						oDem:SetValue('VB8_IMEDB', 1)
					endif
				else
					If FS_isEspecial( (cSQLSD2Abe)->(VS3_CODSIT) ) // especial soma hits normal, mas só isso
						oDem := DMS_DataContainer():New({;
							{"VB8_HITSBN", 1},;
							{"VB8_VDABN" , (cSQLSD2Abe)->(D2_QUANT) },;
							{"VB8_TOTBAN", nTotMoeda },;
							{"VB8_CUSBAN", nCusMoeda} ;
						})
						if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
							oDem:SetValue('VB8_IMEDBN', 1)
						endif
					EndIf
				endif
			endif
		EndIf


		if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLSD2Abe)->(D2_COD), (cSQLSD2Abe)->(VS1_SEGMTO))
			oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLSD2Abe)->(D2_COD) +" "+ "SEGMENTO: " + (cSQLSD2Abe)->(VS1_SEGMTO) +" "+ "D2_DOC:" + (cSQLSD2Abe)->(D2_DOC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P6" })
		endif

		begin transaction
			cCod := OA50401_GravaDem(oDados, oDem)
			if Empty((cSQLSD2Abe)->(VS3_FLGNAT))
				OA50400054_FlagaVS3((cSQLSD2Abe)->(VS3RECNO), "G")
			endif
			OA50400024_FlagaD2((cSQLSD2Abe)->(SD2RECNO), "G")
		end transaction
		(cSQLSD2Abe)->(DBSkip())
	enddo
	(cSQLSD2Abe)->(DbCloseArea())


	// -------------------------------------------------------------------------------------
	// PASSO H : Computar vendas perdidas
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT VS1_NUMORC, SBM.BM_PROORI, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_DATORC DATORC, VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_QTDITE, VS3.VS3_QTDELI,  VS3.VS3_CODSIT, SB1.B1_COD CODITE, SB1.B1_CRICOD CRICOD, VS1.VS1_SEGMTO, VS3_LOCAL "
	if lNovoCombo
		cQuery += " ,VS1_ACCRPM "
	endif
	cQuery += "   FROM " + oSqlHlp:NoLock("VS3")
	cQuery += "   JOIN " + oSqlHlp:NoLock("VS1") + " ON VS1_FILIAL = '"+xFilial("VS1")+"'  AND VS1_NUMORC   = VS3_NUMORC            AND VS1_FILIAL      = VS3_FILIAL            AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial("SB1")+"'  AND B1_CODITE    = VS3.VS3_CODITE        AND SB1.B1_GRUPO    = VS3.VS3_GRUITE        AND SB1.D_E_L_E_T_  = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock("SBM") + " ON B1_GRUPO   = SBM.BM_GRUPO          AND BM_FILIAL    = '"+xFilial("SBM")+"'  AND SBM.D_E_L_E_T_  = ' ' "
	cQuery += "  WHERE VS3.VS3_FILIAL  = '"+xFilial("VS3")+"' "
	cQuery += "    AND VS1_TIPORC     = 'P' "
	cQuery += "    AND VS3_QTDELI     <>   0 "
	cQuery += "    AND VS3_FLGNAT     != 'I' AND VS3_FLGNAT     != 'B' AND VS3_FLGNAT != 'C' "
	cQuery += "    AND VS3_MOTPED     in ("+oDpm:GetBalInMotivosVPRpm()+") "
	cQuery += "    AND VS3_QTDINI     >= 0 "
	cQuery += "    AND VS3.D_E_L_E_T_ = ' '   "
	cQuery += "    AND B1_GRUPO IN " + cInGrupos
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVdaPer , .F. , .T. )
	oLogQueries:Log({cQuery})
	oLogger:Log( { "     |> ("+FWTimeStamp(5)+") "+CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) } )

	While !(cSQLVdaPer)->(Eof())
		cCod := ""
		DBSelectArea("VB8")

		begin transaction

			if FS_ConsDem( (cSQLVdaPer)->(VS3_CODSIT) )

				aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cSQLVdaPer)->(VS1_SEGMTO) , (cSQLVdaPer)->VS3_LOCAL )
				cSegmto := aRetAux[1]
				cNNRCod := aRetAux[2]

				oDados := DMS_DataContainer():New({;
					{'VB8_FILIAL' , xFilial("VB8") },;
					{'VB8_PRODUT' , (cSQLVdaPer)->(CODITE) },;
					{'VB8_CRICOD' , (cSQLVdaPer)->(CRICOD) },;
					{'VB8_CODCLI' , (cSQLVdaPer)->(VS1_CLIFAT) },;
					{'VB8_LOJCLI' , (cSQLVdaPer)->(VS1_LOJA) },;
					{'VB8_ANO'    , Left((cSQLVdaPer)->(DATORC),4) },;
					{'VB8_MES'    , Subs((cSQLVdaPer)->(DATORC),5,2) },;
					{'VB8_DIA'    , Subs((cSQLVdaPer)->(DATORC),7,2) },;
					{'VB8_LOCAL'  , IIF((cSQLVdaPer)->(BM_PROORI) == "1","D1","N1") },;
					{'VB8_TIPLOC' , IIF((cSQLVdaPer)->(BM_PROORI) == "1","M","N") },;
					{'VB8_NNRCOD' , cNNRCod},;
					{'VB8_STOCK'  , "S"},;
					{'VB8_TIPREG' , "N"},;
					{'VB8_PROCES' , "N"} ;
				})

				if lNovoCombo
					aDados   := OA50400094_CertoOuPrincipal((cSQLVdaPer)->(VS1_SEGMTO), (cSQLVdaPer)->(VS1_ACCRPM))
					oDados:SetValue('VB8_ACCRPM', aDados[2])
				else
					aDados   := OA50400094_CertoOuPrincipal((cSQLVdaPer)->(VS1_SEGMTO), "")
				endif
				oDados:SetValue('VB8_SEGMTO', aDados[1])

				oDem := DMS_DataContainer():New({;
					{'VB8_VDPERB' ,iif((cSQLVdaPer)->(VS3_QTDELI) <= 0 , 1, (cSQLVdaPer)->(VS3_QTDELI)) },;
					{'VB8_HIPERB' , 1};
				})

				cCod := OA50401_GravaDem(oDados, oDem)
			EndIf

			if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLVdaPer)->(CODITE), (cSQLVdaPer)->(VS1_SEGMTO))
				oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLVdaPer)->(CODITE) +" "+ "SEGMENTO: " + (cSQLVdaPer)->(VS1_SEGMTO) +" "+ "VS1_NUMORC:" + (cSQLVdaPer)->(VS1_NUMORC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P7" })
			endif

			OA50400054_FlagaVS3((cSQLVdaPer)->(VS3RECNO), "I")
		end transaction
		
		(cSQLVdaPer)->(DBSkip())
	enddo
	(cSQLVdaPer)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0025 +"("+FWTimeStamp(5)+")"} ) //" termino segunda peneira de dados : "

	// venda perdida quando o pedido avançou e cancelou o orçamento
	cQuery := "  SELECT VS1_NUMORC, VS1_PEDREF, SBM.BM_PROORI, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_DATORC DATORC, VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_QTDITE, VS3.VS3_QTDELI,  VS3.VS3_CODSIT, SB1.B1_COD CODITE, SB1.B1_CRICOD CRICOD, VS1.VS1_SEGMTO, VS3.VS3_LOCAL "
	if lNovoCombo
		cQuery += " ,VS1_ACCRPM "
	endif
	cQuery += "    FROM "+oSqlHlp:NoLock('VS1')+" "
	cQuery += "    JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS1_NUMORC = VS3_NUMORC AND VS3_QTDINI >= 0 AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL  = '"+xFilial("SB1")+"'  AND B1_CODITE    = VS3.VS3_CODITE        AND SB1.B1_GRUPO    = VS3.VS3_GRUITE        AND SB1.D_E_L_E_T_  = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock("SBM")+" ON B1_GRUPO   = SBM.BM_GRUPO          AND BM_FILIAL    = '"+xFilial("SBM")+"'  AND SBM.D_E_L_E_T_  = ' ' "
	cQuery += "   WHERE VS1_FILIAL      = '"+xFilial('VS1')+"' "
	cQuery += "     AND VS1_TIPORC      = '1' " // pecas
	cQuery += "     AND (VS1_MOTIVO     in ("+oDpm:GetBalInMotivosVPRpm()+") OR VS3_MOTPED in ("+oDpm:GetBalInMotivosVPRpm()+") ) "
	cQuery += "     AND VS3_FLGNAT      = ' ' "
	cQuery += "     AND VS1.D_E_L_E_T_  = ' ' "
	cQuery += "     AND B1_GRUPO IN " + cInGrupos
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVdaPer , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cSQLVdaPer)->(Eof())
		cCod := ""
		DBSelectArea("VB8")

		begin transaction
			if FS_ConsDem( (cSQLVdaPer)->(VS3_CODSIT) )

				aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , (cSQLVdaPer)->(VS1_SEGMTO) , (cSQLVdaPer)->VS3_LOCAL )
				cSegmto := aRetAux[1]
				cNNRCod := aRetAux[2]

				oDados := DMS_DataContainer():New({;
					{'VB8_FILIAL' , xFilial("VB8")                   },;
					{'VB8_PRODUT' , (cSQLVdaPer)->(CODITE)           },;
					{'VB8_CRICOD' , (cSQLVdaPer)->(CRICOD)           },;
					{'VB8_CODCLI' , (cSQLVdaPer)->(VS1_CLIFAT)       },;
					{'VB8_LOJCLI' , (cSQLVdaPer)->(VS1_LOJA)         },;
					{'VB8_ANO'    , Left((cSQLVdaPer)->(DATORC),4)   },;
					{'VB8_MES'    , Subs((cSQLVdaPer)->(DATORC),5,2) },;
					{'VB8_DIA'    , Subs((cSQLVdaPer)->(DATORC),7,2) },;
					{'VB8_LOCAL'  , IIF((cSQLVdaPer)->(BM_PROORI) == "1","D1","N1") },;
					{'VB8_TIPLOC' , IIF((cSQLVdaPer)->(BM_PROORI) == "1","M","N")   },;
					{'VB8_NNRCOD' , cNNRCod},;
					{'VB8_SEGMTO' , cSegmto},;
					{'VB8_STOCK'  , "S"},;
					{'VB8_TIPREG' , "N"},;
					{'VB8_PROCES' , "N"} ;
				})

				if lNovoCombo
					aDados   := OA50400094_CertoOuPrincipal((cSQLVdaPer)->(VS1_SEGMTO), (cSQLVdaPer)->(VS1_ACCRPM))
					oDados:SetValue('VB8_ACCRPM', aDados[2])
				else
					aDados   := OA50400094_CertoOuPrincipal((cSQLVdaPer)->(VS1_SEGMTO), "")
				endif
				oDados:SetValue('VB8_SEGMTO', aDados[1])
				oDados:SetValue('VB8_NUMORC', (cSQLVdaPer)->(VS1_NUMORC))

				oDem := DMS_DataContainer():New({;
					{'VB8_VDPERB' ,iif((cSQLVdaPer)->(VS3_QTDITE) <= 0 , 1, (cSQLVdaPer)->(VS3_QTDITE)) },;
					{'VB8_HIPERB' , 1};
				})

				cCod := OA50401_GravaDem(oDados, oDem)
			EndIf

			if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLVdaPer)->(CODITE), (cSQLVdaPer)->(VS1_SEGMTO))
				oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLVdaPer)->(CODITE) +" "+ "SEGMENTO: " + (cSQLVdaPer)->(VS1_SEGMTO) +" "+ "VS1_NUMORC:" + (cSQLVdaPer)->(VS1_NUMORC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P8" })
			endif

			OA50400054_FlagaVS3((cSQLVdaPer)->(VS3RECNO), "B")
		end transaction
	
		(cSQLVdaPer)->(DBSkip())
	enddo
	(cSQLVdaPer)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0026 +"("+FWTimeStamp(5)+")"} ) //" termino terceira peneira de dados : "

	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT SD2.R_E_C_N_O_ RECNOSD2, SB1.B1_COD, SB1.B1_CRICOD, SBM.BM_PROORI, SD2.D2_EMISSAO, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_TOTAL, SD2.D2_QUANT,"
	cQuery += "        SD2.D2_PRCVEN, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_DESC, SB1.B1_GRUPO, SB1.B1_CODITE, SD2.D2_CUSTO1, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SD2.D2_LOCAL, F2_MOEDA "
	cQuery += " FROM " + oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oSqlHlp:NoLock("SF2") + " ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC       = D2_DOC       AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD       = B1_COD       AND SB1.D_E_L_E_T_ = ' ' AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES       = F4_CODIGO    AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFBAL","BAL")+"' AND D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND SD2.D_E_L_E_T_ = ' '  "
	cQuery += " AND D2_QUANT > 0 "
	if oDpm:lNovaConfiguracao // somente armazem de venda e configurados
		aArms := oDpm:oNovaConfiguracao:ArmazensDeVenda(cFilAnt)
		aArms := oArHelp:Map(aArms, { |jArm| jArm["CODIGO_ARMAZEM"] })
		cInLocais := "('" + oArHelp:Join(aArms, "','") + "')"
		cQuery += " AND D2_LOCAL in " + cInLocais
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cSQLPedNF)->(Eof())
		cCod := ""
		oDem := DMS_DataContainer():New({})
		if Alltrim((cSQLPedNF)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLPedNF)->(F4_OPEMOV)) != '05'
			OA50400024_FlagaD2((cSQLPedNF)->(RECNOSD2), "J")
			(cSQLPedNF)->(DBSkip())
			loop
		endif
		
		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial("VB8") },;
			{'VB8_PRODUT' , (cSQLPedNF)->(B1_COD) },;
			{'VB8_CRICOD' , (cSQLPedNF)->(B1_CRICOD) },;
			{'VB8_CODCLI' , (cSQLPedNF)->(D2_CLIENTE) },;
			{'VB8_LOJCLI' , (cSQLPedNF)->(D2_LOJA) },;
			{'VB8_ANO'    , Left((cSQLPedNF)->(D2_EMISSAO),4) },;
			{'VB8_MES'    , Subs((cSQLPedNF)->(D2_EMISSAO),5,2) },;
			{'VB8_DIA'    , Subs((cSQLPedNF)->(D2_EMISSAO),7,2) },;
			{'VB8_LOCAL'  , IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1") },;
			{'VB8_TIPLOC' , IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N") },;
			{'VB8_NNRCOD' , iif(empty((cSQLPedNF)->(D2_LOCAL)), "01", (cSQLPedNF)->D2_LOCAL)},;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"} ;
		})


		aDados := OA50400074_SegmtoVda((cSQLPedNF)->(D2_DOC), (cSQLPedNF)->(D2_SERIE))
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		if lNovoCombo
			oDados:SetValue('VB8_ACCRPM', aDados[2])
		endif
		if len(aDados) > 2
			if "NUMORC" $ aDados[3]
				oDados:SetValue('VB8_NUMORC', aDados[4])
			else
				oDados:SetValue('VB8_NUMOSV', aDados[4])
			endif
		endif

		nTotMoeda := FG_MOEDA( (cSQLPedNF)->(D2_TOTAL) , (cSQLPedNF)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cSQLPedNF)->(D2_EMISSAO))

		oDem := DMS_DataContainer():New({;
			{'VB8_HITSB'  , 1 },; // sempre 100% fora do painel
			{'VB8_IMEDB'  , 1 },; // sempre 100% fora do painel
			{'VB8_TOTBAL' , nTotMoeda },;
			{'VB8_CUSBAL' , (cSQLPedNF)->(D2_CUSTO1) },;
			{'VB8_VDAB'   , (cSQLPedNF)->(D2_QUANT)};
		})


		if oRPM:DevoGravarInfoDebug(xFilial('VB8'), (cSQLPedNF)->(B1_COD))
			oLogDebug:Log({ "FILIAL: " + xFilial('VB8') +" "+ "PRODUT: " + (cSQLPedNF)->(B1_COD) +" "+ "D2_DOC:" + (cSQLPedNF)->(D2_DOC) +" "+ "VB8: " + cValToChar(cCod) +" "+ "PENEIRA: P9" })
		endif

		if ! OA5040014_VerificaDupl((cSQLPedNF)->(RECNOSD2))
			begin transaction
				cCod := OA50401_GravaDem(oDados, oDem)
				OA50400024_FlagaD2((cSQLPedNF)->(RECNOSD2), "M")
			end transaction
		endif

		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DBCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0027 +"("+FWTimeStamp(5)+")"} ) //" termino quarta peneira de dados : "

	// ---------------------------------------------------------------------------------------------------
	// Pega todas as movimentações que ainda não foram consideradas e cria um registro padrão de demanda !!!! ISSO É PARA DELTA
	// ---------------------------------------------------------------------------------------------------
	cConc := oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})

	cQuery := " SELECT SD3.R_E_C_N_O_ RECNOSD3, SB1.B1_COD, SB1.B1_CRICOD, SB1.B1_GRUPO, SB1.B1_CODITE,"
	cQuery += "        SBM.BM_PROORI, SD3.D3_EMISSAO, SD3.D3_DOC, SD3.D3_CF, SD3.D3_CUSTO1, SD3.D3_QUANT "
	cQuery += " FROM "+oSqlHlp:NoLock("SD3")
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial("SB1")+"'  AND D3_COD       = SB1.B1_COD    AND SB1.D_E_L_E_T_ = ' '  AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN "+oSqlHlp:NoLock("SBM")+" ON BM_FILIAL = '"+xFilial("SBM")+"'  AND SB1.B1_GRUPO = SBM.BM_GRUPO  AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	cQuery += 		" AND NOT EXISTS ( SELECT NULL "
	cQuery += 						"  FROM "+oSqlHlp:NoLock("VB8")
	cQuery += 						"  WHERE VB8_FILIAL = '"+xFilial("VB8")+"' "
	cQuery += 							" AND VB8_PRODUT = SD3.D3_COD "
	cQuery += 							" AND ("+cConc+") >= '"+DTOS(dDataBase-1)+"' "
	cQuery += 							" AND VB8.D_E_L_E_T_ = ' ' "
	cQuery += 						" ) "
	cQuery += " AND SD3.D3_EMISSAO >= '" +DTOS(dDataBase-1)+ "'"
	cQuery += " AND SD3.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLMovInt , .F. , .T. )
	oLogQueries:Log({cQuery})
	While !(cSQLMovInt)->(Eof())

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial("VB8") },;
			{'VB8_PRODUT' , (cSQLMovInt)->(B1_COD) },;
			{'VB8_CRICOD' , (cSQLMovInt)->(B1_CRICOD) },;
			{'VB8_ANO'    , Left((cSQLMovInt)->(D3_EMISSAO),4) },;
			{'VB8_MES'    , Subs((cSQLMovInt)->(D3_EMISSAO),5,2) },;
			{'VB8_DIA'    , Subs((cSQLMovInt)->(D3_EMISSAO),7,2) },;
			{'VB8_LOCAL'  , IIF((cSQLMovInt)->(BM_PROORI) == "1","D1","N1") },;
			{'VB8_TIPLOC' , IIF((cSQLMovInt)->(BM_PROORI) == "1","M","N") },;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"} ;
		})

		//TODO: avaliar se precisa criar para todos os locais o registro, o problema aqui é que o delta gera esses registros avulsos pra saber o que enviar na prox geracao

		oDem := DMS_DataContainer():New({;
			{'VB8_HITSI' , 0},;
			{'VB8_VDAI'  , 0},;
			{'VB8_IMEDI' , 0},;
			{'VB8_HIPERI', 0} ;
		})

		OA50401_GravaDem(oDados, oDem)

		(cSQLMovInt)->(DBSkip())
	enddo
	(cSQLMovInt)->(DBCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+STR0028 +"("+FWTimeStamp(5)+")"} ) //" termino quinta peneira de dados : "

	// Limpeza de dados que não foi apontado nada em 90 dias
	cUpdLim := " UPDATE " + RetSqlName("VS3")
	cUpdLim += " SET VS3_FLGNAT = 'H' "
	cUpdLim += " WHERE VS3_FILIAL = '"+ xFilial('VS3') +"' "
	cUpdLim += "   AND VS3_FLGNAT = ' ' "
	cUpdLim += "   AND VS3_MOTPED not in ("+oDpm:GetBalInMotivosVPRpm()+") "
	cUpdLim += "   AND D_E_L_E_T_ = ' ' "
	cUpdLim += "   AND EXISTS ("
	cUpdLim += "     SELECT VS1_NUMORC FROM " + RetSQLName('VS1') + " VS1 "
	cUpdLim += "      WHERE VS1.VS1_NUMORC  = VS3_NUMORC "
	cUpdLim += "        AND VS1_TIPORC      = 'P' "
	cUpdLim += "        AND VS1.VS1_FILIAL  = '"+xFilial('VS1')+"' "
	cUpdLim += "        AND VS1.VS1_DATORC <= '"+DTOS(dDataCorte)+"' "
	cUpdLim += "        AND VS1.D_E_L_E_T_  = ' ' "
	cUpdLim += "   ) "

	oLogger:Log( { "     |> ("+FWTimeStamp(5)+") "+CHR(13)+CHR(10)+cUpdLim+CHR(13)+CHR(10) } )

	TcSqlExec(cUpdLim)
next

oLogger:Log( { "     |>" + STR0034 + "("+FWTimeStamp(5)+")"} ) // "Termino nivel de atendimento balcão normal : "

// -------------------------------------------------------------------------------------
// GRAVA DEVOLUCAO
// -------------------------------------------------------------------------------------
IncProc(STR0050)
cAliasSD1 := GetNextAlias()
//
for nCont := 1 to Len(aFilis)
	//
	cFilAnt := aFilis[nCont,1]
	cDadosProd := oDpm:getTabelaDadosAdc()
	//
	cQuery := " SELECT SD1.R_E_C_N_O_ RECSD1, SD2.D2_CLIENTE, SD2.D2_LOJA, SD1.D1_TOTAL, SD1.D1_VALDESC, SD1.D1_CUSTO , SB1.B1_GRUPO , SD1.D1_QUANT, "
	cQuery += "        SF2.F2_PREFORI,SD1.D1_COD, SD1.D1_DTDIGIT, SB1.B1_CRICOD, SD2.D2_EMISSAO, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_LOCAL, F2_MOEDA "
	cQuery += " FROM "+oSqlHlp:NoLock("SD1")
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' "
	cQuery += "  AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON ( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI  AND SF2.F2_PREFORI IN ('"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"') AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC   AND SD2.D2_SERIE=SF2.F2_SERIE    AND SD2.D2_COD = SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // OPEMOV = 05 = VENDA
	cQuery += " WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_=' ' AND D1_FLGNAT = ' ' "
	cQuery += "  ORDER BY SD1.D1_FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )
	oLogQueries:Log({cQuery})
	While !((cAliasSD1)->(Eof()))
		oDem := DMS_DataContainer():New({})

		aRetAux := OA5040101_Segmento_e_Armazem( aSegLoc , OA50400074_SegmtoVda((cAliasSD1)->(D2_DOC), (cAliasSD1)->(D2_SERIE), cConta) , (cAliasSD1)->D2_LOCAL )
		cSegmto := aRetAux[1]
		cNNRCod := aRetAux[2]

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial("VB8") },;
			{'VB8_PRODUT' , (cAliasSD1)->(D1_COD) },;
			{'VB8_CRICOD' , (cAliasSD1)->(B1_CRICOD) },;
			{'VB8_CODCLI' , (cAliasSD1)->(D2_CLIENTE) },;
			{'VB8_LOJCLI' , (cAliasSD1)->(D2_LOJA) },;
			{'VB8_ANO'    , Left((cAliasSD1)->(D2_EMISSAO),4) },;
			{'VB8_MES'    , Subs((cAliasSD1)->(D2_EMISSAO),5,2) },;
			{'VB8_DIA'    , Subs((cAliasSD1)->(D2_EMISSAO),7,2) },;
			{'VB8_NNRCOD' , cNNRCod },;
			{'VB8_LOCAL'  , "D1"},;
			{'VB8_TIPLOC' , "M"},;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"} ;
		})

		aDados := OA50400074_SegmtoVda((cAliasSD1)->(D2_DOC), (cAliasSD1)->(D2_SERIE))
		oDados:SetValue('VB8_SEGMTO', aDados[1])
		if lNovoCombo
			oDados:SetValue('VB8_ACCRPM', aDados[2])
		endif

		nTotMoeda := FG_MOEDA( (cAliasSD1)->(D1_TOTAL), (cAliasSD1)->F2_MOEDA, iif(lMultiMoeda, 1, 0),,, (cAliasSD1)->(D2_EMISSAO))
		nCusMoeda := (cAliasSD1)->(D1_CUSTO)
		nDescMoeda := (cAliasSD1)->(D1_VALDESC)

		oDem := DMS_DataContainer():New({})
		if Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFOFI","OFI"))
			oDem := DMS_DataContainer():New({;
				{'VB8_DEVOFI' , nTotMoeda - nDescMoeda},;
				{'VB8_CUSDEV' , nCusMoeda};
			})
		elseif Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFBAL","BAL"))
			oDem := DMS_DataContainer():New({;
				{'VB8_DEVBAL' , nTotMoeda - nDescMoeda},;
				{'VB8_CUSDEV' , nCusMoeda};
			})
		endif

		begin transaction
			OA50401_GravaDem(oDados, oDem)
			OA50400064_FlagaSD1((cAliasSD1)->(RECSD1), 'K')
		end transaction

		(cAliasSD1)->(DBSkip())
	enddo
	(cAliasSD1)->(DBCloseArea())
next

cFilAnt := cFilBkp

oLogger:Log( {STR0035+ " ("+FWTimeStamp(5)+")"} ) //"Execucao Completa"
oLogger:Log( {"############################################################################"} )
oLogger:CloseOpened(cTblLogCod) // fecha log de execução

If lAuto //Chamada Automatica
	OFIA505(aParam, lSoGer .or. lAuto,,, cConta)
else
	oEventDef:cLog := ""
	oBase:LoadValue("OFA_LOG", oLogger:cStringLog)
	oView:Refresh()
endif
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ConsDem    | Autor |  Vinicius Gati        | Data | 27/10/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_ConsDem(cCodSit)
	If empty(cCodSit)
		return .T.
	Endif
	If oDemDpm:isRecompra(cCodSit)
		return .F.
	EndIf
	If oDemDpm:isEspecial(cCodSit) // se for especial não considera na demanda, a funcao abaixo é só pra quando nao considerar demanda e for especial aí soma hits e imedb
		return .F.
	Endif
	If oDemDpm:ConsDemanda(cCodSit)
		return .T.
	Endif
Return .F.

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | FS_isEspecial | Autor |  Vinicius Gati     | Data | 21/08/24 |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_isEspecial(cCodSit)
return oDemDpm:isEspecial(cCodSit)

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Funcao    | FS_ExVB8      | Autor |  Vinicius Gati     | Data | 21/08/24 |##
##+----------+---------------+-------+--------------------+------+----------+##
##| Verifica se existe VB8 util para agrupar a demanda                      |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_ExVB8(oDados)
	cQuery := " SELECT COALESCE(R_E_C_N_O_, 0) VB8RECNO FROM " + oSqlHlp:NoLock("VB8")
	cQuery += " WHERE VB8_FILIAL = '"+xFilial("VB8")+"' AND "
	cQuery += " VB8_CODCLI = '" + oDados:GetValue('VB8_CODCLI', ' ') + "' AND VB8_LOJCLI = '" + oDados:GetValue('VB8_LOJCLI', ' ') + "' AND "
	cQuery += " VB8_PRODUT = '" + Left( oDados:GetValue('VB8_PRODUT', ' ') +SPACE(27),TamSX3("VB8_PRODUT")[1])+ "' AND "
	cQuery += " VB8_ANO    = '" + oDados:GetValue('VB8_ANO', ' ') + "' AND "
	cQuery += " VB8_MES    = '" + oDados:GetValue('VB8_MES', ' ') + "' AND "
	cQuery += " VB8_DIA    = '" + oDados:GetValue('VB8_DIA', ' ') + "' AND "
	cQuery += " VB8_SEGMTO = '" + oDados:GetValue('VB8_SEGMTO', ' ') + "' AND "
	cQuery += " VB8_NNRCOD = '" + oDados:GetValue("VB8_NNRCOD", ' ') + "' AND "
	cQuery += " VB8_FLGENV = ' ' AND "
	cQuery += " VB8_TIPREG != 'C' AND "
	cQuery += " VB8_STOCK  = '" + oDados:GetValue('VB8_STOCK', ' ') + "' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
return FM_SQL(cQuery)

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | OA50401_GravaDem | Autor |  Vinicius Gati  | Data | 21/08/24 |##
##+----------+---------------+-------+--------------------+------+----------+##
##| Gravará os dados da demanda no VB8 agrupando quando possivel            |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OA50401_GravaDem(oDados, oDem, lForceGer)
	Local nIdx   := 0
	Local nRecno := 0//FS_ExVB8(oDados) //-- nao reaproveitamos mais, nao faz sentido até pra debug além de que o certo é gravar orcamento e nota futuramente, e ficar 1x1 o VB8, seria o maximo detalhe
	Local cNumVB8 := ""
	
	Default lForceGer := .f.

	DBSelectArea('VB8')

	If nRecno == 0
		cNumVB8 := OA50400154_GetSxeNum("VB8", "VB8_CODIGO")
		ConfirmSx8() // sempre confirmamos agora pra evitar problemas
	EndIf

	begin transaction
		if nRecno > 0
			VB8->(DbGoTo(nRecno))
			reclock('VB8', .F.)
		else
			reclock('VB8', .T.)
			VB8->VB8_CODIGO := cNumVB8
		EndIf

		for nIdx := 1 to LEN( oDados:aData )// seta os dados dinamicamente
			cCampo := oDados:aData[nIdx][1]
			valor  := oDados:aData[nIdx][2]
			VB8->&(cCampo) := valor
		next

		for nIdx := 1 to LEN( oDem:aData )// dados de demanda feito +=
			cCampo      := oDem:aData[nIdx][1]
			valor       := oDem:aData[nIdx][2]
			valor_atual := VB8->&(cCampo)
			VB8->&(cCampo) := valor_atual + valor
		next

		if lNovoCombo
			if empty(VB8->VB8_SEGMTO) .and. OA50400164_MemSegmtoUnico(cFilAnt) != "-"
				VB8->VB8_SEGMTO := OA50400164_MemSegmtoUnico(cFilAnt)
			endif
			if empty(VB8->VB8_ACCRPM) .and. OA50400174_MemAccUnico(cFilAnt) != "-"
				VB8->VB8_ACCRPM := OA50400174_MemAccUnico(cFilAnt)
			endif
		endif

		If lForceGer
			msunlock()
			ConfirmSx8()
		Else
			if VB8->VB8_CUSBAL+ VB8->VB8_CUSBAN+ VB8->VB8_CUSOFI+ VB8->VB8_HIPERB+;
				VB8->VB8_HITSB+ VB8->VB8_HITSBN+ VB8->VB8_HITSO+ VB8->VB8_IMEDB+;
				VB8->VB8_IMEDBN+ VB8->VB8_IMEDO+ VB8->VB8_TOTBAL+ VB8->VB8_TOTBAN+;
				VB8->VB8_TOTOFI+ VB8->VB8_VDAB+ VB8->VB8_VDABN+ VB8->VB8_VDAO+;
				VB8->VB8_VDPERB+VB8->VB8_VDPERO+VB8->VB8_HIPERO > 0
				msunlock()
				ConfirmSx8()
			else
				RollBackSX8()
				disarmtransaction()
			end
		EndIf
	end transaction

	// Grava data de ultima venda
	if VB8->VB8_VDAB + VB8->VB8_VDAO + VB8->VB8_VDAI  > 0 // vendeu e considerou na demanda?
		if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
			if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(VB8->VB8_PRODUT)))
				if SBZ->BZ_ULTVDA < STOD( VB8->VB8_ANO + VB8->VB8_MES + VB8->VB8_DIA )
					DBSelectArea("SBZ")
					reclock("SBZ" , .F.)
					SBZ->BZ_ULTVDA := stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					msunlock()
				endif
			endif
		else // PARA QUEM USA SB5
			if SB5->(DBSeek(xFilial("SB5")+Alltrim(VB8->VB8_PRODUT)))
				if SB5->B5_ULTVDA < stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					DBSelectArea("SB5")
					reclock("SB5",.f.)
					SB5->B5_ULTVDA := stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					msunlock()
				endif
			endif
		endif
	endif

return VB8->VB8_CODIGO

/*/{Protheus.doc} OA50400024_FlagaD2
	Flaga a nota para marcar que já foi processada, a flag depende do tipo de processamento

	@type function
	@author Vinicius Gati
	@since 21/08/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
Function OA50400024_FlagaD2(nRecno, cFlag)
return TcSqlExec(" UPDATE " + RetSQLName('SD2') + " SET D2_FLGNAT = '"+cFlag+"' WHERE R_E_C_N_O_ = " +cValToChar(nRecno)) > 0

/*/{Protheus.doc} OA50400034_FlagaVSJ
	Flaga a VSJ para marcar que já foi processada, a flag depende do tipo de processamento

	@type function
	@author Vinicius Gati
	@since 21/08/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
Function OA50400034_FlagaVSJ(nRecno, cFlag)
return TcSqlExec(" UPDATE " + RetSQLName('VSJ') + " SET VSJ_FLGNAT = '"+cFlag+"' WHERE R_E_C_N_O_ = " +cValToChar(nRecno)) > 0

/*/{Protheus.doc} OA50400044_FlagaVOO
	Flaga a VOO para marcar que já foi processado, a flag depende do tipo de processamento

	@type function
	@author Vinicius Gati
	@since 21/08/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
Function OA50400044_FlagaVOO(nRecno, cFlag)
return TcSqlExec(" UPDATE " + RetSQLName('VOO') + " SET VOO_FLGNAT = '"+cFlag+"' WHERE R_E_C_N_O_ = " +cValToChar(nRecno)) > 0

/*/{Protheus.doc} OA50400054_FlagaVS3
	Flaga a VS3 para marcar que já foi processado, a flag depende do tipo de processamento

	@type function
	@author Vinicius Gati
	@since 21/08/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
Function OA50400054_FlagaVS3(nRecno, cFlag)
return TcSqlExec(" UPDATE " + RetSQLName('VS3') + " SET VS3_FLGNAT = '"+cFlag+"' WHERE R_E_C_N_O_ = " +cValToChar(nRecno)) > 0

/*/{Protheus.doc} OA50400064_FlagaSD1
	Flaga a SD1 para marcar que já foi processado, a flag depende do tipo de processamento

	@type function
	@author Vinicius Gati
	@since 21/08/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
Function OA50400064_FlagaSD1(nRecno, cFlag)
return TcSqlExec(" UPDATE " + RetSQLName('SD1') + " SET D1_FLGNAT = '"+cFlag+"' WHERE R_E_C_N_O_ = " +cValToChar(nRecno)) > 0

/*/{Protheus.doc} OA50400074_SegmtoVda
	Busca o segmento da venda via nota de venda, se for possível encontrar

	@type function
	@author Vinicius Gati
	@since 04/09/2024
	@returns Array => [1] segmento
	                  [2] conta se combo ou em branco
					  [3] se OS ou BALCAO usando nome do campo VO1_ ou VS1_
					  [4] numero da OS ou numero do orcamento
/*/
function OA50400074_SegmtoVda(cD2DOC, cD2SERIE, cConta, oSqlHlp)
	local aDados
	local aNDad
	local cQuery
	Default oSqlHlp := DMS_SqlHelper():New()
	cQuery := " SELECT VO1_SEGMTO "
	if lNovoCombo
		cQuery += ", VO1_ACCRPM "
	endif
	cQuery += " , VO1_NUMOSV"
	cQuery += "   FROM " + oSqlHlp:NoLock("SD2")
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VOO") + " ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMNFI = D2_DOC     AND VOO_SERNFI = D2_SERIE AND VOO.D_E_L_E_T_ = ' ' "	
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VO1") + " ON VO1_FILIAL = '"+xFilial('VO1')+"' AND VO1_NUMOSV = VOO_NUMOSV AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC   = '"+cD2DOC+"' AND D2_SERIE = '"+cD2SERIE+"' AND SD2.D_E_L_E_T_ = ' ' "
	if lNovoCombo
		cQuery += " AND VO1_ACCRPM != ' ' "
	endif
	aDados := oSqlHlp:GetSelectArray(oSqlHlp:TOPFunc(cQuery, 1), iif(lNovoCombo, 3, 2))

	if len(aDados) == 0
		return OA50400084_SegmtoVdaBcao(cD2DOC, cD2SERIE, cConta, oSqlHlp)
	endif
	if lNovoCombo
		aNDad := OA50400094_CertoOuPrincipal(aDados[1,1], aDados[1,2])
		return { aNDad[1], aNDad[2], "VO1_NUMOSV", aDados[1,3] }
	else
		aNDad := OA50400094_CertoOuPrincipal(aDados[1,1], "")
	endif	
return { aNDad[1], "", "VO1_NUMOSV", aDados[1,2] }

/*/{Protheus.doc} OA50400084_SegmtoVdaBcao
	Busca o segmento da venda via nota de venda, se for possível encontrar (nota e remito por isso 2 queries)

	@type function
	@author Vinicius Gati
	@since 04/09/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
function OA50400084_SegmtoVdaBcao(cD2DOC, cD2SERIE, cConta, oSqlHlp)
	local aDados
	local aNDad
	local cQuery
	local lVS1REMITO := VS1->(fieldPos("VS1_REMITO")) > 0
	Default oSqlHlp := DMS_SqlHelper():New()
	
	cQuery := " SELECT VS1_SEGMTO "
	if lNovoCombo
		cQuery += ", VS1_ACCRPM "
	endif
	cQuery += " , VS1_NUMORC "
	cQuery += "   FROM " + oSqlHlp:NoLock("SD2")
	cQuery += "   JOIN " + oSqlHlp:NoLock("VS1") + " ON SD2.D2_FILIAL = VS1.VS1_FILIAL AND SD2.D2_DOC = VS1.VS1_NUMNFI AND SD2.D2_SERIE = VS1.VS1_SERNFI "
	cQuery += "  WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC   = '"+cD2DOC+"' AND D2_SERIE = '"+cD2SERIE+"' AND SD2.D_E_L_E_T_ = ' ' "
	if lNovoCombo
		cQuery += " AND VS1_ACCRPM != ' ' "
	endif
	aDados := oSqlHlp:GetSelectArray(oSqlHlp:TOPFunc(cQuery, 1), iif(lNovoCombo, 3, 2))

	if len(aDados) > 0
		aNDad := OA50400094_CertoOuPrincipal(aDados[1,1], aDados[1,2])
		return { aNDad[1], aNDad[2], "VS1_NUMORC", iif(lNovoCombo, aDados[1,3], aDados[1,2]) }
	endif

	if lVS1REMITO

		cQuery := " SELECT VS1_SEGMTO "
		if lNovoCombo
			cQuery += ", VS1_ACCRPM "
		endif
		cQuery += " , VS1_NUMORC "
		cQuery += "   FROM " + oSqlHlp:NoLock("SD2")
		cQuery += "   JOIN " + oSqlHlp:NoLock("VS1") + " ON SD2.D2_FILIAL = VS1.VS1_FILIAL AND SD2.D2_DOC = VS1.VS1_REMITO AND SD2.D2_SERIE = VS1.VS1_SERREM "
		cQuery += "  WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC   = '"+cD2DOC+"' AND D2_SERIE = '"+cD2SERIE+"' AND SD2.D_E_L_E_T_ = ' ' "
		if lNovoCombo
			cQuery += " AND VS1_ACCRPM != ' ' "
		endif
		cSegmto := FM_SQL(oSqlHlp:TOPFunc(cQuery, 1))
		aDados := oSqlHlp:GetSelectArray(oSqlHlp:TOPFunc(cQuery, 1), iif(lNovoCombo, 3, 2))

		if len(aDados) > 0
			aNDad := OA50400094_CertoOuPrincipal(aDados[1,1], aDados[1,2])
			return { aNDad[1], aNDad[2], "VS1_NUMORC", iif(lNovoCombo, aDados[1,3], aDados[1,2]) }
		endif

	endif
return OA50400094_CertoOuPrincipal(" ", cConta, cFilAnt)

/*/{Protheus.doc} OA5040014_VerificaDupl
	Verifica se está processando duplicada a nota

	@type function
	@author Vinicius Gati
	@since 04/09/2024
	@returns boolean .t. ou .f. dependendo se concluiu a query com sucesso
/*/
function OA5040014_VerificaDupl(nRecno)
	if nRecno <= 0
		return .f.
	endif
	DBSelectArea("SD2")
	DBGoTo(nRecno)
	if ! Empty(SD2->D2_FLGNAT)
		return .t.
	endif
return .f.

/*/{Protheus.doc} OA50400094_CertoOuPrincipal
	Caso segmento e conta sejam em branco, procura o correto baseado no principal
	Isso é usado somente quando não tiver a informação ou seja, dados antigos após migrar para combo

	ATENCAO: Essa classe está memoizada e usa variavel global jMemCP para tal, a implementação real está em OA50400144_ExtCertoOuPrincipal

	@type function
	@author Vinicius Gati
	@since 21/02/2025
	@returns array posicao 1 segmento, posicao 2 conta ou vazio se for config antiga
/*/
function OA50400094_CertoOuPrincipal(cSegmto, cConta, cFlal)
	default cFlal := cFilAnt

	cProp := cValToChar(cSegmto) + cValToChar(cConta) + cValToChar(cFlal)

	if ! jMemCP:HasProperty(cProp)
		jMemCP[cProp] := OA50400144_ExtCertoOuPrincipal(cSegmto, cConta, cFlal)
	endif
return jMemCP[cProp]


/*/{Protheus.doc} OA50400102_BuscaLog
	Verifica se tem LOG e preenche
	
	@type function
	@author BrunoForcato
	@since 08/10/2025
/*/
static function OA50400102_BuscaLog()
return {;
	{;
		oEventDef:cLog ;
	}, 0;
}


/*/{Protheus.doc} OA50400114_BPRE_CONTAS
	Somente uma gambiarra necessaria pra nao dar mensagem de "Formulario nao alterado nao precisa ser salvo"
	
	@type function
	@author Vinicius Gati
	@since 05/12/2025
/*/
static function OA50400114_BPRE_CONTAS(oFormFields, cEvent, cField) 
	oModel:= oFormFields:GetModel()
	cVal := oFormFields:GetValue("OFA_CONTA")
	oModel:LoadValue("CONTAS", "OFA_CONTA", "")
	oModel:LoadValue("CONTAS", "OFA_CONTA", cVal)
	oView:SetModified(.t.)
return .t.


/*/{Protheus.doc} OA50400124_Processar
	Processamento de dados esperado da tela
	
	@type function
	@author Vinicius Gati
	@since 05/12/2025
/*/
static function OA50400124_Processar(oModel)
	OA504024_PROCESSO(,, oModel:GetValue("CONTAS", "OFA_CONTA"), oModel)
return .t.
/*/{Protheus.doc} OA5040101_Segmento_e_Armazem
	Retorna o Segmento e o Armazem da Configuração da Filial para gravar corretamente no VB8

	@type function
	@author Andre Luis Almeida
	@since 23/12/2025
	@param aSegLoc, array das Filiais com Segmento e Armazem -> { Filial , Segmento , Armazem }
	@param cSegmto, caracter Segmento de Origem Venda (cabeçalho)
	@param cNNRCod, caracter Armazem utilizado
	@returns aRetAux, array contendo o Segmento e o Armazem corretos em relacao a Configuração da Filial (OFIA503)
/*/
Static Function OA5040101_Segmento_e_Armazem( aSegLoc , cSegmto , cNNRCod )
Local cFilVB8 := xFilial("VB8")
Local aRetAux := { cSegmto , cNNRCod }
Local nPos := 0
If !Empty(cNNRCod)
	nPos := aScan(aSegLoc,{|x| x[1] + x[3] == cFilVB8 + cNNRCod }) // Achar a Filial + Armazem
EndIf
If nPos > 0
	aRetAux[1] := aSegLoc[nPos,2] // Pega o Segmento correspondente ao Armazem utilizado
Else
	cSeekA := cValToChar(cFilVB8) + cValtochar(cSegmto)
	nPos := aScan(aSegLoc,{|x| cValToChar(x[1]) + cValToChar(x[2]) == cSeekA }) // Achar a Filial + Segmento
	If nPos > 0
		aRetAux[2] := aSegLoc[nPos,3] // Pega o Armazem correspondente ao Segmento utilizado
	EndIf
EndIf
Return aRetAux

/*/{Protheus.doc} OA50400134_Converte_Moeda
	Tratamento de moeda
	
	@type function
	@author Vinicius Gati
	@since 15/01/2026
/*/
function OA50400134_Converte_Moeda(nMoedaAtu, nValor, dDataCot, lMultiMoeda)
	local nMoedaEnv := 2 
	default lMultiMoeda := FGX_MULTMOEDA()

	if !lMultiMoeda // Caso não for multimoeda sempre retorna o valor da moeda corrente (BRA)
		return nValor
	endif
return FG_MOEDA( nValor , nMoedaAtu, nMoedaEnv,,, dDataCot)


/*/{Protheus.doc} OA50400144_ExtCertoOuPrincipal
	Caso segmento e conta sejam em branco, procura o correto baseado no principal
	Isso é usado somente quando não tiver a informação ou seja, dados antigos após migrar para combo

	@type function
	@author Vinicius Gati
	@since 26/11/2025
	@returns array posicao 1 segmento, posicao 2 conta ou vazio se for config antiga
/*/
function OA50400144_ExtCertoOuPrincipal(cSegmto, cConta, cFlal)
	local aContas := {}
	local nX := 1
	default cFlal := cFilAnt

	if ! empty(cSegmto) .and. ! empty(cConta)
		return {cSegmto, cConta}
	endif

	aContas := OA5120074_BuscaContasRPM()

	if len(aContas) == 0
		aadd(aContas, nil)  // passando nil como uma conta pra config eu pego exatamente a config antiga sem conta, por isso funciona
	endif

	for nX := 1 to len(aContas)
		cConta := aContas[nX]
		oJdConfig := OFJDConfig():New(, cConta)
		cSegmto := oJdConfig:GetSegmentoPrincipal(cFlal)
		if ! empty(cSegmto)
			cConta := iif(valType(cConta) == "U", "", cConta)
			return { cSegmto, cConta }
		endif
	next
return { "","" }

/*
===============================================================================
###############################################################################
##+-------+---------------------+-------+-----------------+------+----------+##
##|Função | OJD31014_GetSxeNum  | Autor |  Vinicius Gati  | Data | 05/06/17 |##
##+-------+---------------------+-------+-----------------+------+----------+##
##| Verifica se a chave gerada pelo sxenum pode ser usada                   +##
##| e tenta gerar outra até conseguir com limite de 500mil tentativas       +##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OA50400154_GetSxeNum(cTabela, cCampo)
	Local cNum := 0
	Local nMaxTry := 1


	if lIndVB8CODIGO == NIL
		if FWSIXUtil():ExistIndex("VB8" , "5")
			lIndVB8CODIGO := (alltrim(cvaltochar(FWSIXUtil():GetAliasIndexes("VB8")[5,2])) == "VB8_CODIGO")
		endif
	endif

	if lIndVB8CODIGO
		cNum := GetSxeNum("VB8","VB8_CODIGO", "_" + xFilial("VB8") + "_CORR_VB8", 5)
		ConfirmSx8() // sempre confirmamos agora pra evitar problemas
		if empty(cNum)
			UserException("CODIGO NAO PODE SER GERADO COM CHAVE " + "_" + xFilial("VB8") + "_CORR_VB8 NO LICENSE")
		else
			Do While nMaxTry < 500 .and. FM_SQL(" SELECT count(VB8_CODIGO) FROM " + RetSQLName(cTabela) + "  WHERE "+cTabela+"_FILIAL = '"+xFilial(cTabela)+"' AND VB8_CODIGO = '"+cNum+"' ") > 0
				nMaxTry++
				cNum := GetSxeNum("VB8","VB8_CODIGO", "_" + xFilial("VB8") + "_CORR_VB8", 5)
				ConfirmSx8()
			end Do
		endif
	else
		cNum := FM_SQL(" SELECT MAX("+cCampo+") FROM " + RetSQLName(cTabela) + "  WHERE "+cTabela+"_FILIAL = '"+xFilial(cTabela)+"' ")
		cNum := soma1(cNum, TamSx3(cCampo)[1])
	endif
	
Return cNum

/*/{Protheus.doc} OA50400164_MemSegmtoUnico
	Memoization da funcao de segmento unico que serao chamadas muitas vezes

	@type function
	@author Vinicius Gati
	@since 11/05/2026
	@returns boolean se sim ou nao para segmento unico da filial
/*/
function OA50400164_MemSegmtoUnico(cFlal)
	default cFlal := cFilAnt

	if type("jMem14") != "J"
		jMem14 := JsonObject():New()
	endif

	if ! jMem14:HasProperty(cFlal)
		jMem14[cFlal] := OA5120144_ValUnicoSeg(cFlal)
	endif
return jMem14[cFlal]

/*/{Protheus.doc} OA50400174_MemAccUnico
	Memoization da funcao de account unico que sera chamada muitas vezes

	@type function
	@author Vinicius Gati
	@since 11/05/2026
	@returns boolean se sim ou nao para segmento unico da filial
/*/
function OA50400174_MemAccUnico(cFlal)
	default cFlal := cFilAnt

	if type("jMem17") != "J"
		jMem17 := JsonObject():New()
	endif

	if ! jMem17:HasProperty(cFlal)
		jMem17[cFlal] := OA5120154_UnicoAccount(cFlal)
	endif
return jMem17[cFlal]
