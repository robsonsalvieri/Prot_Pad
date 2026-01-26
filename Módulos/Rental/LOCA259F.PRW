#Include "LOCA259F.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "


/*/{Protheus.doc} LOCA259F
Implementa a DEsvinculação da A.S da Demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA259F()
Local oExecView
Local aButtons

Private  aRet   := {}

if !LOCA259VDE() // Valida se há A.S. que possam ser desvinculadas
	Return .T.
endif

aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			{.F.,Nil},{.T.,NIL},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
			{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
oExecView := FWViewExec():New()
//oExecView:setTitle("A.S.")
oExecView:setSource("LOCA259F")
//oExecView:setOK({|| LOCA259FPR()})
oExecView:setModal(.F.)
oExecView:SetButtons(aButtons)
oExecView:setOperation(MODEL_OPERATION_UPDATE)
oExecView:setCloseOnOK({|| .T.})
oExecView:openView(.T.)

return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
MODELO Para Desvincular AS
//-------------------------------------------------------------------/*/
Static Function ModelDef()
local oModel    := FWLoadModel("LOCA259C")

oModel := Loca259HMD(oModel)
oModel:GetModel("GRID"):bLoad :=  {|oGrid| Loca259LdG(oGrid)}
//Adicionando descrição ao modelo
oModel:SetDescription( "Desvincular A.S. Pendente") //"A.S. DIPONIVEL"
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( "A.S. Separadas" ) //"A.S. Disponiveis"
//  oModel:SetPrimaryKey( { 'X_ZMVC' } )
//Adicionando descrição ao modelo
If !Empty(FQ5->FQ5_DEMAND)
	oModel:SetDescription( FQ5->FQ5_DEMAND ) //"A.S. DIPONIVEL"
Else	
	oModel:SetDescription( "Vazio" ) //"A.S. DIPONIVEL"
EndIF	

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*///-------------------------------------------------------------------/*/
Static Function ViewDef()
	local oView    := FwLoadView("LOCA259C")
	local oModel   := FWLoadModel( 'LOCA259F' )

oView := LOCA259HVI(oView, oModel)

//Adcionar os botões especificos
	oView:SetViewAction("BUTTONOK", { |oView| LOCA259FPR( oView ) } )
	oView:SetDescription( STR0021) //"Itens Disponiveis" //STR0001 //"Desvincular A.S. Pendente da Demanda"
Return oView


/*/{Protheus.doc} Loca259LdG
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca259LdG( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}


	cTmp := GetNextAlias()
	
	cQuery += "SELECT FQ5.*,FPA.FPA_LOCAL, FPA.FPA_DESGRU, SB1.B1_DESC, 'F' MARK "
	
	cQuery += " FROM " + RetSqlName("FQ5") + " FQ5 "  					//-- Cadastro de Viagem

	cQuery += " INNER JOIN  " +	RetSqlName("FPA") + " FPA "  					//-- AgendametosS Itens
	cQuery += " ON  FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
	cQuery += " AND	FPA.FPA_AS = FQ5.FQ5_AS"
	cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFREM = ''"

	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  					//-- AgendametosS Itens
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FQ5_XPROD"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					//-- Solicitantes
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FQ5.FQ5_GUINDA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' "

	cQuery += " AND  FQ5_DEMAND = ? " // AS não ligada a uma demanda
	aadd( aParam, FQT->FQT_DEMAND )
	cQuery += " AND  FQ5_XROMAN =  ' ' " // A.S. não está num romaneio
	cQuery += " AND  FQ5_TPAS = 'L'" // AS do tipo Locação
	cQuery += " AND  FQ5_STATUS = '1'" // AS Não Seperada	
	cQuery += " AND  FQ5.D_E_L_E_T_  =  ' ' "


	cQuery += " ORDER BY FQ5_SOT, FQ5_OBRA, FQ5_AS"

	cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())

	For nLinha := 1 To Len(aStruQry)
		If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
			TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
		Endif
	Next nLinha
	TCSetField( cAliasT , "MARK", "L")
/*
FWLoadByAlias
Função que realiza a carga de um submodelo baseado em um alias existente

@param oObj         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias       Alias para carga .
@param cAliasReal   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy        Apenas para compatibilidade, Nao usar
@param lQuery       Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FQ5' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

	if Len(aDados) = 0
		MsgAlert(STR0019) //"Não há A.S. na demanda para serem desvinculadas!"
	endif

Return( aDados )


/*/{Protheus.doc} LOCA259FPR
Processa o Desvinculamento das A.S. marcadas
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
FUNCTION LOCA259FPR(oView)
Local cTitulo := STR0020  //"Desvincula A.S. da Demanda"
Local cMsg := STR0004  //"Desvinculando as A.S."
Local lAborta := .F.

