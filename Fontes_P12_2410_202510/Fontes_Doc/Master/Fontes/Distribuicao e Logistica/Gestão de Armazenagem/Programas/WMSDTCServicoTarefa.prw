#Include "Totvs.ch"
#Include "WMSDTCServicoTarefa.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0044
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0044()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCServicoTarefa
Classe serviço  x tarefa
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCServicoTarefa FROM LongNameClass
	// Data
	DATA cServico
	DATA cDescServ
	DATA cTipo
	DATA cOrdem
	DATA cTarefa
	DATA cCatSer
	DATA cFunExe
	DATA cTipRat
	DATA cTpExec
	DATA cBlqSld
	DATA cBlqSrv
	DATA cFuncao
	DATA cConfExp
	DATA cMntVol
	DATA cDisSep
	DATA cMntExc
	DATA cSolImpEti
	DATA cLibPed
	DATA cUpdEnd
	DATA cUpdPrd
	DATA cMltAti
	DATA cOperacao
	DATA cBxEsto
	DATA aTarefa AS Array
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cServAnt  // Performance
	DATA cOrdemAnt // Performance
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetServico(cServico)
	METHOD SetOrdem(cOrdem)
	METHOD SetTarefa(cTarefa)
	METHOD SetTipo(cTipo)
	METHOD SetTpExec(cTpExec)
	METHOD GetServico()
	METHOD GetDesServ()
	METHOD GetOrdem()
	METHOD GetTarefa()
	METHOD GetTipo()
	METHOD GetCatSer()
	METHOD GetFunExe()
	METHOD GetTipRat()
	METHOD GetTpExec()
	METHOD GetBlqSrv()
	METHOD GetRotina()
	METHOD GetFuncao()
	METHOD GetOperac()
	METHOD GetMntVol()
	METHOD GetDisSep()
	METHOD GetLibPed()
	METHOD GetMntExc()
	METHOD GetMltAti()
	METHOD GetArrTar()
	METHOD GetSolImpE()
	METHOD GetUpdEnd()
	METHOD GetUpdAti()
	METHOD GetBxEsto()
	METHOD GetErro()
	METHOD ChkArmaz()
	METHOD ChkCross()
	METHOD ChkSepNorm()
	METHOD ChkSpCross()
	METHOD ChkReabast()
	METHOD ChkConfEnt()
	METHOD ChkConfSai()
	METHOD ChkTransf()
	METHOD ChkRecebi()
	METHOD ChkSepara()
	METHOD ChkConfer()
	METHOD ChkMntVol()
	METHOD ChkConfExp()
	METHOD ChkUpdEnd()
	METHOD ChkBlqSld()
	METHOD FindReabas()
	METHOD FindConfEnt()
	METHOD FindConfSai()
	METHOD FindTransf()
	METHOD ServTarefa()
	METHOD FindOrdAnt()
	METHOD ChkServico(cOperacao)
	METHOD HasOperac(aOperacao)
	METHOD ChkMovEst()
	METHOD ChkDisSep()
	METHOD ChkConfOrd(nTipo)
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSDTCServicoTarefa
	Self:cServico  := PadR("", TamSx3("DC5_SERVIC")[1])
	Self:cOrdem    := "01"
	Self:cServAnt  := PadR("", Len(Self:cServico))
	Self:cOrdemAnt := "01"
	Self:cDescServ := ""
	Self:cTipo     := PadR("", TamSx3("DC5_TIPO")[1])
	Self:cTarefa   := PadR("", TamSx3("DC5_TAREFA")[1])
	Self:cCatSer   := PadR("", TamSx3("DC5_CATSER")[1])
	Self:cFunExe   := PadR("", TamSx3("DC5_FUNEXE")[1])
	Self:cTipRat   := PadR("", TamSx3("DC5_TIPRAT")[1])
	Self:cTpExec   := PadR("", TamSx3("DC5_TPEXEC")[1])
	Self:cOperacao := PadR("", TamSx3("DC5_OPERAC")[1])
	Self:cBlqSld   := PadR("", TamSx3("DC5_BLQLOT")[1])
	Self:cBlqSrv   := PadR("", TamSx3("DC5_BLQSRV")[1])
	Self:aTarefa   := {}
	Self:cConfExp  := "2"
	Self:cMntVol   := "0"
	Self:cDisSep   := "2"
	Self:cLibPed   := "1"
	Self:cUpdEnd   := "2"
	Self:cUpdPrd   := "1"
	Self:cMntExc   := "2"
	Self:cSolImpEti:= "1"
	Self:cBxEsto   := "2"
	Self:nRecno    := 0
	Self:cErro     := ""
	Self:cFuncao   := ""
