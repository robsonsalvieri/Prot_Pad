#INCLUDE "LOCA104D.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "


/*/{Protheus.doc} LOCA104B
Implementa a Inclusão de Itens de outros contratos e obras no Romaneio de devolução
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA104D()
Local aParam := {}
Local oExecView
Local aButtons
Local lCanSave := .T.

Private  aRet   := {}
PRivate  bLoad  :=  {|oGrid| LOCA104DLd(oGrid)}
// Array a ser passado para ParamBox

    if FQW->FQW_STATUS $ '56' // Não podemos incluir novos itens em Romaneio Faturado
        Help(" ",1,"LOCA104D_02",, STR0015,1,0)  //"Operação invalida! O Romaneio já tem documento de devolução gerado."
    	Return .T.
    endif

	aAdd(aParam, {1, STR0001 ,space(TamSx3("FPA_PROJET")[1]),"", "","FP0","",50,.F.}) //"Projeto de"
	aAdd(aParam, {1, STR0002 ,space(TamSx3("FPA_PROJET")[1]),"", "","FP0","",50,.F.}) //"Projeto até"
	aAdd(aParam, {1, STR0003 ,space(TamSx3("FPA_OBRA")[1]),"", "","","",50,.F.})  //"Obra de"
	aAdd(aParam, {1, STR0004 ,space(TamSx3("FPA_OBRA")[1]),"", "","","",50,.F.}) //"Obra até"
	aadd(aParam, {1, STR0005, space(TamSx3("FPA_PRODUT")[1]) , "", "", "SB1", "", 115, .F.})  //"Produto de"
	aadd(aParam, {1, STR0006, Replicate("z",TamSx3("FPA_PRODUT")[1]) , "", "", "Sb1", "", 115, .F.})  //"Produto até"
	aadd(aParam, {1, STR0007, space(TamSx3("FPA_GRUA")[1]), "", "", "ST9", "", 80, .F.})  //"Bem de"
	aadd(aParam, {1, STR0008, Replicate("z",TamSx3("FPA_GRUA")[1]), "", "", "ST9", "", 80, .F.})  //"Bem até"
	aAdd(aParam, {1, STR0009 ,Criavar("FPA_DTINI", .T.),"", "","","",50,.F.}) //"Data inicio de"
	aAdd(aParam, {1, STR0010 ,Criavar("FPA_DTINI", .T.),"", "","","",50,.F.}) //"Data inicio até"
	aadd(aParam, {1, STR0011, Criavar("FPA_GERAEM", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data de Geração de"
	aadd(aParam, {1, STR0012, CTod("31/12/2999")    , ""  , "", ""   , "", 50, .F.})  //"Data de Geração até"

	// Caso confirme a tela de parametros processa a rotina de demanda
	If ParamBox(aParam,STR0013,@aRet, , , , , , , , lCanSave,)   //"Escolha de Itens para romaneio"
		aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.T.,NIL},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0014+FQW->FQW_CLIDEV+"/"+FQW->FQW_LOJDEV+" - "+FQW->FQW_NOMDEV)  //"Itens Enviados ao Cliente "
		oExecView:setSource("LOCA104B")
		oExecView:setOK({|| LOCA104BOk(FQW->FQW_NUM)})
		oExecView:setModal(.F.)
		oExecView:SetButtons(aButtons)
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:openView(.T.)

	endif

return .T.
/*/{Protheus.doc} LOCA104DLd
Gera a carga do model para a devolução de todos os itens que foram enviados para o mesmo cliente de destino
@type function
@version 25.10
@author Alexandre Circenis
@since 20/10/2025
@param oMdl, object, Model que será preenchido
@return variant, Array com os dadados para preenchimento
/*/
Static Function LOCA104DLd( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}
	Local cCliOri   :=  FQW->FQW_CLIDEV
	LOcal cLojaOri  :=  FQW->FQW_LOJDEV

	cTmp := GetNextAlias()
	
	cQuery += "SELECT FPA.*, SB1.B1_DESC,B1_UM, B1_SEGUM,'F' MARK
	
	cQuery += " FROM "+ RetSqlName("SD2") + " SD2"	// Trazer os itens de nota de remessa não devolvidos
 
	cQuery += " INNER JOIN " + RetSqlName("FPA") + " FPA " 
	cQuery += " ON	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFRET = ' '"
	cQuery += " AND	FPA.FPA_NFREM <> ' '"
	cQuery += " AND FPA.FPA_PROJET >= ? "
	cQuery += " AND FPA.FPA_PROJET <= ? "
	aadd( aParam, aRet[01] )
	aadd( aParam, aRet[02] )
	cQuery += " AND FPA.FPA_OBRA >= ? "
	cQuery += " AND FPA.FPA_OBRA <= ? "
	aadd( aParam, aRet[03] )
	aadd( aParam, aRet[04] )
	cQuery += " AND  FPA.FPA_PRODUT = D2_COD"
	cQuery += " AND  FPA.FPA_DTINI >= ? "
	cQuery += " AND  FPA.FPA_DTINI <= ? "
	aadd( aParam, Dtos(aRet[09]) )
	aadd( aParam, Dtos(aRet[10]) )

	cQuery += " AND  FPA.FPA_GRUA >= ? "
	cQuery += " AND  FPA.FPA_GRUA <= ? "
	aadd( aParam, aRet[07] )
	aadd( aParam, aRet[08] )
    cQuery += " AND FPA.FPA_NFREM = SD2.D2_DOC"
	cQuery += " AND FPA.FPA_SERREM = SD2.D2_SERIE"
	cQuery += " AND FPA.FPA_ITEREM = SD2.D2_ITEMPV"
	If !Empty(FQW->FQW_FILREM)
		cQuery += " AND  FPA_FILREM = ? "
		aadd( aParam, FQW->FQW_FILREM )
	endif
	cQuery += " AND  EXISTS ( " // Contrato / obra deve possuir pelo menus um conjunto transportador de Retorno
	cQuery += " SELECT  FQ7_OBRA "
	cQuery += " FROM " + RetSqlName("FQ7") +" FQ7 "
	cQuery += " WHERE FQ7_FILIAL = '"+xFilial("FQ7")+"'"
	cQuery += " AND FQ7_PROJET = FPA.FPA_PROJET "
	cQuery += " AND FQ7_OBRA = FPA.FPA_OBRA "
	cQuery += " AND FQ7_TPROMA = '1' " // 0 = Saida 1 = Retorno
	cQuery += " AND FQ7.D_E_L_E_T_ = ' ')"
	
	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN " +	RetSqlName("FQ5") + " FQ5 "  
	cQuery += " ON  FQ5.FQ5_FILIAL  =  '" + xFilial("FQ5") + "' "
	cQuery += " AND	FQ5.FQ5_AS = FPA.FPA_AS"
	cQuery += " AND FQ5.FQ5_DATGER >= ? "
	cQuery += " AND FQ5.FQ5_DATGER <= ? "
	aadd( aParam, Dtos(aRet[11]) )
	aadd( aParam, Dtos(aRet[12]) )
	cQuery += " AND	FQ5.D_E_L_E_T_  =  ' ' "
 

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio antigo
	cQuery += " SELECT  FQ3_AS "
	cQuery += " FROM " + RetSqlName("FQ3") +" FQ3 "
	cQuery += " WHERE FQ3_FILIAL = '"+xFilial("FQ3")+"'"
	cQuery += " AND FQ3_AS = FPA.FPA_AS "
	cQuery += " AND FQ3_NFREM = ' ' "
	cQuery += " AND FQ3_NFRET = ' ' "
	cQuery += " AND FQ3.D_E_L_E_T_ = ' ')"

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio novo
	cQuery += " SELECT  FQX_AS "
	cQuery += " FROM " + RetSqlName("FQX") +" FQX "
	cQuery += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
	cQuery += " AND FQX_AS = FPA.FPA_AS "
	cQuery += " AND FQX.D_E_L_E_T_ = ' ')"

	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  				
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FPA_PRODUT"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FPA.FPA_GRUA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " AND SD2.D2_CLIENTE = ?"
	aadd( aParam, cCliOri )
	cQuery += " AND SD2.D2_LOJA = ? "
	aadd( aParam, cLojaOri )
	cQuery += " AND SD2.D2_COD >= ? "
	cQuery += " AND SD2.D2_COD <= ? "
	aadd( aParam, aRet[05] )
	aadd( aParam, aRet[06] )	
	cQuery += " AND SD2.D2_QTDEDEV < D2_QUANT "
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"

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

@param oObj, character,         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias, character,       Alias para carga .
@param cAliasReal, character,   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno, character,  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy, logical,        Apenas para compatibilidade, Nao usar
@param lQuery, Logical,       Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FPA' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )
