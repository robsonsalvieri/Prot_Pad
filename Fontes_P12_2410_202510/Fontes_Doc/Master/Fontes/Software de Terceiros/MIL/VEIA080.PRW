#include "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA080.CH"

Static oTabTmp := NIL
Static oDMSBrwStru
Static oBrwVA080

Static lUsaVRK := .F.

/*/{Protheus.doc} VEIA080
Função para cancelament o de Nota Fiscal de Atendimento de Veículos
@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Function VEIA080()

	Local lIntLoja  := Iif(cPaisLoc == "BRA", Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S", .F.)

	if lIntLoja
		FMX_HELP("VA080ERR2",STR0009,STR0010) // "Esta rotina não é compatível em ambientes onde o módulo de Veículos está integrado ao módulo de Loja."
		return
	endif

	if VA0800073_OpcaoCancelamento(.t.) == 0
		Return
	endif

	If ! Pergunte("VEIA080",.t.)
		Return
	EndIf

	lUsaVRK := FM_SQL("SELECT COUNT(*) FROM " + RetSQLName("VRK") + " WHERE VRK_FILIAL = '" + xFilial("VRK") + "' AND D_E_L_E_T_ = ' '") > 0

	VA0800063_ConfigBrowse(@oDMSBrwStru)

	oBrwVA080 := FWMarkBrowse():New()
	oDMSBrwStru:SetBrwOwner(oBrwVA080)

	oBrwVA080:SetTemporary(.T.)
	oBrwVA080:SetUseFilter(.f.)
	oBrwVA080:SetDescription(STR0001) // "Cancelamento de Nota Fiscal de Atendimento"
	oBrwVA080:SetParam({ || VA0800033_Param() })

	oBrwVA080:SetIgnoreARotina(.T.)
	oBrwVA080:SetFieldMark("TMP_OK")
	oBrwVA080:SetMark( "X", oDMSBrwStru:GetAlias(), "TMP_OK" )

	oBrwVA080:SetWalkThru(.F.)
	oBrwVA080:SetAmbiente(.F.)

	oDMSBrwStru:AddBrwColumn()

	oBrwVA080:SetAlias(oDMSBrwStru:GetAlias())
	oBrwVA080:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwVA080:Activate()

	oDMSBrwStru:DelTrabTmp()

Return
/*/{Protheus.doc} VA0800063_ConfigBrowse
Cria a estrutura de browse para a rotina de cancelamento de nota fiscal de atendimento de veiculos
@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Function VA0800063_ConfigBrowse(oDMSBrwStru)

	oDMSBrwStru := OFBrowseStruct():New({"SA1", "VRK", "VV9", "VV0", "VVA"})

	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'TMP_OK' },;
											{ 'cTitulo' , ' '  },;
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , 1 },;
											{ 'nDecimal' , 0 } } ) , .f. )


	if lUsaVRK
		oDMSBrwStru:AddField("VRK_PEDIDO")
	endif
	oDMSBrwStru:AddField("VV9_NUMATE")
	oDMSBrwStru:AddField("VVA_ITETRA")
	oDMSBrwStru:AddField("VV0_CODCLI")
	oDMSBrwStru:AddField("VV0_LOJA")
	oDMSBrwStru:AddField("VV0_NUMNFI")
	oDMSBrwStru:AddField("VV0_SERNFI")
	oDMSBrwStru:AddField("VV0_DATMOV")
	oDMSBrwStru:AddField("VVA_CHASSI")

	if lUsaVRK
		oDMSBrwStru:AddIndex( "VRK_PEDIDO+VV9_NUMATE" )
	endif
	oDMSBrwStru:AddIndex( "VV9_NUMATE" )

	if lUsaVRK
		oDMSBrwStru:AddSeek({"VRK_PEDIDO", "VV9_NUMATE"})
	endif
	oDMSBrwStru:AddSeek({"VV9_NUMATE"})

	oDMSBrwStru:CriaTabTmp()

	oDMSBrwStru:LoadData( VA0800013_Query() )

Return

