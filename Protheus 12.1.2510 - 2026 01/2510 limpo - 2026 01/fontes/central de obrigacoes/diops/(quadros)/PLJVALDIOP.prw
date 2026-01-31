#include 'totvs.ch'

#DEFINE POS_TABELA	1
#DEFINE POS_REGBLC	2
#DEFINE POS_REGIND	3

#DEFINE CODCRI      1 // Codigo da critica
#DEFINE CODANS      2 // Função de Validação da Crítica
#DEFINE FUNCAO      3 // Função de Validação da Crítica
#DEFINE DESCRI      4 // Descricao
#DEFINE SOLUCAO     5 // Solucao
#DEFINE CONDICAO    6 // Indicacao de critica totalizadora

#DEFINE CODOPE      1
#DEFINE CDCOMP      2
#DEFINE CODOBR      3
#DEFINE ANOCMP      4
#DEFINE QUADRO      5

#DEFINE QDR_BALANC	"1"		// "Balancete Trimestral"
#DEFINE QDR_CADAST	"2"		// "Dados Cadatrais
#DEFINE QDR_AGIMOB	"3"		// "Ativos Garantidores - Imobiliario"
#DEFINE QDR_FLUXCA	"4"		// "Fluxo de Caixa Trimestral"
#DEFINE QDR_IDASPA	"5"		// "Idade de Saldos - Contas a Pagar"
#DEFINE QDR_LUCPRE	"6"		// "Lucros e Prejuízos"
#DEFINE QDR_CONEST	"7"		// "Contratos Estipulados"
#DEFINE QDR_CONREP	"8"		// "Segregação do Montante de Contraprestações a Repassar"
#DEFINE QDR_COBASS	"9"		// "Cobertura Assistencial"
#DEFINE QDR_EVEIND	"11"	// "Movimentação de Eventos Indenizáveis"
#DEFINE QDR_AGRCON	"12"	// "Agrupamento de Contratos"
#DEFINE QDR_PESL    "13"	// "Saldo da Provisão de Eventos Sinistros a Liquidar"
#DEFINE QDR_CCCOOP	"14"	// "Conta-Corrente Cooperado"
#DEFINE QDR_CTRPAS	"15"	// "Conta Tributo Passivo"
#DEFINE QDR_IDASRE	"16"	// "Idade de Saldos - Contas a Receber"
#DEFINE QDR_EVECOR	"18"	// "Eventos em Corresponsabilidade (2018)"
#DEFINE QDR_FUNCOM  "19"	// "Programas-Fundos Comuns de Despesas Assistenciais (2018)"
#DEFINE QDR_EVCCC   "20"	// "Eventos de Contraprestação de Corresponsabilidade Cedida"
#DEFINE QDR_MPC	    "21"	// "Modelo Padrão de Capital"
#DEFINE QDR_TAP     "22"	// "Teste de Adequação do Passivo"
#DEFINE QDR_CONPEC	"23"	// "Movimentação de Contraprestação de Coresponsabilidade"
#DEFINE	QDR_CRDEOP  "24"    // Créditos Débitos Operadora
#DEFINE QDR_DEFUIN  "25"    // Detalhamento Fundos Investimentos
#DEFINE QDR_INADIM  "26"    // Inadimplência
#DEFINE QDR_CBRIS  "27"    // Risco de Mercado

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaDIOPS

Funcao que roda a validacao doo quadro que esta pendente validar e já foi recebido do software de gestao

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function PLJVALDIOP( cCodOpe, cQuadro )

	local cNAlias := getNextAlias()
	local cLockThread := ""
	local aQuadros := {}
	local nQuadro
	default cCodOpe := MV_PAR01
	default cQuadro := ""

	cSql := " SELECT "
	cSql += "  B8X_CODOPE, B8X_CDCOMP, B8X_CODOBR, B8X_ANOCMP, B8X_QUADRO "
	cSql += " FROM " + RetSqlName("B8X") + " "
	cSql += " WHERE "
	cSql += "  B8X_FILIAL = '" + xFilial("B8X") + "' "
	cSql += "  AND B8X_CODOPE = '" + cCodOpe + "' "
	cSql += "  AND B8X_RECEBI = '1' "
	cSql += "  AND B8X_VALIDA = '1'  "
	If !Empty(cQuadro)
		cSql += " 	AND B8X_QUADRO = '" + cQuadro + "'  "
	EndIf
	cSql += "  AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8X_CODOPE,B8X_CODOBR,B8X_ANOCMP,B8X_CDCOMP,B8X_QUADRO "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	while !(cNAlias)->(Eof())

		aAdd(aQuadros,{.F.,{ (cNAlias)->B8X_CODOPE, (cNAlias)->B8X_CDCOMP, (cNAlias)->B8X_CODOBR, (cNAlias)->B8X_ANOCMP, (cNAlias)->B8X_QUADRO }})
		(cNAlias)->(dbSkip())

	end

	(cNAlias)->(dbCloseArea())

	for nQuadro := 1 to len(aQuadros)

		cLockThread := "diops_"+allTrim(aQuadros[nQuadro][2][CODOPE])+allTrim(aQuadros[nQuadro][2][CODOBR])+allTrim(aQuadros[nQuadro][2][CDCOMP])+allTrim(aQuadros[nQuadro][2][ANOCMP])+allTrim(aQuadros[nQuadro][2][QUADRO])+".lck"
		lLocked := CenSmfCtrl( cLockThread )

		if lLocked
			startJob("execValDIOPS",GetEnvServer(),.F.,cEmpAnt, cFilAnt, aQuadros[nQuadro][2][CODOPE], aQuadros[nQuadro][2][CDCOMP], aQuadros[nQuadro][2][CODOBR], cLockThread, aQuadros[nQuadro][2][ANOCMP], aQuadros[nQuadro][2][QUADRO])
		endif

	next nQuadro

return nQuadro >= 1

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execValDIOPS

Faz a execução multi thread da validacao dos quadros agrupado por operadora + compromisso

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function execValDIOPS( cEmp, cFil, cCodOpe, cComp, cObr, cLockThread, cAno, cQuadro, lJob )

	local cNAlias := getNextAlias()
	Default lJob := .T.

	If lJob
		rpcSetType(3)
		rpcSetEnv( cEmp, cFil,,,'PLS',, )
	EndIf

	ptInternal( 1,"Central Obrigações DIOPS: Validação [ Operadora: "+cCodOpe+" - Obrigacao: "+cObr+" - Compromisso: "+cComp+"/"+cAno+" - Quadro: "+allTrim(getDescQuadDiops( cQuadro ))+" ]" )

	validComQDIOPS( cCodOpe, cComp, cQuadro, cObr, cAno )

	If ( B8X->( msSeek( xFilial("B8X")+cCodOpe+cObr+cAno+cComp+cQuadro, .F. ) ) )
		RecLock("B8X",.F.)
		B8X->B8X_VALIDA := '2'
		B8X->(msUnLock())
	EndIf

	If !ExisteCritComp(cCodOpe,cObr,cComp,cAno)

		StatusCompEnvio(cCodOpe,cObr,cComp,cAno)

	EndIf

	CenSmfCtrl( cLockThread, .T. )
	fErase( cLockThread )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} validComQDIOPS

Faz a execucao da validacao do quadro do DIOPS de acordo com a operadora e compromisso

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function validComQDIOPS( cCodOpe, cComp, cQuadro, cObr, cAno )

	local aRegras := {}
	Local aArea := {}
	aRegras := getRegras( cQuadro )
	If !Empty(aRegras[POS_TABELA])
		aArea := (aRegras[POS_TABELA])->(GetArea())
		B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
		B3D->(dbSeek(xFilial("B3D")+cCodOpe+cObr+cAno+cComp))

		if ( !empty( aRegras[POS_REGBLC] ) )
			execRegraAll( cCodOpe, cComp, cQuadro, cObr, aRegras[POS_TABELA], aRegras[POS_REGBLC], cAno )
		endif

		if ( !empty( aRegras[POS_REGIND] ) )
			execRegraBl( cCodOpe, cComp, cQuadro, cObr, aRegras[POS_TABELA], aRegras[POS_REGIND], cAno )
		endif
		RestArea(aArea)
	EndIf
