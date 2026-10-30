#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA412A.CH"
//----------------------------------------------------------
/*/{Protheus.doc} WMSA412A
ModelDef utilizado apra mostrar os produtos conferidos de um operador.
@author  Amanda Rosa Vieira
@version P12
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Function WMSA412A()
Return Nil

Static Function ModelDef()
Local oModel     := Nil
Local oStructD03 := FWFormStruct(1,'D03')
Local oStructD04 := FWFormStruct(1,'D04')
Local cCodOpe    := D03->D03_CODOPE

	oStructD03:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStructD04:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oModel := MPFormModel():New('WMSA412', /*bPre*/, /*bPost*/, {|oModel|CommitModel()}/*bCommit*/, /*bCancel*/)

	oModel:AddFields('A412D03' , Nil  ,oStructD03 , /*bPre*/, /*bPost*/, /*bLoad*/)

	// Operadores - D04
	oStructD04:SetProperty('D04_DESPRO',MODEL_FIELD_INIT,{|| POSICIONE("SB1",1,xFilial("SB1")+D04->D04_CODPRO,"B1_DESC")})
	oStructD04:SetProperty('D04_NOMOPE',MODEL_FIELD_INIT,{|| POSICIONE('DCD',1,xFilial('DCD')+D04->D04_CODOPE,'DCD_NOMFUN')})

	oModel:AddGrid( 'A412D04', 'A412D03'  , oStructD04, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( 'A412D04', {{'D04_FILIAL',"xFilial('D04')"},{'D04_CODEXP','D03_CODEXP'},{'D04_CARGA','D03_CARGA'},{'D04_PEDIDO','D03_PEDIDO'}} , D04->( IndexKey(1) )  )
	oModel:GetModel( 'A412D04' ):SetDescription(STR0001) // Itens Operador

	oModel:GetModel( 'A412D04' ):SetLoadFilter({{'D04_CODOPE' ,"'"+cCodOpe+"'",1}})

	oModel:GetModel('A412D04'):SetNoInsertLine( .T. )
	oModel:GetModel('A412D04'):SetNoDeleteLine( .T. )
	oModel:GetModel('A412D04'):SetNoUpdateLine( .T. )
	oModel:GetModel('A412D04'):SetOptional( .T. )

	oModel:SetDescription(STR0003) //Monitor
	oModel:GetModel("A412D03"):SetDescription(STR0002) //Expedição
	oModel:SetPrimaryKey({"D03_FILIAL","D03_CODEXP","D03_CARGA","D03_PEDIDO"})

	oModel:SetActivate({|oModel| ActiveMdl(oModel) })
Return oModel
//----------------------------------------------------------
/*/{Protheus.doc} WMSA412A
ViewDef
@author  Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FWLoadModel('WMSA412A')

Local oStructD03 := FWFormStruct(2,'D03')
Local oStructD04 := FWFormStruct(2,'D04')

	// Remove Campos D04
	oStructD04:RemoveField('D04_FILIAL')

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('MASTER',0,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:CreateHorizontalBox('DETAIL',100)

	oView:AddField('A412D03' ,oStructD03)

	oView:CreateFolder('IDFOLDER','DETAIL')

	oView:AddSheet('IDFOLDER','IDSHEET01',STR0001) //Itens Operador
	oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
	oView:AddGrid('A412D04', oStructD04)
	oView:SetOnlyView('A412D04')
	oView:SetOwnerView('A412D04', 'DETAIL_1')

	oView:SetOwnerView('A412D03','MASTER')
	oView:SetUseCursor(.F.)
Return oView
//----------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
Realiza alguma alteração no modelo
@author  Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function ActiveMdl(oModel)
	oModel:GetModel('A412D04'):SetNoUpdateLine( .F. )
	oModel:GetModel("A412D04"):SetValue("D04_QTCONF", oModel:GetModel("A412D04"):GetValue("D04_QTCONF"))
	oModel:GetModel('A412D04'):SetNoUpdateLine( .T. )
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} CommitModel
Estorna Operadores a partir do folder Operadores
@author  Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function CommitModel()
Local aAreaD01  := D02->(GetArea())
Local aAreaD02  := D02->(GetArea())
Local aAreaD03  := D02->(GetArea())
Local aAreaD04  := D04->(GetArea())
Local aAreaDCU  := DCU->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aDados    := {}
Local nRecnoD03 := D03->(Recno())
Local cQuery    := ""
Local cAliasD04 := ""
	Begin Transaction
		D03->(dbGoTo(nRecnoD03))
		//Monta array para chamar função de estorno
		cQuery := " SELECT D04_CODPRO,"
		cQuery +=        " D04_QTCONF,"
		cQuery +=        " D04_CARGA,"
		cQuery +=        " D04_PEDIDO,"
		cQuery +=        " D04_LOTE,"
		cQuery +=        " D04_SUBLOT,"
		cQuery +=        " D04_ITEM,"
		cQuery +=        " D04_SEQUEN,"
		cQuery +=        " D04_PRDORI,"
		cQuery +=        " D04_CODEXP"
		cQuery +=   " FROM "+RetSqlName('D04')
		cQuery +=  " WHERE D04_FILIAL = '"+xFilial('D04')+"'"
		cQuery +=    " AND D04_CODEXP = '"+D03->D03_CODEXP+"'"
		cQuery +=    " AND D04_CARGA  = '"+D03->D03_CARGA+"'"
		cQuery +=    " AND D04_PEDIDO = '"+D03->D03_PEDIDO+"'"
		cQuery +=    " AND D04_CODOPE = '"+D03->D03_CODOPE+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD04 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD04,.F.,.T.)
		While (cAliasD04)->(!EoF())
			AAdd(aDados,{(cAliasD04)->D04_CODPRO,; //Código do produto
				           0,;                       //Quantidade já conferida
				           (cAliasD04)->D04_QTCONF,; //Quantidade do Produto
				           (cAliasD04)->D04_CARGA,;  //Carga
				           (cAliasD04)->D04_PEDIDO,; //Pedido
				           (cAliasD04)->D04_LOTE,;   //Lote
				           (cAliasD04)->D04_SUBLOT,; //Sub-lote
				           (cAliasD04)->D04_ITEM,;   //Item
				           (cAliasD04)->D04_SEQUEN,; //Sequência
				           (cAliasD04)->D04_PRDORI,; //Produto Origem
				          	 "" ,;                    //Código do Volume
				          (cAliasD04)->D04_CODEXP})  //Código de Expedição
			(cAliasD04)->(dbSkip())
		EndDo
		(cAliasD04)->(dbCloseArea())
		WMS102GrvE(,,,,,,,,,,,aDados)
	End Transaction
	RestArea(aAreaD01)
	RestArea(aAreaD02)
	RestArea(aAreaD03)
	RestArea(aAreaD04)
	RestArea(aAreaDCU)
	RestArea(aAreaSC9)
Return .T.