Return

METHOD Destroy() CLASS WMSDTCServicoTarefa
	// FreeObj(Self)
Return Nil

METHOD LoadData(nIndex) CLASS WMSDTCServicoTarefa
Local lRet     := .T.
Local lCarrega := .T.
Local aAreaAnt := GetArea()
Local aAreaDC5 := DC5->(GetArea())
Local cAliasDC5:= Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
			If (Empty(Self:cServico).OR. Empty(Self:cOrdem))
				lRet := .F.
			Else
				If Self:cServico == Self:cServAnt .And. Self:cOrdem == Self:cOrdemAnt
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
			cAliasDC5:= GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasDC5
						SELECT DC5.DC5_SERVIC,
								DC5.DC5_ORDEM,
								DC5.DC5_TIPO,
								DC5.DC5_TAREFA,
								DC5.DC5_CATSER,
								DC5.DC5_FUNEXE,
								DC5.DC5_TIPRAT,
								DC5.DC5_TPEXEC,
								DC5.DC5_BLQLOT,
								DC5.DC5_BLQSRV,
								DC5.DC5_FUNEXE,
								DC5.DC5_COFEXP,
								DC5.DC5_MNTVOL,
								DC5.DC5_DISSEP,
								DC5.DC5_LIBPED,
								DC5.DC5_MNTEXC,
								DC5.DC5_MLTATI,
								DC5.DC5_IMPETI,
								DC5.DC5_UPDEND,
								DC5.DC5_UPDPRD,
								DC5.DC5_OPERAC,
								DC5.DC5_BXESTO,
								DC5.R_E_C_N_O_ RECNODC5
						FROM %Table:DC5% DC5
						WHERE DC5.DC5_FILIAL = %xFilial:DC5%
						AND DC5.DC5_SERVIC = %Exp:Self:cServico%
						AND DC5.DC5_ORDEM = %Exp:Self:cOrdem%
						AND DC5.%NotDel%
				EndSql
			EndCAse
			lRet := (cAliasDC5)->(!Eof())
			If lRet
				Self:cServico  := (cAliasDC5)->DC5_SERVIC
				Self:cOrdem    := (cAliasDC5)->DC5_ORDEM
				Self:cDescServ := Tabela("L4",Self:cServico,.F.)
				Self:cTipo     := (cAliasDC5)->DC5_TIPO
				Self:cTarefa   := (cAliasDC5)->DC5_TAREFA
				Self:cCatSer   := (cAliasDC5)->DC5_CATSER
				Self:cFunExe   := (cAliasDC5)->DC5_FUNEXE
				Self:cTipRat   := (cAliasDC5)->DC5_TIPRAT
				Self:cTpExec   := (cAliasDC5)->DC5_TPEXEC
				Self:cBlqSld   := (cAliasDC5)->DC5_BLQLOT
				Self:cBlqSrv   := (cAliasDC5)->DC5_BLQSRV
				Self:cFuncao   := Tabela("L6",Self:cFunExe,.F.)
				Self:cOperacao := IIf(Empty((cAliasDC5)->DC5_OPERAC)," ",(cAliasDC5)->DC5_OPERAC)
				Self:cConfExp  := IIf(Empty((cAliasDC5)->DC5_COFEXP),"2",(cAliasDC5)->DC5_COFEXP)
				Self:cMntVol   := IIf(Empty((cAliasDC5)->DC5_MNTVOL),"0",(cAliasDC5)->DC5_MNTVOL)
				Self:cDisSep   := IIf(Empty((cAliasDC5)->DC5_DISSEP),"2",(cAliasDC5)->DC5_DISSEP)
				Self:cLibPed   := IIf(Empty((cAliasDC5)->DC5_LIBPED),"1",(cAliasDC5)->DC5_LIBPED)
				Self:cMntExc   := IIf(Empty((cAliasDC5)->DC5_MNTEXC),"2",(cAliasDC5)->DC5_MNTEXC)
				Self:cMltAti   := IIf(Empty((cAliasDC5)->DC5_MLTATI),"0",(cAliasDC5)->DC5_MLTATI)
				Self:cSolImpEti:= IIf(Empty((cAliasDC5)->DC5_IMPETI),"1",(cAliasDC5)->DC5_IMPETI)
				Self:cUpdEnd   := IIf(Empty((cAliasDC5)->DC5_UPDEND),"2",(cAliasDC5)->DC5_UPDEND) // Troca endereço destino
				Self:cUpdPrd   := IIf(Empty((cAliasDC5)->DC5_UPDPRD),"1",(cAliasDC5)->DC5_UPDPRD) // Troca produto convocação 1= Não permite; 2=Permite sem confirmação; 3=Permite e solicita confirmação
				Self:cBxEsto   := IIf(Empty((cAliasDC5)->DC5_BXESTO),"2",(cAliasDC5)->DC5_BXESTO) // Baixa estoque movimento interno de requisição 1=Sim; 2=Não
				Self:nRecno    := (cAliasDC5)->RECNODC5
				// Controle dados anteriores
				Self:cServAnt  := Self:cServico
				Self:cOrdemAnt := Self:cOrdem
			Else
				Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",AllTrim(Self:cServico)}}) // Serviço [VAR01] não cadastrado!
				lRet := .F.
			EndIf
			(cAliasDC5)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDC5)
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetServico(cServico) CLASS WMSDTCServicoTarefa
	Self:cServico := PadR(cServico, Len(Self:cServico))
