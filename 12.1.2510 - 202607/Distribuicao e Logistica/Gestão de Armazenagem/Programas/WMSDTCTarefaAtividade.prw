#Include "Totvs.ch"  
#Include "WMSDTCTarefaAtividade.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0045
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0045()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCTarefaAtividade
Classe tarefa x atividade
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCTarefaAtividade FROM LongNameClass
	// Data
	DATA cTarefa
	DATA cOrdem
	DATA cAtivid
	DATA cFuncao
	DATA cTpRec
	DATA cDurac
	DATA cRadioF
	DATA cFilAti
	DATA cObs
	DATA cTpAglu
	DATA cPerMultip
	DATA cSolicEnd
	DATA cDescTar
	DATA cDescAti
	DATA aAtividade AS Array
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cTarefaAnt //Performance
	DATA cOrdemAnt  //Performance
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetTarefa(cTarefa)
	METHOD SetOrdem(cOrdem)
	METHOD GetTarefa()
	METHOD GetOrdem()
	METHOD GetAtivid()
	METHOD GetFuncao()
	METHOD GetTpRec()
	METHOD GetDurac()
	METHOD GetRadioF()
	METHOD GetFilAti()
	METHOD GetObs()
	METHOD GetTpAglu()
	METHOD GetPerMult()
	METHOD GetSolEnd()
	METHOD GetMntVol()
	METHOD GetDesTar()
	METHOD GetDesAti()
	METHOD GetArrAti()
	METHOD TarefaAtiv()
	METHOD ChkPerMult()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSDTCTarefaAtividade
	Self:cTarefa    := PadR("", TamSx3("DC6_TAREFA")[1])
	Self:cOrdem     := "01"
	Self:cTarefaAnt := PadR("", Len(Self:cTarefa))
	Self:cOrdemAnt  := "01"
	Self:cAtivid    := PadR("", TamSx3("DC6_ATIVID")[1])
	Self:cFuncao    := PadR("", TamSx3("DC6_FUNCAO")[1])
	Self:cTpRec     := PadR("", TamSx3("DC6_TPREC")[1])
	Self:cDurac     := PadR("", TamSx3("DC6_DURAC")[1])
	Self:cRadioF    := PadR("", TamSx3("DC6_RADIOF")[1])
	Self:cFilAti    := PadR("", TamSx3("DC6_FILATI")[1])
	Self:cObs       := PadR("", TamSx3("DC6_OBS")[1])
	Self:cPerMultip := "1"
	Self:cTpAglu    := PadR("", TamSx3("DC6_TPAGLU")[1])
	Self:cSolicEnd  := "0"
	Self:cDescTar   := ""
	Self:cDescAti   := ""
	Self:aAtividade := {}
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCTarefaAtividade
	//Mantido para compatibilidade
Return Nil

