#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'JURA307.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA307
Configuração da Forma de Correção Automática
/*/
//-------------------------------------------------------------------
Function JURA307()

Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001)//"Configuração da Forma de Correção Automática"
	oBrowse:SetAlias( "O1F" )
	oBrowse:Activate()
	oBrowse:Destroy()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "VIEWDEF.JURA307", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003 , "VIEWDEF.JURA307", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004 , "VIEWDEF.JURA307", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005 , "VIEWDEF.JURA307", 0, 5, 0, NIL } ) //"Excluir"


Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 02/12/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrO1F   := FWFormStruct(1,'O1F')

	oModel := MPFormModel():New('JURA307', /*bPreValidacao*/, {|oModel| ModelPosValid(oModel)}/*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1FMASTER',/*cOwner*/,oStrO1F,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001) //"Configuração da Forma de Correção Automática"
	oModel:GetModel('O1FMASTER'):SetDescription(STR0006) //"Forma de Correção Automática"
	oModel:SetPrimaryKey( { "O1F_FILIAL", "O1F_CODIGO" } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação dos dados do modelo
@since 02/12/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet      := .T.
Local oMdlO1F   := nil
Local cQuery    := nil
Local cTmpAlias := nil
Local aQryParam := nil

	IF oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		aQryParam := {}
		oMdlO1F   := oModel:GetModel('O1FMASTER')
		cQuery    := ""
		cTmpAlias := GetNextAlias()

		cQuery += " SELECT COUNT(O1F_CODIGO) as TOTAL "
		cQuery += " FROM " + RetSqlName('O1F')
		cQuery += " WHERE "
		cQuery +=     " O1F_FILIAL = ? "
		cQuery +=     " AND O1F_TIPOAS = ? "
		cQuery +=     " AND O1F_CAREAJ = ? "
		cQuery +=     " AND O1F_COBJET = ? "
		cQuery +=     " AND O1F_UF = ? "
		cQuery +=     " AND O1F_CODIGO <> ? "
		cQuery +=     " AND D_E_L_E_T_ = ' ' "

		aAdd(aQryParam,xFilial('O1F'))
		aAdd(aQryParam,oMdlO1F:GetValue("O1F_TIPOAS"))
		aAdd(aQryParam,oMdlO1F:GetValue("O1F_CAREAJ"))
		aAdd(aQryParam,oMdlO1F:GetValue("O1F_COBJET"))
		aAdd(aQryParam,oMdlO1F:GetValue("O1F_UF"))
		aAdd(aQryParam,oMdlO1F:GetValue("O1F_CODIGO"))

		dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aQryParam), cTmpAlias, .T., .F. )

		IF (cTmpAlias)->TOTAL > 0
			lRet := .F.
			JurMsgErro(STR0007) //"Já existem registros com as informações utilizadas"
		Endif
	Endif


Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@since 02/12/2021
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA307')
Local oStrO1F := FWFormStruct(2, 'O1F')

	oView:SetModel(oModel)
	oView:AddField('VIEW_O1F' ,oStrO1F,'O1FMASTER')
	oView:SetDescription(STR0006) //"Forma de Correção Automática"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} J307ForCor