Return

METHOD SetOrdem(cOrdem) CLASS WMSDTCServicoTarefa
	Self:cOrdem := PadR(cOrdem, Len(Self:cOrdem))
Return

METHOD SetTipo(cTipo) CLASS WMSDTCServicoTarefa
	Self:cTipo := PadR(cTipo, Len(Self:cTipo))
Return

METHOD SetTarefa(cTarefa) CLASS WMSDTCServicoTarefa
	Self:cTarefa := PadR(cTarefa, Len(Self:cTarefa))
Return

METHOD SetTpExec(cTpExec) CLASS WMSDTCServicoTarefa
	Self:cTpExec := PadR(cTpExec, Len(Self:cTpExec))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetServico() CLASS WMSDTCServicoTarefa
Return Self:cServico

METHOD GetDesServ() CLASS WMSDTCServicoTarefa
Return Self:cDescServ

METHOD GetOrdem() CLASS WMSDTCServicoTarefa
Return Self:cOrdem

METHOD GetTipo() CLASS WMSDTCServicoTarefa
Return Self:cTipo

METHOD GetTarefa() CLASS WMSDTCServicoTarefa
Return Self:cTarefa

METHOD GetCatSer() CLASS WMSDTCServicoTarefa
Return Self:cCatSer

METHOD GetFunExe() CLASS WMSDTCServicoTarefa
Return Self:cFunExe

METHOD GetTipRat() CLASS WMSDTCServicoTarefa
Return Self:cTipRat

METHOD GetTpExec() CLASS WMSDTCServicoTarefa
Return Self:cTpExec

METHOD GetBlqSrv() CLASS WMSDTCServicoTarefa
Return Self:cBlqSrv

METHOD GetFuncao() CLASS WMSDTCServicoTarefa
Return Self:cFuncao

METHOD GetOperac() CLASS WMSDTCServicoTarefa
Return Self:cOperacao

METHOD GetBxEsto()  CLASS WMSDTCServicoTarefa
Return Self:cBxEsto

METHOD GetMntVol() CLASS WMSDTCServicoTarefa
Return Self:cMntVol

METHOD GetDisSep() CLASS WMSDTCServicoTarefa
Return Self:cDisSep

METHOD GetLibPed() CLASS WMSDTCServicoTarefa
Return Self:cLibPed

METHOD GetMntExc() CLASS WMSDTCServicoTarefa
Return Self:cMntExc

METHOD GetMltAti() CLASS WMSDTCServicoTarefa
Return Self:cMltAti

METHOD GetSolImpE() CLASS WMSDTCServicoTarefa
Return Self:cSolImpEti

METHOD GetArrTar() CLASS WMSDTCServicoTarefa
Return Self:aTarefa

METHOD GetUpdEnd() CLASS WMSDTCServicoTarefa
Return Self:cUpdEnd