/*/{Protheus.doc} VA0800013_Query
Monta a query para o browse de cancelamento de nota fiscal de atendimento de veiculos
@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Static Function VA0800013_Query()

	Local cQuery := ""
	cQuery := ""
	cQuery += " SELECT ' ' AS TMP_OK, " 
	if lUsaVRK
		cQuery += " VRK_PEDIDO , "
	endif
	cQuery += "VV9_NUMATE , VVA_ITETRA, VV0_CODCLI, VV0_LOJA , VV0_NUMNFI, VV0_SERNFI, VV0_DATMOV , VVA_CHASSI "
	cQuery += " FROM " + RetSQLName("VV9") + " VV9"
	cQuery += " JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = '" + xFilial("VV0") + "' AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.D_E_L_E_T_ = ' '"
	cQuery += " JOIN " + RetSQLName("VVA") + " VVA ON VVA.VVA_FILIAL = '" + xFilial("VVA") + "' AND VVA.VVA_NUMTRA = VV9.VV9_NUMATE AND VVA.D_E_L_E_T_ = ' '"
	if lUsaVRK
		cQuery += " LEFT JOIN " + RetSQLName("VRK") + " VRK ON VRK.VRK_FILIAL = '" + xFilial("VRK") + "' AND VRK.VRK_NUMTRA = VVA.VVA_NUMTRA AND VRK.VRK_ITETRA = VVA.VVA_ITETRA AND VRK.D_E_L_E_T_ = ' '"
	endif
	cQuery += " WHERE VV9.VV9_FILIAL = '" + xFilial("VV9") + "'"
	cQuery += " AND VV9.D_E_L_E_T_ = ' '"
	cQuery += " AND VV9.VV9_STATUS = 'F' "
	if ! empty( MV_PAR01 ) .OR. ! empty(MV_PAR02)
		cQuery += " AND VV0_DATMOV BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"
	endif
	if ! empty(MV_PAR03)
		cQuery += " AND VV0_SERNFI = '" + MV_PAR03 + "'"
	endif
	if ! empty( MV_PAR04 ) .OR. ! empty(MV_PAR05)
		cQuery += " AND VV0_NUMNFI BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'"
	endif
	if ! empty( MV_PAR06 ) .OR. ! empty(MV_PAR07)
		cQuery += " AND VV9_NUMATE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
	endif
	if lUsaVRK .and. (! empty( MV_PAR08 ) .OR. ! empty(MV_PAR09))
		cQuery += " AND VRK_PEDIDO BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "'"
	endif
	cQuery := ChangeQuery(cQuery)

	
	
	

Return cQuery


/*/{Protheus.doc} VA0800023_Cancelar
Processa Cancelamento de Nota Fiscal de Atendimento de Veiculos

@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Function VA0800023_Cancelar()

	Local cQuery := ""
	local nQtdNotas := 0
	Local aAtendCanc := {}
	local nOpcCanc

	cQuery := "SELECT COUNT(*) FROM " + oDMSBrwStru:getRealName() + " WHERE TMP_OK = 'X'"
	nQtdNotas := fm_sql(cQuery)
	if nQtdNotas == 0
		Return .f.
	endif

	nOpcCanc := VA0800073_OpcaoCancelamento(.f.)
	if nOpcCanc == 0
		Return .f.
	endif

	aMotCancel := OFA210MOT("000001","1",,,.F.) // Filtro da consulta do motivo de Cancelamentos ( 000001 = Atendimento de Veiculos )
	If len(aMotCancel) <= 0
		Return .f.
	EndIf

	aAtendCanc := VA0800043_SelecionaAtendimentos()

	Processa( { || VA0800053_ProcCancelamento(aAtendCanc, nOpcCanc) } , STR0001)

	Pergunte('VEIA080',.f.)
	oDMSBrwStru:LoadData( VA0800013_Query() , .t. )
	oBrwVA080:Refresh(.T.)

Return

