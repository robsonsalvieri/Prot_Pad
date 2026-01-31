#include 'totvs.ch'
#include 'FWMVCDEF.CH'

#DEFINE QDR_BALANC	"1"	 // "Balancete Trimestral"
#DEFINE QDR_CADAST	"2"	 // "Dados Cadatrais
#DEFINE QDR_AGIMOB	"3"	 // "Ativos Garantidores - Imobiliario"
#DEFINE QDR_FLUXCA	"4"	 // "Fluxo de Caixa Trimestral"
#DEFINE QDR_IDASPA	"5"	 // "Idade de Saldos - Contas a Pagar"
#DEFINE QDR_LUCPRE	"6"	 // "Lucros e Prejuízos"
#DEFINE QDR_CONEST	"7"	 // "Contratos Estipulados"
#DEFINE QDR_CONREP	"8"	 // "Segregação do Montante de Contraprestações a Repassar"
#DEFINE QDR_COBASS	"9"	 // "Cobertura Assistencial"
#DEFINE QDR_EVEIND	"11" // "Movimentação de Eventos Indenizáveis"
#DEFINE QDR_AGRCON	"12" // "Agrupamento de Contratos"
#DEFINE QDR_PESL	"13" // "Saldo da Provisão de Eventos Sinistros a Liquidar"
#DEFINE QDR_CCCOOP	"14" // "Conta-Corrente Cooperado"
#DEFINE QDR_CTRPAS	"15" // "Conta Tributo Passivo"
#DEFINE QDR_IDASRE	"16" // "Idade de Saldos - Contas a Receber"
#DEFINE QDR_EVECOR	"18" // "Eventos em Corresponsabilidade (2018)"
#DEFINE QDR_FUNCOM	"19" // "Programas-Fundos Comuns de Despesas Assistenciais (2018)"
#DEFINE QDR_EVCCC	"20" // "Eventos de Contraprestação de Corresponsabilidade Cedida
#DEFINE QDR_MPC		"21" // "Modelo Padrão de Capital"
#DEFINE QDR_TAP		"22" // "Teste de Adequação do Passivo - TAP"
#DEFINE QDR_CONPEC  "23" // "Contraprestação Pecuniária"
#DEFINE	QDR_CRDEOP  "24" // CBR - Risco de Crédito - Parcela 1
#DEFINE QDR_DEFUIN  "25" // CBR - Risco de Crédito - Parcela 2
#DEFINE QDR_INADIM  "26" // Inadimplência
#DEFINE QDR_CBRIS   "27" //Capital Baseado em Riscos - Risco de Mercado - ALM
#DEFINE PDTE_VALID	"1" // Pendente Validação

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} preValidaDIOPS

Funcao que faz a Pré validacao de um registro do quadro do DIOPS e limpa o objeto da memoria

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function preValidaDIOPS( oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno, cFTrim, cFStat )
	Local cTab := ""

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cTab:=Substr(cFCodOpe,1,3)
		lOk:= PLOBCORCRI(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,cTab,AllTrim(Str(&(cTab+"->(Recno())"))) ,,,.T.)
	Else
		lOk := execPreValDIOPs( oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno, cFTrim, cFStat )
		delClassIntF()
	EndIf

return lOk

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execPreValDIOPs

Funcao que faz a Pré validacao de um registro do quadro do DIOPS

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function execPreValDIOPs( oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno, cFTrim, cFStat )
	local lOk	      := .T.

	if ( empty( oModel:getValue( cFStruct, cFObri ) ) )
		lOk := .F.
		Help( ,, 'HELP',,  "Codigo da obrigação não informado", 1, 0)
	else//cFObri
		if ( empty( oModel:getValue( cFStruct, cFComp ) ) )
			lOk := .F.
			Help( ,, 'HELP',,  "Codigo do Compromisso não informado", 1, 0)
		else//cFComp
			if ( empty( oModel:getValue( cFStruct, cFAno ) ) )
				lOk := .F.
				Help( ,, 'HELP',,  "Ano do Compromisso não informado", 1, 0)
			else//cFAno
				if B3A->B3A_TIPO=='3' .and. B3A->B3A_SZNLDD=='3' .and. ( empty( oModel:getValue( cFStruct, cFTrim ) ) )
					lOk := .F.
					Help( ,, 'HELP',,  "Trimestre do Compromisso não informado", 1, 0)
				else
							
					//atribui o codigo da obrigacao e do compromisso ao model
					If lOk
						lOk := setChvModel(oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno, cFTrim, cFStat )
					EndIf
					//Verifica se pode importar quadro para este compromissmo
					If lOk
						lOk := CompPermImp(oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno )
					EndIf
					//Verifica se a chave primaria do quadro nao vai ser quebrada na inclusão
					If lOk // .and. oModel:GetOperation() # MODEL_OPERATION_UPDATE
						lOk := ChaveQuadro(oModel, cFStruct, cFCodOpe)
					EndIf
					
				endif//cTrim
			endif//cFAno
		endif//cFComp
	endif//cFObri

return lOk

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} valContQdrDIOPS

Funcao criada para validar se conta existe no Plano de Contas da ANS

@return lRetorno	.F. conta não encontrada ou .T. conta encontrada

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function valContQdrDIOPS( cAnoCmp, cCodComp, cConta )

	Local lRet 	:= .T.
	Local cSql 	:= ""
	Local cAliTrb	:= GetNextAlias()
	Local aPerIni := {}
	Local aPerFim := {}

	aAdd(aPerIni,{"01","04","07","10"})
	aAdd(aPerFim,{"03","06","09","12"})

	cDataFim := cAnoCmp + aPerFim[1,val(cCodComp)] + "99"
	cDataIni := cAnoCmp + aPerIni[1,val(cCodComp)] + "01"

	cSql := " SELECT B8B_CONTA FROM " + RetSqlName("B8B")
	cSql += " WHERE B8B_FILIAL = '" + xFilial("B8B") + "' "
	cSql += " AND B8B_CONTA = '" + subStr(cConta,1,9) + "' "
	cSql += " AND B8B_VIGINI <= '" + cDataFim + "' "
	cSql += " AND (B8B_VIGFIN >= '" + cDataIni + "' or B8B_VIGFIN='') "
	cSql += " AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

	lRet := !(cAliTrb)->(Eof())

	(cAliTrb)->(dbCloseArea())

return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} delRegDIOPS

Funcao criada para deletar um registro do quadro no momento de um novo commit do model

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function delRegDIOPS( cAlias, cWhrQuadro, cWhrCritica  )

	local cQryQuadro			:= ""
	local cQryCritica			:= ""
	default cWhrQuadro		:= ""
	default cWhrCritica		:= ""

	If !Empty(cWhrQuadro)
		cQryQuadro := "DELETE FROM " + RetSqlname( allTrim(cAlias) ) + " WHERE " + allTrim( cWhrQuadro )
		TCSQLEXEC(cQryQuadro)
	EndIf

	If !Empty(cWhrCritica)
		cQryCritica := "DELETE FROM " + RetSqlname( "B3F" ) + " WHERE " + allTrim( cWhrCritica )
		TCSQLEXEC(cQryCritica)
	EndIf

return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetWhrQuadro

Funcao criada para montar o where para limpeza da tabela do quadro

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetWhrQuadro(cTable,cCodOpe,cCodObr,cAnoCmp,cCdComp,cRecno)

	Local cWhrQuadro	:= ""
	default cTable := ""
	default cRecno := ""

	If !Empty(cTable)

		cWhrQuadro	:= cTable +"_FILIAL='" + xFilial(cTable) + "' AND "+ cTable +"_CODOPE='"+cCodOpe+"' AND "+ cTable +"_CODOBR='"+cCodObr+"' AND "+ cTable +"_ANOCMP='"+cAnoCmp+"' AND "+ cTable +"_CDCOMP='"+cCdComp+"' "

		if ( !empty(cRecno) )
			cWhrQuadro := cWhrQuadro + "AND R_E_C_N_O_<>" + cRecno+" "
		endif

	EndIf

Return cWhrQuadro

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetWhrCritica

Funcao criada para montar o where para limpeza da tabela de criticas

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetWhrCritica(cFStruct,cCodOpe,cCodObr,cAnoCmp,cCdComp,cTable)

	Local cWhrCritica		:= ""
	default cTable		:= ""

	If !Empty(cTable)

		//X2_UNICO B3F B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI
		cWhrCritica := " B3F_FILIAL='"+xFilial("B3F")+"' AND B3F_CODOPE='"+cCodOpe+"' AND B3F_CDOBRI='"+cCodObr+"' AND B3F_ANO='"+cAnoCmp+"' AND B3F_CDCOMP='"+cCdComp+"' AND B3F_ORICRI='"+cTable+"' "

	EndIf

