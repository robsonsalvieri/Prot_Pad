#INCLUDE "TOTVS.CH"
#INCLUDE "WMSA585.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA585
Ajusta Kardex por endereço
@author Squad WMS
@since 21/11/2018
@version 1.0

@return return, Nil
/*/
//--------------------------------------------------------------
Function WMSA585()
Local oProcess  := MsNewProcess():New( { || Ajustar(oProcess) },STR0004 + "...", STR0005 + "...", .F. ) // Processamento // Aguarde...

	if cPaisLoc <> "BRA"
		Help(,,'HELP',,STR0010,1,0,) //"O programa está disponível somente para o Brasil."
		Return .F.
	endif

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	 
	If Pergunte("WMSA585")
		If MsgYesNo(STR0001 +; //Este programa ajustará as quantidades previstas, bloqueios e empenhos no saldo por endereço WMS (D14) com base em movimentações WMS pendentes no sistema. 
		 STR0007+ CRLF +; //Esta rotina deve ser utilizada somente após identificada a causa do problema e não deve ser incorporada como uma prática padrão. 
		 STR0008+ CRLF +; //Uma vez executada não será possível reverter o processo. 
		 STR0009,STR0002) // Deseja continuar? //Ajuste quantidade prevista no saldo por endereço WMS
			oProcess:Activate()
		EndIf
	EndIf
Return

Static Function Ajustar(oProcess)
Local aErro      := {}
Local oMovimento := Nil
Local cArmDe     := MV_PAR01
Local cArmAte    := MV_PAR02
Local cProdDe    := MV_PAR03
Local cProdAte   := MV_PAR04
Local cAliasQry  := Nil
Local cWhere     := ""
Local cTimeIni   := Time()
Local cTimeFim   := Time()
Local nI         := 0
Local dDateIni   := dDataBase
Local dDateFim   := dDataBase

	If !(cArmDe == cArmAte)
		cWhere += " AND SB2.B2_LOCAL >= '"+cArmDe+"'"
		cWhere += " AND SB2.B2_LOCAL <= '"+cArmAte+"'"
	Else
		cWhere += " AND SB2.B2_LOCAL = '"+cArmDe+"'"
	EndIf
	If !(cProdDe == cProdAte)
		cWhere += " AND SB2.B2_COD >= '"+cProdDe+"'"
		cWhere += " AND SB2.B2_COD <= '"+cProdAte+"'"
	Else
		cWhere += " AND SB2.B2_COD = '"+cProdDe+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SB2.B2_LOCAL,
				SB2.B2_COD
		FROM %Table:SB2% SB2
		WHERE SB2.B2_FILIAL = %xFilial:SB2%
		AND SB2.%NotDel%
		%Exp:cWhere%
		ORDER BY SB2.B2_LOCAL,
					SB2.B2_COD
	EndSql
	If (cAliasQry)->(!Eof())
		oMovimento := WMSDTCMovimentosServicoArmazem():New()
		Do While (cAliasQry)->(!Eof())
			If IntWms((cAliasQry)->B2_COD)
				oMovimento:oEstEnder:EquatePrev((cAliasQry)->B2_LOCAL,(cAliasQry)->B2_COD,oProcess,@aErro)
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		dDateFim := dDataBase
		cTimeFim := Time()
		If !Empty(aErro)
			AAdd(oMovimento:oOrdServ:aWmsAviso,"----------     -------------------------")
			AAdd(oMovimento:oOrdServ:aWmsAviso,STR0006) // Alerta/Falhas no processamento
			AAdd(oMovimento:oOrdServ:aWmsAviso,"---------------     --------------------")
			For nI := 1 To Len(aErro)
				AAdd(oMovimento:oOrdServ:aWmsAviso,aErro[nI])
			Next nI
			oMovimento:oOrdServ:ShowWarnig()
		EndIf
		oMovimento:Destroy()
	EndIf
	WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",DToC(dDateIni)},{"[VAR02]",cTimeIni},{"[VAR03]",DToC(dDateFim)},{"[VAR04]",cTimeFim}})) // Processamento encerrado! (Inicio: [VAR01]-[VAR02] | Fim: [VAR03]-[VAR04])
Return Nil
