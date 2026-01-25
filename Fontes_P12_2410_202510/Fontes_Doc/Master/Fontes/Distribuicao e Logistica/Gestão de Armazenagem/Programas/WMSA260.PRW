#INCLUDE "WMSA260.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA26001 "WMSA26001"
#DEFINE WMSA26002 "WMSA26002"
#DEFINE WMSA26003 "WMSA26003"
#DEFINE WMSA26004 "WMSA26004"

Static oBrowse  := Nil
Static lMarkAll := .F. // Indicador de marca/desmarca todos

//-------------------------------------
/*/{Protheus.doc} WMSA260
Exclusao de uma faixa de enderecos no SBE.
@author Alex Egydio
@since 12/06/2001
@version 2.0
/*/
//-------------------------------------
Function WMSA260()

	If Pergunte("DLA260", .T.)
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription(STR0001) // Exclusão de Endereços
		oBrowse:SetMenuDef("WMSA260")
		oBrowse:SetAlias("SBE")
		oBrowse:SetFieldMark("BE_OK")
		oBrowse:SetAllMark({||AllMark()})
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:Activate()
	EndIf

Return Nil

//-----------------------------------
/*{Protheus.doc} MenuDef
Função MenuDef

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "WMA260Proc" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-----------------------------------
/*{Protheus.doc} MontaQuery
Monta a expressão para filtro dos dados

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function MontaQuery()
Local cQuery := ""

	cQuery :=     " BE_FILIAL   = '"+xFilial("SBE")+"'"
	cQuery += " AND BE_LOCAL   >= '"+MV_PAR01+"'"
	cQuery += " AND BE_LOCAL   <= '"+MV_PAR02+"'"
	cQuery += " AND BE_CODZON  >= '"+MV_PAR03+"'"
	cQuery += " AND BE_CODZON  <= '"+MV_PAR04+"'"
	cQuery += " AND BE_ESTFIS  >= '"+MV_PAR05+"'"
	cQuery += " AND BE_ESTFIS  <= '"+MV_PAR06+"'"
	cQuery += " AND BE_LOCALIZ >= '"+MV_PAR07+"'"
	cQuery += " AND BE_LOCALIZ <= '"+MV_PAR08+"'"

Return cQuery

//-----------------------------------
/*{Protheus.doc} AllMark
Marca ou desmarca todos os registros

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function AllMark()
Local aAreaSBE := SBE->(GetArea())
Local cSpace   := Space(TamSX3("BE_OK")[1])

	lMarkAll := !lMarkAll

	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	SBE->(DbGoTop())

	While !SBE->(Eof())
		RecLock("SBE",.F.)
		SBE->BE_OK := Iif(lMarkAll,cSpace,oBrowse:cMark)
		SBE->(MsUnLock())
		SBE->(DbSkip())
	EndDo

RestArea(aAreaSBE)
oBrowse:Refresh()
Return Nil

//-----------------------------------
/*{Protheus.doc} WMA260Proc
Inicia o processo de exclusão dos endereços

@author  Alex Egydio
@version P12
@Since   12/06/2001
*/
//-----------------------------------
Function WMA260Proc( cAlias, nReg, nOpcx )
	Processa({|lEnd| WMA260Manut(,,@lEnd)},STR0001,STR0003,.T.) // Excluindo Enderecos
Return NIL

//-----------------------------------
/*{Protheus.doc} WMA260Manut
Executa os tratamentos de rotina padrão e rotina automática

@author  Alex Egydio
@version P12
@Since   12/06/2001
*/
//-----------------------------------
Function WMA260Manut(aRotAuto,xCompat,lEnd)
Local aAreaSBE   := SBE->(GetArea())
Local aAreaAnt   := GetArea()
Local l260Auto   := .F.
Local l260Erro   := .F.
Local nX         := 0
Local nY         := 0
Local cQuery     := ""
Local cAliasQry  := ""
Local nRegs      := 0