METHOD GetUpdAti() CLASS WMSDTCServicoTarefa
Return Self:cUpdPrd

METHOD GetErro() CLASS WMSDTCServicoTarefa
Return Self:cErro

METHOD ChkArmaz() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '1'

METHOD ChkCross() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '2'

METHOD ChkSepNorm() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '3'

METHOD ChkSpCross() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '4'

METHOD ChkReabast() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '5'

METHOD ChkConfEnt() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '6'

METHOD ChkConfSai() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '7'

METHOD ChkTransf() CLASS WMSDTCServicoTarefa
Return Self:cOperacao == '8'

METHOD ChkRecebi() CLASS WMSDTCServicoTarefa
Return (Self:ChkCross() .OR. Self:ChkArmaz())

METHOD ChkSepara() CLASS WMSDTCServicoTarefa
Return (Self:ChkSepNorm() .OR. Self:ChkSpCross())

METHOD ChkConfer() CLASS WMSDTCServicoTarefa
Return (Self:ChkConfEnt() .OR. Self:ChkConfSai())

METHOD ChkMovEst() CLASS WMSDTCServicoTarefa
Return (Self:ChkSepara() .Or. Self:ChkRecebi() .Or. Self:ChkTransf() .Or. Self:ChkReabast())

METHOD ChkDisSep() CLASS WMSDTCServicoTarefa
Return (Self:cDisSep == '1')

METHOD ChkConfExp() CLASS WMSDTCServicoTarefa
Return (Self:cConfExp == '1')

METHOD ChkMntVol() CLASS WMSDTCServicoTarefa
Return (Self:cMntVol != '0')

METHOD ChkUpdEnd() CLASS WMSDTCServicoTarefa
Return (Self:cUpdEnd == '1')

METHOD ChkBlqSld() CLASS WMSDTCServicoTarefa
Return (Self:cBlqSld == '1')

METHOD ServTarefa() CLASS WMSDTCServicoTarefa
Local lRet      := .T.
Local aAreaDC5  := DC5->(GetArea())
Local cAliasDC5 := GetNextAlias()
	Self:aTarefa := {}

	BeginSql Alias cAliasDC5
		SELECT DC5.DC5_ORDEM
		FROM %Table:DC5% DC5
		WHERE DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = %Exp:Self:cServico%
		AND DC5.%NotDel%
	EndSql
	Do While (cAliasDC5)->(!Eof())
		aAdd(Self:aTarefa, {(cAliasDC5)->DC5_ORDEM})
		(cAliasDC5)->(dbSkip())
	EndDo
	(cAliasDC5)->(dbCloseArea())
	RestArea(aAreaDC5)
Return lRet

METHOD FindOrdAnt() CLASS WMSDTCServicoTarefa
Local cOrdSep   := "1"
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT DC5.DC5_ORDEM
		FROM %Table:DC5% DC5
		WHERE DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = %Exp:Self:cServico%
		AND DC5.DC5_ORDEM < %Exp:Self:cOrdem%
		AND DC5.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		cOrdSep := (cAliasQry)->DC5_ORDEM
	EndIf

	(cAliasQry)->(dbCloseArea())
Return cOrdSep

METHOD ChkServico(cOperacao) CLASS WMSDTCServicoTarefa
Local aAreaDC5 := DC5->(GetArea())
Local cServico  := ""
Local cAliasDC5 := GetNextAlias()
	If !Empty(cOperacao)
		BeginSql Alias cAliasDC5
			SELECT DC5.DC5_SERVIC
			FROM %Table:DC5% DC5
			WHERE DC5.DC5_FILIAL = %xFilial:DC5%
			AND DC5.DC5_OPERAC = %Exp:cOperacao%
			AND DC5.%NotDel%
		EndSql
		If (cAliasDC5)->(!Eof())
			cServico := (cAliasDC5)->DC5_SERVIC
		EndIf
		If Empty(cServico)
			Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",AllTrim(cOperacao)}}) // Não existe um serviço cadastrado (DC5) com a operacao [VAR01]!
		EndIf
	Else
		Self:cErro := STR0003 // Função não informada!
	EndIf
	(cAliasDC5)->(dbCloseArea())
	RestArea(aAreaDC5)
Return cServico

METHOD FindReabas() CLASS WMSDTCServicoTarefa
Return Self:ChkServico('5')