Função responsavel pela busca da forma de correção
@since 02/12/2021
@param cTpAssunto - Código do tipo de assunto
@param cArea      - Código da area juridica
@param cAssunto   - Código do assunto/objeto
@param cUf        - Código da UF 
@param cCajuri    - Código do assunto jurídico
@param cInstancia - Código da Instancia
@return cRet, retorna aForma de correção encontrada
/*/
//------------------------------------------------------------------------------
Function J307ForCor(cTpAssunto,cArea,cAssunto,cUf,cCajuri,cInstancia)
Local cRet := ""

Default cTpAssunto    := ""
Default cArea         := ""
Default cAssunto      := ""
Default cUf           := ""
Default cCajuri       := ""
Default cInstancia    := ""

	If FwAliasInDic('O1F')
		If !Empty(cCajuri)
			GetDadosProcesso(cCajuri,cInstancia,@cTpAssunto,@cArea,@cAssunto,@cUf)
		Endif
		cRet := GetFormaCorrecao(cTpAssunto,cArea,cAssunto,cUf)
	Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetFormaCorrecao
Função responsavel pela busca da forma de correção
@since 02/12/2021
@param cTpAssunto - Código do tipo de assunto
@param cArea      - Código da area juridica
@param cAssunto   - Código do assunto/objeto
@param cUf        - Código da UF 
@return cRet, retorna aForma de correção encontrada
/*/
//------------------------------------------------------------------------------
Static Function GetFormaCorrecao(cTpAssunto,cArea,cAssunto,cUf)
Local cRet      := ""
Local cQuery    := ""
Local aQryParam := {}
Local cTmpAlias := GetNextAlias()
Local nQtdUtil  := 0
Local nQtdOld   := -1
Local nMaxRest  := 4 //Numero maximo de restrições (para cada campo utilizado na query)

	cQuery += " Select " 
	cQuery +=     " O1F.O1F_TIPOAS, " //TIPO DE ASSUNTO
	cQuery +=     " O1F.O1F_CAREAJ, " //Area
	cQuery +=     " O1F.O1F_COBJET, " //Assunto
	cQuery +=     " O1F.O1F_UF, "     //uf
	cQuery +=     " O1F.O1F_CFCORR "  // Forma de correção
	cQuery += " From " + RetSqlName('O1F') + " O1F "
	cQuery += " Where "
	cQuery +=     " O1F.O1F_FILIAL = ? "
	cQuery +=     " AND O1F.O1F_TIPOAS in(' ', ? )  " //TIPO DE ASSUNTO
	cQuery +=     " AND O1F.O1F_CAREAJ in(' ', ? )  " //Area
	cQuery +=     " AND O1F.O1F_COBJET in(' ', ? )  " //Assunto
	cQuery +=     " AND O1F.O1F_UF in(' ', ? ) "     //uf
	cQuery +=     " AND O1F.D_E_L_E_T_ = ' ' "

	aAdd(aQryParam,xFilial('O1F'))
	aAdd(aQryParam,Padr(cTpAssunto,TamSx3("O1F_TIPOAS")[1]))
	aAdd(aQryParam,Padr(cArea     ,TamSx3("O1F_CAREAJ")[1]))
	aAdd(aQryParam,Padr(cAssunto  ,TamSx3("O1F_COBJET")[1]))
	aAdd(aQryParam,Padr(cUf       ,TamSx3("O1F_UF")[1]))

	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aQryParam), cTmpAlias, .T., .F. )

	While (cTmpAlias)->(!Eof())
		nQtdUtil := 0

		If !Empty((cTmpAlias)->O1F_TIPOAS)
			nQtdUtil++
		Endif
		If !Empty((cTmpAlias)->O1F_CAREAJ)
			nQtdUtil++
		Endif
		If !Empty((cTmpAlias)->O1F_COBJET)
			nQtdUtil++
		Endif
		If !Empty((cTmpAlias)->O1F_UF)
			nQtdUtil++
		Endif

		//Pega a forma de correção do registro mais restrintivo possivel, 
		//caso tenha outros com a mesma quantidade, pega o primeiro
		If nQtdUtil > nQtdOld
			cRet    := (cTmpAlias)->O1F_CFCORR
			nQtdOld := nQtdUtil
		Endif

		//Se for totalmente restringivo, utiliza essa forma de correção
		iF nQtdUtil == nMaxRest
			Exit
		Endif
		(cTmpAlias)->(DbSkip())
	End
	
	(cTmpAlias)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDadosProcesso
Função responsavel pela busca da forma de correção
@since 02/12/2021
@param cCajuri    - Código do Assunto jurídico
@param cInstancia - Código da instancia
@param cTpAssunto - Código do tipo de assunto (referencia)
@param cArea      - Código da area juridica (referencia)
@param cAssunto   - Código do assunto/objeto (referencia)
@param cUf        - Código da UF (referencia)
@return nulo
/*/
//------------------------------------------------------------------------------
Static Function GetDadosProcesso(cCajuri,cInstancia,cTpAssunto,cArea,cAssunto,cUf)
Local cQuery    := ""
Local aQryParam := {}
Local cTmpAlias := GetNextAlias()

Default cInstancia := ""

	cQuery += " SELECT NSZ.NSZ_TIPOAS,NSZ.NSZ_COBJET,NSZ.NSZ_CAREAJ,NQ6_UF "
	cQuery += " FROM "+RetSqlName("NSZ")+" NSZ "
	cQuery +=     " INNER JOIN "+RetSqlName("NUQ")+" NUQ ON ( "
	cQuery +=         " NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQuery +=         " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	If Empty(cInstancia)
		cQuery +=         " AND NUQ.NUQ_INSATU = '1' "
	Else 
		cQuery +=         " AND NUQ.NUQ_COD = ? "
		aAdd(aQryParam,PADR(cInstancia,TamSx3("NUQ_COD")[1]))
	Endif
	cQuery +=         " AND NUQ.D_E_L_E_T_ = ' ' "
	cQuery +=         " ) "
	cQuery +=     " INNER JOIN " + RetSqlName("NQ6") + " NQ6 ON "
	cQuery +=         " NQ6.NQ6_FILIAL = ? "
	cQuery +=         " AND NQ6.NQ6_COD = NUQ.NUQ_CCOMAR "
	cQuery +=         " AND NQ6.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NSZ_FILIAL = ? "
	cQuery +=   " AND NSZ_COD = ? "
	cQuery +=   " AND NSZ.D_E_L_E_T_ = ' ' "

	aAdd(aQryParam,xFilial('NQ6'))//1
	aAdd(aQryParam,xFilial('NSZ'))//2
	aAdd(aQryParam,Padr(cCajuri,TamSx3('NSZ_COD')[1]))
	
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aQryParam), cTmpAlias, .T., .F. )

	While (cTmpAlias)->(!Eof())
		cTpAssunto := (cTmpAlias)->NSZ_TIPOAS
		cArea      := (cTmpAlias)->NSZ_CAREAJ
		cAssunto   := (cTmpAlias)->NSZ_COBJET
		cUf        := (cTmpAlias)->NQ6_UF

		(cTmpAlias)->(DbSkip())
	End
	(cTmpAlias)->(DbCloseArea())
Return