Return cWhrCritica

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetChvModel

Funcao criada para atualizar os campos de obrigacao e compromisso do model

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function SetChvModel(oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno, cFTrim, cFStat )
	Local cCodOpe	:= ""
	Local cCodObr := ""
	Local cCodCmp	:= ""
	Local lRet		:= .T.

	cCodOpe := oModel:GetValue(cFStruct,cFCodOpe)
	cCodObr := iif(B3A->B3A_SZNLDD=='5', oModel:GetValue(cFStruct,cFObri), PLSEXIOBR(cCodOpe) )
	cRefere := oModel:GetValue(cFStruct,cFTrim)
	cRefere := AllTrim(Str(Val(cRefere)))
	cAnoCmp := oModel:GetValue(cFStruct,cFAno)

	If !Empty(cCodObr)

		iif( B3A->B3A_SZNLDD<>'5', oModel:SetValue( cFStruct, cFObri, cCodObr), nil )

		If !cFStruct $ 'BUPMASTER'
			oModel:SetValue( cFStruct, cFStat, '1')
		Else
			oModel:SetValue( cFStruct, cFStat, '2')
		EndIf

		cCodCmp := iif( B3A->B3A_SZNLDD<>'5', oModel:GetValue( cFStruct, cFComp), PLSEXICOM( cCodOpe, cCodObr, cRefere, cAnoCmp ) )
		cRefere := PADL(cRefere,2,'0')
		oModel:SetValue( cFStruct, cFTrim, cRefere )

		If !Empty(cCodCmp)
			oModel:SetValue( cFStruct, cFComp, cCodCmp)
		Else
			lRet := .F.
			Help( ,, 'HELP',,  "Não existe Compromisso cadastrado.", 1, 0)
		EndIf

	Else
		lRet := .F.
		Help( ,, 'HELP',,  "Não existe obrigação cadastrada.", 1, 0)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} existeBalancete

Verifica se balancete existe para aquela operadora e compromisso

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
static function existeBalancete(cCodOpe,cCodObr,cAnoCmp,cCdComp)

	Local cSql	:= ""
	Local lRet	:= .F.
	Local cAliasN := getNextAlias()

	cSql := "SELECT B8A_CONTA FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='" + xFilial("B8A") + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" +cCodObr+ "' AND B8A_ANOCMP='" +cAnoCmp+ "' "
	cSql += "AND B8A_CDCOMP='" +cCdComp+ "' AND D_E_L_E_T_ = ''"
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	lRet := !(cAliasN)->(Eof())

return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSEXIOBR

Funcao criada para verificar se existe uma obrigacao cadastrada

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSEXIOBR( cCodOpe )

	Local cRetorno		:= ""
	Local cSql			:= ""
	local cAliasN		:= getNextAlias()
	Default cCodOpe	:= ""

	cSql := "SELECT B3A_CODIGO FROM " + RetSqlName("B3A") + " WHERE B3A_FILIAL = '" + xFilial("B3A") + "' AND B3A_CODOPE = '" + cCodOpe
	cSQL += "' AND B3A_TIPO = '3'  AND B3A_ATIVO = '1' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	If !(cAliasN)->(Eof())
		cRetorno := (cAliasN)->B3A_CODIGO
	EndIf

	(cAliasN)->(dbCloseArea())

Return cRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSEXICOM

Funcao criada para verificar e retornar se existe um compromisso cadastrado

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSEXICOM( cCodOpe, cCodObr, cRefere, cAno )

	Local cRetorno		:= ""
	Local cAliasN		:= getNextAlias()
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cRefere	:= ""
	Default cAno		:= ""

	//Na B3D-Compromisso o campo B3D_REFERE e gravado no formato 3º Tri/17, por isso o ajuste abaixo
	If !Empty(cRefere)
		cRefere := AllTrim(Str(Val(cRefere)))
	EndIf

	cSql := "SELECT B3D_CODIGO FROM " + RetSqlName("B3D") + " WHERE B3D_FILIAL = '" + xFilial("B3D") + "' AND B3D_CODOPE = '"
	cSql += cCodOpe + "' AND B3D_CDOBRI = '" + cCodObr + "' AND B3D_REFERE LIKE '"+cRefere+"%' AND B3D_ANO = '" + cAno
	cSql += "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	If !(cAliasN)->(Eof())
		cRetorno := (cAliasN)->B3D_CODIGO
	EndIf

	(cAliasN)->(dbCloseArea())

