#INCLUDE "WMSA320A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"

#DEFINE WMSA320A01 "WMSA320A01"
#DEFINE WMSA320A02 "WMSA320A02"
#DEFINE WMSA320A03 "WMSA320A03"

Static __lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static cAliasSF1  := ""
Static oBrwSD1    := Nil
Static oTempTable := Nil
Static aColsSF1   := {}

// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function WMSA320ADUMMY()
Return Nil

//----------------------------------------------------------
// ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructDCW := FWFormStruct(1,'DCW')
Local oStructDCX := FWFormStruct(1,'DCX')
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA320A', /*bPre*/, { |oModel| ValidModel(oModel)}, {|oModel| GravaDados(oModel)}, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('WMSA320ADCW', Nil, oStructDCW,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetDescription(STR0002 ) //Conferencia

	oModel:AddGrid( 'WMSA320ADCX', 'WMSA320ADCW'   , oStructDCX, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( 'WMSA320ADCX', {{'DCX_FILIAL',"xFilial('DCX')"},{'DCX_EMBARQ','DCW_EMBARQ'}} , DCX->( IndexKey(1) ) )
	oModel:GetModel( 'WMSA320ADCX' ):SetOptional( .T. )
	oModel:GetModel( 'WMSA320ADCX' ):SetDescription(Trim(RetTitle('D1_DOC'))) // Documento

	oModel:SetPrimaryKey({'DCW_FILIAL', 'DCW_EMBARQ'})
	oModel:SetActivate({|oModel| ActiveModel(oModel)})
	oModel:SetDeActivate({|oModel| DeActiveModel(oModel)})
Return oModel
//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel('WMSA320A')
Local oStructDCW := FWFormStruct(2,'DCW',,.F.)
Local oView      := FWFormView():New()
	// Elimina Struct DCW
	oStructDCW:RemoveField('DCW_FILIAL')
	oStructDCW:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:CreateHorizontalBox( 'MASTER' , 15,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddField('WMSA320ADCW' , oStructDCW)
	oView:CreateHorizontalBox( 'DETAIL' , 85,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddOtherObject('320ASD1', {|oPnlSD1| MontaSD1(oPnlSD1,@oBrwSD1)})
	// Bottoes
	oView:AddUserButton(STR0001, 'WMSA320A', {|| SetFiltrar(), oBrwSD1:Refresh(.T.)}) //Filtrar
	// Associa um View a um box
	oView:SetOwnerView('WMSA320ADCW', 'MASTER')
	oView:SetOwnerView('320ASD1', 'DETAIL')
	oView:SetUseCursor(.F.)
	oModel:SetDeActivate({|oModel| DeActiveModel(oModel,oBrwSD1)})
Return oView
//-----------------------------------------------------------------------------//
//-------------------------Cria a tabela temporária----------------------------//
//-----------------------------------------------------------------------------//
Static Function CriaTemp()
Local aColsSX3  := {}
 	aColsSF1  := {}
	/*Coluna de marcação*/             AAdd(aColsSF1,{'DO_MARK'   ,'C',2,0})
	BuscarSX3('F1_DOC',,aColsSX3);     AAdd(aColsSF1,{'DO_DOC'    ,'C',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('F1_SERIE',,aColsSX3);   AAdd(aColsSF1,{'DO_SERIE'  ,'C',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('F1_FORNECE',,aColsSX3); AAdd(aColsSF1,{'DO_FORNECE','C',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('A1_NOME',,aColsSX3);    AAdd(aColsSF1,{'DO_NMCLFOR','C',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('F1_LOJA',,aColsSX3);    AAdd(aColsSF1,{'DO_LOJA'   ,'C',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('F1_DTDIGIT',,aColsSX3); AAdd(aColsSF1,{'DO_DTDIGIT','D',aColsSX3[3],aColsSX3[4]})
	BuscarSX3('F1_VOLUME1',,aColsSX3); AAdd(aColsSF1,{'DO_VOLUME1','N',aColsSX3[3],aColsSX3[4]})
	cAliasSF1 := CriaTabTmp(aColsSF1,{'DO_DOC','DO_SERIE','DO_FORNECE','DO_LOJA','DO_VOLUME1'},,@oTempTable)
Return .T.
//----------------------------------------------------------
// Filtro documentos
/*/{Protheus.doc} SetFiltrar
Filtro documentos

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/08/12

/*/
//----------------------------------------------------------
Static Function SetFiltrar()
	//Seleção de documentos
	If Pergunte('DLGA321',.T.)
		SelDocto()
	EndIf
Return
//----------------------------------------------------------
// Seleção documentos disponiveis
/*/{Protheus.doc} SelDocto
Seleção documentos disponiveis

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/08/12

/*/
//----------------------------------------------------------
Static Function SelDocto()
Local cQuery    := ""
Local cAliasQry := ""
Local cQueryPE  := ""
Local aArrayQRY := {}
	cQuery := "SELECT F1_DOC,"
	cQuery +=       " F1_SERIE,"
	cQuery +=       " F1_FORNECE,"
	cQuery +=       " F1_LOJA,"
	cQuery +=       " F1_DTDIGIT,"
	cQuery +=       " F1_VOLUME1,"
	cQuery +=       " F1_TIPO"
	cQuery +=  " FROM "+RetSqlName("SF1")+" SF1"
	cQuery += " WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"' And "

	If (!Empty(MV_PAR03) .Or. Upper(SubStr(MV_PAR04,1,1)) != 'Z') .And. !MV_PAR03 == MV_PAR04
		cQuery  += " SF1.F1_FORNECE >= '"+MV_PAR03+"' And "
		cQuery  += " SF1.F1_FORNECE <= '"+MV_PAR04+"' And "
	ElseIf MV_PAR03 == MV_PAR04
		cQuery  += " SF1.F1_FORNECE = '"+MV_PAR03+"' And "
	EndIf
	
	If (!Empty(MV_PAR05) .Or. Upper(SubStr(MV_PAR06,1,1)) != 'Z') .and. !MV_PAR05 == MV_PAR06
		cQuery  += " SF1.F1_LOJA >= '"+MV_PAR05+"' And "
		cQuery  += " SF1.F1_LOJA <= '"+MV_PAR06+"' And "
	ElseIf MV_PAR05 == MV_PAR06
		cQuery  += " SF1.F1_LOJA = '"+MV_PAR05+"' And "
	EndIf
	
	If (!Empty(MV_PAR01) .Or. Upper(SubStr(MV_PAR02,1,1)) != 'Z') .and. !MV_PAR01 == MV_PAR02
		cQuery  += " SF1.F1_DOC >= '"+MV_PAR01+"' And "
		cQuery  += " SF1.F1_DOC <= '"+MV_PAR02+"' And "
	ElseIf MV_PAR01 == MV_PAR02
		cQuery  += " SF1.F1_DOC = '"+MV_PAR01+"' And "
	EndIf

	If MV_PAR07 == MV_PAR08
		cQuery  += " SF1.F1_DTDIGIT = '"+DTOS(MV_PAR07)+"' And "
	Else
		cQuery  += " SF1.F1_DTDIGIT >= '"+DTOS(MV_PAR07)+"' And "
		cQuery  += " SF1.F1_DTDIGIT <= '"+DTOS(MV_PAR08)+"' And "
	EndIf

	cQuery +=   " (SF1.F1_TIPO = 'N' OR SF1.F1_TIPO = 'D' OR SF1.F1_TIPO = 'B')"
	cQuery +=   " AND (SF1.F1_STATUS <> 'B' AND SF1.F1_STATUS <> 'C')"
	// Quanto parâmetro MV_CONFFIS está ativo, SF1.F1_STATCON fica com valor '0'
	cQuery +=   " AND (SF1.F1_STATCON = ' ' OR SF1.F1_STATCON = '0')"
	cQuery +=   " AND SF1.D_E_L_E_T_ = ' '"
	// Desconsidera os itens com quantidade zerado, utilizados para ajuste de custo
	cQuery +=   " AND EXISTS (SELECT 1 FROM "+RetSqlName("SD1")+" SD1"
	cQuery +=                " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=                  " AND SD1.D1_DOC     = SF1.F1_DOC"
	cQuery +=                  " AND SD1.D1_SERIE   = SF1.F1_SERIE"
	cQuery +=                  " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
	cQuery +=                  " AND SD1.D1_LOJA    = SF1.F1_LOJA"
	If nTipConf == 1 //Conferência de pré-nota
		cQuery +=              " AND SD1.D1_TES     = '"+Space(TamSx3('D1_TES')[1])+"'"
	Else  //Conferência de documento de entrada
		cQuery +=              " AND SD1.D1_TES     <> '"+Space(TamSx3('D1_TES')[1])+"'"
	EndIf
	cQuery +=                  " AND SD1.D1_QUANT   > 0"
	cQuery +=                  " AND SD1.D1_OP      = ' '"
	cQuery +=                  " AND SD1.D_E_L_E_T_ = ' ')"
	If !SuperGetMV("MV_WMSNEW",.F.,.F.)
		cQuery +=   " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("SDB")+" SDB"
		cQuery +=                    " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=                      " AND SDB.DB_DOC     = F1_DOC"
		cQuery +=                      " AND SDB.DB_SERIE   = F1_SERIE"
		cQuery +=                      " AND SDB.DB_CLIFOR  = F1_FORNECE"
		cQuery +=                      " AND SDB.DB_LOJA    = F1_LOJA"
		cQuery +=                      " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=                      " AND SDB.DB_ESTORNO = ' '"
		cQuery +=                      " AND SDB.DB_ORIGEM  = 'SD1'"
		cQuery +=                      " AND SDB.DB_STATUS <> '2'"
		cQuery +=                      " AND SDB.D_E_L_E_T_ = ' ')"
	Else
		cQuery +=   " AND NOT EXISTS (SELECT 1"
		cQuery +=                     " FROM "+RetSqlName("D12")+" D12, "+RetSqlName("DCF")+" DCF"

		cQuery +=                    " INNER JOIN "+RetSqlName("DCR")+" DCR "
		cQuery +=                    	" ON (DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=                    	" AND DCF.DCF_ID = DCR.DCR_IDDCF "
		cQuery +=                    	" AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN "
		cQuery +=                    	" AND DCR.D_E_L_E_T_ = ' ') "

		cQuery +=                    " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=                      " AND DCF.DCF_DOCTO  = F1_DOC"
		cQuery +=                      " AND DCF.DCF_SERIE  = F1_SERIE"
		cQuery +=                      " AND DCF.DCF_CLIFOR = F1_FORNECE"
		cQuery +=                      " AND DCF.DCF_LOJA   = F1_LOJA"
		cQuery +=                      " AND DCF.DCF_ORIGEM = 'SD1'"
		cQuery +=                      " AND DCF.DCF_STSERV <> '0'"
		cQuery +=                      " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=                      " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=                      " AND D12.D12_IDDCF  = DCR.DCR_IDORI "
		cQuery +=                      " AND D12.D12_IDMOV = DCR.DCR_IDMOV "
		cQuery +=                      " AND D12.D12_IDOPER = DCR.DCR_IDOPER "
		cQuery +=                      " AND (D12.D12_STATUS <> '0' AND  D12.D12_STATUS <> '2')"
		cQuery +=                      " AND D12.D_E_L_E_T_ = ' ' )"
		If WmsX212118("D0Q")
			cQuery +=   " AND NOT EXISTS(SELECT D0Q_ID"
			cQuery +=                    " FROM "+RetSqlName('D0Q')+" D0Q"
			cQuery +=                   " WHERE D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
			cQuery +=                     " AND D0Q.D0Q_DOCTO  = SF1.F1_DOC"
			cQuery +=                     " AND D0Q.D0Q_SERIE  = SF1.F1_SERIE"
			cQuery +=                     " AND D0Q.D0Q_CLIFOR = SF1.F1_FORNECE"
			cQuery +=                     " AND D0Q.D0Q_LOJA   = SF1.F1_LOJA"
			cQuery +=                     " AND D0Q.D0Q_STATUS <> '1'"
			cQuery +=                     " AND D0Q.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=   " AND NOT EXISTS ("
		cQuery +=           " SELECT 1"
		cQuery +=             " FROM "+RetSqlName('D07')+" D07"
		cQuery +=            " INNER JOIN "+RetSqlName("SD1")+" SD1"
		cQuery +=               " ON SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
		cQuery +=              " AND SD1.D1_DOC     = SF1.F1_DOC"
		cQuery +=              " AND SD1.D1_SERIE   = SF1.F1_SERIE"
		cQuery +=              " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
		cQuery +=              " AND SD1.D1_LOJA    = SF1.F1_LOJA"
		cQuery +=              " AND SD1.D1_QUANT   > 0"
		cQuery +=              " AND SD1.D1_OP      = ' '"
		cQuery +=              " AND SD1.D_E_L_E_T_ = ' '"
		cQuery +=            " INNER JOIN "+RetSqlName('D06')+" D06"
		cQuery +=               " ON D06.D06_FILIAL = '"+xFilial("D06")+"'"
		cQuery +=              " AND D06.D06_CODDIS = D07.D07_CODDIS"
		cQuery +=              " AND D06.D06_SITDIS = '1'"
		cQuery +=              " AND D06.D_E_L_E_T_ = ' '"
		cQuery +=            " WHERE D07.D07_FILIAL = '"+xFilial("D07")+"'"
		cQuery +=              " AND D07.D07_CODDIS = SD1.D1_CODDIS"
		cQuery +=              " AND D07.D07_DOC = SD1.D1_DOC"
		cQuery +=              " AND D07.D07_SERIE = SD1.D1_SERIE"
		cQuery +=              " AND D07.D07_FORNEC = SD1.D1_FORNECE"
		cQuery +=              " AND D07.D07_LOJA = SD1.D1_LOJA"
		cQuery +=              " AND D07.D07_PRODUT = SD1.D1_COD"
		cQuery +=              " AND D07.D07_ITEM = SD1.D1_ITEM"
		cQuery +=              " AND D07.D07_LOCAL = SD1.D1_LOCAL"
		cQuery +=              " AND D07.D_E_L_E_T_ = ' ')"	
	EndIf
	If ExistBlock('WMS320FL')
		cQueryPE += ExecBlock('WMS320FL', .F., .F., {nTipConf})
		If ValType(cQueryPE) == "C"
			cQuery += cQueryPE
		EndIf
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField( cAliasQry,'F1_DTDIGIT','D')
	While !(cAliasQry)->( Eof() )
		Aadd(aArrayQry,{ " ",;
					(cAliasQry)->F1_DOC,;
					(cAliasQry)->F1_SERIE,;
					(cAliasQry)->F1_FORNECE,;
					IIf((cAliasQry)->F1_TIPO $ "BD",Posicione('SA1',1,xFilial('SA1')+(cAliasQry)->F1_FORNECE+(cAliasQry)->F1_LOJA,'A1_NOME') ,Posicione('SA2',1,xFilial('SA2')+(cAliasQry)->F1_FORNECE+(cAliasQry)->F1_LOJA,'A2_NOME') ),;
					(cAliasQry)->F1_LOJA,;
					(cAliasQry)->F1_DTDIGIT,;
					(cAliasQry)->F1_VOLUME1})
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->( dbCloseArea())
	cAliasSF1 := MntCargDad(cAliasSF1,aArrayQry,aColsSF1)
Return .T.
//----------------------------------------------------------
// Seleção documentos disponiveis
/*/{Protheus.doc} ActiveModel
Carrega documentos disponíveis para montagem

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/08/12

/*/
//----------------------------------------------------------
Static Function ActiveModel(oModel)
	CriaTemp()
	SelDocto()
	If oModel:GetOperation() == 3
		oModel:SetValue('WMSA320ADCW' , 'DCW_DATGER', dDataBase)
		oModel:SetValue('WMSA320ADCW' , 'DCW_HORGER', PadR(Time(),tamSx3("DCW_HORGER")[1]))
		oModel:SetValue('WMSA320ADCW' , 'DCW_SITEMB', '1')
		oModel:SetValue('WMSA320ADCW' , 'DCW_TPCONF', cValToChar(nTipConf))
	EndIf
	If oModel:GetOperation() == 4
		// Atribui o mesmo valor da situação somente para permitir a confirmação - senão da mensagem que não há alteração
		oModel:LoadValue('WMSA320ADCW', 'DCW_SITEMB', oModel:GetValue('WMSA320ADCW', 'DCW_SITEMB')) // Para forçar a simulação de alteração
	EndIf
Return .T.
//----------------------------------------------------------
Static Function DeActiveModel(oModel,oBrwSD1)
	If oBrwSD1 != Nil
		oBrwSD1:Deactivate()
	EndIf
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} ValidModel
Efetua a validação do Model

@param   oModel   Objeto oModel
@author  Guilherme A. Metzger
@version P12
@since   27/12/2017
/*/
//----------------------------------------------------------
Static Function ValidModel(oModel)
Local oModelDCW := oModel:GetModel("WMSA320ADCW")
Local lRet      := .T.

	// Se for conferência de Prenota
	If oModelDCW:GetValue("DCW_TPCONF") == "1"
		lRet := AvalClass(oModel)
	EndIf

	If lRet
		lRet := DocNacImp(oModel)
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} AvalClass
Avalia se alguma das Prenotas selecionadas foi classificada
durante o processo de montagem da conferência
@author  Guilherme A. Metzger
@version P12
@since   14/06/2018
/*/
//----------------------------------------------------------
Static Function AvalClass(oModel)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local cDoctos   := ""
Local lRet      := .T.

	cQuery := "SELECT TMP.DO_DOC"
	cQuery +=  " FROM "+oTempTable:GetRealName()+" TMP"
	cQuery += " WHERE TMP.DO_MARK = '"+oBrwSD1:Mark()+"'"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM "+RetSqlName("SD1")+" SD1"
	cQuery +=                " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=                  " AND SD1.D1_DOC     = TMP.DO_DOC"
	cQuery +=                  " AND SD1.D1_SERIE   = TMP.DO_SERIE"
	cQuery +=                  " AND SD1.D1_FORNECE = TMP.DO_FORNECE"
	cQuery +=                  " AND SD1.D1_LOJA    = TMP.DO_LOJA"
	cQuery +=                  " AND SD1.D1_TES    <> ' '"
	cQuery +=                  " AND SD1.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			cDoctos += Iif(Empty(cDoctos),"",", ") + AllTrim((cAliasQry)->DO_DOC)
			(cAliasQry)->(DbSkip())
		EndDo
		oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSA320A03,STR0010,WmsFmtMsg(STR0011,{{"[VAR01]",cDoctos}})) // "Um ou mais dos documentos selecionados foram classificados durante o processo de montagem da conferência. Somente documentos sem classificação podem ser atribuídos a uma conferência de Prenotas." // "Remova os seguintes documentos da seleção: [VAR01]."
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DocNacImp
Verifica se foram selecionados documentos nacionais e documentos
recebidos através de importação
@author  Guilherme A. Metzger
@version P12
@since   27/12/2017
/*/
//----------------------------------------------------------
Static Function DocNacImp(oModel)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local lImport   := .F.
Local lNacion   := .F.

	cQuery := "SELECT 1"
	cQuery += " FROM "+RetSqlName("SF1")+" SF1"
	cQuery += " INNER JOIN "+RetSqlName("SD1")+" SD1"
	cQuery += " ON SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
	cQuery += " AND SF1.F1_DOC = SD1.D1_DOC"
	cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE"
	cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE"
	cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA"
	cQuery += " INNER JOIN "+oTempTable:GetRealName()+" TMP"
	cQuery += " ON SD1.D1_DOC = TMP.DO_DOC"
	cQuery += " AND SD1.D1_SERIE = TMP.DO_SERIE"
	cQuery += " AND SD1.D1_FORNECE = TMP.DO_FORNECE"
	cQuery += " AND SD1.D1_LOJA = TMP.DO_LOJA"
	cQuery += " WHERE TMP.DO_MARK    = '"+oBrwSD1:Mark()+"'"
	cQuery +=   " AND SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=   " AND SD1.D1_TIPO_NF = ' '" // Tipo Doc. - Nacional
	cQuery +=   " AND SD1.D1_QUANT   > 0"
	cQuery +=   " AND SD1.D1_OP      = ' '"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF1.F1_HAWB    = ' '" //No. Conhec. 
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lNacion := !(cAliasQry)->(Eof())
	(cAliasQry)->(DbCloseArea())

	cQuery := "SELECT 1"
	cQuery += " FROM "+RetSqlName("SF1")+" SF1"
	cQuery += " INNER JOIN "+RetSqlName("SD1")+" SD1"
	cQuery += " ON SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
	cQuery += " AND SF1.F1_DOC = SD1.D1_DOC"
	cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE"
	cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE"
	cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA"
	cQuery += " INNER JOIN "+oTempTable:GetRealName()+" TMP"
	cQuery += " ON SD1.D1_DOC = TMP.DO_DOC"
	cQuery += " AND SD1.D1_SERIE = TMP.DO_SERIE"
	cQuery += " AND SD1.D1_FORNECE = TMP.DO_FORNECE"
	cQuery += " AND SD1.D1_LOJA = TMP.DO_LOJA"
	cQuery += " WHERE TMP.DO_MARK    = '"+oBrwSD1:Mark()+"'"
	cQuery +=   " AND SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=   " AND SD1.D1_TIPO_NF = '1'" // Tipo Doc. - Importacao
	cQuery +=   " AND SD1.D1_QUANT   > 0"
	cQuery +=   " AND SD1.D1_OP      = ' '"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF1.F1_HAWB    <> ' '" //No. Conhec. 
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lImport := !(cAliasQry)->(Eof())
	(cAliasQry)->(DbCloseArea())

	If lImport .And. lNacion
		// Não é permitido agrupar numa mesma montagem documentos nacionais e documentos recebidos através do processo de importação (SIGAEIC).
		// Verifique os documentos selecionados.
		oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSA320A02,STR0008,STR0009)
		RestArea(aAreaAnt)
		Return .F.
	EndIf

RestArea(aAreaAnt)
Return .T.

//----------------------------------------------------------
// Geracao embarque conferencia
/*/{Protheus.doc} GravaDados
Geracao embarque conferencia
@param    oModel   Objeto oModel

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/08/12

/*/
//----------------------------------------------------------
Static Function GravaDados(oModel)
Local oModelDCW := oModel:GetModel('WMSA320ADCW')
Local oModelDCX := oModel:GetModel('WMSA320ADCX')
Local nOp       := (oModel:getOperation())
Local lAddDoc   := .F.
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local aEndereco := {}

	SF1->(DbSetOrder(1))
	(cAliasSF1)->( DbSetOrder(1) )
	(cAliasSF1)->( DbGoTop() )
	While lRet .And. (cAliasSF1)->(!Eof())
		If !Empty((cAliasSF1)->DO_MARK)
			DCX->(DbSetOrder(2)) // DCX_FILIAL+DCX_DOC+DCX_SERIE+DCX_FORNEC+DCX_LOJA
			// Valida para verificar se o documento já não se encontra em um processo de conferência
			If !DCX->(DbSeek(xFilial('DCX')+(cAliasSF1)->DO_DOC+(cAliasSF1)->DO_SERIE+(cAliasSF1)->DO_FORNECE+(cAliasSF1)->DO_LOJA))
				// Valida novamente para verificar se neste meio tempo não foi executado alguma atividade deste documento
				If !__lWmsNew
					cQuery := "SELECT DB_FILIAL"
					cQuery +=   "FROM "+RetSqlName("SDB")
					cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
					cQuery +=   " AND DB_DOC     = '"+(cAliasSF1)->DO_DOC+"'"
					cQuery +=   " AND DB_SERIE   = '"+(cAliasSF1)->DO_SERIE+"'"
					cQuery +=   " AND DB_CLIFOR  = '"+(cAliasSF1)->DO_FORNECE+"'"
					cQuery +=   " AND DB_LOJA    = '"+(cAliasSF1)->DO_LOJA+"'"
					cQuery +=   " AND DB_ATUEST  = 'N'"
					cQuery +=   " AND DB_ESTORNO = ' '"
					cQuery +=   " AND DB_ORIGEM  = 'SD1'"
					cQuery +=   " AND DB_STATUS <> '2'"
					cQuery +=   " AND D_E_L_E_T_ = ' '"
				Else
					cQuery := "SELECT D12_FILIAL"
					cQuery +=  " FROM "+RetSqlName("D12")+" D12, "+RetSqlName("DCF")+" DCF"
					cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
					cQuery +=   " AND DCF.DCF_DOCTO = '"+(cAliasSF1)->DO_DOC+"'"
					cQuery +=   " AND DCF.DCF_ORIGEM = 'SD1'"
					cQuery +=   " AND DCF.DCF_SERIE = '"+(cAliasSF1)->DO_SERIE+"'"
					cQuery +=   " AND DCF.DCF_CLIFOR = '"+(cAliasSF1)->DO_FORNECE+"'"
					cQuery +=   " AND DCF.DCF_LOJA = '"+(cAliasSF1)->DO_LOJA+"'"
					cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
					cQuery +=   " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
					cQuery +=   " AND (D12.D12_STATUS <> '0' AND D12.D12_STATUS <> '2')"
					cQuery +=   " AND D12.D12_IDDCF IN ( SELECT DCR.DCR_IDORI"
					cQuery +=                            " FROM "+RetSqlName("DCR")+" DCR"
					cQuery +=                           " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
					cQuery +=                             " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
					cQuery +=                             " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
					cQuery +=                             " AND DCR.D_E_L_E_T_ = ' ' )"
					cQuery +=   " AND D12.D_E_L_E_T_ = ' ' "
				EndIf
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->( Eof() )
					If !oModelDCX:IsEmpty()
						oModelDCX:addLine()
					EndIf
					oModelDCX:SetValue('DCX_FILIAL' , xFilial('DCX'))
					oModelDCX:SetValue('DCX_EMBARQ' , oModelDCW:GetValue('DCW_EMBARQ'))
					oModelDCX:SetValue('DCX_DOC'    , (cAliasSF1)->DO_DOC)
					oModelDCX:SetValue('DCX_SERIE'  , (cAliasSF1)->DO_SERIE)
					oModelDCX:SetValue('DCX_FORNEC' , (cAliasSF1)->DO_FORNECE)
					oModelDCX:SetValue('DCX_LOJA'   , (cAliasSF1)->DO_LOJA)
					If __lWmsNew
						oModelDCX:SetValue('DCX_QTVOLU' , (cAliasSF1)->DO_VOLUME1)
						oModelDCX:SetValue('DCX_CODUSU' , __cUserID)
					EndIf
					lAddDoc := .T.
				EndIf
				(cAliasQry)->( DbCloseArea() )
			EndIf
		EndIf
		(cAliasSF1)->( dbSkip() )
	EndDo


	If lAddDoc
		If (lRet := ValEndDocs(oModelDCW:GetValue("DCW_EMBARQ"),aEndereco))
			// Deve chamar a função de gravação adicional no bloco de código para garantir a integridade da transação
			lRet := FwFormCommit(oModel,,{|oModel,cID,cAlias| PosAtuMVC(oModel,cID,cAlias)},,{||InTSAtuMVC(oModelDCW:GetValue("DCW_EMBARQ"),aEndereco)})
		EndIf
	Else
		If nOp == 3
			RollBackSXE()
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
//Bloco de código que será executado dentro da transação
//-------------------------------------------------------------------
Static Function InTSAtuMVC(cEmbarque,aEndereco)
Local lRet := .T.
	// Atualizando os itens para serem conferidos
	If lRet .And. Len(aEndereco) > 0
		If !DocAtuEnd(cEmbarque,aEndereco)
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
// Função para atualização das informações complementares com base no
// documento que está sendo inserido no processo de conferência
//-------------------------------------------------------------------
Static Function PosAtuMVC(oModel,cID,cAlias)
Local cEmbarque := ""
Local cDocto    := ""
Local cSerie    := ""
Local cFornec   := ""
Local cLoja     := ""
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD0Q := ""
Local oDmdUnit  := Nil

	If cID == 'WMSA320ADCX' // Se está gravando os documentos

		cEmbarque := oModel:GetValue("DCX_EMBARQ")
		cDocto    := oModel:GetValue("DCX_DOC")
		cSerie    := oModel:GetValue("DCX_SERIE")
		cFornec   := oModel:GetValue("DCX_FORNEC")
		cLoja     := oModel:GetValue("DCX_LOJA")
		// Atualizando a situação da nota fiscal para Em Processo Conferencia
		If (lRet := SF1->(DbSeek(xFilial("SF1")+cDocto+cSerie+cFornec+cLoja)))
			If (lRet := RecLock("SF1",.F.))
				SF1->F1_STATCON := "3"
				SF1->(MsUnlock())
			EndIf
		EndIF

		If WmsX212118("D0Q")
			cQuery := " SELECT D0Q.R_E_C_N_O_ RECNOD0Q"
			cQuery +=   " FROM "+RetSqlName('D0Q')+" D0Q"
			cQuery +=  " WHERE D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
			cQuery +=    " AND D0Q.D0Q_DOCTO  = '"+oModel:GetValue("DCX_DOC")+"'"
			cQuery +=    " AND D0Q.D0Q_SERIE  = '"+oModel:GetValue("DCX_SERIE")+"'"
			cQuery +=    " AND D0Q.D0Q_CLIFOR = '"+oModel:GetValue("DCX_FORNEC")+"'"
			cQuery +=    " AND D0Q.D0Q_LOJA   = '"+oModel:GetValue("DCX_LOJA")+"'"
			cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasD0Q := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0Q,.F.,.T.)
			oDmdUnit := WMSDTCDemandaUnitizacao():New()
			While (cAliasD0Q)->(!EoF())
				oDmdUnit:GoToD0Q((cAliasD0Q)->RECNOD0Q)
				oDmdUnit:ExcludeD0Q()
				(cAliasD0Q)->(dbSkip())
			EndDo
			(cAliasD0Q)->(dbCloseArea())
		EndIf

		// Atualizando os itens para serem conferidos
		If lRet .And. !DocAtuDCY(cEmbarque,cDocto,cSerie,cFornec,cLoja)
			lRet := .F.
		EndIf
		// Atualiza a quantidade total de volumes no DCW
		If lRet .And. __lWmsNew
			If !DocAtuDCW(cEmbarque)
				lRet := .F.
			EndIf
			//Grava o documento de conferencia nas ordens de serviços do WMS
			If lRet .And. !GrvCofDCFxD12(cDocto,cSerie,cFornec,cLoja,cEmbarque)
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Monta Pedidos
Monta pedidos

@author Alexsander Burigo Corrêa
@since 04/12/12
/*/
//-------------------------------------------------------------------
Static Function MontaSD1(oPnlSD1, oBrwSD1)
Local aColsSD1    := {}
Local aColsSX3    := {}
Local lMarcar     := .F.
	// Campos adicionais
	aColsSD1:= {;
		{ BuscarSX3('D1_DOC',,aColsSX3)     ,{|| (cAliasSF1)->DO_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ BuscarSX3('D1_SERIE',,aColsSX3)   ,{|| (cAliasSF1)->DO_SERIE}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ BuscarSX3('D1_FORNECE',,aColsSX3) ,{|| (cAliasSF1)->DO_FORNECE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ BuscarSX3('A1_NOME',,aColsSX3)    ,{|| (cAliasSF1)->DO_NMCLFOR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ BuscarSX3('D1_LOJA',,aColsSX3)    ,{|| (cAliasSF1)->DO_LOJA}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ BuscarSX3('D1_DTDIGIT',,aColsSX3) ,{|| (cAliasSF1)->DO_DTDIGIT},'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{ STR0003                           ,{|| (cAliasSF1)->DO_VOLUME1},'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}} //"Volume NFe"

	oBrwSD1 := FWMarkBrowse():New()
	oBrwSD1:SetAlias(cAliasSF1)
	oBrwSD1:SetOwner(oPnlSD1)
	oBrwSD1:SetFields(aColsSD1)
	oBrwSD1:SetFieldMark( 'DO_MARK' )
	oBrwSD1:bAllMark := { || SetMarkAll(oBrwSD1:Mark(),lMarcar := !lMarcar ), oBrwSD1:Refresh(.T.)  }
	oBrwSD1:SetMenuDef('')
	oBrwSD1:oBrowse:SetFixedBrowse(.T.)
	oBrwSD1:SetDescription(BuscarSX3('D1_DOC',,aColsSX3)) // Pedidos
	oBrwSD1:Activate()
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Marca Todos

@author Alexsander Burigo Corrêa
@since 04/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar )
Local aAreaSF1  := (cAliasSF1)->( GetArea() )
	dbSelectArea(cAliasSF1)
	(cAliasSF1)->( dbGoTop() )
	While !(cAliasSF1)->( Eof() )
		RecLock( (cAliasSF1), .F. )
		(cAliasSF1)->DO_MARK := IIf( lMarcar, cMarca, '  ' )
		MsUnlock()
		(cAliasSF1)->( dbSkip() )
	EndDo
	RestArea( aAreaSF1 )
Return .T.
//-------------------------------------------------------------------
// Atualiza a tabela de itens da conferência de acordo com o
// documento que está sendo inserido no processo de conferência
//-------------------------------------------------------------------
Static Function DocAtuDCY(cEmbarque,cDocto,cSerie,cFornec,cLoja)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasConf := ""
Local cAliasComp := ""
Local cAliasQry  := GetNextAlias()
Local aTamSx3    := TamSx3('D1_QUANT')
Local nI         := 0
Local oProdComp  := IIf(__lWmsNew,WMSDTCProdutoComponente():New(),Nil)
Local lDtValid   := DCY->(ColumnPos("DCY_DTVAL")) > 0
Local lD0kPed    := D0K->(ColumnPos("D0K_PEDIDO")) > 0
Local lD0kEnd    := D0K->(ColumnPos("D0K_ENDER")) > 0
Local lD0kServ   := D0K->(ColumnPos("D0K_SERVIC")) > 0
Local lWMA320DT  := ExistBlock("WMA320DT")

	cQuery := "SELECT D1_ITEM,"
	cQuery +=       " D1_LOCAL,"
	cQuery +=       " D1_COD,"
	cQuery +=       " D1_LOTECTL,"
	cQuery +=       " D1_NUMLOTE,"
	cQuery +=       " D1_QUANT,"
	cQuery +=       " D1_DTVALID,"
	cQuery +=       " D1_PEDIDO,"
	cQuery +=       " D1_ITEMPC,"
	cQuery +=       " D1_ENDER,"
	cQuery +=       " D1_SERVIC"
	cQuery +=  " FROM "+RetSqlName('SD1')
	cQuery += " WHERE D1_FILIAL  = '"+xFilial('SD1')+"'"
	cQuery +=   " AND D1_DOC     = '"+cDocto+"'"
	cQuery +=   " AND D1_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND D1_FORNECE = '"+cFornec+"'"
	cQuery +=   " AND D1_LOJA    = '"+cLoja+"'"
	cQuery +=   " AND D1_QUANT   > 0"
	cQuery +=   " AND D1_OP      = ' '"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D1_ITEM"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TCSetField(cAliasQry,'D1_QUANT','N',aTamSx3[1],aTamSx3[2])
	DCY->(DbSetOrder(1)) //DCY_FILIAL+DCY_EMBARQ+DCY_PRDORI+DCY_PROD+DCY_LOTE+DCY_SUBLOT+DCY_LOCAL
	While (cAliasQry)->(!Eof())
		// Se o produto/lote já existir na conferência, só incrementa as quantidades
		cAliasConf := GetNextAlias()
		BeginSql Alias cAliasConf
			SELECT R_E_C_N_O_ RECNODCY
			  FROM %Table:DCY% DCY
			 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
			   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			   AND DCY.DCY_PRDORI = %Exp:(cAliasQry)->D1_COD%
			   AND DCY.DCY_PROD   = %Exp:(cAliasQry)->D1_COD%
			   AND DCY.DCY_LOTE   = %Exp:(cAliasQry)->D1_LOTECTL%
			   AND DCY.DCY_SUBLOT = %Exp:(cAliasQry)->D1_NUMLOTE%
			   AND DCY.DCY_LOCAL  = %Exp:(cAliasQry)->D1_LOCAL%
			   AND DCY.%NotDel%
		EndSql
		If (cAliasConf)->(!EoF())
			DCY->(DbGoTo((cAliasConf)->RECNODCY))
			RecLock("DCY",.F.)
				DCY->DCY_QTORIG += (cAliasQry)->D1_QUANT
			DCY->(MsUnlock())
			// Se for Novo WMS, deve verificar se é produto componente
			If __lWmsNew
				oProdComp:SetPrdOri((cAliasQry)->D1_COD)
				If oProdComp:LoadData(3) .And. oProdComp:GetNivel() == 1
					oProdComp:EstProduto()
					For nI := 1 To Len(oProdComp:GetArrProd())
						cAliasComp := GetNextAlias()
						BeginSql Alias cAliasComp
							SELECT DCY.R_E_C_N_O_ RECNODCY
							FROM %Table:DCY% DCY
							WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
							AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
							AND DCY.DCY_PRDORI = %Exp:(cAliasQry)->D1_COD%
							AND DCY.DCY_PROD   = %Exp:oProdComp:GetArrProd()[nI,1]%
							AND DCY.DCY_LOTE   = %Exp:(cAliasQry)->D1_LOTECTL%
							AND DCY.DCY_SUBLOT = %Exp:(cAliasQry)->D1_NUMLOTE%
							AND DCY.DCY_LOCAL  = %Exp:(cAliasQry)->D1_LOCAL%
							AND DCY.%NotDel%
						EndSql
						If (cAliasComp)->(!EoF())
							DCY->(DbGoTo((cAliasComp)->RECNODCY))
							RecLock("DCY",.F.)
							DCY->DCY_QTORIG += (cAliasQry)->D1_QUANT * oProdComp:GetArrProd()[nI,2]
							DCY->(MsUnlock())
						Endif
						(cAliasComp)->(DbCloseArea())
					Next nI
				EndIf
			EndIf
		Else
			// Caso contrário, cria um novo registro
			RecLock('DCY',.T.)
			DCY->DCY_FILIAL := xFilial('DCY')
			DCY->DCY_EMBARQ := cEmbarque
			DCY->DCY_PROD   := (cAliasQry)->D1_COD
			DCY->DCY_LOTE   := (cAliasQry)->D1_LOTECTL
			DCY->DCY_SUBLOT := (cAliasQry)->D1_NUMLOTE
			DCY->DCY_QTORIG := (cAliasQry)->D1_QUANT
			DCY->DCY_QTCONF := 0
			DCY->DCY_PRDORI := (cAliasQry)->D1_COD
			DCY->DCY_LOCAL  := (cAliasQry)->D1_LOCAL
			If lDtValid .And. !Empty((cAliasQry)->D1_LOTECTL) .And. !Empty((cAliasQry)->D1_DTVALID)
				DCY->DCY_DTVAL  := SToD((cAliasQry)->D1_DTVALID)
			EndIf
			DCY->(MsUnlock())
			
			If lWMA320DT
				ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})                                                                                       
			EndIf
			// Se for Novo WMS, deve verificar se é produto componente
			If __lWmsNew
				oProdComp:SetPrdOri((cAliasQry)->D1_COD)
				If oProdComp:LoadData(3) .And. oProdComp:GetNivel() == 1
					oProdComp:EstProduto()
					For nI := 1 To Len(oProdComp:GetArrProd())
						RecLock('DCY',.T.)
						DCY->DCY_FILIAL := xFilial('DCY')
						DCY->DCY_EMBARQ := cEmbarque
						DCY->DCY_PROD   := oProdComp:GetArrProd()[nI,1] // Produto componente
						DCY->DCY_LOTE   := (cAliasQry)->D1_LOTECTL
						DCY->DCY_SUBLOT := (cAliasQry)->D1_NUMLOTE
						DCY->DCY_QTORIG := (cAliasQry)->D1_QUANT * oProdComp:GetArrProd()[nI,2]
						DCY->DCY_QTCONF := 0
						DCY->DCY_PRDORI := (cAliasQry)->D1_COD
						DCY->DCY_LOCAL  := (cAliasQry)->D1_LOCAL
						If lDtValid .And. !Empty((cAliasQry)->D1_LOTECTL) .And. !Empty((cAliasQry)->D1_DTVALID)
							DCY->DCY_DTVAL  := SToD((cAliasQry)->D1_DTVALID)
						EndIf
						DCY->(MsUnlock())
						
						If lWMA320DT
							ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
						EndIf
					Next
				EndIf
			EndIf
		EndIf
		(cAliasConf)->(DbCloseArea())
		
		// Grava o relacionamento dos itens do documento com a conferência
		RecLock('D0K',.T.)
		D0K->D0K_FILIAL := xFilial('D0K')
		D0K->D0K_EMBARQ := cEmbarque
		D0K->D0K_DOC    := cDocto
		D0K->D0K_SERIE  := cSerie
		D0K->D0K_FORNEC := cFornec
		D0K->D0K_LOJA   := cLoja
		D0K->D0K_ITEM   := (cAliasQry)->D1_ITEM
		D0K->D0K_LOCAL  := (cAliasQry)->D1_LOCAL
		D0K->D0K_PROD   := (cAliasQry)->D1_COD
		D0K->D0K_LOTE   := (cAliasQry)->D1_LOTECTL
		D0K->D0K_SUBLOT := (cAliasQry)->D1_NUMLOTE
		D0K->D0K_QUANT  := (cAliasQry)->D1_QUANT
		IF lD0kPed
			D0K->D0K_PEDIDO := (cAliasQry)->D1_PEDIDO
			D0K->D0K_ITEMPC := (cAliasQry)->D1_ITEMPC
		EndIf
		If lDtValid
			D0K->D0K_DTVAL := SToD((cAliasQry)->D1_DTVALID)
		EndIf
		If lD0kEnd
			D0K->D0K_ENDER := (cAliasQry)->D1_ENDER
		EndIf
		If lD0kServ
			D0K->D0K_SERVIC := (cAliasQry)->D1_SERVIC
		EndIf

		D0K->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} DocAtuDCW
Atualiza a quantidade total de volumes na DCW

@author  Reinaldo Dias
@version P11
@since   19/09/2015
/*/
//----------------------------------------------------------
Static Function DocAtuDCW(cEmbarque)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDCX := GetNextAlias()
Local nQtdVolu  := 0
Local aTamSx3   := TamSX3('DCX_QTVOLU')

// Inicia a busca dos registros para gravar o codigo do documento de conferencia
cQuery := " SELECT SUM(DCX_QTVOLU) DCX_QTVOLU"
cQuery += " FROM "+RetSqlName("DCX")+" DCX"
cQuery += " WHERE DCX.DCX_FILIAL = '"+xFilial("DCX")+"'"
cQuery += " AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
cQuery += " AND DCX.D_E_L_E_T_ = ' '"
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCX,.F.,.T.)
TcSetField( cAliasDCX,'DCX_QTVOLU','N',aTamSx3[1],aTamSx3[2])
If (cAliasDCX)->(!Eof())
	nQtdVolu := (cAliasDCX)->DCX_QTVOLU
EndIf
(cAliasDCX)->(DbCloseArea())

// Grava a quantidade total de volumes.
RecLock('DCW',.F.)
DCW->DCW_QTVOLU := nQtdVolu
DCW->(MsUnlock())

RestArea(aAreaAnt)

Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} GrvCofDCFxD12
Grava o documento de conferencia apos a classificacao da nota fiscal de entrada na DCF e na D12.

@author  Reinaldo Dias
@version P11
@since   12/09/2015
/*/
//----------------------------------------------------------
Function GrvCofDCFxD12(cDocto,cSerie,cFornec,cLoja,cEmbarque)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasSD1 := GetNextAlias()

// Deve atualizar a situação dos documentos
cQuery := "SELECT SD1.R_E_C_N_O_ RECNOSD1"
cQuery +=  " FROM "+RetSqlName('SD1')+" SD1"
cQuery += " WHERE SD1.D1_FILIAL   = '"+xFilial("SD1")+"'"
cQuery +=   " AND SD1.D1_DOC      = '"+cDocto+"'"
cQuery +=   " AND SD1.D1_SERIE    = '"+cSerie+"'"
cQuery +=   " AND SD1.D1_FORNECE  = '"+cFornec+"'"
cQuery +=   " AND SD1.D1_LOJA     = '"+cLoja+"'"
cQuery +=   " AND SD1.D1_QUANT    > 0"
cQuery +=   " AND SD1.D1_IDDCF   <> '"+Space(6)+"'"
cQuery +=   " AND SD1.D_E_L_E_T_  = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
While (cAliasSD1)->(!Eof())
  SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
  //Grava o documento de conferencia
  GrvCofDCF(cEmbarque)
 (cAliasSD1)->(DbSkip())
EndDo
(cAliasSD1)->(DbCloseArea())

RestArea(aAreaAnt)

Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} GrvCofDCF
Grava o documento de conferencia na tabela DCF, apos classi-
ficacao do documento de entrada.

@author  Reinaldo Dias
@version P11
@since   12/09/2015
/*/
//----------------------------------------------------------
Static Function GrvCofDCF(cEmbarque)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDCF := GetNextAlias()

cQuery := "SELECT R_E_C_N_O_ RECNODCF"
cQuery +=  " FROM " + RetSqlName('DCF')
cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
cQuery +=   " AND DCF_ID     = '"+SD1->D1_IDDCF+"'"
cQuery +=   " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
If (cAliasDCF)->(!Eof())
	// Posiciona na ordem de serviço
	DCF->(DbGoTo((cAliasDCF)->RECNODCF))

	// Caso a ordem de serviço já tenha sido executada,
	// deve subtrair a quantidade faltante da D12 e DCR
	If DCF->DCF_STSERV == '3'
	   GrvCofD12(cEmbarque)
	EndIf

	// Desconta a quantidade faltante ou deleta o registro
	RecLock('DCF')
	DCF->DCF_CODREC := cEmbarque
	DCF->(MsUnlock())
EndIf
(cAliasDCF)->(DbCloseArea())

RestArea(aAreaAnt)

Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} GrvCofD12
Grava o documento de conferencia na tabela D12, apos classi-
ficacao do documento de entrada.

@author  Reinaldo Dias
@version P11
@since   12/09/2015
/*/
//----------------------------------------------------------
Static Function GrvCofD12(cEmbarque)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasD12 := GetNextAlias()

// Inicia a busca dos registros para gravar o codigo do documento de conferencia
cQuery := " SELECT D12.R_E_C_N_O_ RECNOD12"
cQuery +=  " FROM "+RetSqlName("DCR")+" DCR, "+RetSqlName("D12")+" D12"
cQuery += " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
cQuery +=   " AND DCR.DCR_IDDCF  = '"+DCF->DCF_ID+"'"
cQuery +=   " AND DCR.DCR_SEQUEN = '"+DCF->DCF_SEQUEN+"'"
cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
cQuery +=   " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
cQuery +=   " AND D12.D12_IDDCF  = DCR.DCR_IDORI"
cQuery +=   " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
cQuery +=   " AND D12.D12_STATUS <> '0'"
cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
If (cAliasD12)->(!Eof())
	While (cAliasD12)->(!Eof())
		D12->(DbGoTo((cAliasD12)->RECNOD12))
		// Grava o documento de conferencia.
		RecLock('D12')
		D12->D12_CODREC := cEmbarque
		D12->(MsUnlock())
		(cAliasD12)->(DbSkip())
	EndDo
Endif
(cAliasD12)->(DbCloseArea())

RestArea(aAreaAnt)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} ValEndDocs
Valida endereço dos documentos da conferência.
Em um mesmo armazém unitizado todos os endereços devem ser iguais, caso contrário deve solicitar o endereço.
@author  Amanda Rosa Vieira
@version P12
@since   02/05/2017
/*/
//----------------------------------------------------------
Static Function ValEndDocs(cEmbarque,aEndereco)
Local lRet      := .T.
Local cEndereco := ""
Local cQuery    := ""
Local cAliasSD1 := ""

	aEndereco := {}
	If WmsX212118("D0Y")
		cQuery := "SELECT SD1A.D1_LOCAL"
		cQuery +=  " FROM "+oTempTable:GetRealName()+" TMP1,"
		cQuery +=           RetSqlName('SD1')+" SD1A,"
		cQuery +=           RetSqlName('NNR')+" NNR"
		cQuery += " WHERE TMP1.DO_MARK    = '"+oBrwSD1:Mark()+"'"
		cQuery +=   " AND TMP1.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SD1A.D1_FILIAL  = '"+xFilial("SD1")+"'"
		cQuery +=   " AND SD1A.D1_DOC     = TMP1.DO_DOC"
		cQuery +=   " AND SD1A.D1_SERIE   = TMP1.DO_SERIE"
		cQuery +=   " AND SD1A.D1_FORNECE = TMP1.DO_FORNECE"
		cQuery +=   " AND SD1A.D1_LOJA    = TMP1.DO_LOJA"
		cQuery +=   " AND SD1A.D1_QUANT   > 0"
		cQuery +=   " AND SD1A.D1_OP      = ' '"
		cQuery +=   " AND SD1A.D_E_L_E_T_ = ' '"
		cQuery +=   " AND NNR.NNR_FILIAL  = '"+xFilial("NNR")+"'"
		cQuery +=   " AND NNR.NNR_CODIGO  = SD1A.D1_LOCAL"
		cQuery +=   " AND NNR.NNR_AMZUNI  = '1'"
		cQuery +=   " AND NNR.D_E_L_E_T_  = ' '"
		cQuery +=   " AND ( SD1A.D1_ENDER = '"+Space(TamSX3("D1_ENDER")[1])+"'"
		cQuery +=         " OR EXISTS (SELECT 1"
		cQuery +=                      " FROM "+oTempTable:GetRealName()+" TMP2,"
		cQuery +=                               RetSqlName('SD1')+" SD1B,"
		cQuery +=                               RetSqlName('NNR')+" NNR2"
		cQuery +=                     " WHERE TMP2.DO_MARK    = '"+oBrwSD1:Mark()+"'"
		cQuery +=                       " AND TMP2.D_E_L_E_T_ = ' '"
		cQuery +=                       " AND SD1B.D1_FILIAL  = '"+xFilial("SD1")+"'"
		cQuery +=                       " AND SD1B.D1_DOC     = TMP2.DO_DOC"
		cQuery +=                       " AND SD1B.D1_SERIE   = TMP2.DO_SERIE"
		cQuery +=                       " AND SD1B.D1_FORNECE = TMP2.DO_FORNECE"
		cQuery +=                       " AND SD1B.D1_LOJA    = TMP2.DO_LOJA"
		cQuery +=                       " AND SD1B.D1_QUANT   > 0"
		cQuery +=                       " AND SD1B.D1_OP      = ' '"
		cQuery +=                       " AND SD1B.D_E_L_E_T_ = ' '"
		cQuery +=                       " AND NNR2.NNR_FILIAL = '"+xFilial("SD1")+"'"
		cQuery +=                       " AND NNR2.NNR_CODIGO = SD1B.D1_LOCAL"
		cQuery +=                       " AND NNR2.NNR_AMZUNI = '1'"
		cQuery +=                       " AND NNR2.D_E_L_E_T_ = ' '"
		cQuery +=                       " AND SD1B.D1_LOCAL   = SD1A.D1_LOCAL"
		cQuery +=                       " AND SD1B.D1_ENDER  <> SD1A.D1_ENDER"
		cQuery +=                       " AND SD1B.D1_NUMSEQ <> SD1A.D1_NUMSEQ"
		cQuery +=                       " AND SD1B.D_E_L_E_T_ = ' '))"
		cQuery += " GROUP BY SD1A.D1_LOCAL"
		cQuery := ChangeQuery(cQuery)
		cAliasSD1 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
		While !(cAliasSD1)->(Eof())
			cEndereco := ""
			If DLPergEnd(@cEndereco, .F., .T., "1", (cAliasSD1)->D1_LOCAL)
				AAdd(aEndereco,{(cAliasSD1)->D1_LOCAL,cEndereco})
			Else
				lRet := .F.
				Exit
			EndIf
			(cAliasSD1)->(DbSkip())
		EndDo
		(cAliasSD1)->(DbCloseArea())
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} DocAtuEnd
Ajusta D14 quando ocorre a troca de endereço.
@author  Amanda Rosa Vieira
@version P12
@since   02/05/2017
/*/
//----------------------------------------------------------
Static Function DocAtuEnd(cEmbarque,aEndereco)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasSD1  := ""
Local cAliasD0R  := ""
Local nProduto   := 1
Local aProduto   := {}
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local aD0KArea   := D0K->(GetArea())
	//Busca todas as SD1 que precisam ser alteradas
	cQuery := " SELECT SD1.R_E_C_N_O_ RECNOSD1,"
	cQuery +=        " SD1.D1_LOCAL,"
	cQuery +=        " SD1.D1_ENDER,"
	cQuery +=        " SD1.D1_DOC,"
	cQuery +=        " SD1.D1_SERIE,"
	cQuery +=        " SD1.D1_FORNECE,"
	cQuery +=        " SD1.D1_LOJA,"
	cQuery +=        " SD1.D1_COD,"
	cQuery +=        " SD1.D1_NUMSEQ,"
	cQuery +=        " SD1.D1_LOTECTL,"
	cQuery +=        " SD1.D1_NUMLOTE,"
	cQuery +=        " SD1.D1_QUANT,"
	cQuery +=        " SD1.D1_TES,"
	cQuery +=        " SD1.D1_ITEM"
	cQuery +=   " FROM "+RetSqlName('DCX')+" DCX"
	cQuery +=  " INNER JOIN "+RetSqlName('SD1')+" SD1"
	cQuery +=     " ON SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
	cQuery +=    " AND SD1.D1_DOC = DCX.DCX_DOC"
	cQuery +=    " AND SD1.D1_SERIE = DCX.DCX_SERIE"
	cQuery +=    " AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
	cQuery +=    " AND SD1.D1_LOJA = DCX.DCX_LOJA"
	cQuery +=    " AND SD1.D1_QUANT > 0"
	cQuery +=    " AND SD1.D1_OP = ' '"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
	cQuery +=    " AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCX.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSD1 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
	While (cAliasSD1)->(!EoF())
		nI := aScan(aEndereco,{|x| x[1] == (cAliasSD1)->D1_LOCAL})

		If nI > 0
			//Verifica se o endereço do documento é diferente do endereço informado pelo usuário
			If aEndereco[nI][2]  != (cAliasSD1)->D1_ENDER

				cQuery := " SELECT D0R.R_E_C_N_O_ RECNOD0R"
				cQuery += " FROM "+RetSqlName('DCZ')+" DCZ"
				cQuery += " INNER JOIN "+RetSqlName('D0R')+" D0R"
				cQuery += " ON D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
				cQuery += " AND D0R.D0R_IDUNIT = DCZ.DCZ_IDUNIT"
				cQuery += " AND D0R_LOCAL = '"+aEndereco[nI][1]+"'"
				cQuery += " AND D0R_ENDER <> '"+aEndereco[nI][2]+"'"
				cQuery += " AND D0R.D_E_L_E_T_ = ' '"
				cQuery += " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
				cQuery += " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
				cQuery += " AND DCZ.DCZ_PRDORI = '"+(cAliasSD1)->D1_COD+"'"
				cQuery += " AND DCZ.DCZ_LOTE = '"+(cAliasSD1)->D1_LOTECTL+"'"
				cQuery += " AND DCZ.DCZ_SUBLOT = '"+(cAliasSD1)->D1_NUMLOTE+"'"
				cQuery += " AND DCZ.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasD0R := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0R,.F.,.T.)
				While (cAliasD0R)->(!EoF())
					DbGoTo((cAliasD0R)->RECNOD0R)
					If (lRet := RecLock("D0R",.F.))
						D0R->D0R_ENDER := aEndereco[nI][2]
						D0R->(MsUnlock())
					EndIf
					(cAliasD0R)->(dbSkip())
				EndDo
				(cAliasD0R)->(dbCloseArea())

				//Ajusta endereço SD1
				SD1->(dbGoto((cAliasSD1)->RECNOSD1))
				If (lRet := RecLock("SD1",.F.))
					SD1->D1_ENDER := aEndereco[nI][2]
					SD1->(MsUnlock())
				EndIf

				//Usuário digitou endereco na confirmacao da geracao do embarque, pois a pre-nota nao tinha endereco
				D0K->(DbSetOrder(1))
				If D0K->(DbSeek(FwXFilial("D0K")+cEmbarque+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEM))
					RecLock("D0K",.F.)
					D0K->D0K_ENDER := aEndereco[nI][2]
					D0K->(MsUnlock())
				EndIf

				If  lRet .And. !Empty((cAliasSD1)->D1_TES)
					// Carrega estrutura do produto x componente
					oEstEnder:oProdLote:SetPrdOri((cAliasSD1)->D1_COD)
					oEstEnder:oProdLote:SetProduto((cAliasSD1)->D1_COD)
					oEstEnder:oProdLote:SetArmazem((cAliasSD1)->D1_LOCAL)
					oEstEnder:oProdLote:SetLoteCtl((cAliasSD1)->D1_LOTECTL)
					oEstEnder:oProdLote:SetNumLote((cAliasSD1)->D1_NUMLOTE)
					oEstEnder:oProdLote:LoadData()
					aProduto := oEstEnder:oProdLote:GetArrProd()
					//Remove saldo D14
					If Len(aProduto) > 0
						For nProduto := 1 To Len(aProduto)
							// Carrega dados para Estoque por Endereço
							oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])
							oEstEnder:oEndereco:SetArmazem((cAliasSD1)->D1_LOCAL)
							oEstEnder:oEndereco:SetEnder((cAliasSD1)->D1_ENDER)
							oEstEnder:LoadData()
							oEstEnder:SetQuant(QtdComp((cAliasSD1)->D1_QUANT * aProduto[nProduto][2]) )
							// Realiza Saída Armazem Estoque por Endereço
							oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/)
						Next nProduto
					EndIf

					//Refaz saldo no novo endereço
					If Len(aProduto) > 0
						For nProduto := 1 To Len(aProduto)
							// Carrega dados para Estoque por Endereço
							oEstEnder:oEndereco:SetArmazem((cAliasSD1)->D1_LOCAL)
							oEstEnder:oEndereco:SetEnder(aEndereco[nI][2])
							oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])
							oEstEnder:LoadData()
							oEstEnder:SetQuant(QtdComp((cAliasSD1)->D1_QUANT * aProduto[nProduto][2]) )
							// Realiza Entrada Armazem Estoque por Endereço
							oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/)
						Next nProduto
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasSD1)->(DbSkip())
	EndDo
	(cAliasSD1)->(DbCloseArea())
	RestArea(aD0KArea)
Return lRet
