#Include "loca259d.ch"
#INCLUDE "PROTHEUS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA259DNW
Inclui uma nova demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 2/28/2025
@return variant, return_description
/*/
FUNCTION LOCA259DNW()

Local cTitulo := STR0001 //'Inclusão de Nova Demanda'
Local cMsg := STR0002 //'Gerando Nova Demanda'
Local lAborta := .F.
Local lRet := .T.

Processa( {|| lRet := Loca259DGD("I")}, cTitulo, cMsg, lAborta )

Return lRet

/*/{Protheus.doc} LOCA259DAE()
Inclui itens em demanda existente
@type function
@version 24.10
@author Alexandre Circenis
@since 2/28/2025
@return variant, return_description
/*/
FUNCTION LOCA259DAE()

Local cTitulo := STR0009 //"Incluir itens em demanda existente"
Local cMsg := STR0010  //"Peparando demanda"
Local lAborta := .F.
Local lRet := .T.

Processa( {|| lRet := Loca259DGD("A")}, cTitulo, cMsg, lAborta )

Return lRet

/*/{Protheus.doc} Loca259DGD
Rotina para incluir uma nova demanda
@type function
@version  24.10
@author Alexandre Circenis
@since 2/28/2025
/*/
Function Loca259DGD(cTipo)

Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local oRodape := oModel:GetModel("RODAPE")
Local aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
Local oDemanda := FWLoadModel("LOCA259A")
LOcal oMaster  := oDemanda:GetModel("FQTMASTER")
Local oView    := FWViewActive()
Local cDemanda := "" 
Local nQtde    := 0
Local nQtdeSep := 0
LOcal nQtde2   := 0
Local nI
LOcal nQItens    := 0
Local aEnableButtons := {}
Local cTitle
Local nOperation
Local nMulti := 1

//if Len(aAlteradas) = 0
//	Return
//endif

if cTipo = 'I'
	cTitle := STR0011 //'Incluir nova demanda'
	nOperation := MODEL_OPERATION_INSERT
elseif cTipo = 'A'
	cTitle := STR0012 //'Adicionar itens nessa demanda'
	nOperation := MODEL_OPERATION_UPDATE
elseif cTipo = 'D'
	cTitle := STR0019 //'Desvincular itens da demanda'
	nOperation := MODEL_OPERATION_UPDATE
	nMulti := -1
endif

//Posicionar na primeira linha marcada
oGrid:Goline(aAlteradas[1])
// Habilitar somente os botões Confirmar e Cancelar
aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0014},{.T.,STR0013},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar" //"Confirmar"

// Incluir uma nova demanda 
oDemanda:SetOperation( nOperation ) //Inclusao
oDemanda:Activate(.F.)



for nI := 1 to Len(aAlteradas)
	oGrid:Goline(aAlteradas[nI])
	if oGrid:GetValue("MARK")
		if cTipo = "I"
			oMaster:SetValue( "FQT_PROJET", oGrid:GetValue("FQ5_SOT"))
			oMaster:SetValue( "FQT_OBRA"  , oGrid:GetValue("FQ5_OBRA"))
		endif
		nQItens++
		if oGrid:GetValue("FQ5_STATUS") = '6'
			nQtdeSep  += oGrid:GetValue("FQ5_XQTD")
		else
			nQtde  += oGrid:GetValue("FQ5_XQTD")
		endif
		nQtde2 += oGrid:GetValue("FQ5_QTD2")
	endif
next

oMaster:SetValue( "FQT_ITENS" , FwFldGet("FQT_ITENS") + (nMulti * nQItens), .F. )
oMaster:SetValue( "FQT_QTDPRO", FwFldGet("FQT_QTDPRO") + (nMulti * nQtde), .F. )
oMaster:SetValue( "FQT_QTD2"  , FwFldGet("FQT_QTD2") +  (nMulti * nQtde2), .F. )
oMaster:SetValue( "FQT_PENDEN", FwFldGet("FQT_PENDEN") + (nMulti * nQtde), .F. )
oMaster:SetValue( "FQT_SEPARA", FwFldGet("FQT_SEPARA") + (nMulti * nQtdeSep), .F. )
oMaster:SetValue( "FQT_M3"    , FwFldGet("FQT_M3") + (nMulti * oRodape:GetValue("VOLUME")))
oMaster:SetValue( "FQT_PESBRU", FwFldGet("FQT_PESBRU") + (nMulti * oRodape:GetValue("PBRUTO")))
oMaster:SetValue( "FQT_PESLIQ", FwFldGet("FQT_PESLIQ") + (nMulti * oRodape:GetValue("PLIQ")))

if cTipo <> "D"
	if FWExecView( cTitle  , 'LOCA259A', nOperation, /*oDlg*/, {|| .T. } ,{|| cDemanda := oDemanda:GetModel("FQTMASTER"):GetValue("FQT_DEMAND"), .T. }/*bOk*/ , 10, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oDemanda ) <> 0
		oDemanda:DeActivate()
		oDemanda:Destroy()
		Return .F.
	endif

