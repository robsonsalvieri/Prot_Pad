#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#INCLUDE "AGDA032.CH"

STATIC cAliasTmp
STATIC oTempTable

#DEFINE CONTRATO_ACL_VINCULAR_SERVICE agd.ContratoAclVincularService.agdContratoAclVincularService
#DEFINE REPOSITORY_UTILS agd.repositoryUtils.agdRepositoryUtils
#DEFINE ID_SERVICE agd.idService.agdIdService
#DEFINE CONTRATO_ACL_VINCULAR_REPOSITORY agd.contratovincularrepository.agdcontratovincularrepository
#DEFINE CONTRATO_ACL_SERVICE agd.contratoAclService.agdContratoAclService


/*/{Protheus.doc} AGDA032
Tela Contratos a Vincular
@type function
@version P12 
@author scheronlini.martins
@since 24/04/2025
@return variant, return_nil
/*/
Function AGDA032()
	Local oBrowse	:= nil
	Local aColunas 	:= {}
	Local aPesquisa := {}

	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Reinicia definicao em cada execucao
	oTempTable := nil

	if empty(AGDA032VLD())

		AGDA032TMP()

		AGDA032INS()

//Definindo as colunas que serão usadas no browse
		aAdd(aColunas, {Fwx3Titulo('NEE_FILIAL'), 'NJR_FILIAL', TAMSX3('NEE_FILIAL')[3], TAMSX3('NEE_FILIAL')[1], TAMSX3('NEE_FILIAL')[2], PESQPICT('NEE', 'NEE_FILIAL')})
		aAdd(aColunas, {Fwx3Titulo('NJR_CODCTR'), 'NJR_CODCTR', TAMSX3('NJR_CODCTR')[3], TAMSX3('NJR_CODCTR')[1], TAMSX3('NJR_CODCTR')[2], PESQPICT('NJR', 'NJR_CODCTR')})
		aAdd(aColunas, {Fwx3Titulo('NEE_CDPROP'), 'NJR_CODENT', TAMSX3('NEE_CDPROP')[3], TAMSX3('NEE_CDPROP')[1], TAMSX3('NEE_CDPROP')[2], PESQPICT('NEE', 'NEE_CDPROP')})
		aAdd(aColunas, {Fwx3Titulo('NEE_LJPROP'), 'NJR_LOJENT', TAMSX3('NEE_LJPROP')[3], TAMSX3('NEE_LJPROP')[1], TAMSX3('NEE_LJPROP')[2], PESQPICT('NEE', 'NEE_LJPROP')})
		aAdd(aColunas, {Fwx3Titulo('NEE_NMPROP'), 'NJ0_NOME',   TAMSX3('NEE_NMPROP')[3], TAMSX3('NEE_NMPROP')[1], TAMSX3('NEE_NMPROP')[2], PESQPICT('NEE', 'NEE_NMPROP')})
		aAdd(aColunas, {Fwx3Titulo('NJR_QTDCTR'), 'NJR_QTDCTR', TAMSX3('NJR_QTDCTR')[3], TAMSX3('NJR_QTDCTR')[1], TAMSX3('NJR_QTDCTR')[2], PESQPICT('NJR', 'NJR_QTDCTR')})
		aAdd(aColunas, {Fwx3Titulo('NEE_QTDSAC'), 'NEE_QTDSAC', TAMSX3('NEE_QTDSAC')[3], TAMSX3('NEE_QTDSAC')[1], TAMSX3('NEE_QTDSAC')[2], PESQPICT('NEE', 'NEE_QTDSAC')})
		aAdd(aColunas, {Fwx3Titulo('NEE_OPEFIS'), 'NJR_OPEFIS', TAMSX3('NEE_OPEFIS')[3], TAMSX3('NEE_OPEFIS')[1], TAMSX3('NEE_OPEFIS')[2], PESQPICT('NEE', 'NEE_OPEFIS')})
		aAdd(aColunas, {Fwx3Titulo('NEE_INIENT'), 'NNY_DATINI', TAMSX3('NEE_INIENT')[3], TAMSX3('NEE_INIENT')[1], TAMSX3('NEE_INIENT')[2], PESQPICT('NEE', 'NEE_INIENT')})
		aAdd(aColunas, {Fwx3Titulo('NEE_FIMENT'), 'NNY_DATFIM', TAMSX3('NEE_FIMENT')[3], TAMSX3('NEE_FIMENT')[1], TAMSX3('NEE_FIMENT')[2], PESQPICT('NEE', 'NEE_FIMENT')})
		aAdd(aColunas, {Fwx3Titulo('NEE_CONDPG'), 'NJR_CONDPG', TAMSX3('NEE_CONDPG')[3], TAMSX3('NEE_CONDPG')[1], TAMSX3('NEE_CONDPG')[2], PESQPICT('NEE', 'NEE_CONDPG')})
		aAdd(aColunas, {Fwx3Titulo('NEE_DESPG' ), 'E4_DESCRI',  TAMSX3('NEE_DESPG' )[3], TAMSX3('NEE_DESPG' )[1], TAMSX3('NEE_DESPG' )[2], PESQPICT('NEE', 'NEE_DESPG' )})
		aAdd(aColunas, {Fwx3Titulo('NEE_TPFRET'), 'NJR_TPFRET', TAMSX3('NEE_TPFRET')[3], TAMSX3('NEE_TPFRET')[1], TAMSX3('NEE_TPFRET')[2], PESQPICT('NEE', 'NEE_TPFRET')})
		aAdd(aColunas, {Fwx3Titulo('NEE_TABELA'), 'NJR_TABELA', TAMSX3('NEE_TABELA')[3], TAMSX3('NEE_TABELA')[1], TAMSX3('NEE_TABELA')[2], PESQPICT('NEE', 'NEE_TABELA')})
		aAdd(aColunas, {Fwx3Titulo('NNI_DESCRI'), 'NNI_DESCRI', TAMSX3('NNI_DESCRI')[3], TAMSX3('NNI_DESCRI')[1], TAMSX3('NNI_DESCRI')[2], PESQPICT('NNI', 'NNI_DESCRI')})
		aAdd(aColunas, {Fwx3Titulo('NEE_NATURE'), 'NN7_NATURE', TAMSX3('NEE_NATURE')[3], TAMSX3('NEE_NATURE')[1], TAMSX3('NEE_NATURE')[2], PESQPICT('NEE', 'NEE_NATURE')})
		aAdd(aColunas, {Fwx3Titulo('NEE_CODSAF'), 'NJR_CODSAF', TAMSX3('NEE_CODSAF')[3], TAMSX3('NEE_CODSAF')[1], TAMSX3('NEE_CODSAF')[2], PESQPICT('NEE', 'NEE_CODSAF')})
		aAdd(aColunas, {Fwx3Titulo('NJR_DESCRI'), 'NJR_DESCRI', TAMSX3('NJR_DESCRI')[3], TAMSX3('NJR_DESCRI')[1], TAMSX3('NJR_DESCRI')[2], PESQPICT('NJR', 'NJR_DESCRI')})
		aAdd(aColunas, {Fwx3Titulo('NJR_DATA'  ), 'NJR_DATA',   TAMSX3('NJR_DATA'  )[3], TAMSX3('NJR_DATA'  )[1], TAMSX3('NJR_DATA'  )[2], PESQPICT('NJR', 'NJR_DATA'  )})