return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegras

Retorna array de regras a serem validadas

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function getRegras( cQuadro )

	local aRegras := {"",{},{}}
	cQuadro	:= AllTrim(cQuadro)
	Do Case

		Case cQuadro == QDR_BALANC//Balancete
			aRegras := getRegBal()
		Case cQuadro == QDR_AGIMOB //Ativos garantidores Imobiliario
			aRegras := GetRegAgi()
		Case cQuadro == QDR_FLUXCA //Fluxo de Caixa Trimestral
			aRegras := getRegFlx()
		Case cQuadro == QDR_IDASPA //Idade de Saldos - Contas a Pagar
			aRegras := GetRegIDSA()
		Case cQuadro == QDR_LUCPRE//Lucros e Prejuízos
			aRegras := GetRegLCR()
		Case cQuadro == QDR_COBASS //Cobertura Assistencial
			aRegras := getRegCoA()
		Case cQuadro == QDR_EVEIND //Movimentação de Eventos Indenizáveis
			aRegras := getRegEvIn()
		Case cQuadro == QDR_AGRCON //Agrupamento de Contratos
			aRegras := getRegAGC()
		Case cQuadro == QDR_PESL //Saldo da Provisão de Eventos Sinistros a Liquidar
			aRegras := getRegPES()
		Case cQuadro == QDR_CCCOOP //Conta-Corrente Cooperado
			aRegras := GetRegCCC()
		Case cQuadro == QDR_CTRPAS //Conta Tributo Passivo
			aRegras := GetRegCTP()
		Case cQuadro == QDR_IDASRE //Idade de Saldos - Contas a Receber
			aRegras := GetRegIDSP()
			//Descontinuado DSAUCEN-1840
			//Case cQuadro == QDR_EVECOR //Eventos Corresponsabilidade
			//	aRegras := GetRegEVC()
		Case cQuadro == QDR_FUNCOM //Fundos Comuns
			aRegras := GetRegFUC()
		Case cQuadro == QDR_CONREP //Fundos Comuns
			aRegras := getRegSMCR()
		Case cQuadro == QDR_EVCCC //Idade de Saldos - Contas a Receber
			aRegras := getRegCED()
		Case cQuadro == QDR_MPC
			aRegras := getRegMPC()
		Case cQuadro == QDR_TAP
			aRegras := getRegTap()
		Case cQuadro == QDR_CONPEC //Movimentação de Contraprestação de Corresponsabilidade
			aRegras := GetRegCtPe()
		Case cQuadro == QDR_CONEST //Contratos estipulados
			aRegras := GetRegCOE()
		Case cQuadro == QDR_CRDEOP //Contratos estipulados
			aRegras := GetRegCDO()
		Case cQuadro == QDR_DEFUIN //Contratos estipulados
			aRegras := GetRegDFI()
		Case cQuadro == QDR_INADIM //Inadimplência - Administradora de beneficiários
			aRegras := GetRegIna()
		Case cQuadro == QDR_CBRIS // Capital Baseado em Riscos de Mercado
			aRegras := GetRegRIS() 

	EndCase

return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execRegraAll

Executa as regras para todos registros de um compromisso do quadro

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function execRegraAll( cCodOpe, cComp, cQuadro, cObr, cTable, aRegras, cAno )

	local cNAlias := getNextAlias()
	local cDescQdr := ""

	cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName(cTable) + " WHERE "+allTrim(cTable)+"_FILIAL = '" + xFilial(cTable) + "' AND "+allTrim(cTable)+"_CODOPE = '" + cCodOpe + ;
		"' AND "+allTrim(cTable)+"_CODOBR = '" + cObr + "' AND "+allTrim(cTable)+"_ANOCMP = '" + cAno + "' AND "+allTrim(cTable)+"_CDCOMP = '" + cComp + ;
		"' AND "+allTrim(cTable)+"_STATUS <> '2' AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	cDescQdr := allTrim(getDescQuadDiops( cQuadro ))

	ptInternal( 1,"Central Obrigações DIOPS: Validando Regras Registro a Registro [ Operadora: "+allTrim(cCodOpe)+" - Obrigacao: "+allTrim(cObr)+" - Compromisso: "+allTrim(cComp)+"/"+allTrim(cAno)+" - Quadro: "+cDescQdr+" ]" )

	while !(cNAlias)->(Eof())

		(cTable)->(dbGoTo( (cNAlias)->R_E_C_N_O_ ))

		lRet := plObVldCri( cCodOpe, cObr, cAno, cComp, aRegras, cTable, (cNAlias)->R_E_C_N_O_, Nil, Nil, "1", {}, cDescQdr,"")

		(cNAlias)->(dbSkip())

	end

	ptInternal( 1,"Central Obrigações DIOPS: Fim Validacao Regras Registro a Registro [ Operadora: "+allTrim(cCodOpe)+" - Obrigacao: "+allTrim(cObr)+" - Compromisso: "+allTrim(cComp)+"/"+allTrim(cAno)+" - Quadro: "+cDescQdr+" ]" )

	(cNAlias)->(dbCloseArea())