Else
	cDemanda := oDemanda:GetModel("FQTMASTER"):GetValue("FQT_DEMAND")
	If oDemanda:VldData()
 		oDemanda:CommitData()
	else
   		Aviso(STR0022,VarInfo("",oDemanda:GetErrorMessage())) //"Erro na Atualização da Demanda"
		oDemanda:DeActivate()
		oDemanda:Destroy()
		Return .F.
	EndIf
Endif

oDemanda:DeActivate()
oDemanda:Destroy()

nItens := Loca259DID(cDemanda, oGrid, aAlteradas, cTipo)

if cTipo = "I"
	Aviso(STR0007, STR0004+cDemanda+STR0015+ Alltrim(Str(nItens,4,0))+ STR0006, {STR0005}) //"Nova demanda incluida " //"&Ok" //" itens." //"Nova Demanda" //" com "
elseif cTipo = "A"
	Aviso(STR0018, STR0017 +Alltrim(Str(nItens,4,0))+ STR0016+cDemanda, {STR0005}) //"&Ok"  //" itens na demanda " //"Foram incluidos " //"Itens Incluidos em demanda"
elseif cTipo = "D"
	Aviso(STR0020, STR0021 +Alltrim(Str(nItens,4,0))+ STR0016+cDemanda, {STR0005})  //"Itens desvinculados" //"Foram desvinculados "
endif

if cTipo <> "D"
	oModel:Deactivate()
	oModel:Activate()

	oview:Refresh()
endif

return .t.

/*/{Protheus.doc} Loca259DID
Atualiza os dados da A.S. que foi incluida na demanda
@type function
@version 24.10  
@author Alexandre Circenis
@since 2/28/2025
@param cDemanda, character, Codigo da demanda
@param oGrid, object, Grid com as AS selecionadas
@param aAlteradas, Array, Contem as linhas do Grid que foram alteradas
@return variant, Numero de itens incluidos na demanda
/*/
Function Loca259DID(cDemanda, oGrid, aAlteradas, cTipo)
Local nI
Local aArea := GetArea()
Local nItens := 0
// amarrar os itens na demanda
For nI := 1 To Len(aAlteradas)
	IncProc(STR0008) //"Incluindo Itens na Demanda"
	oGrid:Goline(aAlteradas[nI])
	if oGrid:GetValue("MARK")
		FQ5->(dbGoTo(oGrid:GetDataID()))
    	RecLock("FQ5",.F.)
		if cTipo = 'D'
			FQ5->FQ5_DEMAND  := " "
		else
    		FQ5->FQ5_DEMAND  := cDemanda
			FQ5->FQ5_STDEMA  := IF(oGrid:GetValue("FQ5_STATUS")='6','2', '1') // Item com remessa pendente
			FQ5->FQ5_QTD2    := oGrid:GetValue("FQ5_QTD2")
			FQ5->FQ5_PESLIQ  := oGrid:GetValue("FQ5_PESLIQ")
			FQ5->FQ5_PESBRU  := oGrid:GetValue("FQ5_PESBRU")
			FQ5->FQ5_M3      := oGrid:GetValue("FQ5_M3")
		endif	
    	FQ5->(msUnlock())
		nItens++
	endif	
next
RestArea(aArea)
Return nItens


/*/{Protheus.doc} MENUDEF
Menu dos Itens da demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Array com as opçoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

ADD OPTION aRotina TITLE "Imprimir A.S."   ACTION 'LOCR015( FQ5->FQ5_AS )' OPERATION MODEL_OPERATION_VIEW ACCESS 0  //'Visualizar'

Return aRotina