/*/{Protheus.doc} VA0800073_OpcaoCancelamento
Retorna a opção de cancelamento para o atendimento de veiculos
@type function
@author Rubens Takahashi
@since 4/3/2025
@param lValida, logical, Indica se é validação ou não
/*/
static function VA0800073_OpcaoCancelamento(lValida)

	Local cCancVAI := "000000" // Permissao: ( 0=Nao faz nada / 1=Volta / 2=Cancela/Volta / 3=Cancela)
	local nOpcCanc := 0

	cCancVAI := FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_CANVEI","?")
	cOptVAICanc := substr(cCancVAI,6,1)

	if ! cOptVAICanc $ "123"
		FMX_HELP("VA080ERR1",STR0011, STR0012) // "Usuário sem permissão para cancelar atendimento","Verifique a permissão de cancelamento no cadastro de equipe técnica.")
		return 0
	endif

	if lValida
		return 1
	endif

	Do Case
	// VAI - Permite somente Cancelar
	Case cOptVAICanc == "3"
		nOpcCanc   := 2   // Cancelar

	// VAI - Permite Cancelar/Voltar
	Case cOptVAICanc == "2"
		nOpcCanc := Aviso(STR0004,"- "+STR0005+CHR(13)+CHR(10)+"- "+STR0006, { STR0007 , STR0008 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aprovado / Cancelar Total o Atendimento / Voltar / Cancelar

	// VAI - Permite Voltar
	Case cOptVAICanc == "1"
		nOpcCanc   := 1   // Voltar para Aprovado

	EndCase

return nOpcCanc

/*/{Protheus.doc} VA0800053_ProcCancelamento

Executa rotina de cancelamento de Atendimento

@type function
@author Rubens Takahashi
@since 4/3/2025
@param aAtendCanc, array, Relacao de atendimento
@param nOpcCanc, numeric, Opcao para cancelamento ( 1=Volta / 2=Cancela/Volta / 3=Cancela)
/*/
static Function VA0800053_ProcCancelamento(aAtendCanc, nOpcCanc)

	local nPos
	local lErroCanc

	ProcRegua(len(aAtendCanc))

	for nPos := 1 to len(aAtendCanc)

		IncProc(aAtendCanc[nPos])

		lErroCanc := .f.
		
		aAutoVV9 := {}
		aAutoCab := {} // Campos Cabecalho
		aAutoItens:= {} // Campos Itens

		dbSelectArea("VV9")
		dbSetOrder(1)
		VV9->(dbSeek(xFilial("VV9") + aAtendCanc[nPos]))
		SoftLock("VV9")
		
		if ! VA0800083_AtendimentoFinalizado(aAtendCanc[nPos])
			FMX_HELP("VA080ERR3",STR0013 + CHR(13) + CHR(10) + AllTrim(RetTitle("VV9_NUMATE")) + ": " + aAtendCanc[nPos],STR0014) // "Atendimento não está finalizado." "Selecione um atenidmento finalizado para cancelamento da nota fiscal."
			loop
		endif

		aAdd(aAutoVV9, { "VV9_NUMATE" , aAtendCanc[nPos] , NIL } )

		begin transaction
		SetFunName("VEIXA018")
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z,w,u,v| VEIXX002(x,y,,z,,w,u,v)}, aAutoCab, aAutoItens, 5, aAutoVV9,nOpcCanc,aMotCancel)
		if lMsErroAuto
			lErroCanc := .t.
			DisarmTransaction()
			break
		Endif
		End Transaction

		if lErroCanc
			MostraErro()
		endif

	next nPos

	MsUnlockAll()

Return

Function VA0800083_AtendimentoFinalizado(cNumAte)
	local cAlias := "TMPVV9"
	local lRetorno := .f.

	beginSql alias cAlias
		SELECT VV9_STATUS
		FROM %table:VV9% VV9
		WHERE VV9_FILIAL = %xFilial:VV9%
		 AND  VV9_NUMATE = %exp:cNumAte%
		 AND  VV9.%notdel%
	endSql

	if (cAlias)->VV9_STATUS == "F"
		lRetorno := .t.
	endif
	(cAlias)->( dbCloseArea() )
	dbSelectArea("VV9")

Return lRetorno
	

/*/{Protheus.doc} VA0800043_SelecionaAtendimentos
Retorna array com os atendimentos que foram selecionados para cancelamento

@type function
@author Rubens Takahashi
@since 4/3/2025

/*/
Function VA0800043_SelecionaAtendimentos()
	local cAlias := "TMPATEND"
	local cTblName := '%' + oDMSBrwStru:getRealName() + '%'
	local aRetAtend := {}

	beginSql alias cAlias
		SELECT DISTINCT VV9_NUMATE
		FROM %Exp:cTblName%
		WHERE TMP_OK = 'X'
	endSql

	while ! (cAlias)->( eof() )
		aAdd(aRetAtend, (cAlias)->VV9_NUMATE )
		(cAlias)->( dbSkip() )
	enddo
	(cAlias)->( dbCloseArea() )
	dbselectarea(oDMSBrwStru:GetAlias())
	
return aRetAtend

/*/{Protheus.doc} VA0800033_Param
Exibe pergunta de prametros da mBrowse de cancelamento de nota fiscal de atendimento de veiculos 
@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Function VA0800033_Param()

	Local lRet := .T.

	If (lRet := Pergunte('VEIA080',.T.))
		oDMSBrwStru:LoadData( VA0800013_Query() , .t. )
		oBrwVA080:Refresh(.T.)
	EndIf

Return lRet

/*/{Protheus.doc} MenuDef
Menu Def do mBrowse
@type function
@author Rubens Takahashi
@since 4/3/2025
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'VA0800033_Param'    OPERATION 3 ACCESS 0 // "Atualizar Browse"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VA0800023_Cancelar' OPERATION 4 ACCESS 0 // "Cancelar Nota Fiscal"
Return aRotina