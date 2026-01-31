#INCLUDE "TOTVS.CH"
#INCLUDE "WMSA580.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA580
Ajusta Kardex por endereço
@author Squad WMS
@since 21/11/2018
@version 1.0

@return return, Nil
/*/
//--------------------------------------------------------------
Function WMSA580()
Local oProcess  := MsNewProcess():New( { || Ajustar(oProcess) },STR0004 + "...", STR0006 + "...", .F. ) // Processamento // Aguarde...

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If SuperGetMv("MV_ULMES",.F.,"14990101")  >= dDataBase
		WmsMessage(STR0008) //O ajuste de saldo só pode ser realizado após a data do fechamento de estoque.
		Return
	EndIf
	
	If Pergunte("WMSA580")
		If MsgYesNo(STR0001,STR0002) // Este programa irá analisar/ajustar o estoque WMS! Confirma o processamento? // Análise de estoque por endereço WMS
			oProcess:Activate()
		EndIf
	EndIf
Return

Static Function Ajustar(oProcess)
Local lContinua  := .F.
Local aErro      := {}
Local oMovimento := Nil
Local cArmDe     := MV_PAR01
Local cArmAte    := MV_PAR02
Local cProdDe    := MV_PAR03
Local cProdAte   := MV_PAR04
Local cArmAnt    := ""
Local cWhere     := ""
Local cAliasQry  := Nil
Local cTimeIni   := Time()
Local cTimeFim   := Time()
Local nI         := 0
Local nAcao      := MV_PAR05
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
			If !((cAliasQry)->B2_LOCAL == cArmAnt)
				lContinua := .T.
				cArmAnt := (cAliasQry)->B2_LOCAL
				
				oMovimento:oMovEndOri:SetArmazem((cAliasQry)->B2_LOCAL) // Armazem
				oMovimento:oMovEndOri:SetEnder("INVENTARIO")            // Endereço
				If !oMovimento:oMovEndOri:ChkEndInv()
					AAdd(aErro,oMovimento:oMovEndOri:GetErro())
					lContinua := .F.
				EndIf
			EndIf
			If lContinua .And. IntWms((cAliasQry)->B2_COD)
				oMovimento:oEstEnder:EquateOver((cAliasQry)->B2_LOCAL,(cAliasQry)->B2_COD,oProcess,nAcao)
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		dDateFim := dDataBase
		cTimeFim := Time()
	EndIf
	(cAliasQry)->(dbCloseArea())
	// Avalia se há movimentações no endereço de INVENTARIO
	// para ajustar os saldos do produto
	If nAcao == 3
		cWhere := ""
		If !(cArmDe == cArmAte)
			cWhere += " AND SB2.B2_LOCAL >= '"+cArmDe+"'"
			cWhere += " AND SB2.B2_LOCAL <= '"+cArmAte+"'"
		Else
			cWhere += " AND SB2.B2_LOCAL = '"+cArmDe+"'"
		EndIf
		cWhere := "%"+cWhere+"%"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
		SELECT DISTINCT SB2.B2_LOCAL
		FROM %Table:SB2% SB2
		WHERE SB2.B2_FILIAL = %xFilial:SB2%
		AND SB2.%NotDel%
		%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			oMovimento := WMSDTCMovimentosServicoArmazem():New()
			Do While (cAliasQry)->(!Eof())
				If !oMovimento:oEstEnder:AjusEstPrd((cAliasQry)->B2_LOCAL,oProcess)
					AAdd(aErro,oMovimento:oEstEnder:GetErro())
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		(cAliasQry)->(dbCloseArea())
		dDateFim := dDataBase
		cTimeFim := Time()
	EndIf
	
	If !Empty(aErro)
		AAdd(oMovimento:oOrdServ:aWmsAviso,"-----------------------------------")
		AAdd(oMovimento:oOrdServ:aWmsAviso,STR0007) // Falhas no processamento
		AAdd(oMovimento:oOrdServ:aWmsAviso,"-----------------------------------")
		For nI := 1 To Len(aErro)
			AAdd(oMovimento:oOrdServ:aWmsAviso,aErro[nI])
		Next nI
		oMovimento:oOrdServ:ShowWarnig()
	EndIf
	
	WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",DToC(dDateIni)},{"[VAR02]",cTimeIni},{"[VAR03]",DToC(dDateFim)},{"[VAR04]",cTimeFim}})) // Processamento encerrado! (Inicio: [VAR01]-[VAR02] | Fim: [VAR03]-[VAR04])
Return Nil