METHOD LoadData(nIndex) CLASS WMSDTCTarefaAtividade
Local lRet     := .T.
Local lCarrega := .T.
Local aAreaAnt := GetArea()
Local aAreaDC6 := DC6->(GetArea())
Local cAliasDC6:= Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DC6_FILIAL+DC6_TAREFA+DC6_ORDEM
			If (Empty(Self:cTarefa).OR. Empty(Self:cOrdem))
				lRet := .F.
			Else
				//Se não mudou a chave não recarrega nada - Performance
				If Self:cTarefa == Self:cTarefaAnt .And. Self:cOrdem == Self:cOrdemAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDC6 := GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasDC6
						SELECT DC6.DC6_TAREFA,
								DC6.DC6_ORDEM,
								DC6.DC6_ATIVID,
								DC6.DC6_FUNCAO,
								DC6.DC6_TPREC,
								DC6.DC6_DURAC,
								DC6.DC6_RADIOF,
								DC6.DC6_FILATI,
								DC6.DC6_OBS,
								DC6.DC6_TPAGLU,
								DC6.DC6_PERMUL,
								DC6.DC6_TAREFA,
								DC6.DC6_ATIVID,
								DC6.DC6_SOLEND,
								DC6.R_E_C_N_O_ RECNODC6
						FROM %Table:DC6% DC6
						WHERE DC6.DC6_FILIAL = %xFilial:DC6%
						AND DC6.DC6_TAREFA = %Exp:Self:cTarefa%
						AND DC6.DC6_ORDEM =  %Exp:Self:cOrdem%
						AND DC6.%NotDel%
					EndSql
			EndCase
			lRet := (cAliasDC6)->(!Eof())
			If lRet
				Self:cTarefa    := (cAliasDC6)->DC6_TAREFA
				Self:cOrdem     := (cAliasDC6)->DC6_ORDEM
				Self:cAtivid    := (cAliasDC6)->DC6_ATIVID
				Self:cFuncao    := (cAliasDC6)->DC6_FUNCAO
				Self:cTpRec     := (cAliasDC6)->DC6_TPREC
				Self:cDurac     := (cAliasDC6)->DC6_DURAC
				Self:cRadioF    := (cAliasDC6)->DC6_RADIOF
				Self:cFilAti    := (cAliasDC6)->DC6_FILATI
				Self:cObs       := (cAliasDC6)->DC6_OBS
				Self:cTpAglu    := (cAliasDC6)->DC6_TPAGLU
				Self:cPerMultip := IIf(Empty((cAliasDC6)->DC6_PERMUL),"1",(cAliasDC6)->DC6_PERMUL)
				Self:cSolicEnd  := IIf(Empty((cAliasDC6)->DC6_SOLEND),"0",(cAliasDC6)->DC6_SOLEND)
				Self:cDescTar   := Tabela("L2", (cAliasDC6)->DC6_TAREFA, .F.)
				Self:cDescAti   := Tabela("L3", (cAliasDC6)->DC6_ATIVID, .F.)
				Self:nRecno     := (cAliasDC6)->RECNODC6
				// Dados controle anterior	
				Self:cTarefaAnt := Self:cTarefa
				Self:cOrdemAnt  := Self:cOrdem
			EndIf
			(cAliasDC6)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDC6)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetTarefa(cTarefa) CLASS WMSDTCTarefaAtividade
	Self:cTarefa := PadR(cTarefa, Len(Self:cTarefa))
Return

METHOD SetOrdem(cOrdem) CLASS WMSDTCTarefaAtividade
	Self:cOrdem := PadR(cOrdem, Len(Self:cOrdem))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetTarefa() CLASS WMSDTCTarefaAtividade
Return Self:cTarefa

METHOD GetOrdem() CLASS WMSDTCTarefaAtividade
Return Self:cOrdem

METHOD GetAtivid() CLASS WMSDTCTarefaAtividade
Return Self:cAtivid

METHOD GetFuncao() CLASS WMSDTCTarefaAtividade
Return Self:cFuncao

METHOD GetTpRec() CLASS WMSDTCTarefaAtividade
Return Self:cTpRec

METHOD GetDurac() CLASS WMSDTCTarefaAtividade
Return Self:cDurac

METHOD GetRadioF() CLASS WMSDTCTarefaAtividade
Return Self:cRadioF

METHOD GetFilAti() CLASS WMSDTCTarefaAtividade
Return Self:cFilAti

METHOD GetObs() CLASS WMSDTCTarefaAtividade
Return Self:cObs

METHOD GetTpAglu() CLASS WMSDTCTarefaAtividade
Return Self:cTpAglu

METHOD GetPerMult() CLASS WMSDTCTarefaAtividade
Return Self:cPerMultip

METHOD GetSolEnd() CLASS WMSDTCTarefaAtividade
Return Self:cSolicEnd

METHOD GetDesTar() CLASS WMSDTCTarefaAtividade
Return Self:cDescTar

METHOD GetDesAti() CLASS WMSDTCTarefaAtividade
Return Self:cDescAti

METHOD GetArrAti() CLASS WMSDTCTarefaAtividade
Return Self:aAtividade

METHOD ChkPerMult() CLASS WMSDTCTarefaAtividade
Return (Self:cPerMultip != "2")

METHOD TarefaAtiv() CLASS WMSDTCTarefaAtividade
Local lRet     := .T.
Local aAreaDC6 := DC6->(GetArea())
Local cAliasDC6:= ""

	Self:aAtividade := {}
	cAliasDC6 := GetNextAlias()
	BeginSql Alias cAliasDC6
		SELECT DC6.DC6_ORDEM
		FROM %Table:DC6% DC6
		WHERE DC6.DC6_FILIAL = %xFilial:DC6%
		AND DC6.DC6_TAREFA = %Exp:Self:cTarefa%
		AND DC6.%NotDel%
	EndSql
	Do While (cAliasDC6)->(!Eof())
		aAdd(Self:aAtividade, {(cAliasDC6)->DC6_ORDEM})
		(cAliasDC6)->(dbSkip())
	EndDo
	(cAliasDC6)->(dbCloseArea())
	RestArea(aAreaDC6)
Return lRet