return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execRegraBl

Executa as regras para um bloco de registros de um compromisso do quadro

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function execRegraBl( cCodOpe, cComp, cQuadro, cObr, cTable, aRegras, cAno )

	local cNAlias := getNextAlias()
	local nRegra
	local lRet := .F.
	local cSqlRecno := ""
	local cDescQdr := allTrim(getDescQuadDiops( cQuadro ))
	local lEncCr   := .F.
	Local cFiltro := ""

	ptInternal( 1,"Central Obrigações DIOPS: Validando Regras Registro em Bloco [ Operadora: "+allTrim(cCodOpe)+" - Obrigacao: "+allTrim(cObr)+" - Compromisso: "+allTrim(cComp)+"/"+allTrim(cAno)+" - Quadro: "+cDescQdr+" ]" )

	// Já posicionado no B3D
	for nRegra := 1 to len( aRegras )

		If cFiltro <> aRegras[nRegra][CONDICAO]
			cFiltro := aRegras[nRegra][CONDICAO]
			lEncCr := .F.
		EndIf

		cMacro := aRegras[nRegra][FUNCAO]
		lRet := &cMacro

		cSqlRecno := "SELECT R_E_C_N_O_ "
		cSqlRecno += " FROM " + RetSqlName(cTable) + " "
		cSqlRecno += " WHERE "
		cSqlRecno += " "+allTrim(cTable)+"_FILIAL = '" + xFilial(cTable) + "' "
		cSqlRecno += " AND "+allTrim(cTable)+"_CODOPE = '" + cCodOpe + "' "
		cSqlRecno += " AND "+allTrim(cTable)+"_CODOBR = '" + cObr + "' "
		cSqlRecno += " AND "+allTrim(cTable)+"_ANOCMP = '" + cAno + "' "
		cSqlRecno += " AND "+allTrim(cTable)+"_CDCOMP = '" + cComp + "' "
		cSqlRecno += " " + cFiltro + " "
		cSqlRecno += " AND D_E_L_E_T_ = ' ' "

		if ( !lRet )

			B3F->(dbSetOrder(7))
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlRecno),cNAlias,.F.,.T.)

			while !(cNAlias)->(Eof())

				PlObInCrit(cCodOpe,cObr,cAno,cComp,cTable,PADL(AllTrim(Str((cNAlias)->R_E_C_N_O_)),10),aRegras[nRegra][CODCRI],aRegras[nRegra][DESCRI],aRegras[nRegra][SOLUCAO],'','1','', cDescQdr )

				//Informo que o registro foi validado = Status: '1=Nao Validado;2=Valido;3=Invalido'
				TmpStaVld((cNAlias)->R_E_C_N_O_,cTable,dDataBase,Time(),Iif(!lRet,"3","2"),'1')

				(cNAlias)->(dbSkip())
				lEncCr:=.T.
			end

			(cNAlias)->(dbCloseArea())

		Else
			RegistroValido(cTable,cSqlRecno,aRegras[nRegra][CODCRI],lEncCr)

		Endif

	Next nRegra

	ptInternal( 1,"Central Obrigações DIOPS: Fim Validacao Regras Registro em Bloco [ Operadora: "+allTrim(cCodOpe)+" - Obrigacao: "+allTrim(cObr)+" - Compromisso: "+allTrim(cComp)+"/"+allTrim(cAno)+" - Quadro: "+cDescQdr+" ]" )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef

Funcao criada para definir o pergunte do schedule

@return	aParam
				"P"		Processo
				"SIPSDE"	Nome do pergunte
				""			Alias para o relatorio
				aOrdem	Array de ordem para relatorio
				""			Titulo para relatorio
@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()

	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P","DIOPSCE",,aOrdem,"" }

Return aParam

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteCritComp

Verifica se existe alguma critica para o compromisso

@author timoteo.bega
@since 01/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteCritComp(cCodOpe,cObr,cComp,cAno)
	Local lRet			:= .T.
	Local cSql			:= ""
	Local cNAlias		:= GetNextAlias()
	Default cCodOpe	:= ""
	Default cObr		:= ""
	Default cComp		:= ""
	Default cAno		:= ""

	cSql := "SELECT B3F.R_E_C_N_O_ REC FROM " + RetSqlName("B3F") + " B3F "
	cSql += "WHERE B3F_FILIAL='" + xFilial("B3F") + "' AND B3F_CODOPE='" + cCodOpe + "' AND B3F_CDOBRI='" + cObr + "' AND B3F_ANO='" + cAno + "' AND B3F_CDCOMP='" + cComp + "' AND B3F_STATUS='1' AND B3F.D_E_L_E_T_=' '"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())

		lRet := .T.

	EndIf

	(cNAlias)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StatusCompEnvio

Atualiza o status do compromisso como 3-Pronto para Envio

@author timoteo.bega
@since 01/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function StatusCompEnvio(cCodOpe,cObr,cComp,cAno)
	Default cCodOpe	:= ""
	Default cObr		:= ""
	Default cComp		:= ""
	Default cCano		:= ""

	B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
	If B3D->(dbSeek(xFilial("B3D")+cCodOpe+cObr+cAno+cComp+"3"))//3-DIOPS

		RecLock("B3D",.F.)
		B3D->B3D_STATUS := "3"//1=Pendente Envio;2=Criticado;[3]=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
		msUnLock()

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RegistroValido

Funcao criara para marcar o registro como valido (status=2) para validacao em bloco

@author timoteo.bega
@since 17/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RegistroValido(cTable,cSql,cCodCri,lEncCr)
	Local cNAlias		 := GetNextAlias()
	Local cCmpStatus := ""
	Local cCmpDtInVl := ""
	Local cCmpHrInVl := ""
	Local cCmpDtTeVl := ""
	Local cCmpHrTeVl := ""

	Default cTable   := ""
	Default cSql		 := ""
	Default cCodCri  := ""
	Default lEncCr   := .F.

	B3F->(dbSetOrder(7))

	If !Empty(cTable) .And. !Empty(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)
		cCmpStatus := cTable + "->" + cTable + "_STATUS"
		cCmpDtInVl:= cTable + "->" + cTable + "_DTINVL"
		cCmpHrInVl:= cTable + "->" + cTable + "_HRINVL"
		cCmpDtTeVl:= cTable + "->" + cTable + "_DTTEVL"
		cCmpHrTeVl:= cTable + "->" + cTable + "_HRTEVL"

		While !(cNAlias)->(Eof())

			nRec	:= (cNAlias)->R_E_C_N_O_
			(cTable)->(dbGoTo(nRec))

			If &cCmpStatus <> '3' .Or. lEncCr
				RecLock(cTable,.F.)

				If !lEncCr
					&cCmpStatus := "2"
				EndIf
				&cCmpDtInVl:= dDataBase
				&cCmpHrInVl:= Time()
				&cCmpDtTeVl:= dDataBase
				&cCmpHrTeVl:= Time()


				msUnLock()

				// Limpa crítica do B3D
				PLOBCORCRI(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,cTable,PADL(AllTrim(Str(nRec)),10),cCodCri,'1')

			EndIf

			(cNAlias)->(dbSkip())

		EndDo

		(cNAlias)->(dbCloseArea())

	EndIf

Return