Default aRotAuto := {}
Default lEnd     := .F.

	// Execucao via Rotina Automatica
	If Len(aRotAuto) > 0
		l260Auto := .T.
	EndIf

	If l260Auto
		// Valida o Array da Rotina Automatica
		For nX := 1 To Len(aRotAuto)
			If  !(Len(aRotAuto[nX])==4)
				l260Erro := .T.
				Exit
			EndIf
			For nY := 1 To 4
				If  !(ValType(aRotAuto[nX,nY])=='C').Or.Empty(aRotAuto[nX,nY])
					l260Erro := .T.
					Exit
				EndIf
			Next nY
		Next nX

		If l260Erro
			WmsMessage(STR0007,WMSA26002,,,,STR0008) // Um ou mais campos obrigatórios não foram preenchidos. // Preencha os campos cujos títulos possuem o símbolo '*' (asterisco).
			Return
		EndIf

		For nX := 1 To Len(aRotAuto)
			If !DeletEnder(aRotAuto[nX,1],aRotAuto[nX,2],aRotAuto[nX,3],aRotAuto[nX,4],l260Auto)
				Exit
			EndIf
		Next nX

	Else
		cQuery := "SELECT BE_LOCAL,"
		cQuery +=       " BE_LOCALIZ,"
		cQuery +=       " BE_ESTFIS"
		cQuery += " FROM "+RetSqlName("SBE")+" SBE"
		cQuery += " WHERE " + MontaQuery()
		cQuery +=   " AND SBE.BE_OK      = '"+oBrowse:cMark+"'"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())

			// Estabelece tamanho da régua de progressão
			(cAliasQry)->(DbEval({|| nRegs++ }))
			ProcRegua(nRegs)

			// Posiciona no início do cursor, por causa do DBEval
			(cAliasQry)->(DbGoTop())

			While !(cAliasQry)->(Eof())
				// Incremento da régua de progressão
				IncProc()

				// Tratamento do botão cancelar
				If lEnd
					Exit
				EndIf

				// Deleta o endereço
				If !DeletEnder(xFilial("SBE"),(cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,l260Auto)
					Exit
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo		
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If !l260Auto
		oBrowse:Refresh()
	EndIf

RestArea(aAreaSBE)
RestArea(aAreaAnt)
Return Nil

//-----------------------------------
/*{Protheus.doc} DeletEnder
Efetua validação de saldo e exclusão dos endereços

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function DeletEnder(cFilSBE,cArmazem,cEndereco,cEstFis,l260Auto)
Local aAreaSBF := SBF->(GetArea())
Local aAreaD14 := D14->(GetArea())
Local aAreaSDB := SDB->(GetArea())
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lSaldo   := .F.
Local lRet     := .T.
Local cQuery   	:= ""
Local cAliasQry	:= ""
Local dDataFec	:= MVUlmes()

Default cFilSBE := "" //--Incluido por compatibilidade para não alterar a estrutura da execução via execauto

		// Verifica se a saldo no endereco
		If lWmsNew
			D14->(DbSetOrder(4)) // D14_FILIAL+D14_LOCAL+D14_ESTFIS+D14_ENDER
			If D14->(DbSeek(xFilial("D14")+cArmazem+cEstFis+cEndereco))
				lSaldo := .T.
			EndIf
		Else
			SBF->(DbSetOrder(6)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_ESTFIS
			If SBF->(DbSeek(xFilial("SBF")+cArmazem+cEndereco+cEstFis)) .And. SBFSaldo(,,,,.T.) > 0
				lSaldo := .T.
			EndIf
		EndIf

		If lSaldo
			If !l260Auto
				nRet := WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco},{"[VAR03]",cEstFis}}),WMSA26001,10,,{STR0005,STR0006}) // Existe saldo em estoque no armazém/endereço/estrutura [VAR01]/[VAR02]/[VAR03]. Este endereço não será excluído. // Continuar // Cancelar
				If nRet == 2 // Cancelar
					Return .F.
				EndIf
				lRet := .F.
			Else
				WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco},{"[VAR03]",cEstFis}}),WMSA26001,5,.T.) // Existe saldo em estoque no armazém/endereço/estrutura [VAR01]/[VAR02]/[VAR03]. Este endereço não será excluído. // Continuar // Cancelar		
				lRet := .F.
			EndIf
		EndIf

		If lRet
			SBE->( DbSetOrder(1) )	// BE_FILIAL + BE_LOCAL + BE_LOCALIZ + BE_ESTFIS
			If lRet := SBE->( DbSeek(xFilial("SBE")+cArmazem+cEndereco+cEstFis) )
				// Regra adicionada conforme validação antes de excluir - MATA015 - A015AVldA()
				If SBE->BE_STATUS $ "2|3|4|5|6"
					WmsMessage(STR0013,STR0014,5,.T.,,)//"Não é possível excluir este endereço porque o status atual está diferente de 'desocupado'" "Status inválido"
					lRet := .F.
				EndIf

				// Verifica se existe movimento com o endereco apos o fechamento e nao deixa excluir.
				// Regra adicionada conforme validação da função MA015CkSDB() - MATA015
				If lRet .And. (!lWmsNew .Or. (Empty(SBE->BE_CODZON) .And. Empty(SBE->BE_ESTFIS)))
					
					cQuery += "SELECT 1 "		
					cQuery += "FROM " + RetSqlName( "SDB" ) + " SDB "
					cQuery += "WHERE "
					cQuery += "DB_FILIAL ='" + xFilial( "SDB" ) + "' AND "
					cQuery += "DB_DATA > '" + DTOS(dDataFec) + "' AND "
					cQuery += "DB_LOCAL = '" + SBE->BE_LOCAL + "' AND "
					cQuery += "DB_LOCALIZ = '" + SBE->BE_LOCALIZ + "' AND "
					cQuery += "DB_ESTORNO = ' ' AND "
					cQuery += "SDB.D_E_L_E_T_=' ' "

					cQuery := ChangeQuery( cQuery )
					cAliasQry := GetNextAlias()
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )

					If (cAliasQry)->(!Eof())
						Help(" ",1,"WMSA260",,STR0015,1,0) //"Este endereço não pode ser excluído porque possui movimentações com data posterior ao último fechamento."
						lRet := .F.
					Endif

					(cAliasQry)->(dbCloseArea())
				EndIf

				If !(Empty(SBE->BE_CODZON) .And. Empty(SBE->BE_ESTFIS))
					// Avalia os movimentos de distribuição WMS
					cQuery := "SELECT 1 "
					cQuery +=  " FROM "+RetSqlName("D12")+" D12"
					cQuery += " WHERE D12.D12_FILIAL   = '"+xFilial("D12")+"'"
					cQuery +=   " AND ((D12.D12_LOCORI = '"+SBE->BE_LOCAL+"' AND D12_ENDORI = '"+SBE->BE_LOCALIZ+"') OR "
					cQuery +=         "(D12.D12_LOCDES = '"+SBE->BE_LOCAL+"' AND D12_ENDDES = '"+SBE->BE_LOCALIZ+"'))"
					cQuery +=   " AND D12.D12_STATUS  IN ('-','3','2','4')"
					cQuery +=   " AND D12.D_E_L_E_T_   = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )
					If !(cAliasQry)->(Eof())
						WmsMessage(STR0009,WMSA26003,5,.T.,,STR0010) //"Este endereço não pode ser excluído, pois possui movimentações WMS pendentes." // "Estorne os movimentos WMS e realize uma nova tentativa."
						lRet := .F.
					EndIf
					(cAliasQry)->(dbCloseArea())
					// Avalia as movimentações de estoque WMS
					If lRet
						cQuery := "SELECT 1"
						cQuery +=  " FROM "+RetSqlName("D13")+" D13"
						cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
						cQuery +=   " AND D13.D13_LOCAL  = '"+SBE->BE_LOCAL+"'"
						cQuery +=   " AND D13.D13_ENDER  = '"+SBE->BE_LOCALIZ+"'"
						cQuery +=   " AND D13.D13_DTESTO > '"+DtoS(dDataFec)+"'"
						cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery( cQuery )
						cAliasQry := GetNextAlias()
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )
						If !(cAliasQry)->(Eof())							
							WmsMessage(STR0011,WMSA26004,5,.T.,,STR0012) //"Este endereço não pode ser excluído, pois possui movimentações de estoque posteriores ao último fechamento." // "Realize uma nova tentativa depois do próximo fechamento de estoque."
							lRet := .F.
						EndIf
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
			EndIf
		EndIf

		// Exclui os Enderecos Selecionados
		If lRet
			RecLock("SBE",.F.)
			SBE->(DbDelete())
			SBE->(MsUnLock())
		EndIf

RestArea(aAreaSBF)
RestArea(aAreaD14)
RestArea(aAreaSDB)
Return lRet