Return cRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} quadroFimEnvDiops

Atualiza quadro do compromisso do DIOPS para marcar que foi enviado e para processar a validação

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
	local cComp		:= ""
	local cCodObr	:= ""
	local lReturn := .F.

	cCodObr := PLSEXIOBR( cCodOpe )

	cComp := PLSEXICOM( cCodOpe, cCodObr , cRefere, cAno )

	B8X->(dbSetOrder(1))
	//"B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO
	If ( B8X->(MsSeek( xFilial( "B8X" )+cCodOpe+cCodObr+cAno+cComp+cQuadro )) )

		If ( cQuadro == QDR_BALANC )

			recLock( "B8X", .F. )
			B8X->B8X_RECEBI := "1"
			B8X->B8X_VALIDA := "1"
			B8X->(msUnLock())

			lReturn := .T.

			While !B8X->(EoF()) .and. ( B8X->B8X_FILIAL+B8X->B8X_CODOPE+B8X->B8X_ANOCMP+B8X->B8X_CDCOMP == xFilial( "B8X" )+cCodOpe+cAno+cComp )

				if ( B8X->B8X_RECEBI == "1" )

					recLock( "B8X", .F. )
					B8X->B8X_VALIDA := "1"
					B8X->(msUnLock())

				endif

				B8X->(dbSkip())

			End

		Else

			RecLock( "B8X", .F. )
			B8X->B8X_RECEBI := "1"
			B8X->B8X_VALIDA := "1"
			B8X->(msUnLock())

			lReturn := .T.

		EndIf

	Else
		lReturn := .T.

	EndIf

Return lReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} quadroIniEnvDiops

Indica o inicio de envio de um quadro

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere, lDelQua, cRecno )
	Local cTable		:= getTabQuadr( cQuadro )
	Local lReturn		:= .F.
	Local cWhrQuadro 	:= ""
	Local cWhrCritica 	:= ""
	Local cMsgErro 		:= ""

	Default lDelQua	:= .T.
	Default cRecno := ""

	if ( !empty(cTable) )

		cCodObr := PLSEXIOBR( cCodOpe )

		cCdComp := PLSEXICOM( cCodOpe, cCodObr, cRefere, cAno )

		//Monta o where para limpeza do quadro
		cWhrQuadro := GetWhrQuadro(cTable,cCodOpe,cCodObr,cAno,cCdComp,cRecno)

		//Monta o where para limpeza das criticas do quadro
		cWhrCritica := GetWhrCritica(cTable,cCodOpe,cCodObr,cAno,cCdComp,cTable)

		If !cQuadro == QDR_BALANC

			lReturn := existeBalancete(cCodOpe,cCodObr,cAno,cCdComp)

			If !lReturn
				cMsgErro := "Balancete para o compromisso DIOPS do " + allTrim(str(val(cRefere))) + " trimestre de " + allTrim(cAno) + " não encontrado. Permissão para importação negada."
				Help( ,, 'HELP',,  cMsgErro, 1, 0)

			Else
				// Realiza preenchimento de registros dos quadros que exigem
				If cQuadro == QDR_IDASPA	//Idade de Saldos A Pagar
					PLSCRIIDSA(cCodOpe,cCodObr,cCdComp,cAno)
				ElseIf cQuadro == QDR_IDASRE	//Idade de Saldos A Receber
					PLSCRIIDSP(cCodOpe,cCodObr,cCdComp,cAno)
				EndIf

			EndIf

		Else
			lReturn := .T.

		EndIf

	Endif

	If lReturn

		If lDelQua
			delRegDIOPS( cTable, cWhrQuadro, cWhrCritica  )
		Else
			updStatusQua(cTable, cWhrQuadro,"1")
		EndIf

	EndIf

Return lReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabQuadr

Retorna array de regras a serem validadas

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function getTabQuadr( cQuadro )

	local cTable := ""

	Do Case

		Case cQuadro == QDR_BALANC //Balancete
			cTable := getTabBal()
		Case cQuadro == QDR_CADAST //Dados cadastrais
			cTable := cTable
		Case cQuadro == QDR_AGIMOB //Ativos garantidores Imobiliario
			cTable := GetTabAGI()
		Case cQuadro == QDR_FLUXCA //Fluxo de Caixa Trimestral
			cTable := GetTabFLX()
		Case cQuadro == QDR_IDASPA //Idade de Saldos - A Pagar
			cTable := GetTabIDSA()
		Case cQuadro == QDR_LUCPRE //Lucros e Prejuízos
			cTable := getTabLCR()
		Case cQuadro == QDR_CONEST //Contratos Estipulados
			cTable := GetTabCOE()
		Case cQuadro == QDR_CONREP //Segregação do Montante de Contraprestações a Repassar
			cTable := getTabSMCR()
		Case cQuadro == QDR_COBASS //Cobertura Assistencial
			cTable := GetTabCOA()
		Case cQuadro == QDR_EVEIND //Movimentação de Eventos Indenizáveis
			cTable := GetTabEvIn()
		Case cQuadro == QDR_AGRCON //Agrupamento de Contratos
			cTable := GetTabAgCo()
		Case cQuadro == QDR_PESL //Saldo da Provisão de Eventos Sinistros a Liquidar
			cTable := GetTabPES()
		Case cQuadro == QDR_CCCOOP //Conta-Corrente Cooperado
			cTable := GetTabCCC()
		Case cQuadro == QDR_CTRPAS //Conta Tributo Passivo
			cTable := GetTabCTP()
		Case cQuadro == QDR_IDASRE //Idade de Saldos - A receber
			cTable := GetTabIDSP()
			//Descontinuado DSAUCEN-1840
			//Case cQuadro == QDR_EVECOR //Eventos Corresponsabilidade
			//	cTable := GetTabEVC()
		Case cQuadro == QDR_FUNCOM //Fundos Comuns
			cTable := GetTabFUC()
		Case cQuadro == QDR_EVCCC  //CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA
			cTable := GetTabCED()
		Case cQuadro == QDR_MPC    // "Modelo Padrão de Capital"
			cTable := GetTabMPC()
		Case cQuadro == QDR_TAP    // "Modelo Padrão de Capital"
			cTable := GetTabTAP()
		Case cQuadro == QDR_CONPEC //Contraprestações pecuniárias
			cTable := GetTabCtPe()
		Case cQuadro == QDR_CRDEOP //CBR - Risco de Crédito - Parcela 1
			cTable := GetTabCrDO()
		Case cQuadro == QDR_DEFUIN //CBR - Risco de Crédito - Parcela 2
			cTable := GetTabDFuI()
		Case cQuadro == QDR_INADIM //Inadimplência - Administradora de beneficiários
			cTable := GetTabIna()
		Case cQuadro == QDR_CBRIS//Inadimplência - Administradora de beneficiários
			cTable := GetTabRIS()
	EndCase

return cTable
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} setQuadValDiops

Atualiza quadro informando que o mesmo ja foi validado

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function setQuadValDiops( cQuadro, cCodOpe, cCodObr, cAnoCmp, cComp, cQuadro )

	local cTable := "B8X"
	Default cQuadro	:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cComp	:= ""
	Default cQuadro	:= ""

	(cTable)->(dbSetOrder(1))//B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO

	if ( (cTable)->(MsSeek( xFilial( cTable )+cCodOpe+cCodObr+cAnoCmp+cComp+cQuadro )) )

		recLock( cTable, .F. )
		(cTable)->B8X_VALIDA := "2"
		(cTable)->(msUnLock())

	endif

return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getQuadrosDiops

Retorna array com os quadros do DIOPS

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getQuadrosDiops()

	local aQuadros := {}

	aAdd( aQuadros, { QDR_CADAST, "Dados Cadastrais",											""                  ,""              ,""   } )
	aAdd( aQuadros, { QDR_BALANC, "Balancete Trimestral",										"PLSMIGBAL"         ,"PLSRDBALT(.T.)","123"} )
	aAdd( aQuadros, { QDR_AGIMOB, "Ativos Garantidores - Imobiliario",							"PLSMIGAGI"         ,"PLSRDAGIM(.T.)","123"} )
	aAdd( aQuadros, { QDR_FLUXCA, "Fluxo de Caixa Trimestral",									"PLSMIGFLX"         ,"PLSRDFLCX(.T.)","123"} )
	aAdd( aQuadros, { QDR_LUCPRE, "Lucros e Prejuízos",											"PLSMIGLCR"         ,"PLSRDLCRP(.T.)","123"} )
	aAdd( aQuadros, { QDR_IDASPA, "Idade de Saldos - A Pagar",   								"PLSMIGISA"	        ,"PLSRDISP(.T.)" ,"123"} )
	aAdd( aQuadros, { QDR_IDASRE, "Idade de Saldos - A Receber",						     	"PLSMIGISP"         ,"PLSRDISA(.T.)" ,"123"} )
	aAdd( aQuadros, { QDR_COBASS, "Cobertura Assistencial",										"PLSMIGCOA"         ,"PLSRDCOAS(.T.)","23" } )
	aAdd( aQuadros, { QDR_AGRCON, "Agrupamento de Contratos",									"PLSMIGAGC"         ,"PLSRDAGCN(.T.)","23" } )
	aAdd( aQuadros, { QDR_EVEIND, "Movimentação de Eventos Indenizáveis",						"PLSMIGEVI"         ,"PLSRDEVIN(.T.)","23" } )
	aAdd( aQuadros, { QDR_PESL,   "Saldo da Provisão de Eventos Sinistros a Liquidar",			"PLSMIGPES"         ,"PLSRDPESL(.T.)","23" } )
	aAdd( aQuadros, { QDR_CCCOOP, "Conta-Corrente Cooperado",									''/*"PLSMIGCCC"*/   ,"PLSRBCCC(.T.)" ,"23" } )
	aAdd( aQuadros, { QDR_CTRPAS, "Conta Tributo Passivo",										''/*"PLSMIGCTP"*/   ,"PLSRBCTP(.T.)" ,"23" } )
	aAdd( aQuadros, { QDR_CONEST, "Contratos Estipulados",										''/*"PLSMIGCOE"*/   ,"PLSRDCOE(.T.)" ,"13" } )
	aAdd( aQuadros, { QDR_CONREP, "Segregação do Montante de Contraprestações a Repassar",		''/*"PLSMIGMCR"*/   ,"PLSRDSMCR(.T.)","13" } )
	aAdd( aQuadros, { QDR_FUNCOM, "Programas-Fundos Comuns de Despesas Assistenciais (2018)",	''/*"PLSMIGFUC"*/   ,"PLSRDFUCO(.T.)","23" } )
	aAdd( aQuadros, { QDR_EVCCC,  "Eventos de Contraprestação de Corresponsabilidade Cedida",	''/*"PLSMIGMCR"*/   ,"PLSRDEVCC(.T.)","23" } )
	aAdd( aQuadros, { QDR_MPC,	  "Modelo Padrão de Capital",		''                                              ,"PLSRDMPC(.T.)" ,"23" } )
	aAdd( aQuadros, { QDR_TAP,	  "Teste de Adequação do Passivo - TAP",		''                                  ,"PLSRDTAP(.T.)" ,"23" } )
	aAdd( aQuadros, { QDR_CONPEC, "Contraprestação Pecuniária / Prêmios por Período de Cobertura",''/*"PLSMIGCPC"*/ ,"PLSRCTPE(.T.)" ,"23" } )
	aAdd( aQuadros, { QDR_CRDEOP, "CBR - Risco de Crédito - Parcela 1"                           ,''/*"PLSMIGCDO"*/       ,"CENRCRDEOP(.T.)" ,"123" } )
	aAdd( aQuadros, { QDR_DEFUIN, "CBR - Risco de Crédito - Parcela 2",''/*"PLSMIGDFI"*/   ,"CENRDEFUI(.T.)" ,"123" } )
	aAdd( aQuadros, { QDR_INADIM, "Inadimplência Administradora de Beneficiários"              ,''/*"PLSMIGDFI"*/   ,"CENRINADI(.T.)" ,"1" } )
	aAdd( aQuadros, { QDR_CBRIS,  "Capital Baseado em Riscos - Risco de Mercado - ALM"              ,''/*"PLSMIGDFI"*/   ,"CENRRISCO(.T.)" ,"123" } )

Return aQuadros

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDescQuadDiops

Retorna descricao do quadro da DIOPS

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getDescQuadDiops( cQuadro )

	local cDesc := ""
	local aQuadros := getQuadrosDiops()

	nPos := ascan(aQuadros,{|x| x[1] == allTrim(cQuadro)})

	if ( nPos >= 0 )
		cDesc := aQuadros[nPos][2]
	endif

return cDesc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CompPermImp