//Adiciona os indices para pesquisar
    /*
        [n,1] Título da pesquisa
        [n,2,n,1] LookUp
        [n,2,n,2] Tipo de dados
        [n,2,n,3] Tamanho
        [n,2,n,4] Decimal
        [n,2,n,5] Título do campo
        [n,2,n,6] Máscara
        [n,2,n,7] Nome Físico do campo - Opcional - é ajustado no programa
        [n,3] Ordem da pesquisa
        [n,4] Exibe na pesquisa
    */
		aAdd(aPesquisa, {'Contrato', {{"", "C", 6, 0, 'Contrato', "", 'NJR_CODCTR'}} } )

//Criando o browse da temporária
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias(cAliasTmp)
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFields(aColunas)
		oBrowse:SetDescription(STR0001) //"Contratos a Vincular"
		oBrowse:SetSeek(.T., aPesquisa)
		oBrowse:Activate()

	endif

	If ValType(oTempTable) == "O"
		oTempTable:Delete()
	EndIf

Return Nil

/*/{Protheus.doc} MenuDef
Menu da tela Contratos a Vincular
@type function
@version P12 
@author scheronlini.martins
@since 24/04/2025
@return array, return aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Confirmar" ACTION "AGDA032CFM(.T.)" OPERATION 2 ACCESS 0


Return aRotina

/*/{Protheus.doc} AGDA032VLD
Faz a validação para o vinculo do contrato
@type function
@version P12
@author scheronlini.martins
@since 15/08/2025
@return variant, return_string vazia
/*/
function AGDA032VLD()
	Local oServVinc  := CONTRATO_ACL_VINCULAR_SERVICE():New()

	If NEA->NEA_STSAUT != "2"
		oServVinc:setError(STR0004, 404)
		AGDHELP(STR0003,STR0004, STR0005) //### "Negociação com autorização não liberada.", "Será necessário aprovar a autorização da negociação para vincular contrato de compra." )
		Return oServVinc:getMessageError()
	ElseIf !(NEA->NEA_STATUS $ ('1|2') )
		oServVinc:setError(STR0006, 404)
		AGDHELP(STR0003,STR0006, STR0007) //##"Status da negociação não permite vincular contrato","Verifique o status da negociação." )
		Return oServVinc:getMessageError()
	EndIf

	If oServVinc:getSaldoAVincularNEE(NEA->NEA_CODIGO, NEA->NEA_VERSAO) <= 0
		oServVinc:setError(STR0002, 404)
		AGDHELP(STR0003, STR0002 ) //#"Esta negociação não possui saldo a vincular para o contrato, favor verificar!"
		Return oServVinc:getMessageError()
	EndIf

Return ""

/*/{Protheus.doc} AGDA032INS
Popula a tabela temporária
@type function
@version P12 
@author scheronlini.martins
@since 24/04/2025
/*/
Function AGDA032INS(lTela,cCodigoContratoext)
	Local cQryDados := ''
	Local nConverte := 0
	Local nQtdUMPrc := 0
	Local CQryDadTMP := ""
	Local lContrato
	Local oRepoVinc := CONTRATO_ACL_VINCULAR_REPOSITORY():new()
	Default lTela := .t.
	Default cCodigoContratoext := ""

	lContrato:= !lTela
	//Monta a consulta

	cQryDados := oRepoVinc:qryContratosOGVinculo(lContrato,cCodigoContratoext)

	CQryDadTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryDados),CQryDadTMP,.T.,.T.)

	DbSelectArea(CQryDadTMP)
	(CQryDadTMP)->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! (CQryDadTMP)->(EoF())
		nConverte := AGRX001((CQryDadTMP)->NJR_UM1PRO,(CQryDadTMP)->NJR_UMPRC,1,(CQryDadTMP)->NJR_CODPRO)
		nQtdUMPrc := round(((CQryDadTMP)->NJR_QTDCTR * nConverte), TamSX3("NEE_QTDSAC")[2])

		RecLock(cAliasTmp, .T.)

		(cAliasTmp)->NJR_FILIAL := (CQryDadTMP)->NJR_FILIAL
		(cAliasTmp)->NJR_CODCTR := (CQryDadTMP)->NJR_CODCTR
		(cAliasTmp)->NJR_CODENT := (CQryDadTMP)->NJR_CODENT
		(cAliasTmp)->NJR_LOJENT := (CQryDadTMP)->NJR_LOJENT
		(cAliasTmp)->NJ0_NOME   := (CQryDadTMP)->NJ0_NOME
		(cAliasTmp)->NJR_QTDCTR := (CQryDadTMP)->NJR_QTDCTR
		(cAliasTmp)->NEE_QTDSAC := nQtdUMPrc
		(cAliasTmp)->NJR_TESEST := (CQryDadTMP)->NJR_TESEST
		(cAliasTmp)->NJR_OPEFIS := (CQryDadTMP)->NJR_OPEFIS
		(cAliasTmp)->NNY_DATINI := STOD((CQryDadTMP)->NNY_DATINI)
		(cAliasTmp)->NNY_DATFIM := STOD((CQryDadTMP)->NNY_DATFIM)
		(cAliasTmp)->NJR_CONDPG := (CQryDadTMP)->NJR_CONDPG
		(cAliasTmp)->E4_DESCRI  := (CQryDadTMP)->E4_DESCRI
		(cAliasTmp)->NJR_TPFRET := (CQryDadTMP)->NJR_TPFRET
		(cAliasTmp)->NJR_TABELA := (CQryDadTMP)->NJR_TABELA
		(cAliasTmp)->NNI_DESCRI := (CQryDadTMP)->NNI_DESCRI
		(cAliasTmp)->NN7_NATURE := (CQryDadTMP)->NN7_NATURE
		(cAliasTmp)->NJR_CODSAF := (CQryDadTMP)->NJR_CODSAF
		(cAliasTmp)->NJR_DESCRI := (CQryDadTMP)->NJR_DESCRI
		(cAliasTmp)->NJR_DATA	:= STOD((CQryDadTMP)->NJR_DATA)

		(cAliasTmp)->(MsUnlock())

		(CQryDadTMP)->(DbSkip())
	EndDo
	(CQryDadTMP)->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} AGDA032CFM
Confirma e vincula os contratos nas tabelas NEF, NEI, NEE
@type function
@version P12 
@author scheronlini.martins
@since 30/04/2025
/*/
function AGDA032CFM(lTela)
	Local aNEF       := {}
	Local aNEE       := {}
	Local aNEI       := {}
	Local oServVinc  := CONTRATO_ACL_VINCULAR_SERVICE():New()
	Local oContratoACLService  := CONTRATO_ACL_SERVICE():New()
	Local cQuery     := ""
	Local oStatem    := nil
	Local oStateNEI  := NIL
	Local oStaNEISEQ := NIL
	Local cQueryNEI  := ""
	Local cItemNEF	 := ""
	Local nQuant 	 := 0
	Local cSeqNEI	 := ""
	Local cTipo		 := ''
	Local cAliNEI 	 := ""
	Local lRet       := .T.
	Local oIdService := ID_SERVICE():New()
	Local cIdContrato := oIdService:encode({ (cAliasTmp)->NJR_FILIAL, (cAliasTmp)->NJR_CODCTR })

	oServVinc:validarContrato((cAliasTmp)->NJR_FILIAL, (cAliasTmp)->NJR_CODCTR)
	If !oServVinc:isSuccess()
		AGDHELP(STR0003, oServVinc:getMessageError()) //"Ajuda"
		Return .F.
	EndIf

	Begin Transaction
		cQuery := "SELECT MAX(NEE_ITEM) AS NEE_ITEM "
		cQuery += " FROM "+ retSqlName('NEE') +" NEE "
		cQuery += " WHERE NEE_FILIAL = ? AND NEE_CODBRT = ?  "
		cQuery += " AND NEE_VERSAO = ? "
		cQuery += " AND NEE.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery( cQuery )

		oStatem := FWPreparedStatement():New()
		oStatem:SetQuery(cQuery)
		oStatem:SetString(1, FWxFilial('NEE'))
		oStatem:SetString(2, NEA->NEA_CODIGO)
		oStatem:SetString(3, NEA->NEA_VERSAO)
		cQuery := oStatem:GetFixQuery()

		cItemNEE := MPSysExecScalar(cQuery,"NEE_ITEM")
		cItemNEE := STRZERO((GetDToVal(cItemNEE) + 1),TAMSX3("NEE_ITEM")[1])

		aAdd(aNEE,{"NEE_FILIAL",	fwXFilial("NEE")})
		aAdd(aNEE,{"NEE_CODBRT",	NEA->NEA_CODIGO })
		aAdd(aNEE,{"NEE_VERSAO",	NEA->NEA_VERSAO })
		aAdd(aNEE,{"NEE_ITEM",  	cItemNEE })
		aAdd(aNEE,{"NEE_CDPROP",	(cAliasTmp)->NJR_CODENT })
		aAdd(aNEE,{"NEE_LJPROP",	(cAliasTmp)->NJR_LOJENT })
		aAdd(aNEE,{"NEE_NMPROP",	(cAliasTmp)->NJ0_NOME   })
		aAdd(aNEE,{"NEE_QTDSAC",	oServVinc:getQuantidadePermitidaAVincularNEE(NEA->NEA_CODIGO, NEA->NEA_VERSAO,(cAliasTmp)->NEE_QTDSAC) })
		aAdd(aNEE,{"NEE_QTCONV",	oServVinc:getQuantidadeConvertidaPermitidaAVincularNEE(NEA->NEA_CODIGO, NEA->NEA_VERSAO,(cAliasTmp)->NJR_QTDCTR) })
		aAdd(aNEE,{"NEE_TESCTR",	(cAliasTmp)->NJR_TESEST })
		aAdd(aNEE,{"NEE_OPEFIS",	(cAliasTmp)->NJR_OPEFIS })
		aAdd(aNEE,{"NEE_INIENT",	(cAliasTmp)->NNY_DATINI })
		aAdd(aNEE,{"NEE_FIMENT",	(cAliasTmp)->NNY_DATFIM })
		aAdd(aNEE,{"NEE_CONDPG",	(cAliasTmp)->NJR_CONDPG })
		aAdd(aNEE,{"NEE_DESPG" ,	(cAliasTmp)->E4_DESCRI  })
		aAdd(aNEE,{"NEE_TPFRET",	(cAliasTmp)->NJR_TPFRET })
		aAdd(aNEE,{"NEE_TABELA",	(cAliasTmp)->NJR_TABELA })
		aAdd(aNEE,{"NEE_NATURE",	(cAliasTmp)->NN7_NATURE })
		aAdd(aNEE,{"NEE_CODSAF",	(cAliasTmp)->NJR_CODSAF })

		oServVinc:vincularContratoNEE(aNEE)

		If oServVinc:isSuccess()

			cItemNEF := oContratoACLService:getProximaSequenciaNEF(NEA->NEA_CODIGO, cItemNEE)

			aAdd(aNEF,{"NEF_FILIAL",	fwXFilial("NEF")})
			aAdd(aNEF,{"NEF_CODBRT",	NEA->NEA_CODIGO})
			aAdd(aNEF,{"NEF_ITECTR",	cItemNEE})
			aAdd(aNEF,{"NEF_ITEM",  	cItemNEF})
			aAdd(aNEF,{"NEF_QUANT", 	(cAliasTmp)->NJR_QTDCTR})
			aAdd(aNEF,{"NEF_CTREXT",	(cAliasTmp)->NJR_CODCTR})
			aAdd(aNEF,{"NEF_IDCTR", 	cIdContrato })
			aAdd(aNEF,{"NEF_VINCTR",	"1"})

			oServVinc:vincularContratoNEF(aNEF)

			If oServVinc:isSuccess()

				cQueryNEI:= "SELECT SD1.D1_TIPO AS TIPO,SD1.D1_DOC AS DOC_NF, SD1.D1_SERIE AS SERIE_NF, SD1.D1_ITEM AS ITEM_NF, SD1.D1_QUANT AS QUANT, SD1.D1_FORNECE AS FORNECE, SD1.D1_LOJA AS LOJA, SD1.D1_EMISSAO AS EMISSAO "
				cQueryNEI+= " FROM "+ retSqlName('NJJ') +" NJJ   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJM') +" NJM ON NJM_CODROM = NJJ_CODROM AND NJJ_FILIAL = NJM_FILIAL AND NJM.D_E_L_E_T_ = ''   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJ0') +" NJ0 ON NJ0_CODENT = NJM_CODENT AND NJ0_LOJENT = NJM_LOJENT  "
				cQueryNEI+= " INNER JOIN "+ retSqlName('SD1') +" SD1 ON NJM_DOCNUM = D1_DOC AND NJM_DOCSER = D1_SERIE "
				cQueryNEI+= " 	AND D1_FORNECE = NJ0_CODFOR AND D1_LOJA = NJ0_LOJFOR AND  SD1.D_E_L_E_T_ = ''  "
				cQueryNEI+= " 	AND D1_TIPO = 'N'  AND SD1.D1_COD = NJM_CODPRO "
				cQueryNEI+= " WHERE NJJ.D_E_L_E_T_ = '' AND NJJ_TIPO = '5' AND NJJ_FILIAL = ? AND NJJ_CODCTR = ? "
				cQueryNEI+= " UNION "
				cQueryNEI+= " SELECT SD1C.D1_TIPO AS TIPO,SD1C.D1_DOC AS DOC_NF, SD1C.D1_SERIE AS SERIE_NF, SD1C.D1_ITEM AS ITEM_NF, SD1C.D1_QUANT AS QUANT, SD1C.D1_FORNECE AS FORNEC, SD1C.D1_LOJA AS LOJA, SD1C.D1_EMISSAO AS EMISSAO "
				cQueryNEI+= " FROM "+ retSqlName('NJJ') +" NJJ   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJM') +" NJM ON NJM_CODROM = NJJ_CODROM AND NJJ_FILIAL = NJM_FILIAL AND NJM.D_E_L_E_T_ = ''   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJ0') +" NJ0 ON NJ0_CODENT = NJM_CODENT AND NJ0_LOJENT = NJM_LOJENT  "
				cQueryNEI+= " INNER JOIN "+ retSqlName('SD1') +" SD1 ON NJM_DOCNUM = D1_DOC AND NJM_DOCSER = D1_SERIE AND D1_FORNECE = NJ0_CODFOR AND D1_LOJA = NJ0_LOJFOR AND  SD1.D_E_L_E_T_ = ''  "
				cQueryNEI+= " 	AND D1_TIPO = 'N'  AND SD1.D1_COD = NJM_CODPRO "
				cQueryNEI+= " INNER JOIN "+ retSqlName('SD1') +" SD1C ON SD1C.D1_NFORI = SD1.D1_DOC AND SD1C.D1_SERIORI = SD1.D1_SERIE AND SD1.D1_FORNECE = SD1C.D1_FORNECE AND SD1.D1_LOJA = SD1C.D1_LOJA  "
				cQueryNEI+= " 	AND  SD1C.D_E_L_E_T_ = ''AND SD1C.D1_TIPO = 'C'  AND SD1C.D1_COD = SD1.D1_COD "
				cQueryNEI+= " WHERE NJJ.D_E_L_E_T_ = '' AND NJJ_TIPO = '5' AND NJJ_FILIAL = ? AND NJJ_CODCTR = ? "
				cQueryNEI+= " UNION "
				cQueryNEI+= " SELECT SD2.D2_TIPO AS TIPO,SD2.D2_DOC AS DOC_NF, SD2.D2_SERIE AS SERIE_NF, SD2.D2_ITEM AS ITEM_NF, SD2.D2_QUANT AS QUANT, SD2.D2_CLIENTE AS FORNEC, SD2.D2_LOJA AS LOJA, SD2.D2_EMISSAO AS EMISSAO "
				cQueryNEI+= " FROM "+ retSqlName('NJJ') +" NJJ   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJM') +" NJM ON NJM_CODROM = NJJ_CODROM AND NJJ_FILIAL = NJM_FILIAL AND NJM.D_E_L_E_T_ = ''   "
				cQueryNEI+= " INNER JOIN "+ retSqlName('NJ0') +" NJ0 ON NJ0_CODENT = NJM_CODENT AND NJ0_LOJENT = NJM_LOJENT  "
				cQueryNEI+= " INNER JOIN "+ retSqlName('SD1') +" SD1 ON NJM_DOCNUM = D1_DOC AND NJM_DOCSER = D1_SERIE AND D1_FORNECE = NJ0_CODFOR AND D1_LOJA = NJ0_LOJFOR AND  SD1.D_E_L_E_T_ = ''  "
				cQueryNEI+= " 	AND D1_TIPO = 'N'  AND SD1.D1_COD = NJM_CODPRO "
				cQueryNEI+= " INNER JOIN "+ retSqlName('SD2') +" SD2 ON SD2.D2_NFORI = SD1.D1_DOC AND SD2.D2_SERIORI = SD1.D1_SERIE AND SD2.D2_CLIENTE = SD1.D1_FORNECE "
				cQueryNEI+= " 	AND SD2.D2_LOJA = SD1.D1_LOJA AND  SD2.D_E_L_E_T_ = '' AND SD2.D2_TIPO = 'D' AND SD2.D2_COD = SD1.D1_COD "
				cQueryNEI+= " WHERE NJJ.D_E_L_E_T_ = '' AND NJJ_TIPO = '5' AND NJJ_FILIAL = ? AND NJJ_CODCTR = ?  "
				cQueryNEI+= " ORDER BY EMISSAO, DOC_NF "
				cQueryNEI := ChangeQuery( cQueryNEI )

				oStateNEI := FWPreparedStatement():New()
				oStateNEI:SetQuery(cQueryNEI)
				oStateNEI:SetString(1, FWxFilial('NJJ'))
				oStateNEI:SetString(2,(cAliasTmp)->NJR_CODCTR)
				oStateNEI:SetString(3, FWxFilial('NJJ'))
				oStateNEI:SetString(4,(cAliasTmp)->NJR_CODCTR)
				oStateNEI:SetString(5, FWxFilial('NJJ'))
				oStateNEI:SetString(6,(cAliasTmp)->NJR_CODCTR)
				cQueryNEI := oStateNEI:GetFixQuery()

				cAliNEI := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryNEI),cAliNEI,.T.,.T.)

				While !(cAliNEI)->(Eof())

					if (cAliNEI)->TIPO == 'N'
						cTipo:= '1'
						nQuant := (cAliNEI)->QUANT
					elseif (cAliNEI)->TIPO == 'C'
						cTipo:= '3'
						nQuant := (cAliNEI)->QUANT
					elseif (cAliNEI)->TIPO == 'D'
						cTipo:= '2'
						nQuant := -(cAliNEI)->QUANT
					ENDIF

					cQuery := "SELECT MAX(NEI_SEQ) AS NEI_SEQ"
					cQuery += " FROM "+ retSqlName('NEI') +" NEI "
					cQuery += " WHERE NEI_FILIAL = ? AND NEI_CODCTR = ?  "
					cQuery += " AND NEI.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery( cQuery )

					oStaNEISEQ := FWPreparedStatement():New()
					oStaNEISEQ:SetQuery(cQuery)
					oStaNEISEQ:SetString(1, FWxFilial('NEI'))
					oStaNEISEQ:SetString(2,(cAliasTmp)->NJR_CODCTR)
					cQuery := oStaNEISEQ:GetFixQuery()

					cSeqNEI := MPSysExecScalar(cQuery,"NEI_SEQ")
					cSeqNEI := Soma1(cSeqNEI)

					aAdd(aNEI,{"NEI_FILIAL", 	fwXFilial("NEI")})
					aAdd(aNEI,{"NEI_CODCTR",	(cAliasTmp)->NJR_CODCTR })
					aAdd(aNEI,{"NEI_SEQ", 		cSeqNEI })
					aAdd(aNEI,{"NEI_DOC", 		(cAliNEI)->DOC_NF })
					aAdd(aNEI,{"NEI_SERIE", 	(cAliNEI)->SERIE_NF })
					aAdd(aNEI,{"NEI_FORNEC", 	(cAliNEI)->FORNECE })
					aAdd(aNEI,{"NEI_LOJA", 		(cAliNEI)->LOJA })
					aAdd(aNEI,{"NEI_ITEM", 		(cAliNEI)->ITEM_NF })
					aAdd(aNEI,{"NEI_TIPO", 		cTipo })
					aAdd(aNEI,{"NEI_IDCTR", 	cIdContrato })
					aAdd(aNEI,{"NEI_QUANT", 	nQuant})
					oServVinc:vincularContratoNEI(aNEI)
					aNEI:= {}
					(cAliNEI)->(DBSkip())
					If !oServVinc:isSuccess()
						(cAliNEI)->(DBCloseArea())
						DisarmTransaction()
						lRet := .f.
						AGDHELP(STR0003, oServVinc:getMessageError()) //"Ajuda"
						BREAK
					EndIf
				EndDo
				(cAliNEI)->(DBCloseArea())
			else
				DisarmTransaction()
				lRet := .f.
				AGDHELP(STR0003, oServVinc:getMessageError()) //"Ajuda"
				BREAK
			EndIf

		else
			DisarmTransaction()
			lRet := .f.
			AGDHELP(STR0003, oServVinc:getMessageError()) //"Ajuda"
			BREAK
		EndIf
			AGDGRAVAHIS("","NEA", NEA->(NEA_FILIAL+NEA_CODIGO+NEA_VERSAO) + " Contrato: " + AllTrim(NEF->(NEF_CTREXT)), STR0008 ,.F., "") //"VINCULAR"
	End Transaction

	if lTela
		CloseBrowse()
	else
		oTempTable:Delete()
	EndIf