Processa( {|| Loca259DGD("D")}, cTitulo, cMsg, lAborta )

Return .T.

/*/{Protheus.doc} LOCA259FCO
Conta o numero de linhas marcadas
@type function
@version 24.10
@author Alexandre Circenis
@since 3/9/2025
@param oModel, object, Modelo de dados
@return variant, Numero de Linhas Marcadas
/*/
FUNCTION LOCA259FCO(oModel)
Local nContar  := 0
Local nLinhas
Local oGrid  := oModel:GetModel("GRID")

for nLinhas := 1 to oGrid:Length()

	if oGrid:GetValue("MARK", nLinhas)

		nContar++

	endif

next

return nContar

/*/{Protheus.doc} LOCA259VDE
Valida se os itens da demanda estão aptos a serem desvinculados
@type function
@version  25.10
@author Alexandre Circenis
@since 7/18/2025
@param cDemanda, character, codigo de demanda 
@return variant, .T. se houverem itens da demanda que podem ser desvinculadas
/*/
FUNCTION LOCA259VDE(cDemanda)

Local aArea      := GetArea()
Local cAliasT    := GetNextAlias()
Local cQuery 	 := ''
Local cTmp		 := ''
Local aParam     := {}
Local lRet       := .T. // Há dados para fazer o Desvinculo
Local nOK        := 0
Local nSeparado  := 0
LOcal nRomaneio  := 0
LOcal cAviso     := ""

cTmp := GetNextAlias()

cQuery += "SELECT FQ5_STATUS, FQ5_XROMAN"
cQuery += " FROM " + RetSqlName("FQ5") + " FQ5 "  					//-- Cadastro de Viagem

cQuery += " INNER JOIN  " +	RetSqlName("FPA") + " FPA "  					//-- AgendametosS Itens
cQuery += " ON  FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
cQuery += " AND	FPA.FPA_AS = FQ5.FQ5_AS"
cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
cQuery += " AND	FPA.FPA_NFREM = ' '"

cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "
cQuery += " WHERE FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' "

cQuery += " AND  FQ5_DEMAND = ? " // AS não ligada a uma demanda
aadd( aParam, FQT->FQT_DEMAND )
cQuery += " AND  FQ5.D_E_L_E_T_  =  ' ' "
cQuery += " ORDER BY FQ5_SOT, FQ5_OBRA, FQ5_AS"

cQuery := ChangeQuery(cQuery)
//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aParam)

While !(cAliasT)->(Eof())
	if (cAliasT)->FQ5_STATUS = '6' .or. (cAliasT)->FQ5_XROMAN <> ' ' // A.S. Separada

		if (cAliasT)->FQ5_STATUS = '6'
			nSeparado++
		endif	
		if (cAliasT)->FQ5_XROMAN <> ' '
			nRomaneio++
		endif
	else
		nOK ++
	endif
	(cAliasT)->(dbSkip())
enddo

if nOk = 0 // Não tem A.S. para desvincular
	cAviso += STR0019 + CRLF //"Não há A.S. na demanda aptas a serem desvinculadas!"
	LRet := .F.
endif

if nSeparado > 0 .and. nOk = 0
	if nSeparado = 1
		cAviso += STR0023+Alltrim(Str(nSeparado))+STR0022+CRLF //" A.S. separada que não poderá ser desvinculada" //"Existe "
	else
		cAviso += STR0025+Alltrim(Str(nSeparado))+STR0024+CRLF //" A.S. separadas que não podem ser desvinculadas" //"Existem "
	endif
endif	

if nRomaneio > 0 .and. nOk = 0
	if nRomaneio = 1
		cAviso += STR0023+Alltrim(Str(nRomaneio))+STR0026+CRLF //" A.S. em romaneio que não poderá ser desvinculada" //"Existe "
	else
		cAviso += STR0025+Alltrim(Str(nRomaneio))+STR0027+CRLF //" A.S. em romaneio que não podem ser desvinculadas" //"Existem "
	endif
endif	

if !Empty(cAviso)
	MsgAlert(cAviso, STR0028,  {"Ok"}) //"Eventos pré desvinculo da demanda!"
endif

RestArea(aArea)

Return lRet