Verifica se o compromisso se encontra 4=Em processamento ou 6=Finalizado , se estiver retorna F nao pode importar o quadro

@author timoteo.bega
@since 01/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CompPermImp(oModel, cFStruct, cFCodOpe, cFObri, cFComp, cFAno )
	Local lRet		:= .T.
	Local cCodOpe	:= ""
	Local cCodObr	:= ""
	Local cCdComp	:= ""
	Local cAnoCmp	:= ""
	Local cNAlias	:= GetNextAlias()

	cCodOpe := oModel:GetValue(cFStruct,cFCodOpe)
	cCodObr := oModel:GetValue(cFStruct,cFObri)
	cCdComp := oModel:GetValue(cFStruct,cFComp)
	cAnoCmp := oModel:GetValue(cFStruct,cFAno)

	cSql := "SELECT R_E_C_N_O_ REC, B3D_STATUS FROM " + RetSqlName("B3D") + " "
	cSql += "WHERE B3D_FILIAL='" + xFilial("B3D") + "' AND B3D_CODOPE='" + cCodOpe + "' AND B3D_CDOBRI='" + cCodObr + "' AND B3D_ANO='" + cAnoCmp + "' AND B3D_CODIGO='" + cCdComp + "' AND B3D_STATUS IN ('4','6') AND D_E_L_E_T_=' '"
	//B3D_STATUS = 1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())

		lRet := .F.
		cMsgErro := "Quadro não pode ser importado pois o compromisso se encotra no status " + Iif( (cNAlias)->B3D_STATUS == "4", "Em Processamento" , "Finalizado" )
		Help( ,, 'HELP',,  cMsgErro, 1, 0)

	EndIf

	(cNAlias)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChaveQuadro

Verifica se a chave primaria do quadro nao vai ser quebrada com o novo registro

@author timoteo.bega
@since 05/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChaveQuadro(oModel, cFStruct, cFCodOpe)
	Local lRet		:= .T.
	Local cSql		:= ""
	Local cTable	:= LEFT(cFCodOpe,3)
	Local cNAlias	:= GetNextAlias()
	Local aPriKey	:= oModel:GetPrimaryKey()
	Local nFor		:= 0

	cSql := " SELECT R_E_C_N_O_ FROM " + RetSqlName(cTable) + " WHERE " + cTable + "_FILIAL = '" + xFilial(cTable) + "' "

	For nFor := 1 TO Len(aPriKey)
		cCampo := aPriKey[nFor]
		If "_FILIAL" $ cCampo
			Loop
		EndIf
		cValor := oModel:GetValue(cFStruct,cCampo)
		cSql += " AND " + cCampo + " = '"
		cSql += IIf(VALTYPE(cValor)=='D', DTOS(cValor), IIf(VALTYPE(cValor)=='N', Str(cValor), cValor) ) + "' "
	Next nFor

	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())
		if oModel:GetOperation() == MODEL_OPERATION_INSERT .Or.  &(cTable)->(Recno()) <> (cNAlias)->R_E_C_N_O_
			lRet := .F.
			cMsgErro := "O registro não pode ser inserido pois já existe no banco de dados."
			Help( ,, 'HELP',,  cMsgErro, 1, 0)
		EndIf

	EndIf

	(cNAlias)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} updStatusQua

Atualiza registro de quadros que ainda não possuem intregracao

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function updStatusQua(cTable,cWhrQuadro,cStatus)
	Local cUpdate		:= ""
	Default cTable		:= ""
	Default cWhrQuadro	:= ""
	Default cStatus		:= "1"

	cUpdate := "UPDATE " + RetSqlName(cTable) + " SET " + AllTrim(cTable) + "_STATUS='" + cStatus + "' WHERE " + AllTrim(cWhrQuadro)
	TCSQLEXEC(cUpdate)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LibQuaVal

Função criada para liberar para validação quadros sem integração, que são cadasrtrados manualmente

@author timoteo.bega
@since 23/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function LibQuaVal(cQuadro, cCodOpe, cAno, cRefere, oModel)
	Local lRet		:= .F.
	local cRecno 	:= ""
	Local cTable	:= getTabQuadr( cQuadro )
	Default cQuadro	:= ""
	Default cCodOpe	:= ""
	Default cAno	:= ""
	Default cRefere	:= ""
	Default oModel	:= nil

	If oModel <> nil .and. oModel:GetOperation() == MODEL_OPERATION_DELETE
		cRecno := AllTrim( Str( (cTable)->(Recno()) ) )
	endif

	If quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere, .F., cRecno )
		lRet := quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
	EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CONSOPCT
