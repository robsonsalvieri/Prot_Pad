#INCLUDE 'PROTHEUS.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE DATA_TRIM  	1
#DEFINE REGANS    	2
#DEFINE COD_CONTA  	3
#DEFINE DES_CONTA  	4
#DEFINE SALDO_ANT  	5
#DEFINE DEBITO   	6
#DEFINE CREDITO    	7
#DEFINE SALDO_FIN  	8

#DEFINE QDR_BALANC '1'

#DEFINE ARQ_LOG_EXC		"log_limpa_quadro.log"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCBLC

Manutencao de balancete

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCBLC(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8A')
	oBrowse:SetDescription("DIOPS - Balancete")
	oBrowse:AddLegend( "B8A_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8A_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8A_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "B8A_FILIAL=B3D->B3D_FILIAL .And. B8A_CODOPE=B3D->B3D_CODOPE .And. B8A_CODOBR=B3D->B3D_CDOBRI .And. B8A_ANOCMP=B3D->B3D_ANO .And. B8A_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCBLC' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Balancete", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8A", B8A->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'								 , 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCBLC'					 , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCBLC'					 , 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Excluir registro"		, 'VIEWDEF.PLSMVCBLC'					 , 0 , 5 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDBALT(.F.)'						 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("1")'						 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabBal())'				 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCBLC'					 , 0 , 4 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8A

@return oModel	objeto model criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8A 	:= FWFormStruct( 1, 'B8A', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8AMASTER', 'B8A_CODOPE', 'B8A_CODOBR', 'B8A_CDCOMP', 'B8A_ANOCMP', 'B8A_REFERE', 'B8A_STATUS') }

	oModel := MPFormModel():New( "DIOPS - Balancete", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8AMASTER', NIL , oStruB8A )
	oModel:GetModel( 'B8AMASTER' ):SetDescription( "DIOPS - Balancete" )

	If B8A->(fieldpos("B8A_MESCMP")) > 0
		oModel:SetPrimaryKey({'B8A_FILIAL','B8A_CODOPE','B8A_CODOBR','B8A_ANOCMP','B8A_CDCOMP','B8A_CONTA','B8A_MESCMP'})
	Else 
		oModel:SetPrimaryKey({'B8A_FILIAL','B8A_CODOPE','B8A_CODOBR','B8A_ANOCMP','B8A_CDCOMP','B8A_CONTA'})
	EndIf

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8A

@return oView	objeto view criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'PLSMVCBLC' )
	Local oStruB8A := FWFormStruct( 2, 'B8A' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8A' , oStruB8A , 'B8AMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8A', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8A', 'DIOPS - Balancete' )

	oView:SetFieldAction( 'B8A_SALANT', { |oView, cIDView, cField, xValue| DiGetSal( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction( 'B8A_CREDIT', { |oView, cIDView, cField, xValue| DiGetSal( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction( 'B8A_DEBITO', { |oView, cIDView, cField, xValue| DiGetSal( oView, cIDView, cField, xValue ) } )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegrasBal

Retorna array de regras para validar o balancete

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegBal()

	local aRegrasAll := {}
	local aRegrasBl := {}
	local aRegras := {}

	aAdd( aRegrasAll, {"D001","    ","DIOVLDD001()", "Valor da conta contábil é diferente da somatória das suas sub contas", "Verifique o valor das sub contas e ajuste a diferença", ""} )
	aAdd( aRegrasAll, {"D002","    ","DIOVLDD002()", "Conta contábil é Redutora, o saldo final deverá ser menor ou igual a zero", "Verificar se a conta é Redutora,essas contas tem o sinal (-) que precede o valor do saldo final", ""} )
	aAdd( aRegrasAll, {"D003","    ","DIOVLDD003()", "Conta contábil não prevista no Plano de Contas da ANS", "Verifique este item e envie novamente com a Conta Contábil correta", ""} )
	aAdd( aRegrasAll,  {"D004","    ","DIOVLDD004()", "Balancete não possui um dos grupos contábeis: Ativo, Passivo, Receitas e Despesas", "Verificar no balancete o grupo de contas que está faltando e efetuar a importação novamente", " AND B8A_CONTA IN ('1','2','3','4') " } )
	aAdd( aRegrasAll, {"D005","    ","DIOVLDD005()", "Valor da conta 1-Ativo diferente da somatória das subcontas 12 e 13", "Verifique as subcontas 12 e 13 e também 19 para que esta não seja somado na conta 1-Ativo", " AND B8A_CONTA='1' " } )
	aAdd( aRegrasAll, {"D006","    ","DIOVLDD006()", "Valor da conta 2-Passivo diferente da somatória das subcontas 21, 23 e 25", "Verifique as subcontas 21,23 e 25 e também 29 para que está não seja somado na conta 1-Passivo", " AND B8A_CONTA='2' " } )
	aAdd( aRegrasAll, {"D007","    ","DIOVLDD007()", "Valores da conta Ativo/Despesa inconsistente com o Saldo Final", "Verificar (Sld. Anterior + Débitos - Créditos) diferente do Saldo Final", "" } )
	aAdd( aRegrasAll, {"D008","    ","DIOVLDD008()", "Valores da conta Passivo/Receita inconsistente com o Saldo Final", "Verificar (Sld. Anterior - Débitos + Créditos) diferente do Saldo Final", "" } )

	aRegras := { getTabBal(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabBal

Retorna tabela do quadro

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabBal()
return "B8A"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenLimpBlc

Excluir todos os dados do quadro

@author everton.mateus
@since 09/01/2018
/*/
//--------------------------------------------------------------------------------------------------
function CenLimpBlc(cTabela,lAuto)
	Default lAuto := .F.

	If lAuto .Or. MsgYesNo('Deseja excluir todos os dados do quadro no trimestre ' + SubStr(B3D->B3D_CODIGO,2,2) + ' de ' + B3D->B3D_ANO + ' ? Esse processo não pode ser revertido.','TOTVS')
		If lAuto
			LimpaTabela(cTabela,B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO)
		Else
			Proc2BarGauge( {||LimpaTabela(cTabela,B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO)},"Central de Obrigacoes" ,"Limpeza do dados do DIOPS" ,"Excluindo registros. Aguarde...")
		EndIf
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaTabela
Funcao criada para limpar os dados processados pela central para a obrigacao

@param cTab		Tabela onde serao excluidos os registros
@param cOpe		Codigo da operadora
@param cObri	Codigo da obrigacao
@param cAno		Ano do compromisso
@param cComp	Codigo do compromisso

@author timoteo.bega
@since 17/07/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaTabela(cTab,cCodOpe,cCodObr,cAno,cCDComp)
	Local cSql			:= ""
	Local cMsg 			:= ""
	Local nRet			:= 0

	Default cTab		:= ""
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAno		:= ""
	Default cCDComp		:= ""

	BEGIN TRANSACTION

		cSql := " DELETE FROM " + RetSqlName(cTab) + " "
		cSql += " WHERE "
		cSql += " " + cTab + "_FILIAL='" + xFilial(cTab) + "' "
		cSql += " AND " + cTab + "_CODOPE='" + cCodOpe + "' "
		cSql += " AND " + cTab + "_CODOBR='" + cCodObr + "' "
		cSql += " AND " + cTab + "_ANOCMP='" + cAno + "' "
		cSql += " AND " + cTab + "_CDCOMP='" + cCdComp + "' "
		cSql += " AND D_E_L_E_T_=' ' "

		nRet := TCSQLEXEC(cSql)
		PlsLogFil(CENDTHRL("I") + "Limpando tabela: " + cTab + ". Comando: " + cSql , ARQ_LOG_EXC)
		If nRet >= 0
			TcSQLExec("COMMIT")

			cSql := " DELETE FROM " + RetSqlName('B3F') + " "
			cSql += " WHERE "
			cSql += " B3F_FILIAL='" + xFilial("B3F") + "' "
			cSql += " AND B3F_CODOPE='" + cCodOpe + "' "
			cSql += " AND B3F_CDOBRI='" + cCodObr + "' "
			cSql += " AND B3F_ANO='" + cAno + "' "
			cSql += " AND B3F_CDCOMP='" + cCdComp + "' "
			cSql += " AND B3F_ORICRI = '" + cTab + "' "
			cSql += " AND D_E_L_E_T_=' ' "

			nRet := TCSQLEXEC(cSql)
			PlsLogFil(CENDTHRL("I") + "Limpando tabela: B3F. Comando: " + cSql , ARQ_LOG_EXC)
			If nRet >= 0
				TcSQLExec("COMMIT")
			Else
				cMsg := "Nao conseguiu efetuar a limpeza das críticas."+ CRLF +;
					"Verifique o log na pasta /logpls." + CRLF + ;
					"Codigo de retorno " + AllTrim(Str(nRet)) + ": " + CRLF + ;
					TCSQLError()
			EndIf

		Else
			cMsg := "Nao conseguiu efetuar a limpeza da tabela "+ cTab + "." + CRLF +;
				"Verifique o log na pasta /logpls." + CRLF + ;
				"Codigo de retorno " + AllTrim(Str(nRet)) + ": " + CRLF + ;
				TCSQLError()
		EndIf

		If !Empty(cMsg)
			PlsLogFil(CENDTHRL("E") + cMsg , ARQ_LOG_EXC)
			Alert(cMsg)
		EndIf

	END TRANSACTION

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenVldQdMn
Funcao criada para validar um quadro manualmente

@param cQuadro	Quadro que será validado

@author everton.mateus
@since 10/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenVldQdMn(cQuadro,lAuto)
	default cQuadro := QDR_BALANC
	default lAuto := .F.

	If !lAuto
		MsAguarde({|| LibQuaVal(cQuadro, B3D->B3D_CODOPE,B3D->B3D_ANO,B3D->B3D_REFERE)},"Central de Obrigacoes" ,"Liberando quadro para validação. Aguarde...")
	Else
		LibQuaVal(cQuadro, B3D->B3D_CODOPE,B3D->B3D_ANO,B3D->B3D_REFERE)
	EndIf

	If !lAuto .And. MsgYesNo('Deseja executar a validação em segundo plano (via Job)?','TOTVS')
		AVISO('A validação será executada via JOB','Dentro de instantes o Status dos registros serão atualizados',{'OK'})"
		MsAguarde( {||PLJVALDIOP( B3D->B3D_CODOPE, cQuadro )},"Central de Obrigacoes" ,"Iniciando Jobs. Aguarde...")
	Else
		lLiberado := cQuadro == QDR_BALANC .OR. EstaLiberado(B3D->B3D_CODOPE,cQuadro)
		If lLiberado
			If !lAuto
				MsAguarde( {||validComQDIOPS( B3D->B3D_CODOPE, B3D->B3D_CODIGO, cQuadro, B3D->B3D_CDOBRI, B3D->B3D_ANO )},"Central de Obrigacoes" ,"Validando registros. Aguarde...")
				MsgInfo("Validação concluída")
			Else
				EstaLiberado(B3D->B3D_CODOPE,cQuadro)
				validComQDIOPS( B3D->B3D_CODOPE, B3D->B3D_CODIGO, cQuadro, B3D->B3D_CDOBRI, B3D->B3D_ANO )
			EndIf
		Else
			Alert("O quadro ainda não foi liberado para validação.")
		EndIf
	EndIf
Return lAuto

Static Function EstaLiberado(cCodOpe,cQuadro)
	Local lLiberado := .F.

	If ExisteB8X(cCodOpe,cQuadro)
		lLiberado := TRBB8X->B8X_RECEBI == '1' .AND. TRBB8X->B8X_VALIDA == '1'
	Else
		lLiberado:=CriaB8X(cCodOpe,B3D->B3D_ANO,B3D->B3D_CODIGO,B3D->B3D_CDOBRI,cQuadro)
		If lLiberado
			LibQuaVal(cQuadro, B3D->B3D_CODOPE,B3D->B3D_ANO,B3D->B3D_REFERE)
		EndIf
	EndIf
	TRBB8X->(dbCloseArea())
Return lLiberado

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteB8X
Funcao criada para validar um quadro manualmente

@param cQuadro	Quadro que será validado

@author everton.mateus
@since 10/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function ExisteB8X(cCodOpe,cQuadro)
	Local lLiberado := .F.
	Default cCodOpe := ""
	Default cQuadro := ""

	cSql := " SELECT "
	cSql += " 	B8X_CODOPE, B8X_CDCOMP, B8X_CODOBR, B8X_ANOCMP, B8X_QUADRO, B8X_RECEBI, B8X_VALIDA "
	cSql += " FROM " + RetSqlName("B8X") + " "
	cSql += " WHERE "
	cSql += " 	B8X_FILIAL = '" + xFilial("B8X") + "' "
	cSql += " 	AND B8X_CODOPE = '" + cCodOpe + "' "
	cSql += " 	AND B8X_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " 	AND B8X_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " 	AND B8X_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " 	AND B8X_QUADRO = '" + cQuadro + "'  "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8X_CODOPE,B8X_CODOBR,B8X_ANOCMP,B8X_CDCOMP,B8X_QUADRO "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB8X",.F.,.T.)

	lLiberado := !TRBB8X->(Eof())

Return lLiberado

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaB8X
Funcao criada para criar um quadro manualmente

@param cQuadro	Quadro que será validado

@author jose.paulo
@since 19/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CriaB8X(cCodOpe,cAnoCmp,cCdComp,cCodObr,cQuadro)
	Local aQuadros		:= getQuadrosDiops()
	Local lRetorno		:= .F.
	Default cCodOpe	    := ""
	Default cCodObr	    := ""
	Default cCdComp	    := ""
	Default cAnoCmp	    := ""
	Default cQuadro     := ""

	If Len(aQuadros) >= 1 .And. Ascan(aQuadros,{ |x| x[1] == cQuadro})

		lRetorno := .T.
		GravaB8X(cCodOpe,cCodObr,cCdComp,cAnoCmp,cQuadro)

	EndIf

Return lRetorno

/*/{Protheus.doc} DiGetSal
	Calcula o valor do saldo a partir dos valores de saldo anterior, crédito e débito e do tipo da conta contábil.
	@type  Function
	@author p.drivas
	@since 12/03/2020
	@version 00
	@param
	@return nSaldo, numeric, saldo calculado
/*/
Static Function DiGetSal( oView, cIDView, cField, xValue )

	Local oModel	:= FWModelActive()
	Local oModelB8A := oModel:GetModel( 'B8AMASTER' )
	Local aNegativo := DiCntRed()
	Local cCodConta := AllTrim(oModelB8A:GetValue("B8A_CONTA"))
	Local nSaldoAnt := oModelB8A:GetValue("B8A_SALANT")
	Local nDebitos  := oModelB8A:GetValue("B8A_DEBITO")
	Local nCreditos := oModelB8A:GetValue("B8A_CREDIT")
	Local aArea     := GetArea()

	FwFldPut("B8A_SALFIN", Iif( ASCAN(aNegativo, { |x| AllTrim(x) == cCodConta }) == 0, nSaldoAnt + nCreditos - nDebitos, nSaldoAnt - nCreditos + nDebitos ))
		oview:Refresh( 'VIEW_B8A' )

	RestArea(aArea)

Return .T.