METHOD FindConfEnt() CLASS WMSDTCServicoTarefa
Return Self:ChkServico('6')

METHOD FindConfSai() CLASS WMSDTCServicoTarefa
Return Self:ChkServico('7')

METHOD FindTransf() CLASS WMSDTCServicoTarefa
Return Self:ChkServico('8')

METHOD HasOperac(aOperacao) CLASS WMSDTCServicoTarefa
Local lRet      := .T.
Local aAreaDC5  := DC5->(GetArea())
Local cListOpe  := ""
Local cListOper := ""
Local cAliasDC5 := Nil
Local nCont     := 0

	If !Empty(aOperacao)
		cListOpe := ""
		For nCont := 1 to Len(aOperacao)
			cListOpe += "'"+aOperacao[nCont]+"',"
		Next nCont
		cListOpe := SubsTr(cListOpe,1,Len(cListOpe)-1)
	EndIf
	If !Empty(cListOpe)
		cListOper := +StrTran(StrTran(cListOpe,"'",""),",","|")
		cListOpe := "%"+cListOpe+"%"
		cAliasDC5 := GetNextAlias()
		BeginSql Alias cAliasDC5
			SELECT DC5.DC5_SERVIC
			FROM %Table:DC5% DC5
			WHERE DC5.DC5_FILIAL = %xFilial:DC5%
			AND DC5.DC5_SERVIC = %Exp:Self:cServico%
			AND DC5.DC5_OPERAC IN ( %Exp:cListOpe% )
			AND DC5.%NotDel%
		EndSql
		If (cAliasDC5)->(Eof())
			Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",AllTrim(Self:cServico)},{"[VAR02]",AllTrim(cListOper)}}) // Não existe no serviço [VAR01] a(s) função(ões) [VAR02]!
			lRet := .F.
		EndIf
		(cAliasDC5)->(dbCloseArea())
	Else
		Self:cErro := STR0003 // Função não informada!
		lRet := .F.
	EndIf
	RestArea(aAreaDC5)
Return lRet

METHOD ChkConfOrd(nTipo) CLASS WMSDTCServicoTarefa
Local lRet      := .T.
Local cAliasDC5 := Nil

Default nTipo := 1

	If nTipo == 1

		// Valida se não há tarefas WMS Padrão antes da tarefa de conferencia de entrada
		cAliasDC5 := GetNextAlias()
		BeginSql Alias cAliasDC5
			SELECT DC5.DC5_OPERAC
			FROM %Table:DC5% DC5
			WHERE DC5.DC5_FILIAL = %xFilial:DC5%
			AND DC5.DC5_SERVIC = %Exp:Self:GetServico()%
			AND DC5.DC5_ORDEM  < (  SELECT DC51.DC5_ORDEM
									FROM %Table:DC5% DC51
									WHERE DC51.DC5_FILIAL = %xFilial:DC5%
									AND DC51.DC5_SERVIC = %Exp:Self:GetServico()%
									AND DC51.DC5_OPERAC = '6'
									AND DC51.%NotDel% )
			AND DC5.DC5_OPERAC NOT IN ('0','6')
			AND DC5.%NotDel%
		EndSql
		lRet := (cAliasDC5)->(EoF())
		(cAliasDC5)->(dbCloseArea())
	Else
		// Valida se há tarefa WMS Padrão antes da conferencia de saida
		cAliasDC5 := GetNextAlias()
		BeginSql Alias cAliasDC5
			SELECT DC5.DC5_OPERAC
			FROM %Table:DC5% DC5
			WHERE DC5.DC5_FILIAL = %xFilial:DC5%
			AND DC5.DC5_SERVIC = %Exp:Self:GetServico()%
			AND DC5.DC5_ORDEM  < (  SELECT DC51.DC5_ORDEM
									FROM %Table:DC5% DC51
									WHERE DC51.DC5_FILIAL = %xFilial:DC5%
									AND DC51.DC5_SERVIC = %Exp:Self:GetServico()%
									AND DC51.DC5_OPERAC = '7'
									AND DC51.%NotDel%)
			AND DC5.DC5_OPERAC IN ('3','4')
			AND DC5.%NotDel%
		EndSql
		lRet := !(cAliasDC5)->(EoF())
		(cAliasDC5)->(dbCloseArea())
	EndIf
Return lRet