Função utilizada para filtrar as contas de acordo com a Operadora //Caso queira utilizar a consulta padrão B8BPLS em outras tabelas
diferente de B8E e BUY.. deve adicionar a validação abaixo.

@author    José Paulo
@version   V12
@since     13/06/2019
/*/
//------------------------------------------------------------------------------------------
function CONSOPCT()
	local cRet := "@#.T."

	if Type('M->B8E_CODOPE') <> 'U'
		cRet 	:= "@#M->B8E_CODOPE == B8B->B8B_CODOPE "

	elseiF	Type('M->B8A_CODOPE') <> 'U'
		cRet 	:= "@#M->B8A_CODOPE == B8B->B8B_CODOPE "

	elseiF	Type('M->BUY_CODOPE') <> 'U'
		cRet 	:= "@#M->BUY_CODOPE == B8B->B8B_CODOPE "
	Else
		cRet 	:= "@#M->B8B_CODOPE == B8B->B8B_CODOPE "

	EndIf

	cRet += " @#"

return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDIOZERO
Insere os valores zerados no quadro

@author    david.juan
@since     06/05/2021
/*/
//------------------------------------------------------------------------------------------
Function CENDIOZERO(cQuadro, aCampos)
	Local nCampo	:= 0
	Local nLenCampos:= 0
	Default cQuadro := ""
	Default aCampos := {}

	nLenCampos := Len(aCampos)

	If !Empty(cQuadro) .AND. nLenCampos > 0
		If !MsSeek(xFilial(cQuadro)+B3D->B3D_CODOPE+B3D->B3D_CDOBRI+B3D->B3D_ANO+B3D->B3D_CODIGO)
			RecLock(cQuadro,.T.)
			(cQuadro)->&(cQuadro + "_FILIAL") := xFilial(cQuadro)
			(cQuadro)->&(cQuadro + "_CODOPE") := B3D->B3D_CODOPE
			(cQuadro)->&(cQuadro + "_CODOBR") := B3D->B3D_CDOBRI
			(cQuadro)->&(cQuadro + "_ANOCMP") := B3D->B3D_ANO
			(cQuadro)->&(cQuadro + "_CDCOMP") := B3D->B3D_CODIGO
			(cQuadro)->&(cQuadro + "_REFERE") := B3DRefere()
			(cQuadro)->&(cQuadro + "_STATUS") := PDTE_VALID
			For nCampo := 1 To nLenCampos
				(cQuadro)->&(cQuadro + aCampos[nCampo]) := 0
			Next nCampo
			msUnLock()
		Else
			MsgInfo("Já existe registro dentro da vigência parametrizada.","Verifique")
		EndIf
	EndIf
Return

/*/{Protheus.doc} VlMesDiops
	Valida se o mês informado entra no trimestre corret.
	@type  Function
	@author PLS Team
	@since 03/05/2024
	/*/
Function VlMesDiops(oModel, cFStruct )

	Local lOk := .T.
	Local cComp := "" 
	Local cMesCmp := "" 

	iF cFStruct $ "B8AMASTER" .OR. cFStruct $ "B8HMASTER" 

		cComp := IIF( cFStruct == "B8AMASTER", oModel:getValue( cFStruct, "B8A_CDCOMP" ), oModel:getValue( cFStruct, "B8H_CDCOMP" ) )
		cMesCmp := IIF( cFStruct == "B8AMASTER", oModel:getValue( cFStruct, "B8A_MESCMP" ), oModel:getValue( cFStruct, "B8H_MESCMP" ) )

		if cComp == "001"
			If !(cMesCmp >= "01" .and. cMesCmp <= "03")
				lOk := .F.
			Endif
		Elseif cComp == "002"
			If !(cMesCmp >= "04" .and. cMesCmp <= "06")
				lOk := .F.
			Endif
		Elseif cComp == "003"
			If !(cMesCmp >= "07" .and. cMesCmp <= "09")
				lOk := .F.
			Endif
		Elseif cComp == "004"
			If !(cMesCmp >= "10" .and. cMesCmp <= "12")
				lOk := .F.
			Endif
		EndIf

	EndIf
		
Return lOk