return lRet

/*/{Protheus.doc} AGDA032TMP
Função cria a tabela temporaria
@type function
@version  P12
@author scheronlini.martins
@since 15/08/2025
@return variant, return_alias da tabela
/*/
function AGDA032TMP()
	Local aCampos 	:= {}

	cAliasTmp := GetNextAlias()

	//Campos da temporária
	aAdd(aCampos, { 'NJR_FILIAL', TAMSX3('NEE_FILIAL')[3], TAMSX3('NEE_FILIAL')[1], TAMSX3('NEE_FILIAL')[2]})
	aAdd(aCampos, { 'NJR_CODCTR', TAMSX3('NJR_CODCTR')[3], TAMSX3('NJR_CODCTR')[1], TAMSX3('NJR_CODCTR')[2]})
	aAdd(aCampos, { 'NJR_CODENT', TAMSX3('NEE_CDPROP')[3], TAMSX3('NEE_CDPROP')[1], TAMSX3('NEE_CDPROP')[2]})
	aAdd(aCampos, { 'NJR_LOJENT', TAMSX3('NEE_LJPROP')[3], TAMSX3('NEE_LJPROP')[1], TAMSX3('NEE_LJPROP')[2]})
	aAdd(aCampos, { 'NJ0_NOME',   TAMSX3('NEE_NMPROP')[3], TAMSX3('NEE_NMPROP')[1], TAMSX3('NEE_NMPROP')[2]})
	aAdd(aCampos, { 'NJR_QTDCTR', TAMSX3('NJR_QTDCTR')[3], TAMSX3('NJR_QTDCTR')[1], TAMSX3('NJR_QTDCTR')[2]})
	aAdd(aCampos, { 'NEE_QTDSAC', TAMSX3('NEE_QTDSAC')[3], TAMSX3('NEE_QTDSAC')[1], TAMSX3('NEE_QTDSAC')[2]})
	aAdd(aCampos, { 'NJR_TESEST', TAMSX3('NEE_TESCTR')[3], TAMSX3('NEE_TESCTR')[1], TAMSX3('NEE_TESCTR')[2]})
	aAdd(aCampos, { 'NJR_OPEFIS', TAMSX3('NEE_OPEFIS')[3], TAMSX3('NEE_OPEFIS')[1], TAMSX3('NEE_OPEFIS')[2]})
	aAdd(aCampos, { 'NNY_DATINI', TAMSX3('NEE_INIENT')[3], TAMSX3('NEE_INIENT')[1], TAMSX3('NEE_INIENT')[2]})
	aAdd(aCampos, { 'NNY_DATFIM', TAMSX3('NEE_FIMENT')[3], TAMSX3('NEE_FIMENT')[1], TAMSX3('NEE_FIMENT')[2]})
	aAdd(aCampos, { 'NJR_CONDPG', TAMSX3('NEE_CONDPG')[3], TAMSX3('NEE_CONDPG')[1], TAMSX3('NEE_CONDPG')[2]})
	aAdd(aCampos, { 'E4_DESCRI',  TAMSX3('NEE_DESPG' )[3], TAMSX3('NEE_DESPG' )[1], TAMSX3('NEE_DESPG' )[2]})
	aAdd(aCampos, { 'NJR_TPFRET', TAMSX3('NEE_TPFRET')[3], TAMSX3('NEE_TPFRET')[1], TAMSX3('NEE_TPFRET')[2]})
	aAdd(aCampos, { 'NJR_TABELA', TAMSX3('NEE_TABELA')[3], TAMSX3('NEE_TABELA')[1], TAMSX3('NEE_TABELA')[2]})
	aAdd(aCampos, { 'NNI_DESCRI', TAMSX3('NNI_DESCRI')[3], TAMSX3('NNI_DESCRI')[1], TAMSX3('NNI_DESCRI')[2]})
	aAdd(aCampos, { 'NN7_NATURE', TAMSX3('NEE_NATURE')[3], TAMSX3('NEE_NATURE')[1], TAMSX3('NEE_NATURE')[2]})
	aAdd(aCampos, { 'NJR_CODSAF', TAMSX3('NEE_CODSAF')[3], TAMSX3('NEE_CODSAF')[1], TAMSX3('NEE_CODSAF')[2]})
	aAdd(aCampos, { 'NJR_DESCRI', TAMSX3('NJR_DESCRI')[3], TAMSX3('NJR_DESCRI')[1], TAMSX3('NJR_DESCRI')[2]})
	aAdd(aCampos, { 'NJR_DATA',   TAMSX3('NJR_DATA'  )[3], TAMSX3('NJR_DATA'  )[1], TAMSX3('NJR_DATA'  )[2]})


	//Cria a temporária
	oTempTable := FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("1", {"NJR_CODCTR"} )
	oTempTable:Create()

return cAliasTmp

